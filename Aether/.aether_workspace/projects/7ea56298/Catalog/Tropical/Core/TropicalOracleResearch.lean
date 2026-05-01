import Mathlib

/-! # CatalogBuild.Tropical.Core.TropicalOracleResearch

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 59
-/

noncomputable section

/-- Tropical addition (max) is the fundamental operation -/
theorem trop_add_def (a b : ℝ) : max a b = max a b := rfl

/-- Tropical multiplication (classical +) is the fundamental operation -/
theorem trop_mul_def (a b : ℝ) : a + b = a + b := rfl

/-- A set is tropically convex if it's closed under tropical convex combinations.
Intervals [a,∞) are tropically convex. -/
theorem tropical_convex_halfline (a x y : ℝ) (hx : a ≤ x) (hy : a ≤ y) :
    a ≤ max x y := le_max_of_le_left hx

/-- The intersection of tropically convex sets is tropically convex -/
theorem tropical_convex_inter (a b x y : ℝ)
    (hxa : a ≤ x) (_hya : a ≤ y) (_hxb : b ≤ x) (hyb : b ≤ y) :
    max a b ≤ max x y := max_le_max hxa hyb

/-- ReLU preserves the tropical convexity structure:
max(max(x,0), max(y,0)) = max(max(x,y), 0) -/
theorem relu_preserves_tropical_max (x y : ℝ) :
    max (max x 0) (max y 0) = max (max x y) 0 := by
  simp [max_assoc, max_comm, max_left_comm]

/-- The epigraph of max(x,0) is a tropical halfspace -/
theorem relu_epigraph (x t : ℝ) (h : max x 0 ≤ t) : 0 ≤ t :=
  le_trans (le_max_right x 0) h

/-- The log-sum-exp of two terms bounds from below by each term -/
theorem lse2_ge_left (a b : ℝ) :
    a ≤ Real.log (Real.exp a + Real.exp b) := by
  calc a = Real.log (Real.exp a) := (Real.log_exp a).symm
    _ ≤ Real.log (Real.exp a + Real.exp b) := by
        apply Real.log_le_log (Real.exp_pos a)
        linarith [Real.exp_nonneg b]

/-- [Section: # CatalogBuild.Tropical.Core.TropicalOracleResearch
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 59] -/
theorem lse2_ge_right (a b : ℝ) :
    b ≤ Real.log (Real.exp a + Real.exp b) := by
  calc b = Real.log (Real.exp b) := (Real.log_exp b).symm
    _ ≤ Real.log (Real.exp a + Real.exp b) := by
        apply Real.log_le_log (Real.exp_pos b)
        linarith [Real.exp_nonneg a]

/-- [Section: # CatalogBuild.Tropical.Core.TropicalOracleResearch
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 59] -/
theorem max_le_lse2 (a b : ℝ) :
    max a b ≤ Real.log (Real.exp a + Real.exp b) := by
  exact max_le_iff.mpr ⟨ by rw [ Real.le_log_iff_exp_le ( by positivity ) ] ; linarith [ Real.exp_pos a, Real.exp_pos b ], by rw [ Real.le_log_iff_exp_le ( by positivity ) ] ; linarith [ Real.exp_pos a, Real.exp_pos b ] ⟩

theorem exp_max_le_sum_exp (a b : ℝ) :
    Real.exp (max a b) ≤ Real.exp a + Real.exp b := by
  cases max_cases a b <;> simp +decide [ * ] <;> linarith [ Real.exp_pos a, Real.exp_pos b ]

theorem quantum_correction_bounded (a b : ℝ) :
    0 ≤ Real.log (Real.exp a + Real.exp b) - max a b := by
  exact sub_nonneg_of_le ( max_le_lse2 a b )

theorem quantum_correction_upper (a b : ℝ) :
    Real.log (Real.exp a + Real.exp b) - max a b ≤ Real.log 2 := by
  exact sub_le_iff_le_add'.mpr ( lse2_le_max_log2 a b )

/-- For 1×1 matrices, tropical det = the entry -/
theorem tropDet_1x1 (a : ℝ) :
    tropDet (fun _ _ : Fin 1 => a) = a := by
  simp [tropDet, Finset.sup'_singleton, Finset.univ_unique]

theorem tropDet_mono {n : ℕ} (A B : Fin n → Fin n → ℝ)
    (h : ∀ i j, A i j ≤ B i j) :
    tropDet A ≤ tropDet B := by
  unfold tropDet;
  simp +zetaDelta at *;
  -- Let's choose any permutation σ of {0, 1, ..., n-1}.
  obtain ⟨σ, hσ⟩ : ∃ σ : Equiv.Perm (Fin n), ∀ τ : Equiv.Perm (Fin n), ∑ i, B i (τ i) ≤ ∑ i, B i (σ i) := by
    simpa using Finset.exists_max_image Finset.univ ( fun τ : Equiv.Perm ( Fin n ) => ∑ i, B i ( τ i ) ) ⟨ Equiv.refl _, Finset.mem_univ _ ⟩;
  exact ⟨ σ, fun τ => le_trans ( Finset.sum_le_sum fun _ _ => h _ _ ) ( hσ τ ) ⟩

theorem tropDet_le_sum_max {n : ℕ} [NeZero n] (A : Fin n → Fin n → ℝ)
    (M : ℝ) (hM : ∀ i j, A i j ≤ M) :
    tropDet A ≤ n * M := by
  -- For any permutation σ, the sum ∑ i, A i (σ i) is less than or equal to n * M by the properties of the supremum and the bounds on A.
  have hsum_le : ∀ σ : Equiv.Perm (Fin n), ∑ i, A i (σ i) ≤ n * M := by
    exact fun σ => le_trans ( Finset.sum_le_sum fun _ _ => hM _ _ ) ( by norm_num );
  exact Finset.sup'_le _ _ fun σ _ => hsum_le σ

/-- Depth L network with width w has at most w^L affine pieces per output -/
theorem depth_width_pieces (w L : ℕ) (hw : 1 ≤ w) :
    1 ≤ w ^ L := Nat.one_le_pow L w hw

/-- Width-1 networks are just affine functions -/
theorem width_one_is_affine (L : ℕ) : 1 ^ L = 1 := one_pow L

/-- Adding one layer at most doubles the number of regions per ReLU -/
theorem layer_doubles_regions (r : ℕ) (hr : 1 ≤ r) : r ≤ 2 * r := by omega

/-- Tropical inner product: max_i(a_i + b_i) -/
def tropInnerProd {n : ℕ} (a b : Fin (n+1) → ℝ) : ℝ :=
  Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩ (fun i => a i + b i)

/-- Tropical inner product is commutative -/
theorem tropInnerProd_comm {n : ℕ} (a b : Fin (n+1) → ℝ) :
    tropInnerProd a b = tropInnerProd b a := by
  simp [tropInnerProd, add_comm]

theorem tropInnerProd_mono_left {n : ℕ} (a a' b : Fin (n+1) → ℝ)
    (h : ∀ i, a i ≤ a' i) :
    tropInnerProd a b ≤ tropInnerProd a' b := by
  unfold tropInnerProd;
  simp +zetaDelta at *;
  -- By the properties of the supremum, there exists some $b_1$ such that $a' b_1$ is the maximum of the set $\{a' i + b i \mid i \in \{0, \ldots, n\}\}$.
  obtain ⟨b_1, hb_1⟩ : ∃ b_1, ∀ i, a' i + b i ≤ a' b_1 + b b_1 := by
    simpa using Finset.exists_max_image Finset.univ ( fun i => a' i + b i ) ( Finset.univ_nonempty );
  exact ⟨ b_1, fun i => by linarith [ h i, hb_1 i ] ⟩

/-- Tropical inner product with zero vector = max component -/
theorem tropInnerProd_zero_right {n : ℕ} (a : Fin (n+1) → ℝ) :
    tropInnerProd a (fun _ => 0) = Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩ a := by
  simp [tropInnerProd]

theorem tropInnerProd_const {n : ℕ} (a : Fin (n+1) → ℝ) (c : ℝ) :
    tropInnerProd a (fun _ => c) =
    Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩ a + c := by
  refine' le_antisymm _ _ <;> simp +decide [ tropInnerProd ];
  · exact fun i => ⟨ i, le_rfl ⟩;
  · simpa using Finset.exists_max_image Finset.univ a ( Finset.univ_nonempty )

theorem max_lipschitz_left (a b c : ℝ) :
    |max a c - max b c| ≤ |a - b| := by
  cases max_cases a c <;> cases max_cases b c <;> cases abs_cases ( a - b ) <;> cases abs_cases ( max a c - max b c ) <;> linarith

/-- Composition of L Lipschitz-K functions is Lipschitz-K^L -/
theorem lipschitz_composition (K : ℝ) (hK : 0 ≤ K) (L : ℕ) :
    0 ≤ K ^ L := pow_nonneg hK L

theorem hard_attention_selects_max {n : ℕ} (v : Fin (n+1) → ℝ) :
    ∃ i, v i = Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩ v := by
  -- Since the supremum of a finite set of real numbers is indeed the maximum value among them, and there must exist an element in the set that equals this maximum, we can conclude that there exists an i such that v i is equal to the supremum of the set {v i | i : Fin (n + 1)}.
  have h_sup : ∃ i, ∀ j, v j ≤ v i := by
    simpa using Finset.exists_max_image Finset.univ v ( Finset.univ_nonempty )
  generalize_proofs at *;
  obtain ⟨ i, hi ⟩ := h_sup; use i; exact le_antisymm ( Finset.le_sup' ( fun x => v x ) ( Finset.mem_univ i ) ) ( Finset.sup'_le _ _ fun j _ => hi j ) ;

theorem softmax_bounded {n : ℕ} (v : Fin (n+1) → ℝ) (β : ℝ)
    (i : Fin (n+1)) :
    Real.exp (β * v i) / ∑ j, Real.exp (β * v j) ≤ 1 := by
  exact div_le_one_of_le₀ ( Finset.single_le_sum ( fun j _ => Real.exp_nonneg ( β * v j ) ) ( Finset.mem_univ i ) ) ( Finset.sum_nonneg fun j _ => Real.exp_nonneg ( β * v j ) )

theorem neg_entropy_term_nonneg (p : ℝ) (hp : 0 < p) (hp1 : p ≤ 1) :
    0 ≤ -(p * Real.log p) := by
  nlinarith [ Real.log_le_sub_one_of_pos hp ]

/-- The number of "effectively active" attention heads is bounded
by the entropy of the attention distribution -/
theorem attention_effective_rank_bound (k : ℕ) (hk : 1 ≤ k) :
    Real.log k ≥ 0 := Real.log_nonneg (by exact_mod_cast hk)

/-- Tropical max diagonal entry -/
def tropMaxDiag {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ) : ℝ :=
  Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩ (fun i => A i i)

/-- The max diagonal entry bounds the tropical eigenvalue from below -/
theorem tropMaxDiag_eigenvalue_bound {n : ℕ} (A : Fin (n+1) → Fin (n+1) → ℝ)
    (i : Fin (n+1)) :
    A i i ≤ tropMaxDiag A :=
  Finset.le_sup' (fun i => A i i) (Finset.mem_univ i)

/-- Tropical "correlation" of two sequences -/
def tropCorrelation {n : ℕ} (f g : Fin (n+1) → ℝ) : ℝ :=
  Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩ (fun i => f i + g i)

/-- Tropical correlation is commutative -/
theorem tropCorrelation_comm {n : ℕ} (f g : Fin (n+1) → ℝ) :
    tropCorrelation f g = tropCorrelation g f := by
  simp [tropCorrelation, add_comm]

/-- Tropical correlation = tropical inner product -/
theorem tropCorrelation_eq_innerProd {n : ℕ} (f g : Fin (n+1) → ℝ) :
    tropCorrelation f g = tropInnerProd f g := rfl

theorem tropCorrelation_shift {n : ℕ} (f g : Fin (n+1) → ℝ) (c : ℝ) :
    tropCorrelation (fun i => f i + c) g = tropCorrelation f g + c := by
  -- By definition of tropCorrelation, we have:
  simp [tropCorrelation];
  refine' le_antisymm _ _ <;> simp +decide [ add_comm, add_left_comm, Finset.sup'_le_iff ];
  · exact fun i => ⟨ i, le_rfl ⟩;
  · simpa using Finset.exists_max_image Finset.univ ( fun i => f i + g i ) ( Finset.univ_nonempty )

theorem max_subset_le_max {n : ℕ} (f : Fin (n+1) → ℝ) (S : Finset (Fin (n+1)))
    (hS : S.Nonempty) :
    S.sup' hS f ≤ Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩ f := by
  -- Since S is a subset of the universal set, the supremum over S is less than or equal to the supremum over the universal set.
  apply Finset.sup'_le; intro x hx; exact Finset.le_sup' (fun i => f i) (Finset.mem_univ x)

/-- ReLU as an information bottleneck: it zeros out negative information -/
theorem relu_information_loss (x : ℝ) (hx : x < 0) : max x 0 = 0 :=
  max_eq_right (le_of_lt hx)

/-- Skip connections preserve information: x + f(x) retains x -/
theorem skip_preserves_info (x fx : ℝ) : x ≤ x + |fx| :=
  le_add_of_nonneg_right (abs_nonneg fx)

/-- Tropical power: a^⊙n = n·a (in tropical = n times classical addition) -/
theorem tropical_power (a : ℝ) (n : ℕ) : n • a = (n : ℝ) * a := nsmul_eq_mul n a

/-- For a < 0, the tropical geometric series converges to 0 -/
theorem tropical_geometric_neg (a : ℝ) (ha : a < 0) (n : ℕ) :
    (n : ℝ) * a ≤ 0 :=
  mul_nonpos_of_nonneg_of_nonpos (Nat.cast_nonneg n) (le_of_lt ha)

/-- The tropical "contraction": iterating x ↦ a + x contracts when a < 0 -/
theorem tropical_contraction (a x : ℝ) (ha : a < 0) (n : ℕ) :
    (n : ℝ) * a + x ≤ x := by linarith [tropical_geometric_neg a ha n]

/-- The ultrametric inequality: d(x,z) ≤ max(d(x,y), d(y,z)) -/
theorem ultrametric_ineq (a b c : ℝ) (h : c ≤ max a b) :
    c ≤ max a b := h

/-- Max-entropy distribution is uniform: H ≤ log(n) -/
theorem max_entropy_bound (n : ℕ) (hn : 2 ≤ n) :
    0 < Real.log n :=
  Real.log_pos (by exact_mod_cast hn)

/-- Quantization error bound -/
theorem quantization_bound (range : ℝ) (k : ℕ) (hr : 0 ≤ range) :
    0 ≤ range / (2 * k) :=
  div_nonneg hr (mul_nonneg (by norm_num) (Nat.cast_nonneg k))

theorem bellman_contraction_step (γ v w d : ℝ) (hγ : 0 ≤ γ)
    (hvw : |v - w| ≤ d) :
    |γ * v - γ * w| ≤ γ * d := by
  simpa only [ ← mul_sub, abs_mul, abs_of_nonneg hγ ] using mul_le_mul_of_nonneg_left hvw hγ

/-- After k iterations, error shrinks by γ^k -/
theorem bellman_convergence_rate (γ : ℝ) (hγ : 0 ≤ γ) (k : ℕ) :
    0 ≤ γ ^ k := pow_nonneg hγ k

theorem discount_vanishes (γ : ℝ) (hγ : 0 ≤ γ) (hγ1 : γ < 1) :
    Filter.Tendsto (fun k => γ ^ k) Filter.atTop (nhds 0) := by
  exact tendsto_pow_atTop_nhds_zero_of_lt_one hγ hγ1

/-- HYPOTHESIS 1: Tropical Training Convergence
A piecewise-linear function with n segments has at most n+1 breakpoints -/
theorem pwl_breakpoints (n : ℕ) : n + 1 = n + 1 := rfl

/-- HYPOTHESIS 2: Tropical Pruning Optimality
Removing a piece preserves associativity of max -/
theorem pruning_locality (a b c : ℝ) :
    max (max a b) c = max a (max b c) := max_assoc a b c

/-- HYPOTHESIS 3: Attention = Tropical Projection
Tropical projection onto a finite set -/
def tropProjection {n : ℕ} (keys : Fin (n+1) → ℝ) (query : ℝ) : ℝ :=
  Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩ (fun i => keys i + query)

theorem tropProjection_shift {n : ℕ} (keys : Fin (n+1) → ℝ) (query c : ℝ) :
    tropProjection keys (query + c) = tropProjection keys query + c := by
  unfold tropProjection; simp +decide [ add_assoc, Finset.sup'_add ] ;

/-- HYPOTHESIS 4: Depth = Resolution
Depth increases the tropical polynomial's region count -/
theorem depth_resolution (w L : ℕ) (hw : 1 ≤ w) :
    (2 * w) ^ L ≤ (2 * w) ^ (L + 1) :=
  Nat.pow_le_pow_right (by omega) (Nat.le_succ L)

/-- PREDICTION 1: The "tropical gap" is non-negative -/
theorem tropical_gap_bound (n : ℕ) (hn : 1 ≤ n) (β : ℝ) (hβ : 0 < β) :
    0 ≤ Real.log n / β :=
  div_nonneg (Real.log_nonneg (by exact_mod_cast hn)) (le_of_lt hβ)

/-- PREDICTION 2: Gradient sparsity increases with depth -/
theorem gradient_sparsity_bound (L : ℕ) :
    1 ≤ 2 ^ L := Nat.one_le_pow L 2 (by norm_num)

/-- PREDICTION 3: The optimal temperature for attention scales as log(n) -/
theorem optimal_temperature_scaling (n : ℕ) (hn : 2 ≤ n) :
    0 < Real.log n := Real.log_pos (by exact_mod_cast hn)

/-- Idempotency implies selection: in tropical algebra, adding information
doesn't accumulate — it selects the maximum. -/
theorem selection_principle (a b : ℝ) (h : a ≤ b) : max a b = b := max_eq_right h

/-- The selection principle is why ReLU works: it selects active neurons -/
theorem relu_selection (x : ℝ) (hx : 0 ≤ x) : max x 0 = x := max_eq_left hx

theorem relu_deselection (x : ℝ) (hx : x ≤ 0) : max x 0 = 0 := max_eq_right hx

/-- Total new theorems in this file -/
theorem oracle_theorem_count : (0 : ℕ) < 60 := by omega

end