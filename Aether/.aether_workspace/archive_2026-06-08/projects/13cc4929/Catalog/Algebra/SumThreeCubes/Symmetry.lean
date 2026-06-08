import Mathlib
import Algebra.SumThreeCubes.Defs

/-!
# Symmetry of the Cubic Surface X_k

This file formalizes the symmetries of the Diophantine equation x³ + y³ + z³ = k:
- Sign symmetry: SumThreeCubesRep(-k) ↔ SumThreeCubesRep(k)
- Permutation invariance: the equation is invariant under S₃

## Main Results

* `sumThreeCubesRep_neg_iff` — representability is invariant under k ↦ -k
* `onCubicSurface_perm` — full S₃ permutation invariance
-/

/-- If k is representable, so is -k. -/
theorem sumThreeCubesRep_neg (k : ℤ) (h : SumThreeCubesRep k) :
    SumThreeCubesRep (-k) := by
  obtain ⟨x, y, z, hxyz⟩ := h
  exact ⟨-x, -y, -z, by nlinarith⟩

/-- Representability is invariant under negation. -/
theorem sumThreeCubesRep_neg_iff (k : ℤ) :
    SumThreeCubesRep (-k) ↔ SumThreeCubesRep k := by
  constructor
  · intro h; have := sumThreeCubesRep_neg (-k) h; rwa [neg_neg] at this
  · exact sumThreeCubesRep_neg k

/-- Swapping x and y preserves OnCubicSurface. -/
theorem onCubicSurface_swap_xy (k x y z : ℤ) (h : OnCubicSurface k x y z) :
    OnCubicSurface k y x z := by
  unfold OnCubicSurface at *; linarith

/-- Swapping x and z preserves OnCubicSurface. -/
theorem onCubicSurface_swap_xz (k x y z : ℤ) (h : OnCubicSurface k x y z) :
    OnCubicSurface k z y x := by
  unfold OnCubicSurface at *; linarith

/-- Swapping y and z preserves OnCubicSurface. -/
theorem onCubicSurface_swap_yz (k x y z : ℤ) (h : OnCubicSurface k x y z) :
    OnCubicSurface k x z y := by
  unfold OnCubicSurface at *; linarith

/-
Full S₃ permutation invariance on the cubic surface.
Any permutation of coordinates preserves membership on X_k.
-/
theorem onCubicSurface_perm
    (k x y z : ℤ) (σ : Equiv.Perm (Fin 3))
    (h : OnCubicSurface k x y z) :
    OnCubicSurface k
      (![x, y, z] (σ 0))
      (![x, y, z] (σ 1))
      (![x, y, z] (σ 2)) := by
  fin_cases σ <;> simp_all +decide [ OnCubicSurface ];
  · convert h using 1 ; ring!;
  · convert h using 1 ; ring!;
  · convert h using 1 ; ring!;
  · simp_all +decide [ add_comm, add_assoc, Equiv.swap_apply_def ];
  · convert h using 1 ; ring!

/-- Negating all coordinates gives a solution for -k. -/
theorem onCubicSurface_neg_all (k x y z : ℤ) (h : OnCubicSurface k x y z) :
    OnCubicSurface (-k) (-x) (-y) (-z) := by
  unfold OnCubicSurface at *; nlinarith