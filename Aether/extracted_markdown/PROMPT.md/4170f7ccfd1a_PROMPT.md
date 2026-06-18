## Assignment: Direction 1: Arithmetic Universality for Deep Compositions — The Tropical Composition Diagram as Combinatorial Invariant

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test.

---

### Research Direction

**Central Thesis:** The combinatorial complexity of deep ReLU networks—measured by their linear region decomposition—is an *arithmetic invariant* of the weight matrices' valuation profiles. Two networks with the same tropical composition diagram have isomorphic active-set complexes, regardless of the specific coefficient values. This extends the single-layer arithmetic universality principle to the architecturally relevant multi-layer setting, establishing that the "effective complexity" of a deep network is determined by tropical algebra, not Euclidean geometry.

**Precise Theorem Statements with Lean 4 Type Signatures:**

```lean
-- Novel Definition 1: Tropical Composition Diagram
-- Encodes the valuation profile and sign type of each layer in a k-layer network
structure TropicalCompositionDiagram (k : ℕ) (dims : Fin (k + 1) → ℕ) where
  val_profiles : ∀ i : Fin k, Matrix (Fin (dims i)) (Fin (dims (i + 1))) ℕ
  sign_types : ∀ i : Fin k, SignType (dims i) (dims (i + 1))
  -- val_profiles records the p-adic valuation of each weight entry
  -- sign_types records the sign pattern (positive/negative/zero) of each entry

-- Novel Definition 2: Active-Set Complex
-- The simplicial complex whose faces are sets of neurons that can be simultaneously active
def ActiveSetComplex {k : ℕ} {dims : Fin (k + 1) → ℕ}
    (Ws : ∀ i : Fin k, Matrix (Fin (dims i)) (Fin (dims (i + 1))) ℝ) :
    SimplicialComplex (Fin (∑ i : Fin k, dims (i + 1))) :=
  -- A face is a subset S of neurons such that there exists an input x
  -- where exactly the neurons in S are active (output strictly positive)
  { faces := {S | ∃ x, ∀ (i : Fin k) (j : Fin (dims (i + 1))),
      j ∈ S.layer i ↔ (Ws i * ... * x)_j > 0} }

-- Novel Definition 3: Tropical Composition (max-plus matrix multiplication)
def tropicalCompose {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ≥0∞)
    (B : Matrix (Fin n) (Fin p) ℝ≥0∞) :
    Matrix (Fin m) (Fin p) ℝ≥0∞ :=
  fun i j => ⨆ (k : Fin n), A i k + B k j  -- max-plus: max over k of A_ik + B_kj

-- THEOREM 1: Tropical composition preserves valuation equivalence
-- If two networks have valuation-equivalent weights at each layer,
-- their tropical compositions are valuation-equivalent
theorem tropicalCompose_preserves_valuation
    {k : ℕ} {dims : Fin (k + 1) → ℕ}
    {Ws₁ Ws₂ : ∀ i : Fin k, Matrix (Fin (dims i)) (Fin (dims (i + 1))) ℝ}
    (h_val : ∀ i, ValuationEquivalent (Ws₁ i) (Ws₂ i))
    (h_sign : ∀ i, SameSignType (Ws₁ i) (Ws₂ i)) :
    ValuationEquivalent (tropicalNetworkCompose Ws₁) (tropicalNetworkCompose Ws₂) := by
  -- Proof by induction on k, using the fact that max-plus multiplication
  -- respects valuation equivalence when sign types agree
  sorry

-- THEOREM 2 (Main Result): Active-Set Complex Isomorphism
-- The active-set complexes of two networks with the same tropical composition
-- diagram are isomorphic as simplicial complexes
theorem activeComplex_iso_of_sameCompositionDiagram
    {k : ℕ} {dims : Fin (k + 1) → ℕ}
    {Ws₁ Ws₂ : ∀ i : Fin k, Matrix (Fin (dims i)) (Fin (dims (i + 1))) ℝ}
    (h_diag : tropicalCompositionDiagram Ws₁ = tropicalCompositionDiagram Ws₂) :
    Nonempty (ActiveSetComplex Ws₁ ≃ ActiveSetComplex Ws₂) := by
  -- The isomorphism is induced by the bijection on active neuron sets
  -- which exists because valuation-equivalent + same-sign-type implies
  -- the same neurons are active for the same inputs
  sorry

-- THEOREM 3 (Cross-Domain): Active-Set Complex as Matroid
-- The active-set complex of a ReLU network is the independence complex
-- of a matroid; isomorphic complexes yield isomorphic matroids
-- This connects tropical geometry to matroid theory
theorem activeComplex_is_matroid
    {k : ℕ} {dims : Fin (k + 1) → ℕ}
    {Ws : ∀ i : Fin k, Matrix (Fin (dims i)) (Fin (dims (i + 1))) ℝ} :
    IsMatroid (neuronSet Ws) (activeSetComplex Ws).faces := by
  -- The exchange axiom follows from the convexity of linear regions:
  -- If neurons i,j can be simultaneously active, and i is active alone,
  -- then there exists a region where i and some other neuron are active
  sorry

-- THEOREM 4: Linear Region Count as Arithmetic Invariant
-- The number of linear regions depends only on the tropical composition diagram
-- This is the Euler characteristic of the active-set complex
theorem linearRegionCount_is_arithmetic_invariant
    {k : ℕ} {dims : Fin (k + 1) → ℕ}
    {Ws₁ Ws₂ : ∀ i : Fin k, Matrix (Fin (dims i)) (Fin (dims (i + 1))) ℝ}
    (h_diag : tropicalCompositionDiagram Ws₁ = tropicalCompositionDiagram Ws₂) :
    linearRegionCount Ws₁ = linearRegionCount Ws₂ := by
  -- Follows from Theorem 2: isomorphic simplicial complexes have
  -- the same Euler characteristic, which counts the linear regions
  sorry
```

**Proof Strategies:**

**Strategy A (Direct Combinatorial — Face Lattice Approach):**
Construct an explicit isomorphism between the face lattices of the active-set complexes. For each linear region R₁ of network 1, define the corresponding region R₂ of network 2 as the set of inputs where the same combinatorial pattern of neuron activations occurs. The key lemma: if two weight matrices are valuation-equivalent with the same sign type, the function mapping each input to its activation pattern is a piecewise-linear bijection that preserves the face lattice structure. *Weakness:* The piecewise-linear bijection requires careful construction across layers, and the induction on k is not straightforward because the bijection at layer i depends on the bijection at layer i-1.

**Strategy B (Subdivision-Theoretic — Mixed Subdivision Approach) [RECOMMENDED]:**
Use the theory of mixed subdivisions of Minkowski sums. The tropical composition of k layers gives rise to a mixed subdivision of the Minkowski sum P₁ + P₂ + ... + Pₖ, where Pᵢ is the Newton polytope of layer i. The combinatorial type of this mixed subdivision—which determines the active-set complex—depends only on the valuations (not the coefficients). This follows from the fundamental theorem of tropical geometry: the tropicalization of a variety depends only on its initial ideals, which are determined by valuations. *Strength:* Directly leverages the existing catalog theorem `tropMax_eq_of_valuationEquivalent` and connects to the well-developed theory of secondary polytopes and regular subdivisions. The key technical lemma is that mixed subdivisions of Minkowski sums are determined by the subdivisions of the summands.

**Strategy C (Matroid-Theoretic — Independence Complex Approach):**
Define a matroid structure on the set of neurons where independent sets are subsets that can be simultaneously active. Prove that this matroid is a *valuation matroid*—its structure depends only on the valuations of the weight matrices. Since matroid isomorphism is stronger than simplicial complex isomorphism (it preserves the exchange axiom), this gives a stronger result. *Strength:* Connects to the rich theory of matroid representability and provides tools from matroid theory (e.g., the Tutte polynomial as a more refined invariant than just the region count). *Weakness:* Proving the exchange axiom requires understanding the geometry of linear regions at a level of detail that may be hard to formalize.

**Recommendation:** Strategy B is most promising because (1) it directly builds on the catalog theorems, (2) the theory of mixed subdivisions is well-established and provides clean proof tools, and (3) it makes the connection to tropical geometry explicit rather than implicit.

**Cross-Domain Connections:**

1. **Tropical Geometry ↔ Matroid Theory:** The active-set complex is the independence complex of a matroid. The matroid is representable over the tropical semiring, and its isomorphism class is determined by the tropical composition diagram. This connects the complexity of deep networks to the classification of tropical matroids—a subject at the frontier of algebraic combinatorics.

2. **Tropical Geometry ↔ Algebraic Topology:** The number of linear regions is the Euler characteristic of the active-set complex, which is a topological invariant. Two networks with the same tropical composition diagram have homotopy-equivalent decision boundaries. This means the "topological complexity" of a neural network is an arithmetic invariant.

3. **Tropical Geometry ↔ Information Theory:** The tropical composition diagram can be viewed as a kind of "capacity region" for the network—each face of the active-set complex corresponds to an operating point where certain neurons are active. The isomorphism theorem says that networks with the same diagram have the same capacity region, connecting to network information theory.

**Catalog References to Build On:**
- `Tropical/ArithmeticUniversality/Defs.lean` — Theorems `tropMax_eq_of_valuationEquivalent`, `activeComplex_bij_of_sameSignType`
- Build on `tropMax_eq_of_valuationEquivalent` to show that tropical composition (iterated max-plus multiplication) preserves valuation equivalence
- Build on `activeComplex_bij_of_sameSignType` to show that the bijection extends to an isomorphism of simplicial complexes

**Falsifiable Conjecture with Computational Test:**

**Conjecture (Mixed Subdivision Universality):** For two k-layer ReLU networks with the same tropical composition diagram, their mixed subdivisions are combinatorially equivalent—meaning there exists a bijection between their cells that preserves the face incidences and the combinatorial types of each cell. This is stronger than just having the same number of linear regions; it requires the same *incidence structure*.

**Test:** (1) Construct pairs of 3-layer networks with 4 neurons per layer, identical valuation profiles but different coefficients (e.g., replace each weight w with w + ε·rand() for small ε). (2) Compute the linear region decomposition numerically using the polyhedral tools of Serra et al. (2018). (3) Build the Hasse diagram of the face lattice for each network's active-set complex. (4) Check whether the Hasse diagrams are isomorphic as posets. A single pair with non-isomorphic Hasse diagrams refutes the conjecture. The test should be run for at least 100 random coefficient perturbations at each of 10 different valuation profiles to achieve statistical significance.

**Revolutionary Significance:**

This work establishes that the combinatorial complexity of deep neural networks—arguably their most important structural property—is an *arithmetic invariant* of their weight matrices, not a geometric one. This has three profound implications:

1. **For theory:** It provides a rigorous foundation for understanding why certain architectures are more expressive than others, independent of the specific trained weights. The "effective complexity" is a property of the architecture's tropical type.

2. **For practice:** It suggests that network compression and pruning should preserve the tropical composition diagram, not just the weight magnitudes. A network can be "tropically compressed" by rounding weights to their valuations while preserving the active-set complex.

3. **For foundations:** It opens the door to a *tropical information theory* where the capacity of a neural network is measured by the entropy of its active-set complex distribution, and the data processing inequality takes a tropical form.

**Mandatory Deliverables:**

(a) A structured FUTURE_DIRECTIONS.md with 3-5 testable scientific hypotheses—each a falsifiable conjecture with a clear computational test.

(b) A RESEARCH_PAPER.md that is a STANDALONE scientific document—someone reading ONLY this paper must understand what was discovered, why it matters, and what to investigate next.

(c) An ARTICLE.md written in Scientific American style—engaging, accessible, explaining the discovery to a broad audience.

(d) A verified algorithm or computational method for computing the tropical composition diagram and verifying active-set complex isomorphism.

(e) A demo.py that demonstrates the result interactively—given two networks with the same tropical composition diagram, visualize their active-set complexes and verify isomorphism.

### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Pythagorean
Research mode: prove
