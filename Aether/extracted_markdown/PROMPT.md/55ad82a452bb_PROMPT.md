## Assignment: Existence

Prove a genuinely new theorem at the interface of tropical linear algebra, graph algorithms, and max-plus spectral theory: formalize a finite-dimensional version of the tropical Perron–Frobenius mechanism in which Karp’s minimum cycle mean algorithm identifies the tropical eigenvalue, the critical graph isolates the spectral support, and a CSR-style construction produces an actual eigenvector.

This is not an incremental coding exercise. It is the formal seed of a certified tropical spectral theory in Lean 4.

### Research Direction

Let `A : Matrix (Fin n) (Fin n) ℝ` be interpreted in the max-plus semiring style: matrix multiplication is replaced by
\[
(A \otimes x)_i = \max_j (A_{ij} + x_j).
\]
Define the tropical spectral value
\[
\mu(A) = \min_{C \text{ directed cycle}} \frac{w(C)}{|C|}
\]
or, depending on the normalization convention you choose for max-plus spectral theory,
\[
\lambda(A) = \max_{C \text{ directed cycle}} \frac{w(C)}{|C|}.
\]
Pick one convention and stick to it globally. The breakthrough target is:

> compute the cycle mean via a Karp-style dynamic program, define the critical graph as the subgraph of edges belonging to optimal mean cycles, and prove that the CSR decomposition on the critical part yields a tropical eigenvector.

Because signs/conventions vary in the literature, the most Lean-feasible route is:

- either work in **min-plus** and prove existence of `v` with
  \[
  \forall i,\ \min_j (A_{ij}+v_j)=\mu+v_i,
  \]
- or work in **max-plus** and prove existence of `v` with
  \[
  \forall i,\ \max_j (A_{ij}+v_j)=\lambda+v_i.
  \]

The second is more standard for tropical Perron theory; the first aligns more directly with “minimum mean cycle”. You should explicitly normalize the two viewpoints and, if possible, prove they are equivalent under negation of weights.

### Precise Theorem Target

A strong formal target is the following existence theorem.

#### Mathematical statement

For every finite weighted directed graph encoded by a real matrix `A`, if the critical graph is nonempty, then there exists a vector `v : Fin n → ℝ` such that on every critical node, the tropical matrix action attains the spectral value, and globally `v` is a tropical subeigenvector; moreover, after CSR saturation/reduction, one obtains a genuine tropical eigenvector on the critical class.

A sharper version:

\[
\forall n \ge 1,\ \forall A \in \mathbb{R}^{n\times n},\ 
\exists \lambda \in \mathbb{R},\ \exists v : \{0,\dots,n-1\}\to\mathbb{R},
\]
such that
\[
\forall i,\ \max_j (A_{ij}+v_j)\le \lambda + v_i,
\]
and for every vertex `i` in the critical graph,
\[
\max_j (A_{ij}+v_j)= \lambda + v_i.
\]
If the critical graph is strongly connected (or after restricting to a critical strongly connected component), then
\[
\forall i \in \mathrm{Crit},\ \max_j (A_{ij}+v_j)= \lambda + v_i
\]
and `v` restricted to `Crit` is a tropical eigenvector.

This is already a serious theorem. It bridges algorithmic cycle-mean optimization and algebraic eigenstructure.

### Suggested Lean 4 theorem signatures

You will likely need staged theorems rather than one monolith. Here are realistic target signatures.

```lean
open Matrix BigOperators

def tropMulVec {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.sup fun j => A i j + v j
```

If `Finset.sup` over `ℝ` becomes awkward due to order-theoretic requirements, replace with a `max'` formulation on `Finset.univ.image ...` under `n > 0`, or define using `sSup` on a finite set and prove finiteness lemmas.

```lean
def IsTropicalSubeigenpair {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (λ : ℝ) (v : Fin n → ℝ) : Prop :=
  ∀ i, tropMulVec A v i ≤ λ + v i

def IsTropicalEigenpair {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (λ : ℝ) (v : Fin n → ℝ) : Prop :=
  ∀ i, tropMulVec A v i = λ + v i
```

For the cycle mean:

```lean
def edgeWeight {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) : ℝ := A i j
```

You may define directed walks/cycles using lists or `SimpleGraph`-style structures if available, but a custom finite digraph encoding may be cleaner.

A theorem close to the real target:

```lean
theorem exists_tropical_subeigenpair_with_critical_equality
    {n : ℕ} (hn : 0 < n)
    (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ λ : ℝ, ∃ v : Fin n → ℝ,
      IsTropicalSubeigenpair A λ v ∧
      ∀ i, i ∈ criticalNodes A → tropMulVec A v i = λ + v i := by
  sorry
```

A stronger restricted critical-component theorem:

```lean
theorem exists_tropical_eigenpair_on_critical_component
    {n : ℕ} (hn : 0 < n)
    (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ λ : ℝ, ∃ C : Finset (Fin n), ∃ v : Fin n → ℝ,
      IsCriticalComponent A C ∧
      (∀ i, i ∈ C → tropMulVec A v i = λ + v i) := by
  sorry
```

If full CSR is too large for one cycle, prove the decomposition as a chain:

1. `karp_value_eq_optimal_cycle_mean`
2. `critical_graph_nonempty`
3. `exists_potential_subeigenvector`
4. `critical_edges_force_equality`
5. `csr_produces_eigenvector_on_critical_component`

That sequence is both mathematically natural and Lean-friendly.

### Core definitions to introduce

You should define, minimally:

- weighted directed graph from a matrix,
- directed walk / cycle,
- cycle total weight,
- cycle mean,
- optimal cycle mean (`μ` or `λ`),
- critical edge,
- critical node,
- critical graph,
- tropical matrix-vector action,
- tropical subeigenpair / eigenpair,
- CSR reduction object if feasible.

A practical formalization strategy is to define the critical graph by a **certificate condition** first, not by “edge lies on some optimal cycle” directly. For example, after computing a potential `v`, define critical edges by
\[
A_{ij}+v_j = \lambda + v_i.
\]
Then later prove that these coincide with edges on optimal cycles. This is a crucial Lean simplification: algebraic tightness is easier to manipulate than existential cycle membership.

### 2–3 Proof Strategy Paths

#### Strategy A: Potential/subeigenvector first, critical graph second
Most promising.

1. Define the Karp dynamic programming quantities `dp k i`, representing optimal weight of a length-`k` path ending at `i`.
2. Use the classical Karp formula to define the spectral value `λ` (or `μ`) from asymptotic path growth / cycle mean.
3. Construct a potential `v` from normalized path weights, e.g. a supremum of `dp k i - k*λ` over bounded `k`, and prove
   \[
   \max_j (A_{ij}+v_j)\le \lambda+v_i.
   \]
4. Define critical edges as those with equality. Prove every critical cycle has mean `λ`, and every optimal cycle is tight. Conclude equality on critical nodes, giving an eigenvector on the critical component.

Why this is promising: it turns the graph-theoretic theorem into an order-theoretic inequality theorem, which Lean handles better than existential combinatorics over cycles.

#### Strategy B: Cycle-space/combinatorial graph proof
More direct but more brittle.

1. Formalize cycles and their means explicitly.
2. Prove Karp’s value equals the extremal cycle mean.
3. Define the critical graph as the union of optimal cycles.
4. Show every critical strongly connected component supports a solution to the system
   \[
   A_{ij}+v_j=\lambda+v_i
   \]
   along critical edges, by choosing a basepoint and assigning `v` via path weights.
5. Prove path-independence from zero total discrepancy around critical cycles.

Why it matters: this is conceptually pure CSR. Why it is harder: path-independence and cycle quotient arguments are proof-heavy in Lean.

#### Strategy C: Reduction to difference constraints / Bellman–Ford style duality
Very powerful cross-domain route.

1. Rewrite tropical subeigenvector inequalities as difference constraints:
   \[
   A_{ij}+v_j \le \lambda + v_i \iff v_j - v_i \le \lambda - A_{ij}.
   \]
2. Show feasibility is equivalent to all cycle sums satisfying the cycle mean bound.
3. Use the optimal cycle mean as the least feasible `λ`.
4. At the optimum, tight constraints define the critical graph; on a critical SCC, tightness propagates to equality and yields an eigenvector.

Why this is exciting: it reframes tropical spectral theory as linear optimization duality on graphs. This opens immediate bridges to operations research, static analysis, and certified optimization.

### Which strategy is best?

Start with **Strategy C**, then blend into **Strategy A**.

Reason: difference constraints are much easier to formalize than arbitrary cycle decomposition, and they expose the exact convex-dual structure behind Karp’s algorithm. Once you have the feasible potential, you can define critical edges by tightness and recover the CSR/eigenvector story. Strategy B should be a later strengthening, once the inequality infrastructure is built.

### How to build on catalog theorems

The listed catalog theorems are not directly about tropical spectral graph theory, but they can still be used architecturally.

- `tropical_factoring_decomposition`  
  Use this as precedent for a decomposition-centric theorem style. Your result should similarly separate the object into algebraically meaningful pieces: spectral value, critical graph, saturation/tightness region, and reduced eigenvector support.

- `tropical_norm_from_decomposition`  
  This suggests an important methodological bridge: derive global spectral structure from a decomposition. If that theorem already packages norm control from a finite decomposition, mirror the pattern to package eigenvector existence from critical decomposition.

- `relu_tropical_decomposition`  
  This is a bridge to piecewise-linear geometry. Tropical eigenvectors are also fixed points of piecewise-linear max-affine operators. You should explicitly note that your theorem certifies existence of fixed points for a max-affine dynamical system determined by `A`.

- `tropical_mirror_theorem`  
  Though elementary, it is a reminder that idempotent algebra identities can simplify max-structure proofs. Use analogous max-idempotent rewriting aggressively in the tropical action lemmas.

- `birthday_bound_tropical_hash`  
  This is the most unexpected bridge: critical graph extraction is, in effect, identifying collision structures among tight constraints. There may be a combinatorial “collision of path-growth certificates” interpretation worth mentioning in FUTURE_DIRECTIONS.

### Breakthrough significance

If you formalize this theorem, you are not merely proving an isolated graph fact. You are building the first certified bridge among:

- Karp’s algorithmic minimum/maximum cycle mean computation,
- tropical Perron–Frobenius theory,
- CSR decomposition from max-plus algebra,
- difference constraints / shortest path duality,
- piecewise-linear fixed point theory.

This opens a new field direction inside Lean: **certified idempotent spectral theory**.

That, in turn, enables future formal work on:

- tropical control and scheduling,
- discrete event systems,
- mean-payoff games,
- static program analysis via max-plus abstractions,
- tropical neural network verification,
- spectral invariants of weighted automata.

### Cross-domain connections to exploit explicitly

1. **Optimization / Operations Research**  
   The subeigenvector inequalities are dual feasibility constraints. Karp’s cycle mean is the threshold where feasibility appears. This is a graph LP duality phenomenon in disguise.

2. **Dynamical Systems**  
   Tropical eigenvectors are additive eigenmodes for max-plus linear dynamics. Critical components determine asymptotic growth and periodic regime structure.

3. **Computer Science / Verification**  
   Difference constraints and cycle means are core to model checking, scheduling, timed systems, and abstract interpretation. A formal tropical spectral theorem becomes a certified algorithmic primitive.

4. **Neural Networks / Piecewise-Linear Analysis**  
   Max-affine maps are the algebraic skeleton of ReLU-like systems. Tropical eigenvectors correspond to invariant directions or growth modes in piecewise-linear architectures.

5. **Nonlinear Perron–Frobenius Theory**  
   This theorem is the idempotent analogue of classical eigenvector existence. Formalizing it lays groundwork for nonlinear order-preserving homogeneous maps.

### Concrete theorem decomposition roadmap

You should aim to prove several nontrivial lemmas, not just one endpoint theorem.

#### Phase 1: Graph/cycle infrastructure
- Define finite directed cycles in a matrix-weighted graph.
- Define cycle weight and cycle mean.
- Prove basic invariance under cyclic rotation.

#### Phase 2: Difference-constraint characterization
- Prove:
  ```lean
  theorem subeigenpair_iff_difference_constraints ...
  ```
- Prove:
  ```lean
  theorem feasible_iff_all_cycles_bounded ...
  ```
  where feasibility of `v_j - v_i ≤ λ - A i j` is equivalent to every directed cycle having mean `≤ λ` (or `≥ μ` in min-plus convention).

#### Phase 3: Spectral value existence
- Define `λ` as the supremum of cycle means over all nonempty directed cycles.
- Since the graph is finite, prove the supremum is attained by some cycle.

#### Phase 4: Tight-edge/critical graph construction
- Define critical edges by tightness in a minimal feasible potential.
- Prove every critical edge lies on an optimal cycle, or at least every critical SCC contains an optimal cycle.
- Show critical nodes satisfy equality.

#### Phase 5: CSR-style eigenvector extraction
- Restrict to a critical SCC.
- Prove the tight equations are consistent and define an eigenvector there.
- If possible, extend by saturation to a global subeigenvector with equality on the critical part.

### Lean implementation advice

Use concrete finite types:
- `Fin n` for vertices,
- `Matrix (Fin n) (Fin n) ℝ` for weights,
- `Finset` for finite subsets and cycle supports.

Avoid overcommitting to a giant graph API if Mathlib’s digraph support does not align smoothly with weighted cycles. A bespoke lightweight directed-cycle structure may be faster.

For tropical matrix-vector action, if `sup` on `ℝ` creates lattice headaches, define:
```lean
def tropMulVec' {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (i : Fin n) : ℝ :=
  Finset.max' Finset.univ
    (by simpa using Finset.univ_nonempty)
    (fun j => A i j + v j)
```
or package a helper lemma that finite maxima over `Fin n` exist.

Expect the key technical burden to be:
- finite maximum/sup lemmas,
- path/cycle combinatorics,
- converting cycle inequalities to telescoping sums.

### High-value intermediate lemma

A particularly elegant target that may be easier than full CSR but still major:

```lean
theorem exists_least_tropical_spectral_bound
    {n : ℕ} (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ λ : ℝ,
      (∃ v : Fin n → ℝ, IsTropicalSubeigenpair A λ v) ∧
      (∀ μ < λ, ¬ ∃ v : Fin n → ℝ, IsTropicalSubeigenpair A μ v) := by
  sorry
```

This theorem alone would be a formal max-plus Collatz–Wielandt-type threshold result. Then the critical-equality theorem becomes the second act.

### Application keywords

tropical linear algebra, max-plus algebra, min-plus algebra, Karp algorithm, minimum cycle mean, maximum cycle mean, tropical eigenvector, tropical Perron–Frobenius, CSR decomposition, critical graph, difference constraints, Bellman–Ford duality, discrete event systems, mean-payoff games, static analysis, piecewise-linear dynamics, formal verification, idempotent analysis

### Deliverables

1. Lean 4 file(s) proving at least one substantial theorem of the above form with minimized `sorry`.
2. Definitions for spectral value, critical graph/tight graph, and tropical (sub)eigenpair.
3. Supporting lemmas connecting cycle means and difference constraints.
4. `FUTURE_DIRECTIONS.md` with 3–5 specific next-step theorem statements.

### Required FUTURE_DIRECTIONS.md content

You must include 3–5 concrete breakthrough next steps, each with:
- precise theorem statement,
- why it matters,
- proof strategy sketch,
- cross-domain connection.

At least three of the following should appear:

1. **Tropical Collatz–Wielandt Formula**  
   Characterize the spectral value as an infimum over subeigenvector bounds and a supremum over cycle means.

2. **Ultimate Periodicity of Max-Plus Powers**  
   Prove that powers `A^k` become eventually periodic modulo linear drift determined by the critical graph cyclicity.

3. **Mean-Payoff Game Duality**  
   Relate tropical eigenvectors to value functions of deterministic mean-payoff games.

4. **Certified Karp Algorithm Correctness**  
   Formalize the dynamic program and prove it computes the cycle mean exactly.

5. **Tropical Neural Fixed-Point Certificates**  
   Transfer the tropical eigenvector machinery to max-affine/ReLU-inspired operators.

Be bold: the ideal outcome is not merely “an eigenvector exists,” but a formal platform from which tropical spectral algorithms, optimization duality, and piecewise-linear dynamics can all be certified in Lean.

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
