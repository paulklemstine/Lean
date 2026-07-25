/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Universal Coefficient Theorem: Concrete Cases

This file proves concrete instances of the Universal Coefficient Theorem
for homology over ℤ. The UCT relates homology with coefficients to the
tensor product and Tor of integral homology with the coefficient module:

  0 → H_n(C) ⊗ A → H_n(C; A) → Tor₁(H_{n-1}(C), A) → 0

We prove specific cases using the explicit free resolution of ℤ/nℤ.
-/
import Mathlib
import Algebra.Homology.DerivedFunctors.ExtTorBasic

open TensorProduct

/-! ## The UCT for cyclic groups

The simplest nontrivial case of the universal coefficient theorem
computes the homology with coefficients for a cyclic group.

For a cyclic group of order n (with H₁ = 0 and H₀ = ℤ/nℤ), the UCT gives:
  H₀(C; A) ≅ (ℤ/nℤ ⊗ A) ≅ A/nA
  H₁(C; A) ≅ Tor₁(ℤ/nℤ, A)   (the n-torsion of A)

We prove these isomorphisms concretely.
-/

/-- For the 2-term resolution of ℤ/nℤ, the tensored complex
    A →(·n)→ A has:
    - H₀ = coker(·n) = A/nA
    - H₁ = ker(·n) = n-torsion of A

    This is the content of the universal coefficient theorem
    in this concrete case. -/
theorem uct_concrete_H0 (n : ℤ) (A : Type*) [AddCommGroup A] [Module ℤ A] :
    Nonempty (AModNA A n ≃ₗ[ℤ] A ⧸ nImage A n) :=
  ⟨LinearEquiv.refl ℤ _⟩

/-- The H₁ piece of the UCT: the first homology of the tensored complex
    is the n-torsion of A, which equals Tor₁(ℤ/nℤ, A). -/
theorem uct_concrete_H1 (n : ℤ) (A : Type*) [AddCommGroup A] [Module ℤ A] :
    Nonempty (nTorsion A n ≃ₗ[ℤ] Tor1_ZMod n A) :=
  ⟨LinearEquiv.refl ℤ _⟩

/-! ## UCT for explicit computations -/

/-- The universal coefficient theorem applied to Ext¹(ℤ/nℤ, ℤ/mℤ):
    Ext¹(ℤ/nℤ, ℤ/mℤ) ≅ ℤ/gcd(n,m)ℤ. -/
theorem uct_Ext1_ZMod (n m : ℕ) (hn : 0 < n) (hm : 0 < m) :
    Nonempty (Ext1_ZMod (n : ℤ) (ZMod m) ≃ₗ[ℤ] ZMod (Nat.gcd n m)) :=
  Ext1_ZMod_ZMod_equiv n m hn hm

/-- The UCT applied to Tor₁(ℤ/nℤ, ℤ/mℤ):
    Tor₁(ℤ/nℤ, ℤ/mℤ) ≅ ℤ/gcd(n,m)ℤ. -/
theorem uct_Tor1_ZMod (n m : ℕ) (hn : 0 < n) (hm : 0 < m) :
    Nonempty (Tor1_ZMod (n : ℤ) (ZMod m) ≃ₗ[ℤ] ZMod (Nat.gcd n m)) :=
  Tor1_ZMod_ZMod_equiv n m hn hm

/-! ## Vanishing of Tor for free modules -/

/-
The vanishing of Tor₁ for ℤ: since ℤ is torsion-free,
    Tor₁(ℤ/nℤ, ℤ) = {x ∈ ℤ : n·x = 0} = {0} for n ≠ 0.
-/
theorem nTorsion_int_trivial (n : ℤ) (hn : n ≠ 0) :
    nTorsion ℤ n = ⊥ := by
  simp +decide [ nTorsion, LinearMap.mem_ker ];
  aesop

/-
Tor₁ vanishes for free modules: Tor₁(ℤ/nℤ, ℤ) is trivial for n ≠ 0.
-/
theorem Tor1_vanishes_for_free (n : ℤ) (hn : n ≠ 0) :
    Subsingleton (Tor1_ZMod n ℤ) := by
  -- Apply the fact that the n-torsion of ℤ is trivial when n ≠ 0.
  have h_torsion : nTorsion ℤ n = ⊥ := nTorsion_int_trivial n hn;
  -- Since the bottom submodule is a subsingleton, we can conclude that Tor1_ZMod n ℤ is a subsingleton.
  have h_subsingleton : Subsingleton (nTorsion ℤ n) := by
    exact h_torsion ▸ by infer_instance;
  exact h_subsingleton

/-! ## Ext-Tor duality for cyclic modules

For the 2-term resolution of ℤ/nℤ, we have:
- Ext¹(ℤ/nℤ, A) = A/nA = coker(·n : A → A)
- Tor₁(ℤ/nℤ, A) = nA = ker(·n : A → A)

When A = ℤ/mℤ, both give ℤ/gcd(n,m)ℤ. -/

/-
Ext and Tor agree for cyclic modules: Ext¹(ℤ/nℤ, ℤ/mℤ) ≅ Tor₁(ℤ/nℤ, ℤ/mℤ).
    Both are isomorphic to ℤ/gcd(n,m)ℤ.
-/
theorem Ext_Tor_cyclic_agree (n m : ℕ) (hn : 0 < n) (hm : 0 < m) :
    Nonempty (Ext1_ZMod (n : ℤ) (ZMod m) ≃ₗ[ℤ] Tor1_ZMod (n : ℤ) (ZMod m)) := by
  have := Tor1_ZMod_ZMod_equiv n m hn hm;
  exact ⟨ ( Ext1_ZMod_ZMod_equiv n m hn hm ).some.trans ( this.some.symm ) ⟩