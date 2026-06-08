import Mathlib

/-!
# Berggren Orbits as Integral Lorentz Symmetries with Parity Shadow

This file establishes the algebraic backbone connecting Pythagorean triple
generation via the Berggren tree to integral Lorentz geometry and finite-state
parity dynamics.

## Main results

1. **Quadratic form invariance**: Each Berggren generator preserves the
   Pythagorean cone Q(x,y,z) = x² + y² - z², placing them in the integral
   Lorentz group O(2,1;ℤ).

2. **Orbit theorem**: Every triple reachable from (3,4,5) by iterated
   application of Berggren generators is Pythagorean.

3. **Parity shadow**: Berggren generators induce well-defined endomorphisms
   on (ℤ/2ℤ)³ preserving the parity relation x + y + z ≡ 0 (mod 2) that
   every primitive Pythagorean triple satisfies.

## Mathematical significance

The Pythagorean cone Q = 0 is the light cone of a (2+1)-dimensional Minkowski
space over ℤ. Berggren matrices are discrete Lorentz transformations. The mod-2
reduction exposes a finite-state stabilizer-like structure: a certified shadow
of the full integral symmetry acting on parity configurations.
-/

set_option maxHeartbeats 800000

namespace BerggrenQuantumBridge

/-! ## Core Definitions -/

/-- The Pythagorean quadratic form Q(v) = v₀² + v₁² - v₂². -/
def pythQuad (v : Fin 3 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- The Lorentz metric matrix η = diag(1, 1, -1). -/
def eta : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0;
     0, 1, 0;
     0, 0, -1]

/-- A matrix preserves the Pythagorean quadratic form iff Mᵀ η M = η. -/
def preservesPythQuad (M : Matrix (Fin 3) (Fin 3) ℤ) : Prop :=
  M.transpose * eta * M = eta

/-- Berggren generator A. -/
def berggrenA : Matrix (Fin 3) (Fin 3) ℤ :=
  !![ 1, -2,  2;
      2, -1,  2;
      2, -2,  3]

/-- Berggren generator B. -/
def berggrenB : Matrix (Fin 3) (Fin 3) ℤ :=
  !![ 1,  2,  2;
      2,  1,  2;
      2,  2,  3]

/-- Berggren generator C. -/
def berggrenC : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1,  2,  2;
     -2,  1,  2;
     -2,  2,  3]

/-! ## Section 1: Generator Preservation of the Quadratic Form -/

/-- Berggren A lies in O(2,1;ℤ): it preserves the Pythagorean cone. -/
theorem berggren_A_preserves : preservesPythQuad berggrenA := by
  unfold preservesPythQuad berggrenA eta
  native_decide

/-- Berggren B lies in O(2,1;ℤ). -/
theorem berggren_B_preserves : preservesPythQuad berggrenB := by
  unfold preservesPythQuad berggrenB eta
  native_decide

/-- Berggren C lies in O(2,1;ℤ). -/
theorem berggren_C_preserves : preservesPythQuad berggrenC := by
  unfold preservesPythQuad berggrenC eta
  native_decide

/-- All three generators lie in the integral Lorentz group. -/
theorem berggren_all_preserve :
    preservesPythQuad berggrenA ∧ preservesPythQuad berggrenB ∧ preservesPythQuad berggrenC :=
  ⟨berggren_A_preserves, berggren_B_preserves, berggren_C_preserves⟩

/-! ## Section 2: Quadratic Form Preservation implies Pythagorean Preservation -/

/-
Any matrix preserving η sends Pythagorean triples to Pythagorean triples.
    This is the key bridge: integral Lorentz symmetry ⟹ Pythagorean invariance.
-/
theorem berggren_map_pythagorean
    (M : Matrix (Fin 3) (Fin 3) ℤ)
    (hM : preservesPythQuad M)
    (v : Fin 3 → ℤ)
    (hv : pythQuad v = 0) :
    pythQuad (M.mulVec v) = 0 := by
  unfold pythQuad at *;
  convert congr_arg ( fun x : Fin 3 → ℤ => x 0 * v 0 + x 1 * v 1 + x 2 * v 2 ) ( congr_arg ( fun x : Matrix ( Fin 3 ) ( Fin 3 ) ℤ => x.mulVec v ) hM ) using 1 <;> simp +decide [ Matrix.mulVec, Fin.sum_univ_three ] ; ring!;
  · simp +decide [ Matrix.mul_apply, dotProduct, Fin.sum_univ_three ] ; ring!;
    simp +decide [ eta ] ; ring!;
  · simp +decide [ dotProduct, Fin.sum_univ_three, eta ];
    linarith

/-! ## Section 3: Berggren Reachability and Orbit Theorem -/

/-- Inductive type capturing all triples reachable from (3,4,5) via Berggren generators. -/
inductive BerggrenReachable : (Fin 3 → ℤ) → Prop
  | root : BerggrenReachable ![3, 4, 5]
  | stepA {v} : BerggrenReachable v → BerggrenReachable (berggrenA.mulVec v)
  | stepB {v} : BerggrenReachable v → BerggrenReachable (berggrenB.mulVec v)
  | stepC {v} : BerggrenReachable v → BerggrenReachable (berggrenC.mulVec v)

/-- The root triple (3,4,5) is Pythagorean. -/
theorem root_pythagorean : pythQuad ![3, 4, 5] = 0 := by native_decide

/-
Every triple reachable from (3,4,5) via Berggren generators is Pythagorean.
    This is the orbit theorem: the Berggren tree lives entirely on the light cone.
-/
theorem reachable_is_pythagorean
    (v : Fin 3 → ℤ)
    (hv : BerggrenReachable v) :
    pythQuad v = 0 := by
  induction' hv;
  · rfl;
  · exact berggren_map_pythagorean _ berggren_A_preserves _ ‹_›;
  · exact berggren_map_pythagorean _ berggren_B_preserves _ ‹_›;
  · exact berggren_map_pythagorean _ berggren_C_preserves _ ‹_›

/-! ## Section 4: Explicit Orbit Computations -/

/-- Berggren A sends (3,4,5) to (5,12,13). -/
theorem berggrenA_on_root :
    berggrenA.mulVec ![3, 4, 5] = ![5, 12, 13] := by
  native_decide

/-- Berggren B sends (3,4,5) to (21,20,29). -/
theorem berggrenB_on_root :
    berggrenB.mulVec ![3, 4, 5] = ![21, 20, 29] := by
  native_decide

/-- Berggren C sends (3,4,5) to (15,8,17). -/
theorem berggrenC_on_root :
    berggrenC.mulVec ![3, 4, 5] = ![15, 8, 17] := by
  native_decide

/-- (5,12,13) is Pythagorean — first-generation verification. -/
theorem child_A_pythagorean : pythQuad ![5, 12, 13] = 0 := by native_decide

/-- (21,20,29) is Pythagorean. -/
theorem child_B_pythagorean : pythQuad ![21, 20, 29] = 0 := by native_decide

/-- (15,8,17) is Pythagorean. -/
theorem child_C_pythagorean : pythQuad ![15, 8, 17] = 0 := by native_decide

/-! ## Section 5: Determinant Structure -/

/-- det(A) = 1: A is a proper Lorentz transformation. -/
theorem det_berggrenA : berggrenA.det = 1 := by native_decide

/-- det(B) = -1: B is an improper Lorentz transformation. -/
theorem det_berggrenB : berggrenB.det = -1 := by native_decide

/-- det(C) = 1: C is proper. -/
theorem det_berggrenC : berggrenC.det = 1 := by native_decide

/-! ## Section 6: Parity Shadow — Mod 2 Reduction -/

/-- Extract the parity vector of an integer vector. -/
def parityVec (v : Fin 3 → ℤ) : Fin 3 → ZMod 2 :=
  fun i => (v i : ZMod 2)

/-- The parity constraint: x + y + z ≡ 0 (mod 2).
    Every primitive Pythagorean triple satisfies this. -/
def parityConstraint (w : Fin 3 → ZMod 2) : Prop :=
  w 0 + w 1 + w 2 = 0

/-
Berggren generators preserve the parity constraint.
    This is the proto-stabilizer theorem: Berggren evolution preserves
    a linear invariant over the finite field GF(2).
-/
theorem berggren_preserves_parityConstraint
    (M : Matrix (Fin 3) (Fin 3) ℤ)
    (hM : M = berggrenA ∨ M = berggrenB ∨ M = berggrenC)
    (v : Fin 3 → ℤ)
    (hv : parityConstraint (parityVec v)) :
    parityConstraint (parityVec (M.mulVec v)) := by
  rcases hM with ( rfl | rfl | rfl ) <;> simp_all +decide [ parityConstraint, parityVec ];
  · simp_all +decide [ Fin.sum_univ_three, dotProduct, berggrenA ];
    grind +ring;
  · simp_all +decide [ Fin.sum_univ_three, Matrix.mulVec ];
    simp_all +decide [ Fin.sum_univ_three, dotProduct ];
    simp_all +decide [ berggrenB ];
    grind;
  · simp_all +decide [ Fin.sum_univ_three, Matrix.mulVec ];
    simp_all +decide [ Fin.sum_univ_three, dotProduct ];
    simp_all +decide [ berggrenC ];
    grind

/-- The root triple satisfies the parity constraint: 3+4+5 = 12 ≡ 0 (mod 2). -/
theorem root_parity : parityConstraint (parityVec ![3, 4, 5]) := by
  unfold parityConstraint parityVec
  native_decide

/-
Every reachable triple satisfies the parity constraint.
-/
theorem reachable_parityConstraint
    (v : Fin 3 → ℤ)
    (hv : BerggrenReachable v) :
    parityConstraint (parityVec v) := by
  induction' hv;
  · exact root_parity;
  · exact berggren_preserves_parityConstraint _ ( Or.inl rfl ) _ ‹_›;
  · grind +suggestions;
  · exact berggren_preserves_parityConstraint _ ( Or.inr <| Or.inr rfl ) _ ‹_›

/-! ## Section 7: Closure Under Products -/

/-
Products of Pythagorean-form-preserving matrices also preserve the form.
    This shows the set of such matrices forms a monoid.
-/
theorem preservesPythQuad_mul (M N : Matrix (Fin 3) (Fin 3) ℤ)
    (hM : preservesPythQuad M) (hN : preservesPythQuad N) :
    preservesPythQuad (M * N) := by
  unfold preservesPythQuad at *;
  simp_all +decide [ Matrix.mul_assoc ];
  simp_all +decide [ ← Matrix.mul_assoc ]

/-
The identity matrix preserves the Pythagorean quadratic form.
-/
theorem preservesPythQuad_one : preservesPythQuad (1 : Matrix (Fin 3) (Fin 3) ℤ) := by
  unfold preservesPythQuad;
  native_decide +revert

end BerggrenQuantumBridge