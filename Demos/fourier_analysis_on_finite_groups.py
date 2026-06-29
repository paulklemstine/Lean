"""Numerical demonstrations of Fourier analysis on the finite cyclic group Z/NZ.

This self-contained script demonstrates, by direct numerical computation, every
theorem from the accompanying paper:

  * character orthogonality          (stdAddChar_sum_mul)
  * the convolution theorem          (dft_conv)
  * Parseval / Plancherel            (parseval, plancherel)
  * self-convolution counts          (conv_ind)
  * energy as sum of squared counts  (addEnergy_eq_sum_count_sq)
  * the spectral energy formula      (addEnergy_eq_dft)
  * the energy lower bound           (card_pow_four_div_le_addEnergy)

Conventions match the paper exactly:
    e(x)     = exp(2*pi*i*x / N)            (standard additive character)
    f_hat[k] = sum_j e(-j*k) * f[j]         (forward DFT; normalizer N on inverse)
Consequently Plancherel reads   sum_k |f_hat[k]|^2 = N * sum_j |f[j]|^2,
and the energy identity reads    E[A] = (1/N) * sum_k |1A_hat[k]|^4.

Only the Python standard library is used (cmath, math, itertools).
"""

from __future__ import annotations

import cmath
import math
from itertools import product
from typing import Callable, List, Sequence, Set

Complex = complex


# --------------------------------------------------------------------------- #
# Core primitives
# --------------------------------------------------------------------------- #
def std_add_char(N: int, x: int) -> Complex:
    """Standard additive character e(x) = exp(2*pi*i*x/N) on Z/NZ."""
    return cmath.exp(2j * math.pi * (x % N) / N)


def dft(N: int, f: Sequence[Complex]) -> List[Complex]:
    """Forward discrete Fourier transform: f_hat[k] = sum_j e(-j*k) * f[j]."""
    return [sum(std_add_char(N, -(j * k)) * f[j] for j in range(N)) for k in range(N)]


def convolve(N: int, f: Sequence[Complex], g: Sequence[Complex]) -> List[Complex]:
    """Cyclic convolution (f * g)(x) = sum_y f[y] * g[(x - y) mod N]."""
    return [sum(f[y] * g[(x - y) % N] for y in range(N)) for x in range(N)]


def indicator(N: int, A: Set[int]) -> List[Complex]:
    """Complex indicator 1_A of a subset A of Z/NZ."""
    return [1.0 + 0j if (x % N) in A else 0j for x in range(N)]


def representation_count(N: int, A: Set[int], a: int) -> int:
    """r_A(a) = #{(x, y) in A x A : x + y = a (mod N)}."""
    return sum(1 for x in A for y in A if (x + y) % N == a % N)


def additive_energy_direct(N: int, A: Set[int]) -> int:
    """E[A] = #{(a,b,c,d) in A^4 : a + b = c + d (mod N)} by brute force."""
    return sum(
        1
        for a, b, c, d in product(A, repeat=4)
        if (a + b) % N == (c + d) % N
    )


# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #
def approx_equal(z: Complex, w: Complex, tol: float = 1e-7) -> bool:
    return abs(z - w) < tol


def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_orthogonality(N: int) -> None:
    """Verify sum_i e(t*i) = N if t = 0 else 0 (stdAddChar_sum_mul)."""
    banner(f"Character orthogonality on Z/{N}Z   (stdAddChar_sum_mul)")
    for t in range(N):
        s = sum(std_add_char(N, t * i) for i in range(N))
        expected = N if t == 0 else 0
        ok = approx_equal(s, expected)
        print(f"  t={t:2d}:  sum_i e(t*i) = {s:+.4f}   expected {expected}   {'OK' if ok else 'FAIL'}")


def demo_convolution_theorem(N: int, f: Sequence[Complex], g: Sequence[Complex]) -> None:
    """Verify dft(f * g)[k] = dft(f)[k] * dft(g)[k] (dft_conv)."""
    banner(f"Convolution theorem on Z/{N}Z   (dft_conv)")
    lhs = dft(N, convolve(N, f, g))
    fh, gh = dft(N, f), dft(N, g)
    rhs = [fh[k] * gh[k] for k in range(N)]
    for k in range(N):
        ok = approx_equal(lhs[k], rhs[k])
        print(f"  k={k:2d}:  dft(f*g)={lhs[k]:+.3f}   dft f . dft g={rhs[k]:+.3f}   {'OK' if ok else 'FAIL'}")


def demo_plancherel(N: int, f: Sequence[Complex]) -> None:
    """Verify sum_k |f_hat[k]|^2 = N * sum_j |f[j]|^2 (plancherel)."""
    banner(f"Plancherel identity on Z/{N}Z   (plancherel)")
    fh = dft(N, f)
    lhs = sum(abs(z) ** 2 for z in fh)
    rhs = N * sum(abs(z) ** 2 for z in f)
    print(f"  sum_k |f_hat[k]|^2 = {lhs:.6f}")
    print(f"  N * sum_j |f[j]|^2 = {rhs:.6f}")
    print(f"  match: {'OK' if approx_equal(lhs, rhs) else 'FAIL'}")


def demo_parseval(N: int, f: Sequence[Complex], g: Sequence[Complex]) -> None:
    """Verify sum_k f_hat[k] conj(g_hat[k]) = N sum_j f[j] conj(g[j]) (parseval)."""
    banner(f"Parseval identity on Z/{N}Z   (parseval)")
    fh, gh = dft(N, f), dft(N, g)
    lhs = sum(fh[k] * gh[k].conjugate() for k in range(N))
    rhs = N * sum(f[j] * g[j].conjugate() for j in range(N))
    print(f"  lhs = {lhs:+.6f}")
    print(f"  rhs = {rhs:+.6f}")
    print(f"  match: {'OK' if approx_equal(lhs, rhs) else 'FAIL'}")


def demo_conv_ind(N: int, A: Set[int]) -> None:
    """Verify (1_A * 1_A)(a) = r_A(a) (conv_ind)."""
    banner(f"Self-convolution counts representations   (conv_ind), A={sorted(A)}")
    ia = indicator(N, A)
    conv = convolve(N, ia, ia)
    for a in range(N):
        r = representation_count(N, A, a)
        ok = approx_equal(conv[a], r)
        print(f"  a={a:2d}:  (1A*1A)(a)={conv[a].real:5.1f}   r_A(a)={r}   {'OK' if ok else 'FAIL'}")


def demo_energy_identity(N: int, A: Set[int]) -> None:
    """Verify E[A] = sum_a r_A(a)^2 = (1/N) sum_k |1A_hat[k]|^4 >= |A|^4 / N."""
    banner(f"Spectral formula for additive energy   (addEnergy_eq_dft), A={sorted(A)}")
    e_direct = additive_energy_direct(N, A)
    e_counts = sum(representation_count(N, A, a) ** 2 for a in range(N))      # addEnergy_eq_sum_count_sq
    ah = dft(N, indicator(N, A))
    e_spectral = sum(abs(z) ** 4 for z in ah) / N                            # addEnergy_eq_dft
    lower_bound = len(A) ** 4 / N                                            # card_pow_four_div_le_addEnergy
    print(f"  E[A] (brute-force quadruples)        = {e_direct}")
    print(f"  sum_a r_A(a)^2  (count form)         = {e_counts}")
    print(f"  (1/N) sum_k |1A_hat[k]|^4 (spectral) = {e_spectral:.6f}")
    print(f"  |A|^4 / N  (lower bound)             = {lower_bound:.6f}")
    print(f"  identities match: "
          f"{'OK' if approx_equal(e_direct, e_counts) and approx_equal(e_direct, e_spectral) else 'FAIL'}")
    print(f"  lower bound holds: {'OK' if e_direct + 1e-9 >= lower_bound else 'FAIL'}")


def make_function(N: int, values: Sequence[Complex]) -> List[Complex]:
    """Pad/truncate an explicit list to a length-N complex function."""
    return [complex(values[j]) if j < len(values) else 0j for j in range(N)]


def main() -> None:
    N = 7
    f = make_function(N, [1, 2j, -1, 3, 0, 1 - 1j, 2])
    g = make_function(N, [0, 1, 1, 0, 2, -1j, 1])

    demo_orthogonality(N)
    demo_convolution_theorem(N, f, g)
    demo_parseval(N, f, g)
    demo_plancherel(N, f)

    A = {0, 1, 2, 4}        # a set in Z/7Z
    demo_conv_ind(N, A)
    demo_energy_identity(N, A)

    # An arithmetic progression has higher energy than a "spread" set of the same size.
    banner("Structure vs. randomness: energy of different sets in Z/11Z")
    M = 11
    for name, S in [
        ("AP {0,1,2,3,4}", {0, 1, 2, 3, 4}),
        ("spread {0,1,3,7,9}", {0, 1, 3, 7, 9}),
    ]:
        e = additive_energy_direct(M, S)
        print(f"  {name:22s}: E[A] = {e:3d}   |A|^4/N = {len(S)**4 / M:.2f}")


if __name__ == "__main__":
    main()
