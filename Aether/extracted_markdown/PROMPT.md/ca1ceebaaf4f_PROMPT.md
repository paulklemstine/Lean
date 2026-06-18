Soli Deo Gloria

## Assignment: Direction 3: Information-Theoretic Monotonicity for Robustly Lorentzian Measures

**Mode:** `prove`

Prove genuinely new, nontrivial theorems at the interface of **Lorentzian probability measures, entropy inequalities, and discrete information geometry**. This project should not be a soft reformulation of correlation decay; it should establish a **formal information-theoretic calculus for robustly Lorentzian measures**. The goal is to show that the same curvature/negativity mechanisms controlling pairwise dependence also force monotonicity and rigidity of entropy-like quantities under projection and conditioning.

Build explicitly on:

- `Catalog/Pythagorean/RobustLorentzianSampling.lean`
- especially theorem `robust_quadform_negativity`

Your task is to extract from robust quadratic-form negativity a new family of **entropy and mutual-information bounds** with enough structure to support algorithms, experiments, and future theory.

---

## Central Vision

A robustly Lorentzian measure should behave like a discrete curved medium: deleting coordinates cannot destroy too much uncertainty, and pairwise information cannot become arbitrarily concentrated if the Lorentzian gap is bounded below. If formalized correctly, this becomes a new dictionary:

- **Lorentzian gap** ↔ **information contraction**
- **Rayleigh-type negativity** ↔ **pairwise information suppression**
- **projection / deletion** ↔ **data processing**
- **strong combinatorial concavity** ↔ **entropy monotonicity**

This would open a new field: **discrete Hodge-information theory**, where algebraic negativity statements imply quantitative information inequalities.

---

## Precise Formalization Targets

You must introduce at least one genuinely new definition not already present in the catalog. A promising choice is a finite-coordinate probability package for subset laws together with information quantities.

### New definitions to introduce

Define a structure encoding a probability mass function on `Finset (Fin n)` together with normalization and positivity:

```lean
structure FinsetLaw (n : ℕ) where
  weight : Finset (Fin n) → ℝ
  nonneg : ∀ s, 0 ≤ weight s
  total_one : (∑ s in Finset.powerset Finset.univ, weight s) = 1
```

Define deletion pushforward:

```lean
def deleteCoordPushforward (μ : FinsetLaw (n+1)) (k : Fin (n+1)) : FinsetLaw n := ...
```

Define coordinate indicator marginals, binary entropy, total entropy, conditional entropy, and pairwise mutual information:

```lean
def coordProb (μ : FinsetLaw n) (i : Fin n) : ℝ := ...
def binaryEntropy (p : ℝ) : ℝ := ...
def totalEntropy (μ : FinsetLaw n) : ℝ := ...
def pairJointProb (μ : FinsetLaw n) (i j : Fin n) : ℝ := ...
def mutualInfoCoord (μ : FinsetLaw n) (i j : Fin n) : ℝ := ...
```

Define a robustness predicate abstracting the quantitative negativity inherited from the catalog theorem:

```lean
def RobustlyLorentzian (μ : FinsetLaw n) (ε : ℝ) : Prop := ...
```

This predicate should be strong enough to derive pairwise covariance control from `robust_quadform_negativity`, but weak enough that uniform matroid laws and related examples can instantiate it.

You may also define an auxiliary notion:

```lean
def PairwiseCovControlled (μ : FinsetLaw n) (ε : ℝ) : Prop := ...
```

if this helps separate the catalog import from the entropy arguments.

---

## Exact Theorem Targets

You must prove at least **3 substantial theorems**. At least one should be a cross-domain bridge theorem. Below are the target statements.

### Theorem 1: Projection entropy lower bound
A rigorous theorem should replace the informal `O(1)` by an explicit constant, even if modest.

**Mathematical statement.**  
For every finite law `μ` on subsets of `[n+1]`, if `μ` is robustly Lorentzian with gap `ε > 0`, then deleting one coordinate decreases entropy by at most a logarithmic penalty in the inverse gap:

\[
\forall n \ge 1,\ \forall \mu,\ \forall k,\ \forall \varepsilon>0,\quad
\mathrm{RobustlyLorentzian}(\mu,\varepsilon)\to
H(\pi_{k*}\mu)\ge H(\mu)-\log(1/\varepsilon)-C
\]
for an explicit universal constant `C`.

A Lean-oriented signature could be:

```lean
theorem entropy_delete_lower_bound
    {n : ℕ} (hn : 1 ≤ n) (μ : FinsetLaw (n+1)) (k : Fin (n+1)) {ε C : ℝ}
    (hε : 0 < ε) (hC : 0 ≤ C)
    (hrob : RobustlyLorentzian μ ε)
    (hconst : UniversalEntropyConstant C) :
    totalEntropy (deleteCoordPushforward μ k)
      ≥ totalEntropy μ - Real.log (1 / ε) - C
```

If `UniversalEntropyConstant` is too heavy, you may instead prove the theorem with a concrete constant derived in the proof.

### Theorem 2: Pairwise mutual information bound from robust negativity
This is the heart of the information-theoretic dictionary.

\[
\forall i\neq j,\qquad I(X_i;X_j)\le C\,\Phi(\varepsilon),
\]
where the most realistic first target is either `C / ε`, `C * log(1 + 1/ε)`, or `C * |Cov(X_i,X_j)|` followed by a covariance bound from robust Lorentzianity.

A Lean-oriented target:

```lean
theorem mutualInfoCoord_le_of_robust
    {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hε : 0 < ε) (hrob : RobustlyLorentzian μ ε) :
    ∀ ⦃i j : Fin n⦄, i ≠ j →
      mutualInfoCoord μ i j ≤ mutualInfoBound ε
```

where

```lean
def mutualInfoBound (ε : ℝ) : ℝ := ...
```

You should make this explicit, not asymptotic.

### Theorem 3: Entropy submodularity / Shearer-type consequence under robust Lorentzianity
To avoid merely bounding one projection, prove a structural theorem showing entropy behaves monotonically across families of deletions or coverings.

A promising statement:

\[
H(\mu)\le \frac1r\sum_{t=1}^m H(\pi_{A_t *}\mu) + \Psi(\varepsilon),
\]
for a family of coordinate subsets covering each coordinate at least `r` times.

Lean-style:

```lean
theorem shearer_type_of_robust_lorentzian
    {n m r : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hε : 0 < ε) (hrob : RobustlyLorentzian μ ε)
    (A : Fin m → Finset (Fin n))
    (hcover : ∀ i : Fin n, r ≤ ((Finset.univ.filter fun t => i ∈ A t).card))
    (hr : 0 < r) :
    totalEntropy μ ≤
      (1 / (r : ℝ)) * ∑ t : Fin m, totalEntropy (projectToSet μ (A t))
      + shearerError ε
```

This theorem is revolutionary because it upgrades pairwise negativity into a many-coordinate information inequality.

### Theorem 4 (cross-domain theorem): Correlation-energy or communication bound
You must include at least one theorem explicitly bridging to another domain.

Two strong options:

#### Option A: Statistical physics bridge
Show that robust Lorentzianity forces an upper bound on susceptibility / quadratic response of the associated spin system.

```lean
theorem fisher_information_style_bound
    {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hε : 0 < ε) (hrob : RobustlyLorentzian μ ε) :
    spinSusceptibility μ ≤ susceptibilityBound ε
```

This creates a bridge to **statistical mechanics**: Lorentzian negativity acts like repulsive curvature limiting response.

#### Option B: Communication complexity / information complexity bridge
Show that if a binary protocol samples two coordinates from a robustly Lorentzian law, then the internal information cost is bounded by the same mutual-information control.

```lean
theorem protocol_info_cost_bound
    {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hε : 0 < ε) (hrob : RobustlyLorentzian μ ε) :
    twoCoordinateInfoCost μ ≤ mutualInfoBound ε
```

Even a simplified theorem reducing protocol information cost to `mutualInfoCoord` is valuable. This is a direct bridge from combinatorial Hodge theory to **communication complexity**.

---

## Why this would be a breakthrough

The catalog theorem `robust_quadform_negativity` gives a geometric negativity principle. That is already powerful. But if you can prove that this negativity controls **entropy loss under projection** and **pairwise mutual information**, then the meaning of robust Lorentzianity changes completely:

- it is no longer just a geometric or algebraic property;
- it becomes an **information-contraction principle**;
- it yields a new toolkit for analyzing sampling, privacy, dependence, and compression.

This would create the first formal bridge from **discrete Lorentzian geometry** to **information theory**, with immediate implications for:

- strongly negatively dependent sampling,
- privacy amplification under coordinate deletion,
- anti-clustering bounds in statistical mechanics,
- information complexity of combinatorial distributions,
- entropy decay along combinatorial Markov chains.

---

## Proof Strategy Architecture

You must not give a one-line proof sketch. Develop at least 2–3 viable approaches, and pursue the most promising one in Lean.

### Strategy A: Covariance-to-information route via binary variables
This is the most promising first path.

1. Use `robust_quadform_negativity` to derive explicit pairwise covariance bounds for indicator variables `1_{i ∈ S}` and `1_{j ∈ S}`.
2. Prove an analytic lemma bounding mutual information of two Bernoulli variables in terms of covariance and marginal probabilities.
3. Combine with entropy chain rule:
   \[
   H(X) = H(X_{-k}) + H(X_k \mid X_{-k}),
   \]
   and use covariance control to show the conditional entropy term cannot collapse too much under deletion.

Why promising: this reduces the hard geometry to finite-dimensional analytic inequalities on Bernoulli pairs, which are realistic in Lean using `calc`, `field_simp`, case splits, and explicit algebra.

### Strategy B: Shearer + approximate submodularity route
1. Prove entropy submodularity for your finite law formalism, or at least the restricted form needed for coordinate projections.
2. Use robust Lorentzianity to control the defect between exact Shearer behavior and the actual projection entropy profile.
3. Deduce projection lower bounds and many-coordinate entropy inequalities.

Why promising: this scales beyond pairwise bounds and gives a true information-theoretic structure theorem, but it is likely technically heavier in Lean.

### Strategy C: Generating polynomial / partition function route
1. Associate to `μ` a multiaffine generating polynomial.
2. Translate deletion/projection into specialization or differentiation of the generating polynomial.
3. Use robust Lorentzian Hessian negativity to control second derivatives of `log Z`, then identify these with covariances and entropy derivatives.

Why promising: conceptually deepest and best aligned with Lorentzian geometry. Why risky: formalizing the analytic dictionary may be substantial unless the catalog already provides enough polynomial infrastructure.

**Recommendation:** Start with Strategy A for the core theorem package, then extract Strategy C as a conceptual interpretation in `RESEARCH_PAPER.md` and a conjectural extension.

---

## Concrete intermediate lemmas you should aim to prove

These are not optional fluff; they are the scaffolding that turns the conjecture into a theorem.

1. **Indicator covariance control**
```lean
theorem cov_indicator_le_of_robust
    {n : ℕ} (μ : FinsetLaw n) {ε : ℝ}
    (hε : 0 < ε) (hrob : RobustlyLorentzian μ ε) :
    ∀ ⦃i j : Fin n⦄, i ≠ j →
      |coordCov μ i j| ≤ covBound ε
```

2. **Mutual information bounded by covariance for Bernoulli pairs**
```lean
theorem mutualInfo_bernoulli_pair_le_cov_bound
    {p q c : ℝ}
    (hp : 0 < p) (hp1 : p < 1)
    (hq : 0 < q) (hq1 : q < 1)
    (hc : jointCompatible p q c) :
    bernoulliPairMI p q c ≤ bernoulliMICovUpper p q * |c|
```

3. **Entropy chain rule for deletion pushforward**
```lean
theorem totalEntropy_delete_chain_rule
    {n : ℕ} (μ : FinsetLaw (n+1)) (k : Fin (n+1)) :
    totalEntropy μ =
      totalEntropy (deleteCoordPushforward μ k) +
      conditionalEntropyCoord μ k
```

4. **Conditional entropy lower bound from robust dependence control**
```lean
theorem conditionalEntropyCoord_lower_of_robust
    {n : ℕ} (μ : FinsetLaw (n+1)) (k : Fin (n+1)) {ε : ℝ}
    (hε : 0 < ε) (hrob : RobustlyLorentzian μ ε) :
    -Real.log (1 / ε) - entropySlack ≤ conditionalEntropyCoord μ k
```

These lemmas will force real proof work: induction over coordinates, `rcases` on membership, `by_contra` for positivity constraints, `field_simp` in rational manipulations, and multi-step `calc` proofs for entropy algebra.

---

## Lean 4 expectations

Your Lean development must include at least 3 theorems whose proofs materially use techniques such as:

- induction on `n` or on finite set structure,
- `rcases` on coordinate membership and pushed-forward fibers,
- `by_contra` to derive impossible sign configurations,
- `field_simp` for entropy/covariance algebra with denominators,
- long `calc` chains connecting covariance, entropy, and projection formulas.

Avoid vacuous proofs by simplification alone. The target theorems should resist brute-force automation.

---

## Cross-domain connections to develop explicitly

At least one theorem and part of the exposition must connect to a different domain. You should emphasize one or more of:

- **Information theory:** data processing, mutual information, Shearer’s lemma, entropy chain rule.
- **Statistical mechanics:** susceptibility, response bounds, repulsive spin systems.
- **Communication complexity:** internal information cost of revealing coordinates.
- **Privacy / DP:** deletion as a privacy mechanism, entropy retention as robustness of uncertainty.
- **Discrete geometry / Hodge theory:** Lorentzian forms as curvature controlling information flow.

The most compelling narrative is:

> robust Lorentzianity is a discrete curvature condition, and entropy monotonicity is its information-theoretic shadow.

That is the conceptual leap.

---

## Computational / algorithmic deliverable

You must produce a **verified computational method**, not only theorem statements.

### Required algorithm
Implement an algorithm that, for explicit finite laws on subsets of `[n]`:

1. computes coordinate marginals,
2. computes pairwise covariances,
3. computes pairwise mutual informations,
4. computes deletion pushforward entropies,
5. checks the theorem inequalities numerically,
6. tests the conjectured scaling in `ε`.

Suggested Lean-visible specification:

```lean
def auditRobustLorentzianInfoProfile (μ : FinsetLaw n) : InfoProfile := ...
```

with fields such as entropy, deleted entropies, covariance matrix entries, MI matrix entries, and pass/fail indicators for the proved bounds.

This should support extraction or parallel implementation in Python.

---

## demo.py requirements

Provide `demo.py` that interactively demonstrates:

- uniform matroid distributions,
- perturbed negatively dependent laws,
- deletion entropy before/after removing a coordinate,
- pairwise mutual information heatmaps,
- comparison of empirical values against the certified upper bounds.

The demo should let the user vary a proxy for `ε` and see whether:
- entropy loss tracks `log(1/ε)`,
- mutual information tracks the predicted bound,
- uniform matroid examples saturate or undershoot the inequalities.

---

## Falsifiable conjecture with computational test

You must state at least one explicit conjecture that could fail under computation.

### Conjecture A: Sharp logarithmic deletion law
There exists a universal `C > 0` such that for every robustly Lorentzian law `μ` with gap `ε`,
\[
H(\pi_{k*}\mu) \ge H(\mu) - \log(1/\varepsilon) - C
\]
for every deleted coordinate `k`, and this is asymptotically sharp for a family of sparse matroid laws.

**Testable prediction:** compute exact entropies for uniform matroids and selected perturbations; fit the entropy drop against `log(1/ε)` and check whether the residual remains bounded.

### Conjecture B: Mutual information is actually logarithmic, not linear
The stated `O(1/\varepsilon)` may be crude. The real law may be
\[
I(X_i;X_j)\le C \log(1 + 1/\varepsilon).
\]

**Testable prediction:** on explicit robustly Lorentzian families, compare empirical `I(X_i;X_j)` against both `1/ε` and `log(1+1/ε)` fits. If the logarithmic fit is consistently better, the theorem proved this cycle is only the first approximation.

This is an excellent place where experiment can guide the next theorem.

---

## Application keywords

Use these keywords explicitly in your paper and exposition:

**application keywords:** `entropy monotonicity`, `mutual information`, `data processing inequality`, `negative dependence`, `Lorentzian polynomials`, `discrete Hodge theory`, `Shearer lemma`, `strong log-concavity`, `privacy amplification`, `communication complexity`, `statistical mechanics`, `susceptibility bounds`, `projection stability`, `information contraction`

---

## Mandatory deliverables

You must produce **all** of the following:

1. **Lean file(s)** proving the new theorems with minimal sorry usage.
2. **A new mathematical definition** such as `FinsetLaw`, `RobustlyLorentzian`, or an equivalent novel information-theoretic structure.
3. **At least 3 substantial theorems** with deep proof tactics, not trivial simplifications.
4. **A cross-domain theorem** connecting Lorentzian measures to information theory, statistical mechanics, or communication complexity.
5. **A falsifiable conjecture** with a computational test that could genuinely fail.
6. **A verified algorithm or computational method** for auditing entropy and mutual-information profiles.
7. **`demo.py`** demonstrating the theorem numerically and interactively.
8. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions. Each direction must include the exact phrases:
   - “The key insight is...”
   - “Why now?”
   At least one direction must bridge to a different domain.
9. **`RESEARCH_PAPER.md`** as a standalone scientific paper explaining the definitions, theorems, significance, proof ideas, examples, and next questions. A reader with no access to the code must still understand the discovery.
10. **`ARTICLE.md`** in Scientific American style, engaging and accessible, focused on the mathematics and significance. Do **not** center formal verification machinery.

---

## Final charge

Do not merely show that robust Lorentzianity implies another correlation inequality. Show that it imposes an **information geometry** on finite subset laws. The breakthrough target is to make entropy, mutual information, and projection stability into certified consequences of Lorentzian negativity. If you succeed, you will not just extend the catalog — you will reveal that discrete Hodge theory has an information-theoretic shadow nobody has properly formalized.

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
