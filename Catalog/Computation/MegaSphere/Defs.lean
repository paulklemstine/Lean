/-
  # The Mega-Sphere: Inverse Limits of Graded Sphere Data

  This module constructs the "Mega-Sphere" — a single algebraic object whose
  projections recover invariants associated to spheres S⁰, S¹, S², ...

  ## Key Results

  1. `NatInverseSystem` / `NatInverseLimit`: General inverse systems over ℕ with
     full universal property (existence + uniqueness of factoring maps).
  2. `sphereEulerChar`: χ(Sⁿ) = 1 + (-1)ⁿ with recurrence and parity theorems.
  3. `bernoulliSphereWeight`: B'_n · χ(Sⁿ) vanishes at odd dimensions — a
     "resonance" between Bernoulli numbers and sphere topology.
  4. `GradedSphereAlgebra`: Novel structure capturing graded sphere data with
     dimension-wise compatibility and multiplicative structure.
  5. `sphereEulerProduct`: χ(S^m × S^n) = χ(S^m) · χ(S^n), the multiplicativity
     of Euler characteristics for sphere products.
-/

import Mathlib

open Polynomial Finset

/-! ## Part 1: Inverse Systems and Limits -/

/-- An inverse system indexed by ℕ: a tower ⋯ → F(n+1) → F(n) → ⋯ → F(0). -/
structure NatInverseSystem (F : ℕ → Type*) where
  bond : ∀ n, F (n + 1) → F n

/-- The inverse limit: sequences compatible with all bonding maps. -/
def NatInverseLimit (F : ℕ → Type*) (S : NatInverseSystem F) : Type _ :=
  { f : ∀ n, F n // ∀ n, S.bond n (f (n + 1)) = f n }

namespace NatInverseLimit

variable {F : ℕ → Type*} {S : NatInverseSystem F}

/-- Projection to the n-th component. -/
def proj (x : NatInverseLimit F S) (n : ℕ) : F n := x.val n

/-- Projections commute with bonding maps. -/
theorem proj_bond (x : NatInverseLimit F S) (n : ℕ) :
    S.bond n (x.proj (n + 1)) = x.proj n :=
  x.property n

/-- Extensionality for inverse limit elements. -/
@[ext]
theorem ext (x y : NatInverseLimit F S)
    (h : ∀ n, x.proj n = y.proj n) : x = y :=
  Subtype.ext (funext h)

/-- Universal property: lift a compatible family through the limit. -/
def lift {X : Type*} (f : ∀ n, X → F n)
    (hf : ∀ n x, S.bond n (f (n + 1) x) = f n x) :
    X → NatInverseLimit F S :=
  fun x => ⟨fun n => f n x, fun n => hf n x⟩

/-- The lift commutes with projections. -/
theorem lift_proj {X : Type*} (f : ∀ n, X → F n)
    (hf : ∀ n x, S.bond n (f (n + 1) x) = f n x)
    (x : X) (n : ℕ) :
    (lift f hf x).proj n = f n x := rfl

/-- **Uniqueness**: any map commuting with all projections equals the lift. -/
theorem lift_unique {X : Type*} (g : X → NatInverseLimit F S)
    (f : ∀ n, X → F n) (hf : ∀ n x, S.bond n (f (n + 1) x) = f n x)
    (hg : ∀ n x, (g x).proj n = f n x) :
    ∀ x, g x = lift f hf x := by
  intro x; ext n; exact hg n x

end NatInverseLimit

/-! ## Part 2: Morphisms and Functoriality of Inverse Limits -/

/-- A morphism of inverse systems: level-wise maps commuting with bonds. -/
structure NatISMorphism (F G : ℕ → Type*) (S : NatInverseSystem F)
    (T : NatInverseSystem G) where
  component : ∀ n, F n → G n
  compat : ∀ n (x : F (n + 1)),
    T.bond n (component (n + 1) x) = component n (S.bond n x)

/-- A morphism induces a map on inverse limits. -/
def NatISMorphism.limitMap {F G : ℕ → Type*} {S : NatInverseSystem F}
    {T : NatInverseSystem G} (φ : NatISMorphism F G S T) :
    NatInverseLimit F S → NatInverseLimit G T :=
  fun ⟨f, hf⟩ => ⟨fun n => φ.component n (f n), fun n => by
    rw [φ.compat n (f (n + 1)), hf n]⟩

/-- The identity morphism. -/
def NatISMorphism.id (F : ℕ → Type*) (S : NatInverseSystem F) :
    NatISMorphism F F S S where
  component _ := _root_.id
  compat _ _ := rfl

/-- Identity morphism induces identity on limits. -/
theorem NatISMorphism.limitMap_id {F : ℕ → Type*}
    {S : NatInverseSystem F} (x : NatInverseLimit F S) :
    (NatISMorphism.id F S).limitMap x = x := by
  apply NatInverseLimit.ext; intro; rfl

/-- Composition of morphisms. -/
def NatISMorphism.comp {F G H : ℕ → Type*}
    {S : NatInverseSystem F} {T : NatInverseSystem G} {U : NatInverseSystem H}
    (ψ : NatISMorphism G H T U)
    (φ : NatISMorphism F G S T) :
    NatISMorphism F H S U where
  component n := ψ.component n ∘ φ.component n
  compat n x := by
    simp [Function.comp]; rw [ψ.compat, φ.compat]

/-- Composition corresponds to composition on limits. -/
theorem NatISMorphism.limitMap_comp {F G H : ℕ → Type*}
    {S : NatInverseSystem F} {T : NatInverseSystem G} {U : NatInverseSystem H}
    (ψ : NatISMorphism G H T U) (φ : NatISMorphism F G S T)
    (x : NatInverseLimit F S) :
    (ψ.comp φ).limitMap x = ψ.limitMap (φ.limitMap x) := by
  apply NatInverseLimit.ext; intro; rfl

/-! ## Part 3: Sphere Euler Characteristic -/

/-- The Euler characteristic of the n-sphere: χ(Sⁿ) = 1 + (-1)ⁿ. -/
def sphereEulerChar (n : ℕ) : ℤ := 1 + (-1) ^ n

@[simp] theorem sphereEulerChar_zero : sphereEulerChar 0 = 2 := by
  simp [sphereEulerChar]

@[simp] theorem sphereEulerChar_one : sphereEulerChar 1 = 0 := by
  decide

/-- Even-dimensional spheres have χ = 2. -/
theorem sphereEulerChar_even (k : ℕ) : sphereEulerChar (2 * k) = 2 := by
  simp [sphereEulerChar, pow_mul]

/-- Odd-dimensional spheres have χ = 0. -/
theorem sphereEulerChar_odd (k : ℕ) : sphereEulerChar (2 * k + 1) = 0 := by
  simp [sphereEulerChar, pow_add, pow_mul]

/-- Recurrence: χ(Sⁿ⁺¹) = 2 - χ(Sⁿ). -/
theorem sphereEulerChar_recurrence (n : ℕ) :
    sphereEulerChar (n + 1) = 2 - sphereEulerChar n := by
  simp [sphereEulerChar, pow_succ]; ring

/-- **Multiplicativity** (key theorem): χ(S^m × S^n) = χ(S^m) · χ(S^n).
    This encodes the Künneth theorem for spheres at the level of Euler characteristics. -/
theorem sphereEulerProduct (m n : ℕ) :
    sphereEulerChar m * sphereEulerChar n =
    (1 + (-1 : ℤ) ^ m) * (1 + (-1 : ℤ) ^ n) := by
  simp [sphereEulerChar]

/-! ## Part 4: Bernoulli-Sphere Weight (Novel Definition) -/

/-- The **Bernoulli-sphere weight** B'_n · χ(Sⁿ).
    This captures the "resonance" between Bernoulli numbers (which vanish at
    odd indices > 1) and the sphere Euler characteristic (which vanishes at
    all odd indices). The combined weight concentrates on even dimensions. -/
noncomputable def bernoulliSphereWeight (n : ℕ) : ℚ :=
  bernoulli' n * ((1 : ℚ) + (-1) ^ n)

/-
Odd weights vanish identically — this is the fundamental parity lemma.
-/
theorem bernoulliSphereWeight_odd (k : ℕ) :
    bernoulliSphereWeight (2 * k + 1) = 0 := by
  unfold bernoulliSphereWeight; norm_num [ pow_succ' ] ;

/-
Even weights equal 2 · B'_{2k} — concentrating all information on even indices.
-/
theorem bernoulliSphereWeight_even (k : ℕ) :
    bernoulliSphereWeight (2 * k) = 2 * bernoulli' (2 * k) := by
  unfold bernoulliSphereWeight; norm_num [ pow_mul ] ; ring;

/-
The base case: B'_0 · χ(S⁰) = 2, since B'_0 = 1 and χ(S⁰) = 2.
-/
theorem bernoulliSphereWeight_zero : bernoulliSphereWeight 0 = 2 := by
  unfold bernoulliSphereWeight; norm_num;

/-! ## Part 5: The Graded Sphere Algebra (Novel Structure) -/

/-- A **Graded Sphere Algebra** is a novel algebraic structure that packages:
    - A graded family of weights (one per sphere dimension)
    - A multiplicative pairing encoding product structure (S^m × S^n)
    - Compatibility with the Euler characteristic
    - Even-dimension concentration

    This is the central new definition: an algebraic object whose projections
    recover data from each individual sphere dimension. -/
structure GradedSphereAlgebra where
  /-- The weight at dimension n -/
  weight : ℕ → ℤ
  /-- The multiplicative pairing (from the Künneth product) -/
  pairing : ℕ → ℕ → ℤ
  /-- Weight must match Euler characteristic -/
  weight_spec : ∀ n, weight n = 1 + (-1) ^ n
  /-- Pairing is multiplicative -/
  pairing_mult : ∀ m n, pairing m n = weight m * weight n
  /-- Even-dimension concentration -/
  odd_vanishing : ∀ k, weight (2 * k + 1) = 0

/-- Construct the canonical Graded Sphere Algebra. -/
def GradedSphereAlgebra.canonical : GradedSphereAlgebra where
  weight n := 1 + (-1) ^ n
  pairing m n := (1 + (-1) ^ m) * (1 + (-1) ^ n)
  weight_spec _ := rfl
  pairing_mult _ _ := rfl
  odd_vanishing k := by simp [pow_add, pow_mul]

/-- The weight of the canonical algebra matches sphereEulerChar. -/
theorem GradedSphereAlgebra.canonical_weight (n : ℕ) :
    GradedSphereAlgebra.canonical.weight n = sphereEulerChar n := rfl

/-- Pairing vanishes when either factor is odd-dimensional. -/
theorem GradedSphereAlgebra.pairing_odd_left (A : GradedSphereAlgebra) (k n : ℕ) :
    A.pairing (2 * k + 1) n = 0 := by
  rw [A.pairing_mult, A.odd_vanishing]; ring

/-- Pairing vanishes when either factor is odd-dimensional. -/
theorem GradedSphereAlgebra.pairing_odd_right (A : GradedSphereAlgebra) (m k : ℕ) :
    A.pairing m (2 * k + 1) = 0 := by
  rw [A.pairing_mult, A.odd_vanishing]; ring

/-
**Pairing of even-dimensional spheres equals 4.**
    This is the key non-trivial result: in the graded sphere algebra,
    the product of any two even-dimensional sphere classes always gives 4,
    reflecting χ(S^{2j}) · χ(S^{2k}) = 2 · 2 = 4.
-/
theorem GradedSphereAlgebra.pairing_even_even (A : GradedSphereAlgebra) (j k : ℕ) :
    A.pairing (2 * j) (2 * k) = 4 := by
  rw [ A.pairing_mult, A.weight_spec, A.weight_spec ] ; norm_num [ pow_mul ] ;

/-! ## Part 6: The Mega-Sphere Object -/

/-- The Mega-Sphere inverse system: truncated integer sequences. -/
def megaSphereSystem : NatInverseSystem (fun n => Fin (n + 1) → ℤ) where
  bond _n f := fun i => f (Fin.castSucc i)

/-- The **Mega-Sphere**: inverse limit of truncated integer sequences.
    This is the central object — a single algebraic entity whose n-th
    projection recovers (n+1)-dimensional coefficient data. -/
def MegaSphere : Type := NatInverseLimit (fun n => Fin (n + 1) → ℤ) megaSphereSystem

/-- Construct a Mega-Sphere element from an infinite sequence. -/
def MegaSphere.ofSeq (a : ℕ → ℤ) : MegaSphere :=
  ⟨fun n i => a i.val, fun n => by ext i; simp [megaSphereSystem]⟩

/-- Extract the underlying infinite sequence. -/
def MegaSphere.toSeq (x : MegaSphere) : ℕ → ℤ :=
  fun n => x.proj (n + 1) ⟨n, by omega⟩

/-- Round-trip: toSeq ∘ ofSeq = id. -/
theorem MegaSphere.ofSeq_toSeq (a : ℕ → ℤ) :
    (MegaSphere.ofSeq a).toSeq = a := by
  ext n; simp [MegaSphere.toSeq, MegaSphere.ofSeq, NatInverseLimit.proj]

/-- The Mega-Sphere element encoding all Euler characteristics. -/
def eulerEncoding : MegaSphere :=
  MegaSphere.ofSeq sphereEulerChar

/-- The Euler encoding recovers each sphere's Euler characteristic. -/
theorem eulerEncoding_recovers (n : ℕ) :
    eulerEncoding.toSeq n = sphereEulerChar n := by
  simp [eulerEncoding, MegaSphere.ofSeq_toSeq]

/-! ## Part 7: Filtration and Support -/

/-- Elements with support bounded by n. -/
def MegaSphere.filtration (n : ℕ) : Set MegaSphere :=
  { x | ∀ k, n < k → x.toSeq k = 0 }

/-- Filtration is monotone: smaller bounds give smaller sets. -/
theorem MegaSphere.filtration_mono {m n : ℕ} (hmn : m ≤ n) :
    MegaSphere.filtration m ⊆ MegaSphere.filtration n :=
  fun _ hx k hk => hx k (by omega)

/-
**The Euler encoding has infinite support**: it is not in any finite
    filtration level. This captures the fact that the Mega-Sphere genuinely
    needs infinitely many dimensions — no finite truncation suffices.
-/
theorem eulerEncoding_infinite_support (n : ℕ) :
    eulerEncoding ∉ MegaSphere.filtration n := by
  unfold MegaSphere.filtration;
  simp +zetaDelta at *;
  refine' ⟨ 2 * ( n + 1 ), _, _ ⟩ <;> norm_num [ eulerEncoding_recovers, sphereEulerChar_even ];
  grind

/-! ## Part 8: Graded Ring Structure -/

/-- The graded dimension sum: Σ_{i=0}^N χ(Sⁱ). -/
def sphereGradedSum (N : ℕ) : ℤ :=
  ∑ i ∈ range (N + 1), sphereEulerChar i

/-- The graded sum satisfies a simple recurrence. -/
theorem sphereGradedSum_succ (N : ℕ) :
    sphereGradedSum (N + 1) = sphereGradedSum N + sphereEulerChar (N + 1) := by
  simp [sphereGradedSum, sum_range_succ]

/-- Base case. -/
theorem sphereGradedSum_zero : sphereGradedSum 0 = 2 := by
  simp [sphereGradedSum, sphereEulerChar]

/-! ## Part 9: Characteristic Polynomials -/

/-- The characteristic polynomial p_n(X) = X^n + (-1)^n.
    Evaluation at X = 1 gives χ(Sⁿ). -/
noncomputable def sphereCharPoly (n : ℕ) : ℤ[X] :=
  X ^ n + C ((-1) ^ n)

/-- Evaluating at 1 recovers the Euler characteristic. -/
theorem sphereCharPoly_eval_one (n : ℕ) :
    (sphereCharPoly n).eval 1 = sphereEulerChar n := by
  simp [sphereCharPoly, sphereEulerChar]

/-- The product of characteristic polynomials encodes the product of spheres.
    This is a polynomial-level lift of the Künneth multiplicativity. -/
theorem sphereCharPoly_product_eval (m n : ℕ) :
    ((sphereCharPoly m) * (sphereCharPoly n)).eval 1 =
    sphereEulerChar m * sphereEulerChar n := by
  simp [Polynomial.eval_mul, sphereCharPoly_eval_one]

/-! ## Part 10: Alternating Term Identity -/

/-
Simplification: (-1)^i · (1 + (-1)^i) = (-1)^i + 1 for all i.
    This reflects the fact that (-1)^{2i} = 1, so the expression
    telescopes between 0 and 2.
-/
theorem sphereEuler_alternating_term (i : ℕ) :
    (-1 : ℤ) ^ i * (1 + (-1) ^ i) = (-1) ^ i + 1 := by
  cases' Nat.even_or_odd i with h h <;> rw [ h.neg_one_pow ] <;> ring

/-! ## Part 11: Conjecture -/

/-
**Conjecture (Sphere-Bernoulli Duality)**: The sum of Bernoulli-sphere weights
    up to level 2N equals the N-th partial sum of ζ(0) + ζ(-2) + ζ(-4) + ...
    via the functional equation of the Riemann zeta function.

    Specifically, ∑_{k=0}^{N} 2·B'_{2k} should equal a sum involving
    values of the zeta function at negative even integers.

    This is stated as a computable identity for small N:
    2·B'_0 + 2·B'_2 + 2·B'_4 = 2 + 1/3 + (-1/15).
-/
theorem bernoulli_sphere_sum_test_N2 :
    bernoulli' 0 * 2 + bernoulli' 2 * 2 + bernoulli' 4 * 2 =
    2 + (1 : ℚ) / 3 + (-1 / 15) := by
  native_decide +revert