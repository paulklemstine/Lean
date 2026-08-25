import Mathlib

/-!
# Cube-digit families: beating the square-root barrier for sums of three cubes

The Vieta identity `a³ + b³ + (-a-b)³ = -3ab(a+b)` produces a two-dimensional
family of sums of three cubes, but its value map has divisor-type collisions, so
the injective subfamilies one can exhibit for it are essentially one-dimensional
and only give `≍ √N` represented integers below `N`.

This file develops a different, *provably injective*, three-parameter family of
sums of three **positive** cubes (so a fortiori three nonzero cubes: no padded
`0³`), based on a "cube-digit" (greedy) recovery principle:

* `cube_block_unique`: if `r < 3z² + 3z + 1` then the decomposition `z³ + r` is
  unique, i.e. `z` is the integer cube root of `z³ + r`;
* iterating this twice, on the box
  `1 ≤ x ≤ t⁴`, `t⁶ ≤ y < 2t⁶`, `2t⁹ ≤ z < 3t⁹`
  the map `(x, y, z) ↦ x³ + y³ + z³` is injective (`cubeSum_injOn`);
* the box has exactly `t¹⁹` points and all values lie in `[1, 36 t²⁷]`, giving
  `cube_digit_count : t¹⁹ ≤ (posRepSet (36 t²⁷)).ncard`;
* in real-analytic form this is a lower bound `≫ N^(19/27)` with `19/27 ≈ 0.7037`
  (`cube_digit_count_rpow`, `cube_digit_count_general`), and
  `cube_digit_beats_sqrt` shows explicitly that it dominates any fixed multiple
  of `√N`.

The exponent `19/27` comes from the three nested greedy windows: `z ≍ t⁹`,
`y ≍ z^(2/3)`, `x ≍ y^(2/3)`, i.e. `4 + 6 + 9 = 19` against `3 · 9 = 27`.
-/

namespace CubeDigitFamilies

/-! ## Represented sets -/

/-- `k` is a sum of three positive integral cubes. -/
def SumOfThreePositiveCubes (k : ℤ) : Prop :=
  ∃ x y z : ℤ, 0 < x ∧ 0 < y ∧ 0 < z ∧ x ^ 3 + y ^ 3 + z ^ 3 = k

/-- `k` is a sum of three nonzero integral cubes (no padded zero cube). -/
def SumOfThreeNonzeroCubes (k : ℤ) : Prop :=
  ∃ x y z : ℤ, x ≠ 0 ∧ y ≠ 0 ∧ z ≠ 0 ∧ x ^ 3 + y ^ 3 + z ^ 3 = k

theorem SumOfThreeNonzeroCubes_of_positive {k : ℤ} (h : SumOfThreePositiveCubes k) :
    SumOfThreeNonzeroCubes k := by
  obtain ⟨x, y, z, hx, hy, hz, hk⟩ := h
  exact ⟨x, y, z, hx.ne', hy.ne', hz.ne', hk⟩

/-- The positive integers `≤ N` which are sums of three positive cubes. -/
def posRepSet (N : ℕ) : Set ℤ :=
  {k | 0 < k ∧ k ≤ (N : ℤ) ∧ SumOfThreePositiveCubes k}

theorem posRepSet_finite (N : ℕ) : (posRepSet N).Finite :=
  (Set.finite_Icc (1 : ℤ) (N : ℤ)).subset (by rintro k ⟨h1, h2, -⟩; exact ⟨h1, h2⟩)

theorem posRepSet_mono {N M : ℕ} (h : N ≤ M) : posRepSet N ⊆ posRepSet M := by
  rintro k ⟨h1, h2, h3⟩
  exact ⟨h1, h2.trans (by exact_mod_cast h), h3⟩

theorem posRepSet_ncard_mono {N M : ℕ} (h : N ≤ M) :
    (posRepSet N).ncard ≤ (posRepSet M).ncard :=
  Set.ncard_le_ncard (posRepSet_mono h) (posRepSet_finite M)

theorem card_le_ncard_posRepSet {N : ℕ} (T : Finset ℤ) (hT : ∀ k ∈ T, k ∈ posRepSet N) :
    T.card ≤ (posRepSet N).ncard := by
  have hsub : (↑T : Set ℤ) ⊆ posRepSet N := fun k hk => hT k (by simpa using hk)
  have := Set.ncard_le_ncard hsub (posRepSet_finite N)
  simpa [Set.ncard_coe_finset] using this

/-! ## The cube-digit (greedy) recovery principle -/

/-- **Cube-digit uniqueness.**  A number of the form `z³ + r` with a remainder
`r` smaller than the cube gap `(z+1)³ - z³ = 3z² + 3z + 1` determines both `z`
and `r`.  This is the engine of all injectivity statements below. -/
theorem cube_block_unique {z r z' r' : ℕ}
    (h : r < 3 * z ^ 2 + 3 * z + 1) (h' : r' < 3 * z' ^ 2 + 3 * z' + 1)
    (heq : z ^ 3 + r = z' ^ 3 + r') : z = z' ∧ r = r' := by
  have key : ∀ a b ra rb : ℕ, a < b → ra < 3 * a ^ 2 + 3 * a + 1 →
      a ^ 3 + ra = b ^ 3 + rb → False := by
    intro a b ra rb hab hra heq'
    have hle : (a + 1) ^ 3 ≤ b ^ 3 := Nat.pow_le_pow_left hab 3
    have hexp : (a + 1) ^ 3 = a ^ 3 + 3 * a ^ 2 + 3 * a + 1 := by ring
    linarith
  rcases lt_trichotomy z z' with hlt | hz | hgt
  · exact (key z z' r r' hlt h heq).elim
  · subst hz
    exact ⟨rfl, by omega⟩
  · exact (key z' z r' r hgt h' heq.symm).elim

/-! ## The three-scale box -/

/-- The parameter box: `1 ≤ x ≤ t⁴`, `t⁶ ≤ y < 2t⁶`, `2t⁹ ≤ z < 3t⁹`. -/
def boxSet (t : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  Finset.Icc 1 (t ^ 4) ×ˢ Finset.Ico (t ^ 6) (2 * t ^ 6) ×ˢ
    Finset.Ico (2 * t ^ 9) (3 * t ^ 9)

/-- The value of a box point: the sum of the three cubes. -/
def cubeSum (p : ℕ × ℕ × ℕ) : ℕ := p.1 ^ 3 + p.2.1 ^ 3 + p.2.2 ^ 3

theorem mem_boxSet_iff {t x y z : ℕ} :
    (x, y, z) ∈ boxSet t ↔
      (1 ≤ x ∧ x ≤ t ^ 4) ∧ (t ^ 6 ≤ y ∧ y < 2 * t ^ 6) ∧
        (2 * t ^ 9 ≤ z ∧ z < 3 * t ^ 9) := by
  simp [boxSet, Finset.mem_product, Finset.mem_Icc, Finset.mem_Ico, and_assoc]

/-- The box has exactly `t¹⁹` points. -/
theorem boxSet_card (t : ℕ) : (boxSet t).card = t ^ 19 := by
  rw [boxSet, Finset.card_product, Finset.card_product, Nat.card_Icc, Nat.card_Ico,
    Nat.card_Ico]
  have h1 : t ^ 4 + 1 - 1 = t ^ 4 := by omega
  have h2 : 2 * t ^ 6 - t ^ 6 = t ^ 6 := by omega
  have h3 : 3 * t ^ 9 - 2 * t ^ 9 = t ^ 9 := by omega
  rw [h1, h2, h3]
  ring

/-- First greedy window: `x³` is below the cube gap at `y`. -/
theorem box_gap_x {t x y z : ℕ} (h : (x, y, z) ∈ boxSet t) :
    x ^ 3 < 3 * y ^ 2 + 3 * y + 1 := by
  rw [mem_boxSet_iff] at h
  obtain ⟨⟨-, hx⟩, ⟨hy, -⟩, -⟩ := h
  have hx3 : x ^ 3 ≤ (t ^ 4) ^ 3 := Nat.pow_le_pow_left hx 3
  have hy2 : (t ^ 6) ^ 2 ≤ y ^ 2 := Nat.pow_le_pow_left hy 2
  have e1 : (t ^ 4) ^ 3 = t ^ 12 := by ring
  have e2 : (t ^ 6) ^ 2 = t ^ 12 := by ring
  rw [e1] at hx3
  rw [e2] at hy2
  have h0 : 0 ≤ y ^ 2 := Nat.zero_le _
  have h0' : 0 ≤ y := Nat.zero_le _
  linarith

/-- Second greedy window: `x³ + y³` is below the cube gap at `z`. -/
theorem box_gap_xy {t x y z : ℕ} (ht : 1 ≤ t) (h : (x, y, z) ∈ boxSet t) :
    x ^ 3 + y ^ 3 < 3 * z ^ 2 + 3 * z + 1 := by
  rw [mem_boxSet_iff] at h
  obtain ⟨⟨-, hx⟩, ⟨-, hy⟩, ⟨hz, -⟩⟩ := h
  have hx3 : x ^ 3 ≤ (t ^ 4) ^ 3 := Nat.pow_le_pow_left hx 3
  have hy3 : y ^ 3 < (2 * t ^ 6) ^ 3 := Nat.pow_lt_pow_left hy (by norm_num)
  have hz2 : (2 * t ^ 9) ^ 2 ≤ z ^ 2 := Nat.pow_le_pow_left hz 2
  have e1 : (t ^ 4) ^ 3 = t ^ 12 := by ring
  have e2 : (2 * t ^ 6) ^ 3 = 8 * t ^ 18 := by ring
  have e3 : (2 * t ^ 9) ^ 2 = 4 * t ^ 18 := by ring
  have e4 : t ^ 12 ≤ t ^ 18 := Nat.pow_le_pow_right ht (by norm_num)
  rw [e1] at hx3
  rw [e2] at hy3
  rw [e3] at hz2
  have h0 : 0 ≤ z := Nat.zero_le _
  have h1 : 0 ≤ t ^ 18 := Nat.zero_le _
  linarith

/-- Every box value is at most `36 t²⁷`. -/
theorem box_value_le {t x y z : ℕ} (ht : 1 ≤ t) (h : (x, y, z) ∈ boxSet t) :
    cubeSum (x, y, z) ≤ 36 * t ^ 27 := by
  rw [mem_boxSet_iff] at h
  obtain ⟨⟨-, hx⟩, ⟨-, hy⟩, ⟨-, hz⟩⟩ := h
  have hx3 : x ^ 3 ≤ (t ^ 4) ^ 3 := Nat.pow_le_pow_left hx 3
  have hy3 : y ^ 3 < (2 * t ^ 6) ^ 3 := Nat.pow_lt_pow_left hy (by norm_num)
  have hz3 : z ^ 3 < (3 * t ^ 9) ^ 3 := Nat.pow_lt_pow_left hz (by norm_num)
  have e1 : (t ^ 4) ^ 3 = t ^ 12 := by ring
  have e2 : (2 * t ^ 6) ^ 3 = 8 * t ^ 18 := by ring
  have e3 : (3 * t ^ 9) ^ 3 = 27 * t ^ 27 := by ring
  have e4 : t ^ 12 ≤ t ^ 27 := Nat.pow_le_pow_right ht (by norm_num)
  have e5 : t ^ 18 ≤ t ^ 27 := Nat.pow_le_pow_right ht (by norm_num)
  rw [e1] at hx3
  rw [e2] at hy3
  rw [e3] at hz3
  unfold cubeSum
  simp only
  linarith

/-- Box points are positive in each coordinate. -/
theorem box_pos {t x y z : ℕ} (ht : 1 ≤ t) (h : (x, y, z) ∈ boxSet t) :
    0 < x ∧ 0 < y ∧ 0 < z := by
  rw [mem_boxSet_iff] at h
  obtain ⟨⟨hx, -⟩, ⟨hy, -⟩, ⟨hz, -⟩⟩ := h
  have h6 : 1 ≤ t ^ 6 := Nat.one_le_pow _ _ ht
  have h9 : 1 ≤ t ^ 9 := Nat.one_le_pow _ _ ht
  exact ⟨hx, by omega, by omega⟩

/-- **Two-step greedy injectivity.**  If two triples satisfy the two nested
greedy window conditions and have the same cube sum, they are equal.  This is
the reusable engine: any box satisfying the gap inequalities carries an
injective cube-sum map. -/
theorem cubeSum_inj_of_gaps {x y z x' y' z' : ℕ}
    (h1 : x ^ 3 < 3 * y ^ 2 + 3 * y + 1) (h2 : x' ^ 3 < 3 * y' ^ 2 + 3 * y' + 1)
    (h3 : x ^ 3 + y ^ 3 < 3 * z ^ 2 + 3 * z + 1)
    (h4 : x' ^ 3 + y' ^ 3 < 3 * z' ^ 2 + 3 * z' + 1)
    (heq : x ^ 3 + y ^ 3 + z ^ 3 = x' ^ 3 + y' ^ 3 + z' ^ 3) :
    x = x' ∧ y = y' ∧ z = z' := by
  have hval' : z ^ 3 + (x ^ 3 + y ^ 3) = z' ^ 3 + (x' ^ 3 + y' ^ 3) := by omega
  obtain ⟨hz, hxy⟩ := cube_block_unique h3 h4 hval'
  have hxy' : y ^ 3 + x ^ 3 = y' ^ 3 + x' ^ 3 := by omega
  obtain ⟨hy, hx3⟩ := cube_block_unique h1 h2 hxy'
  exact ⟨Nat.pow_left_injective (by norm_num) hx3, hy, hz⟩

/-- **Injectivity of the cube-digit family.**  On the three-scale box the map
`(x,y,z) ↦ x³ + y³ + z³` is injective: the greedy windows let one read off `z`,
then `y`, then `x` from the value. -/
theorem cubeSum_injOn (t : ℕ) (ht : 1 ≤ t) :
    Set.InjOn (fun p : ℕ × ℕ × ℕ => (cubeSum p : ℤ)) ↑(boxSet t) := by
  rintro ⟨x, y, z⟩ hp ⟨x', y', z'⟩ hq hEq
  have hp' : (x, y, z) ∈ boxSet t := hp
  have hq' : (x', y', z') ∈ boxSet t := hq
  have hEq' : ((cubeSum (x, y, z) : ℤ)) = ((cubeSum (x', y', z') : ℤ)) := hEq
  have hval : cubeSum (x, y, z) = cubeSum (x', y', z') := by exact_mod_cast hEq'
  have hval2 : x ^ 3 + y ^ 3 + z ^ 3 = x' ^ 3 + y' ^ 3 + z' ^ 3 := hval
  obtain ⟨hx, hy, hz⟩ :=
    cubeSum_inj_of_gaps (box_gap_x hp') (box_gap_x hq') (box_gap_xy ht hp')
      (box_gap_xy ht hq') hval2
  simp [hx, hy, hz]

/-! ## The quantitative lower bound -/

/-- **Main counting theorem.**  For every `t ≥ 1` there are at least `t¹⁹`
positive integers `≤ 36 t²⁷` which are sums of three positive (hence nonzero)
cubes.  Since `36 t²⁷ = N` this is a lower bound of order `N^(19/27)`. -/
theorem cube_digit_count (t : ℕ) (ht : 1 ≤ t) :
    t ^ 19 ≤ (posRepSet (36 * t ^ 27)).ncard := by
  classical
  set T : Finset ℤ := (boxSet t).image (fun p => (cubeSum p : ℤ)) with hT
  have hcard : T.card = t ^ 19 := by
    rw [hT, Finset.card_image_of_injOn (cubeSum_injOn t ht), boxSet_card]
  have hmem : ∀ k ∈ T, k ∈ posRepSet (36 * t ^ 27) := by
    intro k hk
    rw [hT, Finset.mem_image] at hk
    obtain ⟨⟨x, y, z⟩, hxyz, rfl⟩ := hk
    obtain ⟨hx, hy, hz⟩ := box_pos ht hxyz
    refine ⟨?_, ?_, ?_⟩
    · have : 0 < cubeSum (x, y, z) := by
        unfold cubeSum; simp only; positivity
      exact_mod_cast this
    · exact_mod_cast box_value_le ht hxyz
    · refine ⟨(x : ℤ), (y : ℤ), (z : ℤ), by exact_mod_cast hx, by exact_mod_cast hy,
        by exact_mod_cast hz, ?_⟩
      unfold cubeSum
      push_cast
      ring
  calc t ^ 19 = T.card := hcard.symm
    _ ≤ (posRepSet (36 * t ^ 27)).ncard := card_le_ncard_posRepSet T hmem

/-- Every integer counted above is a sum of three nonzero cubes: the bound
contains no padded zero cubes. -/
theorem posRepSet_no_padded_zero {N : ℕ} {k : ℤ} (hk : k ∈ posRepSet N) :
    SumOfThreeNonzeroCubes k :=
  SumOfThreeNonzeroCubes_of_positive hk.2.2

/-- **The bound beats the square-root barrier.**  For `t ≥ 4` the cube-digit
count `t¹⁹` exceeds one hundred times `√N` for `N = 36 t²⁷`. -/
theorem cube_digit_beats_sqrt (t : ℕ) (ht : 4 ≤ t) :
    100 * Nat.sqrt (36 * t ^ 27) ≤ t ^ 19 := by
  have ht1 : 1 ≤ t := by omega
  have hsq : Nat.sqrt (36 * t ^ 27) ≤ 6 * t ^ 14 := by
    have hle : 36 * t ^ 27 ≤ (6 * t ^ 14) * (6 * t ^ 14) := by
      have : t ^ 27 ≤ t ^ 28 := Nat.pow_le_pow_right ht1 (by norm_num)
      calc 36 * t ^ 27 ≤ 36 * t ^ 28 := by omega
        _ = (6 * t ^ 14) * (6 * t ^ 14) := by ring
    calc Nat.sqrt (36 * t ^ 27) ≤ Nat.sqrt ((6 * t ^ 14) * (6 * t ^ 14)) :=
          Nat.sqrt_le_sqrt hle
      _ = 6 * t ^ 14 := Nat.sqrt_eq _
  have h600 : 600 ≤ t ^ 5 := by
    have : (4 : ℕ) ^ 5 ≤ t ^ 5 := Nat.pow_le_pow_left ht 5
    omega
  calc 100 * Nat.sqrt (36 * t ^ 27) ≤ 100 * (6 * t ^ 14) := by omega
    _ = 600 * t ^ 14 := by ring
    _ ≤ t ^ 5 * t ^ 14 := Nat.mul_le_mul_right _ h600
    _ = t ^ 19 := by ring

/-! ## Real-analytic form of the bound -/

/-- **Real form at the sample points.**  With `N = 36 t²⁷` the count is at least
`N^(19/27) / 36`. -/
theorem cube_digit_count_rpow (t : ℕ) (ht : 1 ≤ t) :
    ((36 * t ^ 27 : ℕ) : ℝ) ^ ((19 : ℝ) / 27) / 36 ≤
      ((posRepSet (36 * t ^ 27)).ncard : ℝ) := by
  have ht0 : (0 : ℝ) ≤ (t : ℝ) := Nat.cast_nonneg t
  have hcast : ((36 * t ^ 27 : ℕ) : ℝ) = 36 * (t : ℝ) ^ 27 := by push_cast; ring
  have hkey : ((36 * t ^ 27 : ℕ) : ℝ) ^ ((19 : ℝ) / 27) ≤ 36 * (t : ℝ) ^ 19 := by
    rw [hcast, Real.mul_rpow (by norm_num) (by positivity)]
    have h1 : ((t : ℝ) ^ 27) ^ ((19 : ℝ) / 27) = (t : ℝ) ^ 19 := by
      rw [← Real.rpow_natCast (t : ℝ) 27, ← Real.rpow_mul ht0]
      norm_num
    have h2 : (36 : ℝ) ^ ((19 : ℝ) / 27) ≤ 36 := by
      calc (36 : ℝ) ^ ((19 : ℝ) / 27) ≤ (36 : ℝ) ^ (1 : ℝ) :=
            Real.rpow_le_rpow_of_exponent_le (by norm_num) (by norm_num)
        _ = 36 := by norm_num
    rw [h1]
    have hpos : (0 : ℝ) ≤ (t : ℝ) ^ 19 := by positivity
    nlinarith
  have hcount : ((t : ℝ) ^ 19) ≤ ((posRepSet (36 * t ^ 27)).ncard : ℝ) := by
    have := cube_digit_count t ht
    exact_mod_cast this
  linarith

/-- **Real form for all `N`.**  For every `N ≥ 36` the number of positive
integers `≤ N` that are sums of three positive cubes is at least
`(N / (36 · 2²⁷))^(19/27)`; in particular it is `≫ N^(19/27)`. -/
theorem cube_digit_count_general (N : ℕ) (hN : 36 ≤ N) :
    ((N : ℝ) / (36 * 2 ^ 27)) ^ ((19 : ℝ) / 27) ≤ ((posRepSet N).ncard : ℝ) := by
  classical
  set t : ℕ := Nat.floor (((N : ℝ) / 36) ^ ((1 : ℝ) / 27)) with htdef
  have hNpos : (0 : ℝ) < (N : ℝ) / 36 := by
    have : (36 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
    linarith
  have hone : (1 : ℝ) ≤ ((N : ℝ) / 36) ^ ((1 : ℝ) / 27) := by
    have h1 : (1 : ℝ) ≤ (N : ℝ) / 36 := by
      have : (36 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
      linarith
    exact Real.one_le_rpow h1 (by norm_num)
  have ht1 : 1 ≤ t := by
    rw [htdef]
    exact Nat.le_floor (by exact_mod_cast hone)
  -- `t` is a lower approximation, so `36 t²⁷ ≤ N`
  have hfloor_le : (t : ℝ) ≤ ((N : ℝ) / 36) ^ ((1 : ℝ) / 27) := Nat.floor_le (by positivity)
  have hpow_le : (t : ℝ) ^ 27 ≤ (N : ℝ) / 36 := by
    have h := pow_le_pow_left₀ (Nat.cast_nonneg t) hfloor_le 27
    calc (t : ℝ) ^ 27 ≤ (((N : ℝ) / 36) ^ ((1 : ℝ) / 27)) ^ 27 := h
      _ = (N : ℝ) / 36 := by
          rw [← Real.rpow_natCast (((N : ℝ) / 36) ^ ((1 : ℝ) / 27)) 27,
            ← Real.rpow_mul (le_of_lt hNpos)]
          norm_num
  have hNbound : 36 * t ^ 27 ≤ N := by
    have : (36 : ℝ) * (t : ℝ) ^ 27 ≤ (N : ℝ) := by linarith
    exact_mod_cast this
  -- `t + 1` is an upper approximation, so `N ≤ 36 (2t)²⁷`
  have hfloor_lt : ((N : ℝ) / 36) ^ ((1 : ℝ) / 27) < (t : ℝ) + 1 :=
    Nat.lt_floor_add_one _
  have hupper : (N : ℝ) / 36 < ((t : ℝ) + 1) ^ 27 := by
    have h := pow_lt_pow_left₀ hfloor_lt (by positivity) (by norm_num : 27 ≠ 0)
    calc (N : ℝ) / 36
        = (((N : ℝ) / 36) ^ ((1 : ℝ) / 27)) ^ 27 := by
          rw [← Real.rpow_natCast (((N : ℝ) / 36) ^ ((1 : ℝ) / 27)) 27,
            ← Real.rpow_mul (le_of_lt hNpos)]
          norm_num
      _ < ((t : ℝ) + 1) ^ 27 := h
  have h2t : ((t : ℝ) + 1) ≤ 2 * (t : ℝ) := by
    have : (1 : ℝ) ≤ (t : ℝ) := by exact_mod_cast ht1
    linarith
  have hN2 : (N : ℝ) / (36 * 2 ^ 27) ≤ (t : ℝ) ^ 27 := by
    have h1 : ((t : ℝ) + 1) ^ 27 ≤ (2 * (t : ℝ)) ^ 27 :=
      pow_le_pow_left₀ (by positivity) h2t 27
    have h2 : (2 * (t : ℝ)) ^ 27 = 2 ^ 27 * (t : ℝ) ^ 27 := by ring
    have : (N : ℝ) / 36 ≤ 2 ^ 27 * (t : ℝ) ^ 27 := by
      calc (N : ℝ) / 36 ≤ ((t : ℝ) + 1) ^ 27 := le_of_lt hupper
        _ ≤ (2 * (t : ℝ)) ^ 27 := h1
        _ = 2 ^ 27 * (t : ℝ) ^ 27 := h2
    rw [div_le_iff₀ (by positivity)]
    nlinarith [this]
  -- put the two estimates together
  have hstep : ((N : ℝ) / (36 * 2 ^ 27)) ^ ((19 : ℝ) / 27) ≤ (t : ℝ) ^ 19 := by
    have hnn : (0 : ℝ) ≤ (N : ℝ) / (36 * 2 ^ 27) := by positivity
    have h1 : ((N : ℝ) / (36 * 2 ^ 27)) ^ ((19 : ℝ) / 27) ≤
        ((t : ℝ) ^ 27) ^ ((19 : ℝ) / 27) :=
      Real.rpow_le_rpow hnn hN2 (by norm_num)
    have h2 : ((t : ℝ) ^ 27) ^ ((19 : ℝ) / 27) = (t : ℝ) ^ 19 := by
      rw [← Real.rpow_natCast (t : ℝ) 27, ← Real.rpow_mul (Nat.cast_nonneg t)]
      norm_num
    linarith [h1, h2.le, h2.ge]
  have hmono : (posRepSet (36 * t ^ 27)).ncard ≤ (posRepSet N).ncard :=
    posRepSet_ncard_mono hNbound
  have hcount : ((t : ℝ) ^ 19) ≤ ((posRepSet N).ncard : ℝ) := by
    have h := (cube_digit_count t ht1).trans hmono
    exact_mod_cast h
  linarith

end CubeDigitFamilies