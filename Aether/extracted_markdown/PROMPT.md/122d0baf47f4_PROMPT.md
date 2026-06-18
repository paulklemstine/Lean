## Assignment: Overview

Prove genuinely new theorems about **transport of orbit structure through semiconjugacies**, pushing beyond eventual periodicity into **cycle-length divisibility, orbit-compression rigidity, and finite-state shadow dynamics**. The goal is not merely to extend `semiconj_iterate_eq` by one lemma, but to turn semiconjugacy into a reusable bridge between **discrete dynamics, finite combinatorics, graph condensation, and cryptographic orbit analysis**.

You should treat the existing results

- `semiconj_iterate_eq`
- `semiconj_eventually_periodic`
- `semiconj_eventually_periodic_of_fintype`

as the seed of a broader theory: **factor maps preserve enough orbit data to force arithmetic constraints on periods and enough combinatorial structure to control collisions**.

Build at least one theorem that would feel at home in a future `Mathlib/Dynamics/Semiconj.lean`.

---

## Research Direction

The decisive next move is to prove that semiconjugacy does not merely preserve “eventual periodicity exists,” but imposes **sharp arithmetic structure** on orbit periods in finite dynamics.

### Primary breakthrough target

Let `f : α → α`, `g : β → β`, `h : α → β` with `Function.Semiconj h f g`, i.e.
`h ∘ f = g ∘ h`.

If `x : α` is periodic for `f` with period `n`, then `h x` is periodic for `g` with period dividing `n`. This is the first real arithmetic theorem in this direction and upgrades orbit transport from qualitative to quantitative.

This opens a path toward:
- factor dynamics on finite state spaces,
- quotienting state-transition systems,
- cryptographic orbit compression bounds,
- graph-theoretic condensation of deterministic automata,
- symbolic dynamics and finite-state abstractions.

---

## Precise Theorem Statements

### Theorem 1: periodic points descend with divisibility of periods

A mathematically strong and Lean-realistic formulation is:

```lean
theorem Function.Semiconj.periodicPts_image_subset_periodicPts
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hf : Function.Semiconj h f g) :
    Set.MapsTo h (Function.periodicPts f n) (Function.periodicPts g n)
```

for each `n : ℕ`.

This is the entry theorem: if `f^[n] x = x`, then `g^[n] (h x) = h x`.

A stronger arithmetic consequence should then be extracted.

### Theorem 2: minimal periods descend by divisibility

You may need to define a minimal-period predicate if Mathlib lacks the exact API you want. A robust theorem statement is:

```lean
theorem Function.Semiconj.minimalPeriod_dvd
    {α β : Type*} [Finite β]
    {f : α → α} {g : β → β} {h : α → β} (hf : Function.Semiconj h f g)
    {x : α} {n : ℕ}
    (hx : Function.IsPeriodicPt f n x) :
    ∃ m ∣ n, Function.IsPeriodicPt g m (h x)
```

This theorem is weaker than a statement about the exact minimal period, but already breakthrough-level and highly formalizable.

If you can identify or define a notion `minimalPeriod`, aim for the sharper theorem:

```lean
theorem Function.Semiconj.minimalPeriod_image_dvd
    {α β : Type*} [Finite β]
    {f : α → α} {g : β → β} {h : α → β} (hf : Function.Semiconj h f g)
    {x : α}
    (hx : Function.EventuallyPeriodicPt f x) :
    Function.minimalPeriod g (h x) ∣ Function.minimalPeriod f x
```

This may require substantial infrastructure; if exact minimal period is too costly, prove the existential divisibility theorem above and document the sharper conjecture in `FUTURE_DIRECTIONS.md`.

### Theorem 3: injective semiconjugacy reflects periodicity

This is the rigidity theorem: if the factor map forgets no information, periodicity is not just preserved but reflected.

```lean
theorem Function.Semiconj.eventuallyPeriodic_iff_of_injective
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hf : Function.Semiconj h f g) (hh : Function.Injective h) (x : α) :
    Function.EventuallyPeriodicPt g (h x) ↔ Function.EventuallyPeriodicPt f x
```

A periodic version is even cleaner:

```lean
theorem Function.Semiconj.isPeriodicPt_iff_of_injective
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hf : Function.Semiconj h f g) (hh : Function.Injective h) {x : α} {n : ℕ} :
    Function.IsPeriodicPt g n (h x) ↔ Function.IsPeriodicPt f n x
```

This is conceptually important: semiconjugacies can collapse cycles, but injective semiconjugacies cannot.

### Theorem 4: finite-state orbit collision after semiconjugate compression

Exploit finite codomain and existing orbit-collision ideas. A concrete theorem:

```lean
theorem Function.Semiconj.exists_iterate_image_eq_of_finite
    {α β : Type*} [Finite β]
    {f : α → α} {g : β → β} {h : α → β}
    (hf : Function.Semiconj h f g) (x : α) :
    ∃ m n : ℕ, m < n ∧ h ((f^[m]) x) = h ((f^[n]) x)
```

This is easy from finiteness plus semiconjugacy, but it is foundational for orbit compression and can be refined into eventual periodicity of the image orbit. It links naturally to `closure_cryptographic_orbit_collision_bound`.

### Theorem 5: semiconjugacy induces a map on cycle representatives in finite dynamics

On a finite type, every orbit eventually lands in a cycle. The quotient-by-eventual-cycle picture should become explicit. A first theorem could be:

```lean
theorem Function.Semiconj.mapsTo_eventualPeriodicPts
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hf : Function.Semiconj h f g) :
    Set.MapsTo h {x | Function.EventuallyPeriodicPt f x}
      {y | Function.EventuallyPeriodicPt g y}
```

This likely follows immediately from the catalog theorem, but it packages the result in a set-theoretic form suitable for quotient constructions and finite graph interpretations.

---

## Lean 4 Formalization Targets

You should search Mathlib first for existing names around:

- `Function.Semiconj`
- `Function.Semiconj.iterate_right`
- `Function.Semiconj.iterate_left`
- `Function.IsPeriodicPt`
- `Function.EventuallyPeriodicPt`
- `Function.periodicPts`
- iterate notation `f^[n]`

If exact names differ, adapt. The core theorem likely reduces to the iterate transport identity already available through `semiconj_iterate_eq`.

A likely local definition, if needed:

```lean
def Function.IsPeriodicPt (f : α → α) (n : ℕ) (x : α) : Prop :=
  (f^[n]) x = x
```

And eventual periodicity can be used from Mathlib or recreated locally if necessary.

---

## Proof Strategy Architecture

### Strategy A: Iterate transport + direct arithmetic extraction
**Most promising.**

1. Use `semiconj_iterate_eq` to show
   `h ((f^[n]) x) = (g^[n]) (h x)`.
2. If `hx : (f^[n]) x = x`, rewrite to get
   `(g^[n]) (h x) = h x`.
3. Conclude `IsPeriodicPt g n (h x)`.
4. For divisibility/minimal-period style results, combine with finite search over positive witnesses and use `Nat.find` or finite-set minimization to extract a least period dividing `n`.

Why this is strongest:
- It is directly aligned with the catalog theorem.
- It minimizes new infrastructure.
- It yields both pointwise and setwise transport theorems.

### Strategy B: Orbit-as-directed-graph condensation
**Best for cross-domain impact.**

1. View each function `f : α → α` on a finite type as a functional digraph.
2. A semiconjugacy `h` is then a graph homomorphism commuting with successors.
3. Cycles map to cycles; transient trees map into transient trees feeding those cycles.
4. Use graph language to prove collision and eventual periodicity theorems, then translate back into iterates.

Why this matters:
- It connects your theorem to `Bridges/IncrementalDAG.lean` and condensation-level reasoning.
- It suggests quotient dynamics and level-preservation analogues.
- It creates a path to finite automata and symbolic dynamics.

### Strategy C: Finite-pigeonhole extraction of image periodicity
**Good fallback for finite codomain theorems.**

1. Consider the sequence `a_n = h ((f^[n]) x)`.
2. By semiconjugacy, this is exactly the `g`-orbit of `h x`.
3. If `β` is finite, pigeonhole gives `a_m = a_n` with `m < n`.
4. Then derive eventual periodicity of `h x` under `g`.

Why useful:
- This strategy avoids requiring periodicity of `x`.
- It is ideal for proving finite-state orbit-collision statements.
- It interfaces naturally with `closure_cryptographic_orbit_collision_bound`.

---

## How to Build on the Catalog Theorems

### 1. `closure_cryptographic_orbit_collision_bound`
**File:** `Bridges/ClosureLefschetzTrace.lean`

Use this as conceptual scaffolding for finite-state collision theorems. The new semiconjugacy theorems can strengthen the cryptographic interpretation:

- if a complex state update `f` semiconjugates to a compressed observable dynamics `g`,
- then collisions in the compressed orbit are not accidental but structurally forced by finite codomain,
- and eventual periodicity in the observable layer can be certified independently of the full system.

This is a bridge between **discrete dynamics** and **cryptographic state compression**.

### 2. `level_eq_of_pred_eq_and_levels_eq`
**File:** `Bridges/IncrementalDAG.lean`

Interpret eventual periodicity decomposition as a level/cycle decomposition in a functional graph:
- preperiod = level,
- period = cycle.

A semiconjugacy should preserve enough successor structure to induce statements about level collapse and cycle identification. Even if you do not prove a full DAG theorem now, use this perspective to motivate and shape definitions.

### 3. `product_translation_preserves_bounded_hamming_and_tropical`
**File:** `Bridges/CertificateTransfer.lean`

This theorem suggests a meta-principle: **structured transformations preserve certified properties across representations**. Your semiconjugacy results are a dynamical analogue:
- orbit regularity,
- eventual periodicity,
- collision bounds,
- cycle arithmetic

can all be “transported certificates.” This is a conceptual bridge to robust ML and certified abstractions.

### 4. `tropical_profile_complete_for_bounded_architecture_congruence`
**File:** `Bridges/AlgebraMachineLearning/OperadicTropicalization.lean`

This is a powerful cross-domain cue: semiconjugacy can be interpreted as a coarse observable of a more complicated system, much like tropicalization captures leading-order structure. You should explicitly frame the new theorem as a **dynamical tropicalization principle**:
- complex dynamics upstairs,
- compressed but structurally faithful orbit arithmetic downstairs.

Even if the proof does not use tropical methods, the analogy is mathematically fertile and should be documented.

---

## Cross-Domain Connections

### Symbolic dynamics
Semiconjugacy is a standard factor-map notion in symbolic dynamics. Formalizing cycle divisibility under semiconjugacy in Lean creates a foundation for future work on:
- subshifts of finite type,
- finite-state symbolic factors,
- entropy monotonicity candidates.

### Finite automata and verification
A deterministic transition system with abstraction map `h` is exactly a semiconjugate system. Your theorem says:
- liveness-like cyclic behavior in the concrete system descends to the abstraction,
- injective abstractions reflect such behavior.

This is relevant to model checking and abstract interpretation.

### Cryptography
Compressed observations of an internal state machine often behave as factor systems. Orbit-collision and eventual periodicity in the observed stream become mathematically inevitable in finite codomains. This connects directly to collision analysis and pseudorandomness limitations.

### Tropical / operadic ML
A neural or algebraic system may admit a compressed profile map preserving update structure only semiconjugately. Then orbit signatures, periodic attractors, and coarse recurrence are certified at the profile level. This could become a theorem schema for certifiable dynamical abstraction in ML.

### Graph theory
Every finite deterministic dynamical system is a functional digraph: disjoint cycles with rooted in-trees attached. Semiconjugacy becomes a graph morphism preserving successor edges. Your theorems become cycle-image and level-collapse theorems in graph condensation.

---

## Concrete Lean Priorities

1. **First prove**
   `Function.Semiconj.isPeriodicPt_image`
   or equivalent.
2. **Then prove**
   setwise image inclusion for periodic points.
3. **Then prove**
   an existential divisibility theorem for periods.
4. **Then prove**
   injective reflection of periodicity/eventual periodicity.
5. **Then prove**
   a finite-codomain collision/eventual periodicity theorem for image orbits.

This progression gives you a coherent theorem cluster rather than isolated lemmas.

---

## Suggested Lean Skeletons

### Periodicity transport
```lean
theorem Function.Semiconj.isPeriodicPt_image
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hf : Function.Semiconj h f g) {x : α} {n : ℕ}
    (hx : (f^[n]) x = x) :
    (g^[n]) (h x) = h x := by
  simpa [hf.iterate_eq] using congrArg h hx
```

You may need the exact iterate lemma name:
- `hf.iterate_right`
- `hf.iterate_eq`
- or derived from `semiconj_iterate_eq`.

### Injective reflection
```lean
theorem Function.Semiconj.isPeriodicPt_iff_of_injective
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hf : Function.Semiconj h f g) (hh : Function.Injective h)
    {x : α} {n : ℕ} :
    (g^[n]) (h x) = h x ↔ (f^[n]) x = x := by
  constructor
  · intro hg
    apply hh
    simpa [hf.iterate_eq] using hg
  · intro hx
    simpa [hf.iterate_eq] using congrArg h hx
```

Adjust the rewrite direction depending on the actual semiconjugacy iterate lemma.

### Finite collision
```lean
theorem Function.Semiconj.exists_iterate_image_eq_of_finite
    {α β : Type*} [Finite β]
    {f : α → α} {g : β → β} {h : α → β}
    (hf : Function.Semiconj h f g) (x : α) :
    ∃ m n : ℕ, m < n ∧ h ((f^[m]) x) = h ((f^[n]) x) := by
  -- Use finiteness of β on the sequence n ↦ (g^[n]) (h x),
  -- then rewrite via semiconjugacy.
  sorry
```

This theorem is a gateway to a finite-state abstraction theory.

---

## Breakthrough Significance

If you complete this cluster, you will have established a **formal arithmetic theory of factor dynamics** in Lean. That is a real opening, not an incremental patch.

Why this matters:

- It upgrades semiconjugacy from a commuting-diagram definition to a theorem-producing machine.
- It makes finite-state abstractions mathematically certified objects.
- It creates reusable infrastructure for symbolic dynamics, automata, and cryptographic state evolution.
- It prepares the ground for entropy, zeta-function, and Lefschetz-style counting statements on factor systems.
- It interfaces unexpectedly with graph condensation, tropical abstraction, and certified ML representation maps.

This is exactly the kind of theorem cluster that lets later work say:
“By the semiconjugacy arithmetic package, recurrence properties descend to the observable quotient.”

---

## Deliverables

1. Lean 4 file(s) proving as many of the theorem cluster as possible.
2. Minimal use of `sorry`; if one theorem is blocked by API mismatch, isolate the blocker and prove the surrounding infrastructure.
3. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, each with:
   - precise theorem target,
   - likely dependencies,
   - expected significance.

---

## Required FUTURE_DIRECTIONS.md items

Include at least 3 of the following, stated concretely:

1. **Cycle quotient theorem**  
   Define an equivalence relation by eventual coalescence or equal eventual cycle, and prove semiconjugacy descends to the quotient.

2. **Period-counting inequality under finite fibers**  
   For finite `β`, bound the number of distinct image cycles in terms of cycle structure upstairs and fiber cardinalities of `h`.

3. **Entropy-shadow prototype**  
   On finite state spaces, define orbit-growth or periodic-point counting sequences and prove monotonicity under surjective semiconjugacy.

4. **Functional graph condensation theorem**  
   Formalize finite dynamical systems as functional digraphs and prove that semiconjugacy induces a morphism on SCC/cycle decompositions.

5. **Cryptographic observable-period bound**  
   Use `closure_cryptographic_orbit_collision_bound` together with semiconjugacy to prove that observable periods are bounded by internal orbit statistics.

---

## Application Keywords

semiconjugacy, discrete dynamical systems, periodic points, eventual periodicity, minimal period, functional digraphs, graph condensation, symbolic dynamics, finite automata, abstract interpretation, cryptographic orbit collision, state compression, quotient dynamics, tropical abstraction, certified transport, recurrence, cycle decomposition, Lean 4, Mathlib

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

Research domain: Bridges
Research mode: prove
