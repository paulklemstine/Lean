def closed_form(n: int) -> int:
    if n < 0: raise ValueError("n must be nonnegative")
    numerator = 127 * (pow(1000, n + 1) - 1)
    value, remainder = divmod(numerator, 999)
    if remainder: raise ArithmeticError("nonexact division")
    return value
