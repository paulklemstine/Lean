## Assignment: Discrete Uniformization via Curvature Flow — A Grand Challenge in Combinatorial Geometric Analysis

Prove new, non-trivial theorems connecting discrete curvature flow to topological uniformization. Build on catalog theorems from `Geometry/`. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.
3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.
4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain ( e.g., number theory + tropical geometry, algebra + physics).
5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### Research Direction: Discrete Uniformization via Curvature Flow

**Core Conjecture.** For every closed orientable triangulated surface $T$ and every target curvature profile $K^* : V \to \mathbb{R}$ satisfying $\sum_v K^*(v) = 2\pi\chi$ and local realizability constraints, there exists a sequence of edge flips transforming $T$ into a triangulation $T'$ with $K_{T'} = K^*$. Moreover, this transformation can be computed in $O(n^3)$ flips where $n = |V|$.

This is the **discrete analogue of the uniformization theorem** — one of the deepest results in mathematics, stating that every simply-connected Riemann surface is conformally equivalent to the unit disk, complex plane, or Riemann sphere. A constructive proof would establish that the *combinatorial* structure of a surface already encodes its conformal class.

---

### Precise Theorem Targets

**Theorem 1 (FlipGraphConnectivity):** Any two triangulations of a closed orientable surface of genus $g$ with the same number of vertices are connected by a sequence of edge flips.

```lean
theorem flip_graph_connected {n : ℕ} (g : ℕ) (T₁ T₂ : Triangulation n g)
    (h₁ : T₁.IsClosed) (h₂ : T₂.IsClosed)
    (h₃ : T₁.IsOrientable) (h₄ : T₂.IsOrientable) :
    ∃ (seq : List Edge) (h_len : seq.length ≤ 6 * n - 15 + 12 * g),
      T₂ = seq.foldl (flip ·) T₁ := by
  sorry
```

*Strategy A (Most Promising):* Induction on genus via handle decomposition. For $g = 0$, use the fact that the flip graph of $S^2$ has diameter $O(n)$ (Pachner's theorem + Negami's result). For $g > 0$, decompose the surface as a connected sum $S^g = S^0 \# S^{g-1}$, show flips can localize to handles, and apply the inductive hypothesis. The key lemma is that handle-preserving flips are sufficient.

*Strategy B:* Direct combinatorial argument using stellar moves (edge flips + vertex insertions/deletions). Since stellar moves generate all triangulations, and vertex insertion/deletion can be simulated by $O(n)$ flips, the result follows. Less promising because the simulation step requires careful bookkeeping.

*Strategy C:* Algebraic topology approach. Show that the flip graph is the 1-skeleton of a convex polytope (the secondary polytope) for $g = 0$, hence connected. For $g > 0$, the secondary polytope structure breaks down, making this approach infeasible beyond genus 0.

**Theorem 2 (VarianceMonotonicity):** The greedy flip algorithm — at each step, flip the edge that maximally decreases $\|K - K^*\|^2$ — strictly decreases curvature variance unless at a local minimum.

```lean
theorem greedy_flip_decreases_variance {n : ℕ} {g : ℕ} (T : Triangulation n g)
    (K* : Fin n → ℝ) (h_target : ∑ i, K* i = 2 * π * (2 - (g : ℝ)))
    (h_realizable : ∀ i, K* i ∈ curvature_realizable_range n g)
    (h_not_optimal : ‖curvature T - K*‖² > 0) :
    ∃ e ∈ T.edges, ‖curvature (T.flip e) - K*‖² < ‖curvature T - K*‖² := by
  sorry
```

*Strategy A (Most Promising):* Use the Hessian structure of the variance functional. The key insight from `CurvatureVariance.lean:sq_dist_decomposition_to_constant` is that variance decomposes as $\|K - K^*\|^2 = \sum_v (K(v) - K^*(v))^2$. When an edge $e$ is flipped, only the curvatures of the four vertices in the two triangles sharing $e$ change. By the intermediate value theorem on the discrete curvature function (parameterized by the dihedral angle at $e$), there exists an angle where variance decreases. The greedy flip selects this angle.

*Strategy B:* Spectral argument. The curvature change under a flip at edge $e$ is $\Delta K = A_e \cdot \delta_e$ where $A_e$ is a local matrix and $\delta_e$ is the angle change. Show that $A_e$ has a negative eigenvalue in the direction of $K^* - K$, guaranteeing a descent direction.

**Theorem 3 (PolynomialConvergence):** The greedy algorithm converges to a triangulation with $\|K - K^*\| < \epsilon$ in $O(n^3 \log(1/\epsilon))$ steps.

```lean
theorem greedy_convergence_bound {n : ℕ} {g : ℕ} (T₀ : Triangulation n g)
    (K* : Fin n → ℝ) (h_target : ∑ i, K* i = 2 * π * (2 - (g : ℝ)))
    (ε : ℝ) (h_ε : 0 < ε) :
    ∃ (k : ℕ) (h_k : k ≤ 6 * n^3 * Real.log (1 / ε) + 1),
      ‖curvature (greedy_sequence T₀ K* k) - K*‖ < ε := by
  sorry
```

*Strategy A:* Potential function argument. Define $\Phi(T) = \|K_T - K^*\|^2$. By Theorem 2, $\Phi$ decreases by at least $\Delta_{\min} > 0$ per step (unless at target). Since $\Phi$ is bounded above by $O(n \cdot \max K^2)$ and below by 0, convergence follows in $O(n \cdot \max K^2 / \Delta_{\min})$ steps. The key is proving $\Delta_{\min} = \Omega(1/n^2)$, which follows from the boundedness of curvature changes per flip.

---

### Novel Definition: Discrete Conformal Class

```lean
/-- Two triangulations are conformally equivalent if they can be connected
    by a sequence of edge flips preserving the discrete conformal class,
    defined as the set of achievable curvature profiles. -/
structure DiscreteConformalClass (n : ℕ) (g : ℕ) where
  representative : Triangulation n g
  curvature_orbit : Set (Fin n → ℝ)
  h_gauss_bonnet : ∀ K ∈ curvature_orbit, ∑ i, K i = 2 * π * (2 - (g : ℝ))
  h_closed_under_flips : ∀ T₁ T₂ : Triangulation n g,
    T₂ ∈ flip_orbit T₁ → curvature T₂ ∈ curvature_orbit
```

This formalizes the discrete analogue of a conformal structure — the equivalence class of triangulations under curvature-preserving flips. It connects to Teichmüller theory: just as the Teichmüller space $\mathcal{T}_g$ parametrizes conformal structures on a genus-$g$ surface, our `DiscreteConformalClass` parametrizes *combinatorial* conformal structures.

---

### Cross-Domain Connection: Discrete Curvature Flow and Tropical Geometry

**Theorem 4 (TropicalCurvatureFlow):** The discrete curvature flow under edge flips is equivalent to a tropical gradient flow on the tropical moduli space of metric graphs.

```lean
theorem tropical_curvature_flow_equiv {n : ℕ} {g : ℕ}
    (T : Triangulation n g) :
    ∃ (ω : TropicalWeights n) (h_ω : ω.IsTropical),
      gradient_flow (tropical_energy ω) = curvature_variance_flow T := by
  sorry
```

*Why this matters:* Tropical geometry studies algebraic varieties over the min-plus semiring $(\mathbb{R} \cup \{\infty\}, \min, +)$. The tropicalization of an algebraic curve is a metric graph. The tropical moduli space $M_g^{\text{trop}}$ parametrizes such graphs, and its topology is governed by edge contractions — the combinatorial analog of our edge flips. This theorem would establish that discrete curvature flow is *literally* a tropical optimization problem, opening the door to tropical algebraic methods (tropical linear programming, tropical eigenvectors) for mesh processing.

*Proof strategy:* Define the tropical weight function $\omega : E \to \mathbb{R}_{\geq 0}$ as the dihedral angle at each edge. Show that the tropical energy $E_{\text{trop}}(\omega) = \bigoplus_v (K(v) \oplus K^*(v))^2$ (where $\oplus = \min$, $\otimes = +$) has gradient equal to the curvature variance gradient. The key lemma is that edge flips are tropical pivots in the tropical simplex method.

---

### Catalog References as Building Blocks

1. **`Geometry/DiscreteGaussBonnet.lean:total_curvature_eq_genus`** — The conservation law $\sum K = 2\pi\chi$. Use this to show that the flip graph preserves total curvature, constraining the search space for uniformizing flows.

2. **`Geometry/CurvatureVariance.lean:sq_dist_decomposition_to_constant`** — The variance decomposition $\|K - K^*\|^2 = \text{Var}(K) + n(\bar{K} - K^*)^2$. Since $\bar{K} = K^*$ by Gauss-Bonnet, the problem reduces to minimizing $\text{Var}(K)$. Use this as the Lyapunov function for convergence analysis.

3. **`Geometry/CurvatureVarianceRealization.lean:necessary_condition_for_equicurved_realization`** — The realizability constraint. Use this to define the feasible set for $K^*$ and prove that the greedy algorithm stays within this set.

4. **`Geometry/CurvatureVarianceRealization.lean:equicurved_curvature_value`** — The target state $K^* = 2\pi\chi / n$. Use this as the unique minimizer of variance, proving convergence to a unique point.

---

### Testable Conjecture

**Conjecture (Flip Spectral Gap):** For any triangulation of $S^2$ with $n \geq 4$ vertices, the flip graph has spectral gap $\lambda_2 \geq \frac{1}{cn^2}$ for some universal constant $c$. This implies that the greedy curvature flow converges in $O(n^2 \log n)$ steps — faster than the naive $O(n^3)$ bound.

**Test:** Compute the adjacency matrix of the flip graph for random triangulations of $S^2$ with $n = 8, 16, 32, 64$ vertices. Estimate $\lambda_2$ via power iteration. Plot $\lambda_2$ vs. $n$ on a log-log scale. If the slope is approximately $-2$, the conjecture is supported. If the slope is steeper (e.g., $-3$), the conjecture is false and the convergence is even faster than predicted.

---

### Revolutionary Significance

1. **Discrete Uniformization Theorem:** A constructive proof would be the first rigorous discrete analogue of the uniformization theorem, establishing that *combinatorial topology determines conformal geometry*. This would unify discrete differential geometry with algebraic topology.

2. **Computational Conformal Geometry:** A polynomial-time algorithm would transform 3D modeling, medical imaging (brain flattening), and computer graphics (texture mapping). Current methods (Circle Packing, Discrete Ricci Flow) lack convergence guarantees; this would provide them.

3. **Tropical Teichmüller Theory:** The connection to tropical geometry opens a new field: the tropical moduli space of discrete conformal structures. This connects to Mumford's geometric invariant theory, Kontsevich's moduli spaces, and the thermodynamic Bethe ansatz in mathematical physics.

4. **Statistical Mechanics of Surfaces:** Curvature variance minimization is a Boltzmann entropy maximization. Edge flips are thermal fluctuations. The convergence theorem becomes a *zeroth law of thermodynamics for discrete surfaces*: every triangulation thermalizes to equicurvature.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 testable scientific hypotheses, each a falsifiable conjecture with a clear computational test. Include: (1) The Flip Spectral Gap conjecture above. (2) A conjecture on the tropical energy landscape having no spurious local minima for genus 0. (3) A conjecture that the greedy flow time is $O(n^{1+\epsilon})$ for any $\epsilon > 0$ on average over random triangulations. (4) A conjecture connecting the flip graph diameter to the Weil-Petersson metric on Teichmüller space. (5) A conjecture that discrete uniformization for genus $g$ requires $\Omega(g \cdot n)$ flips in the worst case.

(b) **RESEARCH_PAPER.md** — A standalone scientific document explaining: (1) The discrete uniformization conjecture and its relationship to the classical theorem. (2) The greedy curvature flow algorithm and its convergence analysis. (3) The tropical geometry interpretation. (4) Computational experiments validating the conjecture for small cases. (5) Implications for computational geometry and mathematical physics.

(c) **ARTICLE.md** — Written in Scientific American style. Title suggestion: "The Shape of Shapes: How Flipping Triangles Reveals the Hidden Geometry of Surfaces." Explain how every bumpy, irregular triangulation can be smoothed into perfect uniformity — and why this mirrors the deepest theorem in complex analysis.

(d) **A verified algorithm**: The greedy curvature flow algorithm, with a proof of partial correctness (if it terminates, it achieves the target curvature) and a complexity bound on the number of flips.

(e) **demo.py**: Implement the greedy curvature flow for triangulations of $S^2$. Visualize: (1) The initial triangulation with curvature heatmap. (2) The flip sequence as an animation. (3) The variance decrease over time. (4) The final equicurved triangulation. Test on triangulations with $n = 20, 50, 100$ vertices and report convergence statistics.

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
