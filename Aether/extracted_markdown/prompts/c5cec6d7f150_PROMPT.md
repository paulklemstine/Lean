## Assignment: Linear Algebra / Tropical Geometry / Factorization

Mode: **prove**

Aristotle, do not drift into small variants. Use the catalog to force a new bridge theorem at the interface of **tropical rank**, **rank-1 factorization**, and **classical low-rank geometry**. The right target is not another inequality; it is a structural equivalence that turns tropical rank-1 certificates into an explicit factorization theory. This would create a formal backbone for tropical matrix decomposition, tropical latent-variable models, and low-complexity certificates for neural and representation-theoretic constructions.

## Breakthrough Target

Prove a **tropical rank-one factorization theorem** for 2×2 minors, then push it toward a finite-dimensional decomposition principle.

The core theorem should state that for a tropical matrix over a linearly ordered additive type, vanishing of all 2×2 tropical minors is equivalent to additive separability of entries. In ordinary language: every tropical rank-1 matrix is exactly a sum of a row potential and a column potential.

This is the missing structural statement behind the existing theorem `tropical_rank1_minor`. Right now the catalog contains local rank-1 minor identities and ambient rank bounds; you should globalize them into a classification theorem.

## Primary Theorem

Work first over `ℝ`, where order/comparison arguments are easiest.

### Mathematical statement

Let `A : Fin n → Fin m → ℝ` with `n,m ≥ 1`. Assume that for all row indices `i₁,i₂` and column indices `j₁,j₂`,
\[
A\, i₁\, j₁ + A\, i₂\, j₂ = A\, i₁\, j₂ + A\, i₂\, j₁.
\]
Then there exist functions `u : Fin n → ℝ` and `v : Fin m → ℝ` such that
\[
A\, i\, j = u\, i + v\, j
\]
for all `i,j`.

Conversely, every matrix of the form `u i + v j` satisfies all these 2×2 minor equalities.

This is the exact tropical analogue of the classical statement “all 2×2 minors vanish iff rank ≤ 1”, but in the min-plus / max-plus additive-separable form. Formalizing it in Lean creates a reusable theorem schema for tropical factorization.

### Suggested Lean 4 theorem signature

```lean
theorem tropical_rank_one_iff_additive_separable
    {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (A : Fin n → Fin m → ℝ) :
    (∀ i₁ i₂ : Fin n, ∀ j₁ j₂ : Fin m,
      A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁) ↔
    ∃ u : Fin n → ℝ, ∃ v : Fin m → ℝ,
      ∀ i j, A i j = u i + v j
```

You should also prove the forward direction separately as a reusable theorem:

```lean
theorem additive_separable_of_all_tropical_2x2_minors_vanish
    {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (A : Fin n → Fin m → ℝ)
    (hminor : ∀ i₁ i₂ : Fin n, ∀ j₁ j₂ : Fin m,
      A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁) :
    ∃ u : Fin n → ℝ, ∃ v : Fin m → ℝ,
      ∀ i j, A i j = u i + v j
```

and the converse:

```lean
theorem all_tropical_2x2_minors_vanish_of_additive_separable
    {n m : ℕ}
    (A : Fin n → Fin m → ℝ)
    (hA : ∃ u : Fin n → ℝ, ∃ v : Fin m → ℝ,
      ∀ i j, A i j = u i + v j) :
    ∀ i₁ i₂ : Fin n, ∀ j₁ j₂ : Fin m,
      A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁
```

## Stronger Follow-Up Theorem

Once the equivalence is established, prove a normalization theorem. Fix a base row and base column and show the factorization can be chosen canonically.

### Mathematical statement

For `i₀ : Fin n`, `j₀ : Fin m`, define
\[
u(i) := A(i,j₀), \qquad v(j) := A(i₀,j) - A(i₀,j₀).
\]
Under the minor-vanishing hypothesis, this yields
\[
A(i,j) = u(i) + v(j).
\]

This is much stronger for formal work because it removes existential ambiguity and gives an executable construction.

### Lean signature

```lean
theorem tropical_rank_one_factorization_normalized
    {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (A : Fin n → Fin m → ℝ)
    (i₀ : Fin n) (j₀ : Fin m)
    (hminor : ∀ i₁ i₂ : Fin n, ∀ j₁ j₂ : Fin m,
      A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁) :
    let u : Fin n → ℝ := fun i => A i j₀
    let v : Fin m → ℝ := fun j => A i₀ j - A i₀ j₀
    ∀ i j, A i j = u i + v j
```

This theorem is likely the most useful one computationally and conceptually.

## Why this is a breakthrough

This would formalize, in a clean Lean-native way, the first real **structure theorem** for tropical low rank in your local catalog. The existing theorems are fragments:

- `tropical_rank1_minor` gives a 2×2 local identity.
- `tropical_rank_bound` and `tropical_rank_le_dim` give ambient constraints.
- `relu_tropical_rank_le2` hints at low-rank phenomena in piecewise-linear networks.
- `gl3_tropical_satake_injective_of_edge_rank2_marginals` suggests rank constraints can control representation-theoretic transforms.

Your theorem would turn those fragments into a factorization engine. Once you can pass from tropical minor equalities to explicit `u + v` decompositions, you unlock:

- tropical matrix compression,
- tropical latent factor models,
- exact certificates for low-complexity neural layers,
- rigidity criteria in tropical representation theory,
- algorithmic recognition of rank-1 tropical objects.

This is not a variant. It is a missing algebraic spine.

## How to build on the catalog

1. **Use `tropical_rank1_minor` as the atomic local relation.**  
   Even if its current statement is specialized to four real numbers, it captures the exact equality pattern needed in the 2×2 case. Generalize its logic into indexed matrix form.

2. **Use `tropical_rank_bound` and `tropical_rank_le_dim` as conceptual support.**  
   These do not directly prove factorization, but they justify the framing: tropical rank behaves dimensionally like classical rank, so rank-1 should admit a rigid normal form.

3. **Connect to `relu_tropical_rank_le2`.**  
   After proving the rank-1 factorization theorem, formulate a corollary for any layer or matrix already known to have tropical rank ≤ 2: rank-1 subblocks admit explicit additive-separable decompositions. This is a first bridge to neural network interpretability.

4. **Connect to `gl3_tropical_satake_injective_of_edge_rank2_marginals`.**  
   The long-term message is that local rank constraints can force global rigidity/injectivity. Your theorem supplies the rank-1 version of this principle in a transparent algebraic setting.

## Proof architecture: three viable strategies

### Strategy A: Basepoint reconstruction from one row and one column
This is the most promising strategy.

1. Choose base indices `i₀ : Fin n` and `j₀ : Fin m`.
2. Define
   \[
   u(i)=A(i,j₀),\qquad v(j)=A(i₀,j)-A(i₀,j₀).
   \]
3. Apply the minor identity to the quadruple `(i, i₀, j, j₀)`:
   \[
   A(i,j)+A(i₀,j₀)=A(i,j₀)+A(i₀,j).
   \]
   Rearranging gives
   \[
   A(i,j)=u(i)+v(j).
   \]

Why this is best:
- It is explicit.
- It avoids induction and heavy finite combinatorics.
- It yields the normalized theorem automatically.
- Lean likes this because the proof is pointwise and algebraic.

### Strategy B: Difference-independence / cocycle trivialization
This is conceptually deeper and may be useful for generalization.

1. Show that for fixed `j₁,j₂`, the quantity `A i j₁ - A i j₂` is independent of `i`.
2. Deduce the existence of a well-defined column potential `v`.
3. Then recover `u` from any chosen column.

This reframes the theorem as exactness of a discrete 1-cocycle on the complete bipartite graph `Fin n × Fin m`. It is elegant and likely generalizes to abstract ordered additive groups.

Why it matters:
- It exposes hidden cohomology.
- It links tropical rank-1 factorization to graph potentials and gauge normalization.
- It may support future work on hypergraph and sheaf-theoretic tropical factorization.

### Strategy C: Finite induction on rows/columns
Useful if you later want an algorithmic decomposition theorem.

1. Prove the result for `1 × m` and `n × 1` matrices trivially.
2. Add one row or column at a time, using the 2×2 minor relations to force compatibility with existing potentials.
3. Assemble the global factorization.

Why to keep it in reserve:
- It mirrors constructive algorithms.
- It may be easier if you later move to `Matrix (Fin n) (Fin m) α` and want recursive extraction code.

But for the first theorem, Strategy A is superior.

## Recommended Lean implementation steps

### Step 1: Prove the converse first
It is a one-line algebraic check once you unfold `A i j = u i + v j`.

```lean
theorem all_tropical_2x2_minors_vanish_of_additive_separable ...
```

This gives confidence and creates a simp-friendly lemma.

### Step 2: Prove the normalized construction
Introduce `u` and `v` by explicit formulas and use `hminor i i₀ j j₀`. Rearrange with `linarith` or explicit ring algebra over `ℝ`.

### Step 3: Package the iff theorem
Combine the two directions.

### Step 4: Add a matrix-valued version
If convenient, restate using `Matrix (Fin n) (Fin m) ℝ`:

```lean
theorem tropical_rank_one_iff_matrix_additive_separable
    {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (A : Matrix (Fin n) (Fin m) ℝ) :
    (∀ i₁ i₂ j₁ j₂,
      A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁) ↔
    ∃ u : Fin n → ℝ, ∃ v : Fin m → ℝ,
      ∀ i j, A i j = u i + v j
```

This version will compose better with Mathlib matrix APIs.

## Ambitious extension theorem

If the first theorem lands cleanly, aim for a decomposition existence statement for tropical factor rank.

### Candidate extension
Define a tropical rank-`k` factorization predicate:
\[
A(i,j)=\min_{t \in \mathrm{Fin}\,k}(U(i,t)+V(t,j))
\]
or max-plus variant, depending on your ambient conventions.

Then prove at least one nontrivial existence theorem for `k = 1`, showing your additive-separable theorem is exactly the factor-rank-1 case.

### Lean target
You may need to define:

```lean
def TropicalFactorRankLE (k : ℕ) (A : Fin n → Fin m → ℝ) : Prop :=
  ∃ U : Fin n → Fin k → ℝ, ∃ V : Fin k → Fin m → ℝ,
    ∀ i j, A i j = Finset.univ.inf' ?h (fun t => U i t + V t j)
```

If the inf/min machinery becomes too heavy, stay with the rank-1 theorem this cycle and document the rank-`k` definition in `FUTURE_DIRECTIONS.md`.

## Cross-domain connections you must exploit

### 1. Neural networks
`relu_tropical_rank_le2` suggests low tropical rank captures architectural simplicity. Your theorem would imply that rank-1 components are exactly those whose logits/features decompose into row and column potentials. This is a form of **interpretable separability**.

Potential corollary direction:
- rank-1 tropical layers correspond to additive feature-channel decoupling.

### 2. Representation theory / Satake
`gl3_tropical_satake_injective_of_edge_rank2_marginals` indicates tropical rank constraints can control injectivity. Your theorem gives a toy but exact model:
- local minor constraints force a global coordinate factorization.
This is the finite-dimensional shadow of rigidity phenomena in tropicalized harmonic analysis.

### 3. Graph theory / discrete potential theory
Your factorization theorem is equivalent to saying a matrix with zero rectangular curl is a sum of vertex potentials on a complete bipartite graph. This is a discrete exactness theorem. That opens a bridge to:
- cohomology on bipartite complexes,
- network flow potentials,
- gauge fixing in combinatorial optimization.

### 4. Statistics / latent variable models
An additive-separable tropical matrix is a one-factor model in the min-plus/max-plus semiring. This is a tropical analogue of:
- rank-1 nonnegative matrix factorization,
- log-linear models,
- low-complexity cost tables in optimal transport.

### 5. Complexity / optimization
Recognizing rank-1 structure by checking all 2×2 minors gives a polynomial certificate. Formalizing this could lead to verified recognition algorithms for structured cost matrices.

## Concrete corollaries worth proving if time permits

### Corollary 1: Uniqueness up to gauge
If
\[
A(i,j)=u(i)+v(j)=u'(i)+v'(j),
\]
then there exists `c : ℝ` such that
\[
u'(i)=u(i)+c,\qquad v'(j)=v(j)-c.
\]

Lean target:

```lean
theorem additive_separable_gauge_uniqueness
    {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    {A : Fin n → Fin m → ℝ}
    {u u' : Fin n → ℝ} {v v' : Fin m → ℝ}
    (h : ∀ i j, A i j = u i + v j)
    (h' : ∀ i j, A i j = u' i + v' j) :
    ∃ c : ℝ, (∀ i, u' i = u i + c) ∧ (∀ j, v' j = v j - c)
```

This is mathematically natural and very useful downstream.

### Corollary 2: Every 2×2 submatrix is additive-separable
A localized version for submatrices may help automate proofs.

### Corollary 3: Constant row-differences criterion
Show equivalence between additive separability and independence of row differences:
\[
A(i,j)-A(i,j₀)
\]
is independent of `i`.

This may be easier to use than the raw 2×2 condition.

## Lean proof tips

- For `hn : 0 < n`, obtain a basepoint with:
  ```lean
  let i₀ : Fin n := ⟨0, hn⟩
  ```
  similarly for `j₀`.
- Keep the first theorem over `ℝ`; subtraction and `linarith` are available.
- If `linarith` struggles, use `nlinarith` or explicit calc chains.
- Prefer pointwise function matrices `Fin n → Fin m → ℝ` before lifting to `Matrix`.
- Package helper lemmas about rearranging
  ```lean
  a + b = c + d
  ```
  into
  ```lean
  a = c + d - b
  ```
  if that improves readability.

## What would make this field-opening

If you complete the theorem suite above, you will have built the first robust Lean-certified bridge from **tropical rank constraints** to **explicit factorization data**. That changes the game: rank is no longer a black-box numerical invariant but a source of canonical coordinates. This opens a path toward verified tropical analogues of:

- SVD-style decomposition,
- matrix completion,
- low-rank learning,
- factor models in combinatorial optimization,
- rigidity in tropical representation theory.

This is exactly the kind of theorem that mathematicians quietly use all the time but formal libraries often lack in reusable, theorem-engine form. Formalizing it now creates leverage far beyond this cycle.

## Deliverables

1. Lean theorem(s) implementing the primary equivalence and normalized factorization.
2. Minimal `sorry` count; prefer complete proofs over speculative definitions.
3. At least one corollary connecting to another domain.
4. A `FUTURE_DIRECTIONS.md` with **3–5 concrete next steps**, each including:
   - exact theorem statement,
   - likely Lean signature,
   - proof strategy,
   - cross-domain significance.

## Required FUTURE_DIRECTIONS targets

Your `FUTURE_DIRECTIONS.md` must include specific next steps such as:

1. **Tropical factor-rank-1 equivalence**  
   Formalize a rank-1 factorization predicate via min/max-plus and prove equivalence with additive separability.

2. **Tropical rank-2 decomposition criteria**  
   Seek a theorem characterizing matrices expressible as min/max of two additive-separable terms.

3. **Neural separability theorem**  
   Use `relu_tropical_rank_le2` to identify conditions under which a ReLU layer admits a verified tropical rank-1 or rank-2 decomposition.

4. **Bipartite cohomology formulation**  
   Recast the theorem as exactness of a discrete cocycle on `Fin n × Fin m`.

5. **Representation-theoretic rigidity bridge**  
   Connect local tropical minor constraints to injectivity phenomena inspired by `gl3_tropical_satake_injective_of_edge_rank2_marginals`.

## Application keywords

tropical rank, tropical factorization, rank-one decomposition, additive separability, matrix rigidity, low-rank certification, discrete potential theory, graph cohomology, neural network interpretability, tropical representation theory, latent variable models, combinatorial optimization, verified linear algebra, Lean 4, Mathlib

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
