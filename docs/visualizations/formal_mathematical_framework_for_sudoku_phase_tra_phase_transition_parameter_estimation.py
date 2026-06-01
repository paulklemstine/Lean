def phase_params(n: int) -> dict:
    return {
        'critical_density': 1 - 1/n**2,
        'interaction_strength': 2*(n+1)/(3*n+1),
        'degree_ratio': (3*n+1)/(2*(n+1)),
        'overlap_fraction': 1/(n+1)
    }