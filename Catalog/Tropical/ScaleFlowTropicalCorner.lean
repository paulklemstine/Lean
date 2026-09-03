import Mathlib
import Tropical.ScaleFlowSweep

/-!
# The knee table as a tropical binomial, and its corner locus

The clamp `(t − σ)⁺` that carries the whole octave-shift law is a *max-plus*
operation, so the real knee table

`k*(σ, t) = k₀ + δ · (t − σ)⁺ = max (k₀) (k₀ + δ·t − δ·σ)`

is literally a **tropical binomial** in the two real coordinates: the tropical sum
of the constant monomial `k₀` and the monomial `k₀ + δ·t − δ·σ`
(`kstar_tropical_form`).  This file develops the geometry that this identification
buys.

* `convexOn_kstar_ctx`, `convexOn_kstar_scale` — the table is convex in context and
  convex in scale: knee budgets have *diminishing returns* along both axes, and
  this is forced by the tropical form, not assumed.
* `differentiableAt_kstar_off_corner`, `not_differentiableAt_kstar_corner` — the
  table is smooth away from the locus `t = σ` and **provably non-differentiable on
  it** whenever the rate is positive.  The proof is the two-sided derivative
  argument: within `Ioi σ` the derivative is `δ`, within `Iio σ` it is `0`, and
  `UniqueDiffWithinAt` forbids both.
* `corner_locus_eq` — the non-smooth locus is *exactly* `{t = σ}`: the tropical
  hypersurface of the binomial.  Deployment-wise this is the statement that a model
  has exactly one knee in its knee table, located at its own base context.
* `corner_locus_flow_invariant` — the corner locus is the diagonal of the
  `(scale, context)` plane, hence invariant under the flow direction `(1,1)`.  The
  exchange law of `Combinatorics.OctaveShiftLaw` is precisely the statement that
  the tropical hypersurface is a line of slope one; the discrete law samples this
  line at the lattice points.
* `flow_preserves_convexOn` — the scale flow preserves convexity of profiles: if a
  measured family shows diminishing returns at one scale it shows them at every
  scale.  So "diminishing returns" is a scale-invariant, not a per-model, property.
-/

namespace Tropical.ScaleFlowTropicalCorner

open Tropical.ScaleFlowSweep Set

/-! ## Convexity of max-affine functions -/

/-- A max of a constant and an affine function is convex. -/
theorem convexOn_max_affine (c u v : ℝ) :
    ConvexOn ℝ (univ : Set ℝ) (fun x : ℝ => max c (u * x + v)) := by
  refine ⟨convex_univ, ?_⟩
  intro x _ y _ a b ha hb hab
  simp only [smul_eq_mul]
  have h1x : c ≤ max c (u * x + v) := le_max_left _ _
  have h1y : c ≤ max c (u * y + v) := le_max_left _ _
  have h2x : u * x + v ≤ max c (u * x + v) := le_max_right _ _
  have h2y : u * y + v ≤ max c (u * y + v) := le_max_right _ _
  have hc : a * c + b * c = c := by rw [← add_mul, hab, one_mul]
  have hv : a * v + b * v = v := by rw [← add_mul, hab, one_mul]
  refine max_le ?_ ?_
  · have e1 : a * c ≤ a * max c (u * x + v) := mul_le_mul_of_nonneg_left h1x ha
    have e2 : b * c ≤ b * max c (u * y + v) := mul_le_mul_of_nonneg_left h1y hb
    linarith
  · have hexp : u * (a * x + b * y) + v = a * (u * x + v) + b * (u * y + v) := by
      linear_combination -hv
    rw [hexp]
    have e1 : a * (u * x + v) ≤ a * max c (u * x + v) := mul_le_mul_of_nonneg_left h2x ha
    have e2 : b * (u * y + v) ≤ b * max c (u * y + v) := mul_le_mul_of_nonneg_left h2y hb
    linarith

/-! ## The tropical form -/

/-- **The knee table is a tropical binomial.**  `k*(σ,t)` is the max-plus sum of the
constant monomial `k₀` and the monomial `k₀ + δ·t − δ·σ`. -/
theorem kstar_tropical_form {k0 delta : ℝ} (hδ : 0 ≤ delta) (sigma t : ℝ) :
    kstar k0 delta sigma t = max k0 (k0 + delta * t - delta * sigma) := by
  rcases le_total t sigma with h | h
  · rw [kstar_of_le h, max_eq_left (by nlinarith)]
  · rw [kstar_of_ge h, max_eq_right (by nlinarith)]
    ring

/-- The table is convex in context: diminishing returns along the context axis. -/
theorem convexOn_kstar_ctx {k0 delta : ℝ} (hδ : 0 ≤ delta) (sigma : ℝ) :
    ConvexOn ℝ (univ : Set ℝ) (fun t => kstar k0 delta sigma t) := by
  refine (convexOn_max_affine k0 delta (k0 - delta * sigma)).congr ?_
  intro x _
  show max k0 (delta * x + (k0 - delta * sigma)) = kstar k0 delta sigma x
  rw [kstar_tropical_form hδ]
  ring_nf

/-- The table is convex in scale as well. -/
theorem convexOn_kstar_scale {k0 delta : ℝ} (hδ : 0 ≤ delta) (t : ℝ) :
    ConvexOn ℝ (univ : Set ℝ) (fun sigma => kstar k0 delta sigma t) := by
  refine (convexOn_max_affine k0 (-delta) (k0 + delta * t)).congr ?_
  intro x _
  show max k0 (-delta * x + (k0 + delta * t)) = kstar k0 delta x t
  rw [kstar_tropical_form hδ]
  ring_nf

/-! ## The corner locus -/

/-- Away from the locus `t = σ` the table is differentiable in context. -/
theorem differentiableAt_kstar_off_corner (k0 delta : ℝ) {sigma t : ℝ} (h : t ≠ sigma) :
    DifferentiableAt ℝ (fun x => kstar k0 delta sigma x) t := by
  rcases lt_or_gt_of_ne h with hlt | hgt
  · have hloc : (fun x => kstar k0 delta sigma x) =ᶠ[nhds t] fun _ => k0 := by
      filter_upwards [gt_mem_nhds hlt] with x hx
      exact kstar_of_le (le_of_lt hx)
    exact (differentiableAt_const k0).congr_of_eventuallyEq hloc
  · exact (hasDerivAt_kstar_ctx k0 delta hgt).differentiableAt

/-- **The corner.**  At `t = σ` the table is not differentiable, whenever the
keys-per-octave rate is positive: the one-sided rates are `δ` and `0`. -/
theorem not_differentiableAt_kstar_corner {k0 delta : ℝ} (hδ : 0 < delta) (sigma : ℝ) :
    ¬ DifferentiableAt ℝ (fun x => kstar k0 delta sigma x) sigma := by
  intro hdiff
  set d := deriv (fun x => kstar k0 delta sigma x) sigma with hd
  have hderiv : HasDerivAt (fun x => kstar k0 delta sigma x) d sigma := hdiff.hasDerivAt
  have haff : HasDerivAt (fun x : ℝ => k0 + delta * (x - sigma)) delta sigma := by
    have h2 : HasDerivAt (fun x : ℝ => x - sigma) 1 sigma := by
      simpa using (hasDerivAt_id sigma).sub_const sigma
    simpa using ((h2.const_mul delta).const_add k0)
  have hright : HasDerivWithinAt (fun x => kstar k0 delta sigma x) delta (Ioi sigma) sigma := by
    refine haff.hasDerivWithinAt.congr (fun x hx => ?_) ?_
    · exact kstar_of_ge (le_of_lt hx)
    · rw [kstar_of_le (le_refl sigma)]; ring
  have hleft : HasDerivWithinAt (fun x => kstar k0 delta sigma x) 0 (Iio sigma) sigma := by
    refine (hasDerivAt_const sigma k0).hasDerivWithinAt.congr (fun x hx => ?_) ?_
    · exact kstar_of_le (le_of_lt hx)
    · exact kstar_of_le (le_refl sigma)
  have h1 : d = delta :=
    (uniqueDiffWithinAt_Ioi sigma).eq_deriv _ hderiv.hasDerivWithinAt hright
  have h2 : d = 0 :=
    (uniqueDiffWithinAt_Iio sigma).eq_deriv _ hderiv.hasDerivWithinAt hleft
  rw [h1] at h2
  linarith

/-- **The corner locus is the tropical hypersurface.**  For a positive rate the set
of context octaves at which the knee table fails to be smooth is exactly `{σ}`:
each model has exactly one knee, at its own base context. -/
theorem corner_locus_eq {k0 delta : ℝ} (hδ : 0 < delta) (sigma : ℝ) :
    {t : ℝ | ¬ DifferentiableAt ℝ (fun x => kstar k0 delta sigma x) t} = {sigma} := by
  ext t
  simp only [mem_setOf_eq, mem_singleton_iff]
  constructor
  · intro h
    by_contra hne
    exact h (differentiableAt_kstar_off_corner k0 delta hne)
  · rintro rfl
    exact not_differentiableAt_kstar_corner hδ t

/-- **The corner locus is the flow line.**  In the `(scale, context)` plane the
non-smooth locus is the diagonal `t = σ`, so it is invariant under the flow
direction `(1,1)`: this is the infinitesimal geometry behind the exchange law
`F(σ+a, t+a) = F(σ, t)` of the discrete theory. -/
theorem corner_locus_flow_invariant {k0 delta : ℝ} (hδ : 0 < delta) (sigma t a : ℝ) :
    (¬ DifferentiableAt ℝ (fun x => kstar k0 delta sigma x) t) ↔
      (¬ DifferentiableAt ℝ (fun x => kstar k0 delta (sigma + a) x) (t + a)) := by
  have h1 : (¬ DifferentiableAt ℝ (fun x => kstar k0 delta sigma x) t) ↔ t = sigma := by
    constructor
    · intro h
      have hmem : t ∈ {u : ℝ | ¬ DifferentiableAt ℝ (fun x => kstar k0 delta sigma x) u} := h
      rw [corner_locus_eq hδ sigma] at hmem
      exact hmem
    · rintro rfl
      exact not_differentiableAt_kstar_corner hδ t
  have h2 : (¬ DifferentiableAt ℝ (fun x => kstar k0 delta (sigma + a) x) (t + a)) ↔
      t + a = sigma + a := by
    constructor
    · intro h
      have hmem : t + a ∈
          {u : ℝ | ¬ DifferentiableAt ℝ (fun x => kstar k0 delta (sigma + a) x) u} := h
      rw [corner_locus_eq hδ (sigma + a)] at hmem
      exact hmem
    · intro h
      rw [h]
      exact not_differentiableAt_kstar_corner hδ (sigma + a)
  rw [h1, h2]
  constructor
  · intro h; rw [h]
  · intro h; linarith

/-! ## The flow preserves diminishing returns -/

/-- The clamp is convex. -/
theorem convexOn_clamp (sigma : ℝ) : ConvexOn ℝ (univ : Set ℝ) (fun t : ℝ => max (t - sigma) 0) := by
  refine (convexOn_max_affine 0 1 (-sigma)).congr ?_
  intro x _
  show max 0 (1 * x + -sigma) = max (x - sigma) 0
  rw [max_comm]
  ring_nf

theorem clamp_image (sigma : ℝ) : (fun t : ℝ => max (t - sigma) 0) '' univ = Ici (0 : ℝ) := by
  ext y
  simp only [mem_image, mem_univ, true_and, mem_Ici]
  constructor
  · rintro ⟨x, rfl⟩
    exact le_max_right _ _
  · intro hy
    exact ⟨sigma + y, by rw [add_sub_cancel_left, max_eq_left hy]⟩

/-- **The scale flow preserves convexity.**  If the base knee profile has
diminishing returns (is convex) and is monotone, then so does every scaled profile:
diminishing returns is a property of the *family*, not of an individual model. -/
theorem flow_preserves_convexOn {K0 : ℝ → ℝ} (hconv : ConvexOn ℝ (univ : Set ℝ) K0)
    (hmono : Monotone K0) (sigma : ℝ) :
    ConvexOn ℝ (univ : Set ℝ) (fun t => K0 (max (t - sigma) 0)) := by
  have himg : (fun t : ℝ => max (t - sigma) 0) '' univ = Ici (0 : ℝ) := clamp_image sigma
  have houter : ConvexOn ℝ ((fun t : ℝ => max (t - sigma) 0) '' univ) K0 := by
    rw [himg]
    exact hconv.subset (subset_univ _) (convex_Ici 0)
  have hmonoOn : MonotoneOn K0 ((fun t : ℝ => max (t - sigma) 0) '' univ) :=
    fun _ _ _ _ hxy => hmono hxy
  exact houter.comp (convexOn_clamp sigma) hmonoOn

end Tropical.ScaleFlowTropicalCorner