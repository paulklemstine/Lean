#!/usr/bin/env python3
"""
Algorithms for Tropical Certificate Complexity and NBP Analysis.

Implements the core computational methods from the research paper:
1. Optimal tropical certificate computation
2. NBP construction and verification
3. Lower bound computation
4. Path enumeration and certificate extraction
"""

import itertools
from typing import Callable, Dict, List, Optional, Set, Tuple
from dataclasses import dataclass, field


# ============================================================================
# Core Data Structures
# ============================================================================

@dataclass
class PartialAssignment:
    """A partial assignment to Boolean variables.

    Attributes:
        dom: Set of assigned variable indices
        val: Mapping from variable index to assigned value
    """
    dom: Set[int]
    val: Dict[int, bool]

    def agrees(self, x: Tuple[bool, ...]) -> bool:
        """Check if total assignment x extends this partial assignment."""
        return all(x[i] == self.val[i] for i in self.dom)

    def forces(self, f: Callable, n: int, target: bool) -> bool:
        """Check if this partial assignment forces f to target.

        Args:
            f: Boolean function (tuple of bools -> bool)
            n: Number of variables
            target: Target Boolean value

        Returns:
            True if every x extending this assignment satisfies f(x) == target
        """
        for x in itertools.product([False, True], repeat=n):
            if self.agrees(x) and f(x) != target:
                return False
        return True

    def tropical_cost(self, w: List[int]) -> int:
        """Compute tropical cost under weight function w.

        This is the additive cost in the min-plus semiring:
        sum of weights of all assigned coordinates.
        """
        return sum(w[i] for i in self.dom)


@dataclass
class NBPEdge:
    """An edge in a Nondeterministic Branching Program.

    At state `src`, query variable `var`. If the value equals `val`,
    transition to state `tgt`.
    """
    src: int
    var: int
    val: bool
    tgt: int


@dataclass
class NBP:
    """Nondeterministic Branching Program.

    A directed graph with labeled edges representing a nondeterministic
    computation over Boolean inputs. Accepts input x iff there exists
    a start-to-accept path consistent with x.

    Attributes:
        num_states: Total number of states (states are 0..num_states-1)
        n_vars: Number of input variables
        start: Start state index
        accept: Accept state index
        edges: List of labeled edges
    """
    num_states: int
    n_vars: int
    start: int
    accept: int
    edges: List[NBPEdge]

    def is_acyclic(self) -> bool:
        """Check if all edges go from lower to higher state index.

        Time complexity: O(|edges|)
        """
        return all(e.src < e.tgt for e in self.edges)

    def accepts(self, x: Tuple[bool, ...]) -> bool:
        """Check if the NBP accepts input x.

        Uses BFS to find an accepting path consistent with x.

        Time complexity: O(|edges|)
        """
        visited = set()
        queue = [self.start]
        while queue:
            state = queue.pop(0)
            if state == self.accept:
                return True  # Only valid if we've traversed at least one edge
            if state in visited:
                continue
            visited.add(state)
            for e in self.edges:
                if e.src == state and x[e.var] == e.val:
                    if e.tgt == self.accept:
                        return True
                    queue.append(e.tgt)
        return False

    def find_all_accepting_paths(self, x: Tuple[bool, ...],
                                  max_depth: int = None) -> List[List[NBPEdge]]:
        """Enumerate all accepting paths consistent with x.

        Args:
            x: Input assignment
            max_depth: Maximum path length (default: num_states)

        Returns:
            List of edge-lists, each forming an accepting path

        Time complexity: O(|paths|) which can be exponential
        """
        if max_depth is None:
            max_depth = self.num_states
        result = []
        self._enumerate_paths(self.start, x, [], result, max_depth)
        return result

    def _enumerate_paths(self, state: int, x: Tuple[bool, ...],
                         path: List[NBPEdge], result: List[List[NBPEdge]],
                         max_depth: int):
        if state == self.accept and len(path) > 0:
            result.append(list(path))
            return
        if len(path) >= max_depth:
            return
        for e in self.edges:
            if e.src == state and x[e.var] == e.val:
                path.append(e)
                self._enumerate_paths(e.tgt, x, path, result, max_depth)
                path.pop()

    def computes(self, f: Callable) -> bool:
        """Verify that this NBP computes Boolean function f.

        Time complexity: O(2^n * |edges|)
        """
        for x in itertools.product([False, True], repeat=self.n_vars):
            if f(x) != self.accepts(x):
                return False
        return True


# ============================================================================
# Algorithm 1: Minimum Tropical Certificate Cost
# ============================================================================

def compute_min_cert_cost(f: Callable, w: List[int], n: int,
                          target: bool = True) -> Tuple[int, PartialAssignment]:
    """Compute the minimum tropical certificate cost for f.

    Enumerates all partial assignments and finds the one with minimum
    tropical cost that forces f to the target value.

    Args:
        f: Boolean function
        w: Weight function (list of n weights)
        n: Number of variables
        target: Target value (True for accepting certificates)

    Returns:
        (min_cost, optimal_certificate) pair

    Time complexity: O(3^n * 2^n) — exponential in n
    Space complexity: O(n)

    Algorithm:
        For each subset S of {0,...,n-1}:
            For each value assignment v on S:
                Check if (S, v) forces f to target
                If yes, compute tropical cost and track minimum
    """
    best_cost = float('inf')
    best_cert = None

    for size in range(n + 1):
        for dom_tuple in itertools.combinations(range(n), size):
            dom = set(dom_tuple)
            for vals in itertools.product([False, True], repeat=size):
                val = {dom_tuple[i]: vals[i] for i in range(size)}
                cert = PartialAssignment(dom, val)
                if cert.forces(f, n, target):
                    cost = cert.tropical_cost(w)
                    if cost < best_cost:
                        best_cost = cost
                        best_cert = cert

    return (best_cost if best_cost != float('inf') else 0, best_cert)


# ============================================================================
# Algorithm 2: Path Certificate Extraction
# ============================================================================

def extract_path_certificate(path: List[NBPEdge],
                              x: Tuple[bool, ...]) -> PartialAssignment:
    """Extract the partial assignment induced by an NBP path.

    For a path consistent with x, the certificate uses x's values
    on the set of variables queried along the path.

    Args:
        path: List of NBP edges forming a valid path
        x: Total assignment consistent with the path

    Returns:
        Partial assignment (dom = queried variables, val = x restricted to dom)

    Time complexity: O(|path|)

    This is the computational realization of the Fulcrum Lemma:
    if the path is accepting and the NBP computes f, then the
    returned certificate forces f to True.
    """
    dom = set(e.var for e in path)
    val = {i: x[i] for i in dom}
    return PartialAssignment(dom, val)


# ============================================================================
# Algorithm 3: NBP Size Lower Bound Computation
# ============================================================================

def compute_lower_bounds(f: Callable, w: List[int], n: int) -> Dict[str, int]:
    """Compute tropical certificate lower bounds on NBP size.

    Returns multiple lower bound estimates based on different
    versions of the main theorem.

    Args:
        f: Boolean function
        w: Weight function
        n: Number of variables

    Returns:
        Dictionary with keys:
        - 'min_cert_cost': L, the minimum accepting certificate cost
        - 'max_weight': W_max, maximum weight
        - 'linear_bound': L / W_max (linear lower bound for acyclic NBPs)
        - 'sum_weight': total weight sum
        - 'exponential_bounds': dict mapping C values to 2^(L/C)

    Time complexity: O(3^n * 2^n)
    """
    L, best_cert = compute_min_cert_cost(f, w, n, target=True)
    W_max = max(w) if w else 1

    # Linear bound: any acyclic NBP has ≥ L/W_max states
    linear = L // W_max if W_max > 0 else 0

    # Exponential bounds for various C values
    exp_bounds = {}
    for C in [1, 2, 3, 5, 10]:
        if C > 0:
            exp_bounds[C] = 2 ** (L // C)

    return {
        'min_cert_cost': L,
        'optimal_certificate': best_cert,
        'max_weight': W_max,
        'linear_bound': linear,
        'sum_weight': sum(w),
        'exponential_bounds': exp_bounds,
    }


# ============================================================================
# Algorithm 4: NBP Construction for Common Functions
# ============================================================================

def build_and_nbp(n: int) -> NBP:
    """Build an optimal NBP for AND of n variables.

    The AND function requires checking all n variables, so the
    optimal NBP is a linear chain with n+1 states.

    Size: n + 1 states
    """
    edges = [NBPEdge(i, i, True, i + 1) for i in range(n)]
    return NBP(n + 1, n, 0, n, edges)


def build_or_nbp(n: int) -> NBP:
    """Build an optimal NBP for OR of n variables.

    The OR function can be computed by nondeterministically
    guessing which variable is True.

    Size: 2 states (optimal)
    """
    edges = [NBPEdge(0, i, True, 1) for i in range(n)]
    return NBP(2, n, 0, 1, edges)


def build_tribes_nbp(n: int, group_size: int) -> NBP:
    """Build an NBP for the Tribes function.

    Tribes = OR of groups, each group = AND of group_size variables.
    The NBP nondeterministically guesses which group is all-True.

    Size: 1 + 2 * num_groups + 1 states
    """
    num_groups = n // group_size
    accept = 1 + 2 * num_groups
    edges = []
    for g in range(num_groups):
        mid = 1 + 2 * g
        for step in range(group_size):
            var = g * group_size + step
            if step == 0:
                edges.append(NBPEdge(0, var, True, mid))
            elif step == group_size - 1:
                edges.append(NBPEdge(mid + step - 1, var, True, accept))
            else:
                edges.append(NBPEdge(mid + step - 1, var, True, mid + step))

    total_states = accept + 1
    return NBP(total_states, n, 0, accept, edges)


# ============================================================================
# Main: Run all algorithms with examples
# ============================================================================

if __name__ == "__main__":
    print("TROPICAL CERTIFICATE ALGORITHMS — EXAMPLES")
    print("=" * 60)

    # Example 1: AND function
    n = 4
    w = [1, 2, 3, 4]

    def and_fn(x): return all(x)

    print(f"\n1. AND({n}) with weights {w}")
    bounds = compute_lower_bounds(and_fn, w, n)
    print(f"   Min cert cost (L): {bounds['min_cert_cost']}")
    print(f"   Max weight (W): {bounds['max_weight']}")
    print(f"   Linear bound (L/W): {bounds['linear_bound']}")
    if bounds['optimal_certificate']:
        cert = bounds['optimal_certificate']
        print(f"   Optimal certificate: dom={cert.dom}, val={cert.val}")
    print(f"   Exponential bounds: {bounds['exponential_bounds']}")

    B = build_and_nbp(n)
    print(f"   NBP size: {B.num_states}")
    print(f"   NBP computes AND: {B.computes(and_fn)}")

    # Example 2: OR function
    def or_fn(x): return any(x)

    print(f"\n2. OR({n}) with weights {w}")
    bounds = compute_lower_bounds(or_fn, w, n)
    print(f"   Min cert cost (L): {bounds['min_cert_cost']}")
    print(f"   Linear bound: {bounds['linear_bound']}")

    # Example 3: Majority
    n3 = 3
    w3 = [3, 2, 1]

    def majority(x): return sum(x) >= 2

    print(f"\n3. Majority({n3}) with weights {w3}")
    bounds = compute_lower_bounds(majority, w3, n3)
    print(f"   Min cert cost (L): {bounds['min_cert_cost']}")
    print(f"   Optimal cert: dom={bounds['optimal_certificate'].dom}")
    print(f"   Linear bound: {bounds['linear_bound']}")

    print("\n" + "=" * 60)
    print("All algorithm examples complete.")
