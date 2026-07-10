"""
Shell Structure as Spectral Degeneracy — Numerical Demonstrations
=================================================================

Self-contained numerical companion to the paper "Shell Structure as
Spectral Degeneracy: Closed Shells and Magic Numbers as Cumulative
Eigenvalue Multiplicities".

Each function is inlined and type-hinted. Running this script verifies:

  1. The angular-momentum sum rule  sum_{l<n} (2l+1) = n^2.
  2. The Coulomb closed-form filling 3*F(n) = n(n+1)(2n+1),
     producing 2, 10, 28, 60, 110.
  3. The oscillator closed-form filling 3*G(n) = (n+1)(n+2)(n+3),
     producing 2, 8, 20, 40, 70, 112 (first three = nuclear magic numbers).
  4. Strict monotonicity of both filling sequences.
  5. The diagonal shell Hamiltonian: Hermitian, standard basis vectors are
     eigenvectors, and trace = total shell energy.
  6. A two-parameter family of degeneracy laws d(k) = a k^2 + b k + c.

No third-party dependencies are required (pure Python).
"""

from __future__ import annotations

from typing import Callable, List, Tuple


# ---------------------------------------------------------------------------
# 1. Angular-momentum sum rule
# ---------------------------------------------------------------------------
def angular_count(n: int) -> int:
    """Return sum_{l=0}^{n-1} (2l+1). Proven equal to n**2."""
    return sum(2 * l + 1 for l in range(n))


def shell_degeneracy(n: int) -> int:
    """Coulomb (hydrogenic) shell degeneracy 2 n^2 (spin included)."""
    return 2 * n * n


# ---------------------------------------------------------------------------
# 2. Coulomb cumulative fillings (noble-gas pattern)
# ---------------------------------------------------------------------------
def noble_gas(n: int) -> int:
    """Cumulative filling of the first n Coulomb shells: sum_{k=1}^{n} 2 k^2."""
    return sum(shell_degeneracy(k + 1) for k in range(n))


def noble_gas_closed(n: int) -> int:
    """Closed form: F(n) = n(n+1)(2n+1)/3."""
    return n * (n + 1) * (2 * n + 1) // 3


# ---------------------------------------------------------------------------
# 3. Harmonic-oscillator cumulative fillings (nuclear magic numbers)
# ---------------------------------------------------------------------------
def ho_degeneracy(N: int) -> int:
    """Degeneracy of the N-th isotropic 3D oscillator level: (N+1)(N+2)."""
    return (N + 1) * (N + 2)


def magic_ho(n: int) -> int:
    """Cumulative filling of oscillator levels 0..n: sum_{N=0}^{n} (N+1)(N+2)."""
    return sum(ho_degeneracy(N) for N in range(n + 1))


def magic_ho_closed(n: int) -> int:
    """Closed form: G(n) = (n+1)(n+2)(n+3)/3."""
    return (n + 1) * (n + 2) * (n + 3) // 3


# ---------------------------------------------------------------------------
# 4. Generic quadratic-degeneracy family
# ---------------------------------------------------------------------------
def cumulative_filling(a: int, b: int, c: int, n: int) -> int:
    """Cumulative filling F(n) = sum_{k=0}^{n} (a k^2 + b k + c)."""
    return sum(a * k * k + b * k + c for k in range(n + 1))


def recover_quadratic(fillings: List[int]) -> Tuple[float, float, float]:
    """Recover (a, b, c) of the degeneracy law from four consecutive fillings.

    Given F(0), F(1), F(2), F(3) with F(n)=sum_{k=0}^{n} d(k), the
    successive differences give the degeneracies d(1), d(2), d(3); a
    quadratic is then determined by its second differences.
    """
    d1 = fillings[1] - fillings[0]  # = d(1)
    d2 = fillings[2] - fillings[1]  # = d(2)
    d3 = fillings[3] - fillings[2]  # = d(3)
    a = (d3 - 2 * d2 + d1) / 2.0
    b = (d2 - d1) - 3.0 * a
    c = d1 - a - b
    return a, b, c


# ---------------------------------------------------------------------------
# 5. The diagonal shell Hamiltonian
# ---------------------------------------------------------------------------
def build_diagonal_hamiltonian(energies: List[float]) -> List[List[float]]:
    """Return the diagonal matrix H with H[j][j] = energies[j]."""
    d = len(energies)
    return [[energies[i] if i == j else 0.0 for j in range(d)] for i in range(d)]


def matvec(matrix: List[List[float]], vector: List[float]) -> List[float]:
    """Matrix-vector product."""
    return [sum(row[k] * vector[k] for k in range(len(vector))) for row in matrix]


def standard_basis(d: int, j: int) -> List[float]:
    """Return the j-th standard basis vector in R^d."""
    return [1.0 if i == j else 0.0 for i in range(d)]


def is_hermitian(matrix: List[List[float]]) -> bool:
    """Check H = H^T (real symmetric = Hermitian for real matrices)."""
    d = len(matrix)
    return all(matrix[i][j] == matrix[j][i] for i in range(d) for j in range(d))


def trace(matrix: List[List[float]]) -> float:
    """Sum of diagonal entries."""
    return sum(matrix[i][i] for i in range(len(matrix)))


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------
def main() -> None:
    print("=" * 70)
    print("Shell Structure as Spectral Degeneracy — Numerical Demonstrations")
    print("=" * 70)

    # 1. Angular-momentum sum rule
    print("\n[1] Angular-momentum sum rule  sum_{l<n}(2l+1) = n^2")
    for n in range(8):
        assert angular_count(n) == n * n
        print(f"    n={n}:  angular_count={angular_count(n):3d}   n^2={n*n:3d}  OK")

    # 2. Coulomb fillings
    print("\n[2] Coulomb cumulative fillings (idealized noble-gas pattern)")
    coulomb = [noble_gas(n) for n in range(1, 6)]
    print(f"    F(1..5) = {coulomb}   (expected 2,10,28,60,110)")
    for n in range(1, 20):
        assert 3 * noble_gas(n) == n * (n + 1) * (2 * n + 1)
        assert noble_gas(n) == noble_gas_closed(n)
    assert coulomb == [2, 10, 28, 60, 110]
    print("    Closed form 3F(n)=n(n+1)(2n+1) verified for n=1..19  OK")

    # 3. Oscillator fillings
    print("\n[3] Oscillator cumulative fillings (nuclear magic numbers)")
    osc = [magic_ho(n) for n in range(6)]
    print(f"    G(0..5) = {osc}   (expected 2,8,20,40,70,112)")
    for n in range(20):
        assert 3 * magic_ho(n) == (n + 1) * (n + 2) * (n + 3)
        assert magic_ho(n) == magic_ho_closed(n)
    assert osc == [2, 8, 20, 40, 70, 112]
    print("    First three 2,8,20 are the first three nuclear magic numbers  OK")

    # 4. Monotonicity + agreement on first shell
    print("\n[4] Strict monotonicity and first-shell agreement")
    assert all(noble_gas(n) < noble_gas(n + 1) for n in range(30))
    assert all(magic_ho(n) < magic_ho(n + 1) for n in range(30))
    assert noble_gas(1) == magic_ho(0) == 2
    print("    Both sequences strictly increasing; F(1)=G(0)=2 (helium)  OK")

    # 5. Diagonal Hamiltonian: elements as eigenvalues
    print("\n[5] Diagonal shell Hamiltonian: elements as eigenvalues")
    energies = [-13.6, -3.4, -1.51, -0.85]  # illustrative shell energies (eV)
    H = build_diagonal_hamiltonian(energies)
    assert is_hermitian(H)
    for j, E in enumerate(energies):
        e_j = standard_basis(len(energies), j)
        Hej = matvec(H, e_j)
        assert Hej == [E * c for c in e_j]
        print(f"    H e_{j} = {E:+.2f} * e_{j}  (eigenvalue = shell energy)  OK")
    print(f"    Hermitian: {is_hermitian(H)};  trace = {trace(H):.2f} eV = sum E_j  OK")

    # 6. Two-parameter family
    print("\n[6] Two-parameter family of degeneracy laws d(k)=a k^2 + b k + c")
    # Oscillator law d(k)=(k+1)(k+2) = k^2 + 3k + 2  ->  (a,b,c)=(1,3,2)
    fills = [cumulative_filling(1, 3, 2, n) for n in range(4)]
    a, b, c = recover_quadratic(fills)
    print(f"    fillings {fills}  ->  recovered (a,b,c)=({a:.1f},{b:.1f},{c:.1f})")
    assert (round(a), round(b), round(c)) == (1, 3, 2)
    print("    Degeneracy law uniquely recovered from four fillings  OK")

    print("\n" + "=" * 70)
    print("All demonstrations passed.")
    print("=" * 70)


if __name__ == "__main__":
    main()
