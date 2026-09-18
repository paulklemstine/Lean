"""
Synergy and Overlap in Batteries of Measurement Dials
=====================================================

Numerical demonstration of the co-information calculus for measurement
batteries.  Everything here is exact finite-population computation: the
population is a finite list of individuals, a "dial" is a deterministic
function from individuals to readouts, and all information quantities are
empirical entropies computed by fibre counting.

Results demonstrated
--------------------
1.  Pair co-information identity
        I(L;(f,g)) - I(L;f) - I(L;g)  =  I(f;g|L) - I(f;g)
2.  Nonnegativity of the two dependence terms, and the unsignedness of their
    difference.
3.  The three-signs witness: one three-dial battery on four individuals whose
    rows are +1, 0 and -1 bit.
4.  Overlap bounds:   overlap <= I(f;g)   and   overlap <= min(I1, I2),
    both attained by a duplicated dial.
5.  Total overlap for a refining dial:  Delta = -I(L;g)  when g = u(f).
6.  Width-k law:  Delta(S) = TC(reads|L) - TC(reads),  with both terms >= 0,
    the overlap bound Delta >= -TC, and its attainment by k duplicated dials.
7.  A structural analogue of the measured arithmetic table: a "rich" coprime
    pair that synergizes, a "lossy" pair that is nearly additive, and a
    shared-structure pair that overlaps almost completely.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from collections import Counter
from typing import Callable, Hashable, List, Sequence, Tuple

Individual = Hashable
Readout = Hashable
Statistic = Callable[[Individual], Readout]

LOG2 = math.log(2.0)


# ---------------------------------------------------------------------------
# Core information-theoretic primitives (empirical, uniform population)
# ---------------------------------------------------------------------------


def entropy(stat: Statistic, population: Sequence[Individual]) -> float:
    """Empirical entropy H(stat) in bits, over the uniform distribution."""
    n = len(population)
    counts = Counter(stat(x) for x in population)
    return -sum((c / n) * math.log2(c / n) for c in counts.values())


def pair_stat(f: Statistic, g: Statistic) -> Statistic:
    """The joint statistic x -> (f(x), g(x))."""
    return lambda x: (f(x), g(x))


def tuple_stat(fs: Sequence[Statistic]) -> Statistic:
    """The joint statistic x -> (f_1(x), ..., f_k(x))."""
    return lambda x: tuple(f(x) for f in fs)


def mutual_information(
    f: Statistic, g: Statistic, population: Sequence[Individual]
) -> float:
    """I(f;g) = H(f) + H(g) - H(f,g), in bits."""
    return (
        entropy(f, population)
        + entropy(g, population)
        - entropy(pair_stat(f, g), population)
    )


def conditional_entropy(
    g: Statistic, cond: Statistic, population: Sequence[Individual]
) -> float:
    """H(g | cond) = H(cond, g) - H(cond), in bits."""
    return entropy(pair_stat(cond, g), population) - entropy(cond, population)


def conditional_dependence(
    label: Statistic, f: Statistic, g: Statistic, population: Sequence[Individual]
) -> float:
    """I(f;g|L) = H(L,f) + H(L,g) - H(L,f,g) - H(L), in bits."""
    tri = lambda x: (label(x), f(x), g(x))  # noqa: E731
    return (
        entropy(pair_stat(label, f), population)
        + entropy(pair_stat(label, g), population)
        - entropy(tri, population)
        - entropy(label, population)
    )


def pair_synergy(
    label: Statistic, f: Statistic, g: Statistic, population: Sequence[Individual]
) -> float:
    """Delta = I(L;(f,g)) - I(L;f) - I(L;g), in bits."""
    return (
        mutual_information(label, pair_stat(f, g), population)
        - mutual_information(label, f, population)
        - mutual_information(label, g, population)
    )


# ---------------------------------------------------------------------------
# Full decompositions
# ---------------------------------------------------------------------------


def pair_decomposition(
    label: Statistic, f: Statistic, g: Statistic, population: Sequence[Individual]
) -> dict:
    """Every quantity of the pair law, plus a check of the identity."""
    i1 = mutual_information(label, f, population)
    i2 = mutual_information(label, g, population)
    ijoint = mutual_information(label, pair_stat(f, g), population)
    delta = ijoint - i1 - i2
    dep = mutual_information(f, g, population)
    dep_l = conditional_dependence(label, f, g, population)
    return {
        "I1": i1,
        "I2": i2,
        "I_joint": ijoint,
        "additive_prediction": i1 + i2,
        "Delta": delta,
        "overlap": -delta,
        "Dep": dep,
        "Dep_L": dep_l,
        "identity_residual": delta - (dep_l - dep),
        "H_f": entropy(f, population),
        "H_g": entropy(g, population),
    }


def total_correlation(
    fs: Sequence[Statistic], population: Sequence[Individual]
) -> float:
    """TC = sum_i H(f_i) - H(joint), in bits."""
    return sum(entropy(f, population) for f in fs) - entropy(
        tuple_stat(fs), population
    )


def conditional_total_correlation(
    label: Statistic, fs: Sequence[Statistic], population: Sequence[Individual]
) -> float:
    """TC(.|L) = sum_i H(f_i|L) - H(joint|L), in bits."""
    return sum(
        conditional_entropy(f, label, population) for f in fs
    ) - conditional_entropy(tuple_stat(fs), label, population)


def battery_decomposition(
    label: Statistic, fs: Sequence[Statistic], population: Sequence[Individual]
) -> dict:
    """Every quantity of the width-k law, plus a check of the identity."""
    i_joint = mutual_information(label, tuple_stat(fs), population)
    sum_i = sum(mutual_information(label, f, population) for f in fs)
    delta = i_joint - sum_i
    tc = total_correlation(fs, population)
    tc_l = conditional_total_correlation(label, fs, population)
    return {
        "width": len(fs),
        "I_joint": i_joint,
        "additive_prediction": sum_i,
        "Delta": delta,
        "TC": tc,
        "TC_L": tc_l,
        "identity_residual": delta - (tc_l - tc),
        "overlap_bound_slack": delta - (-tc),
        "synergy_ceiling_slack": tc_l - delta,
    }


def greedy_battery(
    label: Statistic,
    catalogue: Sequence[Tuple[str, Statistic]],
    k: int,
    population: Sequence[Individual],
) -> List[Tuple[str, float]]:
    """Greedy battery assembly by exact conditional increment (not marginal score)."""
    chosen: List[Tuple[str, Statistic]] = []
    trace: List[Tuple[str, float]] = []
    for _ in range(min(k, len(catalogue))):
        if chosen:
            current = mutual_information(
                label, tuple_stat([s for _, s in chosen]), population
            )
        else:
            current = 0.0
        best_name, best_stat, best_gain = None, None, -math.inf
        for name, stat in catalogue:
            if any(name == c for c, _ in chosen):
                continue
            joint = tuple_stat([s for _, s in chosen] + [stat])
            gain = mutual_information(label, joint, population) - current
            if gain > best_gain + 1e-12:
                best_name, best_stat, best_gain = name, stat, gain
        if best_stat is None:
            break
        chosen.append((best_name, best_stat))
        trace.append((best_name, best_gain))
    return trace


# ---------------------------------------------------------------------------
# Presentation helpers
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def show_pair(name: str, d: dict) -> None:
    print(f"\n  {name}")
    print(f"    I(L;f)            = {d['I1']:+.4f} bits")
    print(f"    I(L;g)            = {d['I2']:+.4f} bits")
    print(f"    I(L;(f,g))        = {d['I_joint']:+.4f} bits")
    print(f"    additive guess    = {d['additive_prediction']:+.4f} bits")
    print(f"    Delta             = {d['Delta']:+.4f} bits", end="")
    if d["Delta"] > 1e-9:
        print("   <-- SYNERGY")
    elif d["Delta"] < -1e-9:
        print("   <-- OVERLAP")
    else:
        print("   <-- exactly additive")
    print(f"    I(f;g)      (Dep) = {d['Dep']:+.4f} bits")
    print(f"    I(f;g|L)  (Dep_L) = {d['Dep_L']:+.4f} bits")
    print(f"    identity residual = {d['identity_residual']:+.2e}  (must be 0)")


# ---------------------------------------------------------------------------
# Demonstration 1 — the three-signs witness on four individuals
# ---------------------------------------------------------------------------


def demo_three_signs() -> None:
    banner("1. THREE SIGNS IN ONE BATTERY (population = two bits, 4 individuals)")

    pop: List[Tuple[int, int]] = list(itertools.product([0, 1], repeat=2))

    f0 = lambda x: x[0]          # dial 0 : first bit            # noqa: E731
    f1 = lambda x: x[1]          # dial 1 : second bit           # noqa: E731
    f2 = lambda x: x[0]          # dial 2 : duplicate of dial 0  # noqa: E731
    lab_xor = lambda x: x[0] ^ x[1]   # parity label             # noqa: E731
    lab_fst = lambda x: x[0]          # first-bit label          # noqa: E731

    print("\n  dials : f0 = first bit, f1 = second bit, f2 = duplicate of f0")
    print("  labels: parity (b1 xor b2), and first bit")

    show_pair("ROW 1  parity label, dials {0,1}", pair_decomposition(lab_xor, f0, f1, pop))
    show_pair("ROW 2  first-bit label, dials {0,1}", pair_decomposition(lab_fst, f0, f1, pop))
    show_pair("ROW 3  first-bit label, dials {0,2}", pair_decomposition(lab_fst, f0, f2, pop))

    print("\n  => the battery space is NEITHER additive NOR comonotone:")
    print("     the same dial pair {0,1} is strictly super-additive against one")
    print("     label and exactly additive against another, while the duplicated")
    print("     pair {0,2} is strictly sub-additive.")


# ---------------------------------------------------------------------------
# Demonstration 2 — the bounds, and their attainment
# ---------------------------------------------------------------------------


def demo_bounds() -> None:
    banner("2. THE TWO-SIDED LAW  -min(I1,I2) <= Delta <= min(H f, H g)")

    pop = list(itertools.product([0, 1], repeat=2))
    f0 = lambda x: x[0]   # noqa: E731
    f1 = lambda x: x[1]   # noqa: E731
    lab_fst = lambda x: x[0]   # noqa: E731
    lab_xor = lambda x: x[0] ^ x[1]   # noqa: E731

    cases = [
        ("duplicated dial vs first-bit label", lab_fst, f0, f0),
        ("independent dials vs parity label", lab_xor, f0, f1),
        ("independent dials vs first-bit label", lab_fst, f0, f1),
    ]
    for name, lab, f, g in cases:
        d = pair_decomposition(lab, f, g, pop)
        lower = -min(d["I1"], d["I2"])
        upper = min(d["H_f"], d["H_g"])
        print(f"\n  {name}")
        print(f"    lower bound -min(I1,I2) = {lower:+.4f}")
        print(f"    Delta                   = {d['Delta']:+.4f}"
              f"   {'  (LOWER BOUND ATTAINED)' if abs(d['Delta']-lower) < 1e-12 else ''}")
        print(f"    upper bound min(Hf,Hg)  = {upper:+.4f}"
              f"   {'  (UPPER BOUND ATTAINED)' if abs(d['Delta']-upper) < 1e-12 else ''}")
        print(f"    overlap {-d['Delta']:+.4f}  <=  I(f;g) = {d['Dep']:.4f}"
              f"   {'  (SHARED-CHANNEL BOUND ATTAINED)' if abs(-d['Delta']-d['Dep']) < 1e-12 else ''}")


# ---------------------------------------------------------------------------
# Demonstration 3 — a refining dial contributes nothing
# ---------------------------------------------------------------------------


def demo_refinement() -> None:
    banner("3. 'SAME SUBFIELD = SAME DIAL': a post-processed dial costs a full marginal")

    pop = list(itertools.product([0, 1], repeat=3))
    f = lambda x: (x[0], x[1])            # a two-bit dial            # noqa: E731
    g = lambda x: x[0]                    # g = u(f): coarser view    # noqa: E731
    lab = lambda x: (x[0], x[2])          # a two-bit label           # noqa: E731

    d = pair_decomposition(lab, f, g, pop)
    i_g = mutual_information(lab, g, pop)
    show_pair("f = (b1,b2),  g = b1  (a post-processing of f)", d)
    print(f"\n    prediction Delta = -I(L;g) = {-i_g:+.4f}  --> "
          f"{'MATCHES' if abs(d['Delta'] + i_g) < 1e-12 else 'MISMATCH'}")


# ---------------------------------------------------------------------------
# Demonstration 4 — the width-k law
# ---------------------------------------------------------------------------


def demo_width_k() -> None:
    banner("4. THE WIDTH-k LAW  Delta(S) = TC(reads|L) - TC(reads)")

    print("\n  (a) k duplicated dials read against their own readout:")
    pop = [0, 1]
    u = lambda x: x   # noqa: E731
    for k in range(1, 6):
        fs = [u] * k
        d = battery_decomposition(u, fs, pop)
        print(f"      k = {k}:  TC = {d['TC']:.4f}   Delta = {d['Delta']:+.4f}"
              f"   (predicted {-(k-1):+d})   residual {d['identity_residual']:+.1e}")

    print("\n  (b) k independent fair bits, label = parity of all of them:")
    for k in range(2, 6):
        popk = list(itertools.product([0, 1], repeat=k))
        fs = [(lambda i: (lambda x: x[i]))(i) for i in range(k)]
        lab = lambda x: sum(x) % 2   # noqa: E731
        d = battery_decomposition(lab, fs, popk)
        print(f"      k = {k}:  sum of marginals = {d['additive_prediction']:.4f}"
              f"   I(L;joint) = {d['I_joint']:.4f}   Delta = {d['Delta']:+.4f}"
              f"   TC = {d['TC']:.4f}   TC_L = {d['TC_L']:.4f}")
    print("\n      => independent readouts (TC = 0) force super-additivity at every width;")
    print("         here every marginal is worthless yet the battery pins the label.")


# ---------------------------------------------------------------------------
# Demonstration 5 — a structural analogue of the measured arithmetic table
# ---------------------------------------------------------------------------


def demo_arithmetic_analogue() -> None:
    banner("5. STRUCTURAL ANALOGUE OF THE MEASURED TABLE (residue dials on pairs)")

    # Population: pairs (p, q) of integers in a range, standing in for a pair of
    # primes.  Dials read residues.  The label is a joint fingerprint of the pair:
    # the sum modulo 3 together with the parity of the first component.  Ranges are
    # deliberately not multiples of the moduli, so the population is only
    # approximately balanced -- as a real sampled population would be.
    pop = [(p, q) for p in range(1, 30) for q in range(1, 32)]

    def res(component: int, m: int) -> Statistic:
        return lambda x: x[component] % m

    label = lambda x: ((x[0] + x[1]) % 3, x[0] % 2)   # noqa: E731

    rich_a = res(0, 6)     # rich dial on p: sees p mod 2 AND p mod 3
    rich_b = res(1, 3)     # transverse dial on q: sees q mod 3
    lossy_a = res(0, 2)    # coarse dial: only the parity of p
    lossy_b = lambda x: 1 if x[1] % 4 == 0 else 0   # very coarse dial  # noqa: E731
    shared_a = res(0, 6)   # sees 2 and 3
    shared_b = res(0, 2)   # sees 2 only -- a post-processing of the previous dial

    show_pair("rich transverse pair  (p mod 6) x (q mod 3)",
              pair_decomposition(label, rich_a, rich_b, pop))
    show_pair("lossy pair  (p mod 2) x (4 | q ?)",
              pair_decomposition(label, lossy_a, lossy_b, pop))
    show_pair("shared-structure pair  (p mod 6) x (p mod 2)",
              pair_decomposition(label, shared_a, shared_b, pop))

    print("\n  The three rows reproduce the structural pattern of the measured table:")
    print("  transverse rich dials synergize strongly (neither dial alone sees the")
    print("  sum modulo 3, both together see it), coarse dials are near-additive,")
    print("  and a dial that post-processes another overlaps by a full marginal.")


# ---------------------------------------------------------------------------
# Demonstration 6 — additivity is a knife edge (random search)
# ---------------------------------------------------------------------------


def demo_knife_edge(trials: int = 4000, seed: int = 20260918) -> None:
    banner("6. ADDITIVITY IS A KNIFE EDGE (random dials on a random population)")

    rng = random.Random(seed)
    pop = list(range(12))
    pos = neg = zero = 0
    worst_residual = 0.0
    extreme_pos = extreme_neg = 0.0

    for _ in range(trials):
        fvals = [rng.randrange(3) for _ in pop]
        gvals = [rng.randrange(3) for _ in pop]
        lvals = [rng.randrange(2) for _ in pop]
        f = lambda x: fvals[x]   # noqa: E731
        g = lambda x: gvals[x]   # noqa: E731
        lab = lambda x: lvals[x]   # noqa: E731
        d = pair_decomposition(lab, f, g, pop)
        worst_residual = max(worst_residual, abs(d["identity_residual"]))
        if d["Delta"] > 1e-9:
            pos += 1
            extreme_pos = max(extreme_pos, d["Delta"])
        elif d["Delta"] < -1e-9:
            neg += 1
            extreme_neg = min(extreme_neg, d["Delta"])
        else:
            zero += 1

    print(f"\n  trials                 : {trials}")
    print(f"  strictly synergistic   : {pos}  ({100*pos/trials:.1f} %)   max {extreme_pos:+.4f} bits")
    print(f"  strictly overlapping   : {neg}  ({100*neg/trials:.1f} %)   min {extreme_neg:+.4f} bits")
    print(f"  exactly additive       : {zero}  ({100*zero/trials:.1f} %)")
    print(f"  worst identity residual: {worst_residual:.2e}  (co-information identity)")
    print("\n  => exact additivity is a coincidence, not a law: it is one scalar")
    print("     equation on the joint law, and both signs occur generically.")


# ---------------------------------------------------------------------------
# Demonstration 7 — greedy battery assembly beats marginal ranking
# ---------------------------------------------------------------------------


def demo_greedy_vs_marginal() -> None:
    banner("7. FEATURE SELECTION: marginal ranking vs exact conditional increments")

    pop = list(itertools.product([0, 1], repeat=3))
    label = lambda x: x[0] ^ x[1]   # noqa: E731

    catalogue: List[Tuple[str, Statistic]] = [
        ("bit1", lambda x: x[0]),
        ("bit2", lambda x: x[1]),
        ("bit3 (noise)", lambda x: x[2]),
        ("copy of bit3", lambda x: x[2]),
    ]

    print("\n  label = bit1 XOR bit2;  catalogue of four candidate dials")
    print("\n  marginal capacities (the usual top-k score):")
    for name, stat in catalogue:
        print(f"      {name:<14} I(L;f) = {mutual_information(label, stat, pop):.4f} bits")
    print("      -> every marginal score is 0: top-k ranking is blind here.")

    print("\n  greedy assembly by exact conditional increment:")
    for name, gain in greedy_battery(label, catalogue, 3, pop):
        print(f"      + {name:<14} increment = {gain:+.4f} bits")
    print("      -> the synergistic pair is recovered; the redundant copy adds 0.")


# ---------------------------------------------------------------------------


def main() -> None:
    print(__doc__)
    demo_three_signs()
    demo_bounds()
    demo_refinement()
    demo_width_k()
    demo_arithmetic_analogue()
    demo_knife_edge()
    demo_greedy_vs_marginal()
    banner("ALL DEMONSTRATIONS COMPLETE")
    print("\nEvery identity residual printed above is zero to machine precision:")
    print("the co-information law Delta = I(f;g|L) - I(f;g) and its width-k form")
    print("Delta(S) = TC(reads|L) - TC(reads) hold exactly on every example.\n")


if __name__ == "__main__":
    main()
