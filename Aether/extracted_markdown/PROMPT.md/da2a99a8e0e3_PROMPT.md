## Assignment: Direction 3 — Clause Space Lower Bounds via Width–Space Connections

**Mode:** `prove`

You should not merely formalize a folklore inequality. You should build a new formal bridge between **resolution proof complexity**, **configuration-space graph theory**, and **memory lower bounds for algorithmic reasoning**. The target is to turn clause space from a bookkeeping notion into a mathematically robust invariant that can support genuine lower-bound arguments and executable experiments.

The central vision is this:

> Resolution proofs are not just derivations; they are **dynamical trajectories through a finite configuration graph**. Width controls geometric spread, while space controls instantaneous memory load. If formalized correctly, this opens a route from SAT proof complexity to **pebbling**, **graph searching**, and **memory-constrained computation**.

Your job is to make that route mathematically real in Lean 4.

---

## Core Breakthrough Goal

Formalize a nontrivial theory of **configuration-based clause space** for resolution, prove at least **three substantial theorems** about it, and use it to derive new lower bounds for families of CNFs inspired by the pigeonhole principle and narrow encodings.

You should build on:

- `Computation/ProofComplexity/WidthToSize.lean`
- especially results analogous to:
  - `allClauses_width_le_maxWidth`
  - `widthSpectrum`
  - `clauseSpaceBound`

But do **not** stop at reproving known width-space inequalities. The breakthrough target is to introduce a **new formal object** — a live-clause configuration system — and prove that lower bounds on proof memory arise from unavoidable traversal of configuration states.

---

## Precise Theorem Targets

You must aim to formalize statements at approximately the following level of precision. Adjust names to match the existing library, but keep the mathematical content intact.

### New definition: proof configurations

Introduce a new structure, genuinely novel relative to the catalog:

```lean
structure ProofConfiguration (ν : Type) [Fintype ν] [DecidableEq ν] where
  liveClauses : Finset (Clause ν)
```

and a notion of legal one-step evolution for a sequential resolution proof:

```lean
inductive ConfigStep (F : CNF ν) : ProofConfiguration ν → ProofConfiguration ν → Prop
| axiom_add ...
| resolve_add ...
| weaken_add ...      -- only if weakening is already part of your framework
| erase ...
```

Then define proof-space:

```lean
def configurationSpace {ν : Type} [Fintype ν] [DecidableEq ν]
    (π : List (ProofConfiguration ν)) : Nat :=
  (π.foldl (fun m C => max m C.liveClauses.card) 0)
```

and a legality predicate:

```lean
def IsConfigurationRefutation (F : CNF ν) (π : List (ProofConfiguration ν)) : Prop := ...
```

This is the central new object. Everything else should be built around it.

---

## Theorem 1: Configuration-space lower bound from width

Formalize a sharpened width-space theorem at the configuration level.

### Mathematical statement
For every unsatisfiable CNF `F`, every legal sequential resolution refutation through configurations has space at least the width gap plus one:

\[
\forall F,\ \forall \pi,\ \text{IsConfigurationRefutation}(F,\pi)
\to \operatorname{configurationSpace}(\pi)\ge
\operatorname{refutationWidth}(F)-\operatorname{maxInitWidth}(F)+1.
\]

If the catalog already contains a theorem of the form `clauseSpaceBound`, your task is **not** to duplicate it, but to prove that the new configuration semantics realizes that bound.

### Suggested Lean type signature
```lean
theorem configurationSpace_ge_width_gap
    {ν : Type} [Fintype ν] [DecidableEq ν]
    (F : CNF ν) (π : List (ProofConfiguration ν))
    (hπ : IsConfigurationRefutation F π) :
    refutationConfigurationSpace F π ≥
      minRefutationWidth F - maxInitWidth F + 1 := by
  ...
```

If your library uses different names such as `widthSpectrum` or `clauseSpaceBound`, prove a theorem of the form:

```lean
theorem configurationSpace_ge_clauseSpaceBound
    {ν : Type} [Fintype ν] [DecidableEq ν]
    (F : CNF ν) (π : List (ProofConfiguration ν))
    (hπ : IsConfigurationRefutation F π) :
    configurationSpace π ≥ clauseSpaceBound F := by
  ...
```

### Why this matters
This theorem upgrades an existential or combinatorial width-space inequality into a **state-trajectory theorem**. That is a conceptual leap: proofs become paths in a graph with unavoidable memory bottlenecks. This is exactly the formal language needed to connect proof complexity to pebbling and memory management.

---

## Theorem 2: Configuration graph connectivity and bottleneck principle

Define the **configuration graph** whose vertices are legal live-clause sets and whose directed edges are `ConfigStep`. Prove a bottleneck theorem saying that any path from the empty configuration to contradiction must cross a large-space frontier.

### Mathematical statement
Let `ConfGraph(F)` be the directed graph of legal configurations. Let
\[
B_s(F)=\{C : |C|\le s\}.
\]
If contradiction is unreachable from the initial configuration inside the induced subgraph on `B_s(F)`, then every refutation requires space at least `s+1`.

This sounds obvious, but formalizing it cleanly in Lean creates the graph-theoretic interface you need for experiments and future transfer to pebbling.

### Suggested Lean type signature
```lean
theorem bottleneck_space_lower_bound
    {ν : Type} [Fintype ν] [DecidableEq ν]
    (F : CNF ν) (s : Nat)
    (hsep : ¬ ReachableWithinBound F s initialConfiguration contradictionConfiguration) :
    ∀ π, IsConfigurationRefutation F π → configurationSpace π ≥ s + 1 := by
  ...
```

You may need to define:
- `initialConfiguration`
- `contradictionConfiguration`
- `ReachableWithinBound`

### Why this is a breakthrough
This theorem recasts proof-space lower bounds as **graph separation phenomena**. That is the exact form needed for importing methods from:
- graph searching,
- pathwidth/treewidth,
- pebbling lower bounds,
- memory-constrained planning.

This is the cross-domain portal.

---

## Theorem 3: Narrow-encoding linear space lower bound

The standard PHP width-space inequality is weak because initial width is already large. So you should introduce or formalize a **narrow encoding** where initial clauses have bounded width, while refutation width is still linear.

You do **not** need to solve the full unrestricted PHP space conjecture. Instead, prove a theorem of the following form for a bounded-width family `NarrowPHP n`:

### Mathematical statement
There exists a family of unsatisfiable CNFs `NarrowPHP n` such that:

1. `maxInitWidth (NarrowPHP n) ≤ C` for some constant `C`,
2. `minRefutationWidth (NarrowPHP n) ≥ n`,
3. therefore every sequential resolution refutation has clause space at least `n - C + 1`.

### Suggested Lean type signature
```lean
theorem narrowPHP_space_linear
    (n : Nat) :
    ∃ F : CNF (VarOfNarrowPHP n),
      isNarrowPHPEncoding n F ∧
      maxInitWidth F ≤ C ∧
      minRefutationWidth F ≥ n ∧
      ∀ π, IsConfigurationRefutation F π → configurationSpace π ≥ n - C + 1 := by
  ...
```

If constructing the full family is too large for one cycle, prove a parameterized theorem:

```lean
theorem boundedInitWidth_of_narrowPHP ...
theorem width_lower_bound_of_narrowPHP ...
theorem space_lower_bound_of_narrowPHP ...
```

### Why this matters
This turns a trivial lower bound into a **linear memory lower bound**. That is the first genuinely algorithmically meaningful result in this direction, because it says memory blowup is not an artifact of proof search strategy but is forced by the encoding geometry.

---

## Optional Theorem 4: Pebbling-to-resolution transfer

If time permits, define a simple black-pebbling game on a DAG and prove a transfer theorem:

\[
\text{PebblingSpace}(G) \le \text{ClauseSpace}(\operatorname{PebblingCNF}(G)).
\]

### Suggested Lean type signature
```lean
theorem pebblingSpace_le_clauseSpace_pebblingCNF
    (G : DAG α) :
    pebblingSpace G ≤ minClauseSpace (pebblingCNF G) := by
  ...
```

Even a restricted version for layered DAGs would be valuable.

### Why this is revolutionary
This would connect SAT proof memory lower bounds directly to the classical theory of **time-space tradeoffs**, making the formal library relevant to computational complexity beyond proof systems.

---

## Proof Architecture: 3 viable strategies

You must include deep proof tactics: induction, `rcases`, `by_contra`, `field_simp` where relevant, and multi-step `calc`. Avoid trivial automation.

### Strategy A: Width monotonicity along configuration traces
Most promising for Theorem 1.

1. Define a predicate saying a clause is **available at configuration `C`** iff it lies in `C.liveClauses`.
2. Show by induction on proof length that every derived clause must appear in some reachable configuration.
3. Prove that if all reachable configurations had size at most `s`, then all clauses appearing in the derivation lie in a bounded combinatorial family controlled by width and `s`.
4. Invoke the catalog width-space bound (`clauseSpaceBound`) to conclude.

Why promising:
- It directly leverages existing catalog infrastructure.
- It only requires proving the new semantics is sound and complete with respect to the old one.
- It yields a clean abstraction barrier.

### Strategy B: Configuration graph separation
Best for Theorem 2 and future directions.

1. Construct the finite directed graph of legal configurations.
2. Define the subgraph of configurations of size `≤ s`.
3. Prove by contradiction (`by_contra`) that a refutation with space `≤ s` induces a path inside this subgraph from initial to contradiction.
4. Therefore if no such path exists, every refutation crosses the `s+1` frontier.

Why promising:
- Graph-theoretic reasoning is robust and reusable.
- It supports computational certification: `demo.py` can literally search this graph.
- It opens the door to graph-width invariants.

### Strategy C: Encoding-level lower bound via bounded-width CNFs
Most promising for Theorem 3 if you can identify a manageable encoding.

1. Define a narrow CNF family with constant-width initial clauses.
2. Prove unsatisfiability and establish a linear lower bound on refutation width.
3. Combine with Theorem 1 to obtain linear clause-space lower bounds.

Why promising:
- Produces the most concrete “headline theorem.”
- Supports exhaustive experiments for small `n`.
- Gives immediate SAT-solver relevance.

---

## Catalog Building Blocks and How to Use Them

You explicitly need to mine `Computation/ProofComplexity/WidthToSize.lean` for exact theorem names and reuse them structurally.

Expected use pattern:

- Use `allClauses_width_le_maxWidth` to control widths of clauses appearing in bounded-width derivations or configurations.
- Use `widthSpectrum` to identify the width profile of derivable clauses and connect it to configuration occupancy.
- Use `clauseSpaceBound` as the abstract lower bound, then prove your new configuration-space semantics **realizes** that invariant.

Do not merely cite these. Prove lemmas of the form:

```lean
theorem configSemantics_sound_against_catalog ...
theorem configSemantics_complete_against_catalog ...
theorem configurationSpace_eq_catalogClauseSpace ...
```

or at least inequalities in the needed direction.

That transfer theorem is likely the true formal contribution.

---

## Required Cross-Domain Connection

You must include at least one theorem explicitly connecting proof complexity to another domain.

### Preferred bridge: graph searching / pathwidth
Define a configuration graph and prove a theorem of the form:

```lean
theorem clauseSpace_ge_pathwidthLowerBound
    {ν : Type} [Fintype ν] [DecidableEq ν]
    (F : CNF ν) :
    graphPathwidth (configurationGraph F) ≤ minClauseSpace F + K := by
  ...
```

Even a weak or restricted statement is acceptable if nontrivial.

Alternative bridges:
- pebbling games,
- memory allocation models,
- finite automata state complexity,
- graph searching numbers.

This is mandatory: at least one theorem must not live entirely inside proof complexity.

---

## Conjecture with Testable Prediction

State at least one falsifiable conjecture, with a computational protocol that could refute it.

### Conjecture A: Exact small-n narrow-PHP space law
For the narrow encoding `NarrowPHP n`,
\[
\operatorname{minClauseSpace}(\text{NarrowPHP } n)=n+1
\quad \text{for } 2 \le n \le 8.
\]

Computational test:
- Enumerate all legal sequential resolution refutations up to symmetry.
- Compute exact minimum configuration space.
- Refute if any `n ≤ 8` violates equality.

### Conjecture B: Bottleneck-pathwidth correspondence
There exists a universal constant `c` such that for every unsatisfiable CNF `F`,
\[
\operatorname{minClauseSpace}(F) \ge \frac{1}{c}\,\operatorname{pathwidth}(\operatorname{configurationGraph}(F)).
\]

Computational test:
- For all CNFs on up to, say, 5 variables, compute both sides exactly.
- Search for a counterexample to any proposed constant.

### Conjecture C: Pebbling transfer sharpness
For layered DAGs `G`,
\[
\operatorname{minClauseSpace}(\operatorname{PebblingCNF}(G))
=
\operatorname{pebblingSpace}(G) + O(1).
\]

Computational test:
- Generate small layered DAGs.
- Compute black-pebbling number and exact clause space of the associated CNF.
- Look for superconstant gaps.

At least one of these must appear in `FUTURE_DIRECTIONS.md` as a falsifiable scientific hypothesis.

---

## Lean 4 Formalization Guidance

Your theorem statements should be as close as possible to executable Lean signatures. You will likely need finite-variable assumptions:

```lean
variable {ν : Type} [Fintype ν] [DecidableEq ν]
```

Potential core definitions:

```lean
def Clause.width (C : Clause ν) : Nat := ...
def CNF.maxWidth (F : CNF ν) : Nat := ...
def derivesResolution (F : CNF ν) (C : Clause ν) : Prop := ...
def isContradiction (C : Clause ν) : Prop := ...
def minRefutationWidth (F : CNF ν) : Nat := ...
def minClauseSpace (F : CNF ν) : Nat := ...
```

New objects to introduce:

```lean
structure ProofConfiguration (ν : Type) [Fintype ν] [DecidableEq ν] where
  liveClauses : Finset (Clause ν)

inductive ConfigStep (F : CNF ν) :
    ProofConfiguration ν → ProofConfiguration ν → Prop
| axiom_add ...
| resolve_add ...
| erase ...

def IsConfigurationTrace (F : CNF ν) : List (ProofConfiguration ν) → Prop := ...
def IsConfigurationRefutation (F : CNF ν) : List (ProofConfiguration ν) → Prop := ...
def configurationSpace (π : List (ProofConfiguration ν)) : Nat := ...
def configurationGraph (F : CNF ν) := ...
```

You should expect proofs using:
- induction on traces,
- `rcases` on `ConfigStep`,
- `by_contra` for bottleneck theorems,
- multi-step `calc` for inequalities over `Nat`,
- explicit finite combinatorics over `Finset`.

Avoid any theorem whose proof is just decision procedure brute force unless the theorem itself encodes a serious structural fact.

---

## Algorithmic Deliverable

You must produce a **verified algorithm** that computes or bounds clause space for small CNFs via configuration search.

Minimum target:
- a function that explores the configuration graph up to a space bound `s`,
- a correctness theorem:
  - if it returns `false`, no refutation exists within space `s`,
  - if it returns `true`, it extracts a witness trace.

Suggested Lean signature:
```lean
def boundedSpaceRefutable
    {ν : Type} [Fintype ν] [DecidableEq ν]
    (F : CNF ν) (s : Nat) : Bool := ...

theorem boundedSpaceRefutable_sound
    (F : CNF ν) (s : Nat) :
    boundedSpaceRefutable F s = true →
    ∃ π, IsConfigurationRefutation F π ∧ configurationSpace π ≤ s := by
  ...

theorem boundedSpaceRefutable_complete
    (F : CNF ν) (s : Nat) :
    boundedSpaceRefutable F s = false →
    ¬ ∃ π, IsConfigurationRefutation F π ∧ configurationSpace π ≤ s := by
  ...
```

This is not optional. A theorem without an executable search procedure leaves the scientific loop incomplete.

---

## Demo / Experimental Program

Your `demo.py` must:
1. construct small narrow-PHP or related bounded-width unsatisfiable CNFs,
2. compute exact or lower-bounded clause space by configuration search,
3. visualize the configuration graph or bottleneck frontier,
4. print width, initial width, and computed space side-by-side.

Minimum experiments:
- verify small cases `n ≤ 6`,
- compare standard PHP encoding vs narrow encoding,
- demonstrate the width-gap lower bound and whether it is tight.

---

## Revolutionary Significance

If you succeed, this project will do more than extend a proof-complexity library.

It will:
- create the first formal **state-space semantics** for resolution memory,
- connect SAT lower bounds to **graph bottlenecks** and **pebbling-style memory barriers**,
- provide verified small-scale experiments for **memory-aware SAT solving**,
- open a route to formalizing **time-space tradeoffs** inside Lean.

Application keywords:
**SAT solving, proof complexity, clause space, width-space tradeoffs, configuration graphs, graph searching, pebbling games, pathwidth, memory complexity, algorithmic verification, certified search, bounded-memory reasoning**

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean file(s)** containing:
   - at least one novel definition,
   - at least 3 nontrivial theorems with deep proof tactics,
   - at least one cross-domain theorem.

2. **`FUTURE_DIRECTIONS.md`**
   - 3–5 falsifiable scientific hypotheses,
   - each with a clear computational or formal test that could refute it.

3. **`RESEARCH_PAPER.md`**
   - fully standalone,
   - explains definitions, main theorems, proof ideas, significance, and next questions,
   - understandable without reading the code.

4. **`ARTICLE.md`**
   - Scientific American style,
   - explain why proof memory matters and how “proofs as trajectories through memory states” changes the story.

5. **A verified algorithm or computational method**
   - not just theorem statements,
   - with formal soundness/completeness or certified lower-bound guarantees.

6. **`demo.py`**
   - interactive or script-based demonstration of the theorem/algorithm on small instances.

---

## Final Standard

Do not settle for “solid extension.” The true target is:

> **Resolution proofs as memory-constrained dynamical systems**, with certified bottlenecks and experimentally testable lower bounds.

That is a field-opening perspective. Build the formal bridge so future work can pass from width, to space, to graph geometry, to computational memory lower bounds.

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
