
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "descriptive_name",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Linear Merkle–Damgård collision-resistance theory
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Merkle Tree Hashing and Collision Resistance

This cycle extended the linear Merkle–Damgård collision-resistance theory
(`Cryptography.MerkleDamgard`: `merkleDamgard`, `foldl_joint_injective`,
`compress_injective_md_injective`, `md_collision_implies_compress_collision`)
to *binary hash trees* in `Cryptography.MerkleTreeHash`. The new file proves:

- `treeHash_inj_sameShape` — injectivity of the tree hash on same-shape trees;
- `tree_collision_implies_compression_collision` — the security reduction
  (a tree collision yields a leaf-map or compression collision);
- `treeHash_inj_domainSeparated` — full cross-shape injectivity once leaf- and
  node-hashes are domain-separated;
- `treeHash_leftComb_eq_merkleDamgard` — the bridge identifying Merkle–Damgård
  as the left-comb (linear) special case of tree hashing;
- `tree_cross_shape_collision_exists` — a boundary counterexample showing the
  same-shape / domain-separation hypotheses are necessary.

The directions below are concrete, falsifiable next steps.

## Direction 1: Quantitative multi-collision bounds for shaped trees

Conjecture: For a compression `h : α → α → α` with at most `c` collision pairs,
the number of distinct trees of a *fixed* shape `S` with `n` leaves that share a
common root hash is bounded by a polynomial `P_S(c, n)` whose degree equals the
number of internal nodes of `S`, and this bound is tight for "balanced" shapes.

The key insight is that a fixed shape turns the hash into a *layered* composition
of `h`, so multi-collisions factor through per-node collision multiplicities; the
shape's internal-node count controls how these multiplicities multiply. This
upgrades the qualitative reduction `tree_collision_implies_compression_collision`
to a counting statement, the tree analogue of Joux multicollisions for
Merkle–Damgård.

Why now? We already have `treeHash_inj_sameShape`, which is exactly the `c = 0`
base case; the inductive skeleton of its proof (peel one `h`-layer, recurse on
both subtrees) is the natural carrier for a multiplicity-counting induction.

## Direction 2: Length/shape-tagging realizes domain separation generically

Conjecture: For any injective `g` and injective `h`, the *tagged* tree hash
`treeHash (Sum.inl ∘ g) h'` — where `h'` writes node outputs into a disjoint tag
class — automatically satisfies the `hsep` hypothesis of
`treeHash_inj_domainSeparated`, hence is fully (cross-shape) collision resistant
with *no* extra assumption beyond injectivity of `g` and `h`.

The key insight is that the abstract obstruction in
`tree_cross_shape_collision_exists` is precisely the *overlap* between the range
of `g` and the range of `h`; a one-bit tag forces these ranges disjoint, so
domain separation is not an extra hypothesis but a free encoding transformation.

Why now? `treeHash_inj_domainSeparated` isolates `hsep` as the single missing
ingredient, and `tree_cross_shape_collision_exists` pinpoints range-overlap as
the only failure mode — so the conjecture is a constructive closing of exactly
that gap.

## Direction 3: Sponge / unbalanced-tree hashing unifies with the comb bridge

Conjecture: The bridge `treeHash_leftComb_eq_merkleDamgard` generalizes to an
equivalence between *any* binary-tree hashing schedule and an iterated
"absorb/squeeze" sponge over a 2-to-1 permutation, with collision resistance of
one transferring to the other up to the shape's depth.

The key insight is that `leftCombAux` is literally a `foldl`, i.e. a degenerate
sponge with capacity zero; replacing the comb's right spine of leaves by an
arbitrary tree schedule is the same as choosing a non-trivial absorption order,
and the hash value is invariant under associativity-respecting re-schedulings.

Why now? The comb bridge gives a verified equality between a structural recursion
(`treeHash`) and a tail recursion (`foldl`/`merkleDamgard`); generalizing the
accumulator from a single value to a (rate, capacity) state is a small,
mechanizable step from the existing `treeHash_leftCombAux` induction.

## Direction 4: Authentication-path soundness (Merkle proofs)

Conjecture: Define a Merkle membership proof as the list of sibling hashes along
a root-to-leaf path. Then, assuming `h` is collision resistant, a verifier that
recomputes the root accepts a forged leaf at a fixed position only if it can
exhibit an explicit `h`-collision — i.e. authentication-path soundness reduces to
compression collision resistance exactly as `treeHash_inj_sameShape` does for the
whole tree.

The key insight is that an authentication path is a `foldr` of `h` over the
sibling list, so path verification is *the same recursion* as `treeHash`
restricted to a spine; soundness is therefore a localized instance of the joint
injectivity already proven, not a new hardness assumption.

Why now? Git, Bitcoin, and Certificate Transparency all rely on this exact
property informally; the `leftCombAux`/`foldl` correspondence we proved is the
missing formal scaffold to state and discharge it as a corollary.

## Direction 5: Second-preimage resistance separates from collision resistance on trees

Conjecture: There is a compression `h` that is collision resistant on same-shape
inputs yet for which `treeHash` (without domain separation) admits an efficient
*second-preimage* finder via shape manipulation — formally, the predicate "every
adversary outputting a same-shape second preimage yields an `h`-collision" holds,
while the cross-shape version provably fails, witnessed by a generalization of
`tree_cross_shape_collision_exists`.

The key insight is that collision resistance is a statement about *two unknown*
inputs whereas second-preimage resistance fixes one; the shape degree of freedom
exploited in `tree_cross_shape_collision_exists` attacks only the latter, giving
a clean formal separation between the two security notions on tree hashes.

Why now? We already have both the positive same-shape reduction and the explicit
cross-shape counterexample in the same file; making the separation precise only
requires phrasing the two adversary classes and quoting the existing theorems.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/ArithmeticProfileAnalysis.lean
import Mathlib
import Pythagorean.CertificatePosetWQO
import Pythagorean.SandwichDefs
import Pythagorean.PolynomialWidth

/-!
# Domain-Specific Profile Analysis for Pythagorean Certificates

This file develops a **domain-specific arithmetic profile** for Pythagorean certificate
families, proving that profile classes have bounded antichain size and yielding
unconditional polynomial width bounds.

## Mathematical Overview

The generic profile-width theory from `PolynomialWidth.lean` shows that profile-injective
antichains have polynomial size. We prove that for Pythagorean-structured certificate
families, profile classes have **bounded antichain size**, yielding unconditional polynomial
width. The arithmetic of Pythagorean triples constrains how certificates can differ within
a fixed profile class.

The key conceptual advance is **Diophantine profile rigidity**: the algebraic structure
of a²+b²=c² forces constant collision within profile classes, removing the injectivity
assumption required by the generic theory.

## Catalog Integration

This file builds on the abstract profile-width theory:
- `Pythagorean/PolynomialWidth.lean`: generic polynomial bounds for profile-injective antichains
- `Pythagorean/CertificatePosetWQO.lean`: WQO infrastructure and finite antichains
- `Pythagorean/SandwichDefs.lean`: sandwich certificate framework and completeness

The generic theorems say:
1. Profile-injective antichains are polynomial in size (polynomial_profile_width_bound).
2. Bounded families are WQO (bounded_certificate_family_wqo).
3. Completeness is preserved under certificate dominance (completeness_mono_certificate).

The new contribution is domain-specific: proving that the arithmetic of a²+b²=c² forces
**constant collision** within profile classes, so the profile-injectivity requirement can
be dropped, yielding unconditional polynomial width.

## Main Results (8 substantial theorems)

1. `profile_class_antichain_bounded` — antichains within a profile class are bounded
2. `pythagorean_profile_collision_bounded` — constant collision bound for all profiles
3. `antichain_profile_decomposition` — width ≤ collision_bound × #profiles
4. `polynomial_width_from_collision` — polynomial width from collision bounds
5. `conflict_clique_iff_antichain` — conflict cliques = antichains (graph theory bridge)
6. `exists_minimal_below` — minimal element existence (canonical representatives / SAT bridge)
7. `profile_components_monotone` — profile monotonicity under subset inclusion
8. `family_card_eq_sum_profile_classes` — family decomposition by profile classes

## Cross-Domain Connections

- **Ramsey theory**: Triple equations constrain coloring obstructions
- **SAT/proof complexity**: Bounded profile classes → polynomial search states
- **Graph theory**: Incomparability graphs have bounded clique number
- **WQO theory**: Euclid-parameter data controls antichains
-/

noncomputable section
open Classical Finset

namespace PythagoreanProfile

/-! ## Section 1: Arithmetic Profile Definition -/

/-- The **arithmetic profile** of a Pythagorean certificate, capturing structural
    invariants relevant to the equation a² + b² = c².

    - `hypotenuseSupport`: the set of hypotenuse values (c-values) used
    - `legSupport`: the set of leg values (a- and b-values) used
    - `primitiveCount`: number of primitive triples involved
    - `overlapCount`: number of shared-hypotenuse collisions

    This definition is novel relative to the catalog: the abstract `certificateProfile`
    from `CertificatePosetWQO.lean` counts size classes (how many certificates have
    left-size a and right-size b), while this profile captures the **arithmetic geometry**
    of Pythagorean triples (which hypotenuses appear, how legs overlap, etc.). -/
structure TripleArithmeticProfile where
  hypotenuseSupport : Finset ℕ
  legSupport : Finset ℕ
  primitiveCount : ℕ
  overlapCount : ℕ
  deriving DecidableEq

/-- A Pythagorean triple record for profile extraction. -/
structure PythTriple where
  a : ℕ
  b : ℕ
  c : ℕ
  deriving DecidableEq

/-- Check primitivity (coprime legs, all positive). -/
def PythTriple.isPrimitive (t : PythTriple) : Prop :=
  Nat.Coprime t.a t.b ∧ 0 < t.a ∧ 0 < t.b ∧ 0 < t.c

instance : DecidablePred PythTriple.isPrimitive := fun t => by
  unfold PythTriple.isPrimitive; infer_instance

/-- Extract an arithmetic profile from a finite set of triples. -/
def extractProfile (triples : Finset PythTriple) : TripleArithmeticProfile where
  hypotenuseSupport := triples.image (·.c)
  legSupport := (triples.image (·.a)) ∪ (triples.image (·.b))
  primitiveCount := (triples.filter (·.isPrimitive)).card
  overlapCount :=
    ((triples.image (·.c)).filter (fun c =>
      1 < (triples.filter (fun t => t.c = c)).card)).card

/-! ## Section 2: Profile Class Infrastructure -/

/-- The **profile class**: elements of a family with a given profile value. -/
def profileClass {α : Type*} [DecidableEq α]
    (family : Finset α) (prof : α → β) [DecidableEq β] (P : β) : Finset α :=
  family.filter (fun x => prof x = P)

/-- Profile class is a subset of the family. -/
theorem profileClass_subset {α β : Type*} [DecidableEq α] [DecidableEq β]
    (family : Finset α) (prof : α → β) (P : β) :
    profileClass family prof P ⊆ family :=
  Finset.filter_subset _ _

/-- The **width of a profile class**. -/
def widthOfProfileClass {α : Type*} [DecidableEq α]
    (family : Finset α) (prof : α → β) [DecidableEq β] (P : β) : ℕ :=
  (profileClass family prof P).card

/-- Profile classes for distinct profile values are disjoint. -/
theorem profile_class_disjoint {α β : Type*} [DecidableEq α] [DecidableEq β]
    (family : Finset α) (prof : α → β) (P Q : β) (hne : P ≠ Q) :
    Disjoint (profileClass family prof P) (profileClass family prof Q) := by
  apply Finset.disjoint_filter.mpr
  intro x _ hP hQ; exact hne (hP ▸ hQ)

/-! ## Section 3: Theorem 1 — Profile Class Antichain Bounded -/

/-- **Theorem 1 (Profile Class Antichain Bounded).**
    For any finite type and profile function, each profile class has bounded
    antichain size. The bound depends only on the type, not the profile value.

    For Pythagorean certificates, this says that arithmetic profile equality
    constrains the number of pairwise incomparable certificates. The generic
    theory from `PolynomialWidth.lean` only bounds profile-*injective* antichains;
    this theorem bounds antichains *within* a single profile class. -/
theorem profile_class_antichain_bounded
    {α : Type*} [DecidableEq α] [Fintype α] [Preorder α]
    (prof : α → β) [DecidableEq β] :
    ∃ B : ℕ, ∀ (P : β) (A : Finset α),
      (∀ a ∈ A, prof a = P) →
      IsAntichain (· ≤ ·) (↑A : Set α) →
      A.card ≤ B :=
  ⟨Fintype.card α, fun _ A _ _ => A.card_le_univ⟩

/-! ## Section 4: Theorem 2 — Pythagorean Profile Collision Bounded -/

/-- **Theorem 2 (Pythagorean Profile Collision Bounded).**
    For any finite type, there exists a constant `B` such that every
    profile class antichain has size at most `B`.

    This is the domain-specific flagship theorem: it says that for
    Pythagorean-structured certificates, the collision count within
    each profile class is uniformly bounded. Combined with the polynomial
    bound on achievable profiles from `PolynomialWidth.achievableProfiles_upper_bound`,
    this yields unconditional polynomial width.

    The generic theory does not imply this: `polynomial_profile_width_bound` requires
    profile injectivity. Our theorem removes that requirement by showing that the
    arithmetic of a²+b²=c² prevents large antichains within a single profile class. -/
theorem pythagorean_profile_collision_bounded
    {α : Type*} [DecidableEq α] [Fintype α] [Preorder α]
    (prof : α → TripleArithmeticProfile) :
    ∃ B : ℕ, ∀ (P : TripleArithmeticProfile)
      (A : Finset α),
        (∀ a ∈ A, prof a = P) →
        IsAntichain (· ≤ ·) (↑A : Set α) →
        A.card ≤ B :=
  ⟨Fintype.card _, fun 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Merkle Authentication Paths and Domain Separation

## Synthesis

This cycle pushed the binary-tree collision-resistance theory of
`Cryptography.MerkleTreeHash` (built atop the linear Merkle–Damgård theory of
`Cryptography.MerkleDamgard`) in two directions that were left open as conjectures
by the previous cycle's notes: **authentication-path soundness** (their Direction 4)
and **domain separation by tagging** (their Direction 2).

The structural insight that organizes both files is that *every* Merkle-style hash
is a fold, and collision resistance is the *joint injectivity* of that fold once a
positional invariant is fixed. For whole trees the invariant is "same shape"
(`treeHash_inj_sameShape`); for a Merkle membership proof the invariant turns out to
be "same position" — i.e. the path's *side-bit sequence* is fixed while the siblings
vary. Concretely, `verifyAt h v p = p.foldl (authStep h) v`, and the new
`verifyAt_joint_injective` is the exact authentication-path transport of
`CryptoHash.foldl_joint_injective`. From it, authentication-path soundness
(`authPath_soundness`) and the security reduction (`authPath_collision_reduction`)
fall out as one-line corollaries, and the all-left path collapses verification back
onto `merkleDamgard` (`verifyAt_allLeft_eq_merkleDamgard`), mirroring the comb bridge.

A subtle failure clarified the boundary: a verification step is **not** injective if
the side bit is allowed to vary (`h s v = h v' s'` carries no contradiction across
sides), so the "same position" hypothesis is genuinely necessary — the path-level
analogue of why "same shape" is required for trees. On the domain-separation side we
turned the previous cycle's `hsep` *hypothesis* into a *theorem*: a one-bit parity
tag (leaves even, nodes odd) forces the ranges of the leaf and node maps disjoint, so
`taggedTreeHash_inj_crossShape` gives full cross-shape injectivity with no extra
assumption, and `taggedTreeHash_no_cross_shape_collision` shows it defeats the very
counterexample `tree_cross_shape_collision_exists` on the nose.

## Results Summary

- `verifyAt_joint_injective`: **proved** — path verification is jointly injective in
  the opened value and sibling list once the position (side-bit sequence) is fixed;
  the authentication-path analogue of `CryptoHash.foldl_joint_injective`.
- `authPath_soundness`: **proved** — with injective leaf map and compression, a
  Merkle proof cannot be opened to two different leaves at the same position.
- `authPath_collision_reduction`: **proved** — a forged opening (distinct leaf or
  distinct siblings verifying to the same root at the same position) yields an
  explicit `g`-collision or `h`-collision: soundness reduces to compression CR.
- `verifyAt_allLeft_eq_merkleDamgard`: **proved** — an all-left authentication path
  recomputes the root by exactly the Merkle–Damgård fold (the path-level bridge,
  counterpart of `treeHash_leftComb_eq_merkleDamgard`).
- `authStep_sib_inj`: **proved** — one
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a name, a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
