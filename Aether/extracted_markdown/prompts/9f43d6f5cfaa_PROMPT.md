## Assignment: Exhibit

**Mode:** `prove`

Prove a genuinely new theorem that turns the Schwartz–Zippel worldview into an exact coding-theoretic statement for Reed–Muller evaluation codes, and then push it toward polynomial identity testing for algebraic circuits. Do not settle for a soft lower bound if an exact extremal theorem is within reach.

Minimize `sorry`. If you introduce auxiliary definitions, make them reusable and theorem-shaped rather than ad hoc.

---

## Research Direction 1: Exact Minimum Distance of Generalized Reed–Muller Codes

### Breakthrough Goal
Formalize and prove the **exact minimum distance theorem** for low-degree multivariate polynomial evaluation codes over a finite field, including an explicit extremal codeword attaining the bound. This is not just a coding theorem: it is the finite-field geometric skeleton behind low-degree testing, secret sharing thresholds, and PIT soundness.

The conceptual leap is to move from:

- “nonzero low-degree polynomials cannot vanish too often”

to the sharper statement:

- “the maximal zero set among nonzero degree-`≤ d` polynomials is attained by a product of distinct affine linear factors, hence the minimum distance is exact.”

This closes the gap between a probabilistic lemma and a sharp extremal structure theorem.

---

## Precise Theorem Statement

Let `𝔽_q` be a finite field, `n ≥ 1`, and let `RM_q(n,d)` be the code of evaluation vectors of multivariate polynomials in `n` variables of total degree at most `d`, evaluated on all points of `Fin q → 𝔽_q` (or an equivalent finite indexing type of cardinality `q^n`). For `0 ≤ d < q`, the minimum Hamming distance is exactly

\[
(q-d)\, q^{n-1}.
\]

Moreover, this bound is attained by the polynomial

\[
f(X_1,\dots,X_n)=\prod_{i=0}^{d-1}(X_1-a_i)
\]

for any choice of `d` distinct field elements `a_0,\dots,a_{d-1}`.

### Lean 4 target shape
You may need to adapt names to the existing Mathlib polynomial API, but the theorem should look approximately like this:

```lean
theorem reedMuller_minimum_distance_exact
  (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
  (n d : ℕ)
  (hn : 1 ≤ n)
  (hd : d < Fintype.card 𝔽) :
  reedMullerMinimumDistance 𝔽 n d
    = (Fintype.card 𝔽 - d) * (Fintype.card 𝔽)^(n - 1)
```

and an explicit witness theorem:

```lean
theorem reedMuller_distance_attained_by_linear_factor_product
  (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽] [DecidableEq 𝔽]
  (n d : ℕ)
  (hn : 1 ≤ n)
  (hd : d < Fintype.card 𝔽) :
  ∃ f : MvPolynomial (Fin n) 𝔽,
    totalDegree f ≤ d ∧
    f ≠ 0 ∧
    hammingWeight (evalCodeword f)
      = (Fintype.card 𝔽 - d) * (Fintype.card 𝔽)^(n - 1)
```

If `reedMullerMinimumDistance`, `hammingWeight`, or `evalCodeword` do not yet exist, define them cleanly and prove the theorem against those definitions.

A particularly elegant witness in Lean is the polynomial depending only on coordinate `0 : Fin n`:
```lean
∏ a in s, (X 0 - C a)
```
where `s : Finset 𝔽` has cardinality `d`.

---

## Mathematical Framing

You already have the key lower-bound ingredients in view:

- `eval_map_injective_of_degree_lt_card`
- `hamming_weight_ge_of_schwartz_zippel`
- `reedMuller_minimum_distance` as the target exact computation

The new theorem should combine them into a sharp extremal result.

The lower bound says every nonzero codeword has weight at least `(q - d) q^(n-1)`. The missing step is the **explicit construction** of a codeword with exactly that weight. The witness polynomial vanishes exactly when the first coordinate lies in a chosen `d`-element subset of `𝔽_q`, so its zero set has cardinality `d q^(n-1)`, hence its support has size `(q-d) q^(n-1)`.

This theorem is a formal bridge from algebraic geometry over finite fields to exact coding parameters.

---

## Suggested Lean 4 type signatures for supporting lemmas

These are not mandatory verbatim, but Aristotle should aim for theorem statements of this precision.

### 1. Weight-zero-count relation
```lean
theorem hammingWeight_eval_eq_total_points_sub_zeroCount
  (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽] [DecidableEq 𝔽]
  (n : ℕ) (f : MvPolynomial (Fin n) 𝔽) :
  hammingWeight (evalCodeword f)
    = (Fintype.card 𝔽)^n - zeroCount f
```

### 2. Zero count of the extremal product
```lean
theorem zeroCount_prod_linear_factors_first_coordinate
  (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽] [DecidableEq 𝔽]
  (n : ℕ) (hn : 1 ≤ n)
  (s : Finset 𝔽) :
  zeroCount (∏ a in s, (MvPolynomial.X 0 - MvPolynomial.C a))
    = s.card * (Fintype.card 𝔽)^(n - 1)
```

### 3. Degree control of the witness
```lean
theorem totalDegree_prod_linear_factors_first_coordinate
  (𝔽 : Type*) [Field 𝔽]
  (n : ℕ) (s : Finset 𝔽) :
  MvPolynomial.totalDegree
      (∏ a in s, (MvPolynomial.X 0 - MvPolynomial.C a : MvPolynomial (Fin n) 𝔽))
    ≤ s.card
```

### 4. Nonzeroness of the witness
```lean
theorem prod_linear_factors_first_coordinate_ne_zero
  (𝔽 : Type*) [Field 𝔽] [DecidableEq 𝔽]
  (n : ℕ) (s : Finset 𝔽) :
  (∏ a in s, (MvPolynomial.X 0 - MvPolynomial.C a : MvPolynomial (Fin n) 𝔽)) ≠ 0
```

This last lemma may use that `MvPolynomial (Fin n) 𝔽` is a domain.

---

## Proof Strategy Paths

### Strategy A: Extremal witness + existing lower bound
This is the most promising route.

1. **Lower bound**  
   Use `hamming_weight_ge_of_schwartz_zippel` to show every nonzero degree-`≤ d` codeword has weight at least `(q - d) q^(n-1)`.

2. **Construct explicit witness**  
   Pick a `Finset 𝔽` of cardinality `d` using `hd : d < Fintype.card 𝔽`. Define
   \[
   f = \prod_{a \in s}(X_0 - a).
   \]
   Prove `totalDegree f ≤ d`, `f ≠ 0`, and compute its zero count exactly.

3. **Conclude exactness**  
   Since the lower bound is attained, the minimum distance equals the bound.

**Why this is best:** it isolates the difficult finite-field combinatorics into a completely explicit geometric object. It is robust, elegant, and likely easiest to formalize in Lean.

---

### Strategy B: Fiber-counting via projection to one coordinate
A more structural route.

1. Regard evaluation points as fibers over the first coordinate:
   \[
   𝔽_q^n \cong 𝔽_q \times 𝔽_q^{n-1}.
   \]

2. For the witness polynomial depending only on `X₀`, show:
   - if `x₀ ∈ s`, then all points in that fiber are zeros;
   - if `x₀ ∉ s`, then no point in that fiber is a zero.

3. Count fibers: exactly `|s|` zero-fibers, each of size `q^(n-1)`.

**Why this is attractive:** it gives a clean decomposition theorem for zero sets of coordinate-dependent polynomials. This could later generalize to tensor-product code constructions and affine subspace test arguments.

---

### Strategy C: Factorization-to-support dictionary
A more conceptual coding-theoretic route.

1. Prove that a product of distinct affine linear factors defines a union of parallel hyperplanes.
2. Show that for factors in a single coordinate, those hyperplanes are disjoint.
3. Translate “union of `d` parallel hyperplanes” into exact support size.

**Why it matters:** this recasts the theorem as a finite-geometry statement and prepares the ground for generalized Reed–Muller results when `d = a(q-1)+b`, where extremizers become products of coordinate blocks and one partial block.

---

## Most Promising Route
**Strategy A with Strategy B as the counting subroutine** is the ideal architecture.

Use the existing Schwartz–Zippel-based lower bound globally, then prove a fiber-counting lemma for the explicit witness. This minimizes dependency complexity while preserving a conceptual proof.

---

## Cross-Domain Connections

### Coding theory
This theorem certifies the exact distance of Reed–Muller codes, a cornerstone parameter for:

- unique decoding radius
- list decoding heuristics
- local testability intuition
- dual-code threshold phenomena

### Complexity theory
Exact minimum distance is the geometric engine behind:

- low-degree testing
- PCP-style algebraic consistency checks
- algebraic proof complexity
- hardness amplification for polynomial predicates

### Cryptography
Reed–Muller structure feeds directly into:

- secret sharing threshold analysis
- robust multiparty computation encodings
- algebraic masking schemes
- code-based commitments and proximity proofs

### Finite geometry
The extremal polynomial realizes a union of `d` parallel affine hyperplanes. This is a finite-field incidence statement masquerading as a coding theorem.

### Formal methods
A clean Lean development here creates a reusable library for:
- zero counting of multivariate polynomials
- evaluation codes
- exact support computations
- probabilistic soundness bounds from algebraic degree constraints

---

## Application Keywords
`Reed–Muller codes`, `minimum distance`, `Schwartz–Zippel`, `finite fields`, `evaluation codes`, `low-degree testing`, `PIT`, `secret sharing`, `algebraic complexity`, `formalized coding theory`, `finite geometry`, `error-correcting codes`

---

## Build Explicitly on Existing Verified Theorems

### From the current catalog
- `bounded_circuit_degree_bound`  
  Use this in Direction 2 to connect circuit size/structure to polynomial degree, turning an algebraic circuit into a soundness theorem over random evaluation.

- `soundness_error_bound`  
  Even if currently abstract, inspect whether it can serve as a probabilistic shell for converting zero-count bounds into error probabilities.

The other cryptographic theorems may not directly discharge algebraic obligations, but they can motivate later bridge lemmas about security reductions from polynomial nonzeroness.

---

## Research Direction 2: PIT Soundness for Algebraic Circuits

### Breakthrough Goal
Turn the Reed–Muller zero-density theorem into a formal **black-box PIT soundness theorem** for algebraic circuits over finite fields.

This is important because it converts a static algebraic fact into an algorithmic certification theorem: random evaluation detects nonzeroness except with probability at most `d/q`.

---

## Precise Theorem Statement

Let `C` be an algebraic circuit over `𝔽_q` in `n` variables, computing a polynomial of degree at most `d`. If the computed polynomial is nonzero, then for uniformly random `x ∈ 𝔽_q^n`,
\[
\Pr[C(x)=0] \le d/q,
\quad\text{equivalently}\quad
\Pr[C(x)\neq 0] \ge 1-d/q.
\]

### Lean 4 target shape
Something like:

```lean
theorem algebraicCircuit_PIT_soundness
  (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
  (n d : ℕ)
  (C : AlgCircuit 𝔽 n)
  (hdeg : circuitDegree C ≤ d)
  (hd : d < Fintype.card 𝔽)
  (hnz : circuitPolynomial C ≠ 0) :
  zeroProbability C ≤ (d : ℚ) / Fintype.card 𝔽
```

or equivalently:

```lean
theorem algebraicCircuit_random_detection_prob
  (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
  (n d : ℕ)
  (C : AlgCircuit 𝔽 n)
  (hdeg : circuitDegree C ≤ d)
  (hd : d < Fintype.card 𝔽)
  (hnz : circuitPolynomial C ≠ 0) :
  (1 : ℚ) - zeroProbability C ≥ 1 - (d : ℚ) / Fintype.card 𝔽
```

If `zeroProbability` is not defined, define it as a finite counting ratio over `Fintype.card 𝔽 ^ n`.

---

## Proof Strategy Paths for PIT

### Strategy A: Reduce circuits to polynomials
Most promising.

1. Use `bounded_circuit_degree_bound` to control the degree of `circuitPolynomial C`.
2. Apply the zero-count/Schwartz–Zippel theorem to that polynomial.
3. Divide by `q^n` to convert counts into probabilities.

This is the cleanest theorem statement and creates a reusable pipeline from circuit semantics to randomized soundness.

---

### Strategy B: Structural induction on circuits
1. Define circuit evaluation and degree recursively.
2. Prove a recursive soundness invariant for leaves, addition, and multiplication.
3. Recover the global probability bound.

This may be heavier than needed, but it could produce a more algorithmic circuit library.

---

### Strategy C: Code-theoretic embedding
1. View the circuit polynomial as a Reed–Muller codeword when degree-bounded.
2. Use minimum distance to bound the fraction of zeros.
3. Deduce PIT soundness.

This is conceptually powerful because it says:
**PIT is decoding-theoretic nontriviality detection.**

---

## Why This Is Revolutionary
If formalized cleanly, this creates a machine-checked triangle:

\[
\text{finite-field geometry} \Longleftrightarrow \text{coding theory} \Longleftrightarrow \text{randomized algebraic algorithms}.
\]

That triangle is foundational in modern complexity theory, but formal libraries usually contain fragments, not the connective tissue. This project can become the first serious Lean blueprint for algebraic pseudorandomness and low-degree reasoning.

It opens the door to:
- formal low-degree tests
- sum-check protocol soundness
- code-based cryptographic reductions
- derandomization metatheorems over finite fields
- certified algebraic property testing

---

## Concrete Deliverables

1. Define the Reed–Muller evaluation code object, or at minimum its codewords and Hamming weight.
2. Prove the lower bound from Schwartz–Zippel if not already available in the exact needed form.
3. Construct the explicit extremal witness polynomial.
4. Prove the exact minimum distance theorem.
5. Lift the zero-density theorem to PIT soundness for algebraic circuits.

If time forces triage, prioritize:
1. explicit witness construction,
2. exact distance theorem,
3. PIT corollary.

---

## Suggested Auxiliary Formalization Targets

- finite-product polynomial witness depending on one variable
- counting points in a coordinate fiber of `Fin n → 𝔽`
- conversion between zero counts and probabilities
- support/weight lemmas for finitely supported evaluation vectors
- existence of a `Finset 𝔽` of cardinality `d` from `d < Fintype.card 𝔽`

A useful helper theorem may be:

```lean
theorem exists_finset_card_of_lt_card
  (α : Type*) [Fintype α]
  (d : ℕ) (hd : d ≤ Fintype.card α) :
  ∃ s : Finset α, s.card = d
```

Mathlib may already have something close; use it rather than reproving from scratch if available.

---

## What To Watch Out For

- Be precise about `n = 0`. The formula simplifies there; if it complicates the statement, assume `1 ≤ n`.
- Decide early whether codewords are functions `((Fin n → 𝔽) → 𝔽)` or vectors indexed by a finite type. Pick one and keep it consistent.
- Total degree lemmas for `MvPolynomial` products can become annoying; isolate them immediately.
- When proving exact zero count, avoid inclusion–exclusion by choosing parallel hyperplanes in one coordinate, where disjointness is automatic.

---

## Demand: FUTURE_DIRECTIONS.md
At the end, produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete, breakthrough-level next steps**. These must be specific theorem targets, not vague topics.

Strong candidates include:
1. exact minimum distance of generalized Reed–Muller codes for arbitrary `d = a(q-1)+b`;
2. formal low-degree test soundness over finite fields;
3. sum-check protocol soundness from Schwartz–Zippel in Lean;
4. dual Reed–Muller structure and secret-sharing threshold theorems;
5. derandomized PIT for restricted circuit classes via subspace-evasive sets.

Make the future directions bold enough that they could define the next research cycle.

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

Research domain: Cryptography
Research mode: prove
