"""
demo.py -- Periodicity of tensor powers in monoidal categories.

This script demonstrates, on concrete computable models of monoidal categories,
the main results of the accompanying paper:

  * mpow             : the right-associated n-fold tensor power  X^n
                       (X^0 = 1, X^(n+1) = X (x) X^n)
  * additive law     : X^(m+n)  ~=  X^m (x) X^n
  * detection        : if X^m ~= X^n with m < n then X is periodic, period n-m
  * shift invariance : a period at height m is a period at every height m+k
  * least period     : the smallest positive period, with minimality

Because the theory speaks of objects only up to ISOMORPHISM, every concrete model
below represents an isomorphism class of objects by a canonical label, and the
tensor product is realized as a binary operation on those labels.  This is
faithful: two objects are "the same" exactly when their labels agree.

The script is fully self-contained (standard library only) and uses type hints.
Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, Hashable, List, Optional, Tuple

Label = Hashable  # a canonical name for an isomorphism class of objects


# ---------------------------------------------------------------------------
# A computable model of a (small) monoidal category, tracked up to isomorphism.
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class MonoidalModel:
    """A finite model: iso-class labels, a unit, and a tensor on labels.

    `tensor(a, b)` returns the label of  a (x) b.  Associativity and unitality
    are assumed to hold on labels (they hold up to isomorphism in the category,
    and labels are iso classes), which is exactly the setting of the paper.
    """

    name: str
    labels: Tuple[Label, ...]
    unit: Label
    tensor: Callable[[Label, Label], Label]

    def mpow_label(self, x: Label, n: int) -> Label:
        """Label of the n-fold tensor power X^n  (X^0 = 1, X^(n+1) = X (x) X^n)."""
        acc: Label = self.unit
        for _ in range(n):
            acc = self.tensor(x, acc)
        return acc

    def mpow_sequence(self, x: Label, upto: int) -> List[Label]:
        """The labels of X^0, X^1, ..., X^upto."""
        return [self.mpow_label(x, n) for n in range(upto + 1)]


# ---------------------------------------------------------------------------
# Core algorithmic facts about the tower of tensor powers.
# ---------------------------------------------------------------------------
def additive_law_holds(model: MonoidalModel, x: Label, bound: int) -> bool:
    """Check X^(m+n) ~= X^m (x) X^n for all m, n <= bound (Theorem: add law)."""
    for m in range(bound + 1):
        xm = model.mpow_label(x, m)
        for n in range(bound + 1):
            lhs = model.mpow_label(x, m + n)
            rhs = model.tensor(xm, model.mpow_label(x, n))
            if lhs != rhs:
                return False
    return True


def detect_period(model: MonoidalModel, x: Label, search: int) -> Optional[Tuple[int, int, int]]:
    """Detection principle: find the FIRST collision X^m ~= X^n, m < n <= search.

    Returns (m, n, d) with d = n - m, certifying periodicity with period d,
    or None if no collision is found within the search window.
    """
    seen: Dict[Label, int] = {}
    for n in range(search + 1):
        lbl = model.mpow_label(x, n)
        if lbl in seen:
            m = seen[lbl]
            return (m, n, n - m)
        seen[lbl] = n
    return None


def shift_invariance_holds(model: MonoidalModel, x: Label, m: int, d: int, ks: int) -> bool:
    """Verify shift invariance: X^(m+k) ~= X^(m+k+d) for all k <= ks,
    given that X^m ~= X^(m+d) (Theorem: HasPeriodAt.shift)."""
    if model.mpow_label(x, m) != model.mpow_label(x, m + d):
        return False  # hypothesis fails; nothing to shift
    for k in range(ks + 1):
        if model.mpow_label(x, m + k) != model.mpow_label(x, m + k + d):
            return False
    return True


def period_set(model: MonoidalModel, x: Label, search: int) -> List[int]:
    """All positive d <= search that are periods: some X^m ~= X^(m+d), m <= search."""
    out: List[int] = []
    for d in range(1, search + 1):
        for m in range(search + 1):
            if model.mpow_label(x, m) == model.mpow_label(x, m + d):
                out.append(d)
                break
    return out


def min_period(model: MonoidalModel, x: Label, search: int) -> Optional[int]:
    """The least positive period within the search window, or None."""
    ps = period_set(model, x, search)
    return min(ps) if ps else None


# ---------------------------------------------------------------------------
# Concrete models.
# ---------------------------------------------------------------------------
def rep_cyclic_group(n: int) -> MonoidalModel:
    """Rep(Z/n): iso classes are characters 0..n-1; tensor = addition mod n;
    unit = the trivial character 0.  X^k of character a has label (a*k) mod n."""
    return MonoidalModel(
        name=f"Rep(Z/{n})",
        labels=tuple(range(n)),
        unit=0,
        tensor=lambda a, b: (a + b) % n,
    )


def vect_free_monoid(cap: int) -> MonoidalModel:
    """A toy 'graded lines' model whose iso classes are 0,1,2,... (a free
    commutative monoid on one generator), tensor = addition, unit = 0.  Here the
    tower X^n (X = label 1) NEVER repeats -- it is the categorical analogue of
    powers of a number and is the canonical NON-periodic example."""
    return MonoidalModel(
        name=f"GradedLines(cap={cap})",
        labels=tuple(range(cap + 1)),
        unit=0,
        tensor=lambda a, b: a + b,  # may exceed cap; used only for small n
    )


def klein_four() -> MonoidalModel:
    """Rep(Z/2 x Z/2): iso classes are pairs in {0,1}^2; tensor = componentwise
    XOR; unit = (0,0).  Every nontrivial character squares to the unit."""
    elts: Tuple[Label, ...] = tuple((a, b) for a in (0, 1) for b in (0, 1))
    return MonoidalModel(
        name="Rep(Z/2 x Z/2)",
        labels=elts,
        unit=(0, 0),
        tensor=lambda u, v: ((u[0] ^ v[0]), (u[1] ^ v[1])),
    )


# ---------------------------------------------------------------------------
# Driver.
# ---------------------------------------------------------------------------
def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def report_periodic_object(model: MonoidalModel, x: Label, search: int) -> None:
    seq = model.mpow_sequence(x, min(search, 8))
    print(f"  model         : {model.name}")
    print(f"  object X       : {x}")
    print(f"  tower X^0..    : {seq}")
    print(f"  additive law   : X^(m+n) ~= X^m (x) X^n  ->  {additive_law_holds(model, x, 6)}")
    det = detect_period(model, x, search)
    if det is None:
        print(f"  detection      : no collision within {search} steps (looks non-periodic)")
        return
    m, n, d = det
    print(f"  detection      : X^{m} ~= X^{n}  =>  period d = {d}")
    si = shift_invariance_holds(model, x, m, d, ks=search - n)
    print(f"  shift invariance: period {d} holds at every height >= {m}  ->  {si}")
    ps = period_set(model, x, search)
    print(f"  period set      : {sorted(set(ps))}  (multiples of the least period)")
    mp = min_period(model, x, search)
    print(f"  least period    : minPeriod = {mp}  (positive, divides all others)")


def main() -> None:
    banner("Example 1 -- Cyclic charge in Rep(Z/3): least period 3")
    report_periodic_object(rep_cyclic_group(3), x=1, search=12)

    banner("Example 2 -- Rep(Z/6), character of order 6 and of order 2/3")
    report_periodic_object(rep_cyclic_group(6), x=1, search=18)  # order 6
    print()
    report_periodic_object(rep_cyclic_group(6), x=2, search=18)  # order 3
    print()
    report_periodic_object(rep_cyclic_group(6), x=3, search=18)  # order 2

    banner("Example 3 -- Klein four group: every nontrivial char has period 2")
    report_periodic_object(klein_four(), x=(1, 0), search=8)
    print()
    report_periodic_object(klein_four(), x=(1, 1), search=8)

    banner("Example 4 -- The non-periodic baseline (graded lines)")
    report_periodic_object(vect_free_monoid(cap=50), x=1, search=20)

    banner("Example 5 -- Forced periodicity (pigeonhole) in a finite model")
    # In Rep(Z/n) there are only n iso classes, so X^0..X^n (n+1 terms) must
    # contain a repeat; the detected period is at most n.
    for n in (4, 5, 7, 12):
        det = detect_period(rep_cyclic_group(n), x=1, search=n)
        assert det is not None, "pigeonhole guarantees a collision"
        m, k, d = det
        print(f"  Rep(Z/{n}): collision X^{m} ~= X^{k}, period {d} <= {n}  (n classes)")

    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
