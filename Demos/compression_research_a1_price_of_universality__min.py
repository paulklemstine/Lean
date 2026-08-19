"""
The Price of Universality — numerical demonstrations.

This self-contained script demonstrates, numerically, the main results of
"The Price of Universality: An Exact Non-Asymptotic Theory of Minimax Redundancy".

Setting
-------
A *source class* is a finite family of probability distributions
    p_theta : X -> (0, 1],  theta in Theta
on a finite message space X.  A *coding distribution* q is a probability
distribution on X; coding p_theta-data with q wastes

    D(p_theta || q) = sum_x p_theta(x) log2( p_theta(x) / q(x) )   bits per message.

The price of universality is the minimax value  min_q max_theta D(p_theta || q).

Main theorem (redundancy-capacity theorem)
------------------------------------------
    min_q max_theta D(p_theta || q)  =  C  :=  max_w  I(w),
    I(w) = sum_theta w_theta D(p_theta || m_w),   m_w = sum_theta w_theta p_theta.

I(w) is the mutual information between the source index and the message, so C is
the Shannon capacity of the channel theta -> x.

What this script checks
-----------------------
 1. Blahut-Arimoto computation of C, with a certified two-sided bracket.
 2. The saddle point / equalizer property of the optimal prior.
 3. Uniqueness of the optimal Bayes mixture (from two different starting priors).
 4. Closed form for unknown-offset classes:  C = log2|A| - H(p0),
    worst case = log2|A| - Hmin(p0), gap = H(p0) - Hmin(p0).
 5. The explicit Bernoulli(3/4) two-source class: C = (3/4)log2 3 - 1,
    worst case = log2 3 - 1, gap = (1/4) log2 3.
 6. Additivity of the capacity over independent blocks.
 7. Model-selection sandwich: merging K classes costs at most log2 K bits.
 8. Data processing and sufficiency: the type of an i.i.d. message is a
    sufficient statistic (zero parse defect), a lossy parse is not.
 9. Rissanen rates: capacity of Bernoulli families vs log2(n+1), and the
    explicit Chebyshev packing lower bound (15/32) log2 n - 8.

Run with:  python3 demo.py         (standard library only)
"""

from __future__ import annotations

import itertools
import math
from typing import Callable, Dict, List, Sequence, Tuple

Vector = List[float]
Matrix = List[Vector]  # p[theta][x]

LOG2 = math.log(2.0)


# ----------------------------------------------------------------------------
# Basic information-theoretic quantities
# ----------------------------------------------------------------------------

def entropy_bits(p: Sequence[float]) -> float:
    """Shannon entropy H(p) in bits, with the convention 0 log 0 = 0."""
    return -sum(pi * math.log2(pi) for pi in p if pi > 0.0)


def min_entropy_bits(p: Sequence[float]) -> float:
    """Min-entropy H_inf(p) = -log2 max_x p(x), in bits."""
    return -math.log2(max(p))


def kl_bits(p: Sequence[float], q: Sequence[float]) -> float:
    """Relative entropy D(p || q) in bits.  Requires q(x) > 0 wherever p(x) > 0."""
    total = 0.0
    for pi, qi in zip(p, q):
        if pi > 0.0:
            total += pi * math.log2(pi / qi)
    return total


def chi_squared(a: Sequence[float], b: Sequence[float]) -> float:
    """chi^2(a || b) = sum_x (a(x) - b(x))^2 / b(x)."""
    return sum((ai - bi) ** 2 / bi for ai, bi in zip(a, b))


def mixture(weights: Sequence[float], sources: Matrix) -> Vector:
    """The Bayes mixture m_w(x) = sum_theta w_theta p_theta(x)."""
    n = len(sources[0])
    return [sum(w * p[x] for w, p in zip(weights, sources)) for x in range(n)]


def mutual_info_bits(weights: Sequence[float], sources: Matrix) -> float:
    """I(w) = sum_theta w_theta D(p_theta || m_w)."""
    m = mixture(weights, sources)
    return sum(w * kl_bits(p, m) for w, p in zip(weights, sources) if w > 0.0)


def shtarkov_sum(sources: Matrix) -> float:
    """C_S = sum_x max_theta p_theta(x); log2 C_S is the worst-case price."""
    n = len(sources[0])
    return sum(max(p[x] for p in sources) for x in range(n))


def nml(sources: Matrix) -> Vector:
    """Normalized maximum-likelihood distribution (the worst-case optimum)."""
    cs = shtarkov_sum(sources)
    n = len(sources[0])
    return [max(p[x] for p in sources) / cs for x in range(n)]


# ----------------------------------------------------------------------------
# Blahut-Arimoto: compute the capacity with a certified bracket
# ----------------------------------------------------------------------------

def blahut_arimoto(
    sources: Matrix,
    iterations: int = 4000,
    tol: float = 1e-13,
    prior0: Sequence[float] | None = None,
) -> Tuple[float, Vector, Vector, float, float]:
    """Compute the capacity C of a source class by alternating maximisation.

    Returns (C_estimate, optimal_prior, optimal_mixture, lower_cert, upper_cert),
    where lower_cert = I(w) <= C <= upper_cert = max_theta D(p_theta || m_w).
    The bracket is rigorous at every iteration: the lower certificate holds by
    definition of C as a supremum, and the upper certificate by the verification
    criterion (any coding distribution within c bits of every source forces C <= c).
    """
    k = len(sources)
    w = list(prior0) if prior0 is not None else [1.0 / k] * k
    m = mixture(w, sources)
    lower = mutual_info_bits(w, sources)
    upper = max(kl_bits(p, m) for p in sources)
    for _ in range(iterations):
        m = mixture(w, sources)
        d = [kl_bits(p, m) for p in sources]
        lower = sum(wi * di for wi, di in zip(w, d))
        upper = max(d)
        new = [wi * (2.0 ** di) for wi, di in zip(w, d)]
        z = sum(new)
        w = [v / z for v in new]
        if upper - lower < tol:
            break
    m = mixture(w, sources)
    d = [kl_bits(p, m) for p in sources]
    lower = sum(wi * di for wi, di in zip(w, d))
    upper = max(d)
    return 0.5 * (lower + upper), w, m, lower, upper


# ----------------------------------------------------------------------------
# Source-class constructors
# ----------------------------------------------------------------------------

def shift_class(p0: Sequence[float]) -> Matrix:
    """Unknown-offset class over Z/|A|:  p_theta(x) = p0(x - theta)."""
    n = len(p0)
    return [[p0[(x - theta) % n] for x in range(n)] for theta in range(n)]


def iid_binary_class(n: int, params: Sequence[float]) -> Matrix:
    """The i.i.d. Bernoulli(t) laws on {0,1}^n, messages indexed by 0..2^n-1."""
    out: Matrix = []
    for t in params:
        row: Vector = []
        for code in range(2 ** n):
            ones = bin(code).count("1")
            row.append((t ** ones) * ((1.0 - t) ** (n - ones)))
        out.append(row)
    return out


def log_binom(n: int, k: int) -> float:
    return math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)


def binomial_law(n: int, t: float) -> Vector:
    """Law of the number of ones -- the sufficient statistic of Bernoulli(t) on n bits."""
    return [math.exp(log_binom(n, k) + k * math.log(t) + (n - k) * math.log1p(-t))
            for k in range(n + 1)]


def tensor_class(s: Matrix, t: Matrix) -> Matrix:
    """The product class: independent blocks, parameters range over pairs."""
    out: Matrix = []
    for ps in s:
        for pt in t:
            out.append([a * b for a in ps for b in pt])
    return out


def smooth_class(sources: Matrix, eps: float) -> Matrix:
    """eps-smoothing: (1-eps) p_theta + eps * uniform, making the class positive."""
    n = len(sources[0])
    return [[(1.0 - eps) * pi + eps / n for pi in p] for p in sources]


# ----------------------------------------------------------------------------
# Parses: pushforward, chain rule and the parse defect
# ----------------------------------------------------------------------------

def pushforward(f: Callable[[int], int], p: Sequence[float], n_out: int) -> Vector:
    """(f_* p)(y) = sum_{x : f(x)=y} p(x)."""
    out = [0.0] * n_out
    for x, px in enumerate(p):
        out[f(x)] += px
    return out


def parse_defect(
    f: Callable[[int], int], p: Sequence[float], q: Sequence[float], n_out: int
) -> float:
    """The within-fibre defect D(p || q | f) = D(p||q) - D(f_*p || f_*q).

    By the chain rule this equals the divergence between the conditional laws of
    p and q inside the fibres of f, so it is >= 0, and it vanishes exactly when f
    is a sufficient statistic (Fisher-Neyman factorisation).
    """
    fp = pushforward(f, p, n_out)
    fq = pushforward(f, q, n_out)
    return kl_bits(p, q) - kl_bits(fp, fq)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_saddle_point() -> None:
    banner("1-3. Capacity, saddle point, equalizer property, uniqueness")
    sources: Matrix = [
        [0.70, 0.20, 0.10],
        [0.10, 0.70, 0.20],
        [0.25, 0.25, 0.50],
    ]
    cap, w, m, lo, hi = blahut_arimoto(sources)
    print(f"capacity C            = {cap:.10f} bits")
    print(f"certified bracket     = [{lo:.10f}, {hi:.10f}]  (width {hi - lo:.2e})")
    print(f"optimal prior w*      = [" + ", ".join(f"{x:.6f}" for x in w) + "]")
    print(f"optimal mixture m*    = [" + ", ".join(f"{x:.6f}" for x in m) + "]")
    print()
    print("Saddle point: every source is within C bits of the optimal mixture,")
    print("and every source with positive prior weight pays EXACTLY C (equalizer):")
    for i, p in enumerate(sources):
        print(f"   D(p_{i} || m*) = {kl_bits(p, m):.10f}   w*_{i} = {w[i]:.6f}")
    max_dev = max(abs(kl_bits(p, m) - cap) for p, wi in zip(sources, w) if wi > 1e-9)
    print(f"   max |D - C| over the support of w* = {max_dev:.2e}")
    print()
    print("No coding distribution beats C against all sources.  Random probe:")
    worst_over_random = 0.0
    rng_state = 12345
    for _ in range(2000):
        # a tiny deterministic LCG keeps the script dependency-free
        rng_state = (1103515245 * rng_state + 12345) % (2 ** 31)
        a = (rng_state % 1000 + 1) / 1000.0
        rng_state = (1103515245 * rng_state + 12345) % (2 ** 31)
        b = (rng_state % 1000 + 1) / 1000.0
        rng_state = (1103515245 * rng_state + 12345) % (2 ** 31)
        c = (rng_state % 1000 + 1) / 1000.0
        z = a + b + c
        q = [a / z, b / z, c / z]
        val = max(kl_bits(p, q) for p in sources)
        if worst_over_random == 0.0 or val < worst_over_random:
            worst_over_random = val
    print(f"   best max-redundancy over 2000 random codes = {worst_over_random:.6f}")
    print(f"   capacity (the true minimum)                = {cap:.6f}")
    print()
    print("Uniqueness of the optimal mixture (two different starting priors):")
    _, w1, m1, _, _ = blahut_arimoto(sources, prior0=[0.98, 0.01, 0.01])
    _, w2, m2, _, _ = blahut_arimoto(sources, prior0=[0.01, 0.01, 0.98])
    print("   m* from prior A = [" + ", ".join(f"{x:.8f}" for x in m1) + "]")
    print("   m* from prior B = [" + ", ".join(f"{x:.8f}" for x in m2) + "]")
    print(f"   sup-norm difference = {max(abs(a - b) for a, b in zip(m1, m2)):.2e}")


def demo_chi_squared_bound() -> None:
    banner("Analytic tool: the chi-squared bound driving the perturbation proof")
    base = [0.5, 0.3, 0.2]
    other = [0.1, 0.1, 0.8]
    print("   t        D(m_t || m*)      t^2 chi^2 / ln 2      ratio")
    for t in (0.5, 0.2, 0.1, 0.05, 0.01, 0.001):
        mt = [(1 - t) * b + t * o for b, o in zip(base, other)]
        d = kl_bits(mt, base)
        bound = t * t * chi_squared(other, base) / LOG2
        ratio = d / bound if bound > 0 else float("nan")
        print(f"  {t:<7.3f}  {d:<16.10f}  {bound:<18.10f}  {ratio:.4f}")
    print("The divergence is O(t^2): the linear term of the perturbation wins.")


def demo_shift_class() -> None:
    banner("4-5. Unknown-offset classes: closed forms and the average/worst gap")
    examples: List[Tuple[str, Vector]] = [
        ("Bernoulli(3/4) on Z/2", [0.75, 0.25]),
        ("skewed law on Z/3", [0.6, 0.3, 0.1]),
        ("near-uniform on Z/4", [0.30, 0.26, 0.24, 0.20]),
        ("spiky law on Z/4", [0.85, 0.05, 0.05, 0.05]),
    ]
    print(f"{'class':<24}{'C (numeric)':>14}{'log2|A|-H':>14}"
          f"{'worst':>12}{'gap':>12}{'H-Hmin':>12}")
    for name, p0 in examples:
        cls = shift_class(p0)
        cap, _, _, _, _ = blahut_arimoto(cls)
        closed = math.log2(len(p0)) - entropy_bits(p0)
        worst = math.log2(shtarkov_sum(cls))
        gap = worst - cap
        predicted_gap = entropy_bits(p0) - min_entropy_bits(p0)
        print(f"{name:<24}{cap:>14.8f}{closed:>14.8f}"
              f"{worst:>12.8f}{gap:>12.8f}{predicted_gap:>12.8f}")
    print()
    print("The explicit two-source class {(3/4,1/4), (1/4,3/4)}:")
    cls = shift_class([0.75, 0.25])
    cap, _, _, _, _ = blahut_arimoto(cls)
    print(f"   average price C        = {cap:.10f}   "
          f"(3/4)log2 3 - 1 = {0.75 * math.log2(3) - 1:.10f}")
    worst = math.log2(shtarkov_sum(cls))
    print(f"   worst-case price       = {worst:.10f}   "
          f"log2 3 - 1      = {math.log2(3) - 1:.10f}")
    print(f"   gap                    = {worst - cap:.10f}   "
          f"(1/4) log2 3    = {0.25 * math.log2(3):.10f}")
    print("   The worst-case theory overcharges an average-case coder ~3x here.")


def demo_additivity() -> None:
    banner("6. Additivity of the price over independent blocks")
    s = shift_class([0.75, 0.25])
    t = shift_class([0.6, 0.3, 0.1])
    cs, _, _, _, _ = blahut_arimoto(s)
    ct, _, _, _, _ = blahut_arimoto(t)
    cst, _, _, _, _ = blahut_arimoto(tensor_class(s, t))
    print(f"   C(S)          = {cs:.10f}")
    print(f"   C(T)          = {ct:.10f}")
    print(f"   C(S (x) T)    = {cst:.10f}")
    print(f"   C(S) + C(T)   = {cs + ct:.10f}   (difference {abs(cst - cs - ct):.2e})")
    print("   No universality discount is available across independent data.")


def demo_model_selection() -> None:
    banner("7. Model selection: merging K classes costs at most log2 K bits")
    classes: List[Matrix] = [
        shift_class([0.75, 0.25, 0.0 + 1e-12, 1e-12]),
        [[0.7, 0.1, 0.1, 0.1], [0.1, 0.7, 0.1, 0.1]],
        [[0.1, 0.1, 0.7, 0.1], [0.1, 0.1, 0.1, 0.7]],
    ]
    classes = [smooth_class(c, 1e-6) for c in classes]
    caps = [blahut_arimoto(c)[0] for c in classes]
    merged: Matrix = [row for c in classes for row in c]
    cmerged, _, _, _, _ = blahut_arimoto(merged)
    k = len(classes)
    b = max(caps)
    print("   specialised prices C_i = [" + ", ".join(f"{c:.6f}" for c in caps) + "]")
    print(f"   merged price C(Sigma)  = {cmerged:.6f}")
    print(f"   lower bound max_i C_i  = {b:.6f}      (satisfied: {b <= cmerged + 1e-9})")
    print(f"   upper bound B + log2 K = {b + math.log2(k):.6f}  "
          f"(satisfied: {cmerged <= b + math.log2(k) + 1e-9})")
    print("   Specialisation can move at most log2 K bits into the decompressor.")


def demo_sufficiency() -> None:
    banner("8. Data processing and sufficiency: which front ends are free?")
    n = 4
    params = [0.25, 0.5, 0.75]
    cls = iid_binary_class(n, params)

    def count_ones(code: int) -> int:
        return bin(code).count("1")

    def first_bit(code: int) -> int:
        return code & 1

    cap_full, w, m, _, _ = blahut_arimoto(cls)
    push_type = [pushforward(count_ones, p, n + 1) for p in cls]
    cap_type, _, _, _, _ = blahut_arimoto(push_type)
    push_first = [pushforward(first_bit, p, 2) for p in cls]
    cap_first, _, _, _, _ = blahut_arimoto(push_first)

    print(f"   raw class on 2^{n} = {2 ** n} messages:  C = {cap_full:.10f}")
    print(f"   parsed by the TYPE (count of ones):  C = {cap_type:.10f}")
    print(f"   parsed by the FIRST BIT only:        C = {cap_first:.10f}")
    print()
    print("   Parse defect  D(p_theta || m* | f)  (0 <=> sufficient statistic):")
    for i, p in enumerate(cls):
        d_type = parse_defect(count_ones, p, m, n + 1)
        d_first = parse_defect(first_bit, p, m, 2)
        print(f"      t = {params[i]:<5}  type: {d_type:.3e}     first bit: {d_first:.6f}")
    print()
    print("   The type is a sufficient statistic: zero defect, capacity preserved.")
    print("   The first bit destroys information: positive defect, capacity drops.")
    avg_defect = sum(wi * parse_defect(first_bit, p, m, 2) for wi, p in zip(w, cls))
    print(f"   average defect of the lossy parse = {avg_defect:.6f} bits")
    print(f"   sandwich: C(f_*S) = {cap_first:.6f} <= C(S) = {cap_full:.6f}"
          f" <= C(f_*S) + defect = {cap_first + avg_defect:.6f}")


def demo_rates() -> None:
    banner("9. Rissanen rates: how the price grows with message length n")
    print("   Bernoulli families on n bits: capacity vs the bound log2(n+1)")
    print(f"{'n':>4}{'#params':>9}{'C (numeric)':>16}{'log2(n+1)':>14}"
          f"{'(1/2)log2 n':>14}")
    for n in (2, 4, 6, 8, 10, 12):
        params = [(2 * j + 1) / (2 * (n + 1)) for j in range(n + 1)]
        cls = iid_binary_class(n, params)
        # push forward to the sufficient statistic (count of ones) to keep it cheap
        push = [pushforward(lambda c: bin(c).count("1"), p, n + 1) for p in cls]
        cap, _, _, _, _ = blahut_arimoto(push, iterations=6000)
        print(f"{n:>4}{len(params):>9}{cap:>16.8f}{math.log2(n + 1):>14.8f}"
              f"{0.5 * math.log2(n):>14.8f}")
    print()
    print("   Larger n, computed directly on the sufficient statistic (the count of")
    print("   ones), with the family refined as K ~ 3 sqrt(n) parameters:")
    print(f"{'n':>8}{'K':>6}{'C':>13}{'(1/2)log2 n':>14}{'log2(n+1)':>13}")
    pts: List[Tuple[float, float]] = []
    for n in (32, 64, 128, 256, 512):
        k = max(8, int(3 * math.sqrt(n)))
        rows = [binomial_law(n, (2 * j + 1) / (2 * k)) for j in range(k)]
        cap, _, _, _, _ = blahut_arimoto(rows, iterations=250)
        pts.append((math.log2(n), cap))
        print(f"{n:>8}{k:>6}{cap:>13.6f}{0.5 * math.log2(n):>14.6f}"
              f"{math.log2(n + 1):>13.6f}")
    slope = (pts[-1][1] - pts[0][1]) / (pts[-1][0] - pts[0][0])
    print(f"   empirical slope in log2 n = {slope:.4f}   (theory 1/2, bracket [15/32, 1])")
    print()
    print("   The numeric capacity tracks (1/2) log2 n, comfortably inside the")
    print("   proved bracket  (15/32) log2 n - 8  <=  C  <=  log2(n+1)  (n >= 64):")
    print(f"{'n':>10}{'lower (15/32)log2 n - 8':>28}{'upper log2(n+1)':>20}")
    for n in (64, 256, 4096, 10 ** 6, 10 ** 9):
        lo = (15 / 32) * math.log2(n) - 8
        hi = math.log2(n + 1)
        print(f"{n:>10}{lo:>28.4f}{hi:>20.4f}")


def demo_bernoulli_packing() -> None:
    banner("9b. The Chebyshev packing behind the lower bound")
    print("   At scale k = floor(sqrt n) the packing uses the parameters")
    print("   t_j = (4j+2)/k for j < floor(k/4).  Their count-windows")
    print("   |N - n t_j| < 2n/k are pairwise disjoint and each carries")
    print("   mass >= 15/16 by Chebyshev, so the sources are distinguishable.")
    print()
    print(f"{'n':>8}{'k':>6}{'#sources':>10}{'window half-width':>20}"
          f"{'mean spacing':>15}{'disjoint':>10}")
    for n in (64, 256, 1024, 10 ** 4, 10 ** 6):
        k = math.isqrt(n)
        count = k // 4
        half = 2.0 * n / k
        spacing = 4.0 * n / k
        # windows are disjoint iff spacing >= 2 * half
        ok = spacing >= 2 * half - 1e-9
        print(f"{n:>8}{k:>6}{count:>10}{half:>20.2f}{spacing:>15.2f}{str(ok):>10}")
    print()
    print("   Chebyshev mass check: variance n t (1-t) <= n/4, window radius 2n/k,")
    print("   so the tail probability is at most (n/4)/(2n/k)^2 = k^2/(16 n) <= 1/16.")
    for n in (64, 1024, 10 ** 6):
        k = math.isqrt(n)
        tail = (k * k) / (16.0 * n)
        print(f"      n = {n:<9} k = {k:<5} tail bound = {tail:.6f} "
              f"(mass >= {1 - tail:.6f})")


def demo_kraft_operational() -> None:
    banner("10. Operational form: real prefix codes lose between C and C+1 bits")
    cls = shift_class([0.6, 0.25, 0.1, 0.05])
    cap, w, m, _, _ = blahut_arimoto(cls)
    lengths = [math.ceil(math.log2(1.0 / mx)) for mx in m]
    kraft = sum(2.0 ** (-L) for L in lengths)
    print(f"   capacity C          = {cap:.8f} bits")
    print(f"   Shannon code of m*  = {lengths}   (Kraft sum {kraft:.6f} <= 1)")
    print()
    print(f"{'source':>8}{'H(p)':>12}{'E[len]':>12}{'excess':>12}"
          f"{'C':>10}{'C+1':>10}")
    for i, p in enumerate(cls):
        h = entropy_bits(p)
        avg = sum(pi * L for pi, L in zip(p, lengths))
        print(f"{i:>8}{h:>12.6f}{avg:>12.6f}{avg - h:>12.6f}"
              f"{cap:>10.6f}{cap + 1:>10.6f}")
    print("   Every source's excess lies in [0, C+1]; and by the converse, no Kraft")
    print("   code can have excess below C on all sources simultaneously.")


def main() -> None:
    print(__doc__)
    demo_saddle_point()
    demo_chi_squared_bound()
    demo_shift_class()
    demo_additivity()
    demo_model_selection()
    demo_sufficiency()
    demo_rates()
    demo_bernoulli_packing()
    demo_kraft_operational()
    banner("Summary")
    print("The price of universality equals the capacity of the source class.")
    print("It is unique, additive, positive, monotone, at most log2 |Theta|,")
    print("at most the worst-case (Shtarkov) price, a function of the sufficient")
    print("statistic alone, and of order log2 n for parametric families -- so")
    print("specialised decompressors can move only O(log n) bits per message.")


if __name__ == "__main__":
    main()
