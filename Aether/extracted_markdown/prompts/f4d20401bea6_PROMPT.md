## Assignment: Formalize the dimension of bounded-degree polynomial spaces

Mode: **prove**

You are not being asked for a routine counting lemma. You are being asked to formalize the algebra–combinatorics interface that turns “monomials of bounded total degree” into a certified finite-dimensional object in Lean 4, in a way that can become infrastructure for Hilbert functions, graded algebras, algebraic complexity, and eventually formalized algebraic geometry.

The core breakthrough is to make the finite-dimensional truncation of multivariate polynomial rings computationally and structurally transparent:
- combinatorially, via weak compositions / stars-and-bars,
- algebraically, via a basis of monomials indexed by finitely supported exponent vectors,
- formally, via `MvPolynomial σ K`, `Finsupp`, `Submodule`, `FiniteDimensional.finrank`, and finite support degree bounds.

This should not stop at “there are this many monomials.” The target is a robust Lean theorem package identifying the bounded-degree subspace with a finite free `K`-module whose rank is the expected binomial coefficient.

---

## Precise theorem targets

Work over a field `K` and a finite variable type `σ`. Let `n = Fintype.card σ`. Define the subspace of multivariate polynomials of total degree `< d`:
```lean
def boundedTotalDegreeSubmodule
    (K : Type*) [Field K]
    (σ : Type*) [Fintype σ] [DecidableEq σ]
    (d : ℕ) : Submodule K (MvPolynomial σ K) :=
{ carrier := {p | p.totalDegree < d},
  zero_mem' := by
    simp,
  add_mem' := by
    intro p q hp hq
    exact lt_of_le_of_lt (MvPolynomial.totalDegree_add_le _ _) (max_lt_iff.mpr ⟨hp, hq⟩),
  smul_mem' := by
    intro a p hp
    exact lt_of_le_of_lt (MvPolynomial.totalDegree_smul_le _ _ ) hp }
```
If exact theorem names differ in Mathlib, adapt with the available `totalDegree_*` lemmas; if needed, define the submodule first using the known degree support characterization rather than this direct form.

### Primary theorem
Formalize the exact dimension formula:
```lean
theorem finrank_boundedTotalDegreeSubmodule
    (K : Type*) [Field K]
    (σ : Type*) [Fintype σ] [DecidableEq σ]
    (d : ℕ) :
    FiniteDimensional.finrank K (boundedTotalDegreeSubmodule K σ d)
      = Nat.choose (d + Fintype.card σ - 1) (Fintype.card σ)
```
This is the stars-and-bars theorem in algebraic disguise.

### Equivalent graded-slice theorem
A sharper theorem is often easier first: the homogeneous slice of exact total degree `m` has dimension `choose (m+n-1) n-1`. Define the subspace spanned by monomials with exponent sum exactly `m`, or if existing graded machinery is available, use the homogeneous component:
```lean
theorem finrank_homogeneousComponent
    (K : Type*) [Field K]
    (σ : Type*) [Fintype σ] [DecidableEq σ]
    (m : ℕ) :
    FiniteDimensional.finrank K (homogeneousComponent K σ m)
      = Nat.choose (m + Fintype.card σ - 1) (Fintype.card σ - 1)
```
Then derive the bounded-degree theorem by summing over `m < d` and invoking the hockey-stick identity:
```lean
∑ m in Finset.range d, Nat.choose (m + n - 1) (n - 1) = Nat.choose (d + n - 1) n
```

### Basis-level theorem
For downstream use, produce an explicit basis rather than only a finrank equality:
```lean
def monomialBasisBoundedTotalDegree
    (K : Type*) [Field K]
    (σ : Type*) [Fintype σ] [DecidableEq σ]
    (d : ℕ) :
    Basis {s : σ →₀ ℕ // s.sum (fun _ e => e) < d}
      K
      (boundedTotalDegreeSubmodule K σ d)
```
This is the real infrastructure theorem. Once this basis exists, the finrank statement should become a corollary from cardinality of the index type.

---

## Why this is a breakthrough

This theorem is the formal Hilbert-function seed crystal. Once in place, it opens several directions:
1. **Formalized Hilbert series**: the generating series of dimensions of graded pieces of `MvPolynomial σ K` becomes `(1 - t)^(-n)`.
2. **Algebraic complexity**: bounded-degree polynomial spaces are the ambient search spaces for arithmetic circuits; dimension controls lower bounds, interpolation, and rank arguments.
3. **Combinatorial commutative algebra**: monomial ideals, Gröbner theory, and Hilbert polynomials all begin from counting monomials excluded by degree constraints.
4. **Discrete probability / statistical mechanics**: weak compositions count occupancy states of bosons in `n` modes with total energy `m`; the same combinatorics drives partition functions.
5. **Information geometry / machine learning**: polynomial feature maps of degree `< d` have exactly this feature dimension, the backbone of kernel methods and tensorized models.

This is not just a lemma. It is the finite-dimensional doorway through which formalized algebraic geometry, complexity, and combinatorial species can all pass.

---

## Lean 4 theorem signature suggestions

Use signatures close to these, adapting to available Mathlib APIs:

```lean
open scoped BigOperators

noncomputable section

def boundedMonomialExponents
    (σ : Type*) [Fintype σ] [DecidableEq σ] (d : ℕ) :=
  {s : σ →₀ ℕ // s.sum (fun _ e => e) < d}

def exactMonomialExponents
    (σ : Type*) [Fintype σ] [DecidableEq σ] (m : ℕ) :=
  {s : σ →₀ ℕ // s.sum (fun _ e => e) = m}

theorem card_exactMonomialExponents
    (σ : Type*) [Fintype σ] [DecidableEq σ] (m : ℕ) :
    Fintype.card (exactMonomialExponents σ m)
      = Nat.choose (m + Fintype.card σ - 1) (Fintype.card σ - 1)

theorem card_boundedMonomialExponents
    (σ : Type*) [Fintype σ] [DecidableEq σ] (d : ℕ) :
    Fintype.card (boundedMonomialExponents σ d)
      = Nat.choose (d + Fintype.card σ - 1) (Fintype.card σ)

def boundedTotalDegreeSubmodule
    (K : Type*) [Field K]
    (σ : Type*) [Fintype σ] [DecidableEq σ]
    (d : ℕ) : Submodule K (MvPolynomial σ K)

def monomialBasisBoundedTotalDegree
    (K : Type*) [Field K]
    (σ : Type*) [Fintype σ] [DecidableEq σ]
    (d : ℕ) :
    Basis (boundedMonomialExponents σ d) K (boundedTotalDegreeSubmodule K σ d)

theorem finrank_boundedTotalDegreeSubmodule
    (K : Type*) [Field K]
    (σ : Type*) [Fintype σ] [DecidableEq σ]
    (d : ℕ) :
    FiniteDimensional.finrank K (boundedTotalDegreeSubmodule K σ d)
      = Nat.choose (d + Fintype.card σ - 1) (Fintype.card σ)
```

If `Field` is too restrictive for basis construction, consider proving a stronger theorem over a semiring/ring for spanning + linear independence, then specialize to `Field K` for `finrank`.

---

## Proof architecture: three viable strategies

### Strategy A: Explicit monomial basis via bounded-support exponent vectors
This is the most canonical and likely the best long-term infrastructure route.

**Step 1: Define the exponent index type.**
Let
```lean
{ s : σ →₀ ℕ // s.sum (fun _ e => e) < d }
```
index monomials `MvPolynomial.monomial s 1`.

Prove these monomials lie in the bounded-degree submodule.

**Step 2: Prove linear independence and spanning.**
- Linear independence should descend from the standard linear independence of distinct monomials in `MvPolynomial`.
- Spanning follows by expanding any polynomial as a finite sum of monomials and using the total-degree bound to show every exponent in its support has sum `< d`.

This step may require a support lemma of the form:
```lean
p.totalDegree < d → ∀ s ∈ p.support, s.sum (fun _ e => e) < d
```
or a weak inequality version using `s ≤ p.totalDegree` in the `WithBot ℕ` sense.

**Step 3: Convert basis cardinality to binomial coefficient.**
Count the index type using a stars-and-bars equivalence with weak compositions of an integer `< d` into `n` parts, either:
- by summing exact-degree counts,
- or by a direct bijection to compositions of `d-1` with a slack variable.

**Why Strategy A is most promising:** it yields the strongest reusable artifact: an actual basis object. This is what later work on Hilbert series, interpolation, and circuit lower bounds will need.

---

### Strategy B: Decompose into homogeneous components and use a hockey-stick summation
This is conceptually elegant and closer to graded algebra.

**Step 1: Formalize exact-degree pieces.**
Define the subspace spanned by monomials of degree exactly `m`. Show bounded-degree subspace is the direct sum over `m < d` of these pieces.

**Step 2: Prove each exact-degree piece has basis indexed by**
```lean
{s : σ →₀ ℕ // s.sum (fun _ e => e) = m}
```
and hence finrank `choose (m+n-1) (n-1)`.

**Step 3: Sum dimensions.**
Use finite direct sum finrank additivity and the hockey-stick identity:
```lean
∑ m in Finset.range d, choose (m+n-1) (n-1) = choose (d+n-1) n.
```

**Why Strategy B is powerful:** it naturally leads to formal Hilbert function and Hilbert series theorems. If Mathlib’s graded machinery is mature enough, this can become a gateway theorem for standard graded algebras.

---

### Strategy C: Direct combinatorial equivalence with order-preserving separator sets
This is the pure counting route and may be easiest for the cardinality lemma if `Finsupp.antidiagonal` becomes awkward.

**Step 1: Show exponent vectors of exact degree `m` correspond to weak compositions of `m` into `n` parts.**
For finite `σ`, first transport along an equivalence `σ ≃ Fin n`.

**Step 2: Use stars-and-bars as subsets of size `n-1` of `Fin (m+n-1)`.**
Map a composition `(a₁,…,aₙ)` to separator positions after cumulative sums:
```text
a₁ | a₂ | ... | aₙ
```

**Step 3: Lift the combinatorial count back to `MvPolynomial`.**
Once the index set cardinality is known, use basis cardinality to conclude the finrank formula.

**Why Strategy C matters:** it avoids dependence on fragile specialized API and gives a clean combinatorial skeleton that can be reused elsewhere, including formal species and occupancy models.

---

## Recommended execution order

1. **First prove the exact-degree counting lemma for `Fin n`.**
   This isolates the stars-and-bars core.
2. **Transport to arbitrary finite `σ`.**
   Use `Fintype.equivFin σ`.
3. **Construct the monomial basis for exact degree or bounded degree.**
4. **Derive `finrank` formula.**
5. **If time permits, prove the Hilbert-series corollary.**

This ordering minimizes the chance that algebraic API friction blocks the combinatorial theorem.

---

## Key supporting lemmas to hunt for or prove

You will likely need versions of:

- monomials are linearly independent in `MvPolynomial`,
- support exponents are bounded by total degree,
- `totalDegree_monomial`,
- `totalDegree_C_mul_X` / `totalDegree_add_le`,
- finite-dimensionality of submodule spanned by a finite set,
- cardinality of weak compositions / `Finsupp.antidiagonal`,
- binomial summation identity (hockey-stick).

Potential useful patterns:
```lean
Finsupp.sum
MvPolynomial.monomial
MvPolynomial.support
Submodule.span
FiniteDimensional.finrank_span_eq_card
Nat.choose
Finset.antidiagonal
Fintype.card_subtype_iff
Fintype.card_ofFinset
```

If Mathlib lacks the exact stars-and-bars theorem you need, prove a dedicated combinatorial lemma:
```lean
theorem card_finsupp_total_eq
    (n m : ℕ) :
    Fintype.card {s : Fin n →₀ ℕ // s.sum (fun _ e => e) = m}
      = Nat.choose (m + n - 1) (n - 1)
```
and then derive the `< d` version by summation.

---

## Cross-domain connections to exploit

Do not leave this as isolated commutative algebra. Connect it explicitly.

### 1. Algebraic complexity
The dimension of degree-`< d` polynomial space in `n` variables is the size of the ambient hypothesis class for arithmetic circuits restricted by degree. This links directly to:
- `bounded_circuit_degree_bound`
- `mulGates_lower_bound_from_degree`

A strong follow-up theorem could bound how many coefficients must be recovered to identify a bounded-degree polynomial, yielding interpolation complexity lower bounds.

### 2. Machine learning / kernel methods
Polynomial feature maps of total degree `< d` in `n` variables have exactly this many coordinates. This is the formal dimension behind polynomial kernels, tensor lifts, and feature explosion.

### 3. Statistical mechanics / occupancy models
`choose (m+n-1) (n-1)` counts bosonic occupancy states of total energy `m` across `n` modes. A formal bridge theorem here could relate Hilbert series to partition functions.

### 4. Coding theory / sparse recovery
Bounded-degree polynomial spaces are message spaces for Reed–Muller-type codes. Formal dimension statements are prerequisites for code rate and interpolation theorems.

### 5. Enumerative combinatorics
This is the species-level count of multisets of size `m` on `n` colors. Formalizing this once unlocks multiple combinatorial transfer theorems.

---

## Concrete theorem package to aim for

A truly valuable contribution would include most of the following:

1. `card_exactMonomialExponents`
2. `card_boundedMonomialExponents`
3. `monomialBasisExactDegree`
4. `monomialBasisBoundedTotalDegree`
5. `finrank_homogeneousComponent`
6. `finrank_boundedTotalDegreeSubmodule`
7. Optional Hilbert-series corollary:
   ```lean
   theorem hilbertFunction_mvPolynomial
       (n m : ℕ) :
       hilbertFunction (MvPolynomial (Fin n) K) m = Nat.choose (m + n - 1) (n - 1)
   ```

Even if the full Hilbert-series theorem is too ambitious this cycle, design your definitions so it becomes immediate later.

---

## Nontriviality requirement

Do not settle for a naked combinatorial cardinality theorem detached from algebra. The theorem should culminate in a `FiniteDimensional.finrank` statement about a genuine polynomial subspace. The counting lemma is necessary but not sufficient.

Also, avoid proving only the univariate case. The multivariate finite-type theorem is the point.

---

## Interaction with existing catalog theorems

The listed catalog theorems are not directly on-point, but they suggest a broader algebraic-complexity ecosystem. Use this theorem as foundational infrastructure for later strengthening:
- dimension bounds for spaces representable by bounded circuits,
- lower bounds via degree-vs-parameter counting,
- finite search-space estimates for polynomial reconstruction.

In particular, this theorem can become the “ambient dimension” lemma underlying future refinements of `bounded_circuit_degree_bound` and `mulGates_lower_bound_from_degree`.

---

## Deliverables

1. Lean 4 code proving as much of the theorem package above as possible.
2. Definitions that are reusable, not one-off hacks.
3. Minimize `sorry`; if blocked, isolate the exact missing lemma.
4. Add a structured `FUTURE_DIRECTIONS.md`.

---

## Required `FUTURE_DIRECTIONS.md`

You must produce `FUTURE_DIRECTIONS.md` with **3–5 concrete, breakthrough-level next steps**, each with:
- theorem statement,
- why it matters,
- likely dependencies,
- estimated proof difficulty.

The next steps should be ambitious and specific, for example:
1. formal Hilbert series of `MvPolynomial (Fin n) K`,
2. dimension formula for quotient by monomial ideals via standard monomials,
3. Reed–Muller code dimension theorem,
4. interpolation complexity lower bounds from bounded-degree dimension,
5. graded Noether normalization toy model in finite type.

---

## Application keywords

Hilbert function, Hilbert series, stars and bars, weak compositions, graded algebra, multivariate polynomials, monomial basis, finite-dimensional truncation, algebraic complexity, arithmetic circuits, polynomial kernels, Reed–Muller codes, occupancy models, combinatorial commutative algebra, formalized algebraic geometry.

Go build the finite-dimensional skeleton of multivariate polynomial theory.

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
