"""
demo.py — Invariance of the separable degree m_f under purely inseparable base change.

This script demonstrates, with exact symbolic arithmetic over F_p, the main theorem:

    For a simple algebraic extension L = K(theta) in characteristic p > 0 with minimal
    polynomial f = minpoly_K(theta), and any purely inseparable extension N/K, the
    invariant

        m_f := natSepDegree(f) = (number of DISTINCT roots of f)

    is unchanged when we base change to N:   m_{f,N} = m_f.

We model the base field as the rational function field K = F_p(t) (an imperfect field,
which is what makes nontrivial purely inseparable extensions possible).  A purely
inseparable extension is N = K(t^{1/p^k}) = F_p(u) with u^{p^k} = t.

Key computable facts used (all field-theoretic identities turned into syntactic operations):

  * For an IRREDUCIBLE f over a field of characteristic p, we may write f(X) = g(X^{p^e})
    with g separable irreducible, and m_f = deg(g) = deg(f) / p^e, where p^e is the
    LARGEST power of p dividing every nonzero X-exponent of f.  This is a purely syntactic
    read-off of the X-exponents, mirroring `Polynomial.natSepDegree`.

  * Under purely inseparable base change t |-> u^{p^k}, the base-changed polynomial factors
    as f-tilde = (minpoly_N theta)^{p^j}.  We recover minpoly_N theta by extracting p-th
    roots (a polynomial over F_p(u) in char p is a perfect p-th power iff all its X-exponents
    and all its u-exponents are divisible by p; the p-th root in F_p is the identity since
    a^p = a).

  * Because f and minpoly_N theta have exactly the SAME set of distinct roots, their
    separable degrees coincide:  m_{f,N} = m_f  (this is the theorem
    `InseparableBaseChange.mInvariant_base_change`).

The script also illustrates:
  * `mInvariant_dvd_natDegree`:  m_f always divides deg f.
  * `mInvariant_eq_one_iff_isPurelyInseparable`:  m_f = 1 marks the purely inseparable case.
  * `natDegree_minpoly_base_change_of_separable`:  if theta is separable (m_f = deg f),
    the FULL degree is preserved by base change; in the inseparable case it can strictly drop.
"""

from __future__ import annotations
from math import gcd
from functools import reduce
from typing import Dict, Tuple

# A polynomial f in K[X] with K = F_p(<var>) is represented as:
#   Dict[int, Dict[int, int]]
# mapping  X-exponent  ->  ( base-variable-exponent -> coefficient in F_p ).
# Example over F_2(t):  X^4 + t*X^2 + t  is  {4:{0:1}, 2:{1:1}, 0:{1:1}}.

Poly = Dict[int, Dict[int, int]]


def normalize(f: Poly, p: int) -> Poly:
    """Reduce all coefficients mod p and drop zero terms."""
    out: Poly = {}
    for xe, coeff in f.items():
        c: Dict[int, int] = {}
        for be, v in coeff.items():
            v %= p
            if v != 0:
                c[be] = v
        if c:
            out[xe] = c
    return out


def x_degree(f: Poly) -> int:
    """The X-degree of f."""
    return max(f.keys()) if f else 0


def largest_p_power_dividing_exponents(f: Poly, p: int) -> int:
    """Return e where p^e is the largest power of p dividing every nonzero X-exponent of f.

    For an irreducible f, f(X) = g(X^{p^e}) with g separable, so this is the inseparable
    exponent.
    """
    exps = [xe for xe in f.keys() if xe != 0]
    if not exps:
        return 0
    g = reduce(gcd, exps)
    e = 0
    while g % p == 0 and g > 0:
        g //= p
        e += 1
    return e


def nat_sep_degree(f: Poly, p: int) -> int:
    """m_f = natSepDegree(f) = deg(f) / p^e, the number of distinct roots of irreducible f."""
    e = largest_p_power_dividing_exponents(f, p)
    return x_degree(f) // (p ** e)


def is_perfect_pth_power(f: Poly, p: int) -> bool:
    """A polynomial over F_p(u) is a perfect p-th power iff every X-exponent is divisible
    by p and every coefficient (a polynomial in u) has all u-exponents divisible by p."""
    for xe, coeff in f.items():
        if xe % p != 0:
            return False
        for be in coeff:
            if be % p != 0:
                return False
    return True


def pth_root(f: Poly, p: int) -> Poly:
    """Given a perfect p-th power, return its p-th root.  In F_p the p-th root is the
    identity (a^p = a), so we only divide X- and u-exponents by p."""
    out: Poly = {}
    for xe, coeff in f.items():
        out[xe // p] = {be // p: v for be, v in coeff.items()}
    return normalize(out, p)


def maximal_pth_root(f: Poly, p: int) -> Tuple[Poly, int]:
    """Extract p-th roots until f is no longer a perfect p-th power.
    Returns (root, j) with f = root^{p^j}."""
    j = 0
    while is_perfect_pth_power(f, p):
        f = pth_root(f, p)
        j += 1
    return f, j


def base_change(f: Poly, p: int, k: int) -> Poly:
    """Base change t |-> u^{p^k}, i.e. K = F_p(t) -> N = F_p(u) with u^{p^k} = t.
    This multiplies every base-variable exponent by p^k."""
    factor = p ** k
    out: Poly = {}
    for xe, coeff in f.items():
        out[xe] = {be * factor: v for be, v in coeff.items()}
    return normalize(out, p)


def minpoly_over_N(f: Poly, p: int, k: int) -> Tuple[Poly, int]:
    """Minimal polynomial of theta over N = K(t^{1/p^k}).
    f-tilde = (minpoly_N theta)^{p^j}; we recover minpoly_N theta by maximal p-th root."""
    ftilde = base_change(f, p, k)
    return maximal_pth_root(ftilde, p)


def show(f: Poly, var: str = "t") -> str:
    """Pretty-print a polynomial for display."""
    if not f:
        return "0"
    terms = []
    for xe in sorted(f.keys(), reverse=True):
        coeff = f[xe]
        cparts = []
        for be in sorted(coeff.keys(), reverse=True):
            v = coeff[be]
            if be == 0:
                cparts.append(f"{v}")
            elif be == 1:
                cparts.append(f"{v}*{var}" if v != 1 else var)
            else:
                cparts.append(f"{v}*{var}^{be}" if v != 1 else f"{var}^{be}")
        cstr = "+".join(cparts)
        if xe == 0:
            terms.append(f"({cstr})")
        elif xe == 1:
            terms.append(f"({cstr})*X" if cstr != "1" else "X")
        else:
            terms.append(f"({cstr})*X^{xe}" if cstr != "1" else f"X^{xe}")
    return " + ".join(terms)


def analyze(name: str, f: Poly, p: int, k: int) -> None:
    """Full report on one example: m_f over K, divisibility, base change to N, invariance."""
    f = normalize(f, p)
    mK = nat_sep_degree(f, p)
    degK = x_degree(f)
    eK = largest_p_power_dividing_exponents(f, p)

    print("=" * 74)
    print(f"{name}   (characteristic p = {p})")
    print(f"  f(X) over K = F_{p}(t):   {show(f, 't')}")
    print(f"  deg f                  = {degK}")
    print(f"  inseparable exponent e = {eK}   (inseparable degree p^e = {p**eK})")
    print(f"  m_f = natSepDegree(f)  = {mK}   = #distinct roots of f")
    assert degK % mK == 0, "m_f must divide deg f"
    print(f"  CHECK mInvariant_dvd_natDegree:  m_f | deg f   ->  {mK} | {degK}  OK")
    if mK == 1:
        print("  m_f = 1  ->  K(theta)/K is PURELY INSEPARABLE "
              "(mInvariant_eq_one_iff_isPurelyInseparable)")
    elif mK == degK:
        print("  m_f = deg f  ->  theta is SEPARABLE over K")
    else:
        print("  1 < m_f < deg f  ->  genuinely MIXED extension")

    g, j = minpoly_over_N(f, p, k)
    mN = nat_sep_degree(g, p)
    degN = x_degree(g)
    print(f"  --- base change to N = K(t^(1/p^{k})) = F_{p}(u), u^(p^{k}) = t ---")
    print(f"  f base-changed = (minpoly_N theta)^(p^{j})")
    print(f"  minpoly_N theta        = {show(g, 'u')}")
    print(f"  [N(theta):N] = deg     = {degN}    (was [K(theta):K] = {degK})")
    print(f"  m_{{f,N}}                 = {mN}")
    print(f"  *** mInvariant_base_change:  m_{{f,N}} = m_f   ->  {mN} = {mK}  "
          f"{'OK' if mN == mK else 'FAIL'} ***")
    assert mN == mK, "MAIN THEOREM VIOLATED"
    if mK == degK and degN == degK:
        print("  theta separable AND degree preserved "
              "(natDegree_minpoly_base_change_of_separable)")
    elif degN < degK:
        print(f"  raw degree DROPPED {degK} -> {degN}: inseparable part absorbed by N "
              "(degree is NOT invariant)")
    print()


def main() -> None:
    p = 2
    # Example 1 -- purely inseparable, collapsing: f = X^2 - t (= X^2 + t in char 2).
    #   m_f = 1 over K; base change N = K(sqrt t) makes theta = sqrt t in N: degree p -> 1.
    analyze("Example 1: collapsing purely inseparable  f = X^2 + t",
            {2: {0: 1}, 0: {1: 1}}, p, k=1)

    # Example 2 -- genuinely mixed: f = X^4 + t X^2 + t = g(X^2), g = Y^2 + tY + t separable.
    #   m_f = 2, deg f = 4.  Base change N = K(sqrt t) absorbs the inseparable factor:
    #   degree drops 4 -> 2, but m_f stays 2.
    analyze("Example 2: mixed extension  f = X^4 + t X^2 + t",
            {4: {0: 1}, 2: {1: 1}, 0: {1: 1}}, p, k=1)

    # Example 3 -- separable: f = X^2 + t X + t, f' = t != 0 separable, m_f = deg f = 2.
    #   Base change preserves the FULL degree (separable case).
    analyze("Example 3: separable extension  f = X^2 + t X + t",
            {2: {0: 1}, 1: {1: 1}, 0: {1: 1}}, p, k=1)

    # Example 4 -- higher characteristic, mixed: p = 3, f = X^9 + t X^3 + t = g(X^3),
    #   g = Y^3 + tY + t separable.  m_f = 3, deg f = 9, inseparable exponent e = 1.
    analyze("Example 4: char 3 mixed  f = X^9 + t X^3 + t",
            {9: {0: 1}, 3: {1: 1}, 0: {1: 1}}, p=3, k=1)

    # Example 5 -- deeper inseparability: p = 2, f = X^8 + t (= X^{2^3} - t).
    #   m_f = 1 (purely inseparable, one distinct root), deg 8, e = 3.
    #   Base change by k = 2 (N = K(t^{1/4})) absorbs two of the three inseparable layers:
    #   degree drops 8 -> 2 but m_f stays 1.
    analyze("Example 5: deep purely inseparable  f = X^8 + t,  N = K(t^(1/4))",
            {8: {0: 1}, 0: {1: 1}}, p=2, k=2)

    print("All examples satisfy m_{f,N} = m_f  (mInvariant_base_change).")


if __name__ == "__main__":
    main()


"""
visualize.py — The rigidity of m_f vs. the collapse of the raw degree.

Produces a grouped bar chart over a family of irreducible polynomials in
characteristic p, comparing for each example:
  * deg f over K            (the raw degree, before base change),
  * [N(theta):N] over N     (the degree after purely inseparable base change),
  * m_f = m_{f,N}           (the separable invariant, equal before and after).

The picture makes the theorem visible: the separable invariant (flat line of
markers) does not move, while the raw degree (tall bars) can collapse.
"""

from __future__ import annotations
from math import gcd
from functools import reduce
from typing import Dict, List, Tuple

Poly = Dict[int, Dict[int, int]]


def normalize(f: Poly, p: int) -> Poly:
    out: Poly = {}
    for xe, coeff in f.items():
        c = {be: v % p for be, v in coeff.items() if v % p != 0}
        if c:
            out[xe] = c
    return out


def x_degree(f: Poly) -> int:
    return max(f.keys()) if f else 0


def insep_exponent(f: Poly, p: int) -> int:
    exps = [xe for xe in f if xe != 0]
    if not exps:
        return 0
    g, e = reduce(gcd, exps), 0
    while g > 0 and g % p == 0:
        g //= p
        e += 1
    return e


def nat_sep_degree(f: Poly, p: int) -> int:
    return x_degree(f) // (p ** insep_exponent(f, p))


def is_pth_power(f: Poly, p: int) -> bool:
    return all(xe % p == 0 and all(be % p == 0 for be in c) for xe, c in f.items())


def pth_root(f: Poly, p: int) -> Poly:
    return normalize({xe // p: {be // p: v for be, v in c.items()}
                      for xe, c in f.items()}, p)


def minpoly_over_N(f: Poly, p: int, k: int) -> Poly:
    g = normalize({xe: {be * p ** k: v for be, v in c.items()}
                   for xe, c in f.items()}, p)
    while is_pth_power(g, p):
        g = pth_root(g, p)
    return g


def main() -> None:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import numpy as np

    examples: List[Tuple[str, int, Poly, int]] = [
        ("$X^2+t$\n(p=2)", 2, {2: {0: 1}, 0: {1: 1}}, 1),
        ("$X^4+tX^2+t$\n(p=2)", 2, {4: {0: 1}, 2: {1: 1}, 0: {1: 1}}, 1),
        ("$X^2+tX+t$\n(p=2)", 2, {2: {0: 1}, 1: {1: 1}, 0: {1: 1}}, 1),
        ("$X^9+tX^3+t$\n(p=3)", 3, {9: {0: 1}, 3: {1: 1}, 0: {1: 1}}, 1),
        ("$X^8+t$\n(p=2,k=2)", 2, {8: {0: 1}, 0: {1: 1}}, 2),
    ]

    labels, degK, degN, mvals = [], [], [], []
    for name, p, f, k in examples:
        f = normalize(f, p)
        labels.append(name)
        degK.append(x_degree(f))
        degN.append(x_degree(minpoly_over_N(f, p, k)))
        mvals.append(nat_sep_degree(f, p))

    x = np.arange(len(labels))
    w = 0.35
    fig, ax = plt.subplots(figsize=(11, 6))
    ax.bar(x - w / 2, degK, w, label=r"$\deg f$ over $K$", color="#4C72B0")
    ax.bar(x + w / 2, degN, w, label=r"$[N(\theta):N]$ over $N$", color="#C44E52")
    ax.plot(x, mvals, "o-", color="#000000", markersize=11, linewidth=2,
            label=r"$m_f = m_{f,N}$ (invariant)")
    for xi, m in zip(x, mvals):
        ax.annotate(f"{m}", (xi, m), textcoords="offset points", xytext=(0, 10),
                    ha="center", fontweight="bold")

    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.set_ylabel("degree")
    ax.set_title("Purely inseparable base change: the raw degree collapses,\n"
                 r"but the separable invariant $m_f$ is rigid")
    ax.legend()
    ax.grid(axis="y", alpha=0.3)
    fig.tight_layout()
    fig.savefig("m_f_invariance.png", dpi=150)
    print("wrote m_f_invariance.png")


if __name__ == "__main__":
    main()
