/-! # CatalogBuild.Pythagorean.Berggren.ErrorCorrection

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 24
-/

import Mathlib

def h (a b c : ℤ) : ℤ := -2*a - 2*b + 3*c

-- ═══════════════════════════════════════════════════════════════
-- Section 1: Recovery Equations
-- ═══════════════════════════════════════════════════════════════


theorem recover_a (a b c : ℤ) :
    a = (p a b c) + 2 * (q a b c) + 2 * (h a b c) := by
  simp only [p, q, h]; ring


theorem recover_b (a b c : ℤ) :
    b = 2 * (p a b c) + (q a b c) + 2 * (h a b c) := by
  simp only [p, q, h]; ring


theorem recover_c (a b c : ℤ) :
    c = 2 * (p a b c) + 2 * (q a b c) + 3 * (h a b c) := by
  simp only [p, q, h]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Error Detection — All Six Components
-- The six-tuple (a, b, c, p, q, h) is stored. If any one is perturbed,
-- the recovery equations detect the error.
-- ═══════════════════════════════════════════════════════════════

-- If a is perturbed while p,q,h remain correct:
-- (a+ε) ≠ p + 2q + 2h = a

theorem detect_error_a (a b c ε : ℤ) (hε : ε ≠ 0) :
    a + ε ≠ p a b c + 2 * q a b c + 2 * h a b c := by
  rw [← recover_a a b c]; omega

-- If b is perturbed while p,q,h remain correct:

theorem detect_error_b (a b c ε : ℤ) (hε : ε ≠ 0) :
    b + ε ≠ 2 * p a b c + q a b c + 2 * h a b c := by
  rw [← recover_b a b c]; omega

-- If c is perturbed while p,q,h remain correct:

theorem detect_error_c (a b c ε : ℤ) (hε : ε ≠ 0) :
    c + ε ≠ 2 * p a b c + 2 * q a b c + 3 * h a b c := by
  rw [← recover_c a b c]; omega

-- If p is perturbed while a,b,c remain correct:
-- a ≠ (p+ε) + 2q + 2h

theorem detect_error_p (a b c ε : ℤ) (hε : ε ≠ 0) :
    a ≠ (p a b c + ε) + 2 * q a b c + 2 * h a b c := by
  simp only [p, q, h]; omega

-- If q is perturbed while a,b,c remain correct:

theorem detect_error_q (a b c ε : ℤ) (hε : ε ≠ 0) :
    a ≠ p a b c + 2 * (q a b c + ε) + 2 * h a b c := by
  simp only [p, q, h]; omega

-- If h is perturbed while a,b,c remain correct:

theorem detect_error_h (a b c ε : ℤ) (hε : ε ≠ 0) :
    a ≠ p a b c + 2 * q a b c + 2 * (h a b c + ε) := by
  simp only [p, q, h]; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Ghost Pythagorean Preservation
-- ═══════════════════════════════════════════════════════════════


theorem ghost_pyth_preserved (a b c : ℤ) (hp : a^2 + b^2 = c^2) :
    (p a b c)^2 + (q a b c)^2 = (h a b c)^2 := by
  simp only [p, q, h]; nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Syndrome Calculation
-- The syndrome is the vector of discrepancies in the recovery equations.
-- For a valid six-tuple, all syndromes are zero.
-- ═══════════════════════════════════════════════════════════════


theorem syndrome_zero_1 (a b c : ℤ) :
    a - (p a b c + 2 * q a b c + 2 * h a b c) = 0 := by
  simp only [p, q, h]; ring


theorem syndrome_zero_2 (a b c : ℤ) :
    b - (2 * p a b c + q a b c + 2 * h a b c) = 0 := by
  simp only [p, q, h]; ring


theorem syndrome_zero_3 (a b c : ℤ) :
    c - (2 * p a b c + 2 * q a b c + 3 * h a b c) = 0 := by
  simp only [p, q, h]; ring

-- When a is perturbed by ε (stored value becomes a+ε):
-- Syndrome s₁ = (a+ε) − (p+2q+2h) = ε

theorem syndrome_perturb_a (a b c ε : ℤ) :
    (a + ε) - (p a b c + 2 * q a b c + 2 * h a b c) = ε := by
  have := syndrome_zero_1 a b c; omega

-- When p is perturbed by ε (stored value becomes p+ε):
-- Syndrome s₁ = a − ((p+ε)+2q+2h) = −ε

theorem syndrome_perturb_p (a b c ε : ℤ) :
    a - ((p a b c + ε) + 2 * q a b c + 2 * h a b c) = -ε := by
  have := syndrome_zero_1 a b c; omega

-- When q is perturbed by ε:
-- Syndrome s₁ = a − (p+2(q+ε)+2h) = −2ε

theorem syndrome_perturb_q (a b c ε : ℤ) :
    a - (p a b c + 2 * (q a b c + ε) + 2 * h a b c) = -2 * ε := by
  have := syndrome_zero_1 a b c; omega

-- When h is perturbed by ε:
-- Syndrome s₁ = a − (p+2q+2(h+ε)) = −2ε

theorem syndrome_perturb_h (a b c ε : ℤ) :
    a - (p a b c + 2 * q a b c + 2 * (h a b c + ε)) = -2 * ε := by
  have := syndrome_zero_1 a b c; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Error Correction Feasibility
-- Different error locations produce different syndrome patterns,
-- enabling error localization (not just detection).
-- ═══════════════════════════════════════════════════════════════

-- Three syndrome equations, each checking one recovery equation:
-- s₁ = a − (p+2q+2h), s₂ = b − (2p+q+2h), s₃ = c − (2p+2q+3h)

-- Syndrome patterns for each error location:
-- error in a: (ε, 0, 0) — only s₁ is nonzero
-- error in b: (0, ε, 0) — only s₂ is nonzero
-- error in c: (0, 0, ε) — only s₃ is nonzero
-- error in p: (−ε, −2ε, −2ε)
-- error in q: (−2ε, −ε, −2ε)
-- error in h: (−2ε, −2ε, −3ε)

-- These are all distinct directions (over ℤ), so errors are localizable.
-- We verify a subset:

-- Error in a: s₂ = 0 (b check unchanged)

theorem syndrome_a_s2 (a b c ε : ℤ) :
    (b) - (2 * p a b c + q a b c + 2 * h a b c) = 0 := by
  simp only [p, q, h]; ring

-- Error in p: s₂ = −2ε

theorem syndrome_p_s2 (a b c ε : ℤ) :
    b - (2 * (p a b c + ε) + q a b c + 2 * h a b c) = -2 * ε := by
  have := syndrome_zero_2 a b c; omega

-- Error in q: s₂ = −ε

theorem syndrome_q_s2 (a b c ε : ℤ) :
    b - (2 * p a b c + (q a b c + ε) + 2 * h a b c) = -ε := by
  have := syndrome_zero_2 a b c; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Concrete Examples
-- ═══════════════════════════════════════════════════════════════


theorem six_tuple_345 :
    p 3 4 5 = 1 ∧ q 3 4 5 = 0 ∧ h 3 4 5 = 1 := by
  simp only [p, q, h]; omega


theorem recover_345 :
    1 + 2 * 0 + 2 * 1 = (3 : ℤ) ∧
    2 * 1 + 0 + 2 * 1 = (4 : ℤ) ∧
    2 * 1 + 2 * 0 + 3 * 1 = (5 : ℤ) := by omega


theorem six_tuple_51213 :
    p 5 12 13 = 3 ∧ q 5 12 13 = -4 ∧ h 5 12 13 = 5 := by
  simp only [p, q, h]; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Axiom Verification
-- ═══════════════════════════════════════════════════════════════

#print axioms detect_error_a
#print axioms detect_error_b
#print axioms detect_error_c
#print axioms detect_error_p
#print axioms detect_error_q
#print axioms detect_error_h
#print axioms ghost_pyth_preserved
#print axioms syndrome_perturb_a
#print axioms syndrome_perturb_p
#print axioms syndrome_perturb_q
#print axioms syndrome_p_s2

