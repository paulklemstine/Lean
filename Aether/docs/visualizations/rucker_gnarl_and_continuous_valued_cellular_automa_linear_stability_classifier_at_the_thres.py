def classify(a: float) -> str:
    """Stability classifier with threshold a = 1/2.

    Returns 'laminar' on [0, 1/2] (spectral radius == 1, maximum principle
    holds) and 'unstable' otherwise (spectral radius |1 - 4a| > 1).
    """
    if 0.0 <= a <= 0.5:
        return "laminar"
    return "unstable"
