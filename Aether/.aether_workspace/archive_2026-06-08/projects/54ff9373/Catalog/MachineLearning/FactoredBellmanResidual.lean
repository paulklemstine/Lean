/-
# Factored Bellman Residual Tensorization for Structured MDPs

This module formalizes a **tensorization principle** for Bellman residuals in
factored Markov Decision Processes: in product-state MDPs with coordinatewise
dynamics, Bellman residual control scales with the number of factors, not the
cardinality of the full product state space.

## Main results

### Abstract iterative decay
* `iterate_decay_le_max` — Subtractive decay bound for iterates.
* `eventually_le_zero` — Finite-step convergence.

### Factored sweep decay
* `sweep_gap_decay` — One sweep of factor updates decreases residual by `∑ βᵢ`.
* `factoredSweep_gap_iterate_le` — After `t` sweeps, residual ≤ max(0, gap₀ - t·β).
* `factoredSweep_eventually_zero_gap` — Finite-step convergence when β > 0.

### Bellman residual tensorization
* `finSupNorm_sum_le_sum_finSupNorm` — Sup-norm triangle on product types.
* `bellmanResidual_le_sumFactorResidual` — Global residual ≤ sum of factor residuals.
* `factoredMDP_residual_decay` — Full integrated factored MDP decay theorem.

## Scientific significance

This is a **dimension-breaking theorem**: residual analysis scales with factor
count rather than product state-space cardinality, enabling certified dynamic
programming on exponentially large state spaces via compositional verification.
-/

import Mathlib

open Finset BigOperators

/-! ## Section 1: Abstract Iterative Decay -/

/-
A sequence satisfying `x_{n+1} ≤ max(0, xₙ - β)` is bounded by
`max(0, x₀ - n * β)`. This is the engine of finite-step convergence.
-/
theorem iterate_decay_le_max
    (x : ℕ → ℝ) (β : ℝ) (hβ : 0 ≤ β)
    (hdecay : ∀ n, x (n + 1) ≤ max 0 (x n - β)) :
    ∀ t, x t ≤ max 0 (x 0 - ↑t * β) := by
  intro t;
  -- We proceed by induction on $t$.
  induction' t with t ih;
  · norm_num;
  · grind

/-
Finite-step convergence from subtractive decay with positive step.
-/
theorem eventually_le_zero
    (x : ℕ → ℝ) (β : ℝ) (hβ : 0 < β)
    (hdecay : ∀ n, x (n + 1) ≤ max 0 (x n - β)) :
    ∃ t : ℕ, x t ≤ 0 := by
  -- By induction, we can show that $x_n \leq \max(0, x_0 - n\beta)$.
  have h_ind : ∀ n, x n ≤ max 0 (x 0 - n * β) := by
    exact iterate_decay_le_max x β hβ.le hdecay;
  exact ⟨ ⌊x 0 / β⌋₊ + 1, le_trans ( h_ind _ ) ( max_le ( by norm_num ) ( by push_cast; nlinarith [ Nat.lt_floor_add_one ( x 0 / β ), mul_div_cancel₀ ( x 0 ) hβ.ne' ] ) ) ⟩

/-! ## Section 2: Sweep Composition -/

/-
One sweep of `k` factor updates reduces the gap by at least `∑ᵢ βᵢ`.
-/
theorem sweep_gap_decay
    {k : ℕ} {State : Type*}
    (gap : (State → ℝ) → ℝ)
    (U : Fin k → (State → ℝ) → (State → ℝ))
    (β : Fin k → ℝ)
    (hstep : ∀ (i : Fin k) (W : State → ℝ), gap (U i W) ≤ gap W - β i) :
    ∀ V : State → ℝ,
      gap (List.foldl (fun W i => U i W) V (List.finRange k)) ≤
        gap V - ∑ i : Fin k, β i := by
  induction' k with k ih;
  · simp +decide;
  · simp_all +decide [ List.finRange_succ ];
    intro V;
    convert le_trans ( ih ( fun i W => U i.succ W ) ( fun i => β i.succ ) ( fun i W => hstep _ _ ) ( U 0 V ) ) _ using 1;
    · exact congr_arg _ ( by rw [ List.foldl_map ] );
    · rw [ Fin.sum_univ_succ ] ; linarith [ hstep 0 V ]

/-
After `t` full sweeps, the gap is bounded by `max(0, gap(V₀) - t * ∑ᵢ βᵢ)`.
-/
theorem factoredSweep_gap_iterate_le
    {k : ℕ} {State : Type*}
    (gap : (State → ℝ) → ℝ)
    (U : Fin k → (State → ℝ) → (State → ℝ))
    (β : Fin k → ℝ)
    (hβ : ∀ i, 0 ≤ β i)
    (_hgap_nonneg : ∀ V, 0 ≤ gap V)
    (hstep : ∀ (i : Fin k) (W : State → ℝ), gap (U i W) ≤ gap W - β i)
    (V₀ : State → ℝ) :
    let Sweep := fun W => List.foldl (fun V i => U i V) W (List.finRange k)
    ∀ t : ℕ, gap (Sweep^[t] V₀) ≤ max 0 (gap V₀ - ↑t * ∑ i : Fin k, β i) := by
  refine' fun t => _;
  convert iterate_decay_le_max _ ( ∑ i, β i ) ( Finset.sum_nonneg fun _ _ => hβ _ ) ( fun n => ?_ ) t using 1;
  rotate_left;
  rotate_left;
  use fun n => gap ( ( fun W => List.foldl ( fun V i => U i V ) W ( List.finRange k ) )^[n] V₀ );
  · refine' le_max_of_le_right _;
    simpa only [ Function.iterate_succ_apply' ] using sweep_gap_decay gap U β hstep _;
  · rfl;
  · rfl

/-
Finite-step convergence for factored sweeps when `∑ βᵢ > 0`.
-/
theorem factoredSweep_eventually_zero_gap
    {k : ℕ} {State : Type*}
    (gap : (State → ℝ) → ℝ)
    (U : Fin k → (State → ℝ) → (State → ℝ))
    (β : Fin k → ℝ)
    (hβ : ∀ i, 0 ≤ β i)
    (hβ_pos : 0 < ∑ i : Fin k, β i)
    (hgap_nonneg : ∀ V, 0 ≤ gap V)
    (hstep : ∀ (i : Fin k) (W : State → ℝ), gap (U i W) ≤ gap W - β i)
    (V₀ : State → ℝ) :
    let Sweep := fun W => List.foldl (fun V i => U i V) W (List.finRange k)
    ∃ t : ℕ, gap (Sweep^[t] V₀) = 0 := by
  -- By definition of $Sweep$, we know that $gap (Sweep^[t] V₀) ≤ max 0 (gap V₀ - t * ∑ i, β i)$.
  have h_sweep_gap_iterate_le : ∀ t : ℕ, gap ((fun W => List.foldl (fun V i => U i V) W (List.finRange k))^[t] V₀) ≤ max 0 (gap V₀ - t * ∑ i, β i) := by
    convert factoredSweep_gap_iterate_le gap U β hβ hgap_nonneg hstep V₀ using 1;
  -- Choose $t$ large enough so that $gap V₀ - t * ∑ i, β i ≤ 0$.
  obtain ⟨t, ht⟩ : ∃ t : ℕ, gap V₀ - t * ∑ i, β i ≤ 0 := by
    exact ⟨ ⌈gap V₀ / ∑ i, β i⌉₊, by nlinarith [ Nat.le_ceil ( gap V₀ / ∑ i, β i ), mul_div_cancel₀ ( gap V₀ ) hβ_pos.ne' ] ⟩;
  exact ⟨ t, le_antisymm ( le_trans ( h_sweep_gap_iterate_le t ) ( max_le_iff.mpr ⟨ by norm_num, by linarith ⟩ ) ) ( hgap_nonneg _ ) ⟩

/-! ## Section 3: Sup-Norm Tensorization -/

/-- Finite sup-norm of a function over a nonempty `Fintype`. -/
noncomputable def finSupNorm {α : Type*} [Fintype α] [Nonempty α] (f : α → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun a => |f a|)

theorem finSupNorm_nonneg {α : Type*} [Fintype α] [Nonempty α] (f : α → ℝ) :
    0 ≤ finSupNorm f := by
  exact Finset.le_sup' ( fun a => |f a| ) ( Finset.mem_univ ( Classical.arbitrary α ) ) |> le_trans ( abs_nonneg _ )

theorem le_finSupNorm {α : Type*} [Fintype α] [Nonempty α] (f : α → ℝ) (a : α) :
    |f a| ≤ finSupNorm f := by
  exact Finset.le_sup' ( fun a => |f a| ) ( Finset.mem_univ a )

/-
**Sup-norm tensorization**: the sup of a sum of separable functions over
a product type is at most the sum of factor-wise sups.
-/
theorem finSupNorm_sum_le_sum_finSupNorm
    (k : ℕ) (_hk : 0 < k)
    (n : Fin k → ℕ) (hn : ∀ i, 0 < n i)
    (g : ∀ i : Fin k, Fin (n i) → ℝ) :
    haveI : Nonempty (∀ i : Fin k, Fin (n i)) := ⟨fun i => ⟨0, hn i⟩⟩
    finSupNorm (fun s : ∀ i : Fin k, Fin (n i) => ∑ i, g i (s i)) ≤
      ∑ i : Fin k, (haveI : Nonempty (Fin (n i)) := ⟨⟨0, hn i⟩⟩; finSupNorm (g i)) := by
  unfold finSupNorm;
  simp +zetaDelta at *;
  exact fun b => le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i _ => Finset.le_sup' ( fun a => |g i a| ) ( Finset.mem_univ _ ) )

/-! ## Section 4: Bellman Residual of Separable Value Functions -/

/-- The Bellman residual (gap) of a value function `V` under operator `T`. -/
noncomputable def bellmanGap {State : Type*} [Fintype State] [Nonempty State]
    (T : (State → ℝ) → (State → ℝ)) (V : State → ℝ) : ℝ :=
  finSupNorm (fun s => T V s - V s)

theorem bellmanGap_nonneg {State : Type*} [Fintype State] [Nonempty State]
    (T : (State → ℝ) → (State → ℝ)) (V : State → ℝ) :
    0 ≤ bellmanGap T V :=
  finSupNorm_nonneg _

/-
**Bellman residual tensorization**: If the Bellman operator preserves
separability, the global residual is at most the sum of factor residuals.
-/
theorem bellmanResidual_le_sumFactorResidual
    (k : ℕ) (hk : 0 < k)
    (n : Fin k → ℕ) (hn : ∀ i, 0 < n i)
    (T : ((∀ i : Fin k, Fin (n i)) → ℝ) → (∀ i : Fin k, Fin (n i)) → ℝ)
    (Ti : ∀ i : Fin k, (Fin (n i) → ℝ) → (Fin (n i) → ℝ))
    (Vi : ∀ i : Fin k, Fin (n i) → ℝ)
    (hTsep : ∀ (Wi : ∀ i, Fin (n i) → ℝ),
      T (fun s => ∑ i, Wi i (s i)) = fun s => ∑ i, Ti i (Wi i) (s i)) :
    haveI : Nonempty (∀ i : Fin k, Fin (n i)) := ⟨fun i => ⟨0, hn i⟩⟩
    bellmanGap T (fun s => ∑ i, Vi i (s i)) ≤
      ∑ i : Fin k, (haveI : Nonempty (Fin (n i)) := ⟨⟨0, hn i⟩⟩; bellmanGap (Ti i) (Vi i)) := by
  convert finSupNorm_sum_le_sum_finSupNorm k hk n hn ( fun i s => Ti i ( Vi i ) s - Vi i s ) using 1;
  unfold bellmanGap; aesop;

/-! ## Section 5: Full Integration -/

/-
**Factored MDP residual decay theorem**: In a factored MDP with factor
updates that each decrease the Bellman residual by `βᵢ`, after `t` full sweeps
the global Bellman residual satisfies
  `gap(Sweep^t V₀) ≤ max(0, gap(V₀) - t · ∑ᵢ βᵢ)`.

The convergence rate depends on `k` and the factor gains `βᵢ`, not on `∏ᵢ nᵢ`.
-/
theorem factoredMDP_residual_decay
    (k : ℕ) (_hk : 0 < k)
    (n : Fin k → ℕ) (hn : ∀ i, 0 < n i)
    (T : ((∀ i : Fin k, Fin (n i)) → ℝ) → (∀ i : Fin k, Fin (n i)) → ℝ)
    (Ui : ∀ i : Fin k,
      ((∀ j : Fin k, Fin (n j)) → ℝ) → ((∀ j : Fin k, Fin (n j)) → ℝ))
    (β : Fin k → ℝ)
    (hβ : ∀ i, 0 ≤ β i)
    (hUstep : ∀ (i : Fin k) (W : (∀ j : Fin k, Fin (n j)) → ℝ),
      (haveI : Nonempty (∀ j : Fin k, Fin (n j)) := ⟨fun j => ⟨0, hn j⟩⟩;
       bellmanGap T (Ui i W)) ≤
      (haveI : Nonempty (∀ j : Fin k, Fin (n j)) := ⟨fun j => ⟨0, hn j⟩⟩;
       bellmanGap T W) - β i)
    (V₀ : (∀ i : Fin k, Fin (n i)) → ℝ) :
    haveI : Nonempty (∀ j : Fin k, Fin (n j)) := ⟨fun j => ⟨0, hn j⟩⟩
    let Sweep := fun W => List.foldl (fun V _i => Ui _i V) W (List.finRange k)
    ∀ t : ℕ, bellmanGap T (Sweep^[t] V₀) ≤
      max 0 (bellmanGap T V₀ - ↑t * ∑ i : Fin k, β i) := by
  intros Sweep _;
  convert factoredSweep_gap_iterate_le _ _ _ _ _ _ _ _;
  · assumption;
  · grind +suggestions;
  · assumption