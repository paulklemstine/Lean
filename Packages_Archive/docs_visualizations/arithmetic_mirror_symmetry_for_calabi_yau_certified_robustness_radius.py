def certified_robustness_radius(gamma: float, K: float) -> float:
    """Compute certified robustness radius r* = gamma / (2K).
    
    Args:
        gamma: Elimination gap certificate (minimum gap across all rounds)
        K: Lipschitz constant of the score function (L_inf -> L_inf)
    
    Returns:
        r_star: Maximum L_inf perturbation radius guaranteeing winner preservation
    """
    if K <= 0:
        return float('inf')
    return gamma / (2.0 * K)
