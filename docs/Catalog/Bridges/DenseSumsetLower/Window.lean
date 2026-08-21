/-
# The threshold window: sharpening the upper constant from `3` to `3/2`

`Bridges.DeltaDenseSumsetAvoidance` constructs, for `0 < δ < 1` and large `n`, a `δ`-dense
set `S ⊆ [n]` containing no sumset `apF a d₁ k + apF b d₂ k` of two `k`-term progressions
once `k ≥ 3 log n / log (1/δ)`.  The first-moment computation behind it, however, is
lossy: the L-shaped witness has `2k - 1` points while the union bound only costs `n³`, so
the natural threshold is `(3/2) log n / log (1/δ)`.

This file extracts that gain:

* `SumsetWindow.pow_cond_sharp` — a version of `DeltaDense.pow_cond` with the fixed
  `1/2`-buffer replaced by an arbitrary relative buffer `θ`;
* `SumsetWindow.exists_dense_avoiding_ap_sumsets_sharp` — avoidance for
  `k ≥ (3/(2(1-θ))) log n / log (1/δ) + 2`;
* `SumsetWindow.eventually_avoiding_ap_sumsets_three_halves` — the asymptotic form:
  for every `ε > 0`, eventually in `n`, some `δ`-dense set avoids all progression sumsets
  of common length `≥ (3/2 + ε) log n / log (1/δ)`;
* `SumsetWindow.threshold_window` — the two-sided statement, combining this upper bound
  with the greedy lower bound of `Bridges.DenseSumsetLower.Density`.

Consequence: the extremal constant `C(δ)` of the problem satisfies, for small `δ`,
`1 - o(1) ≤ C(δ) ≤ 3/2 + o(1)` for progression sumsets, an improvement of the previously
recorded upper constant `3`.
-/
import Bridges.DeltaDenseSumsetAvoidance
import Bridges.DenseSumsetLower.Sharp

namespace SumsetWindow

open Finset Pointwise Filter DeltaDense

/-! ## A first-moment condition with an arbitrary buffer -/

/-- **Sharpened counting condition.**  With `m = ⌈δ n⌉`, the first-moment inequality
`n^c m^L < n^L` holds as soon as `L > c/(1-θ) · log n / log (1/δ)`, where `θ ∈ (0,1)`
absorbs the rounding loss `1/(δ n) ≤ θ log (1/δ)`. -/
theorem pow_cond_sharp (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) (n : ℕ) (hn2 : 2 ≤ n)
    (hδn : 1 ≤ δ * n) {θ : ℝ} (hθ1 : θ < 1)
    (hbig : 1 / (δ * n) ≤ θ * Real.log (1 / δ)) (c L : ℕ)
    (hL : ((c : ℝ) / (1 - θ)) * (Real.log n / Real.log (1 / δ)) < L) :
    n ^ c * (⌈δ * (n : ℝ)⌉₊) ^ L < n ^ L := by
  set l : ℝ := Real.log (1 / δ) with hl
  have hlpos : 0 < l := by
    rw [hl]; simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  have hn0 : (0 : ℝ) < n := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn2
    linarith
  have hlogn : 0 < Real.log n := Real.log_pos (by exact_mod_cast hn2)
  set m : ℕ := ⌈δ * (n : ℝ)⌉₊ with hm
  have hm1 : 1 ≤ m := by
    rw [hm]; exact Nat.one_le_ceil_iff.2 (by linarith)
  have hmR : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm1
  have hmlt : (m : ℝ) < δ * n + 1 := Nat.ceil_lt_add_one (by positivity)
  -- `log m ≤ log n - (1-θ) l`
  have hlogm : Real.log m ≤ Real.log n - (1 - θ) * l := by
    have step1 : Real.log m ≤ Real.log (δ * n + 1) :=
      Real.log_le_log (by linarith) (le_of_lt hmlt)
    have hfac : δ * (n : ℝ) + 1 = (δ * n) * (1 + 1 / (δ * n)) := by field_simp
    have step2 : Real.log (δ * n + 1) = Real.log (δ * n) + Real.log (1 + 1 / (δ * n)) := by
      rw [hfac, Real.log_mul (by positivity) (by positivity)]
    have step3 : Real.log (1 + 1 / (δ * n)) ≤ 1 / (δ * n) := by
      have := Real.log_le_sub_one_of_pos (x := 1 + 1 / (δ * n)) (by positivity)
      linarith
    have step4 : Real.log (δ * n) = Real.log n - l := by
      rw [Real.log_mul (ne_of_gt h0) (ne_of_gt hn0), hl]
      simp only [one_div, Real.log_inv]
      ring
    linarith
  have hLpos : (0 : ℝ) ≤ (L : ℝ) := Nat.cast_nonneg _
  have hkey : (c : ℝ) * Real.log n + (L : ℝ) * Real.log m < (L : ℝ) * Real.log n := by
    have h6 : (L : ℝ) * Real.log m ≤ (L : ℝ) * (Real.log n - (1 - θ) * l) :=
      mul_le_mul_of_nonneg_left hlogm hLpos
    have h7 : (c : ℝ) * Real.log n < (L : ℝ) * ((1 - θ) * l) := by
      have hstep : ((c : ℝ) / (1 - θ)) * (Real.log n / l) < (L : ℝ) := hL
      have hpos : (0 : ℝ) < (1 - θ) * l := mul_pos (by linarith) hlpos
      have hne1 : (1 - θ) ≠ 0 := by intro hcontra; linarith [hcontra]
      have hlne : l ≠ 0 := ne_of_gt hlpos
      have hmul := mul_lt_mul_of_pos_right hstep hpos
      have hexpand : ((c : ℝ) / (1 - θ)) * (Real.log n / l) * ((1 - θ) * l)
          = (c : ℝ) * Real.log n := by
        field_simp
      linarith [hexpand ▸ hmul]
    nlinarith [h6, h7]
  have hreal : (n : ℝ) ^ c * (m : ℝ) ^ L < (n : ℝ) ^ L := by
    have hx : (0 : ℝ) < (n : ℝ) ^ c * (m : ℝ) ^ L := by positivity
    have hy : (0 : ℝ) < (n : ℝ) ^ L := by positivity
    rw [← Real.log_lt_log_iff hx hy,
      Real.log_mul (by positivity) (by positivity), Real.log_pow, Real.log_pow, Real.log_pow]
    linarith [hkey]
  exact_mod_cast hreal

/-! ## The sharpened avoidance theorem -/

/-- **Sharpened progression-sumset avoidance.**  For `0 < δ < 1`, `n` with
`1/(δ n) ≤ θ log (1/δ)`, there is a `δ`-dense `S ⊆ [n]` containing no sumset of two
`k`-term progressions with positive common differences once
`k ≥ (3/(2(1-θ))) log n / log (1/δ) + 2`. -/
theorem exists_dense_avoiding_ap_sumsets_sharp (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {n : ℕ}
    (hn2 : 2 ≤ n) (hδn : 1 ≤ δ ^ 2 * n) {θ : ℝ} (hθ1 : θ < 1)
    (hbig : 1 / (δ * n) ≤ θ * Real.log (1 / δ)) :
    ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ a b d₁ d₂ k : ℕ, 0 < d₁ → 0 < d₂ →
        (3 / (2 * (1 - θ))) * (Real.log n / Real.log (1 / δ)) + 2 ≤ k →
        ¬ (apF a d₁ k + apF b d₂ k ⊆ S) := by
  have hlpos : 0 < Real.log (1 / δ) := by
    simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  have hn0 : (0 : ℝ) < n := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn2
    linarith
  have hδn1 : 1 ≤ δ * n := by nlinarith [hδn, h0, h1, hn0]
  have hR2 : 2 ≤ Real.log n / Real.log (1 / δ) := by
    have hle : (1 / δ) ^ 2 ≤ (n : ℝ) := by
      rw [div_pow, one_pow, div_le_iff₀ (by positivity)]
      linarith [hδn]
    have hlog := Real.log_le_log (by positivity) hle
    rw [Real.log_pow] at hlog
    rw [le_div_iff₀ hlpos]
    push_cast at hlog
    linarith
  set R : ℝ := Real.log n / Real.log (1 / δ) with hR
  set K : ℝ := 3 / (2 * (1 - θ)) with hK
  have hKpos : 0 < K := by rw [hK]; exact div_pos (by norm_num) (by linarith)
  set k₀ : ℕ := ⌈K * R⌉₊ + 1 with hk₀
  have hk₀ge : K * R + 1 ≤ (k₀ : ℝ) := by
    rw [hk₀]; push_cast; linarith [Nat.le_ceil (K * R)]
  have hk₀le : (k₀ : ℝ) ≤ K * R + 2 := by
    rw [hk₀]; push_cast
    have := Nat.ceil_lt_add_one (a := K * R) (by positivity)
    linarith
  have hk₀2 : 2 ≤ k₀ := by
    have hKR0 : 0 < K * R := mul_pos hKpos (by linarith)
    have h1c : 1 ≤ ⌈K * R⌉₊ := Nat.one_le_ceil_iff.2 hKR0
    rw [hk₀]; omega
  have hcast : ((2 * k₀ - 1 : ℕ) : ℝ) = 2 * (k₀ : ℝ) - 1 := by
    have hle : 1 ≤ 2 * k₀ := by omega
    push_cast [Nat.cast_sub hle]
    ring
  have hmn : ⌈δ * (n : ℝ)⌉₊ ≤ n := Nat.ceil_le.2 (by nlinarith)
  have hcond : n ^ 3 * (⌈δ * (n : ℝ)⌉₊) ^ (2 * k₀ - 1) < n ^ (2 * k₀ - 1) := by
    refine pow_cond_sharp δ h0 h1 n hn2 hδn1 hθ1 hbig 3 (2 * k₀ - 1) ?_
    rw [hcast]
    have hRpos : 0 < R := by linarith
    have hKR : (3 : ℝ) / (1 - θ) * R = 2 * (K * R) := by
      rw [hK]; field_simp
    push_cast
    rw [hKR]
    linarith [hk₀ge]
  obtain ⟨S, hSsub, hScard, hSno⟩ := exists_card_eq_no_grid hmn hk₀2 hcond
  refine ⟨S, hSsub, by rw [hScard]; exact Nat.le_ceil _, ?_⟩
  intro a b d₁ d₂ k hd₁ hd₂ hk hsub
  have hkR : (k₀ : ℝ) ≤ (k : ℝ) := le_trans hk₀le (by linarith)
  have hkk : k₀ ≤ k := by exact_mod_cast hkR
  exact hSno (a + b) d₁ d₂ hd₁ hd₂
    ((gridWitness_subset_add (by omega) hkk).trans hsub)

/-- **Asymptotic form: the constant `3/2`.**  For every `0 < δ < 1` and every `ε > 0`, for
all large `n` there is a `δ`-dense `S ⊆ [n]` containing no sumset of two progressions of
common length at least `(3/2 + ε) log n / log (1/δ)`. -/
theorem eventually_avoiding_ap_sumsets_three_halves (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1)
    {ε : ℝ} (hε : 0 < ε) :
    ∀ᶠ n : ℕ in atTop, ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ a b d₁ d₂ k : ℕ, 0 < d₁ → 0 < d₂ →
        (3 / 2 + ε) * (Real.log n / Real.log (1 / δ)) ≤ k →
        ¬ (apF a d₁ k + apF b d₂ k ⊆ S) := by
  have hlpos : 0 < Real.log (1 / δ) := by
    simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  -- choose the buffer `θ` so that `3/(2(1-θ)) ≤ 3/2 + ε/2`
  set ε' : ℝ := min ε 1 with hε'
  have hε'0 : 0 < ε' := lt_min hε zero_lt_one
  have hε'1 : ε' ≤ 1 := min_le_right _ _
  have hε'ε : ε' ≤ ε := min_le_left _ _
  set θ : ℝ := ε' / 8 with hθ
  have hθ0 : 0 < θ := by rw [hθ]; positivity
  have hθ1 : θ < 1 := by rw [hθ]; linarith
  have hKle : 3 / (2 * (1 - θ)) ≤ 3 / 2 + ε' / 2 := by
    rw [div_le_iff₀ (by rw [hθ]; nlinarith)]
    rw [hθ]
    nlinarith
  rw [eventually_atTop]
  refine ⟨max 2 (max ⌈1 / δ ^ 2⌉₊
      (max ⌈1 / (δ * (θ * Real.log (1 / δ)))⌉₊ ⌈Real.exp ((4 / ε') * Real.log (1 / δ))⌉₊)),
    fun n hn => ?_⟩
  have hn2 : 2 ≤ n := le_trans (le_max_left _ _) hn
  have hA : ⌈1 / δ ^ 2⌉₊ ≤ n := le_trans (le_trans (le_max_left _ _) (le_max_right 2 _)) hn
  have hB : ⌈1 / (δ * (θ * Real.log (1 / δ)))⌉₊ ≤ n :=
    le_trans (le_trans (le_trans (le_max_left _ _) (le_max_right _ _)) (le_max_right 2 _)) hn
  have hC : ⌈Real.exp ((4 / ε') * Real.log (1 / δ))⌉₊ ≤ n :=
    le_trans (le_trans (le_trans (le_max_right _ _) (le_max_right _ _)) (le_max_right 2 _)) hn
  have hn0 : (0 : ℝ) < n := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn2
    linarith
  have hδn : 1 ≤ δ ^ 2 * n := by
    have h1n : 1 / δ ^ 2 ≤ (n : ℝ) := le_trans (Nat.le_ceil _) (by exact_mod_cast hA)
    rw [div_le_iff₀ (by positivity)] at h1n
    linarith
  have hbig : 1 / (δ * n) ≤ θ * Real.log (1 / δ) := by
    have h2n : 1 / (δ * (θ * Real.log (1 / δ))) ≤ (n : ℝ) :=
      le_trans (Nat.le_ceil _) (by exact_mod_cast hB)
    rw [div_le_iff₀ (by positivity)] at h2n
    rw [div_le_iff₀ (by positivity)]
    nlinarith
  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_dense_avoiding_ap_sumsets_sharp δ h0 h1 hn2 hδn hθ1 hbig
  refine ⟨S, hSsub, hScard, ?_⟩
  intro a b d₁ d₂ k hd₁ hd₂ hk
  refine hSno a b d₁ d₂ k hd₁ hd₂ ?_
  set R : ℝ := Real.log n / Real.log (1 / δ) with hR
  have hR2 : 2 ≤ R := by
    have hle : (1 / δ) ^ 2 ≤ (n : ℝ) := by
      rw [div_pow, one_pow, div_le_iff₀ (by positivity)]
      linarith [hδn]
    have hlog := Real.log_le_log (by positivity) hle
    rw [Real.log_pow] at hlog
    rw [hR, le_div_iff₀ hlpos]
    push_cast at hlog
    linarith
  have hRbig : 4 / ε' ≤ R := by
    have hexp : Real.exp ((4 / ε') * Real.log (1 / δ)) ≤ (n : ℝ) :=
      le_trans (Nat.le_ceil _) (by exact_mod_cast hC)
    have hlog : (4 / ε') * Real.log (1 / δ) ≤ Real.log n :=
      (Real.le_log_iff_exp_le hn0).2 hexp
    rw [hR, le_div_iff₀ hlpos]
    exact hlog
  have h4 : ε' * (4 / ε') = 4 := by field_simp
  have hmul : ε' * (4 / ε') ≤ ε' * R := mul_le_mul_of_nonneg_left hRbig (le_of_lt hε'0)
  have hstep : (3 / (2 * (1 - θ))) * R + 2 ≤ (3 / 2 + ε) * R := by
    have h1' : (3 / (2 * (1 - θ))) * R ≤ (3 / 2 + ε' / 2) * R := by nlinarith
    nlinarith [hε'ε, hε'0]
  linarith

/-! ## The two-sided window -/

/-- **Two-sided threshold window.**  Fix `0 < δ < 1`, `ε > 0` and `c > 0` with
`c log (1/δ) < 1`.  Then for all large `n`:

* *(lower bound)* every `S ⊆ [n]` with `|S| ≥ δ n` contains a sumset `A + B` with
  `|A| = |B| = ⌊c log n⌋`;
* *(upper bound)* some `S ⊆ [n]` with `|S| ≥ δ n` contains no sumset of two arithmetic
  progressions of common length at least `(3/2 + ε) log n / log (1/δ)`.

So the extremal threshold for progression sumsets in `δ`-dense subsets of `[n]` lies
between `(1 - o(1)) log n / log (1/δ)` and `(3/2 + o(1)) log n / log (1/δ)`. -/
theorem threshold_window (δ c : ℝ) (h0 : 0 < δ) (h1 : δ < 1) (hc0 : 0 < c)
    (hc : c * Real.log (1 / δ) < 1) {ε : ℝ} (hε : 0 < ε) :
    ∀ᶠ n : ℕ in atTop,
      (∀ S : Finset ℕ, S ⊆ range n → δ * (n : ℝ) ≤ S.card →
        ∃ A B : Finset ℕ, A.card = ⌊c * Real.log n⌋₊ ∧ B.card = ⌊c * Real.log n⌋₊ ∧
          A + B ⊆ S) ∧
      (∃ S ⊆ range n, δ * n ≤ S.card ∧
        ∀ a b d₁ d₂ k : ℕ, 0 < d₁ → 0 < d₂ →
          (3 / 2 + ε) * (Real.log n / Real.log (1 / δ)) ≤ k →
          ¬ (apF a d₁ k + apF b d₂ k ⊆ S)) := by
  filter_upwards [DenseSumsetLower.eventually_exists_sumset_sharp h0 h1 hc0 hc,
    eventually_avoiding_ap_sumsets_three_halves δ h0 h1 hε] with n hlow hup
  exact ⟨hlow, hup⟩

end SumsetWindow