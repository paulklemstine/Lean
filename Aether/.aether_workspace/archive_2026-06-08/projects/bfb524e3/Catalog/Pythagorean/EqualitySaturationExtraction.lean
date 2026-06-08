import Mathlib

/-!
# Equality Saturation Extraction Correctness

## Overview

This file establishes that **equality saturation extraction is a certified optimization
procedure**, not merely a heuristic search over rewrites. We formalize the bridge between
term rewriting (confluence, normalization, equivalence generation), quotient semantics
(semantic invariance on `EqvGen`), and optimization theory (extraction as argmin over
an equivalence class).

## Mathematical Contribution

The key insight is: an e-graph whose `sameClass` relation is sound and complete for
`EqvGen R.rel` on a saturated domain supports extraction of representatives that are
semantically equivalent to any other class member. Combined with a cost model, this
yields a certified optimizer: the cheapest representative preserves semantics while
minimizing cost.

## Main Definitions

- `RewriteSystem`: a type with an oriented rewrite relation.
- `Convergent`: a rewrite system that is confluent and normalizing.
- `SaturatedEGraphExtractor`: an e-graph with sound/complete class relation and extraction.
- `CostModel`, `IsCheapestInClass`: cost-based optimization structures.

## Main Theorems

- `extraction_semantics_preserved`: extraction preserves denotation.
- `extraction_eq_any_representative`: any two class members have the same extracted semantics.
- `cheapest_extraction_sound_and_optimal`: cheapest extraction is sound and cost-optimal.
- `extraction_agrees_with_quotient_nf_semantically`: extraction agrees with normal-form
  computation semantically.
- `extraction_induces_resource_abstraction`: cross-domain bridge to optimization theory.
- `bounded_extractor_sound_of_complete`: algorithmic/verified extraction theorem.

## Lineage

Builds on `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean`:
- `nf_constant_on_eqvGen`
- `quotientNf_mk`
- `eval_eq_of_nf_eq`
-/

open Relation

/-! ## Section 1: Core Definitions -/

/-- A rewrite system consists of a type of terms and an oriented rewrite relation. -/
structure RewriteSystem' (α : Type u) where
  /-- The single-step rewrite relation. -/
  rel : α → α → Prop

/-- A term is in normal form if no rule applies. -/
def RewriteSystem'.IsNF {α : Type u} (R : RewriteSystem' α) (t : α) : Prop :=
  ∀ u, ¬R.rel t u

/-- A rewrite system is confluent. -/
def RewriteSystem'.IsConfluent {α : Type u} (R : RewriteSystem' α) : Prop :=
  ∀ ⦃t u₁ u₂ : α⦄,
    ReflTransGen R.rel t u₁ → ReflTransGen R.rel t u₂ →
    ∃ v, ReflTransGen R.rel u₁ v ∧ ReflTransGen R.rel u₂ v

/-- A convergent rewrite system is both confluent and normalizing, and comes equipped
with a computable normal-form function. -/
structure Convergent' {α : Type u} (R : RewriteSystem' α) where
  /-- The normal-form function. -/
  nf : α → α
  /-- Normal forms are in normal form. -/
  nf_normal : ∀ t, R.IsNF (nf t)
  /-- Every term reduces to its normal form. -/
  nf_reduces : ∀ t, ReflTransGen R.rel t (nf t)
  /-- Confluence of the system. -/
  confluent : R.IsConfluent

/-! ## Section 2: Saturated E-Graph Extractor -/

/-- A **saturated e-graph extractor** for a rewrite system `R` on terms of type `α`.

This models a finite e-graph whose `sameClass` relation captures equivalence between
terms. The relation is *sound* (merging only genuinely equivalent terms) and *complete*
on a saturated domain (capturing all equivalences derivable from `R`).

The `extract` function selects a representative from each equivalence class. -/
structure SaturatedEGraphExtractor
    (α : Type u)
    (R : RewriteSystem' α) where
  /-- The domain on which saturation is complete. -/
  complete_on : Set α
  /-- The e-class equivalence relation (may be coarser outside `complete_on`). -/
  sameClass : α → α → Prop
  /-- Soundness: if two terms are in the same e-class, they are equivalent
      under `EqvGen R.rel`. -/
  sound_sameClass : ∀ {a b}, sameClass a b → EqvGen R.rel a b
  /-- Completeness on the saturated domain: equivalent terms within `complete_on`
      are recognized as being in the same class. -/
  complete_sameClass : ∀ {a b}, a ∈ complete_on → b ∈ complete_on →
    EqvGen R.rel a b → sameClass a b
  /-- The extraction function choosing a representative for each term. -/
  extract : α → α
  /-- The extracted representative is in the same e-class as the original term
      (for terms in the saturated domain). -/
  extract_mem_class : ∀ {a}, a ∈ complete_on → sameClass a (extract a)

/-- A cost model assigns a natural number cost to each term. -/
structure CostModel' (α : Type u) where
  /-- The cost function. -/
  cost : α → Nat

/-- A term `x` is the cheapest in a class `C` if it belongs to `C` and has minimal cost. -/
def IsCheapestInClass'
    {α : Type u} (c : CostModel' α) (C : Set α) (x : α) : Prop :=
  x ∈ C ∧ ∀ y ∈ C, c.cost x ≤ c.cost y

/-! ## Section 3: Key Lemma — Extraction Yields Equivalent Terms -/

/-- The extracted representative is equivalent to the original term
under `EqvGen R.rel`. -/
theorem extract_eqvGen {α : Type u}
    {R : RewriteSystem' α}
    (E : SaturatedEGraphExtractor α R)
    {t : α} (ht : t ∈ E.complete_on) :
    EqvGen R.rel t (E.extract t) :=
  E.sound_sameClass (E.extract_mem_class ht)

/-! ## Section 4: Extraction Soundness (Theorem 1) -/

/-
**Extraction soundness from saturation completeness.**

Let `R` be a rewrite system, `M` a semantic interpretation respecting `EqvGen R.rel`,
and `E` a saturated e-graph extractor. Then for every term `t` in the saturated domain,
extraction preserves denotation: `M (E.extract t) = M t`.

This is the central theorem: it says the extractor need not compute the normal form;
it only needs to pick a representative of the correct quotient class.
-/
theorem extraction_semantics_preserved
    {α : Type u}
    {β : Type v}
    (R : RewriteSystem' α)
    (M : α → β)
    (hM : ∀ {a b}, EqvGen R.rel a b → M a = M b)
    (E : SaturatedEGraphExtractor α R)
    {t : α}
    (ht : t ∈ E.complete_on) :
    M (E.extract t) = M t := by
  rw [ hM <| E.sound_sameClass <| E.extract_mem_class ht ]

/-
**Stronger symmetric form:** any two same-class terms in the saturated domain
have the same extracted semantics.
-/
theorem extraction_eq_any_representative
    {α : Type u}
    {β : Type v}
    (R : RewriteSystem' α)
    (M : α → β)
    (hM : ∀ {a b}, EqvGen R.rel a b → M a = M b)
    (E : SaturatedEGraphExtractor α R)
    {t u : α}
    (ht : t ∈ E.complete_on)
    (_hu : u ∈ E.complete_on)
    (hclass : E.sameClass t u) :
    M (E.extract t) = M u := by
  apply hM;
  exact EqvGen.trans _ _ _ ( EqvGen.symm _ _ ( extract_eqvGen E ht ) ) ( E.sound_sameClass hclass )

/-! ## Section 5: Cheapest Extraction (Theorem 2) -/

/-
**Cheapest extraction is sound and cost-optimal.**

If the extractor returns the cheapest representative in the e-class of `t`, then
extraction is both semantically sound and cost-optimal within the equivalence class.
-/
theorem cheapest_extraction_sound_and_optimal
    {α : Type u}
    {β : Type v}
    (R : RewriteSystem' α)
    (c : CostModel' α)
    (M : α → β)
    (hM : ∀ {a b}, EqvGen R.rel a b → M a = M b)
    (E : SaturatedEGraphExtractor α R)
    (hcheap :
      ∀ {t}, t ∈ E.complete_on →
        IsCheapestInClass' c {x | E.sameClass t x ∧ x ∈ E.complete_on} (E.extract t))
    {t u : α}
    (ht : t ∈ E.complete_on)
    (hu : u ∈ E.complete_on)
    (heq : EqvGen R.rel t u) :
    M (E.extract t) = M t ∧ c.cost (E.extract t) ≤ c.cost u := by
  exact ⟨ extraction_semantics_preserved R M hM E ht, hcheap ht |>.2 u ⟨ E.complete_sameClass ht hu heq, hu ⟩ ⟩

/-! ## Section 6: Normal Forms are Constant on EqvGen Classes -/

/-
A normal form cannot reduce further.
-/
private theorem nf_irred {α : Type u}
    {R : RewriteSystem' α}
    (_hconv : Convergent' R)
    {u v : α} (hu : R.IsNF u) (huv : ReflTransGen R.rel u v) : u = v := by
  induction huv;
  · rfl;
  · exact False.elim ( hu _ ( by subst_vars; assumption ) )

/-
Normal forms are constant on `EqvGen R.rel` classes for convergent systems.
-/
theorem nf_constant_on_eqvGen' {α : Type u}
    {R : RewriteSystem' α}
    (hconv : Convergent' R) :
    ∀ {s t : α}, EqvGen R.rel s t → hconv.nf s = hconv.nf t := by
  intro s t h;
  induction h;
  · rename_i x y hxy;
    -- By confluence of x →* nf x and x →* nf y, get common reduct v.
    obtain ⟨v, hvx, hvy⟩ : ∃ v, ReflTransGen R.rel (hconv.nf x) v ∧ ReflTransGen R.rel (hconv.nf y) v := by
      have := hconv.confluent ( hconv.nf_reduces x ) ( ReflTransGen.trans ( ReflTransGen.single hxy ) ( hconv.nf_reduces y ) );
      exact this;
    have := nf_irred hconv ( hconv.nf_normal x ) hvx; have := nf_irred hconv ( hconv.nf_normal y ) hvy; aesop;
  · rfl;
  · grind +revert;
  · grind

/-
`ReflTransGen R.rel` implies `EqvGen R.rel`.
-/
theorem reflTransGen_to_eqvGen {α : Type u}
    {R : α → α → Prop} {a b : α}
    (h : ReflTransGen R a b) : EqvGen R a b := by
  have h_refl_trans_to_equiv : ∀ (a b : α), ReflTransGen R a b → EqvGen R a b := by
    intro a b h;
    induction h;
    · exact EqvGen.refl a;
    · exact EqvGen.trans _ _ _ ‹_› ( EqvGen.rel _ _ ‹_› );
  exact h_refl_trans_to_equiv a b h

/-! ## Section 7: Agreement with Quotient Normal Form (Theorem 3) -/

/-
**Extraction agrees with quotient normal form semantically.**

For a convergent rewrite system, if the e-graph is complete for `EqvGen`, then the
extracted representative is semantically equal to the canonical normal-form representative.
Hence extraction factors through the same quotient map as `nf`.

This theorem is strategically vital because it identifies equality saturation as
**quotient normalization without canonicality**: the extractor need not find the
*canonical* representative, only a *correct* one.
-/
theorem extraction_agrees_with_quotient_nf_semantically
    {α : Type u}
    {β : Type v}
    (R : RewriteSystem' α)
    (hconv : Convergent' R)
    (M : α → β)
    (hM : ∀ {a b}, EqvGen R.rel a b → M a = M b)
    (E : SaturatedEGraphExtractor α R)
    {t : α}
    (ht : t ∈ E.complete_on) :
    M (E.extract t) = M (hconv.nf t) := by
  apply hM;
  convert EqvGen.trans _ _ _ ( EqvGen.symm _ _ <| extract_eqvGen E ht ) ( reflTransGen_to_eqvGen <| hconv.nf_reduces t ) using 1

/-! ## Section 8: Cross-Domain Bridge — Optimization as Resource Abstraction -/

/-
**Extraction induces a resource abstraction.**

For any saturated e-graph with a cost model, extraction finds a cheapest representative
in each e-class. This interprets equality saturation as computing a semantics-preserving
resource abstraction: circuit size, proof length, energy, etc.

**Cross-domain connections:**
- **Compiler optimization**: cheapest equivalent program
- **SMT / theorem proving**: smallest proof witness in an equivalence class
- **Statistical physics**: minimum-energy state within a symmetry orbit
- **Category theory**: choosing a section of a quotient functor subject to a monoidal cost
-/
theorem extraction_induces_resource_abstraction
    {α : Type u}
    (R : RewriteSystem' α)
    (c : CostModel' α)
    (E : SaturatedEGraphExtractor α R)
    (hcheap :
      ∀ {t}, t ∈ E.complete_on →
        IsCheapestInClass' c {y | E.sameClass t y ∧ y ∈ E.complete_on} (E.extract t)) :
    ∀ {t}, t ∈ E.complete_on →
      ∃ x, E.sameClass t x ∧
        IsCheapestInClass' c {y | E.sameClass t y ∧ y ∈ E.complete_on} x := by
  exact fun { t } ht => ⟨ _, E.extract_mem_class ht, hcheap ht ⟩

/-! ## Section 9: Verified Bounded Extraction Algorithm -/

/-- A bounded e-graph is an e-graph extractor restricted to a finite carrier set,
with an explicit list of elements. This models the algorithmic setting where saturation
runs on a finite universe of terms. -/
structure BoundedEGraph (α : Type u) (R : RewriteSystem' α) where
  /-- The underlying saturated extractor. -/
  extractor : SaturatedEGraphExtractor α R
  /-- The finite carrier elements (as a list). -/
  elements : List α
  /-- All elements are in the saturated domain. -/
  elements_in_domain : ∀ t ∈ elements, t ∈ extractor.complete_on

/-- **Bounded extractor soundness.**

If a bounded e-graph has been saturated (completeness holds on its carrier),
then running the extractor on any element produces a semantically equivalent term. -/
theorem bounded_extractor_sound_of_complete
    {α : Type u}
    {β : Type v}
    (R : RewriteSystem' α)
    (M : α → β)
    (hM : ∀ {a b}, EqvGen R.rel a b → M a = M b)
    (B : BoundedEGraph α R)
    {t : α}
    (ht : t ∈ B.elements) :
    M (B.extractor.extract t) = M t :=
  extraction_semantics_preserved R M hM B.extractor (B.elements_in_domain t ht)

/-- Running the bounded extractor on any element produces a term equivalent to the
normal form, when the rewrite system is convergent. -/
theorem bounded_extractor_agrees_with_nf
    {α : Type u}
    {β : Type v}
    (R : RewriteSystem' α)
    (hconv : Convergent' R)
    (M : α → β)
    (hM : ∀ {a b}, EqvGen R.rel a b → M a = M b)
    (B : BoundedEGraph α R)
    {t : α}
    (ht : t ∈ B.elements) :
    M (B.extractor.extract t) = M (hconv.nf t) :=
  extraction_agrees_with_quotient_nf_semantically R hconv M hM B.extractor
    (B.elements_in_domain t ht)

/-! ## Section 10: Quotient Semantic Extraction -/

/-- The semantic evaluation `M ∘ extract` is well-defined on the quotient when
the extractor is complete on the full universe. -/
noncomputable def quotientSemanticExtract {α : Type u} {β : Type v}
    {R : RewriteSystem' α}
    (E : SaturatedEGraphExtractor α R)
    (M : α → β)
    (hM : ∀ {a b}, EqvGen R.rel a b → M a = M b)
    (hfull : E.complete_on = Set.univ) :
    Quot (EqvGen R.rel) → β :=
  Quot.lift (M ∘ E.extract) (by
    intro a b hab
    simp only [Function.comp]
    have ha : a ∈ E.complete_on := hfull ▸ Set.mem_univ a
    have hb : b ∈ E.complete_on := hfull ▸ Set.mem_univ b
    have h1 : M (E.extract a) = M a :=
      extraction_semantics_preserved ⟨R.rel⟩ M hM E ha
    have h2 : M (E.extract b) = M b :=
      extraction_semantics_preserved ⟨R.rel⟩ M hM E hb
    rw [h1, h2]
    exact hM hab)

/-- The quotient semantic extraction agrees with direct evaluation on representatives. -/
theorem quotientSemanticExtract_mk {α : Type u} {β : Type v}
    {R : RewriteSystem' α}
    (E : SaturatedEGraphExtractor α R)
    (M : α → β)
    (hM : ∀ {a b}, EqvGen R.rel a b → M a = M b)
    (hfull : E.complete_on = Set.univ)
    (t : α) :
    quotientSemanticExtract E M hM hfull (Quot.mk _ t) = M (E.extract t) := by
  rfl

/-! ## Section 11: Extraction Preserves Semantic Equivalence Class Structure -/

/-
If two terms are in the same e-class and both in the saturated domain,
their extractions have the same semantics.
-/
theorem sameClass_implies_extract_semantics_eq
    {α : Type u} {β : Type v}
    (R : RewriteSystem' α)
    (M : α → β)
    (hM : ∀ {a b}, EqvGen R.rel a b → M a = M b)
    (E : SaturatedEGraphExtractor α R)
    {t u : α}
    (ht : t ∈ E.complete_on)
    (hu : u ∈ E.complete_on)
    (hclass : E.sameClass t u) :
    M (E.extract t) = M (E.extract u) := by
  obtain ⟨w, hw⟩ : ∃ w, EqvGen R.rel t w ∧ EqvGen R.rel u w := by
    exact ⟨ u, E.sound_sameClass hclass, EqvGen.refl u ⟩;
  rw [ ← hM ( extract_eqvGen E ht ), ← hM ( extract_eqvGen E hu ), hM hw.1, hM hw.2 ]

/-- Extraction is idempotent semantically: extracting twice gives the same semantics
as extracting once. -/
theorem extract_semantics_idempotent
    {α : Type u} {β : Type v}
    (R : RewriteSystem' α)
    (M : α → β)
    (hM : ∀ {a b}, EqvGen R.rel a b → M a = M b)
    (E : SaturatedEGraphExtractor α R)
    (hextract_in : ∀ {a}, a ∈ E.complete_on → E.extract a ∈ E.complete_on)
    {t : α}
    (ht : t ∈ E.complete_on) :
    M (E.extract (E.extract t)) = M (E.extract t) :=
  extraction_semantics_preserved R M hM E (hextract_in ht)

/-!
## Conjecture: Bounded Completeness Threshold for Finite Convergent Systems

**Conjecture.** For every finite convergent rewrite system `R` over a finite signature
and every finite seed set `S`, there exists a saturation bound `B(R,S) : ℕ` such that
bounded equality saturation to depth `B(R,S)` computes exactly the `EqvGen R.rel` classes
reachable from `S`.

**Stronger testable formulation.** For finite convergent systems with maximal rule size `k`,
the required saturation depth grows at most polynomially in the size of the reachable
normal-form closure.

**Computational test:**
- Generate 100 random finite convergent systems over a finite carrier.
- For each, choose 1000 random seed terms.
- Compute: (1) equivalence by normal form, (2) equivalence by bounded saturation at
  increasing depth.
- Search for the smallest depth where the two relations agree.
- Fit growth against reachable closure size; any super-polynomial family would falsify the
  stronger conjecture.

This is falsifiable: a single family with provably insufficient bounded saturation refutes
the polynomial-growth claim.
-/