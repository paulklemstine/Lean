/-
# Ultrametric Observer–Code Duality via Prime-Congruence Proof Codes

This file formalizes the duality between **finite ultrametric observer geometries**
and **prime-congruence code systems**. The central result is that every finite
ℕ-valued ultrametric space gives rise to a canonical nested family of equivalence
relations—a "prime-congruence code"—and this code faithfully represents and is
uniquely determined by the ultrametric separation data.

## Main Results

### Structures
* `FiniteObserverSystem` — finite set with ℕ-valued ultrametric distance
* `PrimeCongruenceCode` — code type with nested level equivalences
* `CodeIso` — level-preserving isomorphism between codes

### Theorems
* `levelRel_equivalence` — each level relation is an equivalence relation
* `levelRel_mono` — the family of level relations is nested
* `levelRel_zero_iff` — level-0 equivalence = equality
* `canonicalCode_correct` — the canonical code faithfully represents separation
* `exists_primeCongruenceCode` — existence of a faithful prime-congruence code
* `sep_isosceles` — ultrametric isosceles triangle theorem
* `sep_determines_levelRel` — separation uniquely determines all level relations
* `faithful_code_same_partition` — any faithful code gives same partition as levelRel
* `valDist_ultrametric` — the ℚ-valued ultrametric inequality
* `expDist_ultrametric` — exponential ultrametric distance inequality

## Conventions

We use `sep` as a **distance** (higher value = more separated, `sep x x = 0`),
with the ultrametric inequality `sep(x,z) ≤ max(sep(x,y), sep(y,z))`.
The level relation `levelRel n x y := sep x y ≤ n` produces *coarser* partitions
for larger `n`, corresponding to the dendrogram structure where finer levels
have smaller radius.
-/

import Mathlib

set_option maxHeartbeats 800000

open Finset Function

noncomputable section

universe u

/-! ## §1. Finite Observer Systems -/

/-- A `FiniteObserverSystem` on a type `O` is a finite ultrametric space
where the distance takes values in `ℕ`. -/
structure FiniteObserverSystem (O : Type u) where
  instFintype   : Fintype O
  instDecEq     : DecidableEq O
  sep           : O → O → ℕ
  sep_self      : ∀ x, sep x x = 0
  sep_symm      : ∀ x y, sep x y = sep y x
  sep_ultra     : ∀ x y z, sep x z ≤ max (sep x y) (sep y z)
  sep_pos_of_ne : ∀ {x y}, x ≠ y → 0 < sep x y

attribute [instance] FiniteObserverSystem.instFintype FiniteObserverSystem.instDecEq

variable {O : Type u}

/-- `sep` is zero iff elements are equal. -/
theorem FiniteObserverSystem.sep_eq_zero_iff (S : FiniteObserverSystem O) (x y : O) :
    S.sep x y = 0 ↔ x = y := by
  constructor
  · intro h; by_contra hne; exact Nat.not_lt.mpr (Nat.le_of_eq h) (S.sep_pos_of_ne hne)
  · rintro rfl; exact S.sep_self x

/-! ## §2. Level Relations — The Prime-Congruence Filtration -/

/-- The level-`n` equivalence relation: `x` and `y` are `n`-equivalent iff
their separation is at most `n`. -/
def levelRel (S : FiniteObserverSystem O) (n : ℕ) (x y : O) : Prop :=
  S.sep x y ≤ n

instance levelRel.decidable (S : FiniteObserverSystem O) (n : ℕ) :
    DecidableRel (levelRel S n) :=
  fun x y => Nat.decLe (S.sep x y) n

/-- Level-0 equivalence characterizes equality. -/
theorem levelRel_zero_iff (S : FiniteObserverSystem O) (x y : O) :
    levelRel S 0 x y ↔ x = y := by
  simp [levelRel, S.sep_eq_zero_iff]

/-- Each level relation is an equivalence relation. -/
theorem levelRel_equivalence (S : FiniteObserverSystem O) (n : ℕ) :
    Equivalence (levelRel S n) where
  refl x := by simp [levelRel, S.sep_self]
  symm h := by rwa [levelRel, S.sep_symm]
  trans h1 h2 := le_trans (S.sep_ultra _ _ _) (max_le h1 h2)

/-- Monotonicity: the family coarsens as the level increases. -/
theorem levelRel_mono (S : FiniteObserverSystem O) {m n : ℕ} (h : m ≤ n)
    {x y : O} (hmxy : levelRel S m x y) : levelRel S n x y :=
  le_trans hmxy h

/-- The level relation exactly characterizes separation (definitional). -/
theorem levelRel_iff (S : FiniteObserverSystem O) (n : ℕ) (x y : O) :
    levelRel S n x y ↔ S.sep x y ≤ n := Iff.rfl

/-- The level relations completely determine the separation function. -/
theorem sep_determines_levelRel (S₁ S₂ : FiniteObserverSystem O)
    (h : ∀ n x y, levelRel S₁ n x y ↔ levelRel S₂ n x y) :
    ∀ x y, S₁.sep x y = S₂.sep x y := by
  intro x y
  by_contra hne
  rcases Nat.lt_or_gt_of_ne hne with hlt | hlt
  · have := (h (S₁.sep x y) x y).mp (le_refl _)
    exact Nat.not_lt.mpr this hlt
  · have := (h (S₂.sep x y) x y).mpr (le_refl _)
    exact Nat.not_lt.mpr this hlt

/-! ## §3. Setoid Structure and Level Partitions -/

/-- The `Setoid` at level `n`. -/
def levelSetoid (S : FiniteObserverSystem O) (n : ℕ) : Setoid O where
  r := levelRel S n
  iseqv := levelRel_equivalence S n

/-- The number of equivalence classes at level `n`. -/
def numLevelClasses (S : FiniteObserverSystem O) (n : ℕ) : ℕ :=
  @Fintype.card (Quotient (levelSetoid S n))
    (@Quotient.fintype O S.instFintype (levelSetoid S n)
      (fun a b => levelRel.decidable S n a b))

/-
At level 0, every element is its own class.
-/
theorem numLevelClasses_zero (S : FiniteObserverSystem O) :
    numLevelClasses S 0 = @Fintype.card O S.instFintype := by
      convert Fintype.card_eq.mpr _;
      refine' ⟨ Equiv.ofBijective _ ⟨ _, _ ⟩ ⟩;
      refine' fun q => Quotient.liftOn' q ( fun x => x ) fun x y hxy => _;
      exact Classical.not_not.1 fun h => S.sep_pos_of_ne h |> not_le_of_gt <| hxy;
      · intro q₁ q₂ h; induction q₁ using Quotient.inductionOn' ; induction q₂ using Quotient.inductionOn' ; aesop;
      · exact fun x => ⟨ ⟦x⟧, rfl ⟩

/-
The number of classes is monotone decreasing.
-/
theorem numLevelClasses_antitone (S : FiniteObserverSystem O) {m n : ℕ} (h : m ≤ n) :
    numLevelClasses S n ≤ numLevelClasses S m := by
      -- Consider the map from the quotient set at level `m` to the quotient set at level `n`.
      let f : Quotient (levelSetoid S m) → Quotient (levelSetoid S n) := fun q => Quotient.map' id (by
      exact fun x y hxy => levelRel_mono S h hxy) q
      generalize_proofs at *;
      have hf_surjective : Function.Surjective f := by
        intro q
        obtain ⟨x, hx⟩ := Quotient.exists_rep q
        use Quotient.mk'' x
        simp [f];
        exact hx;
      convert Fintype.card_le_of_surjective f hf_surjective

/-! ## §4. Ultrametric Isosceles Triangle Theorem -/

/-
**Ultrametric isosceles theorem**: if `sep(x,y) ≠ sep(y,z)`, then
`sep(x,z) = max(sep(x,y), sep(y,z))`. Among three pairwise separations,
the two largest are always equal.
-/
theorem sep_isosceles (S : FiniteObserverSystem O) (x y z : O)
    (hne : S.sep x y ≠ S.sep y z) :
    S.sep x z = max (S.sep x y) (S.sep y z) := by
      cases max_cases ( S.sep x y ) ( S.sep y z ) <;> cases lt_or_gt_of_ne hne <;> simp_all +decide;
      · linarith;
      · have := S.sep_ultra x y z; have := S.sep_ultra x z y; simp_all +decide [ le_of_lt ] ;
        cases this <;> linarith [ S.sep_symm y z ];
      · apply le_antisymm;
        · exact le_trans ( S.sep_ultra _ _ _ ) ( max_le ( by linarith ) ( by linarith ) );
        · have := S.sep_ultra y x z; simp_all +decide [ le_of_lt ] ;
          exact this.resolve_left ( by linarith [ S.sep_symm x y ] );
      · lia

/-- Corollary: among three pairwise separations, the two largest are equal. -/
theorem sep_two_largest_equal (S : FiniteObserverSystem O) (x y z : O) :
    S.sep x y = S.sep y z ∨
    S.sep x z = max (S.sep x y) (S.sep y z) := by
  by_cases h : S.sep x y = S.sep y z
  · exact Or.inl h
  · exact Or.inr (sep_isosceles S x y z h)

/-! ## §5. Prime Congruence Code Structure -/

/-- A `PrimeCongruenceCode` provides a code type with a nested family of
decidable equivalence relations and a coding map. -/
structure PrimeCongruenceCode (O : Type u) where
  Code          : Type u
  instFintypeC  : Fintype Code
  instDecEqC    : DecidableEq Code
  levelEq       : ℕ → Code → Code → Prop
  levelEq_dec   : ∀ n, DecidableRel (levelEq n)
  code          : O → Code
  levelEq_equiv : ∀ n, Equivalence (levelEq n)
  levelEq_mono  : ∀ {m n : ℕ}, m ≤ n → ∀ a b, levelEq m a b → levelEq n a b

attribute [instance] PrimeCongruenceCode.instFintypeC PrimeCongruenceCode.instDecEqC

/-- A code is **faithful** if `levelEq n (code x) (code y) ↔ sep(x,y) ≤ n`. -/
def PrimeCongruenceCode.IsFaithful (S : FiniteObserverSystem O)
    (C : PrimeCongruenceCode O) : Prop :=
  ∀ n x y, C.levelEq n (C.code x) (C.code y) ↔ S.sep x y ≤ n

/-! ## §6. Canonical Code Construction -/

/-- The **canonical code**: `O` as code type, identity coding, `levelRel` as levels. -/
def canonicalCode (S : FiniteObserverSystem O) : PrimeCongruenceCode O where
  Code := O
  instFintypeC := S.instFintype
  instDecEqC := S.instDecEq
  levelEq := levelRel S
  levelEq_dec := fun n => levelRel.decidable S n
  code := id
  levelEq_equiv := levelRel_equivalence S
  levelEq_mono := fun h _ _ hab => levelRel_mono S h hab

/-- The canonical code is faithful. -/
theorem canonicalCode_correct (S : FiniteObserverSystem O) :
    (canonicalCode S).IsFaithful S :=
  fun _ _ _ => Iff.rfl

/-- **Theorem 1 (Representation)**: Every finite observer system admits
a faithful prime-congruence code. -/
theorem exists_primeCongruenceCode (S : FiniteObserverSystem O) :
    ∃ C : PrimeCongruenceCode O, C.IsFaithful S :=
  ⟨canonicalCode S, canonicalCode_correct S⟩

/-! ## §7. Faithful Codes and Partition Uniqueness -/

/-- Any faithful code induces the same equivalence as `levelRel`. -/
theorem faithful_code_same_partition (S : FiniteObserverSystem O)
    (C : PrimeCongruenceCode O) (hC : C.IsFaithful S)
    (n : ℕ) (x y : O) :
    C.levelEq n (C.code x) (C.code y) ↔ levelRel S n x y :=
  hC n x y

/-- Two faithful codes agree on equivalence of any pair. -/
theorem two_faithful_codes_agree (S : FiniteObserverSystem O)
    (C₁ C₂ : PrimeCongruenceCode O)
    (hC₁ : C₁.IsFaithful S) (hC₂ : C₂.IsFaithful S)
    (n : ℕ) (x y : O) :
    C₁.levelEq n (C₁.code x) (C₁.code y) ↔
    C₂.levelEq n (C₂.code x) (C₂.code y) := by
  rw [hC₁, hC₂]

/-
A faithful code's coding map is injective.
-/
theorem faithful_code_injective (S : FiniteObserverSystem O)
    (C : PrimeCongruenceCode O) (hC : C.IsFaithful S) :
    Function.Injective C.code := by
      intro x y hxy
      have h_eq : ∀ n, C.levelEq n (C.code x) (C.code y) := by
        exact fun n => hxy.symm ▸ ( C.levelEq_equiv n ).refl _;
      exact Classical.byContradiction fun h => by have := hC 0 x y; have := h_eq 0; have := S.sep_pos_of_ne h; aesop;

/-! ## §8. Rational-Valued Ultrametric Distance -/

/-- The ℚ-valued ultrametric distance. -/
def valDist (S : FiniteObserverSystem O) (x y : O) : ℚ :=
  (S.sep x y : ℚ)

/-- Identity of indiscernibles for ℚ-valued distance. -/
theorem valDist_eq_zero_iff (S : FiniteObserverSystem O) (x y : O) :
    valDist S x y = 0 ↔ x = y := by
  simp [valDist, Nat.cast_eq_zero, S.sep_eq_zero_iff]

/-- Symmetry for ℚ-valued distance. -/
theorem valDist_symm (S : FiniteObserverSystem O) (x y : O) :
    valDist S x y = valDist S y x := by
  simp [valDist, S.sep_symm]

/-
**Ultrametric inequality** for ℚ-valued distance.
-/
theorem valDist_ultrametric (S : FiniteObserverSystem O) (x y z : O) :
    valDist S x z ≤ max (valDist S x y) (valDist S y z) := by
      convert S.sep_ultra x y z using 1;
      unfold valDist;
      norm_cast

/-! ## §9. Level-Preserving Code Isomorphisms -/

/-- A `CodeIso` between two codes is a type equivalence that preserves
level equivalences and commutes with coding maps. -/
structure CodeIso (C₁ C₂ : PrimeCongruenceCode O) where
  toEquiv : C₁.Code ≃ C₂.Code
  respects_levels :
    ∀ n a b, C₁.levelEq n a b ↔ C₂.levelEq n (toEquiv a) (toEquiv b)
  respects_code :
    ∀ x : O, toEquiv (C₁.code x) = C₂.code x

/-! ## §10. Maximum Separation and Bounded Levels -/

/-- The maximum separation in a finite observer system. -/
def maxSep (S : FiniteObserverSystem O) [Nonempty O] : ℕ := by
  haveI := S.instFintype
  exact Finset.sup (Finset.univ ×ˢ Finset.univ) (fun p => S.sep p.1 p.2)

/-
All separations are bounded by maxSep.
-/
theorem sep_le_maxSep (S : FiniteObserverSystem O) [Nonempty O] (x y : O) :
    S.sep x y ≤ maxSep S := by
      convert Finset.le_sup ( f := fun p : O × O => S.sep p.1 p.2 ) ( show ( x, y ) ∈ Finset.univ ×ˢ Finset.univ from Finset.mem_product.mpr ⟨ Finset.mem_univ _, Finset.mem_univ _ ⟩ ) using 1

/-- Above maxSep, all elements are equivalent. -/
theorem levelRel_maxSep (S : FiniteObserverSystem O) [Nonempty O]
    {n : ℕ} (hn : maxSep S ≤ n) (x y : O) :
    levelRel S n x y :=
  le_trans (sep_le_maxSep S x y) hn

/-! ## §11. Exponential Ultrametric Distance -/

/-- The exponential ultrametric distance `d(x,y) = 2^{sep(x,y)}`.
In the distance convention, this is monotone and satisfies the ultrametric
inequality directly from `sep_ultra` and monotonicity of exponentiation. -/
def expDist (S : FiniteObserverSystem O) (x y : O) : ℕ :=
  2 ^ S.sep x y

/-- `expDist(x,x) = 1`. -/
theorem expDist_self (S : FiniteObserverSystem O) (x : O) :
    expDist S x x = 1 := by simp [expDist, S.sep_self]

/-
The exponential distance satisfies the ultrametric inequality.
-/
theorem expDist_ultrametric (S : FiniteObserverSystem O) (x y z : O) :
    expDist S x z ≤ max (expDist S x y) (expDist S y z) := by
      have h_exp : S.sep x z ≤ max (S.sep x y) (S.sep y z) := by
        exact S.sep_ultra x y z;
      unfold expDist;
      cases max_cases ( S.sep x y ) ( S.sep y z ) <;> simp_all +decide [ pow_le_pow_iff_right₀ ]

end