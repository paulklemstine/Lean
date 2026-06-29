"""Numerical demonstrations for "Diffusion Models as Stochastic Differential
Equations: Exact Fokker-Planck Dynamics, Stationarity, and Time Reversal for
the Ornstein-Uhlenbeck Process".

All functions are self-contained (standard library only) and mirror the
formally verified results:

  * ouMean / ouVar               -> OU marginal moments (Definition 1)
  * moment ODEs                  -> ouMean_hasDerivAt, ouVar_hasDerivAt (Lemma 1)
  * long-time limits             -> ouMean_tendsto, ouVar_tendsto (Theorem 1)
  * gaussianDensity (exp-log)    -> gaussianDensity, gaussian_pos (Def 2, Prop 1)
  * spatial/time derivatives     -> hasDerivAt_gaussian_x/_xx/_t (Lemmas 2-4)
  * forward Fokker-Planck PDE    -> ou_fokker_planck (Theorem 2, MAIN RESULT)
  * stationary Fokker-Planck     -> stationary_fokker_planck (Theorem 3)
  * Gaussian score & reversal    -> ou_reverse_fokker_planck (Theorem 4)

Run: python demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------- #
# OU marginal moments (Definition 1) and their ODEs (Lemma 1)
# --------------------------------------------------------------------------- #
def ou_mean(theta: float, m0: float, t: float) -> float:
    """Marginal mean m(t) = m0 * exp(-theta t)."""
    return m0 * math.exp(-theta * t)


def ou_var(theta: float, sigma2: float, v0: float, t: float) -> float:
    """Marginal variance v(t) = v0 e^{-2 theta t} + (sigma2/2theta)(1 - e^{-2 theta t})."""
    decay = math.exp(-2.0 * theta * t)
    v_inf = sigma2 / (2.0 * theta)
    return v0 * decay + v_inf * (1.0 - decay)


def numerical_derivative(f: Callable[[float], float], x: float, h: float = 1e-6) -> float:
    """Central finite difference approximation to f'(x)."""
    return (f(x + h) - f(x - h)) / (2.0 * h)


def second_derivative(f: Callable[[float], float], x: float, h: float = 1e-4) -> float:
    """Central finite difference approximation to f''(x)."""
    return (f(x + h) - 2.0 * f(x) + f(x - h)) / (h * h)


# --------------------------------------------------------------------------- #
# Gaussian density in exp-log form (Definition 2)
# --------------------------------------------------------------------------- #
def gaussian_density(m: float, v: float, x: float) -> float:
    """Exp-log Gaussian N(m, v): exp(-log(2 pi v)/2 - (x-m)^2/(2v)).

    Always strictly positive (Proposition 1, gaussian_pos)."""
    return math.exp(-math.log(2.0 * math.pi * v) / 2.0 - (x - m) ** 2 / (2.0 * v))


def gaussian_density_std(m: float, v: float, x: float) -> float:
    """Standard normalized Gaussian (Proposition 2, gaussianDensity_eq_sqrt)."""
    return (1.0 / math.sqrt(2.0 * math.pi * v)) * math.exp(-(x - m) ** 2 / (2.0 * v))


def ou_density(theta: float, sigma2: float, m0: float, v0: float, x: float, t: float) -> float:
    """OU marginal density p(x, t) = N(m(t), v(t))(x) (Definition 3)."""
    return gaussian_density(ou_mean(theta, m0, t), ou_var(theta, sigma2, v0, t), x)


# --------------------------------------------------------------------------- #
# Closed-form derivatives (Lemmas 2-4)
# --------------------------------------------------------------------------- #
def gaussian_dx(m: float, v: float, x: float) -> float:
    """dp/dx = p * (-(x-m)/v) (Lemma 2)."""
    return gaussian_density(m, v, x) * (-(x - m) / v)


def gaussian_dxx(m: float, v: float, x: float) -> float:
    """d^2 p/dx^2 = p * ((x-m)^2 - v) / v^2 (Lemma 3)."""
    return gaussian_density(m, v, x) * ((x - m) ** 2 - v) / v ** 2


# --------------------------------------------------------------------------- #
# Demo 1: OU moment ODEs and convergence to the stationary law
# --------------------------------------------------------------------------- #
def demo_moment_odes_and_limits() -> None:
    print("=" * 72)
    print("DEMO 1  Moment ODEs (Lemma 1) and convergence (Theorem 1)")
    print("=" * 72)
    theta, sigma2, m0, v0 = 1.3, 2.0, 4.0, 0.25
    v_inf = sigma2 / (2.0 * theta)
    print(f"  theta={theta}, sigma2={sigma2}, m0={m0}, v0={v0}")
    print(f"  stationary variance v_inf = sigma2/(2 theta) = {v_inf:.6f}\n")
    print(f"  {'t':>5} {'m(t)':>12} {'m'' vs -th*m':>16} {'v(t)':>12} {'v'' vs ODE':>16}")
    for t in [0.0, 0.5, 1.0, 2.0, 4.0, 8.0]:
        m = ou_mean(theta, m0, t)
        v = ou_var(theta, sigma2, v0, t)
        # ODE residuals: m' = -theta m ; v' = -2 theta v + sigma2
        mprime = numerical_derivative(lambda s: ou_mean(theta, m0, s), t)
        vprime = numerical_derivative(lambda s: ou_var(theta, sigma2, v0, s), t)
        m_res = abs(mprime - (-theta * m))
        v_res = abs(vprime - (-2.0 * theta * v + sigma2))
        print(f"  {t:>5.1f} {m:>12.6f} {m_res:>16.2e} {v:>12.6f} {v_res:>16.2e}")
    print(f"\n  As t grows: m(t) -> 0 and v(t) -> {v_inf:.6f}  (ouMean_tendsto/ouVar_tendsto)\n")


# --------------------------------------------------------------------------- #
# Demo 2: MAIN THEOREM -- forward Fokker-Planck residual is zero
# --------------------------------------------------------------------------- #
def fokker_planck_residual(
    theta: float, sigma2: float, m0: float, v0: float, x: float, t: float
) -> Tuple[float, float, float, float]:
    """Return (dp/dt, drift term, diffusion term, residual) for the OU FP PDE
    d_t p = theta d_x(x p) + (sigma2/2) d_xx p  (Theorem 2, ou_fokker_planck).

    dp/dt and d_x(x p) are taken by finite differences; d_xx p uses the
    verified closed form (Lemma 3) for accuracy."""
    p_t = numerical_derivative(lambda s: ou_density(theta, sigma2, m0, v0, x, s), t)
    drift = theta * numerical_derivative(
        lambda y: y * ou_density(theta, sigma2, m0, v0, y, t), x
    )
    m, v = ou_mean(theta, m0, t), ou_var(theta, sigma2, v0, t)
    diffusion = (sigma2 / 2.0) * gaussian_dxx(m, v, x)
    residual = p_t - drift - diffusion
    return p_t, drift, diffusion, residual


def demo_fokker_planck_main() -> None:
    print("=" * 72)
    print("DEMO 2  MAIN THEOREM ou_fokker_planck:  d_t p = th d_x(x p) + (s2/2) d_xx p")
    print("=" * 72)
    theta, sigma2, m0, v0 = 0.8, 1.5, 2.0, 0.5
    print(f"  theta={theta}, sigma2={sigma2}, m0={m0}, v0={v0}\n")
    print(f"  {'x':>6} {'t':>5} {'d_t p':>12} {'drift+diff':>12} {'|residual|':>12}")
    max_res = 0.0
    for x in [-2.0, -0.5, 0.7, 1.5, 3.0]:
        for t in [0.3, 1.0, 2.5]:
            p_t, drift, diff, res = fokker_planck_residual(theta, sigma2, m0, v0, x, t)
            max_res = max(max_res, abs(res))
            print(f"  {x:>6.1f} {t:>5.1f} {p_t:>12.6f} {drift + diff:>12.6f} {abs(res):>12.2e}")
    print(f"\n  Max |residual| over the grid: {max_res:.2e}  (theory: exactly 0)\n")


# --------------------------------------------------------------------------- #
# Demo 3: stationary Fokker-Planck (Theorem 3) -- L p_inf = 0
# --------------------------------------------------------------------------- #
def demo_stationary() -> None:
    print("=" * 72)
    print("DEMO 3  stationary_fokker_planck:  L p_inf = 0 for N(0, sigma2/2theta)")
    print("=" * 72)
    theta, sigma2 = 1.1, 3.0
    v_inf = sigma2 / (2.0 * theta)
    print(f"  theta={theta}, sigma2={sigma2}, v_inf = {v_inf:.6f}\n")
    print(f"  {'x':>6} {'theta d_x(x p)':>16} {'(s2/2) d_xx p':>16} {'|L p_inf|':>12}")
    max_res = 0.0
    for x in [-3.0, -1.0, 0.0, 1.5, 2.5]:
        drift = theta * numerical_derivative(
            lambda y: y * gaussian_density(0.0, v_inf, y), x
        )
        diffusion = (sigma2 / 2.0) * gaussian_dxx(0.0, v_inf, x)
        res = drift + diffusion
        max_res = max(max_res, abs(res))
        print(f"  {x:>6.1f} {drift:>16.6f} {diffusion:>16.6f} {abs(res):>12.2e}")
    print(f"\n  Max |L p_inf| over the grid: {max_res:.2e}  (theory: exactly 0)\n")


# --------------------------------------------------------------------------- #
# Demo 4: Gaussian score and reverse-time sampling (Theorem 4)
# --------------------------------------------------------------------------- #
def gaussian_score(m: float, v: float, x: float) -> float:
    """Score d_x log p = -(x-m)/v (Lemma 5)."""
    return -(x - m) / v


def reverse_time_sampler(
    theta: float,
    sigma2: float,
    m0: float,
    v0: float,
    T: float,
    n_steps: int,
    n_samples: int,
    seed: int = 0,
) -> Tuple[float, float]:
    """Euler-Maruyama for the reverse SDE dY = b(Y,t) dt + sigma d(bar W),
    with reverse drift b = theta x + sigma2 * score(x, t) (Theorem 4).

    Integrate s in [0, T] with physical time t = T - s, starting Y ~ p_inf,
    and return the empirical (mean, variance) of the terminal samples, which
    should match (m0, v0) -- exact data recovery."""
    rng = random.Random(seed)
    sigma = math.sqrt(sigma2)
    dt = T / n_steps
    v_inf = sigma2 / (2.0 * theta)
    ys: List[float] = [rng.gauss(0.0, math.sqrt(v_inf)) for _ in range(n_samples)]
    for k in range(n_steps):
        s = k * dt
        t = T - s  # physical (forward) time
        m_t = ou_mean(theta, m0, t)
        v_t = ou_var(theta, sigma2, v0, t)
        new_ys: List[float] = []
        for y in ys:
            b = theta * y + sigma2 * gaussian_score(m_t, v_t, y)
            y_next = y + b * dt + sigma * math.sqrt(dt) * rng.gauss(0.0, 1.0)
            new_ys.append(y_next)
        ys = new_ys
    n = len(ys)
    mean = sum(ys) / n
    var = sum((y - mean) ** 2 for y in ys) / (n - 1)
    return mean, var


def demo_reverse_time() -> None:
    print("=" * 72)
    print("DEMO 4  ou_reverse_fokker_planck:  reverse SDE recovers the data law")
    print("=" * 72)
    theta, sigma2, m0, v0 = 1.0, 2.0, 3.0, 0.4
    T = 6.0
    print(f"  Forward: theta={theta}, sigma2={sigma2}; data N(m0={m0}, v0={v0})")
    print(f"  Start reverse run from stationary N(0, {sigma2/(2*theta):.4f}) at t=T={T}\n")
    mean, var = reverse_time_sampler(
        theta, sigma2, m0, v0, T, n_steps=1500, n_samples=4000, seed=42
    )
    print(f"  Recovered empirical mean     = {mean:8.4f}   (target m0 = {m0})")
    print(f"  Recovered empirical variance = {var:8.4f}   (target v0 = {v0})")
    print("  Reverse-time integration reconstructs the data distribution.\n")


# --------------------------------------------------------------------------- #
# Demo 5: exp-log vs standard Gaussian (Proposition 2)
# --------------------------------------------------------------------------- #
def demo_density_equivalence() -> None:
    print("=" * 72)
    print("DEMO 5  gaussianDensity_eq_sqrt: exp-log form == standard Gaussian")
    print("=" * 72)
    m, v = 1.2, 0.7
    print(f"  m={m}, v={v}\n")
    print(f"  {'x':>6} {'exp-log p':>14} {'standard p':>14} {'|diff|':>12} {'p > 0':>7}")
    for x in [-2.0, 0.0, 1.2, 3.0]:
        a = gaussian_density(m, v, x)
        b = gaussian_density_std(m, v, x)
        print(f"  {x:>6.1f} {a:>14.8f} {b:>14.8f} {abs(a - b):>12.2e} {str(a > 0):>7}")
    print()


def main() -> None:
    demo_moment_odes_and_limits()
    demo_fokker_planck_main()
    demo_stationary()
    demo_reverse_time()
    demo_density_equivalence()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


"""Visualization for the OU diffusion / Fokker-Planck package.

Produces a two-panel figure:
  (left)  the OU marginal density p(x, t) = N(m(t), v(t)) at several times,
          collapsing from the data Gaussian toward the stationary N(0, sigma2/2theta);
  (right) the moments m(t), v(t) with the stationary variance v_inf marked,
          illustrating ouMean_tendsto / ouVar_tendsto.

Run: python visualize.py   (saves ou_diffusion.png)
"""

from __future__ import annotations

import math
from typing import List

import numpy as np
import matplotlib.pyplot as plt


def ou_mean(theta: float, m0: float, t: float) -> float:
    return m0 * math.exp(-theta * t)


def ou_var(theta: float, sigma2: float, v0: float, t: float) -> float:
    decay = math.exp(-2.0 * theta * t)
    v_inf = sigma2 / (2.0 * theta)
    return v0 * decay + v_inf * (1.0 - decay)


def gaussian_density(m: float, v: float, x: np.ndarray) -> np.ndarray:
    return np.exp(-np.log(2.0 * np.pi * v) / 2.0 - (x - m) ** 2 / (2.0 * v))


def main() -> None:
    theta, sigma2, m0, v0 = 1.0, 2.0, 4.0, 0.2
    v_inf = sigma2 / (2.0 * theta)
    xs = np.linspace(-6.0, 8.0, 600)
    times: List[float] = [0.0, 0.25, 0.6, 1.2, 3.0]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    cmap = plt.get_cmap("viridis")
    for i, t in enumerate(times):
        m = ou_mean(theta, m0, t)
        v = ou_var(theta, sigma2, v0, t)
        ax1.plot(xs, gaussian_density(m, v, xs), color=cmap(i / max(1, len(times) - 1)),
                 label=f"t = {t:.2f}")
    ax1.plot(xs, gaussian_density(0.0, v_inf, xs), "k--", lw=2,
             label=r"stationary $N(0,\sigma^2/2\theta)$")
    ax1.set_title("OU marginal density collapsing to the stationary law")
    ax1.set_xlabel("x")
    ax1.set_ylabel("p(x, t)")
    ax1.legend()

    ts = np.linspace(0.0, 5.0, 300)
    ms = [ou_mean(theta, m0, t) for t in ts]
    vs = [ou_var(theta, sigma2, v0, t) for t in ts]
    ax2.plot(ts, ms, label=r"$m(t) = m_0 e^{-\theta t}$")
    ax2.plot(ts, vs, label=r"$v(t)$")
    ax2.axhline(v_inf, color="k", ls="--", label=r"$v_\infty = \sigma^2/2\theta$")
    ax2.axhline(0.0, color="gray", ls=":")
    ax2.set_title("Moments relax exponentially to the fixed point")
    ax2.set_xlabel("t")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("ou_diffusion.png", dpi=150)
    print("Saved ou_diffusion.png")


if __name__ == "__main__":
    main()
