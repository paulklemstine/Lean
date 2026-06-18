## Mode: prove + counterexample

## Mission
Formalize and separate two rival notions of tropical Grassmannian geometry:

1. the **Dressian** `Dr(r,n)`, cut out by the 3-term tropical Plücker relations alone, and  
2. the **tropical Grassmannian** `Trop(Gr(r,n))`, coming from actual tropicalizations / realizable valuated matroids.

Then prove the first decisive fault line in the subject inside Lean:

- **rank 2 coincidence:** `Dr(2,n) = Trop(Gr(2,n))`, via the tree-metric characterization;
- **rank 3 divergence:** produce an explicit element of `Dr(3,7)` not lying in `Trop(Gr(3,7))`, using the Fano matroid as the obstruction.

This is not a routine formalization. It is the formal birth of the distinction between **combinatorial tropical linearity** and **geometric realizability**. Once certified, this opens a machine-checkable theory of valuated matroids, tropical moduli, and non-realizability phenomena across combinatorics, algebraic geometry, and phylogenetics.

---

## Precise theorem targets

You should introduce a mathematically honest but Lean-feasible layer of definitions first, then prove theorems at that layer.

### Core finite-index setup
Let `α := Fin n`. For rank `r`, tropical Plücker coordinates are functions
`w : Finset α → ℝ`
restricted to subsets of cardinality `r`.

A good implementation is to package coordinates as:
```lean
def PluckerVec (r n : ℕ) := {I : Finset (Fin n) // I.card = r} → ℝ
```

or, if easier for extensionality and decidability,
```lean
def PluckerVec (r n : ℕ) := {I : Finset (Fin n) // I.card = r} → Tropical := ...
```
but `ℝ` with `min`-style predicates is likely easier initially.

### Definition targets
Define:

1. **Three-term tropical Plücker relation** for rank `r`:
   for every `(r-2)`-subset `S` and distinct `a b c d ∉ S`, the minimum of
   ```text
   w(S ∪ {a,b}) + w(S ∪ {c,d}),
   w(S ∪ {a,c}) + w(S ∪ {b,d}),
   w(S ∪ {a,d}) + w(S ∪ {b,c})
   ```
   is attained at least twice.

2. **Dressian**
```lean
def InDressian (r n : ℕ) (w : PluckerVec r n) : Prop := ...
```

3. **Tree metric side for rank 2**
A symmetric dissimilarity map on `Fin n`, zero diagonal, satisfying the four-point condition.

You may define:
```lean
def IsTreeMetric (n : ℕ) (d : Fin n → Fin n → ℝ) : Prop := ...
```

4. **Rank-2 Plücker ↔ distance conversion**
A standard normalization is:
```lean
d i j = c - w {i,j}
```
or simply use an equivalent four-point predicate directly on `w`.

5. **Tropical Grassmannian**
If full initial-ideal formalization is too heavy for cycle 1, define an abstract realizability predicate:
```lean
def InTropicalGrassmannian (r n : ℕ) (w : PluckerVec r n) : Prop := ...
```
with a realizability-based semantics:
- `∃ K` a valued field,
- `∃ V : Submodule K (Fin n → K)` of rank `r`,
- `w` is the valuation of the Plücker coordinates of `V`.

If valued-field infrastructure is too large for immediate completion, isolate an axiomatic bridge:
```lean
axiom realizable_implies_dressian :
  InTropicalGrassmannian r n w → InDressian r n w
```
but do not stop there: the rank-2 equality and the rank-3 counterexample should still be proved concretely.

---

## Main theorem statement with Lean 4 signatures

### Theorem A: rank-2 Dressian equals tree metrics
A first concrete target:
```lean
theorem inDressian_rank2_iff_four_point
    (n : ℕ) (w : PluckerVec 2 n) :
    InDressian 2 n w ↔ SatisfiesFourPointOnPairs n w := by
```
where `SatisfiesFourPointOnPairs` is the four-point/tree metric condition expressed directly in pair coordinates.

A stronger and more geometric formulation:
```lean
theorem inDressian_rank2_iff_exists_tree_metric
    (n : ℕ) (w : PluckerVec 2 n) :
    InDressian 2 n w ↔ ∃ d : Fin n → Fin n → ℝ, IsTreeMetric n d ∧ PairPluckerFromMetric d w := by
```

### Theorem B: rank-2 coincidence of Dressian and tropical Grassmannian
```lean
theorem dressian_eq_tropicalGrassmannian_rank2
    (n : ℕ) (w : PluckerVec 2 n) :
    InDressian 2 n w ↔ InTropicalGrassmannian 2 n w := by
```

This is the conceptual breakthrough theorem: every rank-2 valuated matroid is realizable tropically, because both sides are exactly tree metrics / phylogenetic metrics.

### Theorem C: explicit rank-3 counterexample candidate on 7 points
Construct an explicit `wFano : PluckerVec 3 7`, ideally `0/1`-valued from the Fano matroid bases:
- `wFano(I) = 0` if `I` is a basis of the Fano matroid,
- `wFano(I) = 1` if `I` is a circuit line.

Then prove:
```lean
def fanoWeight : PluckerVec 3 7 := ...

theorem fanoWeight_in_dressian :
    InDressian 3 7 fanoWeight := by

theorem fanoWeight_not_in_tropicalGrassmannian :
    ¬ InTropicalGrassmannian 3 7 fanoWeight := by
```

Combined separation theorem:
```lean
theorem dressian_ne_tropicalGrassmannian_rank3 :
    ∃ w : PluckerVec 3 7, InDressian 3 7 w ∧ ¬ InTropicalGrassmannian 3 7 w := by
  exact ⟨fanoWeight, fanoWeight_in_dressian, fanoWeight_not_in_tropicalGrassmannian⟩
```

---

## Why this is a breakthrough
This is the first formal certification of a central phenomenon in tropical geometry:

- **rank 2 is controlled by metric geometry**;
- **higher rank introduces genuinely non-realizable tropical linear spaces**.

That separation is foundational. It creates a verified interface between:
- tropical algebraic geometry,
- valuated matroid theory,
- phylogenetic tree reconstruction,
- realizability/non-realizability in incidence geometry,
- and eventually cluster structures and tropical moduli.

A Lean development here would not just formalize a theorem; it would establish a reusable language for proving when tropical objects are geometric shadows of classical algebra and when they are purely combinatorial ghosts.

---

## Suggested file architecture

Create a new cluster such as:
- `Tropical/Grassmannian/DressianBasic.lean`
- `Tropical/Grassmannian/Rank2TreeMetric.lean`
- `Tropical/Grassmannian/FanoCounterexample.lean`

Possible theorem flow:

### `DressianBasic.lean`
- finite subset indexing lemmas
- definition of `PluckerVec`
- definition of 3-term tropical Plücker relation
- `InDressian`
- basic permutation invariance lemmas

### `Rank2TreeMetric.lean`
- pair-coordinate API for `r=2`
- four-point condition
- equivalence with rank-2 tropical Plücker condition
- tree metric definitions / conversions
- theorem `dressian_eq_tropicalGrassmannian_rank2`

### `FanoCounterexample.lean`
- explicit 7-point combinatorics
- define the 7 Fano lines
- define `fanoWeight`
- prove Dressian membership by finite checking
- encode non-realizability obstruction
- derive strict inequality

---

## Proof strategy architecture

## Strategy A: rank-2 via direct reduction to the four-point condition
This is the most promising path for an actual Lean breakthrough.

### Step 1
Show that when `r = 2`, the tropical Plücker relation has no `S`-part, so for every distinct `a b c d`, the condition is exactly:
```text
min( w_ab + w_cd, w_ac + w_bd, w_ad + w_bc )
is attained at least twice.
```
This is already the tropical four-point relation.

### Step 2
Relate `w` to a dissimilarity map `d` by a harmless affine renormalization:
```text
d(i,j) = C - w({i,j})
```
for a constant `C`, or define the four-point condition directly in terms of `w`.
Then prove equivalence between the tropical-min formulation and the standard tree-metric-max/two-largest-equal formulation.

### Step 3
Invoke or reconstruct the finite tree-metric characterization:
a dissimilarity map is a tree metric iff it satisfies the four-point condition.
If Mathlib lacks this exact theorem, formalize a finite combinatorial version specialized to `Fin n`.

**Why Strategy A is best:**  
It avoids heavy valued-field machinery at first. It turns tropical geometry into finite metric combinatorics, which Lean handles well. It also gives a computationally checkable normal form for rank 2.

---

## Strategy B: realizability-first via valuated matroids
This is more ambitious and likely a second-wave theorem after Strategy A.

### Step 1
Define `InTropicalGrassmannian` by realizable valuations of Plücker coordinates over a valued field.

### Step 2
Prove `InTropicalGrassmannian r n w → InDressian r n w` by tropicalizing the classical Plücker relations and using the non-Archimedean valuation inequality.

### Step 3
For `r=2`, prove every tree metric arises from a realizable rank-2 configuration, e.g. from a phylogenetic/tree model over Puiseux series.

**Why Strategy B matters:**  
It gives the true algebraic-geometric semantics of tropicalization. It is the route to future formalization of tropical varieties via initial forms and Gröbner theory.

---

## Strategy C: counterexample by explicit finite obstruction
This is the right route for the rank-3 separation theorem.

### Step 1
Define the Fano matroid combinatorially on `Fin 7` using its 7 lines:
```text
{0,1,2}, {0,3,4}, {0,5,6}, {1,3,5}, {1,4,6}, {2,3,6}, {2,4,5}
```
(or any canonically chosen labeling).

### Step 2
Define the valuated matroid weight `fanoWeight` from bases/nonbases and prove it satisfies all 3-term tropical Plücker relations. Since the ground set is finite and tiny, this can be done by exhaustive finite case analysis plus symmetry reduction.

### Step 3
Formalize the non-realizability obstruction:
the Fano matroid is realizable only in characteristic `2`, hence not realizable over characteristic `0`; depending on your chosen semantics for `InTropicalGrassmannian`, use a field-characteristic contradiction or a known forbidden-minor style argument.

**Why Strategy C is promising:**  
It turns an abstract separation statement into a concrete finite witness. Lean excels when a deep theorem can be anchored to a tiny explicit object.

---

## Cross-domain connections to exploit

### 1. Phylogenetics and metric geometry
The rank-2 theorem is exactly the theorem that tropical lines in projective space encode tree metrics. This connects tropical Grassmannians to:
- Buneman’s theorem,
- additive metrics,
- phylogenetic reconstruction.

This is not just analogy: it provides an algorithmic interpretation of `Trop(Gr(2,n))`.

### 2. Matroid realizability and finite geometry
The Fano counterexample links tropical geometry to:
- incidence geometry,
- characteristic-dependent realizability,
- oriented/valuated matroids,
- non-representability phenomena in combinatorics.

This is the higher-rank wall where tropical geometry stops being “just metric.”

### 3. Algebraic statistics and network geometry
Tree metrics drive latent tree models and graphical models. A formal rank-2 equivalence theorem could become a certified foundation for:
- tropical statistical models,
- identifiability certificates,
- combinatorial inference over semiring geometries.

### 4. Formal Gröbner/tropical bridge
Once `InTropicalGrassmannian` is encoded semantically, this project becomes the seed for a verified theory of:
- initial ideals,
- tropical varieties,
- Newton polytopes,
- secondary fans and Dressians.

---

## How to leverage existing catalog theorems
The listed catalog theorems are not directly about Grassmannians, but they can still serve as local infrastructure patterns:

- `min_equal_both_consistent` suggests there is already some precedent for proving “minimum attained at least twice” style lemmas. Reuse this style for the tropical Plücker predicate.
- `tropCrossRatio_all_equal` is structurally close to rank-2 four-point identities; cross-ratio style symmetry lemmas may inspire pairwise permutation invariance proofs.
- `tropical_tree_growth` is weak mathematically here, but conceptually aligns with the combinatorics of trees and can motivate finite-tree auxiliary constructions if needed.

Do not force irrelevant dependencies. Build genuinely useful local lemmas for:
- symmetry of pair coordinates,
- cardinality-2 and cardinality-3 subset enumeration on `Fin n`,
- “minimum attained at least twice” equivalences.

---

## Lean-specific implementation advice

### Pair indexing for rank 2
To avoid fighting quotient-like symmetry of `{i,j}`, consider an auxiliary structure:
```lean
structure PairIdx (n : ℕ) where
  i j : Fin n
  hij : i ≠ j
```
and then impose symmetry separately, or use `Sym2 (Fin n)` if practical.  
But `Finset (Fin n)` with cardinality proof may still be simpler for direct subset algebra.

### Predicate for “minimum attained at least twice”
A robust finite predicate:
```lean
def MinAttainedAtLeastTwice3 (a b c : ℝ) : Prop :=
  (a = b ∧ a ≤ c) ∨ (a = c ∧ a ≤ b) ∨ (b = c ∧ b ≤ a)
```
Then the 3-term tropical Plücker relation becomes algebraic rather than order-theoretic over arbitrary finite sets.

### Explicit finite witness for Fano
For the rank-3 counterexample, avoid excessive abstraction initially. Hard-code the 7 special triples as a decidable predicate on `Finset (Fin 7)`.

Example skeleton:
```lean
def IsFanoLine : Finset (Fin 7) → Prop := ...
def fanoWeight : PluckerVec 3 7 :=
  fun I => if IsFanoLine I.1 then 1 else 0
```
Then prove:
- every line has card `3`,
- all tropical Plücker checks pass.

If proving non-realizability from first principles is too heavy, isolate the classical theorem as a named assumption with explicit future goal:
```lean
axiom fano_not_realizable_char_zero :
  ¬ InTropicalGrassmannian 3 7 fanoWeight
```
But only do this if necessary after serious effort. The ideal outcome is a genuine proof via characteristic obstruction.

---

## Concrete subgoals
Pursue the following in order:

1. Define `PluckerVec`, `MinAttainedAtLeastTwice3`, `InDressian`.
2. Prove permutation invariance of the 3-term relation.
3. Specialize to `r=2` and derive the four-point form.
4. Define `SatisfiesFourPointOnPairs`.
5. Prove `inDressian_rank2_iff_four_point`.
6. Define or encode `IsTreeMetric`.
7. Prove `inDressian_rank2_iff_exists_tree_metric`.
8. Define `InTropicalGrassmannian` semantically or axiomatically.
9. Prove `dressian_eq_tropicalGrassmannian_rank2`.
10. Define `fanoWeight`.
11. Prove `fanoWeight_in_dressian`.
12. Prove or cleanly isolate `fanoWeight_not_in_tropicalGrassmannian`.
13. Conclude `dressian_ne_tropicalGrassmannian_rank3`.

---

## Ambition beyond the first theorem
If the core theorems land, you will have formalized the first real boundary between tropical combinatorics and tropical algebraic geometry. That unlocks the next frontier:

- tropical linear spaces as valuated matroids,
- Dressian fan structures,
- tropical moduli of trees and higher-rank analogues,
- certified non-realizability libraries for matroids,
- algorithmic tropical geometry in Lean.

This can become a foundational corpus, not a one-off theorem.

---

## Deliverables
Required:
- Lean 4 files with minimized `sorry`
- `FUTURE_DIRECTIONS.md`

Optional but encouraged:
- `ARTICLE.md` explaining the mathematics and formalization choices
- `RESEARCH_PAPER.md` with theorem statements, proof sketches, and implications
- `diagram.svg` showing:
  - `Trop(Gr(2,n)) = Dr(2,n) = TreeMetrics(n)`
  - strict inclusion `Trop(Gr(3,7)) ⊊ Dr(3,7)`

---

## Required application keywords
tropical geometry, Grassmannian, Dressian, valuated matroid, tree metric, phylogenetics, Fano matroid, non-realizability, formalized algebraic geometry, combinatorial geometry, Lean 4, Mathlib, tropical Plücker relations, incidence geometry, metric geometry

---

## FUTURE_DIRECTIONS.md requirement
You must produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps at breakthrough level. Include items such as:

1. Formalize the equivalence between valuated matroids and tropical linear spaces.
2. Define tropical Grassmannians via initial ideals and prove equivalence with realizable valuations.
3. Formalize the Dressian fan / secondary fan structure for hypersimplices.
4. Build a certified library of realizability obstructions for finite matroids beyond Fano.
5. Connect `Trop(Gr(2,n))` to moduli of phylogenetic trees and tropical `M̄_{0,n}`.

Be bold: do not merely formalize folklore. Establish the certified language in which tropical geometry can genuinely be done.

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
