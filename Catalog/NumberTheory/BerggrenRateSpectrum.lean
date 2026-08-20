import Catalog.NumberTheory.BerggrenSilverExtremal

/-!
# Hyperbolic–Pythagorean Geodesics, cycle X (part 2): the metric growth rate spectrum

Companion to `NumberTheory/BerggrenSilverExtremal.lean`.  That file settled the extremal
structure of the Berggren tree at a fixed depth; this one studies the *rates*
`d(i, z_k)/k` along infinite paths, and refutes conjecture I1 of cycle IX.

## Main results

* `middle_frequency_does_not_determine_rate` : two `B₁`-free periodic paths with the same
  middle-move frequency `1/2` have different rates (elementary rational bounds).
* `two_distinct_rates_at_frequency_half` : the same two paths have *exact* rates
  `½ log(2+√5) = 0.72181…` and `½ log(2+√3) = 0.65848…`, obtained from Binet expansions of
  the period matrices `[[4,1],[1,0]]` and `[[13,6],[2,1]]`.
* `tendsto_rate_of_geometric` : a reusable criterion — a geometric two-sided bound
  `c₁ λ^j ≤ m_j ≤ c₂ λ^j` along a word family of length `p j` forces the rate `log λ / p`.
* `berggren_spectrum_infinite` : for every `b` the `B₁`-free path `(B₂B₃^b)^∞` has exact
  rate `log ρ_b/(b+1) > 0` with `ρ_b = (1+b)+√((1+b)²+1)`, and these rates tend to `0`.
  Hence the growth spectrum contains infinitely many distinct interior points.
-/

namespace HyperbolicBerggrenGeodesics

open Real Filter Topology

noncomputable section

/-! ## Part E. Conjecture I1 is false: the rate is not a function of the `B₂`-frequency -/

/-- The hyperbolic distance from the base point to the node reached by the word `w`. -/
def wdist (w : List Move) : ℝ :=
  dist (hpoint (run w).1 (run w).2 (lt_trans (run_isSeed w).pos (run_isSeed w).lt))
    UpperHalfPlane.I

theorem wdist_ge_log (w : List Move) : Real.log (run w).1 ≤ wdist w :=
  (dist_window_log_fst (run_isSeed w).pos (run_isSeed w).lt).1

theorem wdist_le_log (w : List Move) : wdist w ≤ Real.log (run w).1 + Real.log 2 :=
  (dist_window_log_fst (run_isSeed w).pos (run_isSeed w).lt).2

/-- The `B₁`-free periodic word `(B₂B₃)^j`. -/
def wordA : ℕ → List Move
  | 0 => []
  | j + 1 => Move.R :: Move.M :: wordA j

/-- The `B₁`-free periodic word `(B₂B₂B₃B₃)^j`. -/
def wordB : ℕ → List Move
  | 0 => []
  | j + 1 => Move.R :: Move.R :: Move.M :: Move.M :: wordB j

theorem wordA_length (j : ℕ) : (wordA j).length = 2 * j := by
  induction j with
  | zero => rfl
  | succ j ih => simp [wordA, ih]; omega

theorem wordB_length (j : ℕ) : (wordB j).length = 4 * j := by
  induction j with
  | zero => rfl
  | succ j ih => simp [wordB, ih]; omega

theorem wordA_countM (j : ℕ) : countM (wordA j) = j := by
  induction j with
  | zero => rfl
  | succ j ih => simp [wordA, countM] at ih ⊢; omega

theorem wordB_countM (j : ℕ) : countM (wordB j) = 2 * j := by
  induction j with
  | zero => rfl
  | succ j ih => simp [wordB, countM] at ih ⊢; omega

theorem wordA_no_L (j : ℕ) : Move.L ∉ wordA j := by
  induction j with
  | zero => simp [wordA]
  | succ j ih => simp [wordA, ih]

theorem wordB_no_L (j : ℕ) : Move.L ∉ wordB j := by
  induction j with
  | zero => simp [wordB]
  | succ j ih => simp [wordB, ih]

/-- One period of `wordA` sends `(m,n)` to `(4m+n, m)`. -/
theorem wordA_step (j : ℕ) :
    (run (wordA (j + 1))).1 = 4 * (run (wordA j)).1 + (run (wordA j)).2 ∧
      (run (wordA (j + 1))).2 = (run (wordA j)).1 := by
  have hrun : run (wordA (j + 1)) = seedR (seedM (run (wordA j))) := rfl
  rw [hrun]
  simp [seedR, seedM]
  omega

/-- One period of `wordB` sends `(m,n)` to `(13m+6n, 2m+n)`. -/
theorem wordB_step (j : ℕ) :
    (run (wordB (j + 1))).1 = 13 * (run (wordB j)).1 + 6 * (run (wordB j)).2 ∧
      (run (wordB (j + 1))).2 = 2 * (run (wordB j)).1 + (run (wordB j)).2 := by
  have hrun : run (wordB (j + 1))
      = seedR (seedR (seedM (seedM (run (wordB j))))) := rfl
  rw [hrun]
  simp [seedR, seedM]
  omega

/-- Along `(B₂B₃)^j` the first coordinate is at least `2·4^j`: the rate is at least
`log 4 / 2 = log 2` per move. -/
theorem wordA_fst_ge (j : ℕ) : 2 * 4 ^ j ≤ (run (wordA j)).1 := by
  induction j with
  | zero => exact le_of_eq rfl
  | succ j ih =>
      have h := wordA_step j
      have hpow : (4 : ℕ) ^ (j + 1) = 4 * 4 ^ j := by ring
      omega

/-- The self-improving slope invariant along `(B₂B₂B₃B₃)^j`: from the first period on,
`6n ≤ m`. -/
theorem wordB_slope (j : ℕ) : 6 * (run (wordB (j + 1))).2 ≤ (run (wordB (j + 1))).1 := by
  induction j with
  | zero =>
      have h := wordB_step 0
      have h0 : run (wordB 0) = (2, 1) := rfl
      rw [h0] at h
      omega
  | succ j ih =>
      have h := wordB_step (j + 1)
      omega

/-- Along `(B₂B₂B₃B₃)^j` the first coordinate is at most `32·14^{j}` from the first period
on: the rate is at most `log 14 / 4 < log 2` per move. -/
theorem wordB_fst_le (j : ℕ) : (run (wordB (j + 1))).1 ≤ 32 * 14 ^ j := by
  induction j with
  | zero =>
      have h := wordB_step 0
      have h0 : run (wordB 0) = (2, 1) := rfl
      rw [h0] at h
      simp only [pow_zero, mul_one]
      omega
  | succ j ih =>
      have h := wordB_step (j + 1)
      have hs := wordB_slope j
      have hpow : (14 : ℕ) ^ (j + 1) = 14 * 14 ^ j := by ring
      omega

/-- The rate of the word `(B₂B₃)^j` is at least `log 2` at every period. -/
theorem wordA_rate_ge (j : ℕ) (hj : 0 < j) :
    Real.log 2 ≤ wdist (wordA j) / (wordA j).length := by
  have hjR : (0 : ℝ) < (j : ℝ) := by exact_mod_cast hj
  have hnat := wordA_fst_ge j
  have hcast : (2 : ℝ) * 4 ^ j ≤ ((run (wordA j)).1 : ℝ) := by
    have : ((2 * 4 ^ j : ℕ) : ℝ) ≤ (((run (wordA j)).1 : ℕ) : ℝ) := by exact_mod_cast hnat
    simpa using this
  have hlog : Real.log ((2 : ℝ) * 4 ^ j) ≤ Real.log (run (wordA j)).1 :=
    Real.log_le_log (by positivity) hcast
  rw [Real.log_mul (by norm_num) (by positivity), Real.log_pow] at hlog
  have hd := wdist_ge_log (wordA j)
  have hlog4 : Real.log 4 = 2 * Real.log 2 := by
    rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]; push_cast; ring
  rw [wordA_length j]
  rw [le_div_iff₀ (by positivity)]
  push_cast
  rw [hlog4] at hlog
  have hlog2 : (0 : ℝ) ≤ Real.log 2 := Real.log_nonneg (by norm_num)
  nlinarith

/-- The rate of the word `(B₂B₂B₃B₃)^{j+1}` is at most `(6 log 2 + j log 14)/(4j+4)`. -/
theorem wordB_dist_le (j : ℕ) :
    wdist (wordB (j + 1)) ≤ 6 * Real.log 2 + (j : ℝ) * Real.log 14 := by
  have hnat := wordB_fst_le j
  have hcast : ((run (wordB (j + 1))).1 : ℝ) ≤ 32 * 14 ^ j := by
    have : (((run (wordB (j + 1))).1 : ℕ) : ℝ) ≤ ((32 * 14 ^ j : ℕ) : ℝ) := by exact_mod_cast hnat
    simpa using this
  have hpos : (0 : ℝ) < ((run (wordB (j + 1))).1 : ℝ) := by
    have := (run_isSeed (wordB (j + 1))).pos
    have h2 := (run_isSeed (wordB (j + 1))).lt
    have : 0 < (run (wordB (j + 1))).1 := by omega
    exact_mod_cast this
  have hlog : Real.log (run (wordB (j + 1))).1 ≤ Real.log ((32 : ℝ) * 14 ^ j) :=
    Real.log_le_log hpos hcast
  rw [Real.log_mul (by norm_num) (by positivity), Real.log_pow] at hlog
  have h32 : Real.log 32 = 5 * Real.log 2 := by
    rw [show (32 : ℝ) = 2 ^ 5 by norm_num, Real.log_pow]; push_cast; ring
  rw [h32] at hlog
  have hd := wdist_le_log (wordB (j + 1))
  linarith

/-- `4 log 2 > log 14`: the arithmetic heart of the separation `log 14/4 < log 2`. -/
theorem log_fourteen_lt : Real.log 14 < 4 * Real.log 2 := by
  have h : Real.log 14 < Real.log 16 := Real.log_lt_log (by norm_num) (by norm_num)
  have h16 : Real.log 16 = 4 * Real.log 2 := by
    rw [show (16 : ℝ) = 2 ^ 4 by norm_num, Real.log_pow]; push_cast; ring
  linarith

/-- **Conjecture I1 is false.**  Two `B₁`-free periodic Berggren paths with the *same*
middle-move frequency `1/2` have different growth rates: `(B₂B₃)^j` has rate `≥ log 2` at
every depth, whereas `(B₂B₂B₃B₃)^j` has rate `< log 2` from some depth on.  So the metric
growth rate is not a function of the asymptotic `B₂`-frequency, and in particular it is not
a strictly increasing function of it. -/
theorem middle_frequency_does_not_determine_rate :
    (∀ j : ℕ, 2 * countM (wordA j) = (wordA j).length ∧
        2 * countM (wordB j) = (wordB j).length) ∧
      (∀ j : ℕ, Move.L ∉ wordA j ∧ Move.L ∉ wordB j) ∧
      (∀ j : ℕ, 0 < j → Real.log 2 ≤ wdist (wordA j) / (wordA j).length) ∧
      (∃ J : ℕ, ∀ j : ℕ, J ≤ j → wdist (wordB j) / (wordB j).length < Real.log 2) := by
  refine ⟨fun j => ⟨by rw [wordA_countM, wordA_length], by rw [wordB_countM, wordB_length]; ring⟩,
    fun j => ⟨wordA_no_L j, wordB_no_L j⟩, wordA_rate_ge, ?_⟩

  have hgap : 0 < 4 * Real.log 2 - Real.log 14 := by linarith [log_fourteen_lt]
  obtain ⟨i₀, hi₀⟩ := exists_nat_gt (2 * Real.log 2 / (4 * Real.log 2 - Real.log 14))
  refine ⟨i₀ + 1, ?_⟩
  intro j hj
  obtain ⟨i, rfl⟩ : ∃ i, j = i + 1 := ⟨j - 1, by omega⟩
  have hi : (i₀ : ℝ) ≤ (i : ℝ) := by exact_mod_cast (by omega : i₀ ≤ i)
  have hkey : 2 * Real.log 2 < (i : ℝ) * (4 * Real.log 2 - Real.log 14) := by
    rw [div_lt_iff₀ hgap] at hi₀
    nlinarith
  have hdist := wordB_dist_le i
  have hlen : ((wordB (i + 1)).length : ℝ) = 4 * (i : ℝ) + 4 := by
    rw [wordB_length]; push_cast; ring
  rw [hlen, div_lt_iff₀ (by positivity)]
  nlinarith

/-! ## Part F. The two rates, exactly: `½ log(2+√5)` versus `½ log(2+√3)` -/

/-- The Perron root `2+√5` of one period `B₂B₃` (the map `(m,n) ↦ (4m+n, m)`). -/
def alphaA : ℝ := 2 + Real.sqrt 5

/-- Its conjugate `2−√5`. -/
def betaA : ℝ := 2 - Real.sqrt 5

/-- The Perron root `7+4√3 = (2+√3)²` of one period `B₂B₂B₃B₃`
(the map `(m,n) ↦ (13m+6n, 2m+n)`). -/
def gammaB : ℝ := 7 + 4 * Real.sqrt 3

/-- Its conjugate `7−4√3`. -/
def deltaB : ℝ := 7 - 4 * Real.sqrt 3

theorem sqrt_five_sq : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)

theorem sqrt_three_sq : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)

theorem sqrt_five_bounds : (2.23 : ℝ) < Real.sqrt 5 ∧ Real.sqrt 5 < 2.24 := by
  constructor
  · nlinarith [sqrt_five_sq, Real.sqrt_nonneg 5]
  · nlinarith [sqrt_five_sq, Real.sqrt_nonneg 5]

theorem sqrt_three_bounds : (1.73 : ℝ) < Real.sqrt 3 ∧ Real.sqrt 3 < 1.74 := by
  constructor
  · nlinarith [sqrt_three_sq, Real.sqrt_nonneg 3]
  · nlinarith [sqrt_three_sq, Real.sqrt_nonneg 3]

/-- `γ = (2+√3)²`, so the rate of `(B₂B₂B₃B₃)^∞` is `½ log(2+√3)`. -/
theorem gammaB_eq_sq : gammaB = (2 + Real.sqrt 3) ^ 2 := by
  simp only [gammaB]
  linear_combination -sqrt_three_sq

/-- **Binet formula along `(B₂B₃)^j`.** -/
theorem wordA_binet (j : ℕ) :
    ((run (wordA j)).1 : ℝ) = (alphaA ^ (j + 1) + betaA ^ (j + 1)) / 2 ∧
      ((run (wordA j)).2 : ℝ) = (alphaA ^ j + betaA ^ j) / 2 := by
  have hA2 : alphaA ^ 2 = 4 * alphaA + 1 := by
    simp only [alphaA]; linear_combination sqrt_five_sq
  have hB2 : betaA ^ 2 = 4 * betaA + 1 := by
    simp only [betaA]; linear_combination sqrt_five_sq
  induction j with
  | zero =>
      have h0 : run (wordA 0) = (2, 1) := rfl
      rw [h0]
      constructor
      · show ((2 : ℕ) : ℝ) = _
        simp only [alphaA, betaA]
        norm_num
      · show ((1 : ℕ) : ℝ) = _
        norm_num
  | succ j ih =>
      have hA : alphaA ^ (j + 2) = 4 * alphaA ^ (j + 1) + alphaA ^ j := by
        have h : alphaA ^ (j + 2) = alphaA ^ j * alphaA ^ 2 := by ring
        rw [h, hA2]; ring
      have hB : betaA ^ (j + 2) = 4 * betaA ^ (j + 1) + betaA ^ j := by
        have h : betaA ^ (j + 2) = betaA ^ j * betaA ^ 2 := by ring
        rw [h, hB2]; ring
      have hc1 : ((run (wordA (j + 1))).1 : ℝ)
          = 4 * ((run (wordA j)).1 : ℝ) + ((run (wordA j)).2 : ℝ) := by
        rw [(wordA_step j).1]; push_cast; ring
      have hc2 : ((run (wordA (j + 1))).2 : ℝ) = ((run (wordA j)).1 : ℝ) := by
        rw [(wordA_step j).2]
      refine ⟨?_, ?_⟩
      · rw [hc1, ih.1, ih.2]
        linear_combination (-hA - hB) / 2
      · rw [hc2, ih.1]

/-- **Binet formula along `(B₂B₂B₃B₃)^j`.** -/
theorem wordB_binet (j : ℕ) :
    ((run (wordB j)).1 : ℝ)
        = (1 + 3 * Real.sqrt 3 / 4) * gammaB ^ j + (1 - 3 * Real.sqrt 3 / 4) * deltaB ^ j ∧
      ((run (wordB j)).2 : ℝ)
        = (1 / 2 - Real.sqrt 3 / 12) * gammaB ^ j + (1 / 2 + Real.sqrt 3 / 12) * deltaB ^ j := by
  have hAg : (1 + 3 * Real.sqrt 3 / 4) * gammaB
      = 13 * (1 + 3 * Real.sqrt 3 / 4) + 6 * (1 / 2 - Real.sqrt 3 / 12) := by
    simp only [gammaB]; linear_combination 3 * sqrt_three_sq
  have hBd : (1 - 3 * Real.sqrt 3 / 4) * deltaB
      = 13 * (1 - 3 * Real.sqrt 3 / 4) + 6 * (1 / 2 + Real.sqrt 3 / 12) := by
    simp only [deltaB]; linear_combination 3 * sqrt_three_sq
  have hCg : (1 / 2 - Real.sqrt 3 / 12) * gammaB
      = 2 * (1 + 3 * Real.sqrt 3 / 4) + (1 / 2 - Real.sqrt 3 / 12) := by
    simp only [gammaB]; linear_combination (-1 / 3 : ℝ) * sqrt_three_sq
  have hDd : (1 / 2 + Real.sqrt 3 / 12) * deltaB
      = 2 * (1 - 3 * Real.sqrt 3 / 4) + (1 / 2 + Real.sqrt 3 / 12) := by
    simp only [deltaB]; linear_combination (-1 / 3 : ℝ) * sqrt_three_sq
  induction j with
  | zero =>
      have h0 : run (wordB 0) = (2, 1) := rfl
      rw [h0]
      constructor
      · show ((2 : ℕ) : ℝ) = _
        norm_num
      · show ((1 : ℕ) : ℝ) = _
        norm_num
  | succ j ih =>
      have hc1 : ((run (wordB (j + 1))).1 : ℝ)
          = 13 * ((run (wordB j)).1 : ℝ) + 6 * ((run (wordB j)).2 : ℝ) := by
        rw [(wordB_step j).1]; push_cast; ring
      have hc2 : ((run (wordB (j + 1))).2 : ℝ)
          = 2 * ((run (wordB j)).1 : ℝ) + ((run (wordB j)).2 : ℝ) := by
        rw [(wordB_step j).2]; push_cast; ring
      refine ⟨?_, ?_⟩
      · rw [hc1, ih.1, ih.2]
        linear_combination (-(gammaB ^ j)) * hAg + (-(deltaB ^ j)) * hBd
      · rw [hc2, ih.1, ih.2]
        linear_combination (-(gammaB ^ j)) * hCg + (-(deltaB ^ j)) * hDd

theorem one_lt_alphaA : 1 < alphaA := by
  simp only [alphaA]; linarith [sqrt_five_bounds.1]

theorem abs_betaA_le_one : |betaA| ≤ 1 := by
  rw [abs_le]
  constructor <;> · simp only [betaA]; linarith [sqrt_five_bounds.1, sqrt_five_bounds.2]

theorem one_lt_gammaB : 1 < gammaB := by
  simp only [gammaB]; linarith [sqrt_three_bounds.1]

theorem deltaB_mem : 0 < deltaB ∧ deltaB < 1 := by
  constructor <;> · simp only [deltaB]; linarith [sqrt_three_bounds.1, sqrt_three_bounds.2]

/-- Geometric two-sided bounds along `(B₂B₃)^j`. -/
theorem wordA_sandwich (j : ℕ) :
    1 * alphaA ^ j ≤ ((run (wordA j)).1 : ℝ) ∧ ((run (wordA j)).1 : ℝ) ≤ 3 * alphaA ^ j := by
  have hbin := (wordA_binet j).1
  have hone : (1 : ℝ) ≤ alphaA ^ j := one_le_pow₀ (le_of_lt one_lt_alphaA)
  have habs : |betaA ^ (j + 1)| ≤ 1 := by
    rw [abs_pow]
    exact pow_le_one₀ (abs_nonneg _) abs_betaA_le_one
  rw [abs_le] at habs
  have hsplit : alphaA ^ (j + 1) = alphaA * alphaA ^ j := by ring
  have ha : (4 : ℝ) ≤ alphaA := by simp only [alphaA]; linarith [sqrt_five_bounds.1]
  have hb : alphaA ≤ 5 := by simp only [alphaA]; linarith [sqrt_five_bounds.2]
  constructor
  · rw [hbin, hsplit]
    nlinarith [habs.1, hone]
  · rw [hbin, hsplit]
    nlinarith [habs.2, hone]

/-- Geometric two-sided bounds along `(B₂B₂B₃B₃)^j`. -/
theorem wordB_sandwich (j : ℕ) :
    1 * gammaB ^ j ≤ ((run (wordB j)).1 : ℝ) ∧ ((run (wordB j)).1 : ℝ) ≤ 3 * gammaB ^ j := by
  have hbin := (wordB_binet j).1
  have hone : (1 : ℝ) ≤ gammaB ^ j := one_le_pow₀ (le_of_lt one_lt_gammaB)
  have hd0 : (0 : ℝ) < deltaB ^ j := pow_pos deltaB_mem.1 j
  have hd1 : deltaB ^ j ≤ 1 := pow_le_one₀ (le_of_lt deltaB_mem.1) (le_of_lt deltaB_mem.2)
  have h3 := sqrt_three_bounds.1
  have h4 := sqrt_three_bounds.2
  constructor
  · rw [hbin]; nlinarith
  · rw [hbin]; nlinarith

/-- **The rate of a geometrically growing path.**  If the first coordinate of the node
reached by `w j` is squeezed between `c₁ λ^j` and `c₂ λ^j` and `|w j| = p j`, then the
hyperbolic rate `d/|w|` converges to `log λ / p`. -/
theorem tendsto_rate_of_geometric (w : ℕ → List Move) (lam c₁ c₂ : ℝ) (p : ℕ)
    (hp : 0 < p) (hlen : ∀ j, (w j).length = p * j) (hlam : 1 < lam)
    (hc₁ : 0 < c₁) (hc₂ : 0 < c₂)
    (h1 : ∀ j, c₁ * lam ^ j ≤ ((run (w j)).1 : ℝ))
    (h2 : ∀ j, ((run (w j)).1 : ℝ) ≤ c₂ * lam ^ j) :
    Tendsto (fun j : ℕ => wdist (w j) / (w j).length) atTop (𝓝 (Real.log lam / p)) := by
  have hpR : (0 : ℝ) < (p : ℝ) := by exact_mod_cast hp
  have hlampos : (0 : ℝ) < lam := lt_trans zero_lt_one hlam
  have hlo : Tendsto (fun j : ℕ => (Real.log c₁ / p) / j + Real.log lam / p) atTop
      (𝓝 (Real.log lam / p)) := by
    have := tendsto_const_div_atTop_nhds_zero_nat (Real.log c₁ / p)
    simpa using this.add tendsto_const_nhds
  have hhi : Tendsto (fun j : ℕ => ((Real.log c₂ + Real.log 2) / p) / j + Real.log lam / p) atTop
      (𝓝 (Real.log lam / p)) := by
    have := tendsto_const_div_atTop_nhds_zero_nat ((Real.log c₂ + Real.log 2) / p)
    simpa using this.add tendsto_const_nhds
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlo hhi ?_ ?_
  · filter_upwards [eventually_ge_atTop 1] with j hj
    have hjR : (0 : ℝ) < (j : ℝ) := by exact_mod_cast hj
    have hpos : (0 : ℝ) < ((w j).length : ℝ) := by
      rw [hlen j]; push_cast; positivity
    have hlog : Real.log c₁ + (j : ℝ) * Real.log lam ≤ Real.log (run (w j)).1 := by
      have hstep : Real.log (c₁ * lam ^ j) ≤ Real.log (run (w j)).1 :=
        Real.log_le_log (by positivity) (h1 j)
      rw [Real.log_mul (ne_of_gt hc₁) (by positivity), Real.log_pow] at hstep
      linarith
    have hd := wdist_ge_log (w j)
    have hlenR : ((w j).length : ℝ) = (p : ℝ) * (j : ℝ) := by rw [hlen j]; push_cast; ring
    rw [hlenR, le_div_iff₀ (by positivity)]
    have hid : (Real.log c₁ / p / j + Real.log lam / p) * ((p : ℝ) * j)
        = Real.log c₁ + (j : ℝ) * Real.log lam := by field_simp
    rw [hid]
    linarith
  · filter_upwards [eventually_ge_atTop 1] with j hj
    have hjR : (0 : ℝ) < (j : ℝ) := by exact_mod_cast hj
    have hpos : (0 : ℝ) < ((w j).length : ℝ) := by
      rw [hlen j]; push_cast; positivity
    have hxpos : (0 : ℝ) < ((run (w j)).1 : ℝ) := by
      have hs := run_isSeed (w j)
      have : 0 < (run (w j)).1 := lt_trans hs.pos hs.lt
      exact_mod_cast this
    have hlog : Real.log (run (w j)).1 ≤ Real.log c₂ + (j : ℝ) * Real.log lam := by
      have hstep : Real.log (run (w j)).1 ≤ Real.log (c₂ * lam ^ j) :=
        Real.log_le_log hxpos (h2 j)
      rw [Real.log_mul (ne_of_gt hc₂) (by positivity), Real.log_pow] at hstep
      linarith
    have hd := wdist_le_log (w j)
    have hlenR : ((w j).length : ℝ) = (p : ℝ) * (j : ℝ) := by rw [hlen j]; push_cast; ring
    rw [hlenR, div_le_iff₀ (by positivity)]
    have hid : ((Real.log c₂ + Real.log 2) / p / j + Real.log lam / p) * ((p : ℝ) * j)
        = Real.log c₂ + Real.log 2 + (j : ℝ) * Real.log lam := by field_simp
    rw [hid]
    linarith

/-- **The exact rate of the path `(B₂B₃)^∞` is `½ log(2+√5) = 0.7218…`.** -/
theorem wordA_rate_tendsto :
    Tendsto (fun j : ℕ => wdist (wordA j) / (wordA j).length) atTop
      (𝓝 (Real.log alphaA / 2)) := by
  have := tendsto_rate_of_geometric wordA alphaA 1 3 2 (by norm_num)
    (fun j => wordA_length j) one_lt_alphaA (by norm_num) (by norm_num)
    (fun j => (wordA_sandwich j).1) (fun j => (wordA_sandwich j).2)
  simpa using this

/-- **The exact rate of the path `(B₂B₂B₃B₃)^∞` is `¼ log(7+4√3) = ½ log(2+√3) = 0.6585…`.** -/
theorem wordB_rate_tendsto :
    Tendsto (fun j : ℕ => wdist (wordB j) / (wordB j).length) atTop
      (𝓝 (Real.log gammaB / 4)) := by
  have := tendsto_rate_of_geometric wordB gammaB 1 3 4 (by norm_num)
    (fun j => wordB_length j) one_lt_gammaB (by norm_num) (by norm_num)
    (fun j => (wordB_sandwich j).1) (fun j => (wordB_sandwich j).2)
  simpa using this

/-- The rate of `(B₂B₂B₃B₃)^∞` is strictly smaller than that of `(B₂B₃)^∞`, because
`7+4√3 < (2+√5)² = 9+4√5`. -/
theorem rate_gammaB_lt_rate_alphaA : Real.log gammaB / 4 < Real.log alphaA / 2 := by
  have hg : (0 : ℝ) < gammaB := by simp only [gammaB]; linarith [sqrt_three_bounds.1]
  have ha : (0 : ℝ) < alphaA := by simp only [alphaA]; linarith [sqrt_five_bounds.1]
  have hlt : gammaB < alphaA ^ 2 := by
    simp only [gammaB, alphaA]
    nlinarith [sqrt_three_bounds.2, sqrt_five_bounds.1, sqrt_five_sq]
  have hlog : Real.log gammaB < Real.log (alphaA ^ 2) := Real.log_lt_log hg hlt
  rw [Real.log_pow] at hlog
  push_cast at hlog
  linarith

/-- **Conjecture I1 is false, in the sharpest form.**  The two `B₁`-free periodic paths
`(B₂B₃)^∞` and `(B₂B₂B₃B₃)^∞` have middle-move frequency exactly `1/2`, yet their metric
growth rates *exist* and are the two distinct quadratic irrationalities
`½ log(2+√5) = 0.72181…` and `½ log(2+√3) = 0.65848…`.  So the growth rate of a `B₁`-free
Berggren path is not a function of the asymptotic frequency of the middle move: the
*arrangement* of the letters matters. -/
theorem two_distinct_rates_at_frequency_half :
    (∀ j : ℕ, 2 * countM (wordA j) = (wordA j).length ∧
        2 * countM (wordB j) = (wordB j).length) ∧
      Tendsto (fun j : ℕ => wdist (wordA j) / (wordA j).length) atTop
        (𝓝 (Real.log alphaA / 2)) ∧
      Tendsto (fun j : ℕ => wdist (wordB j) / (wordB j).length) atTop
        (𝓝 (Real.log gammaB / 4)) ∧
      Real.log gammaB / 4 < Real.log alphaA / 2 ∧
      gammaB = (2 + Real.sqrt 3) ^ 2 :=
  ⟨fun j => ⟨by rw [wordA_countM, wordA_length], by rw [wordB_countM, wordB_length]; ring⟩,
    wordA_rate_tendsto, wordB_rate_tendsto, rate_gammaB_lt_rate_alphaA, gammaB_eq_sq⟩

/-- **Two interior points of the metric growth spectrum.**  Cycle IX exhibited only the
endpoints `0` and `log(1+√2)` of the spectrum.  The two rates computed here are strictly
between them, so the spectrum of the Berggren tree contains at least four points, two of
which are interior. -/
theorem berggren_spectrum_two_interior_values :
    0 < Real.log gammaB / 4 ∧ Real.log gammaB / 4 < Real.log alphaA / 2 ∧
      Real.log alphaA / 2 < Real.log silver := by
  refine ⟨by linarith [Real.log_pos one_lt_gammaB], rate_gammaB_lt_rate_alphaA, ?_⟩
  · have ha : (0 : ℝ) < alphaA := by simp only [alphaA]; linarith [sqrt_five_bounds.1]
    have hlt : alphaA < silver ^ 2 := by
      simp only [alphaA, silver]
      nlinarith [sqrt_five_bounds.2, sqrt_two_bounds.1, sqrt_two_sq]
    have hlog : Real.log alphaA < Real.log (silver ^ 2) := Real.log_lt_log ha hlt
    rw [Real.log_pow] at hlog
    push_cast at hlog
    linarith

/-! ## Part G. Infinitely many exact rates, accumulating at `0` -/

/-- The `B₁`-free periodic word `(B₂B₃^b)^j`. -/
def wordC (b : ℕ) : ℕ → List Move
  | 0 => []
  | j + 1 => Move.M :: (List.replicate b Move.R ++ wordC b j)

/-- Running `b` copies of `B₃` adds `2b n` to the first coordinate. -/
theorem run_replicate_R (b : ℕ) (w : List Move) :
    run (List.replicate b Move.R ++ w) = ((run w).1 + 2 * b * (run w).2, (run w).2) := by
  induction b with
  | zero => simp
  | succ b ih =>
      have hcons : List.replicate (b + 1) Move.R ++ w
          = Move.R :: (List.replicate b Move.R ++ w) := by
        simp [List.replicate_succ]
      rw [hcons]
      have hstep : run (Move.R :: (List.replicate b Move.R ++ w))
          = seedR (run (List.replicate b Move.R ++ w)) := rfl
      rw [hstep, ih]
      simp [seedR]
      ring

theorem wordC_length (b j : ℕ) : (wordC b j).length = (b + 1) * j := by
  induction j with
  | zero => rfl
  | succ j ih => simp [wordC, ih]; ring

theorem wordC_countM (b j : ℕ) : countM (wordC b j) = j := by
  have hrep : List.count Move.M (List.replicate b Move.R) = 0 := by
    rw [List.count_replicate]
    simp
  induction j with
  | zero => rfl
  | succ j ih =>
      have h : wordC b (j + 1) = Move.M :: (List.replicate b Move.R ++ wordC b j) := rfl
      unfold countM at ih ⊢
      rw [h, List.count_cons, List.count_append, hrep, ih]
      simp

theorem wordC_no_L (b j : ℕ) : Move.L ∉ wordC b j := by
  induction j with
  | zero => simp [wordC]
  | succ j ih => simp [wordC, ih]

/-- One period of `(B₂B₃^b)` sends `(m,n)` to `(2m + (4b+1)n, m + 2bn)`. -/
theorem wordC_step (b j : ℕ) :
    (run (wordC b (j + 1))).1
        = 2 * (run (wordC b j)).1 + (4 * b + 1) * (run (wordC b j)).2 ∧
      (run (wordC b (j + 1))).2 = (run (wordC b j)).1 + 2 * b * (run (wordC b j)).2 := by
  have hrun : run (wordC b (j + 1)) = seedM (run (List.replicate b Move.R ++ wordC b j)) := rfl
  rw [hrun, run_replicate_R]
  constructor
  · simp [seedM]
    ring
  · simp [seedM]

/-- The first coordinate along `(B₂B₃^b)^j` obeys the two-term recurrence
`m_{j+2} = (2+2b) m_{j+1} + m_j` (Cayley–Hamilton for a period matrix of determinant `−1`). -/
theorem wordC_rec (b j : ℕ) :
    (run (wordC b (j + 2))).1
      = (2 + 2 * b) * (run (wordC b (j + 1))).1 + (run (wordC b j)).1 := by
  have h1 := wordC_step b (j + 1)
  have h2 := wordC_step b j
  rw [h1.1, h2.1, h2.2]
  ring

/-- The Perron root of one period of `(B₂B₃^b)`: `ρ_b = (1+b) + √((1+b)²+1)`. -/
def rhoC (b : ℕ) : ℝ := (1 + (b : ℝ)) + Real.sqrt ((1 + (b : ℝ)) ^ 2 + 1)

theorem rhoC_sqrt_sq (b : ℕ) :
    Real.sqrt ((1 + (b : ℝ)) ^ 2 + 1) ^ 2 = (1 + (b : ℝ)) ^ 2 + 1 :=
  Real.sq_sqrt (by positivity)

theorem rhoC_bounds (b : ℕ) : 2 * (b : ℝ) + 2 < rhoC b ∧ rhoC b < 2 * (b : ℝ) + 3 := by
  have hb : (0 : ℝ) ≤ (b : ℝ) := Nat.cast_nonneg b
  have hs := rhoC_sqrt_sq b
  have hnn : 0 ≤ Real.sqrt ((1 + (b : ℝ)) ^ 2 + 1) := Real.sqrt_nonneg _
  constructor
  · simp only [rhoC]
    nlinarith
  · simp only [rhoC]
    nlinarith

theorem one_lt_rhoC (b : ℕ) : 1 < rhoC b := by
  have h := (rhoC_bounds b).1
  have hb : (0 : ℝ) ≤ (b : ℝ) := Nat.cast_nonneg b
  linarith

theorem rhoC_sq (b : ℕ) : rhoC b ^ 2 = (2 + 2 * (b : ℝ)) * rhoC b + 1 := by
  have hs := rhoC_sqrt_sq b
  simp only [rhoC]
  nlinarith [hs]

/-- Geometric two-sided bounds along `(B₂B₃^b)^j`, by the two-term recurrence. -/
theorem wordC_sandwich (b j : ℕ) :
    1 * rhoC b ^ j ≤ ((run (wordC b j)).1 : ℝ) ∧ ((run (wordC b j)).1 : ℝ) ≤ 3 * rhoC b ^ j := by
  have hb : (0 : ℝ) ≤ (b : ℝ) := Nat.cast_nonneg b
  have hlo := (rhoC_bounds b).1
  have hhi := (rhoC_bounds b).2
  have hrpos : (0 : ℝ) < rhoC b := by linarith
  have hbase0 : ((run (wordC b 0)).1 : ℝ) = 2 := by norm_num [wordC, run]
  have hbase1 : ((run (wordC b 1)).1 : ℝ) = 4 * (b : ℝ) + 5 := by
    have h := (wordC_step b 0).1
    have h0 : run (wordC b 0) = (2, 1) := rfl
    rw [h0] at h
    rw [h]
    push_cast
    ring
  have key : ∀ j, (1 * rhoC b ^ j ≤ ((run (wordC b j)).1 : ℝ) ∧
      ((run (wordC b j)).1 : ℝ) ≤ 3 * rhoC b ^ j) ∧
      (1 * rhoC b ^ (j + 1) ≤ ((run (wordC b (j + 1))).1 : ℝ) ∧
        ((run (wordC b (j + 1))).1 : ℝ) ≤ 3 * rhoC b ^ (j + 1)) := by
    intro j
    induction j with
    | zero =>
        refine ⟨⟨by rw [hbase0]; norm_num, by rw [hbase0]; norm_num⟩, ?_⟩
        have hp1 : rhoC b ^ (0 + 1) = rhoC b := by norm_num
        rw [hbase1, hp1]
        constructor <;> linarith
    | succ j ih =>
        refine ⟨ih.2, ?_⟩
        have hrecn := wordC_rec b j
        have hrec : ((run (wordC b (j + 2))).1 : ℝ)
            = (2 + 2 * (b : ℝ)) * ((run (wordC b (j + 1))).1 : ℝ)
              + ((run (wordC b j)).1 : ℝ) := by
          rw [hrecn]; push_cast; ring
        have hpowj : (0 : ℝ) < rhoC b ^ j := pow_pos hrpos j
        have hsq : rhoC b ^ (j + 2) = rhoC b ^ j * rhoC b ^ 2 := by ring
        have hexp : rhoC b ^ (j + 2)
            = (2 + 2 * (b : ℝ)) * rhoC b ^ (j + 1) + rhoC b ^ j := by
          rw [hsq, rhoC_sq]; ring
        refine ⟨?_, ?_⟩
        · rw [show j + 1 + 1 = j + 2 from rfl, hrec, hexp]
          nlinarith [ih.1.1, ih.2.1]
        · rw [show j + 1 + 1 = j + 2 from rfl, hrec, hexp]
          nlinarith [ih.1.2, ih.2.2]
  exact (key j).1

/-- **The exact rate of the path `(B₂B₃^b)^∞` is `log ρ_b/(b+1)`,
`ρ_b = (1+b) + √((1+b)²+1)`.**  For `b = 1` this is `½ log(2+√5)`, the rate of Part F. -/
theorem wordC_rate_tendsto (b : ℕ) :
    Tendsto (fun j : ℕ => wdist (wordC b j) / (wordC b j).length) atTop
      (𝓝 (Real.log (rhoC b) / (b + 1))) := by
  have h := tendsto_rate_of_geometric (wordC b) (rhoC b) 1 3 (b + 1) (by omega)
    (fun j => wordC_length b j) (one_lt_rhoC b) (by norm_num) (by norm_num)
    (fun j => (wordC_sandwich b j).1) (fun j => (wordC_sandwich b j).2)
  simpa using h

/-- Every one of these rates is strictly positive. -/
theorem wordC_rate_pos (b : ℕ) : 0 < Real.log (rhoC b) / (b + 1) := by
  have h := Real.log_pos (one_lt_rhoC b)
  have hb : (0 : ℝ) ≤ (b : ℝ) := Nat.cast_nonneg b
  positivity

/-- **The rates accumulate at `0`.**  `log ρ_b/(b+1) → 0` as the `B₃`-blocks get longer. -/
theorem wordC_rate_tendsto_zero :
    Tendsto (fun b : ℕ => Real.log (rhoC b) / (b + 1)) atTop (𝓝 0) := by
  have hup : Tendsto (fun b : ℕ => Real.log (2 * (b : ℝ) + 3) / b) atTop (𝓝 0) :=
    log_affine_div_tendsto_zero 2 3 (by norm_num) (by norm_num)
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hup ?_ ?_
  · filter_upwards with b using le_of_lt (wordC_rate_pos b)
  · filter_upwards [eventually_ge_atTop 1] with b hb
    have hbR : (1 : ℝ) ≤ (b : ℝ) := by exact_mod_cast hb
    have hlt := (rhoC_bounds b).2
    have hpos : (0 : ℝ) < rhoC b := lt_trans zero_lt_one (one_lt_rhoC b)
    have hlog : Real.log (rhoC b) ≤ Real.log (2 * (b : ℝ) + 3) :=
      Real.log_le_log hpos (le_of_lt hlt)
    have hlogpos : 0 < Real.log (rhoC b) := Real.log_pos (one_lt_rhoC b)
    rw [div_le_div_iff₀ (by linarith) (by linarith)]
    nlinarith

/-- **The metric growth spectrum of the Berggren tree is infinite and accumulates at `0`.**
For every `b` the `B₁`-free path `(B₂B₃^b)^∞` has an exact growth rate `log ρ_b/(b+1) > 0`,
and these rates tend to `0`.  Together with the endpoint `log(1+√2)` of cycle IX and the
two frequency-`1/2` values of Part F, the spectrum contains infinitely many distinct
points of `(0, log(1+√2))`. -/
theorem berggren_spectrum_infinite :
    (∀ b : ℕ, Tendsto (fun j : ℕ => wdist (wordC b j) / (wordC b j).length) atTop
        (𝓝 (Real.log (rhoC b) / (b + 1)))) ∧
      (∀ b : ℕ, 0 < Real.log (rhoC b) / (b + 1)) ∧
      (∀ b j : ℕ, Move.L ∉ wordC b j ∧
        (b + 1) * countM (wordC b j) = (wordC b j).length) ∧
      Tendsto (fun b : ℕ => Real.log (rhoC b) / (b + 1)) atTop (𝓝 0) :=
  ⟨wordC_rate_tendsto, wordC_rate_pos,
    fun b j => ⟨wordC_no_L b j, by rw [wordC_countM, wordC_length]⟩,
    wordC_rate_tendsto_zero⟩

/-! ## Part H. The sharp middle-move lower bound, and accumulation at `log(1+√2)` -/

/-- `B₁` never decreases the silver potential; the slack is `√2 (m−n)`. -/
theorem pot_le_pot_seedL {m n : ℕ} (h : IsSeed m n) : pot (m, n) ≤ pot (seedL (m, n)) := by
  have hltnat := h.lt
  have hcast : ((2 * m - n : ℕ) : ℝ) = 2 * (m : ℝ) - (n : ℝ) := by
    have : n ≤ 2 * m := by omega
    push_cast [Nat.cast_sub this]
    ring
  have hnm : (n : ℝ) ≤ (m : ℝ) := by exact_mod_cast h.lt.le
  have h2 := sqrt_two_bounds.1
  simp only [pot, seedL, hcast]
  nlinarith

/-- `B₃` never decreases the silver potential; the slack is `2n`.  (No seed hypothesis is
needed here.) -/
theorem pot_le_pot_seedR (m n : ℕ) : pot (m, n) ≤ pot (seedR (m, n)) := by
  have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
  have h2 := sqrt_two_bounds.1
  simp only [pot, seedR]
  push_cast
  nlinarith

/-- **Each middle move multiplies the potential by `1+√2`, and the other two never decrease
it.**  Hence the potential of the node reached by `w` is at least `(1+√2)^{#B₂(w)+1}`. -/
theorem run_pot_ge_silver_pow (w : List Move) : silver ^ (countM w + 1) ≤ pot (run w) := by
  induction w with
  | nil => simp [run, countM, pot_root]
  | cons a w ih =>
      have hs := run_isSeed w
      cases a with
      | L =>
          have hc : countM (Move.L :: w) = countM w := by simp [countM]
          have hstep : pot (run w) ≤ pot (run (Move.L :: w)) := by
            have := pot_le_pot_seedL (m := (run w).1) (n := (run w).2) hs
            simpa using this
          rw [hc]
          linarith
      | M =>
          have hc : countM (Move.M :: w) = countM w + 1 := by simp [countM]
          have hstep : pot (run (Move.M :: w)) = silver * pot (run w) := by
            have := pot_seedM_eq (run w).1 (run w).2
            simpa using this
          rw [hc, hstep, pow_succ]
          nlinarith [silver_pos, ih]
      | R =>
          have hc : countM (Move.R :: w) = countM w := by simp [countM]
          have hstep : pot (run w) ≤ pot (run (Move.R :: w)) := by
            have := pot_le_pot_seedR (run w).1 (run w).2
            simpa using this
          rw [hc]
          linarith

/-- Consequently the first coordinate satisfies `m ≥ (1+√2)^{#B₂(w)+1}/√2`, a sharpening of
cycle IX's `m ≥ 2^{#B₂(w)+1}`. -/
theorem run_fst_ge_silver_pow (w : List Move) :
    silver ^ (countM w + 1) / Real.sqrt 2 ≤ ((run w).1 : ℝ) := by
  have hs := run_isSeed w
  have hsq : (0 : ℝ) < Real.sqrt 2 := by linarith [sqrt_two_bounds.1]
  have h1 : pot (run w) ≤ Real.sqrt 2 * ((run w).1 : ℝ) := by
    have := pot_le_sqrt_two_mul_fst (m := (run w).1) (n := (run w).2) hs.lt.le
    simpa using this
  have h2 := run_pot_ge_silver_pow w
  rw [div_le_iff₀ hsq]
  nlinarith

/-- **The sharp middle-move lower bound.**  Cycle IX proved
`(#B₂(w)+1) log 2 ≤ d`; the true per-middle-move gain is the *silver* logarithm:
`(#B₂(w)+1) log(1+√2) − ½ log 2 ≤ d`. -/
theorem dist_ge_countM_silver (w : List Move) :
    ((countM w : ℝ) + 1) * Real.log silver - (1 / 2) * Real.log 2 ≤ wdist w := by
  have hsq : (0 : ℝ) < Real.sqrt 2 := by linarith [sqrt_two_bounds.1]
  have hpos : (0 : ℝ) < silver ^ (countM w + 1) / Real.sqrt 2 :=
    div_pos (pow_pos silver_pos _) hsq
  have hlog : Real.log (silver ^ (countM w + 1) / Real.sqrt 2) ≤ Real.log (run w).1 :=
    Real.log_le_log hpos (run_fst_ge_silver_pow w)
  have hsplit : Real.log (silver ^ (countM w + 1) / Real.sqrt 2)
      = ((countM w : ℝ) + 1) * Real.log silver - (1 / 2) * Real.log 2 := by
    rw [Real.log_div (ne_of_gt (pow_pos silver_pos _)) (ne_of_gt hsq), Real.log_pow,
      Real.log_sqrt (by norm_num)]
    push_cast
    ring
  rw [hsplit] at hlog
  linarith [wdist_ge_log w]

/-- **The sharp two-sided word estimate.**  Both constants are now `log(1+√2)`, so the
estimate is tight to `O(1)` for words that are (almost) all middle moves. -/
theorem berggren_word_two_sided_sharp (w : List Move) :
    ((countM w : ℝ) + 1) * Real.log silver - (1 / 2) * Real.log 2 ≤ wdist w ∧
      wdist w ≤ ((w.length : ℝ) + 1) * Real.log silver + Real.log 2 :=
  ⟨dist_ge_countM_silver w, dist_le_silver_depth (run_reaches w)⟩

/-- The `B₁`-free periodic word `(B₂^a B₃)^j`, of middle-move frequency `a/(a+1)`. -/
def wordF (a : ℕ) : ℕ → List Move
  | 0 => []
  | j + 1 => List.replicate a Move.M ++ (Move.R :: wordF a j)

theorem wordF_length (a j : ℕ) : (wordF a j).length = (a + 1) * j := by
  induction j with
  | zero => rfl
  | succ j ih => simp [wordF, ih]; ring

theorem wordF_countM (a j : ℕ) : countM (wordF a j) = a * j := by
  have hrep : List.count Move.M (List.replicate a Move.M) = a := by
    rw [List.count_replicate]
    simp
  induction j with
  | zero => rfl
  | succ j ih =>
      have h : wordF a (j + 1) = List.replicate a Move.M ++ (Move.R :: wordF a j) := rfl
      unfold countM at ih ⊢
      rw [h, List.count_append, List.count_cons, hrep, ih]
      simp
      ring

/-- **The rates accumulate at the top of the spectrum.**  Along `(B₂^a B₃)^j` the rate is at
least `a/(a+1) · log(1+√2)` up to `O(1/j)`, while no path ever exceeds `log(1+√2)`.  Letting
`a → ∞` the rates approach the maximal rate `log(1+√2)` of cycle IX. -/
theorem wordF_rate_ge (a j : ℕ) (hj : 0 < j) :
    (a : ℝ) / ((a : ℝ) + 1) * Real.log silver
      - Real.log 2 / (2 * (((a : ℝ) + 1) * j)) ≤ wdist (wordF a j) / (wordF a j).length := by
  have hjR : (0 : ℝ) < (j : ℝ) := by exact_mod_cast hj
  have haR : (0 : ℝ) ≤ (a : ℝ) := Nat.cast_nonneg a
  have hlen : ((wordF a j).length : ℝ) = ((a : ℝ) + 1) * (j : ℝ) := by
    rw [wordF_length]; push_cast; ring
  have hcount : ((countM (wordF a j) : ℕ) : ℝ) = (a : ℝ) * (j : ℝ) := by
    rw [wordF_countM]; push_cast; ring
  have hlow := dist_ge_countM_silver (wordF a j)
  rw [hcount] at hlow
  have hpos : (0 : ℝ) < ((a : ℝ) + 1) * (j : ℝ) := by positivity
  rw [hlen, le_div_iff₀ hpos]
  have hid : ((a : ℝ) / ((a : ℝ) + 1) * Real.log silver
      - Real.log 2 / (2 * (((a : ℝ) + 1) * j))) * (((a : ℝ) + 1) * (j : ℝ))
      = (a : ℝ) * (j : ℝ) * Real.log silver - (1 / 2) * Real.log 2 := by
    field_simp
  rw [hid]
  have hlogpos : 0 < Real.log silver := log_silver_pos
  nlinarith

end

end HyperbolicBerggrenGeodesics