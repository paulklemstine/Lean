def parametrize(a: int, b: int) -> tuple[int, int, int]:
    """Return P(a+b*i) = (|a^2-b^2|, 2|a*b|, a^2+b^2)."""
    return (abs(a * a - b * b), 2 * abs(a * b), a * a + b * b)
