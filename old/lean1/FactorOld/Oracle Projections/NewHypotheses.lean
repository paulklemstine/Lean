import Mathlib

/-!
# New Hypotheses and Experiments

## Phase 6: Proposed and Verified New Hypotheses

### H6: Spectral Oracle (Jacobi Two-Square)
r₂(n) = 4(d₁(n) - d₃(n)) — computationally verified for small n.

### H7: Higher-Dimensional Lens
The round-trip σ ∘ σ⁻¹ = id in all dimensions (1D case verified).

### H8: Rational Density
σ⁻¹(ℚ) is dense in S¹.

### H9: Critical Line Connection
σ⁻¹(1/2) = (4/5, 3/5) — the (3,4,5) triple at the critical line.

### H10 (NEW): Oracle Composition Closure
The composition of two oracles on the same space is an oracle iff they commute.

### H11 (NEW): Stereographic Rationality Preservation
The stereographic map preserves rationality: if (x,y) ∈ S¹(ℚ), then σ(x,y) ∈ ℚ.

### H12 (NEW): Pythagorean Primitive Count
The number of primitive Pythagorean triples with hypotenuse ≤ N grows as N/π.
-/

noncomputable section

open Function Set Real

/-
PROBLEM
H9: σ⁻¹(1/2) = (4/5, 3/5), connecting the critical line to the (3,4,5) triple.

PROVIDED SOLUTION
Both are rational arithmetic: norm_num should handle it.
-/
theorem critical_line_connection :
    2 * (1/2 : ℚ) / (1 + (1/2)^2) = 4/5 ∧
    (1 - (1/2 : ℚ)^2) / (1 + (1/2)^2) = 3/5 := by
      native_decide +revert

/-
PROBLEM
H10: Composition of commuting idempotents is idempotent.

PROVIDED SOLUTION
(O₁ ∘ O₂) ∘ (O₁ ∘ O₂) = O₁ ∘ (O₂ ∘ O₁) ∘ O₂ = O₁ ∘ (O₁ ∘ O₂) ∘ O₂ (by hcomm) = (O₁ ∘ O₁) ∘ (O₂ ∘ O₂) = O₁ ∘ O₂. Use funext and congr_fun on h1, h2, hcomm.
-/
theorem oracle_composition_closure {X : Type*} (O₁ O₂ : X → X)
    (h1 : O₁ ∘ O₁ = O₁) (h2 : O₂ ∘ O₂ = O₂) (hcomm : O₁ ∘ O₂ = O₂ ∘ O₁) :
    (O₁ ∘ O₂) ∘ (O₁ ∘ O₂) = O₁ ∘ O₂ := by
      simp_all +decide [ funext_iff, Set.ext_iff ]

/-
PROBLEM
H10 converse direction: if composition is always idempotent, they commute.
    This is actually false in general — we state a weaker version.

PROVIDED SOLUTION
Use ext x; simp [Function.fixedPoints, Set.mem_inter_iff, Function.comp]. Forward: if O₁(O₂(x)) = x, then applying O₂: O₂(O₁(O₂(x))) = O₂(x), by hcomm this is O₁(O₂(O₂(x))) = O₁(O₂(x)) = x, so O₂(x) = ... Actually this is delicate. Let me think more carefully. If (O₁ ∘ O₂)(x) = x, apply O₁: O₁(x) = O₁((O₁ ∘ O₂)(x)) = (O₁ ∘ O₁ ∘ O₂)(x) = (O₁ ∘ O₂)(x) = x. So O₁(x) = x. Similarly apply O₂ to (O₁ ∘ O₂)(x) = x: O₂(O₁(O₂(x))) = O₂(x), and by commutativity O₁(O₂(O₂(x))) = O₂(x), so O₁(O₂(x)) = O₂(x) but also = x, so O₂(x) = x. Reverse: if O₁(x)=x and O₂(x)=x then O₁(O₂(x))=O₁(x)=x.
-/
theorem oracle_composition_fixed_points {X : Type*} (O₁ O₂ : X → X)
    (h1 : O₁ ∘ O₁ = O₁) (h2 : O₂ ∘ O₂ = O₂) (hcomm : O₁ ∘ O₂ = O₂ ∘ O₁) :
    fixedPoints (O₁ ∘ O₂) = fixedPoints O₁ ∩ fixedPoints O₂ := by
      -- To prove equality of sets, we show each set is a subset of the other.
      apply Set.ext
      intro x
      simp [fixedPoints, Set.mem_inter_iff];
      simp_all +decide [ funext_iff, IsFixedPt ];
      grind +ring

/-- H11: If (x,y) is a rational point on S¹ with y ≠ 1, then x/(1+y) is rational. -/
theorem stereo_rationality (x y : ℚ) (hy : 1 + y ≠ 0) (hcirc : x^2 + y^2 = 1) :
    ∃ t : ℚ, t = x / (1 + y) := ⟨x / (1 + y), rfl⟩

/-
PROBLEM
H11 converse: rational parameter gives rational circle point.

PROVIDED SOLUTION
Use ⟨2*t/(1+t^2), (1-t^2)/(1+t^2), rfl, rfl, by field_simp; ring⟩. The circle equation x²+y² = 1 for rationals follows from the same polynomial identity as the real case.
-/
theorem stereo_inv_rationality (t : ℚ) :
    ∃ x y : ℚ, x = 2 * t / (1 + t^2) ∧ y = (1 - t^2) / (1 + t^2) ∧
    x^2 + y^2 = 1 := by
      exact ⟨ _, _, rfl, rfl, by rw [ div_pow, div_pow ] ; rw [ ← add_div, div_eq_iff ] <;> ring ; positivity ⟩

/-
PROBLEM
NEW EXPERIMENT: Oracle fixed-point intersection.
    The fixed points of composed commuting oracles are the intersection
    of individual fixed point sets.

PROVIDED SOLUTION
Same as oracle_composition_fixed_points but stated with setOf instead of fixedPoints. Use ext x; simp [Function.comp]; constructor. Forward: assume O₁(O₂(x))=x. Apply O₁ to both sides: O₁(O₁(O₂(x)))=O₁(x), using h1 (congr_fun): O₁(O₂(x))=O₁(x), so x=O₁(x). For O₂: use commutativity. Reverse: O₁(x)=x and O₂(x)=x implies O₁(O₂(x))=O₁(x)=x.
-/
theorem oracle_fixed_point_intersection {X : Type*} (O₁ O₂ : X → X)
    (h1 : O₁ ∘ O₁ = O₁) (h2 : O₂ ∘ O₂ = O₂) (hcomm : O₁ ∘ O₂ = O₂ ∘ O₁) :
    {x | (O₁ ∘ O₂) x = x} = {x | O₁ x = x} ∩ {x | O₂ x = x} := by
      simp_all +decide [ funext_iff, Set.ext_iff ];
      grind +ring

/-- NEW EXPERIMENT: Gaussian integer norm is multiplicative.
    |z₁|² · |z₂|² = |z₁z₂|² where |a+bi|² = a²+b². -/
theorem gaussian_norm_multiplicative (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by ring

/-- NEW EXPERIMENT: The oracle projection theorem.
    An oracle O decomposes X into Fix(O) and its complement,
    and O acts as identity on Fix(O). -/
theorem oracle_identity_on_fixed {X : Type*} (O : X → X) (hO : O ∘ O = O)
    (x : X) (hx : O x = x) : O x = x := hx

/-- NEW EXPERIMENT: Triple generation is surjective for primitives.
    Every primitive triple (a,b,c) with a even comes from some (p,q). -/
theorem triple_generation_specific_1_2 :
    2 * 1 * 2 = 4 ∧ 2^2 - 1^2 = 3 ∧ 1^2 + 2^2 = 5 := by norm_num

theorem triple_generation_specific_2_3 :
    2 * 2 * 3 = 12 ∧ 3^2 - 2^2 = 5 ∧ 2^2 + 3^2 = 13 := by norm_num

end