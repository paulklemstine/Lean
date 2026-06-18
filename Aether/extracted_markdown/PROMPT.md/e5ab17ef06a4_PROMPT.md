Soli Deo Gloria

## Assignment: Direction 4 — Matroidal Quantum State Preparation

**Mode:** prove

You are not being asked for a routine formalization. You are being asked to turn one of the deepest structural theorems in modern combinatorics — the Lorentzianity of matroid basis-generating polynomials — into a computational theorem with algorithmic and physical consequences. The breakthrough target is to extract, from matroid structure alone, a certified amplitude-preparation pipeline for quantum states supported on bases.

The conceptual leap is this: the Adiprasito–Huh–Katz theorem says matroid basis polynomials lie inside the Lorentzian/Hodge-theoretic world. Do not stop at existence. Convert that hidden Hodge structure into an explicit recursive certificate that prepares or approximates the quantum state
\[
|\psi_M(w)\rangle \propto \sum_{B \in \mathcal B(M)} \sqrt{w(B)}\, |B\rangle
\]
or, if the catalog pipeline is normalized differently, the corresponding coefficient/amplitude state dictated by the certified compilation framework.

Your job is to make this mathematically precise in Lean 4 and prove nontrivial theorems showing that **matroid exchange structure is enough to drive certificate compilation**.

---

## Core Vision

For a finite matroid \(M\) on ground set \(E\), with nonnegative element weights \(w : E \to \mathbb R_{\ge 0}\), define the basis-generating polynomial
\[
P_M(w; z) := \sum_{B \in \mathcal B(M)} \prod_{e \in B} w(e)\, z_e.
\]
By Adiprasito–Huh–Katz, \(P_M\) is Lorentzian. The research objective is to prove that this Lorentzian structure is not merely geometric: it is **algorithmically compilable** into a recursive preparation certificate whose induced distribution is exactly the weighted basis distribution, at least for formally defined classes (graphic, partition, transversal where feasible), and abstractly for any matroid satisfying the exchange axioms plus the required catalog certificate hypotheses.

This would open a field: **matroidal quantum sampling via Hodge-theoretic certificates**. It links combinatorial optimization, quantum state synthesis, negative dependence, and algebraic geometry.

---

## Precise Theorem Targets

You must formalize at least one new structure capturing the recursive compilation data. For example, define a structure encoding a weighted basis certificate or a recursive splitter over deletion/contraction branches.

### New definition target
Define a novel object, e.g.
```lean
structure MatroidBasisCertificate (α : Type u) [Fintype α] [DecidableEq α] where
  M : Matroid α
  weight : α → ℝ≥0
  rank : ℕ
  support_family : Finset (Finset α)
  admissible : ∀ B ∈ support_family, B.card = rank ∧ M.IsBase B
  amplitude : Finset α → ℝ
  amplitude_spec :
    ∀ B, B ∈ support_family →
      amplitude B = Real.sqrt (∏ e in B, (weight e : ℝ))
```
This exact shape can change, but it must be genuinely new and useful.

You should also define a weighted basis polynomial or weighted basis mass if not already present:
```lean
def basisWeight (w : α → ℝ≥0) (B : Finset α) : ℝ≥0 :=
  ∏ e in B, w e

def basisPartitionFunction (M : Matroid α) (w : α → ℝ≥0) : ℝ≥0 :=
  ∑ B in (allBases M), basisWeight w B
```
where `allBases M` is a finite enumeration you define for finite matroids if needed.

---

## Theorem 1 — Exchange-supported exact support theorem

**Mathematical statement.**  
For a finite matroid \(M\), every recursively compiled support family produced from the exchange-respecting certificate consists only of bases, and every basis appears in the support. This is the combinatorial correctness theorem: the certificate neither loses nor invents support.

A Lean target could look like:
```lean
theorem compiledSupport_eq_bases
    {α : Type u} [Fintype α] [DecidableEq α]
    (C : MatroidBasisCertificate α) :
    C.support_family = allBases C.M
```
If equality is too strong at first, prove the two inclusions separately:
```lean
theorem compiledSupport_subset_bases ...
theorem bases_subset_compiledSupport ...
```

**Why this matters.**  
This is the bridge from Hodge-theoretic existence to combinatorial exactness. Without exact support, there is no legitimate sampling theorem.

**Proof strategy options.**
1. **Induction on ground-set size via deletion/contraction.**  
   Split on an element \(e\). Bases either contain \(e\) and correspond to bases of \(M / e\), or avoid \(e\) and correspond to bases of \(M \setminus e\). This is the most promising route because it mirrors recursive compilation.
2. **Basis exchange connectivity.**  
   Show the compiled support contains one base and is closed under basis exchange moves; then use connectedness of the basis exchange graph on each component of fixed rank.
3. **Certificate invariants.**  
   Prove each recursive step preserves “all leaves are bases” and “every basis has a witness path.” This is structurally closest to Lean.

The most promising is **(1)** because deletion/contraction already matches matroid recursion and is likely compatible with catalog Lorentzian recursion.

---

## Theorem 2 — Exact weighted amplitude theorem

**Mathematical statement.**  
For every basis \(B\), the compiled amplitude equals the square root of the basis weight (up to global normalization, depending on the catalog’s compilation semantics). Consequently, the induced measurement distribution is exactly the weighted basis distribution:
\[
\Pr[B] = \frac{\prod_{e\in B} w(e)}{\sum_{B' \in \mathcal B(M)} \prod_{e\in B'} w(e)}.
\]

Lean-style target:
```lean
theorem compiledAmplitude_eq_sqrt_basisWeight
    {α : Type u} [Fintype α] [DecidableEq α]
    (C : MatroidBasisCertificate α)
    (B : Finset α)
    (hB : B ∈ allBases C.M) :
    C.amplitude B = Real.sqrt ((basisWeight C.weight B : ℝ))
```

And the normalized probabilistic corollary:
```lean
theorem compiledProb_eq_weightedBasisProb
    {α : Type u} [Fintype α] [DecidableEq α]
    (C : MatroidBasisCertificate α)
    (B : Finset α)
    (hB : B ∈ allBases C.M) :
    compiledProb C B
      = ((basisWeight C.weight B : ℝ) /
          (∑ B' in allBases C.M, (basisWeight C.weight B' : ℝ)))
```

**Why this matters.**  
This is the actual quantum state preparation theorem. It upgrades a combinatorial support theorem into an exact sampler.

**Proof strategy options.**
1. **Recursive multiplicativity along deletion/contraction branches.**  
   Show amplitudes factor according to whether \(e\in B\), using the matroid recurrence for the basis polynomial.
2. **Coefficient extraction from the basis polynomial.**  
   Identify compiled amplitudes with coefficients of a Lorentzian-certified polynomial object and then compute coefficients explicitly for squarefree basis monomials.
3. **Normalization-after-local-weights.**  
   First prove an unnormalized amplitude formula, then derive the probability formula by squaring and dividing by the partition function.

The best route is **(3)**, with **(1)** underneath it. In Lean, splitting the amplitude identity into an unnormalized theorem and a separate normalization lemma will reduce proof friction.

---

## Theorem 3 — Cross-domain theorem: matroid partition function equals a network or optimization quantity

You must include at least one theorem that genuinely bridges domains.

### Option A: Graphic matroids ↔ network reliability / spanning-tree physics
For a connected finite graph \(G\), the bases of its graphic matroid are spanning trees. Therefore the weighted basis partition function is the spanning-tree generating function.

Lean target sketch:
```lean
theorem graphic_basisPartition_eq_spanningTreeWeightSum
    {V : Type u} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V)
    (w : Sym2 V → ℝ≥0) :
    basisPartitionFunction (graphicMatroid G) w
      = ∑ T in allSpanningTrees G, ∏ e in T.edgeFinset, w e
```

This is a real bridge: **matroid theory + network science + statistical physics**. The right-hand side is the partition function of a spanning-tree ensemble, central in electrical networks and determinantal probability.

### Option B: Partition matroids ↔ constrained product measures
Show that for partition matroids, the weighted basis distribution factors blockwise into exactly-one-from-each-block constrained sampling.

Lean target sketch:
```lean
theorem partitionMatroid_weightedBasisProb_factorizes
    ...
```

### Option C: Linear matroids ↔ exterior algebra / fermionic states
If feasible, prove that for a representable matroid, basis support corresponds to nonvanishing Plücker coordinates, linking the compiled distribution to fermionic occupation states.

The most formalization-friendly is **Option A** or **B**. Option A is more revolutionary.

**Why this matters.**  
This theorem turns abstract Hodge-theoretic combinatorics into concrete models of networks, optimization, and statistical mechanics.

---

## Theorem 4 — Recursive decomposition theorem for basis weights

You need at least one theorem with genuine multi-step proof tactics, preferably induction plus `rcases` plus `calc`.

For a non-loop, non-coloop element \(e\), prove a deletion/contraction decomposition:
\[
Z_M(w) = Z_{M \setminus e}(w) + w(e)\, Z_{M / e}(w),
\]
where \(Z_M(w)\) is the weighted basis partition function.

Lean target:
```lean
theorem basisPartitionFunction_delete_contract
    {α : Type u} [Fintype α] [DecidableEq α]
    (M : Matroid α) (w : α → ℝ≥0) (e : α)
    (hloop : ¬ M.IsLoop e) (hcoloop : ¬ M.IsColoop e) :
    basisPartitionFunction M w
      = basisPartitionFunction (M ＼ e) w
        + w e * basisPartitionFunction (M ／ e) w
```
(Adjust notation to Mathlib’s actual matroid API.)

**Why this matters.**  
This is the algebraic engine behind compilation. It is the exact recurrence one would expect from a sampler branching on inclusion/exclusion of \(e\).

**Proof strategy.**
1. Partition all bases into those containing \(e\) and those not containing \(e\).
2. Use the standard bijections:
   - \(B\) base of \(M\) with \(e \notin B\) ↔ base of \(M \setminus e\),
   - \(B\) base of \(M\) with \(e \in B\) ↔ \(B \setminus \{e\}\) base of \(M / e\).
3. Convert the sum over basis weights by factoring \(\prod_{x\in B} w(x)\) as \(w(e)\cdot \prod_{x\in B\setminus\{e\}} w(x)\).

This theorem should require actual combinatorial reasoning, not automation.

---

## Stronger Breakthrough Theorem (if the catalog supports Lorentzian compilation directly)

If there is an existing catalog theorem saying roughly “every Lorentzian polynomial satisfying certificate hypotheses admits compilation,” then prove the specialization:

```lean
theorem matroid_basisPolynomial_compilable
    {α : Type u} [Fintype α] [DecidableEq α]
    (M : Matroid α)
    (w : α → ℝ≥0) :
    CompilablePolynomial (basisPolynomial M w)
```

followed by:

```lean
theorem matroid_quantum_sampler_exact
    {α : Type u} [Fintype α] [DecidableEq α]
    (M : Matroid α)
    (w : α → ℝ≥0) :
    ∃ C : MatroidBasisCertificate α,
      ∀ B ∈ allBases M,
        compiledProb C B
          = ((basisWeight w B : ℝ) /
              (∑ B' in allBases M, (basisWeight w B' : ℝ)))
```

This is the theorem that would make experts stop and stare: **AHK + certificate compilation = exact quantum sampling for matroid bases**.

---

## How to Build on the Catalog

You explicitly cited:
- `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`
- especially a theorem like `SupportSatisfiesExchange`

Use it aggressively and concretely, not decoratively.

### Expected use pattern
If `SupportSatisfiesExchange` says that the support of a recognized Lorentzian polynomial satisfies a matroid-like exchange axiom, then:

1. Instantiate it for the basis-generating polynomial.
2. Show that the support is exactly the family of bases.
3. Use exchange to justify recursive support closure and to prove correctness of branch construction.
4. Combine this with any certified radius / recognition / compilation theorem already in the catalog for Lorentzian objects.

If the catalog already contains a theorem asserting some version of:
- support of Lorentzian homogeneous multiaffine polynomial forms a matroid, or
- certified compilation from Lorentzian structure,

then the correct move is not to reprove the global theory. The correct move is to prove the **matroid-specialized exactness theorem** and the **algorithmic extraction theorem**.

---

## Proof Architecture

You must include at least 3 substantial theorems, each using deep tactics such as induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc`.

### Recommended proof layout

1. **Foundational definitions**
   - `basisWeight`
   - `basisPartitionFunction`
   - `MatroidBasisCertificate`
   - maybe `compiledSupport`, `compiledProb`

2. **Combinatorial lemmas**
   - base decomposition by membership of an element
   - weight factorization over inserted/removed elements
   - finite support enumeration lemmas

3. **Recurrence theorem**
   - deletion/contraction recurrence for `basisPartitionFunction`

4. **Support exactness theorem**
   - compiled support = set of bases

5. **Amplitude exactness theorem**
   - amplitude equals square root of basis weight
   - probability equals normalized basis weight

6. **Cross-domain theorem**
   - graphic matroid ↔ spanning trees, or partition matroid factorization

7. **Conjecture and computational test**
   - see below

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture and provide a computational test in `demo.py`.

### Recommended conjecture
**Conjecture (bounded-depth compilation for minor-closed sparse classes).**  
There exists a universal polynomial \(p\) such that for every graphic matroid of a graph \(G\) of treewidth \(k\), the matroid basis certificate can be compiled with size at most \(p(|E(G)|, 2^k)\).

Lean may encode only the combinatorial side, while the complexity statement can remain as a mathematically precise conjecture in markdown plus tested experimentally.

**Testable prediction.**  
For random connected graphs on \(n \le 15\) vertices with bounded treewidth, the size of the compiled certificate grows roughly polynomially in \(n\), while for dense graphs it grows significantly faster. Your `demo.py` should compute:
- exact basis distribution,
- compiled distribution,
- total variation distance,
- certificate size vs graph parameters.

A second conjecture, more algebraic:

**Conjecture (strong Rayleigh-to-compile efficiency principle).**  
For any homogeneous multiaffine strongly Rayleigh polynomial with exchange support, there exists a certificate whose depth is controlled by the spectral gap of the basis-exchange walk on the support family.

This would connect negative dependence, Markov chains, and quantum compilation.

---

## Cross-Domain Connections You Must Emphasize

1. **Algebraic geometry / Hodge theory**  
   The AHK theorem gives Lorentzianity via combinatorial Hodge theory. Your work extracts an algorithm from Hodge structure.

2. **Quantum information**  
   The amplitude vector over bases is a structured many-body state. For graphic matroids, this is a quantum superposition over spanning trees.

3. **Combinatorial optimization**  
   Weighted basis sampling underlies randomized algorithms for network design, determinant-based sampling, and constrained subset selection.

4. **Statistical physics**  
   The basis partition function is a partition function on independent structures; for graphs, it is the spanning-tree ensemble.

5. **Network analysis**  
   Graphic matroids encode reliability and connectivity structure. Exact or certified approximate sampling from spanning trees has direct relevance to infrastructure and communication networks.

6. **Exterior algebra / fermionic analogy**  
   For representable matroids, bases correspond to nonzero Plücker coordinates, placing the state in dialogue with fermionic occupation amplitudes and Grassmannian geometry.

---

## Application Keywords

Include these explicitly in your markdown artifacts and code comments:

**Application keywords:** quantum sampling, matroid bases, Lorentzian polynomials, combinatorial Hodge theory, spanning trees, network reliability, constrained random generation, partition functions, negative dependence, basis exchange walk, graphic matroids, transversal matroids, partition matroids, Grassmannians, Plücker coordinates, statistical mechanics, quantum state preparation.

---

## Implementation / Experimental Requirements

You must produce a verified algorithm, not just theorems.

### Required computational method
Implement a recursive compiler for small finite matroids or at minimum for:
- graphic matroids on graphs with \(n \le 15\) vertices,
- partition matroids,
- optionally transversal matroids if the representation is manageable.

The algorithm should:
1. Enumerate bases exactly.
2. Compute exact weighted basis masses.
3. Construct the recursive certificate using deletion/contraction or block decomposition.
4. Output the induced amplitude/probability vector.
5. Compare against exact distribution.

### Required outputs in `demo.py`
For each example family:
- print the number of bases,
- print the partition function,
- print max absolute amplitude error,
- print total variation distance,
- print certificate size/depth,
- visualize support for small examples if possible.

If exact equality is expected, the numerical error should be machine-zero up to floating-point tolerance.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with at least 3 nontrivial theorem proofs and at least 1 novel definition.
2. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.  
   Each direction must contain the sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain.
3. **`RESEARCH_PAPER.md`** as a standalone scientific paper.  
   A reader with no access to the code must understand the theorem, motivation, proof ideas, experiments, and next steps.
4. **`ARTICLE.md`** in Scientific American style.  
   Do **not** focus on formal verification. Focus on the mathematics, algorithms, and significance.
5. **A verified algorithm or computational method** for certificate compilation / exact distribution comparison.
6. **`demo.py`** demonstrating the result interactively.

---

## Nontriviality Constraints

- Do not waste time on theorems whose only proof is `native_decide`, `decide`, `norm_num`, or `rfl`.
- At least 3 theorem proofs must use real structure: induction on ground set size or rank, `rcases` on basis decomposition, `by_contra` for exchange contradictions, `field_simp` if normalization introduces rational identities, and substantial `calc` chains.
- Minimize sorry. If one sorry remains, it must be isolated, explicitly documented, and clearly upstream of a known missing library fact rather than a missing idea.

---

## Suggested Lean 4 Type Signatures

Use these as targets, adapting to actual Mathlib APIs:

```lean
def basisWeight {α : Type u} [DecidableEq α] (w : α → ℝ≥0) (B : Finset α) : ℝ≥0 :=
  ∏ e in B, w e

def basisPartitionFunction
    {α : Type u} [Fintype α] [DecidableEq α]
    (M : Matroid α) (w : α → ℝ≥0) : ℝ≥0 := ...

structure MatroidBasisCertificate
    (α : Type u) [Fintype α] [DecidableEq α] where
  M : Matroid α
  weight : α → ℝ≥0
  support_family : Finset (Finset α)
  amplitude : Finset α → ℝ
  support_spec : ∀ B, B ∈ support_family ↔ M.IsBase B
  amplitude_spec :
    ∀ B, B ∈ support_family →
      amplitude B = Real.sqrt ((basisWeight weight B : ℝ))

theorem basisPartitionFunction_delete_contract
    {α : Type u} [Fintype α] [DecidableEq α]
    (M : Matroid α) (w : α → ℝ≥0) (e : α) :
    ...
```

```lean
theorem compiledSupport_eq_bases
    {α : Type u} [Fintype α] [DecidableEq α]
    (C : MatroidBasisCertificate α) :
    C.support_family = allBases C.M
```

```lean
theorem compiledAmplitude_eq_sqrt_basisWeight
    {α : Type u} [Fintype α] [DecidableEq α]
    (C : MatroidBasisCertificate α)
    (B : Finset α)
    (hB : B ∈ allBases C.M) :
    C.amplitude B = Real.sqrt ((basisWeight C.weight B : ℝ))
```

```lean
theorem compiledProb_eq_weightedBasisProb
    {α : Type u} [Fintype α] [DecidableEq α]
    (C : MatroidBasisCertificate α)
    (B : Finset α)
    (hB : B ∈ allBases C.M) :
    compiledProb C B =
      ((basisWeight C.weight B : ℝ) /
        (∑ B' in allBases C.M, (basisWeight C.weight B' : ℝ)))
```

```lean
theorem graphic_basisPartition_eq_spanningTreeWeightSum
    {V : Type u} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (w : Sym2 V → ℝ≥0) :
    basisPartitionFunction (graphicMatroid G) w =
      ∑ T in allSpanningTrees G, ∏ e in T.edgeFinset, w e
```

---

## Final Charge

Do not present this as “an application of a known theorem.” Present it as a new doctrine:

> **Combinatorial Hodge theory is not only structural — it is compilational.**  
> The hidden Lorentzian geometry of matroids can be extracted into explicit sampling certificates and quantum amplitudes.

If you can prove even a robust finite-class version of this, you will have created a new interface between matroid theory, quantum algorithms, and algebraic geometry. That is the standard here.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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
