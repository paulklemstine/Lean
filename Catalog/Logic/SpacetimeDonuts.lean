import Mathlib

/-!
# Spacetime donuts: topology, wrapping, and a causal counterexample

This file gives a concrete flat model of `T³ = (ℝ/ℤ)³`.  It proves that integer
straight lines project to nonconstant closed spatial geodesics and identifies the
covering-translation group with `ℤ³`, with three independent standard generators.

It also tests the stronger claim that torus *spatial topology alone* forces closed
timelike geodesics.  In the standard product spacetime `ℝ × T³`, an affine
geodesic can close only if its (unquotiented) time velocity is zero, whereas a
timelike velocity must have nonzero time component.  Thus that stronger claim is
false without an additional causal/time identification.  Compactifying time to a
circle does produce a closed timelike affine geodesic.

The Weeks-manifold minimal-volume statement is recorded only as a precise
order-theoretic conjecture schema; no unformalized hyperbolic geometry is claimed.
-/

open AddCircle

namespace RuckerSpacetimeDonuts

abbrev Torus3 := Fin 3 → AddCircle (1 : ℝ)

noncomputable def proj : (Fin 3 → ℝ) →+ Torus3 :=
  Pi.addMonoidHom fun i =>
    (QuotientAddGroup.mk' _).comp (Pi.evalAddMonoidHom (fun _ : Fin 3 => ℝ) i)

@[simp] theorem proj_apply (x : Fin 3 → ℝ) (i : Fin 3) :
    proj x i = ((x i : ℝ) : AddCircle (1 : ℝ)) := rfl

/-- Projection of a straight line of integer velocity in the universal cover. -/
def geo (n : Fin 3 → ℤ) (t : ℝ) : Torus3 :=
  fun i => ((t * n i : ℝ) : AddCircle (1 : ℝ))

theorem geo_eq_proj_line (n : Fin 3 → ℤ) (t : ℝ) :
    geo n t = proj (fun i => t * (n i : ℝ)) := rfl

/-- Integer-direction straight lines close after one unit of parameter time. -/
theorem geo_periodic (n : Fin 3 → ℤ) (t : ℝ) : geo n (t + 1) = geo n t := by
  funext i
  show (((t + 1) * n i : ℝ) : AddCircle (1 : ℝ)) =
    ((t * n i : ℝ) : AddCircle (1 : ℝ))
  rw [show ((t + 1) * n i : ℝ) = (n i) • (1 : ℝ) + t * n i by
        simp only [zsmul_eq_mul, mul_one]; ring,
      coe_add, coe_zsmul, coe_period, smul_zero, zero_add]

@[simp] theorem geo_zero (n : Fin 3 → ℤ) : geo n 0 = 0 := by
  funext i
  simp [geo]

/-- A nonzero wrapping vector gives a genuinely nonconstant closed geodesic. -/
theorem geo_nontrivial (n : Fin 3 → ℤ) (hn : n ≠ 0) :
    ∃ t : ℝ, geo n t ≠ geo n 0 := by
  rw [Function.ne_iff] at hn
  obtain ⟨i, hi⟩ := hn
  refine ⟨1 / (2 * n i), ?_⟩
  intro h
  have hne : (n i : ℝ) ≠ 0 := by exact_mod_cast (by simpa using hi)
  have hci := congrFun h i
  rw [geo_zero] at hci
  simp only [geo, Pi.zero_apply] at hci
  rw [show (1 / (2 * (n i : ℝ)) * n i : ℝ) = 1 / 2 by field_simp] at hci
  rw [AddCircle.coe_eq_zero_iff] at hci
  obtain ⟨m, hm⟩ := hci
  simp only [zsmul_eq_mul, mul_one] at hm
  have h1 : (2 * m : ℤ) = 1 := by
    have h2 : (2 : ℝ) * m = 1 := by rw [hm]; ring
    exact_mod_cast h2
  omega

/-
The flat three-torus contains a genuinely nonconstant closed spatial
geodesic (for example, one winding in the first coordinate).
-/
theorem exists_nontrivial_closed_geodesic :
    ∃ n : Fin 3 → ℤ,
      n ≠ 0 ∧ (∀ t, geo n (t + 1) = geo n t) ∧
        ∃ t, geo n t ≠ geo n 0 := by
  refine' ⟨ Pi.single 0 1, _, _, 1 / 2, _ ⟩ <;> norm_num;
  · exact fun t => geo_periodic _ _;
  · intro h; have := congr_fun h 0; norm_num [ geo ] at this;
    obtain ⟨ k, hk ⟩ := this;
    rcases k with ⟨ _ | _ | k ⟩ <;> norm_num at hk <;> linarith

/-- The integer lattice in the universal cover. -/
def latt : (Fin 3 → ℤ) →+ (Fin 3 → ℝ) where
  toFun n := fun i => (n i : ℝ)
  map_zero' := by funext i; simp
  map_add' a b := by funext i; simp

@[simp] theorem latt_apply (n : Fin 3 → ℤ) (i : Fin 3) : latt n i = (n i : ℝ) := rfl

theorem latt_injective : Function.Injective latt := by
  intro a b h
  funext i
  have hi : (a i : ℝ) = (b i : ℝ) := congrFun h i
  exact_mod_cast hi

/-- Kernel characterization of the torus covering projection. -/
theorem mem_ker_iff (x : Fin 3 → ℝ) :
    proj x = 0 ↔ ∀ i, ∃ m : ℤ, x i = m := by
  constructor
  · intro h i
    have hi : ((x i : ℝ) : AddCircle (1 : ℝ)) = 0 := by
      rw [← proj_apply, h]
      rfl
    rw [AddCircle.coe_eq_zero_iff] at hi
    obtain ⟨m, hm⟩ := hi
    exact ⟨m, by simpa using hm.symm⟩
  · intro h
    funext i
    obtain ⟨m, hm⟩ := h i
    rw [Pi.zero_apply, proj_apply, hm, AddCircle.coe_eq_zero_iff]
    exact ⟨m, by simp⟩

/-- The deck-translation kernel is exactly the image of `ℤ³`. -/
theorem ker_proj_eq_range : proj.ker = latt.range := by
  ext x
  simp only [AddMonoidHom.mem_ker, AddMonoidHom.mem_range]
  rw [mem_ker_iff]
  constructor
  · intro h
    choose m hm using h
    exact ⟨m, by funext i; exact (hm i).symm⟩
  · rintro ⟨n, rfl⟩ i
    exact ⟨n i, rfl⟩

/-- The three coordinate wrapping directions are linearly independent over `ℤ`. -/
theorem standard_basis_indep :
    LinearIndependent ℤ (fun i : Fin 3 =>
      (Pi.single i (1 : ℤ) : Fin 3 → ℤ)) := by
  have h := (Pi.basisFun ℤ (Fin 3)).linearIndependent
  have he : (fun i : Fin 3 => (Pi.single i (1 : ℤ) : Fin 3 → ℤ)) =
      ⇑(Pi.basisFun ℤ (Fin 3)) := by
    funext i
    rw [Pi.basisFun_apply]
  rw [he]
  exact h

/-- The class of an integer geodesic, represented by its lifted endpoint. -/
def geoClass (n : Fin 3 → ℤ) : proj.ker :=
  ⟨latt n, by
    rw [AddMonoidHom.mem_ker, mem_ker_iff]
    intro i
    exact ⟨n i, rfl⟩⟩

theorem geoClass_injective : Function.Injective geoClass := by
  intro a b h
  apply latt_injective
  exact congrArg Subtype.val h

/-! ## The causal claim: a counterexample and a repaired theorem -/

/-- Constant velocity of an affine geodesic in the universal cover `ℝ × ℝ³`. -/
structure AffineVelocity where
  time : ℝ
  space : Fin 3 → ℝ

/-- Minkowski timelikeness, in units where the speed of light is one. -/
def Timelike (v : AffineVelocity) : Prop :=
  (∑ i, (v.space i) ^ 2) < v.time ^ 2

/-- Closing after unit parameter time in `ℝ × T³`: time is not quotiented,
while each spatial displacement must be integral. -/
def ClosesInProduct (v : AffineVelocity) : Prop :=
  v.time = 0 ∧ ∀ i, ∃ n : ℤ, v.space i = n

/-
**Contrarian disproof.** In the globally timed product spacetime `ℝ × T³`,
no unit-period affine geodesic is both closed and timelike.  Consequently the
spatial topology `T³` alone does not imply closed timelike geodesics.
-/
theorem no_closed_timelike_affine_in_product (v : AffineVelocity)
    (hc : ClosesInProduct v) : ¬ Timelike v := by
  unfold Timelike; have := hc.1; norm_num [ this ];
  exact Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- Closing in a fully compactified spacetime `(ℝ/ℤ) × T³`. -/
def ClosesInCompactTime (v : AffineVelocity) : Prop :=
  (∃ n : ℤ, v.time = n) ∧ ∀ i, ∃ n : ℤ, v.space i = n

/-- Unit motion around a compact time circle. -/
def timeCircleVelocity : AffineVelocity where
  time := 1
  space := 0

/-
Compactifying time repairs the existential claim: the time-circle direction
is a closed timelike affine geodesic.
-/
theorem compact_time_has_closed_timelike :
    ClosesInCompactTime timeCircleVelocity ∧ Timelike timeCircleVelocity := by
  exact ⟨ ⟨ ⟨ 1, by norm_num [ timeCircleVelocity ] ⟩, fun i => ⟨ 0, by norm_num [ timeCircleVelocity ] ⟩ ⟩, by norm_num [ Timelike, timeCircleVelocity ] ⟩

/-
There are infinitely many distinct nonzero wrapping classes, not merely the
three displayed basis vectors.
-/
theorem infinitely_many_wrapping_classes :
    Set.Infinite (Set.range geoClass) := by
  convert Set.infinite_range_of_injective ( geoClass_injective ) using 1

/-! ## The Weeks conjecture, stated without pretending to formalize its geometry -/

/-- For a type of candidate manifolds equipped with volume, this is the exact
minimal-volume assertion attached to a distinguished candidate.  Instantiating
`M` with complete orientable hyperbolic 3-manifolds and `weeks` with the Weeks
manifold is the classical conjecture/theorem-level geometric statement. -/
def IsMinimalVolume {M : Type*} (volume : M → ℝ) (weeks : M) : Prop :=
  ∀ X, volume weeks ≤ volume X

/-
The minimal-volume assertion is precisely membership of the Weeks volume in
the lower-bound set of all candidate volumes.
-/
theorem minimalVolume_iff_lowerBound {M : Type*} (volume : M → ℝ) (weeks : M) :
    IsMinimalVolume volume weeks ↔
      volume weeks ∈ lowerBounds (Set.range volume) := by
  exact ⟨ fun h x hx => by obtain ⟨ y, rfl ⟩ := hx; exact h y, fun h x => h ⟨ x, rfl ⟩ ⟩

end RuckerSpacetimeDonuts