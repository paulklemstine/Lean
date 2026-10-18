import Mathlib

/-!
# Local obstructions for the UMW rank-2 door

Open door 1 of the campaign asks for two sets `A, B` of size about `n^{1/3}`
whose difference set `A - B` realises `n^{2/3}` of prime mass.  This file proves
the two unconditional constraints any such construction must satisfy.

1. **Capacity (no slack).**  `prime_cover_capacity`: if every element of a
   target set `T` is of the form `|a - b|`, then `|T| ≤ |A|·|B|`.  At
   `|A| = |B| = n^{1/3}` and `|T| = n^{2/3}` the inequality is tight, so the
   construction must be *injective*: every pair contributes a distinct prime.
2. **Local residue budget.**  `residue_classes_disjoint` and `residue_budget`:
   if every difference `a - b` (`a ∈ A`, `b ∈ B`) is a prime exceeding `m`, then
   for every prime `ℓ ≤ m` the residue classes of `A` and of `B` modulo `ℓ` are
   *disjoint*, hence `#(A mod ℓ) + #(B mod ℓ) ≤ ℓ`.
   `parity_rigidity` is the case `ℓ = 2`: all of `A` has one parity, all of `B`
   the other.

These are the admissibility (sieve-dimension) constraints of the rank-2 problem:
a construction must live in a product of residue-class boxes avoiding the
diagonal at every small prime, *and* be injective.
-/

namespace FactoringFrontier.RankTwo

open Finset

/-- `(A, B)` is a prime-difference pair above `m`: every difference `a - b` is,
in absolute value, a prime exceeding `m`. -/
def PrimeDiffPair (A B : Finset ℤ) (m : ℕ) : Prop :=
  ∀ a ∈ A, ∀ b ∈ B, (a - b).natAbs.Prime ∧ m < (a - b).natAbs

/-- A prime difference exceeding `m ≥ ℓ` cannot be divisible by the prime `ℓ`. -/
theorem residues_ne_of_primeDiff {ℓ m : ℕ} (hℓ : ℓ.Prime) (hm : ℓ ≤ m) {a b : ℤ}
    (h : (a - b).natAbs.Prime ∧ m < (a - b).natAbs) : (a : ZMod ℓ) ≠ (b : ZMod ℓ) := by
  intro hab
  have hdvd : (ℓ : ℤ) ∣ a - b := by
    rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
    push_cast
    rw [hab, sub_self]
  have h2 : ℓ ∣ (a - b).natAbs := Int.ofNat_dvd_left.1 hdvd
  have := (Nat.prime_dvd_prime_iff_eq hℓ h.1).1 h2
  omega

/-- **Residue classes are disjoint.**  For a prime-difference pair above `m`
and any prime `ℓ ≤ m`, `A` and `B` occupy disjoint residue classes mod `ℓ`. -/
theorem residue_classes_disjoint {A B : Finset ℤ} {m ℓ : ℕ} (hAB : PrimeDiffPair A B m)
    (hℓ : ℓ.Prime) (hm : ℓ ≤ m) :
    Disjoint (A.image (fun a : ℤ => (a : ZMod ℓ))) (B.image (fun b : ℤ => (b : ZMod ℓ))) := by
  rw [disjoint_left]
  intro r hrA hrB
  obtain ⟨a, ha, rfl⟩ := mem_image.1 hrA
  obtain ⟨b, hb, hba⟩ := mem_image.1 hrB
  exact residues_ne_of_primeDiff hℓ hm (hAB a ha b hb) hba.symm

/-- **Local residue budget.**  `#(A mod ℓ) + #(B mod ℓ) ≤ ℓ` for every prime
`ℓ ≤ m`. -/
theorem residue_budget {A B : Finset ℤ} {m ℓ : ℕ} (hAB : PrimeDiffPair A B m)
    (hℓ : ℓ.Prime) (hm : ℓ ≤ m) :
    (A.image (fun a : ℤ => (a : ZMod ℓ))).card + (B.image (fun b : ℤ => (b : ZMod ℓ))).card
      ≤ ℓ := by
  haveI : NeZero ℓ := ⟨hℓ.ne_zero⟩
  rw [← card_union_of_disjoint (residue_classes_disjoint hAB hℓ hm)]
  calc _ ≤ (univ : Finset (ZMod ℓ)).card := card_le_univ _
    _ = ℓ := by rw [card_univ, ZMod.card]

/-- **Parity rigidity (`ℓ = 2`).**  If `B` is nonempty and `(A, B)` is a
prime-difference pair above `m ≥ 2`, then any two elements of `A` have the same
parity. -/
theorem parity_rigidity {A B : Finset ℤ} {m : ℕ} (hAB : PrimeDiffPair A B m) (hm : 2 ≤ m)
    (hB : B.Nonempty) {a a' : ℤ} (ha : a ∈ A) (ha' : a' ∈ A) : Even (a - a') := by
  obtain ⟨b, hb⟩ := hB
  have h1 := residues_ne_of_primeDiff Nat.prime_two hm (hAB a ha b hb)
  have h2 := residues_ne_of_primeDiff Nat.prime_two hm (hAB a' ha' b hb)
  -- in `ZMod 2`, two elements different from the same `b` are equal
  have key : (a : ZMod 2) = (a' : ZMod 2) := by
    revert h1 h2
    generalize (a : ZMod 2) = x
    generalize (a' : ZMod 2) = y
    generalize (b : ZMod 2) = z
    revert x y z
    decide
  have : ((a - a' : ℤ) : ZMod 2) = 0 := by push_cast; rw [key, sub_self]
  rw [ZMod.intCast_zmod_eq_zero_iff_dvd] at this
  exact even_iff_two_dvd.2 (by exact_mod_cast this)

/-- **Capacity: no slack.**  If every element of `T` is an absolute difference
`|a - b|` with `a ∈ A`, `b ∈ B`, then `|T| ≤ |A|·|B|`. -/
theorem prime_cover_capacity (A B : Finset ℤ) (T : Finset ℕ)
    (hT : ∀ t ∈ T, ∃ a ∈ A, ∃ b ∈ B, (a - b).natAbs = t) :
    T.card ≤ A.card * B.card := by
  classical
  have hsub : T ⊆ (A ×ˢ B).image (fun x : ℤ × ℤ => (x.1 - x.2).natAbs) := by
    intro t ht
    obtain ⟨a, ha, b, hb, rfl⟩ := hT t ht
    exact mem_image.2 ⟨(a, b), mem_product.2 ⟨ha, hb⟩, rfl⟩
  calc T.card ≤ _ := card_le_card hsub
    _ ≤ (A ×ˢ B).card := card_image_le
    _ = A.card * B.card := card_product A B

/-- **Tight capacity forces injectivity.**  If `|T| = |A|·|B|` in the setting
of `prime_cover_capacity`, then distinct pairs give distinct differences. -/
theorem tight_capacity_injective (A B : Finset ℤ) (T : Finset ℕ)
    (hT : ∀ t ∈ T, ∃ a ∈ A, ∃ b ∈ B, (a - b).natAbs = t)
    (htight : T.card = A.card * B.card) :
    Set.InjOn (fun x : ℤ × ℤ => (x.1 - x.2).natAbs) (A ×ˢ B : Finset (ℤ × ℤ)) := by
  classical
  have hsub : T ⊆ (A ×ˢ B).image (fun x : ℤ × ℤ => (x.1 - x.2).natAbs) := by
    intro t ht
    obtain ⟨a, ha, b, hb, rfl⟩ := hT t ht
    exact mem_image.2 ⟨(a, b), mem_product.2 ⟨ha, hb⟩, rfl⟩
  have h1 := card_le_card hsub
  have h2 : ((A ×ˢ B).image (fun x : ℤ × ℤ => (x.1 - x.2).natAbs)).card
      = (A ×ˢ B).card := by
    apply le_antisymm card_image_le
    rw [card_product, ← htight]; exact h1
  exact card_image_iff.1 h2

/-! ## Lab notes (kernel-checked)

`A = {0, 6}`, `B = {-5, -11}`: the four differences `5, 11, 11, 17` are prime
(above `m = 3`); the cover is *not* injective (`11` twice).  Residues: mod `2`,
`A ↦ {0}`, `B ↦ {1}`; mod `3`, `A ↦ {0}`, `B ↦ {1}` — disjoint as predicted. -/

example : ((({0, 6} : Finset ℤ) ×ˢ ({-5, -11} : Finset ℤ)).image
    (fun x : ℤ × ℤ => (x.1 - x.2).natAbs)) = {5, 11, 17} := by decide

end FactoringFrontier.RankTwo