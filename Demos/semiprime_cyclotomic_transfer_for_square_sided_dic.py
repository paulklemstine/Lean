import json, os

base = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
assets = os.path.join(base, "_assets")

def rd(p):
    with open(p, encoding="utf-8") as f:
        return f.read()

article = rd(os.path.join(base, "ARTICLE.md"))
paper_md = rd(os.path.join(base, "RESEARCH_PAPER.md"))
paper_tex = rd(os.path.join(base, "RESEARCH_PAPER.tex"))
demo = rd(os.path.join(base, "demo.py"))
viz = rd(os.path.join(assets, "visualization.py"))
algo = rd(os.path.join(assets, "algorithm.py"))
html = rd(os.path.join(assets, "interactive.html"))
lean = rd(os.path.join(assets, "lean_source.lean"))

future_directions = """# Future directions

These follow-ups build directly on the verified base case in
`NumberTheory/Phi6SquareDiceBaseCase.lean` (`p = 2, q = 3, m = 6, n = 2`). Each is a
concrete, attainable next step rather than a restatement of the full semiprime conjecture.

## 1. Generalize the quotient identity from `36` to any multiple `6r`

The base case proves `Φ₆ · P36 = S₃₆` with `P36 = Σ_{j<6} blockNat(j)`. The same block
formula should give `Φ₆ · (Σ_{j<r} blockNat(j)) = S_{6r}` for every `r`. The key insight is
that each block `blockNat(j) = X^{6j+1} + 2X^{6j+2} + 2X^{6j+3} + X^{6j+4}` is the shift by
`6j` of a single fixed degree-`4` pattern, and `Φ₆` times that pattern telescopes to the
six consecutive monomials `X^{6j+1} + ⋯ + X^{6j+6}`, so summing over `j < r` tiles
`X^1 + ⋯ + X^{6r}` exactly. **Why now?** The base case already isolates the one-block
computation that the induction reuses, so the generalization is a clean `Finset.range`
induction with no new algebraic content — the hard expansion is done and verified.

## 2. Prove the transfer is genuinely "new" (Sicherman-style inequivalence)

The product identity shows `P36 · Q4 = S₃₆ · S₄`, but it does not yet record that
`(P36, Q4)` differs from the trivial factorization `(S₃₆, S₄)`. The key insight is that the
two factorizations are distinguished by their cyclotomic-factor multiset: `P36` carries the
factor `Φ₆` that `S₃₆` keeps and `S₄` lacks, so a single coefficient comparison (for
instance `P36.coeff 5 = 0` while `S₃₆.coeff 5 = 1`) already certifies inequivalence.
**Why now?** All the polynomials are concrete and their coefficients are computable in the
existing file, so the distinguishing lemma is a short `decide`/`coeff`-level fact that
upgrades the artifact from "a valid factorization" to "a nontrivial transfer".

## 3. Catalogue the admissible `(p, q)` substitutions beyond `(2, 3)`

The witness uses `Φ₆ = Φ_{2·3}`. The natural next instances replace `Φ₆` by other
`Φ_{pq}` for small distinct primes `p, q` (e.g. `Φ_{10}, Φ_{15}, Φ_{21}`) and ask for the
analogous block decomposition. The key insight is that `Φ_{pq}` always divides
`S_{pq·k}` for suitable `k` because `S_N` collects exactly the cyclotomic factors
`Φ_d` with `d | (N+1)` and `d > 1`, so the block pattern is governed by the explicit
coefficient sequence of `Φ_{pq}` rather than by anything specific to `6`. **Why now?**
The present file gives a template — define `blockNat`, cast from `ℕ`, prove the quotient
identity by `ring`, derive nonnegativity from the cast — that ports almost verbatim to each
new `(p, q)`, turning a research question into a finite enumeration of mechanical cases.

## 4. Replace the hand-built blocks by a reusable `S`-divisibility API

The proof currently expands sums and calls `ring`. The key insight is that the recurring
fact is purely structural: `Φ_d` divides `S_{N}` whenever `d | (N+1)` and `d ≠ 1`, with an
explicit nonnegative quotient, and this divisibility — not the particular numerology of the
base case — is the load-bearing lemma for the full semiprime conjecture."""

pkg = {
    "title": "Semiprime Cyclotomic Transfer for Square-Sided Dice: The Verified \u03a6\u2086 Base Case",
    "domain": "Algebra",
    "description": "Encoding dice as generating polynomials, we transfer the cyclotomic atom \u03a6\u2086 = x\u00b2 \u2212 x + 1 from a 36-sided die to a 4-sided die, producing a nonstandard yet sum-equivalent pair of square-sided dice. The base case p=2, q=3, m=6, n=2 of the semiprime cyclotomic transfer conjecture is established with the quotient identity \u03a6\u2086\u00b7P36 = S36 and the transfer identity Q4 = \u03a6\u2086\u00b7S4.",
    "authors": ["Aristotle"],
    "date": "2026-06-20",
    "key_results": [
        "phi6_mul_P36: \u03a6\u2086 \u00b7 P36 = S\u2083\u2086, the quotient identity expressing S\u2083\u2086/\u03a6\u2086 as the nonnegative block polynomial P36 = \u03a3_{j<6} blockNat(j) with repeating coefficient pattern 1,2,2,1,0,0",
        "Q4_eq_phi6_mul_S4: Q4 = \u03a6\u2086 \u00b7 S\u2084 = x + x\u00b3 + x\u2074 + x\u2076, the transferred 4-sided die with faces {1,3,4,6}",
        "P36 \u00b7 Q4 = S\u2083\u2086 \u00b7 S\u2084 with P36(1)=36 and Q4(1)=4: the transfer preserves the sum distribution and the square-sided face counts",
    ],
    "keywords": [
        "cyclotomic polynomial", "Phi_6", "Sicherman dice", "generating polynomial",
        "semiprime", "square-sided dice", "polynomial factorization", "block decomposition",
    ],
    "article": article,
    "research_paper": paper_md,
    "research_paper_tex": paper_tex,
    "demo": demo,
    "demos": [
        {
            "name": "End-to-End Verification of the \u03a6\u2086 Cyclotomic Dice Transfer",
            "description": "Computes, in exact integer arithmetic, every quantity in the base case: it builds \u03a6\u2086 = x\u00b2\u2212x+1, the block polynomial P36 = S\u2083\u2086/\u03a6\u2086 with its repeating 1,2,2,1,0,0 coefficient pattern, and the transferred die Q4 = \u03a6\u2086\u00b7S\u2084 = x+x\u00b3+x\u2074+x\u2076 (faces {1,3,4,6}). It then verifies the quotient identity \u03a6\u2086\u00b7P36 = S\u2083\u2086, the transfer identity, the face counts P36(1)=36 and Q4(1)=4, nonnegativity of both dice, nonstandardness via a distinguishing coefficient, and finally prints the full sum distributions of the standard pair (S\u2083\u2086,S\u2084) and the transfer pair (P36,Q4) side by side to show they coincide on every total from 2 to 40 (144 equally-likely outcomes).",
            "code": demo,
        }
    ],
    "algorithms": [
        {
            "name": "Cyclotomic Block Quotient: Linear-Time Computation of S\u2086\u1d63/\u03a6\u2086",
            "description": "Computes the polynomial quotient S_{6r}/\u03a6\u2086 without performing any polynomial long division. The algorithm exploits the local telescoping identity \u03a6\u2086\u00b7(x+2x\u00b2+2x\u00b3+x\u2074) = x+x\u00b2+\u00b7\u00b7\u00b7+x\u2076: the fixed weight pattern (1,2,2,1) is exactly the preimage of a flat run of six monomials under multiplication by \u03a6\u2086. The quotient is therefore the sum of r shifted copies of that pattern, block(j) = x^{6j+1}+2x^{6j+2}+2x^{6j+3}+x^{6j+4}, whose images under \u03a6\u2086 tile the exponents 1..6r with no gaps or overlaps. The routine performs 4r coefficient updates on a length-(6r\u22121) array, giving O(r) time and O(r) space \u2014 linear in the output size \u2014 and, crucially, never introduces any negative intermediate coefficients, so nonnegativity of the quotient is manifest by construction. This is the computational engine behind the quotient identity phi6_mul_P36 and the template for generalizing the construction to any multiple of six.",
            "pseudocode": "function CyclotomicBlockQuotient(r):\n    require r >= 1\n    P <- array of zeros, indices 0 .. 6r-2      # coefficients of degrees 0..6r-2\n    for j in 0, 1, ..., r-1:\n        base <- 6*j\n        P[base + 1] <- P[base + 1] + 1\n        P[base + 2] <- P[base + 2] + 2\n        P[base + 3] <- P[base + 3] + 2\n        P[base + 4] <- P[base + 4] + 1\n    return P     # satisfies Phi_6 * P = S_{6r}, all coefficients in {0,1,2}",
            "code": algo,
        }
    ],
    "visualizations": [
        {
            "name": "Sum-Distribution Equality and the Block Structure of P36",
            "description": "A two-panel matplotlib figure. The left panel overlays the sum distributions of the standard pair (S\u2083\u2086,S\u2084) and the transfer pair (P36,Q4) as grouped bars over totals 2..40, making their exact coincidence visually unmistakable. The right panel renders the coefficients of P36 = S\u2083\u2086/\u03a6\u2086 across faces 1..36, color-coded by multiplicity, exposing the repeating block pattern 1,2,2,1,0,0 that tiles the die.",
            "code": viz,
        }
    ],
    "interactive_demos": [
        {
            "title": "Cyclotomic Dice Transfer Explorer",
            "description": "A self-contained HTML/JavaScript widget that lets the reader slide the big-die size through 6r for r = 1..12 and watch the quotient P = S_{6r}/\u03a6\u2086 rebuild itself from shifted (1,2,2,1) blocks, with a live check that \u03a6\u2086\u00b7P = S_{6r}. A second panel displays the transferred small die Q = \u03a6\u2086\u00b7S\u2084 (faces {1,3,4,6}), and a third draws the standard vs. transfer sum distributions for the 36\u00d74 base case side by side, confirming in real time that the two distributions are identical across all 144 equally-likely outcomes. All polynomial arithmetic runs in the browser; no external libraries are required.",
            "html": html,
        }
    ],
    "lean_proofs": lean,
    "future_directions": future_directions,
    "modules": {"demo": demo},
    "lean_files": [
        "Catalog/NumberTheory/Phi6SquareDiceBaseCase.lean"
    ],
}

with open(os.path.join(base, "PACKAGE.json"), "w", encoding="utf-8") as f:
    json.dump(pkg, f, ensure_ascii=False, indent=2)

print("PACKAGE.json written, keys:", list(pkg.keys()))
print("bytes:", os.path.getsize(os.path.join(base, "PACKAGE.json")))


"""
Visualization: sum distributions of the standard pair (S_36, S_4) versus the
cyclotomic-transfer pair (P36, Q4), shown side by side to make their identity
visually obvious. Also renders the block structure of P36.

Requires matplotlib. Run:  python3 visualization.py
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt


def trim(p: List[int]) -> List[int]:
    q = list(p)
    while len(q) > 1 and q[-1] == 0:
        q.pop()
    return q


def poly_mul(a: List[int], b: List[int]) -> List[int]:
    r = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            r[i + j] += ai * bj
    return trim(r)


def S(N: int) -> List[int]:
    return [0] + [1] * N


PHI6: List[int] = [1, -1, 1]


def P36() -> List[int]:
    p = [0] * 37
    for j in range(6):
        b = 6 * j
        p[b + 1] += 1
        p[b + 2] += 2
        p[b + 3] += 2
        p[b + 4] += 1
    return p


def main() -> None:
    p36, q4, s36, s4 = P36(), poly_mul(PHI6, S(4)), S(36), S(4)
    dist_std = poly_mul(s36, s4)
    dist_trf = poly_mul(p36, q4)
    sums = list(range(2, 41))
    std = [dist_std[s] for s in sums]
    trf = [dist_trf[s] for s in sums]

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    ax = axes[0]
    w = 0.4
    ax.bar([s - w / 2 for s in sums], std, width=w, label="standard (S36, S4)")
    ax.bar([s + w / 2 for s in sums], trf, width=w, label="transfer (P36, Q4)")
    ax.set_xlabel("sum of the two dice")
    ax.set_ylabel("number of equally-likely outcomes")
    ax.set_title("Identical sum distributions")
    ax.legend()

    ax = axes[1]
    coeffs = p36[1:37]
    colors = ["#d62728" if c == 2 else ("#1f77b4" if c == 1 else "#cccccc")
              for c in coeffs]
    ax.bar(range(1, 37), coeffs, color=colors)
    ax.set_xlabel("face value")
    ax.set_ylabel("multiplicity")
    ax.set_title("Block structure of P36 = S36 / $\\Phi_6$  (pattern 1,2,2,1,0,0)")

    fig.suptitle("Cyclotomic transfer of $\\Phi_6 = x^2 - x + 1$", fontsize=14)
    fig.tight_layout()
    fig.savefig("phi6_square_dice.png", dpi=150)
    print("saved phi6_square_dice.png")


if __name__ == "__main__":
    main()


"""
Semiprime Cyclotomic Transfer for Square-Sided Dice
===================================================

Numerical demonstration of the verified base case (p=2, q=3, m=6, n=2) built on
the sixth cyclotomic polynomial  Phi_6 = x^2 - x + 1.

A die with faces 1..N is encoded as the generating polynomial
    S_N(x) = x + x^2 + ... + x^N,
and the distribution of the SUM of two dice is the polynomial product of their
generators.  We verify, in exact integer arithmetic:

    (1) Phi_6 * P36 = S_36                (quotient identity, `phi6_mul_P36`)
    (2) Q4 = Phi_6 * S_4 = x + x^3 + x^4 + x^6   (`Q4_eq_phi6_mul_S4`)
    (3) P36(1) = 36,  Q4(1) = 4          (face counts)
    (4) P36 * Q4 = S_36 * S_4            (sum-preservation, the transfer)

Polynomials are represented as coefficient lists `c` with `c[k]` the coefficient
of x^k (index 0 = constant term).

Run:  python3 demo.py
"""

from __future__ import annotations

from typing import List


# --------------------------------------------------------------------------- #
#  Polynomial utilities (exact integer arithmetic)                            #
# --------------------------------------------------------------------------- #

def trim(p: List[int]) -> List[int]:
    """Remove trailing zero coefficients (keep at least the constant term)."""
    q = list(p)
    while len(q) > 1 and q[-1] == 0:
        q.pop()
    return q


def poly_mul(a: List[int], b: List[int]) -> List[int]:
    """Multiply two polynomials given as coefficient lists."""
    result = [0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        if ai == 0:
            continue
        for j, bj in enumerate(b):
            result[i + j] += ai * bj
    return trim(result)


def poly_eq(a: List[int], b: List[int]) -> bool:
    """Test equality of two polynomials up to trailing zeros."""
    return trim(a) == trim(b)


def evaluate_at_one(p: List[int]) -> int:
    """Evaluate a polynomial at x = 1 (the face count for a die polynomial)."""
    return sum(p)


def to_string(p: List[int]) -> str:
    """Human-readable rendering of a polynomial."""
    terms: List[str] = []
    for k, c in enumerate(p):
        if c == 0:
            continue
        if k == 0:
            terms.append(str(c))
        else:
            coeff = "" if c == 1 else f"{c}*"
            power = "x" if k == 1 else f"x^{k}"
            terms.append(f"{coeff}{power}")
    return " + ".join(terms) if terms else "0"


def faces(p: List[int]) -> List[int]:
    """Multiset of die faces encoded by a die polynomial (faces with repeats)."""
    out: List[int] = []
    for k, c in enumerate(p):
        out.extend([k] * c)
    return out


# --------------------------------------------------------------------------- #
#  The objects of the base case                                               #
# --------------------------------------------------------------------------- #

def S(N: int) -> List[int]:
    """Standard N-sided die generating polynomial  x + x^2 + ... + x^N."""
    p = [0] * (N + 1)
    for i in range(1, N + 1):
        p[i] = 1
    return p


# Sixth cyclotomic polynomial Phi_6 = x^2 - x + 1  (constant, linear, quadratic)
PHI6: List[int] = [1, -1, 1]


def block(j: int) -> List[int]:
    """The degree-4 block shifted by 6j:  x^{6j+1}+2x^{6j+2}+2x^{6j+3}+x^{6j+4}."""
    base = 6 * j
    p = [0] * (base + 5)
    p[base + 1] += 1
    p[base + 2] += 2
    p[base + 3] += 2
    p[base + 4] += 1
    return p


def P36() -> List[int]:
    """The 36-sided nonstandard die  P36 = sum_{j=0}^{5} block(j) = S_36 / Phi_6."""
    acc: List[int] = [0]
    for j in range(6):
        acc = poly_add(acc, block(j))
    return trim(acc)


def poly_add(a: List[int], b: List[int]) -> List[int]:
    """Add two polynomials."""
    n = max(len(a), len(b))
    out = [0] * n
    for i, ai in enumerate(a):
        out[i] += ai
    for i, bi in enumerate(b):
        out[i] += bi
    return trim(out)


def Q4() -> List[int]:
    """The transferred 4-sided die  Q4 = Phi_6 * S_4."""
    return poly_mul(PHI6, S(4))


# --------------------------------------------------------------------------- #
#  Demonstration                                                              #
# --------------------------------------------------------------------------- #

def main() -> None:
    p36 = P36()
    q4 = Q4()
    s36 = S(36)
    s4 = S(4)

    print("=" * 70)
    print("  Semiprime cyclotomic transfer: base case p=2, q=3, m=6, n=2")
    print("=" * 70)
    print(f"  Phi_6           = {to_string(PHI6)}")
    print(f"  S_4             = {to_string(s4)}")
    print(f"  P36 (= S_36/Phi_6) coeffs = {p36[1:]}")
    print(f"  Q4  (= Phi_6*S_4)         = {to_string(q4)}")
    print(f"  Q4 faces                  = {faces(q4)}")
    print()

    # (1) Quotient identity:  Phi_6 * P36 = S_36
    lhs1 = poly_mul(PHI6, p36)
    ok1 = poly_eq(lhs1, s36)
    print(f"(1) Phi_6 * P36 == S_36           : {ok1}")

    # (2) Transfer identity:  Q4 = Phi_6 * S_4 = x + x^3 + x^4 + x^6
    expected_q4 = [0, 1, 0, 1, 1, 0, 1]
    ok2 = poly_eq(q4, expected_q4)
    print(f"(2) Q4 == x + x^3 + x^4 + x^6     : {ok2}")

    # (3) Face counts
    ok3 = evaluate_at_one(p36) == 36 and evaluate_at_one(q4) == 4
    print(f"(3) P36(1)=={evaluate_at_one(p36)}, Q4(1)=={evaluate_at_one(q4)}"
          f"     : {ok3}")

    # (4) Sum-preservation:  P36 * Q4 = S_36 * S_4
    ok4 = poly_eq(poly_mul(p36, q4), poly_mul(s36, s4))
    print(f"(4) P36 * Q4 == S_36 * S_4        : {ok4}")

    # Nonnegativity
    ok5 = all(c >= 0 for c in p36) and all(c >= 0 for c in q4)
    print(f"(5) P36, Q4 nonnegative           : {ok5}")

    # Nonstandardness witness
    ok6 = p36[5] == 0 and s36[5] == 1
    print(f"(6) Nonstandard: [x^5]P36=0 != 1=[x^5]S_36 : {ok6}")

    print()
    # Show the two sum distributions coincide.
    dist_standard = poly_mul(s36, s4)
    dist_transfer = poly_mul(p36, q4)
    print("  Sum distribution (ways to roll total s), standard vs. transfer:")
    print(f"  {'s':>4} | {'standard':>9} | {'transfer':>9}")
    for s in range(2, 41):
        a = dist_standard[s] if s < len(dist_standard) else 0
        b = dist_transfer[s] if s < len(dist_transfer) else 0
        flag = "" if a == b else "   <-- MISMATCH"
        print(f"  {s:>4} | {a:>9} | {b:>9}{flag}")
    print(f"  total outcomes: {sum(dist_standard)} (= 36 * 4 = 144)")
    print()

    all_ok = all([ok1, ok2, ok3, ok4, ok5, ok6])
    print("=" * 70)
    print(f"  ALL CHECKS PASSED: {all_ok}")
    print("=" * 70)


if __name__ == "__main__":
    main()
