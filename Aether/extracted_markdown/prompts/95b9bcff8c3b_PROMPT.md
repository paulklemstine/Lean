## Assignment: Direction 2: PF₂ Closure Under Polynomial Convolution

Prove a genuinely new formal theorem cluster around **closure of PF₂ / ratio-decreasing sequences under finite convolution**, pushing beyond the catalog’s linear-factor closure result.

This is not just an extension exercise. If you can formalize a constructive convolution theorem for PF₂ sequences, you will turn a classical “folklore” stability principle into a reusable certified engine for algebraic combinatorics, probability, and discrete total positivity. The breakthrough is that convolution is the native multiplication law of generating functions, the addition law of independent random variables, and the composition law of transfer kernels. Closing PF₂ under this operation gives a mathematically rich, computationally testable stability calculus.

Build explicitly on:

- `Pythagorean/PF2Theorems.lean`
  - `IsRatioDecreasing`
  - `ratioDecreasing_mul_linear`

Your goal is to go decisively beyond multiplication by a 2-term kernel.

---

## Core theorem target

### Precise mathematical theorem

Let `a b : ℕ → ℝ` be finitely supported, pointwise nonnegative sequences. Define the finite convolution
\[
(a ⋆ b)(n) := \sum_{k=0}^n a(k)b(n-k).
\]
Assume both `a` and `b` are ratio-decreasing in the PF₂ sense, i.e.
\[
a_{n+1}a_m \le a_n a_{m+1} \quad \text{for all } m \le n,
\]
and similarly for `b`.

Then prove:
\[
\forall m \le n,\quad (a⋆b)_{n+1}(a⋆b)_m \le (a⋆b)_n (a⋆b)_{m+1}.
\]
Equivalently: finite convolution preserves the PF₂ / ratio-decreasing property.

This is the theorem that turns the catalog’s one-step linear closure into a full multiplicative closure law.

---

## Lean 4 formalization target

You should introduce a finite-support convolution definition if one is not already present in the right usable form for sequences `ℕ → ℝ`.

A plausible target signature is:

```lean
def natConv (a b : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ k in Finset.range (n + 1), a k * b (n - k)
```

You may also want a support-bounded variant:

```lean
def HasFiniteSupportNat (a : ℕ → ℝ) : Prop :=
  ∃ N, ∀ n > N, a n = 0
```

If the catalog already contains a better support notion, use that instead.

### Main theorem target signature

```lean
theorem IsRatioDecreasing.natConv
    (a b : ℕ → ℝ)
    (ha_nonneg : ∀ n, 0 ≤ a n)
    (hb_nonneg : ∀ n, 0 ≤ b n)
    (ha_fin : HasFiniteSupportNat a)
    (hb_fin : HasFiniteSupportNat b)
    (ha_rd : IsRatioDecreasing a)
    (hb_rd : IsRatioDecreasing b) :
    IsRatioDecreasing (natConv a b)
```

If `IsRatioDecreasing` in the catalog is phrased differently, adapt the statement exactly to the existing API, but preserve this mathematical content.

---

## Minimum theorem package

You must prove at least 3 substantial theorems, with nontrivial proofs using induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc`.

### Theorem 1: Convolution closure of ratio-decreasing sequences
The central result above.

Suggested Lean target:

```lean
theorem IsRatioDecreasing.natConv
    ...
    : IsRatioDecreasing (natConv a b)
```

### Theorem 2: Iterated polynomial-product closure
Show that finite products of PF₂ sequences remain PF₂ under repeated convolution.

Mathematically:
If `s : Fin m → (ℕ → ℝ)` is a finite family of finitely supported nonnegative ratio-decreasing sequences, then their iterated convolution is ratio-decreasing.

Possible Lean target:

```lean
def listNatConv : List (ℕ → ℝ) → (ℕ → ℝ)
-- define recursively

theorem IsRatioDecreasing.listNatConv
    (L : List (ℕ → ℝ))
    (h_nonneg : ∀ a ∈ L, ∀ n, 0 ≤ a n)
    (h_fin : ∀ a ∈ L, HasFiniteSupportNat a)
    (h_rd : ∀ a ∈ L, IsRatioDecreasing a) :
    IsRatioDecreasing (listNatConv L)
```

This theorem upgrades a binary closure law into a reusable algebraic calculus.

### Theorem 3: Probability bridge — preservation of discrete log-concavity / monotone likelihood ratio under sums
Interpret normalized finitely supported nonnegative sequences as probability mass functions. Show that if two pmfs satisfy the PF₂ inequality, then the pmf of the sum of independent variables also satisfies it.

Mathematically:
If `X, Y` are independent `ℕ`-valued random variables with PF₂ mass functions, then `X+Y` has PF₂ mass function.

In Lean, you may avoid full measure-theoretic probability if too heavy, and instead formalize a pmf-style statement as a theorem about normalized sequences:

```lean
def IsPMF (a : ℕ → ℝ) : Prop :=
  (∀ n, 0 ≤ a n) ∧ HasFiniteSupportNat a ∧ (∑' n, a n = 1)
```

Then prove:

```lean
theorem IsPMF.ratioDecreasing_natConv
    (a b : ℕ → ℝ)
    (ha : IsPMF a)
    (hb : IsPMF b)
    (ha_rd : IsRatioDecreasing a)
    (hb_rd : IsRatioDecreasing b) :
    IsRatioDecreasing (natConv a b)
```

This is your required **cross-domain theorem**:
- algebra/combinatorics: convolution of coefficient sequences
- probability/statistical mechanics: sum of independent discrete laws, monotone likelihood ratio, variation-diminishing behavior

If feasible, strengthen it to say `natConv a b` is again a pmf.

---

## Novel definitions required

You must define at least one genuinely new concept not already present in the catalog.

Recommended options:

### Option A: Finite-support natural convolution kernel
```lean
def natConv (a b : ℕ → ℝ) : ℕ → ℝ := ...
```

### Option B: PF₂ kernel / Toeplitz-minor predicate
A concept that makes the proof more structural:

```lean
def IsPF2Kernel (K : ℕ → ℕ → ℝ) : Prop :=
  ∀ i₁ i₂ j₁ j₂, i₁ ≤ i₂ → j₁ ≤ j₂ →
    K i₁ j₁ * K i₂ j₂ ≥ K i₁ j₂ * K i₂ j₁
```

Then specialize Toeplitz kernels `K i j = a (j - i)` where meaningful.

This could unlock a matrix-based proof and future extensions to total positivity.

### Option C: Support-bounded sequence class
```lean
structure FinSuppSeq where
  toFun : ℕ → ℝ
  nonneg : ∀ n, 0 ≤ toFun n
  bounded_support : ∃ N, ∀ n > N, toFun n = 0
```

This may help package theorems and algorithms more cleanly.

The strongest conceptual choice is **Option B**, because it opens the door from PF₂ sequences to total positivity of kernels and Markov operators.

---

## Proof architecture: 3 serious strategy paths

You should not commit blindly to one route. Try multiple paths and choose the one that best aligns with the existing catalog API.

### Strategy A: Induction on support via repeated linear-factor convolution
Use `ratioDecreasing_mul_linear` as the atomic step.

Steps:
1. Show that if a finitely supported PF₂ sequence `b` admits a factorization into linear factors with nonnegative coefficients, then repeated application of `ratioDecreasing_mul_linear` yields closure under convolution with `b`.
2. Formalize a constructive factorization theorem for the generating polynomial of `b`, likely requiring a strong additional hypothesis such as real-rootedness with nonpositive roots.
3. Deduce the convolution theorem for that subclass, and then determine whether the full PF₂ class in your formal setting already implies such a factorization.

Why promising:
- It directly reuses catalog machinery.
- It yields a very elegant algebraic story.

Why risky:
- The equivalence “PF₂ + finite support ↔ real-rooted with nonpositive roots” is deep and may be too large to formalize in one cycle.
- Good as a partial theorem or a second route, but probably not the shortest path to the full result.

### Strategy B: Direct Toeplitz-minor proof by double summation rearrangement
This is likely the most promising route for the full theorem.

Steps:
1. Expand
   \[
   (a⋆b)_{n+1}(a⋆b)_m - (a⋆b)_n(a⋆b)_{m+1}
   \]
   as a quadruple sum.
2. Rearrange and group terms into manifestly nonnegative pieces using the PF₂ inequalities for `a` and `b`.
3. Use finite support to justify all summation manipulations and prove nonnegativity term-by-term or via pairwise symmetrization.

Why promising:
- Constructive, elementary, and independent of root-factorization theory.
- Closest in spirit to total positivity arguments.
- Most likely to produce a robust Lean proof with `Finset` algebra, `calc`, and order reasoning.

Key challenge:
- Finding the right combinatorial decomposition so the difference becomes a sum of products of known nonnegative quantities.

### Strategy C: Kernel composition / total positivity route
Lift sequences to Toeplitz kernels and prove that composition of PF₂ kernels is PF₂; convolution is then kernel composition applied to Toeplitz kernels.

Steps:
1. Define a Toeplitz kernel associated to `a`, e.g. `K_a(i,j) = a (j-i)` with suitable truncation convention.
2. Prove that `IsRatioDecreasing a` implies `K_a` is TP₂ / PF₂ as a kernel.
3. Prove composition of nonnegative TP₂ kernels is TP₂; specialize to Toeplitz kernels to conclude convolution closure.

Why revolutionary:
- This does not merely prove one theorem; it builds a formal bridge from sequence inequalities to total positivity of operators.
- It opens future work on Markov chains, variation-diminishing transforms, and stochastic monotonicity.

Why harder:
- Requires more new definitions.
- But if successful, it is the most field-opening approach.

**Recommendation:** Prioritize **Strategy B** for the main theorem, while structuring definitions so that **Strategy C** becomes natural future work. Use **Strategy A** only as a conditional theorem or sanity-check subclass result.

---

## Concrete intermediate lemmas to target

These are the kinds of lemmas that can make the main proof tractable.

1. **Finite support of convolution**
```lean
theorem HasFiniteSupportNat.natConv
    {a b : ℕ → ℝ} :
    HasFiniteSupportNat a → HasFiniteSupportNat b → HasFiniteSupportNat (natConv a b)
```

2. **Nonnegativity of convolution**
```lean
theorem natConv_nonneg
    (ha : ∀ n, 0 ≤ a n)
    (hb : ∀ n, 0 ≤ b n) :
    ∀ n, 0 ≤ natConv a b n
```

3. **Index-shift formula**
A lemma rewriting `natConv a b (n+1)` in a way compatible with induction or telescoping.

4. **Difference expansion lemma**
A structured formula for
```lean
natConv a b (n + 1) * natConv a b m - natConv a b n * natConv a b (m + 1)
```
as a finite sum over index pairs.

5. **Symmetrized nonnegativity lemma**
A grouped-term inequality reducing the main statement to PF₂ inequalities for `a` and `b`.

These are not filler. They are the actual scaffolding of the final theorem.

---

## Cross-domain connections you must surface in the code comments and paper

### 1. Algebra ↔ Probability
Convolution of coefficient sequences equals addition of independent discrete random variables. PF₂ corresponds to a strong form of discrete log-concavity / monotone likelihood ratio behavior. Closure means “shape constraints survive summation.”

### 2. Algebra ↔ Total positivity
Ratio-decreasing sequences are Toeplitz shadows of TP₂ matrices. Your theorem is a sequence-level manifestation of closure of total positivity under kernel composition.

### 3. Combinatorics ↔ Statistical physics
PF₂/log-concave coefficient profiles model unimodal energy distributions and partition statistics. Closure under convolution reflects stability under independent subsystem aggregation.

### 4. Control / signal processing ↔ PF₂
Convolution is the fundamental operation of linear filtering. A PF₂ closure theorem suggests a shape-preserving class of discrete filters, potentially useful in robust inference and inverse problems.

---

## Application keywords

Use these explicitly in your writing and theorem comments:

- PF₂
- Pólya frequency sequence
- ratio-decreasing
- discrete log-concavity
- convolution algebra
- Toeplitz minors
- total positivity
- TP₂ kernels
- monotone likelihood ratio
- independent sums
- variation-diminishing
- generating functions
- real-rootedness
- probabilistic stability
- shape-constrained inference

---

## Falsifiable conjecture with computational test

You must include at least one clear conjecture and a disproof protocol.

### Conjecture A: Strong PF₂ closure without finite support
If `a, b : ℕ → ℝ≥0` are summable, nonnegative, ratio-decreasing sequences, then their infinite convolution is ratio-decreasing.

Test:
1. Sample long-tailed summable sequences, e.g. truncated geometric mixtures.
2. Numerically approximate the infinite convolution up to cutoff `N`.
3. Check PF₂ inequalities for all `m ≤ n ≤ N`.
4. Increase `N` and search for violations near the tail.

A counterexample would be scientifically valuable; it would locate the true boundary of constructive closure.

### Conjecture B: Strictness propagation
If `a` and `b` are strictly ratio-decreasing on their positive supports and not degenerate point masses, then `a ⋆ b` is strictly ratio-decreasing on its positive support.

Test:
1. Generate random strictly PF₂ sequences.
2. Convolve.
3. Check strict inequalities away from zero-support boundary.
4. Search for equality cases and classify them.

This conjecture is sharper and likely very interesting.

---

## Deliverables you must produce

You must produce **all** of the following:

1. **Lean file(s)** with at least 3 substantial theorems as described above, minimizing `sorry`.
2. **A verified algorithm or computational method**:
   - an executable checker that tests whether a finitely supported sequence is ratio-decreasing;
   - a convolution routine;
   - an automated search procedure for counterexamples to the conjectures above.
3. **`demo.py`**:
   - generate random finitely supported nonnegative PF₂ sequences,
   - convolve them,
   - verify the PF₂ inequalities,
   - visualize coefficient ratios or Toeplitz minors,
   - report whether any counterexample was found.
4. **`FUTURE_DIRECTIONS.md`** with 3–5 falsifiable scientific hypotheses, each with:
   - precise statement,
   - why it might be true,
   - exact computational or formal test that could refute it.
5. **`RESEARCH_PAPER.md`** as a standalone scientific document:
   - define PF₂ / ratio-decreasing sequences,
   - state the main theorem,
   - explain the proof architecture,
   - explain significance in probability and total positivity,
   - state open problems.
6. **`ARTICLE.md`** in Scientific American style:
   - explain why convolution-stability of shape constraints matters,
   - discuss independent random sums, filters, and algebraic stability,
   - do **not** focus on formal verification machinery.

---

## Standards for the Lean development

- Avoid trivial theorem statements whose proof is just `rfl`, `native_decide`, `decide`, or `norm_num`.
- At least 3 theorem proofs must visibly use serious proof structure:
  - induction,
  - `rcases`,
  - `by_contra`,
  - `field_simp`,
  - multi-step `calc`,
  - nontrivial `Finset` rearrangements.
- Use comments to explain the mathematical meaning of each major lemma.
- Reuse catalog lemmas wherever possible, especially `ratioDecreasing_mul_linear`.
- If the full theorem resists completion, prove the strongest nontrivial closure theorem you can:
  - closure under convolution with a 3-term PF₂ sequence,
  - closure under iterated linear factors,
  - kernel-composition closure in a structured subclass.
  But do not settle for a toy result unless it is a genuine stepping stone to the full theorem.

---

## What would make this a breakthrough

A successful formalization here would not just certify a classical fact. It would create a **reusable PF₂ convolution calculus**:
- multiplying generating functions while preserving shape constraints,
- summing independent discrete laws while preserving monotone likelihood structure,
- setting up future formal work on total positivity, stable polynomials, and variation-diminishing operators.

This is how one opens a field: not by proving one isolated theorem, but by building the algebra that future theorems can inhabit.

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
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


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

Research domain: Pythagorean
Research mode: prove
