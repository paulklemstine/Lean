# Future Directions: Proof-Theoretic Novelty Geometry

## Overview

The depth gap framework establishes the first computable, machine-checkable notion of conceptual novelty for mathematical artifacts. This document outlines five concrete breakthrough research directions opened by this work, each with specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Graph-Labeled Conceptual Path Theory

### Hypothesis
The L¹ metric depth gap is a coarse shadow of a richer graph-theoretic invariant where edges are typed by specific conceptual transformations (definition introduction, type change, perspective shift, equivalence transport, specialization, generalization). The graph distance provides strictly finer novelty discrimination than the metric model.

### Proof Strategy
1. Define a finite directed graph on `TheoremProfile` (or a richer `Presentation` type) where each edge carries a `LeapKind` label.
2. Define `graphDepthGap` as the shortest path length from any corpus node to the target.
3. Prove `graphDepthGap ≥ profileDepthGap` (the metric model lower-bounds graph distance).
4. Construct explicit examples where the inequality is strict: profiles reachable in fewer metric steps but requiring more graph-typed leaps.
5. Prove a "path witness" theorem: every finite graph depth gap is realized by an explicit path of typed leaps.

### Key Technical Challenge
Formalizing shortest-path computation on finite graphs in Lean 4. The `SimpleGraph` library in Mathlib provides walk/path infrastructure that could be adapted.

### Cross-Domain Connection
This connects to **combinatorial optimization** and **category theory** — typed leaps can be viewed as morphisms in a category of mathematical presentations, making depth gap a functor to (ℕ, ≤).

---

## Direction 2: Compression–Novelty Duality

### Hypothesis
There exists a quantitative relationship between proof compression score and conceptual depth gap: highly compressible theorems (relative to a corpus) are necessarily derivative, but the converse fails. Specifically, for profiles with `compressionScore ≤ C · proofSize`, the depth gap is bounded by a function of `C` and the corpus geometry.

### Proof Strategy
1. Define a "compression ratio" `ρ(T) = T.compressionScore / T.proofSize` (using rational arithmetic).
2. Prove: if `ρ(T) ≤ ρ_max` for all corpus elements and `ρ(target) ≤ ρ_max`, then `depthGap ≤ f(ρ_max, |K|)`.
3. Construct counter-examples showing high depth gap with low compression ratio (novel but concise theorems).
4. Connect to the existing `compression_threshold_exists` theorem in `Core.lean` to show the compression threshold induces a derivativeness threshold.

### Key Technical Challenge
The relationship between syntactic compression and conceptual distance is non-trivial. Need to formalize what "compression relative to a corpus" means — possibly via Kolmogorov-style conditional complexity.

### Cross-Domain Connection
This directly connects to **information theory** (rate-distortion theory), **Kolmogorov complexity**, and **minimum description length** in machine learning.

---

## Direction 3: Ultrametric Novelty Geometry

### Hypothesis
Replacing the additive L¹ leap cost with a max-based (ultrametric) cost `ultraCost(A, B) = max(dist_defs, dist_types, dist_persp)` yields a novelty geometry with hierarchical clustering structure. In this geometry, the "novelty ball" around a corpus becomes a box rather than an L¹ ball, and the depth gap admits a tree-structured decomposition.

### Proof Strategy
1. Define `ultraLeapCost` using `max` instead of `+`.
2. Prove the ultrametric inequality: `ultraLeapCost(A, C) ≤ max(ultraLeapCost(A, B), ultraLeapCost(B, C))`.
3. Prove that `ultraDepthGap ≤ profileDepthGap` always holds (the ultrametric is coarser).
4. Show that the ultrametric depth gap induces a hierarchical clustering of the profile space, where clusters at each level correspond to "novelty classes."
5. Connect to the `UltrametricProofLearning` framework already in the codebase.

### Key Technical Challenge
The ultrametric inequality is easy to prove, but the interesting part is showing the hierarchical clustering gives meaningful mathematical structure — e.g., that novelty classes correspond to natural mathematical domain boundaries.

### Cross-Domain Connection
Connects to **p-adic analysis**, **phylogenetic trees**, **hierarchical Bayesian models**, and **tropical geometry**. The existing tropical threshold theorems in the codebase are natural companions.

---

## Direction 4: Extracting Profiles from Encoded Proof Syntax

### Hypothesis
A computable function `extractProfile : EncodedExpr → TheoremProfile` can be defined on a finite syntax of proof terms, such that the depth gap of extracted profiles is invariant under proof normalization (β-reduction, definitional unfolding).

### Proof Strategy
1. Define `EncodedExpr` as an inductive type capturing a fragment of the Calculus of Inductive Constructions (variables, applications, λ-abstractions, let-bindings, constants).
2. Define `extractProfile` by:
   - Counting `let`-bindings and new constant references → `defsIntroduced`
   - Counting universe polymorphism and type-family applications → `typeChanges`
   - Counting proof-irrelevance collapses and `Equiv`-based transports → `perspectiveShifts`
   - Measuring AST size → `proofSize`
   - Measuring DAG-compressed size → `compressionScore`
3. Prove that `extractProfile` respects β-reduction: if `e₁ ≈β e₂` then `extractProfile(e₁) = extractProfile(e₂)`.
4. Prove that the depth gap of extracted profiles is computable.

### Key Technical Challenge
This requires formalizing a meaningful fragment of proof syntax in Lean 4 at the object level (not using metaprogramming). The key is choosing a fragment rich enough to be interesting but simple enough for clean proofs.

### Cross-Domain Connection
Connects to **proof theory**, **type theory**, **program analysis**, and **software engineering metrics**. Could enable a "complexity analyzer" for proof assistants.

---

## Direction 5: Certified Evaluator for Machine-Generated Theorem Corpora

### Hypothesis
The depth gap framework can be compiled into a certified evaluator — a standalone executable that takes as input a corpus of theorem profiles and a list of candidate theorems, and outputs a certified novelty score for each candidate, with machine-checkable proofs that the classification is correct.

### Proof Strategy
1. Use Lean's `#eval` and `native_decide` infrastructure to make `computeProfileDepthGap` fully executable.
2. Define a `CertifiedClassification` structure pairing a classification with a proof witness:
   ```
   structure CertifiedClassification where
     target : TheoremProfile
     depth : ℕ
     classification : Bool  -- true = derivative
     witness : if classification then DerivativeFrom K T τ else ¬DerivativeFrom K T τ
   ```
3. Build a function `certifiedEvaluate : Finset TheoremProfile → TheoremProfile → ℕ → CertifiedClassification` that produces self-certifying results.
4. Prove that `certifiedEvaluate` always terminates and produces valid certificates.
5. Package as a command-line tool using Lean's `IO` monad.

### Key Technical Challenge
Making the evaluation performant for large corpora while maintaining proof certificates. May need to use decision procedures (`native_decide`) for efficiency.

### Cross-Domain Connection
Connects to **certified compilation**, **proof-carrying code**, **automated theorem proving benchmarks**, and **responsible AI evaluation**. Could become infrastructure for evaluating LLM-based theorem provers.

---

## Implementation Roadmap

| Quarter | Direction | Key Milestone |
|---------|-----------|---------------|
| Q1 | Direction 1 | Graph distance formalization, path witness theorem |
| Q1 | Direction 5 | Prototype certified evaluator with `native_decide` |
| Q2 | Direction 2 | Compression–novelty duality theorem |
| Q2 | Direction 3 | Ultrametric depth gap, connection to tropical geometry |
| Q3 | Direction 4 | Encoded syntax type, profile extraction function |
| Q3 | All | Integration: single framework supporting all five invariants |
| Q4 | All | Publication-ready paper, open-source tool release |

---

## Cross-Cutting Themes

### Theorem Corpus as Metric Space
All five directions share the perspective of viewing a theorem corpus as a finite metric space. This opens connections to:
- **Persistent homology**: compute topological features of the novelty landscape
- **Optimal transport**: measure the "distance" between two corpora
- **Geometric group theory**: study symmetries of the novelty geometry

### Benchmarking Infrastructure
Directions 1 and 5 together would produce a complete benchmarking pipeline:
1. Extract profiles from proof terms (Direction 4)
2. Compute typed graph distance (Direction 1)
3. Certify classification (Direction 5)
4. Report novelty statistics (already implemented in Python)

### Theoretical Foundations
Directions 2 and 3 deepen the mathematical theory:
- Compression duality connects novelty to information content
- Ultrametric geometry reveals hierarchical structure
- Together they suggest a "spectral theory of novelty" where eigenvalues of the distance matrix capture fundamental scales of conceptual variation.
