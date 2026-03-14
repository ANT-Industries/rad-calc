package tools

import "fmt"

// --- Activity ---

func BqToCi(val float64) float64 { return val / 3.7e10 }
func CiToBq(val float64) float64 { return val * 3.7e10 }

func ConvertToCuries(unit string, val float64) (float64, error) {
	switch unit {
	case "dps":
		return BqToCi(val), nil
	case "dpm":
		return val / 2.22e12, nil
	case "Ci":
		return val, nil
	case "pCi":
		return val / 1e12, nil
	case "nCi":
		return val / 1e9, nil
	case "uCi":
		return val / 1e6, nil
	case "mCi":
		return val / 1e3, nil
	case "Bq":
		return BqToCi(val), nil
	case "kBq":
		return BqToCi(val * 1e3), nil
	case "MBq":
		return BqToCi(val * 1e6), nil
	case "GBq":
		return BqToCi(val * 1e9), nil
	case "TBq":
		return BqToCi(val * 1e12), nil
	default:
		return 0, fmt.Errorf("unknown activity unit: %s", unit)
	}
}

func ConvertFromCuries(unit string, val float64) (float64, error) {
	switch unit {
	case "dps":
		return CiToBq(val), nil
	case "dpm":
		return val * 2.22e12, nil
	case "Ci":
		return val, nil
	case "pCi":
		return val * 1e12, nil
	case "nCi":
		return val * 1e9, nil
	case "uCi":
		return val * 1e6, nil
	case "mCi":
		return val * 1e3, nil
	case "Bq":
		return CiToBq(val), nil
	case "kBq":
		return CiToBq(val) / 1e3, nil
	case "MBq":
		return CiToBq(val) / 1e6, nil
	case "GBq":
		return CiToBq(val) / 1e9, nil
	case "TBq":
		return CiToBq(val) / 1e12, nil
	default:
		return 0, fmt.Errorf("unknown activity unit: %s", unit)
	}
}

// --- Distance ---

func ConvertToCentimeters(unit string, val float64) (float64, error) {
	switch unit {
	case "cm":
		return val, nil
	case "m":
		return val * 100, nil
	case "inch":
		return val * 2.54, nil
	case "foot":
		return val * 2.54 * 12, nil
	case "yard":
		return val * 2.54 * 12 * 3, nil
	default:
		return 0, fmt.Errorf("unknown distance unit: %s", unit)
	}
}

func ConvertFromCentimeters(unit string, val float64) (float64, error) {
	switch unit {
	case "cm":
		return val, nil
	case "m":
		return val / 100, nil
	case "inch":
		return val / 2.54, nil
	case "foot":
		return val / 2.54 / 12, nil
	case "yard":
		return val / 2.54 / 12 / 3, nil
	default:
		return 0, fmt.Errorf("unknown distance unit: %s", unit)
	}
}

// --- Dose ---

func ConvertToRem(unit string, val float64) (float64, error) {
	switch unit {
	case "Rem":
		return val, nil
	case "mRem":
		return val / 1000, nil
	case "uRem":
		return val / 1e6, nil
	default:
		return 0, fmt.Errorf("unknown dose unit: %s", unit)
	}
}

func ConvertFromRem(unit string, val float64) (float64, error) {
	switch unit {
	case "Rem":
		return val, nil
	case "mRem":
		return val * 1000, nil
	case "uRem":
		return val * 1e6, nil
	default:
		return 0, fmt.Errorf("unknown dose unit: %s", unit)
	}
}

// --- Energy ---

func ConvertToMeV(unit string, val float64) (float64, error) {
	switch unit {
	case "mev":
		return val, nil
	case "kev":
		return val / 1000, nil
	default:
		return 0, fmt.Errorf("unknown energy unit: %s", unit)
	}
}

func ConvertFromMeV(unit string, val float64) (float64, error) {
	switch unit {
	case "mev":
		return val, nil
	case "kev":
		return val * 1000, nil
	default:
		return 0, fmt.Errorf("unknown energy unit: %s", unit)
	}
}

// --- Exposure ---

func ConvertToRoentgen(unit string, val float64) (float64, error) {
	switch unit {
	case "R":
		return val, nil
	case "mR":
		return val / 1000, nil
	case "uR":
		return val / 1e6, nil
	default:
		return 0, fmt.Errorf("unknown exposure unit: %s", unit)
	}
}

func ConvertFromRoentgen(unit string, val float64) (float64, error) {
	switch unit {
	case "R":
		return val, nil
	case "mR":
		return val * 1000, nil
	case "uR":
		return val * 1e6, nil
	default:
		return 0, fmt.Errorf("unknown exposure unit: %s", unit)
	}
}

// --- Exposure Rate ---

func ConvertToRoentgenPerHour(unit string, val float64) (float64, error) {
	switch unit {
	case "R/hr":
		return val, nil
	case "mR/hr":
		return val / 1000, nil
	case "uR/hr":
		return val / 1e6, nil
	default:
		return 0, fmt.Errorf("unknown exposure rate unit: %s", unit)
	}
}

func ConvertFromRoentgenPerHour(unit string, val float64) (float64, error) {
	switch unit {
	case "R/hr":
		return val, nil
	case "mR/hr":
		return val * 1000, nil
	case "uR/hr":
		return val * 1e6, nil
	default:
		return 0, fmt.Errorf("unknown exposure rate unit: %s", unit)
	}
}

// --- Time ---

func ConvertToSeconds(unit string, val float64) (float64, error) {
	switch unit {
	case "s":
		return val, nil
	case "min":
		return val * 60, nil
	case "hr":
		return val * 60 * 60, nil
	case "d":
		return val * 60 * 60 * 24, nil
	case "y":
		return val * 60 * 60 * 24 * 365.25, nil
	default:
		return 0, fmt.Errorf("unknown time unit: %s", unit)
	}
}

func ConvertFromSeconds(unit string, val float64) (float64, error) {
	switch unit {
	case "s":
		return val, nil
	case "min":
		return val / 60, nil
	case "hr":
		return val / 60 / 60, nil
	case "d":
		return val / 60 / 60 / 24, nil
	case "y":
		return val / 60 / 60 / 24 / 365.25, nil
	default:
		return 0, fmt.Errorf("unknown time unit: %s", unit)
	}
}
