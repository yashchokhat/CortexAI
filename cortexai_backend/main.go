package main

import (
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

// Device represents an Edge AI device in CortexAI.
type Device struct {
	ID           string   `json:"id"`
	Name         string   `json:"name"`
	Chip         string   `json:"chip"`
	Status       string   `json:"status"` // "online", "offline", "syncing"
	IPAddress    string   `json:"ip_address"`
	FirmwareVer  string   `json:"firmware_version"`
	Capabilities []string `json:"capabilities"`
	LastSeen     string   `json:"last_seen"`
}

// Template represents a quick-run action or agent configuration template.
type Template struct {
	ID           string `json:"id"`
	Title        string `json:"title"`
	Chip         string `json:"chip"`
	Description  string `json:"description"`
	Icon         string `json:"icon"`
	ActionPrompt string `json:"action_prompt"`
	Category     string `json:"category"`
}

// InferenceRequest represents an AI prompt sent to the backend.
type InferenceRequest struct {
	DeviceID string `json:"device_id" binding:"required"`
	Prompt   string `json:"prompt" binding:"required"`
	Model    string `json:"model,omitempty"`
}

var startTime = time.Now()

var mockDevices = []Device{
	{
		ID:           "node-esp32-s3-01",
		Name:         "Living Room Edge Node",
		Chip:         "ESP32-S3-WROOM-1",
		Status:       "online",
		IPAddress:    "192.168.1.101",
		FirmwareVer:  "v1.2.0-cortex",
		Capabilities: []string{"audio-in", "audio-out", "offline-chat", "gpio-control"},
		LastSeen:     time.Now().UTC().Format(time.RFC3339),
	},
	{
		ID:           "node-esp32-p4-02",
		Name:         "Vision Gateway P4",
		Chip:         "ESP32-P4",
		Status:       "online",
		IPAddress:    "192.168.1.102",
		FirmwareVer:  "v1.4.1-cortex",
		Capabilities: []string{"camera-stream", "edge-inference", "h264-encoding", "ethernet"},
		LastSeen:     time.Now().UTC().Format(time.RFC3339),
	},
	{
		ID:           "node-esp32-s3-03",
		Name:         "Sensor Hub Node",
		Chip:         "ESP32-S3",
		Status:       "idle",
		IPAddress:    "192.168.1.105",
		FirmwareVer:  "v1.1.0-cortex",
		Capabilities: []string{"temp-humidity", "radar-mmwave", "ble-mesh"},
		LastSeen:     time.Now().Add(-5 * time.Minute).UTC().Format(time.RFC3339),
	},
}

var mockTemplates = []Template{
	{
		ID:           "tpl-weather",
		Title:        "Show Weather",
		Chip:         "Live Sync",
		Description:  "Retrieve local atmospheric conditions, humidity & pressure telemetry.",
		Icon:         "weather",
		ActionPrompt: "Fetch local weather report and current atmospheric telemetry.",
		Category:     "Utility",
	},
	{
		ID:           "tpl-score",
		Title:        "Get Score",
		Chip:         "Sports API",
		Description:  "Stream live match scores, team standings & tournament feed.",
		Icon:         "score",
		ActionPrompt: "Stream current match live score and game analytics.",
		Category:     "Feed",
	},
	{
		ID:           "tpl-on-led",
		Title:        "On LED",
		Chip:         "GPIO Out",
		Description:  "Energize onboard optical indicator and visual alert array.",
		Icon:         "lightbulb_on",
		ActionPrompt: "Send HIGH logic pulse to GPIO 2 status LED.",
		Category:     "Hardware",
	},
	{
		ID:           "tpl-temp-hum",
		Title:        "Fetch Temp & Humidity",
		Chip:         "I2C Sensor",
		Description:  "Read SHTC3 high-precision thermal & relative humidity register.",
		Icon:         "thermo",
		ActionPrompt: "Query I2C bus 0x70 for real-time temperature and humidity.",
		Category:     "Sensors",
	},
	{
		ID:           "tpl-off-led",
		Title:        "Off LED",
		Chip:         "GPIO Out",
		Description:  "Extinguish active LED arrays to conserve edge power draw.",
		Icon:         "lightbulb_off",
		ActionPrompt: "Send LOW logic pulse to GPIO 2 status LED.",
		Category:     "Hardware",
	},
	{
		ID:           "tpl-notification",
		Title:        "Send Notification",
		Chip:         "Push APN",
		Description:  "Dispatch high-priority alert to linked iOS and desktop clients.",
		Icon:         "bell",
		ActionPrompt: "Dispatch push notification to primary developer endpoint.",
		Category:     "Alerts",
	},
	{
		ID:           "tpl-read-sensor",
		Title:        "Read Sensor",
		Chip:         "ADC Pin",
		Description:  "Sample 12-bit analog input channels for raw voltage wave.",
		Icon:         "gauge",
		ActionPrompt: "Sample analog channel A0-A3 voltage waveform buffer.",
		Category:     "Sensors",
	},
	{
		ID:           "tpl-trigger-alert",
		Title:        "Trigger Alert",
		Chip:         "Relay Switch",
		Description:  "Trip emergency relay interlock and beacon warning siren.",
		Icon:         "alert",
		ActionPrompt: "Trip hardware safety relay switch and arm perimeter buzzer.",
		Category:     "Security",
	},
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8000"
	}

	router := setupRouter()

	log.Printf("🚀 CortexAI Backend running on http://0.0.0.0:%s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

func setupRouter() *gin.Engine {
	r := gin.Default()

	// Configure CORS for Flutter Web, Android Emulator (10.0.2.2), and localhost
	corsConfig := cors.DefaultConfig()
	corsConfig.AllowAllOrigins = true
	corsConfig.AllowMethods = []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"}
	corsConfig.AllowHeaders = []string{"Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With"}
	r.Use(cors.New(corsConfig))

	// Root endpoint
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "CortexAI Edge Gateway API",
			"version": "1.2.0",
			"docs":    "/api/v1",
			"health":  "/health",
		})
	})

	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":    "healthy",
			"service":   "cortexai_backend",
			"version":   "1.2.0",
			"uptime":    time.Since(startTime).String(),
			"timestamp": time.Now().UTC().Format(time.RFC3339),
		})
	})

	// API v1 group
	v1 := r.Group("/api/v1")
	{
		// System status
		v1.GET("/status", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{
				"system": "CortexAI Edge Platform",
				"status": "operational",
				"stats": gin.H{
					"total_devices":    len(mockDevices),
					"online_devices":   2,
					"active_pipelines": 1,
					"cpu_load_percent": 14.2,
					"memory_used_mb":   48.5,
				},
				"timestamp": time.Now().UTC().Format(time.RFC3339),
			})
		})

		// List all devices
		v1.GET("/devices", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{
				"count":   len(mockDevices),
				"devices": mockDevices,
			})
		})

		// Get device by ID
		v1.GET("/devices/:id", func(c *gin.Context) {
			id := c.Param("id")
			for _, d := range mockDevices {
				if d.ID == id {
					c.JSON(http.StatusOK, d)
					return
				}
			}
			c.JSON(http.StatusNotFound, gin.H{"error": "Device not found"})
		})

		// List all templates
		v1.GET("/templates", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{
				"count":     len(mockTemplates),
				"templates": mockTemplates,
			})
		})

		// Edge AI inference
		v1.POST("/inference", func(c *gin.Context) {
			var req InferenceRequest
			if err := c.ShouldBindJSON(&req); err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
				return
			}

			c.JSON(http.StatusOK, gin.H{
				"task_id":   "inf-" + time.Now().Format("20060102150405"),
				"device_id": req.DeviceID,
				"prompt":    req.Prompt,
				"status":    "completed",
				"result": gin.H{
					"response":    "CortexAI Edge node acknowledged instruction: '" + req.Prompt + "'. Executing deterministically on ESP32 agent.",
					"tokens_used": 38,
					"latency_ms":  16,
					"mode":        "local-edge",
				},
				"created_at": time.Now().UTC().Format(time.RFC3339),
			})
		})
	}

	return r
}
