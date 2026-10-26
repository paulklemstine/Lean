module

public import Catalog.Algebra.JigsawParsimony.Basic

/-!
# A mod-2 inclusion–exclusion formula for the assembly count

Over `ZMod 2` the indicator that a clause piece fits is `1 + [the piece is
falsified]`, so expanding the product over clause pieces yields an inclusion–
exclusion formula with no signs:

`count P ≡ ∑_{S ⊆ clause pieces} #{a : a falsifies every piece in S}  (mod 2)`.

Combined with `count_compPuzzle`, the falsifier sums of `P` and of its complement
agree mod 2 (`falsifierSum_compPuzzle`).
-/

@[expose] public section

namespace JigsawParsimony

open Finset

variable {n : ℕ}

/-- A choice of variable pieces *falsifies* a clause piece when none of its inputs
mates. -/
def Falsifies (a : Cube n) (c : ClausePiece n) : Prop := ∀ l ∈ c, ¬ Fits a l

instance (a : Cube n) (c : ClausePiece n) : Decidable (Falsifies a c) := by
  unfold Falsifies; infer_instance

/-- Number of choices of variable pieces falsifying every clause piece indexed by
`S`. -/
def falsifierCount (P : Puzzle n) (S : Finset (Fin P.length)) : ℕ :=
  (univ.filter fun a : Cube n => ∀ i ∈ S, Falsifies a (P.get i)).card

theorem assembles_iff_forall_get (P : Puzzle n) (a : Cube n) :
    Assembles P a ↔ ∀ i : Fin P.length, ¬ Falsifies a (P.get i) := by
  unfold Assembles Falsifies
  simp only [not_forall, not_not, exists_prop]
  constructor
  · intro h i
    exact h _ (List.get_mem P i)
  · intro h c hc
    obtain ⟨i, rfl⟩ := List.get_of_mem hc
    exact h i

theorem fits_indicator (p : Prop) [Decidable p] :
    ((if ¬ p then 1 else 0 : ZMod 2)) = 1 + (if p then 1 else 0) := by
  by_cases hp : p <;> simp [hp]
  decide

/-- **Signless inclusion–exclusion mod 2.** -/
theorem count_cast_zmod_two (P : Puzzle n) :
    (count P : ZMod 2) = ∑ S ∈ (univ : Finset (Fin P.length)).powerset,
      (falsifierCount P S : ZMod 2) := by
  have h1 : (count P : ZMod 2) =
      ∑ a : Cube n, ∏ i : Fin P.length, (if ¬ Falsifies a (P.get i) then 1 else 0 : ZMod 2) := by
    rw [count, assemblies, ← Finset.sum_boole]
    refine Finset.sum_congr rfl fun a _ => ?_
    rw [Finset.prod_boole]
    simp only [Finset.mem_univ, true_implies, assembles_iff_forall_get]
  rw [h1]
  simp_rw [fits_indicator, Finset.prod_one_add, Finset.prod_boole]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun S _ => ?_
  rw [falsifierCount, Finset.natCast_card_filter]
  refine Finset.sum_congr rfl fun a _ => ?_
  congr 1

/-- The same formula as a congruence of natural numbers. -/
theorem count_modEq_falsifierSum (P : Puzzle n) :
    count P ≡ ∑ S ∈ (univ : Finset (Fin P.length)).powerset, falsifierCount P S [MOD 2] := by
  rw [← ZMod.natCast_eq_natCast_iff, count_cast_zmod_two, Nat.cast_sum]

theorem length_compPuzzle (P : Puzzle n) : (compPuzzle P).length = P.length := by
  simp [compPuzzle]

/-- **Complementation invariance of the falsifier sum mod 2**: a nontrivial identity
between two inclusion–exclusion expansions, obtained from parsimony. -/
theorem falsifierSum_compPuzzle (P : Puzzle n) :
    ∑ S ∈ (univ : Finset (Fin (compPuzzle P).length)).powerset, falsifierCount (compPuzzle P) S
      ≡ ∑ S ∈ (univ : Finset (Fin P.length)).powerset, falsifierCount P S [MOD 2] :=
  ((count_modEq_falsifierSum (compPuzzle P)).symm.trans
    (by rw [count_compPuzzle])).trans (count_modEq_falsifierSum P)

end JigsawParsimony