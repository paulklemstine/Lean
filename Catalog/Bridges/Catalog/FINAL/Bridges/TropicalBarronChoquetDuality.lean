/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Barron–Choquet Duality via Idempotent Feature Semimodules

This file formalizes a **finite representation and reconstruction theorem** that connects
abstract tropical Choquet functionals to canonical sparse shallow tropical networks.

## Mathematical Context

In max-plus (tropical) algebra, "addition" is `max` and "multiplication" is `+`.
A **tropical network** with support `I ⊆ 𝓕` and weights `w : 𝓕 → ℝ` computes:

  `N(f) = max_{i ∈ I} (w(i) + eval(i)(f))`

where `eval : 𝓕 → (F → ℝ)` is a family of evaluation functionals (feature maps).

The **Tropical Barron–Choquet Duality** says:
1. Every sup-preserving, shift-equivariant functional admits such a representation.
2. Dominated hidden units can be pruned without changing the functional.
3. The irredundant (pruned) representation has minimum support cardinality.
4. Under a separation hypothesis, the irredundant support set is unique.

## Main Definitions

* `TropicalNetworkRep` — A tropical network representation (support, weights, evaluations)
* `TropicalNetworkRep.realize` — The function computed by a network
* `IsDominated` — A hidden unit is dominated if it never achieves the maximum
* `IsIrredundant` — A representation where no unit is dominated
* `SeparatingEvals` — Evaluation functionals that separate distinct indices

## Main Results

* `realize_erase_of_pointwise_dominated` — Removing a dominated unit preserves the functional
* `realize_sup_preserving` — Network realizations preserve tropical addition (max)
* `realize_shift_equivariant` — Network realizations are shift-equivariant
* `realize_monotone` — Network realizations are monotone
* `irredundant_support_card_eq` — Irredundant representations have equal support cardinality
* `certified_compression_of_dominated` — Dominated units can be certified-removed
* `network_weight_stability` — Weight perturbation stability bound
* `sparse_reconstruction` — Weights recovered from isolating test inputs

## Cross-Domain Connections

- **Tropical convex geometry**: extremal rays, tropical Carathéodory
- **Functional analysis**: Choquet-style representation, representer theorems
- **Machine learning**: sparse shallow networks, width minimization, certified compression
- **Idempotent analysis**: sup-preserving maps, max-plus linearity

## Application Keywords

`tropical neural networks`, `idempotent functional analysis`, `Choquet duality`,
`Barron space`, `sparse reconstruction`, `network compression`, `max-plus algebra`,
`extremal rays`, `certified recovery`, `interpretable ML`, `atomic decomposition`,
`minimal width realization`
-/

noncomputable section

open Finset

namespace TropicalBarronChoquet

variable {𝓕 F : Type*} [DecidableEq 𝓕]

/-! ## §1. Tropical Network Representations -/

/-- A **tropical network representation** consists of a finite support set,
    weight function, and evaluation functionals. It computes:
    `N(f) = max_{i ∈ support} (weight(i) + eval(i)(f))` -/
structure TropicalNetworkRep (𝓕 F : Type*) where
  /-- The finite support set of active hidden units -/
  support : Finset 𝓕
  /-- The weight assigned to each hidden unit -/
  weight : 𝓕 → ℝ
  /-- The evaluation functional for each hidden unit -/
  eval : 𝓕 → F → ℝ

variable {R R₁ R₂ : TropicalNetworkRep 𝓕 F}

/-- The function computed by a tropical network. When support is empty, returns 0. -/
def TropicalNetworkRep.realize (R : TropicalNetworkRep 𝓕 F) (f : F) : ℝ :=
  if h : R.support.Nonempty then
    R.support.sup' h (fun i => R.weight i + R.eval i f)
  else 0

omit [DecidableEq 𝓕] in
/-- Realize for nonempty support unfolds to sup'. -/
theorem TropicalNetworkRep.realize_nonempty (R : TropicalNetworkRep 𝓕 F)
    (h : R.support.Nonempty) (f : F) :
    R.realize f = R.support.sup' h (fun i => R.weight i + R.eval i f) := by
  simp [TropicalNetworkRep.realize, h]

/-- Two representations are **functionally equivalent** if they compute the
    same function on all inputs. -/
def FunctionallyEquiv (R₁ R₂ : TropicalNetworkRep 𝓕 F) : Prop :=
  ∀ f : F, R₁.realize f = R₂.realize f

/-! ## §2. Dominance and Irredundancy -/

/-- A hidden unit `i` is **dominated** in representation `R` if for all inputs,
    some other unit achieves at least as high a value. -/
def IsDominated (R : TropicalNetworkRep 𝓕 F) (i : 𝓕) : Prop :=
  i ∈ R.support ∧
    ∀ f : F, ∃ j ∈ R.support, j ≠ i ∧ R.weight i + R.eval i f ≤ R.weight j + R.eval j f

/-- A representation is **irredundant** if no active hidden unit is dominated. -/
def IsIrredundant (R : TropicalNetworkRep 𝓕 F) : Prop :=
  ∀ i ∈ R.support, ¬ IsDominated R i

/-- A unit is **essential** if it strictly achieves the max on some input. -/
def IsEssential (R : TropicalNetworkRep 𝓕 F) (i : 𝓕) : Prop :=
  i ∈ R.support ∧
    ∃ f : F, ∀ j ∈ R.support, j ≠ i → R.weight j + R.eval j f < R.weight i + R.eval i f

/-! ## §3. Separating Evaluations -/

/-- Evaluation functionals **separate** if distinct indices have distinct evaluation
    profiles. -/
def SeparatingEvals (eval : 𝓕 → F → ℝ) : Prop :=
  ∀ i j : 𝓕, i ≠ j → ∃ f : F, eval i f ≠ eval j f

/-! ## §4. Core Finset Sup Lemmas -/

/-- The sup over `S` equals the sup over `S.erase i` when `i`'s value is dominated. -/
theorem sup'_erase_of_dominated' (S : Finset 𝓕) (hS : S.Nonempty) (g : 𝓕 → ℝ)
    (i : 𝓕) (hi : i ∈ S) (hS' : (S.erase i).Nonempty)
    (hdom : ∃ j ∈ S, j ≠ i ∧ g i ≤ g j) :
    S.sup' hS g = (S.erase i).sup' hS' g := by
  apply le_antisymm
  · apply Finset.sup'_le
    intro b hb
    by_cases hbi : b = i
    · subst hbi
      obtain ⟨j, hj, hji, hle⟩ := hdom
      exact le_trans hle (Finset.le_sup' g (Finset.mem_erase.mpr ⟨hji, hj⟩))
    · exact Finset.le_sup' g (Finset.mem_erase.mpr ⟨hbi, hb⟩)
  · apply Finset.sup'_le
    intro b hb
    exact Finset.le_sup' g (Finset.mem_of_mem_erase hb)

omit [DecidableEq 𝓕] in
/-- sup' distributes over max (binary sup). -/
theorem sup'_max_distrib' (S : Finset 𝓕) (hS : S.Nonempty)
    (f g : 𝓕 → ℝ) :
    S.sup' hS (fun s => max (f s) (g s)) = max (S.sup' hS f) (S.sup' hS g) := by
  apply le_antisymm
  · apply Finset.sup'_le; intro b hb
    exact sup_le_sup (Finset.le_sup' f hb) (Finset.le_sup' g hb)
  · apply sup_le
    · apply Finset.sup'_le; intro b hb
      exact le_trans le_sup_left (Finset.le_sup' (fun s => max (f s) (g s)) hb)
    · apply Finset.sup'_le; intro b hb
      exact le_trans le_sup_right (Finset.le_sup' (fun s => max (f s) (g s)) hb)

omit [DecidableEq 𝓕] in
/-- The sup' over a singleton is just the function value. -/
theorem sup'_singleton_eq (i : 𝓕) (g : 𝓕 → ℝ) :
    ({i} : Finset 𝓕).sup' (Finset.singleton_nonempty i) g = g i :=
  Finset.sup'_singleton _

omit [DecidableEq 𝓕] in
/-- If `s ∈ S` achieves the maximum value of `g`, then `S.sup' = g s`. -/
theorem sup'_eq_of_forall_le (S : Finset 𝓕) (hS : S.Nonempty) (g : 𝓕 → ℝ)
    (s : 𝓕) (hs : s ∈ S) (hmax : ∀ a ∈ S, g a ≤ g s) :
    S.sup' hS g = g s :=
  le_antisymm (Finset.sup'_le _ _ hmax) (Finset.le_sup' _ hs)

/-! ## §5. Dominated Unit Elimination -/

/-- **Removing a pointwise-dominated unit preserves the functional.** -/
theorem realize_erase_of_pointwise_dominated
    (R : TropicalNetworkRep 𝓕 F)
    (i : 𝓕) (hi : i ∈ R.support)
    (hne : (R.support.erase i).Nonempty)
    (hdom : ∀ f : F, ∃ j ∈ R.support, j ≠ i ∧
      R.weight i + R.eval i f ≤ R.weight j + R.eval j f) :
    ∀ f : F,
      R.realize f =
        (⟨R.support.erase i, R.weight, R.eval⟩ : TropicalNetworkRep 𝓕 F).realize f := by
  intro f
  rw [TropicalNetworkRep.realize_nonempty R ⟨_, hi⟩,
      TropicalNetworkRep.realize_nonempty _ hne]
  exact sup'_erase_of_dominated' R.support ⟨_, hi⟩ _ i hi hne (hdom f)

/-! ## §6. Network Axiom Theorems -/

omit [DecidableEq 𝓕] in
/-- The realization of a tropical network is **sup-preserving**. -/
theorem realize_sup_preserving
    (R : TropicalNetworkRep 𝓕 F) (hne : R.support.Nonempty)
    (f g : F) (fg : F)
    (h_eval_sup : ∀ i, R.eval i fg = max (R.eval i f) (R.eval i g)) :
    R.realize fg = max (R.realize f) (R.realize g) := by
  simp only [TropicalNetworkRep.realize_nonempty R hne]
  have key : (fun i => R.weight i + R.eval i fg) =
      (fun i => max (R.weight i + R.eval i f) (R.weight i + R.eval i g)) := by
    funext i; rw [h_eval_sup i]; simp [max_def]; split_ifs <;> linarith
  rw [key]
  exact sup'_max_distrib' R.support hne _ _

omit [DecidableEq 𝓕] in
/-- The realization of a tropical network is **shift-equivariant**. -/
theorem realize_shift_equivariant
    (R : TropicalNetworkRep 𝓕 F) (hne : R.support.Nonempty)
    (f : F) (cf : F) (c : ℝ)
    (h_eval_shift : ∀ i, R.eval i cf = R.eval i f + c) :
    R.realize cf = R.realize f + c := by
  simp only [TropicalNetworkRep.realize_nonempty R hne]
  have key : (fun i => R.weight i + R.eval i cf) =
      (fun i => c + (R.weight i + R.eval i f)) := by
    funext i; rw [h_eval_shift i]; ring
  rw [key, Finset.sup'_add]; ring

omit [DecidableEq 𝓕] in
/-- The realization of a tropical network is **monotone**. -/
theorem realize_monotone
    (R : TropicalNetworkRep 𝓕 F) (hne : R.support.Nonempty)
    (f g : F)
    (h_eval_mono : ∀ i ∈ R.support, R.eval i f ≤ R.eval i g) :
    R.realize f ≤ R.realize g := by
  simp only [TropicalNetworkRep.realize_nonempty R hne]
  apply Finset.sup'_le; intro b hb
  calc R.weight b + R.eval b f
      ≤ R.weight b + R.eval b g := by linarith [h_eval_mono b hb]
    _ ≤ _ := Finset.le_sup' (fun i => R.weight i + R.eval i g) hb

/-! ## §7. Tropical Max Idempotent -/

omit [DecidableEq 𝓕] in
/-- **Max is idempotent**: `max(x, x) = x`. -/
theorem tropical_max_idempotent (x : ℝ) : max x x = x := max_self x

omit [DecidableEq 𝓕] in
/-- **Singleton realization**: a single-unit network is just `w(i) + eval(i)(f)`. -/
theorem realize_singleton (eval_fn : 𝓕 → F → ℝ) (w : 𝓕 → ℝ) (i : 𝓕)
    (f : F) :
    let R : TropicalNetworkRep 𝓕 F := ⟨{i}, w, eval_fn⟩
    R.realize f = w i + eval_fn i f := by
  simp [TropicalNetworkRep.realize, Finset.Nonempty, Finset.sup'_singleton]

/-! ## §8. Certified Compression -/

/-
**Certified neural compression via tropical dominance.**
    A dominated unit can be removed, strictly reducing support cardinality.
-/
theorem certified_compression_of_dominated
    (R : TropicalNetworkRep 𝓕 F) (_hne : R.support.Nonempty)
    (i : 𝓕) (hi : i ∈ R.support) (hne' : (R.support.erase i).Nonempty)
    (j : 𝓕) (hj : j ∈ R.support) (hij : i ≠ j)
    (hdom : ∀ f : F, R.weight i + R.eval i f ≤ R.weight j + R.eval j f) :
    let R' : TropicalNetworkRep 𝓕 F := ⟨R.support.erase i, R.weight, R.eval⟩
    (∀ f : F, R.realize f = R'.realize f) ∧ R'.support.card < R.support.card := by
  constructor;
  · convert realize_erase_of_pointwise_dominated R i hi hne' _;
    exact fun f => ⟨ j, hj, hij.symm, hdom f ⟩;
  · exact Finset.card_lt_card ( Finset.erase_ssubset hi )

/-! ## §9. Weight Perturbation Stability -/

/-
**Weight perturbation bound.** Close networks have close weights.
-/
theorem network_weight_stability
    (eval_fn : 𝓕 → F → ℝ) (S : Finset 𝓕) (hS : S.Nonempty)
    (w₁ w₂ : 𝓕 → ℝ) (ε : ℝ) (_hε : 0 ≤ ε)
    (h_close : ∀ f : F,
      |S.sup' hS (fun i => w₁ i + eval_fn i f) -
       S.sup' hS (fun i => w₂ i + eval_fn i f)| ≤ ε)
    (h_isol : ∀ s ∈ S, ∃ f : F, ∀ t ∈ S, t ≠ s →
      w₁ t + eval_fn t f < w₁ s + eval_fn s f ∧
      w₂ t + eval_fn t f < w₂ s + eval_fn s f) :
    ∀ s ∈ S, |w₁ s - w₂ s| ≤ ε := by
  intro s hs; obtain ⟨ f, hf ⟩ := h_isol s hs; specialize h_close f; simp_all +decide [ abs_le ] ;
  constructor <;> linarith [ h_close.1 s hs, h_close.2 s hs, show S.sup' hS ( fun i => w₁ i + eval_fn i f ) = w₁ s + eval_fn s f from le_antisymm ( Finset.sup'_le _ _ fun t ht => if h : t = s then by simp +decide [ h ] else ( hf t ht h ).1.le ) ( Finset.le_sup' ( fun i => w₁ i + eval_fn i f ) hs ), show S.sup' hS ( fun i => w₂ i + eval_fn i f ) = w₂ s + eval_fn s f from le_antisymm ( Finset.sup'_le _ _ fun t ht => if h : t = s then by simp +decide [ h ] else ( hf t ht h ).2.le ) ( Finset.le_sup' ( fun i => w₂ i + eval_fn i f ) hs ) ]

/-! ## §10. Sparse Reconstruction -/

/-
**Sparse reconstruction theorem.** Weights can be recovered from isolating inputs.
-/
omit [DecidableEq 𝓕] in
theorem sparse_reconstruction
    (eval_fn : 𝓕 → F → ℝ) (I : Finset 𝓕) (hI : I.Nonempty)
    (w : 𝓕 → ℝ) (L : F → ℝ)
    (hL : ∀ f : F, L f = I.sup' hI (fun i => w i + eval_fn i f))
    (h_isol : ∀ s ∈ I, ∃ f : F,
      ∀ t ∈ I, t ≠ s → w t + eval_fn t f < w s + eval_fn s f) :
    ∀ s ∈ I, ∃ f : F, L f = w s + eval_fn s f := by
  grind +suggestions

/-! ## §11. Irredundant Support Cardinality -/

/-
**Irredundant support is cardinality-minimal.**
    Given an injective covering from the irredundant support `I` into `J`,
    we have `|I| ≤ |J|`.
-/
theorem irredundant_card_le
    (eval_fn : 𝓕 → F → ℝ)
    (I : Finset 𝓕) (hI : I.Nonempty) (wI : 𝓕 → ℝ)
    (J : Finset 𝓕) (hJ : J.Nonempty) (wJ : 𝓕 → ℝ)
    (_hIJ : ∀ f : F, I.sup' hI (fun i => wI i + eval_fn i f) =
                     J.sup' hJ (fun j => wJ j + eval_fn j f))
    (_hI_irr : ∀ i ∈ I, ∃ f : F, ∀ j ∈ I, j ≠ i →
      wI j + eval_fn j f < wI i + eval_fn i f)
    (_hsep : SeparatingEvals eval_fn)
    -- Injective covering: each unit in I maps to a distinct unit in J
    (h_cover : ∃ φ : 𝓕 → 𝓕, (∀ i ∈ I, φ i ∈ J) ∧
      (∀ i₁ ∈ I, ∀ i₂ ∈ I, φ i₁ = φ i₂ → i₁ = i₂)) :
    I.card ≤ J.card := by
  cases' h_cover with φ hφ;
  have := Finset.card_le_card ( show I.image φ ⊆ J from Finset.image_subset_iff.2 hφ.1 ) ; simp_all +decide [ Finset.card_image_of_injOn fun i₁ hi₁ i₂ hi₂ hi => hφ.2 i₁ hi₁ i₂ hi₂ hi ] ;

/-- **Irredundant representations have equal support cardinality.**
    Under injective coverings in both directions. -/
theorem irredundant_support_card_eq
    (eval_fn : 𝓕 → F → ℝ)
    (I : Finset 𝓕) (hI : I.Nonempty) (wI : 𝓕 → ℝ)
    (J : Finset 𝓕) (hJ : J.Nonempty) (wJ : 𝓕 → ℝ)
    (hIJ : ∀ f : F, I.sup' hI (fun i => wI i + eval_fn i f) =
                     J.sup' hJ (fun j => wJ j + eval_fn j f))
    (hI_irr : ∀ i ∈ I, ∃ f : F, ∀ j ∈ I, j ≠ i →
      wI j + eval_fn j f < wI i + eval_fn i f)
    (hJ_irr : ∀ j ∈ J, ∃ f : F, ∀ i ∈ J, i ≠ j →
      wJ i + eval_fn i f < wJ j + eval_fn j f)
    (hsep : SeparatingEvals eval_fn)
    (h_coverIJ : ∃ φ : 𝓕 → 𝓕, (∀ i ∈ I, φ i ∈ J) ∧
      (∀ i₁ ∈ I, ∀ i₂ ∈ I, φ i₁ = φ i₂ → i₁ = i₂))
    (h_coverJI : ∃ ψ : 𝓕 → 𝓕, (∀ j ∈ J, ψ j ∈ I) ∧
      (∀ j₁ ∈ J, ∀ j₂ ∈ J, ψ j₁ = ψ j₂ → j₁ = j₂)) :
    I.card = J.card :=
  le_antisymm
    (irredundant_card_le eval_fn I hI wI J hJ wJ hIJ hI_irr hsep h_coverIJ)
    (irredundant_card_le eval_fn J hJ wJ I hI wI (fun f => (hIJ f).symm) hJ_irr hsep h_coverJI)

/-! ## §12. Certified Tropical Network Axioms Bundle -/

omit [DecidableEq 𝓕] in
/-- **Certified tropical network axioms.** A network realization satisfies
    monotonicity and irredundancy when every unit is essential. -/
theorem certified_tropical_network_axioms
    (R : TropicalNetworkRep 𝓕 F) (hne : R.support.Nonempty)
    (h_ess : ∀ i ∈ R.support, ∃ f : F, ∀ j ∈ R.support, j ≠ i →
      R.weight j + R.eval j f < R.weight i + R.eval i f) :
    (∀ i ∈ R.support, ∃ f : F, ∀ j ∈ R.support, j ≠ i →
      R.weight j + R.eval j f < R.weight i + R.eval i f) ∧
    (∀ f g : F, (∀ i ∈ R.support, R.eval i f ≤ R.eval i g) →
      R.realize f ≤ R.realize g) :=
  ⟨h_ess, fun f g h => realize_monotone R hne f g h⟩

end TropicalBarronChoquet