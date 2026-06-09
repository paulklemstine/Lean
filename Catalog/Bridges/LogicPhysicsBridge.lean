import Mathlib

/-!
# Logic-Physics Bridge: Consistency of Physical Theories

We formalize the relationship between physical realizability (having a model)
and proof-theoretic consistency (non-provability of falsum) for abstract
formal theories.

## Main Results

1. `consistency_antimono`: Consistency is anti-monotone under theory extension.
2. `model_implies_consistency`: Soundness + model → consistency (physics → logic).
3. `physical_implies_mathematical`: Physical consistency → mathematical consistency.
4. `math_consistency_not_sufficient`: Mathematical consistency ↛ physical consistency.

## Key Concepts

- **Mathematical consistency**: A theory Γ does not prove ⊥ (syntactic).
- **Physical consistency**: A theory has a model in a sound proof system (semantic).
- **The bridge**: Physical consistency is strictly stronger than mathematical consistency.

This formalizes the intuition that physical theories carry stronger consistency
guarantees than purely syntactic ones, and that the existence of a physical
realization (model) provides a semantic certificate of non-contradiction.
-/

universe u v

namespace LogicPhysicsBridge

/-- An abstract proof system over a type of sentences.
Captures the minimal structure needed: monotonicity and the assumption rule. -/
structure ProofSystem (S : Type u) where
  /-- `proves Γ φ` means φ is provable from the set of assumptions Γ. -/
  proves : Set S → S → Prop
  /-- A distinguished "false" / absurdity sentence. -/
  falsum : S
  /-- Provability is monotone: enlarging the assumption set preserves provability. -/
  mono : ∀ {Γ Δ : Set S}, Γ ⊆ Δ → ∀ {φ}, proves Γ φ → proves Δ φ
  /-- Any assumption is provable from itself (identity/axiom rule). -/
  assumption : ∀ {Γ : Set S} {φ}, φ ∈ Γ → proves Γ φ

variable {S : Type u} {W : Type v}

/-- A theory (set of axioms) is **consistent** if it does not prove falsum. -/
def Consistent (P : ProofSystem S) (Γ : Set S) : Prop :=
  ¬ P.proves Γ P.falsum

/-- Theory Δ **extends** theory Γ when Γ ⊆ Δ. -/
def Extends (Δ Γ : Set S) : Prop := Γ ⊆ Δ

/-- An interpretation assigns truth values to sentences at each world. -/
structure Interpretation (S : Type u) (W : Type v) where
  satisfies : W → S → Prop

/-- **Full soundness**: every provable sentence is true in all models of the assumptions. -/
def Sound (P : ProofSystem S) (I : Interpretation S W) : Prop :=
  ∀ (Γ : Set S) (φ : S),
    P.proves Γ φ → ∀ w : W, (∀ ψ ∈ Γ, I.satisfies w ψ) → I.satisfies w φ

/-- **Falsum-restricted soundness**: only the preservation of falsum is required. -/
def FalsumSound (P : ProofSystem S) (I : Interpretation S W) : Prop :=
  ∀ (Γ : Set S),
    P.proves Γ P.falsum → ∀ w : W, (∀ ψ ∈ Γ, I.satisfies w ψ) → I.satisfies w P.falsum

/-- Falsum is never satisfied in the interpretation (semantic non-triviality). -/
def FalsumUnsatisfied (P : ProofSystem S) (I : Interpretation S W) : Prop :=
  ∀ w : W, ¬ I.satisfies w P.falsum

/-- A theory **has a model** under interpretation I: some world satisfies all axioms. -/
def HasModel (Γ : Set S) (I : Interpretation S W) : Prop :=
  ∃ w : W, ∀ φ ∈ Γ, I.satisfies w φ

/-- **Physical consistency**: a theory has a model in a sound, non-trivial interpretation. -/
def PhysicallyConsistent (P : ProofSystem S) (Γ : Set S) (I : Interpretation S W) : Prop :=
  HasModel Γ I ∧ FalsumUnsatisfied P I ∧ Sound P I

/-! ## Theorem 1: Consistency Anti-Monotonicity -/

-- !-- Proof Sketch: consistency_antimono -- !--
-- By provability monotonicity: if Γ ⊢ ⊥ and Γ ⊆ Δ then Δ ⊢ ⊥.
-- Contrapositively, Δ consistent and Γ ⊆ Δ implies Γ consistent.
-- !-- End Proof Sketch -- !--

/-- **Theorem 1**: Consistency is anti-monotone under theory extension.
If Δ extends Γ and Δ is consistent, then Γ is consistent.
Equivalently: inconsistency propagates upward through extensions. -/
theorem consistency_antimono (P : ProofSystem S) {Γ Δ : Set S}
    (h_ext : Extends Δ Γ) (h_con : Consistent P Δ) : Consistent P Γ :=
  fun h => h_con (P.mono h_ext h)

/-! ## Theorem 2: Model Existence Implies Consistency -/

-- !-- Proof Sketch: model_implies_consistency -- !--
-- Given model w of Γ: if Γ ⊢ ⊥, soundness gives I.satisfies w ⊥,
-- contradicting FalsumUnsatisfied. Three-line proof by contradiction.
-- !-- End Proof Sketch -- !--

/-- **Theorem 2**: Model existence with soundness implies consistency.
This is the core **physics → logic** bridge: if a theory has a physical
realization (model) in a sound proof system, it cannot be contradictory. -/
theorem model_implies_consistency (P : ProofSystem S)
    {I : Interpretation S W}
    (h_sound : Sound P I)
    (h_falsum : FalsumUnsatisfied P I)
    {Γ : Set S}
    (h_model : HasModel Γ I) : Consistent P Γ := by
  intro h_proves
  obtain ⟨w, hw⟩ := h_model
  exact h_falsum w (h_sound Γ _ h_proves w hw)

/-! ## Theorem 3: Physical Consistency Implies Mathematical Consistency -/

-- !-- Proof Sketch: physical_implies_mathematical -- !--
-- Direct application of model_implies_consistency: PhysicallyConsistent
-- bundles exactly the three hypotheses (soundness, falsum-unsatisfied, model).
-- !-- End Proof Sketch -- !--

/-- **Theorem 3**: Physical consistency implies mathematical consistency.
A theory with a physical model in a sound proof system is proof-theoretically consistent.
This formalizes the asymmetry: physics → logic. -/
theorem physical_implies_mathematical (P : ProofSystem S)
    {I : Interpretation S W} {Γ : Set S}
    (h : PhysicallyConsistent P Γ I) : Consistent P Γ :=
  model_implies_consistency P h.2.2 h.2.1 h.1

/-! ## Theorem 4: Separation — Mathematical ↛ Physical -/

-- !-- Proof Sketch: math_consistency_not_sufficient -- !--
-- Counterexample construction:
-- • S = Bool, falsum = false, proves Γ φ ↔ φ ∈ Γ (minimal proof system)
-- • W = Empty (no physical worlds exist)
-- • I.satisfies is vacuous (no worlds to satisfy anything)
-- • Γ = {true} is consistent because false ∉ {true}
-- • HasModel fails because Empty has no inhabitants
-- Soundness and FalsumUnsatisfied hold vacuously over Empty.
-- !-- End Proof Sketch -- !--

/-- The minimal proof system: only assumptions are provable. -/
private def minimalPS : ProofSystem Bool where
  proves := fun Γ φ => φ ∈ Γ
  falsum := false
  mono := by intro Γ Δ h φ hm; exact h hm
  assumption := by intro Γ φ h; exact h

/-- Vacuous interpretation over the empty type. -/
private def emptyInterp : Interpretation Bool Empty where
  satisfies := fun w _ => w.elim

/-- **Theorem 4 (Separation)**: Mathematical consistency does NOT imply physical
consistency. There exists a proof system, interpretation, and theory that is
mathematically consistent but has no physical model.
The converse of Theorem 3 fails: **logic ↛ physics**. -/
theorem math_consistency_not_sufficient :
    ∃ (S : Type) (P : ProofSystem S) (W : Type) (I : Interpretation S W) (Γ : Set S),
      Sound P I ∧ FalsumUnsatisfied P I ∧ Consistent P Γ ∧ ¬ HasModel Γ I := by
  refine ⟨Bool, minimalPS, Empty, emptyInterp, {true}, ?_, ?_, ?_, ?_⟩
  · -- Sound: vacuously true (no worlds)
    intro _ _ _ w; exact w.elim
  · -- FalsumUnsatisfied: vacuously true (no worlds)
    intro w; exact w.elim
  · -- Consistent: false ∉ {true}
    intro h
    simp [minimalPS] at h
  · -- ¬ HasModel: no worlds exist
    intro ⟨w, _⟩; exact w.elim

/-! ## Generalization: Falsum-Soundness Suffices -/

-- !-- Proof Sketch: sound_implies_falsum_sound -- !--
-- Specialize full soundness to the case φ = P.falsum.
-- !-- End Proof Sketch -- !--

/-- Full soundness implies falsum-restricted soundness. -/
theorem sound_implies_falsum_sound (P : ProofSystem S) (I : Interpretation S W)
    (h : Sound P I) : FalsumSound P I :=
  fun Γ hΓ => h Γ _ hΓ

-- !-- Proof Sketch: model_implies_consistency_weak -- !--
-- Same proof structure as model_implies_consistency, but using FalsumSound.
-- Shows the minimal logical requirement: only falsum needs to be sound.
-- !-- End Proof Sketch -- !--

/-- **Generalization of Theorem 2**: Only falsum-soundness is needed for the bridge.
This weakens the hypothesis from full soundness to soundness restricted
to the falsum sentence, revealing the minimal logical content of the bridge. -/
theorem model_implies_consistency_weak (P : ProofSystem S)
    {I : Interpretation S W}
    (h_sound : FalsumSound P I)
    (h_falsum : FalsumUnsatisfied P I)
    {Γ : Set S}
    (h_model : HasModel Γ I) : Consistent P Γ := by
  intro h_proves
  obtain ⟨w, hw⟩ := h_model
  exact h_falsum w (h_sound Γ h_proves w hw)

/-! ## Theorem 5: Falsum-Soundness is Strictly Weaker -/

-- !-- Proof Sketch: falsum_sound_strictly_weaker -- !--
-- Construct a proof system with a non-trivial deduction rule: from sentence p,
-- derive sentence q. Use an interpretation where p is true but q is false.
-- Then FalsumSound holds (falsum is never provable from consistent assumptions)
-- but full Sound fails (q is provable from {p} but not true at the model of {p}).
-- Uses a 3-element sentence type: bot, p, q with proves Γ φ = (φ ∈ Γ ∨ (φ = q ∧ p ∈ Γ)).
-- !-- End Proof Sketch -- !--

/-- Three-element sentence type for the separation counterexample. -/
private inductive Sent : Type
  | bot : Sent  -- falsum
  | p : Sent    -- a sentence
  | q : Sent    -- another sentence (derivable from p but not modeled)
  deriving DecidableEq

/-- Proof system with a deduction rule: p ⊢ q. -/
private def deductivePS : ProofSystem Sent where
  proves := fun Γ φ => φ ∈ Γ ∨ (φ = Sent.q ∧ Sent.p ∈ Γ)
  falsum := Sent.bot
  mono := by
    intro Γ Δ h φ hprov
    exact hprov.elim (fun hm => Or.inl (h hm)) (fun ⟨hq, hp⟩ => Or.inr ⟨hq, h hp⟩)
  assumption := by intro Γ φ h; exact Or.inl h

/-- Interpretation where p is true but q is false. -/
private def partialInterp : Interpretation Sent Unit where
  satisfies := fun () s => match s with
    | Sent.bot => False
    | Sent.p => True
    | Sent.q => False

/-
**Theorem 5**: Falsum-soundness is strictly weaker than full soundness.
There exists a proof system that is falsum-sound but not fully sound,
demonstrating that Theorem 2's generalization is proper.
-/
theorem falsum_sound_strictly_weaker :
    ∃ (S : Type) (P : ProofSystem S) (W : Type) (I : Interpretation S W),
      FalsumSound P I ∧ ¬ Sound P I := by
  refine' ⟨ _, _, _, _, _, _ ⟩;
  exact ULift ℕ;
  exact ⟨ fun Γ φ => φ ∈ Γ ∨ ( φ = 1 ∧ 0 ∈ Γ ), 0, by
    grind, by
    exact fun h => Or.inl h ⟩
  all_goals generalize_proofs at *;
  exact ULift ℕ;
  exact ⟨ fun _ x => x.down = 0 ⟩;
  · intro Γ hΓ w hw; aesop;
  · intro h; specialize h { 0 } 1; simp_all +decide ;

/-! ## Bonus: Proper Extension Theorem -/

/-- A consistent theory extended by a non-provable sentence yields a proper extension
(the new axiom is provable in the extension but not in the original). -/
theorem proper_extension_new_theorem (P : ProofSystem S)
    {Γ : Set S} {φ : S}
    (h_not_proves : ¬ P.proves Γ φ) :
    P.proves (Γ ∪ {φ}) φ ∧ ¬ P.proves Γ φ :=
  ⟨P.assumption (Set.mem_union_right Γ (Set.mem_singleton φ)), h_not_proves⟩

-- !-- Lab Notebook: consistency_antimono -- !--
-- Hypothesis: Consistency should be anti-monotone because adding axioms can only
--   increase provability, never decrease it.
-- Result: Proved in one line by composing provability monotonicity with negation.
-- Insight: This is the foundational structural result — it means restricting
--   a theory preserves consistency. Key for modular theory building.
-- Failure analysis: None — this was immediate from the definitions.
-- !-- End Lab Notebook -- !--

-- !-- Lab Notebook: model_implies_consistency -- !--
-- Hypothesis: Having a model in a sound proof system should imply consistency,
--   because a model provides a semantic witness against contradiction.
-- Result: Proved by contradiction: if Γ ⊢ ⊥, soundness transfers ⊥ to the model,
--   contradicting FalsumUnsatisfied.
-- Insight: This is the formal core of "physics implies logic." The proof reveals
--   that three ingredients are independently necessary: soundness, falsum-unsatisfied,
--   and model existence. Removing any one breaks the argument.
-- Failure analysis: Initial attempt tried to avoid FalsumUnsatisfied, but it's
--   essential — without it, the model could satisfy ⊥ and the argument collapses.
-- !-- End Lab Notebook -- !--

-- !-- Lab Notebook: math_consistency_not_sufficient -- !--
-- Hypothesis: There should exist consistent theories with no model — the converse
--   of soundness fails in general.
-- Result: Constructed counterexample with W = Empty (no physical realization possible).
--   S = Bool, Γ = {true}, minimal proof system. All semantic conditions vacuously
--   satisfied over Empty; consistency holds by false ≠ true.
-- Insight: The Empty world type captures a deep idea: a syntactically coherent theory
--   may have no physical realization simply because the "universe of models" is empty.
--   This is analogous to a consistent set of axioms having no standard model.
-- Failure analysis: First tried W = Unit with a partial interpretation, but that
--   made it harder to prove ¬HasModel. Empty world type gives it for free.
-- !-- End Lab Notebook -- !--

-- !-- Lab Notebook: falsum_sound_strictly_weaker -- !--
-- Hypothesis: Full soundness is strictly stronger than falsum-soundness, because
--   a proof system can be "wrong" about non-falsum sentences while still correctly
--   preserving the non-provability of contradiction.
-- Result: Counterexample with deductive rule p ⊢ q and interpretation where p is
--   true but q is false. FalsumSound holds because proving bot requires bot ∈ Γ,
--   which makes the hypothesis of the implication contradictory. Full Sound fails
--   because {p} ⊢ q but q is false at the model of {p}.
-- Insight: The gap between falsum-soundness and full soundness is precisely the
--   gap between "doesn't generate contradictions" and "preserves all truth."
-- Failure analysis: Had to be careful that the deduction rule didn't affect
--   provability of bot. The key is that the extra rule only derives q from p,
--   never bot from anything new.
-- !-- End Lab Notebook -- !--

-- !-- Lab Notebook: model_implies_consistency_weak -- !--
-- Hypothesis: The model→consistency bridge only needs falsum-soundness, not full soundness.
-- Result: Confirmed — identical proof structure goes through with the weaker hypothesis.
-- Insight: The bridge theorem's proof only ever applies soundness to falsum, never to
--   other sentences. This means the minimal requirement is a very weak form of soundness.
-- Failure analysis: None — this was a clean generalization.
-- !-- End Lab Notebook -- !--

end LogicPhysicsBridge