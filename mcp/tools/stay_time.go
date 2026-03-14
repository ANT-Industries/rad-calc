package tools

import (
	"context"

	"github.com/modelcontextprotocol/go-sdk/mcp"
)

type StayTimeInput struct {
	StayTime          *float64 `json:"stay_time,omitempty"`
	AllowableExposure *float64 `json:"allowable_exposure,omitempty"`
	ExposureRate      *float64 `json:"exposure_rate,omitempty"`
	SolveFor          string   `json:"solve_for"`
}

func StayTimeHandler(ctx context.Context, req *mcp.CallToolRequest, input StayTimeInput) (*mcp.CallToolResult, Output, error) {
	ST := Val(input.StayTime)
	AE := Val(input.AllowableExposure)
	ER := Val(input.ExposureRate)

	var res float64

	switch input.SolveFor {
	case "stay_time":
		res = SafeCalc(func() float64 { return (AE / ER) * 3600 })
	case "allowable_exposure":
		res = SafeCalc(func() float64 { return (ST * ER) / 3600 })
	case "exposure_rate":
		res = SafeCalc(func() float64 { return (AE / ST) * 3600 })
	}

	return nil, Output{Result: res}, nil
}
