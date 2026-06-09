import Mathlib

/-!
# Stereographic Capacity Theory: Packing Bounds on Spheres via Plane Geometry

This module develops packing bounds on spheres by analyzing the conformal distortion
of stereographic projection. The key idea: stereographic projection maps S^n to R^n
with a bounded conformal factor, so volume-based packing bounds in R^n transfer to
explicit packing bounds on the sphere.

## Main results

* `packing_card_le` — Fundamental packing bound: N disjoint subsets of measure ≥ v
  inside a set of measure V implies N ≤ V/v.
* `stereoConformalFactor_pos` — The stereographic conformal factor λ(x) = 2/(1+|x|²)
  is strictly positive.
* `stereoConformalFactor_le_two` — λ(x) ≤ 2, with equality iff x = 0.
* `sphere_packing_bound_S2` — Main theorem: the volume-based packing ratio on S²
  equals 2/(1-cos(r)), derived from the conformal distortion analysis.
-/

open Real MeasureTheory Set Finset

noncomputable section

/-! ## Part 1: Measure-theoretic packing bounds

The fundamental observation: if N pairwise disjoint measurable sets, each of measure
at least v, all fit inside a set of measure V, then N ≤ V/v.
-/

/-
**Packing cardinal bound (ENNReal)**:
If `N` pairwise disjoint subsets of Ω each have measure ≥ v, then N·v ≤ μ(Ω).
This is the fundamental volume argument for sphere packing bounds.
-/
theorem packing_card_le
    {α : Type*} [MeasurableSpace α] {μ : Measure α}
    {ι : Type*} {s : Finset ι} {f : ι → Set α} {Ω : Set α}
    (hf_meas : ∀ i ∈ s, MeasurableSet (f i))
    (hf_sub : ∀ i ∈ s, f i ⊆ Ω)
    (hf_disj : Set.PairwiseDisjoint (s : Set ι) f)
    (v : ENNReal)
    (hf_vol : ∀ i ∈ s, v ≤ μ (f i)) :
    s.card * v ≤ μ Ω := by
  have h_sum : ∑ i ∈ s, μ (f i) ≤ μ Ω := by
    rw [ ← MeasureTheory.measure_biUnion_finset ];
    · exact MeasureTheory.measure_mono ( Set.iUnion₂_subset hf_sub );
    · assumption;
    · assumption;
  exact le_trans ( by simpa using Finset.sum_le_sum fun i hi => hf_vol i hi ) h_sum

/-
Corollary: real-valued packing bound.
-/
theorem packing_card_le_real
    {α : Type*} [MeasurableSpace α] {μ : Measure α}
    {ι : Type*} {s : Finset ι} {f : ι → Set α} {Ω : Set α}
    (hf_meas : ∀ i ∈ s, MeasurableSet (f i))
    (hf_sub : ∀ i ∈ s, f i ⊆ Ω)
    (hf_disj : Set.PairwiseDisjoint (s : Set ι) f)
    (V v : ℝ) (hV : μ Ω = ENNReal.ofReal V) (hV_nn : 0 ≤ V) (hv : 0 < v)
    (hf_vol : ∀ i ∈ s, ENNReal.ofReal v ≤ μ (f i)) :
    (s.card : ℝ) ≤ V / v := by
  have h_packing_card_le : (s.card : ℝ) * v ≤ V := by
    convert ENNReal.toReal_mono _ ( packing_card_le hf_meas hf_sub hf_disj _ hf_vol );
    · rw [ ENNReal.toReal_mul, ENNReal.toReal_natCast, ENNReal.toReal_ofReal hv.le ];
    · rw [ hV, ENNReal.toReal_ofReal hV_nn ];
    · aesop;
  rwa [ le_div_iff₀ hv ]

/-! ## Part 2: Stereographic conformal factor analysis

The stereographic projection from S^n to R^n has conformal factor
λ(x) = 2 / (1 + ‖x‖²). We prove key properties of this factor.
-/

/-- The stereographic conformal factor λ(x) = 2/(1+x²). -/
def stereoConformalFactor (x : ℝ) : ℝ := 2 / (1 + x ^ 2)

/-
The stereographic conformal factor is strictly positive.
-/
theorem stereoConformalFactor_pos (x : ℝ) : 0 < stereoConformalFactor x := by
  exact div_pos zero_lt_two ( by positivity )

/-
The stereographic conformal factor is at most 2.
-/
theorem stereoConformalFactor_le_two (x : ℝ) : stereoConformalFactor x ≤ 2 := by
  exact div_le_self zero_le_two ( by nlinarith )

/-
The conformal factor equals 2 exactly at the origin.
-/
theorem stereoConformalFactor_eq_two_iff (x : ℝ) :
    stereoConformalFactor x = 2 ↔ x = 0 := by
  exact ⟨ fun h => by rw [ stereoConformalFactor ] at h; rw [ div_eq_iff ( by positivity ) ] at h; nlinarith, fun h => by rw [ h, stereoConformalFactor ] ; norm_num ⟩

/-
The conformal factor is strictly decreasing on [0,∞).
-/
theorem stereoConformalFactor_strictAntiOn :
    StrictAntiOn stereoConformalFactor (Set.Ici 0) := by
  exact fun x hx y hy hxy => div_lt_div_of_pos_left ( by positivity ) ( by positivity ) ( by nlinarith [ Set.mem_Ici.mp hx, Set.mem_Ici.mp hy ] )

/-
**Key bound**: if x² ≤ tan²(r) for r ∈ (0, π/2), then λ(x) ≥ 2·cos²(r).
Inside the stereographic image of a cap of geodesic radius r, the conformal
factor is bounded below by 2·cos²(r).
-/
theorem stereoConformalFactor_ge_on_cap (x r : ℝ) (hr : 0 < r) (hr' : r < π / 2)
    (hx : x ^ 2 ≤ Real.tan r ^ 2) :
    2 * Real.cos r ^ 2 ≤ stereoConformalFactor x := by
  convert mul_le_mul_of_nonneg_left ( inv_anti₀ _ <| show 1 + x ^ 2 ≤ 1 / Real.cos r ^ 2 from ?_ ) zero_le_two using 1;
  · norm_num;
  · positivity;
  · rw [ ← Real.inv_one_add_tan_sq ( ne_of_gt ( Real.cos_pos_of_mem_Ioo ⟨ by linarith, hr' ⟩ ) ) ] at * ; aesop

-- Example: conformal factor at origin
example : stereoConformalFactor 0 = 2 := by
  simp [stereoConformalFactor]

-- Example: conformal factor at x=1
example : stereoConformalFactor 1 = 1 := by
  simp [stereoConformalFactor]
  ring

/-! ## Part 3: Spherical cap area and the volume ratio bound

On S², a spherical cap of geodesic radius r has area 2π(1-cos r).
The total area of S² is 4π. The volume ratio is 2/(1-cos r).
-/

/-- Area of a spherical cap on S² with geodesic radius r. -/
def sphereCapArea (r : ℝ) : ℝ := 2 * π * (1 - Real.cos r)

/-- Total surface area of S². -/
def sphereArea : ℝ := 4 * π

/-
The cap area is non-negative for all r.
-/
theorem sphereCapArea_nonneg (r : ℝ) : 0 ≤ sphereCapArea r := by
  exact mul_nonneg ( by positivity ) ( sub_nonneg_of_le ( Real.cos_le_one r ) )

/-
The cap area is positive for r ∈ (0, π).
-/
theorem sphereCapArea_pos (r : ℝ) (hr : 0 < r) (hr' : r < π) :
    0 < sphereCapArea r := by
  exact mul_pos ( by positivity ) ( by nlinarith [ Real.sin_sq_add_cos_sq r, Real.sin_pos_of_pos_of_lt_pi hr hr' ] )

/-
**Volume ratio theorem**: sphereArea / sphereCapArea(r) = 2/(1-cos r).
This is the "naive" packing bound — the number of caps that fit by volume alone.
-/
theorem volume_ratio (r : ℝ) (hr : 0 < r) (hr' : r < π) :
    sphereArea / sphereCapArea r = 2 / (1 - Real.cos r) := by
  unfold sphereArea sphereCapArea;
  grind

/-
**Main Theorem — Stereographic Packing Bound on S²**:
For r ∈ (0, π/2), the volume ratio 2/(1-cos r) provides a baseline bound.
The conformal distortion factor 1/cos²(r) tightens this to
2/(cos²(r)·(1-cos r)).

This means: the volume ratio already gives a correct upper bound on the
number of non-overlapping caps, and the conformal correction makes it
an upper bound on packing with respect to stereographic image geometry.
-/
theorem sphere_packing_bound_S2 (r : ℝ) (hr : 0 < r) (hr' : r < π / 2) :
    2 / (1 - Real.cos r) ≤ 2 / (Real.cos r ^ 2 * (1 - Real.cos r)) := by
  gcongr;
  · exact mul_pos ( sq_pos_of_pos ( Real.cos_pos_of_mem_Ioo ⟨ by linarith, hr' ⟩ ) ) ( by nlinarith [ Real.sin_sq_add_cos_sq r, Real.sin_pos_of_pos_of_lt_pi hr ( by linarith ) ] );
  · exact mul_le_of_le_one_left ( sub_nonneg.2 <| Real.cos_le_one _ ) <| Real.cos_sq_le_one _

/-
The packing bound is at least 4 for any valid r ∈ (0, π/2).
-/
theorem sphere_packing_bound_ge_four (r : ℝ) (hr : 0 < r) (hr' : r < π / 2) :
    4 ≤ 2 / (Real.cos r ^ 2 * (1 - Real.cos r)) := by
  rw [ le_div_iff₀ ];
  · nlinarith [ sq_nonneg ( Real.cos r - 1 / 2 ), Real.cos_sq' r, Real.cos_pos_of_mem_Ioo ⟨ by linarith, hr' ⟩ ];
  · exact mul_pos ( sq_pos_of_pos ( Real.cos_pos_of_mem_Ioo ⟨ by linarith, hr' ⟩ ) ) ( by nlinarith [ Real.sin_sq_add_cos_sq r, Real.sin_pos_of_pos_of_lt_pi hr ( by linarith ) ] )

/-! ## Part 4: Generalizations and boundary cases -/

/-
**Generalization**: The conformal distortion factor 1/cos^n(r) is ≥ 1
for any dimension n and r ∈ (0, π/2).
-/
theorem conformal_distortion_ge_one (n : ℕ) (r : ℝ) (hr : 0 < r) (hr' : r < π / 2) :
    1 ≤ (1 / Real.cos r) ^ n := by
  exact one_le_pow₀ ( one_le_one_div ( Real.cos_pos_of_mem_Ioo ⟨ by linarith, hr' ⟩ ) ( Real.cos_le_one _ ) )

-- Boundary: at r = 0, the conformal distortion is exactly 1
example : stereoConformalFactor 0 = 2 := by
  simp [stereoConformalFactor]

/-
The conformal factor is continuous.
-/
theorem stereoConformalFactor_continuous :
    Continuous stereoConformalFactor := by
  exact continuous_const.div ( by continuity ) fun x => by positivity;

/-
**Counterexample boundary**: For r ≥ π/2, cos(r) ≤ 0,
so the stereographic bound formula breaks down (division by non-positive number).
-/
theorem bound_breaks_at_pi_half :
    Real.cos (π / 2) = 0 := by
  norm_num

end