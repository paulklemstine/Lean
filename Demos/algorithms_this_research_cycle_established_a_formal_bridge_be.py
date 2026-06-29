"""
Algorithms for Log-Concavity Analysis and the Lorentzian Bridge

Implements the key algorithms from the research:
1. K-fold log-concavity depth computation
2. Hadamard product with depth tracking
3. Geometric tilting
4. Log-concavity signature composition
"""

from typing import List, Optional, Tuple
import math


def is_positive(seq: List[float]) -> bool:
    """Check if all terms in a sequence are strictly positive."""
    return all(x > 0 for x in seq)


def is_log_concave(seq: List[float]) -> bool:
    """Check if a sequence satisfies a(n+1)^2 >= a(n)*a(n+2) for all valid n."""
    if len(seq) < 3:
        return True
    return all(
        seq[n + 1] ** 2 >= seq[n] * seq[n + 2] - 1e-12
        for n in range(len(seq) - 2)
    )


def ratio_sequence(seq: List[float]) -> List[float]:
    """Compute the ratio sequence r(n) = a(n+1)/a(n).
    
    Args:
        seq: A positive sequence (all terms > 0).
        
    Returns:
        The ratio sequence, which has length len(seq) - 1.
    """
    if len(seq) < 2:
        return []
    return [seq[n + 1] / seq[n] for n in range(len(seq) - 1)]


def kfold_log_concavity_depth(seq: List[float], max_depth: int = 100) -> int:
    """Compute the k-fold log-concavity depth of a sequence.
    
    The depth is the maximum k such that the sequence is k-fold log-concave:
    - Depth 0: the sequence is positive
    - Depth k+1: positive, log-concave, and ratio sequence has depth >= k
    
    Args:
        seq: Input sequence.
        max_depth: Maximum depth to check (returns this if depth appears infinite).
        
    Returns:
        The k-fold log-concavity depth (0 if not positive, max_depth if ≥ max_depth).
    """
    if not is_positive(seq):
        return -1  # Not even positive
    
    current = seq[:]
    for k in range(max_depth):
        if len(current) < 3:
            return max_depth  # Too short to fail LC
        if not is_log_concave(current):
            return k
        current = ratio_sequence(current)
        if not is_positive(current):
            return k
    return max_depth


def hadamard_product(a: List[float], b: List[float]) -> List[float]:
    """Compute the Hadamard (entrywise) product of two sequences.
    
    Args:
        a, b: Input sequences of the same length.
        
    Returns:
        The pointwise product [a[0]*b[0], a[1]*b[1], ...].
    """
    n = min(len(a), len(b))
    return [a[i] * b[i] for i in range(n)]


def geometric_tilt(seq: List[float], r: float) -> List[float]:
    """Apply geometric tilting: a(n) -> a(n) * r^n.
    
    Args:
        seq: Input sequence.
        r: Tilt parameter (must be > 0).
        
    Returns:
        The tilted sequence.
    """
    return [seq[n] * r ** n for n in range(len(seq))]


def binomial_coefficients(d: int) -> List[float]:
    """Compute binomial coefficients C(d, 0), C(d, 1), ..., C(d, d)."""
    return [float(math.comb(d, k)) for k in range(d + 1)]


def convolution(a: List[float], b: List[float]) -> List[float]:
    """Compute the discrete convolution (Cauchy product) of two sequences.
    
    c(n) = sum_{i=0}^{n} a(i) * b(n-i)
    
    Args:
        a, b: Input sequences.
        
    Returns:
        The convolution, of length len(a) + len(b) - 1.
    """
    n = len(a) + len(b) - 1
    result = [0.0] * n
    for i in range(len(a)):
        for j in range(len(b)):
            result[i + j] += a[i] * b[j]
    return result


class LogConcavitySignature:
    """A sequence bundled with its certified log-concavity depth.
    
    Corresponds to the Lean structure LogConcavitySignature.
    """
    
    def __init__(self, seq: List[float], depth: Optional[int] = None):
        """Initialize a signature.
        
        Args:
            seq: The coefficient sequence (must be positive).
            depth: The certified depth (computed if not provided).
        """
        self.seq = seq[:]
        if depth is not None:
            self.depth = depth
        else:
            self.depth = kfold_log_concavity_depth(seq)
    
    def product(self, other: 'LogConcavitySignature') -> 'LogConcavitySignature':
        """Hadamard product of two signatures.
        
        By the Hadamard stability theorem, the depth of the product is
        at least min(self.depth, other.depth).
        """
        prod = hadamard_product(self.seq, other.seq)
        certified = min(self.depth, other.depth)
        # The actual depth may be higher
        actual = kfold_log_concavity_depth(prod)
        return LogConcavitySignature(prod, max(certified, actual))
    
    def tilt(self, r: float) -> 'LogConcavitySignature':
        """Geometric tilting preserves the depth."""
        tilted = geometric_tilt(self.seq, r)
        return LogConcavitySignature(tilted, self.depth)
    
    def __repr__(self) -> str:
        return f"Sig(seq={self.seq[:5]}{'...' if len(self.seq)>5 else ''}, depth={self.depth})"


def depth_additivity_test(a: List[float], b: List[float]) -> Tuple[int, int, int, bool]:
    """Test the depth additivity conjecture for two sequences.
    
    Returns:
        (depth_a, depth_b, depth_product, is_additive)
        where is_additive checks if depth(a*b) >= depth(a) + depth(b).
    """
    da = kfold_log_concavity_depth(a)
    db = kfold_log_concavity_depth(b)
    prod = hadamard_product(a, b)
    dp = kfold_log_concavity_depth(prod)
    return (da, db, dp, dp >= da + db)
