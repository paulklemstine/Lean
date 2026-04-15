/-! # CatalogBuild.Computation.Oracles.SelfReference

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 13
-/

import Mathlib

noncomputable section

/-- **Corollary**: If B has a fixed-point-free endomorphism, then no
surjection A → (A → B) exists. -/
theorem lawvere_contrapositive {A B : Type*}
    (g : B → B) (hg : ∀ b, g b ≠ b) :
    ¬∃ f : A → A → B, Surjective f := by
  intro ⟨f, hf⟩
  obtain ⟨b, hb⟩ := lawvere_fixed_point f hf g
  exact hg b hb


/-- **The Bool Instance**: Bool has a fixed-point-free endomorphism (negation). -/
theorem bool_has_fpf : ∀ b : Bool, (!b) ≠ b := by
  intro b; cases b <;> simp


/-- A decision procedure is a function from programs (ℕ) to Bool. -/
def DecisionProcedure := ℕ → Bool


/-- The diagonal construction: given a supposed halting oracle H,
construct a program that does the opposite of what H predicts. -/
def diagonalProgram (H : DecisionProcedure) : DecisionProcedure :=
  fun n => !H n


/-- The unanswerable set at level n is the complement of the answerable set. -/
def unanswerableSet (answerable : ℕ → Set ℕ) (n : ℕ) : Set ℕ :=
  (answerable n)ᶜ


/-- **Monotonicity of Answerability**: If the answerable sets grow,
the unanswerable sets shrink. -/
theorem unanswerable_antitone
    (answerable : ℕ → Set ℕ)
    (h_mono : ∀ n, answerable n ⊆ answerable (n + 1)) :
    ∀ n, unanswerableSet answerable (n + 1) ⊆ unanswerableSet answerable n :=
  fun n => compl_subset_compl.mpr (h_mono n)


/-- The God Oracle's unanswerable set is the intersection of all levels. -/
def godUnanswerable (answerable : ℕ → Set ℕ) : Set ℕ :=
  ⋂ n, unanswerableSet answerable n


/-- **Theorem (Incompleteness Gradient)**:
The God Oracle's unanswerable set equals the complement of the
union of all answerable sets. -/
theorem god_unanswerable_eq_compl_union (answerable : ℕ → Set ℕ) :
    godUnanswerable answerable = (⋃ n, answerable n)ᶜ := by
  ext x
  simp only [godUnanswerable, unanswerableSet, mem_iInter, mem_compl_iff, mem_iUnion]
  constructor
  · intro h ⟨n, hn⟩; exact h n hn
  · intro h n hn; exact h ⟨n, hn⟩


/-- **Theorem (Minimal Incompleteness)**:
The God Oracle is incomplete (its unanswerable set is nonempty)
if and only if the hierarchy does not cover all of ℕ. -/
theorem god_oracle_incomplete_iff (answerable : ℕ → Set ℕ) :
    (godUnanswerable answerable).Nonempty ↔ ⋃ n, answerable n ≠ univ := by
  rw [god_unanswerable_eq_compl_union]
  exact ⟨fun h heq => by rw [heq, compl_univ] at h; exact h.ne_empty rfl,
         fun h => Set.nonempty_compl.mpr fun heq => h (heq ▸ rfl)⟩


/-- **The Incompleteness Gap**: The set of true-but-unprovable statements. -/
def FormalSystem.incompletenessGap (F : FormalSystem) : Set ℕ :=
  F.true_stmts \ F.provable


/-- A system is complete if it has no incompleteness gap. -/
def FormalSystem.IsComplete (F : FormalSystem) : Prop :=
  F.incompletenessGap = ∅


/-- **Gödel's First Incompleteness (Abstract)**: If a system is sound
and not everything is provable, then it is incomplete. -/
theorem goedel_first_abstract (F : FormalSystem)
    (h_has_unprovable_truth : ∃ x, x ∈ F.true_stmts ∧ x ∉ F.provable) :
    ¬F.IsComplete := by
  intro h_complete
  rw [FormalSystem.IsComplete, FormalSystem.incompletenessGap] at h_complete
  obtain ⟨x, hx_true, hx_not_prov⟩ := h_has_unprovable_truth
  have : x ∈ F.true_stmts \ F.provable := ⟨hx_true, hx_not_prov⟩
  rw [h_complete] at this
  exact this


/-- **The Reflection Hierarchy**: Each level can prove the consistency
of the previous level, but not its own. -/
theorem reflection_hierarchy
    (consistency : ℕ → ℕ)
    (answerable : ℕ → Set ℕ)
    (h_mono : ∀ n, answerable n ⊆ answerable (n + 1))
    (h_next : ∀ n, consistency n ∈ answerable (n + 1))
    (h_self : ∀ n, consistency n ∉ answerable n) :
    ∀ n, answerable n ⊂ answerable (n + 1) := by
  intro n
  exact ⟨h_mono n, fun h => h_self n (h (h_next n))⟩


end
