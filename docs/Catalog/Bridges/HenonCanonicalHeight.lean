import Mathlib

/-!
# Escape regions and normalized heights for a Hénon map

This file formalizes algebraic and analytic ingredients used in the study of the map
`φ(x,y) = (y, x + y^D + b)`.  The escape region below is a slightly strengthened,
robust version of the usual archimedean escape region: the additional condition
`3 |y| < |y|^D` makes forward invariance transparent even in the presence of
cancellation.  No global arithmetic-height machinery is assumed.
-/

namespace HenonCanonicalHeight

/-- The normalized Hénon map `φ(x,y) = (y, x + y^D + b)`. -/
def henon (D : ℕ) (b : ℝ) (P : ℝ × ℝ) : ℝ × ℝ :=
  (P.2, P.1 + P.2 ^ D + b)

/-- The polynomial inverse of `henon`. -/
def henonInv (D : ℕ) (b : ℝ) (P : ℝ × ℝ) : ℝ × ℝ :=
  (P.2 - P.1 ^ D - b, P.1)

/-- The displayed inverse is a left inverse. -/
theorem henonInv_henon (D : ℕ) (b : ℝ) (P : ℝ × ℝ) :
    henonInv D b (henon D b P) = P := by
  simp [henon, henonInv]
  ring_nf

/-- The displayed inverse is a right inverse. -/
theorem henon_henonInv (D : ℕ) (b : ℝ) (P : ℝ × ℝ) :
    henon D b (henonInv D b P) = P := by
  unfold henon henonInv
  simp
  ring_nf

/-- A robust archimedean forward escape region.  Its first inequality says the
new nonlinear term dominates both possible error terms and `1`; its second says
that one third of the nonlinear term is already larger than the old coordinate. -/
def InForwardRegion (D : ℕ) (b : ℝ) (P : ℝ × ℝ) : Prop :=
  3 * max (max |P.1| |b|) 1 < |P.2| ^ D ∧
  3 * |P.2| < |P.2| ^ D

/-- In the forward region, one Hénon step has the standard archimedean
`1/3` and `5/3` growth bounds. -/
theorem forward_growth_bounds {D : ℕ} {b x y : ℝ}
    (hP : InForwardRegion D b (x, y)) :
    (1 / 3 : ℝ) * |y| ^ D < |x + y ^ D + b| ∧
      |x + y ^ D + b| < (5 / 3 : ℝ) * |y| ^ D := by
  -- Extract the key inequalities from InForwardRegion
  have h1 : 3 * max (max |x| |b|) 1 < |y| ^ D := hP.1
  have h2 : 3 * |y| < |y| ^ D := hP.2
  -- From h1, we get |x| < |y|^D / 3 and |b| < |y|^D / 3
  have h1' : max (max |x| |b|) 1 < |y| ^ D / 3 := by linarith
  have hx : |x| < |y| ^ D / 3 := by
    calc |x| ≤ max |x| |b| := le_max_left _ _
      _ ≤ max (max |x| |b|) 1 := le_max_left _ _
      _ < |y| ^ D / 3 := h1'
  have hb : |b| < |y| ^ D / 3 := by
    calc |b| ≤ max |x| |b| := le_max_right _ _
      _ ≤ max (max |x| |b|) 1 := le_max_left _ _
      _ < |y| ^ D / 3 := h1'
  -- Bound on |x + b|
  have hxb : |x + b| < 2 * |y| ^ D / 3 := by
    calc |x + b| ≤ |x| + |b| := abs_add_le x b
      _ < |y| ^ D / 3 + |y| ^ D / 3 := by linarith
      _ = 2 * |y| ^ D / 3 := by ring
  -- Note: |y^D| = |y|^D
  have hyD : |y ^ D| = |y| ^ D := abs_pow y D
  -- Rewrite as y^D + (x + b)
  have rew : x + y ^ D + b = y ^ D + (x + b) := by ring
  constructor
  · -- Lower bound: |y^D + (x+b)| ≥ |y^D| - |x+b|
    have h := abs_sub_abs_le_abs_add (y ^ D) (x + b)
    calc 1 / 3 * |y| ^ D = |y| ^ D - 2 * |y| ^ D / 3 := by ring
      _ < |y ^ D| - |x + b| := by rw [hyD]; linarith
      _ ≤ |y ^ D + (x + b)| := h
      _ = |x + y ^ D + b| := by rw [← rew]
  · -- Upper bound: |y^D + (x+b)| ≤ |y^D| + |x+b|
    calc |x + y ^ D + b| = |y ^ D + (x + b)| := by rw [rew]
      _ ≤ |y ^ D| + |x + b| := abs_add_le _ _
      _ = |y| ^ D + |x + b| := by rw [hyD]
      _ < |y| ^ D + 2 * |y| ^ D / 3 := by linarith
      _ = 5 / 3 * |y| ^ D := by ring

/-- The strengthened forward escape region is invariant under `henon`. -/
theorem forward_region_invariant {D : ℕ} (hD : 2 ≤ D) {b : ℝ} {P : ℝ × ℝ}
    (hP : InForwardRegion D b P) :
    InForwardRegion D b (henon D b P) := by
  -- Let x = P.1, y = P.2
  set x := P.1 with hx
  set y := P.2 with hy
  -- Unfold definitions
  unfold henon InForwardRegion
  -- Get the original bounds
  have h1 : 3 * max (max |x| |b|) 1 < |y| ^ D := hP.1
  have h2 : 3 * |y| < |y| ^ D := hP.2
  -- This means |y| > 1
  have hy_one : |y| > 1 := by
    by_contra hc
    push_neg at hc
    have hy_nonneg : |y| ≥ 0 := abs_nonneg _
    have hyD_le_y : |y| ^ D ≤ |y| := by
      have hD1 : 1 ≤ D := by omega
      by_cases hy_eq_zero : |y| = 0
      · simp [hy_eq_zero, zero_pow (by omega : D ≠ 0)]
      · have hy_pos : |y| > 0 := lt_of_le_of_ne hy_nonneg (Ne.symm hy_eq_zero)
        calc |y| ^ D ≤ |y| ^ 2 := pow_le_pow_of_le_one hy_nonneg hc (by omega : D ≥ 2)
          _ = |y| * |y| := by ring
          _ ≤ |y| * 1 := by nlinarith
          _ = |y| := by ring
    linarith
  -- Apply forward_growth_bounds to get bounds on |x + y^D + b|
  have growth := forward_growth_bounds hP
  -- Let y' = x + y^D + b
  set y' := x + y ^ D + b with hy'_def
  -- We have (1/3) * |y|^D < |y'| < (5/3) * |y|^D
  have hy'_lower : (1/3 : ℝ) * |y| ^ D < |y'| := growth.1
  have hy'_upper : |y'| < (5/3 : ℝ) * |y| ^ D := growth.2
  -- From h2 and D ≥ 2, we get |y|^D > |y|, so (1/3)|y|^D > |y|/3 * 3 = |y| is not quite right
  -- Actually: |y|^D > 3|y| (from h2), so (1/3)|y|^D > |y|
  have hy'_gt_y : |y'| > |y| := by linarith
  -- Since |y| > 1, we have |y'| > 1
  have hy'_one : |y'| > 1 := by linarith
  -- Simplify the goal: (P.2, y').1 = y and (P.2, y').2 = y'
  simp
  -- Need to prove: 3 * max (max |y| |b|) 1 < |y'|^D ∧ 3 * |y'| < |y'|^D
  have key : |y| ^ D < |y'| ^ D := by
    gcongr
  -- Each component of max (max |y| |b|) 1 is < |y|^D / 3
  have hy_bound : |y| < |y|^D / 3 := by linarith
  have hb_bound : |b| < |y|^D / 3 := by linarith [le_max_right |x| |b|, le_max_left (max |x| |b|) 1]
  have h1_bound : 1 < |y|^D / 3 := by
    have : |y|^D > 1 := one_lt_pow₀ hy_one (by omega : D ≠ 0)
    linarith
  have hmax_lt : max (max |y| |b|) 1 < |y|^D / 3 := by
    apply max_lt <;> [apply max_lt; linarith] <;> linarith
  have h1' : 3 * max (max |y| |b|) 1 < |y|^D := by linarith
  have h1'' : 3 * max (max |y| |b|) 1 < |y'|^D := by linarith
  constructor
  · exact h1''
  · -- Second condition: 3 * |y'| < |y'|^D
    have hy_pos : |y| > 0 := by linarith
    have hy_Dm1 : |y| ^ (D - 1) > 3 := by
      have h2' : |y| ^ D > 3 * |y| := h2
      have hDeq : D = (D - 1) + 1 := by omega
      rw [hDeq, pow_succ] at h2'
      nlinarith
    have hy'_Dm1 : |y'| ^ (D - 1) > 3 := by
      have hy_abs_nonneg : |y| ≥ 0 := abs_nonneg _
      have hDm1_ne : D - 1 ≠ 0 := by omega
      calc |y'| ^ (D - 1) > |y| ^ (D - 1) := by gcongr
        _ > 3 := hy_Dm1
    have hD_eq : D = (D - 1) + 1 := by omega
    rw [hD_eq, pow_succ]
    nlinarith [abs_nonneg y']

/-- A robust backward escape region, obtained by exchanging the coordinates. -/
def InBackwardRegion (D : ℕ) (b : ℝ) (P : ℝ × ℝ) : Prop :=
  3 * max (max |P.2| |b|) 1 < |P.1| ^ D ∧
  3 * |P.1| < |P.1| ^ D

/-- The strengthened backward escape region is invariant under the inverse map. -/
theorem backward_region_invariant {D : ℕ} (hD : 2 ≤ D) {b : ℝ} {P : ℝ × ℝ}
    (hP : InBackwardRegion D b P) :
    InBackwardRegion D b (henonInv D b P) := by
  obtain ⟨h1, h2⟩ := hP
  simp [InBackwardRegion, henonInv] at *
  -- Let z = P.2 - P.1^D - b
  set z := P.2 - P.1 ^ D - b with hz_def
  -- Key bounds from h1
  have h1' : max (max |P.2| |b|) 1 < |P.1| ^ D / 3 := by linarith
  have hP2_bound : |P.2| < |P.1| ^ D / 3 := by
    calc |P.2| ≤ max |P.2| |b| := le_max_left _ _
      _ ≤ max (max |P.2| |b|) 1 := le_max_left _ _
      _ < |P.1| ^ D / 3 := h1'
  have hb_bound : |b| < |P.1| ^ D / 3 := by
    calc |b| ≤ max |P.2| |b| := le_max_right _ _
      _ ≤ max (max |P.2| |b|) 1 := le_max_left _ _
      _ < |P.1| ^ D / 3 := h1'
  -- |P.1|^D > 3 since max ≥ 1
  have hmax_ge_one : (1 : ℝ) ≤ max (max |P.2| |b|) 1 := le_max_right _ _
  have hPD_pos : (3 : ℝ) < |P.1| ^ D := by nlinarith
  have hPD_div3_pos : (1 : ℝ) < |P.1| ^ D / 3 := by linarith
  -- Lower bound on |z| using triangle inequality
  have hz_lower : |z| ≥ |P.1| ^ D - |P.2| - |b| := by
    have hz_eq : z = -(P.1 ^ D + (b - P.2)) := by simp [hz_def]; ring
    rw [hz_eq, abs_neg]
    have htri : |P.1 ^ D + (b - P.2)| ≥ |P.1 ^ D| - |b - P.2| := by
      have := abs_sub_abs_le_abs_add (P.1 ^ D) (b - P.2)
      linarith
    have htri2 : |b - P.2| ≤ |b| + |P.2| := abs_sub _ _
    have habs_pow : |P.1 ^ D| = |P.1| ^ D := abs_pow P.1 D
    calc |P.1 ^ D + (b - P.2)| ≥ |P.1 ^ D| - |b - P.2| := htri
      _ = |P.1|^D - |b - P.2| := by rw [habs_pow]
      _ ≥ |P.1|^D - (|b| + |P.2|) := by linarith [htri2]
      _ = |P.1| ^ D - |P.2| - |b| := by ring
  -- |z| > |P.1|^D / 3 > 1
  have hz_gt : |z| > |P.1| ^ D / 3 := by linarith
  have hz_gt1 : |z| > 1 := by linarith
  -- |z| > |P.1| since |P.1|^(D-1) > 3
  have heq_pow : |P.1| ^ D = |P.1| ^ (D - 1) * |P.1| := by
    rcases D with _ | _ | D <;> simp [pow_succ] at *
  have hP1_pos : 0 < |P.1| := by
    have hD_pos : D ≠ 0 := by linarith
    have h1_abs : |P.1| ≥ 0 := abs_nonneg _
    cases' lt_or_eq_of_le h1_abs with hpos heq
    · exact hpos
    · rw [heq.symm] at hPD_pos
      simp [hD_pos] at hPD_pos
      linarith
  have hPD_div3_gt_P1 : |P.1| ^ D / 3 > |P.1| := by
    have h2'_old : 3 < |P.1| ^ (D - 1) := by nlinarith [heq_pow, hP1_pos]
    rw [heq_pow]
    nlinarith [h2'_old]
  have hz_gt_P1 : |z| > |P.1| := by linarith
  have h2'_old : 3 < |P.1| ^ (D - 1) := by nlinarith [heq_pow, hP1_pos]
  -- |z|^(D-1) > |P.1|^(D-1) > 3
  have hD1 : D - 1 ≥ 1 := by omega
  have hz_sub : |z| ^ (D - 1) > |P.1| ^ (D - 1) := by gcongr
  have hz_pow_gt3 : 3 < |z| ^ (D - 1) := lt_trans h2'_old hz_sub
  -- |z|^D = |z| * |z|^(D-1)
  have heqz : |z| ^ D = |z| * |z| ^ (D - 1) := by
    have hD_eq : D = D - 1 + 1 := by omega
    conv_lhs => rw [hD_eq, pow_succ]
    ring
  -- Second part: 3 * |z| < |z|^D
  have h_part2 : 3 * |z| < |z| ^ D := by rw [heqz]; nlinarith
  -- First part: 3 * max (max |P.1| |b|) 1 < |z|^D
  have h_part1 : 3 * max (max |P.1| |b|) 1 < |z| ^ D := by
    have hb_le_z : |b| ≤ |z| := by linarith
    have hmax_le : max (max |P.1| |b|) 1 ≤ |z| := by
      have h1 : max |P.1| |b| ≤ |z| := le_trans (max_le_max hz_gt_P1.le le_rfl) (max_le le_rfl hb_le_z)
      exact max_le h1 hz_gt1.le
    nlinarith [h_part2]
  exact ⟨h_part1, h_part2⟩

/-- A finite-stage canonical-height estimate.  If a nonnegative raw height changes
by at most `C` from the exact degree-`D` scaling law, then every normalized iterate
stays within `C/(D-1)` of the initial height.  This is the geometric-series estimate
at the core of canonical-height constructions. -/
theorem normalized_height_error_bound
    {D : ℕ} (hD : 2 ≤ D) (h : ℕ → ℝ) (C : ℝ) (hC : 0 ≤ C)
    (hscale : ∀ n, |h (n + 1) - (D : ℝ) * h n| ≤ C) :
    ∀ n, |h n / (D : ℝ) ^ n - h 0| ≤ C / ((D : ℝ) - 1) := by
  -- Stronger bound: |h n / D^n - h 0| ≤ C * (1 - 1/D^n) / (D - 1)
  have key : ∀ n, |h n / (D : ℝ) ^ n - h 0| ≤ C * (1 - 1 / (D : ℝ) ^ n) / ((D : ℝ) - 1) := by
    intro n
    induction n with
    | zero => simp
    | succ n ih =>
      have hD_pos : (0 : ℝ) < D := by linarith [show (2 : ℝ) ≤ D by exact_mod_cast hD]
      have hDn_pos : (0 : ℝ) < D ^ n := pow_pos hD_pos n
      have hDn1_pos : (0 : ℝ) < D ^ (n + 1) := pow_pos hD_pos (n + 1)
      have hD_ne : (D : ℝ) ≠ 0 := ne_of_gt hD_pos
      have hDn_ne : (D : ℝ) ^ n ≠ 0 := ne_of_gt hDn_pos
      have hDn1_ne : (D : ℝ) ^ (n + 1) ≠ 0 := ne_of_gt hDn1_pos
      -- Key decomposition
      have decompose : h (n + 1) / (D : ℝ) ^ (n + 1) - h 0 =
          (h (n + 1) - D * h n) / (D : ℝ) ^ (n + 1) + (h n / (D : ℝ) ^ n - h 0) := by
        field_simp
        ring
      rw [decompose]
      -- Triangle inequality
      have tri := abs_add_le ((h (n + 1) - D * h n) / (D : ℝ) ^ (n + 1)) (h n / (D : ℝ) ^ n - h 0)
      -- Bound on first term
      have bound1 : |((h (n + 1) - D * h n) / (D : ℝ) ^ (n + 1))| ≤ C / (D : ℝ) ^ (n + 1) := by
        rw [abs_div]
        gcongr
        · exact hscale n
        · rw [abs_of_pos hDn1_pos]
      -- Now combine using a calculation
      calc |((h (n + 1) - D * h n) / (D : ℝ) ^ (n + 1)) + (h n / (D : ℝ) ^ n - h 0)|
          ≤ |((h (n + 1) - D * h n) / (D : ℝ) ^ (n + 1))| + |h n / (D : ℝ) ^ n - h 0| := tri
        _ ≤ C / (D : ℝ) ^ (n + 1) + C * (1 - 1 / (D : ℝ) ^ n) / ((D : ℝ) - 1) := by linarith
        _ = C * (1 - 1 / (D : ℝ) ^ (n + 1)) / ((D : ℝ) - 1) := by
            have hD_sub_ne : (D : ℝ) - 1 ≠ 0 := by linarith [show (2 : ℝ) ≤ D by exact_mod_cast hD]
            field_simp
            ring_nf
  intro n
  have := key n
  refine this.trans ?_
  have hD_pos : (0 : ℝ) < D := by linarith [show (2 : ℝ) ≤ D by exact_mod_cast hD]
  have hDn_pos : (0 : ℝ) < D ^ n := pow_pos hD_pos n
  have h_le_one : 1 - 1 / (D : ℝ) ^ n ≤ 1 := sub_le_self _ (by positivity)
  have hD_sub_pos : (0 : ℝ) ≤ D - 1 := by linarith [show (2 : ℝ) ≤ D by exact_mod_cast hD]
  gcongr
  · nlinarith

/-- Exact degree scaling gives an exactly constant normalized height sequence. -/
theorem normalized_height_exact
    (D : ℕ) (hD : 1 ≤ D) (h : ℕ → ℝ)
    (hscale : ∀ n, h (n + 1) = (D : ℝ) * h n) :
    ∀ n, h n / (D : ℝ) ^ n = h 0 := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
      have hD0 : (D : ℝ) ≠ 0 := by
        exact_mod_cast (Nat.ne_of_gt (lt_of_lt_of_le Nat.zero_lt_one hD))
      have hp : (D : ℝ) ^ n ≠ 0 := pow_ne_zero _ hD0
      have hn : h n = h 0 * (D : ℝ) ^ n := (div_eq_iff hp).mp ih
      rw [hscale, hn, pow_succ]
      field_simp

end HenonCanonicalHeight