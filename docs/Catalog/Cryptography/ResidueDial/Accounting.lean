import Cryptography.ResidueDial.Core

/-!
# Two accountings of a dial-aware scan: `4/3` versus `2`

The cap proved in `Core.lean` is `4/3`, while the *asked* barrier in the
literature is `2`.  The discrepancy is not a mistake in either place: it is a
difference of **cost accounting**, and this file isolates it exactly.

* **Worst-case-in-phase accounting** (`Core.lean`).  A phase that scans `m`
  classes is charged `m`.  Exact law `1 - θ + θ²`, exact cap `4/3`
  (`speedup_le_four_thirds`), attained at `θ = 1/2`.

* **Expected-position accounting** (this file).  The scan is charged the
  *position* at which the target is found, the algorithm being allowed to
  reorder the classes freely inside each branch of the dial reading.  The
  optimal expected cost of a dial with blocks of sizes `k` and `j` is
  `(k(k+1) + j(j+1)) / (2(k+j))`, against a baseline `(k+j+1)/2`, giving
  `avgSpeedup k j = (k+j)(k+j+1) / (k(k+1) + j(j+1))`.

The main results:

* `schedule_sum_lower_bound` — the optimality lemma: *any* pair of scan orders
  compatible with the dial reading costs at least the triangular sums.  This is
  what makes `avgSpeedup` an upper bound over all strategies, not just the value
  of one strategy.
* `avgSpeedup_lt_two` — under expected-position accounting the barrier is `2`,
  **never attained**.
* `avgSpeedup_balanced`, `avgSpeedup_balanced_tendsto_two` — it is nevertheless
  sharp: at balanced blocks the value is `(2m+1)/(m+1) → 2`.
* `accounting_gap` — the two accountings genuinely differ: `4/3 < 2`, and for
  every `ε > 0` the expected-position speedup exceeds `2 - ε` for large enough
  balanced blocks, while the worst-case-in-phase speedup never exceeds `4/3`.

Moral (the self-caught error of the round): the provable universal constant in
the worst-case-in-phase framing is `4/3`, and `2` is only the *supremum* of a
different, more generous accounting — reporting `≤ 2` in the first framing would
have been a strictly weaker, and reporting `= 2` a false, claim.
-/

namespace ResidueDial

open Finset

/-! ## Optimality of the block schedules -/

/-- Any injective assignment of positions `≥ 1` to the `m` elements of `S` costs
at least the triangular number `m(m+1)/2` in total.  (Stated multiplied by `2`
to stay in `ℤ`.) -/
theorem sum_ge_triangular {α : Type*} [DecidableEq α] (S : Finset α) (p : α → ℤ)
    (hinj : Set.InjOn p S) (h1 : ∀ t ∈ S, 1 ≤ p t) :
    (S.card : ℤ) * (S.card + 1) ≤ 2 * ∑ t ∈ S, p t := by
  classical
  set T : Finset ℤ := S.image p with hT
  have hcard : T.card = S.card :=
    Finset.card_image_of_injOn (by intro x hx y hy hxy; exact hinj hx hy hxy)
  have hsum : ∑ x ∈ T, x = ∑ t ∈ S, p t :=
    Finset.sum_image (by intro x hx y hy hxy; exact hinj hx hy hxy)
  have hge : ∀ x ∈ T, (1:ℤ) ≤ x := by
    intro x hx
    obtain ⟨t, ht, rfl⟩ := Finset.mem_image.mp hx
    exact h1 t ht
  have key := Finset.sum_range_le_sum (s := T) (c := 1) hge
  have hrange : 2 * ∑ n ∈ Finset.range T.card, ((1:ℤ) + n)
      = (T.card : ℤ) * (T.card + 1) := by
    induction T.card with
    | zero => simp
    | succ m ih =>
        rw [Finset.sum_range_succ, mul_add, ih]
        push_cast
        ring
  have : (T.card : ℤ) * (T.card + 1) ≤ 2 * ∑ x ∈ T, x := by
    rw [← hrange]; linarith [key]
  rwa [hcard, hsum] at this

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The total cost of a dial-aware pair of scan orders: the target is found at
position `posIn t` if the dial says "kept", at `posOut t` otherwise. -/
def scheduleTotal (K : Finset α) (posIn posOut : α → ℤ) : ℤ :=
  ∑ t : α, if t ∈ K then posIn t else posOut t

/-- **Optimality lemma.**  Whatever orders the algorithm chooses inside the two
branches of the dial reading, the total cost is at least the sum of the two
triangular numbers.  Hence no dial-aware scan can beat `avgSpeedup`. -/
theorem schedule_sum_lower_bound (K : Finset α) (posIn posOut : α → ℤ)
    (hInjIn : Set.InjOn posIn K) (hIn1 : ∀ t ∈ K, 1 ≤ posIn t)
    (hInjOut : Set.InjOn posOut ((univ : Finset α) \ K))
    (hOut1 : ∀ t ∈ (univ : Finset α) \ K, 1 ≤ posOut t) :
    (K.card : ℤ) * (K.card + 1)
        + (((univ : Finset α) \ K).card : ℤ) * ((((univ : Finset α) \ K).card : ℤ) + 1)
      ≤ 2 * scheduleTotal K posIn posOut := by
  classical
  have hsplit : scheduleTotal K posIn posOut
      = (∑ t ∈ K, posIn t) + ∑ t ∈ (univ : Finset α) \ K, posOut t := by
    have hf1 : (univ : Finset α).filter (fun x => x ∈ K) = K := by ext x; simp
    have hf2 : (univ : Finset α).filter (fun x => x ∉ K) = (univ : Finset α) \ K := by
      ext x; simp
    rw [scheduleTotal, Finset.sum_ite, hf1, hf2]
  have h1 := sum_ge_triangular K posIn hInjIn hIn1
  have hInjOut' : Set.InjOn posOut (((univ : Finset α) \ K : Finset α) : Set α) := by
    intro x hx y hy hxy
    exact hInjOut (by simpa using hx) (by simpa using hy) hxy
  have h2 := sum_ge_triangular ((univ : Finset α) \ K) posOut hInjOut' hOut1
  rw [hsplit]
  linarith

/-! ## The expected-position speedup -/

/-- Speedup under expected-position accounting for blocks of sizes `k` and `j`:
`(k+j)(k+j+1) / (k(k+1) + j(j+1))`. -/
noncomputable def avgSpeedup (k j : ℕ) : ℝ :=
  ((k : ℝ) + j) * ((k : ℝ) + j + 1) / ((k : ℝ) * (k + 1) + (j : ℝ) * (j + 1))

theorem avgSpeedup_denom_pos {k j : ℕ} (h : 0 < k + j) :
    0 < (k : ℝ) * (k + 1) + (j : ℝ) * (j + 1) := by
  rcases Nat.eq_zero_or_pos k with hk | hk
  · have hj : 0 < j := by omega
    have : (0:ℝ) < j := by exact_mod_cast hj
    have hk0 : (k:ℝ) = 0 := by exact_mod_cast hk
    rw [hk0]; nlinarith
  · have : (0:ℝ) < k := by exact_mod_cast hk
    have hj : (0:ℝ) ≤ j := by positivity
    nlinarith

/-- **The `2` barrier of expected-position accounting: strict.**  However the
dial splits the class space, the expected-position speedup is `< 2`. -/
theorem avgSpeedup_lt_two {k j : ℕ} (h : 0 < k + j) : avgSpeedup k j < 2 := by
  have hden := avgSpeedup_denom_pos h
  rw [avgSpeedup, div_lt_iff₀ hden]
  have hk : (0:ℝ) ≤ k := by positivity
  have hj : (0:ℝ) ≤ j := by positivity
  have hpos : (0:ℝ) < (k : ℝ) + j := by
    have : 0 < ((k + j : ℕ) : ℝ) := by exact_mod_cast h
    push_cast at this; linarith
  nlinarith [sq_nonneg ((k : ℝ) - j)]

/-- Balanced blocks give the exact value `(2m+1)/(m+1)`. -/
theorem avgSpeedup_balanced {m : ℕ} (hm : 0 < m) :
    avgSpeedup m m = (2 * (m : ℝ) + 1) / ((m : ℝ) + 1) := by
  have hmR : (0:ℝ) < m := by exact_mod_cast hm
  rw [avgSpeedup]
  rw [div_eq_div_iff (by nlinarith) (by linarith)]
  ring

/-- …and those values approach `2`: the expected-position barrier is sharp in
the limit, though never attained. -/
theorem avgSpeedup_balanced_tendsto_two :
    Filter.Tendsto (fun m : ℕ => (2 * (m : ℝ) + 1) / ((m : ℝ) + 1)) Filter.atTop (nhds 2) := by
  have h : ∀ m : ℕ, (2 * (m : ℝ) + 1) / ((m : ℝ) + 1) = 2 - 1 / ((m : ℝ) + 1) := by
    intro m
    have hm : ((m : ℝ) + 1) ≠ 0 := by positivity
    field_simp
    ring
  simp only [h]
  have h0 : Filter.Tendsto (fun m : ℕ => 1 / ((m : ℝ) + 1)) Filter.atTop (nhds 0) :=
    tendsto_one_div_add_atTop_nhds_zero_nat
  simpa using (tendsto_const_nhds (x := (2:ℝ)) (f := Filter.atTop (α := ℕ))).sub h0

/-- **The expected-position bound on realized speedup.**  The baseline scan
costs `(n+1)/2` on average; a dial-aware scan costs `scheduleTotal / n`.  By the
optimality lemma the resulting speedup is at most `avgSpeedup k j`, so
`avgSpeedup` is an upper bound over *all* dial-aware strategies. -/
theorem realized_speedup_le_avgSpeedup (K : Finset α) (posIn posOut : α → ℤ)
    (hInjIn : Set.InjOn posIn K) (hIn1 : ∀ t ∈ K, 1 ≤ posIn t)
    (hInjOut : Set.InjOn posOut ((univ : Finset α) \ K))
    (hOut1 : ∀ t ∈ (univ : Finset α) \ K, 1 ≤ posOut t)
    (hn : 0 < Fintype.card α) :
    ((Fintype.card α : ℝ) * ((Fintype.card α : ℝ) + 1))
        / (2 * (scheduleTotal K posIn posOut : ℝ))
      ≤ avgSpeedup K.card (((univ : Finset α) \ K).card) := by
  classical
  set k := K.card with hk
  set j := ((univ : Finset α) \ K).card with hj
  have hkj : k + j = Fintype.card α := by
    rw [hk, hj, Finset.card_sdiff, Finset.inter_univ, Finset.card_univ]
    have : K.card ≤ Fintype.card α := by
      simpa [Finset.card_univ] using Finset.card_le_univ K
    omega
  have hkjR : (k : ℝ) + j = (Fintype.card α : ℝ) := by exact_mod_cast hkj
  have hbound := schedule_sum_lower_bound K posIn posOut hInjIn hIn1 hInjOut hOut1
  have hboundR : (k : ℝ) * (k + 1) + (j : ℝ) * (j + 1)
      ≤ 2 * (scheduleTotal K posIn posOut : ℝ) := by
    exact_mod_cast hbound
  have hDpos : 0 < (k : ℝ) * (k + 1) + (j : ℝ) * (j + 1) :=
    avgSpeedup_denom_pos (by omega)
  have hnum : 0 ≤ (Fintype.card α : ℝ) * ((Fintype.card α : ℝ) + 1) := by positivity
  rw [avgSpeedup, hkjR]
  exact div_le_div_of_nonneg_left hnum hDpos hboundR

/-! ## The accounting gap -/

/-- **The gap is real.**  The worst-case-in-phase cap `4/3` is strictly below the
expected-position barrier `2`, and the latter is approached: for every `ε > 0`
some balanced dial has expected-position speedup `> 2 - ε`, while *no* dial ever
has worst-case-in-phase speedup above `4/3`. -/
theorem accounting_gap (ε : ℝ) (hε : 0 < ε) :
    (∀ θ : ℝ, speedup θ ≤ 4 / 3) ∧ (4 / 3 : ℝ) < 2 ∧
      ∃ m : ℕ, 0 < m ∧ 2 - ε < avgSpeedup m m ∧ avgSpeedup m m < 2 := by
  refine ⟨speedup_le_four_thirds, by norm_num, ?_⟩
  obtain ⟨m, hm⟩ := exists_nat_gt (1 / ε)
  refine ⟨m + 1, Nat.succ_pos m, ?_, avgSpeedup_lt_two (by omega)⟩
  have hm1 : (0:ℝ) < (m : ℝ) + 1 := by positivity
  have hεm : 1 / ((m : ℝ) + 1) < ε := by
    rw [div_lt_iff₀ hm1]
    have h1 : 1 / ε < (m : ℝ) := hm
    rw [div_lt_iff₀ hε] at h1
    nlinarith
  rw [avgSpeedup_balanced (Nat.succ_pos m)]
  push_cast
  have hval : (2 * ((m : ℝ) + 1) + 1) / (((m : ℝ) + 1) + 1) = 2 - 1 / ((m : ℝ) + 2) := by
    have h2 : ((m : ℝ) + 2) ≠ 0 := by positivity
    field_simp
    ring
  rw [hval]
  have : 1 / ((m : ℝ) + 2) < ε := lt_of_le_of_lt (by
    apply one_div_le_one_div_of_le hm1; linarith) hεm
  linarith

end ResidueDial