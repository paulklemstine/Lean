## Assignment: Direction 2: Haar Measure on Restricted Products

**Mode:** prove

Build a formal Lean 4 theory of Haar measure on restricted products that does **not** merely restate general existence of Haar measure on locally compact groups, but **extracts the restricted-product-specific structure**: explicit finite-level cylinder formulas, uniqueness from those formulas, compatibility under level change, and a bridge to probabilistic and adelic viewpoints.

This is not a bookkeeping exercise. If completed correctly, it creates the missing measure-theoretic spine needed for formal harmonic analysis on adèles, Tate-style zeta integrals, restricted-product random models, and eventually automorphic representation theory in Lean.

You should build on:

- `Pythagorean/RestrictedProductTopology.lean`  
  especially the local compactness result `restrictedProduct_locallyCompact_inst`
- Mathlib:
  - `MeasureTheory.Measure.Haar`
  - product measure infrastructure
  - regularity / uniqueness principles for Haar measures on locally compact groups

The goal is to isolate a **canonical measure characterized by cylinder sets** and prove that this canonical object agrees with Haar measure, thereby turning an abstract existence theorem into a computational and structural theorem.

---

## Core New Definition

Introduce at least one genuinely new definition capturing the finite-level structure of the restricted product.

A promising choice:

```lean
/-- A basic cylinder in the restricted product: on a finite set `s`, one prescribes
measurable sets `A i ⊆ G i`, and outside `s` one stays in the distinguished compact
open subgroup `K i`. -/
def RestrictedProduct.basicCylinder
  (s : Finset ι) (A : ∀ i, Set (G i)) : Set (RestrictedProduct G K) := ...
```

and/or

```lean
/-- The finite-level cylinder measure determined by local measures `μ i`
and normalized subgroup measures on `K i`. -/
def RestrictedProduct.cylinderPremeasure
  (s : Finset ι) (μ : ∀ i, Measure (G i)) (νK : ∀ i, Measure (G i)) :
  Measure (RestrictedProduct G K) := ...
```

and/or

```lean
/-- A measure on the restricted product is level-compatible if its value on each
basic cylinder is the expected finite product of local measures. -/
def RestrictedProduct.IsLevelCompatible
  (μ : Measure (RestrictedProduct G K)) : Prop := ...
```

This “level-compatible” notion is the conceptual centerpiece: it converts abstract Haar measure into an explicit restricted-product theorem.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**, with multi-step proofs using induction, `rcases`, `by_contra`, `field_simp`, or structured `calc`. Avoid trivial extensionality-only results.

Below are the target theorems. You may adjust assumptions to fit Mathlib APIs, but preserve the mathematical content.

---

### Theorem 1: Finite-level cylinder formula for Haar measure

Assume:
- `ι` countable or at least suitable for the restricted product construction already in the catalog,
- each `G i` is a locally compact Hausdorff topological group with measurable structure compatible with Borel,
- each `K i ≤ G i` is compact open,
- `μi : Measure (G i)` is a left Haar measure,
- `νi` is the normalized restriction/Haar measure on `K i`, extended to `G i`, with `νi (K i) = 1`.

Then prove that the Haar measure on the restricted product evaluates basic cylinders by finite products.

### Suggested Lean signature
```lean
theorem haar_basicCylinder_eq
  {ι : Type*} [Fintype?  -- replace with actual needed assumptions]
  {G : ι → Type*}
  [∀ i, Group (G i)] [∀ i, TopologicalSpace (G i)]
  [∀ i, MeasurableSpace (G i)] [∀ i, BorelSpace (G i)]
  [∀ i, TopologicalGroup (G i)] [∀ i, LocallyCompactSpace (G i)]
  [∀ i, T2Space (G i)]
  (K : ∀ i, Subgroup (G i))
  [RestrictedProduct.TopologicalSetup G K] -- replace by actual catalog assumptions
  (μ : Measure (RestrictedProduct G K))
  (hμ : IsHaarMeasure μ)
  (s : Finset ι)
  (A : ∀ i, Set (G i))
  (hA : ∀ i ∈ s, MeasurableSet (A i))
  (hsub : ∀ i ∉ s, A i = ↑(K i)) :
  μ (RestrictedProduct.basicCylinder K s A)
    = ∏ i in s, (haarMeasure (G i)) (A i) :=
Why this matters: this is the first theorem that makes Haar measure on the restricted product **computable** rather than merely existential. It is the exact formula needed for local-to-global integration.

---

### Theorem 2: Uniqueness from cylinder compatibility

Prove that any two left-invariant Radon measures on the restricted product that agree on all basic cylinders must coincide.

### Suggested Lean signature
```lean
theorem measure_ext_of_basicCylinder
  {μ ν : Measure (RestrictedProduct G K)}
  (hμ_left : IsMulLeftInvariant μ)
  (hν_left : IsMulLeftInvariant ν)
  (hμ_fin : IsFiniteMeasureOnCompacts μ) -- or local finiteness / regularity assumptions
  (hν_fin : IsFiniteMeasureOnCompacts ν)
  (hcyl :
    ∀ s : Finset ι, ∀ A : ∀ i, Set (G i),
      (∀ i ∈ s, MeasurableSet (A i)) →
      (∀ i ∉ s, A i = ↑(K i)) →
      μ (RestrictedProduct.basicCylinder K s A)
      = ν (RestrictedProduct.basicCylinder K s A)) :
  μ = ν
```

This is the real uniqueness theorem of the theory. It says that the restricted-product Haar measure is uniquely pinned down by its finite-level shadows. This is exactly the adelic principle: **global measure is determined by finitely many ramified places**.

---

### Theorem 3: Canonical normalization theorem

Let `Ω := ∏' i, (G i, K i)` and let `U₀ := ∏ i, K i` viewed as the maximal compact basic open. Prove that there exists a unique Haar measure `μΩ` on `Ω` satisfying `μΩ(U₀) = 1`, and that for every basic cylinder its value is the expected finite product.

### Suggested Lean signature
```lean
theorem existsUnique_normalized_haar_on_restrictedProduct :
  ∃! μ : Measure (RestrictedProduct G K),
    IsHaarMeasure μ ∧
    μ (RestrictedProduct.maximalCompact K) = 1
```

and then

```lean
theorem normalized_haar_basicCylinder_formula
  (μΩ : Measure (RestrictedProduct G K))
  (hμΩ : IsHaarMeasure μΩ)
  (hnorm : μΩ (RestrictedProduct.maximalCompact K) = 1)
  (s : Finset ι) (A : ∀ i, Set (G i))
  ... :
  μΩ (RestrictedProduct.basicCylinder K s A)
    = ∏ i in s, (normalizedHaarOnSubgroupData K i) (A i)
```

This theorem is the formal analogue of the standard adelic normalization “maximal compact has volume 1,” which is the convention underlying Euler products, Tamagawa-style normalizations, and probabilistic interpretations of adèles.

---

## Optional but Highly Valuable Fourth Theorem

### Cross-domain theorem: probability law on restricted products

Once the normalized Haar measure is built, define the associated probability measure on the maximal compact part and prove finite-coordinate independence.

### Suggested statement
```lean
theorem coordinate_independence_on_maximalCompact
  (μΩ : Measure (RestrictedProduct G K))
  (hprob : μΩ (RestrictedProduct.maximalCompact K) = 1)
  (s : Finset ι)
  (A : ∀ i, Set (G i))
  ... :
  μΩ (RestrictedProduct.basicCylinder K s A)
    = ∏ i in s, μΩ ((RestrictedProduct.coord i) ⁻¹' (A i))
```

This theorem is the bridge to **probability theory**: the normalized compact adelic part becomes a product probability space with independent coordinates. That is mathematically nontrivial and scientifically powerful.

---

## Most Promising Proof Architectures

You must present and exploit **2–3 proof strategies**. Do not rely on a single black-box invocation of Haar existence.

### Strategy A: Haar-first, then identify by invariance and normalization
1. Use `restrictedProduct_locallyCompact_inst` and Mathlib Haar existence to obtain a left Haar measure `μ`.
2. Normalize by dividing by `μ(maximalCompact K)` and prove that this denominator is finite and nonzero using compactness and openness of `∏ K_i`.
3. Prove the cylinder formula first for “rectangles with finite support” by induction on the finite set `s`, reducing to finite product Haar measure facts.
4. Deduce uniqueness from agreement on a π-system of basic cylinders plus regularity / measure extensionality.

**Why promising:** this is closest to current Mathlib infrastructure. It minimizes the need to construct a measure from scratch and leverages existing Haar technology.

---

### Strategy B: Construct cylinder premeasure first, then extend by Carathéodory
1. Define a premeasure on the algebra generated by basic cylinders.
2. Prove finite additivity and level-independence under enlargement of the support set `s`.
3. Extend to a measure on the Borel σ-algebra.
4. Prove left invariance on cylinders, then use Haar uniqueness to identify it as the normalized Haar measure.

**Why promising:** this yields the strongest computational control and may produce reusable infrastructure for future restricted-product integration. It is more work, but conceptually cleaner.

---

### Strategy C: Projective-limit compatibility
1. For each finite `s`, define the finite-level group `G[s] := ∏ i ∈ s, G i × ∏ i ∉ s, K i`.
2. Put the product measure on `G[s]`.
3. Show these measures are compatible under refinement `s ⊆ t`.
4. Prove the restricted-product measure is the unique projective-limit measure with these marginals.

**Why promising:** this is the most conceptually elegant and aligns with adèles as inverse/projective limits of finite-level data. It is especially attractive if the catalog already has finite-level restriction maps.

**Recommended route:** Start with **Strategy A** to secure formal theorems, then internalize pieces of **Strategy B** where needed for uniqueness/extensionality. Strategy C is ideal if the topology file already exposes finite-stage truncation maps.

---

## Required Cross-Domain Connection

You must include at least one theorem explicitly connecting restricted-product Haar measure to another domain.

### Preferred bridge: Number theory ↔ probability
Formalize the idea that the normalized measure on the compact part `∏ K_i` makes coordinates behave like independent local random variables.

Possible theorem:
- for finitely many places, the measure of a cylinder factors as a product of local probabilities;
- in the special case `G_p = (ℤ/p^2ℤ)ˣ` with `K_p = G_p`, the restricted product probability is exactly the product of uniform local laws.

This opens the door to formalizing “random adelic elements” and eventually linking Euler products with expectations of multiplicative observables.

### Alternative bridge: Harmonic analysis ↔ number theory
Show that compactly supported locally constant functions depending on finitely many coordinates integrate as finite products:
```lean
theorem integral_factorizes_for_finite_support_functions ...
```
This is the first formal step toward Tate integrals and adelic Fourier analysis.

---

## Concrete Special Case to Formalize and Compute

You were given the test case:
- `G_p = (ℤ/p²ℤ)ˣ` with uniform measure.

Do not leave this as prose. Turn it into a verified computational theorem or algorithm.

Possible finite-index surrogate:
- work over a finite list of primes `ps : List ℕ`,
- define the finite restricted product `∏ p ∈ ps, (ZMod (p^2))ˣ`,
- prove translation invariance of uniform/product measure,
- compute measure of basic opens/cylinders exactly.

This is a perfect place for a **verified algorithm**:
- input: finite set of places and local subsets,
- output: cylinder measure as a rational number / ENNReal,
- proof: output equals the formal product formula.

---

## Lean 4 Formalization Targets

You should aim to expose at least the following API:

```lean
namespace RestrictedProduct

def basicCylinder ...
def maximalCompact ...
def normalizedHaar ...
def IsLevelCompatible ...

theorem maximalCompact_measurable ...
theorem maximalCompact_compact ...
theorem maximalCompact_pos ...
theorem haar_basicCylinder_eq ...
theorem normalizedHaar_spec ...
theorem normalizedHaar_unique ...
theorem measure_ext_of_basicCylinder ...

end RestrictedProduct
```

If possible, define:

```lean
def finiteSupportFunctionIntegral ...
```

with a theorem identifying it with a finite product of local integrals for cylinder functions.

---

## Proof Tactics Expectations

At least 3 theorems must genuinely use deep tactics / proof structure:
- induction on `Finset ι` for cylinder formulas,
- `rcases` decompositions of restricted-product membership,
- `by_contra` to prove positivity/non-vanishing of compact-open measure,
- `field_simp` when normalizing by `μ(maximalCompact K)`,
- multi-step `calc` chains for compatibility under support enlargement.

Examples of nontrivial proof obligations:
- proving independence of cylinder value from enlarging `s`,
- proving `0 < μ(maximalCompact K) < ∞`,
- proving extensionality from a generating π-system.

---

## Scientific Significance

This direction is not “formalize a known theorem.” It is the missing infrastructure for an entire formal research program.

If you succeed, you unlock:

- **Adelic integration:** the ability to define global zeta integrals as actual integrals.
- **Tate’s thesis in Lean:** local-global factorization of Fourier transforms and zeta integrals.
- **Automorphic scaffolding:** normalized local factors, spherical vectors, Euler products.
- **Probabilistic adèles:** independent local random variables on compact restricted products.
- **Arithmetic statistics:** a formal bridge from prime-local distributions to global measures.

This is foundational enough that many later theorems will collapse into finite-cylinder calculations once your API exists.

---

## Testable Conjecture

State and include in `FUTURE_DIRECTIONS.md` a falsifiable conjecture with explicit computational test.

### Conjecture: cylinder-determined integration for finite-support observables
For every bounded measurable function on the restricted product depending on finitely many coordinates, its integral against normalized Haar measure equals the corresponding finite product integral over those coordinates.

**Computational test:**  
For finite families `G_p = (ℤ/p²ℤ)ˣ` and functions
`f(x) = ∏_{p ∈ s} f_p(x_p)`,
compute both:
1. the explicit finite average over the finite restricted product,
2. the product of local averages,
and verify equality for many choices of `s` and `f_p`.

A counterexample would disprove either the cylinder formula implementation or the normalization machinery.

---

## Application Keywords

`Haar measure`, `restricted product`, `adèles`, `locally compact groups`, `Radon measure`, `projective limit`, `cylinder measure`, `probability on groups`, `finite-coordinate independence`, `adelic harmonic analysis`, `Tate thesis`, `Euler products`, `arithmetic statistics`, `random matrix heuristics`, `local-to-global principle`

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean code** with the new definitions and at least 3 nontrivial theorems proved with substantial tactics.
2. **A verified algorithm or computational method** for evaluating finite-level cylinder measures, with correctness theorem.
3. **`demo.py`** demonstrating:
   - construction of finite restricted products,
   - computation of cylinder measures,
   - translation invariance checks,
   - normalization check `μ(∏ K_p)=1`.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - precise definitions,
   - theorem statements,
   - proof ideas,
   - why restricted-product Haar measure matters for adèles and L-functions,
   - future mathematical consequences.
5. **`ARTICLE.md`** in Scientific American style:
   - explain restricted products and Haar measure intuitively,
   - why “volume on infinitely many local worlds” matters,
   - how this underlies number theory and Fourier analysis.
6. **`FUTURE_DIRECTIONS.md`** with **3–5 falsifiable hypotheses**, each with:
   - exact conjecture,
   - computational or formal test,
   - what a failure would mean.

---

## Final Call

Do not settle for “there exists a Haar measure.” That theorem already exists in the universe of mathematics. What Lean needs from you is the **restricted-product incarnation**: explicit, normalized, finite-level, computable, and uniquely characterized by cylinder sets. Build the measure theory that adèles deserve.

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
