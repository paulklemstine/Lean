Soli Deo Gloria

## Assignment: Direction 1: Comparison Theorems for Non-Group Markov Chains

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc` reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog. Check the catalog references to confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

## Vision: from Cayley-graph comparison to a universal transport principle for reversible Markov chains

The breakthrough target is not merely “another comparison inequality.” The real objective is to **liberate spectral-gap certification from group structure**. The catalog already contains a mature canonical-path and Poincaré theory for Cayley expanders:

- `Pythagorean/CayleyExpander/CanonicalPaths.lean`
- `Pythagorean/CayleyExpander/SpectralGap.lean`
- `Pythagorean/CayleyExpander/MixingTime.lean`

Those results encode a profound mechanism: control of variance by path congestion, hence control of spectral gap and mixing. But at present that mechanism is trapped inside the symmetry of groups. Your task is to extract the invariant core and prove that **reversible chains inherit expansion from any comparison chain through a distortion-controlled transport map**. If this works, it opens a formal pathway from algebraic expanders to Glauber dynamics, Metropolis chains, constraint-satisfaction samplers, spin systems, and combinatorial state spaces with no ambient group law.

This is a field-opening result because it would transform canonical paths from a specialized expander argument into a **general certification technology for MCMC**.

---

## Primary theorem target

### New structure to define

Define a new concept expressing that one reversible chain is compared to another through path transport.

Suggested Lean-facing structure:
```lean
structure ReversibleChainComparison
    (α : Type*) [Fintype α] [DecidableEq α] where
  πP : α → ℝ
  πQ : α → ℝ
  P : α → α → ℝ
  Q : α → α → ℝ
  revP : ∀ x y, πP x * P x y = πP y * P y x
  revQ : ∀ x y, πQ x * Q x y = πQ y * Q y x
  path : α → α → List α
  path_spec :
    ∀ {x y}, P x y ≠ 0 →
      (path x y).Head? = some x ∧ (path x y).getLast? = some y
  comparison_constant : ℝ
  congestion_bound :
    -- formulate edge congestion of transported P-flow through Q-edges
    Prop
```

You may refine this to fit existing catalog definitions, but **you must introduce at least one genuinely new definition**, such as:

- `DirichletForm`
- `ReversibleKernel`
- `PathCongestion`
- `ComparisonEmbedding`
- `DistortionControlledEmbedding`

At least one should be novel relative to the catalog.

---

## Precise theorem statement

### Theorem 1: Dirichlet-form comparison implies spectral-gap comparison

Mathematical statement:

Let `α` be finite. Let `P` and `Q` be reversible Markov kernels on `α` with stationary distributions `πP` and `πQ`. Assume there exists `C > 0` such that for every real-valued function `f : α → ℝ`,
\[
\mathcal E_Q(f,f) \le C\, \mathcal E_P(f,f),
\]
where
\[
\mathcal E_P(f,f)=\frac12 \sum_{x,y} \pi_P(x) P(x,y)(f(x)-f(y))^2.
\]
Assume also the stationary measures are comparable:
\[
a\,\pi_Q(x)\le \pi_P(x)\le b\,\pi_Q(x)\quad \forall x.
\]
Then the spectral gaps satisfy
\[
\lambda(P)\ge \frac{a}{b}\,\frac{\lambda(Q)}{C}.
\]

This is the correct quantitative form: comparison of energies plus comparison of variances under different stationary measures yields comparison of spectral gaps.

### Suggested Lean 4 signature
```lean
theorem spectralGap_lower_bound_of_dirichlet_comparison
    {α : Type*} [Fintype α] [DecidableEq α]
    (P Q : α → α → ℝ)
    (πP πQ : α → ℝ)
    (a b C : ℝ)
    (ha : 0 < a) (hb : 0 < b) (hC : 0 < C)
    (hrevP : ∀ x y, πP x * P x y = πP y * P y x)
    (hrevQ : ∀ x y, πQ x * Q x y = πQ y * Q y x)
    (hπcmp_lower : ∀ x, a * πQ x ≤ πP x)
    (hπcmp_upper : ∀ x, πP x ≤ b * πQ x)
    (hEcmp : ∀ f : α → ℝ, dirichletForm πQ Q f ≤ C * dirichletForm πP P f) :
    spectralGap πP P ≥ (a / b) * (spectralGap πQ Q / C)
```

This theorem is the fulcrum. Once formalized, it becomes a reusable engine for every later application.

---

### Theorem 2: Path-congestion comparison theorem for reversible chains

Mathematical statement:

Let `P,Q` be reversible chains on the same finite state space `α`, with common stationary distribution `π`. For each oriented `P`-edge `(x,y)` with `P(x,y)>0`, choose a `Q`-path `γ_xy`. Define the congestion
\[
\rho := \max_{(u,v):Q(u,v)>0}
\frac{1}{\pi(u)Q(u,v)}
\sum_{(x,y):\, (u,v)\in \gamma_{xy}}
\pi(x)P(x,y)\,|\gamma_{xy}|.
\]
Then for every `f`,
\[
\mathcal E_P(f,f)\le \rho\,\mathcal E_Q(f,f),
\]
and hence
\[
\lambda(P)\le \rho\,\lambda(Q).
\]
Equivalently,
\[
\lambda(Q)\ge \lambda(P)/\rho.
\]

This is the exact abstraction of the canonical-path argument stripped of group-specific language.

### Suggested Lean 4 signature
```lean
theorem dirichletForm_le_congestion_mul_dirichletForm
    {α : Type*} [Fintype α] [DecidableEq α]
    (π : α → ℝ) (P Q : α → α → ℝ)
    (Γ : α → α → List α)
    (ρ : ℝ)
    (hrevP : ∀ x y, π x * P x y = π y * P y x)
    (hrevQ : ∀ x y, π x * Q x y = π y * Q y x)
    (hΓ : ∀ {x y}, P x y ≠ 0 → validQPath Q (Γ x y) x y)
    (hρ : pathCongestion π P Q Γ ≤ ρ) :
    ∀ f : α → ℝ, dirichletForm π P f ≤ ρ * dirichletForm π Q f
```

and then:

```lean
theorem spectralGap_le_congestion_mul_spectralGap
    {α : Type*} [Fintype α] [DecidableEq α]
    (π : α → ℝ) (P Q : α → α → ℝ)
    (Γ : α → α → List α)
    (ρ : ℝ)
    ...
    (hρ : pathCongestion π P Q Γ ≤ ρ) :
    spectralGap π P ≤ ρ * spectralGap π Q
```

This theorem should explicitly extend the lineage of `variance_le_congestion_mul_energy` from `CanonicalPaths.lean`.

---

### Theorem 3: Embedding into a Cayley comparison chain yields a lower bound

Let `Ω` be a finite state space, `P` a reversible chain on `Ω`, `G` a finite group with symmetric generating set `S`, and let `Q` be the simple random walk on the Cayley graph `Cay(G,S)`. Suppose there is an injective map `φ : Ω → G` and a path-lifting rule sending each `P`-transition `(x,y)` to a Cayley path from `φ x` to `φ y` of length at most `D`, with edge congestion at most `D` in the transported flow sense. Then
\[
\lambda(P)\ge \frac{\lambda(Q)}{D^2}
\]
up to the exact normalization constants you verify formally. If the stationary distributions differ, include the variance-comparison factor from Theorem 1.

This is the theorem closest to the original conjecture, but you should prove it only after the two structural theorems above.

### Suggested Lean 4 signature
```lean
theorem spectralGap_lower_bound_of_cayley_embedding
    {Ω G : Type*}
    [Fintype Ω] [DecidableEq Ω]
    [Fintype G] [DecidableEq G] [Group G]
    (πΩ : Ω → ℝ)
    (P : Ω → Ω → ℝ)
    (S : Finset G)
    (φ : Ω → G)
    (D : ℝ)
    (hD : 0 < D)
    (hemb : distortionControlledEmbedding πΩ P S φ D) :
    spectralGap πΩ P ≥ spectralGap (uniformMeasureOn G) (cayleyWalk S) / (D^2)
```

You may need a more elaborate statement if the stationary distribution is not uniform; that is acceptable and mathematically preferable.

---

## Most promising proof architecture

### Strategy A: Variational/Rayleigh quotient route — **most promising**
This is the cleanest route and should likely be your main line.

1. **Define Dirichlet forms and variance under a stationary measure.**
   Build a finite-state theory:
   \[
   \lambda(P)=\inf_{f \not\equiv \mathrm{const}} \frac{\mathcal E_P(f,f)}{\mathrm{Var}_{\pi}(f)}.
   \]
   If catalog spectral gap is already defined via `L²` contraction, prove equivalence to the Rayleigh quotient using the reversible self-adjoint operator viewpoint.

2. **Prove energy comparison and variance comparison separately.**
   - Energy comparison from path congestion:
     telescope along paths and apply Cauchy–Schwarz.
   - Variance comparison from stationary measure comparability:
     \[
     \mathrm{Var}_{\pi_P}(f)\le b\,\mathrm{Var}_{\pi_Q}(f), \quad
     \mathrm{Var}_{\pi_Q}(f)\le a^{-1}\,\mathrm{Var}_{\pi_P}(f).
     \]

3. **Assemble the spectral-gap inequality via the infimum characterization.**
   This proof will require nontrivial `calc`, likely `field_simp`, and careful positivity side-conditions.

**Why this is most promising:** it isolates the difficult combinatorial part (energy comparison) from the analytic part (spectral gap), and it aligns perfectly with the catalog’s Poincaré-inequality lineage.

---

### Strategy B: Operator comparison in finite-dimensional Hilbert space
Treat reversible kernels as self-adjoint operators on `ℓ²(π)` and compare quadratic forms.

1. Define the Laplacians `L_P = I - P`, `L_Q = I - Q`.
2. Prove a Loewner-order style inequality on the orthogonal complement of constants:
   \[
   L_Q \preceq C L_P.
   \]
3. Transfer this to eigenvalue inequalities via min-max.

**Why it is powerful:** conceptually elegant and opens a bridge to spectral graph theory and mathematical physics.  
**Why it is harder in Lean:** formalizing finite-dimensional spectral min-max machinery may be heavier than the direct Rayleigh route unless Mathlib support is already strong in the needed direction.

---

### Strategy C: Direct extension of canonical paths from Cayley graphs
Mine the existing `CanonicalPaths.lean` proofs and abstract only the group-specific steps.

1. Identify where the current proof uses multiplication or translation-invariance.
2. Replace those uses by a generic path family `Γ : α → α → List α`.
3. Reprove the key congestion lemma for arbitrary reversible kernels.

**Why this is valuable:** maximal code reuse from the catalog.  
**Why it may stall:** the existing file may have implicit dependence on group symmetry hidden in notation or lemmas.

**Recommendation:** Use Strategy A as the primary architecture, while opportunistically importing lemmas from Strategy C.

---

## Concrete theorem bundle to include in the file

Your file must contain at least these three deep theorems, all with nontrivial proofs:

1. `variance_le_stationaryComparison_mul_variance`
   ```lean
   theorem variance_le_stationaryComparison_mul_variance
       {α : Type*} [Fintype α] [DecidableEq α]
       (πP πQ : α → ℝ) (b : ℝ)
       (hb : 0 < b)
       (hcmp : ∀ x, πP x ≤ b * πQ x) :
       ∀ f : α → ℝ, variance πP f ≤ b * variance πQ f
   ```
   Proof should use expansion of variance around the mean and nontrivial measure comparison.

2. `dirichletForm_le_congestion_mul_dirichletForm`
   as above, proved by path telescoping and Cauchy–Schwarz.

3. `spectralGap_lower_bound_of_dirichlet_comparison`
   as above, combining the previous two.

A fourth theorem is strongly encouraged:

4. `spectralGap_lower_bound_of_cayley_embedding`
   giving the distortion-to-gap transfer.

---

## Cross-domain theorem requirement

Include at least one theorem that bridges to a different domain. The best option here is a bridge to **statistical physics**:

### Theorem 4: Glauber dynamics comparison corollary
Formalize a finite spin system on a graph `H`, with state space of colorings or spins, and define a reversible single-site update chain `P_Glauber`. Then prove a comparison theorem of the form:

\[
\lambda(P_{\mathrm{Glauber}})\ge c(H,\beta)\,\lambda(Q_{\mathrm{reference}})
\]
for a suitable reference chain `Q`, where `c(H,\beta)` is explicitly computable from update distortion or influence bounds.

Even a weaker finite-graph corollary is acceptable if fully formalized.

### Suggested cross-domain framing
- **Probability theory:** reversible Markov chains, spectral gaps
- **Statistical physics:** Glauber dynamics, spin relaxation, phase mixing
- **Algorithms:** MCMC convergence certification
- **Spectral graph theory:** Poincaré inequalities, Laplacian comparison

This theorem is where the project stops being “about Cayley graphs” and starts being “about universality of mixing certification.”

---

## Specific catalog build points

You must explicitly build on the following catalog lineage:

- From `Pythagorean/CayleyExpander/CanonicalPaths.lean`:
  reuse or generalize the mechanism behind `variance_le_congestion_mul_energy`.
  Your brief target is to **factor out the path-counting argument from group symmetry**.

- From `Pythagorean/CayleyExpander/SpectralGap.lean`:
  connect the newly generalized Dirichlet/Poincaré inequality to the existing `L²` contraction or spectral-gap formalization.

- From `Pythagorean/CayleyExpander/MixingTime.lean`:
  if possible, derive a corollary translating the new gap lower bound into an explicit mixing-time upper bound for non-group chains.

A desirable corollary:
```lean
theorem mixingTime_le_of_spectralGap_comparison
    ...
    : mixingTime P ε ≤
      explicitBoundInTermsOf (spectralGap Q) (comparisonConstant ...) ε
```

This would be the first real “application theorem” of the framework.

---

## Instantiation target: graph colorings and the Petersen graph

The proposed test case is excellent, but sharpen it mathematically.

### Formal application target
Let `H` be the Petersen graph. Let `Ω_k(H)` be the proper `k`-colorings of `H` for some small explicit `k` where the state space is nonempty and interesting. Define the single-vertex recoloring Glauber chain `P_col`. Construct a comparison map from colorings to permutations or to a reference walk on a symmetric-group-related state space, then bound the path distortion/congestion.

If a full embedding into `Sym(n)` is too rigid, a more mathematically natural route is:

- encode colorings as constrained words,
- compare the Glauber chain to a product chain or adjacent-transposition chain,
- then compare that chain to a Cayley walk on `S_n`.

This may give a cleaner formal path than forcing a direct coloring-to-permutation embedding.

### Numerical verification task
In `demo.py`, compute:
- the exact transition matrix for the Petersen coloring chain for a chosen `k`,
- its numerically estimated spectral gap,
- the comparison constant/distortion bound from your formal theorem,
- the certified lower bound predicted by the theorem.

If the bound is weak, that is still scientifically valuable: it reveals where the comparison loses sharpness.

---

## Conjecture with falsifiable prediction

State at least one explicit conjecture and a test that could refute it.

### Recommended conjecture
**Conjecture (bounded-distortion coloring comparison):**  
For every graph `H` of maximum degree `Δ` and every `k ≥ 2Δ+1`, the Glauber dynamics on proper `k`-colorings admits a comparison embedding into a reference transposition-based chain with distortion bounded by a polynomial in `|V(H)|` and `Δ`, uniformly over the choice of graph.

A falsifiable computational prediction:
- For all connected graphs on at most `n = 8` vertices and `k = 2Δ+1`, exhaustive computation should reveal congestion bounded by `poly(n,Δ)` with exponent no worse than, say, `4`.
- A counterexample graph with superpolynomial observed congestion would refute the conjectural form.

This is much better than an untestable conjecture: it can be attacked immediately by brute-force enumeration on small graphs.

---

## Lean design suggestions

You should create a new file along the lines of:
```text
Pythagorean/MarkovComparison/NonGroupComparison.lean
```
and possibly supporting files:
```text
Pythagorean/MarkovComparison/DirichletForm.lean
Pythagorean/MarkovComparison/GlauberColorings.lean
```

Suggested core definitions:
```lean
def dirichletForm
    {α : Type*} [Fintype α]
    (π : α → ℝ) (P : α → α → ℝ) (f : α → ℝ) : ℝ := ...

def variance
    {α : Type*} [Fintype α]
    (π : α → ℝ) (f : α → ℝ) : ℝ := ...

def validQPath
    {α : Type*} [DecidableEq α]
    (Q : α → α → ℝ) (γ : List α) (x y : α) : Prop := ...

def pathCongestion
    {α : Type*} [Fintype α] [DecidableEq α]
    (π : α → ℝ) (P Q : α → α → ℝ)
    (Γ : α → α → List α) : ℝ := ...

def spectralGap
    {α : Type*} [Fintype α]
    (π : α → ℝ) (P : α → α → ℝ) : ℝ := ...
```

Be disciplined about positivity hypotheses:
- `π x ≥ 0`
- `∑ x, π x = 1`
- `P x y ≥ 0`
- `∑ y, P x y = 1`

If a full abstract Markov-kernel API is too expensive, work first with finite kernels satisfying explicit hypotheses and later package them.

---

## Technical proof ingredients to force genuine depth

Your proofs should visibly use:

- `rcases` on path decomposition / nonempty path structure
- `by_contra` in the spectral-gap contradiction step or positivity lemmas
- `field_simp` when normalizing variance or Rayleigh quotient constants
- multi-step `calc` blocks for:
  - telescoping sums along paths,
  - Cauchy–Schwarz estimates,
  - comparison of variances under `πP` and `πQ`,
  - assembling constants into the final gap inequality

A canonical deep step you should aim to formalize:
\[
(f(x)-f(y))^2
= \left(\sum_{e\in \gamma_{xy}} \nabla_e f\right)^2
\le |\gamma_{xy}| \sum_{e\in \gamma_{xy}} (\nabla_e f)^2.
\]
This is the heart of the comparison theorem.

---

## Why this would be revolutionary

If successful, this project opens a new formal research program:

1. **Universal certified MCMC**  
   Spectral-gap and mixing-time certification for state spaces with no group structure.

2. **Statistical mechanics bridge**  
   Rigorous comparison of Glauber dynamics, spin systems, and constrained sampling chains using expander-style tools.

3. **Algorithmic synthesis**  
   Automatic generation of comparison witnesses and congestion bounds for practical samplers.

4. **Spectral transport theory**  
   A new viewpoint: expansion is not tied to symmetry; it can be transported through reversible comparison morphisms.

This is exactly the kind of result that makes a mathematician say: “I had not realized the canonical-path method could be abstracted that far.”

---

## Application keywords

Markov chains; reversible kernels; spectral gap; Dirichlet form; Poincaré inequality; canonical paths; path congestion; comparison theorem; Diaconis–Saloff-Coste; Glauber dynamics; spin systems; MCMC; mixing time; Cayley graphs; expander graphs; spectral graph theory; transport of functional inequalities; finite-state statistical mechanics; combinatorial sampling; Petersen graph.

---

## Mandatory deliverables

You must produce **ALL** of the following:

1. **Lean code** formalizing the new definitions and proving the theorems above, with minimal sorry usage.
2. **A verified algorithm or computational method** for computing or bounding path congestion / comparison constants from an explicit chain description.
3. **`demo.py`** that interactively demonstrates the result on at least one explicit example, ideally the Petersen graph coloring chain or a comparably rich finite reversible chain.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper explaining:
   - the precise new theorems,
   - how they extend the catalog,
   - why the result matters mathematically,
   - what experiments were run,
   - what the next conjectures are.
5. **`ARTICLE.md`** in Scientific American style, explaining the ideas and significance to a broad audience, with **no focus on formal verification machinery**.
6. **`FUTURE_DIRECTIONS.md`** containing 3–5 original research directions. Each direction must include the sentences:
   - **“The key insight is...”**
   - **“Why now?”**
   At least one direction must bridge to a different domain, such as statistical physics, complexity theory, or information theory.

The system does science by iteration: hypothesize → formalize → compute → analyze → generalize. This project is an ideal vehicle for that cycle.

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
