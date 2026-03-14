# rad-calc MCP Server

This directory contains the Go-based [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) server for the Health Physics `rad-calc` calculators.

The server exposes 7 core calculators as interactive MCP Tools that can be directly used by any LLM/AI Assistant (like Claude Desktop) or navigated via a built-in rich HTML graphical user interface.

---

## 🏗 Building the Source

This project consists of a Go backend and an embedded HTML/JS frontend. You can compile everything into a single portable executable.

From this `mcp` directory, you can build the binary either by running Go directly or by using the included script:

```bash
go build -o ../bin/rad-calc main.go
```

---

## 🚀 Running & Using the Server

The server has two primary operational modes: **Stdio (Standard I/O)** and **HTTP Mode**.

### 1. Stdio Mode (Default)
By default, the compiled binary runs as a standard MCP server communicating over standard input/output. This is the optimal configuration for local desktop assistants like the Claude Desktop App.

**Example `claude_desktop_config.json`:**
```json
{
  "mcpServers": {
    "rad-calc": {
      "command": "/absolute/path/to/your/repo/bin/rad-calc"
    }
  }
}
```

### 2. HTTP Mode
You can launch the server over HTTP, which provides **Server-Sent Events (SSE)** for remote MCP clients and an interactive **Web GUI** for humans. 

Start the server using the `-http` flag:
```bash
../bin/rad-calc -http -port 8080
```

#### Using the Web GUI
Once running over HTTP, you can open your browser to `http://localhost:8080` to see an interactive dashboard of all available calculators, complete with forms, API execution, and chart visualizations.

#### Connecting an MCP Client via HTTP (Remote Mode)
To connect an AI agent to the streaming HTTP backend instead of Stdio, you point the client to the `/mcp/sse` endpoint.

**Example Remote Connection:**
```bash
npx -y mcp-remote http://localhost:8080/mcp/sse
```

*(Note: The server uses the modern `mcp.NewStreamableHTTPHandler` abstraction from the Go SDK, providing a unified endpoint at `/mcp/sse`.)*

---

## 🧰 Available Tools

1. **`six_cen_calc`**: Calculates the 6CEN Approximation rule of thumb.
2. **`point_source_calc`**: Inverse square law point source calculations.
3. **`line_source_calc`**: Linear source attenuation.
4. **`plane_source_calc`**: 2D radial plane exposure calculations.
5. **`half_life_calc`**: Standard radioactive exponential decay calculation.
6. **`shielding_calc`**: Half-Value Layer attenuation calculation.
7. **`stay_time_calc`**: Work duration safety limits calculation.
