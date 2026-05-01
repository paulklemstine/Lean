import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.KleinFourAction

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 34
-/

/-- Element σ₀ (identity): (+p, +q, h) = B₂⁻¹. -/
def ghost_id (a b c : ℤ) : ℤ × ℤ × ℤ := (gp a b c, gq a b c, gh a b c)

/-- Element σ₁: (+p, -q, h) = B₁⁻¹. -/
def ghost_s1 (a b c : ℤ) : ℤ × ℤ × ℤ := (gp a b c, -(gq a b c), gh a b c)

/-- Element σ₂: (-p, +q, h) = B₃⁻¹. -/
def ghost_s2 (a b c : ℤ) : ℤ × ℤ × ℤ := (-(gp a b c), gq a b c, gh a b c)

/-- Element σ₁σ₂: (-p, -q, h) = the "fourth ghost". -/
def ghost_s12 (a b c : ℤ) : ℤ × ℤ × ℤ := (-(gp a b c), -(gq a b c), gh a b c)

-- ═══════════════════════════════════════════════════════════════
-- Section 3: All Four Ghosts are Pythagorean
-- ═══════════════════════════════════════════════════════════════

theorem ghost_id_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (ghost_id a b c).1^2 + (ghost_id a b c).2.1^2 = (ghost_id a b c).2.2^2 := by
  simp [ghost_id]; exact ghost_pyth a b c h

theorem ghost_s1_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (ghost_s1 a b c).1^2 + (ghost_s1 a b c).2.1^2 = (ghost_s1 a b c).2.2^2 := by
  simp [ghost_s1]; nlinarith [ghost_pyth a b c h]

theorem ghost_s2_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (ghost_s2 a b c).1^2 + (ghost_s2 a b c).2.1^2 = (ghost_s2 a b c).2.2^2 := by
  simp [ghost_s2]; nlinarith [ghost_pyth a b c h]

/-- The FOURTH GHOST (-p, -q, h) is also Pythagorean. -/
theorem ghost_s12_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (ghost_s12 a b c).1^2 + (ghost_s12 a b c).2.1^2 = (ghost_s12 a b c).2.2^2 := by
  simp [ghost_s12]; nlinarith [ghost_pyth a b c h]

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Klein Four Group Structure
-- ═══════════════════════════════════════════════════════════════

/-- All four ghosts share the same hypotenuse. -/
theorem ghosts_same_hyp (a b c : ℤ) :
    (ghost_id a b c).2.2 = (ghost_s1 a b c).2.2 ∧
    (ghost_s1 a b c).2.2 = (ghost_s2 a b c).2.2 ∧
    (ghost_s2 a b c).2.2 = (ghost_s12 a b c).2.2 := by
  simp [ghost_id, ghost_s1, ghost_s2, ghost_s12]

/-- σ₁ negates q: second components of σ₀ and σ₁ are opposite. -/
theorem s1_negates_q (a b c : ℤ) :
    (ghost_s1 a b c).2.1 = -(ghost_id a b c).2.1 := by
  simp [ghost_s1, ghost_id]

/-- σ₂ negates p: first components of σ₀ and σ₂ are opposite. -/
theorem s2_negates_p (a b c : ℤ) :
    (ghost_s2 a b c).1 = -(ghost_id a b c).1 := by
  simp [ghost_s2, ghost_id]

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Orbit Distinctness
-- ═══════════════════════════════════════════════════════════════

theorem orbit_distinct_01 (a b c : ℤ) (hq : gq a b c ≠ 0) :
    ghost_id a b c ≠ ghost_s1 a b c := by
  simp [ghost_id, ghost_s1, Prod.ext_iff]; intro _; omega

theorem orbit_distinct_02 (a b c : ℤ) (hp : gp a b c ≠ 0) :
    ghost_id a b c ≠ ghost_s2 a b c := by
  unfold ghost_id ghost_s2
  simp only [Prod.mk.injEq, ne_eq, not_and]; intro h; exfalso; exact hp (by omega)

theorem orbit_distinct_03 (a b c : ℤ) (hp : gp a b c ≠ 0) :
    ghost_id a b c ≠ ghost_s12 a b c := by
  unfold ghost_id ghost_s12
  simp only [Prod.mk.injEq, ne_eq, not_and]; intro h; exfalso; exact hp (by omega)

theorem orbit_distinct_12 (a b c : ℤ) (hp : gp a b c ≠ 0) :
    ghost_s1 a b c ≠ ghost_s2 a b c := by
  unfold ghost_s1 ghost_s2
  simp only [Prod.mk.injEq, ne_eq, not_and]; intro h; exfalso; exact hp (by omega)

theorem orbit_distinct_13 (a b c : ℤ) (hp : gp a b c ≠ 0) :
    ghost_s1 a b c ≠ ghost_s12 a b c := by
  unfold ghost_s1 ghost_s12
  simp only [Prod.mk.injEq, ne_eq, not_and]; intro h; exfalso; exact hp (by omega)

theorem orbit_distinct_23 (a b c : ℤ) (hq : gq a b c ≠ 0) :
    ghost_s2 a b c ≠ ghost_s12 a b c := by
  unfold ghost_s2 ghost_s12
  simp only [Prod.mk.injEq, ne_eq, not_and]; intro _ h; exfalso; exact hq (by omega)

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Descent Rate
-- ═══════════════════════════════════════════════════════════════

theorem pyth_triangle (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a^2 + b^2 = c^2) : a + b > c := by
  nlinarith [sq_nonneg (a - b), sq_abs (a + b)]

theorem parent_lt_child (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a^2 + b^2 = c^2) : gh a b c < c := by
  have hab := pyth_triangle a b c ha hb hpyth; simp [gh]; linarith

theorem parent_pos (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a^2 + b^2 = c^2) (hc : 5 ≤ c) : 0 < gh a b c := by
  simp [gh]; nlinarith [sq_nonneg (a - b)]

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Root Detection and Fixed Point
-- ═══════════════════════════════════════════════════════════════

theorem root_ghost_params : (gp 3 4 5, gq 3 4 5, gh 3 4 5) = (1, 0, 1) := by
  simp [gp, gq, gh]

theorem root_ghost_pyth : (1 : ℤ)^2 + 0^2 = 1^2 := by norm_num

theorem swapped_root_ghost : (gp 4 3 5, gq 4 3 5, gh 4 3 5) = (0, 1, 1) := by
  simp [gp, gq, gh]

-- The iterated descent terminates at (3,4,5), whose ghost params are (1,0,1).
-- Since 1² + 0² = 1², this is the "fixed point" of the ghost map.

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Continued Fraction Connection
-- ═══════════════════════════════════════════════════════════════

-- The Berggren branch is determined by the ratio m/n of Euclid parameters.

theorem cf_branch1 (m n : ℤ) (hn : 0 < n) (hm1 : n < m) (hm2 : m < 2*n) :
    0 < gp (m^2 - n^2) (2*m*n) (m^2 + n^2) ∧
    gq (m^2 - n^2) (2*m*n) (m^2 + n^2) < 0 := by
  simp [gp, gq]; constructor <;> nlinarith

theorem cf_branch2 (m n : ℤ) (hn : 0 < n) (hm1 : 2*n < m) (hm2 : m < 3*n) :
    0 < gp (m^2 - n^2) (2*m*n) (m^2 + n^2) ∧
    0 < gq (m^2 - n^2) (2*m*n) (m^2 + n^2) := by
  simp [gp, gq]; constructor <;> nlinarith

theorem cf_branch3 (m n : ℤ) (hn : 0 < n) (hm : 3*n < m) :
    gp (m^2 - n^2) (2*m*n) (m^2 + n^2) < 0 ∧
    0 < gq (m^2 - n^2) (2*m*n) (m^2 + n^2) := by
  simp [gp, gq]; constructor <;> nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Parent Hypotenuse as Sum of Squares
-- ═══════════════════════════════════════════════════════════════

theorem parent_hyp_binary_form (m n : ℤ) :
    gh (m^2 - n^2) (2*m*n) (m^2 + n^2) = (m - 2*n)^2 + n^2 := by
  simp [gh]; ring

theorem parent_hyp_witnesses (m n : ℤ) :
    ∃ u v : ℤ, gh (m^2 - n^2) (2*m*n) (m^2 + n^2) = u^2 + v^2 :=
  ⟨m - 2*n, n, parent_hyp_binary_form m n⟩

-- ═══════════════════════════════════════════════════════════════
-- Section 10: Parity Cascade
-- ═══════════════════════════════════════════════════════════════

theorem odd_preserved (a b c : ℤ) (ha : a % 2 = 1) : gp a b c % 2 = 1 := by
  rw [p_parity]; exact ha

theorem even_preserved (a b c : ℤ) (hb : b % 2 = 0) : gq a b c % 2 = 0 := by
  rw [q_parity]; exact hb

-- ═══════════════════════════════════════════════════════════════
-- Section 11: Syndrome Error Detection
-- ═══════════════════════════════════════════════════════════════

/-- For Pythagorean triples, the syndrome vanishes. -/
theorem syndrome_zero (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    syndrome a b c = 0 := by
  rw [syndrome_eq_Q]; omega

/-- A nonzero syndrome detects corruption. -/
theorem syndrome_detects (a b c : ℤ) (h : a^2 + b^2 ≠ c^2) :
    syndrome a b c ≠ 0 := by
  rw [syndrome_eq_Q]; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 12: Concrete Orbit Examples
-- ═══════════════════════════════════════════════════════════════

-- For (5,12,13): p = 3, q = -4, h = 5
-- ghost_id (B₂⁻¹) = (3, -4, 5), ghost_s1 (B₁⁻¹) = (3, 4, 5)
-- ghost_s2 (B₃⁻¹) = (-3, -4, 5), ghost_s12 ("fourth") = (-3, 4, 5)

theorem ghosts_5_12_13 :
    ghost_id 5 12 13 = (3, -4, 5) ∧
    ghost_s1 5 12 13 = (3, 4, 5) ∧
    ghost_s2 5 12 13 = (-3, -4, 5) ∧
    ghost_s12 5 12 13 = (-3, 4, 5) := by
  simp only [ghost_id, ghost_s1, ghost_s2, ghost_s12, gp, gq, gh]; norm_num

-- For (20,21,29): p = 4, q = 3, h = 5

theorem ghosts_20_21_29 :
    ghost_id 20 21 29 = (4, 3, 5) ∧
    ghost_s1 20 21 29 = (4, -3, 5) ∧
    ghost_s2 20 21 29 = (-4, 3, 5) ∧
    ghost_s12 20 21 29 = (-4, -3, 5) := by
  simp only [ghost_id, ghost_s1, ghost_s2, ghost_s12, gp, gq, gh]; norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 13: Axiom Check
-- ═══════════════════════════════════════════════════════════════

#print axioms ghost_pyth
#print axioms ghost_s12_pyth
#print axioms syndrome_eq_Q
#print axioms syndrome_detects
#print axioms cf_branch1
#print axioms parent_hyp_binary_form