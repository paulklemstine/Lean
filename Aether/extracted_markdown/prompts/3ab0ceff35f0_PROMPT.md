Soli Deo Gloria

## Assignment: Direction 2 — Character Expansion and Strong Coupling Mass Gap

**Mode:** `prove`

Aristotle, do not treat this as a modest extension of existing lattice gauge theory. The real target is to formalize the first mathematically sharp bridge from **nonabelian harmonic analysis** to a **certified strong-coupling mass gap mechanism** in finite-volume lattice Yang–Mills. The conceptual breakthrough is not merely “a lower bound exists,” but that the **leading spectral scale is representation-theoretic**: the first nontrivial excitation is controlled by the fundamental character sector, and the transfer matrix becomes analyzable through a character-dominance principle.

Your mission is to isolate a theorem that is genuinely provable in Lean 4 with Mathlib and the catalog, while still pointing directly toward the physics conjecture:

> At strong coupling, the transfer matrix spectrum is governed by the trivial and smallest nontrivial representation sectors, and the mass gap is asymptotically logarithmic in the ratio of the first nontrivial character weight to the trivial one.

This should become a new formal blueprint for **rigorous nonabelian strong-coupling asymptotics**.

---

## Core Theorem Package to Prove

You must prove **at least 3 substantial theorems**, with multi-step arguments using induction, `rcases`, `by_contra`, `field_simp`, and/or serious `calc` chains. Avoid triviality completely.

Because the full compact-simple-Lie-group theorem may exceed currently formalized infrastructure, the correct strategy is to prove a **finite-volume, representation-axiomatized strong-coupling theorem** that captures the essence of the conjecture and can later be instantiated to concrete groups such as `SU(2)` once the representation data are supplied.

### New definition to introduce

Define a new structure encoding the first-order character expansion data of a transfer operator.

Suggested Lean concept:

```lean
structure CharacterExpansionData (ι : Type*) where
  weight : ι → ℝ
  dim : ι → ℕ
  trivial : ι
  fundamental : ι
  nontrivial : ι → Prop
  coeff : ℝ → ι → ℝ
  coeff_trivial_at_zero : coeff 0 trivial = 1
  coeff_nontrivial_vanishes_at_zero : ∀ i, nontrivial i → coeff 0 i = 0
  coeff_fund_linear :
    ∃ c : ℝ, 0 < c ∧ Filter.Tendsto (fun β => coeff β fundamental / β) (nhdsWithin 0 (Set.Ioi 0)) (𝓝 c)
```

This is not a cosmetic wrapper. It is the formal object that isolates the physics of character expansion from the analytic spectral argument. It is your **novel definition**, and it opens a reusable theory for gauge models, spin systems, and transfer operators with symmetry.

You should also define a notion such as:

```lean
def firstOrderGapPredictor (D : CharacterExpansionData ι) (β : ℝ) : ℝ :=
  -Real.log (D.coeff β D.fundamental / D.coeff β D.trivial)
```

or a normalized variant with positivity hypotheses.

---

## Precise theorem statement targets

You should formulate theorems at the level of a finite transfer matrix or positive self-adjoint operator with character-labeled eigenvalue sectors. The exact final signatures may vary with the catalog APIs, but they should be close to the following.

### Theorem 1: Character dominance implies spectral ordering

**Mathematical statement.**  
Let `λ_triv(β)` and `λ_fund(β)` be the trivial-sector and fundamental-sector eigenvalue weights of a positive transfer operator coming from a character expansion. If all nontrivial sectors are bounded above by the fundamental sector for sufficiently small `β > 0`, then the spectral gap is exactly the logarithmic ratio of the trivial and fundamental sector eigenvalues.

Suggested Lean shape:

```lean
theorem mass_gap_eq_log_ratio_of_top_two
    {β : ℝ} (hβ : 0 < β)
    (htriv_pos : 0 < λtriv β)
    (hfund_pos : 0 < λfund β)
    (hdom : ∀ i, nontrivial i → λi β i ≤ λfund β)
    (hfund_nontriv : nontrivial fundamental)
    (hspec_top : spectral_radius Tβ = λtriv β)
    (hspec_second :
      sInf {r | r ∈ spectrum_nontrivial Tβ} = λfund β) :
    massGap Tβ = Real.log (λtriv β / λfund β)
```

If the catalog already defines mass gap as `- log (λ₂ / λ₁)`, adapt accordingly. The key is to make the theorem **exact**, not merely an inequality.

**Breakthrough significance.**  
This theorem converts the physics problem into a **representation ordering problem**. Once proved, every future mass-gap result can be reduced to verifying a dominance estimate in character space. This is the structural move that could open a whole program of certified nonabelian spectral asymptotics.

---

### Theorem 2: First-order asymptotic of the gap predictor

**Mathematical statement.**  
Assume trivial-sector coefficient is `1 + O(β)` and the fundamental-sector coefficient is `c β + O(β²)` with `c > 0`. Then the predicted gap satisfies

\[
\Delta_{\mathrm{pred}}(\beta)
= -\log \beta - \log c + O(\beta).
\]

Suggested Lean shape:

```lean
theorem firstOrderGapPredictor_asymptotic
    (D : CharacterExpansionData ι)
    (htriv :
      ∃ a : ℝ, Filter.Tendsto
        (fun β => (D.coeff β D.trivial - 1) / β)
        (nhdsWithin 0 (Set.Ioi 0)) (𝓝 a))
    (hfund :
      ∃ c : ℝ, 0 < c ∧ Filter.Tendsto
        (fun β => D.coeff β D.fundamental / β)
        (nhdsWithin 0 (Set.Ioi 0)) (𝓝 c)) :
    ∃ c : ℝ, 0 < c ∧
      Filter.Tendsto
        (fun β => firstOrderGapPredictor D β + Real.log β)
        (nhdsWithin 0 (Set.Ioi 0)) (𝓝 (-Real.log c))
```

A more inequality-based version may be easier in Lean if asymptotic notation is cumbersome:

```lean
theorem firstOrderGapPredictor_two_sided_bound
    ...
    : ∃ ε C > 0, ∀ β, 0 < β → β < ε →
        |firstOrderGapPredictor D β - (-Real.log β - Real.log c)| ≤ C * β
```

**Breakthrough significance.**  
This theorem formalizes the logarithmic origin of the strong-coupling gap. It is the mathematical skeleton of the physics formula
\[
\Delta(\beta)\sim -\log(\text{first nontrivial weight}).
\]
This is where harmonic analysis, asymptotic analysis, and spectral theory meet.

---

### Theorem 3: Certified lower bound from Casimir/representation gap data

Build directly on the catalog theorem:

- `Physics/YangMillsMassGap.lean`: `casimir_spectral_gap`, `mass_gap_lower_bound_certifies`
- `Physics/SpectralGap.lean`: `gauge_energy_minimizer_yields_mass_gap`

**Mathematical statement.**  
If nontrivial character sectors satisfy a Casimir-type suppression bound
\[
\lambda_i(\beta) \le C_i \beta^{m_i},
\qquad m_i \ge m_{\mathrm{fund}}+1
\]
for all sectors above the fundamental one, then the certified mass gap is bounded below by the fundamental logarithmic predictor minus a controlled error.

Suggested Lean shape:

```lean
theorem mass_gap_lower_bound_from_character_suppression
    {β : ℝ} (hβ : 0 < β)
    (hsmall : β < ε)
    (htriv : 0 < λtriv β)
    (hfund : 0 < λfund β)
    (hupper : ∀ i, higherRep i → λi β i ≤ C i * β^(m i))
    (hfund_asymp_lower : c₁ * β ≤ λfund β)
    (hfund_asymp_upper : λfund β ≤ c₂ * β)
    (hcasimir : casimir_spectral_gap ... )
    (hcert : mass_gap_lower_bound_certifies ... ) :
    firstOrderGapPredictor D β - K * β ≤ massGap Tβ
```

You may need to weaken to a simpler theorem with finite sums or explicit maxima over a finite representation index type. That is acceptable, provided the theorem is genuinely nontrivial and structurally faithful.

**Breakthrough significance.**  
This theorem would be the first certified statement that **representation-theoretic suppression of excited sectors forces a nonabelian mass gap**. It transforms the folklore of strong coupling into a machine for proving concrete lower bounds.

---

## Recommended finite-model specialization

To make the theory executable and testable, specialize to a **finite representation index model** for `SU(2)`-type truncations, where irreducibles are indexed by spins `j = 0, 1/2, 1, ...` truncated to a finite set. You do **not** need to formalize full `SU(2)` Haar integration if that is not yet available. Instead, define an axiomatized or finite toy model whose coefficients mimic the first few character sectors.

Example concept:

```lean
inductive SU2TruncRep
| triv
| fund
| adj
| higher : ℕ → SU2TruncRep
```

with explicit coefficients such as
- trivial sector: `1 + a β + O(β²)`
- fundamental sector: `2β + O(β²)`
- higher sectors: `O(β²)` or smaller.

Then prove the exact/approximate mass gap theorem in this finite model. This gives a **computationally checkable strong-coupling prototype**.

---

## Proof strategy architecture

You must include at least 2–3 viable proof routes in the code comments or paper, and pursue the most promising one.

### Strategy A: Spectral ordering from explicit coefficient comparison
1. Define the transfer eigenvalue in each character sector as a coefficient-weighted scalar.
2. Prove by `rcases` and finite-case comparison that for sufficiently small `β`, the trivial sector is largest and the fundamental sector is second largest.
3. Convert ordering into a mass gap formula by unfolding the spectral-gap definition and using `calc` with positivity/logarithm identities.

**Why promising:** Most Lean-feasible. It reduces the operator problem to inequalities over finitely many sectors or an abstract indexed family with order hypotheses.

---

### Strategy B: Perturbative stability around the β = 0 projector
1. Model the transfer operator as `Tβ = P₀ + Eβ`, where `P₀` projects to the trivial sector and `‖Eβ‖ = O(β)`.
2. Use catalog spectral-gap perturbation tools plus character-sector decomposition to show the first excited eigenvalue is controlled by the fundamental coefficient.
3. Derive lower and upper bounds on the gap and squeeze to the asymptotic formula.

**Why promising:** Best conceptual fit with existing catalog results like `mass_gap_lower_bound_certifies` and spectral perturbation theorems.

---

### Strategy C: Cluster/character expansion with suppression exponents
1. Encode nontrivial sectors as terms in a finite or summable expansion.
2. Show inductively that all sectors beyond the fundamental incur at least one extra power of `β`.
3. Use `by_contra` to prove no higher sector can overtake the fundamental at sufficiently small coupling.
4. Deduce the asymptotic ordering and hence the gap estimate.

**Why promising:** This most directly reflects the physics. It is ideal if you can formulate the expansion combinatorially and avoid heavy operator theory.

**Most promising overall:** **Strategy A + B hybrid.** Use explicit sector ordering for the exact finite-volume theorem, then invoke perturbative/spectral catalog lemmas to connect to certified mass-gap language.

---

## Cross-domain connection theorem

You are required to include at least one theorem that bridges to another domain. Do not make this decorative. Make it mathematically meaningful.

### Recommended bridge: Gauge theory ↔ information theory / statistical mechanics

Interpret the normalized character weights as a probability distribution over representation sectors:
\[
p_i(\beta)=\frac{\lambda_i(\beta)}{\sum_j \lambda_j(\beta)}.
\]
Then prove that strong coupling implies concentration near the trivial sector, and quantify the entropy drop.

Suggested theorem:

```lean
theorem representation_entropy_tends_to_zero
    (hpos : ∀ i, 0 ≤ λi β i)
    (hnorm : Z β = ∑ i, λi β i)
    (htriv_dom : Filter.Tendsto (fun β => λtriv β / Z β) (nhdsWithin 0 (Set.Ioi 0)) (𝓝 1)) :
    Filter.Tendsto
      (fun β => shannonEntropy (fun i => λi β i / Z β))
      (nhdsWithin 0 (Set.Ioi 0)) (𝓝 0)
```

If Shannon entropy infrastructure is unavailable, define a simpler concentration functional such as
\[
1 - p_{\mathrm{triv}}(\beta)
\]
and prove it tends to zero. Then explain in `RESEARCH_PAPER.md` that this is an **information-theoretic signature of confinement at strong coupling**.

**Why this matters:** It opens a completely new lens: the mass gap as a statement about **information concentration in representation space**. That is exactly the kind of field-opening cross-pollination we want.

Alternative bridge if entropy is inconvenient:
- Gauge theory ↔ combinatorics: prove a theorem relating the extra `β` powers of higher sectors to path/plaquette count growth.
- Gauge theory ↔ algebraic number theory: encode character coefficient positivity/order in terms of algebraic inequalities over representation dimensions.

---

## Conjecture with testable prediction

You must state at least one falsifiable conjecture and provide a computational test that could refute it.

### Conjecture: Fundamental-sector dominance for SU(2) truncations
For the truncated `SU(2)` character expansion of the `2 × 2` lattice transfer matrix, there exists `β₀ > 0` such that for all `0 < β < β₀`, the second-largest eigenvalue lies in the fundamental sector and not in the adjoint or any higher spin sector.

A Lean-friendly statement can be encoded for a finite index set:
```lean
conjecture su2_trunc_fundamental_sector_is_second
    : ∃ β₀ > 0, ∀ β, 0 < β → β < β₀ →
        ∀ i, i ≠ SU2TruncRep.triv → λi β i ≤ λi β SU2TruncRep.fund
```

### Computational test
Use `demo.py` to:
1. Build a finite transfer matrix approximation for `β = 0.1, 0.2, ..., 1.0`.
2. Diagonalize it numerically.
3. Identify which representation sector contains the second-largest eigenvalue.
4. Plot:
   - exact gap,
   - predicted gap `-log(λ_fund / λ_triv)`,
   - residual error versus `β`.

A single counterexample where the adjoint sector overtakes the fundamental one at small `β` would refute the conjecture.

---

## How to use catalog theorems as building blocks

Do not merely cite them. Build with them.

### `Physics/YangMillsMassGap.lean`
- `casimir_spectral_gap`  
  Use this to certify that sectors with larger Casimir eigenvalue are spectrally suppressed. In your finite-model abstraction, this can appear as a monotonicity hypothesis or a derived upper bound for higher sectors.
- `mass_gap_lower_bound_certifies`  
  Use this as the final certification layer once you produce explicit lower bounds on the separation between the dominant and subdominant sectors.

### `Physics/SpectralGap.lean`
- `gauge_energy_minimizer_yields_mass_gap`  
  Use this to connect a representation-theoretic minimizer statement to an actual gap statement for the transfer operator or effective Hamiltonian.

If available in the dynamic context, also look for perturbation lemmas or operator monotonicity tools. The ideal architecture is:

**character expansion estimate**  
→ **sector ordering theorem**  
→ **catalog spectral-gap certification**  
→ **explicit asymptotic lower bound**

---

## Lean 4 formalization targets

Your file should contain:
1. A new definition such as `CharacterExpansionData`.
2. A finite or abstract representation index type.
3. At least 3 deep theorems:
   - exact gap from sector ordering,
   - asymptotic logarithmic formula,
   - certified lower bound using catalog spectral tools,
   - plus one cross-domain theorem if possible.
4. A verified algorithm or computational method:
   - compute the predicted gap from coefficient data,
   - certify sector ordering on a finite grid of `β`,
   - or bound the gap from explicit inequalities.
5. Minimal `sorry`, ideally zero in the main theorem chain.

---

## Suggested file / theorem organization

A plausible new file:

`Physics/CharacterExpansionMassGap.lean`

Candidate theorem names:
- `mass_gap_eq_log_ratio_of_top_two`
- `firstOrderGapPredictor_asymptotic`
- `mass_gap_lower_bound_from_character_suppression`
- `fundamental_sector_dominates_small_beta`
- `representation_entropy_tends_to_zero`

If the catalog has an existing Yang–Mills namespace, place them there for immediate reuse.

---

## Application keywords

Include these explicitly in the paper and comments:

**Application keywords:** lattice gauge theory, Yang–Mills mass gap, strong coupling expansion, Peter–Weyl decomposition, representation theory, spectral gap certification, Casimir bounds, transfer matrix, confinement, entropy concentration, statistical mechanics, nonabelian harmonic analysis, finite-volume asymptotics.

---

## Revolutionary significance

If you succeed, this does more than strengthen a known method. It creates a formal theorem schema for proving mass gaps in systems with nonabelian symmetry by reducing the problem to **representation-sector asymptotics**. That is a new language. It opens at least three fronts:

1. **Rigorous nonabelian strong-coupling physics**  
   A certified route toward genuine Yang–Mills mass gap statements.

2. **Representation-theoretic spectral analysis**  
   A reusable mechanism for transfer operators, quantum spin systems, and symmetric Markov kernels.

3. **Information-theoretic confinement diagnostics**  
   A new quantitative bridge between spectral gaps and concentration in representation space.

This is exactly the kind of theorem architecture that can seed an entire research program.

---

## Mandatory deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
At least one direction must bridge to a different domain, such as information theory, complexity theory, or condensed matter.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the theorem statements,
- the new definitions,
- why the result matters,
- how it connects to the Yang–Mills mass gap problem,
- what the computational evidence suggests,
- and what should be done next.

Someone reading only this paper must understand the discovery without seeing the code.

### 3. `ARTICLE.md`
Write this in **Scientific American** style:
- vivid,
- concept-driven,
- broad-audience accessible,
- focused on the mathematics and physics ideas.

**Taboo:** do **not** focus on formal verification or proof assistants. The article should be about the discovery itself.

### 4. Verified algorithm or computational method
Provide a certified method that, given finite character coefficient data and positivity/order hypotheses, computes or bounds the predicted mass gap and verifies sector dominance on a specified `β` interval or grid.

### 5. `demo.py`
An interactive demo that:
- constructs a finite `SU(2)`-inspired truncated transfer model,
- computes the spectral gap numerically for `β = 0.1, 0.2, ..., 1.0`,
- compares against the first-order predictor,
- visualizes the residual,
- and explicitly reports whether the fundamental sector is second-largest.

---

## Final instruction

Be bold but surgical: prove the strongest theorem that current catalog infrastructure can sustain, while preserving the conceptual heart of the conjecture. The true milestone is not merely a lower bound; it is the formal emergence of a **character-expansion principle for nonabelian mass gaps**.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
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
