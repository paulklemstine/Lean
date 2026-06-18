## Assignment: Direction 2: Discrete Curvature Flow with Convergence Guarantee

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

**Core Vision.** Establish that combinatorial curvature flow—the discrete analog of Hamilton's Ricci flow—converges in polynomially many steps on triangulated surfaces, yielding the first certified mesh regularization algorithm with provable convergence. This bridges discrete differential geometry, convex optimization, and statistical mechanics.

---

### Precise Theorem Statements (Lean 4 Targets)

**New Definitions Required:**

```lean
-- A locally planar triangulation of a closed surface
structure Triangulation where
  n : ℕ          -- number of vertices
  hn : n ≥ 4
  edges : Finset (Fin n × Fin n)    -- undirected edges (stored as ordered pairs with fst < snd)
  faces : Finset (Fin n × Fin n × Fin n)  -- oriented triangles
  -- Well-formedness: every edge bounds exactly 2 faces, Euler formula holds, locally planar

-- Discrete Gaussian curvature (angle defect)
def angleDefect (T : Triangulation) (v : Fin T.n) : ℝ :=
  2 * π - (∑ face in facesContaining T v, interiorAngle T face v)

-- Curvature variance (already in catalog, but we need the discrete instantiation)
def curvatureVariance (T : Triangulation) : ℝ :=
  (1 / T.n : ℝ) * ∑ v : Fin T.n, (angleDefect T v - avgCurvature T)²

-- The key new structure: a variance-decreasing edge flip
-- An edge flip replaces edge (a,c) with edge (b,d) in quadrilateral (a,b,c,d)
def greedyFlip (T : Triangulation) : Triangulation :=
  -- Select the edge whose flip maximally decreases curvatureVariance
  -- Ties broken by choosing the edge adjacent to the vertex with max |K(v) - K̄|
  ...

-- The flow: iterated application of greedyFlip
def curvatureFlow : ℕ → Triangulation → Triangulation
  | 0, T => T
  | k + 1, T => greedyFlip (curvatureFlow k T)
```

**Theorem 1 (Monotonicity):** Every greedy flip decreases curvature variance.

```lean
theorem curvatureFlow_monotone (T : Triangulation) :
  curvatureVariance (greedyFlip T) ≤ curvatureVariance T ∧
  (curvatureVariance (greedyFlip T) = curvatureVariance T ↔ isLocalMinimum T)
```

**Theorem 2 (Progress Bound):** If `T` is not a local minimum, the greedy flip decreases variance by at least `Ω(1/n²)`.

```lean
theorem progress_bound (T : Triangulation) (h : ¬isLocalMinimum T) :
  curvatureVariance T - curvatureVariance (greedyFlip T) ≥ C / (T.n : ℝ)²
```

where `C` is a universal constant depending only on the genus.

**Theorem 3 (Polynomial Convergence):** The flow reaches an ε-approximate local minimum in `O(n² · (V₀ / ε))` steps, where `V₀` is the initial variance.

```lean
theorem curvatureFlow_converges (T₀ : Triangulation) (ε : ℝ) (hε : ε > 0) :
  ∃ k : ℕ, k ≤ ⌈(T₀.n : ℝ)² * curvatureVariance T₀ / ε⌉₊ ∧
    curvatureVariance (curvatureFlow k T₀) ≤ ε ∧
    (∀ j ≥ k, curvatureVariance (curvatureFlow j T₀) ≤ ε)
```

**Theorem 4 (Cross-Domain: Curvature Variance ↔ Discrete Heat Equation):** The curvature flow is equivalent to a discrete heat equation on the curvature distribution, with Gauss-Bonnet as the mass conservation law.

```lean
theorem curvature_flow_is_heat_equation (T : Triangulation) :
  ∃ (Δ : Fin T.n → Fin T.n → ℝ),  -- discrete Laplacian on the vertex graph
    (∀ v, angleDefect (greedyFlip T) v - angleDefect T v = -Δ v • angleDefect T) ∧
    (∑ v, angleDefect T v = 2 * π * (2 - genus T))  -- Gauss-Bonnet preserved
```

This establishes that the flow is a **discrete diffusion process** — curvature "flows" from high-curvature to low-curvature vertices, exactly as heat flows from hot to cold regions.

**Theorem 5 (Genus-Zero Uniqueness):** For genus 0, the equicurved triangulation (all vertices have curvature `4π/n`) is the unique global minimizer of curvature variance.

```lean
theorem genus_zero_unique_minimizer {T : Triangulation} (hg : genus T = 0) :
  (∀ T', isLocalMinimum T' → curvatureVariance T' ≥ curvatureVariance equicurved) ∧
  (curvatureVariance equicurved = (4 * π / (T.n : ℝ))² * (T.n - 1) / T.n)
```

Wait — for genus 0, the equicurved state has `K(v) = 4π/n` for all `v`, so variance is 0. This is achievable only if `4π/n` is realizable. The theorem should state that the infimum of variance over all triangulations is 0, and the flow drives variance toward 0.

```lean
theorem genus_zero_variance_infimum {T : Triangulation} (hg : genus T = 0) :
  curvatureVariance T ≥ 0 ∧
  (∀ ε > 0, ∃ k ≤ ⌈(T.n : ℝ)² * curvatureVariance T / ε⌉₊,
    curvatureVariance (curvatureFlow k T) ≤ ε)
```

---

### Proof Strategies

**Strategy A: Lyapunov Function via Decomposition Identity (RECOMMENDED)**

This is the most promising approach because it directly leverages the catalog's `sq_dist_decomposition_to_constant`.

1. **Lyapunov function**: Set `V(T) = curvatureVariance(T)`. By `curvatureVariance_nonneg`, this is bounded below by 0. By `sq_dist_decomposition_to_constant`, we have:
   ```
   V(T) = (1/n) Σᵢ (Kᵢ - K̄)² = (1/(2n)) Σᵢⱼ (Kᵢ - Kⱼ)² / n
   ```
   This is a sum of pairwise squared differences, which is more amenable to local analysis.

2. **Local progress**: When we flip edge `(a,c)` to `(b,d)` in quadrilateral `(a,b,c,d)`, only the curvatures at vertices `{a,b,c,d}` change. The change in `V` can be written as a sum over pairs involving these four vertices. Show that the greedy choice (flip the edge that maximizes decrease) decreases `V` by at least `C/n²` because:
   - The decomposition into pairwise terms means each flip affects `O(n)` of the `O(n²)` total terms.
   - By Cauchy-Schwarz, the maximum local improvement is proportional to the maximum local curvature deviation.
   - Since we flip the edge adjacent to the maximum-deviation vertex, the improvement is `Ω(max_v |K(v) - K̄|² / n)`.
   - The gap `V(T) - 0` equals `(1/n) Σᵢ (Kᵢ - K̄)²`, so `max_v |K(v) - K̄|² ≥ V(T)`. Combining: improvement ≥ `C · V(T) / n²`.

3. **Convergence**: Since `V` decreases by at least `C · V / n²` per step (when `V > 0`), we get `V(k+1) ≤ V(k) · (1 - C/n²)`. This gives geometric convergence: `V(k) ≤ V(0) · (1 - C/n²)^k`. To reach `V(k) ≤ ε`, we need `k ≤ (n²/C) · ln(V(0)/ε)`.

**Strategy B: Convex Optimization on the Curvature Polytope**

1. View the set of achievable curvature vectors `{K ∈ ℝⁿ : Σ Kᵢ = 2πχ, Kᵢ ∈ (0, 2π)}` as a convex polytope.
2. Show that edge flips correspond to projected gradient descent steps on `V(K) = (1/n)||K - K̄·1||²`.
3. Apply convergence results for projected gradient descent (Nesterov): `O(1/ε)` iterations to reach `ε`-suboptimality.

This approach is elegant but harder to formalize because the "achievable curvature polytope" is difficult to characterize in Lean.

**Strategy C: Spectral Gap / Mixing Time Analysis**

1. Define a Markov chain on triangulations where transitions are uniform random variance-decreasing edge flips.
2. Show this chain has a spectral gap `≥ C/n²` by establishing a Poincaré inequality on the space of curvature assignments.
3. Mixing time `O(n² log(1/ε))` follows from the spectral gap.

This is theoretically clean but requires developing Markov chain theory in Lean, which is a heavy dependency.

**Recommendation**: Use Strategy A for the main convergence proof. Strategy B provides intuition for why the flow works (it's gradient descent on a convex function). Strategy C connects to statistical mechanics but is better left as future work.

---

### Catalog Building Blocks

- **`Geometry/CurvatureVariance.lean: curvatureVariance_nonneg`** — The lower bound `V(T) ≥ 0` is the foundation: the Lyapunov function is bounded below, so the flow cannot decrease indefinitely.

- **`Geometry/CurvatureVariance.lean: sq_dist_decomposition_to_constant`** — This is the KEY identity. It decomposes variance into pairwise squared differences, enabling local analysis of edge flips. Specifically:
  ```
  V(T) = (1/n) Σᵢ (Kᵢ - K̄)² = (1/(2n²)) Σᵢⱼ (Kᵢ - Kⱼ)²
  ```
  When an edge flip changes curvatures at vertices `{a,b,c,d}`, only the `O(n)` terms involving these vertices change. The identity lets us bound the change in terms of local curvature deviations.

- **`Geometry/CurvatureVarianceRealization.lean: surface_curvatureVariance_nonneg`** — Confirms the variance framework instantiates correctly on surfaces, validating our discrete-to-continuous analogy.

---

### Cross-Domain Connections

**1. Discrete Differential Geometry ↔ Statistical Mechanics (Curvature Flow = Thermalization)**

The curvature flow is a discrete analog of thermalization in statistical mechanics:
- Curvature variance ↔ thermal energy (both measure deviation from equilibrium)
- Gauss-Bonnet ↔ energy conservation (both constrain total "mass")
- Greedy flip ↔ maximum entropy production (both drive toward equilibrium)
- Convergence time ↔ relaxation time (both polynomial in system size for "nice" systems)

**Theorem 4 formalizes this**: the flow satisfies a discrete heat equation, meaning curvature diffuses according to a Laplacian on the vertex graph. This is precisely the discrete analog of Fourier's law of heat conduction.

**2. Curvature Flow ↔ Combinatorial Ricci Flow (Chow-Luo)**

The Chow-Luo combinatorial Ricci flow modifies edge weights (not edge connectivity) to achieve target curvatures. Our flow modifies connectivity (edge flips) while keeping weights implicit. The two flows are complementary: one adjusts the metric, the other adjusts the topology. Together, they provide a complete discrete analog of the continuous Ricci flow program (Hamilton-Perelman).

**3. Curvature Variance ↔ Information Theory**

The curvature variance `V(T)` equals `(1/n) Σ(Kᵢ - K̄)²`, which is the **Fisher information** of the curvature distribution with respect to the uniform (maximum entropy) distribution. Minimizing variance = minimizing Fisher information = maximizing entropy subject to Gauss-Bonnet. This is Jaynes' maximum entropy principle in disguise.

**Application Keywords:** mesh regularization, finite element preprocessing, Ricci flow, discrete conformal geometry, surface parametrization, Markov chain mixing, Poincaré inequality, Lyapunov stability, thermalization, certified optimization

---

### Falsifiable Conjecture

**Conjecture (Quadratic Convergence Rate):** For any triangulation `T` of a closed surface with `n` vertices and genus `g`, the curvature flow satisfies:
```
curvatureVariance(curvatureFlow k T) ≤ V₀ · exp(-C · k / n²)
```
where `V₀ = curvatureVariance(T)` and `C` is a universal constant (independent of `n` and `g`).

**Computational Test:**
1. Generate 1000 random triangulations with `n = 50, 100, 200, 500` vertices for genus 0, 1, 2.
2. Run curvature flow until variance drops below `V₀ / 1000`.
3. Plot `log(V(k)/V₀)` vs `k/n²`. If the conjecture holds, all curves collapse to a line with slope `≥ -C`.
4. Fit `C` from the data. A counterexample would be a triangulation where the plot shows slope decreasing to 0 (convergence slower than exponential in `k/n²`).

**Stronger Conjecture (Genus-Dependent Rate):** The constant `C` satisfies `C ≥ π / (4(1 + g)²)` where `g` is the genus. This predicts slower convergence for higher genus, analogous to how thermalization time increases with system complexity.

---

### Revolutionary Significance

This work establishes the **first polynomial-time convergence guarantee for combinatorial curvature flow**, with direct applications:

1. **Finite Element Mesh Optimization**: Certified mesh regularization with provable convergence — no more heuristic edge-flip heuristics.
2. **Discrete Ricci Flow Theory**: Provides the topological-flow companion to the metric-flow (Chow-Luo) theory, completing the discrete analog of Perelman's program.
3. **Statistical Mechanics of Curvature**: Opens the study of curvature distributions on surfaces as thermodynamic systems, with entropy, temperature, and phase transitions.
4. **Markov Chain Methods in Geometry**: The flow defines a natural Markov chain on triangulations; its mixing time determines convergence, connecting to the rapidly developing theory of Markov chains on combinatorial objects.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 testable scientific hypotheses, each falsifiable with a computational experiment. Include:
   - The genus-dependent convergence rate conjecture above
   - A conjecture on the spectral gap of the flip Markov chain
   - A conjecture on phase transitions in the curvature distribution at high genus
   - A conjecture connecting curvature variance minimization to mesh quality metrics (aspect ratio, Delaunay property)

(b) **RESEARCH_PAPER.md** — A standalone scientific document presenting: (1) the curvature flow definition, (2) the Lyapunov analysis via decomposition identity, (3) the polynomial convergence theorem, (4) the heat equation interpretation, (5) computational experiments. Someone reading ONLY this paper must understand what was discovered and why it matters.

(c) **ARTICLE.md** in Scientific American style — Explain how "curvature flows downhill like heat" and why this gives us certified mesh optimization. Use the analogy: "Just as heat flows from hot to cold until equilibrium, curvature flows from sharp to flat until the surface is as smooth as its topology allows."

(d) **Verified algorithm**: The `greedyFlip` operation and `curvatureFlow` iteration, with proven monotonicity and convergence rate bounds.

(e) **demo.py** — Interactive visualization of curvature flow on random triangulations. Show: (1) the triangulation with vertices colored by curvature, (2) the variance decreasing over time, (3) the convergence rate compared to the theoretical bound.

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
