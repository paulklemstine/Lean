# Soli Deo Gloria

## Assignment: Strict Sub-d Integrality Gap Without Capping — A Local-Geometry Barrier Breaking Theorem

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

---

## The Central Conjecture (Precise Form)

**Conjecture (Sub-d Integrality Gap from Pair Codegree)**. For every integer $d \geq 3$ and $K \geq 1$, there exist constants $\varepsilon(d,K) > 0$ and $n_0(d,K)$ such that for every $d$-uniform hypergraph $H$ on $n \geq n_0$ vertices with maximum pair codegree $\Delta_2(H) \leq K$:

$$\tau(H) \leq (d - \varepsilon(d,K)) \cdot \tau^*(H)$$

The predicted form is $\varepsilon(d,K) = \frac{c_d}{K+1}$ where $c_d \approx \frac{1}{2d}$.

---

## Lean 4 Formalization Targets

### New Definitions (Required — Not in Catalog)

```lean
/-- The pair codegree of a 2-element set s in hypergraph H:
    number of edges of H containing both elements of s. -/
def pairCodegree {α : Type*} [DecidableEq α] 
    (H : Set (Finset α)) (s : Finset α) : ℕ :=
  (H.filter (fun e => s ⊆ e)).toFinset.card

/-- Maximum pair codegree over all 2-element subsets. -/
def maxPairCodegree {α : Type*} [Fintype α] [DecidableEq α]
    (H : Set (Finset α)) : ℕ :=
  sSup {(pairCodegree H s) | s : Finset α, s.card = 2}

/-- The repair set for threshold rounding: vertices needed to cover
    edges not hit by the initial threshold selection. -/
def repairSet {α : Type*} [DecidableEq α] [Fintype α]
    (H : Set (Finset α)) (x : α → ℝ) (θ : ℝ) : Finset α :=
  ⋃ e ∈ H.toFinset, if ∀ v ∈ e, x v < θ then e else ∅

/-- The conflict graph on uncovered edges: two uncovered edges
    are adjacent iff they share a 2-element subset. -/
def conflictGraph {α : Type*} [DecidableEq α] [Fintype α]
    (H : Set (Finset α)) (x : α → ℝ) (θ : ℝ) : Set (Finset α × Finset α) :=
  {(e₁, e₂) | e₁ ∈ H ∧ e₂ ∈ H ∧ e₁ ≠ e₂ ∧ 
    ∃ s ⊆ e₁ ∩ e₂, s.card = 2 ∧ (∀ v ∈ e₁, x v < θ) ∧ (∀ v ∈ e₂, x v < θ)}
```

### Primary Theorem (Lean 4 Signature)

```lean
/-- The strict sub-d integrality gap for hypergraphs with bounded pair codegree.
    This is the main result: the integrality gap is strictly less than d
    when pair codegree is bounded, without any capping assumption. -/
theorem integrality_gap_strict_of_bounded_codegree 
    {α : Type*} [Fintype α] [DecidableEq α] [LinearOrder α]
    {d K : ℕ} (hd : d ≥ 3) (hK : K ≥ 1)
    (H : Set (Finset α)) 
    (hunif : ∀ e ∈ H, e.card = d)
    (hcodeg : ∀ s, s.card = 2 → pairCodegree H s ≤ K)
    (hn : (⋃ e ∈ H, (e : Set α)).toFinset.card ≥ n₀ d K)
    (hτstar_pos : τ* H > 0) :
    τ H ≤ (d - ε d K) * τ* H := by
  sorry
```

### Supporting Lemmas (Deep Proof Tactics Required)

```lean
/-- Key Lemma 1: Threshold rounding covers most edges.
    If x is a fractional transversal and θ = 1/(d-1), then the 
    threshold set S = {v : x(v) ≥ θ} satisfies |S| ≤ (d-1)·τ*(H)
    and covers all edges where some vertex has weight ≥ θ. -/
theorem threshold_rounding_covers_most 
    {α : Type*} [Fintype α] [DecidableEq α]
    {d : ℕ} (hd : d ≥ 3) (H : Set (Finset α))
    (hunif : ∀ e ∈ H, e.card = d)
    (x : α → ℝ) (hx : IsFractionalTransversal H x)
    (hθ : θ = 1 / (d - 1)) :
    let S := {v | x v ≥ θ}
    (∀ e ∈ H, (∃ v ∈ e, x v ≥ θ) → e ⊆ S) ∧
    ∑ v, x v ≤ τ* H → |S| ≤ ⌈(d - 1 : ℝ) * τ* H⌉₊ := by
  sorry

/-- Key Lemma 2: Bounded pair codegree implies bounded chromatic number
    of the conflict graph of uncovered edges.
    
    This is the crucial structural insight: the conflict graph G on uncovered
    edges (where e₁ ~ e₂ iff |e₁ ∩ e₂| ≥ 2) has chromatic number at most
    K + 1 when Δ₂(H) ≤ K. This follows because each uncovered edge shares
    ≥2 vertices with at most K other uncovered edges (by codegree bound),
    so the maximum degree in G is at most K·(d choose 2), giving χ(G) ≤ K·(d choose 2) + 1.
    
    The deeper bound χ(G) ≤ K + 1 comes from the observation that the
    intersection graph of sets containing a common pair is a clique complex,
    and the pair codegree bound makes this a K-bounded hypergraph. -/
theorem conflict_graph_chromatic_bound 
    {α : Type*} [Fintype α] [DecidableEq α]
    {d K : ℕ} (hd : d ≥ 3) (hK : K ≥ 1)
    (H : Set (Finset α))
    (hunif : ∀ e ∈ H, e.card = d)
    (hcodeg : ∀ s, s.card = 2 → pairCodegree H s ≤ K)
    (x : α → ℝ) (θ : ℝ) :
    let U := {e ∈ H | ∀ v ∈ e, x v < θ}
    χ (conflictGraphOn U) ≤ K * (d.choose 2) + 1 := by
  sorry

/-- Key Lemma 3: Greedy repair with chromatic bound.
    If the uncovered edges have conflict chromatic number χ, then
    we can repair with at most χ additional vertices per color class.
    Since each color class is an independent set in the conflict graph,
    any two edges in the same class share at most 1 vertex, so the
    greedy algorithm covers each class using at most |class|/(d-1)
    additional vertices. -/
theorem greedy_repair_bound 
    {α : Type*} [Fintype α] [DecidableEq α]
    {d K : ℕ} (hd : d ≥ 3) (hK : K ≥ 1)
    (H : Set (Finset α))
    (hunif : ∀ e ∈ H, e.card = d)
    (hcodeg : ∀ s, s.card = 2 → pairCodegree H s ≤ K)
    (x : α → ℝ) (hx : IsFractionalTransversal H x)
    (hθ : θ = 1 / (d - 1)) :
    let S₁ := {v | x v ≥ θ}
    let U := {e ∈ H | ∀ v ∈ e, x v < θ}
    let χ := χ (conflictGraphOn U)
    ∃ R : Finset α, (∀ e ∈ U, ∃ v ∈ R, v ∈ e) ∧ R.card ≤ χ * (⌈τ* H⌉₊ : ℕ) := by
  sorry

/-- Key Lemma 4: Combining threshold and repair gives the gap.
    The total transversal size |S₁ ∪ R| ≤ (d-1)·τ* + (K·(d choose 2)+1)·τ*
    = (d - 1 + K·d·(d-1)/2 + 1)·τ*, which after careful optimization
    of θ and asymptotic analysis gives the (d - c_d/(K+1)) bound. -/
theorem combined_gap_bound 
    {α : Type*} [Fintype α] [DecidableEq α] [LinearOrder α]
    {d K : ℕ} (hd : d ≥ 3) (hK : K ≥ 1)
    (H : Set (Finset α))
    (hunif : ∀ e ∈ H, e.card = d)
    (hcodeg : ∀ s, s.card = 2 → pairCodegree H s ≤ K)
    (hn : (⋃ e ∈ H, (e : Set α)).toFinset.card ≥ n₀ d K)
    (hτstar_pos : τ* H > 0) :
    τ H ≤ (d - (1 : ℝ)/(2 * d * (K + 1))) * τ* H := by
  sorry
```

---

## Proof Strategies (Three Paths)

### Strategy A: Layered Threshold Rounding with Conflict Graph Coloring (Most Promising)

**Why most promising**: This directly exploits the local overlap geometry. The pair codegree bound creates a *sparseness condition* on the conflict hypergraph that is strictly stronger than what uniformity alone gives.

1. **Threshold phase**: Set $\theta = \frac{1}{d-1}$ and let $S_1 = \{v : x(v) \geq \theta\}$. Since $x$ is a fractional transversal of total weight $\tau^*$, we have $|S_1| \leq (d-1) \cdot \tau^*(H)$.

2. **Conflict graph phase**: The uncovered edges $U$ form a hypergraph where any two edges sharing $\geq 2$ vertices create a conflict edge. By $\Delta_2 \leq K$, each pair of vertices lies in at most $K$ edges, so the conflict graph on $U$ has maximum degree $\leq K \cdot \binom{d}{2}$. By greedy coloring, $\chi(\text{conflict}(U)) \leq K \cdot \binom{d}{2} + 1$.

3. **Repair phase**: Each color class in the conflict graph is an *independent set* — meaning any two edges in the same class share at most 1 vertex. For such a linear-like hypergraph, a second threshold at $\theta_2 = \frac{1}{d-1}$ (on the residual LP) covers each class using $\leq (d-1)$ vertices per $\tau^*$-unit. Total repair: $\leq (K \cdot \binom{d}{2} + 1)(d-1) \cdot \tau^*$.

4. **Optimization**: The total is $|S_1| + |R| \leq (d-1)\tau^* + (K\binom{d}{2}+1)(d-1)\tau^*$. For $n$ large relative to $K$, the fractional LP value $\tau^* \geq n/(dK)$ (by a volume argument), so the additive overhead becomes a multiplicative improvement: $\tau(H) \leq (d - \Omega(\frac{1}{dK})) \cdot \tau^*(H)$.

**Key insight**: The conflict graph chromatic number bound is the *only* place where $\Delta_2 \leq K$ is used. This means the theorem extends to any structural condition bounding $\chi(\text{conflict}(U))$.

### Strategy B: Probabilistic Rounding with Pair Codegree Variance Control

1. Independently include each vertex $v$ with probability $\min(1, p \cdot x(v))$ where $p = \frac{\ln(dK) + C}{\tau^*}$.

2. The expected number of uncovered edges is controlled by $\Pr[e \text{ uncovered}] \leq (1-p/d)^d \leq e^{-pd}$.

3. **Crucial variance step**: Because $\Delta_2 \leq K$, the indicator random variables for "edge $e$ is uncovered" are *negatively correlated* within each pair-codegree class. Specifically, for edges $e_1, e_2$ sharing a pair, $\Pr[e_1 \text{ unc.} \wedge e_2 \text{ unc.}] \leq \Pr[e_1 \text{ unc.}] \cdot \Pr[e_2 \text{ unc.}] \cdot (1 + O(1/d))$. This near-independence allows concentration.

4. Derandomize via conditional expectations to get a deterministic algorithm achieving the same bound.

**Risk**: The variance analysis requires careful handling of the "shared vertices create positive correlation" issue. Strategy A avoids this entirely.

### Strategy C: Tropical Min-Plus Duality Bridge

This connects to tropical geometry via the observation that $\tau^*(H)$ is the value of the tropical linear program $\min \bigoplus_v x_v$ subject to $\bigoplus_{v \in e} x_v \geq 0$ for all $e \in H$ (in the min-plus semiring).

1. The integrality gap $\tau/\tau^*$ is precisely the *tropical integrality gap* for the covering LP.

2. The pair codegree bound $\Delta_2 \leq K$ translates to a *tropical tropicality condition* on the Newton polytope of the dual packing LP: each codimension-1 face meets at most $K$ facets.

3. By tropical Bernstein–Khovanskii–Kushnirenko (tropical BKK) theory, the tropical volume of this Newton polytope is bounded by $K$, giving a tropical sparseness bound that translates back to the integrality gap.

**Why this is visionary**: It opens a tropical geometric theory of LP integrality gaps, connecting approximation ratios to Newton polytope geometry. However, the formalization path is longer.

**Recommendation**: Pursue Strategy A as the primary path (most direct, best formalization fit). Strategy C should be a FUTURE_DIRECTIONS item.

---

## Cross-Domain Connections

### 1. Proof Complexity: Integrality Gaps → Resolution Lower Bounds

**Theorem (Bridge)**: If $\tau(H)/\tau^*(H) \leq d - \varepsilon for all $H$ with $\Delta_2 \leq K$, then the clause-variable incidence graph of any $d$-CNF formula with maximum variable co-occurrence $\leq K$ admits a resolution refutation of width $\leq d - \varepsilon$ times the fractional covering number.

This connects to: `Catalog/Pythagorean/QuantitativeCodegreeGap.lean` — the integrality gap directly controls proof complexity lower bounds for structured SAT instances.

### 2. Tropical Geometry: Min-Plus Linear Programming

The fractional transversal is a min-plus linear program. The pair codegree bound constrains the *tropical tropical intersection number* of the dual arrangement. This bridges to tropical BKK theory and opens the question: **Is the integrality gap of a covering LP determined by the tropical intersection theory of its constraint arrangement?**

### 3. Statistical Mechanics: Potts Model Ground States

The conflict graph chromatic number bound is equivalent to a ground-state energy bound for a Potts model on the uncovered edges with coupling determined by $K$. The gap $\varepsilon(d,K) = c_d/(K+1)$ resembles a mean-field energy correction in statistical mechanics.

---

## Falsifiable Conjecture with Computational Test

**Conjecture (Sharp Threshold Form)**: For $d = 3$ and $K = 1$, the integrality gap satisfies $\tau(H)/\tau^*(H) \leq 3 - \frac{1}{8}$ for all $n \geq 12$, and the constant $1/8$ is best possible.

**Test**: Generate all 3-uniform hypergraphs on $n = 12$ vertices with $\Delta_2 \leq 1$ (these are *linear* 3-uniform hypergraphs — Steiner triple systems and their subsets). For each, compute $\tau$ (via ILP) and $\tau^*$ (via LP). The conjecture predicts $\max \tau/\tau^* \leq 23/8 = 2.875$. If any instance achieves $\tau/\tau^* > 2.875$, the conjecture is falsified and the constant $c_3$ must be revised downward.

**Computational demo**: `demo.py` should:
1. Generate random linear 3-uniform hypergraphs (Steiner triple system subgraphs)
2. Solve the LP relaxation for $\tau^*$
3. Solve the ILP for $\tau$
4. Plot $\tau/\tau^*$ as a function of $n$ and $K$
5. Compare against the predicted bound $(d - 1/(2d(K+1)))$

---

## Catalog Integration

Build directly on:
- `Catalog/Pythagorean/QuantitativeCodegreeGap.lean`: Theorem `integrality_gap_strict_of_capped` — extend by removing the capping assumption
- `Catalog/Pythagorean/HypergraphTransversal.lean`: Classical bounds on $\tau$ and $\tau^*$ — use as the base definitions
- The new `pairCodegree` and `conflictGraph` definitions are novel to this project

**Critical**: The existing `integrality_gap_strict_of_capped` theorem assumes a *global capping* condition (every vertex in at most $r$ edges). This work replaces that with a *local overlap* condition ($\Delta_2 \leq K$), which is strictly weaker for $d \geq 3$ and more natural in applications (bounded co-occurrence in SAT, bounded overlap in set systems).

---

## Mandatory Deliverables

### (a) FUTURE_DIRECTIONS.md
Must include at least 3 directions, each with "The key insight is..." and "Why now?" At least one must bridge to a different domain. Suggested directions:
1. **Tropical LP Integrality Gap Theory**: The key insight is that covering LP integrality gaps are tropical min-plus optimization problems, and pair codegree bounds are tropical intersection conditions. Why now? Tropical geometry has matured enough to support LP duality.
2. **Proof Complexity of Structured SAT**: The key insight is that sub-d integrality gaps for bounded-codegree hypergraphs directly yield resolution width lower bounds for bounded-co-occurrence CNF formulas. Why now? SAT solvers increasingly exploit structure; understanding the complexity-theoretic limits requires these bounds.
3. **Online Set Cover with Bounded Overlap**: The key insight is that the repair phase of our rounding is a greedy algorithm that can be made online, giving competitive ratios below $d$ for online set cover with $\Delta_2 \leq K$. Why now? Online algorithms for structured instances are a frontier topic.

### (b) RESEARCH_PAPER.md
Standalone scientific document proving: (1) the strict sub-d integrality gap theorem, (2) the conflict graph chromatic number bound, (3) the computational verification of the conjectured constant. Must be readable without access to Lean code.

### (c) ARTICLE.md
Scientific American style. Title suggestion: "When Local Overlap Breaks the Barrier: How Restricting Shared Vertices in Hypergraphs Yields Better Approximations." Focus on the *idea* — that local geometry (pair codegree) controls global approximation quality — NOT on formal verification.

### (d) Verified Algorithm
The layered threshold rounding algorithm: given a fractional transversal $x$ and threshold $\theta$, compute the threshold set $S_1$, identify uncovered edges $U$, greedily color the conflict graph of $U$, and repair each color class. This must be a computable function in Lean, not just an existence proof.

### (e) demo.py
Interactive demonstration that:
1. Generates $d$-uniform hypergraphs with $\Delta_2 \leq K$
2. Solves the LP/ILP for $\tau^*$ and $\tau$
3. Plots the empirical integrality gap ratio against the theoretical bound
4. For $d=3, K=1$, tests the sharp threshold conjecture on $n=12$
5. Shows the conflict graph and its coloring for a small example

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
