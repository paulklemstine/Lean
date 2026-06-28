/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Transseries: Ingredients of Real Closedness — Divisible Value Group and Monomial Roots

A Hahn-series field `K((G))` over a coefficient field `K` and value group `G` is **real
closed** precisely when `K` is real closed *and* `G` is a divisible ordered abelian group
(Maclane / the Artin–Schreier theory of Hahn fields).  Here `K = ℝ` is real closed and the
transseries value group is `G = Lex (ℤ →₀ ℝ)`.

The decisive feature of transseries — the one that pushes them past Laurent/Puiseux series
toward real closedness — is that the exponents are **real**, making the value group
`ℤ →₀ ℝ` *divisible* (a direct sum of copies of the divisible group `ℝ`).  By contrast the
Laurent value group `ℤ` is **not** divisible, which is exactly why the Laurent field fails to
be real closed.  This file isolates and proves that divisibility, and turns it into the
concrete consequence that **every positive transmonomial has an `n`-th root** (in particular
is a square) in the ordered field `OTSeries` — the monomial shadow of full real closedness.

## Main results

- `EMLTransseries.valueGroup_divisible`  : the value group is **divisible** — every
                                           transmonomial is `n`-divisible for `n > 0`.
- `EMLTransseries.isSquare_term`         : every one-term transseries is a **square**.
- `EMLTransseries.exists_nthRoot_term`   : every one-term transseries has an **`n`-th root**.
- `EMLTransseries.laurent_value_group_not_divisible` : the Laurent value group `ℤ` is **not**
                                           divisible — the precise obstruction transseries
                                           overcome.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): real exponents make the transseries value group divisible, and
this divisibility is *equivalent* to monomials having roots — the first nontrivial instance
of the square/root property required for real closedness.

Experiment (Experimenter): divisibility `∃ g', n • g' = g` was witnessed constructively by
`g' = (n : ℝ)⁻¹ • g`, verified pointwise on the finsupp via `mul_inv_cancel₀`.  Monomial roots
follow by halving / dividing the *exponent*: `(term h (a/n))^n = term h (n·(a/n)) = term h a`
through the law of exponents `term_pow`, then transported into the ordered field by `toLex`.
The contrast was sharpened by proving the Laurent value group `ℤ` is *not* divisible: `2 • k = 1`
has no integer solution (`omega`).

Analysis (Analyst): the result is "true and structural".  The square `term h (a/2)` exists
*only* because exponents live in the divisible group `ℝ`; over `ℤ`-exponents (Laurent) the
half-exponent `a/2` would not exist, so `x` would have no square root.  This is the cleanest
formal explanation of *why* transseries — and not Laurent series — approach real closedness.
Full real closedness additionally needs roots of `1 + ε` (binomial series) and of arbitrary
positive series (Newton iteration); we deliberately scope to the monomial / value-group layer,
which is the genuinely transseries-specific ingredient.

Critique (Critic): not `rfl`/`decide`.  `valueGroup_divisible` constructs a witness and proves
a pointwise field identity; `exists_nthRoot_term` uses induction-backed `term_pow` and a
`field_simp` exponent identity.  Attempted counterexample: does the root really land in the
*ordered* field with the right value?  We compute `(term h (a/n))^n = term h a` as an equality
of transseries (not just up to sign), and `term h (a/n)` is positive by `term_pos`, so the
`n`-th root is the genuine positive root.  The Laurent non-divisibility theorem rules out the
"obvious" worry that this could also hold for ordinary Laurent series.
-- !-- Lab Notes -- !--
-/
import EML.Transseries.OrderedField

open HahnSeries

namespace EMLTransseries

noncomputable section

/-- **The value group of transseries is divisible.**  For every transmonomial `g` and every
positive `n`, there is a transmonomial `g'` with `n • g' = g`.  This is the abelian-group
divisibility of `Lex (ℤ →₀ ℝ)`, inherited from divisibility of the real exponent group `ℝ`,
and is the value-group half of the criterion for a Hahn field to be real closed. -/
theorem valueGroup_divisible (g : TransMono) (n : ℕ) (hn : 0 < n) :
    ∃ g', n • g' = g := by
  refine ⟨toLex ((n : ℝ)⁻¹ • (ofLex g)), ?_⟩
  show (n • ((n : ℝ)⁻¹ • (ofLex g)) : ℤ →₀ ℝ) = ofLex g
  ext i
  simp only [Finsupp.smul_apply, smul_eq_mul, nsmul_eq_mul]
  rw [← mul_assoc, mul_inv_cancel₀ (by exact_mod_cast hn.ne'), one_mul]

/-- **Every one-term transseries has an `n`-th root** (for `n > 0`) in the ordered field.
The root is the transmonomial with exponent divided by `n`, witnessing — at the monomial
level — the root-extraction property of real closed fields. -/
theorem exists_nthRoot_term (h : ℤ) (a : ℝ) (n : ℕ) (hn : 0 < n) :
    ∃ y : OTSeries, y ^ n = toLex (term h a) := by
  refine ⟨toLex (term h (a / n)), ?_⟩
  have hpow : (toLex (term h (a / n)) : OTSeries) ^ n = toLex ((term h (a / n)) ^ n) := rfl
  rw [hpow, term_pow]
  congr 1
  field_simp

/-- **Every one-term transseries is a square** in the ordered field — the `n = 2` case of
`exists_nthRoot_term`, and the defining root property of a real closed field restricted to
transmonomials. -/
theorem isSquare_term (h : ℤ) (a : ℝ) : IsSquare (toLex (term h a) : OTSeries) := by
  refine ⟨toLex (term h (a / 2)), ?_⟩
  have hmul : (toLex (term h (a / 2)) : OTSeries) * toLex (term h (a / 2))
      = toLex (term h (a / 2) * term h (a / 2)) := rfl
  rw [hmul, term_mul_term_same]
  norm_num

/-- **The Laurent value group `ℤ` is NOT divisible.**  There is no integer `k` with `2k = 1`:
the precise obstruction that prevents the Laurent-series field from being real closed, and the
property transseries overcome by using real exponents. -/
theorem laurent_value_group_not_divisible : ¬ ∃ k : ℤ, 2 • k = 1 := by
  rintro ⟨k, hk⟩
  rw [two_nsmul] at hk
  omega

end

end EMLTransseries