#!/usr/bin/env python3
"""
Tropical Descriptive Complexity: Algorithms

Implements the core algorithms from the research:
1. Formula-to-automaton compilation (structural induction)
2. Tropical automaton evaluation via dynamic programming
3. State complexity analysis
4. Tropical matrix semantics
"""

from typing import List, Tuple, Dict, Set, Optional, Callable
from dataclasses import dataclass, field
import itertools

INF = float('inf')


# ============================================================
# Tropical Semiring Operations
# ============================================================

def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with infinity handling)."""
    if a == INF or b == INF:
        return INF
    return a + b


def trop_zero() -> float:
    """Tropical additive identity: ∞."""
    return INF


def trop_one() -> float:
    """Tropical multiplicative identity: 0."""
    return 0.0


# ============================================================
# Tropical Matrix Operations
# ============================================================

class TropicalMatrix:
    """Matrix over the tropical (min-plus) semiring."""

    def __init__(self, n: int, m: int, data: Optional[List[List[float]]] = None):
        self.n = n  # rows
        self.m = m  # columns
        if data is not None:
            self.data = [row[:] for row in data]
        else:
            self.data = [[INF] * m for _ in range(n)]

    def __getitem__(self, idx: Tuple[int, int]) -> float:
        return self.data[idx[0]][idx[1]]

    def __setitem__(self, idx: Tuple[int, int], val: float):
        self.data[idx[0]][idx[1]] = val

    def __repr__(self):
        rows = []
        for row in self.data:
            cells = [f"{x:.1f}" if x < INF else "∞" for x in row]
            rows.append("[" + ", ".join(f"{c:>6s}" for c in cells) + "]")
        return "\n".join(rows)

    @staticmethod
    def identity(n: int) -> 'TropicalMatrix':
        """Tropical identity matrix: 0 on diagonal, ∞ elsewhere."""
        m = TropicalMatrix(n, n)
        for i in range(n):
            m[i, i] = 0
        return m

    def trop_matmul(self, other: 'TropicalMatrix') -> 'TropicalMatrix':
        """Tropical matrix multiplication: (A⊗B)_{ij} = min_k (A_{ik} + B_{kj})."""
        assert self.m == other.n
        result = TropicalMatrix(self.n, other.m)
        for i in range(self.n):
            for j in range(other.m):
                val = INF
                for k in range(self.m):
                    val = min(val, trop_mul(self[i, k], other[k, j]))
                result[i, j] = val
        return result

    def trop_add(self, other: 'TropicalMatrix') -> 'TropicalMatrix':
        """Tropical matrix addition: pointwise min."""
        assert self.n == other.n and self.m == other.m
        result = TropicalMatrix(self.n, self.m)
        for i in range(self.n):
            for j in range(self.m):
                result[i, j] = min(self[i, j], other[i, j])
        return result


# ============================================================
# Tropical Automaton with Matrix Semantics
# ============================================================

@dataclass
class TropicalAutomaton:
    """
    Tropical weighted automaton with explicit matrix representation.

    The recognized series is:
      f(w) = init^T ⊗ M(a₁) ⊗ M(a₂) ⊗ ... ⊗ M(aₙ) ⊗ final
    where ⊗ is tropical matrix multiplication.

    Attributes:
        n_states: Number of states
        alphabet: Set of input symbols
        init_vec: Initial cost vector (1×n)
        matrices: Symbol → transition matrix (n×n)
        final_vec: Terminal cost vector (n×1)
    """
    n_states: int
    alphabet: List[str]
    init_vec: List[float]
    matrices: Dict[str, TropicalMatrix] = field(default_factory=dict)
    final_vec: List[float] = field(default_factory=list)

    def evaluate(self, word: List[str]) -> float:
        """
        Evaluate the automaton on a word using tropical matrix multiplication.

        Time complexity: O(|w| · n³) where n = n_states
        Space complexity: O(n²)
        """
        # Start with identity matrix (current state distribution)
        current = TropicalMatrix(1, self.n_states,
                                 [self.init_vec[:]])

        # Multiply by transition matrices
        for symbol in word:
            if symbol not in self.matrices:
                return INF
            current = current.trop_matmul(self.matrices[symbol])

        # Apply final vector
        result = INF
        for j in range(self.n_states):
            result = min(result, trop_mul(current[0, j], self.final_vec[j]))
        return result

    def evaluate_dp(self, word: List[str]) -> float:
        """
        Evaluate using dynamic programming (Viterbi-style).

        Time complexity: O(|w| · n²)
        Space complexity: O(n)
        """
        n = self.n_states
        # dp[q] = min cost to reach state q after processing prefix
        dp = self.init_vec[:]

        for symbol in word:
            if symbol not in self.matrices:
                return INF
            M = self.matrices[symbol]
            new_dp = [INF] * n
            for q_prime in range(n):
                for q in range(n):
                    cost = trop_mul(dp[q], M[q, q_prime])
                    new_dp[q_prime] = min(new_dp[q_prime], cost)
            dp = new_dp

        # Apply final costs
        result = INF
        for q in range(n):
            result = min(result, trop_mul(dp[q], self.final_vec[q]))
        return result


# ============================================================
# Formula-to-Automaton Compiler
# ============================================================

def compile_const(c: float, alphabet: List[str]) -> TropicalAutomaton:
    """
    Compile constant formula to 1-state automaton.

    Algorithm:
        States: {0}
        init[0] = c
        M(a)[0,0] = 0 for all a
        final[0] = 0

    Correctness: f(w) = c + 0 + ... + 0 + 0 = c for all w.
    State complexity: 1
    """
    aut = TropicalAutomaton(
        n_states=1,
        alphabet=alphabet,
        init_vec=[c],
        final_vec=[0]
    )
    for a in alphabet:
        M = TropicalMatrix(1, 1, [[0]])
        aut.matrices[a] = M
    return aut


def compile_letter_cost(cost_fn: Callable[[str], float],
                        alphabet: List[str]) -> TropicalAutomaton:
    """
    Compile letter-cost formula Σᵢ f(aᵢ) to 1-state automaton.

    Algorithm:
        States: {0}
        init[0] = 0
        M(a)[0,0] = f(a)
        final[0] = 0

    Correctness: f(w) = 0 + f(a₁) + ... + f(aₙ) + 0 = Σ f(aᵢ)
    State complexity: 1
    """
    aut = TropicalAutomaton(
        n_states=1,
        alphabet=alphabet,
        init_vec=[0],
        final_vec=[0]
    )
    for a in alphabet:
        M = TropicalMatrix(1, 1, [[cost_fn(a)]])
        aut.matrices[a] = M
    return aut


def compile_exists(pred: Callable[[str], bool],
                   alphabet: List[str]) -> TropicalAutomaton:
    """
    Compile existential predicate ∃i: p(aᵢ) to 2-state automaton.

    Algorithm:
        States: {0='unseen', 1='seen'}
        init = [0, ∞]
        M(a) = [[0, 0 if p(a) else ∞],
                [∞, 0]]
        final = [∞, 0]

    Correctness: Minimum-cost path goes 0→...→0→1→...→1 with
    transition 0→1 possible only when p(a)=true (cost 0).
    State complexity: 2
    """
    aut = TropicalAutomaton(
        n_states=2,
        alphabet=alphabet,
        init_vec=[0, INF],
        final_vec=[INF, 0]
    )
    for a in alphabet:
        M = TropicalMatrix(2, 2)
        M[0, 0] = 0
        M[0, 1] = 0 if pred(a) else INF
        M[1, 0] = INF
        M[1, 1] = 0
        aut.matrices[a] = M
    return aut


def compile_forall(pred: Callable[[str], bool],
                   alphabet: List[str]) -> TropicalAutomaton:
    """
    Compile universal predicate ∀i: p(aᵢ) to 1-state automaton.

    Algorithm:
        States: {0}
        init[0] = 0
        M(a)[0,0] = 0 if p(a) else ∞
        final[0] = 0

    Correctness: f(w) = Σ (0 if p(aᵢ) else ∞) = 0 iff all p(aᵢ), else ∞
    State complexity: 1
    """
    return compile_letter_cost(lambda a: 0 if pred(a) else INF, alphabet)


def compile_min(A1: TropicalAutomaton,
                A2: TropicalAutomaton) -> TropicalAutomaton:
    """
    Compile min(f₁, f₂) via disjoint union of automata.

    Algorithm:
        States: S₁ ⊔ S₂ (disjoint union)
        init = [A₁.init, A₂.init]
        M(a) = [[M₁(a), ∞],
                [∞, M₂(a)]]   (block diagonal)
        final = [A₁.final, A₂.final]

    Correctness: Paths stay within one component.
    min over all paths = min(min over A₁ paths, min over A₂ paths)
    State complexity: |S₁| + |S₂|
    """
    n1, n2 = A1.n_states, A2.n_states
    n = n1 + n2
    alphabet = list(set(A1.alphabet) | set(A2.alphabet))

    aut = TropicalAutomaton(
        n_states=n,
        alphabet=alphabet,
        init_vec=A1.init_vec + A2.init_vec,
        final_vec=A1.final_vec + A2.final_vec
    )

    for a in alphabet:
        M = TropicalMatrix(n, n)
        # Upper-left block: A₁
        if a in A1.matrices:
            M1 = A1.matrices[a]
            for i in range(n1):
                for j in range(n1):
                    M[i, j] = M1[i, j]
        # Lower-right block: A₂
        if a in A2.matrices:
            M2 = A2.matrices[a]
            for i in range(n2):
                for j in range(n2):
                    M[n1 + i, n1 + j] = M2[i, j]
        # Cross blocks remain ∞
        aut.matrices[a] = M

    return aut


def compile_add(A1: TropicalAutomaton,
                A2: TropicalAutomaton) -> TropicalAutomaton:
    """
    Compile f₁ + f₂ via product (tensor) of automata.

    Algorithm:
        States: S₁ × S₂ (Cartesian product)
        init[(q₁,q₂)] = A₁.init[q₁] + A₂.init[q₂]
        M(a)[(q₁,q₂), (q₁',q₂')] = M₁(a)[q₁,q₁'] + M₂(a)[q₂,q₂']
        final[(q₁,q₂)] = A₁.final[q₁] + A₂.final[q₂]

    Correctness: Product paths decompose into independent component paths.
    min over product paths = (min over A₁ paths) + (min over A₂ paths)

    Key algebraic fact: ⨅_{(x,y)} (f(x) + g(y)) = (⨅_x f(x)) + (⨅_y g(y))

    State complexity: |S₁| × |S₂|
    """
    n1, n2 = A1.n_states, A2.n_states
    n = n1 * n2
    alphabet = list(set(A1.alphabet) | set(A2.alphabet))

    def idx(q1: int, q2: int) -> int:
        return q1 * n2 + q2

    init = [INF] * n
    final = [INF] * n
    for q1 in range(n1):
        for q2 in range(n2):
            init[idx(q1, q2)] = trop_mul(A1.init_vec[q1], A2.init_vec[q2])
            final[idx(q1, q2)] = trop_mul(A1.final_vec[q1], A2.final_vec[q2])

    aut = TropicalAutomaton(
        n_states=n, alphabet=alphabet,
        init_vec=init, final_vec=final
    )

    for a in alphabet:
        M = TropicalMatrix(n, n)
        M1 = A1.matrices.get(a)
        M2 = A2.matrices.get(a)
        if M1 is None or M2 is None:
            aut.matrices[a] = M  # all ∞
            continue
        for q1 in range(n1):
            for q2 in range(n2):
                for q1p in range(n1):
                    for q2p in range(n2):
                        M[idx(q1, q2), idx(q1p, q2p)] = trop_mul(
                            M1[q1, q1p], M2[q2, q2p]
                        )
        aut.matrices[a] = M

    return aut


def compile_formula(formula_type: str,
                    alphabet: List[str],
                    **kwargs) -> TropicalAutomaton:
    """
    Master compilation function: formula → tropical automaton.

    Implements the structural induction from the main theorem.

    Args:
        formula_type: One of 'const', 'letter_cost', 'exists', 'forall', 'min', 'add'
        alphabet: Base alphabet symbols
        **kwargs: Constructor-specific arguments

    Returns:
        TropicalAutomaton computing the formula's semantics
    """
    if formula_type == 'const':
        return compile_const(kwargs['c'], alphabet)
    elif formula_type == 'letter_cost':
        return compile_letter_cost(kwargs['cost_fn'], alphabet)
    elif formula_type == 'exists':
        return compile_exists(kwargs['pred'], alphabet)
    elif formula_type == 'forall':
        return compile_forall(kwargs['pred'], alphabet)
    elif formula_type == 'min':
        return compile_min(kwargs['left'], kwargs['right'])
    elif formula_type == 'add':
        return compile_add(kwargs['left'], kwargs['right'])
    else:
        raise ValueError(f"Unknown formula type: {formula_type}")


# ============================================================
# State Complexity Analysis
# ============================================================

def state_complexity_bound(formula_tree: dict) -> int:
    """
    Compute an upper bound on the number of states needed for
    the compiled automaton, given a formula tree.

    Args:
        formula_tree: dict with 'type' and optional 'left', 'right' children
            Types: 'const' (1 state), 'letter_cost' (1 state),
                   'exists' (2 states), 'forall' (1 state),
                   'min' (sum), 'add' (product)

    Returns:
        Upper bound on state count

    Time complexity: O(|formula|)
    """
    t = formula_tree['type']
    if t == 'const':
        return 1
    elif t == 'letter_cost':
        return 1
    elif t == 'exists':
        return 2
    elif t == 'forall':
        return 1
    elif t == 'min':
        return (state_complexity_bound(formula_tree['left']) +
                state_complexity_bound(formula_tree['right']))
    elif t == 'add':
        return (state_complexity_bound(formula_tree['left']) *
                state_complexity_bound(formula_tree['right']))
    else:
        raise ValueError(f"Unknown type: {t}")


# ============================================================
# Verification
# ============================================================

def verify_compilation(aut: TropicalAutomaton,
                       eval_fn: Callable[[List[str]], float],
                       test_words: List[List[str]],
                       tol: float = 1e-10) -> bool:
    """
    Verify that a compiled automaton matches the formula semantics
    on a set of test words.

    Returns True if all evaluations match within tolerance.
    """
    for w in test_words:
        aut_val = aut.evaluate(w)
        formula_val = eval_fn(w)
        if abs(aut_val - formula_val) > tol and not (aut_val == INF and formula_val == INF):
            print(f"  MISMATCH on {w}: automaton={aut_val}, formula={formula_val}")
            return False
    return True


if __name__ == "__main__":
    print("Tropical Descriptive Complexity: Algorithm Demonstrations")
    print("=" * 60)

    alphabet = ['a', 'b', 'c']

    # Test matrix multiplication
    print("\n1. Tropical Matrix Multiplication")
    A = TropicalMatrix(2, 2, [[0, 3], [INF, 1]])
    B = TropicalMatrix(2, 2, [[2, INF], [1, 0]])
    C = A.trop_matmul(B)
    print(f"  A:\n{A}")
    print(f"  B:\n{B}")
    print(f"  A⊗B:\n{C}")

    # Test compilation
    print("\n2. Formula Compilation Verification")

    # Constant
    aut_const = compile_const(7, alphabet)
    words = [[], ['a'], ['b', 'c'], ['a', 'b', 'c']]
    ok = verify_compilation(aut_const, lambda w: 7, words)
    print(f"  const(7): {'✓' if ok else '✗'}")

    # Letter cost (word length)
    aut_len = compile_letter_cost(lambda a: 1, alphabet)
    ok = verify_compilation(aut_len, lambda w: len(w), words)
    print(f"  length: {'✓' if ok else '✗'}")

    # Exists
    aut_ex = compile_exists(lambda a: a == 'a', alphabet)
    ok = verify_compilation(
        aut_ex,
        lambda w: 0 if 'a' in w else INF,
        words + [['b', 'b'], ['c', 'a', 'b']]
    )
    print(f"  exists(a): {'✓' if ok else '✗'}")

    # Forall
    aut_fa = compile_forall(lambda a: a == 'a', alphabet)
    ok = verify_compilation(
        aut_fa,
        lambda w: 0 if all(x == 'a' for x in w) else INF,
        words + [['a', 'a'], ['a', 'b']]
    )
    print(f"  forall(a): {'✓' if ok else '✗'}")

    # Min composition
    aut_min = compile_min(aut_ex, aut_len)
    ok = verify_compilation(
        aut_min,
        lambda w: min(0 if 'a' in w else INF, len(w)),
        words + [['b', 'b']]
    )
    print(f"  min(exists(a), length): {'✓' if ok else '✗'} ({aut_min.n_states} states)")

    # Add composition
    aut_add = compile_add(aut_ex, aut_len)
    ok = verify_compilation(
        aut_add,
        lambda w: (0 if 'a' in w else INF) + len(w) if 'a' in w else INF,
        words + [['b', 'b']]
    )
    print(f"  exists(a) + length: {'✓' if ok else '✗'} ({aut_add.n_states} states)")

    # State complexity
    print("\n3. State Complexity Bounds")
    formulas = [
        ("const", {'type': 'const'}),
        ("∃a", {'type': 'exists'}),
        ("∃a ∧ ∃b (as +)", {
            'type': 'add',
            'left': {'type': 'exists'},
            'right': {'type': 'exists'}
        }),
        ("min(∃a, length)", {
            'type': 'min',
            'left': {'type': 'exists'},
            'right': {'type': 'letter_cost'}
        }),
        ("(∃a + ∃b) + length", {
            'type': 'add',
            'left': {
                'type': 'add',
                'left': {'type': 'exists'},
                'right': {'type': 'exists'}
            },
            'right': {'type': 'letter_cost'}
        }),
    ]
    for name, tree in formulas:
        bound = state_complexity_bound(tree)
        print(f"  {name}: ≤ {bound} states")

    # DP vs matrix evaluation comparison
    print("\n4. DP vs Matrix Evaluation")
    aut = compile_min(
        compile_exists(lambda a: a == 'a', alphabet),
        compile_letter_cost(lambda a: 2 if a == 'b' else 1, alphabet)
    )
    test_words = [[], ['a'], ['b', 'c'], ['a', 'b', 'b']]
    for w in test_words:
        mat_val = aut.evaluate(w)
        dp_val = aut.evaluate_dp(w)
        match = "✓" if abs(mat_val - dp_val) < 1e-10 or (mat_val == INF and dp_val == INF) else "✗"
        v = f"{mat_val:.1f}" if mat_val < INF else "∞"
        print(f"  {w}: matrix={v}, dp={v} {match}")

    print("\nAll algorithm tests completed!")
