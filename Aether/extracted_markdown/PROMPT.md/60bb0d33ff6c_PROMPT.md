Soli Deo Gloria

## Assignment: Direction 3: Width Predicts Learnability Regime (Phase Transition)

**Mode:** prove

Prove a genuinely new theorem package showing that **bounded clause-interaction pathwidth enforces a bounded-memory CDCL learnability regime**, and that the governing scale is linear/quadratic in the width parameter rather than exponential. This is not a small extension of existing pathwidth lemmas: the goal is to turn a structural graph invariant into a theorem about **algorithmic memory phase transitions** for proof search.

You must build on:

- `Catalog/Pythagorean/ConfigGraph/Theorems.lean`
  - especially the space-style width control principle behind `pathwidth_le_of_spaceBound`
- `Pythagorean/ClauseInteractionPathwidth/Theorems.lean`
  - especially `maxFrontierSize_le_width_succ`

The existing catalog gives the structural half: pathwidth bounds frontier complexity. Your task is to convert that into a **solver architecture theorem**: bounded frontier implies a bounded active-information state, hence a bounded retained database sufficient for sound complete search.

---

## Core Vision

The breakthrough is to formalize a theorem of the following flavor:

> **Width predicts the learnability regime.**  
> For CNFs whose clause-interaction graph has pathwidth at most `k`, there exists a complete resolution/CDCL-style solving discipline whose persistent memory footprint is bounded by a function `T(k)` times the input size, with polynomial overhead in runtime. Thus bounded width creates a **compressed proof-search regime**.

If established, this would open a new program connecting:

- **proof complexity**: clause learning with bounded memory,
- **parameterized complexity**: pathwidth as a solver resource parameter,
- **statistical physics / CSP phase transitions**: structural width as an order parameter,
- **learning theory**: “learnability regime” as compressibility of search-relevant information.

Application keywords: **CDCL, proof complexity, pathwidth, parameterized SAT, bounded-memory reasoning, phase transition, random CSP, graph separators, dynamic programming, compressed search, resolution width, structural learnability**

---

## New Formal Objects You Must Introduce

The catalog likely does not yet contain the exact abstractions needed. You must define at least one genuinely new structure. Suggested definitions:

1. **Active frontier state** for a path decomposition of the clause-interaction graph.
   - Intuition: the set of clauses/variables whose information must remain live because they still interact with future bags.

2. **Retained database profile**
   - a function assigning to each decomposition position the number of clauses that must remain stored for a complete sound strategy.

3. **Width-controlled solver policy**
   - an abstract CDCL-like policy parameterized by a path decomposition, with soundness/completeness axioms and a memory bound.

A possible Lean-facing definition skeleton:

```lean
structure RetainedProfile (α : Type _) where
  stages : List α
  retainedAt : α → ℕ

structure WidthControlledPolicy (F : CNF) where
  pwBound : ℕ
  profile : RetainedProfile ℕ
  sound : Prop
  complete : Prop
  memoryBound : ∀ t, profile.retainedAt t ≤ (pwBound + 1) * F.clauseCount
```

If `CNF` is not already in exactly this form, adapt to the catalog’s actual SAT/CNF types. The important thing is that the definition captures a **mathematical memory invariant**, not implementation trivia.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**, using multi-step reasoning. At least one theorem must connect SAT width control to a different mathematical domain.

### Theorem 1: Structural memory envelope from pathwidth

This is the first nontrivial bridge from the catalog to solver memory.

**Mathematical statement**

Let `F` be a CNF and let `pwCI(F)` denote the pathwidth of its clause-interaction graph. Then there exists a decomposition-guided retained-memory profile whose stagewise retained set size is bounded by `(pwCI(F)+1) * |F|`.

More explicitly:

\[
\forall F,\ \operatorname{pwCI}(F)\le k \;\Longrightarrow\; \exists P,\ 
(\forall t,\ \mathrm{retainedAt}_P(t)\le (k+1)\cdot |F|).
\]

This should be derived by combining:
- a path decomposition of width `k`,
- the frontier bound from `maxFrontierSize_le_width_succ`,
- a counting argument converting frontier size into total live clause information.

**Lean 4 type signature sketch**

```lean
theorem exists_retainedProfile_bound_of_clauseInteractionPathwidth_le
  (F : CNF) (k : ℕ)
  (hk : clauseInteractionPathwidth F ≤ k) :
  ∃ P : RetainedProfile ℕ,
    ∀ t, P.retainedAt t ≤ (k + 1) * F.clauseCount
```

If your catalog uses a decomposition object explicitly, strengthen this to quantify over decompositions:

```lean
theorem exists_retainedProfile_bound_of_hasPathDecomposition
  (F : CNF) (D : PathDecomposition (clauseInteractionGraph F)) (k : ℕ)
  (hw : D.width ≤ k) :
  ∃ P : RetainedProfile D.BagIndex,
    ∀ t, P.retainedAt t ≤ (k + 1) * F.clauseCount
```

**Why this matters**
This theorem converts a graph-theoretic width certificate into a **global memory certificate** for reasoning. It is the first rigorous statement that “small pathwidth means small live proof state.”

---

### Theorem 2: Existence of a width-controlled complete policy

This is the conceptual centerpiece.

**Mathematical statement**

For every CNF `F` of clause-interaction pathwidth at most `k`, there exists a sound complete decomposition-guided search policy whose retained database size is bounded stagewise by a function linear in `|F|` and width `k`.

\[
\forall F,\ \operatorname{pwCI}(F)\le k \Rightarrow
\exists \Pi,\ \mathrm{Sound}(\Pi,F)\wedge \mathrm{Complete}(\Pi,F)\wedge
\forall t,\ \mathrm{DBSize}_\Pi(t)\le (k+1)|F|.
\]

This theorem should formalize a mathematically abstract solver policy, not necessarily a full executable industrial CDCL engine. A dynamic-programming-style elimination policy that simulates complete search over the path decomposition is acceptable, provided you prove:
- soundness,
- completeness,
- memory bound.

**Lean 4 type signature sketch**

```lean
theorem exists_widthControlledPolicy_of_clauseInteractionPathwidth_le
  (F : CNF) (k : ℕ)
  (hk : clauseInteractionPathwidth F ≤ k) :
  ∃ π : WidthControlledPolicy F,
    π.pwBound ≤ k ∧
    π.sound ∧
    π.complete ∧
    (∀ t, π.profile.retainedAt t ≤ (k + 1) * F.clauseCount)
```

A stronger and more revolutionary version is to state polynomial overhead:

```lean
theorem exists_widthControlledPolicy_polyOverhead_of_clauseInteractionPathwidth_le
  (F : CNF) (k : ℕ)
  (hk : clauseInteractionPathwidth F ≤ k) :
  ∃ π : WidthControlledPolicy F,
    π.sound ∧
    π.complete ∧
    (∀ t, π.profile.retainedAt t ≤ (k + 1) * F.clauseCount) ∧
    runtimeBound π ≤ polynomialIn (F.varCount + F.clauseCount + k)
```

If runtime formalization is too heavy, prove the memory theorem first and isolate runtime as a conjectural extension in `FUTURE_DIRECTIONS.md`.

**Why this matters**
This would be a formal theorem that **bounded structural width implies bounded-memory complete reasoning**. That is a field-opening statement at the boundary of SAT, proof complexity, and parameterized algorithms.

---

### Theorem 3: Monotonicity / phase transition control law

You need a theorem that gives the “phase transition” language real mathematical content. Prove that the minimal admissible memory threshold is monotone in width, and preferably subadditive or linearly bounded by the frontier law.

Define a threshold function:

\[
T(F) := \inf\{M \in \mathbb N : \exists \text{ sound complete policy for } F \text{ with retained size }\le M\}.
\]

Then prove a structural upper bound:

\[
\forall F,\ T(F)\le (\operatorname{pwCI}(F)+1)\cdot |F|.
\]

And if you define an extremal threshold over width classes,

\[
T^\star(k,n)=\sup\{T(F): |F|=n,\ \operatorname{pwCI}(F)\le k\},
\]

prove:

\[
T^\star(k,n)\le (k+1)n.
\]

This gives a rigorous theorem behind the conjectural `O(k²)` discussion and may even sharpen it to linear-in-`k` under your abstract policy model.

**Lean 4 type signature sketch**

```lean
def memoryThreshold (F : CNF) : ℕ := ...

theorem memoryThreshold_le_pathwidth_mul_clauseCount
  (F : CNF) :
  memoryThreshold F ≤ (clauseInteractionPathwidth F + 1) * F.clauseCount
```

Optionally:

```lean
def worstCaseThreshold (k n : ℕ) : ℕ := ...

theorem worstCaseThreshold_le
  (k n : ℕ) :
  worstCaseThreshold k n ≤ (k + 1) * n
```

**Why this matters**
This is the theorem that turns “phase transition” from metaphor into invariant. Width becomes an **order parameter** for bounded-memory solvability.

---

### Theorem 4: Cross-domain bridge to statistical mechanics / separators / entropy

You must include at least one theorem linking this SAT-width story to another domain.

The most promising route is an **entropy or state-count theorem**: bounded frontier size implies bounded number of distinct partial boundary states. This is a combinatorial-statistical-mechanics bridge.

**Mathematical statement**

If a decomposition has frontier size at most `k+1`, then the number of possible boundary truth assignments is at most `2^(k+1)`. Hence the solver’s relevant information state space is exponentially bounded in width and independent of global instance size at each stage.

\[
\forall F,\ \operatorname{pwCI}(F)\le k \Rightarrow
\exists \text{ stage model } S_t,\ \forall t,\ |S_t|\le 2^{k+1}.
\]

This is the exact analogue of a transfer-matrix bound in statistical mechanics: bounded separator width implies bounded local state complexity.

**Lean 4 type signature sketch**

```lean
theorem boundaryStateCount_le_pow_of_frontierBound
  (F : CNF) (k : ℕ)
  (hk : clauseInteractionPathwidth F ≤ k) :
  ∃ S : ℕ → Finset BoundaryState,
    (∀ t, (S t).card ≤ 2 ^ (k + 1))
```

If cardinalities over finite assignment spaces are easier:

```lean
theorem card_partialAssignments_le_two_pow_frontier
  {α : Type _} [Fintype α]
  (B : Finset α) :
  Fintype.card (B → Bool) ≤ 2 ^ B.card
```

then specialize using the frontier-width theorem. This gives a clean bridge to:
- transfer matrices,
- Gibbs boundary conditions,
- communication complexity of separators.

**Why this matters**
This is the cross-domain theorem. It says bounded pathwidth creates a **finite thermodynamic boundary state space**. That is the right language for phase transitions and compressed inference.

---

## Proof Strategy Architecture

You must not give Aristotle a single path. Use multiple strategies and indicate the most promising.

### Strategy A: Frontier-to-memory counting argument
Most promising for Theorems 1 and 3.

1. Start from a path decomposition witnessing `clauseInteractionPathwidth F ≤ k`.
2. Apply `maxFrontierSize_le_width_succ` to bound the live interaction frontier by `k+1`.
3. Define retained clauses as those intersecting the current frontier or needed to preserve completeness for future bags.
4. Prove by induction on decomposition stages that the retained set never exceeds `(k+1) * |F|` or a sharper linear expression.
5. Package the result as `RetainedProfile` and derive `memoryThreshold_le_pathwidth_mul_clauseCount`.

Why promising:
- It directly leverages catalog theorems.
- It avoids needing a fully realistic CDCL semantics at first.
- It gives the cleanest route to a formal upper bound.

### Strategy B: Dynamic programming / elimination policy simulation
Most promising for Theorem 2.

1. Define a decomposition-guided policy that processes bags left-to-right.
2. At each step, retain only clauses or summaries whose variables lie in the current frontier.
3. Prove completeness by showing all eliminated interior variables have their effect summarized on the frontier.
4. Prove soundness by induction over the processed prefix.
5. Derive the memory bound from frontier cardinality and the encoding size of summaries.

Why promising:
- This gives an actual algorithmic theorem rather than only a counting theorem.
- It naturally yields a `demo.py` implementation.
- It creates a bridge to treewidth/pathwidth dynamic programming literature.

### Strategy C: Resolution-width / proof-compression reinterpretation
High risk, high reward.

1. Formalize a notion of learned clause support localized to the frontier.
2. Show any needed learned clause can be replaced by an equivalent frontier-supported summary clause.
3. Prove bounded-memory completeness by replacing unrestricted clause retention with frontier summaries.
4. Relate this to resolution width or clause space.

Why promising:
- If it works, this is the most revolutionary proof-complexity statement.
Why risky:
- It may require much heavier infrastructure than currently exists in the catalog.

**Recommendation:** Execute Strategy A first, then Strategy B. Reserve Strategy C for `FUTURE_DIRECTIONS.md` unless the infrastructure already exists.

---

## Concrete Lean Guidance

You must include precise theorem statements in Lean 4 style, adapted to actual catalog names once inspected. At minimum, aim for the following theorem namespace pattern:

```lean
namespace Pythagorean.CDCLPathwidth

def memoryThreshold (F : CNF) : ℕ := ...
def retainedClauseSet ... := ...
structure RetainedProfile ... := ...
structure WidthControlledPolicy (F : CNF) where ...

theorem exists_retainedProfile_bound_of_clauseInteractionPathwidth_le ...
theorem memoryThreshold_le_pathwidth_mul_clauseCount ...
theorem exists_widthControlledPolicy_of_clauseInteractionPathwidth_le ...
theorem boundaryStateCount_le_pow_of_frontierBound ...

end Pythagorean.CDCLPathwidth
```

Deep proof tactics expected:
- induction over decomposition index/list of bags,
- `rcases` on decomposition witnesses and frontier bounds,
- `by_contra` for minimal-threshold or extremal arguments,
- `field_simp` only if a normalized asymptotic/rational inequality appears,
- multi-step `calc` chains for cardinality bounds.

Do not hide the mathematics in automation. The point is to expose a new invariant and prove it structurally.

---

## What Would Make This Paradigm-Shifting

If you prove even the abstract version, you will have created a new theorem schema:

> **graph width controls solver memory complexity**

That is broader than SAT. It suggests analogous results for:
- CSP propagation,
- Bayesian network inference,
- tensor network contraction,
- message passing in spin systems,
- database query evaluation.

This is exactly the kind of theorem that can seed a new field: **structural learnability theory for reasoning systems**.

---

## Falsifiable Conjecture to Include

You must state at least one explicit conjecture with a computational disproof protocol.

### Main conjecture
For bounded-pathwidth clause-interaction instances, the worst-case complete retained-memory threshold is asymptotically linear in width:

\[
\exists C>0,\ \forall F,\quad
\operatorname{memoryThreshold}(F)\le C(\operatorname{pwCI}(F)+1)\cdot |F|.
\]

If your formal theorem already proves this with `C = 1`, state the stronger empirical conjecture:

\[
T^\star(k,n) = \Theta(k n)
\quad\text{rather than}\quad \Theta(k^2 n)\ \text{or}\ \exp(k)n.
\]

### Computational test
Generate random planted-solution CNFs whose clause-interaction graph is constrained by a path decomposition of width `k`. For each `k ∈ {2,5,10,20,50}`:
1. estimate the smallest retained memory budget under decomposition-guided learning that preserves completeness across 1000 instances;
2. fit growth in `k`;
3. reject the conjecture if the best fit is superlinear/exponential with strong statistical confidence.

A second falsifiable conjecture:
> The empirical number of distinct boundary states scales like `≈ c · 2^k` rather than `2^{Θ(k log k)}`.

This directly tests the statistical-mechanics interpretation.

---

## Cross-Domain Connections You Must Explicitly Discuss

1. **Proof complexity**
   - clause space, resolution width, proof compression
2. **Parameterized complexity**
   - pathwidth/treewidth as resource parameters
3. **Statistical mechanics**
   - frontier states as boundary conditions; transfer-matrix state complexity
4. **Learning theory**
   - bounded retained database as compressed hypothesis state
5. **Random CSP phase transitions**
   - width as an order parameter separating easy compressed-search from hard expansive-search regimes

Do not mention these as buzzwords only; explain how your theorem mathematically interfaces with each domain.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial theorems, minimizing `sorry`.
2. **`FUTURE_DIRECTIONS.md`**
   - include **3–5 falsifiable scientific hypotheses**
   - each must state:
     - the conjectured phenomenon,
     - the exact computational or mathematical test,
     - what outcome would refute it
3. **`RESEARCH_PAPER.md`**
   - standalone scientific paper
   - must explain:
     - theorem statements,
     - proof ideas,
     - why width predicts a learnability regime,
     - how this reframes bounded-memory SAT/proof complexity,
     - next-step research agenda
4. **`ARTICLE.md`**
   - Scientific American style
   - accessible and engaging
   - taboo: do **not** focus on formal verification machinery
   - focus on the mathematical idea that structural bottlenecks govern the memory of reasoning
5. **A verified algorithm or computational method**
   - e.g. a decomposition-guided bounded-memory solver, or a certified boundary-state counter
6. **`demo.py`**
   - interactively generate bounded-pathwidth CNFs,
   - estimate the retained-memory threshold,
   - visualize threshold vs. width,
   - show boundary-state counts / phase-transition plots

---

## Final Standard

Do not settle for “pathwidth gives a small frontier.” That is already morally known. The target is stronger:

> **formalize and prove that bounded width induces a bounded-memory complete reasoning regime, and identify width as the order parameter of a learnability phase transition.**

If you can establish this cleanly, you are not extending a theorem—you are defining a new research program.

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

Research domain: Pythagorean
Research mode: prove
