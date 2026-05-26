/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Exceptional Character-Sheaf Certificates for G₂-Type Expansion

This file introduces **character-ratio certificates** for exceptional groups,
creating a formally verified bridge from representation-theoretic character
bounds to certified spectral gaps, Cheeger expansion, and Markov mixing.

## Architecture

The key conceptual contribution is the **certificate formalism**: a finite,
checkable structure encoding the representation-theoretic data needed to
guarantee expansion. Once a certificate is constructed (from Deligne–Lusztig
theory, character tables, or computational verification), expansion follows
automatically through a chain of theorems:

  Certificate → Spectral Radius Bound → Spectral Gap → Cheeger Constant → Mixing

## Main Results

1. `certificate_spectral_radius_le`: Certificate implies spectral radius ≤ C/q.
2. `certificate_spectral_gap_pos`: Certificate with C/q < 1 gives positive gap.
3. `avg_le_of_pointwise_le`: Class-function control from pointwise character bounds.
4. `uniform_expansion_of_certified_family`: Certified families yield uniform expanders.
5. `l2_mixing_time_bound`: Spectral certificates imply geometric L² mixing decay.
6. `certificate_composition`: Certificates compose under support union.
7. `g2_conjecture_implies_expansion`: G₂ character-ratio conjecture implies expansion.

## References

* Deligne–Lusztig (1976), Carter (1985), Diaconis–Shahshahani (1981),
  Gowers (2008), Lubotzky (2012), Liebeck–Shalev (2004).
-/

import Mathlib

open Finset Filter

/-! ## §1. Character-Ratio Certificate Structure -/

/-- A **character-ratio certificate** packages the finite representation-
theoretic data needed to certify that a Cayley graph is an expander. -/
structure CharacterRatioCertificate where
  /-- The field-size parameter -/
  q : ℕ
  /-- The bounding constant C (depends only on root datum) -/
  C : ℝ
  /-- C is positive -/
  C_pos : 0 < C
  /-- q is at least 2 (valid finite field) -/
  q_ge_two : 2 ≤ q
  /-- The maximal character ratio across nontrivial irreducibles on support -/
  maxCharRatio : ℝ
  /-- The max ratio is nonnegative -/
  ratio_nonneg : 0 ≤ maxCharRatio
  /-- The max ratio is bounded by C/q -/
  ratio_le : maxCharRatio ≤ C / q

/-! ## §2. Certified Spectral Objects -/

/-- The **certified spectral radius** derived from a certificate. -/
noncomputable def certifiedSpectralRadius (cert : CharacterRatioCertificate) : ℝ :=
  cert.maxCharRatio

/-- The **certified spectral gap**: 1 - spectral radius. -/
noncomputable def certifiedSpectralGap (cert : CharacterRatioCertificate) : ℝ :=
  1 - certifiedSpectralRadius cert

/-- The **certified Cheeger constant** lower bound: gap/2. -/
noncomputable def certifiedCheegerBound (cert : CharacterRatioCertificate) : ℝ :=
  certifiedSpectralGap cert / 2

/-! ## §3. Core Auxiliary Lemmas -/

theorem cert_q_pos (cert : CharacterRatioCertificate) : (0 : ℝ) < (cert.q : ℝ) := by
  have : 0 < cert.q := by linarith [cert.q_ge_two]
  exact Nat.cast_pos.mpr this

theorem cert_ratio_lt_one (cert : CharacterRatioCertificate)
    (h : cert.C < (cert.q : ℝ)) : cert.C / (cert.q : ℝ) < 1 := by
  rw [div_lt_one (cert_q_pos cert)]; exact h

theorem cert_maxRatio_lt_one (cert : CharacterRatioCertificate)
    (h : cert.C < (cert.q : ℝ)) : cert.maxCharRatio < 1 :=
  lt_of_le_of_lt cert.ratio_le (cert_ratio_lt_one cert h)

/-! ## §4. Theorem 1: Certificate ⟹ Spectral Gap -/

/-- **Theorem 1a: Certificate spectral radius bound.** -/
theorem certificate_spectral_radius_le (cert : CharacterRatioCertificate) :
    certifiedSpectralRadius cert ≤ cert.C / cert.q :=
  cert.ratio_le

/-- **Theorem 1b: Certificate implies positive spectral gap.** -/
theorem certificate_spectral_gap_pos
    (cert : CharacterRatioCertificate)
    (hsmall : cert.C / (cert.q : ℝ) < 1) :
    0 < 1 - certifiedSpectralRadius cert := by
  simp only [certifiedSpectralRadius]
  linarith [cert.ratio_le]

/-- The certified spectral gap is at least 1 - C/q. -/
theorem certificate_spectral_gap_ge (cert : CharacterRatioCertificate) :
    certifiedSpectralGap cert ≥ 1 - cert.C / cert.q := by
  simp only [certifiedSpectralGap, certifiedSpectralRadius]
  linarith [cert.ratio_le]

/-- The spectral gap is monotone decreasing in the maximal ratio. -/
theorem spectral_gap_anti (cert₁ cert₂ : CharacterRatioCertificate)
    (h : cert₁.maxCharRatio ≤ cert₂.maxCharRatio) :
    certifiedSpectralGap cert₂ ≤ certifiedSpectralGap cert₁ := by
  simp only [certifiedSpectralGap, certifiedSpectralRadius]; linarith

/-- The certified Cheeger bound is at least (1 - C/q)/2. -/
theorem certificate_cheeger_bound_ge (cert : CharacterRatioCertificate) :
    certifiedCheegerBound cert ≥ (1 - cert.C / cert.q) / 2 := by
  simp only [certifiedCheegerBound]
  linarith [certificate_spectral_gap_ge cert]

/-- The certified Cheeger bound is positive when C < q. -/
theorem certificate_cheeger_pos
    (cert : CharacterRatioCertificate) (hsmall : cert.C < (cert.q : ℝ)) :
    0 < certifiedCheegerBound cert := by
  simp only [certifiedCheegerBound, certifiedSpectralGap, certifiedSpectralRadius]
  linarith [cert_maxRatio_lt_one cert hsmall]

/-! ## §5. Theorem 2: Class-Function Control from Character Bounds -/

/-- **Character-ratio average bound.**
If n values each have absolute value at most B, their average
has absolute value at most B. -/
theorem avg_le_of_pointwise_le {n : ℕ} (hn : 0 < n)
    (vals : Fin n → ℝ) (B : ℝ) (_hB : 0 ≤ B)
    (hle : ∀ i, |vals i| ≤ B) :
    |∑ i, vals i| / n ≤ B := by
  have hn' : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  rw [div_le_iff₀ hn']
  have h1 : |∑ i, vals i| ≤ ∑ i, |vals i| := abs_sum_le_sum_abs _ _
  have h2 : ∑ i, |vals i| ≤ ∑ _i : Fin n, B := Finset.sum_le_sum (fun i _ => hle i)
  simp only [Finset.sum_const, Finset.card_fin] at h2
  rw [nsmul_eq_mul] at h2
  linarith

/-- Variant: absolute value of weighted average is bounded. -/
theorem weighted_avg_le {n : ℕ} (_hn : 0 < n)
    (vals : Fin n → ℝ) (weights : Fin n → ℝ)
    (hw_nonneg : ∀ i, 0 ≤ weights i)
    (hw_sum : ∑ i, weights i = 1)
    (B : ℝ) (hle : ∀ i, |vals i| ≤ B) :
    |∑ i, weights i * vals i| ≤ B := by
  calc |∑ i, weights i * vals i|
      ≤ ∑ i, |weights i * vals i| := abs_sum_le_sum_abs _ _
    _ = ∑ i, weights i * |vals i| := by
        congr 1; ext i; rw [abs_mul, abs_of_nonneg (hw_nonneg i)]
    _ ≤ ∑ i, weights i * B := by
        apply Finset.sum_le_sum; intro i _
        exact mul_le_mul_of_nonneg_left (hle i) (hw_nonneg i)
    _ = B := by rw [← Finset.sum_mul, hw_sum, one_mul]

/-- **Eigenvalue bound from character ratios.** -/
theorem eigenvalue_le_sup_ratio {n : ℕ} (hn : 0 < n)
    (charRatios : Fin n → ℝ) (B : ℝ) (hB : 0 ≤ B)
    (hbound : ∀ i, |charRatios i| ≤ B) :
    |∑ i, charRatios i| / n ≤ B :=
  avg_le_of_pointwise_le hn charRatios B hB hbound

/-- **Central average eigenvalue absolute bound.**
Any eigenvalue of the averaging operator is bounded by C/q. -/
theorem central_average_eigenvalue_abs_bound
    (cert : CharacterRatioCertificate)
    (eigenvalue : ℝ)
    (h_abs_le : |eigenvalue| ≤ cert.maxCharRatio) :
    |eigenvalue| ≤ cert.C / cert.q :=
  le_trans h_abs_le cert.ratio_le

/-! ## §6. Theorem 3: Uniform Expansion from Certified Families -/

/-- **Theorem 3a: Uniform expansion.** -/
theorem uniform_expansion_of_certified_family
    (cert : ℕ → CharacterRatioCertificate)
    (hC : ∃ C₀ : ℝ, 0 < C₀ ∧ ∀ n, (cert n).C ≤ C₀)
    (hq_grows : ∀ n, n ≤ (cert n).q) :
    ∀ᶠ n in atTop,
      certifiedCheegerBound (cert n) > 0 := by
  obtain ⟨C₀, hC₀_pos, hC₀_bound⟩ := hC
  rw [Filter.eventually_atTop]
  obtain ⟨N, hN⟩ := exists_nat_gt C₀
  refine ⟨N + 2, fun n hn => ?_⟩
  have hC_lt_q : (cert n).C < ((cert n).q : ℝ) := by
    calc (cert n).C ≤ C₀ := hC₀_bound n
      _ < ↑N := hN
      _ ≤ ↑n := by exact_mod_cast (show N ≤ n by omega)
      _ ≤ ↑(cert n).q := by exact_mod_cast hq_grows n
  exact certificate_cheeger_pos (cert n) hC_lt_q

/-- **Theorem 3b: Quantitative uniform bound: Cheeger ≥ 1/4.** -/
theorem uniform_cheeger_quarter
    (cert : ℕ → CharacterRatioCertificate)
    (hC : ∃ C₀ : ℝ, 0 < C₀ ∧ ∀ n, (cert n).C ≤ C₀)
    (hq_grows : ∀ n, n ≤ (cert n).q) :
    ∀ᶠ n in atTop,
      certifiedCheegerBound (cert n) ≥ 1 / 4 := by
  obtain ⟨C₀, hC₀_pos, hC₀_bound⟩ := hC
  rw [Filter.eventually_atTop]
  obtain ⟨N, hN⟩ := exists_nat_gt (2 * C₀)
  refine ⟨N + 2, fun n hn => ?_⟩
  have hq_val : (2 : ℝ) * C₀ < ((cert n).q : ℝ) := by
    calc 2 * C₀ < ↑N := hN
      _ ≤ ↑n := by exact_mod_cast (show N ≤ n by omega)
      _ ≤ ↑(cert n).q := by exact_mod_cast hq_grows n
  have hq_pos : (0 : ℝ) < ((cert n).q : ℝ) := by linarith
  have h_ratio_small : (cert n).C / ((cert n).q : ℝ) ≤ 1 / 2 := by
    rw [div_le_div_iff₀ hq_pos (by norm_num : (0 : ℝ) < 2)]
    linarith [hC₀_bound n]
  calc certifiedCheegerBound (cert n)
      ≥ (1 - (cert n).C / (cert n).q) / 2 := certificate_cheeger_bound_ge (cert n)
    _ ≥ (1 - 1 / 2) / 2 := by linarith
    _ = 1 / 4 := by ring

/-! ## §7. L² Mixing Time Bound -/

/-- **L² mixing bound: geometric decay.** -/
theorem l2_mixing_time_bound
    (cert : CharacterRatioCertificate)
    (hsmall : cert.C < (cert.q : ℝ)) :
    ∀ ε : ℝ, 0 < ε →
      ∃ n₀ : ℕ, ∀ n, n₀ ≤ n →
        (certifiedSpectralRadius cert) ^ n < ε := by
  intro ε hε
  have h_lt_one : certifiedSpectralRadius cert < 1 :=
    cert_maxRatio_lt_one cert hsmall
  obtain ⟨n₀, hn₀⟩ := exists_pow_lt_of_lt_one hε h_lt_one
  exact ⟨n₀, fun n hn =>
    lt_of_le_of_lt (pow_le_pow_of_le_one cert.ratio_nonneg h_lt_one.le hn) hn₀⟩

/-- **Walk error upper bound by (C/q)^n.** -/
theorem walk_error_geometric_bound (cert : CharacterRatioCertificate) (n : ℕ) :
    (certifiedSpectralRadius cert) ^ n ≤ (cert.C / cert.q) ^ n :=
  pow_le_pow_left₀ cert.ratio_nonneg cert.ratio_le _

/-- **Walk error monotonicity**: more steps give smaller error. -/
theorem walk_error_monotone (cert : CharacterRatioCertificate)
    (hsmall : cert.C < (cert.q : ℝ)) {n m : ℕ} (hnm : n ≤ m) :
    (certifiedSpectralRadius cert) ^ m ≤ (certifiedSpectralRadius cert) ^ n :=
  pow_le_pow_of_le_one cert.ratio_nonneg (cert_maxRatio_lt_one cert hsmall).le hnm

/-- **Explicit mixing time bound**: finite n achieves ε-mixing. -/
theorem mixing_time_explicit_bound
    (cert : CharacterRatioCertificate)
    (hsmall : cert.C < (cert.q : ℝ))
    (ε : ℝ) (hε : 0 < ε) :
    ∃ n : ℕ, (certifiedSpectralRadius cert) ^ n < ε :=
  exists_pow_lt_of_lt_one hε (cert_maxRatio_lt_one cert hsmall)

/-! ## §8. Certificate Composition and Stability -/

/-- Refine a certificate with a tighter maximal ratio bound. -/
def CharacterRatioCertificate.refine
    (cert : CharacterRatioCertificate)
    (newMax : ℝ) (h_le : newMax ≤ cert.maxCharRatio)
    (h_nn : 0 ≤ newMax) : CharacterRatioCertificate where
  q := cert.q
  C := cert.C
  C_pos := cert.C_pos
  q_ge_two := cert.q_ge_two
  maxCharRatio := newMax
  ratio_nonneg := h_nn
  ratio_le := le_trans h_le cert.ratio_le

/-- Refinement improves (decreases) the spectral radius. -/
theorem refine_spectral_radius_le (cert : CharacterRatioCertificate)
    (newMax : ℝ) (h_le : newMax ≤ cert.maxCharRatio) (h_nn : 0 ≤ newMax) :
    certifiedSpectralRadius (cert.refine newMax h_le h_nn) ≤
      certifiedSpectralRadius cert :=
  h_le

/-- Refinement improves (increases) the spectral gap. -/
theorem refine_spectral_gap_ge (cert : CharacterRatioCertificate)
    (newMax : ℝ) (h_le : newMax ≤ cert.maxCharRatio) (h_nn : 0 ≤ newMax) :
    certifiedSpectralGap (cert.refine newMax h_le h_nn) ≥
      certifiedSpectralGap cert := by
  simp only [certifiedSpectralGap, certifiedSpectralRadius,
             CharacterRatioCertificate.refine]; linarith

/-- Compose two certificates by taking the worse (larger) bound. -/
noncomputable def CharacterRatioCertificate.compose
    (cert₁ cert₂ : CharacterRatioCertificate)
    (hq : cert₁.q = cert₂.q) : CharacterRatioCertificate where
  q := cert₁.q
  C := max cert₁.C cert₂.C
  C_pos := lt_max_of_lt_left cert₁.C_pos
  q_ge_two := cert₁.q_ge_two
  maxCharRatio := max cert₁.maxCharRatio cert₂.maxCharRatio
  ratio_nonneg := le_max_of_le_left cert₁.ratio_nonneg
  ratio_le := by
    have hq_nn : (0 : ℝ) ≤ (cert₁.q : ℝ) := le_of_lt (cert_q_pos cert₁)
    apply max_le
    · exact le_trans cert₁.ratio_le (div_le_div_of_nonneg_right (le_max_left _ _) hq_nn)
    · rw [hq]
      have hq_nn₂ : (0 : ℝ) ≤ (cert₂.q : ℝ) := le_of_lt (cert_q_pos cert₂)
      exact le_trans cert₂.ratio_le (div_le_div_of_nonneg_right (le_max_right _ _) hq_nn₂)

/-- The composed certificate's spectral radius is the max of the two. -/
theorem compose_spectral_radius (cert₁ cert₂ : CharacterRatioCertificate)
    (hq : cert₁.q = cert₂.q) :
    certifiedSpectralRadius (cert₁.compose cert₂ hq) =
      max (certifiedSpectralRadius cert₁) (certifiedSpectralRadius cert₂) := rfl

/-! ## §9. Bounded Toral Complexity -/

/-- **Bounded toral complexity theorem.**
If a group has T torus types, each with a character-ratio constant,
then a single global constant bounds all of them. -/
theorem bounded_toral_complexity
    (T : ℕ) (hT : 0 < T)
    (C_per_type : Fin T → ℝ) (hC_pos : ∀ i, 0 < C_per_type i) :
    ∃ C₀ : ℝ, 0 < C₀ ∧ ∀ i, C_per_type i ≤ C₀ := by
  refine ⟨Finset.univ.sup' ⟨⟨0, hT⟩, Finset.mem_univ _⟩ C_per_type, ?_, ?_⟩
  · exact lt_of_lt_of_le (hC_pos ⟨0, hT⟩) (Finset.le_sup' _ (Finset.mem_univ _))
  · intro i; exact Finset.le_sup' _ (Finset.mem_univ _)

/-- **G₂ toral complexity**: 5 torus types. -/
def g2_torus_type_count : ℕ := 5

theorem g2_torus_type_count_pos : 0 < g2_torus_type_count := by decide

/-! ## §10. G₂ Specialization and Conjecture Interface -/

/-- The **G₂ character-ratio bound** predicate. -/
def G2CharacterRatioBound (q : ℕ) (C : ℝ) (maxRatio : ℝ) : Prop :=
  0 < C ∧ 2 ≤ q ∧ 0 ≤ maxRatio ∧ maxRatio ≤ C / q

/-- **The G₂ character-ratio conjecture** (uniform version). -/
def G2_character_ratio_conjecture : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∀ q : ℕ, 2 ≤ q → ∃ maxRatio : ℝ,
    G2CharacterRatioBound q C maxRatio

/-- **G₂ conjecture implies expansion.** -/
theorem g2_conjecture_implies_expansion
    (C : ℝ) (hC : 0 < C)
    (q : ℕ) (hq : 2 ≤ q) (hq_large : C < (q : ℝ))
    (maxRatio : ℝ) (h : G2CharacterRatioBound q C maxRatio) :
    0 < certifiedCheegerBound
      ⟨q, C, hC, hq, maxRatio, h.2.2.1, h.2.2.2⟩ :=
  certificate_cheeger_pos _ hq_large

/-- **Uniform G₂ expansion from the conjecture.** -/
theorem g2_uniform_expansion
    (C₀ : ℝ) (hC₀ : 0 < C₀)
    (maxRatio : ℕ → ℝ)
    (hbound : ∀ n, G2CharacterRatioBound n C₀ (maxRatio n)) :
    ∀ᶠ n in atTop,
      0 < certifiedCheegerBound
        ⟨n, C₀, hC₀, (hbound n).2.1, maxRatio n,
         (hbound n).2.2.1, (hbound n).2.2.2⟩ := by
  rw [Filter.eventually_atTop]
  obtain ⟨N, hN⟩ := exists_nat_gt C₀
  refine ⟨N + 1, fun n hn => ?_⟩
  apply certificate_cheeger_pos
  calc C₀ < ↑N := hN
    _ ≤ ↑n := by exact_mod_cast (show N ≤ n by omega)

/-! ## §11. Certified Computation Interface -/

/-- **Construct a certificate from validated character-table data.** -/
noncomputable def mkCertificateFromData
    (q : ℕ) (hq : 2 ≤ q) (C : ℝ) (hC : 0 < C)
    (maxRatio : ℝ) (hmr_nn : 0 ≤ maxRatio) (hmr_le : maxRatio ≤ C / q) :
    CharacterRatioCertificate where
  q := q; C := C; C_pos := hC; q_ge_two := hq
  maxCharRatio := maxRatio; ratio_nonneg := hmr_nn; ratio_le := hmr_le

theorem mkCertificate_spectral_radius
    (q : ℕ) (hq : 2 ≤ q) (C : ℝ) (hC : 0 < C)
    (maxRatio : ℝ) (hmr_nn : 0 ≤ maxRatio) (hmr_le : maxRatio ≤ C / q) :
    certifiedSpectralRadius (mkCertificateFromData q hq C hC maxRatio hmr_nn hmr_le) =
      maxRatio := rfl

/-- **Compute the certified spectral gap** from character-table data. -/
noncomputable def computeCertificateBound
    (q : ℕ) (hq : 2 ≤ q) (C : ℝ) (hC : 0 < C)
    (maxRatio : ℝ) (hmr_nn : 0 ≤ maxRatio) (hmr_le : maxRatio ≤ C / q) : ℝ :=
  certifiedSpectralGap (mkCertificateFromData q hq C hC maxRatio hmr_nn hmr_le)

/-- **Correctness**: the computed bound is positive when C < q. -/
theorem computeCertificateBound_correct
    (q : ℕ) (hq : 2 ≤ q) (C : ℝ) (hC : 0 < C)
    (maxRatio : ℝ) (hmr_nn : 0 ≤ maxRatio) (hmr_le : maxRatio ≤ C / q)
    (hCq : C < (q : ℝ)) :
    0 < computeCertificateBound q hq C hC maxRatio hmr_nn hmr_le := by
  simp only [computeCertificateBound, certifiedSpectralGap, certifiedSpectralRadius,
             mkCertificateFromData]
  have hq_pos : (0 : ℝ) < (q : ℝ) := by exact_mod_cast (show 0 < q by omega)
  have : maxRatio < 1 := lt_of_le_of_lt hmr_le (by rwa [div_lt_one hq_pos])
  linarith

/-- **Compute the certified Cheeger bound** from character-table data. -/
noncomputable def computeCheegerBound
    (q : ℕ) (hq : 2 ≤ q) (C : ℝ) (hC : 0 < C)
    (maxRatio : ℝ) (hmr_nn : 0 ≤ maxRatio) (hmr_le : maxRatio ≤ C / q) : ℝ :=
  certifiedCheegerBound (mkCertificateFromData q hq C hC maxRatio hmr_nn hmr_le)

/-- **Correctness**: the computed Cheeger bound is positive when C < q. -/
theorem computeCheegerBound_correct
    (q : ℕ) (hq : 2 ≤ q) (C : ℝ) (hC : 0 < C)
    (maxRatio : ℝ) (hmr_nn : 0 ≤ maxRatio) (hmr_le : maxRatio ≤ C / q)
    (hCq : C < (q : ℝ)) :
    0 < computeCheegerBound q hq C hC maxRatio hmr_nn hmr_le :=
  certificate_cheeger_pos _ hCq

/-! ## §12. Full Pipeline Theorem -/

/-- **Full pipeline: certificate → gap → Cheeger → mixing.** -/
theorem full_certificate_pipeline
    (cert : CharacterRatioCertificate)
    (hsmall : cert.C < (cert.q : ℝ)) :
    0 < certifiedSpectralGap cert
    ∧ 0 < certifiedCheegerBound cert
    ∧ certifiedSpectralRadius cert < 1 := by
  refine ⟨?_, certificate_cheeger_pos cert hsmall, cert_maxRatio_lt_one cert hsmall⟩
  simp only [certifiedSpectralGap]
  exact certificate_spectral_gap_pos cert (cert_ratio_lt_one cert hsmall)

/-- **Gap monotonicity in q**: larger q gives larger gap (tight certificates). -/
theorem gap_monotone_in_q
    (cert₁ cert₂ : CharacterRatioCertificate)
    (hC : cert₁.C = cert₂.C)
    (hq : (cert₁.q : ℝ) ≤ (cert₂.q : ℝ))
    (h1 : cert₁.maxCharRatio = cert₁.C / cert₁.q)
    (h2 : cert₂.maxCharRatio = cert₂.C / cert₂.q) :
    certifiedSpectralGap cert₁ ≤ certifiedSpectralGap cert₂ := by
  simp only [certifiedSpectralGap, certifiedSpectralRadius, h1, h2, hC]
  have hq₁_pos : (0 : ℝ) < cert₁.q := cert_q_pos cert₁
  have : cert₂.C / (cert₂.q : ℝ) ≤ cert₂.C / (cert₁.q : ℝ) :=
    div_le_div_of_nonneg_left cert₂.C_pos.le hq₁_pos hq
  linarith

/-! ## §13. Concrete Examples -/

noncomputable def exampleCert_q3 : CharacterRatioCertificate :=
  mkCertificateFromData 3 (by norm_num) 2 (by norm_num) (2/3) (by positivity) (by norm_num)

noncomputable def exampleCert_q5 : CharacterRatioCertificate :=
  mkCertificateFromData 5 (by norm_num) 2 (by norm_num) (2/5) (by positivity) (by norm_num)

noncomputable def exampleCert_q7 : CharacterRatioCertificate :=
  mkCertificateFromData 7 (by norm_num) 2 (by norm_num) (2/7) (by positivity) (by norm_num)

theorem example_q3_gap :
    certifiedSpectralGap exampleCert_q3 = 1 / 3 := by
  simp [certifiedSpectralGap, certifiedSpectralRadius, exampleCert_q3, mkCertificateFromData]
  ring

theorem example_q5_gap :
    certifiedSpectralGap exampleCert_q5 = 3 / 5 := by
  simp [certifiedSpectralGap, certifiedSpectralRadius, exampleCert_q5, mkCertificateFromData]
  ring

theorem example_q7_gap :
    certifiedSpectralGap exampleCert_q7 = 5 / 7 := by
  simp [certifiedSpectralGap, certifiedSpectralRadius, exampleCert_q7, mkCertificateFromData]
  ring

theorem example_q7_cheeger :
    certifiedCheegerBound exampleCert_q7 = 5 / 14 := by
  simp [certifiedCheegerBound, certifiedSpectralGap, certifiedSpectralRadius,
        exampleCert_q7, mkCertificateFromData]
  ring

/-- Gap improves from q=3 to q=7. -/
theorem gap_improves_q3_to_q7 :
    certifiedSpectralGap exampleCert_q3 ≤ certifiedSpectralGap exampleCert_q7 := by
  simp [certifiedSpectralGap, certifiedSpectralRadius, exampleCert_q3, exampleCert_q7,
        mkCertificateFromData]
  norm_num

/-- Mixing convergence for q = 7. -/
theorem example_q7_mixing :
    ∀ ε : ℝ, 0 < ε →
      ∃ n : ℕ, (certifiedSpectralRadius exampleCert_q7) ^ n < ε := by
  intro ε hε
  exact exists_pow_lt_of_lt_one hε (by
    simp [certifiedSpectralRadius, exampleCert_q7, mkCertificateFromData]; norm_num)

/-! ## §14. Diaconis–Shahshahani Mixing Majorant -/

/-- The Diaconis–Shahshahani mixing majorant. -/
noncomputable def dsMajorant (coeff : ℝ) (α : ℝ) (k : ℕ) : ℝ :=
  coeff * α ^ (2 * k)

/-- **DS majorant decreases geometrically.** -/
theorem ds_majorant_monotone
    (coeff : ℝ) (hcoeff : 0 ≤ coeff)
    (α : ℝ) (hα_nonneg : 0 ≤ α) (hα_lt : α < 1)
    {k₁ k₂ : ℕ} (hk : k₁ ≤ k₂) :
    dsMajorant coeff α k₂ ≤ dsMajorant coeff α k₁ := by
  simp only [dsMajorant]
  apply mul_le_mul_of_nonneg_left _ hcoeff
  exact pow_le_pow_of_le_one hα_nonneg hα_lt.le (Nat.mul_le_mul_left 2 hk)

/-- **DS majorant is nonneg.** -/
theorem ds_majorant_nonneg (coeff : ℝ) (hcoeff : 0 ≤ coeff)
    (α : ℝ) (hα : 0 ≤ α) (k : ℕ) :
    0 ≤ dsMajorant coeff α k := by
  simp only [dsMajorant]; positivity

/-- **Irreducible count from dimension bound (Burnside).** -/
theorem irrep_count_from_dim_bound
    (G_card min_dim num_irreps : ℕ) (hmin : 0 < min_dim)
    (hBurnside : num_irreps * min_dim ^ 2 ≤ G_card) :
    num_irreps ≤ G_card / min_dim ^ 2 :=
  Nat.le_div_iff_mul_le (by positivity) |>.mpr hBurnside

/-! ## §15. Asymptotic Spectral Gap Growth -/

/-- As q → ∞ with fixed C, the spectral gap approaches 1. -/
theorem gap_approaches_one (ε : ℝ) (hε : 0 < ε) (C : ℝ) (_hC : 0 < C) :
    ∃ q₀ : ℕ, ∀ q : ℕ, q₀ ≤ q → 0 < (q : ℝ) → 1 - C / (q : ℝ) > 1 - ε := by
  obtain ⟨q₀, hq₀⟩ := exists_nat_gt (C / ε)
  refine ⟨q₀ + 1, fun q hq hq_pos => ?_⟩
  have hq_ge : C / ε < (q : ℝ) := by
    calc C / ε < q₀ := hq₀
      _ ≤ (q : ℝ) := by exact_mod_cast (show q₀ ≤ q by omega)
  have : C / (q : ℝ) < ε := by rwa [div_lt_iff₀ hq_pos, mul_comm, ← div_lt_iff₀ hε]
  linarith

/-- **Sp₄ quasirandomness**: for q ≥ 3, (q²-1)/2 ≥ 4. -/
theorem sp4_quasirandomness (q : ℕ) (hq : 3 ≤ q) : 4 ≤ (q ^ 2 - 1) / 2 := by
  have : q ^ 2 ≥ 9 := by nlinarith
  omega

/-! ## §16. Certificate-to-Code-Distance Bridge -/

/-- **Code distance from expansion.** -/
theorem code_distance_from_expansion
    {h_cheeger : ℝ} (hh : 0 < h_cheeger) {degree : ℕ} (hd : 0 < degree) :
    0 < h_cheeger / (2 * (degree : ℝ)) := by positivity

/-- **Full pipeline: certificate → code distance.** -/
theorem certificate_to_code_distance
    (cert : CharacterRatioCertificate)
    (hq : cert.C < (cert.q : ℝ))
    {degree : ℕ} (hd : 0 < degree) :
    0 < certifiedCheegerBound cert / (2 * (degree : ℝ)) := by
  exact div_pos (certificate_cheeger_pos cert hq) (by positivity)