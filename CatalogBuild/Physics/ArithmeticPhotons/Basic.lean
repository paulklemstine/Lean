/-! # CatalogBuild.Physics.ArithmeticPhotons.Basic

Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 37
-/

import Mathlib

/-- Null cone equivalence: Pythagorean quadruples ARE null vectors -/
theorem pythQuad_iff_null (a b c d : ℤ) :
    IsPythQuad a b c d ↔ lorentzQ a b c d = 0 := by
  unfold IsPythQuad lorentzQ; omega


/-- Causal classification -/
inductive CausalClass where
  | null : CausalClass      -- photon: Q = 0
  | timelike : CausalClass  -- massive: Q < 0
  | spacelike : CausalClass -- tachyonic: Q > 0
  deriving DecidableEq, Repr


/-- Every integer vector has exactly one causal type -/
def classify (a b c d : ℤ) : CausalClass :=
  if lorentzQ a b c d = 0 then .null
  else if lorentzQ a b c d < 0 then .timelike
  else .spacelike


/-- Null vectors classify as null -/
theorem null_classifies_null (a b c d : ℤ) (h : IsPythQuad a b c d) :
    classify a b c d = .null := by
  unfold classify
  rw [(pythQuad_iff_null a b c d).mp h]
  simp


/-- The standard parametrization of Pythagorean quadruples -/
def quadParam (m n p q : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (m^2 + n^2 - p^2 - q^2,
   2 * (m * q + n * p),
   2 * (n * q - m * p),
   m^2 + n^2 + p^2 + q^2)


/-- The parametrization always produces a valid Pythagorean quadruple -/
theorem quadParam_valid (m n p q : ℤ) :
    let ⟨a, b, c, d⟩ := quadParam m n p q
    IsPythQuad a b c d := by
  unfold quadParam IsPythQuad
  ring


theorem quad_1_4_8_9 : IsPythQuad 1 4 8 9 := by unfold IsPythQuad; norm_num

theorem quad_4_4_7_9 : IsPythQuad 4 4 7 9 := by unfold IsPythQuad; norm_num

theorem quad_2_6_9_11 : IsPythQuad 2 6 9 11 := by unfold IsPythQuad; norm_num

theorem quad_6_6_7_11 : IsPythQuad 6 6 7 11 := by unfold IsPythQuad; norm_num


/-- Projecting a quadruple to the (a,b) plane gives a deficit -/
theorem projection_deficit (a b c d : ℤ) (h : IsPythQuad a b c d) :
    a ^ 2 + b ^ 2 = d ^ 2 - c ^ 2 := by
  unfold IsPythQuad at h; linarith


/-- A quadruple with c = 0 degenerates to a Pythagorean triple -/
theorem quad_c_zero_is_triple (a b d : ℤ) (h : IsPythQuad a b 0 d) :
    a ^ 2 + b ^ 2 = d ^ 2 := by
  unfold IsPythQuad at h; linarith


/-- Permuting the spatial coordinates preserves the quadruple property -/
theorem pythQuad_perm_ab (a b c d : ℤ) (h : IsPythQuad a b c d) :
    IsPythQuad b a c d := by
  unfold IsPythQuad at *; linarith


/-- [Section: ## Part 6: Symmetries] -/
theorem pythQuad_perm_ac (a b c d : ℤ) (h : IsPythQuad a b c d) :
    IsPythQuad c b a d := by
  unfold IsPythQuad at *; linarith


theorem pythQuad_perm_bc (a b c d : ℤ) (h : IsPythQuad a b c d) :
    IsPythQuad a c b d := by
  unfold IsPythQuad at *; linarith


/-- Negating a spatial coordinate preserves the quadruple property -/
theorem pythQuad_neg_a (a b c d : ℤ) (h : IsPythQuad a b c d) :
    IsPythQuad (-a) b c d := by
  unfold IsPythQuad at *; ring_nf; linarith


theorem pythQuad_neg_b (a b c d : ℤ) (h : IsPythQuad a b c d) :
    IsPythQuad a (-b) c d := by
  unfold IsPythQuad at *; ring_nf; linarith


theorem pythQuad_neg_c (a b c d : ℤ) (h : IsPythQuad a b c d) :
    IsPythQuad a b (-c) d := by
  unfold IsPythQuad at *; ring_nf; linarith


/-- Scaling a quadruple by k gives a new quadruple -/
theorem pythQuad_scale (a b c d k : ℤ) (h : IsPythQuad a b c d) :
    IsPythQuad (k * a) (k * b) (k * c) (k * d) := by
  unfold IsPythQuad at *; nlinarith [sq_nonneg k]


/-- The Minkowski metric η = diag(1,1,1,-1) -/
def minkowskiMetric : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, (-1)]


/-- A matrix preserves the Lorentz form iff Mᵀ η M = η -/
def IsLorentzMatrix (M : Matrix (Fin 4) (Fin 4) ℤ) : Prop :=
  Mᵀ * minkowskiMetric * M = minkowskiMetric


/-- The identity is a Lorentz transformation -/
theorem id_is_lorentz : IsLorentzMatrix 1 := by
  unfold IsLorentzMatrix; simp


/-- The trivial family: (0, 0, d, d) is always a quadruple -/
theorem trivial_quadruple (d : ℤ) : IsPythQuad 0 0 d d := by
  unfold IsPythQuad; ring


/-- Key constructive family: (2mn, m²-n², 0, m²+n²) gives triples
embedded as quadruples (Euclid's parametrization) -/
theorem euclid_embed (m n : ℤ) :
    IsPythQuad (2 * m * n) (m ^ 2 - n ^ 2) 0 (m ^ 2 + n ^ 2) := by
  unfold IsPythQuad; ring


/-- The sum of two null vectors is generally NOT null -/
theorem null_sum_not_null :
    IsPythQuad 1 2 2 3 ∧ IsPythQuad 2 3 6 7 ∧
    ¬ IsPythQuad (1 + 2) (2 + 3) (2 + 6) (3 + 7) := by
  refine ⟨?_, ?_, ?_⟩ <;> unfold IsPythQuad <;> norm_num


/-- The Lorentz form is additive: Q(v + w) = Q(v) + Q(w) + 2η(v,w) -/
theorem lorentz_additivity (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    lorentzQ (a₁ + a₂) (b₁ + b₂) (c₁ + c₂) (d₁ + d₂) =
    lorentzQ a₁ b₁ c₁ d₁ + lorentzQ a₂ b₂ c₂ d₂ +
    2 * (a₁ * a₂ + b₁ * b₂ + c₁ * c₂ - d₁ * d₂) := by
  unfold lorentzQ; ring


/-- Two null vectors sum to null iff they are "Minkowski-orthogonal" -/
theorem null_sum_null_iff (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h₁ : IsPythQuad a₁ b₁ c₁ d₁) (h₂ : IsPythQuad a₂ b₂ c₂ d₂) :
    IsPythQuad (a₁ + a₂) (b₁ + b₂) (c₁ + c₂) (d₁ + d₂) ↔
    a₁ * a₂ + b₁ * b₂ + c₁ * c₂ = d₁ * d₂ := by
  rw [pythQuad_iff_null, lorentz_additivity,
      (pythQuad_iff_null _ _ _ _).mp h₁,
      (pythQuad_iff_null _ _ _ _).mp h₂]
  omega


/-- The Lorentz form is a quadratic form: Q(kv) = k²Q(v) -/
theorem lorentz_homogeneous (a b c d k : ℤ) :
    lorentzQ (k*a) (k*b) (k*c) (k*d) = k^2 * lorentzQ a b c d := by
  unfold lorentzQ; ring


/-- Q(0) = 0: the origin is null -/
theorem lorentz_zero : lorentzQ 0 0 0 0 = 0 := by
  unfold lorentzQ; ring


/-- Q(-v) = Q(v): the form is even -/
theorem lorentz_neg (a b c d : ℤ) :
    lorentzQ (-a) (-b) (-c) (-d) = lorentzQ a b c d := by
  unfold lorentzQ; ring


/-- A number n is a sum of three squares means ∃ a b c, a² + b² + c² = n -/
def IsSumThreeSquares (n : ℤ) : Prop :=
  ∃ a b c : ℤ, a ^ 2 + b ^ 2 + c ^ 2 = n


/-- d is a quadruple hypotenuse iff d² is a sum of three squares -/
theorem hypotenuse_iff_sum3sq (d : ℤ) :
    (∃ a b c : ℤ, IsPythQuad a b c d) ↔ IsSumThreeSquares (d ^ 2) := by
  unfold IsPythQuad IsSumThreeSquares
  constructor
  · rintro ⟨a, b, c, h⟩; exact ⟨a, b, c, h⟩
  · rintro ⟨a, b, c, h⟩; exact ⟨a, b, c, h⟩


/-- d² is always a sum of three squares (constructive: d² = d² + 0² + 0²) -/
theorem d_sq_is_sum3sq (d : ℤ) : IsSumThreeSquares (d ^ 2) := by
  exact ⟨d, 0, 0, by ring⟩


/-- Therefore every d is a quadruple hypotenuse -/
theorem every_d_is_hypotenuse (d : ℤ) : ∃ a b c : ℤ, IsPythQuad a b c d := by
  exact (hypotenuse_iff_sum3sq d).mpr (d_sq_is_sum3sq d)


/-- Two lattice points are photon-connected if their displacement is a quadruple -/
def PhotonConnected (v w : Fin 4 → ℤ) : Prop :=
  IsPythQuad (w 0 - v 0) (w 1 - v 1) (w 2 - v 2) (w 3 - v 3)


/-- Photon connectivity is symmetric (via negation symmetry of the Lorentz form) -/
theorem photon_connected_symm (v w : Fin 4 → ℤ) :
    PhotonConnected v w → PhotonConnected w v := by
  intro h
  unfold PhotonConnected IsPythQuad at *
  nlinarith [sq_nonneg (w 0 - v 0), sq_nonneg (v 0 - w 0),
             sq_nonneg (w 1 - v 1), sq_nonneg (v 1 - w 1),
             sq_nonneg (w 2 - v 2), sq_nonneg (v 2 - w 2),
             sq_nonneg (w 3 - v 3), sq_nonneg (v 3 - w 3)]


/-- Every point is photon-connected to itself (trivially, with zero displacement) -/
theorem photon_connected_refl (v : Fin 4 → ℤ) :
    PhotonConnected v v := by
  unfold PhotonConnected IsPythQuad
  simp

