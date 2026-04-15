/-! # CatalogBuild.Logic.UniversalSolver

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 37
-/

import Mathlib

noncomputable section

/-- Forward stereographic projection from the **north pole** (0,1).
σ_N(x, y) = x / (1 - y) for (x,y) on S¹ with y ≠ 1. -/
def stereoFromNorth' (x y : ℝ) : ℝ := x / (1 - y)


/-- Forward stereographic projection from the **south pole** (0,-1).
σ_S(x, y) = x / (1 + y) for (x,y) on S¹ with y ≠ -1. -/
def stereoFromSouth' (x y : ℝ) : ℝ := x / (1 + y)


/-- Inverse stereographic projection from the **north pole**.
σ_N⁻¹(t) = (2t/(1+t²), (t²-1)/(1+t²)) -/
def invStereoNorth' (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (t ^ 2 - 1) / (1 + t ^ 2))


/-- Inverse stereographic projection from the **south pole**.
σ_S⁻¹(t) = (2t/(1+t²), (1-t²)/(1+t²)) -/
def invStereoSouth' (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))


/-- The dual projection map: lift from south pole, project from north pole.
D(t) = σ_N(σ_S⁻¹(t)) -/
def dualProjection' (t : ℝ) : ℝ :=
  let p := invStereoSouth' t
  stereoFromNorth' p.1 p.2


/-- The mirror dual: lift from north pole, project from south pole.
D*(t) = σ_S(σ_N⁻¹(t)) -/
def mirrorDualProjection' (t : ℝ) : ℝ :=
  let p := invStereoNorth' t
  stereoFromSouth' p.1 p.2


/-- 1 + t² is always positive. -/
theorem one_plus_sq_pos' (t : ℝ) : (0 : ℝ) < 1 + t ^ 2 := by positivity


/-- The inverse stereographic projection from the south pole lands on S¹. -/
theorem invStereoSouth'_on_circle (t : ℝ) :
    (invStereoSouth' t).1 ^ 2 + (invStereoSouth' t).2 ^ 2 = 1 := by
  simp only [invStereoSouth']
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp; ring


/-- The inverse stereographic projection from the north pole lands on S¹. -/
theorem invStereoNorth'_on_circle (t : ℝ) :
    (invStereoNorth' t).1 ^ 2 + (invStereoNorth' t).2 ^ 2 = 1 := by
  simp only [invStereoNorth']
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp; ring


/-- The south-pole inverse never hits the south pole (y ≠ -1). -/
theorem invStereoSouth'_avoids_south (t : ℝ) :
    (invStereoSouth' t).2 ≠ -1 := by
  simp only [invStereoSouth']
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  intro heq
  have := (div_eq_iff h).mp heq
  nlinarith [sq_nonneg t]


/-- The north-pole inverse never hits the north pole (y ≠ 1). -/
theorem invStereoNorth'_avoids_north (t : ℝ) :
    (invStereoNorth' t).2 ≠ 1 := by
  simp only [invStereoNorth']
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  intro heq
  have := (div_eq_iff h).mp heq
  nlinarith [sq_nonneg t]


/-- [Section: ═══════════════════════════════════════════════════════════════════════
§2: THE DUAL PROJECTION IS A MÖBIUS TRANSFORMATION
Agent Beta: Matrix representation
═══════════════════════════════════════════════════════════════════════] -/
theorem dualProjection'_eq_inv (t : ℝ) (ht : t ≠ 0) :
    dualProjection' t = 1 / t := by
  unfold dualProjection' invStereoSouth' stereoFromNorth';
  -- Simplify the expression for the dual projection.
  field_simp [ht]
  ring


theorem mirrorDualProjection'_eq_inv (t : ℝ) (ht : t ≠ 0) :
    mirrorDualProjection' t = 1 / t := by
  unfold mirrorDualProjection' invStereoNorth' stereoFromSouth';
  field_simp;
  rw [ div_eq_iff ] <;> nlinarith [ mul_self_pos.2 ht ]


/-- The dual projections are equal: D = D*. The mirror is symmetric. -/
theorem dual_eq_mirror' (t : ℝ) (ht : t ≠ 0) :
    dualProjection' t = mirrorDualProjection' t := by
  rw [dualProjection'_eq_inv t ht, mirrorDualProjection'_eq_inv t ht]


/-- The dual projection is an involution: D(D(t)) = t. -/
theorem dualProjection'_involution (t : ℝ) (ht : t ≠ 0) :
    dualProjection' (dualProjection' t) = t := by
  rw [dualProjection'_eq_inv t ht]
  have h1t : (1 : ℝ) / t ≠ 0 := div_ne_zero one_ne_zero ht
  rw [dualProjection'_eq_inv (1/t) h1t]
  field_simp


/-- A Problem is a pair: a state space and a goal predicate. -/
structure Problem' (X : Type*) where
  state : X
  goal : X → Prop


/-- A Reducer transforms a problem into a simpler problem. -/
structure Reducer' (X Y : Type*) where
  encode : X → Y
  decode : Y → X
  roundTrip : ∀ x, decode (encode x) = x


/-- A ProjectionReducer works via idempotent projection. -/
structure ProjectionReducer' (n : ℕ) where
  project : (Fin n → ℝ) → (Fin n → ℝ)
  idem : ∀ v, project (project v) = project v


/-- A projection reducer is an oracle (from MetaOracle.lean). -/
def ProjectionReducer'.toOracle {n : ℕ} (P : ProjectionReducer' n) :
    Oracle (Fin n → ℝ) where
  consult := P.project
  idem := P.idem


/-- The composition of commuting idempotents is idempotent. -/
theorem idem_comp_of_comm' {X : Type*}
    (f g : X → X) (hf : ∀ x, f (f x) = f x) (hg : ∀ x, g (g x) = g x)
    (comm : ∀ x, f (g x) = g (f x)) :
    ∀ x, (f ∘ g) ((f ∘ g) x) = (f ∘ g) x := by
  intro x
  simp only [comp_def]
  show f (g (f (g x))) = f (g x)
  have : f (g x) = g (f x) := comm x
  conv_lhs => rw [this]
  rw [hg, ← this, hf]


/-- A linear oracle: an idempotent linear map (= projection matrix). -/
structure LinearOracle' (n : ℕ) where
  toFun : (Fin n → ℝ) →ₗ[ℝ] (Fin n → ℝ)
  idem : toFun.comp toFun = toFun


/-- A linear oracle projects onto its range. -/
theorem LinearOracle'.range_projection {n : ℕ} (P : LinearOracle' n) (v : Fin n → ℝ)
    (hv : v ∈ LinearMap.range P.toFun) :
    P.toFun v = v := by
  obtain ⟨w, hw⟩ := hv
  rw [← hw]
  have := LinearMap.ext_iff.mp P.idem w
  simp [LinearMap.comp_apply] at this
  exact this


/-- The composition of two commuting linear oracles is a linear oracle. -/
def LinearOracle'.compose {n : ℕ} (P Q : LinearOracle' n)
    (comm : P.toFun.comp Q.toFun = Q.toFun.comp P.toFun) : LinearOracle' n where
  toFun := P.toFun.comp Q.toFun
  idem := by
    ext v
    simp only [LinearMap.comp_apply]
    have hP := fun w => (LinearMap.ext_iff.mp P.idem w)
    have hQ := fun w => (LinearMap.ext_iff.mp Q.idem w)
    have hcomm := fun w => (LinearMap.ext_iff.mp comm w)
    simp only [LinearMap.comp_apply] at hP hQ hcomm
    simp only [hcomm, hQ, hP]


/-- The Universal Solver Theorem (finite-dimensional):
commuting linear projections compose to a single matrix multiply. -/
theorem universal_solver_finite' {n : ℕ} (P Q : LinearOracle' n)
    (comm : P.toFun.comp Q.toFun = Q.toFun.comp P.toFun) (v : Fin n → ℝ) :
    (LinearOracle'.compose P Q comm).toFun v = P.toFun (Q.toFun v) := by
  simp [LinearOracle'.compose, LinearMap.comp_apply]


/-- A SolverOracle: idempotent consultation. -/
structure SolverOracle' (X : Type*) where
  consult : X → X
  idem : ∀ x, consult (consult x) = consult x


/-- A MetaSolver selects which oracle to apply. -/
structure MetaSolver' (X : Type*) where
  oracles : Set (SolverOracle' X)
  select : X → SolverOracle' X
  valid : ∀ x, select x ∈ oracles
  stable : ∀ x, select ((select x).consult x) = select x


/-- One step of meta-oracle guided solving. -/
def MetaSolver'.step {X : Type*} (M : MetaSolver' X) (x : X) : X :=
  (M.select x).consult x


/-- The fixed points of a solver oracle. -/
def SolverOracle'.solved {X : Type*} (O : SolverOracle' X) : Set X :=
  {x | O.consult x = x}


/-- Consulting the oracle always produces a solved state. -/
theorem SolverOracle'.consult_solves {X : Type*} (O : SolverOracle' X) (x : X) :
    O.consult x ∈ O.solved := by
  simp [SolverOracle'.solved, O.idem]


/-- Any idempotent function is a solver oracle. -/
def oracleOfIdem' {X : Type*} (f : X → X) (hf : ∀ x, f (f x) = f x) :
    SolverOracle' X where
  consult := f
  idem := hf


/-- The Universal Solver Principle: one consultation suffices. -/
theorem universal_solver_principle' {X : Type*} (f : X → X)
    (hf : ∀ x, f (f x) = f x) (x : X) :
    (oracleOfIdem' f hf).consult x ∈ (oracleOfIdem' f hf).solved :=
  SolverOracle'.consult_solves _ x


/-- The FrozenCrystalSolver: a meta solver whose step is idempotent.
The frozen crystal solves any problem in one step: step(step(x)) = step(x). -/
structure FrozenCrystalSolver' (X : Type*) where
  /-- The underlying meta solver -/
  toMetaSolver : MetaSolver' X
  /-- Crystallization: the step output is already a fixed point of the selected oracle -/
  crystallized : ∀ x, toMetaSolver.step x ∈
    (toMetaSolver.select (toMetaSolver.step x)).solved


/-- The frozen crystal solves everything in one step. -/
theorem FrozenCrystalSolver'.one_step_solution {X : Type*}
    (C : FrozenCrystalSolver' X) (x : X) :
    C.toMetaSolver.step (C.toMetaSolver.step x) = C.toMetaSolver.step x := by
  have h := C.crystallized x
  simp only [MetaSolver'.step, SolverOracle'.solved, mem_setOf_eq] at h ⊢
  exact h


/-- The Möbius transformation corresponding to rotation by θ.
M_θ(t) = (t·cos(θ/2) + sin(θ/2)) / (-t·sin(θ/2) + cos(θ/2)) -/
def mobiusRotation' (θ t : ℝ) : ℝ :=
  (t * Real.cos (θ / 2) + Real.sin (θ / 2)) /
  (-t * Real.sin (θ / 2) + Real.cos (θ / 2))


/-- The identity Möbius transformation (θ = 0) is the identity. -/
theorem mobiusRotation'_zero (t : ℝ) :
    mobiusRotation' 0 t = t := by
  simp [mobiusRotation']


/-- The modular oracle projects to residues. -/
def modOracle' (m : ℤ) (hm : m ≠ 0) : SolverOracle' ℤ where
  consult := fun n => n % m
  idem := by intro n; exact Int.emod_emod_of_dvd n (dvd_refl m)


/-- The mod oracle's solved set is {0, 1, ..., m-1} for positive m. -/
theorem modOracle'_solved (m : ℤ) (hm : 0 < m) :
    (modOracle' m (ne_of_gt hm)).solved = {n : ℤ | 0 ≤ n ∧ n < m} := by
  ext n; simp [SolverOracle'.solved, modOracle']
  constructor
  · intro h
    constructor
    · linarith [Int.emod_nonneg n (ne_of_gt hm)]
    · linarith [Int.emod_lt_of_pos n hm]
  · intro ⟨h1, h2⟩; exact Int.emod_eq_of_lt h1 h2


end
