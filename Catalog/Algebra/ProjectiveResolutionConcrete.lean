/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Concrete Projective Resolutions for ℤ-modules

This file constructs explicit projective (free) resolutions for concrete ℤ-modules,
most importantly the canonical 2-term free resolution of ℤ/nℤ:
  ℤ --(·n)--> ℤ --π--> ℤ/nℤ --> 0

We prove this resolution is exact, and that the modules in the resolution are free (hence projective).
This forms the computational foundation for explicit Ext and Tor calculations over ℤ.
-/
import Mathlib

open CategoryTheory

/-! ## Multiplication by n on ℤ -/

/-- Multiplication by `(n : ℤ)` as a ℤ-linear map. -/
noncomputable def LinearMap.mulLeft_int (n : ℤ) : ℤ →ₗ[ℤ] ℤ :=
  LinearMap.lsmul ℤ ℤ n

@[simp]
lemma LinearMap.mulLeft_int_apply (n x : ℤ) :
    LinearMap.mulLeft_int n x = n * x := by
  simp [LinearMap.mulLeft_int]

/-
The kernel of multiplication by a nonzero integer is trivial.
-/
theorem ker_mulLeft_int_of_ne_zero {n : ℤ} (hn : n ≠ 0) :
    LinearMap.ker (LinearMap.mulLeft_int n) = ⊥ := by
  simp_all +decide [ SetLike.ext_iff, LinearMap.mulLeft_int, LinearMap.ext_iff ]

/-
The range of multiplication by n is the submodule nℤ.
-/
theorem range_mulLeft_int (n : ℤ) :
    LinearMap.range (LinearMap.mulLeft_int n) = Submodule.span ℤ {n} := by
  ext; simp [LinearMap.mulLeft_int];
  simp +decide [ Ideal.mem_span_singleton, eq_comm ];
  rfl

/-- The canonical projection ℤ → ℤ/nℤ as a ℤ-linear map. -/
noncomputable def ZMod.linearMapFromInt (n : ℕ) : ℤ →ₗ[ℤ] ZMod n :=
  Int.castRingHom (ZMod n) |>.toIntAlgHom |>.toLinearMap

/-
The canonical projection ℤ → ℤ/nℤ is surjective.
-/
theorem ZMod.linearMapFromInt_surjective (n : ℕ) :
    Function.Surjective (ZMod.linearMapFromInt n) := by
  exact ZMod.intCast_surjective

/-
The kernel of the projection ℤ → ℤ/nℤ equals nℤ.
-/
theorem ZMod.ker_linearMapFromInt (n : ℕ) :
    LinearMap.ker (ZMod.linearMapFromInt n) = Submodule.span ℤ {(n : ℤ)} := by
  ext;
  simp +decide [ Ideal.mem_span_singleton, ZMod.intCast_zmod_eq_zero_iff_dvd ];
  erw [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ; aesop

/-! ## Exactness of the resolution sequence -/

/-
For any `n ≠ 0`, the sequence `ℤ --(·n)--> ℤ --π--> ℤ/nℤ --> 0` is exact at the
middle term: the image of multiplication by n equals the kernel of the projection.
-/
theorem resolution_exact_at_middle (n : ℕ) (_hn : n ≠ 0) :
    LinearMap.range (LinearMap.mulLeft_int (n : ℤ)) =
    LinearMap.ker (ZMod.linearMapFromInt n) := by
  convert ( ZMod.ker_linearMapFromInt n |> fun h => h.symm ) using 1;
  convert range_mulLeft_int n

/-
The multiplication-by-n map ℤ → ℤ is injective when n ≠ 0.
-/
theorem mulLeft_int_injective {n : ℤ} (hn : n ≠ 0) :
    Function.Injective (LinearMap.mulLeft_int n) := by
  exact fun a b h => mul_left_cancel₀ hn h

/-! ## Free module structure -/

/-- ℤ is a free ℤ-module. -/
instance : Module.Free ℤ ℤ := Module.Free.self ℤ

/-- ℤ is a projective ℤ-module. -/
instance : Module.Projective ℤ ℤ := Module.Projective.of_free

/-! ## The key isomorphism: cokernel of (·n) on A is A/nA -/

/-- The n-torsion submodule of a ℤ-module A. -/
def nTorsion (A : Type*) [AddCommGroup A] [Module ℤ A] (n : ℤ) : Submodule ℤ A :=
  LinearMap.ker (LinearMap.lsmul ℤ A n)

/-- The quotient A/nA for a ℤ-module A. -/
def quotientByN (A : Type*) [AddCommGroup A] [Module ℤ A] (n : ℤ) :=
  A ⧸ (Submodule.span ℤ {a | ∃ x : A, n • x = a} : Submodule ℤ A)

/-- The image of multiplication by n in A, viewed as a submodule. -/
def nImage (A : Type*) [AddCommGroup A] [Module ℤ A] (n : ℤ) : Submodule ℤ A :=
  LinearMap.range (LinearMap.lsmul ℤ A n)

/-- A/nA defined as the quotient by the image of n. -/
abbrev AModNA (A : Type*) [AddCommGroup A] [Module ℤ A] (n : ℤ) :=
  A ⧸ nImage A n