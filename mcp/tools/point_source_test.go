package tools

import (
	"context"
	"math"
	"testing"
)

func TestPointSourceHandler(t *testing.T) {
	tests := []struct {
		name     string
		input    PointSourceInput
		expected float64
	}{
		{
			name: "Calculate Exposure 2",
			input: PointSourceInput{
				Exposure1: floatPtr(100),
				Distance1: floatPtr(1),
				Distance2: floatPtr(2),
				SolveFor:  "exposure_2",
			},
			expected: 25, // 100 * (1/2)^2 = 25
		},
		{
			name: "Calculate Distance 2 (inverse square)",
			input: PointSourceInput{
				Exposure1: floatPtr(100),
				Distance1: floatPtr(1),
				Exposure2: floatPtr(25),
				SolveFor:  "distance_2",
			},
			expected: 2, // math.sqrt( (100/25) * 1^2 ) = 2
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, out, err := PointSourceHandler(context.Background(), nil, tt.input)
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if math.Abs(out.Result-tt.expected) > 0.0001 {
				t.Errorf("expected %v, got %v", tt.expected, out.Result)
			}
		})
	}
}
