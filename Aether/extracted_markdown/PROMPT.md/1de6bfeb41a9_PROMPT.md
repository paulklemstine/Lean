
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

**Title**: Close Proofs: Linear Merkle–Damgård collision-resistance theory
**Domain**: Algebra
**Mathematical framing**: Cycle 78c4e8f5 (Q=0.477) proved 1483 theorems in Novelty but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: Merkle Tree Hashing and Collision Resistance

This cycle extended the linear Merkle–Damgård collision-resistance theory
(`Cryptography.MerkleDamgard`: `merkleDamgard`, `foldl_join
Research domain: Algebra
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/MerkleDamgardAction.lean
/-
  Merkle–Damgård as a Monoid Action: an Algebra ⇄ Cryptography bridge.

  The catalog file `Cryptography.MerkleDamgard` (`CryptoHash`) develops the linear
  Merkle–Damgård collision-resistance theory: `merkleDamgard`, `merkleDamgard_append`,
  `foldl_joint_injective`, `compress_injective_md_injective`,
  `md_collision_implies_compress_collision`, etc.

  This file *generalizes* that theory by reinterpreting it algebraically.  The catalog
  proves facts about a *fixed* initialization vector `iv`.  We instead view a message
  `m : List β` as the **state transformation** `a ↦ merkleDamgard f a m`, i.e. an element
  of `Function.End α`.  The domain-extension lemma `merkleDamgard_append` then becomes a
  genuine algebraic statement: message concatenation is *anti*-homomorphic to composition
  of state transformations, so words of the free monoid `FreeMonoid β` act on the state
  space.  We package this as a `MonoidHom`

      mdHom f : FreeMonoid β →* (Function.End α)ᵐᵒᵖ

  and show the catalog's joint injectivity (`foldl_joint_injective`) upgrades to the
  statement that this action is *faithful on words of a fixed length* whenever the
  compression function is injective — a strictly stronger, `iv`-independent form of the
  catalog's `compress_injective_md_injective`.

  Cross-domain content: free monoids / monoid homomorphisms (Algebra) applied to hash
  collision resistance (Cryptography).
-/

import Mathlib
import Cryptography.MerkleDamgard

open CryptoHash

namespace MerkleDamgardAction

variable {α β : Type*}

/-! ## The state-transformation action -/

-- !-- Lab Notebook: mdEnd / the action viewpoint -- !--
-- !-- Hypothesis: The catalog's `merkleDamgard_append` is secretly the statement that
--     messages act on the state space by composition; making the action explicit should
--     turn `iv`-fixed collision lemmas into `iv`-free algebraic ones. -- !--
-- !-- Result: Confirmed. `mdEnd f m := fun a => merkleDamgard f a m` lands in
--     `Function.End α`, and append becomes `mdEnd (m₁ ++ m₂) = mdEnd m₂ * mdEnd m₁`. -- !--
-- !-- Insight: The composition order is *reversed* (process m₁ first, then m₂), so the
--     natural target is the *opposite* monoid `(Function.End α)ᵐᵒᵖ`, not `Function.End α`. -- !--
-- !-- Failure analysis: A first attempt targeting `Function.End α` directly forced the
--     wrong multiplication order in `map_mul'`; switching to `ᵐᵒᵖ` fixed it cleanly. -- !--
-- !-- End Lab Notebook -- !--

/-- The state transformation induced by processing a message `m` through the
    Merkle–Damgård compression `f`: it sends a chaining value `a` to the hash
    `merkleDamgard f a m`.  Lives in `Function.End α` (the monoid of self-maps under
    composition). -/
def mdEnd (f : α → β → α) (m : List β) : Function.End α := fun a => merkleDamgard f a m

@[simp] theorem mdEnd_apply (f : α → β → α) (m : List β) (a : α) :
    mdEnd f m a = merkleDamgard f a m := rfl

-- !-- comment: empty message = identity transformation; nil/cons inherited from catalog. -- !--

/-- The empty message acts as the identity transformation. -/
@[simp] theorem mdEnd_nil (f : α → β → α) : mdEnd f ([] : List β) = 1 := rfl

/-- **Anti-homomorphism / action law.**  Concatenating messages composes their state
    transformations in reverse order.  This is the algebraic incarnation of the catalog's
    `merkleDamgard_append` (domain extension). -/
theorem mdEnd_append (f : α → β → α) (m₁ m₂ : List β) :
    mdEnd f (m₁ ++ m₂) = mdEnd f m₂ * mdEnd f m₁ := by
  funext a
  simp only [mdEnd, Function.End.mul_def, Function.comp_apply, merkleDamgard_append]

/-! ## The Merkle–Damgård monoid homomorphism -/

-- !-- Lab Notebook: mdHom -- !--
-- !-- Hypothesis: `mdEnd` extends to a monoid homomorphism out of the free monoid on
--     blocks, packaging the entire MD construction as a single algebraic object. -- !--
-- !-- Result: Proved. `mdHom f : FreeMonoid β →* (Function.End α)ᵐᵒᵖ`, with
--     `map_one'` from `mdEnd_nil` and `map_mul'` from `mdEnd_append` + `op_mul`. -- !--
-- !-- Insight: Under this hom, "collision resistance" = "injectivity of mdHom on a fixed
--     length", a clean algebraic reformulation of the cryptographic property. -- !--
-- !-- Failure analysis: `FreeMonoid β` is definitionally `List β` but multiplication only
--     simp-normalizes via `FreeMonoid.toList_mul`; routing through `.toList` was needed. -- !--
-- !-- End Lab Notebook -- !--

/-- The Merkle–Damgård construction as a single algebraic object: a monoid homomorphism
    from the free monoid of message blocks to the *opposite* of the endomorphism monoid of
    the state space.  This realizes domain extension (`merkleDamgard_append`) as
    `map_mul`. -/
def mdHom (f : α → β → α) : FreeMonoid β →* (Function.End α)ᵐᵒᵖ where
  toFun := fun m => MulOpposite.op (mdEnd f m.toList)
  map_one' := by
    show MulOpposite.op (mdEnd f (FreeMonoid.toList 1)) = 1
    rw [FreeMonoid.toList_one]
    rfl
  map_mul' := by
    intro x y
    show MulOpposite.op (mdEnd f (FreeMonoid.toList (x * y))) = _
    rw [FreeMonoid.toList_mul, mdEnd_append, MulOpposite.op_mul]

/-- Evaluating the homomorphism recovers the Merkle–Damgård hash: `mdHom f` applied to a
    word `m`, unwrapped from the opposite monoid and applied to `iv`, is exactly
    `merkleDamgard f iv m`. -/
@[simp] theorem mdHom_apply (f : α → β → α) (m : FreeMonoid β) (iv : α) :
    (mdHom f m).unop iv = merkleDamgard f iv m.toList := rfl

/-! ## Faithfulness = collision resistance (iv-independent upgrade) -/

-- !-- Lab Notebook: mdEnd_injOn_length -- !--
-- !-- Hypothesis: If `f` is injective then the action is *faithful on equal-length words*:
--     `mdEnd f m₁ = mdEnd f m₂` with `|m₁| = |m₂|` forces `m₁ = m₂`.  This is stronger
--     than the catalog's `compress_injective_md_injective`, which fixes a single `iv`. -- !--
-- !-- Result: Proved by evaluating the function equality at an arbitrary state `a`
--     (needs `Nonempty α`) and invoking the catalog lemma `foldl_joint_injective`. -- !--
-- !-- Insight: Catalog injectivity is "for some/this iv"; faithfulness of the action is
--     "as functions of all iv simultaneously" — the action language makes the upgrade
--     a one-line evaluation rather than a new induction. -- !--
-- !-- Failure analysis: `Nonempty α` is genuinely required: over `α = Empty` every map is
--     vacuously equal, so the action is never faithful regardless of `f`. -- !--
-- !-- End Lab Notebook -- !--

/-- **Main theorem (faithful action ⇒ collision resistance, iv-free form).**
    If the compression function `f` is injective (as a function of the pair) and the state
    space is nonempty, then equal-length messages inducing the *same state transformation*
    must be equal.  This generalizes the catalog's `compress_injective_md_injective`
    from a single fixed `iv` to "for all `iv` simultaneously". -/
theorem mdEnd_injOn_length [Nonempty α] {f : α → β → α}
    (hf : Function.Injective (Function.uncurry f))
    {m₁ m₂ : List β} (hlen : m₁.length = m₂.length)
    (heq : mdEnd f m₁ = mdEnd f m₂) : m₁ = m₂ := by
  obtain ⟨a⟩ := (inferInstance : Nonempty α)
  have hpt : m₁.foldl f a = m₂.foldl f a := congrFun heq a
  exact (foldl_joint_injective hf hlen hpt).2

/-- Corollary in homomorphism language: on words of a fixed length, `mdHom f` is injective
    whenever `f` is injective and the state space is nonempty. -/
theorem mdHom_injOn_length [Nonempty α] {f : α → β → α}
    (hf : Function.Injective (Function.uncurry f))
    {m₁ m₂ : FreeMonoid β} (hlen : m₁.toList.length = m₂.toList.length)
    (heq : mdHom f m₁ = mdHom f m₂) : m₁ = m₂ := by
  have : mdEnd f m₁.toList = mdEnd f m₂.toList :=
    MulOpposite.op_injective.eq_iff.mp heq
  exact FreeMonoid.toList.injective (mdEnd_injOn_length hf hlen this)

/-! ## Collisions are closed under common suffixes -/

-- !-- Lab Notebook: md_collision_closed_under_suffix -- !--
-- !-- Hypothesis: Any Merkle–Damgård collision surv
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Merkle–Damgård as a Monoid Action

New file this cycle: `Catalog/Algebra/MerkleDamgardAction.lean`
(module `Algebra.MerkleDamgardAction`), an Algebra ⇄ Cryptography bridge built on the
catalog file `Cryptography.MerkleDamgard` (`CryptoHash`).

## Synthesis

The catalog's linear Merkle–Damgård theory (`merkleDamgard`, `merkleDamgard_append`,
`foldl_joint_injective`, `compress_injective_md_injective`,
`md_collision_implies_compress_collision`, `md_strengthen_injective`) reasons about a
*fixed* initialization vector. The structural insight of this cycle is that those results
are shadows of a single algebraic object: a message is a **state transformation**
`a ↦ merkleDamgard f a m`, an element of `Function.End α`. Under this lens the catalog's
domain-extension lemma `merkleDamgard_append` is exactly the statement that concatenation
of messages composes transformations *in reverse order*, so the free monoid `FreeMonoid β`
of message blocks acts on the state space. We packaged this as a genuine monoid
homomorphism `mdHom f : FreeMonoid β →* (Function.End α)ᵐᵒᵖ` (the opposite monoid is forced
by the reversed composition order — our first failed attempt targeted `Function.End α`
directly and the multiplication order in `map_mul'` was wrong).

With the algebra in place, two upgrades fell out almost for free. First, "collision
resistance" becomes "faithfulness of the action": `mdEnd_injOn_length` shows that for
injective `f` over a nonempty state space, equal-length messages inducing the *same*
transformation must be equal — an `iv`-independent strengthening of the catalog's
single-`iv` `compress_injective_md_injective`. Second, the Critic found that the converse is
**false**: `converse_faithful_not_imply_injective` exhibits a nonempty state space and a
non-injective compression whose action is nevertheless faithful on equal-length words
(over a one-block alphabet, equal-length words are automatically equal, so faithfulness is
vacuous). This pins down precisely why faithfulness is weaker than injectivity: the action
sees `f` only through *reachable* chaining values.

Finally we ran the generalization loop one level up the structural ladder: linear MD is the
path-graph special case of binary **Merkle tree** hashing. `treeHash_injOn_shape` proves
collision resistance for trees of a fixed shape, the free-*magma* analogue of
`foldl_joint_injective` (the same "shape/length determines structure, injectivity peels one
layer" induction recurs). The same-shape hypothesis is essential — dropping it makes the
statement false (a leaf can collide with a node) — which seeds the open domain-separation
conjecture below.

## Results Summary

- `mdEnd` / `mdEnd_apply` / `mdEnd_nil`: proved — define the message-as-state-transformation
  viewpoint and its identity law.
- `mdEnd_append`: proved — message concatenation composes transformations in reverse order
  (the algebraic form of `merkleDamgard_append`).
- `mdHom`: proved (`MonoidHom`) — packages the w
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
