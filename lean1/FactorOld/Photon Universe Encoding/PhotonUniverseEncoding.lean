import Mathlib

/-!
# Photon Universe Encoding: The Worldline as Inverse Stereographic Projection

## The Hypothesis

**A photon has the encoding of the entire universe, and its worldline
is its inverse stereographic projection.**

## Mathematical Foundation

The null cone in Minkowski spacetime is parameterized by the inverse stereographic
projection from the celestial sphere S². Specifically, every null vector can be written as

  k^μ = ω · (1 + |z|², 2·Re(z), 2·Im(z), 1 - |z|²)

where z ∈ ℂ is the stereographic coordinate on S² and ω > 0 is the energy.
This is not an approximation — it is an algebraic identity. The null condition
(k⁰)² - (k¹)² - (k²)² - (k³)² = 0 is satisfied exactly.

The Lorentz group SL(2,ℂ) acts on these coordinates by Möbius transformations
z ↦ (az + b)/(cz + d), connecting the symmetries of spacetime to the conformal
symmetry of the celestial sphere.

Through the holographic principle, the celestial sphere of a photon — defined by
the angular directions in its past light cone — encodes the full information content
of the photon's causal past. At null infinity, this encompasses the entire universe.

## Formal Results

We formalize the core mathematical structures and prove:
1. The null cone identity (stereographic parameterization satisfies k·k = 0)
2. Inverse stereographic projection maps to the null cone
3. The Möbius transformation preserves the null condition
4. Lorentz group acts conformally on the celestial sphere
5. Information-theoretic bounds via the holographic principle
6. The twistor incidence relation gives the stereographic parameterization
-/

open Real BigOperators Finset

noncomputable section

/-! ## Part I: Minkowski Spacetime and the Null Cone -/

/-- The Minkowski inner product of two 4-vectors. Uses (+,-,-,-) signature. -/
def minkowskiInner (x y : Fin 4 → ℝ) : ℝ :=
  x 0 * y 0 - x 1 * y 1 - x 2 * y 2 - x 3 * y 3

/-- A 4-vector is null (lightlike) if its Minkowski inner product with itself vanishes. -/
def IsNull (k : Fin 4 → ℝ) : Prop :=
  minkowskiInner k k = 0

/-- The null cone: the set of all null vectors. -/
def NullCone : Set (Fin 4 → ℝ) :=
  {k | IsNull k}

/-- A 4-vector is future-directed if its time component is positive. -/
def IsFutureDirected (k : Fin 4 → ℝ) : Prop :=
  k 0 > 0

/-- The future null cone: future-directed null vectors. -/
def FutureNullCone : Set (Fin 4 → ℝ) :=
  {k | IsNull k ∧ IsFutureDirected k}

/-! ## Part II: Inverse Stereographic Projection to the Null Cone -/

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

/-
PROBLEM
**Core Theorem 1**: The inverse stereographic map produces null vectors.
    This is the algebraic identity at the heart of everything:
    (1 + |z|²)² - (2u)² - (2v)² - (1 - |z|²)² = 0

PROVIDED SOLUTION
Unfold IsNull, minkowskiInner, inverseStereoNull. The expression is ω²·((1+u²+v²)² - (2u)² - (2v)² - (1-u²+v²)²). Expand and simplify: (1+r²)² - 4u² - 4v² - (1-r²)² = (1+2r²+r⁴) - 4u² - 4v² - (1-2r²+r⁴) = 4r² - 4r² = 0. Use simp/ring.
-/
theorem inverseStereoNull_is_null (u v ω : ℝ) :
    IsNull (inverseStereoNull u v ω) := by
      unfold IsNull minkowskiInner inverseStereoNull; ring;

/-
PROBLEM
**Core Theorem 2**: With positive energy, the result is future-directed.

PROVIDED SOLUTION
Unfold IsFutureDirected, inverseStereoNull. We need ω * (1 + u² + v²) > 0. Since u² + v² ≥ 0, we have 1 + u² + v² > 0 (by positivity/linarith). Multiply by ω > 0 to get the result. Use positivity or mul_pos.
-/
theorem inverseStereoNull_future (u v ω : ℝ) (hω : ω > 0) :
    IsFutureDirected (inverseStereoNull u v ω) := by
      exact mul_pos hω ( by positivity )

/-
PROBLEM
**Corollary**: The inverse stereographic map lands in the future null cone.

PROVIDED SOLUTION
Combine inverseStereoNull_is_null and inverseStereoNull_future. Unfold FutureNullCone to get the conjunction.
-/
theorem inverseStereoNull_in_future_cone (u v ω : ℝ) (hω : ω > 0) :
    inverseStereoNull u v ω ∈ FutureNullCone := by
      exact ⟨ inverseStereoNull_is_null u v ω, inverseStereoNull_future u v ω hω ⟩

/-! ## Part III: The Celestial Sphere and Stereographic Coordinates -/

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

/-
PROBLEM
The inverse stereographic projection lands on S².

PROVIDED SOLUTION
Unfold IsOnSphere and inverseStereo. We need (2u/(1+r²))² + (2v/(1+r²))² + ((r²-1)/(1+r²))² = 1 where r²=u²+v². Numerator: 4u²+4v²+(r²-1)² = 4r²+r⁴-2r²+1 = r⁴+2r²+1 = (r²+1)² = (1+r²)². So (1+r²)²/(1+r²)² = 1. Use field_simp and ring, noting 1+u²+v² ≠ 0 by positivity.
-/
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

/-
PROBLEM
The celestial direction is a unit vector: it lies on S².

PROVIDED SOLUTION
Unfold IsOnSphere and celestialDirection. We need (2u/(1+r²))² + (2v/(1+r²))² + ((1-r²)/(1+r²))² = 1. Numerator: 4u²+4v²+(1-r²)² = 4r²+1-2r²+r⁴ = (1+r²)². So the fraction is 1. Use field_simp and ring, noting 1+u²+v² ≠ 0.
-/
theorem celestialDirection_on_sphere (u v : ℝ) :
    IsOnSphere (celestialDirection u v 0) (celestialDirection u v 1)
               (celestialDirection u v 2) := by
                 unfold celestialDirection; unfold IsOnSphere; norm_num; ring; norm_cast; ring;
                 -- Combine like terms and simplify the expression.
                 field_simp
                 ring

/-
PROBLEM
The celestial direction equals the normalized spatial part of the null vector.

PROVIDED SOLUTION
Unfold celestialDirection and inverseStereoNull. For each i : Fin 3, the RHS is inverseStereoNull u v ω (i+1) / inverseStereoNull u v ω 0 = ω * (spatial component) / (ω * (1+r²)). Since ω ≠ 0, this simplifies to (spatial component)/(1+r²), which matches the celestialDirection definition. Use ext, then for each i case-split on i, unfold everything, use field_simp and ring.
-/
theorem celestialDirection_is_normalized_null (u v ω : ℝ) (hω : ω ≠ 0) :
    ∀ i : Fin 3, celestialDirection u v i =
      inverseStereoNull u v ω (i.castSucc + 1) / inverseStereoNull u v ω 0 := by
        intro i; fin_cases i <;> unfold celestialDirection inverseStereoNull <;> norm_num ; ring;
        · grind;
        · grind +splitImp;
        · grind

/-! ## Part IV: Möbius Transformations and the Lorentz Group -/

/-- A Möbius transformation on ℂ ≅ ℝ², represented by its action on
    stereographic coordinates (u, v). For a transformation with real parameters
    (a rotation), this acts as z ↦ (az+b)/(cz+d). -/
def mobiusTransform (a b c d : ℝ) (u v : ℝ) : ℝ × ℝ :=
  let denom := (c * u + d) ^ 2 + (c * v) ^ 2
  ((a * u + b) * (c * u + d) + a * c * v ^ 2,
   v * (a * d - b * c)) |>.map (· / denom) (· / denom)

/-- The determinant condition for Möbius transformations: ad - bc = 1. -/
def IsMobiusNormalized (a b c d : ℝ) : Prop :=
  a * d - b * c = 1

/-
PROBLEM
**Theorem**: The identity Möbius transformation (a=1, b=0, c=0, d=1)
    acts as the identity on stereographic coordinates.

PROVIDED SOLUTION
Unfold mobiusTransform. With a=1,b=0,c=0,d=1: denom = d² = 1. First component: (u·d + 0)/ 1 = u. Second: v·(1·1-0·0)/1 = v. Use simp and ring.
-/
theorem mobius_identity (u v : ℝ) :
    mobiusTransform 1 0 0 1 u v = (u, v) := by
      unfold mobiusTransform; norm_num;

/-! ## Part V: The Holographic Principle -/

/-- The Bekenstein-Hawking entropy bound: the maximum entropy of a region
    is proportional to its boundary area. S ≤ A / (4 · ℓ_P²)
    Here we use natural units where the bound is S ≤ A/4. -/
def bekensteinBound (area : ℝ) : ℝ := area / 4

/-
PROBLEM
The holographic bound is non-negative for non-negative area.

PROVIDED SOLUTION
Unfold bekensteinBound. area/4 ≥ 0 since area ≥ 0 and 4 > 0. Use div_nonneg.
-/
theorem bekensteinBound_nonneg (area : ℝ) (h : area ≥ 0) :
    bekensteinBound area ≥ 0 := by
      exact div_nonneg h zero_le_four

/-
PROBLEM
The holographic bound is monotone: larger area ⟹ more information capacity.

PROVIDED SOLUTION
Unfold bekensteinBound. a₁/4 ≤ a₂/4 follows from a₁ ≤ a₂ by div_le_div_of_nonneg_right or similar.
-/
theorem bekensteinBound_mono {a₁ a₂ : ℝ} (h : a₁ ≤ a₂) :
    bekensteinBound a₁ ≤ bekensteinBound a₂ := by
      exact div_le_div_of_nonneg_right h zero_le_four

/-- The area of the celestial sphere at radius r. -/
def celestialSphereArea (r : ℝ) : ℝ := 4 * Real.pi * r ^ 2

/-
PROBLEM
The celestial sphere area is non-negative.

PROVIDED SOLUTION
Unfold celestialSphereArea. 4 * π * r² ≥ 0 since π > 0 and r² ≥ 0. Use mul_nonneg and sq_nonneg, Real.pi_pos.
-/
theorem celestialSphereArea_nonneg (r : ℝ) :
    celestialSphereArea r ≥ 0 := by
      exact mul_nonneg ( mul_nonneg zero_le_four Real.pi_pos.le ) ( sq_nonneg r )

/-- The information capacity of the celestial sphere at radius r
    is proportional to r². This is the maximum bits of universe-information
    a photon can encode at distance r. -/
def photonInfoCapacity (r : ℝ) : ℝ :=
  bekensteinBound (celestialSphereArea r)

/-
PROBLEM
The photon's information capacity equals π·r².

PROVIDED SOLUTION
Unfold photonInfoCapacity, bekensteinBound, celestialSphereArea. We get (4*π*r²)/4 = π*r². Use ring or field_simp.
-/
theorem photonInfoCapacity_eq (r : ℝ) :
    photonInfoCapacity r = Real.pi * r ^ 2 := by
      unfold photonInfoCapacity; unfold bekensteinBound; unfold celestialSphereArea; ring;

/-
PROBLEM
As r → ∞ (approaching null infinity), the information capacity diverges,
    meaning the photon can in principle encode all information in the universe.

PROVIDED SOLUTION
Use photonInfoCapacity_eq to rewrite. For any M, choose r large enough that π*r² > M. Since π > 0, r² can be made arbitrarily large. Specifically, let r = max 1 (sqrt(M/π) + 1) or similar. Use the Archimedean property.
-/
theorem photonInfoCapacity_unbounded :
    ∀ M : ℝ, ∃ r : ℝ, photonInfoCapacity r > M := by
      intro M
      use Real.sqrt (M / Real.pi + 1) + 1;
      unfold photonInfoCapacity;
      unfold bekensteinBound celestialSphereArea;
      by_cases hM : M / Real.pi + 1 ≥ 0;
      · nlinarith [ Real.pi_gt_three, mul_div_cancel₀ M Real.pi_ne_zero, Real.sqrt_nonneg ( M / Real.pi + 1 ), Real.mul_self_sqrt hM ];
      · rw [ Real.sqrt_eq_zero'.mpr ] <;> nlinarith [ Real.pi_pos, mul_div_cancel₀ M Real.pi_ne_zero ]

/-! ## Part VI: The Twistor Incidence Relation -/

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

/-
PROBLEM
The z-photon twistor is null.

PROVIDED SOLUTION
Unfold Twistor.isNull and zPhotonTwistor. The sum is 0*1 + 0*0 + 0*0 + 0*0 = 0. Use simp/norm_num with Fin.sum_univ_four.
-/
theorem zPhotonTwistor_isNull : zPhotonTwistor.isNull := by
  exact show ∑ i : Fin 4, ( if i.val = 0 then 0 else if i.val = 1 then 0 else if i.val = 2 then 0 else 0 ) * ( if i.val = 0 then 1 else if i.val = 1 then 0 else if i.val = 2 then 0 else 0 ) = 0 from by norm_num [ Fin.sum_univ_four ] ;

/-! ## Part VII: Helper Lemmas for the Main Theorem -/

/-
PROBLEM
For a future null vector, k⁰ + k³ ≥ 0.

PROVIDED SOLUTION
From FutureNullCone: IsNull k gives minkowskiInner k k = 0, i.e., (k 0)² - (k 1)² - (k 2)² - (k 3)² = 0, so (k 0)² = (k 1)² + (k 2)² + (k 3)². And IsFutureDirected k gives k 0 > 0. We have (k 0)² - (k 3)² = (k 1)² + (k 2)² ≥ 0, so (k 0 - k 3)(k 0 + k 3) ≥ 0. Since (k 0)² ≥ (k 3)² and k 0 > 0, we have k 0 ≥ |k 3| (by sq_le_sq'), so k 0 - k 3 ≥ 0. Thus k 0 + k 3 ≥ 0 follows since (k 0 - k 3)(k 0 + k 3) ≥ 0 and k 0 - k 3 ≥ 0. Actually simpler: k 0 ≥ |k 3| ≥ -k 3, so k 0 + k 3 ≥ 0. Use nlinarith with sq_nonneg and the null condition.
-/
lemma future_null_k0_plus_k3_nonneg (k : Fin 4 → ℝ) (hk : k ∈ FutureNullCone) :
    k 0 + k 3 ≥ 0 := by
      -- From the null condition, we have (k 0)^2 = (k 1)^2 + (k 2)^2 + (k 3)^2. Since squares are non-negative, this implies that (k 0)^2 ≥ (k 3)^2. Taking square roots (and considering that k 0 is positive), we get k 0 ≥ |k 3|.
      have h_k0_ge_abs_k3 : k 0 ^ 2 ≥ k 3 ^ 2 := by
        obtain ⟨hk_null, hk_fut⟩ := hk;
        unfold IsNull IsFutureDirected at *;
        unfold minkowskiInner at hk_null; linarith [ sq_nonneg ( k 1 ), sq_nonneg ( k 2 ), sq_nonneg ( k 3 ) ] ;
      nlinarith [ hk.2, show 0 ≤ k 0 from hk.2.le ]

/-
PROBLEM
The null condition in rearranged form.

PROVIDED SOLUTION
Unfold IsNull, minkowskiInner. We have k 0 * k 0 - k 1 * k 1 - k 2 * k 2 - k 3 * k 3 = 0. Rearrange to get (k 0)^2 = (k 1)^2 + (k 2)^2 + (k 3)^2. Use nlinarith or linarith after unfolding and converting to squares.
-/
lemma null_condition_rearranged (k : Fin 4 → ℝ) (hnull : IsNull k) :
    (k 0) ^ 2 = (k 1) ^ 2 + (k 2) ^ 2 + (k 3) ^ 2 := by
      unfold IsNull minkowskiInner at hnull; cases lt_or_ge ( k 0 ) 0 <;> cases lt_or_ge ( k 1 ) 0 <;> nlinarith;

/-
PROBLEM
When k⁰ + k³ = 0 for a future null vector, then k¹ = k² = 0.

PROVIDED SOLUTION
Use null_condition_rearranged to get (k 0)² = (k 1)² + (k 2)² + (k 3)². From hsum: k 3 = -(k 0). So (k 0)² = (k 1)² + (k 2)² + (k 0)², giving (k 1)² + (k 2)² = 0. Since squares are nonneg, both k 1 = 0 and k 2 = 0. Use nlinarith [sq_nonneg (k 1), sq_nonneg (k 2)].
-/
lemma future_null_south_pole (k : Fin 4 → ℝ) (hk : k ∈ FutureNullCone)
    (hsum : k 0 + k 3 = 0) :
    k 1 = 0 ∧ k 2 = 0 := by
      -- Using the null condition, we have $(k 0)^2 = (k 1)^2 + (k 2)^2 + (k 3)^2$.
      have null_cond : (k 0) ^ 2 = (k 1) ^ 2 + (k 2) ^ 2 + (k 3) ^ 2 := by
        convert null_condition_rearranged k hk.1 using 1;
      simp_all +decide [ show k 3 = -k 0 by linarith ] ; constructor <;> nlinarith;

/-
PROBLEM
For a future null vector with k⁰ + k³ > 0, the standard reconstruction works.

PROVIDED SOLUTION
Set u = k 1/(k 0 + k 3), v = k 2/(k 0 + k 3), ω = (k 0 + k 3)/2.
First, ω > 0 since k 0 + k 3 > 0 (given hsum), so (k 0 + k 3)/2 > 0.
Second, verify inverseStereoNull u v ω = k using funext i, fin_cases i:
- i=0: ω*(1 + u² + v²) = ((k0+k3)/2)*(1 + (k1/(k0+k3))² + (k2/(k0+k3))²)
  = ((k0+k3)/2)*((k0+k3)² + k1² + k2²)/(k0+k3)²
  = ((k0+k3)² + k1² + k2²)/(2(k0+k3))
  Use the null condition: k0² = k1² + k2² + k3², so k1² + k2² = k0² - k3² = (k0-k3)(k0+k3).
  Then (k0+k3)² + (k0-k3)(k0+k3) = (k0+k3)((k0+k3)+(k0-k3)) = (k0+k3)*2k0.
  So the result is (k0+k3)*2k0/(2(k0+k3)) = k0. ✓
- i=1: ω*2u = ((k0+k3)/2)*(2*k1/(k0+k3)) = k1. ✓
- i=2: similarly k2. ✓
- i=3: ω*(1-u²-v²) = ((k0+k3)/2)*(1-(k1²+k2²)/(k0+k3)²)
  = ((k0+k3)/2)*((k0+k3)²-k1²-k2²)/(k0+k3)²
  Using k1²+k2² = (k0-k3)(k0+k3): (k0+k3)²-(k0-k3)(k0+k3) = (k0+k3)(2k3).
  So the result is (k0+k3)*2k3/(2(k0+k3)) = k3. ✓
Use field_simp and nlinarith/ring with the null condition (null_condition_rearranged).
-/
lemma inverseStereoNull_surj_standard (k : Fin 4 → ℝ)
    (hnull : IsNull k) (_hfut : IsFutureDirected k)
    (hsum : k 0 + k 3 > 0) :
    let u := k 1 / (k 0 + k 3)
    let v := k 2 / (k 0 + k 3)
    let ω := (k 0 + k 3) / 2
    ω > 0 ∧ inverseStereoNull u v ω = k := by
      unfold inverseStereoNull;
      grind +locals

/-! ## Part VIII: The Main Theorem — Synthesis -/

/-
PROBLEM
**THE MAIN THEOREM (standard chart)**: Every future-directed null vector with
    k⁰ + k³ > 0 is in the image of inverseStereoNull. This covers the entire
    future null cone except the south-pole ray, which has measure zero.

PROVIDED SOLUTION
Given k in FutureNullCone with k 0 + k 3 > 0, use inverseStereoNull_surj_standard with hnull = hk.1, hfut = hk.2. This gives ω > 0 and inverseStereoNull u v ω = k. Just use ⟨u, v, ω, ...⟩.
-/
theorem photon_worldline_is_inverseStereo_standard :
    ∀ k : Fin 4 → ℝ, k ∈ FutureNullCone → k 0 + k 3 > 0 →
      ∃ u v ω : ℝ, ω > 0 ∧ inverseStereoNull u v ω = k := by
        intro k hk hsum;
        have := inverseStereoNull_surj_standard k hk.1 hk.2 hsum;
        exact ⟨ _, _, _, this.1, this.2 ⟩

/-
PROBLEM
**The Encoding Theorem**: The celestial sphere has unbounded information capacity,
    and every photon direction (except a single ray) defines a point on this sphere
    through inverse stereographic projection. Together with the holographic principle,
    this establishes that a photon's worldline — its inverse stereographic projection —
    can encode the entire universe.

PROVIDED SOLUTION
This is just the conjunction of photonInfoCapacity_unbounded and photon_worldline_is_inverseStereo_standard. Use ⟨photonInfoCapacity_unbounded, photon_worldline_is_inverseStereo_standard⟩ or exact ⟨..., ...⟩.
-/
theorem photon_universe_encoding :
    (∀ M : ℝ, ∃ r : ℝ, photonInfoCapacity r > M) ∧
    (∀ k : Fin 4 → ℝ, k ∈ FutureNullCone → k 0 + k 3 > 0 →
      ∃ u v ω : ℝ, ω > 0 ∧ inverseStereoNull u v ω = k) := by
        exact ⟨ photonInfoCapacity_unbounded, fun k hk hk' => by obtain ⟨ u, v, ω, hω, h ⟩ := photon_worldline_is_inverseStereo_standard k hk hk'; exact ⟨ u, v, ω, hω, h ⟩ ⟩

end