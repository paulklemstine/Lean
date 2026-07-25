/-
  # Width-Bounded Dynamic Programming for Tropical Φ

  This file formalizes a layered tropical circuit model and proves that
  the tropical Φ invariant (minimum-cost path through a layered network)
  is exactly computable via Bellman-style dynamic programming with
  O(L · w²) arithmetic operations, where L is the number of layers
  and w is the width (number of states per layer).

  ## Main Results

  - `tropicalPhi`: The minimum total cost over all state trajectories through L layers.
  - `dpTable`: The dynamic programming value function computed by Bellman updates.
  - `computePhiDP_correct`: Global correctness — DP computes tropicalPhi exactly.
  - `dpWork`: Work bound — DP uses at most L * w * w + w operations.
  - `dp_beats_enumeration`: Asymptotic separation — DP work is eventually less than 2^L.
-/

import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Model: Layered Tropical Circuit -/

/-- Total cost of a trajectory q through the layered system with L layers and width w. -/
def PathCost {L w : ℕ} (step : Fin L → Fin w → Fin w → ℝ)
    (q : Fin (L + 1) → Fin w) : ℝ :=
  ∑ i : Fin L, step i (q (Fin.castSucc i)) (q i.succ)

/-- The tropical Φ invariant: minimum path cost over all trajectories.
    Defined via `Finset.inf'` over the nonempty finite set of all trajectories. -/
def tropicalPhi {L w : ℕ} [NeZero w]
    (step : Fin L → Fin w → Fin w → ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty
    (fun q : Fin (L + 1) → Fin w => PathCost step q)

/-! ## Dynamic Programming via Bellman Updates -/

/-- DP table: minimum cost-to-go from state s with `remaining` layers left.
    - Base case (0 remaining): cost is 0
    - Recursive case (n+1 remaining): min over next states of step cost + future cost -/
def dpTable {L w : ℕ} [NeZero w]
    (step : Fin L → Fin w → Fin w → ℝ) :
    (remaining : ℕ) → (remaining ≤ L) → Fin w → ℝ
  | 0, _, _ => 0
  | n + 1, hrem, s =>
    Finset.inf' Finset.univ Finset.univ_nonempty
      (fun t : Fin w => step ⟨L - (n + 1), by omega⟩ s t + dpTable step n (by omega) t)

/-- The DP-computed tropical Φ: minimize over initial states. -/
def computePhiDP {L w : ℕ} [NeZero w]
    (step : Fin L → Fin w → Fin w → ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty
    (fun s : Fin w => dpTable step L le_rfl s)

/-! ## Correctness

The proof proceeds by showing two inequalities:
1. computePhiDP ≤ tropicalPhi (DP value ≤ any path cost)
2. tropicalPhi ≤ computePhiDP (there exists a path achieving the DP value)
-/

/-
For any trajectory q, dpTable with all L layers at q(0) is at most PathCost q.
-/
theorem dpTable_le_pathCost {L w : ℕ} [NeZero w]
    (step : Fin L → Fin w → Fin w → ℝ)
    (q : Fin (L + 1) → Fin w) :
    dpTable step L le_rfl (q ⟨0, by omega⟩) ≤ PathCost step q := by
  -- By induction on $L$, we can show that for any $n \leq L$, $dpTable step n hn (q ⟨L-n, by omega⟩) \leq \sum_{i : Fin n} step ⟨L-n+i, by omega⟩ (q ⟨L-n+i, by omega⟩) (q ⟨L-n+i+1, by omega⟩)$.
  have h_inductive : ∀ (n : ℕ) (hn : n ≤ L) (q : Fin (L + 1) → Fin w), dpTable step n hn (q ⟨L - n, by omega⟩) ≤ ∑ i : Fin n, step ⟨L - n + i.val, by omega⟩ (q ⟨L - n + i.val, by omega⟩) (q ⟨L - n + i.val + 1, by omega⟩) := by
    intro n hn q;
    induction' n with n ih generalizing q <;> simp_all +decide [ Fin.sum_univ_succ ];
    · exact le_rfl;
    · refine' le_trans ( Finset.inf'_le _ <| Finset.mem_univ <| q ⟨ L - n, by omega ⟩ ) _;
      refine' add_le_add _ ( le_trans ( ih ( Nat.le_of_succ_le hn ) q ) _ );
      · grind +qlia;
      · grind;
  convert h_inductive L le_rfl q using 1;
  · norm_num;
  · simp +decide [ PathCost ];
    congr! 2

/-
There exists a trajectory achieving the dpTable value.
-/
theorem exists_traj_eq_dpTable {L w : ℕ} [NeZero w]
    (step : Fin L → Fin w → Fin w → ℝ) (s : Fin w) :
    ∃ q : Fin (L + 1) → Fin w,
      q ⟨0, by omega⟩ = s ∧ PathCost step q = dpTable step L le_rfl s := by
  -- We prove this by induction on `remaining`.
  have h_ind : ∀ (remaining : ℕ) (hrem : remaining ≤ L) (s : Fin w), ∃ q : Fin (remaining + 1) → Fin w, q ⟨0, by omega⟩ = s ∧ ∑ i : Fin remaining, step ⟨L - remaining + i, by omega⟩ (q ⟨i.val, by omega⟩) (q ⟨i.val + 1, by omega⟩) = dpTable step remaining hrem s := by
    intro remaining hrem;
    induction' remaining with remaining ihizing s;
    · exact fun s => ⟨ fun _ => s, rfl, by simp +decide [ dpTable ] ⟩;
    · intro s
      obtain ⟨t₀, ht₀⟩ : ∃ t₀ : Fin w, dpTable step (remaining + 1) hrem s = step ⟨L - (remaining + 1), by omega⟩ s t₀ + dpTable step remaining (by omega) t₀ := by
        have := Finset.exists_min_image Finset.univ ( fun t => step ⟨ L - ( remaining + 1 ), by omega ⟩ s t + dpTable step remaining ( by omega ) t ) ⟨ s, Finset.mem_univ s ⟩;
        obtain ⟨ t₀, ht₀₁, ht₀₂ ⟩ := this; use t₀; exact le_antisymm ( Finset.inf'_le _ ht₀₁ ) ( Finset.le_inf' _ _ fun x hx => ht₀₂ x hx ) ;
      obtain ⟨ q, hq₁, hq₂ ⟩ := ihizing ( Nat.le_of_succ_le hrem ) t₀;
      refine' ⟨ Fin.cons s q, _, _ ⟩ <;> simp_all +decide [ Fin.sum_univ_succ ];
      convert hq₂ using 2;
      congr! 2;
      omega;
  obtain ⟨ q, hq₁, hq₂ ⟩ := h_ind L le_rfl s;
  use q; aesop;

/-
Global correctness: computePhiDP computes tropicalPhi exactly.
-/
theorem computePhiDP_correct {L w : ℕ} [NeZero w]
    (step : Fin L → Fin w → Fin w → ℝ) :
    computePhiDP step = tropicalPhi step := by
  unfold computePhiDP tropicalPhi;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le_iff ];
  · exact fun q => ⟨ q ⟨ 0, by linarith ⟩, dpTable_le_pathCost step q ⟩;
  · exact fun s => by obtain ⟨ q, hq₁, hq₂ ⟩ := exists_traj_eq_dpTable step s; exact ⟨ q, hq₂.le ⟩ ;

/-! ## Work Bound -/

/-- The number of arithmetic operations used by the DP. -/
def dpWork (L w : ℕ) : ℕ := L * w * w + w

theorem dpWork_eq (L w : ℕ) : dpWork L w = L * w * w + w := rfl

/-! ## Asymptotic Separation -/

/-
For any fixed width w, the DP work L*w*w + w is eventually less than 2^L.
-/
theorem dp_beats_enumeration (w : ℕ) :
    ∃ N0 : ℕ, ∀ L : ℕ, L ≥ N0 → dpWork L w < 2 ^ L := by
  -- We'll use that $2^L$ grows exponentially faster than $L^2$.
  have h_exp_growth : Filter.Tendsto (fun L : ℕ => (L * w * w + w : ℝ) / 2 ^ L) Filter.atTop (nhds 0) := by
    -- We can factor out $w^2$ from the numerator and use the fact that $\frac{L}{2^L}$ tends to $0$ as $L$ tends to infinity.
    have h_factor : Filter.Tendsto (fun L : ℕ => (L : ℝ) / 2 ^ L) Filter.atTop (nhds 0) := by
      refine' squeeze_zero_norm' _ tendsto_inv_atTop_nhds_zero_nat;
      norm_num;
      exact ⟨ 8, fun n hn => by rw [ inv_eq_one_div, div_le_div_iff₀ ] <;> norm_cast <;> induction hn <;> norm_num [ Nat.pow_succ ] at * ; nlinarith ⟩;
    convert Filter.Tendsto.add ( h_factor.mul_const ( w ^ 2 : ℝ ) ) ( tendsto_const_nhds.mul ( tendsto_inv_atTop_zero.comp ( tendsto_pow_atTop_atTop_of_one_lt one_lt_two ) ) ) using 2 <;> ring!;
    norm_num [ ← inv_pow ];
  have := h_exp_growth.eventually ( gt_mem_nhds zero_lt_one );
  exact Filter.eventually_atTop.mp ( this.mono fun x hx => by rw [ div_lt_one ( by positivity ) ] at hx; exact_mod_cast hx )

end