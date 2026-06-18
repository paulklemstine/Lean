## Assignment: Idempotent Transfer Operators and Critical Exponent Computation

Mode: `prove`

You are not being asked for a decorative analogy between renormalization and tropical algebra. You are being asked to force a constructive theorem out of that analogy, in Lean 4, on concrete finite state spaces, with exact computable invariants. The right battlefield is finite tropical transfer operators on `Fin n → ℝ`, where fixed points, cycle means, spectral gaps, and combinatorial cell decompositions can all be made explicit and certified.

The breakthrough target is to formalize a **constructive tropical renormalization principle**: on a finite tropical probability space, an idempotent/max-plus transfer operator has canonical fixed points; its asymptotic growth is controlled by a max-plus eigenvalue; and a strict gap between the top two cycle means yields an exact critical exponent / correlation-length scale. Then push one step further: prove that the parameter space is partitioned into finitely many polyhedral regions (tropical Cohn–Voronoi cells) on which the universality invariant is constant, with effective polynomial-time evaluation once the active cell is known.

This would open a formal bridge between:
- renormalization group flow,
- tropical Perron–Frobenius theory,
- algorithmic universality classification,
- and finite-state statistical mechanics / automata / control.

It is not an incremental extension. It is the seed of a new certified theory of **idempotent critical phenomena**.

---

## Core formalization target

Work with finite index type `Fin n` and matrices `M : Matrix (Fin n) (Fin n) ℝ`. Define the tropical transfer operator
\[
(T_M v)(i) := \max_j (M i j + v j).
\]
This is the concrete object on which everything should be built.

A good Lean definition target is:

```lean
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.LinearAlgebra.Matrix
import Mathlib.Order.Basic

open Matrix BigOperators

def tropTransfer {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.sup fun j : Fin n => M i j + v j
```

If `Finset.sup` over `ℝ` becomes awkward because of order-theoretic instances, replace by a definition via `sSup` of a finite set image, or work first with `ℝ≥0∞`, or define a custom finite max operator using `Finset.fold max`. The theorem matters more than the exact encoding.

You should also define tropical eigenpair and cycle mean:

```lean
def IsTropEigenpair {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) (λ : ℝ) (v : Fin n → ℝ) : Prop :=
  tropTransfer M v = fun i => λ + v i

def edgeWeightSum {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) : List (Fin n) → ℝ := ...
def isCycle {n : ℕ} : List (Fin n) → Prop := ...
def cycleMean {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) (c : List (Fin n)) : ℝ := ...
def maxCycleMean {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) : ℝ := ...
```

If full list-cycle formalization is too heavy for one cycle, begin with a tractable surrogate:
- define the eigenvalue by a variational formula over a finite set of candidate cycles up to length `n`, or
- restrict to `n = 2` or to diagonal-dominant / strongly normalized matrices,
- then generalize.

---

## Precise theorem targets

### Theorem 1: Idempotent transfer fixed point existence on finite tropical spaces

The first theorem should be a real, formalizable finite-dimensional fixed-point theorem, not a slogan.

**Mathematical statement.**  
For every finite tropical transfer matrix `M : Matrix (Fin n) (Fin n) ℝ`, there exists a scalar `λ : ℝ` and a potential `v : Fin n → ℝ` such that
\[
T_M(v) = \lambda + v.
\]
Equivalently, every finite max-plus linear operator admits a tropical eigenpair.

A realistic Lean target:

```lean
theorem exists_trop_eigenpair_fin
    {n : ℕ} (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) :
    ∃ (λ : ℝ) (v : Fin n → ℝ), IsTropEigenpair M λ v
```

If the full theorem is too ambitious at first, prove a normalized fixed-point version:

```lean
def normalizedTropTransfer {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) : Fin n → ℝ :=
  let w := tropTransfer M v
  fun i => w i - w 0

theorem exists_normalized_fixed_point_fin
    {n : ℕ} (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) :
    ∃ v : Fin n → ℝ, normalizedTropTransfer M v = v
```

This normalized version is especially promising in Lean because it turns the eigenproblem into an honest fixed-point equation modulo additive gauge.

**Why this is a breakthrough.**  
This is the certified entrance gate to tropical renormalization: it says coarse-graining by an idempotent transfer rule has a canonical asymptotic profile. Combined with the catalog theorem `fixed_points_are_iterative_invariants`, this upgrades “fixed points exist” to “renormalization invariants are algorithmically stable.”

Build explicitly on:
- `fixed_points_are_iterative_invariants` to show the fixed point defines an invariant under iteration,
- `idempotent_renormalization_duality` to interpret the fixed point as a renormalization fixed phase.

---

### Theorem 2: Tropical spectral gap determines an exact critical exponent / decay scale

You need a theorem that turns the eigenvalue gap into a critical quantity. On finite systems, the cleanest rigorous version is exponential convergence to the top eigenspace under a strict gap hypothesis. The “critical exponent” can be formalized first as an exact decay rate, then interpreted physically.

**Mathematical statement.**  
Assume the top cycle mean `λ₁` is strictly greater than the second cycle mean `λ₂`. Then the normalized iterates of the transfer operator converge exponentially with rate `λ₁ - λ₂`. In particular the correlation-length exponent / relaxation exponent is exactly the inverse gap:
\[
\xi = (\lambda_1 - \lambda_2)^{-1}.
\]

A Lean-ready version should avoid overcommitting to analytic machinery and focus on finite-step inequalities.

For a norm on potentials, e.g. oscillation seminorm
\[
\|v\|_{\mathrm{osc}} = \max_i v_i - \min_i v_i,
\]
target:

```lean
def oscNorm {n : ℕ} (v : Fin n → ℝ) : ℝ :=
  (Finset.univ.sup fun i => v i) - (Finset.univ.inf fun i => v i)

def iterate {α : Type*} (f : α → α) : ℕ → α → α
  | 0 => id
  | k+1 => f ∘ iterate f k

theorem tropical_gap_controls_decay
    {n : ℕ} (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ)
    (λ₁ λ₂ : ℝ) (hgap : λ₂ < λ₁) :
    ∃ (v⋆ : Fin n → ℝ) (C : ℝ),
      0 ≤ C ∧
      ∀ k : ℕ, oscNorm ((iterate (normalizedTropTransfer M) k) v⋆ - v⋆)
        ≤ C * Real.exp (-k * (λ₁ - λ₂))
```

This exact statement may require tuning because subtraction of functions and the use of `Real.exp` on `ℕ` coercions can be fiddly. A more combinatorial and likely easier theorem is:

```lean
theorem tropical_gap_linear_bound
    {n : ℕ} (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ)
    (δ : ℝ) (hδ : 0 < δ) :
    -- if top and second cycle means differ by at least δ,
    -- then after k steps the ambiguity is bounded by initial_oscillation - k*δ
    ...
```

or even

```lean
theorem critical_exponent_eq_inv_gap
    (λ₁ λ₂ : ℝ) (hgap : λ₂ < λ₁) :
    let ξ := 1 / (λ₁ - λ₂)
    ξ > 0
```

but only as a corollary of a nontrivial decay theorem, not as a standalone tautology.

**Best exact finite theorem to aim for.**
On a finite graph where every maximizing path eventually enters the unique critical cycle, prove eventual linear asymptotics:
\[
(T_M^k v)(i) = k\lambda + h(i)
\]
for all sufficiently large `k`, and if the second-best cycle mean is at most `λ - δ`, then the transient defect decays with parameter `δ`. This is the tropical analogue of a gapped transfer matrix theorem.

**Why this is a breakthrough.**  
This is where “critical exponent” stops being metaphorical. You would have a certified theorem saying that universality data is encoded in a tropical spectral gap. Combined with `spectral_gap_distance` and `hamiltonian_gap_time_duality`, this creates a cross-domain dictionary:
- Hamiltonian gap ↔ relaxation time,
- tropical transfer gap ↔ critical decay scale,
- renormalization fixed point ↔ max-plus eigenvector.

That is exactly the kind of theorem that can propagate into formalized statistical mechanics, control, and optimization.

---

### Theorem 3: Tropical Cohn–Voronoi cell counting and polynomial-time universality invariants

Now make the classification algorithmic. The parameter space of transfer matrices is stratified by which affine forms dominate in each row and along each relevant cycle. On each cell, the critical invariant is constant or piecewise affine. This is the right formal replacement for the phrase “universality class invariant.”

Define a finite family of tropical cells in parameter space by inequalities of the form
\[
M_{ij} + v_j \ge M_{ik} + v_k.
\]
Then prove a counting/decision theorem.

A realistic first theorem:

```lean
def sameArgmaxPattern {n : ℕ}
    (M N : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ i j k, M i j ≥ M i k ↔ N i j ≥ N i k

def universalityInvariant {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) : Finset (Fin n × Fin n) := ...

theorem universality_invariant_constant_on_cells
    {n : ℕ} (M N : Matrix (Fin n) (Fin n) ℝ)
    (hcell : sameArgmaxPattern M N) :
    universalityInvariant M = universalityInvariant N
```

Then strengthen toward a counting theorem:

```lean
theorem finitary_tropical_cell_count_bound
    {n : ℕ} :
    ∃ C : ℕ, ∀ d : ℕ,
      -- number of tropical universality cells cut out by d affine comparisons
      -- is bounded polynomially in d for fixed n
      cellCount n d ≤ C * d^n
```

You may need to define `cellCount` abstractly for a finite arrangement of comparison hyperplanes. Even a theorem that the number of cells is finite and explicitly bounded by a combinatorial expression is already meaningful.

A more immediately formalizable finite theorem:

```lean
theorem argmax_regions_finite
    {n : ℕ} :
    Finite {R : Set (Matrix (Fin n) (Fin n) ℝ) // ∃ S : Finset ((Fin n) × (Fin n) × (Fin n)),
      R = {M | ∀ i j k, ((i,j,k) ∈ S ↔ M i j ≥ M i k)}}
```

This is less elegant mathematically, but it certifies finiteness of universality cells.

**Why this is a breakthrough.**  
This is the algorithmic side of universality. Instead of “critical phenomena are mysterious,” you get:
- a finite polyhedral decomposition of parameter space,
- a computable invariant constant on cells,
- and complexity bounds for classifying a model into a universality class.

This opens a route to certified phase-diagram computation and tropical model checking.

---

## Recommended proof strategies

### Strategy A: Normalized compactness / finite-dimensional fixed point
Most promising for Theorem 1.

1. Define `normalizedTropTransfer` by subtracting one coordinate or the mean value.
2. Prove it maps a bounded convex set in `Fin n → ℝ` into itself, using oscillation bounds:
   \[
   \operatorname{osc}(T_M v) \le \max_{i,j,k}(M_{ij}-M_{ik}) + \operatorname{osc}(v).
   \]
   After normalization, oscillation is uniformly bounded.
3. Invoke a finite-dimensional fixed-point theorem if available in Mathlib; if not, prove existence constructively on a compact cube using continuity and extreme value / minimization of a defect functional.
4. Convert a normalized fixed point into a tropical eigenpair.

Why promising: it avoids deep cycle combinatorics and turns the problem into concrete finite-dimensional analysis.

### Strategy B: Dynamic programming / cycle mean construction
Most promising for Theorem 2.

1. Define the `k`-step value functions:
   \[
   u_k(i) := (T_M^k 0)(i).
   \]
   Show `u_k(i)` equals the maximum weight of a length-`k` path starting at `i`.
2. Use finite graph combinatorics to prove asymptotic linear growth:
   \[
   u_k(i)/k \to \lambda,
   \]
   where `λ` is the maximal cycle mean.
3. Under a strict gap hypothesis, show any noncritical path incurs a linear penalty `kδ`, giving exact asymptotic separation and a decay/exponent statement.

Why promising: this makes the renormalization interpretation vivid and is constructive enough for Lean on finite graphs.

### Strategy C: Polyhedral / arrangement-theoretic proof of universality cells
Most promising for Theorem 3.

1. Encode each argmax choice by linear inequalities between matrix entries.
2. Show each cell is the intersection of finitely many half-spaces, hence polyhedral.
3. Prove the invariant depends only on the active argmax pattern / critical cycle support.
4. Count cells using finite combinatorics of sign patterns or hyperplane arrangements.

Why promising: finite polyhedral combinatorics is much easier to certify than asymptotic analytic universality.

---

## How to build on the catalog theorems

Do not merely cite them; use them as structural bridges.

1. `tropical_universal_idempotent`  
   Use this as the seed identity ensuring max-plus idempotence is the correct algebraic semantics. In proofs of monotonicity/idempotence for transfer maps, repeatedly reduce expressions of the form `max a a`.

2. `fixed_points_are_iterative_invariants`  
   Once you produce a normalized fixed point `v`, immediately derive that all iterates preserve it. This is the formal bridge from “eigenvector exists” to “renormalization invariant exists.”

3. `idempotent_renormalization_duality`  
   Use this theorem to phrase the fixed-point/eigenpair theorem as a certified renormalization duality result, not just a matrix lemma. The theorem should appear in the final narrative as the conceptual explanation of why tropical fixed points encode coarse-grained phases.

4. `spectral_gap_distance`  
   Reuse it as a technical gap-to-distance lemma when proving that a positive tropical spectral gap yields quantitative separation between critical and noncritical sectors. Even if its exact statement is abstract, connect your decay parameter `δ` to its certified lower-bound mechanism.

5. `hamiltonian_gap_time_duality`  
   This is the cross-domain bridge theorem. Use it to compare tropical transfer gap ↔ relaxation time with Hamiltonian gap ↔ temporal scale. A formal corollary equating or bounding these scales would be extremely valuable.

---

## Cross-domain connections you should explicitly exploit

1. **Statistical mechanics / renormalization group**  
   Fixed points of `normalizedTropTransfer` are tropical RG fixed points. Spectral gap gives the exact relaxation or correlation scale.

2. **Optimal control / dynamic programming**  
   `T_M` is the Bellman operator for a deterministic finite-state control system. Tropical eigenvectors correspond to bias functions; max cycle mean is the average reward. This connection is mathematically rigorous and highly formalizable.

3. **Spectral graph theory**  
   Cycle mean and gap are graph invariants. Universality classes become combinatorial classes of weighted digraphs.

4. **Hamiltonian complexity / quantum analogy**  
   Through `hamiltonian_gap_time_duality`, interpret the tropical gap as a classical/idempotent shadow of quantum spectral gap phenomena. This is exactly the kind of “I did not expect that connection” bridge worth making precise.

5. **Computational complexity**  
   The cell decomposition theorem is a formal statement that universality classification can be reduced to finite polyhedral decision problems. This invites certified algorithms.

Application keywords: `tropical spectral theory`, `renormalization group`, `critical exponent`, `spectral gap`, `max-plus algebra`, `dynamic programming`, `average reward`, `polyhedral complexity`, `universality classification`, `Hamiltonian gap duality`.

---

## Concrete Lean development plan

1. **Define the operator**
   - `tropTransfer`
   - `normalizedTropTransfer`
   - monotonicity and additive homogeneity lemmas:
     ```lean
     theorem tropTransfer_monotone ...
     theorem tropTransfer_add_const ...
     theorem normalizedTropTransfer_gauge_invariant ...
     ```

2. **Define finite-step iteration**
   - `iterate`
   - path-value interpretation for `iterate (tropTransfer M)` if feasible.

3. **Prove fixed-point/eigenpair existence**
   - Start with normalized fixed point.
   - Derive eigenpair.

4. **Define and prove gap-based statements**
   - oscillation norm,
   - eventual linear asymptotics or quantitative contraction under gap assumptions.

5. **Define universality invariant**
   - argmax support, critical edge set, or critical cycle support.
   - prove invariance on tropical cells.

6. **Optional but powerful**
   - algorithm extraction: a function that computes candidate invariant on `Fin n`.
   - prove correctness.

---

## Minimal nontrivial theorem bundle to complete this cycle

If the full program is too large, complete at least the following certified bundle:

```lean
theorem exists_normalized_fixed_point_fin
    {n : ℕ} (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) :
    ∃ v : Fin n → ℝ, normalizedTropTransfer M v = v

theorem normalized_fixed_point_iter_invariant
    {n : ℕ} (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) :
    ∃ v : Fin n → ℝ, ∀ k : ℕ, iterate (normalizedTropTransfer M) k v = v

theorem universality_invariant_constant_on_cells
    {n : ℕ}
    (M N : Matrix (Fin n) (Fin n) ℝ)
    (hcell : sameArgmaxPattern M N) :
    universalityInvariant M = universalityInvariant N
```

If you can add one gap theorem, even in a simplified finite form, the cycle becomes genuinely field-opening.

---

## What would make this paradigm-shifting

A theorem of the form

```lean
theorem tropical_rg_duality_with_gap
    {n : ℕ} (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ)
    (hgap : hasPositiveTropicalGap M) :
    ∃ (λ ξ : ℝ) (v : Fin n → ℝ),
      IsTropEigenpair M λ v ∧
      ξ = 1 / tropicalGap M ∧
      0 < ξ ∧
      isUniversalityInvariant (criticalSupport M)
```

would be a flagship result: a fully formal theorem that extracts a critical exponent from an idempotent transfer operator and certifies its universality data.

That is the kind of theorem that opens a new file, then a new library, then a new subfield.

---

## Deliverables

1. Lean file(s) with theorems above, minimizing `sorry`.
2. Definitions chosen to maximize future reuse.
3. At least one theorem explicitly invoking or leveraging a catalog theorem.
4. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - tropical Perron–Frobenius theorem on strongly connected weighted digraphs;
   - certified average-reward/control interpretation of tropical critical exponents;
   - comparison theorem between Hamiltonian gap and tropical transfer gap;
   - tropical phase diagram computation via polyhedral cell enumeration;
   - extension from finite deterministic transfer operators to stochastic/idempotent kernels.

Produce that `FUTURE_DIRECTIONS.md` explicitly. It is required.

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

Research domain: Physics
Research mode: prove
