Soli Deo Gloria

## Assignment: Direction 2: Lee–Yang Zero Stability Under Coupling Noise

**Mode:** `prove`

Prove a genuinely new theorem package connecting **Lorentzian / half-plane-stable polynomials**, **Lee–Yang zeros for Ising partition functions**, and **quantitative root perturbation theory**. This should not be a cosmetic extension of existing Lee–Yang results: the target is a **first quantitative stability theorem** saying that when the coupling data varies inside a gapped Lorentzian regime, the Lee–Yang zero set of the univariate field polynomial moves in a controlled way.

The field-opening goal is to create a formal bridge between:
- combinatorial Hodge theory / Lorentzian polynomials,
- statistical mechanics of phase transitions,
- complex-analytic root perturbation,
- and algorithmic certification of zero motion under noisy couplings.

If successful, this opens a new program: **certified phase-transition stability under structured disorder**.

---

## Core mathematical target

Let `n : ℕ`, and let `J, ΔJ : Fin n → Fin n → ℝ` be symmetric coupling matrices with zero diagonal. Define the ferromagnetic Ising partition polynomial in the field variable `z = exp (β h)` by
\[
Z_J(z)
=
\sum_{\sigma \in \{\pm 1\}^n}
\exp\!\Big(\beta \sum_{i<j} J_{ij}\sigma_i\sigma_j\Big)\,
z^{N_+(\sigma)},
\]
where `N_+(σ)` is the number of `+1` spins. Equivalently,
\[
Z_J(z)=\sum_{k=0}^n a_k(J)\, z^k
\]
with positive coefficients `a_k(J)`.

Your task is to formalize a robust version of the following theorem schema.

### Precise theorem statement

Assume:

1. `J` lies in a **gapped Lorentzian coupling class** ensuring the associated multiaffine partition polynomial has the half-plane property / Lorentzian signature;
2. `J' = J + ΔJ` is another coupling matrix in the same class;
3. `‖ΔJ‖∞ ≤ δ`;
4. there is a **zero separation scale** `η > 0` for `Z_J`, meaning each root `ζ` of `Z_J` is isolated by a circle on which `|Z_J|` dominates the perturbation;
5. coefficient perturbations satisfy a quantitative bound
   \[
   |a_k(J')-a_k(J)| \le C_0(\beta,n,J)\,\delta
   \quad \text{for all }k.
   \]

Then each root `ζ` of `Z_J` admits a root `ζ'` of `Z_{J'}` with
\[
|ζ'-ζ| \le C(\beta,n,J,\eta)\,\delta.
\]
Under a uniform combinatorial estimate derived from the covariance/log-Lipschitz input, you should sharpen this to a bound of the form
\[
|ζ'-ζ| \le C \,\beta\, n^2\, \delta.
\]

This is the theorem the brief is aiming at. If the full sharp `O(β n² δ)` statement is too ambitious in one pass, prove a two-stage result:

- **Stage A:** coefficient Lipschitz bound for the Lee–Yang polynomial under coupling perturbation;
- **Stage B:** root displacement bound under a quantitative root-separation hypothesis.

That two-step theorem is already significant.

---

## Lean 4 formalization targets

You should introduce a mathematically meaningful new definition capturing the noisy-coupling stability regime.

### New definitions to create

1. **Gapped Lorentzian couplings**
```lean
structure GappedLorentzianCoupling (n : ℕ) where
  J : Fin n → Fin n → ℝ
  symm : Symmetric J
  diag_zero : ∀ i, J i i = 0
  gap : ℝ
  gap_pos : 0 < gap
  lorentzian_cert : Prop
```

2. **Coefficientwise perturbation control**
```lean
def coeffLipschitzBound
    {n : ℕ}
    (β : ℝ)
    (J J' : Fin n → Fin n → ℝ)
    (C : ℝ) : Prop :=
  ∀ k : Fin (n + 1),
    ‖isingFieldPolyCoeff β J k - isingFieldPolyCoeff β J' k‖ ≤ C * couplingDist J J'
```

3. **Root matching within radius**
```lean
def RootsMatchedWithin
    (p q : Polynomial ℂ) (R : ℝ) : Prop :=
  ∀ z : ℂ, z ∈ p.roots.toFinset →
    ∃ w : ℂ, w ∈ q.roots.toFinset ∧ ‖w - z‖ ≤ R
```

4. **Lee–Yang stability radius**
```lean
def leeYangStabilityRadius
    (p : Polynomial ℂ) (z : ℂ) : ℝ := ...
```
This should encode a quantitative Rouché-style isolation radius, or at minimum a certified radius derived from a lower bound of `‖p w‖` on a circle around `z`.

These definitions are not bureaucratic; they are the conceptual heart of the project.

---

## Exact theorem package to aim for

At least **3 substantial theorems**, each with real proof architecture.

### Theorem 1: coefficient perturbation under coupling noise
Formalize a theorem of the following shape:

```lean
theorem isingFieldPolyCoeff_lipschitz_of_coupling_sup_bound
    {n : ℕ} {β δ : ℝ}
    (hβ : 0 ≤ β) (hδ : 0 ≤ δ)
    (J J' : Fin n → Fin n → ℝ)
    (hJ : Symmetric J) (hJ' : Symmetric J')
    (hdiag : ∀ i, J i i = 0)
    (hdiag' : ∀ i, J' i i = 0)
    (hclose : couplingDist J J' ≤ δ) :
    ∃ C : ℝ, 0 ≤ C ∧
      ∀ k : Fin (n + 1),
        ‖isingFieldPolyCoeff β J k - isingFieldPolyCoeff β J' k‖
          ≤ C * β * (n : ℝ)^2 * δ
```

**Meaning:** changing couplings by `δ` changes each coefficient by at most `O(β n² δ)`.

This theorem is the quantitative engine. It is where you should use multi-step estimates, finite sums over spin configurations, and Lipschitz control of the exponential.

---

### Theorem 2: quantitative root stability from coefficient perturbation
A robust complex-analysis/algebra theorem:

```lean
theorem roots_matchedWithin_of_coeff_perturbation_and_separation
    (p q : Polynomial ℂ)
    (R m : ℝ)
    (hR : 0 < R) (hm : 0 < m)
    (hsep : ∀ z : ℂ, z ∈ p.roots.toFinset →
      ∀ w : ℂ, ‖w - z‖ = R → m ≤ ‖eval w p‖)
    (hsmall : ∀ w : ℂ, ‖q.eval w - p.eval w‖ < m) :
    RootsMatchedWithin p q R
```

If direct use of `Polynomial.roots` is technically awkward, reformulate via existential root neighborhoods or counting roots with multiplicity inside discs. A localized theorem is acceptable if it is precise.

**Meaning:** this is the Rouché-theoretic bridge from coefficient stability to zero stability.

---

### Theorem 3: Lee–Yang zero stability under gapped Lorentzian perturbation
The flagship theorem:

```lean
theorem leeYang_roots_stable_of_gapped_lorentzian_noise
    {n : ℕ} {β δ : ℝ}
    (hβ : 0 < β) (hδ : 0 ≤ δ)
    (K K' : GappedLorentzianCoupling n)
    (hclose : couplingDist K.J K'.J ≤ δ)
    (hstable : leeYangSeparationHypothesis β K)
    (hcoeff : coeffLipschitzBound β K.J K'.J C) :
    RootsMatchedWithin
      (isingFieldPoly β K.J)
      (isingFieldPoly β K'.J)
      (C' * β * (n : ℝ)^2 * δ)
```

If needed, split this into:
- a theorem giving root matching for sufficiently small `δ`,
- and a corollary with explicit radius `C' * β * n^2 * δ`.

This is the breakthrough statement.

---

## Stronger speculative theorem to attempt if the machinery lands

If your formal development goes well, try to prove a **unit-circle persistence theorem** under ferromagnetic perturbations:

```lean
theorem leeYang_unitCircle_persistence_under_small_ferromagnetic_noise
    {n : ℕ} {β δ : ℝ}
    (hβ : 0 < β)
    (K K' : GappedLorentzianCoupling n)
    (hferro : ∀ i j, 0 ≤ K.J i j)
    (hferro' : ∀ i j, 0 ≤ K'.J i j)
    (hclose : couplingDist K.J K'.J ≤ δ)
    (hsmall : δ ≤ ε β n K) :
    ∀ z : ℂ, z ∈ (isingFieldPoly β K'.J).roots.toFinset → ‖z‖ = 1
```

Even a weaker “roots remain in an annulus `1-ε ≤ ‖z‖ ≤ 1+ε`” theorem would be important.

---

## Proof strategy architecture

You must not just “express the partition function as a polynomial.” Build one of the following proof pathways.

### Strategy A: coefficient-Lipschitz + Rouché + root matching
**Most promising.**

1. **Coefficient perturbation bound.**
   Write each coefficient `a_k(J)` as a finite sum over spin configurations with exactly `k` plus spins. For each configuration,
   \[
   \exp(\beta E_J(\sigma)) - \exp(\beta E_{J'}(\sigma))
   \]
   is bounded using the mean value theorem / exponential Lipschitz estimate:
   \[
   |e^x - e^y| \le e^{\max(x,y)} |x-y|.
   \]
   Then bound
   \[
   |E_J(\sigma)-E_{J'}(\sigma)| \le \binom{n}{2}\delta \le \tfrac12 n^2\delta.
   \]
   This yields the `O(β n² δ)` coefficient perturbation.

2. **Pass from coefficients to polynomial perturbation on circles.**
   On a circle `|w-z|=R`,
   \[
   |(Z_{J'}-Z_J)(w)| \le \sum_k |a_k(J')-a_k(J)|\,|w|^k.
   \]
   Use the coefficient bound and finite geometric estimates to dominate the perturbation by a quantity `< m`.

3. **Apply a Rouché-style argument.**
   If `|Z_{J'}-Z_J| < |Z_J|` on the circle around a simple root `ζ`, then the perturbed polynomial has exactly one root inside. Convert this to a root-displacement bound.

**Why this is best:** it converts the statistical mechanics input into a finite-dimensional analytic estimate and is likely the most Lean-friendly.

---

### Strategy B: half-plane property / Lorentzian stability route
1. Use catalog Lorentzian stability results, especially `reversed_cauchy_schwarz_of_gapped`, to certify that the multivariate partition polynomial remains in a controlled stable class under perturbation.
2. Show the Lee–Yang univariate specialization inherits this stable geometry.
3. Use stability of hyperbolic / Lorentzian cones to derive zero confinement and then quantitative displacement.

**Why it matters:** this route would produce a conceptually deeper theorem, tying zero stability directly to Lorentzian geometry rather than only coefficient estimates.

**Why it is harder:** Lean support for multivariate stable-polynomial technology may be thinner than for finite sums and univariate root estimates.

---

### Strategy C: logarithmic derivative / susceptibility control
1. Differentiate `log Z_J(z)` with respect to coupling parameters `J_ij`.
2. Express the derivative via correlation observables or covariance identities (the brief references Theorem 3.6).
3. Integrate the logarithmic derivative along the perturbation path `J_t = J + tΔJ` to control motion of simple zeros by the implicit-function formula:
   \[
   \dot ζ(t) = - \frac{\partial_t Z_{J_t}(ζ(t))}{Z_{J_t}'(ζ(t))}.
   \]
4. Bound numerator by covariance/log-Lipschitz input and denominator by zero-separation.

**Why this is powerful:** it gives a dynamical interpretation of zero motion and may be the route to sharper constants.

**Why it is risky:** it requires more analytic machinery about differentiating roots along parameterized families.

---

## How to use the catalog

You explicitly cited:

- `Catalog/Pythagorean/LorentzianSharpStability.lean`
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`
  with `reversed_cauchy_schwarz_of_gapped`

Use them as follows:

1. **Extract the exact gap hypothesis** already formalized there.
   Do not paraphrase “gapped Lorentzian” if the catalog already has a stronger usable condition. Wrap it into your `GappedLorentzianCoupling` structure.

2. **Leverage `reversed_cauchy_schwarz_of_gapped`** to derive quantitative lower bounds controlling degeneration. The conceptual use is:
   - a Lorentzian gap prevents collapse of the stable cone,
   - which in turn should yield a lower bound on polynomial magnitude away from roots or on derivative size at simple roots,
   - which is exactly what a Rouché/implicit-root argument needs.

3. **Cross-link with any existing sharp stability inequalities** in `LorentzianSharpStability.lean`.
   If those theorems control how a hyperbolic or Lorentzian form changes under perturbation, use them to define or estimate your separation parameter `η`.

Do not merely cite these files; import and exploit them structurally.

---

## Cross-domain theorem requirement

You must include at least one theorem that explicitly bridges to another domain.

### Recommended bridge: statistical mechanics ↔ spectral / matrix analysis
Define the coupling matrix norm and prove a theorem of the form:

```lean
theorem energy_perturbation_bound_of_operator_norm
    {n : ℕ} (J J' : Fin n → Fin n → ℝ) :
    ∀ σ : Fin n → ℝ,
      (∀ i, σ i = 1 ∨ σ i = -1) →
      ‖spinEnergy J σ - spinEnergy J' σ‖
        ≤ (n : ℝ) * ‖J - J'‖op
```

or a sup-norm variant if operator norm is too heavy.

**Why this matters:** it links root stability in phase transitions to matrix perturbation theory and opens a route to random matrix disorder models.

Other acceptable bridges:
- complex analysis + combinatorics,
- Lorentzian geometry + probability,
- statistical physics + control theory.

---

## Conjecture with testable prediction

State at least one falsifiable conjecture in the Lean file as a comment block and in the paper.

### Conjecture A: sharp displacement scaling
For Curie–Weiss / complete graph Ising couplings `K_n`, the maximal Lee–Yang zero displacement under symmetric perturbation `‖ΔJ‖∞ ≤ δ` satisfies
\[
\max_j |\zeta_j(J+\Delta J)-\zeta_j(J)| \le C \beta n \delta
\]
for ferromagnetic perturbations, improving the generic `n²` factor to `n`.

**Testable prediction:** compute zeros for `n ∈ {4,6,8,10}` and fit displacement against `β n δ` versus `β n² δ`; the better collapse falsifies one scaling law.

### Conjecture B: annular confinement under noisy ferromagnetism
For sufficiently small ferromagnetic perturbations, all Lee–Yang zeros remain in
\[
1-\varepsilon \le |\zeta| \le 1+\varepsilon,
\qquad \varepsilon = O(\beta n^2 \delta).
\]
A computational counterexample would immediately disprove this.

These are good science because they can fail.

---

## Algorithmic deliverable

You must produce a **verified computational method**, not just theorems.

### Required algorithm
Implement a function that:
1. builds `Z_J(z)` for finite `n`,
2. computes or approximates its complex roots,
3. perturbs `J` by a user-specified `δ`,
4. matches old and new roots by nearest-neighbor or optimal matching,
5. reports the maximal displacement and compares it to `β n² δ`.

In Lean, formalize at least the exact polynomial construction and the coefficient bound it relies on. In Python, perform the numerical root computation.

Suggested interface:
```python
def lee_yang_zero_stability_demo(n, beta, delta, trials=20):
    ...
```

---

## demo.py requirements

Your `demo.py` must:
- generate `K_n` / Curie–Weiss couplings,
- apply symmetric random perturbations of magnitude `δ`,
- compute zeros of `Z_J(z)`,
- plot zero clouds before/after perturbation,
- plot `max displacement / (β n² δ)` versus `n`,
- test whether zeros stay near the unit circle,
- print clear verdicts on the conjectured scaling.

If possible, include an interactive slider for `β`, `n`, and `δ`.

---

## Lean proof expectations

The file must contain at least 3 theorems with nontrivial proofs using tactics like:
- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`

Recommended places to use them:
- induction over finite spin subsets / coefficient decomposition,
- `rcases` on membership in finite sums or root neighborhoods,
- `by_contra` in a separation or uniqueness-of-matched-root lemma,
- `field_simp` in rational expressions involving logarithmic derivatives,
- long `calc` chains for perturbation inequalities.

Avoid toy lemmas whose proofs collapse to `simp`.

---

## Application keywords

Include these explicitly in your paper and article:

**Application keywords:** phase transitions, disordered systems, Lee–Yang zeros, Lorentzian polynomials, half-plane property, root perturbation, complex stability, Ising model, combinatorial Hodge theory, certified numerical analysis, spectral perturbation, statistical mechanics.

---

## Deliverables (ALL mandatory)

1. **Lean file(s)** with the new definitions and at least 3 deep theorems.
2. **FUTURE_DIRECTIONS.md** with 3–5 original research directions.  
   Each direction must include the sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain.
3. **RESEARCH_PAPER.md** as a standalone scientific paper:
   - problem statement,
   - theorem statements,
   - proof ideas,
   - computational experiments,
   - significance,
   - limitations,
   - next questions.
4. **ARTICLE.md** in Scientific American style:
   - engaging and idea-centered,
   - explain why zero stability matters for phase transitions,
   - do **not** focus on formal verification machinery.
5. **Verified algorithm / computational method** for constructing the field polynomial and bounding perturbation effects.
6. **demo.py** implementing the numerical experiments and visualizations.

---

## Final call to arms

Do not settle for “Lee–Yang zeros remain roots of a polynomial with perturbed coefficients.” That is bookkeeping. The real theorem is: **structured disorder does not arbitrarily scramble the analytic skeleton of a phase transition**. Formalize that skeleton. Use the Lorentzian gap to prevent catastrophic degeneration, use coefficient control to quantify the noise, and use complex analysis to track the zeros themselves.

If you can make this precise, you are not just proving another Ising lemma. You are creating a rigorous language for **stability of critical phenomena under disorder**.

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
