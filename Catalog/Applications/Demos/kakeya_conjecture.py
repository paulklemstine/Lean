"""
applications.py — Applications of Finite-Field Kakeya Theory

Demonstrates practical applications of the polynomial method and Kakeya
set theory, including:
1. Error-correcting codes via polynomial evaluation
2. Randomized polynomial identity testing
3. Combinatorial set covering problems
4. Extremal configurations in finite geometry
"""

import itertools
from collections import defaultdict
import math
from algorithms import FiniteField, affine_line_points, direction_classes


def application_polynomial_identity_testing():
    """
    Application 1: Schwartz-Zippel Polynomial Identity Testing

    The Schwartz-Zippel lemma (which we formalized as mvpoly_nonvanishing)
    is the foundation of randomized polynomial identity testing:
    if P ≠ 0 and deg(P) < q, then evaluating P at a random point of F_q^n
    gives P(x) ≠ 0 with probability ≥ 1 - d/q.

    This gives a simple randomized algorithm: to test if P = Q,
    evaluate P - Q at random points.
    """
    print("=" * 60)
    print("APPLICATION 1: Polynomial Identity Testing")
    print("=" * 60)
    print()

    import random
    random.seed(42)

    for p in [7, 11, 13]:
        F = FiniteField(p)
        n = 2

        # Create a nonzero polynomial of degree 3
        # P(x,y) = x^2*y + 2*x + 3
        def poly_P(x, y):
            return (F.mul(F.mul(x, x), y) + F.mul(2, x) + 3) % p

        # Count non-roots
        total = 0
        non_roots = 0
        for x in F.elements:
            for y in F.elements:
                total += 1
                if poly_P(x, y) != 0:
                    non_roots += 1

        prob_nonzero = non_roots / total
        theoretical_lower = 1 - 3 / p  # degree 3, field size p

        print(f"F_{p}^2, degree-3 polynomial:")
        print(f"  Non-root fraction:       {prob_nonzero:.4f}")
        print(f"  Theoretical lower bound: {theoretical_lower:.4f}")
        print(f"  Bound holds:             {prob_nonzero >= theoretical_lower - 1e-10}")
        print()


def application_covering_designs():
    """
    Application 2: Optimal Covering Designs

    Kakeya sets provide solutions to covering problems:
    what is the minimum number of points needed to intersect
    every line in every direction?

    This connects to combinatorial design theory and coding theory.
    """
    print("=" * 60)
    print("APPLICATION 2: Covering Designs from Kakeya Sets")
    print("=" * 60)
    print()

    for p in [2, 3, 5]:
        F = FiniteField(p)
        n = 2
        q = p

        dirs = direction_classes(F, n)
        num_dirs = len(dirs)

        # For each direction class, count how many lines exist
        lines_per_dir = {}
        for v in dirs:
            lines = set()
            for base in itertools.product(F.elements, repeat=n):
                line = affine_line_points(F, base, v)
                lines.add(line)
            lines_per_dir[v] = len(lines)

        total_lines = sum(lines_per_dir.values())
        total_points = q**n

        print(f"F_{q}^{n}:")
        print(f"  Direction classes:     {num_dirs}")
        print(f"  Lines per direction:   {lines_per_dir[dirs[0]]}")
        print(f"  Total lines:           {total_lines}")
        print(f"  Total points:          {total_points}")
        print(f"  Dvir bound:            {q**n / math.factorial(n):.1f}")
        print()


def application_incidence_energy_analysis():
    """
    Application 3: Incidence Energy Analysis

    Analyze the multiplicity energy E = Σ m(x)² for various line
    configurations. The energy controls the Cauchy-Schwarz union
    size lower bound: |P| ≥ (|L|·q)² / E.

    High energy means many points lie on many lines (high overlap).
    Low energy means the lines spread out efficiently.
    """
    print("=" * 60)
    print("APPLICATION 3: Incidence Energy Analysis")
    print("=" * 60)
    print()

    for p in [3, 5, 7]:
        F = FiniteField(p)
        n = 2
        q = p

        dirs = direction_classes(F, n)

        # Configuration 1: All lines through origin
        lines_origin = [(tuple(0 for _ in range(n)), v) for v in dirs]

        # Configuration 2: Lines with spread-out base points
        lines_spread = []
        for i, v in enumerate(dirs):
            base = tuple((i * j) % q for j in range(n))
            lines_spread.append((base, v))

        for name, lines in [("Through origin", lines_origin),
                            ("Spread bases", lines_spread)]:
            mults = defaultdict(int)
            for base, direction in lines:
                for point in affine_line_points(F, base, direction):
                    mults[point] += 1

            total_inc = sum(mults.values())
            energy = sum(m * m for m in mults.values())
            union_size = len(mults)
            max_mult = max(mults.values())

            # Cauchy-Schwarz bound
            cs_bound = (total_inc ** 2) / energy if energy > 0 else 0

            print(f"F_{q}^{n}, {name} ({len(lines)} lines):")
            print(f"  Union size |P|:        {union_size}")
            print(f"  Total incidences:      {total_inc}")
            print(f"  Energy Σm²:            {energy}")
            print(f"  Max multiplicity:      {max_mult}")
            print(f"  Cauchy-Schwarz bound:  {cs_bound:.1f}")
            print()


def application_extremal_kakeya():
    """
    Application 4: Extremal Kakeya Configurations

    Search for minimal Kakeya sets and analyze their structure.
    These extremal configurations reveal algebraic structure
    that connects to the polynomial method.
    """
    print("=" * 60)
    print("APPLICATION 4: Extremal Kakeya Configurations")
    print("=" * 60)
    print()

    for p in [2, 3]:
        F = FiniteField(p)
        n = 2
        q = p
        total_points = q ** n

        dirs = direction_classes(F, n)

        # Exhaustive search for minimum Kakeya set (only feasible for small q)
        if q <= 3:
            min_size = total_points
            min_sets = []

            # Generate all subsets of F_q^n of size >= Dvir bound
            all_points = list(itertools.product(F.elements, repeat=n))
            dvir = math.ceil(q**n / math.factorial(n))

            for size in range(dvir, total_points + 1):
                if size > min_size:
                    break
                found_at_size = False
                for subset in itertools.combinations(all_points, size):
                    K = set(subset)
                    # Check Kakeya property
                    is_kakeya = True
                    for v in dirs:
                        has_line = False
                        for base in all_points:
                            line = affine_line_points(F, base, v)
                            if line.issubset(K):
                                has_line = True
                                break
                        if not has_line:
                            is_kakeya = False
                            break
                    if is_kakeya:
                        if size < min_size:
                            min_size = size
                            min_sets = [K]
                        elif size == min_size:
                            min_sets.append(K)
                        found_at_size = True
                if found_at_size:
                    break

            print(f"F_{q}^{n}: Exhaustive search")
            print(f"  Direction classes:       {len(dirs)}")
            print(f"  Dvir lower bound:        {dvir}")
            print(f"  Minimum Kakeya size:     {min_size}")
            print(f"  Number of minimizers:    {len(min_sets)}")
            if min_sets:
                print(f"  Example minimizer:       {sorted(min_sets[0])}")
            print()


if __name__ == "__main__":
    application_polynomial_identity_testing()
    application_covering_designs()
    application_incidence_energy_analysis()
    application_extremal_kakeya()
    print("\nAll applications demonstrated successfully!")


"""
demo.py — Finite-Field Kakeya Sets: Computational Demonstrations

This module demonstrates key phenomena from the finite-field Kakeya conjecture
through concrete numerical examples. It constructs Kakeya sets over small finite
fields, measures their sizes, and verifies the Dvir lower bound |K| >= q^n / n!.
"""

import itertools
from collections import defaultdict


def make_field(p):
    """Create arithmetic operations for F_p (prime field)."""
    return {
        'add': lambda a, b: (a + b) % p,
        'mul': lambda a, b: (a * b) % p,
        'sub': lambda a, b: (a - b) % p,
        'inv': lambda a: pow(a, p - 2, p) if a != 0 else None,
        'neg': lambda a: (-a) % p,
        'elements': list(range(p)),
        'q': p,
    }


def affine_line(F, base, direction):
    """Compute the set of points on the affine line base + t * direction in F^n."""
    q = F['q']
    n = len(base)
    points = set()
    for t in F['elements']:
        point = tuple(F['add'](base[i], F['mul'](t, direction[i])) for i in range(n))
        points.add(point)
    return points


def is_nonzero(v):
    """Check if a vector is nonzero."""
    return any(x != 0 for x in v)


def all_nonzero_directions(F, n):
    """Generate all nonzero vectors in F^n."""
    return [v for v in itertools.product(F['elements'], repeat=n) if is_nonzero(v)]


def construct_kakeya_set(F, n):
    """
    Construct a Kakeya set in F_q^n by choosing a line for each nonzero direction.
    Uses a greedy approach to try to minimize the set size.
    """
    directions = all_nonzero_directions(F, n)
    kakeya_set = set()

    for v in directions:
        # Try each base point and pick the one that adds the fewest new points
        best_base = None
        best_new = None
        for base in itertools.product(F['elements'], repeat=n):
            line = affine_line(F, base, v)
            new_points = line - kakeya_set
            if best_new is None or len(new_points) < len(best_new):
                best_base = base
                best_new = new_points
        kakeya_set.update(affine_line(F, best_base, v))

    return kakeya_set


def construct_kakeya_random(F, n, base_choice=None):
    """
    Construct a Kakeya set by choosing base = 0 for all directions.
    This is a simple construction that may not be minimal.
    """
    if base_choice is None:
        base_choice = tuple(0 for _ in range(n))

    directions = all_nonzero_directions(F, n)
    kakeya_set = set()
    for v in directions:
        line = affine_line(F, base_choice, v)
        kakeya_set.update(line)
    return kakeya_set


def verify_kakeya(F, n, K):
    """Verify that K is indeed a Kakeya set."""
    directions = all_nonzero_directions(F, n)
    for v in directions:
        found = False
        for base in itertools.product(F['elements'], repeat=n):
            line = affine_line(F, base, v)
            if line.issubset(K):
                found = True
                break
        if not found:
            return False
    return True


def dvir_lower_bound(q, n):
    """Compute the Dvir lower bound q^n / n!."""
    import math
    return q**n / math.factorial(n)


def compute_incidences(F, n, lines):
    """
    Compute incidence data: for each point, count how many lines pass through it.
    Returns (point_multiplicities, total_incidences).
    """
    multiplicities = defaultdict(int)
    for base, direction in lines:
        for point in affine_line(F, base, direction):
            multiplicities[point] += 1
    total = sum(multiplicities.values())
    return dict(multiplicities), total


def demo_kakeya_sizes():
    """Demonstrate Kakeya set sizes for small parameters."""
    print("=" * 60)
    print("DEMO 1: Kakeya Set Sizes vs Dvir Lower Bound")
    print("=" * 60)
    print()

    results = []
    for p in [2, 3, 5]:
        for n_dim in [2, 3]:
            F = make_field(p)
            q = F['q']

            # Simple construction (all lines through origin)
            K_simple = construct_kakeya_random(F, n_dim)

            # Greedy construction
            if q <= 3 or n_dim <= 2:
                K_greedy = construct_kakeya_set(F, n_dim)
            else:
                K_greedy = K_simple  # Skip greedy for large cases

            lb = dvir_lower_bound(q, n_dim)
            total = q**n_dim

            print(f"F_{q}^{n_dim}:")
            print(f"  Total points:          {total}")
            print(f"  Dvir lower bound:      {lb:.1f}")
            print(f"  Simple Kakeya |K|:     {len(K_simple)}")
            if K_greedy is not K_simple:
                print(f"  Greedy Kakeya |K|:     {len(K_greedy)}")
            print(f"  Is valid (simple):     {verify_kakeya(F, n_dim, K_simple)}")
            print(f"  Ratio |K|/q^n:         {len(K_simple)/total:.3f}")
            print()
            results.append((q, n_dim, len(K_simple), lb, total))

    return results


def demo_incidence_identity():
    """Demonstrate the incidence double-counting identity."""
    print("=" * 60)
    print("DEMO 2: Incidence Double-Counting Identity")
    print("=" * 60)
    print()

    for p in [2, 3, 5]:
        F = make_field(p)
        q = F['q']
        n = 2

        # Create lines with distinct directions
        directions = all_nonzero_directions(F, n)
        lines = []
        for v in directions:
            base = tuple(0 for _ in range(n))
            lines.append((base, v))

        _, total_incidences = compute_incidences(F, n, lines)
        expected = len(lines) * q

        print(f"F_{q}^{n}, {len(lines)} lines:")
        print(f"  Total incidences:      {total_incidences}")
        print(f"  Expected (|L| * q):    {expected}")
        print(f"  Match:                 {total_incidences == expected}")
        print()


def demo_polynomial_vanishing():
    """Demonstrate that a polynomial of degree < q vanishing on all of F_q is zero."""
    print("=" * 60)
    print("DEMO 3: Polynomial Vanishing over Finite Fields")
    print("=" * 60)
    print()

    for p in [3, 5, 7]:
        F = make_field(p)
        q = F['q']

        # Test: polynomial of degree < q vanishing on all of F_q
        # Use Lagrange interpolation to find the unique polynomial
        # that vanishes on all of F_q
        # p(x) = prod_{a in F_q} (x - a) has degree q
        # Any polynomial of degree < q vanishing on all F_q must be 0

        # Construct random polynomial of degree < q
        import random
        random.seed(42)
        coeffs = [random.randint(0, p-1) for _ in range(q - 1)]

        def eval_poly(coeffs, x):
            result = 0
            for i, c in enumerate(coeffs):
                result = F['add'](result, F['mul'](c, pow(x, i, p)))
            return result

        # Check if it vanishes everywhere
        all_zero = all(eval_poly(coeffs, x) == 0 for x in F['elements'])
        is_zero_poly = all(c == 0 for c in coeffs)

        print(f"F_{q}: Random poly of degree < {q}")
        print(f"  Coefficients: {coeffs}")
        print(f"  Vanishes on all F_{q}: {all_zero}")
        print(f"  Is zero polynomial:    {is_zero_poly}")
        if all_zero and not is_zero_poly:
            print(f"  ERROR: Non-zero poly vanishes everywhere!")
        elif all_zero:
            print(f"  Consistent: zero poly vanishes everywhere")
        else:
            print(f"  Consistent: non-zero poly has non-roots")
        print()


def demo_line_intersection():
    """Demonstrate that lines with distinct directions intersect in at most one point."""
    print("=" * 60)
    print("DEMO 4: Line Intersection Bounds")
    print("=" * 60)
    print()

    for p in [3, 5, 7]:
        F = make_field(p)
        q = F['q']
        n = 2

        directions = all_nonzero_directions(F, n)
        max_intersection = 0
        total_pairs = 0
        single_point_count = 0

        for i, v1 in enumerate(directions):
            for v2 in directions[i+1:]:
                if v1 == v2:
                    continue
                line1 = affine_line(F, (0,) * n, v1)
                line2 = affine_line(F, (1, 0), v2)
                intersection = line1 & line2
                max_intersection = max(max_intersection, len(intersection))
                total_pairs += 1
                if len(intersection) == 1:
                    single_point_count += 1

        print(f"F_{q}^{n}: {total_pairs} line pairs tested")
        print(f"  Max intersection size: {max_intersection}")
        print(f"  Single-point intersections: {single_point_count}")
        print()


def demo_ascending_factorial():
    """Demonstrate the ascending factorial inequality q^n <= q(q+1)...(q+n-1)."""
    print("=" * 60)
    print("DEMO 5: Ascending Factorial Inequality")
    print("=" * 60)
    print()

    for q in [2, 3, 5, 7, 11]:
        for n in [1, 2, 3, 4, 5]:
            asc_fact = 1
            for i in range(n):
                asc_fact *= (q + i)
            power = q ** n
            print(f"  q={q}, n={n}: q^n = {power:>6d}, "
                  f"q(q+1)...(q+n-1) = {asc_fact:>8d}, "
                  f"ratio = {asc_fact/power:.2f}")
        print()


if __name__ == "__main__":
    demo_kakeya_sizes()
    demo_incidence_identity()
    demo_polynomial_vanishing()
    demo_line_intersection()
    demo_ascending_factorial()
    print("\nAll demos completed successfully!")
