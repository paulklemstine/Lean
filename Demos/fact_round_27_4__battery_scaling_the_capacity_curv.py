"""
The Battery Capacity Law — numerical demonstrations.

A *battery* is a family of finite-valued measurements ("dials") read against a hidden
*label* on a finite population.  This script demonstrates, by exact computation on fully
enumerated populations (no sampling, hence no finite-sample bias), the structural laws
governing the *capacity curve* I(k) = I(joint reading of the first k dials ; label):

  1. Ceiling            I(K;L) <= H(L), with slack exactly the conditional entropy H(L|K).
  2. Saturation         I(K;L) = H(L)  <=>  the reading determines the label.
  3. Monotonicity       S subset T  =>  I(K_S;L) <= I(K_T;L)   (data processing).
  4. Strong subadd.     H(u,v,w) + H(u) <= H(u,v) + H(u,w).
  5. Synergy            independent readings:  I(k1;L) + I(k2;L) <= I((k1,k2);L).
  6. Boundary of (5)    duplicated dials give a strictly NEGATIVE deficit.
  7. Exact blindness    a symmetry of the dials that flips a binary label forces I = 0.

Everything is computed with counting (empirical) entropies:
    H(f) = - sum_a (n_a / N) log2(n_a / N),   n_a = #{x : f(x) = a}.

Pure standard library; runs in a few seconds.
"""

from __future__ import annotations

import math
import random
from collections import Counter
from itertools import combinations
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

Individual = Hashable
Reading = Hashable

# --------------------------------------------------------------------------------------
# 1. The counting calculus
# --------------------------------------------------------------------------------------


def entropy(values: Sequence[Reading]) -> float:
    """Counting entropy H(f) in bits of a statistic, given its list of readings.

    H(f) = - sum_a (n_a/N) log2(n_a/N), the sum over the values actually attained.
    """
    n_total = len(values)
    if n_total == 0:
        return 0.0
    counts = Counter(values)
    return -sum((c / n_total) * math.log2(c / n_total) for c in counts.values())


def joint(*columns: Sequence[Reading]) -> List[Tuple[Reading, ...]]:
    """The joint statistic x |-> (f_1(x), ..., f_r(x)), as a list of tuples."""
    return list(zip(*columns))


def mutual_information(f: Sequence[Reading], g: Sequence[Reading]) -> float:
    """I(f;g) = H(f) + H(g) - H(f,g), in bits.  Always >= 0."""
    return entropy(f) + entropy(g) - entropy(joint(f, g))


def conditional_entropy(target: Sequence[Reading], given: Sequence[Reading]) -> float:
    """H(target | given) = H(given, target) - H(given), in bits."""
    return entropy(joint(given, target)) - entropy(given)


def chained_key(columns: Sequence[Sequence[int]], moduli: Sequence[int]) -> List[int]:
    """Encode a joint reading of residue dials as a single integer key (Horner's rule).

    This is what makes large batteries computable: a dense table indexed by the product
    of the moduli would be astronomically large, while the chained keys use O(N) memory
    independent of the moduli.
    """
    n_total = len(columns[0]) if columns else 0
    keys = [0] * n_total
    for column, modulus in zip(columns, moduli):
        for idx, residue in enumerate(column):
            keys[idx] = keys[idx] * modulus + residue
    return keys


# --------------------------------------------------------------------------------------
# 2. A six-dial coprime battery, computed exactly
# --------------------------------------------------------------------------------------

MODULI: Tuple[int, ...] = (2, 3, 5, 7, 11, 13)


def build_population() -> Tuple[List[List[int]], List[Tuple[int, ...]]]:
    """Enumerate the whole population Z_M, M = 2*3*5*7*11*13 = 30030.

    Dial i reads x mod m_i.  Because the moduli are pairwise coprime, the Chinese
    Remainder Theorem makes the six residue readings *exactly* independent in this
    population, and the full six-tuple determines x.

    The label is a chain of *pairwise* blocks,
        L(x) = ( (r1+r2) mod 3, (r2+r3) mod 5, (r3+r4) mod 7,
                 (r4+r5) mod 11, (r5+r6) mod 13 ),
    where r_i is the reading of dial i.  Each block needs two adjacent dials, so no single
    dial says much about the label, while the six dials together determine it exactly.
    This is the shape of a real capacity curve: a staircase of synergistic gains rising to
    the ceiling at the completing dial.
    """
    modulus = math.prod(MODULI)
    blocks: Tuple[int, ...] = (3, 5, 7, 11, 13)
    dials: List[List[int]] = [[] for _ in MODULI]
    labels: List[Tuple[int, ...]] = []
    for x in range(modulus):
        residues = [x % m for m in MODULI]
        for i, r in enumerate(residues):
            dials[i].append(r)
        labels.append(
            tuple((residues[i] + residues[i + 1]) % blocks[i] for i in range(len(blocks)))
        )
    return dials, labels


def capacity_curve(
    dials: Sequence[Sequence[int]], labels: Sequence[Reading]
) -> List[Dict[str, float]]:
    """Capacity curve, additive bookkeeping and deficit along the nested chain."""
    ceiling = entropy(labels)
    marginals = [mutual_information(d, labels) for d in dials]
    rows: List[Dict[str, float]] = []
    for k in range(1, len(dials) + 1):
        reading = joint(*dials[:k])
        info = mutual_information(reading, labels)
        additive = sum(marginals[:k])
        rows.append(
            {
                "k": float(k),
                "I": info,
                "additive": additive,
                "deficit": info - additive,
                "ceiling": ceiling,
                "pct": 100.0 * info / ceiling if ceiling > 0 else float("nan"),
                "gap": ceiling - info,
            }
        )
    return rows


def demo_capacity_curve() -> None:
    print("=" * 86)
    print("1.  THE CAPACITY CURVE OF A SIX-DIAL COPRIME BATTERY (exact, N = 30030)")
    print("=" * 86)
    dials, labels = build_population()
    rows = capacity_curve(dials, labels)
    print(f"    moduli            : {MODULI}  (pairwise coprime, product {math.prod(MODULI)})")
    print("    label             : the five pairwise blocks (r_i + r_{i+1}) mod m_{i+1}")
    print(f"    ceiling H(L)      : {entropy(labels):.4f} bits\n")
    header = f"{'k':>2} {'I(k)':>9} {'S marginals':>12} {'deficit':>9} {'ceiling':>9} {'% ceil':>8} {'gap':>8}"
    print(header)
    print("-" * len(header))
    for row in rows:
        print(
            f"{int(row['k']):>2} {row['I']:>9.4f} {row['additive']:>12.4f} "
            f"{row['deficit']:>9.4f} {row['ceiling']:>9.4f} {row['pct']:>7.2f}% {row['gap']:>8.4f}"
        )

    # --- law checks -------------------------------------------------------------------
    print("\n    law checks")
    mono_curve = all(rows[i]["I"] <= rows[i + 1]["I"] + 1e-12 for i in range(len(rows) - 1))
    below = all(row["I"] <= row["ceiling"] + 1e-12 for row in rows)
    mono_def = all(
        rows[i]["deficit"] <= rows[i + 1]["deficit"] + 1e-12 for i in range(len(rows) - 1)
    )
    print(f"      monotone curve            (Corollary: curve never decreases) : {mono_curve}")
    print(f"      below the ceiling         (Ceiling Theorem)                  : {below}")
    print(f"      monotone deficit          (guarded Synergy Law)              : {mono_def}")
    saturates = abs(rows[-1]["gap"]) < 1e-12
    print(f"      exact saturation at k = 6 (Saturation Theorem)               : {saturates}")

    # the same joint entropy, computed through integer keys instead of tuples
    keys = chained_key(dials, MODULI)
    print(
        f"\n    chained-key encoding of the six-dial reading: H = {entropy(keys):.4f} bits"
        f"  (tuple encoding: {entropy(joint(*dials)):.4f} bits)"
    )

    # the hypothesis of the guarded law, verified exactly, dial by dial
    print("\n    independence audit: is the new dial independent of the previous reading?")
    for k in range(1, len(dials)):
        previous = joint(*dials[:k])
        overlap = mutual_information(previous, dials[k])
        print(
            f"      I(reading of first {k} dials ; dial {k + 1}) = {overlap:.2e} bits"
            f"   -> {'independent' if overlap < 1e-9 else 'DEPENDENT'}"
        )


# --------------------------------------------------------------------------------------
# 3. Saturation certificate and ambiguity audit
# --------------------------------------------------------------------------------------


def saturation_certificate(
    reading: Sequence[Reading], labels: Sequence[Reading]
) -> Dict[str, float]:
    """Audit the residual ambiguity of a reading with respect to a label.

    Returns the exact ceiling gap H(L|K), the fraction of the population sitting in cells
    that contain more than one label, and log2 of the largest number of distinct labels in
    a single cell (a cell-local upper bound for the gap).
    """
    cells: Dict[Reading, List[Reading]] = {}
    for cell, label in zip(reading, labels):
        cells.setdefault(cell, []).append(label)
    n_total = len(labels)
    impure = sum(len(v) for v in cells.values() if len(set(v)) > 1)
    worst = max((len(set(v)) for v in cells.values()), default=1)
    return {
        "gap": conditional_entropy(labels, reading),
        "impure_fraction": impure / n_total if n_total else 0.0,
        "cell_bound": math.log2(worst),
        "pure": 1.0 if worst == 1 else 0.0,
    }


def demo_saturation_certificate() -> None:
    print("\n" + "=" * 86)
    print("2.  SATURATION CERTIFICATE: where the missing bits live")
    print("=" * 86)
    dials, labels = build_population()
    print(f"{'k':>2} {'gap H(L|K)':>12} {'impure pop.':>12} {'cell bound':>12} {'pure?':>7}")
    print("-" * 50)
    for k in range(1, len(dials) + 1):
        cert = saturation_certificate(joint(*dials[:k]), labels)
        print(
            f"{k:>2} {cert['gap']:>12.4f} {100 * cert['impure_fraction']:>11.1f}% "
            f"{cert['cell_bound']:>12.4f} {'yes' if cert['pure'] else 'no':>7}"
        )
    print(
        "\n    The gap is never larger than the cell bound: the ceiling gap is controlled by\n"
        "    how many distinct labels survive inside a single cell of the joint reading."
    )


# --------------------------------------------------------------------------------------
# 4. Synergy, and the boundary of the law
# --------------------------------------------------------------------------------------


def demo_synergy_and_duplication() -> None:
    print("\n" + "=" * 86)
    print("3.  SYNERGY UNDER INDEPENDENCE — AND A NEGATIVE DEFICIT UNDER DUPLICATION")
    print("=" * 86)
    dials, labels = build_population()

    print("    (a) Synergy law on every pair of the coprime battery:")
    print(f"        {'pair':>8} {'I(k_i;L)':>10} {'I(k_j;L)':>10} {'sum':>10} {'I(joint;L)':>12} {'ok?':>5}")
    for i, j in combinations(range(len(dials)), 2):
        left = mutual_information(dials[i], labels) + mutual_information(dials[j], labels)
        right = mutual_information(joint(dials[i], dials[j]), labels)
        print(
            f"        {f'({i + 1},{j + 1})':>8} {mutual_information(dials[i], labels):>10.4f} "
            f"{mutual_information(dials[j], labels):>10.4f} {left:>10.4f} {right:>12.4f} "
            f"{'yes' if left <= right + 1e-12 else 'NO':>5}"
        )

    print("\n    (b) The boundary: two identical one-bit dials on a two-element population.")
    population_labels: List[int] = [0, 1]
    one_bit: List[int] = [0, 1]
    duplicate_reading = joint(one_bit, one_bit)
    joint_info = mutual_information(duplicate_reading, population_labels)
    additive = 2 * mutual_information(one_bit, population_labels)
    print(f"        I(joint of the two dials ; label) = {joint_info:.4f} bits")
    print(f"        additive bookkeeping              = {additive:.4f} bits")
    print(f"        deficit                           = {joint_info - additive:+.4f} bits")
    print("        -> strictly negative: the unguarded 'deficit always grows' claim is false.")

    print("\n    (c) A dial that is worthless alone but completes the classifier.")
    # population: pairs (a, b) in Z_4 x Z_4; label = (a + b) mod 4; dial 1 = a, dial 2 = b.
    a_col: List[int] = []
    b_col: List[int] = []
    xor_labels: List[int] = []
    for a in range(4):
        for b in range(4):
            a_col.append(a)
            b_col.append(b)
            xor_labels.append((a + b) % 4)
    marg_a = mutual_information(a_col, xor_labels)
    marg_b = mutual_information(b_col, xor_labels)
    both = mutual_information(joint(a_col, b_col), xor_labels)
    print(f"        population: all pairs (a,b) in Z_4 x Z_4, label L = (a+b) mod 4")
    print(f"        I(a;L) = {marg_a:.4f} bits,  I(b;L) = {marg_b:.4f} bits,  H(L) = {entropy(xor_labels):.4f} bits")
    print(f"        I((a,b);L) = {both:.4f} bits  -> deficit {both - marg_a - marg_b:+.4f} bits")
    print("        -> each dial alone carries exactly zero; together they saturate the ceiling.")


# --------------------------------------------------------------------------------------
# 5. Strong subadditivity, checked on random statistics
# --------------------------------------------------------------------------------------


def demo_strong_subadditivity(trials: int = 8, size: int = 400, seed: int = 27) -> None:
    print("\n" + "=" * 86)
    print("4.  STRONG SUBADDITIVITY  H(u,v,w) + H(u) <= H(u,v) + H(u,w)")
    print("=" * 86)
    rng = random.Random(seed)
    print(f"    {'trial':>5} {'H(u,v,w)+H(u)':>15} {'H(u,v)+H(u,w)':>15} {'slack = I(v;w|u)':>18} {'ok?':>5}")
    for trial in range(1, trials + 1):
        u = [rng.randrange(rng.choice([2, 3, 4])) for _ in range(size)]
        v = [rng.randrange(rng.choice([2, 3, 5])) for _ in range(size)]
        w = [(ui * rng.randrange(1, 4) + vi + rng.randrange(3)) % 6 for ui, vi in zip(u, v)]
        left = entropy(joint(u, v, w)) + entropy(u)
        right = entropy(joint(u, v)) + entropy(joint(u, w))
        print(
            f"    {trial:>5} {left:>15.5f} {right:>15.5f} {right - left:>18.5f} "
            f"{'yes' if left <= right + 1e-12 else 'NO':>5}"
        )
    print("\n    The slack is the conditional mutual information I(v;w|u) >= 0, which is what")
    print("    the Gibbs argument against the conditional product reference bounds.")


# --------------------------------------------------------------------------------------
# 6. Exact factor blindness
# --------------------------------------------------------------------------------------


def demo_factor_blindness(modulus: int = 5) -> None:
    print("\n" + "=" * 86)
    print("5.  THE WHICH-FACTOR WALL IS AN IDENTITY, NOT A SMALL NUMBER")
    print("=" * 86)
    pairs: List[Tuple[int, int]] = [
        (a, b) for a in range(modulus) for b in range(modulus) if a != b
    ]
    sum_dial: List[int] = [(a + b) % modulus for a, b in pairs]
    product_dial: List[int] = [(a * b) % modulus for a, b in pairs]
    which_factor: List[bool] = [a < b for a, b in pairs]

    print(f"    population: ordered pairs of distinct residues mod {modulus}  (N = {len(pairs)})")
    print(f"    H(sum dial)        = {entropy(sum_dial):.4f} bits   (a genuinely informative dial)")
    print(f"    H(which-factor bit)= {entropy(which_factor):.4f} bits   (a full bit)")
    print(f"    I(sum dial ; bit)            = {mutual_information(sum_dial, which_factor):.2e} bits")
    print(f"    I(product dial ; bit)        = {mutual_information(product_dial, which_factor):.2e} bits")
    two_dials = joint(sum_dial, product_dial)
    print(f"    I(both symmetric dials ; bit)= {mutual_information(two_dials, which_factor):.2e} bits")
    print("\n    Every symmetric reading is preserved by the swap involution (a,b) -> (b,a),")
    print("    which flips the bit; so each cell splits exactly in half and the capacity is")
    print("    identically zero — at every battery size.  Adding dials cannot help.")

    # For contrast: an asymmetric dial does see the bit.
    first_dial: List[int] = [a for a, _ in pairs]
    print(f"\n    contrast: I(first coordinate ; bit) = {mutual_information(first_dial, which_factor):.4f} bits")
    print("    -> breaking the symmetry is the only way to read the bit.")


# --------------------------------------------------------------------------------------
# 7. Consistency of the reported six-dial measurement with the laws
# --------------------------------------------------------------------------------------

REPORTED_I: Tuple[float, ...] = (1.0011, 2.1334, 4.0242, 8.2412, 11.5307, 12.7235)
REPORTED_MARGINALS: Tuple[float, ...] = (1.0011, 2.0020, 2.4777, 3.9120, 5.1591, 5.3650)
REPORTED_CEILING: Tuple[float, ...] = (float("nan"), 4.6063, 6.4947, 9.5434, 11.9557, 12.7726)


def demo_reported_table() -> None:
    print("\n" + "=" * 86)
    print("6.  THE MEASURED SIX-DIAL TABLE, TESTED AGAINST THE LAWS")
    print("=" * 86)
    deficits = [i - m for i, m in zip(REPORTED_I, REPORTED_MARGINALS)]
    header = f"{'k':>2} {'I(k)':>9} {'S marg':>9} {'deficit':>9} {'ceiling':>9} {'% ceiling':>10}"
    print(header)
    print("-" * len(header))
    for k, (info, marg, deficit, ceiling) in enumerate(
        zip(REPORTED_I, REPORTED_MARGINALS, deficits, REPORTED_CEILING), start=1
    ):
        pct = "     —" if math.isnan(ceiling) else f"{100 * info / ceiling:9.2f}%"
        ceil_str = "        —" if math.isnan(ceiling) else f"{ceiling:9.4f}"
        print(f"{k:>2} {info:>9.4f} {marg:>9.4f} {deficit:>+9.4f} {ceil_str} {pct:>10}")

    checks = {
        "curve strictly increasing": all(
            REPORTED_I[i] < REPORTED_I[i + 1] for i in range(len(REPORTED_I) - 1)
        ),
        "every value strictly below its ceiling": all(
            REPORTED_I[i] < REPORTED_CEILING[i] for i in range(1, len(REPORTED_I))
        ),
        "deficit strictly increasing": all(
            deficits[i] < deficits[i + 1] for i in range(len(deficits) - 1)
        ),
        "six-dial row above 99.6% of its ceiling": REPORTED_I[-1] > 0.996 * REPORTED_CEILING[-1],
    }
    print()
    for name, ok in checks.items():
        print(f"    {name:<44}: {ok}")

    gap = REPORTED_CEILING[-1] - REPORTED_I[-1]
    cap = REPORTED_CEILING[-1] - REPORTED_MARGINALS[-1]
    print(f"\n    residual ceiling gap at k = 6      : {gap:.4f} bits")
    print(f"    = average within-cell label entropy; e.g. a balanced binary ambiguity on")
    print(f"      {100 * gap:.1f}% of the population would account for it exactly.")
    print(f"    deficit cap  H(L) - S marginals    : {cap:.4f} bits")
    print(f"    measured deficit                   : {deficits[-1]:.4f} bits "
          f"({100 * deficits[-1] / cap:.1f}% of its structural maximum)")


# --------------------------------------------------------------------------------------


def main() -> None:
    demo_capacity_curve()
    demo_saturation_certificate()
    demo_synergy_and_duplication()
    demo_strong_subadditivity()
    demo_factor_blindness()
    demo_reported_table()
    print("\n" + "=" * 86)
    print("All demonstrations complete.")
    print("=" * 86)


if __name__ == "__main__":
    main()
