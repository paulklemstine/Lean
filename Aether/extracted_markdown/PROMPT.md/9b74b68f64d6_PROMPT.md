Soli Deo Gloria

## Assignment: Direction 3 — Quantum Circuit Rewriting via Tensor Distributivity

**Mode:** prove

Build a genuinely new bridge between **term rewriting**, **tensor algebra**, and **quantum circuit theory**. Do not merely instantiate existing catalog lemmas mechanically. The goal is to show that distributivity-based tensor rewriting is not just syntactic bookkeeping, but a mathematically robust source of **canonical forms for quantum circuits**.

You should treat the catalog files

- `Catalog/Pythagorean/TensorConfluence.lean`
- `Catalog/Pythagorean/TensorSortedRewrite.lean`

as foundational infrastructure: extract their abstract rewrite architecture, identify exactly which hypotheses are structural and which are semantic, and then specialize them to a quantum model based on complex matrices and state vectors. The breakthrough is to prove that **linearity of quantum mechanics can be reinterpreted as a confluent tensor rewrite principle**, at least in a meaningful 2-qubit fragment.

---

## Central Vision

Quantum circuit optimization is still dominated by local identities and heuristic peephole simplification. What is missing is a mathematically canonical notion of **normal form** that is compatible with the tensorial structure of quantum mechanics itself.

Your task is to formalize and prove the first substantial theorems showing that a **tensor distributivity rewrite system**, instantiated in a 2-qubit setting, yields:

1. **semantic soundness** with respect to matrix/state evaluation,
2. **normalization and/or confluence modulo AC** in a nontrivial fragment,
3. a verified computational procedure for comparing or simplifying circuits.

The deeper conceptual claim is:

> **Quantum parallelism is distributivity.**  
> Superposition and tensorial composition force a rewrite theory whose normal forms encode canonical circuit structure.

If this succeeds, it opens a path toward:
- certified quantum circuit optimization,
- canonical equivalence checking,
- categorical semantics of rewriting for compact/monoidal quantum languages,
- and eventually scalable rewriting for ZX-like or tensor-network calculi.

---

## Precise Theorem Targets

You must prove at least **3 nontrivial theorems**. At least one should connect quantum circuit rewriting to another domain, such as category theory, algebra, or rewriting theory.

### New definitions required

Define at least one genuinely new structure, for example:

- `QuantumTensorExpr` for 2-qubit tensor expressions,
- `QRewriteStep` as a specialized rewrite relation,
- `ParallelACEq` for equivalence modulo commuting disjoint/parallel gates,
- `QuantumNormalForm` as a predicate or structure packaging irreducibility + sortedness + semantic invariance.

You should not simply reuse a catalog structure unchanged; introduce a quantum-specific concept.

---

## Suggested Lean 4 formalization targets

These signatures are indicative targets; refine them as needed to fit Mathlib’s available matrix/complex APIs.

### 1. Soundness of quantum tensor rewriting

Prove that every one-step rewrite preserves denotational semantics.

```lean
theorem qrewrite_sound
  {e₁ e₂ : QuantumTensorExpr}
  (h : QRewriteStep e₁ e₂) :
  denote e₁ = denote e₂
```

If your semantics are state-transformer semantics:

```lean
theorem qrewrite_sound_on_state
  {e₁ e₂ : QuantumTensorExpr} (ψ : QubitState 2)
  (h : QRewriteStep e₁ e₂) :
  denoteOn ψ e₁ = denoteOn ψ e₂
```

This theorem should not be trivial. The proof should use multi-step `calc`, extensionality on vectors/matrices, and explicit use of linearity/distributivity lemmas.

---

### 2. Normalization or confluence modulo AC in a restricted 2-qubit fragment

You likely need a restricted fragment first: e.g. circuits built from
`H`, `T`, `CNOT`, sequential composition, tensor/parallel composition, and formal sums representing superpositions or distributive expansion.

A precise target could be:

```lean
theorem qrewrite_confluent_mod_parallelAC
  {e a b : QuantumTensorExpr}
  (ha : ReflTransGen QRewriteStep e a)
  (hb : ReflTransGen QRewriteStep e b) :
  ∃ c, ReflTransGen QRewriteStep a c ∧
       ReflTransGen QRewriteStep b c ∧
       ParallelACEq c c
```

More realistically, if full confluence is too ambitious, prove **local confluence modulo AC** plus a terminating measure:

```lean
theorem qrewrite_local_confluence_mod_parallelAC
  {e a b : QuantumTensorExpr}
  (ha : QRewriteStep e a)
  (hb : QRewriteStep e b) :
  ∃ c, ReflTransGen QRewriteStep a c ∧ ReflTransGen QRewriteStep b c
```

together with

```lean
theorem qrewrite_terminates :
  WellFounded (fun e₁ e₂ : QuantumTensorExpr => QRewriteStep e₂ e₁)
```

and then derive confluence by Newman-style reasoning if the catalog already contains the needed theorem.

This is likely the most revolutionary theorem in the file. If full AC-modulo confluence is too technically expensive, prove it on a sharply defined fragment where the critical pairs can be classified and discharged rigorously.

---

### 3. Uniqueness of normal form implies deterministic circuit comparison

Prove that normal forms are semantically complete for the chosen fragment:

```lean
theorem normalForm_unique
  {e₁ e₂ n₁ n₂ : QuantumTensorExpr}
  (h₁ : ReflTransGen QRewriteStep e₁ n₁)
  (h₂ : ReflTransGen QRewriteStep e₂ n₂)
  (hn₁ : IsQuantumNormalForm n₁)
  (hn₂ : IsQuantumNormalForm n₂)
  (hsem : denote e₁ = denote e₂) :
  ParallelACEq n₁ n₂
```

A weaker but still powerful variant is:

```lean
theorem same_normalForm_of_rewrite_equiv
  {e₁ e₂ n₁ n₂ : QuantumTensorExpr}
  (hrew : Joinable QRewriteStep e₁ e₂)
  (h₁ : ReflTransGen QRewriteStep e₁ n₁)
  (h₂ : ReflTransGen QRewriteStep e₂ n₂)
  (hn₁ : IsQuantumNormalForm n₁)
  (hn₂ : IsQuantumNormalForm n₂) :
  ParallelACEq n₁ n₂
```

This theorem is the foundation for a verified optimizer/comparator.

---

### 4. Cross-domain theorem: algebra/category theory/physics bridge

You must include at least one theorem whose statement clearly links quantum rewriting to another domain.

A strong option is to show that rewrite equivalence implies equality in a monoidal semantic category:

```lean
theorem rewrite_eq_monoidal_morphism
  {e₁ e₂ : QuantumTensorExpr}
  (h : ReflTransGen QRewriteStep e₁ e₂) :
  MonoidalDenote e₁ = MonoidalDenote e₂
```

Or connect to linear algebra more explicitly:

```lean
theorem distributive_normalization_respects_entanglement_rank
  {e n : QuantumTensorExpr}
  (h : ReflTransGen QRewriteStep e n)
  (hn : IsQuantumNormalForm n) :
  schmidtRank (denote e) = schmidtRank (denote n)
```

This is especially compelling: it says canonical rewriting preserves an intrinsically quantum invariant. That is a real cross-domain bridge between **rewriting systems** and **quantum information theory**.

If Schmidt rank is too heavy for the current cycle, prove preservation of separability for product states under your normalized semantics.

---

## Recommended theorem statement refinement

A particularly promising main theorem is:

> **Theorem (2-qubit distributive normalization):**  
> For every 2-qubit circuit expression `e` generated by the gate set `{H, T, CNOT}` together with sequential composition, parallel composition, and formal superposition nodes, if `e` belongs to the distributive fragment `WellFormedQExpr`, then there exists a normal form `n` such that:
> 1. `e ⟶* n`,
> 2. `n` is irreducible and sorted,
> 3. `denote e = denote n`,
> 4. any two such normal forms are AC-equivalent on parallel factors.

A Lean-shaped version:

```lean
theorem exists_unique_normalForm_mod_parallelAC
  (e : QuantumTensorExpr)
  (hwf : WellFormedQExpr e) :
  ∃ n, ReflTransGen QRewriteStep e n ∧
       IsQuantumNormalForm n ∧
       denote e = denote n ∧
       ∀ n', ReflTransGen QRewriteStep e n' →
         IsQuantumNormalForm n' →
         ParallelACEq n n'
```

This theorem would be a genuine milestone.

---

## Proof architecture: 3 possible strategies

You must describe and exploit multiple proof pathways, not just one.

### Strategy A: Abstract transfer from catalog confluence theorems
1. Identify the exact hypotheses in `TensorConfluence.lean` and `TensorSortedRewrite.lean`: termination measure, local confluence/critical pair closure, sortedness invariants.
2. Define the quantum instantiation as a model of that abstract tensor rewrite system.
3. Discharge the semantic side-conditions using matrix linearity over `ℂ`, then invoke the catalog theorem to obtain normalization/confluence.

**Why promising:** fastest route if the catalog abstractions are sufficiently parametric.  
**Risk:** the catalog may encode assumptions too specifically for the Pythagorean setting.

---

### Strategy B: Direct critical-pair analysis for the `{H, T, CNOT}` fragment
1. Define the rewrite rules concretely on quantum tensor expressions.
2. Enumerate the overlap shapes of distributivity and sorting rules.
3. Prove joinability of each critical pair by explicit rewrite derivations.
4. Combine with a structural size measure to show termination, then conclude confluence.

**Why promising:** mathematically robust and independent of abstraction mismatch.  
**Risk:** more laborious, but this gives the strongest theorem and the cleanest scientific narrative.

This is likely the **best strategy** if the fragment is kept disciplined.

---

### Strategy C: Semantic-guided normalization
1. Define a recursive normalization function `normalize : QuantumTensorExpr → QuantumTensorExpr`.
2. Prove by induction that `normalize e` is normal, semantics-preserving, and reachable by rewrite closure.
3. Prove uniqueness by showing every normal form computes the same sorted distributive expansion.

**Why promising:** gives an executable algorithm immediately.  
**Risk:** uniqueness may still require nontrivial algebraic lemmas and AC reasoning.

This strategy is ideal for the **verified algorithm** requirement and pairs well with A or B.

---

## Concrete proof tactics expected

Your proofs must use deep tactics and structure:
- induction on expression derivations or rewrite closure,
- `rcases` for critical-pair shape analysis,
- `by_contra` for irreducibility/uniqueness arguments,
- `field_simp` if rational/complex scalar normalizations appear,
- substantial `calc` chains for semantic equality of matrix actions,
- extensionality on vectors/matrices where needed.

Do not hide the mathematics behind automation. The point is to expose the algebraic content.

---

## Mathematical ingredients to exploit

### From the catalog
Use the catalog results as reusable rewrite-theoretic scaffolding:
- sorted rewrite invariants,
- abstract confluence transfer principles,
- tensor-expression decomposition lemmas,
- termination measures on syntax trees.

Be explicit in the file about which lemmas are imported and how they are repurposed.

### From Mathlib
Potentially relevant areas:
- `Matrix`
- `Complex`
- linear maps and finite-dimensional vector spaces
- reflexive transitive closure / relation theory
- multisets / lists for AC-normalization and sortedness
- well-founded recursion / measures

You do not need a full formalization of `SU(2)` unless it directly serves the theorem. A gate-level matrix semantics for `H`, `T`, and `CNOT` is enough. If proving unitarity is helpful, prove it for the concrete gates you use.

---

## Scope discipline

Be ambitious, but choose a fragment you can actually conquer formally.

A good scope is:
- 2 qubits only,
- gate set `{H, T, CNOT}`,
- a syntax with sequential composition, tensor composition, and formal distributive nodes,
- confluence/normalization modulo commutativity of **parallel independent factors** only.

Do **not** attempt full arbitrary quantum circuit equivalence. The breakthrough is already substantial if you establish a canonical distributive normal form in a rich 2-qubit fragment.

---

## Cross-domain connections to emphasize

You must make at least one of these bridges explicit in theorem statements or discussion:

1. **Rewriting theory ↔ quantum information**  
   Canonical forms for circuits; preservation of entanglement-sensitive invariants.

2. **Category theory ↔ circuit optimization**  
   Interpret rewrites as coherence/normalization phenomena in a monoidal or compact-closed setting.

3. **Algebra ↔ physics**  
   Show that distributivity and bilinearity are the algebraic skeleton of superposition and controlled evolution.

4. **Certified algorithms ↔ complexity of equivalence checking**  
   Normal forms can reduce circuit comparison from search to normalization.

---

## Application keywords

Include these explicitly in your writeup and metadata-style comments:

**Application keywords:** quantum circuit optimization, canonical forms, tensor rewriting, confluence modulo AC, distributive normal forms, quantum compilation, equivalence checking, monoidal categories, entanglement invariants, certified algorithms, term rewriting, linear algebraic semantics.

---

## Falsifiable conjecture with computational test

State at least one concrete conjecture and implement a test that could refute it.

### Suggested conjecture
> **Conjecture:** For all 2-qubit circuits of depth at most 5 over `{H, T, CNOT}`, distributive normalization yields a unique normal form modulo `ParallelACEq`.

A Lean-adjacent mathematical statement:

```lean
conjecture depth5_unique_nf_mod_parallelAC :
  ∀ e,
    circuitDepth e ≤ 5 →
    UsesGateSetHTCNOT e →
    WellFormedQExpr e →
    ∃! n, ReflTransGen QRewriteStep e n ∧ IsQuantumNormalForm n
```

This may be too strong globally; if so, state a more precise restricted version. The crucial point is that it is **testable and falsifiable**.

### Computational test
Implement BFS/normalization-based enumeration of all circuits of depth `≤ 5` over `{H, T, CNOT}`:
- generate circuits,
- normalize them,
- compare all reachable normal forms from the same source,
- search for counterexamples to uniqueness/confluence modulo AC.

If a counterexample appears, that is scientifically valuable: refine the rewrite system and document the obstruction.

---

## Verified algorithm requirement

You must provide a verified computational method, not only existence theorems.

### Minimum target
Define a normalization function:

```lean
def normalize : QuantumTensorExpr → QuantumTensorExpr
```

and prove:

```lean
theorem normalize_sound (e : QuantumTensorExpr) :
  denote (normalize e) = denote e

theorem normalize_normal (e : QuantumTensorExpr) :
  IsQuantumNormalForm (normalize e)

theorem normalize_reachable (e : QuantumTensorExpr) :
  ReflTransGen QRewriteStep e (normalize e)
```

If uniqueness is established:

```lean
theorem normalize_complete
  {e n : QuantumTensorExpr}
  (h₁ : ReflTransGen QRewriteStep e n)
  (hn : IsQuantumNormalForm n) :
  ParallelACEq (normalize e) n
```

This gives a certified optimizer and equivalence-checking primitive.

---

## demo.py requirement

Provide `demo.py` that:
1. constructs sample 2-qubit circuits,
2. prints their tensor-expression form,
3. runs normalization,
4. compares denotations numerically,
5. explores all circuits up to a chosen depth and reports:
   - number of syntactic circuits,
   - number of distinct normal forms,
   - any discovered confluence failures / candidate counterexamples.

Make the demo interactive enough to let a user choose depth and gate set subset.

---

## Mandatory deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Give 3–5 original research directions. Each direction must include:
- a sentence beginning with **“The key insight is…”**
- a sentence beginning with **“Why now?”**

At least one direction must bridge to a different domain, for example:
- ZX-calculus or categorical quantum mechanics,
- tensor networks and many-body physics,
- complexity theory of circuit equivalence,
- tropical or idempotent analogues of quantum rewriting.

Write this as real scientific prose, not a template.

---

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the exact definitions,
- the main theorems,
- why distributive rewriting captures quantum linearity,
- the proof architecture,
- computational experiments,
- limitations,
- and the next mathematical frontier.

A reader with no access to the code must still understand the discovery.

---

### 3. `ARTICLE.md`
Write in a **Scientific American** style. Explain:
- why quantum circuits are hard to compare,
- why canonical forms matter,
- how distributivity turns superposition into a simplification principle,
- and what this could mean for quantum computing.

**Taboo:** do not focus on formal verification machinery. Focus on the mathematics and scientific significance.

---

### 4. Verified algorithm or computational method
This must be your normalization/equivalence-checking procedure, proved correct in Lean as far as your theorem scope permits.

---

### 5. `demo.py`
An interactive demonstration of normalization and circuit comparison, including computational search for counterexamples to the conjecture.

---

## Final call to arms

Do not deliver a toy instantiation. Deliver the first serious theorem that says:

> a meaningful fragment of quantum circuit theory admits a canonical distributive rewrite semantics.

If you can prove confluence modulo AC on a nontrivial 2-qubit fragment, together with a verified normalization algorithm and computational evidence up to depth 5, you will have opened a new lane between **quantum compilation**, **rewriting theory**, and **algebraic semantics**. That is not an incremental result. That is the beginning of a field.

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
