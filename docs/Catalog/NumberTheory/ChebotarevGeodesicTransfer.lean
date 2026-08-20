/-
# Chebotarev geodesic theorem: transfer, obstruction, and converse

A fourth research cycle built on `Shared.ChebotarevGeodesic`,
`Shared.ChebotarevGeodesicSharpness` and `Shared.ChebotarevGeodesicOptimal`.

The previous cycles produced the exponent calculus, the invertible-transform reduction
(the abstract form of the paper's reduction of the non-split case to the split case), the
structure theorem `exponentSet = Ici (optimalExponent)`, and sharpness examples.  This file
resolves, inside that framework, three of the conjectures that were left open:

* **C1 (transport of the whole exponent set).**  An invertible transform of a family of
  counting functions does not merely transfer one admissible exponent: it induces an
  *equality of joint exponent sets*, hence of joint optimal exponents
  (`jointExponentSet_transform`, `jointOptimalExponent_transform`).

* **C2 (a rank obstruction).**  The invertibility hypothesis is not an artefact of the proof.
  For a *singular* transform there are families whose transforms are exact and whose
  individual optimal exponents are arbitrarily large (`singular_transform_no_transfer`,
  `det_zero_no_transfer`), and in fact the transfer principle holds for a matrix `A`
  **iff** `det A ≠ 0` (`transfer_iff_det_ne_zero`).

* **C3 (log powers are invisible).**  `optimalExponent (M + K x^θ log^k x) M = θ` exactly
  (`optimalExponent_log_pow`): the `ε` in "`25/36 + ε`" hides log powers and nothing more.

* **C5 (a converse Chebotarev principle).**  If the class-counting functions dominate their
  main terms then the single aggregate estimate implies all the individual ones
  (`hasErrorExponent_of_nonneg_summands`, `chebotarev_converse`), and the positivity
  hypothesis cannot be dropped (`cancellation_counterexample`).

Supporting the above, the sharpness machinery of cycle 3 is upgraded from "growth for all
`x ≥ 1`" to "growth eventually", which is what genuine oscillation estimates provide.
-/

import Mathlib
import Catalog.Shared.ChebotarevGeodesic
import Catalog.Shared.ChebotarevGeodesicSharpness
import Catalog.Shared.ChebotarevGeodesicOptimal

open Finset Filter Set
open scoped Topology

namespace ChebotarevGeodesic

/-! ## 0.  Robustness of the exponent predicate -/

/-- A counting function is its own main term with any exponent.  (Used to produce exact
transforms in the obstruction below.) -/
theorem hasErrorExponent_self (π : ℝ → ℝ) (θ : ℝ) : HasErrorExponent π π θ := by
  intro ε hε
  refine ⟨1, one_pos, 1, le_rfl, fun x hx => ?_⟩
  have hx0 : (0 : ℝ) ≤ x ^ (θ + ε) := Real.rpow_nonneg (by linarith) _
  simpa using hx0

/-! ### Eventual growth suffices for sharpness

`not_hasErrorExponent_of_growth` requires the lower bound `c x^β ≤ |π − M|` for *all* `x ≥ 1`.
Oscillation estimates only ever hold for large `x`; we upgrade the three sharpness statements
accordingly. -/

/-- Sharpness from *eventual* growth: an error term that is eventually of size at least
`c x^β` rules out every exponent `θ < β`. -/
theorem not_hasErrorExponent_of_eventually_growth {π M : ℝ → ℝ} {θ β c : ℝ} (hc : 0 < c)
    (hlt : θ < β) (hgrow : ∀ᶠ x in atTop, c * x ^ β ≤ |π x - M x|) :
    ¬ HasErrorExponent π M θ := by
  intro h
  set ε := (β - θ) / 2 with hεdef
  have hε : 0 < ε := by rw [hεdef]; linarith
  obtain ⟨C, hC, X, hX, hb⟩ := h ε hε
  have hpos : 0 < β - (θ + ε) := by rw [hεdef]; linarith
  have hbig : Tendsto (fun x : ℝ => x ^ (β - (θ + ε))) atTop atTop := tendsto_rpow_atTop hpos
  obtain ⟨x, hxg, hx1, hxX, hxbig⟩ :
      ∃ x : ℝ, c * x ^ β ≤ |π x - M x| ∧ 1 ≤ x ∧ X ≤ x ∧ C / c < x ^ (β - (θ + ε)) := by
    obtain ⟨x, hx⟩ := (hgrow.and ((hbig.eventually_gt_atTop (C / c)).and
      ((eventually_ge_atTop (1 : ℝ)).and (eventually_ge_atTop X)))).exists
    exact ⟨x, hx.1, hx.2.2.1, hx.2.2.2, hx.2.1⟩
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx1
  have h1 : c * x ^ β ≤ C * x ^ (θ + ε) := le_trans hxg (hb x hxX)
  have hsplit : x ^ β = x ^ (β - (θ + ε)) * x ^ (θ + ε) := by
    rw [← Real.rpow_add hx0]; ring_nf
  have hxe : (0 : ℝ) < x ^ (θ + ε) := Real.rpow_pos_of_pos hx0 _
  rw [hsplit] at h1
  have h2 : c * x ^ (β - (θ + ε)) ≤ C :=
    le_of_mul_le_mul_right (by rw [mul_assoc]; exact h1) hxe
  rw [div_lt_iff₀ hc] at hxbig
  nlinarith

/-- Eventual growth of size `x^β` bounds the exponent set from below by `β`. -/
theorem bddBelow_exponentSet_of_eventually_growth {π M : ℝ → ℝ} {β c : ℝ} (hc : 0 < c)
    (hgrow : ∀ᶠ x in atTop, c * x ^ β ≤ |π x - M x|) :
    BddBelow (exponentSet π M) := by
  refine ⟨β, fun θ hθ => ?_⟩
  by_contra hlt
  push_neg at hlt
  exact not_hasErrorExponent_of_eventually_growth hc hlt hgrow hθ

/-- Eventual growth of size `x^β` forces `optimalExponent ≥ β`. -/
theorem le_optimalExponent_of_eventually_growth {π M : ℝ → ℝ} {β c : ℝ} (hc : 0 < c)
    (hne : (exponentSet π M).Nonempty)
    (hgrow : ∀ᶠ x in atTop, c * x ^ β ≤ |π x - M x|) :
    β ≤ optimalExponent π M := by
  by_contra hlt
  push_neg at hlt
  exact not_hasErrorExponent_of_eventually_growth hc hlt hgrow
    (hasErrorExponent_optimalExponent π M hne)

/-- **Bracketing from eventual growth.** -/
theorem optimalExponent_eq_of_eventually_growth {π M : ℝ → ℝ} {β c : ℝ} (hc : 0 < c)
    (hgrow : ∀ᶠ x in atTop, c * x ^ β ≤ |π x - M x|)
    (hupper : HasErrorExponent π M β) :
    optimalExponent π M = β :=
  le_antisymm
    (optimalExponent_le_of_hasErrorExponent
      (bddBelow_exponentSet_of_eventually_growth hc hgrow) hupper)
    (le_optimalExponent_of_eventually_growth hc ⟨β, hupper⟩ hgrow)

/-! ## 1.  C1: an invertible transform transports the whole exponent set -/

section Transform

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The linear transform of a family of counting functions by a matrix (a "character
table"): `(A · f) j (x) = ∑ i A j i · f i (x)`. -/
def transform (A : Matrix ι ι ℝ) (f : ι → ℝ → ℝ) (j : ι) : ℝ → ℝ :=
  fun x => ∑ i, A j i * f i x

omit [DecidableEq ι] in
/-- Transforms inherit a common exponent — the easy direction, valid for every matrix. -/
theorem hasErrorExponent_transform (A : Matrix ι ι ℝ) (f M : ι → ℝ → ℝ) (θ : ℝ)
    (h : ∀ i, HasErrorExponent (f i) (M i) θ) (j : ι) :
    HasErrorExponent (transform A f j) (transform A M j) θ :=
  HasErrorExponent.linear_comb Finset.univ (fun i => A j i) f M θ fun i _ => h i

/-- **Transfer principle.**  For an invertible transform, the family satisfies the estimate
with exponent `θ` if and only if all of its transforms do. -/
theorem hasErrorExponent_transform_iff {A B : Matrix ι ι ℝ} (hBA : B * A = 1)
    (f M : ι → ℝ → ℝ) (θ : ℝ) :
    (∀ j, HasErrorExponent (transform A f j) (transform A M j) θ) ↔
      ∀ i, HasErrorExponent (f i) (M i) θ :=
  ⟨fun h i => exponent_of_inverse_transform A B hBA f M θ (fun j => h j) i,
    fun h j => hasErrorExponent_transform A f M θ h j⟩

/-- The set of exponents admissible for *every* member of a family. -/
def jointExponentSet (f M : ι → ℝ → ℝ) : Set ℝ := {θ | ∀ i, HasErrorExponent (f i) (M i) θ}

omit [Fintype ι] [DecidableEq ι] in
theorem jointExponentSet_eq_iInter (f M : ι → ℝ → ℝ) :
    jointExponentSet f M = ⋂ i, exponentSet (f i) (M i) := by
  ext θ
  simp [jointExponentSet, exponentSet, Set.mem_iInter]

omit [Fintype ι] [DecidableEq ι] in
/-- The joint exponent set is an upper set. -/
theorem isUpperSet_jointExponentSet (f M : ι → ℝ → ℝ) : IsUpperSet (jointExponentSet f M) :=
  fun _ _ hle h i => (h i).mono hle

/-- **C1, set form.**  An invertible transform preserves the joint exponent set exactly:
the exponent data is an invariant of the family up to invertible linear change. -/
theorem jointExponentSet_transform {A B : Matrix ι ι ℝ} (hBA : B * A = 1) (f M : ι → ℝ → ℝ) :
    jointExponentSet (transform A f) (transform A M) = jointExponentSet f M := by
  ext θ
  exact hasErrorExponent_transform_iff hBA f M θ

/-- The infimal exponent valid for the whole family. -/
noncomputable def jointOptimalExponent (f M : ι → ℝ → ℝ) : ℝ := sInf (jointExponentSet f M)

/-- **C1, numerical form.**  The joint optimal exponent is invariant under an invertible
transform.  In the geometric setting: the record exponent does not depend on whether one
counts geodesics class by class or through the split-case (character-twisted) counting
functions. -/
theorem jointOptimalExponent_transform {A B : Matrix ι ι ℝ} (hBA : B * A = 1)
    (f M : ι → ℝ → ℝ) :
    jointOptimalExponent (transform A f) (transform A M) = jointOptimalExponent f M := by
  unfold jointOptimalExponent
  rw [jointExponentSet_transform hBA]

/-! ## 2.  C2: the rank obstruction -/

omit [DecidableEq ι] in
/-- **C2.**  If `v` is a nonzero kernel vector of the transform `A`, then perturbing a family
by `v · x^β` changes nothing after transforming, while destroying every exponent below `β`
for each index where `v` does not vanish.  So a singular transform can carry *no* information
about individual exponents. -/
theorem singular_transform_no_transfer (A : Matrix ι ι ℝ) (v : ι → ℝ)
    (hv : A.mulVec v = 0) (M : ι → ℝ → ℝ) {θ β : ℝ} (hθβ : θ < β) {i : ι} (hvi : v i ≠ 0) :
    ∃ f : ι → ℝ → ℝ,
      (∀ j, HasErrorExponent (transform A f j) (transform A M j) θ) ∧
      ¬ HasErrorExponent (f i) (M i) θ := by
  refine ⟨fun k x => M k x + v k * x ^ β, fun j => ?_, ?_⟩
  · have hz : ∑ k, A j k * v k = 0 := by
      have := congrFun hv j
      simpa [Matrix.mulVec, dotProduct] using this
    have e : transform A (fun k x => M k x + v k * x ^ β) j = transform A M j := by
      funext x
      have hsplit : ∑ k, A j k * (M k x + v k * x ^ β)
          = (∑ k, A j k * M k x) + (∑ k, A j k * v k) * x ^ β := by
        rw [Finset.sum_mul, ← Finset.sum_add_distrib]
        exact Finset.sum_congr rfl fun k _ => by ring
      simp only [transform]
      rw [hsplit, hz, zero_mul, add_zero]
    rw [e]
    exact hasErrorExponent_self _ _
  · refine not_hasErrorExponent_of_growth (c := |v i|) (β := β) (abs_pos.mpr hvi) hθβ ?_
    intro x hx
    have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx
    have hxβ : (0 : ℝ) ≤ x ^ β := (Real.rpow_pos_of_pos hx0 β).le
    have heq : M i x + v i * x ^ β - M i x = v i * x ^ β := by ring
    show |v i| * x ^ β ≤ |M i x + v i * x ^ β - M i x|
    rw [heq, abs_mul, abs_of_nonneg hxβ]

/-- The determinantal form of the obstruction: a singular transform always admits such a
counterexample. -/
theorem det_zero_no_transfer (A : Matrix ι ι ℝ) (hdet : A.det = 0) (M : ι → ℝ → ℝ)
    {θ β : ℝ} (hθβ : θ < β) :
    ∃ (i : ι) (f : ι → ℝ → ℝ),
      (∀ j, HasErrorExponent (transform A f j) (transform A M j) θ) ∧
      ¬ HasErrorExponent (f i) (M i) θ := by
  obtain ⟨v, hv0, hv⟩ := Matrix.exists_mulVec_eq_zero_iff.mpr hdet
  obtain ⟨i, hvi⟩ := Function.ne_iff.mp hv0
  obtain ⟨f, hf, hnf⟩ := singular_transform_no_transfer A v hv M hθβ (i := i) hvi
  exact ⟨i, f, hf, hnf⟩

/-- **Sharp form of the reduction lemma.**  The paper's mechanism — deduce the individual
(non-split) estimates from the transformed (split) ones — is available for the transform `A`
*exactly* when `A` is invertible.  Both directions are non-trivial: invertibility gives the
transfer, and singularity produces an explicit family defeating it. -/
theorem transfer_iff_det_ne_zero (A : Matrix ι ι ℝ) (M : ι → ℝ → ℝ) {θ β : ℝ} (hθβ : θ < β) :
    (∀ f : ι → ℝ → ℝ, (∀ j, HasErrorExponent (transform A f j) (transform A M j) θ) →
        ∀ i, HasErrorExponent (f i) (M i) θ) ↔ A.det ≠ 0 := by
  constructor
  · intro h hdet
    obtain ⟨i, f, hf, hnf⟩ := det_zero_no_transfer A hdet M hθβ
    exact hnf (h f hf i)
  · intro hdet f hf i
    have hunit : IsUnit A.det := isUnit_iff_ne_zero.mpr hdet
    exact (hasErrorExponent_transform_iff (A := A) (B := A⁻¹)
      (Matrix.nonsing_inv_mul A hunit) f M θ).mp hf i

end Transform

/-! ## 3.  C3: powers of the logarithm do not move the optimal exponent -/

/-- **C3.**  An error term `K x^θ (log x)^k` has optimal exponent exactly `θ`, for every
`k`.  Hence all the information hidden by the `ε` in "exponent `25/36 + ε`" is log-power
data: the exponent itself is unaffected. -/
theorem optimalExponent_log_pow (M : ℝ → ℝ) {K θ : ℝ} (hK : 0 < K) (k : ℕ) :
    optimalExponent (fun x => M x + K * x ^ θ * (Real.log x) ^ k) M = θ := by
  have hupper : HasErrorExponent (fun x => M x + K * x ^ θ * (Real.log x) ^ k) M θ := by
    refine hasErrorExponent_of_log_pow_bound (K := K) (k := k) hK.le fun x hx => ?_
    have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx
    have hlog : 0 ≤ Real.log x := Real.log_nonneg hx
    have hxθ : (0 : ℝ) < x ^ θ := Real.rpow_pos_of_pos hx0 θ
    have heq : M x + K * x ^ θ * (Real.log x) ^ k - M x = K * x ^ θ * (Real.log x) ^ k := by
      ring
    rw [heq, abs_of_nonneg (by positivity)]
  have hgrow : ∀ᶠ x in atTop,
      K * x ^ θ ≤ |(M x + K * x ^ θ * (Real.log x) ^ k) - M x| := by
    filter_upwards [eventually_ge_atTop (Real.exp 1)] with x hx
    have hx0 : (0 : ℝ) < x := lt_of_lt_of_le (Real.exp_pos 1) hx
    have hlog : 1 ≤ Real.log x := (Real.le_log_iff_exp_le hx0).mpr hx
    have hlk : 1 ≤ (Real.log x) ^ k := one_le_pow₀ hlog
    have hxθ : (0 : ℝ) < x ^ θ := Real.rpow_pos_of_pos hx0 θ
    have heq : M x + K * x ^ θ * (Real.log x) ^ k - M x = K * x ^ θ * (Real.log x) ^ k := by
      ring
    rw [heq, abs_of_nonneg (by positivity)]
    have hKx : (0 : ℝ) ≤ K * x ^ θ := by positivity
    calc K * x ^ θ = K * x ^ θ * 1 := by ring
      _ ≤ K * x ^ θ * (Real.log x) ^ k := mul_le_mul_of_nonneg_left hlk hKx
  exact optimalExponent_eq_of_eventually_growth hK hgrow hupper

/-- The record exponent survives the log powers produced by a trace formula: the error term
`x^{25/36} (log x)^k` has optimal exponent exactly `25/36`. -/
theorem optimalExponent_log_pow_25_36 (k : ℕ) :
    optimalExponent (fun x : ℝ => x ^ ((25 : ℝ) / 36) * (Real.log x) ^ k) (fun _ => 0)
      = 25 / 36 := by
  have e : (fun x : ℝ => x ^ ((25 : ℝ) / 36) * (Real.log x) ^ k)
      = fun x : ℝ => (fun _ : ℝ => (0 : ℝ)) x + 1 * x ^ ((25 : ℝ) / 36) * (Real.log x) ^ k := by
    funext x; ring
  rw [e]
  exact optimalExponent_log_pow _ one_pos k

/-! ## 4.  C5: a converse Chebotarev principle -/

/-- **C5, analytic core.**  A single estimate for a sum of *non-negatively deviating*
counting functions implies the estimate for each summand: non-negative summands cannot
cancel, so no individual error can exceed the aggregate one. -/
theorem hasErrorExponent_of_nonneg_summands {ι : Type*} (s : Finset ι) (f g : ι → ℝ → ℝ)
    (θ : ℝ) (hnn : ∀ i ∈ s, ∀ᶠ x in atTop, 0 ≤ f i x - g i x)
    (hsum : HasErrorExponent (fun x => ∑ i ∈ s, f i x) (fun x => ∑ i ∈ s, g i x) θ)
    {i : ι} (hi : i ∈ s) : HasErrorExponent (f i) (g i) θ := by
  intro ε hε
  obtain ⟨C, hC, X, hX, hb⟩ := hsum ε hε
  have hall : ∀ᶠ x in atTop, ∀ j ∈ s, 0 ≤ f j x - g j x :=
    (eventually_all_finset s).mpr hnn
  obtain ⟨X₀, hX₀⟩ := eventually_atTop.mp hall
  refine ⟨C, hC, max X (max X₀ 1),
    le_max_of_le_right (le_max_right _ _), fun x hx => ?_⟩
  have hxX : X ≤ x := le_trans (le_max_left _ _) hx
  have hxX₀ : X₀ ≤ x := le_trans (le_trans (le_max_left _ _) (le_max_right X _)) hx
  have hnn' : ∀ j ∈ s, 0 ≤ f j x - g j x := hX₀ x hxX₀
  have h1 : f i x - g i x ≤ ∑ j ∈ s, (f j x - g j x) := Finset.single_le_sum hnn' hi
  have h2 : ∑ j ∈ s, (f j x - g j x) = (∑ j ∈ s, f j x) - ∑ j ∈ s, g j x :=
    Finset.sum_sub_distrib (fun j => f j x) (fun j => g j x)
  have h3 : (∑ j ∈ s, f j x) - ∑ j ∈ s, g j x ≤ C * x ^ (θ + ε) :=
    le_trans (le_abs_self _) (hb x hxX)
  rw [h2] at h1
  rw [abs_of_nonneg (hnn' i hi)]
  linarith

/-- **C5, geometric form.**  If every class-counting function eventually dominates its
predicted main term `(|C|/|G|)·li`, then the prime geodesic theorem with exponent `θ` for the
total counting function already implies the full Chebotarev geodesic theorem with the same
exponent: the implication `prime_geodesic_of_chebotarev` can be reversed under positivity. -/
theorem chebotarev_converse (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    [Fintype (ConjClasses G)] (piC : ConjClasses G → ℝ → ℝ) (li : ℝ → ℝ) (θ : ℝ)
    (hnn : ∀ C, ∀ᶠ x in atTop, classDensity G C * li x ≤ piC C x)
    (hsum : HasErrorExponent (fun x => ∑ C : ConjClasses G, piC C x) li θ)
    (C : ConjClasses G) :
    HasErrorExponent (piC C) (fun x => classDensity G C * li x) θ := by
  classical
  have e : (fun x => ∑ _C : ConjClasses G, classDensity G _C * li x) = li := by
    funext x
    rw [← Finset.sum_mul, sum_classDensity G, one_mul]
  have hsum' : HasErrorExponent (fun x => ∑ C : ConjClasses G, piC C x)
      (fun x => ∑ C : ConjClasses G, classDensity G C * li x) θ := by
    rw [e]; exact hsum
  refine hasErrorExponent_of_nonneg_summands Finset.univ piC
    (fun C x => classDensity G C * li x) θ (fun D _ => ?_) hsum' (Finset.mem_univ C)
  filter_upwards [hnn D] with x hx
  linarith

/-- **The positivity hypothesis in `chebotarev_converse` is necessary.**  Two counting
functions whose errors are `+x^β` and `−x^β` have a perfect sum, yet neither satisfies any
estimate with exponent `θ < β`.  So the converse principle genuinely needs one-sided
deviations. -/
theorem cancellation_counterexample {θ β : ℝ} (hθβ : θ < β) :
    ∃ f g : Fin 2 → ℝ → ℝ,
      HasErrorExponent (fun x => ∑ i, f i x) (fun x => ∑ i, g i x) θ ∧
      ¬ HasErrorExponent (f 0) (g 0) θ ∧ ¬ HasErrorExponent (f 1) (g 1) θ := by
  refine ⟨![fun x => x ^ β, fun x => -(x ^ β)], ![fun _ => 0, fun _ => 0], ?_, ?_, ?_⟩
  · have e₁ : (fun x : ℝ => ∑ i, (![fun x : ℝ => x ^ β, fun x : ℝ => -(x ^ β)] : Fin 2 → ℝ → ℝ) i x)
        = fun _ : ℝ => (0 : ℝ) := by
      funext x
      simp [Fin.sum_univ_two]
    have e₂ : (fun x : ℝ => ∑ i, (![fun _ : ℝ => (0:ℝ), fun _ : ℝ => (0:ℝ)] : Fin 2 → ℝ → ℝ) i x)
        = fun _ : ℝ => (0 : ℝ) := by
      funext x
      simp [Fin.sum_univ_two]
    rw [e₁, e₂]
    exact hasErrorExponent_self _ _
  · refine not_hasErrorExponent_of_growth (c := 1) (β := β) one_pos hθβ fun x hx => ?_
    have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx
    have hxβ : (0 : ℝ) ≤ x ^ β := (Real.rpow_pos_of_pos hx0 β).le
    simp [abs_of_nonneg hxβ]
  · refine not_hasErrorExponent_of_growth (c := 1) (β := β) one_pos hθβ fun x hx => ?_
    have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx
    have hxβ : (0 : ℝ) ≤ x ^ β := (Real.rpow_pos_of_pos hx0 β).le
    simp [abs_of_nonneg hxβ]

/-! ## 5.  Synthesis for the setting of the paper -/

/-- **Synthesis.**  Fix a finite Galois group `G` of a cover of the geodesic space, and assume
the class-counting functions dominate their main terms (which is the case for the counting
functions of the paper up to an admissible error).  Then the following are equivalent:
the Chebotarev geodesic theorem with exponent `25/36` for every class, and the prime geodesic
theorem with exponent `25/36` for the total counting function.  Consequently the two
statements of the abstract are not merely related by an implication — they carry exactly the
same analytic content. -/
theorem chebotarev_iff_prime_geodesic_25_36 (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    [Fintype (ConjClasses G)] (piC : ConjClasses G → ℝ → ℝ) (li : ℝ → ℝ)
    (hnn : ∀ C, ∀ᶠ x in atTop, classDensity G C * li x ≤ piC C x) :
    (∀ C, HasErrorExponent (piC C) (fun x => classDensity G C * li x) (25 / 36)) ↔
      HasErrorExponent (fun x => ∑ C : ConjClasses G, piC C x) li (25 / 36) :=
  ⟨fun h => prime_geodesic_of_chebotarev G piC li (25 / 36) h,
    fun h C => chebotarev_converse G piC li (25 / 36) hnn h C⟩


/-! ## 6.  C4: a quantitative equidistribution rate -/

/-- **Quantitative ratio estimate.**  If a partial counting function satisfies
`piS = d·li + O(x^{θ+ε})`, the total one satisfies `pi = li + O(x^{θ+ε})`, and the main term
grows at least like `c x^β` with `β > θ`, then the *ratio* converges to the density `d` at the
rate `x^{θ−β+ε}`.  This upgrades the qualitative limit `chebotarev_natural_density` to an
effective statement, and shows the only way the group enters the implied constant is through
the density `d`. -/
theorem hasErrorExponent_ratio {piS pit li : ℝ → ℝ} {d θ β c : ℝ} (hc : 0 < c) (hθβ : θ < β)
    (hli : ∀ᶠ x in atTop, c * x ^ β ≤ li x)
    (hS : HasErrorExponent piS (fun x => d * li x) θ)
    (htot : HasErrorExponent pit li θ) :
    HasErrorExponent (fun x => piS x / pit x) (fun _ => d) (θ - β) := by
  intro ε hε
  set ε₀ := min ε ((β - θ) / 2) with hε₀def
  have hε₀ : 0 < ε₀ := lt_min hε (by linarith)
  have hε₀le : ε₀ ≤ ε := min_le_left _ _
  have hlt : θ + ε₀ < β := by
    have h := min_le_right ε ((β - θ) / 2)
    rw [← hε₀def] at h
    linarith
  obtain ⟨C₁, hC₁, X₁, hX₁, hb₁⟩ := hS ε₀ hε₀
  obtain ⟨C₂, hC₂, X₂, hX₂, hb₂⟩ := htot ε₀ hε₀
  have hδ : 0 < β - (θ + ε₀) := by linarith
  have hbig : Tendsto (fun x : ℝ => x ^ (-(β - (θ + ε₀)))) atTop (𝓝 0) :=
    tendsto_rpow_neg_atTop hδ
  have hev := hbig.eventually (gt_mem_nhds (show (0 : ℝ) < c / (2 * C₂) by positivity))
  have hden : ∀ᶠ x in atTop, c / 2 * x ^ β ≤ pit x := by
    filter_upwards [hli, hev, eventually_ge_atTop X₂, eventually_gt_atTop (0 : ℝ)]
      with x hlix hxlt hxX₂ hx0
    have hsplit : x ^ (θ + ε₀) = x ^ (-(β - (θ + ε₀))) * x ^ β := by
      rw [← Real.rpow_add hx0]; ring_nf
    have hxβ : (0 : ℝ) < x ^ β := Real.rpow_pos_of_pos hx0 β
    have hkey : C₂ * x ^ (-(β - (θ + ε₀))) ≤ c / 2 := by
      calc C₂ * x ^ (-(β - (θ + ε₀))) ≤ C₂ * (c / (2 * C₂)) :=
            mul_le_mul_of_nonneg_left hxlt.le hC₂.le
        _ = c / 2 := by field_simp
    have h1 : |pit x - li x| ≤ C₂ * x ^ (θ + ε₀) := hb₂ x hxX₂
    have h2 : li x - pit x ≤ C₂ * x ^ (θ + ε₀) := by linarith [(abs_le.mp h1).1]
    have h3 : C₂ * x ^ (θ + ε₀) ≤ c / 2 * x ^ β := by
      rw [hsplit]
      calc C₂ * (x ^ (-(β - (θ + ε₀))) * x ^ β)
          = (C₂ * x ^ (-(β - (θ + ε₀)))) * x ^ β := by ring
        _ ≤ (c / 2) * x ^ β := mul_le_mul_of_nonneg_right hkey hxβ.le
    linarith
  obtain ⟨X₃, hX₃⟩ := eventually_atTop.mp hden
  refine ⟨2 * (C₁ + |d| * C₂) / c + 1, by positivity, max (max X₁ X₂) (max X₃ 1),
    le_max_of_le_right (le_max_right _ _), fun x hx => ?_⟩
  have hxX₁ : X₁ ≤ x := le_trans (le_trans (le_max_left _ _) (le_max_left _ _)) hx
  have hxX₂ : X₂ ≤ x := le_trans (le_trans (le_max_right _ _) (le_max_left _ _)) hx
  have hxX₃ : X₃ ≤ x := le_trans (le_trans (le_max_left _ _) (le_max_right _ _)) hx
  have hx1 : (1 : ℝ) ≤ x := le_trans (le_trans (le_max_right _ _) (le_max_right _ _)) hx
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx1
  have hxβ : (0 : ℝ) < x ^ β := Real.rpow_pos_of_pos hx0 β
  have hxe : (0 : ℝ) < x ^ (θ + ε₀) := Real.rpow_pos_of_pos hx0 _
  have hpi : c / 2 * x ^ β ≤ pit x := hX₃ x hxX₃
  have hpipos : 0 < pit x := lt_of_lt_of_le (by positivity) hpi
  have hnum : |piS x - d * pit x| ≤ (C₁ + |d| * C₂) * x ^ (θ + ε₀) := by
    have e : piS x - d * pit x = (piS x - d * li x) - d * (pit x - li x) := by ring
    calc |piS x - d * pit x| = |(piS x - d * li x) - d * (pit x - li x)| := by rw [e]
      _ ≤ |piS x - d * li x| + |d * (pit x - li x)| := abs_sub _ _
      _ ≤ C₁ * x ^ (θ + ε₀) + |d| * (C₂ * x ^ (θ + ε₀)) := by
          rw [abs_mul]
          exact add_le_add (hb₁ x hxX₁)
            (mul_le_mul_of_nonneg_left (hb₂ x hxX₂) (abs_nonneg d))
      _ = (C₁ + |d| * C₂) * x ^ (θ + ε₀) := by ring
  have he : piS x / pit x - d = (piS x - d * pit x) / pit x := by
    field_simp
  show |piS x / pit x - d| ≤ (2 * (C₁ + |d| * C₂) / c + 1) * x ^ (θ - β + ε)
  rw [he, abs_div, abs_of_pos hpipos]
  have hstep : |piS x - d * pit x| / pit x
      ≤ ((C₁ + |d| * C₂) * x ^ (θ + ε₀)) / (c / 2 * x ^ β) := by
    have hposden : (0 : ℝ) < c / 2 * x ^ β := by positivity
    gcongr
  have hcalc : ((C₁ + |d| * C₂) * x ^ (θ + ε₀)) / (c / 2 * x ^ β)
      = (2 * (C₁ + |d| * C₂) / c) * x ^ (θ + ε₀ - β) := by
    rw [Real.rpow_sub hx0]
    field_simp
  have hmono : x ^ (θ + ε₀ - β) ≤ x ^ (θ - β + ε) :=
    Real.rpow_le_rpow_of_exponent_le hx1 (by linarith)
  have hcoef : (0 : ℝ) ≤ 2 * (C₁ + |d| * C₂) / c := by positivity
  have hlast : (2 * (C₁ + |d| * C₂) / c) * x ^ (θ + ε₀ - β)
      ≤ (2 * (C₁ + |d| * C₂) / c + 1) * x ^ (θ - β + ε) := by
    have hxp : (0 : ℝ) ≤ x ^ (θ - β + ε) := (Real.rpow_pos_of_pos hx0 _).le
    calc (2 * (C₁ + |d| * C₂) / c) * x ^ (θ + ε₀ - β)
        ≤ (2 * (C₁ + |d| * C₂) / c) * x ^ (θ - β + ε) :=
          mul_le_mul_of_nonneg_left hmono hcoef
      _ ≤ (2 * (C₁ + |d| * C₂) / c + 1) * x ^ (θ - β + ε) := by nlinarith
  calc |piS x - d * pit x| / pit x
      ≤ ((C₁ + |d| * C₂) * x ^ (θ + ε₀)) / (c / 2 * x ^ β) := hstep
    _ = (2 * (C₁ + |d| * C₂) / c) * x ^ (θ + ε₀ - β) := hcalc
    _ ≤ (2 * (C₁ + |d| * C₂) / c + 1) * x ^ (θ - β + ε) := hlast

open scoped Classical in
/-- **C4.**  Effective Chebotarev equidistribution: under the class-wise estimates with
exponent `θ` and a main term of size at least `c x^β`, the proportion of geodesics whose
Frobenius class lies in `S` approaches `∑_{C ∈ S} |C|/|G|` with error exponent `θ − β`.  For
the paper's data (`θ = 25/36`, `β` just below `1`) this is a saving of a power of `x`. -/
theorem chebotarev_density_rate (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    [Fintype (ConjClasses G)] (S : Finset (ConjClasses G)) (piC : ConjClasses G → ℝ → ℝ)
    (li : ℝ → ℝ) {θ β c : ℝ} (hc : 0 < c) (hθβ : θ < β)
    (hli : ∀ᶠ x in atTop, c * x ^ β ≤ li x)
    (h : ∀ C, HasErrorExponent (piC C) (fun x => classDensity G C * li x) θ) :
    HasErrorExponent (fun x => (∑ C ∈ S, piC C x) / (∑ C : ConjClasses G, piC C x))
      (fun _ => ∑ C ∈ S, classDensity G C) (θ - β) := by
  classical
  have hS : HasErrorExponent (fun x => ∑ C ∈ S, piC C x)
      (fun x => (∑ C ∈ S, classDensity G C) * li x) θ := by
    have := HasErrorExponent.sum S piC (fun C x => classDensity G C * li x) θ fun C _ => h C
    have e : (fun x => ∑ C ∈ S, classDensity G C * li x)
        = fun x => (∑ C ∈ S, classDensity G C) * li x := by
      funext x; rw [Finset.sum_mul]
    rwa [e] at this
  exact hasErrorExponent_ratio hc hθβ hli hS (prime_geodesic_of_chebotarev G piC li θ h)

end ChebotarevGeodesic