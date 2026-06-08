import Mathlib

/-!
# Paraconsistent Logic: Paradoxes as Theorems

We construct a formal system based on Belnap's four-valued logic (FDE) where the
Liar sentence, Berry's paradox, and Russell's paradox are all provable theorems
rather than contradictions. The key insight is that the four-valued truth space
{True, False, Both, Neither} allows contradictions to be localized without
explosion (ex falso quodlibet fails).

## Main Definitions

- `BelnapVal` — The four truth values: True, False, Both, Neither
- `ParaconsistentTheory` — A theory with sentences, truth predicate, and connectives
- `FDEFormula` — Formulas of first-degree entailment logic
- `ParaconsistentMembership` — Four-valued set membership

## Main Results

- `liar_sentence_both` — The Liar sentence receives value Both (true AND false)
- `russell_set_both` — Russell's set has Both-valued self-membership
- `berry_paradox_noninj` — Definability functions are non-injective (pigeonhole)
- `fde_explosion_fails` — Ex falso quodlibet fails in FDE
- `classical_no_liar` — Classical logic cannot support paradox-as-theorem
- `classical_no_russell` — Classical logic cannot support Russell's paradox
- `excluded_middle_not_tautology` — Excluded middle fails in FDE
- `nontrivial_bounded_inconsistency` — Non-trivial theories have bounded inconsistency
- `liar_compatible_with_soundness` — Liar is compatible with soundness

## References

- Belnap, N. (1977). "A useful four-valued logic"
- Priest, G. (2006). "In Contradiction"
-/

noncomputable section

open Set Function Finset

/-! ## Part 1: Belnap's Four-Valued Logic -/

/-- The four truth values of Belnap's logic FDE.
- `T` : true only
- `F` : false only
- `B` : both true and false (the "dialetheia" value)
- `N` : neither true nor false (the "gap" value) -/
inductive BelnapVal : Type
  | T : BelnapVal
  | F : BelnapVal
  | B : BelnapVal
  | N : BelnapVal
  deriving DecidableEq, Repr

namespace BelnapVal

/-- A Belnap value is "at least true" if it is T or B. -/
def isTrue : BelnapVal → Bool
  | T => true
  | B => true
  | _ => false

/-- A Belnap value is "at least false" if it is F or B. -/
def isFalse : BelnapVal → Bool
  | F => true
  | B => true
  | _ => false

/-- Belnap negation: swaps T↔F, fixes B and N. -/
def neg : BelnapVal → BelnapVal
  | T => F
  | F => T
  | B => B
  | N => N

/-- Belnap conjunction (truth order meet). -/
def conj : BelnapVal → BelnapVal → BelnapVal
  | T, y => y
  | y, T => y
  | F, _ => F
  | _, F => F
  | B, B => B
  | B, N => F
  | N, B => F
  | N, N => N

/-- Belnap disjunction (truth order join). -/
def disj : BelnapVal → BelnapVal → BelnapVal
  | F, y => y
  | y, F => y
  | T, _ => T
  | _, T => T
  | B, B => B
  | B, N => T
  | N, B => T
  | N, N => N

/-- Double negation is the identity in FDE. -/
theorem neg_neg (v : BelnapVal) : neg (neg v) = v := by
  cases v <;> rfl

/-- Negation of B is B — contradictions are self-dual. -/
theorem neg_both : neg B = B := rfl

/-- Negation of N is N — gaps are self-dual. -/
theorem neg_neither : neg N = N := rfl

/-- B is both true and false simultaneously. -/
theorem both_is_true : isTrue B = true := rfl
theorem both_is_false : isFalse B = true := rfl

/-- T is true but not false. -/
theorem true_not_false : isFalse T = false := rfl
theorem false_not_true : isTrue F = false := rfl

end BelnapVal

/-! ## Part 2: The Information Lattice -/

/-- The information ordering on Belnap values: N ≤ T, F ≤ B.
N has least information, B has most. -/
def BelnapVal.infoLE : BelnapVal → BelnapVal → Bool
  | .N, _ => true
  | .T, .T => true
  | .T, .B => true
  | .F, .F => true
  | .F, .B => true
  | .B, .B => true
  | _, _ => false

theorem belnap_info_refl (v : BelnapVal) : v.infoLE v = true := by
  cases v <;> rfl

theorem belnap_info_trans (a b c : BelnapVal)
    (h1 : a.infoLE b = true) (h2 : b.infoLE c = true) :
    a.infoLE c = true := by
  cases a <;> cases b <;> cases c <;> simp_all [BelnapVal.infoLE]

/-! ## Part 3: Paraconsistent Theory with Truth Predicate -/

/-- A paraconsistent theory over a type of sentences. -/
structure ParaconsistentTheory (S : Type*) where
  /-- The four-valued truth predicate -/
  truth : S → BelnapVal
  /-- Negation of sentences -/
  sentNeg : S → S
  /-- Conjunction of sentences -/
  sentConj : S → S → S
  /-- Disjunction of sentences -/
  sentDisj : S → S → S
  /-- Truth predicate respects negation -/
  truth_neg : ∀ s, truth (sentNeg s) = (truth s).neg
  /-- Truth predicate respects conjunction -/
  truth_conj : ∀ s t, truth (sentConj s t) = (truth s).conj (truth t)
  /-- Truth predicate respects disjunction -/
  truth_disj : ∀ s t, truth (sentDisj s t) = (truth s).disj (truth t)

/-- A sentence is a dialetheia if it has value Both. -/
def isDilatheia {S : Type*} (T : ParaconsistentTheory S) (s : S) : Prop :=
  T.truth s = BelnapVal.B

/-- A theory is non-trivial if it has both pure-true and pure-false sentences. -/
def isNontrivial {S : Type*} (T : ParaconsistentTheory S) : Prop :=
  ∃ s₁ s₂, T.truth s₁ = BelnapVal.T ∧ T.truth s₂ = BelnapVal.F

/-! ## Part 4: The Liar Sentence -/

/-- A theory has a Liar sentence: truth(L) = truth(¬L). -/
structure HasLiar {S : Type*} (T : ParaconsistentTheory S) where
  liar : S
  liar_fixed : T.truth liar = T.truth (T.sentNeg liar)

/-- **Liar Sentence Theorem**: The Liar must have value B or N. -/
theorem liar_value_fixed {S : Type*} (T : ParaconsistentTheory S)
    (hL : HasLiar T) :
    T.truth hL.liar = BelnapVal.B ∨ T.truth hL.liar = BelnapVal.N := by
  have h := hL.liar_fixed
  rw [T.truth_neg] at h
  cases hv : T.truth hL.liar <;> rw [hv] at h <;> simp [BelnapVal.neg] at h
  · left; rfl
  · right; rfl

/-- **Strong Liar Theorem**: If the Liar has positive truth info, it is a dialetheia. -/
theorem liar_sentence_both {S : Type*} (T : ParaconsistentTheory S)
    (hL : HasLiar T)
    (hTrue : (T.truth hL.liar).isTrue = true) :
    T.truth hL.liar = BelnapVal.B := by
  rcases liar_value_fixed T hL with h | h
  · exact h
  · rw [h] at hTrue; simp [BelnapVal.isTrue] at hTrue

/-! ## Part 5: Russell's Paradox in Paraconsistent Set Theory -/

/-- Four-valued membership relation. -/
structure ParaconsistentMembership (α : Type*) where
  mem : α → α → BelnapVal

/-- Russell's set has a fixed-point property. -/
structure HasRussellSet {α : Type*} (M : ParaconsistentMembership α) where
  russell : α
  russell_fixed : M.mem russell russell = (M.mem russell russell).neg

/-- **Russell's Paradox as Theorem**: Self-membership must be B or N. -/
theorem russell_set_fixed_point {α : Type*} (M : ParaconsistentMembership α)
    (hR : HasRussellSet M) :
    M.mem hR.russell hR.russell = BelnapVal.B ∨
    M.mem hR.russell hR.russell = BelnapVal.N := by
  have h := hR.russell_fixed
  cases hv : M.mem hR.russell hR.russell <;> rw [hv] at h <;>
    simp [BelnapVal.neg] at h
  · left; rfl
  · right; rfl

/-- **Russell's set is a dialetheia**: If positive info, must be Both. -/
theorem russell_set_both {α : Type*} (M : ParaconsistentMembership α)
    (hR : HasRussellSet M)
    (hPos : (M.mem hR.russell hR.russell).isTrue = true) :
    M.mem hR.russell hR.russell = BelnapVal.B := by
  rcases russell_set_fixed_point M hR with h | h
  · exact h
  · rw [h] at hPos; simp [BelnapVal.isTrue] at hPos

/-! ## Part 6: Berry's Paradox via Pigeonhole -/

/-- **Berry's Paradox**: More objects than descriptions ⟹ non-injectivity. -/
theorem berry_paradox_noninj (n : ℕ) (f : Fin (n + 1) → Fin n) :
    ∃ i j, i ≠ j ∧ f i = f j :=
  Fintype.exists_ne_map_eq_of_card_lt f (by simp)

/-- Berry's paradox for definability on finite sets. -/
theorem berry_definability_bound {α : Type*} [DecidableEq α] (descs : Finset α)
    (objects : Finset α) (f : α → α)
    (hf_range : ∀ o ∈ objects, f o ∈ descs)
    (hsize : descs.card < objects.card) :
    ∃ o₁ ∈ objects, ∃ o₂ ∈ objects, o₁ ≠ o₂ ∧ f o₁ = f o₂ := by
  by_contra h
  push_neg at h
  have hinj : Set.InjOn f ↑objects := by
    intro a ha b hb hab
    by_contra hne
    exact absurd hab (h a ha b hb hne)
  have := Finset.card_le_card_of_injOn f (fun x hx => hf_range x hx) hinj
  omega

/-! ## Part 7: Explosion Fails in FDE -/

/-- **Explosion Failure**: conj(B, neg B) = B, not T. -/
theorem fde_explosion_fails :
    BelnapVal.conj BelnapVal.B (BelnapVal.neg BelnapVal.B) = BelnapVal.B := rfl

/-- There exist values where contradiction doesn't yield T. -/
theorem fde_no_explosion :
    ∃ v : BelnapVal, BelnapVal.conj v (BelnapVal.neg v) ≠ BelnapVal.T :=
  ⟨BelnapVal.B, by decide⟩

/-! ## Part 8: Classical Logic Incompatibility -/

/-- A classical theory: every sentence is T or F. -/
def IsClassical {S : Type*} (T : ParaconsistentTheory S) : Prop :=
  ∀ s, T.truth s = BelnapVal.T ∨ T.truth s = BelnapVal.F

/-- **Classical logic cannot support a Liar sentence.** -/
theorem classical_no_liar {S : Type*} (T : ParaconsistentTheory S)
    (hClass : IsClassical T) (hL : HasLiar T) : False := by
  have hval := liar_value_fixed T hL
  rcases hClass hL.liar with h | h <;> rw [h] at hval <;> simp at hval

/-- **Classical logic cannot support Russell's set.** -/
theorem classical_no_russell {α : Type*} (M : ParaconsistentMembership α)
    (hClass : ∀ a b, M.mem a b = BelnapVal.T ∨ M.mem a b = BelnapVal.F)
    (hR : HasRussellSet M) : False := by
  have hval := russell_set_fixed_point M hR
  rcases hClass hR.russell hR.russell with h | h <;> rw [h] at hval <;> simp at hval

/-! ## Part 9: FDE Formulas and Tautologies -/

/-- FDE formula type. -/
inductive FDEFormula : Type
  | atom : ℕ → FDEFormula
  | neg : FDEFormula → FDEFormula
  | conj : FDEFormula → FDEFormula → FDEFormula
  | disj : FDEFormula → FDEFormula → FDEFormula
  deriving DecidableEq, Repr

namespace FDEFormula

/-- Evaluate an FDE formula under a valuation. -/
def eval (v : ℕ → BelnapVal) : FDEFormula → BelnapVal
  | atom n => v n
  | neg φ => (eval v φ).neg
  | conj φ ψ => (eval v φ).conj (eval v ψ)
  | disj φ ψ => (eval v φ).disj (eval v ψ)

/-- An FDE tautology is at-least-true under every valuation. -/
def isTautology (φ : FDEFormula) : Prop :=
  ∀ v : ℕ → BelnapVal, (eval v φ).isTrue = true

/-- Double negation preserves truth value. -/
theorem eval_neg_neg (v : ℕ → BelnapVal) (φ : FDEFormula) :
    eval v (neg (neg φ)) = eval v φ := by
  simp [eval, BelnapVal.neg_neg]

/-- **Excluded middle fails in FDE**: p ∨ ¬p is not an FDE tautology. -/
theorem excluded_middle_not_tautology :
    ¬ isTautology (disj (atom 0) (neg (atom 0))) := by
  intro h
  have := h (fun _ => BelnapVal.N)
  simp [eval, BelnapVal.disj, BelnapVal.neg, BelnapVal.isTrue] at this

/-- **Non-contradiction fails in FDE**: ¬(p ∧ ¬p) is not an FDE tautology. -/
theorem non_contradiction_not_tautology :
    ¬ isTautology (neg (conj (atom 0) (neg (atom 0)))) := by
  intro h
  have := h (fun _ => BelnapVal.N)
  simp [eval, BelnapVal.conj, BelnapVal.neg, BelnapVal.isTrue] at this

end FDEFormula

/-! ## Part 10: Paraconsistent Soundness -/

/-- A paraconsistent theory is sound if provable sentences are at-least-true. -/
def ParaconsistentTheory.isSound {S : Type*} (T : ParaconsistentTheory S)
    (provable : Set S) : Prop :=
  ∀ s ∈ provable, (T.truth s).isTrue = true

/-- **Self-Soundness**: The Liar (value B) is compatible with soundness. -/
theorem liar_compatible_with_soundness {S : Type*} (T : ParaconsistentTheory S)
    (hL : HasLiar T) (hBoth : T.truth hL.liar = BelnapVal.B)
    (provable : Set S) (_hLprov : hL.liar ∈ provable)
    (hOther : ∀ s ∈ provable, s ≠ hL.liar → (T.truth s).isTrue = true) :
    T.isSound provable := by
  intro s hs
  by_cases heq : s = hL.liar
  · rw [heq, hBoth]; rfl
  · exact hOther s hs heq

/-! ## Part 11: The Inconsistency Strength Hierarchy -/

/-- The inconsistency degree of a theory. -/
def inconsistencyDegree {S : Type*} [Fintype S] [DecidableEq S]
    (T : ParaconsistentTheory S) : ℕ :=
  (Finset.univ.filter (fun s => T.truth s = BelnapVal.B)).card

/-- Inconsistency degree is bounded by the number of sentences. -/
theorem inconsistency_degree_le_card {S : Type*} [Fintype S] [DecidableEq S]
    (T : ParaconsistentTheory S) :
    inconsistencyDegree T ≤ Fintype.card S := by
  unfold inconsistencyDegree
  exact Finset.card_filter_le _ _

/-- **Non-trivial theories have bounded inconsistency**: If a theory has a
    pure-true sentence, inconsistency degree < total sentences. -/
theorem nontrivial_bounded_inconsistency {S : Type*} [Fintype S] [DecidableEq S]
    (T : ParaconsistentTheory S)
    (hT : ∃ s : S, T.truth s = BelnapVal.T) :
    inconsistencyDegree T < Fintype.card S := by
  obtain ⟨s, hs⟩ := hT
  unfold inconsistencyDegree
  apply Finset.card_lt_card
  constructor
  · exact Finset.filter_subset _ _
  · intro h
    have : s ∈ Finset.univ.filter (fun s => T.truth s = BelnapVal.B) :=
      h (Finset.mem_univ s)
    simp at this
    rw [hs] at this
    exact absurd this (by decide)

/-! ## Part 12: Conjecture — Minimal Paraconsistent Theories -/

/-- **Conjecture**: For any n ≥ 4, there exists a paraconsistent theory on Fin n
    with exactly one dialetheia that has both true and false sentences.
    Testable: construct such theories for small n and verify. -/
def paraconsistent_minimal_conjecture : Prop :=
  ∀ n : ℕ, 4 ≤ n →
    ∃ (T : ParaconsistentTheory (Fin n)),
      (∃ s, T.truth s = BelnapVal.B) ∧
      (∃ s, T.truth s = BelnapVal.T) ∧
      (∃ s, T.truth s = BelnapVal.F) ∧
      (Finset.univ.filter (fun s => T.truth s = BelnapVal.B)).card = 1

end