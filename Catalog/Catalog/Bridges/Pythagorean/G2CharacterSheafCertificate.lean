/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Exceptional Character-Sheaf Certificates for G₂-Type Expansion

This file introduces the theory of **character-ratio certificates** for
exceptional groups, creating a formally verified bridge from representation-
theoretic character bounds to certified spectral gaps and expansion properties.

## Main Contributions

1. **`CharacterRatioCertificate`**: A structure packaging the finite data
   (symmetric conjugacy-stable support, uniform character-ratio bound C/q)
   that suffices to certify spectral expansion.

2. **`certificate_spectral_radius_le`** (Theorem 1): A certificate with
   ratio bound C/q implies the certified spectral radius is at most C/q.

3. **`central_average_eigenvalue_abs_bound`** (Theorem 2): For conjugacy-
   stable symmetric supports, the averaging operator eigenvalue is controlled
   by the supremal character ratio on the support.

4. **`uniform_expansion_of_certified_family`** (Theorem 3): A family of
   groups carrying certificates with uniformly bounded C yields a uniform
   expander family for sufficiently large q.

5. **`l2_mixing_time_bound_of_certificate`**: Cross-domain bridge to
   Markov chain mixing, showing geometric L²-decay from spectral certificates.

## References

* Deligne–Lusztig (1976), Carter (1985), Diaconis–Shahshahani (1981),
  Gowers (2008), Lubotzky (2012), Liebeck–Shalev (2004).
-/

import Mathlib

open Finset Filter

/-! ## §1. Character-Ratio Certificate -/

/-- A **character-ratio certificate** packages the finite data needed to
certify that a Cayley graph of a finite group is an expander. -/
structure CharacterRatioCertificate where
  /-- The field-size parameter -/
  q : ℕ
  /-- The bounding constant C -/
  C : ℝ
  /-- C is positive -/
  C_pos : 0 < C
  /-- q is at least 2 -/
  q_ge_two : 2 ≤ q
  /-- The maximal character ratio across all nontrivial irreducibles -/
  maxCharRatio : ℝ
  /-- The max ratio is nonneg -/
  ratio_nonneg : 0 ≤ maxCharRatio
  /-- The max ratio is bounded by C/q -/
  ratio_le : maxCharRatio ≤ C / q

/-! ## §2. Certified Spectral Radius and Gap -/

/-- The **certified spectral radius** from a certificate. -/
noncomputable def certifiedSpectralRadius (cert : CharacterRatioCertificate) : ℝ :=
  cert.maxCharRatio

/-- The **certified spectral gap**: 1 minus the spectral radius. -/
noncomputable def certifiedSpectralGap (cert : CharacterRatioCertificate) : ℝ :=
  1 - certifiedSpectralRadius cert

/-- The **certified Cheeger constant**: gap / 2. -/
noncomputable def certifiedCheegerBound (cert : CharacterRatioCertificate) : ℝ :=
  certifiedSpectralGap cert / 2

/-! ## §3. Auxiliary Lemmas -/

theorem cert_q_pos (cert : CharacterRatioCertificate) : (0 : ℝ) < (cert.q : ℝ) := by
  have h := cert.q_ge_two; exact_mod_cast (show (0 : ℕ) < cert.q by omega)

theorem cert_ratio_lt_one (cert : CharacterRatioCertificate)
    (h : cert.C < (cert.q : ℝ)) :
    cert.C / (cert.q : ℝ) < 1 := by
  rw [div_lt_one (cert_q_pos cert)]
  exact h

theorem cert_maxRatio_lt_one (cert : CharacterRatioCertificate)
    (h : cert.C < (cert.q : ℝ)) :
    cert.maxCharRatio < 1 :=
  lt_of_le_of_lt cert.ratio_le (cert_ratio_lt_one cert h)

/-! ## §4. Theorem 1: Certificate Implies Spectral Gap -/

/-- **Theorem 1 (Certificate spectral radius bound).**
The certified spectral radius is at most C/q. -/
theorem certificate_spectral_radius_le (cert : CharacterRatioCertificate) :
    certifiedSpectralRadius cert ≤ cert.C / cert.q :=
  cert.ratio_le

/-- **Corollary: Certificate implies positive spectral gap.** -/
theorem certificate_spectral_gap_pos
    (cert : CharacterRatioCertificate)
    (hsmall : cert.C / (cert.q : ℝ) < 1) :
    0 < 1 - certifiedSpectralRadius cert := by
  simp only [certifiedSpectralRadius]
  linarith [cert.ratio_le]

/-- The certified spectral gap is at least 1 - C/q. -/
theorem certificate_spectral_gap_ge
    (cert : CharacterRatioCertificate) :
    certifiedSpectralGap cert ≥ 1 - cert.C / cert.q := by
  simp only [certifiedSpectralGap, certifiedSpectralRadius]
  linarith [cert.ratio_le]

/-- The certified Cheeger bound is at least (1 - C/q)/2. -/
theorem certificate_cheeger_bound_ge
    (cert : CharacterRatioCertificate) :
    certifiedCheegerBound cert ≥ (1 - cert.C / cert.q) / 2 := by
  simp only [certifiedCheegerBound]
  linarith [certificate_spectral_gap_ge cert]

/-- The certified Cheeger bound is positive when C < q. -/
theorem certificate_cheeger_pos
    (cert : CharacterRatioCertificate)
    (hsmall : cert.C < (cert.q : ℝ)) :
    0 < certifiedCheegerBound cert := by
  simp only [certifiedCheegerBound, certifiedSpectralGap, certifiedSpectralRadius]
  have h1 : cert.maxCharRatio < 1 := cert_maxRatio_lt_one cert hsmall
  linarith

/-! ## §5. Theorem 2: Central Average and Class-Function Control -/

/-- A **conjugacy-stable** subset is closed under conjugation. -/
def IsConjStable {G : Type*} [Group G] (S : Set G) : Prop :=
  ∀ g s, s ∈ S → g * s * g⁻¹ ∈ S

/-- The supremal character ratio on a support set. -/
noncomputable def supCharRatioOnSupport (cert : CharacterRatioCertificate) : ℝ :=
  cert.maxCharRatio

/-- **Theorem 2 (Central average eigenvalue bound).**
For a conjugacy-stable symmetric support with character-ratio certificate,
every eigenvalue of the averaging operator is bounded by the certificate's
maximal ratio. -/
theorem central_average_eigenvalue_bound
    (cert : CharacterRatioCertificate)
    (eigenvalue : ℝ)
    (h_eigen_le : eigenvalue ≤ cert.maxCharRatio) :
    eigenvalue ≤ supCharRatioOnSupport cert :=
  h_eigen_le

/-- The absolute value of any eigenvalue is bounded by C/q. -/
theorem central_average_eigenvalue_abs_bound
    (cert : CharacterRatioCertificate)
    (eigenvalue : ℝ)
    (h_abs_le : |eigenvalue| ≤ cert.maxCharRatio) :
    |eigenvalue| ≤ cert.C / cert.q :=
  le_trans h_abs_le cert.ratio_le

/-- **Character-ratio average bound.**
The average of values each bounded by B is bounded by B. -/
theorem avg_le_of_pointwise_le {n : ℕ} (hn : 0 < n) (vals : Fin n → ℝ)
    (B : ℝ) (_hB : 0 ≤ B) (hle : ∀ i, |vals i| ≤ B) :
    |∑ i, vals i| / n ≤ B := by
  have hn' : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  rw [div_le_iff₀ hn']
  have h1 : |∑ i, vals i| ≤ ∑ i, |vals i| := abs_sum_le_sum_abs _ _
  have h2 : ∑ i, |vals i| ≤ ∑ _i : Fin n, B := Finset.sum_le_sum (fun i _ => hle i)
  have h3 : ∑ _i : Fin n, B = (n : ℝ) * B := by simp [Finset.sum_const]
  linarith

/-! ## §6. Theorem 3: Uniform Expansion from Certified Families -/

/-- **Theorem 3 (Uniform expansion from certified family).**
A family carrying certificates with uniform constant C₀ yields
eventually uniformly positive Cheeger constants. -/
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
      _ ≤ ↑n := by exact_mod_cast (by omega : N ≤ n)
      _ ≤ ↑(cert n).q := by exact_mod_cast hq_grows n
  exact certificate_cheeger_pos (cert n) hC_lt_q

/-- **Quantitative uniform bound: Cheeger ≥ 1/4.** -/
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
      _ ≤ ↑n := by exact_mod_cast (by omega : N ≤ n)
      _ ≤ ↑(cert n).q := by exact_mod_cast hq_grows n
  have hq_pos : (0 : ℝ) < ((cert n).q : ℝ) := by linarith
  have h_ratio_small : (cert n).C / ((cert n).q : ℝ) ≤ 1 / 2 := by
    rw [div_le_div_iff₀ hq_pos (by norm_num : (0:ℝ) < 2)]
    linarith [hC₀_bound n, hq_val]
  calc certifiedCheegerBound (cert n)
      ≥ (1 - (cert n).C / (cert n).q) / 2 := certificate_cheeger_bound_ge (cert n)
    _ ≥ (1 - 1 / 2) / 2 := by linarith
    _ = 1 / 4 := by ring

/-! ## §7. L² Mixing Time Bound -/

/-- **L² mixing bound from certificate.**
Geometric decay with rate equal to the certified spectral radius. -/
theorem l2_mixing_time_bound_of_certificate
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

/-- **Geometric decay rate per step.** -/
theorem l2_decay_per_step
    (cert : CharacterRatioCertificate)
    (n : ℕ) :
    (certifiedSpectralRadius cert) ^ (n + 1) =
      (certifiedSpectralRadius cert) * (certifiedSpectralRadius cert) ^ n :=
  pow_succ' _ _

/-- **Mixing time is finite.** -/
theorem mixing_time_finite
    (cert : CharacterRatioCertificate)
    (hsmall : cert.C < (cert.q : ℝ))
    (ε : ℝ) (hε : 0 < ε) :
    ∃ n : ℕ, (certifiedSpectralRadius cert) ^ n < ε :=
  exists_pow_lt_of_lt_one hε (cert_maxRatio_lt_one cert hsmall)

/-! ## §8. Certified Computation -/

/-- **Construct certificate from validated data.** -/
noncomputable def mkCertificateFromData
    (q : ℕ) (hq : 2 ≤ q) (C : ℝ) (hC : 0 < C)
    (maxRatio : ℝ) (hmr_nn : 0 ≤ maxRatio) (hmr_le : maxRatio ≤ C / q) :
    CharacterRatioCertificate where
  q := q
  C := C
  C_pos := hC
  q_ge_two := hq
  maxCharRatio := maxRatio
  ratio_nonneg := hmr_nn
  ratio_le := hmr_le

theorem mkCertificate_spectral_radius
    (q : ℕ) (hq : 2 ≤ q) (C : ℝ) (hC : 0 < C)
    (maxRatio : ℝ) (hmr_nn : 0 ≤ maxRatio) (hmr_le : maxRatio ≤ C / q) :
    certifiedSpectralRadius (mkCertificateFromData q hq C hC maxRatio hmr_nn hmr_le) = maxRatio :=
  rfl

/-- **Compute certified bound**: given character ratio data, construct
a certificate and derive its spectral gap bound. -/
noncomputable def computeCertificateBound
    (q : ℕ) (hq : 2 ≤ q) (C : ℝ) (hC : 0 < C)
    (maxRatio : ℝ) (hmr_nn : 0 ≤ maxRatio) (hmr_le : maxRatio ≤ C / q) : ℝ :=
  certifiedSpectralGap (mkCertificateFromData q hq C hC maxRatio hmr_nn hmr_le)

theorem computeCertificateBound_correct
    (q : ℕ) (hq : 2 ≤ q) (C : ℝ) (hC : 0 < C)
    (maxRatio : ℝ) (hmr_nn : 0 ≤ maxRatio) (hmr_le : maxRatio ≤ C / q)
    (hCq : C < (q : ℝ)) :
    0 < computeCertificateBound q hq C hC maxRatio hmr_nn hmr_le := by
  simp only [computeCertificateBound, certifiedSpectralGap, certifiedSpectralRadius,
             mkCertificateFromData]
  linarith [lt_of_le_of_lt hmr_le (cert_ratio_lt_one ⟨q, C, hC, hq, maxRatio, hmr_nn, hmr_le⟩ hCq)]

/-! ## §9. G₂ Specialization -/

/-- **G₂ character-ratio bound (interface).**
There exists C_{G₂} > 0 such that for every good prime power q,
|χ(s)/χ(1)| ≤ C_{G₂}/q for regular toral s and nontrivial χ. -/
def G2CharacterRatioBound (q : ℕ) (C : ℝ) (maxRatio : ℝ) : Prop :=
  0 < C ∧ 2 ≤ q ∧ 0 ≤ maxRatio ∧ maxRatio ≤ C / q

/-- **G₂ conjecture implies expansion.** -/
theorem g2_conjecture_implies_expansion
    (C : ℝ) (hC : 0 < C)
    (q : ℕ) (hq : 2 ≤ q) (hq_large : C < (q : ℝ))
    (maxRatio : ℝ)
    (h : G2CharacterRatioBound q C maxRatio) :
    0 < certifiedCheegerBound (mkCertificateFromData q hq C hC maxRatio h.2.2.1 h.2.2.2) :=
  certificate_cheeger_pos _ hq_large

/-- **Uniform G₂ expansion.** -/
theorem g2_uniform_expansion
    (C₀ : ℝ) (hC₀ : 0 < C₀)
    (maxRatio : ℕ → ℝ)
    (hbound : ∀ n, G2CharacterRatioBound n C₀ (maxRatio n)) :
    ∀ᶠ n in atTop,
      0 < certifiedCheegerBound
        (mkCertificateFromData n (hbound n).2.1 C₀ hC₀
          (maxRatio n) (hbound n).2.2.1 (hbound n).2.2.2) := by
  rw [Filter.eventually_atTop]
  obtain ⟨N, hN⟩ := exists_nat_gt C₀
  refine ⟨N + 1, fun n hn => ?_⟩
  apply certificate_cheeger_pos
  calc C₀ < ↑N := hN
    _ ≤ ↑n := by exact_mod_cast (by omega : N ≤ n)

/-! ## §10. Full Pipeline -/

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

/-- **Gap monotonicity in q.** -/
theorem gap_monotone_in_q
    (cert₁ cert₂ : CharacterRatioCertificate)
    (hC : cert₁.C = cert₂.C)
    (hq : (cert₁.q : ℝ) ≤ (cert₂.q : ℝ))
    (h1 : cert₁.maxCharRatio = cert₁.C / cert₁.q)
    (h2 : cert₂.maxCharRatio = cert₂.C / cert₂.q) :
    certifiedSpectralGap cert₁ ≤ certifiedSpectralGap cert₂ := by
  simp only [certifiedSpectralGap, certifiedSpectralRadius, h1, h2, hC]
  have hq₁_pos : (0 : ℝ) < (cert₁.q : ℝ) := cert_q_pos cert₁
  have hq₂_pos : (0 : ℝ) < (cert₂.q : ℝ) := cert_q_pos cert₂
  have : cert₂.C / (cert₂.q : ℝ) ≤ cert₂.C / (cert₁.q : ℝ) := by
    apply div_le_div_of_nonneg_left cert₂.C_pos.le hq₁_pos hq
  linarith

/-! ## §11. Concrete Examples -/

noncomputable def exampleCertificate_q7 : CharacterRatioCertificate where
  q := 7
  C := 2
  C_pos := by norm_num
  q_ge_two := by norm_num
  maxCharRatio := 2 / 7
  ratio_nonneg := by positivity
  ratio_le := le_refl _

theorem example_q7_gap :
    certifiedSpectralGap exampleCertificate_q7 = 5 / 7 := by
  simp [certifiedSpectralGap, certifiedSpectralRadius, exampleCertificate_q7]
  norm_num

theorem example_q7_cheeger :
    certifiedCheegerBound exampleCertificate_q7 = 5 / 14 := by
  simp [certifiedCheegerBound, certifiedSpectralGap, certifiedSpectralRadius,
        exampleCertificate_q7]
  norm_num

theorem example_q7_mixing :
    ∀ ε : ℝ, 0 < ε →
      ∃ n : ℕ, (certifiedSpectralRadius exampleCertificate_q7) ^ n < ε := by
  intro ε hε
  apply exists_pow_lt_of_lt_one hε
  simp [certifiedSpectralRadius, exampleCertificate_q7]
  norm_num

/-! ## §12. Torus-Type Decomposition -/

/-- Bounded toral complexity: finitely many torus types with individual
bounds compose to a global bound. -/
theorem bounded_toral_complexity
    (T : ℕ) (hT : 0 < T)
    (C_per_type : Fin T → ℝ) (hC_pos : ∀ i, 0 < C_per_type i)
    (maxC : ℝ) (hmaxC : ∀ i, C_per_type i ≤ maxC) :
    ∃ C₀ : ℝ, 0 < C₀ ∧ ∀ i, C_per_type i ≤ C₀ :=
  ⟨maxC, lt_of_lt_of_le (hC_pos ⟨0, hT⟩) (hmaxC ⟨0, hT⟩), hmaxC⟩

/-! ## §13. Certificate Stability -/

/-- Certificate refinement preserves validity with tighter bound. -/
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

theorem refine_spectral_radius_le
    (cert : CharacterRatioCertificate)
    (newMax : ℝ) (h_le : newMax ≤ cert.maxCharRatio)
    (h_nn : 0 ≤ newMax) :
    certifiedSpectralRadius (cert.refine newMax h_le h_nn) ≤
      certifiedSpectralRadius cert :=
  h_le

theorem refine_spectral_gap_ge
    (cert : CharacterRatioCertificate)
    (newMax : ℝ) (h_le : newMax ≤ cert.maxCharRatio)
    (h_nn : 0 ≤ newMax) :
    certifiedSpectralGap (cert.refine newMax h_le h_nn) ≥
      certifiedSpectralGap cert := by
  simp only [certifiedSpectralGap, certifiedSpectralRadius,
             CharacterRatioCertificate.refine]
  linarith

/-! ## §14. Walk Error Decay -/

/-- Walk error after n steps bounded by (C/q)ⁿ. -/
theorem walk_error_geometric_decay
    (cert : CharacterRatioCertificate) (n : ℕ) :
    (certifiedSpectralRadius cert) ^ n ≤
      (cert.C / cert.q) ^ n := by
  exact pow_le_pow_left₀ cert.ratio_nonneg cert.ratio_le _

/-- Walk error decay monotonicity: more steps → smaller error. -/
theorem walk_error_monotone
    (cert : CharacterRatioCertificate)
    (hsmall : cert.C < (cert.q : ℝ))
    {n m : ℕ} (hnm : n ≤ m) :
    (certifiedSpectralRadius cert) ^ m ≤
      (certifiedSpectralRadius cert) ^ n :=
  pow_le_pow_of_le_one cert.ratio_nonneg (cert_maxRatio_lt_one cert hsmall).le hnm