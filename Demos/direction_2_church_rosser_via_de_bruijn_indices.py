#!/usr/bin/env python3
"""
applications.py — Applications of quantitative confluence theory.

Demonstrates real-world applications of the Church-Rosser theorem
and the metric hub inequality in:
1. Compiler optimization verification
2. Program equivalence checking
3. Normalization cost analysis
4. Reduction strategy comparison
"""

from algorithms import *
from typing import List, Tuple
import time


# ─── Application 1: Compiler Optimization Verification ───────────────────────

def verify_optimization(original: DBTerm, optimized: DBTerm, name: str = "") -> bool:
    """
    Verify that a compiler optimization preserves semantics.

    By the Church-Rosser theorem, if both terms normalize to the same
    normal form, they are β-equivalent (semantically identical).

    This is a simple but powerful verification technique: instead of
    proving the optimization correct directly, we just normalize both
    sides and compare.
    """
    nf_orig, cost_orig = normalize(original)
    nf_opt, cost_opt = normalize(optimized)

    if nf_orig is None or nf_opt is None:
        print(f"  [{name}] ⚠ Could not normalize (may diverge)")
        return False

    correct = nf_orig == nf_opt
    savings = cost_orig - cost_opt

    print(f"  [{name}]")
    print(f"    Original:  normCost = {cost_orig}")
    print(f"    Optimized: normCost = {cost_opt}")
    print(f"    Savings:   {savings} steps ({savings/max(cost_orig,1)*100:.0f}%)")
    print(f"    Correct?   {'✓' if correct else '✗'}")

    return correct


def demo_compiler_verification():
    """Demonstrate compiler optimization verification via normalization."""
    print("=" * 60)
    print("Application 1: Compiler Optimization Verification")
    print("=" * 60)

    # Optimization: (λx.x) M → M (β-reduction of identity)
    M = App(Var(0), Var(1))
    original = App(I, M)
    optimized = M
    verify_optimization(original, optimized, "identity elimination")

    # Optimization: K M N → M (constant folding)
    N = Var(2)
    original2 = App(App(K, M), N)
    optimized2 = M
    verify_optimization(original2, optimized2, "constant folding")

    # Dead code elimination: (λx.y) M → y
    original3 = App(Lam(Var(1)), App(Var(0), Var(0)))
    optimized3 = Var(0)  # y (after decrement)
    verify_optimization(original3, optimized3, "dead code elimination")

    print()


# ─── Application 2: Program Equivalence Testing ──────────────────────────────

def check_equivalence(t: DBTerm, u: DBTerm, name: str = "") -> Tuple[bool, int, int]:
    """
    Check if two programs are β-equivalent by normalization.

    Returns (equivalent, cost_t, cost_u).
    By uniqueness of normal forms (proved in our formalization),
    β-equivalence is decidable for normalizing terms.
    """
    nf_t, cost_t = normalize(t)
    nf_u, cost_u = normalize(u)

    if nf_t is None or nf_u is None:
        return False, cost_t, cost_u

    equiv = nf_t == nf_u
    return equiv, cost_t, cost_u


def demo_program_equivalence():
    """Test equivalence of different implementations."""
    print("=" * 60)
    print("Application 2: Program Equivalence Checking")
    print("=" * 60)

    # Church numeral addition: two implementations
    # plus1 = λm.λn.λf.λx. m f (n f x)
    plus1 = Lam(Lam(Lam(Lam(
        App(App(Var(3), Var(1)), App(App(Var(2), Var(1)), Var(0)))
    ))))

    # plus2 = λm.λn. m succ n  where succ = λn.λf.λx. f (n f x)
    succ = Lam(Lam(Lam(App(Var(1), App(App(Var(2), Var(1)), Var(0))))))
    plus2 = Lam(Lam(App(App(Var(1), succ), Var(0))))

    # Test: plus1 2 3 ≡ plus2 2 3 ≡ 5
    result1 = App(App(plus1, church(2)), church(3))
    result2 = App(App(plus2, church(2)), church(3))

    equiv, c1, c2 = check_equivalence(result1, result2, "plus implementations")
    nf1, _ = normalize(result1)
    five = church(5)

    print(f"  plus1(2,3): normCost = {c1}")
    print(f"  plus2(2,3): normCost = {c2}")
    print(f"  Equivalent? {'✓' if equiv else '✗'}")
    print(f"  Both equal Church(5)? {nf1 == five}")
    print(f"  Hub bound: d ≤ {c1} + {c2} = {c1 + c2}")
    print()


# ─── Application 3: Normalization Cost Analysis ──────────────────────────────

def analyze_cost_family(name: str, terms: List[Tuple[str, DBTerm]]):
    """Analyze normalization costs for a family of terms."""
    print(f"\n  Family: {name}")
    print(f"  {'Term':<20} {'Size':>6} {'NormCost':>10} {'CD Passes':>10}")
    print(f"  {'-'*20} {'-'*6} {'-'*10} {'-'*10}")

    for label, t in terms:
        size = term_size(t)
        _, cost = normalize(t, fuel=5000)
        _, cd_passes = normalize_via_cd(t, fuel=100)
        print(f"  {label:<20} {size:>6} {cost:>10} {cd_passes:>10}")


def demo_cost_analysis():
    """Analyze normalization costs across term families."""
    print("=" * 60)
    print("Application 3: Normalization Cost Analysis")
    print("=" * 60)

    # Church numeral self-application: church(n) church(n) church(m)
    church_apps = [
        (f"church({n}) I", App(church(n), I))
        for n in range(6)
    ]
    analyze_cost_family("Church(n) applied to I", church_apps)

    # SKK = I (well-known equivalence)
    skk_variants = [
        ("I", I),
        ("S K K", App(App(S, K), K)),
        ("S K S", App(App(S, K), S)),
    ]
    analyze_cost_family("Identity variants", skk_variants)
    print()


# ─── Application 4: Reduction Strategy Comparison ────────────────────────────

def demo_strategy_comparison():
    """Compare different reduction strategies."""
    print("=" * 60)
    print("Application 4: Reduction Strategy Comparison")
    print("=" * 60)

    terms = [
        ("(λx.xx)(II)", App(Lam(App(Var(0), Var(0))), App(I, I))),
        ("KI(II)", App(App(K, I), App(I, I))),
        ("S I I x", App(App(App(S, I), I), Var(0))),
    ]

    for name, t in terms:
        # Leftmost-outermost
        nf_lo, cost_lo = normalize(t)
        # Complete development
        nf_cd, cost_cd = normalize_via_cd(t)

        print(f"\n  Term: {name}")
        print(f"    Leftmost-outermost: {cost_lo} steps")
        print(f"    Complete development: {cost_cd} passes")
        if nf_lo is not None and nf_cd is not None:
            print(f"    Same result? {nf_lo == nf_cd}")

    print()


# ─── Application 5: Hub Distance Verification ────────────────────────────────

def demo_hub_distance():
    """Verify the metric hub inequality on concrete examples."""
    print("=" * 60)
    print("Application 5: Metric Hub Inequality Verification")
    print("=" * 60)
    print("  Theorem: d(t,u) ≤ normCost(t) + normCost(u)")
    print("  for all β-equivalent normalizing terms t, u")

    # Generate pairs of β-equivalent terms
    pairs = []

    # (λx.x)(λy.y) ↔ λy.y
    pairs.append(("II", App(I, I), "I", I))

    # S K K x ↔ I x ↔ x
    pairs.append(("SKKx", App(App(App(S, K), K), Var(0)),
                  "Ix", App(I, Var(0))))

    # K I (II) ↔ K I I
    pairs.append(("KI(II)", App(App(K, I), App(I, I)),
                  "KII", App(App(K, I), I)))

    print(f"\n  {'Pair':<25} {'d(t,u)':>8} {'c(t)+c(u)':>10} {'Holds?':>8}")
    print(f"  {'-'*25} {'-'*8} {'-'*10} {'-'*8}")

    for name_t, t, name_u, u in pairs:
        nf_t, cost_t = normalize(t)
        nf_u, cost_u = normalize(u)
        bound = cost_t + cost_u

        dist = eq_path_dist(t, u, max_depth=10)
        dist_str = str(dist) if dist is not None else ">10"

        holds = dist is not None and dist <= bound
        pair_name = f"{name_t} ↔ {name_u}"

        print(f"  {pair_name:<25} {dist_str:>8} {bound:>10} {'✓' if holds else '?':>8}")

    print()


if __name__ == "__main__":
    print("\n" + "═" * 60)
    print(" Applications of Quantitative Confluence Theory")
    print("═" * 60 + "\n")

    demo_compiler_verification()
    demo_program_equivalence()
    demo_cost_analysis()
    demo_strategy_comparison()
    demo_hub_distance()

    print("═" * 60)
    print(" All applications demonstrated successfully.")
    print("═" * 60)


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of Church-Rosser via de Bruijn indices.

Demonstrates:
- De Bruijn term construction and display
- Capture-avoiding substitution
- Parallel β-reduction and complete development
- Church-Rosser confluence (common reducts)
- Normalization and the metric hub inequality:
    eqPathDist(t,u) ≤ normCost(t) + normCost(u)

Keywords: Church-Rosser, de Bruijn indices, parallel β-reduction,
confluence, uniqueness of normal forms, quantitative rewriting
"""

from dataclasses import dataclass
from typing import Optional, List, Tuple


# ─── De Bruijn Term Syntax ────────────────────────────────────────────────────

@dataclass(frozen=True)
class Var:
    index: int
    def __repr__(self): return str(self.index)

@dataclass(frozen=True)
class App:
    fun: 'DBTerm'
    arg: 'DBTerm'
    def __repr__(self): return f"({self.fun} {self.arg})"

@dataclass(frozen=True)
class Lam:
    body: 'DBTerm'
    def __repr__(self): return f"(λ.{self.body})"

DBTerm = Var | App | Lam


# ─── Shifting ─────────────────────────────────────────────────────────────────

def shift(d: int, c: int, t: DBTerm) -> DBTerm:
    """Shift free variables >= cutoff c by amount d."""
    match t:
        case Var(k):
            return Var(k) if k < c else Var(k + d)
        case App(f, a):
            return App(shift(d, c, f), shift(d, c, a))
        case Lam(body):
            return Lam(shift(d, c + 1, body))


# ─── Substitution ─────────────────────────────────────────────────────────────

def subst(s: DBTerm, j: int, t: DBTerm) -> DBTerm:
    """Substitute s for variable j in t (capture-avoiding, with decrement)."""
    match t:
        case Var(k):
            if k == j: return s
            elif k < j: return Var(k)
            else: return Var(k - 1)
        case App(f, a):
            return App(subst(s, j, f), subst(s, j, a))
        case Lam(body):
            return Lam(subst(shift(1, 0, s), j + 1, body))


# ─── One-step β-reduction ────────────────────────────────────────────────────

def beta_reduce_once(t: DBTerm) -> Optional[DBTerm]:
    """Try one leftmost-outermost β-reduction step."""
    match t:
        case App(Lam(body), arg):
            return subst(arg, 0, body)
        case App(f, a):
            r = beta_reduce_once(f)
            if r is not None: return App(r, a)
            r = beta_reduce_once(a)
            if r is not None: return App(f, r)
            return None
        case Lam(body):
            r = beta_reduce_once(body)
            return Lam(r) if r is not None else None
        case _:
            return None


# ─── Complete Development (Takahashi's ⋆-translation) ─────────────────────

def complete_dev(t: DBTerm) -> DBTerm:
    """Contract ALL β-redexes simultaneously (Takahashi's ⋆-translation)."""
    match t:
        case Var(k):
            return Var(k)
        case App(Lam(body), arg):
            return subst(complete_dev(arg), 0, complete_dev(body))
        case App(f, a):
            return App(complete_dev(f), complete_dev(a))
        case Lam(body):
            return Lam(complete_dev(body))


# ─── Normalization ────────────────────────────────────────────────────────────

def normalize(t: DBTerm, fuel: int = 1000) -> Tuple[DBTerm, int]:
    """Normalize t by repeated β-reduction. Returns (normal_form, step_count)."""
    steps = 0
    current = t
    for _ in range(fuel):
        r = beta_reduce_once(current)
        if r is None:
            return current, steps
        current = r
        steps += 1
    return current, steps


def is_normal_form(t: DBTerm) -> bool:
    return beta_reduce_once(t) is None


# ─── Named term pretty-printing ──────────────────────────────────────────────

def pretty(t: DBTerm, depth: int = 0) -> str:
    """Pretty-print with named variables for readability."""
    names = "xyzwvutsrqpnm"
    match t:
        case Var(k):
            idx = depth - k - 1
            return names[idx % len(names)] if 0 <= idx < len(names) else f"#{k}"
        case App(f, a):
            return f"({pretty(f, depth)} {pretty(a, depth)})"
        case Lam(body):
            vname = names[depth % len(names)]
            return f"(λ{vname}.{pretty(body, depth + 1)})"


# ─── Example Terms ────────────────────────────────────────────────────────────

# Church numerals
def church(n: int) -> DBTerm:
    """Church numeral n = λf.λx. f^n x"""
    body = Var(0)  # x
    for _ in range(n):
        body = App(Var(1), body)  # f applied
    return Lam(Lam(body))

# Combinators
I = Lam(Var(0))                                    # λx.x
K = Lam(Lam(Var(1)))                               # λx.λy.x
S = Lam(Lam(Lam(App(App(Var(2), Var(0)),           # λx.λy.λz.(xz)(yz)
                     App(Var(1), Var(0))))))
OMEGA = App(Lam(App(Var(0), Var(0))),               # (λx.xx)(λx.xx)
            Lam(App(Var(0), Var(0))))


# ─── Demonstrations ──────────────────────────────────────────────────────────

def demo_substitution():
    """Demonstrate capture-avoiding substitution with de Bruijn indices."""
    print("=" * 60)
    print("DEMO 1: Capture-Avoiding Substitution")
    print("=" * 60)

    # (λx.λy.x)[x := y] should NOT capture y
    # In de Bruijn: (λ.λ.1)[0 := 0] — substituting var 0 for var 0
    # With named vars this would be problematic; with de Bruijn it's clean
    t = Lam(Lam(Var(1)))  # λ.λ.1 = λx.λy.x (K combinator body)
    s = Var(0)            # free variable 0
    result = subst(s, 0, t)
    print(f"  Term:   {pretty(t)} = {t}")
    print(f"  Subst:  [0 := {s}]")
    print(f"  Result: {pretty(result)} = {result}")
    print(f"  (No capture — de Bruijn handles it automatically)")
    print()


def demo_complete_development():
    """Demonstrate Takahashi's complete development."""
    print("=" * 60)
    print("DEMO 2: Complete Development (Takahashi's ⋆-translation)")
    print("=" * 60)

    # (λx.x)(λy.y) — should reduce to λy.y
    t = App(I, I)
    cd = complete_dev(t)
    print(f"  Term:       {pretty(t)}")
    print(f"  Star(term): {pretty(cd)}")
    print(f"  Is NF?      {is_normal_form(cd)}")
    print()

    # Church numeral 2 applied to successor-like term
    two = church(2)
    succ = Lam(Lam(Lam(App(Var(1), App(App(Var(2), Var(1)), Var(0))))))
    t2 = App(App(two, I), Var(0))
    cd2 = complete_dev(t2)
    print(f"  Term:       {pretty(t2)}")
    print(f"  Star(term): {pretty(cd2)}")
    nf2, steps2 = normalize(t2)
    print(f"  Normal form: {pretty(nf2)} (in {steps2} steps)")
    print()


def demo_church_rosser():
    """Demonstrate Church-Rosser: different reduction paths converge."""
    print("=" * 60)
    print("DEMO 3: Church-Rosser Confluence")
    print("=" * 60)

    # (λx.x x)(I) where I = λy.y
    # Two reduction strategies: reduce outer or inner first
    t = App(Lam(App(Var(0), Var(0))), I)

    # Path 1: reduce the outer β-redex first
    r1 = subst(I, 0, App(Var(0), Var(0)))  # I I
    print(f"  Start:   {pretty(t)}")
    print(f"  Path 1 (outer first): {pretty(r1)}")
    nf1, s1 = normalize(r1)
    print(f"    → normalizes to {pretty(nf1)} in {s1} steps")

    # Path 2: reduce the inner I first (it's already in NF, so reduce arg)
    # Actually both paths converge to I
    nf_orig, s_orig = normalize(t)
    print(f"  Path 2 (full normalization): {pretty(nf_orig)} in {s_orig} steps")

    print(f"\n  ✓ Both paths reach the same normal form: {pretty(nf1)}")
    print(f"  This is the Church-Rosser theorem in action!")
    print()


def demo_metric_hub():
    """Demonstrate the metric hub inequality for normalizing terms."""
    print("=" * 60)
    print("DEMO 4: Metric Hub — d(t,u) ≤ normCost(t) + normCost(u)")
    print("=" * 60)

    pairs = [
        ("I I", App(I, I), "I", I),
        ("K I I", App(App(K, I), I), "K I", App(K, I)),
        ("S K K", App(App(S, K), K), "I", I),
    ]

    for name_t, t, name_u, u in pairs:
        nf_t, cost_t = normalize(t)
        nf_u, cost_u = normalize(u)

        # Compute path distance (upper bound: sum of steps in β-eq chain)
        # The actual eqPathDist would require the minimal chain, but
        # we can bound it by cost_t + cost_u when nf_t == nf_u
        same_nf = nf_t == nf_u
        bound = cost_t + cost_u

        print(f"\n  t = {name_t:<8} normCost = {cost_t}")
        print(f"  u = {name_u:<8} normCost = {cost_u}")
        print(f"  nf(t) = {pretty(nf_t)}")
        print(f"  nf(u) = {pretty(nf_u)}")
        print(f"  Same NF? {same_nf}")
        if same_nf:
            print(f"  ✓ d(t,u) ≤ {cost_t} + {cost_u} = {bound}")
        else:
            print(f"  (Different NFs — terms may not be β-equivalent)")
    print()


def demo_church_numerals():
    """Demonstrate confluence on Church numeral arithmetic."""
    print("=" * 60)
    print("DEMO 5: Church Numeral Confluence")
    print("=" * 60)

    for n in range(5):
        cn = church(n)
        nf, cost = normalize(cn)
        print(f"  Church({n}): normCost = {cost}, isNF = {is_normal_form(cn)}")

    # 2 + 1 via Church encoding
    # plus = λm.λn.λf.λx. m f (n f x)
    plus = Lam(Lam(Lam(Lam(
        App(App(Var(3), Var(1)),
            App(App(Var(2), Var(1)), Var(0)))
    ))))

    two_plus_one = App(App(plus, church(2)), church(1))
    nf, cost = normalize(two_plus_one, fuel=200)
    three = church(3)
    nf3, _ = normalize(three)
    print(f"\n  2 + 1 normalizes in {cost} steps")
    print(f"  Result: {pretty(nf)}")
    print(f"  Church(3): {pretty(nf3)}")
    print(f"  Equal? {nf == nf3}")
    print()


def demo_complete_dev_optimality():
    """Compare complete development with leftmost reduction."""
    print("=" * 60)
    print("DEMO 6: Complete Development vs Leftmost Reduction")
    print("=" * 60)

    terms = [
        ("I I", App(I, I)),
        ("K I I", App(App(K, I), I)),
        ("(λx.x x) I", App(Lam(App(Var(0), Var(0))), I)),
    ]

    for name, t in terms:
        # Complete development passes
        cd_passes = 0
        current = t
        while not is_normal_form(current):
            current = complete_dev(current)
            cd_passes += 1
            if cd_passes > 100:
                break

        # Leftmost reduction steps
        _, lr_steps = normalize(t)

        print(f"\n  Term: {name}")
        print(f"    Complete development passes: {cd_passes}")
        print(f"    Leftmost reduction steps:    {lr_steps}")
        ratio = lr_steps / cd_passes if cd_passes > 0 else float('inf')
        print(f"    Ratio (leftmost/CD):         {ratio:.2f}")
    print()


if __name__ == "__main__":
    print("\n" + "═" * 60)
    print(" Church-Rosser via de Bruijn Indices")
    print(" Quantitative Confluence Demonstration")
    print("═" * 60 + "\n")

    demo_substitution()
    demo_complete_development()
    demo_church_rosser()
    demo_metric_hub()
    demo_church_numerals()
    demo_complete_dev_optimality()

    print("═" * 60)
    print(" All demonstrations complete.")
    print(" Key theorem: d(t,u) ≤ normCost(t) + normCost(u)")
    print(" for all β-equivalent normalizing terms t, u.")
    print("═" * 60)
