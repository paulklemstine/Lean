/-
# Sheaf-Theoretic Data Integration: When Databases Form a Sheaf

This file formalizes the connection between database consistency and sheaf theory.
A database with missing entries is modeled as a partial assignment on a grid of
(row, column) positions. The "sheaf condition" requires that partial sections
(subsets of filled cells) agree on their overlaps, enabling consistent gluing
into a global section (a complete database).

## Main Definitions

* `PartialDB` — A partial database: a function from positions to optional values
* `ConsistentPair` — Two partial databases agree on their overlap
* `SheafCondition` — A family of partial databases is pairwise consistent
* `GluingMap` — The union of consistent partial databases
* `CoboundaryNorm` — Measures total inconsistency across overlapping pairs
* `SheafImputationObjective` — The optimization problem for sheaf-based imputation
* `SheafFiltration` — Novel structure: progressive imputation as a filtered complex

## Main Results

* `consistent_pair_symm` — Consistency is symmetric
* `gluing_extends_both` — The gluing of consistent sections extends both
* `coboundary_zero_iff_sheaf` — Zero coboundary norm ⟺ sheaf condition
* `sheaf_condition_of_global_restriction` — Restricting a global section satisfies sheaf condition
* `sheaf_filtration_auto_consistent` — Monotone filtrations are automatically consistent
* `gluing_preserves_consistency` — Gluing preserves consistency with third parties
* `filtration_final_contains_all` — Final filtration level contains all information
* `imputation_zero_iff_extends` — Zero imputation cost ⟺ perfect extension

## Cross-domain bridges

* **Algebraic geometry → Data science**: The sheaf condition on a database is
  the discrete analogue of the gluing axiom in algebraic geometry.
* **Homological algebra → Missing data**: The coboundary operator measures
  data inconsistency; its kernel is the space of consistently imputable databases.
* **Optimization → Sheaf cohomology**: Sheaf imputation minimizes the coboundary
  norm, connecting data imputation to H¹ vanishing.
-/

import Mathlib

open Finset

/-! ## Section 1: Partial Databases and Consistency -/

/-- A position in a database grid: (row, column). -/
abbrev DBPos (nRows nCols : ℕ) := Fin nRows × Fin nCols

/-- A partial database assigns optional values to grid positions.
    `none` represents a missing entry. -/
def PartialDB (nRows nCols : ℕ) (V : Type*) := DBPos nRows nCols → Option V

/-- The domain of a partial database: the set of positions with values. -/
def PartialDB.dom {nRows nCols : ℕ} {V : Type*} (db : PartialDB nRows nCols V) :
    Set (DBPos nRows nCols) :=
  {p | db p ≠ none}

/-- Two partial databases are consistent if they agree on every position
    where both have values. This is the discrete sheaf overlap condition. -/
def ConsistentPair {nRows nCols : ℕ} {V : Type*}
    (db1 db2 : PartialDB nRows nCols V) : Prop :=
  ∀ p : DBPos nRows nCols, ∀ v1 v2 : V,
    db1 p = some v1 → db2 p = some v2 → v1 = v2

/-- A family of partial databases satisfies the sheaf condition if every pair
    is consistent. This is the Čech 0-cocycle condition for the data sheaf. -/
def SheafCondition {nRows nCols : ℕ} {V : Type*} {ι : Type*}
    (dbs : ι → PartialDB nRows nCols V) : Prop :=
  ∀ i j : ι, ConsistentPair (dbs i) (dbs j)

/-- The gluing (union) of two partial databases, preferring the first where both
    are defined. When the pair is consistent, the choice doesn't matter. -/
def GluingMap {nRows nCols : ℕ} {V : Type*}
    (db1 db2 : PartialDB nRows nCols V) : PartialDB nRows nCols V :=
  fun p => match db1 p with
    | some v => some v
    | none => db2 p

/-- A global section: a complete database with no missing values. -/
def IsGlobalSection {nRows nCols : ℕ} {V : Type*}
    (db : PartialDB nRows nCols V) : Prop :=
  ∀ p : DBPos nRows nCols, db p ≠ none

/-- Restriction of a partial database to a set of positions. -/
def PartialDB.restrict {nRows nCols : ℕ} {V : Type*}
    (db : PartialDB nRows nCols V) (S : Set (DBPos nRows nCols))
    [DecidablePred (· ∈ S)] : PartialDB nRows nCols V :=
  fun p => if p ∈ S then db p else none

/-! ## Section 2: Consistency Properties -/

/-- Consistency of partial databases is a symmetric relation.
    This follows from the commutativity of the overlap intersection. -/
theorem consistent_pair_symm {nRows nCols : ℕ} {V : Type*}
    (db1 db2 : PartialDB nRows nCols V)
    (h : ConsistentPair db1 db2) :
    ConsistentPair db2 db1 := by
  intro p v1 v2 h1 h2
  exact (h p v2 v1 h2 h1).symm

/-- The empty partial database (all entries missing) is consistent with everything.
    This is the base case for inductive consistency proofs. -/
theorem consistent_with_empty {nRows nCols : ℕ} {V : Type*}
    (db : PartialDB nRows nCols V) :
    ConsistentPair (fun _ => none) db := by
  intro p v1 _ h1 _
  simp at h1

/-- Consistency is reflexive: every partial database is consistent with itself. -/
theorem consistent_pair_refl {nRows nCols : ℕ} {V : Type*}
    (db : PartialDB nRows nCols V) :
    ConsistentPair db db := by
  intro p v1 v2 h1 h2
  rw [h1] at h2
  exact Option.some.inj h2

/-! ## Section 3: Gluing Properties -/

/-- The gluing of two partial databases extends the first: wherever db1 is defined,
    the gluing agrees with it. -/
theorem gluing_extends_left {nRows nCols : ℕ} {V : Type*}
    (db1 db2 : PartialDB nRows nCols V) (p : DBPos nRows nCols)
    (v : V) (hv : db1 p = some v) :
    GluingMap db1 db2 p = some v := by
  unfold GluingMap
  rw [hv]

/-- The gluing extends the second database where the first is undefined. -/
theorem gluing_extends_right {nRows nCols : ℕ} {V : Type*}
    (db1 db2 : PartialDB nRows nCols V) (p : DBPos nRows nCols)
    (hn : db1 p = none) :
    GluingMap db1 db2 p = db2 p := by
  unfold GluingMap
  rw [hn]

/-- **Gluing extends both**: The gluing of two consistent partial databases
    extends both of them. This is the key sheaf-theoretic property:
    consistent local data can always be assembled into a larger section. -/
theorem gluing_extends_both {nRows nCols : ℕ} {V : Type*}
    (db1 db2 : PartialDB nRows nCols V)
    (hc : ConsistentPair db1 db2) :
    (∀ p v, db1 p = some v → GluingMap db1 db2 p = some v) ∧
    (∀ p v, db2 p = some v → GluingMap db1 db2 p = some v) := by
  constructor
  · intro p v hv
    exact gluing_extends_left db1 db2 p v hv
  · intro p v hv
    unfold GluingMap
    match h : db1 p with
    | some v1 =>
      have := hc p v1 v h hv
      rw [this]
    | none => exact hv

/-! ## Section 4: Sheaf Condition from Global Sections -/

/-- Restricting a global section to any family of subsets always produces
    a family satisfying the sheaf condition. This is the "easy direction"
    of the sheaf correspondence: global sections always glue locally.

    Proof uses case analysis on set membership. -/
theorem sheaf_condition_of_global_restriction {nRows nCols : ℕ} {V : Type*}
    {ι : Type*}
    (g : PartialDB nRows nCols V)
    (S : ι → Set (DBPos nRows nCols))
    [∀ i, DecidablePred (· ∈ S i)] :
    SheafCondition (fun i => g.restrict (S i)) := by
  intro i j p v1 v2 h1 h2
  simp only [PartialDB.restrict] at h1 h2
  split at h1
  · split at h2
    · -- both in their respective sets, so both equal g p
      simp_all
    · cases h2
  · cases h1

/-! ## Section 5: Coboundary and Inconsistency Measurement -/

/-- The disagreement indicator for two partial databases at a position.
    Returns 1 if both are defined and disagree, 0 otherwise.
    This is the pointwise contribution to the Čech coboundary. -/
def disagreementAt {nRows nCols : ℕ} {V : Type*} [DecidableEq V]
    (db1 db2 : PartialDB nRows nCols V) (p : DBPos nRows nCols) : ℕ :=
  match db1 p, db2 p with
  | some v1, some v2 => if v1 = v2 then 0 else 1
  | _, _ => 0

/-- The coboundary norm of a family of partial databases: the total number of
    disagreements across all pairs and positions. This is the discrete analogue
    of the Čech coboundary operator norm ‖δ⁰(σ)‖₁. -/
noncomputable def CoboundaryNorm {nRows nCols : ℕ} {V : Type*} [DecidableEq V]
    {n : ℕ} (dbs : Fin n → PartialDB nRows nCols V) : ℕ :=
  ∑ i : Fin n, ∑ j : Fin n,
    ∑ r : Fin nRows, ∑ c : Fin nCols,
      disagreementAt (dbs i) (dbs j) (r, c)

/-- **Zero coboundary norm is equivalent to the sheaf condition.**
    This connects the algebraic (coboundary = 0) and geometric (gluing exists)
    perspectives. The proof decomposes the sum and uses the definition of
    disagreement pointwise.

    This is the discrete analogue of: ker(δ⁰) = H⁰ = global sections. -/
theorem coboundary_zero_iff_sheaf {nRows nCols : ℕ} {V : Type*} [DecidableEq V]
    {n : ℕ} (dbs : Fin n → PartialDB nRows nCols V) :
    CoboundaryNorm dbs = 0 ↔ SheafCondition dbs := by
  constructor
  · -- Zero norm implies sheaf condition
    intro h0
    unfold CoboundaryNorm at h0
    have hsum := Finset.sum_eq_zero_iff.mp h0
    intro i j p v1 v2 hv1 hv2
    have hi := hsum i (Finset.mem_univ i)
    have hij := Finset.sum_eq_zero_iff.mp hi j (Finset.mem_univ j)
    have hrc := Finset.sum_eq_zero_iff.mp hij p.1 (Finset.mem_univ p.1)
    have hfinal := Finset.sum_eq_zero_iff.mp hrc p.2 (Finset.mem_univ p.2)
    unfold disagreementAt at hfinal
    rw [hv1, hv2] at hfinal
    simp at hfinal
    exact hfinal
  · -- Sheaf condition implies zero norm
    intro hsc
    unfold CoboundaryNorm
    apply Finset.sum_eq_zero
    intro i _
    apply Finset.sum_eq_zero
    intro j _
    apply Finset.sum_eq_zero
    intro r _
    apply Finset.sum_eq_zero
    intro c _
    unfold disagreementAt
    match h1 : dbs i (r, c), h2 : dbs j (r, c) with
    | some v1, some v2 =>
      have := hsc i j (r, c) v1 v2 h1 h2
      simp [this]
    | some _, none => rfl
    | none, _ => rfl

/-! ## Section 6: Overlap Constraint Counting -/

/-- The number of overlap constraints for n partial databases: n*(n-1)/2 pair
    comparisons times nRows*nCols positions per pair. -/
def overlapConstraintCount (n nRows nCols : ℕ) : ℕ :=
  n * (n - 1) / 2 * (nRows * nCols)

/-- The overlap constraint count is zero when there are fewer than 2 databases. -/
theorem overlap_zero_of_lt_two (nRows nCols : ℕ) {n : ℕ} (hn : n < 2) :
    overlapConstraintCount n nRows nCols = 0 := by
  unfold overlapConstraintCount
  interval_cases n <;> simp

/-- The constraint count grows at most quadratically in the number of databases. -/
theorem overlap_quadratic_growth (nRows nCols : ℕ) (n : ℕ) :
    overlapConstraintCount n nRows nCols ≤ n * n * (nRows * nCols) := by
  unfold overlapConstraintCount
  apply Nat.mul_le_mul_right
  calc n * (n - 1) / 2 ≤ n * (n - 1) := Nat.div_le_self _ _
    _ ≤ n * n := Nat.mul_le_mul_left n (Nat.sub_le n 1)

/-! ## Section 7: Consistency Probability Model -/

/-- The consistency probability model: for independent Bernoulli-filled cells,
    the probability that all overlap constraints are satisfied decays exponentially.
    P(consistent) = (1-r)^C where r is the per-constraint disagreement rate
    and C is the number of constraints. -/
noncomputable def consistencyProbability (r : ℝ) (constraintCount : ℕ) : ℝ :=
  (1 - r) ^ constraintCount

/-- Consistency probability is monotone decreasing in constraint count:
    more constraints make consistency harder. -/
theorem consistency_prob_mono_constraints {r : ℝ} (hr0 : 0 ≤ r) (hr1 : r ≤ 1)
    {c1 c2 : ℕ} (hc : c1 ≤ c2) :
    consistencyProbability r c2 ≤ consistencyProbability r c1 := by
  unfold consistencyProbability
  apply pow_le_pow_of_le_one
  · linarith
  · linarith
  · exact hc

/-- Consistency probability is monotone decreasing in the disagreement rate:
    higher noise makes consistency harder. Uses `pow_le_pow_left₀`. -/
theorem consistency_prob_mono_rate {c : ℕ}
    {r1 r2 : ℝ} (hr2 : r2 ≤ 1) (hle : r1 ≤ r2) :
    consistencyProbability r2 c ≤ consistencyProbability r1 c := by
  unfold consistencyProbability
  apply pow_le_pow_left₀ (by linarith)
  linarith

/-- At zero disagreement rate, consistency probability is 1. -/
theorem consistency_prob_zero_rate (c : ℕ) :
    consistencyProbability 0 c = 1 := by
  unfold consistencyProbability
  simp

/-- At disagreement rate 1, consistency probability is 0 for positive constraints. -/
theorem consistency_prob_one_rate {c : ℕ} (hc : 0 < c) :
    consistencyProbability 1 c = 0 := by
  unfold consistencyProbability
  simp [zero_pow (by omega : c ≠ 0)]

/-! ## Section 8: The Sheaf Imputation Problem -/

/-- The sheaf imputation objective: given observed partial data, find the closest
    complete database. The "distance" is the number of observed positions where
    the candidate disagrees with the observation. -/
noncomputable def SheafImputationObjective {nRows nCols : ℕ} {V : Type*} [DecidableEq V]
    (observed : PartialDB nRows nCols V)
    (candidate : DBPos nRows nCols → V) : ℕ :=
  ∑ r : Fin nRows, ∑ c : Fin nCols,
    match observed (r, c) with
    | some v => if v = candidate (r, c) then 0 else 1
    | none => 0

/-- **The imputation objective is zero iff the candidate extends the observed data.**
    This characterizes optimal imputation: zero cost means the candidate preserves
    all observed values while filling in the missing ones. -/
theorem imputation_zero_iff_extends {nRows nCols : ℕ} {V : Type*} [DecidableEq V]
    (observed : PartialDB nRows nCols V)
    (candidate : DBPos nRows nCols → V) :
    SheafImputationObjective observed candidate = 0 ↔
    ∀ p : DBPos nRows nCols, ∀ v : V, observed p = some v → candidate p = v := by
  unfold SheafImputationObjective
  rw [Finset.sum_eq_zero_iff]
  constructor
  · intro h ⟨r, c⟩ v hv
    have hr := h r (Finset.mem_univ r)
    rw [Finset.sum_eq_zero_iff] at hr
    have hc := hr c (Finset.mem_univ c)
    simp only [hv] at hc
    split at hc <;> simp_all
  · intro h r _
    apply Finset.sum_eq_zero
    intro c _
    match hobs : observed (r, c) with
    | some v =>
      have := h (r, c) v hobs
      simp [this]
    | none => simp

/-! ## Section 9: Novel Structure — Sheaf Filtration -/

/-- A **SheafFiltration** is a sequence of increasingly refined partial databases,
    where each level fills in more cells while maintaining consistency with
    all previous levels. This models the progressive imputation process.

    This is a novel concept connecting filtered complexes in homological algebra
    to the progressive refinement of missing data. The monotonicity condition
    ensures information is never lost; the consistency condition ensures all
    intermediate states are compatible. -/
structure SheafFiltration (nRows nCols : ℕ) (V : Type*) (depth : ℕ) where
  /-- The partial databases at each filtration level -/
  level : Fin depth → PartialDB nRows nCols V
  /-- Each level extends the previous one (monotone in information) -/
  monotone : ∀ i j : Fin depth, i ≤ j → ∀ p v,
    level i p = some v → level j p = some v
  /-- All levels are pairwise consistent (sheaf condition holds throughout) -/
  consistent : SheafCondition level

/-- A sheaf filtration is **complete** if the final level is a global section. -/
def SheafFiltration.isComplete {nRows nCols : ℕ} {V : Type*} {depth : ℕ}
    (F : SheafFiltration nRows nCols V depth) (hd : 0 < depth) : Prop :=
  IsGlobalSection (F.level ⟨depth - 1, by omega⟩)

/-- **Monotone filtrations are automatically consistent.**
    If each level extends the previous one (information only grows),
    then pairwise consistency follows automatically. This uses case analysis
    on the ordering of indices.

    This theorem shows that monotonicity is the "right" structural condition:
    it implies consistency for free, reducing the sheaf condition to a
    simpler order-theoretic property. -/
theorem sheaf_filtration_auto_consistent {nRows nCols : ℕ} {V : Type*} {depth : ℕ}
    (levels : Fin depth → PartialDB nRows nCols V)
    (hmono : ∀ i j : Fin depth, i ≤ j → ∀ p v,
      levels i p = some v → levels j p = some v) :
    SheafCondition levels := by
  intro i j p v1 v2 hv1 hv2
  by_cases hij : i ≤ j
  · -- i ≤ j: levels j extends levels i
    have := hmono i j hij p v1 hv1
    rw [this] at hv2
    exact Option.some.inj hv2
  · -- j < i: levels i extends levels j
    push_neg at hij
    have := hmono j i (le_of_lt hij) p v2 hv2
    rw [this] at hv1
    exact (Option.some.inj hv1).symm

/-! ## Section 10: Domain Growth Properties -/

/-- Gluing two partial databases only increases the domain (set of filled positions). -/
theorem gluing_increases_domain {nRows nCols : ℕ} {V : Type*}
    (db1 db2 : PartialDB nRows nCols V) :
    db1.dom ⊆ (GluingMap db1 db2).dom := by
  intro p hp
  unfold PartialDB.dom GluingMap at *
  simp only [Set.mem_setOf_eq] at *
  match h : db1 p with
  | some _ => simp
  | none => exact absurd h hp

/-- Gluing preserves the domain of the second database as well. -/
theorem gluing_preserves_right_domain {nRows nCols : ℕ} {V : Type*}
    (db1 db2 : PartialDB nRows nCols V) :
    db2.dom ⊆ (GluingMap db1 db2).dom := by
  intro p hp
  unfold PartialDB.dom GluingMap at *
  simp only [Set.mem_setOf_eq] at *
  match h : db1 p with
  | some _ => simp
  | none => simp; exact hp

/-! ## Section 11: Conjecture — Exponential Consistency Decay -/

/-- **Conjecture (Exponential Consistency Decay)**:
    For uniformly random databases with missing rate r and n columns, k rows,
    the probability that the sheaf condition holds (consistency across all
    overlapping feature-subset pairs) decays as (1-r)^{C(n,k)}.

    **Testable prediction**: For n=10 columns, k=100 rows, missing rate r=0.3,
    with C = n*(n-1)/2 * k = 4500 overlap constraints, the consistency
    probability is approximately (0.7)^4500 ≈ 10^{-697}, which is essentially zero.

    **To falsify**: Generate 10^6 random 100×10 databases with 30% missing rate
    and count how many satisfy the sheaf condition. If any do, the conjecture
    is too pessimistic. If none do, it confirms the exponential decay. -/
def conjecture_exponential_decay_testable : Prop :=
  ∀ (n k : ℕ) (r : ℝ), 0 < r → r < 1 → 2 ≤ n → 1 ≤ k →
    consistencyProbability r (overlapConstraintCount n k n) <
    consistencyProbability r (k * n)

/-! ## Section 12: Advanced Sheaf-Theoretic Results -/

/-- A partial database **locally extends** another if it agrees on all defined positions
    and fills in at least one more. -/
def LocallyExtends {nRows nCols : ℕ} {V : Type*}
    (db_ext db : PartialDB nRows nCols V) : Prop :=
  (∀ p v, db p = some v → db_ext p = some v) ∧
  (∃ p, db p = none ∧ db_ext p ≠ none)

/-- The gluing of two consistent partial databases locally extends the first
    when the second has information the first lacks. -/
theorem gluing_locally_extends_of_not_contained {nRows nCols : ℕ} {V : Type*}
    (db1 db2 : PartialDB nRows nCols V)
    (_hc : ConsistentPair db1 db2)
    (h_extra : ∃ p, db1 p = none ∧ db2 p ≠ none) :
    LocallyExtends (GluingMap db1 db2) db1 := by
  constructor
  · intro p v hv
    exact gluing_extends_left db1 db2 p v hv
  · obtain ⟨p, hp1, hp2⟩ := h_extra
    exact ⟨p, hp1, by unfold GluingMap; rw [hp1]; exact hp2⟩

/-- **Consistency is preserved under gluing**: if db1, db2, db3 are pairwise
    consistent, then GluingMap db1 db2 is consistent with db3.

    This is crucial for iterated gluing: we can glue databases one at a time
    while preserving consistency with the remaining databases. -/
theorem gluing_preserves_consistency {nRows nCols : ℕ} {V : Type*}
    (db1 db2 db3 : PartialDB nRows nCols V)
    (_h12 : ConsistentPair db1 db2)
    (h13 : ConsistentPair db1 db3)
    (h23 : ConsistentPair db2 db3) :
    ConsistentPair (GluingMap db1 db2) db3 := by
  intro p v1 v2 hv1 hv2
  unfold GluingMap at hv1
  match h : db1 p with
  | some v =>
    rw [h] at hv1
    have := Option.some.inj hv1
    rw [← this]
    exact h13 p v v2 h hv2
  | none =>
    rw [h] at hv1
    exact h23 p v1 v2 hv1 hv2

/-! ## Section 13: Inductive Construction of Sheaf Filtrations -/

/-- Every single partial database forms a trivial sheaf filtration of depth 1. -/
theorem sheaf_filtration_exists_singleton {nRows nCols : ℕ} {V : Type*}
    (db : PartialDB nRows nCols V) :
    ∃ F : SheafFiltration nRows nCols V 1, F.level ⟨0, by omega⟩ = db := by
  refine ⟨{
    level := fun _ => db
    monotone := fun _ _ _ p v hv => hv
    consistent := fun _ _ p v1 v2 hv1 hv2 => by rw [hv1] at hv2; exact Option.some.inj hv2
  }, rfl⟩

/-- **Key Theorem**: In any sheaf filtration, the final level's domain contains
    all domains of previous levels (by monotonicity). This shows that
    information accumulates: nothing is lost across filtration levels. -/
theorem filtration_final_contains_all {nRows nCols : ℕ} {V : Type*} {depth : ℕ}
    (F : SheafFiltration nRows nCols V depth)
    (hd : 0 < depth)
    (i : Fin depth) :
    (F.level i).dom ⊆ (F.level ⟨depth - 1, by omega⟩).dom := by
  intro p hp
  unfold PartialDB.dom at *
  simp only [Set.mem_setOf_eq] at *
  obtain ⟨v, hv⟩ := Option.ne_none_iff_exists'.mp hp
  have hmono := F.monotone i ⟨depth - 1, by omega⟩ (by
    simp only [Fin.le_def]; omega) p v hv
  rw [hmono]
  exact Option.some_ne_none v

/-! ## Section 14: Consistency Probability Composition -/

/-- **Consistency probability composes multiplicatively**: combining two independent
    sets of constraints multiplies the probabilities. This justifies the exponential
    decay model: each new constraint multiplies by (1-r). -/
theorem consistency_prob_mul {r : ℝ} (c1 c2 : ℕ) :
    consistencyProbability r (c1 + c2) =
    consistencyProbability r c1 * consistencyProbability r c2 := by
  unfold consistencyProbability
  exact pow_add (1 - r) c1 c2

/-- Doubling the constraint count squares the probability. -/
theorem consistency_prob_double {r : ℝ} (c : ℕ) :
    consistencyProbability r (2 * c) =
    (consistencyProbability r c) ^ 2 := by
  unfold consistencyProbability
  ring

/-- The consistency probability at rate r with c constraints is bounded above
    by exp(-r*c) when 0 ≤ r ≤ 1 (since 1-r ≤ exp(-r)). We state and prove
    a weaker but useful bound: the probability is at most 1. -/
theorem consistency_prob_le_one {r : ℝ} (_hr0 : 0 ≤ r) (hr1 : r ≤ 1) (c : ℕ) :
    consistencyProbability r c ≤ 1 := by
  unfold consistencyProbability
  apply pow_le_one₀
  · linarith
  · linarith

/-- Nonnegative consistency probability. -/
theorem consistency_prob_nonneg {r : ℝ} (_hr0 : 0 ≤ r) (hr1 : r ≤ 1) (c : ℕ) :
    0 ≤ consistencyProbability r c := by
  unfold consistencyProbability
  apply pow_nonneg
  linarith