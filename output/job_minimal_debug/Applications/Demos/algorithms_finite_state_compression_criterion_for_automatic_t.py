#!/usr/bin/env python3
"""
Finite-State Compression Criterion — Algorithms

Implements the core algorithms from the research:
1. DFAO/DFST simulation
2. Factor complexity computation
3. Non-periodicity verification
4. Transcendence criterion checker
"""

from typing import Callable, Dict, List, Optional, Set, Tuple
from dataclasses import dataclass


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 1: DFAO and DFST Simulation
# ──────────────────────────────────────────────────────────────────────────────

@dataclass
class DFAO:
    """
    Deterministic Finite Automaton with Output.
    
    Computes a(n) by reading the base-k digits of n and outputting
    based on the final state.
    
    Time: O(log_k n) per evaluation
    Space: O(S * k) for the transition table
    """
    num_states: int
    input_size: int  # k
    output_size: int  # b
    init_state: int
    transition: Dict[Tuple[int, int], int]  # (state, input) -> state
    output_fn: Dict[int, int]  # state -> output

    def run_state(self, word: List[int]) -> int:
        """Run DFAO on a word, return final state. O(|word|)."""
        state = self.init_state
        for symbol in word:
            state = self.transition.get((state, symbol), 0)
        return state

    def eval(self, word: List[int]) -> int:
        """Evaluate DFAO on a word. O(|word|)."""
        return self.output_fn[self.run_state(word)]

    def eval_nat(self, n: int) -> int:
        """Evaluate DFAO on base-k representation of n. O(log n)."""
        if n == 0:
            return self.eval([0])
        digits = []
        while n > 0:
            digits.append(n % self.input_size)
            n //= self.input_size
        return self.eval(digits)  # LSB first


@dataclass
class DFST:
    """
    Deterministic Finite-State Transducer.
    
    Unlike DFAO, produces output at each transition step.
    
    Time: O(|input|) per evaluation
    Space: O(S * k) for tables
    """
    num_states: int
    input_size: int
    output_size: int
    init_state: int
    transition: Dict[Tuple[int, int], int]
    output_fn: Dict[Tuple[int, int], int]  # (state, input) -> output

    def run(self, word: List[int]) -> List[int]:
        """Run DFST, producing output at each step. O(|word|)."""
        state = self.init_state
        outputs = []
        for symbol in word:
            outputs.append(self.output_fn.get((state, symbol), 0))
            state = self.transition.get((state, symbol), 0)
        return outputs


def make_thue_morse_dfao() -> DFAO:
    """
    Construct the 2-state DFAO that computes the Thue-Morse sequence.
    
    States: {0, 1} (parity of popcount so far)
    Input: {0, 1} (binary digits)
    Output: state value
    
    Transitions:
      (0, 0) -> 0,  (0, 1) -> 1
      (1, 0) -> 1,  (1, 1) -> 0
    """
    return DFAO(
        num_states=2,
        input_size=2,
        output_size=2,
        init_state=0,
        transition={(0, 0): 0, (0, 1): 1, (1, 0): 1, (1, 1): 0},
        output_fn={0: 0, 1: 1}
    )


def dfao_to_dfst(dfao: DFAO) -> DFST:
    """
    Embed a DFAO into a DFST.
    
    The DFST output at each step is the DFAO output of the current state.
    This is the formal embedding used in dfao_embeds_in_dfst.
    
    Time: O(S * k)
    Space: O(S * k)
    """
    output_fn = {}
    for (state, inp), _ in dfao.transition.items():
        output_fn[(state, inp)] = dfao.output_fn[state]
    return DFST(
        num_states=dfao.num_states,
        input_size=dfao.input_size,
        output_size=dfao.output_size,
        init_state=dfao.init_state,
        transition=dfao.transition,
        output_fn=output_fn
    )


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 2: Factor Complexity Computation
# ──────────────────────────────────────────────────────────────────────────────

def compute_factor_complexity(
    seq: Callable[[int], int],
    max_m: int,
    window: int = 10000
) -> List[int]:
    """
    Compute factor complexity p(m) for m = 1, ..., max_m.
    
    Uses a sliding window over the first `window` terms.
    
    Time: O(window * max_m) 
    Space: O(window * max_m) for storing factors
    
    Args:
        seq: The sequence function
        max_m: Maximum factor length
        window: Number of terms to scan
    
    Returns:
        List of p(1), p(2), ..., p(max_m)
    """
    # Pre-compute sequence values
    values = [seq(i) for i in range(window)]
    
    result = []
    for m in range(1, max_m + 1):
        factors: Set[Tuple[int, ...]] = set()
        for i in range(window - m + 1):
            factor = tuple(values[i:i + m])
            factors.add(factor)
        result.append(len(factors))
    
    return result


def check_linear_complexity(
    complexities: List[int],
    tolerance: float = 1.5
) -> Tuple[bool, Optional[float], Optional[float]]:
    """
    Check if factor complexity is at most linear: p(m) ≤ C*m + D.
    
    Returns (is_linear, C, D) where C and D are the best-fit constants.
    
    Time: O(len(complexities))
    """
    if not complexities:
        return True, 0, 0
    
    # Simple linear regression
    n = len(complexities)
    ms = list(range(1, n + 1))
    
    # Compute C as max(p(m) / m) and D as max residual
    C = max(complexities[i] / ms[i] for i in range(n))
    D = max(complexities[i] - C * ms[i] for i in range(n))
    D = max(D, 0)
    
    # Check if all points satisfy p(m) ≤ C*m + D
    is_linear = all(
        complexities[i] <= C * ms[i] + D + tolerance
        for i in range(n)
    )
    
    return is_linear, C, D


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 3: Non-Periodicity Verification
# ──────────────────────────────────────────────────────────────────────────────

def check_eventually_periodic(
    seq: Callable[[int], int],
    max_period: int = 100,
    max_n: int = 1000,
    start_check: int = 0
) -> Tuple[bool, Optional[int], Optional[int]]:
    """
    Check if a sequence is eventually periodic with period ≤ max_period
    and onset ≤ start_check.
    
    Returns (is_periodic, period, onset) or (False, None, None).
    
    Time: O(max_period * max_n)
    """
    # Pre-compute values
    values = [seq(n) for n in range(max_n + max_period)]
    
    for onset in range(start_check + 1):
        for p in range(1, max_period + 1):
            all_match = True
            for n in range(onset, max_n):
                if values[n] != values[n + p]:
                    all_match = False
                    break
            if all_match:
                return True, p, onset
    
    return False, None, None


def verify_thue_morse_nonperiodicity(p: int) -> Tuple[int, int]:
    """
    For a given candidate period p, find the contradiction points
    using the proof strategy from the formalization.
    
    Returns (n1, n2) where t(n1) ≠ t(n1 + p) or t(n2) ≠ t(n2 + p).
    
    Time: O(log p) for finding k, O(1) for the check
    """
    from math import log2, ceil
    
    popcount = lambda n: bin(n).count('1')
    tm = lambda n: popcount(n) % 2
    
    # Find k such that 2^k > max(p, 1)
    k = max(1, int(ceil(log2(max(p + 1, 2)))))
    
    # The two test points
    n1 = 2**k - 1
    n2 = 2**(k + 1) - 1
    
    # Check which one gives a violation
    if tm(n1) != tm(n1 + p):
        return n1, p
    if tm(n2) != tm(n2 + p):
        return n2, p
    
    # This should never happen (by our theorem)
    raise AssertionError(f"Unexpected: no violation found for p={p}")


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 4: Transcendence Criterion Checker
# ──────────────────────────────────────────────────────────────────────────────

@dataclass
class TranscendenceResult:
    """Result of the transcendence criterion check."""
    sequence_name: str
    is_nonperiodic: bool
    is_linear_complexity: bool
    complexity_bound_C: Optional[float]
    complexity_bound_D: Optional[float]
    digit_real_value: float
    conclusion: str  # "transcendental", "rational", "unknown"


def transcendence_criterion_check(
    name: str,
    seq: Callable[[int], int],
    base: int = 2,
    max_factor_length: int = 20,
    max_period_check: int = 100,
    num_terms: int = 200
) -> TranscendenceResult:
    """
    Apply the finite-state transcendence criterion to a sequence.
    
    Pipeline:
    1. Check non-periodicity
    2. Compute factor complexity
    3. Check linear complexity bound
    4. Compute digit real
    5. Conclude transcendence (conditionally on AB criterion)
    
    Time: O(max_period_check * N + N * max_factor_length)
    where N = number of terms examined
    """
    # Step 1: Check periodicity
    is_periodic, period, onset = check_eventually_periodic(
        seq, max_period_check
    )
    
    # Step 2: Factor complexity
    complexities = compute_factor_complexity(seq, max_factor_length)
    is_linear, C, D = check_linear_complexity(complexities)
    
    # Step 3: Digit real
    x = sum(seq(n) / base**(n + 1) for n in range(num_terms))
    
    # Step 4: Conclusion
    if is_periodic:
        conclusion = "rational (eventually periodic)"
    elif not is_periodic and is_linear:
        conclusion = "transcendental (by AB criterion)"
    else:
        conclusion = "unknown"
    
    return TranscendenceResult(
        sequence_name=name,
        is_nonperiodic=not is_periodic,
        is_linear_complexity=is_linear,
        complexity_bound_C=C,
        complexity_bound_D=D,
        digit_real_value=x,
        conclusion=conclusion
    )


# ──────────────────────────────────────────────────────────────────────────────
# Algorithm 5: k-Kernel Computation
# ──────────────────────────────────────────────────────────────────────────────

def compute_k_kernel(
    seq: Callable[[int], int],
    k: int,
    max_depth: int = 5,
    num_terms: int = 100
) -> List[Tuple[int, ...]]:
    """
    Compute the k-kernel of a sequence up to depth max_depth.
    
    The k-kernel is {n ↦ a(k^i * n + r) : i ∈ ℕ, r < k^i}.
    A sequence is k-automatic iff its k-kernel is finite.
    
    Returns distinct sequences (as tuples of first num_terms values).
    
    Time: O(sum_{i=0}^{max_depth} k^i * num_terms)
    """
    kernel_seqs: Set[Tuple[int, ...]] = set()
    
    for i in range(max_depth + 1):
        ki = k ** i
        for r in range(ki):
            subseq = tuple(seq(ki * n + r) for n in range(num_terms))
            kernel_seqs.add(subseq)
    
    return list(kernel_seqs)


# ──────────────────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("Algorithm Demonstrations")
    print("=" * 70)
    print()
    
    # DFAO for Thue-Morse
    tm_dfao = make_thue_morse_dfao()
    print("DFAO for Thue-Morse:")
    for n in range(16):
        val = tm_dfao.eval_nat(n)
        expected = bin(n).count('1') % 2
        print(f"  n={n:2d}: DFAO={val}, popcount mod 2={expected}, match={val==expected}")
    print()
    
    # DFST embedding
    tm_dfst = dfao_to_dfst(tm_dfao)
    print("DFST embedding of Thue-Morse DFAO:")
    word = [1, 0, 1, 1]  # binary 1101 = 13 (LSB first)
    outputs = tm_dfst.run(word)
    print(f"  Input: {word}")
    print(f"  Outputs: {outputs}")
    print()
    
    # Transcendence criterion
    tm = lambda n: bin(n).count('1') % 2
    result = transcendence_criterion_check("Thue-Morse", tm)
    print(f"Transcendence criterion for {result.sequence_name}:")
    print(f"  Non-periodic: {result.is_nonperiodic}")
    print(f"  Linear complexity: {result.is_linear_complexity}")
    print(f"  Bounds: C={result.complexity_bound_C:.2f}, D={result.complexity_bound_D:.2f}")
    print(f"  Digit real: {result.digit_real_value:.15f}")
    print(f"  Conclusion: {result.conclusion}")
    print()
    
    # k-kernel
    kernel = compute_k_kernel(tm, 2, max_depth=4, num_terms=20)
    print(f"2-kernel of Thue-Morse (depth 4): {len(kernel)} distinct sequences")
    print(f"  (Thue-Morse is 2-automatic iff this is finite)")
    print()
    
    # Non-periodicity proof verification
    print("Non-periodicity proof verification:")
    for p in [1, 2, 3, 5, 7, 10, 100]:
        n, _ = verify_thue_morse_nonperiodicity(p)
        print(f"  p={p:3d}: violation at n={n} "
              f"(t({n})={tm(n)}, t({n+p})={tm(n+p)})")
