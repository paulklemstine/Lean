Soli Deo Gloria

## Assignment: Jones Polynomial Formalization as a Gateway to Certified Quantum Topology

**Mode:** prove

You should not merely encode the textbook definition of the Jones polynomial. The real target is a formally verified **skein-theoretic engine** that turns planar combinatorics into topological and even physical invariants. The breakthrough is to make Lean certify that a state-sum defined from local smoothing rules survives global diagrammatic moves, and then leverage that engine to prove nontrivial detection and computation results. This is the seed of a formalized bridge between **low-dimensional topology, statistical mechanics, and quantum invariants**.

Build on the existing verified theorem

- `adequate_jones_detects_unknot`  
  in `Speculative/Knot/Alternating.lean`

and treat it as a springboard, not the destination. In particular, use it to derive stronger diagram-level corollaries for alternating/adequate classes after you construct the Kauffman bracket and Jones polynomial machinery.

---

## Core Vision

Formalize the **Kauffman bracket state sum** and the **normalized Jones polynomial**, prove their behavior under Reidemeister moves with enough precision to isolate the exact framing anomaly, and then compute explicit knot families in a way that exposes recursive and algorithmic structure. The ideal end product is not “the Jones polynomial exists,” but:

1. a verified algebraic-combinatorial calculus for link diagrams,
2. a proof that normalization removes Reidemeister I dependence,
3. exact certified computations for emblematic knots and torus-knot recurrences,
4. a detection theorem for the unknot in an alternating/adequate regime,
5. a computational pipeline that can experimentally test new conjectures.

---

## Precise Formal Targets

You should introduce a concrete diagram type if needed, but keep the algebraic codomain explicit. A robust choice is to work in Laurent polynomials `LaurentPolynomial ℤ` or a custom finitely supported `ℤ`-coefficient Laurent polynomial type if Mathlib support is insufficient.

### New definitions to introduce

At least one genuinely new structure/concept should appear. Recommended candidates:

1. `BracketState`  
   A structure encoding a smoothing choice at each crossing and the resulting loop count.
2. `WritheNormalized`  
   A structure packaging a diagram with its writhe and bracket normalization data.
3. `AdequateSpan`  
   A new concept measuring extremal degree span of the bracket/Jones polynomial, designed to connect adequacy to detection and crossing-number lower bounds.
4. `SkeinEvaluableDiagram`  
   A class certifying that a diagram admits recursive decomposition by a chosen crossing order, enabling verified computation.

A promising Lean-style definition sketch:
```lean
structure BracketState (D : LinkDiagram n) where
  smoothing : Fin D.crossingCount → Bool
  loops : ℕ

def kauffmanBracket (D : LinkDiagram n) : LaurentPolynomial ℤ := ...
def writhe (D : OrientedLinkDiagram n) : ℤ := ...
def jonesPolynomial (D : OrientedLinkDiagram n) : LaurentPolynomial ℤ := ...
def bracketSpan (D : LinkDiagram n) : ℤ := ...
def isAlternating (D : OrientedLinkDiagram n) : Prop := ...
def isAdequate (D : OrientedLinkDiagram n) : Prop := ...
```

---

## Theorem Program

You must prove at least 3 substantial theorems with real proof architecture. Here is the minimum ambitious set.

### Theorem 1: Skein expansion / state-sum correctness
Formalize the bracket as a recursive crossing elimination and prove equivalence with the full state sum.

**Mathematical statement**
For every link diagram `D`, the recursively defined Kauffman bracket equals the sum over all smoothing states:
\[
\langle D\rangle
=
\sum_{s \in \{A,B\}^{c(D)}} A^{a(s)-b(s)} \cdot (-A^2-A^{-2})^{\ell(s)-1}.
\]

**Lean 4 type signature sketch**
```lean
theorem kauffmanBracket_eq_stateSum
    {n : ℕ} (D : LinkDiagram n) :
    kauffmanBracket D =
      ∑ s in allStates D,
        monomial (stateExponent s D)
          (stateCoeff s D) := by
  ...
```

If `allStates D` is inconvenient as a `Finset`, define an equivalent finite type of states and sum over it.

**Why this matters**
This theorem is the algebraic heart of the theory: it turns a topological invariant into a certified finite statistical-mechanical partition function. Once formalized, it supports both exact proofs and verified algorithms.

---

### Theorem 2: Framed invariance and normalized Reidemeister invariance
Separate the framed and unframed stories cleanly.

**Mathematical statement**
For link diagrams related by Reidemeister II or III, the bracket is unchanged. Under Reidemeister I, it transforms by the known multiplicative factor. Consequently the normalized Jones polynomial is invariant under all oriented Reidemeister moves:
\[
V_{D}(t)=(-A)^{-3w(D)}\langle D\rangle\big|_{t=A^{-4}}.
\]

**Lean 4 type signature sketch**
```lean
theorem kauffmanBracket_reidemeisterII_invariant
    {n : ℕ} {D₁ D₂ : LinkDiagram n}
    (h : ReidemeisterII D₁ D₂) :
    kauffmanBracket D₁ = kauffmanBracket D₂ := by
  ...

theorem kauffmanBracket_reidemeisterIII_invariant
    {n : ℕ} {D₁ D₂ : LinkDiagram n}
    (h : ReidemeisterIII D₁ D₂) :
    kauffmanBracket D₁ = kauffmanBracket D₂ := by
  ...

theorem kauffmanBracket_reidemeisterI_factor
    {n : ℕ} {D₁ D₂ : OrientedLinkDiagram n}
    (h : ReidemeisterI D₁.toLinkDiagram D₂.toLinkDiagram) :
    kauffmanBracket D₂.toLinkDiagram =
      reidemeisterIFactor h * kauffmanBracket D₁.toLinkDiagram := by
  ...

theorem jonesPolynomial_reidemeister_invariant
    {n : ℕ} {D₁ D₂ : OrientedLinkDiagram n}
    (h : ReidemeisterEquiv D₁ D₂) :
    jonesPolynomial D₁ = jonesPolynomial D₂ := by
  ...
```

**Why this matters**
This is the moment where local rewrite rules become ambient isotopy invariants. In formal mathematics, that passage is notoriously subtle because one must track orientation, writhe, and normalization exactly.

---

### Theorem 3: Certified computations for canonical knots
Prove exact formulas, not just numerical examples.

**Mathematical statements**
For chosen formal encodings of the unknot, trefoil, and figure-eight diagrams:
\[
V_{\text{unknot}}(t)=1,
\quad
V_{\text{trefoil}}(t)=t^{-1}+t^{-3}-t^{-4}
\]
for a consistent handedness convention, and
\[
V_{4_1}(t)=t^2-t+1-t^{-1}+t^{-2}.
\]

**Lean 4 type signature sketch**
```lean
theorem jones_unknot :
    jonesPolynomial unknotDiagram = 1 := by
  ...

theorem jones_trefoil :
    jonesPolynomial trefoilDiagram = trefoilJonesExpected := by
  ...

theorem jones_figureEight :
    jonesPolynomial figureEightDiagram = figureEightJonesExpected := by
  ...
```

You may need to define the expected polynomials explicitly:
```lean
def trefoilJonesExpected : LaurentPolynomial ℤ := ...
def figureEightJonesExpected : LaurentPolynomial ℤ := ...
```

**Why this matters**
These are not toy computations; they certify the entire implementation stack from diagram encoding to normalization. They become benchmark examples for future Khovanov/HOMFLY work.

---

### Theorem 4: Torus-knot recursion or closed family computation
Do not stop at isolated examples. Capture a family.

A strong target is a recurrence for the Jones polynomial of `T(2, 2m+1)` or a closed form if your encoding supports it.

**Mathematical statement**
For a suitable family `torusKnot2Odd m`,
\[
V_{T(2,2m+1)}(t)
=
t^m + t^{m+2} - t^{m+3} + \cdots
\]
or an equivalent recurrence derived from the skein relation.

**Lean 4 type signature sketch**
```lean
theorem jones_torusKnot2Odd_skein_recurrence
    (m : ℕ) :
    jonesPolynomial (torusKnot2Odd (m+1)) =
      torusRecurrenceStep
        (jonesPolynomial (torusKnot2Odd m))
        (jonesPolynomial (torusKnot2Odd (m-1))) := by
  ...
```

**Why this matters**
A family-level theorem turns your development from example checking into a generative machine. It also creates a verified algorithm for whole knot classes.

---

### Theorem 5: Detection of the unknot for alternating/adequate knots
Use the existing theorem as a certified lever.

If you can instantiate adequacy from alternating reduced diagrams, prove a corollary of the form:

**Mathematical statement**
If `D` is a reduced alternating diagram and its Jones polynomial is `1`, then `D` represents the unknot.

**Lean 4 type signature sketch**
```lean
theorem alternating_jones_detects_unknot
    {n : ℕ} {D : OrientedLinkDiagram n}
    (hAlt : isReducedAlternating D)
    (hJones : jonesPolynomial D = 1) :
    IsUnknot D := by
  ...
```

Or, if your infrastructure is diagrammatic rather than isotopy-class based:
```lean
theorem reducedAlternating_jones_eq_one_implies_trivial
    {n : ℕ} {D : OrientedLinkDiagram n}
    (hAlt : isReducedAlternating D)
    (hJones : jonesPolynomial D = 1) :
    diagramRepresentsUnknot D := by
  ...
```

**How to build on the catalog theorem**
Use `adequate_jones_detects_unknot` from `Speculative/Knot/Alternating.lean` by proving that reduced alternating diagrams are adequate in your formalization, or by translating your `isReducedAlternating` predicate into the adequacy predicate expected by that theorem. This is the right kind of bridge theorem: it converts a specialized certified result into a broader conceptual consequence.

**Why this matters**
This is a landmark statement in the formal theory: it makes the Jones polynomial a certified detector on a significant geometric class, not just a computable invariant.

---

## Recommended Proof Strategies

You asked for 2–3 strategy steps; below are multiple proof pathways. Use whichever aligns best with available infrastructure.

### Strategy A: State-sum induction on crossing number
**Best for** `kauffmanBracket_eq_stateSum`, explicit computations, and torus-knot recurrences.

1. Define `crossingCount : LinkDiagram n → ℕ` and recursively resolve one chosen crossing.
2. Prove the recursive bracket formula agrees with partitioning the state space according to the chosen crossing’s smoothing.
3. Use induction on `crossingCount D`, with a multi-step `calc` block to reorganize the finite sum and identify the loop factor.

Why promising: this gives both theorem proofs and executable algorithms from the same recursion.

---

### Strategy B: Local move verification + normalization transport
**Best for** Reidemeister invariance.

1. Prove local bracket identities for the finite list of Reidemeister move templates.
2. Track the writhe change under oriented Reidemeister I by a direct case split.
3. Combine the two via a `calc` proof showing the normalization factor exactly cancels the Reidemeister I anomaly, while II and III preserve both bracket and writhe appropriately.

Why promising: this mirrors the mathematical architecture of the theory and keeps the framing anomaly explicit instead of buried.

---

### Strategy C: Extremal degree / adequacy route
**Best for** unknot detection and cross-domain span results.

1. Define maximal and minimal degree of a nonzero Laurent polynomial and prove degree bounds from the state sum.
2. Show adequate or reduced alternating diagrams realize extremal states uniquely, yielding exact span formulas.
3. Deduce that if the Jones polynomial is trivial, then the span vanishes; combine with adequacy/alternation to force crossing number zero, hence the unknot.

Why promising: this is deeper than direct computation and connects combinatorics of states to geometric complexity.

---

## Deep Proof Tactic Expectations

Your file must include at least 3 theorems whose proofs genuinely use techniques like:

- induction on crossing number or braid/torus parameter,
- `rcases` on Reidemeister move constructors or smoothing states,
- `by_contra` for span/detection arguments,
- `field_simp` or coefficient-ring normalization when translating between `A` and `t=A^{-4}`,
- nontrivial `calc` chains reorganizing Laurent polynomial expressions.

Do not let the main results collapse into definitional equality. If a theorem is only true because you defined both sides the same way, it is not one of the three flagship theorems.

---

## Cross-Domain Connections You Must Include

At least one theorem should explicitly connect knot invariants to another domain.

### Connection 1: Statistical mechanics / partition functions
The Kauffman bracket is a finite state sum analogous to a partition function. Make this precise.

A possible theorem:
```lean
theorem kauffmanBracket_as_partitionFunction
    {n : ℕ} (D : LinkDiagram n) :
    kauffmanBracket D =
      partitionFunction (isingLikeModelOfDiagram D) := by
  ...
```
This can be at the level of a custom finite combinatorial partition function if a full Ising formalization is too large. The key is to identify smoothing states with spin configurations or edge states and prove exact equality of weights.

**Breakthrough significance:** this opens a verified route from quantum topology to lattice models and topological phases.

### Connection 2: Euler characteristic / topological move invariance
The catalog theorem
- `eulerChar_two_moves_invariant` in `FINAL/Geometry/DiscreteGaussBonnet.lean`

suggests a conceptual analogy: local cell moves preserving global invariants. If you define a state graph, Tait graph, or checkerboard surface combinatorics, prove an invariant relation under diagrammatic moves. Even a theorem comparing move-invariance mechanisms between knot diagrams and cell complexes would be valuable.

For example:
```lean
theorem reidemeisterII_preserves_stateGraph_euler_relation
    {n : ℕ} {D₁ D₂ : LinkDiagram n}
    (h : ReidemeisterII D₁ D₂) :
    stateGraphEulerData D₁ = stateGraphEulerData D₂ := by
  ...
```

### Connection 3: Quantum computation / braid representations
If feasible, define a braid closure family and show the Jones polynomial computation factors through a braid recursion. Even a modest formal theorem relating braid generators to skein updates is significant.

---

## Application Keywords

Include these in your `RESEARCH_PAPER.md` and `ARTICLE.md` as framing anchors:

- quantum topology
- skein theory
- knot detection
- formal verification
- topological quantum computation
- partition functions
- statistical mechanics
- low-dimensional topology
- braid groups
- certified symbolic computation
- alternating knots
- adequacy
- Laurent polynomials
- Reidemeister invariance

---

## Concrete Lean 4 Deliverables

Produce all of the following:

### 1. Verified theorem file(s)
A Lean development containing at least:
- one new structure/concept,
- the state-sum theorem,
- Reidemeister invariance theorems,
- at least two exact knot computations,
- one family theorem or recurrence,
- one cross-domain theorem,
- one detection theorem using or extending `adequate_jones_detects_unknot`.

### 2. Verified algorithm / computational method
Implement a certified algorithm:
```lean
def computeJones (D : OrientedLinkDiagram n) : LaurentPolynomial ℤ := ...
```
and prove:
```lean
theorem computeJones_correct
    {n : ℕ} (D : OrientedLinkDiagram n) :
    computeJones D = jonesPolynomial D := by
  ...
```
This is mandatory. The algorithm should recurse on crossings or use memoized skein decomposition if you can support it.

### 3. `demo.py`
An interactive demonstration script that:
- constructs the unknot, trefoil, figure-eight, and sample torus knots,
- prints their Jones polynomials,
- verifies known identities,
- experimentally checks your conjecture on a finite database of alternating diagrams,
- visualizes degree span / coefficient patterns if possible.

### 4. `FUTURE_DIRECTIONS.md`
Must contain 3–5 **falsifiable scientific hypotheses**, each with a clear computational disproof test.

Recommended examples:

1. **Span-sharpness hypothesis for alternating families**  
   For every reduced alternating diagram `D` in a tested census,  
   `span (jonesPolynomial D) = crossingNumber D`.  
   **Test:** enumerate reduced alternating diagrams up to `N` crossings and search for a counterexample.

2. **Torus-knot coefficient unimodality hypothesis**  
   For `T(2,2m+1)`, the absolute values of coefficients of the Jones polynomial follow a predictable unimodal profile.  
   **Test:** compute for `m ≤ N`; disprove by a single violation.

3. **Partition-function universality hypothesis**  
   The bracket state sum of every adequate diagram matches a finite spin model with interaction graph derived from the Tait graph.  
   **Test:** construct the graph model for all diagrams in a finite census and compare polynomials.

4. **Alternation rigidity hypothesis**  
   If an adequate knot has Jones polynomial with the same span and extremal coefficient pattern as an alternating knot, then it is alternating.  
   **Test:** search adequate non-alternating knots in a census.

5. **Braid recursion complexity hypothesis**  
   For braid closures of fixed strand number, memoized skein recursion computes the Jones polynomial in empirically sub-exponential time in crossing number over the tested range.  
   **Test:** benchmark runtime growth and fit asymptotics.

### 5. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the definitions,
- the main theorems,
- the proof ideas,
- the computational method,
- the significance for topology and physics,
- the conjectures and experimental agenda.

It must be readable without access to the code.

### 6. `ARTICLE.md`
A Scientific American–style article explaining to a broad audience how local crossing rules can encode global topology, why formal verification matters, and how this connects to quantum science.

---

## Suggested Development Order

1. Define Laurent-polynomial target and state space.
2. Prove recursive bracket = state sum.
3. Prove local Reidemeister identities.
4. Define writhe-normalized Jones polynomial and prove invariance.
5. Compute unknot, trefoil, figure-eight.
6. Prove torus-knot recurrence.
7. Connect reduced alternating to adequate and invoke `adequate_jones_detects_unknot`.
8. Add the partition-function theorem and computational algorithm.

---

## What Would Make This Paradigm-Shifting

If you succeed, you will have formalized one of the first genuinely nontrivial quantum-topological invariants in a way that is:

- **topologically meaningful**: invariant under ambient isotopy,
- **algorithmically certified**: exact computation comes with proof of correctness,
- **structurally extensible**: ready for Khovanov homology, HOMFLY-PT, Temperley–Lieb categories, and braid-group quantum representations,
- **cross-disciplinary**: linked to partition functions and quantum information viewpoints.

This is not “formalize a polynomial.” This is the beginning of a **verified skein-theoretic laboratory** for quantum topology.

Minimize sorry. Avoid trivial proofs. Make the theorems do real work.

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

Research domain: Geometry
Research mode: prove
