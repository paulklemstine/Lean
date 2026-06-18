Soli Deo Gloria

## Assignment: Direction 1: Full Gärtner–Ellis Large Deviation Principle for Generation Defect

**Mode:** `prove`

Prove a genuinely new asymptotic theorem at the interface of finite group theory, convex analysis, and probability: a **full large deviation principle for the generation defect on direct powers** of a fixed finite group. This is not an incremental extension. It is the passage from finite combinatorial pressure inequalities to a thermodynamic-limit theorem with a convex-analytic rate function. If completed cleanly, it creates a new field: **large deviations in probabilistic generation theory**.

You must build on the catalog architecture already present, especially:

- `Catalog/old/Pythagorean/SubgroupPressure.lean` — product factorization / partition-function control on direct products
- `Pythagorean/LargeDeviationPressure.lean` — log-convexity, antitonicity, and pressure inequalities, especially `subgroupPressure_geometric_convex`

The target is not just existence of a limit, but a mathematically meaningful **full asymptotic principle** with an explicit rate function and a computational pipeline.

---

## Core Mathematical Objective

Let `G` be a nontrivial finite group. Let `genDefect : G × G → ℕ` denote the generation defect of a pair, and for the direct power `G^n`, let the induced random variable on uniformly sampled pairs
\[
D_n : (G^n \times G^n) \to \mathbb{R}
\]
be the normalized generation defect
\[
D_n(x,y) := \frac{1}{n}\,\delta_n(x,y),
\]
where `δ_n` is the appropriate additive or subadditive defect statistic extracted from the subgroup-pressure formalism.

Define the partition function
\[
Z_n(t) := \mathbb{E}\big[\exp(t\,\delta_n)\big]
\quad\text{or equivalently}\quad
\widetilde Z_n(t) := \sum_{(x,y)\in G^n\times G^n} e^{t\,\delta_n(x,y)},
\]
depending on the normalization already used in the catalog, and define the finite-volume pressure
\[
\Lambda_n(t) := \frac{1}{n}\log Z_n(t).
\]
The asymptotic log-pressure is conjecturally
\[
\Lambda_G(t) := \lim_{n\to\infty}\Lambda_n(t).
\]

Your mission is to formalize and prove the full Gärtner–Ellis picture.

---

## Precise Target Theorems

### Theorem A: Existence of asymptotic pressure
For every finite nontrivial group `G` and every `t ≥ 0`, the limit
\[
\Lambda_G(t)=\lim_{n\to\infty}\frac{1}{n}\log Z_n(t)
\]
exists in `ℝ` and equals the infimum/supremum given by the relevant Fekete-type lemma, depending on whether the sequence is subadditive or superadditive after logarithm.

### Lean 4 type signature target
You should introduce a precise formal object for the pressure sequence and prove something of the following shape:

```lean
theorem exists_limit_logPartition_directPower
    (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (hG : Nontrivial G) :
    ∀ t : ℝ, 0 ≤ t →
      ∃ L : ℝ,
        Tendsto
          (fun n : ℕ => (1 : ℝ) / n * Real.log (directPowerPartition G n t))
          atTop (𝓝 L)
```

Because `n = 0` is annoying, it may be cleaner and mathematically better to define the sequence on `ℕ+` or prove an equivalent statement for `n+1`:

```lean
theorem exists_limit_logPartition_directPower_succ
    (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (hG : Nontrivial G) :
    ∀ t : ℝ, 0 ≤ t →
      ∃ L : ℝ,
        Tendsto
          (fun n : ℕ => (1 : ℝ) / (n + 1) * Real.log (directPowerPartition G (n + 1) t))
          atTop (𝓝 L)
```

If Mathlib’s existing Fekete lemmas are insufficient, define and prove a custom version specialized to real sequences satisfying the exact inequality produced by the catalog.

---

### Theorem B: Convexity and lower semicontinuity of the limiting pressure
Prove that `Λ_G` is convex on `ℝ≥0` (or all `ℝ`, if the partition function is finite there), and therefore continuous on the interior of its effective domain. This is the exact analytic gateway needed for the Legendre transform.

### Lean 4 type signature target
```lean
def asymptoticPressure
    (G : Type*) [Group G] [Fintype G] [DecidableEq G] (t : ℝ) : ℝ := ...

theorem asymptoticPressure_convexOn
    (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (hG : Nontrivial G) :
    ConvexOn ℝ (Set.Ici 0) (asymptoticPressure G)
```

A stronger global statement is welcome if justified:

```lean
theorem asymptoticPressure_convex
    (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (hG : Nontrivial G) :
    Convex ℝ {p : ℝ × ℝ | p.2 = asymptoticPressure G p.1}
```

But the `ConvexOn` version is likely the right formal level.

---

### Theorem C: Large deviation upper and lower bounds via Legendre transform
Define the candidate rate function
\[
I_G(\alpha) := \sup_{t\ge 0}\{t\alpha - \Lambda_G(t)\}.
\]
Then prove a large deviation principle for the laws of `D_n`, at least first on closed and open subsets of a compact interval containing the support, and then globally if feasible:
- for closed `F`,
\[
\limsup_{n\to\infty}\frac1n \log \mathbb{P}(D_n\in F)\le -\inf_{\alpha\in F} I_G(\alpha),
\]
- for open `U`,
\[
\liminf_{n\to\infty}\frac1n \log \mathbb{P}(D_n\in U)\ge -\inf_{\alpha\in U} I_G(\alpha).
\]

### Lean 4 type signature target
Mathlib may not yet have a ready-made LDP interface in exactly the needed form, so you may need to define a custom predicate:

```lean
def satisfiesLDP
    (μ : ℕ → Measure ℝ) (speed : ℕ → ℝ) (I : ℝ → ℝ) : Prop := ...
```

and prove:

```lean
theorem generationDefect_satisfiesLDP
    (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (hG : Nontrivial G) :
    satisfiesLDP
      (generationDefectLaw G)
      (fun n => n)
      (rateFunction G)
```

If a full measure-theoretic LDP is too heavy for one cycle, prove a mathematically honest finite-support discrete version first:

```lean
theorem generationDefect_ldp_discrete_closed_open
    (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (hG : Nontrivial G) :
    discreteLDP (generationDefectLaw G) (fun n => n) (rateFunction G)
```

This is acceptable only if you clearly state the reduction from the general topological LDP to the finite-support/discrete-support setting for these random variables.

---

## New Definitions You Must Introduce

You are required to define at least one genuinely new mathematical concept not already in the catalog. Here are strong candidates.

### 1. Asymptotic pressure
```lean
def asymptoticPressure
    (G : Type*) [Group G] [Fintype G] [DecidableEq G] (t : ℝ) : ℝ := ...
```
This should package the thermodynamic limit rather than repeatedly re-proving existence.

### 2. Legendre rate function
```lean
def rateFunction
    (G : Type*) [Group G] [Fintype G] [DecidableEq G] (α : ℝ) : ℝ := ...
```

### 3. Generation defect law
A probability measure or pmf on `ℝ`/`ℚ`/`ℕ` induced by uniform sampling of pairs in `G^n`:
```lean
def generationDefectLaw
    (G : Type*) [Group G] [Fintype G] [DecidableEq G] :
    ℕ → Measure ℝ := ...
```
or, in a finite/discrete setting,
```lean
def generationDefectPMF
    (G : Type*) [Group G] [Fintype G] [DecidableEq G] :
    ℕ → PMF ℕ := ...
```

### 4. A custom LDP predicate
This is likely the most scientifically valuable formal addition:
```lean
def discreteLDP
    (μ : ℕ → PMF ℕ) (speed : ℕ → ℝ) (I : ℝ → ℝ) : Prop := ...
```

This is not bureaucratic overhead: it is the conceptual interface that turns your finite-group generation theory into statistical mechanics.

---

## Recommended Proof Architecture

### Strategy A: Thermodynamic formalism via subadditivity + convexity + custom discrete Gärtner–Ellis
This is the most promising path.

**Step 1. Prove multiplicative/submultiplicative partition inequalities on direct powers.**
Use the catalog’s product factorization to show
\[
Z_{m+n}(t)\le Z_m(t)Z_n(t)
\quad\text{or}\quad
Z_{m+n}(t)=Z_m(t)Z_n(t),
\]
depending on the exact defect decomposition already formalized. After taking logs:
\[
a_{m+n}(t)\le a_m(t)+a_n(t),\qquad a_n(t):=\log Z_n(t).
\]
If equality holds, exploit it ruthlessly: then the asymptotic pressure is immediate and even linear in `n`. If only inequalities are available, Fekete is essential.

**Step 2. Formalize Fekete’s lemma in the exact real-valued form you need.**
Do not settle for an abstract existence theorem that is hard to apply. Prove the version:
```lean
theorem fekete_real
    (a : ℕ → ℝ)
    (hsub : ∀ m n, a (m + n) ≤ a m + a n) :
    ∃ L, Tendsto (fun n => a (n+1) / (n+1 : ℝ)) atTop (𝓝 L)
```
or an infimum characterization. This theorem alone will become a reusable catalog asset.

**Step 3. Pass finite-volume geometric convexity to the limit.**
Using `subgroupPressure_geometric_convex`, prove each `Λ_n` is convex/log-convex enough, then show the limit preserves convexity:
\[
\Lambda_G(\theta s+(1-\theta)t)\le \theta \Lambda_G(s)+(1-\theta)\Lambda_G(t).
\]
This gives lower semicontinuity and the Legendre transform framework.

**Step 4. Prove the LDP upper bound using exponential Markov/Chernoff estimates.**
For closed upper tails this should be straightforward:
\[
\mathbb P(D_n \ge \alpha) \le \exp(-nt\alpha)\, Z_n(t).
\]
Then optimize in `t`. This already yields a meaningful one-sided LDP bound and should be formalized even if the full theorem takes longer.

**Step 5. Prove the lower bound from exposed points / differentiability.**
Use convexity and differentiability of `Λ_G` on the interior of the domain, if obtainable from strict convexity or finite-support regularity. If full differentiability is difficult, prove the lower bound first at exposed points of `I_G`, then derive the full LDP if the support is compact and the rate function is good.

**Why this is best:** it aligns perfectly with what the catalog already certifies: product structure + geometric convexity. It converts existing finite-level inequalities into asymptotic statistical mechanics.

---

### Strategy B: Finite-support reduction to a combinatorial Laplace principle
Because `D_n` takes values in a finite subset of `[0,C]` for each `n`, you may bypass some measure-theoretic overhead by proving a **discrete Laplace principle**:
\[
\lim_{n\to\infty}\frac1n \log \sum_\alpha e^{n t \alpha}\, \mathbb P(D_n=\alpha)
= \sup_\alpha \{t\alpha - J_n(\alpha)\}
\]
and then identify the asymptotic rate function through epi-limits of finite support costs.

**Step 1. Define the finite support of `D_n` explicitly and prove compactness/uniform boundedness.**

**Step 2. Prove a discrete Laplace upper/lower bound by max-dominance.**
Since finite sums are dominated by maximal terms up to logarithmic correction, one can derive:
\[
\frac1n\log \sum_i e^{n b_{n,i}} = \max_i b_{n,i} + o(1).
\]

**Step 3. Extract the rate function from the asymptotic maximization formula.**

**Why this is attractive:** it may avoid importing a heavy general Gärtner–Ellis theorem, while still yielding a formally verified theorem that is mathematically equivalent in your finite-group setting.

---

### Strategy C: Exact product decomposition and Cramér-type theorem on coordinate defects
If the generation defect on `G^n` actually decomposes as a sum of i.i.d. coordinate-level defect variables on `G`, then you can prove a direct Cramér theorem rather than a generic Gärtner–Ellis theorem.

**Step 1. Prove additive decomposition**
\[
\delta_n((x_1,\dots,x_n),(y_1,\dots,y_n))
= \sum_{i=1}^n \delta_1(x_i,y_i).
\]

**Step 2. Identify `Z_n(t) = Z_1(t)^n`.**

**Step 3. Apply a finite-support Cramér theorem.**

**Why it is powerful:** if true, it gives much more than existence — it gives an exact closed form:
\[
\Lambda_G(t)=\log \mathbb E[e^{t\delta_1}],
\]
and the rate function becomes the ordinary Legendre transform of a one-step cumulant generating function. This would be spectacularly clean. But do not force it unless the defect really is coordinate-additive; if only subadditivity survives, return to Strategy A.

---

## Cross-Domain Connections You Must Exploit

This project is strongest when framed not as “finite group combinatorics,” but as a new thermodynamic theory of algebraic generation.

### 1. Statistical mechanics / thermodynamic formalism
Interpret `Z_n(t)` as a partition function, `Λ_G(t)` as free energy density, and `I_G` as entropy cost of atypical generation behavior. This is not analogy for analogy’s sake: it dictates the proof architecture and gives the correct conceptual vocabulary.

### 2. Convex analysis / optimization
The Legendre transform is the bridge from pressure to rate. Convex duality is the engine. Formalizing this in Lean creates infrastructure usable far beyond group theory.

### 3. Information theory
If you can show that the normalized generation defect behaves like an empirical cost observable, then the rate function acts like a relative-entropy penalty. Even a heuristic theorem relating `I_G` to a variational principle would be a major conceptual advance.

### 4. Probabilistic combinatorics
This theorem would place random generation of finite groups into the same asymptotic universe as random graphs, spin systems, and coding theory — an entirely new bridge.

### 5. Mathematical physics
The nontrivial message is that subgroup structure induces an effective energy landscape on random pairs. The asymptotic pressure is then a bona fide free energy for algebraic generation.

---

## Concrete Intermediate Theorems You Should Prove

You must include at least 3 substantial theorems with nontrivial proofs. Strong candidates:

### Theorem 1: Subadditivity of log partition
```lean
theorem log_directPowerPartition_subadditive
    (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (hG : Nontrivial G) (t : ℝ) (ht : 0 ≤ t) :
    ∀ m n : ℕ,
      Real.log (directPowerPartition G (m + n) t)
        ≤ Real.log (directPowerPartition G m t)
        + Real.log (directPowerPartition G n t)
```
This should require real inequalities, positivity of partition functions, and likely multi-step `calc`.

### Theorem 2: Fekete limit theorem specialized to pressure
```lean
theorem pressure_limit_exists
    (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (hG : Nontrivial G) (t : ℝ) (ht : 0 ≤ t) :
    ∃ L : ℝ,
      Tendsto
        (fun n : ℕ =>
          Real.log (directPowerPartition G (n + 1) t) / (n + 1 : ℝ))
        atTop (𝓝 L)
```

### Theorem 3: Convexity of asymptotic pressure
```lean
theorem pressure_limit_convex
    (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (hG : Nontrivial G) :
    ConvexOn ℝ (Set.Ici 0) (asymptoticPressure G)
```

### Theorem 4: Chernoff upper bound for defect tails
```lean
theorem generationDefect_upper_tail_bound
    (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (hG : Nontrivial G) :
    ∀ {α t : ℝ}, 0 ≤ t →
      ∀ n : ℕ,
      Real.log (tailProb G n α) / (n + 1 : ℝ)
        ≤ asymptoticPressure G t - t * α + errorTerm n
```
with `errorTerm n → 0`. This is already a publishable asymptotic inequality if fully formalized.

### Theorem 5: Legendre upper bound
```lean
theorem generationDefect_ldp_upper_bound
    (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (hG : Nontrivial G) :
    ∀ α : ℝ,
      Filter.limsup
        (fun n : ℕ => Real.log (tailProb G n α) / (n + 1 : ℝ))
        atTop
      ≤ - rateFunction G α
```

---

## Falsifiable Conjecture with Computational Test

You must state at least one testable conjecture with a clear disproof protocol.

### Conjecture: Strict convexity away from the degenerate regime
For every finite nontrivial group `G` whose one-step generation defect is nonconstant, the asymptotic pressure `Λ_G` is strictly convex on some nonempty interval in `(0,∞)`. Equivalently, the rate function `I_G` is differentiable on the interior of its effective domain except possibly at finitely many phase-transition points.

### Lean-facing statement sketch
```lean
conjecture asymptoticPressure_strictConvex
    (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    (hG : Nontrivial G) (hnonconst : NonconstantOneStepDefect G) :
    StrictConvexOn ℝ (Set.Ioi 0) (asymptoticPressure G)
```

### Computational disproof test
For `G = ZMod 6`, `S₃`, `D₈`, and `Q₈`, numerically compute:
- `Λ_n(t)` for `n ≤ 50`,
- discrete second differences in `t`,
- empirical histograms of `D_n`,
- Legendre-transformed candidate rates.

A counterexample would appear as persistent flat regions in the second derivative proxy or mismatch between empirical tail slopes and the predicted `I_G`.

This is falsifiable, not decorative.

---

## Why This Would Be a Breakthrough

A proof here would do more than solve one conjecture. It would establish that **algebraic generation statistics admit a thermodynamic limit with a variational principle**. That is a conceptual leap.

It would open:
- asymptotic generation theory for families of groups,
- concentration and moderate deviations for random generators,
- phase-transition phenomena in subgroup landscapes,
- analogies with spin systems and free energy in algebraic settings,
- a reusable Lean library for subadditivity, convex duality, and discrete LDPs.

This is exactly the kind of theorem that makes a mathematician say: *I did not expect finite group generation to have a free-energy/rate-function theory.*

---

## Implementation Expectations

You must minimize `sorry` and avoid trivial theorem padding. The work should include:

1. **A Lean file** with the new definitions and at least 3 substantial theorems using real proof structure: induction, `rcases`, `by_contra`, `field_simp`, and/or multi-step `calc`.
2. **A verified algorithm or computational method** to compute or approximate:
   - `directPowerPartition G n t`,
   - empirical defect law,
   - numerical Legendre transform of `Λ_n`.
3. **`demo.py`** that interactively:
   - samples random pairs in `(Z/6Z)^n`,
   - estimates empirical tail probabilities,
   - computes numerical pressure curves,
   - compares empirical rate estimates with the Legendre-transform prediction.
4. **`RESEARCH_PAPER.md`** as a standalone scientific document explaining the theorem, the proof architecture, the conceptual meaning, and next questions.
5. **`ARTICLE.md`** in Scientific American style, focused on the ideas: random generation, rare events, thermodynamic laws in algebra. Do **not** talk about formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions. Each direction must include the exact sentences:
   - **“The key insight is…”**
   - **“Why now?”**
   At least one direction must bridge to a different domain, such as information theory, statistical mechanics, or additive combinatorics.

---

## Suggested File-Level Deliverables

A compelling architecture would be:

- `Pythagorean/GenerationDefectLDP.lean`
  - definitions: `asymptoticPressure`, `rateFunction`, `generationDefectLaw`, `discreteLDP`
  - theorems: subadditivity, Fekete limit, convexity, upper tail LDP, full discrete LDP if feasible

- `Pythagorean/FeketeTools.lean`
  - reusable subadditive-limit lemmas for real sequences

- `demo.py`
  - Monte Carlo and numerical pressure/rate plots

---

## Application Keywords

large deviations, Gärtner–Ellis theorem, Fekete lemma, convex duality, Legendre transform, finite group generation, random generators, subgroup pressure, thermodynamic formalism, free energy, entropy, Chernoff bounds, probabilistic combinatorics, statistical mechanics, asymptotic algebra, rate function, concentration of measure, phase transitions, information theory

---

## Final Charge

Do not merely show a limit exists. Build the **thermodynamic theory of generation defect**. Extract a pressure, prove convexity, derive a rate function, and turn finite subgroup inequalities into asymptotic laws of rare algebraic events. This is the moment to make probabilistic generation of finite groups look like statistical mechanics.

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
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
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
