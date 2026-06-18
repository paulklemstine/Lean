## Assignment: Direction 3: Thermodynamic Formalism for Arithmetic Orbits

**Mode**: `prove`

Prove a genuinely new theorem package that turns discounted arithmetic-orbit value functions into a rigorous thermodynamic formalism. The goal is not to speculate about “phase transitions,” but to certify a sharp Abelian/Tauberian bridge between discounted free energy growth as `γ → 1⁻` and the tail statistics of Collatz-like stopping times. This would open a new interface between arithmetic dynamics, reinforcement-style value functions, and statistical mechanics.

You should aim to formalize a theorem of the following shape: if `Vγ(n)` is the discounted orbit cost associated to an arithmetic transition system and `τ(n)` is a stopping-time observable, then for a weighted partition function
\[
F(\gamma) := \sum_{n=1}^\infty w(n)\,V_\gamma(n),
\]
the asymptotic divergence rate of `F(γ)` near `γ = 1` is controlled by weighted tail sums of `τ`. In the Collatz case, this would convert stopping-time distribution information into a free-energy singularity statement. That is the breakthrough: a thermodynamic order parameter for arithmetic orbits.

### Precise Theorem Target

Work first in a general abstract setting where the stopping-time observable is already available, and only then specialize to Collatz-style arithmetic maps.

Let `τ : ℕ → ℕ` be any stopping-time observable, let `w : ℕ → ℝ≥0∞` or `ℝ` be a nonnegative summable or truncated weight, and define the discounted cost
\[
V_\gamma(n) := \sum_{k=0}^{\tau(n)-1} \gamma^k
=
\begin{cases}
\frac{1-\gamma^{\tau(n)}}{1-\gamma}, & \gamma \neq 1,\\
\tau(n), & \gamma = 1 \text{ formally}.
\end{cases}
\]
Then define finite-volume free energy
\[
F_N(\gamma) := \sum_{n=1}^{N} w(n)\,V_\gamma(n).
\]

The first target should be an exact summation identity:
\[
F_N(\gamma)=\sum_{m=0}^\infty \gamma^m \sum_{\substack{1\le n\le N\\ m<\tau(n)}} w(n),
\]
where the outer sum is actually finite after truncation. This is the arithmetic analogue of writing free energy as the generating function of tail events.

From this, prove a monotone comparison theorem:

> If there exist constants `A, B > 0` and exponent `β ≥ 0` such that for all `M`,
> \[
> A(M+1)^{-\beta} \le \sum_{\substack{1\le n\le N\\ \tau(n)>M}} w(n)
> \le B(M+1)^{-\beta},
> \]
> then there exist constants `c₁, c₂ > 0` such that for all `γ ∈ [0,1)`,
> \[
> c_1 \,\Phi_\beta(\gamma)\ \le\ F_N(\gamma)\ \le\ c_2 \,\Phi_\beta(\gamma),
> \]
> where
> \[
> \Phi_\beta(\gamma)=\sum_{m=0}^\infty \gamma^m (m+1)^{-\beta}.
> \]
> In particular:
> - if `β < 1`, then `F_N(γ) ≍ (1-γ)^{β-1}`;
> - if `β = 1`, then `F_N(γ) ≍ \log \frac{1}{1-\gamma}`;
> - if `β > 1`, then `F_N(γ)` stays bounded as `γ → 1⁻`.

This is already a major theorem: it identifies the critical exponent of free-energy divergence with the tail exponent of stopping times.

### Lean 4 Type Signature Targets

You should formalize at least the finite-truncation version completely, since it avoids measure-theoretic headaches and is enough to expose the thermodynamic mechanism.

A plausible Lean theorem skeleton:

```lean
theorem discounted_cost_eq_geometric_sum
    (τ : ℕ → ℕ) (γ : ℝ) (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) (n : ℕ) :
    (∑ k in Finset.range (τ n), γ^k)
      = (1 - γ^(τ n)) / (1 - γ) := by
```

```lean
def discountedCost (τ : ℕ → ℕ) (γ : ℝ) (n : ℕ) : ℝ :=
  ∑ k in Finset.range (τ n), γ^k
```

```lean
def freeEnergyTrunc (τ : ℕ → ℕ) (w : ℕ → ℝ) (N : ℕ) (γ : ℝ) : ℝ :=
  ∑ n in Finset.Icc 1 N, w n * discountedCost τ γ n
```

```lean
def tailMassTrunc (τ : ℕ → ℕ) (w : ℕ → ℝ) (N m : ℕ) : ℝ :=
  ∑ n in (Finset.Icc 1 N).filter (fun n => m < τ n), w n
```

```lean
theorem freeEnergyTrunc_eq_tail_generating_function
    (τ : ℕ → ℕ) (w : ℕ → ℝ) (N : ℕ) (γ : ℝ) :
    freeEnergyTrunc τ w N γ
      = ∑ m in Finset.range (Nat.succ (∑ n in Finset.Icc 1 N, τ n)),
          γ^m * tailMassTrunc τ w N m := by
```

A cleaner bounded-support variant may be easier:

```lean
theorem freeEnergyTrunc_eq_tail_sum
    (τ : ℕ → ℕ) (w : ℕ → ℝ) (N M : ℕ)
    (hM : ∀ n ∈ Finset.Icc 1 N, τ n ≤ M) :
    freeEnergyTrunc τ w N γ
      = ∑ m in Finset.range M, γ^m * tailMassTrunc τ w N m := by
```

Then prove comparison bounds:

```lean
theorem freeEnergyTrunc_upper_bound_of_tail_upper
    (τ : ℕ → ℕ) (w : ℕ → ℝ) (N : ℕ) (γ B β : ℝ)
    (hγ0 : 0 ≤ γ) (hγ1 : γ < 1) (hβ : 0 ≤ β)
    (hw : ∀ n ∈ Finset.Icc 1 N, 0 ≤ w n)
    (htail : ∀ m : ℕ, tailMassTrunc τ w N m ≤ B / (m+1 : ℝ)^β) :
    freeEnergyTrunc τ w N γ
      ≤ B * ∑' m : ℕ, γ^m / (m+1 : ℝ)^β := by
```

and similarly a lower bound theorem.

If the Collatz stopping time is already defined anywhere in the codebase, specialize to it. If not, introduce an abstract arithmetic-orbit stopping time interface first; do not get bogged down in full Collatz formalization unless the infrastructure already exists.

### Why This Is a Breakthrough

This theorem would create a rigorous dictionary:

- **discount factor `γ`** ↔ **inverse temperature / fugacity**
- **discounted value function** ↔ **finite-time free energy contribution**
- **stopping-time tails** ↔ **density of excited states**
- **critical divergence at `γ → 1⁻`** ↔ **phase transition exponent**

That dictionary is not cosmetic. It would let arithmetic orbit statistics be studied through singularity analysis of generating functions, importing the logic of Ruelle transfer operators and Tauberian theory into discrete arithmetic dynamics. If successful, this opens a new field: **thermodynamic arithmetic dynamics**.

### Proof Strategy Options

#### Strategy A: Exact combinatorial rearrangement + positivity comparison
Most promising for Lean.

1. Expand
   \[
   V_\gamma(n)=\sum_{k<\tau(n)} \gamma^k.
   \]
   Substitute into `F_N(γ)` and swap the finite sums.
2. Identify the inner coefficient as the weighted tail count
   \[
   \sum_{n\le N,\ \tau(n)>k} w(n).
   \]
3. Apply upper/lower tail hypotheses termwise to compare `F_N(γ)` with
   \[
   \sum_k \gamma^k (k+1)^{-\beta}.
   \]

Why this is strongest: it is entirely finitary, uses only `Finset` manipulations, monotonicity, and standard power estimates. It minimizes sorry and gives a robust theorem independent of unresolved Collatz specifics.

#### Strategy B: Summation by parts / Abel transform
Elegant and closer to classical thermodynamic formalism.

1. Start from the weighted distribution of `τ`.
2. Write `F_N(γ)` as a discrete Stieltjes transform of the cumulative distribution.
3. Use Abel summation to derive asymptotic growth from tail asymptotics.

Why useful: this exposes the exact Tauberian structure and may scale to Dirichlet-series or zeta-function variants. It may also connect naturally to existing `free_energy_*` catalog theorems if they are phrased analytically.

#### Strategy C: Generating-function bridge to polylogarithmic asymptotics
Most ambitious.

1. Reduce the comparison function to
   \[
   \Phi_\beta(\gamma)=\sum_{m\ge0}\gamma^m(m+1)^{-\beta}.
   \]
2. Identify this as a real polylog-type object.
3. Prove asymptotics near `γ = 1` using integral comparison or known Mathlib asymptotic lemmas if available.

Why powerful: this yields the true “critical exponent” theorem. But it may require more analytic infrastructure than currently available. If necessary, first prove elementary comparison bounds with explicit integrals instead of full asymptotic equivalence.

### How to Build on Existing Catalog Theorems

Use the existing free-energy and partition-function lemmas as structural anchors, even if they come from different bridge files.

- `free_energy_lower_bound` and `free_energy_upper_bound`:
  use these as templates for how free-energy quantities are packaged and bounded in the catalog. Mirror their style and abstractions so the new arithmetic free energy theory plugs into the existing ecosystem.
- `free_energy_ritt_bound` and `free_energy_bounds`:
  inspect whether these establish two-sided control from complexity parameters. If so, reinterpret stopping-time tail mass as the complexity parameter and derive analogous arithmetic corollaries.
- `partition_function_bound`:
  use this as a formal model for truncation, positivity, and normalization estimates. Your `freeEnergyTrunc` should look like a partition function with arithmetic microstates indexed by `n ≤ N`.

The deeper point is to unify these bridge theorems into a single narrative: arithmetic orbit statistics admit the same bounding technology as thermodynamic partition sums in geometry, learning theory, and tropical systems.

### Cross-Domain Connections

Push these explicitly in the formal and informal writeup.

- **Dynamical systems**: tail masses of stopping times play the role of return-time distributions in inducing schemes.
- **Statistical mechanics**: `γ` is a fugacity-like control parameter; divergence classes correspond to critical phenomena.
- **Reinforcement learning / control**: discounted value functions already live in Bellman-style language; arithmetic dynamics becomes a deterministic MDP over `ℕ`.
- **Analytic number theory**: the free-energy singularity is a generating-function shadow of stopping-time distribution, analogous to Tauberian recovery of counting asymptotics from zeta singularities.
- **Complexity theory**: stopping-time tails encode computational hardness of orbit descent; phase transitions may mark algorithmic universality classes.
- **Probability / heavy tails**: if `τ` exhibits power-law or logarithmic-tail behavior, the free energy detects the exponent sharply.

This is exactly the sort of cross-pollination that can create a new research program rather than an isolated theorem.

### Concrete Theorem Package to Deliver

1. **Exact finite-volume free energy decomposition**
   - `freeEnergyTrunc = Σ γ^m * tailMassTrunc`
2. **Monotonicity and positivity lemmas**
   - nonnegativity under `w ≥ 0`, monotone in `γ`
3. **Upper and lower comparison theorems**
   - from tail upper/lower bounds to free-energy upper/lower bounds
4. **Critical exponent corollary**
   - classify bounded / logarithmic / power divergence regimes
5. **Optional specialization**
   - to any existing Collatz stopping-time notion in the repo

Even if the final asymptotic equivalence theorem is too ambitious in one cycle, the exact decomposition plus comparison inequalities already constitute a publishable conceptual bridge.

### Application Keywords

`Collatz dynamics`, `arithmetic orbits`, `thermodynamic formalism`, `free energy`, `partition function`, `discounted value function`, `stopping times`, `Tauberian theory`, `generating functions`, `phase transitions`, `heavy-tail statistics`, `Ruelle transfer philosophy`, `deterministic control on ℕ`, `analytic number theory`, `statistical mechanics`

### Implementation Guidance

- Prefer finite sums over `Finset` first.
- Keep all weights nonnegative where possible; positivity makes every inequality easier.
- Isolate the key combinatorial lemma:
  membership equivalence between `k ∈ range (τ n)` and `k < τ n`.
- If asymptotic notation is too heavy, prove explicit comparison inequalities with constants.
- If infinite sums become painful, work with truncated `M` and then pass to monotone limits only where Mathlib support is strong.

### Deliverables

1. A Lean file proving the theorem package above with minimal sorry.
2. A short note inside the file or adjacent markdown explaining the thermodynamic interpretation.
3. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - a transfer-operator formalism for arithmetic maps,
   - a Dirichlet free energy `Σ w(n)n^{-s}Vγ(n)`,
   - large-deviation principles for stopping-time distributions,
   - universality classes across Collatz, `ax+b`, and Euclidean descent systems,
   - Bellman-equation formulations of arithmetic complexity.

Do not settle for a weak analogy. Build the exact generating-function theorem that makes the analogy mathematically real.

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
