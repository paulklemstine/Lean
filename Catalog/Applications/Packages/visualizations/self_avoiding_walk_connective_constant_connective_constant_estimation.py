def estimate_mu(max_n: int = 16) -> float:
    counts = []
    for k in range(max_n + 1):
        counts.append(count_saws(k))
    return counts[-1] ** (1.0 / max_n)