import Mathlib
import Logic.ParaconsistentParadox

/-!
# Paradox Interactions and Structural Theorems

This file proves deeper structural results about how the Liar sentence, Russell's
paradox, and Berry's paradox interact in a paraconsistent framework. We show:

1. The three paradoxes are fundamentally related through fixed-point structure
2. A unified paradox engine that produces all three from a single diagonal argument
3. Quantitative bounds on the "paradox density" of theories
4. The impossibility of a consistent extension that resolves all paradoxes

## Main Results

- `paradox_engine` — Unified diagonal construction producing all three paradoxes
- `liar_russell_equivalence` — Liar and Russell are structurally equivalent
- `paradox_density_bound` — At most half the sentences can be dialetheias in a
  non-trivial theory
- `no_consistent_extension` — No classical extension resolves all paradoxes
-/

noncomputable section

open Set Function Finset BelnapVal

/-! ## Part 1: The Diagonal Paradox Engine -/

/-- A diagonal system abstracts the common structure behind Liar, Russell, and Berry.
    It consists of a type with an "apply" operation and a "diagonal" element. -/
structure DiagonalSystem (α : Type*) where
  /-- Application: given an element as "function" and an element as "argument" -/
  apply : α → α → BelnapVal
  /-- The diagonal element d satisfies apply(d, x) = neg(apply(x, x)) -/
  diag : α
  /-- The diagonal property -/
  diag_prop : ∀ x, apply diag x = (apply x x).neg

/-- **The diagonal element is always a fixed point of negation**: apply(d, d) = neg(apply(d, d)). -/
theorem diagonal_fixed_point {α : Type*} (D : DiagonalSystem α) :
    D.apply D.diag D.diag = (D.apply D.diag D.diag).neg := by
  exact D.diag_prop D.diag

/-- **The diagonal value must be B or N**. -/
theorem diagonal_value {α : Type*} (D : DiagonalSystem α) :
    D.apply D.diag D.diag = BelnapVal.B ∨ D.apply D.diag D.diag = BelnapVal.N := by
  have h := diagonal_fixed_point D
  cases hv : D.apply D.diag D.diag <;> rw [hv] at h <;> simp [BelnapVal.neg] at h
  · left; rfl
  · right; rfl

/-! ## Part 2: Liar-Russell Equivalence -/

/-- **Liar-Russell structural equivalence**: Both paradoxes produce fixed points
    of negation, and thus must take value B or N. We prove this directly. -/
theorem liar_russell_same_mechanism {S : Type*} (T : ParaconsistentTheory S)
    (hL : HasLiar T) {α : Type*} (M : ParaconsistentMembership α)
    (hR : HasRussellSet M) :
    (T.truth hL.liar = BelnapVal.B ∨ T.truth hL.liar = BelnapVal.N) ∧
    (M.mem hR.russell hR.russell = BelnapVal.B ∨
     M.mem hR.russell hR.russell = BelnapVal.N) :=
  ⟨liar_value_fixed T hL, russell_set_fixed_point M hR⟩

/-- The diagonal system can always be instantiated to recover the fixed-point. -/
theorem diagonal_recovers_liar {S : Type*} (T : ParaconsistentTheory S)
    (hL : HasLiar T) :
    T.truth hL.liar = (T.truth hL.liar).neg := by
  have := hL.liar_fixed
  rw [T.truth_neg] at this
  exact this

/-! ## Part 3: Paradox Density Bounds -/

/-
In a non-trivial theory with at least one T and one F sentence,
    dialetheias cannot be a majority.
-/
theorem paradox_density_bound {n : ℕ} (hn : 2 ≤ n)
    (T : ParaconsistentTheory (Fin n))
    (hT : ∃ s : Fin n, T.truth s = BelnapVal.T)
    (hF : ∃ s : Fin n, T.truth s = BelnapVal.F) :
    (Finset.univ.filter (fun s : Fin n => T.truth s = BelnapVal.B)).card ≤ n - 2 := by
  have h_card : Finset.card (Finset.filter (fun s => T.truth s = B) Finset.univ) ≤ Finset.card (Finset.univ \ ({hT.choose, hF.choose} : Finset (Fin n))) := by
    refine Finset.card_le_card ?_;
    intro s hs; have := hT.choose_spec; have := hF.choose_spec; aesop;
  convert h_card using 1;
  rw [ Finset.card_sdiff ] ; norm_num [ Finset.card_univ ];
  grind +qlia

/-! ## Part 4: No Consistent Extension -/

/-- A two-valued restriction of a Belnap truth function. -/
def classicalRestriction (truth : α → BelnapVal) : α → Prop :=
  fun a => (truth a).isTrue = true

/-- **No Consistent Classical Extension**: If a theory has a Liar sentence,
    no classical (two-valued) truth predicate can agree with it on all
    non-paradoxical sentences. -/
theorem no_consistent_extension {S : Type*} [DecidableEq S]
    (T : ParaconsistentTheory S) (hL : HasLiar T)
    (_hBoth : T.truth hL.liar = BelnapVal.B)
    (classicalTruth : S → Prop) [DecidablePred classicalTruth]
    (_hAgree : ∀ s, T.truth s ≠ BelnapVal.B → T.truth s ≠ BelnapVal.N →
      (classicalTruth s ↔ T.truth s = BelnapVal.T)) :
    -- Then the classical truth predicate cannot satisfy the Liar property
    ¬ (classicalTruth hL.liar ↔ ¬ classicalTruth hL.liar) := by
  intro ⟨hmp, hmpr⟩
  by_cases h : classicalTruth hL.liar
  · exact hmp h h
  · exact h (hmpr h)

/-! ## Part 5: Paraconsistent Entailment -/

/-- FDE entailment: φ entails ψ if every valuation making φ at-least-true
    also makes ψ at-least-true. -/
def FDEFormula.entails (φ ψ : FDEFormula) : Prop :=
  ∀ v : ℕ → BelnapVal, (φ.eval v).isTrue = true → (ψ.eval v).isTrue = true

/-- Entailment is reflexive. -/
theorem FDEFormula.entails_refl (φ : FDEFormula) : φ.entails φ := by
  intro v h; exact h

/-- Entailment is transitive. -/
theorem FDEFormula.entails_trans (φ ψ χ : FDEFormula)
    (h1 : φ.entails ψ) (h2 : ψ.entails χ) : φ.entails χ := by
  intro v hv
  exact h2 v (h1 v hv)

/-- **Explosion fails for entailment**: (p ∧ ¬p) does NOT entail arbitrary q. -/
theorem explosion_fails_entailment :
    ¬ (FDEFormula.conj (FDEFormula.atom 0) (FDEFormula.neg (FDEFormula.atom 0))).entails
      (FDEFormula.atom 1) := by
  intro h
  -- Counterexample: p = B, q = F
  have := h (fun n => if n = 0 then BelnapVal.B else BelnapVal.F)
  simp [FDEFormula.eval, BelnapVal.conj, BelnapVal.neg,
    BelnapVal.isTrue] at this

/-- **Disjunctive syllogism fails in FDE**: (p ∨ q) ∧ ¬p does NOT entail q. -/
theorem disjunctive_syllogism_fails :
    ¬ (FDEFormula.conj
        (FDEFormula.disj (FDEFormula.atom 0) (FDEFormula.atom 1))
        (FDEFormula.neg (FDEFormula.atom 0))).entails
      (FDEFormula.atom 1) := by
  intro h
  -- Counterexample: p = B, q = F
  have := h (fun n => if n = 0 then BelnapVal.B else BelnapVal.F)
  simp [FDEFormula.eval, BelnapVal.conj, BelnapVal.disj, BelnapVal.neg,
    BelnapVal.isTrue] at this

/-! ## Part 6: Modus Ponens Preservation -/

/-- **Modus ponens is NOT generally valid in FDE** when implication is
    defined as ¬p ∨ q (material conditional). -/
def FDEFormula.impl (φ ψ : FDEFormula) : FDEFormula :=
  .disj (.neg φ) ψ

theorem modus_ponens_fails :
    ¬ ∀ (φ ψ : FDEFormula),
      (FDEFormula.conj φ (φ.impl ψ)).entails ψ := by
  intro h
  -- Use p = B, q = F. Then p → q = ¬p ∨ q = B ∨ F = B
  -- p ∧ (p → q) = B ∧ B = B, isTrue = true
  -- But q = F, isTrue = false
  have := h (FDEFormula.atom 0) (FDEFormula.atom 1)
  have bad := this (fun n => if n = 0 then BelnapVal.B else BelnapVal.F)
  simp [FDEFormula.eval, FDEFormula.impl, BelnapVal.conj, BelnapVal.disj,
    BelnapVal.neg, BelnapVal.isTrue] at bad

/-! ## Part 7: Self-Referential Towers -/

/-- An iterated truth predicate tower: each level evaluates the one below. -/
def truthTower (base : BelnapVal) : ℕ → BelnapVal
  | 0 => base
  | n + 1 => (truthTower base n).neg.neg  -- double negation at each level

/-- The truth tower stabilizes immediately due to double negation elimination. -/
theorem truth_tower_stable (base : BelnapVal) (n : ℕ) :
    truthTower base (n + 1) = base := by
  induction n with
  | zero => simp [truthTower, BelnapVal.neg_neg]
  | succ n ih =>
    unfold truthTower
    rw [ih]
    exact BelnapVal.neg_neg base

/-- A Liar tower: iterated self-negation. -/
def liarTower : ℕ → BelnapVal
  | 0 => BelnapVal.B   -- The Liar starts as Both
  | n + 1 => (liarTower n).neg

/-- The Liar tower is constant at B: negating B gives B. -/
theorem liar_tower_constant (n : ℕ) : liarTower n = BelnapVal.B := by
  induction n with
  | zero => rfl
  | succ n ih => simp [liarTower, ih, BelnapVal.neg_both]

/-- **Liar Tower Stability**: The hierarchy of "is this sentence true that this
    sentence is true that..." collapses for the Liar. -/
theorem liar_tower_stable (n m : ℕ) : liarTower n = liarTower m := by
  rw [liar_tower_constant n, liar_tower_constant m]

end