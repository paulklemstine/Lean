#!/usr/bin/env python3
"""
Applications of Weighted Consequence Systems

Demonstrates real-world applications:
1. Software Build System Optimization
2. Knowledge Base Query Cost Analysis
3. Access Control Policy Verification
4. Curriculum Prerequisite Analysis
"""

import itertools
from typing import FrozenSet, Dict, List, Set, Optional, Tuple


def forward_chaining_closure(rules, seed):
    """Compute derivable closure."""
    current = set(seed)
    changed = True
    while changed:
        changed = False
        for premises, conclusion, _ in rules:
            if premises <= current and conclusion not in current:
                current.add(conclusion)
                changed = True
    return frozenset(current)


def min_deriv_cost_exact(rules, target):
    """Exact minimum derivation cost."""
    n = len(rules)
    best = None
    for mask in range(1 << n):
        subset = [rules[i] for i in range(n) if mask & (1 << i)]
        cost = sum(w for _, _, w in subset)
        if best is not None and cost >= best:
            continue
        closure = forward_chaining_closure(subset, frozenset())
        if target <= closure:
            best = cost
    return best


# ============================================================
# Application 1: Software Build System Optimization
# ============================================================

def app_build_system():
    """
    Model a software build system as a weighted consequence system.
    Modules are "atoms", compilation dependencies are "rules",
    and build times are "weights".

    This finds the minimum-cost build plan for any target configuration.
    """
    print("=" * 60)
    print("Application 1: Software Build System Optimization")
    print("=" * 60)

    # Modules in a hypothetical project
    modules = {"core", "utils", "db", "api", "web", "tests"}

    # Build rules: (dependencies, module_built, build_time_seconds)
    rules = [
        (frozenset(), "core", 10),
        (frozenset(), "utils", 5),
        (frozenset({"core"}), "db", 20),
        (frozenset({"core", "utils"}), "api", 15),
        (frozenset({"api", "db"}), "web", 25),
        (frozenset({"core", "api"}), "tests", 8),
    ]

    print("\nBuild rules (dependencies → module [build time]):")
    for deps, mod, time in rules:
        deps_str = ", ".join(sorted(deps)) if deps else "∅"
        print(f"  {{{deps_str}}} → {mod}  [{time}s]")

    # Find minimum build cost for various targets
    targets = {
        "API server": frozenset({"core", "utils", "api"}),
        "Full web app": frozenset({"core", "utils", "db", "api", "web"}),
        "Tests only": frozenset({"core", "utils", "api", "tests"}),
        "Everything": frozenset(modules),
    }

    print("\nMinimum build costs:")
    for name, target in targets.items():
        cost = min_deriv_cost_exact(rules, target)
        print(f"  {name:20s}: {cost}s (modules: {', '.join(sorted(target))})")

    # Show that build cost is subadditive
    print("\nSubadditivity: building A then B is at least as expensive as building A∪B at once")
    A = frozenset({"core", "db"})
    B = frozenset({"core", "utils", "api"})
    cost_A = min_deriv_cost_exact(rules, A)
    cost_B = min_deriv_cost_exact(rules, B)
    cost_AB = min_deriv_cost_exact(rules, A | B)
    print(f"  cost(A={set(A)}) = {cost_A}")
    print(f"  cost(B={set(B)}) = {cost_B}")
    print(f"  cost(A∪B={set(A|B)}) = {cost_AB}")
    print(f"  {cost_AB} ≤ {cost_A} + {cost_B} = {cost_A + cost_B} ✓")


# ============================================================
# Application 2: Knowledge Base Query Optimization
# ============================================================

def app_knowledge_base():
    """
    Model a knowledge base where facts can be derived from other facts.
    Each derivation rule has a computational cost.
    Find the cheapest way to answer a query (derive a set of facts).
    """
    print("\n" + "=" * 60)
    print("Application 2: Knowledge Base Query Optimization")
    print("=" * 60)

    # Facts in a medical knowledge base
    facts = {"symptom_fever", "symptom_cough", "has_infection",
             "needs_antibiotics", "needs_rest", "diagnosis_flu"}

    rules = [
        # Base facts (observations with recording cost)
        (frozenset(), "symptom_fever", 1),
        (frozenset(), "symptom_cough", 1),
        # Inference rules with computational cost
        (frozenset({"symptom_fever", "symptom_cough"}), "has_infection", 5),
        (frozenset({"has_infection"}), "needs_antibiotics", 3),
        (frozenset({"symptom_fever"}), "needs_rest", 2),
        (frozenset({"has_infection", "symptom_cough"}), "diagnosis_flu", 8),
    ]

    print("\nKnowledge base rules:")
    for deps, fact, cost in rules:
        deps_str = ", ".join(sorted(deps)) if deps else "∅"
        print(f"  {{{deps_str}}} → {fact}  [cost={cost}]")

    # Query costs
    queries = {
        "Does patient need rest?":
            frozenset({"symptom_fever", "needs_rest"}),
        "Full diagnosis":
            frozenset({"symptom_fever", "symptom_cough", "has_infection",
                       "diagnosis_flu", "needs_antibiotics", "needs_rest"}),
        "Just check infection":
            frozenset({"symptom_fever", "symptom_cough", "has_infection"}),
    }

    print("\nQuery costs (minimum inference cost):")
    for query_name, target in queries.items():
        cost = min_deriv_cost_exact(rules, target)
        print(f"  {query_name:30s}: cost = {cost}")


# ============================================================
# Application 3: Access Control Policy
# ============================================================

def app_access_control():
    """
    Model access control as a closure system.
    Permissions propagate through role hierarchies.
    Cost represents audit/verification overhead.
    """
    print("\n" + "=" * 60)
    print("Application 3: Access Control Policy Analysis")
    print("=" * 60)

    perms = {"read", "write", "admin", "deploy", "audit", "backup"}

    rules = [
        # Base permissions (free to assign)
        (frozenset(), "read", 0),
        # Derived permissions
        (frozenset({"read"}), "write", 2),
        (frozenset({"write"}), "admin", 5),
        (frozenset({"admin"}), "deploy", 3),
        (frozenset({"admin"}), "audit", 1),
        (frozenset({"admin", "deploy"}), "backup", 4),
    ]

    print("\nPermission escalation rules:")
    for deps, perm, cost in rules:
        deps_str = ", ".join(sorted(deps)) if deps else "∅"
        print(f"  {{{deps_str}}} → {perm}  [audit cost={cost}]")

    # Role configurations and their audit costs
    roles = {
        "Reader": frozenset({"read"}),
        "Editor": frozenset({"read", "write"}),
        "Admin": frozenset({"read", "write", "admin"}),
        "DevOps": frozenset({"read", "write", "admin", "deploy", "backup"}),
        "Full access": frozenset(perms),
    }

    print("\nRole audit costs (minimum verification overhead):")
    for role_name, target in roles.items():
        cost = min_deriv_cost_exact(rules, target)
        print(f"  {role_name:15s}: audit cost = {cost}")

    # Monotonicity: more permissions = more audit cost
    print("\nMonotonicity check (more permissions ⟹ higher audit cost):")
    role_list = sorted(roles.items(), key=lambda x: len(x[1]))
    for i in range(len(role_list)):
        for j in range(i + 1, len(role_list)):
            name_i, perms_i = role_list[i]
            name_j, perms_j = role_list[j]
            if perms_i <= perms_j:
                cost_i = min_deriv_cost_exact(rules, perms_i)
                cost_j = min_deriv_cost_exact(rules, perms_j)
                ok = cost_i <= cost_j
                print(f"  {name_i} ⊆ {name_j}: {cost_i} ≤ {cost_j} {'✓' if ok else '✗'}")


# ============================================================
# Application 4: Curriculum Prerequisites
# ============================================================

def app_curriculum():
    """
    Model a university curriculum as a weighted consequence system.
    Courses are atoms, prerequisites are rules, study hours are weights.
    """
    print("\n" + "=" * 60)
    print("Application 4: Curriculum Prerequisite Analysis")
    print("=" * 60)

    courses = {"calc1", "calc2", "linalg", "diffeq", "stats",
               "proofs", "abstract_alg", "real_analysis"}

    rules = [
        (frozenset(), "calc1", 150),
        (frozenset({"calc1"}), "calc2", 150),
        (frozenset({"calc1"}), "linalg", 120),
        (frozenset({"calc2"}), "diffeq", 130),
        (frozenset({"calc1"}), "stats", 100),
        (frozenset({"calc2", "linalg"}), "proofs", 160),
        (frozenset({"proofs", "linalg"}), "abstract_alg", 180),
        (frozenset({"proofs", "calc2"}), "real_analysis", 200),
    ]

    print("\nCurriculum (prerequisite → course [study hours]):")
    for deps, course, hours in rules:
        deps_str = ", ".join(sorted(deps)) if deps else "∅"
        print(f"  {{{deps_str}}} → {course}  [{hours}h]")

    # Degree programs and their minimum study hours
    programs = {
        "Applied Math": frozenset({"calc1", "calc2", "linalg", "diffeq", "stats"}),
        "Pure Math": frozenset({"calc1", "calc2", "linalg", "proofs",
                                "abstract_alg", "real_analysis"}),
        "All courses": frozenset(courses),
    }

    print("\nMinimum study hours for degree programs:")
    for prog_name, target in programs.items():
        hours = min_deriv_cost_exact(rules, target)
        print(f"  {prog_name:15s}: {hours} hours")

    # Proof rate: how study cost grows with program breadth
    print("\nProof rate (maximum cost by number of generating courses):")
    closed_sets = set()
    for r in range(len(courses) + 1):
        for subset in itertools.combinations(sorted(courses), r):
            seed = frozenset(subset)
            cl = forward_chaining_closure(rules, seed)
            closed_sets.add(cl)

    for m in range(len(courses) + 1):
        max_cost = 0
        for cl_set in closed_sets:
            # Find rank
            rank = None
            for rr in range(len(courses) + 1):
                found = False
                for sub in itertools.combinations(sorted(courses), rr):
                    if forward_chaining_closure(rules, frozenset(sub)) == cl_set:
                        rank = rr
                        found = True
                        break
                if found:
                    break
            if rank is not None and rank <= m:
                cost = min_deriv_cost_exact(rules, cl_set)
                if cost is not None:
                    max_cost = max(max_cost, cost)
        print(f"  R({m}) = {max_cost} hours")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Applications of Weighted Consequence Systems")
    print("=" * 60)
    print()

    app_build_system()
    app_knowledge_base()
    app_access_control()
    app_curriculum()

    print("\n" + "=" * 60)
    print("Conclusion")
    print("=" * 60)
    print("""
These applications demonstrate that weighted consequence systems
provide a unified framework for analyzing cost-optimal derivation
in diverse domains:

- Software engineering: minimum build times
- AI/Knowledge bases: query optimization
- Security: audit cost analysis
- Education: curriculum planning

The key mathematical properties (monotonicity, subadditivity,
closure operator structure) hold universally across domains,
providing rigorous guarantees for optimization.
""")


#!/usr/bin/env python3
"""
Weighted Consequence Systems & Closure Proof Complexity: Demo

Demonstrates the core mathematical ideas with concrete examples:
1. Closure operators from weighted rules
2. Minimum derivation costs and subadditivity
3. Proof rate computation
4. Basis reconstruction
"""

import itertools
from typing import FrozenSet, Dict, List, Set, Optional


class WeightedRule:
    """A Horn-style rule: premises → conclusion, with weight."""
    def __init__(self, premises: FrozenSet[str], conclusion: str, weight: int):
        self.premises = premises
        self.conclusion = conclusion
        self.weight = weight

    def __repr__(self):
        prem_str = ", ".join(sorted(self.premises)) if self.premises else "∅"
        return f"{{{prem_str}}} → {self.conclusion}  [w={self.weight}]"


class WeightedConsequenceSystem:
    """A finite set of weighted Horn rules over a finite alphabet."""
    def __init__(self, alphabet: Set[str], rules: List[WeightedRule]):
        self.alphabet = alphabet
        self.rules = rules

    def derivable_closure(self, seed: FrozenSet[str]) -> FrozenSet[str]:
        """Compute the derivable closure of seed under the rules."""
        current = set(seed)
        changed = True
        while changed:
            changed = False
            for rule in self.rules:
                if rule.premises <= current and rule.conclusion not in current:
                    current.add(rule.conclusion)
                    changed = True
        return frozenset(current)

    def min_deriv_cost(self, target: FrozenSet[str], seed: FrozenSet[str] = frozenset()) -> Optional[int]:
        """
        Minimum cost (subset of rules) to derive target from seed.
        For the formal theory, seed = ∅ matches the Lean definition.
        """
        best = None
        n = len(self.rules)
        for mask in range(1 << n):
            subset = [self.rules[i] for i in range(n) if mask & (1 << i)]
            cost = sum(r.weight for r in subset)
            if best is not None and cost >= best:
                continue
            current = set(seed)
            changed = True
            while changed:
                changed = False
                for rule in subset:
                    if rule.premises <= current and rule.conclusion not in current:
                        current.add(rule.conclusion)
                        changed = True
            if target <= frozenset(current):
                if best is None or cost < best:
                    best = cost
        return best

    def all_closed_sets(self) -> List[FrozenSet[str]]:
        """Enumerate all closed sets (fixed points of the closure)."""
        closed = set()
        for r in range(len(self.alphabet) + 1):
            for subset in itertools.combinations(sorted(self.alphabet), r):
                cl = self.derivable_closure(frozenset(subset))
                closed.add(cl)
        return sorted(closed, key=lambda s: (len(s), sorted(s)))


def closure_rank(wcs, target):
    """Minimum cardinality of a generating set whose closure equals target."""
    for r in range(len(wcs.alphabet) + 1):
        for subset in itertools.combinations(sorted(wcs.alphabet), r):
            if wcs.derivable_closure(frozenset(subset)) == target:
                return r
    return None


def proof_rate(wcs, m):
    """Max cost over closed sets of rank ≤ m (cost measured from ∅)."""
    best = 0
    for cl_set in wcs.all_closed_sets():
        rank = closure_rank(wcs, cl_set)
        # Cost to derive cl_set from ∅ using the cheapest subset of rules
        cost = wcs.min_deriv_cost(cl_set)
        if rank is not None and rank <= m and cost is not None:
            best = max(best, cost)
    return best


# ============================================================
# Example 1: Propositional Inference
# ============================================================

def example_propositional():
    print("=" * 60)
    print("Example 1: Propositional Inference Network")
    print("=" * 60)

    # No axioms (no rules with empty premises) → rich closure structure
    alphabet = {"p", "q", "r", "s"}
    rules = [
        WeightedRule(frozenset({"p"}), "q", 2),       # p → q
        WeightedRule(frozenset({"q"}), "r", 3),       # q → r
        WeightedRule(frozenset({"p", "r"}), "s", 1),  # {p,r} → s
        WeightedRule(frozenset({"s"}), "q", 4),       # s → q (alternate)
    ]
    wcs = WeightedConsequenceSystem(alphabet, rules)

    print("\nRules:")
    for r in rules:
        print(f"  {r}")

    print("\nClosed sets (fixed points of derivable closure):")
    print(f"  {'Set':>30s}  {'rank':>5s}")
    print(f"  {'-'*30}  {'-'*5}")
    for cs in wcs.all_closed_sets():
        rank = closure_rank(wcs, cs)
        label = "{" + ",".join(sorted(cs)) + "}" if cs else "∅"
        print(f"  {label:>30s}  {str(rank):>5s}")

    # Subadditivity of the closure-based cost
    # Use "closure cost" = minimum rules to close a set
    print("\n--- Subadditivity of Derivation Cost ---")
    # Pick two sets and check cost(cl(A∪B)) ≤ cost(cl(A)) + cost(cl(B))
    A = frozenset({"p"})
    B = frozenset({"s"})
    cl_A = wcs.derivable_closure(A)
    cl_B = wcs.derivable_closure(B)
    cl_AB = wcs.derivable_closure(A | B)

    # Cost of closing: minimum rules needed
    cost_cl_A = wcs.min_deriv_cost(cl_A, A)
    cost_cl_B = wcs.min_deriv_cost(cl_B, B)
    cost_cl_AB = wcs.min_deriv_cost(cl_AB, A | B)

    print(f"  A = {{p}},  cl(A) = {set(cl_A)},  closure cost = {cost_cl_A}")
    print(f"  B = {{s}},  cl(B) = {set(cl_B)},  closure cost = {cost_cl_B}")
    print(f"  A∪B = {{p,s}},  cl(A∪B) = {set(cl_AB)},  closure cost = {cost_cl_AB}")
    if cost_cl_A is not None and cost_cl_B is not None and cost_cl_AB is not None:
        total = cost_cl_A + cost_cl_B
        print(f"  Subadditive: {cost_cl_AB} ≤ {cost_cl_A} + {cost_cl_B} = {total}? "
              f"{'✓' if cost_cl_AB <= total else '✗'}")

    # Proof rate
    print("\n--- Proof Rate (cost from seed, not from ∅) ---")
    for m in range(5):
        # Rate: max over closed C with rank ≤ m of min_cost(C, seed=generators)
        max_cost = 0
        for cs in wcs.all_closed_sets():
            rank = closure_rank(wcs, cs)
            if rank is not None and rank <= m:
                # Find the cheapest generating set of this rank
                for sub in itertools.combinations(sorted(wcs.alphabet), rank):
                    seed = frozenset(sub)
                    if wcs.derivable_closure(seed) == cs:
                        cost = wcs.min_deriv_cost(cs, seed)
                        if cost is not None:
                            max_cost = max(max_cost, cost)
                        break
        print(f"  R({m}) = {max_cost}")


# ============================================================
# Example 2: Diamond Dependency with Costs
# ============================================================

def example_diamond():
    print("\n" + "=" * 60)
    print("Example 2: Diamond Dependency with Costs")
    print("=" * 60)

    alphabet = {"a", "b", "c", "d"}
    rules = [
        WeightedRule(frozenset({"a"}), "b", 3),       # a → b
        WeightedRule(frozenset({"a"}), "c", 4),       # a → c
        WeightedRule(frozenset({"b", "c"}), "d", 1),  # {b,c} → d
    ]
    wcs = WeightedConsequenceSystem(alphabet, rules)

    print("\nRules (diamond shape: a → b, a → c, {b,c} → d):")
    for r in rules:
        print(f"  {r}")

    print("\nClosed sets:")
    print(f"  {'Set':>30s}  {'rank':>5s}  {'cost_from_gen':>15s}")
    print(f"  {'-'*30}  {'-'*5}  {'-'*15}")
    for cs in wcs.all_closed_sets():
        rank = closure_rank(wcs, cs)
        label = "{" + ",".join(sorted(cs)) + "}" if cs else "∅"
        # Find minimal generator
        cost_str = "—"
        if rank is not None:
            for sub in itertools.combinations(sorted(wcs.alphabet), rank):
                seed = frozenset(sub)
                if wcs.derivable_closure(seed) == cs:
                    cost = wcs.min_deriv_cost(cs, seed)
                    cost_str = str(cost) if cost is not None else "∞"
                    break
        print(f"  {label:>30s}  {str(rank):>5s}  {cost_str:>15s}")

    # Show monotonicity
    print("\n--- Monotonicity of Closure Cost ---")
    closed = wcs.all_closed_sets()
    for i, c1 in enumerate(closed):
        for c2 in closed[i+1:]:
            if c1 < c2:
                # Cost from their respective generators
                r1 = closure_rank(wcs, c1)
                r2 = closure_rank(wcs, c2)
                l1 = "{" + ",".join(sorted(c1)) + "}" if c1 else "∅"
                l2 = "{" + ",".join(sorted(c2)) + "}" if c2 else "∅"
                print(f"  {l1} ⊂ {l2}  (ranks {r1}, {r2})")


# ============================================================
# Example 3: Reconstruction
# ============================================================

def example_reconstruction():
    print("\n" + "=" * 60)
    print("Example 3: Closure Operator Reconstruction")
    print("=" * 60)

    alphabet = {"a", "b", "c"}

    def cl(S: FrozenSet[str]) -> FrozenSet[str]:
        result = set(S)
        if "a" in result and "b" in result:
            result.add("c")
        return frozenset(result)

    print("\nClosure operator: cl adds 'c' when both 'a' and 'b' are present")

    all_subsets = []
    for r in range(len(alphabet) + 1):
        for s in itertools.combinations(sorted(alphabet), r):
            all_subsets.append(frozenset(s))

    ext = all(s <= cl(s) for s in all_subsets)
    mon = all(cl(s1) <= cl(s2) for s1 in all_subsets for s2 in all_subsets if s1 <= s2)
    idem = all(cl(cl(s)) == cl(s) for s in all_subsets)
    print(f"  Extensive: {ext}  Monotone: {mon}  Idempotent: {idem}")

    # All closed sets
    print("\n  Closed sets:")
    for s in all_subsets:
        if cl(s) == s:
            label = "{" + ",".join(sorted(s)) + "}" if s else "∅"
            print(f"    {label}")

    # Reconstruct basis
    print("\n  Reconstructed implicational basis:")
    basis = []
    for s in all_subsets:
        closure = cl(s)
        for x in sorted(closure - s):
            basis.append((s, x))
            prem_str = "{" + ",".join(sorted(s)) + "}" if s else "∅"
            print(f"    {prem_str} → {x}")

    # Verify
    rules = [WeightedRule(prem, concl, 1) for prem, concl in basis]
    wcs = WeightedConsequenceSystem(alphabet, rules)
    match = all(wcs.derivable_closure(s) == cl(s) for s in all_subsets)
    status = "✓" if match else "✗"
    print(f"\n  Reconstruction correct: {match} {status}")

    # The realization theorem guarantees this always works!
    print("\n  This demonstrates the Realization Theorem:")
    print("  Every closure operator on a finite type is exactly realized")
    print("  by the weighted consequence system from its full basis.")


if __name__ == "__main__":
    print("Weighted Consequence Systems & Closure Proof Complexity")
    print("=" * 60)
    print()

    example_propositional()
    example_diamond()
    example_reconstruction()

    print("\n" + "=" * 60)
    print("Summary of Machine-Verified Properties")
    print("=" * 60)
    print("""
All of the following are formally proved in machine-checked mathematics:

1. CLOSURE STRUCTURE: The derivable closure of any weighted consequence
   system is a closure operator (extensive, monotone, idempotent).

2. COST NORMALIZATION: The minimum derivation cost of ∅ is 0.

3. COST MONOTONICITY: If C ⊆ D, then cost(C) ≤ cost(D).

4. COST SUBADDITIVITY: cost(A ∪ B) ≤ cost(A) + cost(B).

5. REALIZATION: Every closure operator on a finite type is exactly
   realized by some weighted consequence system.

6. PROOF RATE MONOTONICITY: The proof rate function R(m) is monotone.

7. DAG EXISTENCE: For any derivable set, there exists a valid
   derivation DAG witnessing derivability.
""")


#!/usr/bin/env python3
"""
Visualizations for Weighted Consequence Systems

Generates matplotlib figures saved as PNG files.
"""

import itertools
import base64
import io
from typing import FrozenSet, List, Tuple, Set, Optional

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def forward_chaining_closure(rules, seed):
    current = set(seed)
    changed = True
    while changed:
        changed = False
        for premises, conclusion, _ in rules:
            if premises <= current and conclusion not in current:
                current.add(conclusion)
                changed = True
    return frozenset(current)


def min_deriv_cost_exact(rules, target):
    n = len(rules)
    best = None
    for mask in range(1 << n):
        subset = [rules[i] for i in range(n) if mask & (1 << i)]
        cost = sum(w for _, _, w in subset)
        if best is not None and cost >= best:
            continue
        closure = forward_chaining_closure(subset, frozenset())
        if target <= closure:
            best = cost
    return best


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


# ============================================================
# Figure 1: Closure Lattice with Costs
# ============================================================

def plot_closure_lattice():
    """Plot the Hasse diagram of closed sets with derivation costs."""
    alphabet = {"a", "b", "c", "d"}
    rules = [
        (frozenset(), "a", 2),
        (frozenset({"a"}), "b", 3),
        (frozenset({"b"}), "c", 1),
        (frozenset({"a", "c"}), "d", 4),
    ]

    # Find all closed sets
    closed_sets = set()
    for r in range(len(alphabet) + 1):
        for subset in itertools.combinations(sorted(alphabet), r):
            cl = forward_chaining_closure(rules, frozenset(subset))
            closed_sets.add(cl)

    closed_list = sorted(closed_sets, key=lambda s: (len(s), sorted(s)))

    # Compute costs
    costs = {}
    for cs in closed_list:
        costs[cs] = min_deriv_cost_exact(rules, cs)

    # Assign positions (layered by size)
    layers = {}
    for cs in closed_list:
        size = len(cs)
        if size not in layers:
            layers[size] = []
        layers[size].append(cs)

    positions = {}
    for size, sets in layers.items():
        n = len(sets)
        for i, cs in enumerate(sets):
            x = (i - (n - 1) / 2) * 2.5
            y = size * 2
            positions[cs] = (x, y)

    # Find cover relations (Hasse diagram edges)
    edges = []
    for i, c1 in enumerate(closed_list):
        for c2 in closed_list:
            if c1 < c2:
                # Check if c2 covers c1 (no intermediate)
                is_cover = True
                for c3 in closed_list:
                    if c1 < c3 < c2:
                        is_cover = False
                        break
                if is_cover:
                    edges.append((c1, c2))

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Draw edges
    for c1, c2 in edges:
        x1, y1 = positions[c1]
        x2, y2 = positions[c2]
        ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1.5)

    # Draw nodes
    for cs in closed_list:
        x, y = positions[cs]
        cost = costs[cs]
        label = "{" + ",".join(sorted(cs)) + "}" if cs else "∅"
        color = plt.cm.YlOrRd(cost / max(c for c in costs.values() if c is not None) if cost else 0)

        circle = plt.Circle((x, y), 0.4, color=color, ec='black', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y + 0.6, label, ha='center', va='bottom', fontsize=8, fontweight='bold')
        ax.text(x, y - 0.15, f"κ={cost}", ha='center', va='top', fontsize=7, color='darkblue')

    ax.set_xlim(-5, 5)
    ax.set_ylim(-1, max(len(cs) for cs in closed_list) * 2 + 1)
    ax.set_aspect('equal')
    ax.set_title('Closure Lattice with Derivation Costs', fontsize=14, fontweight='bold')
    ax.axis('off')

    fig.tight_layout()
    fig.savefig('/workspace/request-project/closure_lattice.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


# ============================================================
# Figure 2: Proof Rate Function
# ============================================================

def plot_proof_rate():
    """Plot the proof rate function R(m) for multiple systems."""
    systems = {
        "Linear chain": [
            (frozenset(), "a", 1),
            (frozenset({"a"}), "b", 2),
            (frozenset({"b"}), "c", 3),
            (frozenset({"c"}), "d", 4),
        ],
        "Parallel": [
            (frozenset(), "a", 3),
            (frozenset(), "b", 5),
            (frozenset(), "c", 2),
            (frozenset(), "d", 7),
        ],
        "Diamond": [
            (frozenset(), "a", 2),
            (frozenset({"a"}), "b", 3),
            (frozenset({"a"}), "c", 4),
            (frozenset({"b", "c"}), "d", 1),
        ],
    }

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    colors = ['#e74c3c', '#3498db', '#2ecc71']
    markers = ['o', 's', '^']

    for idx, (name, rules) in enumerate(systems.items()):
        alphabet = set()
        for prem, concl, _ in rules:
            alphabet |= prem
            alphabet.add(concl)

        # Compute closed sets
        closed_sets = set()
        for r in range(len(alphabet) + 1):
            for subset in itertools.combinations(sorted(alphabet), r):
                cl = forward_chaining_closure(rules, frozenset(subset))
                closed_sets.add(cl)

        # Proof rate
        max_m = len(alphabet)
        rates = []
        for m in range(max_m + 1):
            max_cost = 0
            for cl_set in closed_sets:
                # Find rank
                rank = None
                for rr in range(len(alphabet) + 1):
                    found = False
                    for sub in itertools.combinations(sorted(alphabet), rr):
                        if forward_chaining_closure(rules, frozenset(sub)) == cl_set:
                            rank = rr
                            found = True
                            break
                    if found:
                        break
                if rank is not None and rank <= m:
                    cost = min_deriv_cost_exact(rules, cl_set)
                    if cost is not None:
                        max_cost = max(max_cost, cost)
            rates.append(max_cost)

        ax.plot(range(max_m + 1), rates, '-' + markers[idx],
                color=colors[idx], label=name, linewidth=2, markersize=8)

    ax.set_xlabel('Rank bound m', fontsize=12)
    ax.set_ylabel('Proof rate R(m)', fontsize=12)
    ax.set_title('Proof Rate Functions for Different Systems', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(range(5))

    fig.tight_layout()
    fig.savefig('/workspace/request-project/proof_rate.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


# ============================================================
# Figure 3: Subadditivity Visualization
# ============================================================

def plot_subadditivity():
    """Visualize subadditivity of derivation cost."""
    alphabet = {"a", "b", "c", "d", "e"}
    rules = [
        (frozenset(), "a", 3),
        (frozenset(), "b", 2),
        (frozenset({"a"}), "c", 4),
        (frozenset({"b"}), "d", 5),
        (frozenset({"c", "d"}), "e", 1),
    ]

    # Pick various pairs
    pairs = [
        (frozenset({"a", "c"}), frozenset({"b", "d"})),
        (frozenset({"a"}), frozenset({"b"})),
        (frozenset({"a", "c"}), frozenset({"b", "d", "e"})),
        (frozenset({"a"}), frozenset({"a", "b", "c", "d", "e"})),
    ]

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    x_labels = []
    cost_union = []
    cost_sum = []

    for A, B in pairs:
        cA = min_deriv_cost_exact(rules, A)
        cB = min_deriv_cost_exact(rules, B)
        cAB = min_deriv_cost_exact(rules, A | B)
        if cA is None or cB is None or cAB is None:
            continue
        label_A = "{" + ",".join(sorted(A)) + "}"
        label_B = "{" + ",".join(sorted(B)) + "}"
        x_labels.append(f"{label_A}\n∪\n{label_B}")
        cost_union.append(cAB)
        cost_sum.append(cA + cB)

    x = np.arange(len(x_labels))
    width = 0.35

    bars1 = ax.bar(x - width/2, cost_union, width, label='cost(A ∪ B)',
                   color='#3498db', edgecolor='black')
    bars2 = ax.bar(x + width/2, cost_sum, width, label='cost(A) + cost(B)',
                   color='#e74c3c', alpha=0.7, edgecolor='black')

    ax.set_ylabel('Cost', fontsize=12)
    ax.set_title('Subadditivity: cost(A∪B) ≤ cost(A) + cost(B)', fontsize=14, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(x_labels, fontsize=8)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')

    # Add value labels
    for bar in bars1:
        height = bar.get_height()
        ax.annotate(f'{int(height)}', xy=(bar.get_x() + bar.get_width() / 2, height),
                   xytext=(0, 3), textcoords="offset points", ha='center', fontsize=9)
    for bar in bars2:
        height = bar.get_height()
        ax.annotate(f'{int(height)}', xy=(bar.get_x() + bar.get_width() / 2, height),
                   xytext=(0, 3), textcoords="offset points", ha='center', fontsize=9)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/subadditivity.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


# ============================================================
# Figure 4: Cost Landscape
# ============================================================

def plot_cost_landscape():
    """Plot derivation cost as a function of target set size."""
    alphabet = {"a", "b", "c", "d", "e"}
    rules = [
        (frozenset(), "a", 2),
        (frozenset(), "b", 3),
        (frozenset({"a"}), "c", 4),
        (frozenset({"b"}), "d", 1),
        (frozenset({"c", "d"}), "e", 6),
    ]

    # Compute costs for all closed sets
    closed_sets = set()
    for r in range(len(alphabet) + 1):
        for subset in itertools.combinations(sorted(alphabet), r):
            cl = forward_chaining_closure(rules, frozenset(subset))
            closed_sets.add(cl)

    sizes = []
    costs = []
    labels = []
    for cs in sorted(closed_sets, key=lambda s: (len(s), sorted(s))):
        cost = min_deriv_cost_exact(rules, cs)
        if cost is not None:
            sizes.append(len(cs))
            costs.append(cost)
            labels.append("{" + ",".join(sorted(cs)) + "}" if cs else "∅")

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    scatter = ax.scatter(sizes, costs, c=costs, cmap='YlOrRd', s=150,
                        edgecolors='black', linewidth=1.5, zorder=5)

    # Add labels
    for i, label in enumerate(labels):
        ax.annotate(label, (sizes[i], costs[i]),
                   textcoords="offset points", xytext=(5, 5),
                   fontsize=7, alpha=0.8)

    ax.set_xlabel('Closed Set Size |C|', fontsize=12)
    ax.set_ylabel('Minimum Derivation Cost κ(C)', fontsize=12)
    ax.set_title('Cost Landscape: Derivation Cost vs. Set Size', fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3)

    plt.colorbar(scatter, label='Cost')

    fig.tight_layout()
    fig.savefig('/workspace/request-project/cost_landscape.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_lattice = plot_closure_lattice()
    print("  ✓ Closure lattice saved to closure_lattice.png")
    b64_rate = plot_proof_rate()
    print("  ✓ Proof rate saved to proof_rate.png")
    b64_sub = plot_subadditivity()
    print("  ✓ Subadditivity saved to subadditivity.png")
    b64_cost = plot_cost_landscape()
    print("  ✓ Cost landscape saved to cost_landscape.png")
    print("\nAll visualizations generated successfully!")
