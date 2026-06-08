import Mathlib

/-!
# Tropical Height Rigidity for Berggren Tree Valuations

This module formalizes a valuation-theoretic rigidity principle for the Berggren tree
of primitive Pythagorean triples. The main result is that finite-depth tropical
observables on Berggren orbits admit a decidable rigidity/collision stratification:
either a given observable value determines a unique word/triple, or there exists a
canonical collision certificate.

## Main definitions

* `BerggrenTropical.Gen` — the three Berggren generators {A, B, C}
* `BerggrenTropical.Word` — words in the free monoid on generators
* `BerggrenTropical.ObsVec` — observable vector: archimedean height + p-adic data
* `BerggrenTropical.theta` — the observable map from words to `ObsVec`
* `BerggrenTropical.WordsUpTo` — the finite set of all words of length ≤ d
* `BerggrenTropical.fiber` — preimage fiber of `theta` over `WordsUpTo d`

## Main results

* `fiber_singleton_or_collision` — every nonempty fiber is a singleton or has a collision
* `berggren_theta_decidable_rigidity` — decidable rigidity/collision dichotomy
* `generic_singleton_outside_exceptional` — augmented observables separate generic fibers
-/

open Matrix Finset

namespace BerggrenTropical

/-! ## §1. Berggren Generators and Word Algebra -/

/-- The three Berggren generators for the tree of primitive Pythagorean triples. -/
inductive Gen where
  | A | B | C
  deriving DecidableEq, Repr, Inhabited

instance : Fintype Gen where
  elems := {Gen.A, Gen.B, Gen.C}
  complete := by intro x; cases x <;> simp

/-- A word is a list of generators, representing a path in the Berggren tree. -/
abbrev Word := List Gen

/-- Berggren matrix A: generates one branch of the Pythagorean tree. -/
def genMatA : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B: generates another branch. -/
def genMatB : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix C: generates the third branch. -/
def genMatC : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Map each generator to its 3×3 integer matrix. -/
def genMatrix : Gen → Matrix (Fin 3) (Fin 3) ℤ
  | Gen.A => genMatA
  | Gen.B => genMatB
  | Gen.C => genMatC

/-- Evaluate a word to the product of its generator matrices.
    The empty word maps to the identity matrix. -/
def evalWord : Word → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | g :: w => genMatrix g * evalWord w

/-- The root Pythagorean triple (3, 4, 5). -/
def rootTriple : Fin 3 → ℤ := ![3, 4, 5]

/-- The Pythagorean triple obtained by applying a word to the root. -/
def tripleOfWord (w : Word) : Fin 3 → ℤ :=
  evalWord w *ᵥ rootTriple

/-! ## §2. Observable Functions -/

/-- Archimedean height: maximum absolute value of coordinates. -/
def archHeight (t : Fin 3 → ℤ) : ℕ :=
  max (Int.natAbs (t 0)) (max (Int.natAbs (t 1)) (Int.natAbs (t 2)))

/-- p-adic valuation of the absolute value of a coordinate. -/
def vNatCoord (p : ℕ) (t : Fin 3 → ℤ) (i : Fin 3) : ℕ :=
  padicValNat p (Int.natAbs (t i))

/-- Observable vector: archimedean height together with 2-adic and 3-adic valuations
    of all three coordinates. This provides a "tropical snapshot" of the triple. -/
structure ObsVec where
  arch : ℕ
  v2x : ℕ
  v2y : ℕ
  v2z : ℕ
  v3x : ℕ
  v3y : ℕ
  v3z : ℕ
  deriving DecidableEq, Repr

instance : Inhabited ObsVec := ⟨⟨0, 0, 0, 0, 0, 0, 0⟩⟩

/-- Compute the observable vector of a triple. -/
def obsVecOf (t : Fin 3 → ℤ) : ObsVec where
  arch := archHeight t
  v2x := vNatCoord 2 t 0
  v2y := vNatCoord 2 t 1
  v2z := vNatCoord 2 t 2
  v3x := vNatCoord 3 t 0
  v3y := vNatCoord 3 t 1
  v3z := vNatCoord 3 t 2

/-- The observable map: compose tripleOfWord with obsVecOf. -/
def theta (w : Word) : ObsVec :=
  obsVecOf (tripleOfWord w)

/-! ## §3. Finite Word Sets and Fibers -/

/-- All words of exactly length n over the three generators. -/
def WordsOfLen : ℕ → Finset Word
  | 0 => {[]}
  | n + 1 => (Fintype.elems : Finset Gen).biUnion fun g =>
      (WordsOfLen n).map ⟨(g :: ·), List.cons_injective (a := g)⟩

/-- All words of length at most d. -/
def WordsUpTo (d : ℕ) : Finset Word :=
  (Finset.range (d + 1)).biUnion fun n => WordsOfLen n

/-
Membership in WordsOfLen is equivalent to having the right length.
-/
theorem mem_WordsOfLen (w : Word) (n : ℕ) :
    w ∈ WordsOfLen n ↔ w.length = n := by
  induction n generalizing w <;> simp_all +decide [ WordsOfLen ];
  rcases w with ( _ | ⟨ a, w ⟩ ) <;> simp_all +decide [ Fintype.elems ];
  cases a <;> aesop

/-- Membership in WordsUpTo is equivalent to bounded length. -/
theorem mem_WordsUpTo (w : Word) (d : ℕ) :
    w ∈ WordsUpTo d ↔ w.length ≤ d := by
  simp only [WordsUpTo, Finset.mem_biUnion, Finset.mem_range]
  constructor
  · rintro ⟨n, hn, hw⟩
    rw [mem_WordsOfLen] at hw; omega
  · intro hle
    exact ⟨w.length, by omega, (mem_WordsOfLen w w.length).mpr rfl⟩

/-- The fiber of an observable value: all words of depth ≤ d mapping to that value. -/
def fiber (d : ℕ) (o : ObsVec) : Finset Word :=
  (WordsUpTo d).filter (fun w => theta w = o)

/-- Fiber membership characterization. -/
theorem mem_fiber (d : ℕ) (o : ObsVec) (w : Word) :
    w ∈ fiber d o ↔ w ∈ WordsUpTo d ∧ theta w = o := by
  simp [fiber, Finset.mem_filter]

/-! ## §4. Core Finite-Depth Rigidity Theorem -/

/-- **Finite-Depth Collision Dichotomy (Main Theorem A).**
    For every depth bound `d` and observable value `o`,
    either the fiber is a singleton (rigid) or has a collision. -/
theorem fiber_singleton_or_collision
    (d : ℕ) (o : ObsVec) (hne : (fiber d o).Nonempty) :
    (fiber d o).card = 1 ∨
    ∃ w₁ ∈ fiber d o, ∃ w₂ ∈ fiber d o, w₁ ≠ w₂ := by
  by_cases h : (fiber d o).card = 1
  · left; exact h
  · right
    have hge2 : 2 ≤ (fiber d o).card := by
      have := Finset.Nonempty.card_pos hne; omega
    exact Finset.one_lt_card.mp hge2

/-
**Berggren theta decidable rigidity.**
    Every observable value in the image of θ at depth d admits a decidable
    classification: either a unique preimage or an explicit collision.
-/
theorem berggren_theta_decidable_rigidity
    (d : ℕ) :
    ∀ o ∈ (WordsUpTo d).image theta,
      (∃! w, w ∈ WordsUpTo d ∧ theta w = o) ∨
      (∃ w₁ ∈ WordsUpTo d, ∃ w₂ ∈ WordsUpTo d,
          w₁ ≠ w₂ ∧ theta w₁ = o ∧ theta w₂ = o) := by
  by_contra! h; simp_all +decide [ ExistsUnique ] ;
  grind +splitImp

/-
A singleton fiber yields a unique witness.
-/
theorem singleton_fiber_gives_unique
    (d : ℕ) (o : ObsVec) (h : (fiber d o).card = 1) :
    ∃! w, w ∈ WordsUpTo d ∧ theta w = o := by
  obtain ⟨ w, hw ⟩ := Finset.card_eq_one.mp h; use w; simp_all +decide [ Finset.ext_iff, mem_fiber ] ;

/-
A fiber with card ≥ 2 yields two distinct elements with the same observable.
-/
theorem card_ge_two_gives_collision
    (d : ℕ) (o : ObsVec) (h : 2 ≤ (fiber d o).card) :
    ∃ w₁ ∈ WordsUpTo d, ∃ w₂ ∈ WordsUpTo d,
      w₁ ≠ w₂ ∧ theta w₁ = o ∧ theta w₂ = o := by
  -- Apply the lemma that states if the cardinality of a finset is at least 2, then there exist two distinct elements in the set.
  obtain ⟨w₁, hw₁, w₂, hw₂, hne⟩ := Finset.one_lt_card.mp h;
  exact ⟨ w₁, mem_fiber _ _ _ |>.1 hw₁ |>.1, w₂, mem_fiber _ _ _ |>.1 hw₂ |>.1, hne, mem_fiber _ _ _ |>.1 hw₁ |>.2, mem_fiber _ _ _ |>.1 hw₂ |>.2 ⟩

/-
Positive fiber card iff the observable is in the image.
-/
theorem fiber_card_pos_iff (d : ℕ) (o : ObsVec) :
    0 < (fiber d o).card ↔ o ∈ (WordsUpTo d).image theta := by
  unfold fiber;
  rw [ Finset.card_pos, Finset.nonempty_iff_ne_empty, Ne, Finset.filter_eq_empty_iff ] ; aesop

/-! ## §5. Canonical Representatives and Certified Inversion -/

/-- Certified inversion output: either a unique preimage or a collision. -/
inductive InversionResult (d : ℕ) (o : ObsVec) where
  | unique (w : Word) (hmem : w ∈ WordsUpTo d) (hobs : theta w = o)
      (huniq : ∀ u, u ∈ WordsUpTo d → theta u = o → u = w)
  | collision (w₁ w₂ : Word)
      (h₁mem : w₁ ∈ WordsUpTo d) (h₂mem : w₂ ∈ WordsUpTo d)
      (h₁obs : theta w₁ = o) (h₂obs : theta w₂ = o)
      (hne : w₁ ≠ w₂)
  | empty (hempty : fiber d o = ∅)

/-
Correctness of inversion: a trichotomy always holds.
-/
theorem invertTheta_correct (d : ℕ) (o : ObsVec) :
    (∃ w, w ∈ WordsUpTo d ∧ theta w = o ∧
      ∀ u, u ∈ WordsUpTo d → theta u = o → u = w) ∨
    (∃ w₁ ∈ WordsUpTo d, ∃ w₂ ∈ WordsUpTo d,
      w₁ ≠ w₂ ∧ theta w₁ = o ∧ theta w₂ = o) ∨
    (fiber d o = ∅) := by
  by_cases h : fiber d o = ∅ <;> simp_all +decide;
  obtain ⟨w₁, hw₁⟩ : ∃ w₁, w₁ ∈ fiber d o := by
    exact Finset.nonempty_of_ne_empty h;
  by_cases h_unique : ∀ u ∈ WordsUpTo d, theta u = o → u = w₁;
  · exact Or.inl ⟨ w₁, by rw [ mem_fiber ] at hw₁; exact hw₁.1, by rw [ mem_fiber ] at hw₁; exact hw₁.2, h_unique ⟩;
  · grind

/-! ## §6. Augmented Observables with Modular Data -/

/-- Augmented observable vector: base observable plus mod-5 and mod-7 residues.
    The modular data provides additional separation power for fibers. -/
structure AugObsVec where
  base : ObsVec
  mod5x : ZMod 5
  mod5y : ZMod 5
  mod5z : ZMod 5
  mod7x : ZMod 7
  mod7y : ZMod 7
  mod7z : ZMod 7
  deriving DecidableEq, Repr

instance : Inhabited AugObsVec := ⟨⟨default, 0, 0, 0, 0, 0, 0⟩⟩

/-- Compute the augmented observable vector. -/
def augObsVecOf (t : Fin 3 → ℤ) : AugObsVec where
  base := obsVecOf t
  mod5x := (t 0 : ZMod 5)
  mod5y := (t 1 : ZMod 5)
  mod5z := (t 2 : ZMod 5)
  mod7x := (t 0 : ZMod 7)
  mod7y := (t 1 : ZMod 7)
  mod7z := (t 2 : ZMod 7)

/-- The augmented observable map. -/
def thetaAug (w : Word) : AugObsVec :=
  augObsVecOf (tripleOfWord w)

/-- The augmented fiber. -/
def fiberAug (d : ℕ) (o : AugObsVec) : Finset Word :=
  (WordsUpTo d).filter (fun w => thetaAug w = o)

/-- The exceptional set: augmented observable values with non-singleton fibers. -/
def exceptionalSet (d : ℕ) : Finset AugObsVec :=
  ((WordsUpTo d).image thetaAug).filter (fun o =>
    1 < ((WordsUpTo d).filter (fun w => thetaAug w = o)).card)

/-
**Generic Separation Theorem (Main Theorem C).**
    Outside the exceptional set, every augmented observable fiber is a singleton.
-/
theorem generic_singleton_outside_exceptional
    (d : ℕ) {o : AugObsVec}
    (ho : o ∈ (WordsUpTo d).image thetaAug)
    (hnot : o ∉ exceptionalSet d) :
    ∃! w, w ∈ WordsUpTo d ∧ thetaAug w = o := by
  have h_card : ((WordsUpTo d).filter (fun w => thetaAug w = o)).card ≤ 1 := by
    unfold exceptionalSet at hnot; aesop;
  obtain ⟨ w, hw ⟩ := Finset.mem_image.mp ho;
  rw [ Finset.card_le_one_iff ] at h_card;
  exact ⟨ w, hw, fun x hx => h_card ( by aesop ) ( by aesop ) ⟩

/-! ## §7. Tropical Valuation Properties -/

/-- The p-adic valuation is additive on products.
    This is the fundamental "tropical functor" property. -/
theorem padic_val_mul_nat (p a b : ℕ) (hp : Nat.Prime p)
    (ha : a ≠ 0) (hb : b ≠ 0) :
    padicValNat p (a * b) = padicValNat p a + padicValNat p b := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact padicValNat.mul ha hb

/-- Valuation of a prime power. -/
theorem padic_val_prime_pow (p k : ℕ) (hp : Nat.Prime p) :
    padicValNat p (p ^ k) = k := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact padicValNat.prime_pow k

/-- The root triple (3,4,5) is a Pythagorean triple. -/
theorem root_is_pythagorean :
    rootTriple 0 ^ 2 + rootTriple 1 ^ 2 = rootTriple 2 ^ 2 := by
  native_decide

/-- evalWord of the empty word is the identity matrix. -/
theorem evalWord_nil : evalWord [] = (1 : Matrix (Fin 3) (Fin 3) ℤ) := rfl

/-- evalWord is a monoid homomorphism (concatenation → product). -/
theorem evalWord_append (w₁ w₂ : Word) :
    evalWord (w₁ ++ w₂) = evalWord w₁ * evalWord w₂ := by
  induction w₁ with
  | nil => simp [evalWord]
  | cons g w₁ ih =>
    simp only [List.cons_append, evalWord, ih, Matrix.mul_assoc]

/-- tripleOfWord of the empty word is the root triple. -/
theorem tripleOfWord_nil : tripleOfWord [] = rootTriple := by
  simp [tripleOfWord, evalWord]

/-! ## §8. Concrete Computational Verification -/

/-- The triple for word [A] is (5, 12, 13). -/
theorem tripleOfWord_A : tripleOfWord [Gen.A] = ![5, 12, 13] := by native_decide

/-- The triple for word [B] is (21, 20, 29). -/
theorem tripleOfWord_B : tripleOfWord [Gen.B] = ![21, 20, 29] := by native_decide

/-- The triple for word [C] is (15, 8, 17). -/
theorem tripleOfWord_C : tripleOfWord [Gen.C] = ![15, 8, 17] := by native_decide

/-- The observables for the three depth-1 words are all distinct,
    demonstrating rigidity at depth 1. -/
theorem depth1_all_rigid :
    theta [Gen.A] ≠ theta [Gen.B] ∧
    theta [Gen.A] ≠ theta [Gen.C] ∧
    theta [Gen.B] ≠ theta [Gen.C] := by native_decide

/-- The augmented observables for depth-1 words are all distinct. -/
theorem depth1_aug_all_rigid :
    thetaAug [Gen.A] ≠ thetaAug [Gen.B] ∧
    thetaAug [Gen.A] ≠ thetaAug [Gen.C] ∧
    thetaAug [Gen.B] ≠ thetaAug [Gen.C] := by native_decide

end BerggrenTropical