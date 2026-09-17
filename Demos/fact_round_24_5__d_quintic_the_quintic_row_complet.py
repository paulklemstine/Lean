"""
The type/coset channel of a finite group: numerical demonstration.
==================================================================

This self-contained script demonstrates, numerically, every headline result about
the information channel

        factorization type of f mod p   --->   abelianization coset of p

for quintic polynomials.  It contains no external dependencies beyond the Python
standard library.

Contents
--------
1.  Polynomial arithmetic over F_p and distinct-degree factorization, giving the
    factorization type (= Frobenius cycle type) of f mod p.
2.  Exact closed-form entropies of the five transitive quintic groups
    (C5, D5, F20, A5, S5), checked against direct numerical evaluation.
3.  The empirical Chebotarev histogram of x^5 + 20x + 32, compared with the
    D5 class fractions {1/10, 4/10, 5/10}.
4.  The quadratic-resolvent identification: type parity versus the Kronecker
    symbol (-20 | p), and the exact residue-dial mutual information
    I(p mod 20 ; T) = 1 bit.
5.  The saturation criterion: F20 fails it and loses exactly 1/2 bit.
6.  The pair law and the which-factor wall, computed exactly on D5 x D5.

Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd as _int_gcd
from math import log2
from typing import Dict, Iterable, List, Sequence, Tuple

Poly = List[int]  # little-endian coefficient list over F_p


# ---------------------------------------------------------------------------
# 1. Polynomial arithmetic over F_p and the factorization type
# ---------------------------------------------------------------------------


def poly_trim(a: Poly) -> Poly:
    """Remove trailing zero coefficients."""
    while a and a[-1] == 0:
        a.pop()
    return a


def poly_mod_scalar(a: Sequence[int], p: int) -> Poly:
    return poly_trim([c % p for c in a])


def poly_add(a: Poly, b: Poly, p: int) -> Poly:
    n = max(len(a), len(b))
    out = [0] * n
    for i in range(n):
        x = a[i] if i < len(a) else 0
        y = b[i] if i < len(b) else 0
        out[i] = (x + y) % p
    return poly_trim(out)


def poly_sub(a: Poly, b: Poly, p: int) -> Poly:
    n = max(len(a), len(b))
    out = [0] * n
    for i in range(n):
        x = a[i] if i < len(a) else 0
        y = b[i] if i < len(b) else 0
        out[i] = (x - y) % p
    return poly_trim(out)


def poly_mul(a: Poly, b: Poly, p: int) -> Poly:
    if not a or not b:
        return []
    out = [0] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        if x == 0:
            continue
        for j, y in enumerate(b):
            if y:
                out[i + j] = (out[i + j] + x * y) % p
    return poly_trim(out)


def poly_divmod(a: Poly, b: Poly, p: int) -> Tuple[Poly, Poly]:
    """Division with remainder in F_p[x]; `b` must be nonzero."""
    a = a[:]
    if not b:
        raise ZeroDivisionError("division by the zero polynomial")
    inv_lead = pow(b[-1], p - 2, p)
    q = [0] * max(0, len(a) - len(b) + 1)
    while len(a) >= len(b) and a:
        shift = len(a) - len(b)
        coeff = (a[-1] * inv_lead) % p
        q[shift] = coeff
        for i, y in enumerate(b):
            a[i + shift] = (a[i + shift] - coeff * y) % p
        poly_trim(a)
    return poly_trim(q), poly_trim(a)


def poly_mod(a: Poly, b: Poly, p: int) -> Poly:
    return poly_divmod(a, b, p)[1]


def poly_gcd(a: Poly, b: Poly, p: int) -> Poly:
    a, b = a[:], b[:]
    while b:
        a, b = b, poly_mod(a, b, p)
    if a:
        inv = pow(a[-1], p - 2, p)
        a = [(c * inv) % p for c in a]
    return a


def poly_powmod(base: Poly, exponent: int, modulus: Poly, p: int) -> Poly:
    """Compute base**exponent mod (modulus, p) by square-and-multiply."""
    result: Poly = [1]
    b = poly_mod(base, modulus, p)
    e = exponent
    while e > 0:
        if e & 1:
            result = poly_mod(poly_mul(result, b, p), modulus, p)
        b = poly_mod(poly_mul(b, b, p), modulus, p)
        e >>= 1
    return result


def factorization_type(f: Sequence[int], p: int) -> Tuple[int, ...]:
    """Sorted multiset of degrees of the irreducible factors of `f` mod `p`.

    Uses distinct-degree factorization: for each i, gcd(F, x^(p^i) - x) collects
    all irreducible factors of F of degree exactly i.  Returns () if f mod p is
    not squarefree (i.e. p is ramified for f).
    """
    fp = poly_mod_scalar(f, p)
    n = len(fp) - 1
    # squarefree test via gcd with the derivative
    deriv = poly_trim([(i * c) % p for i, c in enumerate(fp)][1:])
    if not deriv or len(poly_gcd(fp, deriv, p)) > 1:
        return ()
    degrees: List[int] = []
    F = fp
    h: Poly = [0, 1]  # x
    i = 0
    while len(F) - 1 > 0 and i < n:
        i += 1
        h = poly_powmod(h, p, F, p)            # h = x^(p^i) mod F
        g = poly_gcd(F, poly_sub(h, [0, 1], p), p)
        d = len(g) - 1
        if d > 0:
            degrees.extend([i] * (d // i))
            F = poly_divmod(F, g, p)[0]
            h = poly_mod(h, F, p) if len(F) - 1 > 0 else h
    if len(F) - 1 > 0:
        degrees.append(len(F) - 1)
    return tuple(sorted(degrees))


def primes_up_to(limit: int) -> List[int]:
    sieve = bytearray([1]) * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    for q in range(2, int(limit**0.5) + 1):
        if sieve[q]:
            sieve[q * q :: q] = bytearray(len(sieve[q * q :: q]))
    return [i for i in range(limit + 1) if sieve[i]]


def kronecker(a: int, n: int) -> int:
    """Kronecker symbol (a | n) for n > 0."""
    if n == 0:
        return 1 if a in (1, -1) else 0
    result = 1
    if n < 0:
        n = -n
        if a < 0:
            result = -result
    twos = 0
    while n % 2 == 0:
        n //= 2
        twos += 1
    if twos:
        if a % 2 == 0:
            return 0
        if twos % 2 == 1 and a % 8 in (3, 5):
            result = -result
    a %= n
    while a:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0


# ---------------------------------------------------------------------------
# 2. Shannon quantities of a finite joint table
# ---------------------------------------------------------------------------


def eta(x: float) -> float:
    """-x log2 x, with the convention 0 log 0 = 0."""
    return 0.0 if x <= 0.0 else -x * log2(x)


def type_marginal(table: Dict[Tuple[object, object], float]) -> Dict[object, float]:
    out: Dict[object, float] = {}
    for (t, _c), v in table.items():
        out[t] = out.get(t, 0.0) + v
    return out


def coset_marginal(table: Dict[Tuple[object, object], float]) -> Dict[object, float]:
    out: Dict[object, float] = {}
    for (_t, c), v in table.items():
        out[c] = out.get(c, 0.0) + v
    return out


def shannon(table: Dict[Tuple[object, object], float]) -> Dict[str, float]:
    """All Shannon quantities of a joint table, in bits."""
    h_type = sum(eta(v) for v in type_marginal(table).values())
    h_coset = sum(eta(v) for v in coset_marginal(table).values())
    h_joint = sum(eta(v) for v in table.values())
    info = h_type + h_coset - h_joint
    return {
        "H(T)": h_type,
        "H(C)": h_coset,
        "H(T,C)": h_joint,
        "I(T;C)": info,
        "H(T|C)": h_joint - h_coset,
        "H(C|T)": h_joint - h_type,
    }


def determines(table: Dict[Tuple[object, object], float]) -> bool:
    """Does each type occur with a single coset?"""
    seen: Dict[object, object] = {}
    for (t, c), v in table.items():
        if v <= 0:
            continue
        if t in seen and seen[t] != c:
            return False
        seen[t] = c
    return True


def group_table(
    elements: Iterable[object],
    type_obs,
    coset_obs,
) -> Dict[Tuple[object, object], float]:
    """Joint table of two observables at a uniformly random group element."""
    elems = list(elements)
    n = len(elems)
    table: Dict[Tuple[object, object], float] = {}
    for g in elems:
        key = (type_obs(g), coset_obs(g))
        table[key] = table.get(key, 0.0) + 1.0 / n
    return table


# ---------------------------------------------------------------------------
# 3. The five transitive quintic tables, as exact class statistics
# ---------------------------------------------------------------------------

L5 = log2(5.0)
L3 = log2(3.0)

QUINTIC_TABLES: Dict[str, Dict[Tuple[str, str], float]] = {
    # C5: abelian, the coset IS the Frobenius element (five cosets).
    "C5": {
        ("[1^5]", "c0"): 1 / 5,
        ("[5]", "c1"): 1 / 5,
        ("[5]", "c2"): 1 / 5,
        ("[5]", "c3"): 1 / 5,
        ("[5]", "c4"): 1 / 5,
    },
    # D5: abelianization C2, rotations vs reflections.
    "D5": {
        ("[1^5]", "rot"): 1 / 10,
        ("[5]", "rot"): 4 / 10,
        ("[1,2,2]", "refl"): 5 / 10,
    },
    # F20: abelianization C4; the type [4] straddles BOTH generators of C4.
    "F20": {
        ("[1^5]", "0"): 1 / 20,
        ("[5]", "0"): 4 / 20,
        ("[4]", "1"): 5 / 20,
        ("[4]", "3"): 5 / 20,
        ("[1,2,2]", "2"): 5 / 20,
    },
    # A5: perfect group, trivial abelianization.
    "A5": {
        ("[1^5]", "*"): 1 / 60,
        ("[1,2,2]", "*"): 15 / 60,
        ("[1,1,3]", "*"): 20 / 60,
        ("[5]", "*"): 24 / 60,
    },
    # S5: abelianization C2 via the sign character.
    "S5": {
        ("[1^5]", "even"): 1 / 120,
        ("[1,1,1,2]", "odd"): 10 / 120,
        ("[1,2,2]", "even"): 15 / 120,
        ("[1,1,3]", "even"): 20 / 120,
        ("[2,3]", "odd"): 20 / 120,
        ("[1,4]", "odd"): 30 / 120,
        ("[5]", "even"): 24 / 120,
    },
}

CLOSED_FORMS: Dict[str, Dict[str, float]] = {
    "C5": {"H(T)": L5 - 8 / 5, "H(C)": L5, "I(T;C)": L5 - 8 / 5},
    "D5": {"H(T)": 1 / 5 + L5 / 2, "H(C)": 1.0, "I(T;C)": 1.0},
    "F20": {"H(T)": 11 / 10 + L5 / 4, "H(C)": 2.0, "I(T;C)": 1.5},
    "A5": {"H(T)": 2 / 15 + 7 * L3 / 20 + 5 * L5 / 12, "H(C)": 0.0, "I(T;C)": 0.0},
    "S5": {"H(T)": 7 / 5 + 5 * L5 / 24 + 17 * L3 / 40, "H(C)": 1.0, "I(T;C)": 1.0},
}


def demo_quintic_row() -> None:
    print("=" * 78)
    print("THE TRANSITIVE QUINTIC ROW: closed forms versus direct evaluation")
    print("=" * 78)
    header = f"{'group':>5} {'H(T)':>9} {'H(C)':>7} {'I(T;C)':>8} {'gap':>8} {'sat?':>5}"
    print(header)
    print("-" * 78)
    for name, table in QUINTIC_TABLES.items():
        s = shannon(table)
        cf = CLOSED_FORMS[name]
        for key, predicted in cf.items():
            assert abs(s[key] - predicted) < 1e-12, (name, key, s[key], predicted)
        gap = s["H(T)"] - s["I(T;C)"]
        assert abs(gap - s["H(T|C)"]) < 1e-12, "gap identity failed"
        assert -1e-12 <= s["I(T;C)"] <= min(s["H(T)"], s["H(C)"]) + 1e-12
        sat = "yes" if abs(s["I(T;C)"] - s["H(C)"]) < 1e-12 else "NO"
        print(
            f"{name:>5} {s['H(T)']:9.5f} {s['H(C)']:7.4f} "
            f"{s['I(T;C)']:8.5f} {gap:8.5f} {sat:>5}"
        )
    print("-" * 78)
    print("All closed forms confirmed; the gap equals H(T|C) in every row.")
    print()


def demo_saturation_criterion() -> None:
    print("=" * 78)
    print("THE SATURATION CRITERION:  I(T;C) = H(C)  <=>  type determines coset")
    print("=" * 78)
    for name, table in QUINTIC_TABLES.items():
        s = shannon(table)
        det = determines(table)
        sat = abs(s["I(T;C)"] - s["H(C)"]) < 1e-12
        assert det == sat, f"criterion violated for {name}"
        print(
            f"{name:>5}: determines={str(det):>5}   "
            f"I={s['I(T;C)']:.5f}   H(C)={s['H(C)']:.5f}   saturates={sat}"
        )
    f20 = shannon(QUINTIC_TABLES["F20"])
    deficit = f20["H(C)"] - f20["I(T;C)"]
    print()
    print("F20 is the unique non-saturating cell with nontrivial abelianization:")
    print("  the type [4] has mass 1/2 and straddles k = 2 cosets of C4,")
    print(f"  so the deficit is exactly (1/2) * log2(2) = {deficit:.5f}.")
    assert abs(deficit - 0.5) < 1e-12
    print()


# ---------------------------------------------------------------------------
# 4. The D5 quintic x^5 + 20x + 32, empirically
# ---------------------------------------------------------------------------

F_D5: List[int] = [32, 20, 0, 0, 0, 1]  # 32 + 20x + x^5
D5_CONDUCTOR = 20
D5_RESOLVENT_DISC = -20  # K = Q(sqrt(-5)), disc(K) = -20


def demo_chebotarev(limit: int = 60000) -> None:
    print("=" * 78)
    print(f"CHEBOTAREV READOUT of x^5 + 20x + 32 over primes p < {limit}")
    print("=" * 78)
    counts: Dict[Tuple[int, ...], int] = {}
    joint: Dict[Tuple[object, object], float] = {}
    agree = 0
    total = 0
    for p in primes_up_to(limit):
        if p in (2, 5):
            continue
        t = factorization_type(F_D5, p)
        if not t:
            continue  # ramified
        counts[t] = counts.get(t, 0) + 1
        total += 1
        # coset: reflections (type [1,2,2]) are the nontrivial coset
        coset = 1 if t == (1, 2, 2) else 0
        kro = kronecker(D5_RESOLVENT_DISC, p)
        if (kro == -1) == (coset == 1):
            agree += 1
        key = (t, p % D5_CONDUCTOR)
        joint[key] = joint.get(key, 0.0) + 1.0
    for k in joint:
        joint[k] /= total

    expected = {(1, 1, 1, 1, 1): 0.1, (5,): 0.4, (1, 2, 2): 0.5}
    print(f"{'type':>14} {'count':>7} {'observed':>10} {'D5 class':>10} {'error':>9}")
    print("-" * 78)
    for t, c in sorted(counts.items(), key=lambda kv: -kv[1]):
        obs = c / total
        exp = expected.get(t, 0.0)
        print(f"{str(t):>14} {c:>7} {obs:>10.5f} {exp:>10.5f} {obs - exp:>+9.5f}")
    assert set(counts) <= set(expected), "a non-D5 factorization type occurred!"
    print("-" * 78)
    print(f"No factorization type outside the D5 menu ever occurs ({total} primes).")
    print(f"Agreement of type parity with the Kronecker symbol (-20|p): "
          f"{agree / total:.4f}")
    assert agree == total, "the quadratic resolvent identification failed"

    s = shannon(joint)
    print()
    print("Empirical residue-dial channel  T  versus  p mod 20:")
    print(f"  H(T)               = {s['H(T)']:.4f}   "
          f"(exact: {1/5 + L5/2:.4f})")
    print(f"  H(p mod 20)        = {s['H(C)']:.4f}   (exact: 3)")
    print(f"  I(p mod 20 ; T)    = {s['I(T;C)']:.4f}   (exact: 1)")
    print()
    print("Residue-dial invariance: the residue is a 4-to-1 refinement of the")
    print("coset, so it carries log2(4) = 2 extra bits of entropy and exactly")
    print("zero extra bits of information about the factorization type.")
    print()


def demo_residue_refinement() -> None:
    print("=" * 78)
    print("RESIDUE-DIAL INVARIANCE, exactly:  refine the coset alphabet m-to-one")
    print("=" * 78)
    base = QUINTIC_TABLES["D5"]
    split = [1, 3, 7, 9]   # residues mod 20 where -5 is a square
    inert = [11, 13, 17, 19]
    refined: Dict[Tuple[object, object], float] = {}
    for (t, c), v in base.items():
        fibre = split if c == "rot" else inert
        for r in fibre:
            refined[(t, r)] = refined.get((t, r), 0.0) + v / 4

    s0, s1 = shannon(base), shannon(refined)
    print(f"{'quantity':>10} {'coset table':>14} {'residue table':>15} {'difference':>12}")
    print("-" * 78)
    for key in ("H(T)", "H(C)", "H(T,C)", "I(T;C)"):
        print(f"{key:>10} {s0[key]:14.6f} {s1[key]:15.6f} {s1[key] - s0[key]:+12.6f}")
    print("-" * 78)
    assert abs(s1["H(T)"] - s0["H(T)"]) < 1e-12
    assert abs((s1["H(C)"] - s0["H(C)"]) - 2.0) < 1e-12
    assert abs((s1["H(T,C)"] - s0["H(T,C)"]) - 2.0) < 1e-12
    assert abs(s1["I(T;C)"] - s0["I(T;C)"]) < 1e-12
    print("H(T) fixed; H(C) and H(T,C) each gain log2(4) = 2; I is unchanged.")
    print()


# ---------------------------------------------------------------------------
# 5. The pair law and the which-factor wall, exactly on D5 x D5
# ---------------------------------------------------------------------------

# Dihedral group of order 10 as pairs (kind, i): kind 0 = rotation r^i,
# kind 1 = reflection s r^i.
D5_ELEMENTS: List[Tuple[int, int]] = [(k, i) for k in (0, 1) for i in range(5)]


def d5_type(g: Tuple[int, int]) -> str:
    kind, i = g
    if kind == 1:
        return "[1,2,2]"
    return "[1^5]" if i == 0 else "[5]"


def d5_coset(g: Tuple[int, int]) -> int:
    return g[0]  # rotations -> 0, reflections -> 1


def demo_pair_law() -> None:
    print("=" * 78)
    print("THE PAIR LAW AND THE WHICH-FACTOR WALL (exact, over D5 x D5)")
    print("=" * 78)
    single = group_table(D5_ELEMENTS, d5_type, d5_coset)
    s_single = shannon(single)
    print(f"single prime : I(T ; coset)              = {s_single['I(T;C)']:.6f}")
    assert abs(s_single["I(T;C)"] - 1.0) < 1e-12

    pairs = [(g, h) for g in D5_ELEMENTS for h in D5_ELEMENTS]
    pair_table = group_table(
        pairs,
        lambda x: (d5_type(x[0]), d5_type(x[1])),
        lambda x: (d5_coset(x[0]) + d5_coset(x[1])) % 2,
    )
    s_pair = shannon(pair_table)
    print(f"semiprime    : I((T_p,T_q) ; coset(pq))  = {s_pair['I(T;C)']:.6f}")
    assert abs(s_pair["I(T;C)"] - 1.0) < 1e-12

    wall = group_table(
        pairs,
        lambda x: d5_coset(x[0]),
        lambda x: (d5_coset(x[0]) + d5_coset(x[1])) % 2,
    )
    s_wall = shannon(wall)
    print(f"which-factor : I(coset(p) ; coset(pq))   = {s_wall['I(T;C)']:.6f}")
    assert abs(s_wall["I(T;C)"]) < 1e-12

    for k in (1, 2, 3, 4):
        tuples: List[Tuple[Tuple[int, int], ...]] = [()]
        for _ in range(k):
            tuples = [t + (g,) for t in tuples for g in D5_ELEMENTS]
        tbl = group_table(
            tuples,
            lambda x: tuple(d5_type(g) for g in x),
            lambda x: sum(d5_coset(g) for g in x) % 2,
        )
        val = shannon(tbl)["I(T;C)"]
        assert abs(val - 1.0) < 1e-12
        print(f"arity k = {k}  : I(type vector ; product coset) = {val:.6f}")
    print()
    print("Pairing (or k-tupling) neither gains nor loses information: exactly")
    print("log2|A| = 1 bit at every arity, with a hard zero wall between the")
    print("product coset and the coset of any single factor.")
    print()


# ---------------------------------------------------------------------------
# 6. A5: the channel that transmits nothing
# ---------------------------------------------------------------------------


def demo_a5_silence(limit: int = 30000) -> None:
    print("=" * 78)
    print("A5 (x^5 + 20x + 16): 1.6555 bits of factorization entropy, ZERO of")
    print("which any congruence condition can see")
    print("=" * 78)
    f = [16, 20, 0, 0, 0, 1]
    counts: Dict[Tuple[int, ...], int] = {}
    total = 0
    for p in primes_up_to(limit):
        t = factorization_type(f, p)
        if not t:
            continue
        counts[t] = counts.get(t, 0) + 1
        total += 1
    expected = {
        (1, 1, 1, 1, 1): 1 / 60,
        (1, 2, 2): 15 / 60,
        (1, 1, 3): 20 / 60,
        (5,): 24 / 60,
    }
    for t, c in sorted(counts.items(), key=lambda kv: -kv[1]):
        print(f"  {str(t):>14}: observed {c / total:.5f}  A5 class {expected.get(t, 0):.5f}")
    emp_h = sum(eta(c / total) for c in counts.values())
    print(f"  empirical H(T) = {emp_h:.4f}   closed form "
          f"{2/15 + 7*L3/20 + 5*L5/12:.4f}")
    print("  I(T ; coset) = 0 exactly: A5 is perfect, so it has no abelian")
    print("  quotient and no reciprocity law predicts this factorization.")
    print()


# ---------------------------------------------------------------------------


def main() -> None:
    demo_quintic_row()
    demo_saturation_criterion()
    demo_residue_refinement()
    demo_chebotarev()
    demo_pair_law()
    demo_a5_silence()
    print("=" * 78)
    print("All assertions passed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
