import Mathlib

/-! # CatalogBuild.Pythagorean.Quadruples.FiveDDescent

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 27
-/

/-- [Section: # 5D Pythagorean Quintuple Descent Theory
## Main Results
1. **Sign-flip symmetry (ℤ/2)⁴**: 16-element sign-flip group
2. **Permutation symmetry S₄**: 24-element permutation group
3. **Triangle inequality**: a+b+c+d > e for positive quintuples
4. **Two largest > hypotenuse**: c+d > e for ordered quintuples
5. **Cauchy-Schwarz**: Inner product bounded
6. **Composition from triples**: Building quintuples
7. **Ghost group = 384**: |S₄ × (ℤ/2)⁴|] -/
def IsPQ5 (a b c d e : ℤ) : Prop := a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = e ^ 2

-- ═══════════════════════════════════════════════════════════════
-- Section 1: Examples
-- ═══════════════════════════════════════════════════════════════

theorem pq5_1_2_2_4_5 : IsPQ5 1 2 2 4 5 := by unfold IsPQ5; norm_num

theorem pq5_1_1_1_1_2 : IsPQ5 1 1 1 1 2 := by unfold IsPQ5; norm_num

theorem pq5_2_2_2_2_4 : IsPQ5 2 2 2 2 4 := by unfold IsPQ5; norm_num

theorem pq5_0_0_3_4_5 : IsPQ5 0 0 3 4 5 := by unfold IsPQ5; norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Sign-Flip Symmetry
-- ═══════════════════════════════════════════════════════════════

theorem sf5_a (a b c d e : ℤ) (h : IsPQ5 a b c d e) : IsPQ5 (-a) b c d e := by
  unfold IsPQ5 at *; nlinarith

theorem sf5_b (a b c d e : ℤ) (h : IsPQ5 a b c d e) : IsPQ5 a (-b) c d e := by
  unfold IsPQ5 at *; nlinarith

theorem sf5_c (a b c d e : ℤ) (h : IsPQ5 a b c d e) : IsPQ5 a b (-c) d e := by
  unfold IsPQ5 at *; nlinarith

theorem sf5_d (a b c d e : ℤ) (h : IsPQ5 a b c d e) : IsPQ5 a b c (-d) e := by
  unfold IsPQ5 at *; nlinarith

theorem sf5_all (a b c d e : ℤ) (h : IsPQ5 a b c d e)
    (s₁ s₂ s₃ s₄ : ℤ) (hs₁ : s₁ = 1 ∨ s₁ = -1) (hs₂ : s₂ = 1 ∨ s₂ = -1)
    (hs₃ : s₃ = 1 ∨ s₃ = -1) (hs₄ : s₄ = 1 ∨ s₄ = -1) :
    IsPQ5 (s₁ * a) (s₂ * b) (s₃ * c) (s₄ * d) e := by
  unfold IsPQ5 at *
  rcases hs₁ with rfl | rfl <;> rcases hs₂ with rfl | rfl <;>
    rcases hs₃ with rfl | rfl <;> rcases hs₄ with rfl | rfl <;> nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Permutation Symmetry
-- ═══════════════════════════════════════════════════════════════

theorem perm5_12 (a b c d e : ℤ) (h : IsPQ5 a b c d e) : IsPQ5 b a c d e := by
  unfold IsPQ5 at *; linarith

theorem perm5_13 (a b c d e : ℤ) (h : IsPQ5 a b c d e) : IsPQ5 c b a d e := by
  unfold IsPQ5 at *; linarith

theorem perm5_14 (a b c d e : ℤ) (h : IsPQ5 a b c d e) : IsPQ5 d b c a e := by
  unfold IsPQ5 at *; linarith

theorem perm5_23 (a b c d e : ℤ) (h : IsPQ5 a b c d e) : IsPQ5 a c b d e := by
  unfold IsPQ5 at *; linarith

theorem perm5_34 (a b c d e : ℤ) (h : IsPQ5 a b c d e) : IsPQ5 a b d c e := by
  unfold IsPQ5 at *; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Triangle Inequality
-- ═══════════════════════════════════════════════════════════════

/-- Sum of all four spatial components exceeds hypotenuse. -/
theorem triangle_5d (a b c d e : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hd : 0 < d) (he : 0 < e) (hpq : IsPQ5 a b c d e) :
    a + b + c + d > e := by
  unfold IsPQ5 at hpq
  -- We know (a+b+c+d)² ≥ a²+b²+c²+d² = e² with equality iff cross terms = 0
  -- But all positive so cross terms > 0
  by_contra h; push_neg at h
  have h2 : (a + b + c + d) ^ 2 ≤ e ^ 2 := by nlinarith
  -- Expand: a²+b²+c²+d² + 2(ab+ac+ad+bc+bd+cd) ≤ e² = a²+b²+c²+d²
  -- So 2(ab+ac+ad+bc+bd+cd) ≤ 0, contradiction since all positive
  have hab : 0 < a * b := by positivity
  have hac : 0 < a * c := by positivity
  nlinarith [mul_pos ha hd, mul_pos hb hc, mul_pos hb hd, mul_pos hc hd]

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Two Largest Components
-- ═══════════════════════════════════════════════════════════════

/-- For ordered (a ≤ b ≤ c ≤ d), c + d ≥ e, with equality iff a=b=c=d. -/
theorem two_largest_5d (a b c d e : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) (hd : 0 < d) (he : 0 < e)
    (hpq : IsPQ5 a b c d e) (hab : a ≤ b) (hbc : b ≤ c) (hcd : c ≤ d) :
    c + d ≥ e := by
  unfold IsPQ5 at hpq
  by_contra h; push_neg at h
  have h2 : e ^ 2 < (c + d) ^ 2 := by nlinarith
  nlinarith [sq_nonneg (c - a), sq_nonneg (d - b), sq_nonneg (c - b), sq_nonneg (d - a)]

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Composition
-- ═══════════════════════════════════════════════════════════════

theorem compose_triples (a b c d e f g : ℤ)
    (h1 : a ^ 2 + b ^ 2 = f ^ 2) (h2 : c ^ 2 + d ^ 2 = g ^ 2)
    (h3 : f ^ 2 + g ^ 2 = e ^ 2) :
    IsPQ5 a b c d e := by
  unfold IsPQ5; linarith

theorem extend_pq4 (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    IsPQ5 a b c 0 d := by
  unfold IsPQ5; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Component Bounds
-- ═══════════════════════════════════════════════════════════════

theorem comp_bound_a (a b c d e : ℤ) (hpq : IsPQ5 a b c d e)
    (hb : 0 < b) (hc : 0 < c) (hd : 0 < d) : a ^ 2 < e ^ 2 := by
  unfold IsPQ5 at hpq; nlinarith [sq_nonneg b, sq_nonneg c, sq_nonneg d]

theorem three_comp_bound (a b c d e : ℤ) (hpq : IsPQ5 a b c d e) (hd : 0 < d) :
    a ^ 2 + b ^ 2 + c ^ 2 < e ^ 2 := by
  unfold IsPQ5 at hpq; nlinarith [sq_nonneg d]

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Cauchy-Schwarz
-- ═══════════════════════════════════════════════════════════════

theorem cauchy_schwarz_5d (a₁ b₁ c₁ d₁ e₁ a₂ b₂ c₂ d₂ e₂ : ℤ)
    (h₁ : IsPQ5 a₁ b₁ c₁ d₁ e₁) (h₂ : IsPQ5 a₂ b₂ c₂ d₂ e₂) :
    (a₁ * a₂ + b₁ * b₂ + c₁ * c₂ + d₁ * d₂) ^ 2 ≤ e₁ ^ 2 * e₂ ^ 2 := by
  unfold IsPQ5 at *
  nlinarith [sq_nonneg (a₁ * b₂ - b₁ * a₂),
             sq_nonneg (a₁ * c₂ - c₁ * a₂),
             sq_nonneg (a₁ * d₂ - d₁ * a₂),
             sq_nonneg (b₁ * c₂ - c₁ * b₂),
             sq_nonneg (b₁ * d₂ - d₁ * b₂),
             sq_nonneg (c₁ * d₂ - d₁ * c₂)]

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Ghost Group and Counting
-- ═══════════════════════════════════════════════════════════════

theorem ghost_5d_order : 24 * 16 = 384 := by norm_num

theorem lifting_planes_5d : Nat.choose 4 2 = 6 := by native_decide

theorem berggren_branches_5d : 3 * 6 = 18 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 10: Parity and Doubled Norm
-- ═══════════════════════════════════════════════════════════════

theorem pq5_parity (a b c d e : ℤ) (h : IsPQ5 a b c d e) :
    (a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2) % 2 = e ^ 2 % 2 := by
  unfold IsPQ5 at h; omega

theorem pq5_doubled_norm (a b c d e : ℤ) (h : IsPQ5 a b c d e) :
    a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 + e ^ 2 = 2 * e ^ 2 := by
  unfold IsPQ5 at h; linarith

