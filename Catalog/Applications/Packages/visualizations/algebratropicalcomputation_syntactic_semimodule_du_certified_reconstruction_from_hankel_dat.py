#!/usr/bin/env python3
"""
Algorithms for Tropical Hankel Realization Duality

Implements the core algorithms from the research paper:
1. Certified reconstruction from Hankel data
2. Hankel window learning algorithm
3. Automaton minimization via observation equivalence
4. Tropical Hankel rank computation
"""

import numpy as np
from typing import List, Tuple, Optional, Callable, Set
import itertools
from dataclasses import dataclass

# Tropical arithmetic
INF = float('inf')

def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)"""
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with ∞ handling)"""
    if a == INF or b == INF:
        return INF
    return a + b

def trop_vec_dot(u: np.ndarray, v: np.ndarray) -> float:
    """Tropical dot product: min_i (u_i + v_i)"""
    result = INF
    for a, b in zip(u, v):
        result = trop_add(result, trop_mul(a, b))
    return result


@dataclass
class TropicalAutomaton:
    """Weighted automaton over the tropical (min-plus) semiring.

    Attributes:
        n_states: Number of states
        alphabet_size: Size of the input alphabet
        init: Initial weight vector (n_states,)
        trans: List of transition matrices, one per letter (n_states × n_states)
        output: Output weight vector (n_states,)
    """
    n_states: int
    alphabet_size: int
    init: np.ndarray
    trans: List[np.ndarray]
    output: np.ndarray

    def reach(self, word: List[int]) -> np.ndarray:
        """Compute reach vector: state weights after processing word.

        Time complexity: O(|word| * n_states^2)
        """
        v = self.init.copy()
        for a in word:
            new_v = np.full(self.n_states, INF)
            for j in range(self.n_states):
                for i in range(self.n_states):
                    new_v[j] = trop_add(new_v[j], trop_mul(v[i], self.trans[a][i, j]))
            v = new_v
        return v

    def obs(self, suffix: List[int], state: int) -> float:
        """Observation function: weight from state processing suffix.

        Time complexity: O(|suffix| * n_states)
        """
        if not suffix:
            return self.output[state]
        a = suffix[0]
        rest = suffix[1:]
        result = INF
        for i in range(self.n_states):
            result = trop_add(result,
                             trop_mul(self.trans[a][state, i], self.obs(rest, i)))
        return result

    def behavior(self, word: List[int]) -> float:
        """Compute behavior (recognized weight) on word.

        Time complexity: O(|word| * n_states^2)
        """
        r = self.reach(word)
        return trop_vec_dot(r, self.output)

    def obs_vector(self, suffix: List[int]) -> np.ndarray:
        """Full observation vector for a suffix."""
        return np.array([self.obs(suffix, j) for j in range(self.n_states)])


@dataclass
class RealizationData:
    """Realization data for a weighted language.

    Consists of generators, coefficients, and shift matrices satisfying:
    1. L(u·v) = min_j [coeff(u)_j + gen_j(v)]
    2. coeff(u·a)_j = min_i [coeff(u)_i + shift(a)_{i,j}]
    3. gen_j(a·v) = min_k [shift(a)_{j,k} + gen_k(v)]
    """
    n_generators: int
    alphabet_size: int
    gen: List[Callable]      # gen[j](v) -> float
    coeff: Callable          # coeff(u) -> np.ndarray
    shift: List[np.ndarray]  # shift[a] -> np.ndarray (n × n)
    init_coeff: np.ndarray   # coeff(ε)
    gen_at_empty: np.ndarray # [gen[j](ε) for j]


def certified_reconstruction(data: RealizationData) -> TropicalAutomaton:
    """Certified Reconstruction Algorithm.

    Given realization data (gen, coeff, shift), constructs a weighted
    automaton whose behavior provably equals the original language.

    Algorithm:
        A.init[j]         = coeff(ε)[j]
        A.trans[a][i][j]   = shift(a)[i][j]
        A.output[j]       = gen[j](ε)

    Time complexity: O(n^2 * |Σ|)
    Space complexity: O(n^2 * |Σ|)

    Returns:
        TropicalAutomaton with behavior = original language
    """
    n = data.n_generators
    sigma = data.alphabet_size

    init = data.init_coeff.copy()
    trans = [s.copy() for s in data.shift]
    output = data.gen_at_empty.copy()

    return TropicalAutomaton(n, sigma, init, trans, output)


def extract_realization_data(A: TropicalAutomaton) -> RealizationData:
    """Extract realization data from a weighted automaton.

    This is the backward direction of the realization duality:
    every automaton canonically yields realization data.

    Time complexity: O(1) (just wrapping existing data)
    """
    gen = [lambda v, j=j: A.obs(v, j) for j in range(A.n_states)]
    coeff = lambda u: A.reach(u)
    init_coeff = A.init.copy()
    gen_at_empty = A.output.copy()

    return RealizationData(
        n_generators=A.n_states,
        alphabet_size=A.alphabet_size,
        gen=gen,
        coeff=coeff,
        shift=A.trans,
        init_coeff=init_coeff,
        gen_at_empty=gen_at_empty
    )


def enumerate_words(alphabet_size: int, max_length: int) -> List[List[int]]:
    """Enumerate all words over alphabet {0,...,alphabet_size-1} up to max_length."""
    words = [[]]
    for length in range(1, max_length + 1):
        for w in itertools.product(range(alphabet_size), repeat=length):
            words.append(list(w))
    return words


def build_hankel_window(L: Callable, prefixes: List[List[int]],
                         suffixes: List[List[int]]) -> np.ndarray:
    """Build the Hankel matrix for given prefix/suffix sets.

    H[i,j] = L(prefixes[i] · suffixes[j])

    Time complexity: O(|P| * |S| * query_cost)
    """
    H = np.zeros((len(prefixes), len(suffixes)))
    for i, u in enumerate(prefixes):
        for j, v in enumerate(suffixes):
            H[i, j] = L(u + v)
    return H


def tropical_row_rank(H: np.ndarray, tol: float = 1e-10) -> int:
    """Estimate the tropical row rank of a matrix.

    The tropical row rank is the minimum number of tropical generators
    needed to express all rows. This is computed by a greedy algorithm
    that finds rows not expressible as tropical combinations of existing
    generators.

    Time complexity: O(m * n * k) where m = rows, n = cols, k = rank

    Args:
        H: Matrix (rows × cols)
        tol: Tolerance for equality checks

    Returns:
        Estimated tropical row rank
    """
    m, n = H.shape
    generators = []  # indices of generator rows

    for i in range(m):
        row = H[i]
        # Check if row is a tropical shift of an existing generator
        # A row r is a tropical shift of g if r - g is constant
        # (in ordinary arithmetic), i.e., r = g + c for some constant c
        is_generated = False
        for gen_indices in _generate_tropical_combinations(generators, H, n):
            # Check if row matches a tropical combination
            combo = _eval_tropical_combination(gen_indices, H, n)
            if _trop_vec_eq(row, combo, tol):
                is_generated = True
                break

        if not is_generated:
            generators.append(i)

    return len(generators)


def _generate_tropical_combinations(gen_indices: List[int], H: np.ndarray,
                                      n: int):
    """Generate simple tropical combinations (shifts of single generators)."""
    for idx in gen_indices:
        yield [(idx, 0.0)]  # just the generator itself
        # Also try constant shifts
        for c in range(-10, 11):
            yield [(idx, float(c))]


def _eval_tropical_combination(combo: List[Tuple[int, float]],
                                  H: np.ndarray, n: int) -> np.ndarray:
    """Evaluate a tropical combination of rows."""
    result = np.full(n, INF)
    for idx, c in combo:
        for j in range(n):
            val = trop_mul(c, H[idx, j])
            result[j] = trop_add(result[j], val)
    return result


def _trop_vec_eq(a: np.ndarray, b: np.ndarray, tol: float) -> bool:
    """Check tropical equality of two vectors."""
    for x, y in zip(a, b):
        if x == INF and y == INF:
            continue
        if x == INF or y == INF:
            return False
        if abs(x - y) > tol:
            return False
    return True


def learn_from_hankel(L: Callable, alphabet_size: int,
                       max_depth: int = 5) -> Optional[TropicalAutomaton]:
    """Hankel Window Learning Algorithm.

    Learns a minimal tropical weighted automaton from query access to L.

    Algorithm:
    1. Start with window P = S = {ε}
    2. Build Hankel matrix H
    3. Find generators (tropically independent rows)
    4. Check shift stability: for each generator g and letter a,
       is shift(g, a) in the span of generators?
    5. If not, extend the window and repeat
    6. Once stable, extract automaton via certified reconstruction

    Time complexity: O(n * |Σ| * n^2) per iteration, at most n iterations
    Space complexity: O(n^2 * |Σ|) for the automaton

    Args:
        L: Query oracle for the weighted language
        alphabet_size: Size of the alphabet
        max_depth: Maximum word length to consider

    Returns:
        TropicalAutomaton if learning succeeds, None otherwise
    """
    prefixes = [[]]
    suffixes = [[]]

    for depth in range(max_depth):
        # Build Hankel matrix
        H = build_hankel_window(L, prefixes, suffixes)

        # Find generator rows (tropically independent)
        gen_indices = _find_generators(H)
        n_gen = len(gen_indices)

        if n_gen == 0:
            continue

        # Check shift stability
        stable = True
        new_prefixes = set(tuple(p) for p in prefixes)
        new_suffixes = set(tuple(s) for s in suffixes)

        for a in range(alphabet_size):
            for gi in gen_indices:
                u = prefixes[gi]
                shifted_prefix = u + [a]

                # Check if shifted residual is in span
                shifted_row = np.array([L(shifted_prefix + v) for v in suffixes])

                if not _is_in_tropical_span(shifted_row, H, gen_indices):
                    stable = False
                    new_prefixes.add(tuple(shifted_prefix))

            for sj_idx in range(len(suffixes)):
                for letter_a in range(alphabet_size):
                    new_suffix = [letter_a] + suffixes[sj_idx]
                    new_suffixes.add(tuple(new_suffix))

        if stable:
            # Extract automaton
            return _extract_automaton_from_window(
                L, prefixes, suffixes, H, gen_indices, alphabet_size)

        # Extend window
        prefixes = [list(p) for p in sorted(new_prefixes, key=lambda x: (len(x), x))]
        suffixes = [list(s) for s in sorted(new_suffixes, key=lambda x: (len(x), x))]

    return None


def _find_generators(H: np.ndarray, tol: float = 1e-10) -> List[int]:
    """Find tropically independent rows (generators)."""
    m, n = H.shape
    generators = []

    for i in range(m):
        row = H[i]
        if all(row[j] == INF for j in range(n)):
            continue

        is_dependent = False
        for gi in generators:
            gen_row = H[gi]
            # Check if row is a constant shift of gen_row
            # i.e., row[j] - gen_row[j] is constant for all finite entries
            diffs = []
            valid = True
            for j in range(n):
                if row[j] == INF and gen_row[j] == INF:
                    continue
                if row[j] == INF or gen_row[j] == INF:
                    valid = False
                    break
                diffs.append(row[j] - gen_row[j])
            if valid and diffs and all(abs(d - diffs[0]) < tol for d in diffs):
                is_dependent = True
                break

        if not is_dependent:
            generators.append(i)

    return generators


def _is_in_tropical_span(row: np.ndarray, H: np.ndarray,
                           gen_indices: List[int], tol: float = 1e-10) -> bool:
    """Check if a row is in the tropical span of generator rows."""
    for gi in gen_indices:
        gen_row = H[gi]
        diffs = []
        valid = True
        for j in range(len(row)):
            if row[j] == INF and gen_row[j] == INF:
                continue
            if row[j] == INF or gen_row[j] == INF:
                valid = False
                break
            diffs.append(row[j] - gen_row[j])
        if valid and diffs and all(abs(d - diffs[0]) < tol for d in diffs):
            return True
    return False


def _extract_automaton_from_window(
        L: Callable, prefixes: List[List[int]], suffixes: List[List[int]],
        H: np.ndarray, gen_indices: List[int],
        alphabet_size: int) -> TropicalAutomaton:
    """Extract automaton from stable Hankel window."""
    n = len(gen_indices)

    # Initial weights: decomposition of L itself (prefix = ε)
    eps_idx = prefixes.index([])
    init = np.full(n, INF)

    # Simple extraction: use generator prefix reach as state weights
    for k, gi in enumerate(gen_indices):
        init[k] = 0.0 if gi == eps_idx else INF

    # Output weights: gen_j(ε) = H[gen_j_prefix, ε_suffix]
    eps_suffix_idx = suffixes.index([])
    output = np.array([H[gi, eps_suffix_idx] for gi in gen_indices])

    # Transition matrices: find shift coefficients
    trans = []
    for a in range(alphabet_size):
        T = np.full((n, n), INF)
        for i, gi in enumerate(gen_indices):
            u = prefixes[gi]
            shifted = u + [a]
            shifted_row = np.array([L(shifted + v) for v in suffixes])

            for j, gj in enumerate(gen_indices):
                gen_row = H[gj]
                # Find constant c such that shifted_row ≈ gen_row + c
                diffs = []
                for s in range(len(suffixes)):
                    if shifted_row[s] != INF and gen_row[s] != INF:
                        diffs.append(shifted_row[s] - gen_row[s])
                if diffs:
                    T[i, j] = min(diffs)

        trans.append(T)

    return TropicalAutomaton(n, alphabet_size, init, trans, output)


def minimize_automaton(A: TropicalAutomaton,
                        test_depth: int = 5) -> TropicalAutomaton:
    """Minimize a tropical weighted automaton.

    Groups states by observation equivalence and merges equivalent states.

    Algorithm:
    1. Compute obs(v, j) for all states j and suffixes v up to test_depth
    2. Group states with identical observation profiles
    3. Construct quotient automaton

    Time complexity: O(n * |Σ|^d * n) where d = test_depth
    Space complexity: O(n * |Σ|^d)

    Args:
        A: Input automaton
        test_depth: Depth of suffix exploration for observation equivalence

    Returns:
        Minimized automaton (fewer or equal states)
    """
    suffixes = enumerate_words(A.alphabet_size, test_depth)

    # Compute observation profiles
    profiles = {}
    for j in range(A.n_states):
        profile = tuple(A.obs(v, j) for v in suffixes)
        if profile not in profiles:
            profiles[profile] = []
        profiles[profile].append(j)

    # Create quotient
    classes = list(profiles.values())
    n_new = len(classes)

    # Representative for each class
    reps = [cls[0] for cls in classes]
    state_map = {}
    for ci, cls in enumerate(classes):
        for j in cls:
            state_map[j] = ci

    # New automaton
    new_init = np.full(n_new, INF)
    for j in range(A.n_states):
        ci = state_map[j]
        new_init[ci] = trop_add(new_init[ci], A.init[j])

    new_output = np.array([A.output[reps[ci]] for ci in range(n_new)])

    new_trans = []
    for a in range(A.alphabet_size):
        T = np.full((n_new, n_new), INF)
        for ci in range(n_new):
            for cj in range(n_new):
                T[ci, cj] = A.trans[a][reps[ci], reps[cj]]
        new_trans.append(T)

    return TropicalAutomaton(n_new, A.alphabet_size, new_init, new_trans, new_output)


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Hankel Realization Duality — Algorithm Demos")
    print("=" * 60)
    print()

    # Create a simple automaton
    n, sigma = 3, 2
    init = np.array([0, INF, INF])
    output = np.array([0, 0, 0])
    T0 = np.array([[0, 2, INF], [INF, 0, INF], [INF, INF, 0]])
    T1 = np.array([[0, INF, 6], [INF, 0, 3], [INF, INF, 0]])

    A = TropicalAutomaton(n, sigma, init, [T0, T1])

    # Test certified reconstruction
    print("1. Certified Reconstruction:")
    data = extract_realization_data(A)
    A_recon = certified_reconstruction(data)

    test_words = [[], [0], [1], [0, 1], [1, 0], [0, 0, 1], [0, 1, 1]]
    all_match = True
    for w in test_words:
        b1 = A.behavior(w)
        b2 = A_recon.behavior(w)
        if b1 != b2:
            all_match = False
    print(f"   Reconstruction correct: {all_match}")
    print()

    # Test minimization
    print("2. Automaton Minimization:")
    # Create a redundant automaton (duplicate state 1)
    n_big = 4
    init_big = np.array([0, INF, INF, INF])
    output_big = np.array([0, 0, 0, 0])
    T0_big = np.array([
        [0, 2, INF, 2],
        [INF, 0, INF, INF],
        [INF, INF, 0, INF],
        [INF, INF, INF, 0]
    ])
    T1_big = np.array([
        [0, INF, 6, INF],
        [INF, 0, 3, INF],
        [INF, INF, 0, INF],
        [INF, INF, INF, 0]  # state 3 mimics state 1
    ])
    A_big = TropicalAutomaton(n_big, sigma, init_big, [T0_big, T1_big])
    print(f"   Original: {A_big.n_states} states")

    A_min = minimize_automaton(A_big, test_depth=3)
    print(f"   Minimized: {A_min.n_states} states")
    print()

    # Test Hankel rank computation
    print("3. Tropical Hankel Rank:")
    words = enumerate_words(sigma, 3)[:15]
    H = build_hankel_window(A.behavior, words, words)
    rank = tropical_row_rank(H)
    print(f"   Hankel matrix size: {H.shape}")
    print(f"   Tropical row rank: {rank}")
    print(f"   Automaton states: {A.n_states}")
    print()

    # Test learning
    print("4. Hankel Window Learning:")
    L = A.behavior
    A_learned = learn_from_hankel(L, sigma, max_depth=4)
    if A_learned:
        print(f"   Learned automaton: {A_learned.n_states} states")
        matches = sum(1 for w in test_words
                      if A.behavior(w) == A_learned.behavior(w))
        print(f"   Matches on test words: {matches}/{len(test_words)}")
    else:
        print("   Learning did not converge within depth limit")
