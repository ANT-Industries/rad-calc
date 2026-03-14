package tools

import (
	"context"
	"math"

	"github.com/modelcontextprotocol/go-sdk/mcp"
)

type HalfLifeInput struct {
	InitialActivity *float64 `json:"initial_activity,omitempty"`
	FinalActivity   *float64 `json:"final_activity,omitempty"`
	HalfLife        *float64 `json:"half_life,omitempty"`
	Time            *float64 `json:"time,omitempty"`
	SolveFor        string   `json:"solve_for"`
}

func HalfLifeHandler(ctx context.Context, req *mcp.CallToolRequest, input HalfLifeInput) (*mcp.CallToolResult, Output, error) {
	IA := Val(input.InitialActivity)
	FA := Val(input.FinalActivity)
	HL := Val(input.HalfLife)
	T := Val(input.Time)

	var res float64

	switch input.SolveFor {
	case "initial_activity":
		res = SafeCalc(func() float64 { return FA * math.Exp((math.Ln2/HL)*T) })
	case "final_activity":
		res = SafeCalc(func() float64 { return IA * math.Exp(-((math.Ln2 / HL) * T)) })
	case "half_life":
		res = SafeCalc(func() float64 { return (T * math.Ln2) / math.Log(IA/FA) })
	case "time":
		res = SafeCalc(func() float64 { return math.Log(FA/IA) / -(math.Ln2 / HL) })
	}

	return nil, Output{Result: res}, nil
}
