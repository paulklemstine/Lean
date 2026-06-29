"""
Dream Logic II: Structural Meta-Theory of Paraconsistent Consequence
====================================================================

Self-contained numerical demonstration of Priest's Logic of Paradox (LP) and its
non-monotone minimal-glut refinement (LPm).

Truth values form the chain   ff < bb < tt   where `bb` ("both") is the glut.
Designated (accepted) values:  {bb, tt}.
Connectives:  neg fixes bb;  conj = min;  disj = max  in the order ff < bb < tt.

This file reproduces, by brute-force finite enumeration, every headline result of
the formal development:

    desig_conj / desig_disj_left   (value-level engines)
    entails_refl / entails_monotone / entails_cut   (Tarskian closure operator)
    entails_and_intro / entails_or_intro_left        (surviving introductions)
    disjunctive_syllogism_fails / mp_fails           (dying eliminations)
    entailsMin_recovers_mp / retraction_nonmonotone  (dream-logic recapture)
    LPvalid_imp_classicallyValid / lp_validity_eq_classical  (Priest's theorem)

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, FrozenSet, Iterable, List, Optional, Set, Tuple

# --------------------------------------------------------------------------- #
# Truth values: encode the chain ff < bb < tt as integers 0 < 1 < 2.          #
# --------------------------------------------------------------------------- #

FF: int = 0  # false
BB: int = 1  # both (the glut) -- fixed point of negation
TT: int = 2  # true

VALUES: Tuple[int, int, int] = (FF, BB, TT)
NAME: Dict[int, str] = {FF: "ff", BB: "bb", TT: "tt"}


def desig(a: int) -> bool:
    """A value is designated (accepted) iff it is at least bb."""
    return a >= BB


def neg(a: int) -> int:
    """Negation: flips ff<->tt, fixes the glut bb (neg bb = bb)."""
    if a == BB:
        return BB
    return TT if a == FF else FF


def conj(a: int, b: int) -> int:
    """Conjunction is the order meet (minimum)."""
    return min(a, b)


def disj(a: int, b: int) -> int:
    """Disjunction is the order join (maximum)."""
    return max(a, b)


# --------------------------------------------------------------------------- #
# Formulas as a small algebraic data type.                                    #
# --------------------------------------------------------------------------- #

@dataclass(frozen=True)
class Form:
    """Propositional formula over natural-number atoms.

    kind in {"atom", "neg", "conj", "disj"}.
    For "atom":  idx is the atom index.
    For "neg":   left is the operand.
    For "conj"/"disj": left and right are the operands.
    """
    kind: str
    idx: Optional[int] = None
    left: Optional["Form"] = None
    right: Optional["Form"] = None


def atom(n: int) -> Form:
    return Form("atom", idx=n)


def Neg(a: Form) -> Form:
    return Form("neg", left=a)


def Conj(a: Form, b: Form) -> Form:
    return Form("conj", left=a, right=b)


def Disj(a: Form, b: Form) -> Form:
    return Form("disj", left=a, right=b)


def Imp(a: Form, b: Form) -> Form:
    """Material conditional p -> q  :=  (neg p) disj q."""
    return Disj(Neg(a), b)


Valuation = Dict[int, int]


def eval_form(v: Valuation, a: Form) -> int:
    """Evaluate a formula under a valuation (atoms default to ff if unbound)."""
    if a.kind == "atom":
        return v.get(a.idx, FF)            # type: ignore[arg-type]
    if a.kind == "neg":
        return neg(eval_form(v, a.left))   # type: ignore[arg-type]
    if a.kind == "conj":
        return conj(eval_form(v, a.left), eval_form(v, a.right))  # type: ignore[arg-type]
    if a.kind == "disj":
        return disj(eval_form(v, a.left), eval_form(v, a.right))  # type: ignore[arg-type]
    raise ValueError(f"unknown kind {a.kind}")


def holds(v: Valuation, a: Form) -> bool:
    """A formula holds iff its value is designated."""
    return desig(eval_form(v, a))


def show(a: Form) -> str:
    """Pretty-print a formula."""
    if a.kind == "atom":
        return f"p{a.idx}"
    if a.kind == "neg":
        return f"¬{show(a.left)}"
    if a.kind == "conj":
        return f"({show(a.left)} ∧ {show(a.right)})"
    if a.kind == "disj":
        return f"({show(a.left)} ∨ {show(a.right)})"
    raise ValueError


# --------------------------------------------------------------------------- #
# Atom collection and valuation enumeration.                                  #
# --------------------------------------------------------------------------- #

def atoms_of(a: Form) -> Set[int]:
    if a.kind == "atom":
        return {a.idx}                     # type: ignore[arg-type]
    if a.kind == "neg":
        return atoms_of(a.left)            # type: ignore[arg-type]
    return atoms_of(a.left) | atoms_of(a.right)  # type: ignore[arg-type]


def atoms_of_theory(gamma: Iterable[Form], extra: Iterable[Form] = ()) -> List[int]:
    s: Set[int] = set()
    for f in gamma:
        s |= atoms_of(f)
    for f in extra:
        s |= atoms_of(f)
    return sorted(s)


def all_valuations(atoms: List[int]) -> Iterable[Valuation]:
    for assignment in product(VALUES, repeat=len(atoms)):
        yield dict(zip(atoms, assignment))


# --------------------------------------------------------------------------- #
# Consequence relations.                                                       #
# --------------------------------------------------------------------------- #

def models(gamma: List[Form], v: Valuation) -> bool:
    return all(holds(v, b) for b in gamma)


def entails(gamma: List[Form], a: Form) -> Tuple[bool, Optional[Valuation]]:
    """LP-consequence. Returns (valid, countermodel-if-any)."""
    atoms = atoms_of_theory(gamma, [a])
    for v in all_valuations(atoms):
        if models(gamma, v) and not holds(v, a):
            return False, v
    return True, None


def glut_set(v: Valuation) -> FrozenSet[int]:
    return frozenset(n for n, val in v.items() if val == BB)


def entails_min(gamma: List[Form], a: Form) -> Tuple[bool, Optional[Valuation]]:
    """LPm-consequence: check A on minimal-glut models only."""
    atoms = atoms_of_theory(gamma, [a])
    mods = [v for v in all_valuations(atoms) if models(gamma, v)]
    minimal = [
        v for v in mods
        if not any(glut_set(w) < glut_set(v) for w in mods)
    ]
    for v in minimal:
        if not holds(v, a):
            return False, v
    return True, None


# --------------------------------------------------------------------------- #
# Validity.                                                                     #
# --------------------------------------------------------------------------- #

def lp_valid(a: Form) -> Tuple[bool, Optional[Valuation]]:
    atoms = sorted(atoms_of(a))
    for v in all_valuations(atoms):
        if not holds(v, a):
            return False, v
    return True, None


def classically_valid(a: Form) -> Tuple[bool, Optional[Valuation]]:
    atoms = sorted(atoms_of(a))
    for assignment in product((FF, TT), repeat=len(atoms)):  # classical: no bb
        v = dict(zip(atoms, assignment))
        if not holds(v, a):
            return False, v
    return True, None


def collapse_plus(v: Valuation) -> Valuation:
    """The classical collapse v+ : bb |-> tt, fixing ff and tt."""
    return {n: (TT if val in (BB, TT) else FF) for n, val in v.items()}


# --------------------------------------------------------------------------- #
# Demonstrations.                                                              #
# --------------------------------------------------------------------------- #

def fmt_val(v: Valuation) -> str:
    return "{" + ", ".join(f"p{n}={NAME[val]}" for n, val in sorted(v.items())) + "}"


def demo_value_engines() -> None:
    print("=" * 70)
    print("VALUE-LEVEL ENGINES: designation closed under min and max")
    print("=" * 70)
    ok_conj = all(desig(conj(a, b)) for a in VALUES for b in VALUES
                  if desig(a) and desig(b))
    ok_disj = all(desig(disj(a, b)) for a in VALUES for b in VALUES if desig(a))
    print(f"desig_conj      : two designated values -> conj designated : {ok_conj}")
    print(f"desig_disj_left : left designated        -> disj designated : {ok_disj}")
    # Show neg fixes the glut -- the source of paraconsistency.
    print(f"negation fixes the glut: neg(bb) = {NAME[neg(BB)]}  (== bb)")
    print()


def demo_structural_rules() -> None:
    print("=" * 70)
    print("STRUCTURAL RULES: entails is a Tarskian closure operator")
    print("=" * 70)
    p, q, r = atom(0), atom(1), atom(2)

    # Reflexivity
    refl, _ = entails([p, q], p)
    print(f"entails_refl      : {{p,q}} ⊢ p                          : {refl}")

    # Monotonicity: {p} ⊢ p∨q  ==>  {p,r} ⊢ p∨q
    base, _ = entails([p], Disj(p, q))
    mono, _ = entails([p, r], Disj(p, q))
    print(f"entails_monotone  : {{p}} ⊢ p∨q  then  {{p,r}} ⊢ p∨q       : {base and mono}")

    # Cut: {p} ⊢ p∧p style chain. Use A = p∧q derivable, then conclude.
    # Demonstrate Cut schematically: Γ⊢A and Γ,A⊢B  =>  Γ⊢B.
    gamma = [p, q]
    A = Conj(p, q)
    cut_premise1, _ = entails(gamma, A)            # Γ ⊢ A
    cut_premise2, _ = entails(gamma + [A], Disj(A, r))  # Γ,A ⊢ B
    cut_concl, _ = entails(gamma, Disj(A, r))      # Γ ⊢ B
    cut_ok = (not cut_premise1) or (not cut_premise2) or cut_concl
    print(f"entails_cut       : Γ⊢A & Γ,A⊢B  ⟹  Γ⊢B                 : {cut_ok}")
    print()


def demo_introductions() -> None:
    print("=" * 70)
    print("SURVIVING CONNECTIVE RULES: the introductions")
    print("=" * 70)
    p, q = atom(0), atom(1)
    and_intro, _ = entails([p, q], Conj(p, q))
    or_intro, _ = entails([p], Disj(p, q))
    print(f"entails_and_intro     : {{p,q}} ⊢ p∧q : {and_intro}")
    print(f"entails_or_intro_left : {{p}}   ⊢ p∨q : {or_intro}")
    print()


def demo_elimination_fails() -> None:
    print("=" * 70)
    print("DYING CONNECTIVE RULE: disjunctive syllogism / modus ponens FAIL")
    print("=" * 70)
    p, q = atom(0), atom(1)

    ds_valid, cm_ds = entails([p, Disj(Neg(p), q)], q)
    print(f"disjunctive_syllogism_fails : {{p, ¬p∨q}} ⊢ q  is  {ds_valid}")
    if cm_ds is not None:
        print(f"    countermodel: {fmt_val(cm_ds)}")
        print(f"      eval(p)      = {NAME[eval_form(cm_ds, p)]}  (designated)")
        print(f"      eval(¬p∨q)   = {NAME[eval_form(cm_ds, Disj(Neg(p), q))]}  (designated)")
        print(f"      eval(q)      = {NAME[eval_form(cm_ds, q)]}  (NOT designated)")

    mp_valid, cm_mp = entails([p, Imp(p, q)], q)
    print(f"mp_fails                    : {{p, p⊃q}} ⊢ q  is  {mp_valid}")
    if cm_mp is not None:
        print(f"    countermodel: {fmt_val(cm_mp)}")
    print()


def demo_recapture() -> None:
    print("=" * 70)
    print("DREAM LOGIC: LPm recovers modus ponens on consistent premises")
    print("=" * 70)
    p, q = atom(0), atom(1)

    # On consistent {p, p⊃q}, LP loses q but LPm recovers it.
    lp_mp, _ = entails([p, Imp(p, q)], q)
    lpm_mp, _ = entails_min([p, Imp(p, q)], q)
    print(f"LP  : {{p, p⊃q}} ⊢ q       : {lp_mp}   (lost)")
    print(f"LPm : {{p, p⊃q}} ⊢_min q   : {lpm_mp}   (entailsMin_recovers_mp)")

    # Non-monotonicity of LPm: adding a forcing premise can retract a conclusion,
    # because the new premise forces a glut that the previous minimal models avoided.
    print()
    print("Non-monotonicity check (retraction_nonmonotone):")
    found = _search_nonmonotone()
    if found is not None:
        (G, D, A), gm, dm = found
        print(f"    Γ = {{{', '.join(show(f) for f in G)}}}")
        print(f"    Δ = {{{', '.join(show(f) for f in D)}}}  (⊇ Γ)")
        print(f"    A = {show(A)}")
        print(f"    Γ ⊢_min A : {gm}    Δ ⊢_min A : {dm}   -> monotonicity FAILS")
    print()


def _search_nonmonotone() -> Optional[
    Tuple[Tuple[List[Form], List[Form], Form], bool, bool]
]:
    """Find Γ ⊆ Δ and A with entails_min(Γ,A) but not entails_min(Δ,A)."""
    p, q = atom(0), atom(1)
    candidate_extra = [Neg(p), Conj(p, Neg(p))]
    candidate_concl = [q, Neg(p), Disj(p, q), Imp(p, q)]
    bases = [
        [p, Disj(Neg(p), q)],   # canonical: {p, ¬p∨q} ⊢_min q
        [p, Imp(p, q)],         # {p, p⊃q} ⊢_min q
        [Disj(p, q)],
        [p],
        [Disj(Neg(p), q)],
    ]
    for G in bases:
        for ex in candidate_extra:
            D = G + [ex]
            for A in candidate_concl:
                gm, _ = entails_min(G, A)
                dm, _ = entails_min(D, A)
                if gm and not dm:
                    return (G, D, A), gm, dm
    return None


def demo_priest_validity() -> None:
    print("=" * 70)
    print("PRIEST'S CHARACTERIZATION: LP-valid  <=>  classically valid")
    print("=" * 70)
    p, q = atom(0), atom(1)
    samples: List[Tuple[str, Form]] = [
        ("LEM     p ∨ ¬p", Disj(p, Neg(p))),
        ("LNC     ¬(p ∧ ¬p)", Neg(Conj(p, Neg(p)))),
        ("DNE→    ¬¬p ∨ ¬p (taut)", Disj(Neg(Neg(p)), Neg(p))),
        ("Peirce  ((p⊃q)⊃p)⊃p", Imp(Imp(Imp(p, q), p), p)),
        ("non-taut p ⊃ q", Imp(p, q)),
        ("non-taut p", p),
    ]
    print(f"{'formula':28} {'LP-valid':>9} {'classical':>10} {'agree':>7}")
    print("-" * 60)
    for label, f in samples:
        lpv, _ = lp_valid(f)
        clv, _ = classically_valid(f)
        print(f"{label:28} {str(lpv):>9} {str(clv):>10} {str(lpv == clv):>7}")

    # Exhaustively verify the equivalence on all small formulas up to depth 2.
    print()
    print("Exhaustive check LPvalid(A) == ClassicallyValid(A) on generated formulas:")
    forms = list(_generate_forms(max_atom=1, depth=2))
    agree = sum(1 for f in forms if lp_valid(f)[0] == classically_valid(f)[0])
    print(f"    {agree}/{len(forms)} formulas agree   (mismatch count = {len(forms) - agree})")

    # Demonstrate the Collapsing Lemma numerically.
    print()
    print("Collapsing Lemma (collapse_preserve), sample over a glut valuation:")
    v = {0: BB, 1: FF}
    vp = collapse_plus(v)
    test = Disj(Neg(p), Disj(p, q))   # classically valid
    print(f"    v  = {fmt_val(v)} ,  v⁺ = {fmt_val(vp)}")
    print(f"    eval(v⁺, A) = {NAME[eval_form(vp, test)]}  ->  eval(v, A) = "
          f"{NAME[eval_form(v, test)]}  (designated: {holds(v, test)})")
    print()


def _generate_forms(max_atom: int, depth: int) -> Iterable[Form]:
    """Generate all formulas over atoms 0..max_atom up to the given depth."""
    base: List[Form] = [atom(n) for n in range(max_atom + 1)]
    level: List[Form] = list(base)
    seen: Set[str] = {show(f) for f in level}
    for f in level:
        yield f
    for _ in range(depth):
        nxt: List[Form] = []
        for f in level:
            for g in (Neg(f),):
                if show(g) not in seen:
                    seen.add(show(g))
                    nxt.append(g)
        for f in level:
            for h in level:
                for g in (Conj(f, h), Disj(f, h)):
                    if show(g) not in seen:
                        seen.add(show(g))
                        nxt.append(g)
        for f in nxt:
            yield f
        level = nxt


def main() -> None:
    print()
    print("#" * 70)
    print("#  DREAM LOGIC II — Structural Meta-Theory of Paraconsistent Logic   #")
    print("#" * 70)
    print()
    demo_value_engines()
    demo_structural_rules()
    demo_introductions()
    demo_elimination_fails()
    demo_recapture()
    demo_priest_validity()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
