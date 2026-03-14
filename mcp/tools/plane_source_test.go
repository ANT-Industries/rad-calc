package tools

import (
	"context"
	"math"
	"testing"
)

func TestPlaneSourceHandler(t *testing.T) {
	tests := []struct {
		name     string
		input    PlaneSourceInput
		expected float64
	}{
		{
			name: "Calculate Constant Exposure (inner R1 region)",
			input: PlaneSourceInput{
				Radius:    floatPtr(100),
				Exposure1: floatPtr(100),
				Distance1: floatPtr(1),
				Distance2: floatPtr(5), // Both <= 10 (r1)
				SolveFor:  "exposure_2",
			},
			expected: 100, // Should be constant
		},
		{
			name: "Calculate Exposure dropoff past R7",
			input: PlaneSourceInput{
				Radius:    floatPtr(10), // r7 = 7
				Exposure1: floatPtr(100),
				Distance1: floatPtr(1), // Under r1 (1)
				Distance2: floatPtr(14), // Over r7
				SolveFor:  "exposure_2",
			},
			// ER1/3 * (r7/D2)^2 => (100/3) * (7/14)^2 = 33.33 * .25 = 8.3333...
			expected: 8.3333333333,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, out, err := PlaneSourceHandler(context.Background(), nil, tt.input)
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if math.Abs(out.Result-tt.expected) > 0.0001 {
				t.Errorf("expected %v, got %v", tt.expected, out.Result)
			}
		})
	}
}
