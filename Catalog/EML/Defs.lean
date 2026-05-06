--- a/Physics/Defs.lean
+++ b/Physics/Defs.lean
@@ -1,138 +1,105 @@
-/-
-Copyright (c) 2025. All rights reserved.
-Released under Apache 2.0 license as described in the file LICENSE.
+import Mathlib
 
-# KMS–Gödel Barrier: Definitions
+/-! # Berggren–Photonic Bridge: Definitions
 
-This file defines the abstract framework for the **KMS–Gödel Barrier theorem**,
-which establishes that no closure self-model carrying a modular thermodynamic
-structure can simultaneously support an exact internally truthful self-semantics
-and a β-KMS equilibrium semantics at positive inverse temperature.
-
-## Mathematical context
-
-The theorem sits at the intersection of three classical ideas:
-
-1. **Gödel/Lawvere diagonalization**: self-reference forces fixed points.
-2. **KMS equilibrium theory**: modular dynamics constrains equilibrium states.
-3. **Variational free-energy principles**: equilibrium has strict gap properties.
-
-The key insight is that exact internal truthfulness, when combined with
-self-referential capability, induces a zero-gap modular free-energy fixed
-point. But KMS equilibrium at positive inverse temperature strictly forbids
-such zero-gap fixed points. This is not mere incompleteness — it is a
-**thermodynamic obstruction** to perfect self-knowledge.
-
-## Overview of types
-
-- `ClosureSelfModel M`: a system with self-referential sentences and a
-  diagonal (Gödel–Lawvere) fixed-point schema.
-- `ModularThermodynamicStructure M`: equips the model with a modular
-  free-energy gap functional and axiomatizes strict positivity at β > 0.
-- `ExactInternallyTruthfulKMSModel M beta`: the hypothesis that the model
-  achieves exact internal truth under KMS equilibrium, which forces the
-  free-energy gap to vanish.
-
-## References
-
-* Gödel, K. — Über formal unentscheidbare Sätze (1931)
-* Lawvere, F.W. — Diagonal arguments and cartesian closed categories (1969)
-* Haag, Hugenholtz, Winnink — On the equilibrium states in quantum
-  statistical mechanics (1967)
-* Tomita, M. — On canonical forms of von Neumann algebras (1967)
+This module defines the core mathematical objects for the Berggren–Photonic
+correspondence:
+- Primitive Pythagorean triples
+- The stereographic Pythagorean bridge (SPB)
+- Möbius transformations on ℝ induced by 2×2 integer matrices
+- Cross-ratio of four real numbers
+- The three Berggren generators (U, A, D) as 3×3 integer matrices
+- Their induced 2×2 matrices for the Möbius action
 -/
 
-import Mathlib
+noncomputable section
+open Matrix
 
-universe u
+/-! ## Primitive Pythagorean Triples -/
 
-/-! ## §1. Closure Self-Model -/
+/-- A primitive Pythagorean triple `(a, b, c)` with `a² + b² = c²`, `a > 0`, `b > 0`,
+    and `gcd(a, b) = 1`. -/
+structure PrimPythTriple where
+  a : ℤ
+  b : ℤ
+  c : ℤ
+  pyth : a ^ 2 + b ^ 2 = c ^ 2
+  a_pos : 0 < a
+  b_pos : 0 < b
+  coprime : Int.gcd a b = 1
+  c_pos : 0 < c
 
-/-- A **closure self-model** is an abstract formal system with self-referential
-capability via a diagonal (Gödel–Lawvere) fixed-point schema, together with
-a provability predicate and basic logical connectives.
+/-- `c - b > 0` for any primitive Pythagorean triple, since `c² - b² = a² > 0`
+    and both `c, b > 0` implies `c > b`. -/
+theorem PrimPythTriple.c_sub_b_pos (p : PrimPythTriple) : 0 < p.c - p.b := by
+  nlinarith [p.pyth, p.a_pos, sq_nonneg p.a, sq_nonneg (p.c - p.b), p.c_pos, p.b_pos]
 
-This is a lighter version of `CoherentClosureSelfModel` that retains only
-the structural features needed for the KMS–Gödel barrier. -/
-class ClosureSelfModel (M : Type u) where
-  /-- The type of sentences in the formal language. -/
-  Sentence : Type u
-  /-- External derivability / truth predicate. -/
-  models : Sentence → Prop
-  /-- Internal provability predicate (sentence-level). -/
-  provSent : Sentence → Sentence
-  /-- Sentence-level negation. -/
-  negSent : Sentence → Sentence
-  /-- Internalization of an external Lean `Prop` as an internal sentence. -/
-  internalize : Prop → Sentence
-  /-- **Diagonal lemma (Gödel–Lawvere).**
-  For any definable operation `Ψ` on sentences, there exists a diagonal
-  fixed-point sentence `G` satisfying `models (G ↔ᵢ ¬ᵢ Prov(Ψ G))`. -/
-  ax_diagonal : ∀ (Ψ : Sentence → Sentence),
-    ∃ G : Sentence, models (internalize (models G ↔ ¬ models (provSent (Ψ G))))
-  /-- **Soundness for internalized propositions.**
-  If M models the internalization of `P`, then `P` holds externally. -/
-  ax_internalize_sound : ∀ {P : Prop}, models (internalize P) → P
+/-- `c - b ≠ 0` (as a real number). -/
+theorem PrimPythTriple.c_sub_b_ne_zero (p : PrimPythTriple) : (p.c : ℝ) - (p.b : ℝ) ≠ 0 := by
+  have h := p.c_sub_b_pos
+  exact_mod_cast ne_of_gt h
 
-/-! ## §2. Modular Thermodynamic Structure -/
+/-! ## Stereographic Pythagorean Bridge -/
 
-/-- A **modular thermodynamic structure** on a closure self-model equips
-the system with a real-valued free-energy gap functional parameterized by
-inverse temperature β, together with the fundamental axiom that the gap
-is strictly positive at positive β.
+/-- The stereographic Pythagorean bridge maps a primitive Pythagorean triple `(a, b, c)`
+    to the real number `a / (c - b)`.
 
-The free-energy gap `ModularFreeEnergyGap M beta` measures the minimum
-thermodynamic cost of self-referential encoding across all sentences.
-The strict positivity axiom is the operator-algebraic content:
-KMS equilibrium at positive temperature enforces a non-vanishing gap,
-preventing exact self-compression. -/
-class ModularThermodynamicStructure (M : Type u) where
-  /-- The modular free-energy gap at inverse temperature β.
-  This is a global invariant of the model, representing the infimum of
-  free-energy defects across all self-referential encodings. -/
-  freeEnergyGap : ℝ → ℝ
-  /-- **No-self-compression principle.**
-  At positive inverse temperature, the modular free-energy gap is
-  strictly positive. This is the thermodynamic content: KMS equilibrium
-  forbids exact self-compression.
+    This is the stereographic projection of the rational point `(a/c, b/c)` on the unit
+    circle from the "south pole" `(0, -1)` onto the real line, restricted to the first
+    quadrant. The image lies in `(0, ∞)` and parameterizes the "photonic frontier" — the
+    space of massless states in the Minkowski light-cone interpretation. -/
+def spb (p : PrimPythTriple) : ℝ := (p.a : ℝ) / ((p.c : ℝ) - (p.b : ℝ))
 
-  Physically, this says that any self-referential encoding must pay a
-  minimum thermodynamic cost proportional to the inverse temperature. -/
-  positive_gap_of_beta_pos : ∀ {beta : ℝ}, 0 < beta → 0 < freeEnergyGap beta
+/-- The SPB value is always positive. -/
+theorem spb_pos (p : PrimPythTriple) : 0 < spb p := by
+  unfold spb
+  apply div_pos
+  · exact_mod_cast p.a_pos
+  · exact_mod_cast p.c_sub_b_pos
 
-/-! ## §3. Exact Internally Truthful KMS Model -/
+/-! ## Möbius Transformations -/
 
-/-- `ExactInternallyTruthfulKMSModel M beta` asserts that the closure
-self-model `M` achieves **exact internal truth** under KMS equilibrium
-at inverse temperature `beta`.
+/-- Möbius transformation on ℝ induced by a 2×2 real matrix `[[a, b], [c, d]]`:
+    `z ↦ (a·z + b) / (c·z + d)`. -/
+def moebiusReal (a b c d : ℝ) (z : ℝ) : ℝ := (a * z + b) / (c * z + d)
 
-The key consequence is `induces_zero_gap`: exact internal truth forces
-the modular free-energy gap to vanish. Intuitively, if the system can
-perfectly evaluate all its own truth predicates, the self-referential
-encoding cost collapses to zero — there is no discrepancy between
-internal and external evaluation.
+/-- Möbius transformation on ℝ induced by a 2×2 integer matrix, cast to ℝ. -/
+def moebius (M : Matrix (Fin 2) (Fin 2) ℤ) (z : ℝ) : ℝ :=
+  moebiusReal (M 0 0 : ℝ) (M 0 1 : ℝ) (M 1 0 : ℝ) (M 1 1 : ℝ) z
 
-This is the hypothesis that the KMS–Gödel barrier theorem refutes:
-it cannot hold simultaneously with positive-temperature KMS equilibrium. -/
-class ExactInternallyTruthfulKMSModel (M : Type u)
-    [ClosureSelfModel M] [ModularThermodynamicStructure M]
-    (beta : ℝ) : Prop where
-  /-- Exact internal truth annihilates the modular free-energy gap.
-  This is the bridge from semantic exactness to thermodynamic obstruction:
-  if the system is exactly truthful, the gap vanishes. -/
-  induces_zero_gap : ModularThermodynamicStructure.freeEnergyGap (M := M) beta = 0
+/-! ## Cross-Ratio -/
 
-/-! ## §4. Auxiliary Definitions -/
+/-- The cross-ratio of four real numbers `(z₁, z₂, z₃, z₄)`, defined as
+    `((z₁ - z₃)(z₂ - z₄)) / ((z₁ - z₄)(z₂ - z₃))`.
 
-/-- The modular free-energy gap at inverse temperature β, as a top-level
-function for convenience. -/
-noncomputable def ModularFreeEnergyGap (M : Type u)
-    [ModularThermodynamicStructure M] (beta : ℝ) : ℝ :=
-  ModularThermodynamicStructure.freeEnergyGap (M := M) beta
+    This is a fundamental projective invariant: it is preserved by all Möbius
+    transformations. -/
+def cross_ratio (z₁ z₂ z₃ z₄ : ℝ) : ℝ :=
+  ((z₁ - z₃) * (z₂ - z₄)) / ((z₁ - z₄) * (z₂ - z₃))
 
-/-- `HasExactModularFreeEnergyFixedPoint M beta` holds when the modular
-free-energy gap vanishes, i.e., the system has an exact fixed point
-under the modular free-energy operator. -/
-def HasExactModularFreeEnergyFixedPoint (M : Type u)
-    [ModularThermodynamicStructure M] (beta : ℝ) : Prop :=
-  ModularFreeEnergyGap M beta = 0+/-! ## Berggren Generators -/
+
+/-- The three Berggren 3×3 matrices that generate all primitive Pythagorean triples
+    from `(3, 4, 5)`. Each maps a primitive triple to a new primitive triple. -/
+def berggrenMatrix : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
+  | 0 => !![1, -2, 2; 2, -1, 2; 2, -2, 3]   -- U
+  | 1 => !![1, 2, 2; 2, 1, 2; 2, 2, 3]       -- A
+  | 2 => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]    -- D
+
+/-- The Berggren action on column vectors `(a, b, c)ᵀ`. -/
+def berggrenActVec (g : Fin 3) (v : Fin 3 → ℤ) : Fin 3 → ℤ :=
+  (berggrenMatrix g).mulVec v
+
+/-- The 2×2 matrices induced by the Berggren generators on the stereographic
+    coordinates `[a : c - b]`. These act by Möbius transformations on the SPB
+    value `a/(c-b)`.
+
+    - Generator 0 (U): `[[1, 2], [0, 1]]` — translation `t ↦ t + 2`
+    - Generator 1 (A): `[[2, 1], [1, 0]]` — inversion-translation `t ↦ 2 + 1/t`
+    - Generator 2 (D): `[[2, -1], [1, 0]]` — inversion-translation `t ↦ 2 - 1/t` -/
+def berggren2x2 : Fin 3 → Matrix (Fin 2) (Fin 2) ℤ
+  | 0 => !![1, 2; 0, 1]
+  | 1 => !![2, 1; 1, 0]
+  | 2 => !![2, -1; 1, 0]
+
+end