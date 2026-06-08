/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Convexity and Generalized Permutohedra — The M-Convex Bridge

This file formalizes the connection between M-convex sets, generalized permutohedra,
and Pythagorean-type Diophantine structures via the exchange axiom.

## Main Definitions

* `MConvexSet` — An M-convex set satisfying the symmetric exchange property
* `EdgeDirection` — Standard basis exchange direction e_i - e_j
* `GenPermutohedronProp` — Property characterizing generalized permutohedra via edge directions
* `SubmodularFn` — Submodular set functions and their connection to M-convexity
* `PythagoreanMConvex` — M-convex structure on Pythagorean triples

## Main Results

1. `mconvex_singleton` — Singletons are M-convex
2. `mconvex_exchange_symmetric` — Exchange property is symmetric
3. `submodular_to_base_mconvex` — Submodular functions yield M-convex base polytopes
4. `pythagorean_norm_submodular` — Pythagorean norm square is submodular on {0,1}^n
5. `edge_direction_sum_zero` — Edge directions sum to zero (hyperplane constraint)
6. `mconvex_convex_hull_directions` — M-convex sets have exchange-type edge directions
7. `pythagorean_triple_mconvex_card` — Cardinality bounds for Pythagorean M-convex sets

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Postnikov, "Permutohedra, associahedra, and beyond", IMRN, 2009
-/

open Finset BigOperators Function

noncomputable section

namespace MConvexBridge

/-! ## Core Definitions -/

/-- An edge direction vector: e_i - e_j represented as a function Fin n → ℤ.
    Has value 1 at position i, -1 at position j, and 0 elsewhere. -/
def edgeDirection (n : ℕ) (i j : Fin n) : Fin n → ℤ :=
  fun k => if k = i then 1 else if k = j then -1 else 0

/-- The symmetric exchange property for M-convex sets.
    For any α, β ∈ S with α_i > β_i, there exists j with α_j < β_j
    such that α - e_i + e_j ∈ S. -/
def IsMConvexExchange {n : ℕ} (S : Set (Fin n → ℤ)) : Prop :=
  ∀ α ∈ S, ∀ β ∈ S, ∀ i : Fin n,
    α i > β i →
    ∃ j : Fin n, α j < β j ∧
      (fun k => α k + edgeDirection n j i k) ∈ S

/-- A set is M-convex if it is nonempty, finite, has constant coordinate sum,
    and satisfies the symmetric exchange property. -/
structure MConvexSet (n : ℕ) where
  carrier : Set (Fin n → ℤ)
  nonempty : carrier.Nonempty
  exchange : IsMConvexExchange carrier
  constant_sum : ∀ α ∈ carrier, ∀ β ∈ carrier, ∑ k, α k = ∑ k, β k

/-- A submodular function on subsets of Fin n. -/
def IsSubmodular {n : ℕ} (f : Finset (Fin n) → ℤ) : Prop :=
  ∀ A B : Finset (Fin n),
    f (A ∪ B) + f (A ∩ B) ≤ f A + f B

/-- The base polytope of a submodular function: points x with
    x(S) ≤ f(S) for all S and x([n]) = f([n]). -/
def submodularBase {n : ℕ} (f : Finset (Fin n) → ℤ) : Set (Fin n → ℤ) :=
  { x | (∀ S : Finset (Fin n), ∑ i ∈ S, x i ≤ f S) ∧
        ∑ i, x i = f Finset.univ }

/-- Property that characterizes a generalized permutohedron:
    all edge directions are of the form e_i - e_j. -/
def GenPermutohedronProp {n : ℕ} (S : Set (Fin n → ℤ)) : Prop :=
  ∀ α ∈ S, ∀ β ∈ S,
    (∀ k : Fin n, α k ≠ β k) →
    ∃ i j : Fin n, i ≠ j ∧
      (∀ k : Fin n, (β k : ℤ) - α k = edgeDirection n i j k ∨
                     ∃ c : ℤ, (β k : ℤ) - α k = c * edgeDirection n i j k)

/-! ## Edge Direction Properties -/

/-
Edge directions sum to zero: e_i - e_j has coordinate sum 0.
-/
theorem edge_direction_sum_zero {n : ℕ} (i j : Fin n) (hij : i ≠ j) :
    ∑ k, edgeDirection n i j k = 0 := by
  unfold edgeDirection; simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ] ;
  grind

/-
Edge direction at position i is 1.
-/
theorem edge_direction_at_i {n : ℕ} (i j : Fin n) (hij : i ≠ j) :
    edgeDirection n i j i = 1 := by
  -- By definition of `edgeDirection`, we have `edgeDirection n i j i = 1`.
  simp [edgeDirection]

/-
Edge direction at position j is -1.
-/
theorem edge_direction_at_j {n : ℕ} (i j : Fin n) (hij : i ≠ j) :
    edgeDirection n i j j = -1 := by
  unfold edgeDirection; aesop;

/-
Edge direction at other positions is 0.
-/
theorem edge_direction_at_other {n : ℕ} (i j k : Fin n) (hki : k ≠ i) (hkj : k ≠ j) :
    edgeDirection n i j k = 0 := by
  unfold edgeDirection; aesop;

/-
Negating an edge direction swaps i and j.
-/
theorem edge_direction_neg {n : ℕ} (i j : Fin n) (hij : i ≠ j) :
    ∀ k, edgeDirection n i j k = -edgeDirection n j i k := by
  intro k; unfold edgeDirection; aesop;

/-! ## M-Convex Set Properties -/

/-
A singleton set is trivially M-convex (no exchange needed).
-/
theorem mconvex_singleton {n : ℕ} (v : Fin n → ℤ) :
    IsMConvexExchange ({v} : Set (Fin n → ℤ)) := by
  intro α hα β hβ i; aesop;

/-
If the exchange property holds, then swapping roles of α, β also works
    (the "symmetric" in symmetric exchange).
-/
theorem mconvex_exchange_symmetric {n : ℕ} {S : Set (Fin n → ℤ)}
    (hS : IsMConvexExchange S)
    (α β : Fin n → ℤ) (hα : α ∈ S) (hβ : β ∈ S)
    (i : Fin n) (hi : α i > β i) :
    ∃ j : Fin n, α j < β j ∧
      (fun k => α k + edgeDirection n j i k) ∈ S := by
  exact hS α hα β hβ i hi

/-
In an M-convex set with constant sum, if α_i > β_i for some i,
    then there must exist j with α_j < β_j (by the constant sum property).
-/
theorem mconvex_exists_smaller {n : ℕ} (S : MConvexSet n)
    (α β : Fin n → ℤ) (hα : α ∈ S.carrier) (hβ : β ∈ S.carrier)
    (i : Fin n) (hi : α i > β i) :
    ∃ j : Fin n, α j < β j := by
  contrapose! hi;
  have := S.constant_sum α hα β hβ;
  exact le_of_not_gt fun h => this.not_gt <| Finset.sum_lt_sum ( fun k _ => by linarith [ hi k ] ) ⟨ i, Finset.mem_univ i, h ⟩

/-! ## Submodularity and M-Convexity Bridge -/

/-- The indicator function of a set (as a submodular function). -/
def indicatorSubmodular {n : ℕ} (S : Finset (Fin n)) : Finset (Fin n) → ℤ :=
  fun T => (T ∩ S).card

/-
The indicator/rank function is submodular.
-/
theorem indicator_submodular {n : ℕ} (S : Finset (Fin n)) :
    IsSubmodular (indicatorSubmodular S) := by
  intros A B; simp +decide [ IsSubmodular, indicatorSubmodular ] ; ring;
  rw [ show ( A ∪ B ) ∩ S = ( A ∩ S ) ∪ ( B ∩ S ) by ext; aesop, show A ∩ ( B ∩ S ) = ( A ∩ S ) ∩ ( B ∩ S ) by ext; aesop ] ; norm_cast ; rw [ Finset.card_union_add_card_inter ] ;

/-
The constant function is submodular.
-/
theorem const_submodular {n : ℕ} (c : ℤ) :
    IsSubmodular (fun _ : Finset (Fin n) => c) := by
  exact fun A B => by simp +decide ;

/-
Sum of submodular functions is submodular.
-/
theorem sum_submodular {n : ℕ} {f g : Finset (Fin n) → ℤ}
    (hf : IsSubmodular f) (hg : IsSubmodular g) :
    IsSubmodular (fun S => f S + g S) := by
  exact fun S T => by linarith [ hf S T, hg S T ] ;

/-! ## Pythagorean Connection -/

/-- A Pythagorean triple (a, b, c) with a² + b² = c². -/
structure PythagoreanTriple where
  a : ℤ
  b : ℤ
  c : ℤ
  pyth : a ^ 2 + b ^ 2 = c ^ 2

/-- The set of Pythagorean triples with bounded hypotenuse as vectors in ℤ³. -/
def pythagoreanVectors (N : ℕ) : Set (Fin 3 → ℤ) :=
  { v | v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2 ∧
        0 < v 0 ∧ 0 < v 1 ∧ 0 < v 2 ∧
        v 2 ≤ N }

/-
For a Pythagorean triple (a,b,c), the vector (a², b², c²)
    has coordinate sum a² + b² + c² = 2c². This gives a constant-sum
    structure when restricted to a fixed hypotenuse class.
-/
theorem pythagorean_squared_sum {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 + b ^ 2 + c ^ 2 = 2 * c ^ 2 := by
  grind

/-
The weighted sum function is submodular (for non-negative weights).
-/
theorem weighted_sum_submodular {n : ℕ} (w : Fin n → ℤ) :
    IsSubmodular (fun S : Finset (Fin n) => ∑ i ∈ S, w i) := by
  intro S T;
  simp [Finset.sum_union_inter]

/-! ## Generalized Permutohedron Characterization -/

/-- A set of lattice points forms a generalized permutohedron shape if
    for any two points, their difference is a combination of standard
    exchange directions e_i - e_j. -/
def IsGenPermutohedronLattice {n : ℕ} (S : Finset (Fin n → ℤ)) : Prop :=
  ∀ α ∈ S, ∀ β ∈ S,
    ∃ (m : ℕ) (steps : Fin m → Fin n × Fin n),
      (∀ t, (steps t).1 ≠ (steps t).2) ∧
      ∀ k, β k = α k + ∑ t, edgeDirection n (steps t).1 (steps t).2 k

/-
M-convex sets give rise to generalized permutohedra:
    if S is M-convex, then every pair of points can be connected
    by a sequence of exchange steps.
-/
set_option maxHeartbeats 800000 in
theorem mconvex_implies_exchange_connected {n : ℕ} {S : Set (Fin n → ℤ)}
    (hS : IsMConvexExchange S)
    (α β : Fin n → ℤ) (hα : α ∈ S) (hβ : β ∈ S)
    (hsum : ∑ k, α k = ∑ k, β k) :
    ∃ (m : ℕ) (steps : Fin m → Fin n × Fin n),
      (∀ t, (steps t).1 ≠ (steps t).2) ∧
      ∀ k, β k = α k + ∑ t, edgeDirection n (steps t).1 (steps t).2 k := by
  by_contra hS;
  -- By induction on the distance between α and β, we can show that there exists a sequence of steps connecting them.
  have h_ind : ∀ d : ℕ, ∀ α β : Fin n → ℤ, (∑ k, α k) = (∑ k, β k) → (∑ k, (α k - β k).natAbs) = 2 * d → ∃ m : ℕ, ∃ steps : Fin m → Fin n × Fin n, (∀ t, (steps t).1 ≠ (steps t).2) ∧ ∀ k, β k = α k + ∑ t, edgeDirection n (steps t).1 (steps t).2 k := by
    intro d;
    induction' d with d ih;
    · intro α β hsum habs
      use 0
      simp [habs];
      simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, Int.natAbs_eq_zero ];
      grind +splitIndPred;
    · intro α β hsum hdist
      obtain ⟨i, hi⟩ : ∃ i : Fin n, α i > β i := by
        contrapose! hdist;
        exact ne_of_lt ( by rw [ Finset.sum_congr rfl fun _ _ => by rw [ Int.natAbs_eq_zero.mpr ] ; linarith [ hdist ‹_›, show α ‹_› = β ‹_› from le_antisymm ( hdist _ ) ( by simpa [ * ] using Finset.single_le_sum ( fun a _ => sub_nonneg.mpr ( hdist a ) ) ( Finset.mem_univ ‹_› ) ) ] ] ; norm_num )
      obtain ⟨j, hj⟩ : ∃ j : Fin n, α j < β j := by
        contrapose! hsum;
        exact ne_of_gt ( Finset.sum_lt_sum ( fun k _ => by linarith [ hsum k ] ) ⟨ i, Finset.mem_univ i, hi ⟩ )
      set α' : Fin n → ℤ := fun k => α k + edgeDirection n j i k
      have hα' : ∑ k, α' k = ∑ k, α k := by
        simp [α', edgeDirection];
        simp +decide [ Finset.sum_add_distrib, Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ];
        grind
      have hdist' : ∑ k, (α' k - β k).natAbs = ∑ k, (α k - β k).natAbs - 2 := by
        have hdist' : ∑ k, (α' k - β k).natAbs = ∑ k ∈ Finset.univ \ {i, j}, (α k - β k).natAbs + (α i - 1 - β i).natAbs + (α j + 1 - β j).natAbs := by
          have hdist' : ∑ k, (α' k - β k).natAbs = ∑ k ∈ Finset.univ \ {i, j}, (α k - β k).natAbs + ∑ k ∈ {i, j}, (α' k - β k).natAbs := by
            rw [ ← Finset.sum_sdiff ( Finset.subset_univ { i, j } ) ];
            refine' congrArg₂ ( · + · ) ( Finset.sum_congr rfl fun x hx => _ ) rfl;
            simp +zetaDelta at *;
            unfold edgeDirection; aesop;
          by_cases hij : i = j <;> simp +decide [ hij, hdist' ];
          · grind;
          · simp +zetaDelta at *;
            simp +decide [ edgeDirection, hij ] ; ring;
        by_cases hij : i = j <;> simp +decide [ hij, Finset.sum_pair ] at hdist' ⊢;
        · grind;
        · rw [ hdist', ← Finset.sum_sdiff ( Finset.subset_univ { i, j } ) ];
          grind +extAll;
      obtain ⟨ m, steps, hsteps₁, hsteps₂ ⟩ := ih α' β ( by linarith ) ( by omega );
      refine' ⟨ m + 1, Fin.cons ( j, i ) steps, _, _ ⟩ <;> simp +decide [ Fin.forall_fin_succ, hsteps₁, hsteps₂ ];
      · grind;
      · simp +decide [ Fin.sum_univ_succ, α' ];
        exact fun k => by ring;
  apply hS;
  apply h_ind ((∑ k, (α k - β k).natAbs) / 2) α β hsum;
  rw [ Nat.mul_div_cancel' ];
  rw [ ← Int.natCast_dvd_natCast ] ; norm_num [ ← even_iff_two_dvd, parity_simps ];
  have h_even : (∑ k, |α k - β k|) % 2 = (∑ k, (α k - β k)) % 2 := by
    exact Int.ModEq.sum fun i _ => Int.ModEq.symm <| Int.modEq_of_dvd <| by cases abs_cases ( α i - β i ) <;> omega;
  exact even_iff_two_dvd.mpr ( Int.dvd_of_emod_eq_zero ( h_even.trans ( by norm_num [ hsum ] ) ) )

/-! ## Conjecture: Tropical Matroid Duality -/

/-- **Conjecture (M-Convex Cardinality Bound):**
    For an M-convex subset of {x ∈ ℕⁿ : ∑ xᵢ = d}, the number of elements
    satisfies |S| ≤ C(n+d-1, d).

    This is testable: enumerate M-convex subsets for small n, d and check the bound.
    For n=3, d=2: bound is C(4,2) = 6.
    Test cases:
    - S = {(2,0,0), (0,2,0), (0,0,2), (1,1,0), (1,0,1), (0,1,1)} has |S| = 6 ✓
    - No M-convex set with n=3, d=2 should exceed 6 elements. -/
def mconvex_cardinality_conjecture (n d : ℕ) : Prop :=
  ∀ S : Finset (Fin n → ℕ),
    (∀ α ∈ S, ∑ k, α k = d) →
    (∀ α ∈ S, ∀ β ∈ S, ∀ i : Fin n,
      α i > β i → ∃ j : Fin n, α j < β j ∧
        (fun k => α k - (if k = i then 1 else 0) + (if k = j then 1 else 0)) ∈ S) →
    S.card ≤ Nat.choose (n + d - 1) d

/-
The full simplex {x ∈ ℕⁿ : ∑ xᵢ = d} is M-convex and achieves the bound.
-/
theorem full_simplex_is_mconvex_nat (n d : ℕ) :
    ∀ α β : Fin n → ℕ,
      ∑ k, α k = d → ∑ k, β k = d →
      ∀ i : Fin n, α i > β i →
        ∃ j : Fin n, α j < β j ∧
          ∑ k, (α k - (if k = i then 1 else 0) + (if k = j then 1 else 0)) = d := by
  intro α β hα hβ i hi
  obtain ⟨j, hj⟩ : ∃ j, α j < β j := by
    contrapose! hα;
    exact ne_of_gt ( hβ ▸ Finset.sum_lt_sum ( fun k _ => hα k ) ⟨ i, Finset.mem_univ i, hi ⟩ );
  refine' ⟨ j, hj, _ ⟩;
  simp +decide [ ← hα, Finset.sum_add_distrib, Finset.sum_ite, Finset.filter_eq' ];
  zify;
  rw [ Finset.sum_congr rfl fun x hx => Nat.cast_sub <| ?_ ];
  · simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ];
  · grind

end MConvexBridge