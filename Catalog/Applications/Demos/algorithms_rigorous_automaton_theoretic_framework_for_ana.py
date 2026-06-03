"""
Gap Automaton: Algorithms for prime gap analysis via modular sieves.

This module implements the core algorithms of the gap automaton framework,
which models prime gap patterns as transitions in a finite-state machine
whose states are residue classes modulo a primorial.
"""
from typing import List, Set, Tuple, Dict, Optional
import numpy as np
from math import gcd
from functools import reduce


def primorial(primes: List[int]) -> int:
    """Compute the product of a list of primes (the primorial)."""
    return reduce(lambda a, b: a * b, primes, 1)


def sieve_forbidden(primes: List[int]) -> Set[int]:
    """
    Compute the set of forbidden residues modulo the primorial.
    A residue r is forbidden if gcd(r, primorial) > 1, i.e.,
    r is divisible by at least one prime in the sieve.

    Args:
        primes: List of sieve primes, e.g. [2, 3, 5]

    Returns:
        Set of forbidden residue classes mod primorial(primes)
    """
    m = primorial(primes)
    return {r for r in range(m) if gcd(r, m) > 1}


def admissible_states(primes: List[int]) -> Set[int]:
    """
    Compute the set of admissible residues (coprime to the primorial).
    These correspond to positions that could potentially be prime.
    """
    m = primorial(primes)
    forbidden = sieve_forbidden(primes)
    return set(range(m)) - forbidden


def step(state: int, gap: int, modulus: int) -> int:
    """Transition function: (state + gap) mod modulus."""
    return (state + gap) % modulus


def admissible_successors(
    state: int, alphabet: List[int], modulus: int, forbidden: Set[int]
) -> List[int]:
    """
    Find all gaps in the alphabet that lead from `state` to an admissible state.

    Args:
        state: Current residue class
        alphabet: List of possible gap values
        modulus: The primorial modulus
        forbidden: Set of forbidden residue classes

    Returns:
        List of gap values leading to admissible states
    """
    return [g for g in alphabet if step(state, g, modulus) not in forbidden]


def is_forcing(
    state: int, alphabet: List[int], modulus: int, forbidden: Set[int]
) -> Optional[int]:
    """
    Check if state `state` is a forcing state: exactly one gap in the alphabet
    leads to an admissible state.

    Returns:
        The forced gap value, or None if not forcing.
    """
    succs = admissible_successors(state, alphabet, modulus, forbidden)
    if len(succs) == 1:
        return succs[0]
    return None


def build_transition_matrix(
    primes: List[int], alphabet: List[int]
) -> Tuple[np.ndarray, List[int]]:
    """
    Build the transition matrix T restricted to admissible states.
    T[i,j] = number of gaps g in alphabet such that step(s_i, g) = s_j.

    Args:
        primes: Sieve primes
        alphabet: Gap alphabet (e.g., [2, 4, 6, ...])

    Returns:
        (T, states) where T is the transition matrix and states is the
        list of admissible states in sorted order.
    """
    m = primorial(primes)
    forbidden = sieve_forbidden(primes)
    states = sorted(admissible_states(primes))
    n = len(states)
    state_idx = {s: i for i, s in enumerate(states)}

    T = np.zeros((n, n), dtype=float)
    for i, s in enumerate(states):
        for g in alphabet:
            t = step(s, g, m)
            if t in state_idx:
                T[i, state_idx[t]] += 1

    return T, states


def spectral_gap(T: np.ndarray) -> float:
    """
    Compute the spectral gap of transition matrix T.
    The spectral gap is λ₁ - |λ₂| where eigenvalues are sorted
    by absolute value.

    Args:
        T: Square transition matrix

    Returns:
        The spectral gap (difference between largest and second-largest
        eigenvalue magnitudes).
    """
    eigenvalues = np.linalg.eigvals(T)
    mags = sorted(np.abs(eigenvalues), reverse=True)
    if len(mags) < 2:
        return 0.0
    return float(mags[0] - mags[1])


def analyze_forcing_density(
    primes: List[int], max_gap: int
) -> Dict[str, float]:
    """
    Analyze what fraction of admissible states are forcing states
    for a given sieve and gap alphabet [2, 4, ..., max_gap].

    Args:
        primes: Sieve primes
        max_gap: Maximum gap value (must be even)

    Returns:
        Dictionary with analysis results including forcing density,
        number of forcing states, and total admissible states.
    """
    m = primorial(primes)
    forbidden = sieve_forbidden(primes)
    states = admissible_states(primes)
    alphabet = list(range(2, max_gap + 1, 2))

    forcing_count = 0
    forcing_states = []
    for s in sorted(states):
        forced = is_forcing(s, alphabet, m, forbidden)
        if forced is not None:
            forcing_count += 1
            forcing_states.append((s, forced))

    return {
        "modulus": m,
        "num_admissible": len(states),
        "num_forcing": forcing_count,
        "forcing_density": forcing_count / len(states) if states else 0,
        "forcing_states": forcing_states,
        "alphabet_size": len(alphabet),
    }


def spectral_gap_scaling(max_sieve_depth: int = 5) -> List[Dict]:
    """
    Compute the spectral gap for sieves of increasing depth and
    analyze the scaling behavior.

    Args:
        max_sieve_depth: Number of primes to include (2, 3, 5, 7, 11, ...)

    Returns:
        List of dictionaries with sieve info and spectral gap data.
    """
    all_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23]
    results = []

    for k in range(1, min(max_sieve_depth + 1, len(all_primes) + 1)):
        primes = all_primes[:k]
        m = primorial(primes)
        # Use even gaps up to 2*m as alphabet
        max_gap = min(2 * m, 100)
        alphabet = list(range(2, max_gap + 1, 2))

        T, states = build_transition_matrix(primes, alphabet)
        gap = spectral_gap(T)

        results.append({
            "primes": primes,
            "primorial": m,
            "log_primorial": float(np.log(m)),
            "num_admissible": len(states),
            "spectral_gap": gap,
            "gap_over_log": gap / np.log(m) if np.log(m) > 0 else float('inf'),
        })

    return results
