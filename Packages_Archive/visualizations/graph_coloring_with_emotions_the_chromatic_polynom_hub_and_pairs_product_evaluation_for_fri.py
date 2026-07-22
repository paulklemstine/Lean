def friendship_chromatic_evaluation(n: int, k: int) -> int:
    """Evaluate P_Fn(k) using the hub-and-pairs factorization."""
    if n < 0 or k < 0:
        raise ValueError("n and k must be nonnegative")
    return k * pow(k - 1, n) * pow(k - 2, n)
