## Assignment: Direction 4: Persistent Torsion Detection for TDA

**Mode**: prove

Build a torsion-aware persistent homology theory over `ℤ` that does something standard field-valued barcodes cannot do: detect, localize, and transport torsion across a filtration. This is not just an implementation exercise. The goal is to formalize a genuinely new theorem package showing that torsion in integral persistent homology can be detected functorially via `Tor₁`, organized into interval data, and certified in Lean 4.

You must prove new, non-trivial theorems, building explicitly on:

- `Algebra/Homology/DerivedFunctors/TorsionDetection.lean`
- especially the catalog theorems
  - `tor1_vanishes_iff_no_n_torsion`
  - `tor1_Zmod_free_vanishes_via_torsion`

The conceptual leap is this: **classical persistence over fields collapses torsion information; `Tor₁(ℤ/pℤ, -)` recovers it as a new persistent observable.** If formalized correctly, this opens a verified pipeline for torsion-sensitive TDA, with applications to non-orientable geometry, materials with defect topology, and discrete physical systems where mod-`p` obstructions matter.

---

## Core Mathematical Objective

Let `K : ι → SimplicialComplex V` be a filtered simplicial complex indexed by a preorder `ι`, with structure maps `K i ⟶ K j` for `i ≤ j`, and let
`H_k(K_i; ℤ)` denote the integral homology at filtration level `i`.

For each prime `p`, define the **torsion detector module**
\[
T^{(p)}_k(i) := \operatorname{Tor}_1^{\mathbb Z}(\mathbb Z/p\mathbb Z,\; H_k(K_i;\mathbb Z)).
\]

The central theorem to formalize is:

> **Persistent Torsion Detection Theorem.**
> For every filtration index `i`, degree `k`, and prime `p`,
> \[
> T^{(p)}_k(i) \neq 0 \iff H_k(K_i;\mathbb Z)\text{ has nonzero }p\text{-torsion}.
> \]
> Moreover, the assignment `i ↦ T^{(p)}_k(i)` is functorial in the filtration, so changes in `T^{(p)}_k(i)` define a torsion-sensitive persistence invariant invisible over fields of characteristic `≠ p`.

This is the pointwise theorem. The real breakthrough is to push beyond pointwise detection and prove a persistence-compatible structure theorem for **torsion support intervals**.

---

## Precise Formal Targets

You should introduce at least one genuinely new definition, for example a notion of torsion support along a filtration.

### New definitions to add

Define a filtered torsion observable, e.g.

```lean
def pTorsionDetected
    (p : ℕ) (A : Type _) [AddCommGroup A] [Module ℤ A] : Prop :=
  ¬ Subsingleton (ModuleCat.Tor₁ (ModuleCat.of ℤ (ZMod p)) (ModuleCat.of ℤ A))
```

or more realistically in the actual Mathlib category/interface available for Tor:

```lean
def pTorsionDetected
    (p : ℕ) (M : ModuleCat ℤ) : Prop :=
  ¬ Subsingleton (Tor₁ (ModuleCat.of ℤ (ZMod p)) M)
```

Then define a support set/barcode-like object for a persistence module `H : ι → ModuleCat ℤ`:

```lean
def torsionSupport
    (p : ℕ) (H : ι → ModuleCat ℤ) : Set ι :=
  {i | pTorsionDetected p (H i)}
```

If interval decompositions are too ambitious in full generality, define instead a robust finite-filtration notion:

```lean
def torsionBirth
    [Preorder ι] (p : ℕ) (H : ι → ModuleCat ℤ) (i : ι) : Prop :=
  pTorsionDetected p (H i) ∧ ∀ j < i, ¬ pTorsionDetected p (H j)

def torsionDeath
    [Preorder ι] (p : ℕ) (H : ι → ModuleCat ℤ) (i : ι) : Prop :=
  ¬ pTorsionDetected p (H i) ∧ ∃ j < i, pTorsionDetected p (H j)
```

If Mathlib’s exact `Tor₁` interface differs, adapt signatures, but keep the theorem statements mathematically identical.

---

## Theorems You Should Prove

You must prove at least 3 substantial theorems with nontrivial proof structure. The following package is the target.

### Theorem 1: Pointwise Tor-detects-p-torsion in persistent homology

**Mathematical statement**
For each filtration level `i`, degree `k`, and prime `p`,
\[
\operatorname{Tor}_1^{\mathbb Z}(\mathbb Z/p\mathbb Z, H_k(K_i;\mathbb Z)) = 0
\iff
H_k(K_i;\mathbb Z)\text{ has no }p\text{-torsion}.
\]

Equivalently,
\[
\operatorname{Tor}_1^{\mathbb Z}(\mathbb Z/p\mathbb Z, H_k(K_i;\mathbb Z)) \neq 0
\iff
\exists x \neq 0,\; p x = 0 \text{ in } H_k(K_i;\mathbb Z).
\]

### Suggested Lean-style type signature
```lean
theorem tor1_persistent_detects_ptorsion
    {ι : Type _} [Preorder ι]
    (H : ι → ModuleCat ℤ)
    (p : ℕ) [Fact p.Prime] (i : ι) :
    IsZero (Tor₁ (ModuleCat.of ℤ (ZMod p)) (H i)) ↔
      NoPTorsion p (H i)
```

or, if the catalog theorem is phrased in terms of `n`-torsion:
```lean
theorem tor1_Zmod_p_vanishes_iff_no_p_torsion
    {ι : Type _} [Preorder ι]
    (H : ι → ModuleCat ℤ)
    (p : ℕ) [Fact p.Prime] (i : ι) :
    IsZero (Tor₁ (ModuleCat.of ℤ (ZMod p)) (H i)) ↔
      NoNTorsion p (H i)
```

**How to build from catalog**
This should be a direct but nontrivial specialization of
`tor1_vanishes_iff_no_n_torsion`,
instantiated at each filtration level. The nontriviality comes from packaging it in a persistent setting and connecting it to your new definitions.

---

### Theorem 2: Functoriality of torsion detection along the filtration

If `i ≤ j`, the inclusion `K_i ↪ K_j` induces a map
\[
H_k(K_i;\mathbb Z) \to H_k(K_j;\mathbb Z),
\]
hence by functoriality of `Tor₁`,
\[
\operatorname{Tor}_1(\mathbb Z/p\mathbb Z, H_k(K_i;\mathbb Z))
\to
\operatorname{Tor}_1(\mathbb Z/p\mathbb Z, H_k(K_j;\mathbb Z)).
\]

Formalize that the torsion detector is itself a persistence module.

### Suggested Lean-style type signature
```lean
def pTorPersistence
    {ι : Type _} [Preorder ι]
    (H : PersistenceModule ι (ModuleCat ℤ))
    (p : ℕ) :
    PersistenceModule ι (ModuleCat ℤ)
```

and prove coherence:

```lean
theorem pTorPersistence_map_comp
    {ι : Type _} [Preorder ι]
    (H : PersistenceModule ι (ModuleCat ℤ))
    (p : ℕ) {i j k : ι} (hij : i ≤ j) (hjk : j ≤ k) :
    (pTorPersistence H p).map hij ≫ (pTorPersistence H p).map hjk =
      (pTorPersistence H p).map (le_trans hij hjk)
```

If a full persistence module structure is too heavy, prove the induced-map theorem:

```lean
theorem tor1_map_of_le
    {ι : Type _} [Preorder ι]
    (H : ι → ModuleCat ℤ)
    (maps : ∀ {i j}, i ≤ j → H i ⟶ H j)
    (map_id : ...)
    (map_comp : ...)
    (p : ℕ) [Fact p.Prime]
    {i j : ι} (hij : i ≤ j) :
    ∃ f : Tor₁ (ModuleCat.of ℤ (ZMod p)) (H i) ⟶
          Tor₁ (ModuleCat.of ℤ (ZMod p)) (H j), True
```

**Breakthrough significance**
This theorem says torsion is not merely detected levelwise; it **propagates as a derived persistent signal**. That is a new invariant in formal TDA.

---

### Theorem 3: Free persistent homology implies vanishing torsion barcode

If every `H_k(K_i; ℤ)` is free as a `ℤ`-module, then the entire `p`-torsion detector persistence module vanishes.

### Suggested Lean-style type signature
```lean
theorem pTorPersistence_vanishes_of_free
    {ι : Type _} [Preorder ι]
    (H : ι → ModuleCat ℤ)
    (p : ℕ)
    (hfree : ∀ i, Module.Free ℤ (H i)) :
    ∀ i, IsZero (Tor₁ (ModuleCat.of ℤ (ZMod p)) (H i))
```

**How to build from catalog**
Use `tor1_Zmod_free_vanishes_via_torsion` pointwise. Then package the result into vanishing of `torsionSupport p H`.

A stronger corollary should compare with field persistence:

```lean
theorem torsion_barcode_invisible_over_fields
    {ι : Type _} [Preorder ι]
    (H : ι → ModuleCat ℤ)
    (p q : ℕ) [Fact p.Prime] [Fact q.Prime]
    (hpq : p ≠ q)
    (htors : ∀ i, pTorsionDetected p (H i)) :
    True
```

Even if the exact field-barcode comparison cannot be fully internalized, state and partially formalize the principle: persistence over `ZMod q` can fail to detect `p`-torsion when `p ≠ q`, whereas `Tor₁(ZMod p, -)` detects it exactly.

---

### Theorem 4: Existence of a torsion birth in finite filtrations

For a finite linearly ordered filtration, if torsion is absent at the start and present at the end, then there exists a first index where `p`-torsion appears.

This gives the formal backbone of a barcode notion.

### Suggested Lean-style type signature
```lean
theorem exists_torsion_birth
    {ι : Type _} [LinearOrder ι] [Fintype ι]
    (H : ι → ModuleCat ℤ)
    (p : ℕ) [Fact p.Prime]
    (i0 i1 : ι)
    (h0 : ¬ pTorsionDetected p (H i0))
    (h1 : pTorsionDetected p (H i1))
    (hle : i0 ≤ i1) :
    ∃ b, i0 ≤ b ∧ b ≤ i1 ∧
      pTorsionDetected p (H b) ∧
      ∀ j, i0 ≤ j → j < b → ¬ pTorsionDetected p (H j)
```

**Proof depth**
This should use finite-order minimality arguments, likely via `Finite.exists_minimal`, induction over finite chains, or contradiction. This is not a one-line corollary and should count as one of the deep proofs.

---

## Proof Strategy Architecture

You must present and implement at least 2–3 proof routes, even if one becomes primary.

### Strategy A: Pointwise derived-functor lifting
1. Define the persistent module `H : ι → ModuleCat ℤ`.
2. Apply `tor1_vanishes_iff_no_n_torsion` at each `i`.
3. Package the resulting predicates into `torsionSupport`, then prove existence/birth theorems using order-theoretic arguments on finite filtrations.

**Why promising**: This directly leverages the catalog and minimizes foundational overhead. It is the fastest route to a verified torsion barcode theorem.

---

### Strategy B: Exact-sequence / universal coefficient perspective
1. Express torsion emergence through short exact sequences in chain complexes associated to filtration inclusions.
2. Use long exact sequences in homology and naturality of `Tor₁`.
3. Show that torsion transitions can be certified via connecting morphisms and exactness.

**Why deeper**: This reveals the mechanism of torsion birth/death rather than only detecting it pointwise. If feasible, it would be much more publishable mathematically.

---

### Strategy C: Finite combinatorial persistence over explicit filtered complexes
1. Restrict to finite simplicial complexes with explicit chain complexes over `ℤ`.
2. Compute homology groups and `Tor₁` concretely for canonical examples: `RP²`, Klein bottle, lens-space-like toy complexes if available.
3. Prove that your abstract detector agrees with the computed torsion pattern.

**Why essential**: This gives the algorithmic side and a bridge to verified computation. It is also the strongest route to `demo.py`.

**Recommended primary path**: A + C.  
First secure a clean theorem package using the catalog theorem pointwise; then certify it computationally on explicit complexes. B is the ideal stretch goal if the exact sequence API is mature enough in Mathlib.

---

## Cross-Domain Connections You Must Exploit

This project becomes field-opening only if you frame torsion persistence as more than “persistent homology with integers.”

### 1. Computational topology + homological algebra
Persistent homology is usually linear algebra over a field. Your work replaces this with a **derived functor observable**, importing the machinery of homological algebra into TDA in a computationally meaningful way.

### 2. TDA + materials science
Torsion classes arise in non-orientable structures and defect patterns. A torsion barcode could distinguish spaces with identical Betti barcodes but different global topology, relevant to:
- crystalline defects,
- mechanical metamaterials,
- topological phases on discretized configuration spaces.

### 3. TDA + arithmetic / modular sensing
The dependence on prime `p` means torsion persistence is an **arithmetic topological signal**. Different primes probe different hidden features. This is a rare and powerful bridge between:
- persistent topology,
- modular representation theory,
- arithmetic invariants.

### 4. TDA + sheaf/derived methods
This project suggests a future “derived persistence” program: not just vector-space-valued persistence, but persistence of derived invariants (`Tor`, `Ext`, spectral sequence pages). Your theorem should be written as the first verified step in that direction.

---

## Application Keywords

Use these explicitly in your paper and article:

- torsion barcode
- integral persistent homology
- derived persistence
- `Tor₁` detection
- prime-sensitive topology
- non-orientable feature detection
- verified computational topology
- arithmetic topological signal
- materials informatics
- topological defect analysis
- certified homological algebra
- persistence beyond fields

---

## Concrete Computational Targets

Implement torsion barcode computation for explicit filtered triangulations of:

- `S¹` or torus-like examples as torsion-free controls,
- `RP²` as the canonical `2`-torsion example,
- Klein bottle as a mixed free-plus-`2`-torsion example in homology.

Your test should verify:

1. Over field coefficients, ordinary barcodes may agree or miss torsion-sensitive distinctions.
2. Your `p`-torsion detector correctly identifies `2`-torsion in `RP²` and Klein bottle.
3. Torsion-free examples yield empty torsion barcode.
4. The detector changes with `p`, demonstrating arithmetic selectivity.

If full simplicial homology automation is too large, certify a smaller verified kernel:
- explicit boundary matrices over `ℤ`,
- Smith normal form or a verified surrogate,
- extraction of `p`-torsion from invariant factors,
- comparison with `Tor₁(ZMod p, -)`.

---

## Testable Conjectures for FUTURE_DIRECTIONS.md

You must include 3–5 falsifiable hypotheses. At least one should be computationally tested now. Suggested hypotheses:

1. **Prime selectivity hypothesis**  
   For finite filtered complexes `K`, the supports of `torsionSupport p H_k` and `torsionSupport q H_k` can differ strictly for distinct primes `p ≠ q`.  
   **Test**: Evaluate explicit filtered complexes with mixed torsion.

2. **Field invisibility hypothesis**  
   There exist filtrations `K` and degrees `k` such that all field-valued persistent Betti barcodes are identical across two filtrations, but their torsion barcodes differ.  
   **Test**: Construct filtered non-orientable surfaces or cell complexes with matched Betti data.

3. **Stability heuristic hypothesis**  
   Under filtration refinements that preserve chain-homotopy type at each stage, torsion birth indices are unchanged.  
   **Test**: Compare barycentric subdivision/refinement filtrations.

4. **Derived separation hypothesis**  
   The family of functors `Tor₁(ZMod p, -)` over all primes `p` separates more filtered homotopy types than ordinary field persistence in a finite benchmark suite.  
   **Test**: Compute on a corpus of triangulated surfaces and small CW complexes.

5. **Defect sensitivity hypothesis**  
   Torsion barcodes correlate with non-orientable or defect-induced topology in discretized materials datasets.  
   **Test**: Synthetic meshes with inserted cross-caps / Möbius-type defects.

---

## Mandatory Deliverables

You must produce all of the following:

1. **Lean file(s)** with:
   - at least 3 substantial theorem proofs,
   - at least 1 genuinely new definition,
   - minimal `sorry`,
   - no trivialized “proofs” by pure computation unless mathematically essential.

2. **`FUTURE_DIRECTIONS.md`**
   - 3–5 falsifiable scientific hypotheses,
   - each with a clear experimental or computational disproof criterion.

3. **`RESEARCH_PAPER.md`**
   - standalone scientific paper,
   - must explain the theorem, the formalization architecture, why torsion persistence matters, and what new science it enables,
   - readable without access to code.

4. **`ARTICLE.md`**
   - Scientific American style,
   - explain how hidden “modular shadows” of shape appear in data,
   - broad audience, but scientifically faithful.

5. **Verified algorithm or computational method**
   - not just theorem statements,
   - implement torsion barcode computation or a verified reduction to `Tor₁`/Smith data.

6. **`demo.py`**
   - interactive or scripted demonstration,
   - run examples on `RP²`, torus, Klein bottle or simplified analogues,
   - print/plot ordinary barcode summaries versus torsion barcode summaries.

---

## Lean-Proof Expectations

Your proofs must visibly use deep tactics and reasoning patterns:
- induction on finite filtrations or chains,
- `rcases` for extracting torsion witnesses,
- `by_contra` for minimal-birth/existence arguments,
- `field_simp` if rational comparisons arise in algorithmic sublemmas,
- multi-step `calc` chains for functoriality and vanishing transport.

Do not settle for a vacuous wrapper around the catalog theorem. The real result is the **persistent organization** of torsion detection.

---

## What Would Make This a Breakthrough

If you succeed, you will have created the first Lean-verified bridge between:
- derived functors,
- integral homology,
- and persistence theory.

That is not an incremental extension. It is the opening move in a new subject: **derived topological data analysis**. From there one can ask for `Ext`-persistent invariants, spectral-sequence-aware persistence, arithmetic signatures of data, and topological diagnostics invisible to all field-based pipelines.

Make the theorem package sharp, the definitions reusable, and the computational story undeniable.

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
