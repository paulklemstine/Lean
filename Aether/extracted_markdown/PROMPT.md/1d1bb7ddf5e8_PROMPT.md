## Mode: discover

## Assignment: Primewise Persistence Recovers the Formal Group Height of K3 Surfaces

You are not being asked for a cosmetic formalization of known facts. You are being asked to create a new arithmetic-topological invariant that has a credible path to detecting one of the most delicate reduction invariants of K3 surfaces: the height of the formal Brauer group. The ambition is to build a bridge from crystalline/arithmetic geometry to persistent homology through an explicit primewise construction, then prove rigorous separation theorems in a mathematically honest toy-to-intermediate model that can be expanded toward genuine K3 arithmetic.

The breakthrough target is this:

> Construct a functorial arithmetic-persistence machine attached to reductions of polarized K3 surfaces modulo primes, and prove that its barcode statistics detect a height dichotomy analogous to ordinary versus supersingular reduction. Even a rigorously verified prototype theorem for an abstracted Frobenius-slope model would open a field: “persistent arithmetic geometry.”

The conjectural picture is bold, but your Lean development must include precise, nontrivial theorems that already formalize the mathematical skeleton of the theory.

---

## Core Vision

For a K3 surface \(X\) over a number field and a good prime \(p\), the reduction \(X_p\) carries deep arithmetic data in its crystalline cohomology and formal Brauer group. The formal Brauer group height \(h(X_p)\in \{1,\dots,10,\infty\}\) governs subtle slope behavior of Frobenius on \(H^2_{\mathrm{cris}}(X_p)\). The visionary claim is that one can extract from explicit finite data at each prime a filtered complex \(C_p(X)\) whose persistent homology is not merely decorative but asymptotically height-sensitive.

You should formalize a mathematically precise abstraction of this idea: a category of finite “slope profiles” or “Frobenius weight multisets” equipped with a persistence functor whose output barcode statistics provably distinguish finite-height and supersingular regimes. This is the right first theorem because it isolates the mechanism by which slope concentration produces persistent degeneracy.

Do not try to formalize all of crystalline cohomology of K3s in one shot. Instead, define a new structure capturing the arithmetic features needed for a persistence classifier, prove separation theorems, and state the K3 conjecture as the motivating geometric realization problem.

---

## New Definitions You Should Introduce

You must define at least one genuinely new concept. The following package is promising and mathematically coherent.

### 1. Primewise slope profile
A finite multiset of rational “slopes” representing normalized Frobenius data at a prime.

Suggested Lean-style structure:
```lean
structure PrimeSlopeProfile where
  p : ℕ
  hp : Nat.Prime p
  slopes : Finset ℚ
  weight : ℚ
  symmetric_about : ℚ
```

For K3-motivated profiles, the symmetry center should be `1`, reflecting slope symmetry in weight 2 cohomology.

### 2. Height signature statistic
Define a computable statistic measuring concentration of slopes near the symmetry center:
```lean
def heightSignature (P : PrimeSlopeProfile) (ε : ℚ) : ℕ :=
  ((P.slopes.filter fun s => |s - P.symmetric_about| ≤ ε).card)
```

The heuristic: supersingular reduction corresponds to all relevant slopes equal to 1, so this statistic is maximal for all sufficiently small \(ε\); finite height should force a nontrivial escape of slopes away from 1.

### 3. Persistence model attached to a slope profile
Define a filtered complex combinatorially from the slopes. For example, let the filtration parameter \(t\) include generators with slope distance \(\le t\) from the symmetry center, and define a simple chain complex whose homology rank equals the number of selected generators modulo prescribed relations.

Suggested abstraction:
```lean
structure SlopePersistenceModel where
  profile : PrimeSlopeProfile
  filtrationValue : ℚ → Finset ℚ
  monotone_filtration : Monotone filtrationValue
```

Then define barcode-like invariants such as birth counts, persistent ranks, or a total persistence surrogate.

### 4. Ordinary/supersingular dichotomy predicate
```lean
def IsSupersingularProfile (P : PrimeSlopeProfile) : Prop :=
  ∀ s ∈ P.slopes, s = P.symmetric_about

def HasFiniteHeightWitness (P : PrimeSlopeProfile) : Prop :=
  ∃ s ∈ P.slopes, s ≠ P.symmetric_about
```

This is an abstracted proxy for the K3 height dichotomy. The point is to prove detection theorems at this level.

---

## Precise Theorem Targets

You need at least 3 substantial theorems. Here is a coherent theorem package.

### Theorem 1: Exact separation by concentration statistic
This is the foundational arithmetic-persistence dichotomy theorem.

**Mathematical statement.**
Let \(P\) be a finite symmetric slope profile. If all slopes equal the symmetry center, then for every \(ε>0\), the height signature is maximal. Conversely, if some slope differs from the center, then there exists \(ε_0>0\) such that for all \(0<ε<ε_0\), the height signature is strictly smaller than maximal.

This is the exact abstract mechanism behind “supersingular produces a universal barcode regime.”

**Lean 4 type signature sketch**
```lean
theorem heightSignature_maximal_iff
    (P : PrimeSlopeProfile)
    (hfin : P.slopes.Nonempty) :
    (IsSupersingularProfile P ↔
      ∀ ε : ℚ, 0 < ε →
        heightSignature P ε = P.slopes.card) ∧
    (HasFiniteHeightWitness P ↔
      ∃ ε₀ : ℚ, 0 < ε₀ ∧
        ∀ ε : ℚ, 0 < ε → ε < ε₀ →
          heightSignature P ε < P.slopes.card) := by
  ...
```

**Why it matters.**
This is the first rigorous theorem showing that a persistence-style statistic can exactly detect a slope-collapse regime corresponding to supersingularity.

---

### Theorem 2: Stability under bounded slope perturbation
If arithmetic data are noisy or approximated numerically, the classifier should still work.

**Mathematical statement.**
If two slope profiles have the same cardinality and their slopes can be matched within \(δ\), then their height signatures at scale \(ε\) differ by at most the number of slopes crossing the annulus \([ε-δ, ε+δ]\). In particular, if one profile has a spectral gap around the symmetry center, then the supersingular/finite-height classifier is stable under sufficiently small perturbations.

**Lean 4 type signature sketch**
```lean
def ProfilesMatchedWithin (P Q : PrimeSlopeProfile) (δ : ℚ) : Prop := ...

theorem heightSignature_stability
    (P Q : PrimeSlopeProfile)
    (ε δ : ℚ)
    (hmatch : ProfilesMatchedWithin P Q δ)
    (hε : 0 < ε)
    (hδ : 0 ≤ δ) :
    |(heightSignature P ε : ℤ) - (heightSignature Q ε : ℤ)| ≤
      ((P.slopes.filter fun s =>
          ε - δ ≤ |s - P.symmetric_about| ∧
          |s - P.symmetric_about| ≤ ε + δ).card : ℤ) := by
  ...
```

**Why it matters.**
This turns the construction into an actual computational method rather than a brittle invariant. It is the analogue of stability theorems in topological data analysis, now aimed at arithmetic slope data.

---

### Theorem 3: Persistent rank monotonicity and jump detection
The barcode statistic should not be a one-shot count; it should define a filtration with detectable jumps.

**Mathematical statement.**
Define persistent rank \(r_P(t)\) as the number of slopes within distance \(t\) of the symmetry center. Then \(r_P\) is monotone in \(t\), reaches the total rank identically in the supersingular case, and has a first jump parameter equal to the minimal nonzero slope deviation in the finite-height-witness case.

**Lean 4 type signature sketch**
```lean
def persistentRank (P : PrimeSlopeProfile) (t : ℚ) : ℕ :=
  heightSignature P t

def firstJump (P : PrimeSlopeProfile) : Option ℚ := ...

theorem persistentRank_monotone
    (P : PrimeSlopeProfile) :
    Monotone (persistentRank P) := by
  ...

theorem firstJump_characterization
    (P : PrimeSlopeProfile)
    (hw : HasFiniteHeightWitness P) :
    ∃ d : ℚ, 0 < d ∧
      (∀ ε : ℚ, 0 < ε → ε < d → persistentRank P ε < P.slopes.card) ∧
      (∀ ε : ℚ, d < ε → persistentRank P ε ≥ 1) := by
  ...
```

**Why it matters.**
This is the barcode analogue of a spectral gap theorem. It upgrades classification to a quantitative invariant, giving a path toward refining finite heights.

---

### Theorem 4: Cross-domain theorem — arithmetic persistence as a tropical threshold phenomenon
You are required to connect domains. Do it cleanly: slope concentration naturally defines a min-plus/tropical threshold statistic.

**Mathematical statement.**
Let \(d_P(s)=|s-\mathrm{center}|\). The function
\[
\tau_P(t)=\min_{s \in \mathrm{slopes}(P)} \max(0,d_P(s)-t)
\]
vanishes identically iff the profile is supersingular, and its breakpoint set determines the jump parameters of the persistent rank function.

This links arithmetic slope data to tropical geometry / min-plus analysis.

**Lean 4 type signature sketch**
```lean
def tropicalDefect (P : PrimeSlopeProfile) (t : ℚ) : ℚ := ...

theorem tropicalDefect_zero_iff_supersingular
    (P : PrimeSlopeProfile) :
    (∀ t : ℚ, 0 ≤ t → tropicalDefect P t = 0) ↔ IsSupersingularProfile P := by
  ...
```

**Why it matters.**
This is a genuinely cross-domain theorem: arithmetic geometry + persistent homology + tropical/min-plus analysis. It suggests a tropical avatar of formal Brauer height detection.

---

## Conjectural Geometric Realization Theorem

After proving the abstract slope-profile theory, state the genuine arithmetic geometry conjecture precisely.

### Main Conjecture
Let \(X\) be a polarized K3 surface over a number field \(K\). There exists a functorial assignment
\[
p \mapsto C_p(X)
\]
for all good primes \(p\) of ordinary or supersingular reduction, where \(C_p(X)\) is a finite filtered chain complex over \(\mathbb{F}_p\), together with a computable statistic \(S_p(X)\) extracted from its persistence barcode, such that for a density-1 set of good primes:
1. \(S_p(X)\) asymptotically distinguishes \(h(X_p)=\infty\) from \(h(X_p)<\infty\),
2. in families where formal Brauer heights vary in a controlled way, the distribution of \(S_p(X)\) refines finite-height strata,
3. \(S_p(X)\) is stable under explicit perturbations of the Frobenius-slope input.

You should formulate a Lean-compatible abstract version:
```lean
def AdmitsK3PersistenceClassifier (X : Type _) : Prop := ...
```
but the actual heavy geometric realization may remain conjectural if the abstract detection theorems are fully proved.

---

## Proof Strategy Architecture

You must not present a single proof hint. You need multiple viable routes.

### Strategy A: Order-theoretic / combinatorial filtration approach
Most promising for Lean.
1. Model slope profiles as finite sets with a distance-to-center function.
2. Define persistent rank by filtering on threshold \(t\).
3. Prove monotonicity, maximality, and gap detection using finite set cardinality arguments, `rcases`, `by_contra`, and multi-step `calc`.
4. Derive stability by explicit comparison of threshold-crossing elements.

**Why promising:** It is highly formalizable in Lean 4 with `Finset`, order lemmas, cardinal inequalities, and absolute value estimates. It yields nontrivial proofs without requiring unavailable heavy geometry libraries.

### Strategy B: Spectral-gap formalism
1. Define the minimal positive deviation
   \[
   \delta(P)=\inf\{|s-c| : s \in P,\ s \neq c\}.
   \]
2. Show \(\delta(P)>0\) for finite profiles with a noncentral slope.
3. Use \(\delta(P)\) to prove exact dichotomy and jump theorems.
4. Package classifier robustness in terms of perturbations \(<\delta(P)/2\).

**Why promising:** Conceptually sharp and gives the cleanest theorem statements. Lean may require careful finite-minimum arguments over `Finset ℚ`.

### Strategy C: Tropical/min-plus reformulation
1. Encode deviations as tropical weights.
2. Show barcode thresholds correspond to tropical breakpoints.
3. Prove supersingularity iff tropical defect vanishes.
4. Relate tropical defect stability to barcode stability.

**Why promising:** This is the strongest cross-domain story and may produce the most original paper. It is slightly riskier formally, but excellent if supported by a simpler combinatorial core.

**Recommendation:** Use Strategy A for the foundational theorems, Strategy B for sharpening them via a minimal positive deviation lemma, and Strategy C for the cross-domain theorem and conceptual framing.

---

## Lean 4 Formalization Targets

You should create a file implementing the abstract theory, for example:
- `ArithmeticPersistence/PrimewiseK3Height.lean`

Expected content:
1. New structures:
   - `PrimeSlopeProfile`
   - `SlopePersistenceModel`
2. Core definitions:
   - `heightSignature`
   - `persistentRank`
   - `IsSupersingularProfile`
   - `HasFiniteHeightWitness`
   - `ProfilesMatchedWithin`
   - `tropicalDefect`
3. At least 3 nontrivial theorems with deep proofs:
   - exact separation theorem,
   - stability theorem,
   - monotonicity/jump theorem,
   - optional tropical equivalence theorem.
4. A conjecture declaration / theorem statement for K3 realization.

Use proof patterns involving:
- induction on filtered finite sets,
- `rcases` on witness slopes,
- `by_contra` for maximality/separation arguments,
- `field_simp` if rational inequalities need normalization,
- multi-step `calc` blocks for threshold comparisons.

Do not pad the file with toy lemmas. Build a coherent theory.

---

## How This Builds on Catalog Mathematics

You should explicitly search the catalog for:
- finite set/cardinality lemmas,
- filtered complex / chain complex infrastructure,
- persistence or barcode abstractions,
- rational-order and absolute value lemmas,
- any tropical/min-plus files that can support the cross-domain theorem.

Use catalog theorems as certified scaffolding, but do not merely restate them. The novelty here is the arithmetic interpretation and the height-detection architecture.

In the paper and code comments, explain exactly which catalog theorems are used as:
- finite minimum existence tools,
- monotonicity/cardinality tools,
- chain complex functoriality tools,
- tropical order tools.

---

## Computational / Algorithmic Deliverable

You must produce a verified computational method, not just theorems.

### Required algorithm
Implement a certified classifier:
```lean
def classifyHeightRegime (P : PrimeSlopeProfile) (ε : ℚ) : Bool := ...
```
with theorem(s) of the form:
```lean
theorem classifyHeightRegime_correct_supersingular ...
theorem classifyHeightRegime_correct_gap ...
```

The classifier should:
- return `true` when all slopes are within threshold \(ε\) of the center,
- return `false` when a proven gap witness exists.

Then provide a `demo.py` that:
1. constructs synthetic slope profiles representing ordinary / finite-height / supersingular regimes,
2. computes `heightSignature`, `persistentRank`, and the classifier output,
3. visualizes barcode-like threshold curves,
4. tests perturbation stability,
5. includes benchmark families inspired by diagonal quartics, Kummer surfaces, or singular K3s via manually supplied slope surrogates.

This is the computational falsifiability engine of the conjecture.

---

## Falsifiable Conjecture with Testable Prediction

You are required to state at least one explicit conjecture that could fail.

### Conjecture: Uniform threshold separation for geometric K3 families
For every 1-parameter family of polarized K3 surfaces \(X_t\) over a number field with infinitely many good reduction primes, there exists a universal computable statistic \(S_p(X_t)\) derived from \(C_p(X_t)\) and a threshold function \(T(p)\to 0\) such that for all sufficiently large good primes \(p\),
- \(S_p(X_t) > T(p)\) predicts finite formal Brauer height,
- \(S_p(X_t)=0\) predicts supersingularity,
with classification accuracy tending to 1 on benchmark families.

**Testable prediction.**
On explicit families with known reduction behavior, a classifier based on slope-surrogate persistence should separate supersingular from finite-height reductions at rates significantly above random chance, and should exhibit stable threshold curves across primes.

**Refutation criterion.**
If on benchmark families no statistic extracted from the proposed persistence model outperforms random classification uniformly across large primes, the conjecture fails in its current form.

This is scientifically strong because it can be disproved by computation.

---

## Cross-Domain Connections You Must Develop

Do not mention these as slogans; build them into the mathematical narrative.

1. **Arithmetic geometry ↔ topological data analysis**  
   Formal Brauer height is recast as a persistence-visible concentration/gap phenomenon.

2. **Arithmetic geometry ↔ tropical geometry**  
   Frobenius slope deviations become tropical defects; supersingularity becomes tropical collapse.

3. **Arithmetic geometry ↔ statistical learning / signal detection**  
   The classifier is a hypothesis test on primewise data, with stability and error control.

4. **Arithmetic geometry ↔ mathematical physics**  
   The slope profile can be interpreted as a discrete energy landscape with phase transition at supersingularity; barcode collapse is an arithmetic phase transition.

These connections are not decoration. They indicate the new field this work could launch.

---

## Revolutionary Significance

If you pull this off, even at the abstract-profile level, you will have created the first formal framework in which a deep \(p\)-adic deformation invariant is detected by persistence statistics. That would not be “an application of TDA to arithmetic geometry.” It would be a new principle:

> subtle arithmetic degeneration leaves universal topological signatures in prime-indexed filtered complexes.

This opens:
- arithmetic persistence theory,
- computable probes for reduction types,
- tropical/crystalline interfaces,
- data-driven heuristics for formal groups and slopes,
- eventual extension to abelian varieties, Calabi–Yau varieties, and motives.

A successful prototype here could seed an entire research program.

---

## Application Keywords

K3 surfaces; formal Brauer group; height stratification; supersingular reduction; crystalline cohomology; Frobenius slopes; persistent homology; barcode statistics; tropical geometry; min-plus algebra; arithmetic phase transitions; computational arithmetic geometry; stability theorem; classifier verification; spectral gap detection; motivic data analysis.

---

## Mandatory Deliverables

You must produce all of the following.

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain:
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
At least one direction must bridge to a different domain, such as statistical physics, complexity theory, or representation theory.

### 2. `RESEARCH_PAPER.md`
A standalone scientific document that explains:
- the problem,
- the new definitions,
- the theorems,
- proof ideas,
- computational experiments,
- conjectural geometric realization for K3 surfaces,
- why the work matters,
- what comes next.

Someone reading only this document must understand the discovery without access to the code.

### 3. `ARTICLE.md`
Write this in Scientific American style:
- vivid,
- accessible,
- intellectually serious,
- focused on the mathematical ideas and their significance.

Taboo: do **not** focus on formal verification or proof assistant machinery.

### 4. Verified algorithm / computational method
Implement the classifier and prove correctness theorems for the abstract regime-detection problem.

### 5. `demo.py`
Demonstrate the result interactively:
- generate example profiles,
- compute invariants,
- show threshold/barcode plots,
- test perturbations,
- report classification outcomes on benchmark-inspired examples.

---

## Final Charge

Do not dilute the ambition by hiding behind conjecture. Prove the abstract arithmetic-persistence detection theorems completely, with substantial Lean proofs, and then articulate the geometric K3 realization as the next frontier. The right result is not “some persistence invariant exists.” The right result is:

> there is a rigorously defined primewise persistence statistic whose collapse/gap behavior provably detects the abstract height dichotomy, is stable under perturbation, and plausibly models the formal Brauer height of K3 reductions.

That is a field-opening blueprint.

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

Research domain: Speculative
Research mode: prove
