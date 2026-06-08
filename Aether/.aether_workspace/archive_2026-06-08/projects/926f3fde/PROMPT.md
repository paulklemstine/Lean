# Mode: prove

## Title
**Primewise Persistent Homology Detects Exceptional Isogeny Volcano Depth**

## Vision

Take the conjectural bridge between arithmetic graph geometry and topological data analysis and turn it into a rigorous theorem schema in Lean 4: not merely that one can attach a filtered simplicial object to local \(\ell\)-isogeny neighborhoods, but that explicit, computable cycle statistics extracted from these filtrations provably recover volcano depth in a mathematically meaningful regime. The breakthrough is not “persistent homology on graphs” in isolation; it is the creation of a **topological invariant of endomorphism-ring stratification**. If successful, this opens a new arithmetic-topological interface: using homological signatures to infer discrete valuation data in isogeny graphs, with consequences for algorithmic navigation, cryptographic heuristics, and the emerging topology of arithmetic moduli.

Your task is to formalize and prove a mathematically sharp surrogate theorem package that captures the essential mechanism behind the conjecture, while also delivering a verified computational pipeline that can be experimentally stress-tested.

---

## Core Mathematical Program

The full conjecture about ordinary elliptic curves over finite fields may currently be beyond direct formalization in Mathlib without a substantial elliptic-curve/isogeny-volcano infrastructure. So the right move is to isolate the **universal combinatorial-topological mechanism** underlying the conjecture and prove it in a general graph-theoretic setting tailored to volcanoes.

The central idea: in an \(\ell\)-volcano, crater vertices support short cycles while descending trees do not. A filtered clique or neighborhood complex built from radius-bounded graph neighborhoods should therefore exhibit a degree-1 persistence profile whose long or short bars encode the distance to the crater. Formalize this for an abstract volcano graph class, then derive arithmetic interpretation statements as corollaries/specifications for future work.

---

## New Definitions You Must Introduce

You must define at least one genuinely new concept. I recommend introducing all of the following.

### 1. Layered volcano graphs
A combinatorial abstraction of an \(\ell\)-isogeny volcano.

```lean
structure LayeredVolcano (V : Type*) [Fintype V] where
  adj : V → V → Prop
  depth : V → ℕ
  crater : Finset V
  maxDepth : ℕ
  symm : Symmetric adj
  irrefl : Irreflexive adj
  depth_le_max : ∀ v, depth v ≤ maxDepth
  crater_iff_depth_zero : ∀ v, v ∈ crater ↔ depth v = 0
  -- optional axioms describing allowed edges:
  edge_depth_constraint : ∀ {u v}, adj u v → depth v = depth u ∨ depth v + 1 = depth u ∨ depth u + 1 = depth v
```

This is the formal combinatorial avatar of an isogeny volcano.

### 2. Radius neighborhood filtration
For a vertex \(v\), define the finite set of vertices within graph distance \(\le r\), and from it a simplicial object such as the flag/clique complex or cycle-generating subgraph.

```lean
def ball (G : LayeredVolcano V) (v : V) (r : ℕ) : Finset V := ...
```

### 3. Cycle-rank profile / persistent cycle signature
Since full persistent homology infrastructure may be heavy, define a tractable invariant that still reflects \(H_1\): for a finite graph \(H\), its cycle rank
\[
\beta_1(H) = |E(H)| - |V(H)| + c(H),
\]
where \(c(H)\) is the number of connected components. Then define the filtration profile:
\[
\mathrm{cycleProfile}(v)(r) := \beta_1(B_r(v)).
\]

```lean
def cycleRank (Gsub : Finset V × Finset (Sym2 V)) : ℕ := ...
def cycleProfile (G : LayeredVolcano V) (v : V) : ℕ → ℕ := ...
```

This is a mathematically serious substitute for degree-1 persistent homology and is enough to detect first-cycle birth. You may then define:

```lean
def firstCycleRadius (G : LayeredVolcano V) (v : V) : ℕ := sInf {r | 0 < cycleProfile G v r}
```

provided you formalize it over finite search ranges, or use `Nat.find`.

### 4. Exceptional vertices
To model arithmetic irregularities and “error probability tending to 0”, define a predicate of exceptional local geometry.

```lean
def Exceptional (G : LayeredVolcano V) (v : V) : Prop := ...
```

For example: the local neighborhood violates the idealized unique-parent/tree-below-crater behavior.

This creates room for theorem statements of the form “outside exceptional vertices, depth is exactly recovered.”

---

## Precise Theorem Targets

You must prove at least **three substantial theorems**. Here is the theorem package I want.

---

### Theorem 1: Tree neighborhoods below the crater have trivial \(H_1\)-surrogate

If the radius-\(r\) ball around \(v\) stays strictly below the crater, then its cycle rank vanishes.

**Mathematical statement.**
Let \(G\) be a layered volcano satisfying the local tree property off the crater. If \(v\) has depth \(d\) and \(r < d\), then the induced subgraph on the radius-\(r\) ball around \(v\) has no cycles. Hence \(\mathrm{cycleProfile}(v)(r)=0\).

This is the first pillar: before the crater is reached, no 1-dimensional topological signal appears.

**Lean-style target signature.**
```lean
theorem cycleProfile_eq_zero_of_lt_depth
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : LayeredVolcano V)
    (tree_below : ∀ v, 0 < G.depth v → IsTreeInducedBallBelow G v)
    (v : V) {r : ℕ}
    (hr : r < G.depth v) :
    cycleProfile G v r = 0
```

You will need to define `IsTreeInducedBallBelow`.

**Why this matters.**
This theorem identifies the “silent regime” of persistence: the filtration detects nothing until the crater becomes visible. It is the topological analog of the arithmetic fact that the lower levels of a volcano are tree-like.

---

### Theorem 2: First cycle birth occurs exactly at crater distance

Under suitable crater-cycle hypotheses, the first radius at which a cycle appears is exactly the depth.

**Mathematical statement.**
Assume every crater vertex lies on a cycle, and every strict subcrater neighborhood below depth \(d\) is acyclic. Then for any non-exceptional vertex \(v\),
\[
\mathrm{firstCycleRadius}(v) = \mathrm{depth}(v).
\]

This is the key theorem: a topological birth time recovers arithmetic depth.

**Lean-style target signature.**
```lean
theorem firstCycleRadius_eq_depth
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : LayeredVolcano V)
    (h_tree : ∀ v r, r < G.depth v → cycleProfile G v r = 0)
    (h_crater_cycle : ∀ v, G.depth v = 0 → ∃ r ≤ 1, 0 < cycleProfile G v r)
    (h_nonexceptional : ∀ v, ¬ Exceptional G v →
      0 < cycleProfile G v (G.depth v))
    (v : V)
    (hv : ¬ Exceptional G v) :
    firstCycleRadius G v = G.depth v
```

This theorem should be proved by combining:
- vanishing for all \(r < \mathrm{depth}(v)\),
- positivity at \(r = \mathrm{depth}(v)\),
- minimality via `Nat.find` or an equivalent finite least-radius argument.

**Why this matters.**
This is the exact formal core of the conjecture. It shows that a persistence-style invariant recovers volcano depth without computing the endomorphism ring directly.

---

### Theorem 3: Crater vs. floor classification by cycle birth or bar-length proxy

Define a classifier:
- crater iff `firstCycleRadius = 0`,
- floor iff depth is maximal and first cycle radius is maximal.

Then prove separation in the idealized model.

**Mathematical statement.**
For non-exceptional vertices in a finite layered volcano:
1. \(v\) is on the crater iff \(\mathrm{firstCycleRadius}(v)=0\).
2. If \(v\) is on the floor and the volcano has positive depth, then \(\mathrm{firstCycleRadius}(v)=\mathrm{maxDepth}\).

**Lean-style target signature.**
```lean
theorem crater_iff_firstCycleRadius_eq_zero
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : LayeredVolcano V)
    (h_main : ∀ v, ¬ Exceptional G v → firstCycleRadius G v = G.depth v)
    (v : V)
    (hv : ¬ Exceptional G v) :
    v ∈ G.crater ↔ firstCycleRadius G v = 0
```

and

```lean
theorem floor_vertices_maximize_firstCycleRadius
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : LayeredVolcano V)
    (h_main : ∀ v, ¬ Exceptional G v → firstCycleRadius G v = G.depth v)
    (v : V)
    (hv : ¬ Exceptional G v)
    (hfloor : G.depth v = G.maxDepth) :
    firstCycleRadius G v = G.maxDepth
```

**Why this matters.**
This gives a concrete classifier extracted from topological data. It is exactly the sort of invariant one could compute locally in isogeny-based cryptographic settings.

---

## Strong Optional Theorem 4: Stability under bounded local perturbation

This is where the project becomes genuinely field-opening.

Suppose two local volcano neighborhoods around vertices \(v,w\) agree up to radius \(R\). Then the first cycle radius agrees up to \(R\), and in particular if both depths are \(\le R\), then equal local neighborhoods imply equal depth.

**Lean-style target signature.**
```lean
theorem firstCycleRadius_stable_under_local_iso
    {V W : Type*} [Fintype V] [DecidableEq V] [Fintype W] [DecidableEq W]
    (G : LayeredVolcano V) (H : LayeredVolcano W)
    (v : V) (w : W) (R : ℕ)
    (hiso : LocalBallIso G H v w R)
    (hdetectG : firstCycleRadius G v ≤ R)
    (hdetectH : firstCycleRadius H w ≤ R) :
    firstCycleRadius G v = firstCycleRadius H w
```

This theorem is a profound algorithmic statement: **depth is locally topologically identifiable**.

---

## Cross-Domain Connection Theorem

You are required to connect to another domain. The most natural bridge is to **topological data analysis / network science**, but be more ambitious: connect arithmetic graph depth detection to **discrete Morse theory** or **spectral graph theory**.

### Recommended cross-domain theorem:
Show that in your volcano model, vanishing cycle rank implies a sharp Euler characteristic identity, and use this to connect the arithmetic depth problem to a topological invariant.

**Mathematical statement.**
For a connected induced radius ball \(B_r(v)\),
\[
\chi(B_r(v)) = 1 - \beta_1(B_r(v)).
\]
Hence, for \(r < \mathrm{depth}(v)\), one has \(\chi(B_r(v))=1\), while at the crater-detecting radius the Euler characteristic drops.

**Lean-style target signature.**
```lean
theorem eulerChar_ball_eq_one_sub_cycleProfile
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : LayeredVolcano V) (v : V) (r : ℕ)
    (hconn : BallConnected G v r) :
    eulerCharBall G v r = 1 - cycleProfile G v r
```

Combined with Theorem 1 and Theorem 2, this becomes a bridge:
**number theory / isogeny graphs ↔ algebraic topology / Euler characteristic ↔ network science / cycle detection**.

If possible, add a spectral heuristic proposition in `RESEARCH_PAPER.md`: the first nontrivial cycle should correlate with a change in local non-backtracking spectrum. Even if not fully formalized, this is a major conceptual bridge.

---

## Proof Strategy Architecture

You asked for 2–3 proof strategy steps. Here are the most promising routes.

### Strategy A: Graph-theoretic exactness via cycle rank
**Most promising for Lean.**
1. Define induced radius balls and the finite edge set inside them.
2. Prove acyclicity below the crater by induction on radius, using the volcano parent-child structure.
3. Derive cycle rank zero from tree structure, then prove exact detection by showing the crater introduces a cycle at the first reachable radius.

Why this is strongest: it uses only finite combinatorics, trees, connected components, and `Nat.find`; this is all realistically formalizable in Lean 4 with Mathlib.

### Strategy B: Simplicial flag complex and \(H_1\)-surrogate
1. Build the clique complex of the induced radius ball.
2. Show that for graph balls that are trees, the clique complex is collapsible / has trivial first homology.
3. Show that reaching the crater creates a nontrivial 1-cycle in the 1-skeleton, yielding positive degree-1 persistence.

Why this is deeper conceptually: it aligns more faithfully with persistent homology. Why it is harder: full simplicial-homology infrastructure may be heavier than necessary. Use it if Mathlib support is already available in the dynamic context.

### Strategy C: Discrete Morse-theoretic birth-time argument
1. Construct a Morse function by graph distance from the root/crater.
2. Show no critical 1-cells occur below the crater.
3. Show the first critical 1-cell appears exactly when a crater cycle becomes visible.

Why this is revolutionary: it links arithmetic graph geometry to Morse theory. Why it is likely secondary: more setup, less immediate library support. Still excellent as a conceptual direction and possibly for the paper.

**Recommendation:** Prove the main theorems with Strategy A, explain B and C in the paper as future generalizations.

---

## Suggested Lean 4 File Structure

Create a new file, for example:

`PrimewisePersistentHomology/VolcanoPersistence.lean`

Organize it as:
1. finite graph preliminaries,
2. layered volcano definition,
3. radius balls and induced subgraphs,
4. cycle rank and first cycle radius,
5. exceptional vertices,
6. main depth-detection theorems,
7. Euler characteristic / cross-domain theorem,
8. executable classifier.

If the catalog contains vetted graph-theory utilities, use those aggressively rather than rebuilding from scratch. In particular, look for:
- finite simple graph infrastructure,
- connected components,
- tree/acyclicity lemmas,
- cardinality lemmas for edges and vertices,
- induced subgraph constructions,
- Euler characteristic or finite CW/simplicial support if available.

When citing catalog theorems in your paper and comments, explain exactly how they are used.

---

## Algorithmic Deliverable

You must provide a verified computational method, not just theorem statements.

### Required algorithm
Define and implement a classifier that predicts depth from local topological data:

```lean
def predictDepth (G : LayeredVolcano V) (v : V) : ℕ :=
  firstCycleRadius G v
```

Then prove correctness on non-exceptional vertices:

```lean
theorem predictDepth_correct
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : LayeredVolcano V) (v : V)
    (hv : ¬ Exceptional G v) :
    predictDepth G v = G.depth v
```

Also implement a computable approximation:
- search radii from `0` to `G.maxDepth`,
- return the first radius with positive cycle profile.

This is the formal algorithmic heart of the project.

---

## Computational Test / Falsifiable Conjecture

You are required to state a falsifiable conjecture with a clear computational refutation criterion.

### Conjecture
For each fixed small prime \(\ell\), there exists \(R_\ell\) such that for all sufficiently large primes \(p\), if \(E/\mathbb{F}_p\) is ordinary and non-exceptional in the \(\ell\)-isogeny graph, then the first cycle radius of the bounded-radius neighborhood complex \(K(E)\) equals the \(\ell\)-volcano depth of \(E\).

### Testable prediction
For random ordinary \(E/\mathbb{F}_p\), the empirical misclassification rate of the classifier
\[
E \mapsto \text{first cycle birth radius}
\]
for crater-vs-floor and depth recovery tends to \(0\) as \(p \to \infty\), outside explicitly detectable exceptional families.

### Refutation criterion
To refute, exhibit an infinite family of ordinary elliptic curves \(E_i/\mathbb{F}_{p_i}\) with unbounded \(p_i\) and fixed \(\ell\) such that:
- either distinct depths yield identical cycle-birth profiles for all bounded radii,
- or crater and floor vertices are not asymptotically separable by the barcode/cycle-profile statistic.

Put this conjecture and refutation criterion explicitly in both the code comments and `RESEARCH_PAPER.md`.

---

## Application Keywords

Include these keywords explicitly in the paper, article, and code comments:

**isogeny volcanoes, elliptic curves over finite fields, persistent homology, topological data analysis, arithmetic graphs, endomorphism rings, local graph invariants, cycle rank, Euler characteristic, discrete Morse theory, graph algorithms, isogeny-based cryptography, local-to-global detection, spectral graph heuristics**

---

## Revolutionary Significance

If you can prove the abstract volcano theorem package, you will have created the first formal blueprint for **topological detection of arithmetic depth**. This opens several research frontiers at once:

1. **Arithmetic TDA:** persistent invariants of moduli graphs, especially isogeny and Hecke graphs.
2. **Cryptographic navigation:** local topological heuristics for finding crater layers or avoiding trap regions in isogeny-based protocols.
3. **Topological endomorphism inference:** recovering ring-theoretic information from local cycle structure.
4. **Spectral-topological arithmetic:** relating cycle birth to non-backtracking operators, Ihara zeta functions, or expansion statistics.
5. **Primewise asymptotics:** studying how arithmetic randomness manifests in persistent barcode distributions across \(p\).

This is not an incremental extension. It is a new language for arithmetic graph structure.

---

## Mandatory Deliverables

You must produce **all** of the following:

### 1. Lean development
A substantial Lean 4 file formalizing the definitions and proving at least 3 nontrivial theorems as above, with deep proof steps using induction, `rcases`, `by_contra`, `field_simp` where relevant, or multi-step `calc`. Minimize `sorry`.

### 2. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each written as prose and each containing:
- **“The key insight is…”**
- **“Why now?”**
At least one direction must bridge to a different domain, such as spectral graph theory, topological data analysis, or cryptography.

### 3. `RESEARCH_PAPER.md`
A **standalone scientific paper** explaining:
- the mathematical problem,
- the new definitions,
- the main theorems,
- proof ideas,
- why the result matters,
- the conjecture and computational test,
- future work.
A reader with no access to the code must understand the discovery.

### 4. `ARTICLE.md`
Write this in **Scientific American style**:
- vivid,
- accessible,
- mathematically serious,
- focused on the ideas and their significance.
**Do not focus on formal verification machinery.** Focus on the discovery: topology reading arithmetic depth from isogeny graphs.

### 5. Verified algorithm / computational method
Implement the depth-prediction method and prove its correctness in the idealized model.

### 6. `demo.py`
Provide an interactive Python demo that:
- constructs sample volcano-like graphs,
- computes cycle-rank / first-cycle-radius statistics,
- predicts depths,
- visualizes the local neighborhoods and classifier output,
- allows the user to vary crater size, branching, and depth.

If feasible, include a mode simulating noisy or exceptional vertices to test robustness.

---

## Concrete Success Criteria

A strong submission will include:

- a new `LayeredVolcano` abstraction,
- a formal cycle-rank or persistence surrogate,
- a theorem that first cycle birth equals volcano depth,
- a crater/floor classification theorem,
- a cross-domain Euler characteristic or Morse-theoretic bridge,
- a verified depth-classification algorithm,
- a falsifiable asymptotic conjecture and a computational test harness.

Do not retreat to toy statements. Prove the mechanism that makes the original arithmetic conjecture plausible. The goal is to build the first rigorous topological depth detector for volcano graphs, so that future work can attach it to actual \(\ell\)-isogeny graphs of ordinary elliptic curves over finite fields.

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

Research domain: Speculative
Research mode: prove
