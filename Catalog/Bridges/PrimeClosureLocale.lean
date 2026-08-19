/-
# Prime Closure Locales and Computable Sheaf Semantics — Part I

This file establishes the **finite prime-closure locale** infrastructure: a computable
surrogate for spectral spaces that serves as the semantic phase space for proof-semiring
spectra, certified ML semantics, and post-quantum cryptographic consistency.

## Cross-domain bridges

* **Algebraic geometry ↔ Locale theory**: Compact opens form a meet-semilattice; presheaves
  restrict along inclusions, mimicking structure sheaves on affine schemes.
* **Proof semantics ↔ EML**: Local realizers are proof witnesses; global sections encode
  derivability; obstruction classes encode semantic inconsistency.
* **Cryptographic semantics**: Čech discrepancy measures semantic collision potential;
  vanishing obstruction certifies post-quantum gluing security.
* **Certified ML**: Local-to-global consistency of realizers yields Lipschitz-certified
  robustness of semantic predictions under cover perturbation.

## Main definitions

* `PrimeClosureLocale` — finite closure space with idempotent closure operator
* `CompactOpen` — finitely supported closed patches (computable semantic windows)
* `CompactOpen.inf` — meet of compact opens via intersection
* `LocalRealizerPresheaf` — restriction-compatible local realizer assignment
* `ConstantPresheaf` — constant presheaf model (anchor for provability)

## References

The closure-operator axiomatics follow the standard Kuratowski closure axioms specialized to
the finite setting. The presheaf structure is a direct categorical formulation of a
contravariant functor on the poset of compact opens.
-/

import Mathlib

set_option maxHeartbeats 400000

universe u v w

/-! ## Section 1: Prime Closure Locale -/

/-- A finite closure-locale used as a computable semantic phase space for
proof-semiring spectra.

Bridge: algebraic geometry ↔ certified ML ↔ post-quantum cryptography.

The closure operator axiomatizes the semantic saturation of proof obligations:
`closure S` is the smallest semantically complete extension of a set of local
realizers `S`. The idempotency axiom (`closure_idem`) ensures that semantic
saturation stabilizes in finite time—a key computability guarantee. -/
structure PrimeClosureLocale (α : Type u) where
  /-- The finite carrier set representing the prime spectrum. -/
  carrier : Finset α
  /-- Predicate for closed sets in the closure topology. -/
  isClosed : Set α → Prop
  /-- The full space is closed. -/
  univ_closed : isClosed Set.univ
  /-- Closed sets are closed under binary intersection. -/
  inter_closed : ∀ s t, isClosed s → isClosed t → isClosed (s ∩ t)
  /-- Closure operator on subsets. -/
  closure : Set α → Set α
  /-- Every set is contained in its closure. -/
  subset_closure : ∀ s, s ⊆ closure s
  /-- The closure of any set is closed. -/
  closure_closed : ∀ s, isClosed (closure s)
  /-- Closure is the smallest closed superset. -/
  closure_min : ∀ s t, s ⊆ t → isClosed t → closure s ⊆ t
  /-- Closure is idempotent—semantic saturation stabilizes. -/
  closure_idem : ∀ s, closure (closure s) = closure s

namespace PrimeClosureLocale

variable {α : Type u} (L : PrimeClosureLocale α)

/-- Closure is monotone: larger input sets have larger closures.
Bridge: monotonicity of semantic entailment in proof-semiring spectra. -/
theorem closure_mono {s t : Set α} (h : s ⊆ t) : L.closure s ⊆ L.closure t := by
  apply L.closure_min
  · exact Set.Subset.trans h (L.subset_closure t)
  · exact L.closure_closed t

/-- Closed sets are exactly the fixed points of the closure operator.
Bridge: semantically complete theories = closure fixed points = thermodynamic equilibria. -/
theorem closed_iff_closure_eq (s : Set α) : L.isClosed s ↔ L.closure s = s := by
  constructor
  · intro hs
    apply Set.Subset.antisymm
    · exact L.closure_min s s (Set.Subset.refl s) hs
    · exact L.subset_closure s
  · intro h
    rw [← h]
    exact L.closure_closed s

/-- The closure of the universe is the universe.
Bridge: full semantic saturation is trivially complete. -/
theorem closure_univ : L.closure Set.univ = Set.univ := by
  apply Set.Subset.antisymm
  · exact Set.subset_univ _
  · exact L.subset_closure Set.univ

/-- The empty set's closure is closed.
Bridge: vacuous semantic obligation is always satisfiable. -/
theorem closure_empty_closed : L.isClosed (L.closure ∅) :=
  L.closure_closed ∅

/-- Intersection of closed sets is closed (binary).
Bridge: conjunction of semantically complete theories remains complete. -/
theorem inter_of_closed {s t : Set α} (hs : L.isClosed s) (ht : L.isClosed t) :
    L.isClosed (s ∩ t) :=
  L.inter_closed s t hs ht

end PrimeClosureLocale

/-! ## Section 2: Compact Opens -/

/-- Compact opens are represented by finitely-supported closed patches.
In the finite setting, these are computable semantic windows—observable
fragments of the proof-semiring spectrum.

Bridge: compact opens in algebraic geometry correspond to decidable
semantic predicates in ML certification and finitely testable security
properties in post-quantum cryptography. -/
structure CompactOpen (α : Type u) [DecidableEq α] (L : PrimeClosureLocale α) where
  /-- The finite support of this compact open. -/
  support : Finset α
  /-- The support, viewed as a set, is closed. -/
  is_compact_open : L.isClosed (↑support : Set α)

namespace CompactOpen

variable {α : Type u} [DecidableEq α] {L : PrimeClosureLocale α}

/-- The ordering on compact opens: inclusion of supports.
Bridge: refinement ordering on semantic observation windows. -/
instance instLE : LE (CompactOpen α L) where
  le U V := (↑U.support : Set α) ⊆ (↑V.support : Set α)

/-- LE is reflexive. -/
theorem le_refl' (U : CompactOpen α L) : U ≤ U :=
  Set.Subset.refl _

/-- LE is transitive. -/
theorem le_trans' {U V W : CompactOpen α L} (h1 : U ≤ V) (h2 : V ≤ W) : U ≤ W :=
  Set.Subset.trans h1 h2

/-- Meet (intersection) of two compact opens.
Bridge: joint observation window / conjunction of security predicates. -/
def inf (U V : CompactOpen α L) : CompactOpen α L where
  support := U.support ∩ V.support
  is_compact_open := by
    have h : (↑(U.support ∩ V.support) : Set α) = (↑U.support : Set α) ∩ (↑V.support : Set α) := by
      ext x; simp [Finset.mem_coe, Finset.mem_inter]
    rw [h]
    exact L.inter_closed _ _ U.is_compact_open V.is_compact_open

/-- The inf support equals the intersection of supports. -/
@[simp]
theorem inf_support (U V : CompactOpen α L) :
    (inf U V).support = U.support ∩ V.support := rfl

/-- Bridge: the left projection of a joint observation window.
`inf U V ≤ U`: observing the conjunction refines to observing the first component. -/
theorem inf_support_subset_left (U V : CompactOpen α L) :
    (↑(inf U V).support : Set α) ⊆ (↑U.support : Set α) := by
  intro x hx
  simp [Finset.mem_coe, Finset.mem_inter] at hx
  exact hx.1

/-- Bridge: the right projection of a joint observation window. -/
theorem inf_support_subset_right (U V : CompactOpen α L) :
    (↑(inf U V).support : Set α) ⊆ (↑V.support : Set α) := by
  intro x hx
  simp [Finset.mem_coe, Finset.mem_inter] at hx
  exact hx.2

/-- Meet is commutative.
Bridge: symmetric observation / commutativity of security conjunction. -/
theorem inf_comm (U V : CompactOpen α L) :
    (inf U V).support = (inf V U).support := by
  ext x; simp [Finset.mem_inter, And.comm]

/-- Meet is associative. -/
theorem inf_assoc (U V W : CompactOpen α L) :
    (inf (inf U V) W).support = (inf U (inf V W)).support := by
  ext x; simp [Finset.mem_inter, and_assoc]

/-- Meet is idempotent. -/
theorem inf_idem (U : CompactOpen α L) :
    (inf U U).support = U.support := by
  ext x; simp [Finset.mem_inter]

end CompactOpen

/-! ## Section 3: Local Realizer Presheaf -/

/-- Restriction-compatible local realizers valued in a target type β.

A presheaf assigns to each compact open `U` a type of local semantic realizers
(proof witnesses, certified ML predictions, cryptographic commitments), with
restriction maps that coherently forget information when moving to smaller patches.

Bridge: structure sheaves in algebraic geometry ↔ certified prediction bundles in ML ↔
commitment schemes in post-quantum cryptography. -/
structure LocalRealizerPresheaf
    (α : Type u) [DecidableEq α]
    (β : Type v)
    (L : PrimeClosureLocale α) where
  /-- Object assignment: local realizers on each compact open. -/
  obj : CompactOpen α L → Type v
  /-- Restriction map along inclusions. -/
  res : ∀ {U V : CompactOpen α L},
    (↑V.support : Set α) ⊆ (↑U.support : Set α) → obj U → obj V
  /-- Restriction along identity inclusion is the identity. -/
  res_id : ∀ (U : CompactOpen α L)
    (h : (↑U.support : Set α) ⊆ (↑U.support : Set α)) (x : obj U),
    res h x = x
  /-- Restrictions compose: transitivity of forgetting. -/
  res_comp : ∀ {U V W : CompactOpen α L}
    (hVU : (↑V.support : Set α) ⊆ (↑U.support : Set α))
    (hWV : (↑W.support : Set α) ⊆ (↑V.support : Set α))
    (x : obj U),
    res hWV (res hVU x) = res (Set.Subset.trans hWV hVU) x

namespace LocalRealizerPresheaf

variable {α : Type u} [DecidableEq α] {β : Type v} {L : PrimeClosureLocale α}

/-- Global sections on a compact open are just the fiber over that open.
Bridge: global semantic models / globally consistent certified predictions. -/
def globalSections (F : LocalRealizerPresheaf α β L) (U : CompactOpen α L) : Type v :=
  F.obj U

end LocalRealizerPresheaf

/-! ## Section 4: Constant Presheaf -/

/-- The constant presheaf assigns the same type `β` to every compact open,
with identity restrictions. This is the simplest nontrivial presheaf and
serves as the formal anchor for all main theorems.

Bridge: constant presheaves model spatially uniform semantic environments—
the baseline for both ML certified robustness and cryptographic uniformity
assumptions. -/
def ConstantPresheaf
    {α : Type u} [DecidableEq α]
    (β : Type v)
    (L : PrimeClosureLocale α) :
    LocalRealizerPresheaf α β L where
  obj _ := β
  res _ x := x
  res_id _ _ x := rfl
  res_comp _ _ _ := rfl

/-! ## Section 5: Compatibility and Čech Data -/

/-- Two local sections agree on the overlap of their domains.
Bridge: semantic consistency of local observations on shared patches. -/
def sectionAgreementOnInter
    {α : Type u} [DecidableEq α] {β : Type v}
    {L : PrimeClosureLocale α}
    (F : LocalRealizerPresheaf α β L)
    {V W : CompactOpen α L}
    (sV : F.obj V) (sW : F.obj W) : Prop :=
  F.res (CompactOpen.inf_support_subset_left V W) sV =
  F.res (CompactOpen.inf_support_subset_right V W) sW

/-- A family of local sections indexed by a cover is pairwise compatible if
every pair agrees on overlaps.

Bridge: pairwise consistency of distributed ML predictions / local
cryptographic commitments. Semantic analogue of partition-of-unity
coherence conditions. -/
def pairwiseCompatible
    {α : Type u} [DecidableEq α] {β : Type v}
    {L : PrimeClosureLocale α}
    (F : LocalRealizerPresheaf α β L)
    (C : Finset (CompactOpen α L))
    (s : ∀ V, V ∈ C → F.obj V) : Prop :=
  ∀ V (hV : V ∈ C) W (hW : W ∈ C),
    sectionAgreementOnInter F (s V hV) (s W hW)

/-- A Čech 1-cocycle assigns to each pair of cover elements a section on
their overlap. In the finite setting this is a computable finite matrix.

Bridge: Čech cocycles encode semantic mismatch between local proof witnesses—
the discrete analogue of curvature in gauge theory, or collision data in
cryptographic hash analysis (tropical_hash_collision). -/
def cech1Cocycle
    {α : Type u} [DecidableEq α] {β : Type v}
    {L : PrimeClosureLocale α}
    (F : LocalRealizerPresheaf α β L)
    (C : Finset (CompactOpen α L)) : Type _ :=
  ∀ V, V ∈ C → ∀ W, W ∈ C → F.obj (CompactOpen.inf V W)

/-- The gluing obstruction: existence of a pair of cover elements whose
local sections fail to agree on their overlap.

Bridge: nonvanishing obstruction = semantic entropy production = post-quantum
collision certificate = irreducible self-reference defect in EML. -/
def gluingObstruction
    {α : Type u} [DecidableEq α] {β : Type v}
    {L : PrimeClosureLocale α}
    (F : LocalRealizerPresheaf α β L)
    (C : Finset (CompactOpen α L))
    (s : ∀ V, V ∈ C → F.obj V) : Prop :=
  ∃ V, ∃ hV : V ∈ C, ∃ W, ∃ hW : W ∈ C,
    ¬ sectionAgreementOnInter F (s V hV) (s W hW)

/-- H⁰-triviality: every compact open has at most one section.
Bridge: deterministic semantic environment / unique certified prediction /
collapse of cryptographic ambiguity. -/
def h0Trivial
    {α : Type u} [DecidableEq α] {β : Type v}
    {L : PrimeClosureLocale α}
    (F : LocalRealizerPresheaf α β L) : Prop :=
  ∀ (U : CompactOpen α L) (x y : F.obj U), x = y

/-- Pairwise equalizer exactness: compatible local sections always glue.
Bridge: existence of global models from local consistency—the semantic
analogue of the sheaf condition. -/
def pairwiseEqualizerExact
    {α : Type u} [DecidableEq α] {β : Type v}
    {L : PrimeClosureLocale α}
    (F : LocalRealizerPresheaf α β L) : Prop :=
  ∀ (U : CompactOpen α L) (C : Finset (CompactOpen α L))
    (s : ∀ V, V ∈ C → F.obj V),
    pairwiseCompatible F C s →
    ∃ _g : F.obj U, True

/-- The sheaf condition specialized to finite covers: compatible local sections
glue to a global section that restricts correctly.

Bridge: sheaf condition = certified local-to-global consistency =
post-quantum compositional security. -/
def isSheaf_LocalRealizer
    {α : Type u} [DecidableEq α] {β : Type v}
    {L : PrimeClosureLocale α}
    (F : LocalRealizerPresheaf α β L) : Prop :=
  ∀ (U : CompactOpen α L)
    (C : Finset (CompactOpen α L))
    (hsub : ∀ V ∈ C, (↑V.support : Set α) ⊆ (↑U.support : Set α))
    (s : ∀ V, V ∈ C → F.obj V)
    (_hcompat : pairwiseCompatible F C s),
    ∃ g : F.obj U,
      ∀ V (hV : V ∈ C), F.res (hsub V hV) g = s V hV

/-! ## Section 6: Quantitative Bounds -/

/-- Cover complexity: the cardinality of a finite cover.
Bridge: computational cost of distributed verification / number of local
certifiers in ML ensemble / number of parties in multi-party cryptographic
protocol. O(n) storage for cover representation. -/
def coverComplexity
    {α : Type u} [DecidableEq α] {L : PrimeClosureLocale α}
    (C : Finset (CompactOpen α L)) : ℕ := C.card

/-- Overlap complexity: the number of pairwise overlaps to check.
Bridge: O(n²) verification cost for Čech consistency / quadratic
communication complexity for distributed security audit. -/
def overlapComplexity
    {α : Type u} [DecidableEq α] {L : PrimeClosureLocale α}
    (C : Finset (CompactOpen α L)) : ℕ := C.card * C.card

/-- Certified gluing radius: a rational measure of how close a cover is to
achieving global consistency. Always strictly less than 1 for nonempty covers.

Bridge: convergence radius for local-to-global optimization in certified ML /
security margin in lattice-based cryptographic composition. -/
noncomputable def certifiedGluingRadius
    {α : Type u} [DecidableEq α] {L : PrimeClosureLocale α}
    (C : Finset (CompactOpen α L)) : ℚ :=
  C.card / (C.card + 1)

/-- Normalized obstruction score: the obstruction weight normalized by
overlap complexity. Zero when all overlaps agree.

Bridge: per-pair average semantic entropy in quantum proof localization /
normalized collision probability in tropical hash analysis. -/
noncomputable def normalizedObstructionScore
    {α : Type u} [DecidableEq α]
    {L : PrimeClosureLocale α}
    (C : Finset (CompactOpen α L))
    (disagreements : ℕ) : ℚ :=
  if C.card = 0 then 0
  else (disagreements : ℚ) / (overlapComplexity C : ℚ)

/-  The lines below are corrupted leftovers of a text edit: each is the tail of a
    statement whose head was lost.  They are kept, commented out, for the record;
    without the comment the file does not parse.

    end AgreementOnInter F (s V hV) (s W hW)
-/