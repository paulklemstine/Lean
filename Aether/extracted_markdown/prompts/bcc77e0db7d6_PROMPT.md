Mode: prove

Title: Tropical Matrix Certificates Beyond Rank One — Local Witnesses, Idempotent Closure, and a Tropical Helly-to-Rank Bridge

Aristotle,

Do not treat “Conjecture 3” as a missing lemma. Treat it as the seed of a new certification theory for tropical linear algebra: a theory in which low-complexity local witnesses control global matrix structure, in the same way minors control classical rank, Helly certificates control convex infeasibility, and local constraints in statistical physics determine phase structure.

Your mission is to build a formal, reusable Lean 4 framework for tropical matrix certificates and then prove at least 3 genuinely nontrivial theorems showing that these certificates detect rank-one structure, propagate through idempotent tropical closure, and interact with existing small-certificate principles from tropical feasibility.

This is not an incremental exercise. If successful, it opens a field: certified tropical linear algebra, where matrix properties admit finitely checkable witnesses with algorithmic extraction.

## Precise Research Objective

Implement a new notion of tropical matrix certificate capturing when a matrix is “locally rank-one consistent” on all 2×2 submatrices, and prove that for finite matrices this local certificate implies a global additive-separable decomposition. Then connect this to tropical idempotence and small-certificate phenomena already verified in the catalog.

The breakthrough is that rank-one tropical structure should become certifiable by sparse local data, exactly as convex infeasibility is certifiable by small subsets. This is a tropical analogue of local-to-global rigidity.

## New Definitions You Must Introduce

You must define at least one genuinely new concept. I recommend introducing all three below.

### 1. Tropical rectangle equality certificate
For a matrix `A : ι → κ → ℝ`, define that a quadruple `(i₁,i₂,j₁,j₂)` satisfies the rectangle equality if
`A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁`.

This is the tropical analogue of vanishing classical 2×2 minors after logarithmic change.

Suggested Lean 4 definition:
```lean
def TropicalRectangleEq {ι κ : Type*} (A : ι → κ → ℝ)
    (i₁ i₂ : ι) (j₁ j₂ : κ) : Prop :=
  A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁
```

### 2. Tropical matrix certificate
A matrix has a tropical certificate if all rectangles satisfy the equality.
```lean
def HasTropicalMatrixCertificate {ι κ : Type*} (A : ι → κ → ℝ) : Prop :=
  ∀ i₁ i₂ j₁ j₂, TropicalRectangleEq A i₁ i₂ j₁ j₂
```

If Conjecture 3 in your source material is more nuanced, refine this to a “small support certificate” structure carrying only enough rectangle witnesses to reconstruct the full property.

### 3. Certificate-extracted potentials
Define a structure encoding row and column potentials:
```lean
structure TropicalSeparableDecomposition {ι κ : Type*} where
  u : ι → ℝ
  v : κ → ℝ
  witness : ∀ i j, ?A i j = u i + v j
```
You may instead define this relative to a fixed matrix `A`.

This is not merely packaging: it turns certification into an extractable algorithmic object.

## Core Theorems to Prove

You need at least 3 deep theorems. The following package is the right target.

---

### Theorem 1: Global rank-one from rectangle certificate
This is the central theorem.

**Mathematical statement.**  
For finite nonempty index types, if every 2×2 rectangle of `A : ι → κ → ℝ` satisfies the tropical rectangle equality, then `A` is additively separable, hence tropical rank one by the catalog theorem
`tropical_rank_one_iff_matrix_additive_separable`.

In explicit form:
\[
(\forall i_1,i_2,j_1,j_2,\;
A_{i_1j_1}+A_{i_2j_2}=A_{i_1j_2}+A_{i_2j_1})
\;\Longrightarrow\;
\exists u:ι\to\mathbb R,\exists v:κ\to\mathbb R,\forall i,j,\;A_{ij}=u_i+v_j.
\]

**Lean 4 type signature target.**
```lean
theorem tropical_certificate_implies_additive_separable
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    [DecidableEq ι] [DecidableEq κ]
    [Nonempty ι] [Nonempty κ]
    (A : ι → κ → ℝ)
    (hcert : HasTropicalMatrixCertificate A) :
    ∃ u : ι → ℝ, ∃ v : κ → ℝ, ∀ i j, A i j = u i + v j
```

Then derive:

```lean
theorem tropical_certificate_implies_rank_one
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    [DecidableEq ι] [DecidableEq κ]
    [Nonempty ι] [Nonempty κ]
    (A : ι → κ → ℝ)
    (hcert : HasTropicalMatrixCertificate A) :
    TropicalRankOne A
```

where `TropicalRankOne A` should be instantiated using the exact notion in
`FINAL/Tropical/RankOneFactorization.lean` or `Tropical/RankOneFactorization.lean`.

**Why this is a breakthrough.**  
This theorem says tropical rank one is not merely existentially factorized; it is locally certifiable. That is the birth of certificate complexity for tropical matrix theory.

---

### Theorem 2: Canonical extraction of certificate potentials
Do not stop at existence. Extract a canonical decomposition from a chosen base row and base column.

Fix `i₀ : ι`, `j₀ : κ`. Define
\[
u(i)=A_{i j_0},\qquad v(j)=A_{i_0 j}-A_{i_0 j_0}.
\]
Then prove
\[
A_{ij}=u(i)+v(j)
\]
under the certificate hypothesis.

**Lean 4 type signature target.**
```lean
theorem tropical_certificate_extracts_potentials
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    [DecidableEq ι] [DecidableEq κ]
    [Nonempty ι] [Nonempty κ]
    (A : ι → κ → ℝ)
    (hcert : HasTropicalMatrixCertificate A) :
    let i0 : ι := Classical.choice ‹Nonempty ι›
    let j0 : κ := Classical.choice ‹Nonempty κ›
    let u : ι → ℝ := fun i => A i j0
    let v : κ → ℝ := fun j => A i0 j - A i0 j0
    ∀ i j, A i j = u i + v j
```

**Why this matters.**  
This is the algorithmic heart. It gives an actual verified reconstruction method, not just a theorem. It is the tropical analogue of recovering vertex potentials from curl-free edge data.

---

### Theorem 3: Idempotent matrices with certificate are stable under tropical multiplication / closure
Use `tropical_matrix_idempotent` as a bridge theorem. The exact formal statement depends on how tropical multiplication is encoded in the file, but the conceptual theorem should be:

If a tropical square matrix is idempotent and has the rectangle certificate, then its canonical extracted decomposition is fixed by tropical matrix multiplication, and its image defines a one-dimensional tropical semimodule.

A more Lean-manageable version:

```lean
theorem tropical_idempotent_certificate_rank_one
    {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    (A : ι → ι → ℝ)
    (hidem : TropicalIdempotent A)
    (hcert : HasTropicalMatrixCertificate A) :
    ∃ u v, (∀ i j, A i j = u i + v j) ∧ TropicalIdempotent A
```

or, if the imported theorem gives a stronger idempotence formula, prove that the decomposition is compatible with it.

**Why this is a breakthrough.**  
Idempotents are projectors. Rank-one certified idempotents are tropical projective atoms. This connects tropical linear algebra to representation theory and categorical projection phenomena.

---

### Theorem 4: Small certificates suffice for failure of rank one or feasibility reduction
This is your cross-catalog synthesis theorem. Build on
`tropical_feasibility_has_small_certificate`.

A compelling target is:

If a finite matrix fails the rectangle certificate, then there exists a 2×2 submatrix witnessing failure. Conversely, if a global tropical feasibility problem is encoded by all rectangle equalities for additive-separability potentials, infeasibility has a small certificate by the Helly theorem.

At minimum prove the direct local witness theorem:

```lean
theorem not_certificate_iff_exists_bad_rectangle
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    [DecidableEq ι] [DecidableEq κ]
    (A : ι → κ → ℝ) :
    ¬ HasTropicalMatrixCertificate A ↔
      ∃ i₁ i₂ j₁ j₂,
        A i₁ j₁ + A i₂ j₂ ≠ A i₁ j₂ + A i₂ j₁
```

This may look simple logically, but do not make this one of your “deep three.” It should support the next theorem:

Encode additive-separability as a system of tropical linear equalities in unknowns `u,v`. Then use `tropical_feasibility_has_small_certificate` to prove existence of a bounded-size obstruction certificate whenever no decomposition exists.

Even if the exact imported theorem is abstract, you should explicitly bridge the matrix decomposition problem into its feasibility framework.

**Why this is a breakthrough.**  
This is the first step toward NP-style certificate theory for tropical rank. It says obstructions to low rank are small and machine-checkable.

## Proof Strategy Architecture

You must include multi-step proofs, not brute force simplification. Here are the best approaches.

### Strategy A: Basepoint potential extraction via rectangle identity
Most promising.

1. Choose base indices `i₀, j₀` using `Nonempty`.
2. Define `u i = A i j₀` and `v j = A i₀ j - A i₀ j₀`.
3. Apply the rectangle equality to `(i, i₀, j, j₀)`:
   \[
   A_{ij}+A_{i_0j_0}=A_{ij_0}+A_{i_0j}.
   \]
4. Rearrange by `linarith` or explicit `calc`:
   \[
   A_{ij}=A_{ij_0}+(A_{i_0j}-A_{i_0j_0})=u(i)+v(j).
   \]
5. Invoke `tropical_rank_one_iff_matrix_additive_separable`.

Why most promising: it is constructive, canonical, and Lean-friendly. It uses rcases for basepoints, calc blocks for algebra, and creates the verified algorithm immediately.

### Strategy B: Difference-cocycle / discrete integrability
More conceptual and excellent for the paper.

1. For each pair of columns define row-difference functions
   \[
   \Delta_{j_1,j_2}(i)=A_{ij_1}-A_{ij_2}.
   \]
2. Show rectangle equality implies `Δ_{j₁,j₂}` is independent of `i`.
3. Fix a base row and recover column potentials from these constant differences.
4. Deduce additive separability.

Why useful: this reveals the theorem as a vanishing-curl / exact-1-form statement on the complete bipartite graph. It creates a strong cross-domain bridge to combinatorial Hodge theory and gauge theory.

### Strategy C: Feasibility encoding + small certificate transfer
Ambitious, potentially field-opening.

1. Introduce unknowns `u : ι → ℝ`, `v : κ → ℝ` and constraints `A i j = u i + v j`.
2. Show rectangle equalities are necessary consequences of this system.
3. Conversely, use Strategy A to show sufficiency.
4. Push the resulting feasibility instance through `tropical_feasibility_has_small_certificate`.
5. Derive a bounded witness for non-separability.

Why powerful: this turns a structural theorem into an algorithmic certification theorem and links tropical rank to Helly-type complexity.

## Cross-Domain Connections You Must Make Explicit

At least one theorem and all written documents must emphasize these bridges:

1. **Combinatorial Hodge theory / discrete gauge theory**  
   Rectangle equalities are zero-curl conditions on a bipartite grid. Potentials `u,v` are gauge potentials. Your extraction theorem is a discrete Poincaré lemma for tropical matrices.

2. **Constraint satisfaction / proof complexity**  
   A tropical matrix certificate is a local witness system. Small obstructions resemble minimally unsatisfiable cores and Helly certificates.

3. **Representation theory / idempotent semirings**  
   Rank-one idempotent tropical matrices act as atomic projectors in idempotent linear algebra. Connect to `tropical_matrix_idempotent`.

4. **Statistical physics / energy landscapes**  
   Additively separable matrices are exactly pairwise energies with no interaction term. Rectangle equality means zero mixed interaction. This is the rank-one/no-coupling phase.

5. **Information theory**  
   Additive separability is the tropical shadow of independence. A “bad rectangle” is a witness of tropical interaction, analogous to failure of multiplicative factorization in probabilistic models.

## Application Keywords

Use these explicitly in comments, theorem docs, and papers:

- tropical rank certification
- local-to-global rigidity
- certificate complexity
- Helly-type obstruction
- discrete integrability
- zero-curl condition
- tropical projector
- idempotent linear algebra
- separable energy landscape
- tropical independence witness
- algorithmic factorization
- verified certificate extraction

## Lean Implementation Guidance

You must minimize sorry and avoid trivialized statements.

### Tactics expected in the deep theorems
Across the file, ensure at least 3 theorems use some of:
- `rcases` for extracting `Nonempty` witnesses
- `by_contra` for obstruction-style results
- `field_simp` if you normalize rational variants or affine normalizations
- induction if you define certificate propagation on finite lists of rectangles
- multi-step `calc`
- careful rewriting with `sub_eq_iff_eq_add`, `eq_sub_iff_add_eq`, `ring_nf`, or `linarith`

### Suggested file organization
Create a new file such as:
`Speculative/AutoResearch/Tropical/TropicalMatrixCertificate.lean`

Suggested section structure:
1. Basic definitions
2. Rectangle certificate implies separability
3. Extraction algorithm
4. Rank-one corollaries via existing theorem
5. Idempotent compatibility
6. Small obstruction certificates / Helly bridge
7. Computational API

## Concrete Theorem Package to Aim For

Here is a coherent minimal target list.

```lean
def TropicalRectangleEq {ι κ : Type*} (A : ι → κ → ℝ)
    (i₁ i₂ : ι) (j₁ j₂ : κ) : Prop :=
  A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁

def HasTropicalMatrixCertificate {ι κ : Type*} (A : ι → κ → ℝ) : Prop :=
  ∀ i₁ i₂ j₁ j₂, TropicalRectangleEq A i₁ i₂ j₁ j₂
```

```lean
theorem tropical_certificate_extracts_potentials
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    [DecidableEq ι] [DecidableEq κ]
    [Nonempty ι] [Nonempty κ]
    (A : ι → κ → ℝ)
    (hcert : HasTropicalMatrixCertificate A) :
    ∃ u : ι → ℝ, ∃ v : κ → ℝ, ∀ i j, A i j = u i + v j
```

```lean
theorem tropical_certificate_implies_additive_separable
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    [DecidableEq ι] [DecidableEq κ]
    [Nonempty ι] [Nonempty κ]
    (A : ι → κ → ℝ)
    (hcert : HasTropicalMatrixCertificate A) :
    ∃ u : ι → ℝ, ∃ v : κ → ℝ, ∀ i j, A i j = u i + v j
```

```lean
theorem tropical_certificate_implies_rank_one
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    [DecidableEq ι] [DecidableEq κ]
    [Nonempty ι] [Nonempty κ]
    (A : ι → κ → ℝ)
    (hcert : HasTropicalMatrixCertificate A) :
    -- replace with exact catalog notion
    TropicalRankOne A
```

```lean
theorem not_certificate_iff_exists_bad_rectangle
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    [DecidableEq ι] [DecidableEq κ]
    (A : ι → κ → ℝ) :
    ¬ HasTropicalMatrixCertificate A ↔
      ∃ i₁ i₂ j₁ j₂,
        A i₁ j₁ + A i₂ j₂ ≠ A i₁ j₂ + A i₂ j₁
```

```lean
theorem tropical_idempotent_certificate_rank_one
    {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    (A : ι → ι → ℝ)
    (hidem : TropicalIdempotent A)
    (hcert : HasTropicalMatrixCertificate A) :
    ∃ u : ι → ℝ, ∃ v : ι → ℝ, ∀ i j, A i j = u i + v j
```

If the exact theorem names in the catalog differ, adapt the signatures to imported definitions. But preserve this mathematical content.

## Testable Conjecture You Must State

You must include at least one falsifiable conjecture with a computational disproof path.

### Conjecture: bounded certificate size for tropical rank > 1
For every finite matrix `A`, if `A` is not tropical rank one, then there exists a witness involving at most one base row, one base column, and one bad rectangle certifying non-separability.

Equivalent computational prediction:
An algorithm that samples all 2×2 rectangles will always find a counterexample whenever canonical potential extraction fails.

Formal conjecture sketch:
```lean
conjecture tropical_non_rank_one_has_four_point_witness
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    [DecidableEq ι] [DecidableEq κ]
    [Nonempty ι] [Nonempty κ]
    (A : ι → κ → ℝ) :
    ¬ TropicalRankOne A →
    ∃ i₁ i₂ j₁ j₂,
      A i₁ j₁ + A i₂ j₂ ≠ A i₁ j₂ + A i₂ j₁
```

This is falsifiable: brute-force search over all 2×2 rectangles either finds a witness or produces evidence toward a proof. If false, a counterexample matrix can be explicitly exhibited.

A stronger scientific hypothesis for FUTURE_DIRECTIONS:
Matrices of tropical rank `r` admit obstruction certificates supported on at most `(r+1) × (r+1)` submatrices. This would be the tropical analogue of minor-based rank certification.

## Deliverables — Mandatory

You must produce ALL of the following:

1. **Lean file** with the new definitions and at least 3 deep theorems proven using nontrivial tactics, minimizing sorry.
2. **FUTURE_DIRECTIONS.md** containing 3–5 falsifiable scientific hypotheses, each with:
   - precise conjecture
   - why it matters
   - a concrete computational or formal test that could refute it
3. **RESEARCH_PAPER.md** as a standalone scientific document explaining:
   - the theorem statements
   - proof ideas
   - relation to catalog theorems
   - why tropical certification is a new research direction
   - future experiments and conjectures
4. **ARTICLE.md** in Scientific American style for a broad audience, explaining how local checks can certify global hidden structure in exotic algebra.
5. **A verified algorithm or computational method**:
   - canonical potential extraction from a certified matrix
   - checker for bad rectangles / certificate failure
   - optional reconstruction of rank-one decomposition
6. **demo.py**:
   - generate random small matrices
   - test rectangle certificate
   - if certificate holds, extract `u,v`
   - if it fails, display a bad rectangle witness
   - visualize the matrix as a separable energy landscape or interaction heatmap

## Final Vision

If you execute this well, the result will not read like “another theorem about tropical rank one.” It will read like the beginning of a new doctrine:

- tropical rank can be certified locally,
- decomposition can be extracted algorithmically,
- idempotent projectors admit atomic certification,
- and Helly-type ideas govern obstruction size.

That is the kind of bridge that changes a catalog into a research program.

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
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Speculative
Research mode: prove
