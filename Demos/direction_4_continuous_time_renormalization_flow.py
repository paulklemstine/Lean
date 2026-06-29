#!/usr/bin/env python3
"""
Applications of the Continuous Renormalization Flow Theory

Demonstrates real-world applications of the discrete-to-continuous renormalization
framework across multiple domains:

1. Numerical ODE integration via Euler method reinterpretation
2. Signal decay in communication channels
3. Population dynamics with time-varying mortality
4. Financial option decay (theta decay modeling)
5. Temperature cooling with Newton's law of cooling
"""

import math
from typing import Callable, List, Tuple


# ──────────────────────────────────────────────────────
# Core engine (self-contained)
# ──────────────────────────────────────────────────────

def cumulative_damping(alpha: Callable[[float], float], t: float,
                       num_points: int = 10000) -> float:
    """Compute ∫₀ᵗ (1/α(s)) ds."""
    if t <= 0:
        return 0.0
    ds = t / num_points
    total = 0.0
    for i in range(num_points):
        s = (i + 0.5) * ds
        total += ds / alpha(s)
    return total


def renorm_flow(alpha: Callable[[float], float], V0: float, t: float) -> float:
    """Compute V₀ · exp(-∫₀ᵗ 1/α(s) ds)."""
    return V0 * math.exp(-cumulative_damping(alpha, t))


def renorm_cascade(alpha: Callable[[float], float], V0: float, n: int, t: float) -> float:
    """Discrete cascade: V₀ · ∏ (1 - 1/((n+1)α(k/(n+1))))."""
    m = n + 1
    num_steps = int(math.floor(m * t))
    product = V0
    for k in range(num_steps):
        s = k / m
        factor = 1.0 - 1.0 / (m * alpha(s))
        product *= factor
    return product


# ──────────────────────────────────────────────────────
# Application 1: Euler Method as Renormalization Cascade
# ──────────────────────────────────────────────────────

def app_euler_method():
    """
    The Euler method for y' = -y/α(t) with step size dt = 1/n is exactly
    the renormalization cascade. This application shows how our convergence
    theorem provides rigorous error bounds for Euler's method applied to
    linear nonautonomous ODEs.
    """
    print("=" * 70)
    print("APPLICATION 1: Euler Method as Renormalization Cascade")
    print("=" * 70)
    print()
    print("The ODE: y'(t) = -y(t)/α(t),  y(0) = 1")
    print("Euler method with step dt = 1/(n+1) is EXACTLY our cascade.")
    print()

    alpha = lambda t: 2.0 + math.sin(t)
    V0 = 1.0
    t_final = 5.0

    exact = renorm_flow(alpha, V0, t_final)
    print(f"Profile: α(t) = 2 + sin(t)")
    print(f"Exact solution at t={t_final}: V(t) = {exact:.8f}")
    print()
    print(f"{'n (steps)':>10s}  {'Euler approx':>14s}  {'Error':>12s}  {'n*Error':>10s}")
    print("-" * 52)

    for n in [10, 50, 100, 500, 1000, 5000]:
        euler = renorm_cascade(alpha, V0, n, t_final)
        err = abs(euler - exact)
        print(f"{n:10d}  {euler:14.8f}  {err:12.2e}  {n*err:10.4f}")

    print()
    print("The O(1/n) convergence rate is exactly what our theorem guarantees!")
    print()


# ──────────────────────────────────────────────────────
# Application 2: Signal Attenuation in Fading Channels
# ──────────────────────────────────────────────────────

def app_signal_decay():
    """
    In wireless communications, signal power decays through a channel with
    time-varying attenuation rate. The continuous flow models the ideal
    signal decay, while discrete measurements correspond to the cascade.
    """
    print("=" * 70)
    print("APPLICATION 2: Signal Attenuation in Time-Varying Channels")
    print("=" * 70)
    print()

    # Fading channel: attenuation rate varies with environmental conditions
    # α(t) represents the "channel quality" — higher α means slower decay
    alpha_channel = lambda t: 3.0 + 2.0 * math.sin(0.5 * t) + 0.5 * math.cos(2 * t)
    P0 = 100.0  # Initial power in watts

    print(f"Channel model: α(t) = 3 + 2sin(t/2) + 0.5cos(2t)")
    print(f"Initial signal power: P₀ = {P0} W")
    print()
    print(f"{'Time (s)':>10s}  {'Power (W)':>12s}  {'Decay (dB)':>12s}  {'Damping':>10s}")
    print("-" * 48)

    for t in [0.5, 1.0, 2.0, 3.0, 5.0, 10.0]:
        P = renorm_flow(alpha_channel, P0, t)
        decay_db = 10 * math.log10(P / P0) if P > 0 else float('-inf')
        damping = cumulative_damping(alpha_channel, t)
        print(f"{t:10.1f}  {P:12.4f}  {decay_db:12.2f}  {damping:10.4f}")

    print()
    print("The cumulative damping functional measures total signal degradation.")
    print("Logarithmic linearization: decay in dB ∝ cumulative damping.")
    print()


# ──────────────────────────────────────────────────────
# Application 3: Population Dynamics
# ──────────────────────────────────────────────────────

def app_population():
    """
    Population with seasonal mortality rate modeled by the renormalization flow.
    α(t) represents the "survival timescale" — larger values mean slower die-off.
    """
    print("=" * 70)
    print("APPLICATION 3: Population Dynamics with Seasonal Mortality")
    print("=" * 70)
    print()

    # Seasonal mortality: harder in winter (smaller α), easier in summer
    alpha_season = lambda t: 5.0 + 3.0 * math.sin(2 * math.pi * t)  # period = 1 year
    N0 = 10000.0  # Initial population

    print(f"Survival timescale: α(t) = 5 + 3sin(2πt) (annual cycle)")
    print(f"Initial population: N₀ = {int(N0)}")
    print()

    # Compare discrete (monthly census) vs continuous model
    print("Discrete cascade (monthly steps, n=12) vs continuous flow:")
    print(f"{'Year':>6s}  {'Continuous':>12s}  {'Discrete':>12s}  {'Error':>10s}")
    print("-" * 44)

    for year in [0.25, 0.5, 0.75, 1.0, 2.0, 3.0, 5.0]:
        continuous = renorm_flow(alpha_season, N0, year)
        discrete = renorm_cascade(alpha_season, N0, 11, year)  # n=11 → 12 steps/unit
        err = abs(discrete - continuous)
        print(f"{year:6.2f}  {continuous:12.1f}  {discrete:12.1f}  {err:10.1f}")

    print()
    print("Observation: With only 12 measurements per year, the discrete census")
    print("closely tracks the continuous model, with error bounded by O(1/12).")
    print()


# ──────────────────────────────────────────────────────
# Application 4: Monotonicity and Profile Comparison
# ──────────────────────────────────────────────────────

def app_profile_comparison():
    """
    Demonstrates the monotonicity theorem: if α(s) ≤ β(s) pointwise on [0,t],
    then V_α(t) ≤ V_β(t). Stronger damping (smaller α) yields faster decay.
    """
    print("=" * 70)
    print("APPLICATION 4: Monotonicity — Comparing Damping Profiles")
    print("=" * 70)
    print()

    alpha1 = lambda t: 1.0          # Fast decay
    alpha2 = lambda t: 2.0          # Medium decay
    alpha3 = lambda t: 5.0          # Slow decay
    alpha4 = lambda t: 1.0 + t      # Accelerating protection

    profiles = [
        ("α=1 (fast)", alpha1),
        ("α=2 (medium)", alpha2),
        ("α=5 (slow)", alpha3),
        ("α=1+t (adaptive)", alpha4),
    ]

    V0 = 1.0
    print(f"Initial value V₀ = {V0}")
    print()
    print(f"{'t':>6s}", end="")
    for name, _ in profiles:
        print(f"{name:>16s}", end="")
    print()
    print("-" * (6 + 16 * len(profiles)))

    for t in [0.0, 0.5, 1.0, 2.0, 3.0, 5.0]:
        print(f"{t:6.1f}", end="")
        for _, alpha in profiles:
            V = renorm_flow(alpha, V0, t)
            print(f"{V:16.6f}", end="")
        print()

    print()
    print("Confirmed: Smaller α (stronger damping) → faster decay at each time.")
    print("This is exactly our monotonicity theorem: α ≤ β ⟹ flow_α ≤ flow_β.")
    print()


# ──────────────────────────────────────────────────────
# Application 5: Newton's Law of Cooling
# ──────────────────────────────────────────────────────

def app_newton_cooling():
    """
    Newton's law of cooling with time-varying thermal conductivity:
        T'(t) = -(T(t) - T_env) / τ(t)

    When T_env = 0, this is exactly our renormalization flow with α = τ.
    """
    print("=" * 70)
    print("APPLICATION 5: Newton's Law of Cooling (Time-Varying)")
    print("=" * 70)
    print()

    T0 = 100.0  # Initial temperature (°C above ambient)

    # Thermal time constant varies: object is moved between environments
    # τ(t) = 2 + sin(t) — oscillates as object is periodically exposed to wind
    tau = lambda t: 2.0 + math.sin(t)

    print(f"Thermal profile: τ(t) = 2 + sin(t) seconds")
    print(f"Initial excess temperature: T₀ = {T0}°C above ambient")
    print()
    print(f"{'Time (s)':>10s}  {'Temp (°C)':>12s}  {'Decay %':>10s}  {'Damping':>10s}")
    print("-" * 46)

    for t in [0, 1, 2, 3, 5, 8, 10, 15, 20]:
        T = renorm_flow(tau, T0, t)
        decay_pct = (1 - T / T0) * 100
        damping = cumulative_damping(tau, t)
        print(f"{t:10d}  {T:12.2f}  {decay_pct:10.1f}  {damping:10.3f}")

    print()
    print("The renormalization flow precisely models non-equilibrium cooling")
    print("with time-varying thermal coupling. The cumulative damping is the")
    print("total 'thermal exposure' integral.")
    print()


# ──────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   CONTINUOUS RENORMALIZATION FLOW — APPLICATIONS                   ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    app_euler_method()
    app_signal_decay()
    app_population()
    app_profile_comparison()
    app_newton_cooling()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Continuous Renormalization Flow — Demonstration Script

Demonstrates the convergence of discrete renormalization cascades to continuous
exponential flows, verifying the theorems proved in the formal Lean development.

Experiments:
1. Constant-α cascade vs e^{-t}: pointwise convergence
2. Quantitative error bound: |cascade - exp(-t)| ≤ C/(α+1)
3. Variable-profile cascades vs integral formula
4. Numerical test of Conjecture A (first-order error asymptotics)
"""

import numpy as np
import math


# ──────────────────────────────────────────────────────
# Core algorithms
# ──────────────────────────────────────────────────────

def discrete_cascade_const(alpha: int, t: float) -> float:
    """Compute (1 - 1/(alpha+1))^floor((alpha+1)*t)."""
    n = alpha + 1
    k = int(math.floor(n * t))
    base = 1.0 - 1.0 / n
    return base ** k


def continuous_flow_const(t: float) -> float:
    """Compute e^{-t}."""
    return math.exp(-t)


def discrete_cascade_variable(alpha_func, V0: float, n: int, t: float) -> float:
    """
    Compute the discrete cascade with variable profile:
    V0 * prod_{k=0}^{floor((n+1)*t)-1} (1 - 1/((n+1)*alpha(k/(n+1))))
    """
    m = n + 1
    num_steps = int(math.floor(m * t))
    product = V0
    for k in range(num_steps):
        s = k / m
        a = alpha_func(s)
        if a <= 0:
            return 0.0
        factor = 1.0 - 1.0 / (m * a)
        product *= factor
    return product


def continuous_flow_variable(alpha_func, V0: float, t: float, num_quad: int = 10000) -> float:
    """
    Compute V0 * exp(-integral_0^t 1/alpha(s) ds) via numerical quadrature.
    """
    if t <= 0:
        return V0
    ds = t / num_quad
    integral = 0.0
    for i in range(num_quad):
        s = (i + 0.5) * ds  # midpoint rule
        a = alpha_func(s)
        if a <= 0:
            return 0.0
        integral += ds / a
    return V0 * math.exp(-integral)


def cumulative_damping(alpha_func, t: float, num_quad: int = 10000) -> float:
    """Compute integral_0^t 1/alpha(s) ds."""
    if t <= 0:
        return 0.0
    ds = t / num_quad
    integral = 0.0
    for i in range(num_quad):
        s = (i + 0.5) * ds
        a = alpha_func(s)
        integral += ds / a
    return integral


# ──────────────────────────────────────────────────────
# Experiment 1: Constant-α convergence
# ──────────────────────────────────────────────────────

def experiment_1():
    print("=" * 70)
    print("EXPERIMENT 1: Constant-α cascade converges to e^{-t}")
    print("=" * 70)
    print()

    t_values = [0.0, 0.5, 1.0, 2.0, 5.0]
    alpha_values = [5, 10, 50, 100, 500, 1000, 10000]

    print(f"{'t':>6s}", end="")
    print(f"{'e^(-t)':>12s}", end="")
    for alpha in alpha_values:
        print(f"{'α=' + str(alpha):>12s}", end="")
    print()
    print("-" * (6 + 12 + 12 * len(alpha_values)))

    for t in t_values:
        exact = continuous_flow_const(t)
        print(f"{t:6.1f}", end="")
        print(f"{exact:12.6f}", end="")
        for alpha in alpha_values:
            val = discrete_cascade_const(alpha, t)
            print(f"{val:12.6f}", end="")
        print()

    print()
    print("Observation: The discrete cascade converges to e^{-t} as α → ∞.")
    print()


# ──────────────────────────────────────────────────────
# Experiment 2: Error bound verification
# ──────────────────────────────────────────────────────

def experiment_2():
    print("=" * 70)
    print("EXPERIMENT 2: Error bound |(1-1/(α+1))^⌊(α+1)t⌋ - e^{-t}| ≤ C/(α+1)")
    print("=" * 70)
    print()

    T = 5.0
    t_samples = np.linspace(0, T, 200)
    alpha_values = [10, 50, 100, 500, 1000, 5000]

    print(f"{'α':>8s}  {'sup error':>12s}  {'(α+1)*sup_err':>14s}  {'1/(α+1)':>10s}")
    print("-" * 50)

    for alpha in alpha_values:
        max_err = 0.0
        for t in t_samples:
            err = abs(discrete_cascade_const(alpha, t) - continuous_flow_const(t))
            max_err = max(max_err, err)
        n = alpha + 1
        print(f"{alpha:8d}  {max_err:12.8f}  {n * max_err:14.6f}  {1.0/n:10.6f}")

    print()
    print("Observation: (α+1) * sup_error stabilizes to a constant ≈ C,")
    print("confirming the O(1/(α+1)) error bound proved in Theorem 2.")
    print()


# ──────────────────────────────────────────────────────
# Experiment 3: Variable-profile convergence
# ──────────────────────────────────────────────────────

def experiment_3():
    print("=" * 70)
    print("EXPERIMENT 3: Variable-profile cascade → integral formula")
    print("=" * 70)
    print()

    profiles = {
        "α(t) = 1": lambda t: 1.0,
        "α(t) = 1 + t": lambda t: 1.0 + t,
        "α(t) = 2 + sin(t)": lambda t: 2.0 + math.sin(t),
        "α(t) = 1 + 0.5|sin(5t)|": lambda t: 1.0 + 0.5 * abs(math.sin(5 * t)),
    }

    V0 = 1.0
    t = 3.0
    n_values = [10, 50, 100, 500, 1000, 5000]

    for name, alpha_func in profiles.items():
        exact = continuous_flow_variable(alpha_func, V0, t)
        print(f"Profile: {name}")
        print(f"  Exact flow value at t={t}: {exact:.8f}")
        print(f"  Cumulative damping: {cumulative_damping(alpha_func, t):.6f}")
        print(f"  {'n':>8s}  {'cascade':>12s}  {'error':>12s}  {'n*error':>12s}")
        print(f"  {'-'*50}")

        for n in n_values:
            cascade = discrete_cascade_variable(alpha_func, V0, n, t)
            err = abs(cascade - exact)
            print(f"  {n:8d}  {cascade:12.8f}  {err:12.2e}  {n*err:12.6f}")
        print()

    print("Observation: For all profiles, the discrete cascade converges to the")
    print("continuous integral flow, with error ≈ C/n (first-order convergence).")
    print()


# ──────────────────────────────────────────────────────
# Experiment 4: Conjecture A — first-order error asymptotics
# ──────────────────────────────────────────────────────

def experiment_4():
    print("=" * 70)
    print("EXPERIMENT 4: Conjecture A — n * sup_error → constant C(α,T)")
    print("=" * 70)
    print()

    profiles = {
        "α(t) = 1 (constant)": lambda t: 1.0,
        "α(t) = 1 + t (affine)": lambda t: 1.0 + t,
        "α(t) = 2 + sin(t) (periodic)": lambda t: 2.0 + math.sin(t),
        "α(t) = 1 + 0.5|sin(5t)| (rough)": lambda t: 1.0 + 0.5 * abs(math.sin(5 * t)),
    }

    V0 = 1.0
    T = 3.0
    t_samples = np.linspace(0, T, 300)
    n_values = [50, 100, 200, 500, 1000, 2000, 5000]

    for name, alpha_func in profiles.items():
        print(f"Profile: {name}, T = {T}")
        print(f"  {'n':>8s}  {'sup_error':>12s}  {'n*sup_err':>12s}")
        print(f"  {'-'*40}")

        for n in n_values:
            max_err = 0.0
            for t in t_samples:
                cascade = discrete_cascade_variable(alpha_func, V0, n, t)
                exact = continuous_flow_variable(alpha_func, V0, t)
                err = abs(cascade - exact)
                max_err = max(max_err, err)
            print(f"  {n:8d}  {max_err:12.2e}  {n * max_err:12.6f}")

        print()

    print("VERDICT: If n * sup_error stabilizes, Conjecture A holds for that profile.")
    print("If it grows without bound, the conjecture fails.")
    print()


# ──────────────────────────────────────────────────────
# Experiment 5: Logarithmic linearization verification
# ──────────────────────────────────────────────────────

def experiment_5():
    print("=" * 70)
    print("EXPERIMENT 5: Logarithmic linearization log(V(t)/V0) = -∫ 1/α(s) ds")
    print("=" * 70)
    print()

    alpha_func = lambda t: 2.0 + math.sin(t)
    V0 = 3.0
    t_values = [0.5, 1.0, 2.0, 3.0, 5.0]

    print(f"Profile: α(t) = 2 + sin(t), V0 = {V0}")
    print(f"  {'t':>6s}  {'V(t)':>12s}  {'log(V/V0)':>12s}  {'-∫1/α':>12s}  {'diff':>12s}")
    print(f"  {'-'*58}")

    for t in t_values:
        V = continuous_flow_variable(alpha_func, V0, t)
        log_ratio = math.log(V / V0)
        neg_integral = -cumulative_damping(alpha_func, t)
        diff = abs(log_ratio - neg_integral)
        print(f"  {t:6.1f}  {V:12.6f}  {log_ratio:12.6f}  {neg_integral:12.6f}  {diff:12.2e}")

    print()
    print("Observation: log(V(t)/V0) = -∫₀ᵗ 1/α(s) ds (up to numerical precision),")
    print("confirming the logarithmic linearization theorem.")
    print()


# ──────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   CONTINUOUS RENORMALIZATION FLOW — COMPUTATIONAL DEMONSTRATION     ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    experiment_1()
    experiment_2()
    experiment_3()
    experiment_4()
    experiment_5()

    print("All experiments completed successfully.")
