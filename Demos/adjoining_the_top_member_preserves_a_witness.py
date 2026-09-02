"""Algorithm 1 — Degree/Surplus Profile and the Single-Maximum Abundance Certificate.

Computes, in one pass over the incidence structure, the degree, surplus and density of every
element of a ground set, and decides the existence of an abundant element by the equivalence

    (exists x in s abundant in F)   <=>   |F| <= 2 * max_{x in s} deg_F(x).

Complexity: O(|F| * |s|) time and O(|s|) space; the certificate is the maximiser.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, List, Optional, Sequence, Set


@dataclass(frozen=True)
class Profile:
    """Per-element statistics of a family together with the global certificate."""
    card: int                      # |F|
    degrees: Dict[int, int]        # deg_F(x) for x in the ground set
    surpluses: Dict[int, int]      # 2 deg_F(x) - |F|
    densities: Dict[int, float]    # deg_F(x) / |F|
    abundant: List[int]            # elements with surplus >= 0
    certificate: int               # max_x deg_F(x)
    witness: Optional[int]         # an abundant element, if one exists


def degree_profile(family: Sequence[Set[int]], ground: Iterable[int]) -> Profile:
    """Compute all degrees, surpluses and densities, plus the abundance certificate."""
    ground_list: List[int] = list(ground)
    card: int = len(family)
    degrees: Dict[int, int] = {x: 0 for x in ground_list}
    for member in family:                      # one pass over the incidences
        for x in member:
            if x in degrees:
                degrees[x] += 1
    surpluses = {x: 2 * degrees[x] - card for x in ground_list}
    densities = {x: (degrees[x] / card if card else 0.0) for x in ground_list}
    abundant = [x for x in ground_list if surpluses[x] >= 0]
    certificate = max((degrees[x] for x in ground_list), default=0)
    witness = next((x for x in ground_list if degrees[x] == certificate
                    and card <= 2 * certificate), None)
    return Profile(card, degrees, surpluses, densities, abundant, certificate, witness)


def has_abundant_element(family: Sequence[Set[int]], ground: Iterable[int]) -> bool:
    """Decide abundance by the single numerical test |F| <= 2 * max deg."""
    prof = degree_profile(family, ground)
    return prof.card <= 2 * prof.certificate


if __name__ == "__main__":
    F: List[Set[int]] = [{0, 1}, {1}, {1, 2}, {2}]
    prof = degree_profile(F, [0, 1, 2])
    print("family        :", [sorted(A) for A in F])
    print("degrees       :", prof.degrees)
    print("surpluses     :", prof.surpluses)
    print("abundant      :", prof.abundant)
    print("certificate   :", f"|F| = {prof.card} <= 2 * {prof.certificate}"
          f" = {2 * prof.certificate} -> {has_abundant_element(F, [0, 1, 2])}")
    print("witness       :", prof.witness)


"""Algorithm 2 — Top-Adjunction Audit with Predictive Surplus Update.

Given a family F and a tracked element x, this computes the top (the union of all members),
decides whether adjoining it changes anything, and *predicts* the new surplus without
recomputing any degree, using the unit-step rule

    adjoining a new set A:   sigma -> sigma + 1  if x in A,
                             sigma -> sigma - 1  if x not in A.

Since the top contains every element occurring in F, adjoining it is a +1 step for every such
element; it is a no-op exactly when the top is already a member. The audit also reports the
strict density improvement deg/|F| -> (deg+1)/(|F|+1) and flags the unique degenerate case
F = {} on which an abundant witness is destroyed.

Complexity: O(|F| * m) for the top (m = size of the largest member); the surplus update itself
is O(1) per element.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, FrozenSet, List, Sequence, Set


@dataclass(frozen=True)
class AuditReport:
    top: Set[int]
    top_is_new: bool
    card_before: int
    card_after: int
    deg_before: int
    deg_after: int
    surplus_before: int
    surplus_after: int
    density_before: float
    density_after: float
    abundant_before: bool
    abundant_after: bool
    degenerate: bool          # True exactly for the empty family
    explanation: str


def top_of(family: Sequence[Set[int]]) -> Set[int]:
    """The union of all members of the family."""
    out: Set[int] = set()
    for member in family:
        out |= member
    return out


def adjoin_top(family: Sequence[Set[int]]) -> List[Set[int]]:
    """F^+ = F u {top(F)}, respecting set-equality of members."""
    t = top_of(family)
    keys = {frozenset(A) for A in family}
    return list(family) if frozenset(t) in keys else list(family) + [t]


def audit_adjoin_top(family: Sequence[Set[int]], x: int) -> AuditReport:
    """Predict the effect of adjoining the top on the tracked element x."""
    t = top_of(family)
    keys: Set[FrozenSet[int]] = {frozenset(A) for A in family}
    top_is_new = frozenset(t) not in keys

    n = len(family)
    d = sum(1 for A in family if x in A)
    sigma = 2 * d - n

    if not top_is_new:
        n2, d2 = n, d
        expl = "the top is already a member: adjoining it is a no-op."
    else:
        n2 = n + 1
        d2 = d + (1 if x in t else 0)     # x in t iff x occurs in some member
        expl = ("the top is new and contains x, so it is charged once to |F| and twice to "
                "2*deg: the surplus rises by exactly +1."
                if x in t else
                "the top is new but does not contain x (only possible when x occurs in no "
                "member): the surplus falls by 1.")
    sigma2 = 2 * d2 - n2

    degenerate = (n == 0)
    if degenerate:
        expl = ("F is empty: every element is vacuously abundant, but F^+ = {{}} has one "
                "member containing nothing, so every witness is destroyed. This is the unique "
                "counterexample to the unguarded claim.")

    return AuditReport(
        top=t, top_is_new=top_is_new,
        card_before=n, card_after=n2,
        deg_before=d, deg_after=d2,
        surplus_before=sigma, surplus_after=sigma2,
        density_before=(d / n if n else 0.0), density_after=(d2 / n2 if n2 else 0.0),
        abundant_before=(n <= 2 * d), abundant_after=(n2 <= 2 * d2),
        degenerate=degenerate, explanation=expl,
    )


if __name__ == "__main__":
    for F in ([{0}, {1}, {0, 2}], [{0}, {0, 1}, {0, 1, 2}], []):
        rep = audit_adjoin_top(F, x=0)
        print("family :", [sorted(A) for A in F])
        print("  top =", sorted(rep.top), " new:", rep.top_is_new)
        print(f"  |F| {rep.card_before} -> {rep.card_after},"
              f"  deg {rep.deg_before} -> {rep.deg_after},"
              f"  sigma {rep.surplus_before:+d} -> {rep.surplus_after:+d}")
        print(f"  density {rep.density_before:.3f} -> {rep.density_after:.3f},"
              f"  abundant {rep.abundant_before} -> {rep.abundant_after}")
        print("  ", rep.explanation, "\n")


"""Algorithm 3 — Union Closure with a Surplus Ledger, and Safe-Schedule Search.

The union closure of a family is reached by adjoining new sets one at a time, and by the unit
step rule each adjunction is worth exactly +1 or -1 to a tracked element x. A *safe schedule*
for x is an ordering of the new sets along which the running surplus of x never drops below
its starting value sigma_F(x).

This module (i) computes the closure, (ii) replays it as a ledger, and (iii) searches for a
safe schedule. The search uses the fact that a greedy rule is optimal for this objective: at
each step adjoin a pending set containing x if one exists, otherwise a set avoiding x. Since
adding sets never removes options, greedy maximises the running surplus prefix-wise, so a safe
schedule exists if and only if the greedy one is safe. In particular, a safe schedule exists
for x iff every prefix of the greedy order stays above the start, which happens iff the total
number of new sets avoiding x never exceeds the number containing x at any greedy prefix --
equivalently iff the final surplus is at least the initial one.

Complexity: closure computation is O(|ucl(F)|^2) union operations (worst case exponential in
|F|); the schedule search is O(k log k) in the number k of newly added sets.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import FrozenSet, List, Optional, Sequence, Set, Tuple

Mask = int


def popcount(m: Mask) -> int:
    return bin(m).count("1")


def show(mask: Mask, width: int = 4) -> str:
    elts = [i for i in range(width) if mask >> i & 1]
    return "{" + ",".join(map(str, elts)) + "}" if elts else "{}"


def union_closure(family: Set[Mask]) -> Set[Mask]:
    """Least union-closed family containing `family` (iterated pairwise completion)."""
    cur = set(family)
    while True:
        new = {a | b for a in cur for b in cur} - cur
        if not new:
            return cur
        cur |= new


def surplus(family: Sequence[Mask], x: int) -> int:
    return 2 * sum(1 for m in family if m >> x & 1) - len(family)


@dataclass(frozen=True)
class Schedule:
    element: int
    start_surplus: int
    order: List[Mask]
    running: List[int]
    safe: bool


def greedy_schedule(family: Set[Mask], x: int) -> Schedule:
    """Greedy ordering of the sets added by the closure: good sets (containing x) first."""
    closure = union_closure(family)
    pending = sorted(closure - family, key=lambda m: (0 if m >> x & 1 else 1, popcount(m), m))
    cur: List[Mask] = list(family)
    start = surplus(cur, x)
    running: List[int] = [start]
    for m in pending:
        cur.append(m)
        running.append(surplus(cur, x))
    safe = all(v >= start for v in running)
    return Schedule(element=x, start_surplus=start, order=pending, running=running, safe=safe)


def find_safe_element(family: Set[Mask], ground: Sequence[int]) -> Optional[Schedule]:
    """Search the ground set for an element admitting a safe schedule of the closure."""
    best: Optional[Schedule] = None
    for x in ground:
        sched = greedy_schedule(family, x)
        if sched.safe and (best is None or sched.running[-1] > best.running[-1]):
            best = sched
    return best


if __name__ == "__main__":
    # The counterexample family {{0,1,2},{0,1},{1},{2}} over the ground set {0,1,2}.
    F: Set[Mask] = {0b111, 0b011, 0b010, 0b100}
    ground = [0, 1, 2]
    print("family  :", sorted(show(m, 3) for m in F))
    print("closure :", sorted(show(m, 3) for m in union_closure(F)))
    for x in ground:
        s = greedy_schedule(F, x)
        print(f"  x = {x}: start {s.start_surplus:+d}, order "
              f"{[show(m, 3) for m in s.order]}, running {s.running}, safe = {s.safe}")
    best = find_safe_element(F, ground)
    print("element with a safe schedule:", None if best is None else best.element)


"""Algorithm 4 — Averaging Certificate and Witness Extraction by Double Counting.

Implements the sufficient condition

    |s| * |F| <= 2 * T(F),   where T(F) = sum over members of |A|,

for a nonempty ground set s containing every member. When it holds, some element of s is
abundant, and a witness is found without any search over subsets: any element of maximum
degree works. The routine also verifies the underlying double count
sum_{x in s} deg_F(x) = T(F), and checks the stability of the criterion under adjoining the
top, which raises T(F) by |top(F)| while raising |F| by one.

Complexity: O(|F| * |s|) time, O(|s|) space -- a single pass over the incidences.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, List, Optional, Sequence, Set


@dataclass(frozen=True)
class AveragingReport:
    ground_size: int
    card: int
    total_size: int
    double_count_ok: bool
    criterion_holds: bool
    witness: Optional[int]
    witness_degree: Optional[int]
    stable_after_adjoining_top: bool


def total_size(family: Sequence[Set[int]]) -> int:
    """T(F): the number of incidences (x, A) with x in A in F."""
    return sum(len(A) for A in family)


def degrees(family: Sequence[Set[int]], ground: Sequence[int]) -> Dict[int, int]:
    d = {x: 0 for x in ground}
    for A in family:
        for x in A:
            if x in d:
                d[x] += 1
    return d


def averaging_certificate(family: Sequence[Set[int]],
                          ground: Optional[Sequence[int]] = None) -> AveragingReport:
    """Test the averaging criterion and extract a witness when it holds."""
    if ground is None:                                   # canonical ground set: the top
        top: Set[int] = set()
        for A in family:
            top |= A
        ground = sorted(top)
    ground = list(ground)

    T = total_size(family)
    deg = degrees(family, ground)
    double_count_ok = (sum(deg.values()) == T)           # the double count of Theorem 6.1
    holds = bool(ground) and len(ground) * len(family) <= 2 * T

    witness: Optional[int] = None
    witness_degree: Optional[int] = None
    if holds:
        witness = max(ground, key=lambda x: deg[x])
        witness_degree = deg[witness]
        assert len(family) <= 2 * witness_degree, "criterion must produce an abundant element"

    # Stability: adjoining the top adds |top| incidences and one member.
    top_set: Set[int] = set()
    for A in family:
        top_set |= A
    top_is_new = all(A != top_set for A in family)
    card2 = len(family) + (1 if top_is_new else 0)
    total2 = T + (len(top_set) if top_is_new else 0)
    stable = (not holds) or (len(top_set) * card2 <= 2 * total2)

    return AveragingReport(
        ground_size=len(ground), card=len(family), total_size=T,
        double_count_ok=double_count_ok, criterion_holds=holds,
        witness=witness, witness_degree=witness_degree,
        stable_after_adjoining_top=stable,
    )


if __name__ == "__main__":
    examples: List[List[Set[int]]] = [
        [{0, 1}, {1, 2}, {0, 2}, {0, 1, 2}],                    # criterion holds
        [set(), {0}, {1}, {0, 1}, {0, 1, 2}],                   # abundant, criterion fails
    ]
    for F in examples:
        rep = averaging_certificate(F)
        print("family :", [sorted(A) for A in F])
        print(f"  |s| = {rep.ground_size}, |F| = {rep.card}, T(F) = {rep.total_size},"
              f" double count verified: {rep.double_count_ok}")
        print(f"  criterion |s||F| = {rep.ground_size * rep.card} <= 2T ="
              f" {2 * rep.total_size}: {rep.criterion_holds}")
        print(f"  witness: {rep.witness} (degree {rep.witness_degree});"
              f" stable under adjoining the top: {rep.stable_after_adjoining_top}\n")


"""Demo: exhaustive census of safe closure schedules on small ground sets.

A *safe schedule* for an element x is an ordering of the sets added by the union closure along
which the running surplus sigma = 2*deg - |F| of x never drops below its starting value. Since
the multiset of additions is fixed, the ordering that puts every set containing x first
maximises every prefix, and its prefix minimum is the final surplus; hence a safe schedule for
x exists if and only if sigma_{ucl(F)}(x) >= sigma_F(x).

This script asks, for every family over a ground set of size 3 and of size 4:

  * how often does the closure lower the surplus of a previously abundant element (the failure
    mode exhibited by {{0,1,2},{0,1},{1},{2}} with x = 0)?
  * is there always SOME element admitting a safe schedule?
  * is there always some element abundant in the closure (Frankl's conjecture for the closure,
    which is automatically union-closed)?

The answers on both ground sets: the closure does destroy individual witnesses, but every
family with a nonempty member admits an element with a safe schedule, and every closure with a
nonempty member has an abundant element.
"""

from __future__ import annotations

from typing import FrozenSet, List, Set, Tuple


def popcount(m: int) -> int:
    return bin(m).count("1")


def deg(fam: FrozenSet[int], x: int) -> int:
    return sum(1 for m in fam if m >> x & 1)


def surplus(fam: FrozenSet[int], x: int) -> int:
    return 2 * deg(fam, x) - len(fam)


def union_closure(fam: FrozenSet[int]) -> FrozenSet[int]:
    cur: Set[int] = set(fam)
    while True:
        new = {a | b for a in cur for b in cur} - cur
        if not new:
            return frozenset(cur)
        cur |= new


def show(mask: int, n: int) -> str:
    elts = [i for i in range(n) if mask >> i & 1]
    return "{" + ",".join(map(str, elts)) + "}" if elts else "{}"


def census(n: int) -> None:
    ground = list(range(n))
    universe = 1 << n
    families = 1 << universe
    destroyed = 0
    no_safe_element = 0
    no_abundant_closure = 0
    examples: List[Tuple[FrozenSet[int], int]] = []

    for code in range(families):
        fam = frozenset(m for m in range(universe) if code >> m & 1)
        if not fam or not any(m != 0 for m in fam):
            continue
        cl = union_closure(fam)
        lost = [x for x in ground if surplus(fam, x) >= 0 > surplus(cl, x)]
        if lost:
            destroyed += 1
            if len(examples) < 3:
                examples.append((fam, lost[0]))
        if not any(surplus(cl, x) >= surplus(fam, x) for x in ground):
            no_safe_element += 1
        if not any(surplus(cl, x) >= 0 for x in ground):
            no_abundant_closure += 1

    print(f"ground set of size {n}: families with a nonempty member examined")
    print(f"  closures destroying an abundant witness : {destroyed}")
    print(f"  families with NO safely schedulable element : {no_safe_element}")
    print(f"  closures with NO abundant element : {no_abundant_closure}")
    for fam, x in examples:
        cl = union_closure(fam)
        print(f"  example: F = {sorted(show(m, n) for m in fam)}  x = {x}"
              f"  sigma {surplus(fam, x):+d} -> {surplus(cl, x):+d}"
              f"  (closure = {sorted(show(m, n) for m in cl)})")


if __name__ == "__main__":
    census(3)
    print()
    census(4)


"""Visualization: the averaging criterion over all families on a three-element ground set.

For every one of the 2^8 = 256 families F of subsets of {0,1,2} we plot

    x-axis: average member density  T(F) / (|s| * |F|)  with s = top(F) and T(F) = sum |A|,
    y-axis: best abundance ratio    2 * max_x deg_F(x) / |F|,

so that a family has an abundant element exactly when its y-value is at least 1, and the
averaging criterion  |s|*|F| <= 2*T(F)  holds exactly when its x-value is at least 1/2.

The picture shows the criterion is *sufficient* (nothing lies in the lower-right quadrant)
and *not necessary* (the upper-left quadrant is heavily populated).  The highlighted point is
the union-closed family {∅,{0},{1},{0,1},{0,1,2}}, which has an abundant element while failing
the criterion.  Produces `averaging.png`.
"""

from __future__ import annotations

from typing import FrozenSet, List, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def popcount(m: int) -> int:
    return bin(m).count("1")


def top(fam: FrozenSet[int]) -> int:
    t = 0
    for m in fam:
        t |= m
    return t


def deg(fam: FrozenSet[int], x: int) -> int:
    return sum(1 for m in fam if m >> x & 1)


def is_union_closed(fam: FrozenSet[int]) -> bool:
    return all((a | b) in fam for a in fam for b in fam)


def main() -> None:
    xs_pass: List[float] = []
    ys_pass: List[float] = []
    xs_fail: List[float] = []
    ys_fail: List[float] = []
    uc_x: List[float] = []
    uc_y: List[float] = []

    for code in range(1 << 8):
        fam = frozenset(m for m in range(8) if code >> m & 1)
        if not fam:
            continue
        s = top(fam)
        k = popcount(s)
        if k == 0:
            continue
        T = sum(popcount(m) for m in fam)
        dens = T / (k * len(fam))
        ratio = 2 * max(deg(fam, x) for x in range(3)) / len(fam)
        if 2 * T >= k * len(fam):
            xs_pass.append(dens)
            ys_pass.append(ratio)
        else:
            xs_fail.append(dens)
            ys_fail.append(ratio)
        if is_union_closed(fam):
            uc_x.append(dens)
            uc_y.append(ratio)

    fig, ax = plt.subplots(figsize=(8.4, 6.0))
    ax.axhspan(0, 1, color="#ffb3b3", alpha=0.22)
    ax.axvspan(0.5, 1.05, color="#b8e6cf", alpha=0.22)
    ax.scatter(xs_fail, ys_fail, s=26, color="#c0392b", alpha=0.55,
               label="averaging criterion fails")
    ax.scatter(xs_pass, ys_pass, s=30, color="#2f6fbf", alpha=0.75,
               label="averaging criterion holds")
    ax.scatter(uc_x, uc_y, s=14, color="#111", alpha=0.8, marker="x",
               label="union-closed families")

    # The union-closed witness that has an abundant element but fails the criterion.
    witness = frozenset({0b000, 0b001, 0b010, 0b011, 0b111})
    s = top(witness)
    T = sum(popcount(m) for m in witness)
    wx = T / (popcount(s) * len(witness))
    wy = 2 * max(deg(witness, x) for x in range(3)) / len(witness)
    ax.scatter([wx], [wy], s=170, facecolors="none", edgecolors="#ffc857", linewidths=2.4)
    ax.annotate(r"$\{\emptyset,\{0\},\{1\},\{0,1\},\{0,1,2\}\}$" "\nabundant, criterion fails",
                (wx, wy), textcoords="offset points", xytext=(14, -30), fontsize=10,
                color="#8a6d1e",
                arrowprops=dict(arrowstyle="->", color="#8a6d1e", lw=1.2))

    ax.axhline(1, color="#333", lw=1.3)
    ax.axvline(0.5, color="#1e8449", lw=1.3, ls="--")
    ax.annotate("abundance threshold", (0.26, 1.03), fontsize=10)
    ax.annotate("criterion threshold\n(average member = half the ground set)",
                (0.505, 0.06), fontsize=10, color="#1e8449")
    ax.set_xlabel(r"average member density  $T(F) / (|s|\,|F|)$")
    ax.set_ylabel(r"abundance ratio  $2\max_x \deg_F(x) / |F|$")
    ax.set_title("The averaging criterion is sufficient but not necessary\n"
                 "(all 255 nonempty families over a three-element ground set)", fontsize=12.5)
    ax.legend(loc="lower right", fontsize=9)
    ax.grid(alpha=0.22)
    fig.tight_layout()
    fig.savefig("averaging.png", dpi=160)
    print("wrote averaging.png")


if __name__ == "__main__":
    main()


"""Visualization: the sharp local degree law and its extremal families.

For a union-closed family F with a member A containing a, one has
    |F| <= (2^(|A|-1) + 1) * deg_F(a),
and the constant is attained by E(A,a) = {A} u P(A \\ {a}).

The left panel plots the predicted constant 2^(k-1)+1 against the maximum ratio |F|/deg(a)
actually observed by exhaustive enumeration of ALL union-closed families on a four-element
ground set (there are 4959 nonempty ones), broken down by the size k of the member A.  The
two agree exactly for k = 1,2,3,4.  The right panel shows how far the guarantee sits above
the abundance threshold 2 as k grows.  Produces `local_law.png`.
"""

from __future__ import annotations

from typing import Dict, FrozenSet, List

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def popcount(m: int) -> int:
    return bin(m).count("1")


def is_union_closed(fam: FrozenSet[int]) -> bool:
    return all((a | b) in fam for a in fam for b in fam)


def deg(fam: FrozenSet[int], x: int) -> int:
    return sum(1 for m in fam if m >> x & 1)


def observed_max_ratios(n: int = 4) -> Dict[int, float]:
    """Exhaustive search: max |F|/deg(a) over union-closed F, a in A in F, by |A| = k."""
    worst: Dict[int, float] = {k: 0.0 for k in range(1, n + 1)}
    for code in range(1 << (1 << n)):
        fam = frozenset(m for m in range(1 << n) if code >> m & 1)
        if not fam or not is_union_closed(fam):
            continue
        for A in fam:
            k = popcount(A)
            if k == 0:
                continue
            for a in range(n):
                if A >> a & 1:
                    d = deg(fam, a)
                    if d:
                        worst[k] = max(worst[k], len(fam) / d)
    return worst


def main() -> None:
    ks: List[int] = [1, 2, 3, 4]
    predicted = [2 ** (k - 1) + 1 for k in ks]
    observed = observed_max_ratios(4)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12.5, 4.6))

    width = 0.38
    ax1.bar([k - width / 2 for k in ks], predicted, width,
            label=r"predicted optimum $2^{k-1}+1$", color="#2f6fbf")
    ax1.bar([k + width / 2 for k in ks], [observed[k] for k in ks], width,
            label="observed maximum (exhaustive, 4-element ground set)", color="#ffc857")
    for k, p in zip(ks, predicted):
        ax1.annotate(str(p), (k - width / 2, p), textcoords="offset points",
                     xytext=(0, 4), ha="center", fontsize=10)
    ax1.axhline(2, color="#1e8449", ls="--", lw=1.6)
    ax1.annotate("abundance threshold  ratio = 2", (2.4, 2.25), color="#1e8449", fontsize=10)
    ax1.set_xticks(ks)
    ax1.set_xlabel("size $k = |A|$ of the member")
    ax1.set_ylabel(r"maximal ratio $|F| / \deg_F(a)$")
    ax1.set_title("The bound is attained for every $k$", fontsize=12)
    ax1.legend(fontsize=9)
    ax1.grid(axis="y", alpha=0.25)

    kk = list(range(1, 9))
    ax2.plot(kk, [2 ** (k - 1) + 1 for k in kk], "o-", color="#2f6fbf", lw=2,
             label=r"$2^{k-1}+1$: what one member of size $k$ guarantees")
    ax2.axhline(2, color="#1e8449", ls="--", lw=1.6, label="what abundance requires")
    ax2.fill_between(kk, 2, [2 ** (k - 1) + 1 for k in kk], color="#ffb3b3", alpha=0.35,
                     label="obstruction gap")
    ax2.set_yscale("log", base=2)
    ax2.set_xlabel("size $k = |A|$ of the member")
    ax2.set_ylabel("guaranteed ratio (log scale)")
    ax2.set_title("Only $k=1$ settles abundance", fontsize=12)
    ax2.legend(fontsize=9)
    ax2.grid(alpha=0.25)

    fig.suptitle(r"A single member of size $k$ forces $|F| \leq (2^{k-1}+1)\,\deg_F(a)$ — and no more",
                 fontsize=13)
    fig.tight_layout(rect=(0, 0, 1, 0.92))
    fig.savefig("local_law.png", dpi=160)
    print("wrote local_law.png")


if __name__ == "__main__":
    main()


"""Visualization: the surplus ledger as a lattice path along the union closure.

Each adjunction of a new set is worth exactly +1 to a tracked element x if the set contains x,
and -1 if it avoids x.  The plot draws the running surplus sigma = 2*deg - |F| as sets are
added, for three regimes:

  * adjoining the top of a family that lacks it            -- always a single +1 step;
  * completing the counterexample family {{0,1,2},{0,1},{1},{2}} to its union closure,
    where the new set {1,2} avoids 0 and pushes the surplus below zero;
  * a favourable schedule of the same closure for the element 1, which never drops.

The shaded region sigma < 0 is the "witness lost" zone.  Produces `surplus_walk.png`.
"""

from __future__ import annotations

from typing import Iterable, List, Sequence, Set, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def deg(fam: Iterable[int], x: int) -> int:
    return sum(1 for m in fam if m >> x & 1)


def surplus(fam: Sequence[int], x: int) -> int:
    return 2 * deg(fam, x) - len(fam)


def show(mask: int) -> str:
    elts = [i for i in range(4) if mask >> i & 1]
    return "{" + ",".join(map(str, elts)) + "}" if elts else "{}"


def closure(fam: Set[int]) -> Set[int]:
    cur = set(fam)
    while True:
        new = {a | b for a in cur for b in cur} - cur
        if not new:
            return cur
        cur |= new


def walk(start: Sequence[int], additions: Sequence[int], x: int) -> Tuple[List[int], List[str]]:
    """Running surplus of x as the sets in `additions` are adjoined one at a time."""
    fam = list(start)
    ys = [surplus(fam, x)]
    labels = ["start"]
    for a in additions:
        fam.append(a)
        ys.append(surplus(fam, x))
        labels.append(show(a))
    return ys, labels


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.4), sharey=True)

    # Panel 1: adjoining the top is a single +1 step.
    F1 = [0b0001, 0b0010, 0b0101]          # {0}, {1}, {0,2}
    top1 = 0b0111
    ys, labels = walk(F1, [top1], 0)
    axes[0].set_title("Adjoining the top: always $+1$", fontsize=11)

    # Panel 2: the closure destroys the witness for x = 0.
    F2 = [0b0111, 0b0011, 0b0010, 0b0100]  # {0,1,2},{0,1},{1},{2}
    added2 = sorted(closure(set(F2)) - set(F2))
    ys2, labels2 = walk(F2, added2, 0)
    axes[1].set_title("Union closure, tracking $x=0$: witness lost", fontsize=11)

    # Panel 3: same closure, tracking x = 1 -- never drops.
    ys3, labels3 = walk(F2, added2, 1)
    axes[2].set_title("Same closure, tracking $x=1$: schedule is safe", fontsize=11)

    for ax, ys_, labels_, colour in (
        (axes[0], ys, labels, "#2f6fbf"),
        (axes[1], ys2, labels2, "#c0392b"),
        (axes[2], ys3, labels3, "#1e8449"),
    ):
        xs = list(range(len(ys_)))
        ax.axhspan(-4, 0, color="#ffb3b3", alpha=0.28, zorder=0)
        ax.axhline(0, color="#444", lw=1, zorder=1)
        ax.plot(xs, ys_, "-o", color=colour, lw=2.2, ms=7, zorder=3)
        for i, (xi, yi) in enumerate(zip(xs, ys_)):
            ax.annotate(f"{yi:+d}", (xi, yi), textcoords="offset points",
                        xytext=(0, 9), ha="center", fontsize=9, color=colour)
        ax.set_xticks(xs)
        ax.set_xticklabels(labels_, rotation=40, ha="right", fontsize=9)
        ax.set_ylim(-2.6, 4.0)
        ax.set_xlabel("set adjoined")
        ax.grid(axis="y", alpha=0.25)

    axes[0].set_ylabel(r"surplus  $\sigma = 2\deg - |F|$")
    fig.suptitle("The surplus ledger: $+1$ for a set containing the tracked element, "
                 "$-1$ for one avoiding it", fontsize=12.5)
    fig.tight_layout(rect=(0, 0, 1, 0.93))
    fig.savefig("surplus_walk.png", dpi=160)
    print("wrote surplus_walk.png")


if __name__ == "__main__":
    main()


"""Assemble PACKAGE.json from the individual deliverables in this project."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List

ROOT = Path(__file__).resolve().parent
A = ROOT / "assets"


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


LEAN_FILES: List[str] = [
    "Catalog/Computation/UnionClosedAdjoinTop.lean",
    "Catalog/Computation/UnionClosedAbundanceAveraging.lean",
    "Catalog/Computation/UnionClosedLocalDegreeBound.lean",
    "Catalog/Computation/UnionClosedChainCertificate.lean",
]

lean_proofs = "\n\n".join(
    f"-- ==== {f} ====\n\n" + read(ROOT / f) for f in LEAN_FILES
)

FUTURE_DIRECTIONS = """# Future Directions — union-closed families, abundance, and the closure operation

## What has been established (context for the conjectures)

* Adjoining the top member preserves an abundant witness lying in the top; the parity of |F|
  is irrelevant because the surplus 2·deg − |F| moves up by exactly +1; the exact extra
  hypothesis is that the family be nonempty, with the empty family the unique counterexample.
* The mechanism is surplus additivity over disjoint batches; a batch of new sets costs one
  unit per set avoiding the tracked element.
* One step further — all pairwise unions, or the full union closure — abundance can be
  destroyed.
* Sharp local degree bound: |F| ≤ (2^{|A|−1} + 1)·deg_F(a) for a ∈ A ∈ F union-closed,
  attained for every |A|.
* Unconditional Frankl cases proved here: singleton member, pair member, chains, families with
  at most four members, families of large average member size; plus the exhaustive census over
  a three-element ground set.

## Direction 1 — Batch-surplus schedules for the union closure

The counterexample shows the closure can be surplus-negative, but it reaches its closure
through many single adjunctions, each of which is either +1 or −1. **Conjecture: for every
union-closed target there is an ordering of the added sets along which the running surplus of
some fixed element never drops below its starting value.** The key insight is that adjoining
the top is safe *because it is the batch of size one with positive surplus*, so the question is
not whether a batch is dangerous but whether it can be *scheduled* into safe increments. Why
now? Surplus additivity makes the schedule a purely combinatorial object — a lattice path — so
the conjecture is testable by exhaustive search on three- and four-element ground sets before
any proof attempt. (Such a search finds no family over a ground set of size 3 or 4 with a
nonempty member for which every element fails to admit a safe schedule.)

## Direction 2 — The 2^{k−1} + 1 law as a Frankl obstruction

A *single* member of size k can force nothing better than |F| ≤ (2^{k−1}+1)·deg, and this is
attained. **Conjecture: for a union-closed family in which every nonempty member has size at
least k, the best possible abundance ratio degrades exactly like 2^{k−1}+1, i.e. the extremal
family consisting of all subsets of A \\ {a} together with A is the unique extremiser up to
isomorphism.** The key insight is that the extremal family is a power set with a single "cap",
so extremality is a statement about how much of a Boolean lattice can sit below one cap. Why
now? Both the bound and its attainment are already established, so uniqueness is the only
missing ingredient, and it can be probed by enumerating extremisers on a four-element ground
set.

## Direction 3 — Frankl for families of bounded structural complexity

Chains and families of at most four members are the two extremes of the same counting: chains
maximise how many members can contain a fixed minimal element, small families minimise how many
members must be covered. The natural interpolations are families of bounded width in the
inclusion order, families generated by few sets, and families with a bounded number of maximal
members. In each case the surplus ledger provides a uniform way to measure how far the family
sits from the abundance threshold, and the local degree law says how much a single small member
can contribute.

## Direction 4 — Quantitative averaging

The averaging criterion is a threshold statement: average member size at least half the ground
set forces an abundant element. What is the best abundance guarantee obtainable as a function
of the average member density T(F)/(|s|·|F|)? A quantitative version would interpolate between
the trivial regime and the criterion, and could be combined with structural information about
union-closed families to enlarge the reach of the argument.
"""

INTERACTIVE_LAYOUT = r"""
# Abundance, the Top, and the Surplus Ledger

## A conjecture you can explain over coffee

A family $F$ of finite sets is **union-closed** when the union of any two of its members is
again a member. In 1979 Péter Frankl conjectured:

> If a union-closed family has at least one nonempty member, some element belongs to at least
> half of the members.

Call such an element **abundant**: writing $\deg_F(x)$ for the number of members containing
$x$, abundance means $|F| \le 2\deg_F(x)$. Almost fifty years later the conjecture is open.
This page is a guided tour of one operation on families that we understand *completely* — and
of exactly where that understanding stops.

The central object is the **surplus**
$$\sigma_F(x) \;=\; 2\deg_F(x) - |F| \in \mathbb{Z}, \qquad x \text{ abundant} \iff \sigma_F(x) \ge 0 .$$

<details>
<summary><strong>Background: why union-closed families are everywhere</strong></summary>

Anything that can only grow when you combine two things gives a union-closed family: the sets
of features fired by at least one example of a class, the reachable states of a monotone
process, the supports of sums in a positive cone, the closed sets of a matroid's dual under
union of flats' complements. The conjecture is a statement about the unavoidable presence of a
"popular" coordinate in such systems. See the
[Wikipedia entry on the union-closed sets conjecture](https://en.wikipedia.org/wiki/Union-closed_sets_conjecture)
for history and known partial results.
</details>

## 1. The two-versus-one accounting

Everything below is powered by one observation. Adjoin a single new set $A$ to $F$:

* if $x \in A$, then $|F|$ grows by $1$ and $\deg_F(x)$ grows by $1$, so $\sigma$ moves by
  $2 - 1 = \mathbf{+1}$;
* if $x \notin A$, then only $|F|$ grows, so $\sigma$ moves by $\mathbf{-1}$.

A new member is charged **once** against the family size and pays **twice** into the degree.
Play with it: build a family, pick an element to track, and watch the ledger.

{{interactive_demo:0}}

<details>
<summary><strong>Formal statement and proof of the unit-step rule</strong></summary>

**Lemma.** Let $A \notin F$. If $x \in A$ then $\sigma_{F\cup\{A\}}(x) = \sigma_F(x)+1$; if
$x \notin A$ then $\sigma_{F\cup\{A\}}(x) = \sigma_F(x)-1$.

*Proof.* In the first case both $|F|$ and $\deg_F(x)$ increase by exactly one, so
$\sigma = 2\deg - |F|$ changes by $2\cdot 1 - 1$. In the second the degree is unchanged while
$|F|$ increases by one. $\square$

**Corollary (additivity).** For disjoint families, $\sigma_{F \sqcup G}(x) = \sigma_F(x) + \sigma_G(x)$;
so abundance survives adjoining any batch at least half of whose sets contain $x$.
</details>

## 2. Adjoining the top is always safe

The **top** of $F$ is $\bigvee F = \bigcup_{A \in F} A$. If $F$ is union-closed and nonempty
the top is already a member; otherwise adjoining it is the natural first step of union-closing.

> **Theorem (Adjoining the top preserves a witness).** If $x$ is abundant in $F$ and
> $x \in \bigvee F$, then $x$ is abundant in $F^{+} = F \cup \{\bigvee F\}$, and when the top is
> new the surplus rises by exactly one.

The suspicion one naturally has — that the *parity* of $|F|$ could break a threshold condition
like $|F| \le 2\deg$ — turns out to be exactly backwards.

> **Theorem (Parity is a bonus).** If $|F|$ is odd and $x$ is abundant, then in fact
> $|F| + 1 \le 2\deg_F(x)$: on odd families abundance is automatically strict.

And the honest failure mode is degeneracy, not parity:

> **Theorem (Exact boundary).** For an abundant $x$: abundance survives adjoining the top **iff**
> $F \ne \varnothing$. The empty family is the unique counterexample — every element is
> vacuously abundant in $\varnothing$, and $\varnothing^{+} = \{\varnothing\}$ has none.

Press *Preset: empty family* in the lab above, then *Adjoin the top*, to see all witnesses die
at once.

{{algorithm:1}}

## 3. Where safety ends

Adjoining the top is one step of the union closure $\mathrm{ucl}(F)$ (the least union-closed
family containing $F$). The very next step need not be safe. Take
$$F = \{\{0,1,2\},\ \{0,1\},\ \{1\},\ \{2\}\}, \qquad x = 0 .$$
Two of four members contain $0$, so $\sigma = 0$; the top is already present, so $F^{+} = F$.
But one round of pairwise unions creates $\{1\}\cup\{2\} = \{1,2\}$, which avoids $0$: five
members, degree still two, $\sigma = -1$. The witness is gone.

{{visualization:0}}

Each adjunction is worth exactly $\pm 1$, so the closure traces a lattice path, and the
conjecture is a statement about where such paths can end.

{{algorithm:2}}

<details>
<summary><strong>What the schedule search finds on small ground sets</strong></summary>

Because the multiset of added sets is fixed, putting every set containing $x$ first maximises
every prefix of the path; the prefix minimum of that ordering is its final value. So a safe
schedule for $x$ exists precisely when $\sigma_{\mathrm{ucl}(F)}(x) \ge \sigma_F(x)$. Sweeping
all families over ground sets of size $3$ and $4$: individual witnesses *are* destroyed
(thousands of times), but no family with a nonempty member leaves *every* element unschedulable.
This is the computational evidence behind the scheduling conjecture below — evidence, not proof.
</details>

{{demo:1}}

## 4. Creating a witness out of thin air

So far we have transported witnesses. Can we manufacture one? Count incidences two ways:
$$\sum_{x \in s} \deg_F(x) \;=\; \sum_{A \in F} |A| \;=:\; T(F)$$
for any ground set $s$ containing all members — the row and column marginals of the incidence
matrix.

> **Theorem (Averaging criterion).** If $s \ne \varnothing$ contains every member and
> $|s|\,|F| \le 2T(F)$ — the members average at least half the ground set — then some $x \in s$
> is abundant. **No union-closedness is needed.**

<details>
<summary><strong>Proof in two lines</strong></summary>

Suppose $2\deg_F(x) < |F|$ for all $x \in s$. Summing this strict inequality over the nonempty
set $s$ gives $2\sum_{x\in s}\deg_F(x) < |s|\,|F|$; the left side is $2T(F)$ by the double
count, contradicting the hypothesis. $\square$
</details>

It is genuinely one-directional: the union-closed family
$\{\varnothing,\{0\},\{1\},\{0,1\},\{0,1,2\}\}$ has the abundant element $0$ (degree $3$ of $5$)
yet $T = 7$ while the criterion demands $2T \ge 15$. The picture below plots every family over a
three-element ground set in the plane (average member density, abundance ratio): the lower-right
quadrant is empty (the criterion is sufficient) and the upper-left is crowded (it is far from
necessary).

{{visualization:2}}

The pleasant surprise is that the criterion is preserved by the very operation of Section 2:

> **Theorem (Stability).** If $|\bigvee F|\,|F| \le 2T(F)$ then the same holds for $F^{+}$.

Adjoining a new top adds $|\bigvee F|$ incidences and one member, and $2m \ge m$ closes the
bookkeeping. So the operation preserves not just a witness but the hypothesis that produces
witnesses. It even strictly improves the scale-free statistic: if the top is new and $x$ misses
some member, the density $\deg_F(x)/|F|$ strictly increases.

{{algorithm:3}}

## 5. How much can one member tell you?

Frankl's conjecture is unconditionally true when the family contains a singleton $\{a\}$. What
if the smallest available member has size $k$?

> **Theorem (Sharp local degree law).** For union-closed $F$ with $a \in A \in F$,
> $$|F| \le \left(2^{|A|-1}+1\right)\deg_F(a),$$
> and equality holds for the family consisting of all subsets of $A \setminus \{a\}$ together
> with $A$ — so the constant is optimal for every size of $A$.

<details>
<summary><strong>Proof sketch: fibres of $B \mapsto B \cup A$</strong></summary>

Send each member $B$ avoiding $a$ to $B \cup A$, which is a member (union-closedness) containing
$a$. A fibre over $C$ is determined by $B \cap A$, because $B = (C\setminus A)\cup(B\cap A)$; and
$B \cap A \subseteq A\setminus\{a\}$, so fibres have at most $2^{|A|-1}$ elements. Hence the
members avoiding $a$ number at most $2^{|A|-1}\deg_F(a)$, and adding the $\deg_F(a)$ members
containing $a$ gives the bound. $\square$
</details>

Slide $k$ and watch the guarantee decay — and note that only $k=1$ reaches the abundance
threshold $2$:

{{interactive_demo:1}}

{{visualization:1}}

This is an **obstruction**: no argument that uses only a single member of size $\ge 2$ can prove
Frankl's conjecture. Any proof must use several members at once — as the pair theorem does.

## 6. Cases where the conjecture is simply true

* **Singleton.** $\{a\} \in F$ union-closed $\Rightarrow$ $a$ abundant (inject $B \mapsto B\cup\{a\}$).
* **Pair.** $\{a,b\} \in F$ union-closed $\Rightarrow$ $a$ or $b$ abundant; the counting core is
  $|F| \le \deg_F(a)+\deg_F(b)$, from inclusion–exclusion plus the injection $B \mapsto B\cup\{a,b\}$.
* **Chains.** A family totally ordered by inclusion with a nonempty member is automatically
  union-closed and always has an abundant element: every element of a minimum-size nonempty
  member lies in *every* nonempty member.
* **Small families.** At most four members, one of them nonempty $\Rightarrow$ abundant element,
  since two distinct nonempty members always force some element of degree $\ge 2$.
* **Three-element ground sets.** All $256$ families checked exhaustively.

Deciding abundance needs no search at all:

> **Certificate.** Over a nonempty ground set $s$, some $x \in s$ is abundant **iff**
> $|F| \le 2\max_{x\in s}\deg_F(x)$ — and adjoining the top never decreases that maximum.

{{algorithm:0}}

## 7. Run everything

The full computational companion reproduces every claim above: the surplus ledger, the exact
boundary census, the sharpness examples, the double count, the averaging criterion and its
stability, the extremal families with their exhaustive four-element confirmation of the
constants $2, 3, 5, 9$, the chain and small-family cases, and the certificate.

{{demo:0}}

## 8. Where this leaves the conjecture

Frankl's conjecture is untouched — but the shape of the difficulty is now sharp. The safe move
is a batch of size one with positive surplus. The dangerous moves are batches with more sets
avoiding your element than containing it. The closure is a sequence of $\pm 1$ moves, and the
conjecture asserts something about the endpoint that no step-by-step monotonicity supplies. The
most promising question is therefore not *which batches are dangerous* but *whether danger can
always be rescheduled away*:

> **Scheduling conjecture.** For every union-closed target there is an ordering of the added
> sets along which the running surplus of some fixed element never drops below its starting
> value.

That is a question about lattice paths, and — unlike the conjecture itself — you can start
testing it on a three-element ground set this afternoon.
"""

package: Dict[str, Any] = {
    "title": "Adjoining the Top: A Surplus Calculus for Abundance in Union-Closed Families",
    "domain": "Computation",
    "description": (
        "An exact accounting for how adjoining sets to a finite set family moves the abundance "
        "threshold |F| <= 2 deg(x): adjoining the union of all members always preserves an "
        "abundant witness (the empty family being the unique exception), an averaging criterion "
        "creates witnesses and is preserved by the same operation, and a sharp local law "
        "|F| <= (2^{|A|-1}+1) deg(a) shows no single member of size at least two can settle "
        "Frankl's union-closed sets conjecture."
    ),
    "authors": ["Aristotle"],
    "date": "2026-09-02",
    "key_results": [
        "Adjoining the top of a family preserves an abundant witness lying in the top, and when "
        "the top is a new member the surplus 2*deg(x) - |F| increases by exactly one, so the "
        "parity of the number of members is never an obstruction.",
        "Exact boundary: for an abundant element, abundance survives adjoining the top if and "
        "only if the family is nonempty; the empty family is the unique counterexample, while "
        "one further step (all pairwise unions, or the full union closure) can destroy the "
        "witness, as the family {{0,1,2},{0,1},{1},{2}} with tracked element 0 shows.",
        "Averaging criterion: if a nonempty ground set contains every member and the members "
        "average at least half its size, |s|*|F| <= 2*sum_{A in F}|A|, then some element of the "
        "ground set is abundant, with no union-closedness assumed; this criterion is itself "
        "preserved by adjoining the top, and the operation strictly increases the density "
        "deg(x)/|F| whenever the top is new and x misses some member.",
        "Sharp local degree law: for a union-closed family with a member A containing a, "
        "|F| <= (2^{|A|-1}+1)*deg(a), attained for every size of A by the family of all subsets "
        "of A minus a together with A, so no argument using a single member of size at least "
        "two can prove Frankl's conjecture.",
        "Unconditional cases of Frankl's union-closed sets conjecture: families containing a "
        "singleton or a two-element member, chains of arbitrary length, families with at most "
        "four members, families satisfying the averaging criterion, and all families over a "
        "three-element ground set; existence of an abundant element is equivalent to the single "
        "test |F| <= 2*max_x deg(x).",
    ],
    "keywords": [
        "union-closed families",
        "Frankl's conjecture",
        "abundant element",
        "surplus",
        "double counting",
        "averaging criterion",
        "union closure",
        "extremal family",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Complete Computational Companion: Surplus Ledger, Exact Boundary, "
                    "Averaging Criterion, and Sharp Local Degree Law",
            "description": (
                "A self-contained script that reproduces every result by explicit computation on "
                "bitmask-encoded families. It exhibits the unit-step rule (+1 for an adjoined set "
                "containing the tracked element, -1 for one avoiding it); verifies that adjoining "
                "the top raises the surplus by exactly one and strictly increases the density; "
                "sweeps all 256 families over a three-element ground set to confirm that the empty "
                "family is the unique case where an abundant witness is destroyed; confirms that "
                "odd families carry a unit of slack; exhibits the sharpness examples in which a "
                "single set avoiding the element, one pairwise-completion step, or the full union "
                "closure destroys abundance; checks the double count sum_x deg(x) = sum_A |A| and "
                "the averaging criterion together with its stability and a union-closed family "
                "showing it is not necessary; enumerates all 4959 nonempty union-closed families "
                "over a four-element ground set to confirm the optimal constants 2, 3, 5, 9 of the "
                "local degree law; and verifies Frankl's conjecture exhaustively on a three-element "
                "ground set alongside the chain and small-family cases."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "Exhaustive Census of Safe Closure Schedules on Small Ground Sets",
            "description": (
                "Computational exploration of the scheduling conjecture. Since the multiset of sets "
                "added by the union closure is fixed, the ordering that adjoins every set containing "
                "the tracked element first maximises every prefix of the surplus path, and its "
                "prefix minimum equals the final surplus; hence a safe schedule for an element "
                "exists exactly when the closure does not lower that element's surplus. The script "
                "sweeps every family with a nonempty member over ground sets of size three and four "
                "and reports how often the closure destroys an individual abundant witness (9 "
                "families on three elements, 5252 on four), how many families leave every element "
                "unschedulable (none in either sweep), and how many closures lack an abundant "
                "element (none). It prints explicit destroyed-witness examples with their closures."
            ),
            "code": read(A / "demo_schedule_census.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Degree–Surplus Profile and the Single-Maximum Abundance Certificate",
            "description": (
                "Computes the degree, surplus and density of every ground-set element in a single "
                "pass over the incidence structure, and decides the existence of an abundant "
                "element via the equivalence: some x in s is abundant if and only if "
                "|F| <= 2 max_{x in s} deg(x). The equivalence is what turns an existential "
                "quantifier over the ground set into one numerical comparison; the maximiser is the "
                "witness. Time complexity O(|F|*|s|) with O(|s|) auxiliary space, i.e. linear in the "
                "size of the incidence data. The certificate is monotone: enlarging the family can "
                "only increase the maximum degree, which is the algorithmic shadow of the surplus "
                "calculus. Note that the procedure does not reduce the complexity of Frankl's "
                "conjecture, since the family itself may be exponential in the ground set."
            ),
            "pseudocode": (
                "INPUT: family F of subsets of a ground set s\n"
                "OUTPUT: degrees, surpluses, densities, abundant elements, certificate, witness\n"
                "\n"
                "1. for each x in s: deg[x] <- 0\n"
                "2. for each member A in F:\n"
                "3.     for each x in A with x in s: deg[x] <- deg[x] + 1\n"
                "4. n <- |F|\n"
                "5. for each x in s:\n"
                "6.     sigma[x] <- 2*deg[x] - n\n"
                "7.     density[x] <- deg[x]/n           (0 if n = 0)\n"
                "8. abundant <- { x in s : sigma[x] >= 0 }\n"
                "9. cert <- max_{x in s} deg[x]          (0 if s empty)\n"
                "10. if n <= 2*cert then witness <- argmax_{x in s} deg[x] else witness <- none\n"
                "11. return (deg, sigma, density, abundant, cert, witness)"
            ),
            "code": read(A / "alg1_profile.py"),
        },
        {
            "name": "Top-Adjunction Audit with Predictive Surplus Update",
            "description": (
                "Given a family and a tracked element, computes the top (the union of all members), "
                "determines whether adjoining it changes the family, and predicts the resulting "
                "surplus, density and abundance status without recomputing any degree, using the "
                "unit-step rule: a new set containing the element moves the surplus by +1, one "
                "avoiding it by -1. Because the top contains every element occurring in the family, "
                "adjoining a new top is a +1 step for all of them simultaneously; it is a no-op "
                "exactly when the top is already a member, which is automatic for nonempty "
                "union-closed families. The audit also flags the unique degenerate case, the empty "
                "family, where every element is vacuously abundant beforehand and none is abundant "
                "afterwards. Complexity O(|F|*m) to form the top (m the size of the largest member) "
                "and O(1) per element for the update itself."
            ),
            "pseudocode": (
                "INPUT: family F, tracked element x\n"
                "OUTPUT: audit report (cardinalities, degree, surplus, density, verdict)\n"
                "\n"
                "1. T <- union of all members of F\n"
                "2. new <- (T not a member of F)\n"
                "3. n <- |F|;  d <- #{A in F : x in A};  sigma <- 2d - n\n"
                "4. if not new:\n"
                "5.     (n', d') <- (n, d)                  // adjoining the top is a no-op\n"
                "6. else:\n"
                "7.     n' <- n + 1\n"
                "8.     d' <- d + 1 if x in T else d        // unit-step rule, no recomputation\n"
                "9. sigma' <- 2d' - n'\n"
                "10. if n = 0: report the degenerate case (all witnesses destroyed) and stop\n"
                "11. report sigma -> sigma', density d/n -> d'/n', abundance n<=2d -> n'<=2d'"
            ),
            "code": read(A / "alg2_adjoin_audit.py"),
        },
        {
            "name": "Union Closure with a Surplus Ledger and Safe-Schedule Search",
            "description": (
                "Computes the union closure by iterated pairwise completion while recording, for a "
                "tracked element, the +1/-1 ledger of each adjunction, and searches for a safe "
                "schedule: an ordering of the newly added sets along which the running surplus never "
                "drops below its starting value. The search exploits an optimality argument: the "
                "multiset of added sets is determined by the closure, so any ordering has the same "
                "final surplus, and the ordering that places every set containing the element first "
                "maximises every prefix. Consequently the prefix minimum of the greedy order equals "
                "the final surplus, and a safe schedule exists for an element precisely when the "
                "closure does not lower that element's surplus. Closure computation costs "
                "O(|ucl(F)|^2) union operations and can be exponential in |F| in the worst case; "
                "the schedule search is O(k log k) in the number k of added sets. This is the "
                "experimental instrument for the scheduling conjecture."
            ),
            "pseudocode": (
                "INPUT: family F (bitmask-encoded), ground set s\n"
                "OUTPUT: for each element, a greedy schedule of the closure and its safety flag\n"
                "\n"
                "1. C <- F\n"
                "2. repeat\n"
                "3.     N <- { A | B : A, B in C } \\ C\n"
                "4.     C <- C u N\n"
                "5. until N is empty                        // C = ucl(F)\n"
                "6. for each x in s:\n"
                "7.     pending <- sort(C \\ F) with sets containing x first\n"
                "8.     cur <- F;  start <- 2*deg(cur,x) - |cur|;  running <- [start]\n"
                "9.     for each A in pending:\n"
                "10.        cur <- cur u {A}\n"
                "11.        append 2*deg(cur,x) - |cur| to running   // differs by exactly +-1\n"
                "12.    safe[x] <- (min(running) >= start)\n"
                "13. return the schedules, and any x with safe[x] = true"
            ),
            "code": read(A / "alg3_schedule.py"),
        },
        {
            "name": "Averaging Certificate and Witness Extraction by Double Counting",
            "description": (
                "Tests the averaging criterion |s|*|F| <= 2*T(F), where T(F) = sum over members of "
                "their cardinality, and extracts a witness when it holds. The mathematical basis is "
                "the double count sum_{x in s} deg(x) = T(F), the row and column marginals of the "
                "incidence matrix: if every element had degree strictly below half the number of "
                "members, summing over the nonempty ground set would contradict the hypothesis. The "
                "witness requires no search over subsets — any element of maximum degree works. The "
                "routine additionally verifies the double count numerically and checks stability "
                "under adjoining the top, which raises T by the size of the top and the number of "
                "members by one, so that the inequality is preserved. Complexity O(|F|*|s|) time "
                "and O(|s|) space. The criterion is sufficient but not necessary, which the routine "
                "illustrates on a sparse union-closed family that has an abundant element yet fails "
                "the test."
            ),
            "pseudocode": (
                "INPUT: family F, optional ground set s (default: the top of F)\n"
                "OUTPUT: criterion verdict, witness, double-count check, stability flag\n"
                "\n"
                "1. if s is not given: s <- union of all members of F\n"
                "2. T <- sum over A in F of |A|\n"
                "3. deg[x] <- #{A in F : x in A} for all x in s      // one pass\n"
                "4. assert sum_{x in s} deg[x] = T                   // double counting\n"
                "5. holds <- (s nonempty) and (|s|*|F| <= 2T)\n"
                "6. if holds:\n"
                "7.     w <- argmax_{x in s} deg[x]\n"
                "8.     assert |F| <= 2*deg[w]                       // guaranteed abundant\n"
                "9. T' <- T + |s| and n' <- |F| + 1 if the top is new, else (T, |F|)\n"
                "10. stable <- (not holds) or (|s|*n' <= 2T')        // criterion survives\n"
                "11. return (holds, w, stable)"
            ),
            "code": read(A / "alg4_averaging.py"),
        },
    ],
    "visualizations": [
        {
            "name": "The Surplus Ledger as a Lattice Path",
            "description": (
                "Three panels showing the running surplus 2*deg - |F| of a tracked element as sets "
                "are adjoined one at a time, with the region below zero shaded as the 'witness lost' "
                "zone. Panel one: adjoining the top of a family that lacks it is a single +1 step. "
                "Panel two: completing {{0,1,2},{0,1},{1},{2}} to its union closure adds {1,2}, "
                "which avoids the element 0, and the surplus falls from 0 to -1. Panel three: the "
                "identical closure tracked at the element 1, where the path never drops. Together "
                "they show that the danger lies in specific adjunctions, not in closure per se."
            ),
            "code": read(A / "viz_surplus_walk.py"),
        },
        {
            "name": "Sharpness of the 2^(k-1)+1 Local Degree Law",
            "description": (
                "Left panel: the constant 2^(k-1)+1 predicted by the local degree law against the "
                "maximum ratio |F|/deg(a) actually observed by exhaustive enumeration of every "
                "union-closed family on a four-element ground set, broken down by the size k of the "
                "member; the two agree exactly at 2, 3, 5, 9. Right panel: the exponential growth of "
                "the guarantee on a log scale against the constant 2 that abundance requires, with "
                "the gap between them shaded as the obstruction region — only k = 1 reaches the "
                "threshold, which is precisely Frankl's singleton case."
            ),
            "code": read(A / "viz_local_law.py"),
        },
        {
            "name": "The Averaging Criterion: Sufficient but Far from Necessary",
            "description": (
                "Every nonempty family over a three-element ground set plotted by average member "
                "density T(F)/(|s||F|) against abundance ratio 2 max_x deg(x)/|F|, with union-closed "
                "families marked. A family has an abundant element exactly when its height is at "
                "least one, and passes the averaging criterion exactly when its abscissa is at least "
                "one half. The lower-right quadrant is empty, which is the criterion's sufficiency; "
                "the upper-left quadrant is crowded, which is its failure to be necessary. The "
                "highlighted point is the union-closed family {∅,{0},{1},{0,1},{0,1,2}}, abundant at "
                "the element 0 yet failing the test."
            ),
            "code": read(A / "viz_averaging.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Surplus Lab — build a family, track an element, watch the ledger",
            "description": (
                "A full laboratory for the surplus calculus on the ground set {0,1,2,3}. Toggle any "
                "of the sixteen subsets into the family, choose the element to track, and read off "
                "the number of members, the top, the degree, the surplus, the density, the total "
                "size, the averaging test, union-closedness and the single-maximum certificate, all "
                "updating live. Degree bars display each element against the gold half-way line that "
                "defines abundance. Buttons adjoin the top, perform one pairwise-completion step, or "
                "compute the full union closure, and a running ledger records the exact +1 or -1 "
                "paid by every move. Five presets stage the key phenomena: a family whose top is "
                "missing (a clean +1), the four-member counterexample whose closure destroys the "
                "witness at the element 0, a chain, the extremal family attaining the local degree "
                "law with nine members and degree one, and the empty family, the unique case where "
                "adjoining the top annihilates every vacuous witness."
            ),
            "html": read(A / "widget_surplus_lab.html"),
        },
        {
            "title": "The 2^(k-1)+1 Law — how much a single member can tell you",
            "description": (
                "An explorer for the sharp local degree law. Slide the size k of the member A and "
                "the widget builds the extremal family — every subset of A minus the element a, plus "
                "the single cap A — displaying its 2^(k-1)+1 members, the fact that exactly one of "
                "them contains a, and the resulting best-possible ratio |F|/deg(a). A live chart "
                "plots that ratio against the value 2 that abundance demands, making visible that "
                "only k = 1 (Frankl's singleton case) reaches the threshold, and that for every "
                "larger k the bound is attained, so single-member arguments are provably incapable "
                "of settling the conjecture."
            ),
            "html": read(A / "widget_local_law.html"),
        },
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "schedule_census": read(A / "demo_schedule_census.py"),
        "profile_algorithm": read(A / "alg1_profile.py"),
        "adjoin_top_audit": read(A / "alg2_adjoin_audit.py"),
        "closure_schedule": read(A / "alg3_schedule.py"),
        "averaging_certificate": read(A / "alg4_averaging.py"),
    },
    "lean_files": LEAN_FILES,
}

(ROOT / "PACKAGE.json").write_text(
    json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
)
print("wrote PACKAGE.json")


"""
Surplus calculus for union-closed families: numerical demonstrations.

This self-contained script demonstrates, by explicit computation, every result of the
accompanying paper:

  * degrees, abundance and the surplus  sigma_F(x) = 2*deg_F(x) - |F|;
  * adjoining the top  F^+ = F u {top(F)}  raises the surplus of any element of the top
    by exactly +1 (and is a no-op when the top is already a member);
  * the exact boundary: F = empty is the unique family on which an abundant witness is
    destroyed by adjoining the top;
  * parity is a bonus, not an obstruction (odd families carry a unit of slack);
  * sharpness: adjoining a set avoiding x, one pairwise-completion step, or the full
    union closure can each destroy abundance;
  * double counting  sum_x deg_F(x) = sum_A |A|  and the averaging criterion
    |s|*|F| <= 2*T(F)  =>  some x in s is abundant, together with its stability under
    adjoining the top and a family showing it is not necessary;
  * strict density improvement  deg/|F| < (deg+1)/(|F|+1);
  * the sharp local degree law  |F| <= (2^(|A|-1) + 1) * deg_F(a),  with the extremal
    family attaining it, and an exhaustive search over all union-closed families on a
    four-element ground set confirming the constants 2, 3, 5, 9;
  * Frankl's conjecture verified exhaustively on a three-element ground set, plus the
    chain and small-family cases.

Sets are encoded as integer bitmasks; a family is a frozenset of bitmasks.  Run with
`python3 demo.py`.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Sequence, Set, Tuple

Family = FrozenSet[int]

# --------------------------------------------------------------------------------------
# Basic encoding helpers
# --------------------------------------------------------------------------------------


def bits(mask: int) -> List[int]:
    """The elements of the set encoded by `mask`, as a sorted list of ground-set indices."""
    out: List[int] = []
    i = 0
    while (1 << i) <= mask:
        if mask >> i & 1:
            out.append(i)
        i += 1
    return out


def show_set(mask: int) -> str:
    """Human-readable rendering of a bitmask set."""
    elts = bits(mask)
    return "{}" if not elts else "{" + ",".join(str(e) for e in elts) + "}"


def show_family(fam: Iterable[int]) -> str:
    """Human-readable rendering of a family, sorted by size then value."""
    members = sorted(fam, key=lambda m: (bin(m).count("1"), m))
    return "{" + ", ".join(show_set(m) for m in members) + "}"


def from_sets(sets: Sequence[Sequence[int]]) -> Family:
    """Build a family from explicit lists of ground-set indices."""
    return frozenset(sum(1 << e for e in s) for s in sets)


# --------------------------------------------------------------------------------------
# The core statistics
# --------------------------------------------------------------------------------------


def deg(fam: Family, x: int) -> int:
    """Number of members of `fam` containing the ground-set element `x`."""
    return sum(1 for m in fam if m >> x & 1)


def is_abundant(fam: Family, x: int) -> bool:
    """True iff `x` lies in at least half of the members: |F| <= 2 deg_F(x)."""
    return len(fam) <= 2 * deg(fam, x)


def surplus(fam: Family, x: int) -> int:
    """The integer surplus 2 deg_F(x) - |F|; abundance is exactly surplus >= 0."""
    return 2 * deg(fam, x) - len(fam)


def top(fam: Family) -> int:
    """The top of the family: the union of all its members (0 for the empty family)."""
    t = 0
    for m in fam:
        t |= m
    return t


def adjoin_top(fam: Family) -> Family:
    """F^+ = F u {top(F)}."""
    return fam | {top(fam)}


def total_size(fam: Family) -> int:
    """T(F) = sum over members of their cardinality = number of incidences."""
    return sum(bin(m).count("1") for m in fam)


def density(fam: Family, x: int) -> float:
    """The fraction deg_F(x)/|F| of members containing x (0 for the empty family)."""
    return 0.0 if not fam else deg(fam, x) / len(fam)


def is_union_closed(fam: Family) -> bool:
    """True iff the family is closed under binary unions."""
    return all((a | b) in fam for a in fam for b in fam)


def pair_union(fam: Family) -> Family:
    """One step of pairwise completion: adjoin all unions of two members."""
    return fam | frozenset(a | b for a in fam for b in fam)


def union_closure(fam: Family) -> Family:
    """The least union-closed family containing `fam` (iterated pairwise completion)."""
    cur = fam
    while True:
        nxt = pair_union(cur)
        if nxt == cur:
            return cur
        cur = nxt


def abundant_elements(fam: Family, ground: Iterable[int]) -> List[int]:
    """All elements of `ground` that are abundant in `fam`."""
    return [x for x in ground if is_abundant(fam, x)]


def max_degree(fam: Family, ground: Sequence[int]) -> int:
    """The certificate value max_{x in s} deg_F(x)."""
    return max((deg(fam, x) for x in ground), default=0)


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------


def banner(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def demo_surplus_ledger() -> None:
    banner("1. The surplus ledger: +1 for a set containing x, -1 for a set avoiding x")
    fam = from_sets([[0], [1], [0, 1]])
    x = 0
    print(f"F  = {show_family(fam)},  x = {x}")
    print(f"   |F| = {len(fam)},  deg = {deg(fam, x)},  surplus = {surplus(fam, x):+d},"
          f"  abundant = {is_abundant(fam, x)}")
    good = 1 << 0 | 1 << 2  # {0,2}: contains x
    bad = 1 << 1 | 1 << 2   # {1,2}: avoids x
    for name, new in (("contains x", good), ("avoids   x", bad)):
        g = fam | {new}
        print(f"   adjoin {show_set(new)} ({name}): surplus {surplus(fam, x):+d} -> "
              f"{surplus(g, x):+d}   (change {surplus(g, x) - surplus(fam, x):+d})")


def demo_adjoin_top() -> None:
    banner("2. Adjoining the top preserves the witness; the surplus rises by exactly 1")
    fam = from_sets([[0], [1], [0, 2]])
    x = 0
    t = top(fam)
    plus = adjoin_top(fam)
    print(f"F   = {show_family(fam)}   top = {show_set(t)}   top in F? {t in fam}")
    print(f"F^+ = {show_family(plus)}")
    print(f"   x = {x}:  surplus {surplus(fam, x):+d} -> {surplus(plus, x):+d}"
          f"   abundant {is_abundant(fam, x)} -> {is_abundant(plus, x)}")
    print(f"   density  {density(fam, x):.4f} -> {density(plus, x):.4f}"
          f"   (strictly increases: {density(plus, x) > density(fam, x)})")

    print("\n   Already-closed family: adjoining the top is a no-op.")
    uc = from_sets([[0], [0, 1], [0, 1, 2]])
    print(f"   F = {show_family(uc)}  union-closed = {is_union_closed(uc)}"
          f"  F^+ == F ? {adjoin_top(uc) == uc}")


def demo_empty_boundary() -> None:
    banner("3. The exact boundary: F = {} is the unique counterexample")
    empty: Family = frozenset()
    print(f"F = {show_family(empty)}:  |F| = 0, deg = 0, every x is vacuously abundant"
          f" -> {is_abundant(empty, 0)}")
    plus = adjoin_top(empty)
    print(f"F^+ = {show_family(plus)}:  |F^+| = {len(plus)}, deg = {deg(plus, 0)},"
          f" abundant = {is_abundant(plus, 0)}")

    ground = [0, 1, 2]
    all_sets = list(range(8))
    failures: List[Family] = []
    for r in range(len(all_sets) + 1):
        for sub in combinations(all_sets, r):
            fam = frozenset(sub)
            for x in ground:
                if is_abundant(fam, x) and not is_abundant(adjoin_top(fam), x):
                    failures.append(fam)
    print(f"\n   Exhaustive census over all 2^8 = 256 families on a 3-element ground set:")
    print(f"   families where an abundant witness is destroyed: "
          f"{[show_family(f) for f in sorted(set(failures), key=len)]}")


def demo_parity() -> None:
    banner("4. Parity is a bonus, not an obstruction")
    print("   On a family of odd size, |F| <= 2 deg forces |F| + 1 <= 2 deg:")
    checked = 0
    for r in range(9):
        for sub in combinations(range(8), r):
            fam = frozenset(sub)
            if len(fam) % 2 == 1:
                for x in range(3):
                    if is_abundant(fam, x):
                        assert len(fam) + 1 <= 2 * deg(fam, x)
                        checked += 1
    print(f"   verified on {checked} (odd family, abundant element) pairs over 3 elements.")
    fam = from_sets([[0], [0, 1], [1]])
    print(f"   example: F = {show_family(fam)}, |F| = 3, deg(0) = {deg(fam, 0)},"
          f" surplus = {surplus(fam, 0):+d} (strict slack)")


def demo_closure_destroys() -> None:
    banner("5. One step further: pairwise completion and the closure can destroy abundance")
    fam = from_sets([[0, 1, 2], [0, 1], [1], [2]])
    x = 0
    pu = pair_union(fam)
    ucl = union_closure(fam)
    for name, g in (("F        ", fam), ("F^+      ", adjoin_top(fam)),
                    ("pairwise ", pu), ("closure  ", ucl)):
        print(f"   {name} = {show_family(g):<48} |G| = {len(g)}, deg(0) = {deg(g, x)},"
              f" surplus = {surplus(g, x):+d}, abundant = {is_abundant(g, x)}")

    print("\n   And a single set avoiding x already suffices:")
    small = from_sets([[], [0]])
    grown = small | {1 << 1}
    print(f"   F = {show_family(small)} (abundant: {is_abundant(small, 0)})"
          f"  ->  F u {{{show_set(1 << 1)}}} = {show_family(grown)}"
          f" (abundant: {is_abundant(grown, 0)})")


def demo_double_counting_and_averaging() -> None:
    banner("6. Double counting, the averaging criterion, and its stability")
    fam = from_sets([[0, 1], [1, 2], [0, 1, 2], [0, 2]])
    t = top(fam)
    ground = bits(t)
    lhs = sum(deg(fam, x) for x in ground)
    print(f"F = {show_family(fam)},  ground set s = top(F) = {show_set(t)}")
    print(f"   sum_x deg_F(x) = {lhs}   =   sum_A |A| = T(F) = {total_size(fam)}")
    crit = len(ground) * len(fam) <= 2 * total_size(fam)
    print(f"   averaging test: |s|*|F| = {len(ground) * len(fam)} <= 2 T(F) ="
          f" {2 * total_size(fam)}  ->  {crit}")
    print(f"   abundant elements of s: {abundant_elements(fam, ground)}")

    plus = adjoin_top(fam)
    gp = bits(top(plus))
    crit2 = len(gp) * len(plus) <= 2 * total_size(plus)
    print(f"   after adjoining the top: |s|*|F^+| = {len(gp) * len(plus)} <= 2 T(F^+) ="
          f" {2 * total_size(plus)}  ->  {crit2}   (criterion is stable)")

    print("\n   Sufficient but NOT necessary:")
    sparse = from_sets([[], [0], [1], [0, 1], [0, 1, 2]])
    g2 = bits(top(sparse))
    print(f"   F = {show_family(sparse)}  union-closed = {is_union_closed(sparse)}")
    print(f"   deg(0) = {deg(sparse, 0)} of |F| = {len(sparse)} -> abundant ="
          f" {is_abundant(sparse, 0)}, but |s|*|F| = {len(g2) * len(sparse)}"
          f" > 2 T(F) = {2 * total_size(sparse)}")

    print("\n   Exhaustive check of the averaging criterion on a 3-element ground set:")
    passing = 0
    for r in range(9):
        for sub in combinations(range(8), r):
            f2 = frozenset(sub)
            s2 = bits(top(f2))
            if s2 and len(s2) * len(f2) <= 2 * total_size(f2):
                passing += 1
                assert abundant_elements(f2, s2), show_family(f2)
    print(f"   {passing} families satisfy the hypothesis; all of them have an abundant"
          f" element of their top.")


def demo_local_degree_law() -> None:
    banner("7. The sharp local degree law  |F| <= (2^(|A|-1) + 1) deg_F(a)")
    for k in (1, 2, 3, 4):
        A = (1 << k) - 1          # the set {0, ..., k-1}
        a = 0
        rest = A & ~(1 << a)      # A \ {a}
        subsets = [m for m in range(1 << k) if m & ~rest == 0]
        extremal = frozenset(subsets) | {A}
        bound = 2 ** (k - 1) + 1
        print(f"   |A| = {k}: extremal family has {len(extremal)} members,"
              f" deg(a) = {deg(extremal, a)}, bound constant = {bound},"
              f" union-closed = {is_union_closed(extremal)},"
              f" equality = {len(extremal) == bound * deg(extremal, a)}")

    print("\n   Exhaustive search over all union-closed families on a 4-element ground set:")
    worst: Dict[int, float] = {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0}
    n_uc = 0
    all_sets = list(range(16))
    for code in range(1 << 16):
        fam = frozenset(m for i, m in enumerate(all_sets) if code >> i & 1)
        if not fam or not is_union_closed(fam):
            continue
        n_uc += 1
        for A in fam:
            k = bin(A).count("1")
            if k == 0:
                continue
            for a in bits(A):
                d = deg(fam, a)
                if d > 0:
                    worst[k] = max(worst[k], len(fam) / d)
    print(f"   union-closed families found: {n_uc}")
    for k in (1, 2, 3, 4):
        print(f"   |A| = {k}: max |F|/deg(a) observed = {worst[k]:g},"
              f"  predicted optimum 2^(|A|-1)+1 = {2 ** (k - 1) + 1}")


def demo_frankl_cases() -> None:
    banner("8. Unconditional cases of Frankl's conjecture")
    chain = from_sets([[0], [0, 1], [0, 1, 2], [0, 1, 2, 3]])
    print(f"   chain  F = {show_family(chain)}  union-closed = {is_union_closed(chain)}"
          f"  abundant elements = {abundant_elements(chain, [0, 1, 2, 3])}")

    small = from_sets([[1, 2], [0, 1, 2], [2]])
    print(f"   small  F = {show_family(small)}  |F| = {len(small)}"
          f"  abundant elements = {abundant_elements(small, [0, 1, 2])}")

    singleton = union_closure(from_sets([[0], [1, 2], [0, 2]]))
    print(f"   closure of a family containing {{0}}: {show_family(singleton)}"
          f"  0 abundant = {is_abundant(singleton, 0)}")

    print("\n   Exhaustive verification on a 3-element ground set:")
    total, exceptional = 0, []
    for r in range(9):
        for sub in combinations(range(8), r):
            fam = frozenset(sub)
            if not is_union_closed(fam) or not any(m != 0 for m in fam):
                continue
            total += 1
            if not abundant_elements(fam, [0, 1, 2]):
                exceptional.append(fam)
    print(f"   {total} union-closed families with a nonempty member; counterexamples:"
          f" {[show_family(f) for f in exceptional]}")
    degenerate = frozenset({0})
    print(f"   (the excluded family {show_family(degenerate)} has no nonempty member and"
          f" no abundant element: {abundant_elements(degenerate, [0, 1, 2])})")


def demo_certificate() -> None:
    banner("9. The single-maximum certificate and its monotonicity")
    fam = from_sets([[0, 1], [1], [1, 2], [2]])
    ground = [0, 1, 2]
    cert = max_degree(fam, ground)
    plus = adjoin_top(fam)
    print(f"F = {show_family(fam)}")
    print(f"   max deg over s = {cert};  test |F| = {len(fam)} <= 2*max = {2 * cert}"
          f"  ->  {len(fam) <= 2 * cert}")
    print(f"   abundant elements: {abundant_elements(fam, ground)}")
    print(f"   after adjoining the top {show_set(top(fam))}: max deg ="
          f" {max_degree(plus, ground)} (never decreases), test"
          f" {len(plus)} <= {2 * max_degree(plus, ground)} ->"
          f" {len(plus) <= 2 * max_degree(plus, ground)}")


def main() -> None:
    demo_surplus_ledger()
    demo_adjoin_top()
    demo_empty_boundary()
    demo_parity()
    demo_closure_destroys()
    demo_double_counting_and_averaging()
    demo_local_degree_law()
    demo_frankl_cases()
    demo_certificate()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
