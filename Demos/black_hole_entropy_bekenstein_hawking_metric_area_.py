"""
Numerical demonstration of the exactly solvable isolated-horizon microstate model.

Model
-----
A horizon microstate is an ordered list of punctures. A puncture with spin label
k = 2j >= 1 contributes k elementary quanta of horizon area and carries k + 1
internal (magnetic) states. W(A) counts the ordered configurations of total area A.

Results verified numerically here
---------------------------------
1.  Renewal recursion            W(A+1) = sum_{i=0}^{A} (i+2) W(A-i)
2.  Finite linear recursion      W(A+2) = 4 W(A+1) - 2 W(A)          (A >= 1)
3.  Exact closed form            4 W(A) = (1+r2) s^A + (1-r2) s'^A,  s = 2+sqrt2
4.  Two-sided bound              s^A / 2 <= W(A) <= s^A
5.  Area law                     |log W(A) - A log s| <= log 2
6.  Exact subleading constant    log W(A) - A log s -> log((1+sqrt2)/4)
7.  Area quantum                 gamma = 4 log(2+sqrt2) is the unique value
                                 giving S = A_phys / 4
8.  Characteristic equation      sum_{k>=1} (k+1) x_c^k = 1 at x_c = 1/(2+sqrt2)
9.  Characteristic-root theorem  L = -log r for general degeneracy functions
10. Truncation rate              0 <= L - L_K <= (B/(1-Br)) (Br)^K
11. Partition function           Z(x) = (1-x)^2 / (2x^2 - 4x + 1) for x < x_c
12. Cumulant closed forms and    residues x_c, x_c^2, 2 x_c^3 of the poles of
    Hagedorn pole residues       kappa_1, kappa_2, kappa_3 at x = x_c
13. Gauss constraint             W(A)^2 <= (2A+1) Z(2A); Z(odd) = 0;
                                 failure of unimodality of the projection profile

Run with:  python demo.py
"""

from __future__ import annotations

import math
from itertools import product
from typing import Callable, Dict, Iterator, List, Tuple

# --------------------------------------------------------------------------- #
# Constants of the model
# --------------------------------------------------------------------------- #

SQRT2: float = math.sqrt(2.0)
S: float = 2.0 + SQRT2            # dominant growth rate  2 + sqrt(2)
S_PRIME: float = 2.0 - SQRT2      # subdominant root      2 - sqrt(2)
LAMBDA: float = math.log(S)       # entropy density       log(2 + sqrt(2))
X_C: float = 1.0 / S              # Hagedorn fugacity     1/(2 + sqrt(2))
THETA: float = S_PRIME / S        # eigenvalue ratio      3 - 2 sqrt(2)
GAMMA_BH: float = 4.0 * LAMBDA    # Bekenstein-Hawking area quantum
T_HAGEDORN: float = 1.0 / LAMBDA  # Hagedorn temperature


# --------------------------------------------------------------------------- #
# 1. Exact microstate counts
# --------------------------------------------------------------------------- #

def microstates_by_renewal(n_max: int) -> List[int]:
    """W(0..n_max) computed from the infinite-order renewal recursion.

    W(A+1) = sum_{i=0}^{A} (i+2) W(A-i).  Cost O(n_max^2) big-integer ops.
    """
    w: List[int] = [1]
    for a in range(n_max):
        w.append(sum((i + 2) * w[a - i] for i in range(a + 1)))
    return w


def microstates_by_linear_recursion(n_max: int) -> List[int]:
    """W(0..n_max) computed from W(A+2) = 4 W(A+1) - 2 W(A), valid for A >= 1.

    Seeded with W(0)=1, W(1)=2, W(2)=7.  Cost O(n_max) big-integer ops.
    """
    if n_max == 0:
        return [1]
    if n_max == 1:
        return [1, 2]
    w: List[int] = [1, 2, 7]
    for a in range(1, n_max - 1):
        w.append(4 * w[a + 1] - 2 * w[a])
    return w[: n_max + 1]


def microstates_closed_form(a: int) -> float:
    """4 W(A) = (1+sqrt2) s^A + (1-sqrt2) s'^A, valid for A >= 1."""
    return ((1.0 + SQRT2) * S**a + (1.0 - SQRT2) * S_PRIME**a) / 4.0


# --------------------------------------------------------------------------- #
# 2. Brute-force enumeration (independent check of the model definition)
# --------------------------------------------------------------------------- #

def enumerate_configurations(area: int) -> Iterator[Tuple[Tuple[int, int], ...]]:
    """All ordered puncture lists ((k1,M1),...) with sum ki = area.

    Magnetic numbers M range over {k, k-2, ..., -k}: exactly k+1 values.
    """
    if area == 0:
        yield ()
        return
    for k in range(1, area + 1):
        for m_index in range(k + 1):
            head = (k, k - 2 * m_index)
            for tail in enumerate_configurations(area - k):
                yield (head,) + tail


def brute_force_count(area: int) -> int:
    return sum(1 for _ in enumerate_configurations(area))


def projection_profile(area: int) -> Dict[int, int]:
    """D(A, M): number of configurations of area A with total projection M."""
    profile: Dict[int, int] = {}
    for cfg in enumerate_configurations(area):
        m_total = sum(m for _, m in cfg)
        profile[m_total] = profile.get(m_total, 0) + 1
    return profile


def constrained_count(area: int) -> int:
    """Z(A) = D(A, 0): microstates obeying the Gauss (singlet) constraint."""
    return projection_profile(area).get(0, 0)


# --------------------------------------------------------------------------- #
# 3. General puncture models: characteristic root and entropy density
# --------------------------------------------------------------------------- #

def general_microstates(deg: Callable[[int], int], n_max: int) -> List[int]:
    """W_deg(0..n_max) via the renewal recursion W(A) = sum_k deg(k) W(A-k)."""
    w: List[int] = [1] + [0] * n_max
    for a in range(1, n_max + 1):
        w[a] = sum(deg(k) * w[a - k] for k in range(1, a + 1))
    return w


def characteristic_root(deg: Callable[[int], int], k_max: int,
                        tol: float = 1e-15) -> float:
    """Unique r > 0 with sum_{k=1}^{k_max} deg(k) r^k = 1, by bisection."""
    def f(x: float) -> float:
        return sum(deg(k) * x**k for k in range(1, k_max + 1))

    lo, hi = 0.0, 1.0
    while f(hi) < 1.0:            # widen if the truncated model is very sparse
        hi *= 2.0
        if hi > 1e6:
            raise ValueError("no characteristic root: model too degenerate")
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        if f(mid) < 1.0:
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    return 0.5 * (lo + hi)


def entropy_density_from_root(deg: Callable[[int], int], k_max: int) -> float:
    """L_K = -log r_K for the model truncated at puncture area k_max."""
    return -math.log(characteristic_root(deg, k_max))


# --------------------------------------------------------------------------- #
# 4. Canonical thermodynamics
# --------------------------------------------------------------------------- #

def partition_function(x: float) -> float:
    """Z(x) = (1-x)^2 / (2x^2 - 4x + 1) for 0 <= x < x_c."""
    return (1.0 - x) ** 2 / (2.0 * x * x - 4.0 * x + 1.0)


def mean_area(x: float) -> float:
    """kappa_1(x) = 2x / ((2x^2 - 4x + 1)(1 - x)); simple pole at x_c."""
    return 2.0 * x / ((2.0 * x * x - 4.0 * x + 1.0) * (1.0 - x))


def area_variance(x: float) -> float:
    """kappa_2(x) = 2x(4x^3 - 6x^2 + 1) / ((2x^2-4x+1)^2 (1-x)^2); double pole."""
    num = 2.0 * x * (4.0 * x**3 - 6.0 * x**2 + 1.0)
    den = (2.0 * x * x - 4.0 * x + 1.0) ** 2 * (1.0 - x) ** 2
    return num / den


def area_third_cumulant(x: float) -> float:
    """kappa_3(x), a rational function with a triple pole at x_c."""
    num = 2.0 * x * (1.0 + 5.0 * x - 36.0 * x**2 + 56.0 * x**3
                     - 4.0 * x**4 - 36.0 * x**5 + 16.0 * x**6)
    den = (2.0 * x * x - 4.0 * x + 1.0) ** 3 * (1.0 - x) ** 3
    return num / den


def boltzmann_terms(x: float, n_terms: int) -> List[float]:
    """The terms t_A = W(A) x^A, computed in floating point without overflow.

    Uses t_{A+2} = 4x t_{A+1} - 2x^2 t_A (valid for A >= 1), seeded with
    t_0 = 1, t_1 = 2x, t_2 = 7x^2.  Independent of the closed form.
    """
    if n_terms == 0:
        return [1.0]
    if n_terms == 1:
        return [1.0, 2.0 * x]
    t: List[float] = [1.0, 2.0 * x, 7.0 * x * x]
    for a in range(1, n_terms - 1):
        t.append(4.0 * x * t[a + 1] - 2.0 * x * x * t[a])
    return t[: n_terms + 1]


def partition_by_summation(x: float, n_terms: int = 4000) -> float:
    """Z(x) from the truncated sum sum_A W(A) x^A."""
    return math.fsum(boltzmann_terms(x, n_terms))


def cumulants_by_summation(x: float, n_terms: int = 4000) -> Tuple[float, float, float]:
    """kappa_1, kappa_2, kappa_3 from truncated sums sum_A A^p W(A) x^A."""
    t = boltzmann_terms(x, n_terms)
    m0 = math.fsum(t)
    m1 = math.fsum(a * t[a] for a in range(len(t)))
    m2 = math.fsum(a * a * t[a] for a in range(len(t)))
    m3 = math.fsum(a ** 3 * t[a] for a in range(len(t)))
    mu1, mu2, mu3 = m1 / m0, m2 / m0, m3 / m0
    return mu1, mu2 - mu1 ** 2, mu3 - 3.0 * mu1 * mu2 + 2.0 * mu1 ** 3


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_counts() -> None:
    print("=" * 78)
    print("1. EXACT MICROSTATE COUNTS")
    print("=" * 78)
    n = 14
    w_ren = microstates_by_renewal(n)
    w_lin = microstates_by_linear_recursion(n)
    assert w_ren == w_lin, "renewal and linear recursions disagree"
    print("  A |          W(A) | 4W(A) closed form | W(A+2)-4W(A+1)+2W(A)")
    print("  " + "-" * 70)
    for a in range(n + 1):
        cf = microstates_closed_form(a) if a >= 1 else float("nan")
        chk = (w_lin[a + 2] - 4 * w_lin[a + 1] + 2 * w_lin[a]
               if 1 <= a <= n - 2 else None)
        chk_s = "-" if chk is None else str(chk)
        print(f" {a:2d} | {w_lin[a]:13d} | {cf:17.6f} | {chk_s:>20s}")
    print("\n  Brute-force enumeration cross-check (A <= 8):")
    for a in range(9):
        bf = brute_force_count(a)
        assert bf == w_lin[a], f"mismatch at A={a}"
        print(f"    A = {a}: enumerated {bf:6d}   recursion {w_lin[a]:6d}   OK")
    print()


def demo_area_law() -> None:
    print("=" * 78)
    print("2. THE AREA LAW, ITS BOUNDED DEFECT, AND ITS EXACT SUBLEADING CONSTANT")
    print("=" * 78)
    print(f"  entropy density  lambda = log(2+sqrt2) = {LAMBDA:.12f}")
    print(f"  area quantum      gamma = 4 lambda     = {GAMMA_BH:.12f}")
    print(f"  predicted limit   log((1+sqrt2)/4)     = "
          f"{math.log((1.0 + SQRT2) / 4.0):.12f}")
    print()
    w = microstates_by_linear_recursion(60)
    print("   A |      S(A) |  S(A)-A*lambda | bound log2 | S(A)/(gamma*A)")
    print("  " + "-" * 68)
    for a in [1, 2, 3, 5, 10, 20, 30, 40, 50, 60]:
        s = math.log(w[a])
        defect = s - a * LAMBDA
        assert abs(defect) <= math.log(2.0) + 1e-12, "bounded-defect law violated"
        assert w[a] * 2 >= S**a - 1e-6 and w[a] <= S**a + 1e-6
        print(f" {a:3d} | {s:9.5f} | {defect:14.9f} |   {math.log(2.0):8.5f} "
              f"| {s / (GAMMA_BH * a):.9f}")
    print("\n  The defect converges to log((1+sqrt2)/4) = "
          f"{math.log((1.0+SQRT2)/4.0):.9f} at rate theta^A, theta = "
          f"{THETA:.6f}.")
    print("  S(A)/(gamma A) -> 1/4 = 0.25 exactly when gamma = 4 lambda.")
    print()


def demo_characteristic_equation() -> None:
    print("=" * 78)
    print("3. THE CHARACTERISTIC EQUATION AND THE UNIVERSAL DENSITY")
    print("=" * 78)
    total = sum((k + 1) * X_C**k for k in range(1, 400))
    print(f"  x_c = 1/(2+sqrt2)              = {X_C:.12f}")
    print(f"  sum_{{k>=1}} (k+1) x_c^k        = {total:.12f}   (should be 1)")
    assert abs(total - 1.0) < 1e-10
    print(f"  -log x_c                       = {-math.log(X_C):.12f}")
    print(f"  lambda                         = {LAMBDA:.12f}   (equal)")
    print()
    print("  Truncation rate:  0 <= lambda - L_K <= (2/(1-2x_c)) (2x_c)^K")
    b_r = 2.0 * X_C
    print("    K |        L_K |  lambda - L_K |   rigorous bound")
    print("  " + "-" * 58)
    for k_max in [1, 2, 3, 5, 8, 12, 16, 20, 30]:
        lk = entropy_density_from_root(lambda k: k + 1, k_max)
        bound = (2.0 / (1.0 - b_r)) * b_r**k_max
        gap = LAMBDA - lk
        assert -1e-12 <= gap <= bound + 1e-12, "truncation bound violated"
        print(f"   {k_max:2d} | {lk:10.7f} | {gap:13.3e} | {bound:15.3e}")
    print()
    print("  Other puncture models: L = -log r with sum_k deg(k) r^k = 1.")
    models: List[Tuple[str, Callable[[int], int]]] = [
        ("deg(k) = k+1  (isolated horizon)", lambda k: k + 1),
        ("deg(k) = 1    (compositions)     ", lambda k: 1),
        ("deg(k) = 2^k  (saturated)        ", lambda k: 2**k),
        ("deg(1)=1, deg(k>=2)=0 (degenerate)", lambda k: 1 if k == 1 else 0),
    ]
    print("    model                              |      r     |     L=-log r "
          "| empirical log W(A)/A")
    print("  " + "-" * 96)
    for name, deg in models:
        k_max = 25
        r = characteristic_root(deg, k_max)
        l_theory = -math.log(r)
        w = general_microstates(deg, 300)
        empirical = math.log(w[300]) / 300 if w[300] > 0 else float("nan")
        print(f"    {name:34s} | {r:10.7f} | {l_theory:12.8f} | {empirical:.8f}")
    print("\n  Rigidity: increasing any degeneracy strictly increases L.")
    base = characteristic_root(lambda k: k + 1, 25)
    bumped = characteristic_root(lambda k: (k + 1) + (1 if k == 3 else 0), 25)
    assert bumped < base
    print(f"    L(deg)          = {-math.log(base):.10f}")
    print(f"    L(deg + e_3)    = {-math.log(bumped):.10f}   (strictly larger)")
    print()


def demo_thermodynamics() -> None:
    print("=" * 78)
    print("4. CANONICAL THERMODYNAMICS AND THE HAGEDORN TRANSITION")
    print("=" * 78)
    print(f"  Hagedorn fugacity     x_c = {X_C:.12f}")
    print(f"  Hagedorn temperature  T_H = 1/log(2+sqrt2) = {T_HAGEDORN:.12f}")
    print()
    print("  Closed form Z(x) = (1-x)^2/(2x^2-4x+1) versus truncated sum:")
    print("      x     |  Z closed form |  Z truncated sum")
    print("  " + "-" * 52)
    for x in [0.05, 0.10, 0.20, 0.25, 0.28, 0.29]:
        trunc = partition_by_summation(x, 6000)
        zc = partition_function(x)
        assert abs(trunc - zc) < 1e-7 * max(1.0, abs(zc))
        print(f"   {x:7.4f} | {zc:14.8f} | {trunc:16.8f}")
    print()
    print("  Cumulants: closed forms versus direct summation")
    print("      x     |    kappa_1    |    kappa_2    |    kappa_3")
    print("  " + "-" * 62)
    for x in [0.10, 0.20, 0.25, 0.28]:
        k1c, k2c, k3c = mean_area(x), area_variance(x), area_third_cumulant(x)
        k1s, k2s, k3s = cumulants_by_summation(x, 6000)
        assert abs(k1c - k1s) < 1e-6 * max(1.0, abs(k1c))
        assert abs(k2c - k2s) < 1e-5 * max(1.0, abs(k2c))
        assert abs(k3c - k3s) < 1e-4 * max(1.0, abs(k3c))
        print(f"   {x:7.4f} | {k1c:13.6f} | {k2c:13.6f} | {k3c:13.6f}")
        print(f"   (summed) | {k1s:13.6f} | {k2s:13.6f} | {k3s:13.6f}")
    print()
    print("  Pole orders and residues at x_c:")
    print("      eps     | (x_c-x) k1 | (x_c-x)^2 k2 | (x_c-x)^3 k3")
    print("  " + "-" * 62)
    for eps in [1e-2, 1e-3, 1e-4, 1e-5, 1e-6]:
        x = X_C - eps
        r1 = eps * mean_area(x)
        r2 = eps**2 * area_variance(x)
        r3 = eps**3 * area_third_cumulant(x)
        print(f"   {eps:9.1e} | {r1:10.7f} | {r2:12.9f} | {r3:12.10f}")
    print(f"   targets    | {X_C:10.7f} | {X_C**2:12.9f} | {2*X_C**3:12.10f}")
    print()
    print("  Positivity (stability and right-skewness) for 0 < x < x_c:")
    for x in [0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.29]:
        assert area_variance(x) > 0 and area_third_cumulant(x) > 0
    print("    kappa_2 > 0 and kappa_3 > 0 verified on a grid: specific heat")
    print("    C = beta^2 kappa_2 is positive and the area law is right-skewed.")
    print()


def demo_gauss_constraint() -> None:
    print("=" * 78)
    print("5. THE GAUSS (PROJECTION) CONSTRAINT")
    print("=" * 78)
    print("  Projection profiles D(A, M) and the constrained count Z(A) = D(A,0):")
    print("    A |  W(A) |  Z(A) | profile D(A, M) for M = -A..A")
    print("  " + "-" * 74)
    for a in range(0, 8):
        prof = projection_profile(a)
        w_a = sum(prof.values())
        row = " ".join(str(prof.get(m, 0)) for m in range(-a, a + 1))
        print(f"   {a:2d} | {w_a:5d} | {prof.get(0,0):5d} | {row}")
    print()
    print("  Parity superselection: Z(A) = 0 for odd A.")
    for a in range(1, 10, 2):
        assert constrained_count(a) == 0
    print("    verified for A = 1, 3, 5, 7, 9.")
    print()
    print("  Sharp constraint bound  W(A)^2 <= (2A+1) Z(2A):")
    print("    A | W(A)^2      | (2A+1) Z(2A) | entropy defect | bound log4+log(2A+1)")
    print("  " + "-" * 78)
    for a in range(1, 6):
        w_a = brute_force_count(a)
        z2a = constrained_count(2 * a)
        lhs = w_a * w_a
        rhs = (2 * a + 1) * z2a
        assert lhs <= rhs, "sharp constraint bound violated"
        defect = 2 * a * LAMBDA - math.log(z2a) if z2a > 0 else float("nan")
        bound = math.log(4.0) + math.log(2 * a + 1)
        print(f"   {a:2d} | {lhs:11d} | {rhs:12d} | {defect:14.6f} | {bound:20.6f}")
    print()
    print("  Failure of global unimodality D(A,M) <= D(A,0):")
    prof1 = projection_profile(1)
    print(f"    D(1, +1) = {prof1.get(1,0)},  D(1, -1) = {prof1.get(-1,0)},  "
          f"D(1, 0) = {prof1.get(0,0)}")
    assert prof1.get(1, 0) > prof1.get(0, 0)
    print("    So D(1,1) > D(1,0): unimodality holds at best within a parity class.")
    print()


def main() -> None:
    print()
    print("#" * 78)
    print("#  BEKENSTEIN-HAWKING AREA LAW FROM ISOLATED-HORIZON MICROSTATE COUNTING")
    print("#" * 78)
    print()
    demo_counts()
    demo_area_law()
    demo_characteristic_equation()
    demo_thermodynamics()
    demo_gauss_constraint()
    print("=" * 78)
    print("All numerical checks passed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
