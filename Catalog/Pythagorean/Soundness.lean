/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import CertifiedLorentzianRecognition.Defs

/-!
# Certified Lorentzian Recognition: Soundness Theorems

This file proves the core soundness theorems for certified Lorentzian recognition
under floating-point coefficient uncertainty. Together with the definitions in `Defs.lean`,
these theorems form the first formal bridge between interval arithmetic and Lorentzian
polynomial theory.

## Main Results

### Theorem 1 — Soundness of certified robust recognition
* `certify_lorentzian_of_margin_dominates` — If spectral margin > perturbation error
  on a coefficient box, then every matrix in the box has Lorentzian signature.
* `certify_nonlorentzian_of_obstruction_dominates` — Dual result for certified
  non-Lorentzianity.

### Theorem 2 — Quantitative perturbation bound
* `gapped_signature_residual` — Gapped signature degrades linearly under perturbation.
* `spectralMargin_entrywise_perturbation` — Entry-wise bounds yield Lipschitz control
  of the spectral margin with constant n².

### Theorem 3 — Grid ambiguity bound
* `monotone_grid_ambiguity_le` — For monotone sequences, ambiguous grid count is O(ε/δ).

### Theorem 4 — Cross-domain bridge
* `lorentzian_signature_implies_energy_decay` — Lorentzian signature implies
  control-style energy decay on the orthogonal complement.
* `energy_decay_robust_under_perturbation` — Energy decay margins degrade gracefully.

### Algorithm soundness
* `certifyLorentzian_sound_yes` — Algorithm returns `yes` ⟹ robust Lorentzianity.
* `certifyLorentzian_sound_no` — Algorithm returns `no` ⟹ robust non-Lorentzianity.
-/

open Finset BigOperators Matrix

noncomputable section

namespace CertifiedLorentzian

/-! ## Theorem 1: Soundness of Certified Robust Recognition -/

/-
**Soundness of certified Lorentzian recognition (positive case).**

If the center matrix has a gapped signature with gap `margin`, and every matrix
in the coefficient box differs from the center by a perturbation with quadratic
form bound at most `err < margin`, then every matrix in the box has Lorentzian
signature. This converts floating-point uncertainty into a valid certificate.
-/
theorem certify_lorentzian_of_margin_dominates
    {n : ℕ} {ι : Type*}
    (B : FPBox ι)
    (toMatrix : (ι → ℝ) → Matrix (Fin n) (Fin n) ℝ)
    (margin err : ℝ)
    (hmargin_pos : 0 < margin)
    (hmargin_err : err < margin)
    (hcenter_gap : HasGappedSignature (toMatrix B.center) margin)
    (hpert : ∀ a, B.mem a →
      QuadFormBound (toMatrix a - toMatrix B.center) err) :
    RobustLorentzianOnBox B toMatrix := by
  obtain ⟨ w, hw ⟩ := hcenter_gap;
  intro a ha;
  use w;
  intro v hv; specialize hpert a ha v; rw [ show toMatrix a = toMatrix B.center + ( toMatrix a - toMatrix B.center ) by abel1 ] ; simp_all +decide [ quadForm_add ] ;
  rw [ show toMatrix a = toMatrix B.center + ( toMatrix a - toMatrix B.center ) by abel1, quadForm_add ] ; nlinarith [ hw v hv, abs_le.mp hpert, sqNorm_nonneg v ] ;

/-
**Soundness of certified non-Lorentzian recognition.**

If the center has a quantitative obstruction and the perturbation is smaller,
then no matrix in the box has Lorentzian signature.
-/
theorem certify_nonlorentzian_of_obstruction_dominates
    {n : ℕ} {ι : Type*}
    (B : FPBox ι)
    (toMatrix : (ι → ℝ) → Matrix (Fin n) (Fin n) ℝ)
    (obs err : ℝ)
    (hobs_pos : 0 < obs)
    (hobs_err : err < obs)
    (hcenter_obs : HasObstruction (toMatrix B.center) obs)
    (hpert : ∀ a, B.mem a →
      QuadFormBound (toMatrix a - toMatrix B.center) err) :
    RobustNonLorentzianOnBox B toMatrix := by
  intro a ha;
  rintro ⟨ w, hw ⟩;
  obtain ⟨ v, hv₁, hv₂, hv₃ ⟩ := hcenter_obs w;
  have := hpert a ha v;
  simp_all +decide [ abs_le, QuadForm ];
  simp_all +decide [ sub_mul, mul_sub ];
  nlinarith [ hw v hv₁ ]

/-! ## Theorem 2: Quantitative Perturbation Bounds -/

/-
**Residual gap under perturbation.**

If A has gapped signature with gap ε and E has quadratic form bound δ < ε,
then A + E has residual gap ε - δ. This is the exact modulus of robustness.
-/
theorem gapped_signature_residual
    {n : ℕ} (A E : Matrix (Fin n) (Fin n) ℝ)
    {ε δ : ℝ}
    (hgap : HasGappedSignature A ε)
    (hbound : QuadFormBound E δ)
    (hsmall : δ < ε) :
    HasGappedSignature (A + E) (ε - δ) := by
  obtain ⟨ w, hw ⟩ := hgap;
  use w;
  intro v hv; rw [ quadForm_add ] ; linarith [ hw v hv, abs_le.mp ( hbound v ) ] ;

/-
**Entry-wise perturbation bound for quadratic form.**

A matrix with entries bounded by B has quadratic form bounded by n² · B.
This connects entry-wise coefficient perturbation to quadratic form bounds.
-/
theorem quadFormBound_of_entry_bound
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (B : ℝ) (hB : 0 ≤ B)
    (hentry : ∀ i j, |A i j| ≤ B) :
    QuadFormBound A ((n : ℝ) ^ 2 * B) := by
  intro v;
  -- By the properties of the quadratic form and the Cauchy-Schwarz inequality, we have:
  have h_cauchy_schwarz : ∀ i j, |A i j * v i * v j| ≤ B * (v i ^ 2 + v j ^ 2) / 2 := by
    intro i j; rw [ abs_le ] ; constructor <;> nlinarith [ abs_le.mp ( hentry i j ), sq_nonneg ( v i - v j ), sq_nonneg ( v i + v j ) ] ;
  refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun i _ => Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun j _ => h_cauchy_schwarz i j ) _ );
  norm_num [ sqNorm, Finset.sum_add_distrib, ← Finset.mul_sum _ _ _, ← Finset.sum_div ] ; ring_nf;
  exact mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_left ( mod_cast Nat.le_self_pow ( by norm_num ) _ ) hB ) ( Finset.sum_nonneg fun _ _ => sq_nonneg _ )

/-- **Spectral margin perturbation via entry-wise control.**

If Q has gapped signature with gap ε, and E has entries bounded by δ,
then Q + E has gapped signature with gap ε - n² · δ (when positive).
The Lipschitz constant is n². -/
theorem spectralMargin_entrywise_perturbation
    {n : ℕ} {Q E : Matrix (Fin n) (Fin n) ℝ}
    {ε δ : ℝ}
    (hgap : HasGappedSignature Q ε)
    (hentry : ∀ i j, |E i j| ≤ δ)
    (hδ : 0 ≤ δ)
    (hsmall : (n : ℝ) ^ 2 * δ < ε) :
    HasGappedSignature (Q + E) (ε - (n : ℝ) ^ 2 * δ) := by
  exact gapped_signature_residual Q E hgap (quadFormBound_of_entry_bound E δ hδ hentry) hsmall

/-! ## Theorem 3: Grid Ambiguity Bound -/

/-- Count of ambiguous grid points. -/
def gridAmbiguousCount {N : ℕ} (f : Fin N → ℝ) (ε : ℝ) : ℕ :=
  (Finset.univ.filter fun i => |f i| ≤ ε).card

/-- Trivial upper bound. -/
theorem gridAmbiguousCount_le_card {N : ℕ} (f : Fin N → ℝ) (ε : ℝ) :
    gridAmbiguousCount f ε ≤ N := by
  unfold gridAmbiguousCount
  exact le_trans (Finset.card_filter_le _ _) (by simp)

/-
**Monotone grid ambiguity bound.**

For a strictly increasing sequence on Fin N with step size ≥ δ > 0,
the number of grid points with |f(i)| ≤ ε is at most ⌊2ε/δ⌋ + 1.

This is the discretized version of the O(ε) ambiguity-volume theorem:
near a zero crossing, a Lipschitz function traverses the [-ε,ε] band
in at most 2ε/δ grid steps.
-/
theorem monotone_grid_ambiguity_le
    {N : ℕ} (f : Fin N → ℝ) (δ ε : ℝ)
    (hδ : 0 < δ) (hε : 0 ≤ ε)
    (hmono : ∀ i j : Fin N, i < j → f i + δ ≤ f j) :
    gridAmbiguousCount f ε ≤ Nat.floor (2 * ε / δ) + 1 := by
  -- Let $S$ be the set of indices $i$ such that $|f(i)| \leq \epsilon$.
  set S : Finset (Fin N) := Finset.univ.filter (fun i => |f i| ≤ ε) with hS_def;
  by_cases hS_empty : S = ∅ <;> simp_all +decide [ gridAmbiguousCount ];
  · grind +locals;
  · -- Let $a$ and $b$ be the minimum and maximum indices in $S$, respectively.
    obtain ⟨a, ha⟩ : ∃ a ∈ S, ∀ i ∈ S, a ≤ i := by
      exact ⟨ Finset.min' S ⟨ hS_empty.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hS_empty.choose_spec ⟩ ⟩, Finset.min'_mem _ _, fun i hi => Finset.min'_le _ _ hi ⟩
    obtain ⟨b, hb⟩ : ∃ b ∈ S, ∀ i ∈ S, i ≤ b := by
      exact ⟨ Finset.max' S ⟨ a, ha.1 ⟩, Finset.max'_mem _ _, fun i hi => Finset.le_max' _ _ hi ⟩
    have h_dist : b - a ≤ ⌊2 * ε / δ⌋₊ := by
      have h_dist : f b - f a ≥ (b - a) * δ := by
        have h_dist : ∀ i j : Fin N, i ≤ j → f j - f i ≥ (j - i) * δ := by
          intro i j hij; induction' j with j hj ih generalizing i; induction' i with i hi ih' ; simp_all +decide [ Finset.sum_range_succ ] ;
          induction hij <;> norm_num at *;
          rename_i k hk ih; linarith! [ ih ( by linarith ), hmono ⟨ k, by linarith ⟩ ⟨ k + 1, by linarith ⟩ ( Nat.lt_succ_self _ ) ] ;
        exact h_dist a b ( ha.2 b hb.1 ) |> le_trans ( by norm_num ) |> le_trans <| by norm_num;
      simp +zetaDelta at *;
      exact Nat.le_of_lt_succ <| by rw [ ← @Nat.cast_lt ℝ ] ; push_cast; nlinarith [ abs_le.mp ha.1, abs_le.mp hb.1, mul_div_cancel₀ ( 2 * ε ) hδ.ne', Nat.lt_floor_add_one ( 2 * ε / δ ) ] ;
    have h_card : S.card ≤ b - a + 1 := by
      have h_card : S ⊆ Finset.Icc a b := by
        exact fun i hi => Finset.mem_Icc.mpr ⟨ ha.2 i hi, hb.2 i hi ⟩
      have h_card_le : S.card ≤ (Finset.Icc a b).card := by
        exact Finset.card_le_card h_card
      simp_all +decide [ Finset.card_range ];
      omega;
    linarith [Nat.floor_le (show 0 ≤ 2 * ε / δ by positivity)]

/-! ## Theorem 4: Cross-Domain Bridge — Energy Decay -/

/-
**Lorentzian signature implies control-style energy decay.**

If A has gapped signature with gap c > 0, then the energy decay functional
satisfies energyDecay(v) ≤ -c · positiveNorm(v) for all v.

**Cross-domain significance:**
- Control theory: analogous to a Lyapunov stability margin for LTI systems.
- Optimization: guarantees strong concavity of the Lagrangian on tangent spaces.
- Physics: controls energy dissipation rate in the orthogonal complement.
-/
theorem lorentzian_signature_implies_energy_decay
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ}
    {c : ℝ} (hc : 0 < c)
    (hgap : HasGappedSignature A c) :
    ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
      energyDecayFunctional A w v ≤ -c * positiveNormFunctional w v := by
  obtain ⟨ w, hw ⟩ := hgap;
  use w;
  intro v; unfold energyDecayFunctional positiveNormFunctional; by_cases h : ∑ i, w i * v i = 0 <;> simp_all +decide ;

/-- **Robustness of energy decay under perturbation.**

Energy decay with rate c survives perturbation of bound δ < c,
giving residual rate c - δ. Lyapunov-style stability margins degrade gracefully. -/
theorem energy_decay_robust_under_perturbation
    {n : ℕ} {A E : Matrix (Fin n) (Fin n) ℝ}
    {c δ : ℝ} (hc : 0 < c) (hδ : δ < c)
    (hgap : HasGappedSignature A c)
    (hbound : QuadFormBound E δ) :
    ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
      energyDecayFunctional (A + E) w v ≤ -(c - δ) * positiveNormFunctional w v := by
  have hresid := gapped_signature_residual A E hgap hbound hδ
  exact lorentzian_signature_implies_energy_decay (by linarith) hresid

/-! ## Certified Recognition Algorithm -/

/-- Certified Lorentzian recognition: compare gap to error. -/
def certifyLorentzian (gap err : ℝ) : CertifiedDecision :=
  if err < gap then CertifiedDecision.yes
  else if err < -gap then CertifiedDecision.no
  else CertifiedDecision.unknown

/-- **Algorithm soundness (yes case).** -/
theorem certifyLorentzian_sound_yes
    {n : ℕ} {ι : Type*}
    (B : FPBox ι)
    (toMatrix : (ι → ℝ) → Matrix (Fin n) (Fin n) ℝ)
    (gap err : ℝ)
    (hgap_pos : 0 < gap)
    (hcenter_gap : HasGappedSignature (toMatrix B.center) gap)
    (hpert : ∀ a, B.mem a →
      QuadFormBound (toMatrix a - toMatrix B.center) err)
    (hcert : certifyLorentzian gap err = CertifiedDecision.yes) :
    RobustLorentzianOnBox B toMatrix := by
  have herr : err < gap := by
    unfold certifyLorentzian at hcert
    split_ifs at hcert with h <;> simp_all
  exact certify_lorentzian_of_margin_dominates B toMatrix gap err hgap_pos herr
    hcenter_gap hpert

/-- **Algorithm soundness (no case).** -/
theorem certifyLorentzian_sound_no
    {n : ℕ} {ι : Type*}
    (B : FPBox ι)
    (toMatrix : (ι → ℝ) → Matrix (Fin n) (Fin n) ℝ)
    (obs err : ℝ)
    (hobs_pos : 0 < obs)
    (hcenter_obs : HasObstruction (toMatrix B.center) obs)
    (hpert : ∀ a, B.mem a →
      QuadFormBound (toMatrix a - toMatrix B.center) err)
    (hcert : certifyLorentzian (-obs) err = CertifiedDecision.no) :
    RobustNonLorentzianOnBox B toMatrix := by
  have herr : err < obs := by
    unfold certifyLorentzian at hcert
    split_ifs at hcert with h1 h2 <;> simp_all <;> linarith
  exact certify_nonlorentzian_of_obstruction_dominates B toMatrix obs err hobs_pos herr
    hcenter_obs hpert

/-! ## Uniform Leaf Stability Application -/

/-- The canonical leaf Hessian for the uniform matroid: J - I. -/
def leafHessian (m : ℕ) : Matrix (Fin m) (Fin m) ℝ :=
  fun i j => if i = j then 0 else 1

/-
Quadratic form of the leaf Hessian decomposes as (∑ vᵢ)² - ‖v‖².
-/
theorem leafHessian_quadform (m : ℕ) (v : Fin m → ℝ) :
    QuadForm (leafHessian m) v = (∑ i, v i) ^ 2 - sqNorm v := by
  -- Expand the definition of QuadForm.
  simp [QuadForm, leafHessian];
  simp +decide [ Finset.sum_ite, Finset.filter_ne, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, sqNorm ] ; ring;
  simpa only [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sq ] using by ring;

/-
The leaf Hessian has gapped Lorentzian signature with gap 1.
-/
theorem leafHessian_gapped (m : ℕ) :
    HasGappedSignature (leafHessian m) 1 := by
  use fun _ => 1;
  intro v hv; rw [ leafHessian_quadform ] ; simp_all +decide [ Finset.sum_ite, Finset.filter_ne' ] ;

/-- **Certified stability of uniform matroid Lorentzianity.**

For the uniform matroid, the leaf Hessian has gap 1, so any entry-wise
perturbation bounded by 1/n² preserves Lorentzian signature. -/
theorem uniform_matroid_certified_stability
    {m : ℕ} (E : Matrix (Fin m) (Fin m) ℝ) {δ : ℝ}
    (hδ : 0 ≤ δ) (hentry : ∀ i j, |E i j| ≤ δ)
    (hsmall : (m : ℝ) ^ 2 * δ < 1) :
    HasLorentzianSignature (leafHessian m + E) := by
  apply hasLorentzianSignature_of_gapped _ (by linarith : 0 ≤ 1 - (m : ℝ) ^ 2 * δ)
  exact spectralMargin_entrywise_perturbation (leafHessian_gapped m) hentry hδ hsmall

end CertifiedLorentzian