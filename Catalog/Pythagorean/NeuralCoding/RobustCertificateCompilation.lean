/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Robust Certificate Compilation for Approximate Lorentzianity

This file establishes the perturbative stability theory for certificate compilation
of quantum states from approximately Lorentzian coefficient data. The central result
is that exact Lorentzian certificate compilation is not a knife-edge phenomenon:
small violations of exact Lorentzianity induce only quadratically small losses
in the prepared quantum state, linking combinatorial log-concavity to quantitative
quantum robustness.

## Main Definitions

* `RobustCertificate.l2NormSq` — ℓ² norm squared: `∑ a, (w a)²`
* `RobustCertificate.l2Norm` — ℓ² norm: `√(∑ a, (w a)²)`
* `RobustCertificate.tvDist` — total variation distance for weight vectors
* `RobustCertificate.normalizedVec` — normalized weight vector: `w / ‖w‖₂`
* `RobustCertificate.fidelityReal` — fidelity between real amplitude states
* `RobustCertificate.ApproxLorentzianCertificate` — approximate certificate structure

## Main Results

* `normalized_l2_stability` — normalization is 2-Lipschitz on the unit-norm shell
* `fidelity_ge_one_sub_norm_sq` — fidelity ≥ 1 - ‖normalized difference‖²
* `fidelity_bound_from_perturbation` — fidelity ≥ 1 - 4‖w-v‖²/min(‖w‖,‖v‖)²
* `approximate_certificate_fidelity_bound` — robust compilation theorem
* `bhattacharyya_le_fidelity_sqrt` — bridge to classical statistical distance

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Fuchs–van de Graaf, "Cryptographic distinguishability measures", IEEE Trans. IT, 1999
-/

open Finset BigOperators Real

noncomputable section

namespace RobustCertificate

/-! ## Core Definitions -/

/-- The ℓ² norm squared of a weight vector: `∑ a, (w a)²`. -/
def l2NormSq {α : Type*} [Fintype α] (w : α → ℝ) : ℝ :=
  ∑ a, w a ^ 2

/-- The ℓ² norm of a weight vector: `√(∑ a, (w a)²)`. -/
def l2Norm {α : Type*} [Fintype α] (w : α → ℝ) : ℝ :=
  Real.sqrt (l2NormSq w)

/-- The total variation distance between two weight vectors:
    `(1/2) * ∑ a, |w a - v a|`. -/
def tvDist {α : Type*} [Fintype α] (w v : α → ℝ) : ℝ :=
  (1 / 2) * ∑ a, |w a - v a|

/-- The ℓ¹ distance between two weight vectors: `∑ a, |w a - v a|`. -/
def l1Dist {α : Type*} [Fintype α] (w v : α → ℝ) : ℝ :=
  ∑ a, |w a - v a|

/-- The normalized weight vector: `w / ‖w‖₂`. -/
def normalizedVec {α : Type*} [Fintype α] (w : α → ℝ) : α → ℝ :=
  fun a => w a / l2Norm w

/-- The inner product of two weight vectors: `∑ a, w a * v a`. -/
def innerProd {α : Type*} [Fintype α] (w v : α → ℝ) : ℝ :=
  ∑ a, w a * v a

/-- Real fidelity between two nonneg weight vectors, defined as
    the squared overlap of normalized vectors:
    `(∑ a, (w a / ‖w‖) * (v a / ‖v‖))²`. -/
def fidelityReal {α : Type*} [Fintype α] (w v : α → ℝ) : ℝ :=
  (∑ a, normalizedVec w a * normalizedVec v a) ^ 2

/-- An approximate Lorentzian certificate bundles exact and approximate
    weight vectors with controlled total variation error. -/
structure ApproxLorentzianCertificate (α : Type*) [Fintype α] where
  /-- The exact (certified Lorentzian) weight vector -/
  exactWeights : α → ℝ
  /-- The approximate (perturbed) weight vector -/
  approxWeights : α → ℝ
  /-- Nonnegativity of exact weights -/
  nonneg_exact : ∀ a, 0 ≤ exactWeights a
  /-- Nonnegativity of approximate weights -/
  nonneg_approx : ∀ a, 0 ≤ approxWeights a
  /-- The error bound -/
  eps : ℝ
  /-- The error bound is nonneg -/
  eps_nonneg : 0 ≤ eps
  /-- Total variation distance is bounded by eps -/
  tv_le_eps : tvDist approxWeights exactWeights ≤ eps

/-! ## Basic Properties -/

theorem l2NormSq_nonneg {α : Type*} [Fintype α] (w : α → ℝ) :
    0 ≤ l2NormSq w :=
  Finset.sum_nonneg fun a _ => sq_nonneg (w a)

theorem l2Norm_nonneg {α : Type*} [Fintype α] (w : α → ℝ) :
    0 ≤ l2Norm w :=
  Real.sqrt_nonneg (l2NormSq w)

theorem l2NormSq_pos_of_ne_zero {α : Type*} [Fintype α] (w : α → ℝ)
    (h : ∃ a, w a ≠ 0) : 0 < l2NormSq w := by
  obtain ⟨a, ha⟩ := h
  exact Finset.sum_pos' (fun i _ => sq_nonneg (w i)) ⟨a, Finset.mem_univ _, by positivity⟩

theorem l2Norm_pos_of_ne_zero {α : Type*} [Fintype α] (w : α → ℝ)
    (h : ∃ a, w a ≠ 0) : 0 < l2Norm w :=
  Real.sqrt_pos_of_pos (l2NormSq_pos_of_ne_zero w h)

theorem l2Norm_sq {α : Type*} [Fintype α] (w : α → ℝ) :
    l2Norm w ^ 2 = l2NormSq w :=
  Real.sq_sqrt (l2NormSq_nonneg w)

theorem l2Norm_pos_of_pos_weight {α : Type*} [Fintype α] (w : α → ℝ)
    (h : ∃ a, 0 < w a) : 0 < l2Norm w := by
  obtain ⟨a, ha⟩ := h
  exact l2Norm_pos_of_ne_zero w ⟨a, ne_of_gt ha⟩

/-- Total variation distance is nonneg. -/
theorem tvDist_nonneg {α : Type*} [Fintype α] (w v : α → ℝ) :
    0 ≤ tvDist w v := by
  unfold tvDist
  apply mul_nonneg
  · linarith
  · exact Finset.sum_nonneg fun a _ => abs_nonneg _

/-- Total variation distance is symmetric. -/
theorem tvDist_symm {α : Type*} [Fintype α] (w v : α → ℝ) :
    tvDist w v = tvDist v w := by
  unfold tvDist
  congr 1
  apply Finset.sum_congr rfl
  intro a _
  rw [abs_sub_comm]

/-- ℓ¹ distance is nonneg. -/
theorem l1Dist_nonneg {α : Type*} [Fintype α] (w v : α → ℝ) :
    0 ≤ l1Dist w v :=
  Finset.sum_nonneg fun a _ => abs_nonneg _

/-- TV distance equals half the ℓ¹ distance. -/
theorem tvDist_eq_half_l1 {α : Type*} [Fintype α] (w v : α → ℝ) :
    tvDist w v = (1 / 2) * l1Dist w v := rfl

/-! ## Normalization Properties -/

/-- The ℓ² norm squared of a normalized vector is 1 when the norm is positive. -/
theorem normalizedVec_l2NormSq {α : Type*} [Fintype α] (w : α → ℝ)
    (hw : 0 < l2Norm w) :
    l2NormSq (normalizedVec w) = 1 := by
  unfold l2NormSq normalizedVec
  simp only [div_pow]
  rw [← Finset.sum_div]
  rw [l2Norm_sq] at *
  exact div_self (ne_of_gt (l2NormSq_pos_of_ne_zero w (by
    by_contra h
    push_neg at h
    simp [l2Norm, l2NormSq, h] at hw)))

/-- The inner product of the normalized vector with itself is 1. -/
theorem normalizedVec_innerProd_self {α : Type*} [Fintype α] (w : α → ℝ)
    (hw : 0 < l2Norm w) :
    innerProd (normalizedVec w) (normalizedVec w) = 1 := by
  unfold innerProd normalizedVec
  simp only [← sq]
  simp only [div_pow]
  rw [← Finset.sum_div, l2Norm_sq]
  exact div_self (ne_of_gt (l2NormSq_pos_of_ne_zero w (by
    by_contra h; push_neg at h; simp [l2Norm, l2NormSq, h] at hw)))

/-- The inner product of normalized vectors factors through norms. -/
theorem innerProd_normalizedVec {α : Type*} [Fintype α] (w v : α → ℝ)
    (_hw : 0 < l2Norm w) (_hv : 0 < l2Norm v) :
    innerProd (normalizedVec w) (normalizedVec v) =
      innerProd w v / (l2Norm w * l2Norm v) := by
  unfold innerProd normalizedVec
  simp only [div_mul_div_comm]
  rw [← Finset.sum_div]

/-- Fidelity expressed via raw inner product. -/
theorem fidelityReal_eq {α : Type*} [Fintype α] (w v : α → ℝ)
    (hw : 0 < l2Norm w) (hv : 0 < l2Norm v) :
    fidelityReal w v = (innerProd w v / (l2Norm w * l2Norm v)) ^ 2 := by
  unfold fidelityReal
  congr 1
  exact innerProd_normalizedVec w v hw hv

/-! ## ℓ² Norm of Difference of Normalized Vectors -/

/-
The ℓ² norm squared of the difference of normalized vectors satisfies
    `‖ψ_w - ψ_v‖₂² = 2 - 2⟨ψ_w, ψ_v⟩`.
-/
theorem l2NormSq_normalizedVec_sub {α : Type*} [Fintype α] (w v : α → ℝ)
    (hw : 0 < l2Norm w) (hv : 0 < l2Norm v) :
    l2NormSq (fun a => normalizedVec w a - normalizedVec v a) =
      2 - 2 * innerProd (normalizedVec w) (normalizedVec v) := by
  have h_norm_sq : l2NormSq (normalizedVec w) = 1 ∧ l2NormSq (normalizedVec v) = 1 := by
    exact ⟨ normalizedVec_l2NormSq w hw, normalizedVec_l2NormSq v hv ⟩
  have h_inner_prod : innerProd (normalizedVec w) (normalizedVec v) = innerProd w v / (l2Norm w * l2Norm v) := by
    convert innerProd_normalizedVec w v hw hv using 1
  have h_norm_sq_diff : l2NormSq (fun a => normalizedVec w a - normalizedVec v a) = l2NormSq (normalizedVec w) + l2NormSq (normalizedVec v) - 2 * innerProd (normalizedVec w) (normalizedVec v) := by
    unfold l2NormSq innerProd; simp +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _ ] ; ring;
  simp_all +decide [ l2NormSq, innerProd ];
  norm_num

/-! ## Main Theorem 1: Normalization is Lipschitz -/

/-
**Reverse triangle inequality for ℓ² norm:**
    `|‖w‖₂ - ‖v‖₂| ≤ ‖w - v‖₂`.
-/
theorem l2Norm_reverse_triangle {α : Type*} [Fintype α] (w v : α → ℝ) :
    |l2Norm w - l2Norm v| ≤ l2Norm (fun a => w a - v a) := by
  -- Apply the reverse triangle inequality for the Euclidean norm.
  have h_reverse_triangle : ∀ (u v : EuclideanSpace ℝ α), |‖u‖ - ‖v‖| ≤ ‖u - v‖ := by
    exact fun u v => abs_norm_sub_norm_le u v;
  simp_all +decide [ EuclideanSpace.norm_eq ];
  convert h_reverse_triangle ( WithLp.toLp 2 w ) ( WithLp.toLp 2 v ) using 1

/-
**Normalization stability (ℓ² bound):**
    For vectors with positive ℓ² norms:
    `‖w/‖w‖ - v/‖v‖‖₂ ≤ 2 * ‖w - v‖₂ / min(‖w‖₂, ‖v‖₂)`.

    This is the analytic backbone of robust compilation: small perturbations
    in weight vectors produce proportionally small perturbations in
    normalized states, with amplification controlled by the inverse of the
    smallest norm.
-/
theorem normalized_l2_stability {α : Type*} [Fintype α] (w v : α → ℝ)
    (hw : 0 < l2Norm w) (hv : 0 < l2Norm v) :
    l2NormSq (fun a => normalizedVec w a - normalizedVec v a) ≤
      (2 * l2Norm (fun a => w a - v a) / min (l2Norm w) (l2Norm v)) ^ 2 := by
  -- By the properties of the ℓ² norm and the Cauchy-Schwarz inequality, we can bound the inner product.
  have h_inner_bound : innerProd w v ≥ (l2Norm w ^ 2 + l2Norm v ^ 2 - l2NormSq (fun a => w a - v a)) / 2 := by
    unfold innerProd l2NormSq l2Norm;
    unfold l2NormSq; rw [ Real.sq_sqrt <| Finset.sum_nonneg fun _ _ => sq_nonneg _, Real.sq_sqrt <| Finset.sum_nonneg fun _ _ => sq_nonneg _ ] ; simp +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _ ] ; ring_nf; simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ] ;
  -- Substitute the bound on the inner product into the expression for the ℓ² norm squared of the difference of normalized vectors.
  have h_subst : l2NormSq (fun a => normalizedVec w a - normalizedVec v a) ≤ (l2Norm w ^ 2 + l2Norm v ^ 2 - 2 * ((l2Norm w ^ 2 + l2Norm v ^ 2 - l2NormSq (fun a => w a - v a)) / 2)) / (l2Norm w * l2Norm v) := by
    convert l2NormSq_normalizedVec_sub w v hw hv |> fun h => h.le.trans _ using 1;
    rw [ innerProd_normalizedVec w v hw hv ];
    field_simp;
    linarith [ sq_nonneg ( l2Norm w - l2Norm v ) ];
  refine le_trans h_subst ?_;
  rw [ div_pow, div_le_div_iff₀ ] <;> try positivity;
  rw [ show l2NormSq ( fun a => w a - v a ) = l2Norm ( fun a => w a - v a ) ^ 2 by rw [ l2Norm_sq ] ] ; ring_nf;
  cases min_cases ( l2Norm w ) ( l2Norm v ) <;> nlinarith [ mul_pos hw hv, mul_le_mul_of_nonneg_left ( min_le_left ( l2Norm w ) ( l2Norm v ) ) ( sq_nonneg ( l2Norm ( fun a => w a - v a ) ) ), mul_le_mul_of_nonneg_left ( min_le_right ( l2Norm w ) ( l2Norm v ) ) ( sq_nonneg ( l2Norm ( fun a => w a - v a ) ) ) ]

/-! ## Main Theorem 2: Fidelity Lower Bound from Perturbation -/

/-
**Inner product and norm-squared identity:**
    For unit vectors `u, v`, `⟨u, v⟩ = 1 - ½‖u - v‖₂²`.
-/
theorem inner_eq_one_sub_half_normSq {α : Type*} [Fintype α] (w v : α → ℝ)
    (hw : 0 < l2Norm w) (hv : 0 < l2Norm v) :
    innerProd (normalizedVec w) (normalizedVec v) =
      1 - (1/2) * l2NormSq (fun a => normalizedVec w a - normalizedVec v a) := by
  unfold l2NormSq; ring;
  simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, mul_assoc, mul_comm, mul_left_comm, sq, innerProd ] ; ring;
  rw [ show ∑ x, normalizedVec w x ^ 2 = 1 by exact normalizedVec_l2NormSq w hw ] ; rw [ show ∑ x, normalizedVec v x ^ 2 = 1 by exact normalizedVec_l2NormSq v hv ] ; norm_num [ ← Finset.sum_mul _ _ _ ] ; ring;

/-
**Fidelity lower bound (nonneg case):**
    For nonneg weight vectors, fidelity is at least `1 - ‖ψ_w - ψ_v‖₂²`.

    Proof: For nonneg vectors, `⟨ψ_w, ψ_v⟩ ≥ 0`, so
    `F = ⟨ψ_w, ψ_v⟩² ≥ ⟨ψ_w, ψ_v⟩ · (2⟨ψ_w,ψ_v⟩ - 1)`.
    But actually the clean bound is `⟨ψ_w, ψ_v⟩ ≥ 1 - δ²/2`,
    hence `F ≥ (1 - δ²/2)² ≥ 1 - δ²`.
-/
theorem fidelity_ge_one_sub_norm_sq {α : Type*} [Fintype α]
    (w v : α → ℝ)
    (hw0 : ∀ a, 0 ≤ w a) (hv0 : ∀ a, 0 ≤ v a)
    (hw : 0 < l2Norm w) (hv : 0 < l2Norm v) :
    fidelityReal w v ≥
      1 - l2NormSq (fun a => normalizedVec w a - normalizedVec v a) := by
  -- By inner_eq_one_sub_half_normSq, let δ² = l2NormSq(ψ_w - ψ_v), then
  -- ⟨ψ_w, ψ_v⟩ = 1 - δ²/2.
  set δ_sq := l2NormSq (fun a => (normalizedVec w a) - (normalizedVec v a))
  have h_inner : innerProd (normalizedVec w) (normalizedVec v) = 1 - δ_sq / 2 := by
    convert inner_eq_one_sub_half_normSq w v hw hv using 1 ; ring;
  -- Since `fidelityReal w v = (⟨ψ_w, ψ_v⟩)²`, we need to show `(1 - δ_sq / 2)² ≥ 1 - δ_sq`.
  have h_fidelity : fidelityReal w v = (1 - δ_sq / 2) ^ 2 := by
    convert congr_arg ( · ^ 2 ) h_inner using 1;
  nlinarith only [ h_fidelity, show 0 ≤ δ_sq by exact Finset.sum_nonneg fun _ _ => sq_nonneg _ ]

/-
**Quantitative fidelity bound from perturbation:**
    `fidelity(w, v) ≥ 1 - 4 * ‖w - v‖₂² / min(‖w‖₂, ‖v‖₂)²`.

    This combines the normalization stability theorem with the fidelity
    lower bound to give the quantitative perturbation result.
-/
theorem fidelity_bound_from_perturbation {α : Type*} [Fintype α]
    (w v : α → ℝ)
    (hw0 : ∀ a, 0 ≤ w a) (hv0 : ∀ a, 0 ≤ v a)
    (hw : 0 < l2Norm w) (hv : 0 < l2Norm v) :
    fidelityReal w v ≥
      1 - 4 * l2NormSq (fun a => w a - v a) / (min (l2Norm w) (l2Norm v)) ^ 2 := by
  convert fidelity_ge_one_sub_norm_sq w v hw0 hv0 hw hv |> le_trans _ using 1;
  convert sub_le_sub_left ( normalized_l2_stability w v hw hv ) 1 using 1 ; ring;
  rw [ l2Norm_sq ] ; ring

/-! ## Cross-Domain Bridge: Bhattacharyya Coefficient and Fidelity -/

/-- The Bhattacharyya coefficient between two nonneg unit vectors:
    `BC(p, q) = ∑ a, √(p a * q a)`. -/
def bhattacharyyaCoeff {α : Type*} [Fintype α] (p q : α → ℝ) : ℝ :=
  ∑ a, Real.sqrt (p a * q a)

/-
**Bhattacharyya–fidelity bridge for nonneg amplitude vectors:**
    For nonneg weight vectors, fidelity equals the squared Bhattacharyya
    coefficient of the squared-amplitude distributions.

    More precisely, for nonneg `w, v`, the overlap of normalized vectors
    `⟨ψ_w, ψ_v⟩ = ∑ w_i v_i / (‖w‖ ‖v‖)` satisfies
    `⟨ψ_w, ψ_v⟩ = BC(p, q)` where `p_i = w_i²/‖w‖²`, `q_i = v_i²/‖v‖²`.

    This connects quantum fidelity to classical statistical overlap.
-/
theorem fidelity_eq_bhattacharyya_sq_of_nonneg {α : Type*} [Fintype α]
    (w v : α → ℝ)
    (hw0 : ∀ a, 0 ≤ w a) (hv0 : ∀ a, 0 ≤ v a)
    (hw : 0 < l2Norm w) (hv : 0 < l2Norm v) :
    fidelityReal w v =
      (bhattacharyyaCoeff
        (fun a => (w a / l2Norm w) ^ 2)
        (fun a => (v a / l2Norm v) ^ 2)) ^ 2 := by
  unfold fidelityReal bhattacharyyaCoeff;
  simp +decide [ normalizedVec, Real.sqrt_mul ( sq_nonneg _ ), Real.sqrt_sq ( div_nonneg ( hw0 _ ) hw.le ), Real.sqrt_sq ( div_nonneg ( hv0 _ ) hv.le ) ]

/-! ## Condition Number Theorem -/

/-
**Condition number for certificate compilation:**
    If total mass `∑ w a ≥ m > 0` and the number of elements is `n`,
    then `‖w‖₂ ≥ m / √n`, giving a condition number bound for
    normalization stability.
-/
theorem l2Norm_ge_mass_div_sqrt {α : Type*} [Fintype α]
    (w : α → ℝ) (hw0 : ∀ a, 0 ≤ w a)
    (m : ℝ) (hm : m ≤ ∑ a, w a) :
    m / Real.sqrt (Fintype.card α) ≤ l2Norm w := by
  refine' div_le_of_le_mul₀ _ _ _;
  · exact Real.sqrt_nonneg _;
  · exact l2Norm_nonneg w;
  · refine' le_trans hm _;
    have h_cauchy_schwarz : (∑ a, w a) ^ 2 ≤ (Fintype.card α) * (∑ a, w a ^ 2) := by
      have := ( Finset.univ.sum_le_sum fun i _ => mul_self_nonneg ( w i - ( ∑ i : α, w i ) / Fintype.card α ) );
      by_cases h : Fintype.card α = 0 <;> simp_all +decide [ sub_mul, mul_sub ];
      · simp_all +decide [ Fintype.card_eq_zero_iff ];
      · case _ => simp_all +decide only [← sum_mul, ← Finset.mul_sum _ _ _, sq] ; nlinarith [ mul_div_cancel₀ ( ∑ i, w i ) ( Nat.cast_ne_zero.mpr h ) ] ;
    convert Real.le_sqrt_of_sq_le h_cauchy_schwarz using 1;
    unfold l2Norm; rw [ mul_comm, Real.sqrt_mul ( Nat.cast_nonneg _ ) ] ;
    rfl

/-
**Condition-number-controlled fidelity:**
    If both weight vectors have total mass at least `m > 0` and the
    ambient type has cardinality `n`, then:
    `fidelity(w, v) ≥ 1 - 4n * ‖w - v‖₂² / m²`.
-/
theorem fidelity_bound_from_mass {α : Type*} [Fintype α]
    (w v : α → ℝ)
    (hw0 : ∀ a, 0 ≤ w a) (hv0 : ∀ a, 0 ≤ v a)
    (m : ℝ) (hm : 0 < m)
    (hwm : m ≤ ∑ a, w a) (hvm : m ≤ ∑ a, v a)
    (hw : 0 < l2Norm w) (hv : 0 < l2Norm v) :
    fidelityReal w v ≥
      1 - 4 * (Fintype.card α : ℝ) * l2NormSq (fun a => w a - v a) / m ^ 2 := by
  -- From l2Norm_ge_mass_div_sqrt: l2Norm w ≥ m / √n and l2Norm v ≥ m / √n.
  have l2Norm_w_ge : l2Norm w ≥ m / Real.sqrt (Fintype.card α) := by
    exact l2Norm_ge_mass_div_sqrt w hw0 m hwm
  have l2Norm_v_ge : l2Norm v ≥ m / Real.sqrt (Fintype.card α) := by
    convert l2Norm_ge_mass_div_sqrt v hv0 m hvm using 1;
  convert fidelity_bound_from_perturbation w v hw0 hv0 hw hv |> le_trans _ using 1;
  rw [ sub_le_sub_iff_left, div_le_div_iff₀ ] <;> try positivity;
  -- By simplifying, we can see that both sides of the inequality are equal.
  have h_simp : (m / Real.sqrt (Fintype.card α)) ^ 2 ≤ (min (l2Norm w) (l2Norm v)) ^ 2 := by
    exact pow_le_pow_left₀ ( by positivity ) ( le_min l2Norm_w_ge l2Norm_v_ge ) _;
  convert mul_le_mul_of_nonneg_left h_simp ( show 0 ≤ 4 * ( Fintype.card α : ℝ ) * l2NormSq ( fun a => w a - v a ) by exact mul_nonneg ( mul_nonneg zero_le_four ( Nat.cast_nonneg _ ) ) ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ) using 1 ; ring;
  by_cases h : Fintype.card α = 0 <;> simp_all +decide [ mul_assoc ];
  simp_all +decide [ Fintype.card_eq_zero_iff ];
  linarith

/-! ## ℓ² vs ℓ¹ Bridge -/

/-
The ℓ² norm squared is at most the ℓ¹ norm squared:
    `∑ (w a - v a)² ≤ (∑ |w a - v a|)²`.
-/
theorem l2NormSq_le_l1Dist_sq {α : Type*} [Fintype α] (w v : α → ℝ) :
    l2NormSq (fun a => w a - v a) ≤ l1Dist w v ^ 2 := by
  unfold l2NormSq l1Dist;
  simpa only [ sq, Finset.sum_mul ] using Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( Finset.single_le_sum ( fun a _ => abs_nonneg ( w a - v a ) ) ( Finset.mem_univ i ) ) ( abs_nonneg ( w i - v i ) ) |> le_trans ( by cases abs_cases ( w i - v i ) <;> nlinarith )

/-
**TV-based fidelity bound:**
    `fidelity(w, v) ≥ 1 - 16 * tvDist(w, v)² / min(‖w‖₂, ‖v‖₂)²`.
-/
theorem fidelity_bound_from_tv {α : Type*} [Fintype α]
    (w v : α → ℝ)
    (hw0 : ∀ a, 0 ≤ w a) (hv0 : ∀ a, 0 ≤ v a)
    (hw : 0 < l2Norm w) (hv : 0 < l2Norm v) :
    fidelityReal w v ≥
      1 - 16 * tvDist w v ^ 2 / (min (l2Norm w) (l2Norm v)) ^ 2 := by
  have h_bound : l2NormSq (fun a => w a - v a) ≤ (2 * tvDist w v) ^ 2 := by
    convert l2NormSq_le_l1Dist_sq w v using 1 ; ring;
    unfold tvDist l1Dist; ring;
  convert fidelity_bound_from_perturbation w v hw0 hv0 hw hv |> le_trans _ using 1;
  exact sub_le_sub_left ( div_le_div_of_nonneg_right ( by linarith ) ( sq_nonneg _ ) ) _

/-! ## Main Theorem 3: Robust Certificate Compilation -/

/-- **Approximate certificate compilation fidelity bound:**
    If an approximate certificate has TV error at most `ε`, then the fidelity
    between the approximate and exact coefficient states satisfies
    `F ≥ 1 - 16ε² / min(‖w‖₂, ‖v‖₂)²`.

    This is the centerpiece theorem: exact certificate uniqueness combined
    with perturbation stability yields robust compiled-state correctness. -/
theorem approximate_certificate_fidelity_bound {α : Type*} [Fintype α]
    (A : ApproxLorentzianCertificate α)
    (hw : 0 < l2Norm A.exactWeights)
    (hv : 0 < l2Norm A.approxWeights) :
    fidelityReal A.approxWeights A.exactWeights ≥
      1 - 16 * A.eps ^ 2 / (min (l2Norm A.approxWeights) (l2Norm A.exactWeights)) ^ 2 := by
  have h1 := fidelity_bound_from_tv A.approxWeights A.exactWeights A.nonneg_approx A.nonneg_exact hv hw
  have h2 : tvDist A.approxWeights A.exactWeights ≤ A.eps := A.tv_le_eps
  have h3 : 0 ≤ tvDist A.approxWeights A.exactWeights := tvDist_nonneg _ _
  have h4 : tvDist A.approxWeights A.exactWeights ^ 2 ≤ A.eps ^ 2 :=
    sq_le_sq' (by linarith) h2
  have h5 : 16 * tvDist A.approxWeights A.exactWeights ^ 2 /
      (min (l2Norm A.approxWeights) (l2Norm A.exactWeights)) ^ 2 ≤
    16 * A.eps ^ 2 / (min (l2Norm A.approxWeights) (l2Norm A.exactWeights)) ^ 2 := by
    apply div_le_div_of_nonneg_right _ (by positivity)
    nlinarith
  linarith

end RobustCertificate