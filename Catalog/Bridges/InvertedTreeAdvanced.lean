import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.InvertedTreeAdvanced

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 90
-/

/-- Forward Berggren transform B₁. -/
def fwdB₁ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Forward Berggren transform B₂. -/
def fwdB₂ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Forward Berggren transform B₃. -/
def fwdB₃ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The p-parameter: shared first component of B₁⁻¹ and B₂⁻¹. -/
def berggren_p (a b c : ℤ) : ℤ := a + 2*b - 2*c

/-- The q-parameter: shared second component of B₂⁻¹ and B₃⁻¹. -/
def berggren_q (a b c : ℤ) : ℤ := 2*a + b - 2*c

/-- The h-parameter: universal parent hypotenuse. -/
def berggren_h (a b c : ℤ) : ℤ := -2*a - 2*b + 3*c

/-- Inverse Berggren transform `B₁⁻¹`.  (Supplied here: the auto-generated file used
`invB₁`, `invB₂`, `invB₃` without carrying their definitions along; they are the
matrix inverses of `fwdB₁`, `fwdB₂`, `fwdB₃`.) -/
def invB₁ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

/-- Inverse Berggren transform `B₂⁻¹`. -/
def invB₂ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- Inverse Berggren transform `B₃⁻¹`. -/
def invB₃ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- **Component Sharing (1,2)**: B₁⁻¹ and B₂⁻¹ share the same first component. -/
theorem invB₁_fst_eq_invB₂_fst (a b c : ℤ) :
    (invB₁ a b c).1 = (invB₂ a b c).1 := by
  simp [invB₁, invB₂]

/-- **Component Sharing (2,3)**: B₂⁻¹ and B₃⁻¹ share the same second component. -/
theorem invB₂_snd_eq_invB₃_snd (a b c : ℤ) :
    (invB₂ a b c).2.1 = (invB₃ a b c).2.1 := by
  simp [invB₂, invB₃]

/-- **Universal Hypotenuse**: All three produce the same third component. -/
theorem all_hyp_eq₁₂ (a b c : ℤ) :
    (invB₁ a b c).2.2 = (invB₂ a b c).2.2 := by
  simp [invB₁, invB₂]

/-- [Section: # Inverted Berggren Tree — Advanced Theorems
New discoveries about the inverted Berggren tree structure.
## Main Results
1. **Ghost Triple Structure**: All three inverse images are (p, -q, h), (p, q, h), (-p, q, h)
— related by sign flips of two canonical parameters p and q.
2. **Branch Determination**: The valid parent branch is determined by signs of
p = a + 2b - 2c and q = 2a + b - 2c.
3. **Euclid Parameterization**: Branch determination in terms of Euclid (m,n) parameters.
4. **Parent Hypotenuse = Sum of Squares**: h = (m-2n)² + n² for Euclid triples.
5. **Ghost Pythagorean**: If (a,b,c) is Pythagorean, then (p,q,h) is also Pythagorean.
6. **Parity Conservation**: p ≡ a, q ≡ b, h ≡ c (mod 2).] -/
theorem all_hyp_eq₂₃ (a b c : ℤ) :
    (invB₂ a b c).2.2 = (invB₃ a b c).2.2 := by
  simp [invB₂, invB₃]

/-- **Ghost Structure**: B₁⁻¹ first component = p. -/
theorem invB₁_fst_eq_p (a b c : ℤ) :
    (invB₁ a b c).1 = berggren_p a b c := by
  simp [invB₁, berggren_p]

/-- B₁⁻¹ second component = -q. -/
theorem invB₁_snd_eq_neg_q (a b c : ℤ) :
    (invB₁ a b c).2.1 = -berggren_q a b c := by
  simp [invB₁, berggren_q]; ring

/-- B₂⁻¹ second component = q. -/
theorem invB₂_snd_eq_q (a b c : ℤ) :
    (invB₂ a b c).2.1 = berggren_q a b c := by
  simp [invB₂, berggren_q]

/-- B₃⁻¹ first component = -p. -/
theorem invB₃_fst_eq_neg_p (a b c : ℤ) :
    (invB₃ a b c).1 = -berggren_p a b c := by
  simp [invB₃, berggren_p]; ring

/-- All three share hypotenuse = h. -/
theorem inv_hyp_eq_h (a b c : ℤ) :
    (invB₁ a b c).2.2 = berggren_h a b c := by
  simp [invB₁, berggren_h]

/-- **Sign Opposition (1↔3)**: First components of B₁⁻¹ and B₃⁻¹ sum to zero. -/
theorem invB₁_fst_neg_invB₃_fst (a b c : ℤ) :
    (invB₁ a b c).1 = -(invB₃ a b c).1 := by
  simp [invB₁, invB₃]; ring

/-- **Sign Opposition (1↔2)**: Second components of B₁⁻¹ and B₂⁻¹ sum to zero. -/
theorem invB₁_snd_neg_invB₂_snd (a b c : ℤ) :
    (invB₁ a b c).2.1 = -(invB₂ a b c).2.1 := by
  simp [invB₁, invB₂]; ring

/-- **Sign Opposition (2↔3)**: First components of B₂⁻¹ and B₃⁻¹ sum to zero. -/
theorem invB₂_fst_neg_invB₃_fst (a b c : ℤ) :
    (invB₂ a b c).1 = -(invB₃ a b c).1 := by
  simp [invB₂, invB₃]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Branch Determination
-- ═══════════════════════════════════════════════════════════════

/-- B₁⁻¹ = (p, -q, h) is all-positive iff p > 0, q < 0, h > 0. -/
theorem branch1_positive_iff (a b c : ℤ) :
    (0 < (invB₁ a b c).1 ∧ 0 < (invB₁ a b c).2.1 ∧ 0 < (invB₁ a b c).2.2) ↔
    (0 < berggren_p a b c ∧ berggren_q a b c < 0 ∧ 0 < berggren_h a b c) := by
  rw [invB₁_fst_eq_p, invB₁_snd_eq_neg_q, inv_hyp_eq_h]
  constructor
  · intro ⟨ha, hb, hc⟩; exact ⟨ha, by linarith, hc⟩
  · intro ⟨ha, hb, hc⟩; exact ⟨ha, by linarith, hc⟩

/-- B₂⁻¹ = (p, q, h) is all-positive iff p > 0, q > 0, h > 0. -/
theorem branch2_positive_iff (a b c : ℤ) :
    (0 < (invB₂ a b c).1 ∧ 0 < (invB₂ a b c).2.1 ∧ 0 < (invB₂ a b c).2.2) ↔
    (0 < berggren_p a b c ∧ 0 < berggren_q a b c ∧ 0 < berggren_h a b c) := by
  simp only [invB₂, berggren_p, berggren_q, berggren_h]

/-- B₃⁻¹ = (-p, q, h) is all-positive iff p < 0, q > 0, h > 0. -/
theorem branch3_positive_iff (a b c : ℤ) :
    (0 < (invB₃ a b c).1 ∧ 0 < (invB₃ a b c).2.1 ∧ 0 < (invB₃ a b c).2.2) ↔
    (berggren_p a b c < 0 ∧ 0 < berggren_q a b c ∧ 0 < berggren_h a b c) := by
  simp only [invB₃, berggren_p, berggren_q, berggren_h]; constructor
  · intro ⟨ha, hb, hc⟩; exact ⟨by linarith, hb, hc⟩
  · intro ⟨ha, hb, hc⟩; exact ⟨by linarith, hb, hc⟩

theorem branch_exclusive_13 (a b c : ℤ)
    (h1 : 0 < (invB₁ a b c).1 ∧ 0 < (invB₁ a b c).2.1 ∧ 0 < (invB₁ a b c).2.2)
    (h3 : 0 < (invB₃ a b c).1 ∧ 0 < (invB₃ a b c).2.1 ∧ 0 < (invB₃ a b c).2.2) :
    False := by
  rw [branch1_positive_iff] at h1; rw [branch3_positive_iff] at h3; linarith [h1.1, h3.1]

theorem branch_exclusive_23 (a b c : ℤ)
    (h2 : 0 < (invB₂ a b c).1 ∧ 0 < (invB₂ a b c).2.1 ∧ 0 < (invB₂ a b c).2.2)
    (h3 : 0 < (invB₃ a b c).1 ∧ 0 < (invB₃ a b c).2.1 ∧ 0 < (invB₃ a b c).2.2) :
    False := by
  rw [branch2_positive_iff] at h2; rw [branch3_positive_iff] at h3; linarith [h2.1, h3.1]

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Round-Trip Identities
-- ═══════════════════════════════════════════════════════════════

theorem fwdB₁_comp_invB₁ (a b c : ℤ) :
    fwdB₁ (invB₁ a b c).1 (invB₁ a b c).2.1 (invB₁ a b c).2.2 = (a, b, c) := by
  simp [fwdB₁, invB₁, Prod.ext_iff]; constructor <;> [ring; constructor <;> ring]

theorem fwdB₂_comp_invB₂ (a b c : ℤ) :
    fwdB₂ (invB₂ a b c).1 (invB₂ a b c).2.1 (invB₂ a b c).2.2 = (a, b, c) := by
  simp [fwdB₂, invB₂, Prod.ext_iff]; constructor <;> [ring; constructor <;> ring]

theorem fwdB₃_comp_invB₃ (a b c : ℤ) :
    fwdB₃ (invB₃ a b c).1 (invB₃ a b c).2.1 (invB₃ a b c).2.2 = (a, b, c) := by
  simp [fwdB₃, invB₃, Prod.ext_iff]; constructor <;> [ring; constructor <;> ring]

theorem invB₁_comp_fwdB₁ (a b c : ℤ) :
    invB₁ (fwdB₁ a b c).1 (fwdB₁ a b c).2.1 (fwdB₁ a b c).2.2 = (a, b, c) := by
  simp [invB₁, fwdB₁, Prod.ext_iff]; constructor <;> [ring; constructor <;> ring]

theorem invB₂_comp_fwdB₂ (a b c : ℤ) :
    invB₂ (fwdB₂ a b c).1 (fwdB₂ a b c).2.1 (fwdB₂ a b c).2.2 = (a, b, c) := by
  simp [invB₂, fwdB₂, Prod.ext_iff]; constructor <;> [ring; constructor <;> ring]

theorem invB₃_comp_fwdB₃ (a b c : ℤ) :
    invB₃ (fwdB₃ a b c).1 (fwdB₃ a b c).2.1 (fwdB₃ a b c).2.2 = (a, b, c) := by
  simp [invB₃, fwdB₃, Prod.ext_iff]; constructor <;> [ring; constructor <;> ring]

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Concrete Descent Examples
-- ═══════════════════════════════════════════════════════════════

/-- (8, 15, 17) → (4, 3, 5) via B₁⁻¹. -/
theorem descent_8_15_17 : invB₁ 8 15 17 = (4, 3, 5) := by native_decide

/-- (20, 21, 29) → (4, 3, 5) via B₂⁻¹. -/
theorem descent_20_21_29 : invB₂ 20 21 29 = (4, 3, 5) := by native_decide

/-- Three-step descent: (9,40,41) → (7,24,25) → (5,12,13) → (3,4,5). -/
theorem three_step_descent :
    let t₁ := invB₁ 9 40 41
    let t₂ := invB₁ t₁.1 t₁.2.1 t₁.2.2
    let t₃ := invB₁ t₂.1 t₂.2.1 t₂.2.2
    t₃ = (3, 4, 5) := by native_decide

/-- The root (3,4,5) has degenerate parent (1, 0, 1) via B₂⁻¹. -/
theorem root_parent : invB₂ 3 4 5 = (1, 0, 1) := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Lorentz Form Preservation
-- ═══════════════════════════════════════════════════════════════

/-- The Lorentz form `a² + b² - c²` preserved by the Berggren transforms.  (Supplied
here: the auto-generated file used `lorentzQ` without carrying its definition along.) -/
def lorentzQ (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

theorem invB₁_preserves_Q (a b c : ℤ) :
    lorentzQ (invB₁ a b c).1 (invB₁ a b c).2.1 (invB₁ a b c).2.2 = lorentzQ a b c := by
  simp [lorentzQ, invB₁]; ring

theorem invB₂_preserves_Q (a b c : ℤ) :
    lorentzQ (invB₂ a b c).1 (invB₂ a b c).2.1 (invB₂ a b c).2.2 = lorentzQ a b c := by
  simp [lorentzQ, invB₂]; ring

theorem invB₃_preserves_Q (a b c : ℤ) :
    lorentzQ (invB₃ a b c).1 (invB₃ a b c).2.1 (invB₃ a b c).2.2 = lorentzQ a b c := by
  simp [lorentzQ, invB₃]; ring

theorem fwdB₁_preserves_Q (a b c : ℤ) :
    lorentzQ (fwdB₁ a b c).1 (fwdB₁ a b c).2.1 (fwdB₁ a b c).2.2 = lorentzQ a b c := by
  simp [lorentzQ, fwdB₁]; ring

theorem fwdB₂_preserves_Q (a b c : ℤ) :
    lorentzQ (fwdB₂ a b c).1 (fwdB₂ a b c).2.1 (fwdB₂ a b c).2.2 = lorentzQ a b c := by
  simp [lorentzQ, fwdB₂]; ring

theorem fwdB₃_preserves_Q (a b c : ℤ) :
    lorentzQ (fwdB₃ a b c).1 (fwdB₃ a b c).2.1 (fwdB₃ a b c).2.2 = lorentzQ a b c := by
  simp [lorentzQ, fwdB₃]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 7: The p-q-h Algebra
-- ═══════════════════════════════════════════════════════════════

/-- **Ghost Pythagorean Theorem**: If (a,b,c) is Pythagorean, then (p,q,h) is too. -/
theorem ghost_pythagorean (a b c : ℤ) (hpyth : a^2 + b^2 = c^2) :
    (berggren_p a b c)^2 + (berggren_q a b c)^2 = (berggren_h a b c)^2 := by
  simp [berggren_p, berggren_q, berggren_h]; nlinarith

/-- The descent decrease is 2(a + b - c). -/
theorem descent_decrease (a b c : ℤ) :
    c - berggren_h a b c = 2 * (a + b - c) := by
  simp [berggren_h]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Descent Bounds
-- ═══════════════════════════════════════════════════════════════

/-- **Triangle inequality for integer Pythagorean triples**: if `a, b > 0` and
`a² + b² = c²` then `c < a + b`.  (For `c ≤ 0` this is immediate; for `c > 0` it
follows from `(a+b)² = c² + 2ab > c²`.) -/
theorem ppt_triangle_ineq (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) : c < a + b := by
  rcases le_or_lt c 0 with hc | hc
  · linarith
  · nlinarith

/-- Hypotenuse strictly decreases during descent. -/
theorem hyp_decreases (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) : berggren_h a b c < c := by
  have hab := ppt_triangle_ineq a b c ha hb hpyth
  have := descent_decrease a b c; linarith

/-- Descent gap is at least 2. -/
theorem descent_gap_ge_2 (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) : 2 ≤ c - berggren_h a b c := by
  have := ppt_triangle_ineq a b c ha hb hpyth
  have := descent_decrease a b c; linarith

/-- Depth upper bound: h ≤ c - 2. -/
theorem hyp_decrease_by_at_least_2 (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a^2 + b^2 = c^2) :
    berggren_h a b c ≤ c - 2 := by
  linarith [descent_gap_ge_2 a b c ha hb hpyth]

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Root Detection
-- ═══════════════════════════════════════════════════════════════

/-- At the root (3,4,5): p = 1. -/
theorem root_p : berggren_p 3 4 5 = 1 := by simp [berggren_p]

/-- At the root (3,4,5): q = 0 (signals the root). -/
theorem root_q : berggren_q 3 4 5 = 0 := by simp [berggren_q]

/-- At the root (3,4,5): h = 1. -/
theorem root_h : berggren_h 3 4 5 = 1 := by simp [berggren_h]

/-- The swapped root (4,3,5) has p = 0 (the complementary signal). -/
theorem swapped_root_p : berggren_p 4 3 5 = 0 := by simp [berggren_p]

/-- The swapped root (4,3,5) has q = 1. -/
theorem swapped_root_q : berggren_q 4 3 5 = 1 := by simp [berggren_q]

/-- Descent gap at the root is exactly 4. -/
theorem root_descent_gap : 5 - berggren_h 3 4 5 = 4 := by simp [berggren_h]

-- ═══════════════════════════════════════════════════════════════
-- Section 10: Leg Swap Symmetry
-- ═══════════════════════════════════════════════════════════════

/-- Swapping legs a↔b relates B₁⁻¹ to B₃⁻¹ via a leg swap. -/
theorem leg_swap_B₁_B₃ (a b c : ℤ) :
    invB₃ b a c = ((invB₁ a b c).2.1, (invB₁ a b c).1, (invB₁ a b c).2.2) := by
  simp [invB₃, invB₁, Prod.ext_iff]; constructor <;> [ring; constructor <;> ring]

/-- B₂⁻¹ commutes with leg swap (swapping inputs swaps outputs). -/
theorem leg_swap_B₂ (a b c : ℤ) :
    invB₂ b a c = ((invB₂ a b c).2.1, (invB₂ a b c).1, (invB₂ a b c).2.2) := by
  simp [invB₂, Prod.ext_iff]; constructor <;> [ring; constructor <;> ring]

-- ═══════════════════════════════════════════════════════════════
-- Section 11: Euclid Parameterization
-- ═══════════════════════════════════════════════════════════════

/-- p for Euclid triples factors as -(m-n)(m-3n). -/
theorem euclid_p (m n : ℤ) :
    berggren_p (m^2 - n^2) (2*m*n) (m^2 + n^2) = -(m - n) * (m - 3*n) := by
  simp [berggren_p]; ring

/-- q for Euclid triples factors as 2n(m-2n). -/
theorem euclid_q (m n : ℤ) :
    berggren_q (m^2 - n^2) (2*m*n) (m^2 + n^2) = 2 * n * (m - 2*n) := by
  simp [berggren_q]; ring

/-- **Parent hypotenuse is a sum of squares**: h = (m-2n)² + n². -/
theorem euclid_h_sum_of_squares (m n : ℤ) :
    berggren_h (m^2 - n^2) (2*m*n) (m^2 + n^2) = (m - 2*n)^2 + n^2 := by
  simp [berggren_h]; ring

/-- The parent hypotenuse of any Euclid triple is itself a sum of two squares. -/
theorem parent_hyp_is_sum_of_squares (m n : ℤ) :
    ∃ u v : ℤ, berggren_h (m^2 - n^2) (2*m*n) (m^2 + n^2) = u^2 + v^2 :=
  ⟨m - 2*n, n, euclid_h_sum_of_squares m n⟩

/-- Branch 1 in Euclid parameters: n < m < 2n gives p > 0, q < 0. -/
theorem euclid_branch1 (m n : ℤ) (hn : 0 < n) (hm1 : n < m) (hm2 : m < 2*n) :
    0 < berggren_p (m^2-n^2) (2*m*n) (m^2+n^2) ∧
    berggren_q (m^2-n^2) (2*m*n) (m^2+n^2) < 0 := by
  rw [euclid_p, euclid_q]; constructor <;> nlinarith

/-- Branch 2 in Euclid parameters: 2n < m < 3n gives p > 0, q > 0. -/
theorem euclid_branch2 (m n : ℤ) (hn : 0 < n) (hm1 : 2*n < m) (hm2 : m < 3*n) :
    0 < berggren_p (m^2-n^2) (2*m*n) (m^2+n^2) ∧
    0 < berggren_q (m^2-n^2) (2*m*n) (m^2+n^2) := by
  rw [euclid_p, euclid_q]; constructor <;> nlinarith

/-- Branch 3 in Euclid parameters: m > 3n gives p < 0, q > 0. -/
theorem euclid_branch3 (m n : ℤ) (hn : 0 < n) (hm : 3*n < m) :
    berggren_p (m^2-n^2) (2*m*n) (m^2+n^2) < 0 ∧
    0 < berggren_q (m^2-n^2) (2*m*n) (m^2+n^2) := by
  rw [euclid_p, euclid_q]; constructor <;> nlinarith

/-- Factored form of B₁⁻¹ applied to a Euclid triple. -/
theorem invB₁_euclid (m n : ℤ) :
    invB₁ (m^2-n^2) (2*m*n) (m^2+n^2) =
    (-(m-n)*(m-3*n), -2*n*(m-2*n), (m-2*n)^2+n^2) := by
  simp [invB₁, Prod.ext_iff]; constructor <;> [ring; constructor <;> ring]

/-- Factored form of B₂⁻¹ applied to a Euclid triple. -/
theorem invB₂_euclid (m n : ℤ) :
    invB₂ (m^2-n^2) (2*m*n) (m^2+n^2) =
    (-(m-n)*(m-3*n), 2*n*(m-2*n), (m-2*n)^2+n^2) := by
  simp [invB₂, Prod.ext_iff]; constructor <;> [ring; constructor <;> ring]

/-- Factored form of B₃⁻¹ applied to a Euclid triple. -/
theorem invB₃_euclid (m n : ℤ) :
    invB₃ (m^2-n^2) (2*m*n) (m^2+n^2) =
    ((m-n)*(m-3*n), 2*n*(m-2*n), (m-2*n)^2+n^2) := by
  simp [invB₃, Prod.ext_iff]; constructor <;> [ring; constructor <;> ring]

-- ═══════════════════════════════════════════════════════════════
-- Section 12: Parity Conservation
-- ═══════════════════════════════════════════════════════════════

/-- p has the same parity as a. -/
theorem p_parity (a b c : ℤ) : berggren_p a b c % 2 = a % 2 := by
  unfold berggren_p; omega

/-- q has the same parity as b. -/
theorem q_parity (a b c : ℤ) : berggren_q a b c % 2 = b % 2 := by
  unfold berggren_q; omega

/-- h has the same parity as c. -/
theorem h_parity (a b c : ℤ) : berggren_h a b c % 2 = c % 2 := by
  unfold berggren_h; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 13: Matrix Properties
-- ═══════════════════════════════════════════════════════════════

def mB₁_inv : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, -2; -2, -1, 2; -2, -2, 3]

def mB₂_inv : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, -2; 2, 1, -2; -2, -2, 3]

def mB₃_inv : Matrix (Fin 3) (Fin 3) ℤ := !![-1, -2, 2; 2, 1, -2; -2, -2, 3]

def mB₁_fwd : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

def mB₂_fwd : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

def mB₃_fwd : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

def mQ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- The inverse matrices do NOT commute pairwise. -/
theorem inv_noncommutative_12 : mB₁_inv * mB₂_inv ≠ mB₂_inv * mB₁_inv := by native_decide

theorem inv_noncommutative_13 : mB₁_inv * mB₃_inv ≠ mB₃_inv * mB₁_inv := by native_decide

theorem inv_noncommutative_23 : mB₂_inv * mB₃_inv ≠ mB₃_inv * mB₂_inv := by native_decide

/-- Traces of squared inverse matrices. -/
theorem B₁_inv_sq_trace : Matrix.trace (mB₁_inv * mB₁_inv) = 3 := by native_decide

theorem B₂_inv_sq_trace : Matrix.trace (mB₂_inv * mB₂_inv) = 35 := by native_decide

theorem B₃_inv_sq_trace : Matrix.trace (mB₃_inv * mB₃_inv) = 3 := by native_decide

/-- The isobaric matrix B₁ · B₂⁻¹ has trace 1. -/
theorem isobaric_trace : Matrix.trace (mB₁_fwd * mB₂_inv) = 1 := by native_decide

/-- The isobaric matrix B₁ · B₂⁻¹ has determinant -1. -/
theorem isobaric_det : Matrix.det (mB₁_fwd * mB₂_inv) = -1 := by native_decide

/-- The isobaric matrix preserves the Lorentz form. -/
theorem isobaric_lorentz :
    (mB₁_fwd * mB₂_inv).transpose * mQ * (mB₁_fwd * mB₂_inv) = mQ := by native_decide

/-- Forward Lorentz preservation (matrix form). -/
theorem B₁_fwd_lorentz : mB₁_fwd.transpose * mQ * mB₁_fwd = mQ := by native_decide

theorem B₂_fwd_lorentz : mB₂_fwd.transpose * mQ * mB₂_fwd = mQ := by native_decide

theorem B₃_fwd_lorentz : mB₃_fwd.transpose * mQ * mB₃_fwd = mQ := by native_decide

/-- Inverse Lorentz preservation (matrix form). -/
theorem B₁_inv_lorentz : mB₁_inv.transpose * mQ * mB₁_inv = mQ := by native_decide

theorem B₂_inv_lorentz : mB₂_inv.transpose * mQ * mB₂_inv = mQ := by native_decide

theorem B₃_inv_lorentz : mB₃_inv.transpose * mQ * mB₃_inv = mQ := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 14: Verification Examples
-- ═══════════════════════════════════════════════════════════════

theorem ppt_3_4_5 : (3 : ℤ)^2 + 4^2 = 5^2 := by norm_num

theorem ppt_8_15_17 : (8 : ℤ)^2 + 15^2 = 17^2 := by norm_num

theorem ppt_20_21_29 : (20 : ℤ)^2 + 21^2 = 29^2 := by norm_num

#print axioms ghost_pythagorean
#print axioms euclid_branch1
#print axioms parent_hyp_is_sum_of_squares
-- (`#print axioms` for `branch_exclusive_12` and `pq_diff` removed: no such
-- declarations exist in this development.)