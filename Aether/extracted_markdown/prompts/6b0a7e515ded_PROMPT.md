## Assignment: Tropical rank growth under tropical powers and image-set explosion

**Mode:** prove

You should attack a genuinely new theorem program around the principle that repeated tropical matrix multiplication amplifies combinatorial complexity until it saturates ambient dimension, and that this rank growth forces large orbit/image sets under tropical powering. This is not a small variant: it is a bridge between tropical linear algebra, semigroup growth, combinatorial optimization, and dynamical systems.

The core vision is to formalize a **tropical complexity-growth law**: if a tropical matrix has enough independent finite entries and avoids degenerate collapse, then its powers cannot remain combinatorially poor forever. This opens a path toward a tropical analogue of spectral expansion, growth in linear semigroups, and entropy production.

---

## Precise theorem targets

Work with tropical matrices over `WithTop ℤ` or `ℝ` as appropriate. Use concrete finite dimensions `Fin n`.

You will likely need to define a notion of **finite support graph** and a notion of **tropical image set of powers on basis vectors**.

### Definition targets

Introduce, if needed:

```lean
def tropMat (n : ℕ) := Matrix (Fin n) (Fin n) (WithTop ℤ)

def trop_mul {n : ℕ} (A B : tropMat n) : tropMat n := fun i k =>
  ⨅ j, (A i j + B j k)   -- or use the convention already present in the catalog if max-plus is used

def trop_pow {n : ℕ} (A : tropMat n) (m : ℕ) : tropMat n := A ^ m
```

If the existing files use min-plus or max-plus conventions, align strictly with the catalog and do not fight notation.

Define a finite-entry support predicate:

```lean
def finiteEntrySupport {n : ℕ} (A : tropMat n) : Finset (Fin n × Fin n) := ...
```

Define row-image set of powers on standard basis / columns:

```lean
def powerImageSet {n : ℕ} (A : tropMat n) (M : ℕ) : Finset (Fin n → WithTop ℤ) := ...
```

or a simpler finite-set surrogate based on columns/rows of `A^m` for `m ≤ M`.

---

## Primary breakthrough theorem

### Theorem A: monotone bounded tropical rank growth forces eventual stabilization, hence strict growth before saturation under non-stability hypotheses

This should be formalized in the strongest version you can prove. A realistic formal target is:

```lean
theorem exists_strict_rank_growth_before_saturation
  (n : ℕ) (A : Matrix (Fin n) (Fin n) (WithTop ℤ))
  (h_nonstable : ∃ m : ℕ, tropicalRank (A^(m+1)) ≠ tropicalRank (A^m))
  (h_bound : ∀ m : ℕ, tropicalRank (A^m) ≤ n) :
  ∃ m : ℕ, m < n ∧ tropicalRank (A^m) < tropicalRank (A^(m+1))
```

This theorem says: if the tropical rank sequence of powers is not already stable, then strict growth occurs before ambient saturation. It packages the philosophical claim “growth with `m` up to `n`” into a mathematically robust pigeonhole principle.

A stronger aspirational target, if you can define a suitable nondegeneracy condition, is:

```lean
theorem tropical_rank_pow_strict_mono_until_top
  (n : ℕ) (A : Matrix (Fin n) (Fin n) (WithTop ℤ))
  (h_nd : TropicallyNondegenerate A) :
  ∀ m : ℕ, m + 1 ≤ n →
    tropicalRank (A^m) < n →
    tropicalRank (A^m) < tropicalRank (A^(m+1))
```

This would be a true field-opening result. The hard part is defining `TropicallyNondegenerate A` so that it is both meaningful and provable from combinatorial hypotheses.

Build explicitly on:
- `tropical_rank_bound`
- `tropical_rank_le_dim`
- `tropical_rank1_minor`

The likely architecture is:
1. use `tropical_rank_le_dim` to cap the sequence;
2. use a nondegeneracy witness from a tropical minor to rule out constant rank at low levels;
3. conclude strict increase at some step or on an interval.

---

## Secondary theorem: large image sets from rank growth

This is the more visionary statement. You want a theorem saying that many distinct powers, or many distinct columns of powers, appear once tropical rank becomes large.

A practical formal theorem target:

```lean
theorem card_power_columns_lower_bound
  (n M : ℕ) (A : Matrix (Fin n) (Fin n) (WithTop ℤ))
  (hmono : Monotone (fun m : ℕ => tropicalRank (A^m)))
  (hdistinct : ∀ m < M, tropicalRank (A^m) < tropicalRank (A^(m+1))) :
  M + 1 ≤ ((Finset.range (M+1)).biUnion (fun m =>
    Finset.univ.image (fun j : Fin n => Matrix.col (A^m) j))).card
```

Interpretation: if rank strictly grows along the first `M` powers, then the set of columns appearing among these powers has cardinality at least `M+1`. This is a clean formal bridge from rank growth to image-set growth.

A more dynamic formulation, if easier:

```lean
theorem power_imageSet_large_of_rank_growth
  (n M : ℕ) (A : Matrix (Fin n) (Fin n) (WithTop ℤ))
  (hgrow : ∀ m < M, tropicalRank (A^m) < tropicalRank (A^(m+1))) :
  M + 1 ≤ (powerImageSet A M).card
```

This theorem is important because it translates algebraic complexity (rank) into dynamical complexity (many distinct outputs under iteration). That is the real conceptual breakthrough.

You should also explore a product-growth theorem inspired by the catalog theorem `factoring_space_grows_with_product`:

```lean
theorem tropical_power_image_growth_via_rank_product
  (n M : ℕ) (A : Matrix (Fin n) (Fin n) (WithTop ℤ)) :
  ∃ c : ℕ, c ≤ n ∧
    c * M ≤ (powerImageSet A M).card + n
```

Even a weaker but nontrivial lower bound linking image-set size to accumulated rank increments would be significant.

---

## Tertiary theorem: rank-1 obstruction and first nontrivial growth step

Use `tropical_rank1_minor` to isolate a concrete first-step theorem.

```lean
theorem tropical_rank_ge_two_of_nondegenerate_2x2_minor
  (A : Matrix (Fin 2) (Fin 2) ℝ)
  (hminor : TropicalNonSingular2x2 A) :
  2 ≤ tropicalRank A
```

Then lift this into a power-growth statement:

```lean
theorem tropical_rank_power_not_constant_from_2x2_witness
  (n : ℕ) (A : Matrix (Fin n) (Fin n) ℝ)
  (hminor : ∃ i₁ i₂ j₁ j₂, i₁ ≠ i₂ ∧ j₁ ≠ j₂ ∧
    TropicalNonSingular2x2 (submatrix A (![i₁,i₂]) (![j₁,j₂]))) :
  ∃ m, tropicalRank (A^m) < tropicalRank (A^(m+1)) ∨ tropicalRank (A^m) = n
```

This creates a local-to-global mechanism: a single nontrivial tropical minor seeds eventual rank growth or saturation.

---

## Lean 4 type signature suggestions

Use these as north stars; adapt to actual existing definitions in the repository.

```lean
theorem exists_strict_rank_growth_before_saturation
  (n : ℕ) (A : Matrix (Fin n) (Fin n) (WithTop ℤ))
  (h_nonstable : ∃ m : ℕ, tropicalRank (A^(m+1)) ≠ tropicalRank (A^m))
  : ∃ m : ℕ, m < n ∧ tropicalRank (A^m) < tropicalRank (A^(m+1)) := ...

theorem powerImageSet_card_ge_rank_jumps
  (n M : ℕ) (A : Matrix (Fin n) (Fin n) (WithTop ℤ))
  (hjump : ∀ m < M, tropicalRank (A^m) < tropicalRank (A^(m+1))) :
  M + 1 ≤ (powerImageSet A M).card := ...

theorem tropical_rank_eventually_stable
  (n : ℕ) (A : Matrix (Fin n) (Fin n) (WithTop ℤ)) :
  ∃ N ≤ n, ∀ m ≥ N, tropicalRank (A^m) = tropicalRank (A^N) := ...
```

That last theorem is extremely plausible from bounded monotone growth, but only if you first prove monotonicity. If monotonicity fails in full generality, weaken the statement and discover the right hypothesis. That discovery itself would be valuable.

---

## Proof strategy architecture

### Strategy A: bounded monotone growth of integer-valued complexity
Most promising for the first theorem.

1. **Establish codomain bounds.**
   Use `tropical_rank_le_dim` and/or `tropical_rank_bound` to show
   `tropicalRank (A^m) ≤ n` for all `m`.

2. **Prove or isolate monotonicity under a nondegeneracy hypothesis.**
   If full monotonicity is false, define a hypothesis such as
   `TropicallyNondegenerate A` or `PowerRankMonotone A := Monotone (fun m => tropicalRank (A^m))`.

3. **Apply finite ascent / pigeonhole.**
   Any strictly increasing sequence of naturals bounded by `n` has length at most `n`.
   Hence either saturation occurs by time `n`, or some desired strict jump occurs before then.
   This gives the “up to `n`” phenomenon in a completely formal way.

Why promising: it uses catalog bounds immediately and reduces the hard tropical content to a manageable monotonicity or anti-collapse lemma.

---

### Strategy B: witness growth via tropical minors
Most promising for a truly new theorem.

1. **Encode rank lower bounds by explicit minors.**
   Use `tropical_rank1_minor` as the base case showing that a nontrivial `2 × 2` tropical minor obstructs rank `≤ 1`.

2. **Track witnesses through multiplication.**
   Show that if a witness minor survives or propagates under tropical multiplication, then rank cannot stagnate at too low a level.

3. **Bootstrap from local witnesses to global rank increments.**
   Repeated powering creates new path combinations in the weighted digraph of `A`; these can generate new tropically independent columns/rows.

Why promising: it gives actual tropical substance rather than pure order-theoretic bookkeeping. This is where a publishable new idea may live.

---

### Strategy C: graph-theoretic / semigroup reinterpretation
Best for cross-domain breakthrough and image-set growth.

1. **Interpret `A^m` as path optimization in a weighted directed graph.**
   Entries of `A^m` correspond to optimal path weights of length `m`.

2. **Use path-combinatorics to produce distinct columns or rows.**
   Distinct optimal path profiles induce distinct tropical images. Strong connectivity / branching should force many profiles.

3. **Deduce lower bounds on image-set cardinality from combinatorial branching.**
   Connect rank growth to the number of distinct optimization profiles.

Why promising: this links tropical algebra to automata, shortest-path dynamics, and entropy growth. Even partial formalization could be conceptually transformative.

---

## Cross-domain connections you should explicitly exploit

1. **Graph theory / shortest paths**
   Tropical matrix powers are dynamic programming over weighted digraphs. Rank growth corresponds to growth in diversity of optimal path profiles.

2. **Semigroup growth and entropy**
   The family `{A^m}` is a tropical matrix semigroup. Large image sets suggest a notion of tropical entropy or complexity production under iteration.

3. **Information theory**
   Build on `factoring_space_grows_with_product`. The slogan is:
   **rank growth implies representational richness**.
   If factor spaces grow under products, tropical power images should behave like information expansion in a lossy-but-structured channel.

4. **Combinatorial optimization**
   Tropical multiplication is Bellman-type composition. Rank and image-set growth may quantify how many distinct optimal policies emerge over time.

5. **Control theory / discrete event systems**
   Max-plus and min-plus powers model scheduling and event propagation. A theorem on image-set growth would imply lower bounds on reachable timing profiles.

These are not decorative; they should shape theorem statements and FUTURE_DIRECTIONS.

---

## How to use the catalog theorems concretely

- `tropical_rank_bound`  
  Use as the ambient finiteness principle. If it is stronger than `tropical_rank_le_dim`, make it the main boundedness lemma in every rank-growth proof.

- `tropical_rank_le_dim`  
  This is your default codomain bound:
  `tropicalRank A ≤ n`.
  Apply it to `A^m` for all `m`.

- `tropical_rank1_minor`  
  Use it to manufacture explicit non-rank-1 witnesses. This is likely the key theorem for proving first nontrivial rank jumps or excluding total collapse.

- `factoring_space_grows_with_product`  
  Treat this as a conceptual bridge: repeated product operations enlarge representational/factoring spaces. Translate that philosophy into tropical powers and image-set cardinality.

- `tropical_and_bound`  
  Possibly useful as an auxiliary inequality-combination lemma if you need to combine lower bounds from two tropical conditions. At minimum, check whether it can package bound-composition in image-growth proofs.

---

## Concrete experimental agenda in Lean

You should not only state abstract theorems; define computable examples and test hypotheses.

1. Construct explicit `2×2`, `3×3`, `4×4` tropical matrices with finite entries.
2. Compute or characterize `A`, `A^2`, `A^3`.
3. Compare:
   - tropical ranks,
   - number of distinct columns across powers,
   - support-graph connectivity.
4. Search for:
   - monotone rank growth examples,
   - counterexamples to unconditional monotonicity,
   - hypotheses under which monotonicity becomes true.

If unconditional monotonicity fails, pivot immediately to a sharper theorem with the right hypothesis. A good counterexample is as valuable as a proof.

---

## High-value theorem variants if the main conjecture resists

### Variant 1: eventual stabilization without monotonicity
```lean
theorem finite_range_tropical_rank_powers
  (n : ℕ) (A : Matrix (Fin n) (Fin n) (WithTop ℤ)) :
  Set.Finite (Set.range (fun m : ℕ => tropicalRank (A^m)))
```
This is weaker but very formalizable and still useful.

### Variant 2: distinct powers from distinct ranks
```lean
theorem rank_jump_gives_distinct_power
  (n : ℕ) (A : Matrix (Fin n) (Fin n) (WithTop ℤ))
  {m k : ℕ} (h : tropicalRank (A^m) ≠ tropicalRank (A^k)) :
  A^m ≠ A^k
```
This is elementary but becomes a useful engine for image-set lower bounds.

### Variant 3: image growth from pairwise distinct columns
```lean
theorem distinct_columns_yield_large_image
  (n : ℕ) (S : Finset (Fin n → WithTop ℤ))
  (hS : S ⊆ powerImageSet A M) :
  S.card ≤ (powerImageSet A M).card
```
Trivial in isolation, but useful as a lemma in a structured proof pipeline.

---

## Revolutionary significance

If you can prove even a clean first theorem here, you open a new direction: **tropical dynamics by complexity growth**. The field currently has many static notions of tropical rank and many dynamic notions of powers, but a formal theorem connecting rank escalation to orbit/image expansion would create a bridge between:

- tropical linear algebra,
- weighted automata,
- optimization dynamics,
- discrete event systems,
- entropy-like complexity measures.

This could become the seed of a tropical Perron–Frobenius theory not just of eigenvalues, but of **expressive growth under iteration**.

A strong result here would make it possible to ask:
- when do tropical systems mix?
- when do tropical semigroups have positive entropy?
- can rank growth certify algorithmic hardness of prediction?
- can image-set growth measure controllability in min-plus systems?

That is the frontier.

---

## Deliverables

1. Lean 4 code proving at least one nontrivial theorem above.
2. New definitions if needed, but keep them concrete and reusable.
3. Minimal `sorry`; if a theorem resists, prove the strongest correct variant and document the obstruction.
4. A **FUTURE_DIRECTIONS.md** with **3–5 specific breakthrough next steps**, each including:
   - exact theorem statement,
   - proof strategy sketch,
   - cross-domain significance.

Optional but encouraged:
- `ARTICLE.md` explaining the tropical dynamics perspective,
- explicit example computations,
- a counterexample section if unconditional monotonicity fails.

---

## Application keywords

tropical rank, tropical matrix powers, min-plus algebra, max-plus algebra, weighted digraphs, shortest paths, semigroup growth, image-set complexity, tropical dynamics, discrete event systems, combinatorial optimization, entropy, information richness, tropical minors, formalized mathematics, Lean 4, Mathlib

---

## Final directive

Do not settle for a cosmetic lemma. Either prove a genuine rank-growth theorem, or discover the exact obstruction and convert it into a sharper theorem with hypotheses. In all cases, produce `FUTURE_DIRECTIONS.md` as the launchpad for the next cycle.

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
