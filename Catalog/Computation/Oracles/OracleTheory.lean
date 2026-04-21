/-! # CatalogBuild.Computation.Oracles.OracleTheory

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 21
-/

import Mathlib

noncomputable section

/-- The anti-oracle: negates every answer. For set A, the anti-oracle answers
membership in Aᶜ. -/
def anti (O : Oracle α) : Oracle α where
  carrier := O.carrierᶜ




/-- The anti-oracle is an involution: applying it twice returns the original. -/
theorem anti_involution (O : Oracle α) : O.anti.anti = O := by
  ext x; simp [anti]




/-- The empty oracle: answers "no" to everything. -/
def empty : Oracle α where
  carrier := ∅




/-- The universal oracle: answers "yes" to everything. -/
def universal : Oracle α where
  carrier := Set.univ




/-- The empty and universal oracles are anti-oracles of each other. -/
theorem empty_anti_universal : (empty : Oracle α).anti = universal := by
  ext x; simp [anti, empty, universal]




/-- [Section: # CatalogBuild.Computation.Oracles.OracleTheory
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 21] -/
theorem universal_anti_empty : (universal : Oracle α).anti = empty := by
  ext x; simp [anti, empty, universal]




/-- Union of two oracles (join in the lattice). -/
def join (O₁ O₂ : Oracle α) : Oracle α where
  carrier := O₁.carrier ∪ O₂.carrier




/-- Intersection of two oracles (meet in the lattice). -/
def meet (O₁ O₂ : Oracle α) : Oracle α where
  carrier := O₁.carrier ∩ O₂.carrier




/-- De Morgan's law for oracle anti-operation:
anti(join) = meet(anti, anti) -/
theorem anti_join (O₁ O₂ : Oracle α) :
    (O₁.join O₂).anti = O₁.anti.meet O₂.anti := by
  ext x; simp only [anti, join, meet, Set.mem_compl_iff, Set.mem_union, Set.mem_inter_iff,
    ]; push_neg; rfl




/-- De Morgan's law for oracle anti-operation:
anti(meet) = join(anti, anti) -/
theorem anti_meet (O₁ O₂ : Oracle α) :
    (O₁.meet O₂).anti = O₁.anti.join O₂.anti := by
  ext x
  simp only [anti, join, meet, Set.mem_compl_iff, Set.mem_union, Set.mem_inter_iff]
  tauto




/-- For surjective f, pushforward ∘ pullback = id on oracles. -/
theorem pushforward_pullback_of_surjective (O : Oracle β) (f : α → β)
    (hf : Surjective f) :
    (O.pullback f).pushforward f = O := by
  ext x; simp [pullback, pushforward, Set.image_preimage_eq _ hf]




/-- The symmetric difference oracle: XOR of two oracles. -/
def xorOracle (O₁ O₂ : Oracle α) : Oracle α where
  carrier := (O₁.carrier \ O₂.carrier) ∪ (O₂.carrier \ O₁.carrier)




/-- The symmetric difference with self is empty. -/
theorem xor_self (O : Oracle α) : O.xorOracle O = empty := by
  ext x; simp [xorOracle, empty]




/-- The symmetric difference of an oracle with its anti gives the universal oracle. -/
theorem xor_anti (O : Oracle α) : O.xorOracle O.anti = universal := by
  ext x
  simp only [xorOracle, anti, universal, Set.mem_union, Set.mem_diff, Set.mem_compl_iff,
    Set.mem_univ, iff_true]
  tauto




/-- An inverse oracle for the identity function is trivial. -/
def idOracle : InverseOracle α α where
  forward := id
  preimage_oracle := fun a => {a}
  correct := by simp [Set.preimage]




/-- For an injective function, the inverse oracle gives singletons. -/
theorem injective_preimage_singleton (O : InverseOracle α β)
    (hinj : Injective O.forward) (b : β) (a : α) (ha : a ∈ O.preimage_oracle b) :
    O.preimage_oracle b = {a} := by
  rw [O.correct] at ha ⊢
  ext x
  simp [Set.mem_preimage] at ha ⊢
  constructor
  · intro hx; exact hinj (hx.trans ha.symm)
  · intro hx; rw [hx]; exact ha




/-- For a bijective function, the inverse oracle defines a function β → α. -/
def bijective_inverse (O : InverseOracle α β)
    (hbij : Bijective O.forward) : β → α :=
  fun b => (hbij.surjective b).choose




/-- [Section: # CatalogBuild.Computation.Oracles.OracleTheory
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 21] -/
theorem bijective_inverse_spec (O : InverseOracle α β)
    (hbij : Bijective O.forward) (b : β) :
    O.forward (O.bijective_inverse hbij b) = b :=
  (hbij.surjective b).choose_spec




/-- The inverse of a bijective inverse oracle recovers the original function. -/
theorem bijective_inverse_left_inverse (O : InverseOracle α β)
    (hbij : Bijective O.forward) :
    O.forward ∘ O.bijective_inverse hbij = id := by
  funext b; exact O.bijective_inverse_spec hbij b




/-- The Contrarian Oracle Theorem: A "contrarian" that always gives the wrong answer
is computationally equivalent to a correct oracle (just negate). -/
theorem contrarian_oracle_equiv (α : Type*) (O : Oracle α) :
    ∀ x, x ∈ O.carrier ↔ x ∉ O.anti.carrier := by
  intro x; simp [Oracle.anti]




/-- The Information Content Theorem: An oracle and its anti-oracle
carry exactly the same information (are inter-definable). -/
theorem oracle_info_equiv (α : Type*) (O : Oracle α) :
    O.carrier = O.anti.carrierᶜ := by
  simp [Oracle.anti, compl_compl]




end
