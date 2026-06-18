# Mode: prove

Aristotle,

This is not a routine parameter computation. This is the missing extremal theorem that turns generalized Reed–Muller codes from a family with known folklore numerics into a formally certified geometric theory of extremal low-degree functions on finite affine space. The target is the full minimum-distance formula, but the real breakthrough is sharper: characterize the extremizers by a tensor-product vanishing geometry and make that geometry executable in Lean.

You should aim for a two-layer result:

1. **Numerical extremal theorem**: the exact minimum weight formula.
2. **Geometric rigidity theorem**: equality is attained by polynomials whose zero set is a union of affine fibers cut independently in `a` coordinates and by one partial fiber condition in one additional coordinate.

The second statement is what makes this field-opening rather than merely completing a table.

---

## Primary theorem target

Let `q := Fintype.card 𝔽`. For `d = a * (q - 1) + b` with `b < q - 1` and `a < n`, prove:

```lean
theorem generalized_reedMuller_min_distance
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    (n d a b : ℕ)
    (h_decomp : d = a * (Fintype.card 𝔽 - 1) + b)
    (hb : b < Fintype.card 𝔽 - 1)
    (ha : a < n) :
    reedMullerMinWeight 𝔽 n d =
      (Fintype.card 𝔽 - b) * (Fintype.card 𝔽) ^ (n - 1 - a)
```

But do not stop there. Strengthen it to the structural statement that explains *why* this formula is true.

---

## Breakthrough structural theorem

A decisive theorem would be a formal extremizer classification along the following lines.

Let `q := Fintype.card 𝔽`. Define the canonical extremal polynomial
\[
f(x_1,\dots,x_n)=c\cdot \prod_{i=1}^a (1-(x_i-\alpha_i)^{q-1})\cdot \prod_{j=1}^{b} (x_{a+1}-\beta_j),
\]
or an affine-coordinate equivalent normal form, depending on your chosen Reed–Muller model.

Then prove that minimum-weight codewords are exactly the affine images of such products.

A Lean-facing version may look like:

```lean
theorem generalized_reedMuller_extremizer_exists
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    (n d a b : ℕ)
    (h_decomp : d = a * (Fintype.card 𝔽 - 1) + b)
    (hb : b < Fintype.card 𝔽 - 1)
    (ha : a < n) :
    ∃ f : MvPolynomial (Fin n) 𝔽,
      reedMullerCodeword 𝔽 n d f ∧
      hammingWeight (evalOnAffineSpace f) =
        (Fintype.card 𝔽 - b) * (Fintype.card 𝔽) ^ (n - 1 - a)
```

and ideally a rigidity theorem such as:

```lean
theorem generalized_reedMuller_extremizer_rigidity
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    (n d a b : ℕ)
    (hq : 1 < Fintype.card 𝔽)
    (h_decomp : d = a * (Fintype.card 𝔽 - 1) + b)
    (hb : b < Fintype.card 𝔽 - 1)
    (ha : a < n)
    {f : MvPolynomial (Fin n) 𝔽}
    (hf : reedMullerCodeword 𝔽 n d f)
    (hmin :
      hammingWeight (evalOnAffineSpace f) =
        (Fintype.card 𝔽 - b) * (Fintype.card 𝔽) ^ (n - 1 - a)) :
    ∃ φ : AffineEquiv (Fin n → 𝔽) (Fin n → 𝔽), ∃ c : 𝔽, c ≠ 0 ∧
      extremalRMShape 𝔽 n a b (fun x => eval f (φ x)) c
```

If the full rigidity theorem is too large for one cycle, prove the numerical theorem and a one-sided existence theorem now, then put full rigidity in `FUTURE_DIRECTIONS.md`.

---

## Why this is a breakthrough

The formula itself is classical in coding theory, but formalizing it in Lean at full generality over arbitrary finite fields is already substantial. The real leap is to recast the proof as a theorem about **tensor-product zero loci in finite affine geometry**. That perspective opens three directions immediately:

- **Coding theory**: exact extremizers for generalized Reed–Muller codes, not merely distances.
- **Finite algebraic geometry**: a classification of degree-constrained hypersurfaces maximizing the number of zeros in `𝔽^n`.
- **Complexity / PCPs**: optimal low-degree test soundness thresholds are powered by exactly these extremal configurations.

This is the kind of theorem that can become infrastructure for whole families of finite-field arguments in Lean.

---

## Mathematical insight: what is really happening

Write `q = |𝔽|` and `d = a(q-1)+b` with `0 ≤ b < q-1`. The minimum-weight codewords correspond to functions with **maximal zero set** among nonzero degree-`≤ d` polynomials on `𝔽^n`. The extremal geometry is:

- in each of `a` coordinates, force vanishing on an entire hyperplane slice structure;
- in one additional coordinate, force vanishing on exactly `b` fibers;
- leave the remaining `n-a-1` coordinates free.

So the support has size
\[
(q-b) q^{n-1-a}.
\]

This is a finite-field analog of a product-set isoperimetric principle: under a degree budget, the way to maximize zeros is not by spreading degree diffusely, but by concentrating it into coordinatewise fiber constraints. That tensor-product principle is the conceptual core to expose in Lean.

---

## Suggested formal decomposition

You will likely need to isolate the theorem into lemmas that are mathematically canonical and Lean-friendly.

### 1. Existence of extremal codewords
Construct an explicit polynomial of degree `d` with exactly the claimed support size.

Candidate normal form:
- use `a` factors of degree `q-1` giving indicator-type behavior of a chosen affine hyperplane complement;
- use one factor of degree `b` in a new coordinate with exactly `b` roots;
- multiply by a nonzero scalar.

A likely formal lemma:

```lean
theorem generalized_reedMuller_min_distance_le
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    (n d a b : ℕ)
    (h_decomp : d = a * (Fintype.card 𝔽 - 1) + b)
    (hb : b < Fintype.card 𝔽 - 1)
    (ha : a < n) :
    reedMullerMinWeight 𝔽 n d ≤
      (Fintype.card 𝔽 - b) * (Fintype.card 𝔽) ^ (n - 1 - a)
```

### 2. Hyperplane restriction inequality
For any nonzero polynomial `f` of degree `≤ d`, restrict to affine hyperplanes `x_i = c`. One of two things happens:
- many restrictions remain nonzero, giving a support lower bound by summing over fibers;
- or `f` vanishes on many parallel hyperplanes, forcing divisibility by the corresponding linear factors and lowering the residual degree.

This is the engine of the induction.

Possible intermediate theorem:

```lean
theorem rm_hyperplane_restriction_or_factor
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    (n : ℕ) (i : Fin n) (f : MvPolynomial (Fin n) 𝔽) :
    -- precise statement to be chosen:
    -- either many restrictions are nonzero, or f is divisible by a product of linear factors in variable i
    True
```

You should make this precise in the language most compatible with your code model.

### 3. Induction on `(n,d)` via degree peeling
The lower bound proof should recursively strip off full `(q-1)`-blocks of degree. If `f` vanishes on `t` parallel hyperplanes in one coordinate, factor out a degree-`t` univariate product and reduce to degree `d-t`. The optimal recurrence should force `t ≤ q-1`, and the extremal choice is exactly `t = q-1` repeated `a` times, then `t = b`.

A likely lower-bound theorem:

```lean
theorem generalized_reedMuller_min_distance_ge
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    (n d a b : ℕ)
    (h_decomp : d = a * (Fintype.card 𝔽 - 1) + b)
    (hb : b < Fintype.card 𝔽 - 1)
    (ha : a < n) :
    (Fintype.card 𝔽 - b) * (Fintype.card 𝔽) ^ (n - 1 - a) ≤
      reedMullerMinWeight 𝔽 n d
```

Then combine both inequalities.

---

## Proof strategies

## Strategy A: classical hyperplane-induction via factorization
This is the most promising route for Lean.

**Step 1.** For a fixed coordinate `x_i`, count the number of affine fibers `x_i = c` on which `f` vanishes identically.  
If there are `t` such fibers, prove divisibility by
\[
\prod_{c \in S}(X_i-c),
\]
where `S` is the set of such `c`.

**Step 2.** Write `f = g * h`, where `g` is this univariate-in-`x_i` factor and `h` has reduced degree.  
On remaining fibers, restrictions of `h` are nonzero degree-bounded polynomials in `n-1` variables, so induction gives support lower bounds fiberwise.

**Step 3.** Optimize the resulting recurrence in `t`.  
Show the minimum occurs exactly when degree is spent in chunks of `q-1`, producing the decomposition `d = a(q-1)+b`.

**Why best:** this mirrors the actual extremal geometry, uses finite-field polynomial identities naturally available in Mathlib, and gives reusable infrastructure for low-degree testing arguments.

---

## Strategy B: footprint / Gröbner-shadow method over finite grids
This is more conceptually algebraic and could be revolutionary if formalized cleanly.

**Step 1.** Work modulo the vanishing ideal
\[
(X_1^q-X_1,\dots,X_n^q-X_n),
\]
so every function on `𝔽^n` has a unique reduced representative with each variable exponent `< q`.

**Step 2.** Bound the number of nonzeros of a reduced polynomial via its monomial support and a combinatorial shadow argument.  
The extremal monomial should be
\[
X_1^{q-1}\cdots X_a^{q-1} X_{a+1}^{b},
\]
whose footprint gives exactly the support size `(q-b)q^{n-1-a}`.

**Step 3.** Show this footprint bound is attained by explicit product-form polynomials.

**Why important:** this connects coding theory to Gröbner methods, finite Nullstellensatz, and combinatorial commutative algebra. It is harder to set up in Lean but far more extensible.

---

## Strategy C: finite Schwartz–Zippel with extremal rigidity
This is elegant but may need stronger preparatory lemmas.

**Step 1.** Develop a sharp zero-count theorem for nonzero degree-`≤ d` polynomials on `𝔽^n`.  
The target zero-count upper bound is
\[
q^n - (q-b)q^{n-1-a}.
\]

**Step 2.** Prove the upper bound by iterated slicing and a sharp univariate root bound on each fiber.

**Step 3.** Reconstruct the minimum-distance theorem by identifying codeword weight with the number of nonzeros.

**Why useful:** this packages the result as a standalone finite algebraic geometry theorem, making it reusable beyond coding theory.

---

## Recommended route

Use **Strategy A** as the main formal proof, but phrase the main lemmas in a way that makes **Strategy C** emerge as a corollary. If possible, mention in comments or docstrings that the result is a sharp zero-count theorem on affine space. This will make later PCP and algebraic-geometry developments much easier.

---

## Lean 4 formalization guidance

You will need to choose or define carefully:

- the model of Reed–Muller codewords:
  - either as evaluations of `MvPolynomial (Fin n) 𝔽` of total degree `≤ d`,
  - or as a subspace of functions `(Fin n → 𝔽) → 𝔽`;
- the weight function:
  - Hamming weight of the evaluation vector/function;
- the reduced polynomial representation modulo `X^q - X` if needed.

Likely useful Mathlib ingredients:
- `MvPolynomial`
- total degree / support / evaluation lemmas
- finite function spaces via `Fintype`
- polynomial divisibility by linear factors from root conditions
- cardinality lemmas for finite affine spaces

A good architectural move is to define:

```lean
def affineEvalFn (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽] (n : ℕ) :=
  MvPolynomial (Fin n) 𝔽 → ((Fin n → 𝔽) → 𝔽)
```

and then define support and weight on this function.

Also isolate a reusable lemma of the form:

```lean
theorem mvpoly_vanishes_on_fiber_iff_linear_factor
    (𝔽 : Type*) [Field 𝔽]
    (n : ℕ) (i : Fin n) (c : 𝔽) (f : MvPolynomial (Fin n) 𝔽) :
    (∀ x : Fin n → 𝔽, x i = c → eval x f = 0) ↔
    (X i - C c) ∣ f
```

or a variant after reindexing / substitution. Even proving one implication is already a major enabler.

---

## How to build on catalog theorems

The current verified catalog is not directly about Reed–Muller codes, but you should still exploit its structural lessons.

- `finite_field_state_space`  
  Use this as conceptual precedent for finite-field global state spaces: your evaluation domain `(Fin n → 𝔽)` is exactly such a finite state space. If this theorem already packages cardinality or finiteness infrastructure, reuse it to avoid rebuilding finite-instance plumbing.

- `lawvere_proof_coding_theorem`  
  This suggests an existing bridge between logic and coding. Position the Reed–Muller theorem as a concrete extremal semantics theorem for low-degree proofs. If there are code-space abstractions there, reuse them to define `reedMullerMinWeight` at the right level.

- `finite_duality_theorem` and `extremal_has_minimal_support`  
  These are signals that the catalog already values extremality/support dualities. Your theorem should be framed explicitly as an “extremal support under algebraic degree constraints” theorem. If there is a generic support-minimality API, instantiate it.

- `finite_access_structure_has_closure_capacity_realization`  
  Conceptually, this is about exact realization of extremal combinatorial data. The Reed–Muller extremizer existence theorem is analogous: exact realization of the support lower bound by a concrete algebraic object. If there is a reusable “realization” pattern in the codebase, imitate it.

Do not force these theorems into the proof if they are irrelevant technically. Instead, let them influence the abstraction boundaries and naming.

---

## Cross-domain connections to make explicit in the file/docstring

### Coding theory
This theorem gives the exact minimum distance of generalized Reed–Muller codes over arbitrary finite fields. It certifies the full parameter tradeoff for local testability, local decodability heuristics, and algebraic code concatenation schemes.

### Finite algebraic geometry
Reinterpret the theorem as:
> Among nonzero polynomials on `𝔽^n` of total degree `≤ d`, the maximum number of zeros is `q^n - (q-b)q^{n-1-a}`.

This is a sharp affine hypersurface extremal theorem over finite fields.

### Complexity theory / PCPs
Low-degree tests, sum-check variants, and algebraic PCP soundness all depend on sharp bounds for how often a nonzero low-degree polynomial can vanish. Your theorem provides exact worst-case soundness, not merely asymptotic estimates.

### Additive combinatorics
The extremizers are product-structured sets of codimension built one coordinate at a time. This is a finite-field analog of compression phenomena and lexicographic extremizers in isoperimetry.

### Algebraic statistics / finite learning theory
Low-degree classifiers over finite feature spaces achieve maximal ambiguity exactly on these tensor-product fiber arrangements. This suggests a bridge to concept class complexity and exact shattering thresholds.

---

## Application keywords

Use these explicitly in comments and `FUTURE_DIRECTIONS.md`:

- generalized Reed–Muller code
- minimum distance
- finite-field hypersurface
- sharp zero-count theorem
- affine fiber decomposition
- tensor-product vanishing
- low-degree testing
- algebraic PCP
- finite Nullstellensatz
- Gröbner footprint bound
- extremal support
- finite affine geometry

---

## Concrete milestones

1. Define or locate `reedMullerMinWeight`.
2. Prove the explicit upper bound by constructing an extremal polynomial.
3. Prove a fiber-restriction/factorization lemma.
4. Derive the lower bound by induction on `n` and degree decomposition.
5. Package the result as both a coding theorem and a zero-count theorem.

If time permits, add:

```lean
theorem affine_zero_set_card_le_of_totalDegree_le
    (𝔽 : Type*) [Field 𝔽] [Fintype 𝔽]
    (n d a b : ℕ)
    (h_decomp : d = a * (Fintype.card 𝔽 - 1) + b)
    (hb : b < Fintype.card 𝔽 - 1)
    (ha : a < n)
    {f : MvPolynomial (Fin n) 𝔽}
    (hf : f ≠ 0)
    (hdeg : totalDegree f ≤ d) :
    Fintype.card {x : Fin n → 𝔽 // eval x f = 0} ≤
      (Fintype.card 𝔽)^n -
      (Fintype.card 𝔽 - b) * (Fintype.card 𝔽) ^ (n - 1 - a)
```

This theorem may become the more reusable headline result.

---

## Deliverables

Produce:

1. The Lean theorem `generalized_reedMuller_min_distance`.
2. Supporting lemmas with clean names around fiber restriction and factorization.
3. If feasible, an existence theorem for extremizers.
4. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - rigidity/classification of all minimum-weight codewords up to affine equivalence,
   - projective Reed–Muller analogs,
   - Gröbner-footprint formalization for finite grids,
   - exact soundness theorems for low-degree tests,
   - higher-order Reed–Muller support profiles and generalized Hamming weights.

This is the right problem because it looks classical but actually forces the formal synthesis of finite geometry, polynomial method, and extremal coding theory. If you do it with the geometric tensor-product viewpoint visible, you are not just filling a gap — you are creating a new formal bridge between coding theory and finite algebraic geometry.

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

Research domain: Bridges
Research mode: prove
