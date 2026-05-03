--- a/Tropical/Defs.lean
+++ b/Tropical/Defs.lean
@@ -1,333 +1,178 @@
 --- a/Tropical/Defs.lean
 +++ b/Tropical/Defs.lean
-@@ -1,327 +1,153 @@
----- a/Tropical/Defs.lean
--+++ b/Tropical/Defs.lean
--@@ -1,172 +1,153 @@
------ a/MachineLearning/Defs.lean
---+++ b/MachineLearning/Defs.lean
---@@ -1,105 +1,86 @@
--- import Mathlib
--- 
--- /-!
----# Top-K Robustness: Definitions
---+# Top-k Order Statistics and Robustness Definitions
--- 
----Core definitions for the top-`k` certified robustness theory for multiclass
----piecewise-linear networks. All definitions avoid sorting machinery and instead
----phrase top-`k` membership via pairwise comparison against outside classes.
---+This file defines the core objects for top-k certified robustness:
--- 
----## Main definitions
---+* `kthLargest s k` — the (k+1)-th largest value of `s : Fin C → ℝ` (0-indexed)
---+* `topkGap s k` — the gap between the k-th and (k+1)-th largest values
---+* `topKSet s k` — the set of indices with scores strictly above the (k+1)-th largest
--- 
----* `scoreGap` — The score gap `f(x,i) - f(x,j)` between two classes.
----* `finCompl` — The complement of a finset `S` in `Fin n`.
----* `crossGaps` — The finite set of all score gaps between classes in `S` and classes outside `S`.
----* `topkMargin'` — The minimum score gap across all (in, out) pairs, via `Finset.min'`.
----* `IsTopKSet` — Predicate: all classes in `S` weakly dominate all classes outside `S`.
----* `StrictTopKSet` — Predicate: all classes in `S` strictly dominate all classes outside `S`.
---+The k-th largest value is defined via the classical "sup of infima" characterization:
---+  `kthLargest s k = max_{|S|=k+1} min_{i ∈ S} s(i)`
---+
---+This definition is proof-friendly because the perturbation bound follows directly
---+from the monotonicity of inf and sup operations.
--- -/
---+
---+noncomputable section
--- 
--- open Finset
--- 
----noncomputable section
---+/-! ## Auxiliary lemmas for powersetCard -/
--- 
----variable {n : ℕ}
---+/-- Nonemptiness of powersetCard when k+1 ≤ C -/
---+lemma powersetCard_univ_nonempty {C : ℕ} (k : ℕ) (h : k < C) :
---+    ((univ : Finset (Fin C)).powersetCard (k + 1)).Nonempty := by
---+  rw [powersetCard_nonempty, card_univ, Fintype.card_fin]; omega
--- 
----/-- The score gap between class `i` and class `j` at input `x`. -/
----def scoreGap {α : Type*} (f : α → Fin n → ℝ) (x : α) (i j : Fin n) : ℝ :=
----  f x i - f x j
---+/-- Any member of `powersetCard (k+1) univ` is nonempty -/
---+lemma nonempty_of_mem_powersetCard_succ {C : ℕ} {k : ℕ} {S : Finset (Fin C)}
---+    (hS : S ∈ (univ : Finset (Fin C)).powersetCard (k + 1)) : S.Nonempty := by
---+  rw [nonempty_iff_ne_empty]
---+  intro h
---+  have := (mem_powersetCard.mp hS).2
---+  rw [h, card_empty] at this; omega
--- 
----/-- The complement of `S` in `Fin n`, as a `Finset`. -/
----def finCompl (S : Finset (Fin n)) : Finset (Fin n) :=
----  Finset.univ.filter fun j => j ∉ S
---+/-- Card of members of powersetCard -/
---+lemma card_of_mem_powersetCard {C : ℕ} {k : ℕ} {S : Finset (Fin C)}
---+    (hS : S ∈ (univ : Finset (Fin C)).powersetCard (k + 1)) : S.card = k + 1 :=
---+  (mem_powersetCard.mp hS).2
--- 
----/-- The finite set of all score gaps `f(x,i) - f(x,j)` for `i ∈ S` and `j ∉ S`. -/
----def crossGaps {α : Type*} (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n)) : Finset ℝ :=
----  (S ×ˢ finCompl S).image (fun p => scoreGap f x p.1 p.2)
---+/-! ## Core Definitions -/
--- 
----/-- Nonemptiness of `crossGaps` from nonemptiness of `S` and its complement. -/
----theorem crossGaps_nonempty {α : Type*} (f : α → Fin n → ℝ) (x : α)
----    (S : Finset (Fin n))
----    (hS : S.Nonempty) (hSc : (finCompl S).Nonempty) :
----    (crossGaps f x S).Nonempty := by
----  rcases hS with ⟨i, hi⟩; rcases hSc with ⟨j, hj⟩
----  exact ⟨scoreGap f x i j, Finset.mem_image.mpr
----    ⟨(i, j), Finset.mem_product.mpr ⟨hi, hj⟩, rfl⟩⟩
---+/-- The k-th largest value (0-indexed) of a finite score function `s : Fin C → ℝ`.
---+    Defined as the maximum over all (k+1)-element subsets of `Fin C` of the
---+    minimum value of `s` on the subset:
---+      `kthLargest s k = sup_{|S|=k+1} inf_{i ∈ S} s(i)`
---+    Returns 0 if `k ≥ C`. -/
---+def kthLargest {C : ℕ} (s : Fin C → ℝ) (k : ℕ) : ℝ :=
---+  if h : k < C then
---+    ((univ : Finset (Fin C)).powersetCard (k + 1)).sup'
---+      (powersetCard_univ_nonempty k h)
---+      (fun S => if hne : S.Nonempty then S.inf' hne s else 0)
---+  else 0
--- 
----/-- The minimum score gap across all `(i ∈ S, j ∉ S)` pairs.
----This is the "top-k margin" — the smallest advantage any in-set class holds
----over any out-set class. -/
----def topkMargin' {α : Type*} (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n))
----    (hS : S.Nonempty) (hSc : (finCompl S).Nonempty) : ℝ :=
----  (crossGaps f x S).min' (crossGaps_nonempty f x S hS hSc)
---+/-- The top-k gap: the difference between the k-th largest and (k+1)-th largest values.
---+    For `k ≥ 1`, this measures the separation between the top-k scores and the rest.
---+    `topkGap s k = kthLargest s (k-1) - kthLargest s k` -/
---+def topkGap {C : ℕ} (s : Fin C → ℝ) (k : ℕ) : ℝ :=
---+  kthLargest s (k - 1) - kthLargest s k
--- 
----/-- `S` is a (weak) top-k set at `x`: every class in `S` has score ≥ every class
----outside `S`. -/
----def IsTopKSet {α : Type*} (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n)) : Prop :=
----  ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → f x j ≤ f x i
---+/-- The top-k set: the set of indices whose score strictly exceeds the (k+1)-th
---+    largest value. Under a positive gap condition, this has exactly k elements. -/
---+def topKSet {C : ℕ} (s : Fin C → ℝ) (k : ℕ) : Finset (Fin C) :=
---+  univ.filter (fun i => kthLargest s k < s i)
--- 
----/-- `S` is a strict top-k set at `x`: every class in `S` has score strictly greater
----than every class outside `S`. -/
----def StrictTopKSet {α : Type*} (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n)) : Prop :=
----  ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → f x j < f x i
---+/-! ## Basic kthLargest simplification -/
--- 
----/-- A strict top-k set is also a weak top-k set. -/
----theorem StrictTopKSet.isTopKSet {α : Type*} {f : α → Fin n → ℝ} {x : α}
----    {S : Finset (Fin n)}
----    (h : StrictTopKSet f x S) : IsTopKSet f x S :=
----  fun _ _ hi hj => le_of_lt (h hi hj)
---+/-- Unfold kthLargest when k < C -/
---+lemma kthLargest_def {C : ℕ} (s : Fin C → ℝ) (k : ℕ) (hk : k < C) :
---+    kthLargest s k =
---+      ((univ : Finset (Fin C)).powersetCard (k + 1)).sup'
---+        (powersetCard_univ_nonempty k hk)
---+        (fun S => if hne : S.Nonempty then S.inf' hne s else 0) := by
---+  simp [kthLargest, hk]
--- 
----/-- Membership in `crossGaps` unpacked. -/
----theorem mem_crossGaps_iff {α : Type*} {f : α → Fin n → ℝ} {x : α}
----    {S : Finset (Fin n)} {r : ℝ} :
----    r ∈ crossGaps f x S ↔ ∃ i ∈ S, ∃ j, j ∉ S ∧ r = scoreGap f x i j := by
----  simp only [crossGaps, Finset.mem_image, Finset.mem_product, finCompl,
----    Finset.mem_filter, Finset.mem_univ, true_and]
----  constructor
----  · rintro ⟨⟨i, j⟩, ⟨hi, hj⟩, heq⟩
----    exact ⟨i, hi, j, hj, heq.symm⟩
----  · rintro ⟨i, hi, j, hj, heq⟩
----    exact ⟨⟨i, j⟩, ⟨hi, hj⟩, heq.symm⟩
----
----/-- Every `(i, j)` gap with `i ∈ S`, `j ∉ S` is at least the top-k margin. -/
----theorem topkMargin'_le_scoreGap {α : Type*} {f : α → Fin n → ℝ} {x : α}
----    {S : Finset (Fin n)}
----    {hS : S.Nonempty} {hSc : (finCompl S).Nonempty}
----    {i j : Fin n} (hi : i ∈ S) (hj : j ∉ S) :
----    topkMargin' f x S hS hSc ≤ scoreGap f x i j := by
----  apply Finset.min'_le
----  simp only [crossGaps, Finset.mem_image, Finset.mem_product, finCompl,
----    Finset.mem_filter, Finset.mem_univ, true_and]
----  exact ⟨⟨i, j⟩, ⟨hi, hj⟩, rfl⟩
----
----/-- Positive top-k margin implies `StrictTopKSet`. -/
----theorem strictTopKSet_of_pos_margin {α : Type*} {f : α → Fin n → ℝ} {x : α}
----    {S : Finset (Fin n)}
----    {hS : S.Nonempty} {hSc : (finCompl S).Nonempty}
----    (hpos : 0 < topkMargin' f x S hS hSc) :
----    StrictTopKSet f x S := by
----  intro i j hi hj
----  have h : topkMargin' f x S hS hSc ≤ scoreGap f x i j :=
----    topkMargin'_le_scoreGap hi hj
----  simp only [scoreGap] at h
----  linarith
---+/-- The sup' function on powersetCard evaluates to inf' on nonempty subsets -/
---+lemma kthLargest_eq_sup'_inf' {C : ℕ} (s : Fin C → ℝ) (k : ℕ) (hk : k < C) :
---+    kthLargest s k =
---+      ((univ : Finset (Fin C)).powersetCard (k + 1)).sup'
---+        (powersetCard_univ_nonempty k hk)
---+        (fun S => if hne : S.Nonempty then S.inf' hne s else 0) :=
---+  kthLargest_def s k hk
--- 
--- end+/-
--+Copyright (c) 2025. All rights reserved.
--+Released under Apache 2.0 license as described in the file LICENSE.
+@@ -1,172 +1,153 @@
+---- a/MachineLearning/Defs.lean
+-+++ b/MachineLearning/Defs.lean
+-@@ -1,105 +1,86 @@
+- import Mathlib
+- 
+- /-!
+--# Top-K Robustness: Definitions
+-+# Top-k Order Statistics and Robustness Definitions
+- 
+--Core definitions for the top-`k` certified robustness theory for multiclass
+--piecewise-linear networks. All definitions avoid sorting machinery and instead
+--phrase top-`k` membership via pairwise comparison against outside classes.
+-+This file defines the core objects for top-k certified robustness:
+- 
+--## Main definitions
+-+* `kthLargest s k` — the (k+1)-th largest value of `s : Fin C → ℝ` (0-indexed)
+-+* `topkGap s k` — the gap between the k-th and (k+1)-th largest values
+-+* `topKSet s k` — the set of indices with scores strictly above the (k+1)-th largest
+- 
+--* `scoreGap` — The score gap `f(x,i) - f(x,j)` between two classes.
+--* `finCompl` — The complement of a finset `S` in `Fin n`.
+--* `crossGaps` — The finite set of all score gaps between classes in `S` and classes outside `S`.
+--* `topkMargin'` — The minimum score gap across all (in, out) pairs, via `Finset.min'`.
+--* `IsTopKSet` — Predicate: all classes in `S` weakly dominate all classes outside `S`.
+--* `StrictTopKSet` — Predicate: all classes in `S` strictly dominate all classes outside `S`.
+-+The k-th largest value is defined via the classical "sup of infima" characterization:
+-+  `kthLargest s k = max_{|S|=k+1} min_{i ∈ S} s(i)`
 -+
--+# GL₃ Tropical Satake Surjectivity — Definitions
+-+This definition is proof-friendly because the perturbation bound follows directly
+-+from the monotonicity of inf and sup operations.
+- -/
 -+
--+This file provides the foundational definitions for the GL₃ tropical Satake
--+surjectivity theorem: dominant coweights, support data, tropical Hecke functions,
--+the Satake support extraction map, and the admissibility predicate.
--+-/
--+import Mathlib
--+
--+namespace GL3TropicalSatake
--+
--+/-! ## Sorting into Dominant Chamber -/
--+
--+/-- Sort three integers into weakly decreasing order: (max, mid, min). -/
--+def sort₃ (a b c : ℤ) : ℤ × ℤ × ℤ :=
--+  (max a (max b c),
--+   a + b + c - max a (max b c) - min a (min b c),
--+   min a (min b c))
--+
--+theorem sort₃_fst_ge_snd (a b c : ℤ) : (sort₃ a b c).1 ≥ (sort₃ a b c).2.1 := by
--+  simp only [sort₃]; omega
--+
--+theorem sort₃_snd_ge_thd (a b c : ℤ) : (sort₃ a b c).2.1 ≥ (sort₃ a b c).2.2 := by
--+  simp only [sort₃]; omega
--+
--+theorem sort₃_of_dominant {a b c : ℤ} (h1 : a ≥ b) (h2 : b ≥ c) :
--+    sort₃ a b c = (a, b, c) := by
--+  simp only [sort₃, Prod.mk.injEq]; constructor <;> [skip; constructor] <;> omega
--+
--+theorem sort₃_sum (a b c : ℤ) :
--+    (sort₃ a b c).1 + (sort₃ a b c).2.1 + (sort₃ a b c).2.2 = a + b + c := by
--+  simp only [sort₃]; omega
--+
--+theorem sort₃_swap12 (a b c : ℤ) : sort₃ b a c = sort₃ a b c := by
--+  simp only [sort₃, Prod.mk.injEq]; constructor <;> [skip; constructor] <;> omega
--+
--+theorem sort₃_cycle (a b c : ℤ) : sort₃ b c a = sort₃ a b c := by
--+  simp only [sort₃, Prod.mk.injEq]; constructor <;> [skip; constructor] <;> omega
--+
--+theorem sort₃_idempotent (a b c : ℤ) :
--+    let s := sort₃ a b c
--+    sort₃ s.1 s.2.1 s.2.2 = s := by
--+  have h1 := sort₃_fst_ge_snd a b c
--+  have h2 := sort₃_snd_ge_thd a b c
--+  exact sort₃_of_dominant h1 h2
--+
--+/-! ## Dominant Coweights -/
--+
--+/-- A dominant coweight for GL₃ is a weakly decreasing triple of integers. -/
--+def GL3Dom := { μ : ℤ × ℤ × ℤ // μ.1 ≥ μ.2.1 ∧ μ.2.1 ≥ μ.2.2 }
--+
--+instance : DecidableEq GL3Dom := Subtype.instDecidableEq
--+
--+/-- Construct the dominant representative of any triple. -/
--+def toGL3Dom (a b c : ℤ) : GL3Dom :=
--+  ⟨sort₃ a b c, sort₃_fst_ge_snd a b c, sort₃_snd_ge_thd a b c⟩
--+
--+/-- The zero dominant coweight. -/
--+def GL3Dom.zero : GL3Dom := ⟨(0, 0, 0), le_refl _, le_refl _⟩
--+
--+instance : Zero GL3Dom := ⟨GL3Dom.zero⟩
--+
--+@[simp] theorem GL3Dom.zero_val : (0 : GL3Dom).1 = (0, 0, 0) := rfl
--+
--+/-- Componentwise addition of dominant coweights is dominant. -/
--+def GL3Dom.add (μ ν : GL3Dom) : GL3Dom :=
--+  ⟨(μ.1.1 + ν.1.1, μ.1.2.1 + ν.1.2.1, μ.1.2.2 + ν.1.2.2),
--+   by constructor <;> [linarith [μ.2.1, ν.2.1]; linarith [μ.2.2, ν.2.2]]⟩
--+
--+instance : Add GL3Dom := ⟨GL3Dom.add⟩
--+
--+@[simp] theorem GL3Dom.add_val (μ ν : GL3Dom) :
--+    (μ + ν).1 = (μ.1.1 + ν.1.1, μ.1.2.1 + ν.1.2.1, μ.1.2.2 + ν.1.2.2) := rfl
--+
--+/-- toGL3Dom of a dominant triple returns the original triple. -/
--+theorem toGL3Dom_of_dominant {a b c : ℤ} (h1 : a ≥ b) (h2 : b ≥ c) :
--+    toGL3Dom a b c = ⟨(a, b, c), h1, h2⟩ := by
--+  simp only [toGL3Dom]
--+  exact Subtype.ext (sort₃_of_dominant h1 h2)
--+
--+/-- toGL3Dom is invariant under transposition (12). -/
--+theorem toGL3Dom_swap12 (a b c : ℤ) : toGL3Dom b a c = toGL3Dom a b c := by
--+  exact Subtype.ext (sort₃_swap12 a b c)
--+
--+/-- toGL3Dom is invariant under the 3-cycle. -/
--+theorem toGL3Dom_cycle (a b c : ℤ) : toGL3Dom b c a = toGL3Dom a b c := by
--+  exact Subtype.ext (sort₃_cycle a b c)
--+
--+/-! ## Support Datum -/
--+
--+/-- A support datum is a function from dominant coweights to ℤ. -/
--+def SupportDatum := GL3Dom → ℤ
--+
--+instance : CoeFun SupportDatum (fun _ => GL3Dom → ℤ) := ⟨id⟩
--+
--+
--+
--+/-- Finite support means vanishing outside some finite set. -/
--+def FiniteSupport (h : SupportDatum) : Prop :=
--+  ∃ s : Finset GL3Dom, ∀ μ, μ ∉ s → h μ = 0
--+
--+/-! ## S₃-Invariant Functions (Tropical Hecke Functions) -/
--+
--+/-- A function f : ℤ³ → ℤ is S₃-invariant if it is invariant under
--+    transposition (12) and the 3-cycle (123). -/
--+def IsS3Invariant (f : ℤ → ℤ → ℤ → ℤ) : Prop :=
--+  (∀ a b c, f a b c = f b a c) ∧ (∀ a b c, f a b c = f b c a)
--+
--+/-- A tropical Hecke function for GL₃ is an S₃-invariant function ℤ³ → ℤ. -/
--+def TropicalHeckeGL3 := { f : ℤ → ℤ → ℤ → ℤ // IsS3Invariant f }
--+
--+instance : CoeFun TropicalHeckeGL3 (fun _ => ℤ → ℤ → ℤ → ℤ) := ⟨Subtype.val⟩
--+
--+/-- Extensionality for tropical Hecke functions. -/
--+@[ext] theorem TropicalHeckeGL3.ext {f g : TropicalHeckeGL3}
--+    (h : ∀ a b c, f.1 a b c = g.1 a b c) : f = g :=
--+  Subtype.ext (funext fun a => funext fun b => funext fun c => h a b c)
--+
--+/-! ## Satake Support Map -/
--+
--+/-- Extract the support datum: restrict a Hecke function to the dominant chamber. -/
--+def satakeSupport (f : TropicalHeckeGL3) : SupportDatum :=
--+  fun μ => f.1 μ.1.1 μ.1.2.1 μ.1.2.2
--+
--+/-! ## Satake Extension -/
--+
--+/-- Extend a support datum to an S₃-invariant function on ℤ³ via sorting. -/
--+def satakeExtend (h : SupportDatum) : ℤ → ℤ → ℤ → ℤ :=
--+  fun a b c => h (toGL3Dom a b c)
--+
--+theorem satakeExtend_invariant (h : SupportDatum) : IsS3Invariant (satakeExtend h) := by
--+  constructor
--+  · intro a b c; simp only [satakeExtend, toGL3Dom_swap12]
--+  · intro a b c; simp only [satakeExtend, toGL3Dom_cycle]
--+
--+/-- Lift a support datum to a tropical Hecke function. -/
--+def satakeExtendHecke (h : SupportDatum) : TropicalHeckeGL3 :=
--+  ⟨satakeExtend h, satakeExtend_invariant h⟩
--+
--+/-! ## S₃-invariant functions are determined by their dominant values -/
--+
--+/-
--+Any triple has the same S₃-invariant value as its sorted version.
--+-/
--+theorem s3_inv_eq_at_sort (f : ℤ → ℤ → ℤ → ℤ) (hf : IsS3Invariant f) (a b c : ℤ) :
--+    f a b c = f (sort₃ a b c).1 (sort₃ a b c).2.1 (sort₃ a b c).2.2 := by
--+  unfold sort₃; have := hf.1; have := hf.2; simp_all +decide [max_def, min_def] ;
--+  grind
--+
--+end GL3TropicalSatake+/-
+-+noncomputable section
+- 
+- open Finset
+- 
+--noncomputable section
+-+/-! ## Auxiliary lemmas for powersetCard -/
+- 
+--variable {n : ℕ}
+-+/-- Nonemptiness of powersetCard when k+1 ≤ C -/
+-+lemma powersetCard_univ_nonempty {C : ℕ} (k : ℕ) (h : k < C) :
+-+    ((univ : Finset (Fin C)).powersetCard (k + 1)).Nonempty := by
+-+  rw [powersetCard_nonempty, card_univ, Fintype.card_fin]; omega
+- 
+--/-- The score gap between class `i` and class `j` at input `x`. -/
+--def scoreGap {α : Type*} (f : α → Fin n → ℝ) (x : α) (i j : Fin n) : ℝ :=
+--  f x i - f x j
+-+/-- Any member of `powersetCard (k+1) univ` is nonempty -/
+-+lemma nonempty_of_mem_powersetCard_succ {C : ℕ} {k : ℕ} {S : Finset (Fin C)}
+-+    (hS : S ∈ (univ : Finset (Fin C)).powersetCard (k + 1)) : S.Nonempty := by
+-+  rw [nonempty_iff_ne_empty]
+-+  intro h
+-+  have := (mem_powersetCard.mp hS).2
+-+  rw [h, card_empty] at this; omega
+- 
+--/-- The complement of `S` in `Fin n`, as a `Finset`. -/
+--def finCompl (S : Finset (Fin n)) : Finset (Fin n) :=
+--  Finset.univ.filter fun j => j ∉ S
+-+/-- Card of members of powersetCard -/
+-+lemma card_of_mem_powersetCard {C : ℕ} {k : ℕ} {S : Finset (Fin C)}
+-+    (hS : S ∈ (univ : Finset (Fin C)).powersetCard (k + 1)) : S.card = k + 1 :=
+-+  (mem_powersetCard.mp hS).2
+- 
+--/-- The finite set of all score gaps `f(x,i) - f(x,j)` for `i ∈ S` and `j ∉ S`. -/
+--def crossGaps {α : Type*} (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n)) : Finset ℝ :=
+--  (S ×ˢ finCompl S).image (fun p => scoreGap f x p.1 p.2)
+-+/-! ## Core Definitions -/
+- 
+--/-- Nonemptiness of `crossGaps` from nonemptiness of `S` and its complement. -/
+--theorem crossGaps_nonempty {α : Type*} (f : α → Fin n → ℝ) (x : α)
+--    (S : Finset (Fin n))
+--    (hS : S.Nonempty) (hSc : (finCompl S).Nonempty) :
+--    (crossGaps f x S).Nonempty := by
+--  rcases hS with ⟨i, hi⟩; rcases hSc with ⟨j, hj⟩
+--  exact ⟨scoreGap f x i j, Finset.mem_image.mpr
+--    ⟨(i, j), Finset.mem_product.mpr ⟨hi, hj⟩, rfl⟩⟩
+-+/-- The k-th largest value (0-indexed) of a finite score function `s : Fin C → ℝ`.
+-+    Defined as the maximum over all (k+1)-element subsets of `Fin C` of the
+-+    minimum value of `s` on the subset:
+-+      `kthLargest s k = sup_{|S|=k+1} inf_{i ∈ S} s(i)`
+-+    Returns 0 if `k ≥ C`. -/
+-+def kthLargest {C : ℕ} (s : Fin C → ℝ) (k : ℕ) : ℝ :=
+-+  if h : k < C then
+-+    ((univ : Finset (Fin C)).powersetCard (k + 1)).sup'
+-+      (powersetCard_univ_nonempty k h)
+-+      (fun S => if hne : S.Nonempty then S.inf' hne s else 0)
+-+  else 0
+- 
+--/-- The minimum score gap across all `(i ∈ S, j ∉ S)` pairs.
+--This is the "top-k margin" — the smallest advantage any in-set class holds
+--over any out-set class. -/
+--def topkMargin' {α : Type*} (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n))
+--    (hS : S.Nonempty) (hSc : (finCompl S).Nonempty) : ℝ :=
+--  (crossGaps f x S).min' (crossGaps_nonempty f x S hS hSc)
+-+/-- The top-k gap: the difference between the k-th largest and (k+1)-th largest values.
+-+    For `k ≥ 1`, this measures the separation between the top-k scores and the rest.
+-+    `topkGap s k = kthLargest s (k-1) - kthLargest s k` -/
+-+def topkGap {C : ℕ} (s : Fin C → ℝ) (k : ℕ) : ℝ :=
+-+  kthLargest s (k - 1) - kthLargest s k
+- 
+--/-- `S` is a (weak) top-k set at `x`: every class in `S` has score ≥ every class
+--outside `S`. -/
+--def IsTopKSet {α : Type*} (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n)) : Prop :=
+--  ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → f x j ≤ f x i
+-+/-- The top-k set: the set of indices whose score strictly exceeds the (k+1)-th
+-+    largest value. Under a positive gap condition, this has exactly k elements. -/
+-+def topKSet {C : ℕ} (s : Fin C → ℝ) (k : ℕ) : Finset (Fin C) :=
+-+  univ.filter (fun i => kthLargest s k < s i)
+- 
+--/-- `S` is a strict top-k set at `x`: every class in `S` has score strictly greater
+--than every class outside `S`. -/
+--def StrictTopKSet {α : Type*} (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n)) : Prop :=
+--  ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → f x j < f x i
+-+/-! ## Basic kthLargest simplification -/
+- 
+--/-- A strict top-k set is also a weak top-k set. -/
+--theorem StrictTopKSet.isTopKSet {α : Type*} {f : α → Fin n → ℝ} {x : α}
+--    {S : Finset (Fin n)}
+--    (h : StrictTopKSet f x S) : IsTopKSet f x S :=
+--  fun _ _ hi hj => le_of_lt (h hi hj)
+-+/-- Unfold kthLargest when k < C -/
+-+lemma kthLargest_def {C : ℕ} (s : Fin C → ℝ) (k : ℕ) (hk : k < C) :
+-+    kthLargest s k =
+-+      ((univ : Finset (Fin C)).powersetCard (k + 1)).sup'
+-+        (powersetCard_univ_nonempty k hk)
+-+        (fun S => if hne : S.Nonempty then S.inf' hne s else 0) := by
+-+  simp [kthLargest, hk]
+- 
+--/-- Membership in `crossGaps` unpacked. -/
+--theorem mem_crossGaps_iff {α : Type*} {f : α → Fin n → ℝ} {x : α}
+--    {S : Finset (Fin n)} {r : ℝ} :
+--    r ∈ crossGaps f x S ↔ ∃ i ∈ S, ∃ j, j ∉ S ∧ r = scoreGap f x i j := by
+--  simp only [crossGaps, Finset.mem_image, Finset.mem_product, finCompl,
+--    Finset.mem_filter, Finset.mem_univ, true_and]
+--  constructor
+--  · rintro ⟨⟨i, j⟩, ⟨hi, hj⟩, heq⟩
+--    exact ⟨i, hi, j, hj, heq.symm⟩
+--  · rintro ⟨i, hi, j, hj, heq⟩
+--    exact ⟨⟨i, j⟩, ⟨hi, hj⟩, heq.symm⟩
+--
+--/-- Every `(i, j)` gap with `i ∈ S`, `j ∉ S` is at least the top-k margin. -/
+--theorem topkMargin'_le_scoreGap {α : Type*} {f : α → Fin n → ℝ} {x : α}
+--    {S : Finset (Fin n)}
+--    {hS : S.Nonempty} {hSc : (finCompl S).Nonempty}
+--    {i j : Fin n} (hi : i ∈ S) (hj : j ∉ S) :
+--    topkMargin' f x S hS hSc ≤ scoreGap f x i j := by
+--  apply Finset.min'_le
+--  simp only [crossGaps, Finset.mem_image, Finset.mem_product, finCompl,
+--    Finset.mem_filter, Finset.mem_univ, true_and]
+--  exact ⟨⟨i, j⟩, ⟨hi, hj⟩, rfl⟩
+--
+--/-- Positive top-k margin implies `StrictTopKSet`. -/
+--theorem strictTopKSet_of_pos_margin {α : Type*} {f : α → Fin n → ℝ} {x : α}
+--    {S : Finset (Fin n)}
+--    {hS : S.Nonempty} {hSc : (finCompl S).Nonempty}
+--    (hpos : 0 < topkMargin' f x S hS hSc) :
+--    StrictTopKSet f x S := by
+--  intro i j hi hj
+--  have h : topkMargin' f x S hS hSc ≤ scoreGap f x i j :=
+--    topkMargin'_le_scoreGap hi hj
+--  simp only [scoreGap] at h
+--  linarith
+-+/-- The sup' function on powersetCard evaluates to inf' on nonempty subsets -/
+-+lemma kthLargest_eq_sup'_inf' {C : ℕ} (s : Fin C → ℝ) (k : ℕ) (hk : k < C) :
+-+    kthLargest s k =
+-+      ((univ : Finset (Fin C)).powersetCard (k + 1)).sup'
+-+        (powersetCard_univ_nonempty k hk)
+-+        (fun S => if hne : S.Nonempty then S.inf' hne s else 0) :=
+-+  kthLargest_def s k hk
+- 
+- end+/-
 +Copyright (c) 2025. All rights reserved.
 +Released under Apache 2.0 license as described in the file LICENSE.
 +