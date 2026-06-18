## Assignment: Cyclic groups — cyclotomic subfields as a formal bridge between finite group structure, field extensions, and arithmetic construction

**Mode:** `prove`

Prove genuinely new theorems around the prime cyclotomic extension
\[
\mathbb{Q}(\zeta_p)/\mathbb{Q}
\]
for an odd prime \(p\), with a focus on **explicit intermediate subfields indexed by divisors of \(p-1\)** and the resulting **cyclic Galois correspondence**. The goal is not to restate textbook algebra, but to formalize a reusable machine in Lean 4: from cyclicity of \((\mathbb{Z}/p\mathbb{Z})^\times\), manufacture subextensions of prescribed degree and package them in a way that can power later work in class field theory, explicit algebraic constructions, and arithmetic cryptography.

This is a breakthrough direction because it turns the slogan “prime cyclotomic extensions are cyclic” into an **explicit certified subfield-extraction framework**. If done cleanly, this opens a formal path from finite cyclic groups to:
- constructive Galois correspondence,
- explicit degree-\(d\) abelian extensions of \(\mathbb{Q}\),
- subgroup/subfield duality usable in computational number theory,
- and eventually certified infrastructure for cyclotomic-class-field style arguments.

### Core target theorem

For an odd prime \(p\), the Galois group of the \(p\)-th cyclotomic field over \(\mathbb{Q}\) is cyclic of order \(p-1\). Therefore every divisor \(d \mid (p-1)\) gives an intermediate field of degree exactly \(d\) over \(\mathbb{Q}\).

You should aim to formalize a theorem of the following shape, possibly after adapting to available Mathlib APIs for cyclotomic fields and intermediate fields:

```lean
theorem exists_intermediateField_of_prime_cyclotomic_of_dvd
  (p d : ℕ)
  (hp : p.Prime)
  (hpodd : p ≠ 2)
  (hd : d ∣ (p - 1)) :
  ∃ K : IntermediateField ℚ (CyclotomicField p ℚ),
    FiniteDimensional.finrank ℚ K = d := by
  sorry
```

If `CyclotomicField p ℚ` is not the most API-compatible object, replace it with the concrete splitting field / adjoin formulation that Mathlib supports best, but keep the mathematical content unchanged.

A stronger and even more valuable version is:

```lean
theorem exists_intermediateField_of_prime_cyclotomic_of_dvd_with_galois_group
  (p d : ℕ)
  (hp : p.Prime)
  (hpodd : p ≠ 2)
  (hd : d ∣ (p - 1)) :
  ∃ K : IntermediateField ℚ (CyclotomicField p ℚ),
    FiniteDimensional.finrank ℚ K = d ∧
    IsGalois ℚ K := by
  sorry
```

and, if the Galois correspondence API is sufficiently accessible, the most conceptually powerful statement is:

```lean
theorem prime_cyclotomic_galois_group_has_subgroup_of_every_divisor
  (p d : ℕ)
  (hp : p.Prime)
  (hpodd : p ≠ 2)
  (hd : d ∣ (p - 1)) :
  ∃ H : Subgroup (Gal (CyclotomicField p ℚ) ℚ),
    Fintype.card H = (p - 1) / d := by
  sorry
```

together with the intermediate-field corollary via Galois correspondence.

### Precise mathematical theorem statement

The exact mathematics to target is:

> **Theorem.** Let \(p\) be an odd prime. For every positive integer \(d\) with \(d \mid (p-1)\), there exists an intermediate field
> \[
> \mathbb{Q} \subseteq K \subseteq \mathbb{Q}(\zeta_p)
> \]
> such that \([K:\mathbb{Q}] = d\). Equivalently, there exists a subgroup of index \(d\) in
> \[
> \mathrm{Gal}(\mathbb{Q}(\zeta_p)/\mathbb{Q}) \cong (\mathbb{Z}/p\mathbb{Z})^\times,
> \]
> and since this Galois group is cyclic of order \(p-1\), such subgroups exist uniquely for every divisor \(d \mid (p-1)\).

A second theorem, more explicit and potentially easier to realize in Lean if full cyclotomic Galois APIs are awkward:

> **Subgroup existence theorem for cyclic groups of prime-minus-one order.**
> For an odd prime \(p\) and each \(d \mid (p-1)\), every cyclic group \(G\) of order \(p-1\) has a unique subgroup of order \(d\).

Lean signature:

```lean
theorem exists_unique_subgroup_card_of_dvd_prime_pred
  (p d : ℕ)
  (hp : p.Prime)
  (hpodd : p ≠ 2)
  (hd : d ∣ (p - 1))
  (G : Type*)
  [Group G]
  [Finite G]
  (hcyc : IsCyclic G)
  (hcard : Fintype.card G = p - 1) :
  ∃! H : Subgroup G, Fintype.card H = d := by
  sorry
```

This theorem is not merely group theory bookkeeping: it is the engine that drives the cyclotomic subfield construction.

### Why this is nontrivial and worth doing

The field-opening value is in **formal explicitness**. There is a huge difference between:
- “the Galois group is cyclic, so by correspondence there are subfields,” and
- a Lean-certified theorem that, for any divisor \(d \mid p-1\), constructs or certifies an actual intermediate field with exact degree.

That second form becomes reusable infrastructure for:
- certified extraction of quadratic, cubic, quartic, and higher abelian subfields of cyclotomic fields,
- explicit formal number theory,
- verified cryptographic constructions built from subgroup structure,
- and future formalized class field theoretic experiments.

This also naturally connects to the catalog theorem `prime_degree_divides_galois_order`: once you have explicit subfields of prescribed degree, you can create a two-way bridge between **degree constraints** and **Galois-group divisibility**, moving from abstract divisibility theorems to constructive field realizations.

## Proof strategy architecture

### Strategy A: Cyclic group → subgroup of every divisor → Galois correspondence
This is the most promising route.

1. Prove or import that \(\mathrm{Gal}(\mathbb{Q}(\zeta_p)/\mathbb{Q})\) is finite cyclic of cardinality \(p-1\).
2. Use the standard theorem for finite cyclic groups: for every divisor \(d\) of the group order, there exists a unique subgroup of order \(d\).
3. Transfer this subgroup through Galois correspondence to an intermediate field \(K\), and then use the degree-index formula
   \[
   [K:\mathbb{Q}] = [\mathrm{Gal}(L/\mathbb{Q}) : H] = d
   \]
   with \(L = \mathbb{Q}(\zeta_p)\).

Why this is best: it separates concerns cleanly. Group theory is robust in Mathlib; Galois correspondence is delicate but conceptually exact. If the cyclotomic-field API is sufficient, this gives the strongest theorem with the cleanest semantics.

### Strategy B: Work first at the level of \((ZMod p)ˣ\), then transport to automorphisms
1. Prove that for prime \(p\), the unit group `(ZMod p)ˣ` is cyclic of cardinality \(p-1\).
2. Build subgroups of `(ZMod p)ˣ` of every divisor order.
3. Use the known isomorphism
   \[
   \mathrm{Gal}(\mathbb{Q}(\zeta_p)/\mathbb{Q}) \cong ( \mathbb{Z}/p\mathbb{Z})^\times
   \]
   to transport subgroup existence to the Galois group, then apply Galois correspondence.

Why this may be easier: Mathlib often has stronger concrete APIs for `ZMod` and units than for abstract cyclotomic Galois groups. This route is ideal if the isomorphism theorem is available or can be packaged from existing components.

### Strategy C: Degree-first construction via fixed fields
1. Construct a subgroup \(H\) of order \((p-1)/d\) in the cyclic Galois group.
2. Define \(K\) as the fixed field of \(H\).
3. Prove \([K:\mathbb{Q}] = d\) directly from the fixed-field theorem.

Why this is useful: if the intermediate-field API around `fixedField` is more mature than the full correspondence equivalence, this can avoid some categorical overhead while preserving the mathematical punch.

## Concrete theorem package to pursue

You should not stop at a single theorem. Build a coherent mini-theory with 3 layers:

### Layer 1: Pure finite cyclic group infrastructure
```lean
theorem cyclic_group_exists_subgroup_of_card_dvd
  (G : Type*) [Group G] [Finite G]
  (hcyc : IsCyclic G)
  (d : ℕ)
  (hd : d ∣ Fintype.card G) :
  ∃ H : Subgroup G, Fintype.card H = d := by
  sorry
```

and ideally uniqueness:
```lean
theorem cyclic_group_unique_subgroup_of_card
  (G : Type*) [Group G] [Finite G]
  (hcyc : IsCyclic G)
  (d : ℕ)
  (hd : d ∣ Fintype.card G) :
  ∃! H : Subgroup G, Fintype.card H = d := by
  sorry
```

### Layer 2: Prime cyclotomic specialization
```lean
theorem prime_cyclotomic_galois_group_cyclic
  (p : ℕ) (hp : p.Prime) (hpodd : p ≠ 2) :
  IsCyclic (Gal (CyclotomicField p ℚ) ℚ) := by
  sorry
```

```lean
theorem prime_cyclotomic_galois_group_card
  (p : ℕ) (hp : p.Prime) (hpodd : p ≠ 2) :
  Fintype.card (Gal (CyclotomicField p ℚ) ℚ) = p - 1 := by
  sorry
```

### Layer 3: Intermediate field extraction
```lean
theorem exists_intermediateField_prime_cyclotomic_finrank_eq
  (p d : ℕ)
  (hp : p.Prime)
  (hpodd : p ≠ 2)
  (hd : d ∣ (p - 1)) :
  ∃ K : IntermediateField ℚ (CyclotomicField p ℚ),
    FiniteDimensional.finrank ℚ K = d := by
  sorry
```

If possible, strengthen to:
```lean
theorem exists_unique_intermediateField_prime_cyclotomic_finrank_eq
  (p d : ℕ)
  (hp : p.Prime)
  (hpodd : p ≠ 2)
  (hd : d ∣ (p - 1)) :
  ∃! K : IntermediateField ℚ (CyclotomicField p ℚ),
    FiniteDimensional.finrank ℚ K = d := by
  sorry
```

Be careful: uniqueness of the subgroup in a cyclic group is standard, but uniqueness of the intermediate field of a given degree follows only once the Galois correspondence is set up cleanly.

## How to build on the catalog theorems

### 1. `prime_degree_divides_galois_order`
File: `Bridges/GaloisNeuralCorrespondence.lean`

Use it as a bridge theorem, not merely a citation. Once you produce an intermediate field \(K/\mathbb{Q}\) of prime degree \(q\), this theorem should imply:
\[
q \mid |\mathrm{Gal}(L/\mathbb{Q})|
\]
for suitable Galois closure / ambient field \(L\). In the cyclotomic prime case, this becomes a certified mechanism showing that **prime degree subextensions force divisibility by \(q\) in \(p-1\)**. This can support a converse-style theorem:

```lean
theorem prime_degree_subfield_of_prime_cyclotomic_implies_dvd_pred
  (p q : ℕ)
  (hp : p.Prime)
  (hpodd : p ≠ 2)
  (hq : q.Prime)
  (K : IntermediateField ℚ (CyclotomicField p ℚ))
  (hdeg : FiniteDimensional.finrank ℚ K = q) :
  q ∣ (p - 1) := by
  sorry
```

This is a beautiful arithmetic compression of the whole story.

### 2. `krull_height_theorem_security_prime`
File: `Speculative/AutoResearch/AlgebraicInvariantCryptography.lean`

Even if this theorem lives in a different domain, use it conceptually: prime-index or prime-degree structures often control “security parameters” or rigidity thresholds. Your cyclotomic subfield lattice can become a certified source of structured finite cyclic quotients and subgroup chains. This is exactly the kind of algebraic invariant that could later feed formal cryptographic hardness arguments.

### 3. `hasse_bound_implies_group_order`
File: `Computation/ResearchQuestions.lean`

Use this as a cross-domain inspiration: Hasse-type constraints bound group sizes of arithmetic objects. Your work gives exact subgroup realizability in the cyclotomic setting. A future bridge theorem could compare:
- bounded arithmetic group orders from elliptic curves,
- versus exact divisor-realization in cyclotomic Galois groups.

This is a route toward a formal “arithmetic symmetry engineering” framework.

## Cross-domain connections to emphasize

### Algebraic number theory × cryptography
Subgroups of \((\mathbb{Z}/p\mathbb{Z})^\times\) drive Diffie–Hellman-style arithmetic. Formalizing the corresponding cyclotomic subfields creates a certified dictionary between:
- subgroup structure in finite multiplicative groups,
- and field-theoretic symmetry layers in cyclotomic extensions.

This is a possible foundation for **verified algebraic cryptography** and explicit abelian extension generation.

### Galois theory × representation learning / symmetry
The theorem `prime_degree_divides_galois_order` already hints at a symmetry-degree principle. Your cyclotomic construction turns abstract divisibility into explicit symmetry decomposition. That is mathematically analogous to extracting invariant latent factors indexed by subgroup structure. Even if speculative, this is exactly the kind of bridge that opens new formal sciences.

### Cyclotomic fields × combinatorial lattice theory
The intermediate fields of a cyclic Galois extension form a divisor lattice. Formalizing this cleanly suggests later theorems identifying:
- intermediate-field lattice,
- subgroup lattice,
- divisor poset of \(p-1\).

A strong theorem here would be:

```lean
theorem intermediateField_orderIso_divisors_prime_pred
  (p : ℕ)
  (hp : p.Prime)
  (hpodd : p ≠ 2) :
  Nonempty (
    IntermediateField ℚ (CyclotomicField p ℚ) ≃o
    OrderDual {d : ℕ // d ∣ (p - 1)}
  ) := by
  sorry
```

This is highly ambitious, but if achieved it would be genuinely field-opening formal mathematics.

## Implementation notes for Lean 4

Use concrete types where possible:
- `ℕ`, `ZMod p`, `Units (ZMod p)`, `Subgroup G`, `IntermediateField ℚ L`.
- If `CyclotomicField p ℚ` is cumbersome, define the ambient field via adjoin of a primitive root or splitting field of `cyclotomic p ℚ`.
- Lean may prefer statements in terms of `Fintype.card`, `FiniteDimensional.finrank`, and subgroup index.

Look for existing Mathlib theorems about:
- cyclicity of `Units (ZMod p)` for prime `p`,
- cardinality of units modulo a prime,
- `IsCyclic` subgroup existence theorems,
- `IntermediateField` and fixed fields,
- `IsGalois`,
- `Gal`, `fixedField`, and finite-dimensionality.

If the full theorem is blocked by API friction, prove the strongest transportable version at the subgroup level first, then add a carefully isolated bridge theorem to intermediate fields.

## Experimental theorem variants worth trying

1. **Quadratic subfield existence**
   For odd prime \(p\), there exists a unique quadratic intermediate field of \(\mathbb{Q}(\zeta_p)\) iff \(2 \mid (p-1)\), which is automatic.

```lean
theorem exists_unique_quadratic_subfield_of_prime_cyclotomic
  (p : ℕ)
  (hp : p.Prime)
  (hpodd : p ≠ 2) :
  ∃! K : IntermediateField ℚ (CyclotomicField p ℚ),
    FiniteDimensional.finrank ℚ K = 2 := by
  sorry
```

2. **Prime degree criterion**
   For prime \(q\), there exists a degree-\(q\) subfield iff \(q \mid p-1\).

```lean
theorem exists_prime_degree_subfield_iff
  (p q : ℕ)
  (hp : p.Prime)
  (hpodd : p ≠ 2)
  (hq : q.Prime) :
  (∃ K : IntermediateField ℚ (CyclotomicField p ℚ),
      FiniteDimensional.finrank ℚ K = q) ↔ q ∣ (p - 1) := by
  sorry
```

This is especially elegant and would strongly leverage `prime_degree_divides_galois_order`.

3. **Uniqueness by degree in cyclic extensions**
   Generalize beyond cyclotomic fields:

```lean
theorem unique_intermediateField_of_finrank_in_cyclic_galois_extension
  (K L : Type*) [Field K] [Field L] [Algebra K L]
  [FiniteDimensional K L]
  (hgal : IsGalois K L)
  (hcyc : IsCyclic (Gal L K))
  (d : ℕ)
  (hd : d ∣ FiniteDimensional.finrank K L) :
  ∃! E : IntermediateField K L, FiniteDimensional.finrank K E = d := by
  sorry
```

This is the real prize. It would become a reusable theorem across all cyclic Galois extensions, with the cyclotomic prime case as a corollary.

## Application keywords

cyclotomic fields, cyclic Galois groups, intermediate fields, subgroup lattice, divisor poset, class field theory, formal algebraic number theory, certified field extensions, finite cyclic groups, cryptographic subgroup structure, verified abelian extensions, Lean 4 Mathlib, Galois correspondence, explicit subfield construction

## Deliverables

1. Lean 4 theorem files proving the subgroup and intermediate-field results above.
2. Minimal `sorry`; isolate any unavoidable API gap into clearly named lemmas.
3. A `FUTURE_DIRECTIONS.md` that contains **3–5 specific next theorems**, each with:
   - precise theorem statement,
   - expected Lean signature,
   - proof strategy,
   - cross-domain significance.

### Required FUTURE_DIRECTIONS.md content
Include at least these candidate directions:

1. **Order-isomorphism between intermediate fields and divisors of \(p-1\)**  
2. **Prime-degree subfield iff divisibility of \(p-1\)**  
3. **General cyclic Galois extension uniqueness-by-degree theorem**  
4. **Explicit real subfield formalization via \(\zeta_p + \zeta_p^{-1}\)**  
5. **Cryptographic bridge: subgroup hardness parameters from cyclotomic subfield towers**

Be bold: the correct outcome is not a small lemma, but a formal architecture for explicit cyclic extension theory.

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

Research domain: Speculative
Research mode: prove
