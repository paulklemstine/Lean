## Assignment: Formalize the connection

Prove a genuinely new bridge theorem that turns tropical lower bounds into classical computational lower bounds, and simultaneously build a second bridge between classical spectral expansion and tropical cycle separation. The aim is not to produce an isolated lemma, but a transport principle: a mechanism by which hardness in tropical semiring models migrates into branching-program complexity and spectral graph invariants.

Minimize sorry. Use existing catalog theorems aggressively, especially:
- `tropical_spectral_bound`
- `tropical_and_bound`
- `spectral_tropical_bound`
- `spectral_gap_lower_bound`
- `tropical_classical_bridge`

Produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next-step theorems that could open a new subfield around tropical complexity transfer.

---

## Mode
prove

---

## Primary Research Direction: Tropical Communication Complexity ⇒ Branching Program Lower Bounds

### Vision
Formalize a simulation theorem showing that any deterministic communication protocol with tropical cost lower bound induces a size/depth lower bound for a corresponding branching program computing the same Boolean relation/function. This is the kind of theorem that can become a Rosetta stone between semiring complexity, communication complexity, and automata/program lower bounds.

The breakthrough is not merely “one model simulates another.” The breakthrough is to make tropical cost act as a hardness currency that survives model translation.

---

## Precise Theorem Target

Let `f : α → β → Bool` be a Boolean communication problem on finite input types. Suppose:
1. deterministic protocols for `f` can be represented as finite rooted binary trees,
2. each transcript edge carries a tropical weight,
3. the tropical cost along every accepting computation path is bounded below by a certified communication lower bound `L`,
4. a standard simulation maps each protocol to a read-once or layered branching program `BP` computing the induced unary function on paired inputs.

Then prove that the branching program complexity is bounded below by `L` up to a simulation constant.

### Mathematical statement
A clean formal target is:

> For every finite communication problem `f`, if every deterministic protocol computing `f` has tropical cost at least `L`, and if every branching program for `f` induces such a protocol with simulation overhead at most `C`, then every such branching program has size/depth at least `L / C`.

You may want two versions:
1. a **depth lower bound**
2. a **log-size lower bound** or direct **node-count lower bound**, depending on the simulation formalization.

### Suggested Lean 4 theorem shape
You will likely need to introduce protocol and branching-program structures first, but the target should look morally like:

```lean
theorem tropical_comm_lb_implies_bp_lb
  {α β : Type} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
  (f : α → β → Bool)
  (Protocol : Type) (BP : Type)
  (tropCost : Protocol → ℝ)
  (bpSize : BP → ℕ)
  (protocolComputes : Protocol → Prop)
  (bpComputes : BP → Prop)
  (simulate : BP → Protocol)
  (C : ℝ) (hC : 0 < C)
  (hsim :
    ∀ P : BP, bpComputes P →
      protocolComputes (simulate P) ∧ tropCost (simulate P) ≤ C * (bpSize P : ℝ))
  (hLB :
    ∀ π : Protocol, protocolComputes π → L ≤ tropCost π) :
  ∀ P : BP, bpComputes P → L / C ≤ (bpSize P : ℝ)
```

A more realistic first theorem, easier to land in Lean, is a stripped-down version:

```lean
theorem tropical_comm_lb_implies_bp_depth_lb
  {Protocol BP : Type}
  (tropCost : Protocol → ℝ)
  (bpDepth : BP → ℕ)
  (simulate : BP → Protocol)
  (computesP : Protocol → Prop)
  (computesB : BP → Prop)
  (L C : ℝ)
  (hC : 0 < C)
  (hsim : ∀ B, computesB B → tropCost (simulate B) ≤ C * (bpDepth B : ℝ))
  (hLB  : ∀ π, computesP π → L ≤ tropCost π)
  (hcomp : ∀ B, computesB B → computesP (simulate B)) :
  ∀ B, computesB B → L / C ≤ (bpDepth B : ℝ)
```

This is already nontrivial, reusable, and can serve as the formal transport lemma. After that, instantiate it with a concrete protocol model and a concrete branching-program model.

---

## Secondary Research Direction: Bridge Theorem Between Spectral Gaps and Tropical Cycle Gaps

### Vision
This is the deeper conceptual bridge. Tropical cycle gaps measure combinatorial separation in weighted directed graphs; spectral gaps measure mixing/expansion in linear operators. Prove that under an explicit graph-to-matrix encoding, a positive spectral gap forces a positive tropical cycle gap, or conversely that a small tropical cycle gap obstructs spectral expansion.

This would be revolutionary because it would give a new language for expansion: not just eigenvalues, but min-plus geometry of cycle structure. That opens a route from expander theory to tropical optimization, semiring information theory, and lower bounds for distributed protocols.

---

## Precise Theorem Target

Let `W : Fin n → Fin n → ℝ` be edge weights on a finite directed graph, and let `P` be an associated nonnegative matrix obtained from `W` by a monotone encoding such as
`P i j = exp (-W i j)` or a normalized affine variant whenever needed for formal tractability.

Define:
- a classical spectral gap `γ(P)` for `P`,
- a tropical cycle gap `τ(W)` as the difference between the minimal mean cycle weight and the second-best competing cycle statistic, or another already-formalizable cycle-separation quantity.

Then prove a theorem of the form:

> If `γ(P) ≥ ε > 0`, then `τ(W) ≥ Φ(ε, n, normalization-data)`.

or dually

> If `τ(W) ≤ δ`, then `γ(P) ≤ Ψ(δ, n, normalization-data)`.

The exact `Φ`/`Ψ` can be weak at first. What matters is a formal, non-vacuous monotone inequality.

### Suggested Lean 4 theorem shape
A tractable finite-dimensional bridge target could be:

```lean
theorem spectral_gap_to_tropical_cycle_gap
  {n : ℕ}
  (W : Fin (n+1) → Fin (n+1) → ℝ)
  (gapT gapS : ℝ)
  (hSpec : gapS ≤ spectral_gap_of_weights W)
  (hBridge : tropical_cycle_gap W = gapT)
  (hLower : spectral_to_tropical_transfer gapS ≤ gapT) :
  spectral_to_tropical_transfer gapS ≤ tropical_cycle_gap W
```

If the spectral gap object is not yet formalized, use existing bridge theorems as a certified surrogate:
- derive a tropical bound from `tropical_spectral_bound`,
- combine with `spectral_tropical_bound`,
- isolate a cycle-gap corollary.

A more immediate theorem that is likely Lean-feasible from the current catalog:

```lean
theorem positive_spectral_gap_gives_positive_tropical_gap
  {n : ℕ}
  (A : Fin (n+1) → Fin (n+1) → ℝ)
  (ε : ℝ)
  (hε : 0 < ε)
  (hS : ε ≤ classical_spectral_surrogate A) :
  0 < tropical_cycle_gap_surrogate A
```

where `classical_spectral_surrogate` and `tropical_cycle_gap_surrogate` are explicitly defined in terms already supported by your current files.

---

## How to Build on Existing Catalog Theorems

### 1. `tropical_spectral_bound`
Use this as the main certified inequality converting matrix/weight data into a tropical bound. Do not cite it abstractly; inspect its exact conclusion and make it the engine that produces positivity or a quantitative lower bound on the tropical side.

### 2. `spectral_tropical_bound`
This sounds like the reverse-direction comparison theorem. The key opportunity is to compose it with `tropical_spectral_bound` to create a two-sided sandwich:
- classical spectral quantity
- tropical intermediary
- cycle-gap corollary

If the theorem is stated for small matrices or a specific parametric family `(a b c d : ℝ)`, first extract a robust 2×2 bridge theorem, then generalize to finite `n` through block reduction, induced subgraphs, or local cycle witnesses.

### 3. `tropical_classical_bridge`
This likely provides a generic transfer inequality. Use it to normalize conventions between max-plus/min-plus expressions and ordinary real inequalities. If signs or conventions differ, this theorem may be the key bookkeeping device.

### 4. `spectral_gap_lower_bound`
Even if this theorem lives in a different domain, use it as a source of explicit positive gap instances. It can provide nontrivial families where your bridge theorem yields concrete tropical cycle-gap lower bounds. This is how you avoid proving a purely abstract transfer theorem with no compelling corollaries.

### 5. `tropical_and_bound`
This may supply a product/direct-sum principle. Use it to prove that tropical communication lower bounds tensorize under product problems, which then transport to branching-program lower bounds for composed functions.

---

## Proof Strategy A: Abstract Simulation Transport Lemma
Most promising for the communication-to-BP theorem.

1. **Define a minimal interface** for protocols and branching programs:
   - `computes`
   - `cost` / `depth` / `size`
   - `simulate : BP → Protocol`
   - overhead inequality `tropCost (simulate B) ≤ C * size(B)`

2. **Prove the generic transfer theorem**:
   any lower bound on all protocols transfers to all branching programs by contradiction and order arithmetic.

3. **Instantiate with tropical protocol cost**:
   use your tropical lower bound theorem on protocols, then conclude branching-program lower bounds.

Why this is strongest: it separates the semantic theorem from the model implementation. Aristotle can land a reusable theorem now and refine concrete models later.

---

## Proof Strategy B: Protocol Trees as Weighted Automata
Best for deeper formal content if the abstractions are manageable.

1. Define deterministic communication protocols as finite binary trees with node labels indicating speaker/query and leaf labels giving outputs.
2. Put tropical weights on edges and define path cost as tropical sum.
3. Convert the tree into a layered branching program by merging equal-depth subproblems or by reading transcript states as BP nodes.
4. Show:
   - every BP induces a protocol tree,
   - tropical path cost lower bounds transcript depth,
   - therefore cycle-gap/product lower bounds imply BP lower bounds.

Why this matters: it yields a concrete certified compiler from communication trees to branching programs, not just an abstract transfer lemma.

---

## Proof Strategy C: Spectral-to-Tropical Bridge via Local Cycle Witnesses
Most promising for the spectral-gap direction.

1. Start from a finite weighted graph or matrix `A`.
2. Use `tropical_spectral_bound` and `spectral_tropical_bound` to extract an inequality comparing a spectral surrogate and a tropical extremal quantity.
3. Define tropical cycle gap as a minimum over simple cycles or 2-cycle/3-cycle witnesses first.
4. Prove positivity:
   a positive spectral gap excludes equality among competing tropical cycle means, hence enforces positive cycle separation.

Why this is likely Lean-feasible: simple-cycle or small-cycle surrogates avoid difficult full graph spectral theory while still producing a meaningful bridge theorem.

---

## Recommended Order of Attack

1. **First land the abstract transport theorem**
   `tropical_comm_lb_implies_bp_depth_lb`.
   This is the cleanest theorem and can be fully formalized with modest infrastructure.

2. **Then instantiate it with a simple protocol model**
   finite binary trees, transcript depth, and tropical path cost.

3. **Then prove the spectral-cycle bridge in a surrogate form**
   start with 2×2 or finite witness cycles, then generalize.

4. **Finally derive a direct-sum/product corollary**
   using `tropical_and_bound` or any product theorem already in the catalog.

---

## Breakthrough Corollaries to Aim For

### Corollary 1: Direct-sum branching-program lower bound
If tropical communication lower bounds add under product composition, then branching-program depth lower bounds add as well.

Suggested theorem shape:
```lean
theorem bp_depth_direct_sum_from_tropical
  ...
  : lower_bound (f × g) ≥ lower_bound f + lower_bound g
```

### Corollary 2: Positive spectral gap obstructs tropical degeneracy
A graph family with certified classical spectral gap has uniformly positive tropical cycle gap.

This creates a new tropical notion of expansion.

### Corollary 3: Tropical hardness certificates for explicit functions
Instantiate the communication-to-BP transfer on simple explicit functions like `AND`, disjointness surrogates, or matrix-indexing toy models, using `tropical_and_bound` as the seed case.

---

## Cross-Domain Connections

- **Distributed computing**: transcript depth and tropical path cost become lower bounds on message rounds or communication burden in semiring-valued network models.
- **Database theory**: branching programs model query plans; tropical lower bounds can become lower bounds on adaptive query complexity and provenance compression.
- **Information theory**: tropical costs resemble zero-temperature rate functions; protocol hardness may connect to semiring analogues of rate-distortion and data processing.
- **Spectral graph theory**: cycle-gap positivity offers a min-plus certificate of expansion, potentially useful when eigenvalue computations are unstable or opaque.
- **Automata and verification**: weighted branching programs and protocol trees are natural objects in model checking and cost automata.
- **Optimization and control**: tropical cycle means already govern max-plus linear systems; connecting them to spectral gaps may import expander intuition into discrete event systems.

---

## Application Keywords
tropical communication complexity, branching program lower bounds, protocol simulation, min-plus semiring, max-plus semiring, spectral gap, tropical cycle gap, expander surrogates, direct-sum theorem, weighted automata, distributed lower bounds, query complexity, semiring information theory, cost automata, formal complexity theory

---

## Concrete Deliverables

1. A Lean theorem formalizing the abstract transport principle from tropical protocol lower bounds to branching-program lower bounds.
2. Supporting definitions for a minimal protocol/BP interface, unless compatible structures already exist in Mathlib or local files.
3. At least one instantiated corollary for a concrete function family or toy protocol class.
4. A Lean theorem giving a nontrivial bridge from a spectral-gap surrogate to a tropical cycle-gap surrogate.
5. `FUTURE_DIRECTIONS.md` containing 3–5 specific next theorems, for example:
   - a randomized-protocol tropical transfer theorem,
   - a nondeterministic branching-program version,
   - a tropical data-processing inequality,
   - a tropical expander family theorem,
   - a communication-to-circuit lower-bound transport principle.

---

## Standard of Success

Success is not a vague exploration. Success is one or both of the following:
- a reusable formal transfer theorem that any future lower bound can plug into,
- a first rigorous theorem showing that classical spectral separation forces tropical cycle separation.

Either result would create new infrastructure for a research program, not just close a local lemma.

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
