package tools

import (
	"context"
	"math"
	"testing"
)

func TestLineSourceHandler(t *testing.T) {
	tests := []struct {
		name     string
		input    LineSourceInput
		expected float64
	}{
		{
			name: "Calculate Exposure 2 Near Field (1/r)",
			// If D1 and D2 are under L/2, handles like 1/r
			input: LineSourceInput{
				Length:    floatPtr(10), // half = 5
				Exposure1: floatPtr(100),
				Distance1: floatPtr(1),
				Distance2: floatPtr(2),
				SolveFor:  "exposure_2",
			},
			expected: 50, // 100 * (1/2)
		},
		{
			name: "Calculate Distance 2 (exposure drops)",
			input: LineSourceInput{
				Length:    floatPtr(10),
				Exposure1: floatPtr(100),
				Exposure2: floatPtr(50),
				Distance1: floatPtr(1),
				Distance2: floatPtr(2), // Ensure coverage paths hit correctly
				SolveFor:  "distance_2",
			},
			expected: 2, // (100 / 50) * 1
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, out, err := LineSourceHandler(context.Background(), nil, tt.input)
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if math.Abs(out.Result-tt.expected) > 0.0001 {
				t.Errorf("expected %v, got %v", tt.expected, out.Result)
			}
		})
	}
}
