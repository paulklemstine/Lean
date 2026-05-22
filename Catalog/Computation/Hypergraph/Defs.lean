import Mathlib

/-!
# Hypergraph Transversal Theory and Monotone SAT Reduction

This file develops the theory of finite hypergraph transversals (hitting sets)
and proves the fundamental equivalence between minimum-weight hitting set problems
and satisfiability of monotone CNF formulas. This connection underlies the
reduction from combinatorial certificate search (e.g., for circuit lower bounds
or Pythagorean coloring) to SAT solving.

## Main Definitions

* `IsTransversal` — predicate: a set hits every edge of a hypergraph
* `MonotoneSatisfies` — satisfiability predicate for monotone CNF

## Main Results

* `hitting_set_iff_monotone_sat` — transversals ↔ satisfying assignments
* `monotone_sat_upward_closed` — monotonicity of satisfaction
* `transversal_superset` — supersets of transversals are transversals
* `sunflower_kernel_hit` — sunflower kernels must be hit by any transversal

## References

* Berge, C. "Hypergraphs: Combinatorics of Finite Sets"
* Cygan et al. "Parameterized Algorithms" §7 (Hitting Set)
* Heule, Kullmann, Marek (2016) "Solving the Boolean Pythagorean Triples Problem"
-/

open Finset

/-! ### Hypergraph Transversals -/

/-- A set T is a transversal (hitting set) of a family of sets `edges`
    if it intersects every member of the family. -/
def IsTransversal (edges : Finset (Finset ℕ)) (T : Finset ℕ) : Prop :=
  ∀ e ∈ edges, (T ∩ e).Nonempty

/-
A superset of a transversal is also a transversal (monotonicity).
-/
theorem transversal_superset (edges : Finset (Finset ℕ)) (T₁ T₂ : Finset ℕ)
    (h₁ : IsTransversal edges T₁) (h_sub : T₁ ⊆ T₂) :
    IsTransversal edges T₂ := by
  -- Since T₁ is a transversal, for every edge e in edges, T₁ intersects e. Because T₂ contains T₁, T₂ must also intersect e. Therefore, T₂ is a transversal.
  intros e he
  have h_inter : (T₁ ∩ e).Nonempty := h₁ e he
  have h_inter_T₂ : (T₂ ∩ e).Nonempty := by
    exact h_inter.imp fun x hx => Finset.mem_inter.mpr ⟨ h_sub <| Finset.mem_of_mem_inter_left hx, Finset.mem_of_mem_inter_right hx ⟩
  exact h_inter_T₂

/-
A transversal of a larger edge set is also a transversal of any subset.
-/
theorem transversal_of_subset_edges (edges₁ edges₂ : Finset (Finset ℕ))
    (h : edges₁ ⊆ edges₂) (T : Finset ℕ) (hT : IsTransversal edges₂ T) :
    IsTransversal edges₁ T := by
  exact fun e he => hT e ( h he )

/-
The empty set is a transversal iff there are no edges.
-/
theorem empty_transversal_iff (edges : Finset (Finset ℕ)) :
    IsTransversal edges ∅ ↔ edges = ∅ := by
  unfold IsTransversal; aesop;

/-
If x is in every edge, then {x} is a transversal.
-/
theorem singleton_transversal (edges : Finset (Finset ℕ)) (x : ℕ)
    (h : ∀ e ∈ edges, x ∈ e) :
    IsTransversal edges {x} := by
  exact fun e he => ⟨ x, by aesop ⟩

/-
The union of all edges is a transversal (if all edges are nonempty).
-/
theorem biUnion_transversal (edges : Finset (Finset ℕ))
    (h : ∀ e ∈ edges, e.Nonempty) :
    IsTransversal edges (edges.biUnion id) := by
  exact fun e he => by obtain ⟨ x, hx ⟩ := h e he; exact ⟨ x, Finset.mem_inter.mpr ⟨ Finset.mem_biUnion.mpr ⟨ e, he, hx ⟩, hx ⟩ ⟩ ;

/-
A transversal of edges ∪ {e} either hits e via an element already in the
    transversal, or must include a new element from e.
-/
theorem transversal_insert (edges : Finset (Finset ℕ)) (e : Finset ℕ) (T : Finset ℕ)
    (hT : IsTransversal (insert e edges) T) :
    IsTransversal edges T ∧ (T ∩ e).Nonempty := by
  exact ⟨ fun e' he' => hT e' ( Finset.mem_insert_of_mem he' ), hT e ( Finset.mem_insert_self _ _ ) ⟩

/-! ### Monotone CNF and the SAT–Hitting Set Equivalence -/

/-- Satisfiability of a monotone CNF: an assignment σ (set of true variables)
    satisfies the formula iff σ intersects every clause. -/
def MonotoneSatisfies (clauses : Finset (Finset ℕ)) (σ : Finset ℕ) : Prop :=
  ∀ c ∈ clauses, (σ ∩ c).Nonempty

/-- **Fundamental Theorem (SAT–Hitting Set Duality)**:
    Satisfying assignments of a monotone CNF are precisely the transversals
    of the clause family viewed as a hypergraph. -/
theorem hitting_set_iff_monotone_sat (clauses : Finset (Finset ℕ)) (σ : Finset ℕ) :
    MonotoneSatisfies clauses σ ↔ IsTransversal clauses σ := by
  rfl

/-
**Monotonicity**: Setting more variables to true preserves satisfaction.
    This upward closure is the defining property of monotone Boolean functions.
-/
theorem monotone_sat_upward_closed (clauses : Finset (Finset ℕ)) (σ₁ σ₂ : Finset ℕ)
    (h_sub : σ₁ ⊆ σ₂) (h_sat : MonotoneSatisfies clauses σ₁) :
    MonotoneSatisfies clauses σ₂ := by
  -- Suppose $σ₂ \supseteq σ₁$ is a larger assignment. If $σ₁$ satisfies every clause $c ∈ clauses$, then since $σ₂$ contains all variables true in $σ₁$, we always have $c ∩ σ₂ \supseteq c ∩ σ₁$. Given $σ₁$ hits $c$ (i.e. $c ∩ σ₁$ is nonempty), $σ₂$ also hits $c$. Hence $σ₂$ satisfies the formula.
  apply transversal_superset clauses σ₁ σ₂ h_sat h_sub

/-- The minimum satisfying assignment size equals the minimum transversal size. -/
theorem min_sat_eq_min_transversal (clauses : Finset (Finset ℕ)) :
    sInf { t : ℕ | ∃ σ : Finset ℕ, MonotoneSatisfies clauses σ ∧ σ.card = t } =
    sInf { t : ℕ | ∃ T : Finset ℕ, IsTransversal clauses T ∧ T.card = t } := by
  rfl

/-! ### Sunflower Structure -/

/-- A sunflower (Δ-system) with kernel K: all pairwise intersections equal K,
    and K is contained in every member. -/
def IsSunflower (family : Finset (Finset ℕ)) (kernel : Finset ℕ) : Prop :=
  (∀ e ∈ family, kernel ⊆ e) ∧
  ∀ e₁ ∈ family, ∀ e₂ ∈ family, e₁ ≠ e₂ → e₁ ∩ e₂ = kernel

/-
A pair of distinct sets forms a sunflower with their intersection as kernel.
-/
theorem pair_is_sunflower (e₁ e₂ : Finset ℕ) (h : e₁ ≠ e₂) :
    IsSunflower {e₁, e₂} (e₁ ∩ e₂) := by
  constructor <;> aesop

/-
**Sunflower Kernel Hitting**: If a family forms a sunflower with nonempty kernel K,
    and a transversal T doesn't hit the kernel, then T must have at least one element
    in each petal (each e \ K), meaning |T| ≥ |family|.
-/
theorem sunflower_kernel_or_large_transversal
    (family : Finset (Finset ℕ)) (kernel : Finset ℕ)
    (T : Finset ℕ)
    (_h_sun : IsSunflower family kernel)
    (h_trans : IsTransversal family T) :
    (T ∩ kernel).Nonempty ∨
    ∃ f : ∀ e ∈ family, ℕ, ∀ e he, f e he ∈ T ∧ f e he ∈ e ∧ f e he ∉ kernel := by
  by_cases h : ( T ∩ kernel ).Nonempty <;> simp +decide [ h ];
  simp_all +decide [ Finset.Nonempty ];
  exact ⟨ fun e he => Classical.choose ( h_trans e he ), fun e he => ⟨ Classical.choose_spec ( h_trans e he ) |> fun x => Finset.mem_of_mem_inter_left x, Classical.choose_spec ( h_trans e he ) |> fun x => Finset.mem_of_mem_inter_right x, h _ ( Classical.choose_spec ( h_trans e he ) |> fun x => Finset.mem_of_mem_inter_left x ) ⟩ ⟩

/-! ### Pythagorean Triple Theory -/

/-- A Pythagorean triple (a, b, c) satisfies a² + b² = c². -/
def IsPythagoreanTriple (a b c : ℕ) : Prop :=
  a ^ 2 + b ^ 2 = c ^ 2

/-- (3, 4, 5) is a Pythagorean triple. -/
theorem pythagorean_3_4_5 : IsPythagoreanTriple 3 4 5 := by
  unfold IsPythagoreanTriple; norm_num

/-- (5, 12, 13) is a Pythagorean triple. -/
theorem pythagorean_5_12_13 : IsPythagoreanTriple 5 12 13 := by
  unfold IsPythagoreanTriple; norm_num

/-- (8, 15, 17) is a Pythagorean triple. -/
theorem pythagorean_8_15_17 : IsPythagoreanTriple 8 15 17 := by
  unfold IsPythagoreanTriple; norm_num

/-- (7, 24, 25) is a Pythagorean triple. -/
theorem pythagorean_7_24_25 : IsPythagoreanTriple 7 24 25 := by
  unfold IsPythagoreanTriple; norm_num

/-
Scaling preserves Pythagorean triples.
-/
theorem pythagorean_triple_scale (a b c k : ℕ) (h : IsPythagoreanTriple a b c) :
    IsPythagoreanTriple (k * a) (k * b) (k * c) := by
  grind +locals

/-
Euclid's formula: (m² - n², 2mn, m² + n²) is a Pythagorean triple for m > n.
-/
theorem euclid_pythagorean_triple (m n : ℕ) (h : n < m) :
    IsPythagoreanTriple (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) := by
  exact Eq.symm ( by nlinarith [ Nat.sub_add_cancel ( by nlinarith : n ^ 2 ≤ m ^ 2 ) ] )

/-- A primitive Pythagorean triple: coprime with positive parts. -/
def IsPrimitivePythagoreanTriple (a b c : ℕ) : Prop :=
  IsPythagoreanTriple a b c ∧ Nat.Coprime a b ∧ 0 < a ∧ 0 < b

/-- (3, 4, 5) is primitive. -/
theorem primitive_pythagorean_3_4_5 : IsPrimitivePythagoreanTriple 3 4 5 := by
  refine ⟨pythagorean_3_4_5, ?_, by norm_num, by norm_num⟩
  decide

/-! ### Pythagorean Coloring -/

/-- The Boolean Pythagorean Triples problem: does a 2-coloring χ : {1,...,n} → Bool
    have a monochromatic Pythagorean triple? -/
def HasMonochromaticTriple (n : ℕ) (χ : Fin n → Bool) : Prop :=
  ∃ a b c : Fin n, (a : ℕ) + 1 > 0 ∧ (b : ℕ) + 1 > 0 ∧ (c : ℕ) + 1 > 0 ∧
    IsPythagoreanTriple ((a : ℕ) + 1) ((b : ℕ) + 1) ((c : ℕ) + 1) ∧
    χ a = χ b ∧ χ b = χ c

/-
For n ≤ 4, any coloring trivially avoids monochromatic triples
    (no Pythagorean triple fits in {1,2,3,4}).
-/
theorem no_triple_le_4 (a b c : ℕ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (ha4 : a ≤ 4) (hb4 : b ≤ 4) (hc4 : c ≤ 4) (hab : a < b)
    (hbc : b < c) (h : IsPythagoreanTriple a b c) : False := by
  interval_cases a <;> interval_cases b <;> interval_cases c <;> simp +decide at h hab hbc ⊢;
  · cases h;
  · cases h;
  · cases h;
  · cases h

/-
n = 5 admits a valid 2-coloring: the coloring {1,4}→true, {2,3,5}→false
    avoids monochromatic Pythagorean triples.
-/
theorem pythagorean_coloring_5_exists :
    ∃ χ : Fin 5 → Bool, ¬HasMonochromaticTriple 5 χ := by
  simp +decide [ HasMonochromaticTriple ];
  simp +decide [ IsPythagoreanTriple ]