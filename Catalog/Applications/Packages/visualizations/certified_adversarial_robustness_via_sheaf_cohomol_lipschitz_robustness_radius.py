def compute_lipschitz_robustness_radius(margin: float, lipschitz_const: float) -> float:
    if margin <= 0 or lipschitz_const <= 0:
        return 0.0
    return margin / lipschitz_const