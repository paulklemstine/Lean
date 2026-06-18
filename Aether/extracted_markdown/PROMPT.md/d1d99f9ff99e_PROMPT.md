Soli Deo Gloria

## Assignment: Direction 2 — Separator-Aware Forgetting Dominates Activity-Only Forgetting

**Mode:** `prove` + `discover`

Build a mathematically serious theory of **separator-aware clause forgetting** that elevates the existing pathwidth/frontier lemmas into a structural domination theorem. The goal is not merely to propose a heuristic, but to prove that a path-decomposition-aware retention policy has a canonical optimality property among all local policies that preserve future interaction information across a cut.

You should work from the catalog results in:

- `Pythagorean/ClauseInteractionPathwidth/Theorems.lean`
  - especially `activeFrontier_card_le_width_succ`
  - and `retainAtCut_preserves_frontier_edges`

and turn them into a new theory showing that **frontier/separator retention is the unique minimal information-preserving policy at a cut**, while activity-only forgetting lacks any such structural guarantee.

---

## Core Vision

The current catalog already says two important things:

1. the active frontier is small, bounded by width;
2. retaining clauses at the cut preserves frontier-edge information.

That is the beginning, not the end.

The breakthrough theorem to aim for is:

> **Among all cut-local clause retention policies that preserve every future cross-cut interaction detectable from the clause interaction graph, the separator-aware policy is cardinality-minimal.**

This is the right theorem because it converts a heuristic into a theorem of **optimal compression under structural constraints**. If you can prove this cleanly, then path-respecting forgetting becomes not just “motivated by width,” but **the mathematically canonical minimal-memory policy** compatible with preserving downstream interaction structure.

This opens a field-level bridge between:

- **SAT solver architecture**: clause database reduction with structural guarantees,
- **graph minor / decomposition theory**: separators and path decompositions,
- **information theory**: minimal sufficient interface across a cut,
- **systems/streaming algorithms**: smallest retained state preserving future behavior.

Application keywords: **SAT solving, clause database management, pathwidth, separators, graph algorithms, minimal sufficient state, information-preserving compression, solver memory optimization, algorithm engineering, streaming interfaces**.

---

## New Definitions You Should Introduce

You must define at least one genuinely new concept not already present in the catalog. The right ones are:

### 1. Cut-Local Retention Policy
A policy that, at a cut index `i` in a path decomposition, chooses a set of retained clauses based only on the past side and the bag/frontier data at the cut.

Suggested Lean-facing shape:
```lean
def CutPolicy
  (α : Type _) [DecidableEq α]
  (G : SimpleGraph α) :=
  ℕ → Finset α
```
or, if the decomposition is explicit:
```lean
def CutPolicy
  (α : Type _) [DecidableEq α]
  (bags : ℕ → Finset α) :=
  ℕ → Finset α
```

### 2. Interaction-Preserving at a Cut
A policy is interaction-preserving if every edge from a past clause to a future clause remains represented through retained clauses at the cut.

This should formalize the idea that the retained set contains enough clauses to mediate all future interactions crossing the cut.

### 3. Separator-Minimal Policy
A policy is separator-minimal if it is interaction-preserving and no strictly smaller retained set is interaction-preserving.

This is the key new mathematical object.

### 4. Activity-Blind / Structure-Blind Policy
A formal abstraction of policies that do not use decomposition/separator information. You may not be able to prove strong negative theorems for all such policies, but even a carefully chosen restricted class can support a sharp impossibility result or counterexample family.

---

## Precise Theorem Targets

You must prove at least **3 nontrivial theorems**, and at least one should be a genuine cross-domain theorem.

Below are precise targets. Adjust names/types to fit the existing catalog definitions, but keep the mathematical content.

---

### Theorem 1: Frontier retention is interaction-preserving

This should extend the existing edge-preservation theorem into a full interface theorem.

#### Mathematical statement
Let `G` be a clause interaction graph equipped with a path decomposition `B : Fin n → Finset α`. For a cut `i`, let `Past(i)` be the vertices appearing in bags up to `i`, `Future(i)` those appearing after `i`, and `Frontier(i) := Past(i) ∩ Future(i)`. Then retaining `Frontier(i)` is sufficient to preserve all cross-cut interactions: for every edge `(u,v)` with `u ∈ Past(i)` and `v ∈ Future(i)`, at least one endpoint lies in `Frontier(i)`; equivalently, every cross-cut edge is incident to the retained interface.

This is the real separator statement behind the heuristic.

#### Lean 4 target signature sketch
```lean
theorem frontier_interaction_preserving
  {α : Type _} [DecidableEq α]
  {G : SimpleGraph α}
  {n : ℕ}
  (B : Fin n → Finset α)
  (hpd : IsPathDecomposition G B)
  (i : Fin n) :
  InteractionPreservingAtCut G B i (frontierAtCut B i)
```

If `IsPathDecomposition` or `frontierAtCut` are not yet defined in exactly this form, define the appropriate local version and prove the theorem there.

#### Proof strategy
1. **Decomposition interval argument**: Use the path decomposition axiom that the bags containing a fixed vertex form an interval. For an edge crossing the cut, the standard path decomposition edge axiom gives a bag containing both endpoints; deduce one endpoint must appear on both sides of the cut, hence belongs to the frontier.
2. **Cut contradiction route**: Assume a cross-cut edge has both endpoints outside the frontier. Then one endpoint is entirely past and the other entirely future; show no bag can contain both, contradicting the edge-cover axiom.
3. **Most promising**: Strategy 2 is likely the cleanest in Lean because it reduces directly to `by_contra` plus interval-connectedness facts.

---

### Theorem 2: Frontier retention is cardinality-minimal among interaction-preserving policies

This is the central breakthrough theorem.

#### Mathematical statement
For every cut `i`, the frontier set is a minimum-cardinality interaction-preserving retained set. In stronger form: any interaction-preserving retained set `R` must contain `Frontier(i)`, hence
\[
|Frontier(i)| \le |R|.
\]

This is much stronger than a width upper bound: it says the frontier is not just small, but **unavoidably necessary**.

#### Lean 4 target signature sketch
```lean
theorem frontier_subset_of_any_interaction_preserving
  {α : Type _} [DecidableEq α]
  {G : SimpleGraph α}
  {n : ℕ}
  (B : Fin n → Finset α)
  (hpd : IsPathDecomposition G B)
  (i : Fin n)
  {R : Finset α}
  (hR : InteractionPreservingAtCut G B i R) :
  frontierAtCut B i ⊆ R
```

and then derive:

```lean
theorem card_frontier_le_card_of_interaction_preserving
  {α : Type _} [DecidableEq α]
  {G : SimpleGraph α}
  {n : ℕ}
  (B : Fin n → Finset α)
  (hpd : IsPathDecomposition G B)
  (i : Fin n)
  {R : Finset α}
  (hR : InteractionPreservingAtCut G B i R) :
  (frontierAtCut B i).card ≤ R.card
```

#### Proof strategy
1. **Witness edge method**: For any frontier vertex `x`, prove there exists a past witness `p` and future witness `f` whose cross-cut interaction forces `x` to be retained by any interaction-preserving policy. This is strongest if your interaction-preserving definition encodes exact representation of all cross-cut incidences.
2. **Separator necessity method**: Show `Frontier(i)` is exactly the vertex separator between strictly-past and strictly-future vertices. Then any interaction-preserving set must be a separator, and every such separator contains the frontier. This is conceptually elegant and graph-theoretic.
3. **Most promising**: Strategy 2 is the real breakthrough. Recast the frontier as the canonical cut separator induced by interval geometry of path decompositions. Then the theorem becomes a structural statement about path decompositions, not just SAT.

This theorem is what transforms “separator-aware forgetting” into a mathematically inevitable policy.

---

### Theorem 3: Width yields a universal memory bound for separator-aware forgetting

This should combine your new minimality theorem with the catalog cardinality bound.

#### Mathematical statement
For every cut `i`, every cardinality-minimal interaction-preserving policy retains at most `pw(G)+1` clauses, and the frontier policy achieves this bound whenever the frontier saturates the bag width.

At minimum:
\[
|frontier(i)| \le k+1
\]
whenever the decomposition has width `k`.

#### Lean 4 target signature sketch
```lean
theorem card_minimal_retained_le_width_succ
  {α : Type _} [DecidableEq α]
  {G : SimpleGraph α}
  {n k : ℕ}
  (B : Fin n → Finset α)
  (hpd : IsPathDecompositionWidth G B k)
  (i : Fin n) :
  (frontierAtCut B i).card ≤ k + 1
```

or derive it from the catalog theorem:

```lean
theorem card_minimal_retained_le_width_succ'
  ...
  : minimalRetainedCard G B i ≤ k + 1
```

#### Proof strategy
1. Invoke `activeFrontier_card_le_width_succ` directly after proving your `frontierAtCut` matches the catalog notion.
2. Use `calc` chains to move from minimality to frontier cardinality to width bound.
3. This theorem should not be the star, but it is the bridge from structure to practical memory guarantees.

---

## Cross-Domain Theorem Requirement

You must include at least one theorem that genuinely connects this domain to another mathematical domain.

The strongest option is an **information-theoretic abstraction**:

### Theorem 4: Frontier is a minimal sufficient interface across the cut

Interpret the cut as a communication channel from past to future. The retained set is a state summary. Then the frontier is the minimal sufficient state preserving all future graph interactions.

You can formalize this combinatorially without requiring measure theory:

#### Mathematical statement
Define two past assignments/configurations to be future-equivalent at cut `i` if they induce the same interaction pattern on all future vertices. Then this equivalence relation factors through the frontier projection. In particular, the frontier labels determine the future interaction class.

This is a finite-information theorem: the frontier is a sufficient statistic for future interaction structure.

#### Lean 4 target signature sketch
Something like:
```lean
def FutureEquivalentAtCut ... : Prop := ...

theorem frontier_projection_sufficient
  {α β : Type _} [DecidableEq α] [DecidableEq β]
  ...
  (i : Fin n) :
  SufficesForFutureInteraction G B i (frontierProjection B i)
```

If this exact formalization becomes too heavy, prove a graph-theoretic proxy:

```lean
theorem frontier_separates_past_from_future
  {α : Type _} [DecidableEq α]
  {G : SimpleGraph α}
  ...
  (i : Fin n) :
  VertexSeparator G (strictPast B i) (strictFuture B i) (frontierAtCut B i)
```

This is already a cross-domain bridge:
- graph decomposition theory,
- information compression,
- solver-state summarization.

#### Why this matters
This theorem reframes clause forgetting as **lossy vs lossless state compression**, opening connections to:
- streaming algorithms,
- communication complexity,
- Markov blankets in probabilistic graphical models,
- systems architecture for incremental SAT.

---

## Negative / Separation Result Against Activity-Only Policies

Do not overclaim empirical solver superiority as a theorem. Instead, prove a sharp structural limitation.

### Theorem 5: There exists a bounded-pathwidth family where a structure-blind local policy fails separator preservation

Construct a family of graphs/decompositions and a policy class that ignores separator membership, and show such a policy can delete a frontier vertex whose removal destroys preservation of some cross-cut interaction.

#### Lean 4 target signature sketch
```lean
theorem exists_family_structure_blind_policy_fails
  :
  ∃ (α : Type) (_ : Fintype α) [DecidableEq α]
    (G : SimpleGraph α) (B : Fin n → Finset α) (i : Fin n) (R : Finset α),
    IsPathDecompositionWidth G B k ∧
    StructureBlindAtCut G B i R ∧
    ¬ InteractionPreservingAtCut G B i R
```

If fully polymorphic existence is awkward, instantiate a concrete finite graph family.

#### Proof strategy
1. Build a path-like graph with one crucial frontier vertex mediating all cross-cut edges.
2. Define a structure-blind retained set omitting that vertex.
3. Use explicit graph reasoning and `rcases` to show interaction preservation fails.

This is a mathematically honest way to formalize “activity-only forgetting has no structural guarantee” without pretending to model GLUCOSE internals in Lean.

---

## Recommended Proof Architecture

### Strategy A: Canonical separator theory on path decompositions
- Define `strictPast`, `strictFuture`, `frontierAtCut`.
- Prove the frontier is a separator.
- Prove it is contained in every interaction-preserving retained set.
- Then derive cardinality minimality and width bounds.

**Why promising:** clean, conceptual, reusable, likely to generate multiple theorems with shared lemmas.

### Strategy B: Edge-preservation-first development
- Start from `retainAtCut_preserves_frontier_edges`.
- Strengthen “preserves frontier edges” into “preserves all cross-cut interactions.”
- Define minimality relative to this stronger predicate.
- Use finite-set cardinality arguments.

**Why promising:** closest to the catalog and may minimize engineering overhead.

### Strategy C: Interval model of vertex occurrences
- Formalize that each vertex appears on an interval of bag indices.
- Characterize frontier vertices as those whose intervals cross the cut.
- Show these interval-crossers form the unique minimal interface.

**Why promising:** most mathematically beautiful; if successful, it yields a reusable decomposition calculus for later work on treewidth-aware solver design.

**Best path overall:** combine **B → C**. Start from the catalog theorem to get momentum, then repackage the result through interval/separator language to obtain the conceptual breakthrough theorem.

---

## Computational / Algorithmic Deliverable

You must not stop at theorem statements. Produce a verified algorithmic artifact:

### Verified algorithm
Define and verify a procedure that computes the retained set at a cut from decomposition data:
```lean
def separatorAwareRetain
  {α : Type _} [DecidableEq α]
  (B : Fin n → Finset α) (i : Fin n) : Finset α := ...
```

Then prove:
1. correctness: it is interaction-preserving;
2. minimality: no smaller retained set is interaction-preserving;
3. width bound: its size is at most `k+1` for width-`k` decompositions.

If feasible, also define a streaming version that updates the retained set incrementally from `i` to `i+1`.

This is the bridge to actual solver engineering.

---

## Empirical / Scientific Conjecture

You should include the following conjecture in a mathematically sharpened form:

### Conjecture (testable, falsifiable)
For industrial SAT instances whose clause interaction graphs admit empirical path decompositions of width at most `k ≤ 50`, the separator-aware forgetting policy based on retaining `frontierAtCut ∪ activeFrontierAtCut` yields:
1. strictly smaller median peak clause-memory than LBD/activity-only forgetting,
2. at most `2x` median runtime overhead,
3. improved memory on at least `60%` of benchmarks.

### Clear computational test
- Implement path-respecting forgetting in **CaDiCaL** or **Kissat** as a database-reduction plugin.
- Approximate path decompositions online or offline.
- At each reduction event, retain clauses in the current separator/frontier interface.
- Evaluate on SAT Competition 2023 industrial benchmarks.
- Report:
  - peak resident memory,
  - learned clause count,
  - runtime,
  - solve rate,
  - decomposition maintenance overhead.

### Stronger follow-up hypothesis
Approximate separator-awareness using cheap online graph sketches will recover most of the memory benefit of exact path-aware forgetting, implying that **structural awareness, not exact decomposition optimality, is the key variable**.

This is falsifiable: if approximate methods fail to track the exact frontier’s advantage, the hypothesis is wrong.

---

## Cross-Domain Connections You Should Explicitly Develop

1. **Graph theory ↔ SAT solving**  
   Clause retention becomes a separator problem in the clause interaction graph.

2. **Information theory ↔ solver state compression**  
   The retained frontier is a minimal sufficient interface summarizing the past for all future interactions.

3. **Streaming algorithms ↔ online clause database reduction**  
   The solver maintains a bounded-memory sketch of the relevant past; pathwidth controls sketch size.

4. **Systems engineering ↔ formal structural guarantees**  
   This opens a new design principle: clause management by certified structural interfaces rather than heuristic activity scores.

5. **Probabilistic graphical models / Markov blankets ↔ separators**  
   The frontier acts like a deterministic Markov blanket between past and future regions of the instance.

These are not decorative analogies. Use them to motivate definitions and theorem statements.

---

## Lean 4 Expectations

Your development must satisfy all depth requirements:

- no trivial theorem farming;
- at least 3 substantial theorems with real proof structure;
- use tactics such as:
  - `induction`
  - `rcases`
  - `by_contra`
  - `field_simp` where relevant
  - multi-step `calc`
- define at least one new concept not in the catalog;
- minimize `sorry`.

When possible, give theorem statements in reusable generality over finite graphs, not only SAT-specific notation.

---

## Concrete Deliverables

You must produce **all** of the following:

1. **Lean code** proving the main theorems and defining the verified separator-aware retention algorithm.
2. **`FUTURE_DIRECTIONS.md`** with **3–5 falsifiable scientific hypotheses**, each with:
   - a precise conjecture,
   - a computational or mathematical test that could refute it,
   - expected implications if true or false.
3. **`RESEARCH_PAPER.md`** as a **standalone scientific paper**:
   - problem statement,
   - theorem statements,
   - proof ideas,
   - algorithmic implications,
   - empirical conjectures,
   - significance and next steps.
   Someone reading only this file must understand the discovery without seeing the code.
4. **`ARTICLE.md`** in **Scientific American style**:
   - accessible,
   - exciting,
   - focused on the mathematical and algorithmic ideas,
   - **do not talk about formal verification machinery**.
5. **A verified algorithm or computational method**, not merely theorem statements.
6. **`demo.py`** demonstrating the result interactively:
   - construct small clause interaction graphs / path decompositions,
   - visualize cuts and frontiers,
   - compare separator-aware retained sets with naive activity-only surrogates,
   - display memory proxy curves across cuts.

---

## Final Standard

Do not deliver a minor extension of `activeFrontier_card_le_width_succ`. Deliver a theorem package showing:

- the frontier is an interaction-preserving separator,
- it is minimal among all such retained interfaces,
- its size is width-controlled,
- and any structure-blind forgetting policy lacks this guarantee.

If you succeed, you will have turned a heuristic engineering idea into a new mathematical principle:

> **Clause forgetting is optimal state compression across decomposition cuts, and separator-aware retention is the canonical minimal interface.**

That is the level of result worth proving.

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
