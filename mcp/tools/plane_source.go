package tools

import (
	"context"
	"math"

	"github.com/modelcontextprotocol/go-sdk/mcp"
)

type PlaneSourceInput struct {
	Radius    *float64 `json:"radius,omitempty"`
	Exposure1 *float64 `json:"exposure_1,omitempty"`
	Exposure2 *float64 `json:"exposure_2,omitempty"`
	Distance1 *float64 `json:"distance_1,omitempty"`
	Distance2 *float64 `json:"distance_2,omitempty"`
	SolveFor  string   `json:"solve_for"`
}

func PlaneSourceHandler(ctx context.Context, req *mcp.CallToolRequest, input PlaneSourceInput) (*mcp.CallToolResult, Output, error) {
	Rad := Val(input.Radius)
	ER1 := Val(input.Exposure1)
	ER2 := Val(input.Exposure2)
	D1 := Val(input.Distance1)
	D2 := Val(input.Distance2)

	var res float64

	switch input.SolveFor {
	case "exposure_2":
		res = SafeCalc(func() float64 {
			r1 := Rad * 0.1
			r7 := Rad * 0.7
			if D1 < D2 {
				if D2 <= r1 || ((D1 > r1 && D1 <= r7) && (D2 > r1 && D2 <= r7)) {
					return ER1
				} else if D1 <= r1 && D2 > r1 && D2 <= r7 {
					return ER1 / 3
				} else if D1 <= r1 && D2 > r7 {
					return (ER1 / 3) * math.Pow(r7/D2, 2)
				} else if D1 > r1 && D1 <= r7 && D2 > r7 {
					return ER1 * math.Pow(r7/D2, 2)
				} else if D1 > r7 {
					return ER1 * math.Pow(D1/D2, 2)
				}
				return ER1
			}
			if D1 > D2 {
				if D1 <= r1 || ((D2 > r1 && D2 <= r7) && (D1 > r1 && D1 <= r7)) {
					return ER1
				} else if D2 <= r1 && D1 > r1 && D1 <= r7 {
					return ER1 / 3
				} else if D2 <= r1 && D1 > r7 {
					return (ER1 / 3) * math.Pow(r7/D1, 2)
				} else if D2 > r1 && D2 <= r7 && D1 > r7 {
					return ER1 * math.Pow(r7/D1, 2)
				} else if D2 > r7 {
					return ER1 * math.Pow(D2/D1, 2)
				}
				return ER1
			}
			return ER1
		})
	case "distance_2":
		res = SafeCalc(func() float64 {
			halfR := Rad / 2
			if ER2 > ER1 {
				if D1 <= halfR {
					return (ER1 / ER2) * D1
				} else {
					exposureRateL2 := ER1 * math.Pow(D1/halfR, 2)
					return (exposureRateL2 / ER2) * halfR
				}
			}
			if ER2 < ER1 {
				if D2 <= halfR {
					return (ER1 / ER2) * D1
				} else {
					exposureRateL2 := ER1 * (D1 / halfR)
					return math.Sqrt((exposureRateL2 / ER2) * math.Pow(D1, 2))
				}
			}
			return D1
		})
	}

	return nil, Output{Result: res}, nil
}
