import Mathlib

/-!
# Tropical Spectral Graph Theory

## Overview

We develop a spectral theory of directed graphs using the min-plus (tropical)
semiring structure on `WithTop ℕ`. Instead of counting walks (classical spectral
theory), we compute shortest-weight walks using the (min, +) algebra.

The key insight: tropical matrix powers compute shortest-path distances.
The (i,j) entry of the k-th min-plus power gives the minimum total weight
of any walk of exactly k edges from i to j.

## Main Results

1. **Min-plus identity laws**: I ⊗ A = A = A ⊗ I
2. **Min-plus associativity**: (A ⊗ B) ⊗ C = A ⊗ (B ⊗ C)
3. **Walk composition**: A^⊗(k+l) = A^⊗k ⊗ A^⊗l
4. **Moment vanishing**: 0-th moment is 0, 1st moment is ⊤ (no self-loops)
5. **DAG moment vanishing**: In a DAG, all positive-order moments are ⊤
6. **Moment lower bound**: μ_k ≥ k · w_min for finite moments
7. **Weight monotonicity**: Decreasing weights decreases moments
8. **Dense cycle detection**: Complete digraphs have finite 2nd moment

## Novel Definitions

- `WDGraph`: Weighted directed graph with `WithTop ℕ` edge weights
- `minPlusMul`: Min-plus matrix multiplication
- `minPlusPow`: Iterated min-plus matrix power
- `tropTrace`: Tropical trace (minimum of diagonal)
- `tropMoment`: k-th tropical spectral moment

## References

- Butkovič, *Max-linear Systems: Theory and Algorithms*, Springer 2010
- Akian, Bapat, Gaubert, "Min-plus methods in eigenvalue perturbation theory"
-/

noncomputable section

open Finset BigOperators

/-! ## Weighted Directed Graphs -/

/-- A weighted directed graph on `Fin n` with edge weights in `WithTop ℕ`.
    `⊤` represents no edge; finite values represent edge weights.
    Self-loops are forbidden (weight ⊤ on diagonal). -/
structure WDGraph (n : ℕ) where
  weight : Fin n → Fin n → WithTop ℕ
  no_selfloop : ∀ i, weight i i = ⊤

namespace WDGraph

variable {n : ℕ}

/-- Whether an edge exists from i to j. -/
def hasEdge (G : WDGraph n) (i j : Fin n) : Prop :=
  G.weight i j ≠ ⊤

/-- Out-degree: number of outgoing edges from vertex i. -/
def outDeg (G : WDGraph n) (i : Fin n) : ℕ :=
  (univ.filter (fun j => G.weight i j ≠ ⊤)).card

/-- A weighted digraph is a DAG if it has a topological ordering. -/
def IsDAG (G : WDGraph n) : Prop :=
  ∃ f : Fin n → ℕ, ∀ i j, G.hasEdge i j → f j < f i

/-! ## Min-Plus Matrix Operations -/

/-- Min-plus matrix multiplication.
    (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj}) -/
def minPlusMul (A B : Fin n → Fin n → WithTop ℕ) :
    Fin n → Fin n → WithTop ℕ :=
  fun i j => univ.inf (fun k => A i k + B k j)

/-- Min-plus identity matrix: 0 on diagonal, ⊤ off diagonal. -/
def minPlusId : Fin n → Fin n → WithTop ℕ :=
  fun i j => if i = j then 0 else ⊤

/-- Min-plus matrix power: A^⊗k.
    - A^⊗0 = I (identity)
    - A^⊗(k+1) = A^⊗k ⊗ A -/
def minPlusPow (A : Fin n → Fin n → WithTop ℕ) : ℕ → Fin n → Fin n → WithTop ℕ
  | 0 => minPlusId
  | k + 1 => minPlusMul (minPlusPow A k) A

/-- The tropical trace: min of diagonal entries. -/
def tropTrace (M : Fin n → Fin n → WithTop ℕ) : WithTop ℕ :=
  univ.inf (fun i => M i i)

/-- The k-th tropical spectral moment: tropical trace of A^⊗k. -/
def tropMoment (G : WDGraph n) (k : ℕ) : WithTop ℕ :=
  tropTrace (minPlusPow G.weight k)

/-! ## Identity Laws -/

/-
Left identity: I ⊗ A = A.
    For each (i,j), min_k (I_{ik} + A_{kj}) = A_{ij} because
    the k=i term gives 0 + A_{ij} = A_{ij} and k≠i terms give ⊤.
-/
theorem minPlusMul_id_left (A : Fin n → Fin n → WithTop ℕ) :
    minPlusMul minPlusId A = A := by
      ext i j; simp +decide [ minPlusMul, minPlusId ] ;
      exact le_antisymm ( Finset.inf_le ( Finset.mem_univ i ) |> le_trans <| by aesop ) ( Finset.le_inf fun k _ => by aesop )

/-
Right identity: A ⊗ I = A.
-/
theorem minPlusMul_id_right (A : Fin n → Fin n → WithTop ℕ) :
    minPlusMul A minPlusId = A := by
      funext i j;
      refine' le_antisymm _ _ <;> simp +decide [ minPlusMul ];
      · exact Finset.inf_le ( Finset.mem_univ j ) |> le_trans <| by simp +decide [ minPlusId ] ;
      · intro k; by_cases hk : k = j <;> simp +decide [ hk, minPlusId ] ;

/-! ## Associativity -/

/-
**Min-plus multiplication is associative**: (A ⊗ B) ⊗ C = A ⊗ (B ⊗ C).
    This uses distributivity of + over min in `WithTop ℕ` and
    exchange of two inf operations.
-/
theorem minPlusMul_assoc (A B C : Fin n → Fin n → WithTop ℕ) :
    minPlusMul (minPlusMul A B) C = minPlusMul A (minPlusMul B C) := by
      -- By the properties of the infimum and the distributivity of addition over infimum in `WithTop ℕ`, we can show that both sides are equal.
      have h_eq : ∀ i j, (Finset.univ.inf (fun k => (Finset.univ.inf (fun l => A i l + B l k) + C k j))) = (Finset.univ.inf (fun l => A i l + (Finset.univ.inf (fun k => B l k + C k j)))) := by
        have h_inf_add_right : ∀ (S : Finset (Fin n)) (f : Fin n → WithTop ℕ) (c : WithTop ℕ), (Finset.inf S (fun k => f k + c)) = (Finset.inf S f) + c := by
          intros S f c; induction S using Finset.induction <;> simp_all +decide [ add_assoc ] ;
          cases c ; aesop;
          cases f ‹_› <;> cases ( Finset.inf ‹_› f ) <;> norm_cast;
          grind +revert;
        have h_inf_add_left : ∀ (S : Finset (Fin n)) (f : Fin n → WithTop ℕ) (c : WithTop ℕ), (Finset.inf S (fun k => c + f k)) = c + (Finset.inf S f) := by
          intros S f c; induction S using Finset.induction <;> simp_all +decide [ add_comm, add_left_comm, add_assoc ] ;
        intros i j
        have h_eq : (Finset.univ.inf (fun k => (Finset.univ.inf (fun l => A i l + B l k) + C k j))) = (Finset.univ.inf (fun l => A i l + (Finset.univ.inf (fun k => B l k + C k j)))) := by
          have h_inf_add_right : Finset.univ.inf (fun k => (Finset.univ.inf (fun l => A i l + B l k) + C k j)) = Finset.univ.inf (fun k => Finset.univ.inf (fun l => A i l + (B l k + C k j))) := by
            simp +decide only [← add_assoc];
            grind
          rw [ h_inf_add_right, Finset.inf_comm ];
          exact Finset.inf_congr rfl fun _ _ => by aesop;
        exact h_eq;
      exact funext fun i => funext fun j => h_eq i j

/-! ## Walk Composition -/

/-
**Walk Composition Theorem (Tropical)**: A^⊗(k+l) = A^⊗k ⊗ A^⊗l.
    Proof by induction on l using associativity.
-/
theorem minPlusPow_add (A : Fin n → Fin n → WithTop ℕ) (k l : ℕ) :
    minPlusPow A (k + l) = minPlusMul (minPlusPow A k) (minPlusPow A l) := by
      induction' l with l ih;
      · convert minPlusMul_id_right ( minPlusPow A k ) |> Eq.symm using 1;
      · convert minPlusMul_assoc ( minPlusPow A k ) ( minPlusPow A l ) A using 1;
        exact ih ▸ rfl

/-! ## Moment Properties -/

/-
The 0-th tropical moment is 0 (trace of identity).
-/
theorem tropMoment_zero (G : WDGraph n) [NeZero n] :
    G.tropMoment 0 = 0 := by
      unfold WDGraph.tropMoment;
      unfold tropTrace minPlusPow minPlusId;
      simp +decide [ Finset.inf_const ]

/-
The 1st tropical moment is ⊤ (no self-loops exist).
-/
theorem tropMoment_one (G : WDGraph n) :
    G.tropMoment 1 = ⊤ := by
      unfold WDGraph.tropMoment;
      unfold tropTrace minPlusPow;
      unfold minPlusMul minPlusPow;
      simp +decide [ minPlusId ];
      exact fun i j => Classical.or_iff_not_imp_left.2 fun h => by have := G.no_selfloop j; aesop;

/-! ## DAG Vanishing -/

/-
**DAG Tropical Moment Vanishing**: In a DAG, all tropical moments of
    positive order are ⊤. A closed walk of positive length would create a cycle,
    but the topological ordering forbids this.
-/
theorem dag_tropMoment_pos (G : WDGraph n) (hdag : G.IsDAG) (k : ℕ) (hk : 0 < k) :
    G.tropMoment k = ⊤ := by
      revert hk;
      -- Show that in a DAG with ordering f, every entry of A^⊗k is ⊤ when it would require a walk that decreases f by at least k.
      have h_walk_decreasing (k : ℕ) (f : Fin n → ℕ) (hf : ∀ i j, G.hasEdge i j → f j < f i) : ∀ i j, (minPlusPow G.weight k) i j ≠ ⊤ → f j + k ≤ f i := by
        induction' k with k ih;
        · simp +decide [ minPlusPow, minPlusId ];
        · intro i j hij; rw [ show minPlusPow G.weight ( k + 1 ) = minPlusMul ( minPlusPow G.weight k ) G.weight from rfl ] at hij; simp_all +decide [ minPlusMul ] ;
          obtain ⟨ x, hx₁, hx₂ ⟩ := hij; linarith [ ih i x hx₁, hf x j ( by unfold WDGraph.hasEdge; aesop ) ] ;
      obtain ⟨ f, hf ⟩ := hdag;
      intro hk_pos
      have h_diag : ∀ i, (minPlusPow G.weight k) i i = ⊤ := by
        exact fun i => Classical.not_not.1 fun hi => by linarith [ h_walk_decreasing k f hf i i hi ] ;
      rcases n with ( _ | _ | n ) <;> simp_all +decide [WDGraph.tropMoment,WDGraph.tropTrace]

/-! ## Lower Bound -/

/-
**Min-plus power entry lower bound**: If every finite edge weight is ≥ w,
    then every finite entry of A^⊗k is ≥ k * w.
-/
theorem minPlusPow_lower_bound (G : WDGraph n) (k : ℕ)
    (w : ℕ) (hw : ∀ i j : Fin n, G.weight i j ≠ ⊤ → w ≤ G.weight i j) (i j : Fin n)
    (hfin : minPlusPow G.weight k i j ≠ ⊤) :
    (k * w : WithTop ℕ) ≤ minPlusPow G.weight k i j := by
      -- We proceed by induction on $k$.
      induction' k with k ih generalizing i j;
      · simp +decide [ minPlusPow ];
      · simp_all +decide [ minPlusPow, minPlusMul ];
        intro b; by_cases hb : minPlusPow G.weight k i b = ⊤ <;> by_cases hb' : G.weight b j = ⊤ <;> simp_all +decide [ add_mul ] ;
        exact add_le_add ( ih i b hb ) ( hw b j hb' )

/-! ## Monotonicity -/

/-
Min-plus multiplication is monotone entrywise.
-/
theorem minPlusMul_mono
    (A A' B B' : Fin n → Fin n → WithTop ℕ)
    (hA : ∀ i j, A' i j ≤ A i j)
    (hB : ∀ i j, B' i j ≤ B i j) :
    ∀ i j, minPlusMul A' B' i j ≤ minPlusMul A B i j := by
      intros i j
      simp [minPlusMul];
      exact fun k => le_trans ( Finset.inf_le ( Finset.mem_univ k ) ) ( add_le_add ( hA _ _ ) ( hB _ _ ) )

/-
Min-plus powers are monotone in the base matrix.
-/
theorem minPlusPow_mono
    (A A' : Fin n → Fin n → WithTop ℕ)
    (hle : ∀ i j, A' i j ≤ A i j) (k : ℕ) :
    ∀ i j, minPlusPow A' k i j ≤ minPlusPow A k i j := by
      induction' k with k ih generalizing A A' <;> simp_all +decide [ minPlusPow ];
      exact fun i j => minPlusMul_mono _ _ _ _ ( ih _ _ hle ) hle i j

/-
**Tropical Moment Monotonicity**: Decreasing weights decreases moments.
-/
theorem tropMoment_antitone_weight (G G' : WDGraph n)
    (hle : ∀ i j, G'.weight i j ≤ G.weight i j) (k : ℕ) :
    G'.tropMoment k ≤ G.tropMoment k := by
      convert minPlusPow_mono _ _ hle _;
      swap;
      exact 0;
      simp +decide [ WDGraph.tropMoment, WDGraph.tropTrace, minPlusPow ];
      exact fun i => le_trans ( Finset.inf_le ( Finset.mem_univ i ) ) ( minPlusPow_mono _ _ hle _ _ _ )

/-! ## Dense Graph Cycle Detection -/

/-
**Dense Graph Short Cycle**: If every vertex has out-degree ≥ n-1
    and n ≥ 2, then the 2nd tropical moment is finite —
    the graph is complete so every pair (i,j) has both edges.
-/
theorem dense_graph_has_short_cycle (G : WDGraph n) [NeZero n]
    (hdense : ∀ i : Fin n, n - 1 ≤ G.outDeg i) (hn2 : 2 ≤ n) :
    G.tropMoment 2 ≠ ⊤ := by
      -- Since every vertex has out-degree n-1, for any two distinct vertices i and j, there must be an edge from i to j and from j to i.
      have h_edge : ∀ i j : Fin n, i ≠ j → G.weight i j ≠ ⊤ ∧ G.weight j i ≠ ⊤ := by
        intro i j hij
        have h_out_deg_i : Finset.card (Finset.filter (fun k => G.weight i k ≠ ⊤) Finset.univ) = n - 1 := by
          refine' le_antisymm _ _;
          · exact Nat.le_sub_one_of_lt ( lt_of_lt_of_le ( Finset.card_lt_card ( Finset.filter_ssubset.mpr ⟨ i, by simp +decide [ G.no_selfloop ] ⟩ ) ) ( by simpa ) );
          · exact hdense i
        have h_out_deg_j : Finset.card (Finset.filter (fun k => G.weight j k ≠ ⊤) Finset.univ) = n - 1 := by
          have h_out_deg_j : Finset.card (Finset.filter (fun k => G.weight j k ≠ ⊤) Finset.univ) ≤ n - 1 := by
            exact Nat.le_sub_one_of_lt ( lt_of_lt_of_le ( Finset.card_lt_card ( Finset.filter_ssubset.mpr ⟨ j, by simp +decide [ G.no_selfloop ] ⟩ ) ) ( by simpa ) );
          exact le_antisymm h_out_deg_j ( hdense j );
        have h_out_deg_i : Finset.filter (fun k => G.weight i k ≠ ⊤) Finset.univ = Finset.univ \ {i} := by
          refine' Finset.eq_of_subset_of_card_le ( fun x hx => _ ) _ <;> simp_all +decide [ Finset.card_sdiff ];
          exact fun h => hx <| h.symm ▸ G.no_selfloop i
        have h_out_deg_j : Finset.filter (fun k => G.weight j k ≠ ⊤) Finset.univ = Finset.univ \ {j} := by
          refine' Finset.eq_of_subset_of_card_le ( fun k hk => _ ) _ <;> simp_all +decide [ Finset.card_sdiff ];
          exact fun h => by have := G.no_selfloop j; aesop;
        simp_all +decide [ Finset.ext_iff, Set.ext_iff ];
        tauto;
      -- Since every vertex has out-degree n-1, for any two distinct vertices i and j, there must be an edge from i to j and from j to i. Therefore, the second tropical moment is finite.
      have h_second_moment_finite : ∃ i j : Fin n, i ≠ j ∧ minPlusPow G.weight 2 i i ≠ ⊤ := by
        refine' ⟨ ⟨ 0, by linarith ⟩, ⟨ 1, by linarith ⟩, _, _ ⟩ <;> simp_all +decide [ minPlusPow ];
        simp +decide [ minPlusMul, minPlusId ];
        exact ⟨ 1, h_edge _ _ ( by aesop ) ⟩;
      obtain ⟨ i, j, hij, h ⟩ := h_second_moment_finite; exact ne_top_of_le_ne_top h ( Finset.inf_le ( Finset.mem_univ i ) ) ;

end WDGraph
end