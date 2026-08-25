/-
# Why the `1/ℓ`-weighted dial is the law: saturation versus dilution

Formal core of experiment **577** (paper 227), analytic part.

## The experimental facts to be explained

Two covariates were built from the quadratic-residue pattern of `N` at the
primes `ℓ ≤ B`:

* the **count dial**  `C(B) = #{ℓ ≤ B : ℓ is a QR prime for N}` (equal weights);
* the **harmonically weighted dial** `W(B) = ∑_{QR ℓ ≤ B} 1/ℓ`.

Measured explained variance against the target:

| `B`   | count `R²` | weighted `R²` |
|-------|-----------|----------------|
| 400   | .3207     | .4731          |
| 4000  | .0241     | —              |
| 4·10⁴ | .0150     | —              |
| 10⁵   | .0000     | —              |
| 10⁶   | .0277     | .4786          |

So: **extending the window dilutes the count dial, while the weighted dial
saturates** (corr(W(10⁶), W(400)) = .999).

## What is proved here

The experiment's two-sided phenomenon is a theorem about *linear covariates in
an orthonormal signal model*, not an accident of the arithmetic population.
Model the target as `s = ∑_{i ∈ S} a i • e i` with `e` orthonormal (independent
per-prime contributions of amplitude `a i`); a *window* `T ⊆ S` gives

* the count covariate `∑_{i ∈ T} e i`, and
* the weighted covariate `∑_{i ∈ T} a i • e i`.

* `ProductDialWeighting.R2_of_orthonormal` — the squared correlation of any
  coefficient covariate with the target is the discrete Cauchy–Schwarz ratio.
* `ProductDialWeighting.countDialR2_eq`, `ProductDialWeighting.weightedDialR2_eq`
  — the two dials realise `countR2` and `weightedR2`.
* `ProductDialWeighting.countR2_le_weightedR2` — **the weighted dial dominates
  the count dial at every window**, by Cauchy–Schwarz.  (Measured: `.3207 ≤ .4731`.)
* `ProductDialWeighting.countR2_eq_flatness_mul_weightedR2` and
  `ProductDialWeighting.countR2_lt_weightedR2` — the loss is *exactly* a profile
  flatness factor, and it is strict whenever the amplitudes are non-constant on
  the window (Lagrange's identity for the Cauchy–Schwarz defect).
* `ProductDialWeighting.weightedR2_mono`, `weightedR2_le_one`,
  `weightedR2_eq_one` — the weighted dial is monotone in the window, capped by
  `1`, and exactly `1` at the full window.
* `ProductDialWeighting.weightedR2_ge_one_sub_tail` and the harmonic instance
  `harmonic_weightedR2_ge` — **saturation**: with amplitudes `a i = 1/(i+1)` the
  window `[0, n)` already explains at least `1 - 1/n` of everything the whole
  population can explain, uniformly in the ambient population size.
* `ProductDialWeighting.harmonic_countR2_le` and
  `ProductDialWeighting.harmonic_countR2_le_eventually` — **dilution**: the same
  amplitudes make the equal-weight count `R²` at most `(1 + log n)²/n`, which
  tends to `0`.  Equal weighting *buries* the informative small primes.
* `ProductDialWeighting.saturation_versus_dilution` — the two phenomena, in one
  statement: for every `ε > 0` all sufficiently large windows have weighted
  `R² ≥ 1 - ε` while count `R² ≤ ε`.

The arithmetic input (`a ℓ ≍ 1/ℓ`, the density of the residue class) is exactly
the hypothesis under which the model reproduces both measured columns.
-/
import Mathlib

namespace ProductDialWeighting

open Finset Filter Topology

/-! ## 1. Squared correlation in an orthonormal signal model -/

variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
variable {ι : Type*}

/-- Squared correlation (`R²`) of a covariate `u` with a target `s`. -/
noncomputable def R2 (u s : V) : ℝ := (inner ℝ u s) ^ 2 / (‖u‖ ^ 2 * ‖s‖ ^ 2)

/-- The squared norm of a coefficient vector in an orthonormal family. -/
theorem norm_sq_of_orthonormal {e : ι → V} (he : Orthonormal ℝ e) (S : Finset ι)
    (c : ι → ℝ) : ‖∑ i ∈ S, c i • e i‖ ^ 2 = ∑ i ∈ S, (c i) ^ 2 := by
  have h := he.inner_sum c c S
  rw [← real_inner_self_eq_norm_sq]
  simpa [sq] using h

/-- **`R²` in the orthonormal model.**  Every linear covariate built from the
per-prime contributions has squared correlation given by the discrete
Cauchy–Schwarz ratio. -/
theorem R2_of_orthonormal {e : ι → V} (he : Orthonormal ℝ e) (S : Finset ι)
    (a c : ι → ℝ) :
    R2 (∑ i ∈ S, c i • e i) (∑ i ∈ S, a i • e i)
      = (∑ i ∈ S, c i * a i) ^ 2 / ((∑ i ∈ S, (c i) ^ 2) * (∑ i ∈ S, (a i) ^ 2)) := by
  rw [R2, norm_sq_of_orthonormal he S c, norm_sq_of_orthonormal he S a]
  congr 1
  have h := he.inner_sum c a S
  simpa using congrArg (fun x : ℝ => x ^ 2) h

/-! ## 2. The two dials -/

/-- `R²` of the **equal-weight count dial** on window `T` inside population `S`. -/
noncomputable def countR2 (S T : Finset ι) (a : ι → ℝ) : ℝ :=
  (∑ i ∈ T, a i) ^ 2 / ((T.card : ℝ) * ∑ i ∈ S, (a i) ^ 2)

/-- `R²` of the **amplitude-weighted dial** on window `T` inside population `S`. -/
noncomputable def weightedR2 (S T : Finset ι) (a : ι → ℝ) : ℝ :=
  (∑ i ∈ T, (a i) ^ 2) / ∑ i ∈ S, (a i) ^ 2

section Window

variable [DecidableEq ι]

theorem sum_window_mul {S T : Finset ι} (hTS : T ⊆ S) (c a : ι → ℝ) :
    ∑ i ∈ S, (if i ∈ T then c i else 0) * a i = ∑ i ∈ T, c i * a i := by
  simp only [ite_mul, zero_mul, Finset.sum_ite_mem, Finset.inter_eq_right.mpr hTS]

theorem sum_window_sq {S T : Finset ι} (hTS : T ⊆ S) (c : ι → ℝ) :
    ∑ i ∈ S, ((if i ∈ T then c i else 0)) ^ 2 = ∑ i ∈ T, (c i) ^ 2 := by
  have h : ∀ i : ι, ((if i ∈ T then c i else 0)) ^ 2 = if i ∈ T then (c i) ^ 2 else 0 := by
    intro i; split <;> simp
  simp only [h, Finset.sum_ite_mem, Finset.inter_eq_right.mpr hTS]

/-- The count dial is the covariate with coefficients `1` on the window. -/
theorem countDialR2_eq {e : ι → V} (he : Orthonormal ℝ e) {S T : Finset ι}
    (hTS : T ⊆ S) (a : ι → ℝ) :
    R2 (∑ i ∈ S, (if i ∈ T then (1 : ℝ) else 0) • e i) (∑ i ∈ S, a i • e i)
      = countR2 S T a := by
  rw [R2_of_orthonormal he S a, countR2,
    sum_window_mul hTS (fun _ => (1 : ℝ)) a, sum_window_sq hTS (fun _ => (1 : ℝ))]
  simp

/-- The weighted dial is the covariate with coefficients `a` on the window. -/
theorem weightedDialR2_eq {e : ι → V} (he : Orthonormal ℝ e) {S T : Finset ι}
    (hTS : T ⊆ S) (a : ι → ℝ) :
    R2 (∑ i ∈ S, (if i ∈ T then a i else 0) • e i) (∑ i ∈ S, a i • e i)
      = weightedR2 S T a := by
  rw [R2_of_orthonormal he S a, weightedR2, sum_window_mul hTS a a, sum_window_sq hTS a]
  have hsq : ∑ i ∈ T, a i * a i = ∑ i ∈ T, (a i) ^ 2 :=
    Finset.sum_congr rfl (fun i _ => by ring)
  rw [hsq]
  rcases eq_or_ne (∑ i ∈ T, (a i) ^ 2) 0 with h | h
  · simp [h]
  · rcases eq_or_ne (∑ i ∈ S, (a i) ^ 2) 0 with h' | h'
    · simp [h']
    · field_simp

end Window

/-! ## 3. Weighted dominates count -/

/-- **Cauchy–Schwarz domination.**  At *every* window the harmonically weighted
dial explains at least as much variance as the equal-weight count dial.  This is
the theoretical form of the measured `.3207 ≤ .4731` at `B = 400`. -/
theorem countR2_le_weightedR2 {S T : Finset ι} (a : ι → ℝ)
    (hpos : 0 < ∑ i ∈ S, (a i) ^ 2) :
    countR2 S T a ≤ weightedR2 S T a := by
  rcases Nat.eq_zero_or_pos T.card with hc | hc
  · have hT : T = ∅ := Finset.card_eq_zero.mp hc
    simp [countR2, weightedR2, hT]
  · have hcs : (∑ i ∈ T, a i) ^ 2 ≤ (T.card : ℝ) * ∑ i ∈ T, (a i) ^ 2 :=
      sq_sum_le_card_mul_sum_sq
    have hcard : (0 : ℝ) < T.card := by exact_mod_cast hc
    rw [countR2, weightedR2, div_le_div_iff₀ (by positivity) hpos]
    calc (∑ i ∈ T, a i) ^ 2 * ∑ i ∈ S, (a i) ^ 2
        ≤ ((T.card : ℝ) * ∑ i ∈ T, (a i) ^ 2) * ∑ i ∈ S, (a i) ^ 2 :=
          mul_le_mul_of_nonneg_right hcs (le_of_lt hpos)
      _ = (∑ i ∈ T, (a i) ^ 2) * ((T.card : ℝ) * ∑ i ∈ S, (a i) ^ 2) := by ring

/-! ### 3b. The exact loss factor: profile flatness

The count dial is the weighted dial *times* a purely geometric factor measuring
how flat the amplitude profile is on the window.  A `1/ℓ` profile is very far
from flat, which is precisely why equal weighting loses so much. -/

/-- The **flatness** of the amplitude profile on a window: `1` for a constant
profile, smaller the more the amplitudes vary. -/
noncomputable def flatness (T : Finset ι) (a : ι → ℝ) : ℝ :=
  (∑ i ∈ T, a i) ^ 2 / ((T.card : ℝ) * ∑ i ∈ T, (a i) ^ 2)

/-- **Exact factorisation** of the count dial's explained variance. -/
theorem countR2_eq_flatness_mul_weightedR2 {S T : Finset ι} (a : ι → ℝ)
    (hcard : 0 < T.card) (hTa : 0 < ∑ i ∈ T, (a i) ^ 2)
    (hpos : 0 < ∑ i ∈ S, (a i) ^ 2) :
    countR2 S T a = flatness T a * weightedR2 S T a := by
  have hcard' : (0 : ℝ) < T.card := by exact_mod_cast hcard
  rw [countR2, flatness, weightedR2]
  field_simp

/-- Lagrange's identity in the form needed: the Cauchy–Schwarz defect is the
mean square of all pairwise differences. -/
theorem sum_sq_pairwise_diff (T : Finset ι) (a : ι → ℝ) :
    ∑ i ∈ T, ∑ j ∈ T, (a i - a j) ^ 2
      = 2 * ((T.card : ℝ) * ∑ i ∈ T, (a i) ^ 2 - (∑ i ∈ T, a i) ^ 2) := by
  have h1 : ∀ i : ι, ∑ j ∈ T, (a i - a j) ^ 2
      = (T.card : ℝ) * (a i) ^ 2 - 2 * a i * (∑ j ∈ T, a j) + ∑ j ∈ T, (a j) ^ 2 := by
    intro i
    simp only [sub_sq, Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_const,
      nsmul_eq_mul, ← Finset.mul_sum]
  simp only [h1, Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_const,
    nsmul_eq_mul, ← Finset.mul_sum, ← Finset.sum_mul]
  ring

/-- A non-constant profile has a strictly positive Cauchy–Schwarz defect. -/
theorem sq_sum_lt_card_mul_sum_sq {T : Finset ι} {a : ι → ℝ} {i₀ j₀ : ι}
    (hi : i₀ ∈ T) (hj : j₀ ∈ T) (hne : a i₀ ≠ a j₀) :
    (∑ i ∈ T, a i) ^ 2 < (T.card : ℝ) * ∑ i ∈ T, (a i) ^ 2 := by
  have hterm : (0 : ℝ) < (a i₀ - a j₀) ^ 2 := by
    have : a i₀ - a j₀ ≠ 0 := sub_ne_zero.mpr hne
    positivity
  have hinner : (a i₀ - a j₀) ^ 2 ≤ ∑ j ∈ T, (a i₀ - a j) ^ 2 :=
    Finset.single_le_sum (f := fun j => (a i₀ - a j) ^ 2) (fun j _ => sq_nonneg _) hj
  have houter : (∑ j ∈ T, (a i₀ - a j) ^ 2) ≤ ∑ i ∈ T, ∑ j ∈ T, (a i - a j) ^ 2 :=
    Finset.single_le_sum (f := fun i => ∑ j ∈ T, (a i - a j) ^ 2)
      (fun i _ => Finset.sum_nonneg (fun j _ => sq_nonneg _)) hi
  have hid := sum_sq_pairwise_diff T a
  linarith

/-- **Strict Cauchy–Schwarz domination.**  As soon as the amplitude profile is
non-constant on the window — which a `1/ℓ` profile always is — the weighted dial
is *strictly* better than the count dial. -/
theorem countR2_lt_weightedR2 {S T : Finset ι} {a : ι → ℝ} {i₀ j₀ : ι}
    (hi : i₀ ∈ T) (hj : j₀ ∈ T) (hne : a i₀ ≠ a j₀)
    (hpos : 0 < ∑ i ∈ S, (a i) ^ 2) :
    countR2 S T a < weightedR2 S T a := by
  have hcard : 0 < T.card := Finset.card_pos.mpr ⟨i₀, hi⟩
  have hcard' : (0 : ℝ) < T.card := by exact_mod_cast hcard
  have hdefect := sq_sum_lt_card_mul_sum_sq hi hj hne
  have hTa : 0 < ∑ i ∈ T, (a i) ^ 2 := by
    rcases lt_or_eq_of_le (Finset.sum_nonneg (fun i _ => sq_nonneg (a i)) :
        (0 : ℝ) ≤ ∑ i ∈ T, (a i) ^ 2) with h | h
    · exact h
    · exfalso
      rw [← h, mul_zero] at hdefect
      nlinarith [sq_nonneg (∑ i ∈ T, a i)]
  have hflat : flatness T a < 1 := by
    rw [flatness, div_lt_one (by positivity)]
    exact hdefect
  have hw : 0 < weightedR2 S T a := div_pos hTa hpos
  rw [countR2_eq_flatness_mul_weightedR2 a hcard hTa hpos]
  nlinarith

/-! ## 4. Saturation of the weighted dial -/

theorem weightedR2_nonneg (S T : Finset ι) (a : ι → ℝ) : 0 ≤ weightedR2 S T a := by
  apply div_nonneg <;> positivity

/-- Monotone in the window. -/
theorem weightedR2_mono {S T T' : Finset ι} (h : T ⊆ T') (a : ι → ℝ)
    (hpos : 0 < ∑ i ∈ S, (a i) ^ 2) :
    weightedR2 S T a ≤ weightedR2 S T' a := by
  rw [weightedR2, weightedR2, div_le_div_iff_of_pos_right hpos]
  exact Finset.sum_le_sum_of_subset_of_nonneg h (fun i _ _ => by positivity)

/-- Capped by `1` on windows inside the population. -/
theorem weightedR2_le_one {S T : Finset ι} (hTS : T ⊆ S) (a : ι → ℝ)
    (hpos : 0 < ∑ i ∈ S, (a i) ^ 2) : weightedR2 S T a ≤ 1 := by
  rw [weightedR2, div_le_one hpos]
  exact Finset.sum_le_sum_of_subset_of_nonneg hTS (fun i _ _ => by positivity)

/-- The full window explains everything. -/
theorem weightedR2_eq_one {S : Finset ι} (a : ι → ℝ) (hpos : 0 < ∑ i ∈ S, (a i) ^ 2) :
    weightedR2 S S a = 1 := div_self (ne_of_gt hpos)

/-- **Quantitative saturation.**  If the amplitude mass outside the window is a
fraction `≤ ε` of the total, the window already achieves `R² ≥ 1 - ε`. -/
theorem weightedR2_ge_one_sub_tail [DecidableEq ι] {S T : Finset ι} (hTS : T ⊆ S)
    (a : ι → ℝ) {ε : ℝ} (hpos : 0 < ∑ i ∈ S, (a i) ^ 2)
    (htail : ∑ i ∈ S \ T, (a i) ^ 2 ≤ ε * ∑ i ∈ S, (a i) ^ 2) :
    1 - ε ≤ weightedR2 S T a := by
  have hsplit : ∑ i ∈ S \ T, (a i) ^ 2 + ∑ i ∈ T, (a i) ^ 2 = ∑ i ∈ S, (a i) ^ 2 :=
    Finset.sum_sdiff hTS
  rw [weightedR2, le_div_iff₀ hpos]
  nlinarith [hsplit, htail]

/-! ## 5. The harmonic amplitude model: saturation versus dilution -/

/-- The amplitude profile `a ℓ ≍ 1/ℓ` in index form. -/
noncomputable def harmonicAmp (i : ℕ) : ℝ := 1 / (i + 1)

theorem harmonicAmp_pos (i : ℕ) : 0 < harmonicAmp i := by
  unfold harmonicAmp; positivity

theorem harmonic_total_pos {N : ℕ} (hN : 0 < N) :
    0 < ∑ i ∈ range N, (harmonicAmp i) ^ 2 :=
  Finset.sum_pos (fun i _ => pow_pos (harmonicAmp_pos i) 2) ⟨0, mem_range.mpr hN⟩

/-- The total amplitude mass is at least `1` (the `i = 0` term). -/
theorem harmonic_total_ge_one {N : ℕ} (hN : 0 < N) :
    (1 : ℝ) ≤ ∑ i ∈ range N, (harmonicAmp i) ^ 2 := by
  have h0 : (0 : ℕ) ∈ range N := mem_range.mpr hN
  calc (1 : ℝ) = (harmonicAmp 0) ^ 2 := by norm_num [harmonicAmp]
    _ ≤ ∑ i ∈ range N, (harmonicAmp i) ^ 2 :=
        Finset.single_le_sum (f := fun i => (harmonicAmp i) ^ 2)
          (fun i _ => sq_nonneg _) h0

/-- Telescoping tail bound: `∑_{n ≤ i < m} 1/(i+1)² ≤ 1/n - 1/m`. -/
theorem harmonic_tail_le_sub {n : ℕ} (hn : 0 < n) :
    ∀ m : ℕ, n ≤ m → ∑ i ∈ Ico n m, (harmonicAmp i) ^ 2 ≤ 1 / n - 1 / m := by
  intro m
  induction m with
  | zero => intro hm; omega
  | succ k ihk =>
      intro hm
      rcases eq_or_lt_of_le hm with h1 | h1
      · subst h1
        simp
      · have hnk : n ≤ k := by omega
        have hkpos : 0 < k := lt_of_lt_of_le hn hnk
        have hkR : (0 : ℝ) < k := by exact_mod_cast hkpos
        rw [Finset.sum_Ico_succ_top hnk]
        have hstep : (harmonicAmp k) ^ 2 ≤ 1 / (k : ℝ) - 1 / ((k : ℝ) + 1) := by
          have hid : 1 / (k : ℝ) - 1 / ((k : ℝ) + 1) = 1 / ((k : ℝ) * ((k : ℝ) + 1)) := by
            field_simp
            ring
          rw [hid, harmonicAmp, div_pow, one_pow]
          apply one_div_le_one_div_of_le
          · positivity
          · nlinarith
        have hprev := ihk hnk
        have hcast : ((k : ℝ) + 1) = ((k + 1 : ℕ) : ℝ) := by push_cast; ring
        rw [← hcast]
        linarith

/-- Tail bound for the squared harmonic amplitudes: `∑_{i ≥ n} 1/(i+1)² ≤ 1/n`. -/
theorem harmonic_tail_le {n N : ℕ} (hn : 0 < n) :
    ∑ i ∈ Ico n N, (harmonicAmp i) ^ 2 ≤ 1 / n := by
  rcases le_or_gt n N with h | h
  · have hsub := harmonic_tail_le_sub hn N h
    have hpos : (0 : ℝ) ≤ 1 / (N : ℝ) := by positivity
    linarith
  · rw [Ico_eq_empty_of_le (le_of_lt h), Finset.sum_empty]
    positivity

/-- **Saturation, harmonic instance.**  For every ambient population `range N`
and every window `range n ⊆ range N`, the weighted dial already explains at
least `1 - 1/n` of the explainable variance — uniformly in `N`.  This is the
`corr(W(10⁶), W(400)) = .999` phenomenon. -/
theorem harmonic_weightedR2_ge {n N : ℕ} (hn : 0 < n) (hnN : n ≤ N) :
    1 - 1 / (n : ℝ) ≤ weightedR2 (range N) (range n) harmonicAmp := by
  have hNpos : 0 < N := lt_of_lt_of_le hn hnN
  have hsub : range n ⊆ range N := range_subset_range.mpr hnN
  have hpos := harmonic_total_pos (N := N) hNpos
  have hdiff : range N \ range n = Ico n N := by
    ext i
    simp only [Finset.mem_sdiff, Finset.mem_range, Finset.mem_Ico, not_lt]
    exact ⟨fun h => ⟨h.2, h.1⟩, fun h => ⟨h.2, h.1⟩⟩
  have htail : ∑ i ∈ range N \ range n, (harmonicAmp i) ^ 2
      ≤ (1 / (n : ℝ)) * ∑ i ∈ range N, (harmonicAmp i) ^ 2 := by
    rw [hdiff]
    have h1 := harmonic_total_ge_one (N := N) hNpos
    have h2 : (0 : ℝ) ≤ 1 / (n : ℝ) := by positivity
    calc ∑ i ∈ Ico n N, (harmonicAmp i) ^ 2 ≤ 1 / (n : ℝ) := harmonic_tail_le hn
      _ = (1 / (n : ℝ)) * 1 := by ring
      _ ≤ (1 / (n : ℝ)) * ∑ i ∈ range N, (harmonicAmp i) ^ 2 := by nlinarith
  exact weightedR2_ge_one_sub_tail hsub harmonicAmp hpos htail

/-- **Strict domination in the harmonic model.**  For any window containing at
least two primes, the `1/ℓ`-weighted dial strictly beats the equal-weight count
dial — the theoretical counterpart of `.3207 < .4731`. -/
theorem harmonic_countR2_lt_weightedR2 {n N : ℕ} (hn : 2 ≤ n) (hnN : n ≤ N) :
    countR2 (range N) (range n) harmonicAmp
      < weightedR2 (range N) (range n) harmonicAmp := by
  have hNpos : 0 < N := lt_of_lt_of_le (by omega) hnN
  have h0 : (0 : ℕ) ∈ range n := mem_range.mpr (by omega)
  have h1 : (1 : ℕ) ∈ range n := mem_range.mpr (by omega)
  have hne : harmonicAmp 0 ≠ harmonicAmp 1 := by
    simp [harmonicAmp]
  exact countR2_lt_weightedR2 h0 h1 hne (harmonic_total_pos hNpos)

/-- The window sum of harmonic amplitudes is the harmonic number. -/
theorem harmonic_window_sum (n : ℕ) :
    ∑ i ∈ range n, harmonicAmp i = (harmonic n : ℝ) := by
  rw [harmonic, Rat.cast_sum]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  rw [harmonicAmp]
  push_cast
  ring

/-- **Dilution, harmonic instance.**  The equal-weight count dial on the window
`range n` explains at most `(1 + log n)² / n`, no matter how large the ambient
population is: extending the window *destroys* the signal-to-noise ratio,
because the informative small primes get averaged against `n` uninformative
ones. -/
theorem harmonic_countR2_le {n N : ℕ} (hn : 0 < n) (hnN : n ≤ N) :
    countR2 (range N) (range n) harmonicAmp ≤ (1 + Real.log n) ^ 2 / n := by
  have hNpos : 0 < N := lt_of_lt_of_le hn hnN
  have hcard : ((range n).card : ℝ) = n := by simp
  have hden : (1 : ℝ) ≤ ∑ i ∈ range N, (harmonicAmp i) ^ 2 :=
    harmonic_total_ge_one (N := N) hNpos
  have hnum : ∑ i ∈ range n, harmonicAmp i ≤ 1 + Real.log n := by
    rw [harmonic_window_sum]
    exact harmonic_le_one_add_log n
  have hnum0 : 0 ≤ ∑ i ∈ range n, harmonicAmp i :=
    Finset.sum_nonneg (fun i _ => le_of_lt (harmonicAmp_pos i))
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  rw [countR2, hcard]
  have hsq : (∑ i ∈ range n, harmonicAmp i) ^ 2 ≤ (1 + Real.log n) ^ 2 := by nlinarith
  have hd : (0 : ℝ) < (n : ℝ) * ∑ i ∈ range N, (harmonicAmp i) ^ 2 := by nlinarith
  rw [div_le_div_iff₀ hd (by positivity)]
  have hL : (0 : ℝ) ≤ (1 + Real.log n) ^ 2 := sq_nonneg _
  calc (∑ i ∈ range n, harmonicAmp i) ^ 2 * (n : ℝ)
      ≤ (1 + Real.log n) ^ 2 * (n : ℝ) := by nlinarith
    _ ≤ (1 + Real.log n) ^ 2 * ((n : ℝ) * ∑ i ∈ range N, (harmonicAmp i) ^ 2) := by
        have hmul : (n : ℝ) ≤ (n : ℝ) * ∑ i ∈ range N, (harmonicAmp i) ^ 2 := by nlinarith
        exact mul_le_mul_of_nonneg_left hmul hL

/-- `(1 + log n)² / n → 0`. -/
theorem log_sq_div_tendsto_zero :
    Tendsto (fun n : ℕ => (1 + Real.log n) ^ 2 / n) atTop (𝓝 0) := by
  have hbase : Tendsto (fun x : ℝ => (1 + Real.log x) ^ 2 / x) atTop (𝓝 0) := by
    have h0 : Tendsto (fun x : ℝ => Real.log x ^ 0 / (1 * x + 0)) atTop (𝓝 0) :=
      Real.tendsto_pow_log_div_mul_add_atTop 1 0 0 one_ne_zero
    have h1 : Tendsto (fun x : ℝ => Real.log x ^ 1 / (1 * x + 0)) atTop (𝓝 0) :=
      Real.tendsto_pow_log_div_mul_add_atTop 1 0 1 one_ne_zero
    have h2 : Tendsto (fun x : ℝ => Real.log x ^ 2 / (1 * x + 0)) atTop (𝓝 0) :=
      Real.tendsto_pow_log_div_mul_add_atTop 1 0 2 one_ne_zero
    have hsum := ((h0.const_mul (1 : ℝ)).add (h1.const_mul (2 : ℝ))).add h2
    rw [show ((1 : ℝ) * 0 + 2 * 0 + 0) = 0 by ring] at hsum
    refine hsum.congr' ?_
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with x hx
    field_simp
    ring
  exact hbase.comp tendsto_natCast_atTop_atTop

/-- **Dilution.**  The count dial's explained variance is eventually below any
tolerance, uniformly over ambient populations containing the window. -/
theorem harmonic_countR2_le_eventually (ε : ℝ) (hε : 0 < ε) :
    ∃ n₀ : ℕ, 0 < n₀ ∧ ∀ n N : ℕ, n₀ ≤ n → n ≤ N →
      countR2 (range N) (range n) harmonicAmp ≤ ε := by
  have h := log_sq_div_tendsto_zero
  rw [Metric.tendsto_atTop] at h
  obtain ⟨m, hm⟩ := h ε hε
  refine ⟨max m 1, by positivity, fun n N hn hnN => ?_⟩
  have hn1 : 0 < n := lt_of_lt_of_le Nat.one_pos (le_trans (le_max_right m 1) hn)
  have hmn : m ≤ n := le_trans (le_max_left m 1) hn
  have hd := hm n hmn
  rw [Real.dist_eq, sub_zero] at hd
  exact le_trans (harmonic_countR2_le hn1 hnN) (le_of_lt (lt_of_abs_lt hd))

/-- **Saturation versus dilution, in one statement.**  For every tolerance `ε`
there is a window size beyond which the harmonically weighted dial explains
almost *all* the explainable variance while the equal-weight count dial explains
almost *none* of it — the formal content of "the extension dilutes, the weighted
dial is the law". -/
theorem saturation_versus_dilution (ε : ℝ) (hε : 0 < ε) :
    ∃ n₀ : ℕ, 0 < n₀ ∧ ∀ n N : ℕ, n₀ ≤ n → n ≤ N →
      1 - ε ≤ weightedR2 (range N) (range n) harmonicAmp ∧
      countR2 (range N) (range n) harmonicAmp ≤ ε := by
  obtain ⟨n₁, hn₁pos, hn₁⟩ := harmonic_countR2_le_eventually ε hε
  obtain ⟨n₂, hn₂⟩ := exists_nat_gt (1 / ε)
  refine ⟨max n₁ (n₂ + 1), by positivity, fun n N hn hnN => ?_⟩
  have hna : n₁ ≤ n := le_trans (le_max_left _ _) hn
  have hnb : n₂ + 1 ≤ n := le_trans (le_max_right _ _) hn
  have hnpos : 0 < n := by omega
  refine ⟨?_, hn₁ n N hna hnN⟩
  have hnpos' : (0 : ℝ) < n := by exact_mod_cast hnpos
  have hlt : (1 / ε) < (n : ℝ) := by
    refine lt_of_lt_of_le hn₂ ?_
    exact_mod_cast (by omega : n₂ ≤ n)
  have hle : 1 / (n : ℝ) ≤ ε := by
    rw [div_le_iff₀ hnpos']
    rw [div_lt_iff₀ hε] at hlt
    linarith
  have hsat := harmonic_weightedR2_ge hnpos hnN
  linarith

end ProductDialWeighting