## Assignment: Construct a counterexample and turn it into a structural separation theorem

Prove a genuinely clarifying negative result: **tropical rank and tropical factor rank do not satisfy any reverse inequality**, and exhibit an explicit infinite family with maximal separation. Then push beyond the raw counterexample and formalize the mechanism that creates the gap.

This is not a toy obstruction. It is the tropical analogue of a foundational separation between “intrinsic combinatorial dimension” and “extended formulation complexity.” If formalized cleanly, it opens a bridge from tropical linear algebra to communication complexity, extension complexity, and min-plus algorithmics.

---

## Mode: `prove`

## Primary Target

Work over the tropical semiring `Tropical (WithTop ℝ)` or an equivalent min-plus model already convenient in Mathlib/your local development. Let tropical addition be `inf`/`min` and tropical multiplication be ordinary addition.

Define the `n × n` tropical identity-like matrix
\[
I^{\trop}_{ij} =
\begin{cases}
0 & i=j,\\
\infty & i\neq j.
\end{cases}
\]

The research goal is to prove that this matrix has **small tropical rank** but **maximal factor rank**, yielding a sharp separation.

---

## Precise Theorem Statement

There is a likely typo in the seed prompt: the tropical identity matrix should **not** have tropical rank `1` under standard notions of tropical rank; the meaningful and robust counterexample statement is that it has **full factor rank**, while its tropical rank remains governed by a different notion and does not admit a reverse bound from factor rank. The strongest clean theorem to target is:

### Theorem A: Exact factor-rank of tropical identity
For every `n ≥ 1`, the tropical factor rank of the tropical identity matrix is exactly `n`.

### Theorem B: No reverse inequality from tropical rank to factor rank
For every function `f : ℕ → ℕ`, there exists a tropical matrix `M` such that
\[
\operatorname{factorRank}(M) > f(\operatorname{tropicalRank}(M)).
\]
A concrete infinite family should be extracted if your formal definitions support it.

### Theorem C: Product subadditivity for factor rank
If `C = A ⊗ B`, then
\[
\operatorname{factorRank}(C) \le \min(\operatorname{factorRank}(A), \operatorname{factorRank}(B)).
\]
or at least the weaker but still important
\[
\operatorname{factorRank}(A ⊗ B) \le \operatorname{factorRank}(A), \qquad
\operatorname{factorRank}(A ⊗ B) \le \operatorname{factorRank}(B),
\]
depending on your factorization definition.

This turns the counterexample into a structural theory: factor rank behaves like extension complexity under composition, while tropical rank behaves differently.

---

## Suggested Lean 4 Type Signatures

You will need to adapt these to the exact existing definitions in your files, but aim for statements of this shape.

```lean
def tropIdMatrix (n : ℕ) : Matrix (Fin n) (Fin n) (WithTop ℝ) :=
  fun i j => if i = j then 0 else ⊤
```

If factor rank is defined via existence of `U : Matrix (Fin n) (Fin r) _` and `V : Matrix (Fin r) (Fin n) _` with `M = U ⊗ V`, target:

```lean
theorem factorRank_tropId_eq (n : ℕ) :
    tropicalFactorRank (tropIdMatrix n) = n
```

or with a positivity assumption if your rank convention gives `0` for empty matrices:

```lean
theorem factorRank_tropId_eq_of_pos {n : ℕ} (hn : 0 < n) :
    tropicalFactorRank (tropIdMatrix n) = n
```

For the separation theorem:

```lean
theorem no_reverse_bound_tropicalRank_factorRank :
    ¬ ∃ f : ℕ → ℕ, ∀ n (M : Matrix (Fin n) (Fin n) (WithTop ℝ)),
      tropicalFactorRank M ≤ f (tropicalRank M)
```

If full generality is too definition-heavy, first prove an infinite-family version:

```lean
theorem exists_large_factorRank_fixed_tropicalRank
    (k : ℕ) :
    ∀ N : ℕ, ∃ n ≥ N, ∃ M : Matrix (Fin n) (Fin n) (WithTop ℝ),
      tropicalRank M ≤ k ∧ n ≤ tropicalFactorRank M
```

For product behavior:

```lean
theorem tropicalFactorRank_mul_le_left
    {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) (WithTop ℝ))
    (B : Matrix (Fin n) (Fin p) (WithTop ℝ)) :
    tropicalFactorRank (A ⊗ₜ B) ≤ tropicalFactorRank A
```

```lean
theorem tropicalFactorRank_mul_le_right
    {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) (WithTop ℝ))
    (B : Matrix (Fin n) (Fin p) (WithTop ℝ)) :
    tropicalFactorRank (A ⊗ₜ B) ≤ tropicalFactorRank B
```

If `⊗ₜ` is not already defined, use your tropical matrix multiplication notation.

---

## What makes this a breakthrough

A formalized separation theorem here does three things at once:

1. **It prevents false transfer principles.**  
   Many researchers instinctively import classical-rank intuition into tropical settings. A machine-checked obstruction theorem tells us exactly where that analogy breaks.

2. **It identifies factor rank as an extension-complexity invariant.**  
   This reframes tropical factorization as a complexity measure, not just a linear-algebraic one.

3. **It opens a new formal bridge to complexity theory.**  
   Once the separation is in Lean, one can formalize tropical lower bounds as communication/extension lower bounds, a direction that is still startlingly underdeveloped in proof assistants.

---

## Proof Strategy Architecture

### Strategy 1: Support-pattern rigidity for the tropical identity
This is the most promising route for Theorem A.

**Step 1.** Characterize a tropical rank-1 matrix.  
A tropical rank-1 matrix has entries of the form
\[
R_{ij} = u_i + v_j.
\]
Formalize that any finite entry pattern in such a matrix is a rectangle:
if `R i j`, `R i' j'` are finite, then so are `R i j'` and `R i' j`.

**Step 2.** Show the tropical identity support cannot be covered by fewer than `n` rank-1 supports.  
The support of `tropIdMatrix n` is exactly the diagonal. But any nontrivial rectangle in `Fin n × Fin n` with more than one point creates an off-diagonal finite entry, impossible for `tropIdMatrix`. Therefore each rank-1 summand can contribute to at most one diagonal position.

**Step 3.** Construct the matching upper bound with `n` summands.  
Write
\[
I^\trop = \bigoplus_{k=1}^n u^{(k)} \odot (v^{(k)})^T
\]
where each summand places `0` at `(k,k)` and `∞` elsewhere. This gives factor rank `≤ n`; Step 2 gives `≥ n`.

Why this is best: it is combinatorial, exact, and formalization-friendly. It avoids delicate determinant-style tropical rank definitions.

---

### Strategy 2: Boolean shadow / support reduction
This is the cleanest conceptual bridge to complexity theory.

**Step 1.** Map a tropical matrix to its support relation:
\[
\mathrm{supp}(M)_{ij} := (M_{ij} < \infty).
\]
For factor rank decompositions, prove that support of a tropical rank-1 summand is a combinatorial rectangle.

**Step 2.** Reduce factor-rank lower bounds to rectangle covering lower bounds.  
The diagonal relation on `[n] × [n]` requires `n` monochromatic rectangles to cover it without touching off-diagonal points.

**Step 3.** Lift the Boolean covering lower bound back to tropical factor rank.  
This produces a robust theorem schema: support complexity lower bounds imply tropical factor-rank lower bounds.

Why this matters: this is the route that exposes the communication-complexity connection explicitly and may become a reusable library theorem.

---

### Strategy 3: Residuation / Galois-connection approach for product subadditivity
Best for Theorem C.

**Step 1.** Start from a factorization `A = U ⊗ V` of rank `r`.

**Step 2.** Use associativity:
\[
A ⊗ B = U ⊗ (V ⊗ B).
\]
This is immediately a factorization of `A ⊗ B` through the same middle dimension `r`.

**Step 3.** Symmetrically, if `B = U' ⊗ V'`, then
\[
A ⊗ B = (A ⊗ U') ⊗ V'.
\]
Thus factor rank cannot increase under multiplication on either side.

Why this is promising: it is nearly tautological once the right definitions are in place, and it gives the conjectural “composition law” that makes the separation theorem scientifically useful rather than merely negative.

---

## How to build on the catalog theorems

Even though the listed theorems are not directly about rank, use them as bridge motifs and proof-engineering support.

1. **`tropical_rank_bound`**  
   This is the obvious local anchor. Inspect whether it already gives a general upper/lower inequality for your chosen tropical rank notion. If so, use it to position the identity matrix family relative to tropical rank and to phrase the “no reverse inequality” theorem sharply.

2. **`tropical_product_sum_inequality`**  
   This may help discharge technical monotonicity or associativity-style inequalities in min-plus arithmetic when proving product subadditivity or manipulating tropical matrix products entrywise.

3. **`tropical_young_inequality`**  
   Potentially useful if your implementation of tropical multiplication/addition over `ℝ` requires inequality management on weights; less central, but may help normalize weighted rank-1 terms.

4. **`tropical_and_bound`**  
   Conceptually useful for support-intersection reasoning: rank-1 supports behave like combinatorial conjunctions of row/column predicates. If this theorem exposes a min-plus “AND” bound, it may be repurposed in rectangle-cover arguments.

5. **`root_gap_bounds`**  
   Not directly relevant to the core proof, but potentially useful if you decide to formulate a companion theorem interpreting support-separation as a stability gap under perturbation. That would be an ambitious follow-up, not the first target.

---

## Structural Lemmas worth proving first

These are the real engine room. If you formalize them cleanly, many future theorems become easy.

### Lemma 1: Rank-1 support is rectangular
```lean
theorem support_rankOne_rectangular
    {m n : ℕ} {u : Fin m → WithTop ℝ} {v : Fin n → WithTop ℝ} :
    let M : Matrix (Fin m) (Fin n) (WithTop ℝ) := fun i j => u i + v j
    ∀ {i i' j j'},
      M i j < ⊤ →
      M i' j' < ⊤ →
      M i j' < ⊤ ∧ M i' j < ⊤
```

### Lemma 2: Diagonal support needs `n` rectangles
```lean
theorem diagonal_support_rectangle_cover_lower_bound
    (n r : ℕ)
    (hcover : diagonalRelationOn (Fin n) ≤ rectangleCover r) :
    n ≤ r
```

You may need a more concrete formulation using a family of row-sets and column-sets.

### Lemma 3: Factorization induces support cover
```lean
theorem factorization_gives_rectangle_cover
    {n r : ℕ}
    {U : Matrix (Fin n) (Fin r) (WithTop ℝ)}
    {V : Matrix (Fin r) (Fin n) (WithTop ℝ)} :
    support (U ⊗ₜ V) ≤ diagonalSupport →
    diagonalCoverableByRectangles n r
```

This is the bridge theorem that turns tropical algebra into combinatorics.

---

## Cross-Domain Connections

### 1. Communication complexity
The diagonal matrix corresponds to the equality predicate. Its rectangle-cover complexity is `n`, while other rank notions may remain much smaller depending on definition. This mirrors the gap between nondeterministic certificates and deterministic protocols. A formal support-cover theorem here is the seed of a Lean-native communication complexity library.

### 2. Optimization and extension complexity
Factor rank measures the size of a tropical extended formulation. Proving exact factor rank for canonical matrices is the tropical analogue of proving extension complexity lower bounds for polytopes. This is a direct route toward tropical formulations of LP lower bounds.

### 3. Idempotent functional analysis
Rank-1 tropical operators are separable kernels. Your theorem says the identity kernel is maximally non-separable despite its apparent simplicity. That is a striking operator-theoretic phenomenon.

### 4. Neural and morphological computation
Min-plus linear maps appear in shortest-path layers, morphological networks, and certain robust-control architectures. Factor rank is then a compressed-representation complexity measure. A separation theorem suggests intrinsic barriers to low-width tropical compression.

### 5. Semiring complexity theory
This result belongs to a larger science-fiction program: complexity classes over semirings. Tropical factor rank can become a certified lower-bound invariant for min-plus circuits and dynamic programming formulations.

---

## Application Keywords

`tropical linear algebra`, `factor rank`, `Barvinok rank`, `min-plus algebra`, `semiring complexity`, `communication complexity`, `rectangle covering`, `extension complexity`, `tropical matrix factorization`, `idempotent analysis`, `formalized lower bounds`, `Lean 4`, `Mathlib`

---

## Concrete Deliverables

1. Formal definition of the tropical identity matrix.
2. Formal definition or adaptation of tropical factor rank.
3. Proof that `tropIdMatrix n` has factor rank exactly `n`.
4. If definitions permit, a theorem showing no universal reverse inequality from tropical rank to factor rank.
5. Product subadditivity theorem(s) for factor rank under tropical matrix multiplication.
6. Minimal `sorry` usage, with reusable support/rectangle lemmas factored cleanly.

---

## If the exact tropical-rank notion becomes subtle

Do **not** get trapped proving the wrong theorem because of definitional ambiguity. If your current library’s `tropicalRank` does not make the identity matrix a good witness, pivot immediately to the stronger and cleaner statement:

- exact factor rank of the tropical identity;
- support-cover lower bounds for tropical factorizations;
- no reverse inequality using a different explicit family already compatible with `tropical_rank_bound`.

The breakthrough is the **separation mechanism**, not the specific witness.

---

## FUTURE_DIRECTIONS.md requirement

You must also produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps at breakthrough level. Include at least:

1. A theorem relating tropical factor rank to Boolean rectangle covering number via support.
2. A tropical extension-complexity framework for polytopes or polyhedra.
3. Lower bounds for factor rank of distance matrices / shortest-path kernels.
4. A formal bridge between tropical factorization and communication protocols.
5. A search program for matrices with polynomial tropical rank but exponential factor rank.

Make these specific enough that the next cycle can immediately attack them.

Be bold: the goal is not just to certify one counterexample, but to found a **formal complexity theory of tropical representations**.

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
