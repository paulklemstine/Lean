/-! # CatalogBuild.Algebra.Factoring.OpenResearchTheorems

Auto-generated from theorem catalog database.
Domain: Algebra/Factoring
Declarations: 64
-/

import Mathlib

/-- [Section: ## Ghost Trace Identity (Theorem 1)] -/
theorem ghost_trace (a b c : ℤ) :
    gp a b c + gq a b c + gh a b c = a + b - c := by
  unfold gp gq gh; ring


/-- [Section: # CatalogBuild.Pythagorean.FutureResearch.OpenResearchTheorems
Auto-generated from theorem catalog database.
Domain: Pythagorean/FutureResearch
Declarations: 64] -/
theorem factoring_trace (d e : ℤ) :
    gp d e (d * e) + gq d e (d * e) + gh d e (d * e) = d + e - d * e := by
  unfold gp gq gh; ring


/-- [Section: ## Deficit Preservation] -/
theorem deficit_preservation (a b c : ℤ) :
    deficit (gp a b c) (gq a b c) (gh a b c) = deficit a b c := by
  unfold deficit gp gq gh; ring


theorem linear_triplet_deficit (x N : ℤ) :
    deficit x N (x + N) = -2 * x * N := by
  unfold deficit; ring


/-- [Section: ## Linear Triplet: G maps (x,N,x+N) to (-x,-N,x+N), period 2] -/
theorem linear_triplet_gp (x N : ℤ) : gp x N (x + N) = -x := by unfold gp; ring


theorem linear_triplet_gq (x N : ℤ) : gq x N (x + N) = -N := by unfold gq; ring


theorem linear_triplet_gh (x N : ℤ) : gh x N (x + N) = x + N := by unfold gh; ring


/-- G²(x,N,x+N) formulas (NOT a fixed point; the report's claim was wrong). -/
theorem linear_triplet_sq_p (x N : ℤ) : gp (-x) (-N) (x + N) = -3 * x - 4 * N := by
  unfold gp; ring


theorem linear_triplet_sq_q (x N : ℤ) : gq (-x) (-N) (x + N) = -4 * x - 3 * N := by
  unfold gq; ring


theorem linear_triplet_sq_h (x N : ℤ) : gh (-x) (-N) (x + N) = 5 * x + 5 * N := by
  unfold gh; ring


theorem linear_deficit_dvd_N (x N : ℤ) : (N : ℤ) ∣ deficit x N (x + N) := by
  rw [linear_triplet_deficit]; exact ⟨-2 * x, by ring⟩


/-- [Section: ## Divisor Triplet Analysis] -/
theorem divisor_deficit_factored (d e : ℤ) :
    deficit d e (d * e) = d ^ 2 + e ^ 2 - d ^ 2 * e ^ 2 := by
  unfold deficit; ring


theorem divisor_deficit_alt (d e : ℤ) :
    deficit d e (d * e) = -((d ^ 2 - 1) * (e ^ 2 - 1)) + 1 := by
  unfold deficit; ring


theorem divisor_deficit_neg (d e : ℤ) (hd : 2 ≤ d) (he : 2 ≤ e) :
    deficit d e (d * e) < 0 := by
  unfold deficit
  nlinarith [sq_nonneg (d * e - d), sq_nonneg (d * e - e)]


/-- [Section: ## Deficit-Factor Iff (Theorem 3)] -/
theorem deficit_factor_iff (p q : ℤ) :
    p ∣ deficit p q (p * q) ↔ p ∣ q ^ 2 := by
  have heq : deficit p q (p * q) = p * (p * (1 - q ^ 2)) + q ^ 2 := by
    unfold deficit; ring
  rw [heq]
  exact ⟨fun h => (dvd_add_right (dvd_mul_right p _)).mp h,
         fun h => dvd_add (dvd_mul_right p _) h⟩


/-- [Section: ## Ghost Congruence and Universal Gap] -/
theorem ghost_congruence (a b c : ℤ) :
    (gp a b c) ^ 2 + (gq a b c) ^ 2 =
    (gh a b c) ^ 2 + deficit a b c := by
  unfold gp gq gh deficit; ring


theorem universal_gap (a b c : ℤ) :
    gq a b c - gp a b c = a - b := by
  unfold gp gq; ring


/-- [Section: ## Divisor Ghost Sum] -/
theorem divisor_ghost_sum (d e : ℤ) :
    gp d e (d * e) + gq d e (d * e) = 3 * (d + e) - 4 * (d * e) := by
  unfold gp gq; ring


theorem divisor_ghost_sum_neg (d e : ℤ) (hd : 2 ≤ d) (he : 2 ≤ e) :
    gp d e (d * e) + gq d e (d * e) < 0 := by
  rw [divisor_ghost_sum]; nlinarith


/-- [Section: ## Ghost Map Linearity (Theorem 6)] -/
theorem gp_linear (a₁ b₁ c₁ a₂ b₂ c₂ α β : ℤ) :
    gp (α * a₁ + β * a₂) (α * b₁ + β * b₂) (α * c₁ + β * c₂) =
    α * gp a₁ b₁ c₁ + β * gp a₂ b₂ c₂ := by unfold gp; ring


theorem gq_linear (a₁ b₁ c₁ a₂ b₂ c₂ α β : ℤ) :
    gq (α * a₁ + β * a₂) (α * b₁ + β * b₂) (α * c₁ + β * c₂) =
    α * gq a₁ b₁ c₁ + β * gq a₂ b₂ c₂ := by unfold gq; ring


theorem gh_linear (a₁ b₁ c₁ a₂ b₂ c₂ α β : ℤ) :
    gh (α * a₁ + β * a₂) (α * b₁ + β * b₂) (α * c₁ + β * c₂) =
    α * gh a₁ b₁ c₁ + β * gh a₂ b₂ c₂ := by unfold gh; ring


/-- [Section: ## Multi-Triplet Analysis] -/
theorem multi_triplet_deficit_diff (x₁ x₂ N c₁ c₂ : ℤ) :
    deficit x₁ N c₁ - deficit x₂ N c₂ =
    (x₁ ^ 2 - x₂ ^ 2) - (c₁ ^ 2 - c₂ ^ 2) := by unfold deficit; ring


theorem diff_triplet_deficit (x N : ℤ) :
    deficit x (N - x) N = -2 * x * (N - x) := by unfold deficit; ring


/-- [Section: ## Unit Probe (Theorem 2)] -/
theorem unit_probe_deficit (N : ℤ) : deficit 1 N N = 1 := by unfold deficit; ring


theorem unit_probe_gp (N : ℤ) : gp 1 N N = 1 := by unfold gp; ring


theorem unit_probe_gq (N : ℤ) : gq 1 N N = 2 - N := by unfold gq; ring


theorem unit_probe_gh (N : ℤ) : gh 1 N N = N - 2 := by unfold gh; ring


theorem unit_probe_qh_match (N : ℤ) (hN : 2 ≤ N) :
    |gq 1 N N| = gh 1 N N := by
  rw [unit_probe_gq, unit_probe_gh, abs_of_nonpos (by omega)]; ring


/-- The ghost hypotenuse of unit probe is always < N (no hypothesis needed!). -/
theorem unit_probe_descent' (N : ℤ) : gh 1 N N < N := by
  show -2 * 1 - 2 * N + 3 * N < N; linarith


/-- With the natural hypothesis N ≥ 3, the ghost hypotenuse is positive. -/
theorem unit_probe_gh_pos (N : ℤ) (hN : 3 ≤ N) : 0 < gh 1 N N := by
  show 0 < -2 * 1 - 2 * N + 3 * N; linarith


theorem unit_probe_deficit_invariant (N : ℤ) :
    deficit (gp 1 N N) (gq 1 N N) (gh 1 N N) = deficit 1 N N :=
  deficit_preservation 1 N N


/-- [Section: ## Two-Invariant Product Formula (Theorem 7)] -/
theorem two_invariants_give_product (a b c : ℤ) :
    2 * a * b = (a + b - c) ^ 2 + 2 * (a + b - c) * c - deficit a b c := by
  unfold deficit; ring


/-- [Section: ## Eigenstructure (Theorem 5)] -/
theorem eigenvector_neg1_p : gp 1 (-1) 0 = -(1 : ℤ) := by unfold gp; ring


theorem eigenvector_neg1_q : gq 1 (-1) 0 = -(-1 : ℤ) := by unfold gq; ring


theorem eigenvector_neg1_h : gh 1 (-1) 0 = -(0 : ℤ) := by unfold gh; ring


theorem projection_factor_gap (a b c : ℤ) :
    gq a b c - gp a b c = a - b := by unfold gp gq; ring


theorem ghost_product (a b c : ℤ) :
    gp a b c * gq a b c =
    2 * a ^ 2 + 5 * a * b + 2 * b ^ 2 - 6 * a * c - 6 * b * c + 4 * c ^ 2 := by
  unfold gp gq; ring


/-- The σ-descent for quadruples has a -2σ² correction (Correction 2). -/
theorem quad_descent_correction (a b c d σ : ℤ)
    (hQ : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hσ : 2 * σ = a + b + c - d) :
    (a - σ) ^ 2 + (b - σ) ^ 2 + (c - σ) ^ 2 = (d - σ) ^ 2 - 2 * σ ^ 2 := by
  have h3 : a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2 = 0 := by linarith
  have h4 : d - a - b - c = -(2 * σ) := by linarith
  have h5 : σ * (d - a - b - c) = -(2 * σ ^ 2) := by rw [h4]; ring
  nlinarith


/-- The correct k=4 identity (no σ correction needed). -/
theorem k4_algebraic_identity (a b c d : ℤ)
    (hQ : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - b - c) ^ 2 + (d - a - c) ^ 2 + (d - a - b) ^ 2 = (2 * d - a - b - c) ^ 2 := by
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg d,
             sq_nonneg (a - b), sq_nonneg (a - c), sq_nonneg (b - c)]


theorem ghost_matrix_det : Matrix.det ghostMatrix = -1 := by native_decide


theorem ghost_char_poly_eval_neg1 :
    (-1 : ℤ) ^ 3 - 5 * (-1 : ℤ) ^ 2 - 5 * (-1 : ℤ) + 1 = 0 := by norm_num


theorem ghost_matrix_trace_val :
    ghostMatrix 0 0 + ghostMatrix 1 1 + ghostMatrix 2 2 = 5 := by native_decide


/-- [Section: ## Deficit Negation Invariance] -/
theorem neg_deficit_invariant_a (a b c : ℤ) :
    deficit (-a) b c = deficit a b c := by unfold deficit; ring


theorem neg_deficit_invariant_b (a b c : ℤ) :
    deficit a (-b) c = deficit a b c := by unfold deficit; ring


/-- [Section: ## Concrete Ghost Orbits] -/
theorem ghost_345_p : gp 3 4 5 = 1 := by native_decide


theorem ghost_345_q : gq 3 4 5 = 0 := by native_decide


theorem ghost_345_h : gh 3 4 5 = 1 := by native_decide


theorem ghost_sq_345_p : gp 1 0 1 = -1 := by native_decide


theorem ghost_sq_345_q : gq 1 0 1 = 0 := by native_decide


theorem ghost_sq_345_h : gh 1 0 1 = 1 := by native_decide


theorem ghost_cube_345_p : gp (-1) 0 1 = -3 := by native_decide


theorem ghost_cube_345_q : gq (-1) 0 1 = -4 := by native_decide


theorem ghost_cube_345_h : gh (-1) 0 1 = 5 := by native_decide


/-- Correction 1: Signed ghost map does NOT have period 2 on (3,4,5). -/
theorem period2_false_signed :
    ¬(gp (-1) 0 1 = gp 3 4 5 ∧ gq (-1) 0 1 = gq 3 4 5) := by
  unfold gp gq; omega


/-- [Section: ## Characteristic Polynomial] -/
theorem char_poly_factorization (x : ℤ) :
    x ^ 3 - 5 * x ^ 2 - 5 * x + 1 = (x + 1) * (x ^ 2 - 6 * x + 1) := by ring


theorem eigenvalue_product_exact :
    (-1 : ℤ) * (3 ^ 2 - (2 : ℤ) ^ 2 * 2) = -1 := by norm_num


/-- [Section: ## Ghost Squared Formulas] -/
theorem ghost_sq_p (a b c : ℤ) :
    gp (gp a b c) (gq a b c) (gh a b c) = 9 * a + 8 * b - 12 * c := by
  unfold gp gq gh; ring


theorem ghost_sq_q (a b c : ℤ) :
    gq (gp a b c) (gq a b c) (gh a b c) = 8 * a + 9 * b - 12 * c := by
  unfold gp gq gh; ring


theorem ghost_sq_h (a b c : ℤ) :
    gh (gp a b c) (gq a b c) (gh a b c) = -12 * a - 12 * b + 17 * c := by
  unfold gp gq gh; ring


/-- [Section: ## Divisor Triplet Ghost Formulas] -/
theorem divisor_gp (d e : ℤ) :
    gp d e (d * e) = d + 2 * e - 2 * d * e := by unfold gp; ring


theorem divisor_gq (d e : ℤ) :
    gq d e (d * e) = 2 * d + e - 2 * d * e := by unfold gq; ring


theorem divisor_gh (d e : ℤ) :
    gh d e (d * e) = -2 * d - 2 * e + 3 * d * e := by unfold gh; ring


theorem divisor_ghost_gap (d e : ℤ) :
    gq d e (d * e) - gp d e (d * e) = d - e := by unfold gp gq; ring


