/-
# δ-dense sets avoiding sumsets of GAPs of *arbitrary* dimension

`Bridges/GAPSumsetAvoidance.lean` proves the sharpness statement for sumsets of two
generalised arithmetic progressions whose dimensions satisfy `1 ≤ r + s ≤ 9`.  The
dimension cap is an artefact of the counting lemma `DeltaDense.pow_cond`, which is stated
with the fixed absolute slack `δ n log(1/δ) ≥ 100` and consequently only tolerates
exponents `c ≤ 10` in the union bound `n^c`.

This file removes the cap.  The key is `DeltaDense.pow_cond_uniform`: the first-moment
condition `n^c · ⌈δn⌉^L < n^L` holds for **every** `c`, provided the size hypothesis is
scaled to `δ n log(1/δ) ≥ 100 (c+1)` — a hypothesis that for fixed `δ` is still satisfied
by all large `n`.  Feeding this into the staircase union bound gives:

* `DeltaDense.exists_dense_avoiding_gap_sumsets_sharp` — for every dimension pair `(r,s)`
  with `N = r + s ≥ 1` there is a `δ`-dense `S ⊆ [n]` avoiding every sumset of a
  dimension-`r` and a dimension-`s` GAP of common side length
  `k ≥ (1 + 3/(2N))·log n / log(1/δ) + 1`.  The constant therefore **decreases to `1`** as
  the dimension grows; for `N = 1` it is `5/2 + o(1)`.
* `DeltaDense.exists_dense_avoiding_gap_sumsets_all_dim` — the uniform form with the
  single constant `C(δ) = 3` valid for *all* dimensions, no cap.
* `DeltaDense.exists_dense_no_sumset_with_gap_all_dim` — the `r = 0` case: an arbitrary
  nonempty first summand and a GAP of arbitrary dimension.
* `DeltaDense.eventually_exists_dense_avoiding_gap_sumsets_all_dim` — the `Filter.atTop`
  packaging: for fixed `δ` and fixed dimensions, the conclusion holds for all large `n`.
-/
import Bridges.GAPSumsetAvoidance

namespace DeltaDense

open Finset Pointwise

/-! ## The counting condition, uniformly in the exponent -/

/-- **Uniform first-moment condition.**  With `m = ⌈δ n⌉` the inequality
`n^c · m^L < n^L` holds for *every* exponent `c` — no upper bound on `c` — as soon as
`L ≥ (c + 1/2)·log n / log(1/δ)` and `n` is large enough that
`δ n log(1/δ) ≥ 100 (c + 1)`.

This is the cap-free version of `DeltaDense.pow_cond`, whose fixed slack `100` forces
`c ≤ 10`.  The point is that the rounding loss `log ⌈δn⌉ ≤ log(δn) + 1/(δn)` must be small
compared with `log(1/δ)/(c+1)`, and this is exactly what the scaled hypothesis provides. -/
theorem pow_cond_uniform (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) (n : ℕ) (hn2 : 2 ≤ n)
    (hδn : 1 ≤ δ * n) (c : ℕ) (hbig : 100 * ((c : ℝ) + 1) ≤ δ * n * Real.log (1 / δ))
    (L : ℕ) (hL : ((c : ℝ) + 1 / 2) * (Real.log n / Real.log (1 / δ)) ≤ L) :
    n ^ c * (⌈δ * (n : ℝ)⌉₊) ^ L < n ^ L := by
  set l : ℝ := Real.log (1 / δ) with hl
  have hlpos : 0 < l := by
    rw [hl]; simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  have hn0 : (0 : ℝ) < n := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn2
    linarith
  have hlogn : 0 < Real.log n := Real.log_pos (by exact_mod_cast hn2)
  have hcR : (0 : ℝ) ≤ (c : ℝ) := Nat.cast_nonneg _
  set q : ℝ := 100 * ((c : ℝ) + 1) with hq
  have hqpos : 0 < q := by rw [hq]; linarith
  set m : ℕ := ⌈δ * (n : ℝ)⌉₊ with hm
  have hm1 : 1 ≤ m := by
    rw [hm]; exact Nat.one_le_ceil_iff.2 (by linarith)
  have hmR : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm1
  have hmlt : (m : ℝ) < δ * n + 1 := Nat.ceil_lt_add_one (by positivity)
  -- the rounding estimate, with the loss measured against `l / q`
  have hlogm : Real.log m ≤ Real.log n - l + l / q := by
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
    have step5 : 1 / (δ * (n : ℝ)) ≤ l / q := by
      rw [div_le_div_iff₀ (by positivity) hqpos]
      nlinarith [hbig]
    linarith
  have hLnn : (0 : ℝ) ≤ (L : ℝ) := Nat.cast_nonneg _
  have hw : ((c : ℝ) + 1 / 2) * Real.log n ≤ (L : ℝ) * l := by
    refine (div_le_iff₀ hlpos).1 ?_
    calc ((c : ℝ) + 1 / 2) * Real.log n / l
        = ((c : ℝ) + 1 / 2) * (Real.log n / l) := by ring
      _ ≤ (L : ℝ) := hL
  have hkey : (c : ℝ) * Real.log n + (L : ℝ) * Real.log m < (L : ℝ) * Real.log n := by
    have h6 : (L : ℝ) * Real.log m ≤ (L : ℝ) * (Real.log n - l + l / q) :=
      mul_le_mul_of_nonneg_left hlogm hLnn
    have h7 : (L : ℝ) * (Real.log n - l + l / q)
        = (L : ℝ) * Real.log n - ((L : ℝ) * l - ((L : ℝ) * l) / q) := by
      field_simp
      ring
    -- the numeric heart: `q·c·log n < (L·l)·(q-1)`, because `q/2 > c + 1/2`
    have hmain : q * ((c : ℝ) * Real.log n) < ((L : ℝ) * l) * (q - 1) := by
      have hq1 : (0 : ℝ) < q - 1 := by rw [hq]; linarith
      have hstep := mul_le_mul_of_nonneg_right hw (le_of_lt hq1)
      nlinarith [hlogn, hcR, hstep]
    have hxq : q * (((L : ℝ) * l / q) * (q - 1)) = ((L : ℝ) * l) * (q - 1) := by field_simp
    have hdiv : (c : ℝ) * Real.log n < ((L : ℝ) * l / q) * (q - 1) :=
      lt_of_mul_lt_mul_left (by rw [hxq]; exact hmain) (le_of_lt hqpos)
    have heq : ((L : ℝ) * l / q) * (q - 1) = (L : ℝ) * l - ((L : ℝ) * l) / q := by field_simp
    rw [heq] at hdiv
    rw [h7] at h6
    linarith
  have hreal : (n : ℝ) ^ c * (m : ℝ) ^ L < (n : ℝ) ^ L := by
    have hx : (0 : ℝ) < (n : ℝ) ^ c * (m : ℝ) ^ L := by positivity
    have hy : (0 : ℝ) < (n : ℝ) ^ L := by positivity
    rw [← Real.log_lt_log_iff hx hy,
      Real.log_mul (by positivity) (by positivity), Real.log_pow, Real.log_pow, Real.log_pow]
    linarith [hkey]
  exact_mod_cast hreal

/-! ## The main theorem: no dimension restriction -/

/-- **Sharpness for GAPs of arbitrary dimension, with the sharper constant.**

Let `0 < δ < 1`, let `r, s` be dimensions with `N = r + s ≥ 1`, and let `n` be large:
`δ² n ≥ 1` and `δ n log(1/δ) ≥ 100 (N + 2)`.  Then there is `S ⊆ [n]` with `|S| ≥ δ n`
such that for **all** generalised arithmetic progressions `A` of dimension `r` and `B` of
dimension `s`, with arbitrary positive generators and common side length

`k ≥ (1 + 3/(2N))·log n / log(1/δ) + 1`,

the sumset `A + B` is not contained in `S`.

The witness is again the `(N(k-1)+1)`-point staircase of `A + B`, indexed by the `N + 1`
parameters `(t, d 0, …, d (N-1))`; the union bound costs `n^{N+1}`, and
`pow_cond_uniform` converts this into the stated length requirement.  Note that the
constant `1 + 3/(2N)` tends to `1` as the dimension grows: higher-dimensional
progressions are *easier* to avoid, because their staircases are longer while the number
of parameters grows only linearly. -/
theorem exists_dense_avoiding_gap_sumsets_sharp (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {n : ℕ}
    (hn2 : 2 ≤ n) (hδn : 1 ≤ δ ^ 2 * n) {r s : ℕ} (hrs1 : 1 ≤ r + s)
    (hbig : 100 * ((r : ℝ) + s + 2) ≤ δ * n * Real.log (1 / δ)) :
    ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ (a b k : ℕ) (d e : ℕ → ℕ), (∀ j < r, 0 < d j) → (∀ j < s, 0 < e j) →
        (1 + 3 / (2 * ((r : ℝ) + s))) * (Real.log n / Real.log (1 / δ)) + 1 ≤ k →
        ¬ (gapF a k d r + gapF b k e s ⊆ S) := by
  have hlpos : 0 < Real.log (1 / δ) := by
    simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  have hn0 : (0 : ℝ) < n := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn2
    linarith
  have hδn1 : 1 ≤ δ * n := by nlinarith [hδn, h0, h1, hn0]
  -- `n ≥ (1/δ)²`, hence `log n ≥ 2 log(1/δ)`
  have hR2 : 2 ≤ Real.log n / Real.log (1 / δ) := by
    have hle : (1 / δ) ^ 2 ≤ (n : ℝ) := by
      rw [div_pow, one_pow, div_le_iff₀ (by positivity)]
      linarith [hδn]
    have hlog := Real.log_le_log (by positivity) hle
    rw [Real.log_pow] at hlog
    rw [le_div_iff₀ hlpos]
    push_cast at hlog
    linarith
  set R : ℝ := Real.log n / Real.log (1 / δ) with hRdef
  set N : ℕ := r + s with hN
  have hNR : (1 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hrs1
  have hNpos : (0 : ℝ) < (N : ℝ) := by linarith
  have hNcast : (N : ℝ) = (r : ℝ) + s := by rw [hN]; push_cast; ring
  set k₀ : ℕ := ⌈(1 + 3 / (2 * (N : ℝ))) * R + 1⌉₊ with hk₀
  have hk₀ge : (1 + 3 / (2 * (N : ℝ))) * R + 1 ≤ (k₀ : ℝ) := Nat.le_ceil _
  have hfrac : 0 < 3 / (2 * (N : ℝ)) := by positivity
  have hk₀2 : 2 ≤ k₀ := by
    have : (2 : ℝ) ≤ (k₀ : ℝ) := by nlinarith [hk₀ge, hR2, hfrac]
    exact_mod_cast this
  have hcast : ((N * (k₀ - 1) + 1 : ℕ) : ℝ) = (N : ℝ) * ((k₀ : ℝ) - 1) + 1 := by
    have hle : 1 ≤ k₀ := by omega
    push_cast [Nat.cast_sub hle]
    ring
  have hmn : ⌈δ * (n : ℝ)⌉₊ ≤ n := Nat.ceil_le.2 (by nlinarith)
  have hcond : n ^ (N + 1) * (⌈δ * (n : ℝ)⌉₊) ^ (N * (k₀ - 1) + 1)
      < n ^ (N * (k₀ - 1) + 1) := by
    refine pow_cond_uniform δ h0 h1 n hn2 hδn1 (N + 1) ?_ (N * (k₀ - 1) + 1) ?_
    · push_cast
      rw [hNcast]
      linarith [hbig]
    · rw [hcast]
      push_cast
      -- `N (k₀ - 1) + 1 ≥ (N + 3/2) R` since `k₀ - 1 ≥ (1 + 3/(2N)) R`
      have hstep : (N : ℝ) * ((1 + 3 / (2 * (N : ℝ))) * R) = (N : ℝ) * R + (3 / 2) * R := by
        field_simp
      have h1' : (N : ℝ) * ((1 + 3 / (2 * (N : ℝ))) * R) ≤ (N : ℝ) * ((k₀ : ℝ) - 1) :=
        mul_le_mul_of_nonneg_left (by linarith [hk₀ge]) (le_of_lt hNpos)
      rw [hstep] at h1'
      nlinarith [h1', hR2, hNR]
  obtain ⟨S, hSsub, hScard, hSno⟩ := exists_card_eq_no_staircase hmn hk₀2 hcond
  refine ⟨S, hSsub, by rw [hScard]; exact Nat.le_ceil _, ?_⟩
  intro a b k d e hd he hk hsub
  have hkk : k₀ ≤ k := by
    refine Nat.ceil_le.2 ?_
    rw [hNcast]
    exact hk
  have hdpos : ∀ j < N, 0 < dcat d e r j := by
    intro j hj
    rw [dcat]
    by_cases hjr : j < r
    · simpa [hjr] using hd j hjr
    · simp only [if_neg hjr]
      exact he _ (by omega)
  refine hSno (a + b) (dcat d e r) hdpos ?_
  refine subset_trans (staircase_subset_gapF_add (by omega) r s) (subset_trans ?_ hsub)
  exact Finset.add_subset_add (gapF_mono_side hkk r) (gapF_mono_side hkk s)

/-- **The uniform constant `C(δ) = 3`, with no restriction on the dimension.**

For every `0 < δ < 1`, all dimensions `r, s` with `r + s ≥ 1`, and all `n` with
`δ² n ≥ 1` and `δ n log(1/δ) ≥ 100 (r + s + 2)`, there is `S ⊆ [n]` with `|S| ≥ δ n`
containing no sumset of a dimension-`r` and a dimension-`s` generalised arithmetic
progression of common side length `k ≥ 3 log n / log(1/δ)`.

This is `exists_dense_avoiding_gap_sumsets_sharp` combined with the elementary inequality
`(1 + 3/(2N))·R + 1 ≤ 3R` (valid because `R ≥ 2` and `N ≥ 1`); it removes the hypothesis
`r + s ≤ 9` of `DeltaDense.exists_dense_avoiding_gap_sumsets`. -/
theorem exists_dense_avoiding_gap_sumsets_all_dim (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {n : ℕ}
    (hn2 : 2 ≤ n) (hδn : 1 ≤ δ ^ 2 * n) {r s : ℕ} (hrs1 : 1 ≤ r + s)
    (hbig : 100 * ((r : ℝ) + s + 2) ≤ δ * n * Real.log (1 / δ)) :
    ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ (a b k : ℕ) (d e : ℕ → ℕ), (∀ j < r, 0 < d j) → (∀ j < s, 0 < e j) →
        3 * (Real.log n / Real.log (1 / δ)) ≤ k →
        ¬ (gapF a k d r + gapF b k e s ⊆ S) := by
  have hlpos : 0 < Real.log (1 / δ) := by
    simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  have hn0 : (0 : ℝ) < n := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn2
    linarith
  have hR2 : 2 ≤ Real.log n / Real.log (1 / δ) := by
    have hle : (1 / δ) ^ 2 ≤ (n : ℝ) := by
      rw [div_pow, one_pow, div_le_iff₀ (by positivity)]
      linarith [hδn]
    have hlog := Real.log_le_log (by positivity) hle
    rw [Real.log_pow] at hlog
    rw [le_div_iff₀ hlpos]
    push_cast at hlog
    linarith
  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_dense_avoiding_gap_sumsets_sharp δ h0 h1 hn2 hδn hrs1 hbig
  refine ⟨S, hSsub, hScard, fun a b k d e hd he hk => hSno a b k d e hd he ?_⟩
  set R : ℝ := Real.log n / Real.log (1 / δ) with hRdef
  have hNR : (1 : ℝ) ≤ (r : ℝ) + s := by
    have : (1 : ℝ) ≤ ((r + s : ℕ) : ℝ) := by exact_mod_cast hrs1
    push_cast at this
    linarith
  have hfrac : 3 / (2 * ((r : ℝ) + s)) ≤ 3 / 2 := by
    rw [div_le_div_iff₀ (by linarith) (by norm_num)]
    linarith
  have hRpos : (0 : ℝ) < R := by linarith
  nlinarith [hk, hR2, hfrac, hRpos]

/-- **Arbitrary first summand, arbitrary dimension.**  The `r = 0` case: the same `S`
avoids `A + B` for a completely arbitrary nonempty finite `A` and a generalised
arithmetic progression `B` of *any* dimension `r ≥ 1` and side length
`k ≥ 3 log n / log(1/δ)`. -/
theorem exists_dense_no_sumset_with_gap_all_dim (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {n : ℕ}
    (hn2 : 2 ≤ n) (hδn : 1 ≤ δ ^ 2 * n) {r : ℕ} (hr1 : 1 ≤ r)
    (hbig : 100 * ((r : ℝ) + 2) ≤ δ * n * Real.log (1 / δ)) :
    ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ (A : Finset ℕ) (b k : ℕ) (e : ℕ → ℕ), A.Nonempty → (∀ j < r, 0 < e j) →
        3 * (Real.log n / Real.log (1 / δ)) ≤ k →
        ¬ (A + gapF b k e r ⊆ S) := by
  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_dense_avoiding_gap_sumsets_all_dim δ h0 h1 hn2 hδn (r := 0) (s := r) (by omega)
      (by push_cast; linarith [hbig])
  refine ⟨S, hSsub, hScard, ?_⟩
  intro A b k e hA he hk hsub
  obtain ⟨a, ha⟩ := hA
  refine hSno a b k (fun _ => 0) e (by omega) he hk ?_
  refine subset_trans (Finset.add_subset_add_right ?_) hsub
  simpa [gapF] using ha

/-- Asymptotic packaging: for every `0 < δ < 1` and every fixed pair of dimensions
`r, s` with `r + s ≥ 1`, for all sufficiently large `n` there is a `δ`-dense subset of
`[n]` containing no sumset of a dimension-`r` and a dimension-`s` generalised arithmetic
progression of common side length at least `3 log n / log(1/δ)`. -/
theorem eventually_exists_dense_avoiding_gap_sumsets_all_dim (δ : ℝ) (h0 : 0 < δ)
    (h1 : δ < 1) {r s : ℕ} (hrs1 : 1 ≤ r + s) :
    ∀ᶠ n : ℕ in Filter.atTop, ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ (a b k : ℕ) (d e : ℕ → ℕ), (∀ j < r, 0 < d j) → (∀ j < s, 0 < e j) →
        3 * (Real.log n / Real.log (1 / δ)) ≤ k →
        ¬ (gapF a k d r + gapF b k e s ⊆ S) := by
  have hlpos : 0 < Real.log (1 / δ) := by
    simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  rw [Filter.eventually_atTop]
  refine ⟨max 2 (max ⌈1 / δ ^ 2⌉₊ ⌈100 * ((r : ℝ) + s + 2) / (δ * Real.log (1 / δ))⌉₊),
    fun n hn => ?_⟩
  have hn2 : 2 ≤ n := le_trans (le_max_left _ _) hn
  have hA : ⌈1 / δ ^ 2⌉₊ ≤ n := le_trans (le_trans (le_max_left _ _) (le_max_right 2 _)) hn
  have hB : ⌈100 * ((r : ℝ) + s + 2) / (δ * Real.log (1 / δ))⌉₊ ≤ n :=
    le_trans (le_trans (le_max_right _ _) (le_max_right 2 _)) hn
  have hδn : 1 ≤ δ ^ 2 * n := by
    have h1n : 1 / δ ^ 2 ≤ (n : ℝ) := le_trans (Nat.le_ceil _) (by exact_mod_cast hA)
    rw [div_le_iff₀ (by positivity)] at h1n
    linarith
  have hbig : 100 * ((r : ℝ) + s + 2) ≤ δ * n * Real.log (1 / δ) := by
    have h2n : 100 * ((r : ℝ) + s + 2) / (δ * Real.log (1 / δ)) ≤ (n : ℝ) :=
      le_trans (Nat.le_ceil _) (by exact_mod_cast hB)
    rw [div_le_iff₀ (by positivity)] at h2n
    nlinarith [h2n]
  exact exists_dense_avoiding_gap_sumsets_all_dim δ h0 h1 hn2 hδn hrs1 hbig

/-! ## Different side lengths: the `min{|A|,|B|}` form of the conjecture -/

/-- **Unequal side lengths.**  The two generalised progressions need not have the same
side length: it suffices that the *smaller* of the two side lengths is at least
`3 log n / log(1/δ)`, since a GAP of side `k` contains the GAP of side `min k k'` with the
same base and generators. -/
theorem exists_dense_avoiding_gap_sumsets_min_side (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {n : ℕ}
    (hn2 : 2 ≤ n) (hδn : 1 ≤ δ ^ 2 * n) {r s : ℕ} (hrs1 : 1 ≤ r + s)
    (hbig : 100 * ((r : ℝ) + s + 2) ≤ δ * n * Real.log (1 / δ)) :
    ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ (a b k k' : ℕ) (d e : ℕ → ℕ), (∀ j < r, 0 < d j) → (∀ j < s, 0 < e j) →
        3 * (Real.log n / Real.log (1 / δ)) ≤ min k k' →
        ¬ (gapF a k d r + gapF b k' e s ⊆ S) := by
  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_dense_avoiding_gap_sumsets_all_dim δ h0 h1 hn2 hδn hrs1 hbig
  refine ⟨S, hSsub, hScard, ?_⟩
  intro a b k k' d e hd he hk hsub
  refine hSno a b (min k k') d e hd he (by exact_mod_cast hk) ?_
  refine subset_trans (Finset.add_subset_add (gapF_mono_side (Nat.min_le_left k k') r)
    (gapF_mono_side (Nat.min_le_right k k') s)) hsub

/-- **The conjecture's shape for arithmetic progressions.**  For every `0 < δ < 1` and
every sufficiently large `n` there is `S ⊆ [n]` with `|S| ≥ δ n` such that for all
arithmetic progressions `A`, `B` with arbitrary positive common differences and arbitrary
(possibly different) lengths,

`min{|A|, |B|} ≥ 3 log n / log(1/δ)  ⟹  A + B ⊄ S`.

This is exactly the finitary sharpness statement with `C(δ) = 3`, restricted to
progressions, and phrased — as in the conjecture — in terms of the *cardinalities* of the
summands. -/
theorem exists_dense_avoiding_ap_sumsets_min_card (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {n : ℕ}
    (hn2 : 2 ≤ n) (hδn : 1 ≤ δ ^ 2 * n) (hbig : 400 ≤ δ * n * Real.log (1 / δ)) :
    ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ (a b d₁ d₂ k₁ k₂ : ℕ), 0 < d₁ → 0 < d₂ →
        3 * (Real.log n / Real.log (1 / δ)) ≤ min (apF a d₁ k₁).card (apF b d₂ k₂).card →
        ¬ (apF a d₁ k₁ + apF b d₂ k₂ ⊆ S) := by
  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_dense_avoiding_gap_sumsets_min_side δ h0 h1 hn2 hδn (r := 1) (s := 1) (by omega)
      (by push_cast; linarith)
  refine ⟨S, hSsub, hScard, ?_⟩
  intro a b d₁ d₂ k₁ k₂ hd₁ hd₂ hk hsub
  rw [card_apF _ hd₁, card_apF _ hd₂] at hk
  refine hSno a b k₁ k₂ (fun _ => d₁) (fun _ => d₂) (fun _ _ => hd₁) (fun _ _ => hd₂) hk ?_
  rwa [gapF_one, gapF_one]

end DeltaDense