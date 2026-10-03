import Mathlib
import Probability.RamifiedTypeChannel

/-!
# RAMIFIED-CONTRIBUTION-IS-NEGLIGIBLE (FACT round-36 #1, paper 128)

Experiment: for `x² - 3` (ramified primes `{2, 3}`) the residue-to-type channel is
`I = 1.0020` bits on all primes versus `1.0000` on unramified primes only.  We prove that
this is a universal phenomenon of the counting channel:

* `card_mul_mutInfo_union` — exact decomposition of `N I_{U∪R}` into the parts;
* `abs_card_mul_mutInfo_union_le` — the ramified bracket
  `|N I_{U∪R} - |U| I_U - |R| I_R| ≤ 2 |R| (log₂ N + 1 / log 2)`;
* `ramified_contribution_negligible` —
  `|I_{U∪R} - I_U| ≤ (|R| / N) (3 log₂ N + 2 / log 2)` for *every* read-out pair;
* `tendsto_ramifiedBound`, `ramified_exclusion_justified` — the effect of a bounded
  number of ramified primes tends to `0`;
* `two_ramified_primes_negligible` — two ramified primes among `≥ 2¹⁶` primes move the
  channel by at most `0.002` bits.
-/

namespace Catalog.Probability.RamifiedTypeChannel

open Finset CyclicTypeChannel Catalog.Probability.D5TypeChannelCore

variable {α β γ : Type*}

/-- `log₂` is monotone on natural numbers (with the convention `log₂ 0 = 0`). -/
lemma logb_natCast_mono {m n : ℕ} (h : m ≤ n) : Real.logb 2 (m : ℝ) ≤ Real.logb 2 (n : ℝ) := by
  rcases Nat.eq_zero_or_pos m with rfl | hm
  · simp only [Nat.cast_zero, Real.logb_zero]
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp
    · exact Real.logb_nonneg (by norm_num) (by exact_mod_cast hn)
  · exact Real.logb_le_logb_of_le (by norm_num) (by exact_mod_cast hm) (by exact_mod_cast h)

/-- The mixing term `E(u, r) = (u+r) log₂ (u+r) - u log₂ u - r log₂ r` (that is, `(u+r)` times
the binary entropy of the ramified fraction) lies in `[0, r (log₂ (u+r) + 1 / log 2)]`. -/
lemma mixing_bounds (u r : ℕ) :
    0 ≤ ((u + r : ℕ) : ℝ) * Real.logb 2 ((u + r : ℕ) : ℝ) - u * Real.logb 2 u - r * Real.logb 2 r ∧
    ((u + r : ℕ) : ℝ) * Real.logb 2 ((u + r : ℕ) : ℝ) - u * Real.logb 2 u - r * Real.logb 2 r
      ≤ r * (Real.logb 2 ((u + r : ℕ) : ℝ) + 1 / Real.log 2) := by
  have hl2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hu := logb_natCast_mono (Nat.le_add_right u r)
  have hr := logb_natCast_mono (Nat.le_add_left r u)
  have hu0 : (0 : ℝ) ≤ u := Nat.cast_nonneg u
  have hr0 : (0 : ℝ) ≤ r := Nat.cast_nonneg r
  have hrr : 0 ≤ (r : ℝ) * Real.logb 2 r := by
    rcases Nat.eq_zero_or_pos r with h | h
    · simp [h]
    · exact mul_nonneg hr0 (Real.logb_nonneg (by norm_num) (by exact_mod_cast h))
  have huu : (u : ℝ) * Real.logb 2 ((u + r : ℕ) : ℝ) ≤ u * Real.logb 2 u + r / Real.log 2 := by
    rcases Nat.eq_zero_or_pos u with h | h
    · simp [h]; positivity
    · have hpos : (0 : ℝ) < u := by exact_mod_cast h
      have := logb_add_le hpos hr0
      push_cast
      calc (u : ℝ) * Real.logb 2 (u + r) ≤ u * (Real.logb 2 u + r / u / Real.log 2) :=
            mul_le_mul_of_nonneg_left this hu0
        _ = u * Real.logb 2 u + r / Real.log 2 := by field_simp
  push_cast at hu hr huu ⊢
  have e : (r : ℝ) / Real.log 2 = r * (1 / Real.log 2) := by ring
  have m1 : (u : ℝ) * Real.logb 2 u ≤ u * Real.logb 2 (u + r) := mul_le_mul_of_nonneg_left hu hu0
  have m2 : (r : ℝ) * Real.logb 2 r ≤ r * Real.logb 2 (u + r) := mul_le_mul_of_nonneg_left hr hr0
  rw [add_mul, mul_add]
  constructor
  · linarith
  · linarith

section Main

variable [DecidableEq α] [DecidableEq β] [DecidableEq γ]

/-- **Exact ramified decomposition.**  Splitting the sample of primes `U ∪ R` into the
unramified part `U` and the ramified part `R`, the size-weighted mutual information of the
full sample differs from the size-weighted informations of the two parts by the mixing
term minus the three fibre defects `D(f) = Λ_{U∪R}(f) - Λ_U(f) - Λ_R(f)`. -/
theorem card_mul_mutInfo_union (U R : Finset α) (g : α → β) (k : α → γ) :
    ((U ∪ R).card : ℝ) * mutInfo (U ∪ R) g k - U.card * mutInfo U g k - R.card * mutInfo R g k
      = (((U ∪ R).card : ℝ) * Real.logb 2 (U ∪ R).card - U.card * Real.logb 2 U.card
          - R.card * Real.logb 2 R.card)
        - (lam (U ∪ R) g - lam U g - lam R g) - (lam (U ∪ R) k - lam U k - lam R k)
        + (lam (U ∪ R) (fun x => (k x, g x)) - lam U (fun x => (k x, g x))
            - lam R (fun x => (k x, g x))) := by
  rw [card_mul_mutInfo, card_mul_mutInfo, card_mul_mutInfo]
  ring

/-- **The ramified bracket.**  The weighted information defect caused by the ramified
part is at most `2 |R| (log₂ N + 1 / log 2)` in absolute value. -/
theorem abs_card_mul_mutInfo_union_le {U R : Finset α} (h : Disjoint U R) (g : α → β)
    (k : α → γ) :
    |((U ∪ R).card : ℝ) * mutInfo (U ∪ R) g k - U.card * mutInfo U g k
        - R.card * mutInfo R g k|
      ≤ 2 * R.card * (Real.logb 2 (U ∪ R).card + 1 / Real.log 2) := by
  rw [card_mul_mutInfo_union U R]
  have hc : (U ∪ R).card = U.card + R.card := card_union_of_disjoint h
  obtain ⟨hE0, hE1⟩ := mixing_bounds U.card R.card
  rw [← hc] at hE0 hE1
  have g0 := lam_union_ge h g
  have g1 := lam_union_le h g
  have k0 := lam_union_ge h k
  have k1 := lam_union_le h k
  have p0 := lam_union_ge h (fun x => (k x, g x))
  have p1 := lam_union_le h (fun x => (k x, g x))
  rw [abs_le]
  constructor <;> linarith

omit [DecidableEq α] in
/-- The counting mutual information of a sub-sample is at most `log₂` of the full sample. -/
lemma mutInfo_le_logb_card_of_subset {S T : Finset α} (hST : S ⊆ T) (g : α → β) (k : α → γ) :
    mutInfo S g k ≤ Real.logb 2 T.card :=
  (mutInfo_le_uEnt S g k).trans
    ((uEnt_le_logb_card S g).trans (logb_natCast_mono (card_le_card hST)))

/-- **RAMIFIED-CONTRIBUTION-IS-NEGLIGIBLE.**  Adding a set `R` of ramified primes to a sample
`U` of unramified primes changes the counting mutual information of any type channel by at
most `(|R| / N) (3 log₂ N + 2 / log 2)`, where `N = |U ∪ R|`.  In particular, for a bounded
number of ramified primes the effect is `O(log N / N)` bits. -/
theorem ramified_contribution_negligible {U R : Finset α} (h : Disjoint U R) (g : α → β)
    (k : α → γ) :
    |mutInfo (U ∪ R) g k - mutInfo U g k|
      ≤ (R.card : ℝ) / (U ∪ R).card * (3 * Real.logb 2 (U ∪ R).card + 2 / Real.log 2) := by
  rcases (U ∪ R).eq_empty_or_nonempty with he | hne
  · have hU : U = ∅ := subset_empty.1 (he ▸ subset_union_left)
    subst hU
    simp [he]
  have hN : (0 : ℝ) < (U ∪ R).card := by exact_mod_cast card_pos.2 hne
  set N : ℝ := ((U ∪ R).card : ℝ) with hNdef
  set L : ℝ := Real.logb 2 (U ∪ R).card with hL
  have hc : ((U ∪ R).card : ℝ) = U.card + R.card := by exact_mod_cast card_union_of_disjoint h
  have hbr := abs_card_mul_mutInfo_union_le h g k
  have hU0 := mutInfo_nonneg U g k
  have hR0 := mutInfo_nonneg R g k
  have hU1 := mutInfo_le_logb_card_of_subset (subset_union_left : U ⊆ U ∪ R) g k
  have hR1 := mutInfo_le_logb_card_of_subset (subset_union_right : R ⊆ U ∪ R) g k
  have hr0 : (0 : ℝ) ≤ R.card := Nat.cast_nonneg _
  have hcross : |(R.card : ℝ) * (mutInfo R g k - mutInfo U g k)| ≤ R.card * L := by
    rw [abs_mul, abs_of_nonneg hr0]
    exact mul_le_mul_of_nonneg_left (abs_sub_le_iff.2 ⟨by linarith, by linarith⟩) hr0
  have hsplit : N * (mutInfo (U ∪ R) g k - mutInfo U g k)
      = (N * mutInfo (U ∪ R) g k - U.card * mutInfo U g k - R.card * mutInfo R g k)
        + R.card * (mutInfo R g k - mutInfo U g k) := by
    rw [hNdef, hc]; ring
  have key : |N * (mutInfo (U ∪ R) g k - mutInfo U g k)|
      ≤ R.card * (3 * L + 2 / Real.log 2) := by
    rw [hsplit]
    refine (abs_add_le _ _).trans ?_
    have : 2 * (R.card : ℝ) * (L + 1 / Real.log 2) + R.card * L
        = R.card * (3 * L + 2 / Real.log 2) := by ring
    linarith
  rw [abs_mul, abs_of_pos hN] at key
  rw [div_mul_eq_mul_div, le_div_iff₀ hN]
  linarith

/-- The bound of `ramified_contribution_negligible` for at most `r` ramified primes. -/
noncomputable def ramifiedBound (r N : ℕ) : ℝ :=
  (r : ℝ) / N * (3 * Real.logb 2 N + 2 / Real.log 2)

/-- Uniform version: with at most `r` ramified primes in a sample of size `N`, the change in
the mutual information is at most `ramifiedBound r N`. -/
theorem ramified_contribution_le_bound {U R : Finset α} (h : Disjoint U R) (g : α → β)
    (k : α → γ) {r : ℕ} (hr : R.card ≤ r) :
    |mutInfo (U ∪ R) g k - mutInfo U g k| ≤ ramifiedBound r (U ∪ R).card := by
  refine (ramified_contribution_negligible h g k).trans ?_
  unfold ramifiedBound
  have hl2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hL : 0 ≤ Real.logb 2 ((U ∪ R).card : ℝ) := logb_natCast_mono (Nat.zero_le _) |>.trans_eq'
    (by simp)
  have hpos : 0 ≤ 3 * Real.logb 2 ((U ∪ R).card : ℝ) + 2 / Real.log 2 := by positivity
  refine mul_le_mul_of_nonneg_right ?_ hpos
  exact div_le_div_of_nonneg_right (by exact_mod_cast hr) (Nat.cast_nonneg _)

/-- The ramified bound vanishes as the sample grows: `ramifiedBound r N → 0` as `N → ∞`. -/
theorem tendsto_ramifiedBound (r : ℕ) :
    Filter.Tendsto (fun N : ℕ => ramifiedBound r N) Filter.atTop (nhds 0) := by
  have hlog : Filter.Tendsto (fun x : ℝ => Real.log x ^ 1 / (1 * x + 0)) Filter.atTop
      (nhds 0) := Real.tendsto_pow_log_div_mul_add_atTop 1 0 1 one_ne_zero
  have hinv : Filter.Tendsto (fun x : ℝ => x⁻¹) Filter.atTop (nhds 0) :=
    tendsto_inv_atTop_zero
  have hreal : Filter.Tendsto (fun x : ℝ => (r : ℝ) * (3 / Real.log 2 *
      (Real.log x ^ 1 / (1 * x + 0)) + 2 / Real.log 2 * x⁻¹)) Filter.atTop (nhds 0) := by
    have := ((hlog.const_mul (3 / Real.log 2)).add (hinv.const_mul (2 / Real.log 2))).const_mul
      (r : ℝ)
    simpa using this
  refine (hreal.comp tendsto_natCast_atTop_atTop).congr' ?_
  filter_upwards with N
  simp only [Function.comp, ramifiedBound, Real.logb, pow_one, one_mul, add_zero]
  ring

/-- **Exclusion is justified, asymptotically.**  For every tolerance `ε > 0` and every
bound `r` on the number of ramified primes there is a sample size beyond which including
or excluding the ramified primes changes the type channel by at most `ε` bits. -/
theorem ramified_exclusion_justified (r : ℕ) {ε : ℝ} (hε : 0 < ε) :
    ∃ N₀ : ℕ, ∀ (U R : Finset α), Disjoint U R → R.card ≤ r → N₀ ≤ (U ∪ R).card →
      ∀ (g : α → β) (k : α → γ), |mutInfo (U ∪ R) g k - mutInfo U g k| ≤ ε := by
  obtain ⟨N₀, hN₀⟩ := Filter.eventually_atTop.1
    ((tendsto_ramifiedBound r).eventually (ge_mem_nhds hε))
  exact ⟨N₀, fun U R h hr hN g k => (ramified_contribution_le_bound h g k hr).trans (hN₀ _ hN)⟩

/-- **The paper-128 regime.**  Two ramified primes (`{2, 3}`) among at least `2¹⁶` primes
move the counting type channel by less than `0.002` bits. -/
theorem two_ramified_primes_negligible {U R : Finset α} (h : Disjoint U R) (g : α → β)
    (k : α → γ) (hr : R.card ≤ 2) (hN : 2 ^ 16 ≤ (U ∪ R).card) :
    |mutInfo (U ∪ R) g k - mutInfo U g k| ≤ 1 / 500 := by
  refine (ramified_contribution_le_bound h g k hr).trans ?_
  unfold ramifiedBound
  set x : ℝ := ((U ∪ R).card : ℝ) with hx
  have hx16 : (65536 : ℝ) ≤ x := by rw [hx]; exact_mod_cast hN
  have hxpos : 0 < x := by linarith
  have hl2 : 0.6931471803 < Real.log 2 := Real.log_two_gt_d9
  have hLpos : 0 < Real.log 2 := by linarith
  -- tangent-line bound for `log₂` at `2¹⁶`
  have htan : Real.logb 2 x ≤ 16 + (x - 65536) / 65536 / Real.log 2 := by
    have h1 := logb_add_le (u := 65536) (r := x - 65536) (by norm_num) (by linarith)
    have h2 : Real.logb 2 (65536 : ℝ) = 16 := by
      rw [show (65536 : ℝ) = 2 ^ (16 : ℕ) by norm_num, lb_pow]; norm_num
    rw [h2, show (65536 : ℝ) + (x - 65536) = x by ring] at h1
    exact h1
  have hexp : (2 : ℝ) / x * (3 * (16 + (x - 65536) / 65536 / Real.log 2) + 2 / Real.log 2)
      = 96 / x + 6 / (65536 * Real.log 2) - 2 / (x * Real.log 2) := by
    field_simp; ring
  have hA : 96 / x ≤ 96 / 65536 := div_le_div_of_nonneg_left (by norm_num) (by norm_num) hx16
  have hB : 6 / (65536 * Real.log 2) ≤ 6 / (65536 * 0.6931471803) :=
    div_le_div_of_nonneg_left (by norm_num) (by norm_num) (by linarith)
  have hC : 0 ≤ 2 / (x * Real.log 2) := by positivity
  calc (2 : ℕ) / x * (3 * Real.logb 2 x + 2 / Real.log 2)
      ≤ (2 : ℝ) / x * (3 * (16 + (x - 65536) / 65536 / Real.log 2) + 2 / Real.log 2) := by
        push_cast
        gcongr
    _ ≤ 1 / 500 := by rw [hexp]; norm_num at hA hB ⊢; linarith

end Main

end Catalog.Probability.RamifiedTypeChannel