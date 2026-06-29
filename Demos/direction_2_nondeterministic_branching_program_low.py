#!/usr/bin/env python3
"""
Applications of Tropical Certificate Complexity.

Demonstrates real-world connections:
1. Hardware verification: detecting minimum-cost test patterns
2. Cryptographic hardness: certificate cost as a one-wayness measure
3. Machine learning: feature importance via tropical weighting
4. Network design: minimum information bottleneck analysis
"""

import itertools
import random
from typing import Callable, Dict, List, Set, Tuple


# ============================================================================
# Application 1: Hardware Verification — Minimum-Cost Test Patterns
# ============================================================================

def hardware_testing_application():
    """
    In hardware testing, we need to find input patterns that detect faults.
    A "stuck-at fault" on wire i means the wire is permanently 0 or 1.

    The tropical certificate framework naturally models this:
    - Variables = controllable inputs
    - Weights = cost of controlling each input (some pins are harder to probe)
    - Certificate = minimum-cost input pattern that guarantees fault detection

    The NBP lower bound tells us: if all detection patterns are expensive,
    then any test-generation algorithm needs substantial resources.
    """
    print("APPLICATION 1: Hardware Verification — Fault Detection Costs")
    print("=" * 60)

    # Example: 4-input circuit with different probe costs
    n = 4
    probe_costs = [1, 3, 5, 10]  # Cost to control each input pin

    # Circuit function: detects stuck-at-0 fault on output
    # (output should be 1 for certain inputs)
    def circuit(x):
        # Simulated circuit: (x0 AND x1) OR (x2 AND x3)
        return (x[0] and x[1]) or (x[2] and x[3])

    # Find minimum-cost test patterns
    min_cost = float('inf')
    best_pattern = None

    for size in range(1, n + 1):
        for dom_tuple in itertools.combinations(range(n), size):
            dom = set(dom_tuple)
            for vals in itertools.product([False, True], repeat=size):
                val = {dom_tuple[i]: vals[i] for i in range(size)}
                # Check if this partial pattern forces output = 1
                forces_true = True
                for x in itertools.product([False, True], repeat=n):
                    if all(x[i] == val[i] for i in dom):
                        if not circuit(x):
                            forces_true = False
                            break
                if forces_true:
                    cost = sum(probe_costs[i] for i in dom)
                    if cost < min_cost:
                        min_cost = cost
                        best_pattern = (dom, val)

    print(f"\nCircuit: (x0 AND x1) OR (x2 AND x3)")
    print(f"Probe costs: {probe_costs}")
    print(f"\nMinimum-cost test pattern for output=1 detection:")
    print(f"  Set pins: {best_pattern[0]}")
    print(f"  Values: {best_pattern[1]}")
    print(f"  Total probe cost: {min_cost}")
    print(f"\nLower bound on test resources: any test generator")
    print(f"  needs at least {min_cost // max(probe_costs)} state variables")


# ============================================================================
# Application 2: Feature Importance in Classification
# ============================================================================

def ml_feature_importance():
    """
    Tropical certificate complexity provides a notion of "feature importance"
    for Boolean classifiers: the minimum cost of features needed to
    guarantee a classification.

    This is related to:
    - SHAP values in explainable AI
    - Sufficient reasons in knowledge compilation
    - Minimum feature sets in feature selection
    """
    print("\n\nAPPLICATION 2: Feature Importance via Tropical Certificates")
    print("=" * 60)

    # Simple classifier: disease diagnosis from symptoms
    # Features: fever(0), cough(1), fatigue(2), rash(3), headache(4)
    n = 5
    feature_names = ["fever", "cough", "fatigue", "rash", "headache"]

    # Diagnostic costs (how expensive each test is)
    test_costs = [2, 1, 1, 5, 3]

    # Simplified diagnosis rule: disease if (fever AND cough) OR (rash)
    def diagnose(x):
        return (x[0] and x[1]) or x[3]

    print(f"\nDiagnosis rule: (fever AND cough) OR rash")
    print(f"Test costs: {dict(zip(feature_names, test_costs))}")

    # Find minimum-cost sufficient explanations for positive diagnosis
    print(f"\nMinimum-cost certificates for positive diagnosis:")

    certificates = []
    for size in range(1, n + 1):
        for dom_tuple in itertools.combinations(range(n), size):
            dom = set(dom_tuple)
            for vals in itertools.product([False, True], repeat=size):
                val = {dom_tuple[i]: vals[i] for i in range(size)}
                forces = True
                for x in itertools.product([False, True], repeat=n):
                    if all(x[i] == val[i] for i in dom):
                        if not diagnose(x):
                            forces = False
                            break
                if forces:
                    cost = sum(test_costs[i] for i in dom)
                    cert_desc = {feature_names[i]: val[i] for i in dom}
                    certificates.append((cost, cert_desc, dom))

    certificates.sort(key=lambda c: c[0])

    for cost, desc, dom in certificates[:5]:
        print(f"  Cost {cost}: {desc}")

    if certificates:
        print(f"\nMinimum tropical certificate cost: {certificates[0][0]}")
        print(f"This is the minimum cost to guarantee a positive diagnosis.")
        print(f"\nIn tropical semiring terms: the optimal 'witness' minimizes")
        print(f"the sum of diagnostic test costs while forcing the diagnosis.")


# ============================================================================
# Application 3: Network Information Bottleneck
# ============================================================================

def network_bottleneck():
    """
    The tropical certificate framework applies to network routing:
    - Nodes = branching program states
    - Edge labels = routing decisions based on input
    - Certificate cost = minimum information needed to route correctly

    A network with few nodes cannot efficiently route inputs that
    require high tropical information content.
    """
    print("\n\nAPPLICATION 3: Network Information Bottleneck Analysis")
    print("=" * 60)

    # Example: routing network for 3-bit addresses
    n = 3
    bandwidth_costs = [4, 2, 1]  # Cost of each address bit

    # Routing function: route to destination if address matches
    # destination[target] = 1
    def route_to(target):
        def f(x):
            return x[target]
        return f

    print(f"\nRouting network: {n}-bit addresses")
    print(f"Bandwidth costs per bit: {bandwidth_costs}")

    for target in range(n):
        f = route_to(target)
        min_cost = float('inf')
        for dom_size in range(1, n + 1):
            for dom_tuple in itertools.combinations(range(n), dom_size):
                dom = set(dom_tuple)
                for vals in itertools.product([False, True], repeat=dom_size):
                    val = {dom_tuple[i]: vals[i] for i in range(dom_size)}
                    forces = True
                    for x in itertools.product([False, True], repeat=n):
                        if all(x[i] == val[i] for i in dom):
                            if not f(x):
                                forces = False
                                break
                    if forces:
                        cost = sum(bandwidth_costs[i] for i in dom)
                        min_cost = min(min_cost, cost)

        print(f"\n  Route to bit {target}: min certificate cost = {min_cost}")
        print(f"  → Any routing network needs ≥ {min_cost // max(bandwidth_costs)} nodes")

    print(f"\nThe anisotropic weights capture that some address bits")
    print(f"are more 'expensive' to resolve — a natural model for")
    print(f"hierarchical routing with different bandwidth levels.")


# ============================================================================
# Application 4: Cryptographic Hardness Assessment
# ============================================================================

def crypto_hardness():
    """
    Tropical certificate complexity can measure the hardness of
    inverting a Boolean function: if every preimage certificate
    is expensive, inversion requires substantial computation.
    """
    print("\n\nAPPLICATION 4: Cryptographic Function Hardness")
    print("=" * 60)

    n = 4
    # Simulate a "hash-like" function with high certificate complexity
    random.seed(42)
    truth_table = {x: random.choice([True, False])
                   for x in itertools.product([False, True], repeat=n)}

    def random_fn(x):
        return truth_table[x]

    # Compare uniform vs. exponential weights
    w_uniform = [1] * n
    w_exponential = [2**i for i in range(n)]

    accepting = [x for x in itertools.product([False, True], repeat=n)
                 if random_fn(x)]
    print(f"\nRandom function on {n} variables")
    print(f"Accepting inputs: {len(accepting)} / {2**n}")

    for w, name in [(w_uniform, "uniform"), (w_exponential, "exponential")]:
        min_cost = float('inf')
        for size in range(1, n + 1):
            for dom_tuple in itertools.combinations(range(n), size):
                dom = set(dom_tuple)
                for vals in itertools.product([False, True], repeat=size):
                    val = {dom_tuple[i]: vals[i] for i in range(size)}
                    forces = True
                    for x in itertools.product([False, True], repeat=n):
                        if all(x[i] == val[i] for i in dom):
                            if not random_fn(x):
                                forces = False
                                break
                    if forces:
                        cost = sum(w[i] for i in dom)
                        min_cost = min(min_cost, cost)

        print(f"\n  Weights ({name}): {w}")
        print(f"  Min accepting cert cost: {min_cost}")
        print(f"  Max weight: {max(w)}")
        if min_cost != float('inf'):
            print(f"  Linear lower bound: {min_cost // max(w)} states")

    print(f"\nKey insight: exponential weights amplify the difference")
    print(f"between 'easy' and 'hard' variables, giving finer-grained")
    print(f"hardness measures than uniform certificate complexity.")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("TROPICAL CERTIFICATE COMPLEXITY — APPLICATIONS")
    print("=" * 60)

    hardware_testing_application()
    ml_feature_importance()
    network_bottleneck()
    crypto_hardness()

    print("\n" + "=" * 60)
    print("All applications demonstrated.")


#!/usr/bin/env python3
"""
Demonstration of Tropical Certificate Complexity and NBP Lower Bounds.

This script provides concrete numerical examples illustrating the theorems
formalized in the Lean development, including:
1. Computing tropical certificate costs for specific Boolean functions
2. Constructing NBPs and extracting path certificates
3. Verifying lower bounds on NBP size
"""

import itertools
from typing import Callable, Dict, List, Optional, Set, Tuple


# ============================================================================
# Boolean Functions and Partial Assignments
# ============================================================================

def all_inputs(n: int) -> List[Tuple[bool, ...]]:
    """Generate all 2^n Boolean inputs."""
    return list(itertools.product([False, True], repeat=n))


def partial_assign_agrees(dom: Set[int], val: Dict[int, bool],
                          x: Tuple[bool, ...]) -> bool:
    """Check if total assignment x agrees with partial assignment (dom, val)."""
    return all(x[i] == val[i] for i in dom)


def forces(dom: Set[int], val: Dict[int, bool],
           f: Callable, n: int, target: bool) -> bool:
    """Check if partial assignment forces f to target value."""
    for x in all_inputs(n):
        if partial_assign_agrees(dom, val, x):
            if f(x) != target:
                return False
    return True


def tropical_cost(dom: Set[int], w: List[int]) -> int:
    """Compute tropical cost = sum of weights over domain."""
    return sum(w[i] for i in dom)


def min_accepting_cert_cost(f: Callable, w: List[int], n: int) -> int:
    """Compute minimum tropical cost over all accepting certificates."""
    min_cost = float('inf')
    # Enumerate all possible partial assignments
    for size in range(n + 1):
        for dom_tuple in itertools.combinations(range(n), size):
            dom = set(dom_tuple)
            # Try all value assignments on the domain
            for vals in itertools.product([False, True], repeat=size):
                val = {dom_tuple[i]: vals[i] for i in range(size)}
                if forces(dom, val, f, n, True):
                    cost = tropical_cost(dom, w)
                    min_cost = min(min_cost, cost)
    return min_cost if min_cost != float('inf') else 0


# ============================================================================
# Example Boolean Functions
# ============================================================================

def and_function(x: Tuple[bool, ...]) -> bool:
    """AND of all variables."""
    return all(x)


def or_function(x: Tuple[bool, ...]) -> bool:
    """OR of all variables."""
    return any(x)


def tribes(x: Tuple[bool, ...], group_size: int = 2) -> bool:
    """Tribes function: OR of groups, each group is AND."""
    n = len(x)
    for start in range(0, n, group_size):
        group = x[start:start + group_size]
        if all(group):
            return True
    return False


def parity(x: Tuple[bool, ...]) -> bool:
    """Parity (XOR) of all variables."""
    return sum(x) % 2 == 1


# ============================================================================
# NBP Model
# ============================================================================

class NBPEdge:
    """An edge: at state src, query variable var; if value==val, go to tgt."""
    def __init__(self, src: int, var: int, val: bool, tgt: int):
        self.src = src
        self.var = var
        self.val = val
        self.tgt = tgt

    def __repr__(self):
        return f"({self.src} --x{self.var}={int(self.val)}--> {self.tgt})"


class NBP:
    """Nondeterministic Branching Program."""
    def __init__(self, num_states: int, n_vars: int,
                 start: int, accept: int, edges: List[NBPEdge]):
        self.num_states = num_states
        self.n_vars = n_vars
        self.start = start
        self.accept = accept
        self.edges = edges

    def accepts(self, x: Tuple[bool, ...]) -> bool:
        """Check if the NBP accepts input x (existential path semantics)."""
        paths = self._find_accepting_paths(x)
        return len(paths) > 0

    def _find_accepting_paths(self, x: Tuple[bool, ...]) -> List[List[NBPEdge]]:
        """Find all accepting paths consistent with x."""
        result = []
        self._dfs(self.start, x, [], result)
        return result

    def _dfs(self, state: int, x: Tuple[bool, ...],
             path: List[NBPEdge], result: List[List[NBPEdge]]):
        if state == self.accept and len(path) > 0:
            result.append(list(path))
            return
        for e in self.edges:
            if e.src == state and x[e.var] == e.val:
                # Prevent infinite loops in non-acyclic programs
                if len(path) > self.num_states:
                    continue
                path.append(e)
                self._dfs(e.tgt, x, path, result)
                path.pop()

    def is_acyclic(self) -> bool:
        """Check if all edges go from lower to higher state index."""
        return all(e.src < e.tgt for e in self.edges)

    def computes(self, f: Callable, n: int) -> bool:
        """Verify that the NBP computes f."""
        for x in all_inputs(n):
            if f(x) != self.accepts(x):
                return False
        return True


def path_certificate(path: List[NBPEdge], x: Tuple[bool, ...]) -> Tuple[Set[int], Dict[int, bool]]:
    """Extract the partial assignment from a path and consistent input."""
    dom = set(e.var for e in path)
    val = {i: x[i] for i in dom}
    return dom, val


# ============================================================================
# Demo 1: AND function with uniform weights
# ============================================================================

def demo_and():
    print("=" * 70)
    print("DEMO 1: AND Function — Tropical Certificate Complexity")
    print("=" * 70)

    n = 4
    w = [1, 1, 1, 1]  # Uniform weights

    print(f"\nFunction: AND of {n} variables")
    print(f"Weights: {w} (uniform)")

    # The AND function has exactly one accepting input: (1,1,...,1)
    # The minimum accepting certificate must set ALL variables to 1
    # So min cert cost = sum of all weights = n

    min_cost = min_accepting_cert_cost(and_function, w, n)
    print(f"\nMinimum accepting certificate cost: {min_cost}")
    print(f"(Expected: {sum(w)}, since AND requires all variables)")

    # Build a simple NBP for AND
    # States: 0 (start), 1, 2, 3, 4 (accept)
    # Linear chain: check x0=1, then x1=1, etc.
    edges = [NBPEdge(i, i, True, i + 1) for i in range(n)]
    B = NBP(n + 1, n, 0, n, edges)

    print(f"\nNBP: linear chain with {B.num_states} states")
    print(f"Acyclic: {B.is_acyclic()}")
    print(f"Computes AND: {B.computes(and_function, n)}")

    # Extract path certificate for accepting input
    x_accept = tuple([True] * n)
    paths = B._find_accepting_paths(x_accept)
    print(f"\nAccepting paths for (1,1,1,1): {len(paths)} path(s)")
    for p in paths:
        dom, val = path_certificate(p, x_accept)
        cost = tropical_cost(dom, w)
        print(f"  Path: {p}")
        print(f"  Certificate domain: {dom}, values: {val}")
        print(f"  Tropical cost: {cost}")

    # Lower bound verification
    W_max = max(w)
    L = min_cost
    print(f"\nLower bound theorem (linear):")
    print(f"  L = {L}, W_max = {W_max}")
    print(f"  L / W_max = {L // W_max} ≤ S = {B.num_states} ✓")


# ============================================================================
# Demo 2: OR function with non-uniform weights
# ============================================================================

def demo_or():
    print("\n" + "=" * 70)
    print("DEMO 2: OR Function — Anisotropic Tropical Weights")
    print("=" * 70)

    n = 4
    w = [1, 2, 4, 8]  # Exponentially increasing weights

    print(f"\nFunction: OR of {n} variables")
    print(f"Weights: {w} (exponential)")

    min_cost = min_accepting_cert_cost(or_function, w, n)
    print(f"\nMinimum accepting certificate cost: {min_cost}")
    print(f"(Expected: {min(w)}, since OR needs only one variable)")

    # Build NBP for OR: nondeterministic choice of which variable to check
    # States: 0 (start), 1 (accept)
    edges = [NBPEdge(0, i, True, 1) for i in range(n)]
    B = NBP(2, n, 0, 1, edges)

    print(f"\nNBP: star graph with {B.num_states} states")
    print(f"Acyclic: {B.is_acyclic()}")
    print(f"Computes OR: {B.computes(or_function, n)}")

    # Show different path certificates for different inputs
    for x in [(True, False, False, False), (False, False, False, True),
              (True, True, False, False)]:
        paths = B._find_accepting_paths(x)
        print(f"\n  Input {tuple(int(b) for b in x)}:")
        for p in paths:
            dom, val = path_certificate(p, x)
            cost = tropical_cost(dom, w)
            print(f"    Path: {p}, cost: {cost}")

    print(f"\n  Key insight: OR has cheap certificates (cost {min_cost}),")
    print(f"  so the lower bound is weak → small NBPs suffice.")


# ============================================================================
# Demo 3: Tribes function with anisotropic weights
# ============================================================================

def demo_tribes():
    print("\n" + "=" * 70)
    print("DEMO 3: Tribes Function — Group Structure Meets Tropical Cost")
    print("=" * 70)

    n = 6
    group_size = 2
    num_groups = n // group_size

    # Weight each variable by 2^(group index)
    w = [2 ** (i // group_size) for i in range(n)]

    f = lambda x: tribes(x, group_size)

    print(f"\nFunction: Tribes({n}, group_size={group_size})")
    print(f"  = OR(AND(x0,x1), AND(x2,x3), AND(x4,x5))")
    print(f"Weights: {w}")
    print(f"  (grouped: {[w[i:i+group_size] for i in range(0, n, group_size)]})")

    min_cost = min_accepting_cert_cost(f, w, n)
    print(f"\nMinimum accepting certificate cost: {min_cost}")

    # Count accepting inputs
    accepting = sum(1 for x in all_inputs(n) if f(x))
    print(f"Number of accepting inputs: {accepting} / {2**n}")

    # Build NBP for tribes
    # States: 0=start, 1..num_groups = "group i satisfied", num_groups+1 = accept
    # From state 0, for each group g, if both vars in group g are 1, go to accept
    edges = []
    state_counter = 1
    for g in range(num_groups):
        var1 = g * group_size
        var2 = g * group_size + 1
        mid_state = state_counter
        state_counter += 1
        edges.append(NBPEdge(0, var1, True, mid_state))
        edges.append(NBPEdge(mid_state, var2, True, state_counter))

    accept_state = state_counter
    # Redirect all group completions to the accept state
    new_edges = []
    for e in edges:
        if e.tgt == state_counter:
            pass
        else:
            new_edges.append(e)
    # Rebuild more carefully
    edges = []
    for g in range(num_groups):
        var1 = g * group_size
        var2 = g * group_size + 1
        mid = 1 + 2 * g
        new_accept = 1 + 2 * g + 1
        edges.append(NBPEdge(0, var1, True, mid))
        edges.append(NBPEdge(mid, var2, True, new_accept))

    # All "new_accept" states lead to a single accept
    total_states = 1 + 2 * num_groups + 1
    final_accept = total_states - 1
    final_edges = []
    for g in range(num_groups):
        var1 = g * group_size
        var2 = g * group_size + 1
        mid = 1 + 2 * g
        final_edges.append(NBPEdge(0, var1, True, mid))
        final_edges.append(NBPEdge(mid, var2, True, final_accept))

    B = NBP(total_states, n, 0, final_accept, final_edges)
    print(f"\nNBP: {B.num_states} states")
    print(f"Acyclic: {B.is_acyclic()}")
    print(f"Computes tribes: {B.computes(f, n)}")

    # Lower bound
    W_max = max(w)
    print(f"\nLinear lower bound: L/W_max = {min_cost}//{W_max} = {min_cost // W_max}")
    print(f"Actual NBP size: {B.num_states}")
    print(f"Bound holds: {min_cost // W_max <= B.num_states}")


# ============================================================================
# Demo 4: Exponential lower bound demonstration
# ============================================================================

def demo_exponential_bound():
    print("\n" + "=" * 70)
    print("DEMO 4: Exponential Lower Bound (Conditional Theorem)")
    print("=" * 70)

    print("""
The main theorem states: if
  (1) every accepting certificate has tropical cost ≥ L,
  (2) every accepting path certificate costs ≤ C · log₂(S),
then S ≥ 2^(L/C).

Example scenarios:
""")

    scenarios = [
        (10, 2, "L=10, C=2 → S ≥ 2^5 = 32"),
        (20, 4, "L=20, C=4 → S ≥ 2^5 = 32"),
        (30, 3, "L=30, C=3 → S ≥ 2^10 = 1024"),
        (50, 5, "L=50, C=5 → S ≥ 2^10 = 1024"),
        (100, 10, "L=100, C=10 → S ≥ 2^10 = 1024"),
    ]

    print(f"{'L':>5} {'C':>5} {'L/C':>5} {'2^(L/C)':>10}   Description")
    print("-" * 50)
    for L, C, desc in scenarios:
        bound = 2 ** (L // C)
        print(f"{L:>5} {C:>5} {L//C:>5} {bound:>10}   {desc}")

    print("""
The exponential blow-up shows that high tropical certificate complexity
forces large nondeterministic branching programs — this is the structural
bridge between min-plus algebra and computational complexity.
""")


# ============================================================================
# Demo 5: Path certificate extraction in action
# ============================================================================

def demo_path_extraction():
    print("=" * 70)
    print("DEMO 5: Path Certificate Extraction — The Fulcrum Lemma")
    print("=" * 70)

    # Build an NBP for a 3-variable function: majority
    n = 3
    w = [3, 2, 1]

    def majority(x):
        return sum(x) >= 2

    # NBP for majority with nondeterministic choice
    # Idea: guess which 2 variables are both 1
    # Pairs: (0,1), (0,2), (1,2)
    edges = [
        # Path for pair (0,1): check x0=1 then x1=1
        NBPEdge(0, 0, True, 1), NBPEdge(1, 1, True, 6),
        # Path for pair (0,2): check x0=1 then x2=1
        NBPEdge(0, 0, True, 2), NBPEdge(2, 2, True, 6),
        # Path for pair (1,2): check x1=1 then x2=1
        NBPEdge(0, 1, True, 3), NBPEdge(3, 2, True, 6),
    ]
    # States: 0=start, 1-5=intermediate, 6=accept
    B = NBP(7, n, 0, 6, edges)

    print(f"\nFunction: Majority of {n} variables")
    print(f"Weights: {w}")
    print(f"NBP: {B.num_states} states, acyclic: {B.is_acyclic()}")
    print(f"Computes majority: {B.computes(majority, n)}")

    print(f"\nPath certificate extraction for each accepting input:")
    for x in all_inputs(n):
        if majority(x):
            paths = B._find_accepting_paths(x)
            print(f"\n  Input {tuple(int(b) for b in x)} (majority=True):")
            for p in paths:
                dom, val = path_certificate(p, x)
                cost = tropical_cost(dom, w)
                # Verify forcing
                is_forcing = forces(dom, val, majority, n, True)
                print(f"    Path: {p}")
                print(f"    Certificate: dom={dom}, val={val}")
                print(f"    Tropical cost: {cost}, forces majority=True: {is_forcing}")

    min_cost = min_accepting_cert_cost(majority, w, n)
    print(f"\n  Minimum accepting certificate cost: {min_cost}")
    print(f"  (Cheapest certificate uses variables with smallest weights)")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("TROPICAL CERTIFICATE COMPLEXITY — NUMERICAL DEMONSTRATIONS")
    print("=" * 70)
    print()

    demo_and()
    demo_or()
    demo_tribes()
    demo_exponential_bound()
    demo_path_extraction()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import base64
import io
import sys

# Read text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Generate visualizations
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
    import itertools
    import math

    def fig_to_base64(fig):
        buf = io.BytesIO()
        fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
        buf.seek(0)
        encoded = base64.b64encode(buf.read()).decode('utf-8')
        plt.close(fig)
        return f"data:image/png;base64,{encoded}"

    # Viz 1: Certificate cost landscape
    n = 3
    w = [3, 2, 1]
    def majority(x):
        return sum(x) >= 2

    certs = []
    for size in range(1, n + 1):
        for dom_tuple in itertools.combinations(range(n), size):
            dom = set(dom_tuple)
            for vals in itertools.product([False, True], repeat=size):
                val = {dom_tuple[i]: vals[i] for i in range(size)}
                forces = True
                for x in itertools.product([False, True], repeat=n):
                    if all(x[i] == val[i] for i in dom):
                        if not majority(x):
                            forces = False
                            break
                if forces:
                    cost = sum(w[i] for i in dom)
                    label = ", ".join(f"x{i}={int(val[i])}" for i in sorted(dom))
                    certs.append((cost, label, len(dom)))

    certs.sort(key=lambda c: c[0])
    fig, ax = plt.subplots(figsize=(10, 6))
    colors = {1: '#e74c3c', 2: '#3498db', 3: '#2ecc71'}
    for i, (cost, label, dom_size) in enumerate(certs):
        ax.barh(i, cost, color=colors.get(dom_size, '#95a5a6'), alpha=0.8, edgecolor='white')
        ax.text(cost + 0.1, i, f" {label}", va='center', fontsize=8)
    ax.set_xlabel('Tropical Cost', fontsize=12)
    ax.set_title('Certificate Cost Landscape: Majority(3), w=[3,2,1]', fontsize=14)
    ax.set_yticks([])
    legend_patches = [
        mpatches.Patch(color='#e74c3c', label='1 variable'),
        mpatches.Patch(color='#3498db', label='2 variables'),
        mpatches.Patch(color='#2ecc71', label='3 variables'),
    ]
    ax.legend(handles=legend_patches, loc='lower right')
    ax.axvline(x=min(c[0] for c in certs), color='red', linestyle='--', linewidth=2)
    viz1_data = fig_to_base64(fig)

    # Viz 2: Lower bound growth
    fig, ax = plt.subplots(figsize=(10, 6))
    L_values = range(1, 51)
    C_values = [1, 2, 3, 5, 10]
    colors_line = ['#e74c3c', '#e67e22', '#2ecc71', '#3498db', '#9b59b6']
    for C, color in zip(C_values, colors_line):
        bounds = [2 ** (L // C) for L in L_values]
        ax.plot(L_values, bounds, color=color, linewidth=2, label=f'C = {C}')
    ax.set_xlabel('Certificate Cost L', fontsize=12)
    ax.set_ylabel('Min NBP Size 2^(L/C)', fontsize=12)
    ax.set_title('Exponential Lower Bound Growth', fontsize=14)
    ax.set_yscale('log', base=2)
    ax.legend()
    ax.grid(True, alpha=0.3)
    viz2_data = fig_to_base64(fig)

    # Viz 3: Weight anisotropy
    n = 4
    def and_fn(x): return all(x)
    weight_schemes = {
        'Uniform [1,1,1,1]': [1, 1, 1, 1],
        'Linear [1,2,3,4]': [1, 2, 3, 4],
        'Exponential [1,2,4,8]': [1, 2, 4, 8],
        'Heavy-tail [1,1,1,10]': [1, 1, 1, 10],
    }
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    for ax, (name, ww) in zip(axes.flat, weight_schemes.items()):
        cert_costs = []
        for size in range(1, n + 1):
            for dom_tuple in itertools.combinations(range(n), size):
                dom = set(dom_tuple)
                for vals in itertools.product([False, True], repeat=size):
                    val = {dom_tuple[i]: vals[i] for i in range(size)}
                    forces_val = True
                    for x in itertools.product([False, True], repeat=n):
                        if all(x[i] == val[i] for i in dom):
                            if not and_fn(x):
                                forces_val = False
                                break
                    if forces_val:
                        cost = sum(ww[i] for i in dom)
                        cert_costs.append((cost, len(dom)))
        cert_costs.sort()
        costs = [c[0] for c in cert_costs]
        sizes = [c[1] for c in cert_costs]
        ax.bar(range(len(costs)), costs,
               color=['#e74c3c' if s == n else '#3498db' for s in sizes], alpha=0.7)
        ax.set_title(name, fontsize=12, fontweight='bold')
        ax.set_xlabel('Certificate index')
        ax.set_ylabel('Tropical cost')
        if costs:
            ax.axhline(y=min(costs), color='red', linestyle='--', linewidth=1.5, alpha=0.7)
    fig.suptitle('Weight Anisotropy Effect on AND(4)', fontsize=14)
    plt.tight_layout()
    viz3_data = fig_to_base64(fig)

except Exception as e:
    print(f"Warning: Could not generate matplotlib visualizations: {e}", file=sys.stderr)
    viz1_data = ""
    viz2_data = ""
    viz3_data = ""

# SVG diagram
nbp_svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 400" width="600" height="400">
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#333"/>
    </marker>
  </defs>
  <text x="300" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#2c3e50">NBP for Majority(3) with Path Certificates</text>
  <circle cx="80" cy="200" r="30" fill="#3498db" stroke="#2c3e50" stroke-width="2"/>
  <text x="80" y="205" text-anchor="middle" fill="white" font-size="14" font-weight="bold">S</text>
  <circle cx="230" cy="100" r="25" fill="#e8f4fd" stroke="#3498db" stroke-width="2"/>
  <text x="230" y="105" text-anchor="middle" fill="#2c3e50" font-size="12">q1</text>
  <circle cx="230" cy="200" r="25" fill="#e8f4fd" stroke="#3498db" stroke-width="2"/>
  <text x="230" y="205" text-anchor="middle" fill="#2c3e50" font-size="12">q2</text>
  <circle cx="230" cy="300" r="25" fill="#e8f4fd" stroke="#3498db" stroke-width="2"/>
  <text x="230" y="305" text-anchor="middle" fill="#2c3e50" font-size="12">q3</text>
  <circle cx="520" cy="200" r="30" fill="#2ecc71" stroke="#27ae60" stroke-width="3"/>
  <text x="520" y="205" text-anchor="middle" fill="white" font-size="14" font-weight="bold">A</text>
  <line x1="110" y1="190" x2="200" y2="110" stroke="#e74c3c" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="145" y="140" fill="#e74c3c" font-size="11" font-weight="bold">x0=1</text>
  <line x1="110" y1="200" x2="200" y2="200" stroke="#e67e22" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="155" y="190" fill="#e67e22" font-size="11" font-weight="bold">x0=1</text>
  <line x1="110" y1="210" x2="200" y2="290" stroke="#9b59b6" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="145" y="270" fill="#9b59b6" font-size="11" font-weight="bold">x1=1</text>
  <line x1="255" y1="100" x2="490" y2="190" stroke="#e74c3c" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="370" y="130" fill="#e74c3c" font-size="11" font-weight="bold">x1=1</text>
  <line x1="255" y1="200" x2="490" y2="200" stroke="#e67e22" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="370" y="190" fill="#e67e22" font-size="11" font-weight="bold">x2=1</text>
  <line x1="255" y1="300" x2="490" y2="210" stroke="#9b59b6" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="370" y="275" fill="#9b59b6" font-size="11" font-weight="bold">x2=1</text>
  <rect x="30" y="340" width="250" height="50" rx="8" fill="#fdf2e9" stroke="#e67e22" stroke-width="1.5"/>
  <text x="155" y="360" text-anchor="middle" font-size="10" fill="#2c3e50">Red: {x0,x1} cost=5 | Orange: {x0,x2} cost=4</text>
  <text x="155" y="378" text-anchor="middle" font-size="10" fill="#9b59b6">Purple: {x1,x2} cost=3 (minimum!)</text>
</svg>'''

# Read all source files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algo_code = read_file('algorithms.py')
app_code = read_file('applications.py')
lean_code = read_file('Catalog/Tropical/Core/TropicalNBPLowerBound.lean')

package = {
    "title": "Tropical Certificate Lower Bounds for Nondeterministic Branching Programs",
    "domain": "Tropical Complexity Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Certificate Complexity Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": app_code
        }
    ],
    "algorithms": [
        {
            "name": "Minimum Tropical Certificate Cost",
            "pseudocode": "Input: Boolean function f, weight function w, number of variables n\nOutput: Minimum tropical cost L over all accepting certificates\n\n1. Set L_min = infinity\n2. For each subset S of {1,...,n}:\n   a. For each value assignment v on S:\n      i.  Check if (S, v) forces f to 1\n      ii. If yes: L_min = min(L_min, sum_{i in S} w(i))\n3. Return L_min\n\nComplexity: O(3^n * 2^n) time, O(n) space",
            "code": algo_code
        },
        {
            "name": "Path Certificate Extraction",
            "pseudocode": "Input: Accepting path p = (e1, ..., ek), consistent input x\nOutput: Partial assignment (dom, val) that forces f to 1\n\n1. dom = {e_j.var : 1 <= j <= k}  (set of queried variables)\n2. val = x restricted to dom\n3. Return (dom, val)\n\nComplexity: O(k) time\n\nCorrectness: By the Fulcrum Lemma, if the NBP computes f\nand p is accepting, then (dom, val) forces f to 1.",
            "code": "# Path certificate extraction (standalone)\nimport itertools\n\ndef extract_certificate(path_edges, input_x):\n    \"\"\"Extract tropical certificate from an NBP path.\n    \n    Args:\n        path_edges: list of (src, var, val, tgt) tuples\n        input_x: tuple of bool values\n    Returns:\n        (domain_set, value_dict, tropical_cost)\n    \"\"\"\n    dom = set(e[1] for e in path_edges)\n    val = {i: input_x[i] for i in dom}\n    return dom, val\n\n# Example: AND(3) NBP path\npath = [(0, 0, True, 1), (1, 1, True, 2), (2, 2, True, 3)]\nx = (True, True, True)\ndom, val = extract_certificate(path, x)\nprint(f'Certificate domain: {dom}')\nprint(f'Certificate values: {val}')\nweights = [3, 2, 1]\ncost = sum(weights[i] for i in dom)\nprint(f'Tropical cost: {cost}')\n"
        }
    ],
    "visualizations": [
        {
            "name": "Certificate Cost Landscape",
            "data": viz1_data
        },
        {
            "name": "Exponential Lower Bound Growth",
            "data": viz2_data
        },
        {
            "name": "NBP Structure with Path Certificates",
            "data": nbp_svg
        },
        {
            "name": "Weight Anisotropy Effect",
            "data": viz3_data
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully!")
print(f"Size: {len(json.dumps(package))} bytes")


#!/usr/bin/env python3
"""
Visualizations for Tropical Certificate Complexity and NBP Lower Bounds.
Generates charts showing key mathematical structures.
"""

import itertools
import math
import base64
import io

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    import numpy as np
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available; generating SVG diagrams only")


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


# ============================================================================
# Visualization 1: Tropical Certificate Cost Landscape
# ============================================================================

def viz_cost_landscape():
    """Plot the certificate cost landscape for a Boolean function."""
    if not HAS_MPL:
        return None

    n = 3
    w = [3, 2, 1]

    def majority(x):
        return sum(x) >= 2

    # Find all accepting certificates and their costs
    certs = []
    for size in range(1, n + 1):
        for dom_tuple in itertools.combinations(range(n), size):
            dom = set(dom_tuple)
            for vals in itertools.product([False, True], repeat=size):
                val = {dom_tuple[i]: vals[i] for i in range(size)}
                forces = True
                for x in itertools.product([False, True], repeat=n):
                    if all(x[i] == val[i] for i in dom):
                        if not majority(x):
                            forces = False
                            break
                if forces:
                    cost = sum(w[i] for i in dom)
                    label = ", ".join(f"x{i}={int(val[i])}" for i in sorted(dom))
                    certs.append((cost, label, len(dom)))

    certs.sort(key=lambda c: c[0])

    fig, ax = plt.subplots(figsize=(10, 6))
    colors = {1: '#e74c3c', 2: '#3498db', 3: '#2ecc71'}
    for i, (cost, label, dom_size) in enumerate(certs):
        ax.barh(i, cost, color=colors.get(dom_size, '#95a5a6'), alpha=0.8, edgecolor='white')
        ax.text(cost + 0.1, i, f" {label}", va='center', fontsize=8)

    ax.set_xlabel('Tropical Cost (min-plus sum of weights)', fontsize=12)
    ax.set_ylabel('Certificate', fontsize=12)
    ax.set_title('Certificate Cost Landscape: Majority(3), w = [3, 2, 1]', fontsize=14)
    ax.set_yticks([])

    legend_patches = [
        mpatches.Patch(color='#e74c3c', label='1 variable'),
        mpatches.Patch(color='#3498db', label='2 variables'),
        mpatches.Patch(color='#2ecc71', label='3 variables'),
    ]
    ax.legend(handles=legend_patches, loc='lower right')
    ax.axvline(x=min(c[0] for c in certs), color='red', linestyle='--',
               linewidth=2, label='Min cost (L)')
    ax.set_xlim(0, max(c[0] for c in certs) + 3)

    return fig_to_base64(fig)


# ============================================================================
# Visualization 2: Lower Bound Growth
# ============================================================================

def viz_lower_bound_growth():
    """Plot how 2^(L/C) grows with L for various C values."""
    if not HAS_MPL:
        return None

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    L_values = range(1, 51)
    C_values = [1, 2, 3, 5, 10]
    colors = ['#e74c3c', '#e67e22', '#2ecc71', '#3498db', '#9b59b6']

    # Linear scale
    for C, color in zip(C_values, colors):
        bounds = [2 ** (L // C) for L in L_values]
        ax1.plot(L_values, bounds, color=color, linewidth=2, label=f'C = {C}')

    ax1.set_xlabel('Certificate Cost L', fontsize=12)
    ax1.set_ylabel('Minimum NBP Size 2^(L/C)', fontsize=12)
    ax1.set_title('Exponential Lower Bound (linear scale)', fontsize=13)
    ax1.legend()
    ax1.set_yscale('log', base=2)
    ax1.grid(True, alpha=0.3)

    # Log scale comparison with linear bound
    for C, color in zip([1, 2, 5], colors[:3]):
        exp_bounds = [2 ** (L // C) for L in L_values]
        ax2.plot(L_values, [math.log2(b) if b > 0 else 0 for b in exp_bounds],
                 color=color, linewidth=2, label=f'Exponential: L/C (C={C})')

    # Linear bound
    for W in [1, 2, 5]:
        linear_bounds = [L // W for L in L_values]
        ax2.plot(L_values, linear_bounds, color='gray', linewidth=1,
                 linestyle='--', alpha=0.5)

    ax2.set_xlabel('Certificate Cost L', fontsize=12)
    ax2.set_ylabel('log₂(Lower Bound)', fontsize=12)
    ax2.set_title('Exponential vs Linear Bounds (log scale)', fontsize=13)
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    return fig_to_base64(fig)


# ============================================================================
# Visualization 3: NBP Path Structure
# ============================================================================

def viz_nbp_structure():
    """Generate SVG diagram of an example NBP with path certificates."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 400" width="600" height="400">
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#333"/>
    </marker>
  </defs>

  <!-- Title -->
  <text x="300" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#2c3e50">
    NBP for Majority(3) with Path Certificates
  </text>

  <!-- States -->
  <circle cx="80" cy="200" r="30" fill="#3498db" stroke="#2c3e50" stroke-width="2"/>
  <text x="80" y="205" text-anchor="middle" fill="white" font-size="14" font-weight="bold">S</text>
  <text x="80" y="250" text-anchor="middle" fill="#7f8c8d" font-size="10">start</text>

  <circle cx="230" cy="100" r="25" fill="#e8f4fd" stroke="#3498db" stroke-width="2"/>
  <text x="230" y="105" text-anchor="middle" fill="#2c3e50" font-size="12">q₁</text>

  <circle cx="230" cy="200" r="25" fill="#e8f4fd" stroke="#3498db" stroke-width="2"/>
  <text x="230" y="205" text-anchor="middle" fill="#2c3e50" font-size="12">q₂</text>

  <circle cx="230" cy="300" r="25" fill="#e8f4fd" stroke="#3498db" stroke-width="2"/>
  <text x="230" y="305" text-anchor="middle" fill="#2c3e50" font-size="12">q₃</text>

  <circle cx="520" cy="200" r="30" fill="#2ecc71" stroke="#27ae60" stroke-width="3"/>
  <text x="520" y="205" text-anchor="middle" fill="white" font-size="14" font-weight="bold">A</text>
  <text x="520" y="250" text-anchor="middle" fill="#7f8c8d" font-size="10">accept</text>

  <!-- Edges from start -->
  <line x1="110" y1="190" x2="200" y2="110" stroke="#e74c3c" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="145" y="140" fill="#e74c3c" font-size="11" font-weight="bold">x₀=1</text>

  <line x1="110" y1="200" x2="200" y2="200" stroke="#e67e22" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="155" y="190" fill="#e67e22" font-size="11" font-weight="bold">x₀=1</text>

  <line x1="110" y1="210" x2="200" y2="290" stroke="#9b59b6" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="145" y="270" fill="#9b59b6" font-size="11" font-weight="bold">x₁=1</text>

  <!-- Edges to accept -->
  <line x1="255" y1="100" x2="490" y2="190" stroke="#e74c3c" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="370" y="130" fill="#e74c3c" font-size="11" font-weight="bold">x₁=1</text>

  <line x1="255" y1="200" x2="490" y2="200" stroke="#e67e22" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="370" y="190" fill="#e67e22" font-size="11" font-weight="bold">x₂=1</text>

  <line x1="255" y1="300" x2="490" y2="210" stroke="#9b59b6" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="370" y="275" fill="#9b59b6" font-size="11" font-weight="bold">x₂=1</text>

  <!-- Certificate boxes -->
  <rect x="30" y="320" width="170" height="70" rx="8" fill="#fdf2e9" stroke="#e67e22" stroke-width="1.5"/>
  <text x="115" y="340" text-anchor="middle" font-size="11" fill="#e67e22" font-weight="bold">Path Certificates:</text>
  <text x="115" y="358" text-anchor="middle" font-size="10" fill="#2c3e50">Red: {x₀=1, x₁=1} cost=5</text>
  <text x="115" y="374" text-anchor="middle" font-size="10" fill="#2c3e50">Orange: {x₀=1, x₂=1} cost=4</text>

  <rect x="220" y="340" width="170" height="45" rx="8" fill="#f4ecf7" stroke="#9b59b6" stroke-width="1.5"/>
  <text x="305" y="358" text-anchor="middle" font-size="10" fill="#2c3e50">Purple: {x₁=1, x₂=1} cost=3</text>
  <text x="305" y="374" text-anchor="middle" font-size="10" fill="#9b59b6" font-weight="bold">← Minimum cost!</text>

  <!-- Weight legend -->
  <rect x="420" y="320" width="160" height="70" rx="8" fill="#eaf2ea" stroke="#27ae60" stroke-width="1.5"/>
  <text x="500" y="340" text-anchor="middle" font-size="11" fill="#27ae60" font-weight="bold">Weights w:</text>
  <text x="500" y="358" text-anchor="middle" font-size="10" fill="#2c3e50">w(x₀)=3, w(x₁)=2, w(x₂)=1</text>
  <text x="500" y="374" text-anchor="middle" font-size="10" fill="#2c3e50">TropCert(f,w) = 3</text>
</svg>'''
    return svg


# ============================================================================
# Visualization 4: Weight Anisotropy Effect
# ============================================================================

def viz_weight_anisotropy():
    """Show how different weight functions change the certificate landscape."""
    if not HAS_MPL:
        return None

    n = 4

    def and_fn(x):
        return all(x)

    weight_schemes = {
        'Uniform [1,1,1,1]': [1, 1, 1, 1],
        'Linear [1,2,3,4]': [1, 2, 3, 4],
        'Exponential [1,2,4,8]': [1, 2, 4, 8],
        'Heavy-tail [1,1,1,10]': [1, 1, 1, 10],
    }

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    for ax, (name, w) in zip(axes.flat, weight_schemes.items()):
        # Find all accepting certificates
        certs = []
        for size in range(1, n + 1):
            for dom_tuple in itertools.combinations(range(n), size):
                dom = set(dom_tuple)
                for vals in itertools.product([False, True], repeat=size):
                    val = {dom_tuple[i]: vals[i] for i in range(size)}
                    forces = True
                    for x in itertools.product([False, True], repeat=n):
                        if all(x[i] == val[i] for i in dom):
                            if not and_fn(x):
                                forces = False
                                break
                    if forces:
                        cost = sum(w[i] for i in dom)
                        certs.append((cost, len(dom)))

        certs.sort()
        costs = [c[0] for c in certs]
        sizes = [c[1] for c in certs]

        ax.bar(range(len(costs)), costs, color=['#e74c3c' if s == n else '#3498db'
               for s in sizes], alpha=0.7, edgecolor='white')
        ax.set_title(name, fontsize=12, fontweight='bold')
        ax.set_xlabel('Certificate index')
        ax.set_ylabel('Tropical cost')
        if costs:
            ax.axhline(y=min(costs), color='red', linestyle='--', linewidth=1.5, alpha=0.7)

    fig.suptitle('Weight Anisotropy Effect on AND(4) Certificate Costs', fontsize=14, y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("Generating visualizations...")

    v1 = viz_cost_landscape()
    if v1:
        print(f"  Certificate cost landscape: {len(v1)} bytes")

    v2 = viz_lower_bound_growth()
    if v2:
        print(f"  Lower bound growth: {len(v2)} bytes")

    v3 = viz_nbp_structure()
    print(f"  NBP structure SVG: {len(v3)} bytes")

    v4 = viz_weight_anisotropy()
    if v4:
        print(f"  Weight anisotropy: {len(v4)} bytes")

    print("Done!")
