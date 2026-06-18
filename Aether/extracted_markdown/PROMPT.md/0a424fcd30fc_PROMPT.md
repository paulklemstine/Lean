## Mode: prove

### Breakthrough Objective

Formalize and prove a **tropical Perron–Frobenius / max-plus spectral theorem** for finite weighted directed graphs encoded by real matrices: the normalized tropical matrix powers converge entrywise to a single scalar, and that scalar is exactly the **maximum cycle mean**. This is not a cosmetic extension of existing tropical algebra. It is the finite-dimensional spectral theorem that underlies tropical dynamics, deterministic optimal control, mean-payoff games, idempotent analysis, and asymptotic graph optimization.

The theorem you should target is stronger than mere existence of a limit point: prove that every entry of the tropical power grows linearly with the same slope, and identify that slope combinatorially.

This would open a formal bridge between:
- tropical linear algebra,
- graph cycle optimization,
- subadditive ergodic style asymptotics in a deterministic finite setting,
- dynamic programming / Bellman operators,
- mean-payoff game semantics,
- tropical representation theory.

### Precise Formal Target

You will likely need to define tropical matrix multiplication and tropical powers if they are not already present in the codebase. Work over `Fin (n+1)` to avoid the empty index type.

A first target theorem, close to the assignment, is:

```lean
theorem tropical_perron_frobenius
    {n : ℕ}
    (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    ∃ λ : ℝ, ∀ ε > 0, ∃ N : ℕ, ∀ m ≥ N, ∀ i j : Fin (n+1),
      |tropPow W m i j / (m + 1 : ℝ) - λ| < ε
```

But the real breakthrough target should identify `λ` explicitly. Introduce a finite combinatorial definition of the maximum cycle mean using simple cycles, then prove:

```lean
def cycleMean
    {n : ℕ}
    (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (C : SimpleCycle (Fin (n+1))) : ℝ := ...

def maxCycleMean
    {n : ℕ}
    (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) : ℝ :=
  Finset.sup' (simpleCyclesFinset (Fin (n+1))) ... (fun C => cycleMean W C)

theorem tropical_perron_frobenius_with_value
    {n : ℕ}
    (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    ∀ ε > 0, ∃ N : ℕ, ∀ m ≥ N, ∀ i j : Fin (n+1),
      |tropPow W m i j / (m + 1 : ℝ) - maxCycleMean W| < ε
```

A still more usable structural theorem is the bounded-deviation form:

```lean
theorem tropPow_linear_growth_bounded
    {n : ℕ}
    (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    ∃ λ C : ℝ, 0 ≤ C ∧
      ∀ m : ℕ, ∀ i j : Fin (n+1),
        |tropPow W m i j - (m : ℝ) * λ| ≤ C
```

From this, the asymptotic theorem follows immediately by dividing by `m+1`. In practice, this bounded-deviation theorem is likely the right formal backbone.

### Necessary Definitions You Should Introduce

You should make the semantics fully graph-theoretic.

1. **Tropical matrix product**
```lean
def tropMul {n : ℕ}
    (A B : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    Matrix (Fin (n+1)) (Fin (n+1)) ℝ :=
  fun i j => ⨆ k, (A i k + B k j)
```
Since the index type is finite, this should be implemented using `Finset.sup` rather than `iSup`.

2. **Tropical power**
```lean
def tropPow {n : ℕ}
    (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) : ℕ →
    Matrix (Fin (n+1)) (Fin (n+1)) ℝ
| 0 => tropId
| m+1 => tropMul (tropPow m) W
```

3. **Path interpretation**
Define the weight of a path of length `m` from `i` to `j`, and prove:
```lean
theorem tropPow_eq_max_path_weight ...
```
This is the decisive combinatorial lemma: `tropPow W m i j` is the maximum weight of a length-`m` walk from `i` to `j`.

4. **Cycle mean**
Define the weight and length of a simple directed cycle and the ratio `weight / length`.

Because the vertex set is finite, there are finitely many simple cycles, so the maximum exists constructively.

### Why This Is a Breakthrough

This theorem is the tropical analogue of classical Perron–Frobenius, but with a fundamentally different geometry: addition becomes maximization, multiplication becomes addition, eigenvalues become cycle means, and spectral growth becomes a graph-combinatorial invariant. Formalizing this in Lean would create a reusable spectral engine for:
- longest-path asymptotics,
- deterministic control and Bellman operators,
- discrete event systems,
- scheduling and network timing,
- mean-payoff games,
- tropical automata and weighted formal languages,
- tropicalization of representation-theoretic growth problems.

It would also make the existing tropical catalog qualitatively more powerful. The current listed theorems are isolated; this theorem supplies a unifying asymptotic invariant.

### Proof Strategy A: Walk Decomposition + Cycle Surgery
**Most promising for Lean.**

The key idea: every long walk decomposes into a simple path plus repeated cycles. The maximal average contribution comes from the best cycle mean.

Steps:
1. **Path model for tropical powers.**
   Prove by induction on `m` that `tropPow W m i j` equals the maximum weight among all length-`m` walks from `i` to `j`.

2. **Upper bound via cycle decomposition.**
   Any walk on `n+1` vertices can be decomposed into:
   - a simple path segment of bounded length,
   - a multiset of cycles.
   
   Since every cycle has mean at most `μ := maxCycleMean W`, the total walk weight is at most
   `m * μ + C`
   for a constant `C` depending only on `W` and `n`.

3. **Lower bound via pumping an optimal cycle.**
   Choose a simple cycle `C*` attaining `μ`. For arbitrary `i, j`, connect `i` to a vertex on `C*`, loop around `C*` many times, then connect to `j`. This yields
   `tropPow W m i j ≥ m * μ - C'`
   for all sufficiently large `m` in the strongly connected case, or at least after handling accessibility carefully.

4. **Conclude bounded deviation and divide by `m+1`.**

Why this is best: it is finite, combinatorial, and avoids heavy analytic machinery. Lean can handle finite walks, list decompositions, and constants extracted from finite maxima.

### Proof Strategy B: Max-Plus Subadditivity / Fekete-Type Argument
**Elegant, but needs care to get entrywise uniformity.**

Steps:
1. Define
   ```lean
   a_m := max_{i,j} tropPow W m i j
   ```
   and prove subadditivity up to bounded error, or exact superadditivity for suitable diagonal entries.

2. Use finite-dimensional compactness of cycle statistics to show
   `a_m / m → μ`, where `μ` is the maximal cycle mean.

3. Transfer from global maxima to each fixed entry `i,j` using bounded path-connection overhead.

This is conceptually close to Kingman/Fekete style asymptotics and builds a bridge to ergodic optimization. However, formalizing the transfer from `a_m` to every entry may be more intricate than Strategy A unless you assume irreducibility.

### Proof Strategy C: Bellman Operator / Nonlinear Eigenvector Route
**Deepest conceptual route; best as a second theorem after the main one.**

Interpret `W` as a dynamic programming operator:
```lean
(Tx)_i = max_j (W i j + x_j)
```
Then show the additive eigenvalue equation
```lean
∃ λ v, ∀ i, max_j (W i j + v j) = λ + v i
```
and derive asymptotic linear growth of iterates `T^[m] 0`.

Steps:
1. Prove existence of an additive eigenpair `(λ,v)` from finite graph cycle optimization.
2. Show `T^m 0 = m•λ + O(1)`.
3. Recover matrix-entry asymptotics by interpreting `tropPow W m i j` as a coordinate of `T^m` applied to basis data.

This is the strongest bridge to control theory and mean-payoff games. It may be harder in Lean at first, but it would produce a much more reusable formal interface.

### Critical Refinement: Irreducibility vs General Matrices

As stated, the theorem is too strong for completely arbitrary `W` unless your `tropPow` convention ensures every entry is always finite and the graph has enough connectivity. In max-plus spectral theory, a single common asymptotic slope for **all entries** usually requires a connectivity hypothesis, typically irreducibility / strong connectivity of the underlying graph.

So you should seriously consider proving the following corrected theorem first:

```lean
def stronglyConnectedMatrix {n : ℕ}
    (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) : Prop :=
  ∀ i j : Fin (n+1), ∃ m > 0, ∃ p : Walk i j m, True

theorem tropical_perron_frobenius_irreducible
    {n : ℕ}
    (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hsc : stronglyConnectedMatrix W) :
    ∃ λ : ℝ, ∀ ε > 0, ∃ N : ℕ, ∀ m ≥ N, ∀ i j : Fin (n+1),
      |tropPow W m i j / (m + 1 : ℝ) - λ| < ε
```

Then prove:
```lean
theorem tropical_eigenvalue_eq_maxCycleMean_irreducible ...
```

If the unrestricted theorem fails, produce a formal counterexample and pivot. For example, disconnected or non-communicating components can force different asymptotic behaviors. This is a scientifically valuable move, not a failure.

### Concrete Lean Architecture

You should organize the development into lemmas with strong reuse value.

Suggested files:
- `Tropical/LinearAlgebra/TropicalMatrix.lean`
- `Tropical/LinearAlgebra/TropicalWalks.lean`
- `Tropical/LinearAlgebra/TropicalPerronFrobenius.lean`

Suggested theorem ladder:
1. `tropMul_assoc`
2. `tropPow_succ`
3. `tropPow_eq_max_walk_weight`
4. `simple_cycle_finite`
5. `exists_max_cycle_mean`
6. `walk_weight_le_length_mul_maxCycleMean_add_const`
7. `exists_walk_weight_ge_length_mul_maxCycleMean_sub_const`
8. `tropPow_linear_growth_bounded`
9. `tropical_perron_frobenius_irreducible`
10. `tropical_eigenvalue_eq_maxCycleMean_irreducible`

### How to Build on Catalog Theorems

The listed catalog theorems are not directly spectral, but you should still integrate them conceptually:

- `tropical_clt_growth_bound` suggests there is already a language of tropical growth estimates in the codebase. Reuse any existing asymptotic inequality style, lemma naming conventions, and normalization patterns.
- `tropical_eigenvalue_determines_char` is a conceptual signal that tropical eigenvalues already matter in arithmetic/tropical Langlands directions. Your theorem would provide a graph-theoretic spectral foundation for such invariants.
- `tropical_fundamental_theorem` and `tropical_mirror_theorem` indicate a broader tropical ecosystem. Position your theorem as the linear-algebraic engine underlying these isolated identities.

Do not force artificial dependency if the lemmas are irrelevant. But explicitly cite in comments and documentation that this theorem upgrades the catalog from “examples” to “spectral infrastructure.”

### Cross-Domain Connections to Exploit

1. **Mean-payoff games / theoretical computer science**
   The maximum cycle mean is the value of a deterministic one-player mean-payoff optimization problem. A formal theorem here sets up future formalization of Karp’s algorithm and tropical game semantics.

2. **Optimal control / Bellman operators**
   Tropical powers encode repeated dynamic programming updates. The slope `λ` is the long-run average reward.

3. **Discrete event systems**
   In scheduling and synchronization, max-plus matrix powers describe event timings; the cycle mean is the asymptotic throughput.

4. **Ergodic optimization / subadditive asymptotics**
   This is a finite deterministic analogue of asymptotic growth-rate theorems in ergodic theory.

5. **Tropical representation theory / Langlands**
   If tropical eigenvalues determine characters in rank-1 settings, then a max-plus spectral theorem suggests a route from combinatorial dynamics to tropical character growth.

### High-Value Corollaries

After the main theorem, target at least one of these:

```lean
theorem tropical_gelfand_formula
    {n : ℕ}
    (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hsc : stronglyConnectedMatrix W) :
    ∃ λ, λ = maxCycleMean W ∧
      ∀ i : Fin (n+1), Tendsto (fun m : ℕ => tropPow W m i i / (m : ℝ)) atTop (𝓝 λ)
```

```lean
theorem cycle_mean_attained_by_simple_cycle
    {n : ℕ}
    (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    ∃ C : SimpleCycle (Fin (n+1)), cycleMean W C = maxCycleMean W
```

```lean
theorem tropical_bellman_eigenpair
    {n : ℕ}
    (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (hsc : stronglyConnectedMatrix W) :
    ∃ (λ : ℝ) (v : Fin (n+1) → ℝ),
      ∀ i, (Finset.univ.sup fun j => W i j + v j) = λ + v i
```

The Bellman eigenpair theorem would be a major second-wave result.

### Risk Assessment

The biggest mathematical risk is that the exact statement given in the assignment is false without a connectivity/irreducibility hypothesis. Do not bury this. Test small matrices immediately:
- diagonal matrices with unequal diagonal entries,
- block upper triangular matrices,
- matrices with a dead-end component.

If the theorem fails, formally state and prove the corrected irreducible version, and include a counterexample theorem for the unrestricted claim. That would itself be excellent research hygiene.

### Application Keywords

tropical linear algebra, max-plus algebra, Perron–Frobenius, maximum cycle mean, Karp theorem, Bellman operator, dynamic programming, mean-payoff games, discrete event systems, graph asymptotics, idempotent analysis, tropical spectral theory, longest path growth, nonlinear eigenvalue, formalized mathematics

### Deliverables

1. Lean file proving the strongest correct version of tropical Perron–Frobenius you can support.
2. Supporting definitions for tropical powers, walks, cycle means, and strong connectivity.
3. At least one explicit counterexample if the unrestricted theorem is false.
4. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, such as:
   - formalize Karp’s algorithm and prove it computes `maxCycleMean`,
   - prove existence of tropical eigenvectors / additive Bellman eigenpairs,
   - extend to `ℝ ∪ {-∞}` for authentic max-plus algebra,
   - connect tropical spectral radius to mean-payoff game values,
   - develop a tropical Jordan theory for eventual periodicity of normalized powers.

### Final Directive

Be bold and surgical. Either prove the stated theorem under the right hypotheses, or refute the naive statement and replace it with the true spectral theorem. The win is not “some asymptotic estimate”; the win is to install **tropical spectral asymptotics** as a first-class formalized theory in Lean.

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
