Soli Deo Gloria

## Assignment: Direction 5 — Newton Hierarchy for Interacting Fermions via Determinantal Approximation

**Mode:** `prove`

You are not being asked for a small extension. You are being asked to formalize the first mathematically serious bridge between **free-fermion Newton hierarchy technology** and **weakly interacting many-body entanglement theory**. The breakthrough target is to show that the algebraic invariants controlling compressibility of entanglement spectra are **stable under weak interaction**, and therefore remain informative beyond the Gaussian world.

Build directly on the catalog infrastructure around:

- `Pythagorean/NewtonEntropyHierarchy.lean`
  - `NewtonRatioProfile`
  - `AreaLawCompatible`
  - `esymm_newton_inequality`

Your task is to create a new Lean development proving nontrivial perturbative stability theorems for Newton-ratio data under spectral deformation, with a mathematically meaningful abstraction that captures “interacting spectrum close to determinantal spectrum.”

---

## Central Vision

For a probability spectrum `p : Fin n → ℝ` with nonnegative entries, define its elementary symmetric data and Newton ratio profile. In the free-fermion setting, these ratios encode determinantal/algebraic structure. In an interacting fermion system, the entanglement spectrum is no longer exactly Gaussian, but in the weak-coupling regime it should remain **quantitatively close** to a Gaussian proxy.

The field-opening theorem is:

> **Weak-interaction stability of Newton hierarchy:** if an interacting entanglement spectrum is uniformly close to a Gaussian/free-fermion reference spectrum, then every finite-level Newton ratio changes by a controlled amount, with explicit dependence on the perturbation size and on lower bounds for the relevant symmetric polynomials.

This opens a program in which **algebraic compression** becomes a robust observable for interacting quantum matter rather than a free-particle artifact.

---

## Required New Definitions

You must introduce at least one genuinely new concept not already present in the catalog. The recommended structure is:

### 1. Spectral perturbation structure
Define a notion of two spectra being close in sup norm, together with positivity/nondegeneracy assumptions sufficient to control Newton ratios.

Suggested Lean structure:
```lean
structure WeaklyInteractingApprox (n : ℕ) where
  exactSpec : Fin n → ℝ
  gaussianSpec : Fin n → ℝ
  nonneg_exact : ∀ i, 0 ≤ exactSpec i
  nonneg_gaussian : ∀ i, 0 ≤ gaussianSpec i
  sup_bound : ∃ ε > 0, ∀ i, |exactSpec i - gaussianSpec i| ≤ ε
```

### 2. Newton defect / ratio deviation
Define a new quantity measuring deviation of Newton ratio profiles:
```lean
def NewtonRatioDeviation {n : ℕ} (p q : Fin n → ℝ) (k : ℕ) : ℝ := 
  |NewtonRatioProfile p k - NewtonRatioProfile q k|
```

### 3. Optional stronger concept
A higher-level concept capturing perturbative Newton stability:
```lean
def NewtonStableToOrder {n : ℕ} (p q : Fin n → ℝ) (K : ℕ) (C ε : ℝ) : Prop :=
  ∀ k ≤ K, NewtonRatioDeviation p q k ≤ C * ε
```

This is the right abstraction: not “Hubbard model” directly, but a spectral interface that can later be instantiated by exact diagonalization data.

---

## Precise Theorem Targets

You must prove **at least 3 substantial theorems**. The following are the core targets.

### Theorem 1: Lipschitz stability of elementary symmetric polynomials

Informal statement:

> Let `p q : Fin n → ℝ` be nonnegative spectra with `|p i - q i| ≤ ε` for all `i`. Then for each `k ≤ n`, the difference between the `k`-th elementary symmetric polynomials of `p` and `q` is bounded linearly in `ε`, with a constant depending only on `n`, `k`, and a uniform bound on coordinates.

This is the combinatorial engine behind everything else.

Suggested Lean-style signature:
```lean
theorem esymm_lipschitz_supnorm
  {n k : ℕ} (p q : Fin n → ℝ) (ε B : ℝ)
  (hk : k ≤ n)
  (hε : 0 ≤ ε)
  (hB : 0 ≤ B)
  (hpB : ∀ i, p i ≤ B)
  (hqB : ∀ i, q i ≤ B)
  (hclose : ∀ i, |p i - q i| ≤ ε) :
  ∃ C : ℝ, 0 ≤ C ∧
    |(Finset.univ.powersetCard k).sum (fun s => ∏ i in s, p i)
     - (Finset.univ.powersetCard k).sum (fun s => ∏ i in s, q i)| ≤ C * ε
```

If the catalog already defines the elementary symmetric polynomial operator, use that instead of the explicit finite sum. Prefer a theorem phrased directly in the catalog language.

**Why this matters:** This theorem is the perturbative substitute for exact determinantal structure. It converts coordinate-level spectral proximity into algebraic proximity.

---

### Theorem 2: Stability of Newton ratio profiles under weak perturbation

Informal statement:

> Suppose `p` and `q` are nonnegative spectra with `|p_i - q_i| ≤ ε`, and suppose the relevant symmetric polynomials of `q` are bounded away from zero. Then the Newton ratio profiles satisfy
> `|NR_p(k) - NR_q(k)| ≤ C_k ε`
> for every admissible `k`.

Suggested Lean-style signature:
```lean
theorem newton_ratio_lipschitz
  {n k : ℕ} (p q : Fin n → ℝ) (ε δ B : ℝ)
  (hk1 : 1 ≤ k) (hk2 : k + 1 ≤ n)
  (hε : 0 ≤ ε) (hδ : 0 < δ) (hB : 0 ≤ B)
  (hp_nonneg : ∀ i, 0 ≤ p i)
  (hq_nonneg : ∀ i, 0 ≤ q i)
  (hpB : ∀ i, p i ≤ B)
  (hqB : ∀ i, q i ≤ B)
  (hclose : ∀ i, |p i - q i| ≤ ε)
  (hdenom :
    δ ≤ elementarySymmetric q (k-1) ∧
    δ ≤ elementarySymmetric q k ∧
    δ ≤ elementarySymmetric q (k+1)) :
  ∃ C : ℝ, 0 ≤ C ∧
    |NewtonRatioProfile p k - NewtonRatioProfile q k| ≤ C * ε
```

If `NewtonRatioProfile` is indexed differently in the catalog, adapt accordingly. The theorem must be stated in the native indexing convention of the existing file.

**Why this is a breakthrough:** This is the first theorem saying that Newton-hierarchy observables are not brittle exact identities but **stable observables**. That is exactly what interacting physics needs.

---

### Theorem 3: Area-law compatibility is stable under approximate Gaussianity

Informal statement:

> If a Gaussian reference spectrum satisfies the catalog’s `AreaLawCompatible` property, and an interacting spectrum is sufficiently close to it in the sense above, then the interacting spectrum satisfies a quantitative approximate area-law-compatible inequality.

This should not merely restate the catalog theorem. You need a quantitative deformation result.

Suggested Lean theorem:
```lean
def ApproxAreaLawCompatible {n : ℕ} (p : Fin n → ℝ) (K : ℕ) (η : ℝ) : Prop :=
  ∀ k ≤ K, NewtonRatioProfile p k ≤ η

theorem approx_area_law_of_weakly_interacting
  {n K : ℕ} (p q : Fin n → ℝ) (ε η δ B : ℝ)
  (hK : K + 1 ≤ n)
  (hq_area : AreaLawCompatible q)
  (hclose : ∀ i, |p i - q i| ≤ ε)
  (hp_nonneg : ∀ i, 0 ≤ p i)
  (hq_nonneg : ∀ i, 0 ≤ q i)
  (hpB : ∀ i, p i ≤ B)
  (hqB : ∀ i, q i ≤ B)
  (hδ : 0 < δ) :
  ∃ C : ℝ, 0 ≤ C ∧
    ApproxAreaLawCompatible p K (η + C * ε)
```

If `AreaLawCompatible` in the catalog is not literally an upper bound on `NewtonRatioProfile`, prove the strongest quantitatively deformed statement compatible with the actual definition.

**Why this matters:** This theorem upgrades a static structural property into a **robust phase diagnostic** for weakly interacting systems.

---

## Ambitious Cross-Domain Theorem

You are required to include at least one theorem that genuinely bridges domains. The recommended bridge is:

### Theorem 4: Algebraic-combinatorial control implies perturbative many-body stability

Interpret the entanglement spectrum as a probability vector and prove that **majorization-type spectral control** or **ℓ∞ control** implies bounded variation of algebraic Newton observables. This connects:

- many-body quantum physics,
- algebraic combinatorics of symmetric polynomials,
- and quantitative analysis / perturbation theory.

Suggested statement:
```lean
theorem interacting_fermion_newton_control
  {n K : ℕ} (A : WeaklyInteractingApprox n) (B δ : ℝ)
  (hB_exact : ∀ i, A.exactSpec i ≤ B)
  (hB_gauss : ∀ i, A.gaussianSpec i ≤ B)
  (hδ : 0 < δ) :
  ∃ ε C : ℝ, ε > 0 ∧ 0 ≤ C ∧
    (∀ k ≤ K, NewtonRatioDeviation A.exactSpec A.gaussianSpec k ≤ C * ε)
```

This theorem should be proved by unpacking the structure and invoking the previous stability theorem. It serves as the formal “physics corollary” that makes the abstract machinery reusable.

---

## Proof Strategy Architecture

You must not give a one-line proof plan. Use a genuine multi-path strategy.

### Strategy A — Combinatorial telescoping on products (most promising)
1. Expand the elementary symmetric polynomial as a sum over `k`-subsets.
2. For each subset product `∏ p_i - ∏ q_i`, use a telescoping product identity:
   \[
   \prod_{j=1}^k a_j - \prod_{j=1}^k b_j
   = \sum_{m=1}^k \left(\prod_{j<m} a_j\right)(a_m-b_m)\left(\prod_{j>m} b_j\right).
   \]
3. Bound each term using uniform coordinate bounds `≤ B` and perturbation size `≤ ε`.
4. Sum over subsets to get a global Lipschitz constant for `e_k`.

**Why most promising:** It is finite, explicit, combinatorial, and well-suited to Lean’s `Finset` induction and `calc` chains. It avoids importing analytic differentiation machinery.

### Strategy B — Induction via recursive identity for elementary symmetric polynomials
1. Use the recursion
   \[
   e_k(x_1,\dots,x_n)=e_k(x_1,\dots,x_{n-1})+x_n e_{k-1}(x_1,\dots,x_{n-1}).
   \]
2. Perform induction on `n`, proving simultaneous bounds for all `k`.
3. Derive Newton-ratio stability by combining bounds on numerator and denominator and applying rational perturbation estimates.

**Why useful:** This produces elegant structural proofs and may interact better with existing catalog lemmas if the symmetric polynomial recursion is already available.

### Strategy C — Abstract rational-function perturbation
1. First prove a generic lemma:
   if `|a-a'| ≤ α`, `|b-b'| ≤ β`, and denominators are bounded below by `δ > 0`, then
   \[
   \left|\frac{a}{b}-\frac{a'}{b'}\right|
   \le \frac{α}{δ} + \frac{|a'|β}{δ^2}
   \]
   or a similar explicit bound.
2. Apply this to the formula defining `NewtonRatioProfile`.
3. Combine with Theorem 1 bounds for each relevant `e_k`.

**Why useful:** This modularizes the proof and creates reusable perturbation lemmas for future spectral invariants.

**Recommendation:** Use **Strategy A + C** for the main theorems. Use Strategy B only if the catalog’s esymm recursion is already well-developed.

---

## Lean Tactics Expectations

Your proofs must visibly use deep proof structure. Across the file, ensure at least 3 theorems use combinations of:

- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`
- careful `have` chains on inequalities

Avoid trivial closures by automation. The point is to produce reusable mathematical infrastructure, not merely verified numerology.

---

## Mathematical Refinements You Should Exploit

### Rational perturbation estimate
You will likely need a generic lemma of the form:
```lean
theorem div_diff_bound
  {a b a' b' δ α β : ℝ}
  (hb : δ ≤ |b|) (hb' : δ ≤ |b'|) (hδ : 0 < δ)
  (ha : |a - a'| ≤ α) (hbdd : |b - b'| ≤ β) :
  |a / b - a' / b'| ≤ α / δ + |a'| * β / (δ * δ)
```
or a variant easier to prove in Lean.

This is likely where `field_simp` and a denominator lower-bound argument will matter.

### Nonvanishing hypotheses
Newton ratios are only stable where denominators do not approach zero. Make this explicit. This is mathematically correct and physically meaningful: near-degenerate or vanishing symmetric-polynomial sectors are precisely where perturbation theory breaks down.

### Monotonicity / positivity
Use `esymm_newton_inequality` from the catalog not just as a decorative citation, but as a source of:
- positivity/ordering constraints,
- upper bounds,
- and possible denominator controls in special regimes.

You should inspect whether the catalog theorem gives inequalities among adjacent `e_k` sufficient to derive boundedness of the ratio profile under nonnegativity assumptions.

---

## Computational / Algorithmic Deliverable

You must produce a **verified algorithm**, not just theorems.

### Required algorithm
Implement a function that computes a finite Newton-ratio profile and a certified perturbation envelope:

```lean
def computeNewtonProfile (p : Array ℝ) (K : ℕ) : Array ℝ := ...
def certifiedNewtonDeviationBound
  (p q : Array ℝ) (K : ℕ) : ℝ := ...
```

Specification target:

> If arrays `p` and `q` represent bounded nonnegative spectra and satisfy a sup-norm bound `ε`, then `certifiedNewtonDeviationBound p q K` returns a value `B` such that each Newton-ratio deviation up to level `K` is provably `≤ B`.

You may formalize the specification using list/array coercions into finite functions where needed. If full executable-real certification is awkward, use rationals `ℚ` or a verified upper-bound datatype.

This is crucial: the algorithm is the bridge from theorem to scientific test.

---

## demo.py Requirement

Create `demo.py` that:

1. Generates or loads small spectra for:
   - a mock free-fermion/Gaussian spectrum,
   - a perturbed interacting spectrum.
2. Computes Newton ratio profiles up to level `K`.
3. Displays:
   - the profiles,
   - their deviations,
   - and the certified theoretical upper bound.
4. Includes a **Hubbard-inspired weak-coupling experiment**:
   - either exact diagonalization data if available,
   - or a synthetic perturbative proxy `λ_i(U) = λ_i(0) + U δ_i` with positivity/normalization.
5. Produces a plot of deviation vs coupling strength `U`.

The demo should make the conjecture falsifiable: if the deviations do not scale linearly or vanish as `U → 0`, the user should see that immediately.

---

## Conjecture with Testable Prediction

You must explicitly state and discuss the following conjecture in the code comments and the paper:

> **Conjecture (Weak-coupling Newton universality).**  
> For half-filled finite Hubbard chains of length `L = 8, 10, 12`, for any fixed subsystem size and any fixed Newton level `k` below the rank cutoff, there exists `C_k(L)` such that
> \[
> |\mathrm{NR}_k(\lambda(U)) - \mathrm{NR}_k(\lambda(0))| \le C_k(L)\,|U|
> \]
> for all sufficiently small `U`, where `\lambda(U)` is the exact entanglement spectrum and `\lambda(0)` is the free-fermion spectrum.

### Testable prediction
For numerically computed spectra, the graph of
\[
\log |\mathrm{NR}_k(\lambda(U)) - \mathrm{NR}_k(\lambda(0))|
\]
versus `\log |U|` should have slope approximately `1` in the weak-coupling regime, unless a symmetry forces first-order cancellation.

This is falsifiable and scientifically meaningful.

---

## Cross-Domain Connections to Highlight

You must explicitly emphasize at least one theorem connecting different areas. Suitable bridges include:

- **Many-body quantum physics ↔ algebraic combinatorics**  
  Entanglement spectra are analyzed via elementary symmetric polynomials and Newton inequalities.

- **Perturbation theory ↔ finite symmetric function geometry**  
  Weak coupling induces controlled motion in the cone of nonnegative spectra, and Newton-ratio observables behave as rational coordinates on that cone.

- **Quantum matter ↔ algorithmic compression**  
  If Newton profiles are stable under interaction, then low-complexity surrogates for entanglement data may remain effective in weakly correlated regimes.

- **Statistical mechanics ↔ real algebraic geometry**  
  Approximate determinantal structure can be studied through semialgebraic inequalities among symmetric polynomials.

Do not present these as vague analogies. Tie them to specific formal statements.

---

## Application Keywords

Include these keywords in the paper and article:

- interacting fermions
- entanglement spectrum
- Newton inequalities
- elementary symmetric polynomials
- perturbation stability
- Gaussian states
- determinantal approximation
- Hubbard model
- area law
- algebraic compression
- many-body quantum physics
- combinatorial spectral invariants
- weak coupling universality
- certified numerical bounds

---

## Deliverables (ALL MANDATORY)

You must produce all of the following:

### (a) `FUTURE_DIRECTIONS.md`
Give **3–5 original research directions**. Each direction must include:
- a title,
- a paragraph,
- the exact sentence: **“The key insight is...”**
- the exact sentence: **“Why now?”**

At least one direction must bridge to a different domain, such as:
- random matrix theory,
- quantum chemistry,
- tropical geometry,
- complexity theory,
- or statistical inference.

### (b) `RESEARCH_PAPER.md`
A standalone scientific paper containing:
- motivation from interacting entanglement spectra,
- precise definitions,
- theorem statements,
- proof ideas,
- computational experiment design,
- significance and limitations,
- and next-step conjectures.

A reader with no access to the code must still understand the discovery.

### (c) `ARTICLE.md`
Write in **Scientific American style**:
- vivid and concept-driven,
- no focus on formal verification machinery,
- explain why a stable algebraic fingerprint of interacting quantum matter is surprising and important.

### (d) Verified algorithm / computational method
As described above: certified computation of Newton profiles and perturbation bounds.

### (e) `demo.py`
Interactive demonstration of the theorem and conjecture.

---

## Final Standard

The goal is not to say “weak perturbations preserve something.” The goal is to establish that **Newton hierarchy observables are robust enough to survive contact with interaction**. If you succeed, you will have transformed a free-fermion invariant into a candidate universal diagnostic for weakly correlated quantum matter.

That is not an incremental result. That is the opening move of a new algebraic theory of interacting entanglement.

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
