import Pythagorean.PrefixIndeterminacy

/-!
# No finite prefix determines an autocorrelation law either

The companion of `Pythagorean.PrefixIndeterminacy`.  Frequency statistics are only half of the
folklore claim about the digits of `π`, `e` and `√2`; the other half concerns *correlations*
between digits at a fixed lag.  Here we measure

`agreeCount x r M = #{m < M : dₘ(x) = dₘ₊ᵣ(x)}`,

the lag-`r` autocorrelation counting function, and show that the asymptotic law of `r ↦
agreeCount/M` is again completely undetermined by any finite prefix.

The new witness is the *alternating* tail

`altReal = 0.1213121412131215…` (digits `1,2` alternating, bumped by `1` at the lacunary
positions `2ⁱ - 1`),

which is irrational because it is a rational (period two) number plus the irrational lacunary
number `sparseReal`.  Grafted onto the prefix of any `x`, it has lag-1 autocorrelation `0` and
lag-2 autocorrelation `1`, whereas the graft of `denseReal` has autocorrelation `1` at *every*
lag.

## Main results

* `Pyth.ofDigits_add` — additivity of `Real.ofDigits` in the digit sequence.
* `Pyth.irrational_altReal` — the alternating witness is irrational.
* `Pyth.prefix_determines_no_autocorrelation_law` — the main theorem.
-/

namespace Pyth

open Filter Real

/-! ## Additivity of `Real.ofDigits` -/

/-- Digitwise addition of two digit sequences adds the corresponding real numbers. -/
theorem ofDigits_add (c d e : ℕ → Fin 10) (h : ∀ m, (e m : ℕ) = (c m : ℕ) + (d m : ℕ)) :
    Real.ofDigits e = Real.ofDigits c + Real.ofDigits d := by
  have hsum1 : Summable (Real.ofDigitsTerm c) := Real.summable_ofDigitsTerm
  have hsum2 : Summable (Real.ofDigitsTerm d) := Real.summable_ofDigitsTerm
  have hterm : ∀ m, Real.ofDigitsTerm e m = Real.ofDigitsTerm c m + Real.ofDigitsTerm d m := by
    intro m
    simp only [Real.ofDigitsTerm, h m]
    push_cast
    ring
  calc Real.ofDigits e = ∑' m, Real.ofDigitsTerm e m := rfl
    _ = ∑' m, (Real.ofDigitsTerm c m + Real.ofDigitsTerm d m) := tsum_congr hterm
    _ = Real.ofDigits c + Real.ofDigits d := hsum1.tsum_add hsum2

/-! ## The alternating witness -/

/-- The period-two digit sequence `1, 2, 1, 2, …`. -/
def altBase (m : ℕ) : Fin 10 := if m % 2 = 0 then 1 else 2

/-- The alternating sequence, bumped by one at the lacunary positions. -/
def altSeq (m : ℕ) : Fin 10 :=
  if IsPowTwoSucc m then (if m % 2 = 0 then 2 else 3) else altBase m

theorem altBase_le (m : ℕ) : (altBase m : ℕ) ≤ 8 := by
  unfold altBase; split <;> simp

theorem altSeq_le (m : ℕ) : (altSeq m : ℕ) ≤ 8 := by
  unfold altSeq altBase; split <;> [skip; skip] <;> split <;> simp

theorem altSeq_val (m : ℕ) : (altSeq m : ℕ) = (altBase m : ℕ) + (sparseSeq m : ℕ) := by
  unfold altSeq altBase sparseSeq
  by_cases h : IsPowTwoSucc m <;> by_cases h2 : m % 2 = 0 <;> simp [h, h2]

theorem altBase_periodic (m : ℕ) : altBase (m + 2) = altBase m := by
  unfold altBase
  simp [Nat.add_mod_right]

theorem altBase_ne (m : ℕ) : altBase m ≠ altBase (m + 1) := by
  unfold altBase
  rcases Nat.even_or_odd m with h | h
  · have h1 : m % 2 = 0 := Nat.even_iff.mp h
    have h2 : (m + 1) % 2 = 1 := by omega
    simp [h1, h2]
  · have h1 : m % 2 = 1 := Nat.odd_iff.mp h
    have h2 : (m + 1) % 2 = 0 := by omega
    simp [h1, h2]

/-- `0.1213121412131215…`: alternating digits with lacunary bumps. -/
noncomputable def altReal : ℝ := Real.ofDigits altSeq

theorem digits_altReal : Real.digits altReal 10 = altSeq := digits_ofDigits altSeq altSeq_le

theorem altReal_nonneg : 0 ≤ altReal := Real.ofDigits_nonneg _

theorem altReal_lt_one : altReal < 1 := ofDigits_lt_one_of_le_eight _ altSeq_le

theorem altReal_eq : altReal = Real.ofDigits altBase + sparseReal :=
  ofDigits_add altBase sparseSeq altSeq altSeq_val

/-- **The alternating witness is irrational**: it is a period-two rational plus the lacunary
irrational number. -/
theorem irrational_altReal : Irrational altReal := by
  have hbase : ¬ Irrational (Real.ofDigits altBase) := by
    refine not_irrational_ofDigits_of_eventually_periodic altBase 0 2 (by norm_num) (fun i => ?_)
    simpa using altBase_periodic i
  rw [Irrational, not_not] at hbase
  obtain ⟨q, hq⟩ := hbase
  rw [altReal_eq, ← hq]
  exact irrational_sparseReal.ratCast_add q

/-! ## Autocorrelation counting -/

/-- Number of positions `m < M` at which the decimal digits of `x` at distance `r` agree. -/
noncomputable def agreeCount (x : ℝ) (r M : ℕ) : ℕ :=
  ((Finset.range M).filter (fun m => Real.digits x 10 m = Real.digits x 10 (m + r))).card

/-- The lag-`r` autocorrelation density of the decimal digits of `x` equals `a`. -/
def AgreeDensity (x : ℝ) (r : ℕ) (a : ℝ) : Prop :=
  Tendsto (fun M : ℕ => (agreeCount x r M : ℝ) / M) atTop (nhds a)

theorem agreeCount_le (x : ℝ) (r M : ℕ) : agreeCount x r M ≤ M := by
  unfold agreeCount
  simpa using Finset.card_filter_le (Finset.range M) _

theorem agreeCount_add_disagree (x : ℝ) (r M : ℕ) :
    agreeCount x r M
      + ((Finset.range M).filter (fun m => ¬ Real.digits x 10 m = Real.digits x 10 (m + r))).card
      = M := by
  unfold agreeCount
  rw [Finset.card_filter_add_card_filter_not
    (p := fun m => Real.digits x 10 m = Real.digits x 10 (m + r))]
  exact Finset.card_range M

/-! ## Two limit criteria -/

theorem natLog_succ_le {K : ℕ} (hK : 1 ≤ K) : Nat.log 2 (K + 1) ≤ Nat.log 2 K + 1 := by
  have h1 : K + 1 ≤ K * 2 := by omega
  have h2 : Nat.log 2 (K + 1) ≤ Nat.log 2 (K * 2) := Nat.log_mono_right h1
  rwa [Nat.log_mul_base (by norm_num) (by omega)] at h2

theorem natLog_add_le (K : ℕ) (hK : 1 ≤ K) (r : ℕ) : Nat.log 2 (K + r) ≤ Nat.log 2 K + r := by
  induction r with
  | zero => simp
  | succ r ih =>
      have h1 : Nat.log 2 (K + r + 1) ≤ Nat.log 2 (K + r) + 1 := natLog_succ_le (by omega)
      have : K + (r + 1) = K + r + 1 := by omega
      rw [this]
      omega

/-- A counting function bounded by `a + c·log₂ M` has density zero. -/
theorem tendsto_ratio_zero {f : ℕ → ℕ} {a c : ℕ} (h : ∀ M, 1 ≤ M → f M ≤ a + c * Nat.log 2 M) :
    Tendsto (fun M : ℕ => (f M : ℝ) / M) atTop (nhds 0) := by
  have hlog := tendsto_natLog_div_atTop
  have hconst : Tendsto (fun M : ℕ => (a : ℝ) / M) atTop (nhds 0) :=
    tendsto_const_div_atTop_nhds_zero_nat _
  have hc : Tendsto (fun M : ℕ => (c : ℝ) * ((Nat.log 2 M : ℝ) / M)) atTop (nhds 0) := by
    simpa using hlog.const_mul (c : ℝ)
  have hsum : Tendsto (fun M : ℕ => (c : ℝ) * ((Nat.log 2 M : ℝ) / M) + (a : ℝ) / M) atTop
      (nhds (0 + 0)) := hc.add hconst
  rw [add_zero] at hsum
  refine squeeze_zero' ?_ ?_ hsum
  · filter_upwards [eventually_gt_atTop 0] with M hM
    positivity
  · filter_upwards [eventually_gt_atTop 0] with M hM
    have hM0 : (0:ℝ) < M := by exact_mod_cast hM
    have h1 : (f M : ℝ) ≤ (c : ℝ) * (Nat.log 2 M : ℝ) + (a : ℝ) := by
      have h2 := h M (by omega)
      have h3 : (f M : ℝ) ≤ ((a + c * Nat.log 2 M : ℕ) : ℝ) := by exact_mod_cast h2
      push_cast at h3
      linarith
    rw [mul_div_assoc', ← add_div]
    gcongr

/-- A counting function that misses at most `a + c·log₂ M` of the first `M` positions has
density one. -/
theorem tendsto_ratio_one {f : ℕ → ℕ} {a c : ℕ} (hle : ∀ M, f M ≤ M)
    (h : ∀ M, 1 ≤ M → M ≤ f M + (a + c * Nat.log 2 M)) :
    Tendsto (fun M : ℕ => (f M : ℝ) / M) atTop (nhds 1) := by
  set g : ℕ → ℕ := fun M => M - f M with hg
  have hgb : ∀ M, 1 ≤ M → g M ≤ a + c * Nat.log 2 M := by
    intro M hM
    have := h M hM
    have := hle M
    simp only [hg]
    omega
  have hgz : Tendsto (fun M : ℕ => (g M : ℝ) / M) atTop (nhds 0) := tendsto_ratio_zero hgb
  have hEq : ∀ᶠ M : ℕ in atTop, (f M : ℝ) / M = 1 - (g M : ℝ) / M := by
    filter_upwards [eventually_gt_atTop 0] with M hM
    have hM0 : (M : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
    have h1 : (g M : ℝ) + (f M : ℝ) = (M : ℝ) := by
      have : g M + f M = M := by simp only [hg]; have := hle M; omega
      exact_mod_cast this
    field_simp
    linarith
  have h5 : Tendsto (fun M : ℕ => 1 - (g M : ℝ) / M) atTop (nhds (1 - 0)) :=
    tendsto_const_nhds.sub hgz
  rw [sub_zero] at h5
  exact h5.congr' (hEq.mono fun M hM => hM.symm)

/-! ## The exceptional-set counting lemma -/

/-- If every element of a finite set `S ⊆ [0,M)` is either below `n`, or lands on a lacunary
position after subtracting the prefix length, or does so after a shift by `r`, then `S` has at
most `n + (log₂ M + 1) + (log₂ M + r + 1)` elements. -/
theorem card_exceptional_le {S : Finset ℕ} {n r M : ℕ} (hM : 1 ≤ M)
    (hSM : ∀ m ∈ S, m < M)
    (hS : ∀ m ∈ S, m < n ∨ IsPowTwoSucc (m - n) ∨ IsPowTwoSucc (m - n + r)) :
    S.card ≤ n + ((Nat.log 2 M + 1) + (Nat.log 2 M + r + 1)) := by
  have hsub : S ⊆ Finset.range n
      ∪ (((Finset.range M).filter IsPowTwoSucc).image (fun p => n + p)
      ∪ (((Finset.range (M + r)).filter IsPowTwoSucc).image (fun p => n + p - r))) := by
    intro m hm
    by_cases hmn : m < n
    · exact Finset.mem_union_left _ (Finset.mem_range.mpr hmn)
    · have hnm : n ≤ m := by omega
      have hmM := hSM m hm
      rcases hS m hm with h | h | h
      · exact absurd h hmn
      · refine Finset.mem_union_right _ (Finset.mem_union_left _ ?_)
        exact Finset.mem_image.mpr ⟨m - n, Finset.mem_filter.mpr
          ⟨Finset.mem_range.mpr (by omega), h⟩, by omega⟩
      · refine Finset.mem_union_right _ (Finset.mem_union_right _ ?_)
        exact Finset.mem_image.mpr ⟨m - n + r, Finset.mem_filter.mpr
          ⟨Finset.mem_range.mpr (by omega), h⟩, by omega⟩
  have hcard := Finset.card_le_card hsub
  have h1 := Finset.card_union_le (Finset.range n)
    ((((Finset.range M).filter IsPowTwoSucc).image (fun p => n + p))
      ∪ ((((Finset.range (M + r)).filter IsPowTwoSucc).image (fun p => n + p - r))))
  have h2 := Finset.card_union_le
    (((Finset.range M).filter IsPowTwoSucc).image (fun p => n + p))
    ((((Finset.range (M + r)).filter IsPowTwoSucc).image (fun p => n + p - r)))
  have h3 := Finset.card_image_le (s := (Finset.range M).filter IsPowTwoSucc)
    (f := fun p => n + p)
  have h4 := Finset.card_image_le (s := (Finset.range (M + r)).filter IsPowTwoSucc)
    (f := fun p => n + p - r)
  have h5 := card_powTwoSucc_le M
  have h6 := card_powTwoSucc_le (M + r)
  have h7 : Nat.log 2 (M + r) ≤ Nat.log 2 M + r := natLog_add_le M hM r
  simp only [Finset.card_range] at h1
  omega

/-! ## Autocorrelation of the grafted witnesses -/

/-- Prefix of `x`, then the alternating tail. -/
noncomputable def altGraft (x : ℝ) (n : ℕ) : ℝ := graft x n altReal

theorem digits_altGraft_tail (x : ℝ) (n m : ℕ) :
    Real.digits (altGraft x n) 10 (n + m) = altSeq m := by
  rw [altGraft, digits_graft_of_ge altReal_nonneg, digits_altReal]

theorem digits_altGraft_of_ge {x : ℝ} {n m : ℕ} (h : n ≤ m) :
    Real.digits (altGraft x n) 10 m = altSeq (m - n) := by
  have h2 := digits_altGraft_tail x n (m - n)
  rwa [show n + (m - n) = m by omega] at h2

theorem digits_denseGraft_of_ge {x : ℝ} {n m : ℕ} (h : n ≤ m) :
    Real.digits (denseGraft x n) 10 m = denseSeq (m - n) := by
  have h2 := digits_denseGraft_tail x n (m - n)
  rwa [show n + (m - n) = m by omega] at h2

theorem irrational_altGraft (x : ℝ) (n : ℕ) : Irrational (altGraft x n) :=
  irrational_graft irrational_altReal n

theorem digits_altGraft_prefix {x : ℝ} {n k : ℕ} (hk : k < n) :
    Real.digits (altGraft x n) 10 k = Real.digits x 10 k :=
  digits_graft_of_lt altReal_nonneg altReal_lt_one hk

/-- **Lag one: the alternating graft is anticorrelated.** -/
theorem agreeDensity_altGraft_one (x : ℝ) (n : ℕ) : AgreeDensity (altGraft x n) 1 0 := by
  refine tendsto_ratio_zero (a := n + 4) (c := 2) (fun M hM => ?_)
  have hbound : agreeCount (altGraft x n) 1 M
      ≤ n + ((Nat.log 2 M + 1) + (Nat.log 2 M + 1 + 1)) := by
    refine card_exceptional_le hM (fun m hm => Finset.mem_range.mp (Finset.mem_filter.mp hm).1)
      (fun m hm => ?_)
    obtain ⟨hmM, heq⟩ := Finset.mem_filter.mp hm
    rcases lt_or_ge m n with h | h
    · exact Or.inl h
    · right
      by_contra hc
      push_neg at hc
      obtain ⟨hc1, hc2⟩ := hc
      have e1 : Real.digits (altGraft x n) 10 m = altBase (m - n) := by
        rw [digits_altGraft_of_ge h]
        simp [altSeq, hc1]
      have e2 : Real.digits (altGraft x n) 10 (m + 1) = altBase (m - n + 1) := by
        rw [digits_altGraft_of_ge (by omega), show m + 1 - n = m - n + 1 by omega]
        simp [altSeq, hc2]
      rw [e1, e2] at heq
      exact altBase_ne (m - n) heq
  omega

/-- **Lag two: the same number is perfectly correlated.** -/
theorem agreeDensity_altGraft_two (x : ℝ) (n : ℕ) : AgreeDensity (altGraft x n) 2 1 := by
  refine tendsto_ratio_one (a := n + 5) (c := 2) (agreeCount_le _ _) (fun M hM => ?_)
  set D := ((Finset.range M).filter
    (fun m => ¬ Real.digits (altGraft x n) 10 m = Real.digits (altGraft x n) 10 (m + 2)))
    with hD
  have hDcard : D.card ≤ n + ((Nat.log 2 M + 1) + (Nat.log 2 M + 2 + 1)) := by
    refine card_exceptional_le hM (fun m hm => Finset.mem_range.mp (Finset.mem_filter.mp hm).1)
      (fun m hm => ?_)
    obtain ⟨hmM, hne⟩ := Finset.mem_filter.mp hm
    rcases lt_or_ge m n with h | h
    · exact Or.inl h
    · right
      by_contra hc
      push_neg at hc
      obtain ⟨hc1, hc2⟩ := hc
      refine hne ?_
      have e1 : Real.digits (altGraft x n) 10 m = altBase (m - n) := by
        rw [digits_altGraft_of_ge h]
        simp [altSeq, hc1]
      have e2 : Real.digits (altGraft x n) 10 (m + 2) = altBase (m - n + 2) := by
        rw [digits_altGraft_of_ge (by omega), show m + 2 - n = m - n + 2 by omega]
        simp [altSeq, hc2]
      rw [e1, e2, altBase_periodic]
  have hsum := agreeCount_add_disagree (altGraft x n) 2 M
  rw [← hD] at hsum
  omega

/-- **Every lag: the dense graft is perfectly correlated.** -/
theorem agreeDensity_denseGraft (x : ℝ) (n r : ℕ) : AgreeDensity (denseGraft x n) r 1 := by
  refine tendsto_ratio_one (a := n + r + 3) (c := 2) (agreeCount_le _ _) (fun M hM => ?_)
  set D := ((Finset.range M).filter
    (fun m => ¬ Real.digits (denseGraft x n) 10 m = Real.digits (denseGraft x n) 10 (m + r)))
    with hD
  have hDcard : D.card ≤ n + ((Nat.log 2 M + 1) + (Nat.log 2 M + r + 1)) := by
    refine card_exceptional_le hM (fun m hm => Finset.mem_range.mp (Finset.mem_filter.mp hm).1)
      (fun m hm => ?_)
    obtain ⟨hmM, hne⟩ := Finset.mem_filter.mp hm
    rcases lt_or_ge m n with h | h
    · exact Or.inl h
    · right
      by_contra hc
      push_neg at hc
      obtain ⟨hc1, hc2⟩ := hc
      refine hne ?_
      have e1 : Real.digits (denseGraft x n) 10 m = 1 := by
        rw [digits_denseGraft_of_ge h]
        simp [denseSeq, hc1]
      have e2 : Real.digits (denseGraft x n) 10 (m + r) = 1 := by
        rw [digits_denseGraft_of_ge (by omega), show m + r - n = m - n + r by omega]
        simp [denseSeq, hc2]
      rw [e1, e2]
  have hsum := agreeCount_add_disagree (denseGraft x n) r M
  rw [← hD] at hsum
  omega

/-! ## The main theorem of this file -/

/-- **No finite decimal prefix determines an autocorrelation law.**

For every real `x` and every prefix length `n` there are two irrational numbers `y`, `z`
sharing the first `n` decimal digits of `x` such that

* `y` has lag-1 autocorrelation density `0` but lag-2 autocorrelation density `1`;
* `z` has autocorrelation density `1` at *every* lag.

Thus neither the value of the autocorrelation at a given lag, nor its dependence on the lag,
is a function of any finite prefix. -/
theorem prefix_determines_no_autocorrelation_law (x : ℝ) (n : ℕ) :
    ∃ y z : ℝ,
      (∀ k < n, Real.digits y 10 k = Real.digits x 10 k) ∧
      (∀ k < n, Real.digits z 10 k = Real.digits x 10 k) ∧
      Irrational y ∧ Irrational z ∧
      AgreeDensity y 1 0 ∧ AgreeDensity y 2 1 ∧
      (∀ r : ℕ, AgreeDensity z r 1) := by
  refine ⟨altGraft x n, denseGraft x n, fun k hk => digits_altGraft_prefix hk,
    fun k hk => digits_graft_of_lt denseReal_nonneg denseReal_lt_one hk,
    irrational_altGraft x n, irrational_denseGraft x n,
    agreeDensity_altGraft_one x n, agreeDensity_altGraft_two x n,
    fun r => agreeDensity_denseGraft x n r⟩

/-- The Pythagorean-constant instance. -/
theorem sqrtTwo_prefix_determines_no_autocorrelation_law (n : ℕ) :
    ∃ y z : ℝ,
      (∀ k < n, Real.digits y 10 k = Real.digits (Real.sqrt 2) 10 k) ∧
      (∀ k < n, Real.digits z 10 k = Real.digits (Real.sqrt 2) 10 k) ∧
      Irrational y ∧ Irrational z ∧
      AgreeDensity y 1 0 ∧ AgreeDensity y 2 1 ∧
      (∀ r : ℕ, AgreeDensity z r 1) :=
  prefix_determines_no_autocorrelation_law (Real.sqrt 2) n

end Pyth