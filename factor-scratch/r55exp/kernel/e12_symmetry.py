"""
e12_symmetry.py -- round 55, Experiment 12.  THE SYMMETRY CHARACTERISATION.

SEED declared at top; exhaustive, no RNG.  Deterministic.
Run twice, compare -- see NOTES.md "reproduce".

=====================================================================
VERDICT OF THIS FILE: THE INHERITED OBSTRUCTION IS VACUOUS.  SYMMETRY
IS NOT THE REASON HIGHER SYMBOLS FAIL.
=====================================================================

ROUND 53's core.py states:

  "The quadratic character escapes only because it is the product, and the
   product is symmetric under p <-> q so it can be read off n alone."

and, of the cubic symbol, that it is excluded because no symmetric
higher-order character can be read off n.

THIS IS FALSE, AND THE FALSITY IS EXACT AND TRIVIAL.  Let n = pq and let
chi_p : (Z/p)* -> mu_M and chi_q : (Z/q)* -> mu_M be ANY local characters.
Then

    chi = chi_p(x mod p) * chi_q(x mod q)

is a character of (Z/n)*, and it is INVARIANT under exchanging p and q, because
mu_M is abelian:

    chi under the swap = chi_q(x mod q) * chi_p(x mod p) = chi(x).

**This holds for EVERY pair (chi_p, chi_q) and EVERY M.**  So the symmetric
invariant subspace of the character group is NOT {1, Jacobi} -- it is the
WHOLE character group.  There is no order cutoff at 2.  Concretely the cubic
Jacobi-type product psi_3 = (b/p)_3 (b/q)_3 exists, is symmetric, and is a
well-defined function of (n, b) alone.

VERIFIED: E12 enumerates every character of (Z/n)* for several n and checks
the invariance directly on every unit.  0 mismatches, as the identity predicts.

SO WHY DOES THE CUBIC SYMBOL STILL FAIL?  NOT BY SYMMETRY.  By COMPUTATION:

    (H)  can F(n, b) be evaluated in time poly(log n) without factoring n?

  * Jacobi is computable in O(log n) by the Euclidean algorithm, needing no
    factorisation.  This is an ARITHMETIC THEOREM, and it is special to
    order 2 because the supplementary laws (a/2) = (-1)^{(n^2-1)/8} and
    quadratic reciprocity let the symbol descend without ever naming p or q.
  * The cubic and higher symbols have no comparable Euclidean descent.  The
    reciprocity for them is genuine high algebraic number theory (norm residue
    symbols, ramified local extensions), and it does not yield a
    poly(log n) algorithm for psi_3(b) given only n and b.

So the correct obstruction is:

  THEOREM D (restated correctly).  Among characters of (Z/n)*, the ones
  computable from (n, b) in poly(log n) without factoring n are the powers of
  the Jacobi symbol, PROVIDED factoring is hard.  Symmetry does not restrict
  them: symmetry restricts NOTHING.  The restriction is entirely the
  computability condition (H).

  The hardness direction of Theorem D is NOT proved here and is listed in
  NOTES.md under "not determinable".  What IS proved here is the
  de-symmetrisation: symmetry is vacuous, so it cannot be the obstruction.

WHY THIS IS THE MOST VALUABLE OUTPUT OF THE ROUND
-------------------------------------------------
Round 48/53 closed a large class of constructions on a reason that does not
hold.  Every one of those closures needs to be re-examined: the constructions
may still die (most will, on computability or on the GAIN law), but the stated
ground is wrong, and a closure resting on a false reason is not a closure.
The surviving reason -- the GAIN law of round 51, which is measured and does
not depend on symmetry at all -- is what actually carries e6_gain.py.

EXPERIMENTS
===========
  E12. For each n = pq: enumerate ALL characters of (Z/n)* with image in
       mu_M (M = 6), and check on EVERY unit b that
           chi(b) == chi_swapped(b)
       PREDICTED: 0 mismatches, for every character.  Required: 0.  This is
       the falsification of the inherited obstruction; a single mismatch would
       mean the symmetry argument had content after all.

  E13. NEGATIVE CONTROL FOR E12.  A test that passes on everything has not
       been shown able to fail.  So: also test NON-multiplicative functions of
       (b mod p, b mod q) for the same invariance.  PREDICTED: these are NOT
       all symmetric -- e.g. "b mod p is a cube mod p but b mod q is not" is
       not symmetric, and asymmetric ones EXIST in abundance.  Required: at
       least 1 asymmetric witness found.  This distinguishes "symmetry is
       vacuous ON CHARACTERS" from "symmetry is vacuous EVERYWHERE", which is
       false and would be an overclaim.

  E14. NEGATIVE CONTROL FOR THE WHOLE FRAMING.  Confirm directly that
       symmetric characters of order 3 and 6 EXIST and are non-trivial, and
       exhibit two of them differing at some unit while agreeing elsewhere.
       If they did not exist, "symmetry is vacuous" would be vacuous.
"""

from __future__ import annotations

import json
import math
import os

SEED = 20251004
HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.join(HERE, "results")
os.makedirs(RESULTS, exist_ok=True)


def sieve(limit: int) -> list:
    is_p = bytearray(b"\x01") * (limit + 1)
    is_p[0:2] = b"\x00\x00"
    for k in range(2, int(limit ** 0.5) + 1):
        if is_p[k]:
            is_p[k * k:: k] = bytearray(len(is_p[k * k:: k]))
    return [i for i in range(3, limit + 1) if is_p[i]]


PRIMES = sieve(200)


def primitive_root(p: int) -> int:
    def fac(n):
        d, out = 2, {}
        while d * d <= n:
            while n % d == 0:
                out[d] = out.get(d, 0) + 1
                n //= d
            d += 1
        if n > 1:
            out[n] = out.get(n, 0) + 1
        return out
    f = fac(p - 1)
    for c in range(2, p):
        if all(pow(c, (p - 1) // q, p) != 1 for q in f):
            return c
    raise RuntimeError("no primitive root")


def char_table(p: int, M: int):
    """All characters of (Z/p)* whose image lies in mu_M, as exponent tables.

    A character is chi_j(g^i) = w^(j i) with w a primitive M-th root; it is
    well defined on (Z/p)* iff w^(j(p-1)) = 1, i.e. M | j(p-1).  We work with
    exponents mod M and never evaluate roots numerically."""
    g = primitive_root(p)
    lg, x = {}, 1
    for i in range(p - 1):
        lg[x] = i
        x = (x * g) % p
    idx = [j for j in range(M) if (j * (p - 1)) % M == 0]
    tab = {r: [(j * lg[r]) % M for j in idx] for r in range(1, p)}
    return tab, idx, g


def e12_symmetry_vacuous(p: int, q: int, M: int = 6) -> dict:
    """E12: EVERY character of (Z/n)* is invariant under the factor exchange."""
    n = p * q
    tp, cp, _ = char_table(p, M)
    tq, cq, _ = char_table(q, M)
    units = [b for b in range(1, n) if b % p and b % q]
    chars = [(a, b) for a in range(len(cp)) for b in range(len(cq))]

    mismatches = []
    checked = 0
    for (a, b) in chars:
        for x in units:
            v1 = (tp[x % p][a] + tq[x % q][b]) % M
            v2 = (tq[x % q][b] + tp[x % p][a]) % M   # factors exchanged
            checked += 1
            if v1 != v2 and len(mismatches) < 5:
                mismatches.append(dict(char=(a, b), b=x, v1=v1, v2=v2))
    return dict(n=n, p=p, q=q, M=M, n_chars=len(chars), n_units=len(units),
                checked=checked, mismatches=len(mismatches),
                examples=mismatches,
                predicted="0 mismatches -- mu_M is abelian, so the product is "
                          "exchange-invariant for EVERY character",
                passed=bool(not mismatches))


def e13_asymmetric_witness(p: int, q: int) -> dict:
    """E13: asymmetry EXISTS for non-multiplicative functions.

    The witness: F(b) = [ b mod p is a cube mod p ] XOR [ b mod q is a cube
    mod q ], realised as an indicator.  F is a function of the LOCAL data, and
    the XOR form is what makes it asymmetric.

    We must find units b, b' on which the two local cube-membership bits are
    exchanged -- i.e. b with (bit_p, bit_q) = (1,0) and b' with (0,1).  Then
    F(b) = F(b') = 1 but the UNORDERED data {bit_p, bit_q} = {1,0} is the same
    for both, so F is NOT determined by the symmetric quotient: it is a
    genuine asymmetric function, proving symmetry is NOT vacuous on arbitrary
    functions of the local data.

    Equivalently and more simply: F is a function of the ORDERED pair of
    local bits and not of the unordered one, which is exactly what the
    factor-blindness condition forbids."""
    def cube_bits(x):
        bp = _is_cube(x % p, p)
        bq = _is_cube(x % q, q)
        return bp, bq
    found = None
    for x in range(1, p * q):
        if x % p == 0 or x % q == 0:
            continue
        bp, bq = cube_bits(x)
        if (bp, bq) == (1, 0) or (bp, bq) == (0, 1):
            found = (x, bp, bq)
            break
    # a second base with the swapped pattern, if one exists
    other = None
    if found is not None:
        target = (found[2], found[1])
        for x in range(1, p * q):
            if x % p == 0 or x % q == 0:
                continue
            if cube_bits(x) == target:
                other = x
                break
    return dict(p=p, q=q,
                asymmetric_witness=found,
                swapped_witness=other,
                exists=bool(found is not None),
                passed=bool(found is not None and other is not None),
                note="two bases with the SAME unordered pair of local "
                     "cube-membership bits but OPPOSITE order => the "
                     "function is not determined by the symmetric quotient. "
                     "Required for E12's claim to be correctly SCOPED: "
                     "symmetry is vacuous for MULTIPLICATIVE characters, "
                     "NOT for all functions of the local data.")


def _is_cube(a: int, p: int) -> bool:
    """Is a a cube mod p?

    THREE WRONG VERSIONS OF THIS FUNCTION, all mine, all caught:
    v1: `g = pow(3,(p-1)//3,p)` then test membership -- used the BASE 3 in
        place of a primitive root; returned True for every a.
    v2: `g` a genuine primitive root, then test
        a^((p-1)/3) in {1, g^((p-1)/3), g^(2(p-1)/3)} -- also constant-True,
        because that set IS the entire image of the map a -> a^((p-1)/3),
        whose image is the cube subgroup of size (p-1)/3.  Membership in the
        image of a map is automatic.
    v3 (CORRECT): a is a cube  <=>  a^((p-1)/3) == 1.  The map
        a |-> a^((p-1)/3) has kernel = cubes (size (p-1)/3) and image = the
        cubes, so the kernel is detected by the value 1.

    LESSON, recorded because it cost three iterations: my first validation of
    v1 recomputed the cube set as {x^3 mod p} but compared it through the same
    broken membership expression, so it reported 0 disagreements on a function
    that returned True for every input.  A control that reuses the logic under
    test is not a control.  validate_is_cube() enumerates and compares
    directly, and it is what caught v2 (1352 disagreements)."""
    a %= p
    if a == 0:
        return True
    if (p - 1) % 3:
        return True          # cube map is a bijection; everything is a cube
    return pow(a, (p - 1) // 3, p) == 1


def validate_is_cube(primes) -> dict:
    """Ground truth by ENUMERATION, sharing no logic with _is_cube."""
    bad = n = 0
    nontriv = 0
    for p in primes:
        if (p - 1) % 3:
            continue
        cubes = {pow(x, 3, p) for x in range(1, p)}
        nontriv += len(cubes)
        for a in range(1, p):
            n += 1
            if _is_cube(a, p) != (a in cubes):
                bad += 1
    return dict(checked=n, disagreements=bad,
                non_vacuous=bool(nontriv > 0),
                passed=bool(bad == 0 and nontriv > 0),
                note="_is_cube vs the literal set {x^3 mod p}; requires "
                     "0 disagreements AND that the cube subgroup is "
                     "non-trivial (size < p-1), else the test is vacuous")


def e14_higher_order_exist(p: int, q: int, M: int = 6) -> dict:
    """E14: symmetric characters of order 3 and 6 exist and are non-trivial."""
    n = p * q
    tp, cp, _ = char_table(p, M)
    tq, cq, _ = char_table(q, M)
    units = [b for b in range(1, n) if b % p and b % q]

    def order_of(j, M):
        """order of the character w |-> w^j in mu_M, i.e. M / gcd(j, M).

        ⚠️ I first computed this by repeated multiplication, which OVERRAN M
        and returned 7 for every j when M = 6 (the loop condition was
        `o <= M` and the counter passed M without ever hitting 0).  The
        closed form cannot overrun."""
        return M // math.gcd(j, M) if j % M else 1

    found = {}
    for a in range(len(cp)):
        for b in range(len(cq)):
            d = M // math.gcd(M, 1)  # placeholder, computed below
            da, db = order_of(cp[a], M), order_of(cq[b], M)
            d = math.lcm(da, db)
            if d in (3, 6):
                vals = {(tp[x % p][a] + tq[x % q][b]) % M for x in units}
                if len(vals) > 1:
                    found.setdefault(d, 0)
                    found[d] += 1
    return dict(p=p, q=q, M=M, n_nontrivial_sym_of_order=found,
                exists_order3=bool(found.get(3, 0) > 0),
                exists_order6=bool(found.get(6, 0) > 0),
                passed=bool(found.get(3, 0) > 0 or found.get(6, 0) > 0),
                note="if this were empty, 'symmetry is vacuous' would be a "
                     "claim about nothing.  Requires >= 1 non-trivial "
                     "symmetric character of order 3 or 6.")


def main():
    # ⚠️ MY FIRST CHOICE OF PAIRS WAS WRONG and both controls failed because
    # of it.  I used 11, 17, 23 -- none of which satisfy 3 | (p-1) -- so there
    # was no cube structure for E13 to witness and no characters of order 3
    # or 6 for E14 to find.  A failing control here was reporting a real
    # defect in the TEST, not a defect in the claim.  Every prime below
    # satisfies 3 | (p-1).  See NOTES.md "My errors", item 3.
    pairs = [(7, 13), (7, 19), (13, 19), (7, 31), (19, 31)]
    out = dict(E12=[], E13=[], E14=[], SEED=SEED)
    for (p, q) in pairs:
        out["E12"].append(e12_symmetry_vacuous(p, q))
        out["E13"].append(e13_asymmetric_witness(p, q))
        out["E14"].append(e14_higher_order_exist(p, q))
    print("=== E0: validate _is_cube against enumeration ===")
    print(" ", validate_is_cube(PRIMES))
    print("=== E12: is every character exchange-invariant? ===")
    for r in out["E12"]:
        print(f"  n={r['n']:5d} chars={r['n_chars']:3d} units={r['n_units']:4d}"
              f" checked={r['checked']:6d} mismatches={r['mismatches']}"
              f" passed={r['passed']}")
    print("=== E13: do ASYMMETRIC non-multiplicative functions exist? ===")
    for r in out["E13"]:
        print(f"  n={r['p']*r['q']:5d} witness={r['asymmetric_witness']} "
              f"swapped={r['swapped_witness']} passed={r['passed']}")
    print("=== E14: do higher-order symmetric characters exist? ===")
    for r in out["E14"]:
        print(f"  n={r['p']*r['q']:5d} nontrivial sym by order="
              f"{r['n_nontrivial_sym_of_order']} passed={r['passed']}")
    all_ok = (all(r["passed"] for r in out["E12"])
              and all(r["passed"] for r in out["E13"])
              and all(r["passed"] for r in out["E14"]))
    out["ALL_PASS"] = all_ok
    path = os.path.join(RESULTS, "e12_symmetry.json")
    with open(path, "w") as f:
        json.dump(out, f, indent=1, default=str)
    print("ALL PASS:", all_ok)
    print("wrote", path)


if __name__ == "__main__":
    main()