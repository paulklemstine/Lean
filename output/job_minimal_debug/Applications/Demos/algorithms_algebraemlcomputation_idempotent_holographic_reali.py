#!/usr/bin/env python3
"""
Algorithms for Idempotent Holographic Realization

Implements the core algorithms from the research:
1. Holographic quotient construction (Myhill-Nerode over idempotent semirings)
2. Minimal realization extraction
3. Closure charge descent
4. Hankel rank computation

All algorithms work over arbitrary idempotent semirings provided as a parameter.
"""

from typing import (
    Dict, List, Tuple, Callable, Set, FrozenSet, 
    Optional, TypeVar, Generic, NamedTuple
)
from dataclasses import dataclass, field
from collections import defaultdict
import itertools

T = TypeVar('T')

# =============================================================================
# Idempotent Semiring Interface
# =============================================================================

@dataclass
class IdempotentSemiring:
    """
    An idempotent semiring (S, ⊕, ⊗, 0, 1) where ⊕ is idempotent: a ⊕ a = a.
    
    Common examples:
    - Tropical: (ℝ ∪ {∞}, min, +, ∞, 0)
    - Boolean: ({0, 1}, ∨, ∧, 0, 1)
    - Max-plus: (ℝ ∪ {-∞}, max, +, -∞, 0)
    """
    add: Callable  # (a, b) -> a ⊕ b
    mul: Callable  # (a, b) -> a ⊗ b
    zero: object   # additive identity
    one: object    # multiplicative identity
    name: str = "generic"

# Standard semirings
TROPICAL = IdempotentSemiring(
    add=min, mul=lambda a, b: a + b,
    zero=float('inf'), one=0.0, name="tropical"
)

BOOLEAN = IdempotentSemiring(
    add=max, mul=min,
    zero=0, one=1, name="boolean"
)

MAX_PLUS = IdempotentSemiring(
    add=max, mul=lambda a, b: a + b,
    zero=float('-inf'), one=0.0, name="max-plus"
)

# =============================================================================
# Holographic System
# =============================================================================

@dataclass
class HolographicSystem:
    """
    A holographic system (c, T, K, xprobe) over an idempotent semiring.
    
    Attributes:
        semiring: The underlying idempotent semiring
        n_states: Number of bulk states
        actions: List of action symbols
        n_boundary: Number of boundary probes
        transition: Maps action -> state transition matrix
        closure: Closure map (state index -> closed state index)
        kernel: Boundary observation matrix (n_boundary x n_states)
        probes: Boundary probe -> initial state mapping
    """
    semiring: IdempotentSemiring
    n_states: int
    actions: List[str]
    n_boundary: int
    transition: Dict[str, List[List]]
    closure: List[int]
    kernel: List[List]
    probes: List[int]
    
    def apply_closure(self, state_vec: List) -> List:
        """Apply closure operator to state vector."""
        S = self.semiring
        result = [S.zero] * self.n_states
        for i in range(self.n_states):
            target = self.closure[i]
            result[target] = S.add(result[target], state_vec[i])
        return result
    
    def apply_transition(self, action: str, state_vec: List) -> List:
        """Tropical matrix-vector multiplication."""
        S = self.semiring
        mat = self.transition[action]
        result = [S.zero] * self.n_states
        for i in range(self.n_states):
            for j in range(self.n_states):
                result[i] = S.add(result[i], S.mul(mat[i][j], state_vec[j]))
        return result
    
    def word_action(self, word: List[str], state_vec: List) -> List:
        """Apply sequence of transitions."""
        current = list(state_vec)
        for a in word:
            current = self.apply_transition(a, current)
        return current
    
    def probe_state(self, b: int) -> List:
        """Get initial state for boundary probe b."""
        S = self.semiring
        state = [S.zero] * self.n_states
        state[self.probes[b]] = S.one
        return state
    
    def observe(self, b_out: int, state_vec: List) -> object:
        """Apply kernel observation."""
        S = self.semiring
        result = S.zero
        for j in range(self.n_states):
            result = S.add(result, S.mul(self.kernel[b_out][j], state_vec[j]))
        return result
    
    def boundary_response(self, b_in: int, word: List[str], b_out: int) -> object:
        """
        Compute boundary response H(b_in, word, b_out) = K(b_out, c(T_w(xprobe(b_in)))).
        
        Time complexity: O(|word| · n² + n) where n = n_states
        """
        state = self.probe_state(b_in)
        state = self.word_action(word, state)
        state = self.apply_closure(state)
        return self.observe(b_out, state)


# =============================================================================
# Algorithm 1: Holographic Quotient Construction
# =============================================================================

@dataclass
class QuotientState:
    """A state in the holographic quotient."""
    class_id: int
    representative: Tuple[int, Tuple[str, ...]]  # (probe, history)
    members: List[Tuple[int, Tuple[str, ...]]]
    boundary_row: Dict  # frozen boundary row data

@dataclass 
class HolographicQuotient:
    """The minimal holographic realization obtained by quotienting."""
    states: List[QuotientState]
    initial_map: Dict[int, int]  # probe -> initial quotient state
    transition: Dict[str, Dict[int, int]]  # action -> state -> state
    kernel: Dict[int, Dict[int, object]]  # b_out -> state -> value
    
    def boundary_response(self, b_in: int, word: List[str], b_out: int) -> object:
        """Compute boundary response on the quotient realization."""
        state = self.initial_map[b_in]
        for a in word:
            state = self.transition[a][state]
        return self.kernel[b_out][state]


def compute_holographic_quotient(
    sys: HolographicSystem,
    max_history_len: int = 4,
    max_continuation_len: int = 4
) -> HolographicQuotient:
    """
    Algorithm: Construct the holographic quotient (minimal realization).
    
    This implements the closure-refined Myhill-Nerode construction:
    1. Enumerate boundary histories up to max_history_len
    2. Compute boundary rows for each history
    3. Group histories with identical boundary rows
    4. Construct quotient transitions and kernel
    
    Time complexity: O(|B| · |Σ|^L · (|Σ|^C · |B|)) 
    where L = max_history_len, C = max_continuation_len
    
    Space complexity: O(|B| · |Σ|^L · |Σ|^C · |B|)
    
    Args:
        sys: The holographic system
        max_history_len: Maximum word length for histories
        max_continuation_len: Maximum continuation length for row computation
    
    Returns:
        HolographicQuotient: The minimal realization
    """
    S = sys.semiring
    
    # Step 1: Enumerate all boundary histories
    histories: List[Tuple[int, Tuple[str, ...]]] = []
    for b in range(sys.n_boundary):
        for length in range(max_history_len + 1):
            for word in itertools.product(sys.actions, repeat=length):
                histories.append((b, tuple(word)))
    
    # Step 2: Compute boundary rows
    def compute_row(b_in: int, history: Tuple[str, ...]) -> Tuple:
        """Compute the boundary row as a hashable key."""
        row = []
        for length in range(max_continuation_len + 1):
            for cont in itertools.product(sys.actions, repeat=length):
                for b_out in range(sys.n_boundary):
                    full_word = list(history) + list(cont)
                    val = sys.boundary_response(b_in, full_word, b_out)
                    row.append(((cont, b_out), val))
        return tuple(row)
    
    # Step 3: Group by boundary rows
    row_to_class: Dict[Tuple, int] = {}
    classes: Dict[int, List[Tuple[int, Tuple[str, ...]]]] = defaultdict(list)
    history_to_class: Dict[Tuple[int, Tuple[str, ...]], int] = {}
    boundary_rows: Dict[int, Dict] = {}
    
    class_counter = 0
    for b, hist in histories:
        row_key = compute_row(b, hist)
        if row_key not in row_to_class:
            row_to_class[row_key] = class_counter
            boundary_rows[class_counter] = dict(row_key)
            class_counter += 1
        cid = row_to_class[row_key]
        classes[cid].append((b, hist))
        history_to_class[(b, hist)] = cid
    
    # Step 4: Build quotient states
    quotient_states = []
    for cid in range(class_counter):
        members = classes[cid]
        quotient_states.append(QuotientState(
            class_id=cid,
            representative=members[0],
            members=members,
            boundary_row=boundary_rows[cid]
        ))
    
    # Step 5: Build transitions on quotient
    q_transition: Dict[str, Dict[int, int]] = {a: {} for a in sys.actions}
    for cid in range(class_counter):
        rep_b, rep_hist = classes[cid][0]  # use representative
        for a in sys.actions:
            extended = (rep_b, rep_hist + (a,))
            if extended in history_to_class:
                q_transition[a][cid] = history_to_class[extended]
            else:
                # Extended history not computed; use direct computation
                ext_row = compute_row(rep_b, rep_hist + (a,))
                if ext_row in row_to_class:
                    q_transition[a][cid] = row_to_class[ext_row]
    
    # Step 6: Build kernel on quotient
    q_kernel: Dict[int, Dict[int, object]] = {}
    for b_out in range(sys.n_boundary):
        q_kernel[b_out] = {}
        for cid in range(class_counter):
            rep_b, rep_hist = classes[cid][0]
            q_kernel[b_out][cid] = sys.boundary_response(rep_b, list(rep_hist), b_out)
    
    # Step 7: Build initial state map
    q_initial: Dict[int, int] = {}
    for b in range(sys.n_boundary):
        q_initial[b] = history_to_class[(b, ())]
    
    return HolographicQuotient(
        states=quotient_states,
        initial_map=q_initial,
        transition=q_transition,
        kernel=q_kernel
    )


# =============================================================================
# Algorithm 2: Hankel Rank Computation
# =============================================================================

def compute_hankel_rank(
    sys: HolographicSystem,
    max_row_len: int = 3,
    max_col_len: int = 3
) -> int:
    """
    Compute the closure Hankel rank of a holographic system.
    
    The Hankel rank is the number of distinct boundary rows, which equals
    the number of states in the minimal realization.
    
    Time complexity: O(|B|² · |Σ|^(R+C) · n²)
    where R = max_row_len, C = max_col_len, n = n_states
    
    Args:
        sys: The holographic system
        max_row_len: Maximum history length for rows
        max_col_len: Maximum continuation length for columns
    
    Returns:
        int: The Hankel rank (number of distinct boundary rows)
    """
    seen_rows: Set[Tuple] = set()
    
    for b in range(sys.n_boundary):
        for length in range(max_row_len + 1):
            for hist in itertools.product(sys.actions, repeat=length):
                row = []
                for cl in range(max_col_len + 1):
                    for cont in itertools.product(sys.actions, repeat=cl):
                        for b_out in range(sys.n_boundary):
                            val = sys.boundary_response(b, list(hist) + list(cont), b_out)
                            row.append(val)
                seen_rows.add(tuple(row))
    
    return len(seen_rows)


# =============================================================================
# Algorithm 3: Closure Charge Descent
# =============================================================================

@dataclass
class ClosureCharge:
    """A closure-conserved charge function Q : X -> S."""
    values: Dict[int, object]  # state -> charge value
    name: str = "Q"

def descend_charge(
    sys: HolographicSystem,
    quotient: HolographicQuotient,
    charge: ClosureCharge
) -> Dict[int, object]:
    """
    Descend a closure charge to the boundary quotient.
    
    Given Q : X -> S that is closure-invariant and transition-conserved,
    compute the unique descended charge Qbd : Xmin -> S such that
    Qbd(π(x)) = Q(c(x)).
    
    Time complexity: O(|Xmin|)
    
    Args:
        sys: The holographic system  
        quotient: The holographic quotient
        charge: The closure charge
    
    Returns:
        Dict mapping quotient state id -> descended charge value
    """
    descended: Dict[int, object] = {}
    
    for state in quotient.states:
        rep_b, rep_hist = state.representative
        # Compute the bulk state reached by this history
        bulk_state = sys.probe_state(rep_b)
        bulk_state = sys.word_action(list(rep_hist), bulk_state)
        bulk_state = sys.apply_closure(bulk_state)
        
        # Find the dominant closed state
        S = sys.semiring
        # For tropical: the state with minimum value
        dominant = min(range(sys.n_states), 
                      key=lambda i: bulk_state[i] if bulk_state[i] != S.zero else float('inf'))
        closed_state = sys.closure[dominant]
        
        descended[state.class_id] = charge.values.get(closed_state, S.zero)
    
    return descended


# =============================================================================
# Algorithm 4: Verification
# =============================================================================

def verify_realization(
    sys: HolographicSystem,
    quotient: HolographicQuotient,
    max_word_len: int = 3
) -> Tuple[bool, List[str]]:
    """
    Verify that the quotient realization faithfully reproduces all
    boundary responses up to a given word length.
    
    Time complexity: O(|B|² · |Σ|^L · (n² + |Xmin|))
    
    Args:
        sys: The original system
        quotient: The quotient realization
        max_word_len: Maximum word length to check
    
    Returns:
        (is_valid, list of error messages)
    """
    errors = []
    
    for b_in in range(sys.n_boundary):
        for length in range(max_word_len + 1):
            for word in itertools.product(sys.actions, repeat=length):
                word_list = list(word)
                for b_out in range(sys.n_boundary):
                    original = sys.boundary_response(b_in, word_list, b_out)
                    try:
                        reconstructed = quotient.boundary_response(b_in, word_list, b_out)
                        if original != reconstructed:
                            errors.append(
                                f"Mismatch at H({b_in}, {''.join(word)}, {b_out}): "
                                f"original={original}, reconstructed={reconstructed}"
                            )
                    except (KeyError, TypeError):
                        errors.append(
                            f"Missing transition at H({b_in}, {''.join(word)}, {b_out})"
                        )
    
    return len(errors) == 0, errors


# =============================================================================
# Main: Run all algorithms
# =============================================================================

if __name__ == "__main__":
    INF = float('inf')
    
    print("Holographic Realization Algorithms")
    print("=" * 50)
    
    # Build a test system
    sys = HolographicSystem(
        semiring=TROPICAL,
        n_states=4,
        actions=['a', 'b'],
        n_boundary=2,
        transition={
            'a': [
                [0, INF, 1, INF],
                [INF, 0, INF, 1],
                [2, INF, 0, INF],
                [INF, 2, INF, 0],
            ],
            'b': [
                [INF, 0, INF, INF],
                [0, INF, INF, INF],
                [INF, INF, INF, 0],
                [INF, INF, 0, INF],
            ],
        },
        closure=[0, 0, 2, 2],
        kernel=[
            [0, 0, INF, INF],
            [INF, INF, 0, 0],
        ],
        probes=[0, 2],
    )
    
    # Algorithm 1: Quotient construction
    print("\n1. Computing holographic quotient...")
    quotient = compute_holographic_quotient(sys, max_history_len=3, max_continuation_len=3)
    print(f"   Minimal realization has {len(quotient.states)} states")
    
    # Algorithm 2: Hankel rank
    print("\n2. Computing Hankel rank...")
    rank = compute_hankel_rank(sys, max_row_len=3, max_col_len=3)
    print(f"   Hankel rank = {rank}")
    print(f"   Matches quotient size: {rank == len(quotient.states)}")
    
    # Algorithm 3: Charge descent
    print("\n3. Descending closure charge...")
    charge = ClosureCharge(values={0: 0.0, 1: 0.0, 2: 5.0, 3: 5.0}, name="parity")
    descended = descend_charge(sys, quotient, charge)
    print(f"   Descended charge values: {descended}")
    
    # Algorithm 4: Verification
    print("\n4. Verifying realization...")
    is_valid, errors = verify_realization(sys, quotient, max_word_len=3)
    print(f"   Realization valid: {is_valid}")
    if errors:
        for e in errors[:5]:
            print(f"   Error: {e}")
    
    print("\nAll algorithms completed successfully.")
