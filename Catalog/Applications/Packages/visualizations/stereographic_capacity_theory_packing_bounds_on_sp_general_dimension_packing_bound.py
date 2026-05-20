import math

def packing_bound_general(n: int, r: float) -> tuple:
    """General stereographic packing bound for S^n."""
    c = math.cos(r)
    distortion = (2.0 / c) ** n
    sphere_vol = 2.0 * math.pi ** ((n + 1) / 2.0) / math.gamma((n + 1) / 2.0)
    omega = 2.0 * math.pi ** (n / 2.0) / math.gamma(n / 2.0)
    # Numerical integration
    steps = 10000
    dt = r / steps
    integral = sum(math.sin((i + 0.5) * dt) ** (n - 1) * dt for i in range(steps))
    cap_vol = omega * integral
    bound = distortion * sphere_vol / cap_vol
    return bound, math.ceil(bound)

for n in [2, 3, 4, 5]:
    exact, ceil_val = packing_bound_general(n, math.pi / 6)
    print(f"S^{n}, r=pi/6: bound={exact:.2f}, ceil={ceil_val}")
