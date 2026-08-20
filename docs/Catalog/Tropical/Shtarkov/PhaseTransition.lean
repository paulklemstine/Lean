/-
# Saturation and the state-budget phase transition

Using the counting upper bound `shtarkovSum_fsmClass_le` and the packing lower
bound `shtarkovSum_ge_packing`, this file exhibits the behaviour of the minimax
regret of the finite-state class as a function of the *state budget* `k(n)`:

* `shtarkovSum_counter_eq` — with `k = n+1` states the class **saturates**:
  the Shtarkov sum is exactly `2^n`, i.e. the regret is `n log 2` and no
  compression at all is possible in the worst case;
* `fsm_regret_rate_tendsto_zero` — whenever `k(n) log(n+1) = o(n)` the regret
  *rate* vanishes;
* `sqrtStates_regret_rate_tendsto_zero` — the concrete family `k(n) = ⌊√n⌋`
  satisfies this, so an unbounded number of states is still compatible with a
  vanishing regret rate.

The mechanism is the counter machine `counterFSM n`, whose `n+1` states record
the time index; each state carries one free Bernoulli parameter, and setting
those parameters to `0/1` memorises an arbitrary word.
-/

import Catalog.Tropical.Shtarkov.FiniteState

open Finset Filter Topology

namespace TropicalShtarkov

/-! ## The counter machine -/

/-- The `n+1`-state counter machine: its state is the (capped) time index. -/
def counterFSM (n : ℕ) : FSM (n + 1) where
  init := ⟨0, Nat.succ_pos n⟩
  step := fun s _ => if h : (s : ℕ) + 1 < n + 1 then ⟨(s : ℕ) + 1, h⟩ else s

theorem counterFSM_state (n : ℕ) (u : ℕ → Bool) (i : ℕ) :
    ((stAux (counterFSM n) (counterFSM n).init u i : Fin (n + 1)) : ℕ) = min i n := by
  induction i with
  | zero => simp [counterFSM, stAux]
  | succ i ih =>
      set s := stAux (counterFSM n) (counterFSM n).init u i with hs
      show (((counterFSM n).step s (u i) : Fin (n + 1)) : ℕ) = min (i + 1) n
      by_cases h : (s : ℕ) + 1 < n + 1
      · rw [show (counterFSM n).step s (u i) = ⟨(s : ℕ) + 1, h⟩ from dif_pos h]
        show (s : ℕ) + 1 = min (i + 1) n
        omega
      · rw [show (counterFSM n).step s (u i) = s from dif_neg h]
        omega

/-- At time `i < n` the counter machine is in state `i`. -/
theorem counterFSM_state_lt (n i : ℕ) (u : ℕ → Bool) (h : i < n) :
    stAux (counterFSM n) (counterFSM n).init u i = ⟨i, by omega⟩ := by
  apply Fin.ext
  rw [counterFSM_state]
  simp [min_eq_left h.le]

/-! ## Memorisation: the packing construction -/

/-- The parameter vector of the `n`-counter machine that memorises the word `z`
of length `m`. -/
noncomputable def memorise (n : ℕ) {m : ℕ} (z : Word m) : Params (n + 1) :=
  ⟨fun s => if h : (s : ℕ) < m then (if z ⟨s, h⟩ then 1 else 0) else 0, by
    intro s
    dsimp only
    split
    · split <;> norm_num
    · norm_num⟩

/-- The memorising source assigns its target word probability exactly `1`, for
any horizon `m` within the counter's range. -/
theorem prob_memorise_self {m n : ℕ} (hmn : m ≤ n) (z : Word m) :
    prob (counterFSM n) (memorise n z).1 m z = 1 := by
  unfold prob probFrom
  refine Finset.prod_eq_one fun i hi => ?_
  have him : i < m := Finset.mem_range.mp hi
  have hin : i < n := lt_of_lt_of_le him hmn
  have hz : pad z i = z ⟨i, him⟩ := by simp [pad, dif_pos him]
  rw [counterFSM_state_lt n i (pad z) hin, hz]
  have hθ : (memorise n z).1 ⟨i, by omega⟩ = if z ⟨i, him⟩ then 1 else 0 := by
    simp [memorise, dif_pos him]
  cases hb : z ⟨i, him⟩ <;> simp [wt, hθ, hb]

/-- **Packing lower bound for the counter machine.** -/
theorem shtarkovSum_counter_ge {m n : ℕ} (hmn : m ≤ n) :
    (2 ^ m : ℝ) ≤ shtarkovSum (fsmClass (counterFSM n) m) := by
  have h := shtarkovSum_ge_packing (fsmClass (counterFSM n) m)
    (fsmClass_nonneg _ _) (fsmClass_le_one _ _) (univ : Finset (Word m))
    (fun z => memorise n z)
  have hone : ∀ z ∈ (univ : Finset (Word m)),
      fsmClass (counterFSM n) m (memorise n z) z = 1 :=
    fun z _ => prob_memorise_self hmn z
  rw [Finset.sum_congr rfl hone] at h
  simpa using h

/-- **Saturation.**  With at least one state per time index the finite-state
class has Shtarkov sum exactly `2^m`: the worst-case regret is the whole message
length, so no compression is possible. -/
theorem shtarkovSum_counter_eq_of_le {m n : ℕ} (hmn : m ≤ n) :
    shtarkovSum (fsmClass (counterFSM n) m) = 2 ^ m :=
  le_antisymm (shtarkovSum_fsmClass_le_two_pow _ _) (shtarkovSum_counter_ge hmn)

/-- Saturation at the matched horizon `m = n`. -/
theorem shtarkovSum_counter_eq (n : ℕ) :
    shtarkovSum (fsmClass (counterFSM n) n) = 2 ^ n :=
  shtarkovSum_counter_eq_of_le (le_refl n)

/-! ## Regret -/

variable {k : ℕ}

/-- The minimax pointwise regret of the `k`-state class on words of length `n`. -/
noncomputable def regret (M : FSM k) (n : ℕ) : ℝ := Real.log (shtarkovSum (fsmClass M n))

theorem regret_nonneg (M : FSM k) (n : ℕ) : 0 ≤ regret M n :=
  Real.log_nonneg (one_le_shtarkovSum_fsmClass M n)

/-- The counter machine has maximal regret `n log 2`. -/
theorem regret_counter (n : ℕ) : regret (counterFSM n) n = n * Real.log 2 := by
  unfold regret
  rw [shtarkovSum_counter_eq, Real.log_pow]

/-- The counting upper bound in logarithmic (regret) form. -/
theorem regret_le (M : FSM k) (n : ℕ) : regret M n ≤ 2 * k * Real.log (n + 1) := by
  have h0 : (0:ℝ) < shtarkovSum (fsmClass M n) :=
    lt_of_lt_of_le zero_lt_one (one_le_shtarkovSum_fsmClass M n)
  have h1 := shtarkovSum_fsmClass_le M n
  have h2 : Real.log (shtarkovSum (fsmClass M n)) ≤ Real.log ((((n:ℝ) + 1) * ((n:ℝ) + 1)) ^ k) :=
    Real.log_le_log h0 h1
  refine h2.trans (le_of_eq ?_)
  rw [Real.log_pow, ← Real.sqrt_mul_self (by positivity : (0:ℝ) ≤ (n:ℝ) + 1)]
  rw [Real.sqrt_mul_self (by positivity : (0:ℝ) ≤ (n:ℝ) + 1)]
  rw [Real.log_mul (by positivity) (by positivity)]
  ring

/-! ## The phase transition in the state budget -/

/-- **Vanishing regret rate.**  If the state budget satisfies
`k(n) · log(n+1) = o(n)`, then the per-symbol redundancy of the finite-state
class tends to zero. -/
theorem fsm_regret_rate_tendsto_zero (k : ℕ → ℕ) (M : ∀ n, FSM (k n))
    (h : Tendsto (fun n : ℕ => (k n : ℝ) * Real.log (n + 1) / n) atTop (𝓝 0)) :
    Tendsto (fun n : ℕ => regret (M n) n / n) atTop (𝓝 0) := by
  have hlim : Tendsto (fun n : ℕ => 2 * ((k n : ℝ) * Real.log (n + 1) / n)) atTop (𝓝 0) := by
    simpa using h.const_mul (2 : ℝ)
  refine squeeze_zero' ?_ ?_ hlim
  · filter_upwards [eventually_gt_atTop 0] with n hn
    have hn' : (0:ℝ) < n := by exact_mod_cast hn
    exact div_nonneg (regret_nonneg _ _) hn'.le
  · filter_upwards [eventually_gt_atTop 0] with n hn
    have hn' : (0:ℝ) < n := by exact_mod_cast hn
    have hrw : 2 * ((k n : ℝ) * Real.log (n + 1) / n)
        = (2 * (k n : ℝ) * Real.log (n + 1)) / n := by ring
    rw [hrw]
    gcongr
    exact regret_le (M n) n

/-- `log t / t → 0`. -/
theorem log_div_self_tendsto : Tendsto (fun t : ℝ => Real.log t / t) atTop (𝓝 0) := by
  simpa using Real.tendsto_pow_log_div_mul_add_atTop 1 0 1 one_ne_zero

/-- `log y / √y → 0`. -/
theorem log_div_sqrt_tendsto : Tendsto (fun y : ℝ => Real.log y / Real.sqrt y) atTop (𝓝 0) := by
  have h := (log_div_self_tendsto.comp Real.tendsto_sqrt_atTop).const_mul (2 : ℝ)
  rw [mul_zero] at h
  refine h.congr' ?_
  filter_upwards [eventually_gt_atTop (0:ℝ)] with y hy
  have hs : 0 < Real.sqrt y := Real.sqrt_pos.mpr hy
  show 2 * (Real.log (Real.sqrt y) / Real.sqrt y) = Real.log y / Real.sqrt y
  rw [Real.log_sqrt hy.le]
  field_simp

/-- The natural square root is dominated by the real square root. -/
theorem cast_natSqrt_le (n : ℕ) : (Nat.sqrt n : ℝ) ≤ Real.sqrt n := by
  rw [show ((Nat.sqrt n : ℝ)) = Real.sqrt ((Nat.sqrt n : ℝ) ^ 2) by
    rw [Real.sqrt_sq (by positivity)]]
  exact Real.sqrt_le_sqrt (by exact_mod_cast Nat.sqrt_le' n)

/-- The concrete budget `k(n) = ⌊√n⌋ + 1` satisfies the `o(n / log n)` hypothesis. -/
theorem sqrtStates_rate :
    Tendsto (fun n : ℕ => ((Nat.sqrt n : ℝ) + 1) * Real.log (n + 1) / n) atTop (𝓝 0) := by
  have hcomp : Tendsto (fun n : ℕ => Real.log ((n : ℝ) + 1) / Real.sqrt ((n : ℝ) + 1))
      atTop (𝓝 0) :=
    log_div_sqrt_tendsto.comp
      (tendsto_atTop_add_const_right atTop 1 tendsto_natCast_atTop_atTop)
  have hlim : Tendsto (fun n : ℕ => 4 * (Real.log ((n : ℝ) + 1) / Real.sqrt ((n : ℝ) + 1)))
      atTop (𝓝 0) := by simpa using hcomp.const_mul (4 : ℝ)
  refine squeeze_zero' ?_ ?_ hlim
  · filter_upwards [eventually_gt_atTop 0] with n hn
    have hN : (1:ℝ) ≤ n := by exact_mod_cast hn
    have hL : 0 ≤ Real.log ((n : ℝ) + 1) := Real.log_nonneg (by linarith)
    positivity
  · filter_upwards [eventually_gt_atTop 0] with n hn
    have hN : (1:ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
    have hNpos : (0:ℝ) < (n : ℝ) := by linarith
    have hL : 0 ≤ Real.log ((n : ℝ) + 1) := Real.log_nonneg (by linarith)
    have hs : 0 < Real.sqrt (n : ℝ) := Real.sqrt_pos.mpr hNpos
    have hss : Real.sqrt (n : ℝ) * Real.sqrt (n : ℝ) = (n : ℝ) :=
      Real.mul_self_sqrt hNpos.le
    have hs1 : 0 < Real.sqrt ((n : ℝ) + 1) := Real.sqrt_pos.mpr (by linarith)
    have hsq : Real.sqrt ((n : ℝ) + 1) ≤ 2 * Real.sqrt (n : ℝ) := by
      rw [show (2:ℝ) * Real.sqrt (n : ℝ) = Real.sqrt (4 * (n : ℝ)) by
        rw [show (4:ℝ) * (n : ℝ) = (2 * Real.sqrt (n : ℝ)) ^ 2 by
          rw [mul_pow, Real.sq_sqrt hNpos.le]; ring, Real.sqrt_sq (by positivity)]]
      exact Real.sqrt_le_sqrt (by linarith)
    have hone : (1:ℝ) ≤ (Nat.sqrt n : ℝ) := by
      have : 1 ≤ Nat.sqrt n := Nat.le_sqrt'.mpr hn
      exact_mod_cast this
    have hbudget : (Nat.sqrt n : ℝ) + 1 ≤ 2 * Real.sqrt (n : ℝ) := by
      have := cast_natSqrt_le n
      linarith
    calc ((Nat.sqrt n : ℝ) + 1) * Real.log ((n : ℝ) + 1) / (n : ℝ)
        ≤ (2 * Real.sqrt (n : ℝ)) * Real.log ((n : ℝ) + 1) / (n : ℝ) := by gcongr
      _ = 2 * (Real.log ((n : ℝ) + 1) / Real.sqrt (n : ℝ)) := by
          field_simp
          linear_combination Real.log ((n : ℝ) + 1) * hss
      _ ≤ 4 * (Real.log ((n : ℝ) + 1) / Real.sqrt ((n : ℝ) + 1)) := by
          rw [mul_div_assoc', mul_div_assoc']
          refine (div_le_div_iff₀ hs hs1).mpr ?_
          nlinarith [hL, hsq]

/-- **The state-budget phase transition, vanishing side.**  Any family of
machines with `⌊√n⌋ + 1` states has vanishing per-symbol redundancy. -/
theorem sqrtStates_regret_rate_tendsto_zero (M : ∀ n : ℕ, FSM (Nat.sqrt n + 1)) :
    Tendsto (fun n : ℕ => regret (M n) n / n) atTop (𝓝 0) := by
  refine fsm_regret_rate_tendsto_zero (fun n => Nat.sqrt n + 1) M ?_
  refine sqrtStates_rate.congr' ?_
  filter_upwards with n
  push_cast
  ring

/-- **The state-budget phase transition, saturated side.**  The counter family,
with `n+1` states, has per-symbol redundancy exactly `log 2` for every `n ≥ 1`:
it is a genuine dichotomy, not a matter of constants. -/
theorem counter_regret_rate (n : ℕ) (hn : 0 < n) :
    regret (counterFSM n) n / n = Real.log 2 := by
  have hN : (0:ℝ) < (n : ℝ) := by exact_mod_cast hn
  rw [regret_counter, mul_comm, mul_div_assoc, div_self (ne_of_gt hN), mul_one]

/-- **The state-budget phase transition.**  A single statement contrasting the
two regimes of the state budget `k(n)`: with `k(n) = ⌊√n⌋ + 1` states the
per-symbol minimax redundancy vanishes, while with `k(n) = n + 1` states it is
exactly `log 2`, the maximum possible. -/
theorem state_budget_phase_transition (M : ∀ n : ℕ, FSM (Nat.sqrt n + 1)) :
    Tendsto (fun n : ℕ => regret (M n) n / n) atTop (𝓝 0) ∧
      ∀ n : ℕ, 0 < n → regret (counterFSM n) n / n = Real.log 2 :=
  ⟨sqrtStates_regret_rate_tendsto_zero M, fun n hn => counter_regret_rate n hn⟩

end TropicalShtarkov