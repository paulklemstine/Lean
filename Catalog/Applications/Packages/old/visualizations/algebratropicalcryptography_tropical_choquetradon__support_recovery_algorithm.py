def recover_support(tests, profile, n):
    """Recover canonical support from profile using test battery."""
    return frozenset(e for e in range(n) if tests(e, profile))