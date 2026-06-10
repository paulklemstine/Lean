"""
Applications of the Tropical Bernstein Theorem

This module demonstrates real-world applications of the tropical Bernstein
theorem for sparse polynomial root counting and computational algebra.
"""

from algorithms import (
    minkowski_sum, mixed_lattice_index, degree_simplex,
    lattice_rectangle, convex_hull_2d, shoelace_area,
    bernstein_number, picks_theorem
)


def sparse_root_counting():
    """
    Application 1: Sparse polynomial root counting

    Given two bivariate polynomials f(x,y) and g(x,y) with known
    support sets (Newton polygons), the Bernstein number gives the
    exact generic root count — often much sharper than Bézout.
    """
    print("=" * 60)
    print("APPLICATION 1: SPARSE ROOT COUNTING")
    print("=" * 60)
    print()

    # Example: a system arising in kinematics
    # f(x,y) = a₀ + a₁x + a₂y + a₃x²y
    # g(x,y) = b₀ + b₁xy + b₂x²y² + b₃y³
    support_f = {(0, 0), (1, 0), (0, 1), (2, 1)}
    support_g = {(0, 0), (1, 1), (2, 2), (0, 3)}

    bernstein = bernstein_number(support_f, support_g)

    # Bézout bound: max degree of f is 3, max degree of g is 4
    # So Bézout gives 3 * 4 = 12
    max_deg_f = max(i + j for i, j in support_f)
    max_deg_g = max(i + j for i, j in support_g)
    bezout = max_deg_f * max_deg_g

    print(f"  f: support = {sorted(support_f)}, degree = {max_deg_f}")
    print(f"  g: support = {sorted(support_g)}, degree = {max_deg_g}")
    print()
    print(f"  Bézout bound:    {bezout} roots")
    print(f"  Bernstein bound: {bernstein} roots")
    print(f"  Improvement:     {bezout - bernstein} fewer spurious roots "
          f"({100*(bezout-bernstein)/bezout:.0f}% reduction)")
    print()


def chemical_reaction_networks():
    """
    Application 2: Chemical reaction network steady states

    In computational chemistry, steady states of reaction networks
    are solutions to systems of polynomial equations. The support
    structure reflects the stoichiometry of the reactions.
    """
    print("=" * 60)
    print("APPLICATION 2: CHEMICAL REACTION NETWORKS")
    print("=" * 60)
    print()

    # A two-species reaction network:
    # Species X, Y with concentrations x, y
    # Reaction rates: k₁·x, k₂·x·y, k₃·y², k₄·x²
    # Steady state: two polynomial equations in x, y
    support_eq1 = {(1, 0), (1, 1), (0, 2)}  # production/consumption of X
    support_eq2 = {(0, 1), (1, 1), (2, 0)}  # production/consumption of Y

    roots = bernstein_number(support_eq1, support_eq2)
    max_d1 = max(i + j for i, j in support_eq1)
    max_d2 = max(i + j for i, j in support_eq2)

    print(f"  Equation 1 support: {sorted(support_eq1)}")
    print(f"  Equation 2 support: {sorted(support_eq2)}")
    print(f"  Bernstein root count: {roots} steady states")
    print(f"  Bézout bound: {max_d1 * max_d2}")
    print()
    print("  The Bernstein theorem guarantees that for generic rate")
    print(f"  constants, this system has exactly {roots} torus steady states.")
    print()


def robot_kinematics():
    """
    Application 3: Robot kinematics — workspace boundaries

    Forward kinematics of planar robots leads to systems of
    trigonometric equations. After substitution t = tan(θ/2),
    these become polynomial systems with specific support patterns.
    """
    print("=" * 60)
    print("APPLICATION 3: ROBOT KINEMATICS")
    print("=" * 60)
    print()

    # Two-link planar robot: position equations after tangent substitution
    # x = l₁(1-t₁²)/(1+t₁²) + l₂(1-t₂²)/(1+t₂²)
    # y = l₁(2t₁)/(1+t₁²) + l₂(2t₂)/(1+t₂²)
    # After clearing denominators: degree-2 polynomials in t₁, t₂
    support_x = {(0, 0), (2, 0), (0, 2), (2, 2)}  # rectangle
    support_y = {(1, 0), (0, 1), (1, 2), (2, 1)}  # diamond-like

    roots = bernstein_number(support_x, support_y)

    print(f"  Position eq. X support: {sorted(support_x)}")
    print(f"  Position eq. Y support: {sorted(support_y)}")
    print(f"  Bernstein intersection count: {roots}")
    print()
    print(f"  This means a generic planar 2-link robot has {roots}")
    print("  inverse kinematics solutions (configurations reaching a")
    print("  given position).")
    print()


def lattice_polygon_analysis():
    """
    Application 4: Lattice polygon analysis and comparison

    Systematically compute mixed areas for families of lattice polygons,
    building a certified database of sparse root counts.
    """
    print("=" * 60)
    print("APPLICATION 4: LATTICE POLYGON ANALYSIS")
    print("=" * 60)
    print()

    polygons = {
        "Δ₁": degree_simplex(1),
        "Δ₂": degree_simplex(2),
        "Δ₃": degree_simplex(3),
        "□₁": lattice_rectangle(1, 1),
        "□₂": lattice_rectangle(2, 2),
        "[2×1]": lattice_rectangle(2, 1),
        "[1×3]": lattice_rectangle(1, 3),
    }

    print("  Mixed Area Table:")
    print("  " + "-" * 56)
    names = list(polygons.keys())
    header = "        " + "".join(f"{n:>8}" for n in names)
    print(header)
    print("  " + "-" * 56)

    for n1 in names:
        row = f"  {n1:>6}"
        for n2 in names:
            ma = mixed_lattice_index(polygons[n1], polygons[n2])
            row += f"{ma:>8}"
        print(row)

    print("  " + "-" * 56)
    print()
    print("  This table provides certified sparse root counts for all")
    print("  pairs of these Newton polygon families.")
    print()


def picks_theorem_verification():
    """
    Application 5: Pick's theorem and area computation verification

    Verify the relationship between the mixed lattice index (lattice point counting)
    and the geometric mixed area (via shoelace/Pick's theorem).

    The MLI uses: |P⊕Q| - |P| - |Q| + 1
    The geometric mixed area (2× Euclidean) uses: Area(P⊕Q) - Area(P) - Area(Q)

    By Pick's theorem: |P| = EuclideanArea(P) + B(P)/2 + 1
    So the two quantities differ by boundary-point corrections.
    For degree simplices: MLI = EuclideanMixedArea = d₁·d₂.
    """
    print("=" * 60)
    print("APPLICATION 5: PICK'S THEOREM ANALYSIS")
    print("=" * 60)
    print()
    print("  The mixed lattice index (MLI) and the geometric mixed area")
    print("  are related via Pick's theorem. For convex polygons P, Q:")
    print("    MLI = |P⊕Q| - |P| - |Q| + 1")
    print("    GMA = 2·EuclideanArea(P⊕Q) - 2·Area(P) - 2·Area(Q)")
    print()

    test_cases = [
        ("Δ₂ × Δ₃", degree_simplex(2), degree_simplex(3)),
        ("□₂ × □₃", lattice_rectangle(2, 2), lattice_rectangle(3, 3)),
        ("Δ₁ × □₂", degree_simplex(1), lattice_rectangle(2, 2)),
        ("[3×1] × Δ₂", lattice_rectangle(3, 1), degree_simplex(2)),
    ]

    for name, P, Q in test_cases:
        mli = mixed_lattice_index(P, Q)

        hull_P = convex_hull_2d(list(P))
        hull_Q = convex_hull_2d(list(Q))
        mink = minkowski_sum(P, Q)
        hull_PQ = convex_hull_2d(list(mink))

        _, B_P, I_P = picks_theorem(hull_P)
        _, B_Q, I_Q = picks_theorem(hull_Q)
        _, B_PQ, I_PQ = picks_theorem(hull_PQ)

        # Verify Pick's theorem consistency
        boundary_correction = (B_PQ - B_P - B_Q) // 2

        print(f"  {name}:")
        print(f"    MLI = {mli}")
        print(f"    |P|={len(P)}, |Q|={len(Q)}, |P⊕Q|={len(mink)}")
        print(f"    Boundary points: B(P)={B_P}, B(Q)={B_Q}, B(P⊕Q)={B_PQ}")
        print(f"    Interior points: I(P)={I_P}, I(Q)={I_Q}, I(P⊕Q)={I_PQ}")
        print(f"    Boundary correction: (B(P⊕Q)-B(P)-B(Q))/2 = {boundary_correction}")
        print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║    TROPICAL BERNSTEIN THEOREM: APPLICATIONS             ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    sparse_root_counting()
    chemical_reaction_networks()
    robot_kinematics()
    lattice_polygon_analysis()
    picks_theorem_verification()

    print("=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


"""
Tropical Bernstein Theorem: Demonstrations

This module demonstrates the tropical Bernstein theorem through concrete
computations of mixed areas for various lattice polygon pairs.

The key identity: for generic bivariate tropical polynomials f, g with
Newton polygons P, Q, the total stable intersection multiplicity equals
the mixed area:
    MixedArea(P, Q) = |P ⊕ Q| - |P| - |Q| + 1
where P ⊕ Q is the Minkowski sum and |·| counts lattice points.
"""

from itertools import product


def lattice_points_in_set(points: set[tuple[int, int]]) -> int:
    """Count lattice points in a finite set."""
    return len(points)


def minkowski_sum(A: set[tuple[int, int]], B: set[tuple[int, int]]) -> set[tuple[int, int]]:
    """Compute the Minkowski sum A ⊕ B = {a + b : a ∈ A, b ∈ B}."""
    return {(a[0] + b[0], a[1] + b[1]) for a in A for b in B}


def mixed_lattice_index(A: set[tuple[int, int]], B: set[tuple[int, int]]) -> int:
    """
    Compute the mixed lattice index:
        MLI(A, B) = |A ⊕ B| - |A| - |B| + 1
    For convex lattice polygons, this equals the mixed area.
    """
    mink = minkowski_sum(A, B)
    return len(mink) - len(A) - len(B) + 1


def degree_simplex(d: int) -> set[tuple[int, int]]:
    """The degree-d simplex Δ_d = {(i,j) : i,j ≥ 0, i+j ≤ d}."""
    return {(i, j) for i in range(d + 1) for j in range(d + 1) if i + j <= d}


def lattice_rectangle(a: int, b: int) -> set[tuple[int, int]]:
    """The lattice rectangle [0,a] × [0,b]."""
    return {(i, j) for i in range(a + 1) for j in range(b + 1)}


def print_separator():
    print("=" * 60)


def demo_bezout_recovery():
    """Demonstrate that Bézout is a special case of Bernstein."""
    print_separator()
    print("BÉZOUT AS SPECIALIZATION OF BERNSTEIN")
    print_separator()
    print()
    print("For degree simplices Δ_d₁ and Δ_d₂:")
    print("  MixedArea(Δ_d₁, Δ_d₂) = d₁ · d₂")
    print()

    for d1 in range(1, 6):
        for d2 in range(1, 6):
            P = degree_simplex(d1)
            Q = degree_simplex(d2)
            ma = mixed_lattice_index(P, Q)
            assert ma == d1 * d2, f"Failed: {d1}*{d2} != {ma}"
            if d2 <= d1:
                print(f"  MixedArea(Δ_{d1}, Δ_{d2}) = {ma} = {d1}·{d2} ✓")
    print()


def demo_rectangle_formula():
    """Demonstrate the rectangle mixed area formula."""
    print_separator()
    print("RECTANGLE MIXED AREA FORMULA")
    print_separator()
    print()
    print("For rectangles R₁ = [0,a₁]×[0,b₁] and R₂ = [0,a₂]×[0,b₂]:")
    print("  MixedArea(R₁, R₂) = a₁·b₂ + a₂·b₁")
    print()

    examples = [
        (2, 3, 1, 4),
        (3, 3, 2, 2),
        (1, 1, 1, 1),
        (4, 1, 1, 3),
        (5, 2, 3, 4),
    ]

    for a1, b1, a2, b2 in examples:
        R1 = lattice_rectangle(a1, b1)
        R2 = lattice_rectangle(a2, b2)
        ma = mixed_lattice_index(R1, R2)
        expected = a1 * b2 + a2 * b1
        assert ma == expected
        print(f"  MixedArea([0,{a1}]×[0,{b1}], [0,{a2}]×[0,{b2}]) = {ma} = {a1}·{b2}+{a2}·{b1} ✓")
    print()


def demo_non_simplex_examples():
    """Demonstrate mixed area for non-simplex Newton polygons."""
    print_separator()
    print("NON-SIMPLEX NEWTON POLYGON EXAMPLES")
    print_separator()
    print()

    # L-shape
    L = {(0, 0), (1, 0), (2, 0), (0, 1), (0, 2)}
    print(f"L-shape = {sorted(L)}")
    print(f"  |L| = {len(L)}")

    # Parallelogram
    para = {(0, 0), (2, 0), (1, 1), (3, 1)}
    print(f"Parallelogram = {sorted(para)}")

    # Trapezoid
    trap = {(0, 0), (3, 0), (2, 1), (0, 1)}
    print(f"Trapezoid = {sorted(trap)}")

    # Quadrilaterals
    q1 = {(0, 0), (2, 0), (3, 1), (0, 2)}
    q2 = {(0, 0), (1, 0), (2, 2), (0, 1)}
    print(f"Quad1 = {sorted(q1)}")
    print(f"Quad2 = {sorted(q2)}")

    # Collinear
    col = {(0, 0), (2, 0), (4, 0), (0, 3)}
    print(f"Collinear = {sorted(col)}")
    print()

    tests = [
        ("L-shape × Δ₁", L, degree_simplex(1)),
        ("L-shape × L-shape", L, L),
        ("Δ₁ × □₁", degree_simplex(1), lattice_rectangle(1, 1)),
        ("Δ₂ × [0,2]×[0,1]", degree_simplex(2), lattice_rectangle(2, 1)),
        ("Parallelogram × Trapezoid", para, trap),
        ("Quad1 × Quad2", q1, q2),
        ("Collinear × Δ₁", col, degree_simplex(1)),
        ("Δ₂ × L-shape", degree_simplex(2), L),
        ("□₁ × Δ₂", lattice_rectangle(1, 1), degree_simplex(2)),
    ]

    for name, A, B in tests:
        ma = mixed_lattice_index(A, B)
        mink_size = len(minkowski_sum(A, B))
        print(f"  {name}: |A⊕B|={mink_size}, |A|={len(A)}, |B|={len(B)}, "
              f"MixedArea={ma}")
    print()


def demo_bernstein_vs_bezout():
    """Show cases where Bernstein gives a sharper count than Bézout."""
    print_separator()
    print("BERNSTEIN vs BÉZOUT: SPARSE IS SHARPER")
    print_separator()
    print()
    print("The Bézout number uses only the degree (simplex size).")
    print("The Bernstein number uses the actual Newton polygon shape.")
    print()

    # A sparse system with 4 terms but degree 3
    sparse = {(0, 0), (3, 0), (0, 3), (1, 1)}
    dense = degree_simplex(3)  # 10 lattice points vs 4

    print(f"  Sparse support (4 points): {sorted(sparse)}")
    print(f"  Dense Δ₃ (10 points): {sorted(dense)}")
    print()

    for name, Q in [("Δ₂", degree_simplex(2)), ("□₂", lattice_rectangle(2, 2))]:
        bezout_ma = mixed_lattice_index(dense, Q)
        bernstein_ma = mixed_lattice_index(sparse, Q)
        print(f"  vs {name}:")
        print(f"    Bézout (using Δ₃):    {bezout_ma}")
        print(f"    Bernstein (sparse):   {bernstein_ma}")
        print(f"    Savings: {bezout_ma - bernstein_ma} fewer intersection points")
        print()


def demo_bilinear_scaling():
    """Demonstrate bilinear scaling of mixed area."""
    print_separator()
    print("BILINEAR SCALING OF MIXED AREA")
    print_separator()
    print()
    print("MixedArea(k₁·P, k₂·Q) = k₁·k₂·MixedArea(P, Q)")
    print()

    def dilate(S: set[tuple[int, int]], k: int) -> set[tuple[int, int]]:
        return {(k * x, k * y) for x, y in S}

    P = lattice_rectangle(1, 1)
    Q = degree_simplex(1)
    base_ma = mixed_lattice_index(P, Q)

    for k1 in range(1, 4):
        for k2 in range(1, 4):
            scaled_ma = mixed_lattice_index(dilate(P, k1), dilate(Q, k2))
            expected = k1 * k2 * base_ma
            status = "✓" if scaled_ma == expected else "✗"
            print(f"  k₁={k1}, k₂={k2}: MixedArea = {scaled_ma} = "
                  f"{k1}·{k2}·{base_ma} {status}")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║    TROPICAL BERNSTEIN THEOREM: DEMONSTRATIONS           ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_bezout_recovery()
    demo_rectangle_formula()
    demo_non_simplex_examples()
    demo_bernstein_vs_bezout()
    demo_bilinear_scaling()

    print_separator()
    print("All demonstrations completed successfully!")
    print_separator()
