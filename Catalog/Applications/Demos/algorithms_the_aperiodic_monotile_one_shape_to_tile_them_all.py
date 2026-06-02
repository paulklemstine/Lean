"""
Algorithms for the Aperiodic Monotile (Hat Tile) Spectrum

Implements:
1. Hat spectrum parameterization (edge lengths, areas, edge ratios)
2. Substitution matrix spectral analysis
3. Tile patch generation via substitution
"""

import math
from typing import Tuple, List, Dict

# ============================================================
# Algorithm 1: Hat Spectrum Parameterization
# ============================================================

def edge_length_a(t: float) -> float:
    """Compute edge length a(t) = (1-t) + t*sqrt(3) for t in [0,1]."""
    return (1.0 - t) + t * math.sqrt(3)

def edge_length_b(t: float) -> float:
    """Compute edge length b(t) = t + (1-t)*sqrt(3) for t in [0,1]."""
    return t + (1.0 - t) * math.sqrt(3)

def edge_ratio(t: float) -> float:
    """Compute the edge ratio a(t)/b(t)."""
    return edge_length_a(t) / edge_length_b(t)

def hat_tile_area(t: float, scale: float = 1.0) -> float:
    """Compute the area of a hat tile at parameter t with given scale.

    The hat is composed of 8 kites, each with area sqrt(3)/4 * s^2.
    Total area = 2*sqrt(3)*s^2.
    """
    s = edge_length_a(t) * scale
    return 2.0 * math.sqrt(3) * s ** 2

def critical_parameter() -> float:
    """The critical parameter t* = 1/2 where a(t) = b(t)."""
    return 0.5

def is_aperiodic(t: float, tol: float = 1e-10) -> bool:
    """Check if the tile at parameter t is aperiodic (t != 1/2)."""
    return abs(t - 0.5) > tol


# ============================================================
# Algorithm 2: Expansion Factor Analysis
# ============================================================

def hat_expansion_factor() -> float:
    """The linear expansion factor lambda = 2 + sqrt(3)."""
    return 2.0 + math.sqrt(3)

def hat_expansion_conjugate() -> float:
    """The conjugate 2 - sqrt(3), which is 1/lambda."""
    return 2.0 - math.sqrt(3)

def verify_minimal_polynomial(lam: float) -> float:
    """Verify lambda^2 - 4*lambda + 1 = 0. Returns the residual."""
    return lam**2 - 4*lam + 1

def verify_conjugate_product(lam: float, lam_bar: float) -> float:
    """Verify lambda * lambda_bar = 1. Returns the residual."""
    return lam * lam_bar - 1.0

def area_expansion_factor() -> float:
    """The area expansion factor lambda^2 = 7 + 4*sqrt(3)."""
    lam = hat_expansion_factor()
    return lam ** 2

def tile_count_at_level(n: int) -> float:
    """Approximate number of tiles in a level-n supertile.

    The area grows as lambda^(2n), so the tile count is approximately
    lambda^(2n) (since all tiles have the same area at a given parameter).
    """
    lam = hat_expansion_factor()
    return lam ** (2 * n)


# ============================================================
# Algorithm 3: Substitution Matrix Analysis
# ============================================================

def substitution_matrix() -> List[List[int]]:
    """The 4x4 substitution matrix for the hat metatile system (H,T,P,F).

    M[i][j] = number of copies of metatile type i in the supertile of type j.
    """
    return [
        [1, 0, 0, 1],
        [1, 1, 0, 0],
        [0, 1, 1, 0],
        [0, 0, 1, 1]
    ]

def matrix_multiply(A: List[List[float]], B: List[List[float]]) -> List[List[float]]:
    """Multiply two square matrices."""
    n = len(A)
    C = [[0.0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] += A[i][k] * B[k][j]
    return C

def matrix_power(M: List[List[float]], p: int) -> List[List[float]]:
    """Compute M^p by repeated squaring."""
    n = len(M)
    result = [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]
    base = [row[:] for row in M]
    while p > 0:
        if p % 2 == 1:
            result = matrix_multiply(result, base)
        base = matrix_multiply(base, base)
        p //= 2
    return result

def metatile_counts_at_level(n: int) -> List[List[float]]:
    """Compute M^n to get metatile counts at substitution level n."""
    M = [[float(x) for x in row] for row in substitution_matrix()]
    return matrix_power(M, n)

def metatile_frequencies(n: int) -> List[float]:
    """Compute the relative frequency of each metatile type at level n.

    Returns [freq_H, freq_T, freq_P, freq_F] where freq_X is the
    proportion of type-X metatiles in a level-n H-supertile.
    """
    Mn = metatile_counts_at_level(n)
    # Column 0 = supertile of type H
    col = [Mn[i][0] for i in range(4)]
    total = sum(col)
    return [c / total for c in col]


# ============================================================
# Algorithm 4: Hat Tile Vertex Generation
# ============================================================

def hat_vertices(a: float, b: float) -> List[Tuple[float, float]]:
    """Generate the 13 vertices of the hat tile with edge lengths a and b.

    The hat is constructed from kites of the hexagonal Laves tiling.
    Vertices are given in counterclockwise order.
    """
    s3 = math.sqrt(3)

    # The hat tile vertices (in a coordinate system aligned with the hex grid)
    # Based on the Smith et al. vertex coordinates
    vertices = [
        (0, 0),
        (a, 0),
        (a + b * 0.5, b * s3 / 2),
        (a + b * 0.5 + a * 0.5, b * s3 / 2 + a * s3 / 2),
        (a + b, b * s3),
        (a + b - a * 0.5, b * s3 + a * s3 / 2),
        (b, b * s3),
        (b - a * 0.5, b * s3 - a * s3 / 2),
        (-a * 0.5, b * s3 / 2 + a * s3 / 2),
        (-a, b * s3 / 2 + a * s3 / 2 - b * s3 / 2),
        (-a - b * 0.5, a * s3 / 2),
        (-b * 0.5, a * s3 / 2 - b * s3 / 2),
        (-b * 0.5 + a * 0.5, 0),
    ]
    return vertices


def hat_spectrum_sample(num_points: int = 100) -> List[Dict]:
    """Sample the hat spectrum at evenly spaced parameter values.

    Returns a list of dicts with keys: t, a, b, ratio, area, is_aperiodic.
    """
    results = []
    for i in range(num_points + 1):
        t = i / num_points
        a = edge_length_a(t)
        b = edge_length_b(t)
        results.append({
            't': t,
            'a': a,
            'b': b,
            'ratio': a / b,
            'area': hat_tile_area(t),
            'is_aperiodic': is_aperiodic(t),
        })
    return results


if __name__ == "__main__":
    # Quick verification
    lam = hat_expansion_factor()
    lam_bar = hat_expansion_conjugate()

    print("=== Expansion Factor Properties ===")
    print(f"lambda = {lam:.10f}")
    print(f"lambda_bar = {lam_bar:.10f}")
    print(f"lambda^2 - 4*lambda + 1 = {verify_minimal_polynomial(lam):.2e}")
    print(f"lambda * lambda_bar = {verify_conjugate_product(lam, lam_bar) + 1:.10f}")
    print(f"lambda + lambda_bar = {lam + lam_bar:.10f}")
    print()

    print("=== Hat Spectrum Boundary Values ===")
    print(f"t=0 (hat):    a={edge_length_a(0):.4f}, b={edge_length_b(0):.4f}")
    print(f"t=0.5 (crit): a={edge_length_a(0.5):.4f}, b={edge_length_b(0.5):.4f}")
    print(f"t=1 (turtle): a={edge_length_a(1):.4f}, b={edge_length_b(1):.4f}")
    print()

    print("=== Tile Counts at Substitution Levels ===")
    for n in range(8):
        count = tile_count_at_level(n)
        print(f"Level {n}: ~{count:.1f} tiles")
    print()

    print("=== Metatile Frequencies (level 10 H-supertile) ===")
    freqs = metatile_frequencies(10)
    print(f"H: {freqs[0]:.6f}, T: {freqs[1]:.6f}, P: {freqs[2]:.6f}, F: {freqs[3]:.6f}")
