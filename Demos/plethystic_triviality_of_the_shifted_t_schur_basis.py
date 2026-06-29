"""
demo.py — Numerical demonstration of plethystic triviality of the shifted t-Schur basis.

This script gives a fully self-contained, exact (rational-arithmetic) implementation of:

  * the odd power-sum ring  Gamma = K[p_1, p_3, p_5, ...]   (X_k stands for p_{2k+1}),
  * the diagonal plethysm    phi_t : p_{2k+1} -> (1 - t^{2k+1}) p_{2k+1}  and its
    inverse psi_t : p_{2k+1} -> p_{2k+1} / (1 - t^{2k+1}),
  * the vertex-operator construction of the Schur Q-functions  Q_lambda  and the shifted
    t-Schur functions  S^t_lambda,

and then verifies, at an exact rational value of the deformation parameter t, the headline
results from the formal development:

  (1) Triviality identity           S^t_lambda = phi_t(Q_lambda)        [Sfun_eq_phiT_Qfun]
  (2) Inversion                      Q_lambda  = psi_t(S^t_lambda)      [Qfun_eq_psiT_Sfun]
  (3) phi_t is an automorphism       psi_t(phi_t(f)) = f                [phiTEquiv]
  (4) Diagonal monoid law            Phi_a . Phi_b = Phi_{a*b}          [diagHom_comp]
  (5) Injectivity dichotomy          Phi_a non-injective if some a_k=0  [diagHom_injective_iff]

All arithmetic uses Python's exact `Fraction`, so the equalities below are checked exactly,
not approximately.  The parameter t is instantiated to a generic rational (default 1/2);
because the underlying identities hold over Q(t), they hold at every such non-degenerate
value, which is what the numerical run confirms.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, List, Tuple

# A monomial in the odd power sums: a sorted tuple of (variable index k, exponent e>0).
# The empty tuple is the constant monomial 1.
Monomial = Tuple[Tuple[int, int], ...]

# An element of Gamma = K[X_0, X_1, ...]: a map monomial -> coefficient in K (here Q).
SymFunc = Dict[Monomial, Fraction]

# An element of Gamma[u]: a map (u-degree) -> SymFunc.
PolyU = Dict[int, SymFunc]


# --------------------------------------------------------------------------------------
# Basic algebra of Gamma = K[X_0, X_1, ...]
# --------------------------------------------------------------------------------------

def sf_zero() -> SymFunc:
    return {}


def sf_const(c: Fraction) -> SymFunc:
    return {(): c} if c != 0 else {}


def sf_gen(k: int) -> SymFunc:
    """The generator X_k, i.e. the odd power sum p_{2k+1}."""
    return {((k, 1),): Fraction(1)}


def sf_clean(f: SymFunc) -> SymFunc:
    return {m: c for m, c in f.items() if c != 0}


def sf_add(f: SymFunc, g: SymFunc) -> SymFunc:
    out: SymFunc = dict(f)
    for m, c in g.items():
        out[m] = out.get(m, Fraction(0)) + c
    return sf_clean(out)


def sf_scale(c: Fraction, f: SymFunc) -> SymFunc:
    if c == 0:
        return {}
    return {m: c * v for m, v in f.items()}


def _mono_mul(m1: Monomial, m2: Monomial) -> Monomial:
    exps: Dict[int, int] = {}
    for k, e in m1:
        exps[k] = exps.get(k, 0) + e
    for k, e in m2:
        exps[k] = exps.get(k, 0) + e
    return tuple(sorted((k, e) for k, e in exps.items() if e > 0))


def sf_mul(f: SymFunc, g: SymFunc) -> SymFunc:
    out: SymFunc = {}
    for m1, c1 in f.items():
        for m2, c2 in g.items():
            m = _mono_mul(m1, m2)
            out[m] = out.get(m, Fraction(0)) + c1 * c2
    return sf_clean(out)


def sf_eq(f: SymFunc, g: SymFunc) -> bool:
    return sf_clean(f) == sf_clean(g)


# --------------------------------------------------------------------------------------
# Diagonal plethysms Phi_a : X_k -> a_k X_k, and the operators phi_t, psi_t
# --------------------------------------------------------------------------------------

def diag_hom(a: List[Fraction], f: SymFunc) -> SymFunc:
    """Apply the diagonal plethysm Phi_a (multiply each X_k by the scalar a[k])."""
    out: SymFunc = {}
    for m, c in f.items():
        factor = Fraction(1)
        for k, e in m:
            factor *= a[k] ** e
        out[m] = out.get(m, Fraction(0)) + c * factor
    return sf_clean(out)


def cc(t: Fraction, k: int) -> Fraction:
    """The deformation scalar c_k = 1 - t^{2k+1}."""
    return Fraction(1) - t ** (2 * k + 1)


def phi_t(t: Fraction, f: SymFunc, kmax: int) -> SymFunc:
    return diag_hom([cc(t, k) for k in range(kmax + 1)], f)


def psi_t(t: Fraction, f: SymFunc, kmax: int) -> SymFunc:
    return diag_hom([Fraction(1) / cc(t, k) for k in range(kmax + 1)], f)


# --------------------------------------------------------------------------------------
# The vertex-operator construction
# --------------------------------------------------------------------------------------

def creation(cf: List[SymFunc], n_max: int) -> List[SymFunc]:
    """One-row creation functions q_0,...,q_{n_max} via the Newton recursion (qGen)."""
    q: List[SymFunc] = [sf_const(Fraction(1))]
    for m in range(0, n_max):
        acc = sf_zero()
        for k in range(0, m // 2 + 1):
            term = sf_scale(Fraction(2), sf_mul(cf[k], q[m - 2 * k]))
            acc = sf_add(acc, term)
        q.append(sf_scale(Fraction(1, m + 1), acc))
    return q


def ann_gen(d: List[Fraction], f: SymFunc, kmax: int) -> PolyU:
    """Annihilation A_d : X_k -> X_k - d_k u^{2k+1}, an algebra map into Gamma[u]."""
    # image of each generator as a PolyU
    gen_img: List[PolyU] = []
    for k in range(kmax + 1):
        gen_img.append({0: sf_gen(k), 2 * k + 1: sf_const(-d[k])})

    def pu_mul(p: PolyU, qq: PolyU) -> PolyU:
        out: PolyU = {}
        for du, fu in p.items():
            for dv, gv in qq.items():
                out[du + dv] = sf_add(out.get(du + dv, sf_zero()), sf_mul(fu, gv))
        return {d_: sf_clean(v) for d_, v in out.items() if sf_clean(v)}

    out: PolyU = {0: sf_zero()}
    for m, c in f.items():
        term: PolyU = {0: sf_const(c)}
        for k, e in m:
            for _ in range(e):
                term = pu_mul(term, gen_img[k])
        for du, fu in term.items():
            out[du] = sf_add(out.get(du, sf_zero()), fu)
    return {d_: v for d_, v in out.items() if sf_clean(v)}


def tsum(qf: List[SymFunc], n: int, p: PolyU) -> SymFunc:
    """T_{qf,n}(P) = sum_m qf_{n+m} * P_m."""
    out = sf_zero()
    for du, coeff in p.items():
        idx = n + du
        if idx < len(qf):
            out = sf_add(out, sf_mul(qf[idx], coeff))
    return out


def vertex_B(q: List[SymFunc], d: List[Fraction], n: int, f: SymFunc, kmax: int) -> SymFunc:
    return tsum(q, n, ann_gen(d, f, kmax))


def schur_Q(parts: List[int], q: List[SymFunc], kmax: int) -> SymFunc:
    """Q_lambda = B_{lambda_1}(...B_{lambda_l}(1)...) with the undeformed data (d_k = 4)."""
    d = [Fraction(4) for _ in range(kmax + 1)]
    f = sf_const(Fraction(1))
    for n in reversed(parts):
        f = vertex_B(q, d, n, f, kmax)
    return f


def shifted_tSchur(parts: List[int], qt: List[SymFunc], t: Fraction, kmax: int) -> SymFunc:
    """S^t_lambda with the deformed creation functions qt and d_k = 4/c_k."""
    d = [Fraction(4) / cc(t, k) for k in range(kmax + 1)]
    f = sf_const(Fraction(1))
    for n in reversed(parts):
        f = vertex_B(qt, d, n, f, kmax)
    return f


# --------------------------------------------------------------------------------------
# Pretty-printing
# --------------------------------------------------------------------------------------

def sf_str(f: SymFunc) -> str:
    if not sf_clean(f):
        return "0"
    parts = []
    for m in sorted(f, key=lambda mm: (len(mm), mm)):
        c = f[m]
        if not m:
            parts.append(f"{c}")
        else:
            mon = "*".join(f"p{2*k+1}^{e}" if e > 1 else f"p{2*k+1}" for k, e in m)
            parts.append(f"({c})*{mon}")
    return " + ".join(parts)


# --------------------------------------------------------------------------------------
# Main demonstration
# --------------------------------------------------------------------------------------

def main() -> None:
    t = Fraction(1, 2)        # a generic non-degenerate value of the parameter
    kmax = 6                  # highest variable index X_kmax = p_{2*kmax+1}
    n_max = 14                # highest one-row creation function

    cf_plain: List[SymFunc] = [sf_gen(k) for k in range(kmax + 1)]
    cf_def: List[SymFunc] = [sf_scale(cc(t, k), sf_gen(k)) for k in range(kmax + 1)]
    q = creation(cf_plain, n_max)
    qt = creation(cf_def, n_max)

    print("=" * 78)
    print(f"Plethystic triviality demo   (t = {t})")
    print("=" * 78)

    # Sanity: q_t = phi_t(q)  [qt_eq_phiT_q]
    print("\n[Creation functions intertwine]  q^t_m == phi_t(q_m):")
    ok = all(sf_eq(qt[m], phi_t(t, q[m], kmax)) for m in range(n_max + 1))
    print(f"   verified for m = 0..{n_max}:  {ok}")

    # Smallest case lambda = (1)
    Q1 = schur_Q([1], q, kmax)
    S1 = shifted_tSchur([1], qt, t, kmax)
    print("\n[Smallest case lambda = (1)]")
    print(f"   Q_(1)   = {sf_str(Q1)}        (expect 2*p1)")
    print(f"   S^t_(1) = {sf_str(S1)}   (expect 2*(1-t)*p1 = {2*(Fraction(1)-t)}*p1)")

    strict_partitions: List[List[int]] = [
        [1], [2], [2, 1], [3, 1], [3, 2], [3, 2, 1], [4, 2, 1], [4, 3, 1], [5, 3, 1],
    ]

    print("\n[Triviality identity]  S^t_lambda == phi_t(Q_lambda)   [Sfun_eq_phiT_Qfun]")
    all_ok = True
    for lam in strict_partitions:
        Q = schur_Q(lam, q, kmax)
        S = shifted_tSchur(lam, qt, t, kmax)
        lhs = S
        rhs = phi_t(t, Q, kmax)
        good = sf_eq(lhs, rhs)
        all_ok &= good
        print(f"   lambda = {str(lam):12s}:  {good}")
    print(f"   ALL: {all_ok}")

    print("\n[Inversion]  Q_lambda == psi_t(S^t_lambda)   [Qfun_eq_psiT_Sfun]")
    inv_ok = True
    for lam in strict_partitions:
        Q = schur_Q(lam, q, kmax)
        S = shifted_tSchur(lam, qt, t, kmax)
        good = sf_eq(Q, psi_t(t, S, kmax))
        inv_ok &= good
        print(f"   lambda = {str(lam):12s}:  {good}")
    print(f"   ALL: {inv_ok}")

    print("\n[Automorphism]  psi_t(phi_t(f)) == f   [phiTEquiv]")
    samples = [schur_Q(lam, q, kmax) for lam in strict_partitions]
    auto_ok = all(sf_eq(psi_t(t, phi_t(t, f, kmax), kmax), f) for f in samples)
    print(f"   verified on {len(samples)} sample symmetric functions:  {auto_ok}")

    print("\n[Diagonal monoid law]  Phi_a . Phi_b == Phi_{a*b}   [diagHom_comp]")
    a = [Fraction(k + 2, k + 1) for k in range(kmax + 1)]
    b = [Fraction(2 * k + 3, k + 5) for k in range(kmax + 1)]
    ab = [a[k] * b[k] for k in range(kmax + 1)]
    law_ok = all(
        sf_eq(diag_hom(a, diag_hom(b, f)), diag_hom(ab, f)) for f in samples
    )
    print(f"   verified on {len(samples)} sample symmetric functions:  {law_ok}")

    print("\n[Injectivity dichotomy]  some a_k = 0  =>  Phi_a not injective   [diagHom_injective_iff]")
    a_zero = [Fraction(1) for _ in range(kmax + 1)]
    a_zero[2] = Fraction(0)
    collapsed = diag_hom(a_zero, sf_gen(2))
    print(f"   Phi_a(p5) with a_2 = 0  ->  {sf_str(collapsed)}   (collapsed to 0: {not sf_clean(collapsed)})")

    print("\n" + "=" * 78)
    overall = ok and all_ok and inv_ok and auto_ok and law_ok and (not sf_clean(collapsed))
    print(f"OVERALL: all demonstrated identities hold exactly:  {overall}")
    print("=" * 78)


if __name__ == "__main__":
    main()
