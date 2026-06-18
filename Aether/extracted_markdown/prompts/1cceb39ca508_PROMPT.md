## Assignment: 5. Undecidability Thresholds in Min-Plus Proof Search

**Mode:** prove

Prove a genuinely new theorem that isolates an **explicit undecidability threshold** for min-plus arithmetic, not merely another incompleteness schema. The target is to formalize a fragment where satisfiability or validity of tropical sentences becomes as hard as a known undecidable problem via a precise interpretation theorem.

### Research Direction

Our current verified results already show that finite tropical proof systems with diagonal expressivity are incomplete. That is the foothill. The mountain is sharper:

> identify the smallest natural enrichment of min-plus arithmetic where one can uniformly encode discrete computation and thereby force undecidability.

The breakthrough is not “some tropical system is undecidable.” The breakthrough is a **threshold theorem**:
- below the threshold: decidable or at least plausibly tame;
- at/above the threshold: undecidable by a clean reduction from a classical source such as two-counter machines, Post correspondence, or Hilbert’s tenth problem.

This would open a new field: **tropical logic and computability thresholds**, connecting tropical geometry, semiring model theory, automata, and proof complexity.

### Precise Theorem Target

You should define a concrete syntactic fragment of min-plus arithmetic and prove undecidability for it. The cleanest target is existential satisfiability over integer-valued tropical terms with `min`, `+`, constants, and equality/inequality constraints.

A promising formal target is:

```lean
/-- Tropical terms built from variables, integer constants, binary min, and addition. -/
inductive TropTerm
| var   : ℕ → TropTerm
| const : ℤ → TropTerm
| add   : TropTerm → TropTerm → TropTerm
| min   : TropTerm → TropTerm → TropTerm

/-- Atomic formulas in the min-plus language. -/
inductive TropAtom
| eq : TropTerm → TropTerm → TropAtom
| le : TropTerm → TropTerm → TropAtom

/-- Existential conjunctions of tropical atoms. -/
structure TropExistsCNF where
  numVars : ℕ
  atoms   : List TropAtom

/-- Semantics over integer valuations. -/
def TropValuation := ℕ → ℤ

def TropTerm.eval : TropValuation → TropTerm → ℤ := ...
def TropAtom.Holds : TropValuation → TropAtom → Prop := ...
def TropExistsCNF.Satisfiable (φ : TropExistsCNF) : Prop := ...
```

Then aim for a theorem of the following form:

```lean
/--
Existential satisfiability for conjunctions of min-plus polynomial equations and inequalities
over ℤ is undecidable, via many-one reduction from the halting problem for 2-counter machines.
-/
theorem tropical_exists_sat_undecidable :
  ∃ encode : TwoCounterMachine → TropExistsCNF,
    (∀ M, Halts M ↔ (encode M).Satisfiable) ∧
    ¬ DecidablePred TropExistsCNF.Satisfiable
```

If `¬ DecidablePred TropExistsCNF.Satisfiable` is awkward in the current environment, an equivalent and often Lean-friendlier formulation is:

```lean
theorem tropical_exists_sat_undecidable :
  ∃ encode : TwoCounterMachine → TropExistsCNF,
    ∀ M, Halts M ↔ (encode M).Satisfiable
```

together with a separate corollary:

```lean
theorem tropical_exists_sat_not_decidable :
  ¬ ∃ dec : TropExistsCNF → Bool, ∀ φ, dec φ = true ↔ φ.Satisfiable
```

### Sharper Threshold Version

If you can push farther, the field-opening statement is a **threshold pair**:

```lean
theorem tropical_threshold_theorem :
  (DecidablePred TropPureEqSat) ∧
  (¬ DecidablePred TropExistsCnfSat)
```

where:
- `TropPureEqSat` is a weaker fragment, e.g. conjunctions of equations between affine tropical terms or purely linear min-plus constraints;
- `TropExistsCnfSat` allows enough mixed equality/inequality structure to simulate machine transitions.

Even if the decidable side is not completed, a formal undecidability theorem for one explicit fragment is already a major result.

### Why This Is a Breakthrough

This would be one of the first formally verified theorems locating a **computability phase transition inside tropical arithmetic**. It transforms tropical mathematics from a geometric/combinatorial toolkit into a setting where one can study:
- proof-search hardness,
- definability hierarchies,
- tropical analogues of Diophantine undecidability,
- semiring-based logic,
- complexity barriers for automated reasoning in idempotent algebra.

It would also create a new conceptual bridge:
**tropical geometry + computability theory + formal proof complexity**.

### How to Build on Existing Catalog Theorems

The listed catalog theorems are not themselves undecidability results, but they provide algebraic normalization and semantic control that can be repurposed.

1. `tropical_plus_distributes_over_min`
   - File: `Tropical/TropicalTypeTheory.lean`
   - Use this as a core rewriting lemma in the semantics of tropical terms.
   - It should help normalize machine-encoding constraints into a canonical min-plus form, reducing proof burden in equivalence lemmas for the reduction.

2. `tropical_eigenpair_from_diagonal`
   - File: `Tropical/MinPlusAlgebra.lean`
   - Conceptually, this is evidence that diagonal structure already carries substantial expressive power.
   - Use this as motivation for isolating “diagonal + guarded inequalities” as the likely threshold where static algebra becomes dynamic computation.
   - If the theorem exposes reusable lemmas about min-plus matrices or fixed points, they may help encode one-step transition consistency.

3. `tropical_fundamental_theorem_of_arithmetic`
   - File: `Tropical/Core/TropicalFactoring.lean`
   - Any available factorization or decomposition lemmas may help prove that your encoding is robust under syntactic normalization.
   - This matters if the machine simulation requires expressing disjunction-like behavior through min-decompositions.

4. `tropical_mirror_theorem`
   - File: `Tropical/AlgebraicMirror.lean`
   - Trivial as stated, but use the max/min idempotence pattern to simplify duplicated branches in the encoding.
   - Often these tiny simp lemmas dramatically reduce proof friction in semantic equivalence proofs.

5. `tropical_residue_does_not_force_twin_pairs`
   - File: `Tropical/SieveEnergetics.lean`
   - This theorem suggests a verified pattern of “non-forcing” phenomena.
   - Methodologically, mirror that style when proving that weaker fragments do **not** suffice for full computation, if you pursue the threshold theorem.

### Most Promising Mathematical Encoding

The key design choice is the undecidable source problem. Three candidates:

#### Option A: Two-counter machines
This is the most promising.

A two-counter machine has:
- a finite list of instructions,
- counters `C₁, C₂ : ℕ`,
- increment, decrement-and-branch, halt.

Why it is best:
- It gives a clean finite-step local semantics.
- Configurations are discrete and sparse.
- The reduction can encode an entire run as existentially quantified time-indexed variables.
- Lean formalization is manageable if you define bounded prefixes and a consistency schema.

The tropical challenge is to express:
- time slices,
- control-state exclusivity,
- counter updates,
- zero-test branching.

This can be done by encoding Boolean/discrete choices via min-equalities and guarded inequalities.

#### Option B: Post Correspondence Problem
Potentially elegant, but less structurally aligned.

PCP is naturally combinatorial, and tropical terms do not obviously represent word concatenation. You would likely need a Gödel-style arithmetic encoding first, which complicates the formal reduction.

#### Option C: Hilbert’s tenth problem
Conceptually grand, especially if one can show tropical existential arithmetic interprets classical Diophantine arithmetic.

But this is probably too ambitious for a first formal breakthrough unless there is already substantial support for polynomial Diophantine encodings in the environment.

**Recommendation:** start with **two-counter machines**.

### Proof Strategy A: Direct Simulation of Two-Counter Machines

1. **Define a bounded-run satisfiability schema**
   - Introduce variables:
     - `pc_t` for program counter at time `t`,
     - `x_t, y_t` for counters,
     - optional selector variables for branch choices.
   - Define tropical constraints expressing:
     - initial configuration,
     - local transition legality,
     - halting at some step.

2. **Express exclusivity and zero-tests tropically**
   - Use min-plus equalities/inequalities to force variables into discrete patterns.
   - For example, tropical equalities can enforce “the minimum is attained exactly here” or “these affine forms coincide,” which acts like a branch condition.
   - Build a library of gadgets: one-hot state gadget, successor gadget, zero/nonzero separation gadget.

3. **Prove soundness and completeness of the encoding**
   - `Halts M → satisfiable (encode M)` by constructing a valuation from a halting run.
   - `satisfiable (encode M) → Halts M` by decoding any satisfying valuation into a valid run and proving the constraints exclude spurious behaviors.

This is the most direct route to the theorem.

### Proof Strategy B: Interpret Presburger-with-Multiplication Fragments Inside Tropical Arithmetic

1. Show tropical existential formulas can define:
   - piecewise-linear equalities,
   - guarded affine transitions,
   - finite control and successor structure.

2. Use those definability results to interpret a known undecidable arithmetic theory.

3. Transfer undecidability by interpretability.

This would be more conceptually powerful, because it yields a **general interpretation theorem** rather than a single reduction. But it is heavier and less likely to close first.

### Proof Strategy C: Matrix Dynamics / Min-Plus Linear Systems

1. Encode machine configurations as basis-like tropical vectors.
2. Encode transition relations by min-plus matrices or a finite family of matrices.
3. Reduce halting to reachability or existence of a trajectory satisfying a tropical fixed-point/inequality system.

This is attractive because it ties directly to tropical linear algebra and could leverage `tropical_eigenpair_from_diagonal`. It may produce the most beautiful mathematics. But proving exact machine simulation through matrix dynamics may be technically harder than Strategy A.

**Best path:** Strategy A first.  
**Most revolutionary follow-up:** Strategy C.

### Concrete Intermediate Lemmas to Target

These are the real scaffolding the final theorem will need.

```lean
theorem trop_term_eval_add (v : TropValuation) (s t : TropTerm) :
  TropTerm.eval v (TropTerm.add s t) = TropTerm.eval v s + TropTerm.eval v t := ...

theorem trop_term_eval_min (v : TropValuation) (s t : TropTerm) :
  TropTerm.eval v (TropTerm.min s t) = min (TropTerm.eval v s) (TropTerm.eval v t) := ...

theorem tropical_state_gadget_sound
  (pc : ℕ → ℤ) (k t : ℕ) :
  StateGadget pc k t →
  ∃! i : Fin k, pc t = i.val := ...

theorem tropical_counter_step_sound
  (x : ℕ → ℤ) (t : ℕ) :
  CounterStepGadget x t →
  x (t+1) = x t ∨ x (t+1) = x t + 1 ∨ x (t+1) + 1 = x t := ...

theorem encode_machine_sound (M : TwoCounterMachine) :
  Halts M → (encode M).Satisfiable := ...

theorem encode_machine_complete (M : TwoCounterMachine) :
  (encode M).Satisfiable → Halts M := ...
```

Even if the exact gadget statements change, this level of granularity is what will let the final theorem become routine rather than mystical.

### Cross-Domain Connections You Should Exploit

1. **Tropical geometry ↔ computability theory**
   - Tropical hypersurfaces become computation traces.
   - Satisfying valuations become machine runs.
   - The “corner locus” perspective may help interpret branching behavior.

2. **Semiring logic ↔ proof complexity**
   - This theorem would imply that proof search in sufficiently expressive min-plus systems cannot be algorithmically complete.
   - It reframes tropical deduction as a computationally universal reasoning medium.

3. **Automata theory ↔ tropical linear algebra**
   - Weighted automata over min-plus semirings are already natural.
   - Your reduction may reveal that existential tropical satisfiability is a static shadow of dynamic weighted automaton reachability.

4. **Idempotent analysis ↔ formal verification**
   - Once undecidability is isolated, one can classify decidable subfragments useful for certified optimization and control.
   - This has direct implications for theorem provers reasoning about shortest paths, scheduling, and discrete-event systems.

5. **Diophantine definability ↔ tropical algebra**
   - If this line succeeds, the next frontier is a tropical analogue of Matiyasevich-style representability phenomena.

### Lean 4 Formalization Advice

- Keep syntax first-order and finite.
- Separate:
  1. syntax,
  2. semantics,
  3. machine model,
  4. encoding,
  5. reduction theorem.
- Avoid overcommitting to a fully general logic framework if a bespoke existential-conjunctive fragment suffices.
- If `TwoCounterMachine` is not already in Mathlib, define a compact machine model yourself.
- Use `List`-based formulas before abstracting to sets or inductive logic; it will simplify satisfiability definitions.
- Build many `[simp]` lemmas for `TropTerm.eval`.
- If full undecidability infrastructure is unavailable, prove a reduction equivalence theorem first. That theorem alone is mathematically valuable and can later be connected to standard undecidability APIs.

### Stretch Theorem: The True Threshold Statement

If the core reduction lands, push to:

```lean
theorem tropical_min_plus_threshold :
  DecidablePred WeakTropFragment.Satisfiable ∧
  ¬ DecidablePred StrongTropFragment.Satisfiable
```

where `WeakTropFragment` excludes the exact gadget enabling zero-test branching, and `StrongTropFragment` includes it. This would be the genuine “undecidability threshold” theorem rather than a bare undecidability result.

### Revolutionary Significance

If completed, this project would establish:
- the first formal **computability barrier theorem** for tropical arithmetic proof search,
- a new theory of **tropical interpretability**,
- a roadmap for classifying decidable/undecidable semiring logics,
- foundations for complexity lower bounds in tropical automated reasoning.

It would enable follow-on work in:
- tropical model theory,
- certified lower bounds for proof systems,
- weighted automata verification,
- static analysis of min-plus control systems,
- logical foundations of idempotent mathematics.

### Application Keywords

`tropical arithmetic`, `min-plus semiring`, `undecidability`, `two-counter machines`, `proof complexity`, `semiring logic`, `tropical model theory`, `weighted automata`, `idempotent analysis`, `formal verification`, `Lean 4`, `Mathlib`, `computability threshold`, `existential satisfiability`, `machine encoding`

### Deliverables

1. A Lean file implementing the syntax/semantics of the target tropical fragment.
2. A machine model and encoding function.
3. Soundness and completeness lemmas for the reduction.
4. The main undecidability theorem in precise formal form.
5. If possible, a companion theorem identifying a weaker decidable fragment.

### Required Final Artifact

You must also produce a structured `FUTURE_DIRECTIONS.md` containing **3–5 concrete, specific, breakthrough-level next steps**, such as:
- a tropical Matiyasevich program,
- decidability classification for one-variable or convex-only fragments,
- matrix-reachability formulations of tropical halting,
- complexity-theoretic completeness results for bounded tropical satisfiability,
- interpretability of weighted automata theories in tropical arithmetic.

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
