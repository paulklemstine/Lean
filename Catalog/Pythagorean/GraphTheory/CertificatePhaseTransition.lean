import Mathlib

/-!
# Certificate Phase Transitions in Obstruction Hypergraphs

This file develops a rigorous finite theory of **certificate phase transitions**
for obstruction hypergraph systems. The central objects are finite hypergraphs
whose vertices represent certificate atoms and whose edges represent minimal
obstructions — sets of certificates that are jointly incompatible.

The theory connects:
- **monotone circuit complexity** (certificate search for circuit lower bounds),
- **hypergraph transversal theory** (hitting sets and independent sets),
- **phase transitions in SAT** (threshold phenomena in satisfiability),
- **monotone event theory** (upward/downward-closed families in Boolean lattices).

## Main Definitions

* `CertificateObstructionSystem` — a finite hypergraph of obstructions
* `CertificateSatisfiable` — satisfiability under certificate retention
* `obstructionDensity` — ratio of obstructions to atoms
* `minObstructionSize` — minimum obstruction cardinality
* `TriangleCertSystem` — triangle-detection specialization

## Main Results

* `not_CertificateSatisfiable_mono` — monotonicity of unsatisfiability
* `certificateSatisfiable_iff_compl_hittingSet` — hitting-set equivalence
* `exists_transition_window` — existence of a finite transition window
* `satisfiable_of_card_lt_minObstructionSize` — obstruction-size lower bound
* `upward_closed_unsat_family` — unsatisfiable sets form an upper set
* `satisfiable_family_downward_closed` — satisfiable sets form a simplicial complex

## References

* Berge, C. "Hypergraphs: Combinatorics of Finite Sets"
* Bollobás, B.; Thomason, A. "Threshold functions" (1987)
* Friedgut, E. "Sharp thresholds of graph properties" (1999)
-/

open Finset

/-! ## Core Definitions -/

/-- A **certificate obstruction system** over a finite type `α`.
Vertices of `α` represent certificate atoms; `obstructions` is the family of
minimal jointly incompatible certificate sets (hyperedges).
Every obstruction must be nonempty. -/
structure CertificateObstructionSystem (α : Type*) [DecidableEq α] where
  /-- The family of obstruction sets (hyperedges). -/
  obstructions : Finset (Finset α)
  /-- Every obstruction is nonempty. -/
  nonempty_mem : ∀ s ∈ obstructions, s.Nonempty

/-- A retained certificate set `S` is **satisfiable** if no obstruction is
fully contained in `S`. Equivalently, every obstruction has at least one
atom removed (not in `S`). -/
def CertificateSatisfiable
    {α : Type*} [DecidableEq α]
    (C : CertificateObstructionSystem α) (S : Finset α) : Prop :=
  ∀ o ∈ C.obstructions, ¬ o ⊆ S

/-- The **obstruction density**: ratio of number of obstructions to number of atoms. -/
noncomputable def obstructionDensity
    {α : Type*} [Fintype α] [DecidableEq α]
    (C : CertificateObstructionSystem α) : ℚ :=
  (C.obstructions.card : ℚ) / (Fintype.card α : ℚ)

/-- The **minimum obstruction size**: smallest cardinality among all obstructions.
Returns `none` if there are no obstructions. -/
def minObstructionSize
    {α : Type*} [DecidableEq α]
    (C : CertificateObstructionSystem α) : Option ℕ :=
  if h : C.obstructions.Nonempty then
    some ((C.obstructions.image Finset.card).min' (h.image _))
  else none

/-- Average obstruction size as a rational number. -/
noncomputable def averageObstructionSize
    {α : Type*} [DecidableEq α]
    (C : CertificateObstructionSystem α) : ℚ :=
  if C.obstructions.card = 0 then 0
  else ((C.obstructions.sum Finset.card : ℕ) : ℚ) / (C.obstructions.card : ℚ)

/-! ## Decidable satisfiability check -/

/-- Decidable check: is a retained set `S` satisfiable? -/
instance instDecidableCertificateSatisfiable
    {α : Type*} [DecidableEq α]
    (C : CertificateObstructionSystem α) (S : Finset α) :
    Decidable (CertificateSatisfiable C S) :=
  inferInstanceAs (Decidable (∀ o ∈ C.obstructions, ¬ o ⊆ S))

/-- Boolean satisfiability check. -/
def isCertificateSatisfiableDec
    {α : Type*} [DecidableEq α]
    (C : CertificateObstructionSystem α) (S : Finset α) : Bool :=
  decide (CertificateSatisfiable C S)

/-- Correctness of the Boolean satisfiability check. -/
theorem isCertificateSatisfiableDec_iff
    {α : Type*} [DecidableEq α]
    (C : CertificateObstructionSystem α) (S : Finset α) :
    isCertificateSatisfiableDec C S = true ↔ CertificateSatisfiable C S := by
  simp [isCertificateSatisfiableDec, decide_eq_true_eq]

/-! ## Theorem 1: Monotonicity of unsatisfiability -/

/-
**Monotonicity of unsatisfiability**: If `S ⊆ T` and `S` already contains
a full obstruction, then `T` is also unsatisfiable. Equivalently,
unsatisfiability is upward-closed in the subset lattice.
-/
theorem not_CertificateSatisfiable_mono
    {α : Type*} [DecidableEq α]
    (C : CertificateObstructionSystem α)
    {S T : Finset α}
    (hST : S ⊆ T)
    (hS : ¬ CertificateSatisfiable C S) :
    ¬ CertificateSatisfiable C T := by
  exact fun h => hS fun o ho => fun ho' => h o ho ( Finset.Subset.trans ho' hST )

/-! ## Theorem 1b: Downward closure of satisfiability (simplicial complex) -/

/-
**Downward closure**: satisfiable sets form an abstract simplicial complex.
If `T ⊆ S` and `S` is satisfiable, then `T` is satisfiable.
-/
theorem satisfiable_family_downward_closed
    {α : Type*} [DecidableEq α]
    (C : CertificateObstructionSystem α) :
    ∀ {S T : Finset α}, T ⊆ S → CertificateSatisfiable C S → CertificateSatisfiable C T := by
  exact fun hST hS o ho hoT => hS o ho ( Finset.Subset.trans hoT hST )

/-! ## Cross-domain: Upper set of unsatisfiable family -/

/-
**Upper set structure**: The family of unsatisfiable retained sets is
upward-closed (an upper set) in the Boolean lattice `Finset α` ordered by `⊆`.
This connects to monotone events in percolation and reliability theory.
-/
theorem upward_closed_unsat_family
    {α : Type*} [DecidableEq α]
    (C : CertificateObstructionSystem α) :
    IsUpperSet {S : Finset α | ¬ CertificateSatisfiable C S} := by
  intro T S hT hS;
  convert not_CertificateSatisfiable_mono C hT hS

/-! ## Theorem 2: Hitting-set equivalence -/

/-
**Hitting-set equivalence**: Certificate satisfiability of the retained set `S`
is equivalent to saying that the complement (atoms not in `S`) hits
every obstruction. This bridges SAT/certificate complexity to hypergraph
transversal theory.
-/
theorem certificateSatisfiable_iff_compl_hittingSet
    {α : Type*} [Fintype α] [DecidableEq α]
    (C : CertificateObstructionSystem α)
    (S : Finset α) :
    CertificateSatisfiable C S ↔
      ∀ o ∈ C.obstructions,
        (o.filter fun a => a ∉ S).Nonempty := by
  -- To prove the equivalence, we can use the fact that the condition ¬ o ⊆ S is equivalent to ∃ a ∈ o, a ∉ S.
  simp [CertificateSatisfiable];
  simp +contextual [ Finset.subset_iff, Finset.Nonempty ]

/-! ## Theorem 3: Existence of a finite transition window -/

/-
**Finite transition window**: For any certificate obstruction system where
the empty set is satisfiable and the full universe is unsatisfiable,
there exist cardinality thresholds `k₁ ≤ k₂` such that:
- every subset of size `≤ k₁` is satisfiable,
- every subset of size `≥ k₂` is unsatisfiable.
The interval `[k₁, k₂]` is the finite transition window.
-/
theorem exists_transition_window
    {α : Type*} [Fintype α] [DecidableEq α]
    (C : CertificateObstructionSystem α)
    (h_sat_empty : CertificateSatisfiable C ∅)
    (h_unsat_univ : ¬ CertificateSatisfiable C Finset.univ) :
    ∃ k₁ k₂ : ℕ,
      k₁ ≤ k₂ ∧
      (∀ S : Finset α, S.card ≤ k₁ → CertificateSatisfiable C S) ∧
      (∀ S : Finset α, k₂ ≤ S.card → ¬ CertificateSatisfiable C S) := by
  refine' ⟨ 0, Finset.card ( Finset.univ : Finset α ), _, _, _ ⟩ <;> simp_all +decide [ Finset.card_univ ];
  grind +suggestions

/-! ## Theorem 4: Obstruction-size bound on transition location -/

/-
**Obstruction-size lower bound**: If every obstruction has size at least `d`,
then any retained set of size `< d` is satisfiable.
This gives a structural lower bound on the transition location.
-/
theorem satisfiable_of_card_lt_minObstructionSize
    {α : Type*} [DecidableEq α]
    (C : CertificateObstructionSystem α)
    (d : ℕ)
    (hmin : ∀ o ∈ C.obstructions, d ≤ o.card)
    {S : Finset α}
    (hS : S.card < d) :
    CertificateSatisfiable C S := by
  exact fun o ho => fun h => not_lt_of_ge ( hmin o ho ) ( lt_of_le_of_lt ( Finset.card_le_card h ) hS )

/-! ## Triangle-Detection Specialization -/

/-- Ordered edges of the complete graph on `Fin n`. -/
def orderedEdges (n : ℕ) : Finset (Fin n × Fin n) :=
  Finset.univ.filter fun p => p.1 < p.2

/-- A triangle in `K_n` is a 3-element set of ordered edges `{(i,j), (i,k), (j,k)}`
with `i < j < k`. We encode each triangle as a `Finset` of edges. -/
def triangleEdgeSets (n : ℕ) : Finset (Finset (Fin n × Fin n)) :=
  Finset.univ.filter fun S =>
    ∃ (i j k : Fin n), i < j ∧ j < k ∧
      S = {(i, j), (i, k), (j, k)}

/-- Triangle obstruction system: certificate atoms are ordered edge pairs,
obstructions are triples of edges forming a triangle. -/
noncomputable def triangleCertSystem (n : ℕ) (_hn : 3 ≤ n) :
    CertificateObstructionSystem (Fin n × Fin n) where
  obstructions := triangleEdgeSets n
  nonempty_mem := by
    intro s hs
    simp only [triangleEdgeSets, mem_filter, mem_univ, true_and] at hs
    obtain ⟨i, j, k, _, _, rfl⟩ := hs
    exact ⟨(i, j), mem_insert_self _ _⟩

/-
For the triangle system, every obstruction has size 3.
This uses the fact that `{(i,j), (i,k), (j,k)}` with `i < j < k` has
exactly 3 elements.
-/
theorem triangle_obstruction_size (n : ℕ) (hn : 3 ≤ n)
    (o : Finset (Fin n × Fin n))
    (ho : o ∈ (triangleCertSystem n hn).obstructions) :
    o.card = 3 := by
  grind +locals

/-- For the triangle system, all retained sets of size < 3 are satisfiable. -/
theorem triangle_satisfiable_small (n : ℕ) (hn : 3 ≤ n)
    {S : Finset (Fin n × Fin n)} (hS : S.card < 3) :
    CertificateSatisfiable (triangleCertSystem n hn) S := by
  apply satisfiable_of_card_lt_minObstructionSize _ 3
  · intro o ho
    exact le_of_eq (triangle_obstruction_size n hn o ho).symm
  · exact hS

/-
Certificate satisfiability in the triangle system means the retained edge
set contains no complete triangle — it is **triangle-free**.
This connects certificate phase transitions to classical Ramsey/Turán theory.
-/
theorem triangle_certificate_satisfiable_iff_triangle_free
    (n : ℕ) (hn : 3 ≤ n) (S : Finset (Fin n × Fin n)) :
    CertificateSatisfiable (triangleCertSystem n hn) S ↔
      ∀ (i j k : Fin n), i < j → j < k →
        ¬ ({(i, j), (i, k), (j, k)} ⊆ S) := by
  grind +locals

/-! ## Packing bound: disjoint obstructions force unsatisfiability -/

/-
If the system has `m` pairwise disjoint obstructions, and a retained set
has cardinality ≥ `|α| - m + 1`, then it must contain at least one full obstruction.
This is because we can remove at most one element from each disjoint obstruction.
-/
theorem unsat_of_disjoint_packing
    {α : Type*} [Fintype α] [DecidableEq α]
    (C : CertificateObstructionSystem α)
    (pack : Finset (Finset α))
    (h_sub : ∀ p ∈ pack, p ∈ C.obstructions)
    (h_disj : (pack : Set (Finset α)).PairwiseDisjoint id)
    {S : Finset α}
    (hS : Fintype.card α - pack.card < S.card) :
    ¬ CertificateSatisfiable C S := by
  contrapose! hS;
  have h_complement : (Finset.univ.filter (fun x => x ∉ S)).card ≥ pack.card := by
    have h_complement : ∀ p ∈ pack, (p.filter fun x => x ∉ S).Nonempty := by
      exact fun p hp => by have := hS p ( h_sub p hp ) ; exact Finset.nonempty_of_ne_empty fun h => this <| Finset.subset_iff.mpr fun x hx => by aesop;
    have h_distinct : ∀ p q : Finset α, p ∈ pack → q ∈ pack → p ≠ q → (p.filter fun x => x ∉ S) ∩ (q.filter fun x => x ∉ S) = ∅ := by
      intro p q hp hq hpq; specialize h_disj hp hq hpq; simp_all +decide [ Finset.disjoint_left ] ;
      grind;
    have h_distinct : Finset.card (Finset.biUnion pack (fun p => p.filter fun x => x ∉ S)) ≥ Finset.card pack := by
      rw [ Finset.card_biUnion ];
      · exact le_trans ( by norm_num ) ( Finset.sum_le_sum fun p hp => Finset.card_pos.mpr ( h_complement p hp ) );
      · exact fun p hp q hq hpq => Finset.disjoint_iff_inter_eq_empty.mpr ( h_distinct p q hp hq hpq );
    exact h_distinct.trans ( Finset.card_le_card fun x hx => by aesop );
  simp_all +decide [ Finset.filter_not, Finset.card_sdiff ];
  exact le_tsub_of_add_le_left ( by linarith [ Nat.sub_add_cancel ( show #S ≤ Fintype.card α from Finset.card_le_univ _ ) ] )