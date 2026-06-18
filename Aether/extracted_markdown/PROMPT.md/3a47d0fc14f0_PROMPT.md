## Assignment: Direction 1: Sharp Constants in the Dimension-Degree Stability Law

Prove a genuinely new quantitative stability theorem for Lorentzian polynomials that breaks the current entrywise \(1/n^2\) barrier and isolates the true scaling law. Build directly on the catalog results in `Pythagorean/LorentzianStability.lean`, especially:

- `quadFormBound_of_entry_bound`
- `dimension_degree_stability_law_instance`

The goal is not a cosmetic sharpening. The goal is to identify the correct asymptotic mechanism: the present proof pays an \(n\)-factor because it converts entrywise control to spectral control too crudely. If the true geometry is governed by operator norm rather than worst-entry accumulation, then the right law should be \(C(n,d)=\Theta(1/n)\), and that would fundamentally change certified Lorentzian recognition from conservative to nearly optimal.

## Core Theorem Target

Let \(p\) be a homogeneous Lorentzian polynomial of degree \(d\) in \(n\) variables, and let \(H_p(x)\) denote the Hessian of \(p\) at a positive point \(x \in \mathbb{R}_{>0}^n\). Suppose \(p\) has Lorentzian margin \(\varepsilon>0\), meaning the relevant Hessian minors or quadratic forms are separated from the non-Lorentzian boundary by at least \(\varepsilon\). Let \(q\) be a coefficientwise perturbation of \(p\), with every coefficient changed by at most \(\delta\).

The breakthrough theorem to prove is:

\[
\forall n,d \ge 2,\ \exists A_d,B_d>0\ \text{such that}\ 
\frac{A_d}{n} \le C(n,d) \le \frac{B_d}{n},
\]
where \(C(n,d)\) is the optimal universal constant for which
\[
\delta \le C(n,d)\,\varepsilon \implies q \text{ remains Lorentzian}.
\]

A more formal finite-dimensional version, suitable for Lean, is:

\[
\exists K_d>0,\ \forall n\ge 2,\ \forall p,\ \forall \Delta,\ 
\bigl(\|\Delta\|_{\infty,\mathrm{coeff}} \le (K_d/n)\varepsilon_p\bigr)
\Rightarrow p+\Delta \text{ is Lorentzian}.
\]

This should be paired with a lower-bound construction showing the \(1/n\) scaling is asymptotically sharp: there exist Lorentzian families \(p_n\) and perturbations \(\Delta_n\) with \(\|\Delta_n\|_\infty \asymp \varepsilon_{p_n}/n\) that destroy Lorentzianity.

## Precise Lean 4 Formalization Targets

You should introduce at least one genuinely new definition capturing the improved stability mechanism. For example, define a coefficient perturbation radius controlled through an induced Hessian operator norm rather than raw entry summation.

Possible Lean-facing signatures:

```lean
def coeffSupNorm {σ : Type} [Fintype σ] (a : σ → ℝ) : ℝ :=
  Finset.sup Finset.univ (fun i => |a i|)

def spectralLiftBound (n d : ℕ) : ℝ :=
  -- new dimension-degree constant capturing entrywise-to-operator conversion
  sorry

def LorentzianMargin (p : MvPolynomial (Fin n) ℝ) : ℝ :=
  -- quantitative distance to failure of Lorentzianity
  sorry
```

Main theorem candidate:

```lean
theorem lorentzian_stability_linear_in_dimension
    (n d : ℕ) (hn : 2 ≤ n) (hd : 2 ≤ d)
    (p Δ : MvPolynomial (Fin n) ℝ)
    (hp_hom : p.IsHomogeneous d)
    (hp_lor : IsLorentzian p)
    (hmargin : 0 < LorentzianMargin p)
    (hpert :
      coeffSupNorm (fun m => Δ.coeff m)
        ≤ (spectralLiftBound n d / n) * LorentzianMargin p) :
    IsLorentzian (p + Δ) := by
  sorry
```

Asymptotic sharpness theorem candidate:

```lean
theorem exists_sharp_family_linear_dimension
    (d : ℕ) (hd : 2 ≤ d) :
    ∃ K₁ K₂ : ℝ, 0 < K₁ ∧ 0 < K₂ ∧
      ∀ n : ℕ, 2 ≤ n →
      ∃ p Δ : MvPolynomial (Fin n) ℝ,
        p.IsHomogeneous d ∧ IsLorentzian p ∧
        K₁ / n ≤ coeffSupNorm (fun m => Δ.coeff m) / LorentzianMargin p ∧
        coeffSupNorm (fun m => Δ.coeff m) / LorentzianMargin p ≤ K₂ / n ∧
        ¬ IsLorentzian (p + Δ) := by
  sorry
```

Cross-domain theorem target, connecting Lorentzian stability to spectral matrix theory:

```lean
theorem hessian_operator_norm_control_of_entrywise_bound
    (n : ℕ) (hn : 1 ≤ n)
    (A : Matrix (Fin n) (Fin n) ℝ) :
    ‖A‖ ≤ n * (Finset.sup Finset.univ (fun i =>
      Finset.sup Finset.univ (fun j => |A i j|)) : ℝ) := by
  sorry
```

But do not stop there: improve this crude deterministic inequality in a structured class relevant to Lorentzian Hessians, ideally replacing \(n\) by \(O(\sqrt n)\) or by a geometry-sensitive rank/support parameter. The whole point is to formalize why the previous \(1/n^2\) proof is not intrinsic.

## The New Mathematical Structure You Must Introduce

Define a new concept not already in the catalog, for example:

- `LorentzianMargin`: a quantitative distance-to-boundary invariant.
- `StructuredHessianPerturbation`: perturbations whose induced Hessians satisfy a support or correlation constraint.
- `EffectiveSpectralDimension`: a dimension surrogate controlling how coefficient perturbations amplify at the Hessian level.

A compelling option is:

```lean
structure StructuredHessianPerturbation (n : ℕ) where
  Δ : MvPolynomial (Fin n) ℝ
  entry_bound : ℝ
  support_degree : ℕ
  spectral_profile : ℝ
```

Then prove a theorem saying the stability radius depends on `spectral_profile` rather than ambient `n`. That would be a real conceptual leap: “dimension-degree stability” becomes “effective spectral complexity stability.”

## Three Theorems Minimum — With Deep Proof Tactics

Your file must contain at least 3 serious theorems with multi-step proofs. Suggested theorem suite:

1. **Operator-norm refinement theorem**
   - Improve the catalog’s entrywise Hessian bound by passing through structured operator estimates.
   - Proof should use `calc`, decomposition of Hessians, and nontrivial inequalities.

2. **Linear-in-\(1/n\) Lorentzian stability theorem**
   - Main result deriving preservation of Lorentzianity under coefficient perturbation of size \(O(\varepsilon/n)\).
   - Proof should use contradiction (`by_contra`), reduction to a minimal violating quadratic form, and Schur complement or eigenvalue comparison.

3. **Sharpness / obstruction theorem**
   - Construct a family (likely involving elementary symmetric polynomials \(e_k\)) showing the \(1/n\) rate cannot be improved to \(o(1/n)\).
   - Proof should use explicit coefficient analysis, `rcases`, and multi-step estimates.

A fourth theorem is strongly encouraged:

4. **Cross-domain random perturbation theorem**
   - Under random mean-zero symmetric coefficient perturbations, the failure threshold scales like \(1/\sqrt n\) in operator norm but still induces deterministic \(1/n\) coefficient stability after lifting.
   - This connects Lorentzian geometry to random matrix theory and high-dimensional probability.

## Proof Strategy Architecture

### Strategy A: Schur-complement refinement of the Hessian argument
Most promising.

1. Revisit the proof of `quadFormBound_of_entry_bound` and identify exactly where entrywise perturbations are summed with an \(n\)-loss.
2. Replace this by a Schur complement or Rayleigh quotient argument on the Lorentzian Hessian cone, showing only one “bad direction” matters and the rest are controlled by operator norm.
3. Prove that coefficient perturbation induces Hessian perturbation with operator norm \(\le K_d \cdot n \cdot \|\Delta\|_\infty\), not \(K_d \cdot n^2 \cdot \|\Delta\|_\infty\), yielding the improved \(1/n\) law.

Why this is strongest: it directly attacks the known source of slack in the current proof and is likely formalizable with available matrix tools.

### Strategy B: Effective spectral dimension instead of ambient dimension
Conceptually deeper.

1. Define an invariant measuring the number of Hessian directions that actually interact with a monomial perturbation.
2. Show the perturbation amplification is controlled by this invariant, which is \(O(n)\) for elementary symmetric families and often much smaller.
3. Deduce a generalized theorem:
   \[
   \delta \le \frac{K_d}{\mathrm{EffDim}(p)} \varepsilon \implies p+\Delta \text{ Lorentzian}.
   \]
   Then recover the \(1/n\) law as a corollary.

Why this matters: it would replace a dimension-only theorem by a structural theorem, opening a new classification program.

### Strategy C: Extremal-family analysis via \(e_k\) and symmetric representation theory
Best for sharpness and computational guidance.

1. Specialize to \(p=e_k(x_1,\dots,x_n)\), where the Hessian has large symmetry and can often be diagonalized into isotypic pieces.
2. Compute or bound the exact destruction threshold for perturbations in symmetric and antisymmetric directions.
3. Extract asymptotic constants and use them to conjecture the optimal universal \(C(n,d)\).

Why this matters: even if the full universal theorem is hard, this yields a decisive model case and a high-quality verified algorithm.

## Cross-Domain Connections You Must Exploit

This project must not remain isolated inside Lorentzian combinatorics. Build at least one theorem bridging to another domain.

### Numerical linear algebra
The improved constant is fundamentally about converting coefficientwise perturbation into spectral perturbation. This is an operator-theoretic problem disguised as algebraic combinatorics.

### High-dimensional probability
If random perturbations have spectral radius \(O(\sqrt n\,\delta)\) rather than \(O(n\delta)\), then typical-case stability is dramatically better than worst-case stability. Formalizing even a deterministic shadow of this phenomenon would be powerful.

### Convex optimization / hyperbolic programming
Lorentzian polynomials govern log-concavity and negative dependence; sharper perturbation radii mean more stable optimization certificates and more robust numerical recognition of hyperbolic cones.

### Statistical physics
Lorentzian and strongly log-concave generating polynomials appear in partition functions of interacting systems. Stability under perturbation translates into robustness of phase signatures under noisy couplings.

### Representation theory
For \(e_k\) and other symmetric families, \(S_n\)-symmetry may diagonalize the perturbation problem into a few irreducible modes. This can reveal the true extremizers.

## Computational Test and Falsifiable Conjecture

### Central conjecture
For each fixed degree \(d\ge 2\), there exist constants \(a_d,b_d>0\) such that for all \(n\ge d\),
\[
\frac{a_d}{n} \le C(n,d) \le \frac{b_d}{n}.
\]

### Stronger testable prediction
For the elementary symmetric polynomial \(e_k(x_1,\dots,x_n)\), the scaled threshold
\[
n \cdot C_{e_k}(n,k)
\]
converges as \(n\to\infty\) to a positive finite limit \(\lambda_k\).

This is falsifiable:
- If numerical experiments show \(n \cdot C_{e_k}(n,k)\to 0\), the linear law is false.
- If it grows unbounded, the current heuristic is incomplete.
- If it stabilizes, we likely have the correct asymptotic scaling and a concrete constant to target.

## Verified Algorithm Requirement

You must produce a verified computational method, not just theorem statements.

Target algorithm:
- Given \(n,d\), a homogeneous polynomial \(p\), and perturbation direction \(\Delta\),
- compute a certified lower bound for the maximal \(t\ge 0\) such that \(p+t\Delta\) remains Lorentzian,
- using Hessian eigenvalue margins, Schur complements, or a verified bisection procedure.

This should be formalized as a correctness theorem: if the algorithm outputs \(t_0\), then for all \(0\le t\le t_0\), \(p+t\Delta\) is certified Lorentzian.

A candidate Lean theorem:

```lean
theorem certified_lorentzian_radius_correct
    (n d : ℕ) (p Δ : MvPolynomial (Fin n) ℝ)
    (t0 : ℝ)
    (hcert : t0 ≤ certifiedLorentzianRadius p Δ) :
    ∀ t : ℝ, 0 ≤ t → t ≤ t0 → IsLorentzian (p + C t • Δ) := by
  sorry
```

## demo.py Expectations

Your `demo.py` must:
1. Compute numerical destruction thresholds for \(e_k(x_1,\dots,x_n)\) for \(n \le 20\), \(k \le 10\).
2. Plot \(n \cdot C(n,k)\) against \(n\) for several fixed \(k\).
3. Compare:
   - current catalog \(1/n^2\) certified bound,
   - your improved \(1/n\) certified bound,
   - observed numerical threshold.
4. Include at least one adversarial perturbation and one random perturbation.
5. Print explicit candidate asymptotic constants.

## Application Keywords

Lorentzian polynomials; strong log-concavity; hyperbolic optimization; spectral perturbation theory; Schur complements; random matrix theory; matrix concentration; certified numerical algebra; negative dependence; partition functions; combinatorial Hodge theory; representation stability.

## Why This Would Be a Breakthrough

Right now the theory says Lorentzianity is stable, but with constants too weak to match computation. That leaves open whether the theorem captures the real geometry or just a proof artifact. If you prove the \(1/n\) law, you do three things at once:

1. **You identify the correct perturbative geometry of the Lorentzian cone.**
2. **You make certified recognition practically competitive with numerical heuristics.**
3. **You expose a new bridge between algebraic log-concavity and operator norm phenomena.**

This would not be an incremental refinement. It would convert a qualitative stability theorem into a sharp quantitative theory with algorithmic consequences. It would open the door to:
- near-optimal certified testing of Lorentzianity,
- stability theory for hyperbolic and strongly log-concave structures,
- random perturbation models for combinatorial partition functions,
- effective robustness guarantees in optimization and statistical physics.

## Mandatory Deliverables

You must produce ALL of the following:

1. **Lean file(s)** with at least 3 substantial theorems, deep proofs, and at least one novel definition.
2. **A verified algorithm or computational method** for certified perturbation radii.
3. **`demo.py`** demonstrating the thresholds interactively and visually.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper explaining the theorem, proof ideas, computational evidence, significance, and next questions.
5. **`ARTICLE.md`** in Scientific American style, accessible and engaging, focused on the mathematics and its significance — not on formal verification.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions. Each direction must include:
   - a sentence beginning **“The key insight is...”**
   - a sentence beginning **“Why now?”**
   At least one direction must bridge to a different domain.

## Final Charge

Do not merely shave constants. Discover the mechanism. The current \(1/n^2\) law is almost certainly the shadow of a sharper operator-theoretic truth. Find that truth, formalize it, and turn Lorentzian stability from a conservative existence theorem into a sharp quantitative science.

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
