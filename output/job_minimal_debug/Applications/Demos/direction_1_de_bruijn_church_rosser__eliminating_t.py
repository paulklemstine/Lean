#!/usr/bin/env python3
"""
Applications of De Bruijn Church-Rosser Theory

Demonstrates real-world applications:
1. Compiler optimization: beta reduction as inlining
2. Equality testing: two programs are equivalent if their normal forms match
3. Parallel evaluation: develop as a massively parallel rewrite step
"""

from demo import (
    Term, Var, App, Lam,
    subst0, develop, beta_step, all_parallel_reducts,
    size, redex_count, is_closed
)
from algorithms import normalize, normalize_via_develop, verify_diamond


def demo_compiler_optimization():
    """Demonstrate beta reduction as a compiler optimization (inlining).

    In a compiler, `(λ. body) arg` corresponds to a function call.
    Beta reduction `body[0 := arg]` corresponds to inlining the argument.
    Complete development performs ALL inlinings simultaneously.
    """
    print("═" * 60)
    print("APPLICATION 1: Compiler Optimization (Inlining)")
    print("═" * 60)

    # Simulate: let f = (λx. x + x) in f(f(1))
    # In de Bruijn: (λ. (#0 (#0 #1))) (λ. (#0 #0))
    # where #1 represents the "+" operation (external)
    double = Lam(App(Var(0), Var(0)))          # λ. x x (self-application as doubling)
    program = App(Lam(App(Var(0), App(Var(0), Var(1)))), double)

    print(f"\n  Source program: {program}")
    print(f"  Size: {size(program)}, Redexes: {redex_count(program)}")

    # One-pass complete development (all inlining at once)
    optimized = develop(program)
    print(f"\n  After complete development (parallel inlining):")
    print(f"  {optimized}")
    print(f"  Size: {size(optimized)}, Redexes: {redex_count(optimized)}")

    # Compare with sequential optimization
    print(f"\n  Sequential reduction trace:")
    t = program
    for i in range(10):
        r = beta_step(t)
        if r is None:
            print(f"    Normal form after {i} steps: {t}")
            break
        t = r
        print(f"    Step {i+1}: {t}")


def demo_program_equivalence():
    """Demonstrate using Church-Rosser for program equivalence testing.

    Church-Rosser guarantees: if two terms are beta-equivalent, they
    share a common reduct. So to test equivalence, normalize both and compare.
    """
    print("\n" + "═" * 60)
    print("APPLICATION 2: Program Equivalence Testing")
    print("═" * 60)

    # Two different implementations of the same function
    # Version 1: (λ. λ. #1) applied then eta-expanded
    prog1 = App(Lam(Lam(Var(1))), Lam(Var(0)))  # K I
    # Version 2: identity directly
    prog2 = Lam(Var(0))  # I

    print(f"\n  Program 1: {prog1}")
    print(f"  Program 2: {prog2}")

    nf1, s1 = normalize(prog1)
    nf2, s2 = normalize(prog2)

    print(f"\n  Normal form 1: {nf1}  ({s1} steps)")
    print(f"  Normal form 2: {nf2}  ({s2} steps)")
    print(f"  Equivalent: {nf1 == nf2}")

    # Another pair
    print()
    # S K K = I (a classic combinator identity)
    S = Lam(Lam(Lam(App(App(Var(2), Var(0)), App(Var(1), Var(0))))))
    K = Lam(Lam(Var(1)))
    I = Lam(Var(0))
    SKK = App(App(S, K), K)

    print(f"  S = {S}")
    print(f"  K = {K}")
    print(f"  S K K = {SKK}")

    nf_skk, s_skk = normalize(SKK)
    nf_i, s_i = normalize(I)

    print(f"\n  Normal form of S K K: {nf_skk}  ({s_skk} steps)")
    print(f"  Normal form of I:     {nf_i}  ({s_i} steps)")
    print(f"  S K K ≡ I: {nf_skk == nf_i}")


def demo_parallel_evaluation():
    """Demonstrate parallel evaluation using complete development.

    The diamond property means: no matter how we partition the redexes
    into subsets and reduce them in any order, we always reach the same
    result. This is the mathematical foundation of parallel evaluation.
    """
    print("\n" + "═" * 60)
    print("APPLICATION 3: Parallel Evaluation & Diamond Property")
    print("═" * 60)

    # A term with multiple independent redexes
    t = App(
        App(Lam(Lam(App(Var(1), Var(0)))),  # λ. λ. #1 #0
            Lam(Var(0))),                     # applied to I
        App(Lam(Var(0)), Lam(Var(0)))         # I I
    )

    print(f"\n  Term: {t}")
    print(f"  Redexes: {redex_count(t)}")

    reducts = all_parallel_reducts(t)
    print(f"  Parallel reducts: {len(reducts)}")

    dev_t = develop(t)
    print(f"  Complete development: {dev_t}")

    # Verify diamond: all reducts converge to develop(t)
    success, stats = verify_diamond(t)
    print(f"\n  Diamond property verified: {success}")
    print(f"  All {stats['num_reducts']} reducts converge to develop(t): "
          f"{stats['all_converge_to_develop']}")

    # Show convergence
    print(f"\n  Convergence paths:")
    for i, u in enumerate(reducts[:5]):
        u_dev = develop(u) if u != dev_t else u
        # Check if dev_t is reachable
        u_reducts = all_parallel_reducts(u)
        reachable = dev_t in u_reducts
        print(f"    Reduct [{i}]: {u}")
        print(f"      → develop(t) reachable: {reachable}")


def main():
    demo_compiler_optimization()
    demo_program_equivalence()
    demo_parallel_evaluation()

    print("\n" + "═" * 60)
    print("ALL APPLICATIONS DEMONSTRATED SUCCESSFULLY")
    print("═" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
De Bruijn Lambda Calculus — Interactive Demo

Demonstrates construction of de Bruijn terms, substitution, shifting,
parallel reduction traces, and empirical testing of the complete
development conjecture on small terms.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
import itertools


# ─── Syntax ──────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class Var:
    """De Bruijn variable."""
    index: int
    def __repr__(self): return f"#{self.index}"

@dataclass(frozen=True)
class App:
    """Application."""
    fun: 'Term'
    arg: 'Term'
    def __repr__(self): return f"({self.fun} {self.arg})"

@dataclass(frozen=True)
class Lam:
    """Lambda abstraction (de Bruijn: no variable name needed)."""
    body: 'Term'
    def __repr__(self): return f"(λ. {self.body})"

Term = Var | App | Lam


# ─── Renaming ────────────────────────────────────────────────────────────────

def lift_ren(rho):
    """Lift a renaming under a binder."""
    def lifted(n):
        return 0 if n == 0 else rho(n - 1) + 1
    return lifted

def rename(rho, t: Term) -> Term:
    """Apply a renaming to a term."""
    if isinstance(t, Var):
        return Var(rho(t.index))
    elif isinstance(t, App):
        return App(rename(rho, t.fun), rename(rho, t.arg))
    elif isinstance(t, Lam):
        return Lam(rename(lift_ren(rho), t.body))

def shift1(t: Term) -> Term:
    """Shift all free variables up by 1."""
    return rename(lambda n: n + 1, t)


# ─── Substitution ────────────────────────────────────────────────────────────

def lift_subst(sigma):
    """Lift a substitution under a binder."""
    def lifted(n):
        return Var(0) if n == 0 else shift1(sigma(n - 1))
    return lifted

def subst_env(sigma, t: Term) -> Term:
    """Apply a simultaneous substitution."""
    if isinstance(t, Var):
        return sigma(t.index)
    elif isinstance(t, App):
        return App(subst_env(sigma, t.fun), subst_env(sigma, t.arg))
    elif isinstance(t, Lam):
        return Lam(subst_env(lift_subst(sigma), t.body))

def scons(s: Term, sigma):
    """Cons a term onto a substitution."""
    def result(n):
        return s if n == 0 else sigma(n - 1)
    return result

def ids(n):
    """Identity substitution."""
    return Var(n)

def subst0(s: Term, t: Term) -> Term:
    """Substitute s for variable 0 in t."""
    return subst_env(scons(s, ids), t)


# ─── Beta Reduction ──────────────────────────────────────────────────────────

def is_redex(t: Term) -> bool:
    """Check if term is a beta redex at the root."""
    return isinstance(t, App) and isinstance(t.fun, Lam)

def beta_step(t: Term) -> Optional[Term]:
    """Perform one leftmost-outermost beta step, or None if normal."""
    if isinstance(t, Var):
        return None
    elif isinstance(t, App):
        if isinstance(t.fun, Lam):
            return subst0(t.arg, t.fun.body)
        r = beta_step(t.fun)
        if r is not None:
            return App(r, t.arg)
        r = beta_step(t.arg)
        if r is not None:
            return App(t.fun, r)
        return None
    elif isinstance(t, Lam):
        r = beta_step(t.body)
        return Lam(r) if r is not None else None


# ─── Complete Development ────────────────────────────────────────────────────

def develop(t: Term) -> Term:
    """Complete development (Takahashi's star-translation).
    Simultaneously contracts ALL beta redexes."""
    if isinstance(t, Var):
        return t
    elif isinstance(t, App):
        if isinstance(t.fun, Lam):
            return subst0(develop(t.arg), develop(t.fun.body))
        return App(develop(t.fun), develop(t.arg))
    elif isinstance(t, Lam):
        return Lam(develop(t.body))


# ─── Parallel Reduction ──────────────────────────────────────────────────────

def all_parallel_reducts(t: Term) -> list[Term]:
    """Enumerate all parallel reducts of t (all possible subsets of
    simultaneous redex contractions).

    Corresponds to the ParBetaDB inductive: the beta rule only fires
    when the function is ALREADY a lambda (not when it reduces to one)."""
    if isinstance(t, Var):
        return [t]
    elif isinstance(t, Lam):
        return [Lam(b) for b in all_parallel_reducts(t.body)]
    elif isinstance(t, App):
        fun_reducts = all_parallel_reducts(t.fun)
        arg_reducts = all_parallel_reducts(t.arg)
        results = []
        # App case: reduce function and argument independently
        for f in fun_reducts:
            for a in arg_reducts:
                results.append(App(f, a))
        # Beta case: only if the function is already a lambda
        if isinstance(t.fun, Lam):
            body_reducts = all_parallel_reducts(t.fun.body)
            for b in body_reducts:
                for a in arg_reducts:
                    results.append(subst0(a, b))
        return results


# ─── Metrics ─────────────────────────────────────────────────────────────────

def size(t: Term) -> int:
    if isinstance(t, Var): return 1
    elif isinstance(t, App): return 1 + size(t.fun) + size(t.arg)
    elif isinstance(t, Lam): return 1 + size(t.body)

def redex_count(t: Term) -> int:
    if isinstance(t, Var): return 0
    elif isinstance(t, App):
        base = redex_count(t.fun) + redex_count(t.arg)
        return (1 + base) if isinstance(t.fun, Lam) else base
    elif isinstance(t, Lam): return redex_count(t.body)

def is_closed(t: Term, depth: int = 0) -> bool:
    if isinstance(t, Var): return t.index < depth
    elif isinstance(t, App): return is_closed(t.fun, depth) and is_closed(t.arg, depth)
    elif isinstance(t, Lam): return is_closed(t.body, depth + 1)


# ─── Term Enumeration ────────────────────────────────────────────────────────

def enumerate_terms(max_size: int, depth: int = 0) -> list[Term]:
    """Enumerate all closed de Bruijn terms up to a given size."""
    if max_size < 1:
        return []
    results = []
    # Variables
    for i in range(depth):
        results.append(Var(i))
    # Lambda
    if max_size >= 2:
        for body in enumerate_terms(max_size - 1, depth + 1):
            results.append(Lam(body))
    # Application
    for s1 in range(1, max_size - 1):
        s2 = max_size - 1 - s1
        for t1 in enumerate_terms(s1, depth):
            for t2 in enumerate_terms(s2, depth):
                results.append(App(t1, t2))
    return results


# ─── Conjecture Testing ─────────────────────────────────────────────────────

def test_triangle_property(max_term_size: int = 7) -> tuple[bool, Optional[tuple]]:
    """Test the triangle property: for all t and all parallel reducts u of t,
    does u parallel-reduce to develop(t)?

    Returns (passed, counterexample_or_None)."""
    terms = enumerate_terms(max_term_size)
    closed_terms = [t for t in terms if is_closed(t)]

    for t in closed_terms:
        dev_t = develop(t)
        reducts = all_parallel_reducts(t)
        for u in reducts:
            # Check: does u parallel-reduce to dev_t?
            u_reducts = all_parallel_reducts(u)
            if dev_t not in u_reducts:
                return (False, (t, u, dev_t))
    return (True, None)


def test_develop_reduces_redexes(max_term_size: int = 7) -> list[tuple]:
    """Find counterexamples to: redex_count(develop(t)) <= redex_count(t)."""
    terms = enumerate_terms(max_term_size)
    closed_terms = [t for t in terms if is_closed(t)]
    counterexamples = []
    for t in closed_terms:
        dt = develop(t)
        if redex_count(dt) > redex_count(t):
            counterexamples.append((t, redex_count(t), dt, redex_count(dt)))
    return counterexamples


# ─── Demo ────────────────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("DE BRUIJN LAMBDA CALCULUS — INTERACTIVE DEMO")
    print("=" * 70)

    # 1. Basic term construction
    print("\n── 1. Term Construction ──")
    identity = Lam(Var(0))           # λ. #0  (= λx. x)
    const = Lam(Lam(Var(1)))         # λ. λ. #1  (= λx. λy. x)
    omega = Lam(App(Var(0), Var(0))) # λ. (#0 #0)  (= λx. x x)
    Omega = App(omega, omega)        # (λ. #0 #0) (λ. #0 #0)

    print(f"  Identity (I):  {identity}")
    print(f"  Const (K):     {const}")
    print(f"  Self-app (ω):  {omega}")
    print(f"  Omega (Ω):     {Omega}")

    # 2. Shifting
    print("\n── 2. Shifting ──")
    t = App(Var(0), Var(1))
    print(f"  Original:      {t}")
    print(f"  shift1:        {shift1(t)}")

    # 3. Substitution
    print("\n── 3. Substitution ──")
    body = App(Var(0), Var(1))  # #0 #1
    s = Lam(Var(0))             # λ. #0
    result = subst0(s, body)
    print(f"  body = {body}")
    print(f"  s    = {s}")
    print(f"  body[0 := s] = {result}")

    # 4. Beta reduction trace
    print("\n── 4. Beta Reduction Trace ──")
    t = App(App(const, identity), omega)  # K I ω
    print(f"  Start: {t}")
    step = 0
    while t is not None:
        r = beta_step(t)
        if r is None:
            print(f"  Normal form reached after {step} steps.")
            break
        step += 1
        t = r
        print(f"  Step {step}: {t}")
        if step > 20:
            print("  (truncated)")
            break

    # 5. Complete development
    print("\n── 5. Complete Development ──")
    t = App(Lam(App(Var(0), Var(0))), identity)
    print(f"  Term:     {t}")
    print(f"  Redexes:  {redex_count(t)}")
    dt = develop(t)
    print(f"  develop:  {dt}")
    print(f"  Redexes:  {redex_count(dt)}")

    # Counterexample for redex reduction
    print("\n  Counterexample: develop can INCREASE redex count")
    t2 = App(Lam(App(Var(0), App(Var(0), Var(1)))), Lam(Var(0)))
    print(f"  Term:      {t2}")
    print(f"  Redexes:   {redex_count(t2)}")
    dt2 = develop(t2)
    print(f"  develop:   {dt2}")
    print(f"  Redexes:   {redex_count(dt2)}")

    # 6. Parallel reduction enumeration
    print("\n── 6. Parallel Reducts ──")
    t = App(Lam(App(Var(0), Var(0))), App(Lam(Var(0)), Var(0)))
    print(f"  Term: {t}")
    reducts = all_parallel_reducts(t)
    print(f"  Number of parallel reducts: {len(reducts)}")
    for i, r in enumerate(reducts[:8]):
        print(f"    [{i}] {r}")
    if len(reducts) > 8:
        print(f"    ... ({len(reducts) - 8} more)")

    # 7. Conjecture testing
    print("\n── 7. Triangle Property Test ──")
    for sz in [4, 5, 6]:
        terms = [t for t in enumerate_terms(sz) if is_closed(t)]
        passed, cx = test_triangle_property(sz)
        status = "✓ PASSED" if passed else "✗ FAILED"
        print(f"  Size ≤ {sz}: {len(terms)} closed terms — {status}")
        if not passed:
            t, u, dev_t = cx
            print(f"    Counterexample: t={t}, u={u}, develop(t)={dev_t}")

    # 8. Redex counterexamples
    print("\n── 8. Redex Count Counterexamples ──")
    cxs = test_develop_reduces_redexes(6)
    print(f"  Found {len(cxs)} counterexample(s) to 'develop reduces redexes'")
    for t, rc_t, dt, rc_dt in cxs[:5]:
        print(f"    t={t}  redexes={rc_t} → develop(t)={dt}  redexes={rc_dt}")

    print("\n" + "=" * 70)
    print("DEMO COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()
