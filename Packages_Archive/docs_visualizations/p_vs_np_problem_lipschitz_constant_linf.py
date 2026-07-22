def lipschitz_constant_linf(W: list[list[float]]) -> float:
    """L-infinity Lipschitz constant for linear map s(x) = Wx.
    Equals max_i sum_j |W_ij| (maximum absolute row sum)."""
    return max(sum(abs(w) for w in row) for row in W)