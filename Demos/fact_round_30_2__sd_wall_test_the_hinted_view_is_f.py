"""
demo.py -- Numerical demonstrations of the blindness-sparsity dichotomy
=======================================================================

Self-contained numerical companion to "The Blindness-Sparsity Dichotomy for
Plug-In Information Readings".

Everything here is elementary counting plus base-2 logarithms.  No third-party
dependencies; only the standard library is used.

The demonstrations, in order:

  1. FIBER DECOMPOSITION      H(l) - I(l,c) = sum_k (f_k/n) * H(rho_k)
  2. INJECTIVE LIMIT          C(c) = 0  =>  I(l,c) = H(l) exactly, for ANY label
  3. COLLISION SANDWICH       H(l) - (C/n)log2|L| <= I <= H(l), and C <= 2(n-d)
  4. POWERLESS NULL           observed, every surrogate and the null mean all
                              sit inside one interval of width (C/n)log2|L|
  5. FIBER BAND / ONE BIT     fibers of size <= 2  =>  H(l) - 1 <= I <= H(l)
  6. REFINEMENT MONOTONICITY  I(l, phi o c') <= I(l, c'), gain <= coarse
                              collision term
  7. THE DICHOTOMY            swap-closed sample: I = 0 EXACTLY while C/n = 1
  8. NULL SITS ABOVE THE DATA on a swap-closed sample the shuffle null is
                              biased upward away from the exact zero

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from collections import Counter
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

Label = Hashable
Code = Hashable

# --------------------------------------------------------------------------
# Core estimators
# --------------------------------------------------------------------------


def log2(x: float) -> float:
    """Base-2 logarithm with the information-theoretic convention log2(0)*0 = 0."""
    return math.log2(x) if x > 0.0 else 0.0


def entropy_of_counts(counts: Sequence[int]) -> float:
    """Shannon entropy in bits of the empirical distribution given by `counts`."""
    total: int = sum(counts)
    if total == 0:
        return 0.0
    return -sum((m / total) * log2(m / total) for m in counts if m > 0)


def label_entropy(labels: Sequence[Label]) -> float:
    """Empirical entropy H(l) of the label margin, in bits."""
    return entropy_of_counts(list(Counter(labels).values()))


def plug_in_mutual_information(labels: Sequence[Label], codes: Sequence[Code]) -> float:
    """The plug-in (maximum-likelihood) mutual information I-hat(l, c) in bits.

    I-hat = sum_{a,k} p(a,k) log2( p(a,k) / (p_L(a) p_K(k)) ),  p(a,k) = N_{a,k}/n.
    """
    n: int = len(labels)
    if n == 0:
        return 0.0
    cell: Counter = Counter(zip(labels, codes))
    marg_l: Counter = Counter(labels)
    marg_k: Counter = Counter(codes)
    total = 0.0
    for (a, k), nak in cell.items():
        p = nak / n
        total += p * log2(p / ((marg_l[a] / n) * (marg_k[k] / n)))
    return total


def fiber_sizes(codes: Sequence[Code]) -> Dict[Code, int]:
    """The fiber size f_k = #{i : c_i = k} for every realised code k."""
    return dict(Counter(codes))


def collision_count(codes: Sequence[Code]) -> int:
    """C(c) = #{i : f_{c_i} >= 2} = sum over colliding fibers of f_k."""
    f = fiber_sizes(codes)
    return sum(size for size in f.values() if size >= 2)


def distinct_codes(codes: Sequence[Code]) -> int:
    """The number d of distinct view values realised on the sample."""
    return len(set(codes))


def sandwich_width(labels: Sequence[Label], codes: Sequence[Code]) -> float:
    """The alphabet-based band width (C/n) * log2|L| of the collision sandwich."""
    n = len(codes)
    alphabet = max(len(set(labels)), 2)
    return (collision_count(codes) / n) * math.log2(alphabet)


def fiber_log_width(codes: Sequence[Code]) -> float:
    """The alphabet-free band width (1/n) * sum_{f_k >= 2} f_k log2 f_k."""
    n = len(codes)
    return sum(s * math.log2(s) for s in fiber_sizes(codes).values() if s >= 2) / n


def conditional_entropy_by_fiber(
    labels: Sequence[Label], codes: Sequence[Code]
) -> float:
    """sum_k (f_k / n) * H(rho_k), the right-hand side of the fiber decomposition."""
    n = len(labels)
    buckets: Dict[Code, List[Label]] = {}
    for a, k in zip(labels, codes):
        buckets.setdefault(k, []).append(a)
    return sum(
        (len(group) / n) * entropy_of_counts(list(Counter(group).values()))
        for group in buckets.values()
    )


def permutation_null(
    labels: Sequence[Label],
    codes: Sequence[Code],
    n_shuffles: int = 200,
    seed: int = 20260923,
) -> Tuple[float, float, float, List[float]]:
    """Shuffle the labels `n_shuffles` times; return (mean, sd, z, all readings)."""
    rng = random.Random(seed)
    observed = plug_in_mutual_information(labels, codes)
    shuffled = list(labels)
    readings: List[float] = []
    for _ in range(n_shuffles):
        rng.shuffle(shuffled)
        readings.append(plug_in_mutual_information(shuffled, codes))
    mean = sum(readings) / len(readings)
    var = sum((r - mean) ** 2 for r in readings) / max(len(readings) - 1, 1)
    sd = math.sqrt(var)
    z = (observed - mean) / sd if sd > 1e-15 else float("nan")
    return mean, sd, z, readings


# --------------------------------------------------------------------------
# Sample construction: swap-closed prime-pair populations
# --------------------------------------------------------------------------


def primes_in(lo: int, hi: int) -> List[int]:
    """All primes p with lo < p < hi, by a simple sieve."""
    sieve = [True] * hi
    sieve[0:2] = [False, False]
    for p in range(2, int(hi**0.5) + 1):
        if sieve[p]:
            for m in range(p * p, hi, p):
                sieve[m] = False
    return [p for p in range(lo + 1, hi) if sieve[p]]


def ordered_pairs(primes: Sequence[int]) -> List[Tuple[int, int]]:
    """All ordered pairs (p, q) of distinct primes: a swap-closed population."""
    return [(p, q) for p in primes for q in primes if p != q]


def which_factor_label(pair: Tuple[int, int]) -> int:
    """The which-factor bit: 1 if the first coordinate is the larger prime."""
    p, q = pair
    return 1 if p > q else 0


def product_view(pair: Tuple[int, int], modulus: int = 713) -> int:
    """The symmetric product view N mod m, with N = p*q."""
    p, q = pair
    return (p * q) % modulus


def sd_hint_view(pair: Tuple[int, int]) -> Tuple[int, int]:
    """The (s, d) hint view: the sum and the absolute difference of the factors.

    This is a symmetric function of the unordered pair and is injective on
    unordered pairs, so each of its fibers has size exactly two.
    """
    p, q = pair
    return (p + q, abs(p - q))


def residue_view(pair: Tuple[int, int]) -> int:
    """A deliberately coarse symmetric view: (p*q) mod 3."""
    p, q = pair
    return (p * q) % 3


def swap_involution(pairs: Sequence[Tuple[int, int]]) -> List[int]:
    """Index of (q, p) for each index of (p, q); the swap involution sigma."""
    position = {pair: i for i, pair in enumerate(pairs)}
    return [position[(q, p)] for (p, q) in pairs]


def verify_swap_closed(
    pairs: Sequence[Tuple[int, int]],
    labels: Sequence[Label],
    codes: Sequence[Code],
) -> Dict[str, bool]:
    """Check the four defining conditions of a swap-closed sample."""
    sigma = swap_involution(pairs)
    return {
        "involution": all(sigma[sigma[i]] == i for i in range(len(pairs))),
        "fixed_point_free": all(sigma[i] != i for i in range(len(pairs))),
        "view_symmetric": all(codes[sigma[i]] == codes[i] for i in range(len(pairs))),
        "label_flips": all(labels[sigma[i]] != labels[i] for i in range(len(pairs))),
    }


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_1_fiber_decomposition() -> None:
    rule("1. FIBER DECOMPOSITION:  H(l) - I(l,c) = sum_k (f_k/n) H(rho_k)")
    rng = random.Random(7)
    labels = [rng.choice("ABC") for _ in range(400)]
    codes = [rng.randrange(40) for _ in range(400)]
    h = label_entropy(labels)
    mi = plug_in_mutual_information(labels, codes)
    rhs = conditional_entropy_by_fiber(labels, codes)
    print(f"  label entropy H(l)            = {h:.10f} bits")
    print(f"  plug-in reading I(l,c)        = {mi:.10f} bits")
    print(f"  deficit H(l) - I              = {h - mi:.10f} bits")
    print(f"  fiber-weighted sum of H(rho_k)= {rhs:.10f} bits")
    print(f"  identity holds to             = {abs((h - mi) - rhs):.2e}")


def demo_2_injective_limit() -> None:
    rule("2. INJECTIVE LIMIT:  no collisions => reading = label entropy EXACTLY")
    n = 300
    codes = list(range(n))  # a distinct code per sample: C(c) = 0
    rng = random.Random(11)
    for name, labels in [
        ("labels independent of the code", [rng.randrange(2) for _ in range(n)]),
        ("labels a function of the code  ", [i % 2 for i in range(n)]),
        ("labels heavily imbalanced      ", [1 if i < 17 else 0 for i in range(n)]),
    ]:
        h = label_entropy(labels)
        mi = plug_in_mutual_information(labels, codes)
        print(
            f"  {name}:  C={collision_count(codes):3d}  "
            f"H(l)={h:.6f}  I={mi:.6f}  |I-H|={abs(mi-h):.2e}"
        )
    print("  The reading does not depend on dependence at all -- only on the margin.")


def demo_3_sandwich() -> None:
    rule("3. COLLISION SANDWICH and the data-estimable band  C <= 2(n-d)")
    rng = random.Random(3)
    n = 600
    print(f"  {'granularity':>12} {'d':>5} {'C':>5} {'2(n-d)':>7} "
          f"{'H(l)':>8} {'I':>8} {'lower':>9} {'width':>8}")
    for cells in (4, 25, 120, 400, 600):
        labels = [rng.randrange(2) for _ in range(n)]
        codes = [rng.randrange(cells) for _ in range(n)]
        h = label_entropy(labels)
        mi = plug_in_mutual_information(labels, codes)
        c = collision_count(codes)
        d = distinct_codes(codes)
        w = sandwich_width(labels, codes)
        ok = (h - w - 1e-12) <= mi <= (h + 1e-12) and c <= 2 * (n - d)
        print(
            f"  {cells:12d} {d:5d} {c:5d} {2*(n-d):7d} "
            f"{h:8.4f} {mi:8.4f} {h-w:9.4f} {w:8.4f}   {'OK' if ok else 'FAIL'}"
        )
    print("  Both the sandwich and the estimable bound C <= 2(n-d) hold in every row.")


def demo_4_powerless_null() -> None:
    rule("4. THE HINTED VIEW IS BLIND: observed, surrogates and null mean share a band")
    rng = random.Random(5)
    n = 500
    labels = [rng.randrange(2) for _ in range(n)]
    # A fine view, nearly injective: the regime real screens live in.
    codes = [rng.randrange(3 * n) for _ in range(n)]
    observed = plug_in_mutual_information(labels, codes)
    mean, sd, z, readings = permutation_null(labels, codes, n_shuffles=200)
    width = sandwich_width(labels, codes)
    print(f"  n = {n},  distinct codes d = {distinct_codes(codes)},  "
          f"collision count C = {collision_count(codes)}")
    print(f"  label entropy H(l)        = {label_entropy(labels):.4f} bits")
    print(f"  observed reading          = {observed:.4f} bits")
    print(f"  null mean / sd            = {mean:.4f} / {sd:.4f} bits")
    print(f"  z-score                   = {z:+.2f}")
    print(f"  guaranteed band width     = {width:.4f} bits")
    print(f"  observed - null mean      = {observed - mean:+.4f} bits  "
          f"(bound {width:.4f})")
    print(f"  full null range           = {max(readings) - min(readings):.4f} bits  "
          f"(bound {width:.4f})")
    print("  The entire experiment is confined to an interval it cannot see out of.")


def demo_5_one_bit_window() -> None:
    rule("5. THE ONE-BIT WINDOW: a view injective on unordered pairs")
    primes = primes_in(50, 400)
    pairs = ordered_pairs(primes)
    n = len(pairs)
    labels = [which_factor_label(p) for p in pairs]
    codes = [sd_hint_view(p) for p in pairs]
    f = fiber_sizes(codes)
    h = label_entropy(labels)
    mi = plug_in_mutual_information(labels, codes)
    print(f"  n = {n} ordered pairs of {len(primes)} primes")
    print(f"  distinct (s,d) codes      = {len(f)}  (= n/2 = {n // 2}: one per "
          f"unordered pair)")
    print(f"  maximal fiber size        = {max(f.values())}")
    print(f"  collision fraction C/n    = {collision_count(codes) / n:.4f}")
    print(f"  fiber-log band width      = {fiber_log_width(codes):.4f} bits")
    print(f"  label entropy H(l)        = {h:.6f} bits")
    print(f"  plug-in reading I         = {mi:.6f} bits")
    print(f"  one-bit window [H-1, H]   = [{h - 1:.4f}, {h:.4f}]   "
          f"{'satisfied' if h - 1 - 1e-12 <= mi <= h + 1e-12 else 'VIOLATED'}")


def demo_6_refinement() -> None:
    rule("6. REFINEMENT MONOTONICITY: the finer view always reads at least as much")
    primes = primes_in(50, 300)
    pairs = ordered_pairs(primes)
    n = len(pairs)
    labels = [which_factor_label(p) for p in pairs]
    fine: List[Code] = [sd_hint_view(p) for p in pairs]

    def coarsen(code: Tuple[int, int]) -> int:
        """A merging map phi: keep only the sum coordinate, modulo 97."""
        return code[0] % 97

    coarse: List[Code] = [coarsen(k) for k in fine]  # type: ignore[arg-type]
    i_fine = plug_in_mutual_information(labels, fine)
    i_coarse = plug_in_mutual_information(labels, coarse)
    bound = sandwich_width(labels, coarse)
    print(f"  n = {n}")
    print(f"  fine   (s,d) view : d = {distinct_codes(fine):5d}   I = {i_fine:.6f}")
    print(f"  coarse s mod 97   : d = {distinct_codes(coarse):5d}   I = {i_coarse:.6f}")
    print(f"  gain              = {i_fine - i_coarse:+.6f} bits  "
          f"(>= 0 as the theorem requires)")
    print(f"  ceiling on gain   = {bound:.6f} bits  (coarse collision term)")
    print(f"  gain within ceiling: {i_fine - i_coarse <= bound + 1e-12}")
    print("  Strictness witness (a balanced label copied by the view, then collapsed):")
    lab2 = [0, 1] * 50
    print(f"    reading through the copying view  = "
          f"{plug_in_mutual_information(lab2, lab2):.6f} bits")
    print(f"    reading after collapsing to a point = "
          f"{plug_in_mutual_information(lab2, [0] * len(lab2)):.6f} bits")
    print("  The same comparison on a sample that is NOT swap-closed "
          "(unordered pairs only):")
    unordered = [(p, q) for p in primes for q in primes if p < q]
    m = len(unordered)
    lab3: List[Label] = [1 if (p * q) % 4 == 1 else 0 for (p, q) in unordered]
    fine3: List[Code] = [sd_hint_view(p) for p in unordered]
    coarse3: List[Code] = [k[0] % 97 for k in fine3]  # type: ignore[index]
    i_f = plug_in_mutual_information(lab3, fine3)
    i_c = plug_in_mutual_information(lab3, coarse3)
    cap = sandwich_width(lab3, coarse3)
    print(f"    n = {m};  fine reading = {i_f:.6f}  (view injective, so this is")
    print(f"      exactly the label entropy H(l) = {label_entropy(lab3):.6f})")
    print(f"    coarse reading = {i_c:.6f};  gain = {i_f - i_c:+.6f} "
          f"<= ceiling {cap:.6f}")


def demo_7_dichotomy() -> None:
    rule("7. THE DICHOTOMY: swap-closed => reading EXACTLY 0 and collision fraction 1")
    primes = primes_in(50, 500)
    pairs = ordered_pairs(primes)
    n = len(pairs)
    labels = [which_factor_label(p) for p in pairs]
    views: List[Tuple[str, Callable[[Tuple[int, int]], Code]]] = [
        ("product view N mod 713", product_view),
        ("(s,d) hint view", sd_hint_view),
        ("residue view N mod 3", residue_view),
    ]
    print(f"  n = {n} ordered pairs of {len(primes)} primes in (50, 500)")
    print(f"  {'view':<24}{'d':>7}{'C':>8}{'C/n':>7}{'reading':>12}")
    for name, view in views:
        codes = [view(p) for p in pairs]
        conditions = verify_swap_closed(pairs, labels, codes)
        assert all(conditions.values()), conditions
        c = collision_count(codes)
        mi = plug_in_mutual_information(labels, codes)
        print(f"  {name:<24}{distinct_codes(codes):>7}{c:>8}{c / n:>7.3f}{mi:>12.2e}")
    print("  All four swap-closure conditions verified for every view:")
    print(f"    {verify_swap_closed(pairs, labels, [product_view(p) for p in pairs])}")
    print("  Every reading is 0 to machine precision, and every collision "
          "fraction is exactly 1.")
    print("  Contrapositive check: a view with even one singleton fiber cannot be")
    print("  swap-closed --")
    broken = [product_view(p) for p in pairs]
    broken[0] = ("unique-sentinel",)  # type: ignore[call-overload]
    print(f"    after breaking one code: C = {collision_count(broken)} < n = {n}, "
          f"so no fixed-point-free symmetry of the view exists.")


def demo_8_null_above_data() -> None:
    rule("8. WHY THE NULLS SIT ABOVE THE DATA")
    primes = primes_in(50, 500)
    pairs = ordered_pairs(primes)
    n = len(pairs)
    labels = [which_factor_label(p) for p in pairs]
    print(f"  n = {n};  observed readings are exactly 0 by the dichotomy, "
          f"but the shuffle")
    print("  null destroys the label-flip condition and drifts upward:")
    print(f"  {'view':<24}{'observed':>11}{'null mean':>12}{'null sd':>10}{'z':>9}")
    for name, view in [
        ("product view N mod 713", product_view),
        ("(s,d) hint view", sd_hint_view),
        ("residue view N mod 3", residue_view),
    ]:
        codes = [view(p) for p in pairs]
        observed = plug_in_mutual_information(labels, codes)
        mean, sd, z, _ = permutation_null(labels, codes, n_shuffles=60)
        print(f"  {name:<24}{observed:>11.4f}{mean:>12.4f}{sd:>10.4f}{z:>9.2f}")
    print("  Every null mean exceeds the exactly-zero observation: a 'flag when")
    print("  observed exceeds null' rule can never fire here.")


def main() -> None:
    print(__doc__)
    demo_1_fiber_decomposition()
    demo_2_injective_limit()
    demo_3_sandwich()
    demo_4_powerless_null()
    demo_5_one_bit_window()
    demo_6_refinement()
    demo_7_dichotomy()
    demo_8_null_above_data()
    rule("SUMMARY")
    print("  * The deficit below the label entropy lives entirely on colliding fibers.")
    print("  * An injective view reads the label entropy exactly, regardless of any")
    print("    relationship between label and view.")
    print("  * Observed value, every surrogate and the null mean share one interval")
    print("    of width (C/n)log2|L|: a shuffle test on a fine view has no resolution.")
    print("  * A finer view always reads at least as much; the gain is capped by the")
    print("    coarse view's collision term.")
    print("  * On a swap-closed sample the reading is exactly 0 while the collision")
    print("    fraction is exactly 1 -- the two regimes never overlap.")


if __name__ == "__main__":
    main()
