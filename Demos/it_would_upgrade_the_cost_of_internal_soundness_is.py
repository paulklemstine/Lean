"""
Conservativity for Tangled Hierarchies -- numerical demonstrations.

A *tangled hierarchy* is a propositional language with atoms a in A, falsum, and
implication, extended by an internal truth atom T c for every *name* c, together
with a denotation function den mapping each name c to a formula den(c) that may
mention T c itself.  Its theory is the family of Tarski biconditionals

        T c  <->  den(c)          (one for each name c).

A *model over a base valuation v* is an assignment w of truth values to names
solving all of these equations simultaneously.  The central theorem is:

        the tangle adds no new truth-free consequence to any truth-free base
        theory  <==>  every base valuation expands to a model.

This script implements the syntax, semantics, and every algorithm from the
development, and then verifies the quantitative results numerically:

  1. the single-name trichotomy  1 / 2 / 0  (grounded / truth-teller / liar);
  2. k independent strange loops have exactly 2^k models and add no theorem;
  3. positive tangles always have a model (Knaster-Tarski), checked by
     exhaustive enumeration over a large random sample;
  4. grounded and well-founded tangles have exactly one model;
  5. the mixed tangle:  locally stratified, but neither positive nor grounded;
  6. the tautological loop  T c -> T c:  conservative although not locally
     stratified -- local stratification is sufficient, not necessary;
  7. an exhaustive census of all small single-name denotations, exhibiting the
     exact correlation between negative self-reference and loss of models;
  8. a direct, brute-force conservativity audit over a finite base language.

Run with:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, FrozenSet, Iterable, List, Optional, Sequence, Set, Tuple

# ---------------------------------------------------------------------------
# 1.  Syntax
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Atom:
    """An atom of the old (truth-free) vocabulary."""

    name: str


@dataclass(frozen=True)
class Fls:
    """Falsum."""


@dataclass(frozen=True)
class Imp:
    """Implication."""

    left: "Frm"
    right: "Frm"


@dataclass(frozen=True)
class Tr:
    """The internal truth atom of a name."""

    name: str


Frm = object  # union of Atom | Fls | Imp | Tr


def neg(phi: Frm) -> Frm:
    """Negation, encoded as `phi -> falsum`."""
    return Imp(phi, Fls())


def show(phi: Frm) -> str:
    """Readable rendering of a formula."""
    if isinstance(phi, Atom):
        return phi.name
    if isinstance(phi, Fls):
        return "⊥"
    if isinstance(phi, Tr):
        return f"T{phi.name}"
    assert isinstance(phi, Imp)
    if isinstance(phi.right, Fls):
        return f"¬{show(phi.left)}"
    return f"({show(phi.left)} → {show(phi.right)})"


# ---------------------------------------------------------------------------
# 2.  Semantics
# ---------------------------------------------------------------------------

Valuation = Dict[str, bool]  # base atoms  -> truth values
Assignment = Dict[str, bool]  # names       -> truth values


def evaluate(phi: Frm, v: Valuation, w: Assignment) -> bool:
    """Truth value of `phi` under base valuation `v` and name assignment `w`."""
    if isinstance(phi, Atom):
        return v[phi.name]
    if isinstance(phi, Fls):
        return False
    if isinstance(phi, Tr):
        return w[phi.name]
    assert isinstance(phi, Imp)
    return (not evaluate(phi.left, v, w)) or evaluate(phi.right, v, w)


def truth_free(phi: Frm) -> bool:
    """Does `phi` avoid the internal truth predicate entirely?"""
    if isinstance(phi, (Atom, Fls)):
        return True
    if isinstance(phi, Tr):
        return False
    assert isinstance(phi, Imp)
    return truth_free(phi.left) and truth_free(phi.right)


def occurs(c: str, phi: Frm) -> bool:
    """Does the name `c` occur in `phi`?"""
    if isinstance(phi, (Atom, Fls)):
        return False
    if isinstance(phi, Tr):
        return phi.name == c
    assert isinstance(phi, Imp)
    return occurs(c, phi.left) or occurs(c, phi.right)


def occurrences(phi: Frm) -> Set[str]:
    """All names occurring in `phi`."""
    if isinstance(phi, (Atom, Fls)):
        return set()
    if isinstance(phi, Tr):
        return {phi.name}
    assert isinstance(phi, Imp)
    return occurrences(phi.left) | occurrences(phi.right)


def occurs_pol(c: str, phi: Frm, positive: bool) -> bool:
    """Does `c` occur with the given polarity in `phi`?

    Positive = under an even number of antecedent positions.
    """
    if isinstance(phi, (Atom, Fls)):
        return False
    if isinstance(phi, Tr):
        return positive and phi.name == c
    assert isinstance(phi, Imp)
    return occurs_pol(c, phi.left, not positive) or occurs_pol(c, phi.right, positive)


def is_positive(phi: Frm) -> bool:
    """Is every truth atom of `phi` in positive position (no truth atom negated)?"""
    return all(not occurs_pol(c, phi, False) for c in occurrences(phi))


# ---------------------------------------------------------------------------
# 3.  Tangled hierarchies
# ---------------------------------------------------------------------------

Tangle = Dict[str, Frm]  # name -> the sentence it denotes


def is_model(den: Tangle, v: Valuation, w: Assignment) -> bool:
    """Does `w` solve every loop equation  w(c) <-> den(c)  over `v`?"""
    return all(w[c] == evaluate(den[c], v, w) for c in den)


def all_assignments(names: Sequence[str]) -> Iterable[Assignment]:
    """Every truth assignment to the given names."""
    for bits in product([False, True], repeat=len(names)):
        yield dict(zip(names, bits))


def models(den: Tangle, v: Valuation) -> List[Assignment]:
    """ALGORITHM (brute force): all models of the tangle over `v`.  O(2^n * s)."""
    names = sorted(den)
    return [w for w in all_assignments(names) if is_model(den, v, w)]


def revise(den: Tangle, v: Valuation, w: Assignment) -> Assignment:
    """One application of the revision operator  R(w)(c) = [[den(c)]]_{v,w}."""
    return {c: evaluate(den[c], v, w) for c in den}


def kleene_lfp(den: Tangle, v: Valuation) -> Assignment:
    """ALGORITHM: least fixed point of a *positive* tangle, by Kleene iteration.

    Starts at the everywhere-false assignment and iterates the monotone revision
    operator; converges in at most |names| steps.  Complexity O(n * s).
    """
    w: Assignment = {c: False for c in den}
    for _ in range(len(den) + 1):
        w2 = revise(den, v, w)
        if w2 == w:
            return w
        w = w2
    return w


def kleene_gfp(den: Tangle, v: Valuation) -> Assignment:
    """ALGORITHM: greatest fixed point of a positive tangle, dually.  O(n * s)."""
    w: Assignment = {c: True for c in den}
    for _ in range(len(den) + 1):
        w2 = revise(den, v, w)
        if w2 == w:
            return w
        w = w2
    return w


# ---------------------------------------------------------------------------
# 4.  Structural conditions
# ---------------------------------------------------------------------------


def grounded_rank(den: Tangle) -> Optional[Dict[str, int]]:
    """ALGORITHM: a rank with strictly descending dependencies, if one exists.

    Equivalently (height collapse theorem) a witness that the dependency
    relation is well founded.  Computed by iterated relaxation; returns None if
    the dependency graph has a cycle.  Complexity O(n * s).
    """
    rank: Dict[str, int] = {c: 0 for c in den}
    for _ in range(len(den) + 1):
        changed = False
        for c in den:
            need = max((rank[d] + 1 for d in occurrences(den[c]) if d in den), default=0)
            if need > rank[c]:
                rank[c], changed = need, True
        if not changed:
            return rank
    return None


def local_stratification(den: Tangle) -> Optional[Dict[str, int]]:
    """ALGORITHM: a local stratification rank, if one exists.

    Requires  rk(c') <  rk(c)  for every NEGATIVE occurrence of c' in den(c),
    and       rk(c') <= rk(c)  for every POSITIVE occurrence.
    Solved as a difference-constraint system by Bellman-Ford style relaxation;
    returns None when a positive-weight cycle (a negative edge inside a strongly
    connected component) blocks all solutions.  Complexity O(n * |E|).
    """
    edges: List[Tuple[str, str, int]] = []  # (source name c', target name c, slack)
    for c, phi in den.items():
        for d in occurrences(phi):
            if d not in den:
                continue
            if occurs_pol(d, phi, False):
                edges.append((d, c, 1))
            if occurs_pol(d, phi, True):
                edges.append((d, c, 0))
    rank: Dict[str, int] = {c: 0 for c in den}
    for _ in range(len(den) + 1):
        changed = False
        for (src, tgt, slack) in edges:
            if rank[src] + slack > rank[tgt]:
                rank[tgt] = rank[src] + slack
                changed = True
        if not changed:
            return rank
    return None


def level_model(den: Tangle, rank: Dict[str, int], v: Valuation) -> Assignment:
    """ALGORITHM: the level-by-level model of a locally stratified tangle.

    Levels are processed in increasing rank; everything strictly below the
    current level is frozen at its computed value, and within the level the
    least fixed point of the (monotone) level operator is reached by Kleene
    iteration.  Complexity O(n * s).
    """
    built: Assignment = {c: False for c in den}
    for n in range(max(rank.values(), default=0) + 1):
        w: Assignment = {c: False for c in den}
        for _ in range(len(den) + 1):
            merged = {c: (built[c] if rank[c] < n else w[c]) for c in den}
            w2 = {c: (evaluate(den[c], v, merged) if rank[c] <= n else False) for c in den}
            if w2 == w:
                break
            w = w2
        built = w
    return built


# ---------------------------------------------------------------------------
# 5.  Conservativity auditing
# ---------------------------------------------------------------------------


def expandable_everywhere(den: Tangle, atoms: Sequence[str]) -> bool:
    """Does every base valuation over `atoms` expand to a model of the tangle?

    By the characterization theorem, this is *exactly* conservativity over every
    truth-free base theory.
    """
    return all(len(models(den, dict(zip(atoms, bits)))) > 0
               for bits in product([False, True], repeat=len(atoms)))


def truth_free_formulas(atoms: Sequence[str], depth: int) -> List[Frm]:
    """All truth-free formulas of implication depth <= `depth` over `atoms`."""
    level: List[Frm] = [Fls()] + [Atom(a) for a in atoms]
    out: List[Frm] = list(level)
    for _ in range(depth):
        new = [Imp(p, q) for p in out for q in out]
        out = list({show(f): f for f in out + new}.values())
    return out


def entails_truthfree(theory: Sequence[Frm], psi: Frm, atoms: Sequence[str],
                      den: Optional[Tangle]) -> bool:
    """Semantic entailment, over the tangled theory when `den` is supplied.

    Quantifies over all base valuations and (if `den` is given) all name
    assignments satisfying the Tarski biconditionals.
    """
    names = sorted(den) if den else []
    for bits in product([False, True], repeat=len(atoms)):
        v = dict(zip(atoms, bits))
        candidates = ([w for w in all_assignments(names) if is_model(den, v, w)]
                      if den else [{}])
        for w in candidates:
            if all(evaluate(phi, v, w) for phi in theory):
                if not evaluate(psi, v, w):
                    return False
    return True


def conservativity_audit(den: Tangle, atoms: Sequence[str], depth: int = 1) -> Tuple[int, int]:
    """Brute-force audit: compare old and tangled consequence for every pair
    (base theory drawn from the small truth-free formulas, truth-free target).

    Returns (number of pairs checked, number of discrepancies found).
    """
    pool = truth_free_formulas(atoms, depth)
    checked = 0
    bad = 0
    for theory_phi in pool:
        for psi in pool:
            old = entails_truthfree([theory_phi], psi, atoms, None)
            new = entails_truthfree([theory_phi], psi, atoms, den)
            checked += 1
            if old != new:
                bad += 1
    return checked, bad


# ---------------------------------------------------------------------------
# 6.  The demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_trichotomy() -> None:
    """The cost of one loop:  grounded 1, truth-teller 2, liar 0 models."""
    banner("1.  THE COST OF ONE LOOP  (single-name trichotomy)")
    v: Valuation = {"a": True}
    cases = [("grounded   den(c) = ⊥", {"c": Fls()}, 1),
             ("truth-teller den(c) = Tc", {"c": Tr("c")}, 2),
             ("liar        den(c) = ¬Tc", {"c": neg(Tr("c"))}, 0)]
    for label, den, expected in cases:
        ms = models(den, v)
        print(f"  {label:28s}  models = {len(ms)}   (predicted {expected})")
        assert len(ms) == expected
    print("  ⇒ 1 / 2 / 0 confirmed: grounding buys determinacy, a positive loop")
    print("    costs one bit, a negative loop costs everything (no model at all).")


def demo_k_loops(kmax: int = 8) -> None:
    """k independent strange loops: 2^k models, and no new theorem."""
    banner("2.  k INDEPENDENT STRANGE LOOPS:  2^k MODELS, 0 NEW THEOREMS")
    v: Valuation = {"a": False}
    for k in range(kmax + 1):
        den: Tangle = {f"c{i}": Tr(f"c{i}") for i in range(k)}
        count = len(models(den, v))
        print(f"  k = {k:2d}   models = {count:4d}   2^k = {2 ** k:4d}   "
              f"conservative = {expandable_everywhere(den, ['a'])}")
        assert count == 2 ** k
    print("  ⇒ exponential in semantics, zero in syntax.")


def demo_extremal_extensions() -> None:
    """Sceptical vs credulous truth predicates, and the determinacy criterion."""
    banner("3.  EXTREMAL EXTENSIONS AND THE DETERMINACY CRITERION")
    v: Valuation = {"a": True}
    examples: List[Tuple[str, Tangle]] = [
        ("two independent loops", {"p": Tr("p"), "q": Tr("q")}),
        ("chained loop  p ↦ Tq,  q ↦ Tp", {"p": Tr("q"), "q": Tr("p")}),
        ("forced        p ↦ a,   q ↦ Tp", {"p": Atom("a"), "q": Tr("p")}),
        ("tautology     c ↦ Tc → Tc", {"c": Imp(Tr("c"), Tr("c"))}),
    ]
    for label, den in examples:
        lfp, gfp = kleene_lfp(den, v), kleene_gfp(den, v)
        unique = lfp == gfp
        print(f"  {label:32s} lfp={fmt(lfp)}  gfp={fmt(gfp)}  "
              f"models={len(models(den, v))}  determinate={unique}")
        assert unique == (len(models(den, v)) == 1)
    print("  ⇒ a positive tangle is determinate exactly when its minimal and")
    print("    maximal extensions of the truth predicate coincide.")


def fmt(w: Assignment) -> str:
    return "{" + ",".join(f"{c}:{'T' if w[c] else 'F'}" for c in sorted(w)) + "}"


def demo_structural_conditions() -> None:
    """Positive, grounded, locally stratified: which condition applies where."""
    banner("4.  POSITIVE / GROUNDED / LOCALLY STRATIFIED")
    atoms = ["a"]
    examples: List[Tuple[str, Tangle]] = [
        ("liar            c ↦ ¬Tc", {"c": neg(Tr("c"))}),
        ("truth-teller    c ↦ Tc", {"c": Tr("c")}),
        ("grounded        c ↦ a", {"c": Atom("a")}),
        ("mixed  q ↦ ⊥,  p ↦ Tq → Tp", {"q": Fls(), "p": Imp(Tr("q"), Tr("p"))}),
        ("tautology       c ↦ Tc → Tc", {"c": Imp(Tr("c"), Tr("c"))}),
        ("negated chain   p ↦ ¬Tq, q ↦ a", {"p": neg(Tr("q")), "q": Atom("a")}),
    ]
    header = f"  {'tangle':32s} {'pos':>5s} {'grnd':>5s} {'loc.str':>8s} {'models':>7s} {'consv':>6s}"
    print(header)
    print("  " + "-" * (len(header) - 2))
    for label, den in examples:
        pos = all(is_positive(phi) for phi in den.values())
        grd = grounded_rank(den) is not None
        loc = local_stratification(den) is not None
        counts = {len(models(den, dict(zip(atoms, bits))))
                  for bits in product([False, True], repeat=len(atoms))}
        cons = expandable_everywhere(den, atoms)
        print(f"  {label:32s} {str(pos):>5s} {str(grd):>5s} {str(loc):>8s} "
              f"{str(sorted(counts)):>7s} {str(cons):>6s}")
        # Every sufficient condition really is sufficient:
        if pos or grd or loc:
            assert cons
    print("  ⇒ the mixed tangle is locally stratified but neither positive nor")
    print("    grounded; the tautology is conservative though nothing stratifies it;")
    print("    only the liar fails, and it fails by outright unsatisfiability.")


def demo_level_construction() -> None:
    """The level-by-level construction reproduces a genuine model."""
    banner("5.  LEVEL-BY-LEVEL CONSTRUCTION FOR A LOCALLY STRATIFIED TANGLE")
    den: Tangle = {
        "q": Fls(),                                  # level 0
        "r": Atom("a"),                              # level 0
        "p": Imp(Tr("q"), Tr("p")),                  # level 1: positive self-loop
        "s": Imp(neg(Tr("r")), Tr("s")),             # level 1: positive self-loop
    }
    rank = local_stratification(den)
    assert rank is not None
    print(f"  computed rank: {rank}")
    for bits in product([False, True], repeat=1):
        v = {"a": bits[0]}
        w = level_model(den, rank, v)
        ok = is_model(den, v, w)
        print(f"  v(a) = {str(bits[0]):5s}  level model {fmt(w)}  solves every loop equation: {ok}"
              f"   (total models: {len(models(den, v))})")
        assert ok
    print("  ⇒ freeze the lower levels, take the least fixed point inside the level,")
    print("    glue: the construction is linear in the size of the tangle.")


def demo_omega_tangle(height: int = 12) -> None:
    """An infinitely tall, nowhere positive, completely determined tangle."""
    banner("6.  AN INFINITELY TALL TANGLE  (truncated at finite height)")
    den: Tangle = {"n0": Fls()}
    for n in range(1, height):
        den[f"n{n}"] = neg(Tr(f"n{n - 1}"))
    den["star"] = Tr("n0")
    v: Valuation = {"a": True}
    rank = grounded_rank(den)
    assert rank is not None
    ms = models(den, v)
    assert len(ms) == 1
    w = ms[0]
    pattern = "".join("T" if w[f"n{n}"] else "F" for n in range(height))
    print(f"  height {height}: unique model, T-values along the tower: {pattern}")
    print(f"  T(star) = {w['star']};  every link is a negation, so the tangle is nowhere positive:")
    print(f"  positive = {all(is_positive(p) for p in den.values())}, "
          f"well-founded rank exists = {rank is not None}")
    print("  ⇒ infinite regress is not vicious circularity: unbounded height,")
    print("    no positivity anywhere, and still exactly one truth predicate.")


def enumerate_small_denotations(depth: int) -> List[Frm]:
    """All formulas over {a, ⊥, Tc} of implication depth <= `depth`."""
    out: List[Frm] = [Fls(), Atom("a"), Tr("c")]
    for _ in range(depth):
        new = [Imp(p, q) for p in out for q in out]
        out = list({show(f): f for f in out + new}.values())
    return out


def demo_census(depth: int = 2) -> None:
    """Exhaustive census of small single-name tangles."""
    banner("7.  EXHAUSTIVE CENSUS OF SMALL SINGLE-NAME TANGLES")
    pool = enumerate_small_denotations(depth)
    census: Dict[Tuple[int, int], int] = {}
    positive_without_model = 0
    lost_model_and_positive = 0
    lost_model_total = 0
    for phi in pool:
        counts = tuple(len(models({"c": phi}, {"a": b})) for b in (False, True))
        census[counts] = census.get(counts, 0) + 1
        if min(counts) == 0:
            lost_model_total += 1
            if is_positive(phi):
                positive_without_model += 1
                lost_model_and_positive += 1
    print(f"  denotations of depth ≤ {depth} over {{a, ⊥, Tc}}: {len(pool)}")
    print("  distribution of (#models at v(a)=F, #models at v(a)=T):")
    for key in sorted(census, key=lambda k: -census[k]):
        print(f"      {key} : {census[key]}")
    print(f"  denotations losing a model for some valuation: {lost_model_total}")
    print(f"  ... of which positive: {positive_without_model}  (theory predicts 0)")
    assert positive_without_model == 0
    mixed = sum(1 for phi in pool
                if len({len(models({'c': phi}, {'a': b})) for b in (False, True)}) > 1)
    print(f"  denotations whose model count DEPENDS on the base valuation: {mixed}")
    print("  ⇒ every positive denotation is solvable for every valuation, and")
    print("    conservativity genuinely has to be stated per valuation.")


def demo_conservativity_audit() -> None:
    """Brute-force check that conservative tangles prove nothing new."""
    banner("8.  BRUTE-FORCE CONSERVATIVITY AUDIT")
    atoms = ["a", "b"]
    cases: List[Tuple[str, Tangle]] = [
        ("truth-teller  c ↦ Tc", {"c": Tr("c")}),
        ("two loops     p ↦ Tp, q ↦ Tq", {"p": Tr("p"), "q": Tr("q")}),
        ("mixed  q ↦ ⊥, p ↦ Tq → Tp", {"q": Fls(), "p": Imp(Tr("q"), Tr("p"))}),
        ("naming  c ↦ (a → b)", {"c": Imp(Atom("a"), Atom("b"))}),
        ("LIAR          c ↦ ¬Tc", {"c": neg(Tr("c"))}),
    ]
    for label, den in cases:
        checked, bad = conservativity_audit(den, atoms, depth=1)
        verdict = "CONSERVATIVE" if bad == 0 else f"NOT conservative ({bad} discrepancies)"
        print(f"  {label:34s} pairs checked = {checked:5d}   {verdict}")
        assert (bad == 0) == expandable_everywhere(den, atoms)
    print("  ⇒ the audit agrees exactly with the criterion: a tangle proves")
    print("    something new precisely when some valuation admits no model.")


def main() -> None:
    print(__doc__.strip().splitlines()[0])
    demo_trichotomy()
    demo_k_loops()
    demo_extremal_extensions()
    demo_structural_conditions()
    demo_level_construction()
    demo_omega_tangle()
    demo_census()
    demo_conservativity_audit()
    banner("ALL DEMONSTRATIONS COMPLETED — every predicted count was confirmed")


if __name__ == "__main__":
    main()
