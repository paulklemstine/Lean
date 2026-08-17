"""
Fourier Analysis on Finite Abelian Groups — numerical demonstrations.

This self-contained script (standard library only) implements the discrete Fourier
transform on an arbitrary finite abelian group

        G = Z/n_1 x Z/n_2 x ... x Z/n_r,

written additively, together with its dual group of characters, and verifies
numerically every theorem discussed in the accompanying article and paper:

  1. Orthogonality of characters (both "primal" and "dual" forms).
  2. Fourier inversion, and the fact that the transform is a linear bijection.
  3. Parseval / Plancherel:  sum_psi |f^(psi)|^2 = |G| * sum_x |f(x)|^2.
  4. The convolution theorem:  (f * g)^ = f^ . g^.
  5. The square of the transform:  F^2 = |G| . (reflection).
  6. The Donoho-Stark uncertainty principle:  |supp f| . |supp f^| >= |G|,
     with equality for Dirac deltas, subgroup indicators, and modulated
     translates of subgroup indicators.
  7. Subgroup duality:  1_H^ = |H| . 1_{H^perp}  and  |H| . |H^perp| = |G|,
     plus Poisson summation.
  8. The Fourier counting formula for sumsets, the additive-energy identity,
     the covering bound, and the exact equivalence of the Cauchy-Schwarz
     threshold with the pigeonhole threshold.

Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
import itertools
import math
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Elem = Tuple[int, ...]          # an element of G, and also an index for a character
Func = Dict[Elem, complex]      # a function G -> C

TOL = 1e-9


# ---------------------------------------------------------------------------
# The group and its dual
# ---------------------------------------------------------------------------

def elements(moduli: Sequence[int]) -> List[Elem]:
    """All elements of G = Z/n_1 x ... x Z/n_r, in lexicographic order."""
    return [tuple(t) for t in itertools.product(*(range(n) for n in moduli))]


def add(moduli: Sequence[int], x: Elem, y: Elem) -> Elem:
    """Group addition in G."""
    return tuple((a + b) % n for a, b, n in zip(x, y, moduli))


def sub(moduli: Sequence[int], x: Elem, y: Elem) -> Elem:
    """Group subtraction in G."""
    return tuple((a - b) % n for a, b, n in zip(x, y, moduli))


def neg(moduli: Sequence[int], x: Elem) -> Elem:
    """Additive inverse in G."""
    return tuple((-a) % n for a, n in zip(x, moduli))


def character(moduli: Sequence[int], k: Elem) -> Callable[[Elem], complex]:
    """The character psi_k(x) = exp(2*pi*i * sum_j k_j x_j / n_j).

    As k runs over G these are exactly the |G| characters of G, so the dual
    group is (non-canonically) identified with G itself.
    """
    def psi(x: Elem) -> complex:
        phase = sum(2.0 * math.pi * kj * xj / nj for kj, xj, nj in zip(k, x, moduli))
        return cmath.exp(1j * phase)
    return psi


# ---------------------------------------------------------------------------
# The transform
# ---------------------------------------------------------------------------

def dft(moduli: Sequence[int], f: Func) -> Func:
    """Discrete Fourier transform:  f^(psi_k) = sum_x conj(psi_k(x)) f(x)."""
    G = elements(moduli)
    out: Func = {}
    for k in G:
        psi = character(moduli, k)
        out[k] = sum(psi(x).conjugate() * f[x] for x in G)
    return out


def idft(moduli: Sequence[int], F: Func) -> Func:
    """Inverse transform:  f(x) = (1/|G|) sum_k psi_k(x) F(psi_k)."""
    G = elements(moduli)
    N = len(G)
    out: Func = {}
    for x in G:
        out[x] = sum(character(moduli, k)(x) * F[k] for k in G) / N
    return out


def conv(moduli: Sequence[int], f: Func, g: Func) -> Func:
    """Convolution:  (f * g)(x) = sum_y f(y) g(x - y)."""
    G = elements(moduli)
    return {x: sum(f[y] * g[sub(moduli, x, y)] for y in G) for x in G}


def support(f: Func) -> List[Elem]:
    """The set of points where f does not vanish."""
    return [x for x, v in f.items() if abs(v) > TOL]


def indicator(moduli: Sequence[int], A: Iterable[Elem]) -> Func:
    """The complex indicator function 1_A."""
    S = set(A)
    return {x: (1.0 + 0j if x in S else 0j) for x in elements(moduli)}


def delta(moduli: Sequence[int], a: Elem) -> Func:
    """The Dirac delta at a."""
    return {x: (1.0 + 0j if x == a else 0j) for x in elements(moduli)}


# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

def close(a: complex, b: complex) -> bool:
    return abs(a - b) < 1e-7


def report(name: str, ok: bool, extra: str = "") -> None:
    mark = "OK  " if ok else "FAIL"
    print(f"  [{mark}] {name}{('  ' + extra) if extra else ''}")
    assert ok, name


def check_orthogonality(moduli: Sequence[int]) -> None:
    G = elements(moduli)
    N = len(G)
    ok_dual = True
    for x in G:
        for y in G:
            s = sum(character(moduli, k)(x) * character(moduli, k)(y).conjugate() for k in G)
            ok_dual &= close(s, N if x == y else 0)
    ok_primal = True
    for k in G:
        for l in G:
            s = sum(character(moduli, k)(x) * character(moduli, l)(x).conjugate() for x in G)
            ok_primal &= close(s, N if k == l else 0)
    report("dual orthogonality   sum_psi psi(x) conj(psi(y)) = |G| [x=y]", ok_dual)
    report("primal orthogonality sum_x psi(x) conj(chi(x)) = |G| [psi=chi]", ok_primal)


def random_function(moduli: Sequence[int], seed: int) -> Func:
    """A deterministic pseudo-random complex function on G."""
    state = seed
    out: Func = {}
    for x in elements(moduli):
        state = (1103515245 * state + 12345) % (1 << 31)
        re = (state % 1000) / 500.0 - 1.0
        state = (1103515245 * state + 12345) % (1 << 31)
        im = (state % 1000) / 500.0 - 1.0
        out[x] = complex(re, im)
    return out


def check_inversion_parseval_conv(moduli: Sequence[int]) -> None:
    G = elements(moduli)
    N = len(G)
    f = random_function(moduli, 7)
    g = random_function(moduli, 23)

    back = idft(moduli, dft(moduli, f))
    report("Fourier inversion", all(close(back[x], f[x]) for x in G))

    lhs = sum(abs(v) ** 2 for v in dft(moduli, f).values())
    rhs = N * sum(abs(v) ** 2 for v in f.values())
    report("Parseval  sum|f^|^2 = |G| sum|f|^2", close(lhs, rhs),
           f"({lhs:.6f} vs {rhs:.6f})")

    fh, gh = dft(moduli, f), dft(moduli, g)
    ch = dft(moduli, conv(moduli, f, g))
    report("convolution theorem  (f*g)^ = f^ . g^",
           all(close(ch[k], fh[k] * gh[k]) for k in G))

    # F^2 = |G| . reflection:  applying the transform twice returns |G| f(-x).
    # Under the identification k <-> x of G with its dual, dft(dft f)(x) = |G| f(-x).
    ff = dft(moduli, dft(moduli, f))
    report("square of the transform  F^2 = |G| . reflection",
           all(close(ff[x], N * f[neg(moduli, x)]) for x in G))


def check_uncertainty(moduli: Sequence[int]) -> None:
    G = elements(moduli)
    N = len(G)
    worst = None
    for seed in range(1, 9):
        f = random_function(moduli, seed)
        p = len(support(f)) * len(support(dft(moduli, f)))
        worst = p if worst is None else min(worst, p)
    report("uncertainty for random f:  |supp f| . |supp f^| >= |G|",
           worst is not None and worst >= N, f"(min product {worst}, |G| = {N})")

    a = G[len(G) // 2]
    d = delta(moduli, a)
    prod = len(support(d)) * len(support(dft(moduli, d)))
    report("Dirac delta is extremal:  1 . |G| = |G|", prod == N, f"(product {prod})")


def subgroup_generated(moduli: Sequence[int], gens: Sequence[Elem]) -> List[Elem]:
    """The subgroup of G generated by the given elements (closure under addition)."""
    zero = tuple(0 for _ in moduli)
    H = {zero}
    frontier = [zero]
    while frontier:
        h = frontier.pop()
        for g in gens:
            k = add(moduli, h, g)
            if k not in H:
                H.add(k)
                frontier.append(k)
    return sorted(H)


def check_subgroup_duality(moduli: Sequence[int], gens: Sequence[Elem]) -> None:
    G = elements(moduli)
    N = len(G)
    H = subgroup_generated(moduli, gens)
    ind = indicator(moduli, H)
    indhat = dft(moduli, ind)
    ann = [k for k in G if all(close(character(moduli, k)(h), 1) for h in H)]

    report("1_H^ = |H| . 1_{H^perp}",
           all(close(indhat[k], len(H) if k in ann else 0) for k in G))
    report("|H| . |H^perp| = |G|", len(H) * len(ann) == N,
           f"({len(H)} . {len(ann)} = {N})")
    report("subgroup indicators are extremal for the uncertainty principle",
           len(support(ind)) * len(support(indhat)) == N)

    f = random_function(moduli, 11)
    fh = dft(moduli, f)
    lhs = N * sum(f[h] for h in H)
    rhs = len(H) * sum(fh[k] for k in ann)
    report("Poisson summation  |G| sum_{x in H} f = |H| sum_{psi in H^perp} f^",
           close(lhs, rhs))

    # A modulated translate of a subgroup indicator is still extremal.
    a = G[1] if len(G) > 1 else G[0]
    chi = character(moduli, G[1] if len(G) > 1 else G[0])
    c = 2.5 - 1.5j
    fmod = {x: c * chi(x) * ind[sub(moduli, x, a)] for x in G}
    report("modulated translate of 1_H is extremal",
           len(support(fmod)) * len(support(dft(moduli, fmod))) == N)


def rep_function(moduli: Sequence[int], A: Sequence[Elem], B: Sequence[Elem]) -> Dict[Elem, int]:
    """r_{A,B}(c) = #{(a,b) in A x B : a + b = c}."""
    G = elements(moduli)
    Bs = set(B)
    return {c: sum(1 for a in A if sub(moduli, c, a) in Bs) for c in G}


def check_sumsets(moduli: Sequence[int], A: Sequence[Elem], B: Sequence[Elem]) -> None:
    G = elements(moduli)
    N = len(G)
    r = rep_function(moduli, A, B)
    Ah = dft(moduli, indicator(moduli, A))
    Bh = dft(moduli, indicator(moduli, B))

    ok = True
    for c in G:
        s = sum(character(moduli, k)(c) * Ah[k] * Bh[k] for k in G)
        ok &= close(N * r[c], s)
    report("counting formula  |G| r(c) = sum_psi psi(c) 1_A^(psi) 1_B^(psi)", ok)

    zero = tuple(0 for _ in moduli)
    E = sum(abs(Ah[k]) ** 2 * abs(Bh[k]) ** 2 for k in G if k != zero)
    lhs = N * sum(r[c] ** 2 for c in G)
    rhs = (len(A) * len(B)) ** 2 + E
    report("additive energy identity  |G| sum_c r(c)^2 = (|A||B|)^2 + E",
           close(lhs, rhs), f"({lhs:.4f} vs {rhs:.4f})")

    covered = sum(1 for c in G if r[c] > 0)
    bound = N * (len(A) * len(B)) ** 2 / ((len(A) * len(B)) ** 2 + E)
    report("covering bound  |{c : r(c) > 0}| >= |G|(|A||B|)^2 / ((|A||B|)^2 + E)",
           covered >= bound - 1e-7, f"({covered} >= {bound:.4f})")

    cs = (N - len(A)) * (N - len(B)) < len(A) * len(B)
    pig = N < len(A) + len(B)
    report("Cauchy-Schwarz threshold == pigeonhole threshold", cs == pig,
           f"(both {cs}; |A| = {len(A)}, |B| = {len(B)}, |G| = {N})")
    if cs:
        report("A + B = G", covered == N)


def threshold_equivalence_scan(nmax: int = 40) -> None:
    """Exhaustive check that (N-a)(N-b) < ab  <=>  N < a+b for 0 <= a,b <= N."""
    ok = True
    for N in range(1, nmax + 1):
        for a in range(N + 1):
            for b in range(N + 1):
                ok &= ((N - a) * (N - b) < a * b) == (N < a + b)
    report(f"exhaustive equivalence scan for all |G| <= {nmax}", ok)


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 74)
    print("Fourier analysis on finite abelian groups — numerical verification")
    print("=" * 74)

    for moduli in ([12], [7], [2, 6], [3, 3]):
        G = elements(moduli)
        name = " x ".join(f"Z/{n}" for n in moduli)
        print(f"\nGroup G = {name}   (|G| = {len(G)})")
        check_orthogonality(moduli)
        check_inversion_parseval_conv(moduli)
        check_uncertainty(moduli)

    print("\nSubgroup duality in G = Z/12, H = <3> (order 4)")
    check_subgroup_duality([12], [(3,)])

    print("\nSubgroup duality in G = Z/2 x Z/6, H = <(1,3)>")
    check_subgroup_duality([2, 6], [(1, 3)])

    print("\nSumsets in G = Z/12 with A = {0,1,2,3,4,5,6} and B = {0,2,4,6,8,10}")
    check_sumsets([12], [(i,) for i in range(7)], [(i,) for i in range(0, 12, 2)])

    print("\nSumsets in G = Z/12 with A = {0,1,2} and B = {0,4,8}  (below threshold)")
    check_sumsets([12], [(0,), (1,), (2,)], [(0,), (4,), (8,)])

    print("\nThreshold equivalence")
    threshold_equivalence_scan(40)

    print("\nUncertainty extremals in Z/12: supports of |supp f| . |supp f^| = 12")
    moduli = [12]
    for gens, label in ([[(3,)], "H = <3>"], [[(4,)], "H = <4>"], [[(6,)], "H = <6>"]):
        H = subgroup_generated(moduli, gens)
        ind = indicator(moduli, H)
        ih = dft(moduli, ind)
        print(f"   {label:10s} |supp 1_H| = {len(support(ind)):2d}, "
              f"|supp 1_H^| = {len(support(ih)):2d}, product = "
              f"{len(support(ind)) * len(support(ih))}")

    print("\nAll checks passed.")


if __name__ == "__main__":
    main()
