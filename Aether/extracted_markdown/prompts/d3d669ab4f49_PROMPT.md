Soli Deo Gloria

## Assignment: Direction 1: Smith Normal Form for Rational Metric Graphs

**Mode:** prove

Prove genuinely new, non-trivial theorems at the interface of **metric graph theory, tropical geometry, algebraic graph theory, and arithmetic linear algebra**. Build directly on the catalog’s weighted Laplacian and chip-firing infrastructure, especially:

- `Catalog/Pythagorean/TropicalBridge/MetricKernel/Theorems.lean`
- `Catalog/Pythagorean/TropicalBridge/Defs.lean`
- `Catalog/Bridges/Catalog/Pythagorean/TropicalBridge/CanonicalKernelTheorems.lean`

The central vision is to replace floating-point tropical Jacobian calculations with an **exact arithmetic theory**: for rational metric graphs, the finite torsion data of the tropical Jacobian should be extracted from the **Smith normal form of an integer-scaled reduced Laplacian**. If established cleanly in Lean, this becomes a foundational arithmetic portal between tropical geometry and chip-firing, and opens algorithmic access to exact tropical invariants.

---

## Core Breakthrough Objective

For a connected finite graph with rational edge lengths, define a canonical integer-scaled weighted Laplacian minor. Prove that its Smith normal form controls the finite arithmetic structure naturally attached to the graph, and that its determinant recovers the weighted spanning-tree invariant.

This is not just “another Laplacian theorem.” The breakthrough is the **exact arithmetic reconstruction of tropical Jacobian data from rational metric input**. That would unify:

- **tropical Jacobians** as real tori with arithmetic torsion shadows,
- **critical groups / sandpile groups** as cokernels of Laplacians,
- **Smith normal form** as the canonical classifier of finite abelian groups,
- **weighted Kirchhoff theory** for rational conductance networks.

The field-opening consequence is an exact, computable, theorem-certified dictionary:
\[
\text{rational metric graph} \rightsquigarrow \text{integer reduced Laplacian} \rightsquigarrow \text{SNF invariants} \rightsquigarrow \text{finite tropical Jacobian data}.
\]

---

## Precise Mathematical Program

Let \(G=(V,E)\) be a finite connected graph, with a chosen base vertex \(v_0\), and rational edge lengths
\[
\ell : E \to \mathbb{Q}_{>0}.
\]
Write conductances \(c_e := \ell_e^{-1}\in \mathbb{Q}_{>0}\). Let \(L_\mathbb{Q}\) be the weighted graph Laplacian over \(\mathbb{Q}\), and let \(L_\mathbb{Q}^{(v_0)}\) be the reduced Laplacian minor obtained by deleting the row and column indexed by \(v_0\).

Choose a positive integer \(D\) such that every entry of
\[
M := D \cdot L_\mathbb{Q}^{(v_0)}
\]
is an integer. Then \(M \in \mathrm{Mat}_{n-1}(\mathbb{Z})\).

You should introduce a **new definition** capturing the canonical arithmetic object:

### New definition to add
A structure or definition along the lines of:

- `RationalMetricGraph`
- `integerScaledReducedLaplacian`
- `finiteJacobianPresentation`
- `weightedTreeNumber`

For example, define the arithmetic presentation matrix attached to a rational metric graph:
\[
\mathrm{arithRedLap}(G,\ell,v_0,D) := D \cdot L_\mathbb{Q}^{(v_0)} \in \mathrm{Mat}_{|V|-1}(\mathbb{Z}).
\]

Also define the finite abelian group candidate
\[
K_{\mathrm{arith}}(G,\ell,v_0,D) := \mathbb{Z}^{|V|-1} / \operatorname{Im}(M).
\]

This definition is mathematically new in this catalog context and should be made precise enough to support theorem statements.

---

## Target Theorems

You must prove at least 3 substantial theorems. The following are the primary targets.

### Theorem 1: Integrality of the scaled reduced Laplacian
**Statement.** If \(D\) is a common denominator for all edge conductances (or for all entries of the reduced rational Laplacian), then the scaled reduced Laplacian has integer entries.

A Lean-shape target:

```lean
theorem integerScaledReducedLaplacian_entries_integral
  (Γ : RationalMetricGraph α)
  (v0 : α)
  (D : ℕ)
  (hD : Γ.ClearsDenominators D) :
  ∀ i j, ((Γ.integerScaledReducedLaplacian v0 D) i j : ℚ) =
    (D : ℚ) * (Γ.reducedLaplacianQ v0 i j)
```

and a companion theorem asserting the codomain really lands in `ℤ` / integer matrices:

```lean
theorem integerScaledReducedLaplacian_isInteger
  (Γ : RationalMetricGraph α)
  (v0 : α)
  (D : ℕ)
  (hD : Γ.ClearsDenominators D) :
  Γ.integerScaledReducedLaplacian v0 D ∈ Matrix.integerMatrices
```

If `Matrix.integerMatrices` is not the right existing notion, define an appropriate predicate.

**Why it matters.** This is the arithmetic portal theorem: it converts metric data into exact integer linear algebra.

---

### Theorem 2: Determinant equals weighted spanning-tree number up to scaling
Let \(n = |V|\). Define the weighted tree number
\[
\tau_\ell(G) := \sum_{T \text{ spanning tree}} \prod_{e\in T} c_e.
\]
Then:
\[
\det(L_\mathbb{Q}^{(v_0)}) = \tau_\ell(G),
\qquad
\det(M) = D^{n-1}\tau_\ell(G).
\]

A Lean-shape target:

```lean
theorem det_integerScaledReducedLaplacian
  (Γ : RationalMetricGraph α)
  [Fintype α] [DecidableEq α]
  (hconn : Γ.Connected)
  (v0 : α)
  (D : ℕ)
  (hD : Γ.ClearsDenominators D) :
  (Γ.integerScaledReducedLaplacian v0 D).det =
    (D : ℤ) ^ (Fintype.card α - 1) *
      Γ.weightedTreeNumberInt
```

or, if the tree number is first naturally rational:

```lean
theorem det_integerScaledReducedLaplacian_rat
  ...
  : ((Γ.integerScaledReducedLaplacian v0 D).det : ℚ) =
      (D : ℚ) ^ (Fintype.card α - 1) * Γ.weightedTreeNumber
```

**Why it matters.** This is the exact weighted Kirchhoff theorem in the rational metric setting. It upgrades a numerical invariant into a certified arithmetic one.

---

### Theorem 3: Smith normal form classifies the finite arithmetic Jacobian candidate
If
\[
UMV = \operatorname{diag}(d_1,\dots,d_r,0,\dots,0)
\]
is a Smith normal form of \(M\), with \(d_i \mid d_{i+1}\), then
\[
K_{\mathrm{arith}}(G,\ell,v_0,D) \cong \bigoplus_i \mathbb{Z}/d_i\mathbb{Z}
\]
whenever \(M\) has full rank (which should follow from connectedness of the graph and reduced Laplacian theory).

A Lean-shape target:

```lean
theorem cokernel_integerScaledReducedLaplacian_equiv_snf
  (Γ : RationalMetricGraph α)
  [Fintype α] [DecidableEq α]
  (hconn : Γ.Connected)
  (v0 : α)
  (D : ℕ)
  (hD : Γ.ClearsDenominators D) :
  Nonempty (
    Γ.finiteJacobianPresentation v0 D ≃+
      ⨁ i, ZMod ((Γ.smithInvariant v0 D i).natAbs)
  )
```

If the direct-sum API is too heavy, prove a cardinality theorem plus a decomposition theorem in stages. But do not retreat to a vacuous statement. The theorem should clearly identify the cokernel with the SNF invariant factors.

**Why it matters.** This is the classification theorem: it says the finite arithmetic shadow of the tropical Jacobian is not merely finite, but explicitly decomposed.

---

### Theorem 4: Product of nonzero Smith invariants equals determinant
For a full-rank reduced Laplacian minor,
\[
\prod_i d_i = |\det(M)|.
\]

Lean-shape target:

```lean
theorem prod_smithInvariant_eq_det
  (A : Matrix (Fin n) (Fin n) ℤ)
  (hfull : A.det ≠ 0) :
  ∏ i, (smithDiagonal A i) = Int.natAbs A.det
```

Then instantiate for `Γ.integerScaledReducedLaplacian v0 D`.

**Why it matters.** This links classification data to enumerative data and is the formal bridge from SNF to weighted tree numbers.

---

### Theorem 5: Cycle graph closed form
For the cycle graph \(C_n\) with rational lengths \(\ell_1,\dots,\ell_n\), prove a closed-form expression for the reduced weighted Laplacian determinant and identify the invariant-factor product explicitly.

Expected formula:
\[
\tau_\ell(C_n) = \sum_{i=1}^n \prod_{j\neq i} c_j
= \left(\prod_{j=1}^n c_j\right)\left(\sum_{i=1}^n \ell_i\right).
\]

After clearing denominators, derive an exact integer determinant formula.

Lean-shape target:

```lean
theorem weightedTreeNumber_cycleGraph
  (n : ℕ) (hn : 3 ≤ n)
  (ℓ : Fin n → ℚ)
  (hpos : ∀ i, 0 < ℓ i) :
  let Γ := RationalMetricGraph.cycle n ℓ
  Γ.weightedTreeNumber =
    (∏ i, (ℓ i)⁻¹) * (∑ i, ℓ i)
```

**Why it matters.** This gives a testbed family with explicit formulas, ideal for both proof mining and `demo.py`.

---

## Conjecture with Falsifiable Computational Prediction

You must state and investigate at least one conjecture. Here is the right one to include.

### Conjecture: Canonical torsion independence under denominator clearing
Let \(D\) and \(D'\) be two positive integers clearing denominators for the same rational metric graph. Then the finite abelian groups presented by
\[
D L_\mathbb{Q}^{(v_0)} \quad \text{and} \quad D' L_\mathbb{Q}^{(v_0)}
\]
have a canonically related decomposition, and after dividing out the obvious scalar artifact, the invariant factors encode a denominator-independent arithmetic Jacobian.

**Testable prediction.**
For cycle graphs \(C_n\) and theta graphs with random rational lengths of bounded denominator, compute SNFs for several valid choices of \(D\). The raw invariant factors may scale, but a normalized invariant signature should remain unchanged. If no such normalization exists even in low genus examples, the conjecture is false.

This is falsifiable: your `demo.py` should search for counterexamples.

---

## Proof Strategy Architecture

You must not present a single proof hint. Use multiple strategies and decide which is most promising.

### Strategy A: Direct arithmetic reduction from catalog Laplacian theorems
1. Use existing weighted Laplacian definitions and principal minor lemmas from the catalog.
2. Define a denominator-clearing integer \(D\) and prove entrywise integrality by `rcases` on adjacency cases and `field_simp` on rational conductances.
3. Invoke or rebuild the weighted Matrix-Tree argument for the reduced minor determinant.
4. Pass from determinant to finite cokernel size and then to SNF invariant factors.

**Why promising.** This is closest to the catalog and minimizes foundational overhead. It should produce the determinant theorem quickly and create the matrix needed for the SNF story.

### Strategy B: Chip-firing / cokernel first, then metric interpretation
1. Start from the discrete chip-firing critical group formalism already present in the canonical-kernel theorems.
2. Show that a rational metric graph with denominator clearing induces an integer weighted chip-firing matrix.
3. Prove the arithmetic Jacobian candidate is exactly the chip-firing critical group of that weighted graph.
4. Use standard abelian-group classification via SNF.

**Why promising.** This is likely the strongest route to the group-structure theorem, because chip-firing literature already knows that cokernels of reduced Laplacians classify critical groups.

### Strategy C: Incidence-factorization route
1. Express the weighted Laplacian as \(L = BWB^\top\), with \(B\) an incidence matrix and \(W\) a diagonal conductance matrix.
2. After denominator clearing, obtain an integer matrix factorization.
3. Use Cauchy–Binet to derive the weighted tree-number formula.
4. Analyze rank and cokernel via the incidence presentation.

**Why promising.** This is conceptually the cleanest and gives the deepest bridge to combinatorial Hodge theory and electrical networks. It may require more setup, but it is the most revolutionary route.

**Recommended order.**
- First execute **Strategy A** to secure integrality and determinant results.
- Then use **Strategy B** for the SNF/cokernel classification theorem.
- If time permits, add **Strategy C** as the conceptual unifier and for stronger future directions.

---

## Lean 4 Formalization Targets

Your formalization should aim for precise theorem statements, not vague comments. Include theorem signatures close to the following shapes, adapted to actual Mathlib APIs:

```lean
structure RationalMetricGraph (α : Type _) [Fintype α] [DecidableEq α] where
  adj : α → α → Prop
  symm : Symmetric adj
  loopless : ∀ v, ¬ adj v v
  length : {u v : α} → adj u v → ℚ
  length_pos : ∀ {u v} (h : adj u v), 0 < length h
```

```lean
def RationalMetricGraph.conductance ... : ℚ := (Γ.length h)⁻¹
```

```lean
def RationalMetricGraph.reducedLaplacianQ
  (Γ : RationalMetricGraph α) (v0 : α) :
  Matrix (Fin (Fintype.card α - 1)) (Fin (Fintype.card α - 1)) ℚ := ...
```

```lean
def RationalMetricGraph.integerScaledReducedLaplacian
  (Γ : RationalMetricGraph α) (v0 : α) (D : ℕ) :
  Matrix (Fin (Fintype.card α - 1)) (Fin (Fintype.card α - 1)) ℤ := ...
```

```lean
def RationalMetricGraph.weightedTreeNumber (Γ : RationalMetricGraph α) : ℚ := ...
```

```lean
def RationalMetricGraph.finiteJacobianPresentation
  (Γ : RationalMetricGraph α) (v0 : α) (D : ℕ) : AddCommGroupCat := ...
```

If existing catalog graph structures are more suitable, adapt to them rather than rebuilding unnecessarily. But you must add at least one genuinely new definition not already present in the catalog.

---

## Deep Proof Tactic Requirements

Your file must contain at least 3 theorems whose proofs materially use techniques such as:

- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- nontrivial `calc`
- matrix-entry extensionality plus case splits
- rank/full-rank arguments
- quotient/cokernel reasoning

In particular:
- The integrality theorem should use `rcases` and `field_simp`.
- The determinant scaling theorem should use a multi-step `calc`.
- The full-rank / nonzero determinant argument should use `by_contra` or a kernel-based contradiction from connectedness.

Do **not** let the core results collapse to `native_decide`, `decide`, `norm_num`, or `rfl`.

---

## Cross-Domain Connections You Must Surface

This project is strongest when framed not as isolated graph theory, but as a new arithmetic-combinatorial interface.

### 1. Tropical geometry ↔ algebraic graph theory
The tropical Jacobian of a metric graph is a real torus, but rational edge lengths create a hidden exact arithmetic layer. Your SNF theorem makes that layer computable and classifiable.

### 2. Number theory ↔ electrical network theory
Rational conductances are arithmetic resistive networks. Clearing denominators converts network response data into integer lattices and finite abelian groups. This is a discrete arithmetic analogue of passing from rational forms to integral models.

### 3. Combinatorics ↔ homological algebra
The reduced Laplacian presents a cokernel group; the Smith form is the classification of that finitely generated module. This is the combinatorial shadow of lattice homology.

### 4. Tropical geometry ↔ algorithmic exact computation
Existing numerical SVD approaches approximate Jacobian structure; SNF gives exact decomposition. This matters for certified experiments and opens exact symbolic tropical computation.

### 5. Potential bridge to physics
Weighted Laplacians govern resistor networks, diffusion, and discrete Gaussian free fields. Exact invariant factors may encode arithmetic obstructions in quantized network models.

---

## Application Keywords

Include these explicitly in your paper and metadata-style summaries:

**Application keywords:** tropical Jacobian, Smith normal form, metric graph, chip-firing, critical group, sandpile group, weighted Laplacian, Matrix-Tree theorem, exact arithmetic, rational conductance network, arithmetic tropical geometry, finite abelian group decomposition, combinatorial Hodge theory, electrical networks.

---

## Computational Deliverable

You must produce a **verified algorithm or computational method**, not just theorem statements.

### Required algorithm
Implement exact rational Smith normal form computation for the integer-scaled reduced Laplacian of:
- cycle graphs \(C_n\),
- at least one nontrivial family such as theta graphs or banana graphs.

The algorithm should:
1. construct the weighted rational Laplacian,
2. choose a common denominator \(D\),
3. build the integer-scaled reduced minor,
4. compute its determinant,
5. compute or approximate its Smith normal form,
6. compare the product of invariant factors with the determinant,
7. compare with the existing numerical SVD-based computation from `algorithms.py`.

This is not optional. The computational method is part of the scientific content.

---

## demo.py Requirements

Your `demo.py` must:
- let the user choose a graph family and rational edge lengths,
- display the reduced rational Laplacian,
- display the chosen denominator \(D\),
- display the integer-scaled matrix,
- compute determinant and invariant factors,
- verify the product-of-invariants identity,
- compare against numerical SVD output,
- search for evidence for or against the denominator-independence conjecture.

Make the demo interactive enough to expose the mathematics, not just print a matrix.

---

## Mandatory Deliverables

You must produce all of the following:

### 1. `FUTURE_DIRECTIONS.md`
Provide 3–5 original research directions. Each direction must include:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
At least one direction must bridge to a different domain, such as:
- tropical Hodge theory,
- arithmetic matroids,
- statistical physics on resistor networks,
- complexity theory of exact graph invariants.

### 2. `RESEARCH_PAPER.md`
A standalone scientific document. Someone reading only this paper must understand:
- the problem,
- the new definitions,
- the exact theorems,
- the proof architecture,
- the computational experiments,
- why the discovery matters,
- what should be investigated next.

Do not assume access to the Lean code.

### 3. `ARTICLE.md`
Write this in **Scientific American style**: vivid, accessible, idea-centered. Explain why rational metric graphs secretly carry finite arithmetic structure and why Smith normal form reveals it. Do **not** focus on formal verification machinery.

### 4. Verified algorithm / computational method
As described above.

### 5. `demo.py`
As described above.

---

## Concrete Theorem Checklist

At minimum, your Lean development should include the following theorem-level milestones:

1. **Entrywise integrality after denominator clearing**
2. **Reduced determinant scales correctly**
3. **Connectedness implies full rank of reduced weighted Laplacian**
4. **Product of Smith invariants equals determinant**
5. **Cycle graph closed formula**
6. **At least one theorem linking the arithmetic Jacobian candidate to chip-firing / critical group theory**

If one of these exact formulations turns out to be false as stated, do not force it. Refine the statement and produce a **counterexample theorem** or corrected theorem. Clearing a false conjecture is scientifically valuable.

---

## What Would Make This Revolutionary

A successful outcome here would establish an exact arithmetic layer beneath tropical Jacobians of rational metric graphs. That would open a program in **arithmetic tropical geometry**, where one studies not only the real torus \(J(\Gamma)\), but also the finite integral invariants cut out by rational models. This could lead to:

- exact classification of tropical graph invariants,
- arithmetic moduli of metric graphs,
- new bridges to Néron component groups and degenerations of algebraic curves,
- exact algorithms for tropical Abel–Jacobi data,
- new interactions between chip-firing, resistor networks, and arithmetic geometry.

This is the kind of result that changes the language of the area: from approximate spectral numerics to exact arithmetic structure.

Be bold, be precise, and make the arithmetic heart of rational metric graphs impossible to ignore.

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
