"""
Numerical demonstrations for the uniqueness and classification of
two-point transreal compactifications.

The transreal carrier is

    T = { fin(x) : x in R }  u  { +oo }  u  { -oo }  u  { PHI }

with total division: 1/0 = +oo, (-1)/0 = -oo, 0/0 = PHI (nullity).

A *transreal compactification* is a compact Hausdorff topology on T in which
the finite fragment is an open copy of the real line and {PHI} is open.
Three such topologies appear in this file:

  * NATURAL : the extended real line [-oo, +oo] with PHI isolated.
              Basic neighbourhoods:  N_b(+oo) = {+oo} u fin(x > b)
                                     N_b(-oo) = {-oo} u fin(x < -b)
  * FLIP    : the natural topology with the two infinity labels exchanged.
  * CIRCLE  : the line compactified by the SINGLE point named -oo (so the line
              becomes a circle), with +oo and PHI isolated.
              Basic neighbourhood: N_b(-oo) = {-oo} u fin(|x| > b).

Each model is presented purely by its neighbourhood bases at the exceptional
points; every result below is then decided by finite probing of those bases.

The scripts reproduce, numerically:

  1. the end signature of each model (which infinity absorbs which ray),
  2. the compact core radius M of the ray-separation lemma,
  3. the classification: exactly two models have no isolated infinity,
  4. the division boundary: self-division is discontinuous in every model,
     while the reciprocal 1/y is unrepairable at 0 in the natural and flip
     models but uniquely repairable in the circle model.

Run:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Iterable, Optional, Sequence

# ---------------------------------------------------------------------------
# Points of the transreal carrier
# ---------------------------------------------------------------------------

POS_INF: str = "+oo"
NEG_INF: str = "-oo"
PHI: str = "PHI"

EXCEPTIONAL: tuple[str, str, str] = (POS_INF, NEG_INF, PHI)


@dataclass(frozen=True)
class Point:
    """A point of T: either a finite real, or one of the three exceptions."""

    kind: str  # "fin" | "+oo" | "-oo" | "PHI"
    value: float = 0.0

    def __str__(self) -> str:
        return f"fin({self.value:g})" if self.kind == "fin" else self.kind


def fin(x: float) -> Point:
    return Point("fin", float(x))


P_PINF: Point = Point(POS_INF)
P_NINF: Point = Point(NEG_INF)
P_PHI: Point = Point(PHI)


# ---------------------------------------------------------------------------
# Models, presented by neighbourhood bases
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Model:
    """A transreal compactification given by basic neighbourhoods.

    ``member(a, b, p)`` decides whether the point ``p`` lies in the basic
    neighbourhood ``N_b(a)`` of the exceptional point ``a`` at threshold ``b``.
    ``isolated(a)`` says whether ``{a}`` is open.
    """

    name: str
    member: Callable[[str, float, Point], bool]
    isolated: Callable[[str], bool]


def _natural_member(a: str, b: float, p: Point) -> bool:
    if p.kind != "fin":
        return p.kind == a
    if a == POS_INF:
        return p.value > b
    if a == NEG_INF:
        return p.value < -b
    return False  # N(PHI) = {PHI}


def _flip_member(a: str, b: float, p: Point) -> bool:
    if p.kind != "fin":
        return p.kind == a
    if a == POS_INF:
        return p.value < -b
    if a == NEG_INF:
        return p.value > b
    return False


def _circle_member(a: str, b: float, p: Point) -> bool:
    if p.kind != "fin":
        return p.kind == a
    if a == NEG_INF:  # the glue point of the circle
        return abs(p.value) > b
    return False  # {+oo} and {PHI} are isolated


NATURAL: Model = Model("NATURAL", _natural_member, lambda a: a == PHI)
FLIP: Model = Model("FLIP", _flip_member, lambda a: a == PHI)
CIRCLE: Model = Model("CIRCLE", _circle_member, lambda a: a in (PHI, POS_INF))

MODELS: tuple[Model, Model, Model] = (NATURAL, FLIP, CIRCLE)


# ---------------------------------------------------------------------------
# 1. End classification
# ---------------------------------------------------------------------------


def absorbs_positive_ray(model: Model, a: str, thresholds: Sequence[float]) -> bool:
    """Does every basic neighbourhood of ``a`` contain arbitrarily large x > 0?"""
    if model.isolated(a):
        return False
    return all(model.member(a, b, fin(b + 1.0 + abs(b))) for b in thresholds)


def absorbs_negative_ray(model: Model, a: str, thresholds: Sequence[float]) -> bool:
    """Does every basic neighbourhood of ``a`` contain arbitrarily large x < 0?"""
    if model.isolated(a):
        return False
    return all(model.member(a, b, fin(-(b + 1.0 + abs(b)))) for b in thresholds)


def end_signature(model: Model, thresholds: Sequence[float]) -> dict[str, str]:
    """Classify each exceptional point as isolated / positive / negative / merged."""
    signature: dict[str, str] = {}
    for a in EXCEPTIONAL:
        if model.isolated(a):
            signature[a] = "isolated"
            continue
        pos = absorbs_positive_ray(model, a, thresholds)
        neg = absorbs_negative_ray(model, a, thresholds)
        if pos and neg:
            signature[a] = "merged end (both rays)"
        elif pos:
            signature[a] = "positive end"
        elif neg:
            signature[a] = "negative end"
        else:
            signature[a] = "limit point, not an end"
    return signature


def identify_model(signature: dict[str, str]) -> str:
    """Recover the model from its end signature, as the classification predicts."""
    if signature[POS_INF] == "positive end" and signature[NEG_INF] == "negative end":
        return "the natural topology (oriented end compactification)"
    if signature[POS_INF] == "negative end" and signature[NEG_INF] == "positive end":
        return "the flip of the natural topology"
    if signature[POS_INF] == "isolated" and signature[NEG_INF].startswith("merged"):
        return "an exotic model: the two ends are merged into a circle"
    return "not a two-ended model"


# ---------------------------------------------------------------------------
# 2. Compact core radius and ray assignment (the ray-separation lemma)
# ---------------------------------------------------------------------------


def separating_pair(model: Model, b: float) -> tuple[Callable[[Point], bool],
                                                     Callable[[Point], bool]]:
    """Disjoint open sets around the two infinities, at separation threshold b.

    ``U`` is the basic neighbourhood of +oo, ``V`` that of -oo; if one of the
    infinities is isolated its neighbourhood is the singleton.
    """

    def U(p: Point) -> bool:
        if model.isolated(POS_INF):
            return p.kind == POS_INF
        return model.member(POS_INF, b, p)

    def V(p: Point) -> bool:
        if model.isolated(NEG_INF):
            return p.kind == NEG_INF
        return model.member(NEG_INF, b, p)

    return U, V


def core_radius(model: Model, b: float, grid: Iterable[float]) -> Optional[float]:
    """Least M (on the grid) with both rays (M,oo), (-oo,-M) covered by U u V."""
    U, V = separating_pair(model, b)
    sorted_grid = sorted(grid)
    for M in sorted_grid:
        probes = [fin(M + 1.0), fin(M + 10.0), fin(M + 1000.0),
                  fin(-M - 1.0), fin(-M - 10.0), fin(-M - 1000.0)]
        if all(U(p) or V(p) for p in probes):
            return M
    return None


def ray_assignment(model: Model, b: float, M: float) -> tuple[str, str]:
    """Which separator receives the positive ray, and which the negative one."""
    U, V = separating_pair(model, b)
    far_pos, far_neg = fin(M + 100.0), fin(-M - 100.0)
    pos = "U (around +oo)" if U(far_pos) else ("V (around -oo)" if V(far_pos) else "uncovered")
    neg = "U (around +oo)" if U(far_neg) else ("V (around -oo)" if V(far_neg) else "uncovered")
    return pos, neg


# ---------------------------------------------------------------------------
# 3. Convergence and the division boundary
# ---------------------------------------------------------------------------


def limit_of_sequence(model: Model, seq: Sequence[float],
                      thresholds: Sequence[float]) -> Optional[str]:
    """Which exceptional point (if any) the finite sequence fin(seq) converges to.

    A sequence converges to ``a`` when every basic neighbourhood of ``a``
    contains all but finitely many terms; we test the tail of the sequence.
    """
    tail_start = max(1, len(seq) // 2)
    for a in EXCEPTIONAL:
        if model.isolated(a):
            continue  # nothing finite converges to an isolated exceptional point
        if all(model.member(a, b, fin(x)) for b in thresholds for x in seq[tail_start:]):
            return a
    return None


def reciprocal_side_limits(model: Model, thresholds: Sequence[float]
                           ) -> tuple[Optional[str], Optional[str]]:
    """Limits of fin(1/y) as y -> 0+ and as y -> 0-, computed inside the model."""
    right = [1.0 / (10.0 ** k) for k in range(1, 40)]      # y -> 0+
    left = [-1.0 / (10.0 ** k) for k in range(1, 40)]      # y -> 0-
    lim_right = limit_of_sequence(model, [1.0 / y for y in right], thresholds)
    lim_left = limit_of_sequence(model, [1.0 / y for y in left], thresholds)
    return lim_right, lim_left


def repairing_value(model: Model, thresholds: Sequence[float]) -> Optional[str]:
    """The unique v making y |-> 1/y (with value v at 0) continuous, if any."""
    lim_right, lim_left = reciprocal_side_limits(model, thresholds)
    if lim_right is not None and lim_right == lim_left:
        return lim_right
    return None


def self_division(x: float) -> Point:
    """Transreal self-division x/x: fin(1) away from the origin, PHI at it."""
    return P_PHI if x == 0.0 else fin(1.0)


def self_division_discontinuous(model: Model) -> bool:
    """x |-> x/x is discontinuous at 0 in every T1 model: {PHI} is not a limit.

    The value at 0 is PHI while every punctured neighbourhood value is fin(1),
    and PHI is never in the closure of {fin(1)} in a T1 space.
    """
    punctured_values = {str(self_division(x)) for x in (1e-3, 1e-6, -1e-9, 1e-12)}
    return str(self_division(0.0)) not in punctured_values


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def main() -> None:
    thresholds: list[float] = [0.0, 1.0, 10.0, 1e3, 1e6, 1e12]
    grid: list[float] = [0.0, 0.5, 1.0, 2.0, 5.0, 10.0, 100.0]

    rule("1. END SIGNATURES: which infinity absorbs which ray")
    for model in MODELS:
        sig = end_signature(model, thresholds)
        print(f"\n  model {model.name}")
        for a in EXCEPTIONAL:
            print(f"    {a:>4} : {sig[a]}")
        print(f"    => identified as {identify_model(sig)}")

    rule("2. COMPACT CORE AND RAY SEPARATION (the ends argument, numerically)")
    print("\n  Separating the two infinities by basic neighbourhoods at threshold b=3")
    print("  leaves an uncovered compact core inside the line; beyond its radius M")
    print("  each ray lies wholly inside ONE separator (connectedness), and the two")
    print("  rays must choose DIFFERENT separators (the end property).\n")
    for model in MODELS:
        M = core_radius(model, 3.0, grid)
        if M is None:
            print(f"  {model.name:>8}: rays are never both covered "
                  f"(one infinity is isolated, so it absorbs no ray)")
            continue
        pos, neg = ray_assignment(model, 3.0, M)
        print(f"  {model.name:>8}: core radius M = {M:g}; "
              f"positive ray -> {pos}; negative ray -> {neg}")

    rule("3. CLASSIFICATION: which models have no isolated infinity?")
    print()
    for model in MODELS:
        no_iso = not (model.isolated(POS_INF) or model.isolated(NEG_INF))
        verdict = ("satisfies the classification hypotheses" if no_iso
                   else "excluded: an infinity is isolated")
        print(f"  {model.name:>8}: isolated(+oo)={model.isolated(POS_INF)}, "
              f"isolated(-oo)={model.isolated(NEG_INF)}  -> {verdict}")
    survivors = [m.name for m in MODELS
                 if not (m.isolated(POS_INF) or m.isolated(NEG_INF))]
    print(f"\n  survivors: {survivors}")
    print("  matching the theorem: exactly two such topologies exist, the end")
    print("  compactification and its flip.")

    rule("4. THE DIVISION BOUNDARY")
    print("\n  (a) self-division x |-> x/x  (value PHI at 0, fin(1) elsewhere)")
    for model in MODELS:
        ok = self_division_discontinuous(model)
        print(f"      {model.name:>8}: discontinuous at 0 = {ok}   "
              f"(topology-canonical: true in every T1 model)")

    print("\n  (b) reciprocal y |-> 1/y, repaired at the origin")
    for model in MODELS:
        lim_r, lim_l = reciprocal_side_limits(model, thresholds)
        v = repairing_value(model, thresholds)
        print(f"      {model.name:>8}: lim_{{y->0+}} = {lim_r}, lim_{{y->0-}} = {lim_l}")
        if v is None:
            print("                unrepairable: the one-sided limits disagree, and a")
            print("                Hausdorff space has unique limits.")
        else:
            print(f"                repairable, uniquely, by v = {v}: the two ends are")
            print("                merged, so both sides share one limit.")

    rule("5. NUMERICAL WITNESS: 1/y approaching the origin")
    print("\n     y            1/y           natural       flip          circle")
    print("     " + "-" * 62)
    for k in (1, 3, 6, 9):
        for sign in (+1.0, -1.0):
            y = sign / (10.0 ** k)
            r = 1.0 / y
            cells: list[str] = []
            for model in MODELS:
                seq = [1.0 / (sign / (10.0 ** j)) for j in range(k, k + 25)]
                cells.append(str(limit_of_sequence(model, seq, thresholds)))
            print(f"   {y: .0e}   {r: .0e}     "
                  f"{cells[0]:<13} {cells[1]:<13} {cells[2]:<13}")

    print("\n  In the natural topology the two columns of one-sided limits differ")
    print("  (+oo against -oo), so no repair exists; in the flip they differ too,")
    print("  with the labels exchanged; in the circle model both sides give -oo,")
    print("  the single glue point, and that value repairs the reciprocal.\n")


if __name__ == "__main__":
    main()
