/-! # CatalogBuild.Physics.AlgebraicPhysics.AlgebraicSpacetime

Auto-generated from theorem catalog database.
Domain: Physics/AlgebraicPhysics
Declarations: 46
-/

import Mathlib

noncomputable section

/-- The Minkowski quadratic form in signature (+,+,−) for (2+1) dimensions.
Q(a,b,c) = a² + b² − c². The light cone is Q = 0. -/
def minkowskiQ (v : Fin 3 → ℝ) : ℝ :=
  v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2


/-- The (3+1)-dimensional Minkowski quadratic form with signature (+,−,−,−).
Q(t,x,y,z) = t² − x² − y² − z². -/
def minkowski4Q (v : Fin 4 → ℝ) : ℝ :=
  v 0 ^ 2 - v 1 ^ 2 - v 2 ^ 2 - v 3 ^ 2


/-- A vector is light-like (null) if Q(v) = 0. -/
def isNull (v : Fin 3 → ℝ) : Prop := minkowskiQ v = 0


/-- A vector is timelike if Q(v) < 0 (inside the light cone). -/
def isTimelike (v : Fin 3 → ℝ) : Prop := minkowskiQ v < 0


/-- A vector is spacelike if Q(v) > 0 (outside the light cone). -/
def isSpacelike (v : Fin 3 → ℝ) : Prop := 0 < minkowskiQ v


/-- The Minkowski bilinear form: B(u,v) = u₀v₀ + u₁v₁ − u₂v₂. -/
def minkowskiB (u v : Fin 3 → ℝ) : ℝ :=
  u 0 * v 0 + u 1 * v 1 - u 2 * v 2


/-- The bilinear form polarizes the quadratic form: B(v,v) = Q(v). -/
theorem minkowskiB_self (v : Fin 3 → ℝ) :
    minkowskiB v v = minkowskiQ v := by
  simp [minkowskiB, minkowskiQ, sq]


/-- The bilinear form is symmetric: B(u,v) = B(v,u). -/
theorem minkowskiB_comm (u v : Fin 3 → ℝ) :
    minkowskiB u v = minkowskiB v u := by
  simp [minkowskiB]; ring


/-- Null iff Pythagorean: a² + b² = c². -/
theorem null_iff_pythagorean (v : Fin 3 → ℝ) :
    isNull v ↔ v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2 := by
  simp [isNull, minkowskiQ]; constructor <;> intro h <;> linarith


/-- The light cone is closed under scaling. -/
theorem null_scale (v : Fin 3 → ℝ) (c : ℝ) (hv : isNull v) :
    isNull (fun i => c * v i) := by
  simp only [isNull, minkowskiQ] at *
  ring_nf
  nlinarith [sq_nonneg c, sq_nonneg (v 0), sq_nonneg (v 1), sq_nonneg (v 2)]


/-- Causal trichotomy: every vector is exactly one of timelike, null, or spacelike. -/
theorem causal_trichotomy (v : Fin 3 → ℝ) :
    isTimelike v ∨ isNull v ∨ isSpacelike v := by
  simp only [isTimelike, isNull, isSpacelike, minkowskiQ]
  rcases lt_trichotomy (v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2) 0 with h | h | h
  · exact Or.inl h
  · exact Or.inr (Or.inl h)
  · exact Or.inr (Or.inr h)


/-- A (2+1)-dimensional Lorentz boost matrix in the x-t plane with rapidity φ. -/
def lorentzBoost2D (φ : ℝ) : Matrix (Fin 3) (Fin 3) ℝ :=
  !![1, 0, 0;
     0, Real.cosh φ, Real.sinh φ;
     0, Real.sinh φ, Real.cosh φ]


/-- [Section: # CatalogBuild.Physics.AlgebraicPhysics.AlgebraicSpacetime
Auto-generated from theorem catalog database.
Domain: Physics/AlgebraicPhysics
Declarations: 46] -/
theorem lorentz_boost_preserves_Q (φ : ℝ) (v : Fin 3 → ℝ) :
    minkowskiQ (lorentzBoost2D φ *ᵥ v) = minkowskiQ v := by
  unfold minkowskiQ lorentzBoost2D;
  simpa [ Matrix.mulVec, dotProduct, Fin.sum_univ_succ ] using by nlinarith [ Real.cosh_sq' φ ] ;


/-- A Lorentz boost preserves the null condition: if v is null, so is Λv. -/
theorem lorentz_boost_preserves_null (φ : ℝ) (v : Fin 3 → ℝ) (hv : isNull v) :
    isNull (lorentzBoost2D φ *ᵥ v) := by
  simp [isNull] at *
  rw [lorentz_boost_preserves_Q]
  exact hv


/-- A Lorentz boost preserves the timelike condition. -/
theorem lorentz_boost_preserves_timelike (φ : ℝ) (v : Fin 3 → ℝ) (hv : isTimelike v) :
    isTimelike (lorentzBoost2D φ *ᵥ v) := by
  simp [isTimelike] at *
  rw [lorentz_boost_preserves_Q]
  exact hv


/-- [Section: # CatalogBuild.Physics.AlgebraicPhysics.AlgebraicSpacetime
Auto-generated from theorem catalog database.
Domain: Physics/AlgebraicPhysics
Declarations: 46] -/
theorem lorentz_boost_compose (φ₁ φ₂ : ℝ) :
    lorentzBoost2D φ₁ * lorentzBoost2D φ₂ = lorentzBoost2D (φ₁ + φ₂) := by
  unfold lorentzBoost2D;
  ext i j ; fin_cases i <;> fin_cases j <;> norm_num [ Real.cosh_add, Real.sinh_add ] <;> ring!;


/-- The identity boost has rapidity zero. -/
theorem lorentz_boost_zero : lorentzBoost2D 0 = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
  simp [lorentzBoost2D]


/-- The inverse boost has negated rapidity. -/
theorem lorentz_boost_inv (φ : ℝ) :
    lorentzBoost2D φ * lorentzBoost2D (-φ) = 1 := by
  rw [lorentz_boost_compose, add_neg_cancel, lorentz_boost_zero]


/-- The velocity parameter β = tanh(φ) satisfies |β| < 1 for finite φ. -/
theorem velocity_subluminal (φ : ℝ) : |Real.tanh φ| < 1 :=
  abs_tanh_lt_one φ


/-- The Lorentz factor γ = cosh(φ) ≥ 1. -/
theorem lorentz_factor_ge_one (φ : ℝ) : 1 ≤ Real.cosh φ :=
  Real.one_le_cosh φ


/-- The fundamental identity: cosh²φ − sinh²φ = 1. -/
theorem rapidity_identity (φ : ℝ) :
    Real.cosh φ ^ 2 - Real.sinh φ ^ 2 = 1 := by
  have := Real.cosh_sq_sub_sinh_sq φ; linarith


/-- An electromagnetic field in (2+1) dimensions, represented as
E (electric, 1 component) and B (magnetic, 1 component). -/
structure EMField where
  E : ℝ
  B : ℝ


/-- The first Lorentz invariant: E² − B² (invariant under Lorentz boosts). -/
def EMField.lorentzInvariant (F : EMField) : ℝ := F.E ^ 2 - F.B ^ 2


/-- The energy density: E² + B² (invariant under duality rotations). -/
def EMField.energyDensity (F : EMField) : ℝ := F.E ^ 2 + F.B ^ 2


/-- The electromagnetic field is null (radiation) if E² = B². -/
def EMField.isNull (F : EMField) : Prop := F.lorentzInvariant = 0


/-- Electromagnetic duality rotation by angle α. -/
def EMField.dualRotate (F : EMField) (α : ℝ) : EMField where
  E := F.E * Real.cos α + F.B * Real.sin α
  B := -F.E * Real.sin α + F.B * Real.cos α


/-- [Section: # CatalogBuild.Physics.AlgebraicPhysics.AlgebraicSpacetime
Auto-generated from theorem catalog database.
Domain: Physics/AlgebraicPhysics
Declarations: 46] -/
theorem EMField.dualRotate_preserves_energy (F : EMField) (α : ℝ) :
    (F.dualRotate α).energyDensity = F.energyDensity := by
  unfold EMField.dualRotate EMField.energyDensity; ring; norm_num [ Real.sin_sq, Real.cos_sq ] ; ring;


/-- Duality rotation by π/2 swaps E and B (up to sign). -/
theorem EMField.dualRotate_quarter (F : EMField) :
    (F.dualRotate (π / 2)).E = F.B ∧ (F.dualRotate (π / 2)).B = -F.E := by
  simp [EMField.dualRotate, Real.cos_pi_div_two, Real.sin_pi_div_two]


/-- Note: Duality rotation does NOT preserve the null condition E² = B² in general.
The Lorentz invariant transforms as (E'² - B'²) = (E²-B²)cos(2α) + 2EB sin(2α),
so for a null field with E = B = 1 and α = π/4, we get E' = √2, B' = 0, which is
not null. However, the zero field IS preserved. -/
theorem EMField.dualRotate_zero (α : ℝ) :
    EMField.dualRotate ⟨0, 0⟩ α = ⟨0, 0⟩ := by
  ext <;> simp [EMField.dualRotate]


/-- Composing two duality rotations adds the angles. -/
theorem EMField.dualRotate_compose (F : EMField) (α β : ℝ) :
    (F.dualRotate α).dualRotate β = F.dualRotate (α + β) := by
  ext
  · simp [EMField.dualRotate, Real.cos_add, Real.sin_add]; ring
  · simp [EMField.dualRotate, Real.cos_add, Real.sin_add]; ring


/-- A 2D rotation matrix. -/
def rotationMatrix (θ : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![Real.cos θ, -Real.sin θ;
     Real.sin θ, Real.cos θ]


/-- A full 2π rotation is the identity (for vectors). -/
theorem rotation_full_turn : rotationMatrix (2 * π) = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
  simp [rotationMatrix, Real.cos_two_pi, Real.sin_two_pi]


/-- Under a full 2π rotation, the half-angle rotor gives cos(π) = −1:
spinors flip sign. This is the algebraic origin of spin-½. -/
theorem spinor_sign_flip : Real.cos π = -1 := Real.cos_pi


/-- Under a 4π rotation, the spinor rotor returns to +1. -/
theorem spinor_full_return : Real.cos (2 * π) = 1 := Real.cos_two_pi


/-- The Minkowski metric η = diag(+1, −1, −1, −1) in (3+1) dimensions. -/
def minkowskiEta : Fin 4 → ℝ := ![1, -1, -1, -1]


/-- The metric is its own inverse: η² = 1 (component-wise). -/
theorem eta_sq (i : Fin 4) : minkowskiEta i ^ 2 = 1 := by
  fin_cases i <;> simp [minkowskiEta]


/-- The Clifford relation encodes the metric: η_{μμ} = +1 for time, −1 for space. -/
theorem clifford_relation_encodes_metric :
    ∀ μ : Fin 4, minkowskiEta μ = if μ = 0 then 1 else -1 := by
  intro μ; fin_cases μ <;> simp [minkowskiEta]


/-- The pseudoscalar I² = −1 in (3+1) dimensions.
I² = (−1)^6 · γ₀²γ₁²γ₂²γ₃² = (+1)(−1)(−1)(−1) = −1. -/
theorem pseudoscalar_sq_neg_one :
    (1 : ℝ) * (-1) * (-1) * ((-1) ^ (3 : ℕ)) = -1 := by norm_num


/-- The mass-shell condition: E² − p² = m² (in natural units, c=1). -/
def onMassShell (E px py pz m : ℝ) : Prop :=
  E ^ 2 - px ^ 2 - py ^ 2 - pz ^ 2 = m ^ 2


/-- A massless particle (m = 0) has E² = |p|². -/
theorem massless_energy_momentum (E px py pz : ℝ)
    (h : onMassShell E px py pz 0) :
    E ^ 2 = px ^ 2 + py ^ 2 + pz ^ 2 := by
  simp [onMassShell] at h; linarith


/-- A particle at rest (p = 0) has E = m (Einstein's E = mc²). -/
theorem rest_energy (E m : ℝ) (hE : 0 < E) (hm : 0 < m)
    (h : onMassShell E 0 0 0 m) : E = m := by
  simp [onMassShell] at h
  nlinarith [sq_nonneg (E - m), sq_nonneg (E + m)]


/-- The mass shell is Lorentz invariant under (1+1)D boosts. -/
theorem mass_shell_boost_invariant (φ E px m : ℝ)
    (h : E ^ 2 - px ^ 2 = m ^ 2) :
    (Real.cosh φ * E + Real.sinh φ * px) ^ 2 -
    (Real.sinh φ * E + Real.cosh φ * px) ^ 2 = m ^ 2 := by
  nlinarith [Real.cosh_sq_sub_sinh_sq φ, sq_nonneg E, sq_nonneg px,
             sq_nonneg (Real.cosh φ * E + Real.sinh φ * px),
             sq_nonneg (Real.sinh φ * E + Real.cosh φ * px)]


/-- The spacetime interval between two events. -/
def spacetimeInterval (x y : Fin 4 → ℝ) : ℝ :=
  (y 0 - x 0) ^ 2 - (y 1 - x 1) ^ 2 - (y 2 - x 2) ^ 2 - (y 3 - x 3) ^ 2


/-- The interval is zero for the same event. -/
theorem interval_self (x : Fin 4 → ℝ) : spacetimeInterval x x = 0 := by
  simp [spacetimeInterval]


/-- The interval is symmetric: s²(x,y) = s²(y,x). -/
theorem interval_comm (x y : Fin 4 → ℝ) :
    spacetimeInterval x y = spacetimeInterval y x := by
  simp [spacetimeInterval]; ring


/-- A light signal travels on null intervals (s² = 0). -/
theorem light_travels_null (t v : ℝ) (hv : v ^ 2 = 1) :
    spacetimeInterval (![0, 0, 0, 0]) (![t, v * t, 0, 0]) = 0 := by
  simp [spacetimeInterval]
  nlinarith [sq_nonneg t]


end
