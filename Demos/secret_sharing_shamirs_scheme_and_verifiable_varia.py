"""
Numerical demonstrations of polynomial secret sharing and its verifiable variants.

Everything runs over the prime field F_p = Z/pZ. Each section exercises a specific
theorem from the formal development:

  * shamir_reconstruction / shamir_explicit_reconstruction  -> Section 1, 2
  * shamir_privacy / shamir_insufficient                    -> Section 3
  * shamir_reconstruct_additive / shamir_reconstruct_mul    -> Section 4
  * feldman_verify_iff / feldman_catches_cheater / binding  -> Section 5
  * pedersen_perfect_hiding / pedersen_equivocation         -> Section 6

The "group" is modeled additively as the field F_p itself, with generators g, h
in F_p and "g^a" rendered as the scalar product (a * g) mod p, mirroring the
formal additive-group convention.
"""

from __future__ import annotations

import itertools
import random
from typing import Callable, Dict, List, Sequence, Tuple

# --------------------------------------------------------------------------- #
# Field arithmetic over F_p                                                    #
# --------------------------------------------------------------------------- #

P: int = 2089  # a prime; all arithmetic is mod P


def inv(a: int, p: int = P) -> int:
    """Multiplicative inverse of a modulo p (p prime, a != 0)."""
    return pow(a % p, p - 2, p)


def poly_eval(coeffs: Sequence[int], x: int, p: int = P) -> int:
    """Evaluate a polynomial given by ascending coefficients at x mod p (Horner)."""
    acc = 0
    for c in reversed(coeffs):
        acc = (acc * x + c) % p
    return acc


def poly_add(a: Sequence[int], b: Sequence[int], p: int = P) -> List[int]:
    """Add two polynomials (ascending coefficients) mod p."""
    n = max(len(a), len(b))
    out = [0] * n
    for i in range(n):
        ai = a[i] if i < len(a) else 0
        bi = b[i] if i < len(b) else 0
        out[i] = (ai + bi) % p
    return out


def poly_mul(a: Sequence[int], b: Sequence[int], p: int = P) -> List[int]:
    """Multiply two polynomials (ascending coefficients) mod p."""
    out = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            out[i + j] = (out[i + j] + ai * bj) % p
    return out


# --------------------------------------------------------------------------- #
# Lagrange reconstruction (node-only weights)                                 #
# --------------------------------------------------------------------------- #

def lagrange_coeff(nodes: Sequence[int], i: int, z: int = 0, p: int = P) -> int:
    """
    The reconstruction weight w_i = basis_i(z): the value at z of the Lagrange
    basis polynomial that is 1 at nodes[i] and 0 at the other nodes.

    For z = 0 this is exactly `lagrangeCoeff` from the formal development; it
    depends only on the nodes, not on the shared polynomial.
    """
    xi = nodes[i]
    num, den = 1, 1
    for j, xj in enumerate(nodes):
        if j == i:
            continue
        num = (num * (z - xj)) % p
        den = (den * (xi - xj)) % p
    return (num * inv(den, p)) % p


def reconstruct(nodes: Sequence[int], shares: Sequence[int], z: int = 0, p: int = P) -> int:
    """secret = sum_i share_i * lagrange_coeff_i  (shamir_explicit_reconstruction)."""
    return sum(s * lagrange_coeff(nodes, i, z, p) for i, s in enumerate(shares)) % p


# --------------------------------------------------------------------------- #
# Dealing                                                                      #
# --------------------------------------------------------------------------- #

def deal(secret: int, t: int, nodes: Sequence[int], rng: random.Random,
         p: int = P) -> Tuple[List[int], List[int]]:
    """Return (coefficients, shares) for a degree-<t sharing of `secret`."""
    coeffs = [secret % p] + [rng.randrange(p) for _ in range(t - 1)]
    shares = [poly_eval(coeffs, x, p) for x in nodes]
    return coeffs, shares


# --------------------------------------------------------------------------- #
# Section 1-2: reconstruction threshold = degree + 1                          #
# --------------------------------------------------------------------------- #

def demo_reconstruction() -> None:
    print("=" * 70)
    print("SECTION 1-2  Reconstruction: any t shares recover the secret")
    print("=" * 70)
    rng = random.Random(1)
    secret, t = 1234, 3
    all_nodes = [1, 2, 3, 4, 5]
    coeffs, shares = deal(secret, t, all_nodes, rng)
    print(f"secret = {secret}, threshold t = {t}")
    print(f"nodes  = {all_nodes}")
    print(f"shares = {shares}")
    # Every size-t subset reconstructs the same secret.
    for subset in itertools.combinations(range(len(all_nodes)), t):
        nodes = [all_nodes[i] for i in subset]
        sub_shares = [shares[i] for i in subset]
        rec = reconstruct(nodes, sub_shares)
        assert rec == secret, (subset, rec)
    print(f"All C({len(all_nodes)},{t}) subsets of size t reconstruct {secret}.  OK")
    print()


# --------------------------------------------------------------------------- #
# Section 3: information-theoretic privacy (shamir_privacy)                    #
# --------------------------------------------------------------------------- #

def consistent_polynomial(obs_nodes: Sequence[int], obs_shares: Sequence[int],
                          candidate_secret: int, t: int, p: int = P) -> List[int]:
    """
    The UNIQUE degree-<t polynomial matching the t-1 observed shares AND having
    constant term `candidate_secret`. Built by interpolating on the augmented
    node set {0} U obs_nodes (size t). Witnesses shamir_privacy.
    """
    nodes = [0] + list(obs_nodes)
    values = [candidate_secret % p] + list(obs_shares)
    # Lagrange interpolation -> coefficient vector via summing basis polynomials.
    result = [0] * t
    for i, xi in enumerate(nodes):
        # basis_i(X) = prod_{j!=i} (X - xj)/(xi - xj)
        basis = [1]
        den = 1
        for j, xj in enumerate(nodes):
            if j == i:
                continue
            basis = poly_mul(basis, [(-xj) % p, 1], p)
            den = (den * (xi - xj)) % p
        scale = (values[i] * inv(den, p)) % p
        scaled = [(c * scale) % p for c in basis]
        result = poly_add(result, scaled, p)
    return result


def demo_privacy() -> None:
    print("=" * 70)
    print("SECTION 3  Information-theoretic privacy: t-1 shares reveal nothing")
    print("=" * 70)
    rng = random.Random(7)
    true_secret, t = 999, 3
    nodes = [1, 2, 3, 4]
    _, shares = deal(true_secret, t, nodes, rng)
    # A coalition sees only t-1 = 2 shares.
    obs_nodes = nodes[:t - 1]
    obs_shares = shares[:t - 1]
    print(f"true secret = {true_secret}, threshold t = {t}")
    print(f"coalition sees {t-1} shares at nodes {obs_nodes}: {obs_shares}")
    print("For EVERY candidate secret there is exactly one consistent polynomial:")
    for candidate in [0, 17, 999, 1500, 2088]:
        poly = consistent_polynomial(obs_nodes, obs_shares, candidate, t)
        # Check it reproduces the observed shares and has the candidate secret.
        assert poly[0] == candidate
        for x, s in zip(obs_nodes, obs_shares):
            assert poly_eval(poly, x) == s
        print(f"  candidate {candidate:4d} -> poly {poly}  (matches all shares)")
    print("Every secret is equally consistent: zero information leaks.  OK")
    # shamir_insufficient: two distinct secrets, two distinct polynomials.
    p1 = consistent_polynomial(obs_nodes, obs_shares, 100, t)
    p2 = consistent_polynomial(obs_nodes, obs_shares, 200, t)
    assert p1 != p2 and p1[0] == 100 and p2[0] == 200
    print("shamir_insufficient: secrets 100 and 200 both fit the same shares.  OK")
    print()


# --------------------------------------------------------------------------- #
# Section 4: linear homomorphism (MPC)                                         #
# --------------------------------------------------------------------------- #

def demo_homomorphism() -> None:
    print("=" * 70)
    print("SECTION 4  Linear homomorphism: add and multiply secrets blindly")
    print("=" * 70)
    rng = random.Random(11)
    t = 2
    c, d = 321, 654
    # Additive: nodes of size >= t.
    nodes = [1, 2, 3]
    _, sc = deal(c, t, nodes, rng)
    _, sd = deal(d, t, nodes, rng)
    summed = [(a + b) % P for a, b in zip(sc, sd)]
    rec_sum = reconstruct(nodes[:t], summed[:t])
    print(f"c = {c}, d = {d}")
    print(f"reconstruct(share_c + share_d) = {rec_sum}  vs  c+d = {(c+d)%P}")
    assert rec_sum == (c + d) % P
    # Multiplicative: product polynomial has degree 2t-2, need >= 2t-1 nodes.
    big_nodes = [1, 2, 3, 4, 5]
    cc, scc = deal(c, t, big_nodes, rng)
    dd, sdd = deal(d, t, big_nodes, rng)
    prod_shares = [(a * b) % P for a, b in zip(scc, sdd)]
    k = 2 * t - 1
    rec_prod = reconstruct(big_nodes[:k], prod_shares[:k])
    print(f"reconstruct(share_c * share_d) = {rec_prod}  vs  c*d = {(c*d)%P}")
    assert rec_prod == (c * d) % P
    print("shamir_reconstruct_additive and shamir_reconstruct_mul verified.  OK")
    print()


# --------------------------------------------------------------------------- #
# Section 5: Feldman VSS                                                       #
# --------------------------------------------------------------------------- #

def feldman_commit(coeffs: Sequence[int], g: int, p: int = P) -> List[int]:
    """C_j = a_j * g (additive group convention)."""
    return [(a * g) % p for a in coeffs]


def feldman_verify(commit: Sequence[int], g: int, x: int, s: int, p: int = P) -> bool:
    """Accept iff s*g == sum_j x^j * C_j."""
    rhs = sum((pow(x, j, p) * c) for j, c in enumerate(commit)) % p
    return (s * g) % p == rhs


def demo_feldman() -> None:
    print("=" * 70)
    print("SECTION 5  Feldman VSS: cheating dealers are caught; binding")
    print("=" * 70)
    rng = random.Random(13)
    g, t, secret = 5, 3, 42
    nodes = [1, 2, 3, 4]
    coeffs, shares = deal(secret, t, nodes, rng)
    commit = feldman_commit(coeffs, g)
    print(f"g = {g}, secret = {secret}, commitments = {commit}")
    # Completeness + verify_iff: honest shares always pass.
    for x, s in zip(nodes, shares):
        assert feldman_verify(commit, g, x, s)
    print("Every honest share verifies (feldman_complete / feldman_verify_iff).  OK")
    # Soundness: any forged share is rejected.
    x0, true_share = nodes[0], shares[0]
    rejected = sum(1 for s in range(P) if s != true_share
                   and not feldman_verify(commit, g, x0, s))
    print(f"At node {x0}: all {rejected} of {P-1} wrong shares rejected "
          f"(feldman_catches_cheater).  OK")
    # Binding: different coefficients give different commitments.
    other = coeffs[:]
    other[1] = (other[1] + 1) % P
    assert feldman_commit(other, g) != commit
    print("Distinct polynomials -> distinct commitments (feldman_binding).  OK")
    print()


# --------------------------------------------------------------------------- #
# Section 6: Pedersen VSS (perfect hiding)                                     #
# --------------------------------------------------------------------------- #

def pedersen_commit(coeffs: Sequence[int], blind: Sequence[int],
                    g: int, h: int, p: int = P) -> List[int]:
    """C_j = a_j * g + a'_j * h."""
    return [((a * g) + (b * h)) % p for a, b in zip(coeffs, blind)]


def pedersen_blind_for_target(coeffs: Sequence[int], target: Sequence[int],
                              g: int, h: int, p: int = P) -> List[int]:
    """
    Solve for blinding b_j = (C_j - a_j * g) / h so that the commitment equals
    `target`. Witnesses pedersen_perfect_hiding (requires h != 0).
    """
    return [((cj - (a * g)) * inv(h, p)) % p for a, cj in zip(coeffs, target)]


def demo_pedersen() -> None:
    print("=" * 70)
    print("SECTION 6  Pedersen VSS: perfect hiding and equivocation")
    print("=" * 70)
    rng = random.Random(17)
    g, h, t = 5, 11, 3
    nodes = [1, 2, 3, 4]
    # Honest sharing with a random blinding polynomial.
    coeffs, _ = deal(314, t, nodes, rng)
    blind = [rng.randrange(P) for _ in range(t)]
    commit = pedersen_commit(coeffs, blind, g, h)
    print(f"g = {g}, h = {h}, published commitments = {commit}")
    # Perfect hiding: EVERY secret reproduces the SAME commitment via some blinding.
    print("Every candidate secret can reproduce these exact commitments:")
    for candidate_secret in [0, 100, 314, 2000]:
        fake = [candidate_secret % P] + [rng.randrange(P) for _ in range(t - 1)]
        b = pedersen_blind_for_target(fake, commit, g, h)
        assert pedersen_commit(fake, b, g, h) == commit
        print(f"  secret {candidate_secret:4d}: blinding {b} -> identical commitments")
    print("Commitments leak zero info (pedersen_perfect_hiding).  OK")
    # Equivocation: two different polynomials, same commitment vector.
    f1 = [10, 20, 30]
    f2 = [99, 88, 77]
    b1 = [0, 0, 0]
    c1 = pedersen_commit(f1, b1, g, h)
    b2 = pedersen_blind_for_target(f2, c1, g, h)
    assert pedersen_commit(f2, b2, g, h) == c1 and f1 != f2
    print(f"Polynomials {f1} and {f2} share commitment {c1} "
          f"(pedersen_equivocation).  OK")
    print()


def main() -> None:
    demo_reconstruction()
    demo_privacy()
    demo_homomorphism()
    demo_feldman()
    demo_pedersen()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()


"""
Visualization: the threshold phase transition of Shamir secret sharing.

Left panel  -- shares as points on a degree-(t-1) curve over the reals, with the
               unique interpolating polynomial through any t of them and its
               y-intercept (the secret).
Right panel -- privacy below threshold: with only t-1 points, infinitely many
               degree-(t-1) curves pass through them, each hitting a DIFFERENT
               y-intercept, so the secret is completely undetermined.
"""

from __future__ import annotations

from typing import List, Sequence

import numpy as np
import matplotlib.pyplot as plt


def lagrange_value(xs: Sequence[float], ys: Sequence[float], z: float) -> float:
    """Evaluate the interpolating polynomial through (xs, ys) at z (over the reals)."""
    total = 0.0
    for i, xi in enumerate(xs):
        term = ys[i]
        for j, xj in enumerate(xs):
            if j != i:
                term *= (z - xj) / (xi - xj)
        total += term
    return total


def main() -> None:
    t = 3                       # threshold; sharing polynomial has degree t-1 = 2
    secret = 4.0
    coeffs = [secret, -1.2, 0.6]  # f(x) = 4 - 1.2 x + 0.6 x^2
    nodes = [1.0, 2.0, 3.0, 4.0]
    shares = [sum(c * x ** k for k, c in enumerate(coeffs)) for x in nodes]

    grid = np.linspace(-0.5, 4.5, 400)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # ---- Left: reconstruction with t points ------------------------------- #
    curve = [sum(c * x ** k for k, c in enumerate(coeffs)) for x in grid]
    ax1.plot(grid, curve, "b-", lw=2, label="secret polynomial f")
    ax1.scatter(nodes, shares, c="navy", s=70, zorder=5, label="shares")
    ax1.scatter([0], [secret], c="red", s=120, marker="*", zorder=6,
                label=f"secret f(0) = {secret}")
    ax1.axvline(0, color="grey", ls=":")
    ax1.set_title(f"Reconstruction: t = {t} shares pin down the secret")
    ax1.set_xlabel("evaluation point x")
    ax1.set_ylabel("share value f(x)")
    ax1.legend()
    ax1.grid(alpha=0.3)

    # ---- Right: privacy with t-1 points ----------------------------------- #
    obs_x = nodes[:t - 1]            # only 2 points known
    obs_y = shares[:t - 1]
    ax2.scatter(obs_x, obs_y, c="navy", s=70, zorder=5,
                label=f"{t-1} observed shares")
    colors = plt.cm.viridis(np.linspace(0, 1, 7))
    for color, c0 in zip(colors, np.linspace(0, 8, 7)):
        xs = list(obs_x) + [0.0]
        ys = list(obs_y) + [c0]      # force the y-intercept to be c0
        yy = [lagrange_value(xs, ys, z) for z in grid]
        ax2.plot(grid, yy, color=color, lw=1.5, alpha=0.8)
        ax2.scatter([0], [c0], color=color, s=40, zorder=6)
    ax2.axvline(0, color="grey", ls=":")
    ax2.set_title(f"Privacy: t-1 = {t-1} shares fit every secret equally")
    ax2.set_xlabel("evaluation point x")
    ax2.set_ylabel("share value f(x)")
    ax2.legend()
    ax2.grid(alpha=0.3)

    fig.suptitle("Shamir secret sharing: the threshold phase transition",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("threshold_phase_transition.png", dpi=140)
    print("Saved threshold_phase_transition.png")


if __name__ == "__main__":
    main()
