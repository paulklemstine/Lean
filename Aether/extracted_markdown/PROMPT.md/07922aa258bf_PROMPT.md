## Assignment: Random Graphs: Erdős–Rényi Threshold Phenomena as a Formal Theory of Emergence

**Mode:** `prove`

Build a Lean 4 theory of probabilistic phase transitions in finite graphs that goes beyond encoding folklore. The goal is to formalize a genuinely reusable threshold calculus for Erdős–Rényi random graphs, with proofs that expose the mechanism of emergence: first moments create candidates, second moments certify concentration, and monotonicity/branching heuristics force a discontinuous macroscopic change.

You are not being asked to merely define `G(n,p)` and restate textbook asymptotics. You are being asked to construct a formal bridge between:

- **probability on finite product spaces,**
- **graph connectivity and component structure,**
- **spectral and phase-transition ideas already present in the catalog,**
- **algorithmic detection of thresholds.**

The breakthrough is to make **sharp-threshold reasoning itself** a formal object in Lean, so that future work on percolation, random simplicial complexes, random CSPs, and statistical physics can reuse the machinery.

---

## Core Vision

Formalize a finite Erdős–Rényi model `G(n,p)` on labeled vertices `Fin n`, then prove rigorous finite-`n` threshold theorems that asymptotically imply the classical critical windows:

1. **Connectivity threshold near `p = (log n)/n`** via isolated vertices.
2. **Giant-component phase transition near `p = c/n`** with subcritical and supercritical regimes.
3. **Second moment method for subgraph counts** as a general reusable theorem.

Do this in a way that isolates the proof architecture:
- monotone graph properties,
- expectation/variance computations for edge-independent indicators,
- component exploration processes,
- explicit finite inequalities from which asymptotic corollaries follow.

The deepest contribution would be a formal theorem schema saying:  
**if a graph statistic has diverging expectation and controlled dependency graph, then the corresponding monotone property exhibits a threshold.**

That would open a new formal field: **certified random discrete phase transitions**.

---

## Precise Formal Targets

### New definitions you should introduce

At least one genuinely new concept is mandatory. Introduce several, so the theory becomes reusable:

1. `ERGraph n` as a finite random graph model on `Fin n`.
2. `isolatedVertexCount : SimpleGraph (Fin n) → ℕ`
3. `componentOrderProfile : SimpleGraph (Fin n) → Multiset ℕ`
4. `hasGiantComponent (α : ℝ) : SimpleGraph (Fin n) → Prop`
   meaning there exists a connected component of size at least `⌈α n⌉`.
5. `SubgraphCount H G` for injective labeled embeddings of a fixed finite pattern graph `H`.
6. `ThresholdWindow (P : ℕ → ℝ → Prop)` or a simpler predicate encoding one-sided threshold behavior.

These definitions should be designed so later one can instantiate them for random hypergraphs, simplicial complexes, or bootstrap percolation.

---

## Theorem 1: Connectivity threshold via isolated vertices

You should not attempt to formalize the full strongest asymptotic theorem immediately if the probability library friction is too high. Instead, prove a **finite quantitative theorem** that implies the classical threshold statement.

### Mathematical statement

Let `G ~ G(n,p)` with `p = (log n + c)/n`. Then the expected number of isolated vertices satisfies
\[
\mathbb{E}[X_n] = n(1-p)^{n-1},
\]
and for `p = (log n + c)/n` one has asymptotically
\[
\mathbb{E}[X_n] \to e^{-c}.
\]
Moreover, if `p ≤ (log n - ω(n))/n` with `ω(n) → ∞`, then
\[
\mathbb{P}(G \text{ is connected}) \to 0,
\]
while if `p ≥ (log n + ω(n))/n`, then
\[
\mathbb{P}(G \text{ is connected}) \to 1.
\]

### Lean-oriented finite theorem target

A realistic core theorem is:

```lean
theorem expected_isolated_vertices_ER
    (n : ℕ) (p : ℝ) (hn : 1 ≤ n) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    𝔼[isolatedVertexCount (ERGraph.sample n p)] = n * (1 - p)^(n - 1)
```

If direct expectation notation is difficult in your setup, define the probability space explicitly over edge indicator functions and prove an equivalent finite sum identity.

A stronger finite statement:

```lean
theorem connectivity_upper_bound_by_isolated
    (n : ℕ) (p : ℝ) (hn : 1 ≤ n) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    ℙ[GraphConnected (ERGraph.sample n p)] ≤
      1 - ℙ[isolatedVertexCount (ERGraph.sample n p) ≥ 1]
```

and then derive explicit lower/upper bounds using first and second moment estimates on isolated vertices.

### Most promising proof strategy

**Strategy A: edge-product probability space + indicator decomposition**  
Most promising. Model a graph as a function on unordered pairs `Sym2 (Fin n) → Bool` or `→ Prop` with independent Bernoulli marginals. Then:
1. Define the indicator that a fixed vertex is isolated.
2. Sum over vertices to compute expectation.
3. Compute pairwise correlations to bound variance and invoke Chebyshev/Paley–Zygmund-type arguments.

Why this is best: it turns the threshold proof into finite combinatorics plus product-measure algebra, which Lean handles better than asymptotic probability folklore.

**Strategy B: monotone property + threshold window abstraction**  
Define connectivity as an increasing property and prove one-sided implications from isolated vertices.  
This is elegant but likely depends on having enough measure-theoretic machinery for product Bernoulli spaces and monotonicity lemmas.

**Strategy C: asymptotic analysis first, probability second**  
Prove deterministic inequalities like
\[
n(1-p)^{n-1} \le e^{-c+o(1)}
\]
for `p=(log n + c)/n`, then plug into probabilistic lemmas.  
Useful as a support layer, but not sufficient alone.

---

## Theorem 2: Giant component phase transition near `p = c/n`

This is where the project becomes revolutionary: formalize not merely a graph theorem, but a **birth of macroscopic order** theorem akin to statistical mechanics.

### Mathematical statement

For `G ~ G(n,c/n)`:

- If `0 < c < 1`, then with high probability every connected component has size `O(log n)`.
- If `c > 1`, then there exists `ρ(c) > 0` such that with high probability `G` has a component of size at least `ρ(c)n`.

You may formalize a weaker but still deep version:
- subcritical upper bound on existence of components of size `≥ K log n`,
- supercritical lower bound on existence of a component of linear size for explicit `c > 1 + ε`.

### Lean 4 theorem signature target

```lean
theorem subcritical_no_giant
    (c : ℝ) (hc0 : 0 < c) (hc1 : c < 1) :
    ∃ K : ℝ, 0 < K ∧
      Tendsto
        (fun n : ℕ =>
          ℙ[hasGiantComponent (K * Real.log n / n)
               (ERGraph.sample n (c / n))])
        atTop (𝓝 0)
```

This exact signature may need adjustment; a more Lean-realistic finite version is preferable:

```lean
theorem subcritical_component_tail_bound
    (n k : ℕ) (c : ℝ) (hc0 : 0 < c) (hc1 : c < 1) :
    ℙ[∃ C, IsConnectedComponent (ERGraph.sample n (c / n)) C ∧ k ≤ C.card] ≤
      n * (c * Real.exp (1 - c))^k
```

and in the supercritical direction:

```lean
theorem supercritical_linear_component_lower_bound
    (ε : ℝ) (hε : 0 < ε) :
    ∃ α β : ℝ, 0 < α ∧ 0 < β ∧
      ∀ᶠ n in atTop,
        β ≤ ℙ[hasGiantComponent α (ERGraph.sample n ((1 + ε) / n))]
```

### Proof strategy options

**Strategy A: tree-counting / exploration-process upper bound**  
Most promising for Lean. For the subcritical regime:
1. Fix a root vertex.
2. Bound the probability that its component contains a tree of size `k`.
3. Use Cayley/tree counting or a weaker spanning-tree overcount.
4. Union bound over vertices.

This avoids hard branching-process formalization while still capturing the threshold.

**Strategy B: coupling with Galton–Watson branching process**  
Conceptually beautiful and scientifically important:
1. Define a finite exploration process.
2. Dominate/subdominate by a Poisson or Binomial branching process.
3. Use extinction/survival criteria.

This is more field-opening if you can make it work, because it imports statistical physics / branching-process language into formal random graph theory. But it may be technically heavier.

**Strategy C: susceptibility and second moment of component sizes**  
Define
\[
\chi(G) = \frac{1}{n}\sum_i |C_i|^2
\]
and prove divergence near criticality.  
This is a strong cross-domain bridge to phase transitions and could leverage existing catalog phase-transition machinery, but it may be harder than the tree-counting route.

---

## Theorem 3: General second moment method for subgraph counts

This theorem should become a reusable engine for future formal combinatorics.

### Mathematical statement

Let `H` be a fixed finite graph. Let `X_H` count labeled copies of `H` in `G(n,p)`. Then
\[
\mathbb{E}[X_H] = N_H(n) p^{e(H)},
\]
where `N_H(n)` is the number of injective embeddings of `H` into `K_n`.  
Further, if overlaps between two copies are controlled so that
\[
\mathrm{Var}(X_H) = o(\mathbb{E}[X_H]^2),
\]
then
\[
\mathbb{P}(X_H > 0) \to 1.
\]

### Lean type signature target

```lean
theorem expected_subgraphCount
    {m n : ℕ} (H : SimpleGraph (Fin m)) (p : ℝ)
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    𝔼[SubgraphCount H (ERGraph.sample n p)] =
      labeledEmbeddingCount H (Fin n) * p^(H.edgeFinset.card)
```

And the reusable second moment engine:

```lean
theorem second_moment_existence
    (X : Ω → ℕ)
    (hEXpos : 0 < 𝔼[X])
    (hVar : Variance X ≤ ε * (𝔼[X])^2) :
    ℙ[X = 0] ≤ ε / (1 + ε)
```

or some equivalent Paley–Zygmund/Chebyshev-style formal lemma specialized to finite spaces.

### Proof strategy options

**Strategy A: indicator sum over embeddings**  
Most promising:
1. Write `X_H = ∑_φ I_φ`, where `φ` ranges over injective embeddings.
2. Compute expectation termwise using edge independence.
3. Expand `X_H^2` as a double sum and classify overlaps.

This is the canonical reusable method and should be formalized cleanly.

**Strategy B: dependency graph method**  
Define a graph on embeddings where adjacency means edge overlap, then use combinatorial variance bounds.  
This is more abstract and future-proof; excellent if you can package it.

**Strategy C: polynomial method viewpoint**  
Observe `SubgraphCount H` is a low-degree polynomial in Bernoulli edge variables. Then use variance identities for multilinear polynomials.  
This creates a deep bridge to analysis of Boolean functions and theoretical computer science.

---

## Cross-domain theorem requirement

You must include at least one theorem connecting random graphs to a different domain.

### Recommended cross-domain connection: spectral graph theory + phase transitions

Use the existing catalog theorem

- `regular_graph_eigenvalue_bound`
  from `FINAL/Algebra/IharaZeta.lean`

as conceptual scaffolding, even if not directly applicable to non-regular random graphs. The connection to pursue is:

> In the supercritical regime, the emergence of a giant component should force a detectable change in spectral statistics or non-backtracking growth.

A feasible formal theorem is a deterministic bridge:

```lean
theorem giant_component_implies_spectral_mass
    {n : ℕ} {G : SimpleGraph (Fin n)} {α : ℝ}
    (hGiant : hasGiantComponent α G) :
    ∃ H, H ≤ G ∧ IsConnected H ∧
      α * n ≤ spectralMassLowerBound H
```

If spectral machinery is too heavy, prove a weaker but still cross-domain statement linking giant components to **combinatorial entropy** or **branching complexity**, e.g. lower bounds on numbers of walks.

### Alternative cross-domain directions

1. **Statistical physics:** formalize susceptibility as an order parameter and prove it increases near criticality.
2. **Theoretical CS:** connect subgraph count concentration to randomized property testing.
3. **Algebraic combinatorics:** interpret counts via graph polynomials / partition functions.
4. **Information theory:** define edge entropy and show threshold behavior changes mutual dependence of component indicators.

Application keywords you should explicitly incorporate:
`phase transition`, `critical window`, `branching process`, `spectral graph theory`, `non-backtracking walks`, `susceptibility`, `percolation`, `property testing`, `network science`, `statistical mechanics`, `Boolean functions`, `random structures`.

---

## How to use the existing verified theorems

Do not cite the catalog mechanically. Build on it conceptually.

1. `generalized_phase_transition`
   (`FINAL/Algebra/BootstrapDynamics.lean`)

   Use this as a **formal pattern**: identify an order parameter for random graphs, such as
   - expected isolated vertices,
   - susceptibility,
   - giant-component density,
   and phrase your finite-`n` theorem as a phase-transition statement with an explicit control parameter `p` or `c`.

2. `regular_graph_eigenvalue_bound`
   (`FINAL/Algebra/IharaZeta.lean`)

   Use this to motivate a **spectral witness** of emergence. Even if the final theorem is deterministic and not fully probabilistic, showing that giant components imply lower bounds on walk growth or spectral mass would be a substantial bridge.

3. `random_point_soundness_bound`
   (`FINAL/Algebra/RootBound.lean`)

   This is a useful analogy for a **probabilistic certification principle**: a random sample certifies a global property with controlled failure probability. Adapt that mindset to random graphs: local edge independence certifies global existence/nonexistence of substructures.

4. `sieve_threshold`

   This is minor, but threshold inequalities and monotonic positivity estimates may help for finite arithmetic side lemmas.

---

## Concrete proof architecture Aristotle should follow

### Step 1: Build the finite probability space cleanly
Represent `G(n,p)` as independent Bernoulli choices on unordered pairs of vertices. Avoid premature abstraction if it slows you down.

### Step 2: Prove expectation and variance lemmas for indicator sums
This is the backbone of all three theorem families.

### Step 3: Isolate a reusable second-moment theorem
Once this is formalized, connectivity and subgraph-existence results become instances.

### Step 4: Build component-size bounds by exploration/tree overcount
This gives the giant-component threshold without needing the full strength of branching-process formalization.

### Step 5: Add one cross-domain theorem
Prefer spectral / walk-growth / susceptibility.

---

## Lean tactics and proof depth requirements

Your file must contain at least 3 nontrivial theorems whose proofs genuinely use multi-step reasoning such as:
- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- `calc`
- finite sum manipulations
- variance decomposition
- combinatorial case splits on overlapping embeddings

Do not hide substance behind automation. The proofs should teach the machine a new theory.

---

## Candidate Lean theorem list

These are suggested formal targets; adapt names/types to Mathlib realities.

```lean
def isolatedVertexCount {n : ℕ} (G : SimpleGraph (Fin n)) : ℕ := ...

def hasGiantComponent {n : ℕ} (α : ℝ) (G : SimpleGraph (Fin n)) : Prop := ...

def SubgraphCount {m n : ℕ} (H : SimpleGraph (Fin m)) (G : SimpleGraph (Fin n)) : ℕ := ...

theorem expected_isolated_vertices_ER
    (n : ℕ) (p : ℝ) (hn : 1 ≤ n) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    𝔼[isolatedVertexCount (ERGraph.sample n p)] = n * (1 - p)^(n - 1)

theorem variance_isolated_vertices_ER_bound
    (n : ℕ) (p : ℝ) (hn : 2 ≤ n) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    Variance (isolatedVertexCount (ERGraph.sample n p)) ≤
      n * (1 - p)^(n - 1) +
      n^2 * (1 - p)^(2*n - 3)

theorem subcritical_component_tail_bound
    (n k : ℕ) (c : ℝ) (hc0 : 0 < c) (hc1 : c < 1) :
    ℙ[∃ C, IsConnectedComponent (ERGraph.sample n (c / n)) C ∧ k ≤ C.card] ≤
      n * (c * Real.exp (1 - c))^k

theorem expected_subgraphCount
    {m n : ℕ} (H : SimpleGraph (Fin m)) (p : ℝ)
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    𝔼[SubgraphCount H (ERGraph.sample n p)] =
      labeledEmbeddingCount H (Fin n) * p^(H.edgeFinset.card)

theorem second_moment_existence
    (X : Ω → ℝ≥0)
    (hEX : 0 < 𝔼[X])
    (hVar : Variance X ≤ ε * (𝔼[X])^2) :
    1 - ε / (1 + ε) ≤ ℙ[X > 0]

theorem giant_component_implies_many_walks
    {n L : ℕ} {G : SimpleGraph (Fin n)} {α : ℝ}
    (hGiant : hasGiantComponent α G) :
    α * n ≤ walkCountLowerBound G L
```

The exact notation may differ, but the mathematical content should remain.

---

## Falsifiable conjecture with clear computational test

You must include at least one conjecture that a script can try to disprove.

### Recommended conjecture

**Conjecture (`susceptibility_peak_near_critical`)**  
For the finite Erdős–Rényi model `G(n,p)`, define
\[
\chi_n(p) = \frac{1}{n}\sum_C |C|^2.
\]
Then for sufficiently large `n`, the function `p ↦ 𝔼[\chi_n(p)]` attains its maximum inside a window
\[
p \in \left[\frac{1 - n^{-1/3}}{n}, \frac{1 + n^{-1/3}}{n}\right].
\]

This is falsifiable by Monte Carlo:
- for fixed large `n`,
- sample `G(n,p)` on a grid of `p`,
- estimate expected susceptibility,
- check whether the empirical maximizer lies outside the predicted window.

Alternative conjecture:
**The normalized largest-component size is the sharpest empirical predictor of the non-backtracking spectral radius crossing 1.**

---

## Mandatory deliverables

You must produce **all** of the following:

1. **A Lean file** with the new definitions and at least 3 deep theorems as above, minimizing `sorry`.
2. **`FUTURE_DIRECTIONS.md`** containing **3–5 testable scientific hypotheses**, each falsifiable with a clear computational or formal test.
3. **`RESEARCH_PAPER.md`** as a **standalone scientific paper**:
   - define the model,
   - state the theorems,
   - explain proof ideas,
   - explain why formal threshold theory matters,
   - identify next steps.
4. **`ARTICLE.md`** in **Scientific American style**:
   explain giant components, criticality, and why formal proof assistants can capture emergence.
5. **A verified algorithm or computational method**:
   e.g. a certified routine that estimates isolated-vertex expectation, subgraph-count expectation, or giant-component detection bounds from `n,p`.
6. **`demo.py`**:
   an interactive script that simulates `G(n,p)`, plots connectivity probability / giant component size / susceptibility, and compares experiments to the formal bounds.

---

## Scientific significance

If done well, this project does not merely formalize classical random graph facts. It creates the first reusable Lean framework for **discrete critical phenomena**. That opens immediate follow-on work on:

- random hypergraphs,
- Linial–Meshulam random complexes,
- bootstrap percolation,
- random SAT and CSP thresholds,
- spectral signatures of emergence,
- probabilistic combinatorics as a formal experimental science.

This is the right scale of ambition: not “a theorem about random graphs,” but a **formal language for phase transitions in finite random structures**.

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

Research domain: Algebra
Research mode: prove
