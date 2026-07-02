import Catalog.Applications.FourierFiniteGroups.Basic

/-!
# The Donoho–Stark uncertainty principle on `ZMod N`

For a nonzero function `f : ZMod N → ℂ` we prove the discrete uncertainty
principle
$$ |\operatorname{supp} f| \cdot |\operatorname{supp} \widehat f| \ge N . $$

This is the finite-group analogue of the Heisenberg uncertainty principle: a
function and its Fourier transform cannot both be concentrated on a small set.

-- !-- Lab Notes -- !--
Hypothesis (H2, bold): On *any* finite abelian group `G` one has
`|supp f| · |supp f̂| ≥ |G|` for `f ≠ 0`.  We formalise the cyclic case `G = ZMod N`
which already captures the full analytic content.
Experiment: the proof is the classical two-line Hölder argument.  Set
`Mf := ‖f‖∞`, `Mg := ‖f̂‖∞`.  The two "mixed" bounds
  (A) `Mg ≤ |supp f| · Mf`            (from `dft_norm_le_l1` + `l1_le_card_mul_supNorm`)
  (B) `Mf ≤ N⁻¹ · |supp f̂| · Mg`      (from `f_norm_le_invDFT_l1` + same)
chain to `Mg ≤ (|supp f| · |supp f̂| / N) · Mg`.  Since `f ≠ 0` forces `f̂ ≠ 0`
(`ZMod.dft` is a `LinearEquiv`), `Mg > 0`, and cancelling gives the result.
Analysis: the cancellation step `1 ≤ a·b/N` then `N ≤ a·b` is pure ordered-field
arithmetic; the only Fourier input is the pair of mixed bounds, which in turn use
only `|χ| = 1` and Fourier inversion — no orthogonality.
Critique: the statement is non-vacuous (it fails for `f = 0`, where both supports
are empty, so the hypothesis `f ≠ 0` is genuinely load-bearing), and the bound is
sharp (an indicator of a subgroup of size `d` has transform supported on the
annihilator of size `N/d`, giving equality `d · (N/d) = N`).
-/

open scoped BigOperators

namespace Catalog.FourierFiniteGroups

variable {N : ℕ} [NeZero N]

/-
**Mixed bound (A).**  The sup-norm of the Fourier transform is controlled by
the size of the support of `f` times the sup-norm of `f`.
-/
lemma supNorm_dft_le (f : ZMod N → ℂ) :
    supNorm (ZMod.dft f) ≤ (fsupp f).card * supNorm f := by
  refine' Finset.sup'_le _ _ _;
  intro b hb; exact le_trans ( dft_norm_le_l1 f b ) ( by simpa [ mul_comm ] using l1_le_card_mul_supNorm f ) ;

/-
**Mixed bound (B).**  The sup-norm of `f` is controlled (via Fourier
inversion) by the size of the support of `𝓕 f` times the sup-norm of `𝓕 f`.
-/
lemma supNorm_le_invDFT (f : ZMod N → ℂ) :
    supNorm f ≤ (N : ℝ)⁻¹ * (fsupp (ZMod.dft f)).card * supNorm (ZMod.dft f) := by
  -- Apply the inversion formula and the inequality from `l1_le_card_mul_supNorm`.
  suffices h : ∀ j : ZMod N, ‖f j‖ ≤ (↑N : ℝ)⁻¹ * (fsupp (ZMod.dft f)).card * supNorm (ZMod.dft f) by
    exact Finset.sup'_le _ _ fun j _ => h j;
  exact fun j => by simpa only [ mul_assoc ] using le_trans ( f_norm_le_invDFT_l1 f j ) ( mul_le_mul_of_nonneg_left ( le_trans ( l1_le_card_mul_supNorm ( ZMod.dft f ) ) ( by linarith ) ) ( by positivity ) ) ;

/-
**Donoho–Stark uncertainty principle** on `ZMod N`.  For every nonzero
function `f : ZMod N → ℂ`, the product of the sizes of the support of `f` and of
the support of its discrete Fourier transform is at least `N`.
-/
theorem donoho_stark_uncertainty (f : ZMod N → ℂ) (hf : f ≠ 0) :
    N ≤ (fsupp f).card * (fsupp (ZMod.dft f)).card := by
  -- From the mixed bounds we have Mg ≤ a * Mf and Mf ≤ (N:ℝ)⁻¹ * b * Mg.
  set Mg := supNorm (ZMod.dft f)
  set Mf := supNorm f
  set a := (fsupp f).card
  set b := (fsupp (ZMod.dft f)).card
  have hMg : Mg ≤ a * Mf := by
    convert supNorm_dft_le f using 1
  have hMf : Mf ≤ (N:ℝ)⁻¹ * b * Mg := by
    convert supNorm_le_invDFT f using 1;
  -- From Mg ≤ a * (N:ℝ)⁻¹ * b * Mg and Mg > 0, we get 1 ≤ a * b / N.
  have h_one : (N:ℝ) ≤ a * b := by
    have h_one : Mg ≤ a * (N:ℝ)⁻¹ * b * Mg := by
      nlinarith [ show 0 ≤ ( a : ℝ ) by positivity ];
    contrapose! h_one;
    exact mul_lt_of_lt_one_left ( show 0 < Mg from by simpa using supNorm_pos <| show ZMod.dft f ≠ 0 from by simpa using ( LinearEquiv.map_ne_zero_iff ZMod.dft ).mpr hf ) ( by nlinarith [ inv_mul_cancel₀ ( show ( N : ℝ ) ≠ 0 by norm_cast; exact NeZero.ne N ) ] );
  exact_mod_cast h_one

end Catalog.FourierFiniteGroups