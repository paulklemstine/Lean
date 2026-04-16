/-! # CatalogBuild.Logic.Incompleteness

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 10
-/

import Mathlib

/-- An abstract formal system: a set of sentences with a provability predicate. -/
structure FormalSystem (Sentence : Type*) where
  /-- The provability predicate -/
  provable : Sentence → Prop
  /-- The truth predicate (the "standard model") -/
  true_in_model : Sentence → Prop
  /-- Soundness: provable sentences are true -/
  sound : ∀ s, provable s → true_in_model s



/-- A formal system is complete if every true sentence is provable. -/
def FormalSystem.Complete {S : Type*} (F : FormalSystem S) : Prop :=
  ∀ s, F.true_in_model s → F.provable s



/-- A formal system is consistent if no sentence is both provable and refutable. -/
def FormalSystem.Consistent {S : Type*} (F : FormalSystem S) : Prop :=
  ¬ ∃ s, F.provable s ∧ F.true_in_model s ∧ ¬ F.true_in_model s



/-- A formal system has the **diagonal property** if for every predicate
on sentences, there is a sentence that "says" that predicate holds of itself. -/
def HasDiagonalProperty {S : Type*} (F : FormalSystem S) : Prop :=
  ∀ P : S → Prop, ∃ s : S, F.true_in_model s ↔ P s



/-- [Section: # CatalogBuild.Logic.Incompleteness
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 10] -/
theorem godel_first_incompleteness {S : Type*} (F : FormalSystem S)
    (hdiag : HasDiagonalProperty F) : ¬ F.Complete := by
  intro h_complete
  obtain ⟨G, hG⟩ : ∃ G : S, F.true_in_model G ↔ ¬ F.provable G := hdiag (fun s => ¬ F.provable s);
  by_cases h : F.provable G <;> simp_all +decide [ FormalSystem.Complete ];
  exact hG ( F.sound G h )



theorem godel_sentence_true_but_unprovable {S : Type*} (F : FormalSystem S)
    (hdiag : HasDiagonalProperty F) :
    ∃ s : S, F.true_in_model s ∧ ¬ F.provable s := by
  obtain ⟨ s, hs ⟩ := hdiag ( fun s => ¬F.provable s );
  by_cases h : F.provable s <;> simp_all +decide;
  · exact False.elim ( hs ( F.sound s h ) );
  · use s



theorem tarski_undefinability {S : Type*} (F : FormalSystem S)
    (hdiag : HasDiagonalProperty F) :
    ¬ ∃ T : S → Prop, ∀ s, T s ↔ F.true_in_model s := by
  intro T
  by_contra hT
  obtain ⟨T_def, hT_def⟩ := T
  have hT_def' : ∀ s : S, T_def s ↔ F.true_in_model s := by
    exact hT_def
  obtain ⟨G, hG⟩ := hdiag (fun s => ¬ T_def s)
  simp_all +decide



theorem lob_theorem {S : Type*} (F : FormalSystem S)
    (hdiag : HasDiagonalProperty F)
    (hcomplete_provability : ∀ s, F.provable s → F.true_in_model s)
    (s : S) (h : F.true_in_model s ↔ (F.provable s → F.true_in_model s)) :
    F.true_in_model s := by
  contrapose! hdiag; aesop;



/-- A formal system "asserts its own consistency" if there is a sentence
that is true iff the system is consistent. -/
def AssertsOwnConsistency {S : Type*} (F : FormalSystem S) : Prop :=
  ∃ con : S, F.true_in_model con ↔
    (¬ ∃ s, F.provable s ∧ ¬ F.true_in_model s)



theorem godel_second_incompleteness {S : Type*} (F : FormalSystem S)
    (hdiag : HasDiagonalProperty F)
    (hcons : ¬ ∃ s, F.provable s ∧ ¬ F.true_in_model s)
    (hcon_sentence : ∃ con : S, F.true_in_model con ↔
      (¬ ∃ s, F.provable s ∧ ¬ F.true_in_model s)) :
    ∃ con : S, F.true_in_model con ∧ ¬ F.provable con := by
  -- Apply the diagonal property to the predicate P s := ¬ F.provable s.
  obtain ⟨s, hs⟩ : ∃ s : S, F.true_in_model s ↔ ¬ F.provable s := by
    exact hdiag _;
  grind +qlia


