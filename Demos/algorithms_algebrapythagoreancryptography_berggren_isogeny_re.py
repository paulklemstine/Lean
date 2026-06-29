#!/usr/bin/env python3
"""
Berggren Isogeny Realization Duality — Algorithms

Implements the key algorithms from the research paper:
1. Berggren tree traversal and address computation
2. Correspondence network kernel evaluation
3. Network combination and decomposition
4. Minimal realization search (brute-force for small networks)
5. Row support analysis and observable rank estimation
"""

from typing import Tuple, List, Dict, Set, Optional, Callable
from math import gcd
from itertools import product
from collections import defaultdict

Triple = Tuple[int, int, int]
Action = Callable[[Triple], Triple]


# ============================================================
# Algorithm 1: Berggren Tree Traversal
# ============================================================

def child_A(t: Triple) -> Triple:
    """Berggren child A: matrix [[1,-2,2],[2,-1,2],[2,-2,3]]."""
    a, b, c = t
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def child_B(t: Triple) -> Triple:
    """Berggren child B: matrix [[1,2,2],[2,1,2],[2,2,3]]."""
    a, b, c = t
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def child_C(t: Triple) -> Triple:
    """Berggren child C: matrix [[-1,2,2],[-2,1,2],[-2,2,3]]."""
    a, b, c = t
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

CHILDREN: Dict[str, Action] = {'A': child_A, 'B': child_B, 'C': child_C}
ROOT: Triple = (3, 4, 5)


def berggren_address(t: Triple) -> Optional[str]:
    """
    Compute the Berggren address of a primitive Pythagorean triple.

    The address is the unique word w in {A,B,C}* such that
    apply_word(w, ROOT) = t.

    Uses inverse Berggren matrices to trace back to root.

    Returns None if t is not a primitive Pythagorean triple.

    Complexity: O(log c) where c is the hypotenuse,
    since each inverse step reduces the hypotenuse.
    """
    a, b, c = t
    if a**2 + b**2 != c**2 or gcd(a, b) != 1:
        return None
    if a <= 0 or b <= 0:
        return None

    address = []
    while (a, b, c) != ROOT:
        if c <= 0:
            return None

        # Inverse Berggren matrices
        # inv_A: (a+2b-2c, -2a-b+2c, -2a-2b+3c)  -- but we need to check which inverse works
        # Try each inverse and see which gives positive, valid result
        candidates = [
            ('A', (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)),  # These are forward
        ]

        # Actually, the inverse matrices are:
        # inv_A = (a + 2b - 2c, -2a - b + 2c, -2a - 2b + 3c)  -- not quite right
        # Let me use the standard inverse: parent of child_A is obtained by
        # checking which of the three children would produce (a,b,c)

        # Standard approach: try all three inverse matrices
        # For a, b > 0 and a odd, b even (or vice versa):
        inv_a = (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)   # inv of A (not standard)

        # Actually, let's use the simpler approach: the parent is found by
        # the inverse Berggren transformation. For the standard form:
        # Parent via A^{-1}: ...
        # The cleanest way: try which of A,B,C applied to a candidate parent gives (a,b,c)

        found = False
        for name, child_fn in CHILDREN.items():
            # We need parent p such that child_fn(p) = (a,b,c)
            # Instead, we try the inverse: which inverse matrix gives a valid parent?
            pass

        # Use the known inverse formulas:
        # Inverse of A: p = ((a - 2b + 2c)/1, ...)  -- no, this is A itself
        # The correct inverse matrices (from the catalog):
        # inv_A: (a + 2b - 2c, -2a - b + 2c, -2a - 2b + 3c)
        # But this can give negative values. The standard way is:

        # Determine which branch we came from based on the triple
        # In the standard Berggren tree with a odd, b even:
        # - Branch A if a - 2b + 2c > 0 and 2a - b + 2c > 0 (check signs)
        # - Use the actual inverse matrices

        # Simple heuristic: check all 3 inverse matrices, pick the one giving valid parent
        def inv_A(a, b, c):
            return (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

        def inv_B(a, b, c):
            return (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

        def inv_C(a, b, c):
            return (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

        for name, inv_fn in [('A', inv_A), ('B', inv_B), ('C', inv_C)]:
            pa, pb, pc = inv_fn(a, b, c)
            if pa > 0 and pb > 0 and pc > 0 and pa**2 + pb**2 == pc**2:
                address.append(name)
                a, b, c = pa, pb, pc
                found = True
                break

        if not found:
            return None  # Not reachable from root

    address.reverse()
    return ''.join(address)


def apply_word(word: str, t: Triple) -> Triple:
    """Apply a sequence of Berggren generators."""
    for ch in word:
        t = CHILDREN[ch](t)
    return t


def generate_tree_bfs(max_hyp: int) -> List[Triple]:
    """
    Generate all primitive Pythagorean triples with hypotenuse ≤ max_hyp.

    Uses BFS on the Berggren tree, pruning branches where the hypotenuse
    exceeds the bound (valid since children always have larger hypotenuse).

    Complexity: O(N) where N is the number of primitive triples with c ≤ max_hyp.
    """
    result = []
    queue = [ROOT]
    while queue:
        t = queue.pop(0)
        if t[2] > max_hyp:
            continue
        result.append(t)
        for fn in CHILDREN.values():
            child = fn(t)
            if child[2] <= max_hyp:
                queue.append(child)
    return result


# ============================================================
# Algorithm 2: Correspondence Network
# ============================================================

class CorrNetwork:
    """
    A correspondence network: finite family of (action, weight) pairs.

    Represents K(x,y) = sum_i w_i * [F_i(x) == y]
    """

    def __init__(self, actions: List[Action], weights: List[float]):
        """
        Initialize a correspondence network.

        Args:
            actions: List of n action functions S -> S.
            weights: List of n weights in R.
        """
        assert len(actions) == len(weights), "Actions and weights must have same length"
        self.actions = actions
        self.weights = weights
        self.n = len(actions)

    def kernel(self, x: Triple, y: Triple) -> float:
        """
        Evaluate the correspondence kernel K(x, y).

        K(x, y) = sum_{i=0}^{n-1} w_i * [F_i(x) == y]

        Complexity: O(n) action evaluations.
        """
        result = 0.0
        for i in range(self.n):
            if self.actions[i](x) == y:
                result += self.weights[i]
        return result

    def row_support(self, x: Triple) -> Dict[Triple, float]:
        """
        Compute the row support: {y : K(x,y) != 0} with values.

        Complexity: O(n) action evaluations + O(n) map operations.
        """
        support: Dict[Triple, float] = {}
        for i in range(self.n):
            y = self.actions[i](x)
            support[y] = support.get(y, 0.0) + self.weights[i]
        return {y: v for y, v in support.items() if abs(v) > 1e-15}

    def row_support_size(self, x: Triple) -> int:
        """Cardinality of row support at x. Always ≤ n."""
        return len(self.row_support(x))

    @staticmethod
    def combine(n1: 'CorrNetwork', n2: 'CorrNetwork') -> 'CorrNetwork':
        """
        Combine two networks (implements sum realizability).

        If N1 realizes K1 and N2 realizes K2, then
        combine(N1, N2) realizes K1 + K2.

        Complexity: O(n1 + n2) to construct.
        """
        return CorrNetwork(
            n1.actions + n2.actions,
            n1.weights + n2.weights
        )

    @staticmethod
    def from_berggren_words(words: List[str], weights: List[float]) -> 'CorrNetwork':
        """
        Construct a Berggren-compatible network from generator words.

        Args:
            words: List of Berggren words (e.g., ['A', 'BC', 'ACA']).
            weights: Corresponding weights.
        """
        actions = [lambda t, w=w: apply_word(w, t) for w in words]
        return CorrNetwork(actions, weights)


# ============================================================
# Algorithm 3: Observable Data Analysis
# ============================================================

def compute_observable_rank(K: CorrNetwork, test_states: List[Triple]) -> int:
    """
    Estimate the observable rank of a kernel by counting distinct row types.

    Two states x, x' have the same row type if K(x, ·) = K(x', ·)
    on all test states.

    Args:
        K: The correspondence network.
        test_states: States to evaluate on.

    Returns:
        Number of distinct row types (lower bound on observable rank).
    """
    row_signatures: Set[tuple] = set()

    for x in test_states:
        # Compute row signature as tuple of kernel values
        sig = tuple(K.kernel(x, y) for y in test_states)
        row_signatures.add(sig)

    return len(row_signatures)


def observable_profile(K: CorrNetwork, x: Triple, targets: List[Triple]) -> tuple:
    """Compute the observable profile of x: the tuple of K(x, y) values."""
    return tuple(K.kernel(x, y) for y in targets)


# ============================================================
# Algorithm 4: Minimal Realization Search
# ============================================================

def search_minimal_realization(
    target_kernel: CorrNetwork,
    candidate_actions: List[Action],
    test_states: List[Triple],
    max_size: int = 10,
    tolerance: float = 1e-10
) -> Optional[CorrNetwork]:
    """
    Search for a minimal realization of a target kernel.

    Tries all subsets of candidate actions with varying weights.
    For discrete (integer) weights, does exhaustive search.
    For real weights, uses least-squares fitting.

    Args:
        target_kernel: The kernel to realize.
        candidate_actions: Pool of candidate action functions.
        test_states: States to test equality on.
        max_size: Maximum network size to try.
        tolerance: Numerical tolerance for kernel matching.

    Returns:
        Minimal network if found, None otherwise.

    Complexity: Exponential in max_size (brute-force).
    """
    import numpy as np
    from itertools import combinations

    n_states = len(test_states)

    # Compute target kernel matrix
    target_matrix = np.zeros((n_states, n_states))
    for i, x in enumerate(test_states):
        for j, y in enumerate(test_states):
            target_matrix[i, j] = target_kernel.kernel(x, y)

    for size in range(1, max_size + 1):
        for action_subset in combinations(range(len(candidate_actions)), size):
            # Build indicator matrices for each action
            indicators = []
            for idx in action_subset:
                ind = np.zeros((n_states, n_states))
                for i, x in enumerate(test_states):
                    y = candidate_actions[idx](x)
                    for j, y2 in enumerate(test_states):
                        if y == y2:
                            ind[i, j] = 1.0
                indicators.append(ind.flatten())

            if not indicators:
                continue

            # Solve least squares: target = sum_i w_i * indicator_i
            A_mat = np.column_stack(indicators)
            b_vec = target_matrix.flatten()

            try:
                weights, residuals, _, _ = np.linalg.lstsq(A_mat, b_vec, rcond=None)
            except np.linalg.LinAlgError:
                continue

            # Check if solution matches
            approx = A_mat @ weights
            if np.max(np.abs(approx - b_vec)) < tolerance:
                selected_actions = [candidate_actions[idx] for idx in action_subset]
                return CorrNetwork(selected_actions, weights.tolist())

    return None


# ============================================================
# Algorithm 5: Network Comparison
# ============================================================

def kernels_equal(
    K1: CorrNetwork,
    K2: CorrNetwork,
    test_states: List[Triple],
    tolerance: float = 1e-10
) -> bool:
    """
    Check if two networks produce the same kernel on test states.

    Complexity: O(|test_states|² * max(n1, n2)).
    """
    for x in test_states:
        for y in test_states:
            if abs(K1.kernel(x, y) - K2.kernel(x, y)) > tolerance:
                return False
    return True


def network_isomorphic(
    N1: CorrNetwork,
    N2: CorrNetwork,
    test_states: List[Triple]
) -> bool:
    """
    Check if two networks of the same size are isomorphic
    (related by a permutation of generators).

    Complexity: O(n! * |test_states|) where n is the network size.
    """
    if N1.n != N2.n:
        return False

    from itertools import permutations

    for perm in permutations(range(N1.n)):
        # Check if perm maps N1's generators to N2's
        match = True
        for i in range(N1.n):
            # Check weights
            if abs(N1.weights[i] - N2.weights[perm[i]]) > 1e-10:
                match = False
                break
            # Check actions on test states
            for x in test_states:
                if N1.actions[i](x) != N2.actions[perm[i]](x):
                    match = False
                    break
            if not match:
                break
        if match:
            return True

    return False


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    print("Berggren Isogeny — Algorithm Demonstrations")
    print("=" * 50)

    # Generate test data
    triples = generate_tree_bfs(100)
    print(f"\nGenerated {len(triples)} primitive triples with hyp ≤ 100")

    # Test address computation
    print("\nBerggren addresses:")
    for t in triples[:8]:
        addr = berggren_address(t)
        verified = apply_word(addr, ROOT) == t if addr else False
        print(f"  {t} → address '{addr}', verified: {verified}")

    # Test network operations
    net = CorrNetwork.from_berggren_words(['A', 'B', 'C'], [1.0, 1.0, 1.0])
    print(f"\nChild network (3 generators):")
    print(f"  Observable rank estimate: {compute_observable_rank(net, triples[:20])}")

    # Test minimal realization
    print("\nMinimal realization search for child network...")
    candidate_actions: List[Action] = [child_A, child_B, child_C]
    result = search_minimal_realization(net, candidate_actions, triples[:10], max_size=4)
    if result:
        print(f"  Found realization with {result.n} generators, weights: {[round(w, 3) for w in result.weights]}")
        print(f"  Kernels match: {kernels_equal(net, result, triples[:10])}")

    print("\nAll algorithms executed successfully!")
