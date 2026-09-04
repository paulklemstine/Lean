/-
# The Bhattacharyya angle as a spherical metric

This file develops the *spherical* side of the Fisher–Rao picture opened in
`Algebra.FisherRaoLength.Core`.  The square-root map

  `p ↦ (√p₁, …, √pₙ)`

sends a probability vector to a unit vector of `EuclideanSpace ℝ ι`, and the
Bhattacharyya coefficient `BC(p,q) = ∑ᵢ √(pᵢ qᵢ)` is exactly the inner product
of the images.  Consequently the *Bhattacharyya angle* `arccos BC(p,q)` is the
`InnerProductGeometry.angle` of the two images, i.e. the geodesic distance of
the round sphere.

## Main results

* `FisherRao.angle_sphereEmb` — `angle (√p) (√q) = arccos (BC p q)`
* `FisherRao.arccos_bhattacharyya_triangle` — the Bhattacharyya angle satisfies
  the triangle inequality (it is a genuine metric on the simplex)
* `FisherRao.arccos_bhattacharyya_le_sum` — its iterated (path) version
* `FisherRao.chord_eq_two_mul_sin_half_arccos` — the exact chord/angle relation
  `‖√p − √q‖ = 2 sin(θ/2)`
* `FisherRao.chord_le_arccos_bhattacharyya` — chord ≤ angle
* `FisherRao.arccos_bhattacharyya_mul_sqrt_le` — the quantitative converse: a
  small chord forces a small angle, with the sharp constant
  `θ·√(1−(m/4)²) ≤ m/2` when the chord is `≤ m`.

These are the two-sided comparisons that drive the Riemann-sum convergence
theorem in `Pythagorean.BhattacharyyaRiemannConvergence`.
-/
import Algebra.FisherRaoLength.Core

open Finset Real InnerProductGeometry

namespace FisherRao

variable {ι : Type*} [Fintype ι]

/-! ## The square-root embedding into Euclidean space -/

/-- The square-root embedding of a probability vector into `EuclideanSpace ℝ ι`.
For probability vectors it lands on the unit sphere. -/
noncomputable def sphereEmb (p : ι → ℝ) : EuclideanSpace ℝ ι := WithLp.toLp 2 fun i => √(p i)

omit [Fintype ι] in
@[simp] theorem sphereEmb_ofLp (p : ι → ℝ) (i : ι) : (sphereEmb p).ofLp i = √(p i) := rfl

/-- The Bhattacharyya coefficient is the Euclidean inner product of the
square-root embeddings. -/
theorem inner_sphereEmb (p q : ι → ℝ) (hp : ∀ i, 0 ≤ p i) :
    inner ℝ (sphereEmb p) (sphereEmb q) = bhattacharyya p q := by
  simp only [PiLp.inner_apply, RCLike.inner_apply, conj_trivial, sphereEmb_ofLp, bhattacharyya]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [Real.sqrt_mul (hp i)]
  ring

/-- The square-root embedding of a probability vector is a unit vector. -/
theorem norm_sphereEmb (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hp1 : ∑ i, p i = 1) :
    ‖sphereEmb p‖ = 1 := by
  rw [EuclideanSpace.norm_eq]
  have : ∀ i ∈ (Finset.univ : Finset ι), ‖(sphereEmb p).ofLp i‖ ^ 2 = p i := by
    intro i _
    rw [sphereEmb_ofLp, Real.norm_eq_abs, sq_abs, Real.sq_sqrt (hp i)]
  rw [Finset.sum_congr rfl this, hp1, Real.sqrt_one]

/-- `BC (p, p) = 1` for a probability vector. -/
theorem bhattacharyya_self (p : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hp1 : ∑ i, p i = 1) :
    bhattacharyya p p = 1 := by
  rw [bhattacharyya, ← hp1]
  exact Finset.sum_congr rfl fun i _ => by
    rw [← sq, Real.sqrt_sq (hp i)]

/-- The Bhattacharyya coefficient is symmetric. -/
theorem bhattacharyya_comm (p q : ι → ℝ) : bhattacharyya p q = bhattacharyya q p :=
  Finset.sum_congr rfl fun i _ => by rw [mul_comm]

/-- `BC ≤ 1`: an instance of Cauchy–Schwarz on the sphere. -/
theorem bhattacharyya_le_one (p q : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i)
    (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1) : bhattacharyya p q ≤ 1 := by
  have h := sum_sub_sqrt_sq p q hp hq hp1 hq1
  have hnn : (0:ℝ) ≤ ∑ i, (√(p i) - √(q i)) ^ 2 := Finset.sum_nonneg fun i _ => sq_nonneg _
  linarith

/-- The Bhattacharyya angle is the spherical angle between the square-root
embeddings. -/
theorem angle_sphereEmb (p q : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i)
    (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1) :
    angle (sphereEmb p) (sphereEmb q) = arccos (bhattacharyya p q) := by
  have h : angle (sphereEmb p) (sphereEmb q)
      = arccos (inner ℝ (sphereEmb p) (sphereEmb q) / (‖sphereEmb p‖ * ‖sphereEmb q‖)) := rfl
  rw [h, inner_sphereEmb p q hp, norm_sphereEmb p hp hp1, norm_sphereEmb q hq hq1]
  norm_num

/-! ## The Bhattacharyya angle is a metric -/

/-- **Triangle inequality for the Bhattacharyya angle.**  The angle
`arccos BC` is the geodesic distance of the round sphere under the square-root
embedding, hence a metric on the simplex. -/
theorem arccos_bhattacharyya_triangle (p q r : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i) (hr : ∀ i, 0 ≤ r i)
    (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1) (hr1 : ∑ i, r i = 1) :
    arccos (bhattacharyya p r) ≤ arccos (bhattacharyya p q) + arccos (bhattacharyya q r) := by
  have h := angle_le_angle_add_angle (sphereEmb p) (sphereEmb q) (sphereEmb r)
  rwa [angle_sphereEmb p r hp hr hp1 hr1, angle_sphereEmb p q hp hq hp1 hq1,
    angle_sphereEmb q r hq hr hq1 hr1] at h

/-- **Path form of the triangle inequality.**  Along any finite path of
probability vectors the endpoint Bhattacharyya angle is at most the sum of the
consecutive angles. -/
theorem arccos_bhattacharyya_le_sum (P : ℕ → ι → ℝ)
    (hp : ∀ k i, 0 ≤ P k i) (hp1 : ∀ k, ∑ i, P k i = 1) (N : ℕ) :
    arccos (bhattacharyya (P 0) (P N))
      ≤ ∑ k ∈ Finset.range N, arccos (bhattacharyya (P k) (P (k + 1))) := by
  induction N with
  | zero =>
      simp [bhattacharyya_self (P 0) (hp 0) (hp1 0)]
  | succ n ih =>
      have htri := arccos_bhattacharyya_triangle (P 0) (P n) (P (n + 1))
        (hp 0) (hp n) (hp (n + 1)) (hp1 0) (hp1 n) (hp1 (n + 1))
      rw [Finset.sum_range_succ]
      linarith

/-- **Identity of indiscernibles.**  `BC(p,q) = 1` forces `p = q`. -/
theorem eq_of_bhattacharyya_eq_one {p q : ι → ℝ} (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i)
    (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1) (h : bhattacharyya p q = 1) : p = q := by
  have hsum := sum_sub_sqrt_sq p q hp hq hp1 hq1
  rw [h] at hsum
  have hzero : ∀ i ∈ (Finset.univ : Finset ι), (√(p i) - √(q i)) ^ 2 = 0 := by
    refine (Finset.sum_eq_zero_iff_of_nonneg fun i _ => sq_nonneg _).mp ?_
    rw [hsum]; norm_num
  funext i
  have hi : √(p i) = √(q i) := by
    have := hzero i (Finset.mem_univ i)
    nlinarith [this]
  have := congrArg (fun x : ℝ => x ^ 2) hi
  simpa [Real.sq_sqrt (hp i), Real.sq_sqrt (hq i)] using this

/-- The Bhattacharyya angle vanishes exactly on the diagonal: together with
symmetry and the triangle inequality this makes `arccos BC` a metric on the
simplex. -/
theorem arccos_bhattacharyya_eq_zero_iff {p q : ι → ℝ} (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i)
    (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1) :
    arccos (bhattacharyya p q) = 0 ↔ p = q := by
  constructor
  · intro h
    have h1 : 1 ≤ bhattacharyya p q := Real.arccos_eq_zero.mp h
    exact eq_of_bhattacharyya_eq_one hp hq hp1 hq1
      (le_antisymm (bhattacharyya_le_one p q hp hq hp1 hq1) h1)
  · rintro rfl
    rw [bhattacharyya_self p hp hp1, Real.arccos_one]

/-! ## Chord versus angle -/

/-- **Exact chord/angle relation.**  The Euclidean chord between the square-root
embeddings equals `2 sin(θ/2)`, where `θ = arccos BC` is the Bhattacharyya
angle. -/
theorem chord_eq_two_mul_sin_half_arccos (p q : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i) (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1) :
    √(∑ i, (√(p i) - √(q i)) ^ 2) = 2 * sin (arccos (bhattacharyya p q) / 2) := by
  set θ := arccos (bhattacharyya p q) with hθ
  have hb1 : bhattacharyya p q ≤ 1 := bhattacharyya_le_one p q hp hq hp1 hq1
  have hb0 : (0:ℝ) ≤ bhattacharyya p q := bhattacharyya_nonneg p q
  have hcos : cos θ = bhattacharyya p q := Real.cos_arccos (by linarith) hb1
  have hθ0 : 0 ≤ θ := Real.arccos_nonneg _
  have hθπ : θ ≤ π := Real.arccos_le_pi _
  have hhalf : 0 ≤ sin (θ / 2) := by
    refine Real.sin_nonneg_of_nonneg_of_le_pi (by linarith) ?_
    linarith [Real.pi_pos]
  have hdouble : cos θ = 1 - 2 * sin (θ / 2) ^ 2 := by
    have key : cos (2 * (θ / 2)) = 1 - 2 * sin (θ / 2) ^ 2 := by
      rw [Real.cos_two_mul]
      nlinarith [Real.sin_sq_add_cos_sq (θ / 2)]
    rw [show (2:ℝ) * (θ / 2) = θ by ring] at key
    exact key
  have hsum := sum_sub_sqrt_sq p q hp hq hp1 hq1
  have : ∑ i, (√(p i) - √(q i)) ^ 2 = (2 * sin (θ / 2)) ^ 2 := by
    rw [hsum, ← hcos, hdouble]; ring
  rw [this, Real.sqrt_sq (by positivity)]

/-- The chord is at most the angle: `‖√p − √q‖ ≤ arccos BC(p,q)`. -/
theorem chord_le_arccos_bhattacharyya (p q : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i) (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1) :
    √(∑ i, (√(p i) - √(q i)) ^ 2) ≤ arccos (bhattacharyya p q) := by
  rw [chord_eq_two_mul_sin_half_arccos p q hp hq hp1 hq1]
  have h := Real.sin_le (x := arccos (bhattacharyya p q) / 2)
    (by linarith [Real.arccos_nonneg (bhattacharyya p q)])
  linarith

/-! ## From a small chord to a small angle -/

/-- On `[0, π/2]` one has `x cos x ≤ sin x` (the tangent inequality). -/
theorem mul_cos_le_sin_of_mem {x : ℝ} (hx0 : 0 ≤ x) (hx : x ≤ π / 2) :
    x * cos x ≤ sin x := by
  rcases eq_or_lt_of_le hx0 with h | hpos
  · simp [← h]
  rcases eq_or_lt_of_le hx with h | hlt
  · rw [h, Real.cos_pi_div_two, Real.sin_pi_div_two]; norm_num
  · have hc : 0 < cos x := Real.cos_pos_of_mem_Ioo ⟨by linarith [Real.pi_pos], hlt⟩
    have h := Real.lt_tan hpos hlt
    rw [Real.tan_eq_sin_div_cos, lt_div_iff₀ hc] at h
    linarith

/-- **Quantitative chord-to-angle bound.**  If `sin (θ/2) ≤ s` with
`θ ∈ [0, π]` and `0 ≤ s`, then `θ √(1 − s²) ≤ 2 s`.  As `s → 0` this says the
angle and the chord agree to first order. -/
theorem angle_mul_sqrt_le_of_sin_half_le {θ s : ℝ} (hθ0 : 0 ≤ θ) (hθπ : θ ≤ π)
    (hs0 : 0 ≤ s) (h : sin (θ / 2) ≤ s) :
    θ * √(1 - s ^ 2) ≤ 2 * s := by
  set x := θ / 2 with hx
  have hx0 : 0 ≤ x := by positivity
  have hxπ : x ≤ π / 2 := by rw [hx]; linarith
  have hsin0 : 0 ≤ sin x :=
    Real.sin_nonneg_of_nonneg_of_le_pi hx0 (by linarith [Real.pi_pos])
  have hcos0 : 0 ≤ cos x := Real.cos_nonneg_of_mem_Icc ⟨by linarith [Real.pi_pos], hxπ⟩
  have hpyth := Real.sin_sq_add_cos_sq x
  have hcs : √(1 - s ^ 2) ≤ cos x := by
    have hle : 1 - s ^ 2 ≤ cos x ^ 2 := by nlinarith
    calc √(1 - s ^ 2) ≤ √(cos x ^ 2) := Real.sqrt_le_sqrt hle
      _ = cos x := Real.sqrt_sq hcos0
  have hmain : x * cos x ≤ sin x := mul_cos_le_sin_of_mem hx0 hxπ
  have hsq : 0 ≤ √(1 - s ^ 2) := Real.sqrt_nonneg _
  nlinarith [hmain, hcs, h, hx0]

/-- **The chord controls the angle.**  If the chord between the square-root
embeddings is at most `m`, the Bhattacharyya angle `θ` obeys
`θ √(1 − (m/2)²) ≤ m`.  Together with `chord ≤ θ` this pins the angle between
`chord` and `m/√(1-(m/2)²)`, so angle and chord agree to first order. -/
theorem arccos_bhattacharyya_mul_sqrt_le (p q : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i) (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1)
    {m : ℝ} (hm0 : 0 ≤ m) (hchord : √(∑ i, (√(p i) - √(q i)) ^ 2) ≤ m) :
    arccos (bhattacharyya p q) * √(1 - (m / 2) ^ 2) ≤ m := by
  have hsin : sin (arccos (bhattacharyya p q) / 2) ≤ m / 2 := by
    have h := (chord_eq_two_mul_sin_half_arccos p q hp hq hp1 hq1) ▸ hchord
    linarith
  have := angle_mul_sqrt_le_of_sin_half_le (Real.arccos_nonneg (bhattacharyya p q))
    (Real.arccos_le_pi _) (by linarith) hsin
  linarith

end FisherRao