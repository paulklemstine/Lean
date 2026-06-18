Soli Deo Gloria

## Assignment: Break open algorithmic tropical Hodge theory via a continuous canonical kernel calculus on metric graphs

The canonical kernel calculus developed here — especially the rigidity, energy, and uniqueness phenomena already established for discrete models with pendant structure — is not the endpoint. It is the shadow of a deeper theorem: on a compact metric graph, there should exist a canonical Green-kernel package that simultaneously controls tropical potential theory, effective resistance, Abel–Jacobi coordinates, and quantum graph resolvents. Formalizing this in Lean 4 would not be an incremental extension. It would create a certified bridge between combinatorial divisor theory, tropical geometry, and spectral analysis on one-dimensional spaces.

Your task is to prove genuinely new theorems in this direction, with at least one new definition, at least three substantial proofs, and at least one cross-domain theorem. Build on catalog results about the existing canonical kernel calculus, energy identities, normalized uniqueness, and pendant-edge rigidity; use them as the discrete finite-model skeleton from which the continuous theory is extracted.

## Mode: prove

## Core Vision

Construct a **continuous canonical kernel calculus** for finite compact metric graphs by passing from vertex-supported kernels to point-supported piecewise-linear harmonic kernels, and prove that the resulting kernel:
1. is uniquely characterized by a Laplacian/normalization principle,
2. recovers effective resistance and tropical Abel–Jacobi data,
3. is compatible with subdivision/refinement,
4. admits an algorithmic approximation by finite graph models,
5. connects to a second domain: quantum graph spectral theory or Gaussian free fields.

This would open the field of **certified algorithmic tropical Hodge theory**: a mathematically exact and computationally effective theory of harmonic kernels on tropical curves.

---

## New mathematical structure to define

You must define at least one genuinely new concept not already present in the catalog. A strong candidate is:

### `MetricGraphKernel`
A structure encoding a compact metric graph together with a canonical normalized Green kernel.

Suggested ingredients:
- a type of points `X`,
- a path metric `dist : X → X → ℝ`,
- a finite combinatorial model / subdivision data,
- a space of piecewise-linear functions with integer slope changes,
- a Laplacian operator to signed measures/divisors,
- a normalized kernel `g : X → X → ℝ`,
- symmetry, continuity, piecewise-linearity off diagonal, and zero-mean or basepoint normalization.

You may also define a lighter intermediate notion:

### `RefinementSystem`
A directed system of finite weighted graphs whose geometric realization converges to a metric graph, together with compatibility maps for kernel functions.

or

### `NormalizedPotential`
A function `f : X → ℝ` solving a Laplacian equation with a normalization constraint, viewed as the continuous analogue of a canonical kernel column.

This definition is not decoration: it should be used in at least one theorem in an essential way.

---

## Precise theorem targets

You should aim to formalize at least three of the following, and preferably all four.

### Theorem 1: Uniqueness of normalized continuous kernel
For every compact connected metric graph `Γ` and every point `p : Γ`, there exists a unique normalized potential `g_p : Γ → ℝ` such that:
- `Δ g_p = δ_p - μ` for a canonical unit-mass reference measure `μ`,
- `∫ g_p dμ = 0`,
- `g_p` is continuous and piecewise affine on each edge away from `p`.

This is the continuous master theorem from which the others flow.

#### Lean-style target signature
A realistic formal target may look like:
```lean
theorem exists_unique_normalized_potential
  (Γ : MetricGraphKernel)
  (hconn : ConnectedSpace Γ.X)
  (p : Γ.X) :
  ∃! g : Γ.X → ℝ,
    Γ.IsNormalizedPotential p g
```

If you choose a basepoint normalization instead of integral-zero normalization:
```lean
theorem exists_unique_based_kernel
  (Γ : MetricGraphKernel)
  (hconn : ConnectedSpace Γ.X)
  (p q₀ : Γ.X) :
  ∃! g : Γ.X → ℝ,
    Γ.IsBasedPotential q₀ p g
```

### Theorem 2: Kernel symmetry and resistance identity
The canonical kernel is symmetric and its polarization computes effective resistance:
\[
r(p,q)=g(p,p)+g(q,q)-2g(p,q).
\]

This is the theorem that transforms the kernel from a formal solution into geometric data.

#### Lean-style target signature
```lean
theorem kernel_symm
  (Γ : MetricGraphKernel) :
  Symmetric Γ.g

theorem effectiveResistance_eq
  (Γ : MetricGraphKernel)
  (p q : Γ.X) :
  Γ.effectiveResistance p q = Γ.g p p + Γ.g q q - 2 * Γ.g p q
```

### Theorem 3: Subdivision/refinement invariance
If `G'` is a subdivision of a finite weighted graph model `G`, then the discrete canonical kernel pulled back along the refinement agrees with the original kernel on old vertices. In the limit, the continuous kernel is independent of the chosen refinement system.

This theorem is conceptually decisive: it justifies the passage from combinatorics to geometry.

#### Lean-style target signature
```lean
theorem kernel_invariant_under_subdivision
  (G G' : WeightedGraphModel)
  (hsub : G'.IsSubdivisionOf G)
  (u v : G.V) :
  G'.kernel (hsub.embed u) (hsub.embed v) = G.kernel u v
```

And for the limiting object:
```lean
theorem limit_kernel_independent_of_refinement
  (Γ : MetricGraphKernel)
  (R₁ R₂ : RefinementSystem Γ) :
  R₁.limitKernel = R₂.limitKernel
```

### Theorem 4: Tropical Abel–Jacobi compatibility
The difference of kernel columns defines a harmonic 1-form class, and this class agrees with the Abel–Jacobi image of `p - q`. In effect, the canonical kernel gives coordinates on the tropical Jacobian.

#### Lean-style target signature
```lean
theorem kernelColumn_diff_represents_AbelJacobi
  (Γ : MetricGraphKernel)
  (p q : Γ.X) :
  Γ.harmonicClassOf (fun x => Γ.g p x - Γ.g q x) = Γ.abelJacobi (p, q)
```

This theorem is harder to fully formalize, but even a finite-model precursor would already be a breakthrough.

---

## A cross-domain theorem you should include

You must include at least one theorem that explicitly bridges to another domain.

### Option A: Quantum graph spectral theory
Show that the canonical kernel is the zero-frequency resolvent / pseudoinverse kernel of the metric graph Laplacian.

Informally:
\[
g(x,y) = (\Delta^\dagger)(x,y),
\]
with normalization removing constants.

#### Lean-style target signature
```lean
theorem kernel_eq_laplacian_pseudoinverse
  (Γ : MetricGraphKernel) :
  Γ.g = Γ.laplacianPseudoInverseKernel
```

Why this matters: it identifies tropical potentials with the same kernel that governs Schrödinger evolution and wave propagation on quantum graphs. This opens certified spectral geometry on tropical curves.

### Option B: Gaussian free field covariance
Show that the normalized kernel is the covariance kernel of the centered Gaussian free field on the graph.

#### Lean-style target signature
```lean
theorem kernel_is_GFF_covariance
  (Γ : MetricGraphKernel) :
  Γ.IsCovarianceKernel Γ.gff Γ.g
```

Why this matters: it imports probabilistic intuition and enables tropical-probabilistic dualities.

Either option satisfies the cross-domain requirement; Option A is likely more Lean-feasible if you work with finite weighted graph Laplacians first.

---

## Most promising proof architectures

You must not merely state results. Develop at least 2–3 plausible proof routes and choose one deliberately.

### Strategy A: Discrete-to-continuous via subdivision limits
1. Start from the catalog’s discrete canonical kernel theorems on finite weighted graphs.
2. Define edge subdivisions and prove exact invariance of kernel values on original vertices.
3. Use compatible refinements to define the kernel at interior points as a limit of discrete kernels.
4. Prove the limit satisfies the desired Laplacian and normalization axioms.
5. Use energy minimization to get uniqueness.

**Why this is promising:** it maximally reuses existing catalog theorems and turns the continuous theory into a certified colimit construction. It is the best route if the current codebase already has strong finite-graph infrastructure.

### Strategy B: Variational/energy minimization
1. Define normalized potentials as minimizers of Dirichlet energy under a divisor/Laplacian constraint.
2. Prove strict convexity of energy modulo constants.
3. Derive uniqueness from convexity and existence from compactness/coercivity on a finite-dimensional PL function space.
4. Extract symmetry and resistance identities from polarization.

**Why this is promising:** it is conceptually clean and reveals the Hodge-theoretic structure. It is likely the best route for proving symmetry and resistance formulas elegantly. If you can encode the function space concretely on a finite model, this becomes highly robust.

### Strategy C: Linear-algebraic pseudoinverse on weighted models
1. Represent each finite metric graph model by a weighted Laplacian matrix.
2. Define the kernel as the Moore–Penrose pseudoinverse after quotienting constants.
3. Prove symmetry, positivity, and resistance identities by matrix arguments.
4. Then prove subdivision invariance by explicit block-matrix Schur complement calculations.

**Why this is promising:** this is strongest for the quantum-graph bridge and algorithm extraction. It may be technically heavier in Lean but gives a direct computational method and a natural `demo.py`.

**Recommended plan:** combine A + B. Use A to construct the object from catalog kernels and B to prove uniqueness and characterization. Add C locally for the algorithmic and spectral theorem.

---

## Concrete theorem sequence to implement

A strong sequence is:

1. Define `WeightedGraphModel` and `IsSubdivisionOf`.
2. Prove subdivision preserves discrete energy and kernel values on old vertices.
3. Define `NormalizedPotential` and prove existence/uniqueness on finite weighted graphs by energy minimization.
4. Define `effectiveResistance` from the kernel and prove the resistance identity.
5. Package the compatible family into `MetricGraphKernel`.
6. Prove a finite-model precursor to Abel–Jacobi compatibility or pseudoinverse equivalence.
7. Extract a verified approximation algorithm.

This already satisfies the requirement of at least three deep theorems with induction / `rcases` / `by_contra` / `field_simp` / multi-step `calc`.

---

## Suggested substantial theorems with proof-tactic depth

You need at least 3 nontrivial proofs. Here are suitable candidates:

### Theorem A: Energy strict positivity modulo constants
```lean
theorem energy_pos_of_nonconst
  (G : WeightedGraphModel)
  (f : G.V → ℝ)
  (hnot : ¬ IsConstant f) :
  0 < G.dirichletEnergy f
```
Expected tactics:
- `by_contra` to reduce to zero energy,
- `rcases` on a witness of nonconstancy,
- multi-step `calc` using sum-of-squares decomposition.

### Theorem B: Kernel uniqueness from zero-energy difference
```lean
theorem normalizedPotential_unique
  (G : WeightedGraphModel)
  (p : G.V)
  {f g : G.V → ℝ}
  (hf : G.IsNormalizedPotential p f)
  (hg : G.IsNormalizedPotential p g) :
  f = g
```
Expected tactics:
- show `f - g` is harmonic and normalized,
- prove zero energy,
- invoke positivity modulo constants,
- use normalization to eliminate the constant.

### Theorem C: Resistance polarization identity
```lean
theorem effectiveResistance_eq_energy_of_kernel_diff
  (G : WeightedGraphModel)
  (p q : G.V) :
  G.effectiveResistance p q = G.dirichletEnergy (fun x => G.kernel p x - G.kernel q x)
```
Expected tactics:
- multi-step `calc`,
- bilinearity of energy,
- symmetry of kernel,
- cancellation identities.

### Theorem D: Subdivision invariance by elimination of degree-2 vertices
```lean
theorem kernel_preserved_under_degreeTwo_split
  (G : WeightedGraphModel)
  (e : G.Edge)
  (t : ℝ)
  (ht : 0 < t ∧ t < G.edgeLength e) :
  ...
```
Expected tactics:
- explicit construction,
- `field_simp` on conductance formulas,
- matrix or local harmonicity argument.

This is especially strong because it turns geometric refinement into an exact algebraic theorem.

---

## Cross-domain connections to emphasize

You must include at least one theorem and discuss at least two of the following bridges:

1. **Tropical geometry ↔ electrical networks**  
   Kernel columns are tropical Green’s functions; resistance is tropical distance in Jacobian coordinates.

2. **Tropical geometry ↔ quantum graphs**  
   The same kernel is the zero-energy resolvent of the Laplacian on a metric graph.

3. **Tropical geometry ↔ probability**  
   The kernel acts as a covariance structure for centered Gaussian free fields.

4. **Algebraic geometry ↔ algorithms**  
   Abel–Jacobi coordinates become computable by certified kernel approximation.

5. **Spectral graph theory ↔ arithmetic geometry**  
   Energy pairings and Jacobians suggest a tropical Hodge decomposition with computational period matrices.

These are not rhetorical ornaments; they should guide theorem choice and the writing of the paper/article deliverables.

---

## Application keywords

Include these explicitly in your write-up and metadata:
**tropical geometry, metric graphs, Green’s functions, effective resistance, Abel–Jacobi map, Jacobian, Dirichlet energy, harmonic forms, quantum graphs, spectral theory, Gaussian free field, subdivision invariance, certified algorithms, tropical Hodge theory**

---

## Falsifiable conjecture with computational test

State at least one conjecture that could be disproved by computation.

### Recommended conjecture: total positivity of kernel minors along geodesic order
For points `x₁ < x₂ < ... < x_n` and `y₁ < y₂ < ... < y_n` lying on a common simple geodesic segment of a compact metric graph, the matrix
\[
K_{ij} = g(x_i,y_j)
\]
has nonnegative determinant, and perhaps all minors are nonnegative.

This is not obviously true globally and is highly testable.

#### Lean-adjacent statement
```lean
conjecture geodesic_kernel_minor_nonneg
  (Γ : MetricGraphKernel)
  (xs ys : Fin n → Γ.X)
  (hxs : Γ.GeodesicallyOrdered xs)
  (hys : Γ.GeodesicallyOrdered ys) :
  0 ≤ Matrix.det (fun i j => Γ.g (xs i) (ys j))
```

### Computational disproof test
Your `demo.py` should:
- generate random metric trees, cycles, and lollipop graphs,
- sample ordered points on geodesic arcs,
- numerically approximate the canonical kernel matrix,
- test determinant/minor signs,
- search for counterexamples.

A failed instance is scientifically valuable; if false, pivot to a corrected tree-only or bridge-free version.

---

## Verified algorithmic deliverable

You must produce not just theorems but a verified computational method.

### Required algorithm
A certified approximation algorithm for the continuous kernel `g(p,q)` on a metric graph via adaptive subdivision.

Minimum specification:
1. Input: finite weighted graph model of a metric graph, points `p, q`, tolerance `ε > 0`.
2. Output: rational or floating approximation `ĝ(p,q)`.
3. Correctness theorem: if refinement depth exceeds an explicit bound, then
   \[
   |ĝ(p,q) - g(p,q)| \le ε.
   \]

#### Lean-style target signature
```lean
theorem approxKernel_error_bound
  (Γ : MetricGraphKernel)
  (p q : Γ.X)
  (ε : ℝ)
  (hε : 0 < ε) :
  ∃ N : ℕ, ∀ n ≥ N,
    abs (Γ.approxKernel n p q - Γ.g p q) ≤ ε
```

If exact asymptotic error control is too ambitious, prove a finite-model certified bound first.

---

## Demo requirements

Your `demo.py` must be interactive and scientifically useful. It should:
- construct sample metric graphs,
- compute approximate kernels and effective resistances,
- visualize kernel columns as potentials along edges,
- compare subdivision levels,
- test the conjecture above,
- optionally display Jacobian-coordinate approximations.

The demo should make the mathematics visible, not merely print theorem names.

---

## Mandatory deliverables

You must produce ALL of the following:

1. **Lean file(s)** with the new definitions and at least 3 nontrivial theorems proved with substantive tactics.
2. **FUTURE_DIRECTIONS.md** with 3–5 original research directions.  
   Each direction must include the exact sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain.
3. **RESEARCH_PAPER.md** as a standalone scientific paper.  
   A reader with no access to code must understand:
   - the new definitions,
   - the main theorems,
   - why they are a breakthrough,
   - how the algorithm works,
   - what should be investigated next.
4. **ARTICLE.md** in Scientific American style.  
   Do **not** focus on formal verification machinery; focus on the mathematical ideas and why they matter.
5. **A verified algorithm or computational method**, not just theorem statements.
6. **demo.py** demonstrating the result interactively.

---

## Standard of ambition

Do not settle for “the discrete theorem also holds for weighted graphs.” The target is a unifying kernel formalism that makes metric graphs computable objects in tropical Hodge theory. The ideal outcome is a package where one can say:

- the canonical kernel exists and is unique,
- it survives refinement exactly,
- it computes resistance and Jacobian coordinates,
- it interfaces with spectral theory,
- and it can be approximated with certified error.

That is a field-opening result, not a local patch.

Use the catalog aggressively. Reuse the existing pendant-edge rigidity and normalized-kernel uniqueness theorems as finite anchors. Then transcend them.

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
