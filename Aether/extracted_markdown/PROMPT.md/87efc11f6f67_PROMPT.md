## Assignment: Machine Learning State Compression

Mode: **prove**

Prove a genuinely new bridge theorem turning semiconjugacy of quantized recurrent dynamics into a formal compression principle for periodic memory. The target is not “representation learning works in some vague sense,” but an exact finite-dynamical-systems theorem that can become the seed of a formal theory of symbolic latent dynamics, neural state abstraction, and complexity bounds for learned recurrent systems.

### Core Breakthrough Objective

Let `S` be a finite quantized state space of a recurrent network, `T : S → S` its update rule, `E : S → L` a learned encoder into a smaller latent space, and `U : L → L` a latent update rule such that

\[
E \circ T = U \circ E.
\]

Prove that every periodic orbit in `S` maps to a periodic orbit in `L`, with period dividing the original one, and then go beyond this basic divisibility statement: prove a **fiberwise lifting criterion** showing when a latent periodic orbit certifies existence of a periodic orbit upstairs. This is the mathematically meaningful notion of “state compression preserves attractors.”

This opens a field-level bridge between:
- finite dynamical systems,
- formal verification of recurrent neural networks,
- symbolic abstraction / model reduction,
- circuit complexity of compressed state evolution.

### Precise Theorem Targets

You should define the finite-dynamical notions in Lean using concrete finite types, preferably `Fin n` or a finite type with `[Fintype α] [DecidableEq α]`.

#### Target 1: Period compression under semiconjugacy

Mathematical statement:

For finite types `α`, `β`, maps `f : α → α`, `g : β → β`, and encoder `e : α → β` with semiconjugacy
\[
\forall x,\ e (f x) = g (e x),
\]
if `x` has exact period `n > 0` under `f`, then `e x` is periodic under `g` with some period `m` dividing `n`.

Lean-style target:
```lean
theorem semiconj_periodic_exact_dvd
  {α β : Type} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
  (f : α → α) (g : β → β) (e : α → β)
  (hsemi : Function.Semiconj e f g)
  {x : α} {n : ℕ}
  (hn : 0 < n)
  (hex : Function.IsPeriodicPt f n x)
  (hmin : ∀ m, 0 < m → m < n → ¬ Function.IsPeriodicPt f m x) :
  ∃ m, 0 < m ∧ m ∣ n ∧ Function.IsPeriodicPt g m (e x)
```

If exact minimal-period infrastructure in Mathlib is awkward, first prove the weaker but still valuable theorem:
```lean
theorem semiconj_periodic_dvd
  {α β : Type} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
  (f : α → α) (g : β → β) (e : α → β)
  (hsemi : Function.Semiconj e f g)
  {x : α} {n : ℕ}
  (hn : 0 < n)
  (hper : Function.IsPeriodicPt f n x) :
  Function.IsPeriodicPt g n (e x)
```
and then extract the divisor statement by taking a minimal positive latent period using finiteness / well-ordering on `ℕ`.

#### Target 2: Cycle-count monotonicity under surjective semiconjugacy

This is the stronger, more original theorem.

If `e : α → β` is surjective and semiconjugates `f` to `g`, then every periodic point of `g` has a preimage whose orbit is eventually periodic; under an additional fiber-invariance hypothesis, it lifts to a genuine periodic orbit of `f`.

A practical theorem statement:

```lean
def FiberInvariant
  {α β : Type} (f : α → α) (e : α → β) : Prop :=
  ∀ ⦃x y : α⦄, e x = e y → e (f x) = e (f y)

theorem periodic_lift_of_surjective_semiconj
  {α β : Type} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
  (f : α → α) (g : β → β) (e : α → β)
  (hsemi : Function.Semiconj e f g)
  (hsurj : Function.Surjective e)
  {y : β} {n : ℕ}
  (hn : 0 < n)
  (hper : Function.IsPeriodicPt g n y) :
  ∃ x : α, e x = y ∧ ∃ k, 0 < k ∧ Function.IsPeriodicPt f k x
```

Then seek a sharper exact-lifting theorem under a stronger hypothesis such as injectivity on each periodic fiber or a canonical section:
```lean
theorem periodic_lift_with_divisibility
  ...
  : ∃ x : α, e x = y ∧ ∃ k, 0 < k ∧ k ∣ n ∧ Function.IsPeriodicPt f k x
```

This theorem would be genuinely powerful: latent attractors are not merely images of real attractors; under checkable structural hypotheses they certify actual recurrent memory states upstairs.

#### Target 3: Compression lower bound from orbit complexity

This is the cross-domain theorem that makes the project non-incremental.

Let `P(f)` denote the maximal exact period of a point under `f` on a finite state space. If `e : α → β` semiconjugates `f` to `g`, then the latent space must be large enough to host all image periods. In particular, if `f` has a cycle of length `n` whose image under `e` still has exact period `n`, then `Fintype.card β ≥ n`.

Lean-style theorem:
```lean
theorem latent_card_lower_bound_of_exact_period
  {α β : Type} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
  (f : α → α) (g : β → β) (e : α → β)
  (hsemi : Function.Semiconj e f g)
  {x : α} {n : ℕ}
  (hn : 0 < n)
  (hper : Function.IsPeriodicPt g n (e x))
  (hmin : ∀ m, 0 < m → m < n → ¬ Function.IsPeriodicPt g m (e x)) :
  n ≤ Fintype.card β
```

This is the finite-state analogue of an information bottleneck lower bound: exact recurrent memory of period `n` requires latent capacity at least `n`.

### Why This Is a Breakthrough

This project formalizes a rigorous theorem-schema for **learned dynamical compression**:
- semiconjugacy = certified representation consistency,
- period divisibility = no hallucinated longer memories in latent space,
- lifting = latent attractors correspond to real attractors under structural assumptions,
- cardinality lower bounds = minimal latent dimension/state-count needed to preserve memory.

That is not just another theorem about periodic points. It is the beginning of a mathematically precise theory of:
- recurrent representation learning,
- abstraction-preserving verification,
- finite-state neural compression,
- symbolic latent dynamics as certified quotient systems.

It also creates a bridge to circuit complexity: if compressed dynamics preserve high orbit complexity, then any circuit implementing them must carry corresponding state complexity. This resonates with `depth_lower_bound_from_degree` and `mulGates_lower_bound_from_degree`: the philosophical parallel is that algebraic complexity lower bounds and dynamical memory lower bounds are both obstructions to compression.

### Lean 4 Formalization Guidance

Use concrete definitions if Mathlib’s exact-period API is inconvenient.

Possible helper definitions:
```lean
def IsPeriodicPt {α : Type} (f : α → α) (n : ℕ) (x : α) : Prop :=
  (f^[n]) x = x

def ExactPeriod {α : Type} (f : α → α) (x : α) (n : ℕ) : Prop :=
  0 < n ∧ IsPeriodicPt f n x ∧ ∀ m, 0 < m → m < n → ¬ IsPeriodicPt f m x
```

Then prove:
```lean
theorem semiconj_iterate
  {α β : Type} (f : α → α) (g : β → β) (e : α → β)
  (hsemi : Function.Semiconj e f g) :
  ∀ n, Function.Semiconj e (f^[n]) (g^[n])
```

This lemma should be your engine. It immediately yields image periodicity.

### Proof Strategy Architecture

#### Strategy A: Iterate-first semiconjugacy, then minimal period extraction
Most promising.

1. Prove `e ((f^[n]) x) = (g^[n]) (e x)` by induction on `n`.
2. If `(f^[n]) x = x`, rewrite to get `(g^[n]) (e x) = e x`.
3. Define the set of positive periods of `e x` under `g`, show `n` belongs to it, and choose its least element `m`.
4. Use Euclidean division or standard minimal-period arguments to prove `m ∣ n`.

Why this is promising: it is structurally clean, close to Mathlib’s iteration machinery, and avoids needing sophisticated orbit decomposition.

#### Strategy B: Orbit decomposition via finite cyclic action
More conceptual, useful for stronger results.

1. Define the orbit of `x` as the `Finset`/`Set` of iterates.
2. Show semiconjugacy induces a map from the orbit of `x` onto the orbit of `e x`.
3. If `x` lies on a cycle of length `n`, its orbit carries a transitive `ℤ/nℤ`-action.
4. The image orbit is a quotient cycle, so its size divides `n`.

Why this matters: this is the right route for exact orbit-size theorems, counting results, and later categorical quotient formulations.

#### Strategy C: Finite-state pigeonhole lifting for latent cycles
Best for Target 2.

1. Start from `y` periodic in `β`, choose `x₀` with `e x₀ = y` by surjectivity.
2. Consider the sequence `x₀, f x₀, f^[2] x₀, ...`.
3. Since `α` is finite, some states repeat; derive eventual periodicity.
4. Use semiconjugacy plus periodicity of `y` to force the repeated segment into the fiber over the latent cycle.
5. Under stronger fiber assumptions, convert eventual periodicity to genuine periodicity.

Why it is valuable: it gives a machine-verification theorem for latent attractor certificates.

### Building on Catalog Theorems

The listed catalog theorems are not directly about dynamics, but they suggest a powerful meta-direction: **compression is constrained by complexity**.

- `depth_lower_bound_from_degree` and `mulGates_lower_bound_from_degree` can be used conceptually to motivate a later theorem: if a recurrent update or its unrolled transition polynomial has high algebraic degree, then exact latent simulation by a small algebraic circuit should incur depth/multiplication lower bounds.
- This project can prepare the formal dynamical side of that bridge: first certify what latent semiconjugacy preserves; later connect preserved orbit complexity to algebraic circuit complexity of the encoder/update pair.
- The Pythagorean/factoring theorems are not immediate tools here, so do not force them artificially. The real “build on catalog” move is to align this work with the lower-bound philosophy already present in the repository.

### Cross-Domain Connections

1. **Dynamical systems × machine learning**  
   Semiconjugacy is the exact mathematical form of a representation map preserving temporal structure.

2. **Finite automata × recurrent nets**  
   Quantized RNNs are finite-state machines; periodic attractors are memory loops. Your theorem becomes a minimization principle for learned automata abstractions.

3. **Information theory × latent bottlenecks**  
   `card β ≥ n` for preserving an exact `n`-cycle is a zero-noise memory-capacity lower bound.

4. **Circuit complexity × compressed simulation**  
   If compressed dynamics preserve long exact cycles, implementing them cannot be “too shallow” in algebraic models; this is the future bridge to the degree/depth lower bound catalog.

5. **Formal verification × abstraction refinement**  
   The lifting theorem says when proving safety/liveness on the latent model certifies genuine recurrent behavior in the original network.

### Concrete Deliverables

1. A Lean file defining periodicity/exact periodicity if needed.
2. Proof of `semiconj_iterate`.
3. Proof of `semiconj_periodic_dvd`.
4. Proof of `semiconj_periodic_exact_dvd` via minimal latent period.
5. At least one lifting theorem under surjectivity / fiber assumptions.
6. A cardinality lower bound theorem for exact latent periods.
7. `FUTURE_DIRECTIONS.md` with **3–5 specific breakthrough next steps**.

### Suggested Lean File Structure

- `Dynamics/StateCompression/Periodic.lean`
  - definitions: `IsPeriodicPt`, `ExactPeriod`, `FiberInvariant`
  - theorem: `semiconj_iterate`
  - theorem: `semiconj_periodic_dvd`
  - theorem: `semiconj_periodic_exact_dvd`

- `Dynamics/StateCompression/Lifting.lean`
  - theorem: `periodic_lift_of_surjective_semiconj`
  - stronger variants under extra hypotheses

- `Dynamics/StateCompression/Capacity.lean`
  - theorem: `latent_card_lower_bound_of_exact_period`

### Application Keywords

- certified representation learning
- recurrent neural networks
- quantized dynamics
- finite-state abstraction
- semiconjugacy
- periodic attractors
- symbolic dynamics
- model reduction
- latent capacity lower bounds
- formal verification
- automata minimization
- circuit complexity of memory

### Nontriviality Standard

Do not stop at “periodic points map to periodic points.” That is the warm-up. The real theorem is the divisibility/lifting/capacity triad:
- **divisibility**: compression cannot create longer exact memory,
- **lifting**: latent memory can certify real memory under structure,
- **capacity**: preserving exact memory imposes lower bounds on latent state size.

This is the beginning of a formal science of neural state compression.

### Required Closing Artifact

Produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next problems, for example:
1. eventual-period preservation for non-periodic preperiodic points,
2. entropy-style lower bounds from counts of distinct cycles,
3. categorical quotient dynamics for learned encoders,
4. algebraic-circuit lower bounds for exact latent simulators,
5. verified abstraction-refinement algorithms for quantized RNNs.

Create a team to conduct research, brainstorm hypotheses, run experiments, validate data, update the knowledge base, and iterate forever.

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

Research domain: Algebra
Research mode: prove
