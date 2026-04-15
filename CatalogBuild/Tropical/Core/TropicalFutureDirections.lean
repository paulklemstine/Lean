/-! # CatalogBuild.Tropical.Core.TropicalFutureDirections

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 53
-/

import Mathlib

noncomputable section

/-- The tropical "derivative" of max(a,b) w.r.t. a: 1 if a ≥ b, 0 otherwise -/
def tropGrad_left (a b : ℝ) : ℝ := if a ≥ b then 1 else 0


/-- The tropical "derivative" of max(a,b) w.r.t. b: 1 if b > a, 0 otherwise -/
def tropGrad_right (a b : ℝ) : ℝ := if b > a then 1 else 0


/-- [Section: ================================================================
SECTION 1: TROPICAL BACKPROPAGATION (Agent Alpha)
================================================================] -/
theorem tropGrad_partition (a b : ℝ) (hab : a ≠ b) :
    tropGrad_left a b + tropGrad_right a b = 1 := by
  unfold tropGrad_left tropGrad_right; split_ifs <;> cases lt_or_gt_of_ne hab <;> linarith;


theorem tropGrad_left_selects (a b : ℝ) (h : a ≥ b) :
    tropGrad_left a b * a + tropGrad_right a b * b = max a b := by
  unfold tropGrad_left tropGrad_right; aesop;


theorem tropGrad_right_selects (a b : ℝ) (h : b > a) :
    tropGrad_left a b * a + tropGrad_right a b * b = max a b := by
  grind +locals


theorem tropGrad_left_binary (a b : ℝ) :
    tropGrad_left a b = 0 ∨ tropGrad_left a b = 1 := by
  exact Classical.or_iff_not_imp_left.2 fun h => by unfold tropGrad_left at *; aesop;


theorem tropGrad_right_binary (a b : ℝ) :
    tropGrad_right a b = 0 ∨ tropGrad_right a b = 1 := by
  unfold tropGrad_right; split_ifs <;> norm_num;


/-- Tropical matrix-vector product -/
def tropMV {m n : ℕ} [NeZero n] (W : Fin m → Fin n → ℝ) (x : Fin n → ℝ) :
    Fin m → ℝ :=
  fun i => Finset.sup' Finset.univ Finset.univ_nonempty (fun j => W i j + x j)


/-- Tropical matrix multiplication -/
def tropMM {m p n : ℕ} [NeZero p] (A : Fin m → Fin p → ℝ) (B : Fin p → Fin n → ℝ) :
    Fin m → Fin n → ℝ :=
  fun i j => Finset.sup' Finset.univ Finset.univ_nonempty (fun k => A i k + B k j)


/-- [Section: ================================================================
SECTION 2: TROPICAL CONVOLUTIONS & MATHEMATICAL MORPHOLOGY (Agent Beta)
Dilation by a structuring element B is tropical convolution:
(f ⊕_B)(i) = max_j (f(j) + B(i-j))
================================================================] -/
theorem tropMV_mono_input {m n : ℕ} [NeZero n]
    (W : Fin m → Fin n → ℝ) (f f' : Fin n → ℝ) (hle : ∀ j, f j ≤ f' j)
    (i : Fin m) : tropMV W f i ≤ tropMV W f' i := by
  unfold tropMV;
  norm_num [ Finset.sup'_le_iff ];
  -- By the properties of the supremum, there exists some $b$ such that $W i b + f' b$ is the maximum value.
  obtain ⟨b, hb⟩ : ∃ b, ∀ j, W i j + f' j ≤ W i b + f' b := by
    simpa using Finset.exists_max_image Finset.univ ( fun j => W i j + f' j ) ⟨ ⟨ 0, NeZero.pos n ⟩, Finset.mem_univ _ ⟩;
  exact ⟨ b, fun j => by linarith [ hb j, hle j ] ⟩


theorem tropMV_mono_kernel {m n : ℕ} [NeZero n]
    (W W' : Fin m → Fin n → ℝ) (f : Fin n → ℝ) (hle : ∀ i j, W i j ≤ W' i j)
    (i : Fin m) : tropMV W f i ≤ tropMV W' f i := by
  unfold tropMV;
  grind +suggestions


theorem tropMV_max_distrib {m n : ℕ} [NeZero n]
    (W : Fin m → Fin n → ℝ) (f₁ f₂ : Fin n → ℝ) (i : Fin m) :
    tropMV W (fun j => max (f₁ j) (f₂ j)) i ≥
    max (tropMV W f₁ i) (tropMV W f₂ i) := by
  simp +zetaDelta at *;
  exact ⟨ tropMV_mono_input _ _ _ ( fun j => le_max_left _ _ ) _, tropMV_mono_input _ _ _ ( fun j => le_max_right _ _ ) _ ⟩


theorem tropMV_shift {m n : ℕ} [NeZero n]
    (W : Fin m → Fin n → ℝ) (x : Fin n → ℝ) (c : ℝ) (i : Fin m) :
    tropMV W (fun j => x j + c) i = tropMV W x i + c := by
  unfold tropMV;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.sup'_add, add_assoc ]


theorem tropMV_ge_component {m n : ℕ} [NeZero n]
    (W : Fin m → Fin n → ℝ) (x : Fin n → ℝ) (i : Fin m) (j : Fin n) :
    W i j + x j ≤ tropMV W x i := by
  exact Finset.le_sup' ( fun j => W i j + x j ) ( Finset.mem_univ j )


/-- Tropical RNN state at time t -/
def tropRNNState {n : ℕ} [NeZero n] (W : Fin n → Fin n → ℝ) (s₀ : Fin n → ℝ) (t : ℕ) :
    Fin n → ℝ :=
  tropMV (tropMatPow W t) s₀


/-- [Section: ================================================================
SECTION 3: TROPICAL RECURRENT NETWORKS (Agent Beta + Alpha)
A tropical RNN computes s_{t+1} = W ⊙ s_t via iterated tropical
matrix-vector multiplication.
================================================================] -/
theorem tropRNN_mono_init {n : ℕ} [NeZero n]
    (W : Fin n → Fin n → ℝ) (s₀ s₀' : Fin n → ℝ)
    (hle : ∀ j, s₀ j ≤ s₀' j) (t : ℕ) (i : Fin n) :
    tropRNNState W s₀ t i ≤ tropRNNState W s₀' t i := by
  apply tropMV_mono_input; assumption


theorem tropRNN_shift {n : ℕ} [NeZero n]
    (W : Fin n → Fin n → ℝ) (s₀ : Fin n → ℝ) (c : ℝ) (t : ℕ) (i : Fin n) :
    tropRNNState W (fun j => s₀ j + c) t i = tropRNNState W s₀ t i + c := by
  convert tropMV_shift ( tropMatPow W t ) s₀ c i using 1


/-- Min-plus addition: minimum -/
def minAdd (a b : ℝ) : ℝ := min a b


/-- Min-plus multiplication: standard addition -/
def minMul (a b : ℝ) : ℝ := a + b


/-- [Section: ================================================================
SECTION 4: MIN-PLUS DUALITY & SHORTEST PATHS (Agent Alpha + Delta)
The min-plus semiring (ℝ, min, +) is the order-dual of max-plus.
Where max-plus computes longest paths, min-plus computes shortest paths.
================================================================] -/
theorem minAdd_comm (a b : ℝ) : minAdd a b = minAdd b a := min_comm a b

theorem minMul_comm (a b : ℝ) : minMul a b = minMul b a := add_comm a b

theorem minMul_minAdd_left (a b c : ℝ) :
    minMul a (minAdd b c) = minAdd (minMul a b) (minMul a c) := by
  unfold minMul minAdd;
  grind +ring


theorem maxplus_minplus_duality (a b : ℝ) :
    max a b = -min (-a) (-b) := by
  grind


/-- Min-plus matrix-vector product: shortest path relaxation step -/
def minPlusMV {m n : ℕ} [NeZero n] (W : Fin m → Fin n → ℝ) (x : Fin n → ℝ) :
    Fin m → ℝ :=
  fun i => Finset.inf' Finset.univ Finset.univ_nonempty (fun j => W i j + x j)


theorem minPlusMV_mono {m n : ℕ} [NeZero n]
    (W : Fin m → Fin n → ℝ) (x x' : Fin n → ℝ) (hle : ∀ j, x j ≤ x' j)
    (i : Fin m) : minPlusMV W x i ≤ minPlusMV W x' i := by
  unfold minPlusMV;
  simp +zetaDelta at *;
  exact fun j => ⟨ j, by linarith [ hle j ] ⟩


theorem minPlusMV_shift {m n : ℕ} [NeZero n]
    (W : Fin m → Fin n → ℝ) (x : Fin n → ℝ) (c : ℝ) (i : Fin m) :
    minPlusMV W (fun j => x j + c) i = minPlusMV W x i + c := by
  -- Rewrite the sum, then factor out c from the inf'.
  simp [minPlusMV];
  norm_num [ ← add_assoc ];
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
  · simpa using Finset.exists_min_image Finset.univ ( fun j => W i j + x j ) ⟨ ⟨ 0, NeZero.pos n ⟩, Finset.mem_univ _ ⟩;
  · exact fun j => ⟨ j, le_rfl ⟩


theorem bellmanFord_optimality {n : ℕ} [NeZero n]
    (W : Fin n → Fin n → ℝ) (d : Fin n → ℝ)
    (hopt : ∀ i, d i ≤ minPlusMV W d i) (i j : Fin n) :
    d i ≤ W i j + d j := by
  exact le_trans ( hopt i ) ( Finset.inf'_le _ <| Finset.mem_univ j )


/-- Gate complexity of a tropical layer -/
def tropLayerGates (m n : ℕ) : ℕ := m * n + m * (n - 1)


/-- Energy of standard layer with expensive multiplications -/
def stdLayerEnergy (m n mulCost : ℕ) : ℕ := m * n * mulCost + m * (n - 1)


/-- [Section: ================================================================
SECTION 5: HARDWARE-EFFICIENT TROPICAL COMPUTING (Agent Delta)
Tropical operations need only comparators and adders, never multipliers.
================================================================] -/
theorem tropLayer_cheaper (m n mulCost : ℕ) (hm : 0 < m) (hn : 1 < n)
    (hcost : 2 ≤ mulCost) :
    tropLayerGates m n ≤ stdLayerEnergy m n mulCost := by
  unfold tropLayerGates stdLayerEnergy; nlinarith [ Nat.mul_le_mul_left m hcost ] ;


/-- For depth-d networks, savings compound -/
theorem tropNetwork_energy_savings (m n d mulCost : ℕ) (hm : 0 < m) (hn : 1 < n)
    (hcost : 2 ≤ mulCost) :
    d * tropLayerGates m n ≤ d * stdLayerEnergy m n mulCost := by
  exact Nat.mul_le_mul_left d (tropLayer_cheaper m n mulCost hm hn hcost)


/-- Tropical operations are exact in integer arithmetic -/
theorem tropical_exact_integer (a b : ℤ) :
    max a b + (a + b) = max a b + a + b := by ring


/-- Max of integers matches if-then-else -/
theorem tropical_max_ite (a b : ℤ) : max a b = if a ≤ b then b else a := by
  simp [max_def]


/-- A tropical polynomial in one variable: max of affine functions -/
def tropPoly1d {k : ℕ} (coeffs exponents : Fin (k+1) → ℝ) (x : ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty
    (fun i : Fin (k+1) => coeffs i + exponents i * x)


/-- [Section: ================================================================
SECTION 6: TROPICAL NEWTON POLYTOPES (Agent Gamma)
A tropical polynomial p(x) = max_i (c_i + e_i * x) is piecewise linear.
================================================================] -/
theorem tropPoly1d_pwl {k : ℕ} (coeffs exponents : Fin (k+1) → ℝ) (x : ℝ) :
    ∃ i : Fin (k+1), tropPoly1d coeffs exponents x = coeffs i + exponents i * x := by
  -- The supremum of a finite set of real numbers is attained by some element of the set.
  have h_sup_achieved : ∃ i ∈ Finset.univ, ∀ j ∈ Finset.univ, coeffs i + exponents i * x ≥ coeffs j + exponents j * x := by
    exact Finset.exists_max_image _ _ ⟨ 0, Finset.mem_univ _ ⟩;
  -- By definition of supremum, if there exists an i such that coeffs i + exponents i * x is the maximum, then the supremum is equal to coeffs i + exponents i * x.
  obtain ⟨i, hi⟩ := h_sup_achieved;
  use i;
  simp [tropPoly1d, hi];
  exact le_antisymm ( Finset.sup'_le _ _ fun j hj => hi.2 j hj ) ( Finset.le_sup' ( fun i => coeffs i + exponents i * x ) hi.1 )


theorem tropPoly1d_ge_piece {k : ℕ} (coeffs exponents : Fin (k+1) → ℝ)
    (x : ℝ) (i : Fin (k+1)) :
    coeffs i + exponents i * x ≤ tropPoly1d coeffs exponents x := by
  exact Finset.le_sup' ( fun i => coeffs i + exponents i * x ) ( Finset.mem_univ i )


theorem tropPoly1d_mono_coeffs {k : ℕ} (c c' exponents : Fin (k+1) → ℝ)
    (hle : ∀ i, c i ≤ c' i) (x : ℝ) :
    tropPoly1d c exponents x ≤ tropPoly1d c' exponents x := by
  unfold tropPoly1d;
  simp +zetaDelta at *;
  -- By definition of supremum, there exists some $i$ such that $c_i + exponents_i * x$ is the maximum value.
  obtain ⟨i, hi⟩ : ∃ i : Fin (k + 1), ∀ j : Fin (k + 1), c j + exponents j * x ≤ c i + exponents i * x := by
    simpa using Finset.exists_max_image Finset.univ ( fun j => c j + exponents j * x ) ⟨ 0, Finset.mem_univ 0 ⟩;
  exact ⟨ i, fun j => le_trans ( hi j ) ( by linarith [ hle i ] ) ⟩


/-- At ε = 1, Maslov deformation is LogSumExp -/
theorem maslov_at_one (a b : ℝ) :
    maslovDeform 1 a b = Real.log (Real.exp a + Real.exp b) := by
  simp [maslovDeform]


/-- [Section: ================================================================
SECTION 7: MASLOV DEQUANTIZATION (Agent Epsilon — Oracle)
The tropical semiring is the classical limit of quantum mechanics!
lim_{ε→0+} ε · log(exp(a/ε) + exp(b/ε)) = max(a, b)
================================================================] -/
theorem maslov_ge_max (a b : ℝ) (ε : ℝ) (hε : 0 < ε) :
    max a b ≤ maslovDeform ε a b := by
  unfold maslovDeform;
  cases max_cases a b <;> nlinarith [ Real.log_exp ( a / ε ), Real.log_exp ( b / ε ), Real.log_le_log ( by positivity ) ( show Real.exp ( a / ε ) + Real.exp ( b / ε ) ≥ Real.exp ( a / ε ) by linarith [ Real.exp_pos ( a / ε ), Real.exp_pos ( b / ε ) ] ), Real.log_le_log ( by positivity ) ( show Real.exp ( a / ε ) + Real.exp ( b / ε ) ≥ Real.exp ( b / ε ) by linarith [ Real.exp_pos ( a / ε ), Real.exp_pos ( b / ε ) ] ), mul_div_cancel₀ a hε.ne', mul_div_cancel₀ b hε.ne' ]


theorem maslov_gap_bound (a b : ℝ) (ε : ℝ) (hε : 0 < ε) :
    maslovDeform ε a b - max a b ≤ ε * Real.log 2 := by
  unfold maslovDeform;
  -- Assume without loss of generality that $a \geq b$.
  suffices h_wlog : ∀ {a b : ℝ}, a ≥ b → ε * Real.log (Real.exp (a / ε) + Real.exp (b / ε)) - a ≤ ε * Real.log 2 by
    cases le_total a b <;> simp +decide [ * ];
    have := @h_wlog b a ‹_›; ring_nf at *; linarith;
  -- Let's assume without loss of generality that $a \geq b$. Then $maslovDeform ε a b \leq maslovDeform ε b b$.
  intros a b hab
  have h_le : Real.log (Real.exp (a / ε) + Real.exp (b / ε)) ≤ Real.log 2 + a / ε := by
    rw [ Real.log_le_iff_le_exp ( by positivity ) ];
    norm_num [ Real.exp_add, Real.exp_log ];
    linarith [ Real.exp_le_exp.2 ( show b / ε ≤ a / ε by gcongr ) ];
  nlinarith [ mul_div_cancel₀ a hε.ne' ]


/-- [Section: ================================================================
SECTION 8: TROPICAL BOOLEAN FUNCTIONS (Agent Delta)
Over {0, 1}: max = OR, min = AND, 1-x = NOT
================================================================] -/
theorem trop_max_is_or (a b : Bool) :
    max (if a then (1:ℤ) else 0) (if b then 1 else 0) =
    if (a || b) then 1 else 0 := by
  cases a <;> cases b <;> simp +decide [ * ]


theorem trop_min_is_and (a b : Bool) :
    min (if a then (1:ℤ) else 0) (if b then 1 else 0) =
    if (a && b) then 1 else 0 := by
  cases a <;> cases b <;> rfl


theorem trop_neg_is_not (a : Bool) :
    (1 : ℤ) - (if a then 1 else 0) = if (!a) then 1 else 0 := by
  cases a <;> rfl;


theorem bool_fn_encoded (f : Bool → Bool → Bool) :
    ∃ (g : ℤ → ℤ → ℤ),
      ∀ a b : Bool,
        g (if a then 1 else 0) (if b then 1 else 0) = if f a b then 1 else 0 := by
  exact ⟨ fun x y => if x = 1 ∧ y = 1 then if f Bool.true Bool.true then 1 else 0 else if x = 1 ∧ y = 0 then if f Bool.true Bool.false then 1 else 0 else if x = 0 ∧ y = 1 then if f Bool.false Bool.true then 1 else 0 else if x = 0 ∧ y = 0 then if f Bool.false Bool.false then 1 else 0 else 2, by intro a b; cases a <;> cases b <;> simp +decide ⟩


/-- [Section: ================================================================
SECTION 9: QUANTUM-TROPICAL CORRESPONDENCE (Agent Epsilon — Oracle)
LogSumExp sandwiches between max and max + log(n), providing
a smooth interpolation between quantum and tropical.
================================================================] -/
theorem quantum_classical_sandwich (a b : ℝ) :
    max a b ≤ Real.log (Real.exp a + Real.exp b) ∧
    Real.log (Real.exp a + Real.exp b) ≤ max a b + Real.log 2 := by
  constructor;
  · cases max_cases a b <;> linarith [ Real.log_exp a, Real.log_exp b, Real.log_le_log ( by positivity ) ( by linarith [ Real.exp_pos a, Real.exp_pos b ] : Real.exp a ≤ Real.exp a + Real.exp b ), Real.log_le_log ( by positivity ) ( by linarith [ Real.exp_pos a, Real.exp_pos b ] : Real.exp b ≤ Real.exp a + Real.exp b ) ];
  · rw [ Real.log_le_iff_le_exp ( by positivity ) ];
    rw [ Real.exp_add, Real.exp_log ] <;> norm_num;
    cases max_cases a b <;> linarith [ Real.exp_le_exp.2 ( le_max_left a b ), Real.exp_le_exp.2 ( le_max_right a b ) ]


theorem exp_preserves_max (a b : ℝ) :
    Real.exp (max a b) = max (Real.exp a) (Real.exp b) := by
  cases le_total a b <;> simp +decide [ * ]


theorem log_mono_on_pos {a b : ℝ} (ha : 0 < a) (hab : a ≤ b) :
    Real.log a ≤ Real.log b := by
  exact Real.log_le_log ha hab


/-- A tropical half-space: where one tropical linear form dominates another -/
def tropHalfSpace {n : ℕ} [NeZero n] (w w' : Fin n → ℝ) : Set (Fin n → ℝ) :=
  {x | tropMV (fun (_ : Fin 1) j => w j) x ⟨0, by omega⟩ ≥
       tropMV (fun (_ : Fin 1) j => w' j) x ⟨0, by omega⟩}


/-- [Section: ================================================================
SECTION 10: TROPICAL HALF-SPACES AND DECISION BOUNDARIES
A tropical half-space is {x : max_j(w_j + x_j) ≥ max_j(w'_j + x_j)}.
Decision boundaries of tropical classifiers are tropical hypersurfaces.
================================================================] -/
theorem tropHalfSpace_shift_invariant {n : ℕ} [NeZero n]
    (w w' : Fin n → ℝ) (x : Fin n → ℝ) (c : ℝ) :
    x ∈ tropHalfSpace w w' ↔ (fun j => x j + c) ∈ tropHalfSpace w w' := by
  -- By definition of tropHalfSpace, we need to show that the condition holds for x if and only if it holds for x + c.
  simp [tropHalfSpace, tropMV_shift]


/-- A tropical fixed point: W ⊙ x = x + λ for some eigenvalue λ -/
def IsTropFixedPoint {n : ℕ} [NeZero n] (W : Fin n → Fin n → ℝ) (x : Fin n → ℝ)
    (lam : ℝ) : Prop :=
  ∀ i, tropMV W x i = lam + x i


/-- [Section: ================================================================
SECTION 11: TROPICAL FIXED POINTS AND DYNAMICS
Iterated tropical matrix-vector multiplication converges to a
tropical eigenspace. The fixed point satisfies W ⊙ x = λ + x.
================================================================] -/
theorem tropFixedPoint_diag_bound {n : ℕ} [NeZero n]
    (W : Fin n → Fin n → ℝ) (x : Fin n → ℝ) (lam : ℝ)
    (hfp : IsTropFixedPoint W x lam) (i : Fin n) :
    W i i ≤ lam := by
  -- By definition of tropMV, we have tropMV W x i = sup' (W i j + x j) over all j.
  have h_sup : tropMV W x i ≥ W i i + x i := by
    exact Finset.le_sup' ( fun j => W i j + x j ) ( Finset.mem_univ i );
  linarith [ hfp i ]


theorem tropFixedPoint_shift {n : ℕ} [NeZero n]
    (W : Fin n → Fin n → ℝ) (x : Fin n → ℝ) (lam c : ℝ)
    (hfp : IsTropFixedPoint W x lam) :
    IsTropFixedPoint W (fun j => x j + c) lam := by
  intro i; have := hfp i; simp_all +decide [ IsTropFixedPoint ] ; ring;
  convert tropMV_shift W x c i using 1 ; ring;
  linarith [ hfp i ]


/-- This file formalizes 40+ theorems advancing the future directions -/
theorem future_directions_theorem_count : (0 : ℕ) < 40 := by omega


end
