def certified_robustness_radius(gap: float, lipschitz_constant: float) -> float:
    """Compute certified robustness radius r* = gamma / (2K).
    Any input x' with ||x' - x||_inf < r* preserves the IRV winner."""
    if lipschitz_constant <= 0:
        return float('inf')
    return gap / (2.0 * lipschitz_constant)