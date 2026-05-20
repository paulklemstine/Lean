def stereo_factor(x_norm: float) -> float:
    """Compute stereographic conformal factor lambda(x) = 2/(1 + ||x||^2)."""
    return 2.0 / (1.0 + x_norm ** 2)

# Example
print(f"lambda(0) = {stereo_factor(0.0)}")    # 2.0
print(f"lambda(1) = {stereo_factor(1.0)}")    # 1.0
print(f"lambda(2) = {stereo_factor(2.0)}")    # 0.4
