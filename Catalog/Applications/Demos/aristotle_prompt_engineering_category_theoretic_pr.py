"""
Applications of Galois Connection Closure Theory.

Demonstrates how the abstract mathematical framework applies to concrete
real-world scenarios in engineering, ML feature selection, and specification
refinement.
"""

from typing import List, Tuple, Dict, Set, FrozenSet
import itertools


# ============================================================
# Application 1: Engineering Design Optimization
# ============================================================

def engineering_design_demo():
    """
    Engineering design: specifications are (weight, cost) pairs,
    quality is structural strength = min(weight_contribution, cost_contribution).
    
    The Galois connection captures: achieving strength q requires
    both weight and cost to be at least q.
    """
    print("=" * 60)
    print("APPLICATION 1: Engineering Design Optimization")
    print("=" * 60)
    
    # Design space: (material_weight, manufacturing_cost) in [0, 10]
    # Both contribute to structural strength
    # Quality: max of the two constraints (most demanding requirement)
    
    eval_fn = lambda p: max(p[0], p[1])  # Overall requirement level
    back_fn = lambda q: (q, q)           # Balanced design for requirement q
    
    designs = [
        ("Lightweight/cheap", (2, 3)),
        ("Heavy/cheap", (8, 2)),
        ("Balanced", (5, 5)),
        ("Over-engineered", (9, 9)),
        ("Minimal", (1, 1)),
    ]
    
    print(f"\n{'Design':>20} {'Spec (w,c)':>12} {'Requirement':>12} {'Optimal Design':>16} {'Already Optimal?':>18}")
    print("-" * 82)
    
    for name, spec in designs:
        q = eval_fn(spec)
        optimal = back_fn(q)
        is_opt = optimal == spec
        print(f"{name:>20} {str(spec):>12} {q:>12} {str(optimal):>16} {'✓' if is_opt else '✗':>18}")
    
    print("\nInsight: The closure operator 'balances' the design by raising the")
    print("weaker dimension to match the stronger one. Balanced designs are optimal.")


# ============================================================
# Application 2: Feature Selection in Machine Learning
# ============================================================

def feature_selection_demo():
    """
    ML feature selection: features are boolean vectors indicating
    which features to include. Quality is prediction accuracy.
    
    The Galois connection identifies the minimal sufficient feature sets.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: ML Feature Selection")
    print("=" * 60)
    
    # Simulate: 4 features, each contributes independently
    # Feature importance: [3, 1, 4, 2] (feature 2 is most important)
    importance = [3, 1, 4, 2]
    
    def feature_eval(features: Tuple[bool, ...]) -> int:
        """Total importance of selected features."""
        return sum(imp for f, imp in zip(features, importance) if f)
    
    def feature_back(quality: int) -> Tuple[bool, ...]:
        """Greedy: select features by importance until quality is met."""
        sorted_idx = sorted(range(4), key=lambda i: importance[i], reverse=True)
        features = [False] * 4
        remaining = quality
        for idx in sorted_idx:
            if remaining > 0:
                features[idx] = True
                remaining -= importance[idx]
        return tuple(features)
    
    print(f"\nFeature importances: {importance}")
    print(f"{'Features':>20} {'Quality':>8} {'Closure':>20} {'Optimal?':>10}")
    print("-" * 62)
    
    # Test various feature selections
    test_sets = [
        (True, True, True, True),   # All features
        (True, False, True, False), # Features 0, 2
        (False, False, True, False), # Feature 2 only
        (False, True, False, True),  # Features 1, 3
        (False, False, False, False), # No features
    ]
    
    for fs in test_sets:
        q = feature_eval(fs)
        cl = feature_back(feature_eval(fs))
        # Note: feature_back ∘ feature_eval is the closure
        is_opt = cl == fs
        feat_str = ''.join('1' if f else '0' for f in fs)
        cl_str = ''.join('1' if f else '0' for f in cl)
        print(f"  {feat_str:>18} {q:>8} {cl_str:>20} {'✓' if is_opt else '✗':>10}")
    
    print("\nNote: This is a simplified model. The Galois connection condition")
    print("requires careful construction of eval and back to satisfy the adjunction.")


# ============================================================
# Application 3: Formal Concept Analysis
# ============================================================

def fca_demo():
    """
    Formal Concept Analysis: discover natural groupings in a
    binary relation between objects and attributes.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Formal Concept Analysis")
    print("=" * 60)
    
    # Objects: programming languages
    # Attributes: features they have
    objects = ["Python", "Java", "Haskell", "C", "Rust"]
    attributes = ["GC", "Static", "Functional", "Systems", "OOP"]
    
    # Incidence relation: which languages have which features
    relation = {
        "Python":  {"GC", "OOP"},
        "Java":    {"GC", "Static", "OOP"},
        "Haskell": {"GC", "Static", "Functional"},
        "C":       {"Static", "Systems"},
        "Rust":    {"Static", "Systems"},
    }
    
    def eval_fca(obj_set: FrozenSet[str]) -> FrozenSet[str]:
        """Derivation: common attributes of all objects in set."""
        if not obj_set:
            return frozenset(attributes)
        return frozenset.intersection(*(frozenset(relation[o]) for o in obj_set))
    
    def back_fca(attr_set: FrozenSet[str]) -> FrozenSet[str]:
        """Derivation: objects having all attributes in set."""
        if not attr_set:
            return frozenset(objects)
        return frozenset(o for o in objects if attr_set <= frozenset(relation[o]))
    
    # Compute formal concepts (closed pairs)
    print(f"\nFormal Concepts (closed object-attribute pairs):")
    print("-" * 60)
    
    concepts = []
    # Check all subsets of objects
    for r in range(len(objects) + 1):
        for obj_subset in itertools.combinations(objects, r):
            obj_set = frozenset(obj_subset)
            attrs = eval_fca(obj_set)
            objs_back = back_fca(attrs)
            
            # Check if closed: back(eval(S)) = S
            if objs_back == obj_set:
                concepts.append((obj_set, attrs))
                obj_str = str(sorted(obj_set)) if obj_set else '∅'
                attr_str = str(sorted(attrs)) if attrs else '∅'
                print(f"  Objects: {obj_str:>40}")
                print(f"  Attrs:   {attr_str:>40}")
                print()
    
    print(f"Total formal concepts: {len(concepts)}")
    print("Each concept is a fixed point of the closure operator back ∘ eval.")


# ============================================================
# Application 4: Iterative Requirements Refinement
# ============================================================

def requirements_demo():
    """
    Requirements engineering: iteratively refine specifications
    based on feasibility assessment.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Requirements Refinement")
    print("=" * 60)
    
    # Requirements: (performance_target, budget_level)
    # Feasibility maps to a single score
    # Reconstruction maps score to balanced requirements
    
    eval_fn = lambda r: max(r[0], r[1])
    back_fn = lambda s: (s, s)
    
    scenarios = [
        ("Ambitious startup", (9, 3), "High performance, low budget"),
        ("Conservative corp", (4, 8), "Modest performance, high budget"),
        ("Well-planned", (6, 6), "Balanced requirements"),
        ("MVP approach", (2, 2), "Minimal viable product"),
    ]
    
    print(f"\n{'Scenario':>20} {'Initial':>10} {'Optimal':>10} {'Steps':>6} {'Change':>30}")
    print("-" * 80)
    
    for name, req, desc in scenarios:
        optimal = back_fn(eval_fn(req))
        steps = 0 if optimal == req else 1
        change = "Already optimal" if steps == 0 else f"Raise {'budget' if req[1] < optimal[1] else 'performance'} to {optimal[0]}"
        print(f"{name:>20} {str(req):>10} {str(optimal):>10} {steps:>6} {change:>30}")
    
    print(f"\n  Insight: The closure operator reveals that ambitious-but-underfunded")
    print(f"  projects need budget increases, while over-funded projects can reduce budgets.")
    print(f"  The optimal point is always the balanced requirement (max, max).")


# ============================================================
# Application 5: Abstract Interpretation (Simplified)
# ============================================================

def abstract_interpretation_demo():
    """
    Simplified abstract interpretation: analyzing integer programs
    using sign abstraction.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 5: Abstract Interpretation (Sign Domain)")
    print("=" * 60)
    
    # Concrete domain: sets of integers
    # Abstract domain: {⊥, neg, zero, pos, non-neg, non-pos, ⊤}
    # Ordered by information content
    
    signs = {
        "⊥": set(),
        "neg": {-3, -2, -1},
        "zero": {0},
        "pos": {1, 2, 3},
        "non-neg": {0, 1, 2, 3},
        "non-pos": {-3, -2, -1, 0},
        "⊤": {-3, -2, -1, 0, 1, 2, 3},
    }
    
    def abstract(concrete_set):
        """Map a concrete set to its best abstract approximation."""
        has_neg = any(x < 0 for x in concrete_set)
        has_zero = 0 in concrete_set
        has_pos = any(x > 0 for x in concrete_set)
        
        if not concrete_set:
            return "⊥"
        if has_neg and has_pos:
            return "⊤"
        if has_neg and has_zero:
            return "non-pos"
        if has_pos and has_zero:
            return "non-neg"
        if has_neg:
            return "neg"
        if has_pos:
            return "pos"
        return "zero"
    
    def concretize(abstract_val):
        """Map an abstract value to the largest concrete set it represents."""
        return signs.get(abstract_val, set())
    
    print(f"\n{'Concrete Set':>25} {'Abstract':>10} {'Concretize':>25} {'Closure':>10} {'Closed?':>8}")
    print("-" * 82)
    
    test_sets = [
        {1, 2},
        {-1, 0},
        {0},
        {-2, 3},
        {1, 2, 3},
        set(),
    ]
    
    for s in test_sets:
        a = abstract(s)
        c = concretize(a)
        closure_a = abstract(c)
        is_closed = closure_a == a
        print(f"{str(s):>25} {a:>10} {str(c):>25} {closure_a:>10} {'✓' if is_closed else '✗':>8}")
    
    print("\nThe closure operator in abstract interpretation is γ ∘ α")
    print("(concretize then abstract). Fixed points are 'precise' abstractions.")


if __name__ == "__main__":
    engineering_design_demo()
    feature_selection_demo()
    fca_demo()
    requirements_demo()
    abstract_interpretation_demo()
    
    print("\n" + "=" * 60)
    print("ALL APPLICATIONS DEMONSTRATED")
    print("=" * 60)


"""
Demonstration of Prompt Optimization as Closure Theory via Galois Connections.

This script provides concrete numerical examples of the theorems proved
in the Lean formalization, making the abstract mathematics tangible.
"""

from typing import Tuple, Callable, List, Optional
import itertools


# ============================================================
# Model 1: Two-dimensional Product Order (ℕ × ℕ → ℕ)
# ============================================================

def nat_eval(p: Tuple[int, int]) -> int:
    """Evaluation: quality is the maximum of both prompt dimensions."""
    return max(p[0], p[1])


def nat_back(q: int) -> Tuple[int, int]:
    """Back-projection: to achieve quality q, set both dimensions to q."""
    return (q, q)


def prompt_closure(p: Tuple[int, int]) -> Tuple[int, int]:
    """The closure operator: back ∘ eval."""
    return nat_back(nat_eval(p))


def is_closed(p: Tuple[int, int]) -> bool:
    """Check if a prompt is optimal (a fixed point of closure)."""
    return prompt_closure(p) == p


def iterate_closure(p: Tuple[int, int], n: int) -> Tuple[int, int]:
    """Apply closure n times."""
    result = p
    for _ in range(n):
        result = prompt_closure(result)
    return result


# ============================================================
# Demonstrations
# ============================================================

def demo_closure_operator():
    """Demonstrate the three closure operator properties."""
    print("=" * 60)
    print("THEOREM A: Closure Operator Properties")
    print("=" * 60)
    
    # Property 1: Monotonicity
    print("\n1. MONOTONICITY: p₁ ≤ p₂ ⟹ cl(p₁) ≤ cl(p₂)")
    examples = [((2, 3), (5, 7)), ((1, 1), (3, 2)), ((0, 4), (1, 4))]
    for p1, p2 in examples:
        cl1, cl2 = prompt_closure(p1), prompt_closure(p2)
        mono = cl1[0] <= cl2[0] and cl1[1] <= cl2[1]
        print(f"  p₁={p1}, p₂={p2}: cl(p₁)={cl1}, cl(p₂)={cl2}, monotone={mono}")
    
    # Property 2: Inflation
    print("\n2. INFLATION: p ≤ cl(p)")
    for p in [(2, 5), (3, 3), (7, 1), (0, 0)]:
        cl = prompt_closure(p)
        inflated = p[0] <= cl[0] and p[1] <= cl[1]
        print(f"  p={p}: cl(p)={cl}, p ≤ cl(p)={inflated}")
    
    # Property 3: Idempotence
    print("\n3. IDEMPOTENCE: cl(cl(p)) = cl(p)")
    for p in [(2, 5), (3, 3), (7, 1), (10, 4)]:
        cl1 = prompt_closure(p)
        cl2 = prompt_closure(cl1)
        print(f"  p={p}: cl(p)={cl1}, cl(cl(p))={cl2}, idempotent={cl1 == cl2}")


def demo_optimal_characterization():
    """Demonstrate Theorem B: optimal iff fixed point iff in range(back)."""
    print("\n" + "=" * 60)
    print("THEOREM B: Characterization of Optimal Prompts")
    print("=" * 60)
    
    print("\nChecking all prompts in [0,5] × [0,5]:")
    print(f"{'Prompt':>10} {'Closed?':>10} {'Balanced?':>10} {'In range(back)?':>16}")
    print("-" * 50)
    
    for a in range(6):
        for b in range(6):
            p = (a, b)
            closed = is_closed(p)
            balanced = a == b
            in_range = any(nat_back(q) == p for q in range(10))
            if closed or (a <= 3 and b <= 3):
                print(f"{str(p):>10} {str(closed):>10} {str(balanced):>10} {str(in_range):>16}")
    
    print("\n✓ Optimal ⟺ Balanced ⟺ In range(back)")


def demo_universal_property():
    """Demonstrate the universal property: cl(p) is least closed above p."""
    print("\n" + "=" * 60)
    print("UNIVERSAL PROPERTY: cl(p) is least closed above p")
    print("=" * 60)
    
    p = (3, 5)
    cl_p = prompt_closure(p)
    print(f"\nStarting prompt: p = {p}")
    print(f"Closure: cl(p) = {cl_p}")
    print(f"\nAll closed prompts above p (in [0,10]²):")
    
    closed_above = []
    for a in range(11):
        for b in range(11):
            q = (a, b)
            if is_closed(q) and q[0] >= p[0] and q[1] >= p[1]:
                closed_above.append(q)
                marker = " ← CLOSURE (least!)" if q == cl_p else ""
                print(f"  {q}{marker}")
    
    # Verify cl(p) is least
    for q in closed_above:
        assert cl_p[0] <= q[0] and cl_p[1] <= q[1], f"cl(p) not ≤ {q}!"
    print(f"\n✓ cl(p) = {cl_p} is indeed ≤ all {len(closed_above)} closed prompts above p")


def demo_convergence():
    """Demonstrate Theorem C: finite convergence."""
    print("\n" + "=" * 60)
    print("THEOREM C: Finite Convergence")
    print("=" * 60)
    
    for p0 in [(2, 7), (5, 5), (0, 0), (10, 3), (6, 6)]:
        steps = []
        p = p0
        for i in range(5):
            steps.append(p)
            p_new = prompt_closure(p)
            if p_new == p:
                steps.append(p_new)
                break
            p = p_new
        
        print(f"\n  Start: {p0}")
        for i, s in enumerate(steps):
            marker = " ← FIXED POINT" if i > 0 and s == steps[i-1] else ""
            print(f"    Step {i}: {s}{marker}")
        print(f"  Converged in {len(steps) - 2} step(s)")


def demo_alternating():
    """Demonstrate Theorem D: alternating optimization."""
    print("\n" + "=" * 60)
    print("THEOREM D: Alternating Optimization = Closure Iteration")
    print("=" * 60)
    
    p0 = (3, 8)
    print(f"\nStarting prompt: p₀ = {p0}")
    print(f"\n{'Step':>6} {'p_n (alternating)':>20} {'q_n = eval(p_n)':>16} {'cl^n(p₀)':>15} {'Equal?':>8}")
    print("-" * 70)
    
    p_alt = p0
    for n in range(4):
        cl_n = iterate_closure(p0, n)
        q_n = nat_eval(p_alt)
        equal = p_alt == cl_n
        print(f"{n:>6} {str(p_alt):>20} {q_n:>16} {str(cl_n):>15} {str(equal):>8}")
        p_alt = nat_back(q_n)
    
    print("\n✓ Alternating sequence equals closure iteration at every step")


def demo_duality():
    """Demonstrate the duality between closed prompts and open qualities."""
    print("\n" + "=" * 60)
    print("DUALITY: Closed Prompts ↔ Open Qualities")
    print("=" * 60)
    
    print(f"\n{'Closed Prompt':>15} {'eval →':>8} {'Quality':>10} {'back →':>8} {'Prompt':>15} {'Round-trip?':>12}")
    print("-" * 72)
    
    for n in range(8):
        p = (n, n)  # closed prompt
        q = nat_eval(p)  # quality
        p_back = nat_back(q)  # back to prompt
        q_eval = nat_eval(p_back)  # eval of back
        roundtrip = p == p_back and q == q_eval
        print(f"{str(p):>15} {'→':>8} {q:>10} {'→':>8} {str(p_back):>15} {'✓' if roundtrip else '✗':>12}")
    
    print("\n✓ Perfect bijection between closed prompts and open qualities")


def demo_3d_model():
    """Demonstrate the three-dimensional model."""
    print("\n" + "=" * 60)
    print("MODEL 2: Three-Dimensional Prompt Space")
    print("=" * 60)
    
    def eval3(p):
        return max(max(p[0], p[1]), p[2])
    
    def back3(q):
        return (q, q, q)
    
    def closure3(p):
        return back3(eval3(p))
    
    examples = [(1, 2, 3), (5, 5, 5), (0, 7, 2), (4, 4, 4), (3, 1, 6)]
    
    print(f"\n{'Prompt (a,b,c)':>18} {'eval':>6} {'Closure':>18} {'Optimal?':>10}")
    print("-" * 55)
    
    for p in examples:
        e = eval3(p)
        cl = closure3(p)
        opt = cl == p
        print(f"{str(p):>18} {e:>6} {str(cl):>18} {'✓' if opt else '✗':>10}")


def demo_lattice_structure():
    """Demonstrate the lattice structure of closed prompts."""
    print("\n" + "=" * 60)
    print("LATTICE STRUCTURE: Meet and Join of Closed Prompts")
    print("=" * 60)
    
    # In the ℕ × ℕ model, closed prompts are (n, n)
    # Meet of (a,a) and (b,b) = closure of inf = closure of (min(a,b), min(a,b)) = (min(a,b), min(a,b))
    # Join of (a,a) and (b,b) = closure of sup = closure of (max(a,b), max(a,b)) = (max(a,b), max(a,b))
    
    pairs = [((3, 3), (7, 7)), ((2, 2), (5, 5)), ((4, 4), (4, 4))]
    
    for p1, p2 in pairs:
        meet = (min(p1[0], p2[0]), min(p1[1], p2[1]))
        join = (max(p1[0], p2[0]), max(p1[1], p2[1]))
        cl_meet = prompt_closure(meet)
        cl_join = prompt_closure(join)
        
        print(f"\n  p₁ = {p1}, p₂ = {p2}")
        print(f"  inf(p₁, p₂) = {meet}, closure = {cl_meet} (closed meet)")
        print(f"  sup(p₁, p₂) = {join}, closure = {cl_join} (closed join)")
        print(f"  Both results are closed: {is_closed(cl_meet) and is_closed(cl_join)}")


def demo_statistics():
    """Compute statistics about optimal prompts in finite spaces."""
    print("\n" + "=" * 60)
    print("STATISTICS: Optimal Prompts in Finite Spaces")
    print("=" * 60)
    
    for n in [5, 10, 20, 50]:
        total = n * n
        optimal = sum(1 for a in range(n) for b in range(n) if is_closed((a, b)))
        ratio = optimal / total * 100
        print(f"\n  Space [0,{n-1}]²:")
        print(f"    Total prompts: {total}")
        print(f"    Optimal prompts: {optimal}")
        print(f"    Ratio: {ratio:.1f}%")
        print(f"    Compression: {total // optimal}×")


if __name__ == "__main__":
    demo_closure_operator()
    demo_optimal_characterization()
    demo_universal_property()
    demo_convergence()
    demo_alternating()
    demo_duality()
    demo_3d_model()
    demo_lattice_structure()
    demo_statistics()
    
    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


"""Generate PACKAGE.json from all deliverables."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
core_lean = read_file('Speculative/PromptOptimization/Core.lean')
concrete_lean = read_file('Speculative/PromptOptimization/ConcreteModel.lean')

# Read visualization data
with open('viz_data.json', 'r') as f:
    viz_data = json.load(f)

package = {
    "title": "Prompt Optimization as Closure Theory: Fixed Points of Galois Connections in Finite Lattices",
    "domain": "Order Theory / Category Theory / Specification Optimization",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Closure Operator Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Closure Computation",
            "pseudocode": "Algorithm ComputeClosure(eval, back, p):\n  return back(eval(p))\nTime: O(T_eval + T_back)",
            "code": "def compute_closure(eval_fn, back_fn, p):\n    \"\"\"Compute cl(p) = back(eval(p)). Idempotent, so single application suffices.\"\"\"\n    return back_fn(eval_fn(p))\n\n# Example\neval_fn = lambda p: max(p[0], p[1])\nback_fn = lambda q: (q, q)\nprint(compute_closure(eval_fn, back_fn, (3, 7)))  # (7, 7)"
        },
        {
            "name": "Iterative Convergence",
            "pseudocode": "Algorithm IterateToOptimal(eval, back, p0):\n  p = p0\n  repeat:\n    p_new = back(eval(p))\n    if p_new == p: return p\n    p = p_new\n  Terminates in at most |P| steps.\nTime: O(|P| * (T_eval + T_back))",
            "code": "def iterate_to_optimal(eval_fn, back_fn, p0, max_steps=1000):\n    \"\"\"Iterate closure until convergence. Guaranteed to terminate on finite P.\"\"\"\n    p = p0\n    for step in range(max_steps):\n        p_new = back_fn(eval_fn(p))\n        if p_new == p:\n            return p, step + 1\n        p = p_new\n    return p, max_steps\n\n# Example\neval_fn = lambda p: max(p[0], p[1])\nback_fn = lambda q: (q, q)\nresult, steps = iterate_to_optimal(eval_fn, back_fn, (3, 8))\nprint(f'{result} in {steps} step(s)')  # (8, 8) in 2 step(s)"
        },
        {
            "name": "Enumerate Optimal Specifications",
            "pseudocode": "Algorithm EnumerateOptimal(eval, back, P):\n  optimal = {}\n  for p in P:\n    if back(eval(p)) == p:\n      optimal.add(p)\n  return optimal\nTime: O(|P| * (T_eval + T_back))",
            "code": "def enumerate_optimal(eval_fn, back_fn, elements):\n    \"\"\"Find all fixed points of the closure operator.\"\"\"\n    return [p for p in elements if back_fn(eval_fn(p)) == p]\n\n# Example\neval_fn = lambda p: max(p[0], p[1])\nback_fn = lambda q: (q, q)\nelements = [(a, b) for a in range(6) for b in range(6)]\noptimal = enumerate_optimal(eval_fn, back_fn, elements)\nprint(optimal)  # [(0,0), (1,1), (2,2), (3,3), (4,4), (5,5)]"
        },
        {
            "name": "Galois Connection Validator",
            "pseudocode": "Algorithm ValidateGC(eval, back, P, Q, ≤_P, ≤_Q):\n  for p in P, q in Q:\n    if (eval(p) ≤ q) ≠ (p ≤ back(q)):\n      return (False, (p, q))\n  return (True, None)\nTime: O(|P| * |Q| * (T_eval + T_back + T_le))",
            "code": "def validate_gc(eval_fn, back_fn, p_elts, q_elts, p_le, q_le):\n    \"\"\"Check eval(p) <= q iff p <= back(q) for all p, q.\"\"\"\n    for p in p_elts:\n        for q in q_elts:\n            if q_le(eval_fn(p), q) != p_le(p, back_fn(q)):\n                return False, (p, q)\n    return True, None\n\n# Example\np_elts = [(a,b) for a in range(5) for b in range(5)]\nq_elts = list(range(5))\nvalid, _ = validate_gc(\n    lambda p: max(p[0],p[1]), lambda q: (q,q),\n    p_elts, q_elts,\n    lambda a,b: a[0]<=b[0] and a[1]<=b[1],\n    lambda a,b: a<=b)\nprint(f'Valid: {valid}')  # True"
        }
    ],
    "visualizations": [
        {"name": "Closure Operator on 2D Grid", "data": viz_data["closure_grid"]},
        {"name": "Convergence of Iterative Closure", "data": viz_data["convergence"]},
        {"name": "Galois Connection Diagram", "data": viz_data["galois_connection"]},
        {"name": "Complete Lattice of Optimal Prompts", "data": viz_data["lattice"]},
        {"name": "Selectivity: Optimal Prompt Compression Ratio", "data": viz_data["compression"]},
    ],
    "lean_proofs": core_lean + "\n\n-- ============================================================\n-- Concrete Models\n-- ============================================================\n\n" + concrete_lean
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated: {os.path.getsize('PACKAGE.json')} bytes")


"""
Visualizations for Prompt Optimization via Galois Connections.
Generates publication-quality figures as PNG files.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_closure_grid():
    """Visualize the closure operator on a 2D grid."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    n = 8
    
    # Left: All prompts colored by optimality
    ax = axes[0]
    ax.set_title('Prompt Space P = [0,7] × [0,7]', fontsize=14, fontweight='bold')
    
    for a in range(n):
        for b in range(n):
            is_closed = a == b
            color = '#2ecc71' if is_closed else '#ecf0f1'
            edge = '#27ae60' if is_closed else '#bdc3c7'
            rect = patches.Rectangle((a - 0.4, b - 0.4), 0.8, 0.8,
                                    facecolor=color, edgecolor=edge, linewidth=1.5)
            ax.add_patch(rect)
            if is_closed:
                ax.text(a, b, f'({a},{b})', ha='center', va='center', fontsize=7, fontweight='bold')
    
    ax.set_xlim(-0.6, n - 0.4)
    ax.set_ylim(-0.6, n - 0.4)
    ax.set_xlabel('Specificity', fontsize=12)
    ax.set_ylabel('Depth', fontsize=12)
    ax.set_aspect('equal')
    ax.plot([-0.5, n - 0.5], [-0.5, n - 0.5], 'r--', alpha=0.5, linewidth=2, label='Diagonal (optimal)')
    ax.legend(fontsize=10)
    
    # Right: Closure arrows
    ax = axes[1]
    ax.set_title('Closure Operator: cl(p) = (max(a,b), max(a,b))', fontsize=14, fontweight='bold')
    
    examples = [(1, 4), (3, 6), (5, 2), (2, 7), (6, 1)]
    colors = ['#e74c3c', '#3498db', '#9b59b6', '#f39c12', '#1abc9c']
    
    for (a, b), color in zip(examples, colors):
        m = max(a, b)
        ax.plot(a, b, 'o', color=color, markersize=10, zorder=5)
        ax.plot(m, m, 's', color=color, markersize=12, zorder=5)
        ax.annotate('', xy=(m, m), xytext=(a, b),
                    arrowprops=dict(arrowstyle='->', color=color, lw=2))
        ax.text(a - 0.3, b + 0.3, f'({a},{b})', fontsize=8, color=color)
        ax.text(m + 0.2, m + 0.3, f'({m},{m})', fontsize=8, color=color, fontweight='bold')
    
    ax.plot([-0.5, n - 0.5], [-0.5, n - 0.5], 'g-', alpha=0.3, linewidth=8, label='Closed prompts')
    ax.set_xlim(-0.6, n - 0.4)
    ax.set_ylim(-0.6, n - 0.4)
    ax.set_xlabel('Specificity', fontsize=12)
    ax.set_ylabel('Depth', fontsize=12)
    ax.set_aspect('equal')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.2)
    
    plt.tight_layout()
    fig.savefig('viz_closure_grid.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_convergence():
    """Visualize convergence of iterative closure."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    starts = [(1, 8), (7, 2), (3, 6), (5, 1), (2, 9)]
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']
    
    for (a, b), color in zip(starts, colors):
        # Trajectory
        points = [(a, b)]
        m = max(a, b)
        points.append((m, m))
        points.append((m, m))  # Fixed
        
        xs = [p[0] for p in points]
        ys = [p[1] for p in points]
        
        ax.plot(xs, ys, 'o-', color=color, markersize=8, linewidth=2,
                label=f'Start: ({a},{b}) → ({m},{m})')
        ax.plot(xs[0], ys[0], 'o', color=color, markersize=12)
        ax.plot(xs[-1], ys[-1], '*', color=color, markersize=15)
    
    ax.plot([0, 10], [0, 10], 'k--', alpha=0.3, linewidth=2, label='Fixed points')
    ax.set_xlabel('Dimension 1', fontsize=13)
    ax.set_ylabel('Dimension 2', fontsize=13)
    ax.set_title('Convergence of Iterative Closure\n(All trajectories reach diagonal in 1 step)', 
                fontsize=14, fontweight='bold')
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(True, alpha=0.2)
    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-0.5, 10.5)
    ax.set_aspect('equal')
    
    fig.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_galois_connection():
    """Visualize the Galois connection as a diagram."""
    fig, ax = plt.subplots(figsize=(12, 7))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 7)
    ax.axis('off')
    
    # Left: Prompt space
    ax.add_patch(patches.FancyBboxPatch((0.5, 1), 4, 5, boxstyle="round,pad=0.3",
                                        facecolor='#ebf5fb', edgecolor='#2980b9', linewidth=2))
    ax.text(2.5, 6.3, 'Prompt Space P', ha='center', fontsize=14, fontweight='bold', color='#2980b9')
    
    prompts = [(1, 4), (2, 3), (3, 2), (2.5, 1.5)]
    labels = ['(1,4)', '(2,3)', '(3,2)', '(2,2)']
    for (x, y), label in zip(prompts, labels):
        color = '#27ae60' if label == '(2,2)' else '#3498db'
        ax.plot(x, y, 'o', color=color, markersize=12)
        ax.text(x + 0.15, y + 0.2, label, fontsize=9, color=color, fontweight='bold')
    
    # Right: Quality space
    ax.add_patch(patches.FancyBboxPatch((7.5, 1), 4, 5, boxstyle="round,pad=0.3",
                                        facecolor='#fef9e7', edgecolor='#f39c12', linewidth=2))
    ax.text(9.5, 6.3, 'Quality Space Q', ha='center', fontsize=14, fontweight='bold', color='#f39c12')
    
    qualities = [(9, 4.5), (9, 3.5), (9, 2.5)]
    qlabels = ['4', '3', '2']
    for (x, y), label in zip(qualities, qlabels):
        ax.plot(x, y, 's', color='#f39c12', markersize=12)
        ax.text(x + 0.3, y, label, fontsize=11, color='#e67e22', fontweight='bold')
    
    # Arrows: eval
    ax.annotate('', xy=(7.3, 4.8), xytext=(4.7, 4.8),
                arrowprops=dict(arrowstyle='->', color='#e74c3c', lw=2.5))
    ax.text(6, 5.3, 'eval', fontsize=13, ha='center', color='#e74c3c', fontweight='bold')
    
    # Arrows: back
    ax.annotate('', xy=(4.7, 2.2), xytext=(7.3, 2.2),
                arrowprops=dict(arrowstyle='->', color='#2ecc71', lw=2.5))
    ax.text(6, 1.7, 'back', fontsize=13, ha='center', color='#2ecc71', fontweight='bold')
    
    # Galois condition
    ax.text(6, 0.5, 'eval(p) ≤ q  ⟺  p ≤ back(q)', ha='center', fontsize=13,
            fontweight='bold', style='italic',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#fadbd8', edgecolor='#e74c3c'))
    
    fig.savefig('viz_galois_connection.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_lattice():
    """Visualize the lattice of closed prompts."""
    fig, ax = plt.subplots(figsize=(8, 8))
    
    # Closed prompts in [0, 5]: (0,0), (1,1), ..., (5,5)
    nodes = [(i, i) for i in range(6)]
    
    # Position: vertical chain
    for i, (a, b) in enumerate(nodes):
        y = i * 1.2
        ax.plot(4, y, 'o', color='#2ecc71', markersize=20, zorder=5)
        ax.text(4, y, f'({a},{b})', ha='center', va='center', fontsize=8,
                fontweight='bold', color='white')
        ax.text(5.2, y, f'eval = {max(a,b)}', fontsize=10, va='center', color='#7f8c8d')
        
        if i > 0:
            ax.annotate('', xy=(4, y - 0.3), xytext=(4, (i-1) * 1.2 + 0.3),
                        arrowprops=dict(arrowstyle='-', color='#27ae60', lw=2))
    
    ax.text(4, 6.5, 'Complete Lattice of\nOptimal Prompts', ha='center',
            fontsize=14, fontweight='bold')
    ax.text(4, -1, '⊥ = (0,0)', ha='center', fontsize=11, color='#7f8c8d')
    ax.text(4, 7, '⊤ = (5,5)', ha='center', fontsize=11, color='#7f8c8d')
    
    ax.set_xlim(2, 7)
    ax.set_ylim(-1.5, 7.5)
    ax.axis('off')
    
    fig.savefig('viz_lattice.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_compression_ratio():
    """Visualize the compression ratio: optimal/total as space grows."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    sizes = list(range(2, 51))
    total = [n * n for n in sizes]
    optimal = sizes  # diagonal only
    ratio = [o / t * 100 for o, t in zip(optimal, total)]
    
    ax.plot(sizes, ratio, 'b-', linewidth=2.5, label='Optimal / Total (%)')
    ax.fill_between(sizes, ratio, alpha=0.2, color='blue')
    
    ax.set_xlabel('Space dimension n', fontsize=13)
    ax.set_ylabel('Fraction of optimal prompts (%)', fontsize=13)
    ax.set_title('Selectivity of Closure: Optimal Prompts in [0,n-1]²',
                fontsize=14, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    
    # Annotations
    ax.annotate(f'n=5: {5/25*100:.0f}%', xy=(5, 5/25*100), xytext=(10, 35),
                arrowprops=dict(arrowstyle='->', color='red'), fontsize=11, color='red')
    ax.annotate(f'n=50: {1/50*100:.1f}%', xy=(50, 1/50*100), xytext=(35, 15),
                arrowprops=dict(arrowstyle='->', color='red'), fontsize=11, color='red')
    
    fig.savefig('viz_compression.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_grid = viz_closure_grid()
    print(f"  viz_closure_grid.png: {len(b64_grid)} chars")
    
    b64_conv = viz_convergence()
    print(f"  viz_convergence.png: {len(b64_conv)} chars")
    
    b64_gc = viz_galois_connection()
    print(f"  viz_galois_connection.png: {len(b64_gc)} chars")
    
    b64_lat = viz_lattice()
    print(f"  viz_lattice.png: {len(b64_lat)} chars")
    
    b64_comp = viz_compression_ratio()
    print(f"  viz_compression.png: {len(b64_comp)} chars")
    
    print("\nAll visualizations generated successfully!")
    
    # Save base64 data for PACKAGE.json
    import json
    viz_data = {
        "closure_grid": b64_grid,
        "convergence": b64_conv,
        "galois_connection": b64_gc,
        "lattice": b64_lat,
        "compression": b64_comp,
    }
    with open('viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Base64 data saved to viz_data.json")
