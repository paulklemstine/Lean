#!/usr/bin/env python3
"""
Algorithms for Monotone Circuit Complexity Analysis

This module implements the key algorithms underlying the formal
monotone circuit complexity framework:

1. Approximation sandwich construction and validation
2. KW witness enumeration and compression analysis
3. Monotone circuit evaluation and size/depth analysis
4. Entropy computation for witness distributions
"""

import itertools
import math
import random
from typing import List, Tuple, Set, Dict, Optional, Callable
from collections import Counter


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Approximation Sandwich Construction
# ─────────────────────────────────────────────────────────────────────

def construct_approximation_sandwich(
    n: int,
    k: int,
    target_fn: Callable,
    num_pos: int = 50,
    num_neg: int = 50,
    seed: int = 42
) -> Dict:
    """
    Construct an approximation sandwich for a monotone Boolean function.

    Given a target function f (e.g., k-CLIQUE), constructs a pair (P, N) where:
    - P contains inputs where f evaluates to True
    - N contains inputs where f evaluates to False

    The sandwich is "certified" if f perfectly separates P and N.

    Time complexity: O(num_pos * T_f + num_neg * T_f) where T_f is the
    evaluation time of the target function.

    Args:
        n: Number of vertices in the graph
        k: Clique size parameter
        target_fn: Function (graph_edges) -> bool
        num_pos: Number of positive instances to generate
        num_neg: Number of negative instances to generate
        seed: Random seed for reproducibility

    Returns:
        Dictionary with 'positive', 'negative', 'certified' fields
    """
    rng = random.Random(seed)
    all_edges = list(itertools.combinations(range(n), 2))
    m = len(all_edges)

    positive = []
    negative = []

    # Generate positive instances: embed k-clique + random edges
    attempts = 0
    while len(positive) < num_pos and attempts < num_pos * 10:
        attempts += 1
        if k > n:
            break
        edges = set()
        # Embed a k-clique
        clique_verts = rng.sample(range(n), k)
        for u, v in itertools.combinations(clique_verts, 2):
            edges.add((min(u, v), max(u, v)))
        # Add random edges
        for e in all_edges:
            if rng.random() < 0.3:
                edges.add(e)
        edge_tuple = frozenset(edges)
        if target_fn(n, edges) and edge_tuple not in [frozenset(p) for p in positive]:
            positive.append(edges)

    # Generate negative instances: sparse random graphs
    attempts = 0
    while len(negative) < num_neg and attempts < num_neg * 10:
        attempts += 1
        edges = set()
        for e in all_edges:
            if rng.random() < 0.15:
                edges.add(e)
        if not target_fn(n, edges):
            edge_tuple = frozenset(edges)
            if edge_tuple not in [frozenset(neg) for neg in negative]:
                negative.append(edges)

    # Verify certification
    certified = all(target_fn(n, e) for e in positive) and \
                all(not target_fn(n, e) for e in negative)

    return {
        'positive': positive,
        'negative': negative,
        'certified': certified,
        'num_positive': len(positive),
        'num_negative': len(negative),
    }


def has_k_clique(n: int, edges: Set[Tuple[int, int]], k: int = 3) -> bool:
    """Check if graph (n, edges) contains a k-clique."""
    for subset in itertools.combinations(range(n), k):
        if all((min(u, v), max(u, v)) in edges
               for u, v in itertools.combinations(subset, 2)):
            return True
    return False


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: KW Witness Enumeration
# ─────────────────────────────────────────────────────────────────────

def enumerate_kw_witnesses_bitstring(
    n: int,
    f: Callable[[Tuple[bool, ...]], bool]
) -> List[Tuple[Tuple[bool, ...], Tuple[bool, ...], int]]:
    """
    Enumerate all KW witnesses for a Boolean function on {0,1}^n.

    A KW witness is a triple (x, y, i) where:
    - f(x) = True  (Alice's input)
    - f(y) = False (Bob's input)
    - x[i] ≠ y[i]  (distinguishing coordinate)

    Time complexity: O(2^(2n) * n)
    Space complexity: O(|witnesses|)

    Args:
        n: Input length
        f: Boolean function on n-bit strings

    Returns:
        List of (x, y, i) witness triples
    """
    witnesses = []
    true_inputs = [x for x in itertools.product([False, True], repeat=n) if f(x)]
    false_inputs = [y for y in itertools.product([False, True], repeat=n) if not f(y)]

    for x in true_inputs:
        for y in false_inputs:
            for i in range(n):
                if x[i] != y[i]:
                    witnesses.append((x, y, i))

    return witnesses


def kw_witness_distribution(witnesses: List) -> Dict[int, int]:
    """
    Compute the distribution of distinguishing coordinates.

    For each coordinate i, count how many witnesses use i as the
    distinguishing coordinate.

    Args:
        witnesses: List of (x, y, i) triples

    Returns:
        Dictionary mapping coordinate index to count
    """
    return dict(Counter(w[2] for w in witnesses))


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Shannon Entropy Computation
# ─────────────────────────────────────────────────────────────────────

def shannon_entropy(distribution: Dict, base: float = 2.0) -> float:
    """
    Compute Shannon entropy of a discrete distribution.

    H(X) = -Σ p(x) log_b(p(x))

    Time complexity: O(|support|)

    Args:
        distribution: Dictionary mapping outcomes to counts/probabilities
        base: Logarithm base (default 2 for bits)

    Returns:
        Entropy in the specified base
    """
    total = sum(distribution.values())
    if total == 0:
        return 0.0

    entropy = 0.0
    for count in distribution.values():
        if count > 0:
            p = count / total
            entropy -= p * math.log(p, base)

    return entropy


def witness_entropy_bound(witnesses: List) -> Dict:
    """
    Compute entropy-based lower bounds on KW protocol complexity.

    The Shannon entropy of the witness distribution provides a lower
    bound on the expected code length of any encoding.

    Args:
        witnesses: List of KW witness triples

    Returns:
        Dictionary with entropy statistics
    """
    if not witnesses:
        return {'entropy': 0, 'log2_count': 0, 'min_bits': 0}

    # Coordinate distribution
    coord_dist = kw_witness_distribution(witnesses)
    coord_entropy = shannon_entropy(coord_dist)

    # Full witness distribution
    num_witnesses = len(witnesses)
    log2_count = math.log2(num_witnesses) if num_witnesses > 0 else 0
    min_bits = math.ceil(log2_count)

    return {
        'num_witnesses': num_witnesses,
        'log2_count': log2_count,
        'min_bits': min_bits,
        'coordinate_entropy': coord_entropy,
        'coordinate_distribution': coord_dist,
    }


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Monotone Circuit Complexity Checker
# ─────────────────────────────────────────────────────────────────────

class MonotoneCircuit:
    """
    Abstract monotone circuit representation.

    Supports AND, OR gates over Boolean variables.
    Provides size, depth computation and monotonicity verification.
    """

    def __init__(self, gate_type: str, children=None, var_idx=None):
        self.gate_type = gate_type  # 'AND', 'OR', 'VAR', 'TRUE', 'FALSE'
        self.children = children or []
        self.var_idx = var_idx

    def evaluate(self, assignment: Dict[int, bool]) -> bool:
        """Evaluate circuit on a Boolean assignment."""
        if self.gate_type == 'VAR':
            return assignment.get(self.var_idx, False)
        elif self.gate_type == 'TRUE':
            return True
        elif self.gate_type == 'FALSE':
            return False
        elif self.gate_type == 'AND':
            return all(c.evaluate(assignment) for c in self.children)
        else:  # OR
            return any(c.evaluate(assignment) for c in self.children)

    @property
    def size(self) -> int:
        if self.gate_type in ('VAR', 'TRUE', 'FALSE'):
            return 1
        return 1 + sum(c.size for c in self.children)

    @property
    def depth(self) -> int:
        if self.gate_type in ('VAR', 'TRUE', 'FALSE'):
            return 0
        return 1 + max((c.depth for c in self.children), default=0)

    def verify_monotonicity(self, num_vars: int, num_samples: int = 100) -> bool:
        """
        Empirically verify monotonicity: x ≤ y → f(x) ≤ f(y).

        Tests random pairs where x ≤ y (bitwise) and checks that
        the circuit output is monotone.

        Time complexity: O(num_samples * circuit_size)
        """
        rng = random.Random(0)
        for _ in range(num_samples):
            # Generate random x
            x = {i: rng.random() < 0.5 for i in range(num_vars)}
            # Generate y ≥ x (set additional bits to True)
            y = dict(x)
            for i in range(num_vars):
                if rng.random() < 0.3:
                    y[i] = True

            fx = self.evaluate(x)
            fy = self.evaluate(y)

            if fx and not fy:
                return False
        return True


def validate_approximation_sandwich(
    circuit: MonotoneCircuit,
    positive: List[Dict[int, bool]],
    negative: List[Dict[int, bool]],
    target_fn: Callable[[Dict[int, bool]], bool]
) -> Dict:
    """
    Validate whether a circuit passes an approximation sandwich test.

    Checks if the circuit agrees with the target function on all
    positive and negative test instances.

    Args:
        circuit: Monotone circuit to test
        positive: List of positive test assignments
        negative: List of negative test assignments
        target_fn: Target Boolean function

    Returns:
        Validation results including any failures
    """
    failures = []
    for i, asgn in enumerate(positive):
        c_out = circuit.evaluate(asgn)
        t_out = target_fn(asgn)
        if c_out != t_out:
            failures.append(('POS', i, c_out, t_out))

    for i, asgn in enumerate(negative):
        c_out = circuit.evaluate(asgn)
        t_out = target_fn(asgn)
        if c_out != t_out:
            failures.append(('NEG', i, c_out, t_out))

    return {
        'passed': len(failures) == 0,
        'num_failures': len(failures),
        'failures': failures,
        'total_tests': len(positive) + len(negative),
    }


# ─────────────────────────────────────────────────────────────────────
# Algorithm 5: Compression Obstruction Checker
# ─────────────────────────────────────────────────────────────────────

def check_compression_obstruction(
    witnesses: List,
    target_code_length: int
) -> Dict:
    """
    Check if the KW witness space creates a compression obstruction.

    By the pigeonhole principle, if |witnesses| > 2^k, then any injective
    encoding must assign some witness a code of length > k.

    This is the computational manifestation of the formal theorem
    `cardinality_forces_long_code`.

    Args:
        witnesses: List of KW witnesses
        target_code_length: Maximum desired code length k

    Returns:
        Dictionary with obstruction analysis
    """
    num_witnesses = len(witnesses)
    max_encodable = 2 ** (target_code_length + 1) - 1  # sum of 2^i for i=0..k

    return {
        'num_witnesses': num_witnesses,
        'target_code_length': target_code_length,
        'max_encodable': max_encodable,
        'obstruction_exists': num_witnesses > max_encodable,
        'min_code_length_needed': math.ceil(math.log2(num_witnesses + 1)) if num_witnesses > 0 else 0,
        'excess_ratio': num_witnesses / max_encodable if max_encodable > 0 else float('inf'),
    }


# ─────────────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Demo: Approximation sandwich for 3-CLIQUE
    print("\n1. Approximation Sandwich for 3-CLIQUE on 5 vertices:")
    sandwich = construct_approximation_sandwich(
        n=5, k=3,
        target_fn=lambda n, e: has_k_clique(n, e, 3),
        num_pos=30, num_neg=30
    )
    print(f"   Positive instances: {sandwich['num_positive']}")
    print(f"   Negative instances: {sandwich['num_negative']}")
    print(f"   Certified: {sandwich['certified']}")

    # Demo: KW witness enumeration
    print("\n2. KW Witnesses for OR on 4 variables:")
    or_fn = lambda x: any(x)
    witnesses = enumerate_kw_witnesses_bitstring(4, or_fn)
    stats = witness_entropy_bound(witnesses)
    print(f"   Witnesses: {stats['num_witnesses']}")
    print(f"   log₂(|W|): {stats['log2_count']:.2f}")
    print(f"   Min bits needed: {stats['min_bits']}")
    print(f"   Coordinate entropy: {stats['coordinate_entropy']:.3f}")
    print(f"   Coordinate distribution: {stats['coordinate_distribution']}")

    # Demo: Compression obstruction
    print("\n3. Compression Obstruction for PARITY on 4 variables:")
    parity_fn = lambda x: sum(1 for b in x if b) % 2 == 1
    parity_witnesses = enumerate_kw_witnesses_bitstring(4, parity_fn)
    obstruction = check_compression_obstruction(parity_witnesses, 3)
    print(f"   Witnesses: {obstruction['num_witnesses']}")
    print(f"   Target code length: {obstruction['target_code_length']}")
    print(f"   Max encodable: {obstruction['max_encodable']}")
    print(f"   Obstruction exists: {obstruction['obstruction_exists']}")
    print(f"   Min code length: {obstruction['min_code_length_needed']}")

    # Demo: Shannon entropy
    print("\n4. Entropy comparison across functions (n=4):")
    functions = {
        'OR': lambda x: any(x),
        'AND': lambda x: all(x),
        'PARITY': lambda x: sum(1 for b in x if b) % 2 == 1,
        'MAJORITY': lambda x: sum(1 for b in x if b) > len(x) // 2,
    }
    for name, fn in functions.items():
        w = enumerate_kw_witnesses_bitstring(4, fn)
        stats = witness_entropy_bound(w)
        print(f"   {name:10s}: H_coord = {stats['coordinate_entropy']:.3f} bits, "
              f"|W| = {stats['num_witnesses']}")
