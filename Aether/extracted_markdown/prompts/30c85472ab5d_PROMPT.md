Soli Deo Gloria

## Assignment: Direction 2 — Non-Affine Eigenvalue Flows and Nonlinear Stability

**Mode:** `prove`

You are to turn the affine spectral stability principle into a genuinely nonlinear theory. The affine case says: if each eigenvalue branch has the form `θ_j(t) = a_j + b_j t`, then the stability radius is the first vanishing time. That is elegant — but it is not yet science. Real perturbation families in trust-region methods, polynomial homotopies, nonlinear elasticity, and parametric PDEs are not affine in the perturbation parameter. The breakthrough is to prove that the same “first spectral collision controls stability” paradigm survives for broad classes of **non-affine eigenvalue flows**.

The target is not a cosmetic generalization from linear to quadratic. The target is a new principle:

> **If instability can only arise when some eigenvalue branch crosses zero, then the nonlinear stability radius is exactly the earliest positive zero across all nontrivial branches, under verifiable sign/continuity hypotheses.**

This would open a formal theory of **nonlinear spectral phase transitions**.

---

## Core Mathematical Objective

Build on:

- `Catalog/Pythagorean/SchemeLorentzian/Theorems.lean`
  - `eigenvalue_neg_before_vanishing`
  - `eigenvalue_pos_after_vanishing`
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`
  - `lorentzian_stability_radius_exists`

and prove a nonlinear extension where the affine formula is replaced by a root-selection principle for continuous or polynomial eigenvalue branches.

The conceptual leap is this: in the affine theory, the root is explicit. In the nonlinear theory, the root is geometric. You must formalize the geometry of the **first zero crossing** and show that it still governs the loss of stability.

---

## New Definitions You Should Introduce

You must define at least one genuinely new concept. I recommend the following.

### 1. First positive root of a scalar flow
For `θ : ℝ → ℝ`, define the set of positive zeros and the first crossing time:
```lean
def positiveZeroSet (θ : ℝ → ℝ) : Set ℝ := {t | 0 < t ∧ θ t = 0}

def firstPositiveRoot (θ : ℝ → ℝ) : Prop :=
  ∃ r, 0 < r ∧ θ r = 0 ∧ ∀ s, 0 < s → θ s = 0 → r ≤ s
```
If you want an actual value rather than a proposition, define it via `sInf` under nonemptiness and bounded-below hypotheses.

### 2. Sign-crossing eigenvalue flow
A nonlinear analogue of the affine sign-change property:
```lean
structure SignCrossingFlow (θ : ℝ → ℝ) : Prop where
  continuous : Continuous θ
  neg_at_zero : θ 0 < 0
  eventually_pos : ∃ T > 0, 0 < θ T
```

### 3. Nonlinear spectral stability radius
For a family of eigenvalue branches `θ : ι → ℝ → ℝ`, define the candidate radius as the infimum of positive zeros:
```lean
def spectralRadiusCandidate (θ : ι → ℝ → ℝ) : Set ℝ :=
  {r | ∃ j, 0 < r ∧ θ j r = 0}
```
Then formulate the radius as `sInf` of this set when nonempty.

If the catalog already has a stability-radius object for the Lorentzian/Hessian setting, do not duplicate it; instead define a **non-affine branch witness structure** linking the abstract stability radius to branchwise root data.

---

## Precise Theorem Targets

You need at least 3 substantial theorems. Here is the right theorem package.

### Theorem 1: Existence of a first positive zero for a nonlinear branch
This is the atomic lemma replacing the affine closed-form root.

**Mathematical statement.**  
Let `θ : ℝ → ℝ` be continuous, with `θ 0 < 0`, and suppose `∃ T > 0, 0 < θ T`. Then there exists `r > 0` such that `θ r = 0`, and moreover there exists a minimal such positive root.

**Lean 4 target signature:**
```lean
theorem exists_first_positive_root_of_sign_change
    {θ : ℝ → ℝ}
    (hcont : Continuous θ)
    (hneg : θ 0 < 0)
    (hpos : ∃ T > 0, 0 < θ T) :
    ∃ r, 0 < r ∧ θ r = 0 ∧ ∀ s, 0 < s → θ s = 0 → r ≤ s := by
```

This theorem is the nonlinear replacement for the affine vanishing-time formula. It should use continuity, IVT, and an order/minimality argument on a bounded nonempty zero set.

### Theorem 2: Sign before and after the first root under monotonicity
You need a theorem that recovers the catalog’s affine sign lemmas in nonlinear form.

**Mathematical statement.**  
If `θ` is continuous and strictly monotone on `Ici 0`, and `r` is its first positive root, then `θ t < 0` for `0 ≤ t < r` and `θ t > 0` for `t > r`.

**Lean 4 target signature:**
```lean
theorem neg_before_first_root_pos_after_first_root
    {θ : ℝ → ℝ} {r : ℝ}
    (hcont : Continuous θ)
    (hmono : StrictMonoOn θ (Set.Ici 0))
    (hrpos : 0 < r)
    (hroot : θ r = 0)
    (hmin : ∀ s, 0 < s → θ s = 0 → r ≤ s) :
    ((∀ t, 0 ≤ t → t < r → θ t < 0) ∧
     (∀ t, r < t → 0 < θ t)) := by
```

This theorem is the conceptual hinge: the first root is not merely a zero, it is the **phase boundary**.

### Theorem 3: Stability radius equals the earliest branch root
This is the flagship theorem. State it abstractly enough to be provable with current catalog infrastructure, but concretely enough to matter.

You will likely need a hypothesis saying that the system is stable exactly when all eigenvalue branches are negative. If the catalog expresses this as a Hessian/Lorentzian criterion, instantiate it there. If not, formulate an abstract spectral criterion and then specialize.

**Abstract mathematical statement.**  
Let `θ : ι → ℝ → ℝ` be a finite family of continuous eigenvalue branches, each negative at `0`. Assume:
1. Stability at parameter `t` is equivalent to `∀ j, θ j t < 0`.
2. At least one branch becomes positive for some positive time.
3. Each branch has at most one positive zero, or is strictly monotone on `Ici 0`.

Then the stability radius equals the minimum positive zero among all branches.

**Lean 4 target signature (abstract finite-index version):**
```lean
theorem stability_radius_eq_min_first_root
    {ι : Type} [Fintype ι]
    (θ : ι → ℝ → ℝ)
    (hcont : ∀ j, Continuous (θ j))
    (hneg0 : ∀ j, θ j 0 < 0)
    (hmono : ∀ j, StrictMonoOn (θ j) (Set.Ici 0))
    (hstable :
      ∀ t, 0 ≤ t →
        (StableAt t ↔ ∀ j, θ j t < 0))
    (hcross : ∃ j T, 0 < T ∧ 0 < θ j T) :
    ∃ r, 0 < r ∧
      (¬ StableAt r) ∧
      (∀ t, 0 ≤ t → t < r → StableAt t) ∧
      (∃ j, θ j r = 0 ∧ ∀ s, 0 < s → θ j s = 0 → r ≤ s) := by
```

If `StableAt` is not already in the catalog, replace it by the actual Lorentzian/Hessian stability predicate from `LorentzianStability.lean`, and prove the corresponding concrete theorem there.

### Theorem 4: Polynomial branch specialization
You should also include a theorem specialized to quadratic or polynomial branches, because that makes the result computationally testable and bridges to numerical algebraic geometry.

A useful formal target is not “all polynomials” at first, but a quadratic branch with positive leading coefficient and monotonicity on `Ici 0`.

**Lean 4 target signature:**
```lean
theorem quadratic_branch_has_first_root_when_sign_changes
    {a b c : ℝ}
    (hneg : a < 0)
    (hmono : 0 ≤ b)
    (hconv : 0 < c) :
    ∃ r, 0 < r ∧
      (a + b * r + c * r^2 = 0) ∧
      ∀ t, 0 ≤ t → t < r → a + b * t + c * t^2 < 0 := by
```

This theorem will require real algebra, inequalities, and likely `field_simp`, `nlinarith`, and careful monotonicity arguments. It is not enough by itself, but it makes the nonlinear theory algorithmic.

---

## Why This Is a Breakthrough

The affine theory is a toy model of bifurcation. The nonlinear theory is where real systems live.

If you prove these theorems, you create a formal bridge between:

- **spectral stability theory** and **real root geometry**,
- **Lorentzian/Hessian negativity** and **polynomial homotopy continuation**,
- **optimization trust-region boundaries** and **eigenvalue collision times**,
- **nonlinear dynamics** and **certified phase transition detection**.

This opens the door to a field-level program: **formal bifurcation geometry via eigenvalue flows**. Once the radius is characterized as a first-root object, one can ask about multiplicity, tangential crossings, avoided crossings, stochastic perturbations, and tropical approximations of the root landscape.

---

## Proof Architecture: 3 Viable Strategies

You must include proof ideas in the file comments and exploit them deliberately.

### Strategy A: Continuity + order-theoretic minimal zero selection
1. For each branch `θ_j`, use continuity and the sign change `θ_j(0) < 0 < θ_j(T)` to obtain a zero in `(0,T)` by IVT.
2. Show the set of positive zeros in a compact interval is nonempty and closed; use `IsCompact` or completeness to obtain its minimum.
3. Use strict monotonicity to prove negativity before the minimum root and positivity after it.
4. Transfer branchwise sign information to the system stability predicate.

**Why promising:** This is the cleanest path and most faithful to the mathematics. It should integrate well with existing real-analysis lemmas in Mathlib.

### Strategy B: Infimum-of-instability times
1. Define the unstable set `U := {t > 0 | ¬ StableAt t}`.
2. Let `r = sInf U`, using `lorentzian_stability_radius_exists` as the existence backbone.
3. Prove that at `r`, some branch must satisfy `θ_j(r) = 0`; otherwise all branches remain negative by openness and `r` would not be the first instability time.
4. Use branch monotonicity to identify `r` with the minimum positive root over all branches.

**Why promising:** This uses the catalog’s stability-radius theorem directly and yields a conceptually strong proof: the radius is a phase-transition infimum, and zero-crossing is forced at the boundary.

### Strategy C: Polynomial specialization via derivative monotonicity
1. For quadratic/polynomial branches, prove monotonicity on `Ici 0` from derivative positivity or coefficient constraints.
2. Use sign at `0` and coercive positivity for large `t` to deduce existence of a unique positive root.
3. Push the abstract theorem through this specialization to obtain a concrete stability-radius formula.

**Why promising:** This is the route to algorithms and experiments. It turns the abstract theorem into something demonstrable in `demo.py`.

**Most promising overall:** Combine **Strategy B** for the flagship theorem with **Strategy A** for the branch lemmas and **Strategy C** for computational specialization. That gives a theory, a proof spine, and a verified algorithmic interface.

---

## How to Use the Catalog Results

Do not merely cite the catalog. Extend it.

- Use `eigenvalue_neg_before_vanishing` and `eigenvalue_pos_after_vanishing` as the affine archetype. Your nonlinear sign theorem should explicitly be presented as their conceptual generalization from explicit affine vanishing times to minimal positive roots.
- Use `lorentzian_stability_radius_exists` as the existence engine for the critical parameter. Then identify that parameter spectrally.
- If the catalog theorem already packages “stability until first vanishing” in affine form, factor your proof so that the nonlinear theorem reduces to the affine theorem when `θ_j(t) = a_j + b_j t`.

An especially strong result would be:

```lean
theorem affine_case_recovered_as_specialization
    {a b : ι → ℝ}
    (hbpos : ∀ j, 0 < b j)
    (haneg : ∀ j, a j < 0) :
    nonlinear_stability_radius ... = affine_stability_radius ... := by
```

This is not required, but it would certify that your new framework strictly contains the old one.

---

## Cross-Domain Connections You Must Highlight

At least one theorem and the accompanying prose must connect to another field.

### 1. Numerical algebraic geometry
The stability radius becomes the minimum positive real root among branch polynomials. This connects certified stability to root isolation, Sturm methods, Descartes’ rule, and homotopy continuation.

### 2. Optimization / trust-region methods
Quadratic and higher-order Hessian flows arise when following a curved path in parameter space. The first-root theorem predicts exactly when the local model ceases to be negative definite.

### 3. Dynamical systems / phase transitions
The first zero of an eigenvalue branch is a bifurcation threshold. Your theorem makes this rigorous in a broad nonlinear setting.

### 4. Mathematical physics
In parameter-dependent energy landscapes, the first vanishing mode marks the onset of instability, analogous to a soft mode in phase transitions.

You should explicitly include application keywords in the final documents:
**application keywords:** spectral bifurcation, trust-region optimization, polynomial homotopy continuation, soft-mode instability, phase transitions, root isolation, parametric Hessians, nonlinear eigenvalue flow, certified stability radius.

---

## Conjecture With Testable Prediction

You must state at least one falsifiable conjecture and provide a computational test.

### Conjecture: Unique-root monotone polynomial flow principle
Let `θ_j(t)` be polynomial eigenvalue branches with `θ_j(0) < 0` and strictly increasing on `Ici 0`. Then the system stability radius equals the minimum of their unique positive roots.

This is falsifiable: generate polynomial families, numerically compute branch roots, and compare against binary search for the smallest `t` where the assembled Hessian loses negative definiteness.

A stronger conjecture, if you dare:

> Even without global monotonicity, if every branch crosses zero transversely at its earliest positive root and no two branches have an earlier tangential touch, then the stability radius is still the minimum earliest positive root.

This is more revolutionary because it points beyond monotone flows into genuine bifurcation theory.

---

## Required Computational Deliverable

Produce a **verified algorithm or computational method**, not just theorems.

### Algorithm target
Implement a certified procedure for quadratic branch families:
1. Input coefficients `(a_j, b_j, c_j)` with `a_j < 0`, `b_j ≥ 0`, `c_j > 0`.
2. Compute the positive root
   \[
   r_j = \frac{-b_j + \sqrt{b_j^2 - 4 a_j c_j}}{2 c_j}
   \]
   when valid.
3. Return `ρ = min_j r_j`.
4. Numerically validate by binary search on the smallest `t` where some branch becomes nonnegative.

If possible, prove correctness of the symbolic root formula under your hypotheses.

### `demo.py`
Your demo must:
- generate random quadratic eigenvalue branches,
- plot the branch curves,
- compute predicted `ρ` from roots,
- compute observed instability threshold by search,
- display agreement or counterexample,
- include at least one interactive parameter slider or repeated random trials.

---

## Lean Tactics Expectations

The proofs must be nontrivial. Use:
- `rcases`
- `by_contra`
- `field_simp`
- `nlinarith`
- `linarith`
- `calc`
- interval/continuity reasoning
- compactness or infimum arguments
- induction if you formalize finite-family minimization recursively

Avoid degenerate theorem statements that collapse to `rfl`, `norm_num`, or finite enumeration.

A good file will contain:
- one theorem proved via IVT + `rcases`,
- one theorem proved via contradiction/open-neighborhood reasoning,
- one theorem proved via explicit quadratic algebra and `field_simp` / `nlinarith`.

---

## Concrete Formalization Guidance

A strong file structure would be:

1. **Definitions**
   - `positiveZeroSet`
   - `firstPositiveRoot`
   - `SignCrossingFlow`
   - optional `NonlinearSpectralFlow`

2. **Scalar branch lemmas**
   - existence of a positive zero
   - existence/minimality of first positive root
   - sign before/after first root under monotonicity

3. **Finite-family lemmas**
   - existence of a branch attaining minimal root
   - minimum-over-branches characterization

4. **Stability theorem**
   - abstract theorem linking branch negativity to stability
   - concrete specialization to Lorentzian/Hessian stability

5. **Polynomial specialization**
   - quadratic monotonicity
   - quadratic root theorem
   - algorithmic corollary

---

## Deliverables You Must Produce

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain:
- a sentence beginning with **“The key insight is...”**
- a sentence beginning with **“Why now?”**
At least one direction must bridge to a different domain, such as dynamical systems, numerical algebraic geometry, or mathematical physics.

Possible directions include:
- transverse vs tangential eigenvalue crossings,
- stochastic eigenvalue flows,
- tropical approximations to root-selection geometry,
- certified bifurcation detection in parametric optimization,
- multiparameter stability boundaries as discriminant varieties.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper. A reader with no access to code must understand:
- the nonlinear stability-radius problem,
- the exact theorems proved,
- why affine theory was insufficient,
- how the proof works,
- what computational tests were performed,
- what broader program this launches.

### 3. `ARTICLE.md`
Write in Scientific American style. Explain:
- why “the first vanishing mode” predicts instability,
- why nonlinear parameter dependence changes the game,
- where this matters in science and engineering.

**Taboo:** do not focus on formal verification machinery. Focus on the mathematics and its significance.

### 4. Verified algorithm or computational method
At minimum: certified quadratic-root-based stability radius computation with theorem-level correctness guarantees under explicit hypotheses.

### 5. `demo.py`
Interactive or semi-interactive demonstration of the theorem and conjecture.

---

## Final Ambition

Do not present this as “an extension of affine eigenvalue theory to quadratics.” That is too small.

Present it as the first step toward a formal theory of **nonlinear spectral thresholds**:
the moment when a stable regime ends is encoded not by the whole system at once, but by the earliest zero of a single scalar branch. If you can prove that cleanly and computationally, you have created a reusable theorem schema for optimization, bifurcation theory, and spectral geometry.

This is the right scale of result: mathematically clean, computationally testable, and conceptually expansive.

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
