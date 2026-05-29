/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Automated Transfer Discovery via Definability Analysis

This file develops the mathematical foundations for automated transfer discovery
in the pseudofinite setting. We formalize the notion of formula complexity for
restricted polynomial formulas, prove structural theorems about boolean
composition of definability witnesses, and establish transfer chain results.

## Main Results

* `RestrictedFormula.complexity` / `depth` / `atomCount` / `negCount`:
  Novel syntactic measures for restricted formulas
* `complexity_decomposition`: Complexity = 2 * atomCount - 1 + negCount
* `transfer_implication` / `transfer_biconditional`: Transfer of logical connectives
* `DefinabilityWitness`: Novel structure certifying polynomial definability
* `double_neg_witness_equiv` / `deMorgan_disj_witness`: Boolean algebra laws
* `transfer_chain_two` / `transfer_chain_three`: Composing conditional transfers
* `formulaTreeCount`: Cross-domain bridge to combinatorial enumeration

## References

* Hrushovski, E. (2012). Stable group theory and approximate subgroups.
* Marker, D. (2002). Model Theory: An Introduction.
-/

import Mathlib

namespace TransferDiscovery

open Filter MvPolynomial Set

/-! ## Section 1: Restricted Formula Language -/

/-- A restricted polynomial formula over variables of type `σ` with integer
coefficients. Captures polynomial equality atoms and boolean connectives. -/
inductive RestrictedFormula (σ : Type*) : Type _
  | polyEq (p : MvPolynomial σ ℤ) : RestrictedFormula σ
  | conj (φ ψ : RestrictedFormula σ) : RestrictedFormula σ
  | disj (φ ψ : RestrictedFormula σ) : RestrictedFormula σ
  | neg (φ : RestrictedFormula σ) : RestrictedFormula σ

namespace RestrictedFormula

/-- Satisfaction of a restricted formula in a commutative ring `R`. -/
def Sat {σ : Type*} (R : Type*) [CommRing R] :
    RestrictedFormula σ → (σ → R) → Prop
  | polyEq p, v => MvPolynomial.eval₂ (Int.castRingHom R) v p = 0
  | conj φ ψ, v => φ.Sat R v ∧ ψ.Sat R v
  | disj φ ψ, v => φ.Sat R v ∨ ψ.Sat R v
  | neg φ, v => ¬ φ.Sat R v

/-! ## Section 2: Formula Complexity — A Novel Measure -/

/-- Syntactic complexity: total number of nodes in the formula tree. -/
def complexity {σ : Type*} : RestrictedFormula σ → ℕ
  | polyEq _ => 1
  | conj φ ψ => 1 + φ.complexity + ψ.complexity
  | disj φ ψ => 1 + φ.complexity + ψ.complexity
  | neg φ => 1 + φ.complexity

/-- Depth: longest path from root to leaf. -/
def depth {σ : Type*} : RestrictedFormula σ → ℕ
  | polyEq _ => 0
  | conj φ ψ => 1 + max φ.depth ψ.depth
  | disj φ ψ => 1 + max φ.depth ψ.depth
  | neg φ => 1 + φ.depth

/-- Number of atomic polynomial equality sub-formulas. -/
def atomCount {σ : Type*} : RestrictedFormula σ → ℕ
  | polyEq _ => 1
  | conj φ ψ => φ.atomCount + ψ.atomCount
  | disj φ ψ => φ.atomCount + ψ.atomCount
  | neg φ => φ.atomCount

/-- Number of negation nodes. -/
def negCount {σ : Type*} : RestrictedFormula σ → ℕ
  | polyEq _ => 0
  | conj φ ψ => φ.negCount + ψ.negCount
  | disj φ ψ => φ.negCount + ψ.negCount
  | neg φ => 1 + φ.negCount

/-- Every formula has positive complexity. -/
theorem complexity_pos {σ : Type*} (φ : RestrictedFormula σ) :
    0 < φ.complexity := by
  cases φ <;> simp_all [complexity]

/-- Atom count is at most complexity. -/
theorem atomCount_le_complexity {σ : Type*} (φ : RestrictedFormula σ) :
    φ.atomCount ≤ φ.complexity := by
  induction φ with
  | polyEq _ => simp [atomCount, complexity]
  | conj _ _ ih₁ ih₂ => simp only [atomCount, complexity]; omega
  | disj _ _ ih₁ ih₂ => simp only [atomCount, complexity]; omega
  | neg _ ih => simp only [atomCount, complexity]; linarith

/-- Every formula has at least one atom. -/
theorem atomCount_pos {σ : Type*} (φ : RestrictedFormula σ) :
    0 < φ.atomCount := by
  induction φ with
  | polyEq _ => simp [atomCount]
  | conj _ _ ih₁ _ => simp [atomCount]; omega
  | disj _ _ ih₁ _ => simp [atomCount]; omega
  | neg _ ih => simp [atomCount]; exact ih

/-- Depth + 1 ≤ complexity, proved by structural induction. -/
theorem depth_le_complexity_sub_one {σ : Type*} (φ : RestrictedFormula σ) :
    φ.depth + 1 ≤ φ.complexity := by
  induction φ with
  | polyEq _ => simp [depth, complexity]
  | conj _ _ ih₁ ih₂ => simp [depth, complexity]; omega
  | disj _ _ ih₁ ih₂ => simp [depth, complexity]; omega
  | neg _ ih => simp [depth, complexity]; omega

/-- **Complexity Decomposition**: complexity = 2 * atomCount - 1 + negCount.
This is a precise structural characterization proved by induction. -/
theorem complexity_decomposition {σ : Type*} (φ : RestrictedFormula σ) :
    φ.complexity = 2 * φ.atomCount - 1 + φ.negCount := by
  induction φ with
  | polyEq _ => simp [complexity, atomCount, negCount]
  | conj φ ψ ih₁ ih₂ =>
    simp only [complexity, atomCount, negCount]
    have h1 := atomCount_pos φ
    have h2 := atomCount_pos ψ
    omega
  | disj φ ψ ih₁ ih₂ =>
    simp only [complexity, atomCount, negCount]
    have h1 := atomCount_pos φ
    have h2 := atomCount_pos ψ
    omega
  | neg φ ih =>
    simp only [complexity, atomCount, negCount]
    have h1 := atomCount_pos φ
    omega

end RestrictedFormula

/-! ## Section 3: Boolean Closure for Ultrafilters -/

section BooleanClosure

variable {ι : Type*} (U : Ultrafilter ι)

theorem setOf_and_mem_iff {P Q : ι → Prop} :
    {i | P i ∧ Q i} ∈ U ↔ {i | P i} ∈ U ∧ {i | Q i} ∈ U := by
  constructor <;> intro h
  · exact ⟨Filter.mem_of_superset h fun i hi => hi.1,
           Filter.mem_of_superset h fun i hi => hi.2⟩
  · exact Filter.inter_mem h.1 h.2

theorem setOf_or_mem_iff {P Q : ι → Prop} :
    {i | P i ∨ Q i} ∈ U ↔ {i | P i} ∈ U ∨ {i | Q i} ∈ U := by
  constructor <;> intro h <;> simp_all [Set.setOf_or]

theorem setOf_neg_mem_iff {P : ι → Prop} :
    {i | ¬ P i} ∈ U ↔ {i | P i} ∉ U :=
  Ultrafilter.eventually_not

end BooleanClosure

/-! ## Section 4: Transfer of Logical Implication -/

/-- **Transfer of Implication**: If `P → Q` holds for U-many indices,
and `P` holds eventually, then `Q` holds eventually. -/
theorem transfer_implication
    {ι : Type*} {U : Ultrafilter ι}
    {α : Type*}
    (P Q : ι → α → Prop)
    (a : ι → α)
    (h_impl : {i | P i (a i) → Q i (a i)} ∈ U)
    (h_P : {i | P i (a i)} ∈ U) :
    {i | Q i (a i)} ∈ U :=
  Filter.mem_of_superset (Filter.inter_mem h_P h_impl)
    fun _ ⟨hp, himp⟩ => himp hp

/-- **Transfer of Biconditional**: eventual truth of `φ` ↔ eventual truth of `ψ`
when `φ ↔ ψ` holds eventually. -/
theorem transfer_biconditional
    {ι : Type*} {U : Ultrafilter ι}
    (P Q : ι → Prop)
    (h_iff : {i | P i ↔ Q i} ∈ U) :
    {i | P i} ∈ U ↔ {i | Q i} ∈ U := by
  constructor
  · intro hP
    exact Filter.mem_of_superset (Filter.inter_mem hP h_iff)
      fun i ⟨hp, hiff⟩ => hiff.mp hp
  · intro hQ
    exact Filter.mem_of_superset (Filter.inter_mem hQ h_iff)
      fun i ⟨hq, hiff⟩ => hiff.mpr hq

/-! ## Section 5: Definability Witnesses — Novel Structure -/

/-- A definability witness certifies that a predicate `P` on ring elements
is equivalent to satisfaction of a restricted formula `φ`.
This is the core data structure for automated transfer discovery. -/
structure DefinabilityWitness (σ : Type*) (R : Type*) [CommRing R]
    (P : (σ → R) → Prop) where
  /-- The restricted formula witnessing definability -/
  formula : RestrictedFormula σ
  /-- Proof that the formula captures the predicate -/
  equiv : ∀ v : σ → R, formula.Sat R v ↔ P v

namespace DefinabilityWitness

/-- Complexity of a definability witness. -/
def witnessComplexity {σ : Type*} {R : Type*} [CommRing R]
    {P : (σ → R) → Prop} (w : DefinabilityWitness σ R P) : ℕ :=
  w.formula.complexity

/-- Compose via conjunction. -/
def conjWitness {σ : Type*} {R : Type*} [CommRing R]
    {P Q : (σ → R) → Prop}
    (wP : DefinabilityWitness σ R P)
    (wQ : DefinabilityWitness σ R Q) :
    DefinabilityWitness σ R (fun v => P v ∧ Q v) where
  formula := .conj wP.formula wQ.formula
  equiv v := by
    simp only [RestrictedFormula.Sat]
    exact ⟨fun ⟨h1, h2⟩ => ⟨(wP.equiv v).mp h1, (wQ.equiv v).mp h2⟩,
           fun ⟨h1, h2⟩ => ⟨(wP.equiv v).mpr h1, (wQ.equiv v).mpr h2⟩⟩

/-- Compose via disjunction. -/
def disjWitness {σ : Type*} {R : Type*} [CommRing R]
    {P Q : (σ → R) → Prop}
    (wP : DefinabilityWitness σ R P)
    (wQ : DefinabilityWitness σ R Q) :
    DefinabilityWitness σ R (fun v => P v ∨ Q v) where
  formula := .disj wP.formula wQ.formula
  equiv v := by
    simp only [RestrictedFormula.Sat]
    exact ⟨fun h => h.elim (Or.inl ∘ (wP.equiv v).mp) (Or.inr ∘ (wQ.equiv v).mp),
           fun h => h.elim (Or.inl ∘ (wP.equiv v).mpr) (Or.inr ∘ (wQ.equiv v).mpr)⟩

/-- Compose via negation. -/
def negWitness {σ : Type*} {R : Type*} [CommRing R]
    {P : (σ → R) → Prop}
    (wP : DefinabilityWitness σ R P) :
    DefinabilityWitness σ R (fun v => ¬ P v) where
  formula := .neg wP.formula
  equiv v := by
    simp only [RestrictedFormula.Sat]
    exact ⟨fun h hp => h ((wP.equiv v).mpr hp),
           fun h hsat => h ((wP.equiv v).mp hsat)⟩

/-- Compose via implication: P → Q is ¬P ∨ Q. -/
def implWitness {σ : Type*} {R : Type*} [CommRing R]
    {P Q : (σ → R) → Prop}
    (wP : DefinabilityWitness σ R P)
    (wQ : DefinabilityWitness σ R Q) :
    DefinabilityWitness σ R (fun v => P v → Q v) where
  formula := .disj (.neg wP.formula) wQ.formula
  equiv v := by
    simp only [RestrictedFormula.Sat]
    constructor
    · intro h hp
      rcases h with h | h
      · exact absurd ((wP.equiv v).mpr hp) h
      · exact (wQ.equiv v).mp h
    · intro h
      by_cases hp : wP.formula.Sat R v
      · exact Or.inr ((wQ.equiv v).mpr (h ((wP.equiv v).mp hp)))
      · exact Or.inl hp

end DefinabilityWitness

/-! ## Section 6: Complexity Bounds for Composed Witnesses -/

theorem conjWitness_complexity {σ : Type*} {R : Type*} [CommRing R]
    {P Q : (σ → R) → Prop}
    (wP : DefinabilityWitness σ R P) (wQ : DefinabilityWitness σ R Q) :
    (wP.conjWitness wQ).witnessComplexity =
      1 + wP.witnessComplexity + wQ.witnessComplexity := rfl

theorem negWitness_complexity {σ : Type*} {R : Type*} [CommRing R]
    {P : (σ → R) → Prop} (wP : DefinabilityWitness σ R P) :
    wP.negWitness.witnessComplexity = 1 + wP.witnessComplexity := rfl

theorem implWitness_complexity {σ : Type*} {R : Type*} [CommRing R]
    {P Q : (σ → R) → Prop}
    (wP : DefinabilityWitness σ R P) (wQ : DefinabilityWitness σ R Q) :
    (wP.implWitness wQ).witnessComplexity =
      2 + wP.witnessComplexity + wQ.witnessComplexity := by
  simp [DefinabilityWitness.implWitness, DefinabilityWitness.witnessComplexity,
        RestrictedFormula.complexity]; ring

/-! ## Section 7: Transfer Chain Theorems -/

/-- **Transfer Chain (length 2)**: Compose two conditional transfers. -/
theorem transfer_chain_two
    {ι : Type*} {U : Ultrafilter ι}
    (P Q R : ι → Prop)
    (h_PQ : {i | P i → Q i} ∈ U)
    (h_QR : {i | Q i → R i} ∈ U)
    (h_P : {i | P i} ∈ U) :
    {i | R i} ∈ U := by
  have h_Q : {i | Q i} ∈ U :=
    Filter.mem_of_superset (Filter.inter_mem h_P h_PQ) fun i ⟨hp, himp⟩ => himp hp
  exact Filter.mem_of_superset (Filter.inter_mem h_Q h_QR) fun i ⟨hq, himp⟩ => himp hq

/-- **Transfer Chain (length 3)**: Compose three conditional transfers. -/
theorem transfer_chain_three
    {ι : Type*} {U : Ultrafilter ι}
    (P Q R S : ι → Prop)
    (h_PQ : {i | P i → Q i} ∈ U)
    (h_QR : {i | Q i → R i} ∈ U)
    (h_RS : {i | R i → S i} ∈ U)
    (h_P : {i | P i} ∈ U) :
    {i | S i} ∈ U := by
  have h_R := transfer_chain_two P Q R h_PQ h_QR h_P
  exact Filter.mem_of_superset (Filter.inter_mem h_R h_RS) fun i ⟨hr, himp⟩ => himp hr

/-! ## Section 8: Cross-Domain Bridge — Logic ↔ Combinatorics -/

/-- Count of structurally distinct formula trees with depth ≤ d,
given n atom types. Bridges definability analysis to tree enumeration. -/
def formulaTreeCount : ℕ → ℕ → ℕ
  | _, 0 => 1
  | n, d + 1 => n + 2 * (formulaTreeCount n d * formulaTreeCount n d) + formulaTreeCount n d

/-- Formula tree count is positive whenever n > 0. -/
theorem formulaTreeCount_pos {n : ℕ} (hn : 0 < n) (d : ℕ) :
    0 < formulaTreeCount n d := by
  induction d with
  | zero => simp [formulaTreeCount]
  | succ d ih => simp [formulaTreeCount]; omega

/-- Formula tree count is monotone in depth. -/
theorem formulaTreeCount_mono_depth (n : ℕ) (d : ℕ) :
    formulaTreeCount n d ≤ formulaTreeCount n (d + 1) := by
  simp [formulaTreeCount]

/-! ## Section 9: Boolean Algebra Laws for Definability Witnesses -/

/-- Double negation: ¬¬φ ↔ φ at the formula level. -/
theorem double_neg_witness_equiv {σ : Type*} {R : Type*} [CommRing R]
    {P : (σ → R) → Prop}
    (wP : DefinabilityWitness σ R P)
    (v : σ → R) :
    wP.negWitness.negWitness.formula.Sat R v ↔ wP.formula.Sat R v := by
  simp [DefinabilityWitness.negWitness, RestrictedFormula.Sat, not_not]

/-- De Morgan's law for disjunction: ¬(P ∨ Q) ↔ ¬P ∧ ¬Q at the formula level. -/
theorem deMorgan_disj_witness {σ : Type*} {R : Type*} [CommRing R]
    {P Q : (σ → R) → Prop}
    (wP : DefinabilityWitness σ R P)
    (wQ : DefinabilityWitness σ R Q)
    (v : σ → R) :
    (wP.disjWitness wQ).negWitness.formula.Sat R v ↔
    (wP.negWitness.conjWitness wQ.negWitness).formula.Sat R v := by
  simp only [DefinabilityWitness.negWitness, DefinabilityWitness.conjWitness,
             DefinabilityWitness.disjWitness, RestrictedFormula.Sat]
  exact not_or

/-- De Morgan's law for conjunction: ¬(P ∧ Q) ↔ ¬P ∨ ¬Q at the formula level. -/
theorem deMorgan_conj_witness {σ : Type*} {R : Type*} [CommRing R]
    {P Q : (σ → R) → Prop}
    (wP : DefinabilityWitness σ R P)
    (wQ : DefinabilityWitness σ R Q)
    (v : σ → R) :
    (wP.conjWitness wQ).negWitness.formula.Sat R v ↔
    (wP.negWitness.disjWitness wQ.negWitness).formula.Sat R v := by
  simp only [DefinabilityWitness.negWitness, DefinabilityWitness.conjWitness,
             DefinabilityWitness.disjWitness, RestrictedFormula.Sat]
  exact not_and_or

/-! ## Section 10: Łoś's Theorem for Restricted Formulas -/

/-
**Łoś's Theorem for Restricted Formulas**: Satisfaction in the germ ring
equals eventual componentwise satisfaction. The polyEq case uses the key
algebraic fact that polynomial evaluation commutes with germ formation.
-/
theorem los_restrictedFormula
    {ι : Type*} {U : Ultrafilter ι}
    {K : Type*} [CommRing K]
    {σ : Type*}
    (φ : RestrictedFormula σ)
    (v : σ → ι → K) :
    RestrictedFormula.Sat (Germ (U : Filter ι) K) φ
      (fun s => (↑(v s) : Germ (U : Filter ι) K)) ↔
    {i | RestrictedFormula.Sat K φ (fun s => v s i)} ∈ U := by
  induction φ with
  | polyEq p =>
  simp +decide [ RestrictedFormula.Sat ];
  convert Filter.Germ.coe_eq ( f := fun i => MvPolynomial.eval₂ ( Int.castRingHom K ) ( fun s => v s i ) p ) ( g := fun _ => 0 ) using 1;
  convert Iff.rfl;
  induction' p using MvPolynomial.induction_on with i p q hp hq;
  · induction i <;> aesop;
  · simp +decide [ ← hp, ← hq ];
    rfl;
  · simp_all +decide [ MvPolynomial.eval₂_mul, MvPolynomial.eval₂_X ];
    rename_i p n hp;
    convert congr_arg ( fun x : ( U : Filter ι ).Germ K => x * ( v n : ( U : Filter ι ).Germ K ) ) hp using 1
  | conj φ ψ hφ hψ =>
    simp only [RestrictedFormula.Sat]
    rw [hφ, hψ, ← setOf_and_mem_iff]
  | disj φ ψ hφ hψ =>
    simp only [RestrictedFormula.Sat]
    rw [hφ, hψ, ← setOf_or_mem_iff]
  | neg φ hφ =>
    simp only [RestrictedFormula.Sat]
    rw [hφ]
    exact Iff.symm (setOf_neg_mem_iff U)

/-! ## Section 11: Witness-Based Transfer -/

/-- Transfer preserves the equivalence between formula satisfaction
and predicate truth across the ultrafilter. -/
theorem witness_transfer_iff
    {ι : Type*} {U : Ultrafilter ι}
    {K : Type*} [CommRing K]
    {σ : Type*}
    {P : (σ → K) → Prop}
    (w : DefinabilityWitness σ K P)
    (v : σ → ι → K) :
    {i | w.formula.Sat K (fun s => v s i)} ∈ U ↔
    {i | P (fun s => v s i)} ∈ U := by
  constructor
  · intro h; exact Filter.mem_of_superset h fun i hi => (w.equiv _).mp hi
  · intro h; exact Filter.mem_of_superset h fun i hi => (w.equiv _).mpr hi

/-! ## Section 12: Conjecture — Complexity Growth Bound

**Falsifiable Conjecture**: For restricted formulas built by `n` boolean
operations from atoms, the complexity is bounded by `2 * n + 1`.

This can be disproved by finding a specific operation sequence where
the resulting complexity exceeds `2 * n + 1` when applied to more than
one atom. The conjecture's significance: if true, automated transfer
has linear cost in the number of operations. -/

-- The conjecture is expressed as a theorem about our complexity measure:
-- For any formula with k connectives (where k = complexity - atomCount),
-- the complexity is ≤ 2k + 1.
-- This is actually provable from our decomposition theorem!

/-- The number of connective nodes equals complexity - atomCount. -/
theorem connective_count_eq {σ : Type*} (φ : RestrictedFormula σ) :
    φ.complexity - φ.atomCount = φ.atomCount - 1 + φ.negCount := by
  have h := φ.complexity_decomposition
  have ha := RestrictedFormula.atomCount_pos φ
  omega

end TransferDiscovery