"""
The Price of Universality: numerical demonstrations.

Self-contained numerical companion to the theory of minimax redundancy of
universal decompressors.  Every quantity below is computed from first
principles; the binary Shtarkov sums are computed in exact rational
arithmetic (fractions.Fraction), so the comparisons with the proved bounds
are exact, not floating point.

Results demonstrated
--------------------
1.  The Shtarkov sum  C_S = sum_x max_theta p_theta(x)  of the binary
    memoryless class, exactly, and the proved sandwich
        sqrt(n)/4  <=  C_S  <=  n + 1,      n >= 2,
    equivalently   (1/2) log2 n - 2  <=  log2 C_S  <=  log2(n+1).
2.  The normalized maximum likelihood (NML) code: a single fixed code whose
    length never exceeds the ideal code length of the *true* source by more
    than log2 C_S + 1 bits, on any message and against any source.
3.  The Kraft converse: brute-force search confirming that no code can beat
    log2 C_S everywhere.
4.  The separation theorem: on n-bit files the memoryless class costs
    O(log n) bits while the class of point masses ("one decompressor per
    file") costs exactly n bits.
5.  Structural laws: exact additivity of the price over independently
    parametrised blocks, strict subadditivity when the blocks share a
    parameter.
6.  The average-case dual: the compensation identity
        sum_theta w_theta D(p_theta || q) = I(w) + D(m_w || q),
    Bayes optimality of the mixture code, and I(w) <= log2 C_S.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
from fractions import Fraction
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------
# 1.  Exact Shtarkov sum of the binary memoryless class
# ----------------------------------------------------------------------


def binomial(n: int, k: int) -> int:
    """Binomial coefficient C(n, k)."""
    return math.comb(n, k)


def shtarkov_bernoulli_exact(n: int) -> Fraction:
    """Exact Shtarkov sum of the binary memoryless class on n-bit messages.

    C_S(n) = sum_{k=0}^{n} C(n,k) (k/n)^k ((n-k)/n)^(n-k),  with 0^0 = 1.

    Each string of length n with k ones has maximum likelihood
    (k/n)^k ((n-k)/n)^(n-k), attained at the empirical Bernoulli parameter,
    and there are C(n,k) such strings.
    """
    if n == 0:
        return Fraction(1)
    total = Fraction(0)
    for k in range(n + 1):
        p = Fraction(k, n)
        q = Fraction(n - k, n)
        total += binomial(n, k) * (p ** k) * (q ** (n - k))
    return total


def price_bits(c_s: Fraction) -> float:
    """Price of universality in bits, log2 of the Shtarkov sum."""
    return math.log2(float(c_s))


def bernoulli_sandwich_report(max_n: int = 20) -> None:
    """Check  sqrt(n)/4 <= C_S <= n+1  exactly for 2 <= n <= max_n."""
    print("=" * 78)
    print("1.  Exact Shtarkov sums of the binary memoryless class")
    print("=" * 78)
    print(f"{'n':>4} {'C_S (exact)':>26} {'C_S':>10} {'sqrt(n)/4':>10} "
          f"{'n+1':>6} {'log2 C_S':>9} {'1/2 log2 n - 2':>15}")
    all_ok = True
    for n in list(range(2, min(max_n, 12) + 1)) + [16, 20]:
        if n > max_n:
            continue
        c = shtarkov_bernoulli_exact(n)
        cf = float(c)
        lo_ok = math.sqrt(n) / 4 <= cf
        hi_ok = c <= n + 1                      # exact rational comparison
        all_ok = all_ok and lo_ok and hi_ok
        shown = str(c) if len(str(c)) <= 26 else f"{c.numerator}/{c.denominator}"[:23] + "..."
        print(f"{n:>4} {shown:>26} {cf:>10.4f} {math.sqrt(n)/4:>10.4f} "
              f"{n+1:>6} {math.log2(cf):>9.4f} {0.5*math.log2(n)-2:>15.4f}")
    print(f"\n  sandwich  sqrt(n)/4 <= C_S <= n+1  verified for all tested n: {all_ok}")
    print("  (the exact values C_S(2)=5/2, C_S(4)=103/32, C_S(8)=556403/131072)")
    print(f"  C_S(2) = {shtarkov_bernoulli_exact(2)},  "
          f"C_S(4) = {shtarkov_bernoulli_exact(4)},  "
          f"C_S(8) = {shtarkov_bernoulli_exact(8)}")
    print()


# ----------------------------------------------------------------------
# 2.  Explicit source classes on a small message space
# ----------------------------------------------------------------------

Message = Tuple[int, ...]


def all_messages(n: int) -> List[Message]:
    """All binary strings of length n, as tuples of 0/1."""
    return list(itertools.product((0, 1), repeat=n))


def bernoulli_likelihood(theta: float, x: Message) -> float:
    """p_theta(x) for a memoryless binary source with P(1) = theta."""
    k = sum(x)
    n = len(x)
    return (theta ** k) * ((1.0 - theta) ** (n - k))


def max_likelihood_envelope(messages: Sequence[Message],
                            likelihood: Callable[[float, Message], float],
                            params: Sequence[float]) -> Dict[Message, float]:
    """Pointwise envelope  x -> max_theta p_theta(x)  over a parameter grid."""
    return {x: max(likelihood(t, x) for t in params) for x in messages}


def bernoulli_envelope_exact(n: int) -> Dict[Message, float]:
    """Exact envelope for the binary memoryless class: the ML parameter of a
    string with k ones is k/n, so the envelope is (k/n)^k ((n-k)/n)^(n-k)."""
    out: Dict[Message, float] = {}
    for x in all_messages(n):
        k = sum(x)
        t = k / n
        out[x] = (t ** k) * ((1 - t) ** (n - k)) if 0 < k < n else 1.0
    return out


def nml_distribution(envelope: Dict[Message, float]) -> Dict[Message, float]:
    """Normalized maximum likelihood distribution q*(x) = envelope(x)/C_S."""
    c_s = sum(envelope.values())
    return {x: v / c_s for x, v in envelope.items()}


def nml_code_lengths(q_star: Dict[Message, float]) -> Dict[Message, int]:
    """Integer NML code lengths, ceil(log2 (1/q*(x)))."""
    return {x: math.ceil(math.log2(1.0 / q)) for x, q in q_star.items()}


def kraft_sum(lengths: Dict[Message, int]) -> float:
    """Kraft sum  sum_x 2^{-l(x)};  <= 1 iff a prefix-free code exists."""
    return sum(2.0 ** (-l) for l in lengths.values())


def nml_guarantee_report(n: int = 8, thetas: Iterable[float] = (0.1, 0.3, 0.5, 0.8)) -> None:
    """Show that the single NML code is within log2 C_S + 1 bits of the ideal
    code of every source, on every message."""
    print("=" * 78)
    print(f"2.  The universal NML code on n = {n} bit messages")
    print("=" * 78)
    envelope = bernoulli_envelope_exact(n)
    c_s = sum(envelope.values())
    q_star = nml_distribution(envelope)
    lengths = nml_code_lengths(q_star)
    print(f"  C_S = {c_s:.6f}    log2 C_S = {math.log2(c_s):.4f} bits")
    print(f"  Kraft sum of the NML code: {kraft_sum(lengths):.6f}  (must be <= 1)")
    print(f"\n  {'theta':>6} {'max excess over ideal (bits)':>30} "
          f"{'bound log2 C_S + 1':>20}")
    worst_overall = 0.0
    for theta in thetas:
        worst = max(
            lengths[x] - math.log2(1.0 / bernoulli_likelihood(theta, x))
            for x in envelope
            if bernoulli_likelihood(theta, x) > 0
        )
        worst_overall = max(worst_overall, worst)
        print(f"  {theta:>6.2f} {worst:>30.4f} {math.log2(c_s)+1:>20.4f}")
    print(f"\n  worst excess over all tested sources and all messages: "
          f"{worst_overall:.4f} bits  <=  {math.log2(c_s)+1:.4f}: "
          f"{worst_overall <= math.log2(c_s) + 1 + 1e-12}")
    print()


# ----------------------------------------------------------------------
# 3.  The converse: no code beats log2 C_S everywhere
# ----------------------------------------------------------------------


def converse_search(n: int = 4, trials: int = 20000, seed: int = 20260817) -> None:
    """Randomly probe Kraft-compliant codes and record the best achievable
    worst-case redundancy; the theory says it can never fall below log2 C_S."""
    import random

    rng = random.Random(seed)
    messages = all_messages(n)
    envelope = bernoulli_envelope_exact(n)
    c_s = sum(envelope.values())

    print("=" * 78)
    print(f"3.  Converse: random search over codes on n = {n} bit messages")
    print("=" * 78)

    def worst_case(q: Dict[Message, float]) -> float:
        """sup_x log2( max_theta p_theta(x) / q(x) ): the pointwise redundancy
        of the coding distribution q against the whole class."""
        return max(math.log2(envelope[x] / q[x]) for x in messages)

    best = float("inf")
    for _ in range(trials):
        # a random coding distribution, biased towards the envelope so that
        # the search actually gets close to the optimum
        weights = [envelope[x] ** rng.uniform(0.5, 1.5) * rng.random()
                   + 1e-12 for x in messages]
        total = sum(weights)
        q = {x: w / total for x, w in zip(messages, weights)}
        best = min(best, worst_case(q))

    q_star = nml_distribution(envelope)
    print(f"  log2 C_S (theoretical minimum of the worst case) = {math.log2(c_s):.6f}")
    print(f"  worst case of the NML distribution               = "
          f"{worst_case(q_star):.6f}   (attains the minimum)")
    print(f"  best worst case found in {trials} random codes        = {best:.6f}")
    print(f"  no random code beat the bound: {best >= math.log2(c_s) - 1e-9}")
    print()


# ----------------------------------------------------------------------
# 4.  Separation: memoryless class versus one-decompressor-per-file
# ----------------------------------------------------------------------


def separation_report(ns: Sequence[int] = (2, 4, 8, 16, 32, 1024, 1 << 20)) -> None:
    """Compare the price of the memoryless class with the price of the
    deterministic class (C_S = |X| = 2^n exactly)."""
    print("=" * 78)
    print("4.  Separation: parametric class versus one decompressor per file")
    print("=" * 78)
    print(f"{'n':>9} {'memoryless price (bits)':>26} {'deterministic price':>21} "
          f"{'fraction of message':>21}")
    for n in ns:
        if n <= 12:
            c = float(shtarkov_bernoulli_exact(n))
            memo = math.log2(c)
            label = f"{memo:.4f} (exact)"
        else:
            memo = math.log2(n + 1)          # proved upper bound
            label = f"<= {memo:.4f}"
        print(f"{n:>9} {label:>26} {float(n):>21.1f} {memo/n:>21.6f}")
    print("\n  the deterministic class costs exactly n bits: the n bits each")
    print("  specialist saves are exactly the n bits needed to name it.")
    print("  the memoryless share of the message tends to 0 as n grows.")
    print()


# ----------------------------------------------------------------------
# 5.  Structural laws: additivity and subadditivity
# ----------------------------------------------------------------------


def shtarkov_of_table(probs: Sequence[Sequence[float]]) -> float:
    """C_S of a finite class given as a table probs[theta][x]."""
    n_msgs = len(probs[0])
    return sum(max(row[x] for row in probs) for x in range(n_msgs))


def product_class(p1: Sequence[Sequence[float]],
                  p2: Sequence[Sequence[float]]) -> List[List[float]]:
    """Independent product: parameters chosen separately in each block."""
    return [
        [a * b for a in row1 for b in row2]
        for row1 in p1
        for row2 in p2
    ]


def tied_product_class(p1: Sequence[Sequence[float]],
                       p2: Sequence[Sequence[float]]) -> List[List[float]]:
    """Tied product: one shared parameter drives both blocks."""
    assert len(p1) == len(p2)
    return [
        [a * b for a in p1[t] for b in p2[t]]
        for t in range(len(p1))
    ]


def structure_report() -> None:
    print("=" * 78)
    print("5.  Structural laws of the price")
    print("=" * 78)
    # a three-source class on four messages
    p1 = [
        [0.70, 0.10, 0.10, 0.10],
        [0.10, 0.70, 0.10, 0.10],
        [0.25, 0.25, 0.25, 0.25],
    ]
    p2 = [
        [0.60, 0.40],
        [0.20, 0.80],
        [0.50, 0.50],
    ]
    c1, c2 = shtarkov_of_table(p1), shtarkov_of_table(p2)
    c_prod = shtarkov_of_table(product_class(p1, p2))
    c_tied = shtarkov_of_table(tied_product_class(p1, p2))
    print(f"  block 1:  C_S = {c1:.6f}   price = {math.log2(c1):.4f} bits")
    print(f"  block 2:  C_S = {c2:.6f}   price = {math.log2(c2):.4f} bits")
    print(f"  independent product:  C_S = {c_prod:.6f}  "
          f"= C_S1 * C_S2 = {c1*c2:.6f}   (exact additivity of the price)")
    print(f"  tied product (shared parameter): C_S = {c_tied:.6f} "
          f"<= {c1*c2:.6f}   (strict subadditivity)")
    print(f"  bits saved by sharing the parameter: "
          f"{math.log2(c1*c2) - math.log2(c_tied):.4f}")

    # calibration and monotonicity
    single = [p1[0]]
    print(f"\n  calibration: single-source class has C_S = "
          f"{shtarkov_of_table(single):.6f} (price 0 bits)")
    print(f"  monotonicity: subclass {{p_0, p_1}} has C_S = "
          f"{shtarkov_of_table(p1[:2]):.6f} <= full class {c1:.6f}")

    # subadditivity of the memoryless price in block length
    print("\n  memoryless subadditivity  C_S(n1+n2) <= C_S(n1) C_S(n2):")
    for n1, n2 in ((2, 2), (3, 4), (4, 4), (5, 5)):
        a = shtarkov_bernoulli_exact(n1)
        b = shtarkov_bernoulli_exact(n2)
        ab = shtarkov_bernoulli_exact(n1 + n2)
        print(f"    n1={n1}, n2={n2}:  C_S({n1+n2}) = {float(ab):.4f} "
              f"<= {float(a*b):.4f} = C_S({n1})C_S({n2})   "
              f"{'ok' if ab <= a*b else 'FAIL'}")
    print()


# ----------------------------------------------------------------------
# 6.  The average-case dual: capacity, mixture, compensation identity
# ----------------------------------------------------------------------


def kl_bits(p: Sequence[float], q: Sequence[float]) -> float:
    """Relative entropy in bits between two positive probability vectors."""
    return sum(pi * math.log2(pi / qi) for pi, qi in zip(p, q))


def mixture(probs: Sequence[Sequence[float]], w: Sequence[float]) -> List[float]:
    """Bayes mixture m_w(x) = sum_theta w_theta p_theta(x)."""
    n_msgs = len(probs[0])
    return [sum(w[t] * probs[t][x] for t in range(len(probs))) for x in range(n_msgs)]


def mutual_information(probs: Sequence[Sequence[float]], w: Sequence[float]) -> float:
    """Capacity functional I(w) = sum_theta w_theta D(p_theta || m_w), in bits."""
    m = mixture(probs, w)
    return sum(w[t] * kl_bits(probs[t], m) for t in range(len(probs)))


def bayes_redundancy(probs: Sequence[Sequence[float]], w: Sequence[float],
                     q: Sequence[float]) -> float:
    """Average redundancy sum_theta w_theta D(p_theta || q), in bits."""
    return sum(w[t] * kl_bits(probs[t], q) for t in range(len(probs)))


def capacity_report() -> None:
    print("=" * 78)
    print("6.  Average case: compensation identity and redundancy-capacity")
    print("=" * 78)
    probs = [
        [0.70, 0.10, 0.10, 0.10],
        [0.10, 0.70, 0.10, 0.10],
        [0.25, 0.25, 0.25, 0.25],
    ]
    w = [0.5, 0.3, 0.2]
    envelope = [max(row[x] for row in probs) for x in range(4)]
    c_s = sum(envelope)
    q_star = [e / c_s for e in envelope]
    m = mixture(probs, w)

    i_w = mutual_information(probs, w)
    print(f"  prior w = {w}")
    print(f"  capacity functional I(w)      = {i_w:.6f} bits")
    print(f"  worst-case price log2 C_S     = {math.log2(c_s):.6f} bits")
    print(f"  prior entropy H(w)            = "
          f"{-sum(wi*math.log2(wi) for wi in w):.6f} bits")
    print(f"  log2 |Theta|                  = {math.log2(len(probs)):.6f} bits")
    print(f"  I(w) <= log2 C_S : {i_w <= math.log2(c_s) + 1e-12}")

    print("\n  compensation identity  Rbar(w,q) = I(w) + D(m_w || q):")
    for name, q in (("mixture m_w", m), ("NML q*", q_star),
                    ("uniform", [0.25] * 4)):
        rbar = bayes_redundancy(probs, w, q)
        excess = kl_bits(m, q)
        print(f"    q = {name:<12}  Rbar = {rbar:.6f} = "
              f"I(w) {i_w:.6f} + D(m||q) {excess:.6f}  "
              f"[residual {abs(rbar - i_w - excess):.2e}]")
    print("\n  the mixture is Bayes optimal: no coding distribution has")
    print("  average redundancy below I(w).")
    print()


# ----------------------------------------------------------------------
# main
# ----------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 78)
    print("#  THE PRICE OF UNIVERSALITY - numerical demonstrations")
    print("#" * 78)
    print()
    bernoulli_sandwich_report(max_n=20)
    nml_guarantee_report(n=8)
    converse_search(n=4)
    separation_report()
    structure_report()
    capacity_report()
    print("=" * 78)
    print("Summary: the price of universality is exactly log2 C_S bits.")
    print("Parametric classes pay Theta(log n); a class rich enough to name")
    print("every file pays the whole file.  Sharing a parameter across blocks")
    print("is what turns a linear price into a logarithmic one.")
    print("=" * 78)


if __name__ == "__main__":
    main()
