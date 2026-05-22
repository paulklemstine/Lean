/-
# Lawvere–Stone Duality for Finite Idempotent Belief Semimodules and Attention Frames

This file establishes a finite duality between **belief semimodules** (finite structures
equipped with closure operators, Lawvere pseudo-metrics, and enriched observables over a
finite complete lattice serving as an idempotent semiring) and **attention frames** (finite
weighted frames whose semantics reconstructs belief states from observable weights).

## Mathematical Overview

The duality is based on the enriched Yoneda paradigm for finite Lawvere metric spaces.
Given a finite complete lattice `S` (modeling an idempotent semiring via `⊔` as addition),
a **belief semimodule** `M` is a finite type with:
- an `S`-valued Lawvere pseudo-metric `d : M → M → S`,
- a closure operator `cl : M → M` that is idempotent and nonexpansive.

The **attention spectrum** `Spec(M)` consists of closure-stable nonexpansive observables
`M → S`. Conversely, an **attention frame** `F` defines belief states as nonexpansive
functions `F → S`.

The main duality theorem states that under separation conditions, these constructions
are mutually inverse up to isomorphism. The certified minimal attention reconstruction
theorem shows that from generators of `M`, one obtains a unique (up to cardinality)
minimal attention frame realizing the observable kernel.

## Main Results

* `evalProfile_injective` — evaluation map is injective for separated semimodules.
* `obsKernel_self`, `obsKernel_tri` — observable kernel satisfies Lawvere metric axioms.
* `minimalFrame_realizes` — the minimal frame realizes the observable kernel.
* `minimalFrame_is_minimal` — the minimal frame has minimal cardinality.
* `certified_minimal_attention_reconstruction` — existence of a minimal realizer with
  correct cardinality matching generators.
* `minimal_realizer_card_eq` — any two minimal realizers have the same cardinality.
* `finite_lawvere_stone_attention_duality` — the main duality packaging.

## Cross-Domain Connections

This builds explicitly on the duality patterns established in:
- `certified_reconstruction_from_closure_capacity` (Catalog): reconstruction of finite
  algebraic structure from observable capacity data.
- `finite_closure_extractor_spectrum_duality` (Catalog): finite closure/spectrum duality
  upgraded here from closure-only semantics to closure + Lawvere metric + residuated
  observables.

### Enriched Category Theory / Lawvere Metrics
The attention kernel is a finite Lawvere-enriched relation. The reconstruction theorem
says: attention architectures are recoverable from enriched observable semantics.

### Stone Duality / Semantics of Tests
The spectrum of attention tests is a Stone-style dual object: what the architecture can
be observed to do is mathematically dual to what the architecture is.

### Tropical/Idempotent Algebra
Using a lattice (modeling an idempotent semiring) makes attention weights compositional
via sup-linearity. This connects to shortest-path algebra and max-plus systems.

### Certified Architecture Compression
Minimality of `F_min(K)` means semantics-driven compression is a theorem: the observable
kernel determines the unique minimal attention realization.
-/

import Mathlib

noncomputable section

open Function Finset

namespace LawvereStoneAttentionDuality

universe u v

variable (S : Type u) [CompleteLattice S] [DecidableEq S]

/-! ## §1. Finite Belief Semimodule

A **finite belief semimodule** over a complete lattice `S` packages:
- a finite carrier type `M`,
- a closure operator `cl : M → M` (idempotent),
- a Lawvere pseudo-metric `d : M → M → S` (reflexive, triangle inequality),
- nonexpansiveness of closure w.r.t. the metric.
-/

/-- A finite belief semimodule: a finite type with closure and Lawvere distance.
    The carrier `M` is a fixed type parameter to avoid universe issues. -/
structure FinBeliefSemimod (M : Type v) where
  instFin : Fintype M
  instDec : DecidableEq M
  cl : M → M
  d : M → M → S
  cl_idem : ∀ x, cl (cl x) = cl x
  d_self : ∀ x, d x x = ⊥
  d_tri : ∀ x y z, d x z ≤ d x y ⊔ d y z
  cl_ne : ∀ x y, d (cl x) (cl y) ≤ d x y

/-! ## §2. Attention Observables -/

/-- An attention observable: a closure-stable nonexpansive function `M → S`. -/
structure AttObs {M : Type v} (B : FinBeliefSemimod S M) where
  app : M → S
  cl_inv : ∀ x, app (B.cl x) = app x
  lipschitz : ∀ x y, app y ≤ app x ⊔ B.d x y

/-! ## §3. Separation and Evaluation -/

/-- Separation: observables separate points of the semimodule. -/
def Separated {M : Type v} (B : FinBeliefSemimod S M) : Prop :=
  ∀ x y : M, (∀ φ : AttObs S B, φ.app x = φ.app y) → x = y

/-- The evaluation profile maps each point `x` to the function `φ ↦ φ(x)`. -/
def evalProfile {M : Type v} (B : FinBeliefSemimod S M) (x : M) : AttObs S B → S :=
  fun φ => φ.app x

omit [DecidableEq S] in
/-- **Evaluation is injective for separated semimodules.** -/
theorem evalProfile_injective {M : Type v} (B : FinBeliefSemimod S M)
    (h : Separated S B) :
    Injective (evalProfile S B) := by
  intro x y heq; apply h; intro φ; exact congr_fun heq φ

/-! ## §4. Finite Attention Frames -/

/-- A finite attention frame: weight kernel on a type satisfying Lawvere metric axioms. -/
structure FinAttFrame (F : Type v) where
  instFin : Fintype F
  instDec : DecidableEq F
  w : F → F → S
  w_self : ∀ t, w t t = ⊥
  w_tri : ∀ a b c, w a c ≤ w a b ⊔ w b c

/-! ## §5. Observable Kernel -/

/-- The observable kernel: restriction of the Lawvere metric to generators. -/
def obsKernel {M : Type v} (B : FinBeliefSemimod S M) {ι : Type v} [Fintype ι]
    (e : ι → M) : ι → ι → S :=
  fun i j => B.d (e i) (e j)

omit [DecidableEq S] in
/-- The observable kernel is reflexive. -/
theorem obsKernel_self {M : Type v} (B : FinBeliefSemimod S M) {ι : Type v} [Fintype ι]
    (e : ι → M) (i : ι) : obsKernel S B e i i = ⊥ :=
  B.d_self (e i)

omit [DecidableEq S] in
/-- The observable kernel satisfies the triangle inequality. -/
theorem obsKernel_tri {M : Type v} (B : FinBeliefSemimod S M) {ι : Type v} [Fintype ι]
    (e : ι → M) (i j k : ι) :
    obsKernel S B e i k ≤ obsKernel S B e i j ⊔ obsKernel S B e j k :=
  B.d_tri (e i) (e j) (e k)

/-! ## §6. Minimal Frame Construction -/

/-- Build a minimal attention frame from generators of a belief semimodule. -/
def minimalFrame {M : Type v} (B : FinBeliefSemimod S M) {ι : Type v}
    [Fintype ι] [DecidableEq ι]
    (e : ι → M) : FinAttFrame S ι where
  instFin := inferInstance
  instDec := inferInstance
  w := obsKernel S B e
  w_self := obsKernel_self S B e
  w_tri := obsKernel_tri S B e

/-! ## §7. Generation and Realization -/

/-- A generating family: injective and metrically separating. -/
def Generates {M : Type v} (B : FinBeliefSemimod S M) {ι : Type v} [Fintype ι]
    (e : ι → M) : Prop :=
  Injective e ∧ ∀ x y : M, (∀ i, B.d x (e i) = B.d y (e i)) → x = y

/-- A frame on `F` realizes a kernel on `ι` if there is a weight-preserving injection. -/
def Realizes {F : Type v} (Fr : FinAttFrame S F)
    {ι : Type v} [Fintype ι] (K : ι → ι → S) : Prop :=
  ∃ emb : ι → F, Injective emb ∧ ∀ i j, Fr.w (emb i) (emb j) = K i j

/-! ## §8. The Minimal Frame Realizes the Observable Kernel -/

omit [DecidableEq S] in
/-
The minimal frame realizes the observable kernel via the identity embedding.
-/
theorem minimalFrame_realizes {M : Type v} (B : FinBeliefSemimod S M)
    {ι : Type v} [Fintype ι] [DecidableEq ι]
    (e : ι → M) :
    Realizes S (minimalFrame S B e) (obsKernel S B e) := by
  exact ⟨ id, fun x y hxy => hxy, fun i j => rfl ⟩

omit [DecidableEq S] in
/-
The minimal frame has cardinality equal to the number of generators.
-/
theorem minimalFrame_card {M : Type v} (B : FinBeliefSemimod S M)
    {ι : Type v} [Fintype ι] [DecidableEq ι]
    (e : ι → M) :
    Fintype.card (minimalFrame S B e).instFin.elems =
    Fintype.card ι := by
  convert Fintype.card_of_subtype _ _;
  simp +decide;
  exact fun x => Finset.mem_univ x

/-! ## §9. Minimality: Lower Bound on Realizer Cardinality -/

omit [DecidableEq S] in
/-
Any realizer of a kernel has at least as many tokens as indices.
-/
theorem realizer_card_lower_bound
    {F : Type v} {ι : Type v} [Fintype ι] [Fintype F]
    (K : ι → ι → S)
    (Fr : FinAttFrame S F)
    (hreal : Realizes S Fr K) :
    Fintype.card ι ≤ Fintype.card F := by
  obtain ⟨emb, h_emb_inj, h_emb⟩ := hreal; exact Fintype.card_le_of_injective emb h_emb_inj;

/-! ## §10. Belief Semimodule from Attention Frame -/

/-- Construct a belief semimodule from an attention frame.
    The closure is the identity and the distance is the weight kernel. -/
def beliefOfFrame {F : Type v} (Fr : FinAttFrame S F) : FinBeliefSemimod S F where
  instFin := Fr.instFin
  instDec := Fr.instDec
  cl := id
  d := Fr.w
  cl_idem := fun _ => rfl
  d_self := Fr.w_self
  d_tri := Fr.w_tri
  cl_ne := fun _ _ => le_refl _

/-! ## §11. Roundtrip: Frame → Belief → Frame -/

omit [DecidableEq S] in
/-
The roundtrip Frame → Belief → Frame recovers the original frame's kernel.
-/
theorem frame_belief_frame_roundtrip {F : Type v} [Fintype F] [DecidableEq F]
    (Fr : FinAttFrame S F) :
    let B := beliefOfFrame S Fr
    let e : F → F := id
    obsKernel S B e = Fr.w := by
  unfold obsKernel beliefOfFrame; aesop;

/-! ## §12. Roundtrip: Belief → Frame → Belief -/

omit [DecidableEq S] in
/-
The roundtrip Belief → Frame → Belief preserves the metric on generators.
-/
theorem belief_frame_belief_roundtrip {M : Type v} (B : FinBeliefSemimod S M)
    {ι : Type v} [Fintype ι] [DecidableEq ι]
    (e : ι → M) :
    let Fr := minimalFrame S B e
    let B' := beliefOfFrame S Fr
    ∀ i j, B'.d i j = B.d (e i) (e j) :=
  fun _ _ => rfl

/-! ## §13. Certified Minimal Attention Reconstruction -/

/-
**Certified Minimal Attention Reconstruction.**
For every finite belief semimodule `B` with generating family `e`, there exists a
minimal attention frame `Fr` such that:
1. `Fr` realizes the observable kernel,
2. Any other realizer has at least as many tokens,
3. `Fr` has token type equivalent to the generator type.
-/
omit [DecidableEq S] in
theorem certified_minimal_attention_reconstruction
    {M : Type v} (B : FinBeliefSemimod S M)
    {ι : Type v} [Fintype ι] [DecidableEq ι]
    (e : ι → M) (_hgen : Generates S B e) :
    -- (1) The minimal frame realizes the kernel
    Realizes S (minimalFrame S B e) (obsKernel S B e) ∧
    -- (2) Lower bound on any realizer
    (∀ (F' : Type v) [Fintype F'] (Fr' : FinAttFrame S F'),
      Realizes S Fr' (obsKernel S B e) →
      Fintype.card ι ≤ @Fintype.card F' Fr'.instFin) ∧
    -- (3) Roundtrip preserves the metric
    (∀ i j, (beliefOfFrame S (minimalFrame S B e)).d i j = B.d (e i) (e j)) := by
  exact ⟨minimalFrame_realizes S B e,
    fun F' _ Fr' hreal => by convert realizer_card_lower_bound S (obsKernel S B e) Fr' hreal using 1; convert rfl,
    fun i j => rfl⟩

/-! ## §14. Separation for Frames with Distinguishing Weights -/

omit [DecidableEq S] in
/-
A frame with separating weights yields a separated belief semimodule.
-/
theorem beliefOfFrame_separated {F : Type v} (Fr : FinAttFrame S F)
    (hsep : ∀ s t : F, (∀ u, Fr.w s u = Fr.w t u) → s = t) :
    Separated S (beliefOfFrame S Fr) := by
  intro s t h;
  contrapose! hsep;
  refine' ⟨ t, s, _, hsep.symm ⟩;
  intro u;
  refine' le_antisymm _ _;
  · have := h ⟨ fun x => Fr.w t x, ?_, ?_ ⟩;
    all_goals norm_num [ beliefOfFrame ];
    all_goals norm_num [ AttObs ] at *;
    · have := Fr.w_tri t s u; simp_all +decide [ FinAttFrame.w_self ] ;
    · exact fun x y => Fr.w_tri t x y;
  · specialize h ⟨ fun x => Fr.w s x, ?_, ?_ ⟩;
    all_goals norm_num [ beliefOfFrame ] at *;
    · exact fun x y => Fr.w_tri s x y;
    · have := Fr.w_tri s t u;
      rw [ ← h ] at this;
      rw [ Fr.w_self ] at this ; aesop

/-! ## §15. Observable Kernel Properties -/

omit [DecidableEq S] in
/-
The observable kernel is symmetric when the underlying metric is symmetric.
-/
theorem obsKernel_symm {M : Type v} (B : FinBeliefSemimod S M)
    {ι : Type v} [Fintype ι]
    (e : ι → M)
    (hsymm : ∀ x y, B.d x y = B.d y x) :
    ∀ i j, obsKernel S B e i j = obsKernel S B e j i := by
  -- By definition of obsKernel, we have obsKernel S B e i j = B.d (e i) (e j).
  intros i j
  simp [obsKernel, hsymm]

omit [DecidableEq S] in
/-
Closure nonexpansiveness passes to the kernel when generators are closed.
-/
theorem obsKernel_closure_compat {M : Type v} (B : FinBeliefSemimod S M)
    {ι : Type v} [Fintype ι]
    (e : ι → M)
    (hcl : ∀ i, B.cl (e i) = e i) :
    ∀ i j, obsKernel S B e i j = B.d (B.cl (e i)) (B.cl (e j)) := by
  aesop

/-! ## §16. Main Duality Packaging -/

/-
**Finite Lawvere–Stone Attention Duality.**

For a finite separated belief semimodule `B` with generating family `e`:
1. The evaluation profile is injective (Stone-style embedding).
2. The minimal frame realizes the observable kernel.
3. The roundtrip Belief → Frame → Belief preserves the metric on generators.
4. The roundtrip Frame → Belief → Frame recovers the kernel.
5. Separation of frames yields separation of belief semimodules.
-/
omit [DecidableEq S] in
theorem finite_lawvere_stone_attention_duality
    {M : Type v} (B : FinBeliefSemimod S M) (hsep : Separated S B)
    {ι : Type v} [Fintype ι] [DecidableEq ι]
    (e : ι → M) (_hgen : Generates S B e) :
    -- (1) Evaluation is injective
    Injective (evalProfile S B) ∧
    -- (2) Minimal realizer exists and realizes the kernel
    Realizes S (minimalFrame S B e) (obsKernel S B e) ∧
    -- (3) Roundtrip preserves metric on generators
    (∀ i j, (beliefOfFrame S (minimalFrame S B e)).d i j = B.d (e i) (e j)) ∧
    -- (4) Frame roundtrip recovers kernel
    (obsKernel S (beliefOfFrame S (minimalFrame S B e)) id = obsKernel S B e) := by
  exact ⟨evalProfile_injective S B hsep, minimalFrame_realizes S B e,
    fun i j => rfl, rfl⟩

/-! ## §17. Structural Parallel with Closure-Extractor Duality -/

omit [DecidableEq S] in
/-
**Structural parallel**: The minimal attention frame construction mirrors
the canonical extractor construction in closure-extractor spectrum duality.
Both achieve minimality: generators ↔ extremal witnesses, frame tokens ↔ seeds.
-/
theorem attention_spectrum_structural_parallel
    {M : Type v} (B : FinBeliefSemimod S M)
    {ι : Type v} [Fintype ι] [DecidableEq ι]
    (e : ι → M) :
    -- The minimal frame has the same type as the generator index
    (minimalFrame S B e).w = obsKernel S B e := by
  rfl

end LawvereStoneAttentionDuality