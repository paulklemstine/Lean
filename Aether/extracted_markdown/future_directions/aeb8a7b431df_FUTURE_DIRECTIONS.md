# Future Directions: One-Way Functions — Existence and Hierarchy

## Synthesis

This cycle established a formal framework for "one-way" functions on finite types, defined as
non-injective endomorphisms. The key discovery is that `imageRank` (the cardinality of the
range) serves as a **complete monotone invariant** for the one-way hierarchy: it fully
characterizes injectivity (`imageRank_eq_card_iff_injective`), is monotone under left composition
(`imageRank_compose_le`), and decreases monotonically under iteration (`imageRank_iterate_le`).
The `finite_inj_iff_surj` theorem collapses the classical injective/surjective distinction,
leaving only a binary classification: bijective (information-preserving) or one-way
(information-losing).

We also investigated the substitution lemma for STLC in the project's existing formalization
and **disproved** it: the naive (non-capture-avoiding) substitution in `BoundedBetaDefs.lean`
admits a concrete counterexample via variable capture. This is documented in
`SubjectReduction.lean` with the explicit counterexample (Γ = [(2, base→base)], body =
lam 2 (app (var 0) (var 2)), arg = var 2).

The FiberGraph Theorems.lean file was cleaned up — all its sorry targets were already proved
in the companion Core.lean file, so the duplicated sorry-bearing declarations were removed.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|-------------|
| `finite_inj_iff_surj` | proved | Collapses inj/surj distinction on finite types |
| `imageRank_drop` | proved | Quantifies information loss: non-surjective ⟹ rank < |α| |
| `imageRank_compose_le` | proved | Image rank monotone under left composition |
| `one_way_compose_one_way` | proved | One-wayness propagates through left composition |
| `one_way_absorbs` | proved | One-wayness propagates from EITHER factor |
| `imageRank_eq_card_iff_injective` | proved | Image rank is the complete invariant |
| `imageRank_iterate_le` | proved | Image rank non-increasing under iteration |
| `subst_preserves_typing'` | disproved | Naive substitution admits variable capture |

## Research Directions

### Direction 1: Image Rank Stabilization and Eventual Image Structure

**Hypothesis**: For any f : α → α on a finite type, the sequence imageRank(f^[n]) stabilizes
at some N ≤ |α|, and f restricted to the eventual image (⋂ₙ Im(f^[n])) is a bijection.

**Test**: Prove `∃ N, ∀ n ≥ N, imageRank (f^[n]) = imageRank (f^[N])` using the well-ordering
of ℕ and `imageRank_iterate_le`. Then prove `Function.Bijective (f.restrict (eventualImage f))`.

**Why now**: We have `imageRank_iterate_le` giving the non-increasing property. The missing
piece is a Lean-native proof that a bounded non-increasing ℕ-sequence stabilizes — this
should follow from `Nat.lt_wfRel` or similar Mathlib infrastructure.

**If true**: Opens the door to formalizing the orbit-tail decomposition of finite dynamical
systems, connecting to permutation group theory.

**If false**: Would require rethinking eventualImage as a coalgebraic rather than set-theoretic
concept, which would be surprising.

The key insight is that imageRank is a well-ordered invariant bounded below by 1 (for nonempty types), so the descent must terminate.

### Direction 2: Image Rank as a Lattice Homomorphism

**Hypothesis**: The image rank function `imageRank : End(α) → ℕ` is a lattice homomorphism
from (End(α), ≤_composition) to (ℕ, ≤), where f ≤ g iff Im(f) ⊆ Im(g). Moreover, each
"level set" {f | imageRank f = k} is an ideal in End(α) under composition.

**Test**: Formalize the preorder on End(α) by image containment. Show `imageRank` is monotone
with respect to this preorder. Check whether level sets are ideals (closed under left and
right composition with arbitrary endomorphisms).

**Why now**: We proved `imageRank_compose_le` which gives one direction of monotonicity.
The level set property would follow from `one_way_absorbs` combined with `imageRank_drop`.

**If true**: Provides a connection between transformation monoid theory and lattice theory,
potentially linking to Rees matrix semigroups.

**If false**: The level sets are likely not ideals under right composition — a one-way function
composed on the right with a bijection stays one-way, but the rank might change. This would
teach us that the lattice structure is fundamentally asymmetric.

The key insight is that left composition and right composition interact differently with imageRank.

### Direction 3: Capture-Avoiding Substitution and Subject Reduction

**Hypothesis**: Subject reduction holds for STLC with de Bruijn indices (or with an explicit
freshness condition on substitution).

**Test**: Redefine `Lam` using de Bruijn indices. Prove the substitution lemma and subject
reduction for this representation. Alternatively, add a Barendregt-convention hypothesis
(bound variables are always distinct from free variables) to `subst_preserves_typing'`.

**Why now**: We identified the exact failure point in the current formalization: naive
substitution allows variable capture. The counterexample (body = lam 2 (app (var 0) (var 2)),
arg = var 2) is minimal and instructive.

**If true**: Completes the formalization of basic STLC metatheory, enabling formalization of
strong normalization and other advanced results.

**If false**: Would indicate a deeper issue with the typing judgment formulation (unlikely —
this is very well-studied).

The key insight is that the capture counterexample has a specific structure: the captured
variable must appear in a "function position" with a different type than its binder provides.

### Direction 4: One-Way Functions in Infinite Types

**Hypothesis**: For countably infinite types (ℕ), the one-way hierarchy is strictly richer
than for finite types: there exist injective-but-not-surjective functions, and the image rank
(as a cardinal) does not collapse the hierarchy.

**Test**: Formalize `isOneWay` for `ℕ → ℕ`. Show that the successor function `Nat.succ` is
injective but not surjective. Prove that `imageRank_eq_card_iff_injective` fails: define
a function with image rank ℵ₀ that is not injective (e.g., f(n) = n/2).

**Why now**: Our finite-type results rely crucially on `Finite.injective_iff_surjective`.
Understanding exactly where this breaks in the infinite case would clarify the boundary of
our framework.

**If true**: Establishes that the "one-way hierarchy" has fundamentally different structure
in finite vs. infinite settings, motivating a richer classification theory.

**If false**: Would suggest unexpected structural rigidity in the infinite case.

The key insight is that `Finite.injective_iff_surjective` is the single theorem that makes the
finite hierarchy collapse, and removing it should unlock a richer structure.

### Direction 5: Composition Depth and the Rank Filtration

**Hypothesis**: For a fixed one-way function f : α → α, the "composition depth" d(f) —
defined as the smallest n such that imageRank(f^[n]) = imageRank(f^[n+1]) — satisfies
d(f) ≤ |α| - imageRank(f). Moreover, d(f) equals the length of the longest strictly
decreasing chain in the image sequence.

**Test**: Prove `d(f) ≤ Fintype.card α - imageRank f` using the fact that each strict
decrease reduces imageRank by at least 1. Define `compositionDepth` and prove the bound.

**Why now**: We have `imageRank_iterate_le` and `imageRank_drop`. The bound follows from
counting: at most |α| - imageRank(f) strict decreases are possible before stabilization.

**If true**: Gives a computable invariant measuring "how quickly" a one-way function reaches
its stable regime, with applications to analyzing cryptographic hash function iterations.

**If false**: Would indicate that imageRank can decrease by more than 1 in a single step
while still having a longer chain, which would require a more refined counting argument.

The key insight is that the rank filtration End(α) ⊃ {f | rank ≤ n-1} ⊃ ... ⊃ {f | rank ≤ 1}
provides a natural stratification with at most n-1 levels.
