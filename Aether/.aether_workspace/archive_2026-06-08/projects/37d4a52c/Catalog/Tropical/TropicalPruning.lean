import Mathlib

/-!
# Tropical Polynomial Pruning: Certified Semantic Compression

This file establishes the mathematical foundations for **tropical polynomial pruning**,
a framework for certified compression and interpretability of piecewise-linear models
(such as ReLU neural networks) through tropical geometry.

## Overview

A tropical polynomial is a finite maximum of affine forms. Canonical pruning removes
monomials (affine templates) that are *strictly* dominated on a finite domain — meaning
there exists another monomial that is at least as large everywhere and strictly larger
somewhere. This yields an equivalent but potentially smaller tropical polynomial.

## Key Design Choice: Strict Domination

We use **strict domination** (≤ everywhere, < somewhere) rather than weak domination
(≤ everywhere). This is essential because weak domination can cause mutual elimination
of functionally equivalent but structurally distinct monomials, breaking the preservation
theorem. Strict domination is acyclic on finite sets, ensuring that the pruning process
terminates with correct semantics.

## Main Results

* `canonicalOn_eval_eq` — **Theorem A**: Canonical pruning preserves evaluation.
* `max_affine_relu_bridge` — Max of affine forms is ReLU-computable.
* `relu_tropical_pruning_sound` — **Theorem B**: ReLU-tropical pruning soundness.
* `card_canonicalOn_le` — **Theorem D**: Canonical support ≤ original support.
-/

noncomputable section

open Finset BigOperators

/-! ## Core Definitions -/

/-- A tropical monomial (affine template) in `n` variables.
    Represents `x ↦ bias + ∑ᵢ weight i * x i`. -/
structure TPMonomial (n : ℕ) where
  bias : ℝ
  weight : Fin n → ℝ
  deriving DecidableEq

namespace TPMonomial

/-- Evaluate a tropical monomial at a point. -/
def eval (m : TPMonomial n) (x : Fin n → ℝ) : ℝ :=
  m.bias + ∑ i, m.weight i * x i

@[simp]
theorem eval_mk (b : ℝ) (w : Fin n → ℝ) (x : Fin n → ℝ) :
    (TPMonomial.mk b w).eval x = b + ∑ i, w i * x i := rfl

end TPMonomial

/-- A tropical polynomial: a nonempty finite set of monomials.
    Evaluation takes the supremum (max). -/
structure TPoly (n : ℕ) where
  support : Finset (TPMonomial n)
  nonempty : support.Nonempty

namespace TPoly

/-- Evaluate: max over monomial evaluations. -/
def eval (p : TPoly n) (x : Fin n → ℝ) : ℝ :=
  p.support.sup' p.nonempty (fun m => m.eval x)

/-- Monomials achieving the maximum at a point. -/
def argmax (p : TPoly n) (x : Fin n → ℝ) : Finset (TPMonomial n) :=
  p.support.filter (fun m => m.eval x = p.eval x)

end TPoly

/-- **Strict domination**: `m` is strictly dominated by `m'` on domain `D` if
    `m.eval x ≤ m'.eval x` for all `x ∈ D`, and `m.eval x < m'.eval x` for
    some `x ∈ D`. This is acyclic on finite domains, which is essential for
    the pruning preservation theorem. -/
def StrictlyDominatedOn (D : Finset (Fin n → ℝ)) (m m' : TPMonomial n) : Prop :=
  (∀ x ∈ D, m.eval x ≤ m'.eval x) ∧ (∃ x ∈ D, m.eval x < m'.eval x)

/-- A monomial is strictly dominated in a polynomial if some other support monomial
    strictly dominates it on the entire domain. -/
def IsStrictlyDominated (D : Finset (Fin n → ℝ)) (p : TPoly n)
    (m : TPMonomial n) : Prop :=
  ∃ m' ∈ p.support, m' ≠ m ∧ StrictlyDominatedOn D m m'

instance instDecStrictlyDominatedOn (D : Finset (Fin n → ℝ))
    (m m' : TPMonomial n) : Decidable (StrictlyDominatedOn D m m') :=
  inferInstanceAs (Decidable ((∀ x ∈ D, m.eval x ≤ m'.eval x) ∧
    (∃ x ∈ D, m.eval x < m'.eval x)))

instance instDecIsStrictlyDominated (D : Finset (Fin n → ℝ))
    (p : TPoly n) (m : TPMonomial n) :
    Decidable (IsStrictlyDominated D p m) :=
  inferInstanceAs (Decidable (∃ m' ∈ p.support, m' ≠ m ∧ StrictlyDominatedOn D m m'))

namespace TPoly

/-- **Canonical pruning**: remove strictly dominated monomials.
    Falls back to `p` if the filter empties. -/
def canonicalOn (D : Finset (Fin n → ℝ)) (p : TPoly n) : TPoly n :=
  let filtered := p.support.filter (fun m => ¬IsStrictlyDominated D p m)
  if h : filtered.Nonempty then ⟨filtered, h⟩ else p

/-- Canonical support ⊆ original support. -/
theorem canonicalOn_support_sub (D : Finset (Fin n → ℝ)) (p : TPoly n) :
    (p.canonicalOn D).support ⊆ p.support := by
  unfold canonicalOn; simp only; split
  · exact Finset.filter_subset _ _
  · exact Finset.Subset.refl _

/-- A monomial is **essential** on `D` if it achieves the max at some domain point. -/
def EssentialOn (D : Finset (Fin n → ℝ)) (p : TPoly n) (m : TPMonomial n) : Prop :=
  m ∈ p.support ∧ ∃ x ∈ D, m.eval x = p.eval x

end TPoly

/-! ## Helper lemmas -/

/-- `sup'` over a subset ≤ `sup'` over the superset. -/
theorem sup'_mono_subset (s t : Finset (TPMonomial n))
    (hst : s ⊆ t) (hs : s.Nonempty) (ht : t.Nonempty) (x : Fin n → ℝ) :
    s.sup' hs (fun m => m.eval x) ≤ t.sup' ht (fun m => m.eval x) := by
  exact Finset.sup'_le _ _ fun m hm => Finset.le_sup' (fun m => m.eval x) (hst hm)

/-
There exists a monomial achieving the sup'.
-/
theorem exists_sup'_eq (p : TPoly n) (x : Fin n → ℝ) :
    ∃ m ∈ p.support, m.eval x = p.eval x := by
  -- By definition of `sup'`, there exists some `m` in `p.support` such that `m.eval x` is the greatest element in `p.support`.
  have h_max : ∃ m ∈ p.support, ∀ n ∈ p.support, n.eval x ≤ m.eval x := by
    exact Finset.exists_max_image _ _ p.nonempty;
  exact h_max.imp fun m hm => ⟨ hm.1, le_antisymm ( Finset.le_sup' ( fun m => m.eval x ) hm.1 ) ( Finset.sup'_le _ _ fun n hn => hm.2 n hn ) ⟩

/-
For strictly dominated m by m', if we follow the chain of strict dominations
    in a finite set, we eventually reach an undominated element with value ≥ m.
-/
theorem exists_undominated_ge (D : Finset (Fin n → ℝ))
    (p : TPoly n) (m : TPMonomial n) (hm : m ∈ p.support)
    (x : Fin n → ℝ) (hx : x ∈ D) :
    ∃ m' ∈ p.support, ¬IsStrictlyDominated D p m' ∧ m.eval x ≤ m'.eval x := by
  revert hx m hm;
  intro m hm hx_contra;
  -- By induction on the number of monomials strictly dominating $m$.
  induction' k : (p.support.filter fun m' => StrictlyDominatedOn D m m').card using Nat.strong_induction_on with k ih generalizing m;
  by_cases h : ∃ m' ∈ p.support, StrictlyDominatedOn D m m';
  · obtain ⟨ m', hm', hm'' ⟩ := h;
    have h_card : (p.support.filter fun m'' => StrictlyDominatedOn D m' m'').card < (p.support.filter fun m'' => StrictlyDominatedOn D m m'').card := by
      refine' Finset.card_lt_card _;
      simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
      grind +locals;
    specialize ih _ ( by linarith ) _ hm' rfl;
    exact ⟨ ih.choose, ih.choose_spec.1, ih.choose_spec.2.1, le_trans ( hm''.1 x hx_contra ) ih.choose_spec.2.2 ⟩;
  · exact ⟨ m, hm, fun ⟨ m', hm', hm'', hm''' ⟩ => h ⟨ m', hm', hm''' ⟩, le_rfl ⟩

/-! ## Theorem A: Canonical pruning preserves evaluation -/

/-
**Theorem A (Canonical Pruning Preserves Semantics).**

    Removing all monomials that are strictly dominated (≤ everywhere, < somewhere)
    on the domain does not change the evaluation at any domain point.

    The proof uses two key facts:
    1. Canonical support ⊆ original support, so canonical eval ≤ original eval.
    2. For each monomial m in the original support, there exists an undominated
       monomial m' with m'(x) ≥ m(x), because strict domination is acyclic on
       finite sets. Thus original eval ≤ canonical eval.
-/
theorem canonicalOn_eval_eq (D : Finset (Fin n → ℝ)) (p : TPoly n) :
    ∀ x ∈ D, (p.canonicalOn D).eval x = p.eval x := by
  unfold TPoly.canonicalOn;
  intro x hx
  by_cases h : ∃ m ∈ p.support, ¬IsStrictlyDominated D p m;
  · have h_sup_ge : p.eval x ≤ Finset.sup' (Finset.filter (fun m => ¬IsStrictlyDominated D p m) p.support) (by
    exact ⟨ h.choose, Finset.mem_filter.mpr ⟨ h.choose_spec.1, h.choose_spec.2 ⟩ ⟩) (fun m => m.eval x) := by
      obtain ⟨ m, hm₁, hm₂ ⟩ := exists_sup'_eq p x;
      obtain ⟨ m', hm'₁, hm'₂ ⟩ := exists_undominated_ge D p m hm₁ x hx;
      exact hm₂ ▸ hm'₂.2.trans ( Finset.le_sup' ( fun m => m.eval x ) ( Finset.mem_filter.mpr ⟨ hm'₁, hm'₂.1 ⟩ ) )
    generalize_proofs at *;
    refine' le_antisymm _ _ <;> simp_all +decide [ TPoly.eval ];
    exact ⟨ h_sup_ge.choose, h_sup_ge.choose_spec.1.1, fun m hm hm' => h_sup_ge.choose_spec.2 m hm ⟩;
  · grind

/-! ## ReLU bridge -/

/-- ReLU function. -/
def reluFn (x : ℝ) : ℝ := max x 0

/-- Max of two affine forms is expressible via ReLU. -/
theorem max_affine_relu_bridge (a b c d : ℝ) (x : ℝ) :
    max (a * x + b) (c * x + d) =
      reluFn (a * x + b - (c * x + d)) + (c * x + d) := by
  unfold reluFn
  cases max_cases (a * x + b) (c * x + d) <;>
    cases max_cases (a * x + b - (c * x + d)) 0 <;> linarith

/-! ## Theorem B: ReLU-tropical pruning soundness -/

/-- Construct a tropical polynomial from an affine family. -/
def TPoly.ofAffineFamily {n k : ℕ} (A : Fin k → (Fin n → ℝ))
    (b : Fin k → ℝ) (hk : 0 < k) : TPoly n where
  support := Finset.univ.image (fun i => TPMonomial.mk (b i) (A i))
  nonempty := ⟨_, Finset.mem_image.mpr ⟨⟨0, hk⟩, Finset.mem_univ _, rfl⟩⟩

/-- **Theorem B (ReLU-Tropical Pruning Soundness).**
    Canonical pruning of a max-affine network preserves the computed function. -/
theorem relu_tropical_pruning_sound (D : Finset (Fin n → ℝ)) {k : ℕ}
    (A : Fin k → (Fin n → ℝ)) (b : Fin k → ℝ) (hk : 0 < k) :
    let p := TPoly.ofAffineFamily A b hk
    ∀ x ∈ D, p.eval x = (p.canonicalOn D).eval x := by
  intro p x hx; exact (canonicalOn_eval_eq D p x hx).symm

/-! ## Theorem C direction: essential monomials survive -/

/-
**Theorem C (Uniquely-Maximal Monomial Survives).**
    If `m` is *strictly* the maximum at some domain point (beats all other
    monomials), then `m` cannot be strictly dominated and thus survives
    canonical pruning.

    This is the interpretability direction: monomials with unique witness
    points are guaranteed to survive as essential decision templates.
-/
theorem uniquely_maximal_survives_canonicalOn (D : Finset (Fin n → ℝ))
    (p : TPoly n) (m : TPMonomial n)
    (hm : m ∈ p.support)
    (hstrict : ∃ x ∈ D, ∀ m' ∈ p.support, m' ≠ m → m'.eval x < m.eval x) :
    m ∈ (p.canonicalOn D).support := by
  grind +locals

/-! ## Theorem D: Compression bound -/

/-- **Theorem D (Basic Compression Bound).**
    The canonical support is no larger than the original support. -/
theorem card_canonicalOn_le (D : Finset (Fin n → ℝ)) (p : TPoly n) :
    (p.canonicalOn D).support.card ≤ p.support.card :=
  Finset.card_le_card (TPoly.canonicalOn_support_sub D p)

end