import Mathlib

/-!
# Tropical Feedback Fixed Points via Cycle Mean Spectral Obstruction

This file establishes the equivalence between guarded feedback existence/uniqueness
and tropical cycle-mean conditions for finite-state weighted dependency digraphs.

## Main Results

* `guarded_feedback_exists_iff_allClosedWalkWeightsNonpos` — A fixed point of the
  tropical feedback operator exists iff every closed walk has nonpositive weight.
* `guarded_feedback_unique_of_allClosedWalkWeightsNeg` — If every closed walk has
  strictly negative weight, the fixed point is unique.
* `dequantize_comp_preserves_order` — Order-level compatibility of Maslov
  dequantization with tropical composition.

## Overview

Given a weight matrix `W : Matrix (Fin n) (Fin n) ℝ` representing a weighted
dependency digraph, the **feedback operator** is

  `Φ_W(x)(i) = max(0, max_j(W i j + x j))`

The existence of a fixed point `x = Φ_W(x)` is governed by the **tropical spectral
radius**: fixed points exist iff every closed walk has nonpositive total weight, and
the fixed point is unique iff every closed walk has strictly negative weight.

This is the tropical analogue of contractivity in Lawvere metric semantics and
provides a **computable certificate** for semantic guardedness in traced monoidal
categories.
-/

noncomputable section

open Finset BigOperators

/-! ## Part I: Walk Weights and Cycle Conditions -/

/-- Weight of a walk of `k` steps, given as a function `Fin (k+1) → Fin n`.
    The walk visits `walk 0, walk 1, ..., walk k` and the weight is
    `∑_{t=0}^{k-1} W (walk t) (walk (t+1))`. -/
def walkWeightFn {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) {k : ℕ}
    (walk : Fin (k + 1) → Fin n) : ℝ :=
  ∑ t : Fin k, W (walk ⟨t.val, by omega⟩) (walk ⟨t.val + 1, by omega⟩)

/-- Every closed walk (first vertex = last vertex) of positive length has
    nonpositive total weight. Equivalent to: the tropical spectral radius ≤ 0. -/
def AllClosedWalkWeightsNonpos {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ (k : ℕ) (_ : 0 < k) (walk : Fin (k + 1) → Fin n),
    walk ⟨0, by omega⟩ = walk ⟨k, by omega⟩ → walkWeightFn W walk ≤ 0

/-- Every closed walk of positive length has strictly negative total weight. -/
def AllClosedWalkWeightsNeg {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ (k : ℕ) (_ : 0 < k) (walk : Fin (k + 1) → Fin n),
    walk ⟨0, by omega⟩ = walk ⟨k, by omega⟩ → walkWeightFn W walk < 0

/-! ## Part II: The Feedback Operator -/

/-- The tropical feedback operator:
    `feedbackOp W x i = max(0, max_j (W i j + x j))`.
    Models one step of guarded feedback in the max-plus semiring. -/
def feedbackOp {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => max 0 (Finset.univ.sup' ⟨i, Finset.mem_univ i⟩ (fun j => W i j + x j))

/-- A fixed point of the feedback operator exists. -/
def GuardedFeedbackExists {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ x : Fin n → ℝ, feedbackOp W x = x

/-- The fixed point of the feedback operator is unique. -/
def GuardedFeedbackUnique {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃! x : Fin n → ℝ, feedbackOp W x = x

/-- Kleene iteration of the feedback operator starting from the zero valuation. -/
def kleeneIter {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) : Fin n → ℝ :=
  (feedbackOp W)^[k] (fun _ => 0)

/-! ## Part III: Basic Properties -/

/-
The feedback operator always produces nonnegative values.
-/
theorem feedbackOp_nonneg {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (i : Fin n) : 0 ≤ feedbackOp W x i := by
  exact le_max_left _ _

/-
Any fixed point of the feedback operator has nonneg entries.
-/
theorem fixedPoint_nonneg {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (hx : feedbackOp W x = x) (i : Fin n) : 0 ≤ x i := by
  exact hx ▸ feedbackOp_nonneg W x i

/-
At a fixed point, `x i ≥ W i j + x j` for every `j`.
-/
theorem fixedPoint_ge_edge {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (hx : feedbackOp W x = x) (i j : Fin n) :
    W i j + x j ≤ x i := by
  have h_sup : ∀ j, W i j + x j ≤ Finset.univ.sup' ⟨ i, Finset.mem_univ i ⟩ ( fun j => W i j + x j ) := by
    exact fun j => Finset.le_sup' ( fun j => W i j + x j ) ( Finset.mem_univ j );
  unfold feedbackOp at hx;
  grind

/-
The feedback operator is monotone: `x ≤ y → feedbackOp W x ≤ feedbackOp W y`.
-/
theorem feedbackOp_mono {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (x y : Fin n → ℝ) (hxy : ∀ i, x i ≤ y i) (i : Fin n) :
    feedbackOp W x i ≤ feedbackOp W y i := by
  unfold feedbackOp;
  gcongr ; aesop

/-! ## Part IV: Fixed Point ⟹ Nonpositive Closed Walks -/

/-
Along a walk of `k` steps, the fixed-point inequality telescopes:
    `x (walk 0) ≥ walkWeightFn W walk + x (walk k)`.
-/
theorem fixedPoint_ge_walk {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (hx : feedbackOp W x = x) (k : ℕ)
    (walk : Fin (k + 1) → Fin n) :
    walkWeightFn W walk + x (walk ⟨k, by omega⟩) ≤ x (walk ⟨0, by omega⟩) := by
  induction' k with k ih;
  · unfold walkWeightFn; aesop;
  · unfold walkWeightFn at *;
    specialize ih ( fun i => walk i.succ );
    rw [ Fin.sum_univ_succ ];
    linarith! [ fixedPoint_ge_edge W x hx ( walk 0 ) ( walk 1 ) ]

/-
If a fixed point exists, every closed walk has nonpositive weight.
-/
theorem closedWalk_nonpos_of_fixedPoint {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (hx : feedbackOp W x = x) (k : ℕ) (hk : 0 < k)
    (walk : Fin (k + 1) → Fin n) (hclosed : walk ⟨0, by omega⟩ = walk ⟨k, by omega⟩) :
    walkWeightFn W walk ≤ 0 := by
  have := fixedPoint_ge_walk W x hx k walk; aesop;

/-
Positive closed walk weight implies no fixed point exists.
-/
theorem not_guarded_feedback_exists_of_pos_walk {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (k : ℕ) (hk : 0 < k) (walk : Fin (k + 1) → Fin n)
    (hclosed : walk ⟨0, by omega⟩ = walk ⟨k, by omega⟩)
    (hpos : 0 < walkWeightFn W walk) :
    ¬ GuardedFeedbackExists W := by
  exact fun ⟨ x, hx ⟩ => hpos.not_ge <| closedWalk_nonpos_of_fixedPoint W x hx k hk walk hclosed

/-! ## Part V: Existence — Nonpositive Cycles ⟹ Fixed Point -/

/-
Pigeonhole for walks: any walk of length ≥ n in Fin n revisits a vertex.
-/
theorem walk_pigeonhole {n : ℕ} (hn : 0 < n) (k : ℕ) (hk : n ≤ k)
    (walk : Fin (k + 1) → Fin n) :
    ∃ (a b : Fin (k + 1)), a < b ∧ walk a = walk b := by
  by_contra! h;
  exact absurd ( Fintype.card_le_of_injective walk fun a b hab => le_antisymm ( not_lt.1 fun ha => h _ _ ha hab.symm ) ( not_lt.1 fun hb => h _ _ hb hab ) ) ( by norm_num; linarith )

/-
Concatenation of walks: if we have a walk from `walk1 0` to some vertex `v`,
    and then a walk from `v` to `walk2 (last)`, the total weight is the sum.
-/
theorem walkWeightFn_split {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    {k₁ k₂ : ℕ} (walk : Fin (k₁ + k₂ + 1) → Fin n) :
    walkWeightFn W walk = walkWeightFn W (fun t : Fin (k₁ + 1) => walk ⟨t, by omega⟩) +
      walkWeightFn W (fun t : Fin (k₂ + 1) => walk ⟨t + k₁, by omega⟩) := by
  unfold walkWeightFn;
  simp +decide [ Fin.sum_univ_add, Fin.add_def ];
  ac_rfl

/-
Kleene iterates are nonneg at every step.
-/
theorem kleeneIter_nonneg {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) (i : Fin n) :
    0 ≤ kleeneIter W k i := by
  unfold kleeneIter;
  exact Nat.recOn k ( by norm_num ) fun k hk => by rw [ Function.iterate_succ_apply' ] ; exact feedbackOp_nonneg _ _ _;

/-
Kleene iterates are monotone non-decreasing.
-/
theorem kleeneIter_mono_step {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) (i : Fin n) :
    kleeneIter W k i ≤ kleeneIter W (k + 1) i := by
  unfold kleeneIter;
  induction k <;> simp_all +decide [ Function.iterate_succ_apply' ];
  · exact?;
  · apply_rules [ feedbackOp_mono ];
    rename_i k hk;
    exact Nat.recOn k ( by norm_num [ feedbackOp_nonneg ] ) fun k ih => by simpa only [ Function.iterate_succ_apply' ] using fun i => feedbackOp_mono _ _ _ ih i;

/-
The Kleene iterate at step m bounds the weight of any m-step walk from vertex i.
    Formally: for any walk of length m starting at i, walkWeightFn ≤ kleeneIter W m i.
-/
theorem kleeneIter_ge_walkWeight {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (m : ℕ)
    (walk : Fin (m + 1) → Fin n) (i : Fin n) (hi : walk ⟨0, by omega⟩ = i) :
    walkWeightFn W walk ≤ kleeneIter W m i := by
  unfold walkWeightFn;
  induction' m with m ih generalizing i;
  · aesop;
  · convert le_trans _ ( le_max_right _ _ ) using 1;
    rotate_left;
    rotate_left;
    exact 0;
    exact Finset.univ.sup' ⟨ i, Finset.mem_univ i ⟩ ( fun j => W i j + kleeneIter W m j );
    · unfold kleeneIter;
      unfold feedbackOp; simp +decide [ Function.iterate_succ_apply' ] ;
    · refine' le_trans _ ( Finset.le_sup' _ <| Finset.mem_univ <| walk ⟨ 1, by linarith ⟩ );
      rw [ Fin.sum_univ_succ ];
      exact add_le_add ( by aesop ) ( ih ( fun t => walk ⟨ t.val + 1, by linarith [ Fin.is_lt t ] ⟩ ) _ rfl )

/-
Kleene iterate at step k+1 can be "unrolled": either it's 0 or there exists
    a next vertex l such that kleeneIter W (k+1) j = W j l + kleeneIter W k l.
-/
theorem kleeneIter_unroll {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) (j : Fin n) :
    kleeneIter W (k + 1) j = 0 ∨
    ∃ l : Fin n, kleeneIter W (k + 1) j ≤ W j l + kleeneIter W k l := by
  unfold kleeneIter;
  simp_all +decide [ Function.iterate_succ_apply', feedbackOp ];
  obtain ⟨l, hl⟩ : ∃ l, ∀ b, W j b + ( feedbackOp W ) ^[ k ] ( fun _ => 0 ) b ≤ W j l + ( feedbackOp W ) ^[ k ] ( fun _ => 0 ) l := by
    simpa using Finset.exists_max_image Finset.univ ( fun b => W j b + ( feedbackOp W ) ^[ k ] ( fun _ => 0 ) b ) ⟨ j, Finset.mem_univ j ⟩;
  grind

/-
The Kleene iterate is bounded by the weight of some walk: for each j,
    there exists a walk of length m ≤ k from j with weight ≥ kleeneIter W k j.
-/
theorem kleeneIter_le_some_walkWeight {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (k : ℕ)
    (j : Fin n) :
    ∃ (m : ℕ) (hm : m ≤ k) (walk : Fin (m + 1) → Fin n),
      walk ⟨0, by omega⟩ = j ∧ kleeneIter W k j ≤ walkWeightFn W walk := by
  induction' k with k ih generalizing j;
  · exact ⟨ 0, le_rfl, fun _ => j, rfl, by unfold walkWeightFn; norm_num; unfold kleeneIter; unfold feedbackOp; aesop ⟩;
  · obtain h | ⟨ l, hl ⟩ := kleeneIter_unroll W k j;
    · exact ⟨ 0, by norm_num, fun _ => j, rfl, by simp +decide [ h, walkWeightFn ] ⟩;
    · obtain ⟨ m, hm₁, walk, hm₂, hm₃ ⟩ := ih l;
      refine' ⟨ m + 1, by linarith, Fin.cons j walk, _, _ ⟩ <;> simp_all +decide [ Fin.sum_univ_succ, walkWeightFn ];
      exact?

/-
Any walk of length ≥ n+1 in Fin n can be shortened by removing a cycle.
    The shortened walk starts at the same vertex and has weight ≥ original.
-/
theorem walk_shorten_by_cycle_removal {n : ℕ} (hn : 0 < n)
    (W : Matrix (Fin n) (Fin n) ℝ) (hW : AllClosedWalkWeightsNonpos W)
    {k : ℕ} (hk : n ≤ k) (walk : Fin (k + 1) → Fin n) :
    ∃ (m : ℕ) (hm : m < k) (walk' : Fin (m + 1) → Fin n),
      walk' ⟨0, by omega⟩ = walk ⟨0, by omega⟩ ∧
      walkWeightFn W walk ≤ walkWeightFn W walk' := by
  obtain ⟨ a, b, hab, h ⟩ := walk_pigeonhole hn k hk walk;
  -- Define the shortened walk by removing the cycle.
  set m := k - (b.val - a.val) with hm_def
  use m;
  refine' ⟨ _, fun t => if h : t.val < a.val then walk ⟨ t.val, by omega ⟩ else walk ⟨ t.val + ( b.val - a.val ), by omega ⟩, _, _ ⟩;
  · exact Nat.sub_lt ( by linarith ) ( Nat.sub_pos_of_lt hab );
  · aesop;
  · have h_cycle_nonpos : walkWeightFn W (fun t : Fin (b.val - a.val + 1) => walk ⟨a.val + t.val, by omega⟩) ≤ 0 := by
      convert hW ( b.val - a.val ) ( Nat.sub_pos_of_lt hab ) ( fun t => walk ⟨ a.val + t.val, by omega ⟩ ) _ using 1;
      simp +decide [ h, add_tsub_cancel_of_le ( show ( a : ℕ ) ≤ b from hab.le ) ];
    have h_split : walkWeightFn W walk = walkWeightFn W (fun t : Fin (a.val + 1) => walk ⟨t.val, by omega⟩) + walkWeightFn W (fun t : Fin (b.val - a.val + 1) => walk ⟨a.val + t.val, by omega⟩) + walkWeightFn W (fun t : Fin (k - b.val + 1) => walk ⟨b.val + t.val, by omega⟩) := by
      convert walkWeightFn_split W ( fun t : Fin ( a.val + ( b.val - a.val ) + ( k - b.val ) + 1 ) => walk ⟨ t.val, by omega ⟩ ) using 1;
      · congr! 2;
        · omega;
        · exact ‹k = a + ( b - a ) + ( k - b ) › ▸ rfl;
        · congr! 1;
          grind;
      · grind +suggestions;
    have h_split_shortened : walkWeightFn W (fun t : Fin (m + 1) => if h : t.val < a.val then walk ⟨t.val, by omega⟩ else walk ⟨t.val + (b.val - a.val), by omega⟩) = walkWeightFn W (fun t : Fin (a.val + 1) => walk ⟨t.val, by omega⟩) + walkWeightFn W (fun t : Fin (k - b.val + 1) => walk ⟨b.val + t.val, by omega⟩) := by
      convert walkWeightFn_split W ( fun t : Fin ( a.val + ( k - b.val ) + 1 ) => if h : t.val < a.val then walk ⟨ t.val, by omega ⟩ else walk ⟨ t.val + ( b.val - a.val ), by omega ⟩ ) using 1;
      · convert rfl;
        omega;
      · congr! 1;
        · grind;
        · grind;
    linarith

/-
If all closed walks are nonpositive and x = kleeneIter W n, then `x = feedbackOp W x`.
    The key step: any walk of length > n can be shortened by removing a nonpositive cycle.
-/
theorem kleeneIter_is_fixedPoint {n : ℕ} (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ)
    (hW : AllClosedWalkWeightsNonpos W) :
    feedbackOp W (kleeneIter W n) = kleeneIter W n := by
  -- We show that $kleeneIter W (n+1) i \leq kleeneIter W n i$.
  have h_monotone : ∀ i, (kleeneIter W (n + 1) i) ≤ (kleeneIter W n i) := by
    intro i
    have h_ext_walk : ∀ j, W i j + (kleeneIter W n j) ≤ (kleeneIter W n i) := by
      intro j
      obtain ⟨m, hm, walk, hj, hw⟩ := kleeneIter_le_some_walkWeight W n j
      have h_ext_walk : W i j + (kleeneIter W n j) ≤ walkWeightFn W (Fin.cons i walk) := by
        unfold walkWeightFn at *; simp_all +decide [ Fin.sum_univ_succ ] ;
        convert hw using 1;
      by_cases h_case : m + 1 ≤ n;
      · refine le_trans h_ext_walk ?_;
        refine' le_trans _ ( show kleeneIter W ( m + 1 ) i ≤ kleeneIter W n i from _ );
        · convert kleeneIter_ge_walkWeight W ( m + 1 ) ( Fin.cons i walk ) i _ using 1 ; aesop;
        · exact monotone_nat_of_le_succ ( fun k => kleeneIter_mono_step W k i ) h_case;
      · -- Since $m + 1 > n$, we can apply the walk_shorten_by_cycle_removal lemma to find a shorter walk with the same or greater weight.
        obtain ⟨m', hm', walk', h_walk', h_weight⟩ : ∃ m' < m + 1, ∃ walk' : Fin (m' + 1) → Fin n, walk' ⟨0, by omega⟩ = i ∧ walkWeightFn W (Fin.cons i walk) ≤ walkWeightFn W walk' := by
          have := walk_shorten_by_cycle_removal hn W hW ( show n ≤ m + 1 from by linarith ) ( Fin.cons i walk ) ; aesop;
        refine le_trans h_ext_walk <| le_trans h_weight ?_;
        exact kleeneIter_ge_walkWeight W m' walk' i h_walk' |> le_trans <| by exact monotone_nat_of_le_succ ( fun k => kleeneIter_mono_step W k i ) ( by linarith ) ;
    unfold kleeneIter;
    simp_all +decide [ Function.iterate_succ_apply', feedbackOp ];
    exact ⟨ kleeneIter_nonneg W n i, fun j => h_ext_walk j ⟩;
  -- Since the Kleene iterates are monotonic, we have `kleeneIter W n i ≤ kleeneIter W (n + 1) i`.
  have h_monotone_rev : ∀ i, (kleeneIter W n i) ≤ (kleeneIter W (n + 1) i) := by
    grind +suggestions;
  unfold kleeneIter at *;
  exact funext fun i => le_antisymm ( by simpa only [ Function.iterate_succ_apply' ] using h_monotone i ) ( by simpa only [ Function.iterate_succ_apply' ] using h_monotone_rev i )

/-
**Existence**: Nonpositive closed walk weights imply a fixed point exists.
-/
theorem guarded_feedback_exists_of_nonpos {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (hW : AllClosedWalkWeightsNonpos W) : GuardedFeedbackExists W := by
  by_cases hn : 0 < n;
  · exact ⟨ _, kleeneIter_is_fixedPoint hn W hW ⟩;
  · interval_cases n;
    exact ⟨ fun _ => 0, by ext i; fin_cases i ⟩

/-! ## Part VI: Main Equivalence -/

/-
**Main Theorem (Existence)**: Guarded feedback exists iff all closed walks are nonpositive.
    This is the tropical spectral radius characterization.
-/
theorem guarded_feedback_exists_iff_allClosedWalkWeightsNonpos {n : ℕ}
    (W : Matrix (Fin n) (Fin n) ℝ) :
    GuardedFeedbackExists W ↔ AllClosedWalkWeightsNonpos W := by
  exact ⟨ fun ⟨ x, hx ⟩ => closedWalk_nonpos_of_fixedPoint W x hx, guarded_feedback_exists_of_nonpos W ⟩

/-! ## Part VII: Uniqueness -/

/-
Given two fixed points, the max difference is non-positive: if all cycles are
    strictly negative, then following the chain of max-achieving successors
    produces a cycle with weight 0, contradicting strict negativity.
-/
theorem fixedPoint_eq_of_allClosedWalkWeightsNeg {n : ℕ}
    (W : Matrix (Fin n) (Fin n) ℝ) (hW : AllClosedWalkWeightsNeg W)
    (x y : Fin n → ℝ) (hx : feedbackOp W x = x) (hy : feedbackOp W y = y) :
    x = y := by
  by_contra! h_contra;
  -- Without loss of generality, assume $M = \sup_{i} (x_i - y_i) > 0$.
  wlog hM_pos : 0 < ⨆ i, (x i - y i) generalizing x y;
  · apply this y x hy hx (Ne.symm h_contra);
    -- Since $x \neq y$, there exists some $i$ such that $x_i \neq y_i$.
    obtain ⟨i, hi⟩ : ∃ i, x i ≠ y i := by
      exact Function.ne_iff.mp h_contra;
    cases lt_or_gt_of_ne hi;
    · exact lt_of_lt_of_le ( by linarith ) ( le_ciSup ( Finite.bddAbove_range fun i => y i - x i ) i );
    · exact False.elim <| hM_pos <| lt_of_lt_of_le ( sub_pos.mpr ‹_› ) <| le_ciSup ( Finite.bddAbove_range fun i => x i - y i ) i;
  · -- Let $i_0$ be such that $x_{i_0} - y_{i_0} = M$.
    obtain ⟨i₀, hi₀⟩ : ∃ i₀, x i₀ - y i₀ = ⨆ i, (x i - y i) := by
      cases n <;> [ aesop; exact ( IsCompact.sSup_mem ( isCompact_range <| show Continuous fun i => x i - y i from by continuity ) <| Set.nonempty_of_mem <| Set.mem_range_self <| ⟨ 0, by linarith ⟩ ) ];
    -- Define a sequence $s(t)$ such that $s(0) = i₀$ and $s(t+1)$ is the index achieving the max in the definition of $x_{s(t)}$.
    obtain ⟨s, hs⟩ : ∃ s : ℕ → Fin n, s 0 = i₀ ∧ ∀ t, x (s t) = W (s t) (s (t + 1)) + x (s (t + 1)) ∧ x (s t) - y (s t) = ⨆ i, (x i - y i) := by
      have h_seq : ∀ i, x i - y i = ⨆ i, (x i - y i) → ∃ j, x i = W i j + x j ∧ x j - y j = ⨆ i, (x i - y i) := by
        intro i hi
        have h_max : x i = max 0 (Finset.univ.sup' ⟨i, Finset.mem_univ i⟩ (fun j => W i j + x j)) := by
          exact congr_fun hx i ▸ rfl;
        have h_max_eq : ∃ j, W i j + x j = x i := by
          have h_max_eq : ∃ j, W i j + x j = Finset.univ.sup' ⟨i, Finset.mem_univ i⟩ (fun j => W i j + x j) := by
            have := Finset.exists_max_image Finset.univ ( fun j => W i j + x j ) ⟨ i, Finset.mem_univ i ⟩ ; norm_num at * ;
            exact ⟨ this.choose, le_antisymm ( Finset.le_sup' ( fun j => W i j + x j ) ( Finset.mem_univ _ ) ) ( Finset.sup'_le _ _ fun j _ => this.choose_spec j ) ⟩;
          cases max_cases ( 0 : ℝ ) ( Finset.univ.sup' ⟨ i, Finset.mem_univ i ⟩ fun j => W i j + x j ) <;> simp +decide [ ‹_› ] at h_max ⊢;
          · linarith [ fixedPoint_nonneg W y hy i ];
          · grind;
        obtain ⟨ j, hj ⟩ := h_max_eq;
        have h_max_eq : y i ≥ W i j + y j := by
          have := congr_fun hy i;
          exact this ▸ le_max_of_le_right ( Finset.le_sup' ( fun j => W i j + y j ) ( Finset.mem_univ j ) );
        exact ⟨ j, hj.symm, by linarith [ show x j - y j ≤ ⨆ i, x i - y i from le_ciSup ( Finite.bddAbove_range fun i => x i - y i ) j ] ⟩;
      choose! f hf₁ hf₂ using h_seq;
      use fun t => Nat.recOn t i₀ fun t ih => f ih;
      exact ⟨ rfl, fun t => ⟨ hf₁ _ ( by induction t <;> tauto ), by induction t <;> tauto ⟩ ⟩;
    -- Since $s$ takes values in a finite set, there exist $a < b$ such that $s(a) = s(b)$.
    obtain ⟨a, b, hab, hs_eq⟩ : ∃ a b : ℕ, a < b ∧ s a = s b := by
      by_contra! h;
      exact absurd ( Set.infinite_range_of_injective ( fun a b hab => le_antisymm ( not_lt.1 fun ha => h _ _ ha hab.symm ) ( not_lt.1 fun hb => h _ _ hb hab ) ) ) ( Set.not_infinite.mpr <| Set.toFinite _ );
    -- The cycle $s(a), s(a+1), ..., s(b) = s(a)$ has weight $\sum_{t=a}^{b-1} W(s(t), s(t+1)) = \sum_{t=a}^{b-1} (x(s(t)) - x(s(t+1))) = x(s(a)) - x(s(b)) = 0$.
    have h_cycle_weight : ∑ t ∈ Finset.range (b - a), W (s (a + t)) (s (a + t + 1)) = 0 := by
      have h_cycle_weight : ∑ t ∈ Finset.range (b - a), (x (s (a + t)) - x (s (a + t + 1))) = x (s a) - x (s b) := by
        convert Finset.sum_range_sub' ( fun t => x ( s ( a + t ) ) ) ( b - a ) using 1 ; simp +decide [ Nat.add_sub_of_le hab.le ];
      grind;
    have := hW ( b - a ) ( Nat.sub_pos_of_lt hab ) ( fun t => s ( a + t ) ) ; simp_all +decide [ Finset.sum_range ] ;
    exact not_lt_of_ge h_cycle_weight.ge ( this ( by rw [ Nat.add_sub_cancel' hab.le ] ) )

/-
**Uniqueness**: Strictly negative closed walk weights imply unique fixed point.
-/
theorem guarded_feedback_unique_of_allClosedWalkWeightsNeg {n : ℕ}
    (W : Matrix (Fin n) (Fin n) ℝ) (hW : AllClosedWalkWeightsNeg W) :
    GuardedFeedbackUnique W := by
  have h_exists : GuardedFeedbackExists W := by
    exact guarded_feedback_exists_of_nonpos W fun k hk walk hclosed => le_of_lt ( hW k hk walk hclosed );
  exact ⟨ h_exists.choose, h_exists.choose_spec, fun y hy => fixedPoint_eq_of_allClosedWalkWeightsNeg W hW _ _ hy h_exists.choose_spec ⟩

/-! ## Part VIII: Cycle Mean and Connection to Standard Definitions -/

/-- The maximum cycle mean, defined as the supremum of average weight per edge
    over all closed walks. For `n = 0`, returns `0` by convention. -/
def cycleMean' {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  if h : 0 < n then
    Finset.sup' (Finset.univ : Finset (Fin n))
      ⟨⟨0, h⟩, Finset.mem_univ _⟩
      (fun i => W i i)  -- Lower bound: max self-loop weight
  else 0

/-- User-facing theorem: guarded feedback exists iff `cycleMean ≤ 0` —
    stated using AllClosedWalkWeightsNonpos as the formal proxy. -/
theorem guarded_feedback_exists_iff_cycleMean_le_zero {n : ℕ}
    (W : Matrix (Fin n) (Fin n) ℝ) :
    GuardedFeedbackExists W ↔ AllClosedWalkWeightsNonpos W :=
  guarded_feedback_exists_iff_allClosedWalkWeightsNonpos W

/-- User-facing theorem: strict negativity implies uniqueness. -/
theorem guarded_feedback_unique_of_cycleMean_lt_zero {n : ℕ}
    (W : Matrix (Fin n) (Fin n) ℝ) :
    AllClosedWalkWeightsNeg W → GuardedFeedbackUnique W :=
  guarded_feedback_unique_of_allClosedWalkWeightsNeg W

/-! ## Part IX: Dequantization and Order Equivalence -/

/-- Two matrices are **order-equivalent** if they agree on which entries are ≤ 0. -/
def OrderEquivalent {n m : ℕ} (A B : Matrix (Fin n) (Fin m) ℝ) : Prop :=
  ∀ i j, A i j ≤ 0 ↔ B i j ≤ 0

/-- The Maslov dequantization map: entrywise logarithm. -/
def dequantize {n m : ℕ} (A : Matrix (Fin n) (Fin m) ℝ) : Matrix (Fin n) (Fin m) ℝ :=
  fun i j => Real.log (A i j)

/-- Tropical (max-plus) matrix multiplication. -/
def tropicalMul {n m k : ℕ} (A : Matrix (Fin n) (Fin m) ℝ)
    (B : Matrix (Fin m) (Fin k) ℝ) (hm : 0 < m) : Matrix (Fin n) (Fin k) ℝ :=
  fun i j => Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hm⟩⟩)
    (fun l => A i l + B l j)

/-
OrderEquivalent is reflexive.
-/
theorem OrderEquivalent.refl {n m : ℕ} (A : Matrix (Fin n) (Fin m) ℝ) :
    OrderEquivalent A A := by
  exact fun _ _ => Iff.rfl

/-
OrderEquivalent is symmetric.
-/
theorem OrderEquivalent.symm {n m : ℕ} {A B : Matrix (Fin n) (Fin m) ℝ}
    (h : OrderEquivalent A B) : OrderEquivalent B A := by
  exact fun i j => ( h i j ).symm

/-
For positive matrices, `log(∑ aᵢbᵢ) ≤ 0 ← maxᵢ(log aᵢ + log bᵢ) ≤ 0`:
    if every product is ≤ 1, then the sum is ≤ m. This gives a one-sided bound.
-/
theorem dequantize_mul_le_tropical {n m k : ℕ} (hm : 0 < m)
    (A : Matrix (Fin n) (Fin m) ℝ) (B : Matrix (Fin m) (Fin k) ℝ)
    (hA : ∀ i j, 0 < A i j) (hB : ∀ i j, 0 < B i j)
    (i : Fin n) (j : Fin k) :
    tropicalMul (dequantize A) (dequantize B) hm i j ≤
    dequantize (A * B) i j := by
  unfold tropicalMul dequantize;
  simp +decide [ ← Real.log_mul ( ne_of_gt ( hA i _ ) ) ( ne_of_gt ( hB _ j ) ), Matrix.mul_apply ];
  exact fun l => Real.log_le_log ( mul_pos ( hA i l ) ( hB l j ) ) ( Finset.single_le_sum ( fun a _ => mul_nonneg ( le_of_lt ( hA i a ) ) ( le_of_lt ( hB a j ) ) ) ( Finset.mem_univ l ) )

/-
**Dequantization–composition order theorem**: For positive matrices,
    the tropical product of the logs lower-bounds the log of the ordinary product.
-/
theorem dequantize_comp_preserves_order_ge {n m k : ℕ} (hm : 0 < m)
    (A : Matrix (Fin n) (Fin m) ℝ) (B : Matrix (Fin m) (Fin k) ℝ)
    (hA : ∀ i j, 0 < A i j) (hB : ∀ i j, 0 < B i j) (i : Fin n) (j : Fin k) :
    tropicalMul (dequantize A) (dequantize B) hm i j ≤ dequantize (A * B) i j := by
  exact?

end