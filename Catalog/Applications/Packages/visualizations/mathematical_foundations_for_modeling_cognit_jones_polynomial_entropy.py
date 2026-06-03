def jones_entropy(w: CrossingWord, a: float) -> float:
    """Compute the Jones polynomial entropy at parameter a.

    Uses non-uniform Boltzmann weights: p_σ ∝ |a^{k(σ)}|
    where k(σ) = 2·#A(σ) - n is the Kauffman exponent.

    At a = 1, this reduces to cognitive_entropy (uniform distribution).
    For |a| ≠ 1, the non-uniform weights reduce entropy.

    Time: O(2^n)
    """
    n = num_crossings(w)
    if n == 0:
        return 0.0

    states = enumerate_kauffman_states(n)
    weights = [abs(a ** kauffman_exponent(s)) for s in states]
    total = sum(weights)

    if total == 0:
        return 0.0

    probs = [w_i / total for w_i in weights]
    entropy = -sum(p * math.log(p) if p > 0 else 0 for p in probs)
    return entropy / math.log(2)  # Convert to bits
