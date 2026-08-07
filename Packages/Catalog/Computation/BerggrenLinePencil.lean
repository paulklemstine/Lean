import Computation.BerggrenGeodesicCensus

/-!
# The pencil of straight lines: separation, ideal endpoints, density and growth

Fourth research cycle on the hyperbolic picture of the Berggren tree.  The previous cycles
identified the visible "straight lines" through the centre of the Poincaré disk with the
Pell-like conics `m² - k m n - n² = 1` and showed that each such line is an isometric copy of
`ℕ` with spacing `2 log λ_k` (`λ_k` the `k`-th metallic ratio).

This file answers the remaining structural questions about the *pencil* of those lines.

## Main results

* `onConic_unique`, `lines_meet_only_at_base` — the lines are pairwise disjoint away from the
  centre: a lattice point with `m > 0` lying on two different conics must be the base
  point `(1,0)`.  So the picture really is a pencil of lines through one common point.
* `pellOrbit_ratio_tendsto` — the `k`-th line runs out to the **ideal point**
  `1/λ_k = (√(k²+4) - k)/2` of the boundary, a quadratic irrational; the error after `j` steps
  is `O(m_j^{-2})`.
* `card_pellOrbit_within_radius` — an exact count: the number of nodes of the `k`-th line inside
  the hyperbolic ball of radius `R` around the centre is `⌊R / (2 log λ_k)⌋ + 1`, i.e. the nodes
  have *constant linear density* `1/(2 log λ_k)` along the line.
* `hypotenuse_growth` — combining the ring theorem with the quantization of distance: the
  hypotenuse `c_j = m_j² + n_j²` of the `j`-th node of the `k`-th line satisfies
  `λ_k^{4j} / 2 < c_j < λ_k^{4j}`.  The hypotenuses along a straight line grow *exactly* like the
  fourth power of the metallic ratio.

## Lab notes

`k = 1`: `(m,n) = (2,1), (5,3), (13,8), …`, `c = 5, 34, 233, …` and `λ₁⁴ = 6.854…,
λ₁⁸ = 46.98…, λ₁¹² = 321.9…`; indeed `λ^{4j}/2 < c_j < λ^{4j}` (e.g. `3.43 < 5 < 6.85`,
`23.5 < 34 < 47.0`).  Ratios `n_j/m_j = 0.5, 0.6, 0.6153…` converge to `1/φ = 0.61803…`.
`k = 2`: `(5,2), (29,12), (169,70)`, `n/m → √2 - 1 = 0.41421…`.
-/

noncomputable section

open UpperHalfPlane Real Filter Topology

namespace BerggrenHyperbolic

/-! ## 1. The metallic ratio -/

/-- The `k`-th metallic ratio `λ_k = (k + √(k²+4))/2`, the positive root of `λ² = kλ + 1`. -/
def metallicRatio (k : ℝ) : ℝ := (k + Real.sqrt (k ^ 2 + 4)) / 2

lemma sq_sqrt_metallic (k : ℝ) : Real.sqrt (k ^ 2 + 4) ^ 2 = k ^ 2 + 4 :=
  Real.sq_sqrt (by positivity)

lemma one_lt_metallicRatio {k : ℝ} (hk : 1 ≤ k) : 1 < metallicRatio k := by
  have h : Real.sqrt (k ^ 2 + 4) ^ 2 = k ^ 2 + 4 := sq_sqrt_metallic k
  have hnn : 0 ≤ Real.sqrt (k ^ 2 + 4) := Real.sqrt_nonneg _
  rw [metallicRatio]
  nlinarith

lemma metallicRatio_pos {k : ℝ} (hk : 0 < k) : 0 < metallicRatio k := by
  have := Real.sqrt_nonneg (k ^ 2 + 4)
  rw [metallicRatio]; linarith

lemma metallicRatio_sq (k : ℝ) : metallicRatio k ^ 2 = k * metallicRatio k + 1 := by
  have h : Real.sqrt (k ^ 2 + 4) ^ 2 = k ^ 2 + 4 := sq_sqrt_metallic k
  rw [metallicRatio]; nlinarith

/-- The reciprocal of the metallic ratio is the positive root of `1 - k x - x² = 0`. -/
lemma inv_metallicRatio_root {k : ℝ} (hk : 0 < k) :
    1 - k * (1 / metallicRatio k) - (1 / metallicRatio k) ^ 2 = 0 := by
  have hpos := metallicRatio_pos hk
  have hsq := metallicRatio_sq k
  field_simp
  nlinarith

lemma inv_metallicRatio_mem {k : ℝ} (hk : 1 ≤ k) : 0 < 1 / metallicRatio k ∧
    1 / metallicRatio k < 1 := by
  have h1 := one_lt_metallicRatio hk
  constructor
  · positivity
  · rw [div_lt_one (by linarith)]; linarith

/-- The Pell step length is positive. -/
lemma pellStepLength_pos {k : ℝ} (hk : 1 ≤ k) : 0 < pellStepLength k := by
  have h := exp_step_eq_metallic_sq k (by linarith)
  have hlam : 1 < metallicRatio k := one_lt_metallicRatio hk
  have h1 : (1 : ℝ) < ((k + Real.sqrt (k ^ 2 + 4)) / 2) ^ 2 := by
    rw [metallicRatio] at hlam
    nlinarith [Real.sqrt_nonneg (k ^ 2 + 4)]
  have h2 : Real.exp 0 < Real.exp (pellStepLength k) := by
    rw [Real.exp_zero, h]; exact h1
  exact Real.exp_lt_exp.mp h2

/-! ## 2. Separation: the lines meet only at the centre -/

/-- A lattice point with nonzero coordinates lies on at most one conic. -/
theorem onConic_unique {k k' : ℤ} {p : ℤ × ℤ} (h : OnConic k p) (h' : OnConic k' p)
    (hp1 : p.1 ≠ 0) (hp2 : p.2 ≠ 0) : k = k' := by
  simp only [OnConic] at h h'
  have hz : (k - k') * (p.1 * p.2) = 0 := by ring_nf; ring_nf at h h' ⊢; linarith
  rcases mul_eq_zero.1 hz with hk | hmn
  · linarith [sub_eq_zero.1 hk]
  · rcases mul_eq_zero.1 hmn with h1 | h2
    · exact absurd h1 hp1
    · exact absurd h2 hp2

/-- **Pencil structure.**  Two different lines of the pencil share only the centre: any lattice
point with `m > 0` lying on two distinct conics is the base point `(1,0)`.  (No positivity
assumption on `n` is needed.) -/
theorem lines_meet_only_at_base {k k' : ℤ} (hkk : k ≠ k') {p : ℤ × ℤ} (h : OnConic k p)
    (h' : OnConic k' p) (hm : 0 < p.1) : p = (1, 0) := by
  have hp2 : p.2 = 0 := by
    by_contra hne
    exact hkk (onConic_unique h h' (by omega) hne)
  simp only [OnConic, hp2] at h
  have : p.1 = 1 := by nlinarith
  exact Prod.ext this hp2

/-! ## 3. Growth of the orbit coordinates -/

theorem pellOrbit_fst_ge {k : ℤ} (hk : 0 < k) (j : ℕ) : (j : ℤ) + 1 ≤ (pellOrbit k j).1 := by
  induction j with
  | zero => simp [pellOrbit]
  | succ j ih =>
      obtain ⟨h1, h2⟩ := pellOrbit_pos k hk j
      have : (pellOrbit k (j + 1)).1 = (k ^ 2 + 1) * (pellOrbit k j).1 + k * (pellOrbit k j).2 := by
        simp only [pellOrbit, pellStep]
      push_cast
      nlinarith

/-- From the first step on, every orbit point has the shape of a genuine Euclid seed bound
`1 ≤ n` and `n + 1 ≤ m`. -/
theorem pellOrbit_seed_bounds {k : ℤ} (hk : 0 < k) (j : ℕ) :
    1 ≤ (pellOrbit k (j + 1)).2 ∧ (pellOrbit k (j + 1)).2 + 1 ≤ (pellOrbit k (j + 1)).1 := by
  obtain ⟨h1, h2⟩ := pellOrbit_pos k hk j
  have e1 : (pellOrbit k (j + 1)).1 = (k ^ 2 + 1) * (pellOrbit k j).1 + k * (pellOrbit k j).2 := by
    simp only [pellOrbit, pellStep]
  have e2 : (pellOrbit k (j + 1)).2 = k * (pellOrbit k j).1 + (pellOrbit k j).2 := by
    simp only [pellOrbit, pellStep]
  constructor
  · rw [e2]; nlinarith
  · rw [e1, e2]
    nlinarith [mul_nonneg (by linarith : (0:ℤ) ≤ k - 1) h2,
      mul_le_mul_of_nonneg_left (by nlinarith : (1:ℤ) ≤ k ^ 2 - k + 1) h1.le]

/-! ## 4. The ideal endpoint of a line is a metallic quadratic irrational -/

/-- Quantitative convergence: the slope `n_j / m_j` of the `j`-th node approaches `1/λ_k` with
error at most `m_j^{-2}`. -/
theorem pellOrbit_ratio_error {k : ℤ} (hk : 0 < k) (j : ℕ) :
    |((pellOrbit k j).2 : ℝ) / ((pellOrbit k j).1 : ℝ) - 1 / metallicRatio (k : ℝ)|
      ≤ 1 / ((j : ℝ) + 1) ^ 2 := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  obtain ⟨hp1, hp2⟩ := pellOrbit_pos k hk j
  have hm : (0 : ℝ) < ((pellOrbit k j).1 : ℝ) := by exact_mod_cast hp1
  have hn : (0 : ℝ) ≤ ((pellOrbit k j).2 : ℝ) := by exact_mod_cast hp2
  have hmj : ((j : ℝ) + 1) ≤ ((pellOrbit k j).1 : ℝ) := by
    have h := pellOrbit_fst_ge hk j
    exact_mod_cast h
  have hc : ((pellOrbit k j).1 : ℝ) ^ 2
      - (k : ℝ) * ((pellOrbit k j).1 : ℝ) * ((pellOrbit k j).2 : ℝ)
      - ((pellOrbit k j).2 : ℝ) ^ 2 = 1 := by
    have h := onConic_pellOrbit k j
    simp only [OnConic] at h
    exact_mod_cast congrArg (fun x : ℤ => (x : ℝ)) h
  set m : ℝ := ((pellOrbit k j).1 : ℝ)
  set n : ℝ := ((pellOrbit k j).2 : ℝ)
  set r : ℝ := n / m with hr
  set s : ℝ := 1 / metallicRatio (k : ℝ) with hs
  have hs0 : 0 < s := by
    rw [hs]
    exact one_div_pos.mpr (metallicRatio_pos (by linarith))
  have hsr : 1 - (k : ℝ) * s - s ^ 2 = 0 := inv_metallicRatio_root (by linarith)
  have hrr : 1 - (k : ℝ) * r - r ^ 2 = 1 / m ^ 2 := by
    rw [hr]
    field_simp
    nlinarith [hc]
  have hr0 : 0 ≤ r := by rw [hr]; positivity
  have hm2 : (0 : ℝ) < m ^ 2 := by positivity
  have key : (s - r) * ((k : ℝ) + r + s) = 1 / m ^ 2 := by nlinarith
  have hfac : (1 : ℝ) ≤ (k : ℝ) + r + s := by linarith
  have hpos : 0 < s - r := by
    by_contra hcon
    push_neg at hcon
    nlinarith [one_div_pos.mpr hm2]
  rw [abs_of_nonpos (by linarith)]
  have h1 : s - r ≤ 1 / m ^ 2 := by nlinarith
  have h2 : 1 / m ^ 2 ≤ 1 / ((j : ℝ) + 1) ^ 2 := by
    apply one_div_le_one_div_of_le (by positivity)
    nlinarith
  linarith

/-- **Ideal endpoint.**  The `k`-th straight line of the picture runs out to the boundary point
`1/λ_k = (√(k²+4) - k)/2`; distinct `k` give distinct ideal points, so the lines really do fan
out in different directions. -/
theorem pellOrbit_ratio_tendsto {k : ℤ} (hk : 0 < k) :
    Tendsto (fun j : ℕ => ((pellOrbit k j).2 : ℝ) / ((pellOrbit k j).1 : ℝ)) atTop
      (𝓝 (1 / metallicRatio (k : ℝ))) := by
  have hbig : Tendsto (fun j : ℕ => ((j : ℝ) + 1) ^ 2) atTop atTop :=
    (tendsto_pow_atTop (n := 2) two_ne_zero).comp
      (tendsto_atTop_add_const_right _ 1 tendsto_natCast_atTop_atTop)
  have hzero : Tendsto (fun j : ℕ => 1 / ((j : ℝ) + 1) ^ 2) atTop (𝓝 0) := by
    simpa [one_div] using hbig.inv_tendsto_atTop
  have h := squeeze_zero_norm
    (f := fun j : ℕ => ((pellOrbit k j).2 : ℝ) / ((pellOrbit k j).1 : ℝ)
      - 1 / metallicRatio (k : ℝ))
    (a := fun j : ℕ => 1 / ((j : ℝ) + 1) ^ 2) (fun j => pellOrbit_ratio_error hk j) hzero
  exact tendsto_sub_nhds_zero_iff.mp h

/-! ## 5. Exact linear density of nodes along a line -/

/-- **Counting theorem.**  The number of nodes of the `k`-th line inside the hyperbolic ball of
radius `R` about the centre is exactly `⌊R / (2 log λ_k)⌋ + 1`. -/
theorem card_pellOrbit_within_radius {k : ℤ} (hk : 0 < k) {R : ℝ} (hR : 0 ≤ R) :
    {j : ℕ | dist base (node ((pellOrbit k j).1 : ℝ) ((pellOrbit k j).2 : ℝ)) ≤ R}.ncard
      = ⌊R / pellStepLength (k : ℝ)⌋₊ + 1 := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hL : 0 < pellStepLength (k : ℝ) := pellStepLength_pos hkR
  have hset : {j : ℕ | dist base (node ((pellOrbit k j).1 : ℝ) ((pellOrbit k j).2 : ℝ)) ≤ R}
      = Set.Iic ⌊R / pellStepLength (k : ℝ)⌋₊ := by
    ext j
    simp only [Set.mem_setOf_eq, Set.mem_Iic, dist_base_pellOrbit k hk j]
    rw [Nat.le_floor_iff (by positivity), le_div_iff₀ hL]
  rw [hset, ← Finset.coe_Iic, Set.ncard_coe_finset, Nat.card_Iic]

/-! ## 6. Hypotenuses along a line grow like `λ_k^{4j}` -/

/-- **Exponential growth of the hypotenuse.**  For the `j`-th node of the `k`-th line the
hypotenuse `c = m² + n²` is squeezed between `λ_k^{4j}/2` and `λ_k^{4j}`. -/
theorem hypotenuse_growth {k : ℤ} (hk : 0 < k) (j : ℕ) :
    ((pellOrbit k (j + 1)).1 : ℝ) ^ 2 + ((pellOrbit k (j + 1)).2 : ℝ) ^ 2
        < metallicRatio (k : ℝ) ^ (4 * (j + 1)) ∧
      metallicRatio (k : ℝ) ^ (4 * (j + 1))
        < 2 * (((pellOrbit k (j + 1)).1 : ℝ) ^ 2 + ((pellOrbit k (j + 1)).2 : ℝ) ^ 2) := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  obtain ⟨hn1, hnm⟩ := pellOrbit_seed_bounds hk j
  have hn1' : (1 : ℝ) ≤ ((pellOrbit k (j + 1)).2 : ℝ) := by exact_mod_cast hn1
  have hnm' : ((pellOrbit k (j + 1)).2 : ℝ) + 1 ≤ ((pellOrbit k (j + 1)).1 : ℝ) := by
    exact_mod_cast hnm
  set m : ℝ := ((pellOrbit k (j + 1)).1 : ℝ)
  set n : ℝ := ((pellOrbit k (j + 1)).2 : ℝ)
  have hc : (0 : ℝ) < m ^ 2 + n ^ 2 := by nlinarith
  have hd := dist_base_pellOrbit k hk (j + 1)
  have hlow := log_lt_dist_base_node m n (by linarith) hnm'
  have hupp := dist_base_node_lt_log m n hn1' hnm'
  rw [hd] at hlow hupp
  have hexp : Real.exp (2 * ((j : ℝ) + 1) * pellStepLength (k : ℝ))
      = metallicRatio (k : ℝ) ^ (4 * (j + 1)) := by
    have h1 : (2 : ℝ) * ((j : ℝ) + 1) * pellStepLength (k : ℝ)
        = ((2 * (j + 1) : ℕ) : ℝ) * pellStepLength (k : ℝ) := by push_cast; ring
    rw [h1, Real.exp_nat_mul, exp_step_eq_metallic_sq (k : ℝ) (by linarith)]
    rw [show ((k : ℝ) + Real.sqrt ((k : ℝ) ^ 2 + 4)) / 2 = metallicRatio (k : ℝ) from rfl,
      ← pow_mul]
    ring_nf
  constructor
  · have h1 : Real.log (m ^ 2 + n ^ 2) < 2 * ((j : ℝ) + 1) * pellStepLength (k : ℝ) := by
      push_cast at hlow ⊢
      linarith
    calc m ^ 2 + n ^ 2 = Real.exp (Real.log (m ^ 2 + n ^ 2)) := (Real.exp_log hc).symm
      _ < Real.exp (2 * ((j : ℝ) + 1) * pellStepLength (k : ℝ)) := Real.exp_lt_exp.mpr h1
      _ = _ := hexp
  · have h2 : 2 * ((j : ℝ) + 1) * pellStepLength (k : ℝ) < Real.log (2 * (m ^ 2 + n ^ 2)) := by
      push_cast at hupp ⊢
      linarith
    calc metallicRatio (k : ℝ) ^ (4 * (j + 1))
        = Real.exp (2 * ((j : ℝ) + 1) * pellStepLength (k : ℝ)) := hexp.symm
      _ < Real.exp (Real.log (2 * (m ^ 2 + n ^ 2))) := Real.exp_lt_exp.mpr h2
      _ = 2 * (m ^ 2 + n ^ 2) := Real.exp_log (by positivity)

end BerggrenHyperbolic