## Assignment: Riemann Zeta: Zero-Free Regions, Zero Density, and Prime Error Transference

**Mode: prove + formalize + discover**

This project should not merely restate classical analytic number theory in Lean. The real target is to build a **formal transfer principle**: a certified machine-checked pipeline from a zero-free region for a zeta-like object to explicit asymptotic control on zero counts and then to explicit prime-counting error bounds. If achieved cleanly, this becomes a prototype for formal analytic Langlands-style infrastructure: “spectral nonvanishing ⇒ arithmetic regularity.”

You should aim to prove **at least 3 substantial theorems** with genuinely multi-step proofs, and define at least one **new formal structure** that packages the analytic hypotheses needed for zero-free-region arguments.

---

## Core Vision

The breakthrough is not “formalize one theorem about ζ.” The breakthrough is:

> **Build a reusable Lean 4 framework for zero-free regions and arithmetic consequences, abstract enough to apply later to Dirichlet L-functions, Selberg zeta, or dynamical zeta functions.**

The classical statement
\[
\zeta(s)\neq 0 \quad \text{for} \quad \Re(s) > 1 - \frac{c}{\log(|\Im(s)|+2)}
\]
is only the first layer. The deeper objective is to certify a chain of implications:

1. **Geometric exclusion of zeros near the 1-line**
2. **Quantitative control on zero counting**
3. **Transfer to explicit prime counting error bounds**
4. **Abstract reformulation for future L-function generalization**

This is field-opening because once this pipeline is formalized, the next cycles can attack:
- explicit PNT in arithmetic progressions,
- Deuring–Heilbronn phenomena,
- zero repulsion,
- certified zero-density bounds,
- formalized spectral/arithmetic correspondences.

---

## New Formal Structure to Introduce

Define a new structure capturing the hypotheses of a zeta-like meromorphic function with a logarithmic zero-free region.

Suggested concept:

```lean
structure LogZeroFreeDatum where
  F : ℂ → ℂ
  zeroCount : ℝ → ℕ
  c : ℝ
  T0 : ℝ
  c_pos : 0 < c
  T0_nonneg : 0 ≤ T0
  zero_free :
    ∀ s : ℂ, T0 ≤ Complex.abs s.im →
      1 - c / Real.log (Complex.abs s.im + 2) < s.re →
      F s ≠ 0
```

This is deliberately abstract. You may later enrich it with:
- symmetry conditions,
- meromorphic continuation,
- growth bounds,
- argument-principle compatibility,
- explicit formula hypotheses.

A second useful definition is an explicit “prime error profile”:

```lean
def PrimeErrorProfile (E : ℝ → ℝ) : Prop :=
  ∀ x : ℝ, 2 ≤ x → |E x| ≤ x * Real.exp (-Real.sqrt (Real.log x) / 10)
```

Even if the final constants are placeholders or parameterized, formalizing the **shape** of the bound is mathematically meaningful.

---

## Precise Theorem Targets

You should formalize a hierarchy: unconditional abstract transfer theorems first, then zeta-specialized corollaries.

### Theorem 1: Monotonicity of the logarithmic zero-free barrier
This is elementary but not trivial if done properly, and it is foundational for all later region arguments.

Mathematical statement:
\[
0 < c,\quad y_1 \le y_2 \implies
1 - \frac{c}{\log(y_1+2)} \le 1 - \frac{c}{\log(y_2+2)}
\]
for \(y_i \ge 0\).

Lean 4 target:
```lean
theorem log_barrier_mono
    {c y₁ y₂ : ℝ}
    (hc : 0 < c)
    (hy₁ : 0 ≤ y₁)
    (h12 : y₁ ≤ y₂) :
    1 - c / Real.log (y₁ + 2) ≤ 1 - c / Real.log (y₂ + 2) := by
```

Why it matters: this is the certified geometric fact that the zero-free boundary moves rightward in a controlled way as height increases. It underlies every strip/region inclusion argument.

Proof ingredients:
- prove `0 < Real.log (y + 2)` from `y ≥ 0`,
- monotonicity of `Real.log`,
- positivity-preserving reciprocal order reversal,
- multi-step `calc`.

This theorem should **not** be discharged by automation alone; use `field_simp`, positivity lemmas, and a careful order argument.

---

### Theorem 2: Region inheritance from a stronger zero-free region
Abstract comparison theorem.

Mathematical statement:
If \(F\) is zero-free in a region \(\Re(s) > 1 - c/\log(|\Im s|+2)\), then it is zero-free in every strictly smaller region \(\Re(s) > 1 - c'/\log(|\Im s|+2)\) with \(0 < c' \le c\).

Lean 4 target:
```lean
theorem zero_free_of_smaller_constant
    (D : LogZeroFreeDatum)
    {c' : ℝ}
    (hc' : 0 < c')
    (hcc' : c' ≤ D.c) :
    ∀ s : ℂ, D.T0 ≤ Complex.abs s.im →
      1 - c' / Real.log (Complex.abs s.im + 2) < s.re →
      D.F s ≠ 0 := by
```

Why it matters: this gives a reusable formal principle for “downgrading constants” and stabilizes the analytic framework. It is the sort of theorem mathematicians use implicitly all the time; making it explicit in Lean is high-value infrastructure.

Proof idea:
- compare barriers using `hcc'`,
- show
  \[
  1 - \frac{c}{\log(\cdot)} \le 1 - \frac{c'}{\log(\cdot)}
  \]
  since denominator is positive,
- use transitivity to feed the stronger hypothesis into `D.zero_free`.

This should require `have`, `nlinarith` or `linarith` only after establishing positivity of logs.

---

### Theorem 3: Vertical strip corollary of a logarithmic zero-free region
If \(|\Im s| \le T\), then the logarithmic zero-free region implies a fixed vertical strip free of zeros.

Mathematical statement:
For \(T \ge T_0\), if
\[
\Re(s) > 1 - \frac{c}{\log(T+2)}
\quad \text{and} \quad |\Im s| \le T,
\]
then \(F(s)\neq 0\).

Lean 4 target:
```lean
theorem zero_free_vertical_strip
    (D : LogZeroFreeDatum)
    {T : ℝ}
    (hT0 : D.T0 ≤ T)
    (hT : 0 ≤ T) :
    ∀ s : ℂ, Complex.abs s.im ≤ T →
      1 - D.c / Real.log (T + 2) < s.re →
      D.F s ≠ 0 := by
```

Why it matters: this is the bridge from a curved region to a practical rectangular exclusion zone, exactly the kind of conversion needed in zero-counting and explicit formula estimates.

Proof architecture:
- from `|Im s| ≤ T`, deduce barrier comparison by Theorem 1,
- show
  \[
  1 - \frac{D.c}{\log(|\Im s|+2)}
  \le
  1 - \frac{D.c}{\log(T+2)}
  \]
- conclude the point lies in the original zero-free region.

This theorem should use `rcases` on hypotheses, a multi-step `calc`, and explicit barrier monotonicity.

---

### Theorem 4: Abstract zero-count stabilization in the zero-free strip
Introduce an abstract zero-count function and prove that if all zeros are excluded from a region above some boundary, then the count in that region is zero.

Suggested formal packaging:
```lean
def NoZerosUpToHeight (F : ℂ → ℂ) (σ T : ℝ) : Prop :=
  ∀ s : ℂ, σ < s.re → Complex.abs s.im ≤ T → F s ≠ 0
```

Then prove:

```lean
theorem noZerosUpToHeight_of_logZeroFree
    (D : LogZeroFreeDatum)
    {T : ℝ}
    (hT0 : D.T0 ≤ T)
    (hT : 0 ≤ T) :
    NoZerosUpToHeight D.F (1 - D.c / Real.log (T + 2)) T := by
```

Why it matters: this is the exact formulation one needs before discussing `N(σ,T)`-style density estimates. Even if the full Riemann–von Mangoldt asymptotic is out of immediate reach in Mathlib, this theorem creates the **formal interface** for it.

---

### Theorem 5: Prime error transference skeleton
You likely cannot fully formalize the full prime number theorem with classical constants unless the analytic infrastructure is already present. So build the correct abstract theorem now.

Introduce an explicit-formula-style hypothesis:

```lean
structure PrimeCountingTransferDatum where
  zeroCount : ℝ → ℕ
  psiError : ℝ → ℝ
  A B : ℝ
  A_pos : 0 < A
  B_pos : 0 < B
  transfer :
    ∀ x : ℝ, 2 ≤ x →
      |psiError x| ≤ A * x * Real.exp (-B * Real.sqrt (Real.log x))
```

Then prove easy but nontrivial consequences such as eventual sublinearity:

```lean
theorem psiError_sublinear
    (D : PrimeCountingTransferDatum) :
    ∀ᶠ x : atTop, |D.psiError x| / x ≤ 1 := by
```

or in epsilon form:

```lean
theorem psiError_small_o_identity
    (D : PrimeCountingTransferDatum) :
    Tendsto (fun x : ℝ => |D.psiError x| / x) atTop (𝓝 0) := by
```

Why it matters: this is the formal arithmetic endpoint. It turns spectral input into asymptotic regularity of primes. Even if the strongest transfer theorem is assumed abstractly in this cycle, proving rigorous consequences of that transfer is already scientifically valuable.

This theorem also creates the exact interface needed for later replacement of the abstract `transfer` axiom by a fully formal explicit formula.

---

## Ambitious Zeta-Specialized Target

If Mathlib has enough of `Complex`, `Real.log`, asymptotics, and contour-integration support in your environment, attempt a zeta-specialized wrapper:

```lean
def RiemannZetaZeroFreeRegion (c T0 : ℝ) : Prop :=
  0 < c ∧ 0 ≤ T0 ∧
  ∀ s : ℂ, T0 ≤ Complex.abs s.im →
    1 - c / Real.log (Complex.abs s.im + 2) < s.re →
    riemannZeta s ≠ 0
```

Then prove corollaries of the abstract theorems instantiated to `riemannZeta`, even if the actual zero-free-region hypothesis is assumed as a parameter. This is still a meaningful formal advance: it isolates the analytic heart of the PNT pipeline.

---

## On the Riemann–von Mangoldt Formula

The full asymptotic
\[
N(T)\sim \frac{T}{2\pi}\log\!\left(\frac{T}{2\pi e}\right)
\]
is extraordinarily deep and likely exceeds current library support if attacked head-on. So do **not** bluff. Instead, formalize one of these two visionary alternatives:

### Option A: Abstract asymptotic packaging
Define what it means for a zero-counting function to satisfy Riemann–von Mangoldt asymptotics:

```lean
def IsRiemannVonMangoldtAsymptotic (N : ℝ → ℝ) : Prop :=
  Tendsto (fun T => N T /
    ((T / (2 * Real.pi)) * Real.log (T / (2 * Real.pi * Real.exp 1))))
    atTop (𝓝 1)
```

Then prove robust consequences:
- eventual positivity,
- comparison bounds,
- growth to infinity,
- `N(T) = O(T log T)`.

For example:
```lean
theorem rvM_bigO
    {N : ℝ → ℝ}
    (hN : IsRiemannVonMangoldtAsymptotic N) :
    Asymptotics.IsBigO atTop N (fun T => T * Real.log T) := by
```

This is a serious asymptotic theorem and belongs in the architecture.

### Option B: Density-from-asymptotic transfer
Assume an `IsRiemannVonMangoldtAsymptotic N` hypothesis and prove coarse density bounds on intervals `[T, T+1]`, or deduce eventual monotone positivity of the main term. This is analytically meaningful and library-friendly.

---

## Proof Strategy Architecture

### Strategy A: Abstract-first, zeta-later
Most promising.

1. Define `LogZeroFreeDatum`, `NoZerosUpToHeight`, and asymptotic/error structures.
2. Prove comparison and inheritance theorems purely with real/complex inequalities.
3. Add zeta-specialized corollaries by assuming the classical zero-free region as a hypothesis.

**Why this is best:** it avoids getting trapped by missing contour-integration infrastructure while still producing reusable formal analytic number theory machinery.

---

### Strategy B: Asymptotic transfer via filters
1. Encode Riemann–von Mangoldt asymptotics using `Tendsto`.
2. Prove growth and domination lemmas using filter calculus and `IsBigO`.
3. Connect these to zero-density-style statements and prime error abstractions.

**Why this is powerful:** it gives a modern asymptotic API in Lean and makes later explicit-formula formalization much easier.

---

### Strategy C: Region geometry + contradiction arguments
1. Formalize the barrier function
   \[
   b_c(y)=1-\frac{c}{\log(y+2)}.
   \]
2. Prove monotonicity, positivity, and comparison lemmas.
3. Use `by_contra` to derive contradictions if a zero existed in the induced strip.

**Why this matters:** it ensures your proofs are not merely algebraic manipulations; they mirror the actual logical geometry of zero-free region arguments.

---

## Cross-Domain Connections You Must Include

At least one theorem should explicitly connect this analytic number theory project to another domain.

### Connection 1: Information geometry / entropy barrier
The function \( \log(|t|+2) \) is an information-scale complexity penalty. Package the zero-free boundary as a “complexity barrier” and prove monotonicity facts analogous to entropy-regularized feasible regions.

Possible formal theorem:
```lean
theorem log_barrier_tends_to_one :
    Tendsto (fun y : ℝ => 1 - c / Real.log (y + 2)) atTop (𝓝 1) := by
```
for `c > 0`.

Interpretation: the admissible nonvanishing region approaches the critical line as frequency grows. This is conceptually parallel to high-frequency stability barriers in PDE and statistical mechanics.

### Connection 2: Spectral viewpoint
Zero-counting functions are spectral counting functions. Frame `N(T)` as analogous to Weyl laws in mathematical physics. A theorem about eventual growth of `N(T)` from an asymptotic hypothesis is a direct bridge to spectral geometry.

### Connection 3: Complexity-theoretic analogy
Use the catalog theorem `zero_poly_implies_zero_function` as a conceptual analogy: global vanishing constraints in algebraic circuits mirror the arithmetic rigidity encoded by zero-free regions. Do not force a fake theorem from this unless mathematically honest, but mention it in `RESEARCH_PAPER.md` and `FUTURE_DIRECTIONS.md` as a possible bridge toward “analytic complexity barriers.”

**Application keywords:** analytic number theory, zero-free region, zero density, prime number theorem, explicit formula, asymptotic analysis, spectral counting, mathematical physics, complexity barriers, formal verification.

---

## Recommended Supporting Lemmas

You will likely need these intermediate results:

```lean
theorem log_pos_of_nonneg_add_two {y : ℝ} (hy : 0 ≤ y) :
    0 < Real.log (y + 2) := by
```

```lean
theorem barrier_lt_one {c y : ℝ} (hc : 0 < c) (hy : 0 ≤ y) :
    1 - c / Real.log (y + 2) < 1 := by
```

```lean
theorem barrier_tendsto_one {c : ℝ} (hc : 0 < c) :
    Tendsto (fun y : ℝ => 1 - c / Real.log (y + 2)) atTop (𝓝 1) := by
```

```lean
theorem exp_neg_sqrt_log_decay
    {B : ℝ} (hB : 0 < B) :
    Tendsto (fun x : ℝ => Real.exp (-B * Real.sqrt (Real.log x))) atTop (𝓝 0) := by
```

These are not filler; they are the analytic atoms from which the whole transfer theory is assembled.

---

## Concrete Deliverables

You must produce **ALL** of the following:

1. **Lean file(s)** with at least:
   - one new structure (`LogZeroFreeDatum` or stronger),
   - at least 3 substantial theorems,
   - deep proof tactics (`induction`, `rcases`, `by_contra`, `field_simp`, `calc`) used nontrivially,
   - minimal `sorry`.

2. **FUTURE_DIRECTIONS.md** with **3–5 falsifiable scientific hypotheses**, each with a clear computational disproof test. Examples of acceptable hypothesis style:
   - “For a family of certified zero-free barriers \(b_a(T)\), the best explicit prime error constant scales linearly in \(a\) for \(a\in[0.1,2]\). Test: numerically fit certified bounds on sampled \(x\)-ranges; reject if residual exceeds threshold.”
   - “A formalized abstract zero-free-region API extends to Dirichlet L-functions with fewer than 20% additional lemmas over the ζ-case. Test: count new declarations needed in a prototype implementation.”
   - “The barrier monotonicity lemmas suffice to certify a nontrivial zero-exclusion rectangle for all heights \(T \le 10^6\) under an assumed classical constant \(c\). Test: run demo and search for contradiction instances.”

3. **RESEARCH_PAPER.md** as a standalone scientific paper:
   - problem statement,
   - exact formal theorem statements,
   - proof architecture,
   - significance for analytic number theory and formal methods,
   - limitations,
   - next-step conjectures.

4. **ARTICLE.md** in Scientific American style:
   - what the zeta zeros are,
   - why a zero-free region matters for primes,
   - what it means to certify such reasoning in Lean,
   - why this is a prototype for machine-verified analytic number theory.

5. **A verified algorithm or computational method**
   - e.g. an algorithm computing the barrier \(1-c/\log(T+2)\),
   - certifying strip exclusion from a given zero-free datum,
   - numerically testing candidate constants against sample points while keeping theorems separate from experiments.

6. **demo.py**
   - interactive plot of the logarithmic barrier,
   - user-adjustable `c`, `T0`,
   - display of induced vertical zero-free strips,
   - optional visualization of the main term \(T/(2\pi)\log(T/(2\pi e))\),
   - numerical experiments illustrating the conjectures in `FUTURE_DIRECTIONS.md`.

---

## Standard of Ambition

Do not settle for “ζ has no zeros if we assume ζ has no zeros.” The valuable output is a **formal analytic framework** that turns a deep hypothesis into multiple certified consequences. If you can prove even one clean transfer theorem from logarithmic zero-free geometry to asymptotic or prime-error control, you will have created infrastructure that can scale to whole families of L-functions.

The real scientific contribution here is a new formal language for spectral exclusion and arithmetic regularity. That is the opening.

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

Research domain: Algebra
Research mode: prove
