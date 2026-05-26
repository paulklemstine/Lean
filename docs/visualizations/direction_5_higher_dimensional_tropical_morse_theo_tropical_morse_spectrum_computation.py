"""
Higher-Dimensional Tropical Morse Theory — Core Algorithms

Implements the tropical Morse spectrum computation for finite simplicial
complexes of arbitrary dimension, including:
  - Simplicial complex representation and validation
  - Euler characteristic computation via alternating sums
  - f-vector computation
  - Weighted filtration and tropical Morse spectrum extraction
  - Surface classification via signed event sums
  - Double-counting verification for closed surfaces

All algorithms are exact (using Python integers and fractions).
"""

from __future__ import annotations
from dataclasses import dataclass, field
from fractions import Fraction
from typing import FrozenSet, List, Tuple, Dict, Optional
from collections import Counter
import itertools


# ─────────────────────────────────────────────────────────────────────
# Core data structures
# ─────────────────────────────────────────────────────────────────────

Simplex = FrozenSet[int]

@dataclass
class SimplicialComplex:
    """A finite abstract simplicial complex.

    Represented as a set of simplices (frozensets of vertex indices),
    automatically closed under taking nonempty subfaces.
    """
    faces: set[Simplex] = field(default_factory=set)

    def __post_init__(self):
        self._close_downward()

    def _close_downward(self):
        """Ensure closure under nonempty subsets."""
        to_add = set()
        for sigma in self.faces:
            for k in range(1, len(sigma)):
                for tau in itertools.combinations(sigma, k):
                    to_add.add(frozenset(tau))
        self.faces |= to_add

    @property
    def vertices(self) -> set[int]:
        """Return all vertices."""
        return {v for sigma in self.faces for v in sigma}

    @property
    def dimension(self) -> int:
        """Maximum simplex dimension, or -1 if empty."""
        if not self.faces:
            return -1
        return max(len(sigma) - 1 for sigma in self.faces)

    def f_vector(self) -> Dict[int, int]:
        """Compute f-vector: f[d] = number of d-dimensional simplices.

        Time complexity: O(|faces|)
        Space complexity: O(dim)
        """
        fv: Dict[int, int] = {}
        for sigma in self.faces:
            d = len(sigma) - 1
            fv[d] = fv.get(d, 0) + 1
        return fv

    def euler_characteristic(self) -> int:
        """Compute Euler characteristic χ = Σ (-1)^d f_d.

        Time complexity: O(|faces|)
        Space complexity: O(1)
        """
        return sum((-1) ** (len(sigma) - 1) for sigma in self.faces)

    def edges(self) -> set[Simplex]:
        """Return all 1-dimensional simplices (edges)."""
        return {sigma for sigma in self.faces if len(sigma) == 2}

    def triangles_set(self) -> set[Simplex]:
        """Return all 2-dimensional simplices (triangles)."""
        return {sigma for sigma in self.faces if len(sigma) == 3}

    def is_closed_surface(self) -> Tuple[bool, str]:
        """Check the closed surface condition: every edge in exactly 2 triangles.

        Returns (is_valid, message).
        """
        # Check max dimension ≤ 2
        if self.dimension > 2:
            return False, f"Dimension {self.dimension} > 2"

        edges = self.edges()
        tris = self.triangles_set()

        if not tris:
            return False, "No triangles"

        for e in edges:
            count = sum(1 for t in tris if e <= t)
            if count != 2:
                return False, f"Edge {set(e)} in {count} triangles (expected 2)"

        return True, "Valid closed surface"

    def verify_3f2_eq_2f1(self) -> Tuple[bool, str]:
        """Verify the surface relation 3·f₂ = 2·f₁."""
        fv = self.f_vector()
        f1 = fv.get(1, 0)
        f2 = fv.get(2, 0)
        holds = 3 * f2 == 2 * f1
        return holds, f"3·f₂ = {3*f2}, 2·f₁ = {2*f1}"


# ─────────────────────────────────────────────────────────────────────
# Tropical Morse Events
# ─────────────────────────────────────────────────────────────────────

@dataclass
class TropicalMorseEvent:
    """A critical event in the tropical Morse filtration."""
    value: Fraction
    dim: int
    kind: str  # 'birth', 'death', 'paired'

    @property
    def signed_contribution(self) -> int:
        """(-1)^dim"""
        return (-1) ** self.dim


@dataclass
class TropicalMorseSpectrum:
    """The tropical Morse spectrum of a weighted simplicial complex."""
    events: List[TropicalMorseEvent]

    @property
    def signed_sum(self) -> int:
        """Total signed event sum = Euler characteristic."""
        return sum(e.signed_contribution for e in self.events)

    def event_profile(self) -> Dict[int, int]:
        """Count events by dimension."""
        profile: Dict[int, int] = {}
        for e in self.events:
            profile[e.dim] = profile.get(e.dim, 0) + 1
        return profile

    def signed_profile(self) -> Dict[int, int]:
        """Signed contribution by dimension."""
        profile: Dict[int, int] = {}
        for e in self.events:
            profile[e.dim] = profile.get(e.dim, 0) + e.signed_contribution
        return profile


# ─────────────────────────────────────────────────────────────────────
# Tropical Morse Spectrum Computation
# ─────────────────────────────────────────────────────────────────────

def compute_tropical_morse_spectrum(
    K: SimplicialComplex,
    weight: Dict[Simplex, Fraction]
) -> TropicalMorseSpectrum:
    """Compute the tropical Morse spectrum of a weighted simplicial complex.

    Algorithm:
    1. Sort all faces by weight (breaking ties by dimension, then lexicographic).
    2. Add faces one at a time in sorted order.
    3. Each face insertion is a tropical Morse event with dimension = dim(σ)
       and signed contribution (-1)^dim(σ).

    Under generic weights (all weights distinct), this gives the complete
    filtration event sequence.

    Args:
        K: A simplicial complex.
        weight: A weight function on faces (must assign weight to every face).

    Returns:
        The tropical Morse spectrum.

    Time complexity: O(|faces| · log |faces|)
    Space complexity: O(|faces|)
    """
    # Ensure all faces have weights
    for sigma in K.faces:
        if sigma not in weight:
            raise ValueError(f"Missing weight for face {set(sigma)}")

    # Sort faces by weight, breaking ties by dimension (lower dim first)
    sorted_faces = sorted(K.faces, key=lambda s: (weight[s], len(s), sorted(s)))

    events = []
    for sigma in sorted_faces:
        dim = len(sigma) - 1
        event = TropicalMorseEvent(
            value=weight[sigma],
            dim=dim,
            kind='birth'  # Simplified: every event is a birth in the filtration
        )
        events.append(event)

    return TropicalMorseSpectrum(events=events)


def compute_signed_tms(
    K: SimplicialComplex,
    weight: Dict[Simplex, Fraction]
) -> List[Tuple[Fraction, int, int]]:
    """Compute the signed tropical Morse spectrum as (value, dim, sign) triples.

    Returns:
        List of (weight_value, simplex_dimension, signed_contribution).

    Time complexity: O(|faces| · log |faces|)
    """
    spectrum = compute_tropical_morse_spectrum(K, weight)
    return [(e.value, e.dim, e.signed_contribution) for e in spectrum.events]


def verify_signed_sum_equals_euler(
    K: SimplicialComplex,
    weight: Dict[Simplex, Fraction]
) -> Tuple[bool, int, int]:
    """Verify that the signed event sum equals the Euler characteristic.

    This is the computational verification of the main conservation law
    (Theorem 1 in the formal development).

    Returns:
        (match, signed_sum, euler_char)
    """
    spectrum = compute_tropical_morse_spectrum(K, weight)
    signed_sum = spectrum.signed_sum
    euler_char = K.euler_characteristic()
    return signed_sum == euler_char, signed_sum, euler_char


# ─────────────────────────────────────────────────────────────────────
# Filtration Subcomplex
# ─────────────────────────────────────────────────────────────────────

def filtration_subcomplex(
    K: SimplicialComplex,
    weight: Dict[Simplex, Fraction],
    t: Fraction
) -> SimplicialComplex:
    """Compute the filtration subcomplex K≤t.

    Returns the subcomplex consisting of all faces with weight ≤ t.
    Requires monotone weights (subfaces have ≤ weight of cofaces).

    Time complexity: O(|faces|)
    """
    sub_faces = {sigma for sigma in K.faces if weight[sigma] <= t}
    result = SimplicialComplex.__new__(SimplicialComplex)
    result.faces = sub_faces
    return result


# ─────────────────────────────────────────────────────────────────────
# Standard Surface Triangulations
# ─────────────────────────────────────────────────────────────────────

def minimal_torus_triangulation() -> SimplicialComplex:
    """Minimal triangulation of the torus T² with 7 vertices.

    Uses the standard 7-vertex triangulation (Möbius–Kantor).
    χ(T²) = 0.
    """
    triangles = [
        (0,1,2), (0,2,3), (0,3,4), (0,4,5), (0,5,6), (0,1,6),
        (1,2,4), (2,3,5), (3,4,6), (4,5,1), (5,6,2), (6,1,3),
        (1,3,5), (2,4,6),
    ]
    faces = {frozenset(t) for t in triangles}
    return SimplicialComplex(faces=faces)


def minimal_projective_plane_triangulation() -> SimplicialComplex:
    """Minimal triangulation of RP² with 6 vertices.

    Uses the standard 6-vertex triangulation.
    χ(RP²) = 1.
    """
    triangles = [
        (0,1,2), (0,2,3), (0,3,4), (0,4,5), (0,1,5),
        (1,2,4), (2,3,5), (3,4,1), (4,5,2), (5,1,3),
    ]
    faces = {frozenset(t) for t in triangles}
    return SimplicialComplex(faces=faces)


def minimal_klein_bottle_triangulation() -> SimplicialComplex:
    """Triangulation of the Klein bottle with 9 vertices.

    χ(Klein) = 0.
    """
    # 9-vertex triangulation of the Klein bottle
    triangles = [
        (0,1,4), (0,4,3), (1,2,5), (1,5,4), (2,0,3), (2,3,5),
        (3,4,7), (3,7,6), (4,5,8), (4,8,7), (5,3,6), (5,6,8),
        (6,7,1), (6,1,0), (7,8,2), (7,2,1), (8,6,0), (8,0,2),
    ]
    faces = {frozenset(t) for t in triangles}
    return SimplicialComplex(faces=faces)


def assign_generic_weights(
    K: SimplicialComplex,
    seed: int = 42
) -> Dict[Simplex, Fraction]:
    """Assign generic (distinct) weights to all faces of K.

    Weights are assigned as: weight(σ) = max vertex weight in σ + small
    perturbation based on simplex dimension, ensuring monotonicity
    (subfaces have ≤ weight).

    Time complexity: O(|faces| · max_card)
    """
    import random
    rng = random.Random(seed)

    # Assign base weights to vertices
    vertices = sorted(K.vertices)
    vertex_weight = {}
    for i, v in enumerate(vertices):
        vertex_weight[v] = Fraction(i * 100 + rng.randint(1, 99), 100)

    # Weight of a simplex = max vertex weight + small dim-based offset
    # This ensures monotonicity: subfaces have ≤ weight
    weight = {}
    sorted_faces = sorted(K.faces, key=lambda s: (len(s), sorted(s)))

    used_weights = set()
    counter = 0
    for sigma in sorted_faces:
        base = max(vertex_weight[v] for v in sigma)
        dim_offset = Fraction(len(sigma), 1000)
        w = base + dim_offset + Fraction(counter, 100000)
        # Ensure distinctness
        while w in used_weights:
            counter += 1
            w = base + dim_offset + Fraction(counter, 100000)
        weight[sigma] = w
        used_weights.add(w)
        counter += 1

    return weight


# ─────────────────────────────────────────────────────────────────────
# 2-WL Color Refinement (simplified for comparison)
# ─────────────────────────────────────────────────────────────────────

def face_incidence_graph(K: SimplicialComplex) -> Dict[Simplex, set[Simplex]]:
    """Compute the face-incidence graph of a simplicial complex.

    Two faces are adjacent if one is a proper subset of the other.

    Time complexity: O(|faces|²)
    """
    adj: Dict[Simplex, set[Simplex]] = {sigma: set() for sigma in K.faces}
    faces_list = list(K.faces)
    for i, s1 in enumerate(faces_list):
        for j in range(i + 1, len(faces_list)):
            s2 = faces_list[j]
            if s1 < s2 or s2 < s1:
                adj[s1].add(s2)
                adj[s2].add(s1)
    return adj


def wl2_color_refinement(
    K: SimplicialComplex,
    rounds: int = 10
) -> Dict[Simplex, int]:
    """Run a simplified 2-WL color refinement on the face-incidence graph.

    Initial colors are based on simplex dimension.

    Args:
        K: Simplicial complex.
        rounds: Number of refinement rounds.

    Returns:
        Final color assignment.

    Time complexity: O(rounds · |faces|²)
    """
    adj = face_incidence_graph(K)
    color = {sigma: len(sigma) for sigma in K.faces}

    for _ in range(rounds):
        new_color = {}
        for sigma in K.faces:
            neighbor_colors = tuple(sorted(color[tau] for tau in adj[sigma]))
            new_color[sigma] = hash((color[sigma], neighbor_colors))
        # Normalize colors
        unique = sorted(set(new_color.values()))
        color_map = {c: i for i, c in enumerate(unique)}
        color = {s: color_map[c] for s, c in new_color.items()}

    return color


def wl2_color_histogram(K: SimplicialComplex, rounds: int = 10) -> Counter:
    """Compute the 2-WL color histogram (multiset of final colors)."""
    colors = wl2_color_refinement(K, rounds)
    return Counter(colors.values())


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Build a simple triangle complex
    K = SimplicialComplex(faces={frozenset({0, 1, 2})})
    print(f"Triangle complex: faces = {len(K.faces)}")
    print(f"  f-vector: {K.f_vector()}")
    print(f"  Euler char: {K.euler_characteristic()}")

    # Assign weights and compute spectrum
    w = assign_generic_weights(K)
    spectrum = compute_tropical_morse_spectrum(K, w)
    print(f"  Signed sum: {spectrum.signed_sum}")
    print(f"  Event profile: {spectrum.event_profile()}")

    # Test surfaces
    for name, builder in [
        ("Torus", minimal_torus_triangulation),
        ("RP²", minimal_projective_plane_triangulation),
        ("Klein bottle", minimal_klein_bottle_triangulation),
    ]:
        S = builder()
        fv = S.f_vector()
        chi = S.euler_characteristic()
        valid, msg = S.is_closed_surface()
        print(f"\n{name}: χ={chi}, f-vector={fv}, surface={valid} ({msg})")
        if valid:
            holds, detail = S.verify_3f2_eq_2f1()
            print(f"  3f₂=2f₁: {holds} ({detail})")
