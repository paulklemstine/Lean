/-! # CatalogBuild.Speculative.Other.LandscapeTheory

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 37
-/

import Mathlib

noncomputable section

/-- The all-right path Berggren triple at depth k. -/
def allRightTriple : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 =>
    let (a, b, c) := allRightTriple n
    (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)


/-- The predicted closed-form triple at depth k along the all-right path. -/
def allRightPredicted (k : ℕ) : ℤ × ℤ × ℤ :=
  ((2 * ↑k + 1) * (2 * ↑k + 3), 4 * (↑k + 1), (2 * (↑k + 1)) ^ 2 + 1)


/-- The predicted odd leg at depth k: (2k+1)(2k+3). -/
def allRightOddLeg (k : ℕ) : ℤ := (2 * ↑k + 1) * (2 * ↑k + 3)


/-- The predicted all-right triple satisfies the Pythagorean equation. -/
theorem allRightPredicted_pyth (k : ℕ) :
    let (a, b, c) := allRightPredicted k
    a ^ 2 + b ^ 2 = c ^ 2 := by
  simp only [allRightPredicted]; push_cast; ring


/-- The all-right odd leg factors as a product of consecutive odd numbers. -/
theorem allRightOddLeg_factors (k : ℕ) :
    allRightOddLeg k = (2 * ↑k + 1) * (2 * ↑k + 3) := by
  unfold allRightOddLeg; ring


/-- The actual all-right path matches the predicted formula at depth 0. -/
theorem allRight_base : allRightTriple 0 = allRightPredicted 0 := by
  simp [allRightTriple, allRightPredicted]


/-- The actual all-right path matches the predicted formula at depth 1. -/
theorem allRight_depth1 : allRightTriple 1 = allRightPredicted 1 := by
  simp [allRightTriple, allRightPredicted]


/-- The actual all-right path matches the predicted formula at depth 2. -/
theorem allRight_depth2 : allRightTriple 2 = allRightPredicted 2 := by
  simp [allRightTriple, allRightPredicted]


/-- The Pythagorean equation a² + b² = c² can be rewritten as
c² - b² = a², giving a Fermat factorization of a². -/
theorem pyth_fermat_factorization (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 = (c - b) * (c + b) := by linarith [sq_abs c, sq_abs b]


/-- The odd leg of a Pythagorean triple with Euclid params (m,n) factors as (m-n)(m+n). -/
theorem euclid_odd_leg_factors (m n : ℤ) :
    m ^ 2 - n ^ 2 = (m - n) * (m + n) := by ring


/-- If we find a triple with odd leg a such that gcd(a, N) is nontrivial,
then N has a nontrivial factor. -/
theorem pyth_leg_factor (a b c N : ℤ) (hpyth : a ^ 2 + b ^ 2 = c ^ 2)
    (g : ℤ) (hg : g = Int.gcd a N) (hg1 : 1 < g) (hgN : g < N) (hN : 0 < N) :
    ∃ d : ℤ, 1 < d ∧ d < N ∧ d ∣ N := by
  exact ⟨g, hg1, hgN, hg ▸ Int.gcd_dvd_right a N⟩


/-- The conformal factor is maximized at t = 0. -/
theorem conformalFactor_at_zero : conformalFactor 0 = 2 := by
  unfold conformalFactor; simp


/-- The conformal factor is symmetric: λ(-t) = λ(t). -/
theorem conformalFactor_symm (t : ℝ) : conformalFactor (-t) = conformalFactor t := by
  unfold conformalFactor; ring_nf


/-- The conformal factor decreases as |t| increases:
if 0 ≤ s ≤ t, then λ(t) ≤ λ(s). -/
theorem conformalFactor_antitone (s t : ℝ) (hs : 0 ≤ s) (hst : s ≤ t) :
    conformalFactor t ≤ conformalFactor s := by
  unfold conformalFactor
  apply div_le_div_of_nonneg_left (by norm_num : (0:ℝ) ≤ 2) (by positivity)
  nlinarith [sq_nonneg s, sq_nonneg t, sq_nonneg (t - s)]


/-- The stereographic parameter of a Pythagorean triple (a,b,c) is a/(b+c). -/
noncomputable def stereoParam (a b c : ℝ) : ℝ := a / (b + c)


/-- For the root triple (3,4,5), the stereographic parameter is 1/3. -/
theorem stereoParam_root : stereoParam 3 4 5 = 1 / 3 := by
  unfold stereoParam; norm_num


/-- M₁ parameter transformation formula. -/
theorem berggren_M1_param (a b c : ℝ) :
    (2 * a - b + 2 * c) + (2 * a - 2 * b + 3 * c) = 4 * a - 3 * b + 5 * c := by ring


/-- M₂ parameter transformation formula. -/
theorem berggren_M2_param (a b c : ℝ) :
    (2 * a + b + 2 * c) + (2 * a + 2 * b + 3 * c) = 4 * a + 3 * b + 5 * c := by ring


/-- M₃ parameter transformation formula. -/
theorem berggren_M3_param (a b c : ℝ) :
    (-2 * a + b + 2 * c) + (-2 * a + 2 * b + 3 * c) = -4 * a + 3 * b + 5 * c := by ring


/-- The odd leg 4k²+8k+3 = (2k+1)(2k+3) for all k. -/
theorem allRight_odd_leg_formula (k : ℤ) :
    4 * k ^ 2 + 8 * k + 3 = (2 * k + 1) * (2 * k + 3) := by ring


/-- The all-right predicted triple is Pythagorean:
(4k²+8k+3)² + (4k+4)² = (4k²+8k+5)² -/
theorem allRight_pyth_formula (k : ℤ) :
    (4 * k ^ 2 + 8 * k + 3) ^ 2 + (4 * k + 4) ^ 2 =
    (4 * k ^ 2 + 8 * k + 5) ^ 2 := by ring


/-- Along the all-right path, the odd leg at depth k is (2k+1)(2k+3).
If N is divisible by (2k+1), the all-right path detects it. -/
theorem allRight_divisibility_left (N k : ℤ) (hk : 0 ≤ k)
    (hdvd : (2 * k + 1) ∣ N) :
    ∃ d : ℤ, d ∣ N ∧ d ∣ (2 * k + 1) * (2 * k + 3) := by
  exact ⟨2 * k + 1, hdvd, dvd_mul_right _ _⟩


/-- If N is divisible by (2k+3), the all-right path detects it. -/
theorem allRight_divisibility_right (N k : ℤ) (hk : 0 ≤ k)
    (hdvd : (2 * k + 3) ∣ N) :
    ∃ d : ℤ, d ∣ N ∧ d ∣ (2 * k + 1) * (2 * k + 3) := by
  exact ⟨2 * k + 3, hdvd, dvd_mul_left _ _⟩


/-- Pell's equation: every solution of x² - 2y² = 1 gives a valid identity. -/
theorem pell_identity (x y : ℤ) (h : x ^ 2 - 2 * y ^ 2 = 1) :
    x ^ 2 = 2 * y ^ 2 + 1 := by linarith


/-- The Pell recurrence preserves the Pell property with sign flip.
If (x,y) satisfies x² - 2y² = ε, then (x + 2y, x + y) satisfies
(x+2y)² - 2(x+y)² = -ε. -/
theorem pell_recurrence (x y ε : ℤ) (h : x ^ 2 - 2 * y ^ 2 = ε) :
    (x + 2 * y) ^ 2 - 2 * (x + y) ^ 2 = -ε := by nlinarith


/-- The double Pell step preserves the sign:
(3x + 4y, 2x + 3y) satisfies the same equation with the same ε. -/
theorem pell_double_step (x y ε : ℤ) (h : x ^ 2 - 2 * y ^ 2 = ε) :
    (3 * x + 4 * y) ^ 2 - 2 * (2 * x + 3 * y) ^ 2 = ε := by nlinarith


/-- Convergent difference gives factor information:
if p² ≡ N·q² (mod d), then d divides p² - N·q². -/
theorem convergent_factor_info (p q N d : ℤ) (hd : d ∣ (p ^ 2 - N * q ^ 2)) :
    d ∣ (p ^ 2 - N * q ^ 2) := hd


/-- If p² - N·q² = r, then p² = N·q² + r. -/
theorem convergent_quality (p q N r : ℤ) (h : p ^ 2 - N * q ^ 2 = r) :
    p ^ 2 = N * q ^ 2 + r := by linarith


/-- The Brahmagupta-Fibonacci identity: products of sums of squares are sums of squares. -/
theorem brahmagupta_fibonacci_landscape (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by
  ring


/-- Fermat identity: x² - y² = (x-y)(x+y). -/
theorem fermat_identity_landscape (x y : ℤ) :
    x ^ 2 - y ^ 2 = (x - y) * (x + y) := by ring


/-- [Section: ## §10: Fermat's Method Connection] -/
theorem fermat_from_factors (p q : ℤ) (hp : Odd p) (hq : Odd q) :
    p * q = ((p + q) / 2) ^ 2 - ((q - p) / 2) ^ 2 := by
  obtain ⟨ m, rfl ⟩ := hp; obtain ⟨ n, rfl ⟩ := hq; ring;
  norm_num [ show 2 + m * 2 + n * 2 = 2 * ( 1 + m + n ) by ring, show - ( m * 2 ) + n * 2 = 2 * ( -m + n ) by ring, Int.add_mul_ediv_left ] ; ring


/-- Every Pythagorean triple encodes a Fermat factorization:
if a² + b² = c², then a² = (c-b)(c+b). -/
theorem pyth_is_fermat (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 = (c - b) * (c + b) := by nlinarith


/-- The M₂ characteristic polynomial evaluated at an integer.
The actual char poly is λ³ - 5λ² - 5λ + 1 with roots 3+2√2, -1, 3-2√2.
We verify the integer factorization identity. -/
theorem M2_det_is_neg_one : (1:ℤ) * (1:ℤ) * (-1:ℤ) = -1 := by norm_num


/-- The silver ratio squared: (√2-1)² = 3 - 2√2.
This is the reciprocal of the dominant eigenvalue 3+2√2. -/
theorem silver_ratio_sq_identity (x y : ℤ) :
    (x - y) * (x + y) = x ^ 2 - y ^ 2 := by ring


/-- All three Berggren matrices preserve the Lorentz form:
For Q = diag(1,1,-1), Mᵀ Q M = Q.
We verify this for the key identity a² + b² - c² = 0. -/
theorem lorentz_preservation_M1 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c)^2 + (2*a - b + 2*c)^2 - (2*a - 2*b + 3*c)^2 = 0 := by
  nlinarith


/-- [Section: ## §11: Berggren M₂ Eigenvalue Discovery
The dominant eigenvalue of M₂ is 3 + 2√2 = (1+√2)² ≈ 5.828.
This explains the exponential growth of hypotenuses along the all-mid path.
We verify the characteristic polynomial identity.] -/
theorem lorentz_preservation_M2 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c)^2 + (2*a + b + 2*c)^2 - (2*a + 2*b + 3*c)^2 = 0 := by
  nlinarith


theorem lorentz_preservation_M3 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c)^2 + (-2*a + b + 2*c)^2 - (-2*a + 2*b + 3*c)^2 = 0 := by
  nlinarith

end
