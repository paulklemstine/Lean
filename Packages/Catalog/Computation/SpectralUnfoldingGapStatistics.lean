import Mathlib

/-!
# Normalized gap statistics and pair correlation for finite spectra

This file formalizes the elementary but foundational layer of random-matrix-style
spectral statistics for *finite deterministic* spectra:

* `gap`, `meanGap`, `normGap` : raw gaps, mean gap and **unfolded (normalized) gaps**
  of a level sequence `lam : ℕ → ℝ`;
* `gapCDF` : the empirical distribution function of the normalized gaps;
* `pairCorrCount` : the (unnormalized) two-level correlation counting function.

The main results.

* `sum_normGap` : the normalized gaps of a window of `n` levels always sum to `n`
  (mean spacing exactly one) — the defining property of unfolding.
* `normGap_affine` : normalized gaps are invariant under affine rescaling of the
  spectrum.  Hence *raw* spectra may never be compared, only unfolded ones.
* `quad_gapCDF_close_uniform` : for the raw quadratic spectrum `λ_k = k²` the
  empirical normalized-gap distribution is within `1/(2n)` of the **uniform law
  on `[0,2]`** — an artifact of the divergent density of states, not of any
  underlying statistics.
* `unfoldedQuad_normGap_eq_one` : after unfolding (`λ_k ↦ √λ_k = k`) *every*
  normalized gap equals `1`: a rigid picket fence.
* `picket_pairCorr_eq_zero` / `picket_pairCorr_nn_of_one_le` : the two-level
  correlation of the unfolded quadratic spectrum vanishes identically below
  distance `1` and jumps to `2(n-1)` on `[1,2)`.  This is maximal level
  repulsion — stronger than GUE and incompatible with Poisson.
* `picket_number_rigidity` : the counting function of the unfolded spectrum in a
  window of length `L` deviates from `L` by less than `1`, uniformly in the
  window position: the number variance is bounded, whereas for a Poisson
  process it equals `L`.
-/

namespace Catalog.Computation.SpectralUnfolding

open Finset

/-! ## Gaps, mean gap, normalized gaps -/

/-- The `i`-th raw gap of a level sequence. -/
def gap (lam : ℕ → ℝ) (i : ℕ) : ℝ := lam (i + 1) - lam i

/-- The mean gap of the window consisting of the first `n` gaps. -/
noncomputable def meanGap (lam : ℕ → ℝ) (n : ℕ) : ℝ := (lam n - lam 0) / n

/-- The normalized (unfolded) gap: raw gap divided by the local mean gap. -/
noncomputable def normGap (lam : ℕ → ℝ) (n i : ℕ) : ℝ := gap lam i / meanGap lam n

lemma sum_gap (lam : ℕ → ℝ) (n : ℕ) :
    ∑ i ∈ range n, gap lam i = lam n - lam 0 :=
  Finset.sum_range_sub lam n

lemma meanGap_eq_sum (lam : ℕ → ℝ) (n : ℕ) :
    meanGap lam n = (∑ i ∈ range n, gap lam i) / n := by
  rw [meanGap, sum_gap]

/-- **Unfolding normalizes the mean spacing to one**: the `n` normalized gaps of a
window sum to `n`. -/
theorem sum_normGap (lam : ℕ → ℝ) (n : ℕ) (hn : 0 < n) (h : meanGap lam n ≠ 0) :
    ∑ i ∈ range n, normGap lam n i = n := by
  have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  have hL : lam n - lam 0 ≠ 0 := by
    intro hz
    exact h (by rw [meanGap, hz, zero_div])
  have hs : ∑ i ∈ range n, normGap lam n i = (lam n - lam 0) / meanGap lam n := by
    simp only [normGap, ← Finset.sum_div, sum_gap]
  rw [hs, meanGap]
  field_simp

/-- **Affine invariance**: normalized gap statistics do not see an affine change of
scale of the spectrum. -/
theorem normGap_affine (lam : ℕ → ℝ) (a b : ℝ) (ha : a ≠ 0) (n i : ℕ) :
    normGap (fun k => a * lam k + b) n i = normGap lam n i := by
  simp only [normGap, gap, meanGap]
  rw [show a * lam (i + 1) + b - (a * lam i + b) = a * (lam (i + 1) - lam i) by ring,
      show a * lam n + b - (a * lam 0 + b) = a * (lam n - lam 0) by ring,
      show a * (lam n - lam 0) / (n : ℝ) = a * ((lam n - lam 0) / (n : ℝ)) from
        mul_div_assoc _ _ _,
      mul_div_mul_left _ _ ha]

/-! ## The raw quadratic spectrum -/

/-- The deterministic quadratic spectrum `λ_k = k²`. -/
def quadSpectrum (k : ℕ) : ℝ := (k : ℝ) ^ 2

@[simp] lemma gap_quad (i : ℕ) : gap quadSpectrum i = 2 * i + 1 := by
  simp only [gap, quadSpectrum]
  push_cast
  ring

lemma meanGap_quad (n : ℕ) (hn : 0 < n) : meanGap quadSpectrum n = n := by
  have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  simp only [meanGap, quadSpectrum, Nat.cast_zero]
  rw [show ((0 : ℝ)) ^ 2 = 0 by norm_num, sub_zero, sq, mul_div_assoc, div_self hn', mul_one]

lemma normGap_quad (n i : ℕ) (hn : 0 < n) :
    normGap quadSpectrum n i = (2 * i + 1) / n := by
  rw [normGap, gap_quad, meanGap_quad n hn]

/-- The raw quadratic spectrum has wildly inhomogeneous normalized gaps: the first
one tends to `0`. -/
theorem quad_normGap_first_tendsto_zero :
    Filter.Tendsto (fun n : ℕ => normGap quadSpectrum (n + 1) 0) Filter.atTop (nhds 0) := by
  have h : ∀ n : ℕ, normGap quadSpectrum (n + 1) 0 = 1 / ((n : ℝ) + 1) := by
    intro n
    rw [normGap_quad _ _ (Nat.succ_pos n)]
    push_cast
    ring
  simp only [h]
  exact tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)

/-- The last normalized gap of the raw quadratic spectrum tends to `2`; together with
the previous theorem, the raw normalized gaps spread over the whole interval `[0,2]`. -/
theorem quad_normGap_last_tendsto_two :
    Filter.Tendsto (fun n : ℕ => normGap quadSpectrum (n + 1) n) Filter.atTop (nhds 2) := by
  have h : ∀ n : ℕ, normGap quadSpectrum (n + 1) n = 2 - 1 / ((n : ℝ) + 1) := by
    intro n
    rw [normGap_quad _ _ (Nat.succ_pos n)]
    have hne : ((n : ℝ) + 1) ≠ 0 := by positivity
    push_cast
    field_simp
    ring
  simp only [h]
  have h0 := tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)
  simpa using (tendsto_const_nhds (X := ℝ) (x := (2 : ℝ)) (f := Filter.atTop (α := ℕ))).sub h0

/-! ## Empirical distribution of normalized gaps -/

open scoped Classical in
/-- The empirical CDF of the normalized gaps of the first `n` gaps. -/
noncomputable def gapCDF (lam : ℕ → ℝ) (n : ℕ) (t : ℝ) : ℝ :=
  ((Finset.filter (fun i => normGap lam n i ≤ t) (range n)).card : ℝ) / n

open scoped Classical in
/-- Counting lemma: `#{i < n : 2i+1 ≤ x} = min n ⌊(x+1)/2⌋₊` for `x ≥ 0`. -/
lemma card_filter_odd_le (n : ℕ) (x : ℝ) (hx : 0 ≤ x) :
    (Finset.filter (fun i : ℕ => 2 * (i : ℝ) + 1 ≤ x) (range n)).card
      = min n ⌊(x + 1) / 2⌋₊ := by
  have hxx : (0 : ℝ) ≤ (x + 1) / 2 := by linarith
  have key : ∀ i : ℕ, (2 * (i : ℝ) + 1 ≤ x) ↔ i < ⌊(x + 1) / 2⌋₊ := by
    intro i
    constructor
    · intro h
      have h1 : ((i : ℝ) + 1) ≤ (x + 1) / 2 := by linarith
      have h2 : i + 1 ≤ ⌊(x + 1) / 2⌋₊ := (Nat.le_floor_iff hxx).mpr (by push_cast; linarith)
      omega
    · intro h
      have h' : i + 1 ≤ ⌊(x + 1) / 2⌋₊ := h
      have h2 := (Nat.le_floor_iff hxx).mp h'
      push_cast at h2
      linarith
  have hset : Finset.filter (fun i : ℕ => 2 * (i : ℝ) + 1 ≤ x) (range n)
      = range (min n ⌊(x + 1) / 2⌋₊) := by
    ext i
    simp only [mem_filter, mem_range, key, lt_min_iff]
  rw [hset, card_range]

open scoped Classical in
/-- **The raw quadratic spectrum looks uniform on `[0,2]`.**  Its empirical
normalized-gap distribution is within `1/(2n)` of the uniform law on `[0,2]`. -/
theorem quad_gapCDF_close_uniform (n : ℕ) (hn : 0 < n) (t : ℝ) (ht0 : 0 ≤ t) (ht2 : t ≤ 2) :
    |gapCDF quadSpectrum n t - t / 2| ≤ 1 / (2 * n) := by
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  set x : ℝ := t * n with hxdef
  have hx0 : 0 ≤ x := by positivity
  have hfilter : (Finset.filter (fun i => normGap quadSpectrum n i ≤ t) (range n))
      = (Finset.filter (fun i : ℕ => 2 * (i : ℝ) + 1 ≤ x) (range n)) := by
    apply Finset.filter_congr
    intro i _
    rw [normGap_quad _ _ hn]
    constructor
    · intro h
      have := (div_le_iff₀ hnR).mp h
      linarith
    · intro h
      exact (div_le_iff₀ hnR).mpr (by linarith)
  have hmin : min n ⌊(x + 1) / 2⌋₊ = ⌊(x + 1) / 2⌋₊ := by
    apply min_eq_right
    have hle : (x + 1) / 2 ≤ (n : ℝ) + 1 / 2 := by
      have : x ≤ 2 * n := by
        rw [hxdef]; nlinarith
      linarith
    have hmono := Nat.floor_le_floor hle
    have h2 : ⌊(n : ℝ) + 1 / 2⌋₊ = n := by
      rw [Nat.floor_eq_iff (by positivity)]
      exact ⟨by linarith, by linarith⟩
    omega
  have hcard : ((Finset.filter (fun i => normGap quadSpectrum n i ≤ t) (range n)).card : ℝ)
      = (⌊(x + 1) / 2⌋₊ : ℝ) := by
    rw [hfilter, card_filter_odd_le n x hx0, hmin]
  have hfl1 : (⌊(x + 1) / 2⌋₊ : ℝ) ≤ (x + 1) / 2 := Nat.floor_le (by positivity)
  have hfl2 : (x + 1) / 2 - 1 < (⌊(x + 1) / 2⌋₊ : ℝ) := by
    have := Nat.lt_floor_add_one ((x + 1) / 2)
    linarith
  set c : ℝ := (⌊(x + 1) / 2⌋₊ : ℝ) with hc
  have hdiff : |c - x / 2| ≤ 1 / 2 := by
    rw [abs_le]
    exact ⟨by linarith, by linarith⟩
  have hrewrite : c / n - t / 2 = (c - x / 2) / n := by
    rw [hxdef]; field_simp
  rw [gapCDF, hcard, hrewrite, abs_div, abs_of_pos hnR]
  calc |c - x / 2| / n ≤ (1 / 2) / n := by gcongr
    _ = 1 / (2 * n) := by field_simp

/-! ## Unfolding the quadratic spectrum: the picket fence -/

/-- The **unfolded** quadratic spectrum: the smoothed counting function of
`λ_k = k²` is `N(x) = √x`, so the unfolded levels are `N(λ_k) = k`. -/
noncomputable def unfoldedQuad (k : ℕ) : ℝ := Real.sqrt (quadSpectrum k)

@[simp] lemma unfoldedQuad_eq (k : ℕ) : unfoldedQuad k = k := by
  rw [unfoldedQuad, quadSpectrum, Real.sqrt_sq (Nat.cast_nonneg k)]

@[simp] lemma gap_unfoldedQuad (i : ℕ) : gap unfoldedQuad i = 1 := by
  simp only [gap, unfoldedQuad_eq]
  push_cast
  ring

lemma meanGap_unfoldedQuad (n : ℕ) (hn : 0 < n) : meanGap unfoldedQuad n = 1 := by
  have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  simp only [meanGap, unfoldedQuad_eq, Nat.cast_zero, sub_zero]
  exact div_self hn'

/-- **After unfolding, every normalized gap of the quadratic spectrum equals one.**
The unfolded quadratic spectrum is a perfectly rigid picket fence. -/
theorem unfoldedQuad_normGap_eq_one (n i : ℕ) (hn : 0 < n) :
    normGap unfoldedQuad n i = 1 := by
  rw [normGap, gap_unfoldedQuad, meanGap_unfoldedQuad n hn, div_one]

open scoped Classical in
/-- The empirical gap distribution of the unfolded quadratic spectrum is a Dirac mass
at `1`: no normalized gap is smaller than `1`. -/
theorem unfoldedQuad_gapCDF_eq_zero (n : ℕ) (hn : 0 < n) (t : ℝ) (ht : t < 1) :
    gapCDF unfoldedQuad n t = 0 := by
  have hempty : Finset.filter (fun i => normGap unfoldedQuad n i ≤ t) (range n) = ∅ := by
    rw [Finset.filter_eq_empty_iff]
    intro i _
    rw [unfoldedQuad_normGap_eq_one n i hn]
    exact not_le.mpr ht
  rw [gapCDF, hempty]
  simp

open scoped Classical in
/-- ... and every normalized gap is at most `1`. -/
theorem unfoldedQuad_gapCDF_eq_one (n : ℕ) (hn : 0 < n) (t : ℝ) (ht : 1 ≤ t) :
    gapCDF unfoldedQuad n t = 1 := by
  have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  have hall : Finset.filter (fun i => normGap unfoldedQuad n i ≤ t) (range n) = range n := by
    rw [Finset.filter_eq_self]
    intro i _
    rw [unfoldedQuad_normGap_eq_one n i hn]
    exact ht
  rw [gapCDF, hall, card_range]
  exact div_self hn'

/-! ## Two-level (pair) correlation -/

open scoped Classical in
/-- The unnormalized two-level correlation count: the number of ordered pairs of
distinct levels among the first `n` at distance at most `t`. -/
noncomputable def pairCorrCount (lam : ℕ → ℝ) (n : ℕ) (t : ℝ) : ℕ :=
  (Finset.filter (fun p : ℕ × ℕ => p.1 ≠ p.2 ∧ |lam p.1 - lam p.2| ≤ t)
    ((range n) ×ˢ (range n))).card

lemma one_le_abs_cast_sub {i j : ℕ} (h : i ≠ j) : (1 : ℝ) ≤ |(i : ℝ) - (j : ℝ)| := by
  have hZ : ((i : ℤ) - (j : ℤ)) ≠ 0 := by
    simpa [sub_eq_zero, Nat.cast_inj] using fun hh => h (by exact_mod_cast hh)
  have h1 : (1 : ℤ) ≤ |(i : ℤ) - (j : ℤ)| := by
    rcases lt_trichotomy ((i : ℤ) - (j : ℤ)) 0 with hlt | heq | hgt
    · rw [abs_of_neg hlt]; omega
    · exact absurd heq hZ
    · rw [abs_of_pos hgt]; omega
  have hcast : ((|(i : ℤ) - (j : ℤ)| : ℤ) : ℝ) = |(i : ℝ) - (j : ℝ)| := by
    push_cast
    ring_nf
  calc (1 : ℝ) = ((1 : ℤ) : ℝ) := by norm_num
    _ ≤ ((|(i : ℤ) - (j : ℤ)| : ℤ) : ℝ) := by exact_mod_cast h1
    _ = |(i : ℝ) - (j : ℝ)| := hcast

lemma abs_cast_sub_lt_two {i j : ℕ} (h : |(i : ℝ) - (j : ℝ)| < 2) (hne : i ≠ j) :
    j = i + 1 ∨ i = j + 1 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨h1, h2⟩ := hcon
  have hZ : (2 : ℤ) ≤ |(i : ℤ) - (j : ℤ)| := by
    rcases abs_cases ((i : ℤ) - (j : ℤ)) with ⟨he, _⟩ | ⟨he, _⟩ <;> rw [he] <;> omega
  have hcast : ((|(i : ℤ) - (j : ℤ)| : ℤ) : ℝ) = |(i : ℝ) - (j : ℝ)| := by
    push_cast
    ring_nf
  have : (2 : ℝ) ≤ |(i : ℝ) - (j : ℝ)| := by
    rw [← hcast]
    exact_mod_cast hZ
  linarith

open scoped Classical in
/-- **Maximal level repulsion.** The two-level correlation of the unfolded quadratic
spectrum vanishes identically below distance `1`: there are no small spacings at all.
For a Poisson spectrum this count grows like `2tn` for every `t > 0`. -/
theorem picket_pairCorr_eq_zero (n : ℕ) (t : ℝ) (ht : t < 1) :
    pairCorrCount unfoldedQuad n t = 0 := by
  rw [pairCorrCount, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  rintro ⟨i, j⟩ _
  simp only [unfoldedQuad_eq, not_and, not_le]
  intro hne
  exact lt_of_lt_of_le ht (one_le_abs_cast_sub hne)

open scoped Classical in
/-- The exact value of the two-level correlation of the picket fence on `[1,2)`:
only nearest-neighbour pairs contribute, so the count is `2(n-1)`. -/
theorem picket_pairCorr_eq_two_mul (n : ℕ) (t : ℝ) (h1 : 1 ≤ t) (h2 : t < 2) :
    pairCorrCount unfoldedQuad n t = 2 * (n - 1) := by
  classical
  have hset : Finset.filter (fun p : ℕ × ℕ => p.1 ≠ p.2 ∧ |unfoldedQuad p.1 - unfoldedQuad p.2| ≤ t)
      ((range n) ×ˢ (range n))
      = ((range (n - 1)).image (fun i => (i, i + 1)))
        ∪ ((range (n - 1)).image (fun i => (i + 1, i))) := by
    ext ⟨i, j⟩
    simp only [Finset.mem_filter, Finset.mem_product, mem_range, Finset.mem_union,
      Finset.mem_image, unfoldedQuad_eq, Prod.mk.injEq]
    constructor
    · rintro ⟨⟨hi, hj⟩, hne, hle⟩
      have hlt : |(i : ℝ) - (j : ℝ)| < 2 := lt_of_le_of_lt hle h2
      rcases abs_cast_sub_lt_two hlt hne with rfl | rfl
      · exact Or.inl ⟨i, by omega, rfl, rfl⟩
      · exact Or.inr ⟨j, by omega, rfl, rfl⟩
    · rintro (⟨k, hk, hik, hjk⟩ | ⟨k, hk, hik, hjk⟩) <;> subst hik <;> subst hjk
      · refine ⟨⟨by omega, by omega⟩, by omega, ?_⟩
        have : |(k : ℝ) - ((k : ℝ) + 1)| = 1 := by
          rw [show (k : ℝ) - ((k : ℝ) + 1) = -1 by ring]
          norm_num
        push_cast
        rw [this]
        exact h1
      · refine ⟨⟨by omega, by omega⟩, by omega, ?_⟩
        have : |((k : ℝ) + 1) - (k : ℝ)| = 1 := by
          rw [show ((k : ℝ) + 1) - (k : ℝ) = 1 by ring]
          norm_num
        push_cast
        rw [this]
        exact h1
  have hdisj : Disjoint ((range (n - 1)).image (fun i => (i, i + 1)))
      ((range (n - 1)).image (fun i => ((i + 1, i) : ℕ × ℕ))) := by
    rw [Finset.disjoint_left]
    rintro ⟨i, j⟩ ha hb
    simp only [Finset.mem_image, mem_range, Prod.mk.injEq] at ha hb
    obtain ⟨k, _, hk1, hk2⟩ := ha
    obtain ⟨l, _, hl1, hl2⟩ := hb
    omega
  have hinj1 : Function.Injective (fun i : ℕ => (i, i + 1)) := by
    intro a b hab
    simpa using congrArg Prod.fst hab
  have hinj2 : Function.Injective (fun i : ℕ => ((i + 1, i) : ℕ × ℕ)) := by
    intro a b hab
    simpa using congrArg Prod.snd hab
  rw [pairCorrCount, hset, Finset.card_union_of_disjoint hdisj,
    Finset.card_image_of_injective _ hinj1, Finset.card_image_of_injective _ hinj2, card_range]
  omega

/-! ## Spectral rigidity: the number variance of the picket fence is bounded -/

/-- The levels of the unfolded quadratic spectrum lying in the window `[a, a+L)` are
exactly the integers in `Finset.Ico ⌈a⌉ ⌈a+L⌉`. -/
lemma mem_picketWindow (a L : ℝ) (m : ℤ) :
    m ∈ Finset.Ico ⌈a⌉ ⌈a + L⌉ ↔ (a ≤ (m : ℝ) ∧ (m : ℝ) < a + L) := by
  simp only [Finset.mem_Ico, Int.ceil_le, Int.lt_ceil]

/-- **Spectral rigidity.** The counting function of the unfolded quadratic spectrum in
any window of length `L` differs from `L` by less than `1`, uniformly in the position
of the window; hence the number variance is bounded by `1`.  For a Poisson process the
number variance equals `L` and diverges. -/
theorem picket_number_rigidity (a L : ℝ) (hL : 0 ≤ L) :
    |((Finset.Ico ⌈a⌉ ⌈a + L⌉).card : ℝ) - L| < 1 := by
  have hmono : ⌈a⌉ ≤ ⌈a + L⌉ := Int.ceil_le_ceil (by linarith)
  have hcard : ((Finset.Ico ⌈a⌉ ⌈a + L⌉).card : ℝ) = ((⌈a + L⌉ : ℝ) - (⌈a⌉ : ℝ)) := by
    rw [Int.card_Ico]
    have : ((⌈a + L⌉ - ⌈a⌉).toNat : ℤ) = ⌈a + L⌉ - ⌈a⌉ := Int.toNat_of_nonneg (by omega)
    have h2 : (((⌈a + L⌉ - ⌈a⌉).toNat : ℤ) : ℝ) = ((⌈a + L⌉ - ⌈a⌉ : ℤ) : ℝ) := by
      exact_mod_cast congrArg (fun z : ℤ => (z : ℝ)) this
    push_cast at h2 ⊢
    linarith
  have h1 : a + L ≤ (⌈a + L⌉ : ℝ) := Int.le_ceil _
  have h2 : (⌈a + L⌉ : ℝ) < a + L + 1 := Int.ceil_lt_add_one _
  have h3 : a ≤ (⌈a⌉ : ℝ) := Int.le_ceil _
  have h4 : (⌈a⌉ : ℝ) < a + 1 := Int.ceil_lt_add_one _
  rw [hcard, abs_lt]
  constructor <;> linarith

/-- No window of length at least `1` of the unfolded quadratic spectrum is empty:
the picket fence has no gaps in its counting statistics, unlike a Poisson process,
for which an empty window of length `L` has positive probability `e^{-L}`. -/
theorem picket_no_empty_window (a L : ℝ) (hL : 1 ≤ L) :
    1 ≤ (Finset.Ico ⌈a⌉ ⌈a + L⌉).card := by
  by_contra hcon
  push_neg at hcon
  have hzero : (Finset.Ico ⌈a⌉ ⌈a + L⌉).card = 0 := by omega
  have := picket_number_rigidity a L (by linarith)
  rw [hzero] at this
  simp only [Nat.cast_zero, zero_sub, abs_neg] at this
  rw [abs_of_nonneg (by linarith : (0:ℝ) ≤ L)] at this
  linarith

/-! ## The empirical spacing variance and rigidity -/

/-- The empirical variance of the normalized gaps of a window of `n` levels. -/
noncomputable def gapVariance (lam : ℕ → ℝ) (n : ℕ) : ℝ :=
  (∑ i ∈ range n, (normGap lam n i - 1) ^ 2) / n

/-- **Zero spacing variance characterizes rigidity**: the empirical variance of the
normalized gaps vanishes exactly when every gap in the window equals the mean gap. -/
theorem gapVariance_eq_zero_iff (lam : ℕ → ℝ) (n : ℕ) (hn : 0 < n)
    (hmean : meanGap lam n ≠ 0) :
    gapVariance lam n = 0 ↔ ∀ i ∈ range n, gap lam i = meanGap lam n := by
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  rw [gapVariance, div_eq_zero_iff]
  constructor
  · rintro (hsum | hzero)
    · intro i hi
      have hterm : ∀ j ∈ range n, (0 : ℝ) ≤ (normGap lam n j - 1) ^ 2 := fun j _ => sq_nonneg _
      have := (Finset.sum_eq_zero_iff_of_nonneg hterm).mp hsum i hi
      have hz : normGap lam n i - 1 = 0 := by
        exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp this
      have : normGap lam n i = 1 := by linarith
      rw [normGap, div_eq_one_iff_eq hmean] at this
      exact this
    · exact absurd hzero (ne_of_gt hnR)
  · intro hall
    left
    apply Finset.sum_eq_zero
    intro i hi
    have : normGap lam n i = 1 := by
      rw [normGap, hall i hi, div_self hmean]
    rw [this]
    norm_num

/-- The unfolded quadratic spectrum has exactly zero spacing variance, the extreme
rigid value (compare: `3π/8 - 1` for the GUE surmise and `1` for Poisson statistics). -/
theorem unfoldedQuad_gapVariance_eq_zero (n : ℕ) (hn : 0 < n) :
    gapVariance unfoldedQuad n = 0 := by
  rw [gapVariance_eq_zero_iff _ n hn (by rw [meanGap_unfoldedQuad n hn]; norm_num)]
  intro i _
  rw [gap_unfoldedQuad, meanGap_unfoldedQuad n hn]

end Catalog.Computation.SpectralUnfolding