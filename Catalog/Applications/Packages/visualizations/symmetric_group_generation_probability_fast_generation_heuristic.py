def fast_generation_test(sigma, tau, n):
    """O(n) heuristic for generation test."""
    from algorithms import is_transitive, perm_sign
    if not is_transitive([sigma, tau], n):
        return "NOT_TRANSITIVE"
    if perm_sign(sigma) == 1 and perm_sign(tau) == 1:
        return "BOTH_EVEN"
    return "LIKELY_GENERATES"