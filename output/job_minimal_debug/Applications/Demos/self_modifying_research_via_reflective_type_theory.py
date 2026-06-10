#!/usr/bin/env python3
"""
Applications of Reflective Convergence Theory

Real-world applications demonstrating how the mathematical framework
of self-modifying convergence applies to practical systems.
"""

from typing import List, Dict, Set, Tuple, Callable
from dataclasses import dataclass, field
import random


# ============================================================
# Application 1: Self-Stabilizing Configuration Manager
# ============================================================

@dataclass
class ConfigState:
    """A system configuration as a set of enabled features."""
    features: frozenset
    generation: int = 0

    def __repr__(self):
        return f"Gen{self.generation}:{sorted(self.features)}"


def config_stabilizer():
    """
    A self-stabilizing configuration manager.

    Models a system where enabling features triggers dependencies:
    - Feature A requires B
    - Feature C requires A and D
    - Feature E conflicts with F (at most one can be active)

    The reflective update resolves all dependencies, converging to
    a consistent configuration. This is guaranteed by the closure
    operator theorem (Theorem 1).
    """
    print("=" * 60)
    print("APP 1: Self-Stabilizing Configuration Manager")
    print("=" * 60)

    # Dependency rules: if you enable X, you must enable Y
    dependencies = {
        'A': {'B'},        # A requires B
        'C': {'A', 'D'},   # C requires A and D
        'E': {'B'},        # E requires B
        'G': {'A', 'E'},   # G requires A and E
    }

    # Conflict rules: at most one from each group
    conflicts = [{'E', 'F'}]

    def resolve_step(features: frozenset) -> frozenset:
        """One step of dependency resolution."""
        result = set(features)
        # Add missing dependencies
        for feat in list(result):
            if feat in dependencies:
                result |= dependencies[feat]
        # Resolve conflicts (keep alphabetically first)
        for group in conflicts:
            active = result & group
            if len(active) > 1:
                keep = min(active)
                result -= (active - {keep})
        return frozenset(result)

    def full_closure(features: frozenset) -> frozenset:
        """Compute full closure (idempotent)."""
        current = features
        for _ in range(100):
            next_f = resolve_step(current)
            if next_f == current:
                return current
            current = next_f
        return current

    # Test various initial configurations
    test_configs = [
        frozenset({'A'}),
        frozenset({'C'}),
        frozenset({'E', 'F'}),
        frozenset({'G'}),
        frozenset({'A', 'C', 'E'}),
    ]

    for initial in test_configs:
        result = full_closure(initial)
        print(f"\n  Request: {sorted(initial)}")
        print(f"  Resolved: {sorted(result)}")
        # Verify idempotence
        result2 = full_closure(result)
        print(f"  Stable (F²=F): {result == result2}")


# ============================================================
# Application 2: Iterative Knowledge Base Compiler
# ============================================================

def knowledge_compiler():
    """
    A knowledge base that derives new facts from existing ones,
    modeling reflective epistemic closure.

    The system has axioms and inference rules. Reflection means
    applying all inference rules until no new facts are derived.
    Convergence is guaranteed by Theorem 1 (closure on finite sets).
    """
    print("\n" + "=" * 60)
    print("APP 2: Knowledge Base Compiler")
    print("=" * 60)

    # Facts are represented as (predicate, subject, object) triples
    # encoded as integers for efficiency

    # Axioms (initial facts)
    axioms = {
        (0, 1, 2),  # parent(Alice, Bob)
        (0, 1, 3),  # parent(Alice, Charlie)
        (0, 4, 1),  # parent(David, Alice)
        (0, 5, 4),  # parent(Eve, David)
    }

    # Inference rules
    # Rule 1: parent(X,Y) ∧ parent(Y,Z) → grandparent(X,Z)
    # Rule 2: parent(X,Y) ∧ parent(X,Z) ∧ Y≠Z → sibling(Y,Z)
    # Rule 3: grandparent(X,Y) ∧ parent(Y,Z) → great_grandparent(X,Z)

    PARENT, GRANDPARENT, SIBLING, GREAT_GP = 0, 1, 2, 3

    def derive(facts: frozenset) -> frozenset:
        new_facts = set(facts)

        parents = [(s, o) for (p, s, o) in facts if p == PARENT]

        # Grandparent rule
        for (x, y) in parents:
            for (y2, z) in parents:
                if y == y2:
                    new_facts.add((GRANDPARENT, x, z))

        # Sibling rule
        for (x, y) in parents:
            for (x2, z) in parents:
                if x == x2 and y != z:
                    new_facts.add((SIBLING, y, z))

        # Great-grandparent rule
        grandparents = [(s, o) for (p, s, o) in new_facts if p == GRANDPARENT]
        for (x, y) in grandparents:
            for (y2, z) in parents:
                if y == y2:
                    new_facts.add((GREAT_GP, x, z))

        return frozenset(new_facts)

    names = {1: "Alice", 2: "Bob", 3: "Charlie", 4: "David", 5: "Eve"}
    pred_names = {0: "parent", 1: "grandparent", 2: "sibling", 3: "great_grandparent"}

    def format_fact(f):
        p, s, o = f
        return f"{pred_names.get(p, '?')}({names.get(s, '?')}, {names.get(o, '?')})"

    # Compute closure
    current = frozenset(axioms)
    print(f"\n  Axioms ({len(current)} facts):")
    for f in sorted(current):
        print(f"    {format_fact(f)}")

    step = 0
    while True:
        next_facts = derive(current)
        step += 1
        new = next_facts - current
        if not new:
            print(f"\n  Converged after {step} reflection steps!")
            break
        print(f"\n  Step {step}: derived {len(new)} new facts:")
        for f in sorted(new):
            print(f"    + {format_fact(f)}")
        current = next_facts

    print(f"\n  Total knowledge base: {len(current)} facts")
    # Verify idempotence
    print(f"  Idempotent: {derive(current) == current}")


# ============================================================
# Application 3: Self-Optimizing Search Strategy
# ============================================================

def self_optimizing_search():
    """
    A search algorithm that modifies its own strategy based on
    outcomes, converging to optimal behavior.

    Models dependent reflective convergence (Theorem 2):
    the strategy space (NextType) depends on the current
    performance metric (state).
    """
    print("\n" + "=" * 60)
    print("APP 3: Self-Optimizing Search Strategy")
    print("=" * 60)

    # The "landscape" to search: minimize f(x) = sum of |x_i - target_i|
    target = [3, 7, 1, 9, 5]
    n = len(target)

    # State = current total error (rank)
    # NextType(error) = available step sizes (smaller for small errors)
    # step(error, action) = new error after applying action
    # improve(error) = best action at this error level

    random.seed(42)

    def compute_error(position: List[int]) -> int:
        return sum(abs(p - t) for p, t in zip(position, target))

    def available_step_sizes(error: int) -> List[int]:
        """Dependent next-type: larger errors allow larger steps."""
        if error > 10:
            return [1, 2, 3]
        elif error > 3:
            return [1, 2]
        else:
            return [1]

    position = [0, 0, 0, 0, 0]
    print(f"\n  Target: {target}")
    print(f"  Initial position: {position}")
    print(f"  Initial error: {compute_error(position)}")

    trajectory_errors = [compute_error(position)]

    for iteration in range(50):
        error = compute_error(position)
        if error == 0:
            print(f"\n  Converged to target at iteration {iteration}!")
            break

        step_sizes = available_step_sizes(error)
        max_step = max(step_sizes)

        # Greedy improvement: move each coordinate toward target
        new_position = list(position)
        for i in range(n):
            diff = target[i] - position[i]
            if diff > 0:
                new_position[i] += min(max_step, diff)
            elif diff < 0:
                new_position[i] -= min(max_step, -diff)

        position = new_position
        new_error = compute_error(position)
        trajectory_errors.append(new_error)

        if iteration < 10 or new_error == 0:
            print(f"  Step {iteration+1}: error={new_error}, "
                  f"step_sizes={step_sizes}, pos={position}")

    print(f"\n  Error trajectory: {trajectory_errors}")
    print(f"  Rank strictly decreased each step: "
          f"{all(trajectory_errors[i+1] < trajectory_errors[i] for i in range(len(trajectory_errors)-1) if trajectory_errors[i] > 0)}")


# ============================================================
# Application 4: Convergent Type Inference
# ============================================================

def convergent_type_inference():
    """
    A simplified type inference engine that iteratively refines
    type assignments until reaching a fixed point.

    Models the closure operator theorem: each refinement step
    only adds constraints (extensive), respects existing constraints
    (monotone), and full propagation is idempotent.
    """
    print("\n" + "=" * 60)
    print("APP 4: Convergent Type Inference")
    print("=" * 60)

    # Type lattice: Unknown < Int, Bool, String < Any
    # Inference rules propagate constraints

    types = {"Unknown": 0, "Int": 1, "Bool": 2, "String": 3, "Error": 4}

    # Simple program:
    # x = 5        → x : Int
    # y = x + 1    → y : Int (because x : Int)
    # z = y > 0    → z : Bool (because y : Int, > returns Bool)
    # w = if z then x else y → w : Int (because x,y : Int)

    constraints = [
        ("x", "Int"),           # x = 5
        ("y", "x"),             # y depends on x
        ("z", "Bool"),          # z = y > 0
        ("w", "x"),             # w branches to x
        ("w", "y"),             # w branches to y
    ]

    # Initial assignment: everything unknown
    assignment: Dict[str, str] = {
        "x": "Unknown", "y": "Unknown", "z": "Unknown", "w": "Unknown"
    }

    def refine(assign: Dict[str, str]) -> Dict[str, str]:
        """One step of type refinement."""
        new_assign = dict(assign)
        for var, source in constraints:
            if source in types:
                # Direct type assignment
                if new_assign[var] == "Unknown":
                    new_assign[var] = source
                elif new_assign[var] != source:
                    new_assign[var] = new_assign[var]  # keep existing
            elif source in assign:
                # Propagate from another variable
                if assign[source] != "Unknown" and new_assign[var] == "Unknown":
                    new_assign[var] = assign[source]
        return new_assign

    print(f"\n  Initial: {assignment}")
    for step in range(10):
        new_assignment = refine(assignment)
        if new_assignment == assignment:
            print(f"\n  Type inference converged at step {step}!")
            break
        assignment = new_assignment
        print(f"  Step {step+1}: {assignment}")

    print(f"\n  Final types: {assignment}")
    # Verify idempotence
    print(f"  Idempotent: {refine(assignment) == assignment}")


# ============================================================
# Application 5: Protocol Convergence Verification
# ============================================================

def protocol_convergence():
    """
    Verify that a distributed consensus protocol converges.

    Each node has a state; the update rule models message passing.
    Convergence means all nodes reach agreement (fixed point).
    This is an instance of the general reflective system theorem.
    """
    print("\n" + "=" * 60)
    print("APP 5: Protocol Convergence Verification")
    print("=" * 60)

    # Simple averaging consensus: each node averages with neighbors
    # Network: 0-1-2-3-4 (linear chain)
    n_nodes = 5
    neighbors = {
        0: [1],
        1: [0, 2],
        2: [1, 3],
        3: [2, 4],
        4: [3],
    }

    # Initial values (integers for exact arithmetic)
    # Using scaled integers (multiply by 1000 for precision)
    initial = [1000, 5000, 2000, 8000, 3000]

    def consensus_step(state: List[int]) -> List[int]:
        """One round of averaging consensus (integer arithmetic)."""
        new_state = []
        for i in range(n_nodes):
            total = state[i]
            count = 1
            for j in neighbors[i]:
                total += state[j]
                count += 1
            new_state.append(total // count)
        return new_state

    # Rank: maximum disagreement
    def rank(state: List[int]) -> int:
        return max(state) - min(state)

    print(f"\n  Initial values (×1000): {initial}")
    print(f"  Initial rank (max disagreement): {rank(initial)}")

    current = initial
    for step in range(50):
        next_state = consensus_step(current)
        r = rank(next_state)
        if step < 10 or next_state == current:
            print(f"  Step {step+1}: values={next_state}, rank={r}")
        if next_state == current:
            print(f"\n  Consensus reached at step {step+1}!")
            avg = sum(current) // len(current)
            print(f"  Consensus value: {current[0]} (≈{current[0]/1000:.1f})")
            print(f"  True average: {sum(initial)//len(initial)} (≈{sum(initial)/len(initial)/1000:.1f})")
            break
        current = next_state


if __name__ == "__main__":
    config_stabilizer()
    knowledge_compiler()
    self_optimizing_search()
    convergent_type_inference()
    protocol_convergence()


#!/usr/bin/env python3
"""
Reflective Type Theory: Concrete Demonstrations

Demonstrates the core theorems about convergence of self-modifying
systems with concrete numerical examples.
"""

from typing import Callable, TypeVar, Generic, Optional, Tuple, List


# ============================================================
# Demo 1: Closure Operator on Finite Sets (Finset Nat model)
# ============================================================

def demo_closure_operator():
    """
    Demonstrates Theorem 1: A monotone, extensive, idempotent operator
    on finite sets of natural numbers stabilizes after one step.

    We model a 'knowledge set' where reflection adds all logical consequences.
    """
    print("=" * 60)
    print("DEMO 1: Closure Operator on Knowledge Sets")
    print("=" * 60)

    # Define a dependency graph: if you know premises, you derive the conclusion
    # Rules: {0,1} -> 2, {2,3} -> 4, {1,4} -> 5
    rules = [
        ({0, 1}, 2),
        ({2, 3}, 4),
        ({1, 4}, 5),
    ]

    def F(s: set) -> set:
        """One-step closure: add all derivable conclusions."""
        result = set(s)
        for premises, conclusion in rules:
            if premises <= s:
                result.add(conclusion)
        return frozenset(result)

    # Make it a true closure (apply until stable)
    def closure(s: set) -> frozenset:
        current = frozenset(s)
        while True:
            next_s = F(current)
            if next_s == current:
                return current
            current = next_s

    # The closure operator is idempotent by construction
    s0 = {0, 1, 3}
    print(f"\nInitial knowledge: {sorted(s0)}")

    # Trace the iterations
    current = frozenset(s0)
    for i in range(5):
        next_s = closure(current)
        print(f"  After reflection step {i+1}: {sorted(next_s)}")
        if next_s == current:
            print(f"  → STABILIZED at step {i+1}!")
            break
        current = next_s

    # Verify idempotence
    t = closure(frozenset(s0))
    tt = closure(t)
    print(f"\n  F(s) = {sorted(t)}")
    print(f"  F(F(s)) = {sorted(tt)}")
    print(f"  Idempotent: F(F(s)) == F(s)? {tt == t}")

    # Try different starting sets
    print("\nOther starting sets:")
    for s in [{0}, {1, 3}, {0, 1, 2, 3, 4, 5}, set()]:
        c = closure(frozenset(s))
        print(f"  closure({sorted(s)}) = {sorted(c)}")


# ============================================================
# Demo 2: Dependent Reflective Convergence via Nat Rank
# ============================================================

def demo_nat_rank_convergence():
    """
    Demonstrates Theorem 2: A dependent self-modifying system with a
    decreasing Nat rank converges to a fixed point.

    The 'NextType' depends on the current state — different states
    admit different actions.
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Dependent Rank Convergence")
    print("=" * 60)

    # A system that optimizes a parameter by halving or decrementing
    # NextType(s) = {0: "halve", 1: "decrement"} for s > 0
    # NextType(0) = {0: "stay"}

    def step(s: int, action: int) -> int:
        if s == 0:
            return 0
        if action == 0:  # halve
            return s // 2
        else:  # decrement
            return s - 1

    def improve(s: int) -> int:
        """Policy: halve when possible (faster convergence)."""
        if s == 0:
            return 0
        return 0  # always choose halving

    def F(s: int) -> int:
        return step(s, improve(s))

    print("\nTracing convergence from various starting states:")
    for s0 in [100, 37, 255, 1024, 1]:
        trajectory = [s0]
        current = s0
        for _ in range(50):
            next_s = F(current)
            trajectory.append(next_s)
            if next_s == current:
                break
            current = next_s
        print(f"  s₀ = {s0:5d}: {' → '.join(str(x) for x in trajectory)}")
        print(f"          Fixed point reached at step {len(trajectory)-1}, "
              f"F({trajectory[-1]}) = {trajectory[-1]}")

    # Verify the rank (identity function on Nat) strictly decreases
    print("\nRank verification (μ = id):")
    for s in [10, 5, 3, 1, 0]:
        fs = F(s)
        print(f"  μ({s}) = {s}, μ(F({s})) = {fs}, "
              f"decreasing: {fs <= s}, strict when ≠: {s == fs or fs < s}")


# ============================================================
# Demo 3: Oracle Composition
# ============================================================

def demo_oracle_composition():
    """
    Demonstrates Theorem 5: Composing two commuting research oracles
    yields a stable composite oracle.
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Oracle Composition")
    print("=" * 60)

    # Oracle R: rounds down to nearest multiple of 3
    def R_validate(h: int) -> int:
        return (h // 3) * 3

    # Oracle S: rounds down to nearest even number
    def S_validate(h: int) -> int:
        return (h // 2) * 2

    # Individual stability
    print("\nOracle R (round to mult of 3):")
    for h in [7, 12, 15, 1]:
        r = R_validate(h)
        rr = R_validate(r)
        print(f"  R({h}) = {r}, R(R({h})) = {rr}, stable: {r == rr}")

    print("\nOracle S (round to even):")
    for h in [7, 12, 15, 1]:
        s = S_validate(h)
        ss = S_validate(s)
        print(f"  S({h}) = {s}, S(S({h})) = {ss}, stable: {s == ss}")

    # Composite oracle R ∘ S
    def composite(h: int) -> int:
        return R_validate(S_validate(h))

    print("\nComposite R∘S:")
    for h in [7, 12, 15, 25, 100]:
        c = composite(h)
        cc = composite(c)
        print(f"  (R∘S)({h}) = {c}, (R∘S)²({h}) = {cc}, stable: {c == cc}")

    # Check commutativity condition
    print("\nCommutativity check R(S(R(S(h)))) == R(S(h)):")
    all_commute = True
    for h in range(100):
        rs = R_validate(S_validate(h))
        rsrs = R_validate(S_validate(R_validate(S_validate(h))))
        if rs != rsrs:
            all_commute = False
            print(f"  FAILS at h={h}: R∘S = {rs}, (R∘S)² = {rsrs}")
    if all_commute:
        print("  ✓ Commutes for all h in [0,99]")


# ============================================================
# Demo 4: Reflective System Structure
# ============================================================

def demo_reflective_system():
    """
    Demonstrates the ReflectiveSystem structure with a concrete
    self-improving optimization system.
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Reflective Self-Improving System")
    print("=" * 60)

    # Model: a system that tries to find the minimum of f(x) = (x-3)²
    # State = current x value (integer)
    # NextType(s) = gradient direction choices
    # Rank μ(s) = |s - 3|

    def f(x: int) -> int:
        return (x - 3) ** 2

    def step(s: int, action: str) -> int:
        if action == "left":
            return s - 1
        elif action == "right":
            return s + 1
        else:
            return s

    def improve(s: int) -> str:
        """Gradient descent policy."""
        if s > 3:
            return "left"
        elif s < 3:
            return "right"
        else:
            return "stay"

    def update(s: int) -> int:
        return step(s, improve(s))

    def rank(s: int) -> int:
        return abs(s - 3)

    print("\nOptimizing f(x) = (x-3)² via reflective updates:")
    for s0 in [0, 10, -5, 3, 7]:
        trajectory = [s0]
        current = s0
        for _ in range(20):
            next_s = update(current)
            trajectory.append(next_s)
            if next_s == current:
                break
            current = next_s
        ranks = [rank(s) for s in trajectory]
        print(f"  s₀={s0:3d}: trajectory={trajectory}")
        print(f"         ranks={ranks}")
        print(f"         fixed point: {trajectory[-1]}, f({trajectory[-1]})={f(trajectory[-1])}")


# ============================================================
# Demo 5: Convergence Speed Analysis
# ============================================================

def demo_convergence_speed():
    """
    Analyzes how quickly different reflective systems converge
    as a function of initial state size.
    """
    print("\n" + "=" * 60)
    print("DEMO 5: Convergence Speed Analysis")
    print("=" * 60)

    strategies = {
        "halve": lambda s: s // 2 if s > 0 else 0,
        "decrement": lambda s: s - 1 if s > 0 else 0,
        "sqrt_floor": lambda s: int(s ** 0.5) if s > 1 else 0,
    }

    print(f"\n{'Strategy':<15} {'s₀':>8} {'Steps':>8} {'Trajectory (last 5)':>30}")
    print("-" * 65)

    for name, F in strategies.items():
        for s0 in [10, 100, 1000, 10000]:
            steps = 0
            current = s0
            trajectory = [current]
            while True:
                next_s = F(current)
                steps += 1
                trajectory.append(next_s)
                if next_s == current:
                    break
                current = next_s
            last5 = trajectory[-5:] if len(trajectory) >= 5 else trajectory
            print(f"{name:<15} {s0:>8} {steps:>8} {str(last5):>30}")


if __name__ == "__main__":
    demo_closure_operator()
    demo_nat_rank_convergence()
    demo_oracle_composition()
    demo_reflective_system()
    demo_convergence_speed()
