"""
Close Proofs: numerical demonstrations of the order type of the p-degrees.

This script illustrates, with exact integer arithmetic, the order-theoretic core
of the Cook-Reckhow program formalized in the accompanying Lean development:

  * the polynomial blow-up class and its composition closure,
  * the Domination Characterization (simulation = polynomial domination of size),
  * the Fibonacci separation (Fibonacci growth is super-polynomial),
  * the direct-sum meet (greatest lower bound) on size functions,
  * the infinite power ladder 2^(n^k) and its non-collapsing gaps,
  * density along the ladder via parity-glued size functions,
  * the diagonalization showing there is no greatest p-degree.

All arithmetic is exact (Python big integers); no external dependencies.
"""

from __future__ import annotations

from typing import Callable, List, Optional, Tuple

SizeFn = Callable[[int], int]


# --------------------------------------------------------------------------- #
# 1. The polynomial blow-up class:  f is PolyBounded iff  f(n)+1 <= (n+2)^k.
# --------------------------------------------------------------------------- #
def poly_bound_holds(f: SizeFn, k: int, n_max: int) -> bool:
    """Check f(n) + 1 <= (n+2)^k for all 0 <= n <= n_max."""
    return all(f(n) + 1 <= (n + 2) ** k for n in range(n_max + 1))


def least_poly_exponent(f: SizeFn, k_max: int, n_max: int) -> Optional[int]:
    """Least k <= k_max witnessing PolyBounded f on [0, n_max], else None."""
    for k in range(k_max + 1):
        if poly_bound_holds(f, k, n_max):
            return k
    return None


# --------------------------------------------------------------------------- #
# 2. Domination Characterization:
#    sysOfSize(a) p-simulates sysOfSize(b)  <=>  a(n) <= f(b(n)) for a
#    monotone polynomially-bounded f.  For monotone size functions a, b this is
#    witnessed by checking a(n) <= (b(n)+2)^k on a finite range.
# --------------------------------------------------------------------------- #
def simulates_size_indexed(a: SizeFn, b: SizeFn, k_max: int, n_max: int
                           ) -> Tuple[bool, Optional[int]]:
    """Return (does a-system get simulated by b-system?, witnessing exponent k)."""
    for k in range(k_max + 1):
        if all(a(n) <= (b(n) + 2) ** k for n in range(n_max + 1)):
            return True, k
    return False, None


# --------------------------------------------------------------------------- #
# 3. Fibonacci: an honest super-polynomial size function.
# --------------------------------------------------------------------------- #
def fib(n: int) -> int:
    """The n-th Fibonacci number, F(0)=0, F(1)=1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def fibonacci_outruns_polynomial(k: int, search: int = 200) -> Optional[int]:
    """Smallest m with (2m+3)^k < 2^m, certifying F is not (n+2)^k-bounded."""
    for m in range(search):
        if (2 * m + 3) ** k < 2 ** m:
            return m
    return None


# --------------------------------------------------------------------------- #
# 4. Direct-sum meet:  the GLB of two size functions runs the *cheaper* proof,
#    so its size at n is min(a(n), b(n)); the universal blow-up is max(f,g).
# --------------------------------------------------------------------------- #
def sum_system_size(a: SizeFn, b: SizeFn) -> SizeFn:
    """Size function of the direct-sum (meet) system: pick the smaller proof."""
    return lambda n: min(a(n), b(n))


# --------------------------------------------------------------------------- #
# 5. The power ladder  powSystem(k) := sysOfSize(n -> 2^(n^k)).
# --------------------------------------------------------------------------- #
def pow_ladder_size(k: int) -> SizeFn:
    """Size function 2^(n^k) of the k-th ladder rung."""
    return lambda n: 2 ** (n ** k)


def ladder_gap_witness(k: int, c: int) -> int:
    """Least n with (2^(n^k)+2)^c < 2^(n^(k+1)): rungs are not poly-comparable."""
    n = 0
    while True:
        if (2 ** (n ** k) + 2) ** c < 2 ** (n ** (k + 1)):
            return n
        n += 1


def ladder_gap_witness_with_parity(k: int, c: int, even: bool) -> int:
    """Least n >= c+2 of chosen parity with the uniform gap (density witness)."""
    n = c + 2
    while True:
        if (n % 2 == 0) == even and (2 ** (n ** k) + 2) ** c < 2 ** (n ** (k + 1)):
            return n
        n += 1


# --------------------------------------------------------------------------- #
# 6. Parity-glued intermediate system: fast rate on evens, slow rate on odds.
# --------------------------------------------------------------------------- #
def inter_pow_size(k: int) -> SizeFn:
    """Size 2^(n^(k+1)) on even n, 2^(n^k) on odd n: lies strictly between rungs."""
    return lambda n: 2 ** (n ** (k + 1)) if n % 2 == 0 else 2 ** (n ** k)


# --------------------------------------------------------------------------- #
# 7. Diagonalization against a candidate top T (given by its section sizes sec).
# --------------------------------------------------------------------------- #
def diagonal_size(sec: SizeFn) -> SizeFn:
    """The diagonal size t -> 2^(sec t) + 2^t that escapes every blow-up of sec."""
    return lambda t: 2 ** sec(t) + 2 ** t


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo() -> None:
    print("=" * 70)
    print("1. Polynomial blow-up class and composition closure")
    print("=" * 70)
    f = lambda n: 3 * n + 5          # linear, PolyBounded
    g = lambda n: n * n + 1          # quadratic, PolyBounded
    print(f"  f(n)=3n+5     least exponent k:  {least_poly_exponent(f, 6, 40)}")
    print(f"  g(n)=n^2+1    least exponent k:  {least_poly_exponent(g, 6, 40)}")
    fg = lambda n: f(g(n))
    print(f"  (f o g)(n)    least exponent k:  {least_poly_exponent(fg, 8, 40)}"
          "   <- composition stays polynomial")

    print()
    print("=" * 70)
    print("2. Domination Characterization (simulation = poly domination)")
    print("=" * 70)
    lin, fibs = (lambda n: n), fib
    ok_lf, k_lf = simulates_size_indexed(lin, fibs, 6, 25)
    print(f"  linSystem simulated by fibSystem?  {ok_lf}  (k={k_lf})")
    # The reverse needs ONE exponent k working for ALL n. Each fixed k fails:
    print("  fibSystem simulated by linSystem?  No fixed exponent k works:")
    for k in (2, 4, 6):
        m = fibonacci_outruns_polynomial(k)
        print(f"     k={k}: fails at n={m} since F(2n+1) > (n+2)^{k} eventually")
    print("  => strict: linSystem < fibSystem")

    print()
    print("=" * 70)
    print("3. Fibonacci is super-polynomial (the separation engine)")
    print("=" * 70)
    for k in (2, 4, 6):
        m = fibonacci_outruns_polynomial(k)
        print(f"  for k={k}: (2m+3)^k < 2^m first holds at m={m}  "
              f"=> F not (n+2)^{k}-bounded")

    print()
    print("=" * 70)
    print("4. Direct-sum meet (greatest lower bound)")
    print("=" * 70)
    meet = sum_system_size(lin, fibs)
    print("   n :  lin   fib   meet=min")
    for n in range(8):
        print(f"  {n:2d} : {lin(n):5d} {fibs(n):5d} {meet(n):8d}")
    print("   meet is simulated by each summand (run whichever proof is cheaper)")

    print()
    print("=" * 70)
    print("5. Infinite height: the power ladder 2^(n^k) does not collapse")
    print("=" * 70)
    for k in (1, 2, 3):
        n = ladder_gap_witness(k, c=3)
        lo, hi = 2 ** (n ** k), 2 ** (n ** (k + 1))
        print(f"  k={k}: gap witness n={n}  "
              f"(2^(n^{k})+2)^3 = {(lo+2)**3} < 2^(n^{k+1}) = {hi}")

    print()
    print("=" * 70)
    print("6. Density along the ladder (parity-glued intermediate degree)")
    print("=" * 70)
    k = 1
    inter = inter_pow_size(k)
    lo_fn, hi_fn = pow_ladder_size(k), pow_ladder_size(k + 1)
    print("   n : 2^(n^1)   inter(n)    2^(n^2)")
    for n in range(6):
        print(f"  {n:2d} : {lo_fn(n):7d} {inter(n):11d} {hi_fn(n):10d}")
    ev = ladder_gap_witness_with_parity(k, c=2, even=True)
    od = ladder_gap_witness_with_parity(k, c=2, even=False)
    print(f"  even witness n={ev} keeps fast rate (lower rung can't catch inter)")
    print(f"  odd  witness n={od} drops to slow rate (inter can't catch upper rung)")
    print("  => powSystem 1  <  interPowSys 1  <  powSystem 2")

    print()
    print("=" * 70)
    print("7. No greatest p-degree: diagonalize against any candidate top")
    print("=" * 70)
    # Model a candidate top T whose chosen proof of theorem t has size sec(t).
    sec = lambda t: (t % 5) + 2      # T's local proof sizes (any function)
    diag = diagonal_size(sec)
    print("   t : sec(t)  diag(t)=2^sec(t)+2^t")
    for t in range(8):
        print(f"  {t:2d} : {sec(t):5d} {diag(t):12d}")
    # Any monotone poly blow-up f of sec must dominate 2^sec(t)+2^t at every t.
    # Since sec is bounded, 2^t escapes any constant bound -> no such f.
    bound = max((sec(t) + 2) ** 6 for t in range(8))
    escapes = next(t for t in range(64) if 2 ** t >= bound)
    print(f"  any (sec+2)^6 bound is < {bound}, but 2^t reaches it at t={escapes}")
    print("  => the diagonal degree exceeds T, so T is not a top element")


if __name__ == "__main__":
    demo()
