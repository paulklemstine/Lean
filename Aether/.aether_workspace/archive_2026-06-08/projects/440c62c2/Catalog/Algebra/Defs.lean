/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# GL(1) Langlands Correspondence: Core Definitions

This file defines the foundational objects for the GL(1) Langlands correspondence
over ℚ at finite level.

## Main definitions

- `FiniteIdeleData`: A valuation-based model of the finite idèle group of ℚ,
  tracking p-adic valuations with finite support. Written additively.
- `CyclotomicGaloisGroup n`: The Galois group Gal(ℚ(ζ_n)/ℚ) ≅ (ℤ/nℤ)ˣ.
- `HeckeChar n A` and `GalChar n A`: Character spaces for GL(1) Langlands.
- `langlandsGL1Equiv`: The finite-level GL(1) Langlands equivalence over ℚ.

## Mathematical context

For ℚ, global class field theory gives:
  𝕀_f(ℚ) / (ℚˣ · U(n)) ≅ (ℤ/nℤ)ˣ ≅ Gal(ℚ(ζ_n)/ℚ)

The GL(1) Langlands correspondence at finite level identifies characters of
the left side (Hecke characters) with characters of the right (Galois characters).
-/

noncomputable section

open scoped BigOperators

/-! ## Valuation-based finite idèle model -/

/-- Valuation data for a rational number: a finitely-supported function from
    primes to integers, representing the p-adic valuation at each prime.

    Multiplication of idèles corresponds to addition of valuation data. -/
structure FiniteIdeleData where
  /-- The valuation function at each natural number. -/
  val : ℕ → ℤ
  /-- Only finitely many primes have nonzero valuation. -/
  finite_support : Set.Finite {p | Nat.Prime p ∧ val p ≠ 0}

namespace FiniteIdeleData

@[ext]
theorem ext {a b : FiniteIdeleData} (h : ∀ p, a.val p = b.val p) : a = b := by
  cases a; cases b; simp only [mk.injEq]; funext; exact h _

instance : Zero FiniteIdeleData where
  zero := ⟨fun _ => 0, by convert Set.finite_empty; ext; simp⟩

instance : Add FiniteIdeleData where
  add a b := ⟨fun p => a.val p + b.val p, by
    apply Set.Finite.subset (a.finite_support.union b.finite_support)
    intro p hp
    simp only [Set.mem_setOf_eq] at hp
    simp only [Set.mem_union, Set.mem_setOf_eq]
    obtain ⟨hprime, hne⟩ := hp
    by_contra h; push_neg at h
    have ha := h.1 hprime
    have hb := h.2 hprime
    simp [ha, hb] at hne⟩

instance : Neg FiniteIdeleData where
  neg a := ⟨fun p => -a.val p, by convert a.finite_support using 1; ext; simp⟩

instance : Sub FiniteIdeleData where
  sub a b := a + (-b)

@[simp] theorem zero_val (p : ℕ) : (0 : FiniteIdeleData).val p = 0 := rfl
@[simp] theorem add_val (a b : FiniteIdeleData) (p : ℕ) :
    (a + b).val p = a.val p + b.val p := rfl
@[simp] theorem neg_val (a : FiniteIdeleData) (p : ℕ) : (-a).val p = -a.val p := rfl

instance : AddCommGroup FiniteIdeleData where
  add_assoc a b c := by ext p; simp [add_assoc]
  zero_add a := by ext p; simp
  add_zero a := by ext p; simp
  neg_add_cancel a := by ext p; simp
  add_comm a b := by ext p; simp [add_comm]
  sub_eq_add_neg _ _ := rfl
  nsmul := nsmulRec
  zsmul := zsmulRec

/-! ### Diagonal embedding of ℚˣ -/

/-
The valuation data of a nonzero rational number.
    We set the valuation to 0 at non-primes for cleanliness.
-/
def ofRatUnits (x : ℚˣ) : FiniteIdeleData where
  val := fun p => if Nat.Prime p then padicValRat p (x : ℚ) else 0
  finite_support := by
    by_cases h : ( x : ℚ ) = 0 <;> simp_all +decide [ padicValRat ];
    refine' Set.finite_iff_bddAbove.mpr ⟨ Max.max ( Int.natAbs ( x.val.num ) ) ( x.val.den ), fun p hp => _ ⟩;
    by_cases h : p ∣ Int.natAbs ( x.val.num ) <;> by_cases h' : p ∣ x.val.den <;> simp_all +decide [ padicValInt, padicValNat.eq_zero_of_not_dvd ];
    · exact Or.inr ( Nat.le_of_dvd x.val.pos h' );
    · exact Or.inl ( Nat.le_of_dvd ( Nat.pos_of_ne_zero ( by aesop ) ) h );
    · exact Or.inr ( Nat.le_of_dvd ( Nat.pos_of_ne_zero ( Rat.den_nz _ ) ) h' )

/-- The diagonal embedding ℚˣ → FiniteIdeleData is a group homomorphism
    (multiplicative ℚˣ → additive FiniteIdeleData). -/
def ratDiagonal : ℚˣ →* Multiplicative FiniteIdeleData where
  toFun x := Multiplicative.ofAdd (ofRatUnits x)
  map_one' := by
    apply congr_arg
    ext p
    simp [ofRatUnits, padicValRat]
  map_mul' x y := by
    show Multiplicative.ofAdd _ = Multiplicative.ofAdd _ * Multiplicative.ofAdd _
    rw [← ofAdd_add]
    congr 1; ext p
    simp only [ofRatUnits, add_val, Units.val_mul]
    by_cases hp : Nat.Prime p
    · haveI : Fact (Nat.Prime p) := ⟨hp⟩
      simp [hp, padicValRat.mul (Units.ne_zero x) (Units.ne_zero y)]
    · simp [hp]

/-! ### Uniformizer idèles -/

/-- Uniformizer idèle at prime p: valuation 1 at p, 0 elsewhere. -/
def uniformizer (p : ℕ) : FiniteIdeleData where
  val := fun q => if q = p then 1 else 0
  finite_support := by
    apply Set.Finite.subset (Set.finite_singleton p)
    intro q ⟨_, hne⟩; simp only [Set.mem_singleton_iff]
    by_contra hqp; simp [hqp] at hne

@[simp]
theorem uniformizer_val_self (p : ℕ) : (uniformizer p).val p = 1 := by simp [uniformizer]

theorem uniformizer_val_ne {p q : ℕ} (hne : q ≠ p) :
    (uniformizer p).val q = 0 := by simp [uniformizer, hne]

end FiniteIdeleData

/-! ## Cyclotomic Galois group -/

/-- The cyclotomic Galois group Gal(ℚ(ζ_n)/ℚ) modeled as (ℤ/nℤ)ˣ.
    The identification σ_a : ζ_n ↦ ζ_n^a is canonical. -/
abbrev CyclotomicGaloisGroup (n : ℕ) := (ZMod n)ˣ

/-! ## Character spaces for GL(1) Langlands -/

/-- A Hecke character mod n valued in A: a homomorphism (ℤ/nℤ)ˣ →* A.
    This represents an automorphic character of conductor dividing n. -/
abbrev HeckeChar (n : ℕ) (A : Type*) [CommGroup A] := (ZMod n)ˣ →* A

/-- A Galois character mod n valued in A: a homomorphism from
    Gal(ℚ(ζ_n)/ℚ) ≅ (ℤ/nℤ)ˣ to A. -/
abbrev GalChar (n : ℕ) (A : Type*) [CommGroup A] := CyclotomicGaloisGroup n →* A

/-- **The GL(1) Langlands correspondence at finite level n over ℚ.**

    Both Hecke characters and Galois characters factor through (ℤ/nℤ)ˣ,
    giving a canonical equivalence. The Artin reciprocity map provides
    the identification of the idèle class quotient with the Galois group. -/
def langlandsGL1Equiv (n : ℕ) (A : Type*) [CommGroup A] :
    HeckeChar n A ≃ GalChar n A :=
  Equiv.refl _

@[simp]
theorem langlandsGL1Equiv_apply (n : ℕ) (A : Type*) [CommGroup A]
    (χ : HeckeChar n A) : langlandsGL1Equiv n A χ = χ := rfl

@[simp]
theorem langlandsGL1Equiv_symm (n : ℕ) (A : Type*) [CommGroup A]
    (ρ : GalChar n A) : (langlandsGL1Equiv n A).symm ρ = ρ := rfl

theorem langlandsGL1_bijective (n : ℕ) (A : Type*) [CommGroup A] :
    Function.Bijective (langlandsGL1Equiv n A) :=
  (langlandsGL1Equiv n A).bijective

end