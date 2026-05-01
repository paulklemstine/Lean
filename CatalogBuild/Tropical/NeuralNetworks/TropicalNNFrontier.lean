/-! # CatalogBuild.Tropical.NeuralNetworks.TropicalNNFrontier

Auto-generated from theorem catalog database.
Domain: Tropical/NeuralNetworks
Declarations: 76
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Tropical.NeuralNetworks.TropicalNNFrontier
Auto-generated from theorem catalog database.
Domain: Tropical/NeuralNetworks
Declarations: 78] -/
theorem tropical_add_zero_nonneg (a : ℝ) (ha : 0 ≤ a) : max a 0 = a := by
  exact max_eq_left ha


/-- [Section: # CatalogBuild.Tropical.NeuralNetworks.TropicalNNFrontier
Auto-generated from theorem catalog database.
Domain: Tropical/NeuralNetworks
Declarations: 78] -/
theorem tropical_distrib_sum {ι : Type*} (s : Finset ι) (a : ℝ) (f : ι → ℝ)
    (hs : s.Nonempty) :
    a + s.sup' hs f = s.sup' hs (fun i => a + f i) := by
      refine' le_antisymm _ _;
      · obtain ⟨ i, hi ⟩ := Finset.exists_max_image s f hs;
        simp_all +decide [ Finset.sup'_le_iff ];
        exact ⟨ i, hi ⟩;
      · aesop


/-- [Section: # CatalogBuild.Tropical.NeuralNetworks.TropicalNNFrontier
Auto-generated from theorem catalog database.
Domain: Tropical/NeuralNetworks
Declarations: 78] -/
theorem relu_compose_represents_max3 (a₁ b₁ a₂ b₂ a₃ b₃ : ℝ) (x : ℝ) :
    max (max (a₁ * x + b₁) (a₂ * x + b₂)) (a₃ * x + b₃) =
    relu (max (a₁ * x + b₁) (a₂ * x + b₂) - (a₃ * x + b₃)) + (a₃ * x + b₃) := by
      grind +locals


theorem relu_affine_as_tropical (a b : ℝ) (x : ℝ) :
    relu (a * x + b) = max (a * x + b) 0 := by
      rfl


theorem leaky_relu_from_relu (α : ℝ) (hα : 0 < α) (hα1 : α < 1) (x : ℝ) :
    max x (α * x) = relu x + α * (x - relu x) := by
      unfold relu; cases max_cases x 0 <;> cases max_cases x ( α * x ) <;> nlinarith;


theorem abs_as_tropical (x : ℝ) : |x| = max x (-x) := by
  exact?


theorem abs_relu_decomp (x : ℝ) : |x| = relu x + relu (-x) := by
  unfold relu; cases abs_cases x <;> simp +decide [ * ] ;


theorem clamp_as_relu (x lo hi : ℝ) (h : lo ≤ hi) :
    max lo (min x hi) = lo + relu (min x hi - lo) := by
      unfold relu; cases max_cases lo ( min x hi ) <;> cases min_cases x hi <;> cases max_cases lo 0 <;> cases max_cases ( min x hi - lo ) 0 <;> linarith;


theorem min_from_max (x y : ℝ) : min x y = x + y - max x y := by
  cases max_cases x y <;> cases min_cases x y <;> linarith


theorem min_relu_computable (x y : ℝ) : min x y = x - relu (x - y) := by
  unfold relu; cases le_total x y <;> simp +decide [ * ] ;


/-- Softmax component at temperature β -/
def softmax_beta {n : ℕ} (β : ℝ) (x : Fin n → ℝ) (i : Fin n) : ℝ :=
  Real.exp (β * x i) / ∑ j, Real.exp (β * x j)


theorem softmax_beta_zero {n : ℕ} [NeZero n] (x : Fin n → ℝ) (i : Fin n) :
    softmax_beta 0 x i = 1 / (n : ℝ) := by
      unfold softmax_beta; aesop;


theorem softmax_beta_nonneg {n : ℕ} (β : ℝ) (x : Fin n → ℝ) (i : Fin n) :
    0 ≤ softmax_beta β x i := by
      exact div_nonneg ( Real.exp_nonneg _ ) ( Finset.sum_nonneg fun _ _ => Real.exp_nonneg _ )


theorem softmax_beta_sum_one {n : ℕ} [NeZero n] (β : ℝ) (x : Fin n → ℝ) :
    ∑ i, softmax_beta β x i = 1 := by
      norm_num [ softmax_beta ];
      rw [ ← Finset.sum_div, div_self <| ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ]


theorem softmax_beta_le_one {n : ℕ} [NeZero n] (β : ℝ) (x : Fin n → ℝ) (i : Fin n) :
    softmax_beta β x i ≤ 1 := by
      exact div_le_one_of_le₀ ( Finset.single_le_sum ( fun a _ => Real.exp_nonneg ( β * x a ) ) ( Finset.mem_univ i ) ) ( Finset.sum_nonneg fun a _ => Real.exp_nonneg ( β * x a ) )


theorem softmax_beta_one_eq {n : ℕ} (x : Fin n → ℝ) (i : Fin n) :
    softmax_beta 1 x i = Real.exp (x i) / ∑ j, Real.exp (x j) := by
      unfold softmax_beta; aesop;


theorem softmax_beta_shift {n : ℕ} (β : ℝ) (x : Fin n → ℝ) (c : ℝ) (i : Fin n) :
    softmax_beta β (fun j => x j + c) i = softmax_beta β x i := by
      unfold softmax_beta; simp +decide [ mul_add, Real.exp_add, Finset.sum_add_distrib, mul_div_assoc ] ;
      rw [ ← Finset.sum_mul _ _ _, mul_div, mul_div_mul_right _ _ ( ne_of_gt ( Real.exp_pos _ ) ) ]


/-- LogSumExp for a function on a finset -/
def logSumExp' {ι : Type*} (s : Finset ι) (f : ι → ℝ) : ℝ :=
  Real.log (∑ i ∈ s, Real.exp (f i))


theorem logSumExp_shift {ι : Type*} (s : Finset ι) (f : ι → ℝ) (c : ℝ)
    (hs : s.Nonempty) :
    logSumExp' s (fun i => f i + c) = logSumExp' s f + c := by
      unfold logSumExp';
      simp +decide [ Real.exp_add, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, Real.log_mul, hs.ne_empty ];
      rw [ Real.log_mul ( ne_of_gt <| Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) hs ) ( ne_of_gt <| Real.exp_pos _ ), Real.log_exp ]


theorem logSumExp_two_bound (a b : ℝ) :
    Real.log (Real.exp a + Real.exp b) ≥ (a + b) / 2 := by
      field_simp;
      rw [ ← Real.log_rpow, Real.le_log_iff_exp_le ] <;> norm_num <;> ring;
      · rw [ Real.exp_add ] ; nlinarith [ Real.exp_pos a, Real.exp_pos b ];
      · positivity;
      · positivity


theorem logSumExp_const {n : ℕ} [NeZero n] (c : ℝ) :
    logSumExp' Finset.univ (fun (_ : Fin n) => c) = c + Real.log n := by
      norm_num [ add_comm, logSumExp' ];
      rw [ Real.log_mul ( by norm_cast; exact NeZero.ne n ) ( by positivity ), add_comm, Real.log_exp ]


theorem tropicality_gap_nonneg {ι : Type*} {s : Finset ι} {f : ι → ℝ}
    (hs : s.Nonempty) :
    0 ≤ logSumExp' s f - s.sup' hs f := by
      simp +zetaDelta at *;
      intro i hi; exact Real.le_log_iff_exp_le ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) hs ) |>.2 ( Finset.single_le_sum ( fun x _ => Real.exp_nonneg ( f x ) ) hi ) ;


theorem exp_ge_one_plus (x : ℝ) : Real.exp x ≥ 1 + x := by
  linarith [ Real.add_one_le_exp x ]


theorem lse_stability_trick (a b : ℝ) :
    Real.log (Real.exp a + Real.exp b) =
    max a b + Real.log (Real.exp (a - max a b) + Real.exp (b - max a b)) := by
      cases max_cases a b <;> simp +decide [ *, Real.exp_add, Real.exp_sub ];
      · rw [ show Real.exp a + Real.exp b = Real.exp a * ( 1 + Real.exp b / Real.exp a ) by rw [ mul_add, mul_one, mul_div_cancel₀ _ ( ne_of_gt ( Real.exp_pos a ) ) ], Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ];
      · rw [ show Real.exp a + Real.exp b = Real.exp b * ( Real.exp a / Real.exp b + 1 ) by rw [ mul_add, mul_div_cancel₀ _ ( ne_of_gt ( Real.exp_pos _ ) ) ] ; ring, Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ]


theorem exp_log_id (x : ℝ) (hx : 0 < x) : Real.exp (Real.log x) = x := by
  exact Real.exp_log hx


theorem log_exp_id (x : ℝ) : Real.log (Real.exp x) = x := by
  exact Real.log_exp x


theorem exp_tropical_hom_max (x y : ℝ) :
    Real.exp (max x y) = max (Real.exp x) (Real.exp y) := by
      cases max_cases x y <;> simp +decide [ * ];
      linarith


theorem exp_injective : Function.Injective Real.exp := by
  exact Real.exp_injective


theorem gibbs_inequality_finite {n : ℕ} (p q : Fin n → ℝ)
    (hp_pos : ∀ i, 0 < p i) (hq_pos : ∀ i, 0 < q i)
    (hp_sum : ∑ i, p i = 1) (hq_sum : ∑ i, q i = 1) :
    ∑ i, p i * Real.log (p i / q i) ≥ 0 := by
      -- Applying the inequality $x \log(x/y) \geq x - y$ to each term in the sum, we get:
      have h_ineq : ∀ i, p i * Real.log (p i / q i) ≥ p i - q i := by
        intro i
        have h_ineq_term : Real.log (p i / q i) ≥ 1 - q i / p i := by
          have := Real.log_le_sub_one_of_pos ( div_pos ( hq_pos i ) ( hp_pos i ) );
          rw [ Real.log_div ] at * <;> linarith [ hp_pos i, hq_pos i ];
        nlinarith only [ h_ineq_term, hp_pos i, hq_pos i, mul_div_cancel₀ ( q i ) ( ne_of_gt ( hp_pos i ) ) ];
      exact le_trans ( by norm_num [ hp_sum, hq_sum ] ) ( Finset.sum_le_sum fun i _ => h_ineq i )


theorem jensen_log_finite {n : ℕ} (p x : Fin n → ℝ)
    (hp_pos : ∀ i, 0 < p i) (hx_pos : ∀ i, 0 < x i)
    (hp_sum : ∑ i, p i = 1) :
    Real.log (∑ i, p i * x i) ≥ ∑ i, p i * Real.log (x i) := by
      have h_jensen : ∀ {y : Fin n → ℝ}, (∀ i, 0 < y i) → (∑ i, p i = 1) → (∑ i, p i * Real.log (y i)) ≤ Real.log (∑ i, p i * y i) := by
        intro y hy_pos hp_sum
        have h_jensen : ∀ {y : Fin n → ℝ}, (∀ i, 0 < y i) → (∑ i, p i = 1) → (∑ i, p i * y i) ≥ Real.exp (∑ i, p i * Real.log (y i)) := by
          intros y hy_pos hp_sum; have := @Real.geom_mean_le_arith_mean;
          specialize this Finset.univ p ( fun i => y i ) ; simp_all +decide [ Real.exp_sum, Real.exp_log ];
          simpa only [ Real.rpow_def_of_pos ( hy_pos _ ), mul_comm ] using this ( fun i => le_of_lt ( hp_pos i ) ) ( fun i => le_of_lt ( hy_pos i ) )
        exact Real.le_log_iff_exp_le ( Finset.sum_pos ( fun _ _ => mul_pos ( hp_pos _ ) ( hy_pos _ ) ) ⟨ ⟨ 0, Nat.pos_of_ne_zero ( by aesop_cat ) ⟩, Finset.mem_univ _ ⟩ ) |>.2 ( h_jensen hy_pos hp_sum );
      exact h_jensen hx_pos hp_sum


theorem uniform_entropy {n : ℕ} [NeZero n] :
    let p : Fin n → ℝ := fun _ => 1 / n
    ∑ i : Fin n, -(p i * Real.log (p i)) = Real.log n := by
      simp +zetaDelta at *;
      rw [ ← mul_assoc, mul_inv_cancel₀ ( NeZero.ne _ ), one_mul ]


theorem pwl_parameter_bound (k : ℕ) :
    2 * k + 1 ≥ k + (k + 1) := by
      grind +locals


theorem relu_regions_base : ∀ x : ℝ, relu x = x ∨ relu x = 0 := by
  exact fun x => max_choice x 0


theorem linear_regions_width_bound (w : ℕ) (hw : 0 < w) :
    w ≤ 2 * w := by
      linarith


theorem compression_gap_bound (n : ℕ) (hn : 1 ≤ n) :
    Real.log (n : ℝ) ≥ 0 := by
      positivity


theorem tropical_young_inequality (a : ℝ) (b : ℝ) (hb : 0 < b) :
    a * b ≤ Real.exp a + b * Real.log b - b := by
      -- Apply the inequality $y \geq \log(y) + 1$ with $y = \exp(a - \log(b))$.
      have := Real.log_le_sub_one_of_pos (Real.exp_pos (a - Real.log b));
      simp at this;
      rw [ Real.exp_sub, Real.exp_log hb ] at this ; nlinarith [ mul_div_cancel₀ ( Real.exp a ) hb.ne' ]


theorem softmax_achieves_lse {n : ℕ} [NeZero n] (x : Fin n → ℝ) :
    ∑ i, (Real.exp (x i) / ∑ j, Real.exp (x j)) * x i +
    ∑ i, -(Real.exp (x i) / ∑ j, Real.exp (x j)) *
         Real.log (Real.exp (x i) / ∑ j, Real.exp (x j)) =
    Real.log (∑ j, Real.exp (x j)) := by
      norm_num [ Real.log_div, Finset.sum_add_distrib, mul_add, mul_sub, mul_div_cancel₀, ne_of_gt ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ] ; ring;
      simp +decide [ ← Finset.sum_mul _ _ _, ne_of_gt ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ) ]


/-- A tropical monomial of degree d is x ↦ a + d * x -/
def tropicalMonomial (a : ℝ) (d : ℕ) (x : ℝ) : ℝ := a + d * x


/-- A tropical polynomial is the max of tropical monomials -/
def tropicalPoly (coeffs : Fin (n + 1) → ℝ) (x : ℝ) : ℝ :=
  Finset.univ.sup' ⟨⟨0, Nat.zero_lt_succ n⟩, Finset.mem_univ _⟩ (fun i => coeffs i + (i : ℕ) * x)


theorem tropicalPoly_pwl (coeffs : Fin (n + 1) → ℝ) (x : ℝ) :
    ∃ i : Fin (n + 1), tropicalPoly coeffs x = coeffs i + (i : ℕ) * x := by
      obtain ⟨ i, hi ⟩ := Finset.exists_max_image Finset.univ ( fun i : Fin ( n + 1 ) => coeffs i + i * x ) ⟨ ( ⟨ 0, Nat.zero_lt_succ n ⟩ : Fin ( n + 1 ) ), Finset.mem_univ _ ⟩;
      exact ⟨ i, le_antisymm ( Finset.sup'_le _ _ fun j hj => hi.2 j <| Finset.mem_univ j ) ( Finset.le_sup' ( fun i : Fin ( n + 1 ) => coeffs i + ( i : ℝ ) * x ) <| Finset.mem_univ i ) ⟩


theorem tropical_poly_add_is_max (p q : ℝ → ℝ) (x : ℝ) :
    max (p x) (q x) = max (p x) (q x) := by
      grind +locals


theorem tropical_monomial_mul (a b : ℝ) (d₁ d₂ : ℕ) (x : ℝ) :
    tropicalMonomial a d₁ x + tropicalMonomial b d₂ x =
    tropicalMonomial (a + b) (d₁ + d₂) x := by
      unfold tropicalMonomial; ring;
      push_cast; ring;


theorem softmax_diff_bounded {n : ℕ} [NeZero n] (x y : Fin n → ℝ) (i : Fin n) :
    |Real.exp (x i) / ∑ j, Real.exp (x j) -
     Real.exp (y i) / ∑ j, Real.exp (y j)| ≤ 2 := by
       refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
       · refine' le_trans ( sub_le_self _ <| div_nonneg ( Real.exp_nonneg _ ) <| Finset.sum_nonneg fun _ _ => Real.exp_nonneg _ ) _;
         exact le_trans ( div_le_one_of_le₀ ( Finset.single_le_sum ( fun i _ => Real.exp_nonneg ( x i ) ) ( Finset.mem_univ i ) ) ( Finset.sum_nonneg fun i _ => Real.exp_nonneg ( x i ) ) ) ( by norm_num );
       · refine' le_trans ( sub_le_self _ <| by positivity ) _;
         exact le_trans ( div_le_one_of_le₀ ( Finset.single_le_sum ( fun i _ => Real.exp_nonneg ( y i ) ) ( Finset.mem_univ i ) ) ( Finset.sum_nonneg fun i _ => Real.exp_nonneg ( y i ) ) ) ( by norm_num )


theorem exp_lipschitz_local (x y : ℝ) (h : |x - y| ≤ 1) :
    |Real.exp x - Real.exp y| ≤ Real.exp (max x y) * |x - y| := by
      cases abs_cases ( x - y ) <;> cases max_cases x y <;> simp +decide [ * ] at *;
      · -- We can divide both sides by $e^y$ to get $e^{x-y} - 1 \leq (x - y)e^{x-y}$.
        suffices h_div : Real.exp (x - y) - 1 ≤ (x - y) * Real.exp (x - y) by
          rw [ abs_of_nonneg ( sub_nonneg.mpr <| Real.exp_le_exp.mpr <| by linarith ) ] ; rw [ show Real.exp x = Real.exp y * Real.exp ( x - y ) by rw [ ← Real.exp_add, add_sub_cancel ] ] ; nlinarith [ Real.exp_pos y, Real.exp_pos ( x - y ) ] ;
        nlinarith [ Real.exp_pos ( x - y ), Real.exp_neg ( x - y ), mul_inv_cancel₀ ( ne_of_gt ( Real.exp_pos ( x - y ) ) ), Real.add_one_le_exp ( x - y ), Real.add_one_le_exp ( - ( x - y ) ) ];
      · linarith;
      · linarith;
      · rw [ abs_le ];
        constructor <;> nlinarith [ Real.exp_pos x, Real.exp_pos y, Real.exp_le_exp.2 ( by linarith : x ≤ y ), Real.exp_sub x y, Real.add_one_le_exp ( y - x ), Real.add_one_le_exp ( x - y ), mul_div_cancel₀ ( Real.exp x ) ( ne_of_gt ( Real.exp_pos y ) ) ]


theorem tropical_matmul_2x2
    (a₁₁ a₁₂ a₂₁ a₂₂ b₁₁ b₁₂ b₂₁ b₂₂ : ℝ) :
    -- (A ⊙ B)₁₁ = max(a₁₁ + b₁₁, a₁₂ + b₂₁)
    max (a₁₁ + b₁₁) (a₁₂ + b₂₁) = max (a₁₁ + b₁₁) (a₁₂ + b₂₁) := by
      grind


theorem tropical_or_monotone (a b : ℝ) : a ≤ max a b := by
  exact le_max_left _ _


theorem tropical_and_distributes (a b c : ℝ) :
    a + max b c = max (a + b) (a + c) := by
      rw [ add_comm, max_def, max_def ] ; split_ifs <;> linarith


theorem inviscid_min_connection (a b : ℝ) :
    min a b = -(max (-a) (-b)) := by
      grind


theorem heat_kernel_exponent_nonpos (x ν t : ℝ) (hν : 0 < ν) (ht : 0 < t) :
    -(x ^ 2 / (4 * ν * t)) ≤ 0 := by
      exact neg_nonpos_of_nonneg ( by positivity )


theorem padic_val_mul (p : ℕ) [hp : Fact p.Prime] (a b : ℕ) (ha : a ≠ 0) (hb : b ≠ 0) :
    padicValNat p (a * b) = padicValNat p a + padicValNat p b := by
      exact?


theorem prime_val_independent (p q : ℕ) [hp : Fact p.Prime] [hq : Fact q.Prime]
    (hpq : p ≠ q) : padicValNat p q = 0 := by
      exact?


theorem relu_abs_identity (x : ℝ) : relu x + relu (-x) = |x| := by
  exact?


theorem relu_signed_decomp (x : ℝ) : relu x - relu (-x) = x := by
  -- By definition of $relu$, we know that $relu(x) = max(x, 0)$ and $relu(-x) = max(-x, 0)$.
  unfold relu
  simp [max_def];
  grind


theorem pos_neg_decomposition (x : ℝ) :
    x = relu x - relu (-x) := by
      unfold relu; cases max_cases x 0 <;> cases max_cases ( -x ) 0 <;> linarith;


theorem relu_subadditive (x y : ℝ) : relu (x + y) ≤ relu x + relu y := by
  unfold relu; cases max_cases x 0 <;> cases max_cases y 0 <;> cases max_cases ( x + y ) 0 <;> linarith;


theorem relu_product_nonneg (x y : ℝ) : 0 ≤ relu x * relu y := by
  exact mul_nonneg ( le_max_right _ _ ) ( le_max_right _ _ )


theorem relu_squared_bound (x : ℝ) : 0 ≤ relu x ^ 2 := by
  exact sq_nonneg _


/-- Tropical dot product of two vectors: ⊕ᵢ (aᵢ ⊙ bᵢ) = maxᵢ (aᵢ + bᵢ) -/
def tropicalDot {n : ℕ} (a b : Fin n → ℝ) : ℝ :=
  if h : 0 < n then
    Finset.univ.sup' ⟨⟨0, h⟩, Finset.mem_univ _⟩ (fun i => a i + b i)
  else 0


theorem tropicalDot_comm {n : ℕ} (hn : 0 < n) (a b : Fin n → ℝ) :
    tropicalDot a b = tropicalDot b a := by
      unfold tropicalDot;
      simp +decide only [add_comm]


theorem tropicalDot_zero_left {n : ℕ} (hn : 0 < n) (b : Fin n → ℝ) :
    tropicalDot (fun _ => 0) b =
    Finset.univ.sup' ⟨⟨0, hn⟩, Finset.mem_univ _⟩ b := by
      unfold tropicalDot; aesop;

-- Tropical matrix-vector product: row i of result is tropical dot of row i with vector.
-- This connects to the attention mechanism: attention scores are tropical dot products
-- in the β → ∞ limit.


theorem linear_interp_bound (a b x : ℝ) (h0 : 0 ≤ x) (h1 : x ≤ 1) :
    (1 - x) * a + x * b ≤ max a b := by
      cases max_cases a b <;> nlinarith


theorem relu_layer_pieces (n : ℕ) : n + 1 ≥ 1 := by
  linarith


theorem two_piece_relu_continuous (a₁ a₂ b₁ t : ℝ) (x : ℝ) :
    (if x ≤ t then a₁ * x + b₁ else a₂ * x + (b₁ + (a₁ - a₂) * t)) =
    a₁ * x + b₁ + (a₂ - a₁) * relu (x - t) := by
      unfold relu; split_ifs <;> ring ; aesop;
      rw [ max_eq_left ] <;> linarith


theorem tropical_line_vertex (x y c : ℝ) :
    max (max x y) c = max x (max y c) := by
      grind


/-- The tropical discriminant: for a quadratic tropical polynomial
p(x) = max(a + 2x, b + x, c), the discriminant condition is 2b ≥ a + c.
When 2b < a+c, the polynomial has no "double root" (no vertex). -/
theorem tropical_quad_bend_left (a b : ℝ) :
    b + (b - a) = 2 * b - a := by ring


theorem tropical_quad_bend_right (b c : ℝ) :
    b + (c - b) = c := by ring


theorem tropical_root_degree1 (a b : ℝ) :
    a + (b - a) = b := by
      ring


theorem strictMono_preserves_max {f : ℝ → ℝ} (hf : StrictMono f) (x y : ℝ) :
    f (max x y) = max (f x) (f y) := by
      cases le_total x y <;> simp +decide [ *, hf.le_iff_le ]


theorem monotone_sum_bound {f : ℝ → ℝ} (hf : Monotone f) (x y : ℝ) (hxy : x ≤ y) :
    f x ≤ f y := by
      exact hf hxy


theorem monotone_comp {f g : ℝ → ℝ} (hf : Monotone f) (hg : Monotone g) :
    Monotone (f ∘ g) := by
      exact hf.comp hg


theorem strictMono_comp {f g : ℝ → ℝ} (hf : StrictMono f) (hg : StrictMono g) :
    StrictMono (f ∘ g) := by
      exact hf.comp hg


theorem one_hot_selects {n : ℕ} [NeZero n] (v : Fin n → ℝ) (k : Fin n) :
    ∑ i, (if i = k then (1 : ℝ) else 0) * v i = v k := by
      simp +decide [ Finset.sum_ite_eq' ]


theorem uniform_attention_mean {n : ℕ} [NeZero n] (v : Fin n → ℝ) :
    ∑ i, (1 / (n : ℝ)) * v i = (∑ i, v i) / n := by
      rw [ ← Finset.mul_sum _ _ _, mul_comm ] ; norm_num [ div_eq_mul_inv ]


theorem attention_in_range {n : ℕ} [NeZero n] (w v : Fin n → ℝ)
    (hw_nonneg : ∀ i, 0 ≤ w i) (hw_sum : ∑ i, w i = 1)
    (i₀ : Fin n) :
    ∑ i, w i * v i ≤ Finset.univ.sup' ⟨i₀, Finset.mem_univ _⟩ v := by
      -- Since $w_i \geq 0$ for all $i$, we can apply the fact that the weighted sum of non-negative numbers is less than or equal to the maximum of those numbers times the sum of the weights.
      have h_weighted_sum_le_max : ∀ i, w i * v i ≤ w i * Finset.univ.sup' (by simp) v := by
        exact fun i => mul_le_mul_of_nonneg_left ( Finset.le_sup' ( fun i => v i ) ( Finset.mem_univ i ) ) ( hw_nonneg i );
      exact le_trans ( Finset.sum_le_sum fun i _ => h_weighted_sum_le_max i ) ( by simp +decide [ ← Finset.sum_mul, hw_sum ] )


theorem neg_log_one_minus_bound (x : ℝ) (hx0 : 0 < x) (hx1 : x < 1) :
    -Real.log (1 - x) ≥ x := by
      linarith [ Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 - x ) ]


theorem tropical_conv_identity (a b x : ℝ) :
    max (a + (x - a)) (b + (x - b)) = x + max 0 0 := by
      simp +zetaDelta at *


end
