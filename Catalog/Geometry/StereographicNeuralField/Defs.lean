import Mathlib

/-!
# Inverse Stereographic Neural Field Theory: Definitions

This module develops the formal mathematical foundation for transporting neural field
dynamics between the unit sphere S² and the Euclidean plane ℝ² via inverse stereographic
projection.

## Mathematical context

The stereographic projection identifies S² \ {north pole} with ℝ². Under this
identification, the round metric on S² becomes a conformally flat metric on ℝ²
with conformal factor (2/(1+|x|²))². This transforms the spherical Laplacian
into a weighted Euclidean operator, creating a dictionary between spherical
harmonic analysis and weighted elliptic PDE theory on the plane.
-/

noncomputable section

open scoped Topology
open Filter

/-! ## Inverse Stereographic Projection -/

/-- The inverse stereographic projection from ℝ² to ℝ³.
    Maps (x, y) ∈ ℝ² to (2x/(1+r²), 2y/(1+r²), (r²-1)/(1+r²)) ∈ S²
    where r² = x² + y². -/
def inverseStereographic (p : Fin 2 → ℝ) : Fin 3 → ℝ := fun i =>
  let r2 := p 0 ^ 2 + p 1 ^ 2
  match i with
  | 0 => 2 * p 0 / (1 + r2)
  | 1 => 2 * p 1 / (1 + r2)
  | 2 => (r2 - 1) / (1 + r2)

/-- The north pole (0, 0, 1) ∈ ℝ³, the unique point not in the image
    of inverse stereographic projection. -/
def northPole : Fin 3 → ℝ := ![0, 0, 1]

/-- The denominator 1 + x² + y² appearing in stereographic formulas. -/
def stereoDenom (p : Fin 2 → ℝ) : ℝ := 1 + p 0 ^ 2 + p 1 ^ 2

/-- The stereographic conformal weight factor 2/(1 + |x|²). The round metric
    on S² pulls back to (stereoWeight p)² · g_Euclidean. -/
def stereoWeight (p : Fin 2 → ℝ) : ℝ := 2 / stereoDenom p

/-- The squared conformal weight, the conformal factor relating spherical
    and Euclidean metrics: ds²_S² = stereoMetricWeight · ds²_ℝ². -/
def stereoMetricWeight (p : Fin 2 → ℝ) : ℝ := (stereoWeight p) ^ 2

/-! ## Neural Field Structure -/

/-- A `StereographicNeuralField` packages a function on the sphere together
    with its pullback to the plane via inverse stereographic projection.

    This is the formal foundation for transporting neural field equations
    between spherical cortical geometry and planar Euclidean coordinates. -/
structure StereographicNeuralField where
  /-- The field on the sphere (as a function on ℝ³) -/
  uSphere : (Fin 3 → ℝ) → ℝ
  /-- The corresponding field on the plane -/
  uPlane  : (Fin 2 → ℝ) → ℝ
  /-- Compatibility: the planar field is the pullback of the spherical field -/
  compatible : ∀ x : Fin 2 → ℝ, uPlane x = uSphere (inverseStereographic x)

/-! ## Abstract Laplacian and Eigenfunction Concepts -/

/-- A linear operator on functions from ℝ³ → ℝ (modeling the spherical Laplacian).
    Linearity is required to prove that eigenspaces are submodules. -/
structure SphericalLaplacian where
  /-- The operator action -/
  op : ((Fin 3 → ℝ) → ℝ) → (Fin 3 → ℝ) → ℝ
  /-- The operator is additive -/
  op_add : ∀ u v, op (u + v) = op u + op v
  /-- The operator is homogeneous -/
  op_smul : ∀ (c : ℝ) u, op (c • u) = c • op u

/-- A function u is a spherical eigenfunction of degree ℓ if
    L(u)(p) = -ℓ(ℓ+1) · u(p) for all p. -/
def IsSphereEigenfunction (L : SphericalLaplacian) (u : (Fin 3 → ℝ) → ℝ) (l : ℕ) : Prop :=
  ∀ p : Fin 3 → ℝ, L.op u p = -(↑l * (↑l + 1)) * u p

/-- An abstract Euclidean Laplacian on ℝ². -/
structure EuclideanLaplacian where
  /-- The operator action -/
  op : ((Fin 2 → ℝ) → ℝ) → (Fin 2 → ℝ) → ℝ

/-- The conformal transport property: the key identity relating the spherical
    Laplacian to the Euclidean Laplacian under inverse stereographic projection.

    Δ_E(u ∘ σ)(x) = (stereoMetricWeight x) · Δ_S(u)(σ(x))

    where stereoMetricWeight x = 4/(1+|x|²)². -/
def ConformalTransportProperty (LS : SphericalLaplacian) (LE : EuclideanLaplacian) : Prop :=
  ∀ (u : (Fin 3 → ℝ) → ℝ) (x : Fin 2 → ℝ),
    LE.op (fun y => u (inverseStereographic y)) x =
    stereoMetricWeight x * LS.op u (inverseStereographic x)

/-! ## Weighted Planar Operator -/

/-- A function v on ℝ² is a weighted planar mode of degree ℓ if it satisfies
    Δ_E(v)(x) = -(4ℓ(ℓ+1)/(1+|x|²)²) · v(x). -/
def IsWeightedMode (LE : EuclideanLaplacian) (l : ℕ) (v : (Fin 2 → ℝ) → ℝ) : Prop :=
  ∀ x : Fin 2 → ℝ, LE.op v x = -(4 * ↑l * (↑l + 1) / (stereoDenom x) ^ 2) * v x

/-! ## Radial Kernel and Mode Selection -/

/-- A radial kernel on the sphere, specified by its spectral coefficients.
    For each degree ℓ, the kernel has eigenvalue `eigenval ℓ` on the
    degree-ℓ spherical harmonic subspace. -/
structure RadialSphereKernel where
  /-- The eigenvalue of the kernel on degree-ℓ harmonics -/
  eigenval : ℕ → ℝ

/-- Degree N is the unique maximum mode for a radial kernel if its
    eigenvalue at N strictly exceeds all others. -/
def IsUniqueMaxMode (K : RadialSphereKernel) (N : ℕ) : Prop :=
  ∀ l : ℕ, l ≠ N → K.eigenval l < K.eigenval N

/-- A Mexican-hat kernel with interaction radius parameter. -/
structure MexicanHatKernel extends RadialSphereKernel where
  /-- The interaction radius -/
  radius : ℝ
  /-- The radius is positive -/
  radius_pos : 0 < radius

end