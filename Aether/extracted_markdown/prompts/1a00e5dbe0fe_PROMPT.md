Soli Deo Gloria

## Assignment: Direction 5 — Quantum Algorithmic Phase Transitions via Lorentzian Polynomials

**Mode:** `prove`

Aristotle, this is not a refinement project. This is an attempt to carve out a new interface between **Lorentzian geometry of generating polynomials** and **algorithmic phase transitions in quantum sampling**. The target is a mathematically precise bridge from a geometric stability invariant to a complexity-theoretic noise threshold. If this works even in a sharply delimited toy regime, it opens an entirely new program: **quantum advantage as a Lorentzian stability phenomenon**.

You should not aim for vague analogy. You should prove exact theorems for a formally defined model, build a verified computational procedure for estimating the critical radius, and extract falsifiable predictions for boson-sampling-style instances.

---

## Core Vision

The permanent polynomial sits at the crossroads of combinatorics, hyperbolic/Lorentzian geometry, and quantum optics. Boson sampling amplitudes are permanents of submatrices; noise perturbs those amplitudes; the output distribution degrades until approximate classical simulation becomes plausible. The conjectural leap is:

> **The onset of classical simulability is governed by the loss of Lorentzian stability of the associated amplitude polynomial.**

This is the right kind of theorem to pursue because it is:
- structurally new,
- mathematically nontrivial,
- computationally testable on small instances,
- and conceptually explosive: it reframes “quantum hardness under noise” as a **phase transition in the geometry of polynomial coefficient space**.

Build directly on:

- `Pythagorean/NoiseStabilityDefs.lean`: `LorentzianStableUnder`
- `Pythagorean/NoiseStabilityTheorems.lean`: `spectralGap_pos_of_lorentzian`

The second theorem is especially important: it is already a **geometry → quantitative robustness transfer**. Your task is to convert that into a **geometry → algorithmic phase-boundary transfer** in a rigorously defined finite model.

---

## New Definitions You Must Introduce

You must define at least one genuinely new concept not already in the catalog. I recommend introducing all three of the following.

### 1. Lorentzian stability radius for a polynomial family
Define a quantitative radius attached to a polynomial `p` and perturbation family `Δ`:

- the supremal `r ≥ 0` such that every perturbation of size at most `r` preserves Lorentzian stability.

Suggested Lean-facing structure:
```lean
def lorentzianStabilityRadius
  (p : MvPolynomial σ ℝ)
  (perturb : MvPolynomial σ ℝ → MvPolynomial σ ℝ → Prop) : ℝ := ...
```

Or more concretely, for norm-bounded perturbations:
```lean
def coeffPerturbationBounded
  (ε : ℝ) (p q : MvPolynomial σ ℝ) : Prop := ...

def lorentzianRadius
  (p : MvPolynomial σ ℝ) : ℝ := sSup {ε | 0 ≤ ε ∧ LorentzianStableUnder p ε}
```

You may need a finite-support coefficient norm on homogeneous multivariate polynomials of fixed degree. If Mathlib support is awkward, work with a finite index type and a finitely supported coefficient vectorization.

### 2. A finite quantum sampling proxy model
Do **not** attempt to formalize full boson sampling complexity theory. Instead define a mathematically clean finite proxy capturing the same phase-transition idea.

For example:
```lean
structure QuantumSamplingProxy (ι : Type) where
  ampPoly : MvPolynomial ι ℝ
  noiseFamily : ℝ → MvPolynomial ι ℝ
  idealHardRegion : Set ℝ
```

or better, define a “critical noise predicate” based on spectral gap / anti-concentration surrogate:
```lean
def AlgorithmicallySeparated
  (p : MvPolynomial σ ℝ) (ε : ℝ) : Prop := ...
```

The exact content may use positivity of an associated spectral quantity, nondegeneracy of Hessian signature, or a certified lower bound inherited from `spectralGap_pos_of_lorentzian`.

### 3. Permanent-family polynomial or matching proxy
Since full permanent formalization may be heavy, define a combinatorial proxy polynomial that still carries the intended geometry and algorithmic meaning. Two good options:

- a **bipartite matching generating polynomial**, or
- a **small permanent polynomial** over finite matrices.

The key is to keep the object close enough to boson sampling amplitudes that the bridge is scientifically meaningful.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**. Below are the target statements. If the exact library APIs force mild reformulation, preserve the mathematical content.

---

### Theorem 1 — Positive radius from Lorentzian stability

**Mathematical statement.**  
For every homogeneous polynomial `p` with Lorentzian stability, there exists a positive perturbation radius `ε > 0` such that every sufficiently small coefficient perturbation preserves a positive spectral gap proxy. This is the first rigorous “stability implies algorithmic separation” theorem.

A suitable Lean-style target:

```lean
theorem exists_positive_algorithmic_radius_of_lorentzian
  {σ : Type} [Fintype σ] [DecidableEq σ]
  (p : MvPolynomial σ ℝ)
  (hp_hom : IsHomogeneous p)
  (hp_lor : Lorentzian p) :
  ∃ ε > 0, ∀ q : MvPolynomial σ ℝ,
    coeffPerturbationBounded ε p q →
    spectralGapProxy q > 0
```

If `Lorentzian p` is not the catalog predicate, replace it with the available `LorentzianStableUnder`-based formulation:
```lean
theorem exists_positive_algorithmic_radius_of_lorentzian
  ...
  (hp : LorentzianStableUnder p 0) :
  ∃ ε > 0, ∀ q, coeffPerturbationBounded ε p q → spectralGapProxy q > 0
```

**Why this is a breakthrough.**  
This theorem is the formal seed of the entire program: it turns a geometric positivity condition into a **certified noise margin**. Even if `spectralGapProxy` is a surrogate rather than full classical hardness, this is already a new mathematical transfer principle.

**Proof strategy options.**
1. **Catalog-driven transfer (most promising).**
   - Use `spectralGap_pos_of_lorentzian` as the endpoint positivity theorem.
   - Show that Lorentzian stability persists under sufficiently small coefficient perturbations.
   - Package the perturbation threshold as an existential positive radius.
   - This is the most promising because it directly leverages the vetted geometry-to-gap machinery.

2. **Contrapositive/by_contra route.**
   - Assume no positive radius exists.
   - Construct a sequence of perturbations converging to `p` with nonpositive spectral gap proxy.
   - Use closure/openness of the Lorentzian region to contradict `hp_lor`.
   - This path is elegant if topological continuity lemmas are manageable.

3. **Inductive degree-reduction route.**
   - Prove perturbative preservation for low degree first.
   - Use derivative closure properties of Lorentzian polynomials to bootstrap degree.
   - This is deeper but may require more infrastructure than the catalog already supplies.

---

### Theorem 2 — Monotonicity of certified simulability threshold under radius loss

**Mathematical statement.**  
If one polynomial is more noise-stable in the Lorentzian sense than another, then its certified algorithmic threshold is at least as large. This gives an order-theoretic principle for comparing instances.

Suggested Lean target:
```lean
theorem certifiedThreshold_mono_of_radius_mono
  {σ : Type} [Fintype σ] [DecidableEq σ]
  (p q : MvPolynomial σ ℝ)
  (hmono : lorentzianRadius p ≤ lorentzianRadius q) :
  certifiedThreshold p ≤ certifiedThreshold q
```

Or, if you define threshold directly from the spectral-gap positivity region:
```lean
def certifiedThreshold (p : MvPolynomial σ ℝ) : ℝ := ...

theorem certifiedThreshold_lower_bound_of_lorentzianRadius
  ...
  : certifiedThreshold p ≥ lorentzianRadius p
```

**Why this matters.**  
This theorem says the geometric invariant is not merely decorative; it is **order-controlling**. It allows one to compare families of quantum sampling instances by geometry alone.

**Proof strategy options.**
1. **Set-theoretic threshold comparison.**
   - Define the certified threshold as a supremum over `ε` for which the proxy remains positive.
   - Show inclusion of admissible perturbation sets from radius monotonicity.
   - Conclude by `sSup` monotonicity.

2. **Calc-chain via lower bounds.**
   - First prove `lorentzianRadius p ≤ certifiedThreshold p`.
   - Then combine with `hmono` and transitivity.
   - This is likely the cleanest route in Lean.

3. **By contradiction using witness perturbations.**
   - If thresholds violated monotonicity, produce a perturbation that destroys the gap before the Lorentzian radius allows.
   - Contradict Theorem 1.

---

### Theorem 3 — Cross-domain theorem: combinatorial generating polynomials induce quantum proxy robustness

This is your explicit **cross-domain connection theorem**.

**Mathematical statement.**  
For a combinatorial generating polynomial arising from a matching/matroid/permanent-style construction, Lorentzian stability implies a positive certified robustness threshold in the quantum sampling proxy model.

Suggested Lean target:
```lean
theorem matchingPoly_quantumProxy_robust
  {ι : Type} [Fintype ι] [DecidableEq ι]
  (G : SimpleGraph ι)
  (p := matchingGeneratingPolynomial G) :
  Lorentzian p →
  ∃ ε > 0, ∀ δ : ℝ,
    0 ≤ δ → δ < ε →
    AlgorithmicallySeparated (applyNoise p δ) δ
```

If you formalize a matrix/permanent proxy:
```lean
theorem permanentProxy_quantumPhase_prethreshold
  {n : ℕ}
  (A : Matrix (Fin n) (Fin n) ℝ)
  (hPSD : A.PosSemidef) :
  ∃ ε > 0, ∀ δ : ℝ,
    0 ≤ δ → δ < ε →
    AlgorithmicallySeparated (permanentProxyPoly A) δ
```

**Why this is revolutionary.**  
This theorem crosses from **combinatorial Hodge theory / Lorentzian polynomials** into **quantum algorithmics**. Even a proxy version is a first foothold toward a theorem saying that the geometry underlying negative dependence and spectral concentration also governs the persistence of quantum sampling hardness.

**Proof strategy options.**
1. **Instantiate Theorem 1 with a certified Lorentzian family (best route).**
   - Prove the generating polynomial belongs to a Lorentzian class.
   - Apply the general positive-radius theorem.
   - This is ideal if the family’s Lorentzian property is already known or easy to encode.

2. **Direct Hessian-signature argument.**
   - Show the combinatorial polynomial satisfies the Lorentzian Hessian signature inequalities.
   - Transfer to spectral gap positivity under perturbation.
   - More direct mathematically, but likely more formalization-heavy.

3. **Reduction to a known stable family.**
   - Express your polynomial as a specialization / polarization / derivative closure of an already Lorentzian polynomial.
   - Then use closure properties plus the catalog theorem.
   - This may be especially effective if the permanent itself is too difficult to formalize.

---

## Strongly Recommended Fourth Theorem

If feasible, add a theorem that makes the “phase transition” language mathematically sharp.

```lean
theorem exists_critical_value_for_proxy_phase_transition
  {σ : Type} [Fintype σ] [DecidableEq σ]
  (p : MvPolynomial σ ℝ)
  (hp : Lorentzian p) :
  ∃ τ ≥ 0, 
    (∀ ε, 0 ≤ ε ∧ ε < τ → AlgorithmicallySeparated (applyNoise p ε) ε) ∧
    (∀ η > 0, ∃ ε, τ ≤ ε ∧ ε < τ + η ∧ ¬ AlgorithmicallySeparated (applyNoise p ε) ε)
```

This would be spectacular because it upgrades “there exists a positive safe regime” to “there is a mathematically defined critical boundary.”

---

## Lean 4 Type Signature Guidance

You asked for precise theorem statements with Lean signatures. The exact predicate names may vary with the catalog, but your file should expose signatures close to these:

```lean
def coeffNormDiff
  {σ : Type} [Fintype σ] [DecidableEq σ]
  (p q : MvPolynomial σ ℝ) : ℝ := ...

def coeffPerturbationBounded
  {σ : Type} [Fintype σ] [DecidableEq σ]
  (ε : ℝ) (p q : MvPolynomial σ ℝ) : Prop :=
  coeffNormDiff p q ≤ ε

def spectralGapProxy
  {σ : Type} [Fintype σ] [DecidableEq σ]
  (p : MvPolynomial σ ℝ) : ℝ := ...

def certifiedThreshold
  {σ : Type} [Fintype σ] [DecidableEq σ]
  (p : MvPolynomial σ ℝ) : ℝ := ...

theorem exists_positive_algorithmic_radius_of_lorentzian
  {σ : Type} [Fintype σ] [DecidableEq σ]
  (p : MvPolynomial σ ℝ)
  (hp_hom : IsHomogeneous p)
  (hp_lor : Lorentzian p) :
  ∃ ε > 0, ∀ q : MvPolynomial σ ℝ,
    coeffPerturbationBounded ε p q →
    0 < spectralGapProxy q := ...

theorem lorentzianRadius_le_certifiedThreshold
  {σ : Type} [Fintype σ] [DecidableEq σ]
  (p : MvPolynomial σ ℝ) :
  lorentzianRadius p ≤ certifiedThreshold p := ...

theorem certifiedThreshold_mono_of_radius_mono
  {σ : Type} [Fintype σ] [DecidableEq σ]
  (p q : MvPolynomial σ ℝ)
  (hmono : lorentzianRadius p ≤ lorentzianRadius q) :
  certifiedThreshold p ≤ certifiedThreshold q := ...

theorem matchingPoly_quantumProxy_robust
  {ι : Type} [Fintype ι] [DecidableEq ι]
  (G : SimpleGraph ι) :
  let p := matchingGeneratingPolynomial G
  Lorentzian p →
  ∃ ε > 0, ∀ δ : ℝ,
    0 ≤ δ → δ < ε →
    AlgorithmicallySeparated (applyNoise p δ) δ := ...
```

If `MvPolynomial` becomes intractable, you may replace it with a custom finite homogeneous polynomial structure, but only if that simplification enables real theorems rather than weakening the mathematics.

---

## Proof Architecture: 2–3 Step Tactical Plans

Your file must contain at least 3 theorems with genuinely deep proof scripts using induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc`. Here is how to force mathematical depth.

### Plan A — Radius theorem
1. **Unpack Lorentzian stability into perturbative openness.**
   - Use `rcases` on the catalog theorem or your radius definition to obtain a candidate margin.
2. **Transfer to spectral positivity.**
   - Apply `spectralGap_pos_of_lorentzian`.
3. **Contradiction closure argument.**
   - Use `by_contra hneg` to derive a sequence of violating perturbations inside every radius.

### Plan B — Threshold monotonicity
1. Define thresholds as `sSup` of admissible perturbation radii.
2. Show set inclusion of admissible radii by hypothesis `hmono`.
3. Use a `calc` chain with `le_csSup` / `csSup_le`-style lemmas.

### Plan C — Cross-domain combinatorial theorem
1. Construct the generating polynomial recursively on graph size or degree.
   - This gives you an opportunity to use induction.
2. Prove Lorentzian preservation under your graph operation / polynomial recurrence.
3. Apply the general radius theorem to conclude algorithmic separation.

If possible, include at least one theorem whose proof genuinely uses `field_simp` in a Hessian/discriminant inequality or rational-function bound arising from a spectral proxy.

---

## Most Promising Route

The **most promising route** is:

1. **Do not formalize full boson sampling complexity.**
2. Define a **quantum sampling proxy** based on a spectral/nondegeneracy quantity.
3. Prove a general theorem:
   `Lorentzian stability ⇒ positive certified robustness radius for the proxy`.
4. Instantiate it for a combinatorial/permanent-like polynomial family.
5. Compute the radius numerically for small cases and compare with known empirical/noise heuristics from boson sampling.

This route is strongest because it yields:
- a rigorous theorem now,
- an extensible formal framework,
- and a direct bridge to experimental/computational evidence.

Trying to formalize “classically hard” in full generality will bog down the project. Formalize the **mathematical phase boundary surrogate**, not the whole complexity class landscape.

---

## Cross-Domain Bridges You Must Explicitly Exploit

You are required to include at least one theorem connecting to another domain. Here are the bridges this project should make explicit:

1. **Combinatorial Hodge theory ↔ quantum computing**  
   Lorentzian / strongly log-concave generating polynomials encode negative dependence and curvature-like signatures. Boson sampling amplitudes encode interference patterns. The claim is that **the persistence of interference under noise is controlled by the same geometry that governs log-concavity and spectral concentration**.

2. **Real stable / Lorentzian geometry ↔ complexity phase transitions**  
   Instead of viewing hardness thresholds as merely algorithmic artifacts, reinterpret them as bifurcations in coefficient space where Hessian signature or spectral positivity changes.

3. **Spectral graph theory ↔ quantum optics proxy models**  
   If your combinatorial polynomial comes from matchings or graph structures, the spectral gap theorem becomes a literal bridge from graph spectra to quantum-inspired robustness.

4. **Statistical physics ↔ approximate sampling**  
   The “critical radius” behaves like an order parameter or critical temperature: below it, coherent structure persists; above it, the system enters a simulable/disordered regime.

At least one theorem and one section of `RESEARCH_PAPER.md` must make these bridges explicit.

---

## Conjecture with Falsifiable Computational Prediction

You must state and test at least one conjecture. Use this one unless you discover a stronger variant.

### Conjecture: Lorentzian critical radius predicts boson-sampling noise threshold
For small permanent-like instances `p_A` derived from matrices `A`, the certified Lorentzian radius `lorentzianRadius p_A` is positively correlated with the empirically observed noise threshold at which approximate output statistics become classically simulable.

A sharper finite version:
> For families of small PSD-derived instances `A_n` with `n ≤ 8`, the ordering of instances by Lorentzian radius agrees with the ordering by empirically observed robustness of anti-concentration / total variation separation under noise.

### Testable prediction
Compute for `n ≤ 8`:
- the polynomial/proxy `p_A`,
- its estimated Lorentzian stability radius,
- a simulation-based degradation threshold for your proxy sampling distribution.

Then test:
- rank correlation,
- monotonicity failures,
- and whether radius gives a nontrivial lower bound on observed threshold.

A single robust counterexample is scientifically valuable. If the conjecture fails, that itself reveals the geometric invariant is insufficient and points toward refined invariants (e.g. mixed Lorentzian curvature, Hessian anisotropy, or polarization-sensitive radii).

---

## Verified Algorithm / Computational Deliverable

You are required to produce a verified algorithm, not just existence theorems.

### Required algorithm
Implement a certified search procedure that, for a finite polynomial family, returns a lower bound on the Lorentzian stability radius and a corresponding certified safe-noise region for the algorithmic proxy.

Suggested specification:
```lean
def estimateLorentzianRadius
  {σ : Type} [Fintype σ] [DecidableEq σ]
  (p : MvPolynomial σ ℝ) (grid : List ℝ) :
  Option ℝ
```

Correctness theorem:
```lean
theorem estimateLorentzianRadius_sound
  {σ : Type} [Fintype σ] [DecidableEq σ]
  (p : MvPolynomial σ ℝ) (grid : List ℝ) (ε : ℝ) :
  estimateLorentzianRadius p grid = some ε →
  ε ≤ lorentzianRadius p
```

And ideally:
```lean
theorem estimateLorentzianRadius_certifies_proxy
  ...
  : estimateLorentzianRadius p grid = some ε →
    ∀ δ, 0 ≤ δ → δ < ε → AlgorithmicallySeparated (applyNoise p δ) δ
```

This is where the project becomes science rather than only theorem proving.

---

## demo.py Requirements

Your `demo.py` must:
1. generate small matrix or graph instances;
2. build the associated polynomial/proxy;
3. numerically estimate the Lorentzian radius;
4. simulate noise degradation of the proxy output distribution;
5. plot radius vs empirical threshold;
6. highlight any counterexamples.

Interactive elements:
- choose instance size `n`,
- choose noise model,
- choose polynomial family (`matching`, `permanent_proxy`, etc.),
- display predicted threshold and observed proxy threshold.

---

## Application Keywords

Include these explicitly in the paper and article:

- boson sampling
- Lorentzian polynomials
- real stability
- phase transition
- approximate sampling
- anti-concentration
- spectral gap
- negative dependence
- combinatorial Hodge theory
- quantum advantage
- noise threshold
- permanent polynomial
- robustness certificate
- statistical physics analogy
- complexity geometry

---

## Deliverables — ALL MANDATORY

You must produce all of the following.

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each with:
- **“The key insight is…”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- tensor networks,
- free probability,
- tropical geometry,
- error-correcting codes,
- or statistical mechanics.

Possible directions:
- mixed Lorentzian curvature as a sharper hardness invariant,
- tropicalized permanent geometry and dequantization of sampling thresholds,
- tensor-network analogues of Lorentzian phase boundaries,
- free-probabilistic limits of stability radii for random interferometers.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper containing:
- motivation from boson sampling and Lorentzian geometry,
- precise definitions,
- theorem statements,
- proof ideas,
- computational experiments,
- limitations,
- and a next-step research agenda.

Someone reading only this paper must understand the discovery and why it matters.

### 3. `ARTICLE.md`
Write in **Scientific American style**.  
Do **not** focus on formal verification. Focus on the scientific idea:

> quantum advantage may be governed by a hidden geometric phase boundary in polynomial space.

Make it vivid, conceptually clean, and exciting.

### 4. Verified algorithm / computational method
As specified above: a certified estimator or checker for Lorentzian stability radius and its algorithmic consequence.

### 5. `demo.py`
Interactive demonstration of the conjectured phase boundary and the certified lower bounds.

---

## Nontriviality Constraints

You must obey these strictly:

- No theorem whose only content is discharged by `native_decide`, `decide`, `norm_num`, or `rfl`.
- At least 3 theorems must use substantial proof methods.
- Introduce at least one novel definition.
- Include at least one explicit cross-domain theorem.
- State at least one falsifiable conjecture with a computational disproof pathway.
- Minimize `sorry`; if a deep external theorem is unavailable, isolate it clearly as an assumption and push everything else through rigorously.

---

## Final Objective

The real goal is not merely “a theorem about Lorentzian polynomials.” The goal is to create the first formal mathematical framework in which one can seriously entertain:

> **Quantum sampling hardness has a geometric order parameter.**

Even a clean proxy theorem with computational evidence would be field-opening. It would suggest that the boundary between quantum advantage and classical simulability is not only computational, but **geometric, spectral, and ultimately universal**.

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
