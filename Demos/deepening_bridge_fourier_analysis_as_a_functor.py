"""
Numerical demonstrations for
"Fourier Analysis as a Functor: Pontryagin Duality, Self-Adjointness,
 and a Kernel-Level Uncertainty Principle".

Self-contained: standard library only (cmath, math, itertools, random).

Every routine below verifies, numerically, one of the theorems stated in the
accompanying paper:

  1. Character theory and orthogonality on a finite abelian group.
  2. Fourier inversion.
  3. Naturality:  transform(pushforward f) = transform(f) o dual(phi).
  4. Convolution theorem, Plancherel, and the fourth-power identity.
  5. Annihilator counting |K^perp|*|K| = |G| and Poisson summation.
  6. Donoho-Stark uncertainty, its extremals (modulated coset indicators),
     and the divisibility obstruction.
  7. Quadratic Gauss sums: |sum psi(x^2)|^2 = N, and maximal uncertainty.
  8. The kernel-level uncertainty principle and its non-Fourier instances
     (Hadamard / mutually unbiased bases).
  9. The Polya tree divisor bridge and the counting recurrence (A000081).
"""

from __future__ import annotations

import cmath
import math
import random
from fractions import Fraction
from itertools import product
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Complex = complex
Elem = Tuple[int, ...]          # element of a product of cyclic groups
Char = Tuple[int, ...]          # character index, same shape as Elem

TOL = 1e-9


# ---------------------------------------------------------------------------
# 1. Finite abelian groups as products of cyclic groups
# ---------------------------------------------------------------------------

def group_elements(moduli: Sequence[int]) -> List[Elem]:
    """All elements of Z/m_1 x ... x Z/m_r, in lexicographic order."""
    return [tuple(t) for t in product(*(range(m) for m in moduli))]


def group_order(moduli: Sequence[int]) -> int:
    """|G| = product of the moduli."""
    out = 1
    for m in moduli:
        out *= m
    return out


def add(moduli: Sequence[int], x: Elem, y: Elem) -> Elem:
    """Group addition, componentwise modulo the moduli."""
    return tuple((a + b) % m for a, b, m in zip(x, y, moduli))


def neg(moduli: Sequence[int], x: Elem) -> Elem:
    """Group negation."""
    return tuple((-a) % m for a, m in zip(x, moduli))


def character(moduli: Sequence[int], k: Char, x: Elem) -> Complex:
    """The character psi_k(x) = exp(2*pi*i * sum_j k_j x_j / m_j)."""
    theta = sum(2.0 * math.pi * kj * xj / m for kj, xj, m in zip(k, x, moduli))
    return cmath.exp(1j * theta)


def orthogonality_report(moduli: Sequence[int]) -> Dict[str, bool]:
    """Check both orthogonality relations of the paper's Lemma 4.4."""
    els = group_elements(moduli)
    n = group_order(moduli)
    ok_dual = True
    for x in els:
        s = sum(character(moduli, k, x) for k in els)
        target = n if all(xi == 0 for xi in x) else 0
        ok_dual &= abs(s - target) < TOL * n
    ok_group = True
    for k in els:
        s = sum(character(moduli, k, g) for g in els)
        target = n if all(ki == 0 for ki in k) else 0
        ok_group &= abs(s - target) < TOL * n
    return {"sum_over_characters": ok_dual, "sum_over_group": ok_group}


# ---------------------------------------------------------------------------
# 2. The Fourier transform and its inverse
# ---------------------------------------------------------------------------

def fourier(moduli: Sequence[int], f: Dict[Elem, Complex]) -> Dict[Char, Complex]:
    """(Ff)(psi_k) = sum_g f(g) psi_k(-g)."""
    els = group_elements(moduli)
    return {k: sum(f[g] * character(moduli, k, neg(moduli, g)) for g in els)
            for k in els}


def fourier_inv(moduli: Sequence[int], F: Dict[Char, Complex]) -> Dict[Elem, Complex]:
    """(F^{-1}F)(g) = |G|^{-1} sum_k F(psi_k) psi_k(g)."""
    els = group_elements(moduli)
    n = group_order(moduli)
    return {g: sum(F[k] * character(moduli, k, g) for k in els) / n for g in els}


def random_function(moduli: Sequence[int], rng: random.Random) -> Dict[Elem, Complex]:
    """A random complex function on the group."""
    return {g: complex(rng.gauss(0, 1), rng.gauss(0, 1))
            for g in group_elements(moduli)}


def max_abs_diff(a: Dict, b: Dict) -> float:
    """Sup-norm distance between two functions given as dictionaries."""
    return max(abs(a[k] - b[k]) for k in a)


# ---------------------------------------------------------------------------
# 3. Naturality: pushforward and the dual homomorphism
# ---------------------------------------------------------------------------

def pushforward(source: Sequence[int], target: Sequence[int],
                phi: Callable[[Elem], Elem],
                f: Dict[Elem, Complex]) -> Dict[Elem, Complex]:
    """(phi_* f)(h) = sum over the fibre phi^{-1}(h) of f."""
    out: Dict[Elem, Complex] = {h: 0j for h in group_elements(target)}
    for g in group_elements(source):
        out[phi(g)] += f[g]
    return out


def dual_character_index(source: Sequence[int], target: Sequence[int],
                         phi: Callable[[Elem], Elem], k: Char) -> Callable[[Elem], Complex]:
    """The pulled-back character psi_k o phi, returned as a function on the source."""
    return lambda g: character(target, k, phi(g))


def naturality_defect(source: Sequence[int], target: Sequence[int],
                      phi: Callable[[Elem], Elem],
                      f: Dict[Elem, Complex]) -> float:
    """Sup-norm of  F_H(phi_* f)(psi) - F_G(f)(psi o phi)  over all psi in dual(H)."""
    Ff_push = fourier(target, pushforward(source, target, phi, f))
    worst = 0.0
    for k in group_elements(target):
        pulled = dual_character_index(source, target, phi, k)
        rhs = sum(f[g] * pulled(neg(source, g)) for g in group_elements(source))
        worst = max(worst, abs(Ff_push[k] - rhs))
    return worst


# ---------------------------------------------------------------------------
# 4. Convolution, Plancherel, fourth power
# ---------------------------------------------------------------------------

def convolve(moduli: Sequence[int], f: Dict[Elem, Complex],
             g: Dict[Elem, Complex]) -> Dict[Elem, Complex]:
    """(f*g)(x) = sum_y f(y) g(x-y)."""
    els = group_elements(moduli)
    out: Dict[Elem, Complex] = {}
    for x in els:
        out[x] = sum(f[y] * g[add(moduli, x, neg(moduli, y))] for y in els)
    return out


def plancherel_defect(moduli: Sequence[int], f: Dict[Elem, Complex]) -> float:
    """|sum_psi |Ff|^2 - |G| sum_g |f|^2|."""
    F = fourier(moduli, f)
    lhs = sum(abs(v) ** 2 for v in F.values())
    rhs = group_order(moduli) * sum(abs(v) ** 2 for v in f.values())
    return abs(lhs - rhs)


def fourth_power_defect(moduli: Sequence[int], f: Dict[Elem, Complex]) -> float:
    """Applying the transform twice returns |G| f(-x); four times gives |G|^2 f(x)."""
    n = group_order(moduli)
    F = fourier(moduli, f)
    # The dual group is again indexed by the same tuples, so we may iterate.
    FF = fourier(moduli, F)
    d2 = max(abs(FF[x] - n * f[neg(moduli, x)]) for x in group_elements(moduli))
    FFFF = fourier(moduli, fourier(moduli, FF))
    d4 = max(abs(FFFF[x] - n * n * f[x]) for x in group_elements(moduli))
    return max(d2, d4)


# ---------------------------------------------------------------------------
# 5. Subgroups, annihilators, Poisson summation
# ---------------------------------------------------------------------------

def cyclic_subgroup(moduli: Sequence[int], gen: Elem) -> List[Elem]:
    """The subgroup generated by a single element."""
    out: List[Elem] = []
    cur = tuple(0 for _ in moduli)
    while True:
        out.append(cur)
        cur = add(moduli, cur, gen)
        if cur == tuple(0 for _ in moduli):
            break
    return out


def annihilator(moduli: Sequence[int], K: Sequence[Elem]) -> List[Char]:
    """K^perp = characters that are identically 1 on K."""
    out = []
    for k in group_elements(moduli):
        if all(abs(character(moduli, k, x) - 1.0) < TOL for x in K):
            out.append(k)
    return out


def poisson_defect(moduli: Sequence[int], K: Sequence[Elem],
                   f: Dict[Elem, Complex]) -> float:
    """|  |G| sum_{k in K} f(k)  -  |K| sum_{psi in K^perp} Ff(psi)  |."""
    F = fourier(moduli, f)
    Kperp = annihilator(moduli, K)
    lhs = group_order(moduli) * sum(f[x] for x in K)
    rhs = len(K) * sum(F[p] for p in Kperp)
    return abs(lhs - rhs)


# ---------------------------------------------------------------------------
# 6. Uncertainty on a finite abelian group
# ---------------------------------------------------------------------------

def support_size(f: Dict) -> int:
    """Number of points where f is (numerically) non-zero."""
    return sum(1 for v in f.values() if abs(v) > 1e-8)


def uncertainty_product(moduli: Sequence[int], f: Dict[Elem, Complex]) -> Tuple[int, int, int]:
    """Returns (|supp f|, |supp Ff|, |G|)."""
    return support_size(f), support_size(fourier(moduli, f)), group_order(moduli)


def coset_indicator(moduli: Sequence[int], K: Sequence[Elem], a: Elem,
                    chi: Char) -> Dict[Elem, Complex]:
    """f(g) = chi(g) on the coset a+K, and 0 elsewhere."""
    coset = {add(moduli, a, x) for x in K}
    return {g: (character(moduli, chi, g) if g in coset else 0j)
            for g in group_elements(moduli)}


def dirac(moduli: Sequence[int], a: Elem) -> Dict[Elem, Complex]:
    """The Dirac mass at a."""
    return {g: (1.0 + 0j if g == a else 0j) for g in group_elements(moduli)}


def sparse_random(moduli: Sequence[int], k: int, rng: random.Random) -> Dict[Elem, Complex]:
    """A random function supported on exactly k points."""
    els = group_elements(moduli)
    chosen = rng.sample(els, k)
    out = {g: 0j for g in els}
    for g in chosen:
        out[g] = complex(rng.gauss(0, 1), rng.gauss(0, 1))
    return out


# ---------------------------------------------------------------------------
# 7. Quadratic Gauss sums
# ---------------------------------------------------------------------------

def gauss_sum(N: int) -> Complex:
    """sum_{x mod N} exp(2 pi i x^2 / N)."""
    return sum(cmath.exp(2j * math.pi * (x * x % N) / N) for x in range(N))


def quadratic_phase(N: int) -> Dict[Elem, Complex]:
    """The chirp x -> exp(2 pi i x^2 / N) as a function on Z/N."""
    return {(x,): cmath.exp(2j * math.pi * (x * x % N) / N) for x in range(N)}


# ---------------------------------------------------------------------------
# 8. Kernel-level uncertainty (no group required)
# ---------------------------------------------------------------------------

def kernel_transform(k: List[List[Complex]], f: List[Complex]) -> List[Complex]:
    """(T_k f)(h) = sum_g f(g) k(g,h)."""
    m = len(k[0])
    return [sum(f[g] * k[g][h] for g in range(len(f))) for h in range(m)]


def vec_support(v: Sequence[Complex]) -> int:
    """Number of non-zero entries of a vector."""
    return sum(1 for z in v if abs(z) > 1e-8)


def hadamard_matrix(n: int) -> List[List[Complex]]:
    """Normalised Sylvester-Hadamard matrix of size n = 2^t (orthonormal rows)."""
    assert n & (n - 1) == 0, "n must be a power of two"
    scale = 1.0 / math.sqrt(n)
    return [[scale * ((-1.0) ** bin(i & j).count("1")) + 0j for j in range(n)]
            for i in range(n)]


def dft_matrix(n: int) -> List[List[Complex]]:
    """Unitary DFT matrix, entries of modulus 1/sqrt(n)."""
    scale = 1.0 / math.sqrt(n)
    return [[scale * cmath.exp(-2j * math.pi * i * j / n) for j in range(n)]
            for i in range(n)]


def coherence(U: List[List[Complex]]) -> float:
    """mu = max entry modulus."""
    return max(abs(z) for row in U for z in row)


# ---------------------------------------------------------------------------
# 9. Polya trees: divisor bridge and the counting recurrence
# ---------------------------------------------------------------------------

def divisors(n: int) -> List[int]:
    """All positive divisors of n."""
    return [d for d in range(1, n + 1) if n % d == 0]


def omega_weight(a: Sequence[Fraction], n: int) -> Fraction:
    """omega_n = sum_{d | n} d * a_d."""
    return sum((Fraction(d) * a[d] for d in divisors(n)), Fraction(0))


def s_coefficient(a: Sequence[Fraction], n: int) -> Fraction:
    """s_n = [z^n] S(z) = sum_{i | n} a_{n/i} / i."""
    return sum((a[n // i] / Fraction(i) for i in divisors(n)), Fraction(0))


def polya_trees(nmax: int) -> List[Fraction]:
    """
    a_0 = 0, a_1 = 1, and for k >= 2
        a_k = (1/(k-1)) sum_{j=1}^{k-1} a_j * omega_{k-j},  omega_m = sum_{d|m} d a_d.
    """
    a: List[Fraction] = [Fraction(0)] * (nmax + 1)
    if nmax >= 1:
        a[1] = Fraction(1)
    for k in range(2, nmax + 1):
        total = sum((a[j] * omega_weight(a, k - j) for j in range(1, k)), Fraction(0))
        a[k] = total / Fraction(k - 1)
    return a


def divisor_bridge_holds(a: Sequence[Fraction], nmax: int) -> bool:
    """Verify n * s_n = omega_n for 1 <= n <= nmax."""
    return all(Fraction(n) * s_coefficient(a, n) == omega_weight(a, n)
               for n in range(1, nmax + 1))


def log_derivative_holds(a: Sequence[Fraction], nmax: int) -> bool:
    """Verify the coefficientwise log-derivative identity for 1 <= n <= nmax."""
    for n in range(1, nmax + 1):
        rhs = a[n] + sum(
            (a[j] * Fraction(n - j) * s_coefficient(a, n - j) for j in range(1, n)),
            Fraction(0))
        if Fraction(n) * a[n] != rhs:
            return False
    return True


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)


def main() -> None:
    rng = random.Random(20260806)

    # --- 1. orthogonality -------------------------------------------------
    banner("1.  Character orthogonality on Z/6 x Z/4")
    print(orthogonality_report([6, 4]))

    # --- 2. inversion -----------------------------------------------------
    banner("2.  Fourier inversion")
    for mods in ([12], [6, 4], [2, 2, 3]):
        f = random_function(mods, rng)
        err = max_abs_diff(fourier_inv(mods, fourier(mods, f)), f)
        print(f"  G = Z/{ ' x Z/'.join(map(str, mods)) :<12}  |G| = {group_order(mods):3d}"
              f"   inversion error = {err:.2e}")

    # --- 3. naturality ----------------------------------------------------
    banner("3.  Naturality:  F_H(phi_* f)(psi) = F_G(f)(psi o phi)")
    # phi : Z/6 -> Z/3, reduction mod 3
    f6 = random_function([6], rng)
    d1 = naturality_defect([6], [3], lambda g: (g[0] % 3,), f6)
    print(f"  quotient  Z/6 -> Z/3   (periodisation)      defect = {d1:.2e}")
    # phi : Z/3 -> Z/6, multiplication by 2 (injective)
    f3 = random_function([3], rng)
    d2 = naturality_defect([3], [6], lambda g: (2 * g[0] % 6,), f3)
    print(f"  inclusion Z/3 -> Z/6   (x -> 2x)            defect = {d2:.2e}")
    # phi : Z/2 x Z/3 -> Z/6, the CRT isomorphism
    f23 = random_function([2, 3], rng)
    d3 = naturality_defect([2, 3], [6], lambda g: ((3 * g[0] + 4 * g[1]) % 6,), f23)
    print(f"  CRT iso   Z/2 x Z/3 -> Z/6                  defect = {d3:.2e}")

    # --- 4. convolution / Plancherel / fourth power -----------------------
    banner("4.  Convolution theorem, Plancherel, fourth-power identity")
    mods = [8]
    f, g = random_function(mods, rng), random_function(mods, rng)
    Fc = fourier(mods, convolve(mods, f, g))
    Ff, Fg = fourier(mods, f), fourier(mods, g)
    conv_err = max(abs(Fc[k] - Ff[k] * Fg[k]) for k in Fc)
    print(f"  convolution theorem   max |F(f*g) - Ff.Fg| = {conv_err:.2e}")
    print(f"  Plancherel defect                          = {plancherel_defect(mods, f):.2e}")
    print(f"  fourth-power defect (F^2 = |G|.antipode)   = {fourth_power_defect(mods, f):.2e}")

    # --- 5. annihilators and Poisson --------------------------------------
    banner("5.  Annihilator counting and Poisson summation")
    mods = [12]
    for gen in [(2,), (3,), (4,), (6,)]:
        K = cyclic_subgroup(mods, gen)
        Kp = annihilator(mods, K)
        f = random_function(mods, rng)
        print(f"  K = <{gen[0]}> in Z/12:  |K| = {len(K):2d},  |K^perp| = {len(Kp):2d},"
              f"  product = {len(K)*len(Kp):3d} (= |G| = 12?  {len(K)*len(Kp)==12})"
              f"   Poisson defect = {poisson_defect(mods, K, f):.2e}")

    # --- 6. Donoho-Stark --------------------------------------------------
    banner("6.  Donoho-Stark uncertainty:  |supp f| . |supp Ff| >= |G|")
    mods = [12]
    print("  random sparse functions on Z/12:")
    for k in (1, 2, 3, 5, 7):
        f = sparse_random(mods, k, rng)
        s, S, n = uncertainty_product(mods, f)
        print(f"    |supp f| = {s:2d}   |supp Ff| = {S:2d}   product = {s*S:3d}   |G| = {n}"
              f"   {'EXTREMAL' if s*S == n else 'strict'}")
    print("\n  modulated coset indicators (predicted extremals):")
    for gen in [(1,), (2,), (3,), (4,), (6,)]:
        K = cyclic_subgroup(mods, gen)
        f = coset_indicator(mods, K, (1,), (5,))
        s, S, n = uncertainty_product(mods, f)
        print(f"    K = <{gen[0]}>, |K| = {len(K):2d}:  |supp f| = {s:2d}, "
              f"|supp Ff| = {S:2d},  product = {s*S:3d}  "
              f"{'= |G| (extremal)' if s*S == n else '!= |G|'}")
    print("\n  divisibility obstruction on Z/7 (prime): support size 2..6 cannot be extremal")
    mods = [7]
    for k in range(1, 8):
        f = sparse_random(mods, k, rng)
        s, S, n = uncertainty_product(mods, f)
        divides = (n % s == 0)
        print(f"    |supp f| = {s}  divides 7? {str(divides):5s}   product = {s*S:3d}"
              f"   {'= |G|' if s*S == n else '> |G| (strict, as predicted)'}")

    # --- 7. Gauss sums ----------------------------------------------------
    banner("7.  Quadratic Gauss sums and maximal uncertainty")
    for N in (3, 5, 7, 9, 11, 15, 21):
        S = gauss_sum(N)
        q = quadratic_phase(N)
        s, Sf, n = uncertainty_product([N], q)
        print(f"  N = {N:2d}:  |sum psi(x^2)|^2 = {abs(S)**2:8.4f}  (should be {N})"
              f"   uncertainty product = {s*Sf:4d}  (= N^2 = {N*N})")

    # --- 8. kernel-level uncertainty --------------------------------------
    banner("8.  Kernel-level uncertainty principle (no group needed)")
    print("  Hadamard bases:  mu = 1/sqrt(n),  bound  n <= |supp f| . |supp Uf|")
    for n in (2, 4, 8):
        U = hadamard_matrix(n)
        mu = coherence(U)
        worst = None
        for _ in range(400):
            f = [0j] * n
            for i in rng.sample(range(n), rng.randint(1, n)):
                f[i] = complex(rng.gauss(0, 1), rng.gauss(0, 1))
            prod = vec_support(f) * vec_support(kernel_transform(U, f))
            worst = prod if worst is None else min(worst, prod)
        print(f"    n = {n}:  mu = {mu:.4f},  1/mu^2 = {1/mu**2:5.2f},"
              f"  minimum observed product = {worst}")
    print("\n  unitary DFT matrix (also flat), same bound:")
    for n in (5, 6, 7):
        U = dft_matrix(n)
        mu = coherence(U)
        e0 = [1.0 + 0j] + [0j] * (n - 1)
        prod = vec_support(e0) * vec_support(kernel_transform(U, e0))
        print(f"    n = {n}:  mu = {mu:.4f},  1/mu^2 = {1/mu**2:5.2f},"
              f"  Dirac attains product = {prod}")

    # --- 9. Polya trees ---------------------------------------------------
    banner("9.  Polya trees: divisor bridge and the counting recurrence")
    nmax = 16
    a = polya_trees(nmax)
    counts = [int(x) for x in a[1:]]
    print("  a_1 .. a_16 =", counts)
    print("  all integers?           ", all(x.denominator == 1 for x in a[1:]))
    print("  divisor bridge n.s_n = omega_n holds for n <= 16? ",
          divisor_bridge_holds(a, nmax))
    print("  log-derivative identity holds for n <= 16?        ",
          log_derivative_holds(a, nmax))
    print("  omega_1 .. omega_10 =", [int(omega_weight(a, n)) for n in range(1, 11)])
    expected = [1, 1, 2, 4, 9, 20, 48, 115, 286, 719, 1842, 4766, 12486, 32973,
                87811, 235381]
    print("  matches the rooted-tree counts?  ", counts == expected)

    banner("All demonstrations complete.")


if __name__ == "__main__":
    main()
