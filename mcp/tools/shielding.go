package tools

import (
	"context"
	"math"

	"github.com/modelcontextprotocol/go-sdk/mcp"
)

type ShieldingInput struct {
	InitialExposure *float64 `json:"initial_exposure,omitempty"`
	FinalExposure   *float64 `json:"final_exposure,omitempty"`
	NumHVL          *float64 `json:"num_hvl,omitempty"`
	SolveFor        string   `json:"solve_for"`
}

func ShieldingHandler(ctx context.Context, req *mcp.CallToolRequest, input ShieldingInput) (*mcp.CallToolResult, Output, error) {
	IE := Val(input.InitialExposure)
	FE := Val(input.FinalExposure)
	HVL := Val(input.NumHVL)

	var res float64

	switch input.SolveFor {
	case "initial_exposure":
		res = SafeCalc(func() float64 { return FE / math.Pow(0.5, HVL) })
	case "final_exposure":
		res = SafeCalc(func() float64 { return IE * math.Pow(0.5, HVL) })
	}

	return nil, Output{Result: res}, nil
}
