"""
Chained integer labels: width criterion, exact collapse counts, and the
two-sided collapse ceiling.
========================================================================

A pipeline that packs two discrete codes (a, b) into a single integer key

        pi_M(a, b) = a * M + b            ("frame" M)

is faithful if and only if the frame dominates the inner alphabet, B <= M.
This script demonstrates, numerically:

  1. The width criterion: B <= M  <=>  no two distinct pairs collide.
  2. The exact label count under a narrow frame:  M * (A - 1) + B
     (versus A * B genuine pairs), and the audited 36 -> 18 collapse.
  3. The entropy-deficit calculus: merging destroys entropy, strictly, and
     by at most  (block mass) * log2(block size), attained by uniform blocks.
  4. Encoding invariance: an injective relabelling leaves mutual information
     exactly unchanged.
  5. The signed data-processing law: a collision-producing relabelling can
     only LOWER mutual information -- so the larger of two readings on one
     population is the admissible one.
  6. The collapse ceiling: a k-bounded merge destroys at most log2(k) bits of
     label entropy and at most log2(k) bits of mutual information; a 2-to-1
     merge costs at most one bit; and the information lost never exceeds the
     label entropy lost.
  7. The forensic audit protocol applied to the disputed readings.

Self-contained: standard library only.
"""

from __future__ import annotations

import math
import random
from itertools import product
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Pair = Tuple[int, int]

# ----------------------------------------------------------------------
# 1. Chained labels and the width criterion
# ----------------------------------------------------------------------


def chain(frame: int, outer: int, inner: int) -> int:
    """The chained integer label  pi_M(a, b) = a * M + b."""
    return outer * frame + inner


def population(a_size: int, b_size: int) -> List[Pair]:
    """All genuine code pairs {0..A-1} x {0..B-1}."""
    return [(a, b) for a in range(a_size) for b in range(b_size)]


def width_ok(b_size: int, frame: int) -> bool:
    """The audit check: the frame must dominate the inner alphabet."""
    return b_size <= frame


def has_collision(a_size: int, b_size: int, frame: int) -> bool:
    """Brute-force search for two distinct pairs sharing a chained label."""
    seen: Dict[int, Pair] = {}
    for pair in population(a_size, b_size):
        label = chain(frame, *pair)
        if label in seen and seen[label] != pair:
            return True
        seen[label] = pair
    return False


def distinct_labels(a_size: int, b_size: int, frame: int) -> int:
    """Number of distinct chained labels actually produced."""
    return len({chain(frame, a, b) for a, b in population(a_size, b_size)})


def predicted_labels(a_size: int, b_size: int, frame: int) -> int:
    """Closed form: A*B if the frame is wide, else M*(A-1)+B."""
    if frame >= b_size:
        return a_size * b_size
    return frame * (a_size - 1) + b_size


def fiber_profile(a_size: int, b_size: int, frame: int) -> Dict[int, List[Pair]]:
    """Map each produced label to the list of genuine pairs merged into it."""
    fibers: Dict[int, List[Pair]] = {}
    for pair in population(a_size, b_size):
        fibers.setdefault(chain(frame, *pair), []).append(pair)
    return fibers


# ----------------------------------------------------------------------
# 2. Entropy in bits, and the deficit of a merged block
# ----------------------------------------------------------------------


def eta(t: float) -> float:
    """Pointwise Shannon term -t*log2(t), with the convention eta(0) = 0."""
    return 0.0 if t <= 0.0 else -t * math.log2(t)


def entropy(weights: Iterable[float]) -> float:
    """Shannon entropy (bits) of a nonnegative, not necessarily normalised weight."""
    return sum(eta(w) for w in weights)


def deficit(weights: Sequence[float]) -> float:
    """Entropy destroyed by collapsing a block into one atom of the total mass."""
    return entropy(weights) - eta(sum(weights))


def deficit_closed_form(weights: Sequence[float]) -> float:
    """The closed form  sum_i w_i * (log2 S - log2 w_i),  S = sum_i w_i."""
    total = sum(weights)
    if total <= 0.0:
        return 0.0
    return sum(w * (math.log2(total) - math.log2(w)) for w in weights if w > 0.0)


def deficit_ceiling(weights: Sequence[float]) -> float:
    """The maximum-entropy bound  (block mass) * log2(block size)."""
    n = len(weights)
    return sum(weights) * math.log2(n) if n > 0 else 0.0


# ----------------------------------------------------------------------
# 3. Joint weights, pushforwards, mutual information
# ----------------------------------------------------------------------

Joint = Dict[Tuple[Pair, int], float]


def marginal_first(joint: Joint) -> Dict[Pair, float]:
    out: Dict[Pair, float] = {}
    for (x, _y), w in joint.items():
        out[x] = out.get(x, 0.0) + w
    return out


def marginal_second(joint: Joint) -> Dict[int, float]:
    out: Dict[int, float] = {}
    for (_x, y), w in joint.items():
        out[y] = out.get(y, 0.0) + w
    return out


def mutual_information(joint: Joint) -> float:
    """I(p) = H(first marginal) + H(second marginal) - H(joint), in bits."""
    return (
        entropy(marginal_first(joint).values())
        + entropy(marginal_second(joint).values())
        - entropy(joint.values())
    )


def push_first(joint: Joint, label: Callable[[Pair], int]) -> Dict[Tuple[int, int], float]:
    """Relabel the first coordinate, summing the weights of merged classes."""
    out: Dict[Tuple[int, int], float] = {}
    for (x, y), w in joint.items():
        key = (label(x), y)
        out[key] = out.get(key, 0.0) + w
    return out


def mutual_information_generic(joint: Dict[Tuple[object, object], float]) -> float:
    first: Dict[object, float] = {}
    second: Dict[object, float] = {}
    for (x, y), w in joint.items():
        first[x] = first.get(x, 0.0) + w
        second[y] = second.get(y, 0.0) + w
    return entropy(first.values()) + entropy(second.values()) - entropy(joint.values())


def push_entropy(joint: Dict[Tuple[object, object], float]) -> float:
    """Entropy of the (relabelled) first marginal -- the 'label entropy' column."""
    first: Dict[object, float] = {}
    for (x, _y), w in joint.items():
        first[x] = first.get(x, 0.0) + w
    return entropy(first.values())


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------


def demo_width_criterion() -> None:
    print("=" * 72)
    print("1. WIDTH CRITERION:  B <= M  <=>  no collisions")
    print("=" * 72)
    a_size, b_size = 4, 9
    print(f"population: A = {a_size} outer codes, B = {b_size} inner codes "
          f"({a_size * b_size} genuine pairs)\n")
    print(f"{'frame M':>8} | {'width ok?':>9} | {'collides?':>9} | {'agree':>6}")
    print("-" * 44)
    for frame in [1, 2, 3, 5, 8, 9, 10, 100, 10000]:
        ok = width_ok(b_size, frame)
        col = has_collision(a_size, b_size, frame)
        print(f"{frame:>8} | {str(ok):>9} | {str(col):>9} | {str(ok != col):>6}")
    print("\nThe last column is always True: width validity is EXACTLY the")
    print("absence of collisions -- not a sufficient heuristic, an equivalence.\n")

    # the canonical collision guaranteed by the theory, for every narrow frame
    frame = 3
    print(f"canonical collision for M = {frame} < B = {b_size}:")
    print(f"  pi(0, {frame}) = {chain(frame, 0, frame)}   and   "
          f"pi(1, 0) = {chain(frame, 1, 0)}   -- same label, different pairs\n")


def demo_exact_counts() -> None:
    print("=" * 72)
    print("2. EXACT LABEL COUNTS:  A*B  vs  M*(A-1)+B")
    print("=" * 72)
    print(f"{'A':>3} {'B':>3} {'M':>6} | {'pairs':>6} {'observed':>9} "
          f"{'predicted':>10} | {'image is interval?':>19}")
    print("-" * 68)
    for a_size, b_size, frame in [
        (4, 9, 3), (4, 9, 9), (4, 9, 10000), (6, 6, 2), (3, 12, 5),
        (7, 5, 5), (2, 100, 1), (5, 8, 8),
    ]:
        observed = distinct_labels(a_size, b_size, frame)
        pred = predicted_labels(a_size, b_size, frame)
        labels = sorted({chain(frame, a, b) for a, b in population(a_size, b_size)})
        is_interval = labels == list(range(labels[0], labels[-1] + 1))
        flag = "yes" if (frame <= b_size and is_interval) else ("n/a" if frame > b_size else "NO")
        assert observed == pred, "closed form must match enumeration"
        print(f"{a_size:>3} {b_size:>3} {frame:>6} | {a_size * b_size:>6} "
              f"{observed:>9} {pred:>10} | {flag:>19}")
    print("\nUnder a narrow frame the produced labels form an UNBROKEN interval")
    print("[0, M(A-1)+B): the strips [aM, aM+B) overlap like roof shingles.\n")

    print("The audited instance (A, B) = (4, 9):")
    wide = distinct_labels(4, 9, 10000)
    narrow = distinct_labels(4, 9, 3)
    print(f"  width-valid frame  M = 10000 -> {wide} labels")
    print(f"  narrow frame       M = 3     -> {narrow} labels")
    print(f"  ratio: {wide} = 2 x {narrow}  -- exactly half the classes merged\n")

    fibers = fiber_profile(4, 9, 3)
    sizes = sorted({len(v) for v in fibers.values()})
    worst = max(len(v) for v in fibers.values())
    print(f"  fiber sizes present: {sizes}; maximal fiber k = {worst}")
    print(f"  => collapse ceiling log2(k) = {math.log2(worst):.4f} bits\n")


def demo_deficit_calculus() -> None:
    print("=" * 72)
    print("3. THE ENTROPY DEFICIT: merging loses, strictly, and by at most")
    print("   (mass) x log2(block size)")
    print("=" * 72)
    blocks: List[Tuple[str, List[float]]] = [
        ("uniform pair          ", [0.5, 0.5]),
        ("skewed pair           ", [0.9, 0.1]),
        ("uniform triple        ", [1 / 3, 1 / 3, 1 / 3]),
        ("degenerate triple     ", [1.0, 0.0, 0.0]),
        ("two atoms of 1/36     ", [1 / 36, 1 / 36]),
        ("uniform 8-block       ", [1 / 8] * 8),
    ]
    print(f"{'block':<24} {'deficit':>9} {'closed form':>12} {'ceiling':>9} {'tight?':>7}")
    print("-" * 66)
    for name, w in blocks:
        d = deficit(w)
        c = deficit_closed_form(w)
        cap = deficit_ceiling(w)
        assert abs(d - c) < 1e-12, "definition and closed form must agree"
        assert d <= cap + 1e-12, "the ceiling must hold"
        tight = "yes" if abs(d - cap) < 1e-12 else "no"
        print(f"{name:<24} {d:>9.5f} {c:>12.5f} {cap:>9.5f} {tight:>7}")
    print("\nThe ceiling is attained exactly by the uniform block: a uniform")
    print("k-atom fiber carrying all the mass loses exactly log2(k) bits.\n")

    print("Gibbs' inequality needs absolute continuity (0*log0 = 0 is a trap):")
    a = [0.5, 0.5]
    b = [1.0, 0.0]
    kl = sum(ai * (math.log2(ai) - (math.log2(bi) if bi > 0 else 0.0))
             for ai, bi in zip(a, b))
    print(f"  a = {a}, b = {b}, equal total mass, naive relative entropy = {kl:+.1f} bits")
    print("  -- negative! The hypothesis 'b_i = 0 => a_i = 0' is load-bearing.\n")


def random_joint(a_size: int, b_size: int, y_size: int, seed: int = 20260822) -> Joint:
    """A random joint probability weight on (code pairs) x (outcomes)."""
    rng = random.Random(seed)
    raw = {
        ((a, b), y): rng.random() ** 2
        for a, b in population(a_size, b_size)
        for y in range(y_size)
    }
    total = sum(raw.values())
    return {k: v / total for k, v in raw.items()}


def structured_joint(a_size: int, b_size: int, y_size: int, seed: int = 7,
                     signal: float = 0.85) -> Joint:
    """A joint weight with a genuine channel: the outcome depends on the pair."""
    rng = random.Random(seed)
    raw: Joint = {}
    for a, b in population(a_size, b_size):
        preferred = (a + b) % y_size
        for y in range(y_size):
            base = signal if y == preferred else (1.0 - signal) / max(y_size - 1, 1)
            raw[((a, b), y)] = base * (0.5 + rng.random())
    total = sum(raw.values())
    return {k: v / total for k, v in raw.items()}


def demo_invariance_and_dpi() -> None:
    print("=" * 72)
    print("4-5. ENCODING INVARIANCE AND THE SIGNED DATA-PROCESSING LAW")
    print("=" * 72)
    a_size, b_size, y_size = 4, 9, 5
    joint = structured_joint(a_size, b_size, y_size)
    base = mutual_information(joint)
    print(f"population: {a_size}x{b_size} code pairs, {y_size} outcomes")
    print(f"true mutual information of the pair-vs-outcome channel: {base:.6f} bits\n")

    print(f"{'frame M':>8} | {'labels':>6} | {'max fiber':>9} | {'I(reading)':>11} "
          f"| {'drop':>8} | {'ceiling log2 k':>14}")
    print("-" * 74)
    for frame in [10000, 100, 9, 8, 5, 3, 2, 1]:
        labelled = push_first(joint, lambda x, m=frame: chain(m, x[0], x[1]))
        val = mutual_information_generic(labelled)
        fibers = fiber_profile(a_size, b_size, frame)
        k = max(len(v) for v in fibers.values())
        n_labels = len(fibers)
        drop = base - val
        cap = math.log2(k)
        assert drop >= -1e-12, "data processing: a relabelling can only lose"
        assert drop <= cap + 1e-9, "collapse ceiling must hold"
        print(f"{frame:>8} | {n_labels:>6} | {k:>9} | {val:>11.6f} | {drop:>8.6f} "
              f"| {cap:>14.6f}")
    print("\n* Every width-valid frame (M >= 9) reports the SAME value to the last")
    print("  digit: relabelling is renaming, not analysis (encoding invariance).")
    print("* Every drop is nonnegative: collision artifacts are SIGNED -- they")
    print("  deflate a measurement and never inflate it.")
    print("* Every drop respects its own log2(k) ceiling.\n")

    print("Information lost never exceeds LABEL ENTROPY lost:")
    print(f"{'frame M':>8} | {'dH (labels)':>12} | {'dI (channel)':>13} | {'dI <= dH':>9}")
    print("-" * 52)
    h_base = push_entropy({((a, b), y): w for ((a, b), y), w in joint.items()})
    for frame in [9, 5, 3, 2, 1]:
        labelled = push_first(joint, lambda x, m=frame: chain(m, x[0], x[1]))
        d_h = h_base - push_entropy(labelled)
        d_i = base - mutual_information_generic(labelled)
        ok = d_i <= d_h + 1e-9
        assert ok
        print(f"{frame:>8} | {d_h:>12.6f} | {d_i:>13.6f} | {str(ok):>9}")
    print()


def demo_two_to_one() -> None:
    print("=" * 72)
    print("6. A TWO-TO-ONE MERGE COSTS AT MOST ONE BIT (100 random trials)")
    print("=" * 72)
    worst = 0.0
    for seed in range(100):
        joint = random_joint(4, 2, 4, seed=seed)
        # a labelling whose fibers have at most two elements: forget the last bit
        labelled = push_first(joint, lambda x: chain(1, x[0], 0))
        drop = mutual_information(joint) - mutual_information_generic(labelled)
        assert -1e-12 <= drop <= 1.0 + 1e-9
        worst = max(worst, drop)
    print(f"maximal observed information drop over 100 random populations: "
          f"{worst:.6f} bits")
    print("theoretical ceiling for a 2-to-1 merge: 1.000000 bits")
    print("contrapositive: a drop above one bit PROVES some label swallowed")
    print("at least three distinct classes.\n")


def demo_audit_protocol() -> None:
    print("=" * 72)
    print("7. THE FORENSIC AUDIT PROTOCOL ON THE DISPUTED READINGS")
    print("=" * 72)
    rows = [
        ("original          ", 10000, 36, 4.6006, 2.1314),
        ("clean re-impl.    ", 10000, 36, 4.6006, 2.1314),
        ("rebuild           ", 3, 18, 3.6073, 0.5830),
    ]
    print(f"{'construction':<20} {'frame':>7} {'labels':>7} {'H(labels)':>10} {'I(joint)':>9}")
    print("-" * 58)
    for name, frame, labels, h, i in rows:
        print(f"{name:<20} {frame:>7} {labels:>7} {h:>10.4f} {i:>9.4f}")
    print()

    a_size, b_size = 4, 9
    print("CHECK W (width).")
    for name, frame, labels, _h, _i in rows[::2]:
        ok = width_ok(b_size, frame)
        pred = predicted_labels(a_size, b_size, frame)
        print(f"  {name.strip():<18} frame {frame:>5}: width ok = {ok},"
              f" predicted labels = {pred}, reported = {labels}"
              f"  [{'match' if pred == labels else 'MISMATCH'}]")
    print()

    print("CHECK D (direction).")
    print("  The original encoding is width-valid, the rebuild's is not, and both")
    print("  act on one population. A width-valid reading dominates every other")
    print("  reading, so the admissible value is the LARGER one: 2.1314 bits.")
    print("  The independent clean re-implementation reproduces it exactly -- which")
    print("  is what encoding invariance predicts, not a coincidence.\n")

    print("CHECK C (ceiling).")
    k = max(len(v) for v in fiber_profile(a_size, b_size, 3).values())
    cap = math.log2(k)
    d_i = 2.1314 - 0.5830
    d_h = 4.6006 - 3.6073
    print(f"  maximal narrow-frame fiber k = {k}, ceiling log2(k) = {cap:.4f} bits")
    print(f"  observed information drop dI = {d_i:.4f} bits"
          f"   [{'PASS' if d_i <= cap else 'FAIL'}, margin {cap - d_i:+.4f}]")
    print(f"  observed label-entropy drop dH = {d_h:.4f} bits")
    print(f"  sharp test dI <= dH:  {d_i:.4f} <= {d_h:.4f} ?  "
          f"{'PASS' if d_i <= d_h else 'FAIL'}")
    print("  The magnitude of the gap is admissible under a class merge, but the")
    print("  sharp test fails: a single merge of the joint label cannot lower the")
    print("  information by more than it lowers the label entropy. The two rows")
    print("  therefore differ in MORE than the frame width -- a residual for a")
    print("  targeted re-run to localise.\n")

    print("Calibration: reported per-coordinate marginals 1.0012 + 1.0012 = 2.0024")
    print(f"bits against a joint value of 2.1314 bits; the excess "
          f"{2.1314 - 2 * 1.0012:.4f} bits")
    print("is genuine synergy between the dials -- the first thing a merge destroys.\n")


def main() -> None:
    demo_width_criterion()
    demo_exact_counts()
    demo_deficit_calculus()
    demo_invariance_and_dpi()
    demo_two_to_one()
    demo_audit_protocol()
    print("=" * 72)
    print("All assertions passed: enumerated counts match the closed forms, every")
    print("deficit is nonnegative and under its ceiling, every width-valid frame")
    print("gives an identical reading, and every coarsening only loses.")
    print("=" * 72)


if __name__ == "__main__":
    main()
