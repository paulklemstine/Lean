"""
The cyclic cubic type channel at conductor 7: numerical demonstration.

This self-contained script reproduces, from first principles and with no
external dependencies, every quantitative claim about the decomposition-type
channel of the real cyclic cubic field K = Q(zeta_7 + zeta_7^{-1}), the
splitting field of f(x) = x^3 + x^2 - 2x - 1:

  1. The splitting law: for a prime p != 7, f has a root mod p  <=>  p = +-1 mod 7.
     Verified by brute force over all primes below a bound, together with the
     all-or-nothing property (0 or 3 roots, never exactly 1 or 2).

  2. Full pinning: with p mod 7 uniform on the six invertible classes,
        H(T)          = log2(3) - 2/3 = 0.9182958...
        I(p mod 7; T) = log2(3) - 2/3 = H(T)   (exactly, no slack).

  3. Semiprime degradation: for N = p*q with independent uniform factors and
     S = number of split factors,
        H(S)      = 2*log2(3) - 16/9 = 1.3921861...
        I(N; S)   =   log2(3) - 10/9 = 0.4738514...
        deficit   = H(S) - I(N;S) = log2(3) - 2/3 = H(T)  (exactly one label).

  4. Which-factor blindness: with the ordered pair (T(p), T(q)),
        H(T_p,T_q) = 2*log2(3) - 4/3 = 1.8366292...  ( = H(S) + 4/9 )
        I(N; (T_p,T_q)) - I(N; S) = 0  (exactly).

  5. The conductor-free trace-order criterion: an order-m element of SL_2(F_p)
     exists iff m | p^2 - 1, giving root criteria for the minimal polynomial of
     zeta_m + zeta_m^{-1} at m = 5, 7, 11 simultaneously.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from math import isclose, log2
from typing import Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Basic utilities
# ----------------------------------------------------------------------------


def primes_up_to(limit: int) -> List[int]:
    """All primes < limit, by a simple sieve of Eratosthenes."""
    sieve = [True] * limit
    sieve[0:2] = [False, False]
    for n in range(2, int(limit**0.5) + 1):
        if sieve[n]:
            for k in range(n * n, limit, n):
                sieve[k] = False
    return [n for n in range(limit) if sieve[n]]


def eta(x: float) -> float:
    """The entropy contribution -x*log2(x), with eta(0) = 0."""
    return 0.0 if x <= 0.0 else -x * log2(x)


def entropy(weights: Iterable[float]) -> float:
    """Shannon entropy, in bits, of a list of nonnegative weights."""
    return sum(eta(w) for w in weights)


def mutual_information(joint: Dict[Tuple[object, object], float]) -> float:
    """I(X;Y) = H(X) + H(Y) - H(X,Y) for a joint law given as a dict."""
    marg_x: Dict[object, float] = {}
    marg_y: Dict[object, float] = {}
    for (x, y), w in joint.items():
        marg_x[x] = marg_x.get(x, 0.0) + w
        marg_y[y] = marg_y.get(y, 0.0) + w
    return (
        entropy(marg_x.values())
        + entropy(marg_y.values())
        - entropy(joint.values())
    )


# ----------------------------------------------------------------------------
# 1. The arithmetic layer: the splitting law
# ----------------------------------------------------------------------------


def f_cubic(x: int, p: int) -> int:
    """f(x) = x^3 + x^2 - 2x - 1 evaluated in F_p."""
    return (x * x * x + x * x - 2 * x - 1) % p


def roots_mod(p: int) -> List[int]:
    """All roots of f in F_p."""
    return [x for x in range(p) if f_cubic(x, p) == 0]


def splits(p: int) -> bool:
    """True iff p splits completely in K, i.e. iff f has a root mod p."""
    return len(roots_mod(p)) > 0


def predicted_split(p: int) -> bool:
    """The splitting criterion: p splits iff p = +-1 mod 7."""
    return p % 7 in (1, 6)


def verify_splitting_law(limit: int = 2000) -> Tuple[int, int]:
    """Check the criterion and the all-or-nothing property for all p < limit."""
    checked = 0
    for p in primes_up_to(limit):
        if p == 7:
            continue
        rs = roots_mod(p)
        assert len(rs) in (0, 3), f"p={p}: found {len(rs)} roots (expected 0 or 3)"
        assert (len(rs) == 3) == predicted_split(p), f"criterion fails at p={p}"
        # The Frobenius twist x -> x^2 - 2 permutes the roots cyclically.
        for x in rs:
            assert f_cubic((x * x - 2) % p, p) == 0
        checked += 1
    return checked, limit


# ----------------------------------------------------------------------------
# 2. The single-prime channel
# ----------------------------------------------------------------------------

UNITS7: Tuple[int, ...] = (1, 2, 3, 4, 5, 6)


def res_type(u: int) -> bool:
    """Splitting type of the residue class u mod 7: True = split, False = inert."""
    return u % 7 in (1, 6)


def prime_channel() -> Dict[Tuple[int, bool], float]:
    """Joint law of (p mod 7, type of p) under the uniform prime model."""
    return {(u, res_type(u)): 1.0 / 6.0 for u in UNITS7}


# ----------------------------------------------------------------------------
# 3-4. The semiprime channels (unordered and ordered type pairs)
# ----------------------------------------------------------------------------


def semiprime_channel_unordered() -> Dict[Tuple[int, int], float]:
    """Joint law of (N mod 7, number of split factors) for N = p*q."""
    joint: Dict[Tuple[int, int], float] = {}
    for u, v in product(UNITS7, repeat=2):
        key = ((u * v) % 7, int(res_type(u)) + int(res_type(v)))
        joint[key] = joint.get(key, 0.0) + 1.0 / 36.0
    return joint


def semiprime_channel_ordered() -> Dict[Tuple[int, Tuple[bool, bool]], float]:
    """Joint law of (N mod 7, ordered pair of factor types) for N = p*q."""
    joint: Dict[Tuple[int, Tuple[bool, bool]], float] = {}
    for u, v in product(UNITS7, repeat=2):
        key = ((u * v) % 7, (res_type(u), res_type(v)))
        joint[key] = joint.get(key, 0.0) + 1.0 / 36.0
    return joint


def swap_symmetry_holds() -> bool:
    """Check that exchanging the two factors leaves every count unchanged."""
    joint = semiprime_channel_ordered()
    for (n, (b1, b2)), w in joint.items():
        if not isclose(w, joint.get((n, (b2, b1)), 0.0), abs_tol=1e-15):
            return False
    return True


# ----------------------------------------------------------------------------
# 5. The conductor-free trace-order criterion
# ----------------------------------------------------------------------------


def cheb_A(t: int, n: int, p: int) -> int:
    """A_0 = 0, A_1 = 1, A_{n+2} = t*A_{n+1} - A_n, computed in F_p."""
    a, b = 0 % p, 1 % p
    for _ in range(n):
        a, b = b, (t * b - a) % p
    return a


def has_order_m_companion(m: int, p: int) -> bool:
    """Is there t in F_p with A_m(t) = 0 and A_{m-1}(t) = -1?

    Equivalently: does SL_2(F_p) contain a non-scalar element of order m?
    """
    return any(
        cheb_A(t, m, p) == 0 and cheb_A(t, m - 1, p) == (p - 1) % p
        for t in range(p)
    )


def poly_has_root(coeffs: Sequence[int], p: int) -> bool:
    """Does the polynomial with the given coefficients (ascending) have a root mod p?"""
    for x in range(p):
        acc = 0
        for c in reversed(coeffs):
            acc = (acc * x + c) % p
        if acc == 0:
            return True
    return False


# minimal polynomials of zeta_m + zeta_m^{-1}, coefficients in ascending degree
PSI: Dict[int, Tuple[int, ...]] = {
    5: (-1, 1, 1),                    # x^2 + x - 1
    7: (-1, -2, 1, 1),                # x^3 + x^2 - 2x - 1
    11: (1, 3, -3, -4, 1, 1),         # x^5 + x^4 - 4x^3 - 3x^2 + 3x + 1
}


def verify_trace_order(limit: int = 400) -> int:
    """For m = 5, 7, 11 check: root of Psi_m mod p  <=>  m | p^2 - 1  <=>  order-m element."""
    checked = 0
    for m, coeffs in PSI.items():
        for p in primes_up_to(limit):
            if p == m or p == 2:
                continue
            root = poly_has_root(coeffs, p)
            divides = (p * p - 1) % m == 0
            order = has_order_m_companion(m, p)
            assert root == divides == order, f"m={m}, p={p}: {root} {divides} {order}"
            checked += 1
    return checked


# ----------------------------------------------------------------------------
# Empirical estimates from actual primes
# ----------------------------------------------------------------------------


def empirical_prime_channel(limit: int) -> Tuple[float, float, int]:
    """Estimate H(T) and I(p mod 7; T) from the primes below `limit`."""
    counts: Dict[Tuple[int, bool], float] = {}
    total = 0
    for p in primes_up_to(limit):
        if p == 7:
            continue
        key = (p % 7, splits(p) if p < 3000 else predicted_split(p))
        counts[key] = counts.get(key, 0.0) + 1.0
        total += 1
    joint = {k: v / total for k, v in counts.items()}
    marg_t: Dict[bool, float] = {}
    for (_, t), w in joint.items():
        marg_t[t] = marg_t.get(t, 0.0) + w
    return entropy(marg_t.values()), mutual_information(joint), total


def empirical_semiprime_channel(limit: int) -> float:
    """Estimate I(N mod 7; S) from products of pairs of primes below `limit`."""
    ps = [p for p in primes_up_to(limit) if p != 7]
    counts: Dict[Tuple[int, int], float] = {}
    total = 0
    for i, p in enumerate(ps):
        for q in ps[i:]:
            key = ((p * q) % 7, int(predicted_split(p)) + int(predicted_split(q)))
            counts[key] = counts.get(key, 0.0) + 1.0
            total += 1
    joint = {k: v / total for k, v in counts.items()}
    return mutual_information(joint)


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------


def main() -> None:
    L3 = log2(3.0)
    line = "-" * 74

    print(line)
    print("THE CYCLIC CUBIC TYPE CHANNEL  --  K = Q(zeta_7 + zeta_7^-1),  conductor 7")
    print(line)

    # --- 1. The splitting law -------------------------------------------------
    checked, limit = verify_splitting_law(2000)
    print(f"\n[1] Splitting law   f(x) = x^3 + x^2 - 2x - 1")
    print(f"    Verified for all {checked} primes p < {limit}, p != 7:")
    print("      #roots of f mod p is 0 or 3 (never 1 or 2)   -- all-or-nothing")
    print("      f has a root mod p  <=>  p = +-1 (mod 7)     -- the criterion")
    split_examples = [p for p in primes_up_to(120) if p != 7 and predicted_split(p)]
    inert_examples = [p for p in primes_up_to(120) if p != 7 and not predicted_split(p)]
    print(f"      split primes < 120 : {split_examples}")
    print(f"      inert primes < 120 : {inert_examples}")

    # --- 2. The single-prime channel -----------------------------------------
    joint_rt = prime_channel()
    marg_t: Dict[bool, float] = {}
    for (_, t), w in joint_rt.items():
        marg_t[t] = marg_t.get(t, 0.0) + w
    h_t = entropy(marg_t.values())
    h_r = entropy([1 / 6] * 6)
    h_joint = entropy(joint_rt.values())
    i_rt = mutual_information(joint_rt)

    print("\n[2] Single-prime channel   p mod 7  ->  type")
    print(f"      P[split] = {marg_t[True]:.6f} = 1/3,   P[inert] = {marg_t[False]:.6f} = 2/3")
    print(f"      H(R)     = {h_r:.9f}   exact: 1 + log2 3      = {1 + L3:.9f}")
    print(f"      H(T)     = {h_t:.9f}   exact: log2 3 - 2/3    = {L3 - 2/3:.9f}")
    print(f"      H(R,T)   = {h_joint:.9f}   exact: 1 + log2 3      = {1 + L3:.9f}")
    print(f"      I(R;T)   = {i_rt:.9f}   exact: log2 3 - 2/3    = {L3 - 2/3:.9f}")
    print(f"      FULL PINNING:  I(R;T) - H(T) = {i_rt - h_t:+.2e}   (zero: ceiling attained)")
    assert isclose(i_rt, h_t, abs_tol=1e-12)
    assert isclose(h_t, L3 - 2 / 3, abs_tol=1e-12)

    # --- 3. The semiprime channel --------------------------------------------
    joint_s = semiprime_channel_unordered()
    marg_s: Dict[int, float] = {}
    for (_, s), w in joint_s.items():
        marg_s[s] = marg_s.get(s, 0.0) + w
    h_s = entropy(marg_s.values())
    i_s = mutual_information(joint_s)

    print("\n[3] Semiprime channel   N = p*q mod 7  ->  number S of split factors")
    print(f"      P[S=2] = {marg_s[2]:.6f} = 1/9,  P[S=1] = {marg_s[1]:.6f} = 4/9,"
          f"  P[S=0] = {marg_s[0]:.6f} = 4/9")
    print(f"      H(S)     = {h_s:.9f}   exact: 2 log2 3 - 16/9 = {2 * L3 - 16 / 9:.9f}")
    print(f"      H(N,S)   = {entropy(joint_s.values()):.9f}   exact: 2 log2 3 + 1/3  "
          f"= {2 * L3 + 1 / 3:.9f}")
    print(f"      I(N;S)   = {i_s:.9f}   exact: log2 3 - 10/9   = {L3 - 10 / 9:.9f}")
    print(f"      deficit H(S) - I(N;S) = {h_s - i_s:.9f}")
    print(f"      compare  H(T)         = {h_t:.9f}   <-- EXACTLY ONE TYPE LABEL LOST")
    assert isclose(h_s - i_s, h_t, abs_tol=1e-12)

    print("\n      Structural reason (cosets of H = {1,6} in (Z/7)^x, quotient of order 3):")
    for n in UNITS7:
        rows = sorted((u, (n * pow(u, -1, 7)) % 7) for u in UNITS7)
        pattern = sorted(int(res_type(u)) + int(res_type(v)) for u, v in rows)
        print(f"        N = {n} mod 7:  split-counts over its 6 factorisations = {pattern}")

    # --- 4. Which-factor blindness -------------------------------------------
    joint_o = semiprime_channel_ordered()
    marg_o: Dict[Tuple[bool, bool], float] = {}
    for (_, b), w in joint_o.items():
        marg_o[b] = marg_o.get(b, 0.0) + w
    h_o = entropy(marg_o.values())
    i_o = mutual_information(joint_o)

    print("\n[4] Ordered pair of types   (T_p, T_q)")
    print(f"      H(T_p,T_q)     = {h_o:.9f}   exact: 2 log2 3 - 4/3 = {2 * L3 - 4 / 3:.9f}")
    print(f"      H(T_p,T_q) - H(S) = {h_o - h_s:.9f}   exact: 4/9 = {4 / 9:.9f}"
          "   (real which-factor entropy)")
    print(f"      I(N;(T_p,T_q)) = {i_o:.9f}   exact: log2 3 - 10/9  = {L3 - 10 / 9:.9f}")
    print(f"      WHICH-FACTOR INFORMATION = I(N;(T_p,T_q)) - I(N;S) = {i_o - i_s:+.2e}"
          "   (exactly zero)")
    print(f"      exact swap symmetry of the factorisation counts: {swap_symmetry_holds()}")
    assert isclose(i_o, i_s, abs_tol=1e-12)
    assert swap_symmetry_holds()

    # --- 5. Conductor-free criterion -----------------------------------------
    n_checks = verify_trace_order(400)
    print("\n[5] Conductor-free trace-order criterion")
    print(f"      For m = 5, 7, 11 and all odd primes p < 400 (p != m), {n_checks} checks:")
    print("        Psi_m has a root mod p  <=>  m | p^2 - 1  <=>  SL_2(F_p) has an")
    print("        order-m companion matrix (A_m(t) = 0 and A_{m-1}(t) = -1).")
    print("      m = 5 : x^2 + x - 1                     (golden ratio / Fibonacci)")
    print("      m = 7 : x^3 + x^2 - 2x - 1              (this paper)")
    print("      m = 11: x^5 + x^4 - 4x^3 - 3x^2 + 3x + 1")

    # --- 6. Empirical check with real primes ---------------------------------
    h_emp, i_emp, n_primes = empirical_prime_channel(200000)
    i_semi_emp = empirical_semiprime_channel(4000)
    print("\n[6] Empirical estimates from actual primes")
    print(f"      sample: {n_primes} primes below 200000")
    print(f"      H(T)  empirical = {h_emp:.4f}   theory = {L3 - 2 / 3:.4f}")
    print(f"      I(R;T) empirical = {i_emp:.4f}   theory = {L3 - 2 / 3:.4f}"
          "   (pinning holds sample-wise: I = H(T))")
    print(f"      I(N;S) empirical = {i_semi_emp:.4f}   theory = {L3 - 10 / 9:.4f}")

    print("\n" + line)
    print("All assertions passed: full pinning, exact one-label deficit, zero")
    print("which-factor information, and the conductor-free root criterion.")
    print(line)


if __name__ == "__main__":
    main()
