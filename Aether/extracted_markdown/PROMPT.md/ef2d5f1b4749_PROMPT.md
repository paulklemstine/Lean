## Assignment: Direction 3: Large Deviation Principles for Stopping-Time Distributions

**Mode**: `prove`

Prove a genuinely new theorem that turns the existing “free energy” bounds into a bona fide probabilistic variational principle for arithmetic dynamics. The goal is not to restate asymptotic growth estimates, but to formalize a mathematically sharp bridge:

- **arithmetic stopping times**
- **thermodynamic free energy**
- **Legendre duality**
- **large deviation upper/lower bounds**

This is the kind of theorem that converts a heuristic statistical-mechanics analogy into a reusable formal machine.

---

## Breakthrough Objective

Let `τ : ℕ → ℝ` be a stopping-time observable on positive integers, and define the empirical measures
\[
\mu_N := \frac1N \sum_{n=1}^N \delta_{\tau(n)/\log(n+1)}.
\]
The visionary target is to show that if the exponential moments of `τ` admit a limiting free-energy density, then deviations of `τ(n)/\log(n+1)` are governed by the **Legendre–Fenchel transform** of that density.

This would be a breakthrough because it would establish, inside Lean, a rigorous **thermodynamic formalism for arithmetic stopping-time statistics**. Once formalized, this becomes a blueprint for:

- Collatz-like stopping-time models
- algorithmic runtime distributions
- arithmetic dynamical systems
- complexity-theoretic phase transitions
- entropy/free-energy duality in discrete mathematics

This is not “another bound.” This is the emergence of a **rate-function calculus** for arithmetic observables.

---

## Precise Theorem Target

There are two levels. You should aim to formalize the first completely, and push toward the second if the analytic infrastructure is available.

### Theorem A: Weak large-deviation upper/lower bounds from limiting log-mgf

Assume:
1. `τ : ℕ → ℝ`
2. the scaled log-moment generating function
   \[
   \Lambda(\theta) := \lim_{N\to\infty} \frac{1}{\log(N+1)}
   \log\Big(\frac1N \sum_{n=1}^N e^{\theta \tau(n)}\Big)
   \]
   exists for all `θ` in some interval around `0`
3. `Λ` is convex and lower semicontinuous
4. the normalization by `log(n+1)` is compatible with the scaling above

Define the candidate rate function
\[
I(x) := \sup_{\theta \in \mathbb R} \big(\theta x - \Lambda(\theta)\big).
\]

Then prove the **large deviation upper bound for closed sets** and **lower bound for open sets** for the empirical one-point distributions of `τ(n)/\log(n+1)`:
\[
\limsup_{N\to\infty} \frac{1}{\log(N+1)}
\log \frac{1}{N}\#\{1\le n\le N : \tau(n)/\log(n+1)\in C\}
\le -\inf_{x\in C} I(x)
\]
for closed `C`, and
\[
\liminf_{N\to\infty} \frac{1}{\log(N+1)}
\log \frac{1}{N}\#\{1\le n\le N : \tau(n)/\log(n+1)\in G\}
\ge -\inf_{x\in G} I(x)
\]
for open `G`, under the differentiability / essential smoothness hypotheses needed for the lower bound.

### Lean-oriented theorem skeleton

A realistic Lean target is to package this first for interval events.

```lean
def empiricalProb (τ : ℕ → ℝ) (N : ℕ) (s : Set ℝ) : ℝ :=
  ((Finset.range N.succ).filter (fun n => τ n / Real.log (n + 2) ∈ s)).card / (N + 1)

def logMGF (τ : ℕ → ℝ) (N : ℕ) (θ : ℝ) : ℝ :=
  (Real.log
    (((Finset.range N.succ).sum (fun n => Real.exp (θ * τ n))) / (N + 1))) /
  Real.log (N + 2)

def rateFunction (Λ : ℝ → ℝ) (x : ℝ) : ℝ :=
  sSup {r : ℝ | ∃ θ : ℝ, r = θ * x - Λ θ}
```

Then target a theorem of the following shape:

```lean
theorem ldp_upper_closed_interval
    (τ : ℕ → ℝ)
    (Λ : ℝ → ℝ)
    (hΛ :
      ∀ θ : ℝ, Tendsto (fun N : ℕ => logMGF τ N θ) atTop (𝓝 (Λ θ)))
    (hconv : Convex ℝ (Set.univ : Set ℝ) Λ)
    (hlsc : LowerSemicontinuous Λ)
    {a b : ℝ} (hab : a ≤ b) :
    Filter.limsup (fun N : ℕ =>
      Real.log (empiricalProb τ N (Set.Icc a b)) / Real.log (N + 2))
    Filter.atTop ≤
      - sInf (rateFunction Λ '' (Set.Icc a b)) := by
  sorry
```

This exact signature may need adjustment depending on available `limsup` API and whether `empiricalProb` is better valued in `ENNReal` or `ℝ`. But this is the right mathematical shape.

---

## Stronger Theorem B: Free-energy duality for stopping times

If you can connect the limiting free energy
\[
F(\gamma) := \lim_{N\to\infty}\frac{1}{\log(N+1)}
\log \Big(\frac1N\sum_{n\le N}\gamma^{\tau(n)}\Big)
\]
for `γ > 0` with `Λ(θ)=F(e^\theta)`, then prove explicitly:
\[
I(x)=\sup_{\gamma>0}\big((\log \gamma)x - F(\gamma)\big).
\]

### Lean signature target

```lean
theorem rateFunction_eq_sup_log_gamma
    (F : ℝ → ℝ) (Λ : ℝ → ℝ)
    (hFΛ : ∀ θ : ℝ, Λ θ = F (Real.exp θ)) :
    ∀ x : ℝ,
      rateFunction Λ x =
        sSup {r : ℝ | ∃ γ : ℝ, 0 < γ ∧ r = Real.log γ * x - F γ} := by
  sorry
```

This theorem is conceptually decisive: it says the arithmetic free energy already contains the full rare-event geometry.

---

## Why This Is Revolutionary

Existing verified theorems such as

- `free_energy_lower_bound`
- `free_energy_ritt_bound`
- `free_energy_bounds`
- `free_energy_upper_bound`
- `ThermoComp.strict_closure_growth_implies_positive_energy`

suggest a thermodynamic layer already exists in the catalog. But these results remain at the level of inequalities and positivity phenomena. Your task is to **upgrade free energy from a scalar summary to a generator of a complete fluctuation theory**.

That changes the field.

It would mean arithmetic learning theory is no longer merely using thermodynamic metaphors; it has a formal mechanism for deriving:

- typical behavior from first derivatives of free energy
- fluctuation scales from second derivatives
- rare-event asymptotics from Legendre duality
- phase transitions from non-differentiability of `Λ`

This opens a path toward a rigorous arithmetic analogue of equilibrium statistical mechanics.

---

## How to Build on Catalog Theorems

Use the existing free-energy results not as endpoints, but as **control hypotheses**.

1. **`free_energy_lower_bound`**  
   Use this to ensure the limiting free energy is not `-∞` or degenerate. In large deviations, a trivial mgf limit produces a useless rate function. A lower bound helps prove the rate function is proper.

2. **`free_energy_upper_bound` and `free_energy_bounds`**  
   These are likely the core coercivity tools. They can give local boundedness of `F` / `Λ`, which is exactly what one needs for convex-analytic arguments and to prevent pathological suprema in the Legendre transform.

3. **`free_energy_ritt_bound`**  
   If this theorem controls growth under compositional or dynamical complexity, use it to justify the existence of `Λ` on a nontrivial interval, or at least to prove one-sided finiteness needed for a weak Gärtner–Ellis framework.

4. **`ThermoComp.strict_closure_growth_implies_positive_energy`**  
   This is the philosophical bridge to phase structure. Positive energy should imply a nontrivial rate function with a unique minimizer away from pathological collapse. If formalized carefully, it may give a criterion for `I(x)` to be nonzero off the equilibrium mean.

---

## Proof Strategy Architecture

You must provide at least two proof routes in the development, and choose the one most compatible with Mathlib.

### Strategy A: Convex-analytic Gärtner–Ellis route
This is the most promising route.

**Step 1.** Define finite-volume log-mgfs and prove convexity at each `N`:
\[
\theta \mapsto \frac{1}{\log(N+1)}\log\Big(\frac1N\sum_{n\le N}e^{\theta\tau(n)}\Big)
\]
is convex by Hölder / log-sum-exp convexity.

**Step 2.** Pass convexity to the pointwise limit `Λ`, prove lower semicontinuity, and define `I` as the Legendre–Fenchel transform.

**Step 3.** Prove Chernoff upper bounds for interval events:
\[
\mu_N([a,\infty)) \le \exp\big(-\log(N+1)\sup_{\theta\ge0}(\theta a-\Lambda_N(\theta))\big).
\]
Then pass to the limit to obtain the upper bound.

**Step 4.** For the lower bound, assume differentiability of `Λ` on an open interval and use the exposed-point version of Gärtner–Ellis: if `x = Λ'(θ)`, then neighborhoods of `x` have asymptotic exponent `-I(x)`.

**Why this is best:** it requires only convexity, exponential moments, and standard asymptotic manipulations. It aligns naturally with the existing free-energy catalog.

---

### Strategy B: Subadditive / supermultiplicative thermodynamic formalism
Use this if the stopping time arises from a compositional arithmetic dynamics with hidden concatenation structure.

**Step 1.** Define partition sums
\[
Z_N(\theta)=\sum_{n\le N} e^{\theta \tau(n)}.
\]
Try to prove quasi-multiplicative inequalities of the form
\[
Z_{MN}(\theta)\le C(\theta)\, Z_M(\theta) Z_N(\theta)
\quad\text{or}\quad
\log Z_{MN}(\theta)\le \log Z_M(\theta)+\log Z_N(\theta)+O(1).
\]

**Step 2.** Apply Fekete-type arguments to deduce existence of the free-energy density.

**Step 3.** Derive the LDP upper bound from the partition-function asymptotics.

**Why it matters:** if successful, this route gives a deeper structural theorem: large deviations emerge from arithmetic compositionality, not merely from abstract convex analysis.

---

### Strategy C: Entropic variational principle via tilted empirical measures
This is the most conceptually ambitious.

**Step 1.** Define tilted weights
\[
\nu_{N,\theta}(n) \propto e^{\theta \tau(n)}.
\]

**Step 2.** Show that under `ν_{N,\theta}`, the normalized stopping time concentrates near `Λ'(\theta)`.

**Step 3.** Express the cost of forcing an atypical value `x` as relative entropy between the original counting measure and the tilted measure, recovering
\[
I(x)=\theta x-\Lambda(\theta).
\]

**Why it is powerful:** this route reveals the rate function as an information-theoretic object. It creates a direct bridge to learning theory and statistical inference.

---

## Cross-Domain Connections You Should Make Explicit

Do not leave these as buzzwords. Build them into the narrative and, where possible, into lemmas.

### 1. Statistical mechanics
`Λ` is a pressure/free-energy density; `I` is the nonequilibrium cost function. Non-differentiability of `Λ` corresponds to phase transitions in arithmetic stopping-time statistics.

### 2. Information theory
The Legendre dual rate function is analogous to a Cramér transform / relative entropy cost. This suggests a future formalization of **arithmetic information geometry**.

### 3. Learning theory
Stopping-time observables behave like sample complexity or optimization runtime observables. Large deviations quantify the probability of atypically hard instances.

### 4. Dynamical systems
If `τ` arises from an iteration count to enter a basin or bounded region, the theorem becomes a formal LDP for first-hitting times in arithmetic dynamics.

### 5. Computational complexity
This creates a language for “thermodynamic complexity classes,” where free energy captures average-case exponential weighting and rate functions capture tail hardness.

---

## Application Keywords

large deviations, Gärtner–Ellis theorem, Legendre transform, free energy, arithmetic dynamics, stopping times, empirical measures, convex analysis, Chernoff bounds, thermodynamic formalism, entropy, rare events, phase transitions, average-case complexity, arithmetic learning theory

---

## Concrete Lean Deliverables

1. **Define finite-volume partition sums and log-mgfs**
   - `partitionSum`
   - `logMGF`
   - `empiricalProb`
   - `rateFunction`

2. **Prove elementary convexity lemmas**
   - finite `log-sum-exp` convexity
   - convexity of `logMGF τ N`
   - convexity of the limit `Λ`

3. **Prove a Chernoff-type upper bound**
   for half-lines or intervals first.

4. **Formalize Legendre–Fenchel transform lemmas**
   sufficient to pass from mgf asymptotics to upper bounds.

5. **If full Gärtner–Ellis is too heavy**, prove a mathematically meaningful weaker theorem:
   - upper LDP for closed intervals
   - lower bound at exposed points
   - identification of the candidate rate function

A partial theorem with a precise convex duality statement is far better than an overambitious theorem with many `sorry`s.

---

## Minimal Nontrivial Theorem If Full LDP Is Out of Reach

If Mathlib support for full topological LDP language is too sparse, prove this exact weaker statement:

```lean
theorem chernoff_upper_bound_normalized_stopping_time
    (τ : ℕ → ℝ) (N : ℕ) (θ a : ℝ) (hθ : 0 ≤ θ) :
    empiricalProb τ N (Set.Ici a) ≤
      Real.exp ((Real.log
        (((Finset.range N.succ).sum (fun n => Real.exp (θ * τ n))) / (N + 1)))
        - θ * a * Real.log (N + 2)) := by
  sorry
```

and then a limit theorem:

```lean
theorem ldp_upper_halfline
    (τ : ℕ → ℝ) (Λ : ℝ → ℝ)
    (hΛ : ∀ θ : ℝ, Tendsto (fun N => logMGF τ N θ) atTop (𝓝 (Λ θ))) :
    ∀ a : ℝ,
    Filter.limsup (fun N =>
      Real.log (empiricalProb τ N (Set.Ici a)) / Real.log (N + 2)) Filter.atTop
      ≤ - sSup {r : ℝ | ∃ θ : ℝ, 0 ≤ θ ∧ r = θ * a - Λ θ} := by
  sorry
```

This would already be a major result.

---

## Formalization Notes

- Be careful with `n = 0`; using `log (n+2)` avoids singularities.
- You may want to index over `Finset.Icc 1 N` instead of `range`; choose the cleanest normalization.
- Expect to need positivity lemmas for `Real.log (N + 2)`.
- For empirical probabilities, using cardinal ratios in `ℝ` may be simplest initially.
- If full `LowerSemicontinuous` infrastructure is awkward, state convexity + explicit interval hypotheses first.

---

## What Success Looks Like

The strongest successful outcome is:

1. a formal definition of arithmetic free energy for stopping times,
2. a certified convex dual rate function,
3. a proved large deviation upper bound,
4. at least a local lower bound under differentiability assumptions,
5. a theorem identifying the rate function as the Legendre transform of free energy.

That would establish a new formal research program: **arithmetic thermodynamic large deviations**.

---

## Required Output Artifact

In addition to the Lean development, you must produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete, breakthrough-level next steps**, for example:

1. full Gärtner–Ellis theorem in Mathlib style for arithmetic empirical measures,
2. phase transition criteria from non-differentiability of free energy,
3. moderate deviation and central limit corrections from second derivatives of `Λ`,
4. entropy-production interpretation for arithmetic dynamics,
5. complexity-theoretic applications to runtime tail distributions.

Make these specific, technically actionable, and visionary.

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
