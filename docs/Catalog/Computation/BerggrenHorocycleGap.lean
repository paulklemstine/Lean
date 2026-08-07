import Computation.BerggrenLinePencil

/-!
# Cycle 5: horocycle rigidity, the metallic gap, and the linear density of the pencil

Cycles 1–4 (`BerggrenHyperbolicGeodesics`, `BerggrenPellClassification`,
`BerggrenGeodesicCensus`, `BerggrenLinePencil`) established the metric dictionary for the
Berggren tree in the hyperbolic plane, identified the exact straight lines through the centre
with the Pell-like conics `m² - k m n - n² = 1`, and computed the per-line node count in a ball.

This file closes three of the questions left open there.

## Main results

* `seeds_on_horocycle_finite`, `horocycle_vs_geodesic` — **horocycle rigidity** (the second half
  of Conjecture 5).  A horocycle based at `∞` is the locus `im = t`, i.e. `m` constant, and it
  carries only finitely many Euclid seeds, in sharp contrast with the geodesics of the pencil,
  each of which carries infinitely many (`seeds_on_geodesic_infinite`).  Curvature `1` is
  therefore arithmetically invisible while curvature `0` is not.
* `pellStepLength_eq_two_log_metallic`, `pellStepLength_strictMono`,
  `two_log_goldenRatio_le_pellStepLength` — **the metallic gap** (Sub-conjecture B).  The step
  length of the `k`-th line is exactly `2 log λ_k`, it is strictly increasing in `k`, and it is
  therefore bounded below by `2 log φ = 0.9624…`: no line of the pencil can have its nodes
  packed more tightly than the golden line.
* `metallicRatio_pow_four_gt_six`, `hypotenuse_ratio_bounds` — the growth-exponent form of the
  same gap: consecutive hypotenuses along a line satisfy
  `λ_k⁴/2 < c_{j+1}/c_j < 2 λ_k⁴` with `λ_k⁴ > 6`.
* `lineCount_lt_and_le`, `lineCount_le_golden`, `sum_lineCount_bounds` — **the counting law**
  (Conjecture 4, second half).  Writing `N_k(R)` for the number of nodes of the `k`-th line in
  the ball of radius `R`, one has `R/(2 log λ_k) < N_k(R) ≤ R/(2 log λ_k) + 1`, the uniform
  bound `N_k(R) ≤ R/(2 log φ) + 1`, and
  `R Σ_{k≤K} (2 log λ_k)⁻¹ ≤ Σ_{k≤K} N_k(R) ≤ R Σ_{k≤K} (2 log λ_k)⁻¹ + K`:
  the collinear part of the picture grows *linearly* in the radius, one line at a time.

## Lab notes

Metallic data, `λ_k = (k+√(k²+4))/2`, step `2 log λ_k`, growth exponent `λ_k⁴`:

| k | λ_k      | 2 log λ_k | λ_k⁴     |
|---|----------|-----------|----------|
| 1 | 1.618034 | 0.962424  | 6.8541   |
| 2 | 2.414214 | 1.762747  | 33.9706  |
| 3 | 3.302776 | 2.389526  | 118.9916 |
| 4 | 4.236068 | 2.887271  | 321.9969 |
| 5 | 5.192582 | 3.294462  | 726.9986 |

so the step length is increasing and its infimum `0.9624…` is attained at `k = 1`, exactly as
`pellStepLength_strictMono` and `two_log_goldenRatio_le_pellStepLength` assert.

Node counts in the ball `R = 10` (formula `⌊R/(2 log λ_k)⌋+1`):
`N_1 = 11, N_2 = 6, N_3 = 5, N_4 = 4, N_5 = 4, N_6 = … = N_10 = 3`, total `45` over `k ≤ 10` —
linear in `R`, while the number of seeds in the ball is of order `e^{2R}`.

Seeds on the horocycle `im = 1/m` (i.e. with first coordinate `m`), `m = 2,…,12`:
`1, 1, 2, 2, 2, 3, 4, 3, 4, 5, 4` — always finite (at most `m - 1`), and equal to the number of
`n < m` coprime to `m` of opposite parity.
-/

noncomputable section

open UpperHalfPlane Real

namespace BerggrenHyperbolic

/-! ## 1. Horocycle rigidity -/

/-- The horocycle of the upper half-plane based at the ideal point `∞`, at Euclidean height
`t`.  In the disk picture these are the circles tangent to the boundary at the image of `∞`. -/
def horocycle (t : ℝ) : Set ℍ := {w : ℍ | w.im = t}

/-- A seed node lies on the horocycle of height `t` exactly when `t = 1/m`; in particular the
horocycles based at `∞` are precisely the level sets of the first Euclid parameter. -/
theorem mem_horocycle_iff {m n : ℝ} (hm : 0 < m) (t : ℝ) :
    node m n ∈ horocycle t ↔ t = 1 / m := by
  simp [horocycle, node_im _ hm, eq_comm]

/-- **Horocycle rigidity.**  Every horocycle based at `∞` carries only finitely many Euclid
seeds: the condition `im = t` pins the first parameter `m`, and then `0 < n < m` leaves finitely
many choices.  This is the curvature-`1` half of the curvature dictionary. -/
theorem seeds_on_horocycle_finite (t : ℝ) :
    {p : ℤ × ℤ | IsSeed p.1 p.2 ∧ node (p.1 : ℝ) (p.2 : ℝ) ∈ horocycle t}.Finite := by
  by_cases ht : 0 < t
  · refine Set.Finite.subset (Finset.Icc ((0 : ℤ), (0 : ℤ)) (⌈1 / t⌉, ⌈1 / t⌉)).finite_toSet ?_
    rintro ⟨m, n⟩ ⟨hs, hh⟩
    have hm : (0 : ℤ) < m := lt_trans hs.npos hs.lt
    have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
    have ht' : t = 1 / (m : ℝ) := (mem_horocycle_iff hmR t).1 hh
    have hmeq : (m : ℝ) = 1 / t := by
      rw [ht']; field_simp
    have hle : (m : ℝ) ≤ (⌈1 / t⌉ : ℝ) := by
      rw [hmeq]; exact Int.le_ceil _
    have hmle : m ≤ ⌈1 / t⌉ := by exact_mod_cast hle
    have hn : 0 < n := hs.npos
    have hnm : n < m := hs.lt
    simp only [Finset.coe_Icc, Set.mem_Icc, Prod.mk_le_mk]
    exact ⟨⟨by omega, by omega⟩, ⟨hmle, by omega⟩⟩
  · refine Set.Finite.subset Set.finite_empty ?_
    rintro ⟨m, n⟩ ⟨hs, hh⟩
    exfalso
    have hm : (0 : ℤ) < m := lt_trans hs.npos hs.lt
    have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
    have ht' : t = 1 / (m : ℝ) := (mem_horocycle_iff hmR t).1 hh
    exact ht (by rw [ht']; positivity)

/-- **The curvature dichotomy.**  For every `k ≥ 1` the `k`-th geodesic of the pencil carries
infinitely many Euclid seeds, while *no* horocycle based at `∞` carries more than finitely
many. -/
theorem horocycle_vs_geodesic (k : ℤ) (hk : 0 < k) (t : ℝ) :
    {p : ℤ × ℤ | OnConic k p ∧ 0 < p.2 ∧ p.2 < p.1 ∧ Odd (p.1 + p.2)}.Infinite ∧
      {p : ℤ × ℤ | IsSeed p.1 p.2 ∧ node (p.1 : ℝ) (p.2 : ℝ) ∈ horocycle t}.Finite :=
  ⟨seeds_on_geodesic_infinite k hk, seeds_on_horocycle_finite t⟩

/-! ## 2. The metallic gap -/

lemma metallicRatio_lt_metallicRatio {k k' : ℝ} (hk : 0 ≤ k) (h : k < k') :
    metallicRatio k < metallicRatio k' := by
  have h1 : Real.sqrt (k ^ 2 + 4) < Real.sqrt (k' ^ 2 + 4) :=
    Real.sqrt_lt_sqrt (by positivity) (by nlinarith)
  simp only [metallicRatio]
  linarith

lemma metallicRatio_one : metallicRatio 1 = (1 + Real.sqrt 5) / 2 := by
  norm_num [metallicRatio]

/-- The step length of the `k`-th line is exactly `2 log λ_k`. -/
theorem pellStepLength_eq_two_log_metallic {k : ℝ} (hk : 0 < k) :
    pellStepLength k = 2 * Real.log (metallicRatio k) := by
  have h : Real.exp (pellStepLength k) = metallicRatio k ^ 2 := exp_step_eq_metallic_sq k hk
  have hpos : 0 < metallicRatio k := metallicRatio_pos hk
  calc pellStepLength k = Real.log (Real.exp (pellStepLength k)) := (Real.log_exp _).symm
    _ = Real.log (metallicRatio k ^ 2) := by rw [h]
    _ = 2 * Real.log (metallicRatio k) := by rw [Real.log_pow]; push_cast; ring

/-- **The lines get sparser as `k` grows.**  The spacing `2 log λ_k` is strictly increasing. -/
theorem pellStepLength_strictMono {k k' : ℝ} (hk : 0 < k) (h : k < k') :
    pellStepLength k < pellStepLength k' := by
  rw [pellStepLength_eq_two_log_metallic hk, pellStepLength_eq_two_log_metallic (hk.trans h)]
  have hlt := metallicRatio_lt_metallicRatio hk.le h
  have h0 := metallicRatio_pos hk
  linarith [Real.log_lt_log h0 hlt]

/-- **Metallic gap.**  Every line of the pencil has spacing at least `2 log φ = 0.9624…`, the
golden value, attained exactly by the first line `k = 1`. -/
theorem two_log_goldenRatio_le_pellStepLength {k : ℝ} (hk : 1 ≤ k) :
    2 * Real.log ((1 + Real.sqrt 5) / 2) ≤ pellStepLength k := by
  have h1 : pellStepLength 1 = 2 * Real.log ((1 + Real.sqrt 5) / 2) := by
    rw [pellStepLength_eq_two_log_metallic one_pos, metallicRatio_one]
  rcases eq_or_lt_of_le hk with h | h
  · rw [← h, h1]
  · exact le_of_lt (h1 ▸ pellStepLength_strictMono one_pos h)

lemma sqrt_five_bounds : 2.2 < Real.sqrt 5 ∧ Real.sqrt 5 < 2.25 := by
  have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)
  have hnn : 0 ≤ Real.sqrt 5 := Real.sqrt_nonneg 5
  constructor <;> nlinarith

/-- The growth exponent along any line exceeds `6`; the extremal value is
`φ⁴ = 6.854…`, reached on the golden line. -/
theorem metallicRatio_pow_four_gt_six {k : ℝ} (hk : 1 ≤ k) : 6 < metallicRatio k ^ 4 := by
  obtain ⟨h2, _⟩ := sqrt_five_bounds
  have hgold : (1.6 : ℝ) < metallicRatio 1 := by rw [metallicRatio_one]; linarith
  have hk1 : metallicRatio 1 ≤ metallicRatio k := by
    rcases eq_or_lt_of_le hk with h | h
    · rw [h]
    · exact (metallicRatio_lt_metallicRatio zero_le_one h).le
  have hlt : (1.6 : ℝ) < metallicRatio k := lt_of_lt_of_le hgold hk1
  have h4 : (1.6 : ℝ) ^ 4 < metallicRatio k ^ 4 := by gcongr
  nlinarith [h4]

/-- The hypotenuse of the `j`-th node of the `k`-th line. -/
def hyp (k : ℤ) (j : ℕ) : ℝ := ((pellOrbit k j).1 : ℝ) ^ 2 + ((pellOrbit k j).2 : ℝ) ^ 2

/-- **Geometric growth of the hypotenuses.**  Along the `k`-th line consecutive hypotenuses have
ratio between `λ_k⁴/2` and `2 λ_k⁴`; combined with `metallicRatio_pow_four_gt_six` no exactly
collinear family can grow more slowly than the golden rate. -/
theorem hypotenuse_ratio_bounds {k : ℤ} (hk : 0 < k) (j : ℕ) :
    metallicRatio (k : ℝ) ^ 4 / 2 * hyp k (j + 1) < hyp k (j + 2) ∧
      hyp k (j + 2) < 2 * metallicRatio (k : ℝ) ^ 4 * hyp k (j + 1) := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  obtain ⟨h1a, h1b⟩ := hypotenuse_growth hk j
  obtain ⟨h2a, h2b⟩ := hypotenuse_growth hk (j + 1)
  have hsplit : metallicRatio (k : ℝ) ^ (4 * (j + 1 + 1))
      = metallicRatio (k : ℝ) ^ 4 * metallicRatio (k : ℝ) ^ (4 * (j + 1)) := by
    rw [← pow_add]
    ring_nf
  have hlam : 0 < metallicRatio (k : ℝ) ^ 4 :=
    pow_pos (metallicRatio_pos (by linarith)) 4
  rw [hsplit] at h2a h2b
  simp only [hyp] at h1a h1b h2a h2b ⊢
  constructor
  · nlinarith [h1a, h2b, hlam]
  · nlinarith [h1b, h2a, hlam]

/-! ## 3. The counting law for the pencil -/

/-- The number of nodes of the `k`-th line inside the hyperbolic ball of radius `R` about the
centre `i`. -/
def lineCount (k : ℤ) (R : ℝ) : ℕ :=
  {j : ℕ | dist base (node ((pellOrbit k j).1 : ℝ) ((pellOrbit k j).2 : ℝ)) ≤ R}.ncard

theorem lineCount_eq {k : ℤ} (hk : 0 < k) {R : ℝ} (hR : 0 ≤ R) :
    lineCount k R = ⌊R / pellStepLength (k : ℝ)⌋₊ + 1 :=
  card_pellOrbit_within_radius hk hR

/-- **Linear density.**  The count on a line is `R/(2 log λ_k)` up to an additive `1`. -/
theorem lineCount_lt_and_le {k : ℤ} (hk : 0 < k) {R : ℝ} (hR : 0 ≤ R) :
    R / pellStepLength (k : ℝ) < lineCount k R ∧
      (lineCount k R : ℝ) ≤ R / pellStepLength (k : ℝ) + 1 := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hL : 0 < pellStepLength (k : ℝ) := pellStepLength_pos hkR
  have hnn : 0 ≤ R / pellStepLength (k : ℝ) := by positivity
  rw [lineCount_eq hk hR]
  constructor
  · push_cast
    exact Nat.lt_floor_add_one _
  · push_cast
    have := Nat.floor_le hnn
    linarith

/-- Uniformly in `k`, the golden spacing bounds the count on every line. -/
theorem lineCount_le_golden {k : ℤ} (hk : 0 < k) {R : ℝ} (hR : 0 ≤ R) :
    (lineCount k R : ℝ) ≤ R / (2 * Real.log ((1 + Real.sqrt 5) / 2)) + 1 := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hgold : 0 < 2 * Real.log ((1 + Real.sqrt 5) / 2) := by
    rw [← metallicRatio_one, ← pellStepLength_eq_two_log_metallic one_pos]
    exact pellStepLength_pos le_rfl
  have hle : 2 * Real.log ((1 + Real.sqrt 5) / 2) ≤ pellStepLength (k : ℝ) :=
    two_log_goldenRatio_le_pellStepLength hkR
  have := (lineCount_lt_and_le hk hR).2
  have hdiv : R / pellStepLength (k : ℝ) ≤ R / (2 * Real.log ((1 + Real.sqrt 5) / 2)) :=
    div_le_div_of_nonneg_left hR hgold hle
  linarith

/-- **Counting law for the whole pencil.**  Summing over the first `K` lines, the number of
exactly-collinear nodes in the ball of radius `R` is `R Σ_{k≤K}(2 log λ_k)⁻¹ + O(K)`: linear in
`R`, whereas the total number of seed nodes in the ball is exponential in `R`.  The visible
straight lines are a linearly thin skeleton of the picture. -/
theorem sum_lineCount_bounds (K : ℕ) {R : ℝ} (hR : 0 ≤ R) :
    R * ∑ k ∈ Finset.Icc 1 K, (pellStepLength (k : ℝ))⁻¹
        ≤ ∑ k ∈ Finset.Icc 1 K, (lineCount (k : ℤ) R : ℝ) ∧
      ∑ k ∈ Finset.Icc 1 K, (lineCount (k : ℤ) R : ℝ)
        ≤ R * ∑ k ∈ Finset.Icc 1 K, (pellStepLength (k : ℝ))⁻¹ + K := by
  have key : ∀ k ∈ Finset.Icc 1 K,
      R * (pellStepLength (k : ℝ))⁻¹ ≤ (lineCount (k : ℤ) R : ℝ) ∧
        (lineCount (k : ℤ) R : ℝ) ≤ R * (pellStepLength (k : ℝ))⁻¹ + 1 := by
    intro k hk
    have hk1 : 1 ≤ k := (Finset.mem_Icc.1 hk).1
    have hkz : (0 : ℤ) < (k : ℤ) := by exact_mod_cast hk1
    have hcast : (((k : ℤ) : ℝ)) = (k : ℝ) := by push_cast; ring
    have h := lineCount_lt_and_le hkz hR
    rw [hcast] at h
    exact ⟨by rw [← div_eq_mul_inv]; exact h.1.le, by rw [← div_eq_mul_inv]; exact h.2⟩
  rw [Finset.mul_sum]
  refine ⟨Finset.sum_le_sum fun k hk => (key k hk).1, ?_⟩
  calc ∑ k ∈ Finset.Icc 1 K, (lineCount (k : ℤ) R : ℝ)
      ≤ ∑ k ∈ Finset.Icc 1 K, (R * (pellStepLength (k : ℝ))⁻¹ + 1) :=
        Finset.sum_le_sum fun k hk => (key k hk).2
    _ = ∑ k ∈ Finset.Icc 1 K, R * (pellStepLength (k : ℝ))⁻¹ + K := by
        rw [Finset.sum_add_distrib]
        simp [Nat.card_Icc]

end BerggrenHyperbolic