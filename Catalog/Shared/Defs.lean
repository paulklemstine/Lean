--- a/Tropical/Defs.lean
+++ b/Tropical/Defs.lean
@@ -2,123 +2,152 @@
 Copyright (c) 2025. All rights reserved.
 Released under Apache 2.0 license as described in the file LICENSE.
 
-# GL₃ Tropical Satake Classification — Definitions
+# GL₃ Tropical Satake Surjectivity — Definitions
 
-## Overview
-
-This file provides the core definitions for the GL₃ tropical Satake
-classification theorem on bounded support. We model the dominant coweight
-chamber for GL₃ (modulo center) as pairs `(a, b) ∈ ℕ²`, representing the
-dominant coweight `(a + b, b, 0)`.
-
-## Mathematical Model
-
-The tropical Hecke algebra is modeled by *edge data*: a pair of functions
-on `ℕ` representing the generator coefficients along the two simple-coroot
-directions of the GL₃ dominant chamber. The tropical Satake transform extends
-edge data to the full chamber via the additive formula
-
-  `D(a, b) = f₁(a) + f₂(b)`
-
-reflecting the factored structure of the GL₃ Satake kernel in the tropical limit.
-
-The admissibility conditions characterize which functions on the dominant chamber
-arise as images of the tropical Satake transform. They decompose into:
-
-* **EdgeValuationCompatible** — normalization at the origin
-* **Levi12Compatible** — first-coordinate increment independence
-* **Levi23Compatible** — second-coordinate increment independence
-* **AdjacentFacetCompatible** — vanishing discrete Laplacian
-
-These conditions are shown to be mutually equivalent (up to the origin condition)
-and collectively equivalent to additive separability `D(a,b) = D(a,0) + D(0,b)`.
+This file provides the foundational definitions for the GL₃ tropical Satake
+surjectivity theorem: dominant coweights, support data, tropical Hecke functions,
+the Satake support extraction map, and the admissibility predicate.
 -/
 import Mathlib
 
-namespace TropSatakeGL3
+namespace GL3TropicalSatake
 
-/-! ## Core Types -/
+/-! ## Sorting into Dominant Chamber -/
 
-/-- Dominant coweight for GL₃ (mod center), parameterized as
-    `(a, b) ↦ (a + b, b, 0)`. -/
-abbrev DomWt := ℕ × ℕ
+/-- Sort three integers into weakly decreasing order: (max, mid, min). -/
+def sort₃ (a b c : ℤ) : ℤ × ℤ × ℤ :=
+  (max a (max b c),
+   a + b + c - max a (max b c) - min a (min b c),
+   min a (min b c))
 
-/-- A tropical datum: a real-valued function on the dominant chamber. -/
-abbrev TropDatum := DomWt → ℝ
+theorem sort₃_fst_ge_snd (a b c : ℤ) : (sort₃ a b c).1 ≥ (sort₃ a b c).2.1 := by
+  simp only [sort₃]; omega
 
-/-- Height of a dominant coweight: `height(a, b) = a + b = λ₁`. -/
-def height (p : DomWt) : ℕ := p.1 + p.2
+theorem sort₃_snd_ge_thd (a b c : ℤ) : (sort₃ a b c).2.1 ≥ (sort₃ a b c).2.2 := by
+  simp only [sort₃]; omega
 
-@[simp] lemma height_def (a b : ℕ) : height (a, b) = a + b := rfl
+theorem sort₃_of_dominant {a b c : ℤ} (h1 : a ≥ b) (h2 : b ≥ c) :
+    sort₃ a b c = (a, b, c) := by
+  simp only [sort₃, Prod.mk.injEq]; constructor <;> [skip; constructor] <;> omega
 
-/-! ## Bounded Support -/
+theorem sort₃_sum (a b c : ℤ) :
+    (sort₃ a b c).1 + (sort₃ a b c).2.1 + (sort₃ a b c).2.2 = a + b + c := by
+  simp only [sort₃]; omega
 
-/-- Bounded support: the datum vanishes above a given height. -/
-def BoundedSupport (N : ℕ) (D : TropDatum) : Prop :=
-  ∀ p : DomWt, N < p.1 + p.2 → D p = 0
+theorem sort₃_swap12 (a b c : ℤ) : sort₃ b a c = sort₃ a b c := by
+  simp only [sort₃, Prod.mk.injEq]; constructor <;> [skip; constructor] <;> omega
 
-/-! ## Tropical Hecke Algebra -/
+theorem sort₃_cycle (a b c : ℤ) : sort₃ b c a = sort₃ a b c := by
+  simp only [sort₃, Prod.mk.injEq]; constructor <;> [skip; constructor] <;> omega
 
-/-- A tropical Hecke element for GL₃, given by edge data along the two
-    simple-coroot directions, normalized so that both vanish at the origin.
+theorem sort₃_idempotent (a b c : ℤ) :
+    let s := sort₃ a b c
+    sort₃ s.1 s.2.1 s.2.2 = s := by
+  have h1 := sort₃_fst_ge_snd a b c
+  have h2 := sort₃_snd_ge_thd a b c
+  exact sort₃_of_dominant h1 h2
 
-    * `edge1` stores the values along the first wall `{(a, 0) : a ∈ ℕ}`
-    * `edge2` stores the values along the second wall `{(0, b) : b ∈ ℕ}` -/
-@[ext]
-structure TropHecke where
-  /-- Generator coefficients along the first simple-coroot direction. -/
-  edge1 : ℕ → ℝ
-  /-- Generator coefficients along the second simple-coroot direction. -/
-  edge2 : ℕ → ℝ
-  /-- Normalization: edge1 vanishes at the origin. -/
-  edge1_zero : edge1 0 = 0
-  /-- Normalization: edge2 vanishes at the origin. -/
-  edge2_zero : edge2 0 = 0
+/-! ## Dominant Coweights -/
 
-/-- The tropical Satake transform for GL₃: extends edge data to the full
-    dominant chamber via `D(a, b) = f₁(a) + f₂(b)`.
+/-- A dominant coweight for GL₃ is a weakly decreasing triple of integers. -/
+def GL3Dom := { μ : ℤ × ℤ × ℤ // μ.1 ≥ μ.2.1 ∧ μ.2.1 ≥ μ.2.2 }
 
-    This additive extension encodes the fact that the GL₃ Satake kernel
-    factors through the two simple-root SL₂ subgroups in the tropical limit. -/
-noncomputable def tropSatake (h : TropHecke) : TropDatum :=
-  fun p => h.edge1 p.1 + h.edge2 p.2
+instance : DecidableEq GL3Dom := Subtype.instDecidableEq
 
-/-- Bounded support for Hecke elements: both edge functions vanish beyond height N. -/
-def HeckeBoundedSupport (N : ℕ) (h : TropHecke) : Prop :=
-  (∀ a, N < a → h.edge1 a = 0) ∧ (∀ b, N < b → h.edge2 b = 0)
+/-- Construct the dominant representative of any triple. -/
+def toGL3Dom (a b c : ℤ) : GL3Dom :=
+  ⟨sort₃ a b c, sort₃_fst_ge_snd a b c, sort₃_snd_ge_thd a b c⟩
 
-/-! ## Admissibility Conditions -/
+/-- The zero dominant coweight. -/
+def GL3Dom.zero : GL3Dom := ⟨(0, 0, 0), le_refl _, le_refl _⟩
 
-/-- **Edge valuation compatibility**: the datum vanishes at the origin.
-    This is the normalization condition corresponding to the identity
-    element of the Hecke algebra. -/
-def EdgeValuationCompatible (D : TropDatum) : Prop :=
-  D (0, 0) = 0
+instance : Zero GL3Dom := ⟨GL3Dom.zero⟩
 
-/-- **Levi₁₂ compatibility**: increments in the first coordinate direction
-    are independent of the second coordinate. This corresponds to the
-    rank-2 Levi subgroup for the simple root α₁. -/
-def Levi12Compatible (D : TropDatum) : Prop :=
-  ∀ a b : ℕ, D (a + 1, b) - D (a, b) = D (a + 1, 0) - D (a, 0)
+@[simp] theorem GL3Dom.zero_val : (0 : GL3Dom).1 = (0, 0, 0) := rfl
 
-/-- **Levi₂₃ compatibility**: increments in the second coordinate direction
-    are independent of the first coordinate. This corresponds to the
-    rank-2 Levi subgroup for the simple root α₂. -/
-def Levi23Compatible (D : TropDatum) : Prop :=
-  ∀ a b : ℕ, D (a, b + 1) - D (a, b) = D (0, b + 1) - D (0, b)
+/-- Componentwise addition of dominant coweights is dominant. -/
+def GL3Dom.add (μ ν : GL3Dom) : GL3Dom :=
+  ⟨(μ.1.1 + ν.1.1, μ.1.2.1 + ν.1.2.1, μ.1.2.2 + ν.1.2.2),
+   by constructor <;> [linarith [μ.2.1, ν.2.1]; linarith [μ.2.2, ν.2.2]]⟩
 
-/-- **Adjacent facet compatibility**: the discrete Laplacian vanishes,
-    expressing the commutativity of the two simple-root propagation
-    operators on the dominant chamber. -/
-def AdjacentFacetCompatible (D : TropDatum) : Prop :=
-  ∀ a b : ℕ, D (a + 1, b + 1) + D (a, b) = D (a + 1, b) + D (a, b + 1)
+instance : Add GL3Dom := ⟨GL3Dom.add⟩
 
-/-- **Full Satake admissibility**: conjunction of all four compatibility
-    conditions for the GL₃ tropical Satake transform. -/
-def SatakeAdmissible (D : TropDatum) : Prop :=
-  EdgeValuationCompatible D ∧
-  Levi12Compatible D ∧
-  Levi23Compatible D ∧
-  AdjacentFacetCompatible D
+@[simp] theorem GL3Dom.add_val (μ ν : GL3Dom) :
+    (μ + ν).1 = (μ.1.1 + ν.1.1, μ.1.2.1 + ν.1.2.1, μ.1.2.2 + ν.1.2.2) := rfl
 
-end TropSatakeGL3+/-- toGL3Dom of a dominant triple returns the original triple. -/
+theorem toGL3Dom_of_dominant {a b c : ℤ} (h1 : a ≥ b) (h2 : b ≥ c) :
+    toGL3Dom a b c = ⟨(a, b, c), h1, h2⟩ := by
+  simp only [toGL3Dom]
+  exact Subtype.ext (sort₃_of_dominant h1 h2)
+
+/-- toGL3Dom is invariant under transposition (12). -/
+theorem toGL3Dom_swap12 (a b c : ℤ) : toGL3Dom b a c = toGL3Dom a b c := by
+  exact Subtype.ext (sort₃_swap12 a b c)
+
+/-- toGL3Dom is invariant under the 3-cycle. -/
+theorem toGL3Dom_cycle (a b c : ℤ) : toGL3Dom b c a = toGL3Dom a b c := by
+  exact Subtype.ext (sort₃_cycle a b c)
+
+/-! ## Support Datum -/
+
+/-- A support datum is a function from dominant coweights to ℤ. -/
+def SupportDatum := GL3Dom → ℤ
+
+instance : CoeFun SupportDatum (fun _ => GL3Dom → ℤ) := ⟨id⟩
+
+
+
+/-- Finite support means vanishing outside some finite set. -/
+def FiniteSupport (h : SupportDatum) : Prop :=
+  ∃ s : Finset GL3Dom, ∀ μ, μ ∉ s → h μ = 0
+
+/-! ## S₃-Invariant Functions (Tropical Hecke Functions) -/
+
+/-- A function f : ℤ³ → ℤ is S₃-invariant if it is invariant under
+    transposition (12) and the 3-cycle (123). -/
+def IsS3Invariant (f : ℤ → ℤ → ℤ → ℤ) : Prop :=
+  (∀ a b c, f a b c = f b a c) ∧ (∀ a b c, f a b c = f b c a)
+
+/-- A tropical Hecke function for GL₃ is an S₃-invariant function ℤ³ → ℤ. -/
+def TropicalHeckeGL3 := { f : ℤ → ℤ → ℤ → ℤ // IsS3Invariant f }
+
+instance : CoeFun TropicalHeckeGL3 (fun _ => ℤ → ℤ → ℤ → ℤ) := ⟨Subtype.val⟩
+
+/-- Extensionality for tropical Hecke functions. -/
+@[ext] theorem TropicalHeckeGL3.ext {f g : TropicalHeckeGL3}
+    (h : ∀ a b c, f.1 a b c = g.1 a b c) : f = g :=
+  Subtype.ext (funext fun a => funext fun b => funext fun c => h a b c)
+
+/-! ## Satake Support Map -/
+
+/-- Extract the support datum: restrict a Hecke function to the dominant chamber. -/
+def satakeSupport (f : TropicalHeckeGL3) : SupportDatum :=
+  fun μ => f.1 μ.1.1 μ.1.2.1 μ.1.2.2
+
+/-! ## Satake Extension -/
+
+/-- Extend a support datum to an S₃-invariant function on ℤ³ via sorting. -/
+def satakeExtend (h : SupportDatum) : ℤ → ℤ → ℤ → ℤ :=
+  fun a b c => h (toGL3Dom a b c)
+
+theorem satakeExtend_invariant (h : SupportDatum) : IsS3Invariant (satakeExtend h) := by
+  constructor
+  · intro a b c; simp only [satakeExtend, toGL3Dom_swap12]
+  · intro a b c; simp only [satakeExtend, toGL3Dom_cycle]
+
+/-- Lift a support datum to a tropical Hecke function. -/
+def satakeExtendHecke (h : SupportDatum) : TropicalHeckeGL3 :=
+  ⟨satakeExtend h, satakeExtend_invariant h⟩
+
+/-! ## S₃-invariant functions are determined by their dominant values -/
+
+/-
+Any triple has the same S₃-invariant value as its sorted version.
+-/
+theorem s3_inv_eq_at_sort (f : ℤ → ℤ → ℤ → ℤ) (hf : IsS3Invariant f) (a b c : ℤ) :
+    f a b c = f (sort₃ a b c).1 (sort₃ a b c).2.1 (sort₃ a b c).2.2 := by
+  unfold sort₃; have := hf.1; have := hf.2; simp_all +decide [max_def, min_def] ;
+  grind
+
+end GL3TropicalSatake