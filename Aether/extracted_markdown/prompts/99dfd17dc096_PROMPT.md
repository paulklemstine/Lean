Soli Deo Gloria

## Assignment: Direction 3 — Minor Monotonicity of Defect, Upgraded to a Structural Deletion Calculus

Do not merely verify a local monotonicity lemma. Turn the defect into a bona fide deletion-sensitive invariant with a sharp structural classification. The goal is to show that the defect is not just nonnegative, but behaves like a graph-complexity functional sitting at the interface of cycle rank, connectivity loss, and minor theory.

Build directly on:
- `Pythagorean/TropicalBridge/DefectTheory.lean`
  - especially the catalog notions around `inducedCycleRank` and `structuralDefect`

Your task is to prove a **package of theorems**, not a single inequality.

---

## Core Vision

The conjectured monotonicity
\[
\delta(H,q,S)\le \delta(G,q,S)
\]
for deletion of an edge internal to \(G[S]\) is already interesting. But the real breakthrough is to prove the **exact deletion formula**
showing that the defect drops by exactly one when the deleted edge lies on a cycle of \(G[S]\), and remains unchanged exactly when it is a bridge.

This upgrades defect from a passive statistic to a **minor-monotone structural detector**. If formalized cleanly, this opens a path from defect theory to:
- graph minor theory,
- graphic matroids,
- topological cycle-space complexity,
- and algorithmic graph decomposition.

The key scientific point: the defect should behave as a localized first Betti correction term, with the root-sensitive component count \(\kappa\) frozen under internal deletions. That is the conceptual bridge.

---

## Precise Theorem Targets

You should introduce at least one genuinely new definition capturing “internal edge deletion relative to \(S\)” and “bridge inside the induced subgraph on \(S\).”

### New definitions to add
Define a structure/concept not already in the catalog, for example:

- `InternalEdgeDeletion (G q S e)` meaning:
  1. `e ∈ E(G)`
  2. both endpoints of `e` lie in `S`
  3. `q` is not an endpoint of `e`

- `IsSBridge (G S e)` meaning `e` is a bridge in the induced subgraph `G.induce S`

or an equivalent edge-removal predicate formulated in the style of the existing file.

This novelty is mandatory: do not just reuse an ad hoc conjunction everywhere.

---

## Exact theorem statement package

Let \(H = G - e\), where \(e\) is an edge with both endpoints in \(S\) and not incident to \(q\). Write \(\delta(G,q,S)\) for the structural defect from the catalog.

You should target the following theorem suite.

### Theorem 1: Internal deletion preserves the root-side component term
If \(e\) is internal to \(S\) and not incident to \(q\), then the \(\kappa\)-term in the defect formula is unchanged.

Informally:
\[
\kappa(H,q,S)=\kappa(G,q,S).
\]

This is the hidden invariant making the entire theory work.

### Theorem 2: Exact deletion law for defect
For internal deletion \(H = G - e\),
\[
\delta(H,q,S)=
\begin{cases}
\delta(G,q,S) & \text{if } e \text{ is a bridge of } G[S],\\
\delta(G,q,S)-1 & \text{if } e \text{ is not a bridge of } G[S].
\end{cases}
\]

Equivalent compressed form:
\[
\delta(H,q,S)=\delta(G,q,S)-\mathbf{1}_{\neg \mathrm{IsSBridge}(G,S,e)}.
\]

This is stronger than monotonicity and is the real target.

### Theorem 3: Minor monotonicity of defect under internal edge deletion
As a corollary,
\[
\delta(H,q,S)\le \delta(G,q,S).
\]

### Theorem 4: Equality characterization
\[
\delta(H,q,S)=\delta(G,q,S)
\iff e \text{ is a bridge of } G[S].
\]

### Theorem 5: Iterated deletion / cycle-basis interpretation
If \(F\subseteq E(G[S])\) is a family of internal edges none incident to \(q\), and \(H = G - F\), then under suitable order-independent formulation,
\[
\delta(H,q,S)=\delta(G,q,S)-r,
\]
where \(r\) is the number of deleted edges that were non-bridges at the moment of deletion, equivalently the drop in cycle rank of \(G[S]\).

A particularly elegant version is:
\[
\delta(H,q,S)=\delta(G,q,S)-\big(\beta_1(G[S])-\beta_1(H[S])\big).
\]

This is the statement that turns the one-edge lemma into a structural calculus.

---

## Suggested Lean 4 theorem signatures

Use the actual names from `DefectTheory.lean` once inspected, but the targets should look essentially like the following.

If the catalog already defines `structuralDefect`, `inducedCycleRank`, and a component-count term, adapt accordingly.

```lean
def IsInternalEdge (G : SimpleGraph V) (q : V) (S : Set V) (e : Sym2 V) : Prop := ...
def IsSBridge (G : SimpleGraph V) (S : Set V) (e : Sym2 V) : Prop := ...
def deleteEdge' (G : SimpleGraph V) (e : Sym2 V) : SimpleGraph V := ...
```

Then theorem targets of the form:

```lean
theorem kappa_internal_edge_delete_invariant
    {G : SimpleGraph V} {q : V} {S : Set V} {e : Sym2 V}
    (he : IsInternalEdge G q S e) :
    kappaTerm (deleteEdge' G e) q S = kappaTerm G q S
```

```lean
theorem inducedCycleRank_delete_internal_edge
    {G : SimpleGraph V} {S : Set V} {e : Sym2 V}
    (he : IsInternalEdge G q S e) :
    inducedCycleRank (deleteEdge' G e) S =
      inducedCycleRank G S - if IsSBridge G S e then 0 else 1
```

```lean
theorem structuralDefect_delete_internal_edge
    {G : SimpleGraph V} {q : V} {S : Set V} {e : Sym2 V}
    (he : IsInternalEdge G q S e) :
    structuralDefect (deleteEdge' G e) q S =
      structuralDefect G q S - if IsSBridge G S e then 0 else 1
```

```lean
theorem structuralDefect_minor_monotone_internal_delete
    {G : SimpleGraph V} {q : V} {S : Set V} {e : Sym2 V}
    (he : IsInternalEdge G q S e) :
    structuralDefect (deleteEdge' G e) q S ≤ structuralDefect G q S
```

```lean
theorem structuralDefect_delete_internal_edge_eq_iff
    {G : SimpleGraph V} {q : V} {S : Set V} {e : Sym2 V}
    (he : IsInternalEdge G q S e) :
    structuralDefect (deleteEdge' G e) q S = structuralDefect G q S
      ↔ IsSBridge G S e
```

For the iterated form:

```lean
theorem structuralDefect_delete_edge_set
    {G : SimpleGraph V} {q : V} {S : Set V} {F : Finset (Sym2 V)}
    (hF : ∀ e ∈ F, IsInternalEdge G q S e) :
    structuralDefect (deleteEdgeSet G F) q S =
      structuralDefect G q S -
        (inducedCycleRank G S - inducedCycleRank (deleteEdgeSet G F) S)
```

If exact subtraction on naturals becomes awkward, use an additive reformulation:
```lean
structuralDefect (deleteEdgeSet G F) q S + inducedCycleRank G S =
  structuralDefect G q S + inducedCycleRank (deleteEdgeSet G F) S
```
This may be the most Lean-friendly statement.

---

## Why this would be a breakthrough

If proven cleanly, this says defect is not an arbitrary graph statistic but a **cycle-sensitive minor-monotone quantity** with exact deletion behavior. That is a serious structural theorem.

It would imply:
- defect detects whether internal edge deletion removes homological complexity;
- bridges are exactly the defect-neutral deletions;
- non-bridge deletions strictly simplify the defect by one unit;
- defect can be interpreted as a rooted correction of cycle rank.

This opens a field of “defect calculus” analogous to deletion-contraction recurrences in matroid theory, but rooted and subset-sensitive.

The matroid connection is especially important: in a graphic matroid, an edge is a coloop iff it is a bridge, while non-bridge edges contribute to circuits. Your theorem is effectively saying defect responds exactly to deletion of circuit-participating edges. That is not just graph theory; it is a matroidal law in disguise.

---

## Proof architecture: 3 viable strategies

### Strategy A: Direct decomposition through the defect formula
Most promising if `structuralDefect` is already defined as a sum/difference of established invariants.

1. Unfold `structuralDefect` into the cycle-rank part plus the root-sensitive connectivity term.
2. Prove the connectivity term is unchanged under deleting an edge entirely inside `S` and away from `q`.
   - This will likely require `rcases` on component witnesses and a careful argument that deleting an internal edge in `G[S]` does not alter the connected components of the relevant graph used to define `κ`.
3. Prove the induced cycle rank changes by:
   - `0` if `e` is a bridge of `G[S]`,
   - `1` otherwise.
4. Reassemble with `calc` reasoning.

Why this is best:
- It directly matches the catalog framing.
- It yields exact formulas, not just inequalities.
- It should scale to the iterated deletion theorem.

### Strategy B: Euler characteristic / Betti-number proof
Best if `inducedCycleRank` is defined using
\[
\beta_1 = |E| - |V| + c
\]
or an equivalent finite-combinatorial formula.

1. Express `inducedCycleRank G S` as
   \[
   e(G[S]) - |S| + c(G[S]).
   \]
2. Under deletion of one internal edge:
   - edge count decreases by `1`,
   - vertex count is unchanged,
   - number of components increases by `1` iff the deleted edge is a bridge.
3. Therefore the cycle rank stays the same for bridges and drops by `1` otherwise.
4. Combine with invariance of the `κ` term.

This is mathematically beautiful because it reveals defect as a topological invariant:
it is controlled by the first Betti number of the induced subgraph. This is the best route for cross-domain significance.

### Strategy C: Graphic matroid interpretation
Most visionary, though possibly heavier to formalize.

1. Interpret edges of `G[S]` as elements of the graphic matroid.
2. Show deleting a bridge leaves matroid rank/cycle nullity unchanged in the relevant way, while deleting a non-coloop circuit edge reduces nullity by one.
3. Translate nullity drop into `inducedCycleRank` drop.
4. Conclude the defect formula.

This route is powerful because it suggests future extension to regular matroids, simplicial complexes, and higher-dimensional defect theories. Use it at least in `RESEARCH_PAPER.md` and `FUTURE_DIRECTIONS.md`, even if the Lean proof uses Strategy A or B.

---

## Deep proof tactics requirement

Your file must contain at least 3 nontrivial theorems with real proof structure. In particular, ensure the proofs visibly use some combination of:
- `induction`
- `rcases`
- `by_contra`
- `field_simp` if any rationalized combinatorial identities arise
- multi-step `calc`
- nontrivial rewrites and case splits on bridge/non-bridge

Good candidates:
1. `kappa_internal_edge_delete_invariant`
2. `inducedCycleRank_delete_internal_edge`
3. `structuralDefect_delete_internal_edge_eq_iff`
4. `structuralDefect_delete_edge_set` by induction on a `Finset` of deleted edges

The iterated deletion theorem is an ideal place for `Finset.induction`.

---

## Cross-domain connections you must make explicit

Include at least one theorem or formal lemma that clearly bridges to another domain.

### Option 1: Matroid theory
State and, if feasible, prove a lemma expressing that the defect drop equals the loss of cycle nullity in the graphic matroid of `G[S]`.

Even if Mathlib’s matroid API is too heavy for a full equivalence theorem, you should at minimum formulate the correspondence in `RESEARCH_PAPER.md` and prove a graph-side lemma mirroring matroid nullity behavior.

### Option 2: Algebraic topology
Interpret `inducedCycleRank` as the first Betti number of the 1-dimensional CW complex underlying `G[S]`.
Then your exact deletion law becomes a statement about homological complexity under cell deletion:
- deleting a 1-cell on a cycle lowers \( \beta_1 \) by 1,
- deleting a bridge leaves \( \beta_1 \) unchanged.

This is a genuine graph theory ↔ topology bridge.

### Option 3: Algorithmic complexity / network science
Derive a verified computational method that identifies “defect-neutral” versus “defect-reducing” edge deletions, giving an algorithmic simplification rule for rooted network complexity.

This can be turned into a pruning algorithm:
repeatedly delete non-bridge internal edges to strictly reduce defect until an `S`-forest remains.

---

## Stronger theorem to aim for if feasible

Do not stop at one-edge deletion. If possible, prove the forest reduction theorem:

\[
\delta(G,q,S) = \delta(T,q,S) + \beta_1(G[S]),
\]
where \(T\) is any graph obtained from \(G\) by deleting a cycle basis worth of internal non-bridge edges so that \(T[S]\) is a forest.

This would show defect decomposes into:
- a tree-level rooted complexity term, plus
- pure cycle complexity.

That decomposition is conceptually major.

A Lean-flavored target:
```lean
theorem structuralDefect_forest_reduction
    {G : SimpleGraph V} {q : V} {S : Set V} :
    ∃ T : SimpleGraph V,
      IsForestOn T S ∧
      structuralDefect G q S =
        structuralDefect T q S + inducedCycleRank G S
```
Adjust the exact statement to match available APIs.

---

## Computational deliverable: verified algorithm

You must produce a verified computational method, not just theorem statements.

### Required algorithm
Implement a procedure that, given finite connected `G`, `q`, `S`, and an internal edge `e`,
computes whether deleting `e` preserves defect or lowers it by one.

Specification:
- output `0` iff `e` is an `S`-bridge,
- output `1` iff `e` is not an `S`-bridge,
- prove that
  \[
  \delta(G,q,S)-\delta(G-e,q,S)
  \]
  equals this output.

This is a genuine certified algorithmic classifier.

### Demo requirement
`demo.py` should:
1. enumerate connected graphs with `n ≤ 7`,
2. loop over roots `q`,
3. loop over subsets `S`,
4. loop over eligible internal edges,
5. compute `δ(G,q,S)` and `δ(G-e,q,S)`,
6. empirically test:
   - monotonicity,
   - equality iff bridge,
   - exact drop formula,
7. print summary statistics and counterexamples if any appear.

If exhaustive enumeration is too slow in Python, use:
- all graphs up to `n ≤ 6` exhaustively,
- random connected samples for `n = 7`,
but clearly document the boundary.

---

## Falsifiable conjectures for FUTURE_DIRECTIONS.md

You must include 3–5 testable hypotheses. At least one should directly extend this work. Strong candidates:

### Hypothesis 1: Full minor monotonicity under internal edge contractions
If an edge \(e\subseteq S\) not incident to \(q\) is contracted, then the defect does not increase:
\[
\delta(G/e,q,\pi(S)) \le \delta(G,q,S).
\]
Test: exhaustive search on small graphs, tracking image of \(S\) under contraction.

### Hypothesis 2: Forest normalization uniqueness
The final defect after deleting any maximal family of cycle-killing internal edges is independent of deletion order.
Test: compute all maximal deletion sequences on small graphs.

### Hypothesis 3: Submodularity in \(S\)
For fixed \(G,q\),
\[
\delta(G,q,S\cup T)+\delta(G,q,S\cap T)\le \delta(G,q,S)+\delta(G,q,T).
\]
Test: exhaustive subset search on small graphs.

### Hypothesis 4: Matroidal extension
There exists a matroid-theoretic defect on rooted subsets whose deletion law specializes to the graph theorem.
Test: evaluate candidate formulas on small graphic matroids and compare with graph defect.

### Hypothesis 5: Tropical/topological bridge
The defect equals a tropical rank deficiency of a rooted incidence object associated to \(G[S]\).
Test: compute both quantities for small graphs and search for exact agreement.

Each hypothesis must be falsifiable, with a concrete computational protocol.

---

## Application keywords

Use these explicitly in the scientific documents:

- graph minor monotonicity
- cycle rank
- first Betti number
- bridge detection
- graphic matroid
- nullity
- deletion-contraction calculus
- rooted graph complexity
- topological graph invariants
- certified graph simplification
- network pruning
- combinatorial topology
- structural graph theory
- exact defect drop law

---

## Deliverables (ALL mandatory)

Produce all of the following:

1. **Lean file(s)** with:
   - at least 3 substantial theorems,
   - at least 1 new definition/structure,
   - minimized `sorry`,
   - proofs using deep tactics and multi-step reasoning.

2. **`FUTURE_DIRECTIONS.md`**
   - 3–5 falsifiable scientific hypotheses,
   - each with a concrete computational test,
   - clearly tied to the theorem package proved here.

3. **`RESEARCH_PAPER.md`**
   - standalone scientific exposition,
   - must explain the exact deletion law, why it matters, and what new field it opens,
   - should emphasize the graph minor / matroid / topology triangle.

4. **`ARTICLE.md`**
   - Scientific American style,
   - engaging and accessible,
   - focus on the mathematics and significance,
   - taboo: do **not** focus on formal verification machinery.

5. **Verified algorithm / computational method**
   - classifier for defect-neutral vs defect-reducing internal deletions,
   - with correctness theorem.

6. **`demo.py`**
   - interactive or script-based demonstration of exhaustive small-graph testing,
   - reports whether the conjecture survives all tests.

---

## Final standard

Do not deliver a routine extension. Deliver a structural theorem package showing that defect admits an exact deletion law and therefore behaves like a rooted cycle-nullity invariant. If you succeed, this transforms defect theory from a catalog definition into the beginning of a genuine minor-sensitive complexity theory.

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
