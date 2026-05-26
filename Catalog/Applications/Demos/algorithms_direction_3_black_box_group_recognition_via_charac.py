"""
Algorithms for Black-Box Group Recognition via Characteristic Polynomial Certificates.

This module implements the recognition pipeline:
1. Dimension recovery from characteristic polynomial degrees
2. Fingerprint construction from polynomial samples
3. Theoretical rate computation via the necklace formula
4. Score-based parameter identification
5. Certified recognition with tolerance bounds

All algorithms are derived from the formally verified theorems in
Catalog/Algebra/CharpolyRecognition.lean.
"""

from __future__ import annotations
import math
from dataclasses import dataclass, field
from typing import Optional, Tuple, List, Dict
from functools import lru_cache


# ---------------------------------------------------------------------------
# Möbius function and necklace counting
# ---------------------------------------------------------------------------

def mobius(n: int) -> int:
    """Compute the Möbius function μ(n).

    μ(n) = 1 if n is a product of an even number of distinct primes,
    μ(n) = -1 if n is a product of an odd number of distinct primes,
    μ(n) = 0 if n has a squared prime factor.

    >>> mobius(1)
    1
    >>> mobius(6)
    1
    >>> mobius(4)
    0
    """
    if n <= 0:
        return 0
    if n == 1:
        return 1
    factors = 0
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            temp //= d
            if temp % d == 0:
                return 0  # squared factor
            factors += 1
        d += 1
    if temp > 1:
        factors += 1
    return (-1) ** factors


def divisors(n: int) -> List[int]:
    """Return sorted list of positive divisors of n."""
    if n <= 0:
        return []
    divs = []
    for d in range(1, int(math.isqrt(n)) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)


@lru_cache(maxsize=1024)
def num_irreducible_monic(q: int, n: int) -> int:
    """Number of monic irreducible polynomials of degree n over GF(q).

    Uses the necklace formula:
        N(q, n) = (1/n) * sum_{d | n} μ(n/d) * q^d

    This is the function-field analogue of the prime counting function.

    >>> num_irreducible_monic(2, 1)
    2
    >>> num_irreducible_monic(2, 2)
    1
    >>> num_irreducible_monic(2, 3)
    2
    >>> num_irreducible_monic(2, 4)
    3
    >>> num_irreducible_monic(3, 2)
    3
    """
    if n <= 0 or q <= 0:
        return 0
    total = sum(mobius(n // d) * q**d for d in divisors(n))
    return total // n


def irreducible_rate(q: int, n: int) -> float:
    """Fraction of monic degree-n polynomials over GF(q) that are irreducible.

    Asymptotically ≈ 1/n + O(1/q).

    >>> abs(irreducible_rate(2, 2) - 0.25) < 0.01
    True
    """
    if q <= 0 or n <= 0:
        return 0.0
    return num_irreducible_monic(q, n) / q**n


def split_rate(q: int, n: int) -> float:
    """Fraction of monic degree-n polynomials over GF(q) that split completely.

    This equals q! / (q-n)! / q^n when n ≤ q (falling factorial / q^n),
    and 0 when n > q (not enough roots).

    >>> abs(split_rate(5, 2) - 0.2) < 0.01
    True
    """
    if q <= 0 or n <= 0:
        return 0.0
    if n > q:
        return 0.0
    # Falling factorial: q * (q-1) * ... * (q-n+1) / q^n
    result = 1.0
    for i in range(n):
        result *= (q - i) / q
    return result


# ---------------------------------------------------------------------------
# Fingerprint structures
# ---------------------------------------------------------------------------

@dataclass
class CharpolyFingerprint:
    """Empirical statistics from a sample of characteristic polynomials."""
    dim: int
    sample_size: int
    num_irreducible: int
    num_split: int
    num_squarefree: int

    @property
    def irred_rate(self) -> float:
        return self.num_irreducible / self.sample_size if self.sample_size > 0 else 0.0

    @property
    def split_rate_val(self) -> float:
        return self.num_split / self.sample_size if self.sample_size > 0 else 0.0


@dataclass
class TheoreticalFingerprint:
    """Theoretically predicted polynomial statistics for GL_n(F_q)."""
    dim: int
    field_size: int
    irred_rate: float
    split_rate_val: float

    @staticmethod
    def for_params(n: int, q: int) -> 'TheoreticalFingerprint':
        """Create theoretical fingerprint for given parameters."""
        return TheoreticalFingerprint(
            dim=n,
            field_size=q,
            irred_rate=irreducible_rate(q, n),
            split_rate_val=split_rate(q, n)
        )


# ---------------------------------------------------------------------------
# Recognition score and algorithm
# ---------------------------------------------------------------------------

def fingerprint_loss(fp: CharpolyFingerprint, tf: TheoreticalFingerprint) -> float:
    """Squared discrepancy between empirical and theoretical fingerprints.

    Loss = (irred_rate_emp - irred_rate_theo)^2 + (split_rate_emp - split_rate_theo)^2

    The true parameters uniquely minimize this loss (Theorem: true_params_unique_minimizer).
    """
    return (fp.irred_rate - tf.irred_rate)**2 + (fp.split_rate_val - tf.split_rate_val)**2


def recognition_score(fp: CharpolyFingerprint,
                      candidate_irred_rate: float,
                      candidate_split_rate: float) -> float:
    """Score comparing empirical fingerprint to candidate theoretical rates."""
    return (fp.irred_rate - candidate_irred_rate)**2 + \
           (fp.split_rate_val - candidate_split_rate)**2


def recover_dimension(degrees: List[int]) -> Optional[int]:
    """Recover the matrix dimension from characteristic polynomial degrees.

    Returns the common degree if all agree, None otherwise.
    Corresponds to the verified `recoverDimension` function.

    >>> recover_dimension([3, 3, 3, 3])
    3
    >>> recover_dimension([3, 3, 4, 3]) is None
    True
    >>> recover_dimension([]) is None
    True
    """
    if not degrees:
        return None
    d = degrees[0]
    if all(x == d for x in degrees):
        return d
    return None


def recognize_gl(fp: CharpolyFingerprint,
                 candidate_qs: List[int] = None,
                 tolerance: float = 0.01) -> Optional[Tuple[int, int]]:
    """Recognize GL_n(F_q) from a characteristic polynomial fingerprint.

    Algorithm:
    1. Dimension n is directly read from fp.dim
    2. For each candidate field size q, compute theoretical fingerprint
    3. Score each candidate
    4. Return the best match if its score is below tolerance

    Args:
        fp: Empirical fingerprint
        candidate_qs: List of candidate field sizes (default: primes and prime powers up to 100)
        tolerance: Maximum allowed score for a valid recognition

    Returns:
        (n, q) if recognized, None otherwise
    """
    if candidate_qs is None:
        candidate_qs = [2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19, 23, 25, 27,
                        29, 31, 32, 37, 41, 43, 47, 49, 53, 59, 61, 64, 67,
                        71, 73, 79, 81, 83, 89, 97]

    n = fp.dim
    best_q = None
    best_score = float('inf')

    for q in candidate_qs:
        tf = TheoreticalFingerprint.for_params(n, q)
        score = fingerprint_loss(fp, tf)
        if score < best_score:
            best_score = score
            best_q = q

    if best_score < tolerance and best_q is not None:
        return (n, best_q)
    return None


@dataclass
class RecognitionCertificate:
    """Certificate that a fingerprint identifies a unique (n, q) pair."""
    identified_dim: int
    identified_field_size: int
    tolerance: float
    loss_value: float
    second_best_loss: float
    separation_margin: float

    @property
    def is_certified(self) -> bool:
        return self.loss_value < self.tolerance and self.separation_margin > 0

    def __repr__(self):
        status = "CERTIFIED" if self.is_certified else "UNCERTIFIED"
        return (f"RecognitionCertificate({status}: "
                f"GL_{self.identified_dim}(F_{self.identified_field_size}), "
                f"loss={self.loss_value:.6f}, margin={self.separation_margin:.6f})")


def certified_recognize(fp: CharpolyFingerprint,
                        candidate_qs: List[int] = None,
                        tolerance: float = 0.01) -> RecognitionCertificate:
    """Certified recognition with explicit separation margin.

    Returns a RecognitionCertificate with:
    - The best-matching (n, q)
    - The loss at the best match
    - The separation margin to the second-best candidate
    """
    if candidate_qs is None:
        candidate_qs = [2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19, 23, 25]

    n = fp.dim
    scores = []
    for q in candidate_qs:
        tf = TheoreticalFingerprint.for_params(n, q)
        score = fingerprint_loss(fp, tf)
        scores.append((score, q))

    scores.sort()
    best_score, best_q = scores[0]
    second_score = scores[1][0] if len(scores) > 1 else float('inf')

    return RecognitionCertificate(
        identified_dim=n,
        identified_field_size=best_q,
        tolerance=tolerance,
        loss_value=best_score,
        second_best_loss=second_score,
        separation_margin=second_score - best_score
    )


# ---------------------------------------------------------------------------
# Theoretical rate tables
# ---------------------------------------------------------------------------

def rate_table(max_n: int = 6, qs: List[int] = None) -> Dict[Tuple[int,int], Dict[str,float]]:
    """Compute theoretical rate table for recognition.

    Returns dict mapping (n, q) -> {'irred': rate, 'split': rate, 'count': N(q,n)}.
    """
    if qs is None:
        qs = [2, 3, 5, 7, 11, 13]
    table = {}
    for n in range(1, max_n + 1):
        for q in qs:
            table[(n, q)] = {
                'irred': irreducible_rate(q, n),
                'split': split_rate(q, n),
                'count': num_irreducible_monic(q, n)
            }
    return table


def print_rate_table(max_n: int = 6, qs: List[int] = None):
    """Print a formatted rate table."""
    if qs is None:
        qs = [2, 3, 5, 7]
    print(f"{'n':>3} {'q':>3} {'N(q,n)':>10} {'irred_rate':>12} {'split_rate':>12}")
    print("-" * 50)
    for n in range(1, max_n + 1):
        for q in qs:
            ir = irreducible_rate(q, n)
            sr = split_rate(q, n)
            count = num_irreducible_monic(q, n)
            print(f"{n:>3} {q:>3} {count:>10} {ir:>12.6f} {sr:>12.6f}")


if __name__ == "__main__":
    import doctest
    doctest.testmod()
    print("=== Theoretical Rate Table ===")
    print_rate_table()
    print()
    print("=== Pairwise separation margins (irred rate) ===")
    for n in range(2, 7):
        rates = {q: irreducible_rate(q, n) for q in [2, 3, 5, 7]}
        qs = sorted(rates.keys())
        for i in range(len(qs)):
            for j in range(i+1, len(qs)):
                margin = abs(rates[qs[j]] - rates[qs[i]])
                print(f"  n={n}, q={qs[i]} vs q={qs[j]}: Δ(irred) = {margin:.6f}")
