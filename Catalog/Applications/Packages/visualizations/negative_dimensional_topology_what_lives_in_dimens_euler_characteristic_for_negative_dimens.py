def euler_char_neg_dim(dim: int, components: int) -> int:
    n = abs(dim)
    return components if n % 2 == 0 else -components