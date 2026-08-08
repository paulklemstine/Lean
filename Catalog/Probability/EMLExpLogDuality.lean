import Mathlib

/-!
# EML exp–log duality: the Lie algebra of the scaling group

This file makes precise, and proves, the statement that the *EML*
("exp-minus-log") exponential–logarithmic state space is isomorphic, as a Lie
algebra, to the algebra of infinitesimal *continuous scaling transformations*
`y ↦ c · y ^ k` of the positive half line.

## The picture

The catalog operation `eml x y = exp x - log y` couples an exponential slot to a
logarithmic slot.  Fixing the logarithmic slot, the natural symmetry group of
the state variable `y ∈ (0, ∞)` is the *scaling–power group*

`S = { y ↦ c * y ^ k : c > 0, k ≠ 0 }`,

which is conjugate, via `log : (0,∞) → ℝ`, to the affine group
`A = { x ↦ k * x + b }`.  Differentiating at the identity, `A` has the classical
two dimensional non-abelian Lie algebra `𝔞𝔣𝔣(1)` with basis `D` (dilation) and
`T` (translation) and relation `⁅D, T⁆ = T`.  The corresponding infinitesimal
*EML* generators are the vector fields

`emlField (a, b) (y) = y * (a * log y + b)`

on `(0, ∞)`, i.e. exactly the push-forwards of `affField (a, b) (x) = a * x + b`
along `exp`.

## Main results

* `EMLGen` : the two dimensional EML generator space with the bracket
  `⁅(a,b), (a',b')⁆ = (0, a * b' - a' * b)`, equipped with `LieRing` and
  `LieAlgebra ℝ` instances.
* `EMLExpLogDuality.lie_D_T`, `EMLExpLogDuality.center_trivial`,
  `EMLExpLogDuality.derived_eq_shiftLine`,
  `EMLExpLogDuality.second_derived_trivial` : structure theory of `EMLGen`
  (non-abelian, trivial centre, one dimensional derived algebra, solvable of
  derived length two, hence *not* nilpotent).
* `EMLExpLogDuality.emlMatrixEquiv` : an *explicit* Lie algebra isomorphism
  `EMLGen ≃ₗ⁅ℝ⁆ affMatrixAlgebra`, where `affMatrixAlgebra` is the Lie
  subalgebra `!![a, b; 0, 0]` of `2 × 2` real matrices, i.e. the Lie algebra of
  the affine (scaling + translation) group in its standard faithful
  representation.
* `EMLExpLogDuality.emlField_bracket` and `EMLExpLogDuality.affField_bracket` :
  both realizations reproduce the abstract bracket through the classical
  vector-field commutator `f g' - g f'`.
* `EMLExpLogDuality.expLog_intertwines_bracket` : the `exp`/`log` change of
  variables intertwines the two commutators; this is the analytic content of
  the duality.
* `EMLExpLogDuality.emlFlow_eq_scaling` : the flow of an EML vector field is
  *exactly* a one parameter subgroup of scaling transformations
  `y ↦ c(t) * y ^ k(t)`, together with `emlFlow_hasDerivAt` (it really is the
  flow) and `emlFlow_add` (it really is a one parameter group).
-/

noncomputable section

namespace EMLExpLogDuality

/-! ## The EML generator algebra -/

/-- An infinitesimal EML generator: `scale` is the coefficient of the dilation
generator `y ∂_y log y` and `shift` the coefficient of the pure scaling
generator `y ∂_y`. -/
@[ext]
structure EMLGen where
  /-- Coefficient of the dilation generator. -/
  scale : ℝ
  /-- Coefficient of the pure-scaling generator. -/
  shift : ℝ

namespace EMLGen

instance : Zero EMLGen := ⟨⟨0, 0⟩⟩
instance : Add EMLGen := ⟨fun g h => ⟨g.scale + h.scale, g.shift + h.shift⟩⟩
instance : Neg EMLGen := ⟨fun g => ⟨-g.scale, -g.shift⟩⟩
instance : Sub EMLGen := ⟨fun g h => ⟨g.scale - h.scale, g.shift - h.shift⟩⟩
instance : SMul ℕ EMLGen := ⟨fun n g => ⟨n • g.scale, n • g.shift⟩⟩
instance : SMul ℤ EMLGen := ⟨fun n g => ⟨n • g.scale, n • g.shift⟩⟩
instance : SMul ℝ EMLGen := ⟨fun c g => ⟨c * g.scale, c * g.shift⟩⟩

@[simp] lemma zero_scale : (0 : EMLGen).scale = 0 := rfl
@[simp] lemma zero_shift : (0 : EMLGen).shift = 0 := rfl
@[simp] lemma add_scale (g h : EMLGen) : (g + h).scale = g.scale + h.scale := rfl
@[simp] lemma add_shift (g h : EMLGen) : (g + h).shift = g.shift + h.shift := rfl
@[simp] lemma neg_scale (g : EMLGen) : (-g).scale = -g.scale := rfl
@[simp] lemma neg_shift (g : EMLGen) : (-g).shift = -g.shift := rfl
@[simp] lemma sub_scale (g h : EMLGen) : (g - h).scale = g.scale - h.scale := rfl
@[simp] lemma sub_shift (g h : EMLGen) : (g - h).shift = g.shift - h.shift := rfl
@[simp] lemma nsmul_scale (n : ℕ) (g : EMLGen) : (n • g).scale = n • g.scale := rfl
@[simp] lemma nsmul_shift (n : ℕ) (g : EMLGen) : (n • g).shift = n • g.shift := rfl
@[simp] lemma zsmul_scale (n : ℤ) (g : EMLGen) : (n • g).scale = n • g.scale := rfl
@[simp] lemma zsmul_shift (n : ℤ) (g : EMLGen) : (n • g).shift = n • g.shift := rfl
@[simp] lemma smul_scale (c : ℝ) (g : EMLGen) : (c • g).scale = c * g.scale := rfl
@[simp] lemma smul_shift (c : ℝ) (g : EMLGen) : (c • g).shift = c * g.shift := rfl

instance : AddCommGroup EMLGen where
  add_assoc := by intros; ext <;> simp [add_assoc]
  zero_add := by intros; ext <;> simp
  add_zero := by intros; ext <;> simp
  add_comm := by intros; ext <;> simp [add_comm]
  neg_add_cancel := by intros; ext <;> simp
  sub_eq_add_neg := by intros; ext <;> simp [sub_eq_add_neg]
  nsmul := fun n g => n • g
  nsmul_zero := by intros; ext <;> simp
  nsmul_succ := by intros; ext <;> simp <;> ring
  zsmul := fun n g => n • g
  zsmul_zero' := by intros; ext <;> simp
  zsmul_succ' := by intros; ext <;> simp [add_smul]
  zsmul_neg' := by intros; ext <;> simp [Int.negSucc_eq] <;> ring

instance : Module ℝ EMLGen where
  one_smul := by intros; ext <;> simp
  mul_smul := by intros; ext <;> simp [mul_assoc]
  smul_zero := by intros; ext <;> simp
  smul_add := by intros; ext <;> simp [mul_add]
  add_smul := by intros; ext <;> simp [add_mul]
  zero_smul := by intros; ext <;> simp

/-- The EML bracket: `⁅(a,b), (a',b')⁆ = (0, a b' - a' b)`. -/
instance : Bracket EMLGen EMLGen :=
  ⟨fun g h => ⟨0, g.scale * h.shift - h.scale * g.shift⟩⟩

@[simp] lemma bracket_scale (g h : EMLGen) : ⁅g, h⁆.scale = 0 := rfl

@[simp] lemma bracket_shift (g h : EMLGen) :
    ⁅g, h⁆.shift = g.scale * h.shift - h.scale * g.shift := rfl

instance : LieRing EMLGen where
  add_lie := by intros; ext <;> simp; ring
  lie_add := by intros; ext <;> simp; ring
  lie_self := by intros; ext <;> simp
  leibniz_lie := by intros; ext <;> simp; ring

instance : LieAlgebra ℝ EMLGen where
  lie_smul := by intros; ext <;> simp; ring

/-- The dilation generator `D = (1, 0)`. -/
def D : EMLGen := ⟨1, 0⟩

/-- The pure scaling generator `T = (0, 1)`. -/
def T : EMLGen := ⟨0, 1⟩

@[simp] lemma D_scale : D.scale = 1 := rfl
@[simp] lemma D_shift : D.shift = 0 := rfl
@[simp] lemma T_scale : T.scale = 0 := rfl
@[simp] lemma T_shift : T.shift = 1 := rfl

end EMLGen

open EMLGen

/-- The defining relation of the two dimensional non-abelian Lie algebra. -/
theorem lie_D_T : ⁅D, T⁆ = T := by ext <;> simp

/-- Every generator decomposes in the basis `{D, T}`. -/
theorem basis_decomposition (g : EMLGen) : g = g.scale • D + g.shift • T := by
  ext <;> simp

/-- `{D, T}` is linearly independent, so `EMLGen` really is two dimensional. -/
theorem D_T_independent (r s : ℝ) (h : r • D + s • T = 0) : r = 0 ∧ s = 0 := by
  have h1 : (r • D + s • T).scale = 0 := by rw [h]; simp
  have h2 : (r • D + s • T).shift = 0 := by rw [h]; simp
  simp at h1 h2
  exact ⟨h1, h2⟩

/-- The EML algebra is not abelian. -/
theorem not_abelian : ∃ g h : EMLGen, ⁅g, h⁆ ≠ 0 := by
  refine ⟨D, T, ?_⟩
  rw [lie_D_T]
  intro h
  have : (T : EMLGen).shift = 0 := by rw [h]; simp
  simp at this

/-- Every bracket is a multiple of `T`: the derived algebra is contained in the
scaling line. -/
theorem bracket_eq_smul_T (g h : EMLGen) :
    ⁅g, h⁆ = (g.scale * h.shift - h.scale * g.shift) • T := by
  ext <;> simp

/-- ... and it is *all* of the scaling line. -/
theorem derived_eq_shiftLine (c : ℝ) : ∃ g h : EMLGen, ⁅g, h⁆ = c • T :=
  ⟨D, ⟨0, c⟩, by ext <;> simp⟩

/-- The centre of the EML algebra is trivial. -/
theorem center_trivial (g : EMLGen) : (∀ h : EMLGen, ⁅g, h⁆ = 0) ↔ g = 0 := by
  constructor
  · intro h
    have h1 := congrArg EMLGen.shift (h T)
    have h2 := congrArg EMLGen.shift (h D)
    simp at h1 h2
    ext <;> simp [h1, h2]
  · rintro rfl h
    ext <;> simp

/-- The second derived algebra vanishes: `EMLGen` is solvable of derived
length two. -/
theorem second_derived_trivial (g h g' h' : EMLGen) : ⁅⁅g, h⁆, ⁅g', h'⁆⁆ = 0 := by
  ext <;> simp; ring

/-- The lower central series does *not* terminate: `EMLGen` is not nilpotent.
Iterating `ad D` on `T` always returns `T`. -/
theorem ad_D_iterate_T : ∀ n : ℕ, (fun g => ⁅D, g⁆)^[n] T = T := by
  intro n
  induction n with
  | zero => simp
  | succ k ih => rw [Function.iterate_succ_apply', ih, lie_D_T]


/-! ## The explicit matrix isomorphism with `𝔞𝔣𝔣(1)` -/

/-- The faithful `2 × 2` matrix representation of an EML generator:
`(a, b) ↦ !![a, b; 0, 0]`, the standard representation of the Lie algebra of the
affine (scaling ⋉ translation) group. -/
def toMatrix (g : EMLGen) : Matrix (Fin 2) (Fin 2) ℝ := !![g.scale, g.shift; 0, 0]

@[simp] lemma toMatrix_apply_zero_zero (g : EMLGen) : toMatrix g 0 0 = g.scale := rfl
@[simp] lemma toMatrix_apply_zero_one (g : EMLGen) : toMatrix g 0 1 = g.shift := rfl
@[simp] lemma toMatrix_apply_one_zero (g : EMLGen) : toMatrix g 1 0 = 0 := rfl
@[simp] lemma toMatrix_apply_one_one (g : EMLGen) : toMatrix g 1 1 = 0 := rfl

lemma toMatrix_injective : Function.Injective toMatrix := by
  intro g h hgh
  ext
  · simpa using congrArg (fun A => A 0 0) hgh
  · simpa using congrArg (fun A => A 0 1) hgh

/-- The matrix representation is a morphism of Lie algebras. -/
def toMatrixLie : EMLGen →ₗ⁅ℝ⁆ Matrix (Fin 2) (Fin 2) ℝ where
  toFun := toMatrix
  map_add' := by
    intro g h
    ext i j
    fin_cases i <;> fin_cases j <;> simp [toMatrix]
  map_smul' := by
    intro c g
    ext i j
    fin_cases i <;> fin_cases j <;> simp [toMatrix]
  map_lie' := by
    intro g h
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [toMatrix, Ring.lie_def]; ring

@[simp] lemma toMatrixLie_apply (g : EMLGen) : toMatrixLie g = toMatrix g := rfl

/-- The Lie algebra `𝔞𝔣𝔣(1)` of infinitesimal scaling-plus-translation
transformations, realized as `2 × 2` matrices. -/
def affMatrixAlgebra : LieSubalgebra ℝ (Matrix (Fin 2) (Fin 2) ℝ) := toMatrixLie.range

/-- `𝔞𝔣𝔣(1)` consists exactly of the matrices with vanishing bottom row. -/
theorem mem_affMatrixAlgebra_iff (A : Matrix (Fin 2) (Fin 2) ℝ) :
    A ∈ affMatrixAlgebra ↔ A 1 0 = 0 ∧ A 1 1 = 0 := by
  constructor
  · rintro ⟨g, rfl⟩
    exact ⟨rfl, rfl⟩
  · rintro ⟨h0, h1⟩
    refine ⟨⟨A 0 0, A 0 1⟩, ?_⟩
    ext i j
    fin_cases i <;> fin_cases j <;> simp [toMatrix, h0, h1]

/-- **Explicit Lie algebra isomorphism.**  The EML generator space is isomorphic,
as a real Lie algebra, to the Lie algebra of the continuous scaling group in its
faithful two dimensional representation. -/
def emlMatrixEquiv : EMLGen ≃ₗ⁅ℝ⁆ affMatrixAlgebra :=
  LieEquiv.ofInjective toMatrixLie toMatrix_injective

@[simp] theorem emlMatrixEquiv_apply (g : EMLGen) :
    (emlMatrixEquiv g : Matrix (Fin 2) (Fin 2) ℝ) = !![g.scale, g.shift; 0, 0] :=
  LieEquiv.ofInjective_apply toMatrixLie toMatrix_injective g

/-- The isomorphism carries the abstract relation `⁅D, T⁆ = T` to the matrix
relation `!![1,0;0,0] * !![0,1;0,0] - !![0,1;0,0] * !![1,0;0,0] = !![0,1;0,0]`. -/
theorem matrix_relation :
    toMatrix D * toMatrix T - toMatrix T * toMatrix D = toMatrix T := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [toMatrix]


/-! ## Vector-field realizations and the exp–log intertwiner

The affine group acts on `ℝ` by `x ↦ k x + b`; its infinitesimal generators are
the affine vector fields `affField (a,b) = (a x + b) ∂_x`.  Conjugating by
`exp : ℝ → (0,∞)` turns these into the *EML fields* `emlField (a,b)`, the
infinitesimal continuous scaling transformations of the positive half line.
-/

/-- The coefficient of the commutator of the first order differential operators
`f ∂` and `h ∂`, i.e. `⁅f ∂, h ∂⁆ = (f h' - h f') ∂`. -/
def vfBracket (f h : ℝ → ℝ) : ℝ → ℝ := fun t => f t * deriv h t - h t * deriv f t

/-- The affine vector field attached to a generator: `(a x + b) ∂_x`. -/
def affField (g : EMLGen) : ℝ → ℝ := fun x => g.scale * x + g.shift

/-- The EML vector field attached to a generator: `y (a log y + b) ∂_y` on the
positive half line.  It is the push-forward of `affField g` along `exp`. -/
def emlField (g : EMLGen) : ℝ → ℝ := fun y => y * (g.scale * Real.log y + g.shift)

/-- The exp–log change of variables: an EML field is the push-forward of the
corresponding affine field. -/
theorem emlField_eq_pushforward (g : EMLGen) (y : ℝ) :
    emlField g y = y * affField g (Real.log y) := rfl

/-- Dually, an affine field is the pull-back of the EML field along `log`. -/
theorem affField_eq_pullback (g : EMLGen) (x : ℝ) :
    affField g x = emlField g (Real.exp x) / Real.exp x := by
  have hx : Real.exp x ≠ 0 := (Real.exp_pos x).ne'
  rw [emlField_eq_pushforward, Real.log_exp, mul_comm, mul_div_assoc, div_self hx, mul_one]

theorem affField_hasDerivAt (g : EMLGen) (x : ℝ) :
    HasDerivAt (affField g) g.scale x := by
  have h1 : HasDerivAt (fun z : ℝ => g.scale * z) (g.scale * 1) x :=
    (hasDerivAt_id x).const_mul g.scale
  have h2 := h1.add_const g.shift
  rw [mul_one] at h2
  exact h2

@[simp] theorem deriv_affField (g : EMLGen) (x : ℝ) : deriv (affField g) x = g.scale :=
  (affField_hasDerivAt g x).deriv

theorem emlField_hasDerivAt (g : EMLGen) {y : ℝ} (hy : y ≠ 0) :
    HasDerivAt (emlField g) (g.scale * Real.log y + g.shift + g.scale) y := by
  have hlog : HasDerivAt Real.log y⁻¹ y := Real.hasDerivAt_log hy
  have h1 : HasDerivAt (fun z : ℝ => g.scale * Real.log z + g.shift) (g.scale * y⁻¹) y :=
    ((hlog.const_mul g.scale).add_const g.shift)
  have h2 := (hasDerivAt_id y).mul h1
  convert h2 using 1
  simp only [id_eq]
  field_simp

@[simp] theorem deriv_emlField (g : EMLGen) {y : ℝ} (hy : y ≠ 0) :
    deriv (emlField g) y = g.scale * Real.log y + g.shift + g.scale :=
  (emlField_hasDerivAt g hy).deriv

/-- The affine realization computes the bracket, in the *opposite* order: the
map `g ↦ affField g` is an anti-isomorphism onto the affine vector fields.  This
is the usual left-action sign, not an accident of the definitions. -/
theorem affField_vfBracket (g h : EMLGen) :
    vfBracket (affField g) (affField h) = affField ⁅h, g⁆ := by
  funext x
  simp [vfBracket, affField]
  ring

/-- The same computation for the EML fields on the positive half line: the
logarithms cancel identically, leaving a pure scaling field. -/
theorem emlField_vfBracket (g h : EMLGen) {y : ℝ} (hy : y ≠ 0) :
    vfBracket (emlField g) (emlField h) y = emlField ⁅h, g⁆ y := by
  simp only [vfBracket, deriv_emlField g hy, deriv_emlField h hy, emlField,
    bracket_scale, bracket_shift]
  ring

/-- The sign flip `(a, b) ↦ (-a, b)` is an isomorphism onto the opposite
algebra; composing with it turns the vector-field realizations into genuine
Lie algebra homomorphisms. -/
def flipScale (g : EMLGen) : EMLGen := ⟨-g.scale, g.shift⟩

@[simp] lemma flipScale_scale (g : EMLGen) : (flipScale g).scale = -g.scale := rfl
@[simp] lemma flipScale_shift (g : EMLGen) : (flipScale g).shift = g.shift := rfl

theorem flipScale_bracket (g h : EMLGen) : ⁅flipScale h, flipScale g⁆ = flipScale ⁅g, h⁆ := by
  ext <;> simp; ring

/-- **Bracket-preserving affine realization.** -/
theorem affField_flip_vfBracket (g h : EMLGen) :
    vfBracket (affField (flipScale g)) (affField (flipScale h)) = affField (flipScale ⁅g, h⁆) := by
  rw [affField_vfBracket, flipScale_bracket]

/-- **Bracket-preserving EML realization.** -/
theorem emlField_flip_vfBracket (g h : EMLGen) {y : ℝ} (hy : y ≠ 0) :
    vfBracket (emlField (flipScale g)) (emlField (flipScale h)) y
      = emlField (flipScale ⁅g, h⁆) y := by
  rw [emlField_vfBracket _ _ hy, flipScale_bracket]

/-- **The exp–log intertwiner.**  Under `y = exp x` the EML commutator is the
push-forward of the affine commutator.  Together with injectivity of the two
realizations this is the analytic form of the duality: the Lie algebra of
infinitesimal EML transformations of `(0, ∞)` is isomorphic to the Lie algebra
of infinitesimal affine (scaling) transformations of `ℝ`. -/
theorem expLog_intertwines_bracket (g h : EMLGen) {y : ℝ} (hy : y ≠ 0) :
    vfBracket (emlField g) (emlField h) y
      = y * vfBracket (affField g) (affField h) (Real.log y) := by
  rw [emlField_vfBracket _ _ hy, affField_vfBracket, emlField_eq_pushforward]

/-- The affine realization is faithful. -/
theorem affField_injective : Function.Injective affField := by
  intro g h hgh
  have h0 := congrFun hgh 0
  have h1 := congrFun hgh 1
  simp [affField] at h0 h1
  ext
  · linarith [h0, h1]
  · exact h0

/-- The EML realization is faithful. -/
theorem emlField_injective : Function.Injective emlField := by
  intro g h hgh
  have h1 := congrFun hgh 1
  have he := congrFun hgh (Real.exp 1)
  have hexp : (0:ℝ) < Real.exp 1 := Real.exp_pos 1
  simp only [emlField, Real.log_one, Real.log_exp, mul_zero, zero_add, one_mul,
    mul_one] at h1 he
  have h2 : g.scale + g.shift = h.scale + h.shift := mul_left_cancel₀ hexp.ne' he
  ext
  · linarith
  · exact h1


/-! ## Flows: the EML exponential map lands in the scaling group -/

/-- `expIntegral a t = ∫₀ᵗ exp (a s) ds`, written without a case split in the
`a ≠ 0` branch. -/
def expIntegral (a t : ℝ) : ℝ := if a = 0 then t else (Real.exp (a * t) - 1) / a

@[simp] theorem expIntegral_zero_time (a : ℝ) : expIntegral a 0 = 0 := by
  unfold expIntegral
  split_ifs with h
  · rfl
  · simp

/-- The defining identity `a * ∫₀ᵗ exp(a s) ds + 1 = exp (a t)`. -/
theorem expIntegral_key (a t : ℝ) : a * expIntegral a t + 1 = Real.exp (a * t) := by
  unfold expIntegral
  split_ifs with h
  · simp [h]
  · field_simp
    ring

theorem expIntegral_hasDerivAt (a t : ℝ) :
    HasDerivAt (expIntegral a) (Real.exp (a * t)) t := by
  unfold expIntegral
  split_ifs with h
  · simpa [h] using hasDerivAt_id t
  · have h1 : HasDerivAt (fun s : ℝ => Real.exp (a * s)) (Real.exp (a * t) * a) t := by
      simpa using (Real.hasDerivAt_exp (a * t)).comp t ((hasDerivAt_id t).const_mul a)
    have h2 := (h1.sub_const 1).div_const a
    convert h2 using 1
    field_simp

/-- Addition formula for the flow parameter. -/
theorem expIntegral_add (a t s : ℝ) :
    expIntegral a (t + s) = Real.exp (a * t) * expIntegral a s + expIntegral a t := by
  unfold expIntegral
  split_ifs with h
  · simp [h, add_comm]
  · field_simp
    rw [mul_add, Real.exp_add]
    ring

/-- The flow of the affine vector field `affField g` through `x₀`. -/
def affFlow (g : EMLGen) (x₀ t : ℝ) : ℝ :=
  Real.exp (g.scale * t) * x₀ + g.shift * expIntegral g.scale t

@[simp] theorem affFlow_zero (g : EMLGen) (x₀ : ℝ) : affFlow g x₀ 0 = x₀ := by
  simp [affFlow]

/-- `affFlow` really is the flow of `affField`. -/
theorem affFlow_hasDerivAt (g : EMLGen) (x₀ t : ℝ) :
    HasDerivAt (affFlow g x₀) (affField g (affFlow g x₀ t)) t := by
  have h1 : HasDerivAt (fun s : ℝ => Real.exp (g.scale * s))
      (Real.exp (g.scale * t) * g.scale) t := by
    simpa using (Real.hasDerivAt_exp (g.scale * t)).comp t ((hasDerivAt_id t).const_mul g.scale)
  have h2 : HasDerivAt (fun s : ℝ => Real.exp (g.scale * s) * x₀)
      (Real.exp (g.scale * t) * g.scale * x₀) t := h1.mul_const x₀
  have h3 : HasDerivAt (fun s : ℝ => g.shift * expIntegral g.scale s)
      (g.shift * Real.exp (g.scale * t)) t :=
    (expIntegral_hasDerivAt g.scale t).const_mul g.shift
  have h4 := h2.add h3
  convert h4 using 1
  have hkey := expIntegral_key g.scale t
  simp only [affField, affFlow]
  rw [← hkey]
  ring

/-- The flow is a one parameter group. -/
theorem affFlow_add (g : EMLGen) (x₀ t s : ℝ) :
    affFlow g x₀ (t + s) = affFlow g (affFlow g x₀ s) t := by
  simp only [affFlow, expIntegral_add, mul_add, Real.exp_add]
  ring

/-- The flow of the EML vector field `emlField g` through `y₀ > 0`. -/
def emlFlow (g : EMLGen) (y₀ t : ℝ) : ℝ := Real.exp (affFlow g (Real.log y₀) t)

theorem emlFlow_pos (g : EMLGen) (y₀ t : ℝ) : 0 < emlFlow g y₀ t := Real.exp_pos _

@[simp] theorem emlFlow_zero (g : EMLGen) {y₀ : ℝ} (hy : 0 < y₀) : emlFlow g y₀ 0 = y₀ := by
  simp [emlFlow, Real.exp_log hy]

theorem emlFlow_add (g : EMLGen) (y₀ t s : ℝ) :
    emlFlow g y₀ (t + s) = emlFlow g (emlFlow g y₀ s) t := by
  simp only [emlFlow, Real.log_exp]
  rw [affFlow_add]

/-- **The flow of an EML vector field is a continuous scaling transformation.**
For every generator `g = (a, b)` and every time `t`,
`y ↦ emlFlow g y t` is the map `y ↦ c(t) * y ^ k(t)` with
`k(t) = exp (a t)` and `c(t) = exp (b ∫₀ᵗ exp (a s) ds)`. -/
theorem emlFlow_eq_scaling (g : EMLGen) {y₀ : ℝ} (hy : 0 < y₀) (t : ℝ) :
    emlFlow g y₀ t
      = Real.exp (g.shift * expIntegral g.scale t) * y₀ ^ (Real.exp (g.scale * t)) := by
  rw [Real.rpow_def_of_pos hy]
  simp only [emlFlow, affFlow, Real.exp_add]
  rw [mul_comm]
  congr 1
  rw [mul_comm]

/-- The time-`t` map of the flow is a scaling transformation with positive
prefactor, uniformly in the initial condition. -/
theorem emlFlow_mem_scalingGroup (g : EMLGen) (t : ℝ) :
    ∃ c k : ℝ, 0 < c ∧ ∀ y₀ : ℝ, 0 < y₀ → emlFlow g y₀ t = c * y₀ ^ k :=
  ⟨Real.exp (g.shift * expIntegral g.scale t), Real.exp (g.scale * t), Real.exp_pos _,
    fun _ hy => emlFlow_eq_scaling g hy t⟩

/-- `emlFlow` really is the flow of `emlField`: the exp–log duality transports
the affine flow to the scaling flow. -/
theorem emlFlow_hasDerivAt (g : EMLGen) (y₀ t : ℝ) :
    HasDerivAt (emlFlow g y₀) (emlField g (emlFlow g y₀ t)) t := by
  have h := (Real.hasDerivAt_exp (affFlow g (Real.log y₀) t)).comp t
    (affFlow_hasDerivAt g (Real.log y₀) t)
  convert h using 1
  simp only [emlField, emlFlow, Real.log_exp, affField]


/-! ## The exponential map of the scaling group

The time-one flow sends a generator `(a, b)` to the pair of scaling parameters
`(c, k) = (exp (b ∫₀¹ exp (a s) ds), exp a)`.  Its image is exactly the identity
component `k > 0` of the scaling group, and its derivative at `t = 0` recovers
the generator.  This is the Lie group / Lie algebra correspondence for the EML
duality, in explicit coordinates.
-/

/-- The exponential map of the EML/scaling group: the parameters `(c, k)` of the
time-one flow. -/
def emlExpMap (g : EMLGen) : ℝ × ℝ :=
  (Real.exp (g.shift * expIntegral g.scale 1), Real.exp g.scale)

theorem emlFlow_time_one (g : EMLGen) {y₀ : ℝ} (hy : 0 < y₀) :
    emlFlow g y₀ 1 = (emlExpMap g).1 * y₀ ^ (emlExpMap g).2 := by
  simpa [emlExpMap] using emlFlow_eq_scaling g hy 1

/-- **Surjectivity of the exponential map onto the identity component.**  Every
scaling transformation `y ↦ c * y ^ k` with `c > 0` and `k > 0` is the time-one
flow of a unique-in-form EML generator. -/
theorem emlExpMap_surjective {c k : ℝ} (hc : 0 < c) (hk : 0 < k) :
    ∃ g : EMLGen, emlExpMap g = (c, k) := by
  by_cases hk1 : k = 1
  · refine ⟨⟨0, Real.log c⟩, ?_⟩
    simp [emlExpMap, expIntegral, Real.exp_log hc, hk1]
  · have hlog : Real.log k ≠ 0 := Real.log_ne_zero_of_pos_of_ne_one hk hk1
    have hk1' : k - 1 ≠ 0 := sub_ne_zero.mpr hk1
    refine ⟨⟨Real.log k, Real.log c * Real.log k / (k - 1)⟩, ?_⟩
    have hI : expIntegral (Real.log k) 1 = (k - 1) / Real.log k := by
      simp only [expIntegral, if_neg hlog, mul_one, Real.exp_log hk]
    have hprod : Real.log c * Real.log k / (k - 1) * expIntegral (Real.log k) 1 = Real.log c := by
      rw [hI]
      field_simp
    simp [emlExpMap, hprod, Real.exp_log hc, Real.exp_log hk]

/-- The exponent produced by the exponential map is always positive. -/
theorem emlExpMap_expo_pos (g : EMLGen) : 0 < (emlExpMap g).2 := Real.exp_pos _

/-- **Sharpness of surjectivity.**  Together with `emlExpMap_surjective` this
identifies the image of the exponential map as exactly the identity component
`{(c, k) : c > 0, k > 0}`; in particular the inversion `y ↦ 1 / y` is *not* the
time-one flow of any EML generator. -/
theorem emlExpMap_not_surjective : ¬ ∃ g : EMLGen, emlExpMap g = (1, -1) := by
  rintro ⟨g, hg⟩
  have := emlExpMap_expo_pos g
  rw [hg] at this
  norm_num at this

/-- The scaling exponent `k(t) = exp (a t)` has derivative `a` at `t = 0`: the
dilation part of the generator is recovered from the group. -/
theorem exponent_hasDerivAt_zero (g : EMLGen) :
    HasDerivAt (fun t => Real.exp (g.scale * t)) g.scale 0 := by
  have h := (Real.hasDerivAt_exp (g.scale * 0)).comp 0 ((hasDerivAt_id (0:ℝ)).const_mul g.scale)
  simpa using h

/-- The scaling prefactor `log c(t) = b ∫₀ᵗ exp (a s) ds` has derivative `b` at
`t = 0`: the translation part of the generator is recovered from the group. -/
theorem prefactor_hasDerivAt_zero (g : EMLGen) :
    HasDerivAt (fun t => g.shift * expIntegral g.scale t) g.shift 0 := by
  have h := (expIntegral_hasDerivAt g.scale 0).const_mul g.shift
  simpa using h

/-- The flow through a positive point differentiates, at time zero, to the value
of the EML vector field there. -/
theorem emlFlow_hasDerivAt_zero (g : EMLGen) {y₀ : ℝ} (hy : 0 < y₀) :
    HasDerivAt (emlFlow g y₀) (emlField g y₀) 0 := by
  have h := emlFlow_hasDerivAt g y₀ 0
  rwa [emlFlow_zero g hy] at h


/-! ## Mathlib-level structure theory: solvable but not nilpotent -/

/-- The abelian ideal of pure scalings, `ℝ · T = {(0, b)}`. -/
def shiftIdeal : LieIdeal ℝ EMLGen where
  carrier := {g | g.scale = 0}
  add_mem' := by
    intro a b ha hb
    simp only [Set.mem_setOf_eq] at *
    simp [ha, hb]
  zero_mem' := rfl
  smul_mem' := by
    intro c a ha
    simp only [Set.mem_setOf_eq] at *
    simp [ha]
  lie_mem := by
    intro x m _
    exact rfl

@[simp] lemma mem_shiftIdeal {g : EMLGen} : g ∈ shiftIdeal ↔ g.scale = 0 := Iff.rfl

/-- The derived algebra is contained in the pure scaling ideal. -/
theorem derivedSeries_one_le_shiftIdeal :
    LieAlgebra.derivedSeries ℝ EMLGen 1 ≤ shiftIdeal := by
  rw [LieAlgebra.derivedSeries_def, LieAlgebra.derivedSeriesOfIdeal_succ,
    LieSubmodule.lie_le_iff]
  intro x _ m _
  exact rfl

/-- **The derived algebra is exactly the pure scaling line.** -/
theorem derivedSeries_one_eq_shiftIdeal :
    LieAlgebra.derivedSeries ℝ EMLGen 1 = shiftIdeal := by
  refine le_antisymm derivedSeries_one_le_shiftIdeal ?_
  intro g hg
  have hg' : g.scale = 0 := hg
  have hmem : ⁅D, g⁆ ∈ ⁅(⊤ : LieIdeal ℝ EMLGen), (⊤ : LieIdeal ℝ EMLGen)⁆ :=
    LieSubmodule.lie_mem_lie trivial trivial
  have hDg : ⁅D, g⁆ = g := by ext <;> simp [hg']
  rw [hDg] at hmem
  rw [LieAlgebra.derivedSeries_def, LieAlgebra.derivedSeriesOfIdeal_succ]
  exact hmem

/-- The second derived algebra vanishes. -/
theorem derivedSeries_two_eq_bot : LieAlgebra.derivedSeries ℝ EMLGen 2 = ⊥ := by
  have h1 := derivedSeries_one_le_shiftIdeal
  rw [show (2 : ℕ) = 1 + 1 from rfl, LieAlgebra.derivedSeries_def,
    LieAlgebra.derivedSeriesOfIdeal_succ, ← LieAlgebra.derivedSeries_def,
    LieSubmodule.lie_eq_bot_iff]
  intro x hx m hm
  have hx' : x.scale = 0 := h1 hx
  have hm' : m.scale = 0 := h1 hm
  ext <;> simp [hx', hm']

/-- **The EML algebra is solvable.** -/
instance : LieAlgebra.IsSolvable EMLGen := LieAlgebra.IsSolvable.mk derivedSeries_two_eq_bot

/-- `T` survives every stage of the lower central series. -/
theorem T_mem_lowerCentralSeries :
    ∀ n : ℕ, T ∈ LieModule.lowerCentralSeries ℝ EMLGen EMLGen n := by
  intro n
  induction n with
  | zero => trivial
  | succ k ih =>
      rw [LieModule.lowerCentralSeries_succ]
      have : ⁅D, T⁆ ∈ ⁅(⊤ : LieIdeal ℝ EMLGen), LieModule.lowerCentralSeries ℝ EMLGen EMLGen k⁆ :=
        LieSubmodule.lie_mem_lie trivial ih
      rwa [lie_D_T] at this

/-- **The EML algebra is not nilpotent**, so the scaling group is solvable but
not unipotent: the exp–log duality is genuinely a duality of affine, not
Heisenberg-type, symmetry. -/
theorem not_isNilpotent : ¬ LieModule.IsNilpotent EMLGen EMLGen := by
  intro h
  obtain ⟨k, hk⟩ := LieModule.IsNilpotent.nilpotent ℝ EMLGen EMLGen
  have hT := T_mem_lowerCentralSeries k
  rw [hk] at hT
  have : (T : EMLGen) = 0 := hT
  have := congrArg EMLGen.shift this
  simp at this

end EMLExpLogDuality