#!/usr/bin/env python3
"""
Algorithms for Sofic Transcendence Theory
==========================================

Implements the key algorithms from the research paper:
1. Factor complexity computation (exact and streaming)
2. Follower set computation for shift spaces
3. Sofic shift presentation and path enumeration
4. Finite-state complexity estimation
5. Eventual periodicity detection (suffix-array-based)
"""

from typing import Callable, Optional, Set, Dict, List, Tuple, FrozenSet
from collections import defaultdict
import itertools


# ============================================================
# §1. Factor Complexity (Exact)
# ============================================================

def factor_complexity_exact(
    seq: Callable[[int], int],
    m: int,
    N: int
) -> int:
    """
    Compute the exact factor complexity p_a(m) from a length-N prefix.

    Args:
        seq: Sequence oracle a : ℕ → alphabet.
        m: Word length.
        N: Prefix length to analyze.

    Returns:
        Number of distinct length-m subwords in seq[0:N].

    Complexity: O(N·m) time, O(N·m) space.
    """
    if m > N:
        return 0
    factors: Set[tuple] = set()
    for i in range(N - m + 1):
        w = tuple(seq(i + j) for j in range(m))
        factors.add(w)
    return len(factors)


def factor_complexity_profile(
    seq: Callable[[int], int],
    max_m: int,
    N: int
) -> List[int]:
    """
    Compute [p(1), p(2), ..., p(max_m)].

    Complexity: O(max_m · N · max_m) total.
    """
    return [factor_complexity_exact(seq, m, N) for m in range(1, max_m + 1)]


def factor_set(
    seq: Callable[[int], int],
    m: int,
    N: int
) -> Set[tuple]:
    """
    Return the set of all distinct length-m factors.

    Complexity: O(N·m) time, O(N·m) space.
    """
    factors: Set[tuple] = set()
    for i in range(N - m + 1):
        w = tuple(seq(i + j) for j in range(m))
        factors.add(w)
    return factors


# ============================================================
# §2. First-Difference Analysis
# ============================================================

def complexity_first_differences(
    seq: Callable[[int], int],
    max_m: int,
    N: int
) -> List[int]:
    """
    Compute the first differences Δp(n) = p(n+1) - p(n) for n = 1..max_m-1.

    For a sofic shift, these should be bounded by a constant.
    For a Sturmian sequence, Δp(n) = 1 for all n.

    Args:
        seq: Sequence oracle.
        max_m: Maximum word length.
        N: Prefix length.

    Returns:
        List of first differences [Δp(1), Δp(2), ..., Δp(max_m-1)].
    """
    profile = factor_complexity_profile(seq, max_m, N)
    return [profile[i + 1] - profile[i] for i in range(len(profile) - 1)]


def is_linearly_bounded(
    profile: List[int],
    tolerance: float = 0.1
) -> Tuple[bool, float, float]:
    """
    Check if a complexity profile is approximately linear.

    Returns (is_linear, slope, intercept) where is_linear is True
    if the profile fits p(n) ≈ C·n + D within tolerance.

    Uses least-squares regression.
    """
    n = len(profile)
    if n < 3:
        return True, 0.0, 0.0

    x_vals = list(range(1, n + 1))
    y_vals = profile

    x_mean = sum(x_vals) / n
    y_mean = sum(y_vals) / n

    num = sum((x - x_mean) * (y - y_mean) for x, y in zip(x_vals, y_vals))
    den = sum((x - x_mean) ** 2 for x in x_vals)

    slope = num / den if den > 0 else 0
    intercept = y_mean - slope * x_mean

    # Check R² (coefficient of determination)
    ss_res = sum((y - (slope * x + intercept)) ** 2 for x, y in zip(x_vals, y_vals))
    ss_tot = sum((y - y_mean) ** 2 for y in y_vals)

    r_squared = 1 - ss_res / ss_tot if ss_tot > 0 else 1.0
    is_linear = r_squared > 1 - tolerance

    return is_linear, slope, intercept


# ============================================================
# §3. Follower Set Computation
# ============================================================

def compute_follower_sets(
    seq: Callable[[int], int],
    word_length: int,
    extension_length: int,
    N: int
) -> Dict[tuple, Set[tuple]]:
    """
    Compute follower sets for all length-word_length factors.

    For each length-m factor w, its follower set at length k is
    the set of length-k words that immediately follow w in the sequence.

    Args:
        seq: Sequence oracle.
        word_length: Length m of the base words.
        extension_length: Length k of the extensions.
        N: Prefix length.

    Returns:
        Dictionary mapping each factor w to its follower set.

    Complexity: O(N · (m + k)) time.
    """
    m = word_length
    k = extension_length
    followers: Dict[tuple, Set[tuple]] = defaultdict(set)

    for i in range(N - m - k + 1):
        w = tuple(seq(i + j) for j in range(m))
        v = tuple(seq(i + m + j) for j in range(k))
        followers[w].add(v)

    return dict(followers)


def count_distinct_follower_sets(
    seq: Callable[[int], int],
    word_length: int,
    extension_length: int,
    N: int
) -> int:
    """
    Count the number of distinct follower sets.

    For a sofic shift, this should be finite (bounded by the number
    of vertices in the presentation graph).

    Complexity: O(N · (m + k)) time.
    """
    followers = compute_follower_sets(seq, word_length, extension_length, N)
    # Convert sets to frozensets for hashing
    distinct = {frozenset(v) for v in followers.values()}
    return len(distinct)


# ============================================================
# §4. Sofic Shift Presentation
# ============================================================

class LabeledGraph:
    """A finite labeled directed graph for presenting sofic shifts."""

    def __init__(self, num_vertices: int, alphabet_size: int):
        """
        Args:
            num_vertices: Number of vertices V.
            alphabet_size: Size of the label alphabet b.
        """
        self.V = num_vertices
        self.b = alphabet_size
        self.edges: Dict[Tuple[int, int, int], bool] = {}

    def add_edge(self, source: int, target: int, label: int) -> None:
        """Add a labeled edge from source to target."""
        self.edges[(source, target, label)] = True

    def has_edge(self, source: int, target: int, label: int) -> bool:
        """Check if an edge exists."""
        return (source, target, label) in self.edges

    def successors(self, vertex: int, label: int) -> List[int]:
        """Return all vertices reachable from vertex via the given label."""
        return [t for (s, t, l) in self.edges if s == vertex and l == label]

    def count_label_words(self, n: int) -> int:
        """
        Count the number of distinct length-n label sequences
        readable along paths in the graph.

        Uses dynamic programming on (current_vertex, word_so_far).

        Complexity: O(V² · b · n) time (with memoization of reachable words).
        """
        if n == 0:
            return 1

        # BFS/DFS over paths of length n
        # words[v] = set of length-n words readable starting from v
        words: Set[tuple] = set()

        def enumerate_paths(vertex: int, path_labels: list, remaining: int):
            if remaining == 0:
                words.add(tuple(path_labels))
                return
            for (s, t, l) in self.edges:
                if s == vertex:
                    path_labels.append(l)
                    enumerate_paths(t, path_labels, remaining - 1)
                    path_labels.pop()

        for v in range(self.V):
            enumerate_paths(v, [], n)

        return len(words)


def build_sofic_presentation_from_sequence(
    seq: Callable[[int], int],
    N: int,
    alphabet_size: int,
    max_context: int = 3
) -> LabeledGraph:
    """
    Build a labeled graph presentation approximating the sofic shift
    containing the given sequence, using a de Bruijn-style construction
    with context window of size max_context.

    Vertices correspond to distinct length-max_context contexts.

    Args:
        seq: Sequence oracle.
        N: Prefix length to analyze.
        alphabet_size: Size of the alphabet.
        max_context: Context window size (vertices = distinct contexts).

    Returns:
        A LabeledGraph presenting the approximate sofic shift.
    """
    # Collect all distinct contexts
    contexts: Dict[tuple, int] = {}
    context_list: List[tuple] = []

    for i in range(N - max_context):
        ctx = tuple(seq(i + j) for j in range(max_context))
        if ctx not in contexts:
            contexts[ctx] = len(context_list)
            context_list.append(ctx)

    V = len(context_list)
    G = LabeledGraph(V, alphabet_size)

    # Add edges: context c at position i transitions to context c' at position i+1
    for i in range(N - max_context - 1):
        ctx_from = tuple(seq(i + j) for j in range(max_context))
        ctx_to = tuple(seq(i + 1 + j) for j in range(max_context))
        label = seq(i + max_context)
        if ctx_from in contexts and ctx_to in contexts:
            G.add_edge(contexts[ctx_from], contexts[ctx_to], label)

    return G


# ============================================================
# §5. Finite-State Complexity Estimation
# ============================================================

def fs_complexity_exhaustive(
    seq: Callable[[int], int],
    N: int,
    alphabet_size: int = 2,
    max_K: int = 6
) -> int:
    """
    Compute fsComplexity(a, N) exactly by exhaustive search over
    all K-state machines for K = 1, 2, ...

    A K-state machine is (f : [K] → [K], g : [K] → [b], s₀ ∈ [K])
    generating a(n) = g(f^n(s₀)).

    Args:
        seq: Sequence oracle.
        N: Prefix length.
        alphabet_size: Output alphabet size b.
        max_K: Maximum number of states to try.

    Returns:
        Minimum K such that a K-state machine generates seq[0:N].

    Complexity: O(max_K^{max_K} · b^{max_K} · max_K · N) — exponential!
    """
    target = [seq(n) for n in range(N)]

    for K in range(1, max_K + 1):
        for trans in itertools.product(range(K), repeat=K):
            for out in itertools.product(range(alphabet_size), repeat=K):
                for s0 in range(K):
                    state = s0
                    match = True
                    for i in range(N):
                        if out[state] != target[i]:
                            match = False
                            break
                        state = trans[state]
                    if match:
                        return K
    return N  # Trivial upper bound


def fs_complexity_heuristic(
    seq: Callable[[int], int],
    N: int,
    alphabet_size: int = 2
) -> int:
    """
    Heuristic estimate of finite-state complexity using greedy
    state-merging.

    Starts with N states (one per position) and greedily merges
    states with identical outputs and compatible transitions.

    Complexity: O(N²) time.
    """
    target = [seq(n) for n in range(N)]

    # Build initial automaton: state i outputs target[i], transitions to i+1
    state_output = list(target)
    state_next = list(range(1, N)) + [0]

    # Greedy merge: if states i, j have same output and compatible transitions
    state_map = list(range(N))

    def find(x):
        while state_map[x] != x:
            state_map[x] = state_map[state_map[x]]
            x = state_map[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx != ry:
            state_map[rx] = ry

    changed = True
    while changed:
        changed = False
        for i in range(N):
            for j in range(i + 1, N):
                ri, rj = find(i), find(j)
                if ri != rj:
                    if (state_output[ri] == state_output[rj] and
                            find(state_next[ri]) == find(state_next[rj])):
                        union(ri, rj)
                        changed = True

    return len(set(find(i) for i in range(N)))


# ============================================================
# §6. Eventual Periodicity Detection (Efficient)
# ============================================================

def detect_periodicity_kmp(
    seq: Callable[[int], int],
    N: int
) -> Optional[Tuple[int, int]]:
    """
    Detect eventual periodicity using a KMP-style failure function.

    For each suffix starting at position s, compute the shortest period
    of seq[s:N] using the failure function.

    Args:
        seq: Sequence oracle.
        N: Prefix length.

    Returns:
        (start, period) if found, None if no periodicity detected.

    Complexity: O(N²) worst case.
    """
    prefix = [seq(n) for n in range(N)]

    for start in range(N // 3):  # Don't start too late
        suffix = prefix[start:]
        L = len(suffix)
        if L < 4:
            continue

        # Compute failure function
        fail = [0] * L
        k = 0
        for i in range(1, L):
            while k > 0 and suffix[k] != suffix[i]:
                k = fail[k - 1]
            if suffix[k] == suffix[i]:
                k += 1
            fail[i] = k

        # The shortest period is L - fail[L-1]
        period = L - fail[L - 1]
        if period < L and L >= 3 * period:  # Need enough repetitions
            # Verify the period covers the suffix
            valid = True
            for i in range(period, L):
                if suffix[i] != suffix[i % period]:
                    valid = False
                    break
            if valid:
                return (start, period)

    return None


# ============================================================
# §7. Utility: Substitution Systems
# ============================================================

def substitution_fixed_point(
    rules: Dict[int, List[int]],
    start: int,
    length: int
) -> List[int]:
    """
    Compute the fixed point of a substitution system.

    Args:
        rules: Mapping symbol → replacement word.
        start: Starting symbol.
        length: Desired length of the output.

    Returns:
        Prefix of the fixed-point sequence.
    """
    seq = [start]
    while len(seq) < length:
        new_seq = []
        for s in seq:
            new_seq.extend(rules.get(s, [s]))
        seq = new_seq
    return seq[:length]


def analyze_substitution_complexity(
    rules: Dict[int, List[int]],
    start: int,
    max_m: int = 20,
    prefix_length: int = 500
) -> Dict[str, object]:
    """
    Analyze the factor complexity of a substitution system's fixed point.

    Returns a dictionary with:
    - 'sequence': first terms
    - 'profile': complexity profile
    - 'differences': first differences
    - 'is_linear': whether complexity appears linear
    - 'linear_fit': (slope, intercept) of best linear fit
    """
    seq_list = substitution_fixed_point(rules, start, prefix_length)
    seq_fn = lambda n: seq_list[n] if n < len(seq_list) else 0

    profile = factor_complexity_profile(seq_fn, max_m, prefix_length)
    diffs = [profile[i + 1] - profile[i] for i in range(len(profile) - 1)]
    is_linear, slope, intercept = is_linearly_bounded(profile)

    return {
        'sequence': seq_list[:30],
        'profile': profile,
        'differences': diffs,
        'is_linear': is_linear,
        'linear_fit': (slope, intercept),
    }


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Thue-Morse sequence
    def thue_morse(n: int) -> int:
        return bin(n).count('1') % 2

    print("Factor complexity analysis of Thue-Morse sequence:")
    profile = factor_complexity_profile(thue_morse, 15, 500)
    diffs = complexity_first_differences(thue_morse, 15, 500)
    is_lin, slope, intercept = is_linearly_bounded(profile)
    print(f"  Profile: {profile}")
    print(f"  First differences: {diffs}")
    print(f"  Linear: {is_lin}, slope={slope:.2f}, intercept={intercept:.2f}")
    print()

    # Follower set analysis
    print("Follower set analysis of Thue-Morse:")
    n_follower_sets = count_distinct_follower_sets(thue_morse, 3, 2, 200)
    print(f"  Distinct follower sets (word_len=3, ext_len=2): {n_follower_sets}")
    print()

    # Substitution system
    print("Fibonacci substitution (0→01, 1→0):")
    result = analyze_substitution_complexity({0: [0, 1], 1: [0]}, 0)
    print(f"  First 30 terms: {result['sequence']}")
    print(f"  Profile: {result['profile']}")
    print(f"  Linear: {result['is_linear']}, fit: p(n) ≈ {result['linear_fit'][0]:.2f}·n + {result['linear_fit'][1]:.2f}")
    print()

    # Finite-state complexity
    print("Finite-state complexity of Thue-Morse prefixes:")
    for N in [4, 6, 8, 10]:
        K = fs_complexity_exhaustive(thue_morse, N, 2, 6)
        print(f"  N={N}: fsComplexity = {K}")
