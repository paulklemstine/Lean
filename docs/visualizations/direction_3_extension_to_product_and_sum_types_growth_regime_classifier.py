def classify_growth_regime(t):
    if has_arrow(t): return "double-exponential"
    elif has_prod(t): return "exponential"
    else: return "linear"