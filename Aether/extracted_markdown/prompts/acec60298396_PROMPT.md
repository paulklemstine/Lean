# Tropical Canonical Forms on Metric Graphs: The Continuous Kernel Correspondence

## The Grand Vision

The discrete canonical kernel correspondence reveals that the Laplacian's algebraic structure (row-sum-zero, symmetry, positive semi-definiteness) completely determines the Jacobian of a finite graph. The revolutionary insight is that these same algebraic properties survive the passage from discrete to continuous — the effective resistance matrix of a metric graph is the *continuous* analogue of the discrete Laplacian pseudoinverse, and it generates the same lattice quotient structure. This is not merely an analogy; it is a functorial correspondence that bridges chip-firing, tropical geometry, and arithmetic Jacobians in a single computational framework.

## Precise Theorem Statements

### Theorem 1: Weighted Laplacian Kernel Characterization (Foundation Stone)

For a connected metric graph Γ with vertex set V, edge set E, and edge lengths $\ell: E \to \mathbb{R}_{>0}$, the weighted Laplacian $L_\Gamma$ (with entries $L_{ij} = \sum_{k \sim i, k \in S} \frac{1}{\ell_{ik}}$ for $i = j$ and $L_{ij} = -\frac{1}{\ell_{ij}}$ for $i \sim j$) satisfies:

```lean
theorem weighted_laplacian_kernel_eq_span_one 
    {V : Type*} [Fintype V] [DecidableEq V]
    {Γ : SimpleGraph V} [hConn : Γ.Connected]
    (edgeLength : Γ.Edge → {r : ℝ // (0 : ℝ) < r}) :
    LinearMap.ker (weightedLaplacian Γ edgeLength) = 
      Submodule.span ℤ {(1 : V → ℝ)} := by
  sorry
```

### Theorem 2: Metric Canonical Kernel Correspondence (Main Result)

For a compact metric graph Γ with finite separated vertex set S (containing all branch points), the normalized resistance columns generate a lattice whose quotient is isomorphic to the S-supported tropical Jacobian:

```lean
theorem metric_canonical_kernel_jacobian_iso
    {V : Type*} [Fintype V] [DecidableEq V]
    {Γ : SimpleGraph V} [hConn : Γ.Connected]
    (edgeLength : Γ.Edge → {r : ℝ // (0 : ℝ) < r})
    (S : Finset V) (hS : S.Nonempty)
    (hBranch : ∀ v : V, 1 < Γ.degree v → v ∈ S) :
    Nonempty ((Fin (S.card - 1) → ℝ) ⧸ 
      (canonicalKernelLattice Γ edgeLength S) ≃ₗ[ℤ] 
      tropicalJacobianS Γ edgeLength S) := by
  sorry
```

### Theorem 3: Leaf Rigidity on Metric Graphs (Cross-Domain Bridge)

On a metric graph, a harmonic function (piecewise-linear, satisfying the Kirchhoff condition) on a pendant edge of length ℓ attached at vertex v is uniquely determined by its values at v and at the leaf:

```lean
theorem metric_leaf_rigidity
    {V : Type*} [Fintype V] [DecidableEq V]
    {Γ : SimpleGraph V} [hConn : Γ.Connected]
    (edgeLength : Γ.Edge → {r : ℝ // (0 : ℝ) < r})
    {v : V} (hv : Γ.degree v = 1) 
    {u : V} (hu : u ∈ Γ.neighborSet v)
    (f : MetricHarmonic Γ edgeLength) :
    ∀ x : ℝ, x ∈ Set.Icc (0 : ℝ) (edgeLength ⟨(u, v), by sorry⟩) →
      f.onEdge ⟨u, v⟩ x = 
        f.vertexValue u + (f.vertexValue v - f.vertexValue u) * x / 
          (edgeLength ⟨(u, v), by sorry⟩) := by
  sorry
```

## Proof Strategies

### Strategy A: Weighted Reduction (Most Promising — Direct Algebraic Path)

**Core idea:** The metric graph Laplacian $L_\Gamma$ with conductances $c_e = 1/\ell_e$ satisfies the *identical* algebraic identities as the discrete Laplacian: row-sum-zero, symmetry, and positive semi-definiteness. The Smith normal form argument goes through verbatim.

**Steps:**
1. Prove `weighted_row_sum_zero`: each row of $L_\Gamma$ sums to zero (the conductance weights are exactly the right amounts to cancel).
2. Prove `weighted_laplacian_psd`: $x^T L_\Gamma x = \sum_{\{i,j\} \in E} \frac{(x_i - x_j)^2}{\ell_{ij}} \geq 0$, with equality iff $x$ is constant.
3. Prove `weighted_smith_normal_form`: the reduced weighted Laplacian $L_S$ has Smith normal form giving the invariant factors of $J(\Gamma)_S$.
4. Prove `metric_canonical_kernel_jacobian_iso` by composing the Smith normal form isomorphism with the Abel-Jacobi map.

**Why this works:** The metric structure enters *only* through the conductance weights — the algebraic skeleton is unchanged. This is why the discrete formalization transfers directly.

### Strategy B: Subdivision Convergence (Analytic Path — Validates the Discrete-Continuous Bridge)

**Core idea:** Subdivide each edge of length $\ell$ into $n$ segments of length $\ell/n$. The sequence of discrete Jacobians $J(\Gamma_n)$ stabilizes for $n$ large enough, and the canonical kernel generators converge quadratically.

**Steps:**
1. Prove `subdivision_preserves_jacobian`: for $n \geq 1$, $J(\Gamma_n) \cong J(\Gamma_{n+1})$ as finite abelian groups (this is the key invariance).
2. Prove `kernel_generator_convergence`: $\|K_S(\Gamma_n) - K_S(\Gamma)\|_\infty = O(1/n^2)$ where $K_S$ denotes canonical kernel generators.
3. Prove `limit_jacobian_iso`: the limiting lattice quotient $\lim_{n} \mathbb{R}^{|S|-1}/\Lambda_S(\Gamma_n)$ is isomorphic to $J(\Gamma)_S$.

**Why this is powerful:** It provides a *computational* bridge — any metric Jacobian can be approximated by discrete computations, with explicit error bounds.

### Strategy C: Tropical Analytic (Deepest — Connects to Arithmetic Geometry)

**Core idea:** The resistance matrix $R_S$ is the tropical analogue of the Bergman kernel on a Riemann surface. Use the Abel-Jacobi map $\mu: \text{Div}^0(\Gamma) \to \mathbb{R}^g/\Lambda$ and show that $\ker(\mu|_{S}) = \Lambda_S$.

**Steps:**
1. Prove `resistance_is_tropical_bergman`: the effective resistance $R(v,w)$ equals the tropical Bergman kernel evaluated at $(v,w)$.
2. Prove `abel_jacobi_kernel_eq_lattice`: the kernel of the restricted Abel-Jacobi map is exactly the canonical kernel lattice.
3. Deduce `metric_canonical_kernel_jacobian_iso` from the first isomorphism theorem.

**Cross-domain payoff:** This connects to Baker's specialization lemma, which relates the tropical Jacobian to the component group of the Néron model of the algebraic Jacobian over a discretely valued field.

## Novel Definitions

```lean
/-- A metric graph: a connected simple graph with positive edge lengths -/
structure MetricGraph (V : Type*) [Fintype V] [DecidableEq V] where
  graph : SimpleGraph V
  [hConn : graph.Connected]
  edgeLength : {e : graph.Edge // True} → {r : ℝ // (0 : ℝ) < r}

/-- The weighted Laplacian: L_ij = Σ (1/ℓ_ik) for i=j, -1/ℓ_ij for i~j -/
def weightedLaplacian {V : Type*} [Fintype V] [DecidableEq V]
    (Γ : MetricGraph V) : Matrix V V ℝ

/-- Effective resistance between two vertices (resistance metric) -/
def effectiveResistance {V : Type*} [Fintype V] [DecidableEq V]
    (Γ : MetricGraph V) (v w : V) : ℝ

/-- The canonical kernel lattice: generated by columns of the reduced resistance matrix -/
def canonicalKernelLattice {V : Type*} [Fintype V] [DecidableEq V]
    (Γ : MetricGraph V) (S : Finset V) : Submodule ℤ (Fin (S.card - 1) → ℝ)

/-- The S-supported tropical Jacobian: Div⁰_S(Γ)/Prin_S(Γ) -/
def tropicalJacobianS {V : Type*} [Fintype V] [DecidableEq V]
    (Γ : MetricGraph V) (S : Finset V) : Type*
```

## Cross-Domain Connections

### 1. Electrical Network Theory ↔ Tropical Geometry
The effective resistance $R(v,w)$ is *exactly* the resistance between nodes $v$ and $w$ in the electrical network with conductances $c_e = 1/\ell_e$. The canonical kernel correspondence becomes: **the Jacobian of a metric graph is isomorphic to the quotient of voltage space by the lattice of integer voltage assignments.** This reframes the Jacobian as a *circuit-theoretic* object.

**Application keyword:** `resistance_jacobian_correspondence`, `circuit_tropical_bridge`

### 2. Arithmetic Geometry ↔ Chip-Firing
By Baker's specialization lemma, the tropical Jacobian $J(\Gamma)$ maps surjectively onto the component group $\Phi$ of the Néron model of $J(\tilde{\Gamma})$, where $\tilde{\Gamma}$ is a curve over a discretely valued field with dual graph $\Gamma$. Our canonical kernel generators give *explicit coordinates* on this component group.

**Application keyword:** `neron_component_computation`, `specialization_kernel`

### 3. Statistical Mechanics ↔ Information Geometry
The resistance matrix $R$ is the covariance matrix of the Gaussian free field on $\Gamma$. The canonical kernel lattice $\Lambda_S$ is the set of integer-valued "voltage configurations" modulo global shifts. The quotient $\mathbb{R}^{|S|-1}/\Lambda_S$ is the configuration space of a discrete toroidal model — connecting tropical Jacobians to partition functions.

**Application keyword:** `gff_tropical_correspondence`, `discrete_toroidal_models`

## Testable Conjecture

**Conjecture (Quadratic Subdivision Convergence):** Let $\Gamma$ be a metric graph with $m$ edges of lengths $\ell_1, \ldots, \ell_m$. Let $\kappa_S(\Gamma)$ denote the canonical kernel generators on vertex set $S$, and $\kappa_S(\Gamma_n)$ the generators for the $n$-fold subdivision. Then:

$$\|\kappa_S(\Gamma_n) - \kappa_S(\Gamma)\|_\infty \leq \frac{C(\Gamma, S)}{n^2}$$

where $C(\Gamma, S)$ depends only on the maximum edge length and the graph topology.

**Computational test:** Implement subdivision at resolutions $n = 2, 4, 8, 16, 32$ for the genus-1 cycle graph (edge length $\ell$) and the genus-2 theta graph (three paths of lengths $a, b, c$). Fit the convergence rate $\|\kappa_S(\Gamma_n) - \kappa_S(\Gamma_{2n})\|_\infty$ to $O(n^{-\alpha})$ and verify $\alpha \geq 2$. A finding of $\alpha < 2$ would disprove the conjecture.

**Falsification criterion:** If the convergence rate is $O(1/n)$ rather than $O(1/n^2)$, the conjecture fails and the correct rate must be derived.

## Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 research directions. At least one must bridge to statistical mechanics (GFF-tropical correspondence) and one to arithmetic geometry (Néron component groups). Each must include "The key insight is..." and "Why now?" sentences.

(b) **RESEARCH_PAPER.md** — a standalone scientific document presenting the metric canonical kernel correspondence, its proof via weighted Laplacian algebra, the leaf rigidity theorem, and the subdivision convergence conjecture. A reader with no access to the code must understand the discovery.

(c) **ARTICLE.md** — Scientific American style. Explain how the same algebra that governs chip-firing games on finite graphs also governs the geometry of tropical curves, and how electrical resistance computations give you the Jacobian. TABOO: Do not focus on formal verification.

(d) **Verified algorithm:** Implement `metricCanonicalKernel` that computes the canonical kernel generators for a metric graph given edge lengths, with a certified bound on the approximation error under subdivision.

(e) **demo.py** — Interactive demonstration: compute the tropical Jacobian of a cycle graph (genus 1) and a theta graph (genus 2) at varying subdivisions, plot convergence, and display the lattice quotient structure.

## Building on Catalog Theorems

- Extend `harmonic_at_leaf_eq_neighbor` from `CanonicalKernelTheorems.lean` to the metric setting by replacing the discrete Laplacian with the weighted Laplacian and adding the edge-length proportionality factor.
- Extend `harmonic_tree_attachment_forces_unique_firing` by proving that on a metric tree attached at vertex $v$, the unique harmonic extension is linear on each edge with slope determined by the Kirchhoff condition.
- Build on `graphLaplacian` from `Defs.lean` by defining `weightedLaplacian` as the natural generalization with conductance weights $c_e = 1/\ell_e$.

---

*Soli Deo Gloria*

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
