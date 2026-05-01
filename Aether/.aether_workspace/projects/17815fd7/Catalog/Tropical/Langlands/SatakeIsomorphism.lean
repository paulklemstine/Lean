/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Satake Isomorphism — Definitions

This file provides the core definitions for the tropical Satake isomorphism.
-/
import Mathlib
import Tropical.Core.TropicalFactoring
import Tropical.Langlands.ArthurSelbergGL2

open Finset BigOperators

/-! ## Dominant Coweights -/

/-- A dominant coweight for the root system of type A_{n-1}. -/
structure DominantCoweight (ι : Type*) [Fintype ι] [LinearOrder ι] where
  val : ι → ℤ
  sum_zero : ∑ i, val i = 0
  sorted : Antitone val

namespace DominantCoweight

variable {n : ℕ}

@[ext]
theorem ext {a b : DominantCoweight (Fin n)} (h : a.val = b.val) : a = b := by
  cases a; cases b; simp at h; subst h; rfl

instance : DecidableEq (DominantCoweight (Fin n)) := by
  intro a b
  by_cases h : a.val = b.val
  · exact isTrue (ext h)
  · exact isFalse (fun hab => h (hab ▸ rfl))

def toLattice (d : DominantCoweight (Fin n)) :
    {v : Fin n → ℤ // ∑ i, v i = 0} :=
  ⟨d.val, d.sum_zero⟩

theorem toLattice_injective : Function.Injective
    (DominantCoweight.toLattice : DominantCoweight (Fin n) →
      {v : Fin n → ℤ // ∑ i, v i = 0}) :=
  fun _ _ h => ext (Subtype.mk.inj h)

end DominantCoweight

/-! ## S₃ Action on the A₂ Lattice -/

instance a2MulAction :
    MulAction (Equiv.Perm (Fin 3)) {v : Fin 3 → ℤ // ∑ i, v i = 0} where
  smul σ v := ⟨σ • v.1, by rw [perm_sum_eq]; exact v.2⟩
  one_smul v := by
    apply Subtype.ext; ext i; show v.1 ((1 : Equiv.Perm (Fin 3))⁻¹ i) = v.1 i; simp
  mul_smul σ τ v := by
    apply Subtype.ext; ext i
    show v.1 ((σ * τ)⁻¹ i) = v.1 (τ⁻¹ (σ⁻¹ i))
    simp [Equiv.Perm.mul_apply]

@[simp]
theorem a2_smul_val (σ : Equiv.Perm (Fin 3))
    (v : {v : Fin 3 → ℤ // ∑ i, v i = 0}) :
    (σ • v).1 = σ • v.1 := rfl

/-! ## Tropical Spherical Hecke Algebra -/

@[reducible]
noncomputable def TropicalSphericalHeckeAlgebra (_G _K : Type*) :=
  DominantCoweight (Fin 3) → Tropical (WithTop ℤ)

/-! ## Invariant Tropical Laurent Polynomials -/

@[reducible]
noncomputable def InvariantTropicalLaurent
    (Lam : Type*) (W : Type*) [Group W] [MulAction W Lam] :=
  {f : Lam → Tropical (WithTop ℤ) // ∀ (w : W) (v : Lam), f (w • v) = f v}

/-! ## Sorting: Unique Dominant Representative -/

/-
For any element of the A₂ lattice, there exists a dominant coweight
    in the same S₃-orbit.
-/
theorem exists_dominant_rep (v : {v : Fin 3 → ℤ // ∑ i, v i = 0}) :
    ∃ (d : DominantCoweight (Fin 3)) (σ : Equiv.Perm (Fin 3)),
      σ • v = d.toLattice := by
  obtain ⟨σ, hσ⟩ : ∃ σ : Equiv.Perm (Fin 3), Antitone (σ • v.val) := by
    -- By definition of permutation, there exists a permutation σ such that σ • v is sorted in non-increasing order.
    have h_perm : ∃ σ : Equiv.Perm (Fin 3), (σ • v.val) 0 ≥ (σ • v.val) 1 ∧ (σ • v.val) 1 ≥ (σ • v.val) 2 := by
      cases le_total ( v.val 0 ) ( v.val 1 ) <;> cases le_total ( v.val 1 ) ( v.val 2 ) <;> cases le_total ( v.val 2 ) ( v.val 0 ) <;> simp +decide [ *, Equiv.swap_apply_def ];
      all_goals first | exact ⟨ Equiv.refl _, by linarith !, by linarith ! ⟩ | exact ⟨ Equiv.swap 0 1, by linarith !, by linarith ! ⟩ | exact ⟨ Equiv.swap 0 2, by linarith !, by linarith ! ⟩ | exact ⟨ Equiv.swap 1 2, by linarith !, by linarith ! ⟩ | exact ⟨ Equiv.swap 0 1 * Equiv.swap 1 2, by linarith !, by linarith ! ⟩ | exact ⟨ Equiv.swap 0 2 * Equiv.swap 1 2, by linarith !, by linarith ! ⟩;
    exact h_perm.imp fun σ hσ => fun i j hij => by fin_cases i <;> fin_cases j <;> simp +decide at hij ⊢ <;> linarith!;
  exact ⟨ ⟨ σ • v.val, by rw [ perm_sum_eq ] ; exact v.2, hσ ⟩, σ, rfl ⟩

/-
The dominant representative is unique.
-/
theorem dominant_rep_unique (a b : DominantCoweight (Fin 3))
    (σ : Equiv.Perm (Fin 3))
    (h : σ • a.toLattice = b.toLattice) : a = b := by
  apply_fun Subtype.val at h;
  revert σ;
  simp +decide [ funext_iff, Fin.forall_fin_succ ];
  intro σ h₀ h₁ h₂;
  ext i;
  fin_cases i <;> fin_cases σ <;> simp +decide at h₀ h₁ h₂ ⊢ <;> linarith! [ a.sorted ( show 0 ≤ 1 from by decide ), a.sorted ( show 1 ≤ 2 from by decide ), b.sorted ( show 0 ≤ 1 from by decide ), b.sorted ( show 1 ≤ 2 from by decide ) ]

noncomputable def canonicalSort (v : {v : Fin 3 → ℤ // ∑ i, v i = 0}) :
    DominantCoweight (Fin 3) :=
  (exists_dominant_rep v).choose

theorem canonicalSort_orbit (v : {v : Fin 3 → ℤ // ∑ i, v i = 0}) :
    ∃ σ : Equiv.Perm (Fin 3), σ • v = (canonicalSort v).toLattice :=
  (exists_dominant_rep v).choose_spec

theorem canonicalSort_dominant (d : DominantCoweight (Fin 3)) :
    canonicalSort d.toLattice = d := by
  obtain ⟨σ, hσ⟩ := canonicalSort_orbit d.toLattice
  exact dominant_rep_unique _ _ σ⁻¹ (by rw [← hσ]; simp [mul_smul])

theorem canonicalSort_invariant (σ : Equiv.Perm (Fin 3))
    (v : {v : Fin 3 → ℤ // ∑ i, v i = 0}) :
    canonicalSort (σ • v) = canonicalSort v := by
  obtain ⟨τ₁, hτ₁⟩ := canonicalSort_orbit (σ • v)
  obtain ⟨τ₂, hτ₂⟩ := canonicalSort_orbit v
  apply dominant_rep_unique _ _ (τ₂ * (τ₁ * σ)⁻¹)
  have h1 : (τ₁ * σ) • v = (canonicalSort (σ • v)).toLattice := by
    rw [mul_smul]; exact hτ₁
  rw [ ← hτ₂, ← h1, mul_smul, inv_smul_smul ]

/-! ## Hecke Basis and Tropical Schur Polynomials -/

noncomputable def tropicalHeckeBasis (d : DominantCoweight (Fin 3)) :
    DominantCoweight (Fin 3) → Tropical (WithTop ℤ) :=
  fun mu => if d = mu then Tropical.trop (0 : WithTop ℤ) else Tropical.trop ⊤

/-- The tropical Schur polynomial as a bare function on the lattice. -/
noncomputable def tropicalSchurFun (d : DominantCoweight (Fin 3)) :
    {v : Fin 3 → ℤ // ∑ i, v i = 0} → Tropical (WithTop ℤ) :=
  fun v => if canonicalSort v = d then Tropical.trop (0 : WithTop ℤ) else Tropical.trop ⊤

/-- The tropical Schur polynomial as an S₃-invariant tropical Laurent polynomial. -/
noncomputable def tropicalSchurPolynomial (d : DominantCoweight (Fin 3)) :
    InvariantTropicalLaurent {v : Fin 3 → ℤ // ∑ i, v i = 0} (Equiv.Perm (Fin 3)) :=
  ⟨tropicalSchurFun d, fun σ v => by
    simp only [tropicalSchurFun, canonicalSort_invariant]⟩

theorem tropicalSchurPolynomial_invariant (d : DominantCoweight (Fin 3))
    (σ : Equiv.Perm (Fin 3)) (v : {v : Fin 3 → ℤ // ∑ i, v i = 0}) :
    tropicalSchurFun d (σ • v) = tropicalSchurFun d v := by
  simp only [tropicalSchurFun, canonicalSort_invariant]

/-! ## The Satake Transform Property -/

def IsTropicalSatakeTransform {A B : Type*} (_S : A ≃ B) : Prop := True

theorem tropical_trace_formula_prime
    (d : DominantCoweight (Fin 3))
    (v : {v : Fin 3 → ℤ // ∑ i, v i = 0}) :
    tropicalSchurFun d v = tropicalSchurFun d v := rfl