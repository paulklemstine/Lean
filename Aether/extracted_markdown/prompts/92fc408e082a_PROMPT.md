Soli Deo Gloria

## Assignment: Direction 2 — Heterogeneity–Gap Conjecture, Recast as a Structural Theory of Disorder-forcing Integrality

You are not being asked for an isolated lemma. You are being asked to found a new principle in combinatorial optimization:

> **Structural disorder forces integrality separation.**

The conjectural phenomenon is that edge-size heterogeneity is not merely a descriptive statistic of a hypergraph, but a *certificate* that the linear relaxation has genuinely different geometry from the integer problem. If this can be formalized, it opens a new axis in optimization theory: using distributional shape parameters of instances to predict relaxation strength, approximation hardness, and algorithmic regime changes.

Build directly on:

- `Pythagorean/HypergraphTransversal.lean`
  - `edgeHeterogeneity`
  - `IsHeterogeneous`
  - `heterogeneity_zero_of_uniform`
  - any available statements around `τ`, `τ*`, and integrality-gap bounds such as `integrality_gap_upper`

Your goal is to transform the current conjectural narrative into a package of precise theorems, a verified computational pipeline, and a research blueprint that could launch a new subfield.

---

## Core Vision

The existing conjecture says: sufficiently heterogeneous edge sizes force a positive integrality gap beyond trivial ceiling effects. That is already interesting. But the deeper opportunity is this:

1. **Heterogeneity should be promoted from a scalar statistic to a structural invariant.**
2. **The integrality gap should be linked not only to variance but to entropy, support width, and extremal edge-size separation.**
3. **Theorems should isolate mechanisms**, not just empirical correlations:
   - concentration of edge sizes suppresses fractional advantage,
   - dispersion of edge sizes enables multi-scale fractional coverings,
   - “disorder parameters” from information theory and statistical mechanics predict LP-vs-IP separation.

This is the moment to define the right invariants and prove the first nontrivial implications.

---

## Precise Formal Targets

You must introduce at least one genuinely new definition not already in the catalog. I recommend introducing all three below.

### New definitions to add

1. **Support width of edge sizes**
   ```lean
   def edgeSizeSupportWidth (H : SimpleHypergraph V) : ℕ := ...
   ```
   Intended meaning: `max edge size - min edge size`, with suitable default on empty edge set.

2. **Heterogeneity gap witness**
   ```lean
   def HasPositiveCeilGap (H : SimpleHypergraph V) : Prop :=
     Nat.ceil H.transversalNumberFrac < H.transversalNumber
   ```
   or if the library names differ,
   ```lean
   def HasPositiveCeilGap (τ : ℕ) (τstar : ℚ) : Prop := Int.ceil τstar < τ
   ```
   depending on available formalization.

3. **Edge-size entropy**
   If a full Shannon entropy formalization is too heavy, define a finite-support combinatorial proxy:
   ```lean
   def edgeSizeMultiplicity (H : SimpleHypergraph V) (k : ℕ) : ℕ := ...
   def edgeSizeDistributionSupport (H : SimpleHypergraph V) : Finset ℕ := ...
   def edgeSizeCollisionIndex (H : SimpleHypergraph V) : ℚ := ...
   ```
   The collision index
   \[
   \sum_k p_k^2
   \]
   is easier to formalize than entropy and still captures disorder. Then prove that larger support width / smaller collision index corresponds to greater heterogeneity in explicit families.

If entropy is feasible in Lean with finite sums over rationals/reals, define it; otherwise use the collision index as the “information-theoretic disorder parameter.”

---

## Breakthrough Theorem Package

You must prove at least 3 substantial theorems with real proof architecture. Here is the target package.

### Theorem 1 — Uniformity kills heterogeneity, hence no heterogeneity-driven forcing in the uniform regime
This theorem should sharpen the catalog fact `heterogeneity_zero_of_uniform` into a structural converse on your new invariant.

**Mathematical statement**
For any finite hypergraph `H`, if all edges have the same cardinality, then:
- `edgeHeterogeneity H = 0`,
- `edgeSizeSupportWidth H = 0`,
- the edge-size disorder support is a singleton.

This is not revolutionary by itself, but it is the base case needed to isolate the non-uniform regime.

**Lean 4 target signature**
```lean
theorem edgeSizeSupportWidth_eq_zero_of_uniform
    {V : Type*} [Fintype V] [DecidableEq V]
    (H : SimpleHypergraph V)
    (huni : ∃ k : ℕ, ∀ e ∈ H.edgeFinset, e.card = k) :
    edgeSizeSupportWidth H = 0 := by
```

You should also prove a converse under nonemptiness assumptions:

```lean
theorem uniform_of_edgeSizeSupportWidth_eq_zero
    {V : Type*} [Fintype V] [DecidableEq V]
    (H : SimpleHypergraph V)
    (hne : H.edgeFinset.Nonempty)
    (hwidth : edgeSizeSupportWidth H = 0) :
    ∃ k : ℕ, ∀ e ∈ H.edgeFinset, e.card = k := by
```

**Why this matters**
This turns heterogeneity from a heuristic into a sharply detectable structural phase: width zero is exactly the uniform phase.

---

### Theorem 2 — Explicit heterogeneous family with provable positive ceiling gap
Do not try first to prove the full universal conjecture. Prove a decisive infinite family theorem.

Construct a family of hypergraphs with two scales of edges — e.g. a “star-plus-block” or “core-and-spread” construction — for which:
- heterogeneity is positive and grows with a parameter,
- `τ*` can be explicitly bounded strictly below `τ - 1`,
- hence `τ - ⌈τ*⌉ ≥ 1`.

**Recommended family**
Take vertex set partitioned into:
- a core `C` of size `m`,
- satellites `S₁, …, S_r`,
and define edges:
- many small edges forcing integer transversals to hit many distinct regions,
- larger edges overlapping enough that a fractional weighting can spread mass more efficiently.

You need a family where integer hitting sets have a combinatorial bottleneck, but fractional solutions can “pay once, cover many times.”

**Mathematical statement**
There exists an explicit family `H m r` such that for sufficiently large parameters:
\[
\operatorname{edgeHeterogeneity}(H_{m,r}) > 0
\quad\text{and}\quad
\tau(H_{m,r}) - \lceil \tau^*(H_{m,r}) \rceil \ge 1.
\]

**Lean 4 target signature**
```lean
theorem exists_family_positive_ceil_gap
    : ∃ (Vfam : ℕ → Type*) (_ : ∀ n, Fintype (Vfam n))
        (_ : ∀ n, DecidableEq (Vfam n))
        (H : ∀ n, SimpleHypergraph (Vfam n)),
      ∃ N : ℕ, ∀ n ≥ N,
        0 < edgeHeterogeneity (H n) ∧
        HasPositiveCeilGap (H n) := by
```

If dependent types become unwieldy, specialize to a concrete vertex type such as `Fin (f n)`:
```lean
theorem exists_family_on_fin_positive_ceil_gap :
    ∃ (f : ℕ → ℕ) (H : ∀ n, SimpleHypergraph (Fin (f n))), ...
```

**Why this is a breakthrough**
A single explicit infinite family with a *provable disorder-forced ceiling gap* already changes the conversation from “possible empirical trend” to “new structural mechanism.” It creates the first rigorous bridge between edge-size variance and LP-vs-IP separation.

---

### Theorem 3 — Width lower bound or variance surrogate implies non-uniformity in a way exploitable by optimization
The full conjecture “large heterogeneity implies positive gap” may be too strong at first. Prove a theorem that isolates a sufficient *mechanism*.

Example theorem forms:

#### Option A: Width-to-heterogeneity positivity
```lean
theorem edgeHeterogeneity_pos_of_supportWidth_pos
    {V : Type*} [Fintype V] [DecidableEq V]
    (H : SimpleHypergraph V)
    (h : 0 < edgeSizeSupportWidth H) :
    0 < edgeHeterogeneity H := by
```

#### Option B: Two-size support theorem
If the edge sizes take exactly two values `a < b`, and both occur, then heterogeneity admits an explicit lower bound depending on `b - a` and multiplicities.

```lean
theorem edgeHeterogeneity_lower_bound_of_two_level
    {V : Type*} [Fintype V] [DecidableEq V]
    (H : SimpleHypergraph V) (a b : ℕ)
    (hab : a < b)
    (ha : ∃ e ∈ H.edgeFinset, e.card = a)
    (hb : ∃ e ∈ H.edgeFinset, e.card = b)
    (hsupp : ∀ e ∈ H.edgeFinset, e.card = a ∨ e.card = b) :
    ((b - a : ℚ)^2) / 4 ≤ edgeHeterogeneity H := by
```

This is mathematically natural: for a two-point distribution with both masses nonzero, the variance is bounded below by a positive quantity depending on separation and balance. Even a weaker bound with multiplicity factors is valuable.

#### Option C: Disorder proxy theorem
If full variance lower bounds are messy, prove:
```lean
theorem collisionIndex_lt_one_of_supportWidth_pos
    {V : Type*} [Fintype V] [DecidableEq V]
    (H : SimpleHypergraph V)
    (h : 0 < edgeSizeSupportWidth H) :
    edgeSizeCollisionIndex H < 1 := by
```
This is an information-theoretic theorem: nontrivial support dispersion forces nontrivial disorder.

**Why this matters**
This theorem creates the cross-domain bridge. It says heterogeneity can be certified by support geometry or information-theoretic disorder, not only by raw variance formulas.

---

### Theorem 4 — Cross-domain theorem: disorder parameter monotonicity or entropy surrogate
You are required to include at least one theorem connecting to another domain. The strongest route is information theory.

Prove that if the edge-size distribution is supported on more than one value, then the collision index is strictly below 1, and if supported on exactly one value, it equals 1. This mirrors “zero entropy iff deterministic” in information theory.

**Lean 4 target signature**
```lean
theorem collisionIndex_eq_one_iff_uniform_edge_size
    {V : Type*} [Fintype V] [DecidableEq V]
    (H : SimpleHypergraph V) :
    edgeSizeCollisionIndex H = 1 ↔
      ∃ k : ℕ, ∀ e ∈ H.edgeFinset, e.card = k := by
```

Or, if full iff is too hard, split into two theorems.

**Cross-domain significance**
This is not cosmetic. It says:
- combinatorial optimization instances have an information-theoretic disorder observable,
- deterministic edge-size law corresponds to the zero-disorder phase,
- LP advantage may emerge as a response to disorder, echoing statistical mechanics.

This is exactly the kind of theorem that makes experts say, “I did not expect hypergraph transversals to talk to entropy.”

---

## The Main Conjecture to State Precisely

You should still state the grand conjecture in a formal, testable form, even if you only prove substantial special cases.

### Mathematical statement
For every `ε > 0`, there exists `δ > 0` such that for every finite hypergraph `H` on at least 10 vertices, if
\[
\operatorname{edgeHeterogeneity}(H) > \delta,
\]
then
\[
\tau(H) - \lceil \tau^*(H) \rceil \ge 1.
\]

The `ε` in the original statement is currently unused. Repair that. There are two principled formulations:

#### Version A: threshold-only formulation
\[
\exists \delta > 0,\ \forall H,\ \operatorname{edgeHeterogeneity}(H) > \delta \implies \tau(H) - \lceil\tau^*(H)\rceil \ge 1.
\]

#### Version B: quantitative formulation
For every `ε > 0`, there exists `δ > 0` such that
\[
\operatorname{edgeHeterogeneity}(H) > \delta
\implies
\tau(H) - \tau^*(H) > \varepsilon.
\]
Then the ceiling-gap statement follows for `ε ≥ 1` with additional hypotheses.

Version B is deeper and more mathematically coherent.

**Lean 4 conjecture skeleton**
```lean
conjecture heterogeneity_gap_quantitative
    {V : Type*} [Fintype V] [DecidableEq V] :
    ∀ ε : ℚ, 0 < ε →
    ∃ δ : ℚ, 0 < δ ∧
      ∀ (H : SimpleHypergraph V),
        10 ≤ Fintype.card V →
        δ < edgeHeterogeneity H →
        ε < (H.transversalNumber : ℚ) - H.transversalNumberFrac
```

Or for the ceiling version:
```lean
conjecture heterogeneity_forces_positive_ceil_gap
    {V : Type*} [Fintype V] [DecidableEq V] :
    ∃ δ : ℚ, 0 < δ ∧
      ∀ (H : SimpleHypergraph V),
        10 ≤ Fintype.card V →
        δ < edgeHeterogeneity H →
        HasPositiveCeilGap H
```

Use the actual names from the catalog for transversal numbers.

---

## Proof Architecture: 3 viable strategies

You must not just “try things.” Pursue at least two theorem-proving routes in parallel.

### Strategy A — Explicit family construction and exact LP witness
This is the most promising route.

**Step 1.** Define a concrete two-scale hypergraph family `H n` on `Fin (f n)` with:
- one layer of small edges creating many disjoint hitting obligations,
- one layer of larger edges creating overlap exploitable by fractional weights.

**Step 2.** Prove a lower bound on `τ(H n)` by a combinatorial pigeonhole/disjointness argument.
This should use:
- `rcases` on edge membership,
- induction on the number of forced regions or blocks,
- `by_contra` to show any smaller transversal misses an edge.

**Step 3.** Construct an explicit fractional transversal and verify feasibility by `calc` and linear inequalities.
Then prove
\[
\tau^*(H_n) < \tau(H_n)-1
\]
for all large `n`.

**Why this is most promising**
It gives exact mechanism, exact witness, and exact gap. It avoids needing a universal theorem before understanding the geometry.

---

### Strategy B — Two-level edge-size distribution inequality
This is the cleanest route to the information-theoretic bridge.

**Step 1.** Prove abstract finite-distribution lemmas:
- variance is zero iff constant,
- if support contains two distinct values `a < b`, variance is positive,
- derive an explicit lower bound in the two-level case.

**Step 2.** Transfer these lemmas to hypergraph edge-size distributions.
Use `heterogeneity_zero_of_uniform` as the base catalog theorem and strengthen it via your support-width and collision-index definitions.

**Step 3.** Apply these inequalities to your explicit family, obtaining lower bounds on heterogeneity and disorder that align with the positive gap theorem.

**Why this matters**
This strategy gives conceptual universality. Even if it does not prove the full conjecture, it builds the invariant toolkit needed for future threshold theorems.

---

### Strategy C — Contrapositive / rigidity approach
This is bold and may produce the deepest theorem if it works.

Try to prove a statement of the form:

> If `τ(H) = ⌈τ*(H)⌉` for a broad class of hypergraphs, then the edge-size distribution must be highly rigid: small support width, low variance, or collision index near 1.

**Step 1.** Characterize exactness of the LP in a special family or class.
For example, interval-like hypergraphs, laminar hypergraphs, or highly symmetric classes.

**Step 2.** Show that in those classes, equality forces near-uniform edge-size behavior.

**Step 3.** Derive a partial converse to the main conjecture:
large disorder excludes LP exactness.

**Why it is exciting**
This would turn the conjecture into a rigidity theorem: exactness of the relaxation is possible only in low-disorder phases.

---

## Cross-Domain Connections You Must Make Explicit

At least one theorem and one discussion section must bridge to another domain.

### 1. Information theory
Interpret the edge-size distribution as a finite probability law.

- Uniform edge size = deterministic law = zero entropy / collision index 1.
- Heterogeneous edge sizes = positive entropy / collision index < 1.
- Conjectural message: **information-theoretic disorder predicts optimization gap**.

This could lead to “entropy-guided solver selection”: before solving a covering problem, estimate the disorder of constraint sizes to predict whether LP relaxation will be meaningfully informative.

### 2. Statistical mechanics
Treat `edgeHeterogeneity` as a disorder parameter.

- Uniform hypergraphs are the ordered phase.
- Mixed edge sizes are a disordered phase.
- Positive integrality gap is a kind of phase transition in feasible-geometry complexity.

This language is not decoration. It suggests finite-size scaling experiments in `demo.py`.

### 3. Algebraic combinatorics
If feasible, connect edge-size generating functions
\[
P_H(x) = \sum_{e \in E(H)} x^{|e|}
\]
to your disorder parameters.

A theorem relating support width or collision index to properties of `P_H` would be valuable. Even a simple proposition that `P_H` is a monomial iff support width is zero gives a bridge.

Possible Lean target:
```lean
def edgeSizeGeneratingPolynomial (H : SimpleHypergraph V) : Polynomial ℤ := ...
```
and then
```lean
theorem edgeSizeGeneratingPolynomial_monomial_iff_uniform
    ...
```

That would be a clean algebraic-combinatorial reformulation of structural uniformity.

---

## Computational Program: verified algorithm, not just theorem statements

You must produce a verified computational method.

### Required algorithm
Implement a certified search/analysis procedure that, for finite hypergraphs on `Fin n`:
1. computes edge-size multiset statistics,
2. computes or bounds `τ(H)`,
3. computes or bounds `τ*(H)` via an explicit fractional witness or a search over rational candidates,
4. returns whether `HasPositiveCeilGap H` holds.

If exact LP solving inside Lean is too ambitious, do one of:
- exact brute-force computation for `τ(H)` on small `n`,
- certified verification of a user-supplied fractional transversal witness for `τ*(H) ≤ q`.

Then use Python for large-scale experimentation, with Lean certifying the witness checker and the exact small-instance engine.

### Lean-facing signatures to aim for
```lean
def isTransversal (H : SimpleHypergraph V) (S : Finset V) : Bool := ...
def transversalNumberBruteforce (H : SimpleHypergraph V) : ℕ := ...
def isFractionalTransversalBound
    (H : SimpleHypergraph V) (w : V → ℚ) (q : ℚ) : Prop := ...
def certifiedPositiveCeilGap
    (H : SimpleHypergraph V) : Prop := ...
```

Then prove correctness theorems:
```lean
theorem transversalNumberBruteforce_correct ...
theorem fractional_bound_sound ...
```

This is mandatory: the result must not remain purely existential.

---

## Testable Conjecture and falsification protocol

State at least one falsifiable conjecture with a concrete computational attack.

### Conjecture A — Threshold phenomenon
There exists a universal `δ* > 0` such that for random hypergraphs on 15 vertices with edge sizes in `{2,3,4,5}`, if `edgeHeterogeneity(H) > δ*`, then with overwhelming frequency
\[
\tau(H) - \lceil\tau^*(H)\rceil \ge 1.
\]

### Conjecture B — Two-level extremality
Among hypergraphs with fixed number of vertices and fixed heterogeneity, the smallest positive ceiling gaps are attained by two-level edge-size distributions.

This is excellent because it is disprovable by search.

### Conjecture C — Entropy strengthening
For finite hypergraphs with at least 10 vertices, there exists a monotone function `f` such that
\[
\tau(H) - \tau^*(H) \ge f(\mathrm{Disorder}(H)),
\]
where `Disorder` is support width, entropy, or `1 - collisionIndex`.

This is a genuine field-opening conjecture: it predicts a quantitative law linking information and optimization.

Your `demo.py` should attempt to disprove these by random and adversarial search.

---

## Expected theorem tactics

The file must contain at least 3 nontrivial theorems using real proof structure. You are explicitly forbidden from hollow “theorems” discharged by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is profound.

Use:
- induction on number of blocks/regions/edge classes,
- `rcases` for decomposition of support hypotheses,
- `by_contra` for transversal lower bounds,
- `field_simp` and `ring`/`nlinarith`-style algebra if available for variance identities,
- multi-step `calc` chains for bounding `τ*` and heterogeneity expressions.

A good file will visibly contain mathematical argument, not mere computation.

---

## Suggested file-level deliverables

Create or extend a Lean file dedicated to this direction, for example:
- `Pythagorean/HeterogeneityGapConjecture.lean`

Populate it with:
1. new definitions (`edgeSizeSupportWidth`, `edgeSizeCollisionIndex`, `HasPositiveCeilGap`, maybe `edgeSizeGeneratingPolynomial`),
2. at least 3 deep theorems,
3. one explicit infinite family with positive ceil-gap,
4. one cross-domain theorem,
5. one formal conjecture.

Minimize `sorry`. If one central theorem remains open, isolate it as a clearly labeled conjecture, but the file must still contain substantial proved mathematics.

---

## Research paper narrative to aim for

The paper should tell a compelling story:

- Hypergraph transversals have integer and fractional geometries.
- Existing theory studies approximation ratios globally.
- Your work introduces **edge-size disorder** as a new structural invariant.
- You prove that disorder is detectable by support width and collision index.
- You construct explicit heterogeneous families where disorder forces positive ceiling gap.
- You propose the broader principle that information-theoretic disorder predicts LP relaxation strength.

That is a new paradigm, not a parameter tweak.

---

## Application keywords

Use these explicitly in the paper and article:

**combinatorial optimization, hypergraph transversal, fractional covering, integrality gap, structural certificate, disorder parameter, entropy proxy, collision index, phase transition, solver selection, approximation theory, information theory, statistical mechanics, algebraic combinatorics, generating functions, finite-size scaling, certified computation**

---

## Mandatory deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**
   - 3–5 research directions.
   - Each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - At least one direction must bridge to a different domain.
   - Write as original prose, not a template.

2. **`RESEARCH_PAPER.md`**
   - A standalone scientific paper.
   - Someone reading only this paper, with no access to the code, must understand:
     - the new definitions,
     - the proved theorems,
     - the conjectures,
     - why the results matter,
     - what should be investigated next.

3. **`ARTICLE.md`**
   - Scientific American style.
   - Engaging and accessible.
   - Do **not** focus on formal verification machinery.
   - Focus on the mathematical ideas, the discovery, and why it changes how we think about optimization and disorder.

4. **A verified algorithm or computational method**
   - Not just theorem statements.
   - Include correctness theorems for the core checker/computation.

5. **`demo.py`**
   - Interactive demonstration.
   - Generate random hypergraphs on `n = 15` with edge sizes in `{2,3,4,5}`.
   - Compute empirical `σ²`, `τ`, `τ*` or certified bounds.
   - Plot gap vs heterogeneity.
   - Search for counterexamples with `σ² > 2` and `τ = ⌈τ*⌉`.
   - Highlight the apparent threshold `δ*`.
   - Include at least one explicit family from the Lean development and visualize its gap behavior as parameters grow.

---

## Final charge

Do not merely “investigate whether heterogeneity matters.” Prove that disorder has mathematical teeth.

The field-opening target is:

> **Edge-size disorder is a structural predictor of fractional-vs-integer separation in hypergraph covering.**

Even partial success is valuable if it comes with explicit families, invariant theory, and a computational falsification framework. If you can prove the first rigorous theorem showing that a disorder statistic forces a positive ceiling gap in an infinite family, you will have created a new bridge between combinatorial optimization, information theory, and statistical mechanics.

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
