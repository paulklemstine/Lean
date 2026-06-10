#!/usr/bin/env python3
"""
Closure-Hankel Realization Theory: Applications

Real-world applications of the closure-Hankel realization framework:

1. Tropical scheduling: Shortest/longest path analysis in discrete event systems
2. Weighted automata learning: Extracting minimal models from behavioral data
3. Signal compression: Finite-rank approximation of sequential behaviors
4. Network routing: Path cost analysis with saturation constraints

Usage:
    python applications.py
"""

import numpy as np
from algorithms import (
    HankelRealizer, LinearRealization,
    detect_rank_stabilization, TruncationClosure
)


# ============================================================
# Application 1: Tropical Scheduling (Discrete Event Systems)
# ============================================================

def app_tropical_scheduling():
    """
    Model a manufacturing pipeline as a max-plus linear system.

    In discrete event systems, the state evolution follows max-plus
    dynamics: x(k+1) = A ⊗ x(k) where ⊗ is max-plus multiplication.

    The Hankel realization theorem tells us: if we observe the
    input-output behavior of the system, we can reconstruct the
    minimal internal state model.
    """
    print("=" * 60)
    print("Application 1: Tropical Scheduling (Manufacturing Pipeline)")
    print("=" * 60)

    # A factory with 3 workstations
    # 'a' = process batch at station 1 (takes 3 time units)
    # 'b' = process batch at station 2 (takes 2 time units)
    # B(w) = total processing time for sequence w

    def processing_time(schedule: str) -> float:
        """Total processing time with parallelism constraints.
        Each step takes time based on the station and adds setup time."""
        if not schedule:
            return 0.0
        times = {'a': 3.0, 'b': 2.0}
        total = 0.0
        last = None
        for step in schedule:
            t = times.get(step, 1.0)
            # Setup time when switching stations
            if last is not None and last != step:
                t += 1.0  # Switch penalty
            total += t
            last = step
        return total

    alphabet = ['a', 'b']
    realizer = HankelRealizer(processing_time, alphabet)

    # Analyze Hankel structure
    rank, _, _ = realizer.compute_rank(max_depth=4)
    print(f"\nProcessing time behavior: B(schedule) = total time")
    print(f"Hankel rank: {rank}")

    # Extract realization
    realization = realizer.extract_realization(max_depth=4)
    if realization:
        correct, max_error = realizer.verify_realization(realization)
        print(f"Extracted model: {realization.dim} internal states")
        print(f"Verification: {'PASS' if correct else 'FAIL'} (max error: {max_error:.2e})")

    # Show predictions
    print("\nSchedule optimization (comparing sequences):")
    schedules = ['aabb', 'abab', 'abba', 'bbaa', 'baba', 'baab']
    for s in schedules:
        t = processing_time(s)
        t_pred = realization.evaluate(s) if realization else '?'
        print(f"  Schedule '{s}': time = {t:.1f}" +
              (f", predicted = {t_pred:.1f}" if realization else ""))

    optimal = min(schedules, key=processing_time)
    print(f"  Optimal: '{optimal}' with time {processing_time(optimal):.1f}")
    print()


# ============================================================
# Application 2: Weighted Automata Learning
# ============================================================

def app_automata_learning():
    """
    Learn a minimal weighted automaton from behavioral observations.

    Given black-box access to a behavior (e.g., a probability distribution
    over strings), extract the minimal weighted automaton that generates it.
    This is the practical instantiation of the Hankel realization theorem.
    """
    print("=" * 60)
    print("Application 2: Weighted Automata Learning from Data")
    print("=" * 60)

    # Hidden weighted automaton (the "ground truth" we want to learn)
    # 3-state WFA over {a, b}
    true_alpha = np.array([1.0, 0.0, 0.0])
    true_beta = np.array([0.5, 0.3, 0.2])
    true_A = {
        'a': np.array([[0.6, 0.3, 0.1],
                       [0.0, 0.7, 0.3],
                       [0.2, 0.0, 0.8]]),
        'b': np.array([[0.4, 0.5, 0.1],
                       [0.3, 0.2, 0.5],
                       [0.1, 0.4, 0.5]])
    }

    true_model = LinearRealization(
        dim=3, alpha=true_alpha, beta=true_beta,
        transitions=true_A, alphabet=['a', 'b']
    )

    def behavior(w: str) -> float:
        return true_model.evaluate(w)

    # Learn the model from behavioral observations
    alphabet = ['a', 'b']
    realizer = HankelRealizer(behavior, alphabet)

    rank, _, _ = realizer.compute_rank(max_depth=5)
    print(f"\nTrue model: {true_model.dim} states")
    print(f"Observed Hankel rank: {rank}")

    learned = realizer.extract_realization(max_depth=5)
    if learned:
        correct, max_error = realizer.verify_realization(learned, tol=1e-4)
        print(f"Learned model: {learned.dim} states")
        print(f"Verification: {'PASS' if correct else 'FAIL'} (max error: {max_error:.2e})")

        # Compare on test words
        print("\nComparison (true vs learned):")
        test_words = ['', 'a', 'b', 'ab', 'ba', 'aab', 'abb', 'bab', 'abab']
        for w in test_words:
            true_val = behavior(w)
            learned_val = learned.evaluate(w)
            err = abs(true_val - learned_val)
            print(f"  B('{w}'): true={true_val:.6f}, learned={learned_val:.6f}, "
                  f"error={err:.2e}")
    print()


# ============================================================
# Application 3: Signal Compression via Rank Truncation
# ============================================================

def app_signal_compression():
    """
    Compress a sequential signal by finding a low-rank
    approximation of its Hankel matrix.

    This is analogous to singular value decomposition for matrices,
    but applied to the Hankel structure of a behavioral signal.
    """
    print("=" * 60)
    print("Application 3: Signal Compression via Hankel Truncation")
    print("=" * 60)

    # Complex behavior (sum of periodic components)
    def signal(w: str) -> float:
        """A signal with several frequency components."""
        n = len(w)
        count_a = sum(1 for c in w if c == 'a')
        count_b = n - count_a
        return (2.0 * np.sin(count_a * 0.5) +
                1.5 * np.cos(count_b * 0.7) +
                0.3 * count_a * count_b / max(n, 1))

    alphabet = ['a', 'b']
    realizer = HankelRealizer(signal, alphabet)

    # Full rank analysis
    print("\nSignal: B(w) = 2·sin(#a·0.5) + 1.5·cos(#b·0.7) + 0.3·#a·#b/|w|")

    for depth in range(2, 6):
        words = realizer._enumerate_words(depth)
        H = realizer.build_hankel_matrix(words, words)
        rank = np.linalg.matrix_rank(H, tol=1e-6)
        svs = np.linalg.svd(H, compute_uv=False)
        top_svs = svs[:min(8, len(svs))]
        print(f"  Depth {depth}: matrix {H.shape[0]}×{H.shape[1]}, "
              f"rank={rank}, top SVs={[f'{s:.2f}' for s in top_svs]}")

    # Extract compressed model
    realization = realizer.extract_realization(max_depth=4)
    if realization:
        correct, max_error = realizer.verify_realization(realization, tol=0.1)
        print(f"\nCompressed model: {realization.dim} states "
              f"(max error: {max_error:.4f})")

        # Compression ratio
        words = realizer._enumerate_words(4)
        original_params = len(words)  # Store all B(w) values
        compressed_params = (realization.dim * 2 +
                             realization.dim ** 2 * len(alphabet))
        print(f"Original data points: {original_params}")
        print(f"Compressed parameters: {compressed_params}")
        if compressed_params > 0:
            print(f"Compression ratio: {original_params / compressed_params:.1f}x")
    print()


# ============================================================
# Application 4: Network Routing with Capacity Constraints
# ============================================================

def app_network_routing():
    """
    Model network routing where path costs saturate at capacity limits.

    This demonstrates the closure aspect: the truncation closure
    models capacity constraints, and the Hankel realization of the
    closed behavior gives the minimal routing model.
    """
    print("=" * 60)
    print("Application 4: Network Routing with Capacity Constraints")
    print("=" * 60)

    # Network cost function
    def routing_cost(path: str) -> float:
        """Cost of routing through a network.
        'a' = cheap link (cost 1), 'b' = expensive link (cost 3)."""
        if not path:
            return 0.0
        costs = {'a': 1.0, 'b': 3.0}
        return sum(costs.get(c, 0.0) for c in path)

    # Capacity constraint: total cost capped at 10
    capacity = 10.0
    closure = TruncationClosure(capacity)
    closed_cost = closure(routing_cost)

    alphabet = ['a', 'b']

    # Analyze original vs closed behavior
    realizer_orig = HankelRealizer(routing_cost, alphabet)
    realizer_closed = HankelRealizer(closed_cost, alphabet)

    rank_orig, _, _ = realizer_orig.compute_rank(max_depth=4)
    rank_closed, _, _ = realizer_closed.compute_rank(max_depth=4)

    print(f"\nRouting cost: B(path) = sum of link costs (a=1, b=3)")
    print(f"Capacity constraint: cl(B)(path) = min(B(path), {capacity})")
    print(f"Hankel rank (original): {rank_orig}")
    print(f"Hankel rank (closed):   {rank_closed}")

    # Show effect of closure
    print("\nPath cost comparison:")
    paths = ['', 'a', 'b', 'aaa', 'aab', 'abb', 'bbb',
             'aaaa', 'aabb', 'abbb', 'bbbb', 'aaaaa']
    for p in paths:
        orig = routing_cost(p)
        closed = closed_cost(p)
        saturated = " (saturated)" if closed < orig else ""
        print(f"  '{p}': cost={orig:.0f}, capped={closed:.0f}{saturated}")

    # Extract closed realization
    realization = realizer_closed.extract_realization(max_depth=4)
    if realization:
        correct, max_error = realizer_closed.verify_realization(realization, tol=0.5)
        print(f"\nClosed behavior realization: {realization.dim} states "
              f"(max error: {max_error:.2f})")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Closure-Hankel Realization: Real-World Applications    ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    app_tropical_scheduling()
    app_automata_learning()
    app_signal_compression()
    app_network_routing()

    print("All applications completed.")


#!/usr/bin/env python3
"""
Closure-Hankel Realization Theory: Demonstrations

This module demonstrates the core constructs of closure-Hankel realization
theory with concrete numerical examples over idempotent semirings (tropical,
max-plus, min-plus, Boolean).

Run: python demo.py
"""

import numpy as np
from itertools import product


# ============================================================
# Idempotent Semiring Implementations
# ============================================================

class MaxPlusSemiring:
    """The max-plus (tropical) semiring: (R ∪ {-∞}, max, +)."""
    NEG_INF = float('-inf')

    @staticmethod
    def zero():
        return MaxPlusSemiring.NEG_INF

    @staticmethod
    def one():
        return 0.0

    @staticmethod
    def add(a, b):
        return max(a, b)

    @staticmethod
    def mul(a, b):
        if a == MaxPlusSemiring.NEG_INF or b == MaxPlusSemiring.NEG_INF:
            return MaxPlusSemiring.NEG_INF
        return a + b

    @staticmethod
    def name():
        return "Max-Plus (Tropical)"


class MinPlusSemiring:
    """The min-plus semiring: (R ∪ {+∞}, min, +)."""
    POS_INF = float('inf')

    @staticmethod
    def zero():
        return MinPlusSemiring.POS_INF

    @staticmethod
    def one():
        return 0.0

    @staticmethod
    def add(a, b):
        return min(a, b)

    @staticmethod
    def mul(a, b):
        if a == MinPlusSemiring.POS_INF or b == MinPlusSemiring.POS_INF:
            return MinPlusSemiring.POS_INF
        return a + b

    @staticmethod
    def name():
        return "Min-Plus"


class BooleanSemiring:
    """The Boolean semiring: ({0, 1}, max, min) = ({False, True}, ∨, ∧)."""

    @staticmethod
    def zero():
        return 0

    @staticmethod
    def one():
        return 1

    @staticmethod
    def add(a, b):
        return max(a, b)  # OR

    @staticmethod
    def mul(a, b):
        return min(a, b)  # AND

    @staticmethod
    def name():
        return "Boolean (OR, AND)"


# ============================================================
# Core Operations
# ============================================================

def dot_prod(alpha, beta, S):
    """Dot product α · β over semiring S."""
    result = S.zero()
    for a, b in zip(alpha, beta):
        result = S.add(result, S.mul(a, b))
    return result


def mat_vec_mul(M, x, S):
    """Matrix-vector multiplication over semiring S."""
    n = len(x)
    result = [S.zero()] * n
    for i in range(n):
        for j in range(n):
            result[i] = S.add(result[i], S.mul(M[i][j], x[j]))
    return result


def word_action(transitions, word, beta, S):
    """Compute A_w · β: apply transitions along word left-to-right."""
    state = list(beta)
    for a in word:
        state = mat_vec_mul(transitions[a], state, S)
    return state


def eval_linear_system(alpha, beta, transitions, word, S):
    """Evaluate α · A_w · β for a linear system."""
    state = word_action(transitions, word, beta, S)
    return dot_prod(alpha, state, S)


def hankel_entry(behavior, u, v):
    """Hankel entry H(u,v) = B(u ++ v)."""
    return behavior(u + v)


def build_hankel_matrix(behavior, prefixes, suffixes):
    """Build the Hankel (sub)matrix for given prefix/suffix sets."""
    return [[hankel_entry(behavior, u, v) for v in suffixes] for u in prefixes]


# ============================================================
# Demo 1: Shortest Path Behavior (Min-Plus)
# ============================================================

def demo_shortest_path():
    """
    Demonstrate Hankel realization for a shortest-path behavior
    over the min-plus semiring.

    Consider a 2-node graph with alphabet {a, b}:
    - 'a' moves along edge of weight 3
    - 'b' moves along edge of weight 1
    The behavior B(w) is the cost of the path spelled by w.
    """
    S = MinPlusSemiring
    print("=" * 60)
    print("Demo 1: Shortest Path Behavior (Min-Plus Semiring)")
    print("=" * 60)

    # Define realization: 2-state system
    n = 2
    alpha = [0.0, S.POS_INF]  # Start at node 0
    beta = [0.0, S.POS_INF]   # Observe at node 0

    # Transition matrices (min-plus)
    A = {
        'a': [[S.POS_INF, 3.0],
              [2.0, S.POS_INF]],
        'b': [[1.0, S.POS_INF],
              [S.POS_INF, 1.0]]
    }

    def behavior(w):
        return eval_linear_system(alpha, beta, A, w, S)

    # Show some evaluations
    print("\nBehavior B(w) = minimum cost path along word w:")
    words = ['', 'a', 'b', 'aa', 'ab', 'ba', 'bb', 'aba', 'bab', 'aabb']
    for w in words:
        val = behavior(w)
        print(f"  B('{w}') = {val}")

    # Build Hankel matrix
    prefixes = ['', 'a', 'b', 'ab']
    suffixes = ['', 'a', 'b', 'ab']
    H = build_hankel_matrix(behavior, prefixes, suffixes)

    print("\nHankel submatrix (prefixes × suffixes):")
    header = "        " + "  ".join(f"'{s}':".ljust(8) for s in suffixes)
    print(header)
    for i, u in enumerate(prefixes):
        row = f"  '{u}':".ljust(8) + "  ".join(f"{H[i][j]:.1f}".ljust(8) for j in range(len(suffixes)))
        print(row)

    # Verify realization
    print("\nVerification: B(w) = α · A_w · β")
    for w in words[:6]:
        val = behavior(w)
        state = word_action(A, w, beta, S)
        result = dot_prod(alpha, state, S)
        print(f"  w='{w}': state={[f'{x:.1f}' for x in state]}, "
              f"α·state={result:.1f}, B(w)={val:.1f} {'✓' if result == val else '✗'}")

    print()


# ============================================================
# Demo 2: Regular Language (Boolean Semiring)
# ============================================================

def demo_regular_language():
    """
    Demonstrate Hankel realization for a regular language
    (strings containing 'ab' as a substring) over the Boolean semiring.
    This recovers classical Myhill-Nerode theory.
    """
    S = BooleanSemiring
    print("=" * 60)
    print("Demo 2: Regular Language (Boolean Semiring = Myhill-Nerode)")
    print("=" * 60)

    # Language: strings over {a, b} containing 'ab' as a substring
    # States: 0 = initial (no 'a' seen), 1 = 'a' seen, 2 = 'ab' seen (accept)
    n = 3
    alpha = [0, 0, 1]  # Accept state 2
    beta = [1, 0, 0]   # Start at state 0

    A = {
        'a': [[0, 0, 0],
              [1, 1, 0],
              [0, 0, 1]],
        'b': [[1, 0, 0],
              [0, 0, 0],
              [0, 1, 1]]
    }

    def behavior(w):
        return eval_linear_system(alpha, beta, A, w, S)

    # Show some evaluations
    print("\nBehavior B(w) = 1 iff w contains 'ab':")
    words = ['', 'a', 'b', 'aa', 'ab', 'ba', 'bb', 'aab', 'aba', 'bab', 'bba']
    for w in words:
        val = behavior(w)
        contains_ab = 1 if 'ab' in w else 0
        print(f"  B('{w}') = {val}  (expected: {contains_ab}) {'✓' if val == contains_ab else '✗'}")

    # Build Hankel matrix
    prefixes = ['', 'a', 'b', 'ab']
    suffixes = ['', 'a', 'b', 'ab']
    H = build_hankel_matrix(behavior, prefixes, suffixes)

    print("\nHankel submatrix:")
    header = "        " + "  ".join(f"'{s}'".ljust(6) for s in suffixes)
    print(header)
    for i, u in enumerate(prefixes):
        row = f"  '{u}'".ljust(8) + "  ".join(f"{H[i][j]}".ljust(6) for j in range(len(suffixes)))
        print(row)

    # Count distinct rows
    unique_rows = set()
    for u in prefixes:
        row = tuple(hankel_entry(behavior, u, v) for v in suffixes)
        unique_rows.add(row)
    print(f"\nDistinct Hankel rows: {len(unique_rows)} (= Myhill-Nerode classes)")
    print()


# ============================================================
# Demo 3: Max-Plus Tropical Behavior
# ============================================================

def demo_tropical():
    """
    Demonstrate Hankel realization for a max-plus tropical behavior.
    Models maximum reward accumulation along paths.
    """
    S = MaxPlusSemiring
    print("=" * 60)
    print("Demo 3: Maximum Reward Behavior (Max-Plus/Tropical)")
    print("=" * 60)

    # 2-state system: maximum reward path
    n = 2
    alpha = [0.0, 0.0]        # Observe max of both states
    beta = [0.0, S.NEG_INF]   # Start at state 0

    A = {
        'a': [[2.0, S.NEG_INF],
              [S.NEG_INF, 1.0]],
        'b': [[S.NEG_INF, 3.0],
              [1.0, S.NEG_INF]]
    }

    def behavior(w):
        return eval_linear_system(alpha, beta, A, w, S)

    print("\nBehavior B(w) = maximum reward along word w:")
    words = ['', 'a', 'b', 'aa', 'ab', 'ba', 'bb', 'aba', 'bab', 'abab']
    for w in words:
        val = behavior(w)
        print(f"  B('{w}') = {val}")

    # Build and display Hankel matrix
    prefixes = ['', 'a', 'b', 'ab', 'ba']
    suffixes = ['', 'a', 'b', 'ab']
    H = build_hankel_matrix(behavior, prefixes, suffixes)

    print("\nHankel submatrix (max-plus):")
    header = "        " + "  ".join(f"'{s}'".ljust(8) for s in suffixes)
    print(header)
    for i, u in enumerate(prefixes):
        row = f"  '{u}'".ljust(8) + "  ".join(
            f"{H[i][j]:.1f}".ljust(8) if H[i][j] != S.NEG_INF else "-∞".ljust(8)
            for j in range(len(suffixes)))
        print(row)

    print()


# ============================================================
# Demo 4: Hankel Rank Computation and Realization Extraction
# ============================================================

def demo_hankel_rank():
    """
    Demonstrate computation of Hankel rank and extraction of
    a minimal realization from Hankel data.
    """
    print("=" * 60)
    print("Demo 4: Hankel Rank and Realization Extraction")
    print("=" * 60)

    # Simple behavior over natural numbers (standard semiring)
    # B(w) = number of 'a's in w (over alphabet {a, b})
    def count_a(w):
        return sum(1 for c in w if c == 'a')

    # Generate Hankel matrix
    alphabet = ['a', 'b']
    max_len = 3

    def all_words(max_length):
        words = ['']
        for length in range(1, max_length + 1):
            for w in product(alphabet, repeat=length):
                words.append(''.join(w))
        return words

    words = all_words(max_len)
    prefixes = words[:10]
    suffixes = words[:10]

    H = build_hankel_matrix(count_a, prefixes, suffixes)

    print(f"\nBehavior: B(w) = number of 'a's in w")
    print(f"Generated {len(prefixes)}×{len(suffixes)} Hankel submatrix")

    # Compute rank (over reals as approximation)
    H_np = np.array(H, dtype=float)
    rank = np.linalg.matrix_rank(H_np)
    print(f"Numerical rank of Hankel matrix: {rank}")

    # Show the Hankel matrix structure
    print("\nHankel matrix (first 6×6):")
    for i in range(min(6, len(prefixes))):
        row = [f"{H[i][j]:2d}" for j in range(min(6, len(suffixes)))]
        print(f"  {prefixes[i]:6s}: {' '.join(row)}")

    # Construct realization (by hand for this example)
    # B(w) = #a(w). Realization: n=2, α=(0,1), β=(1,0),
    # A(a) = [[1,0],[1,1]], A(b) = [[1,0],[0,1]]
    # State tracks (1, count_so_far)
    print("\nConstructed realization:")
    print("  n = 2, α = (0, 1), β = (1, 0)")
    print("  A(a) = [[1,0],[1,1]], A(b) = [[1,0],[0,1]]")

    # Verify
    class NatSemiring:
        @staticmethod
        def zero(): return 0
        @staticmethod
        def one(): return 1
        @staticmethod
        def add(a, b): return a + b
        @staticmethod
        def mul(a, b): return a * b

    S = NatSemiring
    alpha = [0, 1]
    beta = [1, 0]
    A_real = {
        'a': [[1, 0], [1, 1]],
        'b': [[1, 0], [0, 1]]
    }

    print("\nVerification:")
    for w in ['', 'a', 'b', 'aa', 'ab', 'aab', 'aba', 'baa']:
        expected = count_a(w)
        computed = eval_linear_system(alpha, beta, A_real, w, S)
        print(f"  B('{w}') = {expected}, eval = {computed} {'✓' if expected == computed else '✗'}")

    print()


# ============================================================
# Demo 5: Closure Operator Effect
# ============================================================

def demo_closure():
    """
    Demonstrate how a closure operator transforms a behavior
    and affects the Hankel structure.
    """
    print("=" * 60)
    print("Demo 5: Closure Operator and Behavior Transformation")
    print("=" * 60)

    S = MaxPlusSemiring

    # Original behavior: max weight along a simple path
    def original_behavior(w):
        """Simple max-plus behavior: sum of letter weights."""
        weight = {'a': 2.0, 'b': 1.0}
        if not w:
            return 0.0
        return sum(weight.get(c, 0.0) for c in w)

    # Closure operator: saturation / ceiling
    def closure(B):
        """Identity closure: cl(B) = B (simplest EML closure)."""
        return B

    # More interesting: truncation closure
    def truncation_closure(B, cap=5.0):
        """Truncation closure: caps the behavior at a maximum value."""
        def clB(w):
            return min(B(w), cap)
        return clB

    print("\nOriginal behavior B(w) = sum of letter weights (a=2, b=1):")
    words = ['', 'a', 'b', 'aa', 'ab', 'aaa', 'aab', 'aaaa']
    for w in words:
        print(f"  B('{w}') = {original_behavior(w)}")

    cl_B = truncation_closure(original_behavior, cap=5.0)
    print("\nClosed behavior cl(B)(w) = min(B(w), 5):")
    for w in words:
        print(f"  cl(B)('{w}') = {cl_B(w)}")

    # Hankel matrices
    prefixes = ['', 'a', 'b', 'aa']
    suffixes = ['', 'a', 'b', 'aa']

    H_orig = build_hankel_matrix(original_behavior, prefixes, suffixes)
    H_cl = build_hankel_matrix(cl_B, prefixes, suffixes)

    print("\nOriginal Hankel matrix:")
    for i, u in enumerate(prefixes):
        print(f"  '{u}': {[H_orig[i][j] for j in range(len(suffixes))]}")

    print("\nClosed Hankel matrix:")
    for i, u in enumerate(prefixes):
        print(f"  '{u}': {[H_cl[i][j] for j in range(len(suffixes))]}")

    # Rank comparison
    rank_orig = np.linalg.matrix_rank(np.array(H_orig, dtype=float))
    rank_cl = np.linalg.matrix_rank(np.array(H_cl, dtype=float))
    print(f"\nRank of original Hankel: {rank_orig}")
    print(f"Rank of closed Hankel:   {rank_cl}")
    print("(Closure can reduce rank by collapsing distinctions)")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Closure-Hankel Realization Theory: Interactive Demos   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_shortest_path()
    demo_regular_language()
    demo_tropical()
    demo_hankel_rank()
    demo_closure()

    print("All demos completed successfully.")


#!/usr/bin/env python3
"""
Closure-Hankel Realization Theory: Visualizations

Generates publication-quality figures showing key mathematical structures.
Saves as PNG files and returns base64 data for JSON packaging.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import base64
import io
from itertools import product


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def generate_all_words(alphabet, max_len):
    """Generate all words up to given length."""
    words = ['']
    for length in range(1, max_len + 1):
        for w in product(alphabet, repeat=length):
            words.append(''.join(w))
    return words


# ============================================================
# Visualization 1: Hankel Matrix Heatmap
# ============================================================

def viz_hankel_heatmap():
    """Visualize the Hankel matrix structure for different behaviors."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    alphabet = ['a', 'b']
    words = generate_all_words(alphabet, 3)[:16]

    behaviors = {
        'Count of a': lambda w: sum(1 for c in w if c == 'a'),
        'Word length': lambda w: len(w),
        'Contains ab': lambda w: 1 if 'ab' in w else 0,
    }

    for ax, (name, B) in zip(axes, behaviors.items()):
        H = np.array([[B(u + v) for v in words] for u in words])
        im = ax.imshow(H, cmap='YlOrRd', aspect='auto')
        ax.set_title(f'B(w) = {name}', fontsize=12, fontweight='bold')
        ax.set_xlabel('Suffix index', fontsize=10)
        ax.set_ylabel('Prefix index', fontsize=10)
        plt.colorbar(im, ax=ax, shrink=0.8)

        # Show rank
        rank = np.linalg.matrix_rank(H)
        ax.text(0.02, 0.98, f'Rank = {rank}', transform=ax.transAxes,
                fontsize=11, verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

    fig.suptitle('Hankel Matrix Structure for Different Behaviors',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_hankel_heatmap.png',
                dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ============================================================
# Visualization 2: Rank Stabilization
# ============================================================

def viz_rank_stabilization():
    """Show how Hankel rank stabilizes as window size increases."""
    fig, ax = plt.subplots(figsize=(10, 6))

    alphabet = ['a', 'b']

    behaviors = {
        'Count of a (rank 2)': lambda w: sum(1 for c in w if c == 'a'),
        'Word length (rank 2)': lambda w: len(w),
        'a-count mod 3 (rank 3)': lambda w: sum(1 for c in w if c == 'a') % 3,
        'Contains ab (rank 3)': lambda w: 1 if 'ab' in w else 0,
        'Constant (rank 1)': lambda w: 1,
    }

    colors = plt.cm.Set2(np.linspace(0, 1, len(behaviors)))

    for (name, B), color in zip(behaviors.items(), colors):
        depths = list(range(1, 6))
        ranks = []
        for d in depths:
            words = generate_all_words(alphabet, d)
            H = np.array([[B(u + v) for v in words] for u in words], dtype=float)
            ranks.append(np.linalg.matrix_rank(H))

        ax.plot(depths, ranks, 'o-', color=color, linewidth=2,
                markersize=8, label=name)

    ax.set_xlabel('Window Depth (max word length)', fontsize=12)
    ax.set_ylabel('Hankel Rank', fontsize=12)
    ax.set_title('Hankel Rank Stabilization', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.set_xticks(range(1, 6))
    ax.set_yticks(range(0, 6))
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, 5.5)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_rank_stabilization.png',
                dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ============================================================
# Visualization 3: Realization State Trajectories
# ============================================================

def viz_state_trajectories():
    """Visualize state trajectories of a linear realization."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # 2-state system for "count of a"
    alpha = np.array([0, 1])
    beta = np.array([1, 0])
    A = {
        'a': np.array([[1, 0], [1, 1]], dtype=float),
        'b': np.array([[1, 0], [0, 1]], dtype=float)
    }

    # Generate trajectories
    alphabet = ['a', 'b']
    words = generate_all_words(alphabet, 4)

    states_x = []
    states_y = []
    word_labels = []
    word_colors = []

    for w in words:
        state = beta.copy().astype(float)
        for c in w:
            state = A[c] @ state
        states_x.append(state[0])
        states_y.append(state[1])
        word_labels.append(w if len(w) <= 2 else '')
        word_colors.append(len(w))

    ax = axes[0]
    scatter = ax.scatter(states_x, states_y, c=word_colors, cmap='viridis',
                         s=50, alpha=0.7, edgecolors='black', linewidth=0.5)
    plt.colorbar(scatter, ax=ax, label='Word length')
    ax.set_xlabel('State component 1', fontsize=11)
    ax.set_ylabel('State component 2', fontsize=11)
    ax.set_title('State Space: B(w) = count of a', fontsize=12, fontweight='bold')

    for i, label in enumerate(word_labels):
        if label:
            ax.annotate(f"'{label}'", (states_x[i], states_y[i]),
                       textcoords="offset points", xytext=(5, 5), fontsize=8)

    # 3-state system for "contains ab"
    alpha2 = np.array([0, 0, 1], dtype=float)
    beta2 = np.array([1, 0, 0], dtype=float)
    A2 = {
        'a': np.array([[0, 0, 0], [1, 1, 0], [0, 0, 1]], dtype=float),
        'b': np.array([[1, 0, 0], [0, 0, 0], [0, 1, 1]], dtype=float)
    }

    words2 = generate_all_words(alphabet, 3)
    states2 = []
    colors2 = []

    for w in words2:
        state = beta2.copy()
        for c in w:
            state = A2[c] @ state
        states2.append(state)
        colors2.append(1 if 'ab' in w else 0)

    states2 = np.array(states2)

    ax2 = axes[1]
    for label, color, marker in [(0, 'blue', 'o'), (1, 'red', 's')]:
        mask = np.array(colors2) == label
        ax2.scatter(states2[mask, 0], states2[mask, 1],
                   c=color, marker=marker, s=60, alpha=0.7,
                   label=f"{'accepts' if label else 'rejects'}",
                   edgecolors='black', linewidth=0.5)

    ax2.set_xlabel('State component 1', fontsize=11)
    ax2.set_ylabel('State component 2', fontsize=11)
    ax2.set_title('State Space: B(w) = contains "ab"', fontsize=12, fontweight='bold')
    ax2.legend(fontsize=10)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_state_trajectories.png',
                dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ============================================================
# Visualization 4: Closure Effect on Hankel Structure
# ============================================================

def viz_closure_effect():
    """Visualize how closure operators transform the Hankel structure."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    alphabet = ['a', 'b']
    words = generate_all_words(alphabet, 3)[:12]

    # Original behavior
    def B(w):
        return sum(1 for c in w if c == 'a') + 0.5 * len(w)

    # Truncation closure
    def cl_trunc(w):
        return min(B(w), 4.0)

    # Saturation closure
    def cl_sat(w):
        v = B(w)
        return v / (1 + v / 5.0)

    closures = {
        'Original B(w)': B,
        'Truncation cl(B)': cl_trunc,
        'Saturation cl(B)': cl_sat,
    }

    for ax, (name, func) in zip(axes, closures.items()):
        H = np.array([[func(u + v) for v in words] for u in words])
        im = ax.imshow(H, cmap='coolwarm', aspect='auto')
        ax.set_title(name, fontsize=12, fontweight='bold')
        ax.set_xlabel('Suffix index', fontsize=10)
        ax.set_ylabel('Prefix index', fontsize=10)
        plt.colorbar(im, ax=ax, shrink=0.8)

        rank = np.linalg.matrix_rank(H, tol=1e-6)
        ax.text(0.02, 0.98, f'Rank ≈ {rank}', transform=ax.transAxes,
                fontsize=11, verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

    fig.suptitle('Effect of Closure Operators on Hankel Structure',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_closure_effect.png',
                dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ============================================================
# Main: Generate All Visualizations
# ============================================================

if __name__ == '__main__':
    print("Generating visualizations...")

    data = {}
    data['hankel_heatmap'] = viz_hankel_heatmap()
    print("  ✓ Hankel heatmap")

    data['rank_stabilization'] = viz_rank_stabilization()
    print("  ✓ Rank stabilization")

    data['state_trajectories'] = viz_state_trajectories()
    print("  ✓ State trajectories")

    data['closure_effect'] = viz_closure_effect()
    print("  ✓ Closure effect")

    print("\nAll visualizations generated.")
    print(f"Base64 data sizes: {', '.join(f'{k}: {len(v)//1024}KB' for k, v in data.items())}")
