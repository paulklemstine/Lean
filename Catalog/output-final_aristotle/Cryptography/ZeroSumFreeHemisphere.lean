import Mathlib

/-!
# A bridge between additive combinatorics and the geometry/measure of the sphere

This file, motivated by Bukh's *zero-sum-free density* problem for the unit sphere
`S^{d-1} ⊆ ℝ^d`, proves a cross-domain *connector* result linking three areas:

* **Additive combinatorics** — the notion of a *zero-sum-free* set: a set none of whose
  nonempty finite sub-families sums to the zero vector.
* **Inner-product geometry / functional analysis** — *linear separation*: a set lying
  strictly on one side of a hyperplane through the origin.
* **Measure theory** — the *normalized surface measure* on the unit sphere.

The main results are:

* `isZeroSumFree_of_inner_pos` : linear separation implies zero-sum-freeness.  This is
  the combinatorics ↔ geometry bridge.
* `measure_half_of_involution` : an abstract measure-halving principle for a
  measure-preserving involution (measure theory).
* `hemisphere_toSphere_eq_half` : an **open hemisphere has exactly half the total
  surface measure** of the sphere.
* `exists_zeroSumFree_half_measure` : the synthesis — there is a measurable, zero-sum-free
  subset of the sphere whose surface measure is exactly half of the total.  This is the
  construction giving the lower bound `m_d ≥ 1/2` in Bukh's problem.

Bukh's conjecture that `1/2` is also an *upper* bound (i.e. `m_d = 1/2` exactly) is open
and is not proved here.
-/

open scoped InnerProductSpace Pointwise
open MeasureTheory Metric Set

namespace ZeroSumFreeHemisphere

/-! ## Part 1: the additive-combinatorics ↔ geometry bridge -/

section Bridge

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- A set `A` is *zero-sum-free* if no nonempty finite family of its elements sums to the
zero vector.  This is the standard notion from additive combinatorics, transported to a
vector space. -/
def IsZeroSumFree (A : Set E) : Prop :=
  ∀ (n : ℕ) (f : Fin n → E), 0 < n → (∀ i, f i ∈ A) → ∑ i, f i ≠ 0

/-
**Bridge lemma.**  If a set is *linearly separated*, i.e. lies strictly on the
positive side of the hyperplane `{x | ⟪x, v⟫ = 0}` for some `v`, then it is zero-sum-free.
This connects a geometric/functional-analytic hypothesis with an additive-combinatorial
conclusion.
-/
theorem isZeroSumFree_of_inner_pos {A : Set E} {v : E}
    (h : ∀ a ∈ A, 0 < inner ℝ a v) : IsZeroSumFree A := by
  intro n f hn hf;
  by_contra h_contra
  have h_inner : ⟪∑ i, f i, v⟫_ℝ = ∑ i, ⟪f i, v⟫_ℝ := by
    rw [ sum_inner ]
  have h_pos : 0 < ∑ i, ⟪f i, v⟫_ℝ := by
    exact Finset.sum_pos ( fun i _ => h _ ( hf i ) ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩
  have h_zero : ⟪∑ i, f i, v⟫_ℝ = 0 := by
    rw [ h_contra, inner_zero_left ]
  linarith [h_pos, h_zero]

end Bridge

/-! ## Part 2: an abstract measure-halving principle -/

/-
**Measure halving via an involution.**  If `T` preserves the measure `ν`, the set `H`
and its preimage `T ⁻¹' H` overlap on a null set, and together they cover all but a null
set, then `H` has exactly half the total measure.
-/
theorem measure_half_of_involution {X : Type*} [MeasurableSpace X]
    (ν : Measure X) {T : X → X} (hT : MeasurePreserving T ν ν)
    {H : Set X} (hHm : MeasurableSet H)
    (hdisj : ν (H ∩ T ⁻¹' H) = 0)
    (hcover : ν (H ∪ T ⁻¹' H)ᶜ = 0) :
    2 * ν H = ν Set.univ := by
  -- Since T is measure preserving, ν T ⁻¹' H = ν H.
  have hT_inv : ν (T ⁻¹' H) = ν H := by
    rw [ hT.measure_preimage ] ; aesop;
  have h_union : ν (H ∪ T ⁻¹' H) = ν H + ν (T ⁻¹' H) := by
    rw [ ← MeasureTheory.measure_union_add_inter H ( hT.measurable hHm ), hdisj, add_zero ];
  have h_union : ν (H ∪ T ⁻¹' H) = ν Set.univ := by
    rw [ MeasureTheory.measure_congr ] ; aesop;
  rw [ ← h_union, ‹ν ( H ∪ T ⁻¹' H ) = ν H + ν ( T ⁻¹' H ) ›, hT_inv, two_mul ]

/-! ## Part 3: the surface measure of an open hemisphere -/

section Sphere

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [MeasurableSpace E] [BorelSpace E] [FiniteDimensional ℝ E]

/-- The open hemisphere `{x ∈ S : ⟪x, v⟫ > 0}` as a subset of the unit sphere. -/
def openHemisphere (v : E) : Set (sphere (0 : E) 1) :=
  {x | 0 < inner ℝ (x : E) v}

/-
The open hemisphere is a measurable subset of the sphere (it is open).
-/
theorem measurableSet_openHemisphere (v : E) : MeasurableSet (openHemisphere v) := by
  refine' measurableSet_lt measurable_const _;
  fun_prop

/-
The kernel hyperplane `{z | ⟪z, v⟫ = 0}` has Haar measure zero (for `v ≠ 0`).
-/
theorem measure_inner_eq_zero (μ : Measure E) [μ.IsAddHaarMeasure] {v : E} (hv : v ≠ 0) :
    μ {z : E | inner ℝ z v = 0} = 0 := by
  convert MeasureTheory.Measure.addHaar_submodule _ _ _;
  any_goals exact LinearMap.ker ( innerₛₗ ℝ v );
  · simp +decide [ Set.ext_iff, innerₛₗ_apply_apply, real_inner_comm ];
  · infer_instance;
  · infer_instance;
  · infer_instance;
  · simp +decide [ Submodule.eq_top_iff' ];
    exact ⟨ v, by simp +decide [ hv ] ⟩

/-
The radial projection of the open hemisphere is the open half-ball on the positive
side of the hyperplane.
-/
omit [MeasurableSpace E] [BorelSpace E] [FiniteDimensional ℝ E] in
theorem radial_openHemisphere (v : E) :
    Set.Ioo (0 : ℝ) 1 • (Subtype.val '' openHemisphere v)
      = {z : E | ‖z‖ < 1 ∧ 0 < inner ℝ z v} := by
  refine' Set.ext fun x => ⟨ _, _ ⟩ <;> intro hx;
  · simp_all +decide;
    rcases hx with ⟨ t, ht, y, hy, rfl ⟩ ; simp_all +decide [ openHemisphere ];
    simp_all +decide [ norm_smul, inner_smul_left ];
    rw [ abs_of_pos ] <;> linarith;
  · refine' ⟨ ‖x‖, _, _ ⟩ <;> simp_all +decide [ openHemisphere ];
    · aesop;
    · refine' ⟨ ‖x‖⁻¹ • x, _, _ ⟩ <;> by_cases hx0 : x = 0 <;> simp_all +decide [ norm_smul, inner_smul_left ]

/-
The positive open half-ball has exactly half the volume of the unit ball.
-/
theorem measure_halfBall (μ : Measure E) [μ.IsAddHaarMeasure] {v : E} (hv : v ≠ 0) :
    2 * μ {z : E | ‖z‖ < 1 ∧ 0 < inner ℝ z v} = μ (ball 0 1) := by
  -- Let $P := {z | ‖z‖ < 1 ∧ 0 < ⟪z, v⟫_ℝ}$ and $N := {z | ‖z‖ < 1 ∧ ⟪z, v⟫_ℝ < 0}$.
  set P := {z : E | ‖z‖ < 1 ∧ 0 < ⟪z, v⟫_ℝ}
  set N := {z : E | ‖z‖ < 1 ∧ ⟪z, v⟫_ℝ < 0};
  -- By definition of $N$, we have $N = Neg.neg ⁻¹' P$.
  have hN : N = Neg.neg ⁻¹' P := by
    ext; aesop;
  -- Since $P$ and $N$ are disjoint and their union is the ball minus the equator, we have $\mu (ball 0 1) = \mu P + \mu N$.
  have h_union : μ (ball 0 1) = μ P + μ N := by
    rw [ ← MeasureTheory.measure_union₀ ];
    · rw [ MeasureTheory.measure_congr ];
      rw [ MeasureTheory.ae_eq_set ];
      constructor <;> rw [ MeasureTheory.measure_eq_zero_iff_ae_notMem ] <;> simp +decide;
      · filter_upwards [ MeasureTheory.measure_eq_zero_iff_ae_notMem.mp ( measure_inner_eq_zero μ hv ) ] with x hx hx' hx'' using ⟨ hx', lt_of_le_of_ne ( le_of_not_gt fun hx''' => hx'' ⟨ hx', hx''' ⟩ ) fun hx''' => hx <| by aesop ⟩;
      · exact Filter.Eventually.of_forall fun x hx => hx.elim ( fun hx => hx.1 ) fun hx => hx.1;
    · exact MeasurableSet.nullMeasurableSet ( by exact MeasurableSet.inter ( measurableSet_lt ( continuous_norm.measurable ) measurable_const ) ( measurableSet_lt ( show Measurable fun z : E => ⟪z, v⟫_ℝ from by exact Continuous.measurable ( by continuity ) ) measurable_const ) );
    · refine' MeasureTheory.measure_mono_null _ ( measure_inner_eq_zero μ hv );
      exact fun x hx => False.elim <| hx.1.2.not_gt hx.2.2;
  rw [ h_union, two_mul, hN ];
  rw [ ← MeasureTheory.measure_preimage_add_right ];
  swap;
  exacts [ 0, by simp +decide ]

/-
**An open hemisphere has exactly half of the total surface measure of the sphere.**
This is the measure-theoretic half of the connector, and gives `m_d ≥ 1/2`.
-/
theorem hemisphere_toSphere_eq_half (μ : Measure E) [μ.IsAddHaarMeasure] {v : E}
    (hv : v ≠ 0) :
    2 * μ.toSphere (openHemisphere v) = μ.toSphere Set.univ := by
  rw [ MeasureTheory.Measure.toSphere_apply' _ ( measurableSet_openHemisphere v ), MeasureTheory.Measure.toSphere_apply_univ _ ];
  rw [ ← mul_left_comm, ← measure_halfBall μ hv, radial_openHemisphere v ]

/-! ## Part 4: the synthesis -/

/-- **Connector theorem.**  There is a measurable subset of the unit sphere that is both
*zero-sum-free* (additive combinatorics) and has *exactly half the total surface measure*
(measure theory), namely an open hemisphere.  This realizes the lower bound `m_d ≥ 1/2` in
Bukh's zero-sum-free density problem. -/
theorem exists_zeroSumFree_half_measure (μ : Measure E) [μ.IsAddHaarMeasure] {v : E}
    (hv : v ≠ 0) :
    ∃ A : Set (sphere (0 : E) 1),
      MeasurableSet A ∧
      IsZeroSumFree (Subtype.val '' A) ∧
      2 * μ.toSphere A = μ.toSphere Set.univ := by
  refine ⟨openHemisphere v, measurableSet_openHemisphere v, ?_, hemisphere_toSphere_eq_half μ hv⟩
  apply isZeroSumFree_of_inner_pos (v := v)
  rintro a ⟨x, hx, rfl⟩
  exact hx

end Sphere

end ZeroSumFreeHemisphere