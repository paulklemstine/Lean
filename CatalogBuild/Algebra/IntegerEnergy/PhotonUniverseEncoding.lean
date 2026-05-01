/-! # CatalogBuild.Algebra.IntegerEnergy.PhotonUniverseEncoding

Auto-generated from theorem catalog database.
Domain: Algebra/IntegerEnergy
Declarations: 29
-/

import Mathlib

noncomputable section

/-- The null cone: the set of all null vectors. -/
def NullCone : Set (Fin 4 → ℝ) :=
  {k | IsNull k}


/-- A 4-vector is future-directed if its time component is positive. -/
def IsFutureDirected (k : Fin 4 → ℝ) : Prop :=
  k 0 > 0


/-- The future null cone: future-directed null vectors. -/
def FutureNullCone : Set (Fin 4 → ℝ) :=
  {k | IsNull k ∧ IsFutureDirected k}


/-- The inverse stereographic projection from ℝ² to the null cone.
This is THE fundamental map: it takes a point (u, v) on the celestial plane
and produces a null 4-vector. The energy parameter ω scales the result.
k^μ(u, v, ω) = ω · (1 + u² + v², 2u, 2v, 1 - u² - v²)
This is the heart of the hypothesis: the photon's worldline IS this map. -/
def inverseStereoNull (u v ω : ℝ) : Fin 4 → ℝ := fun i =>
  match i with
  | 0 => ω * (1 + u ^ 2 + v ^ 2)
  | 1 => ω * (2 * u)
  | 2 => ω * (2 * v)
  | 3 => ω * (1 - u ^ 2 - v ^ 2)


/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonUniverseEncoding
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 29] -/
theorem inverseStereoNull_in_future_cone (u v ω : ℝ) (hω : ω > 0) :
    inverseStereoNull u v ω ∈ FutureNullCone := by
      exact ⟨ inverseStereoNull_is_null u v ω, inverseStereoNull_future u v ω hω ⟩


/-- A point on the unit sphere S² in ℝ³. -/
def IsOnSphere (x y z : ℝ) : Prop :=
  x ^ 2 + y ^ 2 + z ^ 2 = 1


/-- The standard inverse stereographic projection from ℝ² to S².
Maps (u, v) ↦ (2u/(1+u²+v²), 2v/(1+u²+v²), (u²+v²-1)/(1+u²+v²)) -/
def inverseStereo (u v : ℝ) : Fin 3 → ℝ := fun i =>
  let r2 := u ^ 2 + v ^ 2
  match i with
  | 0 => 2 * u / (1 + r2)
  | 1 => 2 * v / (1 + r2)
  | 2 => (r2 - 1) / (1 + r2)


/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonUniverseEncoding
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 29] -/
theorem inverseStereo_on_sphere (u v : ℝ) :
    IsOnSphere (inverseStereo u v 0) (inverseStereo u v 1) (inverseStereo u v 2) := by
      unfold inverseStereo IsOnSphere; ring_nf; norm_num;
      -- Combine like terms and simplify the expression.
      field_simp
      ring


/-- The connection: the null vector k^μ = ω·(1+|z|², 2u, 2v, 1-|z|²) is related to
the sphere point (2u/(1+|z|²), 2v/(1+|z|²), (|z|²-1)/(1+|z|²)) by noting that
the spatial direction k/k⁰ = (2u/(1+|z|²), 2v/(1+|z|²), (1-|z|²)/(1+|z|²))
lies on S². This IS the celestial sphere! -/
def celestialDirection (u v : ℝ) : Fin 3 → ℝ := fun i =>
  let r2 := u ^ 2 + v ^ 2
  match i with
  | 0 => 2 * u / (1 + r2)
  | 1 => 2 * v / (1 + r2)
  | 2 => (1 - r2) / (1 + r2)


/-- [Section: # CatalogBuild.Physics.ArithmeticPhotons.PhotonUniverseEncoding
Auto-generated from theorem catalog database.
Domain: Physics/ArithmeticPhotons
Declarations: 29] -/
theorem celestialDirection_on_sphere (u v : ℝ) :
    IsOnSphere (celestialDirection u v 0) (celestialDirection u v 1)
               (celestialDirection u v 2) := by
                 unfold celestialDirection; unfold IsOnSphere; norm_num; ring; norm_cast; ring;
                 -- Combine like terms and simplify the expression.
                 field_simp
                 ring


theorem celestialDirection_is_normalized_null (u v ω : ℝ) (hω : ω ≠ 0) :
    ∀ i : Fin 3, celestialDirection u v i =
      inverseStereoNull u v ω (i.castSucc + 1) / inverseStereoNull u v ω 0 := by
        intro i; fin_cases i <;> unfold celestialDirection inverseStereoNull <;> norm_num ; ring;
        · grind;
        · grind +splitImp;
        · grind


/-- The determinant condition for Möbius transformations: ad - bc = 1. -/
def IsMobiusNormalized (a b c d : ℝ) : Prop :=
  a * d - b * c = 1


theorem bekensteinBound_nonneg (area : ℝ) (h : area ≥ 0) :
    bekensteinBound area ≥ 0 := by
      exact div_nonneg h zero_le_four


theorem bekensteinBound_mono {a₁ a₂ : ℝ} (h : a₁ ≤ a₂) :
    bekensteinBound a₁ ≤ bekensteinBound a₂ := by
      exact div_le_div_of_nonneg_right h zero_le_four


/-- The area of the celestial sphere at radius r. -/
def celestialSphereArea (r : ℝ) : ℝ := 4 * Real.pi * r ^ 2


theorem celestialSphereArea_nonneg (r : ℝ) :
    celestialSphereArea r ≥ 0 := by
      exact mul_nonneg ( mul_nonneg zero_le_four Real.pi_pos.le ) ( sq_nonneg r )


/-- The information capacity of the celestial sphere at radius r
is proportional to r². This is the maximum bits of universe-information
a photon can encode at distance r. -/
def photonInfoCapacity (r : ℝ) : ℝ :=
  bekensteinBound (celestialSphereArea r)


theorem photonInfoCapacity_eq (r : ℝ) :
    photonInfoCapacity r = Real.pi * r ^ 2 := by
      unfold photonInfoCapacity; unfold bekensteinBound; unfold celestialSphereArea; ring;


theorem photonInfoCapacity_unbounded :
    ∀ M : ℝ, ∃ r : ℝ, photonInfoCapacity r > M := by
      intro M
      use Real.sqrt (M / Real.pi + 1) + 1;
      unfold photonInfoCapacity;
      unfold bekensteinBound celestialSphereArea;
      by_cases hM : M / Real.pi + 1 ≥ 0;
      · nlinarith [ Real.pi_gt_three, mul_div_cancel₀ M Real.pi_ne_zero, Real.sqrt_nonneg ( M / Real.pi + 1 ), Real.mul_self_sqrt hM ];
      · rw [ Real.sqrt_eq_zero'.mpr ] <;> nlinarith [ Real.pi_pos, mul_div_cancel₀ M Real.pi_ne_zero ]


/-- A twistor is a pair (ω, π) ∈ ℂ² × ℂ² ≅ ℂ⁴.
We represent it using real coordinates as a point in ℝ⁸.
For a null twistor (one that corresponds to a null geodesic in spacetime),
the incidence relation ω^A = ix^{AA'}π_{A'} is satisfied. -/
structure Twistor where
  /-- The ω component (2 complex = 4 real) -/
  omega : Fin 4 → ℝ
  /-- The π component (2 complex = 4 real) -/
  pi : Fin 4 → ℝ


/-- A twistor is null if ω · π̄ + ω̄ · π = 0.
In real coordinates: Σᵢ ωᵢ πᵢ = 0. -/
def Twistor.isNull (Z : Twistor) : Prop :=
  ∑ i : Fin 4, Z.omega i * Z.pi i = 0


/-- The simplest twistor corresponding to a photon moving in the z-direction:
π = (1, 0) in complex coordinates, or (1, 0, 0, 0) in real coordinates.
ω = (0, 0) since x = 0 (the photon passes through the origin). -/
def zPhotonTwistor : Twistor where
  omega := ![0, 0, 0, 0]
  pi := ![1, 0, 0, 0]


theorem zPhotonTwistor_isNull : zPhotonTwistor.isNull := by
  exact show ∑ i : Fin 4, ( if i.val = 0 then 0 else if i.val = 1 then 0 else if i.val = 2 then 0 else 0 ) * ( if i.val = 0 then 1 else if i.val = 1 then 0 else if i.val = 2 then 0 else 0 ) = 0 from by norm_num [ Fin.sum_univ_four ] ;


lemma future_null_k0_plus_k3_nonneg (k : Fin 4 → ℝ) (hk : k ∈ FutureNullCone) :
    k 0 + k 3 ≥ 0 := by
      -- From the null condition, we have (k 0)^2 = (k 1)^2 + (k 2)^2 + (k 3)^2. Since squares are non-negative, this implies that (k 0)^2 ≥ (k 3)^2. Taking square roots (and considering that k 0 is positive), we get k 0 ≥ |k 3|.
      have h_k0_ge_abs_k3 : k 0 ^ 2 ≥ k 3 ^ 2 := by
        obtain ⟨hk_null, hk_fut⟩ := hk;
        unfold IsNull IsFutureDirected at *;
        unfold minkowskiInner at hk_null; linarith [ sq_nonneg ( k 1 ), sq_nonneg ( k 2 ), sq_nonneg ( k 3 ) ] ;
      nlinarith [ hk.2, show 0 ≤ k 0 from hk.2.le ]


lemma null_condition_rearranged (k : Fin 4 → ℝ) (hnull : IsNull k) :
    (k 0) ^ 2 = (k 1) ^ 2 + (k 2) ^ 2 + (k 3) ^ 2 := by
      unfold IsNull minkowskiInner at hnull; cases lt_or_ge ( k 0 ) 0 <;> cases lt_or_ge ( k 1 ) 0 <;> nlinarith;


lemma future_null_south_pole (k : Fin 4 → ℝ) (hk : k ∈ FutureNullCone)
    (hsum : k 0 + k 3 = 0) :
    k 1 = 0 ∧ k 2 = 0 := by
      -- Using the null condition, we have $(k 0)^2 = (k 1)^2 + (k 2)^2 + (k 3)^2$.
      have null_cond : (k 0) ^ 2 = (k 1) ^ 2 + (k 2) ^ 2 + (k 3) ^ 2 := by
        convert null_condition_rearranged k hk.1 using 1;
      simp_all +decide [ show k 3 = -k 0 by linarith ] ; constructor <;> nlinarith;


lemma inverseStereoNull_surj_standard (k : Fin 4 → ℝ)
    (hnull : IsNull k) (_hfut : IsFutureDirected k)
    (hsum : k 0 + k 3 > 0) :
    let u := k 1 / (k 0 + k 3)
    let v := k 2 / (k 0 + k 3)
    let ω := (k 0 + k 3) / 2
    ω > 0 ∧ inverseStereoNull u v ω = k := by
      unfold inverseStereoNull;
      grind +locals


theorem photon_worldline_is_inverseStereo_standard :
    ∀ k : Fin 4 → ℝ, k ∈ FutureNullCone → k 0 + k 3 > 0 →
      ∃ u v ω : ℝ, ω > 0 ∧ inverseStereoNull u v ω = k := by
        intro k hk hsum;
        have := inverseStereoNull_surj_standard k hk.1 hk.2 hsum;
        exact ⟨ _, _, _, this.1, this.2 ⟩


theorem photon_universe_encoding :
    (∀ M : ℝ, ∃ r : ℝ, photonInfoCapacity r > M) ∧
    (∀ k : Fin 4 → ℝ, k ∈ FutureNullCone → k 0 + k 3 > 0 →
      ∃ u v ω : ℝ, ω > 0 ∧ inverseStereoNull u v ω = k) := by
        exact ⟨ photonInfoCapacity_unbounded, fun k hk hk' => by obtain ⟨ u, v, ω, hω, h ⟩ := photon_worldline_is_inverseStereo_standard k hk hk'; exact ⟨ u, v, ω, hω, h ⟩ ⟩


end
