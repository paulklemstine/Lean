"""
Applications of Equality Saturation Extraction Correctness.

Demonstrates the theorems in concrete settings:
1. Arithmetic expression optimization
2. Boolean circuit minimization
3. Simple compiler optimization (constant folding + strength reduction)
"""

from __future__ import annotations
from typing import Dict, List, Tuple, Callable
from dataclasses import dataclass
from algorithms import UnionFind, RewriteRule, RewriteSystem, EGraph


# =============================================================================
# Application 1: Arithmetic Expression Optimization
# =============================================================================

def arithmetic_optimization_demo():
    """Demonstrate equality saturation on arithmetic expressions.

    We model expressions as integers in a finite universe where each integer
    represents a specific expression form. The rewrite rules capture algebraic
    identities like commutativity, identity elements, etc.

    Universe (expressions over variable x):
      0: 0         (zero)
      1: 1         (one)
      2: x         (variable)
      3: x + 0     (identity)
      4: 0 + x     (identity, commuted)
      5: x * 1     (identity)
      6: 1 * x     (identity, commuted)
      7: x + x     (doubling)
      8: 2 * x     (doubling, simplified)
      9: x * 2     (doubling, commuted)
    """
    print("=" * 60)
    print("Application 1: Arithmetic Expression Optimization")
    print("=" * 60)

    carrier = list(range(10))
    rules = [
        RewriteRule(3, 2),   # x + 0 → x
        RewriteRule(4, 2),   # 0 + x → x
        RewriteRule(5, 2),   # x * 1 → x
        RewriteRule(6, 2),   # 1 * x → x
        RewriteRule(7, 8),   # x + x → 2*x
        RewriteRule(9, 8),   # x * 2 → 2*x (commutativity)
    ]

    system = RewriteSystem(carrier=carrier, rules=rules)

    # Semantics: evaluate at x = 5
    def eval_at_5(expr_id: int) -> int:
        vals = {0: 0, 1: 1, 2: 5, 3: 5, 4: 5, 5: 5, 6: 5, 7: 10, 8: 10, 9: 10}
        return vals.get(expr_id, -1)

    # Cost: expression size (number of AST nodes)
    def cost(expr_id: int) -> int:
        costs = {0: 1, 1: 1, 2: 1, 3: 3, 4: 3, 5: 3, 6: 3, 7: 3, 8: 3, 9: 3}
        return costs.get(expr_id, 999)

    seeds = [2, 3, 4, 5, 6, 7, 8, 9]
    egraph = EGraph.from_seeds(system, seeds)
    steps = egraph.saturate()

    print(f"\nSaturation completed in {steps} steps")
    print(f"Equivalence classes:")
    for root, members in egraph.get_classes().items():
        names = {
            0: '0', 1: '1', 2: 'x', 3: 'x+0', 4: '0+x',
            5: 'x*1', 6: '1*x', 7: 'x+x', 8: '2*x', 9: 'x*2'
        }
        member_names = [names.get(m, str(m)) for m in sorted(members)]
        print(f"  Class: {{{', '.join(member_names)}}}")

    print(f"\nExtraction results (cheapest representative):")
    for t in seeds:
        extracted = egraph.extract_cheapest(t, cost)
        names = {
            0: '0', 1: '1', 2: 'x', 3: 'x+0', 4: '0+x',
            5: 'x*1', 6: '1*x', 7: 'x+x', 8: '2*x', 9: 'x*2'
        }
        print(f"  {names[t]:>5s} → {names[extracted]:>5s}  "
              f"(eval: {eval_at_5(t)} = {eval_at_5(extracted)}, "
              f"cost: {cost(t)} → {cost(extracted)})")

    # Verify soundness
    print(f"\nSoundness check:")
    for t in seeds:
        extracted = egraph.extract_cheapest(t, cost)
        assert eval_at_5(extracted) == eval_at_5(t), \
            f"Semantic violation for {t}!"
    print("  ✓ All extractions preserve semantics")


# =============================================================================
# Application 2: Boolean Circuit Minimization
# =============================================================================

def boolean_circuit_demo():
    """Demonstrate equality saturation on boolean circuits.

    Universe (boolean expressions over variables a, b):
      0: FALSE     4: a AND b     8: NOT (NOT a)
      1: TRUE      5: b AND a     9: a OR FALSE
      2: a         6: a OR b     10: FALSE OR a
      3: b         7: b OR a     11: a AND TRUE
    """
    print("\n" + "=" * 60)
    print("Application 2: Boolean Circuit Minimization")
    print("=" * 60)

    carrier = list(range(12))
    rules = [
        # Commutativity
        RewriteRule(5, 4),   # b AND a → a AND b
        RewriteRule(7, 6),   # b OR a → a OR b
        # Double negation
        RewriteRule(8, 2),   # NOT(NOT a) → a
        # Identity
        RewriteRule(9, 2),   # a OR FALSE → a
        RewriteRule(10, 2),  # FALSE OR a → a
        RewriteRule(11, 2),  # a AND TRUE → a
    ]

    system = RewriteSystem(carrier=carrier, rules=rules)

    # Semantics: evaluate at a=True, b=False
    def eval_circuit(expr_id: int) -> int:
        a, b = True, False
        vals = {
            0: False, 1: True, 2: a, 3: b,
            4: a and b, 5: b and a, 6: a or b, 7: b or a,
            8: a,  # NOT(NOT a) = a
            9: a,  # a OR FALSE = a
            10: a, # FALSE OR a = a
            11: a, # a AND TRUE = a
        }
        return int(vals.get(expr_id, False))

    # Cost: gate count
    def gate_cost(expr_id: int) -> int:
        costs = {0: 0, 1: 0, 2: 0, 3: 0, 4: 1, 5: 1, 6: 1, 7: 1, 8: 2, 9: 1, 10: 1, 11: 1}
        return costs.get(expr_id, 999)

    seeds = list(range(12))
    egraph = EGraph.from_seeds(system, seeds)
    steps = egraph.saturate()

    print(f"\nSaturation completed in {steps} steps")
    print(f"\nExtraction results (minimum gate count):")
    names = {
        0: 'FALSE', 1: 'TRUE', 2: 'a', 3: 'b',
        4: 'a∧b', 5: 'b∧a', 6: 'a∨b', 7: 'b∨a',
        8: '¬¬a', 9: 'a∨F', 10: 'F∨a', 11: 'a∧T'
    }
    for t in seeds:
        extracted = egraph.extract_cheapest(t, gate_cost)
        print(f"  {names[t]:>8s} → {names[extracted]:>8s}  "
              f"(gates: {gate_cost(t)} → {gate_cost(extracted)})")

    # Verify
    for t in seeds:
        extracted = egraph.extract_cheapest(t, gate_cost)
        assert eval_circuit(extracted) == eval_circuit(t)
    print("  ✓ All extractions preserve boolean semantics")


# =============================================================================
# Application 3: Strength Reduction
# =============================================================================

def strength_reduction_demo():
    """Demonstrate compiler strength reduction via equality saturation.

    Universe (integer expressions over variable n):
      0: 0          4: n * 2       8: n * 4
      1: 1          5: n + n       9: (n + n) + (n + n)
      2: 2          6: n << 1     10: n << 2
      3: n          7: n * 3      11: n + n + n
    """
    print("\n" + "=" * 60)
    print("Application 3: Compiler Strength Reduction")
    print("=" * 60)

    carrier = list(range(12))
    rules = [
        # n * 2 = n + n
        RewriteRule(4, 5),
        # n + n = n << 1
        RewriteRule(5, 6),
        # n * 4 = (n+n) + (n+n)
        RewriteRule(8, 9),
        # (n+n)+(n+n) = n << 2
        RewriteRule(9, 10),
        # n * 3 = n + n + n
        RewriteRule(7, 11),
    ]

    system = RewriteSystem(carrier=carrier, rules=rules)

    # Semantics: evaluate at n = 7
    n = 7
    def eval_expr(expr_id: int) -> int:
        vals = {
            0: 0, 1: 1, 2: 2, 3: n,
            4: n*2, 5: n+n, 6: n<<1,
            7: n*3, 8: n*4, 9: (n+n)+(n+n), 10: n<<2,
            11: n+n+n
        }
        return vals.get(expr_id, -1)

    # Cost: CPU cycles (shifts are cheaper than multiplies)
    def cpu_cost(expr_id: int) -> int:
        costs = {
            0: 0, 1: 0, 2: 0, 3: 0,
            4: 3,   # multiply: 3 cycles
            5: 1,   # add: 1 cycle
            6: 1,   # shift: 1 cycle
            7: 3,   # multiply: 3 cycles
            8: 3,   # multiply: 3 cycles
            9: 2,   # two adds: 2 cycles
            10: 1,  # shift: 1 cycle
            11: 2,  # two adds: 2 cycles
        }
        return costs.get(expr_id, 999)

    seeds = [3, 4, 5, 6, 7, 8, 9, 10, 11]
    egraph = EGraph.from_seeds(system, seeds)
    steps = egraph.saturate()

    print(f"\nSaturation completed in {steps} steps")
    names = {
        0: '0', 1: '1', 2: '2', 3: 'n',
        4: 'n*2', 5: 'n+n', 6: 'n<<1',
        7: 'n*3', 8: 'n*4', 9: '(n+n)+(n+n)', 10: 'n<<2',
        11: 'n+n+n'
    }

    print(f"\nStrength reduction results:")
    for t in seeds:
        extracted = egraph.extract_cheapest(t, cpu_cost)
        print(f"  {names[t]:>12s} → {names[extracted]:>12s}  "
              f"(cycles: {cpu_cost(t)} → {cpu_cost(extracted)}, "
              f"value: {eval_expr(t)})")

    for t in seeds:
        extracted = egraph.extract_cheapest(t, cpu_cost)
        assert eval_expr(extracted) == eval_expr(t)
    print("  ✓ All strength reductions preserve semantics")


if __name__ == '__main__':
    arithmetic_optimization_demo()
    boolean_circuit_demo()
    strength_reduction_demo()


#!/usr/bin/env python3
"""
Interactive Demonstration: Equality Saturation Extraction Correctness

This demo:
1. Generates random convergent rewrite systems
2. Builds bounded e-graphs via saturation
3. Extracts cheapest representatives
4. Compares extracted semantics with original semantics over random finite algebras
5. Prints counterexamples if found
6. Visualizes class merges and extracted costs
7. Tests the bounded completeness conjecture

Usage:
    python demo.py
"""

from __future__ import annotations
import random
import sys
from typing import Dict, List, Optional, Tuple, Callable


# ============================================================================
# Core Data Structures (self-contained, no local imports)
# ============================================================================

class UnionFind:
    """Union-Find with path compression and union by rank."""

    def __init__(self, elements: List[int]):
        self.parent = {x: x for x in elements}
        self.rank = {x: 0 for x in elements}

    def find(self, x: int) -> int:
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x: int, y: int) -> bool:
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True

    def same_class(self, x: int, y: int) -> bool:
        return self.find(x) == self.find(y)

    def get_classes(self) -> Dict[int, List[int]]:
        classes: Dict[int, List[int]] = {}
        for x in self.parent:
            root = self.find(x)
            classes.setdefault(root, []).append(x)
        return classes

    def add(self, x: int):
        if x not in self.parent:
            self.parent[x] = x
            self.rank[x] = 0


class RewriteSystem:
    """A finite rewrite system with rules (source → target)."""

    def __init__(self, carrier: List[int], rules: List[Tuple[int, int]]):
        self.carrier = carrier
        self.rules = rules  # list of (source, target)

    def applies(self, term: int) -> List[int]:
        return [t for s, t in self.rules if s == term]

    def compute_nf(self, term: int, max_steps: int = 1000) -> Optional[int]:
        current = term
        for _ in range(max_steps):
            nexts = self.applies(current)
            if not nexts:
                return current
            current = nexts[0]
        return None


class EGraph:
    """E-graph with bounded saturation and cost-guided extraction."""

    def __init__(self, system: RewriteSystem, seeds: List[int]):
        self.system = system
        self.terms = set(seeds)
        self.uf = UnionFind(list(self.terms))

    def saturate(self, max_depth: int = 100) -> int:
        for step in range(1, max_depth + 1):
            changed = False
            for t in list(self.terms):
                for s, tgt in self.system.rules:
                    if t == s:
                        self.uf.add(tgt)
                        self.terms.add(tgt)
                        if self.uf.union(t, tgt):
                            changed = True
                    if t == tgt:
                        self.uf.add(s)
                        self.terms.add(s)
                        if self.uf.union(t, s):
                            changed = True
            if not changed:
                return step
        return max_depth

    def extract_cheapest(self, term: int, cost_fn: Callable[[int], int]) -> int:
        root = self.uf.find(term)
        classes = self.uf.get_classes()
        members = classes.get(root, [term])
        return min(members, key=cost_fn)

    def same_class(self, a: int, b: int) -> bool:
        if a not in self.uf.parent or b not in self.uf.parent:
            return False
        return self.uf.same_class(a, b)


# ============================================================================
# Random System Generation
# ============================================================================

def generate_convergent_system(n: int, num_rules: int, seed: int) -> RewriteSystem:
    """Generate a random convergent rewrite system.

    Rules always go from higher to lower elements (ensuring termination).
    Confluence is checked; system is regenerated if not confluent.
    """
    rng = random.Random(seed)
    carrier = list(range(n))

    for _ in range(200):
        rules = []
        for _ in range(num_rules):
            source = rng.randint(1, n - 1)
            target = rng.randint(0, source - 1)
            rules.append((source, target))

        system = RewriteSystem(carrier, rules)

        # Check confluence: all elements reachable from same EqvGen class
        # should have same normal form
        nfs = {t: system.compute_nf(t) for t in carrier}
        if any(v is None for v in nfs.values()):
            continue

        # Build equivalence closure
        uf = UnionFind(carrier)
        for s, t in rules:
            uf.union(s, t)

        # Check each class has unique NF
        ok = True
        for members in uf.get_classes().values():
            nf_set = {nfs[m] for m in members}
            if len(nf_set) > 1:
                ok = False
                break
        if ok:
            return system

    return RewriteSystem(carrier, [])


def generate_random_eval(carrier: List[int], output_size: int, seed: int) -> Dict[int, int]:
    """Generate a random evaluation function that respects equivalences."""
    rng = random.Random(seed)
    return {t: rng.randint(0, output_size - 1) for t in carrier}


def make_consistent_eval(
    system: RewriteSystem,
    base_eval: Dict[int, int]
) -> Dict[int, int]:
    """Make an evaluation function consistent with the rewrite system.

    For a sound evaluation, eval(s) = eval(t) whenever s →_R t.
    We enforce this by mapping each term to eval(nf(term)).
    """
    result = {}
    for t in system.carrier:
        nf = system.compute_nf(t)
        if nf is not None and nf in base_eval:
            result[t] = base_eval[nf]
        elif t in base_eval:
            result[t] = base_eval[t]
        else:
            result[t] = 0
    return result


# ============================================================================
# Demo 1: Extraction Soundness Verification
# ============================================================================

def demo_extraction_soundness():
    """Test Theorem 1: extraction_semantics_preserved.

    For random convergent systems, verify that extraction always preserves
    semantics across random evaluation functions.
    """
    print("=" * 70)
    print("DEMO 1: Extraction Soundness Verification")
    print("  (Theorem: extraction_semantics_preserved)")
    print("=" * 70)

    n_systems = 100
    n_evals_per_system = 10
    n_terms_per_test = 20
    violations = 0
    total_tests = 0

    for sys_idx in range(n_systems):
        n = random.randint(8, 20)
        num_rules = random.randint(2, n)
        system = generate_convergent_system(n, num_rules, seed=sys_idx * 1000)

        for eval_idx in range(n_evals_per_system):
            base_eval = generate_random_eval(system.carrier, 5, seed=sys_idx * 100 + eval_idx)
            eval_fn = make_consistent_eval(system, base_eval)
            cost_fn = lambda x: x  # simple cost

            seeds = random.sample(system.carrier, min(n_terms_per_test, n))
            egraph = EGraph(system, seeds)
            egraph.saturate()

            for t in seeds:
                extracted = egraph.extract_cheapest(t, cost_fn)
                total_tests += 1
                if eval_fn.get(extracted, -1) != eval_fn.get(t, -2):
                    violations += 1
                    print(f"  ✗ VIOLATION: system {sys_idx}, "
                          f"eval({t})={eval_fn[t]}, "
                          f"eval(extract({t}))={eval_fn.get(extracted, '?')}")

    print(f"\n  Total tests: {total_tests}")
    print(f"  Violations: {violations}")
    if violations == 0:
        print("  ✓ ALL TESTS PASSED — extraction preserves semantics")
    else:
        print(f"  ✗ {violations} VIOLATIONS FOUND")
    print()


# ============================================================================
# Demo 2: Cost Optimality Verification
# ============================================================================

def demo_cost_optimality():
    """Test Theorem 2: cheapest_extraction_sound_and_optimal.

    Verify that extracted terms are always cheapest in their class.
    """
    print("=" * 70)
    print("DEMO 2: Cost Optimality Verification")
    print("  (Theorem: cheapest_extraction_sound_and_optimal)")
    print("=" * 70)

    n_systems = 100
    violations = 0
    total_tests = 0
    total_savings = 0

    for sys_idx in range(n_systems):
        n = random.randint(8, 20)
        num_rules = random.randint(2, n)
        system = generate_convergent_system(n, num_rules, seed=sys_idx * 2000)

        rng = random.Random(sys_idx * 3000)
        cost_fn_dict = {t: rng.randint(1, 100) for t in system.carrier}
        cost_fn = lambda x, d=cost_fn_dict: d.get(x, 999)

        seeds = system.carrier[:]
        egraph = EGraph(system, seeds)
        egraph.saturate()

        classes = egraph.uf.get_classes()
        for root, members in classes.items():
            min_cost = min(cost_fn(m) for m in members)
            for t in members:
                extracted = egraph.extract_cheapest(t, cost_fn)
                total_tests += 1
                if cost_fn(extracted) > min_cost:
                    violations += 1
                else:
                    total_savings += cost_fn(t) - cost_fn(extracted)

    print(f"\n  Total tests: {total_tests}")
    print(f"  Violations: {violations}")
    print(f"  Total cost savings: {total_savings}")
    if violations == 0:
        print("  ✓ ALL TESTS PASSED — extraction is cost-optimal")
    else:
        print(f"  ✗ {violations} VIOLATIONS FOUND")
    print()


# ============================================================================
# Demo 3: Normal Form Agreement
# ============================================================================

def demo_nf_agreement():
    """Test Theorem 3: extraction_agrees_with_quotient_nf_semantically.

    Verify that extraction agrees with normal-form computation semantically.
    """
    print("=" * 70)
    print("DEMO 3: Normal Form Agreement")
    print("  (Theorem: extraction_agrees_with_quotient_nf_semantically)")
    print("=" * 70)

    n_systems = 100
    violations = 0
    total_tests = 0

    for sys_idx in range(n_systems):
        n = random.randint(8, 20)
        num_rules = random.randint(2, n)
        system = generate_convergent_system(n, num_rules, seed=sys_idx * 4000)

        base_eval = generate_random_eval(system.carrier, 5, seed=sys_idx * 5000)
        eval_fn = make_consistent_eval(system, base_eval)
        cost_fn = lambda x: x

        seeds = system.carrier[:]
        egraph = EGraph(system, seeds)
        egraph.saturate()

        for t in seeds:
            extracted = egraph.extract_cheapest(t, cost_fn)
            nf = system.compute_nf(t)
            total_tests += 1
            if nf is not None and eval_fn.get(extracted, -1) != eval_fn.get(nf, -2):
                violations += 1
                print(f"  ✗ NF disagreement: system {sys_idx}, t={t}, "
                      f"eval(extract)={eval_fn.get(extracted)}, "
                      f"eval(nf)={eval_fn.get(nf)}")

    print(f"\n  Total tests: {total_tests}")
    print(f"  Violations: {violations}")
    if violations == 0:
        print("  ✓ ALL TESTS PASSED — extraction agrees with NF semantically")
    else:
        print(f"  ✗ {violations} VIOLATIONS FOUND")
    print()


# ============================================================================
# Demo 4: Saturation Depth Analysis (Falsifiable Conjecture)
# ============================================================================

def demo_saturation_depth():
    """Test the bounded completeness conjecture.

    Conjecture: For finite convergent systems with n elements, saturation
    depth grows at most polynomially in n.

    We measure saturation depth for systems of increasing size and check
    whether growth is polynomial or super-polynomial.
    """
    print("=" * 70)
    print("DEMO 4: Saturation Depth Analysis (Bounded Completeness Conjecture)")
    print("=" * 70)
    print()
    print("  Conjecture: saturation depth grows polynomially in carrier size")
    print()

    sizes = [5, 8, 10, 12, 15, 18, 20]
    results: List[Tuple[int, float, float, int]] = []

    for n in sizes:
        depths = []
        num_classes_list = []
        for trial in range(50):
            num_rules = max(2, n // 2)
            system = generate_convergent_system(n, num_rules, seed=n * 10000 + trial)

            seeds = system.carrier[:]
            egraph = EGraph(system, seeds)
            depth = egraph.saturate(max_depth=200)
            depths.append(depth)
            num_classes_list.append(len(egraph.uf.get_classes()))

        avg_depth = sum(depths) / len(depths)
        max_depth = max(depths)
        avg_classes = sum(num_classes_list) / len(num_classes_list)

        results.append((n, avg_depth, avg_classes, max_depth))
        print(f"  n={n:3d}: avg_depth={avg_depth:5.1f}, "
              f"max_depth={max_depth:3d}, "
              f"avg_classes={avg_classes:5.1f}")

    print()
    print("  Depth growth analysis:")
    print("  " + "-" * 50)
    print(f"  {'Size':>6s} {'Avg Depth':>10s} {'Max Depth':>10s} {'Ratio':>10s}")
    print("  " + "-" * 50)
    prev_avg = None
    for n, avg_d, _, max_d in results:
        ratio = f"{avg_d / prev_avg:.2f}" if prev_avg and prev_avg > 0 else "  -"
        print(f"  {n:6d} {avg_d:10.1f} {max_d:10d} {ratio:>10s}")
        prev_avg = avg_d
    print("  " + "-" * 50)
    print()

    # Check if growth is polynomial
    if len(results) >= 3:
        first_size, first_depth = results[0][0], results[0][1]
        last_size, last_depth = results[-1][0], results[-1][1]
        if first_depth > 0 and last_depth > 0 and first_size > 0 and last_size > 0:
            import math
            size_ratio = last_size / first_size
            depth_ratio = last_depth / first_depth if first_depth > 0 else float('inf')
            if depth_ratio > 0 and size_ratio > 1:
                exponent = math.log(depth_ratio) / math.log(size_ratio)
                print(f"  Estimated growth exponent: {exponent:.2f}")
                if exponent <= 3:
                    print("  → CONSISTENT with polynomial growth conjecture")
                else:
                    print("  → POTENTIAL EVIDENCE against polynomial growth")
    print()


# ============================================================================
# Demo 5: Visualization of E-Graph Merges
# ============================================================================

def demo_visualization():
    """Visualize the saturation process: class merges at each step."""
    print("=" * 70)
    print("DEMO 5: E-Graph Saturation Visualization")
    print("=" * 70)
    print()

    n = 10
    rules = [
        (1, 0), (3, 2), (5, 4), (7, 6),
        (8, 2), (9, 4),
    ]
    system = RewriteSystem(list(range(n)), rules)

    seeds = list(range(n))
    egraph = EGraph(system, seeds)

    print("  Initial state: each element in its own class")
    print(f"  Rules: {rules}")
    print()

    for step in range(1, 20):
        changed = False
        for t in list(egraph.terms):
            for s, tgt in egraph.system.rules:
                if t == s:
                    egraph.uf.add(tgt)
                    egraph.terms.add(tgt)
                    if egraph.uf.union(t, tgt):
                        changed = True
                if t == tgt:
                    egraph.uf.add(s)
                    egraph.terms.add(s)
                    if egraph.uf.union(t, s):
                        changed = True

        classes = egraph.uf.get_classes()
        class_strs = [
            "{" + ",".join(str(m) for m in sorted(members)) + "}"
            for members in classes.values()
        ]
        print(f"  Step {step}: {' '.join(sorted(class_strs))}")

        if not changed:
            print(f"\n  Saturated after {step} steps!")
            break

    print()
    cost_fn = lambda x: x * x + 1
    print("  Cost-optimal extraction (cost(x) = x² + 1):")
    for t in range(n):
        ext = egraph.extract_cheapest(t, cost_fn)
        print(f"    {t} → {ext} (cost: {cost_fn(t)} → {cost_fn(ext)})")
    print()


# ============================================================================
# Main
# ============================================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Equality Saturation Extraction Correctness — Interactive Demo  ║")
    print("╠══════════════════════════════════════════════════════════════════╣")
    print("║  Testing the formal theorems computationally:                   ║")
    print("║  1. extraction_semantics_preserved                              ║")
    print("║  2. cheapest_extraction_sound_and_optimal                       ║")
    print("║  3. extraction_agrees_with_quotient_nf_semantically             ║")
    print("║  4. Bounded completeness conjecture                             ║")
    print("║  5. E-graph saturation visualization                            ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_extraction_soundness()
    demo_cost_optimality()
    demo_nf_agreement()
    demo_saturation_depth()
    demo_visualization()

    print("=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)


if __name__ == '__main__':
    main()
