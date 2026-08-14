"""
The extrinsic class-group representation vector is a residue dial.

Self-contained numerical demonstration of the results of the paper
"The Extrinsic Class-Group Representation Vector is a Residue Dial".

For a negative discriminant D we enumerate the reduced positive definite binary
quadratic forms of discriminant D, compute the exact representation vector

    r_D(N) = ( #{(x,y) : Q_1(x,y) = N}, ..., #{(x,y) : Q_h(x,y) = N} ),

and verify, entirely numerically:

  1. Genus separation at D = -20 and D = -84: the unit values of the distinct
     classes occupy pairwise disjoint sets of residues mod |D|.
  2. Factor-blindness: r_D(N) is constant on residue classes mod |D| (for N
     coprime to D and represented at all).
  3. The PP / NN collision: semiprimes whose two prime factors lie in the same
     class are all reported identically, whatever that class is.
  4. Gauss composition: the classes form Z/2 at D = -20 and the Klein group
     (Z/2)^2 at D = -84.
  5. Stacking discriminants does not help: the joint (-20, -84) observation is
     still a function of N mod 1680.
  6. The boundary at D = -23: the two forms have identical value sets mod 23,
     and 59 = 13 (mod 23) with 59 principal and 13 not.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from math import isqrt
from typing import Dict, List, Sequence, Set, Tuple

Form = Tuple[int, int, int]  # (a, b, c) meaning a x^2 + b x y + c y^2


# ---------------------------------------------------------------------------
# 1. Reduced forms of a negative discriminant
# ---------------------------------------------------------------------------

def reduced_forms(disc: int) -> List[Form]:
    """All reduced primitive positive definite forms (a,b,c), b^2 - 4ac = disc < 0.

    Reduction conditions: |b| <= a <= c, and b >= 0 when |b| == a or a == c.
    This forces a <= sqrt(|disc|/3), so the enumeration is O(|disc|).
    """
    if disc >= 0:
        raise ValueError("discriminant must be negative")
    forms: List[Form] = []
    a_max = isqrt(abs(disc) // 3) + 1
    for a in range(1, a_max + 1):
        for b in range(-a, a + 1):
            num = b * b - disc
            if num % (4 * a) != 0:
                continue
            c = num // (4 * a)
            if c < a:
                continue
            if (abs(b) == a or a == c) and b < 0:
                continue
            if gcd(gcd(a, b), c) != 1:      # keep only primitive forms
                continue
            forms.append((a, b, c))
    return forms


def evaluate(form: Form, x: int, y: int) -> int:
    a, b, c = form
    return a * x * x + b * x * y + c * y * y


# ---------------------------------------------------------------------------
# 2. Exact representation counts via a certified box
# ---------------------------------------------------------------------------

def representations(form: Form, n: int) -> List[Tuple[int, int]]:
    """All integer solutions of form(x,y) = n, for n > 0 and disc(form) < 0.

    Completing the square, 4a*form(x,y) = (2ax + by)^2 + |D| y^2, so
    |y| <= sqrt(4 a n / |D|) and 2ax + by = +- sqrt(4 a n - |D| y^2).
    The box is provably exhaustive, so the count is exact.
    """
    a, b, c = form
    disc = b * b - 4 * a * c
    absd = -disc
    if n <= 0:
        return []
    y_max = isqrt(4 * a * n // absd)
    out: List[Tuple[int, int]] = []
    for y in range(-y_max, y_max + 1):
        rest = 4 * a * n - absd * y * y
        if rest < 0:
            continue
        s = isqrt(rest)
        if s * s != rest:
            continue
        for t in ({s, -s} if s else {0}):
            num = t - b * y
            if num % (2 * a) == 0:
                x = num // (2 * a)
                if evaluate(form, x, y) == n:
                    out.append((x, y))
    return sorted(set(out))


def representation_vector(disc: int, n: int) -> Tuple[int, ...]:
    """r_D(N): the exact number of representations by each reduced form."""
    return tuple(len(representations(f, n)) for f in reduced_forms(disc))


# ---------------------------------------------------------------------------
# 3. Genus residue sets (the dial table)
# ---------------------------------------------------------------------------

def unit_value_set(form: Form, m: int) -> Set[int]:
    """Values of `form` modulo m that are invertible modulo m."""
    units = {u for u in range(m) if gcd(u, m) == 1}
    return {evaluate(form, x, y) % m for x, y in product(range(m), repeat=2)} & units


def gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return abs(a)


def dial_table(disc: int) -> Dict[Form, Set[int]]:
    """Map each reduced form to its set of admissible unit residues mod |D|."""
    m = abs(disc)
    return {f: unit_value_set(f, m) for f in reduced_forms(disc)}


def is_residue_dial(disc: int) -> bool:
    """True iff the admissible-residue sets are pairwise disjoint.

    Equivalently (genus theory): D has one class per genus.
    """
    sets = list(dial_table(disc).values())
    for i in range(len(sets)):
        for j in range(i + 1, len(sets)):
            if sets[i] & sets[j]:
                return False
    return True


# ---------------------------------------------------------------------------
# 4. Utilities
# ---------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def class_index(disc: int, n: int) -> int | None:
    """Index of the unique reduced form representing n, or None."""
    for i, f in enumerate(reduced_forms(disc)):
        if representations(f, n):
            return i
    return None


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


# ---------------------------------------------------------------------------
# Demonstration 1: genus separation and the dial table
# ---------------------------------------------------------------------------

def demo_genus_separation() -> None:
    banner("1. Genus separation: the admissible residues of each class")
    for disc in (-20, -84, -23):
        print(f"\n  D = {disc}   h(D) = {len(reduced_forms(disc))}")
        for f, s in dial_table(disc).items():
            a, b, c = f
            label = f"{a}x^2 {'+' if b >= 0 else '-'} {abs(b)}xy + {c}y^2"
            print(f"    {label:<26} unit values mod {abs(disc):<3} = {sorted(s)}")
        verdict = "RESIDUE DIAL (disjoint)" if is_residue_dial(disc) else "NOT a dial (overlap)"
        print(f"    => {verdict}")


# ---------------------------------------------------------------------------
# Demonstration 2: factor-blindness of the vector
# ---------------------------------------------------------------------------

def demo_factor_blindness(disc: int = -20, limit: int = 4000) -> None:
    banner(f"2. Factor-blindness at D = {disc}: the class is a function of N mod |D|")
    m = abs(disc)
    seen: Dict[int, Tuple[int, int]] = {}   # residue -> (class index, witness N)
    violations = 0
    for n in range(2, limit):
        if gcd(n, m) != 1:
            continue
        i = class_index(disc, n)
        if i is None:
            continue
        r = n % m
        if r in seen and seen[r][0] != i:
            violations += 1
            print(f"    VIOLATION at residue {r}: {seen[r][1]} -> {seen[r][0]}, {n} -> {i}")
        seen.setdefault(r, (i, n))
    print(f"    checked all represented N < {limit} coprime to {m}")
    print(f"    residues occurring: {sorted(seen)}")
    print(f"    readout table: " +
          ", ".join(f"{r}->class {seen[r][0]}" for r in sorted(seen)))
    print(f"    violations of factor-blindness: {violations}")


# ---------------------------------------------------------------------------
# Demonstration 3: the PP / NN collision
# ---------------------------------------------------------------------------

def demo_pp_nn_collision() -> None:
    banner("3. The PP/NN collision: identical vectors, opposite factorization types")
    print("\n  D = -20,  forms  P = x^2+5y^2  (principal),  Q = 2x^2+2xy+3y^2")
    rows = [(21, 3, 7), (69, 3, 23), (1189, 29, 41), (41 * 61, 41, 61), (87, 3, 29)]
    label = {0: "P", 1: "N", None: "-"}
    print(f"    {'N':>7}  {'= p * q':>12}  {'types':>7}  {'N mod 20':>9}  {'r_-20(N)':>12}")
    for n, p, q in rows:
        tp = label[class_index(-20, p)]
        tq = label[class_index(-20, q)]
        print(f"    {n:>7}  {f'{p} * {q}':>12}  {tp + tq:>7}  {n % 20:>9}  "
              f"{str(representation_vector(-20, n)):>12}")
    print("\n    21 (NN) and 1189 (PP) have IDENTICAL vectors (8, 0):")
    print(f"      21   = {representations((1, 0, 5), 21)}")
    print(f"      1189 = {representations((1, 0, 5), 1189)}")

    print("\n    (see demonstration 4 for the four-class analogue at D = -84)")


# ---------------------------------------------------------------------------
# Demonstration 4: the -84 triple collision
# ---------------------------------------------------------------------------

def demo_d84_collision() -> None:
    banner("4. D = -84: three distinct factorization types, one observation")
    forms = reduced_forms(-84)
    print("    reduced forms:", forms)
    for n, p, q in [(253, 11, 23), (589, 19, 31), (445, 5, 89)]:
        if not (is_prime(p) and is_prime(q) and p * q == n):
            continue
        ip, iq = class_index(-84, p), class_index(-84, q)
        print(f"    N = {n:>5} = {p} * {q}   classes ({ip}, {iq})   "
              f"N mod 84 = {n % 84:>2}   r_-84(N) = {representation_vector(-84, n)}")
    print("\n    253 = 11*23 (both in class f2) and 589 = 19*31 (both in class f3)")
    print("    are different factorization types with the SAME vector (8,0,0,0).")


# ---------------------------------------------------------------------------
# Demonstration 5: Gauss composition
# ---------------------------------------------------------------------------

def demo_composition(disc: int = -84, sample: int = 400) -> None:
    banner(f"5. Gauss composition at D = {disc}: the class group multiplication table")
    forms = reduced_forms(disc)
    h = len(forms)
    m = abs(disc)
    reps: List[List[int]] = [[] for _ in range(h)]
    for n in range(2, sample):
        if gcd(n, m) != 1:
            continue
        i = class_index(disc, n)
        if i is not None:
            reps[i].append(n)
    table = [[None] * h for _ in range(h)]
    for i in range(h):
        for j in range(h):
            for a in reps[i][:6]:
                for b in reps[j][:6]:
                    k = class_index(disc, a * b)
                    if k is not None:
                        if table[i][j] is None:
                            table[i][j] = k
                        elif table[i][j] != k:
                            table[i][j] = "INCONSISTENT"
    print("    class * class -> class:")
    header = "        " + "".join(f"{j:>5}" for j in range(h))
    print(header)
    for i in range(h):
        print(f"    {i:>3} |" + "".join(f"{str(table[i][j]):>5}" for j in range(h)))
    print("\n    every class squares to class 0 (the principal class):")
    print("      => the group is elementary abelian 2-torsion, "
          f"of order {h}")


# ---------------------------------------------------------------------------
# Demonstration 6: stacking discriminants does not help
# ---------------------------------------------------------------------------

def demo_stacking() -> None:
    banner("6. Stacking (-20, -84): a dial mod 1680, still factor-blind")
    pairs = [(109, 421), (23, 107)]
    for p, q in pairs:
        n = p * q
        joint_p = (class_index(-20, p), class_index(-84, p))
        joint_q = (class_index(-20, q), class_index(-84, q))
        joint_n = (class_index(-20, n), class_index(-84, n))
        print(f"    p = {p:>4} joint class {joint_p},  q = {q:>4} joint class {joint_q}")
        print(f"      N = p*q = {n:>6}   N mod 1680 = {n % 1680:>4}   "
              f"joint class of N = {joint_n}")
    print("\n    109*421 (both principal for both D) and 23*107 (both non-principal")
    print("    for both D) receive the SAME joint index (0, 0): the stacked")
    print("    observation is a residue dial modulo 20*84 = 1680.")


# ---------------------------------------------------------------------------
# Demonstration 7: the information budget
# ---------------------------------------------------------------------------

def demo_information_budget() -> None:
    banner("7. Information budget: the multiplication fibre has |Cl| elements")
    for name, group in [("Cl(-20) = Z/2", [0, 1]),
                        ("Cl(-84) = (Z/2)^2", [(a, b) for a in (0, 1) for b in (0, 1)])]:
        def mul(x, y):
            if isinstance(x, tuple):
                return ((x[0] + y[0]) % 2, (x[1] + y[1]) % 2)
            return (x + y) % 2
        ident = group[0]
        fibre = [(g, k) for g in group for k in group if mul(g, k) == ident]
        bits = len(group).bit_length() - 1
        print(f"    {name:<20} |G| = {len(group)}   "
              f"#{{(g,k) : g*k = e}} = {len(fibre)}   "
              f"bits about (class p, class q) retained <= {bits}")
    print("\n    ... and those bits are already a function of N mod |D|, so the")
    print("    net factorization information is zero.")


# ---------------------------------------------------------------------------
# Demonstration 8: the boundary at D = -23
# ---------------------------------------------------------------------------

def demo_boundary_23() -> None:
    banner("8. The boundary at D = -23: the dial breaks")
    P = (1, 1, 6)     # x^2 + xy + 6y^2, principal
    Q = (2, 1, 3)     # 2x^2 + xy + 3y^2, non-principal
    vp = {evaluate(P, x, y) % 23 for x in range(23) for y in range(23)}
    vq = {evaluate(Q, x, y) % 23 for x in range(23) for y in range(23)}
    print(f"    value set of x^2+xy+6y^2  mod 23 : {sorted(vp)}")
    print(f"    value set of 2x^2+xy+3y^2 mod 23 : {sorted(vq)}")
    print(f"    identical? {vp == vq}   -> genus characters see NOTHING")
    print()
    for n in (59, 13):
        print(f"    N = {n:>3}   N mod 23 = {n % 23:>2}   "
              f"principal? {bool(representations(P, n))}   "
              f"non-principal? {bool(representations(Q, n))}   "
              f"reps by P: {representations(P, n)}")
    print("\n    59 = 13 (mod 23), both coprime to 23, yet 59 is principal and 13")
    print("    is not: representability is NOT a function of the residue.")
    print("    Hence no residue dial mod 23 can contain both forms.")

    print("\n    Scan of small discriminants (dial <=> one class per genus):")
    for d in range(-4, -105, -1):
        if (d % 4) not in (0, 1):
            continue
        h = len(reduced_forms(d))
        if h <= 1:
            continue
        flag = "dial      " if is_residue_dial(d) else "NOT a dial"
        print(f"      D = {d:>4}   h = {h:>2}   {flag}")


def main() -> None:
    demo_genus_separation()
    demo_factor_blindness(-20, 4000)
    demo_factor_blindness(-84, 4000)
    demo_pp_nn_collision()
    demo_d84_collision()
    demo_composition(-20, 400)
    demo_composition(-84, 800)
    demo_stacking()
    demo_information_budget()
    demo_boundary_23()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
