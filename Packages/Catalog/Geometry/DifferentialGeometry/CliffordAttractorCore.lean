import Mathlib

/-!
# Clifford / Pickover attractor: boundedness and max-metric Lipschitz core

This file develops the elementary boundedness and Lipschitz estimates for the
Clifford (Pickover) attractor map, working with the max metric on `ℝ × ℝ`.

It deliberately avoids any contraction / fixed point machinery.
-/

noncomputable def clifford (a b c d : ℝ) (p : ℝ × ℝ) : ℝ × ℝ :=
  (Real.sin (a * p.2) + c * Real.cos (a * p.1),
   Real.sin (b * p.1) + d * Real.cos (b * p.2))

def maxAbsDist (p q : ℝ × ℝ) : ℝ := max |p.1 - q.1| |p.2 - q.2|

def cliffordK (a b c d : ℝ) : ℝ := max (|a| * (1 + |c|)) (|b| * (1 + |d|))

/-! ## 1. Coordinate bounds -/

theorem clifford_fst_bound (a b c d : ℝ) (p : ℝ × ℝ) :
    |(clifford a b c d p).1| ≤ 1 + |c| := by
  unfold clifford; exact abs_le.mpr ⟨ by cases abs_cases c <;> nlinarith [ abs_le.mp ( Real.abs_sin_le_one ( a * p.2 ) ), abs_le.mp ( Real.abs_cos_le_one ( a * p.1 ) ) ], by cases abs_cases c <;> nlinarith [ abs_le.mp ( Real.abs_sin_le_one ( a * p.2 ) ), abs_le.mp ( Real.abs_cos_le_one ( a * p.1 ) ) ] ⟩ ;

theorem clifford_snd_bound (a b c d : ℝ) (p : ℝ × ℝ) :
    |(clifford a b c d p).2| ≤ 1 + |d| := by
  unfold clifford; exact abs_le.mpr ⟨ by cases abs_cases d <;> nlinarith [ abs_le.mp ( Real.abs_sin_le_one ( b * p.1 ) ), abs_le.mp ( Real.abs_cos_le_one ( b * p.2 ) ) ], by cases abs_cases d <;> nlinarith [ abs_le.mp ( Real.abs_sin_le_one ( b * p.1 ) ), abs_le.mp ( Real.abs_cos_le_one ( b * p.2 ) ) ] ⟩ ;

/-! ## 2. Box invariance -/

def cliffordBox (c d : ℝ) : Set (ℝ × ℝ) :=
  {p | |p.1| ≤ 1 + |c| ∧ |p.2| ≤ 1 + |d|}

theorem clifford_maps_into_box (a b c d : ℝ) (p : ℝ × ℝ) :
    clifford a b c d p ∈ cliffordBox c d := by
  exact ⟨ by simpa using clifford_fst_bound a b c d p, by simpa using clifford_snd_bound a b c d p ⟩

theorem clifford_range_subset_box (a b c d : ℝ) :
    Set.range (clifford a b c d) ⊆ cliffordBox c d := by
  exact Set.range_subset_iff.mpr fun p => clifford_maps_into_box a b c d p

/-! ## 3. Orbit boundedness -/

theorem clifford_orbit_bounded_succ (a b c d : ℝ) (p : ℝ × ℝ) (n : ℕ) :
    ((clifford a b c d)^[n+1] p) ∈ cliffordBox c d := by
  convert clifford_maps_into_box a b c d ( ( clifford a b c d ) ^[ n ] p ) using 1;
  exact Function.iterate_succ_apply' _ _ _

theorem clifford_orbit_bounded_of_mem_box (a b c d : ℝ) {p : ℝ × ℝ}
    (hp : p ∈ cliffordBox c d) (n : ℕ) :
    ((clifford a b c d)^[n] p) ∈ cliffordBox c d := by
  induction' n with n ih;
  · exact hp;
  · simpa only [ Function.iterate_succ_apply' ] using clifford_maps_into_box a b c d _

/-! ## 4. Trigonometric difference lemmas -/

theorem abs_sin_sub_le (u v : ℝ) : |Real.sin u - Real.sin v| ≤ |u - v| := by
  rw [Real.sin_sub_sin, abs_mul, abs_mul]
  have h1 : |Real.cos ((u + v) / 2)| ≤ 1 := Real.abs_cos_le_one _
  have h2 : |Real.sin ((u - v) / 2)| ≤ |(u - v) / 2| := Real.abs_sin_le_abs
  have key : |(2:ℝ)| * |Real.sin ((u - v) / 2)| * |Real.cos ((u + v) / 2)|
      ≤ 2 * |(u - v) / 2| * 1 := by
    have h2abs : |(2:ℝ)| = 2 := by norm_num
    rw [h2abs]
    gcongr
  have heq : (2:ℝ) * |(u - v) / 2| * 1 = |u - v| := by
    rw [abs_div]; norm_num; ring
  linarith [key, heq.ge, heq.le]

theorem abs_cos_sub_le (u v : ℝ) : |Real.cos u - Real.cos v| ≤ |u - v| := by
  rw [Real.cos_sub_cos, abs_mul, abs_mul]
  have h1 : |Real.sin ((u + v) / 2)| ≤ 1 := Real.abs_sin_le_one _
  have h2 : |Real.sin ((u - v) / 2)| ≤ |(u - v) / 2| := Real.abs_sin_le_abs
  have key : |(-2:ℝ)| * |Real.sin ((u + v) / 2)| * |Real.sin ((u - v) / 2)|
      ≤ 2 * 1 * |(u - v) / 2| := by
    have h2abs : |(-2:ℝ)| = 2 := by norm_num
    rw [h2abs]
    gcongr
  have heq : (2:ℝ) * 1 * |(u - v) / 2| = |u - v| := by
    rw [abs_div]; norm_num; ring
  linarith [key, heq.ge, heq.le]

/-! ## 5. Coordinate Lipschitz estimates -/

theorem clifford_fst_lipschitz (a b c d : ℝ) (p q : ℝ × ℝ) :
    |(clifford a b c d p).1 - (clifford a b c d q).1| ≤ |a| * (1 + |c|) * maxAbsDist p q := by
  unfold clifford maxAbsDist;
  -- Apply the triangle inequality to the first coordinate difference.
  have h1 : |Real.sin (a * p.2) - Real.sin (a * q.2)| ≤ |a| * |p.2 - q.2| := by
    convert abs_sin_sub_le ( a * p.2 ) ( a * q.2 ) using 1;
    rw [ ← mul_sub, abs_mul ]
  have h2 : |Real.cos (a * p.1) - Real.cos (a * q.1)| ≤ |a| * |p.1 - q.1| := by
    convert abs_cos_sub_le ( a * p.1 ) ( a * q.1 ) using 1
    rw [ ← mul_sub, abs_mul ]
  have h3 : |c * (Real.cos (a * p.1) - Real.cos (a * q.1))| ≤ |c| * |a| * |p.1 - q.1| := by
    simpa only [ mul_assoc, abs_mul ] using mul_le_mul_of_nonneg_left h2 ( abs_nonneg c );
  rw [ abs_le ] at *;
  constructor <;> cases max_cases |p.1 - q.1| |p.2 - q.2| <;> nlinarith [ abs_nonneg a, abs_nonneg c, mul_nonneg ( abs_nonneg a ) ( abs_nonneg c ) ]

theorem clifford_snd_lipschitz (a b c d : ℝ) (p q : ℝ × ℝ) :
    |(clifford a b c d p).2 - (clifford a b c d q).2| ≤ |b| * (1 + |d|) * maxAbsDist p q := by
  -- Apply the triangle inequality to the expression.
  have h_triangle : abs ((Real.sin (b * p.1) + d * Real.cos (b * p.2)) - (Real.sin (b * q.1) + d * Real.cos (b * q.2))) ≤ abs (Real.sin (b * p.1) - Real.sin (b * q.1)) + abs d * abs (Real.cos (b * p.2) - Real.cos (b * q.2)) := by
    rw [ ← abs_mul ];
    grind;
  -- Apply the inequalities for the sine and cosine differences.
  have h_sin_cos : abs (Real.sin (b * p.1) - Real.sin (b * q.1)) ≤ abs b * abs (p.1 - q.1) ∧ abs (Real.cos (b * p.2) - Real.cos (b * q.2)) ≤ abs b * abs (p.2 - q.2) := by
    exact ⟨ by simpa only [ ← abs_mul, mul_sub ] using abs_sin_sub_le _ _, by simpa only [ ← abs_mul, mul_sub ] using abs_cos_sub_le _ _ ⟩;
  unfold clifford maxAbsDist;
  cases max_cases |p.1 - q.1| |p.2 - q.2| <;> nlinarith [ abs_nonneg b, abs_nonneg d, mul_nonneg ( abs_nonneg b ) ( abs_nonneg d ) ]

/-! ## 6. Main max-distance Lipschitz theorem -/

theorem clifford_maxAbsDist_lipschitz (a b c d : ℝ) (p q : ℝ × ℝ) :
    maxAbsDist (clifford a b c d p) (clifford a b c d q) ≤ cliffordK a b c d * maxAbsDist p q := by
  -- Apply the Lipschitz estimates to the coordinates.
  have h1 : abs ((clifford a b c d p).1 - (clifford a b c d q).1) ≤ cliffordK a b c d * maxAbsDist p q := by
    refine' le_trans ( clifford_fst_lipschitz a b c d p q ) _;
    exact mul_le_mul_of_nonneg_right ( le_max_left _ _ ) ( by exact le_max_of_le_left ( abs_nonneg _ ) )
  have h2 : abs ((clifford a b c d p).2 - (clifford a b c d q).2) ≤ cliffordK a b c d * maxAbsDist p q := by
    convert clifford_snd_lipschitz a b c d p q |> le_trans <| mul_le_mul_of_nonneg_right ( le_max_right _ _ ) ( by exact le_max_of_le_left <| abs_nonneg _ ) using 1;
  exact max_le h1 h2