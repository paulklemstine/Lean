# Future Directions: Theorem Embeddings from Syntax

## Overview

The TheorySpec extraction framework establishes a foundation for treating proven theorems as structured, machine-actionable data. The following directions represent breakthrough-level research opportunities that build directly on this work.

---

## Direction 1: Generalized Extraction for Arbitrary Algebraic Structures

**Hypothesis:** The `GeneralTheorySpec` framework can be extended to extract specifications from theorems involving semirings, lattices, metric spaces, and categories — not just preorders.

**Concrete Next Steps:**
- Define `AlgebraicTheorySpec` parametrized by a signature (operations + axioms) rather than a single preorder.
- Implement an extractor that recognizes theorem shapes involving ring inequalities (`a * b ≤ c * d`), norm bounds (`‖f x‖ ≤ K * ‖x‖`), and metric estimates (`dist (f x) (f y) ≤ L * dist x y`).
- Prove a generalized `extraction_pipeline_correct` theorem for each algebraic signature.
- **Validation:** Apply to Lipschitz bounds, operator norm estimates, and concentration inequalities in Mathlib.

**Cross-Domain Connections:** This connects to universal algebra, Lawvere theories, and algebraic specification languages (e.g., OBJ, Maude). The categorical semantics of extraction becomes a functor from a syntactic category of theorem declarations to a category of algebraic specifications.

**Expected Impact:** A 10x increase in the number of theorems amenable to automatic extraction, covering the majority of quantitative results in analysis, algebra, and geometry.

---

## Direction 2: Automatic Theorem Clustering by Extracted Invariant Structure

**Hypothesis:** Theorems with structurally similar extracted `TheorySpec`s (same invariant shape, comparable bounds, related witness predicates) form natural clusters that correspond to known mathematical theories.

**Concrete Next Steps:**
- Define a distance metric on `TheorySpec` objects based on:
  - Type-level similarity of carrier types (e.g., both over `ℕ`, both over metric spaces).
  - Structural similarity of invariant functions (e.g., both polynomial, both exponential).
  - Numerical proximity of lower bounds.
- Implement a clustering algorithm (agglomerative or spectral) over extracted specs.
- Apply to the full bridge theorem catalog (490+ files) and validate that clusters correspond to recognized mathematical domains.
- **Proof Target:** Prove that specs within the same cluster can be composed via `TheorySpec.compose`, yielding combined lower bounds.

**Cross-Domain Connections:** Connects to topological data analysis (persistent homology of theorem spaces), knowledge graph construction, and mathematical ontology. The distance metric on specs is itself a formal mathematical object that can be studied.

**Expected Impact:** An automated "table of contents" for formal libraries, where theorems are organized by semantic content rather than file location.

---

## Direction 3: Conjecture Transfer Between Extracted TheorySpecs

**Hypothesis:** If two `TheorySpec`s have the same witness predicate structure but different invariants, and one achieves a tight lower bound, then the other likely has a similar tight bound — and this can be formalized as a meta-theorem about transferability.

**Concrete Next Steps:**
- Define `TheorySpecMorphism` refinements that preserve witness structure while transforming invariants.
- Prove that morphisms between specs preserve the lower-bound property: if `T₁.lowerBound ≤ T₁.inv x` and there is a morphism `T₁ → T₂`, then bounds transfer.
- Implement a conjecture generator: given a spec `T₁` with a known tight bound and a related spec `T₂` with an unknown bound, propose `T₂.lowerBound ≥ g(T₁.lowerBound)` for computable `g`.
- **Validation:** Use depth obstruction bounds (topology/ML) to generate conjectures about sample complexity bounds (learning theory) and verify or refute computationally.

**Cross-Domain Connections:** This is the formal analogue of analogical reasoning in AI. It connects to transfer learning (in ML), functorial semantics (in category theory), and dimensional analysis (in physics). The "transfer functor" between spec categories is a new mathematical object.

**Expected Impact:** Machine-generated conjectures that bridge distant mathematical domains, reducing the human effort needed to discover cross-domain connections.

---

## Direction 4: Verified Theorem Search Engine Keyed by Semantic Patterns

**Hypothesis:** A search engine indexed by extracted `TheorySpec` metadata can answer queries like "find all theorems that give a lower bound of at least 2^n on a counting function" — and return only verified, semantically correct results.

**Concrete Next Steps:**
- Build a `TheorySpecIndex` data structure that maps (carrier type, bound magnitude, invariant shape) triples to theorem declarations.
- Implement a query language: `search(carrier = ℕ, bound ≥ 100, invariant ~ polynomial)`.
- Prove index correctness: every returned theorem genuinely satisfies the query predicate.
- **Deployment:** Run the extractor over the full Mathlib library (200,000+ declarations) and build a searchable index.
- Define `TheorySpecQuery` as a formal structure and prove that query evaluation is sound.

**Cross-Domain Connections:** Connects to information retrieval, database theory, and formal methods. The index is a verified data structure in the sense of verified programming. The query language is a domain-specific language for mathematical search.

**Expected Impact:** A practical tool for working mathematicians: "I need a lower bound on chromatic number — what's in the library?" becomes a computable query.

---

## Direction 5: Categorical Semantics of Theorem Extraction as a Functor

**Hypothesis:** The extraction pipeline `mkTheorySpecOfLowerBoundTheorem` is the object map of a functor from a category of theorem declarations (with proof-preserving morphisms) to a category of `TheorySpec` objects (with `TheorySpecMorphism`s).

**Concrete Next Steps:**
- Define the source category `TheoremDecl` with:
  - Objects: theorem declarations of lower-bound type.
  - Morphisms: proof transformations (e.g., strengthening hypotheses, weakening conclusions).
- Define the target category `TheorySpecCat` with:
  - Objects: `TheorySpec` values.
  - Morphisms: `TheorySpecMorphism` values.
- Prove that `mkTheorySpecOfLowerBoundTheorem` is functorial:
  - Preserves identity: `extract(id) = TheorySpecMorphism.id` (already proven as `extraction_is_section`).
  - Preserves composition: `extract(g ∘ f) = extract(g) ∘ extract(f)`.
- Investigate whether the functor has adjoints (left adjoint = "most general theorem from a spec", right adjoint = "most specific spec from a theorem").

**Cross-Domain Connections:** This is a new application of category theory to proof theory and knowledge representation. It connects to the Curry-Howard-Lambek correspondence (propositions-as-types-as-objects), topos theory (where logical operations become geometric morphisms), and the emerging field of categorical data science.

**Expected Impact:** A mathematical foundation for "theorem compilers" — tools that systematically transform verified mathematical knowledge from one representation to another, with correctness guaranteed by functoriality. This could underpin a new generation of formal mathematical AI systems.

---

## Team Directive

Each direction above should be pursued by a team that:
1. **Formulates precise hypotheses** as formal theorem statements.
2. **Builds proof skeletons** with helper lemmas before attempting full proofs.
3. **Validates computationally** using `#eval` and Python prototypes before committing to formal proofs.
4. **Iterates on decomposition** — if a proof attempt fails, decompose into smaller lemmas rather than retrying.
5. **Cross-references** other directions: discoveries in one direction often unlock progress in others.
6. **Updates the knowledge base** by adding new `TheorySpec` embeddings to the catalog registry.

The goal is a self-sustaining cycle: extract specs → cluster → transfer conjectures → prove → add to library → extract more specs.
