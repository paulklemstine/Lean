Soli Deo Gloria

## Assignment: Direction 1: Optimal Generator Bounds

**Mode:** `prove`

Prove genuinely new, structurally meaningful theorems in Lean 4 on optimal generator bounds for finite-valued presheaves over finite categories. Do not merely restate the existing `Σ_Y |F(op Y)|` construction from the catalog: isolate the hidden combinatorial geometry of redundancy among representable generators and turn it into a formal theory of categorical sparsity.

This direction is promising because it upgrades a coarse existence theorem into a quantitative complexity theory for presheaves. If successful, it opens a new invariant of finite categories: the **generator complexity profile** of a presheaf, analogous to sparsity in compressed sensing, codebook size in coding theory, and key cardinality in database theory.

---

## Core Breakthrough Goal

The catalog theorem
- `Pythagorean/ProbeComplexity/FiniteRepresentability.lean` — `repFinGen_of_finite`

already gives a representable cover with
\[
\sum_{Y \in \mathrm{Ob}(C)} |F(\mathrm{op}\,Y)|
\]
generators, hence at most \(n \cdot m\) when every fiber has size \(\le m\) and \(C\) has \(n\) objects.

That bound is universal but blind: it does not distinguish between genuinely independent generators and elements already forced by restriction along morphisms. Your task is to formalize the first nontrivial structure theory of **minimal representable generating families**.

The right conceptual leap is this:

> A finite presheaf is not just a table of values. It is a dependency system propagating along morphisms. Minimal representable covers should therefore be controlled by an antichain/frontier of restriction-irreducible elements, not by all elements.

This is the bridge to compressed sensing: representables are atoms, restriction relations induce dependence, and minimal covers are sparse dictionaries.

---

## Precise Theorem Targets

You should introduce at least one genuinely new definition capturing irreducibility/redundancy of sections under restriction. A suggested concept:

- a section \(x \in F(\mathrm{op}\,Y)\) is **restriction-generated** if it lies in the image of some non-identity restriction map \(F(f^{op}) : F(\mathrm{op}\,Z) \to F(\mathrm{op}\,Y)\),
- otherwise it is **primitive** (or **restriction-irreducible**).

Then prove theorems showing that primitive sections control generator complexity.

### New definitions to formalize
You are expected to define something in this spirit:

```lean
def PrimitiveSection
  {C : Type u} [Category C] (F : Cᵒᵖ ⥤ Type v) [Finite (Obj C)]
  (Y : C) (x : F.obj (Opposite.op Y)) : Prop := 
  ¬ ∃ (Z : C) (f : Y ⟶ Z) (hf : f ≠ 𝟙 Y) (z : F.obj (Opposite.op Z)),
      F.map f.op z = x
```

or a variant better aligned with your existing finite-category infrastructure.

You may also define a numerical invariant:

```lean
def primitiveCount
  {C : Type u} [Category C] [Fintype C]
  (F : Cᵒᵖ ⥤ Type v) [∀ Y, Fintype (F.obj (Opposite.op Y))] : ℕ := ...
```

and a minimal cover cardinality invariant:

```lean
def minRepCoverCard
  {C : Type u} [Category C] [Fintype C]
  (F : Cᵒᵖ ⥤ Type v) : ℕ := sInf {k | ∃ S, IsRepresentableCoverOfCard F S k}
```

You do not need this exact signature if Mathlib ergonomics suggest a cleaner formulation, but the mathematical content must be present.

---

## Theorem 1: Primitive Generator Upper Bound

### Mathematical statement
Let \(C\) be a finite category and \(F : C^{op} \to \mathrm{FinType}\) a finite-valued presheaf. Suppose every non-identity endomorphism acts without creating new primitive sections, or more generally work under a hypothesis ensuring that every section is restriction-generated from a primitive one. Then \(F\) admits a representable cover with at most the number of primitive sections:
\[
g(F) \le \sum_{Y \in \mathrm{Ob}(C)} |\mathrm{Prim}_F(Y)|.
\]
In particular,
\[
g(F) \le \sum_Y |F(Y)| \le n m.
\]

This theorem is stronger than the catalog theorem because it identifies a strictly smaller controlling quantity.

### Suggested Lean 4 shape
```lean
theorem rep_cover_bound_by_primitiveCount
  {C : Type u} [Category C] [Fintype C]
  (F : Cᵒᵖ ⥤ Type v)
  [∀ Y : C, Fintype (F.obj (Opposite.op Y))]
  (hgen : ∀ {Y : C} (x : F.obj (Opposite.op Y)),
    ∃ (Z : C) (f : Y ⟶ Z) (z : F.obj (Opposite.op Z)),
      PrimitiveSection F Z z ∧ F.map f.op z = x) :
  ∃ k ≤ primitiveCount F, HasRepresentableCoverOfCard F k
```

If your library already has a notion like `RepFinGen`, adapt the conclusion to that object rather than inventing a parallel API.

### Why this is a breakthrough
This theorem upgrades existence into **compressed existence**. It says the true complexity of a presheaf is governed by a frontier of irreducible information. This is the categorical analogue of a sparse generating set, a minimal dictionary, or a basis of indecomposable observations.

---

## Theorem 2: Poset Categories Realize the Frontier Exactly

The strongest and cleanest nontrivial result may appear first for thin categories / finite posets, where restriction-induced dependence is acyclic.

### Mathematical statement
Let \(P\) be a finite poset viewed as a category, and \(F : P^{op} \to \mathrm{FinType}\). Then the minimal number of representable generators equals the number of primitive sections:
\[
g(F) = \sum_{p \in P} |\mathrm{Prim}_F(p)|.
\]

This is much stronger than the global \(n m\) bound and gives an exact formula in a large class of categories.

### Suggested Lean 4 shape
```lean
theorem minRepCoverCard_eq_primitiveCount_of_poset
  {P : Type u} [PartialOrder P] [Fintype P]
  (F : (CategoryTheory.of P)ᵒᵖ ⥤ Type v)
  [∀ p : P, Fintype (F.obj (Opposite.op (CategoryTheory.of p)))] :
  minRepCoverCard F = primitiveCount F
```

If formalizing `CategoryTheory.of P` becomes cumbersome, formulate this over an existing thin-category wrapper already used in the catalog.

### Why this is a breakthrough
This is the exact sparsity law. In compressed sensing language, poset-valued observation systems have no hidden syzygies beyond restriction ancestry; the primitive sections are the atoms. This gives a complete classification theorem in a nontrivial family and provides the canonical testing ground for the general conjecture.

---

## Theorem 3: Sharp Universal Bound and Tightness Construction

### Mathematical statement
For every finite category \(C\) with \(n = |\mathrm{Ob}(C)|\) and every finite-valued presheaf \(F\) with \(|F(Y)| \le m\) for all \(Y\),
\[
g(F) \le n m.
\]
Moreover, for every \(n,m \ge 1\), there exists a finite discrete category \(D_n\) and a presheaf \(F\) on \(D_n\) with \(|F(Y)| = m\) for all \(Y\) such that
\[
g(F) = n m.
\]

This “tightness by discreteness” is mathematically important: it shows the universal constant cannot be improved without using category structure.

### Suggested Lean 4 shape
```lean
theorem minRepCoverCard_le_cardObj_mul_fiberBound
  {C : Type u} [Category C] [Fintype C]
  (F : Cᵒᵖ ⥤ Type v)
  [∀ Y : C, Fintype (F.obj (Opposite.op Y))]
  (m : ℕ)
  (hm : ∀ Y : C, Fintype.card (F.obj (Opposite.op Y)) ≤ m) :
  minRepCoverCard F ≤ Fintype.card C * m
```

and a tightness witness theorem along the lines of

```lean
theorem exists_presheaf_tight_cardObj_mul_fiberBound
  (n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m) :
  ∃ (C : Type) (_ : Category C) (_ : Fintype C)
    (F : Cᵒᵖ ⥤ Type),
      Fintype.card C = n ∧
      (∀ Y : C, Fintype.card (F.obj (Opposite.op Y)) = m) ∧
      minRepCoverCard F = n * m
```

You may instantiate `C` as `Fin n` with the discrete category structure.

### Why this matters
This theorem separates the **universal worst-case law** from the **structure-sensitive exact law**. That separation is itself a field-opening perspective: universal compression is capped by \(nm\), but actual compression comes from morphism-induced dependency.

---

## Theorem 4: Probe Complexity Interface

Use the catalog theorem
- `Catalog/Pythagorean/ProbeComplexity/Theorems.lean` — `card_hom_le_profile_capacity`

to connect generator complexity with probe/separation complexity.

### Mathematical statement
Show that if a probe family \(P\) separates primitive generators, then the number of primitive generators is bounded by an information/profile capacity term derived from probe signatures. Concretely, derive an inequality of the shape
\[
|\mathrm{Prim}(F)| \le \mathrm{Cap}(P),
\]
hence
\[
g(F) \le \mathrm{Cap}(P).
\]

### Suggested Lean 4 shape
The exact type depends on the catalog statement, but aim for something like:

```lean
theorem primitiveCount_le_profile_capacity
  {C : Type u} [Category C] [Fintype C]
  (F : Cᵒᵖ ⥤ Type v)
  (P : ProbeFamily C)
  (hsep : SeparatesPrimitiveSections F P) :
  primitiveCount F ≤ profileCapacity P
```

followed by

```lean
theorem minRepCoverCard_le_profile_capacity
  {C : Type u} [Category C] [Fintype C]
  (F : Cᵒᵖ ⥤ Type v)
  (P : ProbeFamily C)
  (hsep : SeparatesPrimitiveSections F P) :
  minRepCoverCard F ≤ profileCapacity P
```

### Why this is revolutionary
This is the real cross-domain jump: generator complexity becomes **observable complexity**. You are relating sparse categorical representation to sensing profiles. That is the categorical analogue of “recovery complexity is bounded by measurement capacity.”

---

## Proof Strategy Architecture

You must provide at least 2–3 proof routes in the code comments / paper, and choose the most viable.

### Strategy A: Primitive-frontier induction on a well-founded height
Most promising for posets and acyclic categories.

1. Define a dependency relation: \(x \prec y\) if \(x\) is obtained by restricting \(y\) along a non-identity morphism.
2. Prove well-foundedness under a no-cycle / poset hypothesis.
3. Show every section descends from a primitive section by minimal-counterexample or well-founded induction.
4. Build the representable cover from primitive sections and verify surjectivity objectwise.
5. For exactness in posets, prove no primitive section can be omitted: each omitted primitive creates an uncovered fiber element by antichain minimality.

Lean tactics likely needed: `induction`, `rcases`, `by_contra`, `exact`, `refine`, multi-step `calc`.

Why promising: thin categories eliminate coherence headaches and make minimality arguments robust.

### Strategy B: Greedy compression of the catalog generating family
Most promising for the universal \(nm\) bound and practical algorithms.

1. Start from the existing generating family from `repFinGen_of_finite`, indexed by all pairs \((Y,z)\).
2. Define a redundancy predicate: a generator \((Y,z)\) is redundant if its contribution factors through the span of other generators via restriction.
3. Prove that removing a redundant generator preserves surjectivity.
4. Iteratively erase redundant generators until every remaining generator is primitive or irredundant.
5. Bound the size of the terminal family by `primitiveCount`.

Lean techniques: finite-set induction, `rcases` on witness morphisms, `by_contra` for minimality, `calc` for image equalities.

Why promising: this directly extends the catalog construction and is algorithmically implementable.

### Strategy C: Incidence-matrix / hypergraph formulation
Best for cross-domain significance and computational demos.

1. Encode sections as vertices and restriction dependencies as directed hyperedges.
2. Represent a generating family as a hitting set / source set in this dependency hypergraph.
3. Show primitive sections are exactly indegree-zero vertices in the transitive reduction for thin categories.
4. Use combinatorial optimization language to derive exactness or approximation bounds.

Why valuable: this creates the bridge to compressed sensing, sparse coding, and database key minimization. It may not be the cleanest first Lean proof, but it should appear in the scientific narrative and algorithmic implementation.

---

## Cross-Domain Connections You Must Exploit

### 1. Compressed sensing / sparse dictionary learning
Representable presheaves are dictionary atoms; a representable cover is a sparse synthesis of categorical data. Primitive sections are support-minimal atoms.

**Application keywords:** sparse coding, dictionary size, support recovery, measurement complexity.

### 2. Coding theory
A probe family assigns signatures to generators; separation of primitive sections acts like distinguishability of codewords. Capacity bounds mirror codebook cardinality constraints.

**Application keywords:** codebook design, distinguishability, channel capacity, signature compression.

### 3. Database theory
Presheaf restriction corresponds to projection along attributes; primitive sections resemble minimal keys or irreducible tuples not derivable by projection.

**Application keywords:** key minimization, relational dependencies, normalization, schema compression.

### 4. Sheaf-theoretic sensing / topological signal processing
Minimal representable covers describe the smallest family of local sensors whose propagated restrictions reconstruct the whole presheaf.

**Application keywords:** sensor placement, observability, local-to-global reconstruction, sheaf sampling.

### 5. Complexity theory
The minimal cover cardinality is a new complexity measure on functors. You should ask whether computing it is polynomial, NP-hard, or fixed-parameter tractable in special classes.

**Application keywords:** parameterized complexity, exact cover, optimization hardness, combinatorial compression.

---

## Required Lean Deliverables

Your Lean development must include at least:

1. **One novel definition** not already in the catalog:
   - `PrimitiveSection`
   - and preferably `primitiveCount` and/or `minRepCoverCard`.

2. **At least 3 substantial theorems** with nontrivial proof scripts:
   - one upper bound theorem,
   - one exactness theorem for a structured class (e.g. posets/discrete categories),
   - one tightness or probe-capacity theorem.

3. **Deep proof tactics**
   Use induction, `rcases`, `by_contra`, `field_simp` where relevant for cardinality manipulations over rational bounds if you introduce normalized complexity ratios, and multi-step `calc`. Avoid trivial theorem statements whose proof is mere computation.

4. **An algorithmic artifact**
   Implement a verified procedure that, given a finite presheaf on a small finite category, computes:
   - the primitive sections,
   - the greedy reduced generator family,
   - and an upper bound certificate for `minRepCoverCard`.

A suggested signature:
```lean
def greedyPrimitiveCover
  {C : Type u} [Category C] [Fintype C]
  (F : Cᵒᵖ ⥤ Type v) [∀ Y : C, Fintype (F.obj (Opposite.op Y))] :
  GeneratorFamily F
```
with a theorem
```lean
theorem greedyPrimitiveCover_correct ... :
  IsRepresentableCover F (greedyPrimitiveCover F)
```

---

## Computational / Experimental Program

You must test the conjectural landscape computationally for categories with
- `|Ob(C)| ≤ 5`,
- `|Mor(C)| ≤ 20`,
- fiber sizes `≤ 4`.

### Concrete experimental goals
1. Enumerate finite categories in the allowed range, or at least a rich sample:
   - discrete categories,
   - finite chains,
   - diamonds,
   - categories with parallel arrows,
   - categories with nontrivial endomorphisms.

2. For each finite-valued presheaf:
   - compute `primitiveCount`,
   - compute the greedy cover size,
   - compute the true minimal representable cover size by exhaustive search when feasible.

3. Search for:
   - counterexamples to exact equality `minRepCoverCard = primitiveCount`,
   - confirmation of the universal bound `≤ n*m`,
   - families where the compression gap `n*m - minRepCoverCard` is large.

4. Identify whether thin categories always satisfy exactness and whether cycles/endomorphisms create strict inequalities.

This computational component is not ancillary: it is the falsifiability engine of the project.

---

## Testable Conjectures for FUTURE_DIRECTIONS.md

You must include 3–5 falsifiable hypotheses. At minimum include versions of the following:

1. **Thin-category exactness conjecture**  
   For every finite poset category \(P\) and finite-valued presheaf \(F\),
   \[
   \minRepCoverCard(F) = primitiveCount(F).
   \]
   **Test:** exhaustive enumeration on all posets up to 6 elements and all presheaves with fibers of size at most 4.

2. **Cycle-induced compression gap conjecture**  
   In categories with nontrivial endomorphisms or directed cycles, there exist presheaves with
   \[
   \minRepCoverCard(F) < primitiveCount(F).
   \]
   **Test:** search categories with loops/endomorphisms and compare exact minimum with primitive count.

3. **Probe-capacity saturation conjecture**  
   For probe families separating primitive sections, the inequality
   \[
   \minRepCoverCard(F) \le \profileCapacity(P)
   \]
   is asymptotically sharp on a family of thin categories.
   **Test:** generate chains and Boolean lattices, compute both sides, fit asymptotics.

4. **Complexity conjecture**  
   Computing `minRepCoverCard` is NP-hard for finite presheaves over finite categories with parallel arrows.
   **Test:** reduce set cover instances to representable-cover minimization for randomly generated small instances.

5. **Compression-ratio law**  
   For random presheaves on sparse acyclic categories, the expected ratio
   \[
   \frac{\minRepCoverCard(F)}{\sum_Y |F(Y)|}
   \]
   decreases monotonically with morphism density.
   **Test:** Monte Carlo over random DAG categories with fixed object count.

---

## Exact Deliverables Required

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions, theorems, and verified algorithm.
2. **`FUTURE_DIRECTIONS.md`** with 3–5 testable scientific hypotheses, each falsifiable and paired with a concrete computational test.
3. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - define the problem,
   - explain the new invariants,
   - state and interpret the theorems,
   - discuss experiments,
   - explain significance and next steps.
4. **`ARTICLE.md`** in Scientific American style:
   - explain categorical sparsity and generator compression to broad readers,
   - connect to sensing, coding, and data compression.
5. **A verified algorithm or computational method**
   - primitive-section detection,
   - greedy generator compression,
   - exhaustive small-instance minimization where feasible.
6. **`demo.py`**
   - interactive exploration of small categories/presheaves,
   - computes `primitiveCount`, greedy cover size, exact minimum when possible,
   - visualizes the dependency graph / restriction hypergraph.

---

## Suggested File / Theorem Focus

Start from the catalog references:

- `Pythagorean/ProbeComplexity/FiniteRepresentability.lean`
  - especially `repFinGen_of_finite`
- `Catalog/Pythagorean/ProbeComplexity/Theorems.lean`
  - especially `card_hom_le_profile_capacity`

You should create a new file in the same thematic area, for example:
- `Pythagorean/ProbeComplexity/OptimalGeneratorBounds.lean`

Possible theorem names:
- `rep_cover_bound_by_primitiveCount`
- `minRepCoverCard_le_cardObj_mul_fiberBound`
- `minRepCoverCard_eq_primitiveCount_of_poset`
- `exists_presheaf_tight_cardObj_mul_fiberBound`
- `primitiveCount_le_profile_capacity`

---

## Final Scientific Vision

Do not treat this as “improving a bound by a little.” The real objective is to found a **theory of categorical sparsity**:

- universal worst-case bounds,
- exact formulas on structured categories,
- observable/probe-based upper bounds,
- algorithmic compression procedures,
- and falsifiable conjectures about complexity and asymptotics.

If you succeed, this project turns finite presheaf representation into a new meeting point of category theory, combinatorial optimization, sensing, coding, and data science.

**Application keywords:** categorical sparsity, representable compression, probe complexity, dictionary learning, codebook minimization, sheaf sensing, database keys, finite category algorithms, exact cover, observability.

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
