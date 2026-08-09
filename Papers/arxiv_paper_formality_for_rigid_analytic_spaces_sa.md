# Computational Evidence

Target statement: *a differential graded algebra with a compatible weight grading whose
cohomology is pure (weight = cohomological degree) is formal*, together with its Massey-product
consequences. This is the algebraic engine behind formality of the étale / de Rham cohomology
algebras of smooth proper rigid-analytic spaces satisfying the weight-monodromy conjecture.

The claim is a statement about arbitrary bigraded dg-algebras, so there is no sequence to look
up in the OEIS. What can be — and was — checked computationally is the *bookkeeping* of the
bidegrees, which is exactly where such a statement can silently fail. All arithmetic below is
elementary and was re-verified inside Lean as part of the proofs (the Lean files are the
authoritative artifact; nothing in this note is claimed as verified on its own).

## 1. Small-case bidegree table (the mechanism)

Write `(n, w)` for (cohomological degree, weight), `d : (n, w) → (n+1, w)`.
Purity means: cohomology only in bidegrees on the diagonal `w = n`.

| object | degree | weight | on diagonal? |
|---|---|---|---|
| cocycle `x` | `p` | `p` | yes |
| cocycle `y` | `q` | `q` | yes |
| cocycle `z` | `r` | `r` | yes |
| product `x·y` | `p+q` | `p+q` | yes |
| primitive `u`, `du = xy` | `p+q-1` | `p+q` | **no** (weight exceeds degree by 1) |
| Massey rep. `s·(u z) − x v` | `p+q+r-1` | `p+q+r` | **no** (excess 1) |

The single line that makes the theorem work: the excess `w − n` is additive under products and
is *raised by one* by every primitive that a Massey product needs. Purity annihilates every
class of nonzero excess, so every Massey product is forced to contain `0`.

Sanity checks of the same table for the degenerate cases:

* `p = q = r = 0` (degree-zero classes): Massey representative sits in bidegree `(-1, 0)`,
  still off-diagonal, still killed.
* if one rescales weights by `α` (`w = α·n`), the excess of the Massey representative is `α`;
  it vanishes precisely when `α = 0`. So the argument, and the theorem, are sharp exactly in the
  normalisations with `α ≠ 0`. This is the reason the formalisation fixes the standard
  normalisation `w = n` and records the general case as a future direction.

## 2. Truncation model: which pieces survive

For the strict formality zig-zag `A ⊇ A' ↠ A'/J` the pieces are

```
A'(n,w) = 𝒜(n,w)                       if n < w
        = cocycles in 𝒜(n,w)            if n = w
        = 0                             if n > w

J(n,w)  = 𝒜(n,w)                       if n < w
        = d(𝒜(n-1,w))                   if n = w
        = 0                             if n > w
```

Closure checks (all four cases were enumerated by hand before formalising, and each one appears
as a case split in the Lean proof of `pieceSub_mul_le` / `pieceIdeal_mul_le`):

| factors | degrees vs weights | product | in `A'`? |
|---|---|---|---|
| below × below | `n<w`, `m<v` | `n+m < w+v` | yes (below) |
| below × diagonal | `n<w`, `m=v` | `n+m < w+v` | yes (below) |
| diagonal × diagonal | `n=w`, `m=v` | `n+m = w+v`, both cocycles | yes (diagonal) |
| anything × above | piece is `0` | `0` | yes |

The only non-formal step is the diagonal × diagonal case, which needs the Leibniz rule; this is
what forces the Koszul-sign hypothesis to be nowhere zero.

## 3. Counterexample hunt

* **Is purity automatic?** No. `k[ℤ × ℤ]` with the tautological bigrading and zero differential
  has cohomology in every bidegree, in particular off the diagonal. Formalised and proved:
  `Examples.squareDGA_not_isWeightPure`.
* **Is purity vacuous?** No. `k[ℤ]` placed on the diagonal `n ↦ (n, n)` with zero differential
  is pure and has a nonzero, non-exact class in every degree. Formalised and proved:
  `Examples.diagonalDGA_isWeightPure`, `Examples.diagonalDGA_nontrivial_cohomology`.
* **Can a Massey product survive purity?** The bidegree table above says no, and the Lean proof
  `massey_zero_of_weightPure` confirms it. Conversely a genuinely nonvanishing Massey product
  forbids purity (`not_weightPure_of_massey`) — the algebraic shadow of the non-formal
  rigid-analytic surfaces.

No counterexample to any statement that was formalised was found; the two examples above were
found while probing the hypotheses and are now part of the formal development.
