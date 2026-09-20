package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHealthEndpoint(t *testing.T) {
	router := setupRouter()

	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/health", nil)
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("Expected status 200, got %d", w.Code)
	}

	body := w.Body.String()
	if !strings.Contains(body, "cortexai_backend") || !strings.Contains(body, "healthy") {
		t.Fatalf("Unexpected body content: %s", body)
	}
}

func TestDevicesEndpoint(t *testing.T) {
	router := setupRouter()

	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/v1/devices", nil)
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("Expected status 200, got %d", w.Code)
	}

	body := w.Body.String()
	if !strings.Contains(body, "ESP32-S3") {
		t.Fatalf("Expected ESP32 device in response, got: %s", body)
	}
}

func TestTemplatesEndpoint(t *testing.T) {
	router := setupRouter()

	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/v1/templates", nil)
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("Expected status 200, got %d", w.Code)
	}

	body := w.Body.String()
	if !strings.Contains(body, "Show Weather") || !strings.Contains(body, "Fetch Temp") {
		t.Fatalf("Expected templates in response, got: %s", body)
	}
}

func TestInferenceEndpoint(t *testing.T) {
	router := setupRouter()

	payload := strings.NewReader(`{"device_id":"node-esp32-s3-01","prompt":"Turn on edge sensor"}`)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/inference", payload)
	req.Header.Set("Content-Type", "application/json")
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("Expected status 200, got %d", w.Code)
	}

	body := w.Body.String()
	if !strings.Contains(body, "completed") {
		t.Fatalf("Expected completed status, got: %s", body)
	}
}
