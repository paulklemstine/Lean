"""
demo.py
=======

Numerical demonstrations for:

    "Homological Necessity for an Extremal Spectral-Radius Bound:
     The Cone Mechanism and Its Reduced-Euler Shadow"

This self-contained script implements finite abstract simplicial complexes
(ASCs), their links, the reduced Euler characteristic, and the cone
construction, and then *demonstrates* the main results:

    * Theorem  ASC.reducedEuler_cone        : a cone over any complex with a
      fresh apex has reduced Euler characteristic 0.
    * Prop.    ASC.cone_faces_disjoint       : the apex-free and apex-containing
      strata of a cone are disjoint (when the apex is fresh).
    * Cor.     ASC.reducedEuler_eq_zero_of_apex : apex complexes have chi-tilde 0.
    * Remark   sign-reversing involution      : the toggle F |-> F XOR {v}
      certifies chi-tilde = 0 without summation.

We also exhibit non-cones (a circle, a sphere) whose reduced Euler
characteristic is nonzero -- the honest contrast showing chi-tilde = 0 is a
NECESSARY but NOT SUFFICIENT shadow of acyclicity -- and we verify the algebraic
identities for the spectral bound q_bd(n, r, t) = t*n - (t-1)*(r+1).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, Iterable, Set, Tuple

# A face is an immutable set of vertices; a complex is a set of faces.
Face = FrozenSet[int]
Complex = Set[Face]


# ---------------------------------------------------------------------------
# Core combinatorial framework (mirrors the Lean `ASC` development)
# ---------------------------------------------------------------------------

def downward_closure(facets: Iterable[Iterable[int]]) -> Complex:
    """Generate the full ASC (Algorithm A) from a list of generating facets.

    Returns every subset of every facet, together with the empty face.
    """
    faces: Complex = {frozenset()}
    for facet in facets:
        verts = tuple(facet)
        for k in range(len(verts) + 1):
            for sub in combinations(verts, k):
                faces.add(frozenset(sub))
    return faces


def is_complex(faces: Complex) -> bool:
    """Check the ASC axioms: empty face present and downward closure."""
    if frozenset() not in faces:
        return False
    for F in faces:
        for k in range(len(F) + 1):
            for sub in combinations(tuple(F), k):
                if frozenset(sub) not in faces:
                    return False
    return True


def reduced_euler(faces: Complex) -> int:
    """Reduced Euler characteristic (Algorithm B):  sum (-1)^(|F|+1)."""
    return sum((-1) ** (len(F) + 1) for F in faces)


def link(faces: Complex, sigma: Face) -> Complex:
    """Link of a face sigma (Algorithm D):  { F : F disjoint sigma, F u sigma in K }."""
    assert sigma in faces, "link is defined only for sigma a face of the complex"
    return {
        F
        for F in faces
        if F.isdisjoint(sigma) and (F | sigma) in faces
    }


def is_fresh(faces: Complex, v: int) -> bool:
    """The apex v is fresh for the complex if it appears in no face."""
    return all(v not in F for F in faces)


def cone(faces: Complex, v: int) -> Complex:
    """Cone over the complex with apex v (Algorithm C, construction part)."""
    apex_free = set(faces)
    apex_containing = {F | {v} for F in faces}
    return apex_free | apex_containing


def cone_strata(faces: Complex, v: int) -> Tuple[Complex, Complex]:
    """Return the (apex-free, apex-containing) strata of the cone."""
    return set(faces), {F | {v} for F in faces}


def involution_certificate(coned: Complex, v: int) -> bool:
    """Algorithm E: verify the toggle F |-> F XOR {v} is a fixed-point-free,
    sign-reversing involution on the cone -- a certificate that chi-tilde = 0.
    """
    for F in coned:
        G = F ^ frozenset({v})  # symmetric difference toggles apex membership
        if G not in coned:
            return False
        if (F ^ frozenset({v})) ^ frozenset({v}) != F:
            return False
        if (-1) ** (len(G) + 1) != -((-1) ** (len(F) + 1)):
            return False
    return True


# ---------------------------------------------------------------------------
# Spectral bound bookkeeping
# ---------------------------------------------------------------------------

def q_bound(n: int, r: int, t: int) -> int:
    """The extremal bound  q_bd(n, r, t) = t*n - (t-1)*(r+1)."""
    return t * n - (t - 1) * (r + 1)


def q_bound_factored(n: int, r: int, t: int) -> int:
    """Factored form  (t-1)*(n-r-1) + n  (identity qBound_factor)."""
    return (t - 1) * (n - r - 1) + n


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def fmt(face: Face) -> str:
    return "{" + ",".join(map(str, sorted(face))) + "}" if face else "{}"


def demo_reduced_euler_examples() -> None:
    banner("1. Reduced Euler characteristic of basic complexes")

    # Single point: acyclic, chi-tilde = 0.
    point = downward_closure([[0]])
    print(f"point                  chi-tilde = {reduced_euler(point):+d}  (acyclic)")

    # Boundary of a triangle = circle S^1: has a 1-hole, chi-tilde = -1.
    circle = downward_closure([[0, 1], [1, 2], [0, 2]])
    print(f"circle  (triangle bdry) chi-tilde = {reduced_euler(circle):+d}  (1-hole)")

    # Filled triangle (solid 2-simplex): acyclic, chi-tilde = 0.
    disk = downward_closure([[0, 1, 2]])
    print(f"disk    (solid 2-simplex) chi-tilde = {reduced_euler(disk):+d}  (acyclic)")

    # Boundary of a tetrahedron = sphere S^2: has a 2-hole, chi-tilde = +1.
    sphere = downward_closure([[0, 1, 2], [0, 1, 3], [0, 2, 3], [1, 2, 3]])
    print(f"sphere  (tetra bdry)    chi-tilde = {reduced_euler(sphere):+d}  (2-hole)")


def demo_cone_theorem() -> None:
    banner("2. Main theorem: cone over a complex has chi-tilde = 0")

    bases = {
        "circle (triangle bdry)": downward_closure([[0, 1], [1, 2], [0, 2]]),
        "sphere (tetra bdry)": downward_closure(
            [[0, 1, 2], [0, 1, 3], [0, 2, 3], [1, 2, 3]]
        ),
        "two disjoint edges": downward_closure([[0, 1], [2, 3]]),
        "path 0-1-2-3-4": downward_closure([[0, 1], [1, 2], [2, 3], [3, 4]]),
    }
    apex = 99  # a fresh vertex not used by any base above
    for name, base in bases.items():
        assert is_fresh(base, apex)
        C = cone(base, apex)
        chi_base = reduced_euler(base)
        chi_cone = reduced_euler(C)
        af, ac = cone_strata(base, apex)
        disjoint = af.isdisjoint(ac)
        cert = involution_certificate(C, apex)
        print(
            f"{name:24s} chi-tilde(base)={chi_base:+d}  "
            f"chi-tilde(cone)={chi_cone:+d}  "
            f"strata-disjoint={disjoint}  involution-cert={cert}"
        )
        assert chi_cone == 0, "Theorem ASC.reducedEuler_cone violated!"
        assert disjoint, "Prop ASC.cone_faces_disjoint violated!"
        assert cert, "sign-reversing involution certificate failed!"
    print("\nAll cones verified: chi-tilde = 0  (Theorem ASC.reducedEuler_cone).")


def demo_freshness_is_load_bearing() -> None:
    banner("3. Freshness is load-bearing: reusing an existing vertex breaks it")

    base = downward_closure([[0, 1], [1, 2], [0, 2]])  # circle
    stale_apex = 1  # already a vertex of the base -> NOT fresh
    print(f"is_fresh(base, {stale_apex}) = {is_fresh(base, stale_apex)}")
    # Building the 'cone' with a stale apex does not give the clean cancellation.
    C_stale = cone(base, stale_apex)
    af, ac = cone_strata(base, stale_apex)
    print(f"strata disjoint with stale apex? {af.isdisjoint(ac)}")
    print(f"chi-tilde with stale apex = {reduced_euler(C_stale):+d}  "
          f"(theorem does NOT apply; value need not be 0)")


def demo_link_and_codimension() -> None:
    banner("4. Links and codimension t-1")

    # Solid tetrahedron, pure of dimension r = 3 on n = 4 vertices.
    K = downward_closure([[0, 1, 2, 3]])
    print("K = solid tetrahedron  (pure r=3, n=4)")
    for sigma in [frozenset({0}), frozenset({0, 1})]:
        L = link(K, sigma)
        # dimension of the link = max face size - 1
        dim = max((len(F) for F in L), default=0) - 1
        t = 3 - (len(sigma) - 1)  # sigma is an (r-t)-face => t = r - dim(sigma)
        print(
            f"  link of sigma={fmt(sigma)} (an (r-t)-face, t={t}): "
            f"{len(L)} faces, link dim = {dim}  (expected t-1 = {t-1}); "
            f"is_complex={is_complex(L)}, chi-tilde={reduced_euler(L):+d}"
        )


def demo_acyclicity_is_necessary_not_sufficient() -> None:
    banner("5. chi-tilde = 0 is NECESSARY but NOT SUFFICIENT for acyclicity")

    # S^1 wedge nothing has chi=-1 (not zero, correctly flags a hole).
    # Build a complex with holes in two dimensions whose contributions cancel:
    # S^2 (chi-tilde = +1) glued with two circles is fiddly; instead show the
    # cleanest example: a wedge of a 1-sphere and a 2-sphere.
    #   S^1: chi-tilde = -1,  S^2: chi-tilde = +1  => wedge chi-tilde = 0,
    # yet it has H1 = R and H2 = R, so it is NOT acyclic.
    s1 = downward_closure([[0, 1], [1, 2], [0, 2]])            # circle on {0,1,2}
    s2 = downward_closure([[2, 3, 4], [2, 3, 5], [2, 4, 5], [3, 4, 5]])  # sphere sharing vertex 2
    wedge = s1 | s2
    print(f"chi-tilde(S^1) = {reduced_euler(s1):+d}")
    print(f"chi-tilde(S^2) = {reduced_euler(s2):+d}")
    print(f"chi-tilde(S^1 wedge S^2 at vertex 2) = {reduced_euler(wedge):+d}")
    print("  -> chi-tilde = 0 by cancellation, yet the space has holes "
          "in dims 1 and 2: NOT acyclic.")
    print("  This is exactly why we label the cone theorem the NECESSARY "
          "numerical shadow.")


def demo_spectral_bound_identities() -> None:
    banner("6. Spectral bound  q_bd(n,r,t) = t*n - (t-1)*(r+1)  identities")

    print(f"{'n':>3} {'r':>3} {'t':>3} | {'q_bd':>6} {'factored':>9} "
          f"{'d/dn':>5} {'d/dr':>5}")
    print("-" * 44)
    for (n, r, t) in [(6, 2, 1), (6, 2, 2), (8, 3, 2), (10, 4, 3), (12, 5, 3)]:
        q = q_bound(n, r, t)
        qf = q_bound_factored(n, r, t)
        d_n = q_bound(n + 1, r, t) - q_bound(n, r, t)      # expect t
        d_r = q_bound(n, r + 1, t) - q_bound(n, r, t)      # expect -(t-1)
        assert q == qf, "factorization identity failed"
        assert d_n == t, "qBound_succ_n identity failed"
        assert d_r == -(t - 1), "qBound_succ_r identity failed"
        print(f"{n:>3} {r:>3} {t:>3} | {q:>6} {qf:>9} {d_n:>5} {d_r:>5}")
    print("\nVerified: factorization (qBound_factor) and discrete derivatives "
          "(qBound_succ_n = t, qBound_succ_r = -(t-1)).")


def demo_randomized_stress_test(trials: int = 200, seed: int = 12345) -> None:
    banner("7. Randomized stress test of ASC.reducedEuler_cone")

    import random
    rng = random.Random(seed)
    ok = 0
    for _ in range(trials):
        n_facets = rng.randint(1, 4)
        facets = []
        for _ in range(n_facets):
            size = rng.randint(1, 4)
            facets.append(rng.sample(range(8), size))
        base = downward_closure(facets)
        apex = 1000  # always fresh
        C = cone(base, apex)
        if reduced_euler(C) == 0 and involution_certificate(C, apex):
            ok += 1
    print(f"cones with chi-tilde = 0 and valid involution certificate: "
          f"{ok}/{trials}")
    assert ok == trials, "a randomized cone violated the theorem!"
    print("All random cones satisfy the theorem.")


def main() -> None:
    demo_reduced_euler_examples()
    demo_cone_theorem()
    demo_freshness_is_load_bearing()
    demo_link_and_codimension()
    demo_acyclicity_is_necessary_not_sufficient()
    demo_spectral_bound_identities()
    demo_randomized_stress_test()
    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()
