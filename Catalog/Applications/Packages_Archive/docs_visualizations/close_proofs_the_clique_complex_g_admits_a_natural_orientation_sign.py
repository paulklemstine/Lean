def sgn(x, s):
    """Orientation sign (-1)^(number of elements of s strictly below x)."""
    rank = sum(1 for y in s if y < x)
    return (-1) ** rank
