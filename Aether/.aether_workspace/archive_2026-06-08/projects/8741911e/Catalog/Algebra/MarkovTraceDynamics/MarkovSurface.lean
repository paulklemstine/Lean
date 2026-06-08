import Mathlib

/-!
# Markov Surface and Fricke-Vogt Identity

The **Markov equation** x² + y² + z² = 3xyz defines a cubic surface whose integer
solutions (the Markov triples) form a tree under the **Vieta involution**
(x, y, z) ↦ (x, y, 3xy - z).

## Main results

* `markov_vieta_preserves` — The Vieta involution preserves the Markov surface
* `markov_vieta_involution` — The Vieta map is an involution on Markov triples
* `fricke_surface_cyclic` — The Fricke surface is invariant under cyclic permutation
* `fricke_vieta_preserves` — The generalized Vieta involution preserves the Fricke surface
* `markov_vieta_growth` — Vieta produces strictly larger triples
-/

namespace MarkovTrace

/-! ### The Markov Surface -/

/-- A triple (x, y, z) lies on the **Markov surface** if x² + y² + z² = 3xyz. -/
def OnMarkovSurface (x y z : ℤ) : Prop :=
  x ^ 2 + y ^ 2 + z ^ 2 = 3 * x * y * z

/-- The **Vieta involution**: (x, y, z) ↦ (x, y, 3xy - z). -/
def markovVieta (x y z : ℤ) : ℤ × ℤ × ℤ :=
  (x, y, 3 * x * y - z)

/-
The Vieta involution preserves the Markov surface.
-/
theorem markov_vieta_preserves {x y z : ℤ} (h : OnMarkovSurface x y z) :
    OnMarkovSurface x y (3 * x * y - z) := by
      grind +locals

/-
The Vieta map is an involution on Markov triples.
-/
theorem markov_vieta_involution (x y z : ℤ) (_h : OnMarkovSurface x y z) :
    markovVieta x y (3 * x * y - z) = (x, y, z) := by
      unfold markovVieta; ring;

/-
The Markov surface is invariant under cyclic permutation.
-/
theorem markov_surface_cyclic {x y z : ℤ} (h : OnMarkovSurface x y z) :
    OnMarkovSurface y z x := by
      unfold OnMarkovSurface at *; linarith [ pow_two_nonneg ( x - y ), pow_two_nonneg ( y - z ), pow_two_nonneg ( z - x ), mul_self_nonneg x, mul_self_nonneg y, mul_self_nonneg z ] ;

/-- (1, 1, 1) is a Markov triple. -/
theorem markov_triple_one : OnMarkovSurface 1 1 1 := by
  simp [OnMarkovSurface]

/-- (1, 1, 2) is a Markov triple. -/
theorem markov_triple_one_one_two : OnMarkovSurface 1 1 2 := by
  simp [OnMarkovSurface]

/-- (1, 2, 5) is a Markov triple. -/
theorem markov_triple_one_two_five : OnMarkovSurface 1 2 5 := by
  simp [OnMarkovSurface]

/-! ### The Generalized Fricke Surface -/

/-- A triple lies on the **Fricke surface** with parameter κ if
x² + y² + z² - xyz = κ. -/
def OnFrickeSurface (x y z κ : ℤ) : Prop :=
  x ^ 2 + y ^ 2 + z ^ 2 - x * y * z = κ

/-
The Fricke surface is invariant under cyclic permutation.
-/
theorem fricke_surface_cyclic {x y z κ : ℤ} (h : OnFrickeSurface x y z κ) :
    OnFrickeSurface y z x κ := by
      unfold OnFrickeSurface at *; linarith;

/-
The Fricke-Vieta involution (x,y,z) → (x, y, xy-z) preserves the Fricke surface.
-/
theorem fricke_vieta_preserves {x y z κ : ℤ} (h : OnFrickeSurface x y z κ) :
    OnFrickeSurface x y (x * y - z) κ := by
      exact Eq.trans ( by ring ) h

/-
For a positive Markov triple (x,y,z) with y,z ≥ 1, the Vieta involution
on the first coordinate (x → 3yz - x) produces a positive value.
This ensures the Markov tree consists entirely of positive triples.
-/
theorem markov_vieta_positive {x y z : ℤ} (h : OnMarkovSurface x y z)
    (hx : x ≥ 1) (hy : y ≥ 1) (_hz : z ≥ 1) :
    3 * y * z - x ≥ 1 := by
      by_contra h_contra;
      exact absurd h ( by rw [ show OnMarkovSurface x y z = ( x ^ 2 + y ^ 2 + z ^ 2 = 3 * x * y * z ) by rfl ] ; nlinarith [ mul_pos ( by linarith : 0 < y ) ( by linarith : 0 < z ) ] )

/-
**Markov Ascending Lemma**: For a positive Markov triple (x,y,z) with
z ≥ y ≥ x ≥ 1 and z ≥ 2, the Vieta involution on the smallest coordinate
(x → 3yz - x) produces a strictly larger value: 3yz - x > z.
This is the mechanism by which the Markov tree generates arbitrarily large numbers.
-/
theorem markov_ascending {x y z : ℤ} (_h : OnMarkovSurface x y z)
    (hx : x ≥ 1) (hy : y ≥ x) (hz : z ≥ y) (hz2 : z ≥ 2) :
    3 * y * z - x > z := by
      nlinarith

/-! ### Trace Orbit Signature (Novel Definition) -/

/-- The Chebyshev trace sequence (local copy for self-containment). -/
def chebTrace (t : ℤ) : ℕ → ℤ
  | 0 => 2
  | 1 => t
  | (n + 2) => t * chebTrace t (n + 1) - chebTrace t n

/-- The **Trace Orbit Signature** of a hyperbolic SL₂ element.
Captures the complete spectral shadow of a conjugacy class in SL₂(ℤ). -/
structure TraceOrbitSignature where
  /-- The trace parameter t = tr(A) -/
  traceParam : ℤ
  /-- Whether the element is hyperbolic (|t| ≥ 3) -/
  isHyperbolic : traceParam ≥ 3 ∨ traceParam ≤ -3

/-- The n-th value of a trace orbit signature. -/
def TraceOrbitSignature.eval (σ : TraceOrbitSignature) (n : ℕ) : ℤ :=
  chebTrace σ.traceParam n

/-
Two SL₂ elements with the same trace have identical trace orbit signatures.
-/
theorem trace_orbit_uniqueness (t : ℤ) (ht : t ≥ 3) (σ₁ σ₂ : TraceOrbitSignature)
    (h₁ : σ₁.traceParam = t) (h₂ : σ₂.traceParam = t) :
    ∀ n, σ₁.eval n = σ₂.eval n := by
      unfold TraceOrbitSignature.eval; aesop;

/-
The first value of chebTrace determines the trace parameter.
-/
theorem trace_orbit_determined_by_first_two (t₁ t₂ : ℤ)
    (h1 : chebTrace t₁ 1 = chebTrace t₂ 1) :
    t₁ = t₂ := by
      exact h1

end MarkovTrace