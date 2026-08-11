# Computational evidence (Solomon zeta cycle: D2, D5)

All numbers below were produced by `#eval` inside this Lean project (brute-force enumeration
over finite types), before the corresponding general statements were formalised.  They are
*evidence*, not proof: the machine-checked statements are the theorems listed at the end.

## 1. Gaussian-binomial numerator = number of surjections `(𝔽_p)ⁿ ↠ (𝔽_p)^d`

Brute-force count of matrices `A : Fin n → Fin d → ZMod p` whose induced map is surjective,
compared with `∏_{i<d}(pⁿ − p^i)` — the numerator appearing in `freeMobiusWeight`.

| p | n | d | brute-force count | `∏_{i<d}(pⁿ − p^i)` |
|---|---|---|-------------------|---------------------|
| 2 | 2 | 1 | 3   | 3   |
| 2 | 2 | 2 | 6   | 6   |
| 2 | 3 | 2 | 42  | 42  |
| 3 | 2 | 1 | 8   | 8   |
| 3 | 2 | 2 | 48  | 48  |
| 2 | 1 | 2 | 0   | 0   |

The last row is the degenerate case `d > n`: no surjection exists, and the product vanishes —
exactly the vanishing used in `freeMobiusWeight_residue_pi_succ`.

## 2. `𝔽_p[ℤ/pℤ]` is local (input to D2)

The group algebra was realised as functions `ZMod p → ZMod p` under convolution.

| p | #units (brute force) | `p^p − p^{p−1}` | every augmentation-zero element `a` satisfies `a^p = 0`? |
|---|----------------------|-----------------|----------------------------------------------------------|
| 2 | 2                    | 2               | true                                                       |
| 3 | 18                   | 18              | true                                                       |

So the non-units form the augmentation ideal (of size `p^{p−1}`), which is nil of exponent `p`:
the ring is local with residue field `𝔽_p`.  This is the mod-`p` half of D2; the `ℤ_p` half is
the Nakayama ascent formalised in `SolomonZetaLocalityAscent.lean`.

## 3. Freeness is not detected by one quotient type (sharpness of D5)

Over `R = ℤ_p`, take `n = 1` and compare the number of surjections from `M` with the free
weight `freeMobiusWeight ℤ_p 1 X = (p − 1)·#(pX)`:

| `X`            | `#surj(ℤ_p ↠ X)` = free weight | `#surj(𝔽_p ↠ X)` | `#surj(ℤ_p ⊕ 𝔽_p ↠ X)` |
|----------------|--------------------------------|-------------------|--------------------------|
| `𝔽_p`          | `p − 1`                        | `p − 1`           | `p² − 1` (rank 2 needed) |
| `(𝔽_p)²`       | `0`                            | `0`               | `(p²−1)(p²−p)`           |
| `ℤ/p²`         | `p(p − 1)`                     | `0`               | `p³ − p²`                |

Reading the middle column: `M = 𝔽_p` matches the rank one free weight at the residual test
space `(𝔽_p)²` (both `0`) and at `𝔽_p`, but not at `ℤ/p²`.  Hence the conjectured "a single
well-chosen `X` of residual dimension `n+1` suffices" is **false**; the counterexample is
formalised as `SolomonZeta.mobiusWeight_residue_pi_succ_insufficient`.  The last column shows
the same phenomenon for `M = ℤ_p ⊕ 𝔽_p` at rank `n = 2`: at `X = ℤ/p²` one finds
`#surj(M ↠ X) = p³ − p²`, whereas the rank two free weight is `(p² − 1)·p² = p⁴ − p²`.  This is
what motivated the "all finite `X`" formulation that was proved.

## 4. OEIS

The counts in §1 are the Gaussian-binomial numerators; for `p = 2`, `d = n` they are the orders
of `GL_n(𝔽_2)`: `1, 1, 6, 168, 20160, …` (OEIS A002884).  No new sequence was needed in this
cycle.

## 5. What is machine-checked

* `SolomonZeta.isLocalRing_padicMonoidAlgebra`, `SolomonZeta.residueFieldPadicMonoidAlgebraEquiv`,
  `SolomonZeta.autCard_mul_quotIsoCount_padicMonoidAlgebra_free`,
  `SolomonZeta.autCard_mul_quotIsoCount_padicCyclic_free` (conjecture D2);
* `SolomonZeta.nonempty_linearEquiv_free_iff_mobiusWeight_eq`,
  `SolomonZeta.nonempty_linearEquiv_free_iff_mobiusWeight_eq_padic` (conjecture D5),
  with the sharpness statement `SolomonZeta.mobiusWeight_residue_pi_succ_insufficient` and the
  maximality bound `SolomonZeta.mobiusWeight_le_freeMobiusWeight`;
* `SolomonZeta.isLocalRing_of_isMaximal_of_pow_mem` (the general locality ascent);
* `SolomonZeta.mobiusWeight_pi`, `SolomonZeta.mobiusWeight_congr_of_card_hom_eq` (D3 input).
