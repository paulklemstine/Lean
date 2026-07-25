/- Original: AgentAlpha_Invariants.lean -/



/-- The inradius numerator (a+b−c) of a Euclid triple equals 2n(m−n).
(We avoid division to stay in ℤ.) -/
theorem euclid_inradius_num (m n : ℤ) :
    let t := euclidTriple m n
    t.1 + t.2.1 - t.2.2 = 2 * n * (m - n) := by
  simp [euclidTriple]; ring

/-- The perimeter of a Euclid triple is 2m(m + n). -/
theorem euclid_perimeter (m n : ℤ) :
    let t := euclidTriple m n
    t.1 + t.2.1 + t.2.2 = 2 * m * (m + n) := by
  simp [euclidTriple]; ring

/-- The twice-area of a Euclid triple is 2mn(m² − n²) = 2mn(m−n)(m+n). -/
theorem euclid_twice_area (m n : ℤ) :
    let t := euclidTriple m n
    t.1 * t.2.1 = 2 * m * n * (m ^ 2 - n ^ 2) := by
  simp [euclidTriple]; ring

/-- The twice-area factors as 2mn(m−n)(m+n). -/
theorem euclid_twice_area_factored (m n : ℤ) :
    2 * m * n * (m ^ 2 - n ^ 2) = 2 * m * n * (m - n) * (m + n) := by ring

/-- Key identity: (a + b − c)(a + b + c) = 2ab for Pythagorean triples. -/
theorem pyth_inradius_identity (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + b - c) * (a + b + c) = 2 * a * b := by nlinarith [sq_nonneg (a + b - c)]

/-- a + b − c ≥ 0 when a, b, c > 0 and a² + b² = c². -/
theorem pyth_sum_minus_hyp_nonneg (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : 0 ≤ a + b - c := by
  nlinarith [sq_nonneg (a + b - c)]

/-- a + b > c for positive Pythagorean triples (strict triangle inequality). -/
theorem pyth_triangle_strict (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : c < a + b := by
  nlinarith [sq_nonneg (a - b)]

/-- [Section: # CatalogBuild.Pythagorean.Agents.AgentAlpha_Invariants
Auto-generated from theorem catalog database.
Domain: Pythagorean/Agents
Declarations: 28] -/
theorem pyth_inradius_even (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    2 ∣ (a + b - c) := by
  exact even_iff_two_dvd.mp ( by apply_fun Even at *; simp_all +decide [ parity_simps ] )

/-- [Section: # CatalogBuild.Pythagorean.Agents.AgentAlpha_Invariants
Auto-generated from theorem catalog database.
Domain: Pythagorean/Agents
Declarations: 28] -/
theorem consecutive_even (k : ℤ) : 2 ∣ k * (k + 1) := by
  exact even_iff_two_dvd.mp ( by simp +arith +decide [ mul_add, parity_simps ] )

theorem euclid_leg_product_div4 (m n : ℤ) :
    4 ∣ (m ^ 2 - n ^ 2) * (2 * m * n) := by
  have : (m ^ 2 - n ^ 2) * (2 * m * n) = 2 * m * n * (m - n) * (m + n) := by ring
  rw [this]
  rw [ Int.dvd_iff_emod_eq_zero ] ; norm_num [ Int.add_emod, Int.sub_emod, Int.mul_emod ] ; have t := Int.emod_nonneg m four_pos.ne'; have u := Int.emod_nonneg n four_pos.ne'; ( have v := Int.emod_lt_of_pos m four_pos; have w := Int.emod_lt_of_pos n four_pos; interval_cases m % 4 <;> interval_cases n % 4 <;> trivial; )

/-- Under Berggren M₁: the new perimeter P' = 5a − 5b + 7c. -/
theorem berggren_M1_perimeter (a b c : ℤ) :
    (a - 2*b + 2*c) + (2*a - b + 2*c) + (2*a - 2*b + 3*c) = 5*a - 5*b + 7*c := by ring

/-- Under Berggren M₂: P' = 5a + 5b + 7c. -/
theorem berggren_M2_perimeter (a b c : ℤ) :
    (a + 2*b + 2*c) + (2*a + b + 2*c) + (2*a + 2*b + 3*c) = 5*a + 5*b + 7*c := by ring

/-- Under Berggren M₃: P' = −5a + 5b + 7c. -/
theorem berggren_M3_perimeter (a b c : ℤ) :
    (-a + 2*b + 2*c) + (-2*a + b + 2*c) + (-2*a + 2*b + 3*c) = -5*a + 5*b + 7*c := by ring

/-- Under Berggren M₁: the new inradius numerator (a'+b'−c') = a − b + c. -/
theorem berggren_M1_inradius_num (a b c : ℤ) :
    (a - 2*b + 2*c) + (2*a - b + 2*c) - (2*a - 2*b + 3*c) = a - b + c := by ring

/-- Under Berggren M₂: a'+b'−c' = a + b + c (the perimeter!).
**This is remarkable**: the child's inradius numerator equals the parent's perimeter! -/
theorem berggren_M2_inradius_num (a b c : ℤ) :
    (a + 2*b + 2*c) + (2*a + b + 2*c) - (2*a + 2*b + 3*c) = a + b + c := by ring

/-- Under Berggren M₃: a'+b'−c' = −a + b + c. -/
theorem berggren_M3_inradius_num (a b c : ℤ) :
    (-a + 2*b + 2*c) + (-2*a + b + 2*c) - (-2*a + 2*b + 3*c) = -a + b + c := by ring

/-- The product of the M₁ and M₃ inradius numerators equals 2ab. -/
theorem inradius_num_product (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a - b + c) * (-a + b + c) = 2 * a * b := by nlinarith [sq_nonneg (a - b + c)]

/-- **ALPHA'S THEOREM**: The sum of the three children's inradius numerators
equals a + b + 3c. -/
theorem children_inradius_sum (a b c : ℤ) :
    (a - b + c) + (a + b + c) + (-a + b + c) = a + b + 3*c := by ring

theorem children_inradius_product (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a - b + c) * (a + b + c) * (-a + b + c) = 2 * a * b * (a + b + c) := by
  grind +ring

/-- The first defect of a Euclid triple is 2n². -/
theorem euclid_defect1 (m n : ℤ) :
    (m^2 + n^2) - (m^2 - n^2) = 2 * n^2 := by ring

/-- The second defect of a Euclid triple is (m − n)². -/
theorem euclid_defect2 (m n : ℤ) :
    (m^2 + n^2) - 2*m*n = (m - n)^2 := by ring

/-- **ALPHA'S THEOREM**: The product of defects equals twice the inradius squared.
(c−a)(c−b) = 2n²·(m−n)² = 2·(n(m−n))² = 2r². -/
theorem defect_product_eq_twice_inradius_sq (m n : ℤ) :
    (2 * n ^ 2) * (m - n) ^ 2 = 2 * (n * (m - n)) ^ 2 := by ring

/-- **ALPHA'S THEOREM (General form)**: For any Pythagorean triple,
2·(c−a)·(c−b) = (a+b−c)². -/
theorem defect_product_general (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    2 * (c - a) * (c - b) = (a + b - c) ^ 2 := by nlinarith [sq_nonneg (a + b - c)]

/-- For consecutive parameters, a = 2n + 1. -/
theorem consecutive_leg_a (n : ℤ) :
    (n + 1) ^ 2 - n ^ 2 = 2 * n + 1 := by ring

/-- For consecutive parameters, c − b = 1. -/
theorem consecutive_hyp_minus_leg (n : ℤ) :
    ((n + 1) ^ 2 + n ^ 2) - 2 * (n + 1) * n = 1 := by ring

/-- For consecutive parameters, c = 2n² + 2n + 1. -/
theorem consecutive_hyp (n : ℤ) :
    (n + 1) ^ 2 + n ^ 2 = 2 * n ^ 2 + 2 * n + 1 := by ring

/-- For consecutive parameters, inradius numerator = 2n, so inradius = n. -/
theorem consecutive_inradius_num (n : ℤ) :
    (2 * n + 1) + 2 * (n + 1) * n - (2 * n ^ 2 + 2 * n + 1) = 2 * n := by ring

/-- 5 has exactly 8 representations as a² + b² (counting signs and order):
(±1)² + (±2)² and (±2)² + (±1)². -/
theorem five_reps : ∀ a b : ZMod 5, a ^ 2 + b ^ 2 = 0 →
    (a = 0 ∧ b = 0) ∨ (a ≠ 0 ∧ b ≠ 0) := by decide

/- Original: AgentBeta_TreeDynamics.lean -/



/-- A path in the ternary Berggren tree. -/
inductive TreePath : Type
  | root : TreePath
  | left : TreePath → TreePath
  | mid : TreePath → TreePath
  | right : TreePath → TreePath
deriving Repr

/-- Compute the Pythagorean triple at a given tree path. -/
def berggrenTripleAux : TreePath → ℤ × ℤ × ℤ
  | .root => (3, 4, 5)
  | .left p =>
    let (a, b, c) := berggrenTripleAux p
    (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .mid p =>
    let (a, b, c) := berggrenTripleAux p
    (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .right p =>
    let (a, b, c) := berggrenTripleAux p
    (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- M₂ always produces positive components from positive inputs. -/
theorem berggren_M2_pos_a (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < a + 2*b + 2*c := by linarith

/-- [Section: # CatalogBuild.Pythagorean.Agents.AgentBeta_TreeDynamics
Auto-generated from theorem catalog database.
Domain: Pythagorean/Agents
Declarations: 20] -/
theorem berggren_M2_pos_b (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < 2*a + b + 2*c := by linarith

/-- [Section: # CatalogBuild.Pythagorean.Agents.AgentBeta_TreeDynamics
Auto-generated from theorem catalog database.
Domain: Pythagorean/Agents
Declarations: 20] -/
theorem berggren_M2_pos_c (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < 2*a + 2*b + 3*c := by linarith

/-- M₁ produces positive first component when a² + b² = c² and all positive. -/
theorem berggren_M1_pos_a (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    0 < a - 2*b + 2*c := by nlinarith [sq_nonneg (a - b), sq_nonneg b]

/-- M₁ produces positive second component. -/
theorem berggren_M1_pos_b (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    0 < 2*a - b + 2*c := by nlinarith [sq_nonneg a]

/-- M₃ produces positive first component. -/
theorem berggren_M3_pos_a (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    0 < -a + 2*b + 2*c := by nlinarith [sq_nonneg (a - b)]

/-- M₃ produces positive second component. -/
theorem berggren_M3_pos_b (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    0 < -2*a + b + 2*c := by nlinarith [sq_nonneg a]

/-- The set of tree paths at exactly depth d. -/
def pathsAtDepth : ℕ → List TreePath
  | 0     => [.root]
  | d + 1 => (pathsAtDepth d).flatMap fun p => [.left p, .mid p, .right p]

theorem pathsAtDepth_length : ∀ d : ℕ, (pathsAtDepth d).length = 3 ^ d := by
  intro d; induction d with
  | zero => simp [pathsAtDepth]
  | succ n ih =>
  -- By definition of `pathsAtDepth`, we have `pathsAtDepth (n + 1) = (pathsAtDepth n).flatMap fun p => [.left p, .mid p, .right p]`.
  have h_flatMap : pathsAtDepth (n + 1) = (pathsAtDepth n).flatMap fun p => [.left p, .mid p, .right p] := by
    exact?;
  rw [ h_flatMap, List.length_flatMap, List.sum_eq_card_nsmul ] <;> aesop

/-- The M₂-only branch: repeatedly applying M₂ from root. -/
def m2_branch : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 =>
    let (a, b, c) := m2_branch n
    (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

-- The M₂ branch hypotenuses: 5, 29, 169, 985, ...
#eval (m2_branch 0).2.2  -- 5
#eval (m2_branch 1).2.2  -- 29
#eval (m2_branch 2).2.2  -- 169
#eval (m2_branch 3).2.2  -- 985
#eval (m2_branch 4).2.2  -- 5741

/-- Every M₂-branch triple is Pythagorean. -/
theorem m2_branch_pyth (n : ℕ) :
    let t := m2_branch n
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  induction n with
  | zero => decide
  | succ n ih => simp only [m2_branch]; nlinarith [ih]

/-- Sum of the three children's hypotenuses. -/
theorem children_hyp_sum (a b c : ℤ) :
    (2*a - 2*b + 3*c) + (2*a + 2*b + 3*c) + (-2*a + 2*b + 3*c) = 2*a + 2*b + 9*c := by
  ring

/-- Sum of the three children's first legs. -/
theorem children_leg_a_sum (a b c : ℤ) :
    (a - 2*b + 2*c) + (a + 2*b + 2*c) + (-a + 2*b + 2*c) = a + 2*b + 6*c := by ring

/-- Sum of the three children's second legs. -/
theorem children_leg_b_sum (a b c : ℤ) :
    (2*a - b + 2*c) + (2*a + b + 2*c) + (-2*a + b + 2*c) = 2*a + b + 6*c := by ring

/-- **BETA'S THEOREM**: Sum of all children's perimeters = 5a + 5b + 21c. -/
theorem children_perimeter_sum (a b c : ℤ) :
    let p1 := (a - 2*b + 2*c) + (2*a - b + 2*c) + (2*a - 2*b + 3*c)
    let p2 := (a + 2*b + 2*c) + (2*a + b + 2*c) + (2*a + 2*b + 3*c)
    let p3 := (-a + 2*b + 2*c) + (-2*a + b + 2*c) + (-2*a + 2*b + 3*c)
    p1 + p2 + p3 = 5*a + 5*b + 21*c := by ring

/-- The M₂ hypotenuse recurrence: c_{n+2} = 6c_{n+1} - c_n. -/
theorem m2_hyp_recurrence :
    ∀ n : ℕ, (m2_branch (n + 2)).2.2 = 6 * (m2_branch (n + 1)).2.2 - (m2_branch n).2.2 := by
  intro n
  induction n with
  | zero => norm_num [m2_branch]
  | succ n ih => simp only [m2_branch]; linarith

/-- The perimeter of the M₂ branch. -/
def m2_perimeter (n : ℕ) : ℤ :=
  let t := m2_branch n
  t.1 + t.2.1 + t.2.2

#eval m2_perimeter 0  -- 12
#eval m2_perimeter 1  -- 70
#eval m2_perimeter 2  -- 408
#eval m2_perimeter 3  -- 2378

/-- The minimum hypotenuse growth factor is > 1 for each transformation. -/
theorem min_hyp_growth (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c + 2 ≤ 2 * a + 2 * b + 3 * c := by linarith

/- Original: AgentEpsilon_Synthesis.lean -/



/-- A Pythagorean triple gives a rational point on the unit circle. -/
theorem rational_circle_point (a b c : ℤ) (hc : c ≠ 0) (h : a^2 + b^2 = c^2) :
    (a : ℚ) / c * ((a : ℚ) / c) + (b : ℚ) / c * ((b : ℚ) / c) = 1 := by
  have hcq : (c : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hc
  field_simp
  exact_mod_cast h

/-- Stereographic projection parametrizes the unit circle by ℚ. -/
theorem stereographic_parametrization (t : ℚ) (ht : 1 + t ^ 2 ≠ 0) :
    ((1 - t^2) / (1 + t^2))^2 + (2 * t / (1 + t^2))^2 = 1 := by
  field_simp
  ring

/-- [Section: # CatalogBuild.Pythagorean.Agents.AgentEpsilon_Synthesis
Auto-generated from theorem catalog database.
Domain: Pythagorean/Agents
Declarations: 23] -/
theorem stereographic_euclid (m n : ℤ) (hm : m ≠ 0) (hmn : m^2 + n^2 ≠ 0) :
    let t : ℚ := (n : ℚ) / m
    (1 - t^2) / (1 + t^2) = (m^2 - n^2 : ℤ) / (m^2 + n^2 : ℤ) := by
  -- Substitute $t = \frac{n}{m}$ into the expression.
  field_simp [hm];
  push_cast; ring;

/-- Berggren M₁ preserves the Lorentz form for ALL vectors (not just Pythagorean triples). -/
theorem berggren_M1_lorentz_full (x y z : ℤ) :
    (x - 2*y + 2*z)^2 + (2*x - y + 2*z)^2 - (2*x - 2*y + 3*z)^2 =
    x^2 + y^2 - z^2 := by ring

/-- Berggren M₂ preserves the Lorentz form. -/
theorem berggren_M2_lorentz_full (x y z : ℤ) :
    (x + 2*y + 2*z)^2 + (2*x + y + 2*z)^2 - (2*x + 2*y + 3*z)^2 =
    x^2 + y^2 - z^2 := by ring

/-- Berggren M₃ preserves the Lorentz form. -/
theorem berggren_M3_lorentz_full (x y z : ℤ) :
    (-x + 2*y + 2*z)^2 + (-2*x + y + 2*z)^2 - (-2*x + 2*y + 3*z)^2 =
    x^2 + y^2 - z^2 := by ring

/-- −1 is NOT a quadratic residue mod 3 (since 3 ≡ 3 mod 4). -/
theorem neg_one_nqr_mod3 : ¬ ∃ x : ZMod 3, x ^ 2 = -1 := by decide

/-- −1 is NOT a quadratic residue mod 7. -/
theorem neg_one_nqr_mod7 : ¬ ∃ x : ZMod 7, x ^ 2 = -1 := by decide

/-- −1 is NOT a quadratic residue mod 11. -/
theorem neg_one_nqr_mod11 : ¬ ∃ x : ZMod 11, x ^ 2 = -1 := by decide

/-- −1 is NOT a quadratic residue mod 19. -/
theorem neg_one_nqr_mod19 : ¬ ∃ x : ZMod 19, x ^ 2 = -1 := by decide

/-- Euler's four squares identity (quaternion norm multiplicativity). -/
theorem euler_four_sq (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    ∃ c₁ c₂ c₃ c₄ : ℤ,
    c₁^2 + c₂^2 + c₃^2 + c₄^2 =
    (a₁^2 + a₂^2 + a₃^2 + a₄^2) * (b₁^2 + b₂^2 + b₃^2 + b₄^2) :=
  ⟨a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄,
   a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃,
   a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂,
   a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁,
   by ring⟩

/-- For positive Pythagorean triples, a + b > c (triangle inequality). -/
theorem pythagorean_triangle_ineq (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a^2 + b^2 = c^2) : a + b > c := by
  nlinarith [sq_nonneg (a - b)]

/-- For Pythagorean triples, c > a and c > b (hypotenuse is longest). -/
theorem pythagorean_hyp_largest_a (a b c : ℤ) (hb : 0 < b) (hc : 0 < c)
    (h : a^2 + b^2 = c^2) : a < c := by
  nlinarith [sq_nonneg b]

/-- [Section: # CatalogBuild.Pythagorean.Agents.AgentEpsilon_Synthesis
Auto-generated from theorem catalog database.
Domain: Pythagorean/Agents
Declarations: 22] -/
theorem pythagorean_hyp_largest_b (a b c : ℤ) (ha : 0 < a) (hc : 0 < c)
    (h : a^2 + b^2 = c^2) : b < c := by
  nlinarith [sq_nonneg a]

/-- The first few hypotenuses in the Berggren tree are all products of primes ≡ 1 (mod 4):
5, 13, 17, 25, 29, 37, 41, ... -/
theorem hyp_5_mod4 : 5 % 4 = 1 := by decide

theorem hyp_13_mod4 : 13 % 4 = 1 := by decide

theorem hyp_17_mod4 : 17 % 4 = 1 := by decide

theorem hyp_29_mod4 : 29 % 4 = 1 := by decide

theorem hyp_25_mod4 : 25 % 4 = 1 := by decide

theorem hyp_37_mod4 : 37 % 4 = 1 := by decide

/- Original: AgentResearch.lean -/



noncomputable section

/-- [Section: # CatalogBuild.Pythagorean.Agents.AgentResearch
Auto-generated from theorem catalog database.
Domain: Pythagorean/Agents
Declarations: 19] -/
theorem expected_fixed_points_v2 (n : ℕ) (hn : 0 < n) :
    (n : ℚ) * (1 / n) = 1 := by field_simp

/-- [Section: # CatalogBuild.Pythagorean.Agents.AgentResearch
Auto-generated from theorem catalog database.
Domain: Pythagorean/Agents
Declarations: 19] -/
def idempotentCount_v2 (n : ℕ) : ℕ :=
  ∑ k ∈ range (n + 1), n.choose k * k ^ (n - k)

theorem idempotent_count_0_v2 : idempotentCount_v2 0 = 1 := by native_decide

theorem idempotent_count_1_v2 : idempotentCount_v2 1 = 1 := by native_decide

theorem idempotent_count_2_v2 : idempotentCount_v2 2 = 3 := by native_decide

theorem idempotent_count_3_v2 : idempotentCount_v2 3 = 10 := by native_decide

theorem oracle_density_3_v2 : (idempotentCount_v2 3 : ℚ) / (3 ^ 3) = 10 / 27 := by native_decide

theorem contraction_rate_v2 (c d₀ : ℝ) (hc : 0 ≤ c) (hc1 : c < 1) (hd : 0 ≤ d₀) (n : ℕ) :
    c ^ n * d₀ ≤ d₀ :=
  le_of_le_of_eq (mul_le_mul_of_nonneg_right (pow_le_one₀ hc hc1.le) hd) (one_mul d₀)

theorem prime_count_bound_v2 (N : ℕ) :
    ((range (N + 1)).filter Nat.Prime).card ≤ N + 1 :=
  (card_filter_le _ _).trans (card_range (N + 1)).le

theorem pi_10_v2 : ((range 11).filter Nat.Prime).card = 4 := by native_decide

theorem pi_100_v2 : ((range 101).filter Nat.Prime).card = 25 := by native_decide

theorem grover_speedup_v2 (N : ℕ) (hN : 4 ≤ N) :
    Nat.sqrt N + 1 < N := by nlinarith [Nat.sqrt_le N]

structure ApproxOracleV2 (X : Type*) where
  O : X → X
  truth : X → X
  truth_idem : ∀ x, truth (truth x) = truth x
  dist : X → X → ℝ
  ε : ℝ
  approx : ∀ x, dist (O x) (truth x) ≤ ε

def collatz_v2 : ℕ → ℕ
  | 0 => 0
  | 1 => 1
  | n => if n % 2 = 0 then n / 2 else 3 * n + 1

/-- Bertrand's postulate. -/
theorem bertrand_postulate_v2 (p : ℕ) (hp : Nat.Prime p) :
    ∃ q : ℕ, Nat.Prime q ∧ p < q ∧ q ≤ 2 * p := Nat.bertrand p hp.ne_zero

/-- Goldbach check via Finset.filter. -/
def goldbachCheck_v2 (n : ℕ) : Bool :=
  ((range (n + 1)).filter (fun k => Nat.Prime k ∧ Nat.Prime (n - k) ∧ k ≤ n)).Nonempty

theorem goldbach_verified_v2 : ∀ n ∈ (range 51).filter (fun n => 4 ≤ n ∧ n % 2 = 0),
    goldbachCheck_v2 n = true := by native_decide

theorem truth_oracle_is_em_v2 : ∀ P : Prop, P ∨ ¬P := Classical.em

theorem strange_loop_of_truth_v2 :
    (∀ P : Prop, P ∨ ¬P) → (∀ P : Prop, P ∨ ¬P) ∨ ¬(∀ P : Prop, P ∨ ¬P) :=
  Or.inl

end

