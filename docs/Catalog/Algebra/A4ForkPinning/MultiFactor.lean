/-
# The order-3 channel for `k` factors, and its collapse

The semiprime laws of `Semiprime.lean` are the case `k = 2` of a family.  Let
`N = p₁⋯p_{k+1}` be a product of `k+1` unramified primes of the `A₄`-field; the
dial `N mod 9` sees only the sum `s = Σ chi9(pᵢ) ∈ ℤ/3` of the cube classes.

* `A4ForkPinning.card_fiber_sum` — every fibre of the sum map
  `(ℤ/3)^{k+1} → ℤ/3` has exactly `3^k` points (proved by an explicit bijection);
* `A4ForkPinning.allSplitRate_eq_count` — hence `P(all factors split | s) = 3^{-k}`
  if `s = 0` and `0` otherwise: the "all split" fork is the `3^{-k}`-thinning of
  the pinned fork `[s = 0]`;
* `A4ForkPinning.info_all_split` — **the `k`-factor AND law**
  `I = H(3^{-(k+1)}) - (1/3)·H(3^{-k})`, generalising the semiprime value
  `H(1/9) - (1/3)H(1/3)`;
* `A4ForkPinning.info_all_split_strict` — it is a genuine leak: `0 < I < H(F)`;
* `A4ForkPinning.info_all_split_tendsto_zero` — **the channel collapses**:
  `I → 0` as the number of factors grows.  Quantitatively, the residue of a
  many-factor number tells one essentially nothing about its factors' splitting
  behaviour: the "factor-uselessness" of the pinned fork.
-/
import Algebra.A4ForkPinning.Information
import Algebra.A4ForkPinning.Semiprime

namespace A4ForkPinning

open Finset

/-! ## Fibres of the sum map on `(ℤ/3)^{k+1}` -/

/-- **Every fibre of the sum map has `3^k` points.**  (The last coordinate is free
once the sum is prescribed.) -/
theorem card_fiber_sum (k : ℕ) (t : ZMod 3) :
    (univ.filter (fun x : Fin (k + 1) → ZMod 3 => ∑ i, x i = t)).card = 3 ^ k := by
  classical
  have h : (univ.filter (fun x : Fin (k + 1) → ZMod 3 => ∑ i, x i = t)).card
      = (univ : Finset (Fin k → ZMod 3)).card := by
    refine Finset.card_bij' (fun x _ => fun i => x i.castSucc)
      (fun y _ => Fin.snoc y (t - ∑ i, y i)) ?_ ?_ ?_ ?_
    · intro a _; exact Finset.mem_univ _
    · intro b _
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      rw [Fin.sum_univ_castSucc]
      simp [Fin.snoc]
    · intro a ha
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha
      funext i
      refine Fin.lastCases ?_ ?_ i
      · simp only [Fin.snoc_last]
        rw [Fin.sum_univ_castSucc] at ha
        rw [← ha]; ring
      · intro j; simp [Fin.snoc_castSucc]
    · intro b _
      funext i
      simp [Fin.snoc]
  rw [h]
  simp

/-- The only tuple all of whose entries vanish sits in the fibre over `0`. -/
theorem card_all_zero (k : ℕ) (t : ZMod 3) :
    (univ.filter (fun x : Fin (k + 1) → ZMod 3 => (∑ i, x i = t) ∧ ∀ i, x i = 0)).card
      = if t = 0 then 1 else 0 := by
  classical
  by_cases ht : t = 0
  · subst ht
    rw [if_pos rfl]
    rw [Finset.card_eq_one]
    refine ⟨fun _ => 0, ?_⟩
    ext x
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
    constructor
    · rintro ⟨-, hx⟩; funext i; exact hx i
    · rintro rfl; exact ⟨by simp, fun i => rfl⟩
  · rw [if_neg ht, Finset.card_eq_zero]
    ext x
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.notMem_empty, iff_false,
      not_and]
    intro hs hx
    exact ht (by rw [← hs]; simp [hx])

/-! ## The `k`-factor AND channel -/

/-- Conditional probability that **all** `k+1` factors split, given the class of `N`. -/
noncomputable def allSplitRate (k : ℕ) : Fin 3 → ℝ :=
  fun i => (1 / 3 : ℝ) ^ k * (![1, 0, 0] : Fin 3 → ℝ) i

/-- The rate is the exact ratio of counts: one all-zero tuple among the `3^k` tuples
of the fibre. -/
theorem allSplitRate_eq_count (k : ℕ) (i : Fin 3) :
    allSplitRate k i
      = ((univ.filter (fun x : Fin (k + 1) → ZMod 3 =>
            (∑ j, x j = cls i) ∧ ∀ j, x j = 0)).card : ℝ)
        / ((univ.filter (fun x : Fin (k + 1) → ZMod 3 => ∑ j, x j = cls i)).card : ℝ) := by
  rw [card_fiber_sum, card_all_zero]
  fin_cases i <;> simp +decide [allSplitRate]

theorem allSplit_pinned_part : ∀ i : Fin 3,
    (![1, 0, 0] : Fin 3 → ℝ) i = 0 ∨ (![1, 0, 0] : Fin 3 → ℝ) i = 1 := by
  intro i; fin_cases i <;> norm_num

theorem avg_allSplit_pinned_part : avg w3 (![1, 0, 0] : Fin 3 → ℝ) = 1 / 3 := by
  simp [avg, w3, Fin.sum_univ_three]

/-- **The `k`-factor AND law.**  For `N` a product of `k+1` unramified primes,
`I(N mod 9 ; all factors split) = H(3^{-(k+1)}) - (1/3)·H(3^{-k})`.
For `k = 1` this is the semiprime value `H(1/9) - (1/3)H(1/3)`. -/
theorem info_all_split (k : ℕ) :
    info w3 (allSplitRate k) = hb ((1 / 3 : ℝ) ^ (k + 1)) - (1 / 3) * hb ((1 / 3 : ℝ) ^ k) := by
  have h := info_leak w3 (![1, 0, 0] : Fin 3 → ℝ) ((1 / 3 : ℝ) ^ k) allSplit_pinned_part
  rw [avg_allSplit_pinned_part] at h
  rw [show (1 / 3 : ℝ) ^ k * (1 / 3) = (1 / 3 : ℝ) ^ (k + 1) by rw [pow_succ]] at h
  exact h

/-- The `k`-factor AND fork always leaks strictly: `0 < I < H(F)`. -/
theorem info_all_split_strict (k : ℕ) (hk : 1 ≤ k) :
    0 < info w3 (allSplitRate k) ∧
      info w3 (allSplitRate k) < hb (avg w3 (allSplitRate k)) := by
  have hq1 : (1 / 3 : ℝ) ^ k < 1 := by
    apply pow_lt_one₀ (by norm_num) (by norm_num)
    omega
  have hq0 : 0 < (1 / 3 : ℝ) ^ k := by positivity
  exact info_leak_strict w3 (![1, 0, 0] : Fin 3 → ℝ) ((1 / 3 : ℝ) ^ k) allSplit_pinned_part
    hq0 hq1 (by rw [avg_allSplit_pinned_part]; norm_num)
    (by rw [avg_allSplit_pinned_part]; norm_num)

/-! ## Collapse of the channel -/

theorem continuous_nml : Continuous nml :=
  Real.continuous_negMulLog.div_const _

theorem continuous_hb : Continuous hb :=
  continuous_nml.add (continuous_nml.comp (continuous_const.sub continuous_id))

/-- **The channel dies.**  As the number of prime factors grows, the mutual
information between `N mod 9` and "all factors split" tends to `0`. -/
theorem info_all_split_tendsto_zero :
    Filter.Tendsto (fun k => info w3 (allSplitRate k)) Filter.atTop (nhds 0) := by
  have hpow : Filter.Tendsto (fun k : ℕ => (1 / 3 : ℝ) ^ k) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
  have hpow' : Filter.Tendsto (fun k : ℕ => (1 / 3 : ℝ) ^ (k + 1)) Filter.atTop (nhds 0) := by
    simpa using hpow.comp (Filter.tendsto_add_atTop_nat 1)
  have h1 : Filter.Tendsto (fun k : ℕ => hb ((1 / 3 : ℝ) ^ (k + 1))) Filter.atTop (nhds 0) := by
    have := (continuous_hb.tendsto 0).comp hpow'
    simpa [hb_zero] using this
  have h2 : Filter.Tendsto (fun k : ℕ => (1 / 3 : ℝ) * hb ((1 / 3 : ℝ) ^ k))
      Filter.atTop (nhds 0) := by
    have := (continuous_hb.tendsto 0).comp hpow
    have h3 : Filter.Tendsto (fun k : ℕ => hb ((1 / 3 : ℝ) ^ k)) Filter.atTop (nhds 0) := by
      simpa [hb_zero] using this
    simpa using h3.const_mul (1 / 3 : ℝ)
  have := h1.sub h2
  simpa [info_all_split] using this

end A4ForkPinning