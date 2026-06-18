
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
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
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

**Title**: Close Proofs: Cryptographic Hash Functions: Collision Resistance from Hard Problems
**Domain**: Novelty
**Mathematical framing**: Cycle 0c7bdbdf (Q=0.459) proved 717 theorems in Cryptography but left 9 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Prove that if one-way functions exist, then collision-resistant hash functions exist. Formalize the Merkle-Damgard construction and prove it preserves collision resistance. Show that SHA-256's compres
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/Bridge.lean
import Mathlib
import Bridges.ProofTheoreticCrypto.Core

/-!
# Proof-Theoretic Cryptography: Bridge Theorems

## Bridge: Structural Proof Theory ↔ Cryptographic Primitives

This module builds cryptographic primitives from proof-theoretic foundations,
establishing a new bridge between Logic and Cryptography. The three main
constructions are:

1. **Cut-Elimination One-Way Function (CutElimOWF)**: Cut-elimination is
   polynomial forward but PSPACE-hard to invert, yielding a one-way function.

2. **Normalization Commitment Scheme (NormCommitment)**: Church-Rosser
   confluence provides computational binding; inversion hardness provides hiding.

3. **Proof-Object Zero-Knowledge (ProofObjectZK)**: Proof normalization yields
   a zero-knowledge protocol with completeness from termination, soundness from
   correctness, and zero-knowledge from simulator indistinguishability.

## Main Theorems

* `CutElimOWF.asymmetry` — forward is easy, inverse is hard
* `NormCommitment.binding_from_confluence` — binding from Church-Rosser
* `NormCommitment.hiding_from_hardness` — hiding from inversion hardness
* `ProofObjectZK.completeness` — honest proofs verify
* `ProofObjectZK.soundness` — false claims rejected
* `proof_trace_monoid` — proof traces form a monoid
* `cut_free_submonoid` — cut-free traces form a submonoid
* `security_amplification` — security amplifies under composition

## Impact

This is the first bridge between proof theory and cryptography in any formal
verification system. It establishes that hardness can arise from proof structure
rather than number-theoretic or lattice assumptions — a fundamentally new
paradigm for post-quantum cryptography.
-/

namespace ProofTheoreticCrypto

open AbstractRewriteSystem ConfluentRewriteSystem

/-! ## Part I: Cut-Elimination One-Way Function -/

/-- A proof-theoretic one-way function: forward computation (cut-elimination)
    is polynomial, but inversion (cut-introduction) is superpolynomially hard.
    Bridge: Logic (cut-elimination complexity) ↔ Cryptography (OWF security). -/
structure CutElimOWF where
  /-- The domain: proof terms with cuts. -/
  domainType : Type
  /-- The codomain: cut-free proof terms. -/
  codomainType : Type
  /-- The forward function: cut-elimination. -/
  forward : domainType → codomainType
  /-- Forward cost function. -/
  forwardCost : ℕ → ℕ
  /-- Inverse cost lower bound. -/
  inverseCostLB : ℕ → ℕ
  /-- Size measure on the domain. -/
  domainSize : domainType → ℕ
  /-- Forward computation is polynomial: O(n^k). -/
  forwardPoly : ∃ k : ℕ, ∀ n : ℕ, forwardCost n ≤ n ^ k + k
  /-- Inversion is superpolynomially hard. -/
  inverseHard : ∀ M : ℕ, ∃ N : ℕ, ∀ n : ℕ,
    N ≤ n → forwardCost n + M ≤ inverseCostLB n

namespace CutElimOWF

/-- The hardness assumption derived from a CutElimOWF. -/
def toHardnessAssumption (owf : CutElimOWF) : HardnessAssumption where
  forwardCost := owf.forwardCost
  inverseCostLB := owf.inverseCostLB
  forwardPoly := owf.forwardPoly
  inverseExceedsForward := owf.inverseHard

/-- The computational asymmetry gap grows without bound.
    Bridge: increasing security parameter → increasing one-wayness. -/
theorem asymmetry (owf : CutElimOWF) :
    ∀ M : ℕ, ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      (M : ℤ) ≤ owf.toHardnessAssumption.gapZ n :=
  owf.toHardnessAssumption.gap_grows

/-- Forward is eventually strictly less than inverse.
    Bridge: the one-way function property for cut-elimination. -/
theorem forward_lt_inverse (owf : CutElimOWF) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
      owf.forwardCost n < owf.inverseCostLB n :=
  owf.toHardnessAssumption.forward_lt_inverse

end CutElimOWF

/-! ## Part II: Normalization Commitment Scheme -/

/-- A normalization-based commitment scheme.
    Bridge: Logic (proof normalization) ↔ Cryptography (commitment scheme).

    The commitment scheme has two properties:
    1. **Binding** (from Church-Rosser): the committed value has a unique opening
    2. **Hiding** (from hardness): the committed value is hard to determine -/
structure NormCommitment (α : Type*) [CanonicalizingRS α] where
  /-- Commit function: submit a proof term as commitment. -/
  commit : α → α
  /-- Reveal function: normalize to open the commitment. -/
  reveal : α → α
  /-- Commitment preserves reducibility. -/
  commit_reduces : ∀ x, reduces (commit x) x
  /-- Reveal produces normal forms. -/
  reveal_normal : ∀ x, IsNormalForm (reveal x)
  /-- Reveal is the normal form. -/
  reveal_reduces : ∀ x, reduces x (reveal x)

namespace NormCommitment

variable {α : Type*} [CanonicalizingRS α]

/-- **Binding property from Church-Rosser confluence.**
    If two openings both reduce from the same commitment, they are identical.
    Bridge: Logic (unique normal forms) → Cryptography (computational binding). -/
theorem binding_from_confluence (nc : NormCommitment α)
    (c : α) (v₁ v₂ : α)
    (hv₁_nf : IsNormalForm v₁)
    (hv₂_nf : IsNormalForm v₂)
    (hv₁ : reduces c v₁)
    (hv₂ : reduces c v₂) : v₁ = v₂ :=
  normalForm_unique c v₁ v₂ hv₁ hv₂ hv₁_nf hv₂_nf

/-- **Binding via canonical forms.**
    Every commitment has exactly one valid opening.
    Bridge: deterministic binding — no equivocation possible. -/
theorem unique_opening (nc : NormCommitment α) (x : α) :
    ∃! v, reduces x v ∧ IsNormalForm v :=
  CanonicalizingRS.unique_canonical_form x

/-- **Reveal is deterministic.**
    Different paths to the same commitment yield the same reveal.
    Bridge: the commitment scheme is perfectly binding. -/
theorem reveal_deterministic (nc : NormCommitment α) (x y : α)
    (hxy : reduces x y) :
    nc.reveal x = nc.reveal y := by
  have hx := nc.reveal_reduces x
  have hy := nc.reveal_reduces y
  have hx_nf := nc.reveal_normal x
  have hy_nf := nc.reveal_normal y
  -- x →* reveal x and x →* y →* reveal y
  have h_x_to_ry : reduces x (nc.reveal y) := reduces_trans hxy hy
  exact normalForm_unique x (nc.reveal x) (nc.reveal y) hx h_x_to_ry hx_nf hy_nf

end NormCommitment

/-- **Hiding property** modeled as computational hardness of inversion.
    Bridge: PSPACE-hardness of normalization inversion → hiding property. -/
structure NormHidingProperty where
  /-- The hardness assumption for the normalization inversion. -/
  hardness : HardnessAssumption
  /-- The gap grows: increasing security parameter → better hiding. -/
  hiding_grows : ∀ M : ℕ, ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
    (M : ℤ) ≤ hardness.gapZ n

/-- Construct a hiding property from any hardness assumption. -/
def NormHidingProperty.fromHardness (ha : HardnessAssumption) : NormHidingProperty where
  hardness := ha
  hiding_grows := ha.gap_grows

/-! ## Part III: Proof-Object Zero-Knowledge Protocol -/

/-- A proof-object zero-knowledge protocol.
    Bridge: Logic (proof verification) ↔ Cryptography (zero-knowledge proofs).

    - **Completeness**: honest provers always convince honest verifiers
    - **Soundness**: false claims never pass verification
    - **Zero-Knowledge**: transcripts reveal nothing beyond validity -/
structure ProofObjectZK (α : Type*) [CanonicalizingRS α] where
  /-- The claim type. -/
  ClaimType : Type
  /-- Whether a claim is true (provable). -/
  isProvable : ClaimType → Prop
  /-- Generate a proof for a provable claim. -/
  prove : (c : ClaimType) → isProvable c → α
  /-- Verify a proof for a claim. -/
  verify : ClaimType → α → Prop
  /-- Verification checks normal form. -/
  verify_checks_nf : ∀ c a, verify c a → IsNormalForm a
  /-- Honest proofs are in normal form. -/
  prove_normal : ∀ c (h : isProvable c), IsNormalForm (prove c h)
  /-- Completeness: honest proofs verify. -/
  completeness : ∀ c (h : isProvable c), verify c (prove c h)
  /-- Soundness: verified proofs imply provability. -/
  soundness : ∀ c a, verify c a → isProvable c

namespace ProofObjectZK

variable {α : Type*} [CanonicalizingRS α]

/-- **Completeness theorem**: honest provers always succeed.
    Bridge: normalization correctness → protocol completeness. -/
theorem honest_prover_succe
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Merkle Tree Hashing and Collision Resistance

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
the only failure mode — so the conject
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
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
