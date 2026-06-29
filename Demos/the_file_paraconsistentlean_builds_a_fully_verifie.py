"""demo.py — Numerical demonstrations for the Logic of Paradox (LP) and its
minimally-inconsistent strengthening (LPm), plus the tropical / min-plus
semiring bridge.

Everything here is self-contained: the three truth values, the connectives,
formula evaluation, the two consequence relations (classical-style `entails`
and minimal-glut `entails_min`), and the idempotent-semiring algebra are all
implemented inline.  Running the file prints a guided tour that reproduces the
machine-verified results:

  * contradictions are satisfiable but do not explode,
  * excluded middle and non-contradiction survive as *laws*,
  * material modus ponens fails,
  * glut-free valuations reason classically,
  * minimal-glut consequence is genuinely NON-MONOTONE (retraction), and
  * (LP, disj, conj) is a commutative idempotent ("tropical") semiring with a
    prime designated filter {bb, tt}.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import IntEnum
from itertools import product
from typing import Callable, Dict, FrozenSet, List, Set, Tuple


# ---------------------------------------------------------------------------
# 1. The three truth values, ordered as the chain  ff < bb < tt.
# ---------------------------------------------------------------------------
class LP(IntEnum):
    """Priest's three truth values.

    ff = false only, bb = both true and false (a "glut"), tt = true only.
    The integer order encodes the chain ff < bb < tt, so that disjunction is
    `max` and conjunction is `min`.
    """

    ff = 0
    bb = 1
    tt = 2

    def __repr__(self) -> str:  # pragma: no cover - cosmetic
        return self.name


def desig(x: LP) -> bool:
    """A value is *designated* (assertible) iff it is not `ff`."""
    return x != LP.ff


def neg(x: LP) -> LP:
    """LP negation. It fixes the glut bb: an impossible object stays impossible."""
    return {LP.ff: LP.tt, LP.bb: LP.bb, LP.tt: LP.ff}[x]


def conj(x: LP, y: LP) -> LP:
    """LP conjunction = min on the chain ff < bb < tt."""
    return LP(min(int(x), int(y)))


def disj(x: LP, y: LP) -> LP:
    """LP disjunction = max on the chain ff < bb < tt."""
    return LP(max(int(x), int(y)))


# ---------------------------------------------------------------------------
# 2. Formula syntax and three-valued evaluation.
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class Form:
    """A propositional formula over natural-number-indexed atoms.

    `kind` is one of "atom", "neg", "conj", "disj"; `n` indexes the atom for
    atoms; `a`, `b` are subformulas for the connectives.
    """

    kind: str
    n: int = -1
    a: "Form | None" = None
    b: "Form | None" = None


def atom(n: int) -> Form:
    return Form("atom", n=n)


def fneg(p: Form) -> Form:
    return Form("neg", a=p)


def fconj(p: Form, q: Form) -> Form:
    return Form("conj", a=p, b=q)


def fdisj(p: Form, q: Form) -> Form:
    return Form("disj", a=p, b=q)


def fimpl(p: Form, q: Form) -> Form:
    """Material implication p -> q := (not p) or q."""
    return fdisj(fneg(p), q)


Valuation = Dict[int, LP]


def eval_form(v: Valuation, f: Form) -> LP:
    """Three-valued evaluation of a formula under a valuation of atoms.

    Atoms not present in `v` default to `ff`.
    """
    if f.kind == "atom":
        return v.get(f.n, LP.ff)
    if f.kind == "neg":
        return neg(eval_form(v, f.a))
    if f.kind == "conj":
        return conj(eval_form(v, f.a), eval_form(v, f.b))
    if f.kind == "disj":
        return disj(eval_form(v, f.a), eval_form(v, f.b))
    raise ValueError(f"unknown formula kind: {f.kind}")


# ---------------------------------------------------------------------------
# 3. Models and consequence relations over a finite set of atoms.
# ---------------------------------------------------------------------------
def atoms_of(f: Form) -> Set[int]:
    """The set of atom indices occurring in a formula."""
    if f.kind == "atom":
        return {f.n}
    if f.kind == "neg":
        return atoms_of(f.a)
    return atoms_of(f.a) | atoms_of(f.b)


def all_atoms(forms: List[Form]) -> List[int]:
    s: Set[int] = set()
    for f in forms:
        s |= atoms_of(f)
    return sorted(s)


def enumerate_valuations(atom_ids: List[int]) -> List[Valuation]:
    """All 3^k valuations over the given atoms."""
    out: List[Valuation] = []
    for combo in product(LP, repeat=len(atom_ids)):
        out.append({a: val for a, val in zip(atom_ids, combo)})
    return out


def is_model(gamma: List[Form], v: Valuation) -> bool:
    """v is a model of gamma iff it designates every premise."""
    return all(desig(eval_form(v, b)) for b in gamma)


def entails(gamma: List[Form], a: Form) -> bool:
    """Classical-style LP consequence: A holds in every model of gamma."""
    ids = all_atoms(gamma + [a])
    return all(
        desig(eval_form(v, a)) for v in enumerate_valuations(ids) if is_model(gamma, v)
    )


def gluts(v: Valuation, ids: List[int]) -> FrozenSet[int]:
    """The set of atoms assigned the glut value bb under v."""
    return frozenset(n for n in ids if v.get(n, LP.ff) == LP.bb)


def minimal_models(gamma: List[Form], extra: List[Form]) -> List[Valuation]:
    """The glut-minimal models of gamma (atoms drawn from gamma and `extra`).

    A model is minimal if no other model has a strictly smaller glut set.
    """
    ids = all_atoms(gamma + extra)
    models = [v for v in enumerate_valuations(ids) if is_model(gamma, v)]
    glut_sets = [gluts(v, ids) for v in models]
    out: List[Valuation] = []
    for v, gv in zip(models, glut_sets):
        if not any(gw < gv for gw in glut_sets):  # no strictly smaller glut set
            out.append(v)
    return out


def entails_min(gamma: List[Form], a: Form) -> bool:
    """LPm consequence: A holds in every glut-MINIMAL model of gamma."""
    return all(desig(eval_form(v, a)) for v in minimal_models(gamma, [a]))


# ---------------------------------------------------------------------------
# 4. The guided tour.
# ---------------------------------------------------------------------------
def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def show_truth_tables() -> None:
    banner("Truth tables: neg, conj=min, disj=max, and designation")
    print("x   | neg x | desig x")
    for x in LP:
        print(f"{x.name:3} |  {neg(x).name:3}  | {desig(x)}")
    print("\nconj (= min):")
    print("      " + "  ".join(y.name for y in LP))
    for x in LP:
        print(f"  {x.name}  " + "  ".join(conj(x, y).name for y in LP))
    print("\ndisj (= max):")
    print("      " + "  ".join(y.name for y in LP))
    for x in LP:
        print(f"  {x.name}  " + "  ".join(disj(x, y).name for y in LP))


def show_core_phenomena() -> None:
    banner("Core LP phenomena")
    p, q = atom(0), atom(1)

    # Excluded middle and non-contradiction are LAWS (designated everywhere).
    lem_ok = all(desig(eval_form(v, fdisj(p, fneg(p)))) for v in enumerate_valuations([0]))
    lnc_ok = all(
        desig(eval_form(v, fneg(fconj(p, fneg(p))))) for v in enumerate_valuations([0])
    )
    print(f"Law of excluded middle  p v ~p   valid?  {lem_ok}")
    print(f"Law of non-contradiction ~(p&~p) valid?  {lnc_ok}")

    # Contradiction satisfiable: at the glut, p & ~p is designated (= bb).
    vglut = {0: LP.bb}
    contradiction_val = eval_form(vglut, fconj(p, fneg(p)))
    print(
        f"Contradiction p&~p at glut valuation = {contradiction_val.name} "
        f"(designated? {desig(contradiction_val)})  -> satisfiable"
    )

    # Explosion FAILS:  p, ~p  do NOT entail an unrelated q.
    print(f"Explosion  p, ~p |= q   holds?  {entails([p, fneg(p)], q)}  (paraconsistent!)")

    # Material modus ponens FAILS.
    vmp = {0: LP.bb, 1: LP.ff}
    mp_premises_ok = desig(eval_form(vmp, p)) and desig(eval_form(vmp, fimpl(p, q)))
    mp_concl = desig(eval_form(vmp, q))
    print(
        f"Modus ponens counterexample (p=bb,q=ff): premises designated? "
        f"{mp_premises_ok}, conclusion q designated? {mp_concl}"
    )


def show_classical_collapse() -> None:
    banner("Glut-free valuations reason classically")
    p = atom(0)
    classical = True
    for x in (LP.ff, LP.tt):  # glut-free values only
        v = {0: x}
        if desig(eval_form(v, p)) and desig(eval_form(v, fneg(p))):
            classical = False
    print(f"No glut-free valuation makes both A and ~A designated:  {classical}")


def show_nonmonotonicity() -> None:
    banner("LPm is NON-MONOTONE: adding ~p retracts the conclusion q")
    p, q = atom(0), atom(1)
    base = [p, fimpl(p, q)]
    expanded = [p, fimpl(p, q), fneg(p)]

    q_from_base = entails_min(base, q)
    q_from_expanded = entails_min(expanded, q)

    print("Premises  {p, p->q}:")
    print(f"   minimal models -> q designated everywhere?  {q_from_base}")
    print("Premises  {p, p->q, ~p}:")
    print(f"   minimal models -> q designated everywhere?  {q_from_expanded}")
    print(
        f"\nMonotonicity would require the second to stay True. "
        f"It is {q_from_expanded} -> q is RETRACTED."
    )

    # Show the offending minimal model explicitly.
    ids = all_atoms(expanded + [q])
    for v in minimal_models(expanded, [q]):
        vals = {n: v[n].name for n in ids}
        print(f"   minimal model {vals}: q = {eval_form(v, q).name}")


def show_semiring_bridge() -> None:
    banner("Tropical bridge: (LP, disj=max, conj=min) is an idempotent semiring")
    # Identities.
    add_id = all(disj(LP.ff, x) == x for x in LP)
    mul_id = all(conj(LP.tt, x) == x for x in LP)
    add_idem = all(disj(x, x) == x for x in LP)
    mul_idem = all(conj(x, x) == x for x in LP)
    distrib = all(
        conj(x, disj(y, z)) == disj(conj(x, y), conj(x, z))
        for x in LP
        for y in LP
        for z in LP
    )
    print(f"additive identity ff (disj ff x = x):   {add_id}")
    print(f"multiplicative identity tt (conj tt x = x): {mul_id}")
    print(f"additive idempotence (disj x x = x):    {add_idem}")
    print(f"multiplicative idempotence (conj x x = x): {mul_idem}")
    print(f"distributivity conj over disj:          {distrib}")

    # Prime designated filter {bb, tt}.
    filt_mul = all(desig(conj(x, y)) == (desig(x) and desig(y)) for x in LP for y in LP)
    filt_add = all(desig(disj(x, y)) == (desig(x) or desig(y)) for x in LP for y in LP)
    print(f"designated filter is multiplicative (desig(x*y) <-> desig x & desig y): {filt_mul}")
    print(f"designated filter is prime         (desig(x+y) <-> desig x | desig y): {filt_add}")


def main() -> None:
    show_truth_tables()
    show_core_phenomena()
    show_classical_collapse()
    show_nonmonotonicity()
    show_semiring_bridge()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
