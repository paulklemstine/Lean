"""
The Price of Universality — numerical demonstrations.

This self-contained script illustrates, numerically, every main result of the
accompanying paper:

  1. Redundancy is a relative entropy, and the Shannon code of a source costs
     at most one bit above its entropy.
  2. The compensation identity
         sum_theta pi(theta) D(p_theta || q) = I(pi) + D(mixture || q)
     and the redundancy-capacity lower bound it implies.
  3. The exact worst-case price: minimax pointwise regret = log2 S, where
         S = sum_a max_theta p_theta(a)
     is the Shtarkov sum, attained by the normalised maximum likelihood (NML)
     distribution.  Verified by random search over competitor codes.
  4. Structure of S:  1 <= S <= m;  S = m iff disjoint supports;
     S = 1 + TV for two-source classes;  S multiplies over independent
     components.
  5. The memoryless binary class of block length n:
         sqrt(n)/4  <=  S_n  <=  n + 1,
     hence  (1/2) log2 n - 2  <=  regret  <=  log2(n+1),
     together with the Chebyshev window certificate used in the proof.
  6. The k-parameter Rissanen rate and its unboundedness in k.
  7. The exact price of specialising to a subclass.

Only the Python standard library is used.  Run with:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, List, Sequence, Tuple

Distribution = Sequence[float]
SourceClass = Sequence[Distribution]


# ---------------------------------------------------------------------------
# 1.  Basic information quantities (all in bits)
# ---------------------------------------------------------------------------

def entropy(p: Distribution) -> float:
    """Shannon entropy H(p) = -sum p(a) log2 p(a), in bits."""
    return -sum(x * math.log2(x) for x in p if x > 0.0)


def kl_divergence(p: Distribution, q: Distribution) -> float:
    """Relative entropy D(p || q) in bits; terms with p(a) = 0 contribute 0."""
    total = 0.0
    for x, y in zip(p, q):
        if x > 0.0:
            total += x * math.log2(x / y)
    return total


def expected_length(p: Distribution, lengths: Sequence[int]) -> float:
    """Expected code length sum_a p(a) L(a)."""
    return sum(x * L for x, L in zip(p, lengths))


def redundancy(p: Distribution, lengths: Sequence[int]) -> float:
    """R(p, L) = E_p[L] - H(p)."""
    return expected_length(p, lengths) - entropy(p)


def kraft_sum(lengths: Sequence[int]) -> float:
    """Kraft sum sum_a 2^{-L(a)}; a code requires this to be at most 1."""
    return sum(2.0 ** (-L) for L in lengths)


def shannon_code(p: Distribution) -> List[int]:
    """Shannon code lengths ceil(log2(1/p(a))) for a strictly positive p."""
    return [max(0, math.ceil(-math.log2(x))) for x in p]


# ---------------------------------------------------------------------------
# 2.  Class-level quantities
# ---------------------------------------------------------------------------

def envelope(cls: SourceClass) -> List[float]:
    """Maximum-likelihood envelope  a |-> max_theta p_theta(a)."""
    return [max(p[a] for p in cls) for a in range(len(cls[0]))]


def shtarkov_sum(cls: SourceClass) -> float:
    """S = sum_a max_theta p_theta(a)."""
    return sum(envelope(cls))


def nml(cls: SourceClass) -> List[float]:
    """Normalised maximum likelihood distribution: envelope / S."""
    env = envelope(cls)
    S = sum(env)
    return [e / S for e in env]


def mixture(prior: Distribution, cls: SourceClass) -> List[float]:
    """Bayes mixture sum_theta pi(theta) p_theta."""
    return [sum(w * p[a] for w, p in zip(prior, cls)) for a in range(len(cls[0]))]


def mutual_information(prior: Distribution, cls: SourceClass) -> float:
    """I(pi) = sum_theta pi(theta) D(p_theta || mixture)."""
    mix = mixture(prior, cls)
    return sum(w * kl_divergence(p, mix) for w, p in zip(prior, cls))


def total_variation(p: Distribution, q: Distribution) -> float:
    """TV(p, q) = (1/2) sum_a |p(a) - q(a)|."""
    return 0.5 * sum(abs(x - y) for x, y in zip(p, q))


def worst_case_regret(cls: SourceClass, q: Distribution) -> float:
    """max over messages a and sources theta of log2( p_theta(a) / q(a) )."""
    worst = -math.inf
    for a in range(len(q)):
        best = max(p[a] for p in cls)
        if best > 0.0:
            worst = max(worst, math.log2(best / q[a]))
    return worst


def product_class(cls1: SourceClass, cls2: SourceClass) -> List[List[float]]:
    """Independent product: parameters pair up and probabilities multiply."""
    return [
        [x * y for x in p for y in r]
        for p in cls1
        for r in cls2
    ]


# ---------------------------------------------------------------------------
# 3.  The memoryless binary class of block length n
# ---------------------------------------------------------------------------

def log_binomial_coefficient(n: int, k: int) -> float:
    """log2 C(n, k), computed stably through log-gamma."""
    return (math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)) / math.log(2.0)


def log2_binomial_weight(n: int, t: float, k: int) -> float:
    """log2 of C(n,k) t^k (1-t)^{n-k}, with the usual 0^0 = 1 convention."""
    out = log_binomial_coefficient(n, k)
    if k > 0:
        if t <= 0.0:
            return -math.inf
        out += k * math.log2(t)
    if n - k > 0:
        if t >= 1.0:
            return -math.inf
        out += (n - k) * math.log2(1.0 - t)
    return out


def binomial_weight(n: int, t: float, k: int) -> float:
    """C(n,k) t^k (1-t)^{n-k}."""
    lw = log2_binomial_weight(n, t, k)
    return 0.0 if lw == -math.inf else 2.0 ** lw


def bernoulli_shtarkov_sum(n: int) -> float:
    """
    Exact Shtarkov sum of the memoryless binary class of block length n:

        S_n = sum_{k=0}^{n} C(n,k) (k/n)^k (1 - k/n)^{n-k},

    since the maximum-likelihood bias for a string with k ones is k/n and the
    envelope depends on the string only through k.  Cost: Theta(n).
    """
    return sum(binomial_weight(n, k / n, k) for k in range(n + 1))


def chebyshev_window_certificate(n: int) -> Tuple[float, int, int]:
    """
    The disjoint-window lower-bound certificate from the proof.

    Half-width d = floor(sqrt(n)) + 1, centres c_i = 2 d i <= n, windows
    K_i = { k : |k - c_i| < d }.  Returns (certified lower bound on S_n,
    number of windows, d).  Each window mass is >= 3/4 by Chebyshev.
    """
    d = math.isqrt(n) + 1
    total = 0.0
    windows = 0
    i = 0
    while 2 * d * i <= n:
        c = 2 * d * i
        t = c / n
        total += sum(
            binomial_weight(n, t, k)
            for k in range(max(0, c - d + 1), min(n, c + d - 1) + 1)
        )
        windows += 1
        i += 1
    return total, windows, d


# ---------------------------------------------------------------------------
# 4.  Reporting helpers
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def check(label: str, condition: bool) -> None:
    print(f"   [{'OK ' if condition else 'FAIL'}] {label}")


# ---------------------------------------------------------------------------
# Demonstration 1: the specialist costs at most one bit
# ---------------------------------------------------------------------------

def demo_specialist_baseline() -> None:
    banner("1.  A code that knows the source pays at most one bit above entropy")
    random.seed(20260818)
    for trial in range(3):
        raw = [random.random() + 0.05 for _ in range(6)]
        Z = sum(raw)
        p = [x / Z for x in raw]
        L = shannon_code(p)
        r = redundancy(p, L)
        kl = kl_divergence(p, [2.0 ** (-x) for x in L])
        print(f"   trial {trial}:  H(p) = {entropy(p):.4f} bits,"
              f"  E[L] = {expected_length(p, L):.4f},  R = {r:.4f}")
        check("Kraft inequality holds", kraft_sum(L) <= 1.0 + 1e-12)
        check("redundancy equals D(p || 2^-L)", abs(r - kl) < 1e-9)
        check("redundancy in [0, 1]", -1e-12 <= r <= 1.0 + 1e-12)


# ---------------------------------------------------------------------------
# Demonstration 2: compensation identity and redundancy-capacity
# ---------------------------------------------------------------------------

def demo_compensation_identity() -> None:
    banner("2.  Compensation identity and the redundancy-capacity lower bound")
    random.seed(11)
    alphabet, m = 7, 4
    cls: List[List[float]] = []
    for _ in range(m):
        raw = [random.random() + 0.05 for _ in range(alphabet)]
        Z = sum(raw)
        cls.append([x / Z for x in raw])
    prior = [random.random() + 0.1 for _ in range(m)]
    Zp = sum(prior)
    prior = [w / Zp for w in prior]

    L = shannon_code(mixture(prior, cls))
    q = [2.0 ** (-x) for x in L]

    lhs = sum(w * kl_divergence(p, q) for w, p in zip(prior, cls))
    I = mutual_information(prior, cls)
    rhs = I + kl_divergence(mixture(prior, cls), q)
    print(f"   average divergence to the code   = {lhs:.6f} bits")
    print(f"   mutual information I(pi)         = {I:.6f} bits")
    print(f"   + divergence of mixture to code  = {rhs:.6f} bits")
    check("compensation identity holds", abs(lhs - rhs) < 1e-9)

    worst = max(redundancy(p, L) for p in cls)
    print(f"   worst redundancy over the class  = {worst:.6f} bits  (>= I(pi))")
    check("some source pays at least I(pi)", worst >= I - 1e-9)

    m_uniform = mixture([1.0 / m] * m, cls)
    Lu = shannon_code(m_uniform)
    worst_u = max(redundancy(p, Lu) for p in cls)
    print(f"   mixture code, worst redundancy   = {worst_u:.6f}"
          f"   (bound log2 m + 1 = {math.log2(m) + 1:.6f})")
    check("mixture code meets the log2 m + 1 bound", worst_u <= math.log2(m) + 1 + 1e-9)


# ---------------------------------------------------------------------------
# Demonstration 3: exact minimax regret = log2 S
# ---------------------------------------------------------------------------

def demo_exact_minimax() -> None:
    banner("3.  Exact worst-case price: minimax pointwise regret = log2 S")
    random.seed(2718)
    alphabet, m = 8, 5
    cls: List[List[float]] = []
    for _ in range(m):
        raw = [random.random() ** 2 + 0.02 for _ in range(alphabet)]
        Z = sum(raw)
        cls.append([x / Z for x in raw])

    S = shtarkov_sum(cls)
    p_nml = nml(cls)
    print(f"   Shtarkov sum S            = {S:.6f}   (1 <= S <= m = {m})")
    print(f"   exact minimax regret      = {math.log2(S):.6f} bits")
    check("1 <= S <= m", 1.0 - 1e-12 <= S <= m + 1e-12)
    check("NML attains regret exactly log2 S",
          abs(worst_case_regret(cls, p_nml) - math.log2(S)) < 1e-9)

    # No competitor can beat NML: random search over coding distributions.
    best_rival = math.inf
    for _ in range(20000):
        raw = [random.random() + 1e-3 for _ in range(alphabet)]
        Z = sum(raw)
        q = [x / Z for x in raw]
        best_rival = min(best_rival, worst_case_regret(cls, q))
    print(f"   best of 20000 random rivals = {best_rival:.6f} bits"
          f"  (never below {math.log2(S):.6f})")
    check("converse verified against random competitors",
          best_rival >= math.log2(S) - 1e-9)


# ---------------------------------------------------------------------------
# Demonstration 4: structure of the Shtarkov sum
# ---------------------------------------------------------------------------

def demo_structure() -> None:
    banner("4.  Structure of the Shtarkov sum: rigidity, total variation, additivity")

    # (a) Rigidity: disjoint supports <=> S = m.
    m = 6
    deterministic = [[1.0 if a == t else 0.0 for a in range(m)] for t in range(m)]
    print(f"   deterministic class of {m} sources:  S = {shtarkov_sum(deterministic):.6f}"
          f"  (= m, so price = log2 m = {math.log2(m):.4f} bits)")
    check("S = m for perfectly distinguishable sources",
          abs(shtarkov_sum(deterministic) - m) < 1e-12)

    overlapping = [[0.7, 0.3, 0.0], [0.0, 0.4, 0.6], [0.2, 0.2, 0.6]]
    print(f"   overlapping class of 3 sources:    S = {shtarkov_sum(overlapping):.6f}"
          f"  (< 3: overlap is a discount)")
    check("S < m strictly when supports overlap", shtarkov_sum(overlapping) < 3.0 - 1e-9)

    # (b) Two sources: S = 1 + TV.
    print()
    print("   two-source classes:   TV      S        1 + TV    price log2(1+TV)")
    for eps in (0.0, 0.2, 0.5, 0.8, 1.0):
        p0 = [0.5 + 0.5 * eps, 0.5 - 0.5 * eps]
        p1 = [0.5 - 0.5 * eps, 0.5 + 0.5 * eps]
        cls2 = [p0, p1]
        tv = total_variation(p0, p1)
        S2 = shtarkov_sum(cls2)
        print(f"                        {tv:5.3f}  {S2:7.4f}  {1 + tv:7.4f}"
              f"   {math.log2(S2):7.4f}")
        check(f"S = 1 + TV at eps = {eps}", abs(S2 - (1 + tv)) < 1e-12)

    # (c) Multiplicativity over independent components.
    print()
    random.seed(5)
    def rand_class(alpha: int, k: int) -> List[List[float]]:
        out = []
        for _ in range(k):
            raw = [random.random() + 0.05 for _ in range(alpha)]
            Z = sum(raw)
            out.append([x / Z for x in raw])
        return out

    A_cls, B_cls = rand_class(4, 3), rand_class(5, 2)
    SA, SB = shtarkov_sum(A_cls), shtarkov_sum(B_cls)
    SAB = shtarkov_sum(product_class(A_cls, B_cls))
    print(f"   S(A) = {SA:.6f},  S(B) = {SB:.6f},  S(A x B) = {SAB:.6f}"
          f"  (product = {SA * SB:.6f})")
    check("S multiplies over independent components", abs(SAB - SA * SB) < 1e-9)
    check("log2 S adds over independent components",
          abs(math.log2(SAB) - (math.log2(SA) + math.log2(SB))) < 1e-9)


# ---------------------------------------------------------------------------
# Demonstration 5: the memoryless binary class and the (1/2) log n rate
# ---------------------------------------------------------------------------

def demo_bernoulli_rate() -> None:
    banner("5.  Memoryless binary class: (1/2) log2 n - 2  <=  regret  <=  log2(n+1)")
    print("     n        S_n     log2 S_n    lower bd    upper bd   cert(S_n)  windows")
    for n in (1, 4, 16, 64, 256, 1024, 4096, 16384):
        S = bernoulli_shtarkov_sum(n)
        lower = 0.5 * math.log2(n) - 2 if n >= 1 else 0.0
        upper = math.log2(n + 1)
        cert, windows, _d = chebyshev_window_certificate(n)
        print(f"  {n:6d}  {S:9.4f}   {math.log2(S):8.4f}   {lower:9.4f}"
              f"   {upper:9.4f}   {cert:9.4f}   {windows:6d}")
        check(f"n = {n}: sqrt(n)/4 <= S_n <= n+1",
              math.sqrt(n) / 4 - 1e-9 <= S <= n + 1 + 1e-9)
        check(f"n = {n}: certified window mass is a valid lower bound",
              cert <= S + 1e-9)
        check(f"n = {n}: regret between the two bounds",
              lower - 1e-9 <= math.log2(S) <= upper + 1e-9)

    # The true growth: log2 S_n - (1/2) log2 n should settle near a constant,
    # consistent with the conjectured S_n ~ sqrt(pi n / 2).
    print()
    print("   log2 S_n - (1/2) log2 n   (conjectured limit (1/2) log2(pi/2)"
          f" = {0.5 * math.log2(math.pi / 2):.5f}):")
    for n in (256, 1024, 4096, 16384, 65536):
        S = bernoulli_shtarkov_sum(n)
        print(f"      n = {n:6d}:  {math.log2(S) - 0.5 * math.log2(n): .5f}")


# ---------------------------------------------------------------------------
# Demonstration 6: k independent blocks
# ---------------------------------------------------------------------------

def demo_k_parameter_rate() -> None:
    banner("6.  k independent blocks: the price is additive, hence unbounded in k")
    n = 1024
    S = bernoulli_shtarkov_sum(n)
    print(f"   one block of n = {n}:  log2 S_n = {math.log2(S):.4f} bits")
    print("      k    k*log2 S_n   lower bd k(0.5 log2 n - 2)   upper bd k log2(n+1)")
    for k in (1, 2, 4, 8, 64, 1024):
        exact = k * math.log2(S)
        lower = k * (0.5 * math.log2(n) - 2)
        upper = k * math.log2(n + 1)
        print(f"   {k:6d}   {exact:10.3f}   {lower:23.3f}   {upper:20.3f}")
        check(f"k = {k}: two-sided rate holds", lower - 1e-9 <= exact <= upper + 1e-9)

    target = 10_000.0
    k_needed = math.ceil(target / (0.5 * math.log2(n) - 2))
    print(f"   to force > {target:.0f} bits of regret at n = {n}: k = {k_needed} blocks suffice")


# ---------------------------------------------------------------------------
# Demonstration 7: the exact price of specialisation
# ---------------------------------------------------------------------------

def demo_specialisation() -> None:
    banner("7.  What specialising to a subclass is worth")
    m = 8
    full = [[1.0 if a == t else 0.0 for a in range(m)] for t in range(m)]
    sub = [full[0]]  # specialise to a single source
    S_full, S_sub = shtarkov_sum(full), shtarkov_sum(sub)
    saving = math.log2(S_full / S_sub)
    nml_full, nml_sub = nml(full), nml(sub)
    observed = math.log2(nml_sub[0]) - math.log2(nml_full[0])
    print(f"   full class:  S = {S_full:.4f};  subclass:  S = {S_sub:.4f}")
    print(f"   predicted saving log2(S/S') = {saving:.4f} bits")
    print(f"   observed pointwise saving   = {observed:.4f} bits")
    check("saving equals log2(S/S') where the MLE lies in the subclass",
          abs(observed - saving) < 1e-9)

    # A parametric comparison: what fraction of the message does this buy?
    print()
    print("   parametric reality check (memoryless binary class):")
    print("        n     message bits   universality price (log2 S_n)     fraction")
    for n in (64, 1024, 16384, 1_000_000):
        if n <= 16384:
            price = math.log2(bernoulli_shtarkov_sum(n))
        else:
            price = 0.5 * math.log2(n) + 0.5 * math.log2(math.pi / 2)  # asymptotic value
        print(f"   {n:9d}   {n:12d}   {price:28.4f}   {price / n:10.6%}")


def main() -> None:
    print(__doc__)
    demo_specialist_baseline()
    demo_compensation_identity()
    demo_exact_minimax()
    demo_structure()
    demo_bernoulli_rate()
    demo_k_parameter_rate()
    demo_specialisation()
    banner("All demonstrations complete.")


if __name__ == "__main__":
    main()
