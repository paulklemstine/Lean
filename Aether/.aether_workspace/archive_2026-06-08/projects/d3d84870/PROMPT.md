## Assignment: Direction 2: Stability of Torsion Barcodes Under Filtration Perturbations

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important. If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog. Check the catalog references to confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain (e.g., number theory + tropical geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### Research Direction

**Core Breakthrough Theorem (Torsion Barcode Stability via Primary Decomposition)**:

The classical algebraic stability theorem (Cohen-Steiner, Edelsbrunner, Harer 2007; Chazal, Cohen-Steiner, Glisse, Guibas, Oudot 2009) establishes that δ-interleaved persistence modules have barcodes matched within bottleneck distance δ. The obstruction for torsion is immediate: ℤ-modules need not decompose into interval summands (failure of Krull-Schmidt for non-local rings). However, the p-primary component Tor_p(H_n(F_t)) is a persistence module over the **field** ℤ/pℤ, and over a field the structure theorem for persistence modules guarantees interval decomposition. This is the key insight: **primary decomposition reduces torsion barcode stability to the classical stability theorem, one prime at a time.**

**Precise Theorem Statement**:

```
theorem torsion_barcode_stability {K L : SimplicialComplex} [Fintype K.vertices]
    {n : ℕ} (F : Filtration K) (G : Filtration L)
    {δ : ℝ≥0}
    (h_inter : InterleavingDist
      (torPersistenceModule F n : PersistenceModule ℤ)
      (torPersistenceModule G n) ≤ δ)
    (p : ℕ) (hp : p.Prime) :
    BottleneckDist
      (pTorsionBarcode F n p hp)
      (pTorsionBarcode G n p hp) ≤ δ := by
  sorry
```

where `pTorsionBarcode F n p hp` extracts the barcode of the p-primary component `Tor_p(H_n(F_t))` viewed as a persistence module over the field `ZMod p`, and `BottleneckDist` is the ∞-Wasserstein (bottleneck) distance on multisets of intervals.

**Corollary (Full Torsion Barcode Stability)**: Since finite simplicial complexes have finitely generated torsion, only finitely many primes appear, and the supremum over all primes is a maximum:

```
theorem full_torsion_barcode_stability {K L : SimplicialComplex} [Fintype K.vertices]
    {n : ℕ} (F : Filtration K) (G : Filtration L)
    {δ : ℝ≥0}
    (h_inter : InterleavingDist
      (torPersistenceModule F n : PersistenceModule ℤ)
      (torPersistenceModule G n) ≤ δ) :
    BottleneckDist
      (torsionBarcode F n)
      (torsionBarcode G n) ≤ δ := by
  sorry
```

**Secondary Theorem (Support Set Hausdorff Stability)**: A weaker but more structural result: the set of torsion birth indices is Hausdorff-stable.

```
theorem torsion_birth_Hausdorff_stability {K L : SimplicialComplex} [Fintype K.vertices]
    {n : ℕ} (F : Filtration K) (G : Filtration L)
    {δ : ℝ≥0}
    (h_inter : InterleavingDist
      (torPersistenceModule F n : PersistenceModule ℤ)
      (torPersistenceModule G n) ≤ δ) :
    EMetric.infDist
      (torsionBirthSet F n : Set ℝ≥0)
      (torsionBirthSet G n) ≤ δ := by
  sorry
```

**Cross-Domain Theorem (Torsion Barcode Entropy and Information Geometry)**:

Connect to information theory: define the *torsion entropy* of a filtration as the Shannon entropy of the distribution of bar lengths in the torsion barcode. Prove that this entropy is Lipschitz in the interleaving distance, establishing torsion barcodes as information-theoretically stable descriptors.

```
def torsionBarcodeEntropy {K : SimplicialComplex} [Fintype K.vertices]
    (F : Filtration K) (n : ℕ) : ℝ≥0 :=
  ShannonEntropy (torsionBarLengthDistribution F n)

theorem torsion_entropy_lipschitz {K L : SimplicialComplex} [Fintype K.vertices]
    {n : ℕ} (F : Filtration K) (G : Filtration L)
    {δ : ℝ≥0}
    (h_inter : InterleavingDist
      (torPersistenceModule F n : PersistenceModule ℤ)
      (torPersistenceModule G n) ≤ δ) :
    |torsionBarcodeEntropy F n - torsionBarcodeEntropy G n| ≤ C n * δ := by
  sorry
```

where `C n` depends only on the dimension `n` and the maximum torsion order appearing.

---

### Proof Strategy

**Strategy A (Primary Decomposition + Field Coefficient Reduction)** — MOST PROMISING:

1. **Primary decomposition**: For each prime p, the natural map `Tor(H_n(F_t)) → Tor_p(H_n(F_t))` given by the p-primary component is a morphism of persistence modules over ℤ. Show that the p-primary component `Tor_p(H_n(F_t))` inherits the interleaving structure when viewed as a persistence module over `ZMod p`.

2. **Field coefficient stability**: Apply the classical algebraic stability theorem (which holds for persistence modules over any field, hence over `ZMod p`) to conclude that the p-torsion barcodes are δ-matched in bottleneck distance. This is the critical reduction: **torsion barcode stability = ordinary barcode stability applied to field coefficients, one prime at a time.**

3. **Finiteness and supremum**: Since `K` is a finite simplicial complex, `H_n(K, ℤ)` is finitely generated, so only finitely many primes p appear in the torsion decomposition. The full torsion barcode is the union over all such primes, and the bottleneck distance of the union is bounded by the maximum over primes, each of which is ≤ δ.

**Why Strategy A is most promising**: It reduces to a known theorem. The classical algebraic stability theorem for persistence modules over a field is well-established and has been formalized in various contexts. The new mathematical content is the primary decomposition step and the finiteness argument for the supremum.

**Strategy B (Support Set + Hausdorff Distance)**:

1. Define `torsionBirthSet F n` as the set of filtration parameters where torsion first appears in dimension n.
2. Show that an interleaving at the chain level induces an isomorphism on torsion subgroups that is approximately localized: torsion that appears at parameter t in F must have a corresponding torsion element in G appearing within δ of t.
3. Use the universal coefficient theorem to relate the torsion subgroups of F and G through the interleaving maps.
4. Conclude that the Hausdorff distance between birth sets is ≤ δ.

This gives a weaker result (only birth times, not full barcodes) but avoids needing interval decompositions entirely. It could serve as a stepping stone toward Strategy A.

**Strategy C (Derived Functor Approach)**:

1. Use the long exact Tor sequence: for any short exact sequence of chain complexes, the derived functors Tor^ℤ_i form a long exact sequence.
2. Show that the interleaving between F and G induces a morphism of long exact Tor sequences that is approximately the identity.
3. Apply a spectral sequence argument to bound the shift in Tor groups.

This is the most general approach (works for derived functors beyond Tor_1) but is technically the hardest and may require spectral sequence machinery not yet in Mathlib.

---

### Novel Definitions Required

1. **`pTorsionBarcode`**: The barcode of the p-primary component of torsion, viewed as a persistence module over the field `ZMod p`. This requires:
   - Extracting the p-primary component `Tor_p(H_n(F_t))` from the torsion subgroup
   - Verifying it forms a persistence module over `ZMod p` (scalar multiplication by `ZMod p` acts on `Tor_p`)
   - Applying the interval decomposition theorem (which holds over fields)

2. **`torsionBirthSet`**: The set of filtration parameters at which torsion first appears in a given homological dimension. This is a novel invariant that captures the "onset" of torsion.

3. **`torsionBarcodeEntropy`**: Shannon entropy of the normalized bar-length distribution of the torsion barcode. This bridges topological data analysis with information theory.

4. **`InterleavingDist` for persistence modules over ℤ**: Extend the existing interleaving distance (defined for vector space-valued persistence modules) to ℤ-module-valued persistence modules. The key subtlety: the interleaving maps are ℤ-linear, not just additive.

---

### Cross-Domain Connections

1. **Persistence Theory ↔ Information Theory**: The `torsionBarcodeEntropy` theorem establishes that torsion barcodes are information-theoretically stable descriptors. This opens the door to using information-theoretic tools (mutual information, KL divergence) to compare topological features across datasets. The Lipschitz bound on entropy means that small perturbations in data cannot cause large information loss in the torsion descriptor.

2. **Algebraic Topology ↔ Quantum Invariants**: Torsion in homology is intimately related to Reidemeister torsion (R-torsion), which appears in:
   - The analytic torsion of Ray-Singer (spectral geometry)
   - The Chern-Simons path integral (quantum field theory)
   - The Turaev-Viro invariants (quantum topology)
   
   Stability of torsion barcodes implies stability of R-torsion under mesh refinement, which is relevant for discrete approximations to Chern-Simons theory. **Conjecture**: The R-torsion barcode (barcode of the Reidemeister torsion as a function of the filtration parameter) is stable in the same bottleneck sense.

3. **Metric Geometry ↔ Optimal Transport**: The bottleneck distance on barcodes is the ∞-Wasserstein distance on the space of point measures (with diagonal matching). The stability theorem says: interleaving distance ≥ bottleneck distance. This is a form of the *Kantorovich duality* for persistence modules: the algebraic distance (interleaving) dominates the geometric distance (optimal transport of barcodes). This connection suggests using Sinkhorn-type algorithms for fast approximate barcode matching.

4. **Numerical PDEs ↔ Mesh Refinement**: When solving PDEs on manifolds via finite element methods, the mesh undergoes barycentric subdivision. Torsion barcode stability guarantees that topological features detected by torsion (e.g., non-orientability detected by ℤ/2ℤ in H₁) are preserved under mesh refinement. This has direct applications to:
   - Verification of topology in computational fluid dynamics
   - Stability of topological phase transitions in materials science
   - Robustness of topological quantum error-correcting codes

---

### Testable Conjecture

**Conjecture (Sharp Torsion Stability Bound)**: The δ bound in the torsion barcode stability theorem is sharp. Specifically, for every δ > 0 and prime p, there exist filtrations F, G of finite simplicial complexes such that:
- The interleaving distance between `torPersistenceModule F n` and `torPersistenceModule G n` is exactly δ
- The p-torsion bottleneck distance is exactly δ
- The ordinary (non-torsion) barcode distance is strictly less than δ

This would demonstrate that **torsion barcodes are strictly more sensitive than ordinary barcodes** to certain perturbations, making them complementary descriptors.

**Computational Test**: 
1. Construct a filtration of the lens space L(p,1) (which has ℤ/pℤ torsion in H₁) and a perturbed version where the attaching map is shifted by δ in the filtration parameter.
2. Compute both ordinary and torsion barcodes.
3. Verify: bottleneck distance for torsion = δ, bottleneck distance for ordinary < δ.
4. Repeat for p = 2, 3, 5, 7, 11 and δ = 0.1, 0.5, 1.0.

**Falsification**: If the torsion bottleneck distance is always ≤ the ordinary bottleneck distance for these examples, the conjecture is false and torsion barcodes are not more sensitive.

---

### Application Keywords

`topological-data-analysis`, `torsion-barcode-stability`, `algebraic-stability`, `p-primary-decomposition`, `persistence-modules-over-fields`, `bottleneck-distance`, `interleaving-distance`, `information-theoretic-topology`, `Reidemeister-torsion`, `quantum-topology-stability`, `mesh-refinement-robustness`, `optimal-transport-barcode`, `Wasserstein-persistence`, `Chern-Simons-discretization`, `topological-phase-transitions`

---

### Catalog References to Build On

- `Algebra/Homology/DerivedFunctors/TorsionDetection.lean` — `exists_torsion_birth`, `torsion_persistence_functorial`, `torPersistenceModule`: These provide the foundation. Extend `torPersistenceModule` to carry the p-primary decomposition.
- Build on `torsion_persistence_functorial` to show that the p-primary component is functorial and preserves interleavings.
- Use `exists_torsion_birth` to show that `torsionBirthSet` is nonempty when torsion exists, and then prove Hausdorff stability.

---

### Required Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 testable scientific hypotheses, each falsifiable with a clear computational test:
   - H1: Sharp bound conjecture above
   - H2: Torsion entropy is subadditive under direct sums of filtrations
   - H3: The p-torsion barcode of L(p,1) detects the prime p (inverse problem)
   - H4: Multi-parameter torsion barcodes satisfy a stability theorem analogous to the single-parameter case
   - H5: The R-torsion barcode satisfies the same δ-stability bound

(b) **RESEARCH_PAPER.md** — standalone scientific document explaining: the primary decomposition reduction, the stability theorem, the information-theoretic connection, and the sharpness conjecture. A reader with NO access to the code must understand what was discovered and why it matters.

(c) **ARTICLE.md** — Scientific American style, explaining how torsion — the "shadow" structure of topology that ordinary persistence misses — can now be reliably detected in noisy data, and what this means for understanding the shape of data in everything from materials science to quantum computing.

(d) **Verified algorithm**: A certified procedure that, given two filtrations and an interleaving bound δ, computes the p-torsion barcodes for each prime p and certifies that their bottleneck distance is ≤ δ. The certification should use the primary decomposition structure.

(e) **demo.py**: Interactive demonstration that:
   - Computes torsion barcodes for filtrations of RP², the Klein bottle, and L(5,1)
   - Applies perturbations of varying magnitude
   - Verifies the stability bound δ numerically
   - Compares torsion barcode sensitivity vs. ordinary barcode sensitivity
   - Visualizes the p-torsion barcodes colored by prime

---

### Ambition

★★★★ — This is the torsion analogue of the most celebrated theorem in topological data analysis. Success here makes torsion barcodes a practical tool, not just a theoretical curiosity. The primary decomposition insight — that torsion stability reduces to field-coefficient stability — is a conceptual advance that could reshape how the community thinks about persistent homology with integer coefficients.

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
