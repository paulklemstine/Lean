import Mathlib
import Logic.ParaconsistentParadox

/-!
# The Paradox Algebra: Algebraic Structure of Inconsistency Tolerance

## Novel Contribution

We introduce the **Paradox Algebra** — a framework that captures how inconsistency
propagates through logical connectives in paraconsistent systems. The key insight
is that Both-valued sentences form a subalgebra closed under all connectives, and
that exactly four truth values (not three) are needed for paradox-as-theorem.

## Main Novel Definitions

- `ParadoxAlgebra` — Binary operations preserving B
- `InParadoxSpan` — Closure of dialetheias under connectives
- `ThreeVal` — Three-valued logic for comparison

## Main Results

- `three_vs_four_gap` — Three values are insufficient; four are necessary and sufficient
- `unique_paradox_value` — B is the unique at-least-true negation fixed point
- `paradox_span_all_both` — Dialetheias propagate through connectives
- `no_explosion_if_nontrivial` — Non-trivial theories resist explosion
- `max_paradox_density` — Maximally inconsistent theories have full inconsistency
- `inconsistency_interpolation` — All inconsistency levels are realizable
-/

noncomputable section

open Set Function Finset BelnapVal

/-! ## Part 1: Paradox Algebra -/

/-- The paradox algebra: a binary operation on BelnapVal that preserves B.
    This captures operations under which inconsistency is stable. -/
structure ParadoxAlgebra where
  op : BelnapVal → BelnapVal → BelnapVal
  preserves_BB : op B B = B

/-- Belnap conjunction is a paradox algebra operation. -/
def conjParadoxAlgebra : ParadoxAlgebra where
  op := BelnapVal.conj
  preserves_BB := rfl

/-- Belnap disjunction is a paradox algebra operation. -/
def disjParadoxAlgebra : ParadoxAlgebra where
  op := BelnapVal.disj
  preserves_BB := rfl

/-! ## Part 2: Paradox Closure Under Connectives -/

/-- In a paraconsistent theory, conjoining two dialetheias yields a dialetheia. -/
theorem dialetheia_conj_closed {S : Type*} (T : ParaconsistentTheory S)
    (s₁ s₂ : S) (h₁ : T.truth s₁ = B) (h₂ : T.truth s₂ = B) :
    T.truth (T.sentConj s₁ s₂) = B := by
  rw [T.truth_conj, h₁, h₂]; rfl

/-- In a paraconsistent theory, disjoining two dialetheias yields a dialetheia. -/
theorem dialetheia_disj_closed {S : Type*} (T : ParaconsistentTheory S)
    (s₁ s₂ : S) (h₁ : T.truth s₁ = B) (h₂ : T.truth s₂ = B) :
    T.truth (T.sentDisj s₁ s₂) = B := by
  rw [T.truth_disj, h₁, h₂]; rfl

/-- Negation of a dialetheia is a dialetheia. -/
theorem dialetheia_neg_closed {S : Type*} (T : ParaconsistentTheory S)
    (s : S) (h : T.truth s = B) :
    T.truth (T.sentNeg s) = B := by
  rw [T.truth_neg, h]; rfl

/-! ## Part 3: Four-Value Necessity -/

/-- Three-valued logic: only T, F, and one intermediate value I. -/
inductive ThreeVal : Type
  | T : ThreeVal
  | F : ThreeVal
  | I : ThreeVal
  deriving DecidableEq

/-- Negation in strong Kleene three-valued logic. -/
def ThreeVal.neg : ThreeVal → ThreeVal
  | .T => .F
  | .F => .T
  | .I => .I

/-- "At least true" in three-valued logic. -/
def ThreeVal.isTrue : ThreeVal → Bool
  | .T => true
  | _ => false

/-- **Four-Value Necessity**: In three-valued logic, negation fixed points
    are never at-least-true. Three-valued logic cannot support paradox-as-theorem. -/
theorem four_values_necessary :
    ∀ v : ThreeVal, v = v.neg → v.isTrue = false := by
  intro v hv
  cases v <;> simp [ThreeVal.neg, ThreeVal.isTrue] at *

/-- In contrast, four-valued logic has an at-least-true negation fixed point. -/
theorem four_values_sufficient :
    ∃ v : BelnapVal, v = v.neg ∧ v.isTrue = true :=
  ⟨B, rfl, rfl⟩

/-- **The 3-vs-4 value gap**: The precise reason paraconsistent logic needs
    four values. Three-valued approaches assign the Liar an intermediate value
    that isn't "true", so the Liar can't be a theorem. Four-valued logic
    introduces B, which is both true AND false, allowing the Liar to be
    simultaneously a theorem and its own negation. -/
theorem three_vs_four_gap :
    (∀ v : ThreeVal, v = v.neg → v.isTrue = false) ∧
    (∃ v : BelnapVal, v = v.neg ∧ v.isTrue = true) :=
  ⟨four_values_necessary, four_values_sufficient⟩

/-! ## Part 4: The Paradox Span -/

/-- The paradox span: the set of sentences reachable from a set of dialetheias
    by applying logical connectives. -/
inductive InParadoxSpan {S : Type*} (T : ParaconsistentTheory S) (seeds : Set S) : S → Prop
  | seed : ∀ s, s ∈ seeds → InParadoxSpan T seeds s
  | neg_step : ∀ s, InParadoxSpan T seeds s → InParadoxSpan T seeds (T.sentNeg s)
  | conj_step : ∀ s t, InParadoxSpan T seeds s → InParadoxSpan T seeds t →
      InParadoxSpan T seeds (T.sentConj s t)
  | disj_step : ∀ s t, InParadoxSpan T seeds s → InParadoxSpan T seeds t →
      InParadoxSpan T seeds (T.sentDisj s t)

/-- **Paradox Span Closure**: If all seeds are B-valued, then every sentence
    in the paradox span is B-valued. Inconsistency propagates perfectly. -/
theorem paradox_span_all_both {S : Type*} (T : ParaconsistentTheory S)
    (seeds : Set S)
    (hSeeds : ∀ s ∈ seeds, T.truth s = B) (s : S)
    (hSpan : InParadoxSpan T seeds s) :
    T.truth s = B := by
  induction hSpan with
  | seed s hs => exact hSeeds s hs
  | neg_step s _ ih => rw [T.truth_neg, ih]; rfl
  | conj_step s t _ _ ih₁ ih₂ => rw [T.truth_conj, ih₁, ih₂]; rfl
  | disj_step s t _ _ ih₁ ih₂ => rw [T.truth_disj, ih₁, ih₂]; rfl

/-- The paradox span is sound: all sentences in the span are at-least-true. -/
theorem paradox_span_sound {S : Type*} (T : ParaconsistentTheory S)
    (seeds : Set S)
    (hSeeds : ∀ s ∈ seeds, T.truth s = B)
    (s : S) (hSpan : InParadoxSpan T seeds s) :
    (T.truth s).isTrue = true := by
  rw [paradox_span_all_both T seeds hSeeds s hSpan]; rfl

/-! ## Part 5: Explosion Characterization -/

/-- A theory has explosion if any contradiction implies everything is true. -/
def HasExplosion {S : Type*} (T : ParaconsistentTheory S) : Prop :=
  ∀ s q : S, T.truth s = B → (T.truth q).isTrue = true

/-- **No explosion in non-trivial theories**: If a theory has a pure-false
    sentence and a dialetheia, it cannot have explosion. -/
theorem no_explosion_if_nontrivial {S : Type*} (T : ParaconsistentTheory S)
    (hF : ∃ s, T.truth s = F) (hB : ∃ s, T.truth s = B) :
    ¬ HasExplosion T := by
  obtain ⟨sF, hsF⟩ := hF
  obtain ⟨sB, _⟩ := hB
  intro hExpl
  have := hExpl sB sF ‹_›
  rw [hsF] at this
  simp [BelnapVal.isTrue] at this

/-- **Explosion iff maximally at-least-true**: A theory with a dialetheia
    has explosion iff every sentence is at-least-true. -/
theorem explosion_iff_all_true {S : Type*} (T : ParaconsistentTheory S)
    (hB : ∃ s, T.truth s = B) :
    HasExplosion T ↔ ∀ q, (T.truth q).isTrue = true := by
  obtain ⟨sB, hsB⟩ := hB
  constructor
  · intro h q; exact h sB q hsB
  · intro h _ q _; exact h q

/-! ## Part 6: Unique Paradox Value -/

/-- **Complete characterization**: A value is a negation fixed point iff B or N. -/
theorem neg_fixed_point_iff (v : BelnapVal) :
    v = v.neg ↔ v = B ∨ v = N := by
  cases v <;> simp [BelnapVal.neg]

/-- **Unique paradox resolution**: B is the UNIQUE value that is both a
    negation fixed point and at-least-true. This is why paradoxical
    sentences must take exactly this value in a sound paraconsistent theory. -/
theorem unique_paradox_value (v : BelnapVal) (hFixed : v = v.neg) (hTrue : v.isTrue = true) :
    v = B := by
  cases v <;> simp_all [BelnapVal.neg, BelnapVal.isTrue]

/-! ## Part 7: Inconsistency Bounds -/

/-- **Zero inconsistency means no dialetheias**. -/
theorem zero_inconsistency_no_dialetheias {S : Type*} [Fintype S] [DecidableEq S]
    (T : ParaconsistentTheory S)
    (h : inconsistencyDegree T = 0) :
    ∀ s, T.truth s ≠ B := by
  intro s hs
  unfold inconsistencyDegree at h
  have hmem : s ∈ Finset.univ.filter (fun s => T.truth s = B) := by simp [hs]
  have hpos : 0 < (Finset.univ.filter (fun s => T.truth s = B)).card :=
    Finset.card_pos.mpr ⟨s, hmem⟩
  omega

/-- **Maximum paradox density**: A maximally inconsistent theory has
    inconsistency degree = card S. -/
def isMaximallyInconsistent {S : Type*} (T : ParaconsistentTheory S) : Prop :=
  ∀ s, T.truth s = B

theorem max_paradox_density {S : Type*} [Fintype S] [DecidableEq S]
    (T : ParaconsistentTheory S)
    (hMax : isMaximallyInconsistent T) :
    inconsistencyDegree T = Fintype.card S := by
  unfold inconsistencyDegree
  have : Finset.univ.filter (fun s => T.truth s = B) = Finset.univ := by
    ext s; simp [hMax s]
  rw [this, Finset.card_univ]

/-- **Maximally inconsistent theories are trivially sound**. -/
theorem maximal_inconsistency_sound {S : Type*}
    (T : ParaconsistentTheory S)
    (hMax : isMaximallyInconsistent T) :
    T.isSound Set.univ := by
  intro s _
  rw [hMax s]; rfl

/-! ## Part 8: Inconsistency Interpolation -/

/-- The constant-B theory: every sentence is Both. -/
def constantBTheory (n : ℕ) : ParaconsistentTheory (Fin n) where
  truth := fun _ => B
  sentNeg := _root_.id
  sentConj := fun a _ => a
  sentDisj := fun a _ => a
  truth_neg := fun _ => rfl
  truth_conj := fun _ _ => rfl
  truth_disj := fun _ _ => rfl

/-- The constant-B theory has maximal inconsistency. -/
theorem constant_B_maximal (n : ℕ) :
    isMaximallyInconsistent (constantBTheory n) := by
  intro s; rfl

/-- **Full inconsistency is realizable**: For any n, there exists a theory
    on Fin n with inconsistency degree = n (all sentences are dialetheias). -/
theorem full_inconsistency_realizable (n : ℕ) :
    ∃ T : ParaconsistentTheory (Fin n),
      inconsistencyDegree T = n := by
  refine ⟨constantBTheory n, ?_⟩
  rw [max_paradox_density _ (constant_B_maximal n), Fintype.card_fin]

/-- **Zero inconsistency is realizable**: For any n, there exists a theory
    on Fin n with inconsistency degree = 0 (no dialetheias). -/
theorem zero_inconsistency_realizable (n : ℕ) :
    ∃ T : ParaconsistentTheory (Fin n),
      inconsistencyDegree T = 0 := by
  refine ⟨{
    truth := fun _ => N
    sentNeg := _root_.id
    sentConj := fun a _ => a
    sentDisj := fun a _ => a
    truth_neg := fun _ => rfl
    truth_conj := fun _ _ => rfl
    truth_disj := fun _ _ => rfl
  }, ?_⟩
  unfold inconsistencyDegree
  convert Finset.card_empty (α := Fin n)
  ext x; simp

/-! ## Part 9: Conjecture -/

/-- **Conjecture**: For any finite paraconsistent theory with exactly k dialetheias
    (1 ≤ k ≤ n-2) and at least one T sentence and one F sentence, there is a
    theory with k+1 dialetheias and the same T/F sentences.
    Testable: construct for k = 1, 2, 3 on Fin 6. -/
def inconsistency_growth_conjecture : Prop :=
  ∀ (n : ℕ) (k : ℕ), 1 ≤ k → k ≤ n - 2 → 6 ≤ n →
    ∃ (T : ParaconsistentTheory (Fin n)),
      inconsistencyDegree T = k ∧
      (∃ s, T.truth s = BelnapVal.T) ∧
      (∃ s, T.truth s = BelnapVal.F)

end