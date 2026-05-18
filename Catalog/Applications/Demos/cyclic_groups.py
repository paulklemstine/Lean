#!/usr/bin/env python3
"""
Applications of Cyclotomic Subfield Theory

Demonstrates real-world applications:
1. Cryptographic parameter selection (safe primes, embedding degrees)
2. Regular polygon constructibility
3. Quadratic reciprocity via cyclotomic subfields
4. Gauss period computation
"""

from algorithms import (
    is_prime,
    primitive_root,
    divisors,
    factorize,
    euler_totient,
    subgroups_of_units_mod_p,
    cyclotomic_subfield_lattice,
)
import math


# ─────────────────────────────────────────────────
# Application 1: Cryptographic Parameter Selection
# ─────────────────────────────────────────────────


def pohlig_hellman_complexity(p: int) -> dict:
    """Analyze DLP hardness for the group (Z/pZ)*.

    The Pohlig-Hellman algorithm reduces DLP in a group of order n
    to DLP in subgroups of prime-power order. The overall complexity
    is dominated by the largest prime factor of n = p-1.

    Args:
        p: A prime number.

    Returns:
        Dictionary with security analysis.
    """
    n = p - 1
    factors = factorize(n)
    largest_prime = max(factors.keys())
    largest_power = largest_prime ** factors[largest_prime]

    # Baby-step giant-step complexity for each prime factor
    bsgs_costs = {}
    for q, e in factors.items():
        bsgs_costs[q] = int(math.isqrt(q**e)) + 1

    return {
        "p": p,
        "group_order": n,
        "factorization": factors,
        "largest_prime_factor": largest_prime,
        "num_subgroups": len(divisors(n)),
        "bsgs_costs": bsgs_costs,
        "effective_security_bits": math.log2(largest_prime) / 2 if largest_prime > 1 else 0,
        "is_safe_prime": is_prime(n // 2),
    }


def find_safe_primes(limit: int) -> list:
    """Find safe primes up to limit.

    A safe prime p is one where (p-1)/2 is also prime.
    These maximize DLP hardness.

    >>> find_safe_primes(50)
    [5, 7, 11, 23, 47]
    """
    result = []
    for p in range(3, limit + 1):
        if is_prime(p) and is_prime((p - 1) // 2):
            result.append(p)
    return result


def embedding_degree(p: int, q: int) -> int:
    """Compute the embedding degree of an elliptic curve group of order q in F_p.

    The embedding degree k is the smallest positive integer such that
    q | (p^k - 1). This determines the security of pairing-based cryptography.

    In terms of cyclotomic fields: k is the multiplicative order of p mod q.

    >>> embedding_degree(7, 5)  # 5 | (7^4 - 1) = 2400
    4
    """
    if q <= 1:
        return 1
    pk = p % q
    for k in range(1, q + 1):
        if pk == 1:
            return k
        pk = (pk * p) % q
    return q


# ─────────────────────────────────────────────────
# Application 2: Regular Polygon Constructibility
# ─────────────────────────────────────────────────


def is_constructible_polygon(n: int) -> bool:
    """Determine if a regular n-gon is constructible by ruler and compass.

    A regular n-gon is constructible iff n = 2^a * p1 * p2 * ... * pk
    where p1, ..., pk are distinct Fermat primes (primes of the form 2^(2^j) + 1).

    >>> is_constructible_polygon(17)
    True
    >>> is_constructible_polygon(7)
    False
    >>> is_constructible_polygon(15)
    True
    """
    if n <= 2:
        return n == 2

    # Remove factors of 2
    while n % 2 == 0:
        n //= 2

    if n == 1:
        return True

    # Remaining factors must be distinct Fermat primes
    fermat_primes = {3, 5, 17, 257, 65537}

    factors = factorize(n)
    for p, e in factors.items():
        if p not in fermat_primes or e > 1:
            return False
    return True


def constructibility_analysis(n: int) -> dict:
    """Analyze constructibility of regular n-gon via cyclotomic subfields.

    If n = p is prime, constructibility requires p-1 = 2^k.
    Our subfield theorem shows: for each divisor d of p-1,
    there exists a unique degree-d subfield. Constructibility
    requires all these degrees to be powers of 2.

    >>> constructibility_analysis(17)['constructible']
    True
    >>> constructibility_analysis(7)['constructible']
    False
    """
    result = {
        "n": n,
        "constructible": is_constructible_polygon(n),
    }

    if is_prime(n):
        phi = n - 1
        factors = factorize(phi)
        divs = divisors(phi)
        all_2_power = all(d == 1 or (d & (d - 1)) == 0 for d in divs)

        result.update(
            {
                "is_prime": True,
                "p_minus_1": phi,
                "factorization": factors,
                "subfield_degrees": divs,
                "all_degrees_2_power": all_2_power,
                "explanation": (
                    f"p-1 = {phi} = {'·'.join(f'{p}^{e}' if e > 1 else str(p) for p, e in sorted(factors.items()))}. "
                    + (
                        "All subfield degrees are powers of 2, so the polygon is constructible."
                        if all_2_power
                        else "Not all subfield degrees are powers of 2, so the polygon is NOT constructible."
                    )
                ),
            }
        )
    else:
        result["is_prime"] = False

    return result


# ─────────────────────────────────────────────────
# Application 3: Quadratic Reciprocity
# ─────────────────────────────────────────────────


def legendre_symbol(a: int, p: int) -> int:
    """Compute the Legendre symbol (a/p) for odd prime p.

    (a/p) = a^((p-1)/2) mod p, with values in {-1, 0, 1}.

    >>> legendre_symbol(2, 7)
    1
    >>> legendre_symbol(3, 7)
    -1
    """
    if a % p == 0:
        return 0
    result = pow(a, (p - 1) // 2, p)
    return result if result <= 1 else result - p


def quadratic_subfield_discriminant(p: int) -> int:
    """Compute the discriminant of the unique quadratic subfield of Q(ζ_p).

    For odd prime p, the quadratic subfield is Q(√p*) where
    p* = (-1)^((p-1)/2) · p.

    This connects to quadratic reciprocity: (q/p) = (p*/q) for odd primes q ≠ p.

    >>> quadratic_subfield_discriminant(5)
    5
    >>> quadratic_subfield_discriminant(7)
    -7
    >>> quadratic_subfield_discriminant(13)
    13
    """
    return p if (p - 1) // 2 % 2 == 0 else -p


def verify_quadratic_reciprocity(p: int, q: int) -> dict:
    """Verify quadratic reciprocity for odd primes p, q via cyclotomic subfields.

    The quadratic subfield of Q(ζ_p) has discriminant p*.
    Quadratic reciprocity states: (q/p)(p/q) = (-1)^((p-1)/2 · (q-1)/2).

    Equivalently, using p*: (p*/q) = (q/p).

    >>> verify_quadratic_reciprocity(5, 7)['reciprocity_holds']
    True
    """
    p_star = quadratic_subfield_discriminant(p)
    q_star = quadratic_subfield_discriminant(q)

    lp_q = legendre_symbol(p, q)
    lq_p = legendre_symbol(q, p)
    lps_q = legendre_symbol(p_star % q, q)

    sign = (-1) ** (((p - 1) // 2) * ((q - 1) // 2))

    return {
        "p": p,
        "q": q,
        "p_star": p_star,
        "q_star": q_star,
        "(p/q)": lp_q,
        "(q/p)": lq_p,
        "(p*/q)": lps_q,
        "(-1)^((p-1)/2·(q-1)/2)": sign,
        "reciprocity_holds": lp_q * lq_p == sign,
        "cyclotomic_form_holds": lps_q == lq_p,
    }


# ─────────────────────────────────────────────────
# Application 4: Gauss Periods
# ─────────────────────────────────────────────────


def gauss_periods(p: int, d: int) -> list:
    """Compute the d Gauss periods of Q(ζ_p) of degree d.

    The Gauss periods η_0, ..., η_{d-1} are defined by:
        η_j = Σ_{k in C_j} ζ_p^k
    where C_0, ..., C_{d-1} are the cosets of the unique index-d
    subgroup of (Z/pZ)*.

    Returns complex approximations of the periods.

    >>> periods = gauss_periods(7, 3)
    >>> len(periods)
    3
    >>> abs(sum(periods) + 1) < 1e-10  # sum of all periods = -1
    True
    """
    import cmath

    if (p - 1) % d != 0:
        raise ValueError(f"d={d} does not divide p-1={p - 1}")

    g = primitive_root(p)
    n = p - 1
    f = n // d  # subgroup index

    zeta = cmath.exp(2j * cmath.pi / p)

    periods = []
    for j in range(d):
        eta = 0
        for k in range(f):
            exp = pow(g, j + k * d, p)
            eta += zeta**exp
        periods.append(eta)

    return periods


def gauss_period_minimal_polynomial(p: int, d: int) -> list:
    """Approximate the minimal polynomial of a Gauss period.

    Uses Newton's identities to compute power sums, then
    elementary symmetric polynomials, then coefficients.

    Returns coefficients [a_0, a_1, ..., a_d] of the polynomial
    a_d x^d + ... + a_1 x + a_0.

    >>> coeffs = gauss_period_minimal_polynomial(7, 2)
    >>> len(coeffs)
    3
    """
    periods = gauss_periods(p, d)

    # Power sums s_k = sum(eta_j^k for j)
    power_sums = []
    for k in range(1, d + 1):
        s = sum(eta**k for eta in periods)
        power_sums.append(round(s.real))  # should be rational integers

    # Newton's identities: e_k from s_k
    # k * e_k = sum_{i=1}^{k} (-1)^{i-1} e_{k-i} s_i
    elem_sym = [1]  # e_0 = 1
    for k in range(1, d + 1):
        ek = 0
        for i in range(1, k + 1):
            ek += ((-1) ** (i - 1)) * elem_sym[k - i] * power_sums[i - 1]
        ek //= k
        elem_sym.append(ek)

    # Polynomial: x^d - e_1 x^{d-1} + e_2 x^{d-2} - ... + (-1)^d e_d
    coeffs = []
    for k in range(d + 1):
        coeffs.append(int(round((-1) ** (d - k) * elem_sym[d - k])))

    return coeffs


# ─────────────────────────────────────────────────
# Main demonstration
# ─────────────────────────────────────────────────


def main():
    print("=" * 70)
    print("APPLICATION 1: CRYPTOGRAPHIC PARAMETER SELECTION")
    print("=" * 70)
    print()

    safe_primes = find_safe_primes(200)
    print(f"Safe primes up to 200: {safe_primes}")
    print()

    for p in [23, 47, 167]:
        analysis = pohlig_hellman_complexity(p)
        print(f"p = {p}:")
        print(f"  Group order: {analysis['group_order']}")
        print(f"  Factorization: {analysis['factorization']}")
        print(f"  Largest prime factor: {analysis['largest_prime_factor']}")
        print(f"  Number of subgroups: {analysis['num_subgroups']}")
        print(f"  Safe prime: {analysis['is_safe_prime']}")
        print(f"  Effective security bits: {analysis['effective_security_bits']:.1f}")
        print()

    print("=" * 70)
    print("APPLICATION 2: REGULAR POLYGON CONSTRUCTIBILITY")
    print("=" * 70)
    print()

    for n in [3, 5, 6, 7, 8, 9, 10, 12, 15, 17, 20, 24, 257]:
        analysis = constructibility_analysis(n)
        mark = "✓" if analysis["constructible"] else "✗"
        extra = ""
        if analysis["is_prime"]:
            extra = f" (p-1 = {analysis['p_minus_1']}, factors: {analysis['factorization']})"
        print(f"  {mark} Regular {n}-gon{extra}")
    print()

    print("=" * 70)
    print("APPLICATION 3: QUADRATIC RECIPROCITY VIA CYCLOTOMIC SUBFIELDS")
    print("=" * 70)
    print()

    pairs = [(3, 5), (5, 7), (5, 11), (7, 11), (7, 13), (11, 13), (13, 17)]
    print(f"{'(p,q)':>8} {'p*':>4} {'(p/q)':>6} {'(q/p)':>6} {'(p*/q)':>7} {'QR':>4}")
    print("-" * 40)
    for p, q in pairs:
        result = verify_quadratic_reciprocity(p, q)
        print(
            f"({p},{q}){'':<{4-len(str(p))-len(str(q))}} "
            f"{result['p_star']:>4} "
            f"{result['(p/q)']:>6} "
            f"{result['(q/p)']:>6} "
            f"{result['(p*/q)']:>7} "
            f"{'✓' if result['reciprocity_holds'] else '✗':>4}"
        )
    print()

    print("=" * 70)
    print("APPLICATION 4: GAUSS PERIODS")
    print("=" * 70)
    print()

    for p, d in [(7, 2), (7, 3), (13, 2), (13, 3), (13, 4)]:
        print(f"Gauss periods for p={p}, d={d} (degree-{d} subfield):")
        periods = gauss_periods(p, d)
        for j, eta in enumerate(periods):
            print(f"  η_{j} = {eta.real:.6f} + {eta.imag:.6f}i")
        print(f"  Sum of periods: {sum(p.real for p in periods):.6f} (should be -1)")

        coeffs = gauss_period_minimal_polynomial(p, d)
        terms = []
        for i, c in enumerate(coeffs):
            if c == 0:
                continue
            if i == 0:
                terms.append(str(c))
            elif i == 1:
                terms.append(f"{c}x" if abs(c) != 1 else ("-x" if c == -1 else "x"))
            else:
                terms.append(
                    f"{c}x^{i}" if abs(c) != 1 else (f"-x^{i}" if c == -1 else f"x^{i}")
                )
        poly_str = " + ".join(terms).replace("+ -", "- ")
        print(f"  Minimal polynomial: {poly_str}")
        print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Cyclotomic Subfield Extraction — Demonstration

Demonstrates the core theorems computationally:
1. For each prime p, enumerate all subgroups of (Z/pZ)* and corresponding subfields.
2. Verify cyclic group subgroup existence/uniqueness.
3. Show Galois correspondence in action.
"""

from algorithms import (
    primitive_root,
    subgroups_of_cyclic_group,
    divisors,
    euler_totient,
    cyclotomic_subfield_lattice,
)


def demo_cyclic_subgroups():
    """Demonstrate subgroup existence and uniqueness in cyclic groups."""
    print("=" * 70)
    print("CYCLIC GROUP SUBGROUP EXISTENCE AND UNIQUENESS")
    print("=" * 70)
    print()

    for n in [6, 10, 12, 18, 30]:
        print(f"Cyclic group Z/{n}Z:")
        divs = divisors(n)
        print(f"  Order = {n}, Divisors = {divs}")
        subgroups = subgroups_of_cyclic_group(n)
        print(f"  Subgroups (by order):")
        for d in sorted(subgroups.keys()):
            sg = subgroups[d]
            print(f"    Order {d}: {sorted(sg)}")
        print(f"  Total subgroups: {len(subgroups)} = τ({n}) = {len(divs)}")
        print(f"  Uniqueness verified: {len(subgroups) == len(divs)}")
        print()


def demo_galois_group_identification():
    """Show Gal(Q(ζ_p)/Q) ≅ (Z/pZ)* for small primes."""
    print("=" * 70)
    print("GALOIS GROUP IDENTIFICATION: Gal(Q(ζ_p)/Q) ≅ (Z/pZ)*")
    print("=" * 70)
    print()

    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    print(f"{'p':>4} {'p-1':>5} {'φ(p)':>5} {'Prim.Root':>10} {'Factorization':>20} {'#Subfields':>11}")
    print("-" * 60)

    for p in primes:
        g = primitive_root(p)
        phi = euler_totient(p)
        n = p - 1
        # Factor p-1
        factors = {}
        temp = n
        for f in range(2, temp + 1):
            while temp % f == 0:
                factors[f] = factors.get(f, 0) + 1
                temp //= f
            if temp == 1:
                break
        factor_str = " · ".join(
            f"{f}^{e}" if e > 1 else str(f) for f, e in sorted(factors.items())
        )
        num_subfields = len(divisors(n))
        print(f"{p:>4} {n:>5} {phi:>5} {g:>10} {factor_str:>20} {num_subfields:>11}")

    print()


def demo_intermediate_fields():
    """For each prime, show the complete subfield lattice."""
    print("=" * 70)
    print("INTERMEDIATE FIELD EXTRACTION")
    print("=" * 70)
    print()

    for p in [7, 13, 31]:
        print(f"Prime p = {p}, extension Q(ζ_{p})/Q of degree {p-1}")
        print("-" * 50)
        lattice = cyclotomic_subfield_lattice(p)

        print(f"  {'Degree d':>10} {'Subgroup order':>15} {'Generator':>10} {'Subgroup elements':>30}")
        for entry in lattice:
            elems = sorted(entry["subgroup_elements"])
            if len(elems) > 8:
                elem_str = str(elems[:6])[:-1] + ", ...]"
            else:
                elem_str = str(elems)
            print(
                f"  {entry['degree']:>10} {entry['subgroup_order']:>15} "
                f"{entry['generator']:>10} {elem_str:>30}"
            )
        print()


def demo_quadratic_subfield():
    """Show the unique quadratic subfield for each odd prime."""
    print("=" * 70)
    print("QUADRATIC SUBFIELDS OF Q(ζ_p)")
    print("=" * 70)
    print()

    print("For each odd prime p, the unique quadratic subfield is Q(√p*)")
    print("where p* = (-1)^((p-1)/2) · p")
    print()

    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    print(f"{'p':>4} {'p mod 4':>8} {'p*':>6} {'Quadratic subfield':>25}")
    print("-" * 50)

    for p in primes:
        p_star = p if (p - 1) // 2 % 2 == 0 else -p
        if p_star > 0:
            field_str = f"Q(√{p_star})"
        else:
            field_str = f"Q(√({p_star}))"
        print(f"{p:>4} {p % 4:>8} {p_star:>6} {field_str:>25}")

    print()


def demo_security_parameters():
    """Show cryptographic relevance: prime factorization of p-1."""
    print("=" * 70)
    print("CRYPTOGRAPHIC SECURITY: LARGEST PRIME FACTOR OF p-1")
    print("=" * 70)
    print()

    print("For Diffie-Hellman security, p-1 should have a large prime factor.")
    print("Each prime factor q | (p-1) gives a subgroup of order q in (Z/pZ)*.")
    print()

    # Some "safe primes" p where (p-1)/2 is also prime
    safe_primes = [5, 7, 11, 23, 47, 59, 83, 107, 167, 179, 227, 263, 347, 359, 383]
    print("Safe primes (p where (p-1)/2 is also prime):")
    print(f"{'p':>6} {'p-1':>6} {'(p-1)/2':>8} {'#Subfields':>11}")
    print("-" * 35)

    for p in safe_primes:
        n = p - 1
        num_sf = len(divisors(n))
        print(f"{p:>6} {n:>6} {n // 2:>8} {num_sf:>11}")

    print()
    print("Safe primes have only 4 subfields: Q, degree-2, degree-(p-1)/2, and Q(ζ_p).")
    print("This maximizes DLP hardness by minimizing Pohlig-Hellman decomposition.")
    print()


if __name__ == "__main__":
    demo_cyclic_subgroups()
    demo_galois_group_identification()
    demo_intermediate_fields()
    demo_quadratic_subfield()
    demo_security_parameters()


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read content
lean_file1 = read_file('Speculative/CyclotomicSubfields/CyclicGroupSubgroups.lean')
lean_file2 = read_file('Speculative/CyclotomicSubfields/CyclotomicGaloisGroup.lean')
lean_proofs = lean_file1 + "\n\n" + "-- " + "=" * 70 + "\n-- Second file: CyclotomicGaloisGroup.lean\n" + "-- " + "=" * 70 + "\n\n" + lean_file2

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')

algorithms_code = read_file('algorithms.py')

# Self-contained demo
demo_self_contained = '''#!/usr/bin/env python3
"""
Cyclotomic Subfield Extraction — Self-Contained Demo

Demonstrates the core theorems computationally:
- Subgroup existence and uniqueness in cyclic groups
- Galois group identification for prime cyclotomic fields
- Intermediate field enumeration
"""

import math

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i+2) == 0: return False
        i += 6
    return True

def divisors(n):
    divs = []
    for i in range(1, int(n**0.5)+1):
        if n % i == 0:
            divs.append(i)
            if i != n // i:
                divs.append(n // i)
    return sorted(divs)

def euler_totient(n):
    result = n
    p, temp = 2, n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0: temp //= p
            result -= result // p
        p += 1
    if temp > 1: result -= result // temp
    return result

def primitive_root(p):
    if p == 2: return 1
    phi = p - 1
    factors = set()
    temp = phi
    for f in range(2, int(temp**0.5)+1):
        if temp % f == 0:
            factors.add(f)
            while temp % f == 0: temp //= f
    if temp > 1: factors.add(temp)
    for g in range(2, p):
        if all(pow(g, phi // q, p) != 1 for q in factors):
            return g

def factorize(n):
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1: factors[n] = factors.get(n, 0) + 1
    return factors

def subgroups_of_units_mod_p(p):
    g = primitive_root(p)
    n = p - 1
    powers = {}
    current = 1
    for k in range(n):
        powers[k] = current
        current = (current * g) % p
    result = {}
    for d in divisors(n):
        gen_index = n // d
        subgroup = set()
        for k in range(d):
            subgroup.add(powers[(k * gen_index) % n])
        result[d] = subgroup
    return result

# ============================================================
# DEMO 1: Cyclic Group Subgroup Existence and Uniqueness
# ============================================================
print("=" * 60)
print("THEOREM: Unique subgroup of each divisor order")
print("=" * 60)
for n in [6, 12, 30]:
    divs = divisors(n)
    print(f"\\nCyclic group of order {n}: divisors = {divs}")
    print(f"  => Exactly {len(divs)} subgroups (one per divisor)")
    for d in divs:
        gen = n // d
        sg = sorted([(k * gen) % n for k in range(d)])
        print(f"     Order {d}: generated by {gen}, elements = {sg}")

# ============================================================
# DEMO 2: Galois Group Identification
# ============================================================
print("\\n" + "=" * 60)
print("THEOREM: Gal(Q(ζ_p)/Q) is cyclic of order p-1")
print("=" * 60)
primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
print(f"\\n{'p':>4} {'p-1':>5} {'Prim root':>10} {'p-1 factored':>20} {'#Subfields':>11}")
print("-" * 55)
for p in primes:
    g = primitive_root(p)
    n = p - 1
    factors = factorize(n)
    fstr = " * ".join(f"{q}^{e}" if e > 1 else str(q) for q, e in sorted(factors.items()))
    print(f"{p:>4} {n:>5} {g:>10} {fstr:>20} {len(divisors(n)):>11}")

# ============================================================
# DEMO 3: Intermediate Field Extraction
# ============================================================
print("\\n" + "=" * 60)
print("THEOREM: For each d | (p-1), unique degree-d subfield")
print("=" * 60)
for p in [7, 13]:
    n = p - 1
    print(f"\\nPrime p = {p}, Q(ζ_{p})/Q has degree {n}")
    subgroups = subgroups_of_units_mod_p(p)
    for d in sorted(divisors(n)):
        sg_order = n // d
        sg = sorted(subgroups[sg_order])
        if len(sg) > 6:
            sg_str = str(sg[:5])[:-1] + ", ...]"
        else:
            sg_str = str(sg)
        print(f"  Degree {d:>3}: Gal subgroup of order {sg_order:>3} = {sg_str}")

# ============================================================
# DEMO 4: Quadratic Subfields
# ============================================================
print("\\n" + "=" * 60)
print("COROLLARY: Unique quadratic subfield Q(√p*)")
print("=" * 60)
print(f"\\n{'p':>4} {'p mod 4':>8} {'p*':>5} {'Subfield':>15}")
print("-" * 35)
for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
    p_star = p if (p-1)//2 % 2 == 0 else -p
    sf = f"Q(sqrt({p_star}))"
    print(f"{p:>4} {p%4:>8} {p_star:>5} {sf:>15}")

# ============================================================
# DEMO 5: Cryptographic Application
# ============================================================
print("\\n" + "=" * 60)
print("APPLICATION: Safe primes minimize subfield decomposition")
print("=" * 60)
safe = [p for p in range(3, 200) if is_prime(p) and is_prime((p-1)//2)]
print(f"\\nSafe primes < 200: {safe}")
print("These have only 4 subfields, maximizing DLP hardness.")
print(f"\\n{'p':>5} {'(p-1)/2':>8} {'#Subfields':>11} {'Security bits':>14}")
print("-" * 42)
for p in safe:
    q = (p-1) // 2
    bits = math.log2(q) / 2
    print(f"{p:>5} {q:>8} {len(divisors(p-1)):>11} {bits:>14.1f}")
'''

# Self-contained applications
app_self_contained = '''#!/usr/bin/env python3
"""
Applications of Cyclotomic Subfield Theory — Self-Contained

1. Regular polygon constructibility
2. Gauss period computation
3. Quadratic reciprocity verification
"""
import cmath
import math

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i+2) == 0: return False
        i += 6
    return True

def divisors(n):
    divs = []
    for i in range(1, int(n**0.5)+1):
        if n % i == 0:
            divs.append(i)
            if i != n // i: divs.append(n // i)
    return sorted(divs)

def factorize(n):
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1: factors[n] = factors.get(n, 0) + 1
    return factors

def primitive_root(p):
    phi = p - 1
    factors = set()
    temp = phi
    for f in range(2, int(temp**0.5)+1):
        if temp % f == 0:
            factors.add(f)
            while temp % f == 0: temp //= f
    if temp > 1: factors.add(temp)
    for g in range(2, p):
        if all(pow(g, phi // q, p) != 1 for q in factors):
            return g

# ============================================================
# APPLICATION 1: Regular Polygon Constructibility
# ============================================================
print("REGULAR POLYGON CONSTRUCTIBILITY")
print("=" * 50)
print("A regular n-gon is constructible iff all odd prime")
print("factors of n are distinct Fermat primes (3, 5, 17, 257, 65537)")
print()

fermat_primes = {3, 5, 17, 257, 65537}
for n in [3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 17, 20, 24, 51, 257]:
    temp = n
    while temp % 2 == 0: temp //= 2
    factors = factorize(temp) if temp > 1 else {}
    ok = all(p in fermat_primes and e == 1 for p, e in factors.items())
    mark = "YES" if ok else "NO "
    reason = ""
    if is_prime(n):
        pm1 = n - 1
        reason = f"  p-1 = {pm1} = " + "*".join(f"{p}^{e}" if e > 1 else str(p) for p, e in sorted(factorize(pm1).items()))
    print(f"  {mark}  {n}-gon{reason}")

# ============================================================
# APPLICATION 2: Gauss Periods
# ============================================================
print()
print("GAUSS PERIODS — Generators of Subfields")
print("=" * 50)

for p, d in [(7, 2), (7, 3), (13, 3), (13, 4)]:
    g = primitive_root(p)
    n = p - 1
    f = n // d
    zeta = cmath.exp(2j * cmath.pi / p)
    
    print(f"\\np = {p}, degree-{d} subfield:")
    periods = []
    for j in range(d):
        eta = sum(zeta ** pow(g, j + k*d, p) for k in range(f))
        periods.append(eta)
        print(f"  eta_{j} = {eta.real:+.6f} {'+' if eta.imag >= 0 else ''}{eta.imag:.6f}i")
    
    total = sum(periods)
    print(f"  Sum = {total.real:.6f} (should be -1)")
    
    # Power sums for minimal polynomial
    power_sums = [round(sum(e**k for e in periods).real) for k in range(1, d+1)]
    print(f"  Power sums: {power_sums}")

# ============================================================
# APPLICATION 3: Quadratic Reciprocity
# ============================================================
print()
print("QUADRATIC RECIPROCITY via Cyclotomic Subfields")
print("=" * 50)
print("The unique quadratic subfield of Q(zeta_p) is Q(sqrt(p*))")
print("where p* = (-1)^((p-1)/2) * p")
print("Quadratic reciprocity: (p*/q) = (q/p)")
print()

for p, q in [(3,5), (5,7), (5,11), (7,11), (7,13), (11,13)]:
    p_star = p if (p-1)//2 % 2 == 0 else -p
    leg_qp = pow(q, (p-1)//2, p)
    if leg_qp > 1: leg_qp -= p
    ps_mod = p_star % q
    leg_ps = pow(ps_mod if ps_mod > 0 else ps_mod + q, (q-1)//2, q)
    if leg_ps > 1: leg_ps -= q
    ok = "OK" if leg_qp == leg_ps else "FAIL"
    print(f"  p={p}, q={q}: p*={p_star:+d}, (q/p)={leg_qp:+d}, (p*/q)={leg_ps:+d}  [{ok}]")
'''

# Generate visualizations
import sys
sys.path.insert(0, '.')
from visualizations import (
    visualize_subfield_lattice,
    visualize_roots_and_periods,
    visualize_subfield_count_distribution,
    visualize_security_landscape,
)

viz1 = visualize_subfield_lattice(13)
viz2 = visualize_subfield_lattice(31)
viz3 = visualize_roots_and_periods(13, 3)
viz4 = visualize_roots_and_periods(7, 2)
viz5 = visualize_subfield_count_distribution()
viz6 = visualize_security_landscape()

package = {
    "title": "Certified Subfield Extraction from Prime Cyclotomic Extensions via the Cyclic Galois Correspondence",
    "domain": "Algebraic Number Theory / Galois Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {"name": "Cyclotomic Subfield Demo", "code": demo_self_contained},
        {"name": "Applications: Constructibility, Gauss Periods, Reciprocity", "code": app_self_contained}
    ],
    "algorithms": [
        {
            "name": "Primitive Root Computation",
            "pseudocode": "Input: prime p\\nFor g = 2, 3, ..., p-1:\\n  Compute prime factors q1, ..., qk of p-1\\n  If g^((p-1)/qi) ≠ 1 (mod p) for all i:\\n    Return g\\nComplexity: O(p) worst case, O(p^(1/4+ε)) expected under GRH",
            "code": algorithms_code
        },
        {
            "name": "Subgroup Enumeration in (Z/pZ)*",
            "pseudocode": "Input: prime p\\n1. Find primitive root g mod p\\n2. For each divisor d of p-1:\\n   a. Generator = g^((p-1)/d) mod p\\n   b. Elements = {g^(k*(p-1)/d) mod p : k = 0,...,d-1}\\n3. Return all subgroups\\nComplexity: O(σ(p-1)) where σ is the sum-of-divisors function",
            "code": algorithms_code
        },
        {
            "name": "Gauss Period Computation",
            "pseudocode": "Input: prime p, degree d with d | (p-1)\\n1. Find primitive root g mod p\\n2. Let f = (p-1)/d\\n3. For j = 0,...,d-1:\\n   η_j = Σ_{k=0}^{f-1} ζ_p^(g^(j+kd))\\n4. Return [η_0,...,η_{d-1}]\\nThe η_j generate the unique degree-d subfield of Q(ζ_p).",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {"name": "Subfield Lattice of Q(ζ₁₃)/Q", "data": viz1},
        {"name": "Subfield Lattice of Q(ζ₃₁)/Q", "data": viz2},
        {"name": "Roots of Unity and Gauss Periods (p=13, d=3)", "data": viz3},
        {"name": "Roots of Unity and Gauss Periods (p=7, d=2)", "data": viz4},
        {"name": "Subfield Count Distribution Across Primes", "data": viz5},
        {"name": "DLP Security Landscape", "data": viz6},
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully")
print(f"  Size: {os.path.getsize('PACKAGE.json') / 1024:.1f} KB")


#!/usr/bin/env python3
"""
Visualizations for Cyclotomic Subfield Theory

Creates publication-quality figures:
1. Subfield lattice diagram (Hasse diagram)
2. Subgroup structure of (Z/pZ)*
3. Roots of unity and Gauss periods
4. Security parameter landscape
"""

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import cmath
import base64
import io

from algorithms import (
    divisors,
    primitive_root,
    subgroups_of_units_mod_p,
    factorize,
    euler_totient,
    is_prime,
    cyclotomic_subfield_lattice,
)
from applications import gauss_periods, find_safe_primes


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format="png", dpi=150, bbox_inches="tight", facecolor="white")
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode("utf-8")
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def visualize_subfield_lattice(p: int, save_path: str = None) -> str:
    """Draw the Hasse diagram of intermediate fields of Q(ζ_p)/Q."""
    n = p - 1
    divs = sorted(divisors(n))

    # Assign y-coordinates based on degree
    max_deg = max(divs)

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Position nodes: x spread at each level
    level_counts = {}
    for d in divs:
        level_counts[d] = level_counts.get(d, 0) + 1

    # Group divisors by "level" (number of prime factors)
    positions = {}
    y_scale = 6 / max(1, len(divs) - 1)

    # Use log scale for y
    for i, d in enumerate(divs):
        if d == 1:
            y = 0
        elif d == max_deg:
            y = 6
        else:
            y = 6 * np.log(d) / np.log(max_deg)
        positions[d] = y

    # Spread x at each y level
    y_groups = {}
    for d in divs:
        y = round(positions[d], 2)
        if y not in y_groups:
            y_groups[y] = []
        y_groups[y].append(d)

    node_positions = {}
    for y, ds in y_groups.items():
        n_nodes = len(ds)
        for i, d in enumerate(ds):
            x = (i - (n_nodes - 1) / 2) * 2.5
            node_positions[d] = (x, y)

    # Draw edges (d1 -> d2 if d1 | d2 and no d3 with d1 | d3 | d2)
    for d1 in divs:
        for d2 in divs:
            if d1 < d2 and d2 % d1 == 0:
                # Check that there's no intermediate divisor
                is_cover = True
                for d3 in divs:
                    if d1 < d3 < d2 and d3 % d1 == 0 and d2 % d3 == 0:
                        is_cover = False
                        break
                if is_cover:
                    x1, y1 = node_positions[d1]
                    x2, y2 = node_positions[d2]
                    ax.plot(
                        [x1, x2], [y1, y2], "k-", linewidth=1.5, alpha=0.4, zorder=1
                    )
                    # Label the edge with the prime ratio
                    ratio = d2 // d1
                    mx, my = (x1 + x2) / 2, (y1 + y2) / 2
                    ax.text(
                        mx + 0.15,
                        my,
                        str(ratio),
                        fontsize=8,
                        color="darkred",
                        ha="left",
                        va="center",
                        fontweight="bold",
                    )

    # Draw nodes
    for d in divs:
        x, y = node_positions[d]

        # Field description
        if d == 1:
            label = "ℚ"
            color = "#2196F3"
        elif d == n:
            label = f"ℚ(ζ_{p})"
            color = "#F44336"
        elif d == 2:
            p_star = p if (p - 1) // 2 % 2 == 0 else -p
            label = f"ℚ(√{p_star})"
            color = "#4CAF50"
        else:
            label = f"deg {d}"
            color = "#FF9800"

        circle = plt.Circle((x, y), 0.35, color=color, ec="black", linewidth=2, zorder=3)
        ax.add_patch(circle)
        ax.text(
            x,
            y - 0.6,
            label,
            fontsize=9,
            ha="center",
            va="top",
            fontweight="bold",
        )
        ax.text(
            x,
            y,
            str(d),
            fontsize=11,
            ha="center",
            va="center",
            fontweight="bold",
            color="white",
            zorder=4,
        )

    ax.set_xlim(-6, 6)
    ax.set_ylim(-1.5, 7.5)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title(
        f"Intermediate Field Lattice of ℚ(ζ_{p})/ℚ\n"
        f"p = {p}, p−1 = {n} = {'·'.join(f'{q}^{e}' if e > 1 else str(q) for q, e in sorted(factorize(n).items()))}",
        fontsize=14,
        fontweight="bold",
    )

    if save_path:
        fig.savefig(save_path, dpi=150, bbox_inches="tight", facecolor="white")

    return fig_to_base64(fig)


def visualize_roots_and_periods(p: int, d: int, save_path: str = None) -> str:
    """Visualize roots of unity on the unit circle, colored by Gauss period cosets."""
    g = primitive_root(p)
    n = p - 1
    f = n // d

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: roots of unity colored by coset
    ax = axes[0]
    theta = np.linspace(0, 2 * np.pi, 200)
    ax.plot(np.cos(theta), np.sin(theta), "k-", linewidth=0.5, alpha=0.3)

    colors = plt.cm.Set1(np.linspace(0, 1, d))

    for j in range(d):
        for k in range(f):
            exp = pow(g, j + k * d, p)
            angle = 2 * np.pi * exp / p
            x, y = np.cos(angle), np.sin(angle)
            ax.plot(x, y, "o", color=colors[j], markersize=10, zorder=3)
            ax.text(
                1.15 * x,
                1.15 * y,
                f"ζ^{exp}",
                fontsize=7,
                ha="center",
                va="center",
            )

    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect("equal")
    ax.axhline(0, color="gray", linewidth=0.5)
    ax.axvline(0, color="gray", linewidth=0.5)
    ax.set_title(
        f"Roots of Unity mod {p}\nColored by {d} cosets", fontsize=12, fontweight="bold"
    )

    # Legend
    patches = [
        mpatches.Patch(color=colors[j], label=f"Coset C_{j}")
        for j in range(min(d, 8))
    ]
    ax.legend(handles=patches, loc="lower right", fontsize=8)

    # Right: Gauss periods on the complex plane
    ax = axes[1]
    periods = gauss_periods(p, d)

    for j, eta in enumerate(periods):
        ax.plot(eta.real, eta.imag, "o", color=colors[j], markersize=12, zorder=3)
        ax.annotate(
            f"η_{j} ≈ {eta.real:.2f}{'+' if eta.imag >= 0 else ''}{eta.imag:.2f}i",
            (eta.real, eta.imag),
            textcoords="offset points",
            xytext=(10, 10),
            fontsize=8,
        )

    # Show sum = -1
    total = sum(periods)
    ax.plot(total.real, total.imag, "k*", markersize=15, zorder=4)
    ax.annotate(
        f"Sum ≈ {total.real:.2f}",
        (total.real, total.imag),
        textcoords="offset points",
        xytext=(10, -15),
        fontsize=9,
        color="red",
        fontweight="bold",
    )

    ax.axhline(0, color="gray", linewidth=0.5)
    ax.axvline(0, color="gray", linewidth=0.5)
    ax.set_aspect("equal")
    ax.set_title(
        f"Gauss Periods for p={p}, d={d}\n(generators of degree-{d} subfield)",
        fontsize=12,
        fontweight="bold",
    )
    ax.grid(True, alpha=0.3)

    fig.tight_layout()

    if save_path:
        fig.savefig(save_path, dpi=150, bbox_inches="tight", facecolor="white")

    return fig_to_base64(fig)


def visualize_subfield_count_distribution(save_path: str = None) -> str:
    """Show how the number of subfields varies with the prime."""
    primes = [p for p in range(3, 200) if is_prime(p)]
    subfield_counts = [len(divisors(p - 1)) for p in primes]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: scatter plot
    ax = axes[0]
    safe = [p for p in primes if is_prime((p - 1) // 2)]
    not_safe = [p for p in primes if not is_prime((p - 1) // 2)]

    safe_counts = [len(divisors(p - 1)) for p in safe]
    not_safe_counts = [len(divisors(p - 1)) for p in not_safe]

    ax.scatter(not_safe, not_safe_counts, c="#2196F3", s=40, alpha=0.7, label="Regular primes")
    ax.scatter(safe, safe_counts, c="#F44336", s=60, alpha=0.9, label="Safe primes", marker="D")

    ax.set_xlabel("Prime p", fontsize=12)
    ax.set_ylabel("Number of subfields τ(p−1)", fontsize=12)
    ax.set_title("Number of Intermediate Fields\nin ℚ(ζ_p)/ℚ", fontsize=13, fontweight="bold")
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: histogram of subfield counts
    ax = axes[1]
    ax.hist(subfield_counts, bins=range(1, max(subfield_counts) + 2),
            color="#4CAF50", edgecolor="black", alpha=0.7, align="left")
    ax.set_xlabel("Number of subfields τ(p−1)", fontsize=12)
    ax.set_ylabel("Count of primes", fontsize=12)
    ax.set_title("Distribution of Subfield Counts\n(primes 3 ≤ p < 200)", fontsize=13, fontweight="bold")
    ax.grid(True, alpha=0.3, axis="y")

    fig.tight_layout()

    if save_path:
        fig.savefig(save_path, dpi=150, bbox_inches="tight", facecolor="white")

    return fig_to_base64(fig)


def visualize_security_landscape(save_path: str = None) -> str:
    """Visualize DLP security parameters across primes."""
    import math

    primes = [p for p in range(5, 500) if is_prime(p)]

    largest_factors = []
    security_bits = []
    colors = []

    for p in primes:
        factors = factorize(p - 1)
        largest = max(factors.keys())
        largest_factors.append(largest)
        bits = math.log2(largest) / 2
        security_bits.append(bits)
        colors.append("#F44336" if is_prime((p - 1) // 2) else "#2196F3")

    fig, ax = plt.subplots(1, 1, figsize=(12, 6))

    ax.scatter(primes, security_bits, c=colors, s=20, alpha=0.7)

    # Highlight safe primes
    safe_p = [p for p in primes if is_prime((p - 1) // 2)]
    safe_bits = [math.log2((p - 1) // 2) / 2 for p in safe_p]
    ax.scatter(safe_p, safe_bits, c="#F44336", s=40, alpha=0.9, marker="D",
               label="Safe primes", zorder=5)

    ax.set_xlabel("Prime p", fontsize=12)
    ax.set_ylabel("Effective security (bits) = log₂(largest prime factor of p−1) / 2", fontsize=10)
    ax.set_title("DLP Security Landscape\nLarger = harder discrete logarithm", fontsize=13, fontweight="bold")
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()

    if save_path:
        fig.savefig(save_path, dpi=150, bbox_inches="tight", facecolor="white")

    return fig_to_base64(fig)


def generate_all_visualizations():
    """Generate all visualizations and save them."""
    print("Generating subfield lattice for p=13...")
    visualize_subfield_lattice(13, "subfield_lattice_13.png")

    print("Generating subfield lattice for p=31...")
    visualize_subfield_lattice(31, "subfield_lattice_31.png")

    print("Generating roots and periods for p=13, d=3...")
    visualize_roots_and_periods(13, 3, "roots_periods_13_3.png")

    print("Generating roots and periods for p=7, d=2...")
    visualize_roots_and_periods(7, 2, "roots_periods_7_2.png")

    print("Generating subfield count distribution...")
    visualize_subfield_count_distribution("subfield_count_distribution.png")

    print("Generating security landscape...")
    visualize_security_landscape("security_landscape.png")

    print("All visualizations generated.")


if __name__ == "__main__":
    generate_all_visualizations()
