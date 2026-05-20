#!/usr/bin/env python3
"""
Stereographic Capacity Theory: Real-World Applications

Demonstrates applications of stereographic packing bounds to:
1. Spherical code design for communication systems
2. Molecular geometry: packing atoms on viral capsids
3. Directional statistics: sensor placement on Earth
4. Signal constellation design

Each application shows how the bound is computed and interpreted.
"""

import math
from typing import List, Tuple

from algorithms import (
    packing_bound_s2,
    packing_bound_general,
    stereo_factor,
    stereo_exclusion_radius,
    distortion_overhead,
)


# ============================================================
# Application 1: Spherical Code Design
# ============================================================

def spherical_code_bound(n: int, theta: float) -> Tuple[float, int]:
    """
    Upper bound on spherical code size with minimum angular separation θ.

    A spherical code is a finite subset of S^n where all pairs of points
    have angular separation at least θ. This is equivalent to a packing
    with cap radius r = θ/2.

    Parameters
    ----------
    n : int
        Dimension of the sphere.
    theta : float
        Minimum angular separation in radians.

    Returns
    -------
    tuple of (float, int)
        (exact_bound, ceiling_bound)

    Examples
    --------
    >>> exact, ceil_val = spherical_code_bound(2, math.pi / 3)
    >>> ceil_val >= 12  # Icosahedral code
    True
    """
    r = theta / 2.0
    return packing_bound_general(n, r)


def communication_channel_analysis():
    """
    Analyze spherical code capacity for a communication channel.

    In a real-valued communication channel using unit-norm signal vectors,
    the maximum number of distinguishable signals with angular separation
    at least θ is bounded by the spherical packing number.
    """
    print("=" * 65)
    print("Application 1: Spherical Code Capacity for Communication")
    print("=" * 65)
    print()
    print("Signal vectors on S² with minimum angular separation θ:")
    print()
    print(f"{'θ (deg)':>10s}  {'θ (rad)':>10s}  {'Bound':>10s}  {'⌈Bound⌉':>8s}  {'Bits':>8s}")
    print("-" * 55)

    for theta_deg in [30, 45, 60, 72, 90, 120]:
        theta = math.radians(theta_deg)
        r = theta / 2.0
        if r > 0 and r < math.pi / 2:
            exact, ceil_val = packing_bound_s2(r)
            bits = math.log2(ceil_val) if ceil_val > 0 else 0
            print(f"{theta_deg:10d}  {theta:10.4f}  {exact:10.2f}  {ceil_val:8d}  {bits:8.2f}")

    print()
    print("Higher-dimensional codes (S^n, θ = 60°):")
    print(f"{'n':>5s}  {'Bound':>12s}  {'⌈Bound⌉':>8s}  {'Bits':>8s}")
    print("-" * 40)
    for n in [2, 3, 4, 5, 6, 8, 10]:
        r = math.pi / 6  # θ/2 for θ=60°
        exact, ceil_val = packing_bound_general(n, r)
        bits = math.log2(ceil_val) if ceil_val > 0 else 0
        print(f"{n:5d}  {exact:12.2f}  {ceil_val:8d}  {bits:8.2f}")
    print()


# ============================================================
# Application 2: Molecular Geometry
# ============================================================

def viral_capsid_analysis():
    """
    Analyze packing of protein subunits on a viral capsid.

    Viral capsids are approximately spherical, and protein subunits
    must maintain minimum separation. The stereographic bound gives
    upper limits on the number of subunits that can fit.
    """
    print("=" * 65)
    print("Application 2: Viral Capsid Protein Packing")
    print("=" * 65)
    print()

    # Typical capsid parameters
    capsid_radius_nm = 30.0  # nanometers
    protein_diameter_nm = 7.0  # nanometers

    # Angular radius of exclusion zone
    r = math.asin(protein_diameter_nm / (2 * capsid_radius_nm))

    print(f"Capsid radius:      {capsid_radius_nm:.1f} nm")
    print(f"Protein diameter:   {protein_diameter_nm:.1f} nm")
    print(f"Angular exclusion:  {math.degrees(r):.2f}°  ({r:.4f} rad)")
    print()

    exact, ceil_val = packing_bound_s2(r)
    overhead = distortion_overhead(r)

    print(f"Stereographic bound:  ≤ {ceil_val} subunits")
    print(f"Distortion overhead:  {overhead:.4f}x")
    print(f"Simple volume bound:  ≤ {math.ceil(2.0 / (1.0 - math.cos(r)))} subunits")
    print()

    # Compare with known T-numbers
    print("Known icosahedral capsid configurations:")
    for T, N in [(1, 60), (3, 180), (4, 240), (7, 420)]:
        needed_r = math.acos(1 - 2.0 / N * (1 - math.cos(math.pi / 6)))
        print(f"  T={T}: {N} subunits")
    print()


# ============================================================
# Application 3: Sensor Placement
# ============================================================

def sensor_placement_analysis():
    """
    Analyze optimal sensor placement on Earth's surface.

    Sensors must be separated by at least d km on the surface.
    Earth radius ≈ 6371 km. The angular separation is d/R.
    """
    print("=" * 65)
    print("Application 3: Global Sensor Network Placement")
    print("=" * 65)
    print()

    R_earth = 6371.0  # km

    print(f"Earth radius: {R_earth:.0f} km")
    print()
    print(f"{'Sep (km)':>10s}  {'Sep (deg)':>10s}  {'Bound':>10s}  {'⌈Bound⌉':>8s}  {'Overhead':>10s}")
    print("-" * 55)

    for d_km in [100, 200, 500, 1000, 2000, 5000]:
        r = d_km / (2 * R_earth)  # half the angular separation
        if r < math.pi / 2:
            exact, ceil_val = packing_bound_s2(r)
            overhead = distortion_overhead(r)
            r_deg = math.degrees(2 * r)
            print(f"{d_km:10d}  {r_deg:10.2f}  {exact:10.2f}  {ceil_val:8d}  {overhead:10.4f}")
    print()


# ============================================================
# Application 4: Distortion Map Visualization Data
# ============================================================

def distortion_map_data(n_points: int = 50) -> List[Tuple[float, float, float]]:
    """
    Generate data for visualizing the stereographic distortion field.

    Returns (x, y, λ(x,y)) triples for a grid of points in ℝ².

    Parameters
    ----------
    n_points : int
        Grid resolution per axis.

    Returns
    -------
    list of (float, float, float)
        (x, y, conformal_factor) triples.
    """
    data = []
    extent = 5.0
    for i in range(n_points):
        for j in range(n_points):
            x = -extent + 2 * extent * i / (n_points - 1)
            y = -extent + 2 * extent * j / (n_points - 1)
            norm = math.sqrt(x ** 2 + y ** 2)
            lam = stereo_factor(norm)
            data.append((x, y, lam))
    return data


def print_distortion_summary():
    """Print a summary of the distortion field properties."""
    print("=" * 65)
    print("Application 4: Stereographic Distortion Field Analysis")
    print("=" * 65)
    print()
    print("The conformal factor λ(x) = 2/(1+‖x‖²) controls how")
    print("spherical geometry distorts under stereographic projection.")
    print()
    print(f"{'‖x‖':>8s}  {'λ(x)':>10s}  {'1/λ(x)':>10s}  {'Sphere point':>20s}")
    print("-" * 55)

    for norm in [0.0, 0.5, 1.0, 1.5, 2.0, 3.0, 5.0, 10.0]:
        lam = stereo_factor(norm)
        inv_lam = 1.0 / lam
        # Corresponding colatitude on sphere
        if norm == 0:
            desc = "South pole"
        else:
            colat = 2 * math.atan(norm)
            lat = 90 - math.degrees(colat)
            desc = f"lat {lat:.1f}°"
        print(f"{norm:8.2f}  {lam:10.6f}  {inv_lam:10.4f}  {desc:>20s}")
    print()
    print("Key insight: Points near the equator (‖x‖ ≈ 1) have λ ≈ 1,")
    print("while points near the north pole (‖x‖ → ∞) have λ → 0.")
    print("This means projected caps near the north pole are greatly")
    print("enlarged, requiring the distortion correction factor.")
    print()


# ============================================================
# Main
# ============================================================

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Stereographic Capacity Theory: Real-World Applications ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    communication_channel_analysis()
    viral_capsid_analysis()
    sensor_placement_analysis()
    print_distortion_summary()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Stereographic Capacity Theory: S² Packing Bound Calculator

Computes the stereographic upper bound on spherical packing numbers for the
unit 2-sphere, using the closed-form formula:

    N(2, r) ≤ ⌈ 8 / (cos²r · (1 - cos r)) ⌉

This bound arises from stereographic projection distortion analysis:
the conformal factor λ(x) = 2/(1 + ‖x‖²) controls how spherical caps
map to Euclidean balls, and the worst-case distortion yields the factor
(2/cos r)² in the area-based packing estimate.

Usage:
    python demo.py           # Interactive mode
    python demo.py 0.5236    # Compute bound for r = π/6 ≈ 0.5236
"""

import math
import sys


def stereo_bound_s2(r: float) -> float:
    """
    Compute the stereographic upper bound on S² packing number.

    Parameters
    ----------
    r : float
        Geodesic cap radius in radians, must satisfy 0 < r < π/2.

    Returns
    -------
    float
        Upper bound on the number of pairwise 2r-separated points on S².

    Formula
    -------
    B(r) = 8 / (cos²(r) · (1 - cos(r)))

    This equals (2/cos r)² · (4π) / (2π(1 - cos r)), which is the
    distortion-corrected volume ratio bound.
    """
    if r <= 0 or r >= math.pi / 2:
        raise ValueError(f"r must be in (0, π/2), got {r}")
    c = math.cos(r)
    return 8.0 / (c ** 2 * (1.0 - c))


def stereo_bound_s2_factored(r: float) -> float:
    """
    Compute the bound in factored form: (2/cos r)² · sphereArea / capArea.

    This is mathematically equivalent to stereo_bound_s2 but shows the
    decomposition into distortion factor × volume ratio.
    """
    if r <= 0 or r >= math.pi / 2:
        raise ValueError(f"r must be in (0, π/2), got {r}")
    c = math.cos(r)
    distortion = (2.0 / c) ** 2
    sphere_area = 4.0 * math.pi
    cap_area = 2.0 * math.pi * (1.0 - c)
    return distortion * sphere_area / cap_area


def volume_bound_s2(r: float) -> float:
    """
    Simple volume bound (without distortion correction):
    sphereArea / capArea = 4π / (2π(1-cos r)) = 2/(1-cos r).
    """
    if r <= 0 or r >= math.pi:
        raise ValueError(f"r must be in (0, π), got {r}")
    c = math.cos(r)
    return 2.0 / (1.0 - c)


# Known optimal/best-known packing numbers for S²
KNOWN_PACKINGS = {
    "π/6": {"r": math.pi / 6, "known_N": 12, "description": "Icosahedron vertices"},
    "π/4": {"r": math.pi / 4, "known_N": 6, "description": "Octahedron vertices"},
    "π/3": {"r": math.pi / 3, "known_N": 4, "description": "Tetrahedron vertices"},
    "π/2": {"r": math.pi / 2 - 1e-10, "known_N": 3, "description": "Three mutually orthogonal points"},
}


def calibration_table():
    """Print calibration comparison between bound and known configurations."""
    print("=" * 76)
    print("CALIBRATION: Stereographic S² Packing Bound vs Known Optimal Configurations")
    print("=" * 76)
    print(f"{'r':>8s}  {'Bound':>12s}  {'⌈Bound⌉':>8s}  {'Known N':>8s}  {'Ratio':>8s}  {'Config'}")
    print("-" * 76)

    for name, data in KNOWN_PACKINGS.items():
        r = data["r"]
        try:
            bound = stereo_bound_s2(r)
            bound_ceil = math.ceil(bound)
            known = data["known_N"]
            ratio = bound / known
            print(f"{name:>8s}  {bound:12.4f}  {bound_ceil:8d}  {known:8d}  {ratio:8.2f}  {data['description']}")
        except ValueError:
            print(f"{name:>8s}  {'N/A':>12s}  {'N/A':>8s}  {data['known_N']:8d}  {'N/A':>8s}  {data['description']}")
    print()


def distortion_analysis(r: float):
    """Analyze the distortion factor contribution to the bound."""
    c = math.cos(r)
    distortion = (2.0 / c) ** 2
    volume_ratio = 2.0 / (1.0 - c)
    total = distortion * volume_ratio

    print(f"\nDistortion Analysis for r = {r:.6f} ({math.degrees(r):.2f}°)")
    print("-" * 50)
    print(f"  cos(r)                = {c:.6f}")
    print(f"  Distortion (2/cos r)² = {distortion:.6f}")
    print(f"  Volume ratio 2/(1-cr) = {volume_ratio:.6f}")
    print(f"  Total bound           = {total:.4f}")
    print(f"  Ceiling               = {math.ceil(total)}")
    print(f"  Simple volume bound   = {volume_ratio:.4f}")
    print(f"  Distortion overhead   = {distortion:.4f}x")
    print()


def sweep_table(n_points: int = 20):
    """Print a table of bounds for a sweep of radii."""
    print("\n" + "=" * 70)
    print("SWEEP: Stereographic S² Packing Bound for Various Radii")
    print("=" * 70)
    print(f"{'r (rad)':>10s}  {'r (deg)':>10s}  {'Bound':>12s}  {'⌈Bound⌉':>8s}  {'VolBound':>12s}  {'Distort':>8s}")
    print("-" * 70)

    for i in range(1, n_points + 1):
        r = (math.pi / 2) * i / (n_points + 1)
        bound = stereo_bound_s2(r)
        vol_bound = volume_bound_s2(r)
        c = math.cos(r)
        distortion = (2.0 / c) ** 2
        print(f"{r:10.4f}  {math.degrees(r):10.2f}  {bound:12.4f}  {math.ceil(bound):8d}  {vol_bound:12.4f}  {distortion:8.4f}")
    print()


def main():
    print("╔══════════════════════════════════════════════════════╗")
    print("║  Stereographic Capacity Theory: S² Packing Bounds   ║")
    print("╚══════════════════════════════════════════════════════╝")
    print()

    # If command-line argument provided, compute for that radius
    if len(sys.argv) > 1:
        try:
            r = float(sys.argv[1])
            bound = stereo_bound_s2(r)
            print(f"r = {r:.6f} rad ({math.degrees(r):.2f}°)")
            print(f"Stereographic bound: {bound:.4f}")
            print(f"Ceiling:             {math.ceil(bound)}")
            distortion_analysis(r)
        except ValueError as e:
            print(f"Error: {e}")
        return

    # Full interactive demo
    calibration_table()
    sweep_table()

    # Distortion analysis for calibration values
    for name, data in list(KNOWN_PACKINGS.items())[:3]:
        distortion_analysis(data["r"])

    # Interactive input
    print("\n" + "=" * 50)
    print("Interactive Mode")
    print("=" * 50)
    while True:
        try:
            s = input("\nEnter r in radians (or 'q' to quit): ").strip()
            if s.lower() in ('q', 'quit', 'exit', ''):
                break
            r = float(s)
            bound = stereo_bound_s2(r)
            print(f"  Stereographic bound: {bound:.4f}")
            print(f"  Ceiling:             {math.ceil(bound)}")
        except ValueError as e:
            print(f"  Error: {e}")
        except (EOFError, KeyboardInterrupt):
            break

    print("\nDone.")


if __name__ == "__main__":
    main()
