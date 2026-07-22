from math import log2, floor

def newton_steps(target_digits: int) -> int:
    """Hensel iteration complexity: number of Newton steps to reach
    `target_digits` of p-adic precision, given quadratic (doubling) convergence.

    Returns floor(log2(target_digits)) + 1, the certified step count."""
    if target_digits < 1:
        raise ValueError("target_digits must be >= 1")
    return floor(log2(target_digits)) + 1

def precision_after(steps: int) -> int:
    """Lower bound on attained precision after `steps` doublings: 2^steps."""
    return 2 ** steps

def hensel_certificate(target_digits: int) -> dict:
    """Build a certified Hensel-lifting plan: step count and guaranteed
    precision, verifying precision >= target and sublinearity (steps < target)."""
    steps = newton_steps(target_digits)
    prec = precision_after(steps)
    return {
        "target_digits": target_digits,
        "newton_steps": steps,
        "guaranteed_precision": prec,
        "precision_ok": prec >= target_digits,
        "sublinear": steps < target_digits,
    }
