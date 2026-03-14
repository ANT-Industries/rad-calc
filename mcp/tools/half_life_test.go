package tools

import (
	"context"
	"math"
	"testing"
)

func TestHalfLifeHandler(t *testing.T) {
	tests := []struct {
		name     string
		input    HalfLifeInput
		expected float64
	}{
		{
			name: "Calculate Final Activity (one half life)",
			input: HalfLifeInput{
				InitialActivity: floatPtr(100),
				HalfLife:        floatPtr(10),
				Time:            floatPtr(10),
				SolveFor:        "final_activity",
			},
			expected: 50,
		},
		{
			name: "Calculate Initial Activity",
			input: HalfLifeInput{
				FinalActivity: floatPtr(50),
				HalfLife:      floatPtr(10),
				Time:          floatPtr(10),
				SolveFor:      "initial_activity",
			},
			expected: 100,
		},
        {
			name: "Calculate Time (two half lives)",
			input: HalfLifeInput{
				InitialActivity: floatPtr(100),
				FinalActivity:   floatPtr(25),
				HalfLife:        floatPtr(10),
				SolveFor:        "time",
			},
			expected: 20,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, out, err := HalfLifeHandler(context.Background(), nil, tt.input)
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if math.Abs(out.Result-tt.expected) > 0.0001 {
				t.Errorf("expected %v, got %v", tt.expected, out.Result)
			}
		})
	}
}
