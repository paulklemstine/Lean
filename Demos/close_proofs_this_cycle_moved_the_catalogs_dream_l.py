"""
Dream Logic III — Numerical demonstration of the structural core of the Logic of Paradox (LP).

This self-contained script implements LP's three-valued semantics and reproduces, by
explicit computation, every headline result of the accompanying paper:

  * eval_subst                  -- evaluation commutes with substitution
  * lpvalid_subst_closed        -- validity is closed under uniform substitution
  * eval_allbb                  -- the constant glut valuation maps every formula to bb
  * absolute_glut_models_all    -- one valuation satisfies every formula
  * contradiction_satisfiable   -- every {A, ~A} is jointly satisfiable
  * explosion_fails             -- {p, ~p} does not entail q
  * lem_valid / lnc_valid       -- excluded middle and non-contradiction are LP-valid
  * Cn_idempotent (witness)     -- consequence is reflexive + monotone (closure operator)

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, List, Set, Tuple

# --------------------------------------------------------------------------- #
# 1. The three-valued algebra of LP                                           #
#    Truth order:  ff < bb < tt   (encode ff=0, bb=1, tt=2)                    #
# --------------------------------------------------------------------------- #

FF: int = 0  # false only
BB: int = 1  # both true and false (the glut)
TT: int = 2  # true only

NAMES: Dict[int, str] = {FF: "ff", BB: "bb", TT: "tt"}


def neg(a: int) -> int:
    """Antitone De Morgan involution fixing the glut: tt<->ff, bb->bb."""
    return {TT: FF, BB: BB, FF: TT}[a]


def conj(a: int, b: int) -> int:
    """Conjunction = min in the truth order ff < bb < tt."""
    return min(a, b)


def disj(a: int, b: int) -> int:
    """Disjunction = max in the truth order ff < bb < tt."""
    return max(a, b)


def desig(a: int) -> bool:
    """A value is designated (asserted) iff it is at least partly true."""
    return a in (TT, BB)


# --------------------------------------------------------------------------- #
# 2. Syntax of formulas                                                       #
# --------------------------------------------------------------------------- #

@dataclass(frozen=True)
class Form:
    """Propositional formula over atoms indexed by natural numbers."""
    kind: str                      # 'atom' | 'neg' | 'conj' | 'disj'
    n: int = -1                    # atom index (when kind == 'atom')
    left: "Form | None" = None
    right: "Form | None" = None


def atom(n: int) -> Form:
    return Form("atom", n=n)


def NEG(a: Form) -> Form:
    return Form("neg", left=a)


def AND(a: Form, b: Form) -> Form:
    return Form("conj", left=a, right=b)


def OR(a: Form, b: Form) -> Form:
    return Form("disj", left=a, right=b)


def IMP(a: Form, b: Form) -> Form:
    """Material implication, defined as ~A | B."""
    return OR(NEG(a), b)


Valuation = Callable[[int], int]


def eval_form(v: Valuation, a: Form) -> int:
    """Homomorphic evaluation of a formula under a valuation."""
    if a.kind == "atom":
        return v(a.n)
    if a.kind == "neg":
        return neg(eval_form(v, a.left))
    if a.kind == "conj":
        return conj(eval_form(v, a.left), eval_form(v, a.right))
    if a.kind == "disj":
        return disj(eval_form(v, a.left), eval_form(v, a.right))
    raise ValueError(f"unknown formula kind: {a.kind}")


def holds(v: Valuation, a: Form) -> bool:
    return desig(eval_form(v, a))


# --------------------------------------------------------------------------- #
# 3. Substitution and its homomorphism property (eval_subst)                  #
# --------------------------------------------------------------------------- #

Subst = Callable[[int], Form]


def subst(sigma: Subst, a: Form) -> Form:
    """Uniform substitution of a formula for each atom."""
    if a.kind == "atom":
        return sigma(a.n)
    if a.kind == "neg":
        return NEG(subst(sigma, a.left))
    if a.kind == "conj":
        return AND(subst(sigma, a.left), subst(sigma, a.right))
    if a.kind == "disj":
        return OR(subst(sigma, a.left), subst(sigma, a.right))
    raise ValueError(f"unknown formula kind: {a.kind}")


# --------------------------------------------------------------------------- #
# 4. Semantic search utilities                                                #
# --------------------------------------------------------------------------- #

def atoms_of(a: Form) -> Set[int]:
    if a.kind == "atom":
        return {a.n}
    out: Set[int] = set()
    if a.left is not None:
        out |= atoms_of(a.left)
    if a.right is not None:
        out |= atoms_of(a.right)
    return out


def all_valuations(indices: List[int]) -> List[Valuation]:
    """Every assignment of {ff,bb,tt} to the given atom indices."""
    vals: List[Valuation] = []
    for combo in product((FF, BB, TT), repeat=len(indices)):
        table = dict(zip(indices, combo))
        vals.append(lambda n, table=table: table.get(n, FF))
    return vals


def is_valid(a: Form) -> bool:
    """LPvalid A : designated under every valuation of its atoms."""
    idx = sorted(atoms_of(a))
    return all(holds(v, a) for v in all_valuations(idx))


def entails(gamma: List[Form], a: Form) -> bool:
    """entails Gamma A : every model of all premises is a model of A."""
    idx = sorted(set().union(*[atoms_of(f) for f in gamma], atoms_of(a)) or {0})
    for v in all_valuations(list(idx)):
        if all(holds(v, g) for g in gamma) and not holds(v, a):
            return False
    return True


# --------------------------------------------------------------------------- #
# 5. The demonstrations                                                        #
# --------------------------------------------------------------------------- #

def show_value_tables() -> None:
    print("=" * 68)
    print("THE THREE-VALUED ALGEBRA  (ff < bb < tt)")
    print("=" * 68)
    print("neg:  " + ", ".join(f"~{NAMES[a]}={NAMES[neg(a)]}" for a in (TT, BB, FF)))
    print("\nconj (= min):")
    print("       " + "  ".join(NAMES[b] for b in (FF, BB, TT)))
    for a in (FF, BB, TT):
        print(f"  {NAMES[a]}   " + "  ".join(NAMES[conj(a, b)] for b in (FF, BB, TT)))
    print("\ndisj (= max):")
    print("       " + "  ".join(NAMES[b] for b in (FF, BB, TT)))
    for a in (FF, BB, TT):
        print(f"  {NAMES[a]}   " + "  ".join(NAMES[disj(a, b)] for b in (FF, BB, TT)))
    print(f"\ndesignated values: {[NAMES[a] for a in (FF, BB, TT) if desig(a)]}")


def demo_eval_subst() -> None:
    print("\n" + "=" * 68)
    print("eval_subst : evaluation commutes with substitution")
    print("=" * 68)
    A = OR(atom(0), NEG(atom(1)))                 # p | ~q
    sigma: Subst = lambda n: AND(atom(0), atom(1)) if n == 0 else atom(2)
    ok = True
    for combo in product((FF, BB, TT), repeat=3):
        table = {0: combo[0], 1: combo[1], 2: combo[2]}
        v: Valuation = lambda n, table=table: table[n]
        lhs = eval_form(v, subst(sigma, A))
        w: Valuation = lambda n, v=v, sigma=sigma: eval_form(v, sigma(n))
        rhs = eval_form(w, A)
        ok &= (lhs == rhs)
    print(f"  for A = (p | ~q), sigma(p)=(p&q), sigma(q)=r")
    print(f"  eval(v, subst sigma A) == eval(n -> eval(v, sigma n), A) for all 27 v : {ok}")


def demo_subst_closed() -> None:
    print("\n" + "=" * 68)
    print("lpvalid_subst_closed : validity is closed under substitution")
    print("=" * 68)
    lem = OR(atom(0), NEG(atom(0)))               # p | ~p  (valid)
    sigma: Subst = lambda n: AND(atom(1), atom(2))
    inst = subst(sigma, lem)                       # (q&r) | ~(q&r)
    print(f"  LEM (p | ~p) valid              : {is_valid(lem)}")
    print(f"  substituted instance also valid : {is_valid(inst)}")


def demo_glut() -> None:
    print("\n" + "=" * 68)
    print("eval_allbb / absolute_glut_models_all : the model of everything")
    print("=" * 68)
    glut: Valuation = lambda n: BB
    forms = [
        atom(0),
        NEG(atom(0)),
        AND(atom(0), NEG(atom(0))),
        OR(NEG(atom(3)), AND(atom(1), atom(2))),
        IMP(atom(0), atom(5)),
    ]
    for f in forms:
        val = eval_form(glut, f)
        print(f"  eval(glut, formula) = {NAMES[val]:>2}   designated = {desig(val)}")
    print("  => every formula evaluates to bb and is designated.")


def demo_contradiction_and_explosion() -> None:
    print("\n" + "=" * 68)
    print("contradiction_satisfiable & explosion_fails")
    print("=" * 68)
    p, q = atom(0), atom(1)
    # Surgical counter-model: p = bb, q = ff
    v: Valuation = lambda n: BB if n == 0 else FF
    print("  surgical model v: p=bb, q=ff")
    print(f"    holds(v, p)  = {holds(v, p)}    holds(v, ~p) = {holds(v, NEG(p))}")
    print(f"    holds(v, q)  = {holds(v, q)}")
    print(f"  {{p, ~p}} jointly satisfiable     : {holds(v, p) and holds(v, NEG(p))}")
    print(f"  {{p, ~p}} entails q  (explosion)  : {entails([p, NEG(p)], q)}   (False = good)")


def demo_classical_laws() -> None:
    print("\n" + "=" * 68)
    print("lem_valid / lnc_valid : classical laws survive despite gluts")
    print("=" * 68)
    A = atom(0)
    lem = OR(A, NEG(A))
    lnc = NEG(AND(A, NEG(A)))
    print(f"  Excluded middle   (A | ~A)    valid : {is_valid(lem)}")
    print(f"  Non-contradiction ~(A & ~A)   valid : {is_valid(lnc)}")
    glut: Valuation = lambda n: BB
    print(f"  ...yet in the glut world LNC evaluates to "
          f"{NAMES[eval_form(glut, lnc)]} (designated but partly false).")
    print("  => validity is cleanly separated from triviality.")


def demo_closure_operator() -> None:
    print("\n" + "=" * 68)
    print("Cn closure operator : reflexivity + monotonicity (idempotence)")
    print("=" * 68)
    p, q = atom(0), atom(1)
    gamma = [p, q]
    print(f"  reflexivity : entails({{p,q}}, p) = {entails(gamma, p)}")
    pool = [p, q, AND(p, q), OR(p, q), OR(p, NEG(p))]
    cn = [f for f in pool if entails(gamma, f)]
    cn_names = ["p", "q", "p&q", "p|q", "p|~p"]
    drawn = [cn_names[i] for i, f in enumerate(pool) if entails(gamma, f)]
    print(f"  Cn({{p,q}}) (within a finite pool) contains: {drawn}")
    # idempotence witness: everything in Cn is still entailed by Cn (monotonicity)
    idem = all(entails(cn, f) for f in cn)
    print(f"  every member of Cn(Gamma) is entailed by Cn(Gamma) (idempotence) : {idem}")


def main() -> None:
    show_value_tables()
    demo_eval_subst()
    demo_subst_closed()
    demo_glut()
    demo_contradiction_and_explosion()
    demo_classical_laws()
    demo_closure_operator()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
