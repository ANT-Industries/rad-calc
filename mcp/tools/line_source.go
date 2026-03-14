package tools

import (
	"context"
	"math"

	"github.com/modelcontextprotocol/go-sdk/mcp"
)

type LineSourceInput struct {
	Length    *float64 `json:"length,omitempty"`
	Exposure1 *float64 `json:"exposure_1,omitempty"`
	Exposure2 *float64 `json:"exposure_2,omitempty"`
	Distance1 *float64 `json:"distance_1,omitempty"`
	Distance2 *float64 `json:"distance_2,omitempty"`
	SolveFor  string   `json:"solve_for"`
}

func LineSourceHandler(ctx context.Context, req *mcp.CallToolRequest, input LineSourceInput) (*mcp.CallToolResult, Output, error) {
	L := Val(input.Length)
	ER1 := Val(input.Exposure1)
	ER2 := Val(input.Exposure2)
	D1 := Val(input.Distance1)
	D2 := Val(input.Distance2)

	var res float64

	switch input.SolveFor {
	case "exposure_2":
		res = SafeCalc(func() float64 {
			halfL := L / 2
			if D1 < D2 {
				if D1 <= halfL {
					return ER1 * (D1 / D2)
				} else {
					exposureRateL2 := ER1 * (D1 / halfL)
					return exposureRateL2 * math.Pow(halfL/D2, 2)
				}
			}
			if D1 > D2 {
				if D2 > halfL {
					return ER1 * math.Pow(D1/halfL, 2)
				} else {
					exposureRateL2 := ER1 * math.Pow(D1/halfL, 2)
					return exposureRateL2 * (halfL / D2)
				}
			}
			return ER1
		})
	case "distance_2":
		res = SafeCalc(func() float64 {
			halfL := L / 2
			if ER2 > ER1 {
				if D1 <= halfL {
					return (ER1 / ER2) * D1
				} else {
					exposureRateL2 := ER1 * math.Pow(D1/halfL, 2)
					return (exposureRateL2 / ER2) * halfL
				}
			}
			if ER2 < ER1 {
				if D2 <= halfL {
					return (ER1 / ER2) * D1
				} else {
					exposureRateL2 := ER1 * (D1 / halfL)
					return math.Sqrt((exposureRateL2 / ER2) * math.Pow(D1, 2))
				}
			}
			return D1
		})
	}

	return nil, Output{Result: res}, nil
}
