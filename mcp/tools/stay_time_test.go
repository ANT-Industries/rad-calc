package tools

import (
	"context"
	"math"
	"testing"
)

func TestStayTimeHandler(t *testing.T) {
	tests := []struct {
		name     string
		input    StayTimeInput
		expected float64
	}{
		{
			name: "Calculate Stay Time",
			input: StayTimeInput{
				AllowableExposure: floatPtr(5),
				ExposureRate:      floatPtr(10), // hr
				SolveFor:          "stay_time",
			},
			expected: 1800, // (5/10) * 3600 = .5 * 3600
		},
		{
			name: "Calculate Allowable Exposure",
			input: StayTimeInput{
				StayTime:     floatPtr(3600), // 1 hour
				ExposureRate: floatPtr(10),
				SolveFor:     "allowable_exposure",
			},
			expected: 10, // (3600 * 10) / 3600
		},
		{
			name: "Calculate Exposure Rate",
			input: StayTimeInput{
				AllowableExposure: floatPtr(10),
				StayTime:          floatPtr(1800), // 0.5 hour
				SolveFor:          "exposure_rate",
			},
			expected: 20, // (10 / 1800) * 3600 = 10 / 0.5 = 20
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, out, err := StayTimeHandler(context.Background(), nil, tt.input)
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if math.Abs(out.Result-tt.expected) > 0.0001 {
				t.Errorf("expected %v, got %v", tt.expected, out.Result)
			}
		})
	}
}
