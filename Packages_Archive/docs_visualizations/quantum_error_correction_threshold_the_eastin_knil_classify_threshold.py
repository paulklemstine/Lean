def classify(c: float, p: float) -> str:
    q0 = c * p
    if q0 < 1.0:
        return "below threshold  -> logical error -> 0"
    if q0 == 1.0:
        return "at threshold     -> logical error frozen at 1/c"
    return "above threshold  -> logical error -> +inf"
