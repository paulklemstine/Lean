def k_fold_tensor_gap(eps: float, k: int) -> float:
    return 1.0 - (1.0 - eps) ** k