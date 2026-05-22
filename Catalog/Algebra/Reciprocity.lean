/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Catalog.Algebra.LanglandsGL1.Defs
import Catalog.Algebra.LanglandsGL1.Valuations

/-!
# Artin Reciprocity and GL(1) Langlands Correspondence over ℚ

## Main results

- `artinMap`: The Artin reciprocity isomorphism (ℤ/nℤ)ˣ ≅ Gal(ℚ(ζ_n)/ℚ).
- `artinMap_frobenius`: The Artin map sends p to the Frobenius.
- `artinMap_cong_one_eq_one`: Elements ≡ 1 mod n map to identity.
- `gl1_langlands_Q_finite_level`: The GL(1) Langlands equivalence.
- `langlands_frobenius_compat`: Compatibility with Frobenius evaluation.
- `levelRaiseChar`: Change-of-level functoriality for characters.
-/

noncomputable section

open scoped BigOperators

/-! ## The Artin reciprocity map -/

/-- The Artin reciprocity map at level n: the canonical identification
    of (ℤ/nℤ)ˣ with Gal(ℚ(ζ_n)/ℚ). -/
def artinMap (n : ℕ) : (ZMod n)ˣ →* CyclotomicGaloisGroup n :=
  MonoidHom.id _

/-- The Artin map as a group isomorphism. -/
def artinMapEquiv (n : ℕ) : (ZMod n)ˣ ≃* CyclotomicGaloisGroup n :=
  MulEquiv.refl _

/-! ## Frobenius elements -/

/-- The Frobenius element at prime p: ζ_n ↦ ζ_n^p. -/
def frobeniusElement (n p : ℕ) (hcop : Nat.Coprime p n) :
    CyclotomicGaloisGroup n :=
  ZMod.unitOfCoprime p hcop

/-- The Artin map sends p to the Frobenius at p. -/
theorem artinMap_frobenius (n p : ℕ) (hcop : Nat.Coprime p n) :
    artinMap n (ZMod.unitOfCoprime p hcop) = frobeniusElement n p hcop :=
  rfl

/-
Frobenius elements generate the cyclotomic Galois group
    (by Dirichlet's theorem on primes in arithmetic progressions).
-/
theorem frobeniusElement_surjective (n : ℕ) [hn : NeZero n] :
    ∀ σ : CyclotomicGaloisGroup n,
      ∃ (p : ℕ), Nat.Prime p ∧ ∃ (h : Nat.Coprime p n),
        frobeniusElement n p h = σ := by
          intro σ;
          -- By Dirichlet's theorem on primes in arithmetic progressions, there exists a prime $p$ such that $p \equiv a \pmod{n}$.
          obtain ⟨p, hp_prime, hp_cong⟩ : ∃ p : ℕ, Nat.Prime p ∧ p ≡ σ.val.val [MOD n] := by
            have := @Nat.forall_exists_prime_gt_and_eq_mod n;
            obtain ⟨ p, hp₁, hp₂, hp₃ ⟩ := @this hn ( σ : ZMod n ) ( by exact? ) 1 ; exact ⟨ p, hp₂, by simpa [ ← ZMod.natCast_eq_natCast_iff ] using hp₃ ⟩;
          -- Since $p \equiv \sigma.val.val \pmod{n}$, we have $p$ is coprime to $n$.
          have hp_coprime : Nat.Coprime p n := by
            refine' hp_cong.gcd_eq.trans _;
            grind +suggestions;
          refine' ⟨ p, hp_prime, hp_coprime, _ ⟩;
          exact Units.ext <| by simpa [ ZMod.natCast_eq_zero_iff ] using congr_arg ( fun x : ℕ => x : ℕ → ZMod n ) hp_cong;

/-! ## Congruence triviality -/

/-
Elements ≡ 1 (mod n) map to the identity under the Artin map.
-/
theorem artinMap_cong_one_eq_one (n a : ℕ) [NeZero n]
    (hcop : Nat.Coprime a n) (hcong : a ≡ 1 [MOD n]) :
    artinMap n (ZMod.unitOfCoprime a hcop) = 1 := by
      simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ];
      exact Units.ext hcong

/-! ## The GL(1) Langlands statement -/

/-- **GL(1) Langlands over ℚ at finite level.**

    For every n and commutative group A, there is a canonical bijection:
    { Hecke characters of conductor | n } ≃ { 1-dim Galois reps through ℚ(ζ_n)/ℚ } -/
theorem gl1_langlands_Q_finite_level (n : ℕ) (A : Type*) [CommGroup A] :
    Nonempty (HeckeChar n A ≃ GalChar n A) :=
  ⟨langlandsGL1Equiv n A⟩

/-- Langlands GL(1) is compatible with Frobenius evaluation:
    χ(p mod n) = ρ(Frob_p). -/
theorem langlands_frobenius_compat (n p : ℕ) (hcop : Nat.Coprime p n)
    (A : Type*) [CommGroup A] (χ : HeckeChar n A) :
    χ (ZMod.unitOfCoprime p hcop) =
    (langlandsGL1Equiv n A χ) (frobeniusElement n p hcop) :=
  rfl

/-! ## Change of level -/

/-- Level-raising: a character mod m induces one mod n when m ∣ n. -/
def levelRaiseChar (m n : ℕ) (hdvd : m ∣ n) (A : Type*) [CommGroup A]
    (χ : (ZMod m)ˣ →* A) : (ZMod n)ˣ →* A :=
  χ.comp (Units.map (ZMod.castHom hdvd (ZMod m)))

theorem levelRaiseChar_apply (m n : ℕ) (hdvd : m ∣ n) (A : Type*) [CommGroup A]
    (χ : (ZMod m)ˣ →* A) (a : (ZMod n)ˣ) :
    levelRaiseChar m n hdvd A χ a =
      χ (Units.map (ZMod.castHom hdvd (ZMod m)) a) := rfl

/-
Level-raising is functorial.
-/
theorem levelRaiseChar_comp (l m n : ℕ) (hlm : l ∣ m) (hmn : m ∣ n)
    (A : Type*) [CommGroup A] (χ : (ZMod l)ˣ →* A) :
    levelRaiseChar m n hmn A (levelRaiseChar l m hlm A χ) =
    levelRaiseChar l n (dvd_trans hlm hmn) A χ := by
      unfold levelRaiseChar;
      ext;
      cases n <;> simp_all +decide [ ZMod.castHom ];
      · rename_i x;
        cases' Int.units_eq_one_or x with hx hx <;> simp +decide [ hx ];
        convert rfl;
        cases l <;> aesop;
      · congr! 1;
        ext; simp +decide [ ZMod.cast, ZMod.val ] ;
        cases m <;> simp_all +decide [ ZMod ];
        nontriviality;
        cases l <;> simp_all +decide [ ZMod ];
        cases ‹Nontrivial ( Fin _ ) › ; aesop

/-! ## Trivial character and Langlands -/

/-- The trivial Hecke character. -/
def trivialHeckeChar (n : ℕ) (A : Type*) [CommGroup A] : HeckeChar n A := 1

/-- Langlands maps the trivial Hecke character to the trivial Galois representation. -/
theorem langlands_trivial (n : ℕ) (A : Type*) [CommGroup A] :
    langlandsGL1Equiv n A (trivialHeckeChar n A) = (1 : GalChar n A) := rfl

/-! ## Character group structure -/

/-- Pointwise product of two characters. -/
def charMul (n : ℕ) (A : Type*) [CommGroup A]
    (χ₁ χ₂ : (ZMod n)ˣ →* A) : (ZMod n)ˣ →* A where
  toFun a := χ₁ a * χ₂ a
  map_one' := by simp
  map_mul' a b := by simp [map_mul, mul_comm, mul_left_comm]

/-- Langlands GL(1) preserves pointwise products. -/
theorem langlandsGL1_mul_compat (n : ℕ) (A : Type*) [CommGroup A]
    (χ₁ χ₂ : HeckeChar n A) :
    langlandsGL1Equiv n A (charMul n A χ₁ χ₂) =
    charMul n A (langlandsGL1Equiv n A χ₁) (langlandsGL1Equiv n A χ₂) := rfl

end