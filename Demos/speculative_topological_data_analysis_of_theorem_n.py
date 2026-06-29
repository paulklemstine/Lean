"""
Belnap's FOUR: paraconsistency and the product representation FOUR ~= 2 (x) 2.

This self-contained script numerically demonstrates every theorem in the
accompanying paper:

  * the four values N, F, T, B and their two orders (truth, knowledge);
  * negation, conflation, and the four lattice operations;
  * paraconsistency: the contradiction premise is SATISFIABLE (witness B) yet
    does NOT explode, whereas classical logic's premise is UNSATISFIABLE and
    explosion holds only vacuously;
  * the bit-pair representation tau : FOUR -> Bool x Bool and the transport of
    both orders and all six operations to coordinatewise Boolean formulas;
  * cardinality 4 and genuine two-dimensionality of the two orders.

Run with:  python demo.py
No external dependencies.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Tuple

# ---------------------------------------------------------------------------
# 1. Values and the bit-pair representation tau : FOUR -> Bool x Bool
#    First coordinate  = evidence FOR     (told true)
#    Second coordinate = evidence AGAINST (told false)
# ---------------------------------------------------------------------------

Value = str  # one of "N", "F", "T", "B"
BitPair = Tuple[bool, bool]

VALUES: List[Value] = ["N", "F", "T", "B"]

TO_PROD: Dict[Value, BitPair] = {
    "N": (False, False),  # told nothing
    "F": (False, True),   # told false
    "T": (True, False),   # told true
    "B": (True, True),    # told both
}
OF_PROD: Dict[BitPair, Value] = {pair: v for v, pair in TO_PROD.items()}


def to_prod(a: Value) -> BitPair:
    """tau: map a Belnap value to its (for, against) bit-pair."""
    return TO_PROD[a]


def of_prod(p: BitPair) -> Value:
    """sigma: inverse of tau."""
    return OF_PROD[p]


# ---------------------------------------------------------------------------
# 2. Operations, defined directly on bit-pairs (Theorem 5.3) and lifted to values
# ---------------------------------------------------------------------------

def neg(a: Value) -> Value:
    """Negation: swap the two evidence channels."""
    f, g = to_prod(a)
    return of_prod((g, f))


def conf(a: Value) -> Value:
    """Conflation: swap-then-negate (NOT componentwise negation!)."""
    f, g = to_prod(a)
    return of_prod((not g, not f))


def meet_k(a: Value, b: Value) -> Value:
    """Knowledge meet (consensus): componentwise AND."""
    (f1, g1), (f2, g2) = to_prod(a), to_prod(b)
    return of_prod((f1 and f2, g1 and g2))


def join_k(a: Value, b: Value) -> Value:
    """Knowledge join (gullible combination): componentwise OR."""
    (f1, g1), (f2, g2) = to_prod(a), to_prod(b)
    return of_prod((f1 or f2, g1 or g2))


def meet_t(a: Value, b: Value) -> Value:
    """Truth meet (conjunction): AND on for-bit, OR on against-bit (twist)."""
    (f1, g1), (f2, g2) = to_prod(a), to_prod(b)
    return of_prod((f1 and f2, g1 or g2))


def join_t(a: Value, b: Value) -> Value:
    """Truth join (disjunction): OR on for-bit, AND on against-bit (twist)."""
    (f1, g1), (f2, g2) = to_prod(a), to_prod(b)
    return of_prod((f1 or f2, g1 and g2))


# ---------------------------------------------------------------------------
# 3. The two orders (Theorem 5.2)
# ---------------------------------------------------------------------------

def le_k(a: Value, b: Value) -> bool:
    """Knowledge order: product order on (for, against)."""
    (f1, g1), (f2, g2) = to_prod(a), to_prod(b)
    return (f1 <= f2) and (g1 <= g2)


def le_t(a: Value, b: Value) -> bool:
    """Truth order: twisted product order (for up, against down)."""
    (f1, g1), (f2, g2) = to_prod(a), to_prod(b)
    return (f1 <= f2) and (g2 <= g1)


# ---------------------------------------------------------------------------
# 4. Designation and the classical comparison algebra
# ---------------------------------------------------------------------------

def designated(a: Value) -> bool:
    """Assertible: there is evidence FOR (a in {T, B})."""
    return a in ("T", "B")


def bool_neg(b: bool) -> bool:
    return not b


# ---------------------------------------------------------------------------
# Demonstrations of the theorems
# ---------------------------------------------------------------------------

def demo_tables() -> None:
    print("=" * 64)
    print("VALUES and bit-pair representation tau (for, against)")
    print("=" * 64)
    for v in VALUES:
        f, g = to_prod(v)
        print(f"  {v}: (for={int(f)}, against={int(g)})  designated={designated(v)}")

    print("\nNegation and conflation:")
    print("  v   neg(v)  conf(v)")
    for v in VALUES:
        print(f"  {v}     {neg(v)}       {conf(v)}")

    for name, op in [("meet_k (consensus)", meet_k),
                     ("join_k (gullible)", join_k),
                     ("meet_t (and)", meet_t),
                     ("join_t (or)", join_t)]:
        print(f"\n{name} table:")
        print("      " + "  ".join(VALUES))
        for a in VALUES:
            row = "  ".join(op(a, b) for b in VALUES)
            print(f"   {a}  {row}")


def demo_designation_monotone() -> None:
    print("\n" + "=" * 64)
    print("Theorem 3.1: a <=_t b  implies  designated(a) -> designated(b)")
    print("=" * 64)
    ok = all(
        (designated(b) if designated(a) else True)
        for a in VALUES for b in VALUES if le_t(a, b)
    )
    print(f"  holds for all pairs with a <=_t b : {ok}")


def demo_paraconsistency() -> None:
    print("\n" + "=" * 64)
    print("Theorems 4.1-4.4: paraconsistency vs classical explosion")
    print("=" * 64)

    witnesses = [a for a in VALUES if designated(a) and designated(neg(a))]
    print(f"  4.1  contradiction premise satisfiable in FOUR, witnesses = {witnesses}")

    explodes = all(
        designated(q)
        for a in VALUES for q in VALUES
        if designated(a) and designated(neg(a))
    )
    print(f"  4.2  FOUR explodes? {explodes}  (False = paraconsistent)")
    cex = [(a, q) for a in VALUES for q in VALUES
           if designated(a) and designated(neg(a)) and not designated(q)]
    a0, q0 = cex[0]
    print(f"       counterexample (a, q) = {cex[0]}  [{a0} designated, neg {a0} = "
          f"{neg(a0)} designated, yet {q0} not designated]")

    bool_sat = [b for b in (True, False) if b is True and bool_neg(b) is True]
    print(f"  4.3  classical contradiction premise satisfiable? {bool(bool_sat)} "
          f"(unsatisfiable)")

    bool_explodes = all(
        q is True
        for b in (True, False) for q in (True, False)
        if b is True and bool_neg(b) is True
    )
    print(f"  4.4  classical explosion valid (vacuously)? {bool_explodes}")


def demo_representation() -> None:
    print("\n" + "=" * 64)
    print("Theorem 5.1-5.3: FOUR ~= Bool x Bool, transport of orders and ops")
    print("=" * 64)

    bij1 = all(of_prod(to_prod(a)) == a for a in VALUES)
    bij2 = all(to_prod(of_prod(p)) == p
               for p in product((False, True), repeat=2))
    print(f"  5.1  sigma . tau = id : {bij1};  tau . sigma = id : {bij2};  |FOUR| = {len(VALUES)}")

    # Order transport: definitions above are *already* the transported forms,
    # so we re-derive the orders from an independent Hasse-diagram source of
    # truth and confirm agreement.
    truth_chain = {  # explicit truth order edges from the Hasse diagram
        ("F", "F"), ("N", "N"), ("T", "T"), ("B", "B"),
        ("F", "N"), ("N", "T"), ("F", "T"), ("F", "B"), ("B", "T"),
    }
    know_chain = {
        ("N", "N"), ("F", "F"), ("T", "T"), ("B", "B"),
        ("N", "F"), ("F", "B"), ("N", "B"), ("N", "T"), ("T", "B"),
    }
    t_ok = all((le_t(a, b) == ((a, b) in truth_chain)) for a in VALUES for b in VALUES)
    k_ok = all((le_k(a, b) == ((a, b) in know_chain)) for a in VALUES for b in VALUES)
    print(f"  5.2  truth order matches Hasse diagram: {t_ok}")
    print(f"       knowledge order matches Hasse diagram: {k_ok}")

    # Operation transport: confirm coordinatewise formulas hold.
    def b_and(x, y): return x and y
    def b_or(x, y): return x or y
    ops_ok = True
    for a in VALUES:
        for b in VALUES:
            (f1, g1), (f2, g2) = to_prod(a), to_prod(b)
            ops_ok &= to_prod(meet_k(a, b)) == (b_and(f1, f2), b_and(g1, g2))
            ops_ok &= to_prod(join_k(a, b)) == (b_or(f1, f2), b_or(g1, g2))
            ops_ok &= to_prod(meet_t(a, b)) == (b_and(f1, f2), b_or(g1, g2))
            ops_ok &= to_prod(join_t(a, b)) == (b_or(f1, f2), b_and(g1, g2))
    for a in VALUES:
        f, g = to_prod(a)
        ops_ok &= to_prod(neg(a)) == (g, f)
        ops_ok &= to_prod(conf(a)) == (not g, not f)
    print(f"  5.3  all six operations are coordinatewise Boolean: {ops_ok}")


def demo_two_dimensional() -> None:
    print("\n" + "=" * 64)
    print("Theorem 6.2: the two orders are genuinely two-dimensional")
    print("=" * 64)
    w1 = [(a, b) for a in VALUES for b in VALUES if le_t(a, b) and not le_k(a, b)]
    w2 = [(a, b) for a in VALUES for b in VALUES if le_k(a, b) and not le_t(a, b)]
    print(f"  exists a <=_t b with a not<=_k b : {w1[0]}")
    print(f"  exists a <=_k b with a not<=_t b : {w2[0]}")
    print("  => neither order refines the other.")


def main() -> None:
    demo_tables()
    demo_designation_monotone()
    demo_paraconsistency()
    demo_representation()
    demo_two_dimensional()
    print("\nAll demonstrations consistent with the formal theorems.")


if __name__ == "__main__":
    main()


"""
Visualization of Belnap's FOUR: the double Hasse diamond.

Draws the four values N, F, T, B as a diamond and overlays both orders:
  * the KNOWLEDGE order (bottom N -> top B), read vertically;
  * the TRUTH order (left F -> right T), read horizontally.
Negation is the left-right reflection (T <-> F); conflation is the
up-down reflection (N <-> B). Saves 'belnap_diamond.png'.

Requires: matplotlib.  Run:  python visualize.py
"""

from __future__ import annotations

from typing import Dict, Tuple

import matplotlib.pyplot as plt


def main() -> None:
    # Diamond coordinates: x = truth axis, y = knowledge axis.
    pos: Dict[str, Tuple[float, float]] = {
        "N": (0.0, -1.0),   # knowledge bottom (told nothing)
        "F": (-1.0, 0.0),   # truth bottom    (told false)
        "T": (1.0, 0.0),    # truth top       (told true)
        "B": (0.0, 1.0),    # knowledge top   (told both)
    }
    colors = {"N": "#9aa0a6", "F": "#4285f4", "T": "#34a853", "B": "#ea4335"}
    labels = {"N": "N\n(told nothing)", "F": "F\n(told false)",
              "T": "T\n(told true)", "B": "B\n(told both)"}

    knowledge_edges = [("N", "F"), ("N", "T"), ("F", "B"), ("T", "B")]

    fig, ax = plt.subplots(figsize=(7, 7))

    for a, b in knowledge_edges:
        (x0, y0), (x1, y1) = pos[a], pos[b]
        ax.plot([x0, x1], [y0, y1], color="#222", lw=1.5, zorder=1)

    for v, (x, y) in pos.items():
        ax.scatter([x], [y], s=2600, c=colors[v], edgecolors="black",
                   linewidths=1.5, zorder=2)
        ax.text(x, y, labels[v], ha="center", va="center",
                fontsize=11, fontweight="bold", color="white", zorder=3)

    # Axis annotations
    ax.annotate("knowledge order  <=_k", xy=(0, 1.35), ha="center",
                fontsize=12, fontweight="bold", color="#ea4335")
    ax.annotate("(more information up)", xy=(0, 1.2), ha="center",
                fontsize=9, color="#ea4335")
    ax.annotate("truth order  <=_t  (more true right)", xy=(0, -1.45),
                ha="center", fontsize=12, fontweight="bold", color="#34a853")

    ax.annotate("", xy=(0, 1.05), xytext=(0, -1.05),
                arrowprops=dict(arrowstyle="->", color="#ea4335", lw=1, ls=":"))
    ax.annotate("", xy=(1.05, 0), xytext=(-1.05, 0),
                arrowprops=dict(arrowstyle="->", color="#34a853", lw=1, ls=":"))

    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title("Belnap's FOUR as the bilattice 2 (x) 2\n"
                 "negation = left/right flip,  conflation = up/down flip",
                 fontsize=12)

    fig.tight_layout()
    fig.savefig("belnap_diamond.png", dpi=150)
    print("Saved belnap_diamond.png")


if __name__ == "__main__":
    main()
