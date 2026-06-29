"""
Algorithms for discriminant uniformity and splitting type analysis
over finite fields F_p.
"""

from typing import Literal, Dict, List, Tuple


SplittingType = Literal["split", "ramified", "inert"]


def euler_criterion(a: int, p: int) -> int:
    """Compute the Legendre symbol (a/p) via Euler's criterion.
    
    Returns:
        1 if a is a nonzero quadratic residue mod p,
        -1 if a is a quadratic non-residue mod p,
        0 if a ≡ 0 mod p.
    """
    a = a % p
    if a == 0:
        return 0
    result = pow(a, (p - 1) // 2, p)
    return 1 if result == 1 else -1


def classify_quadratic(p: int, b: int, c: int) -> SplittingType:
    """Classify the monic quadratic x² + bx + c over F_p.
    
    Args:
        p: An odd prime.
        b: Coefficient of x.
        c: Constant term.
    
    Returns:
        The splitting type: 'split', 'ramified', or 'inert'.
    """
    disc = (b * b - 4 * c) % p
    if disc == 0:
        return "ramified"
    legendre = euler_criterion(disc, p)
    return "split" if legendre == 1 else "inert"


def enumerate_fiber(p: int, d: int) -> List[Tuple[int, int]]:
    """Enumerate all (b, c) pairs with b² - 4c ≡ d (mod p).
    
    Uses the parametrization b ↦ (b, (b² - d) / 4 mod p).
    
    Args:
        p: An odd prime.
        d: Target discriminant value.
    
    Returns:
        List of (b, c) pairs in the fiber over d.
    """
    inv4 = pow(4, p - 2, p)  # Fermat's little theorem
    fiber = []
    for b in range(p):
        c = ((b * b - d) * inv4) % p
        fiber.append((b, c))
    return fiber


def compute_fiber_sizes(p: int) -> Dict[int, int]:
    """Compute the fiber size for every discriminant value d ∈ F_p.
    
    Args:
        p: An odd prime.
    
    Returns:
        Dictionary mapping d to |{(b,c) : b² - 4c ≡ d}|.
    """
    sizes: Dict[int, int] = {d: 0 for d in range(p)}
    for b in range(p):
        for c in range(p):
            d = (b * b - 4 * c) % p
            sizes[d] += 1
    return sizes


def splitting_type_counts(p: int) -> Dict[SplittingType, int]:
    """Count quadratics of each splitting type over F_p.
    
    Args:
        p: An odd prime.
    
    Returns:
        Dictionary with counts for 'split', 'ramified', 'inert'.
    """
    counts: Dict[SplittingType, int] = {"split": 0, "ramified": 0, "inert": 0}
    for b in range(p):
        for c in range(p):
            st = classify_quadratic(p, b, c)
            counts[st] += 1
    return counts


def discriminant_profile(p: int) -> Dict[str, object]:
    """Compute the full discriminant profile for monic quadratics over F_p.
    
    Args:
        p: An odd prime.
    
    Returns:
        Dictionary with numSplit, numRamified, numInert, total,
        splitFraction, and theoretical predictions.
    """
    counts = splitting_type_counts(p)
    total = p * p
    return {
        "prime": p,
        "numSplit": counts["split"],
        "numRamified": counts["ramified"],
        "numInert": counts["inert"],
        "total": total,
        "splitFraction": counts["split"] / total,
        "theoreticalSplit": p * (p - 1) // 2,
        "theoreticalRamified": p,
        "theoreticalInert": p * (p - 1) // 2,
        "theoreticalSplitFraction": (p - 1) / (2 * p),
    }


def cubic_fiber_sizes(p: int) -> Dict[int, int]:
    """Compute fiber sizes for the cubic discriminant -4b³ - 27c² over F_p.
    
    Args:
        p: An odd prime ≥ 5.
    
    Returns:
        Dictionary mapping d to |{(b,c) : -4b³ - 27c² ≡ d}|.
    """
    sizes: Dict[int, int] = {d: 0 for d in range(p)}
    for b in range(p):
        for c in range(p):
            d = (-4 * b**3 - 27 * c**2) % p
            sizes[d] += 1
    return sizes


def verify_cubic_uniformity(p: int) -> Tuple[bool, Dict[int, int]]:
    """Check whether the cubic discriminant has uniform fibers over F_p.
    
    Args:
        p: An odd prime ≥ 5.
    
    Returns:
        (is_uniform, fiber_sizes) where is_uniform is True iff all fibers 
        have size p.
    """
    sizes = cubic_fiber_sizes(p)
    is_uniform = all(s == p for s in sizes.values())
    return is_uniform, sizes
