import Tropical.MagmaMonoid.Regularity

/-!
# Regularity in equivariant transformation monoids: the general theorem

The magma monoid `Bin(X)` is the monoid of transformations of `X × X` commuting
with the reversal involution (`Structure.lean`), and its regular elements are
characterized by a *diagonal obstruction* (`Regularity.lean`): a value fixed by
reversal must be attained at a point fixed by reversal.

This file isolates the mechanism behind that theorem and proves it in complete
generality, for an arbitrary group `G` acting on an arbitrary set `Y`:

> **Theorem** (`regular_equivariant_iff`).  A `G`-equivariant transformation `T`
> of `Y` is von Neumann regular inside the monoid of `G`-equivariant
> transformations if and only if every point `y` of its image has a preimage `z`
> whose stabilizer contains the stabilizer of `y`.

The magma-monoid criterion is the case `Y = X × X`, `G = ℤ/2` acting by
reversal: the points with non-trivial stabilizer are exactly the diagonal
points, so the condition reads "each diagonal point in the image is the image of
a diagonal point", which is `commutativeImage f = diagonalImage f`.

The engine (`exists_equivariant_section`) is a stabilizer-controlled equivariant
choice: pick one representative in each `G`-orbit of the image, pick a preimage
whose stabilizer is large enough, and transport it around the orbit; the
stabilizer hypothesis is exactly what makes the transport well defined.
-/

namespace MagmaMonoid

variable {G Y : Type*} [Group G] [MulAction G Y]

/-- `G`-equivariant self-maps of a `G`-set. -/
def IsGEquivariant (G : Type*) [Group G] {Y : Type*} [MulAction G Y] (T : Y → Y) : Prop :=
  ∀ (g : G) (y : Y), T (g • y) = g • T y

/-- The image of an equivariant map is `G`-invariant. -/
theorem smul_mem_range {T : Y → Y} (hT : IsGEquivariant G T) (g : G) {y : Y}
    (hy : y ∈ Set.range T) : g • y ∈ Set.range T := by
  obtain ⟨x, rfl⟩ := hy
  exact ⟨g • x, hT g x⟩

/--
**Stabilizer-controlled equivariant section.**  If every point of the image of
an equivariant transformation `T` admits a preimage whose stabilizer contains
the stabilizer of the point, then these preimages can be chosen *equivariantly*:
there is an equivariant `U` with `T (U y) = y` for all `y` in the image of `T`.
-/
theorem exists_equivariant_section {T : Y → Y} (hT : IsGEquivariant G T)
    (hstab : ∀ y ∈ Set.range T, ∃ z, T z = y ∧ ∀ g : G, g • y = y → g • z = z) :
    ∃ U : Y → Y, IsGEquivariant G U ∧ ∀ y ∈ Set.range T, T (U y) = y := by
  classical
  set rep : Y → Y := fun y ↦ (Quotient.mk (MulAction.orbitRel G Y) y).out with hrepdef
  have hrep_orbit : ∀ y : Y, ∃ g : G, g • rep y = y := by
    intro y
    have h : Quotient.mk (MulAction.orbitRel G Y) (rep y)
        = Quotient.mk (MulAction.orbitRel G Y) y := Quotient.out_eq _
    obtain ⟨g, hg⟩ := MulAction.orbitRel_apply.1 (Quotient.exact h)
    exact ⟨g⁻¹, by rw [← hg]; simp⟩
  have hrep_smul : ∀ (g : G) (y : Y), rep (g • y) = rep y := by
    intro g y
    have h : Quotient.mk (MulAction.orbitRel G Y) (g • y)
        = Quotient.mk (MulAction.orbitRel G Y) y :=
      Quotient.sound (MulAction.orbitRel_apply.2 ⟨g, rfl⟩)
    simp only [hrepdef, h]
  choose! z hz1 hz2 using hstab
  choose gof hgof using hrep_orbit
  refine ⟨fun y ↦ if rep y ∈ Set.range T then gof y • z (rep y) else y, ?_, ?_⟩
  · intro h y
    by_cases hy : rep y ∈ Set.range T
    · have hy' : rep (h • y) ∈ Set.range T := by rw [hrep_smul]; exact hy
      simp only [hrep_smul, if_pos hy]
      have e1 : gof (h • y) • rep y = h • y := by
        have := hgof (h • y); rwa [hrep_smul] at this
      have e2 : (h * gof y) • rep y = h • y := by rw [mul_smul, hgof y]
      have hstabg : ((h * gof y)⁻¹ * gof (h • y)) • rep y = rep y := by
        rw [mul_smul, e1, ← e2, inv_smul_smul]
      have hfix := hz2 (rep y) hy _ hstabg
      calc gof (h • y) • z (rep y)
          = (h * gof y) • (((h * gof y)⁻¹ * gof (h • y)) • z (rep y)) := by
            rw [← mul_smul, mul_inv_cancel_left]
        _ = (h * gof y) • z (rep y) := by rw [hfix]
        _ = h • (gof y • z (rep y)) := by rw [mul_smul]
    · have hy' : ¬ rep (h • y) ∈ Set.range T := by rw [hrep_smul]; exact hy
      simp only [if_neg hy, if_neg hy']
  · intro y hy
    have hrepy : rep y ∈ Set.range T := by
      have hr : rep y = (gof y)⁻¹ • y := eq_inv_smul_iff.2 (hgof y)
      rw [hr]
      exact smul_mem_range hT _ hy
    simp only [if_pos hrepy]
    rw [hT, hz1 (rep y) hrepy, hgof y]

/--
**Regularity in an equivariant transformation monoid.**  A `G`-equivariant
transformation `T` of a `G`-set `Y` is von Neumann regular inside the monoid of
`G`-equivariant transformations exactly when every point of its image has a
preimage with at least the same stabilizer.

For the trivial group this is the classical fact that the full transformation
monoid is regular; for `G = ℤ/2` acting on `X × X` by reversal it is the
regularity criterion for the magma monoid.
-/
theorem regular_equivariant_iff {T : Y → Y} (hT : IsGEquivariant G T) :
    (∃ U : Y → Y, IsGEquivariant G U ∧ ∀ y, T (U (T y)) = T y) ↔
      ∀ y ∈ Set.range T, ∃ z, T z = y ∧ ∀ g : G, g • y = y → g • z = z := by
  constructor
  · rintro ⟨U, hU, hUT⟩ y hy
    obtain ⟨x, rfl⟩ := hy
    refine ⟨U (T x), hUT x, fun g hg ↦ ?_⟩
    rw [← hU g (T x), hg]
  · intro h
    obtain ⟨U, hU, hUspec⟩ := exists_equivariant_section hT h
    exact ⟨U, hU, fun x ↦ hUspec _ ⟨x, rfl⟩⟩

/-- Consequence: the *stabilizer-free* case.  If the action is free on the image
(no non-identity element fixes a point of the image), every equivariant
transformation is regular — the obstruction seen in the magma monoid can only
come from points with non-trivial stabilizer. -/
theorem regular_equivariant_of_free {T : Y → Y} (hT : IsGEquivariant G T)
    (hfree : ∀ y ∈ Set.range T, ∀ g : G, g • y = y → g = 1) :
    ∃ U : Y → Y, IsGEquivariant G U ∧ ∀ y, T (U (T y)) = T y := by
  rw [regular_equivariant_iff hT]
  rintro y ⟨x, rfl⟩
  exact ⟨x, rfl, fun g hg ↦ by rw [hfree _ ⟨x, rfl⟩ g hg, one_smul]⟩

/-! ### Specialization: the magma monoid is the case `G = ℤ/2` acting by reversal

We now verify that the general theorem really does subsume the regularity
criterion of `Regularity.lean`, by instantiating it at the two-element group
acting on `X × X` through pair reversal. -/

section SwapAction

variable {X : Type*}

/-- The two-element group acts on `X × X` by pair reversal. -/
scoped instance swapSMul : SMul (Multiplicative (ZMod 2)) (X × X) :=
  ⟨fun g p ↦ if g = 1 then p else swap p⟩

theorem swap_smul_def (g : Multiplicative (ZMod 2)) (p : X × X) :
    g • p = if g = 1 then p else swap p := rfl

scoped instance swapMulAction : MulAction (Multiplicative (ZMod 2)) (X × X) where
  one_smul p := by rw [swap_smul_def]; simp
  mul_smul g h p := by
    by_cases hg : g = 1
    · subst hg; rw [swap_smul_def (1 : Multiplicative (ZMod 2))]; simp
    · by_cases hh : h = 1
      · subst hh; simp [swap_smul_def]
      · have hgh : g * h = 1 := by revert hg hh; revert g h; decide
        rw [swap_smul_def, if_pos hgh, swap_smul_def h, if_neg hh, swap_smul_def g, if_neg hg]
        rfl

theorem swap_smul_of_ne_one {g : Multiplicative (ZMod 2)} (hg : g ≠ 1) (p : X × X) :
    g • p = swap p := by rw [swap_smul_def, if_neg hg]

theorem ofAdd_one_ne_one : (Multiplicative.ofAdd (1 : ZMod 2)) ≠ 1 := by decide

/-- Equivariance for the reversal action is exactly the pairmorph property. -/
theorem isGEquivariant_iff_isPairmorph (T : X × X → X × X) :
    IsGEquivariant (Multiplicative (ZMod 2)) T ↔ IsPairmorph T := by
  constructor
  · intro h p
    have := h (Multiplicative.ofAdd (1 : ZMod 2)) p
    rwa [swap_smul_of_ne_one ofAdd_one_ne_one, swap_smul_of_ne_one ofAdd_one_ne_one] at this
  · intro h g p
    by_cases hg : g = 1
    · subst hg; simp
    · rw [swap_smul_of_ne_one hg, swap_smul_of_ne_one hg]
      exact h p

/-- Regularity of an operation is regularity of its pairmorph inside the monoid
of swap-equivariant transformations. -/
theorem isRegular_iff_exists_pairmorph_middle (f : Operation X) :
    IsRegular f ↔ ∃ U : X × X → X × X, IsPairmorph U ∧
      ∀ p, pairmorph f (U (pairmorph f p)) = pairmorph f p := by
  constructor
  · rintro ⟨g, hg⟩
    refine ⟨pairmorph g, pairmorph_commutes g, fun p ↦ ?_⟩
    have h := congrArg pairmorph hg
    rw [pairmorph_product, pairmorph_product] at h
    exact congrFun h p
  · rintro ⟨U, hU, hUspec⟩
    obtain ⟨g, hg⟩ := (exists_pairmorph_iff U).2 hU
    refine ⟨g, pairmorph_injective ?_⟩
    rw [pairmorph_product, pairmorph_product, hg]
    exact funext hUspec

/-- **The magma-monoid regularity criterion, re-derived from the general
equivariant theorem.**  An operation is regular iff every point of its pairmorph
image has a preimage with at least the same reversal-stabilizer — for points off
the diagonal this is vacuous, and on the diagonal it is the requirement of a
diagonal preimage. -/
theorem isRegular_iff_stabilizer (f : Operation X) :
    IsRegular f ↔ ∀ y ∈ pairImage f, ∃ z, pairmorph f z = y ∧ (swap y = y → swap z = z) := by
  have hequiv : IsGEquivariant (Multiplicative (ZMod 2)) (pairmorph f) :=
    (isGEquivariant_iff_isPairmorph _).2 (pairmorph_commutes f)
  rw [isRegular_iff_exists_pairmorph_middle]
  constructor
  · intro hU
    obtain ⟨U, hUp, hUspec⟩ := hU
    have : ∃ U : X × X → X × X, IsGEquivariant (Multiplicative (ZMod 2)) U ∧
        ∀ y, pairmorph f (U (pairmorph f y)) = pairmorph f y :=
      ⟨U, (isGEquivariant_iff_isPairmorph _).2 hUp, hUspec⟩
    intro y hy
    obtain ⟨z, hz1, hz2⟩ := (regular_equivariant_iff hequiv).1 this y hy
    refine ⟨z, hz1, fun hsy ↦ ?_⟩
    have := hz2 (Multiplicative.ofAdd (1 : ZMod 2))
      (by rw [swap_smul_of_ne_one ofAdd_one_ne_one]; exact hsy)
    rwa [swap_smul_of_ne_one ofAdd_one_ne_one] at this
  · intro h
    have hstab : ∀ y ∈ Set.range (pairmorph f), ∃ z, pairmorph f z = y ∧
        ∀ g : Multiplicative (ZMod 2), g • y = y → g • z = z := by
      intro y hy
      obtain ⟨z, hz1, hz2⟩ := h y hy
      refine ⟨z, hz1, fun g hg ↦ ?_⟩
      by_cases hg1 : g = 1
      · subst hg1; simp
      · rw [swap_smul_of_ne_one hg1] at hg ⊢
        exact hz2 hg
    obtain ⟨U, hU, hUspec⟩ := (regular_equivariant_iff hequiv).2 hstab
    exact ⟨U, (isGEquivariant_iff_isPairmorph _).1 hU, hUspec⟩

end SwapAction

end MagmaMonoid