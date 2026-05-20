def parallel_path_exact_probability(k: int, r: int, p: float) -> float:
    """Exact provability probability for parallel path model.
    Pr[provable] = 1 - (1 - p^k)^r"""
    return 1.0 - (1.0 - p ** k) ** r

def parallel_path_threshold(k: int, r: int) -> float:
    """1/2-threshold: p_{1/2} = (1 - 2^{-1/r})^{1/k}"""
    return (1.0 - 2.0 ** (-1.0 / r)) ** (1.0 / k)

# Example
for k in [2, 3, 5]:
    for r in [1, 5, 20]:
        p_half = parallel_path_threshold(k, r)
        print(f"k={k}, r={r}: threshold = {p_half:.4f}")