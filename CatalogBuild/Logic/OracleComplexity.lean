/-! # CatalogBuild.Logic.OracleComplexity

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 17
-/

import Mathlib

noncomputable section

/-- Oracle A reduces to Oracle B. -/
def OracleReducesTo {alpha beta : Type*} (A : OracleDecision alpha) (B : OracleDecision beta) : Prop :=
  ∃ f : (beta → Bool) → (alpha → Bool), f B = A


/-- Oracle reduction is reflexive. -/
theorem oracle_reduces_refl {alpha : Type*} (A : OracleDecision alpha) :
    OracleReducesTo A A := ⟨id, rfl⟩


/-- Oracle reduction is transitive. -/
theorem oracle_reduces_trans {alpha beta gamma : Type*}
    (A : OracleDecision alpha) (B : OracleDecision beta) (C : OracleDecision gamma)
    (hAB : OracleReducesTo A B) (hBC : OracleReducesTo B C) :
    OracleReducesTo A C := by
  obtain ⟨f, hf⟩ := hAB
  obtain ⟨g, hg⟩ := hBC
  exact ⟨f ∘ g, by simp [hg, hf]⟩


/-- Oracle equivalence: mutual reducibility. -/
def OracleEquiv {alpha beta : Type*} (A : OracleDecision alpha) (B : OracleDecision beta) : Prop :=
  OracleReducesTo A B ∧ OracleReducesTo B A


/-- [Section: # CatalogBuild.Computation.Oracles.OracleComplexity
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17] -/
theorem oracle_equiv_refl {alpha : Type*} (A : OracleDecision alpha) :
    OracleEquiv A A := ⟨oracle_reduces_refl A, oracle_reduces_refl A⟩


/-- [Section: # CatalogBuild.Computation.Oracles.OracleComplexity
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17] -/
theorem oracle_equiv_symm {alpha beta : Type*} (A : OracleDecision alpha) (B : OracleDecision beta) :
    OracleEquiv A B → OracleEquiv B A := fun ⟨h1, h2⟩ => ⟨h2, h1⟩


/-- [Section: # CatalogBuild.Computation.Oracles.OracleComplexity
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17] -/
theorem oracle_equiv_trans {alpha beta gamma : Type*}
    (A : OracleDecision alpha) (B : OracleDecision beta) (C : OracleDecision gamma) :
    OracleEquiv A B → OracleEquiv B C → OracleEquiv A C :=
  fun ⟨h1, h2⟩ ⟨h3, h4⟩ => ⟨oracle_reduces_trans A B C h1 h3, oracle_reduces_trans C B A h4 h2⟩


theorem query_bound_card (k : ℕ) :
    Fintype.card (Fin k → Bool) = 2 ^ k := by
      norm_num +zetaDelta at *


/-- A k-query strategy can produce at most 2^k distinct outputs. -/
structure QueryStrategy (alpha beta : Type*) (k : ℕ) where
  queries : Fin k → alpha
  decide : (Fin k → Bool) → beta


theorem query_strategy_output_bound {alpha beta : Type*} [DecidableEq beta] (k : ℕ)
    (s : QueryStrategy alpha beta k) :
    (Finset.image s.decide Finset.univ).card ≤ 2 ^ k := by
      convert Finset.card_image_le;
      simp +decide [ Finset.card_univ ]


/-- Oracle composition. -/
def OracleComp {alpha : Type*} (f g : OracleDecision alpha → OracleDecision alpha) :
    OracleDecision alpha → OracleDecision alpha := f ∘ g


theorem oracle_comp_assoc {alpha : Type*}
    (f g h : OracleDecision alpha → OracleDecision alpha) :
    OracleComp f (OracleComp g h) = OracleComp (OracleComp f g) h := rfl


def OracleIdentity {alpha : Type*} : OracleDecision alpha → OracleDecision alpha := id


theorem oracle_comp_id_left {alpha : Type*} (f : OracleDecision alpha → OracleDecision alpha) :
    OracleComp OracleIdentity f = f := rfl


theorem oracle_comp_id_right {alpha : Type*} (f : OracleDecision alpha → OracleDecision alpha) :
    OracleComp f OracleIdentity = f := rfl


theorem oracle_entropy_finite_bound (n : ℕ) :
    Fintype.card (OracleDecision (Fin n)) = 2 ^ n := by
      convert query_bound_card n using 1


/-- Two oracles that agree everywhere are equal. -/
theorem oracle_ext_finite {n : ℕ} (A B : OracleDecision (Fin n))
    (h : ∀ i, A i = B i) : A = B := funext h


end
