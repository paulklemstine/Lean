"""
Gap Automaton Spectral Theory — Core Algorithms

Type-hinted implementations of the gap automaton transfer matrix construction,
walk counting via matrix powers, and spectral analysis.
"""

from typing import List, Set, Tuple, Dict
import numpy as np
from numpy.typing import NDArray


def primorial(primes: List[int]) -> int:
    """Compute the primorial: product of given primes."""
    result = 1
    for p in primes:
        result *= p
    return result


def admissible_residues(modulus: int, sieve_primes: List[int]) -> List[int]:
    """Find residue classes mod `modulus` coprime to all sieve primes."""
    return [r for r in range(modulus) if all(r % p != 0 for p in sieve_primes)]


def gap_transfer_matrix(
    modulus: int,
    admissible: Set[int],
    alphabet: List[int],
) -> NDArray[np.float64]:
    """
    Construct the transfer matrix for a gap automaton.

    Args:
        modulus: The modulus (typically a primorial).
        admissible: Set of admissible residue classes.
        alphabet: List of allowed gap values.

    Returns:
        modulus × modulus transfer matrix where T[s][t] counts gaps
        from s to t, masked to zero for forbidden states.
    """
    T = np.zeros((modulus, modulus), dtype=np.float64)
    for s in range(modulus):
        if s not in admissible:
            continue
        for g in alphabet:
            t = (s + g) % modulus
            if t in admissible:
                T[s][t] += 1.0
    return T


def walk_count_matrix(T: NDArray[np.float64], k: int) -> NDArray[np.float64]:
    """
    Compute walk counts of length k via matrix power.

    By the Walk-Matrix Correspondence theorem, (T^k)[s][t] equals
    the number of walks of length k from s to t.
    """
    return np.linalg.matrix_power(T, k)


def spectral_analysis(T: NDArray[np.float64]) -> Dict[str, float]:
    """
    Compute spectral properties of the transfer matrix.

    Returns:
        Dictionary with spectral_radius, second_eigenvalue,
        spectral_gap, and topological_entropy.
    """
    eigenvalues = np.linalg.eigvals(T)
    sorted_eigs = sorted(np.abs(eigenvalues), reverse=True)

    rho = sorted_eigs[0]
    second = sorted_eigs[1] if len(sorted_eigs) > 1 else 0.0

    return {
        "spectral_radius": rho,
        "second_eigenvalue_abs": second,
        "spectral_gap": rho - second,
        "topological_entropy": np.log(rho) if rho > 0 else float("-inf"),
        "eigenvalues": sorted(eigenvalues.real, reverse=True),
    }


def word_growth(T: NDArray[np.float64], max_k: int) -> List[int]:
    """
    Compute the word growth function W(k) = sum of entries of T^k.

    Returns:
        List of W(0), W(1), ..., W(max_k).
    """
    d = T.shape[0]
    growth = []
    Tk = np.eye(d, dtype=np.float64)
    for k in range(max_k + 1):
        growth.append(int(round(np.sum(Tk))))
        Tk = Tk @ T
    return growth


def diagonal_lower_bound(T: NDArray[np.float64], k: int) -> float:
    """
    Compute the self-loop growth lower bound: max_i T[i][i]^k.

    By Theorem 5.1 (diagonal_pow_lower_bound), (T^k)[i][i] >= T[i][i]^k.
    """
    max_diag = np.max(np.diag(T))
    return max_diag ** k


def build_sieve_automaton(
    sieve_primes: List[int], max_gap: int
) -> Tuple[int, Set[int], List[int], NDArray[np.float64]]:
    """
    Build a complete gap automaton for a given sieve.

    Args:
        sieve_primes: List of primes to sieve by (e.g., [2, 3]).
        max_gap: Maximum gap value in the alphabet.

    Returns:
        Tuple of (modulus, admissible_set, alphabet, transfer_matrix).
    """
    mod = primorial(sieve_primes)
    adm = set(admissible_residues(mod, sieve_primes))
    alpha = list(range(2, max_gap + 1, 2))  # even gaps
    T = gap_transfer_matrix(mod, adm, alpha)
    return mod, adm, alpha, T


if __name__ == "__main__":
    # Quick test
    mod, adm, alpha, T = build_sieve_automaton([2, 3], 10)
    print(f"Sieve {{2,3}}, modulus {mod}")
    print(f"Admissible residues: {sorted(adm)}")
    print(f"Alphabet: {alpha}")
    print(f"Transfer matrix (admissible block):")
    adm_list = sorted(adm)
    for s in adm_list:
        row = [T[s][t] for t in adm_list]
        print(f"  state {s}: {row}")
    spec = spectral_analysis(T)
    print(f"Spectral radius: {spec['spectral_radius']:.4f}")
    print(f"Spectral gap: {spec['spectral_gap']:.4f}")
    print(f"Entropy: {spec['topological_entropy']:.4f}")
