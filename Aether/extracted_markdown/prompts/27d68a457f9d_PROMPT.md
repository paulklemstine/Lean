## Assignment: Universality proof

**Mode:** `prove`

Prove a genuinely new theorem establishing that a finite library of verified glider-collision gadgets on sufficiently large tori yields **computational universality** for the tropical cellular automaton under study. This should not be a simulation anecdote; it should be a theorem with quantified size bounds, locality/isolation hypotheses, and a compositional semantics for collision-based logic.

The revolutionary target is to turn tropical CA from “it exhibits interesting moving patterns” into a **formal collision-computing substrate**. If you succeed, you open a new field: **tropical collision complexity**, where computation is encoded not by tape symbols or neural weights, but by phase-shifted propagating defects and their tropical interaction laws.

### Precise Theorem Target

You should formalize a theorem of the following shape.

Let:
- `Config m n` be configurations on the `m × n` torus,
- `step : Config m n → Config m n` be the tropical CA update,
- `evolve t x := (step^[t]) x`,
- `Enc` encode finite Boolean circuits into finite multisets of gliders/gates embedded in a torus,
- `EvalCircuit : Circuit → Vector Bool k → Vector Bool ℓ` be the semantic Boolean evaluation,
- `Readout` decode the designated output lanes after bounded runtime.

Assume a finite gate basis has already been certified by local collision lemmas:
- wire propagation,
- fanout/signal duplication or a substitute via reversible encoding,
- a functionally complete gate basis, e.g. `NAND` or `AND + NOT`,
- collision isolation under spatial separation.

Then prove:

> **Universality on sufficiently large tori.**  
> For every finite Boolean circuit `C` with `k` inputs and `ℓ` outputs, there exist bounds `M, N, T : ℕ` and an encoding `Enc C : Vector Bool k → Config M N` such that for every input `v`,
> 1. the torus is large enough that no unintended wraparound collision occurs before time `T`,
> 2. the designated glider-gate network evolves exactly as the intended circuit composition,
> 3. `Readout (evolve T (Enc C v)) = EvalCircuit C v`.

This should be stated in Lean as close as possible to:

```lean
theorem glider_circuit_universality
  (GateLib : Type)
  [Finite GateLib]
  (RealizeGate :
    ∀ g : GateLib, ∃ (wg hg tg : ℕ), RealizesGate g wg hg tg)
  (complete :
    FunctionallyComplete GateLib)
  (isolation :
    ∀ {m n : ℕ} {x y : Config m n} {T : ℕ},
      WellSeparatedUpTo T x y →
      evolve T (compose x y) = compose (evolve T x) (evolve T y))
  :
  ∀ (C : BoolCircuit),
    ∃ (m n T : ℕ) (enc : Fin C.numInputs → Bool → Config m n),
      ∀ (v : Fin C.numInputs → Bool),
        Readout C (evolve T (encodeCircuit C enc v)) = C.eval v
```

If the full `BoolCircuit` abstraction is too heavy initially, prove the finite-arity version first:

```lean
theorem glider_realizes_nand_basis
  (nand_gate : ∃ w h t, RealizesBinaryGate Nand w h t)
  (wire_gate : ∃ w h t, RealizesWire w h t)
  (not_gate  : ∃ w h t, RealizesUnaryGate Not w h t)
  (isolation : CollisionIsolation)
  :
  ∀ (C : NandCircuit),
    ∃ (m n T : ℕ) (φ : Fin C.arity → Bool → Config m n),
      ∀ (input : Fin C.arity → Bool),
        readout (evolve T (compile C φ input)) = C.eval input
```

And if circuit universality is within reach but Turing universality is not yet formalizable, explicitly package the corollary:

```lean
theorem finite_circuit_family_uniformly_realizable :
  ∀ n : ℕ, ∃ (m nT T : ℕ), ∀ (f : Vector Bool n → Bool),
    CircuitSizeBounded f →
    ∃ x : Config m nT, readout (evolve T x) = f
```

### Why this would be a breakthrough

This would be the first rigorous statement that a tropical CA supports **collision-based digital computation** in the same conceptual class as:
- Conway-Life glider logic,
- reaction-diffusion computing,
- billiard-ball computation,
- signal machines and asynchronous geometry-of-computation.

But the tropical setting is fundamentally different: interactions are governed by min-plus / piecewise-linear mechanics rather than Boolean birth-survival rules. That means universality here would not just replicate Life—it would suggest a new bridge between:
- tropical algebra,
- CA dynamics,
- unconventional computation,
- and semiring semantics.

This is precisely the kind of theorem that can generate an entire research program.

### Build directly on catalog theorems

Even though the listed theorems are not yet in the exact CA-universality lane, use them as **formal proof-patterns and algebraic scaffolding**, not merely as citations.

1. **`tropical_hash_collision_via_finite_orbit`**  
   File: `Bridges/ProofSemiringDiagonalization.lean`  
   Use this as a model for extracting global consequences from a finite orbit argument. The universality proof will also need a finite-time bounded orbit analysis: if the gadget computation completes by time `T`, then only a finite causal diamond matters. This is exactly the kind of “compress infinite dynamics into finite certified behavior” move that should be repurposed.

2. **`min_shift_fixed_point`**  
   File: `Tropical/Cryptography/TropicalTrapdoorResearch.lean`  
   This theorem suggests a mechanism for handling phase shifts and stable propagation in a min-plus environment. Reinterpret it as a tool for proving that glider trajectories are preserved under suitable affine/tropical shifts. If gliders are represented by translated local motifs, a shift-invariance lemma will be essential for compiling repeated wires and timing offsets.

3. **`tropical_residual_fixed_point`**  
   File: `Tropical/NeuralNetworks/TropicalViTFormalization.lean`  
   Use its proof architecture to manage residual/local invariants under iteration. Collision gadgets will likely require a statement like “outside the active interaction zone, the configuration evolves as independent residual glider propagation.” This theorem’s style may help isolate a local perturbation from the ambient flow.

4. **`tropical_plus_distributes_over_min`**  
   File: `Tropical/TropicalTypeTheory.lean`  
   This is a basic semiring identity, but in the universality project it can become the algebraic backbone for proving that superposed timing constraints and phase minima compose correctly. If your glider scheduling semantics is encoded tropically, this theorem will appear naturally in delay-composition arguments.

5. **`tropical_and_bound`**  
   File: `Tropical/Oracles/OracleApplicationsFrontier.lean`  
   This can inspire threshold/boundedness lemmas for gate activation. In collision logic, one often needs a statement that two sufficiently strong/close signals guarantee an output event, while separated signals do not. Even if the theorem is not directly reusable, its quantitative style is the right template.

### Core subtheorems Aristotle should prove

You should not attack universality in one jump. Prove the following architecture.

#### 1. Isolation theorem for finite tori
Formalize the precise “large torus behaves like the infinite grid up to time `T`” statement.

```lean
theorem torus_simulates_infinite_grid_up_to_time
  {S : Finset (ℤ × ℤ)} {T : ℕ} :
  ∃ R : ℕ, ∀ {m n : ℕ},
    R + T < m → R + T < n →
    ∀ x,
      support x ⊆ S →
      restrict_torus (evolve_inf T x) = evolve_torus T (embed_torus x)
```

This is the decisive anti-wraparound lemma. Without it, universality on a torus is ambiguous.

#### 2. Composition theorem for separated gadgets
If two gadgets occupy disjoint spacetime cones up to time `T`, their evolutions compose independently.

```lean
theorem separated_gadgets_compose
  {m n T : ℕ} {x y : Config m n} :
  WellSeparatedUpTo T x y →
  evolve T (compose x y) = compose (evolve T x) (evolve T y)
```

This is the theorem that converts local gadget verification into scalable circuit synthesis.

#### 3. Gate realization theorem
For each primitive gate in the basis, prove there is a glider arrangement implementing it.

```lean
theorem nand_realizable :
  ∃ (m n T : ℕ) (xfalse xtrue : Config m n),
    RealizesBinaryGate Nand m n T xfalse xtrue
```

If `NAND` is too hard, prove `NOT` and `AND`, or a dual-rail conservative basis.

#### 4. Compiler correctness theorem
Compile circuit syntax into spatial-temporal glider diagrams.

```lean
theorem compile_correct
  (C : NandCircuit) :
  ∃ (m n T : ℕ),
    ∀ input,
      readout (evolve T (compile C input)) = C.eval input
```

This is the actual universality theorem in finite-circuit form.

### Proof strategy options

#### Strategy A: Local-to-global causal cone synthesis
1. Prove every verified gate has a bounded spacetime interaction region.
2. Prove that if gadget regions are separated by more than the maximal signal speed times runtime, then they do not interfere.
3. Compile any finite circuit into a planar or layered arrangement with spacing exceeding that bound; then use induction on circuit depth.

**Why promising:** This is the most formalization-friendly route. Lean likes bounded local statements, inductive composition, and explicit quantitative inequalities.

#### Strategy B: Intrinsic simulation of a known universal medium
1. Identify a simpler already-understood universal collision system or reversible logic network.
2. Show each primitive signal and collision rule of that system can be emulated by tropical gliders.
3. Transfer universality by an intrinsic simulation theorem.

**Why promising:** Conceptually powerful and cross-domain elegant. If you can simulate a billiard-ball model or a one-dimensional cyclic tag system, the theorem becomes historically resonant. But this route may be heavier in infrastructure.

#### Strategy C: Semiring-categorical semantics of gates
1. Define a category whose objects are signal interfaces and whose morphisms are glider gadgets modulo spacetime equivalence.
2. Show primitive gadgets generate a symmetric monoidal subcategory containing a functionally complete Boolean circuit category.
3. Deduce universality via a faithful monoidal functor from circuits to gadgets.

**Why promising:** This is the most visionary route. It would recast collision computing as a compositional semantics problem. Harder to execute immediately, but if achieved, it would be field-opening.

**Recommendation:** Start with **Strategy A**, but define interfaces and gadget composition in a way that later upgrades naturally to Strategy C.

### Cross-domain connections you should explicitly exploit

- **Tropical geometry:** periodic orbits and collision loci may be describable as tropical varieties or polyhedral complexes in configuration space.
- **Reaction-diffusion computing:** gliders act like mobile localized excitations; collision gates mirror chemical wave logic.
- **Billiard-ball computation / Fredkin-Toffoli:** spatial routing and collision truth tables suggest a conservative computation analogy.
- **Category theory / string diagrams:** circuits as compositional networks, glider gadgets as morphisms with tensor product given by spatial juxtaposition.
- **Dynamical systems:** the anti-wraparound theorem is a finite-speed-of-propagation statement on compact quotients.
- **Semiring complexity:** tropical algebra may permit a quantitative notion of gate delay, energy, or collision cost.
- **Formal verification:** once compiler correctness is proved, one gets machine-checked unconventional computation, not just hand-drawn universality sketches.

### Application keywords

`tropical cellular automata`, `collision-based computing`, `computational universality`, `glider logic`, `finite torus simulation`, `intrinsic simulation`, `formal verification`, `unconventional computation`, `reaction-diffusion logic`, `billiard-ball model`, `semiring dynamics`, `tropical geometry`, `polyhedral dynamics`, `circuit compilation`, `causal cone decomposition`

---

## Direction 4: Periodic Orbit Classification via Tropical Fixed-Point Varieties

**Mode:** `discover` with a strong `prove` component

Do not leave this as a vague hypothesis. Turn it into a theorem relating periodic points of the CA on finite tori to explicitly definable piecewise-linear constraint sets.

### Precise Theorem Target

Let `F_{m,n} : Config m n → Config m n` be the global update map. For fixed `p`, define the period-`p` point set
\[
\mathrm{Per}_p(F_{m,n}) = \{x \mid F_{m,n}^p(x)=x\}.
\]

You should prove a theorem of the form:

> For each fixed `m, n, p`, the set of period-`p` configurations is definable by a finite system of tropical equalities/inequalities induced by the coordinate formulas of `F_{m,n}^p`. Consequently it is a finite polyhedral complex, and under an appropriate tropicalization map it forms a tropical prevariety.

Lean-facing target:

```lean
theorem periodic_points_are_tropical_prevariety
  (m n p : ℕ) :
  ∃ (E : Finset TropicalEquation),
    periodicPoints m n p = {x | SatisfiesAll E x}
```

A stronger geometric version:

```lean
theorem periodic_points_are_polyhedral
  (m n p : ℕ) :
  IsPolyhedralComplex (periodicPoints m n p)
```

And if the CA update is genuinely min-plus definable coordinatewise, aim for:

```lean
theorem periodic_points_definable_by_min_plus_system
  (m n p : ℕ) :
  ∃ (A B : Finset (MinPlusExpr (ConfigVar m n))),
    periodicPoints m n p = {x | evalMinPlusFamily A x = evalMinPlusFamily B x}
```

### Breakthrough significance

If successful, this would create a new bridge between **symbolic dynamics** and **tropical algebraic geometry**. Periodic orbits would stop being combinatorial curiosities and become points on a structured polyhedral object. That opens:
- dimension counting for orbit families,
- stratification by support type,
- entropy bounds via tropical complexity,
- bifurcation analysis through changes in polyhedral type,
- and possibly a tropical zeta function counting periodic points.

This is not “classify another oscillator.” This is the beginning of a geometry of CA phase space.

### Proof strategy options

#### Strategy A: Coordinate elimination from iterated min-plus formulas
1. Prove by induction on `p` that every coordinate of `F^p` is a min-plus expression in the initial coordinates.
2. Rewrite `F^p(x)=x` as a finite family of tropical polynomial equalities/inequalities.
3. Package the solution set as a tropical prevariety/polyhedral complex.

**Most promising** if the update rule is already encoded in a tropical algebraic style.

#### Strategy B: Fixed-point variety via graph constraints
1. Construct the dependency graph for `F^p`.
2. Show periodicity imposes local consistency constraints on each strongly connected component.
3. Convert these to piecewise-linear equalizer conditions.

This may yield cleaner combinatorial control over dimensions and components.

#### Strategy C: Semimodule-theoretic formulation
1. View configurations as points in a tropical semimodule.
2. Interpret `F^p` as a piecewise-linear endomorphism.
3. Study fixed points as equalizers of tropical linear regions and glue over the normal fan.

This is the most geometric and may produce the strongest downstream theory.

### Concrete first theorem beyond still lifes and blinkers

Do not remain at period 1 or 2. Prove a nontrivial finite classification result such as:

```lean
theorem period_three_points_on_small_torus_are_classified
  :
  ∀ x : Config 3 3,
    IsPeriodThree x ↔ x ∈ classifiedPeriodThreeSet
```

or better, a structural theorem:

```lean
theorem period_p_points_decompose_by_support_pattern
  (m n p : ℕ) :
  periodicPoints m n p =
    ⋃ s ∈ supportPatterns m n,
      realizationCell s p
```

where each `realizationCell s p` is polyhedral/tropical.

### Bridge to the universality project

These two directions are not independent. If glider logic is universal, then periodic orbit spaces may encode circuit verification, and conversely if periodic point sets are tropical prevarieties, one may be able to engineer computation as membership in those varieties. This suggests a science-fiction-level program:

- **computation as tropical intersection theory of spacetime defects.**

That phrase should become mathematically real.

### Deliverables

1. A Lean theorem formalizing finite-torus anti-wraparound simulation.
2. A Lean theorem showing separated gadget composition.
3. A Lean theorem realizing at least one functionally complete gate basis.
4. A compiler-correctness theorem for finite Boolean circuits.
5. A Lean theorem expressing period-`p` points as a finite min-plus constraint system.
6. Minimize `sorry`; prioritize lemmas that can be reused across both projects.

### Required final artifact

Produce a `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
- intrinsic simulation of a tag system or reversible lattice gas,
- tropical zeta functions for periodic orbit counting,
- monoidal category of collision gadgets,
- complexity classes for tropical CA circuit depth/size,
- tropical obstruction theory for impossible gate collisions.

Be specific: each next step should contain an exact theorem target, not a vague theme.

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
