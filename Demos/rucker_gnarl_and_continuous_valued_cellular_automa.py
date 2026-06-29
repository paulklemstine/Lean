"""
Numerical demonstrations for:

    Continuous-Valued Cellular Automata, the Diffusion Threshold,
    and Rucker's "Gnarl".

The symmetric three-point continuous cellular automaton (CA) on bi-infinite
real configurations c : Z -> R is

    step_a(c)(x) = a * c(x-1) + (1 - 2a) * c(x) + a * c(x+1),

with stencil weights (a, 1 - 2a, a) summing to 1. This script verifies, by
direct numerical experiment, the main theorems of the accompanying paper:

  * linearity and translation equivariance of step_a;
  * the geometric-mode spectrum  lambda(a, r) = (1 - 2a) + a (r + 1/r);
  * the constant eigenvalue 1 (r = 1) and Nyquist eigenvalue 1 - 4a (r = -1);
  * (1 - 4a)^n growth of the alternating mode;
  * conservation of total mass for finitely supported configurations;
  * the discrete maximum principle / sup-norm non-expansiveness on [0, 1/2];
  * sharp instability outside [0, 1/2], with threshold a = 1/2.

Pure standard library; no third-party dependencies.
"""

from __future__ import annotations

import math
from typing import Callable, Dict, List

Config = Dict[int, float]  # finitely supported configuration: position -> value


# --------------------------------------------------------------------------
# Core rule
# --------------------------------------------------------------------------
def step(a: float, c: Config) -> Config:
    """One synchronous update of the three-point continuous CA.

    Operates on a finitely supported configuration (dict). The support grows by
    at most one cell on each side (the light cone).
    """
    out: Config = {}
    if not c:
        return out
    lo, hi = min(c), max(c)
    for x in range(lo - 1, hi + 2):
        val = a * c.get(x - 1, 0.0) + (1.0 - 2.0 * a) * c.get(x, 0.0) + a * c.get(x + 1, 0.0)
        if val != 0.0:
            out[x] = val
    return out


def iterate(a: float, n: int, c: Config) -> Config:
    """Apply step_a exactly n times."""
    for _ in range(n):
        c = step(a, c)
    return c


def eigenvalue(a: float, r: float) -> float:
    """Dispersion relation lambda(a, r) = (1 - 2a) + a (r + 1/r)."""
    return (1.0 - 2.0 * a) + a * (r + 1.0 / r)


def spectral_radius(a: float, n_angles: int = 2001) -> float:
    """Max over Fourier modes of |lambda(a, e^{i theta})| = |1 - 2a(1 - cos theta)|."""
    best = 0.0
    for k in range(n_angles):
        theta = math.pi * k / (n_angles - 1)
        lam = 1.0 - 2.0 * a * (1.0 - math.cos(theta))
        best = max(best, abs(lam))
    return best


def is_laminar(a: float) -> bool:
    """Stability classifier: laminar iff 0 <= a <= 1/2 (spectral radius == 1)."""
    return 0.0 <= a <= 0.5


def mass(c: Config) -> float:
    """Total mass (heat content) of a finitely supported configuration."""
    return sum(c.values())


def sup_norm(c: Config) -> float:
    """Sup norm max_x |c(x)|."""
    return max((abs(v) for v in c.values()), default=0.0)


# --------------------------------------------------------------------------
# Sampling abstract configurations onto a finite window (for testing)
# --------------------------------------------------------------------------
def sample(f: Callable[[int], float], lo: int, hi: int) -> Config:
    """Sample a configuration function f on the window [lo, hi]."""
    return {x: f(x) for x in range(lo, hi + 1) if f(x) != 0.0}


def alt(x: int) -> float:
    """Alternating mode (-1)^x."""
    return float((-1) ** x)


def geom(r: float) -> Callable[[int], float]:
    """Geometric mode x |-> r^x."""
    return lambda x: r ** x


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_eigenvalues() -> None:
    print("=" * 70)
    print("Geometric-mode spectrum  lambda(a, r) = (1 - 2a) + a (r + 1/r)")
    print("=" * 70)
    a = 0.3
    for r, name in [(1.0, "constant r=1"), (-1.0, "alternating r=-1"),
                    (2.0, "growing r=2"), (0.5, "decaying r=1/2")]:
        lam = eigenvalue(a, r)
        print(f"  a={a}, {name:18s}: lambda = {lam:+.4f}")
    print(f"  Check eigenvalue(a, 1)   == 1        : {eigenvalue(a, 1.0):+.4f}")
    print(f"  Check eigenvalue(a, -1)  == 1 - 4a   : "
          f"{eigenvalue(a, -1.0):+.4f}  vs  {1 - 4 * a:+.4f}")
    print()


def demo_eigenvector_property() -> None:
    print("=" * 70)
    print("Geometric modes are eigenvectors:  step_a(r^x) = lambda * r^x")
    print("=" * 70)
    a, r = 0.25, 2.0
    c = sample(geom(r), -3, 3)
    stepped = step(a, c)
    lam = eigenvalue(a, r)
    # compare on the interior (light cone padding excluded)
    print(f"  a={a}, r={r}, lambda={lam:.4f}")
    for x in range(-2, 3):
        lhs = stepped.get(x, 0.0)
        rhs = lam * (r ** x)
        print(f"  x={x:+d}: step={lhs:+.5f}  lambda*r^x={rhs:+.5f}  match={abs(lhs-rhs)<1e-9}")
    print()


def demo_alternating_growth() -> None:
    print("=" * 70)
    print("Alternating mode amplitude after n steps is (1 - 4a)^n")
    print("=" * 70)
    for a in [0.1, 0.25, 0.5, 0.6, -0.1]:
        c = sample(alt, -6, 6)
        for n in [1, 3, 5]:
            evolved = iterate(a, n, c)
            amp = evolved.get(0, 0.0)  # value at x=0, where (-1)^0 = 1
            predicted = (1 - 4 * a) ** n
            print(f"  a={a:+.2f} n={n}: amp(x=0)={amp:+.5f}  (1-4a)^n={predicted:+.5f}")
        regime = "LAMINAR (|1-4a|<=1)" if abs(1 - 4 * a) <= 1 else "UNSTABLE (|1-4a|>1)"
        print(f"          -> {regime}\n")


def demo_mass_conservation() -> None:
    print("=" * 70)
    print("Conservation of total mass for finitely supported configurations")
    print("=" * 70)
    c = {-2: 1.0, -1: -3.0, 0: 5.0, 1: 2.0, 3: -4.0}
    m0 = mass(c)
    for a in [0.0, 0.2, 0.5, 0.9, -0.3]:
        evolved = iterate(a, 20, dict(c))
        print(f"  a={a:+.2f}: mass after 20 steps = {mass(evolved):+.6f}  (initial {m0:+.6f})")
    print()


def demo_maximum_principle() -> None:
    print("=" * 70)
    print("Discrete maximum principle / sup-norm non-expansiveness on [0,1/2]")
    print("=" * 70)
    c = {-3: 2.0, -1: -5.0, 0: 7.0, 2: -1.0, 4: 3.0}
    b0 = sup_norm(c)
    print(f"  initial sup-norm = {b0:.4f}")
    for a in [0.0, 0.25, 0.5, 0.65, -0.2]:
        evolved = iterate(a, 30, dict(c))
        b = sup_norm(evolved)
        status = "non-expansive" if b <= b0 + 1e-9 else "GREW (unstable)"
        print(f"  a={a:+.2f}: sup-norm after 30 steps = {b:12.4f}  -> {status}")
    print()


def demo_stability_dichotomy() -> None:
    print("=" * 70)
    print("Stability dichotomy: spectral radius and classifier (threshold a=1/2)")
    print("=" * 70)
    for a in [-0.3, 0.0, 0.1, 0.25, 0.4, 0.5, 0.55, 0.8]:
        sr = spectral_radius(a)
        cls = "laminar " if is_laminar(a) else "unstable"
        print(f"  a={a:+.2f}: spectral_radius={sr:.4f}  classifier={cls}  "
              f"|1-4a|={abs(1-4*a):.4f}")
    print()


def demo_linearity() -> None:
    print("=" * 70)
    print("Linearity: step_a(c + d) = step_a(c) + step_a(d)")
    print("=" * 70)
    a = 0.3
    c = {0: 1.0, 1: 2.0}
    d = {1: -1.0, 2: 4.0}
    cd = {x: c.get(x, 0.0) + d.get(x, 0.0) for x in set(c) | set(d)}
    lhs = step(a, cd)
    sc, sd = step(a, c), step(a, d)
    rhs = {x: sc.get(x, 0.0) + sd.get(x, 0.0) for x in set(sc) | set(sd)}
    ok = all(abs(lhs.get(x, 0.0) - rhs.get(x, 0.0)) < 1e-12 for x in set(lhs) | set(rhs))
    print(f"  a={a}:  step(c+d) == step(c)+step(d) ?  {ok}")
    print()


def main() -> None:
    demo_linearity()
    demo_eigenvalues()
    demo_eigenvector_property()
    demo_alternating_growth()
    demo_mass_conservation()
    demo_maximum_principle()
    demo_stability_dichotomy()


if __name__ == "__main__":
    main()


"""
Dispersion relation and spectral radius versus the diffusion coefficient `a`.

Left panel: the Fourier-band eigenvalues lambda(a, e^{i theta}) = 1 - 2a(1 - cos
theta) for several `a`, showing the band [1 - 4a, 1] and how its lower edge
crosses -1 at a = 1/2. Right panel: the spectral radius
max_theta |lambda(a, e^{i theta})| as a function of `a`, flat at 1 on [0, 1/2]
and rising as |1 - 4a| outside.

Requires: numpy, matplotlib.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def band_eigenvalues(a: float, theta: np.ndarray) -> np.ndarray:
    """lambda(a, e^{i theta}) = 1 - 2a(1 - cos theta)."""
    return 1.0 - 2.0 * a * (1.0 - np.cos(theta))


def spectral_radius(a: float) -> float:
    """max over the Fourier band; equals max(1, |1 - 4a|)."""
    return max(1.0, abs(1.0 - 4.0 * a))


def main() -> None:
    theta = np.linspace(0.0, np.pi, 400)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    for a in [0.1, 0.25, 0.5, 0.65]:
        lam = band_eigenvalues(a, theta)
        ax1.plot(theta, lam, label=f"a = {a}")
    ax1.axhline(1.0, color="gray", ls=":", lw=1)
    ax1.axhline(-1.0, color="gray", ls=":", lw=1)
    ax1.set_xlabel(r"$\theta$ (Fourier mode)")
    ax1.set_ylabel(r"$\lambda(a, e^{i\theta}) = 1 - 2a(1-\cos\theta)$")
    ax1.set_title("Dispersion relation: eigenvalue band")
    ax1.legend()

    a_vals = np.linspace(-0.3, 0.9, 400)
    sr = np.array([spectral_radius(a) for a in a_vals])
    ax2.plot(a_vals, sr, color="crimson", lw=2)
    ax2.axhline(1.0, color="gray", ls=":", lw=1)
    ax2.axvline(0.0, color="green", ls="--", lw=1, label="a = 0")
    ax2.axvline(0.5, color="blue", ls="--", lw=1, label="a = 1/2 (threshold)")
    ax2.fill_betweenx([0.9, sr.max()], 0.0, 0.5, color="green", alpha=0.08)
    ax2.set_xlabel("diffusion coefficient a")
    ax2.set_ylabel("spectral radius")
    ax2.set_title("Spectral radius and the stability dichotomy")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("dispersion.png", dpi=130)
    print("wrote dispersion.png")


if __name__ == "__main__":
    main()


"""
Space-time diagram of the symmetric three-point continuous CA across the phase
transition. For several diffusion coefficients `a`, evolve a localized seed and
render the resulting space-time field, contrasting the laminar regime inside
[0, 1/2] with the explosive instability outside it.

Requires: numpy, matplotlib.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def evolve(a: float, width: int, steps: int, seed: str = "spike") -> np.ndarray:
    """Evolve a configuration of `width` cells (periodic) for `steps` steps.

    Returns a (steps+1, width) array of the space-time field.
    """
    c = np.zeros(width, dtype=float)
    if seed == "spike":
        c[width // 2] = 1.0
    elif seed == "noise":
        rng = np.random.default_rng(0)
        c = rng.standard_normal(width) * 0.01
    field = np.empty((steps + 1, width), dtype=float)
    field[0] = c
    for t in range(steps):
        c = a * np.roll(c, 1) + (1.0 - 2.0 * a) * c + a * np.roll(c, -1)
        field[t + 1] = c
    return field


def main() -> None:
    width, steps = 201, 120
    coeffs = [0.1, 0.25, 0.5, 0.65]  # last one is unstable (> 1/2)
    fig, axes = plt.subplots(1, len(coeffs), figsize=(4 * len(coeffs), 5))
    for ax, a in zip(axes, coeffs):
        # use the noise seed so the alternating mode is excited
        field = evolve(a, width, steps, seed="noise")
        # symmetric color scale clipped for visibility
        vmax = np.percentile(np.abs(field), 99) + 1e-12
        ax.imshow(field, cmap="RdBu_r", vmin=-vmax, vmax=vmax,
                  aspect="auto", interpolation="nearest")
        regime = "laminar" if 0.0 <= a <= 0.5 else "UNSTABLE"
        ax.set_title(f"a = {a}  ({regime})\n|1-4a| = {abs(1 - 4 * a):.2f}")
        ax.set_xlabel("position x")
        ax.set_ylabel("time t (down)")
    fig.suptitle("Continuous CA space-time across the threshold a = 1/2",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("spacetime.png", dpi=130)
    print("wrote spacetime.png")


if __name__ == "__main__":
    main()
