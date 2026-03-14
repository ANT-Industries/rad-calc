package tools

import "math"

type Output struct {
	Result      float64 `json:"result"`
	Explanation string  `json:"explanation,omitempty"`
}

// SafeCalc safely executes a calculation and catches any panics (e.g. division by zero).
// It returns 0 if the result is NaN or Infinity.
func SafeCalc(calc func() float64) float64 {
	defer func() {
		if r := recover(); r != nil {
			// Catch division by zero or other panics
		}
	}()
	res := calc()
	if math.IsNaN(res) || math.IsInf(res, 0) {
		return 0
	}
	return res
}

// Val safely dereferences a float pointer, returning 0 if nil.
func Val(v *float64) float64 {
	if v == nil {
		return 0
	}
	return *v
}
