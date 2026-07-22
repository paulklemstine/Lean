from __future__ import annotations

def weights(epsilon: float) -> tuple[float, float]:
    if epsilon < 0:
        raise ValueError("epsilon must be nonnegative")
    denominator = 1.0 + epsilon * epsilon
    return 1.0 / denominator, epsilon * epsilon / denominator

for e in (1.0, .1, .01, .001, .0001):
    w0, w1 = weights(e)
    print(f"epsilon={e:g}: ({w0:.12g}, {w1:.12g}), sum={w0+w1:.12g}")
