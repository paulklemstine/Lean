import Pythagorean.DigitAutocorrelation

/-!
# Quantitative and cardinal strengthenings

Two refinements of the prefix-indeterminacy theorem.

* **Metric form.**  The grafted witnesses live within `10⁻ⁿ` of the number whose prefix they
  copy (`Pyth.abs_graft_sub_lt`).  Hence every nonnegative real — `√2`, `π`, `e` included —
  is approximated arbitrarily well by irrational numbers which are provably *not* simply
  normal, and equally well by rationals (`Pyth.exists_near_irrational_and_rational`).

* **Cardinal form.**  There are continuum many such witnesses for a given prefix
  (`Pyth.not_countable_prefix_class`): the witnesses are indexed by an arbitrary bit sequence
  `b : ℕ → Bool` written into the lacunary positions `2ⁱ - 1` as the digits `1` or `2`.  So a
  prefix of length `n` does not even cut the set of compatible non-normal irrationals down to
  a countable family.
-/

namespace Pyth

open Filter Real

/-! ## Metric form -/

/-- Grafting changes a number by less than `10⁻ⁿ`. -/
theorem abs_graft_sub_lt {x t : ℝ} (hx : 0 ≤ x) (ht0 : 0 ≤ t) (ht1 : t < 1) (n : ℕ) :
    |graft x n t - x| < 1 / 10 ^ n := by
  have hpow : (0:ℝ) < (10:ℝ) ^ n := by positivity
  have hA1 : ((⌊x * 10 ^ n⌋₊ : ℕ) : ℝ) ≤ x * 10 ^ n := Nat.floor_le (by positivity)
  have hA2 : x * (10:ℝ) ^ n < ((⌊x * 10 ^ n⌋₊ : ℕ) : ℝ) + 1 := Nat.lt_floor_add_one _
  have key : graft x n t - x = (((⌊x * 10 ^ n⌋₊ : ℕ) : ℝ) + t - x * 10 ^ n) / 10 ^ n := by
    unfold graft
    field_simp
  have h1 : |((⌊x * 10 ^ n⌋₊ : ℕ) : ℝ) + t - x * 10 ^ n| < 1 := by
    rw [abs_lt]
    constructor <;> linarith
  calc |graft x n t - x| = |((⌊x * 10 ^ n⌋₊ : ℕ) : ℝ) + t - x * 10 ^ n| / 10 ^ n := by
        rw [key, abs_div, abs_of_pos hpow]
    _ < 1 / 10 ^ n := by gcongr

/-- **Approximation form of prefix indeterminacy.**  Every nonnegative real is a limit both of
irrational, non-simply-normal numbers and of rationals; the two families are indistinguishable
from `x` on longer and longer prefixes. -/
theorem exists_near_irrational_and_rational (x : ℝ) (hx : 0 ≤ x) {ε : ℝ} (hε : 0 < ε) :
    ∃ y w : ℝ, |y - x| < ε ∧ |w - x| < ε ∧
      Irrational y ∧ NonzeroDensity y 0 ∧ ¬ SimplyNormalTen y ∧ ¬ Irrational w := by
  obtain ⟨n, hn⟩ : ∃ n : ℕ, (1 / 10 : ℝ) ^ n < ε := exists_pow_lt_of_lt_one hε (by norm_num)
  have hn' : (1 : ℝ) / 10 ^ n < ε := by
    rw [div_pow, one_pow] at hn
    exact hn
  refine ⟨sparseGraft x n, ratGraft x n, ?_, ?_, irrational_sparseGraft x n,
    nonzeroDensity_sparseGraft x n, not_simplyNormal_sparseGraft x n,
    not_irrational_ratGraft x n⟩
  · exact lt_trans (abs_graft_sub_lt hx sparseReal_nonneg sparseReal_lt_one n) hn'
  · exact lt_trans (abs_graft_sub_lt hx le_rfl one_pos n) hn'

/-! ## A continuum of witnesses -/

/-- The digit sequence carrying the bit stream `b` on the lacunary positions `2ⁱ - 1`:
digit `1` for `true`, digit `2` for `false`, and `0` off the lacunary set. -/
def bitSeq (b : ℕ → Bool) (m : ℕ) : Fin 10 :=
  if IsPowTwoSucc m then (if b (Nat.log 2 (m + 1)) then 1 else 2) else 0

theorem bitSeq_le (b : ℕ → Bool) (m : ℕ) : (bitSeq b m : ℕ) ≤ 8 := by
  unfold bitSeq
  split
  · split <;> simp
  · simp

theorem bitSeq_eq_zero_of_not {b : ℕ → Bool} {m : ℕ} (h : ¬ IsPowTwoSucc m) : bitSeq b m = 0 := by
  simp [bitSeq, h]

theorem bitSeq_ne_zero_of {b : ℕ → Bool} {m : ℕ} (h : IsPowTwoSucc m) : (bitSeq b m : ℕ) ≠ 0 := by
  unfold bitSeq
  simp only [h, if_true]
  split <;> simp

/-- The real number carrying the bit stream `b`. -/
noncomputable def bitReal (b : ℕ → Bool) : ℝ := Real.ofDigits (bitSeq b)

theorem digits_bitReal (b : ℕ → Bool) : Real.digits (bitReal b) 10 = bitSeq b :=
  digits_ofDigits (bitSeq b) (bitSeq_le b)

theorem bitReal_nonneg (b : ℕ → Bool) : 0 ≤ bitReal b := Real.ofDigits_nonneg _

theorem bitReal_lt_one (b : ℕ → Bool) : bitReal b < 1 :=
  ofDigits_lt_one_of_le_eight _ (bitSeq_le b)

/-- Every bit stream produces an irrational number: the lacunary gaps are arbitrarily long. -/
theorem irrational_bitReal (b : ℕ → Bool) : Irrational (bitReal b) := by
  refine irrational_ofDigits_of_gaps (bitSeq b) (bitSeq_le b) (fun L => ?_)
  refine ⟨2 ^ (L + 2), ?_, 2 ^ (2 ^ (L + 2) + L) - 1, ?_, ?_⟩
  · intro j hj1 hj2
    have hnot : ¬ IsPowTwoSucc j := by
      refine not_isPowTwoSucc_of_between (N := L + 2) (by omega) ?_
      have hL : L + 1 < 2 ^ (L + 1) := Nat.lt_two_pow_self
      have h2 : 2 ^ (L + 2) = 2 * 2 ^ (L + 1) := by ring
      have h3 : 2 ^ (L + 3) = 2 * 2 ^ (L + 2) := by ring
      have h4 : (2:ℕ) ^ (L + 1) ≤ 2 ^ (L + 2) := Nat.pow_le_pow_right (by norm_num) (by omega)
      omega
    simp [bitSeq_eq_zero_of_not (b := b) hnot]
  · have h := Nat.lt_two_pow_self (n := 2 ^ (L + 2) + L)
    omega
  · exact bitSeq_ne_zero_of (isPowTwoSucc_pow _)

/-! ### Lacunary grafts -/

/-- The nonzero digits of a graft with lacunary tail are confined to the prefix and to the
`log₂ M` lacunary positions. -/
theorem nonzeroCount_graft_le_of_lacunary {x t : ℝ} (ht0 : 0 ≤ t)
    (hzero : ∀ m, ¬ IsPowTwoSucc m → Real.digits t 10 m = 0) (n M : ℕ) :
    nonzeroCount (graft x n t) M ≤ n + (Nat.log 2 M + 1) := by
  have hsub : (Finset.range M).filter (fun m => Real.digits (graft x n t) 10 m ≠ 0)
      ⊆ Finset.range n ∪ ((Finset.range M).filter IsPowTwoSucc).image (fun m => n + m) := by
    intro m hm
    obtain ⟨hmM, hne⟩ := Finset.mem_filter.mp hm
    have hmM' : m < M := Finset.mem_range.mp hmM
    rcases lt_or_ge m n with h | h
    · exact Finset.mem_union_left _ (Finset.mem_range.mpr h)
    · refine Finset.mem_union_right _ ?_
      have hd : Real.digits (graft x n t) 10 m = Real.digits t 10 (m - n) := by
        have h2 := digits_graft_of_ge (x := x) ht0 n (m - n)
        rwa [show n + (m - n) = m by omega] at h2
      have hpow : IsPowTwoSucc (m - n) := by
        by_contra hc
        exact hne (by rw [hd]; exact hzero _ hc)
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

/-- Prefix of `x`, then the tail carrying the bit stream `b`. -/
noncomputable def bitGraft (x : ℝ) (n : ℕ) (b : ℕ → Bool) : ℝ := graft x n (bitReal b)

theorem digits_bitGraft_tail (x : ℝ) (n : ℕ) (b : ℕ → Bool) (m : ℕ) :
    Real.digits (bitGraft x n b) 10 (n + m) = bitSeq b m := by
  rw [bitGraft, digits_graft_of_ge (bitReal_nonneg b), digits_bitReal]

theorem irrational_bitGraft (x : ℝ) (n : ℕ) (b : ℕ → Bool) : Irrational (bitGraft x n b) :=
  irrational_graft (irrational_bitReal b) n

theorem nonzeroDensity_bitGraft (x : ℝ) (n : ℕ) (b : ℕ → Bool) :
    NonzeroDensity (bitGraft x n b) 0 := by
  refine nonzeroDensity_zero_of_log_bound (n := n) (fun M => ?_)
  refine nonzeroCount_graft_le_of_lacunary (bitReal_nonneg b) (fun m hm => ?_) n M
  rw [digits_bitReal]
  exact bitSeq_eq_zero_of_not hm

theorem not_simplyNormal_bitGraft (x : ℝ) (n : ℕ) (b : ℕ → Bool) :
    ¬ SimplyNormalTen (bitGraft x n b) :=
  not_simplyNormal_of_density_zero (nonzeroDensity_bitGraft x n b)

/-- Different bit streams give different reals: the stream is read back off the digits. -/
theorem bitGraft_injective (x : ℝ) (n : ℕ) : Function.Injective (bitGraft x n) := by
  intro b b' hbb'
  funext i
  by_contra hne
  have hlog : Nat.log 2 (2 ^ i - 1 + 1) = i := by
    have h1 : (1:ℕ) ≤ 2 ^ i := Nat.one_le_two_pow
    rw [show 2 ^ i - 1 + 1 = 2 ^ i by omega, Nat.log_pow (by norm_num)]
  have hpow : IsPowTwoSucc (2 ^ i - 1) := isPowTwoSucc_pow i
  have h1 := digits_bitGraft_tail x n b (2 ^ i - 1)
  have h2 := digits_bitGraft_tail x n b' (2 ^ i - 1)
  rw [hbb'] at h1
  rw [h1] at h2
  simp only [bitSeq, hpow, if_true, hlog] at h2
  rcases Bool.eq_false_or_eq_true (b i) with hb | hb <;>
    rcases Bool.eq_false_or_eq_true (b' i) with hb' | hb' <;>
    simp [hb, hb'] at h2 hne

/-- **Continuum many witnesses.**  For every real `x` and every prefix length `n`, the set of
reals that agree with `x` on the first `n` decimal digits, are irrational, have nonzero-digit
density `0` and are not simply normal, is uncountable. -/
theorem not_countable_prefix_class (x : ℝ) (n : ℕ) :
    ¬ Set.Countable {y : ℝ | (∀ k < n, Real.digits y 10 k = Real.digits x 10 k) ∧
      Irrational y ∧ NonzeroDensity y 0 ∧ ¬ SimplyNormalTen y} := by
  have hmem : ∀ b : ℕ → Bool, bitGraft x n b ∈
      {y : ℝ | (∀ k < n, Real.digits y 10 k = Real.digits x 10 k) ∧
        Irrational y ∧ NonzeroDensity y 0 ∧ ¬ SimplyNormalTen y} := by
    intro b
    refine ⟨fun k hk => digits_graft_of_lt (bitReal_nonneg b) (bitReal_lt_one b) hk,
      irrational_bitGraft x n b, nonzeroDensity_bitGraft x n b, not_simplyNormal_bitGraft x n b⟩
  have hbool : ¬ Countable (ℕ → Bool) := by
    rw [← Cardinal.mk_le_aleph0_iff]
    have h : Cardinal.mk (ℕ → Bool) = Cardinal.continuum := by simp
    rw [h]
    exact Cardinal.aleph0_lt_continuum.not_ge
  intro hc
  have hsub : Countable
      ↥{y : ℝ | (∀ k < n, Real.digits y 10 k = Real.digits x 10 k) ∧
        Irrational y ∧ NonzeroDensity y 0 ∧ ¬ SimplyNormalTen y} := hc.to_subtype
  have hinj : Function.Injective (fun b => (⟨bitGraft x n b, hmem b⟩ :
      {y : ℝ | (∀ k < n, Real.digits y 10 k = Real.digits x 10 k) ∧
        Irrational y ∧ NonzeroDensity y 0 ∧ ¬ SimplyNormalTen y})) := fun a b hab =>
    bitGraft_injective x n (congrArg Subtype.val hab)
  exact hbool hinj.countable

/-- The Pythagorean-constant instance of the cardinal statement. -/
theorem not_countable_sqrtTwo_prefix_class (n : ℕ) :
    ¬ Set.Countable {y : ℝ | (∀ k < n, Real.digits y 10 k = Real.digits (Real.sqrt 2) 10 k) ∧
      Irrational y ∧ NonzeroDensity y 0 ∧ ¬ SimplyNormalTen y} :=
  not_countable_prefix_class (Real.sqrt 2) n

end Pyth