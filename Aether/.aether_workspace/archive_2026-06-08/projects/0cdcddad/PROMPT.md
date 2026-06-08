## Assignment: Direction 2: Higher-Order Log-Concavity and Partition Functions

**Mode:** prove

Prove genuinely new theorems at the interface of Lorentzian polynomials, discrete convexity, and statistical-mechanical partition functions. The target is not a cosmetic extension of ordinary log-concavity, but a formal hierarchy of “depth of concavity” that predicts algorithmic mixing rates and reveals a new structural invariant of generating functions.

Build explicitly on:

- `Pythagorean/CertificateSampling.lean`
  - `LogConcaveSeq`
  - `binomial_log_concave`
  - any multiplicative closure lemmas such as `logConcaveSeq_mul`
- `Catalog/FINAL/Bridges/LorentzianRecognition.lean`
  - `IsRecursivelyLorentzian`

Your goal is to turn recursive Lorentzian structure into a certified higher-order discrete concavity theory with consequences for sampling and partition functions.

---

## Core Vision

The breakthrough target is a **hierarchy theorem**:

> recursive Lorentzian depth of a generating polynomial forces a corresponding depth of discrete log-concavity on its coefficient profile, and this depth governs concentration and sampling behavior.

If formalized cleanly, this opens a new field: **algorithmic Lorentzian complexity**, where one measures not merely whether a polynomial is Lorentzian, but how many recursive layers of Lorentzianity survive under differentiation, and then converts that depth into quantitative analytic consequences.

This would connect:

- **combinatorics**: matroid basis counts, spanning tree enumerators
- **statistical physics**: Ising and related partition functions
- **information theory**: entropy curvature and higher-order data-processing heuristics
- **Markov chain theory**: modified log-Sobolev and spectral decay
- **operator theory**: complete positivity heuristics for coefficient transforms

Application keywords: `Lorentzian polynomials`, `higher-order log-concavity`, `partition functions`, `Ising model`, `matroids`, `spanning trees`, `mixing times`, `modified log-Sobolev inequalities`, `entropy decay`, `negative dependence`, `ultra log-concavity`, `spectral independence`, `discrete convexity`.

---

## Precise Formalization Targets

You must introduce at least one genuinely new definition absent from the current catalog. The most natural candidate is an inductive notion of higher-order log-concavity for sequences.

### New definitions

Define a positive sequence model and a higher-order log-concavity predicate. One workable Lean-facing design is:

```lean
def PositiveSeq (a : ℕ → ℝ) : Prop :=
  ∀ n, 0 < a n

def RatioSeq (a : ℕ → ℝ) : ℕ → ℝ :=
  fun n => a (n+1) / a n

def KFoldLogConcave : ℕ → (ℕ → ℝ) → Prop
  | 0, a => PositiveSeq a
  | k+1, a => PositiveSeq a ∧ LogConcaveSeq (RatioSeq a) ∧ KFoldLogConcave k (RatioSeq a)
```

If `LogConcaveSeq` in the catalog uses a finite-support/list model rather than `ℕ → ℝ`, adapt accordingly, but preserve the mathematical content. If positivity assumptions are too strong globally, define a finitely supported version on an interval `[0, d]`.

A second useful new definition is a coefficient extractor for univariate specializations of recursively Lorentzian multivariate polynomials:

```lean
def CoeffSeqOfSpecialization
  (P : MvPolynomial (Fin n) ℝ) : ℕ → ℝ := ...
```

or, if multivariate coefficient extraction is too heavy, define an abstract structure capturing the coefficient sequence together with a recursive Lorentzian certificate:

```lean
structure RecursiveLorentzianSequence where
  coeff : ℕ → ℝ
  depth : ℕ
  pos : PositiveSeq coeff
  cert : Prop -- tied to IsRecursivelyLorentzian of some witness polynomial
```

The point is to make recursive Lorentzian depth into a reusable certified object.

---

## Exact theorem targets

You should prove at least 3 substantial theorems. The following are the recommended targets.

### Theorem 1: Higher-order log-concavity descends recursively

Mathematical statement:

> For every positive sequence `a`, if `a` is `(k+1)`-fold log-concave, then its ratio sequence is `k`-fold log-concave.

This sounds definitional, but do **not** make it tautological. Define `KFoldLogConcave` so that this theorem requires real proof steps—e.g. because the positivity and local support conditions must be propagated, or because the recursive clause is phrased via finite differences of `log`.

Suggested Lean signature:

```lean
theorem KFoldLogConcave.ratio
    {k : ℕ} {a : ℕ → ℝ}
    (hk : KFoldLogConcave (k+1) a) :
    KFoldLogConcave k (RatioSeq a)
```

Why it matters:
This theorem makes “depth” an actual filtration. Without it, the whole hierarchy is a slogan. With it, recursive Lorentzian depth becomes a monotone invariant.

---

### Theorem 2: Higher-order log-concavity implies ordinary log-concavity at every lower level

Mathematical statement:

> If `a` is `k`-fold log-concave with `k ≥ 1`, then `a` is log-concave; more generally, every iterated ratio sequence up to depth `k-1` is log-concave.

Suggested Lean signature:

```lean
def IterRatio : ℕ → (ℕ → ℝ) → (ℕ → ℝ)
  | 0, a => a
  | m+1, a => RatioSeq (IterRatio m a)

theorem KFoldLogConcave.iterRatio_logConcave
    {k m : ℕ} {a : ℕ → ℝ}
    (hk : KFoldLogConcave k a)
    (hm : m < k) :
    LogConcaveSeq (IterRatio m a)
```

This should require induction on `m` or `k`, plus careful extraction from the recursive hypothesis.

Why it matters:
This theorem shows that higher-order log-concavity is not just stronger than ordinary log-concavity, but a full tower of compatible concavity constraints. It is the discrete analogue of higher-order curvature negativity.

---

### Theorem 3: Binomial coefficients are k-fold log-concave up to the natural depth bound

This is the first nontrivial model family and should build directly on `binomial_log_concave`.

Mathematical statement:

> For each fixed `N`, the finite sequence `m ↦ Nat.choose N m` is `k`-fold log-concave for every `k ≤ N-1` on its natural support.

Suggested Lean signature, in a finite-support encoding:

```lean
def SupportedChooseSeq (N : ℕ) : ℕ → ℝ :=
  fun m => if h : m ≤ N then (Nat.choose N m : ℝ) else 0

theorem choose_kFoldLogConcave
    (N k : ℕ) (hk : k ≤ N - 1) :
    KFoldLogConcave k (SupportedChooseSeq N)
```

You may need a support-restricted version:

```lean
def KFoldLogConcaveOn (k : ℕ) (a : ℕ → ℝ) (N : ℕ) : Prop := ...
```

This theorem should not be a one-line corollary. It should use:
- explicit ratio formula for binomial coefficients,
- induction on `k`,
- algebraic simplification of rational expressions,
- existing `binomial_log_concave`.

Why it matters:
Binomial coefficients are the Gaussian of discrete combinatorics. If the hierarchy does not illuminate them, it is not the right hierarchy.

---

### Theorem 4: Product stability for higher-order log-concavity

This is the structural theorem that turns the hierarchy into a calculus.

Mathematical statement:

> If `a` and `b` are positive `k`-fold log-concave sequences, then under suitable monotonicity/support hypotheses their pointwise product is `k`-fold log-concave.

Suggested Lean signature:

```lean
theorem KFoldLogConcave.mul
    {k : ℕ} {a b : ℕ → ℝ}
    (ha : KFoldLogConcave k a)
    (hb : KFoldLogConcave k b)
    (hpos : PositiveSeq fun n => a n * b n) :
    KFoldLogConcave k (fun n => a n * b n)
```

Build on `logConcaveSeq_mul` at the base case and then lift recursively through ratio identities:
`RatioSeq (a*b) = RatioSeq a * RatioSeq b`.

Why it matters:
Partition functions factor over weakly interacting subsystems. This theorem is the gateway from pure combinatorics to statistical physics.

---

### Theorem 5: Recursive Lorentzian certificates induce coefficient log-concavity

This is the flagship bridge theorem. You may need to formulate it in a restricted but provable form.

Mathematical statement:

> Let `P` be a homogeneous polynomial with nonnegative coefficients and recursive Lorentzian depth at least `k`. Then the coefficient sequence of a one-parameter specialization of `P` is `k`-fold log-concave.

A practical specialization is:
- bivariate homogeneous `P(X,Y) = ∑ a_m X^m Y^(d-m)`, so the coefficient sequence is directly accessible.

Suggested Lean signature:

```lean
theorem recursivelyLorentzian_bivariate_coeff_kFoldLogConcave
    {d k : ℕ} {P : MvPolynomial (Fin 2) ℝ}
    (hLor : IsRecursivelyLorentzian P)
    (hdeg : P.Homogeneous d)
    (hdepth : k ≤ d - 2)
    (hnonneg : ∀ m, 0 ≤ coeffOfBivariateHomogeneous P d m) :
    KFoldLogConcaveOn k (coeffOfBivariateHomogeneous P d) d
```

If full proof from existing catalog infrastructure is too ambitious, prove a weaker certified bridge theorem:

> if a coefficient sequence is extracted from an object carrying a recursive Lorentzian certificate of depth `k`, then its first ratio sequence inherits a Lorentzian-compatible inequality, hence the coefficient sequence is log-concave / 2-fold log-concave.

Why it matters:
This is the theorem that turns the abstract Lorentzian-recognition catalog result into new mathematics. It is the bridge from algebraic geometry to discrete probability.

---

## Lean 4 implementation guidance

Use support-restricted formulations if global `ℕ → ℝ` positivity is awkward. A robust pattern is:

```lean
def PositiveOn (a : ℕ → ℝ) (N : ℕ) : Prop :=
  ∀ n ≤ N, 0 < a n

def LogConcaveOn (a : ℕ → ℝ) (N : ℕ) : Prop :=
  ∀ n, 1 ≤ n → n < N -> a n ^ 2 ≥ a (n-1) * a (n+1)

def RatioSeqOn (a : ℕ → ℝ) : ℕ → ℝ :=
  fun n => a (n+1) / a n

def KFoldLogConcaveOn : ℕ → (ℕ → ℝ) → ℕ → Prop
  | 0, a, N => PositiveOn a N
  | k+1, a, N =>
      PositiveOn a (N+1) ∧
      LogConcaveOn a N ∧
      KFoldLogConcaveOn k (RatioSeqOn a) N
```

This avoids undefined ratios and makes induction on support length natural.

---

## Proof strategy architecture

You must include 2–3 proof routes in your working notes and pursue the strongest one.

### Strategy A: Inductive ratio calculus
Most promising for formalization.

1. Define `KFoldLogConcave` recursively through ratio sequences or finite differences.
2. Prove closure lemmas:
   - positivity of ratio sequences,
   - `RatioSeq (a*b) = RatioSeq a * RatioSeq b`,
   - iteration compatibility of `IterRatio`.
3. Lift known base-case results (`LogConcaveSeq`, `binomial_log_concave`, `logConcaveSeq_mul`) by induction on `k`.

Why this is promising:
It is Lean-friendly, modular, and directly reuses catalog results. It gives theorem statements that are strong enough to matter but not blocked by heavy multivariate algebra.

### Strategy B: Finite-difference concavity of `log`
Conceptually elegant, analytically richer.

1. Define `Δ f n = f (n+1) - f n` and iterate finite differences.
2. For positive `a`, set `f n = Real.log (a n)`.
3. Show that `k`-fold log-concavity corresponds to `Δ^[2] (Δ^[k-1] f) ≤ 0` or an equivalent alternating-sign finite-difference inequality.

Why this is powerful:
It reveals the connection to entropy curvature and discrete convex analysis. It is the right language for information-theoretic applications.

Why it is less promising in Lean:
Managing `Real.log`, positivity, and iterated finite differences may create overhead unless you restrict to clean positive families like binomial coefficients.

### Strategy C: Lorentzian-to-coefficient bridge via specialization
Highest conceptual payoff, technically hardest.

1. Use `IsRecursivelyLorentzian` to control derivatives/specializations.
2. Reduce to bivariate homogeneous slices.
3. Extract coefficient inequalities from Lorentzian Hessian signatures or known coefficient consequences of Lorentzianity.

Why this is revolutionary:
It would turn geometric recursive certificates into a machine for proving discrete inequalities.

Why it may be difficult:
Depends on what exact consequences are already packaged in `LorentzianRecognition.lean`.

**Recommended order:** A first, then B for interpretation, then C as the flagship bridge if the catalog supports it.

---

## Cross-domain connection targets

You are required to include at least one theorem that genuinely bridges domains.

### Bridge 1: Statistical physics
Define a finite-volume coefficient sequence arising from a simplified partition function, for example a ferromagnetic Ising model on a small graph where coefficients count spin configurations by magnetization or edge disagreement number. Prove a structural theorem of the form:

> if the partition-function coefficient sequence factors into certified k-fold log-concave local terms, then the global coefficient sequence is k-fold log-concave.

This can be a mathematically clean toy model rather than the full Ising theorem.

Possible Lean-facing theorem:

```lean
theorem partitionFunctionCoeff_kFoldLogConcave_of_factorization
    {k : ℕ} {a b : ℕ → ℝ}
    (ha : KFoldLogConcave k a)
    (hb : KFoldLogConcave k b) :
    KFoldLogConcave k (fun n => a n * b n)
```

Interpretation:
independent subsystems preserve higher-order concavity.

### Bridge 2: Information theory
Prove a discrete entropy-curvature inequality for positive k-fold log-concave sequences. Even a weak theorem is valuable, such as monotonicity of adjacent log-ratios implying one-step entropy contraction for normalized finite truncations.

### Bridge 3: Operator theory
Interpret the ratio transform as a positivity-preserving nonlinear operator and prove monotonicity/closure under composition on a suitable class. This opens the door to complete positivity analogies.

---

## Conjecture with computationally falsifiable prediction

State and formalize a conjecture strong enough to matter and precise enough to test.

### Main conjecture
For every homogeneous polynomial `P` with recursive Lorentzian depth at least `k`, every nonnegative bivariate specialization coefficient sequence is `k`-fold log-concave.

Suggested prose:

> **Conjecture (Recursive Lorentzian depth controls discrete curvature).**
> Let `P` be a homogeneous polynomial of degree `d` with nonnegative coefficients. If `P` is recursively Lorentzian to depth `k`, then for every positive bivariate specialization `P_t(x,y)`, the coefficient sequence `(a_m)_{m=0}^d` of `P_t(x,y) = ∑ a_m x^m y^{d-m}` is `k`-fold log-concave on `0,…,d`.

### Testable prediction
For each family below, compute iterated ratio sequences and check log-concavity depth:

1. complete bipartite graph spanning tree enumerators,
2. paving matroid basis generating polynomials,
3. Ising partition functions on `2×2`, `2×3`, `3×3` lattices.

A single explicit counterexample with positive coefficients and recursive Lorentzian certificate but failed `k`-fold log-concavity disproves the conjecture.

You should also test the algorithmic prediction:

> observed mixing proxy scales like `n^(2/k)` rather than `n^2`.

Even if the full mixing theorem is not formalized, the demo should numerically compare empirical decay rates across `k`.

---

## Minimum theorem package

Your file must contain at least 3 substantial theorems, and they must use deep proof structure. Recommended package:

1. `KFoldLogConcave.ratio`
2. `KFoldLogConcave.iterRatio_logConcave`
3. `choose_kFoldLogConcave`
4. `KFoldLogConcave.mul`
5. one bridge theorem from partition functions or recursive Lorentzian specialization

At least three of these should visibly use:
- induction
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`

In particular, `choose_kFoldLogConcave` should use explicit ratio algebra and `field_simp`, not brute-force evaluation.

---

## Demo / computational method requirement

You must provide a **verified algorithm or computational method**, not only theorem statements.

### Required algorithmic component
Implement a function that, given a finite positive sequence, computes the maximal observed depth of higher-order log-concavity by iterating ratio sequences and checking log-concavity on each level.

Possible Python-side API:

```python
def kfold_depth(seq: list[float]) -> int: ...
```

and optionally

```python
def test_partition_family(family_name: str, size: int) -> dict: ...
```

The Lean side should formalize correctness of the core checker on exact rational data where feasible, or at minimum formalize the mathematical predicate being checked and prove correctness of one reduction step.

### demo.py must
- generate binomial sequences and verify predicted depth,
- test small graph / matroid / Ising-inspired examples,
- print the first failing depth or certify all tested depths,
- optionally plot empirical “mixing proxy vs depth.”

---

## Deliverables you must produce

You must produce **all** of the following:

1. `FUTURE_DIRECTIONS.md`
   - 3–5 original research directions
   - each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - at least one direction must bridge to a different domain

2. `RESEARCH_PAPER.md`
   - standalone scientific document
   - must explain the definitions, main theorems, examples, significance, and next questions
   - readable without access to code

3. `ARTICLE.md`
   - Scientific American style
   - broad audience
   - focus on the mathematical ideas and why they matter
   - taboo: do **not** focus on formal verification machinery

4. a verified algorithm or computational method

5. `demo.py`
   - interactive or semi-interactive demonstration of the result

---

## Why this would be revolutionary

Ordinary log-concavity has become a unifying principle across combinatorics, geometry, and probability. But it is still fundamentally a **binary** notion: a sequence either has the inequality or it does not. Recursive Lorentzian geometry suggests a richer possibility: concavity has **depth**. If you can formalize and prove that depth propagates to coefficient sequences and then influences sampling behavior, you create a new language for complexity in discrete structures.

This would not be “another log-concavity theorem.” It would be the beginning of a hierarchy:

- depth 1: negative dependence / ordinary concentration
- depth 2: sharpened entropy curvature
- depth k: accelerated equilibration and new sampler design

That is a field-opening perspective. It reframes partition functions as objects with a measurable curvature depth, and it suggests new invariants for combinatorial counting, statistical mechanics, and information flow.

Soli Deo Gloria

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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
