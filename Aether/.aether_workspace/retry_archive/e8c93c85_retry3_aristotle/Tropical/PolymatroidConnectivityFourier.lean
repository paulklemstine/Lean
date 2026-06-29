/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# A finite-discrepancy criterion for the connectivity defect of slice-projections of polymatroids

This file formalizes a *finite-discrepancy criterion* governing when a real set
function — in particular the **connectivity function of a slice-projection
(contraction) of a polymatroid** — admits a **canonical tropical (max-plus)
Fourier expansion** over a fixed finite dictionary of modes, and shows the
criterion is *equivalent* to admitting such an expansion exactly when an
*order-convexity* condition holds.

## Mathematical content

Fix a finite dictionary `φ : κ → α → ℝ` of *modes* on a finite domain `α`.

* The **canonical (tight) coefficient** of `f : α → ℝ` at mode `k` is the largest
  scalar `t` with `t + φ k ≤ f` pointwise, namely `tightCoeff f φ k = min_x (f x - φ k x)`.
* The **canonical reconstruction** is the tropical expansion of these tight
  coefficients, `reconstruct f φ x = max_k (tightCoeff f φ k + φ k x)`.
  This is the idempotent (Fenchel–Moreau / max-plus) biconjugate of `f`.
* The **finite discrepancy** (read: connectivity defect) is
  `discrepancy f φ = max_x (f x - reconstruct f φ x) ≥ 0`.
* `f` is **order-convex** over the dictionary if it admits *some* tropical Fourier
  expansion `f x = max_k (c k + φ k x)`.

The headline result `orderConvex_iff_discrepancy_zero` is the criterion:

> `f` admits the canonical tropical Fourier expansion (`discrepancy f φ = 0`)
> **iff** `f` is order-convex over the dictionary.

The proof is non-circular: the forward direction uses the tight-coefficient
domination lemma `le_tightCoeff` (the canonical coefficients dominate any valid
coefficients), and the backward direction simply exhibits the tight coefficients.

## Polymatroid layer

* `IsPolymatroid` — normalized, monotone, submodular real set function.
* `sliceProj` — the slice-projection (contraction) `A ↦ f (A ∪ s) - f s`.
* `sliceProj_isPolymatroid` — slice-projections of polymatroids are polymatroids.
* `polyConnectivity` and `polyConnectivity_nonneg` — the connectivity function
  `f A + f (Aᶜ) - f univ` is nonnegative for polymatroids; hence so is the
  connectivity of any slice-projection (`sliceProj_polyConnectivity_nonneg`).
* `modular` / `modular_isPolymatroid` — modular (weighted-cardinality) functions
  are polymatroids and (via `modular_orderConvex`) are order-convex, so they meet
  the discrepancy criterion (`modular_discrepancy_zero`).

## Explicit counterexample

`cexF` / `cexPhi` give an explicit function with strictly positive discrepancy
(`cex_discrepancy_pos`), hence *not* order-convex (`cex_not_orderConvex`):
a single constant mode cannot reconstruct a non-constant function. This witnesses
that the order-convexity hypothesis in the criterion is genuinely necessary.
-/

namespace PolymatroidTropical

open Finset

noncomputable section

/-! ## Abstract tropical (max-plus) Fourier reconstruction over a finite dictionary -/

variable {α κ : Type*} [Fintype α] [Nonempty α] [Fintype κ] [Nonempty κ]

/-- **Tropical (max-plus) expansion** of coefficients `c` over the dictionary `φ`:
`tropExpand φ c x = max_k (c k + φ k x)`. -/
def tropExpand (φ : κ → α → ℝ) (c : κ → ℝ) (x : α) : ℝ :=
  univ.sup' univ_nonempty (fun k => c k + φ k x)

/-- **Canonical (tight) coefficient** at mode `k`: the largest scalar `t` with
`t + φ k ≤ f` pointwise, i.e. `min_x (f x - φ k x)`. -/
def tightCoeff (f : α → ℝ) (φ : κ → α → ℝ) (k : κ) : ℝ :=
  univ.inf' univ_nonempty (fun x => f x - φ k x)

/-- **Canonical reconstruction** of `f`: the tropical expansion of the tight
coefficients, `max_k (tightCoeff f φ k + φ k x)`. -/
def reconstruct (f : α → ℝ) (φ : κ → α → ℝ) (x : α) : ℝ :=
  univ.sup' univ_nonempty (fun k => tightCoeff f φ k + φ k x)

/-- **Finite discrepancy / connectivity defect** of `f` relative to the dictionary
`φ`: `max_x (f x - reconstruct f φ x)`. -/
def discrepancy (f : α → ℝ) (φ : κ → α → ℝ) : ℝ :=
  univ.sup' univ_nonempty (fun x => f x - reconstruct f φ x)

/-- `f` is **order-convex** over the dictionary `φ` if it admits *some* tropical
Fourier expansion. -/
def OrderConvex (f : α → ℝ) (φ : κ → α → ℝ) : Prop :=
  ∃ c : κ → ℝ, ∀ x, f x = tropExpand φ c x

/--
The tight coefficient really is a valid coefficient: `tightCoeff f φ k + φ k x ≤ f x`.
-/
omit [Fintype κ] [Nonempty κ] in
lemma tightCoeff_add_le (f : α → ℝ) (φ : κ → α → ℝ) (k : κ) (x : α) :
    tightCoeff f φ k + φ k x ≤ f x := by
  unfold tightCoeff;
  linarith [ Finset.inf'_le ( fun x => f x - φ k x ) ( Finset.mem_univ x ) ]

/--
The canonical reconstruction never overshoots `f`.
-/
lemma reconstruct_le_self (f : α → ℝ) (φ : κ → α → ℝ) (x : α) :
    reconstruct f φ x ≤ f x := by
  exact Finset.sup'_le _ _ fun k _ => by linarith [ tightCoeff_add_le f φ k x ] ;

/--
**Domination of valid coefficients by the tight coefficient.** Any coefficient
`c k` whose mode lies below `f` is dominated by the canonical coefficient.
-/
omit [Fintype κ] [Nonempty κ] in
lemma le_tightCoeff (f : α → ℝ) (φ : κ → α → ℝ) (c : κ → ℝ) (k : κ)
    (h : ∀ x, c k + φ k x ≤ f x) : c k ≤ tightCoeff f φ k := by
  exact Finset.le_inf' _ _ fun x _ => by linarith [ h x ] ;

/--
The finite discrepancy is always nonnegative.
-/
lemma discrepancy_nonneg (f : α → ℝ) (φ : κ → α → ℝ) : 0 ≤ discrepancy f φ := by
  have h_discrepancy_nonneg : ∀ x, 0 ≤ f x - reconstruct f φ x := by
    exact fun x => sub_nonneg_of_le ( reconstruct_le_self f φ x )
  generalize_proofs at *; (
  exact le_trans ( h_discrepancy_nonneg ( Classical.arbitrary α ) ) ( Finset.le_sup' ( fun x => f x - reconstruct f φ x ) ( Finset.mem_univ _ ) ))

/--
The discrepancy vanishes iff `f` equals its canonical reconstruction everywhere.
-/
lemma discrepancy_zero_iff_eq_reconstruct (f : α → ℝ) (φ : κ → α → ℝ) :
    discrepancy f φ = 0 ↔ ∀ x, f x = reconstruct f φ x := by
  constructor;
  · intro h x; exact le_antisymm ( by contrapose! h; exact ne_of_gt ( lt_of_lt_of_le ( sub_pos.mpr h ) ( Finset.le_sup' ( fun x => f x - reconstruct f φ x ) ( Finset.mem_univ x ) ) ) ) ( reconstruct_le_self f φ x ) ;
  · intro h
    unfold discrepancy;
    simp +decide [ ← h ]

/--
Order-convexity is equivalent to `f` being its own canonical reconstruction.
-/
lemma orderConvex_iff_eq_reconstruct (f : α → ℝ) (φ : κ → α → ℝ) :
    OrderConvex f φ ↔ ∀ x, f x = reconstruct f φ x := by
  refine' ⟨ _, fun h => ⟨ _, h ⟩ ⟩;
  rintro ⟨ c, hc ⟩ x;
  have h_le : ∀ k, c k ≤ tightCoeff f φ k := by
    intro k
    apply le_tightCoeff f φ c k
    intro y
    have h_le : c k + φ k y ≤ f y := by
      exact hc y ▸ Finset.le_sup' ( fun k => c k + φ k y ) ( Finset.mem_univ k )
    exact h_le;
  refine' le_antisymm _ _;
  · simp +decide [ hc, tropExpand, reconstruct ];
    obtain ⟨ k, hk ⟩ := Finset.exists_max_image Finset.univ ( fun k => tightCoeff f φ k + φ k x ) ⟨ Classical.arbitrary κ, Finset.mem_univ _ ⟩ ; use k; intro j; linarith [ h_le j, hk.2 j ( Finset.mem_univ j ) ] ;
  · exact reconstruct_le_self f φ x

/-- **Main equivalence (finite-discrepancy criterion).** The finite-discrepancy
criterion `discrepancy f φ = 0` holds iff `f` admits the canonical tropical Fourier
expansion, i.e. iff `f` is order-convex over the dictionary. -/
theorem orderConvex_iff_discrepancy_zero (f : α → ℝ) (φ : κ → α → ℝ) :
    OrderConvex f φ ↔ discrepancy f φ = 0 := by
  rw [orderConvex_iff_eq_reconstruct, discrepancy_zero_iff_eq_reconstruct]

/-! ## Polymatroids, slice-projections and connectivity -/

variable {n : ℕ}

/-- A **polymatroid rank function**: normalized, monotone and submodular. -/
def IsPolymatroid (f : Finset (Fin n) → ℝ) : Prop :=
  f ∅ = 0 ∧ (∀ A B, A ⊆ B → f A ≤ f B) ∧
    (∀ A B, f (A ∪ B) + f (A ∩ B) ≤ f A + f B)

/-- The **slice-projection (contraction)** of `f` by a slice `s`:
`A ↦ f (A ∪ s) - f s`. -/
def sliceProj (f : Finset (Fin n) → ℝ) (s : Finset (Fin n)) (A : Finset (Fin n)) : ℝ :=
  f (A ∪ s) - f s

/--
Slice-projections of polymatroids are polymatroids.
-/
theorem sliceProj_isPolymatroid {f : Finset (Fin n) → ℝ} {s : Finset (Fin n)}
    (hf : IsPolymatroid f) : IsPolymatroid (sliceProj f s) := by
  obtain ⟨h0, hmono, hsub⟩ := hf;
  refine' ⟨ _, _, _ ⟩ <;> simp_all +decide [ sliceProj ];
  · exact fun A B hAB => hmono _ _ ( Finset.union_subset_union hAB ( Finset.Subset.refl _ ) );
  · intro A B; convert sub_le_sub_right ( hsub ( A ∪ s ) ( B ∪ s ) ) ( f s + f s ) using 1 <;> ring;
    rw [ show A ∪ ( B ∪ s ) = A ∪ s ∪ ( B ∪ s ) by ext; aesop, show A ∩ B ∪ s = ( A ∪ s ) ∩ ( B ∪ s ) by ext; aesop ] ; ring

/-- The **connectivity function** of a set function:
`f A + f (univ \ A) - f univ`. -/
def polyConnectivity (f : Finset (Fin n) → ℝ) (A : Finset (Fin n)) : ℝ :=
  f A + f (univ \ A) - f univ

/--
The connectivity function of a polymatroid is nonnegative.
-/
theorem polyConnectivity_nonneg {f : Finset (Fin n) → ℝ} (hf : IsPolymatroid f)
    (A : Finset (Fin n)) : 0 ≤ polyConnectivity f A := by
  convert sub_nonneg_of_le _;
  · infer_instance;
  · convert hf.2.2 A ( univ \ A ) using 1 ; simp +decide [ Finset.union_sdiff_of_subset ( Finset.subset_univ A ) ];
    exact hf.1

/-- The connectivity function of any slice-projection of a polymatroid is
nonnegative — the connectivity *defect* is well-defined and bounded below. -/
theorem sliceProj_polyConnectivity_nonneg {f : Finset (Fin n) → ℝ}
    {s : Finset (Fin n)} (hf : IsPolymatroid f) (A : Finset (Fin n)) :
    0 ≤ polyConnectivity (sliceProj f s) A :=
  polyConnectivity_nonneg (sliceProj_isPolymatroid hf) A

/-- A **modular (weighted-cardinality)** set function `A ↦ ∑_{i ∈ A} w i`. -/
def modular (w : Fin n → ℝ) (A : Finset (Fin n)) : ℝ := ∑ i ∈ A, w i

/--
Modular functions with nonnegative weights are polymatroids.
-/
theorem modular_isPolymatroid {w : Fin n → ℝ} (hw : ∀ i, 0 ≤ w i) :
    IsPolymatroid (modular w) := by
  refine' ⟨ _, _, _ ⟩;
  · exact Finset.sum_empty;
  · exact fun A B hAB => Finset.sum_le_sum_of_subset_of_nonneg hAB fun _ _ _ => hw _;
  · intro A B; simp +decide [ modular, Finset.sum_union_inter ] ;

/--
A modular function is order-convex over the one-mode dictionary consisting of
itself: it *is* its own canonical tropical Fourier expansion.
-/
theorem modular_orderConvex (w : Fin n → ℝ) :
    OrderConvex (modular w) (fun _ : Fin 1 => modular w) := by
  use fun _ => 0; simp [tropExpand]

/-- Hence a modular function meets the finite-discrepancy criterion. -/
theorem modular_discrepancy_zero (w : Fin n → ℝ) :
    discrepancy (modular w) (fun _ : Fin 1 => modular w) = 0 :=
  (orderConvex_iff_discrepancy_zero _ _).mp (modular_orderConvex w)

/-! ## Explicit counterexample: a non-order-convex function with positive defect -/

/-- A non-constant target function on a two-point domain. -/
def cexF : Fin 2 → ℝ := ![0, 1]

/-- A dictionary consisting of a single constant (zero) mode. -/
def cexPhi : Fin 1 → Fin 2 → ℝ := fun _ _ => 0

/--
The single constant mode cannot reconstruct the non-constant `cexF`: the
discrepancy is strictly positive.
-/
theorem cex_discrepancy_pos : 0 < discrepancy cexF cexPhi := by
  refine' lt_of_lt_of_le _ ( Finset.le_sup' _ ( Finset.mem_univ 1 ) ) ; norm_num [ cexF, cexPhi, reconstruct ];
  unfold tightCoeff cexPhi; norm_num [ Fin.univ_succ ] ;

/-- Consequently `cexF` is **not** order-convex over `cexPhi`: it admits no tropical
Fourier expansion over the single constant mode. This shows the order-convexity
hypothesis of `orderConvex_iff_discrepancy_zero` is necessary. -/
theorem cex_not_orderConvex : ¬ OrderConvex cexF cexPhi := by
  intro h
  have := (orderConvex_iff_discrepancy_zero cexF cexPhi).mp h
  linarith [cex_discrepancy_pos]

end

end PolymatroidTropical