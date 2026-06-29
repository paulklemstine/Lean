"""
Certified Expander Codes: Core Algorithms

Implements the construction and decoding of Tanner/expander codes built from
Cayley graphs of GL₂(𝔽_p), with Sipser-Spielman peeling decoders.

Key algorithms:
- Cayley graph construction from GL₂(𝔽_p)
- Bipartite double cover / Tanner graph construction
- Peeling (bit-flipping) decoder with convergence tracking
- LDPC code construction for baseline comparison
"""

import numpy as np
from itertools import product
from typing import List, Tuple, Dict, Optional, Set
from collections import defaultdict


# ============================================================
# Finite Field Arithmetic
# ============================================================

def gf_add(a: int, b: int, p: int) -> int:
    """Addition in GF(p)."""
    return (a + b) % p

def gf_mul(a: int, b: int, p: int) -> int:
    """Multiplication in GF(p)."""
    return (a * b) % p

def gf_inv(a: int, p: int) -> int:
    """Multiplicative inverse in GF(p) using Fermat's little theorem."""
    if a % p == 0:
        raise ValueError(f"{a} has no inverse mod {p}")
    return pow(a, p - 2, p)

def mat_mul_2x2(A: np.ndarray, B: np.ndarray, p: int) -> np.ndarray:
    """Multiply two 2x2 matrices over GF(p)."""
    C = np.zeros((2, 2), dtype=int)
    for i in range(2):
        for j in range(2):
            C[i, j] = sum(gf_mul(int(A[i, k]), int(B[k, j]), p) for k in range(2)) % p
    return C

def mat_det_2x2(M: np.ndarray, p: int) -> int:
    """Determinant of 2x2 matrix over GF(p)."""
    return (gf_mul(int(M[0, 0]), int(M[1, 1]), p) - gf_mul(int(M[0, 1]), int(M[1, 0]), p)) % p


# ============================================================
# GL₂(𝔽_p) Group Construction
# ============================================================

class GL2Fp:
    """
    The general linear group GL₂(𝔽_p) of invertible 2×2 matrices over GF(p).

    Attributes:
        p: prime defining the finite field
        elements: list of all group elements as 2x2 numpy arrays
        element_to_idx: dictionary mapping matrix tuples to indices
    """

    def __init__(self, p: int):
        self.p = p
        self.elements = []
        self.element_to_idx = {}
        self._build_group()

    def _build_group(self):
        """Enumerate all invertible 2x2 matrices over GF(p)."""
        p = self.p
        idx = 0
        for a, b, c, d in product(range(p), repeat=4):
            det = (a * d - b * c) % p
            if det != 0:
                M = np.array([[a, b], [c, d]], dtype=int)
                key = (a, b, c, d)
                self.elements.append(M)
                self.element_to_idx[key] = idx
                idx += 1

    def order(self) -> int:
        """Return |GL₂(𝔽_p)| = (p²-1)(p²-p)."""
        return len(self.elements)

    def mat_to_idx(self, M: np.ndarray) -> int:
        """Convert matrix to index."""
        key = (int(M[0, 0]) % self.p, int(M[0, 1]) % self.p,
               int(M[1, 0]) % self.p, int(M[1, 1]) % self.p)
        return self.element_to_idx[key]

    def multiply(self, i: int, j: int) -> int:
        """Multiply elements[i] * elements[j], return index."""
        prod = mat_mul_2x2(self.elements[i], self.elements[j], self.p)
        return self.mat_to_idx(prod)


# ============================================================
# Cayley Graph Construction
# ============================================================

def standard_generators_gl2(p: int) -> List[np.ndarray]:
    """
    Return a standard symmetric generating set for GL₂(𝔽_p).

    Uses generators:
      S = { [[1,1],[0,1]], [[1,0],[1,1]], [[g,0],[0,1]] }
    and their inverses, where g is a primitive root mod p.
    """
    # Find a primitive root mod p
    g = _primitive_root(p)

    gens = [
        np.array([[1, 1], [0, 1]], dtype=int),  # upper unitriangular
        np.array([[1, 0], [1, 1]], dtype=int),  # lower unitriangular
        np.array([[g, 0], [0, 1]], dtype=int),  # diagonal
    ]

    # Add inverses
    inv_gens = []
    for M in gens:
        det = mat_det_2x2(M, p)
        det_inv = gf_inv(det, p)
        M_inv = np.array([
            [gf_mul(int(M[1, 1]), det_inv, p), gf_mul((-int(M[0, 1])) % p, det_inv, p)],
            [gf_mul((-int(M[1, 0])) % p, det_inv, p), gf_mul(int(M[0, 0]), det_inv, p)]
        ], dtype=int)
        inv_gens.append(M_inv)

    all_gens = gens + inv_gens
    # Remove duplicates
    seen = set()
    unique = []
    for M in all_gens:
        key = tuple(M.flatten() % p)
        if key not in seen:
            seen.add(key)
            unique.append(M % p)
    return unique


def _primitive_root(p: int) -> int:
    """Find the smallest primitive root modulo p."""
    if p == 2:
        return 1
    for g in range(2, p):
        if _is_primitive_root(g, p):
            return g
    return 2


def _is_primitive_root(g: int, p: int) -> bool:
    """Check if g is a primitive root mod p."""
    if p == 2:
        return g % 2 == 1
    order = p - 1
    # Check that g^(order/q) ≠ 1 for each prime factor q of order
    temp = order
    factors = set()
    d = 2
    while d * d <= temp:
        while temp % d == 0:
            factors.add(d)
            temp //= d
        d += 1
    if temp > 1:
        factors.add(temp)

    for q in factors:
        if pow(g, order // q, p) == 1:
            return False
    return True


def build_cayley_graph(group: GL2Fp, generators: List[np.ndarray]) -> Dict[int, Set[int]]:
    """
    Build the Cayley graph Cay(G, S) as an adjacency list.

    Returns dict mapping vertex index to set of neighbor indices.
    """
    n = group.order()
    gen_indices = [group.mat_to_idx(g) for g in generators]

    adj = defaultdict(set)
    for v in range(n):
        for s_idx in gen_indices:
            neighbor = group.multiply(v, s_idx)
            adj[v].add(neighbor)
    return dict(adj)


# ============================================================
# Bipartite Double Cover / Tanner Graph
# ============================================================

class TannerGraph:
    """
    Bipartite Tanner graph built from the double cover of a Cayley graph.

    Left vertices = variable nodes (copies of group elements)
    Right vertices = check nodes (copies of group elements)

    Edge (l, r) exists if r is a neighbor of l in the Cayley graph.

    Attributes:
        n_left: number of left (variable) nodes
        n_right: number of right (check) nodes
        left_neighbors: for each left vertex, set of right neighbors
        right_neighbors: for each right vertex, set of left neighbors
        degree: left regularity (= |S|)
    """

    def __init__(self, cayley_adj: Dict[int, Set[int]], n_vertices: int):
        self.n_left = n_vertices
        self.n_right = n_vertices
        self.left_neighbors = {}
        self.right_neighbors = defaultdict(set)

        for v in range(n_vertices):
            neighbors = cayley_adj.get(v, set())
            self.left_neighbors[v] = set(neighbors)
            for u in neighbors:
                self.right_neighbors[u].add(v)

        # Compute degree
        if n_vertices > 0:
            self.degree = len(next(iter(self.left_neighbors.values())))
        else:
            self.degree = 0

    def neighborhood(self, S: Set[int]) -> Set[int]:
        """Compute N(S) = right neighbors of left set S."""
        result = set()
        for v in S:
            result.update(self.left_neighbors.get(v, set()))
        return result

    def unique_neighbors(self, S: Set[int]) -> Set[int]:
        """
        Compute U(S) = right vertices adjacent to exactly one element of S.

        This is the key quantity for the peeling decoder:
        unique neighbors identify correctable error variables.
        """
        # Count how many elements of S each right vertex is adjacent to
        right_count = defaultdict(int)
        for v in S:
            for r in self.left_neighbors.get(v, set()):
                right_count[r] += 1
        return {r for r, count in right_count.items() if count == 1}

    def correctable(self, E: Set[int]) -> Set[int]:
        """
        Compute the correctable set: left vertices in E that have at least
        one unique-neighbor check.
        """
        unique = self.unique_neighbors(E)
        result = set()
        for r in unique:
            # Find the unique left vertex in E adjacent to r
            for v in self.right_neighbors[r]:
                if v in E:
                    result.add(v)
                    break
        return result


# ============================================================
# Peeling / Bit-Flipping Decoder
# ============================================================

class PeelingDecoder:
    """
    Sipser-Spielman peeling decoder for expander/Tanner codes.

    The decoder iteratively identifies error variables that are uniquely
    identified by a check node (unique neighbor) and corrects them.

    Convergence is guaranteed when the expansion is sufficient:
    by the formally verified theorem `iterated_peel_reaches_fixpoint`,
    the decoder terminates in at most |E| rounds.
    """

    def __init__(self, tanner: TannerGraph):
        self.tanner = tanner

    def peel_step(self, error_set: Set[int]) -> Set[int]:
        """
        One round of peeling: remove all correctable variables from E.

        Returns the new (reduced) error set.

        Formally verified property:
        - peelStep E ⊆ E (peelStep_subset)
        - If correctable(E) ≠ ∅, then |peelStep(E)| < |E| (peelStep_card_lt)
        """
        corr = self.tanner.correctable(error_set)
        return error_set - corr

    def decode(self, error_set: Set[int], max_rounds: Optional[int] = None) -> Tuple[Set[int], List[int]]:
        """
        Full peeling decoding: iterate peel_step until convergence or max_rounds.

        Returns (residual_error, history) where:
        - residual_error: remaining error set (empty if decoding succeeds)
        - history: list of |E| at each round

        Formally verified property (iterated_peel_reaches_fixpoint):
        The decoder converges within |E| rounds.
        """
        if max_rounds is None:
            max_rounds = len(error_set) + 1

        current = set(error_set)
        history = [len(current)]

        for _ in range(max_rounds):
            if not current:
                break
            new = self.peel_step(current)
            history.append(len(new))
            if len(new) == len(current):
                break  # Fixed point reached
            current = new

        return current, history


# ============================================================
# Random LDPC Baseline
# ============================================================

class RandomLDPC:
    """
    Random regular LDPC code for baseline comparison.
    Constructs a random (d_v, d_c)-regular bipartite graph.
    """

    def __init__(self, n: int, d_v: int, d_c: int, seed: int = 42):
        """
        Construct random regular LDPC with n variable nodes.

        Args:
            n: number of variable nodes
            d_v: variable node degree
            d_c: check node degree
            seed: random seed
        """
        self.n_var = n
        self.n_check = n * d_v // d_c
        self.d_v = d_v
        self.d_c = d_c

        rng = np.random.RandomState(seed)
        self._build_random_graph(rng)

    def _build_random_graph(self, rng):
        """Build random regular bipartite graph via permutation method."""
        n_edges = self.n_var * self.d_v

        # Create edge sockets
        var_sockets = np.repeat(np.arange(self.n_var), self.d_v)
        check_sockets = np.repeat(np.arange(self.n_check), self.d_c)

        # Pad if necessary
        if len(check_sockets) < len(var_sockets):
            check_sockets = np.concatenate([
                check_sockets,
                rng.choice(self.n_check, len(var_sockets) - len(check_sockets))
            ])
        elif len(check_sockets) > len(var_sockets):
            check_sockets = check_sockets[:len(var_sockets)]

        # Random permutation matching
        rng.shuffle(check_sockets)

        self.var_neighbors = defaultdict(set)
        self.check_neighbors = defaultdict(set)

        for v_sock, c_sock in zip(var_sockets, check_sockets):
            self.var_neighbors[v_sock].add(c_sock)
            self.check_neighbors[c_sock].add(v_sock)

    def unique_neighbors(self, S: Set[int]) -> Set[int]:
        """Unique check neighbors of variable set S."""
        check_count = defaultdict(int)
        for v in S:
            for c in self.var_neighbors[v]:
                check_count[c] += 1
        return {c for c, count in check_count.items() if count == 1}

    def correctable(self, E: Set[int]) -> Set[int]:
        """Correctable variables in E."""
        unique = self.unique_neighbors(E)
        result = set()
        for c in unique:
            for v in self.check_neighbors[c]:
                if v in E:
                    result.add(v)
                    break
        return result

    def peel_step(self, E: Set[int]) -> Set[int]:
        """One peeling step."""
        return E - self.correctable(E)

    def decode(self, E: Set[int], max_rounds: Optional[int] = None) -> Tuple[Set[int], List[int]]:
        """Full peeling decoding."""
        if max_rounds is None:
            max_rounds = len(E) + 1
        current = set(E)
        history = [len(current)]
        for _ in range(max_rounds):
            if not current:
                break
            new = self.peel_step(current)
            history.append(len(new))
            if len(new) == len(current):
                break
            current = new
        return current, history


# ============================================================
# Channel Models
# ============================================================

def bsc_corrupt(n: int, error_rate: float, rng=None) -> Set[int]:
    """
    Binary symmetric channel: flip each bit independently with probability error_rate.
    Returns set of flipped positions.
    """
    if rng is None:
        rng = np.random.RandomState()
    flips = rng.random(n) < error_rate
    return set(np.where(flips)[0])


def awgn_corrupt(n: int, snr_db: float, rng=None) -> Set[int]:
    """
    AWGN channel model (hard decision): add Gaussian noise and threshold.
    Returns set of positions where hard decision differs from transmitted.
    """
    if rng is None:
        rng = np.random.RandomState()
    sigma = 10 ** (-snr_db / 20)
    noise = rng.randn(n)
    # Hard decision error if noise exceeds threshold
    return set(np.where(np.abs(noise) > 1.0 / (2 * sigma))[0])


# ============================================================
# Expansion Measurement
# ============================================================

def measure_expansion(tanner: TannerGraph, max_set_size: int = 50,
                      n_samples: int = 1000, rng=None) -> Dict:
    """
    Empirically measure the expansion properties of a Tanner graph.

    Returns dictionary with:
    - expansion_ratios: average |N(S)|/|S| for various |S|
    - unique_ratios: average |U(S)|/|S| for various |S|
    """
    if rng is None:
        rng = np.random.RandomState(42)

    results = {'set_sizes': [], 'expansion_ratios': [], 'unique_ratios': []}
    vertices = list(range(tanner.n_left))

    for size in range(1, min(max_set_size, tanner.n_left // 2) + 1):
        exp_ratios = []
        uniq_ratios = []
        for _ in range(n_samples):
            S = set(rng.choice(vertices, size=size, replace=False))
            N = tanner.neighborhood(S)
            U = tanner.unique_neighbors(S)
            if size > 0:
                exp_ratios.append(len(N) / size)
                uniq_ratios.append(len(U) / size)

        results['set_sizes'].append(size)
        results['expansion_ratios'].append(np.mean(exp_ratios))
        results['unique_ratios'].append(np.mean(uniq_ratios))

    return results


if __name__ == "__main__":
    # Quick test
    p = 3
    G = GL2Fp(p)
    print(f"GL₂(F_{p}) has order {G.order()}")

    gens = standard_generators_gl2(p)
    print(f"Using {len(gens)} generators")

    cayley = build_cayley_graph(G, gens)
    tanner = TannerGraph(cayley, G.order())
    print(f"Tanner graph: {tanner.n_left} left, {tanner.n_right} right, degree {tanner.degree}")

    # Test decoder
    rng = np.random.RandomState(42)
    error = bsc_corrupt(tanner.n_left, 0.05, rng)
    print(f"Error set size: {len(error)}")

    decoder = PeelingDecoder(tanner)
    residual, history = decoder.decode(error)
    print(f"Residual size: {len(residual)}")
    print(f"Decoding history: {history}")
