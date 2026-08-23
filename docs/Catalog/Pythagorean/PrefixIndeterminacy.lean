import Pythagorean.SparseWitnesses

/-!
# No finite decimal prefix determines any asymptotic digit law

This is the main file of the development.  It formalises, for an *arbitrary* nonnegative real
number `x` (in particular for the Pythagorean constant `√2`, for `π` and for `e`), the
statement that **the first `n` decimal digits of `x` carry no information whatsoever about the
asymptotic behaviour of its expansion**.

Given `x ≥ 0` and `n`, the *graft* `graft x n t = (⌊x·10ⁿ⌋ + t)/10ⁿ` keeps the first `n`
digits of `x` and continues with the digits of `t ∈ [0,1)`.  Grafting the three tails
`sparseReal`, `denseReal` and `0` produces three numbers sharing the prefix of `x` but with
radically different global behaviour:

| witness | digit at `n` | rationality | nonzero-digit density | simply normal? |
|---|---|---|---|---|
| `sparseGraft x n` | `1` | irrational | `0` | no |
| `denseGraft x n`  | `2` | irrational | `1` | no |
| `ratGraft x n`    | `0` | rational   | `0` | no |

Hence any statistic computed from a finite prefix is empirical data about that prefix, never a
theorem about the number.  Conversely, irrationality *does* have digit content, but only the
one recorded in `Pyth.not_irrational_ofDigits_of_eventually_periodic`: it forbids eventual
periodicity, and nothing more.
-/

namespace Pyth

open Filter Real

/-! ## Unfolding `Real.digits` -/

theorem digits_eq (x : ℝ) (k : ℕ) :
    Real.digits x 10 k = Fin.ofNat 10 ⌊x * (10:ℝ) ^ (k + 1)⌋₊ := by
  simp [Real.digits]

theorem digits_val (x : ℝ) (k : ℕ) :
    (Real.digits x 10 k : ℕ) = ⌊x * (10:ℝ) ^ (k + 1)⌋₊ % 10 := by
  rw [digits_eq, Fin.val_ofNat]

/-! ## Grafting a tail onto a finite prefix -/

/-- `graft x n t` keeps the first `n` decimal digits of `x` and continues with `t ∈ [0,1)`. -/
noncomputable def graft (x : ℝ) (n : ℕ) (t : ℝ) : ℝ := ((⌊x * 10 ^ n⌋₊ : ℕ) + t) / 10 ^ n

theorem graft_nonneg {x t : ℝ} (ht : 0 ≤ t) (n : ℕ) : 0 ≤ graft x n t := by
  unfold graft; positivity

/-- **The prefix is preserved.**  The first `n` decimal digits of `graft x n t` are those
of `x`, for any tail `t ∈ [0,1)`. -/
theorem digits_graft_of_lt {x t : ℝ} (ht0 : 0 ≤ t) (ht1 : t < 1) {n k : ℕ} (hk : k < n) :
    Real.digits (graft x n t) 10 k = Real.digits x 10 k := by
  obtain ⟨j, hj⟩ : ∃ j, n = k + 1 + j := ⟨n - (k + 1), by omega⟩
  have hcast : ((10 ^ j : ℕ) : ℝ) = (10:ℝ) ^ j := by push_cast; ring
  have hjpos : (0:ℝ) < (10:ℝ) ^ j := by positivity
  have hnpos : (0:ℝ) < (10:ℝ) ^ n := by positivity
  have hn : (10:ℝ) ^ n = (10:ℝ) ^ (k + 1) * (10:ℝ) ^ j := by rw [hj, pow_add]
  have e1 : graft x n t * (10:ℝ) ^ (k + 1)
      = (((⌊x * 10 ^ n⌋₊ : ℕ) : ℝ) + t) / ((10 ^ j : ℕ) : ℝ) := by
    unfold graft
    rw [hcast, div_mul_eq_mul_div, div_eq_div_iff (ne_of_gt hnpos) (ne_of_gt hjpos), hn]
    ring
  have e2 : x * (10:ℝ) ^ (k + 1) = (x * (10:ℝ) ^ n) / ((10 ^ j : ℕ) : ℝ) := by
    rw [hcast, eq_div_iff (ne_of_gt hjpos), hn]
    ring
  have f1 : ⌊graft x n t * (10:ℝ) ^ (k + 1)⌋₊ = ⌊x * (10:ℝ) ^ n⌋₊ / 10 ^ j := by
    rw [e1, Nat.floor_div_natCast]
    congr 1
    rw [add_comm, Nat.floor_add_natCast ht0, Nat.floor_eq_zero.mpr ht1, zero_add]
  have f2 : ⌊x * (10:ℝ) ^ (k + 1)⌋₊ = ⌊x * (10:ℝ) ^ n⌋₊ / 10 ^ j := by
    rw [e2, Nat.floor_div_natCast]
  rw [digits_eq, digits_eq, f1, f2]

/-- **The tail is the graft.**  From position `n` on, the digits of `graft x n t` are the
digits of `t`. -/
theorem digits_graft_of_ge {x t : ℝ} (ht0 : 0 ≤ t) (n m : ℕ) :
    Real.digits (graft x n t) 10 (n + m) = Real.digits t 10 m := by
  set A : ℕ := ⌊x * 10 ^ n⌋₊ with hA
  have hpow : (0:ℝ) < (10:ℝ) ^ n := by positivity
  have e1 : graft x n t * (10:ℝ) ^ (n + m + 1)
      = t * (10:ℝ) ^ (m + 1) + ((A * 10 ^ (m + 1) : ℕ) : ℝ) := by
    unfold graft
    push_cast
    field_simp
    ring
  have hnn : 0 ≤ t * (10:ℝ) ^ (m + 1) := by positivity
  have f1 : ⌊graft x n t * (10:ℝ) ^ (n + m + 1)⌋₊
      = ⌊t * (10:ℝ) ^ (m + 1)⌋₊ + A * 10 ^ (m + 1) := by
    rw [e1, Nat.floor_add_natCast hnn]
  apply Fin.ext
  rw [digits_val, digits_val]
  rw [show n + m + 1 = n + m + 1 from rfl, f1]
  have : A * 10 ^ (m + 1) % 10 = 0 := by
    have : (10:ℕ) ∣ A * 10 ^ (m + 1) := ⟨A * 10 ^ m, by ring⟩
    omega
  omega

/-! ## The three witnesses grafted onto a prefix -/

/-- Prefix of `x`, then the lacunary tail: irrational, nonzero-digit density `0`. -/
noncomputable def sparseGraft (x : ℝ) (n : ℕ) : ℝ := graft x n sparseReal

/-- Prefix of `x`, then the everywhere-nonzero tail: irrational, nonzero-digit density `1`. -/
noncomputable def denseGraft (x : ℝ) (n : ℕ) : ℝ := graft x n denseReal

/-- Prefix of `x`, then zeros: a rational number. -/
noncomputable def ratGraft (x : ℝ) (n : ℕ) : ℝ := graft x n 0

theorem digits_sparseGraft_tail (x : ℝ) (n m : ℕ) :
    Real.digits (sparseGraft x n) 10 (n + m) = sparseSeq m := by
  rw [sparseGraft, digits_graft_of_ge sparseReal_nonneg, digits_sparseReal]

theorem digits_denseGraft_tail (x : ℝ) (n m : ℕ) :
    Real.digits (denseGraft x n) 10 (n + m) = denseSeq m := by
  rw [denseGraft, digits_graft_of_ge denseReal_nonneg, digits_denseReal]

theorem digits_ratGraft_tail (x : ℝ) (n m : ℕ) :
    Real.digits (ratGraft x n) 10 (n + m) = 0 := by
  rw [ratGraft, digits_graft_of_ge le_rfl]
  apply Fin.ext
  rw [digits_val]
  simp

/-- The three witnesses are distinguished already by their `n`-th digit. -/
theorem digits_at_n (x : ℝ) (n : ℕ) :
    Real.digits (sparseGraft x n) 10 n = 1 ∧ Real.digits (denseGraft x n) 10 n = 2 ∧
      Real.digits (ratGraft x n) 10 n = 0 := by
  refine ⟨?_, ?_, ?_⟩
  · have := digits_sparseGraft_tail x n 0
    rw [Nat.add_zero] at this
    rw [this]
    simp [sparseSeq, IsPowTwoSucc]
  · have := digits_denseGraft_tail x n 0
    rw [Nat.add_zero] at this
    rw [this]
    simp [denseSeq, IsPowTwoSucc]
  · have := digits_ratGraft_tail x n 0
    rwa [Nat.add_zero] at this

/-! ### Irrationality of the two irrational witnesses -/

theorem irrational_graft {x t : ℝ} (ht : Irrational t) (n : ℕ) : Irrational (graft x n t) := by
  have h1 : Irrational (((⌊x * (10:ℝ) ^ n⌋₊ : ℕ) : ℝ) + t) := by
    simpa [add_comm] using ht.natCast_add ⌊x * (10:ℝ) ^ n⌋₊
  have h2 : graft x n t = (((⌊x * (10:ℝ) ^ n⌋₊ : ℕ) : ℝ) + t) / ((10 ^ n : ℕ) : ℝ) := by
    unfold graft; push_cast; ring
  rw [h2]
  have hne : (10:ℕ) ^ n ≠ 0 := by positivity
  exact h1.div_natCast hne

theorem irrational_sparseGraft (x : ℝ) (n : ℕ) : Irrational (sparseGraft x n) :=
  irrational_graft irrational_sparseReal n

theorem irrational_denseGraft (x : ℝ) (n : ℕ) : Irrational (denseGraft x n) :=
  irrational_graft irrational_denseReal n

/-- The rational witness really is rational. -/
theorem not_irrational_ratGraft (x : ℝ) (n : ℕ) : ¬ Irrational (ratGraft x n) := by
  unfold ratGraft graft
  have : ((⌊x * 10 ^ n⌋₊ : ℕ) + (0:ℝ)) / 10 ^ n
      = (((⌊x * 10 ^ n⌋₊ : ℚ) / 10 ^ n : ℚ) : ℝ) := by
    push_cast
    ring
  rw [this]
  exact Rat.not_irrational _

/-! ### The digit statistics of the grafts -/

theorem nonzeroCount_sparseGraft_le (x : ℝ) (n M : ℕ) :
    nonzeroCount (sparseGraft x n) M ≤ n + (Nat.log 2 M + 1) := by
  have hsub : (Finset.range M).filter (fun m => Real.digits (sparseGraft x n) 10 m ≠ 0)
      ⊆ Finset.range n ∪ ((Finset.range M).filter IsPowTwoSucc).image (fun m => n + m) := by
    intro m hm
    obtain ⟨hmM, hne⟩ := Finset.mem_filter.mp hm
    have hmM' : m < M := Finset.mem_range.mp hmM
    rcases lt_or_ge m n with h | h
    · exact Finset.mem_union_left _ (Finset.mem_range.mpr h)
    · refine Finset.mem_union_right _ ?_
      have hd : Real.digits (sparseGraft x n) 10 m = sparseSeq (m - n) := by
        have h2 := digits_sparseGraft_tail x n (m - n)
        rwa [show n + (m - n) = m by omega] at h2
      have hpow : IsPowTwoSucc (m - n) := by
        by_contra hc
        refine hne ?_
        rw [hd]
        apply Fin.ext
        simpa using sparseSeq_eq_zero_of_not hc
      exact Finset.mem_image.mpr
        ⟨m - n, Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (by omega), hpow⟩, by omega⟩
  have hcard := Finset.card_le_card hsub
  have h1 := Finset.card_union_le (Finset.range n)
    (((Finset.range M).filter IsPowTwoSucc).image (fun m => n + m))
  have h2 := Finset.card_image_le (s := (Finset.range M).filter IsPowTwoSucc)
    (f := fun m => n + m)
  have h3 := card_powTwoSucc_le M
  simp only [Finset.card_range] at h1
  unfold nonzeroCount
  omega

theorem digitCount_zero_denseGraft_le (x : ℝ) (n M : ℕ) :
    digitCount (denseGraft x n) 0 M ≤ n := by
  have hsub : (Finset.range M).filter (fun m => Real.digits (denseGraft x n) 10 m = 0)
      ⊆ Finset.range n := by
    intro m hm
    obtain ⟨hmM, heq⟩ := Finset.mem_filter.mp hm
    by_contra hc
    have h : n ≤ m := Nat.not_lt.mp (fun hh => hc (Finset.mem_range.mpr hh))
    have hd : Real.digits (denseGraft x n) 10 m = denseSeq (m - n) := by
      have h2 := digits_denseGraft_tail x n (m - n)
      rwa [show n + (m - n) = m by omega] at h2
    exact denseSeq_ne_zero (m - n) (by rw [← hd]; exact heq)
  have := Finset.card_le_card hsub
  unfold digitCount
  simpa using this

theorem nonzeroDensity_sparseGraft (x : ℝ) (n : ℕ) : NonzeroDensity (sparseGraft x n) 0 :=
  nonzeroDensity_zero_of_log_bound (nonzeroCount_sparseGraft_le x n)

theorem nonzeroDensity_denseGraft (x : ℝ) (n : ℕ) : NonzeroDensity (denseGraft x n) 1 :=
  nonzeroDensity_one_of_zero_bound (digitCount_zero_denseGraft_le x n)

theorem not_simplyNormal_sparseGraft (x : ℝ) (n : ℕ) : ¬ SimplyNormalTen (sparseGraft x n) :=
  not_simplyNormal_of_density_zero (nonzeroDensity_sparseGraft x n)

theorem not_simplyNormal_denseGraft (x : ℝ) (n : ℕ) : ¬ SimplyNormalTen (denseGraft x n) :=
  not_simplyNormal_of_density_one (nonzeroDensity_denseGraft x n)

/-! ## The main theorem -/

/-- **No finite decimal prefix determines any asymptotic digit law.**

For every nonnegative real `x` and every length `n` there are three real numbers `y`, `z`, `w`
sharing the first `n` decimal digits of `x` — hence indistinguishable from `x` by *any*
statistic of the first `n` digits — such that

* `y` is irrational and the density of its nonzero digits is `0`;
* `z` is irrational and the density of its nonzero digits is `1`;
* `w` is rational;
* none of the three is simply normal, and they are pairwise different (their `n`-th digits
  are `1`, `2` and `0`).

So a finite prefix decides neither rationality, nor any digit frequency, nor normality. -/
theorem prefix_determines_no_digit_law (x : ℝ) (n : ℕ) :
    ∃ y z w : ℝ,
      (∀ k < n, Real.digits y 10 k = Real.digits x 10 k) ∧
      (∀ k < n, Real.digits z 10 k = Real.digits x 10 k) ∧
      (∀ k < n, Real.digits w 10 k = Real.digits x 10 k) ∧
      (Irrational y ∧ NonzeroDensity y 0 ∧ ¬ SimplyNormalTen y) ∧
      (Irrational z ∧ NonzeroDensity z 1 ∧ ¬ SimplyNormalTen z) ∧
      (¬ Irrational w) ∧
      Real.digits y 10 n = 1 ∧ Real.digits z 10 n = 2 ∧ Real.digits w 10 n = 0 := by
  obtain ⟨h1, h2, h3⟩ := digits_at_n x n
  exact ⟨sparseGraft x n, denseGraft x n, ratGraft x n,
    fun k hk => digits_graft_of_lt sparseReal_nonneg sparseReal_lt_one hk,
    fun k hk => digits_graft_of_lt denseReal_nonneg denseReal_lt_one hk,
    fun k hk => digits_graft_of_lt le_rfl one_pos hk,
    ⟨irrational_sparseGraft x n, nonzeroDensity_sparseGraft x n, not_simplyNormal_sparseGraft x n⟩,
    ⟨irrational_denseGraft x n, nonzeroDensity_denseGraft x n, not_simplyNormal_denseGraft x n⟩,
    not_irrational_ratGraft x n, h1, h2, h3⟩

/-! ## Instances: the Pythagorean constant, `π`, `e` -/

/-- The Pythagorean constant `√2`: no finite prefix of its decimal expansion determines any
asymptotic digit law. -/
theorem sqrtTwo_prefix_determines_no_digit_law (n : ℕ) :
    ∃ y z w : ℝ,
      (∀ k < n, Real.digits y 10 k = Real.digits (Real.sqrt 2) 10 k) ∧
      (∀ k < n, Real.digits z 10 k = Real.digits (Real.sqrt 2) 10 k) ∧
      (∀ k < n, Real.digits w 10 k = Real.digits (Real.sqrt 2) 10 k) ∧
      (Irrational y ∧ NonzeroDensity y 0 ∧ ¬ SimplyNormalTen y) ∧
      (Irrational z ∧ NonzeroDensity z 1 ∧ ¬ SimplyNormalTen z) ∧
      (¬ Irrational w) ∧
      Real.digits y 10 n = 1 ∧ Real.digits z 10 n = 2 ∧ Real.digits w 10 n = 0 :=
  prefix_determines_no_digit_law (Real.sqrt 2) n

/-- Same statement for `π`. -/
theorem pi_prefix_determines_no_digit_law (n : ℕ) :
    ∃ y z w : ℝ,
      (∀ k < n, Real.digits y 10 k = Real.digits Real.pi 10 k) ∧
      (∀ k < n, Real.digits z 10 k = Real.digits Real.pi 10 k) ∧
      (∀ k < n, Real.digits w 10 k = Real.digits Real.pi 10 k) ∧
      (Irrational y ∧ NonzeroDensity y 0 ∧ ¬ SimplyNormalTen y) ∧
      (Irrational z ∧ NonzeroDensity z 1 ∧ ¬ SimplyNormalTen z) ∧
      (¬ Irrational w) ∧
      Real.digits y 10 n = 1 ∧ Real.digits z 10 n = 2 ∧ Real.digits w 10 n = 0 :=
  prefix_determines_no_digit_law Real.pi n

/-- Same statement for `e`. -/
theorem exp_one_prefix_determines_no_digit_law (n : ℕ) :
    ∃ y z w : ℝ,
      (∀ k < n, Real.digits y 10 k = Real.digits (Real.exp 1) 10 k) ∧
      (∀ k < n, Real.digits z 10 k = Real.digits (Real.exp 1) 10 k) ∧
      (∀ k < n, Real.digits w 10 k = Real.digits (Real.exp 1) 10 k) ∧
      (Irrational y ∧ NonzeroDensity y 0 ∧ ¬ SimplyNormalTen y) ∧
      (Irrational z ∧ NonzeroDensity z 1 ∧ ¬ SimplyNormalTen z) ∧
      (¬ Irrational w) ∧
      Real.digits y 10 n = 1 ∧ Real.digits z 10 n = 2 ∧ Real.digits w 10 n = 0 :=
  prefix_determines_no_digit_law (Real.exp 1) n

/-! ## Irrationality does not imply normality -/

theorem graft_zero_zero (t : ℝ) : graft 0 0 t = t := by
  unfold graft
  simp

theorem sparseGraft_zero : sparseGraft 0 0 = sparseReal := graft_zero_zero sparseReal

theorem denseGraft_zero : denseGraft 0 0 = denseReal := graft_zero_zero denseReal

/-- **Irrationality does not imply simple normality.**  Two explicit irrational numbers whose
digit frequencies are as far from uniform as possible: all of `sparseReal`'s digit mass sits
on `0`, all of `denseReal`'s sits off `0`. -/
theorem irrational_not_simplyNormal :
    (Irrational sparseReal ∧ NonzeroDensity sparseReal 0 ∧ ¬ SimplyNormalTen sparseReal) ∧
    (Irrational denseReal ∧ NonzeroDensity denseReal 1 ∧ ¬ SimplyNormalTen denseReal) := by
  refine ⟨⟨irrational_sparseReal, ?_, ?_⟩, ⟨irrational_denseReal, ?_, ?_⟩⟩
  · rw [← sparseGraft_zero]; exact nonzeroDensity_sparseGraft 0 0
  · rw [← sparseGraft_zero]; exact not_simplyNormal_sparseGraft 0 0
  · rw [← denseGraft_zero]; exact nonzeroDensity_denseGraft 0 0
  · rw [← denseGraft_zero]; exact not_simplyNormal_denseGraft 0 0

end Pyth