"""
The Multiplicative Law of the Tokenizer Tax — numerical demonstrations.

Self-contained (standard library only). Run with:

    python3 demo.py

The script demonstrates, numerically:

  1. The measured German retention sweep at context 4096 and the power-law fit
     deficit(k) = A * k**(-a).
  2. The exact gate:  retained(k) >= tau  <==>  k >= (A/(1-tau))**(1/a).
     Every measured point fails the 0.98 bar, and the true requirement is ~64 keys.
  3. Homogeneity of the budget in the amplitude, hence the amplification factor
     chi(lam) = lam**(b/a), a character: chi(1) = 1, chi(u*v) = chi(u)*chi(v).
  4. The multiplicative law: tax(C2) * baseline(C1) = tax(C1) * baseline(C2),
     with the +4 -> +16 instance at a 4x baseline acceleration.
  5. Refutation of "the tax dissolves" and "the tax stays constant".
  6. Sub-linearity of the recall exponent forced by the two data anchors, and the
     resulting super-linear budget response.
  7. Non-separability: no table budget(lam, C) = f(C) + g(lam) can exist, and grid
     quantization does not absorb the amplification.
  8. Model independence: a continuum Zipf attention profile x -> x**(-s) on (0, C],
     whose retention curve (k/C)**(1-s) is computed from mass integrals, obeys the
     same law with character chi(u) = u.
  9. The two parameter-free predictions (context-invariant tax ratio; non-crossing
     language rankings).
"""

from __future__ import annotations

import math
from typing import Sequence, Tuple

# --------------------------------------------------------------------------------------
# The measured cell: German prose, context 4096, exact gate, three held-out windows.
# --------------------------------------------------------------------------------------

MEASURED_KEYS: Tuple[int, ...] = (24, 32, 40, 48, 56)
MEASURED_RETAINED: Tuple[float, ...] = (0.953, 0.966, 0.973, 0.975, 0.976)
BAR: float = 0.98


# --------------------------------------------------------------------------------------
# 1. The power-law recall model
# --------------------------------------------------------------------------------------

def deficit(amplitude: float, exponent: float, keys: float) -> float:
    """Recall deficit A * k**(-a): the fraction of attention mass lost at budget `keys`."""
    return amplitude * keys ** (-exponent)


def retained(amplitude: float, exponent: float, keys: float) -> float:
    """Retained fraction 1 - deficit."""
    return 1.0 - deficit(amplitude, exponent, keys)


def budget(amplitude: float, exponent: float, bar: float) -> float:
    """Exact key budget (A/(1-tau))**(1/a) needed to clear the retention bar `bar`."""
    return (amplitude / (1.0 - bar)) ** (1.0 / exponent)


def fit_power_law(keys: Sequence[float], retained_vals: Sequence[float]) -> Tuple[float, float]:
    """Least-squares fit of log(deficit) against log(k); returns (amplitude, exponent)."""
    xs = [math.log(k) for k in keys]
    ys = [math.log(1.0 - r) for r in retained_vals]
    n = float(len(xs))
    mx = sum(xs) / n
    my = sum(ys) / n
    sxy = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    sxx = sum((x - mx) ** 2 for x in xs)
    slope = sxy / sxx          # equals -a
    intercept = my - slope * mx  # equals log A
    return math.exp(intercept), -slope


# --------------------------------------------------------------------------------------
# 2. Amplitude, amplification factor, tax
# --------------------------------------------------------------------------------------

def amplitude(base: float, ctx_exponent: float, lam: float, ctx: float) -> float:
    """Deficit amplitude A0 * (lam * C)**b: language enters as a dilation of the context."""
    return base * (lam * ctx) ** ctx_exponent


def amp(exponent: float, ctx_exponent: float, lam: float) -> float:
    """Amplification factor chi(lam) = lam**(b/a)."""
    return lam ** (ctx_exponent / exponent)


def baseline(base: float, ctx_exponent: float, exponent: float, bar: float, ctx: float) -> float:
    """Reference-language requirement at context `ctx`."""
    return budget(amplitude(base, ctx_exponent, 1.0, ctx), exponent, bar)


def tax(base: float, ctx_exponent: float, exponent: float, bar: float,
        lam: float, ctx: float) -> float:
    """Extra keys the language of fragmentation ratio `lam` demands at context `ctx`."""
    return (budget(amplitude(base, ctx_exponent, lam, ctx), exponent, bar)
            - baseline(base, ctx_exponent, exponent, bar, ctx))


# --------------------------------------------------------------------------------------
# 3. Grid quantization
# --------------------------------------------------------------------------------------

def steps(grid: float, demand: float) -> int:
    """Number of allocation blocks of size `grid` needed for a real demand."""
    return math.ceil(demand / grid)


# --------------------------------------------------------------------------------------
# 4. The continuum Zipf model
# --------------------------------------------------------------------------------------

def zipf_mass(s: float, upper: float) -> float:
    """Exact attention mass of the profile x**(-s) on (0, upper], valid for s < 1."""
    return upper ** (1.0 - s) / (1.0 - s)


def zipf_retained(s: float, keys: float, ctx: float) -> float:
    """Retained fraction of the Zipf profile: computed as a ratio of mass integrals."""
    return zipf_mass(s, keys) / zipf_mass(s, ctx)


def zipf_budget(s: float, bar: float, ctx: float) -> float:
    """Exact Zipf key budget tau**(1/(1-s)) * C."""
    return bar ** (1.0 / (1.0 - s)) * ctx


def zipf_tax(s: float, bar: float, lam: float, ctx: float) -> float:
    """Zipf language tax; equals (lam - 1) * zipf_budget(s, bar, ctx)."""
    return zipf_budget(s, bar, lam * ctx) - zipf_budget(s, bar, ctx)


# --------------------------------------------------------------------------------------
# Reporting helpers
# --------------------------------------------------------------------------------------

def header(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def check(label: str, lhs: float, rhs: float, tol: float = 1e-9) -> None:
    ok = abs(lhs - rhs) <= tol * max(1.0, abs(lhs), abs(rhs))
    print(f"  [{'OK ' if ok else 'BAD'}] {label}: {lhs:.10g}  vs  {rhs:.10g}")


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------

def demo_fit_and_gate() -> Tuple[float, float]:
    header("1. The measured sweep, the power-law fit, and the exact gate")
    A, a = fit_power_law(MEASURED_KEYS, MEASURED_RETAINED)
    print(f"  fitted amplitude A = {A:.4f},  exponent a = {a:.4f}")
    print()
    print("     k   measured   model     residual   clears 0.98?")
    for k, r in zip(MEASURED_KEYS, MEASURED_RETAINED):
        m = retained(A, a, k)
        print(f"   {k:3d}   {r:.4f}     {m:.4f}    {abs(m - r):.4f}      "
              f"{'yes' if m >= BAR else 'NO'}")
    req = budget(A, a, BAR)
    print()
    print(f"  exact requirement at the 0.98 bar: {req:.2f} keys "
          f"(the sweep stopped at {max(MEASURED_KEYS)})")
    print("  gate equivalence  retained(k) >= tau  <==>  k >= budget,  spot-checked:")
    for k in (req - 1.0, req, req + 1.0):
        print(f"    k = {k:6.2f}:  retained = {retained(A, a, k):.6f}, "
              f"passes = {retained(A, a, k) >= BAR}, k >= budget = {k >= req}")
    print("  monotonicity: one failure at the largest budget certifies all smaller ones.")
    return A, a


def demo_character(a: float, b: float) -> None:
    header("2. The amplification factor is a character (chi(1)=1, chi(uv)=chi(u)chi(v))")
    check("chi(1) = 1", amp(a, b, 1.0), 1.0)
    u, v = 1.23, 1.41
    check("chi(u*v) = chi(u)*chi(v)", amp(a, b, u * v), amp(a, b, u) * amp(a, b, v))
    print(f"  German-like lam = 1.30:  chi = {amp(a, b, 1.30):.4f} "
          f"(naive token-count charge lam**b = {1.30 ** b:.4f})")
    print("  the amplification strictly exceeds the token-count penalty because a < 1")


def demo_multiplicative_law(A0: float, b: float, a: float, bar: float, lam: float) -> None:
    header("3. The multiplicative law and the +4 -> +16 instance")
    for C1, C2 in ((512.0, 2048.0), (1024.0, 4096.0), (256.0, 4096.0)):
        t1, t2 = (tax(A0, b, a, bar, lam, C1), tax(A0, b, a, bar, lam, C2))
        B1, B2 = (baseline(A0, b, a, bar, C1), baseline(A0, b, a, bar, C2))
        print(f"  C1={C1:7.0f} -> C2={C2:7.0f}:  baseline x{B2 / B1:6.3f}, "
              f"tax x{t2 / t1:6.3f}")
        check("    tax(C2)*B(C1) = tax(C1)*B(C2)", t2 * B1, t1 * B2)

    print()
    print("  exact rational witness (A0 = b = a = 1, tau = 1/2, lam = 3, C1 = 1, C2 = 4):")
    w = dict(base=1.0, ctx_exponent=1.0, exponent=1.0, bar=0.5)
    B1 = baseline(w["base"], w["ctx_exponent"], w["exponent"], w["bar"], 1.0)
    B2 = baseline(w["base"], w["ctx_exponent"], w["exponent"], w["bar"], 4.0)
    check("    baseline quadruples", B2, 4.0 * B1)
    check("    short-context tax", tax(1.0, 1.0, 1.0, 0.5, 3.0, 1.0), 4.0)
    check("    long-context tax", tax(1.0, 1.0, 1.0, 0.5, 3.0, 4.0), 16.0)


def demo_refutations(A0: float, b: float, a: float, bar: float, lam: float) -> None:
    header("4. P2 and P3 refuted: the tax neither dissolves nor stays constant")
    print("      context      baseline        tax      tax/baseline")
    for C in (256.0, 512.0, 1024.0, 2048.0, 4096.0, 16384.0, 65536.0):
        B = baseline(A0, b, a, bar, C)
        t = tax(A0, b, a, bar, lam, C)
        print(f"   {C:9.0f}   {B:11.3f}   {t:9.3f}    {t / B:.6f}")
    print("  the ratio column is constant: tax = (chi(lam) - 1) * baseline exactly.")
    print(f"  chi(lam) - 1 = {amp(a, b, lam) - 1.0:.6f}")
    target = 1e6
    C = 1.0
    while tax(A0, b, a, bar, lam, C) <= target:
        C *= 2.0
    print(f"  unbounded: tax exceeds {target:g} keys already at context {C:.0f}")


def demo_sublinearity() -> None:
    header("5. The two data anchors force a < 1, hence a super-linear budget response")
    d24, d56 = 0.047, 0.024
    a_implied = math.log(d24 / d56) / math.log(56.0 / 24.0)
    print(f"  deficit(24) = {d24}, deficit(56) = {d56}")
    print(f"  (56/24)**a = {d24 / d56:.4f}  =>  a = {a_implied:.4f} < 1")
    print("  keys buy strictly less than proportional recall.")
    print()
    print("  super-linear response  budget(cA) = c**(1/a) * budget(A) > c * budget(A):")
    A, tau_ = 0.582, 0.98
    for c in (2.0, 4.0, 10.0):
        lhs = budget(c * A, a_implied, tau_)
        rhs = c * budget(A, a_implied, tau_)
        print(f"    c = {c:5.1f}:  budget(cA) = {lhs:9.3f}  >  c*budget(A) = {rhs:9.3f}")


def demo_no_separable_table(A0: float, b: float, a: float, bar: float) -> None:
    header("6. No additive budget table exists; quantization does not absorb the growth")
    print("  a separable table budget(lam,C) = f(C) + g(lam) would force the difference")
    print("  budget(lam,C) - budget(1,C) to be independent of C.  It is not:")
    lam = 1.30
    for C in (512.0, 1024.0, 2048.0, 4096.0):
        print(f"    C = {C:7.0f}:  budget(lam,C) - budget(1,C) = "
              f"{tax(A0, b, a, bar, lam, C):9.4f}")
    print("  distinct values at distinct contexts => no such f, g exist.")
    print()
    print("  exchange symmetry  budget(lam, C) = budget(1, lam*C):")
    check("    exchange", budget(amplitude(A0, b, lam, 2048.0), a, bar),
          budget(amplitude(A0, b, 1.0, lam * 2048.0), a, bar))
    print()
    print("  grid quantization, block size g = 4:")
    print(f"    steps(4, 4)  = {steps(4.0, 4.0)} block(s)")
    print(f"    steps(4, 16) = {steps(4.0, 16.0)} block(s)")
    print("    bound 4*steps(g,x) - 3 <= steps(g, 4x) checked on a grid of demands:")
    worst = min(steps(4.0, 4.0 * x) - (4 * steps(4.0, x) - 3)
                for x in [0.1 * i for i in range(1, 400)])
    print(f"      minimum slack over 399 demands: {worst} (>= 0, so the bound holds)")


def demo_zipf(bar: float) -> None:
    header("7. Model independence: a continuum Zipf attention profile obeys the same law")
    s = 0.4
    print(f"  profile x**(-s) on (0, C] with s = {s}")
    print("  retention computed from mass integrals equals (k/C)**(1-s):")
    for k, C in ((10.0, 100.0), (56.0, 4096.0), (700.0, 1000.0)):
        check(f"    k={k:6.0f}, C={C:6.0f}", zipf_retained(s, k, C), (k / C) ** (1.0 - s))
    print()
    print("  the Zipf gate is exact:  tau <= (k/C)**(1-s)  <==>  k >= tau**(1/(1-s)) * C")
    C = 4096.0
    req = zipf_budget(s, bar, C)
    for k in (req - 1.0, req, req + 1.0):
        print(f"    k = {k:9.3f}: retained = {zipf_retained(s, k, C):.6f}, "
              f"passes = {zipf_retained(s, k, C) >= bar}, k >= budget = {k >= req}")
    print()
    print("  its character is the identity, so a 4x longer context carries a 4x larger tax:")
    lam = 1.30
    t1 = zipf_tax(s, bar, lam, 1024.0)
    t2 = zipf_tax(s, bar, lam, 4096.0)
    print(f"    tax at C=1024: {t1:.4f};  tax at C=4096: {t2:.4f};  ratio {t2 / t1:.4f}")
    check("    multiplicative law", t2 * zipf_budget(s, bar, 1024.0),
          t1 * zipf_budget(s, bar, 4096.0))
    check("    tax = (lam-1)*budget", zipf_tax(s, bar, lam, 4096.0),
          (lam - 1.0) * zipf_budget(s, bar, 4096.0))
    print()
    print("  the two models' characters agree exactly when b = a:")
    for (a_, b_) in ((0.81, 0.81), (0.81, 0.60)):
        print(f"    a = {a_}, b = {b_}:  chi(1.3) = {amp(a_, b_, 1.3):.4f}, "
              f"identity gives 1.3000")


def demo_predictions(A0: float, b: float, a: float, bar: float) -> None:
    header("8. Two parameter-free predictions for the next experimental cells")
    lam_fr, lam_de = 1.15, 1.30
    C1, C2 = 1024.0, 4096.0
    t_fr_1 = tax(A0, b, a, bar, lam_fr, C1)
    t_fr_2 = tax(A0, b, a, bar, lam_fr, C2)
    t_de_1 = tax(A0, b, a, bar, lam_de, C1)
    t_de_2 = tax(A0, b, a, bar, lam_de, C2)
    print("  Prediction 1 (context-invariant ratio):")
    check("    T_fr(C1)*T_de(C2) = T_fr(C2)*T_de(C1)", t_fr_1 * t_de_2, t_fr_2 * t_de_1)
    print(f"    T_fr/T_de = {t_fr_1 / t_de_1:.6f} at C={C1:.0f} and "
          f"{t_fr_2 / t_de_2:.6f} at C={C2:.0f}")
    print()
    print("  Prediction 2 (rankings never cross):")
    print("      context     T(French)    T(German)   ordered?")
    for C in (256.0, 1024.0, 4096.0, 16384.0):
        tf = tax(A0, b, a, bar, lam_fr, C)
        td = tax(A0, b, a, bar, lam_de, C)
        print(f"   {C:9.0f}   {tf:10.4f}   {td:10.4f}   {'yes' if tf <= td else 'NO'}")


def main() -> None:
    A, a = demo_fit_and_gate()

    # Context exponent chosen so that the baseline quadruples over a 4x context stretch
    # at the fitted recall exponent: 4**(b/a) = 4 requires b = a.  We use the slightly
    # smaller b below to show the law holds for any acceleration factor, then the
    # calibrated value b = a for the headline +4 -> +16 cell.
    A0, bar, lam = 0.05, BAR, 1.30

    demo_character(a, a)
    demo_multiplicative_law(A0, a, a, bar, lam)
    demo_refutations(A0, 0.75 * a, a, bar, lam)
    demo_sublinearity()
    demo_no_separable_table(A0, 0.75 * a, a, bar)
    demo_zipf(0.90)
    demo_predictions(A0, 0.75 * a, a, bar)

    header("Summary")
    print("  * the gate is an exact threshold, and the 4096 German sweep never reached it")
    print("  * the language knob multiplies the budget by a character chi(lam)")
    print("  * therefore tax = (chi(lam) - 1) * baseline, and the tax amplifies by exactly")
    print("    the baseline's acceleration:  +4 keys at short context -> +16 at 4096")
    print("  * the tax neither dissolves nor stays constant; it diverges with context")
    print("  * no additive language/context budget table exists, and block quantization")
    print("    does not absorb the growth")
    print("  * a completely different micro-model (continuum Zipf) obeys the same law:")
    print("    the law is structural, the exponent is the measurable content")


if __name__ == "__main__":
    main()
