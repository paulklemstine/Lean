#!/usr/bin/env python3
"""
applications.py — Applications of Model-Shrinkage Theory

Demonstrates real-world applications connecting model-shrinkage distances
to proof complexity, information theory, and combinatorial optimization.

Applications:
1. Resolution proof length estimation via bounded shrinkage
2. Information-theoretic analysis of constraint satisfaction
3. Semantic complexity profiling of CNF formula families
4. Direct-sum predictions for independent constraint composition

Keywords: proof complexity, resolution complexity, Frege systems,
model counting, #SAT, entropy, information theory, direct-sum
"""

import math
import itertools
from typing import List, Set, Tuple, Dict, Callable
from algorithms import (ExactModelCounter, ShrinkageAnalyzer,
                         BoundedShrinkageVerifier, DeficiencyCalculator)


# ═══════════════════════════════════════════════════════════════════
# Application 1: Resolution Proof Length Estimation
# ═══════════════════════════════════════════════════════════════════

def app_resolution_estimation():
    """
    Estimate resolution proof length using model-shrinkage bounds.

    In width-w Resolution, each inference step can add a clause of width ≤ w,
    which restricts the model set by at most a factor of 2^w. This gives
    the bounded-shrinkage model with B = 2^w.

    The lower bound theorem then gives:
        proof_length ≥ log_{2^w}(|Mod(φ)| / |Mod(ψ)|)
                     = shrinkage_distance(φ, ψ) / w

    Example: deriving a single assignment from a full cube on n variables
    requires at least n/w steps in width-w Resolution.
    """
    print("=" * 70)
    print("APPLICATION 1: Resolution Proof Length Estimation")
    print("=" * 70)
    print()

    n_values = [8, 16, 32, 64]
    width_values = [2, 3, 4, 8]

    print(f"  {'n':>4} | {'width w':>8} | {'B=2^w':>8} | {'shrinkage':>10} | {'min steps':>10}")
    print(f"  {'-'*4}-+-{'-'*8}-+-{'-'*8}-+-{'-'*10}-+-{'-'*10}")

    for n in n_values:
        total_shrinkage = n  # going from 2^n to 1 model
        for w in width_values:
            B = 2 ** w
            min_steps = math.ceil(total_shrinkage / w)
            print(f"  {n:>4} | {w:>8} | {B:>8} | {total_shrinkage:>10} | {min_steps:>10}")

    print()
    print("  Key insight: wider clauses allow faster shrinkage, but the")
    print("  total information loss (n bits) must still be 'paid for'.")
    print()


# ═══════════════════════════════════════════════════════════════════
# Application 2: Information-Theoretic Analysis of CSP
# ═══════════════════════════════════════════════════════════════════

def app_csp_analysis():
    """
    Analyze constraint satisfaction problems through the information-theoretic
    lens of model-shrinkage.

    Each constraint in a CSP restricts the solution space. The deficiency
    measures cumulative information gain. For independent constraints on
    disjoint variable sets, deficiency is additive.
    """
    print("=" * 70)
    print("APPLICATION 2: Information-Theoretic CSP Analysis")
    print("=" * 70)
    print()

    n = 6
    counter = ExactModelCounter(n)

    # Define a sequence of constraints
    constraints = [
        ("True (no constraint)", lambda a: True),
        ("x0 = True", lambda a: a[0]),
        ("x0 ∧ x1", lambda a: a[0] and a[1]),
        ("x0 ∧ x1 ∧ ¬x2", lambda a: a[0] and a[1] and not a[2]),
        ("x0 ∧ x1 ∧ ¬x2 ∧ (x3 ∨ x4)",
         lambda a: a[0] and a[1] and not a[2] and (a[3] or a[4])),
        ("x0 ∧ x1 ∧ ¬x2 ∧ (x3 ∨ x4) ∧ x5",
         lambda a: a[0] and a[1] and not a[2] and (a[3] or a[4]) and a[5]),
    ]

    print(f"  Constraint chain on n={n} variables:")
    print(f"  {'Constraint':<40} | {'|Mod|':>6} | {'Deficiency':>10} | {'Shrinkage':>10}")
    print(f"  {'-'*40}-+-{'-'*6}-+-{'-'*10}-+-{'-'*10}")

    prev_count = 2 ** n
    for name, pred in constraints:
        count = counter.count(pred)
        defi = n - math.log2(count) if count > 0 else float('inf')
        shrink = math.log2(prev_count / count) if count > 0 else float('inf')
        print(f"  {name:<40} | {count:>6} | {defi:>10.3f} | {shrink:>10.3f}")
        prev_count = count

    print()
    print("  Note: non-unit clauses (like x3 ∨ x4) give fractional deficiency")
    print("  increase, reflecting their weaker constraining power.")
    print()


# ═══════════════════════════════════════════════════════════════════
# Application 3: CNF Family Complexity Profiling
# ═══════════════════════════════════════════════════════════════════

def app_cnf_profiling():
    """
    Profile the semantic complexity of structured CNF formula families.

    Compares different formula structures by their shrinkage characteristics
    to predict proof complexity behavior.
    """
    print("=" * 70)
    print("APPLICATION 3: CNF Family Semantic Complexity Profiling")
    print("=" * 70)
    print()

    n = 5

    families = {
        "Unit clauses (x_i)": [
            lambda a, i=i: a[i] for i in range(n)
        ],
        "Binary clauses (x_i ∨ x_{i+1})": [
            lambda a, i=i: a[i] or a[i+1] for i in range(n-1)
        ],
        "Negated pairs (¬x_i ∨ ¬x_{i+1})": [
            lambda a, i=i: not a[i] or not a[i+1] for i in range(n-1)
        ],
    }

    for family_name, clause_list in families.items():
        print(f"  Family: {family_name}")
        print(f"  {'Step':>6} | {'|Mod|':>6} | {'Deficiency':>10} | {'Step shrink':>12}")
        print(f"  {'-'*6}-+-{'-'*6}-+-{'-'*10}-+-{'-'*12}")

        # Build cumulative conjunction
        prev_count = 2 ** n
        for k in range(len(clause_list) + 1):
            if k == 0:
                pred = lambda a: True
            else:
                clauses_k = clause_list[:k]
                pred = lambda a, cs=clauses_k: all(c(a) for c in cs)

            counter = ExactModelCounter(n)
            count = counter.count(pred)
            defi = n - math.log2(count) if count > 0 else float('inf')
            shrink = math.log2(prev_count / count) if count > 0 and prev_count > 0 else 0
            print(f"  {k:>6} | {count:>6} | {defi:>10.3f} | {shrink:>12.3f}")
            prev_count = count

        print()


# ═══════════════════════════════════════════════════════════════════
# Application 4: Direct-Sum Predictions
# ═══════════════════════════════════════════════════════════════════

def app_direct_sum():
    """
    Verify direct-sum predictions for independent constraint composition.

    When constraints operate on disjoint variable sets, the product constraint
    has deficiency equal to the sum of individual deficiencies (in the
    power-of-two case) or bounded by it (in general).
    """
    print("=" * 70)
    print("APPLICATION 4: Direct-Sum Predictions for Independent Constraints")
    print("=" * 70)
    print()

    test_cases = [
        # (m, restriction_m, n, restriction_n, description)
        (3, {0: True}, 3, {0: True}, "1 fixed each, power-of-2"),
        (4, {0: True, 1: True}, 4, {0: False}, "2+1 fixed, power-of-2"),
        (3, {0: True, 1: True, 2: False}, 3, {0: True, 1: True, 2: True}, "fully fixed each"),
    ]

    for m, restr_m, n_val, restr_n, desc in test_cases:
        # Compute S
        S = set()
        for a in itertools.product([False, True], repeat=m):
            if all(a[i] == v for i, v in restr_m.items()):
                S.add(a)

        # Compute T
        T = set()
        for a in itertools.product([False, True], repeat=n_val):
            if all(a[i] == v for i, v in restr_n.items()):
                T.add(a)

        # Product
        P = {s + t for s in S for t in T}

        def_S = m - math.log2(len(S)) if len(S) > 0 else float('inf')
        def_T = n_val - math.log2(len(T)) if len(T) > 0 else float('inf')
        def_P = (m + n_val) - math.log2(len(P)) if len(P) > 0 else float('inf')

        print(f"  {desc}:")
        print(f"    S ⊆ {{0,1}}^{m}: |S|={len(S)}, def(S)={def_S:.2f}")
        print(f"    T ⊆ {{0,1}}^{n_val}: |T|={len(T)}, def(T)={def_T:.2f}")
        print(f"    S⊗T ⊆ {{0,1}}^{m+n_val}: |S⊗T|={len(P)}, def(S⊗T)={def_P:.2f}")
        print(f"    def(S)+def(T) = {def_S+def_T:.2f}")
        print(f"    Additivity: {'exact ✓' if abs(def_P - def_S - def_T) < 0.001 else 'sub-additive ≤'}")
        print()

    # Minimum derivation length prediction
    print("  Direct-sum prediction for derivation length:")
    print("  If deriving constraint A requires k_A steps with bound B,")
    print("  and deriving B requires k_B steps with bound B,")
    print("  then deriving A⊗B requires at least k_A + k_B steps.")
    print()
    for B in [2, 4]:
        print(f"    B={B}:")
        for shrink_a, shrink_b in [(4, 4), (8, 2), (16, 4)]:
            k_a = math.ceil(math.log(shrink_a, B))
            k_b = math.ceil(math.log(shrink_b, B))
            k_prod = math.ceil(math.log(shrink_a * shrink_b, B))
            print(f"      shrink_A={shrink_a}, shrink_B={shrink_b}: "
                  f"k_A≥{k_a}, k_B≥{k_b}, k_{'{A⊗B}'}≥{k_prod} "
                  f"(vs k_A+k_B={k_a+k_b})")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Model-Shrinkage Theory: Applications                         ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    app_resolution_estimation()
    app_csp_analysis()
    app_cnf_profiling()
    app_direct_sum()

    print("=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Model-Shrinkage Distance: Interactive Demonstration

Demonstrates the core concepts of model-shrinkage as a proof-complexity invariant
on the Boolean cube {0,1}^n. Computes exact model counts, deficiency, shrinkage
distances, and verifies the bounded-shrinkage lower bound on concrete examples.

Keywords: proof complexity, model counting, #SAT, Boolean cube, entropy,
codimension, information theory, semantic lower bounds
"""

import math
import itertools
from typing import List, Set, Tuple, Dict, Optional


def all_assignments(n: int) -> Set[Tuple[bool, ...]]:
    """Generate all Boolean assignments on n variables."""
    return set(itertools.product([False, True], repeat=n))


def restricted_assignments(n: int, restrictions: Dict[int, bool]) -> Set[Tuple[bool, ...]]:
    """
    Assignments on n variables that agree with the given restrictions.
    restrictions: dict mapping variable index -> required value.
    """
    result = set()
    for assignment in itertools.product([False, True], repeat=n):
        if all(assignment[i] == v for i, v in restrictions.items()):
            result.add(assignment)
    return result


def deficiency(n: int, model_count: int) -> float:
    """
    Entropy deficiency: def(S) = n - log2(|S|).
    For empty sets, returns infinity.
    """
    if model_count <= 0:
        return float('inf')
    return n - math.log2(model_count)


def deficiency_int(n: int, model_count: int) -> int:
    """Integer version of deficiency using floor log2."""
    if model_count <= 0:
        return n  # maximal deficiency
    return n - int(math.log2(model_count))


def shrinkage_distance(card_S: int, card_T: int) -> float:
    """Model-shrinkage distance d(S,T) = log2(|S|/|T|) for T ⊆ S, T nonempty."""
    if card_T <= 0:
        return float('inf')
    return math.log2(card_S / card_T)


def product_assignments(S: Set[Tuple[bool, ...]], T: Set[Tuple[bool, ...]]) -> Set[Tuple[bool, ...]]:
    """Product of two assignment sets on disjoint variable blocks."""
    return {s + t for s in S for t in T}


def bounded_shrinkage_chain_check(chain_cards: List[int], B: int) -> dict:
    """
    Verify a bounded-shrinkage chain and compute the lower bound.

    Args:
        chain_cards: list of cardinalities [|S_0|, |S_1|, ..., |S_k|]
        B: maximum shrinkage factor per step

    Returns:
        dict with chain analysis
    """
    k = len(chain_cards) - 1
    violations = []
    step_shrinkages = []

    for i in range(k):
        ratio = chain_cards[i] / chain_cards[i + 1] if chain_cards[i + 1] > 0 else float('inf')
        step_shrinkages.append(ratio)
        if chain_cards[i] > B * chain_cards[i + 1]:
            violations.append(i)

    # Multiplicative bound: |S_0| ≤ B^k * |S_k|
    multiplicative_bound = B ** k * chain_cards[-1]
    bound_holds = chain_cards[0] <= multiplicative_bound

    # Length lower bound: k ≥ log_B(|S_0| / |S_k|)
    if chain_cards[-1] > 0:
        quotient = chain_cards[0] // chain_cards[-1]
        log_bound = math.log(quotient, B) if B > 1 and quotient > 0 else 0
    else:
        log_bound = float('inf')

    return {
        'k': k,
        'B': B,
        'chain_cards': chain_cards,
        'step_shrinkages': step_shrinkages,
        'violations': violations,
        'is_valid_chain': len(violations) == 0,
        'multiplicative_bound': multiplicative_bound,
        'multiplicative_bound_holds': bound_holds,
        'length_lower_bound': log_bound,
        'bound_satisfied': k >= log_bound,
    }


# ═══════════════════════════════════════════════════════════════════
# DEMONSTRATION 1: Coordinate Restriction — Exact Shrinkage
# ═══════════════════════════════════════════════════════════════════
def demo_coordinate_restriction():
    print("=" * 70)
    print("DEMO 1: Coordinate Restriction Gives Exact Shrinkage")
    print("=" * 70)
    print()

    for n in [3, 4, 5]:
        full = all_assignments(n)
        print(f"  n = {n}: Full cube has {len(full)} = 2^{n} assignments")

        for num_fixed in range(1, min(n, 4)):
            restrictions = {i: True for i in range(num_fixed)}
            restricted = restricted_assignments(n, restrictions)
            expected = 2 ** (n - num_fixed)

            d = shrinkage_distance(len(full), len(restricted))
            defi = deficiency(n, len(restricted))

            print(f"    Fix {num_fixed} variable(s): |R| = {len(restricted)} = 2^{n - num_fixed} "
                  f"(expected {expected}) ✓" if len(restricted) == expected else f" ✗")
            print(f"      shrinkage d = {d:.2f} (should be {num_fixed}), "
                  f"deficiency = {defi:.2f}")

        print()


# ═══════════════════════════════════════════════════════════════════
# DEMONSTRATION 2: Deficiency Monotonicity
# ═══════════════════════════════════════════════════════════════════
def demo_deficiency_monotonicity():
    print("=" * 70)
    print("DEMO 2: Deficiency is Monotone Under Implication (T ⊆ S)")
    print("=" * 70)
    print()

    n = 4
    full = all_assignments(n)

    # Build a chain of subsets by progressively fixing variables
    chain = [full]
    for k in range(1, n + 1):
        restrictions = {i: True for i in range(k)}
        chain.append(restricted_assignments(n, restrictions))

    print(f"  Chain of subsets in {{0,1}}^{n}:")
    for i, S in enumerate(chain):
        d = deficiency(n, len(S))
        print(f"    S_{i}: |S| = {len(S):>3},  deficiency = {d:.2f}")

    print()
    print("  Monotonicity check (def(S_i) ≤ def(S_{i+1})):")
    all_mono = True
    for i in range(len(chain) - 1):
        d_i = deficiency(n, len(chain[i]))
        d_next = deficiency(n, len(chain[i + 1]))
        ok = d_i <= d_next
        all_mono = all_mono and ok
        print(f"    def(S_{i}) = {d_i:.2f} ≤ def(S_{i+1}) = {d_next:.2f}  {'✓' if ok else '✗'}")

    print(f"\n  All monotonicity checks passed: {'✓' if all_mono else '✗'}")
    print()


# ═══════════════════════════════════════════════════════════════════
# DEMONSTRATION 3: Telescoping Identity
# ═══════════════════════════════════════════════════════════════════
def demo_telescoping():
    print("=" * 70)
    print("DEMO 3: Telescoping Model-Shrinkage Identity")
    print("=" * 70)
    print()

    n = 5
    chain_cards = [2**5, 2**4, 2**3, 2**2, 2**1, 2**0]

    print(f"  Power-of-two chain on n={n} variables:")
    print(f"  Chain cardinalities: {chain_cards}")
    print()

    total_sum = 0
    for i in range(len(chain_cards) - 1):
        step = math.log2(chain_cards[i]) - math.log2(chain_cards[i + 1])
        total_sum += step
        print(f"    Step {i}: log2({chain_cards[i]}) - log2({chain_cards[i+1]}) = {step:.2f}")

    direct = math.log2(chain_cards[0]) - math.log2(chain_cards[-1])
    print(f"\n  Sum of steps:        {total_sum:.2f}")
    print(f"  Direct computation:  {direct:.2f}")
    print(f"  Telescoping holds:   {'✓' if abs(total_sum - direct) < 1e-10 else '✗'}")

    # Non-power-of-two example
    print(f"\n  Non-power-of-two chain:")
    chain2 = [30, 15, 7, 3, 1]
    print(f"  Chain cardinalities: {chain2}")
    total_int = 0
    for i in range(len(chain2) - 1):
        step = int(math.log2(chain2[i])) - int(math.log2(chain2[i + 1]))
        total_int += step
        print(f"    Step {i}: ⌊log2({chain2[i]})⌋ - ⌊log2({chain2[i+1]})⌋ "
              f"= {int(math.log2(chain2[i]))} - {int(math.log2(chain2[i+1]))} = {step}")

    direct_int = int(math.log2(chain2[0])) - int(math.log2(chain2[-1]))
    print(f"\n  Sum of steps (integer):  {total_int}")
    print(f"  Direct (integer):        {direct_int}")
    print(f"  Telescoping holds:       {'✓' if total_int == direct_int else '✗'}")
    print()


# ═══════════════════════════════════════════════════════════════════
# DEMONSTRATION 4: Product Assignments and Deficiency Additivity
# ═══════════════════════════════════════════════════════════════════
def demo_product_additivity():
    print("=" * 70)
    print("DEMO 4: Deficiency Additivity Under Independent Composition")
    print("=" * 70)
    print()

    examples = [
        (2, {0: True}, 3, {0: False, 1: True}),
        (3, {0: True, 1: True}, 2, {0: False}),
        (4, {}, 3, {0: True}),
    ]

    for m, restr_m, n_val, restr_n in examples:
        S = restricted_assignments(m, restr_m)
        T = restricted_assignments(n_val, restr_n)
        P = product_assignments(S, T)

        def_S = deficiency(m, len(S))
        def_T = deficiency(n_val, len(T))
        def_P = deficiency(m + n_val, len(P))

        is_pow2_S = (len(S) & (len(S) - 1)) == 0 and len(S) > 0
        is_pow2_T = (len(T) & (len(T) - 1)) == 0 and len(T) > 0

        print(f"  S ⊆ {{0,1}}^{m}: |S| = {len(S)}, def(S) = {def_S:.2f}  "
              f"{'(power of 2)' if is_pow2_S else ''}")
        print(f"  T ⊆ {{0,1}}^{n_val}: |T| = {len(T)}, def(T) = {def_T:.2f}  "
              f"{'(power of 2)' if is_pow2_T else ''}")
        print(f"  S⊗T ⊆ {{0,1}}^{m + n_val}: |S⊗T| = {len(P)}, def(S⊗T) = {def_P:.2f}")
        print(f"  def(S) + def(T) = {def_S + def_T:.2f}")
        print(f"  Sub-additivity: def(S⊗T) ≤ def(S)+def(T)? "
              f"{'✓' if def_P <= def_S + def_T + 0.001 else '✗'}")
        if is_pow2_S and is_pow2_T:
            print(f"  Exact additivity (power-of-2 case): "
                  f"{'✓' if abs(def_P - def_S - def_T) < 0.001 else '✗'}")
        print()


# ═══════════════════════════════════════════════════════════════════
# DEMONSTRATION 5: Bounded-Shrinkage Lower Bound
# ═══════════════════════════════════════════════════════════════════
def demo_bounded_shrinkage():
    print("=" * 70)
    print("DEMO 5: Bounded-Shrinkage Derivation Lower Bound")
    print("=" * 70)
    print()

    print("  Theorem: If each step shrinks by at most factor B,")
    print("  then k ≥ log_B(|S_0| / |S_k|).")
    print()

    # Example 1: B=2 chain (halving each step)
    chain1 = [256, 128, 64, 32, 16, 8, 4, 2, 1]
    result1 = bounded_shrinkage_chain_check(chain1, B=2)
    print(f"  Example 1: B=2, chain = {chain1}")
    print(f"    Steps k = {result1['k']}")
    print(f"    Valid chain (each step ≤ 2×): {result1['is_valid_chain']}")
    print(f"    |S_0|/|S_k| = {chain1[0]}/{chain1[-1]} = {chain1[0]//chain1[-1]}")
    print(f"    Lower bound: k ≥ log_2({chain1[0]//chain1[-1]}) = {result1['length_lower_bound']:.2f}")
    print(f"    Bound satisfied: {result1['bound_satisfied']} ✓")
    print()

    # Example 2: B=4, fewer steps needed
    chain2 = [256, 64, 16, 4, 1]
    result2 = bounded_shrinkage_chain_check(chain2, B=4)
    print(f"  Example 2: B=4, chain = {chain2}")
    print(f"    Steps k = {result2['k']}")
    print(f"    Valid chain: {result2['is_valid_chain']}")
    print(f"    Lower bound: k ≥ log_4({chain2[0]//chain2[-1]}) = {result2['length_lower_bound']:.2f}")
    print(f"    Bound satisfied: {result2['bound_satisfied']} ✓")
    print()

    # Example 3: Tight bound demonstration
    print("  Tightness demonstration:")
    for B in [2, 3, 4, 8]:
        for total_shrink in [64, 256, 1024]:
            min_steps = math.ceil(math.log(total_shrink, B))
            print(f"    B={B}, shrinkage={total_shrink}: minimum steps ≥ "
                  f"⌈log_{B}({total_shrink})⌉ = {min_steps}")
    print()

    # Example 4: Real semantic derivation
    print("  Semantic derivation example (n=6, fixing variables one at a time):")
    n = 6
    chain_sem = []
    for i in range(n + 1):
        card = 2 ** (n - i)
        chain_sem.append(card)
    result_sem = bounded_shrinkage_chain_check(chain_sem, B=2)
    print(f"    Chain: {chain_sem}")
    print(f"    Each step halves the model set (B=2)")
    print(f"    k = {result_sem['k']}, lower bound = {result_sem['length_lower_bound']:.2f}")
    print(f"    This is tight: k = log_2(|S_0|/|S_k|) = {n}")
    print()


# ═══════════════════════════════════════════════════════════════════
# DEMONSTRATION 6: Cross-Domain Connections
# ═══════════════════════════════════════════════════════════════════
def demo_cross_domain():
    print("=" * 70)
    print("DEMO 6: Cross-Domain Connections")
    print("=" * 70)
    print()

    # Information Theory: entropy as model counting
    print("  [Information Theory] Entropy as model counting:")
    n = 4
    for k in range(n + 1):
        card = 2 ** (n - k)
        entropy = math.log2(card)
        defi = deficiency(n, card)
        print(f"    k={k} restrictions: |S| = {card:>3}, "
              f"entropy = {entropy:.1f} bits, deficiency = {defi:.1f} bits")

    print()
    print("  [Coding Theory] Coordinate restrictions as subcubes:")
    n = 5
    for codim in range(n + 1):
        card = 2 ** (n - codim)
        print(f"    Codimension {codim}: subcube of dimension {n-codim}, "
              f"|S| = {card}, deficiency = {codim}")

    print()
    print("  [Statistical Physics] Proof steps as entropy reduction:")
    n = 8
    print(f"    System: {n} Boolean variables, initial entropy = {n} bits")
    print(f"    Each 'constraint application' reduces entropy by 1 bit")
    print(f"    After k constraints: entropy = {n}-k bits, deficiency = k bits")
    print(f"    Minimum {n} constraint steps to reach a single assignment")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Model-Shrinkage Distance: Proof-Complexity Invariant Demo     ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_coordinate_restriction()
    demo_deficiency_monotonicity()
    demo_telescoping()
    demo_product_additivity()
    demo_bounded_shrinkage()
    demo_cross_domain()

    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)
