"""
demo.py — Numerical / symbolic demonstrations for
"Lambda Calculus: Church–Rosser and Normalization".

This file is fully self-contained. It implements the untyped lambda calculus
with de Bruijn indices exactly as formalized in the accompanying Lean
development, and demonstrates the headline results:

  * single-step beta reduction (`Beta`) and its reflexive-transitive
    closure (`BetaStar`);
  * Tait / Martin-Lof PARALLEL reduction (`Par`), which contracts many
    redexes at once;
  * Takahashi's COMPLETE DEVELOPMENT `cd`, a *function* that contracts every
    redex currently present in a term;
  * the TRIANGLE PROPERTY: if t ==> u (parallel) then u ==> cd(t);
  * the DIAMOND PROPERTY of parallel reduction, and through it the
    CHURCH-ROSSER theorem (confluence) of beta reduction;
  * Böhm-tree approximants, with Omega approximating to bottom at every depth.

Everything is plain Python with type hints; no third-party dependencies.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Optional


# ---------------------------------------------------------------------------
# Syntax: lambda terms with de Bruijn indices
#   Var n          a variable bound by the n-th enclosing lambda (0 = closest)
#   Lam t          an abstraction  (lambda . t)
#   App a b        an application  (a b)
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class Term:
    """Base class for lambda terms."""


@dataclass(frozen=True)
class Var(Term):
    idx: int


@dataclass(frozen=True)
class Lam(Term):
    body: Term


@dataclass(frozen=True)
class App(Term):
    fn: Term
    arg: Term


def show(t: Term) -> str:
    """Pretty-print a de Bruijn term."""
    if isinstance(t, Var):
        return str(t.idx)
    if isinstance(t, Lam):
        return f"(λ {show(t.body)})"
    if isinstance(t, App):
        return f"({show(t.fn)} {show(t.arg)})"
    raise TypeError(f"unknown term: {t!r}")


# ---------------------------------------------------------------------------
# Substitution algebra (mirrors Syntax.lean: lift, subst, subst0)
# ---------------------------------------------------------------------------
def lift(cut: int, t: Term) -> Term:
    """Increment every free variable with index >= cut by one."""
    if isinstance(t, Var):
        return Var(t.idx + 1) if t.idx >= cut else t
    if isinstance(t, Lam):
        return Lam(lift(cut + 1, t.body))
    if isinstance(t, App):
        return App(lift(cut, t.fn), lift(cut, t.arg))
    raise TypeError(f"unknown term: {t!r}")


def subst(j: int, s: Term, t: Term) -> Term:
    """Substitute s for the free variable j inside t (capture-avoiding)."""
    if isinstance(t, Var):
        if t.idx == j:
            return s
        # variables above the hole shift down to fill the gap
        return Var(t.idx - 1) if t.idx > j else t
    if isinstance(t, Lam):
        return Lam(subst(j + 1, lift(0, s), t.body))
    if isinstance(t, App):
        return App(subst(j, s, t.fn), subst(j, s, t.arg))
    raise TypeError(f"unknown term: {t!r}")


def subst0(u: Term, t: Term) -> Term:
    """Beta-contraction substitution: replace variable 0 in t by u."""
    return subst(0, u, t)


# ---------------------------------------------------------------------------
# Single-step beta reduction and its transitive closure
# ---------------------------------------------------------------------------
def one_step_reducts(t: Term) -> list[Term]:
    """All terms reachable from t by contracting exactly one redex."""
    out: list[Term] = []
    if isinstance(t, App) and isinstance(t.fn, Lam):
        out.append(subst0(t.arg, t.fn.body))  # head redex
    if isinstance(t, App):
        out.extend(App(r, t.arg) for r in one_step_reducts(t.fn))
        out.extend(App(t.fn, r) for r in one_step_reducts(t.arg))
    if isinstance(t, Lam):
        out.extend(Lam(r) for r in one_step_reducts(t.body))
    return out


def is_normal_form(t: Term) -> bool:
    """True iff t contains no beta-redex."""
    return not one_step_reducts(t)


def normalize(t: Term, fuel: int = 10_000) -> Optional[Term]:
    """Reduce to normal form by leftmost-outermost steps; None if fuel runs out."""
    cur = t
    for _ in range(fuel):
        if is_normal_form(cur):
            return cur
        cur = one_step_reducts(cur)[0]
    return None


# ---------------------------------------------------------------------------
# Takahashi's complete development `cd`
#   cd contracts EVERY redex present in the term in a single sweep.
# ---------------------------------------------------------------------------
def cd(t: Term) -> Term:
    """Complete development: contract all currently-present redexes."""
    if isinstance(t, Var):
        return t
    if isinstance(t, Lam):
        return Lam(cd(t.body))
    if isinstance(t, App):
        if isinstance(t.fn, Lam):
            return subst0(cd(t.arg), cd(t.fn.body))
        return App(cd(t.fn), cd(t.arg))
    raise TypeError(f"unknown term: {t!r}")


# ---------------------------------------------------------------------------
# Parallel reduction membership test:  is `u` a Par-reduct of `t`?
# We generate the (finite) set of parallel reducts of a term to make the
# triangle and diamond properties concretely checkable.
# ---------------------------------------------------------------------------
def par_reducts(t: Term) -> list[Term]:
    """All terms u with  t ==>_par u  (one parallel step)."""
    results: set[Term] = set()
    if isinstance(t, Var):
        results.add(t)
    elif isinstance(t, Lam):
        for b in par_reducts(t.body):
            results.add(Lam(b))
    elif isinstance(t, App):
        # structural: reduce inside both sides simultaneously
        for a in par_reducts(t.fn):
            for b in par_reducts(t.arg):
                results.add(App(a, b))
        # beta: if the head is a lambda, also contract it simultaneously
        if isinstance(t.fn, Lam):
            for tb in par_reducts(t.fn.body):
                for ua in par_reducts(t.arg):
                    results.add(subst0(ua, tb))
    return list(results)


# ---------------------------------------------------------------------------
# Böhm-tree approximants (mirrors Bohm.lean)
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class BTApprox:
    """Finite Böhm-tree approximant."""


@dataclass(frozen=True)
class BTBot(BTApprox):
    """Divergence / undefined (⊥)."""


@dataclass(frozen=True)
class BTNode(BTApprox):
    head: int
    args: tuple[BTApprox, ...]


def bt_show(b: BTApprox) -> str:
    if isinstance(b, BTBot):
        return "⊥"
    if isinstance(b, BTNode):
        if not b.args:
            return str(b.head)
        return f"{b.head}[{', '.join(bt_show(a) for a in b.args)}]"
    raise TypeError(b)


def head_reduce(t: Term) -> Optional[Term]:
    if isinstance(t, App) and isinstance(t.fn, Lam):
        return subst0(t.arg, t.fn.body)
    if isinstance(t, App):
        r = head_reduce(t.fn)
        return App(r, t.arg) if r is not None else None
    return None


def extract_head(t: Term) -> Optional[tuple[int, list[Term]]]:
    if isinstance(t, Var):
        return (t.idx, [])
    if isinstance(t, App):
        h = extract_head(t.fn)
        if h is None:
            return None
        n, args = h
        return (n, args + [t.arg])
    return None


def bohm_approx(fuel: int, t: Term) -> BTApprox:
    if fuel == 0:
        return BTBot()
    hr = head_reduce(t)
    if hr is not None:
        return bohm_approx(fuel - 1, hr)
    eh = extract_head(t)
    if eh is not None:
        hd, args = eh
        return BTNode(hd, tuple(bohm_approx(fuel - 1, a) for a in args))
    return BTBot()


# ---------------------------------------------------------------------------
# Standard combinators
# ---------------------------------------------------------------------------
I = Lam(Var(0))                       # λx. x
K = Lam(Lam(Var(1)))                  # λx y. x
S = Lam(Lam(Lam(App(App(Var(2), Var(0)), App(Var(1), Var(0))))))
DELTA = Lam(App(Var(0), Var(0)))      # λx. x x
OMEGA = App(DELTA, DELTA)             # (λx. x x)(λx. x x)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_confluence() -> None:
    print("=" * 70)
    print("CONFLUENCE (Church–Rosser): forks can always be joined")
    print("=" * 70)
    # A term with two independent redexes -> two different one-step reducts.
    t = App(App(I, App(I, Var(0))), App(I, Var(1)))
    print("start term t =", show(t))
    reds = one_step_reducts(t)
    print(f"\nt has {len(reds)} one-step reducts:")
    for r in reds:
        print("   t -> ", show(r))
    # Their common reduct is the complete development cd(t).
    common = cd(t)
    print("\ncomplete development cd(t) =", show(common))
    for r in reds:
        joined = normalize(r)
        print(f"   {show(r):<28} -*-> {show(joined)}   (== cd-normal? "
              f"{normalize(common) == joined})")
    print("All branches reach the SAME normal form  ⇒  confluence holds.\n")


def demo_triangle() -> None:
    print("=" * 70)
    print("TRIANGLE PROPERTY: every parallel reduct of t reduces to cd(t)")
    print("=" * 70)
    t = App(Lam(App(App(I, Var(0)), Var(0))), App(I, Var(3)))
    print("t =", show(t))
    print("cd(t) =", show(cd(t)))
    target = cd(t)
    ok = True
    for u in par_reducts(t):
        # u ==>_par cd(t)  iff  cd(t) is among the parallel reducts of u
        reaches = target in par_reducts(u)
        ok = ok and reaches
        print(f"   t ==> {show(u):<34}   u ==> cd(t)?  {reaches}")
    print(f"Triangle property holds for every reduct:  {ok}\n")


def demo_diamond() -> None:
    print("=" * 70)
    print("DIAMOND PROPERTY of parallel reduction (witness = cd(t))")
    print("=" * 70)
    t = App(App(Lam(Var(0)), Var(5)), App(Lam(Var(0)), Var(6)))
    print("t =", show(t))
    rs = par_reducts(t)
    w = cd(t)
    print("common reduct w = cd(t) =", show(w))
    good = all(w in par_reducts(u) for u in rs)
    print(f"Every pair (u, v) of parallel reducts joins at w:  {good}\n")


def demo_normalization() -> None:
    print("=" * 70)
    print("NORMALIZATION: terminating vs. diverging terms")
    print("=" * 70)
    skk = App(App(App(S, K), K), Var(0))   # SKK x  =beta=>  x
    print("S K K x =", show(skk), " -*-> ", show(normalize(skk)))
    print("Ω =", show(OMEGA),
          " -> ", show(one_step_reducts(OMEGA)[0]),
          "  (reduces to itself: never normalizes)\n")


def demo_bohm() -> None:
    print("=" * 70)
    print("BÖHM-TREE APPROXIMANTS")
    print("=" * 70)
    for d in range(4):
        print(f"   bohmApprox({d}, Ω) = {bt_show(bohm_approx(d, OMEGA))}")
    print("   Ω approximates to ⊥ at every depth (theorem omega_bohmApprox_bot).")
    # A head-normal form: variable 0 applied to Ω and to the identity.
    t = App(App(Var(0), OMEGA), I)
    for d in range(1, 5):
        print(f"   bohmApprox({d}, 0 Ω I) = {bt_show(bohm_approx(d, t))}")
    print()


if __name__ == "__main__":
    demo_confluence()
    demo_triangle()
    demo_diamond()
    demo_normalization()
    demo_bohm()
