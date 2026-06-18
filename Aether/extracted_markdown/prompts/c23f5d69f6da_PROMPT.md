Soli Deo Gloria

## Assignment: Direction 2: Entropic Area Laws from Strong Log-Concavity

**Mode:** `prove`

You are to attack a genuinely field-opening theorem program: derive **entanglement area-law behavior from classical strong log-concavity / Lorentzian geometry of measurement distributions**. The thesis is radical and precise:

> The “classical shadow” of low-entanglement quantum matter is not merely decay of correlations, but a curvature condition on the generating polynomial of the measurement law.

This is not an incremental variant. If established even in a mathematically clean surrogate model, it opens a new bridge:
- **quantum information theory** ↔ **Lorentzian / strongly log-concave polynomials**
- **entropy inequalities** ↔ **spectral gap / curvature of generating functions**
- **many-body physics** ↔ **classical probabilistic geometry**
- **area laws** ↔ **negative dependence / ultra log-concavity**

Your task is to formalize and prove new nontrivial theorems in Lean 4, building on the catalog references and introducing at least one genuinely new concept.

---

## Core Vision

The conjectural picture is this:

Let `μ` be the computational-basis measurement distribution of a pure 1D quantum state on `n` qubits. Suppose the multivariate generating polynomial associated to `μ` is strongly log-concave, and moreover possesses a quantitative **Lorentzian gap** `δ > 0` measuring how far all relevant Hessian signatures are from degeneracy. Then the bipartite entanglement entropy across any cut should be bounded by a logarithmic function of `1/δ`.

Even if the full physical theorem is too strong at present, you must prove a mathematically precise surrogate theorem that isolates the mechanism:
1. strong log-concavity / Lorentzian gap gives **entropy concentration** or **anti-flatness** of the classical law,
2. entropy concentration bounds the Shannon entropy of coarse marginals,
3. via a quantum-measurement bridge, this constrains entanglement entropy.

The decisive breakthrough would be a theorem showing that a curvature lower bound on a classical generating object implies an area-law-type entropy upper bound.

---

## Precise Formal Targets

### New definitions you should introduce

You must define at least one new structure not already in the catalog. Recommended core definitions:

1. **Lorentzian gap surrogate** for a finite probability law.
   This should be a quantitative parameter extracted from local log-concavity inequalities, pair-mass inequalities, or directional Hessian negativity.

2. **Entropy profile across a cut** for a finite law on bitstrings.
   This lets you define a classical entropy observable that can be related to quantum bipartite entropy.

3. **Area-law surrogate class**: a property saying entropy across every interval cut is bounded by a logarithm of the inverse gap.

A possible Lean-level structure:

```lean
structure EntropicAreaLawWitness (α : Type _) [Fintype α] where
  μ : α → ℝ
  nonneg : ∀ a, 0 ≤ μ a
  normalized : (∑ a, μ a) = 1
  gap : ℝ
  gap_pos : 0 < gap
  entropyBound : ℝ
  entropy_cert :
    shannonEntropy μ ≤ entropyBound ∧ entropyBound ≤ Real.log (1 / gap) + 1
```

But do not stop at packaging; prove substantive theorems using it.

---

## Exact theorem program

You should aim to prove at least **3 deep theorems**, with real multi-step arguments. Here is the recommended theorem suite.

### Theorem 1: Gap-to-anti-concentration entropy bound
Formalize a theorem showing that a quantitative lower bound on local pair masses or directional log-concavity yields an upper bound on entropy.

#### Mathematical statement
Let `μ` be a probability distribution on a finite set `Ω`. Assume:
- `μ(x) ≥ m > 0` on its support,
- a quantitative Lorentzian-gap surrogate `δ > 0` gives a lower bound on certain pair masses / second-difference curvature,
- support size is controlled by `N(δ)` or the effective support is compressed by the gap.

Then
\[
H(\mu) \le C_1 \log(1/\delta) + C_2
\]
for explicit constants in your formal surrogate setting.

#### Suggested Lean 4 type signature
You may need to adapt names/types to Mathlib realities, but target something like:

```lean
theorem shannonEntropy_le_log_inv_gap_add
    {α : Type _} [Fintype α] [DecidableEq α]
    (μ : α → ℝ)
    (hμ_nonneg : ∀ a, 0 ≤ μ a)
    (hμ_sum : (∑ a, μ a) = 1)
    (δ : ℝ)
    (hδ : 0 < δ)
    (hgap : PairMassGap μ ≥ δ) :
    shannonEntropy μ ≤ Real.log (1 / δ) + 1
```

If `PairMassGap` is too coarse, define a stronger surrogate such as `DirectionalSLCGap μ`.

#### Why this matters
This is the mathematical engine. It turns curvature into information compression.

---

### Theorem 2: Bipartition entropy controlled by measurement entropy
You need a theorem connecting classical entropy of the measurement distribution to a quantum or quantum-inspired entropic quantity across a bipartition.

#### Mathematical statement
For a pure state model `ψ` with measurement law `μ`, the entanglement entropy across a cut is bounded above by the Shannon entropy of the induced marginal measurement law:
\[
S_A(\psi) \le H(\mu_A),
\]
or in a surrogate version,
\[
\mathrm{cutEntropy}(ψ,A) \le \mathrm{measurementEntropy}(μ,A).
\]

If the full von Neumann formalization is too ambitious, define a **surrogate entanglement entropy** satisfying the same monotonicity principles and prove the bound rigorously.

#### Suggested Lean 4 type signature
Building on `QuantumMeasurementModel` from the catalog:

```lean
theorem cutEntropy_le_measurementEntropy
    (M : QuantumMeasurementModel n)
    (A : Finset (Fin n)) :
    cutEntropy M A ≤ measurementEntropy M A
```

or, if you need a classicalized abstraction:

```lean
theorem bipartitionSurrogateEntropy_le_marginalShannon
    {n : ℕ}
    (μ : (Fin n → Bool) → ℝ)
    (A : Finset (Fin n))
    (hμ_nonneg : ∀ x, 0 ≤ μ x)
    (hμ_sum : (∑ x, μ x) = 1) :
    bipartitionSurrogateEntropy μ A ≤ marginalShannonEntropy μ A
```

#### Why this matters
This is the bridge theorem: it imports classical probabilistic curvature into quantum area-law language.

---

### Theorem 3: Area-law surrogate from Lorentzian gap
This is the flagship theorem.

#### Mathematical statement
For a 1D measurement model whose distribution satisfies strong log-concavity with gap `δ`, every interval cut obeys:
\[
S(A) \le C \log(1/\delta) + C'
\]
uniformly in system size.

A precise formal surrogate:

```lean
theorem areaLaw_from_lorentzianGap
    {n : ℕ}
    (M : QuantumMeasurementModel n)
    (δ : ℝ)
    (hδ : 0 < δ)
    (hgap : measurementPairMassGap M ≥ δ) :
    ∀ A : Finset (Fin n),
      isIntervalCut A →
      cutEntropy M A ≤ Real.log (1 / δ) + 1
```

If necessary, replace `cutEntropy` with `bipartitionSurrogateEntropy`, but keep the theorem universal over cuts.

#### Why this is a breakthrough
Even as a surrogate theorem, this is the first rigorous route from a **classical geometric property of a measurement distribution** to a **uniform many-body entanglement bound**. It suggests a new organizing principle for quantum phases: **Lorentzian curvature classes**.

---

## Strong conjecture with falsifiable computational prediction

You must explicitly state and test the following conjecture in the code and paper.

### Conjecture
For the transverse-field Ising model (TFIM) ground state on `n = 4, …, 8` qubits, if the computational-basis measurement distribution has surrogate Lorentzian gap `δ_n(A)` across cut `A`, then
\[
S_A \le C \log(1/\delta_n(A)) + C'
\]
with constants approximately stable across `n` and cuts.

### Computational falsification criterion
The conjecture is **refuted** if numerical experiments reveal a family of cuts/states for which
\[
S_A / \log(1/\delta_n(A))
\]
grows systematically with `n`, or if the best fit is polynomial in `1/\delta_n(A)` rather than logarithmic.

This must be implemented in `demo.py`:
- compute TFIM ground states for `n = 4,...,8`,
- compute bipartite entanglement entropy across all contiguous cuts,
- compute a surrogate Lorentzian gap from measurement probabilities,
- plot `S(A)` against `log(1/δ)` and against `1/δ`,
- report which model fits better.

---

## Proof architecture: 3 candidate strategies

You must present and attempt multiple proof routes. Do not rely on a single brittle path.

### Strategy A: Pair-mass gap → min-mass control → entropy bound
Build directly on catalog results such as:
- `pairMassGap_ge_two_minMass`
- `minMass_perturbation_lower_bound`

**Route**
1. Use `pairMassGap_ge_two_minMass` to convert a Lorentzian-gap surrogate into a lower bound on the minimal nonzero atom mass.
2. Deduce an upper bound on support size via normalization:
   \[
   |\mathrm{supp}(\mu)| \le 1 / m.
   \]
3. Apply the standard finite-support entropy bound
   \[
   H(\mu) \le \log |\mathrm{supp}(\mu)|
   \]
   to obtain
   \[
   H(\mu) \le \log(1/m) \lesssim \log(1/\delta).
   \]

**Why promising**
This is the most formalization-friendly strategy because it builds directly from vetted catalog inequalities and reduces the hard theorem to a chain of finite combinatorial entropy lemmas.

---

### Strategy B: Directional log-concavity → entropy concentration
Build on `Catalog/Pythagorean/DirectionalLogConcavity.lean`.

**Route**
1. Formalize a directional curvature quantity from the generating polynomial or from discrete directional second differences.
2. Prove that positive curvature excludes flat high-entropy distributions by bounding variance or effective support.
3. Convert concentration/effective-support control into a Shannon entropy bound.

**Why promising**
This is conceptually closest to the research vision: curvature directly controls entropy. It is more difficult than Strategy A but scientifically deeper and more extensible.

---

### Strategy C: Coarse-graining and subadditivity across cuts
Use information-theoretic inequalities.

**Route**
1. Define the marginal law on a cut `A`.
2. Prove monotonicity/subadditivity properties of Shannon entropy under projection/coarse-graining.
3. Show the Lorentzian gap survives or weakens controllably under marginalization.
4. Apply Theorem 1 to the marginal law and conclude the area-law bound.

**Why promising**
This route is essential for universality across all cuts. It is likely the right framework for scaling from a single entropy bound to a true area-law statement.

**Best overall plan**
Start with **Strategy A** to secure a theorem that is definitely formalizable and nontrivial. Then layer **Strategy C** to propagate the bound to interval cuts. If time permits, develop **Strategy B** as the conceptual core for the paper and future generalization.

---

## Required cross-domain theorem

You must include at least one theorem that explicitly bridges to another domain.

### Recommended theorem: Negative curvature excludes volume-law classical shadows
Interpretation: a combinatorial curvature condition forbids extensive entropy growth.

#### Possible statement
For a family of finite distributions with uniform gap `δ > 0`, entropy density vanishes:
\[
\frac{H(\mu_n)}{n} \to 0.
\]

Lean-style target:

```lean
theorem entropyDensity_tendsTo_zero_of_uniform_gap
    (μ : ℕ → ((Fin n → Bool) → ℝ))
    (δ : ℝ)
    (hδ : 0 < δ)
    (hgap : ∀ n, PairMassGap (μ n) ≥ δ) :
    ∀ ε > 0, ∃ N, ∀ n ≥ N, shannonEntropy (μ n) / n < ε
```

This connects:
- **quantum many-body area laws**
- **asymptotic information theory**
- **discrete convex geometry**

If sequence formalization is too heavy, prove a finite-n corollary:
\[
H(\mu_n) \le \log(1/\delta)+1 \implies H(\mu_n)/n \le (\log(1/\delta)+1)/n.
\]

---

## Suggested new definitions

You should introduce some subset of the following.

```lean
def supportFinset {α : Type _} [Fintype α] [DecidableEq α] (μ : α → ℝ) : Finset α :=
  Finset.univ.filter (fun a => μ a ≠ 0)

def minMass {α : Type _} [Fintype α] [DecidableEq α] (μ : α → ℝ) : ℝ :=
  sInf ((fun a => μ a) '' {a | μ a ≠ 0})

def PairMassGap {α : Type _} [Fintype α] [DecidableEq α] (μ : α → ℝ) : ℝ :=
  -- adapt from catalog bridge notions

def shannonTerm (x : ℝ) : ℝ :=
  if x = 0 then 0 else -x * Real.log x

def shannonEntropy {α : Type _} [Fintype α] (μ : α → ℝ) : ℝ :=
  ∑ a, shannonTerm (μ a)

def marginalOn
    {n : ℕ} (μ : (Fin n → Bool) → ℝ) (A : Finset (Fin n)) :
    (A → Bool) → ℝ := ...

def marginalShannonEntropy
    {n : ℕ} (μ : (Fin n → Bool) → ℝ) (A : Finset (Fin n)) : ℝ := ...

def isIntervalCut {n : ℕ} (A : Finset (Fin n)) : Prop := ...

def bipartitionSurrogateEntropy
    {n : ℕ} (μ : (Fin n → Bool) → ℝ) (A : Finset (Fin n)) : ℝ :=
  marginalShannonEntropy μ A
```

If `QuantumMeasurementModel` already gives a distribution map, integrate with it rather than duplicating.

---

## Catalog building blocks you must exploit explicitly

### 1. `Catalog/Pythagorean/QuantumLorentzianBridge.lean`
Use:
- `QuantumMeasurementModel`
- `minMass`
- pair-mass gap infrastructure
- perturbative lower bounds such as `minMass_perturbation_lower_bound`

**How to use it**
Translate Lorentzian-gap hypotheses into lower bounds on atom masses or pair masses. This is the quantitative seed for entropy control.

### 2. `Catalog/Pythagorean/DirectionalLogConcavity.lean`
Use:
- directional log-concavity lemmas
- any monotonicity / curvature-transfer statements already present

**How to use it**
Lift local concavity information to global entropy constraints, or at least define your new `DirectionalSLCGap` in a way that interoperates with the existing library.

### 3. Existing entropy lemmas in Mathlib
You may need to prove custom lemmas if absent:
- nonnegativity of `-x log x` on `[0,1]`
- entropy bounded by logarithm of support size
- entropy monotonicity under projection / coarse-graining

These are mathematically standard but not trivial in Lean; they will provide the deep proof content required.

---

## Deep proof tactics requirement

Your file must contain at least 3 theorems whose proofs genuinely use multi-step reasoning. Recommended proof ingredients:
- `by_contra` to prove support-size or positivity claims,
- `rcases` on support membership / marginal decomposition,
- induction over finite support or over interval length,
- `field_simp` in logarithmic inequalities where rational expressions arise,
- `calc` chains for entropy bounds,
- case splits on `μ x = 0`,
- `Finset` cardinality arguments and sum manipulations.

Do **not** settle for tautological wrappers. Theorems should expose real mathematics.

---

## Concrete theorem list to include

At minimum, include the following theorem skeletons or stronger variants.

```lean
theorem support_card_le_inv_minMass
    {α : Type _} [Fintype α] [DecidableEq α]
    (μ : α → ℝ)
    (hμ_nonneg : ∀ a, 0 ≤ μ a)
    (hμ_sum : (∑ a, μ a) = 1)
    (m : ℝ)
    (hm : 0 < m)
    (hmin : ∀ a, μ a ≠ 0 → m ≤ μ a) :
    (supportFinset μ).card ≤ Nat.ceil (1 / m)
```

```lean
theorem shannonEntropy_le_log_support_card
    {α : Type _} [Fintype α] [DecidableEq α]
    (μ : α → ℝ)
    (hμ_nonneg : ∀ a, 0 ≤ μ a)
    (hμ_sum : (∑ a, μ a) = 1) :
    shannonEntropy μ ≤ Real.log (supportFinset μ).card
```

```lean
theorem shannonEntropy_le_log_inv_minMass
    {α : Type _} [Fintype α] [DecidableEq α]
    (μ : α → ℝ)
    (hμ_nonneg : ∀ a, 0 ≤ μ a)
    (hμ_sum : (∑ a, μ a) = 1)
    (m : ℝ)
    (hm : 0 < m)
    (hmin : ∀ a, μ a ≠ 0 → m ≤ μ a) :
    shannonEntropy μ ≤ Real.log (1 / m) + 1
```

```lean
theorem marginal_entropy_le_global_entropy
    {n : ℕ}
    (μ : (Fin n → Bool) → ℝ)
    (A : Finset (Fin n))
    (hμ_nonneg : ∀ x, 0 ≤ μ x)
    (hμ_sum : (∑ x, μ x) = 1) :
    marginalShannonEntropy μ A ≤ shannonEntropy μ
```

```lean
theorem areaLaw_surrogate_from_pairMassGap
    {n : ℕ}
    (M : QuantumMeasurementModel n)
    (δ : ℝ)
    (hδ : 0 < δ)
    (hgap : measurementPairMassGap M ≥ δ) :
    ∀ A : Finset (Fin n),
      isIntervalCut A →
      bipartitionSurrogateEntropy (measurementDist M) A ≤ Real.log (1 / δ) + 1
```

You may adjust constants and hypotheses, but the final theorem must have the flavor above.

---

## Scientific significance to emphasize in the paper

If successful, this line of work suggests:

1. **Area laws may be governed by classical polynomial curvature.**
   This is a new organizing principle for low-entanglement phases.

2. **Lorentzian geometry becomes an entanglement diagnostic.**
   Instead of studying reduced density matrices directly, one can inspect the generating polynomial of measurement statistics.

3. **Classical shadows acquire structural meaning.**
   Not just compressed tomography, but a geometric witness of many-body order.

4. **New algorithmic applications become possible.**
   If a gap surrogate is efficiently estimable from samples, one gets a practical certificate for low-entanglement structure.

---

## Application keywords

Include these keywords in the paper and article:
- area law
- entanglement entropy
- strong log-concavity
- Lorentzian polynomial
- negative dependence
- Shannon entropy
- quantum measurement distribution
- transverse-field Ising model
- entropy concentration
- classical shadow of entanglement
- many-body physics
- discrete convex geometry
- information geometry
- spectral independence

---

## Deliverables you must produce

You must produce **all** of the following.

### 1. Lean development
A file proving the new theorems above with minimal sorrys. At least 3 deep proofs. At least one new definition.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper containing:
- problem statement,
- theorem statements in standard mathematical prose,
- proof ideas,
- relation to catalog results,
- computational experiment section,
- limitations,
- next conjectures.

Someone reading only this document must understand the discovery and why it matters.

### 3. `ARTICLE.md`
Scientific American style. Explain the mathematics and physics significance to a broad audience.  
**Taboo:** do **not** focus on formal verification machinery. Focus on ideas, implications, and the surprise connection between curvature and entanglement.

### 4. `FUTURE_DIRECTIONS.md`
3–5 original research directions. Each direction must include:
- **“The key insight is…”**
- **“Why now?”**
At least one direction must bridge to a different domain, such as:
- spin systems ↔ coding theory,
- Lorentzian geometry ↔ complexity theory,
- entropy concentration ↔ high-dimensional statistics.

### 5. Verified computational method
Implement a mathematically specified algorithm for:
- computing the surrogate Lorentzian gap,
- computing marginal entropies across cuts,
- comparing logarithmic vs polynomial fit.

This must not be just a theorem statement; it must be an actual computational method justified by the formal development.

### 6. `demo.py`
Interactive demo that:
- builds TFIM Hamiltonians for `n = 4,...,8`,
- computes approximate ground states,
- extracts computational-basis probabilities,
- computes entanglement entropy across contiguous cuts,
- computes the surrogate Lorentzian gap,
- plots `S(A)` vs `log(1/δ)` and `S(A)` vs `1/δ`,
- prints a verdict on whether the data supports logarithmic scaling.

---

## Final call to arms

Do not treat this as “formalizing an entropy inequality.” Treat it as the first step toward a new theory of **entanglement via classical curvature**.

A successful result here would say: the geometry of a generating polynomial knows whether a quantum state obeys an area law. That is the kind of statement that can launch a research program, not merely close a lemma.

Build the bridge carefully, but build it boldly.

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
