#!/usr/bin/env python3
"""
Algorithms for Monstrous Moonshine Computations

Type-hinted implementations of the key algorithms from the research paper:
1. Multiplicity recovery from McKay-Thompson coefficients
2. Inner product identity verification
3. Trace dominance checking
4. j-function coefficient computation via modular equations
"""

from fractions import Fraction
from typing import List, Tuple, Optional, Dict
import math


class CharacterTable:
    """
    A character table for a finite group with n conjugacy classes.

    Attributes:
        n: number of conjugacy classes (= number of irreps)
        class_sizes: sizes of conjugacy classes
        group_order: order of the group
        chi: character values chi[i][j] = value of i-th irrep on j-th class
    """

    def __init__(
        self,
        class_sizes: List[int],
        chi: List[List[Fraction]],
    ) -> None:
        self.n = len(class_sizes)
        self.class_sizes = class_sizes
        self.group_order = sum(class_sizes)
        self.chi = chi

        assert len(chi) == self.n
        assert all(len(row) == self.n for row in chi)

    def rep_dim(self, i: int) -> Fraction:
        """Dimension of the i-th irreducible representation."""
        return self.chi[i][0]

    def verify_row_orthogonality(self) -> bool:
        """Verify row orthogonality: sum_k |C_k| chi_i(k) chi_j(k) = |G| delta_ij."""
        for i in range(self.n):
            for j in range(self.n):
                inner = sum(
                    Fraction(self.class_sizes[k]) * self.chi[i][k] * self.chi[j][k]
                    for k in range(self.n)
                )
                expected = Fraction(self.group_order) if i == j else Fraction(0)
                if inner != expected:
                    return False
        return True

    def verify_column_orthogonality(self) -> bool:
        """Verify column orthogonality: sum_i chi_i(k) chi_i(l) = (|G|/|C_k|) delta_kl."""
        for k in range(self.n):
            for l in range(self.n):
                inner = sum(
                    self.chi[i][k] * self.chi[i][l]
                    for i in range(self.n)
                )
                expected = (
                    Fraction(self.group_order, self.class_sizes[k])
                    if k == l
                    else Fraction(0)
                )
                if inner != expected:
                    return False
        return True

    def verify_burnside_identity(self) -> bool:
        """Verify sum of squared dimensions equals group order."""
        total = sum(self.rep_dim(i) ** 2 for i in range(self.n))
        return total == Fraction(self.group_order)


class MoonshineDatum:
    """
    A moonshine datum: a character table plus graded multiplicities.

    The graded module V = ⊕_m V_m decomposes as:
        V_m = ⊕_i mult[i][m] copies of ρ_i

    The McKay-Thompson coefficient for class j at grade m is:
        a_m(g_j) = sum_i mult[i][m] * chi_i(g_j)
    """

    def __init__(
        self,
        char_table: CharacterTable,
        mult: Dict[Tuple[int, int], int],
        max_grade: int,
    ) -> None:
        self.ct = char_table
        self.mult = mult
        self.max_grade = max_grade

    def get_mult(self, i: int, m: int) -> Fraction:
        """Get multiplicity of irrep i at grade m."""
        return Fraction(self.mult.get((i, m), 0))

    def mckay_coeff(self, j: int, m: int) -> Fraction:
        """
        McKay-Thompson coefficient: trace of class-j element on V_m.

        a_m(g_j) = sum_i mult(i, m) * chi_i(g_j)
        """
        return sum(
            self.get_mult(i, m) * self.ct.chi[i][j]
            for i in range(self.ct.n)
        )

    def graded_dim(self, m: int) -> Fraction:
        """
        Graded dimension: dim(V_m) = sum_i mult(i, m) * dim(ρ_i).
        Equals mckay_coeff(0, m) (identity element).
        """
        return sum(
            self.get_mult(i, m) * self.ct.rep_dim(i)
            for i in range(self.ct.n)
        )


def compute_multiplicity(
    datum: MoonshineDatum,
    i: int,
    m: int,
) -> Fraction:
    """
    Multiplicity Recovery Algorithm.

    Recovers mult(i, m) from McKay-Thompson coefficients using
    character orthogonality:

        mult(i, m) = (1/|G|) * sum_j |C_j| * chi_i(g_j) * a_m(g_j)

    Args:
        datum: moonshine datum with character table
        i: index of irreducible representation
        m: grade

    Returns:
        The multiplicity of ρ_i in V_m
    """
    ct = datum.ct
    total = sum(
        Fraction(ct.class_sizes[j]) * ct.chi[i][j] * datum.mckay_coeff(j, m)
        for j in range(ct.n)
    )
    return total / Fraction(ct.group_order)


def verify_inner_product_identity(
    datum: MoonshineDatum,
    m: int,
    m_prime: int,
) -> Tuple[bool, Fraction, Fraction]:
    """
    Verify the moonshine inner product identity:

    sum_j |C_j| * a_m(g_j) * a_{m'}(g_j) = |G| * sum_i mult(i,m) * mult(i,m')

    Args:
        datum: moonshine datum
        m, m_prime: grades to compare

    Returns:
        (identity_holds, lhs_value, rhs_value)
    """
    ct = datum.ct

    lhs = sum(
        Fraction(ct.class_sizes[j])
        * datum.mckay_coeff(j, m)
        * datum.mckay_coeff(j, m_prime)
        for j in range(ct.n)
    )

    rhs = Fraction(ct.group_order) * sum(
        datum.get_mult(i, m) * datum.get_mult(i, m_prime)
        for i in range(ct.n)
    )

    return (lhs == rhs, lhs, rhs)


def check_trace_dominance(
    datum: MoonshineDatum,
    max_grade: int,
) -> List[Tuple[int, int, Fraction, Fraction]]:
    """
    Check trace dominance: |a_m(g_j)| ≤ a_m(e) for all j, m.

    Returns list of violations (j, m, |a_m(g_j)|, a_m(e)).
    """
    violations = []
    for m in range(max_grade + 1):
        dim_m = datum.mckay_coeff(0, m)  # identity trace = dimension
        for j in range(datum.ct.n):
            trace = datum.mckay_coeff(j, m)
            if abs(trace) > dim_m:
                violations.append((j, m, abs(trace), dim_m))
    return violations


def j_coefficients_from_recursion(num_terms: int) -> List[int]:
    """
    Compute j-function coefficients using the recursion relation.

    The j-function satisfies j(q) = E_4(q)^3 / Delta(q) where
    E_4 is the Eisenstein series and Delta is the discriminant function.

    We use the fact that Delta = q * prod_{n>=1} (1-q^n)^24
    and E_4 = 1 + 240 * sum_{n>=1} sigma_3(n) q^n.

    Returns coefficients c_{-1}, c_0, c_1, ..., c_{num_terms-2}.
    """
    N = num_terms + 5  # compute extra terms for safety

    # Compute sigma_3(n) = sum of cubes of divisors
    def sigma3(n: int) -> int:
        return sum(d**3 for d in range(1, n + 1) if n % d == 0)

    # E_4 coefficients: E_4 = 1 + 240 * sum sigma_3(n) q^n
    e4 = [0] * N
    e4[0] = 1
    for n in range(1, N):
        e4[n] = 240 * sigma3(n)

    # E_4^3 coefficients (by convolution)
    e4_sq = [0] * N
    for n in range(N):
        for k in range(n + 1):
            e4_sq[n] += e4[k] * e4[n - k]

    e4_cube = [0] * N
    for n in range(N):
        for k in range(n + 1):
            e4_cube[n] += e4_sq[k] * e4[n - k]

    # Delta coefficients: Delta = q * prod (1-q^n)^24
    # Ramanujan's tau function: Delta = sum tau(n) q^n
    # Use the recurrence for the partition-like product
    prod_coeffs = [0] * N
    prod_coeffs[0] = 1
    for m in range(1, N):
        for n in range(m, N):
            prod_coeffs[n] -= 24 * prod_coeffs[n - m]
        # This is wrong — need to use the full product expansion
        # Let's use a cleaner approach

    # Actually, compute Delta = eta(q)^24 where eta = q^{1/24} prod (1-q^n)
    # Delta = q * prod_{n>=1} (1-q^n)^24
    # So Delta[n] = coefficient of q^n in q * prod (1-q^k)^24
    # = coefficient of q^{n-1} in prod (1-q^k)^24

    # Compute prod (1-q^k)^24 up to order N
    p = [0] * N
    p[0] = 1
    for k in range(1, N):
        # Multiply by (1 - q^k)^24
        # We do this by multiplying by (1 - q^k) twenty-four times
        for _ in range(24):
            for n in range(N - 1, k - 1, -1):
                p[n] -= p[n - k]

    # Delta[n] = p[n-1] for n >= 1, Delta[0] = 0
    delta = [0] * N
    for n in range(1, N):
        delta[n] = p[n - 1]

    # j = E_4^3 / Delta
    # j[n] * Delta = E_4^3, so we can recover j by division
    # j = sum j[n] q^n where j[-1] = 1 (coefficient of q^{-1})
    # So j * Delta = E_4^3
    # sum_n j[n] * sum_m delta[m] q^{n+m} = sum_k e4_cube[k] q^k
    # For the coefficient of q^k: sum_{n: n+m=k} j[n] * delta[m] = e4_cube[k]
    # Since delta[0] = 0 and delta[1] = 1:
    # j has a pole at q=0: j = q^{-1} + 744 + ...
    # j[n] for n >= -1

    # j * Delta = E_4^3
    # Coefficient of q^k in j*Delta: sum_{m=1}^{k+1} j[k-m] * delta[m]
    # where j is indexed starting from -1
    # So j[-1]*delta[k+1] + j[0]*delta[k] + ... + j[k-1]*delta[1] = e4_cube[k]

    # Let's index j as j_coeffs[i] = j[i-1] so j_coeffs[0] = j[-1], j_coeffs[1] = j[0], etc.
    j_coeffs = [0] * num_terms
    for k in range(num_terms):
        # Coefficient of q^k: sum_{i=0}^{k} j_coeffs[i] * delta[k - i + 1] = e4_cube[k]
        # j_coeffs[k] * delta[1] + sum_{i=0}^{k-1} j_coeffs[i] * delta[k-i+1] = e4_cube[k]
        rhs = e4_cube[k]
        for i in range(k):
            idx = k - i + 1
            if idx < N:
                rhs -= j_coeffs[i] * delta[idx]
        j_coeffs[k] = rhs // delta[1]  # delta[1] = 1

    return j_coeffs


def demonstrate_algorithms():
    """Run all algorithm demonstrations."""
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Build S₃ character table
    ct = CharacterTable(
        class_sizes=[1, 3, 2],
        chi=[
            [Fraction(1), Fraction(1), Fraction(1)],
            [Fraction(1), Fraction(-1), Fraction(1)],
            [Fraction(2), Fraction(0), Fraction(-1)],
        ],
    )

    print(f"\n1. Character table verification for S₃:")
    print(f"   Row orthogonality: {ct.verify_row_orthogonality()}")
    print(f"   Column orthogonality: {ct.verify_column_orthogonality()}")
    print(f"   Burnside identity: {ct.verify_burnside_identity()}")

    # Build moonshine datum
    mult = {(0, 0): 1, (2, 0): 1, (0, 1): 2, (1, 1): 1, (2, 1): 3}
    datum = MoonshineDatum(ct, mult, max_grade=1)

    print(f"\n2. Moonshine datum for S₃:")
    for m in range(2):
        print(f"   Grade {m}: dim = {datum.graded_dim(m)}")
        for j in range(ct.n):
            print(f"     a_{m}(g_{j}) = {datum.mckay_coeff(j, m)}")

    print(f"\n3. Multiplicity recovery:")
    for m in range(2):
        for i in range(ct.n):
            recovered = compute_multiplicity(datum, i, m)
            actual = datum.get_mult(i, m)
            print(f"   mult({i}, {m}) = {recovered} (actual: {actual}) "
                  f"{'✓' if recovered == actual else '✗'}")

    print(f"\n4. Inner product identity:")
    for m in range(2):
        for mp in range(m, 2):
            ok, lhs, rhs = verify_inner_product_identity(datum, m, mp)
            print(f"   (m={m}, m'={mp}): LHS={lhs}, RHS={rhs} {'✓' if ok else '✗'}")

    print(f"\n5. Trace dominance:")
    violations = check_trace_dominance(datum, 1)
    print(f"   Violations: {len(violations)}")
    if violations:
        for v in violations:
            print(f"     class {v[0]}, grade {v[1]}: |trace|={v[2]} > dim={v[3]}")
    else:
        print("   All traces bounded by dimensions ✓")

    print(f"\n6. j-function coefficients (first 12):")
    j_coeffs = j_coefficients_from_recursion(12)
    for i, c in enumerate(j_coeffs):
        print(f"   c_{i-1} = {c}")

    # Verify against known values
    known = [1, 744, 196884, 21493760, 864299970, 20245856256]
    all_match = all(j_coeffs[i] == known[i] for i in range(min(len(known), len(j_coeffs))))
    print(f"\n   Match known values: {all_match} ✓" if all_match else "   MISMATCH ✗")


if __name__ == "__main__":
    demonstrate_algorithms()
