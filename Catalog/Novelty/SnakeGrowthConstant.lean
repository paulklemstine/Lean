/-
# The snake-in-the-box growth constant exists

`Novelty/SnakeGridComb.lean` proved the **product theorem**

  `maxLen m * maxLen n ≤ 2 * maxLen (m + n)`,

i.e. the normalised quantity `g n = maxLen n / 2` is *supermultiplicative*,
`g m * g n ≤ g (m + n)`.  Fekete's lemma, applied to the subadditive sequence
`u n = - log (g n)`, therefore shows that `(maxLen n) ^ (1/n)` **converges**.
Its limit — the *snake constant* — is the content of this file:

> `snakeGrowth_tendsto` : `(maxLen n) ^ (1/n) → snakeGrowth`,
> `snakeGrowth_ge`      : `23 ^ (1/7) ≤ snakeGrowth`,
> `snakeGrowth_le_two`  : `snakeGrowth ≤ 2`.

The lower bound is the kernel-verified `47`-edge snake of `Q 7` fed through
Fekete's `lim ≤ u k / k`; the upper bound is the cardinality ceiling
`maxLen n + 1 ≤ 2 ^ n`.  So the exponential growth rate of the longest chordless
induced path in `Q n` is a genuine real number lying in `[23^{1/7}, 2]`, i.e.
between about `1.563` and `2`.

This turns the first of the "three concrete sub-conjectures for the next cycle"
(Fekete for snakes) into a theorem, and gives the constant `λ` of Conjecture 2 a
formal definition.

Two conventions make the boundary cases painless: `maxLen 0 = 0` and
`Real.log 0 = 0`, so `u 0 = 0` and subadditivity at `0` is an equality.
-/
import Mathlib
import Computation.SnakeInTheBox
import Computation.SnakeMax
import Novelty.SnakeGridComb
import Novelty.SnakeSupport

namespace SnakeInTheBox

open Filter Topology Set

/-! ## Step 1: the normalised sequence and its supermultiplicativity -/

/-- Half the maximal snake length, viewed as a real number.  The product theorem
says exactly that this sequence is supermultiplicative. -/
noncomputable def halfLen (n : ℕ) : ℝ := (maxLen n : ℝ) / 2

theorem halfLen_zero : halfLen 0 = 0 := by
  simp [halfLen, maxLen_zero]

theorem halfLen_pos {n : ℕ} (hn : 1 ≤ n) : 0 < halfLen n := by
  have h : (1 : ℕ) ≤ maxLen n := le_trans hn (dim_le_maxLen n)
  have : (1 : ℝ) ≤ (maxLen n : ℝ) := by exact_mod_cast h
  simp only [halfLen]
  linarith

/-- **Supermultiplicativity**, the analytic form of the product theorem. -/
theorem halfLen_supermul (m n : ℕ) : halfLen m * halfLen n ≤ halfLen (m + n) := by
  have h := maxLen_mul_le m n
  have h' : (maxLen m : ℝ) * (maxLen n : ℝ) ≤ 2 * (maxLen (m + n) : ℝ) := by
    exact_mod_cast h
  simp only [halfLen]
  linarith

/-- The cardinality ceiling in real form: `maxLen n / 2 ≤ 2 ^ n`. -/
theorem halfLen_le_pow (n : ℕ) : halfLen n ≤ (2 : ℝ) ^ n := by
  obtain ⟨s⟩ := exists_snake_maxLen n
  have h : maxLen n + 1 ≤ 2 ^ n := s.card_le_pow
  have h' : (maxLen n : ℝ) ≤ (2 : ℝ) ^ n := by
    have : ((maxLen n : ℕ) : ℝ) ≤ ((2 ^ n : ℕ) : ℝ) := by exact_mod_cast Nat.le_of_succ_le h
    simpa using this
  have h2 : (0 : ℝ) ≤ (2 : ℝ) ^ n := by positivity
  simp only [halfLen]
  linarith

/-! ## Step 2: Fekete's lemma -/

/-- The subadditive sequence attached to the snake numbers. -/
noncomputable def snakeU (n : ℕ) : ℝ := -Real.log (halfLen n)

theorem snakeU_zero : snakeU 0 = 0 := by
  simp [snakeU, halfLen_zero]

/-- `u n = - log (maxLen n / 2)` is subadditive: this is the product theorem after
taking logarithms. -/
theorem snakeU_subadditive : Subadditive snakeU := by
  intro m n
  rcases Nat.eq_zero_or_pos m with rfl | hm
  · simp [snakeU_zero]
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp [snakeU_zero]
  have hmp : 0 < halfLen m := halfLen_pos hm
  have hnp : 0 < halfLen n := halfLen_pos hn
  have hprod : 0 < halfLen m * halfLen n := mul_pos hmp hnp
  have hlog : Real.log (halfLen m * halfLen n) ≤ Real.log (halfLen (m + n)) :=
    Real.log_le_log hprod (halfLen_supermul m n)
  rw [Real.log_mul (ne_of_gt hmp) (ne_of_gt hnp)] at hlog
  simp only [snakeU]
  linarith

/-- Every normalised term is at least `- log 2`. -/
theorem neg_log_two_le_snakeU_div (n : ℕ) : -Real.log 2 ≤ snakeU n / n := by
  have hlog2 : (0 : ℝ) ≤ Real.log 2 := Real.log_nonneg (by norm_num)
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp only [snakeU_zero, Nat.cast_zero, div_zero]
    linarith
  have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hle : Real.log (halfLen n) ≤ (n : ℝ) * Real.log 2 := by
    have h1 : Real.log (halfLen n) ≤ Real.log ((2 : ℝ) ^ n) :=
      Real.log_le_log (halfLen_pos hn) (halfLen_le_pow n)
    rwa [Real.log_pow] at h1
  have : -((n : ℝ) * Real.log 2) ≤ snakeU n := by
    simp only [snakeU]; linarith
  rw [le_div_iff₀ hnR]
  nlinarith [this]

theorem snakeU_bddBelow : BddBelow (Set.range fun n : ℕ => snakeU n / n) := by
  refine ⟨-Real.log 2, ?_⟩
  rintro x ⟨n, rfl⟩
  exact neg_log_two_le_snakeU_div n

/-! ## Step 3: the growth constant -/

/-- **The snake-in-the-box growth constant.**  The exponential growth rate of the
maximal length of a chordless induced path in `Q n`. -/
noncomputable def snakeGrowth : ℝ := Real.exp (-(Subadditive.lim snakeU_subadditive))

theorem snakeGrowth_pos : 0 < snakeGrowth := Real.exp_pos _

/-- Fekete's lemma applied to the snake numbers. -/
theorem snakeU_tendsto :
    Tendsto (fun n : ℕ => snakeU n / n) atTop (𝓝 (Subadditive.lim snakeU_subadditive)) :=
  snakeU_subadditive.tendsto_lim snakeU_bddBelow

/-- The normalised half-lengths converge to the growth constant. -/
theorem halfLen_rpow_tendsto :
    Tendsto (fun n : ℕ => Real.exp (-(snakeU n / n))) atTop (𝓝 snakeGrowth) := by
  have h := snakeU_tendsto.neg
  exact (Real.continuous_exp.tendsto _).comp h

/-- **Existence of the snake constant.**  `(maxLen n) ^ (1/n)` converges. -/
theorem snakeGrowth_tendsto :
    Tendsto (fun n : ℕ => (maxLen n : ℝ) ^ ((n : ℝ)⁻¹)) atTop (𝓝 snakeGrowth) := by
  have hfac : Tendsto (fun n : ℕ => Real.exp (Real.log 2 / n)) atTop (𝓝 1) := by
    have h0 : Tendsto (fun n : ℕ => Real.log 2 / n) atTop (𝓝 0) :=
      tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop
    have := (Real.continuous_exp.tendsto _).comp h0
    simpa using this
  have hmul := hfac.mul halfLen_rpow_tendsto
  rw [one_mul] at hmul
  refine hmul.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with n hn
  have hpos : 0 < halfLen n := halfLen_pos hn
  have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hmax : (0 : ℝ) < (maxLen n : ℝ) := by
    have : (0 : ℝ) < 2 * halfLen n := by linarith
    simpa [halfLen] using this
  have hsplit : Real.log (maxLen n : ℝ) = Real.log 2 + Real.log (halfLen n) := by
    have : (maxLen n : ℝ) = 2 * halfLen n := by
      simp only [halfLen]; ring
    rw [this, Real.log_mul (by norm_num) (ne_of_gt hpos)]
  calc Real.exp (Real.log 2 / n) * Real.exp (-(snakeU n / n))
      = Real.exp (Real.log 2 / n + Real.log (halfLen n) / n) := by
        rw [← Real.exp_add]
        congr 1
        simp only [snakeU]
        ring
    _ = Real.exp (Real.log (maxLen n : ℝ) * (n : ℝ)⁻¹) := by
        rw [hsplit]; ring_nf
    _ = (maxLen n : ℝ) ^ ((n : ℝ)⁻¹) := (Real.rpow_def_of_pos hmax _).symm

/-! ## Step 4: the two-sided bracket -/

/-- The counting ceiling bounds the growth constant by `2`. -/
theorem snakeGrowth_le_two : snakeGrowth ≤ 2 := by
  have hlim : -Real.log 2 ≤ Subadditive.lim snakeU_subadditive :=
    ge_of_tendsto snakeU_tendsto (Eventually.of_forall neg_log_two_le_snakeU_div)
  have : Real.exp (-(Subadditive.lim snakeU_subadditive)) ≤ Real.exp (Real.log 2) :=
    Real.exp_le_exp.2 (by linarith)
  rwa [Real.exp_log (by norm_num : (0:ℝ) < 2)] at this

/-- The `47`-edge snake of `Q 7` bounds the growth constant from below by
`23 ^ (1/7) ≈ 1.5637`. -/
theorem snakeGrowth_ge : (23 : ℝ) ^ ((7 : ℝ)⁻¹) ≤ snakeGrowth := by
  have h7 : (47 : ℕ) ≤ maxLen 7 := maxLen_seven_ge
  have h23 : (23 : ℝ) ≤ halfLen 7 := by
    have : (47 : ℝ) ≤ (maxLen 7 : ℝ) := by exact_mod_cast h7
    simp only [halfLen]
    linarith
  have hlog : Real.log 23 ≤ Real.log (halfLen 7) :=
    Real.log_le_log (by norm_num) h23
  have hU : snakeU 7 ≤ -Real.log 23 := by
    simp only [snakeU]; linarith
  have hlim : Subadditive.lim snakeU_subadditive ≤ snakeU 7 / (7 : ℕ) :=
    snakeU_subadditive.lim_le_div snakeU_bddBelow (by norm_num)
  have hlim' : Subadditive.lim snakeU_subadditive ≤ -Real.log 23 / 7 := by
    have h7R : ((7 : ℕ) : ℝ) = 7 := by norm_num
    rw [h7R] at hlim
    linarith
  have hexp : Real.exp (Real.log 23 / 7) ≤ snakeGrowth := by
    simp only [snakeGrowth]
    exact Real.exp_le_exp.2 (by linarith)
  have hrpow : (23 : ℝ) ^ ((7 : ℝ)⁻¹) = Real.exp (Real.log 23 / 7) := by
    rw [Real.rpow_def_of_pos (by norm_num : (0:ℝ) < 23)]
    ring_nf
  rw [hrpow]
  exact hexp

/-- The growth is genuinely exponential: the constant exceeds `3/2`. -/
theorem three_halves_lt_snakeGrowth : (3 / 2 : ℝ) < snakeGrowth := by
  have hbase : (3 / 2 : ℝ) < (23 : ℝ) ^ ((7 : ℝ)⁻¹) := by
    have hpow : ((3 / 2 : ℝ) ^ (7 : ℕ)) < 23 := by norm_num
    have h1 : ((3 / 2 : ℝ) ^ (7 : ℕ)) ^ ((7 : ℝ)⁻¹) < (23 : ℝ) ^ ((7 : ℝ)⁻¹) := by
      apply Real.rpow_lt_rpow (by positivity) hpow (by norm_num)
    have h2 : ((3 / 2 : ℝ) ^ (7 : ℕ)) ^ ((7 : ℝ)⁻¹) = (3 / 2 : ℝ) := by
      rw [← Real.rpow_natCast (3 / 2 : ℝ) 7, ← Real.rpow_mul (by norm_num)]
      norm_num
    rwa [h2] at h1
  linarith [snakeGrowth_ge, hbase]

/-- **The bracket.**  The snake-in-the-box growth constant exists and satisfies
`23 ^ (1/7) ≤ snakeGrowth ≤ 2`; in particular the maximal snake length grows
exponentially, at a rate strictly between `3/2` and `2`. -/
theorem snakeGrowth_bracket :
    Tendsto (fun n : ℕ => (maxLen n : ℝ) ^ ((n : ℝ)⁻¹)) atTop (𝓝 snakeGrowth) ∧
      (23 : ℝ) ^ ((7 : ℝ)⁻¹) ≤ snakeGrowth ∧ snakeGrowth ≤ 2 :=
  ⟨snakeGrowth_tendsto, snakeGrowth_ge, snakeGrowth_le_two⟩

end SnakeInTheBox