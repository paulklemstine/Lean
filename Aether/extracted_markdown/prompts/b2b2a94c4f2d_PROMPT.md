## Assignment: Prove a Tropical Collatz–Wielandt Principle for Finite Max-Plus Matrices

Work in Lean 4/Mathlib and formalize a genuinely structural theorem in tropical linear algebra, not a syntactic reformulation. The target is a finite-dimensional max-plus Collatz–Wielandt theorem: the tropical spectral radius of a matrix is exactly the optimal additive subeigenvalue bound.

This is the right theorem because it is the tropical analogue of one of the deepest variational characterizations in Perron–Frobenius theory. Formalizing it opens a route from elementary max identities to certified tropical spectral theory, mean-payoff games, idempotent optimization, discrete event systems, and tropical control.

### Core theorem to prove

Let `W : Matrix (Fin n) (Fin n) ℝ`. Define tropical matrix-vector multiplication by
\[
(W \otimes x)_i := \max_j (W_{ij} + x_j).
\]
Define the subeigenvalue feasible set
\[
\mathrm{SubEig}(W,\lambda) := \exists x : (Fin n \to \mathbb R), \forall i,\ (W \otimes x)_i \le x_i + \lambda.
\]
Define the tropical cycle mean
\[
\rho_{\mathrm{trop}}(W)
:= \max_{\substack{k \ge 1 \\ i_0,\dots,i_k,\ i_k=i_0}}
\frac{W_{i_0 i_1} + \cdots + W_{i_{k-1} i_k}}{k},
\]
where the maximum ranges over directed cycles in `Fin n`.

Then prove the exact variational principle
\[
\rho_{\mathrm{trop}}(W)
=
\sup \{ \lambda : \mathrm{SubEig}(W,\lambda) \}.
\]

Because `Fin n` is finite, the `sup` should collapse to a `max` once the feasible scalar set is shown bounded and nonempty. A more Lean-friendly equivalent statement is:

\[
\forall \lambda,\quad
(\exists x,\ \forall i,\ (W \otimes x)_i \le x_i + \lambda)
\iff
\rho_{\mathrm{trop}}(W) \le \lambda.
\]

This equivalence is the cleanest formal target. From it, the max/sup formula follows immediately.

### Recommended Lean 4 formalization target

You will likely want to define the tropical action explicitly rather than relying on a pre-existing semiring abstraction over `ℝ ∪ {-∞}`. Use concrete `ℝ` first; this gives a finite weighted-complete-digraph setting and avoids order-topology pain from `EReal`.

A plausible Lean skeleton:

```lean
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Algebra.BigOperators.Basic

open Matrix BigOperators

def tropMatVec {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.sup' (Finset.univ_nonempty) (fun j => W i j + x j)

def IsSubeigenvector {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (λ : ℝ) (x : Fin n → ℝ) : Prop :=
  ∀ i, tropMatVec W x i ≤ x i + λ

def HasSubeigenvalue {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (λ : ℝ) : Prop :=
  ∃ x : Fin n → ℝ, IsSubeigenvector W λ x

-- You may define cycle mean first for a fixed cyclic list/path, then take max over a finite encoding.
def cycleWeight ...
def cycleMean ...
def tropicalSpectralRadius {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ := ...

theorem tropical_collatz_wielandt
  {n : ℕ} (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) :
  ∀ λ : ℝ, HasSubeigenvalue W λ ↔ tropicalSpectralRadius W ≤ λ := by
  sorry
```

A second theorem extracting the optimization statement:

```lean
theorem tropical_collatz_wielandt_max
  {n : ℕ} (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) :
  tropicalSpectralRadius W =
    sSup {λ : ℝ | HasSubeigenvalue W λ} := by
  sorry
```

If `sSup` on arbitrary sets becomes annoying, replace it with a bounded-above existence/max theorem over an explicitly finite candidate set of cycle means, or first prove the iff theorem and derive the order characterization:
```lean
theorem tropicalSpectralRadius_le_iff
  {n : ℕ} (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) (λ : ℝ) :
  tropicalSpectralRadius W ≤ λ ↔ HasSubeigenvalue W λ := by
  ...
```

### Minimal but nontrivial supporting definitions

You should define and prove the following infrastructure lemmas:

1. `tropMatVec_le_iff`
   \[
   (W \otimes x)_i \le x_i + \lambda
   \iff
   \forall j,\ W_{ij}+x_j \le x_i+\lambda.
   \]

2. `subeigenvalue_edgewise`
   From `HasSubeigenvalue W λ`, deduce
   \[
   W_{ij}+x_j-x_i \le \lambda
   \]
   for every edge `(i,j)`.

3. `cycle_bound_of_subeigenvector`
   Summing around a cycle yields
   \[
   \frac{\sum W_{i_t i_{t+1}}}{k} \le \lambda.
   \]

4. A realization theorem for the converse direction: if `λ` is at least every cycle mean, construct `x` with
   \[
   W_{ij}+x_j \le x_i+\lambda.
   \]

This fourth item is the heart of the project.

### Why this is a breakthrough

This is not just “another tropical inequality.” It is the variational doorway from combinatorial graph weights to nonlinear eigenvalue theory. Once certified in Lean, it provides a machine-checked bridge between:

- tropical linear algebra,
- max-plus dynamical systems,
- longest-path potentials,
- Bellman inequalities,
- mean-payoff games,
- and idempotent analogues of Perron–Frobenius theory.

That bridge is mathematically deep and strategically powerful. It transforms ad hoc tropical manipulations into a reusable spectral framework.

### Proof architecture: three viable strategies

#### Strategy A: Cycle telescoping + path-potential construction
Most promising.

Step 1: Prove the easy direction (`HasSubeigenvalue W λ → ρ_trop(W) ≤ λ`) by telescoping.
- From `W i j + x j ≤ x i + λ`, rearrange to `W i j ≤ λ + x i - x j`.
- Sum along a cycle:
  \[
  \sum W_{i_t i_{t+1}} \le k\lambda + \sum (x_{i_t}-x_{i_{t+1}})=k\lambda.
  \]
- Divide by `k`.

Step 2: For the converse, define shifted weights
\[
A_{ij} := W_{ij} - \lambda.
\]
Assume every cycle has total weight `≤ 0`. Fix a root `r` and define
\[
x_i := \sup\{\text{weight of a path from } i \text{ to } r \text{ in } A\}.
\]
In finite dimension, because positive cycles are absent, this supremum is achieved by a simple path, so only finitely many candidates are needed.

Step 3: Show the dynamic-programming inequality
\[
A_{ij}+x_j \le x_i,
\]
hence `W_{ij}+x_j ≤ x_i + λ`, and therefore `HasSubeigenvalue W λ`.

Why this is strongest:
- It is constructive.
- It avoids advanced convex duality.
- It connects directly to graph theory and shortest/longest path methods.
- It scales toward algorithms and certified computation.

#### Strategy B: Finite Bellman–Ford duality / difference constraints
Also strong, especially if graph encodings are easier than cycle combinatorics.

Step 1: Rewrite the subeigenvector condition as a family of difference constraints:
\[
x_j - x_i \le \lambda - W_{ij}.
\]

Step 2: Use the classical theorem for feasibility of difference constraints:
a system `x_v - x_u ≤ c(u,v)` is feasible iff every directed cycle has nonnegative total `c`-weight. Here this becomes
\[
\sum (\lambda - W_{i_t i_{t+1}}) \ge 0
\iff
\text{cycle mean} \le \lambda.
\]

Step 3: Formalize the finite feasibility theorem directly in Lean, perhaps by constructing potentials from shortest-path distances in the constraint graph.

Why this is attractive:
- It reframes the theorem as a graph-feasibility duality statement.
- It opens immediate links to linear programming duality, SMT solving, and certified scheduling.
- It may produce cleaner combinatorial lemmas than the path-sup approach.

#### Strategy C: Tropical fixed-point / nonlinear Perron–Frobenius route
Most ambitious; probably second-cycle material unless the infrastructure is already there.

Step 1: Study the map
\[
T_\lambda(x)_i := \max_j (W_{ij} + x_j - \lambda).
\]
Subeigenvectors are exactly post-fixed points `T_λ(x) ≤ x`.

Step 2: Show that the absence of cycle means above `λ` implies iterative boundedness of `T_λ^k(0)`.

Step 3: Extract a fixed or post-fixed point by finite-dimensional compactness/monotone stabilization after gauge normalization.

Why it matters:
- This route ties directly to nonlinear spectral theory and order-preserving homogeneous maps.
- It could generalize beyond matrices to tropical operators, Shapley operators, and min-max systems.

### Concrete intermediate theorem list

Aim to prove these in sequence.

1. **Edgewise characterization**
```lean
theorem isSubeigenvector_iff
  {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (λ : ℝ) (x : Fin n → ℝ) :
  IsSubeigenvector W λ x ↔
    ∀ i j, W i j + x j ≤ x i + λ := by
  sorry
```

2. **Cycle upper bound**
```lean
theorem cycle_mean_le_of_subeigenvector
  {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (λ : ℝ)
  (x : Fin n → ℝ) (hx : IsSubeigenvector W λ x) :
  ∀ c, IsCycle c → cycleMean W c ≤ λ := by
  sorry
```

3. **Potential construction from cycle constraints**
```lean
theorem exists_subeigenvector_of_cycle_means_le
  {n : ℕ} (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) (λ : ℝ)
  (hcycle : ∀ c, IsCycle c → cycleMean W c ≤ λ) :
  HasSubeigenvalue W λ := by
  sorry
```

4. **Collatz–Wielandt equivalence**
```lean
theorem tropical_collatz_wielandt
  {n : ℕ} (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) (λ : ℝ) :
  HasSubeigenvalue W λ ↔ tropicalSpectralRadius W ≤ λ := by
  sorry
```

5. **Optimization corollary**
```lean
theorem tropical_spectral_radius_eq_max_subeigenvalue
  {n : ℕ} (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) :
  tropicalSpectralRadius W =
    sSup {λ : ℝ | HasSubeigenvalue W λ} := by
  sorry
```

### Lean-specific design advice

- Encode cycles carefully. Do not start with arbitrary graph libraries if they create overhead.
- A practical route is to define a cycle as a nonempty list/vector `v : Fin k → Fin n` with wraparound indexing.
- Since `Fin n` is finite, “max over cycles” is delicate if cycles of arbitrary length are allowed. Use the standard reduction: it suffices to consider simple cycles, whose length is at most `n`. This is a key finite combinatorial lemma worth formalizing.
- Therefore define `tropicalSpectralRadius` as the maximum over simple cycles only.
- For path potentials, similarly reduce to simple paths, so all candidate path weights form a finite set.

### Cross-domain connections you should explicitly exploit

1. **Graph theory / combinatorial optimization**
   The theorem is equivalent to a cycle-feasibility criterion for difference constraints. This links tropical eigenvalues to Bellman–Ford and Karp’s maximum cycle mean theorem.

2. **Control theory / discrete event systems**
   Max-plus matrices model synchronization networks, manufacturing systems, and timed event graphs. The subeigenvalue inequality is a certified performance bound.

3. **Game theory / theoretical CS**
   Tropical spectral radius is a precursor to mean-payoff values and Shapley operators. Formalizing this theorem creates a Lean foundation for verified game-solving algorithms.

4. **Nonlinear Perron–Frobenius / idempotent analysis**
   This is the idempotent shadow of classical spectral variational principles. It opens a program toward tropical Krein–Rutman theory.

5. **Optimization / formal verification**
   The existence of potentials witnessing cycle constraints is exactly the kind of theorem that can certify scheduling, routing, and resource-allocation systems.

### How to use the existing catalog theorems

The listed catalog theorems are elementary and not directly spectral, but you should still reuse their style and local max-rewriting patterns.

- `max_aggregation_tropical` and `tropical_max_ite` can support local simplifications of `max`-based tropical expressions.
- `relu_preserves_tropical_max` hints at a broader monotonicity pattern: tropical operators interact well with order-preserving nonlinearities. Mention this in `FUTURE_DIRECTIONS.md` as a bridge to tropical neural operators.
- `tropical_lattice_min_max` suggests finite-order lattice manipulations that may help with `Finset.sup'` lemmas.

Do not force these theorems artificially into the main proof; build on them where natural, but prioritize the mathematically right architecture.

### What would make this field-opening

If you complete the equivalence theorem and the constructive converse, you have created a formal tropical spectral primitive. That primitive can support:

- verified Karp-type algorithms for maximum cycle mean,
- certified bounds for max-plus linear systems,
- formal mean-payoff game dualities,
- tropical eigenspace geometry,
- tropical optimization certificates.

This is the seed crystal for a full Lean library in idempotent mathematics.

### Deliverables

1. Lean theorem statements and proofs for the main equivalence and at least the easy direction fully completed.
2. Supporting definitions for tropical matrix-vector product, cycle weight/mean, and subeigenvectors.
3. At least one constructive converse theorem, even if first stated under a convenient encoding of cycles/paths.
4. Minimize `sorry`; if one remains, it should be concentrated in the finite path/cycle realization lemma, not scattered everywhere.
5. `FUTURE_DIRECTIONS.md` with 3–5 concrete next theorems.

### Required FUTURE_DIRECTIONS.md content

Include 3–5 specific next steps, each with theorem statement, proof strategy, and cross-domain impact. At minimum include candidates like:

1. **Karp formula formalization**
   Prove the tropical spectral radius equals the limit/maximum cycle mean computed from path-growth quantities.

2. **Tropical eigenvector existence**
   Under irreducibility assumptions, prove existence of `x` with exact equality
   \[
   W \otimes x = x + \rho_{\mathrm{trop}}(W)\mathbf 1.
   \]

3. **Mean-payoff game bridge**
   Generalize from max-plus matrices to min-max/Shapley operators and prove a Collatz–Wielandt-type bound.

4. **Certified scheduling duality**
   Formalize difference constraints feasibility and derive tropical performance certificates for timed event graphs.

5. **Tropical neural operators**
   Investigate whether order-preserving homogeneous neural layers admit Collatz–Wielandt bounds, connecting tropical deep learning to nonlinear spectral theory.

### Application keywords

tropical linear algebra, max-plus algebra, Collatz–Wielandt theorem, tropical spectral radius, maximum cycle mean, Bellman inequalities, difference constraints, Bellman–Ford, Karp theorem, discrete event systems, mean-payoff games, idempotent analysis, nonlinear Perron–Frobenius, certified optimization, formal verification

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Tropical
Research mode: prove
