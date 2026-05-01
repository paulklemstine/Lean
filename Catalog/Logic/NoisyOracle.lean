import Mathlib

/-! # CatalogBuild.Computation.Oracles.NoisyOracle

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 6
-/


noncomputable section

/-- For any type, the carriers of O and anti(O) partition the universe. -/
theorem carrier_union_anti_carrier {α : Type*} (O : Oracle α) :
    O.carrier ∪ O.anti.carrier = Set.univ := by
  ext x; simp [anti]




/-- The carriers of O and anti(O) are disjoint. -/
theorem carrier_disjoint_anti {α : Type*} (O : Oracle α) :
    Disjoint O.carrier O.anti.carrier := by
  rw [Set.disjoint_left]; intro x hx ha; simp [anti] at ha; exact ha hx




/-- An oracle and its anti-oracle disagree on every query. -/
theorem anti_total_disagreement {α : Type*} (O : Oracle α) (x : α) :
    (x ∈ O.carrier ∧ x ∉ O.anti.carrier) ∨ (x ∉ O.carrier ∧ x ∈ O.anti.carrier) := by
  simp [anti]; tauto

-- ============================================================
-- Finite oracle cardinality via Finset
-- ============================================================




/-- Convert an oracle on a Fintype to a Finset. -/
noncomputable def Oracle.toFinset (O : Oracle α) : Finset α :=
  Finset.univ.filter (fun x => x ∈ O.carrier)

open Classical in



/-- The anti-oracle's Finset is the complement. -/
theorem anti_toFinset (O : Oracle α) :
    O.anti.toFinset = O.toFinsetᶜ := by
  ext x
  simp only [Oracle.toFinset, Finset.mem_filter, Finset.mem_univ, true_and,
    Finset.mem_compl, anti_carrier, Set.mem_compl_iff]

open Classical in



/-- Cardinality sum: |O| + |anti(O)| = |α|. -/
theorem oracle_card_add_anti_card (O : Oracle α) :
    O.toFinset.card + O.anti.toFinset.card = Fintype.card α := by
  rw [anti_toFinset, Finset.card_compl, Nat.add_sub_cancel' (Finset.card_le_univ _)]




end