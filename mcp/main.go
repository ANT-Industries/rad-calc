package main

import (
	"context"
	"embed"
	"encoding/json"
	"flag"
	"fmt"
	"io/fs"
	"log"
	"net/http"
	"rad-calc-mcp/tools"
	"strings"

	"github.com/modelcontextprotocol/go-sdk/mcp"
)

//go:embed static/*
var staticFiles embed.FS

func main() {
	var httpMode bool
	var port int
	flag.BoolVar(&httpMode, "http", false, "Run as an HTTP server and web app instead of stdio MCP")
	flag.IntVar(&port, "port", 8080, "Port to run the HTTP server on if -http is set")
	flag.Parse()

	server := mcp.NewServer(&mcp.Implementation{Name: "rad-calc-mcp", Version: "v1.0.0"}, nil)

	mcp.AddTool(server, &mcp.Tool{Name: "six_cen_calc", Description: "Calculates the 6CEN Approximation rule of thumb"}, tools.SixCenHandler)
	mcp.AddTool(server, &mcp.Tool{Name: "point_source_calc", Description: "Inverse square law point source calculations"}, tools.PointSourceHandler)
	mcp.AddTool(server, &mcp.Tool{Name: "line_source_calc", Description: "Linear source attenuation"}, tools.LineSourceHandler)
	mcp.AddTool(server, &mcp.Tool{Name: "plane_source_calc", Description: "2D radial plane exposure calculations"}, tools.PlaneSourceHandler)
	mcp.AddTool(server, &mcp.Tool{Name: "half_life_calc", Description: "Standard radioactive exponential decay calculator"}, tools.HalfLifeHandler)
	mcp.AddTool(server, &mcp.Tool{Name: "shielding_calc", Description: "Half-Value Layer attenuation calculation"}, tools.ShieldingHandler)
	mcp.AddTool(server, &mcp.Tool{Name: "stay_time_calc", Description: "Work duration safety limits calculation"}, tools.StayTimeHandler)

	if !httpMode {
		log.Println("Running over StdioTransport...")
		if err := server.Run(context.Background(), &mcp.StdioTransport{}); err != nil {
			log.Fatal(err)
		}
		return
	}

	log.Printf("Starting HTTP server on :%d...", port)

	// --- 1. SET UP THE MCP TRANSPORT ---
	
	// Use Streamable HTTP Handler
	streamable := mcp.NewStreamableHTTPHandler(func(req *http.Request) *mcp.Server {
		return server
	}, nil)

	// Wrap handler with CORS and Logging
	mcpHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("[MCP] %s %s", r.Method, r.URL.String())
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		if r.URL.Scheme == "" {
			if r.TLS != nil {
				r.URL.Scheme = "https"
			} else {
				r.URL.Scheme = "http"
			}
		}
		if r.URL.Host == "" {
			r.URL.Host = r.Host
		}

		rec := &responseRecorder{ResponseWriter: w, status: 200}
		streamable.ServeHTTP(rec, r)

		if rec.status >= 400 {
			log.Printf("[MCP ERROR] %d: %s", rec.status, string(rec.body))
		}
	})

	http.Handle("/mcp/sse", mcpHandler)

	// --- 2. SET UP THE REST API FOR WEB APP ---
	http.HandleFunc("/api/tools", func(w http.ResponseWriter, r *http.Request) {
		type Field struct {
			Name string `json:"name"`
			Type string `json:"type"`
		}
		type ToolInfo struct {
			Name            string   `json:"name"`
			Description     string   `json:"description"`
			Fields          []Field  `json:"fields"`
			SolveForOptions []string `json:"solve_for_options,omitempty"`
		}

		toolsList := []ToolInfo{
			{
				Name:        "six_cen_calc",
				Description: "Calculates the 6CEN Approximation rule of thumb",
				Fields: []Field{
					{Name: "activity", Type: "activity"},
					{Name: "energy", Type: "energy"},
					{Name: "abundance", Type: "number"},
					{Name: "exposure_rate", Type: "exposure_rate"},
				},
				SolveForOptions: []string{"activity", "energy", "abundance", "exposure_rate"},
			},
			{
				Name:        "point_source_calc",
				Description: "Inverse square law point source calculations",
				Fields: []Field{
					{Name: "exposure_1", Type: "exposure"},
					{Name: "exposure_2", Type: "exposure"},
					{Name: "distance_1", Type: "distance"},
					{Name: "distance_2", Type: "distance"},
				},
				SolveForOptions: []string{"exposure_1", "exposure_2", "distance_1", "distance_2"},
			},
			{
				Name:        "line_source_calc",
				Description: "Linear source attenuation",
				Fields: []Field{
					{Name: "length", Type: "distance"},
					{Name: "exposure_1", Type: "exposure"},
					{Name: "exposure_2", Type: "exposure"},
					{Name: "distance_1", Type: "distance"},
					{Name: "distance_2", Type: "distance"},
				},
				SolveForOptions: []string{"exposure_2", "distance_2"},
			},
			{
				Name:        "plane_source_calc",
				Description: "2D radial plane exposure calculations",
				Fields: []Field{
					{Name: "radius", Type: "distance"},
					{Name: "exposure_1", Type: "exposure"},
					{Name: "exposure_2", Type: "exposure"},
					{Name: "distance_1", Type: "distance"},
					{Name: "distance_2", Type: "distance"},
				},
				SolveForOptions: []string{"exposure_2", "distance_2"},
			},
			{
				Name:        "half_life_calc",
				Description: "Standard radioactive exponential decay calculator",
				Fields: []Field{
					{Name: "initial_activity", Type: "activity"},
					{Name: "final_activity", Type: "activity"},
					{Name: "half_life", Type: "time"},
					{Name: "time", Type: "time"},
				},
				SolveForOptions: []string{"initial_activity", "final_activity", "half_life", "time"},
			},
			{
				Name:        "shielding_calc",
				Description: "Half-Value Layer attenuation calculation",
				Fields: []Field{
					{Name: "initial_exposure", Type: "exposure"},
					{Name: "final_exposure", Type: "exposure"},
					{Name: "num_hvl", Type: "number"},
				},
				SolveForOptions: []string{"initial_exposure", "final_exposure"},
			},
			{
				Name:        "stay_time_calc",
				Description: "Work duration safety limits calculation",
				Fields: []Field{
					{Name: "stay_time", Type: "time"},
					{Name: "allowable_exposure", Type: "exposure"},
					{Name: "exposure_rate", Type: "exposure_rate"},
				},
				SolveForOptions: []string{"stay_time", "allowable_exposure", "exposure_rate"},
			},
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(toolsList)
	})

	http.HandleFunc("/api/calculate/", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}
		toolName := strings.TrimPrefix(r.URL.Path, "/api/calculate/")
		
		var args map[string]interface{}
		if err := json.NewDecoder(r.Body).Decode(&args); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		ctx := context.Background()
		var res interface{}
		var err error

		b, _ := json.Marshal(args)
		req := &mcp.CallToolRequest{
			Params: &mcp.CallToolParamsRaw{
				Name:      toolName,
				Arguments: json.RawMessage(b),
			},
		}

		switch toolName {
		case "six_cen_calc":
			var input tools.SixCenInput
			err = mapToStruct(args, &input)
			if err == nil { _, res, err = tools.SixCenHandler(ctx, req, input) }
		case "point_source_calc":
			var input tools.PointSourceInput
			err = mapToStruct(args, &input)
			if err == nil { _, res, err = tools.PointSourceHandler(ctx, req, input) }
		case "line_source_calc":
			var input tools.LineSourceInput
			err = mapToStruct(args, &input)
			if err == nil { _, res, err = tools.LineSourceHandler(ctx, req, input) }
		case "plane_source_calc":
			var input tools.PlaneSourceInput
			err = mapToStruct(args, &input)
			if err == nil { _, res, err = tools.PlaneSourceHandler(ctx, req, input) }
		case "half_life_calc":
			var input tools.HalfLifeInput
			err = mapToStruct(args, &input)
			if err == nil { _, res, err = tools.HalfLifeHandler(ctx, req, input) }
		case "shielding_calc":
			var input tools.ShieldingInput
			err = mapToStruct(args, &input)
			if err == nil { _, res, err = tools.ShieldingHandler(ctx, req, input) }
		case "stay_time_calc":
			var input tools.StayTimeInput
			err = mapToStruct(args, &input)
			if err == nil { _, res, err = tools.StayTimeHandler(ctx, req, input) }
		default:
			http.Error(w, "Unknown tool", http.StatusNotFound)
			return
		}

		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(res)
	})

	staticSubFS, err := fs.Sub(staticFiles, "static")
	if err != nil {
		log.Fatal(err)
	}
	http.Handle("/", http.FileServer(http.FS(staticSubFS)))
	
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", port), nil))
}

func mapToStruct(m map[string]interface{}, v interface{}) error {
	b, err := json.Marshal(m)
	if err != nil {
		return err
	}
	return json.Unmarshal(b, v)
}

type responseRecorder struct {
	http.ResponseWriter
	status int
	body   []byte
}

func (r *responseRecorder) WriteHeader(statusCode int) {
	r.status = statusCode
	r.ResponseWriter.WriteHeader(statusCode)
}

func (r *responseRecorder) Write(b []byte) (int, error) {
	r.body = append(r.body, b...)
	return r.ResponseWriter.Write(b)
}
