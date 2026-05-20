import math

def packing_bound_s2(r: float) -> tuple:
    """Compute stereographic packing bound for S^2.
    Returns (exact_bound, ceiling_bound)."""
    if r <= 0 or r >= math.pi / 2:
        raise ValueError(f"r must be in (0, pi/2), got {r}")
    c = math.cos(r)
    bound = 8.0 / (c ** 2 * (1.0 - c))
    return bound, math.ceil(bound)

# Calibration against known configurations
for name, r, known in [("pi/6", math.pi/6, 12), ("pi/4", math.pi/4, 6), ("pi/3", math.pi/3, 4)]:
    exact, ceil_val = packing_bound_s2(r)
    print(f"r={name}: bound={exact:.2f}, ceil={ceil_val}, known={known}, ratio={exact/known:.2f}")
