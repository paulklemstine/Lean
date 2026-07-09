from typing import Sequence, Callable
import cmath, math

def stereographic_projection(p: Sequence[float]) -> list[float]:
    """Map p on S^n (minus north pole) to R^n: phi(u, t) = u / (1 - t)."""
    t = p[-1]
    return [ui / (1.0 - t) for ui in p[:-1]]

def stereographic_fourier_transform(
    f: Callable[[Sequence[float]], float],
    sphere_points: Sequence[Sequence[float]],
    quad_weights: Sequence[float],
    k: Sequence[float],
    n: int = 2,
) -> complex:
    """Discrete stereographic Fourier transform at frequency k.

    F[f](k) = sum_i f(x_i) (1+|phi(x_i)|^2)^{-n/2}
                     exp(-2 pi i phi(x_i) . k) w_i.
    """
    total = 0j
    for p, w in zip(sphere_points, quad_weights):
        t = stereographic_projection(p)
        r2 = sum(ti * ti for ti in t)
        weight = (1.0 + r2) ** (-n / 2.0)
        phase = -2.0 * math.pi * sum(ti * ki for ti, ki in zip(t, k))
        total += f(p) * weight * cmath.exp(1j * phase) * w
    return total
