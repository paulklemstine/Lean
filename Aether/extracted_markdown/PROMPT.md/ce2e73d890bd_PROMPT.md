## Mode: prove

## Breakthrough Objective

Formalize and prove a sharp finite-field version of Freivalds’ matrix verification theorem in Lean 4, not merely as an algorithmic folklore fact but as a **rank-1 Schwartz–Zippel phenomenon for linear maps over finite fields**. The theorem should expose the structural reason the failure probability is exactly controlled by codimension of a kernel, and should be stated in a way that can immediately generalize to randomized linear sketching, PIT, and derandomization.

This is not just “matrix multiplication checking.” It is the finite-field prototype of a much broader principle:

> **A nonzero linear certificate over a finite field vanishes on at most a 1/q-fraction of random inputs.**

That bridge connects randomized algorithms, polynomial identity testing, coding theory, linear cryptanalysis, and proof-carrying computation.

## Primary Target Theorem

Let `𝔽 = ZMod q` with `q` prime so that `ZMod q` is a field. Let
- `A : Matrix (Fin m) (Fin n) 𝔽`
- `B : Matrix (Fin n) (Fin p) 𝔽`
- `K : Matrix (Fin m) (Fin p) 𝔽`

and assume `K ≠ A ⬝ B`. Then for uniformly random `r : Fin p → 𝔽`, the event
`K.mulVec r = (A ⬝ B).mulVec r`
has probability at most `1 / q`.

The real theorem hiding here is stronger:

> If `M : Matrix (Fin m) (Fin p) 𝔽` is nonzero, then  
> `|{r : Fin p → 𝔽 | M.mulVec r = 0}| ≤ q^(p-1)`,  
> hence the uniform probability is at most `1/q`.

Apply this with `M = K - A ⬝ B`.

## Precise Lean 4 Formalization Targets

You should aim to prove the structural counting lemma first, then derive the probabilistic corollary.

### Core counting theorem
```lean
theorem card_mulVec_eq_zero_le
    {q m p : ℕ} [Fact q.Prime]
    (M : Matrix (Fin m) (Fin p) (ZMod q))
    (hM : M ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0}
      ≤ q ^ (p - 1)
```

### Probability corollary in cardinal form
```lean
theorem freivalds_soundness_card
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A ⬝ B) :
    Fintype.card {r : Fin p → ZMod q // K.mulVec r = (A ⬝ B).mulVec r}
      ≤ q ^ (p - 1)
```

### Probability corollary in `ℚ` or `ℝ`
```lean
theorem freivalds_soundness_prob
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A ⬝ B) :
    ((Fintype.card {r : Fin p → ZMod q // K.mulVec r = (A ⬝ B).mulVec r} : ℚ) /
      Fintype.card (Fin p → ZMod q))
      ≤ (1 : ℚ) / q
```

Since
```lean
Fintype.card (Fin p → ZMod q) = q ^ p
```
this follows from the cardinal theorem.

### Stronger row-witness theorem
A sharper intermediate theorem is often the cleanest proof artifact:
```lean
theorem card_solutions_single_nontrivial_linear_eq
    {q p : ℕ} [Fact q.Prime]
    (w : Fin p → ZMod q)
    (hw : w ≠ 0) (b : ZMod q) :
    Fintype.card {r : Fin p → ZMod q // dotProduct w r = b}
      = q ^ (p - 1)
```

Then deduce:
```lean
theorem card_mulVec_eq_zero_le'
    {q m p : ℕ} [Fact q.Prime]
    (M : Matrix (Fin m) (Fin p) (ZMod q))
    (hM : M ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0}
      = q ^ (p - 1) ∨
    Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0} < q ^ (p - 1)
```
and hence the desired `≤`.

## Why This Is a Breakthrough

Formalizing Freivalds in Lean is valuable, but formalizing it in the **right structural form** is field-opening:

1. It gives a certified bridge from matrix verification to **linear-algebraic PIT**.
2. It creates reusable infrastructure for counting fibers of nonzero linear maps over finite fields.
3. It opens a path toward formalized **Schwartz–Zippel**, **DeMillo–Lipton**, and **soundness analyses of randomized proof systems**.
4. It links algebraic verification to coding theory: the kernel of a nonzero linear functional has codimension 1, hence exact density `1/q`.
5. It provides a blueprint for moving from exact verification to **streaming sketches**, **interactive proofs**, and **linear PCP/IOP soundness**.

This is how one turns a folklore randomized algorithm into a foundational certified theorem about finite-field geometry.

## Most Promising Proof Architecture

### Strategy A: Row-witness + affine hyperplane counting
This is the most promising route.

1. Set `M = K - A ⬝ B`. From `hne : K ≠ A ⬝ B`, derive `M ≠ 0`.
2. Extract a nonzero row `i : Fin m` such that `M i ≠ 0` as a vector in `Fin p → ZMod q`.
3. Show that if `M.mulVec r = 0`, then in particular the `i`-th coordinate gives a single nontrivial linear equation
   `dotProduct (M i) r = 0`.
4. Count the number of solutions to one nontrivial linear equation over `ZMod q`: exactly `q^(p-1)`.
5. Conclude the solution set of `M.mulVec r = 0` injects into that hyperplane, hence has cardinality at most `q^(p-1)`.

Why this is best:
- avoids developing full rank-nullity machinery for matrices over finite fields,
- uses only explicit coordinate algebra,
- gives the exact combinatorial heart of Freivalds,
- likely minimizes `sorry` by relying on elementary `Fin`/`Fintype` arguments.

### Strategy B: Linear map / kernel dimension / rank-nullity
This is conceptually cleaner if Mathlib support is sufficient.

1. Interpret `M.mulVec` as a linear map
   ```lean
   (Fin p → ZMod q) →ₗ[ZMod q] (Fin m → ZMod q)
   ```
2. Show nonzero matrix implies nonzero linear map.
3. Use that a nonzero linear map has kernel of dimension at most `p - 1`.
4. Since a finite-dimensional vector space over `ZMod q` of dimension `d` has cardinality `q^d`, conclude
   `|ker| ≤ q^(p-1)`.

Why this is powerful:
- immediately generalizes to arbitrary finite-dimensional vector spaces,
- aligns with coding theory and linear-algebraic complexity,
- gives a reusable theorem beyond matrices indexed by `Fin`.

Risk:
- dimension/cardinality lemmas over `Finite` vector spaces may require more setup than Strategy A.

### Strategy C: Polynomial identity testing viewpoint
This is the visionary cross-domain route.

1. Regard each coordinate of `(K - A ⬝ B).mulVec r` as a degree-1 polynomial in the variables `r_j`.
2. Since `K ≠ A ⬝ B`, some coordinate polynomial is nonzero.
3. Invoke or adapt finite-field vanishing bounds from
   `circuit_vanishes_on_finite_field_restricted`.
4. Specialize the general PIT statement to linear forms to get the `1/q` bound.

Why this matters:
- it connects Freivalds directly to your catalog’s Nullstellensatz/PIT infrastructure,
- it turns matrix verification into a corollary of algebraic identity testing,
- it suggests a unifying theorem: nonzero low-degree circuits vanish on a bounded fraction of finite-field points.

This is the right second theorem after the elementary proof is in place.

## Recommended Development Order

1. Prove a lemma that a nonzero vector over `Fin p → ZMod q` has a coordinate with nonzero coefficient.
2. Prove the exact solution count for one nontrivial linear equation:
   `dotProduct w r = b` has exactly `q^(p-1)` solutions when `w ≠ 0`.
3. Derive the kernel bound for `M.mulVec`.
4. Rewrite the Freivalds event as
   `(K - A ⬝ B).mulVec r = 0`.
5. Convert cardinal bound to probability bound.

## Key Supporting Lemmas You Will Likely Need

Possible useful statements to formulate explicitly:

```lean
theorem exists_ne_zero_of_ne_zero_vec
    {q p : ℕ} [Fact q.Prime]
    {w : Fin p → ZMod q} (hw : w ≠ 0) :
    ∃ j : Fin p, w j ≠ 0
```

```lean
theorem exists_nonzero_row_of_matrix_ne_zero
    {q m p : ℕ} [Fact q.Prime]
    {M : Matrix (Fin m) (Fin p) (ZMod q)} (hM : M ≠ 0) :
    ∃ i : Fin m, M i ≠ 0
```

```lean
theorem mulVec_sub
    {q m n p : ℕ} [Fact q.Prime]
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (L : Matrix (Fin m) (Fin p) (ZMod q))
    (r : Fin p → ZMod q) :
    (K - L).mulVec r = K.mulVec r - L.mulVec r
```

```lean
theorem eq_mulVec_iff_sub_mulVec_eq_zero
    {q m n p : ℕ} [Fact q.Prime]
    (K L : Matrix (Fin m) (Fin p) (ZMod q))
    (r : Fin p → ZMod q) :
    K.mulVec r = L.mulVec r ↔ (K - L).mulVec r = 0
```

For the hyperplane-counting theorem, a useful approach is to choose a coordinate `j` with `w j ≠ 0`, solve uniquely for `r j` in terms of the remaining coordinates, and build an explicit equivalence:
```lean
{r : Fin p → ZMod q // dotProduct w r = b} ≃ (Fin (p - 1) → ZMod q)
```
or some equivalent type of “all coordinates except `j`”.

If building a direct equivalence over deleted coordinates is annoying, use:
- a decomposition of functions on `Fin p` into one distinguished coordinate plus the rest,
- or a `Fin.cons` / `Fin.tail` parametrization after transporting `j` to `0` via an equivalence.

## Cross-Domain Connections You Should Make Explicit

### 1. Polynomial identity testing
The theorem is the degree-1 case of Schwartz–Zippel over finite fields. Connect it to
`circuit_vanishes_on_finite_field_restricted`:
- Freivalds becomes a PIT statement for the polynomial vector `(K - AB)r`.
- This suggests a later theorem for matrix products whose entries are polynomially parameterized.

### 2. Coding theory
A nonzero row `w` defines a parity-check equation. The set
`{r | dotProduct w r = 0}`
is a linear code of codimension 1 and size `q^(p-1)`. Freivalds’ soundness is exactly the statement that a false product claim is accepted only on one coset of a hyperplane.

### 3. Cryptography and linear sketches
This is the soundness core of random linear fingerprinting:
- randomized equality testing,
- streaming verification,
- vector commitment checks,
- PCP/IOP low-degree consistency checks.

### 4. Quantum/classical verification contrast
Use `insufficient_qubits_theorem` as philosophical contrast: tiny random linear witnesses can certify large algebraic claims classically. There is a complexity-theoretic story here about verification power versus representation size.

### 5. Bayesian verification / evidence accumulation
A stretch connection to `bayes_theorem`: repeated Freivalds trials exponentially suppress posterior belief in a false claim. Once the one-shot soundness theorem is formalized, a follow-up theorem can prove:
```lean
Pr[all t independent trials accept a false claim] ≤ q^(-t)
```
This is exactly the algebraic engine behind probabilistic evidence accumulation.

## Building on Catalog Theorems

You must explicitly leverage the catalog where meaningful, not decoratively.

1. `circuit_vanishes_on_finite_field_restricted`
   - Use it as the conceptual umbrella: Freivalds is a linear/circuit-specialized PIT theorem.
   - If feasible, derive a second theorem showing Freivalds as a corollary of finite-field circuit non-vanishing bounds.

2. `bayes_theorem`
   - Use it in a follow-on corollary about posterior confidence after repeated successful checks.
   - Even if not needed in the main proof, mention it as a formal application theorem to pursue immediately after soundness.

3. `smooth_probability_bound`
   - Use as a stylistic precedent for proving explicit numerical probability bounds from combinatorial counts.

4. `insufficient_qubits_theorem`
   - Use in framing: randomized algebraic certificates can be remarkably information-efficient; this motivates a verified theory of compressed witnesses.

The idempotent Hilbert basis theorem is probably not directly useful in the first proof, but it may become relevant if you generalize from linear verification to semiring/tropical certificate systems.

## Concrete Theorem Variants Worth Attempting If Momentum Builds

### Exact acceptance probability theorem
If `rank(M) = 1`, then the acceptance probability is exactly `1/q`. More generally:
```lean
theorem mulVec_eq_zero_prob_exact
    {q m p : ℕ} [Fact q.Prime]
    (M : Matrix (Fin m) (Fin p) (ZMod q)) :
    ((Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0} : ℚ) /
      q^p)
      = (1 : ℚ) / q^(Module.finrank (ZMod q) M.toLinearMap.range)
```
or an equivalent rank/kernel-cardinality statement.

### Repeated-trial amplification
```lean
theorem freivalds_t_fold_soundness
    {q m n p t : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A ⬝ B) :
    -- probability all t independent random vectors accept
    ... ≤ (1 : ℚ) / q^t
```

### General linear-map theorem
Replace matrices over `Fin` by arbitrary finite-dimensional vector spaces:
```lean
theorem nonzero_linear_map_kernel_density_le
    {q : ℕ} [Fact q.Prime]
    (V W : Type*) [AddCommGroup V] [Module (ZMod q) V]
    [AddCommGroup W] [Module (ZMod q) W]
    [Finite V] [Finite W] [FiniteDimensional (ZMod q) V]
    (f : V →ₗ[(ZMod q)] W) (hf : f ≠ 0) :
    Fintype.card f.ker ≤ (Fintype.card V) / q
```

This is the theorem that truly opens the field.

## Lean-Specific Advice

- Prefer `[Fact q.Prime]` over `[Field (ZMod q)]`; this gives the field instance canonically and avoids awkward assumptions.
- Use `Matrix.mulVec` rather than raw matrix-vector multiplication notation if it simplifies rewriting.
- The event
  `K.mulVec r = (A ⬝ B).mulVec r`
  should be rewritten as
  `(K - A ⬝ B).mulVec r = 0`
  as early as possible.
- For finite counting, subtypes are often easier than `Finset.filter` until the final cardinality translation.
- Search Mathlib for:
  - `Fintype.card_fun`
  - `Fintype.card_subtype_iff`
  - `Matrix.mulVec`
  - `LinearMap.ker`
  - `FiniteDimensional.finrank`
  - cardinality lemmas for finite vector spaces over finite fields.

## What Would Make This Paradigm-Shifting

Do not stop at the folklore theorem. Package the result so it becomes infrastructure for a future theory of:

- certified randomized linear algebra,
- formalized PIT over finite fields,
- soundness amplification,
- linear sketch verification,
- finite-field hyperplane measure,
- coding-theoretic proof systems.

The genuinely new contribution is not “Freivalds in Lean”; it is the extraction of the **finite-field hyperplane counting engine** as a reusable formal theorem.

## Deliverables

1. A Lean file proving the main theorem and its cardinal/probability corollaries.
2. Supporting lemmas on nonzero rows, hyperplane solution counts, and event rewriting.
3. At least one cross-domain corollary, ideally repeated-trial amplification or PIT-specialization.
4. Minimize `sorry`; if one hard combinatorial equivalence remains, isolate it behind a sharply stated lemma rather than scattering placeholders.

## Application Keywords

Freivalds algorithm, finite fields, matrix verification, randomized algorithms, soundness bound, polynomial identity testing, Schwartz–Zippel, linear sketches, coding theory, affine hyperplanes, kernel counting, derandomization, proof verification, streaming algorithms, algebraic complexity, certified probabilistic computation.

## Mandatory FUTURE_DIRECTIONS.md

Produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps at breakthrough level. Include specific theorem statements or formalization targets, not vague topics. Strong candidates:

1. **General nonzero linear map kernel-density theorem** over arbitrary finite-dimensional `𝔽_q`-spaces.
2. **Repeated Freivalds amplification theorem** with exact `q^-t` soundness.
3. **Freivalds as a corollary of finite-field PIT** using `circuit_vanishes_on_finite_field_restricted`.
4. **Rank-sensitive exact acceptance probability theorem** in terms of kernel dimension.
5. **Streaming/interactive verification theorem** for batched matrix products via random linear fingerprints.

Be bold: build the theorem in the form that future formalized randomized algebra can stand on.

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

Research domain: Algebra
Research mode: prove
