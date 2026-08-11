#!/usr/bin/env python3
"""
The Thermodynamics of Comparison Sorting -- numerical demonstrations.

This self-contained script reproduces, numerically, every quantitative claim of the
accompanying paper:

  1. Multiway depth bound and its tightness:      ceil(log_q(n!)) <= d, achieved.
  2. Radix independence of the work ledger:       log(n!) <= d*log q < log(n!) + log q.
  3. Reset registers:                             reset cost = kT*log|image| = kT*log(n!),
                                                  invariant under duplication.
  4. Thermodynamic direct sum:                    entropy adds, history states multiply,
                                                  equality iff no garbage.
  5. Fluctuation penalty:                         <W> - F = kT * D(p || p^R) > 0.
  6. Prior-sensitive sorting:                     H(p) <= E[comparisons] < H(p) + 1,
                                                  H(p) <= log2(n!) with equality iff uniform.

Only the Python standard library is used.  Run with:  python3 demo.py
"""

from __future__ import annotations

import heapq
import itertools
import math
from typing import Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------------
# Section 0.  Exact integer kernels
# ----------------------------------------------------------------------------------


def factorial(n: int) -> int:
    """Exact n! by direct product (arbitrary precision)."""
    result = 1
    for k in range(2, n + 1):
        result *= k
    return result


def ceil_log(q: int, m: int) -> int:
    """Exact ceiling logarithm: least d >= 0 with q**d >= m, for q >= 2, m >= 1.

    Computed in exact integer arithmetic so that no floating point rounding can
    perturb the answer even for astronomically large m such as n!.
    """
    if q < 2:
        raise ValueError("radix must be at least 2")
    if m <= 1:
        return 0
    d, power = 0, 1
    while power < m:
        power *= q
        d += 1
    return d


def log_factorial(n: int) -> float:
    """log(n!) in nats, summed term by term to avoid overflow for large n."""
    return sum(math.log(k) for k in range(2, n + 1))


# ----------------------------------------------------------------------------------
# Section 1.  Multiway depth bound and tightness
# ----------------------------------------------------------------------------------


def transcript_capacity(q: int, d: int) -> int:
    """Number of transcripts of depth d and radix q, i.e. q**d."""
    return q ** d


def depth_bound_certificate(n: int, q: int) -> Dict[str, object]:
    """Certify the multiway depth theorem for (n, q).

    Returns the optimal depth d* = ceil(log_q(n!)), a witness that the counting bound
    is satisfied (n! <= q**d*) and that it is tight (q**(d*-1) < n!).
    """
    nfact = factorial(n)
    d_star = ceil_log(q, nfact)
    return {
        "n": n,
        "q": q,
        "n_factorial": nfact,
        "optimal_depth": d_star,
        "capacity": transcript_capacity(q, d_star),
        "bound_holds": nfact <= transcript_capacity(q, d_star),
        "tight": d_star == 0 or transcript_capacity(q, d_star - 1) < nfact,
    }


def explicit_optimal_sorter(n: int, q: int) -> Dict[Tuple[int, ...], Tuple[int, ...]]:
    """Build an explicit depth-optimal transcript map for small n.

    The map sends the k-th permutation (in lexicographic order) to the base-q
    representation of k, padded to length d* = ceil(log_q(n!)).  It is injective by
    uniqueness of base-q representations, so it is a correct sorter of optimal depth --
    a constructive witness for the achievability theorem.
    """
    d_star = ceil_log(q, factorial(n))
    table: Dict[Tuple[int, ...], Tuple[int, ...]] = {}
    for k, perm in enumerate(itertools.permutations(range(n))):
        digits: List[int] = []
        rest = k
        for _ in range(d_star):
            digits.append(rest % q)
            rest //= q
        table[perm] = tuple(reversed(digits))
    return table


# ----------------------------------------------------------------------------------
# Section 2.  The work ledger and the optimal-radix sandwich
# ----------------------------------------------------------------------------------


def naive_transcript_work(kT: float, q: int, d: int) -> float:
    """Naive per-register charge d * kT * log q (nats of work if kT = 1)."""
    return d * kT * math.log(q)


def sandwich_certificate(n: int, q: int, kT: float = 1.0) -> Dict[str, object]:
    """Certify log(n!) <= d* log q < log(n!) + log q for the depth-optimal sorter."""
    d_star = ceil_log(q, factorial(n))
    baseline = kT * log_factorial(n)
    ledger = naive_transcript_work(kT, q, d_star)
    ceiling = baseline + kT * math.log(q)
    return {
        "q": q,
        "depth": d_star,
        "baseline": baseline,
        "ledger": ledger,
        "ceiling": ceiling,
        "lower_ok": baseline <= ledger + 1e-12,
        "upper_ok": ledger < ceiling + 1e-12,
        "overhead": ledger - baseline,
    }


# ----------------------------------------------------------------------------------
# Section 3.  Reset registers: image entropy, not transcript length
# ----------------------------------------------------------------------------------


def reset_work(kT: float, values: Iterable[object]) -> float:
    """kT * log(number of DISTINCT values the register takes)."""
    distinct = len(set(values))
    return kT * math.log(distinct)


def duplication_experiment(n: int, q: int, kT: float = 1.0) -> Dict[str, float]:
    """Show that duplicating (and triplicating) the transcript is thermodynamically free,
    while the naive length-based charge grows linearly with the number of copies."""
    table = explicit_optimal_sorter(n, q)
    d_star = ceil_log(q, factorial(n))
    single = list(table.values())
    doubled = [(t, t) for t in single]
    tripled = [(t, t, t) for t in single]
    return {
        "reset_single": reset_work(kT, single),
        "reset_doubled": reset_work(kT, doubled),
        "reset_tripled": reset_work(kT, tripled),
        "landauer_baseline": kT * log_factorial(n),
        "naive_single": naive_transcript_work(kT, q, d_star),
        "naive_doubled": naive_transcript_work(kT, q, 2 * d_star),
        "naive_tripled": naive_transcript_work(kT, q, 3 * d_star),
    }


def padded_transcript_experiment(n: int, q: int, pad: int, kT: float = 1.0) -> Dict[str, float]:
    """Pad a correct sorter with `pad` redundant constant queries.  The transcript grows,
    the naive charge grows, and the true reset cost does not move at all."""
    table = explicit_optimal_sorter(n, q)
    d_star = ceil_log(q, factorial(n))
    padded = [t + (0,) * pad for t in table.values()]
    return {
        "pad": pad,
        "reset_padded": reset_work(kT, padded),
        "landauer_baseline": kT * log_factorial(n),
        "naive_padded": naive_transcript_work(kT, q, d_star + pad),
    }


# ----------------------------------------------------------------------------------
# Section 4.  Thermodynamic direct sum for independent blocks
# ----------------------------------------------------------------------------------


def direct_sum_certificate(m: int, n: int, kT: float = 1.0) -> Dict[str, object]:
    """Entropy adds; reversible history states multiply."""
    mf, nf = factorial(m), factorial(n)
    return {
        "m": m,
        "n": n,
        "info_bits_joint": math.log2(mf) + math.log2(nf),
        "info_bits_product_check": math.log2(mf * nf),
        "work_joint": kT * math.log(mf) + kT * math.log(nf),
        "min_history_states": mf * nf,
    }


def garbage_index(aux_card: int, m: int, n: int) -> Dict[str, object]:
    """A reversible protocol with |Aux| = aux_card states: is it garbage-free?

    The history map is injective, so aux_card >= m!n!.  Equality holds iff the history
    map is a bijection, i.e. iff the retained history is exactly the pair of block
    orderings.  Any excess is unused (garbage) history state.
    """
    minimum = factorial(m) * factorial(n)
    if aux_card < minimum:
        return {"admissible": False, "reason": "violates the injective history bound"}
    return {
        "admissible": True,
        "aux_card": aux_card,
        "minimum": minimum,
        "garbage_index": aux_card / minimum,
        "garbage_free": aux_card == minimum,
        "unused_states": aux_card - minimum,
    }


# ----------------------------------------------------------------------------------
# Section 5.  Fluctuation penalty above the Landauer baseline
# ----------------------------------------------------------------------------------


def solve_jarzynski_last_work(
    probs: Sequence[float], works_prefix: Sequence[float], kT: float, F: float
) -> float:
    """Choose the final work value so that the Jarzynski equality holds exactly.

    Solves  sum_i p_i exp(-W_i/kT) = exp(-F/kT)  for the last W, given all the others.
    Raises ValueError if no admissible (finite) solution exists.
    """
    if len(works_prefix) != len(probs) - 1:
        raise ValueError("need exactly one free work value")
    target = math.exp(-F / kT)
    partial = sum(p * math.exp(-w / kT) for p, w in zip(probs, works_prefix))
    residual = target - partial
    if residual <= 0.0:
        raise ValueError("inadmissible prefix: no finite final work value exists")
    return -kT * math.log(residual / probs[-1])


def work_ensemble_report(
    probs: Sequence[float], works: Sequence[float], kT: float, F: float
) -> Dict[str, float]:
    """Report expected work, excess above the baseline, and kT * D(p || p^R)."""
    expected = sum(p * w for p, w in zip(probs, works))
    reverse = [p * math.exp(-(w - F) / kT) for p, w in zip(probs, works)]
    divergence = sum(p * math.log(p / r) for p, r in zip(probs, reverse))
    jarzynski = sum(p * math.exp(-w / kT) for p, w in zip(probs, works))
    return {
        "expected_work": expected,
        "baseline_F": F,
        "excess": expected - F,
        "kT_times_divergence": kT * divergence,
        "reverse_norm": sum(reverse),
        "jarzynski_lhs": jarzynski,
        "jarzynski_rhs": math.exp(-F / kT),
    }


# ----------------------------------------------------------------------------------
# Section 6.  Prior-sensitive sorting: entropy floor and Huffman attainment
# ----------------------------------------------------------------------------------


def shannon_entropy_bits(probs: Sequence[float]) -> float:
    """H(p) = -sum p log2 p, in bits."""
    return -sum(p * math.log2(p) for p in probs if p > 0.0)


def huffman_lengths(probs: Sequence[float]) -> List[int]:
    """Optimal prefix-code lengths for the given prior, via Huffman's algorithm.

    Complexity O(r log r) for r symbols.  Returns the codeword length of each symbol,
    in the order the probabilities were given.
    """
    r = len(probs)
    if r == 1:
        return [1]
    lengths = [0] * r
    heap: List[Tuple[float, int, List[int]]] = [
        (p, i, [i]) for i, p in enumerate(probs)
    ]
    heapq.heapify(heap)
    while len(heap) > 1:
        p1, _, g1 = heapq.heappop(heap)
        p2, _, g2 = heapq.heappop(heap)
        for i in g1 + g2:
            lengths[i] += 1
        heapq.heappush(heap, (p1 + p2, min(g1 + g2), g1 + g2))
    return lengths


def shannon_fano_lengths(probs: Sequence[float]) -> List[int]:
    """Shannon-Fano lengths ceil(-log2 p), which satisfy the Kraft inequality and give
    expected length strictly below H(p) + 1."""
    return [max(1, math.ceil(-math.log2(p))) for p in probs]


def kraft_sum(lengths: Sequence[int]) -> float:
    """sum 2^{-l}, which is <= 1 exactly for prefix-free codes."""
    return sum(2.0 ** (-length) for length in lengths)


def prior_sorter_report(probs: Sequence[float], kT: float = 1.0) -> Dict[str, float]:
    """Entropy floor, Shannon-Fano and Huffman expected comparison counts, and the
    corresponding Landauer work relative to the uniform factorial baseline."""
    n_orderings = len(probs)
    entropy = shannon_entropy_bits(probs)
    sf = shannon_fano_lengths(probs)
    hf = huffman_lengths(probs)
    exp_sf = sum(p * l for p, l in zip(probs, sf))
    exp_hf = sum(p * l for p, l in zip(probs, hf))
    return {
        "entropy_bits": entropy,
        "uniform_bits": math.log2(n_orderings),
        "shannon_fano_expected": exp_sf,
        "huffman_expected": exp_hf,
        "kraft_shannon_fano": kraft_sum(sf),
        "kraft_huffman": kraft_sum(hf),
        "floor_ok": entropy <= exp_hf + 1e-12,
        "within_one_ok": exp_sf < entropy + 1.0 + 1e-12,
        "work_entropy_floor": kT * math.log(2) * entropy,
        "work_uniform_baseline": kT * math.log(2) * math.log2(n_orderings),
    }


# ----------------------------------------------------------------------------------
# Driver
# ----------------------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def main() -> None:
    kT = 1.0  # work reported in nats; multiply by Boltzmann's k and T for joules

    rule("1.  MULTIWAY DEPTH BOUND:  ceil(log_q(n!)) <= d, and the bound is achieved")
    print(f"{'n':>3} {'q':>3} {'n!':>10} {'d*':>4} {'q^d*':>14} {'bound':>7} {'tight':>7}")
    for n in (3, 4, 5, 8, 12):
        for q in (2, 3, 4, 5, 10):
            c = depth_bound_certificate(n, q)
            print(
                f"{c['n']:>3} {c['q']:>3} {c['n_factorial']:>10} "
                f"{c['optimal_depth']:>4} {c['capacity']:>14} "
                f"{str(c['bound_holds']):>7} {str(c['tight']):>7}"
            )
        print()

    print("Explicit depth-optimal sorter for n = 4, q = 3 (first 6 of 24 transcripts):")
    table = explicit_optimal_sorter(4, 3)
    for perm, code in list(table.items())[:6]:
        print(f"   {perm}  ->  {''.join(map(str, code))}")
    print(f"   injective: {len(set(table.values())) == len(table)}  "
          f"(|image| = {len(set(table.values()))} = 4! = {factorial(4)})")

    rule("2.  RADIX INDEPENDENCE:  log(n!) <= d* log q < log(n!) + log q   (n = 5)")
    print(f"{'q':>3} {'d*':>4} {'baseline':>10} {'ledger':>10} {'ceiling':>10} "
          f"{'overhead':>10} {'ok':>5}")
    for q in (2, 3, 4, 5, 10, 100):
        s = sandwich_certificate(5, q, kT)
        ok = bool(s["lower_ok"]) and bool(s["upper_ok"])
        print(
            f"{s['q']:>3} {s['depth']:>4} {s['baseline']:>10.4f} {s['ledger']:>10.4f} "
            f"{s['ceiling']:>10.4f} {s['overhead']:>10.4f} {str(ok):>5}"
        )
    print("\nDepth falls by more than half from q = 2 to q = 10, yet every ledger entry")
    print("stays above log(5!) = %.4f nats: the information balance is radix-blind."
          % log_factorial(5))

    rule("3.  RESET REGISTERS:  cost is image entropy, not transcript length (n = 5, q = 2)")
    d = duplication_experiment(5, 2, kT)
    print(f"   Landauer baseline  kT log(5!)        = {d['landauer_baseline']:.6f} nats")
    print(f"   reset cost, single transcript        = {d['reset_single']:.6f} nats")
    print(f"   reset cost, DUPLICATED transcript    = {d['reset_doubled']:.6f} nats")
    print(f"   reset cost, TRIPLICATED transcript   = {d['reset_tripled']:.6f} nats")
    print(f"   naive charge, single / doubled / tripled = "
          f"{d['naive_single']:.4f} / {d['naive_doubled']:.4f} / {d['naive_tripled']:.4f}")
    print("\n   Padding with redundant constant queries:")
    print(f"   {'pad':>5} {'naive charge':>14} {'true reset cost':>18}")
    for pad in (0, 5, 20, 100):
        p = padded_transcript_experiment(5, 2, pad, kT)
        print(f"   {p['pad']:>5} {p['naive_padded']:>14.4f} {p['reset_padded']:>18.6f}")
    print("\n   The naive charge diverges without bound; the true cost never moves.")

    rule("4.  THERMODYNAMIC DIRECT SUM:  entropy adds, history states multiply")
    for (m, n) in ((3, 3), (4, 2), (5, 3)):
        c = direct_sum_certificate(m, n, kT)
        print(f"   (m, n) = ({m}, {n}):  erased information "
              f"= log2({factorial(m)}) + log2({factorial(n)}) "
              f"= {c['info_bits_joint']:.4f} bits "
              f"(= log2 of product: {c['info_bits_product_check']:.4f})")
        print(f"                minimum reversible history states = {c['min_history_states']}")
    print("\n   Garbage diagnostics for (m, n) = (4, 2), minimum 48 states:")
    for aux in (48, 49, 64, 96):
        g = garbage_index(aux, 4, 2)
        print(f"      |Aux| = {aux:>3}:  garbage index = {g['garbage_index']:.4f}, "
              f"garbage-free = {g['garbage_free']}, unused = {g['unused_states']}")

    rule("5.  FLUCTUATION PENALTY:  <W> - F = kT * D(p || p^R) > 0   (n = 3)")
    F = log_factorial(3)  # = log 6
    print(f"   Landauer baseline F = log(3!) = {F:.6f} nats\n")
    print(f"   {'W1':>9} {'W2':>9} {'<W>':>9} {'excess':>10} {'kT*D':>10} {'match':>7}")
    for delta in (0.0, 0.1, 0.5, 1.0, 1.5):
        probs = [0.5, 0.5]
        w1 = F - delta
        try:
            w2 = solve_jarzynski_last_work(probs, [w1], kT, F)
        except ValueError:
            print(f"   {w1:>9.4f}   (inadmissible: no finite partner work value)")
            continue
        r = work_ensemble_report(probs, [w1, w2], kT, F)
        match = abs(r["excess"] - r["kT_times_divergence"]) < 1e-9
        print(f"   {w1:>9.4f} {w2:>9.4f} {r['expected_work']:>9.4f} "
              f"{r['excess']:>10.6f} {r['kT_times_divergence']:>10.6f} {str(match):>7}")
    print("\n   delta = 0 is the deterministic case W == F: zero spread, zero penalty.")
    print("   Every nonconstant ensemble pays strictly, and the surcharge is EXACTLY")
    print("   kT times the forward/reverse relative entropy -- an identity, not a bound.")

    rule("6.  PRIOR-SENSITIVE SORTING:  H(p) <= E[comparisons] < H(p) + 1   (n = 3)")
    priors: Dict[str, List[float]] = {
        "uniform          ": [1 / 6] * 6,
        "dyadic           ": [1 / 2, 1 / 4, 1 / 8, 1 / 16, 1 / 32, 1 / 32],
        "nearly sorted    ": [0.80, 0.10, 0.04, 0.03, 0.02, 0.01],
        "two-mode         ": [0.45, 0.45, 0.025, 0.025, 0.025, 0.025],
    }
    print(f"   {'prior':<18} {'H(p)':>8} {'log2 6':>8} {'S-F':>8} {'Huff':>8} "
          f"{'floor':>7} {'<H+1':>6}")
    for name, p in priors.items():
        r = prior_sorter_report(p, kT)
        print(f"   {name:<18} {r['entropy_bits']:>8.4f} {r['uniform_bits']:>8.4f} "
              f"{r['shannon_fano_expected']:>8.4f} {r['huffman_expected']:>8.4f} "
              f"{str(bool(r['floor_ok'])):>7} {str(bool(r['within_one_ok'])):>6}")
    print("\n   The dyadic prior has H(p) = 1.9375 bits against the uniform 2.5850 bits,")
    print("   a saving of 0.6475 bits, and the optimal code attains it with zero overshoot.")
    print("   Maximum entropy: the uniform prior is the unique maximiser, so the classical")
    print("   factorial baseline is exactly the no-prior-knowledge special case.")

    rule("SUMMARY")
    print("   Depth  ~ log_q(n!)     : tree CAPACITY, sensitive to the query radix.")
    print("   Work   ~ kT log(n!)    : image CARDINALITY, blind to depth, radix, padding.")
    print("   Blocks : entropy adds, reversible state counts multiply.")
    print("   Speed  : any work fluctuation costs exactly kT * D(forward || reverse).")
    print("   Priors : the floor is kT log2 * H(p), attained to within one comparison.")


if __name__ == "__main__":
    main()
