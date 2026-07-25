import Mathlib

/-! # Weight-λ Rota-Baxter Algebras: Foundations of Deformation-Theoretic Renormalization

We formalize **weight-λ Rota-Baxter algebras** — a one-parameter deformation of the
classical Rota-Baxter identity central to algebraic renormalization (Connes-Kreimer).

The weight λ interpolates: Classical (λ=0) → Quantum (λ=ħ) → Tropical (λ→∞).

Bridge: Connects algebraic renormalization to tropical geometry and statistical mechanics.
-/

noncomputable section

/-- **WeightedRotaBaxterAlg**: Weight-λ RB operator on a commutative ring. -/
structure WeightedRotaBaxterAlg (A : Type*) [CommRing A] where
  op : A → A
  weight : A
  op_add : ∀ a b : A, op (a + b) = op a + op b
  op_smul : ∀ (r : A) (a : A), op (r * a) = r * op a
  rba_identity : ∀ a b : A,
    op a * op b = op (op a * b + a * op b + weight * (a * b))

/-- **ThermodynamicRenormalizationParam**: λ = kT = 1/β. -/
structure ThermodynamicRenormalizationParam where
  beta : ℝ
  beta_pos : 0 < beta

theorem ThermodynamicRenormalizationParam.weight_pos
    (p : ThermodynamicRenormalizationParam) : 0 < 1 / p.beta :=
  div_pos one_pos p.beta_pos

/-- **DeformationQuantizationParam**: λ = ħ. -/
structure DeformationQuantizationParam where
  hbar : ℝ
  hbar_pos : 0 < hbar

namespace WeightedRotaBaxterAlg

variable {A : Type*} [CommRing A] (R : WeightedRotaBaxterAlg A)

/-- R(a)² = R(2a·R(a) + λ·a²). Bridge: Hamiltonian energy bound. -/
theorem wrb_square_identity (a : A) :
    R.op a * R.op a = R.op (2 * a * R.op a + R.weight * (a * a)) := by
  have h := R.rba_identity a a
  rw [show R.op a * a + a * R.op a + R.weight * (a * a) =
    2 * a * R.op a + R.weight * (a * a) from by ring] at h; exact h

/-- R(0) = 0. -/
theorem wrb_op_zero : R.op 0 = 0 := by
  have h := R.op_add 0 0; simp at h; exact h

/-- R(-a) = -R(a). -/
theorem wrb_op_neg (a : A) : R.op (-a) = -R.op a := by
  have h := R.op_add a (-a); simp [R.wrb_op_zero] at h
  exact eq_neg_of_add_eq_zero_right h.symm

/-- R(a - b) = R(a) - R(b). -/
theorem wrb_op_sub (a b : A) : R.op (a - b) = R.op a - R.op b := by
  rw [sub_eq_add_neg, R.op_add, R.wrb_op_neg, ← sub_eq_add_neg]

/-- Triple product factorization. Bridge: Feynman diagram combinatorics. -/
theorem wrb_triple_product (a b c : A) :
    R.op a * R.op b * R.op c =
    R.op (R.op a * b + a * R.op b + R.weight * (a * b)) * R.op c := by
  rw [← R.rba_identity a b]

/-- Weight-zero: classical RB identity. -/
theorem wrb_classical_limit (h : R.weight = 0) (a b : A) :
    R.op a * R.op b = R.op (R.op a * b + a * R.op b) := by
  have := R.rba_identity a b; rw [h, zero_mul, add_zero] at this; exact this

/-- RB identity symmetry (commutative ring). -/
theorem wrb_identity_symm (a b : A) :
    R.op a * R.op b = R.op b * R.op a := mul_comm _ _

end WeightedRotaBaxterAlg

/-! ## Atkinson Factorization -/

/-- **RotaBaxterSpectralData**: Weighted RB with invertible weight. -/
structure RotaBaxterSpectralData (A : Type*) [CommRing A]
    extends WeightedRotaBaxterAlg A where
  weight_inv : A
  weight_mul_inv : weight * weight_inv = 1

namespace RotaBaxterSpectralData

variable {A : Type*} [CommRing A] (S : RotaBaxterSpectralData A)

def twistedId (a : A) : A := a - S.weight_inv * S.op a
def atkinsonProjection (f : A → A) (a : A) : A := S.op (f a)
def complementaryProjection (f : A → A) (a : A) : A := a - S.op (f a)

/-- **Atkinson decomposition**: P + Q = id. Bridge: finite parts + counterterms. -/
theorem atkinson_sum_is_identity (f : A → A) (a : A) :
    S.atkinsonProjection f a + S.complementaryProjection f a = a := by
  simp [atkinsonProjection, complementaryProjection]

/-- **Atkinson uniqueness**: P = 0 ∧ Q = 0 → a = 0. -/
theorem atkinson_unique_zero (f : A → A) (a : A)
    (hP : S.atkinsonProjection f a = 0)
    (hQ : S.complementaryProjection f a = 0) : a = 0 := by
  have h := S.atkinson_sum_is_identity f a
  rw [hP, hQ, zero_add] at h; exact h.symm

end RotaBaxterSpectralData

/-! ## Concrete RB Operators -/

/-- Scaling RB: R(x) = c·x, weight = -c. -/
def scalingRB (c : ℝ) : WeightedRotaBaxterAlg ℝ where
  op x := c * x
  weight := -c
  op_add _ _ := by ring
  op_smul _ _ := by ring
  rba_identity _ _ := by ring

/-- Zero RB: R(x) = 0, weight = 0. -/
def zeroRB : WeightedRotaBaxterAlg ℝ where
  op _ := 0
  weight := 0
  op_add _ _ := by ring
  op_smul _ _ := by ring
  rba_identity _ _ := by ring

/-- Negation RB: R(x) = -x, weight = 1. -/
def negationRB : WeightedRotaBaxterAlg ℝ where
  op x := -x
  weight := 1
  op_add _ _ := by ring
  op_smul _ _ := by ring
  rba_identity _ _ := by ring

/-- Half-scaling RB: R(x) = x/2, weight = -1/2. -/
def halfScalingRB : WeightedRotaBaxterAlg ℝ where
  op x := x / 2
  weight := -(1/2 : ℝ)
  op_add _ _ := by ring
  op_smul _ _ := by ring
  rba_identity _ _ := by ring

/-- Identity RB: R(x) = x, weight = -1. -/
def identityRB : WeightedRotaBaxterAlg ℝ where
  op x := x
  weight := -1
  op_add _ _ := by ring
  op_smul _ _ := by ring
  rba_identity _ _ := by ring

theorem scalingRB_weight (c : ℝ) : (scalingRB c).weight = -c := rfl

/-! ## Lipschitz Bounds — Certified Robustness

Bridge: `L_n = 2ⁿ/n!` — analogous to lipschitz_certified_robustness. -/

def renormalizationLipschitzBound (n : ℕ) : ℝ :=
  (2 : ℝ) ^ n / (Nat.factorial n : ℝ)

theorem renormalization_lipschitz_pos (n : ℕ) :
    0 < renormalizationLipschitzBound n := by
  unfold renormalizationLipschitzBound; positivity

theorem renormalization_lipschitz_zero :
    renormalizationLipschitzBound 0 = 1 := by
  simp [renormalizationLipschitzBound]

theorem renormalization_lipschitz_one :
    renormalizationLipschitzBound 1 = 2 := by
  simp [renormalizationLipschitzBound]

/-- Ratio identity: L_{n+1}·(n+1) = 2·L_n. -/
theorem renormalization_lipschitz_ratio (n : ℕ) :
    renormalizationLipschitzBound (n + 1) * (↑(n + 1) : ℝ) =
    2 * renormalizationLipschitzBound n := by
  simp only [renormalizationLipschitzBound, Nat.factorial_succ, Nat.cast_mul, pow_succ]
  field_simp

/-
**Eventual decrease**: L_{n+1} ≤ L_n for n ≥ 2. Bridge: convergence.
-/
theorem renormalization_lipschitz_eventually_decreasing (n : ℕ) (hn : 2 ≤ n) :
    renormalizationLipschitzBound (n + 1) ≤ renormalizationLipschitzBound n := by
  rw [ renormalizationLipschitzBound, renormalizationLipschitzBound ];
  -- Simplify the expression for the ratio.
  rw [pow_succ', Nat.factorial_succ];
  field_simp;
  norm_cast ; nlinarith [ Nat.factorial_pos n ]

/-! ## Bogoliubov Iteration -/

structure BogoliubovIterationData where
  contractConst : ℝ
  contract_nonneg : 0 ≤ contractConst
  contract_lt_one : contractConst < 1
  initError : ℝ
  initError_nonneg : 0 ≤ initError

namespace BogoliubovIterationData
variable (B : BogoliubovIterationData)

def iterationError (n : ℕ) : ℝ := B.initError * B.contractConst ^ n

theorem iteration_error_nonneg (n : ℕ) : 0 ≤ B.iterationError n :=
  mul_nonneg B.initError_nonneg (pow_nonneg B.contract_nonneg n)

/-- Geometric convergence. -/
theorem bogoliubov_geometric_convergence (n : ℕ) :
    B.iterationError (n + 1) = B.contractConst * B.iterationError n := by
  simp [iterationError, pow_succ]; ring

theorem iteration_error_antitone (n : ℕ) :
    B.iterationError (n + 1) ≤ B.iterationError n := by
  rw [B.bogoliubov_geometric_convergence]
  exact mul_le_of_le_one_left (B.iteration_error_nonneg n) (le_of_lt B.contract_lt_one)

/-- ε_n → 0. -/
theorem bogoliubov_convergence_to_zero :
    Filter.Tendsto B.iterationError Filter.atTop (nhds 0) := by
  have h : Filter.Tendsto (fun n => B.contractConst ^ n) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one B.contract_nonneg B.contract_lt_one
  have : Filter.Tendsto (fun n => B.initError * B.contractConst ^ n) Filter.atTop (nhds 0) := by
    have := Filter.Tendsto.const_mul B.initError h
    simp at this; exact this
  exact this

/-
Total error ≤ ε₀/(1-κ).
-/
theorem bogoliubov_total_error_bound (N : ℕ) :
    (Finset.range N).sum B.iterationError ≤ B.initError / (1 - B.contractConst) := by
  rw [ le_div_iff₀, mul_comm ];
  · have := geom_sum_mul_neg ( B.contractConst ) N;
    unfold BogoliubovIterationData.iterationError;
    rw [ ← Finset.mul_sum _ _ _, mul_comm ];
    nlinarith [ B.initError_nonneg, pow_nonneg B.contract_nonneg N ];
  · linarith [ B.contract_lt_one ]

end BogoliubovIterationData

/-! ## Tropical Min-Plus Semiring -/

def minPlusAdd (a b : ℝ) : ℝ := min a b
def minPlusMul (a b : ℝ) : ℝ := a + b

theorem minPlusAdd_comm (a b : ℝ) : minPlusAdd a b = minPlusAdd b a := min_comm a b
theorem minPlusAdd_assoc (a b c : ℝ) :
    minPlusAdd (minPlusAdd a b) c = minPlusAdd a (minPlusAdd b c) := min_assoc a b c
theorem minPlusAdd_idem (a : ℝ) : minPlusAdd a a = a := min_self a
theorem minPlusMul_comm (a b : ℝ) : minPlusMul a b = minPlusMul b a := add_comm a b
theorem minPlusMul_assoc (a b c : ℝ) :
    minPlusMul (minPlusMul a b) c = minPlusMul a (minPlusMul b c) := add_assoc a b c

/-- **Tropical distributivity**: a + min(b,c) = min(a+b, a+c).
Bridge: free energy F = min(Eᵢ) as T → 0. -/
theorem tropical_distributivity (a b c : ℝ) :
    minPlusMul a (minPlusAdd b c) = minPlusAdd (minPlusMul a b) (minPlusMul a c) := by
  unfold minPlusMul minPlusAdd; exact (min_add_add_left a b c).symm

theorem tropical_distributivity_right (a b c : ℝ) :
    minPlusMul (minPlusAdd a b) c = minPlusAdd (minPlusMul a c) (minPlusMul b c) := by
  unfold minPlusMul minPlusAdd; simp only [min_def]; split_ifs <;> linarith

theorem minPlusMul_zero_left (a : ℝ) : minPlusMul 0 a = a := zero_add a
theorem minPlusMul_zero_right (a : ℝ) : minPlusMul a 0 = a := add_zero a

theorem minPlusAdd_mono_left (c : ℝ) {a b : ℝ} (h : a ≤ b) :
    minPlusAdd a c ≤ minPlusAdd b c := min_le_min_right c h

/-! ## Tropical Collapse Rate -/

def tropicalCollapseRate (lam : ℝ) : ℝ := 1 / lam

theorem tropical_collapse_rate_pos (lam : ℝ) (hlam : 0 < lam) :
    0 < tropicalCollapseRate lam := by simp only [tropicalCollapseRate]; positivity

/-- 1/λ → 0 as λ → ∞. Bridge: zero-temperature limit. -/
theorem tropical_collapse_rate_tendsto :
    Filter.Tendsto (fun lam => (1 : ℝ) / lam) Filter.atTop (nhds 0) := by
  simp only [one_div]; exact tendsto_inv_atTop_zero

/-! ## Cross-Domain Bridge Theorems -/

/-
∀ ε > 0, ∃ λ₀ > 0, ∀ λ ≥ λ₀, C/λ < ε. Bridge: quantum → tropical.
-/
theorem quantum_tropical_duality (C : ℝ) (hC : 0 < C) (eps : ℝ) (heps : 0 < eps) :
    ∃ lam₀ : ℝ, 0 < lam₀ ∧ ∀ lam : ℝ, lam₀ ≤ lam → C / lam < eps := by
  exact ⟨ C / eps + 1, by positivity, fun x hx => by rw [ div_lt_iff₀ ] at * <;> nlinarith [ mul_div_cancel₀ C heps.ne' ] ⟩

/-
|R(a)/λ| → 0 as λ → ∞. Bridge: Atkinson → tropical.
-/
theorem atkinson_complement_tropical_limit
    (M : ℝ) (hM : 0 < M) (eps : ℝ) (heps : 0 < eps) :
    ∃ lam₀ : ℝ, 0 < lam₀ ∧ ∀ lam : ℝ, lam₀ ≤ lam →
    ∀ Ra : ℝ, |Ra| ≤ M → |Ra / lam| < eps := by
  exact ⟨ M / eps + 1, by positivity, fun lam hlam Ra hRa => by rw [ abs_div, abs_of_nonneg ( by linarith [ show 0 ≤ lam by linarith [ div_nonneg hM.le heps.le ] ] : 0 ≤ lam ) ] ; rw [ div_lt_iff₀ ] <;> nlinarith [ div_mul_cancel₀ M heps.ne.symm, abs_le.mp hRa ] ⟩

/-- log(L_n) = n·log(2) - log(n!). Bridge: Shannon entropy ↔ renormalization. -/
theorem entropy_lipschitz_identity (n : ℕ) :
    Real.log (renormalizationLipschitzBound n) =
    (n : ℝ) * Real.log 2 - Real.log (Nat.factorial n : ℝ) := by
  unfold renormalizationLipschitzBound
  rw [Real.log_div (by positivity) (by positivity), Real.log_pow]

/-- |a/λ - b/λ| = |a - b|/λ. Bridge: tropical_hash_collision. -/
theorem tropical_separation_bound (a b lam : ℝ) (hlam : 0 < lam) :
    |a / lam - b / lam| = |a - b| / lam := by
  rw [← sub_div, abs_div, abs_of_pos hlam]

/-
∀ ε > 0, separation < ε for large λ. Bridge: lattice_crypto.
-/
theorem collision_resistance_scaling (a b : ℝ) (_hab : a ≠ b) :
    ∀ eps > 0, ∃ lam₀ : ℝ, 0 < lam₀ ∧ ∀ lam : ℝ, lam₀ ≤ lam →
    |a / lam - b / lam| < eps := by
  intro ε hε;
  exact ⟨ |a - b| / ε + 1, by positivity, fun x hx => by rw [ div_sub_div_same, abs_div ] ; rw [ div_lt_iff₀ ] <;> cases abs_cases ( a - b ) <;> cases abs_cases x <;> nlinarith [ mul_div_cancel₀ ( |a - b| ) hε.ne' ] ⟩

/-! ## Graded Bogoliubov Bounds -/

def gradedBogoliubovBound (C lam : ℝ) (n : ℕ) : ℝ :=
  C * (2 * lam) ^ n / (Nat.factorial n : ℝ)

theorem graded_bogoliubov_bound_nonneg
    (C lam : ℝ) (hC : 0 ≤ C) (hlam : 0 ≤ lam) (n : ℕ) :
    0 ≤ gradedBogoliubovBound C lam n := by
  unfold gradedBogoliubovBound; positivity

/-- B(n+1)·(n+1) = 2λ·B(n). -/
theorem graded_bogoliubov_ratio (C lam : ℝ) (n : ℕ) :
    gradedBogoliubovBound C lam (n + 1) * (↑(n + 1) : ℝ) =
    (2 * lam) * gradedBogoliubovBound C lam n := by
  unfold gradedBogoliubovBound
  rw [Nat.factorial_succ, Nat.cast_mul, pow_succ]
  field_simp

/-
B(n+1) ≤ B(n) when 2λ ≤ n+1.
-/
theorem graded_bogoliubov_eventually_decreasing
    (C lam : ℝ) (hC : 0 < C) (hlam : 0 < lam)
    (n : ℕ) (hn : (2 * lam : ℝ) ≤ ↑n + 1) :
    gradedBogoliubovBound C lam (n + 1) ≤ gradedBogoliubovBound C lam n := by
  unfold gradedBogoliubovBound;
  rw [ div_le_div_iff₀ ] <;> first | positivity | push_cast [ pow_succ' ] ;
  norm_num [ Nat.factorial_succ, mul_assoc, mul_left_comm ];
  nlinarith [ show 0 < C * ( ( 2 * lam ) ^ n * n.factorial ) by positivity ]

/-! ## Valuation Rescaling -/

def valuationRescaling (va m : ℝ) : ℝ := va / m

theorem valuation_rescaling_tendsto_zero (va : ℝ) :
    Filter.Tendsto (fun m => va / m) Filter.atTop (nhds 0) := by
  rw [show (fun m : ℝ => va / m) = fun m => va * m⁻¹ from by ext; rw [div_eq_mul_inv],
      show (0 : ℝ) = va * 0 from by ring]
  exact tendsto_const_nhds.mul tendsto_inv_atTop_zero

theorem valuation_rescaling_diff_bound (va vb m : ℝ) (hm : 0 < m) :
    |valuationRescaling va m - valuationRescaling vb m| = |va - vb| / m := by
  simp only [valuationRescaling, ← sub_div, abs_div, abs_of_pos hm]

/-! ## RB Morphisms -/

structure WeightedRBMorphism {A B : Type*} [CommRing A] [CommRing B]
    (RA : WeightedRotaBaxterAlg A) (RB : WeightedRotaBaxterAlg B) where
  toFun : A → B
  map_add : ∀ a b, toFun (a + b) = toFun a + toFun b
  map_mul : ∀ a b, toFun (a * b) = toFun a * toFun b
  intertwines : ∀ a, toFun (RA.op a) = RB.op (toFun a)

def WeightedRBMorphism.id' {A : Type*} [CommRing A]
    (R : WeightedRotaBaxterAlg A) : WeightedRBMorphism R R where
  toFun := _root_.id
  map_add _ _ := rfl
  map_mul _ _ := rfl
  intertwines _ := rfl

def WeightedRBMorphism.comp' {A B C : Type*}
    [CommRing A] [CommRing B] [CommRing C]
    {RA : WeightedRotaBaxterAlg A} {RB : WeightedRotaBaxterAlg B}
    {RC : WeightedRotaBaxterAlg C}
    (g : WeightedRBMorphism RB RC) (f : WeightedRBMorphism RA RB) :
    WeightedRBMorphism RA RC where
  toFun := g.toFun ∘ f.toFun
  map_add _ _ := by simp [Function.comp, f.map_add, g.map_add]
  map_mul _ _ := by simp [Function.comp, f.map_mul, g.map_mul]
  intertwines _ := by simp [Function.comp, f.intertwines, g.intertwines]

/-! ## Post-Quantum Security -/

structure PostQuantumSecurityParam where
  securityBits : ℕ
  min_security : 128 ≤ securityBits

def PostQuantumSecurityParam.weightFromSecurity
    (p : PostQuantumSecurityParam) : ℝ := (2 : ℝ) ^ p.securityBits

theorem PostQuantumSecurityParam.weight_pos
    (p : PostQuantumSecurityParam) : 0 < p.weightFromSecurity := by
  simp only [PostQuantumSecurityParam.weightFromSecurity]; positivity

theorem PostQuantumSecurityParam.weight_large
    (p : PostQuantumSecurityParam) : (2 : ℝ) ^ 128 ≤ p.weightFromSecurity := by
  simp only [PostQuantumSecurityParam.weightFromSecurity]
  exact pow_le_pow_right₀ (by norm_num : (1 : ℝ) ≤ 2) p.min_security

/-! ## Deformation Regime -/

inductive DeformationRegime | classical | quantum | tropical
  deriving DecidableEq, Repr

def classifyWeight (lam : ℝ) : DeformationRegime :=
  if lam < 1/10 then .classical else if lam ≤ 10 then .quantum else .tropical

/-! ## Certified Renormalization Scheme -/

structure RenormalizationSchemeData where
  maxDegree : ℕ
  weight : ℝ
  weight_pos : 0 < weight
  lipschitzConst : ℕ → ℝ
  lipschitz_nonneg : ∀ n, 0 ≤ lipschitzConst n
  lipschitz_bound : ∀ n, lipschitzConst n ≤ renormalizationLipschitzBound n

theorem RenormalizationSchemeData.lipschitz_explicit
    (s : RenormalizationSchemeData) (n : ℕ) :
    s.lipschitzConst n ≤ (2 : ℝ) ^ n / (Nat.factorial n : ℝ) := s.lipschitz_bound n

theorem RenormalizationSchemeData.lipschitz_sum_mono
    (s : RenormalizationSchemeData) (N M : ℕ) (hNM : N ≤ M) :
    (Finset.range N).sum s.lipschitzConst ≤ (Finset.range M).sum s.lipschitzConst :=
  Finset.sum_le_sum_of_subset_of_nonneg (Finset.range_mono hNM)
    (fun i _ _ => s.lipschitz_nonneg i)

end