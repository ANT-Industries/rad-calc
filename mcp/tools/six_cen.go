package tools

import (
	"context"
	"fmt"
	"github.com/modelcontextprotocol/go-sdk/mcp"
)

type SixCenInput struct {
	Activity     *float64 `json:"activity,omitempty"`
	Energy       *float64 `json:"energy,omitempty"`
	Abundance    *float64 `json:"abundance,omitempty"`
	ExposureRate *float64 `json:"exposure_rate,omitempty"`
	SolveFor     string   `json:"solve_for"`
}


func SixCenHandler(ctx context.Context, req *mcp.CallToolRequest, input SixCenInput) (*mcp.CallToolResult, Output, error) {
	C := Val(input.Activity)
	E := Val(input.Energy)
	N := Val(input.Abundance)
	Exposure := Val(input.ExposureRate)

	var res float64
	var exp string

	switch input.SolveFor {
	case "activity":
		res = SafeCalc(func() float64 { return Exposure / (6 * N * E) })
		exp = fmt.Sprintf("Activity = %f / (6 * %f * %f)", Exposure, N, E)
	case "energy":
		res = SafeCalc(func() float64 { return Exposure / (6 * C * N) })
		exp = fmt.Sprintf("Energy = %f / (6 * %f * %f)", Exposure, C, N)
	case "abundance":
		res = SafeCalc(func() float64 { return Exposure / (6 * C * E) })
		exp = fmt.Sprintf("Abundance = %f / (6 * %f * %f)", Exposure, C, E)
	case "exposure_rate":
		fallthrough
	default:
		res = SafeCalc(func() float64 { return 6 * C * E * N })
		exp = fmt.Sprintf("Exposure Rate = 6 * %f * %f * %f", C, E, N)
	}

	return nil, Output{Result: res, Explanation: exp}, nil
}
