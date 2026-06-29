#!/usr/bin/env python3
"""
Algorithms for Cellular Automata Zeta Rationality and Certificate Complexity

Implements the key algorithms from the research:
1. Periodic point counting via direct enumeration
2. Transfer matrix construction for spacetime block languages
3. Eventual period detection for iterate sequences
4. Certificate verification for spacetime blocks
5. Zeta function computation
"""

from itertools import product
from typing import Callable, List, Tuple, Optional, Dict
import numpy as np


# ─── Type aliases ────────────────────────────────────────────────────────────

Config = Tuple[int, ...]
LocalRule = Callable[[int, int, int], int]


# ─── Algorithm 1: Ring CA Simulation ─────────────────────────────────────────

def ring_ca_step(rule: LocalRule, config: Config, n: int) -> Config:
    """
    Apply one step of a 1D nearest-neighbor CA on a cyclic ring.
    
    Algorithm: For each position i, compute
        new[i] = rule(config[(i-1) mod n], config[i], config[(i+1) mod n])
    
    Time:  O(n) per step
    Space: O(n)
    
    Args:
        rule: Local transition function (left, center, right) -> new_center
        config: Current configuration as tuple of alphabet values
        n: Ring size (must equal len(config))
    
    Returns:
        New configuration after one CA step
    """
    return tuple(
        rule(config[(i - 1) % n], config[i], config[(i + 1) % n])
        for i in range(n)
    )


def ring_ca_iterate(rule: LocalRule, config: Config, n: int, steps: int) -> Config:
    """
    Iterate the CA rule multiple times.
    
    Time:  O(n * steps)
    Space: O(n)
    """
    c = config
    for _ in range(steps):
        c = ring_ca_step(rule, c, n)
    return c


# ─── Algorithm 2: Periodic Point Counting ───────────────────────────────────

def count_periodic_points(
    rule: LocalRule, n: int, alphabet: List[int], period: int
) -> int:
    """
    Count period-m points by exhaustive enumeration.
    
    Algorithm: Enumerate all |A|^n configurations, check T^m(x) = x.
    
    Time:  O(|A|^n * n * m)
    Space: O(n)
    
    PSEUDOCODE:
        count ← 0
        for each config x in A^n:
            y ← T^m(x)
            if y = x: count += 1
        return count
    """
    count = 0
    for config in product(alphabet, repeat=n):
        if ring_ca_iterate(rule, config, n, period) == config:
            count += 1
    return count


def periodic_point_sequence(
    rule: LocalRule, n: int, alphabet: List[int], max_period: int
) -> List[int]:
    """
    Compute the periodic point counting sequence |Fix(T^1)|, |Fix(T^2)|, ...
    
    Time:  O(max_period * |A|^n * n * max_period) = O(max_period^2 * |A|^n * n)
    Space: O(max_period)
    """
    return [
        count_periodic_points(rule, n, alphabet, m)
        for m in range(1, max_period + 1)
    ]


# ─── Algorithm 3: Eventual Period Detection ─────────────────────────────────

def detect_eventual_period(sequence: List[int]) -> Optional[Tuple[int, int]]:
    """
    Detect the eventual period of a sequence.
    
    Algorithm: For each candidate period d = 1, 2, ..., check if
    a[i+d] = a[i] holds for sufficiently many consecutive terms.
    
    Time:  O(n^2) where n = len(sequence)
    Space: O(1)
    
    PSEUDOCODE:
        for d = 1 to n/2:
            for start = 0 to n-d:
                if a[start..n-d] == a[start+d..n]:
                    return (start, d)
        return None
    
    Returns:
        (start_index, period) or None if no period detected
    """
    n = len(sequence)
    for d in range(1, n // 2 + 1):
        for start in range(n - d):
            matches = sum(
                1 for k in range(start, n - d)
                if sequence[k + d] == sequence[k]
            )
            if matches == n - d - start:
                return (start, d)
    return None


# ─── Algorithm 4: Transfer Matrix Construction ──────────────────────────────

def build_transfer_matrix(
    rule: LocalRule, alphabet: List[int], h: int
) -> np.ndarray:
    """
    Build the transfer matrix for the spacetime block language.
    
    A column of height h is a tuple in A^h. The transfer matrix M has
    M[i][j] = 1 if column j can follow column i in a valid spacetime strip.
    
    For height h=1 (single row), adjacent columns (a) and (b) are compatible
    iff there exists a value c such that b = rule(a_prev, a, c) for appropriate
    context. For the general case, we check column-by-column consistency.
    
    This simplified version works for h=1 with periodic (ring) boundary.
    
    Time:  O(|A|^(2h) * h)  — enumerate all pairs of columns
    Space: O(|A|^(2h))      — the transfer matrix
    
    Args:
        rule: Local transition function
        alphabet: List of alphabet values
        h: Height of spacetime strips
    
    Returns:
        Transfer matrix as numpy array
    """
    columns = list(product(alphabet, repeat=h))
    nc = len(columns)
    M = np.zeros((nc, nc), dtype=int)
    
    for i, col_a in enumerate(columns):
        for j, col_b in enumerate(columns):
            # Check if col_b can follow col_a:
            # For each row t, we need consistency with the CA rule
            # This is a simplified version for demonstration
            compatible = True
            for t in range(h - 1):
                # In a strip, row t+1 value at position p+1 should be
                # rule(row_t[p], row_t[p+1], row_t[p+2])
                # With columns, col_a[t] is row t at position p,
                # col_b[t] is row t at position p+1
                # We need col_b[t+1] to be achievable by some rule application
                pass  # Full check requires 3-column context
            M[i][j] = 1  # Conservative: allow all for demonstration
    
    return M


# ─── Algorithm 5: Zeta Function Computation ─────────────────────────────────

def compute_zeta_coefficients(
    rule: LocalRule, n: int, alphabet: List[int], max_terms: int
) -> List[float]:
    """
    Compute coefficients of the Artin-Mazur zeta function.
    
    ζ_T(z) = exp(Σ_{m≥1} |Fix(T^m)| z^m / m)
    
    The coefficients of the zeta function are computed from the periodic
    point counts via the exponential formula.
    
    Time:  O(max_terms^2 * |A|^n * n)
    Space: O(max_terms)
    
    PSEUDOCODE:
        fix_counts ← [|Fix(T^m)| for m = 1..N]
        log_coeffs ← [fix_counts[m] / m for m = 1..N]
        zeta_coeffs ← exp_series(log_coeffs)
        return zeta_coeffs
    """
    fix_counts = periodic_point_sequence(rule, n, alphabet, max_terms)
    
    # Compute log(ζ) coefficients: a_m / m
    log_coeffs = [fix_counts[m] / (m + 1) for m in range(max_terms)]
    
    # Exponentiate the power series: ζ = exp(Σ a_m z^m / m)
    # Using the formula: if log(ζ) = Σ b_m z^m, then
    # ζ_n = (1/n) Σ_{k=1}^{n} k * b_k * ζ_{n-k}
    zeta = [0.0] * (max_terms + 1)
    zeta[0] = 1.0  # constant term
    for nn in range(1, max_terms + 1):
        s = 0.0
        for k in range(1, nn + 1):
            if k <= len(log_coeffs):
                s += k * log_coeffs[k - 1] * zeta[nn - k]
        zeta[nn] = s / nn
    
    return zeta[1:]  # exclude constant term


# ─── Algorithm 6: Certificate Verification ──────────────────────────────────

def verify_spacetime_certificate(
    rule: LocalRule,
    block: List[Config],
    n: int
) -> bool:
    """
    Verify that a spacetime block is a valid CA evolution.
    
    The certificate is the initial row. Given the initial row, we reconstruct
    the entire block by forward simulation and check consistency.
    
    Time:  O(n * h) where h = len(block)
    Space: O(n)
    
    PSEUDOCODE:
        current ← block[0]  (the certificate)
        for t = 1 to h-1:
            next ← apply_rule(current)
            if next ≠ block[t]: return False
            current ← next
        return True
    """
    if not block:
        return True
    
    current = block[0]
    for t in range(1, len(block)):
        expected = ring_ca_step(rule, current, n)
        if expected != block[t]:
            return False
        current = expected
    return True


def certificate_size(w: int, h: int) -> Dict[str, int]:
    """
    Compute certificate sizes for different certification strategies.
    
    Returns dict with:
        - 'initial_row': w (just the first row)
        - 'boundary': w + 2*h (first row + boundary columns)
        - 'full_block': w * h (no compression)
        - 'compression_ratio': w*h / (w + 2*h)
    """
    full = w * h
    boundary = w + 2 * h
    return {
        'initial_row': w,
        'boundary': boundary,
        'full_block': full,
        'compression_ratio': full / max(boundary, 1),
    }


# ─── Algorithm 7: Iterate Period Finder ──────────────────────────────────────

def find_iterate_period(
    rule: LocalRule, n: int, alphabet: List[int]
) -> Tuple[int, int]:
    """
    Find the eventual period of the iterate sequence T, T^2, T^3, ...
    
    Algorithm: Represent each iterate as its action table (a function
    from configs to configs), and detect when two iterates coincide.
    Uses Floyd's cycle detection or direct hashing.
    
    Time:  O(|A|^n * period * n)  — proportional to the period
    Space: O(|A|^n * seen_iterates)
    
    PSEUDOCODE:
        all_configs ← enumerate A^n
        seen ← {}
        for m = 0, 1, 2, ...:
            action ← [T^m(x) for x in all_configs]
            if action in seen:
                return (seen[action], m - seen[action])
            seen[action] ← m
    
    Returns:
        (preperiod, period) — T^[m+period] = T^[m] for all m ≥ preperiod
    """
    all_configs = list(product(alphabet, repeat=n))
    seen: Dict[Tuple, int] = {}
    
    for m in range(len(all_configs) ** len(all_configs) + 1):
        action = tuple(
            ring_ca_iterate(rule, c, n, m) for c in all_configs
        )
        if action in seen:
            return (seen[action], m - seen[action])
        seen[action] = m
    
    raise RuntimeError("Period not found within expected bound")


# ─── Example usage ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Define Rule 90
    def rule90(l, c, r): return (l + r) % 2
    
    alphabet = [0, 1]
    n = 4
    
    print("=== Periodic Point Sequence ===")
    seq = periodic_point_sequence(rule90, n, alphabet, 12)
    for m, c in enumerate(seq, 1):
        print(f"  |Fix(T^{m:2d})| = {c}")
    
    print("\n=== Eventual Period Detection ===")
    result = detect_eventual_period(seq)
    if result:
        print(f"  Period d={result[1]} from index {result[0]}")
    
    print("\n=== Zeta Coefficients ===")
    zeta = compute_zeta_coefficients(rule90, n, alphabet, 8)
    for m, c in enumerate(zeta, 1):
        print(f"  ζ_{m} = {c:.4f}")
    
    print("\n=== Certificate Sizes ===")
    for w, h in [(10, 5), (20, 10), (50, 20), (100, 50)]:
        sizes = certificate_size(w, h)
        print(f"  {w}×{h}: cert={sizes['boundary']}, "
              f"full={sizes['full_block']}, "
              f"compression={sizes['compression_ratio']:.1f}x")
    
    print("\n=== Iterate Period ===")
    pre, per = find_iterate_period(rule90, 3, alphabet)
    print(f"  Rule 90 on ring size 3: preperiod={pre}, period={per}")
