Soli Deo Gloria

## Assignment: Direction 1: Torsion-Aware Tropical Morse Theory

**Mode:** `prove`

Aristotle, do not merely extend the field-coefficient simplex insertion dichotomy. Replace it with an integer-coefficient local surgery law for homology that detects the exact arithmetic content of a simplex attachment. The breakthrough target is a **torsion-sensitive tropical Morse calculus**: every simplex insertion should have a certified local effect on the Smith profile of the boundary map, and hence on the free/torsion decomposition of homology. This is the missing arithmetic layer in discrete Morse-type event theory.

Build directly on:

- `Catalog/Pythagorean/TropicalMorse/SimplicialMorse.lean`
  - especially the field-case theorem `simplex_insertion_dichotomy`
- Mathlib’s integer linear algebra and Smith normal form infrastructure
- finitely generated abelian group structure theorems already available or reconstructible from SNF

The field case only sees whether a new column is zero mod span or not. Over `ℤ`, a new boundary can land in the saturation of the old image without landing in the old image itself; this is where torsion is born or dies. That arithmetic discrepancy is the new tropical event.

---

## Central Breakthrough Goal

Formalize and prove a **simplex insertion trichotomy over `ℤ`** for finite simplicial complexes, together with a computable invariant—the **tropical torsion spectrum**—that records the arithmetic event type via Smith normal form.

This is not just “homology over integers.” It is a local classification theorem for topology-changing moves with arithmetic memory.

---

## Precise Mathematical Targets

You should introduce at least one genuinely new definition, such as:

- `TorsionSpectrum`: the multiset/list of non-unit Smith diagonal entries of a boundary map or homology presentation
- `SimplexInsertionEventZ`: an event type with constructors
  - `birthFree`
  - `killFree`
  - `changeTorsion`
- optionally refine `changeTorsion` into creation/annihilation/modification of a primary component
- `saturationIndex` of a submodule inclusion relevant to whether a new simplex boundary is primitive

The conceptual invariant is:

\[
H_{d-1}(K;\mathbb Z)\cong \mathbb Z^{\beta_{d-1}} \oplus \bigoplus_i \mathbb Z/(n_i),
\quad 1<n_1\mid n_2\mid \cdots
\]

When a single `d`-simplex is inserted, the theorem should assert that exactly one local event occurs in the presentation data: free birth, free kill, or torsion modification.

---

## Theorem 1: Integer Simplex Insertion Trichotomy

### Informal statement
Let `K ⊆ K'` be finite simplicial complexes differing by the insertion of a single `d`-simplex `σ`, with all proper faces of `σ` already in `K`. Then the change from `H_*(K; ℤ)` to `H_*(K'; ℤ)` in dimensions `d` and `d-1` is governed by exactly one of three mutually exclusive events:

1. **Free birth:** a new free `d`-homology class appears;
2. **Free kill:** a free `(d-1)`-homology class is killed;
3. **Torsion change:** the torsion subgroup of `H_{d-1}` changes, while free ranks in the relevant dimensions obey the local Euler constraint.

This must be phrased in a way Lean can support through chain complexes/presentation matrices/SNF.

### Suggested Lean 4 theorem signature
You may need to adapt names to actual catalog structures, but aim for something of this form:

```lean
theorem simplex_insertion_trichotomy_Z
  {K K' : FiniteSimplicialComplex}
  {d : ℕ}
  (hsub : K ≤ K')
  (hinsert : inserts_single_d_simplex K K' d)
  (hfaces : all_faces_present_before_insertion K K' d) :
  let HdK    := homologyZ K d
  let HdK'   := homologyZ K' d
  let Hdm1K  := homologyZ K (d - 1)
  let Hdm1K' := homologyZ K' (d - 1)
  in
    ExclusiveOr3
      (FreeBirthEvent HdK HdK')
      (FreeKillEvent Hdm1K Hdm1K')
      (TorsionChangeEvent Hdm1K Hdm1K')
```

If `ExclusiveOr3` is awkward, use an existential unique event classifier:

```lean
theorem simplex_insertion_has_unique_event_Z
  {K K' : FiniteSimplicialComplex}
  {d : ℕ}
  (hsub : K ≤ K')
  (hinsert : inserts_single_d_simplex K K' d)
  (hfaces : all_faces_present_before_insertion K K' d) :
  ∃! e : SimplexInsertionEventZ,
    realizes_event_Z K K' d e
```

### Stronger quantitative version
The most powerful formulation is in terms of rank and torsion spectrum:

```lean
theorem simplex_insertion_rank_torsion_trichotomy
  {K K' : FiniteSimplicialComplex}
  {d : ℕ}
  (hsub : K ≤ K')
  (hinsert : inserts_single_d_simplex K K' d)
  (hfaces : all_faces_present_before_insertion K K' d) :
  let a := homology_free_rank K d
  let a' := homology_free_rank K' d
  let b := homology_free_rank K (d - 1)
  let b' := homology_free_rank K' (d - 1)
  let T := torsionSpectrum K (d - 1)
  let T' := torsionSpectrum K' (d - 1)
  in
    (a' = a + 1 ∧ b' = b ∧ T' = T) ∨
    (a' = a ∧ b' + 1 = b ∧ T' = T) ∨
    (a' = a ∧ b' = b ∧ T' ≠ T)
```

This is the arithmetic replacement for the field dichotomy.

---

## Theorem 2: Smith-Diagonal Detection of Torsion Event

### Informal statement
If the inserted simplex contributes a new boundary vector whose coordinate in a suitable SNF basis has a non-unit divisibility obstruction, then the event is torsion-changing, and the changed torsion factor is detected by the relevant Smith diagonal entry.

This theorem is the actual bridge from local combinatorics to arithmetic topology.

### Suggested Lean 4 type signature
```lean
theorem torsion_event_detected_by_smith_diagonal
  {M : Matrix (Fin m) (Fin n) ℤ}
  {v : Fin m → ℤ}
  (hsnf : IsSmithNormalForm M S)
  (hcol : column_adjoin_is_simplex_boundary M v)
  (hnonprimitive : ¬ primitive_vector_mod_image M v) :
  ∃ q : ℤ,
    q ≠ 0 ∧ ¬ IsUnit q ∧
    smithDiagonalWitness S q ∧
    torsion_change_from_adjoin M v q
```

If possible, strengthen to prime-power decomposition:

```lean
theorem torsion_event_has_primary_witness
  ...
  : ∃ p k, Nat.Prime p ∧ 0 < k ∧
      changes_p_primary_torsion M v p k
```

### Why this matters
This is the theorem that says the tropical event type is not merely “something happened to torsion,” but that the event carries a discrete arithmetic spectral label. That label is the seed of a new invariant: the **tropical torsion spectrum**.

---

## Theorem 3: Local Conservation Law for Free Rank and Torsion Mass

You need a theorem that behaves like a tropical Morse conservation law. A simplex insertion should alter exactly one unit of “homological complexity,” but over `ℤ` that complexity can move between free and torsion sectors.

One robust formulation is:

### Informal statement
For a single `d`-simplex insertion, the alternating change in free ranks is constrained as in the field case, and any failure of free-rank change is accounted for exactly by a torsion-spectrum change in `H_{d-1}`.

### Suggested Lean 4 type signature
```lean
theorem simplex_insertion_conservation_law_Z
  {K K' : FiniteSimplicialComplex}
  {d : ℕ}
  (hsub : K ≤ K')
  (hinsert : inserts_single_d_simplex K K' d)
  (hfaces : all_faces_present_before_insertion K K' d) :
  let Δβd   := homology_free_rank K' d - homology_free_rank K d
  let Δβdm1 := homology_free_rank K' (d - 1) - homology_free_rank K (d - 1)
  in
    Δβd - Δβdm1 = 1 ∧
    ((Δβd = 1 ∧ Δβdm1 = 0) ∨
     (Δβd = 0 ∧ Δβdm1 = -1) ∨
     (Δβd = 0 ∧ Δβdm1 = 0 ∧ torsionSpectrum K' (d - 1) ≠ torsionSpectrum K (d - 1)))
```

If integer subtraction on naturals is awkward, use `Int`-valued ranks.

This theorem gives the “tropical balance law” needed for a genuine Morse-type event calculus over integers.

---

## New Definitions You Should Introduce

At least one is mandatory; I recommend several.

### 1. Tropical torsion spectrum
```lean
def torsionSpectrum (K : FiniteSimplicialComplex) (d : ℕ) : List ℤ := ...
```
Interpretation: the non-unit invariant factors in the SNF presentation of `H_d(K; ℤ)`, sorted by divisibility.

### 2. Primitive boundary / saturation defect
```lean
def primitive_boundary_relative
  (M : Matrix (Fin m) (Fin n) ℤ) (v : Fin m → ℤ) : Prop := ...
```
This should mean that the class of `v` in the quotient by the old image is primitive, so adding it kills free rank rather than creating torsion.

### 3. Event classifier
```lean
inductive SimplexInsertionEventZ
| birthFree
| killFree
| changeTorsion
```

### 4. Optional: torsion mass
A computable scalar proxy:
```lean
def torsionMass (K : FiniteSimplicialComplex) (d : ℕ) : ℕ := ...
```
For instance, product or sum of valuations of invariant factors. This can support experiments even if full canonical list equality is cumbersome.

---

## Proof Strategy Architecture

You must pursue at least 2–3 proof paths in parallel and choose the one Lean likes best.

### Strategy A: Presentation-matrix + Smith normal form route
**Most promising.**

1. Model insertion of one `d`-simplex as adjoining exactly one generator in `C_d` and one new column in the boundary matrix `∂_d`.
2. Compare old and new cokernel/kernel presentations using SNF.
3. Show the new column has exactly three possibilities relative to the old image lattice:
   - zero in the quotient → free birth in `H_d`
   - primitive nonzero class → free kill in `H_{d-1}`
   - nonprimitive nonzero class → torsion change in `H_{d-1}`
4. Extract the torsion label from the corresponding Smith invariant factor.

Why this is strongest: it directly exposes the arithmetic obstruction absent over fields, and SNF is the right normal form for finitely generated abelian groups.

### Strategy B: Relative homology / long exact sequence route
1. Analyze the pair `(K', K)` where `K' = K ∪ {σ}`.
2. Compute relative chain groups: only one new `d`-cell contributes.
3. Use the long exact sequence
   \[
   H_d(K) \to H_d(K') \to H_d(K',K) \xrightarrow{\partial} H_{d-1}(K) \to H_{d-1}(K')
   \]
4. Prove that the connecting morphism sends the relative generator to `[∂σ]`, and classify this element as zero / primitive / nonprimitive in `H_{d-1}(K)`.

Why this is conceptually elegant: it isolates the local topological move. Why it may be harder in Lean: exact-sequence infrastructure plus primitive/nonprimitive classification in finitely generated abelian groups may require more setup.

### Strategy C: Lattice-saturation route
1. Let `B_{d-1}(K) = im ∂_d ⊆ Z_{d-1}(K)`.
2. Study the lattice generated by `B_{d-1}(K)` and `∂σ` inside cycles.
3. Show:
   - if `∂σ ∈ B_{d-1}(K)`, no new relation in quotient lattice: free birth
   - if `∂σ ∉ sat(B_{d-1}(K))`, quotient free rank drops: free kill
   - if `∂σ ∈ sat(B_{d-1}(K)) \ B_{d-1}(K)`, the quotient gains/loses torsion
4. Identify the torsion order with the index of the lattice extension.

Why this is exciting: it reframes the theorem as a saturation-index law, making contact with tropical geometry and arithmetic combinatorics. This may yield the cleanest conceptual paper even if Strategy A is easier to formalize first.

**Recommendation:** formalize Strategy A first, use Strategy B for explanatory architecture in the paper, and mine Strategy C for the new invariant language.

---

## Cross-Domain Connections You Must Develop

At least one theorem must genuinely bridge to another field. Here are the strongest options.

### Bridge 1: Quantum error correction
In CSS or homological stabilizer codes, torsion can encode subtle degeneracy/constraint structure in integer lifts and related chain models. Prove a theorem of the following flavor:

```lean
theorem torsion_event_changes_code_degeneracy_proxy
  {K K' : FiniteSimplicialComplex} {d : ℕ}
  (hins : inserts_single_d_simplex K K' d)
  (htor : realizes_event_Z K K' d SimplexInsertionEventZ.changeTorsion) :
  codeDegeneracyProxy K (d - 1) ≠ codeDegeneracyProxy K' (d - 1)
```

Even if this uses a simplified “code proxy” rather than full QEC formalism, it creates a serious bridge: local topological moves changing arithmetic homology correspond to changes in defect or logical-constraint structure.

### Bridge 2: Crystallographic defects / materials
Torsion in cell-complex homology can model defect pinning and compatibility obstructions. Define a defect invariant based on torsion mass and prove monotonicity or event sensitivity under simplex insertions.

### Bridge 3: Arithmetic topology / number theory
Prime decomposition of torsion spectrum gives a local `p`-adic event signature. Prove a theorem that the torsion event decomposes into independent `p`-primary changes:

```lean
theorem torsion_spectrum_primewise_detectable
  (K : FiniteSimplicialComplex) (d : ℕ) :
  torsionSpectrum K d = combine_prime_primary_spectra K d
```

Then interpret simplex insertion as a primewise tropical event. This is the cleanest number-theoretic bridge.

---

## Testable Conjecture

State and support at least one falsifiable conjecture with explicit computational disproof conditions.

### Conjecture: Prime-local torsion pulse law
In random Linial–Meshulam 2-complexes over `ℤ`, near the torsion phase transition, the insertion of a single 2-simplex changes the `p`-primary torsion of `H_1` for at most one prime `p` with high probability, and the event-size distribution converges to a sparse law concentrated on small prime powers.

A Lean-adjacent formal shell:
```lean
def primeLocalTorsionPulseConjecture : Prop := ...
```

### Computational test
Generate random 2-complexes on `n` vertices, insert triangles one at a time, compute `H_1(-; ℤ)` via SNF, and check whether a single insertion simultaneously changes `p`-primary torsion for multiple distinct primes. A single robust family of counterexamples falsifies the conjecture.

Alternative stronger conjecture:

### Conjecture: Torsion trichotomy exhaustiveness
For every single-simplex insertion, the total number of changed invariant factors in `H_{d-1}` is at most one.

This is beautiful, sharp, and very falsifiable. If false, discovering the minimal counterexample is itself valuable and publishable.

---

## Suggested Theorem Sequencing

1. **Algebraic lemma:** classify adjoining one vector to a submodule of `ℤ^n` by zero / primitive / nonprimitive quotient class.
2. **SNF transfer lemma:** connect that classification to cokernel free rank and torsion-spectrum change.
3. **Chain-complex insertion lemma:** model simplex insertion as single-column adjunction.
4. **Main trichotomy theorem.**
5. **Primewise torsion detection theorem** or **cross-domain bridge theorem.**

This will satisfy the “at least 3 deep theorems” requirement naturally.

---

## Lean-Specific Guidance

Use deep proof patterns. Your file must visibly include nontrivial uses of:
- `induction`
- `rcases`
- `by_contra`
- `field_simp` where rational/index computations arise
- multi-step `calc`

Do not let the core theorem collapse to finite case-bashing or definitional equality.

Potential technical route:
- represent chain groups as finitely supported integer functions on simplices
- encode boundary maps as integer matrices after choosing finite bases
- use SNF to recover invariant factors of homology presentations
- compare old/new matrices under column adjunction

Even if Mathlib’s full simplicial homology stack is awkward, a finite combinatorial chain model with verified equivalence for the needed local move is acceptable.

---

## Revolutionary Significance

If you succeed, you will have created the first formal **arithmetic tropical Morse theory** for simplicial insertions. The field-case dichotomy becomes a shadow of a richer integer event geometry. This opens:

- **torsion-sensitive topological data analysis**
- **phase-transition diagnostics in random complexes**
- **homological defect theory in materials**
- **arithmetic signatures for quantum code design**
- **primewise topological dynamics**, where topology changes not only in dimension but in arithmetic texture

The real conceptual shift is this: topology-changing events are not merely linear-algebraic over a field; they are **lattice-theoretic and arithmetic**. That changes the ontology of discrete Morse events.

---

## Application Keywords

tropical Morse theory; Smith normal form; finitely generated abelian groups; simplicial homology over integers; torsion phase transition; Linial–Meshulam complexes; lattice saturation; arithmetic topology; prime-primary decomposition; quantum error correction; crystallographic defects; topological data analysis; discrete topology surgery; homological invariants; combinatorial Hodge theory

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **A Lean file** proving the main results with minimal sorrys, including:
   - at least 3 substantial theorems
   - at least 1 genuinely new definition
   - at least 1 cross-domain theorem
   - at least 1 explicit conjecture as a formal declaration

2. **`FUTURE_DIRECTIONS.md`**
   - 3–5 original research directions
   - each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - at least one direction must bridge to a different domain

3. **`RESEARCH_PAPER.md`**
   - standalone scientific exposition
   - must explain the theorem, proof architecture, significance, examples, and next questions
   - readable without code access

4. **`ARTICLE.md`**
   - Scientific American style
   - engaging and concept-driven
   - taboo: do **not** focus on formal verification machinery
   - focus on arithmetic topology, torsion events, and why local topological moves can carry hidden number-theoretic structure

5. **A verified algorithm or computational method**
   - compute the torsion spectrum of a finite simplicial complex
   - classify each simplex insertion event into the trichotomy
   - ideally expose primewise event signatures

6. **`demo.py`**
   - interactively generate or load finite 2-complexes
   - insert simplices one by one
   - compute `H_1(-; ℤ)` via SNF
   - display event classification: free birth / free kill / torsion change
   - include random experiments aimed at the conjecture

---

## Final Charge

Do not settle for “integer version of the old theorem.” The goal is to discover and formalize the arithmetic event structure hidden inside simplex insertion. The field story was about dimension. This story is about **divisibility, saturation, and prime-local topology change**.

Find the theorem that makes mathematicians say: *of course simplex insertions should have a Smith-spectrum signature — why did nobody build tropical Morse theory over the integers this way before?*

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
