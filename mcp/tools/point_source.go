package tools

import (
	"context"
	"github.com/modelcontextprotocol/go-sdk/mcp"
	"math"
)

type PointSourceInput struct {
	Exposure1 *float64 `json:"exposure_1,omitempty"`
	Exposure2 *float64 `json:"exposure_2,omitempty"`
	Distance1 *float64 `json:"distance_1,omitempty"`
	Distance2 *float64 `json:"distance_2,omitempty"`
	SolveFor  string   `json:"solve_for"`
}

func PointSourceHandler(ctx context.Context, req *mcp.CallToolRequest, input PointSourceInput) (*mcp.CallToolResult, Output, error) {
	ER1 := Val(input.Exposure1)
	ER2 := Val(input.Exposure2)
	D1 := Val(input.Distance1)
	D2 := Val(input.Distance2)

	var res float64

	switch input.SolveFor {
	case "exposure_1":
		res = SafeCalc(func() float64 { return ER2 * math.Pow(D2/D1, 2) })
	case "exposure_2":
		res = SafeCalc(func() float64 { return ER1 * math.Pow(D1/D2, 2) })
	case "distance_1":
		res = SafeCalc(func() float64 { return math.Sqrt((ER2 / ER1) * math.Pow(D2, 2)) })
	case "distance_2":
		res = SafeCalc(func() float64 { return math.Sqrt((ER1 / ER2) * math.Pow(D1, 2)) })
	}

	return nil, Output{Result: res}, nil
}
