/-
# Oracle Theory — Basic Definitions

Formalization of oracles, anti-oracles, and their fundamental properties.

An **oracle** over a type `α` is a decision procedure modeled as a set:
membership in the set means "the oracle answers yes."

The **anti-oracle** (contrarian oracle) always gives the opposite answer.
-/
import Mathlib

namespace OracleTheory

/-- An oracle over a type `α` is a decision set: `x ∈ O.carrier` means
    the oracle answers "yes" to query `x`. -/
@[ext]
structure Oracle (α : Type*) where
  carrier : Set α

namespace Oracle

variable {α : Type*}

/-- The empty oracle: always answers "no". -/
def empty : Oracle α := ⟨∅⟩

/-- The universal oracle: always answers "yes". -/
def univ : Oracle α := ⟨Set.univ⟩

/-- The anti-oracle (contrarian): always gives the opposite answer. -/
def anti (O : Oracle α) : Oracle α := ⟨O.carrierᶜ⟩

/-- The join (union) of two oracles: says "yes" when either says "yes". -/
def join (O₁ O₂ : Oracle α) : Oracle α := ⟨O₁.carrier ∪ O₂.carrier⟩

/-- The meet (intersection) of two oracles: says "yes" when both say "yes". -/
def meet (O₁ O₂ : Oracle α) : Oracle α := ⟨O₁.carrier ∩ O₂.carrier⟩

/-- The symmetric difference (XOR) of two oracles. -/
def xor (O₁ O₂ : Oracle α) : Oracle α := ⟨symmDiff O₁.carrier O₂.carrier⟩

/-- The set difference of two oracles. -/
def sdiff (O₁ O₂ : Oracle α) : Oracle α := ⟨O₁.carrier \ O₂.carrier⟩

-- Simp lemmas for carrier access
@[simp] lemma anti_carrier (O : Oracle α) : O.anti.carrier = O.carrierᶜ := rfl
@[simp] lemma join_carrier (O₁ O₂ : Oracle α) :
    (O₁.join O₂).carrier = O₁.carrier ∪ O₂.carrier := rfl
@[simp] lemma meet_carrier (O₁ O₂ : Oracle α) :
    (O₁.meet O₂).carrier = O₁.carrier ∩ O₂.carrier := rfl
@[simp] lemma xor_carrier (O₁ O₂ : Oracle α) :
    (O₁.xor O₂).carrier = symmDiff O₁.carrier O₂.carrier := rfl
@[simp] lemma sdiff_carrier (O₁ O₂ : Oracle α) :
    (O₁.sdiff O₂).carrier = O₁.carrier \ O₂.carrier := rfl
@[simp] lemma empty_carrier : (empty : Oracle α).carrier = ∅ := rfl
@[simp] lemma univ_carrier : (univ : Oracle α).carrier = Set.univ := rfl

-- ============================================================
-- Core Anti-Oracle Properties
-- ============================================================

/-- **Contrarian Oracle Theorem**: `x ∈ O ↔ x ∉ anti(O)`.
    An oracle that always lies is exactly as informative as one that always tells the truth. -/
theorem contrarian_oracle_equiv (O : Oracle α) :
    ∀ x, x ∈ O.carrier ↔ x ∉ O.anti.carrier := by
  intro x; simp [anti]

/-- The anti-oracle is an involution: `anti(anti(O)) = O`.
    Two wrongs make a right, exactly. -/
@[simp]
theorem anti_anti (O : Oracle α) : O.anti.anti = O := by
  ext x; simp [anti]

/-- Anti-oracle of empty is universal. -/
@[simp]
theorem anti_empty : (empty : Oracle α).anti = univ := by
  ext x; simp [anti, empty, univ]

/-- Anti-oracle of universal is empty. -/
@[simp]
theorem anti_univ : (univ : Oracle α).anti = empty := by
  ext x; simp [anti, empty, univ]

/-- XOR of an oracle with its anti-oracle is the universal oracle.
    Between O and anti(O), every question is answered "yes" by exactly one. -/
theorem xor_anti_eq_univ (O : Oracle α) : O.xor O.anti = univ := by
  ext x
  simp only [xor_carrier, anti_carrier, univ_carrier]
  simp [symmDiff_def, Set.mem_univ]

/-- The meet of an oracle with its anti-oracle is empty:
    no question is answered "yes" by both. -/
theorem meet_anti_eq_empty (O : Oracle α) : O.meet O.anti = empty := by
  ext x; simp [meet, anti, empty]

-- ============================================================
-- De Morgan's Laws for Oracles
-- ============================================================

/-- De Morgan: `anti(join(O₁, O₂)) = meet(anti(O₁), anti(O₂))`. -/
theorem anti_join (O₁ O₂ : Oracle α) :
    (O₁.join O₂).anti = O₁.anti.meet O₂.anti := by
  ext x
  simp only [anti_carrier, join_carrier, meet_carrier, Set.mem_compl_iff,
    Set.mem_union, Set.mem_inter_iff, not_or]

/-- De Morgan: `anti(meet(O₁, O₂)) = join(anti(O₁), anti(O₂))`. -/
theorem anti_meet (O₁ O₂ : Oracle α) :
    (O₁.meet O₂).anti = O₁.anti.join O₂.anti := by
  ext x
  simp only [anti_carrier, meet_carrier, join_carrier, Set.mem_compl_iff,
    Set.mem_inter_iff, Set.mem_union, not_and_or]

-- ============================================================
-- Join/Meet algebraic properties
-- ============================================================

theorem join_comm (O₁ O₂ : Oracle α) : O₁.join O₂ = O₂.join O₁ := by
  ext x; simp [join, Set.mem_union, or_comm]

theorem meet_comm (O₁ O₂ : Oracle α) : O₁.meet O₂ = O₂.meet O₁ := by
  ext x; simp [meet, Set.mem_inter_iff, and_comm]

theorem join_assoc (O₁ O₂ O₃ : Oracle α) :
    (O₁.join O₂).join O₃ = O₁.join (O₂.join O₃) := by
  ext x; simp [join, Set.mem_union, or_assoc]

theorem meet_assoc (O₁ O₂ O₃ : Oracle α) :
    (O₁.meet O₂).meet O₃ = O₁.meet (O₂.meet O₃) := by
  ext x; simp [meet, Set.mem_inter_iff, and_assoc]

theorem join_empty (O : Oracle α) : O.join empty = O := by
  ext x; simp [join, empty]

theorem meet_univ (O : Oracle α) : O.meet univ = O := by
  ext x; simp [meet, univ]

theorem join_self (O : Oracle α) : O.join O = O := by
  ext x; simp [join]

theorem meet_self (O : Oracle α) : O.meet O = O := by
  ext x; simp [meet]

/-- Distributivity: join distributes over meet. -/
theorem join_meet_distrib (O₁ O₂ O₃ : Oracle α) :
    O₁.join (O₂.meet O₃) = (O₁.join O₂).meet (O₁.join O₃) := by
  ext x
  simp only [join_carrier, meet_carrier, Set.mem_union, Set.mem_inter_iff]
  tauto

/-- Distributivity: meet distributes over join. -/
theorem meet_join_distrib (O₁ O₂ O₃ : Oracle α) :
    O₁.meet (O₂.join O₃) = (O₁.meet O₂).join (O₁.meet O₃) := by
  ext x
  simp only [join_carrier, meet_carrier, Set.mem_union, Set.mem_inter_iff]
  tauto

-- ============================================================
-- Subset ordering on oracles
-- ============================================================

/-- Oracle O₁ is weaker than O₂ if every "yes" answer of O₁ is also a "yes" of O₂. -/
def weaker (O₁ O₂ : Oracle α) : Prop := O₁.carrier ⊆ O₂.carrier

theorem weaker_refl (O : Oracle α) : weaker O O := Set.Subset.refl _

theorem weaker_trans {O₁ O₂ O₃ : Oracle α} (h₁ : weaker O₁ O₂) (h₂ : weaker O₂ O₃) :
    weaker O₁ O₃ := Set.Subset.trans h₁ h₂

theorem weaker_antisymm {O₁ O₂ : Oracle α} (h₁ : weaker O₁ O₂) (h₂ : weaker O₂ O₁) :
    O₁ = O₂ := Oracle.ext (Set.Subset.antisymm h₁ h₂)

/-- Anti reverses the ordering. -/
theorem anti_weaker_iff (O₁ O₂ : Oracle α) : weaker O₁.anti O₂.anti ↔ weaker O₂ O₁ := by
  simp [weaker, anti, Set.compl_subset_compl]

-- ============================================================
-- Oracle Equivalence
-- ============================================================

/-- Two oracles are equivalent iff they have the same carrier. -/
theorem oracle_eq_iff (O₁ O₂ : Oracle α) : O₁ = O₂ ↔ O₁.carrier = O₂.carrier :=
  ⟨fun h => h ▸ rfl, Oracle.ext⟩

end Oracle
end OracleTheory
