import Mathlib

/-!
# The U108 rung: certified band loss, a plateau localisation theorem, and rapidity pooling

## Research context (FACT round-69 #2, exp 544, `TDIAL-U108-CONTINUES-FADE`)

The recorded measurement is the fourth rung of the `T`-dial bitlen ladder: the pooled Spearman
rank correlation between a trailing-zero / small-prime-QR statistic `T` of a uniformly drawn
integer and a downstream `rate`.

```
bitlen   :  96      100     104     108     112    | (116)    (120)
rho      :  0.5739  0.5436  0.5005  0.4880  0.4621 | 0.4847   0.43636
step     :         -0.0303 -0.0431 -0.0125 -0.0259 | +0.0226  -0.0483
```

At U108 the pooled reading is `0.488`, CI `[0.445, 0.534]`: for the **first** time the entire
confidence interval sits below the pre-registered `0.55` band floor.  The paired advantage of
`T` over the plain count baseline is `+0.092`, CI `[0.043, 0.139]`, and the rung is the first
to show seed heterogeneity.  The step delta (`-0.0125`) is markedly smaller than the two
preceding steps (`-0.0303`, `-0.0431`), which is what motivated the "fade decelerates toward a
`~0.48` plateau" reading.  The rungs `116` and `120` are *later* measurements; here they are
used only to score the extrapolation that the U108 data licensed at the time.

Reproduction script: `ResearchOutput/scripts/2026-08-21-resume/exp544_t_dial_unif_108.py`,
`exp544_result.json`, `run.log`, seeds `20261210`–`20261212`.

Companion catalog files analyse a single pooled number against tie geometry
(`Novelty.ZeroFitDialU64`), Gram geometry (`Algebra.ZeroFitDialU72Parity`), pooling geometry
(`Algebra.ZeroFitDialU120Floor`), floor identifiability
(`Probability.TDialU116FloorIdentifiability`) and the sharpness of the decorrelation
certificate (`Novelty.TDialU112FadeReacceleration`).  This file is self-contained (it only
imports `Mathlib`) and settles three questions those files leave open.

1. `Algebra.ZeroFitDialU120Floor.corr_le_of_advantage` converts a measured advantage
   `a − b = δ` into the decorrelation certificate `c ≤ 1 − δ²/2`.  **Is the full Gram
   certificate strictly stronger, and by exactly how much?**
2. The U108 reading is the first *decelerating* step.  **What does deceleration alone pin down
   about the plateau — quantitatively, and does the window it predicts contain the rungs that
   were measured afterwards?**
3. The U108 rung is the first with seed heterogeneity.  **Can heterogeneity in the seeds
   manufacture a pooled value back inside the band?**

## Main results

### 1. Gram geometry (Section 2)

* `corr_le_gram_bound` — from positive semidefiniteness of the `3×3` correlation matrix
  (in the scalar form `0 ≤ 1 + 2abc − a² − b² − c²`) one gets `c ≤ ab + √((1−a²)(1−b²))`.
* `gram_gap_eq` — the **exact** gap identity
  `(1 − (a−b)²/2) − (ab + √((1−a²)(1−b²))) = (√(1−a²) − √(1−b²))² / 2`.
  So the advantage certificate of the catalog is exactly an AM–GM relaxation of the Gram
  certificate, and the loss is a perfect square in the two "residual lengths".
* `gram_strictly_dominates_advantage` — the Gram bound is *strictly* stronger whenever
  `a² ≠ b²`, i.e. whenever the dial and the baseline have different explanatory strength —
  which is precisely the regime the advantage measurement certifies.
* `u108_decorrelation_certificate` — numerically, at U108 (`a = 0.488`, `b = 0.396`) the Gram
  bound gives `corr(T, count) ≤ 0.9949`, beating the advantage bound `0.995768`.

### 2. Deceleration ⇒ plateau (Section 3)

* `tail_bound` — for an antitone sequence whose consecutive decrements contract by a factor
  `r < 1`, every tail drop is at most `dₙ / (1 − r)`.
* `plateau_of_geometric_deceleration` — such a sequence converges, and the limit `L` is
  localised by a *one-rung* measurement: `L ≤ sₙ ≤ L + dₙ/(1−r)`.
* `u108_plateau_window` — instantiated at U108 with `r ≤ 1/2`: the plateau lies in
  `[0.4362, 0.488]`.
* `u108_window_contains_later_rungs` — both rungs measured *after* the forecast
  (`0.4847` at 116 and `0.43636` at 120) lie inside that window; `0.43636` clears the lower
  edge by only `1.6·10⁻⁴`, so the forecast is tight rather than vacuous.
* `ladder_not_antitone` — the honest boundary: the measured seven-rung ladder is **not**
  antitone (the 116 rebound), so the deceleration hypothesis is a statement about the fade
  component, not about the raw ladder.

### 3. Rapidity pooling and seed heterogeneity (Section 4)

Fisher's `z` is `artanh`, i.e. *rapidity*; correlations compose exactly like collinear
velocities in special relativity.

* `tanh_artanh_add` — `tanh(artanh x + artanh y) = (x+y)/(1+xy)`: Fisher-`z` addition **is**
  Einstein velocity composition.
* `fisherAdd_mem_Ioo` — composition never leaves `(−1,1)`: no "superluminal" pooled
  correlation.
* `tanh_midpoint_ge` — midpoint concavity of `tanh` on `[0,∞)`, proved by the exact identity
  `cosh(m+d)cosh(m−d) = cosh²m + sinh²d`.
* `fisherPool2_ge_mean`, `fisherPool3_ge_mean` — **heterogeneity inflates the pooled
  estimate**: Fisher pooling of nonnegative seed correlations is at least their arithmetic
  mean (the three-seed case is derived from the two-seed case by the classical
  "add the mean as a fourth point" argument).
* `fisherPool3_le_max` — but pooling can never exceed the largest seed.
* `pool_below_floor_of_seeds_below_floor` — consequently, if every seed is below the `0.55`
  floor then the pooled value is below the floor: **heterogeneity cannot rescue the band.**

### 4. Limit form of the certificate (Section 5)

* `limit_decorrelation` — if the dial ladder, the baseline ladder and their mutual correlation
  all converge, and each rung satisfies Gram positivity, then the limiting correlation obeys
  `C ≤ 1 − (A−B)²/2`.  A persistent advantage forces a *permanent* decorrelation certificate;
  at U108's CI lower edge `δ ≥ 0.043` this gives `C ≤ 0.9990755`.
-/

namespace Catalog.Physics.TDialU108

open Real Set Filter

/-! ## Section 1. The recorded ladder -/

/-- The seven measured pooled Spearman readings of the `T`-dial ladder, indexed by
`bitlen = 96 + 4 * i` (the value is `0` outside the measured range). -/
def rho : ℕ → ℚ
  | 0 => 5739/10000
  | 1 => 5436/10000
  | 2 => 5005/10000
  | 3 => 488/1000
  | 4 => 4621/10000
  | 5 => 4847/10000
  | 6 => 43636/100000
  | _ => 0

/-- The pre-registered band floor. -/
def bandFloor : ℚ := 55/100

/-- The U108 confidence interval. -/
def ciU108 : ℚ × ℚ := (445/1000, 534/1000)

/-- The paired advantage of `T` over the count baseline at U108, and its CI. -/
def advU108 : ℚ := 92/1000

/-- Band history of the ladder: the first rung (bitlen 96) is inside the band, and every later
rung is strictly below the floor. -/
theorem band_history :
    bandFloor ≤ rho 0 ∧ ∀ i : ℕ, 1 ≤ i → i ≤ 6 → rho i < bandFloor := by
  refine ⟨by norm_num [rho, bandFloor], fun i h1 h2 => ?_⟩
  interval_cases i <;> norm_num [rho, bandFloor]

/-- CI separation at U108: the *entire* interval lies below the floor, with a margin of at
least `0.016`, and the pooled reading sits inside its own interval. -/
theorem ci_separated_below_floor :
    ciU108.2 < bandFloor ∧ bandFloor - ciU108.2 ≥ 16/1000 ∧
      ciU108.1 ≤ rho 3 ∧ rho 3 ≤ ciU108.2 := by
  refine ⟨by norm_num [ciU108, bandFloor], by norm_num [ciU108, bandFloor], ?_, ?_⟩ <;>
    norm_num [ciU108, rho]


/-- The fade decelerates at U108: the step into 108 is smaller in magnitude than each of the
two preceding steps, and all three steps are negative. -/
theorem fade_decelerates_at_u108 :
    rho 1 - rho 0 < 0 ∧ rho 2 - rho 1 < 0 ∧ rho 3 - rho 2 < 0 ∧
      rho 2 - rho 3 < rho 1 - rho 2 ∧ rho 2 - rho 3 < rho 0 - rho 1 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> norm_num [rho]


/-! ## Section 2. Gram geometry: the exact gap between the two decorrelation certificates -/

/-- Gram positivity in scalar form: if the `3×3` correlation matrix with off-diagonal entries
`a, b, c` has nonnegative determinant, then `(c − ab)² ≤ (1−a²)(1−b²)`. -/
theorem corr_sub_mul_sq_le {a b c : ℝ}
    (hdet : 0 ≤ 1 + 2 * a * b * c - a ^ 2 - b ^ 2 - c ^ 2) :
    (c - a * b) ^ 2 ≤ (1 - a ^ 2) * (1 - b ^ 2) := by
  nlinarith [sq_nonneg (c - a * b)]

/-- The Gram (angle-addition) upper bound on the dial/baseline correlation. -/
theorem corr_le_gram_bound {a b c : ℝ}
    (hdet : 0 ≤ 1 + 2 * a * b * c - a ^ 2 - b ^ 2 - c ^ 2) :
    c ≤ a * b + √((1 - a ^ 2) * (1 - b ^ 2)) := by
  have h := corr_sub_mul_sq_le hdet
  have h1 : c - a * b ≤ |c - a * b| := le_abs_self _
  have h2 : |c - a * b| ≤ √((1 - a ^ 2) * (1 - b ^ 2)) := by
    rw [← Real.sqrt_sq_eq_abs]
    exact Real.sqrt_le_sqrt h
  linarith

/-- **Exact gap identity.**  The catalog's advantage certificate `1 − (a−b)²/2` exceeds the
Gram certificate by exactly half the square of the difference of the two residual lengths
`√(1−a²)` and `√(1−b²)`.  In particular the advantage certificate is precisely the AM–GM
relaxation of the Gram certificate. -/
theorem gram_gap_eq {a b : ℝ} (ha : |a| ≤ 1) (hb : |b| ≤ 1) :
    (1 - (a - b) ^ 2 / 2) - (a * b + √((1 - a ^ 2) * (1 - b ^ 2)))
      = (√(1 - a ^ 2) - √(1 - b ^ 2)) ^ 2 / 2 := by
  have ha2 : (0:ℝ) ≤ 1 - a ^ 2 := by nlinarith [abs_le.1 ha]
  have hb2 : (0:ℝ) ≤ 1 - b ^ 2 := by nlinarith [abs_le.1 hb]
  have h1 : √((1 - a ^ 2) * (1 - b ^ 2)) = √(1 - a ^ 2) * √(1 - b ^ 2) := Real.sqrt_mul ha2 _
  have h2 : √(1 - a ^ 2) ^ 2 = 1 - a ^ 2 := Real.sq_sqrt ha2
  have h3 : √(1 - b ^ 2) ^ 2 = 1 - b ^ 2 := Real.sq_sqrt hb2
  rw [h1]; nlinarith [h2, h3]

/-- The Gram certificate dominates the advantage certificate, always. -/
theorem gram_le_advantage_bound {a b : ℝ} (ha : |a| ≤ 1) (hb : |b| ≤ 1) :
    a * b + √((1 - a ^ 2) * (1 - b ^ 2)) ≤ 1 - (a - b) ^ 2 / 2 := by
  have h := gram_gap_eq ha hb
  nlinarith [sq_nonneg (√(1 - a ^ 2) - √(1 - b ^ 2))]

/-- **Strict domination.**  Whenever the dial and the baseline have different explanatory
strength (`a² ≠ b²`) the Gram certificate is *strictly* stronger than the advantage
certificate. -/
theorem gram_strictly_dominates_advantage {a b : ℝ} (ha : |a| ≤ 1) (hb : |b| ≤ 1)
    (hne : a ^ 2 ≠ b ^ 2) :
    a * b + √((1 - a ^ 2) * (1 - b ^ 2)) < 1 - (a - b) ^ 2 / 2 := by
  have ha2 : (0:ℝ) ≤ 1 - a ^ 2 := by nlinarith [abs_le.1 ha]
  have hb2 : (0:ℝ) ≤ 1 - b ^ 2 := by nlinarith [abs_le.1 hb]
  have hs : √(1 - a ^ 2) ≠ √(1 - b ^ 2) := by
    intro h
    apply hne
    have h2 : √(1 - a ^ 2) ^ 2 = √(1 - b ^ 2) ^ 2 := by rw [h]
    rw [Real.sq_sqrt ha2, Real.sq_sqrt hb2] at h2
    linarith
  have hpos : 0 < (√(1 - a ^ 2) - √(1 - b ^ 2)) ^ 2 := by
    have : √(1 - a ^ 2) - √(1 - b ^ 2) ≠ 0 := sub_ne_zero.mpr hs
    positivity
  have h := gram_gap_eq ha hb
  linarith

/-- The advantage certificate itself (the catalog statement), re-derived here so that the file
is self-contained. -/
theorem corr_le_of_advantage {a b c : ℝ} (ha : |a| ≤ 1) (hb : |b| ≤ 1)
    (hdet : 0 ≤ 1 + 2 * a * b * c - a ^ 2 - b ^ 2 - c ^ 2) :
    c ≤ 1 - (a - b) ^ 2 / 2 :=
  (corr_le_gram_bound hdet).trans (gram_le_advantage_bound ha hb)

/-- **The U108 decorrelation certificate.**  With the measured `a = corr(T, rate) = 0.488` and
`b = corr(count, rate) = 0.396` (advantage `+0.092`), Gram positivity forces
`corr(T, count) ≤ 0.9949`, strictly better than the advantage bound `1 − δ²/2 = 0.995768`. -/
theorem u108_decorrelation_certificate {c : ℝ}
    (hdet : 0 ≤ 1 + 2 * (0.488 : ℝ) * 0.396 * c - (0.488:ℝ) ^ 2 - (0.396:ℝ) ^ 2 - c ^ 2) :
    c ≤ 0.9949 ∧ (0.9949 : ℝ) < 1 - ((0.488:ℝ) - 0.396) ^ 2 / 2 := by
  constructor
  · have hg := corr_le_gram_bound hdet
    have hnum : ((1 : ℝ) - (0.488:ℝ) ^ 2) * (1 - (0.396:ℝ) ^ 2) ≤ (0.8016:ℝ) ^ 2 := by norm_num
    have hsq : √(((1 : ℝ) - (0.488:ℝ) ^ 2) * (1 - (0.396:ℝ) ^ 2)) ≤ 0.8016 := by
      have := Real.sqrt_le_sqrt hnum
      rwa [Real.sqrt_sq (by norm_num)] at this
    nlinarith
  · norm_num

/-! ## Section 3. Deceleration forces a plateau, and the plateau window is testable -/

variable {s : ℕ → ℝ} {r : ℝ}

/-- If the decrements of an antitone sequence contract geometrically with ratio `r < 1`, then
no tail can drop by more than `dₙ / (1 − r)`, where `dₙ = sₙ − sₙ₊₁` is the *current* step. -/
theorem tail_bound (hr1 : r < 1) (hmono : ∀ n, s (n + 1) ≤ s n)
    (hgeo : ∀ n, s (n + 1) - s (n + 2) ≤ r * (s n - s (n + 1))) :
    ∀ n m, s n - s (n + m) ≤ (s n - s (n + 1)) / (1 - r) := by
  have h1r : 0 < 1 - r := by linarith
  intro n m
  induction m generalizing n with
  | zero =>
      have h : 0 ≤ s n - s (n + 1) := by have := hmono n; linarith
      have h2 : (0:ℝ) ≤ (s n - s (n + 1)) / (1 - r) := div_nonneg h h1r.le
      simpa using h2
  | succ m ih =>
      have hstep := ih (n + 1)
      rw [le_div_iff₀ h1r] at hstep
      have hg := hgeo n
      have hnm : n + (m + 1) = n + 1 + m := by omega
      rw [hnm, le_div_iff₀ h1r]
      nlinarith

/-- **Plateau localisation from a single rung.**  An antitone sequence with geometrically
contracting decrements converges, and its limit `L` is sandwiched by the current value and the
current step: `L ≤ sₙ ≤ L + dₙ/(1−r)`.  This is the formal content of "a decelerating fade has
a plateau, and one rung already localises it". -/
theorem plateau_of_geometric_deceleration (hr1 : r < 1) (hmono : ∀ n, s (n + 1) ≤ s n)
    (hgeo : ∀ n, s (n + 1) - s (n + 2) ≤ r * (s n - s (n + 1))) :
    ∃ L : ℝ, Tendsto s atTop (nhds L) ∧
      ∀ n, L ≤ s n ∧ s n - L ≤ (s n - s (n + 1)) / (1 - r) := by
  have h1r : 0 < 1 - r := by linarith
  have hanti : Antitone s := antitone_nat_of_succ_le hmono
  have htail := tail_bound hr1 hmono hgeo
  have hbdd : BddBelow (Set.range s) := by
    refine ⟨s 0 - (s 0 - s 1) / (1 - r), ?_⟩
    rintro _ ⟨n, rfl⟩
    have h := htail 0 n
    simp only [Nat.zero_add] at h
    linarith
  refine ⟨⨅ i, s i, tendsto_atTop_ciInf hanti hbdd, fun n => ⟨ciInf_le hbdd n, ?_⟩⟩
  have key : s n - (s n - s (n + 1)) / (1 - r) ≤ ⨅ i, s i := by
    refine le_ciInf fun m => ?_
    rcases le_or_gt n m with h | h
    · have h2 := htail n (m - n)
      have hmn : n + (m - n) = m := by omega
      rw [hmn] at h2
      linarith
    · have hd : 0 ≤ s n - s (n + 1) := by have := hmono n; linarith
      have h3 : s n ≤ s m := hanti h.le
      have h4 : (0:ℝ) ≤ (s n - s (n + 1)) / (1 - r) := div_nonneg hd h1r.le
      linarith
  linarith

/-- **The U108 plateau window.**  Index `0` is bitlen 108 and index `1` is bitlen 112.  Any
fade model that is antitone from 108 on, decelerates with ratio at most `1/2`, and matches the
two measured values `0.488` and `0.4621`, has its plateau inside `[0.4362, 0.488]`.  The
window is therefore *narrower than the band gap*: the plateau is at least `0.062` below the
`0.55` floor, so the band loss certified at U108 is permanent for the whole model class. -/
theorem u108_plateau_window (hr1 : r ≤ 1/2) (hmono : ∀ n, s (n + 1) ≤ s n)
    (hgeo : ∀ n, s (n + 1) - s (n + 2) ≤ r * (s n - s (n + 1)))
    (h0 : s 0 = 0.488) (h1 : s 1 = 0.4621) :
    ∃ L : ℝ, Tendsto s atTop (nhds L) ∧ 0.4362 ≤ L ∧ L ≤ 0.488 ∧ L ≤ 0.55 - 0.062 := by
  obtain ⟨L, hL, hbounds⟩ := plateau_of_geometric_deceleration (by linarith : r < 1) hmono hgeo
  obtain ⟨hle, hgap⟩ := hbounds 0
  rw [h0, h1] at hgap
  rw [h0] at hle
  have hden : (0:ℝ) < 1 - r := by linarith
  have hdiv : ((0.488 : ℝ) - 0.4621) / (1 - r) ≤ 0.0518 := by
    rw [div_le_iff₀ hden]; nlinarith
  exact ⟨L, hL, by linarith, hle, by linarith⟩

/-- **Scoring the forecast.**  Both rungs measured *after* U108 — `0.4847` at bitlen 116 and
`0.43636` at bitlen 120 — lie inside the predicted plateau window `[0.4362, 0.488]`, the
latter clearing the lower edge by only `1.6·10⁻⁴`.  The window is thus tight, not vacuous. -/
theorem u108_window_contains_later_rungs :
    (4362/10000 : ℚ) ≤ rho 5 ∧ rho 5 ≤ 488/1000 ∧
      (4362/10000 : ℚ) ≤ rho 6 ∧ rho 6 ≤ 488/1000 ∧
      rho 6 - 4362/10000 < 2/10000 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> norm_num [rho]


/-- **The honest boundary.**  The *measured* seven-rung ladder is not antitone: the 116 rung
rebounds above the 112 rung.  Hence the deceleration hypothesis of
`plateau_of_geometric_deceleration` cannot be read as a claim about the raw ladder; it is a
claim about the fade component, and the rebound is the residual. -/
theorem ladder_not_antitone : ¬ ∀ i : ℕ, i ≤ 5 → rho (i + 1) ≤ rho i := by
  intro h
  have h4 := h 4 (by norm_num)
  norm_num [rho] at h4

/-! ## Section 4. Rapidity pooling: heterogeneity cannot rescue the band -/

/-- Einstein / Fisher composition of two correlations. -/
noncomputable def fisherAdd (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-- Fisher-`z` pooling of two seed correlations. -/
noncomputable def fisherPool2 (x y : ℝ) : ℝ := Real.tanh ((artanh x + artanh y) / 2)

/-- Fisher-`z` pooling of three seed correlations. -/
noncomputable def fisherPool3 (x y z : ℝ) : ℝ :=
  Real.tanh ((artanh x + artanh y + artanh z) / 3)

/-- `tanh` is monotone (derived from strict monotonicity of `artanh` on `(-1,1)`). -/
theorem tanh_le_tanh_of_le {u v : ℝ} (h : u ≤ v) : Real.tanh u ≤ Real.tanh v := by
  have hmu : Real.tanh u ∈ Ioo (-1:ℝ) 1 := ⟨Real.neg_one_lt_tanh u, Real.tanh_lt_one u⟩
  have hmv : Real.tanh v ∈ Ioo (-1:ℝ) 1 := ⟨Real.neg_one_lt_tanh v, Real.tanh_lt_one v⟩
  have hiff := Real.artanh_le_artanh_iff hmu hmv
  rw [Real.artanh_tanh, Real.artanh_tanh] at hiff
  exact hiff.1 h

/-- **Fisher-`z` addition is Einstein velocity composition.**  Adding rapidities multiplies
into the relativistic sum of the correlations. -/
theorem tanh_artanh_add {x y : ℝ} (hx : x ∈ Ioo (-1:ℝ) 1) (hy : y ∈ Ioo (-1:ℝ) 1) :
    Real.tanh (artanh x + artanh y) = fisherAdd x y := by
  obtain ⟨hx1, hx2⟩ := hx
  obtain ⟨hy1, hy2⟩ := hy
  have hA : 0 < √(1 - x ^ 2) := Real.sqrt_pos.mpr (by nlinarith)
  have hB : 0 < √(1 - y ^ 2) := Real.sqrt_pos.mpr (by nlinarith)
  rw [fisherAdd, Real.tanh_eq_sinh_div_cosh, Real.sinh_add, Real.cosh_add,
    Real.sinh_artanh ⟨hx1, hx2⟩, Real.cosh_artanh ⟨hx1, hx2⟩,
    Real.sinh_artanh ⟨hy1, hy2⟩, Real.cosh_artanh ⟨hy1, hy2⟩]
  have e1 : x / √(1 - x ^ 2) * (1 / √(1 - y ^ 2)) + 1 / √(1 - x ^ 2) * (y / √(1 - y ^ 2))
      = (x + y) / (√(1 - x ^ 2) * √(1 - y ^ 2)) := by field_simp
  have e2 : 1 / √(1 - x ^ 2) * (1 / √(1 - y ^ 2)) + x / √(1 - x ^ 2) * (y / √(1 - y ^ 2))
      = (1 + x * y) / (√(1 - x ^ 2) * √(1 - y ^ 2)) := by field_simp
  rw [e1, e2, div_div_div_cancel_right₀]
  positivity

/-- **No superluminal pooling.**  Composition of two admissible correlations is admissible. -/
theorem fisherAdd_mem_Ioo {x y : ℝ} (hx : x ∈ Ioo (-1:ℝ) 1) (hy : y ∈ Ioo (-1:ℝ) 1) :
    fisherAdd x y ∈ Ioo (-1:ℝ) 1 := by
  rw [← tanh_artanh_add hx hy]
  exact ⟨Real.neg_one_lt_tanh _, Real.tanh_lt_one _⟩

/-- **Midpoint concavity of `tanh` on `[0, ∞)`**, via the exact hyperbolic identity
`cosh(m+d)·cosh(m−d) = cosh²m + sinh²d`: spreading two rapidities apart at fixed mean can only
lower the average of their `tanh`s. -/
theorem tanh_midpoint_ge (m d : ℝ) (hm : 0 ≤ m) :
    Real.tanh (m + d) + Real.tanh (m - d) ≤ 2 * Real.tanh m := by
  have hden : Real.cosh (m + d) * Real.cosh (m - d) = Real.cosh m ^ 2 + Real.sinh d ^ 2 := by
    rw [Real.cosh_add, Real.cosh_sub]
    linear_combination (Real.cosh m ^ 2) * (Real.cosh_sq_sub_sinh_sq d)
      + (Real.sinh d ^ 2) * (Real.cosh_sq_sub_sinh_sq m)
  have hnum : Real.sinh (m + d) * Real.cosh (m - d) + Real.sinh (m - d) * Real.cosh (m + d)
      = 2 * Real.sinh m * Real.cosh m := by
    rw [Real.sinh_add, Real.sinh_sub, Real.cosh_add, Real.cosh_sub]
    linear_combination (2 * Real.sinh m * Real.cosh m) * (Real.cosh_sq_sub_sinh_sq d)
  have hcp : ∀ x : ℝ, 0 < Real.cosh x := Real.cosh_pos
  have hlhs : Real.tanh (m + d) + Real.tanh (m - d)
      = (2 * Real.sinh m * Real.cosh m) / (Real.cosh m ^ 2 + Real.sinh d ^ 2) := by
    rw [Real.tanh_eq_sinh_div_cosh, Real.tanh_eq_sinh_div_cosh,
      div_add_div _ _ (hcp _).ne' (hcp _).ne', hden.symm, ← hnum]
    ring_nf
  have hrhs : 2 * Real.tanh m = (2 * Real.sinh m * Real.cosh m) / (Real.cosh m ^ 2) := by
    rw [Real.tanh_eq_sinh_div_cosh]; field_simp
  rw [hlhs, hrhs]
  have hsn : 0 ≤ 2 * Real.sinh m * Real.cosh m := by
    have := Real.sinh_nonneg_iff.mpr hm
    positivity
  have hc2 : 0 < Real.cosh m ^ 2 := by positivity
  gcongr
  nlinarith [sq_nonneg (Real.sinh d)]

/-- Two-point form: for nonnegative rapidities, the mean of the `tanh`s is at most the `tanh`
of the mean. -/
theorem tanh_two_point (u v : ℝ) (hu : 0 ≤ u) (hv : 0 ≤ v) :
    Real.tanh u + Real.tanh v ≤ 2 * Real.tanh ((u + v) / 2) := by
  have hm : 0 ≤ (u + v) / 2 := by linarith
  have h := tanh_midpoint_ge ((u + v) / 2) ((u - v) / 2) hm
  have e1 : (u + v) / 2 + (u - v) / 2 = u := by ring
  have e2 : (u + v) / 2 - (u - v) / 2 = v := by ring
  rwa [e1, e2] at h

/-- Three-point form, obtained from the two-point form by the classical trick of adjoining the
mean as a fourth point. -/
theorem tanh_three_point (u v w : ℝ) (hu : 0 ≤ u) (hv : 0 ≤ v) (hw : 0 ≤ w) :
    Real.tanh u + Real.tanh v + Real.tanh w ≤ 3 * Real.tanh ((u + v + w) / 3) := by
  set m : ℝ := (u + v + w) / 3 with hmdef
  have hm : 0 ≤ m := by rw [hmdef]; linarith
  have hA : 0 ≤ (u + v) / 2 := by linarith
  have hB : 0 ≤ (w + m) / 2 := by linarith
  have h1 := tanh_two_point u v hu hv
  have h2 := tanh_two_point w m hw hm
  have h3 := tanh_two_point ((u + v) / 2) ((w + m) / 2) hA hB
  have hmid : ((u + v) / 2 + (w + m) / 2) / 2 = m := by rw [hmdef]; ring
  rw [hmid] at h3
  linarith

/-- **Heterogeneity inflates the pooled estimate (two seeds).**  Fisher-`z` pooling of two
nonnegative seed correlations is at least their arithmetic mean. -/
theorem fisherPool2_ge_mean {x y : ℝ} (hx0 : 0 ≤ x) (hx1 : x < 1) (hy0 : 0 ≤ y) (hy1 : y < 1) :
    (x + y) / 2 ≤ fisherPool2 x y := by
  have hxm : x ∈ Ioo (-1:ℝ) 1 := ⟨by linarith, hx1⟩
  have hym : y ∈ Ioo (-1:ℝ) 1 := ⟨by linarith, hy1⟩
  have hu : 0 ≤ artanh x := Real.artanh_nonneg hx0
  have hv : 0 ≤ artanh y := Real.artanh_nonneg hy0
  have h := tanh_two_point (artanh x) (artanh y) hu hv
  rw [Real.tanh_artanh hxm, Real.tanh_artanh hym] at h
  rw [fisherPool2]
  linarith

/-- **Heterogeneity inflates the pooled estimate (three seeds).** -/
theorem fisherPool3_ge_mean {x y z : ℝ} (hx0 : 0 ≤ x) (hx1 : x < 1) (hy0 : 0 ≤ y) (hy1 : y < 1)
    (hz0 : 0 ≤ z) (hz1 : z < 1) :
    (x + y + z) / 3 ≤ fisherPool3 x y z := by
  have hxm : x ∈ Ioo (-1:ℝ) 1 := ⟨by linarith, hx1⟩
  have hym : y ∈ Ioo (-1:ℝ) 1 := ⟨by linarith, hy1⟩
  have hzm : z ∈ Ioo (-1:ℝ) 1 := ⟨by linarith, hz1⟩
  have h := tanh_three_point (artanh x) (artanh y) (artanh z) (Real.artanh_nonneg hx0)
    (Real.artanh_nonneg hy0) (Real.artanh_nonneg hz0)
  rw [Real.tanh_artanh hxm, Real.tanh_artanh hym, Real.tanh_artanh hzm] at h
  rw [fisherPool3]
  linarith

/-- **But pooling never exceeds the largest seed.** -/
theorem fisherPool3_le_max {x y z : ℝ} (hx : x ∈ Ioo (-1:ℝ) 1) (hy : y ∈ Ioo (-1:ℝ) 1)
    (hz : z ∈ Ioo (-1:ℝ) 1) :
    fisherPool3 x y z ≤ max x (max y z) := by
  set M : ℝ := max x (max y z) with hM
  have hMm : M ∈ Ioo (-1:ℝ) 1 := by
    rcases le_total x (max y z) with h | h
    · rw [hM, max_eq_right h]
      rcases le_total y z with h' | h'
      · rw [max_eq_right h']; exact hz
      · rw [max_eq_left h']; exact hy
    · rw [hM, max_eq_left h]; exact hx
  have hxM : artanh x ≤ artanh M :=
    Real.artanh_le_artanh hx.1 hMm.2 (le_trans (le_max_left _ _) (le_refl M))
  have hyM : artanh y ≤ artanh M :=
    Real.artanh_le_artanh hy.1 hMm.2 (le_trans (le_max_left y z) (le_max_right x _))
  have hzM : artanh z ≤ artanh M :=
    Real.artanh_le_artanh hz.1 hMm.2 (le_trans (le_max_right y z) (le_max_right x _))
  have hmean : (artanh x + artanh y + artanh z) / 3 ≤ artanh M := by linarith
  have hmono := tanh_le_tanh_of_le hmean
  rw [Real.tanh_artanh hMm] at hmono
  simpa [fisherPool3] using hmono

/-- **Heterogeneity cannot rescue the band.**  If every seed correlation is below the `0.55`
floor, then so is the Fisher-pooled value — even though pooling is biased *upward* relative to
the arithmetic mean.  Applied at U108, the first heterogeneous rung, this rules out the
"pooling artefact" explanation of the band loss. -/
theorem pool_below_floor_of_seeds_below_floor {x y z : ℝ} (hx : x ∈ Ioo (-1:ℝ) 1)
    (hy : y ∈ Ioo (-1:ℝ) 1) (hz : z ∈ Ioo (-1:ℝ) 1) (hx0 : 0 ≤ x) (hy0 : 0 ≤ y) (hz0 : 0 ≤ z)
    (hxf : x < 0.55) (hyf : y < 0.55) (hzf : z < 0.55) :
    (x + y + z) / 3 ≤ fisherPool3 x y z ∧ fisherPool3 x y z < 0.55 := by
  refine ⟨fisherPool3_ge_mean hx0 hx.2 hy0 hy.2 hz0 hz.2, ?_⟩
  have hle := fisherPool3_le_max hx hy hz
  have : max x (max y z) < 0.55 := by
    rcases le_total x (max y z) with h | h
    · rw [max_eq_right h]
      rcases le_total y z with h' | h'
      · rw [max_eq_right h']; exact hzf
      · rw [max_eq_left h']; exact hyf
    · rw [max_eq_left h]; exact hxf
  linarith

/-! ## Section 5. The limit form: a persistent advantage is a permanent certificate -/

/-- **Limit decorrelation.**  If the dial ladder `a`, the baseline ladder `b` and their mutual
correlation `c` all converge, and every rung satisfies Gram positivity, then the limiting
dial/baseline correlation obeys `C ≤ 1 − (A−B)²/2`.  Thus a plateau with a persistent
advantage certifies a *permanent* decorrelation between the dial and the count baseline. -/
theorem limit_decorrelation {a b c : ℕ → ℝ} {A B C : ℝ}
    (ha : Tendsto a atTop (nhds A)) (hb : Tendsto b atTop (nhds B))
    (hc : Tendsto c atTop (nhds C)) (ha1 : ∀ n, |a n| ≤ 1) (hb1 : ∀ n, |b n| ≤ 1)
    (hdet : ∀ n, 0 ≤ 1 + 2 * a n * b n * c n - (a n) ^ 2 - (b n) ^ 2 - (c n) ^ 2) :
    C ≤ 1 - (A - B) ^ 2 / 2 := by
  have hbound : ∀ n, c n ≤ 1 - (a n - b n) ^ 2 / 2 := fun n =>
    corr_le_of_advantage (ha1 n) (hb1 n) (hdet n)
  have hlim : Tendsto (fun n => 1 - (a n - b n) ^ 2 / 2) atTop (nhds (1 - (A - B) ^ 2 / 2)) := by
    exact ((ha.sub hb).pow 2).div_const 2 |>.const_sub 1
  exact le_of_tendsto_of_tendsto' hc hlim hbound

/-- The U108 instance of the limit certificate: with the CI lower edge `δ ≥ 0.043` maintained
along the plateau, the limiting dial/baseline correlation is at most `0.9990755`. -/
theorem u108_limit_certificate {a b c : ℕ → ℝ} {A B C : ℝ}
    (ha : Tendsto a atTop (nhds A)) (hb : Tendsto b atTop (nhds B))
    (hc : Tendsto c atTop (nhds C)) (ha1 : ∀ n, |a n| ≤ 1) (hb1 : ∀ n, |b n| ≤ 1)
    (hdet : ∀ n, 0 ≤ 1 + 2 * a n * b n * c n - (a n) ^ 2 - (b n) ^ 2 - (c n) ^ 2)
    (hadv : 0.043 ≤ A - B) :
    C ≤ 0.9990755 := by
  have h := limit_decorrelation ha hb hc ha1 hb1 hdet
  have hsq : (0.043:ℝ) ^ 2 ≤ (A - B) ^ 2 := by nlinarith
  nlinarith

end Catalog.Physics.TDialU108