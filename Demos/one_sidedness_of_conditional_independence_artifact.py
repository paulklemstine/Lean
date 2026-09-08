"""
One-Sidedness of Conditional-Independence Artifacts
===================================================

Numerical companion to the paper.  Everything is self-contained: the entropy
functional, the fiber deficit, mutual information, conditional mutual
information, label merges, and every theorem-level identity is recomputed
numerically on explicit tables.

Conventions
-----------
*   A *weight* is an arbitrary nonnegative function on a finite product set.
    Nothing is normalised: total mass may be any nonnegative number.
*   All logarithms are base 2, so all quantities are in bits.
*   `nlp(w) = -w log2 w`, with `nlp(0) = 0`.
*   `H(w) = sum_x nlp(w(x))`.
*   `D(S, w) = H(w restricted to S) - nlp(sum_{x in S} w(x))`  (the *fiber
    deficit*: the entropy inside the block that is destroyed by pooling it).
*   `MI(q) = H(q_X) + H(q_Y) - H(q)` for a weight `q` on `X x Y`.
*   `CMI(p) = sum_z [ MI(p_z) - nlp(mass(p_z)) ]` for a weight `p` on
    `X x Y x Z`, where `p_z` is the `z`-slice.

Run with:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Tuple

Cell3 = Tuple[Hashable, Hashable, Hashable]
Cell2 = Tuple[Hashable, Hashable]
Table3 = Dict[Cell3, float]
Table2 = Dict[Cell2, float]

TOL = 1e-9


# ---------------------------------------------------------------------------
# Core information-theoretic functionals
# ---------------------------------------------------------------------------


def nlp(w: float) -> float:
    """The Shannon term -w log2 w, extended by nlp(0) = 0."""
    if w <= 0.0:
        return 0.0
    return -w * math.log2(w)


def entropy(values: Iterable[float]) -> float:
    """H(w) = sum of Shannon terms.  No normalisation is assumed."""
    return sum(nlp(v) for v in values)


def deficit(values: Sequence[float]) -> float:
    """Fiber deficit D(S, w) = H(w|_S) - nlp(sum_S w).

    This is the entropy that is destroyed when the block S is pooled into a
    single label.  It is nonnegative (Gibbs), and zero exactly when at most one
    element of the block carries mass.
    """
    return entropy(values) - nlp(sum(values))


def marg1(q: Table2, xs: Sequence[Hashable], ys: Sequence[Hashable]) -> Dict[Hashable, float]:
    """Row sums of a two-way table: q_X(x) = sum_y q(x, y)."""
    return {x: sum(q.get((x, y), 0.0) for y in ys) for x in xs}


def marg2(q: Table2, xs: Sequence[Hashable], ys: Sequence[Hashable]) -> Dict[Hashable, float]:
    """Column sums of a two-way table: q_Y(y) = sum_x q(x, y)."""
    return {y: sum(q.get((x, y), 0.0) for x in xs) for y in ys}


def mass(q: Table2) -> float:
    """Total mass of a two-way table."""
    return sum(q.values())


def MI(q: Table2, xs: Sequence[Hashable], ys: Sequence[Hashable]) -> float:
    """Unnormalised mutual information MI(q) = H(q_X) + H(q_Y) - H(q)."""
    return (
        entropy(marg1(q, xs, ys).values())
        + entropy(marg2(q, xs, ys).values())
        - entropy(q.get((x, y), 0.0) for x in xs for y in ys)
    )


def slice_at(p: Table3, z: Hashable) -> Table2:
    """The z-slice of a three-way table."""
    return {(x, y): v for (x, y, zz), v in p.items() if zz == z}


def CMI(
    p: Table3,
    xs: Sequence[Hashable],
    ys: Sequence[Hashable],
    zs: Sequence[Hashable],
) -> float:
    """Conditional mutual information I(X;Y|Z), summed slice by slice.

    For each context z we take the slice reading MI(p_z) and subtract the
    Shannon term of the slice mass; for a probability table this reduces to the
    textbook  sum p(x,y,z) log2 [ p(x,y,z) p(z) / (p(x,z) p(y,z)) ].
    """
    total = 0.0
    for z in zs:
        s = slice_at(p, z)
        total += MI(s, xs, ys) - nlp(mass(s))
    return total


# ---------------------------------------------------------------------------
# Label merges
# ---------------------------------------------------------------------------


def fiber(f: Callable[[Hashable], Hashable], u: Hashable, xs: Sequence[Hashable]) -> List[Hashable]:
    """The fiber f^{-1}(u) inside the dial alphabet xs."""
    return [x for x in xs if f(x) == u]


def push_fst3(
    f: Callable[[Hashable], Hashable],
    p: Table3,
    xs: Sequence[Hashable],
    ys: Sequence[Hashable],
    zs: Sequence[Hashable],
    us: Sequence[Hashable],
) -> Table3:
    """Merge the dial alphabet: (f_* p)(u, y, z) = sum_{x in f^{-1}(u)} p(x,y,z)."""
    out: Table3 = {}
    for u in us:
        fib = fiber(f, u, xs)
        for y in ys:
            for z in zs:
                out[(u, y, z)] = sum(p.get((x, y, z), 0.0) for x in fib)
    return out


def push_thd(
    f: Callable[[Hashable], Hashable],
    p: Table3,
    xs: Sequence[Hashable],
    ys: Sequence[Hashable],
    zs: Sequence[Hashable],
    ws: Sequence[Hashable],
) -> Table3:
    """Merge the *context* alphabet.  No one-sidedness holds for this."""
    out: Table3 = {}
    for x in xs:
        for y in ys:
            for w in ws:
                out[(x, y, w)] = sum(p.get((x, y, z), 0.0) for z in zs if f(z) == w)
    return out


def label_loss(
    f: Callable[[Hashable], Hashable],
    p: Table3,
    xs: Sequence[Hashable],
    ys: Sequence[Hashable],
    z: Hashable,
    us: Sequence[Hashable],
) -> float:
    """Label entropy destroyed by f inside the context z.

    labelLoss(z) = H(dial marginal in context z) - H(merged dial marginal).
    Only the *marginal* dial counts are needed, so an auditor can compute this
    without ever seeing the joint table.
    """
    s = slice_at(p, z)
    m1 = marg1(s, xs, ys)
    merged = {u: sum(m1[x] for x in fiber(f, u, xs)) for u in us}
    return entropy(m1.values()) - entropy(merged.values())


def marg_xz(
    p: Table3, xs: Sequence[Hashable], ys: Sequence[Hashable], zs: Sequence[Hashable]
) -> Table2:
    """The context channel table: (x, z) |-> sum_y p(x, y, z)."""
    return {(x, z): sum(p.get((x, y, z), 0.0) for y in ys) for x in xs for z in zs}


def as_pair_table(
    p: Table3, xs: Sequence[Hashable], ys: Sequence[Hashable], zs: Sequence[Hashable]
) -> Table2:
    """Read a three-way table as the two-way table of X against the pair (Y,Z)."""
    return {(x, (y, z)): p.get((x, y, z), 0.0) for x in xs for y in ys for z in zs}


# ---------------------------------------------------------------------------
# Example populations
# ---------------------------------------------------------------------------

BOOLS: List[Hashable] = [False, True]


def xor_population() -> Table3:
    """Uniform weight 1/4 on the four cells with z = x XOR y."""
    return {
        (x, y, z): (0.25 if ((x != y) == z) else 0.0)
        for x in BOOLS
        for y in BOOLS
        for z in BOOLS
    }


def copy_population() -> Table3:
    """Uniform weight 1/2 on the two cells with x = y = z."""
    return {
        (x, y, z): (0.5 if (x == y == z) else 0.0)
        for x in BOOLS
        for y in BOOLS
        for z in BOOLS
    }


def random_population(
    nx: int, ny: int, nz: int, rng: random.Random, sparsity: float = 0.25
) -> Table3:
    """A random nonnegative (unnormalised) weight on an nx x ny x nz grid."""
    p: Table3 = {}
    for x in range(nx):
        for y in range(ny):
            for z in range(nz):
                p[(x, y, z)] = 0.0 if rng.random() < sparsity else rng.random()
    return p


# ---------------------------------------------------------------------------
# Checks corresponding to the theorems
# ---------------------------------------------------------------------------


def check(name: str, ok: bool, detail: str = "") -> None:
    flag = "OK  " if ok else "FAIL"
    print(f"  [{flag}] {name}" + (f"   {detail}" if detail else ""))
    if not ok:
        raise AssertionError(name)


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_witnesses() -> None:
    banner("1.  Two witness populations on {0,1}^3")

    xs = ys = zs = BOOLS
    xor = xor_population()
    cop = copy_population()

    xor_cmi = CMI(xor, xs, ys, zs)
    xor_single = MI({(x, y): sum(xor[(x, y, z)] for z in zs) for x in xs for y in ys}, xs, ys)
    cop_cmi = CMI(cop, xs, ys, zs)
    cop_single = MI({(x, y): sum(cop[(x, y, z)] for z in zs) for x in xs for y in ys}, xs, ys)

    print(f"  XOR population :  I(X;Y) = {xor_single:.6f} bits,  I(X;Y|Z) = {xor_cmi:.6f} bits")
    print(f"  copy population:  I(X;Y) = {cop_single:.6f} bits,  I(X;Y|Z) = {cop_cmi:.6f} bits")

    check("XOR: single-dial reading is 0", abs(xor_single) < TOL)
    check("XOR: conditional reading is 1 bit", abs(xor_cmi - 1.0) < TOL)
    check("copy: single-dial reading is 1 bit", abs(cop_single - 1.0) < TOL)
    check("copy: conditional reading is 0", abs(cop_cmi) < TOL)
    print("  => conditional and single-dial readings are logically independent:")
    print("     neither one bounds the other.")

    merge_all: Callable[[Hashable], Hashable] = lambda _: True
    merged = push_fst3(merge_all, xor, xs, ys, zs, [True])
    merged_cmi = CMI(merged, [True], ys, zs)
    print(f"\n  Collapsing merge f(x) = * applied to XOR:  reading = {merged_cmi:.6f} bits")
    check("a reported conditional independence can be a pure artifact",
          abs(merged_cmi) < TOL and xor_cmi > TOL)

    total_label_loss = sum(label_loss(merge_all, xor, xs, ys, z, [True]) for z in zs)
    print(f"  observable label-entropy loss           = {total_label_loss:.6f} bits")
    check("error bar is attained exactly on this witness",
          abs((xor_cmi - merged_cmi) - total_label_loss) < TOL)


def demo_one_sidedness(trials: int = 400) -> None:
    banner("2.  One-sidedness: a dial merge never inflates the reading")

    rng = random.Random(20240908)
    xs = list(range(4))
    ys = list(range(3))
    zs = list(range(3))
    us = list(range(2))

    worst_violation = 0.0
    strict_drops = 0
    for _ in range(trials):
        p = random_population(len(xs), len(ys), len(zs), rng)
        # a random merge of the 4 dial settings onto 2 labels
        table = {x: rng.choice(us) for x in xs}
        f: Callable[[Hashable], Hashable] = lambda x, t=table: t[x]
        true_reading = CMI(p, xs, ys, zs)
        merged_reading = CMI(push_fst3(f, p, xs, ys, zs, us), us, ys, zs)
        worst_violation = max(worst_violation, merged_reading - true_reading)
        if merged_reading < true_reading - TOL:
            strict_drops += 1

    print(f"  {trials} random populations and random merges.")
    print(f"  largest observed value of  I(f(X);Y|Z) - I(X;Y|Z)  =  {worst_violation:.3e}")
    print(f"  strictly lowered readings: {strict_drops}/{trials}")
    check("no merge ever raised the conditional reading", worst_violation < TOL)


def demo_exact_accounting(trials: int = 200) -> None:
    banner("3.  Exact accounting: where the lost bits went")

    rng = random.Random(11235)
    xs = list(range(4))
    ys = list(range(3))
    zs = list(range(2))
    us = list(range(2))

    worst = 0.0
    sample_printed = False
    for _ in range(trials):
        p = random_population(len(xs), len(ys), len(zs), rng)
        table = {x: rng.choice(us) for x in xs}
        f: Callable[[Hashable], Hashable] = lambda x, t=table: t[x]

        loss = CMI(p, xs, ys, zs) - CMI(push_fst3(f, p, xs, ys, zs, us), us, ys, zs)

        localised = 0.0
        contributions: List[Tuple[Hashable, Hashable, float]] = []
        for z in zs:
            s = slice_at(p, z)
            m1 = marg1(s, xs, ys)
            for u in us:
                fib = fiber(f, u, xs)
                marg_def = deficit([m1[x] for x in fib])
                sliced_def = sum(deficit([s.get((x, y), 0.0) for x in fib]) for y in ys)
                contributions.append((z, u, marg_def - sliced_def))
                localised += marg_def - sliced_def

        worst = max(worst, abs(loss - localised))
        if not sample_printed:
            sample_printed = True
            print("  A single example, broken down by (context, fiber):")
            for z, u, c in contributions:
                print(f"    context z={z}, fiber f^-1({u}):  contributes {c:.6f} bits of loss")
            print(f"    total localised loss = {localised:.6f} bits")
            print(f"    actual drop in the reading = {loss:.6f} bits")

    print(f"\n  Over {trials} random instances, worst mismatch between the drop and the")
    print(f"  sum of its (context, fiber) contributions: {worst:.3e}")
    check("exact loss identity holds", worst < 1e-8)


def demo_error_bar(trials: int = 200) -> None:
    banner("4.  The observable error bar")

    rng = random.Random(31415)
    xs = list(range(5))
    ys = list(range(3))
    zs = list(range(2))
    us = list(range(3))

    slack: List[float] = []
    for _ in range(trials):
        p = random_population(len(xs), len(ys), len(zs), rng)
        table = {x: rng.choice(us) for x in xs}
        f: Callable[[Hashable], Hashable] = lambda x, t=table: t[x]
        loss = CMI(p, xs, ys, zs) - CMI(push_fst3(f, p, xs, ys, zs, us), us, ys, zs)
        bar = sum(label_loss(f, p, xs, ys, z, us) for z in zs)
        check_ok = -TOL <= loss <= bar + TOL
        if not check_ok:
            raise AssertionError("error bar violated")
        slack.append(bar - loss)

    print(f"  {trials} random instances; in every one")
    print("      0 <= I(X;Y|Z) - I(f(X);Y|Z) <= (label entropy destroyed by f).")
    print(f"  mean slack in the upper bound: {sum(slack) / len(slack):.6f} bits")
    print(f"  minimum slack observed:        {min(slack):.6f} bits")

    # exactness without injectivity: merge two dial settings that never co-occur
    p: Table3 = {}
    for x in xs:
        for y in ys:
            for z in zs:
                p[(x, y, z)] = 0.0
    #  dial 0 only ever fires in context 0, dial 1 only in context 1,
    #  so the merge {0,1} -> 0 destroys no label entropy in either context,
    #  while dials 2 and 3 keep the reading strictly positive.
    p[(0, 0, 0)] = 0.30
    p[(0, 1, 0)] = 0.10
    p[(2, 0, 0)] = 0.10
    p[(2, 1, 0)] = 0.30
    p[(3, 0, 0)] = 0.20
    p[(3, 1, 0)] = 0.05
    p[(1, 0, 1)] = 0.20
    p[(1, 2, 1)] = 0.40
    coll = {0: 0, 1: 0, 2: 1, 3: 2, 4: 3}
    collide: Callable[[Hashable], Hashable] = lambda x, t=coll: t[x]
    lhs = CMI(push_fst3(collide, p, xs, ys, zs, [0, 1, 2, 3]), [0, 1, 2, 3], ys, zs)
    rhs = CMI(p, xs, ys, zs)
    print("\n  Exactness without injectivity: merging two settings that never occur")
    print("  in the same context leaves the reading untouched.")
    print(f"      merged reading = {lhs:.6f}   true reading = {rhs:.6f}")
    check("no label entropy destroyed => exact reading", abs(lhs - rhs) < TOL)


def demo_chain_rule(trials: int = 200) -> None:
    banner("5.  The chain rule: conditional readings from two ordinary tables")

    rng = random.Random(2718)
    xs = list(range(4))
    ys = list(range(3))
    zs = list(range(3))

    worst = 0.0
    for _ in range(trials):
        p = random_population(len(xs), len(ys), len(zs), rng)
        pair_alphabet = [(y, z) for y in ys for z in zs]
        lhs = CMI(p, xs, ys, zs)
        rhs = MI(as_pair_table(p, xs, ys, zs), xs, pair_alphabet) - MI(
            marg_xz(p, xs, ys, zs), xs, zs
        )
        worst = max(worst, abs(lhs - rhs))

    print(f"  Over {trials} random weights, worst deviation in")
    print("      I(X;Y|Z) = I(X;(Y,Z)) - I(X;Z)")
    print(f"  is {worst:.3e}.")
    check("chain rule holds for arbitrary nonnegative weights", worst < 1e-8)

    xor = xor_population()
    pair_alphabet = [(y, z) for y in BOOLS for z in BOOLS]
    print("\n  On the XOR witness:")
    print(f"    I(X;(Y,Z)) = {MI(as_pair_table(xor, BOOLS, BOOLS, BOOLS), BOOLS, pair_alphabet):.6f}")
    print(f"    I(X;Z)     = {MI(marg_xz(xor, BOOLS, BOOLS, BOOLS), BOOLS, BOOLS):.6f}")
    print(f"    I(X;Y|Z)   = {CMI(xor, BOOLS, BOOLS, BOOLS):.6f}")


def demo_chaining(trials: int = 150) -> None:
    banner("6.  Chained merges: errors accumulate with a fixed sign")

    rng = random.Random(1618)
    xs = list(range(6))
    ys = list(range(3))
    zs = list(range(2))
    mid = list(range(4))
    out = list(range(2))

    worst_comp = 0.0
    worst_mono = 0.0
    for _ in range(trials):
        p = random_population(len(xs), len(ys), len(zs), rng)
        tf = {x: rng.choice(mid) for x in xs}
        tg = {u: rng.choice(out) for u in mid}
        f: Callable[[Hashable], Hashable] = lambda x, t=tf: t[x]
        g: Callable[[Hashable], Hashable] = lambda u, t=tg: t[u]

        once = push_fst3(f, p, xs, ys, zs, mid)
        twice = push_fst3(g, once, mid, ys, zs, out)
        direct = push_fst3(lambda x, a=tf, b=tg: b[a[x]], p, xs, ys, zs, out)

        worst_comp = max(
            worst_comp, max(abs(twice[k] - direct[k]) for k in direct)
        )
        r_full = CMI(p, xs, ys, zs)
        r_once = CMI(once, mid, ys, zs)
        r_twice = CMI(twice, out, ys, zs)
        worst_mono = max(worst_mono, max(r_twice - r_once, r_once - r_full))

    print(f"  {trials} random pairs of merges.")
    print(f"  worst cell-wise discrepancy between chaining and composing: {worst_comp:.3e}")
    print(f"  worst violation of  I(g(f(X));Y|Z) <= I(f(X);Y|Z) <= I(X;Y|Z): {worst_mono:.3e}")
    check("merges compose", worst_comp < 1e-12)
    check("chained readings are monotone", worst_mono < TOL)


def demo_classification() -> None:
    banner("7.  Classification of invisible collisions")

    xs = [0, 1, 2]
    ys = [0, 1]
    zs = [0]
    us = [0, 1]
    merge: Callable[[Hashable], Hashable] = lambda x: 0 if x in (0, 1) else 1

    def reading(p: Table3) -> Tuple[float, float]:
        return CMI(p, xs, ys, zs), CMI(push_fst3(merge, p, xs, ys, zs, us), us, ys, zs)

    # (a) the merged fiber {0,1} IS a product block: rows 0 and 1 are proportional
    prod: Table3 = {
        (0, 0, 0): 0.30, (0, 1, 0): 0.10,
        (1, 0, 0): 0.15, (1, 1, 0): 0.05,
        (2, 0, 0): 0.10, (2, 1, 0): 0.30,
    }
    prod = {(x, y, 0): prod.get((x, y, 0), 0.0) for x in xs for y in ys}
    t, m = reading(prod)
    print("  (a) fiber {0,1} is a product block (rows 3:1 and 3:1):")
    print(f"      true = {t:.6f}   merged = {m:.6f}   difference = {t - m:.3e}")
    check("product fiber => the collision is invisible", abs(t - m) < TOL)

    # (b) break proportionality in a single cell
    nonprod = dict(prod)
    nonprod[(1, 0, 0)] = 0.05
    nonprod[(1, 1, 0)] = 0.15
    t2, m2 = reading(nonprod)
    print("  (b) same merge, rows now 3:1 and 1:3 -- a single non-product cell:")
    print(f"      true = {t2:.6f}   merged = {m2:.6f}   drop = {t2 - m2:.6f} bits")
    check("non-product fiber => strict drop", t2 - m2 > TOL)
    print("  => a collision is invisible exactly when it merges dial settings with")
    print("     identical normalised response profiles in every context.")


def demo_context_merges() -> None:
    banner("8.  Why the guarantee lives on the dial axis only")

    xs = ys = zs = BOOLS
    collapse: Callable[[Hashable], Hashable] = lambda _: True

    xor = xor_population()
    cop = copy_population()

    xor_before = CMI(xor, xs, ys, zs)
    xor_after = CMI(push_thd(collapse, xor, xs, ys, zs, [True]), xs, ys, [True])
    cop_before = CMI(cop, xs, ys, zs)
    cop_after = CMI(push_thd(collapse, cop, xs, ys, zs, [True]), xs, ys, [True])

    print(f"  XOR : merging contexts takes the reading {xor_before:.3f} -> {xor_after:.3f}  (drops)")
    print(f"  copy: merging contexts takes the reading {cop_before:.3f} -> {cop_after:.3f}  (rises)")
    check("context merges can lower the reading", xor_after < xor_before - TOL)
    check("context merges can raise the reading", cop_after > cop_before + TOL)
    print("  => on the context axis the error has no fixed sign; the one-sidedness")
    print("     theorem is genuinely about merges of the dial.")


def demo_capacity_cap(trials: int = 150) -> None:
    banner("9.  The capacity cap  I(X;Y|Z) <= H(X|Z)")

    rng = random.Random(4142)
    xs = list(range(4))
    ys = list(range(4))
    zs = list(range(2))

    worst = 0.0
    for _ in range(trials):
        p = random_population(len(xs), len(ys), len(zs), rng)
        cap = 0.0
        for z in zs:
            s = slice_at(p, z)
            cap += entropy(marg1(s, xs, ys).values()) - nlp(mass(s))
        worst = max(worst, CMI(p, xs, ys, zs) - cap)
    print(f"  Over {trials} random weights, worst violation of the cap: {worst:.3e}")
    check("readings never exceed the surviving dial entropy", worst < TOL)


def main() -> None:
    print(__doc__)
    demo_witnesses()
    demo_one_sidedness()
    demo_exact_accounting()
    demo_error_bar()
    demo_chain_rule()
    demo_chaining()
    demo_classification()
    demo_context_merges()
    demo_capacity_cap()
    print()
    print("=" * 74)
    print("All checks passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
