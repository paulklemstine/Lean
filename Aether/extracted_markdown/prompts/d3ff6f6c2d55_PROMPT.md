## Assignment: Chip-Firing Correspondence — Tropical Hodge Theory Meets Baker-Norine

### The Grand Vision

The Baker-Norine Riemann-Roch theorem for graphs (2007) gave combinatorial algebraic geometry its "Weil conjectures moment" — a discrete analogue of a deep algebro-geometric theorem. What it lacked was the *Hodge-theoretic* complement: a theory of harmonic forms on graphs. The tropical kernel of the graph Laplacian IS that theory. This assignment proves the correspondence that makes it explicit, opening the door to computational tropical Hodge theory.

---

### New Definitions (Required)

```lean
-- A divisor on a graph with integer coefficients
@[ext]
structure Divisor (G : SimpleGraph V) [Fintype V] [DecidableRel G.Adj] where
  coeff : V → ℤ

namespace Divisor

/-- Degree of a divisor: sum of all coefficients -/
def degree (D : Divisor G) : ℤ := ∑ v : V, D.coeff v

/-- The zero divisor -/
def zero : Divisor G := ⟨fun _ => 0⟩

/-- Degree-zero divisors form a group under pointwise addition -/
def DegreeZero : AddSubgroup (Divisor G) where
  carrier := {D | D.degree = 0}
  add_mem' := by intro _ _ ha hb; simp [degree, ha, hb]; omega
  zero_mem' := by simp [degree, zero]
  neg_mem' := by intro _ ha; simp [degree, neg] at *; omega

/-- Support of a divisor: vertices with nonzero coefficient -/
def support (D : Divisor G) : Set V := {v | D.coeff v ≠ 0}

/-- A divisor is supported on a set S -/
def SupportedOn (D : Divisor G) (S : Set V) : Prop := D.support ⊆ S

/-- A divisor D is q-reduced: no proper subset of V \ {q} can be fired -/
def QReduced (q : V) (D : Divisor G) : Prop :=
  ∀ A : Set V, A ⊆ {v | v ≠ q} → A.Nonempty →
    ∃ v ∈ A, D.coeff v < (G.degree v : ℤ) - ∑ u ∈ {u | G.Adj u v ∧ u ∈ A}, (1 : ℤ)

/-- A divisor is balanced: at each vertex, the coefficient equals the minimum
    of neighbors' coefficients whenever the vertex is "active" (nonnegative).
    This mirrors tropicalKernelProp from the catalog. -/
def Balanced (D : Divisor G) : Prop :=
  ∀ v : V, D.coeff v ≥ 0 →
    ∃ u : V, G.Adj v u ∧ D.coeff u ≤ D.coeff v ∧
      ∀ w : V, G.Adj v w → D.coeff w ≥ D.coeff u

/-- Circuit divisor: the divisor associated to a fundamental cycle.
    For cycle C with vertices v₁, ..., vₖ, the circuit divisor has
    coeff +1 on vᵢ if the edge goes "forward" and -1 if "backward". -/
def CircuitDivisor (C : List V) (hC : IsCycle G C) : Divisor G :=
  ⟨fun v => match C.indexOf? v with
    | some i => if i % 2 = 0 then (1 : ℤ) else -1
    | none => 0⟩

end Divisor

/-- The tropical scaling equivalence on divisors:
    D ~ D' iff ∃ (r : ℝ), r > 0 ∧ ∀ v, D'.coeff v = r • D.coeff v -/
def TropicalScalingEquiv (D D' : Divisor G) : Prop :=
  ∃ r : ℝ, r > 0 ∧ ∀ v, (D'.coeff v : ℝ) = r * (D.coeff v : ℝ)

/-- The Jacobian group: degree-zero divisors modulo principal divisors.
    This is the graph-theoretic analogue of the Picard group. -/
def JacobianGroup (G : SimpleGraph V) [Fintype V] [DecidableRel G.Adj] :=
  Divisor.DegreeZero G ⧸ Subgroup.closure {D | ∃ q, D = ChipFiringGame.fireAll q}
```

---

### Main Theorems (with Lean 4 Signatures)

**Theorem 1 (Chip-Firing Correspondence).** The tropical kernel of the graph Laplacian is isomorphic to the group of balanced q-reduced divisors modulo tropical scaling:

```lean
/-- The main correspondence: tropical kernel generators ↔ balanced q-reduced divisors -/
theorem tropical_kernel_correspondence
    (G : SimpleGraph V) [Fintype V] [DecidableRel G.Adj] [Connected G]
    (q : V) (S : Set V) [DecidablePred (· ∈ S)] :
    ModuleEquiv
      (TropicalKernel G S ⧸ Submodule.span ℝ {v | TropicalScalingEquiv v 1})
      (Divisor.DegreeZero G ⧸ Subgroup.closure
        {D | D.SupportedOn S ∧ D.Balanced ∧ D.QReduced q}) := by
  sorry
```

**Theorem 2 (Cycle-Circuit Correspondence).** Each independent cycle in G produces a generator of the tropical kernel that maps to a circuit divisor in the Jacobian:

```lean
/-- The genus-many cycle generators of ker_trop(L) map to circuit divisors -/
theorem cycle_circuit_correspondence
    (G : SimpleGraph V) [Fintype V] [DecidableRel G.Adj] [Connected G]
    (basis : Basis (Fin G.genus) ℝ (TropicalKernel G Set.univ)) :
    ∀ i : Fin G.genus,
    ∃ (C : List V) (hC : IsCycle G C),
      (Divisor.CircuitDivisor C hC).Balanced ∧
      (Divisor.CircuitDivisor C hC).QReduced (basis i).some_vertex ∧
      (Divisor.CircuitDivisor C hC).degree = 0 := by
  sorry
```

**Theorem 3 (Tropical Hodge Dimension).** The dimension of the tropical kernel equals the graph genus, completing the tropical Hodge diamond:

```lean
/-- The tropical Hodge number h^{0,1} equals the genus -/
theorem tropical_hodge_dimension
    (G : SimpleGraph V) [Fintype V] [DecidableRel G.Adj] [Connected G] :
    Module.rank ℝ (TropicalKernel G Set.univ) = G.genus := by
  sorry
```

**Theorem 4 (Cross-Domain: Jacobian Order = Tropical Determinant).** The order of the Jacobian group equals the tropical determinant of the reduced Laplacian, connecting algebraic graph theory to tropical linear algebra:

```lean
/-- The Jacobi-Kirchhoff theorem: |Jac(G)| = τ(G) = tropdet(Lᵠ) -/
theorem jacobi_kirchhoff_tropical
    (G : SimpleGraph V) [Fintype V] [DecidableRel G.Adj] [Connected G]
    (q : V) :
    Fintype.card (JacobianGroup G) = Tropical.det (Laplacian.reduced G q) := by
  sorry
```

---

### Proof Strategies

**Strategy A (Direct Firing Map — RECOMMENDED).** 
*Step 1*: Define the firing map `Φ : TropicalKernel G S → Divisor G` by `Φ(v)(i) = v(i)` (interpreting the tropical kernel vector as a divisor via evaluation). 
*Step 2*: Show `Φ` preserves the balanced condition using `tropicalKernelProp` from `Pythagorean/TropicalBridge/Defs.lean`: the minimum-neighbor condition in the tropical kernel IS the balanced condition for divisors. 
*Step 3*: Show `Φ` is injective modulo tropical scaling by constructing the inverse: given a balanced q-reduced divisor D, the sequence of firing operations that produces D from the zero divisor encodes a unique tropical kernel vector. The key lemma is that `tropicalKernel_leaf_eq` extends from trees to general graphs by induction on the cyclomatic number.
*Why promising*: Builds directly on catalog results and handles the inductive structure naturally.

**Strategy B (Smith Normal Form / Algebraic).** 
*Step 1*: Compute the Smith normal form of the reduced Laplacian Lᵠ over ℤ. The g zero diagonal entries (where g = genus) correspond to tropical kernel generators. 
*Step 2*: Map each nullspace basis vector to a divisor via the incidence matrix. 
*Step 3*: Verify that the resulting divisors are balanced and q-reduced using the column structure of the SNF. 
*Why less promising*: Requires developing SNF for tropical matrices, which is substantial infrastructure work.

**Strategy C (Potential Theory / Energy Minimization).** 
*Step 1*: Define the energy functional `E(D) = ∑_{v,w} D(v) R(v,w) D(w)` where R is the resistance matrix. 
*Step 2*: Show that balanced q-reduced divisors minimize E within their equivalence class (mirroring the uniqueness of q-reduced representatives in Baker-Norine). 
*Step 3*: The energy minimizer satisfies the tropical harmonicity condition, yielding the correspondence. 
*Why interesting*: Connects to the rich theory of effective resistance and the probabilistic interpretation of chip-firing, but requires developing resistance theory first.

---

### Conjecture with Testable Prediction

**Conjecture (Tropical Riemann-Roch for Graphs).** For any divisor D on a connected graph G of genus g:

```
r(D) - r(K - D) = deg(D) - g + 1
```

where `r(D)` is the rank (maximum s such that D - E is effective for all effective E of degree s) and K is the canonical divisor. Moreover, `r(D)` equals the tropical kernel dimension of the subgraph where D is supported.

**Computational Test**: For all 156 connected graphs on ≤ 6 vertices:
1. Compute `dim(ker_trop(L_S))` for each vertex subset S using the tropical Laplacian
2. Compute `r(D)` via the Baker-Norine algorithm for each degree-0 divisor D supported on S
3. Verify: `r(D) = dim(ker_trop(L_S)) - (g - 1)` for all D with `supp(D) = S`
4. **Falsification condition**: Find ANY graph and divisor where the tropical kernel dimension disagrees with the Baker-Norine rank.

---

### Catalog Building Blocks

- **`Pythagorean/TropicalBridge/Defs.lean`**: `tropicalKernelProp` — the balanced condition that mirrors chip-firing firing rules
- **`Pythagorean/TropicalBridge/TropicalHodge.lean`**: `tropicalKernel_leaf_eq` — propagation along tree edges IS q-reduced condition on trees
- **`Pythagorean/TropicalBridge/TropicalHodge.lean`**: `tropical_kernel_dim_eq_genus` (if available) — the dimension theorem
- **Mathlib `LinearAlgebra/Matrix`**: Smith normal form infrastructure
- **Mathlib `Combinatorics/SimpleGraph/Connectivity`**: Connected components, spanning trees

---

### Domain Bridges

1. **Tropical Geometry ↔ Algebraic Geometry**: The correspondence `ker_trop(L) ≅ Div⁰_{balanced}(G)/~` is the graph-theoretic shadow of the isomorphism `H¹(X, O_X) ≅ Pic⁰(X)` for algebraic curves. This makes the Jacobian group computable via tropical linear algebra.

2. **Chip-Firing ↔ Statistical Mechanics**: The energy functional `E(D)` on divisors is a discrete Dirichlet energy. The q-reduced representative is the ground state of this energy. This connects to the Abelian sandpile model and self-organized criticality (Bak-Tang-Wiesenfeld).

3. **Tropical Hodge Theory ↔ Topological Data Analysis**: The tropical kernel dimension equals the first Betti number. This provides a tropical-Hodge-theoretic framework for persistent homology: the "tropical barcode" of a filtration of subgraphs encodes topological features via tropical kernel dimensions.

---

### Application Keywords
`graph-jacobian`, `chip-firing`, `tropical-hodge-theory`, `baker-norine`, `riemann-roch-graphs`, `abelian-sandpile`, `tropical-linear-algebra`, `circuit-divisors`, `effective-resistance`

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md**: 3-5 directions, each with "The key insight is..." and "Why now?". At least one must bridge to statistical mechanics (Abelian sandpile) or topological data analysis (tropical persistent homology).

(b) **RESEARCH_PAPER.md**: Standalone paper proving the chip-firing correspondence, the cycle-circuit theorem, and the tropical Hodge dimension formula. Must include the computational verification on small graphs.

(c) **ARTICLE.md**: Scientific American style — "The Geometry of Sandcastles: How Tropical Algebra Unifies Chip-Firing, Riemann-Roch, and the Physics of Self-Organized Criticality."

(d) **Verified Algorithm**: A certified algorithm that, given a connected graph G and vertex q, computes the Jacobian group `Jac(G)` as a quotient of balanced q-reduced divisors by tropical scaling, using the tropical kernel as the computational engine.

(e) **demo.py**: Interactive demonstration that:
   - Takes any connected graph (default: Peterson graph)
   - Computes `ker_trop(L)` and the balanced q-reduced divisors
   - Displays the explicit bijection
   - Verifies `dim(ker_trop) = g` for all graphs on ≤ 8 vertices
   - Animates chip-firing sequences corresponding to tropical kernel generators

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
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
