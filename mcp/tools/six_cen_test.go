package tools

import (
	"context"
	"math"
	"testing"
)

func floatPtr(f float64) *float64 { return &f }

func TestSixCenHandler(t *testing.T) {
	tests := []struct {
		name     string
		input    SixCenInput
		expected float64
	}{
		{
			name: "Calculate Exposure Rate",
			input: SixCenInput{
				Activity:  floatPtr(10), // 10 Ci
				Energy:    floatPtr(1.2), // 1.2 MeV
				Abundance: floatPtr(1.0), // 100%
				SolveFor:  "exposure_rate",
			},
			expected: 6 * 10 * 1.2 * 1.0, // 72
		},
		{
			name: "Calculate Activity",
			input: SixCenInput{
				ExposureRate: floatPtr(72),
				Energy:       floatPtr(1.2),
				Abundance:    floatPtr(1.0),
				SolveFor:     "activity",
			},
			expected: 10,
		},
        {
			name: "Calculate Activity division by zero safety",
			input: SixCenInput{
				ExposureRate: floatPtr(72),
				Energy:       floatPtr(0),
				Abundance:    floatPtr(0),
				SolveFor:     "activity",
			},
			expected: 0,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, out, err := SixCenHandler(context.Background(), nil, tt.input)
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if math.Abs(out.Result-tt.expected) > 0.0001 {
				t.Errorf("expected %v, got %v", tt.expected, out.Result)
			}
		})
	}
}
