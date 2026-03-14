package tools

import (
	"context"
	"math"
	"testing"
)

func TestShieldingHandler(t *testing.T) {
	tests := []struct {
		name     string
		input    ShieldingInput
		expected float64
	}{
		{
			name: "Calculate Final Exposure (1 HVL)",
			input: ShieldingInput{
				InitialExposure: floatPtr(100),
				NumHVL:          floatPtr(1),
				SolveFor:        "final_exposure",
			},
			expected: 50, // 100 * (0.5)^1
		},
		{
			name: "Calculate Initial Exposure",
			input: ShieldingInput{
				FinalExposure: floatPtr(25),
				NumHVL:        floatPtr(2),
				SolveFor:      "initial_exposure",
			},
			expected: 100, // 25 / (0.5)^2
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, out, err := ShieldingHandler(context.Background(), nil, tt.input)
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if math.Abs(out.Result-tt.expected) > 0.0001 {
				t.Errorf("expected %v, got %v", tt.expected, out.Result)
			}
		})
	}
}
