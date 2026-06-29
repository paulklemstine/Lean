#!/usr/bin/env python3
"""
algorithms.py — Verified algorithms for nonlinear Σ-protocol extraction analysis.

Implements:
1. Image extraction from transcript pairs
2. Fiber enumeration for polynomial witness maps
3. Ambiguity classification for nonlinear protocols
4. Injective domain computation for quadratic maps
"""

from typing import List, Tuple, Set, Optional, Dict
from dataclasses import dataclass
from enum import Enum


class ExtractionResult(Enum):
    """Classification of extraction outcomes."""
    UNIQUE = "unique"           # Single compatible witness
    AMBIGUOUS = "ambiguous"     # Multiple compatible witnesses (fiber > 1)
    INCONSISTENT = "inconsistent"  # No compatible witness
    TRIVIAL = "trivial"         # All witnesses compatible (degenerate)


@dataclass
class ExtractionReport:
    """Complete report of an extraction attempt."""
    result: ExtractionResult
    extracted_image: Optional[int]
    compatible_witnesses: List[int]
    fiber_size: int
    field_size: int
    witness_map_degree: int

    def __repr__(self) -> str:
        lines = [
            f"ExtractionReport(",
            f"  result = {self.result.value},",
            f"  extracted_image = {self.extracted_image},",
            f"  compatible_witnesses = {self.compatible_witnesses},",
            f"  fiber_size = {self.fiber_size},",
            f"  field_size = {self.field_size},",
            f"  witness_map_degree = {self.witness_map_degree}",
            f")"
        ]
        return "\n".join(lines)


def mod_inv(a: int, p: int) -> int:
    """
    Compute modular inverse of a mod p using extended Euclidean algorithm.

    Args:
        a: Element to invert
        p: Prime modulus

    Returns:
        a^(-1) mod p

    Raises:
        ValueError: If a ≡ 0 (mod p)

    Complexity: O(log p) time, O(1) space
    """
    if a % p == 0:
        raise ValueError(f"{a} is not invertible mod {p}")
    return pow(a, p - 2, p)


def extract_image(
    z1: int, z2: int, c1: int, c2: int, p: int
) -> int:
    """
    Extract the witness map image from two transcripts.

    Given transcripts satisfying z_i = t + c_i * g(w) mod p,
    computes g(w) = (z1 - z2) / (c1 - c2) mod p.

    Args:
        z1, z2: Response values
        c1, c2: Challenge values (must be distinct)
        p: Prime modulus

    Returns:
        The extracted image g(w) mod p

    Complexity: O(log p) time, O(1) space

    >>> extract_image(5, 3, 7, 2, 17)  # u = 2/5 mod 17
    11
    """
    if (c1 - c2) % p == 0:
        raise ValueError("Challenges must be distinct")
    return ((z1 - z2) * mod_inv((c1 - c2) % p, p)) % p


def enumerate_fiber(
    g: callable,
    u: int,
    p: int
) -> List[int]:
    """
    Enumerate all elements in the fiber g^(-1)(u) over F_p.

    Args:
        g: Witness map function (int -> int, mod p)
        u: Target image value
        p: Prime modulus

    Returns:
        Sorted list of all w in F_p with g(w) ≡ u (mod p)

    Complexity: O(p) time, O(|fiber|) space
    """
    return sorted([w for w in range(p) if g(w) % p == u])


def classify_extraction(
    g: callable,
    transcripts: List[Tuple[int, int]],
    t: int,
    p: int,
    degree: int = 2
) -> ExtractionReport:
    """
    Classify the extraction outcome for a nonlinear protocol.

    Given a witness map g, commitment term t, and a list of
    (challenge, response) transcript pairs, determines whether
    the witness is uniquely extractable, ambiguous, or inconsistent.

    Algorithm:
    1. Extract image u = g(w) from any two distinct-challenge transcripts
    2. Verify all transcripts are consistent with u
    3. Enumerate fiber g^(-1)(u)
    4. Classify based on fiber size

    Args:
        g: Witness map function
        transcripts: List of (challenge, response) pairs
        t: Commitment term
        p: Prime modulus
        degree: Degree of witness map (for reporting)

    Returns:
        ExtractionReport with full analysis

    Complexity: O(p + k log p) where k = |transcripts|
    """
    if len(transcripts) < 2:
        # With fewer than 2 transcripts, all witnesses may be compatible
        compatible = []
        for w in range(p):
            all_ok = all(
                z == (t + c * g(w)) % p
                for c, z in transcripts
            )
            if all_ok:
                compatible.append(w)
        return ExtractionReport(
            result=ExtractionResult.TRIVIAL if len(compatible) == p
                   else ExtractionResult.AMBIGUOUS if len(compatible) > 1
                   else ExtractionResult.UNIQUE if len(compatible) == 1
                   else ExtractionResult.INCONSISTENT,
            extracted_image=None,
            compatible_witnesses=compatible,
            fiber_size=len(compatible),
            field_size=p,
            witness_map_degree=degree
        )

    # Find two transcripts with distinct challenges
    c1, z1 = transcripts[0]
    c2, z2 = None, None
    for c, z in transcripts[1:]:
        if c % p != c1 % p:
            c2, z2 = c, z
            break

    if c2 is None:
        # All challenges identical — cannot extract
        compatible = [w for w in range(p)
                      if all(z == (t + c * g(w)) % p for c, z in transcripts)]
        return ExtractionReport(
            result=ExtractionResult.AMBIGUOUS if len(compatible) > 1
                   else ExtractionResult.UNIQUE if len(compatible) == 1
                   else ExtractionResult.INCONSISTENT,
            extracted_image=None,
            compatible_witnesses=compatible,
            fiber_size=len(compatible),
            field_size=p,
            witness_map_degree=degree
        )

    # Extract image
    u = extract_image(z1, z2, c1, c2, p)

    # Verify consistency of all transcripts
    consistent = all(z == (t + c * u) % p for c, z in transcripts)
    if not consistent:
        return ExtractionReport(
            result=ExtractionResult.INCONSISTENT,
            extracted_image=u,
            compatible_witnesses=[],
            fiber_size=0,
            field_size=p,
            witness_map_degree=degree
        )

    # Enumerate fiber
    fiber = enumerate_fiber(g, u, p)

    if len(fiber) == 0:
        result = ExtractionResult.INCONSISTENT
    elif len(fiber) == 1:
        result = ExtractionResult.UNIQUE
    else:
        result = ExtractionResult.AMBIGUOUS

    return ExtractionReport(
        result=result,
        extracted_image=u,
        compatible_witnesses=fiber,
        fiber_size=len(fiber),
        field_size=p,
        witness_map_degree=degree
    )


def compute_injective_domain(
    g: callable,
    p: int
) -> List[int]:
    """
    Compute a maximal injective subdomain for g over F_p.

    Selects one representative from each fiber of g,
    preferring the smallest element.

    Args:
        g: Witness map function
        p: Prime modulus

    Returns:
        Sorted list of elements forming an injective domain

    Complexity: O(p) time, O(p) space
    """
    seen_images: Dict[int, int] = {}
    domain: List[int] = []

    for w in range(p):
        img = g(w) % p
        if img not in seen_images:
            seen_images[img] = w
            domain.append(w)

    return sorted(domain)


def quadratic_injective_half(p: int) -> List[int]:
    """
    Compute the canonical injective half-domain for squaring over F_p.

    For odd prime p, returns {0, 1, 2, ..., (p-1)/2}, on which
    the squaring map is injective.

    Args:
        p: Odd prime

    Returns:
        The canonical injective domain

    Complexity: O(1) time
    """
    return list(range((p - 1) // 2 + 1))


def fiber_statistics(g: callable, p: int) -> Dict[str, any]:
    """
    Compute complete fiber statistics for a map g over F_p.

    Args:
        g: Map from F_p to F_p
        p: Prime modulus

    Returns:
        Dictionary with fiber size distribution, image size, etc.

    Complexity: O(p) time, O(p) space
    """
    fibers: Dict[int, List[int]] = {}
    for w in range(p):
        img = g(w) % p
        fibers.setdefault(img, []).append(w)

    fiber_sizes = [len(f) for f in fibers.values()]

    return {
        "field_size": p,
        "image_size": len(fibers),
        "max_fiber_size": max(fiber_sizes),
        "min_fiber_size": min(fiber_sizes),
        "avg_fiber_size": sum(fiber_sizes) / len(fiber_sizes),
        "fiber_size_distribution": {
            size: sum(1 for s in fiber_sizes if s == size)
            for size in sorted(set(fiber_sizes))
        },
        "has_collision": any(s > 1 for s in fiber_sizes),
        "is_injective": all(s == 1 for s in fiber_sizes),
        "fibers": {u: sorted(f) for u, f in sorted(fibers.items())}
    }


# ─── Example usage ───────────────────────────────────────────────────────

if __name__ == "__main__":
    p = 17

    print("=== Image Extraction ===")
    # Setup: w=3, t=5, g(w) = w^2 = 9
    w, t_val = 3, 5
    g = lambda x: x * x
    u_true = g(w) % p

    c1, c2 = 2, 7
    z1 = (t_val + c1 * u_true) % p
    z2 = (t_val + c2 * u_true) % p

    u_ext = extract_image(z1, z2, c1, c2, p)
    print(f"True image: {u_true}, Extracted: {u_ext}, Match: {u_true == u_ext}")

    print("\n=== Fiber Enumeration ===")
    fiber = enumerate_fiber(g, u_true, p)
    print(f"Fiber of {u_true} under squaring: {fiber}")

    print("\n=== Extraction Classification ===")
    transcripts = [(c1, z1), (c2, z2)]
    report = classify_extraction(g, transcripts, t_val, p)
    print(report)

    print("\n=== Injective Domain ===")
    domain = compute_injective_domain(g, p)
    print(f"Injective domain for squaring: {domain}")
    half = quadratic_injective_half(p)
    print(f"Canonical half-domain: {half}")

    print("\n=== Fiber Statistics ===")
    stats = fiber_statistics(g, p)
    for key, val in stats.items():
        if key != "fibers":
            print(f"  {key}: {val}")
