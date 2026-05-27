/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Approximate Gaussianity and Entropy Stability for Interacting Fermions

This file formalizes the first mathematical bridge from exactly Gaussian (free)
fermionic states to weakly interacting fermionic states, using a coefficient-based
entropy technology. The key idea is that if the interacting state's regional
correlation data stays close to a free reference state in a quantified way,
then one obtains nontrivial entropy upper bounds with explicit first-order
dependence on the interaction scale.

## Mathematical Context

For free-fermion states, the reduced entropy of a region A is governed by the
spectrum of the restricted correlation operator K_A:
  S(K_A) = ∑ᵢ h(λᵢ)
where h(x) = -x log x - (1-x) log(1-x) is the binary entropy function.

For weakly interacting states, exact determinantal structure disappears. But if
the interacting state's eigenvalue spectrum stays ε-close to a free reference,
we prove that the entropy inherits control up to an O(ε·m) correction.

## Main Results

* `binaryEntropy_lipschitz_on_compact` — |h(x)-h(y)| ≤ L_δ |x-y| on [δ,1-δ]
* `entropy_difference_le_of_eigenvalue_sup_bound` — |S(λ)-S(μ)| ≤ m·L_δ·η
* `entropy_upper_bound_of_approxGaussian` — S(λ) ≤ S(λ₀) + m·L_δ·C₀·ε
* `entropy_controlled_by_l1_eigenvalue_distance` — |S(λ)-S(μ)| ≤ L_δ · ∑|λᵢ-μᵢ|
* `elementarySymm_stability_of_sup_norm_bound` — |eₖ(λ)-eₖ(μ)| ≤ C(m,k)·k·η
* `entropy_mem_certificate_of_sup_bound` — soundness of the entropy certificate

## References

* Peschel, "Calculation of reduced density matrices from correlation functions", 2003
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finset BigOperators Real

noncomputable section

/-! ## Core Definitions -/

/-- The binary Shannon entropy function h(x) = -x log x - (1-x) log(1-x). -/
def binaryEntropyFn (x : ℝ) : ℝ :=
  -(x * Real.log x) - ((1 - x) * Real.log (1 - x))

/-- The free-fermion entanglement entropy for a subsystem with eigenvalue spectrum. -/
def regionEntropy {m : ℕ} (spec : Fin m → ℝ) : ℝ :=
  ∑ i, binaryEntropyFn (spec i)

/-- The entropy stability constant L_δ = log((1-δ)/δ). -/
def entropyStabilityConstant (δ : ℝ) : ℝ :=
  Real.log ((1 - δ) / δ)

/-- An approximately Gaussian region: bundles a perturbed spectrum near a
    free-fermion reference spectrum with explicit spectral gap and perturbation. -/
structure ApproxGaussianRegion (m : ℕ) where
  spectrum : Fin m → ℝ
  referenceSpectrum : Fin m → ℝ
  delta : ℝ
  epsilon : ℝ
  spectral_gap : ∀ i, spectrum i ∈ Set.Icc delta (1 - delta)
  reference_gap : ∀ i, referenceSpectrum i ∈ Set.Icc delta (1 - delta)
  perturbation : ∀ i, |spectrum i - referenceSpectrum i| ≤ epsilon

/-- Matrix-level correlation perturbation data. -/
structure CorrelationPerturbationBound (m : ℕ) where
  K : Matrix (Fin m) (Fin m) ℝ
  K0 : Matrix (Fin m) (Fin m) ℝ
  epsilon : ℝ
  K_symm : K.IsSymm
  K0_symm : K0.IsSymm

/-- The k-th elementary symmetric polynomial evaluated at a spectrum. -/
def elemSymmFn (m : ℕ) (k : ℕ) (spec : Fin m → ℝ) : ℝ :=
  ∑ S ∈ Finset.univ.powersetCard k, ∏ i ∈ S, spec i

/-- Verified algorithm: certified entropy interval.
    Returns (S(λ₀) - m·L_δ·η, S(λ₀) + m·L_δ·η). -/
def entropyCertificate (m : ℕ) (δ η : ℝ) (spec0 : Fin m → ℝ) : ℝ × ℝ :=
  let S0 := regionEntropy spec0
  let correction := (m : ℝ) * entropyStabilityConstant δ * η
  (S0 - correction, S0 + correction)

/-! ## Theorem 1: Lipschitz stability of binary entropy -/

/-
**Lipschitz stability of binary entropy on compact subintervals.**
On [δ, 1-δ] with 0 < δ < 1/2, |h(x)-h(y)| ≤ log((1-δ)/δ) · |x-y|.
This is the scalar engine behind all entropy stability results.
-/
theorem binaryEntropy_lipschitz_on_compact
    {δ x y : ℝ}
    (hδ₀ : 0 < δ) (hδ₁ : δ < 1 / 2)
    (hx : x ∈ Set.Icc δ (1 - δ))
    (hy : y ∈ Set.Icc δ (1 - δ)) :
    |binaryEntropyFn x - binaryEntropyFn y| ≤
      Real.log ((1 - δ) / δ) * |x - y| := by
  -- We prove |h(x) - h(y)| ≤ log((1-δ)/δ) * |x-y| where h(x) = -(x log x) - ((1-x) log(1-x)).
  have h_deriv_bound : ∀ t ∈ Set.Icc δ (1 - δ), abs (deriv (fun x => -(x * Real.log x) - ((1 - x) * Real.log (1 - x))) t) ≤ Real.log ((1 - δ) / δ) := by
    intro t ht
    have h_deriv : deriv (fun x => -(x * Real.log x) - ((1 - x) * Real.log (1 - x))) t = Real.log ((1 - t) / t) := by
      convert HasDerivAt.deriv ( HasDerivAt.sub ( HasDerivAt.neg ( HasDerivAt.mul ( hasDerivAt_id' t ) ( Real.hasDerivAt_log ?_ ) ) ) ( HasDerivAt.mul ( hasDerivAt_id' t |> HasDerivAt.const_sub 1 ) ( HasDerivAt.log ( hasDerivAt_id' t |> HasDerivAt.const_sub 1 ) ?_ ) ) ) using 1 <;> norm_num;
      · rw [ Real.log_div ] <;> ring <;> nlinarith [ ht.1, ht.2, mul_inv_cancel₀ ( by linarith [ ht.1, ht.2 ] : t ≠ 0 ), mul_inv_cancel₀ ( by linarith [ ht.1, ht.2 ] : ( 1 - t ) ≠ 0 ) ];
      · linarith [ ht.1, ht.2 ];
      · linarith [ ht.1, ht.2 ];
    rw [ h_deriv, abs_le ];
    exact ⟨ by rw [ ← Real.log_inv, inv_div ] ; exact Real.log_le_log ( by exact div_pos ( by linarith [ ht.1, ht.2 ] ) ( by linarith [ ht.1, ht.2 ] ) ) ( by rw [ div_le_div_iff₀ ] <;> nlinarith [ ht.1, ht.2 ] ), Real.log_le_log ( by exact div_pos ( by linarith [ ht.1, ht.2 ] ) ( by linarith [ ht.1, ht.2 ] ) ) ( by rw [ div_le_div_iff₀ ] <;> nlinarith [ ht.1, ht.2 ] ) ⟩;
  -- Apply the mean value theorem to the interval [x, y].
  have h_mvt : ∀ {a b : ℝ}, a ∈ Set.Icc δ (1 - δ) → b ∈ Set.Icc δ (1 - δ) → a < b → ∃ c ∈ Set.Ioo a b, deriv (fun x => -(x * Real.log x) - ((1 - x) * Real.log (1 - x))) c = (-(b * Real.log b) - ((1 - b) * Real.log (1 - b)) - (-(a * Real.log a) - ((1 - a) * Real.log (1 - a)))) / (b - a) := by
    intros a b ha hb hab; apply_rules [ exists_deriv_eq_slope ];
    · exact continuousOn_of_forall_continuousAt fun x hx => by exact ContinuousAt.sub ( ContinuousAt.neg ( ContinuousAt.mul continuousAt_id ( Real.continuousAt_log ( by linarith [ hx.1, ha.1 ] ) ) ) ) ( ContinuousAt.mul ( continuousAt_const.sub continuousAt_id ) ( ContinuousAt.log ( continuousAt_const.sub continuousAt_id ) ( by linarith [ hx.2, hb.2 ] ) ) ) ;
    · exact fun x hx => DifferentiableAt.differentiableWithinAt ( by exact DifferentiableAt.sub ( DifferentiableAt.neg ( differentiableAt_id.mul ( Real.differentiableAt_log ( by linarith [ hx.1, ha.1 ] ) ) ) ) ( DifferentiableAt.mul ( differentiableAt_id.const_sub _ ) ( DifferentiableAt.log ( differentiableAt_id.const_sub _ ) ( by linarith [ hx.2, hb.2 ] ) ) ) ) ;
  rcases lt_trichotomy x y with ( H | rfl | H ) <;> norm_num [ binaryEntropyFn ] at *;
  · obtain ⟨ c, ⟨ hxc, hcy ⟩, hcd ⟩ := h_mvt hx.1 hx.2 hy.1 hy.2 H ; rw [ abs_le ] ; constructor <;> cases abs_cases ( x - y ) <;> nlinarith [ abs_le.mp ( h_deriv_bound c ( by linarith ) ( by linarith ) ), mul_div_cancel₀ ( - ( y * Real.log y ) - ( 1 - y ) * Real.log ( 1 - y ) - ( - ( x * Real.log x ) - ( 1 - x ) * Real.log ( 1 - x ) ) ) ( sub_ne_zero_of_ne H.ne' ) ] ;
  · obtain ⟨ c, ⟨ h₁, h₂ ⟩, h₃ ⟩ := h_mvt hy.1 hy.2 hx.1 hx.2 H ; rw [ abs_le ] ; constructor <;> cases abs_cases ( x - y ) <;> nlinarith [ abs_le.mp ( h_deriv_bound c ( by linarith ) ( by linarith ) ), mul_div_cancel₀ ( - ( x * Real.log x ) - ( 1 - x ) * Real.log ( 1 - x ) - ( - ( y * Real.log y ) - ( 1 - y ) * Real.log ( 1 - y ) ) ) ( sub_ne_zero_of_ne H.ne' ) ]

/-! ## Theorem 2: Entropy stability under eigenvalue perturbation -/

/-
**Entropy stability under sup-norm eigenvalue perturbation.**
|S(spec)-S(mu)| ≤ m · L_δ · η when |specᵢ - muᵢ| ≤ η for all i.
-/
theorem entropy_difference_le_of_eigenvalue_sup_bound
    {m : ℕ} {δ η : ℝ}
    (hδ₀ : 0 < δ) (hδ₁ : δ < 1 / 2)
    {spec mu : Fin m → ℝ}
    (hspec : ∀ i, spec i ∈ Set.Icc δ (1 - δ))
    (hmu : ∀ i, mu i ∈ Set.Icc δ (1 - δ))
    (hclose : ∀ i, |spec i - mu i| ≤ η) :
    |(∑ i, binaryEntropyFn (spec i)) - (∑ i, binaryEntropyFn (mu i))| ≤
      (m : ℝ) * Real.log ((1 - δ) / δ) * η := by
  -- Applying the Lipschitz inequality to each term, we get:
  have h_lip : ∀ i, |binaryEntropyFn (spec i) - binaryEntropyFn (mu i)| ≤ Real.log ((1 - δ) / δ) * |spec i - mu i| := by
    exact fun i => binaryEntropy_lipschitz_on_compact hδ₀ hδ₁ ( hspec i ) ( hmu i );
  convert Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun i _ => h_lip i |> le_trans <| mul_le_mul_of_nonneg_left ( hclose i ) <| Real.log_nonneg <| ?_ using 1;
  exacts [ by rw [ Finset.sum_sub_distrib ], by simp +decide [ mul_assoc ], by rw [ le_div_iff₀ hδ₀ ] ; linarith ]

/-! ## Theorem 3: Flagship entropy bound for approximately Gaussian states -/

/-
**First-order weak-interaction entropy bound.**
S(spec) ≤ S(spec0) + m · L_δ · C₀ · ε when |specᵢ - spec0ᵢ| ≤ C₀·ε.
-/
theorem entropy_upper_bound_of_approxGaussian
    {m : ℕ} {δ ε C0 : ℝ}
    (hδ₀ : 0 < δ) (hδ₁ : δ < 1 / 2)
    {spec spec0 : Fin m → ℝ}
    (hspec : ∀ i, spec i ∈ Set.Icc δ (1 - δ))
    (hspec0 : ∀ i, spec0 i ∈ Set.Icc δ (1 - δ))
    (hpert : ∀ i, |spec i - spec0 i| ≤ C0 * ε) :
    (∑ i, binaryEntropyFn (spec i)) ≤
      (∑ i, binaryEntropyFn (spec0 i)) +
      (m : ℝ) * Real.log ((1 - δ) / δ) * (C0 * ε) := by
  -- Apply the lemma `entropy_difference_le_of_eigenvalue_sup_bound` with η = C0 * ε.
  have h_entropy_diff : |(∑ i, binaryEntropyFn (spec i)) - (∑ i, binaryEntropyFn (spec0 i))| ≤ (m : ℝ) * Real.log ((1 - δ) / δ) * (C0 * ε) := by
    convert entropy_difference_le_of_eigenvalue_sup_bound hδ₀ hδ₁ hspec hspec0 hpert using 1;
  linarith [ abs_le.mp h_entropy_diff ]

/-! ## Theorem 4: L1 eigenvalue distance control -/

/-
**Entropy controlled by L1 eigenvalue distance.**
|S(spec) - S(mu)| ≤ L_δ · ∑ᵢ |specᵢ - muᵢ|.
-/
theorem entropy_controlled_by_l1_eigenvalue_distance
    {m : ℕ} {δ : ℝ}
    (hδ₀ : 0 < δ) (hδ₁ : δ < 1 / 2)
    {spec mu : Fin m → ℝ}
    (hspec : ∀ i, spec i ∈ Set.Icc δ (1 - δ))
    (hmu : ∀ i, mu i ∈ Set.Icc δ (1 - δ)) :
    |regionEntropy spec - regionEntropy mu| ≤
      entropyStabilityConstant δ *
      ∑ i, |spec i - mu i| := by
  convert Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun i _ => binaryEntropy_lipschitz_on_compact hδ₀ hδ₁ ( hspec i ) ( hmu i ) using 1;
  exacts [ by rw [ Finset.sum_sub_distrib, regionEntropy, regionEntropy ], by rw [ Finset.mul_sum _ _ _ ] ; rfl ]

/-! ## Theorem 5: Elementary symmetric polynomial stability -/

/-
**Elementary symmetric polynomial stability.**
|eₖ(spec)-eₖ(mu)| ≤ C(m,k) · k · η when |specᵢ - muᵢ| ≤ η and spectra ∈ [0,1].
-/
theorem elementarySymm_stability_of_sup_norm_bound
    {m k : ℕ} {spec mu : Fin m → ℝ} {η : ℝ}
    (hη : 0 ≤ η)
    (hspec : ∀ i, spec i ∈ Set.Icc 0 1)
    (hmu : ∀ i, mu i ∈ Set.Icc 0 1)
    (hclose : ∀ i, |spec i - mu i| ≤ η) :
    |elemSymmFn m k spec - elemSymmFn m k mu| ≤
      ((Nat.choose m k : ℝ) * k * η) := by
  -- Let's bound the difference between the products $\prod_{i \in S} spec i$ and $\prod_{i \in S} mu i$ for each subset $S$ of size $k$.
  have h_prod_diff_bound : ∀ S : Finset (Fin m), S.card = k → |∏ i ∈ S, spec i - ∏ i ∈ S, mu i| ≤ k * η := by
    intro S hS_card
    have h_prod_bound : ∀ (s : Finset (Fin m)), |∏ i ∈ s, spec i - ∏ i ∈ s, mu i| ≤ s.card * η := by
      intro s
      induction' s using Finset.induction with i s hi ih;
      · norm_num;
      · simp_all +decide [ Finset.prod_insert hi ];
        rw [ abs_le ] at *;
        constructor <;> nlinarith [ abs_le.mp ( hclose i ), hspec i, hmu i, show ∏ i ∈ s, spec i ≥ 0 from Finset.prod_nonneg fun _ _ => hspec _ |>.1, show ∏ i ∈ s, mu i ≥ 0 from Finset.prod_nonneg fun _ _ => hmu _ |>.1, show ∏ i ∈ s, spec i ≤ 1 from Finset.prod_le_one ( fun _ _ => hspec _ |>.1 ) fun _ _ => hspec _ |>.2, show ∏ i ∈ s, mu i ≤ 1 from Finset.prod_le_one ( fun _ _ => hmu _ |>.1 ) fun _ _ => hmu _ |>.2 ];
    simpa only [ hS_card ] using h_prod_bound S;
  convert Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun S hS => h_prod_diff_bound S <| Finset.mem_powersetCard.mp hS |>.2 using 1 ; ring!;
  rw [ Finset.sum_sub_distrib, elemSymmFn, elemSymmFn ];
  norm_num [ mul_assoc ]

/-! ## Soundness of Entropy Certificate -/

/-
**Soundness of the entropy certificate.**
The interval from `entropyCertificate` contains the entropy of any
nearby spectrum.
-/
theorem entropy_mem_certificate_of_sup_bound
    {m : ℕ} {δ η : ℝ} {spec spec0 : Fin m → ℝ}
    (hδ₀ : 0 < δ) (hδ₁ : δ < 1 / 2)
    (_hη : 0 ≤ η)
    (hspec : ∀ i, spec i ∈ Set.Icc δ (1 - δ))
    (hspec0 : ∀ i, spec0 i ∈ Set.Icc δ (1 - δ))
    (hclose : ∀ i, |spec i - spec0 i| ≤ η) :
    let I := entropyCertificate m δ η spec0
    regionEntropy spec ∈ Set.Icc I.1 I.2 := by
  convert entropy_difference_le_of_eigenvalue_sup_bound hδ₀ hδ₁ hspec hspec0 hclose using 1;
  unfold entropyCertificate regionEntropy; norm_num [ abs_le ] ;
  unfold entropyStabilityConstant; ring;

/-! ## ApproxGaussianRegion API -/

/-
The entropy of an approximately Gaussian region is controlled by the
    reference entropy plus a correction term.
-/
theorem ApproxGaussianRegion.entropy_bound
    (R : ApproxGaussianRegion m)
    (hδ₀ : 0 < R.delta) (hδ₁ : R.delta < 1 / 2) :
    regionEntropy R.spectrum ≤
      regionEntropy R.referenceSpectrum +
      (m : ℝ) * entropyStabilityConstant R.delta * R.epsilon := by
  -- Apply the entropy difference bound with η = R.epsilon.
  have h_entropy_diff : |regionEntropy R.spectrum - regionEntropy R.referenceSpectrum| ≤ (m : ℝ) * entropyStabilityConstant R.delta * R.epsilon := by
    convert entropy_difference_le_of_eigenvalue_sup_bound hδ₀ hδ₁ R.spectral_gap R.reference_gap R.perturbation using 1;
  linarith [ abs_le.mp h_entropy_diff ]

/-
Transfer theorem: given a free-fermion entropy bound B on the reference,
    the interacting entropy is bounded by B + correction.
-/
theorem ApproxGaussianRegion.transfer_free_bound
    (R : ApproxGaussianRegion m)
    (hδ₀ : 0 < R.delta) (hδ₁ : R.delta < 1 / 2)
    {B : ℝ} (hfree : regionEntropy R.referenceSpectrum ≤ B) :
    regionEntropy R.spectrum ≤
      B + (m : ℝ) * entropyStabilityConstant R.delta * R.epsilon := by
  convert le_trans _ ( add_le_add_right hfree _ ) using 1;
  rw [ add_comm ];
  convert R.entropy_bound hδ₀ hδ₁ using 1;
  ring

end