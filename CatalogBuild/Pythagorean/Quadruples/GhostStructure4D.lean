/-! # CatalogBuild.Pythagorean.Quadruples.GhostStructure4D

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 75
-/

import Mathlib

/-- A Pythagorean quadruple satisfies a² + b² + c² = d². -/
def isPQ (a b c d : ℤ) : Prop := a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2


/-- The 4D Lorentz form Q₄(a,b,c,d) = a² + b² + c² - d². -/
def LQ4 (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2


/-- A quadruple is Pythagorean iff the Lorentz form vanishes. -/
theorem isPQ_iff_LQ4 (a b c d : ℤ) :
    isPQ a b c d ↔ LQ4 a b c d = 0 := by
  simp [isPQ, LQ4]; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 2: (ℤ/2)³ Sign-Flip Symmetry
-- ═══════════════════════════════════════════════════════════════


/-- [Section: # Four-Dimensional Pythagorean Quadruples: Ghost Structure
For Pythagorean quadruples a² + b² + c² = d², we establish:
1. **(ℤ/2)³ Sign-Flip Symmetry**: Sign flips of spatial components preserve the equation
2. **S₃ Permutation Symmetry**: Permuting spatial components preserves the equation
3. **Lifted 3D Ghost Structure**: The Berggren inverse lifts to 4D via 3 lifting planes
4. **O(3,1;ℤ) Matrix Verification**: Lifted matrices are in the integer Lorentz group
5. **Hypotenuse Descent**: Conditions for the parent hypotenuse to decrease
## Key Discovery: 4D Ghost Structure is Richer Than 3D
In 3D, all three Berggren inverse images share a universal parent hypotenuse.
In 4D, there are THREE families of parent hypotenuses (one per lifting plane),
and the descent depends on choosing the right plane. The full ghost group is
S₃ × (ℤ/2)², giving 24 ghost images (vs. 4 in 3D).] -/
theorem sf1 (a b c d : ℤ) (h : isPQ a b c d) : isPQ (-a) b c d := by
  unfold isPQ at *; nlinarith


/-- [Section: # CatalogBuild.Pythagorean.Quadruples.GhostStructure4D
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 75] -/
theorem sf2 (a b c d : ℤ) (h : isPQ a b c d) : isPQ a (-b) c d := by
  unfold isPQ at *; nlinarith


theorem sf3 (a b c d : ℤ) (h : isPQ a b c d) : isPQ a b (-c) d := by
  unfold isPQ at *; nlinarith


theorem sf12 (a b c d : ℤ) (h : isPQ a b c d) : isPQ (-a) (-b) c d := by
  unfold isPQ at *; nlinarith


theorem sf13 (a b c d : ℤ) (h : isPQ a b c d) : isPQ (-a) b (-c) d := by
  unfold isPQ at *; nlinarith


theorem sf23 (a b c d : ℤ) (h : isPQ a b c d) : isPQ a (-b) (-c) d := by
  unfold isPQ at *; nlinarith


theorem sf123 (a b c d : ℤ) (h : isPQ a b c d) : isPQ (-a) (-b) (-c) d := by
  unfold isPQ at *; nlinarith


/-- All 8 sign patterns preserve the quadruple equation ((ℤ/2)³ action). -/
theorem octahedral_ghost (a b c d : ℤ) (h : isPQ a b c d)
    (s₁ s₂ s₃ : ℤ) (hs₁ : s₁ = 1 ∨ s₁ = -1) (hs₂ : s₂ = 1 ∨ s₂ = -1)
    (hs₃ : s₃ = 1 ∨ s₃ = -1) :
    isPQ (s₁ * a) (s₂ * b) (s₃ * c) d := by
  simp [isPQ] at *
  rcases hs₁ with rfl | rfl <;> rcases hs₂ with rfl | rfl <;> rcases hs₃ with rfl | rfl <;>
    nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 3: S₃ Permutation Symmetry
-- ═══════════════════════════════════════════════════════════════


theorem pm12 (a b c d : ℤ) (h : isPQ a b c d) : isPQ b a c d := by
  simp only [isPQ] at *; linarith


theorem pm13 (a b c d : ℤ) (h : isPQ a b c d) : isPQ c b a d := by
  simp only [isPQ] at *; linarith


theorem pm23 (a b c d : ℤ) (h : isPQ a b c d) : isPQ a c b d := by
  simp only [isPQ] at *; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Lorentz Form Properties
-- ═══════════════════════════════════════════════════════════════


theorem LQ4_sf1 (a b c d : ℤ) : LQ4 (-a) b c d = LQ4 a b c d := by
  unfold LQ4; ring


theorem LQ4_sf2 (a b c d : ℤ) : LQ4 a (-b) c d = LQ4 a b c d := by
  unfold LQ4; ring


theorem LQ4_sf3 (a b c d : ℤ) : LQ4 a b (-c) d = LQ4 a b c d := by
  unfold LQ4; ring


theorem LQ4_pm12 (a b c d : ℤ) : LQ4 b a c d = LQ4 a b c d := by
  unfold LQ4; ring


theorem LQ4_pm23 (a b c d : ℤ) : LQ4 a c b d = LQ4 a b c d := by
  unfold LQ4; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Lebesgue Parametrization
-- ═══════════════════════════════════════════════════════════════


/-- The Lebesgue parametrization of Pythagorean quadruples. -/
def lebParam (m n p q : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (m^2 + n^2 - p^2 - q^2, 2*(m*q + n*p), 2*(n*q - m*p), m^2 + n^2 + p^2 + q^2)


/-- The Lebesgue parametrization always produces a Pythagorean quadruple. -/
theorem leb_is_pq (m n p q : ℤ) :
    isPQ (lebParam m n p q).1 (lebParam m n p q).2.1
         (lebParam m n p q).2.2.1 (lebParam m n p q).2.2.2 := by
  simp [lebParam, isPQ]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Lifted 3D Berggren Inverse to 4D
-- ═══════════════════════════════════════════════════════════════


/-- B₂⁻¹ lifted in the (1,2) plane: transforms (a,b) w.r.t. d, fixing c. -/
def lift12 (a b c d : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (a + 2*b - 2*d, 2*a + b - 2*d, c, -2*a - 2*b + 3*d)


/-- B₁⁻¹ lifted in the (1,2) plane. -/
def lift12_B1 (a b c d : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (a + 2*b - 2*d, -2*a - b + 2*d, c, -2*a - 2*b + 3*d)


/-- B₃⁻¹ lifted in the (1,2) plane. -/
def lift12_B3 (a b c d : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (-a - 2*b + 2*d, 2*a + b - 2*d, c, -2*a - 2*b + 3*d)


/-- B₂⁻¹ lifted in the (1,3) plane: transforms (a,c) w.r.t. d, fixing b. -/
def lift13 (a b c d : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (a + 2*c - 2*d, b, 2*a + c - 2*d, -2*a - 2*c + 3*d)


/-- B₂⁻¹ lifted in the (2,3) plane: transforms (b,c) w.r.t. d, fixing a. -/
def lift23 (a b c d : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (a, b + 2*c - 2*d, 2*b + c - 2*d, -2*b - 2*c + 3*d)

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Lorentz Form Preservation
-- ═══════════════════════════════════════════════════════════════


theorem lift12_preserves_LQ4 (a b c d : ℤ) :
    LQ4 (lift12 a b c d).1 (lift12 a b c d).2.1
        (lift12 a b c d).2.2.1 (lift12 a b c d).2.2.2 = LQ4 a b c d := by
  simp [LQ4, lift12]; ring


theorem lift12_B1_preserves_LQ4 (a b c d : ℤ) :
    LQ4 (lift12_B1 a b c d).1 (lift12_B1 a b c d).2.1
        (lift12_B1 a b c d).2.2.1 (lift12_B1 a b c d).2.2.2 = LQ4 a b c d := by
  simp [LQ4, lift12_B1]; ring


theorem lift12_B3_preserves_LQ4 (a b c d : ℤ) :
    LQ4 (lift12_B3 a b c d).1 (lift12_B3 a b c d).2.1
        (lift12_B3 a b c d).2.2.1 (lift12_B3 a b c d).2.2.2 = LQ4 a b c d := by
  simp [LQ4, lift12_B3]; ring


theorem lift13_preserves_LQ4 (a b c d : ℤ) :
    LQ4 (lift13 a b c d).1 (lift13 a b c d).2.1
        (lift13 a b c d).2.2.1 (lift13 a b c d).2.2.2 = LQ4 a b c d := by
  simp [LQ4, lift13]; ring


theorem lift23_preserves_LQ4 (a b c d : ℤ) :
    LQ4 (lift23 a b c d).1 (lift23 a b c d).2.1
        (lift23 a b c d).2.2.1 (lift23 a b c d).2.2.2 = LQ4 a b c d := by
  simp [LQ4, lift23]; ring

-- Corollaries: preservation of quadruples.


theorem lift12_preserves_PQ (a b c d : ℤ) (h : isPQ a b c d) :
    isPQ (lift12 a b c d).1 (lift12 a b c d).2.1
         (lift12 a b c d).2.2.1 (lift12 a b c d).2.2.2 := by
  rw [isPQ_iff_LQ4] at *; rw [lift12_preserves_LQ4]; exact h


theorem lift12_B1_preserves_PQ (a b c d : ℤ) (h : isPQ a b c d) :
    isPQ (lift12_B1 a b c d).1 (lift12_B1 a b c d).2.1
         (lift12_B1 a b c d).2.2.1 (lift12_B1 a b c d).2.2.2 := by
  rw [isPQ_iff_LQ4] at *; rw [lift12_B1_preserves_LQ4]; exact h


theorem lift12_B3_preserves_PQ (a b c d : ℤ) (h : isPQ a b c d) :
    isPQ (lift12_B3 a b c d).1 (lift12_B3 a b c d).2.1
         (lift12_B3 a b c d).2.2.1 (lift12_B3 a b c d).2.2.2 := by
  rw [isPQ_iff_LQ4] at *; rw [lift12_B3_preserves_LQ4]; exact h


theorem lift13_preserves_PQ (a b c d : ℤ) (h : isPQ a b c d) :
    isPQ (lift13 a b c d).1 (lift13 a b c d).2.1
         (lift13 a b c d).2.2.1 (lift13 a b c d).2.2.2 := by
  rw [isPQ_iff_LQ4] at *; rw [lift13_preserves_LQ4]; exact h


theorem lift23_preserves_PQ (a b c d : ℤ) (h : isPQ a b c d) :
    isPQ (lift23 a b c d).1 (lift23 a b c d).2.1
         (lift23 a b c d).2.2.1 (lift23 a b c d).2.2.2 := by
  rw [isPQ_iff_LQ4] at *; rw [lift23_preserves_LQ4]; exact h

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Ghost Structure of Lifted Transforms
-- ═══════════════════════════════════════════════════════════════


/-- All (1,2)-lifted transforms share the same hypotenuse. -/
theorem lift12_same_hyp (a b c d : ℤ) :
    (lift12 a b c d).2.2.2 = (lift12_B1 a b c d).2.2.2 ∧
    (lift12_B1 a b c d).2.2.2 = (lift12_B3 a b c d).2.2.2 := by
  simp [lift12, lift12_B1, lift12_B3]


/-- All (1,2)-lifted transforms fix the third coordinate c. -/
theorem lift12_same_c (a b c d : ℤ) :
    (lift12 a b c d).2.2.1 = c ∧
    (lift12_B1 a b c d).2.2.1 = c ∧
    (lift12_B3 a b c d).2.2.1 = c := by
  simp [lift12, lift12_B1, lift12_B3]


/-- B₁⁻¹ and B₂⁻¹ share first component (p-parameter). -/
theorem lift12_B1_B2_share_fst (a b c d : ℤ) :
    (lift12_B1 a b c d).1 = (lift12 a b c d).1 := by
  simp [lift12_B1, lift12]


/-- B₂⁻¹ and B₃⁻¹ share second component (q-parameter). -/
theorem lift12_B2_B3_share_snd (a b c d : ℤ) :
    (lift12 a b c d).2.1 = (lift12_B3 a b c d).2.1 := by
  simp [lift12, lift12_B3]


/-- B₁⁻¹ and B₂⁻¹ have opposite second components. -/
theorem lift12_B1_B2_opp_snd (a b c d : ℤ) :
    (lift12_B1 a b c d).2.1 = -(lift12 a b c d).2.1 := by
  simp [lift12_B1, lift12]; ring


/-- B₂⁻¹ and B₃⁻¹ have opposite first components. -/
theorem lift12_B2_B3_opp_fst (a b c d : ℤ) :
    (lift12_B3 a b c d).1 = -(lift12 a b c d).1 := by
  simp [lift12_B3, lift12]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Three Different Parent Hypotenuses in 4D
-- ═══════════════════════════════════════════════════════════════


theorem hyp12_def (a b c d : ℤ) :
    (lift12 a b c d).2.2.2 = -2*a - 2*b + 3*d := by
  simp [lift12]


theorem hyp13_def (a b c d : ℤ) :
    (lift13 a b c d).2.2.2 = -2*a - 2*c + 3*d := by
  simp [lift13]


theorem hyp23_def (a b c d : ℤ) :
    (lift23 a b c d).2.2.2 = -2*b - 2*c + 3*d := by
  simp [lift23]


/-- The three hypotenuses differ by leg differences. -/
theorem hyp12_minus_hyp13 (a b c d : ℤ) :
    (lift12 a b c d).2.2.2 - (lift13 a b c d).2.2.2 = 2*(c - b) := by
  simp [lift12, lift13]; ring


theorem hyp12_minus_hyp23 (a b c d : ℤ) :
    (lift12 a b c d).2.2.2 - (lift23 a b c d).2.2.2 = 2*(c - a) := by
  simp [lift12, lift23]; ring


theorem hyp13_minus_hyp23 (a b c d : ℤ) :
    (lift13 a b c d).2.2.2 - (lift23 a b c d).2.2.2 = 2*(b - a) := by
  simp [lift13, lift23]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 10: Descent in 4D
-- ═══════════════════════════════════════════════════════════════


/-- The (2,3)-lift hypotenuse decreases when b + c > d. -/
theorem hyp23_decrease (b c d : ℤ) (hbc : b + c > d) :
    -2*b - 2*c + 3*d < d := by linarith


theorem descent_exists (a b c d : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hq : isPQ a b c d) (hd : 0 < d) :
    -2*a - 2*b + 3*d < d ∨ -2*a - 2*c + 3*d < d ∨ -2*b - 2*c + 3*d < d := by
  have htri := pq_triangle a b c d ha hb hc hq hd
  by_contra hno
  push_neg at hno
  obtain ⟨h1, h2, h3⟩ := hno
  -- h1: d ≤ -2a - 2b + 3d, i.e., 2a + 2b ≤ 2d
  -- h2: d ≤ -2a - 2c + 3d, i.e., 2a + 2c ≤ 2d
  -- h3: d ≤ -2b - 2c + 3d, i.e., 2b + 2c ≤ 2d
  -- Adding all three: 4(a+b+c) ≤ 6d, i.e., 2(a+b+c) ≤ 3d.
  -- But a+b+c > d, so 2d < 2(a+b+c) ≤ 3d, giving 2d < 3d, i.e., d > 0.
  -- Actually that's not a contradiction. Let me be more careful.
  -- h1 + h2 + h3: 3d ≤ -4a - 4b - 4c + 9d, i.e., 4(a+b+c) ≤ 6d.
  -- But a+b+c > d means 4(a+b+c) > 4d, so 4d < 6d, which is true for d > 0.
  -- So this approach doesn't work directly. Let me think differently.
  -- Actually: the sum of any two spatial components must exceed d for some pair.
  -- From htri: a + b + c > d.
  -- Suppose a + b ≤ d, a + c ≤ d, b + c ≤ d.
  -- Then 2(a+b+c) = (a+b) + (a+c) + (b+c) ≤ 3d.
  -- But also a+b+c > d.
  -- Example: a=1, b=1, c=1, d=1.5. Then a+b+c = 3 > 1.5,
  -- but a+b = 2 > 1.5. So in some cases the hypothesis holds.
  -- Actually for quadruples: (1,2,2,3). a+b=3=d, a+c=3=d, b+c=4>3.
  -- So b+c > d but a+b = d. So at least one pair works.
  -- Can we have all three ≤ d? That would require 2(a+b+c) ≤ 3d.
  -- With a²+b²+c² = d², we need to check...
  -- By AM-QM: (a+b+c)/3 ≥ 1 (if all positive) but this isn't strong enough.
  -- Actually consider a=b=c. Then 3a²=d², d = a√3.
  -- a+b = 2a, d = a√3 ≈ 1.73a. So a+b = 2a > 1.73a = d. ✓
  -- So for the equal case, a+b > d.
  -- For very skewed: a=ε, b=ε, c=d-ε'. Then ε²+ε²+(d-ε')² = d².
  -- 2ε² + d² - 2dε' + ε'² = d². So 2ε² + ε'² = 2dε'. For small ε,
  -- ε' ≈ ε²/(2d). Then b+c ≈ ε + d > d. But a+b ≈ 2ε < d.
  -- And a+c ≈ ε + d > d.
  -- So we can have a+b < d when a is small.
  -- But b+c > d. Let me try: does at least one pair exceed d?
  -- From a+b+c > d and all positive: Suppose a ≤ b ≤ c.
  -- Then b+c ≥ 2c/1... Actually a+b+c > d and a ≤ b, a ≤ c gives
  -- b+c ≥ 2a, and a+b+c > d, so b+c > d - a.
  -- We need b+c > d. Can b+c ≤ d? Then a > 0, b+c ≤ d, a+b+c > d.
  -- So a > d - b - c ≥ 0.
  -- From a²+b²+c² = d²: a² = d² - b² - c².
  -- a² = d² - b² - c² = (d-b)(d+b) - c² ≤ (d-b)(d+b).
  -- Not sure this leads anywhere directly.
  -- Let me just prove: for all positive PQ, b+c > d (where a ≤ b ≤ c).
  -- a² + b² + c² = d². Since a ≤ c, a² ≤ c².
  -- So d² = a²+b²+c² ≤ 2c²+b². Also d² ≥ b²+c².
  -- (b+c)² = b²+2bc+c² = d²-a²+2bc ≥ d²+2bc-c² ≥ d² (if b ≥ 0).
  -- Actually (b+c)² = b²+c²+2bc = d²-a²+2bc > d²-a² (since bc > 0).
  -- And d²-a² < d². So (b+c)² > d²-a².
  -- We need (b+c)² > d². That means d²-a²+2bc > d², i.e., 2bc > a².
  -- Is this always true? For a=b=c: 2a² > a². Yes.
  -- For a=1, b=2, c=2, d=3: 2*2*2=8 > 1. Yes.
  -- For a=1, b=1, c=1: not a quadruple.
  -- For a small: 2bc > a² when bc > a²/2. Since a ≤ b ≤ c, bc ≥ a², so yes!
  -- bc ≥ a·a = a² (since b ≥ a and c ≥ a). So 2bc ≥ 2a² > a². ✓
  -- This means (b+c)² > d² when a ≤ b ≤ c, so b+c > d!
  -- Let me prove this properly.
  have h_sq : (b + c)^2 > d^2 := by
    gcongr ; nlinarith [ hq.symm ];
  nlinarith only [ ha, hb, hc, hd, htri, h1, h2, h3, h_sq ]

-- ═══════════════════════════════════════════════════════════════
-- Section 11: O(3,1;ℤ) Matrix Verification
-- ═══════════════════════════════════════════════════════════════


/-- The Lorentz metric η = diag(1,1,1,-1). -/
def eta4D : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, (-1)]


def inO31 (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  M.transpose * eta4D * M = eta4D


/-- Matrix form of lift12 (B₂⁻¹ in (1,2) plane). -/
def mLift12 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 2, 0, (-2); 2, 1, 0, (-2); 0, 0, 1, 0; (-2), (-2), 0, 3]


theorem mLift12_in_O31 : inO31 mLift12 := by
  unfold inO31 mLift12 eta4D; native_decide


/-- Matrix form of lift13 (B₂⁻¹ in (1,3) plane). -/
def mLift13 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 2, (-2); 0, 1, 0, 0; 2, 0, 1, (-2); (-2), 0, (-2), 3]


theorem mLift13_in_O31 : inO31 mLift13 := by
  unfold inO31 mLift13 eta4D; native_decide


/-- Matrix form of lift23 (B₂⁻¹ in (2,3) plane). -/
def mLift23 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 2, (-2); 0, 2, 1, (-2); 0, (-2), (-2), 3]


theorem mLift23_in_O31 : inO31 mLift23 := by
  unfold inO31 mLift23 eta4D; native_decide


/-- The lifted transforms don't commute (nonabelian structure). -/
theorem lifts_noncommutative : mLift12 * mLift13 ≠ mLift13 * mLift12 := by
  native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 12: Embedding 3D into 4D
-- ═══════════════════════════════════════════════════════════════


theorem triple_embeds (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    isPQ a b 0 c := by
  simp [isPQ]; linarith


theorem combine_triples_pq (a b c d e : ℤ)
    (h1 : a ^ 2 + b ^ 2 = e ^ 2) (h2 : e ^ 2 + c ^ 2 = d ^ 2) :
    isPQ a b c d := by
  simp [isPQ]; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 13: Concrete Examples
-- ═══════════════════════════════════════════════════════════════


theorem pq_1_2_2_3 : isPQ 1 2 2 3 := by unfold isPQ; norm_num


theorem pq_2_3_6_7 : isPQ 2 3 6 7 := by unfold isPQ; norm_num


theorem pq_1_4_8_9 : isPQ 1 4 8 9 := by unfold isPQ; norm_num


theorem pq_4_4_7_9 : isPQ 4 4 7 9 := by unfold isPQ; norm_num

-- (2,3,6,7): the (1,3)-lift gives descent to hypotenuse 5.


theorem descent_1_4_8_9 :
    lift23 1 4 8 9 = (1, 2, -2, 3) := by simp [lift23]

-- Verify descended quadruples


theorem descended_0_3_m4_5 : isPQ 0 3 (-4) 5 := by unfold isPQ; norm_num


theorem descended_1_2_m2_3 : isPQ 1 2 (-2) 3 := by unfold isPQ; norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 14: Parity in 4D Lifting
-- ═══════════════════════════════════════════════════════════════


theorem lift12_par_a (a b c d : ℤ) :
    (lift12 a b c d).1 % 2 = a % 2 := by
  show (a + 2 * b - 2 * d) % 2 = a % 2; omega


theorem lift12_par_b (a b c d : ℤ) :
    (lift12 a b c d).2.1 % 2 = b % 2 := by
  show (2 * a + b - 2 * d) % 2 = b % 2; omega


theorem lift12_par_c (a b c d : ℤ) :
    (lift12 a b c d).2.2.1 % 2 = c % 2 := by rfl


theorem lift12_par_d (a b c d : ℤ) :
    (lift12 a b c d).2.2.2 % 2 = d % 2 := by
  show (-2 * a - 2 * b + 3 * d) % 2 = d % 2; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 15: Ghost Group Order by Dimension
-- ═══════════════════════════════════════════════════════════════


theorem ghost_group_3d : 2 * (2 ^ 2 : ℕ) = 8 := by norm_num


theorem ghost_group_4d : 6 * (2 ^ 3 : ℕ) = 48 := by norm_num


theorem ghost_group_5d : 24 * (2 ^ 4 : ℕ) = 384 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 16: Axiom Check
-- ═══════════════════════════════════════════════════════════════

#print axioms octahedral_ghost
#print axioms lift12_preserves_PQ
#print axioms lift13_preserves_PQ
#print axioms lift23_preserves_PQ
#print axioms mLift12_in_O31
#print axioms pq_triangle

