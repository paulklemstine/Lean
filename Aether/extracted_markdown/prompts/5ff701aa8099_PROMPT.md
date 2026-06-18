Soli Deo Gloria

## Assignment: Direction 1: Sharp Representation-Theoretic Bounds via GL₂ Decomposition

### Mode: `prove`

Prove a genuinely new representation-theoretic spectral gap theorem for certified generators of `GL₂(𝔽_q)` by decomposing the averaging operator across the full irreducible dual. The goal is not a local improvement of an existing expander estimate: it is to build a deterministic, certificate-driven spectral theory for finite linear groups that rivals and conceptually reframes Bourgain–Gamburd-type expansion. The breakthrough target is to show that the obstruction to optimal expansion is governed by the principal series, and that all other families are uniformly better.

This would open a new program: **explicit nonabelian harmonic analysis as a source of certified expanders**, with direct bridges to automorphic representation theory, character-sum technology, quantum mixing, and derandomized pseudorandomness.

## Core theorem target

Let `q` be an odd prime, `G = GL (Fin 2) (ZMod q)`, and let
`S = {g, g⁻¹, h, h⁻¹}` for a certified pair `(g,h)` in the sense of the catalog. Define the normalized adjacency / averaging operator
\[
A_S := \frac14(\lambda_g + \lambda_{g^{-1}} + \lambda_h + \lambda_{h^{-1}})
\]
acting on complex-valued functions on `G`, where `λ` denotes the left-regular representation.

### Precise theorem statement
You should aim to formalize a theorem of the following shape:

> **Theorem (familywise spectral domination for certified pairs).**  
> There exists an absolute constant `C > 0` and a threshold `q₀` such that for every prime `q ≥ q₀`, for every certified pair `(g,h)` in `GL₂(𝔽_q)`, and for every nontrivial irreducible complex representation `ρ` of `GL₂(𝔽_q)`, if
> \[
> M_\rho(S) := \frac14\bigl(\rho(g)+\rho(g^{-1})+\rho(h)+\rho(h^{-1})\bigr),
> \]
> then
> \[
> \|M_\rho(S)\| \le 1 - \frac{C}{q}.
> \]
> Moreover, among the four irreducible families
> 1. determinant twists,
> 2. principal series,
> 3. Steinberg twists,
> 4. cuspidal representations,
> the maximal nontrivial operator norm is attained by a principal series representation.

A more formal “first breakthrough” version, if the exact asymptotic domination theorem is too ambitious, is:

> **Theorem (uniform familywise comparison).**  
> For all sufficiently large primes `q`, every certified pair `(g,h)` satisfies
> \[
> \max_{\rho \in \mathrm{Steinberg}\cup\mathrm{Cuspidal}} \|M_\rho(S)\|
> \;\le\;
> \max_{\rho \in \mathrm{PrincipalSeries}} \|M_\rho(S)\|.
> \]
> Hence the nontrivial spectral radius of `A_S` is controlled by the principal series block.

And the strongest quantitative target suggested by the conjecture is:

> **Sharp asymptotic bound.**  
> For every `ε > 0`, there exists `q₀(ε)` such that for every prime `q ≥ q₀(ε)` and every certified pair `(g,h)`,
> \[
> \gamma(S) \ge \frac{1/2-\varepsilon}{q},
> \]
> where `γ(S) = 1 - λ₂(S)` is the spectral gap of the simple random walk on the Cayley graph.

## Lean 4 formal target

You should introduce a mathematically honest Lean abstraction for the representation-family decomposition, even if the first file proves theorems only for a partially formalized family partition.

A plausible Lean 4 target signature is:

```lean
def averagingOperator
  {q : ℕ} [Fact q.Prime]
  (g h : GL (Fin 2) (ZMod q))
  : Module.End ℂ (Map q) :=
  -- precise implementation to be designed

def spectralGap
  {q : ℕ} [Fact q.Prime]
  (g h : GL (Fin 2) (ZMod q)) : ℝ :=
  1 - ‖restrictToMeanZero (averagingOperator g h)‖

/-- New structure encoding certified GL₂ pairs with spectral hypotheses. -/
structure CertifiedGL2Pair (q : ℕ) [Fact q.Prime] where
  g h : GL (Fin 2) (ZMod q)
  cert : Prop
  irreducible_charpoly_g : Prop
  no_common_invariant_line : Prop
  -- align with catalog certificates

inductive GL2RepFamily
  | detTwist
  | principalSeries
  | steinbergTwist
  | cuspidal

def familyOperatorNorm
  {q : ℕ} [Fact q.Prime]
  (P : CertifiedGL2Pair q) :
  GL2RepFamily → ℝ :=
  -- supremum over irreducibles in that family of the norm of M_ρ(S)

theorem spectral_gap_lower_bound_of_certified
  {q : ℕ} [hq : Fact q.Prime]
  (P : CertifiedGL2Pair q) :
  ∃ C > 0, spectralGap P.g P.h ≥ C / q := by
  sorry

theorem principalSeries_dominates_large_q
  :
  ∃ q0 : ℕ, ∀ {q : ℕ} [Fact q.Prime],
    q ≥ q0 →
    ∀ (P : CertifiedGL2Pair q),
      max (familyOperatorNorm P GL2RepFamily.detTwist)
        (max (familyOperatorNorm P GL2RepFamily.steinbergTwist)
             (familyOperatorNorm P GL2RepFamily.cuspidal))
      ≤ familyOperatorNorm P GL2RepFamily.principalSeries := by
  sorry

theorem sharp_gap_asymptotic
  (ε : ℝ) (hε : 0 < ε) :
  ∃ q0 : ℕ, ∀ {q : ℕ} [Fact q.Prime],
    q ≥ q0 →
    ∀ (P : CertifiedGL2Pair q),
      spectralGap P.g P.h ≥ ((1 / 2 : ℝ) - ε) / q := by
  sorry
```

The exact implementation details may differ, but your theorem statements should be comparably precise, quantified, and mathematically meaningful.

## Required new definitions

You must define at least one genuinely new concept not already present in the catalog. Recommended options:

1. `CertifiedGL2Pair q`: a bundled certificate structure combining algebraic generation/nondegeneracy conditions with the spectral setup.
2. `GL2RepFamily`: an inductive type indexing the four irreducible families.
3. `familyOperatorNorm`: the supremal operator norm of the averaging operator on a representation family.
4. `PrincipalSeriesWitness q P`: a structure expressing that the extremal nontrivial eigenvalue is realized in the principal series.

At least one of these should be used in a substantial theorem, not merely introduced and ignored.

## Catalog build points

You must explicitly build on the following catalog results and explain in comments/prose how they enter the proof:

- `Catalog/Pythagorean/UniformSpectralGap.lean`
  - `singerLike_no_eigenvalue₂`
  - `singerLike_no_invariant_line₂`
  - `GL2Cert.harmonic_meanzero_eq_zero`
- `Catalog/Algebra/MatrixGroupGeneration.lean`
  - `eq_bot_or_top_of_charpoly_irreducible`
- `Catalog/Pythagorean/CertificateExpanders.lean`
  - `harmonic_meanzero_eq_zero`
  - `certified_pair_harmonic_trivial`

These are not ornamental references. Use them as the algebraic certification layer that rules out low-dimensional invariant obstructions, allowing the representation-theoretic analysis to begin from a genuinely mixing pair.

### How these should be used
- `singerLike_no_eigenvalue₂` and `singerLike_no_invariant_line₂` should be the mechanism that excludes degenerate fixed-vector and invariant-line behavior for the certified element `g`, especially inside low-rank models of principal/Steinberg blocks.
- `eq_bot_or_top_of_charpoly_irreducible` should be used to force dichotomy on invariant subspaces generated by the Singer-like element, reducing the possibility of intermediate invariant structures.
- `harmonic_meanzero_eq_zero` and `certified_pair_harmonic_trivial` should be used to identify trivial harmonic components and isolate the mean-zero subspace where the genuine spectral gap lives.

## At least 3 deep theorems

Your Lean development must contain at least 3 substantial theorems with nontrivial proof structure. Suggested theorem package:

1. **No low-dimensional obstruction theorem**
   ```lean
   theorem certified_no_nontrivial_invariant_line
     {q : ℕ} [Fact q.Prime] (P : CertifiedGL2Pair q) :
     ¬ ∃ L : Submodule (ZMod q) ((Fin 2) → ZMod q),
         L ≠ ⊥ ∧ L ≠ ⊤ ∧
         IsInvariantUnderPair P.g P.h L := by
     ...
   ```
   Use `rcases`, contradiction, and catalog irreducibility tools.

2. **Family comparison theorem**
   ```lean
   theorem steinberg_cuspidal_better_than_principal
     {q : ℕ} [Fact q.Prime] (hq : q ≥ q0) (P : CertifiedGL2Pair q) :
     max (familyOperatorNorm P GL2RepFamily.steinbergTwist)
         (familyOperatorNorm P GL2RepFamily.cuspidal)
       ≤ familyOperatorNorm P GL2RepFamily.principalSeries := by
     ...
   ```
   Use multi-step `calc`, inequalities, and reduction lemmas.

3. **Spectral gap lower bound theorem**
   ```lean
   theorem certified_spectralGap_ge_inv_q
     {q : ℕ} [Fact q.Prime] (P : CertifiedGL2Pair q) :
     spectralGap P.g P.h ≥ C / q := by
     ...
   ```
   Use contradiction, decomposition of the regular representation, and familywise norm bounds.

If the full comparison theorem is too large in one file, prove an intermediate theorem that principal series controls all nontrivial **certified low-rank matrix coefficient obstructions**, and make that mathematically sharp.

## Proof strategy architecture

### Strategy A: Representation-family decomposition + explicit matrix coefficient bounds
This is the most promising route.

1. **Decompose the regular representation** into irreducible families of `GL₂(𝔽_q)`: one-dimensional twists, principal series, Steinberg twists, cuspidals.
2. **Define `M_ρ(S)` familywise** and prove that the nontrivial spectral radius of the Cayley operator is the maximum of `‖M_ρ(S)‖` over nontrivial irreducibles.
3. **Use certified algebraic input** to show one-dimensional and nearly reducible obstructions are absent or strongly bounded.
4. **Bound principal series via character sums / induced-model formulas**, where the action of a Singer-like element should reduce to oscillatory sums over `𝔽_q` or `𝔽_q^×`.
5. **Show Steinberg and cuspidal families gain extra cancellation**, so their operator norms are strictly smaller than the principal series extremum.

Why this is best: it aligns directly with the known classification of irreducibles of `GL₂(𝔽_q)` and turns the spectral problem into a controlled finite list of analytic estimates. It also gives a clear computational path for `demo.py`.

### Strategy B: Trace / character method with familywise moment bounds
A second route is to avoid explicit operator models initially.

1. Express powers or moments of `A_S` using traces in the regular representation.
2. Decompose the trace by irreducible characters.
3. Use explicit character tables or familywise character formulas to compare contribution sizes.
4. Infer that the principal series contributes the dominant nontrivial eigenvalue asymptotically.

Why this is attractive: traces are often easier to formalize than full operator norms. Why it is riskier: converting trace information into sharp operator norm domination may require additional inequalities that lose the constant.

### Strategy C: Geometric action on projective line / Bruhat model
This is the most conceptual cross-over path.

1. Realize principal series representations through functions on `P¹(𝔽_q)` or induced models from the Borel subgroup.
2. Interpret the averaging operator as a transfer operator on projective configurations.
3. Use the certified Singer-like condition to force large orbits and no invariant lines.
4. Compare with Steinberg/cuspidal via quotient/subrepresentation geometry or Deligne–Lusztig-style cancellation heuristics.

Why it matters: this route could reveal that the principal series is dominant for geometric reasons, not merely by casework. It may create a reusable architecture for `GL_n` later.

## Concrete mathematical insight to pursue

The deepest conceptual claim here is:

> The worst nontrivial eigenvalue for certified `GL₂(𝔽_q)` Cayley walks is not an accident of low-dimensional noise; it is the shadow of the Borel boundary. The principal series should dominate because it is the representation-theoretic avatar of the projective line, where algebraic generators have the weakest cancellation. Cuspidal and Steinberg blocks are “more oscillatory” and therefore mix faster.

This is the statement that makes the project field-opening rather than technical. If formalized, it suggests a general principle:
- **boundary representations control expansion in finite groups of Lie type**.

That principle would connect expander theory, automorphic forms, and finite harmonic analysis in a new deterministic framework.

## Cross-domain connections

You must include at least one theorem connecting this project to another domain. Strong options:

### Option 1: Quantum information / quantum walks
Interpret `M_ρ(S)` as a finite-dimensional quantum channel or Hermitian quantum walk block.

Possible theorem target:
```lean
theorem certified_quantum_mixing_bound
  {q : ℕ} [Fact q.Prime] (P : CertifiedGL2Pair q) :
  ∀ ρ in NontrivialIrreducibleReps q,
    quantumMixingRate (familyChannel P ρ) ≤ 1 - C / q := by
  ...
```
This connects spectral gap to convergence of noncommutative random walks and finite quantum scrambling.

### Option 2: Additive combinatorics / pseudorandomness
Show that spectral gap implies flattening of convolutions and near-uniform sampling on `GL₂(𝔽_q)`.

Possible theorem target:
```lean
theorem certified_convolution_flattening
  {q : ℕ} [Fact q.Prime] (P : CertifiedGL2Pair q) :
  ∀ n ≥ n0, ‖μP^[n] - uniformMeasure q‖₂ ≤ exp (-C * n / q) := by
  ...
```
This would bridge to derandomization and sampler construction.

### Option 3: Arithmetic geometry / Weil bounds
Make explicit that the principal-series estimates reduce to finite-field character sums controlled by Weil-type cancellation. Even if Weil’s theorem itself is not fully formalized here, state and test the exact sums numerically in `demo.py`.

## Application keywords

Include these keywords in your paper and comments:
- explicit expanders
- spectral gap
- finite groups of Lie type
- principal series
- Steinberg representation
- cuspidal representation
- character sums
- Weil bounds
- deterministic expansion
- quantum mixing
- pseudorandomness
- Cayley graphs
- harmonic analysis
- representation growth
- automorphic analogy

## Conjecture with testable prediction

State this explicitly in the Lean file and in `FUTURE_DIRECTIONS.md`:

> **Conjecture (principal-series extremality).**  
> For every prime `q ≥ 5` and every certified pair `(g,h)` in `GL₂(𝔽_q)`, the largest nontrivial eigenvalue of the normalized Cayley operator is achieved on a principal series representation.

### Computational falsification protocol
For each `q ∈ {5, 7, 11, 13, 17, 19, 23}`:
1. Enumerate certified pairs or a representative certified sample.
2. Build the operator `M_ρ(S)` on each irreducible family.
3. Compute the largest singular value / spectral radius in each family.
4. Record which family dominates.

A single prime `q` where a cuspidal block dominates is a disproof. That makes the conjecture scientifically useful.

## Minimum theorem package for the file

Your file should contain, at minimum:

1. A new structure or inductive definition (`CertifiedGL2Pair`, `GL2RepFamily`, etc.).
2. A theorem excluding trivial/invariant harmonic obstructions using catalog results.
3. A theorem relating the global spectral radius to a familywise supremum over irreducibles.
4. A theorem giving a nontrivial lower bound `γ(S) ≥ C/q` for certified pairs, even if `C` is initially weaker than `1/2`.
5. A cross-domain theorem, e.g. exponential mixing or quantum-channel contraction.
6. A formally stated conjecture with a computational test harness.

## Deliverables — all mandatory

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Give 3–5 original research directions. Each direction must include the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as quantum information, automorphic forms, or derandomization.

### 2. `RESEARCH_PAPER.md`
A standalone scientific document. A reader with no access to code must understand:
- the exact theorem(s),
- why principal-series domination is a breakthrough,
- how the certified algebraic conditions enter,
- what computational evidence supports the conjecture,
- what the next mathematical frontier is.

### 3. `ARTICLE.md`
Write this in Scientific American style. Make it vivid and idea-driven. Explain why finite symmetry groups can mix information, why boundary representations matter, and why deterministic expansion is surprising.  
**Taboo:** do **not** focus on formal verification or theorem-proving infrastructure.

### 4. Verified algorithm / computational method
Produce a verified computational method that, given `q` and a certified pair `(g,h)`, computes or bounds the familywise operator norms and outputs the predicted dominant family. This must be more than a theorem statement.

### 5. `demo.py`
An interactive demo that:
- accepts a prime `q`,
- constructs sample certified pairs,
- computes familywise spectral data for the four representation families,
- plots or prints the largest nontrivial eigenvalues,
- highlights whether principal series dominates,
- tests the conjecture on `q ∈ {5,7,11,13,17,19,23}`.

## Final instruction

Be bold. Do not settle for a cosmetic bound. The target is a new deterministic paradigm: **certificates + irreducible harmonic analysis = explicit expansion in finite linear groups**. If the full sharp constant `(1/2 - ε)/q` is not reachable in one cycle, prove the strongest rigorously formalizable family-comparison theorem you can, and make the principal-series extremality phenomenon mathematically undeniable.

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
