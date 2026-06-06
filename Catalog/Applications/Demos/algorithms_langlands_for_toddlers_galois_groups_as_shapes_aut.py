#!/usr/bin/env python3
"""
Algorithms for the Spectral Pairing Framework

Implements the core algorithms for computing and analyzing the
shape-color dictionary of the GL₁ Langlands correspondence.
"""

from typing import Callable


def jacobi_symbol(a: int, n: int) -> int:
    """
    Compute the Jacobi symbol (a/n).

    The Jacobi symbol generalizes the Legendre symbol to composite odd moduli.
    It is the canonical "evaluation map" of the spectral pairing.

    Args:
        a: Integer (the "shape")
        n: Positive odd integer (the "color basis element")

    Returns:
        -1, 0, or 1
    """
    if n <= 0 or n % 2 == 0:
        raise ValueError(f"n must be odd and positive, got {n}")
    a = a % n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a = a % n
    return result if n == 1 else 0


def qr_sign(a: int, b: int) -> int:
    """
    Compute the quadratic reciprocity sign (-1)^((a//2)*(b//2)).

    This is the "asymmetry defect" of the spectral pairing: it measures
    how much the Jacobi symbol changes when we swap its arguments.

    Args:
        a, b: Natural numbers

    Returns:
        1 or -1
    """
    return (-1) ** ((a // 2) * (b // 2))


def splitting_matrix(
    discriminants: list[int],
    primes: list[int]
) -> list[list[int]]:
    """
    Compute the splitting matrix M[i,j] = J(d_i, p_j).

    The splitting matrix is the finite fragment of the GL₁ Langlands
    correspondence. Each row is the "color" (Dirichlet character)
    assigned to a "shape" (discriminant).

    Args:
        discriminants: List of discriminants (shapes)
        primes: List of odd primes (color basis)

    Returns:
        Matrix of Jacobi symbol values
    """
    return [[jacobi_symbol(d, p) for p in primes] for d in discriminants]


def spectrum_of(d: int, primes: list[int]) -> list[int]:
    """
    Compute the splitting spectrum of discriminant d.

    The spectrum S_d is the function p ↦ J(d, p). It is the
    "color" assigned to the "shape" d by the Langlands dictionary.

    Args:
        d: Discriminant
        primes: List of primes to evaluate at

    Returns:
        List of J(d, p) values
    """
    return [jacobi_symbol(d, p) for p in primes]


def spectrum_inner_product(
    d1: int,
    d2: int,
    primes: list[int]
) -> int:
    """
    Compute the inner product of two spectra: ∑_p J(d₁,p)·J(d₂,p).

    By the spectrum product rule, this equals ∑_p J(d₁d₂, p).
    When d₁ = d₂, this counts the number of primes where d is a QR
    minus the number where it's a QNR.

    Args:
        d1, d2: Discriminants
        primes: List of primes

    Returns:
        Integer inner product
    """
    return sum(jacobi_symbol(d1, p) * jacobi_symbol(d2, p) for p in primes)


def is_spectrally_orthogonal(
    d1: int,
    d2: int,
    primes: list[int],
    threshold: float = 0.1
) -> bool:
    """
    Test whether two spectra are approximately orthogonal.

    Two distinct squarefree discriminants have spectra that are
    asymptotically orthogonal by the equidistribution theorem.

    Args:
        d1, d2: Discriminants
        primes: List of primes
        threshold: Relative threshold for orthogonality

    Returns:
        True if the normalized inner product is below threshold
    """
    if not primes:
        return True
    ip = spectrum_inner_product(d1, d2, primes)
    return abs(ip) / len(primes) < threshold


def frobenius_classify(p: int) -> dict[str, int]:
    """
    Classify a prime by its Frobenius data for fundamental shapes.

    Returns a dictionary mapping shape names to their splitting behavior.

    Args:
        p: An odd prime

    Returns:
        Dictionary with keys '-1', '2', '-3', '5' and values ±1
    """
    return {
        '-1': jacobi_symbol(-1, p),
        '2': jacobi_symbol(2, p),
        '-3': jacobi_symbol(-3, p),
        '5': jacobi_symbol(5, p),
    }


def reciprocity_verify(
    primes: list[int]
) -> list[tuple[int, int, bool]]:
    """
    Verify quadratic reciprocity for all pairs from a list of odd primes.

    For each pair (p, q), checks that J(p,q)·J(q,p) = qrSign(p,q).

    Args:
        primes: List of odd primes

    Returns:
        List of (p, q, success) triples
    """
    results = []
    for i, p in enumerate(primes):
        for q in primes[i+1:]:
            product = jacobi_symbol(p, q) * jacobi_symbol(q, p)
            expected = qr_sign(p, q)
            results.append((p, q, product == expected))
    return results


def character_sum(d: int, p: int) -> int:
    """
    Compute the character sum ∑_{a=0}^{p-1} J(d, p) evaluated at a.

    For prime p not dividing d, this equals ∑ Legendre(a·d, p) = 0.
    The sum ∑_{a=0}^{p-1} J(a, p) = 0 by character orthogonality.

    Args:
        d: Discriminant (unused in the basic sum)
        p: Odd prime

    Returns:
        Sum of J(a, p) for a = 0, ..., p-1
    """
    return sum(jacobi_symbol(a, p) for a in range(p))


def spectral_pairing_table(max_d: int = 20, num_primes: int = 10) -> str:
    """
    Generate a formatted table of the spectral pairing.

    Args:
        max_d: Maximum absolute discriminant
        num_primes: Number of primes to include

    Returns:
        Formatted string table
    """
    # Generate squarefree discriminants
    def is_squarefree(n: int) -> bool:
        n = abs(n)
        if n == 0:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % (i * i) == 0:
                return False
        return True

    discriminants = sorted(
        [d for d in range(-max_d, max_d + 1) if is_squarefree(d) and d != 0 and d != 1],
        key=abs
    )

    # Generate primes
    def sieve(n: int) -> list[int]:
        if n < 2:
            return []
        is_prime = [True] * (n + 1)
        is_prime[0] = is_prime[1] = False
        for i in range(2, int(n**0.5) + 1):
            if is_prime[i]:
                for j in range(i*i, n + 1, i):
                    is_prime[j] = False
        return [i for i in range(3, n + 1) if is_prime[i] and i % 2 == 1]

    primes = sieve(100)[:num_primes]

    lines = []
    header = f"{'d':>4} | " + " ".join(f"{p:>3}" for p in primes)
    lines.append(header)
    lines.append("-" * len(header))
    for d in discriminants[:20]:  # Limit rows
        vals = " ".join(f"{jacobi_symbol(d, p):>3}" for p in primes)
        lines.append(f"{d:>4} | {vals}")

    return "\n".join(lines)


if __name__ == "__main__":
    print("=== Spectral Pairing Table ===")
    print(spectral_pairing_table())

    print("\n=== Reciprocity Verification ===")
    primes = [3, 5, 7, 11, 13]
    results = reciprocity_verify(primes)
    for p, q, ok in results:
        print(f"  ({p}, {q}): {'✓' if ok else '✗'}")

    print("\n=== Frobenius Classification ===")
    for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
        data = frobenius_classify(p)
        print(f"  p={p:>2}: {data}")
