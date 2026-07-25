import Mathlib

/-! # Edge-probability thresholds for graphs without isolated vertices

For a finite simple graph with `m` edges and `n` non-isolated vertices, this
file establishes the basic constraints on the ratio `n.choose 2 / m` appearing
in the proposed probability threshold.  The results form a chain: the closed
formula for `n.choose 2` gives positivity, the universal simple-graph edge
bound gives the lower endpoint `1`, and the handshake lemma gives the upper
endpoint `n - 1` when every vertex is non-isolated.
-/

open Finset SimpleGraph

namespace EdgeProbabilityThreshold

/-- The real-valued ratio between the number of possible pairs and the number
of actual edges. -/
noncomputable def threshold (n m : ℕ) : ℝ := (n.choose 2 : ℝ) / m

/-
The usual closed form for the number of unordered pairs, stated over the
reals to avoid truncated natural-number division.
-/
theorem two_mul_choose_two_cast (n : ℕ) :
    2 * (n.choose 2 : ℝ) = n * (n - 1 : ℕ) := by
  cases n <;> norm_cast;
  induction ‹_› <;> simp_all +decide [ Nat.choose_succ_succ, mul_add, add_mul ] ; linarith

/-
The pair count is positive as soon as there are at least two vertices.
-/
theorem choose_two_cast_pos {n : ℕ} (hn : 2 ≤ n) :
    0 < (n.choose 2 : ℝ) := by
  have hn0 : (0 : ℝ) < n := by
    exact_mod_cast (lt_of_lt_of_le (by omega : 0 < 2) hn)
  have hn1 : (0 : ℝ) < (n - 1 : ℕ) := by
    exact_mod_cast (by omega : 0 < n - 1)
  nlinarith [two_mul_choose_two_cast n]

/-
Any positive denominator bounded by the number of available pairs gives a
threshold at least one.
-/
theorem one_le_threshold {n m : ℕ} (hm : 0 < m) (hedges : m ≤ n.choose 2) :
    (1 : ℝ) ≤ threshold n m := by
  exact one_le_div ( by positivity ) |>.2 ( mod_cast hedges )

/-
A probability strictly below the threshold satisfies the equivalent
cross-multiplied edge-budget inequality.
-/
theorem mul_lt_choose_of_lt_threshold {n m : ℕ} {p : ℝ}
    (hm : 0 < m) (hp : p < threshold n m) :
    p * m < (n.choose 2 : ℝ) := by
  rw [ threshold ] at hp ; rw [ lt_div_iff₀ ] at hp <;> norm_cast at *

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-
If every vertex is non-isolated, the handshake identity forces `n ≤ 2m`.
-/
omit [DecidableEq V] in
theorem card_le_twice_edges_of_no_isolated
    (hni : ∀ v : V, 0 < G.degree v) :
    Fintype.card V ≤ 2 * G.edgeFinset.card := by
  -- Since each vertex has a degree of at least 1, the sum of the degrees is at least the number of vertices.
  have h_sum_deg : ∑ v : V, G.degree v ≥ Fintype.card V := by
    exact le_trans ( by norm_num ) ( Finset.sum_le_sum fun v _ => Nat.succ_le_of_lt ( hni v ) );
  linarith [ SimpleGraph.sum_degrees_eq_twice_card_edges G ]

/-
For a nonempty simple graph, its number of edges is at most the number of
unordered vertex pairs; consequently its threshold is at least one.
-/
omit [DecidableEq V] in
theorem graph_one_le_threshold (hm : 0 < G.edgeFinset.card) :
    (1 : ℝ) ≤ threshold (Fintype.card V) G.edgeFinset.card := by
  convert one_le_threshold ?_ ?_;
  · grind;
  · convert G.card_edgeFinset_le_card_choose_two

/-
If all vertices are non-isolated, the threshold is at most `n - 1`.
Together with `graph_one_le_threshold`, this locates it in the sharp elementary
interval `[1,n-1]`.
-/
omit [DecidableEq V] in
theorem graph_threshold_le_card_sub_one
    (hni : ∀ v : V, 0 < G.degree v) :
    threshold (Fintype.card V) G.edgeFinset.card ≤
      (Fintype.card V - 1 : ℕ) := by
  -- By the handshake lemma, we have $n \leq 2m$.
  have h_handshake : (Fintype.card V : ℝ) ≤ 2 * (G.edgeFinset.card : ℝ) := by
    exact_mod_cast card_le_twice_edges_of_no_isolated G hni;
  convert div_le_of_le_mul₀ _ _ _ <;> norm_cast at *;
  · infer_instance;
  · exact Nat.zero_le _;
  · positivity;
  · simp_all +decide [ Nat.choose_two_right ];
    exact Nat.div_le_of_le_mul <| by nlinarith;

/-
The complete threshold interval for a graph with no isolated vertices.
-/
omit [DecidableEq V] in
theorem graph_threshold_mem_Icc [Nonempty V]
    (hni : ∀ v : V, 0 < G.degree v) :
    threshold (Fintype.card V) G.edgeFinset.card ∈
      Set.Icc (1 : ℝ) (Fintype.card V - 1 : ℕ) := by
  refine' ⟨ _, _ ⟩;
  · refine' graph_one_le_threshold _ _;
    contrapose! hni; simp_all +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset_def ] ;
  · convert graph_threshold_le_card_sub_one G hni

/-
The proposed strict threshold is automatic for every probability `p < 1`:
the lower endpoint of the interval is already one.  This is the central
contrarian consequence of the elementary edge-count bound.
-/
omit [DecidableEq V] in
theorem probability_lt_threshold_of_lt_one [Nonempty V]
    (hni : ∀ v : V, 0 < G.degree v) {p : ℝ} (hp : p < 1) :
    p < threshold (Fintype.card V) G.edgeFinset.card := by
  refine' lt_of_lt_of_le hp _;
  by_cases h : 0 < G.edgeFinset.card <;> simp_all +decide [ threshold ];
  · convert EdgeProbabilityThreshold.graph_one_le_threshold G _;
    exact Finset.card_pos.mpr ( by contrapose! h; aesop );
  · simp_all +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset ]

/-
Thus any `p` below the proposed ratio lies below `n - 1` and
obeys the cross-multiplied edge-budget inequality.
-/
omit [DecidableEq V] in
theorem probability_consequences [Nonempty V]
    (hni : ∀ v : V, 0 < G.degree v) {p : ℝ}
    (hp : p < threshold (Fintype.card V) G.edgeFinset.card) :
    p < (Fintype.card V - 1 : ℕ) ∧
      p * G.edgeFinset.card < (Fintype.card V).choose 2 := by
  refine' ⟨ hp.trans_le _, mul_lt_choose_of_lt_threshold _ hp ⟩;
  · convert graph_threshold_le_card_sub_one G hni;
  · contrapose! hp;
    simp_all +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset_def ]

end EdgeProbabilityThreshold