/-! # CatalogBuild.Pythagorean.Berggren.BerggrenDescent

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 42
-/

import Mathlib

/-- Inverse Berggren transform B₁⁻¹ applied to (a,b,c). -/
def invBerggren1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)


/-- Inverse Berggren transform B₂⁻¹ applied to (a,b,c). -/
def invBerggren2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)


/-- Inverse Berggren transform B₃⁻¹ applied to (a,b,c). -/
def invBerggren3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)


/-- [Section: ## §3. Inverse Transforms Preserve the Pythagorean Property] -/
theorem invBerggren1_preserves (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple (invBerggren1 a b c).1 (invBerggren1 a b c).2.1 (invBerggren1 a b c).2.2 := by
  unfold IsPythTriple invBerggren1 at *; nlinarith [h]


theorem invBerggren2_preserves (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple (invBerggren2 a b c).1 (invBerggren2 a b c).2.1 (invBerggren2 a b c).2.2 := by
  unfold IsPythTriple invBerggren2 at *; nlinarith [h]


theorem invBerggren3_preserves (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythTriple (invBerggren3 a b c).1 (invBerggren3 a b c).2.1 (invBerggren3 a b c).2.2 := by
  unfold IsPythTriple invBerggren3 at *; nlinarith [h]


/-- All three inverse transforms produce the same hypotenuse: c' = 3c - 2a - 2b.
This is the "universal parent hypotenuse formula". -/
theorem universal_parent_hyp (a b c : ℤ) :
    (invBerggren1 a b c).2.2 = -2*a - 2*b + 3*c ∧
    (invBerggren2 a b c).2.2 = -2*a - 2*b + 3*c ∧
    (invBerggren3 a b c).2.2 = -2*a - 2*b + 3*c := by
  unfold invBerggren1 invBerggren2 invBerggren3
  exact ⟨rfl, rfl, rfl⟩


/-- The parent hypotenuse formula can be written as c' = 3c - 2(a+b). -/
theorem parent_hyp_formula (a b c : ℤ) :
    -2*a - 2*b + 3*c = 3*c - 2*(a + b) := by ring


/-- For a Pythagorean triple with a,b > 0, we have a + b > c. -/
theorem sum_gt_hyp (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : IsPythTriple a b c) : a + b > c := by
  unfold IsPythTriple at hpyth
  nlinarith [sq_nonneg (a - b), sq_nonneg a, sq_nonneg b, sq_abs (a + b)]


/-- The hypotenuse decreases by at least 1 at each descent step. -/
theorem hyp_decrease_by_one (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : IsPythTriple a b c) (_hc : 5 < c) :
    3 * c - 2 * (a + b) ≤ c - 1 := by
  have h := sum_gt_hyp a b c ha hb hpyth
  linarith


/-- Forward Berggren transform B₁ -/
def fwdBerggren1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)


/-- Forward Berggren transform B₂ -/
def fwdBerggren2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)


/-- Forward Berggren transform B₃ -/
def fwdBerggren3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


/-- B₁ ∘ B₁⁻¹ = id -/
theorem fwd_inv_cancel_1 (a b c : ℤ) :
    let t := invBerggren1 a b c
    fwdBerggren1 t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [invBerggren1, fwdBerggren1, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩


/-- B₂ ∘ B₂⁻¹ = id -/
theorem fwd_inv_cancel_2 (a b c : ℤ) :
    let t := invBerggren2 a b c
    fwdBerggren2 t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [invBerggren2, fwdBerggren2, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩


/-- B₃ ∘ B₃⁻¹ = id -/
theorem fwd_inv_cancel_3 (a b c : ℤ) :
    let t := invBerggren3 a b c
    fwdBerggren3 t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [invBerggren3, fwdBerggren3, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩


/-- B₁⁻¹ ∘ B₁ = id -/
theorem inv_fwd_cancel_1 (a b c : ℤ) :
    let t := fwdBerggren1 a b c
    invBerggren1 t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [invBerggren1, fwdBerggren1, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩


/-- B₂⁻¹ ∘ B₂ = id -/
theorem inv_fwd_cancel_2 (a b c : ℤ) :
    let t := fwdBerggren2 a b c
    invBerggren2 t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [invBerggren2, fwdBerggren2, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩


/-- B₃⁻¹ ∘ B₃ = id -/
theorem inv_fwd_cancel_3 (a b c : ℤ) :
    let t := fwdBerggren3 a b c
    invBerggren3 t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [invBerggren3, fwdBerggren3, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩


/-- The three inverse transforms have complementary first-leg signs:
B₁⁻¹ and B₃⁻¹ produce negated first legs. -/
theorem branch_sign_characterization (a b c : ℤ) :
    (invBerggren1 a b c).1 = -(invBerggren3 a b c).1 ∧
    (invBerggren1 a b c).2.1 = -(invBerggren2 a b c).2.1 := by
  simp only [invBerggren1, invBerggren2, invBerggren3]
  constructor <;> ring


/-- The fundamental factoring identity: if a² + b² = c², then
c² - a² = b², giving (c-a)(c+a) = b². -/
theorem diff_of_squares_factoring (a b c : ℤ) (h : IsPythTriple a b c) :
    (c - a) * (c + a) = b ^ 2 := by
  unfold IsPythTriple at h; nlinarith


/-- The complementary factoring identity: (c-b)(c+b) = a². -/
theorem diff_of_squares_factoring' (a b c : ℤ) (h : IsPythTriple a b c) :
    (c - b) * (c + b) = a ^ 2 := by
  unfold IsPythTriple at h; nlinarith


/-- For a PPT with odd leg a = N (an odd composite), the triple
provides a difference-of-squares representation of N². -/
theorem iof_core_identity (N u h : ℤ) (hpyth : IsPythTriple N u h) :
    (h - u) * (h + u) = N ^ 2 := by
  unfold IsPythTriple at hpyth; nlinarith


/-- The Lebesgue parametrization produces Pythagorean quadruples. -/
theorem lebesgue_parametrization (m n p q : ℤ) :
    IsPythQuadruple
      (m^2 + n^2 - p^2 - q^2)
      (2*(m*q + n*p))
      (2*(n*q - m*p))
      (m^2 + n^2 + p^2 + q^2) := by
  unfold IsPythQuadruple; ring


/-- A Pythagorean triple lifts to a quadruple by adding a zero component. -/
theorem triple_to_quadruple (a b c : ℤ) (h : IsPythTriple a b c) :
    IsPythQuadruple a b 0 c := by
  unfold IsPythQuadruple IsPythTriple at *; linarith


/-- PPTs are null vectors of the Lorentz form. -/
theorem pyth_is_null (a b c : ℤ) : IsPythTriple a b c ↔ lorentzForm a b c = 0 := by
  unfold IsPythTriple lorentzForm; omega


/-- B₁ preserves the Lorentz form. -/
theorem fwdB1_preserves_lorentz (a b c : ℤ) :
    lorentzForm (fwdBerggren1 a b c).1 (fwdBerggren1 a b c).2.1 (fwdBerggren1 a b c).2.2
    = lorentzForm a b c := by
  unfold lorentzForm fwdBerggren1; ring


/-- B₂ preserves the Lorentz form. -/
theorem fwdB2_preserves_lorentz (a b c : ℤ) :
    lorentzForm (fwdBerggren2 a b c).1 (fwdBerggren2 a b c).2.1 (fwdBerggren2 a b c).2.2
    = lorentzForm a b c := by
  unfold lorentzForm fwdBerggren2; ring


/-- B₃ preserves the Lorentz form. -/
theorem fwdB3_preserves_lorentz (a b c : ℤ) :
    lorentzForm (fwdBerggren3 a b c).1 (fwdBerggren3 a b c).2.1 (fwdBerggren3 a b c).2.2
    = lorentzForm a b c := by
  unfold lorentzForm fwdBerggren3; ring


/-- The hypotenuse sequence along repeated B₂ application satisfies a Pell recurrence.
If (a,b,c) → (a',b',c') via B₂, and (a',b',c') → (a'',b'',c'') via B₂,
then c'' = 6c' - c. -/
theorem pell_recurrence_B2 (a b c : ℤ) :
    let c' := (fwdBerggren2 a b c).2.2
    let abc' := fwdBerggren2 a b c
    let c'' := (fwdBerggren2 abc'.1 abc'.2.1 abc'.2.2).2.2
    c'' = 6 * c' - c := by
  simp only [fwdBerggren2]
  ring


/-- If a² + b² = c² with a,b > 0, then c ≠ 0. -/
theorem hyp_ne_zero (a b c : ℤ) (ha : 0 < a) (_hb : 0 < b)
    (hpyth : IsPythTriple a b c) : c ≠ 0 := by
  unfold IsPythTriple at hpyth
  intro hc; subst hc; nlinarith [sq_nonneg a]


/-- If a² + b² = c² with a,b > 0 and c ≥ 0, then c > 0. -/
theorem hyp_pos_of_legs_pos (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 ≤ c) (hpyth : IsPythTriple a b c) : 0 < c := by
  rcases (hc.lt_or_eq) with h | h
  · exact h
  · exfalso; exact hyp_ne_zero a b c ha hb hpyth (by linarith)


/-- For a PPT, c > a when b > 0. -/
theorem hyp_gt_leg (a b c : ℤ) (ha : 0 ≤ a) (hb : 0 < b) (hc : 0 < c)
    (hpyth : IsPythTriple a b c) : c > a := by
  unfold IsPythTriple at hpyth
  nlinarith [sq_nonneg b, sq_nonneg (c - a), sq_nonneg (c + a)]


/-- Key identity: applying B₂⁻¹ and equating the hypotenuse to 5 gives
-2N - 2u + 3h = 5, i.e., h = (2N + 2u + 5)/3 when N² + u² = h². -/
theorem iof_depth1_constraint (N u h : ℤ)
    (hpyth : N ^ 2 + u ^ 2 = h ^ 2)
    (hroot_hyp : -2*N - 2*u + 3*h = 5) :
    9 * (N ^ 2 + u ^ 2) = (2*N + 2*u + 5) ^ 2 := by
  have hh : 3 * h = 2*N + 2*u + 5 := by linarith
  have : 9 * h ^ 2 = (3 * h) ^ 2 := by ring
  have : (3 * h) ^ 2 = (2*N + 2*u + 5) ^ 2 := by rw [hh]
  nlinarith


/-- Expanding the IOF depth-1 equation gives a quadratic in N and u. -/
theorem iof_depth1_quadratic (N u : ℤ)
    (h : 9 * (N ^ 2 + u ^ 2) = (2*N + 2*u + 5) ^ 2) :
    5 * N ^ 2 - 8 * N * u + 5 * u ^ 2 - 20 * N - 20 * u - 25 = 0 := by
  nlinarith [sq_nonneg (N - u), sq_nonneg (N + u), sq_nonneg N, sq_nonneg u,
    mul_self_nonneg N, mul_self_nonneg u]


/-- Pythagorean quadruples are null vectors of Q₄. -/
theorem quad_is_null (a b c d : ℤ) :
    IsPythQuadruple a b c d ↔ lorentzForm4 a b c d = 0 := by
  unfold IsPythQuadruple lorentzForm4; omega


/-- Consequence: if N = p·q where p = a²+b² and q = c²+d², then
N can be written as a sum of two squares. -/
theorem sum_of_squares_multiplicative (a b c d : ℤ) :
    ∃ x y : ℤ, (a^2 + b^2) * (c^2 + d^2) = x^2 + y^2 := by
  exact ⟨a*c - b*d, a*d + b*c, by ring⟩


/-- B₂ always increases the hypotenuse: c' = 2a + 2b + 3c > c for a,b > 0. -/
theorem B2_hyp_increases (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    (fwdBerggren2 a b c).2.2 > c := by
  simp only [fwdBerggren2]; linarith


/-- B₁ always increases the hypotenuse: c' = 2a - 2b + 3c.
For a > b (which holds on the B₁ branch), c' > c. -/
theorem B1_hyp_increases (a b c : ℤ) (hab : b < a) (hc : 0 < c) :
    (fwdBerggren1 a b c).2.2 > c := by
  simp only [fwdBerggren1]; linarith


/-- Swapping legs preserves the Pythagorean property. -/
theorem pyth_swap (a b c : ℤ) (h : IsPythTriple a b c) : IsPythTriple b a c := by
  unfold IsPythTriple at *; linarith


/-- Negating a leg preserves the Pythagorean property. -/
theorem pyth_neg_a (a b c : ℤ) (h : IsPythTriple a b c) : IsPythTriple (-a) b c := by
  unfold IsPythTriple at *; nlinarith


/-- Negating the other leg preserves the Pythagorean property. -/
theorem pyth_neg_b (a b c : ℤ) (h : IsPythTriple a b c) : IsPythTriple a (-b) c := by
  unfold IsPythTriple at *; nlinarith

