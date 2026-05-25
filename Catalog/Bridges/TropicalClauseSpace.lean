/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Tropical Dimension Equals Clause Space for Monotone Formulas

This file establishes a bridge between **proof complexity** and **tropical geometry**
by showing that a combinatorial tropical dimension invariant of clause configurations
coincides with the maximal clause load under natural separation and saturation hypotheses.

## Main Definitions

* `Clause.IsMonotone` — A clause with only positive literals
* `MonotoneCNF` — A CNF formula with only positive literals
* `clauseLoad` — Number of formula clauses active in a configuration
* `tropicalCoord` — Tropical coordinate: 1 if clause is active, 0 otherwise
* `tropicalSupportSize` — Number of nonzero tropical coordinates
* `varyingClauses` — Clauses active in some configs but not all
* `tropicalDim` — Tropical dimension: number of varying coordinates
* `maxClauseLoad` — Maximum clause load across configurations
* `SupportSeparated` — No clause is universally active
* `LoadSaturated` — Some config witnesses all ever-active clauses

## Main Results

* `clauseLoad_eq_tropicalSupportSize` — Load equals tropical support (Theorem 1)
* `monotone_cnf_unsat_iff_empty_clause` — Monotone CNFs: unsat iff has empty clause
* `tropicalDim_le_maxClauseLoad` — Tropical dim ≤ max clause load (Theorem 2)
* `maxClauseLoad_le_tropicalDim` — Reverse inequality under separation (Theorem 2b)
* `tropicalDim_eq_maxClauseLoad` — Equality under separation + saturation (Theorem 3)
* `tropicalDim_eq_supportWidth` — Cross-domain: tropical dim = order-theoretic width
-/
import Mathlib
import Pythagorean.ForbiddenMinor.Defs

open Finset

/-! ## Monotone Formulas -/

/-- A clause is monotone if it contains only positive literals. -/
def Clause.IsMonotone {n : ℕ} (C : Clause n) : Prop :=
  ∀ l ∈ C, ∃ i, l = Literal.pos i

/-- A CNF formula is monotone if all its clauses are monotone. -/
def MonotoneCNF {n : ℕ} (F : CNFFormula n) : Prop :=
  ∀ C ∈ F, Clause.IsMonotone C

instance Clause.decidableIsMonotone {n : ℕ} (C : Clause n) :
    Decidable (Clause.IsMonotone C) :=
  inferInstanceAs (Decidable (∀ l ∈ C, ∃ i, l = Literal.pos i))

instance MonotoneCNF.decidable {n : ℕ} (F : CNFFormula n) :
    Decidable (MonotoneCNF F) :=
  inferInstanceAs (Decidable (∀ C ∈ F, Clause.IsMonotone C))

/-! ## Clause Load and Tropical Embedding -/

/-- The clause load: number of formula clauses active in configuration `C`. -/
def clauseLoad {n s : ℕ} (F : Finset (Clause n)) (C : Config n s) : ℕ :=
  (F.filter (fun D => D ∈ C.clauses)).card

/-- The tropical coordinate of clause `D` at configuration `C`:
    1 if `D` is active in `C`, 0 otherwise. -/
def tropicalCoord {n s : ℕ} (C : Config n s) (D : Clause n) : ℕ :=
  if D ∈ C.clauses then 1 else 0

/-- The tropical support size: number of clauses in `F` with nonzero
    tropical coordinate at configuration `C`. -/
def tropicalSupportSize {n s : ℕ} (F : Finset (Clause n)) (C : Config n s) : ℕ :=
  (F.filter (fun D => tropicalCoord C D ≠ 0)).card

/-! ## Theorem 1: Clause Load Equals Tropical Support Size -/

/-- The tropical coordinate is nonzero iff the clause is active. -/
theorem tropicalCoord_ne_zero_iff {n s : ℕ} (C : Config n s) (D : Clause n) :
    tropicalCoord C D ≠ 0 ↔ D ∈ C.clauses := by
  unfold tropicalCoord; split <;> simp_all

/-- **Theorem 1**: The clause load equals the tropical support size.
    The tropical embedding faithfully represents clause complexity. -/
theorem clauseLoad_eq_tropicalSupportSize {n s : ℕ}
    (F : Finset (Clause n)) (C : Config n s) :
    clauseLoad F C = tropicalSupportSize F C := by
  unfold clauseLoad tropicalSupportSize
  congr 1; ext D; simp only [mem_filter]
  constructor
  · exact fun ⟨hF, hC⟩ => ⟨hF, (tropicalCoord_ne_zero_iff C D).mpr hC⟩
  · exact fun ⟨hF, hne⟩ => ⟨hF, (tropicalCoord_ne_zero_iff C D).mp hne⟩

/-! ## Correction: Monotone CNF Satisfiability -/

/-- **Correction Theorem**: A monotone CNF formula with all clauses nonempty
    is satisfiable — by the all-true assignment. -/
theorem monotone_cnf_sat_of_nonempty_clauses {n : ℕ}
    (F : CNFFormula n) (hmono : MonotoneCNF F)
    (hne : ∀ C ∈ F, C.Nonempty) :
    ∃ σ : Assignment n, F.satisfiedBy σ := by
  use fun _ => true
  intro C hC
  obtain ⟨l, hl⟩ := hne C hC
  obtain ⟨i, hi⟩ := hmono C hC l hl
  subst hi
  exact ⟨Literal.pos i, hl, show Literal.satisfiedBy (Literal.pos i) (fun _ => true) from rfl⟩

/-- A monotone CNF is unsatisfiable iff it contains the empty clause. -/
theorem monotone_cnf_unsat_iff_empty_clause {n : ℕ}
    (F : CNFFormula n) (hmono : MonotoneCNF F) :
    CNFFormula.IsUnsat F ↔ emptyClause n ∈ F := by
  constructor
  · intro hunsat
    by_contra h
    have hne : ∀ C ∈ F, C.Nonempty := by
      intro C hC
      rw [Finset.nonempty_iff_ne_empty]
      intro heq
      apply h
      simp only [emptyClause]
      exact heq ▸ hC
    obtain ⟨σ, hsat⟩ := monotone_cnf_sat_of_nonempty_clauses F hmono hne
    exact hunsat σ hsat
  · intro hempty σ hsat
    have := hsat (emptyClause n) hempty
    obtain ⟨l, hl, _⟩ := this
    exact absurd hl (by simp [emptyClause])

/-! ## Tropical Dimension and Max Clause Load -/

/-- Clauses from `F` active in at least one config but not all. -/
def varyingClauses {n s : ℕ} (F : Finset (Clause n))
    (Configs : Finset (Config n s)) : Finset (Clause n) :=
  F.filter (fun D =>
    (∃ C ∈ Configs, D ∈ C.clauses) ∧ (∃ C ∈ Configs, D ∉ C.clauses))

/-- Clauses from `F` active in at least one configuration. -/
def everActiveClauses {n s : ℕ} (F : Finset (Clause n))
    (Configs : Finset (Config n s)) : Finset (Clause n) :=
  F.filter (fun D => ∃ C ∈ Configs, D ∈ C.clauses)

/-- The **tropical dimension**: number of varying coordinates. -/
def tropicalDim {n s : ℕ} (F : Finset (Clause n))
    (Configs : Finset (Config n s)) : ℕ :=
  (varyingClauses F Configs).card

/-- The **maximal clause load** across configurations. -/
def maxClauseLoad {n s : ℕ} (F : Finset (Clause n))
    (Configs : Finset (Config n s)) : ℕ :=
  Configs.sup (fun C => clauseLoad F C)

/-- **Support separation**: every ever-active clause has a witness of absence. -/
def SupportSeparated {n s : ℕ} (F : Finset (Clause n))
    (Configs : Finset (Config n s)) : Prop :=
  ∀ D ∈ F, (∃ C ∈ Configs, D ∈ C.clauses) → (∃ C ∈ Configs, D ∉ C.clauses)

/-- **Load saturation**: some config witnesses all ever-active clauses. -/
def LoadSaturated {n s : ℕ} (F : Finset (Clause n))
    (Configs : Finset (Config n s)) : Prop :=
  ∃ C ∈ Configs, ∀ D ∈ F, (∃ C' ∈ Configs, D ∈ C'.clauses) → D ∈ C.clauses

/-! ## Key Lemmas -/

theorem varyingClauses_subset_everActive {n s : ℕ}
    (F : Finset (Clause n)) (Configs : Finset (Config n s)) :
    varyingClauses F Configs ⊆ everActiveClauses F Configs := by
  intro D hD
  simp only [varyingClauses, everActiveClauses, mem_filter] at hD ⊢
  exact ⟨hD.1, hD.2.1⟩

theorem clauseLoad_of_saturating {n s : ℕ}
    (F : Finset (Clause n)) (Configs : Finset (Config n s))
    (C : Config n s) (hC : C ∈ Configs)
    (hsat_C : ∀ D ∈ F, (∃ C' ∈ Configs, D ∈ C'.clauses) → D ∈ C.clauses) :
    clauseLoad F C = (everActiveClauses F Configs).card := by
  unfold clauseLoad everActiveClauses
  congr 1; ext D; simp only [mem_filter]
  constructor
  · exact fun ⟨hF, hD⟩ => ⟨hF, ⟨C, hC, hD⟩⟩
  · exact fun ⟨hF, hex⟩ => ⟨hF, hsat_C D hF hex⟩

theorem everActive_eq_varying_of_separated {n s : ℕ}
    (F : Finset (Clause n)) (Configs : Finset (Config n s))
    (hsep : SupportSeparated F Configs) :
    everActiveClauses F Configs = varyingClauses F Configs := by
  ext D
  simp only [everActiveClauses, varyingClauses, mem_filter]
  constructor
  · intro ⟨hF, hex⟩
    exact ⟨hF, hex, hsep D hF hex⟩
  · intro ⟨hF, hex, _⟩
    exact ⟨hF, hex⟩

theorem clauseLoad_le_everActive_card {n s : ℕ}
    (F : Finset (Clause n)) (Configs : Finset (Config n s))
    (C : Config n s) (hC : C ∈ Configs) :
    clauseLoad F C ≤ (everActiveClauses F Configs).card := by
  unfold clauseLoad everActiveClauses
  apply Finset.card_le_card
  intro D; simp only [mem_filter]
  exact fun ⟨hF, hD⟩ => ⟨hF, ⟨C, hC, hD⟩⟩

/-! ## Theorem 2: Tropical Dimension ≤ Max Clause Load -/

/-- **Theorem 2**: Under load saturation, tropical dimension ≤ max clause load. -/
theorem tropicalDim_le_maxClauseLoad {n s : ℕ}
    (F : Finset (Clause n)) (Configs : Finset (Config n s))
    (hsat : LoadSaturated F Configs) :
    tropicalDim F Configs ≤ maxClauseLoad F Configs := by
  obtain ⟨C, hC, hsat_C⟩ := hsat
  unfold tropicalDim maxClauseLoad
  calc (varyingClauses F Configs).card
      ≤ (everActiveClauses F Configs).card :=
        Finset.card_le_card (varyingClauses_subset_everActive F Configs)
    _ = clauseLoad F C := (clauseLoad_of_saturating F Configs C hC hsat_C).symm
    _ ≤ Configs.sup (fun C => clauseLoad F C) := Finset.le_sup hC

/-! ## Theorem 2b: Max Clause Load ≤ Tropical Dimension Under Separation -/

/-- **Theorem 2b**: Under separation, max clause load ≤ tropical dimension. -/
theorem maxClauseLoad_le_tropicalDim {n s : ℕ}
    (F : Finset (Clause n)) (Configs : Finset (Config n s))
    (hsep : SupportSeparated F Configs) :
    maxClauseLoad F Configs ≤ tropicalDim F Configs := by
  unfold maxClauseLoad tropicalDim
  apply Finset.sup_le
  intro C hC
  rw [← everActive_eq_varying_of_separated F Configs hsep]
  exact clauseLoad_le_everActive_card F Configs C hC

/-! ## Theorem 3: The Main Equality -/

/-- **Theorem 3 (Main Theorem)**: Under support separation and load saturation,
    the tropical dimension equals the maximal clause load.

    This is the central result: when clause supports vary independently enough
    (separation) and the configuration space is rich enough (saturation),
    the tropical coordinate geometry has exactly as many dimensions as the
    proof state has simultaneous clause burden. -/
theorem tropicalDim_eq_maxClauseLoad {n s : ℕ}
    (F : Finset (Clause n)) (Configs : Finset (Config n s))
    (hsep : SupportSeparated F Configs)
    (hsat : LoadSaturated F Configs) :
    tropicalDim F Configs = maxClauseLoad F Configs :=
  le_antisymm
    (tropicalDim_le_maxClauseLoad F Configs hsat)
    (maxClauseLoad_le_tropicalDim F Configs hsep)

/-! ## Cross-Domain: Tropical Dimension = Support Width -/

/-- The support width: max clauses from `F` in any single configuration. -/
def supportWidth {n s : ℕ} (F : Finset (Clause n))
    (Configs : Finset (Config n s)) : ℕ :=
  Configs.sup (fun C => (F.filter (· ∈ C.clauses)).card)

/-- Support width = max clause load. -/
theorem supportWidth_eq_maxClauseLoad {n s : ℕ}
    (F : Finset (Clause n)) (Configs : Finset (Config n s)) :
    supportWidth F Configs = maxClauseLoad F Configs := rfl

/-- **Cross-Domain**: Tropical dimension = order-theoretic support width. -/
theorem tropicalDim_eq_supportWidth {n s : ℕ}
    (F : Finset (Clause n)) (Configs : Finset (Config n s))
    (hsep : SupportSeparated F Configs)
    (hsat : LoadSaturated F Configs) :
    tropicalDim F Configs = supportWidth F Configs := by
  rw [supportWidth_eq_maxClauseLoad]
  exact tropicalDim_eq_maxClauseLoad F Configs hsep hsat

/-! ## Auxiliary Bounds -/

theorem tropicalDim_le_card {n s : ℕ}
    (F : Finset (Clause n)) (Configs : Finset (Config n s)) :
    tropicalDim F Configs ≤ F.card := by
  unfold tropicalDim varyingClauses; exact Finset.card_filter_le F _

theorem clauseLoad_le_space {n s : ℕ}
    (F : Finset (Clause n)) (C : Config n s) :
    clauseLoad F C ≤ s := by
  unfold clauseLoad
  calc (F.filter (· ∈ C.clauses)).card
      ≤ C.clauses.card :=
        Finset.card_le_card (fun D => by simp only [mem_filter]; exact fun ⟨_, h⟩ => h)
    _ ≤ s := C.hsize

theorem clauseLoad_le_card {n s : ℕ}
    (F : Finset (Clause n)) (C : Config n s) :
    clauseLoad F C ≤ F.card := by
  unfold clauseLoad; exact Finset.card_filter_le F _

theorem maxClauseLoad_le_space {n s : ℕ}
    (F : Finset (Clause n)) (Configs : Finset (Config n s)) :
    maxClauseLoad F Configs ≤ s := by
  unfold maxClauseLoad; apply Finset.sup_le; intro C _; exact clauseLoad_le_space F C

theorem clauseLoad_emptyConfig {n s : ℕ} (F : Finset (Clause n)) :
    clauseLoad F (emptyConfig n s) = 0 := by
  unfold clauseLoad emptyConfig; simp

/-! ## Complexity Control -/

/-- Bounded tropical dimension implies bounded clause load (converse control). -/
theorem bounded_tropicalDim_implies_bounded_clauseLoad {n s : ℕ}
    (F : Finset (Clause n)) (Configs : Finset (Config n s))
    (k : ℕ) (hsep : SupportSeparated F Configs)
    (hbound : tropicalDim F Configs ≤ k) :
    maxClauseLoad F Configs ≤ k :=
  le_trans (maxClauseLoad_le_tropicalDim F Configs hsep) hbound

/-! ## Verified Computational Methods -/

/-- Compute the tropical profile: `(clauseLoad, tropicalSupportSize)`. -/
def computeTropicalProfile {n s : ℕ} (F : Finset (Clause n))
    (C : Config n s) : ℕ × ℕ :=
  (clauseLoad F C, tropicalSupportSize F C)

/-- The tropical profile has equal components. -/
theorem computeTropicalProfile_eq {n s : ℕ}
    (F : Finset (Clause n)) (C : Config n s) :
    (computeTropicalProfile F C).1 = (computeTropicalProfile F C).2 :=
  clauseLoad_eq_tropicalSupportSize F C

/-- Compute an upper bound on tropical dimension. -/
def computeTropicalDimBound {n s : ℕ} (F : Finset (Clause n))
    (Configs : Finset (Config n s)) : ℕ :=
  (everActiveClauses F Configs).card

/-- The computed bound is correct. -/
theorem computeTropicalDimBound_correct {n s : ℕ}
    (F : Finset (Clause n)) (Configs : Finset (Config n s)) :
    tropicalDim F Configs ≤ computeTropicalDimBound F Configs := by
  unfold tropicalDim computeTropicalDimBound
  exact Finset.card_le_card (varyingClauses_subset_everActive F Configs)

/-- Under separation, the bound is exact. -/
theorem computeTropicalDimBound_exact {n s : ℕ}
    (F : Finset (Clause n)) (Configs : Finset (Config n s))
    (hsep : SupportSeparated F Configs) :
    tropicalDim F Configs = computeTropicalDimBound F Configs := by
  unfold tropicalDim computeTropicalDimBound
  rw [← everActive_eq_varying_of_separated F Configs hsep]

#print axioms clauseLoad_eq_tropicalSupportSize
#print axioms monotone_cnf_sat_of_nonempty_clauses
#print axioms monotone_cnf_unsat_iff_empty_clause
#print axioms tropicalDim_le_maxClauseLoad
#print axioms maxClauseLoad_le_tropicalDim
#print axioms tropicalDim_eq_maxClauseLoad
#print axioms tropicalDim_eq_supportWidth
#print axioms bounded_tropicalDim_implies_bounded_clauseLoad
#print axioms computeTropicalDimBound_correct
#print axioms computeTropicalDimBound_exact