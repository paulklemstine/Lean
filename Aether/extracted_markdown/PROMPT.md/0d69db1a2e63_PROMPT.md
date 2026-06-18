## Assignment: Vision

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

### Mode
**prove**

### Research Direction
Build the first formal tropical theory of **four-part SATB chorale optimization**: encode soprano–alto–tenor–bass harmonization as a **layered min-plus hypergraph dynamic program** in which
- vertices are chord positions,
- states are admissible SATB 4-tuples,
- vertical harmony constraints are tropical penalties on 4-tuples,
- horizontal voice-leading costs are tropical transition weights between consecutive 4-tuples.

The breakthrough target is not “yet another music formalization,” but a theorem showing that **global optimal chorale realization is exactly a tropical shortest-path / Bellman principle on a 4-uniform constraint hypergraph**. This opens a new formal bridge between tropical algebra, combinatorial optimization, computational music theory, and weighted logic.

### Mathematical Framing
Let `V := Fin 4 → ℤ` represent an SATB voicing as four integer pitches.  
Let
- `vert : V → ℝ` be a vertical penalty,
- `lead : V → V → ℝ` be a voice-leading penalty,
- `mel : ℕ → V → Prop` encode positionwise admissibility against a fixed harmonic/melodic scaffold.

For a finite horizon `N : ℕ`, define the cost of a realization `x : Fin (N+1) → V` by
\[
\mathrm{Cost}(x)
=
\sum_{i=0}^{N} \mathrm{vert}(x_i)
\;+\;
\sum_{i=0}^{N-1} \mathrm{lead}(x_i,x_{i+1}),
\]
subject to admissibility `mel i (x i)` for all `i`.

Define the tropical value function
\[
J_n(v)
=
\inf \{ \mathrm{futureCost}(x) \mid x_0=v,\ \text{admissible tail of length } n \}.
\]
The central theorem should show a Bellman recursion:
\[
J_{n+1}(v)=\mathrm{vert}(v)+\inf_{w \text{ admissible next}} \big(\mathrm{lead}(v,w)+J_n(w)\big).
\]

This is the SATB analogue of shortest path, but in a **hypergraph state space of polyphonic objects** rather than scalar notes.

---

## Precise Theorem Targets

### Target Theorem A: Tropical Bellman recursion for SATB
Formalize a finite-horizon dynamic programming principle for 4-voice harmonization.

A promising Lean 4 type signature:

```lean
def Voice := Fin 4 → Int

def Realization (N : ℕ) := Fin (N + 1) → Voice

def pathCost
    (N : ℕ)
    (vert : Voice → ℝ)
    (lead : Voice → Voice → ℝ)
    (x : Realization N) : ℝ :=
  (∑ i : Fin (N + 1), vert (x i)) +
  (∑ i : Fin N, lead (x (Fin.castSucc i)) (x i.succ))

def admissible
    (N : ℕ)
    (allow : Fin (N + 1) → Voice → Prop)
    (x : Realization N) : Prop :=
  ∀ i, allow i (x i)

def tailValue
    (allow : ∀ n, Fin (n + 1) → Voice → Prop)
    (vert : Voice → ℝ)
    (lead : Voice → Voice → ℝ)
    : ℕ → Voice → ℝ
| 0, v => vert v
| n + 1, v =>
    vert v + sInf {r | ∃ w : Voice,
      allow (n+1) ⟨1, Nat.succ_lt_succ (Nat.succ_pos _)⟩ w ∧
      r = lead v w + tailValue allow vert lead n w}
```

A cleaner theorem statement, likely easier to prove after finite-state restriction:

```lean
theorem satb_bellman_recursion
  (S : Finset Voice)
  (allow : ℕ → Voice → Prop)
  (vert : Voice → ℝ)
  (lead : Voice → Voice → ℝ)
  (hS : ∀ n v, allow n v → v ∈ S) :
  ∀ n v,
    allow 0 v →
    valueFn S allow vert lead (n+1) v
      = vert v + (S.inf' (nonempty_admissible_next S allow (n+1) v)
          (fun w => lead v w + valueFn S (shiftAllow allow) vert lead n w))
```

If `Finset.inf'` over `ℝ` is awkward, switch to `WithTop ℝ` or assume finite nonempty admissible sets and use `Finset.min'` on a transported finite set.

### Target Theorem B: Optimal substructure / principle of optimality
Show that any globally optimal SATB realization has optimal suffixes.

```lean
theorem satb_optimal_suffix
  (S : Finset Voice)
  (allow : Fin (N + 1) → Voice → Prop)
  (vert : Voice → ℝ)
  (lead : Voice → Voice → ℝ)
  (x : Realization N)
  (hxadm : admissible N allow x)
  (hopt : ∀ y, admissible N allow y → pathCost N vert lead x ≤ pathCost N vert lead y) :
  ∀ k : Fin (N + 1),
    isOptimalSuffix S allow vert lead x k
```

This theorem is conceptually decisive: it certifies that chorale writing is not merely representable by tropical cost accumulation, but **structurally governed** by tropical optimality.

### Target Theorem C: Separable vertical penalties decompose into tropical conjunctions
Use the existing catalog around tropicalized Boolean conjunction to show that if vertical constraints decompose by pairwise or local predicates, then the full SATB penalty is a tropical max/sum aggregation.

For example, define penalties for
- voice ordering `B ≤ T ≤ A ≤ S`,
- spacing bounds,
- forbidden doublings,
- hidden/parallel intervals.

Then prove a decomposition theorem of the form:

```lean
theorem satb_vertical_penalty_decomposes
  (p₁ p₂ p₃ p₄ : Voice → ℝ) :
  satbVerticalPenalty (fun v => max (p₁ v) (max (p₂ v) (max (p₃ v) (p₄ v))))
  = fun v => max (p₁ v) (max (p₂ v) (max (p₃ v) (p₄ v)))
```

More substantively, prove a theorem connecting Boolean SATB legality and tropical penalty zero-sets:

```lean
theorem satb_legality_zero_penalty
  (pen : Voice → ℝ)
  (legal : Voice → Prop)
  (hpen : ∀ v, pen v = 0 ↔ legal v) :
  {v | pen v = 0} = legal
```

Then explicitly build `pen` from tropical conjunction machinery inspired by:
- `bool_and_as_tropical_max`
- `tropical_and_bound`
- `tropical_and_distributes`

This creates a verified dictionary between symbolic rule systems and tropical optimization.

---

## Why this is a breakthrough
A fully formal SATB Bellman theorem would establish that classical harmony can be treated as a **certified min-plus control problem on structured musical states**. This is bigger than algorithmic composition:

1. It creates a new formal domain for **tropical dynamic programming on hypergraph-valued states**.
2. It turns pedagogical music rules into **weighted logical constraints** amenable to theorem proving.
3. It opens a route to **certified AI music generation** where optimality and rule satisfaction are machine-checked.
4. It suggests a general paradigm for multi-agent planning, where “voices” are interacting agents and vertical harmony is a synchronization constraint.

This is exactly the kind of cross-pollination that can open a field.

---

## How to build on the catalog theorems
The current catalog is sparse and slightly indirect, but still usable as conceptual infrastructure:

1. **`bool_and_as_tropical_max`**  
   Use this as the seed for translating conjunctions of SATB legality predicates into tropical aggregations. If `legal := c₁ ∧ c₂ ∧ c₃ ∧ c₄`, encode violations by nonnegative penalties and aggregate with `max` to represent conjunction.

2. **`tropical_and_bound`**  
   Use it to prove lower bounds on composite penalties: if each rule contributes at least a baseline cost when violated, then the combined SATB penalty inherits a certified lower bound. This is useful for “illegal implies positive cost” theorems.

3. **`tropical_and_distributes`**  
   Use distributivity to normalize nested penalty expressions for vertical constraints, especially when combining local interval constraints with global ordering constraints.

4. **`tropical_mirror_theorem`**  
   Use idempotence `max a a = a` to simplify duplicated constraints, which will inevitably appear when encoding overlapping harmony rules.

Do not merely cite these theorems; make them the algebraic engine that compresses symbolic rule systems into tropical cost formulas.

---

## Proof Strategies

### Strategy A: Finite-state dynamic programming via `Finset` minimization
**Most promising.**
1. Restrict admissible SATB voicings to a finite `Finset Voice` determined by vocal ranges and harmonic context.
2. Define the value function recursively using `Finset.inf'` / `min'` over admissible successors.
3. Prove Bellman recursion by unfolding definitions and reindexing the cost decomposition into first-step cost plus suffix cost.

Why this is best: Lean handles finite combinatorics and recursive definitions far more robustly than raw infima over infinite spaces. It also matches practical chorale search.

### Strategy B: Tropical semiring / weighted automaton formulation
1. Encode each time step as a weighted relation on `Voice × Voice`.
2. Interpret the full chorale optimization as tropical matrix multiplication over a finite state set.
3. Prove equivalence between path minimization and iterated tropical product.

Why this matters: it connects SATB writing to automata theory and opens spectral/tropical linear algebra methods. This may produce a stronger theorem after Bellman is established.

### Strategy C: Constraint-logic to tropical penalty correspondence
1. Define Boolean legality predicates for vertical constraints.
2. Construct nonnegative penalties whose zero set equals the legal set.
3. Use tropical conjunction theorems to prove that combined legality corresponds to tropical max aggregation.

Why this matters: it turns rule-based harmony into a formally verified weighted logic. This is the right bridge to SAT/SMT, differentiable optimization, and symbolic AI.

---

## Recommended execution order
1. **Define finite SATB state space**: ranges, ordering, admissibility.
2. **Prove cost decomposition lemma** for concatenating head and tail.
3. **Prove Bellman recursion** on finite horizons.
4. **Prove optimal suffix theorem**.
5. **Prove legality/penalty correspondence** using the catalog’s tropical conjunction results.
6. If time remains, derive a **tropical matrix formulation** of the same optimization problem.

---

## Cross-domain connections
This project should explicitly connect to at least one other domain, preferably two:

### 1. Control theory / dynamic programming
SATB writing becomes a finite-horizon optimal control problem with structured state. The Bellman theorem is literally a control theorem in a musical setting.

### 2. Weighted logic / formal methods
Vertical rules are conjunctions of constraints; tropical penalties turn them into quantitative logic. This suggests certified synthesis of structured symbolic artifacts, not just music.

### 3. Multi-agent systems
The four voices are interacting agents with local motion costs and global coordination penalties. This points toward formal theorems for swarm planning, scheduling, and distributed control.

### 4. Tropical automata / speech and sequence modeling
A chorale is a sequence over a structured state alphabet. The tropical DP machinery is parallel to Viterbi decoding, HMMs, and weighted automata, but now on polyphonic objects.

### 5. Computational neuroscience
Four-voice coordination under soft penalties resembles population coding with synchrony constraints. A theorem here could inspire tropical models of coordinated neural trajectories.

---

## Concrete Lean guidance
Use concrete types:
- `Voice := Fin 4 → Int`
- finite range restrictions via `Finset (Fin 4 → Int)` or tuples of bounded integers
- costs in `ℝ` or `ℤ` first, if easier
- if `ℝ` infimum is painful, start with integer-valued penalties and `Finset.min'`, then lift to `ℝ`

Suggested helper definitions:
- `voiceOrdered : Voice → Prop`
- `withinRange : (Fin 4 → Int × Int) → Voice → Prop`
- `verticalLegal : Voice → Prop`
- `transitionLegal : Voice → Voice → Prop`
- `verticalPenalty : Voice → ℝ`
- `leadingPenalty : Voice → Voice → ℝ`

Suggested helper lemmas:
- `pathCost_succ_decompose`
- `admissible_tail_of_admissible`
- `optimal_tail_of_optimal_path`
- `zero_penalty_iff_legal`
- `combined_penalty_nonneg`

A practical move is to define `Voice` alternatively as `Fin 4 → ℤ` for interval arithmetic, then cast to `ℝ` for penalties.

---

## High-value theorem statement to aim for first
If you need one flagship theorem, make it this:

```lean
theorem satb_dynamic_programming
  (S : Finset Voice)
  (vert : Voice → ℤ)
  (lead : Voice → Voice → ℤ)
  (allow : ℕ → Voice → Prop)
  (hfinite : ∀ n v, allow n v → v ∈ S)
  (hnonempty : ∀ n, ∃ v, allow n v) :
  ∀ n v, allow 0 v →
    valueFn S allow vert lead (n+1) v
      = vert v + ((S.filter (allow 1)).min' (nonempty_filter.mpr (hnonempty 1))
          (fun w => lead v w + valueFn S (shiftAllow allow) vert lead n w))
```

Even if the exact API changes, this is the right formal shape: a finite-state Bellman recursion for SATB.

---

## Revolutionary significance
If you prove this cleanly in Lean, you will have created a certified theory in which polyphonic harmony is:
- a tropical optimization problem,
- a weighted logical system,
- a dynamic program on structured states,
- and a prototype for formal synthesis of multi-component artifacts.

That is not a niche result. It is a blueprint for **machine-checked creative mathematics** and a new bridge between theorem proving and the arts.

---

## Application keywords
tropical algebra, min-plus dynamic programming, SATB harmonization, chorale optimization, weighted automata, Bellman recursion, hypergraph optimization, formal music theory, quantitative logic, certified synthesis, multi-agent coordination, symbolic AI, optimal control, Viterbi decoding, tropical semiring

---

## Deliverables
1. Lean 4 file(s) with the main definitions and at least one flagship theorem fully proved.
2. Minimal `sorry` usage; isolate any unavoidable gaps behind clearly named helper lemmas.
3. A `FUTURE_DIRECTIONS.md` containing **3–5 concrete breakthrough next steps**, each with:
   - a precise theorem statement,
   - why it matters,
   - a proof strategy,
   - cross-domain implications.

### Required FUTURE_DIRECTIONS.md items
Include at least these candidate directions:
1. **Tropical matrix/automaton equivalence** for SATB DP.
2. **Counterpoint invariants** as conserved quantities or monotone tropical energies.
3. **Probabilistic/tropical bridge**: log-semiring vs min-plus semiring for chorale decoding.
4. **Complexity theorem**: NP-hardness or tractable subclasses of bounded SATB optimization.
5. **Categorical formulation**: SATB transitions as morphisms in a weighted operadic/categorical structure.

Be bold. Do not settle for a toy model if a structural theorem is within reach.

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
