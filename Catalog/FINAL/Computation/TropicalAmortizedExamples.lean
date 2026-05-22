import Mathlib

/-!
# Tropical Amortized Analysis: Worked Examples

This file demonstrates the tropical amortized analysis framework with
concrete applications: the stack with multipop and the binary counter.

## Main results

* `stack_total_cost_le_two_mul_n` — stack with push/pop has O(n) total cost
* `binary_counter_total_cost_le_two_mul_n` — binary counter increment has amortized O(1)
-/

open Finset BigOperators

/-! ## Foundational lemma (restated from TropicalAmortized) -/

/-
Telescoping identity for Fin-indexed amortized charges.
-/
private theorem sum_amortized_telescoping
    {σ : Type} {n : ℕ}
    (s : Fin (n + 1) → σ)
    (c : Fin n → ℤ)
    (Φ : σ → ℤ) :
    (∑ i : Fin n, (c i + Φ (s ⟨i.1 + 1, by omega⟩) - Φ (s ⟨i.1, by omega⟩))) =
      (∑ i, c i) + Φ (s ⟨n, Nat.lt_succ_self n⟩) - Φ (s 0) := by
  have h_telescope : ∀ (n : ℕ) (s : Fin (n + 1) → σ) (Φ : σ → ℤ), ∑ i : Fin n, (Φ (s (Fin.mk (i + 1) (by linarith [Fin.is_lt i]))) - Φ (s (Fin.mk i (by linarith [Fin.is_lt i])))) = Φ (s (Fin.mk n (by linarith))) - Φ (s 0) := by
    intro n s Φ; induction' n with n ih <;> simp_all +decide [ Fin.sum_univ_castSucc ] ;
    linarith! [ ih fun i => s i.castSucc ];
  simp_all +decide [ Finset.sum_add_distrib, add_sub_assoc ]

/-! ## Example 1: Stack with Push/Pop

A stack supports push (cost 1) and pop (cost 1). The potential function
is the stack size. Each push has amortized cost 2, each pop has amortized
cost 0, and the total actual cost over n operations is at most 2n.
-/

/-- Stack state is just the stack size. -/
abbrev StackState := ℕ

/-- The potential function for the stack: just the stack size. -/
def stackPotential : StackState → ℤ := fun s => (s : ℤ)

/-- **Stack push has amortized cost 2.** -/
theorem stack_push_amortized (s : ℕ) :
    (1 : ℤ) + stackPotential (s + 1) - stackPotential s = 2 := by
  simp [stackPotential]; omega

/-- **Stack pop has amortized cost 0.** -/
theorem stack_pop_amortized (s : ℕ) :
    (1 : ℤ) + stackPotential s - stackPotential (s + 1) = 0 := by
  simp [stackPotential]; omega

/-
For any sequence of n stack operations with amortized cost ≤ 2 each,
starting from empty stack, total cost ≤ 2n.
-/
theorem stack_total_cost_le_two_mul_n
    (n : ℕ)
    (states : Fin (n + 1) → StackState)
    (h_init : states 0 = 0)
    (costs : Fin n → ℤ)
    (h_amortized_bound : ∀ i,
      costs i + stackPotential (states ⟨i.1 + 1, by omega⟩) -
        stackPotential (states ⟨i.1, by omega⟩) ≤ 2) :
    (∑ i, costs i) ≤ 2 * n := by
  -- Apply the fact that the sum of non-negative terms is non-negative.
  have h_sum_nonneg : ∑ i : Fin n, stackPotential (states ⟨i.1 + 1, by omega⟩) - ∑ i : Fin n, stackPotential (states ⟨i.1, by omega⟩) = stackPotential (states ⟨n, Nat.lt_succ_self n⟩) - stackPotential (states 0) := by
    convert sum_amortized_telescoping states ( fun _ => 0 ) stackPotential using 1 ; norm_num;
    norm_num;
  have := Finset.sum_le_sum fun i ( _hi : i ∈ Finset.univ ) => h_amortized_bound i; simp_all +decide [ Finset.sum_add_distrib, mul_comm ] ;
  linarith [ show stackPotential ( states ⟨ n, Nat.lt_succ_self n ⟩ ) - stackPotential 0 ≥ 0 from sub_nonneg_of_le <| by exact Int.ofNat_le.2 <| Nat.zero_le _ ]

/-! ## Example 2: Binary Counter -/

/-- Counter state tracks the number of 1-bits. -/
abbrev CounterState := ℕ

/-- Potential function: number of 1-bits. -/
def counterPotential : CounterState → ℤ := fun ones => (ones : ℤ)

/-
**Binary counter amortized cost per increment ≤ 2.**
If we flip `trailing_ones` 1-bits to 0 and one 0-bit to 1,
actual cost = trailing_ones + 1, and ΔΦ = -trailing_ones + 1,
so amortized = 2.
-/
theorem binary_counter_amortized_step
    (ones_before ones_after trailing_ones : ℕ)
    (h_after : ones_after = ones_before - trailing_ones + 1)
    (h_trailing : trailing_ones ≤ ones_before)
    (actual_cost : ℤ)
    (h_cost : actual_cost = (trailing_ones : ℤ) + 1) :
    actual_cost + counterPotential ones_after - counterPotential ones_before ≤ 2 := by
  unfold counterPotential; omega;

/-
**Binary counter total cost bound.** Total flip cost ≤ 2n for n increments.
-/
theorem binary_counter_total_cost_le_two_mul_n
    (n : ℕ)
    (states : Fin (n + 1) → CounterState)
    (costs : Fin n → ℤ)
    (h_init : states 0 = 0)
    (h_amortized : ∀ i,
      costs i + counterPotential (states ⟨i.1 + 1, by omega⟩) -
        counterPotential (states ⟨i.1, by omega⟩) ≤ 2) :
    (∑ i, costs i) ≤ 2 * n := by
  -- By summing the amortized costs over all steps, we get the total amortized cost.
  have h_total_amortized : ∑ i : Fin n, (costs i + counterPotential (states ⟨i.1 + 1, by omega⟩) - counterPotential (states ⟨i.1, by omega⟩)) = (∑ i : Fin n, costs i) + counterPotential (states ⟨n, Nat.lt_succ_self n⟩) - counterPotential (states 0) := by
    convert sum_amortized_telescoping states costs counterPotential using 1;
  simp_all +decide [ counterPotential ];
  have := Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h_amortized i; simp_all +decide [ Finset.sum_add_distrib ] ; linarith;

/-! ## Example 3: Tropical convolution for two-phase computation -/

/-- Min-plus convolution (restated). -/
noncomputable def tropicalConv' (f g : ℕ → ℕ) (n : ℕ) : ℕ :=
  ((Finset.range (n + 1)).image (fun k => f k + g (n - k))).min'
    ⟨f 0 + g n, Finset.mem_image.mpr ⟨0, by simp, rfl⟩⟩

/-- If phase 1 costs f(k) for k operations and phase 2 costs g(m) for m
operations, the optimal total cost for n operations is bounded by
any particular split. -/
theorem two_phase_optimal_split
    (f g : ℕ → ℕ) (n k : ℕ) (hk : k ≤ n) :
    tropicalConv' f g n ≤ f k + g (n - k) := by
  exact Finset.min'_le _ _
    (Finset.mem_image_of_mem _ (Finset.mem_range.mpr (Nat.lt_succ_of_le hk)))