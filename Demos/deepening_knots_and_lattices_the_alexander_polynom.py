"""
Knots and Lattices: The Alexander Polynomial as a Signed State Sum.

This self-contained script demonstrates the main results:

  * unsigned area generating functions have non-negative coefficients;
  * every finitely supported integer coefficient function is a *signed* state
    sum (universality) -- exhibited by an explicit state family;
  * unsigned representability holds exactly for non-negative functions;
  * connected sum <-> Cauchy product of signed state sums (areas add, signs
    multiply);
  * the torus family T(2, 2k+1) with Delta_k(t) = sum_{i=-k}^{k} (-1)^{i+k} t^i:
    reciprocity, Delta_k(1) = 1, |Delta_k(-1)| = 2k+1, a negative coefficient
    for every k >= 1, yet always a signed state sum.

A "coefficient function" is a dict mapping an integer exponent k to the integer
coefficient of t^k (omitted keys are 0). A "state" is a tuple (area, sign).
"""

from __future__ import annotations

from typing import Dict, List, Tuple

# A coefficient function: exponent -> coefficient.
CoeffFn = Dict[int, int]
# A state carries an integer area and an integer sign (+1 or -1).
State = Tuple[int, int]


# --------------------------------------------------------------------------
# The two generating-function models
# --------------------------------------------------------------------------

def area_gf(states: List[State]) -> CoeffFn:
    """Unsigned area generating function: coefficient of t^k = #{states of area k}."""
    result: CoeffFn = {}
    for area, _sign in states:
        result[area] = result.get(area, 0) + 1
    return {k: v for k, v in result.items() if v != 0}


def signed_gf(states: List[State]) -> CoeffFn:
    """Signed state sum: coefficient of t^k = sum of signs over states of area k."""
    result: CoeffFn = {}
    for area, sign in states:
        result[area] = result.get(area, 0) + sign
    return {k: v for k, v in result.items() if v != 0}


def is_nonneg(c: CoeffFn) -> bool:
    """Does the coefficient function have only non-negative coefficients?"""
    return all(v >= 0 for v in c.values())


# --------------------------------------------------------------------------
# Universality: build an explicit signed state family for ANY coeff function
# --------------------------------------------------------------------------

def universal_states(c: CoeffFn) -> List[State]:
    """For each exponent k with c[k] != 0, emit |c[k]| states of area k, each
    carrying the sign of c[k]. Then signed_gf of this family equals c."""
    states: List[State] = []
    for k, ck in c.items():
        if ck == 0:
            continue
        sign = 1 if ck > 0 else -1
        for _ in range(abs(ck)):
            states.append((k, sign))
    return states


def unsigned_states(c: CoeffFn) -> List[State]:
    """For a non-negative coeff function, emit c[k] states of area k (sign +1)."""
    if not is_nonneg(c):
        raise ValueError("unsigned model requires non-negative coefficients")
    states: List[State] = []
    for k, ck in c.items():
        for _ in range(ck):
            states.append((k, 1))
    return states


# --------------------------------------------------------------------------
# Connected sum <-> Cauchy product of signed state families
# --------------------------------------------------------------------------

def product_states(s: List[State], t: List[State]) -> List[State]:
    """Product state family: areas add, signs multiply (connected sum)."""
    return [(a1 + a2, g1 * g2) for (a1, g1) in s for (a2, g2) in t]


def poly_product(c: CoeffFn, d: CoeffFn) -> CoeffFn:
    """Direct Cauchy product of two coefficient functions."""
    result: CoeffFn = {}
    for k1, v1 in c.items():
        for k2, v2 in d.items():
            result[k1 + k2] = result.get(k1 + k2, 0) + v1 * v2
    return {k: v for k, v in result.items() if v != 0}


# --------------------------------------------------------------------------
# The torus family T(2, 2k+1)
# --------------------------------------------------------------------------

def torus_alex(k: int) -> CoeffFn:
    """Delta_k(t) = sum_{i=-k}^{k} (-1)^{i+k} t^i."""
    return {i: (1 if (i + k) % 2 == 0 else -1) for i in range(-k, k + 1)}


def evaluate(c: CoeffFn, t: int) -> int:
    """Evaluate the Laurent polynomial at an integer t (t = 1 or t = -1 here)."""
    total = 0
    for k, v in c.items():
        if t == 1:
            total += v
        elif t == -1:
            total += v * (1 if k % 2 == 0 else -1)
        else:
            total += v * (t ** k)  # only valid for k >= 0
    return total


def is_palindromic(c: CoeffFn) -> bool:
    """Reciprocity: c[k] == c[-k] for all k."""
    return all(c.get(k, 0) == c.get(-k, 0) for k in c)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def _fmt(c: CoeffFn) -> str:
    if not c:
        return "0"
    return " + ".join(f"{v}*t^{k}" for k, v in sorted(c.items()))


def main() -> None:
    print("=" * 68)
    print("1. The trefoil breaks the UNSIGNED conjecture")
    print("=" * 68)
    trefoil: CoeffFn = {1: 1, 0: -1, -1: 1}
    print(f"   Delta_trefoil(t) = {_fmt(trefoil)}")
    print(f"   non-negative? {is_nonneg(trefoil)}  -> not an unsigned count")

    print()
    print("=" * 68)
    print("2. Universality: the trefoil IS a signed state sum")
    print("=" * 68)
    st = universal_states(trefoil)
    print(f"   states (area, sign): {st}")
    print(f"   signed_gf(states) = {_fmt(signed_gf(st))}")
    assert signed_gf(st) == trefoil

    print()
    print("   Universality on a random-looking target:")
    target: CoeffFn = {-2: 3, -1: -5, 0: 7, 2: -1}
    rebuilt = signed_gf(universal_states(target))
    print(f"   target   = {_fmt(target)}")
    print(f"   rebuilt  = {_fmt(rebuilt)}")
    assert rebuilt == target

    print()
    print("=" * 68)
    print("3. Unsigned model = exactly non-negative functions")
    print("=" * 68)
    nn: CoeffFn = {0: 2, 1: 1, 3: 4}
    print(f"   non-negative target = {_fmt(nn)}")
    print(f"   area_gf(unsigned_states) = {_fmt(area_gf(unsigned_states(nn)))}")
    assert area_gf(unsigned_states(nn)) == nn

    print()
    print("=" * 68)
    print("4. Connected sum <-> Cauchy product")
    print("=" * 68)
    a = universal_states(trefoil)
    b = universal_states(trefoil)
    prod_via_states = signed_gf(product_states(a, b))
    prod_direct = poly_product(trefoil, trefoil)
    print(f"   trefoil # trefoil (via states) = {_fmt(prod_via_states)}")
    print(f"   trefoil * trefoil (direct)     = {_fmt(prod_direct)}")
    assert prod_via_states == prod_direct
    tot_s = sum(sign for _a, sign in a)
    tot_t = sum(sign for _a, sign in b)
    tot_prod = sum(sign for _a, sign in product_states(a, b))
    print(f"   total signed weight multiplies: {tot_s} * {tot_t} = {tot_prod}")
    assert tot_prod == tot_s * tot_t

    print()
    print("=" * 68)
    print("5. The torus family T(2, 2k+1)")
    print("=" * 68)
    for k in range(1, 6):
        d = torus_alex(k)
        neg = any(v < 0 for v in d.values())
        print(f"   k={k}: Delta_k = {_fmt(d)}")
        print(f"        palindromic={is_palindromic(d)}  "
              f"Delta(1)={evaluate(d, 1)}  |Delta(-1)|={abs(evaluate(d, -1))}  "
              f"has_negative={neg}")
        assert is_palindromic(d)
        assert evaluate(d, 1) == 1
        assert abs(evaluate(d, -1)) == 2 * k + 1
        assert d[k - 1] == -1  # negative coefficient for k >= 1
        # yet always a signed state sum:
        assert signed_gf(universal_states(d)) == d
    print("   T(2,3) = trefoil?", torus_alex(1) == trefoil)
    assert torus_alex(1) == trefoil

    print()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
