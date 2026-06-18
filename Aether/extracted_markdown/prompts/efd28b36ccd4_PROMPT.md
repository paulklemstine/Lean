Soli Deo Gloria

## Assignment: Direction 2: Tropical Lorentzian Geometry of Tensor Network Boundary States

**Mode:** `prove` with a `discover` subgoal

Aristotle, do not treat this as a decorative analogy between tensor networks and tropical geometry. Treat it as a program to extract a **new geometric invariant of quantum many-body states** from the tropicalization of boundary measurement data, and to prove that this invariant controls combinatorial entanglement complexity. The right target is not “some relation” but a theorem schema strong enough that future work can build a tropical complexity theory for tensor networks.

Your mission is to formalize and prove a first breakthrough version of the following principle:

> **Boundary measurement polynomials of tensor networks, when tropicalized, remember the network’s combinatorial causal/entanglement geometry; and a Lorentzian gap extracted from this tropical object bounds or detects bond complexity.**

This must be done with genuinely nontrivial mathematics: new definitions, at least 3 serious theorems, and at least one cross-domain theorem connecting tropical geometry to quantum/tensor-network structure.

---

## Core Vision

For a finite tensor network with boundary legs, one can associate a boundary measurement generating polynomial \(P_\mu\) whose monomials encode admissible boundary configurations and whose coefficients encode amplitudes/weights. Tropicalization replaces \((+, \cdot)\) by \((\min, +)\), producing a piecewise-linear object. The conjectural leap is that this tropical object is not merely a degeneration: it is the **combinatorial shadow of entanglement propagation** through the network.

The revolutionary point is this: if true even in a rigorous toy-but-nontrivial regime, it opens a new bridge

- **tensor networks ↔ tropical geometry ↔ Lorentzian polynomials ↔ matroid/combinatorial convexity**

and suggests new algorithms for contraction, complexity lower bounds, and geometric diagnostics for representability of many-body states.

---

## Precise Formal Target

You should work in a mathematically controlled finite model first: finite tensor networks with a finite set of internal vertices and boundary legs, and a finitely supported “boundary measurement polynomial” over `ℝ` or `ℚ`. Do **not** overreach immediately to full PEPS/MERA semantics. Instead isolate the combinatorial essence and prove strong theorems there.

### New definitions you should introduce

At minimum define a new structure capturing the combinatorial tensor network boundary model.

Suggested Lean-level structures:

```lean
structure FiniteTensorNetwork where
  V : Type
  [fintypeV : Fintype V]
  [decV : DecidableEq V]
  B : Finset V                      -- designated boundary vertices
  E : Finset (V × V)                -- internal edges / adjacency data
  bondDim : ℕ
  bondDim_pos : 0 < bondDim

structure BoundaryMeasurementData (α : Type _) where
  n : ℕ
  support : Finset (Fin n →₀ ℕ)
  coeff : (Fin n →₀ ℕ) → α
  coeff_support :
    ∀ m, m ∉ support → coeff m = 0
```

Then define a tropicalization functional and a Lorentzian-gap-style invariant on the support/valuation data. You may need a support-level notion first if full Brändén–Huh Lorentzian formalization is too heavy.

Suggested new concepts:

```lean
def tropWeight {n : ℕ} (v : (Fin n →₀ ℕ) → ℝ) :
    (Fin n →₀ ℕ) → ℝ := v

def tropicalPolynomialSupport {n : ℕ} (D : BoundaryMeasurementData ℝ) :
    Finset (Fin n →₀ ℕ) := D.support

def TropicalHypersurfacePoint {n : ℕ} (D : BoundaryMeasurementData ℝ)
    (x : Fin n → ℝ) : Prop :=
  ∃ m1 ∈ D.support, ∃ m2 ∈ D.support, m1 ≠ m2 ∧
    (weightEval D.coeff x m1 = weightEval D.coeff x m2) ∧
    ∀ m ∈ D.support, weightEval D.coeff x m1 ≤ weightEval D.coeff x m
```

where `weightEval` is your tropical affine evaluation:
```lean
def weightEval {n : ℕ} (c : (Fin n →₀ ℕ) → ℝ)
    (x : Fin n → ℝ) (m : Fin n →₀ ℕ) : ℝ :=
  c m + ∑ i, (m i : ℝ) * x i
```

Then define a combinatorial “Lorentzian gap” invariant. Since full Lorentzian machinery may be too large, start with a support-theoretic or valuation-theoretic proxy that is still mathematically meaningful.

For example:

```lean
def tropicalLorentzianGap {n : ℕ} (D : BoundaryMeasurementData ℝ) : ℝ :=
  sInf {r : ℝ | 0 ≤ r ∧
    ∀ x, ¬ hasThreeWayNearTie D x r}
```

or a more combinatorial version measuring separation of dominant monomials across support fibers. The point is to define a nontrivial invariant that can be related to graph/bond data.

---

## Breakthrough Theorem Package

You must prove at least 3 substantial theorems. The following are the right targets.

### Theorem 1: Tropical support of boundary measurement data is graph-constrained

**Mathematical statement.** For a finite tensor network \(T\), every exponent vector appearing in the boundary measurement polynomial satisfies a conservation law induced by the network incidence/boundary structure. Consequently the tropical support lies in an affine lattice polytope canonically determined by the boundary graph.

This is the first rigorous statement that tropicalization does not forget the tensor network geometry.

#### Suggested Lean 4 theorem signature
```lean
theorem support_subset_boundary_flow_polytope
    (T : FiniteTensorNetwork)
    (D : BoundaryMeasurementData ℝ)
    (hD : D = boundaryMeasurementData T) :
    ∀ m ∈ D.support, satisfiesBoundaryFlowConstraints T m
```

If you define an explicit polytope/set:
```lean
theorem tropical_support_subset_graph_polytope
    (T : FiniteTensorNetwork) :
    tropicalPolynomialSupport (boundaryMeasurementData T) ⊆
      graphBoundaryPolytope T
```

#### Why this is a breakthrough
It converts tensor network geometry into a certified tropical/combinatorial support theorem. This is the seed of a tropical dictionary for entanglement structure.

#### Proof strategy options
**Strategy A: direct combinatorial expansion of boundary measurement**
1. Define `boundaryMeasurementData T` by summing over internal index assignments.
2. Show each monomial exponent records boundary occupation/flow.
3. Prove by induction on internal edges/vertices that every supported monomial satisfies the conservation constraints.

**Strategy B: factorization through local tensors**
1. Express the global generating polynomial as an iterated product/sum of local contributions.
2. Prove each local factor preserves a flow-conservation predicate on exponents.
3. Use support calculus under multiplication to conclude the global support theorem.

**Why B is more promising:** it scales better to PEPS/MERA-style composition and yields reusable lemmas about support under tensor composition.

Proof tactics should include induction on a finite decomposition of the network, `rcases` on membership in support products/sums, and multi-step `calc`.

---

### Theorem 2: Tropical hypersurface detects boundary-separation ambiguity

You need a theorem saying that points on the tropical hypersurface correspond to **competing boundary flow sectors**. This is the geometric manifestation of entanglement ambiguity / multiple dominant contraction channels.

**Mathematical statement.** If \(x\) lies on the tropical hypersurface of the boundary measurement polynomial, then there exist distinct admissible boundary configurations with equal tropical cost at \(x\). Conversely, under a genericity hypothesis, any equality of two minimal admissible sectors yields a tropical hypersurface point.

#### Suggested Lean 4 theorem signatures
```lean
theorem tropical_hypersurface_has_competing_boundary_sectors
    {n : ℕ} (D : BoundaryMeasurementData ℝ) (x : Fin n → ℝ)
    (hx : TropicalHypersurfacePoint D x) :
    ∃ m1 ∈ D.support, ∃ m2 ∈ D.support, m1 ≠ m2 ∧
      weightEval D.coeff x m1 = weightEval D.coeff x m2
```

and a converse under genericity:
```lean
theorem competing_minimizers_yield_tropical_hypersurface
    {n : ℕ} (D : BoundaryMeasurementData ℝ) (x : Fin n → ℝ)
    (hgen : genericBoundaryMeasurement D)
    (hmin :
      ∃ m1 ∈ D.support, ∃ m2 ∈ D.support, m1 ≠ m2 ∧
        isMinimalWeight D x m1 ∧ isMinimalWeight D x m2) :
    TropicalHypersurfacePoint D x
```

#### Cross-domain significance
This theorem is the first rigorous bridge between
- **tropical hypersurfaces** (piecewise-linear algebraic geometry),
- **competing contraction channels** (tensor network physics),
- **degeneracy of dominant sectors** (statistical mechanics / large deviation flavor).

#### Proof strategy options
**Strategy A: unfold definitions**
1. Expand `TropicalHypersurfacePoint`.
2. Extract two distinct minimizers by `rcases`.
3. Build the conclusion directly.

**Strategy B: genericity via exclusion of triple ties**
1. Define a genericity condition forbidding three-way equal minima.
2. Show that two equal minima imply membership in the tropical hypersurface.
3. Use contradiction to rule out support pathologies.

**Why B matters:** it yields a robust geometric theorem, not just a definitional tautology, and can support computational tests in `demo.py`.

This theorem should not be trivialized; the converse direction should require careful use of your genericity definition, finite support arguments, and `by_contra`.

---

### Theorem 3: Tropical Lorentzian gap is bounded by bond complexity

This is the flagship theorem. You likely cannot fully prove the exact physics conjecture “gap scales with log bond dimension” in complete generality in one cycle. But you can and should prove a mathematically sharp finite-model version.

**Target theorem.** For a class of factorized or determinantal boundary measurement models associated to finite tensor networks, the tropical Lorentzian gap is bounded above or below by a monotone function of the bond dimension, and is invariant under support-preserving gauge transformations.

A realistic first theorem:

#### Suggested Lean 4 theorem signatures
```lean
theorem tropicalLorentzianGap_mono_under_support_refinement
    {n : ℕ} {D₁ D₂ : BoundaryMeasurementData ℝ}
    (hsub : D₁.support ⊆ D₂.support)
    (hval : compatibleValuation D₁ D₂) :
    tropicalLorentzianGap D₂ ≤ tropicalLorentzianGap D₁
```

Then instantiate for tensor networks:
```lean
theorem tropicalLorentzianGap_le_bondDimBound
    (T : FiniteTensorNetwork)
    (hfactor : factorizedBoundaryModel T) :
    tropicalLorentzianGap (boundaryMeasurementData T) ≤
      bondDimComplexityBound T.bondDim
```

Or if lower bound is easier from your definitions:
```lean
theorem bondDimLowerBound_of_positive_tropicalGap
    (T : FiniteTensorNetwork)
    (hgap : 0 < tropicalLorentzianGap (boundaryMeasurementData T)) :
    minRequiredBondDim T ≤ bondDimFromGap
      (tropicalLorentzianGap (boundaryMeasurementData T))
```

#### Why this is revolutionary
This is the first formal theorem converting a tropical/Lorentzian geometric invariant into a certified statement about tensor network complexity. Even a finite-model inequality would be field-opening: it suggests that tropical geometry can witness obstructions to low-bond-dimension representation.

#### Proof strategy options
**Strategy A: support counting / separation argument**
1. Show bond dimension bounds the number or arrangement of admissible support sectors.
2. Show the tropical gap is controlled by minimal separation among these sectors.
3. Conclude via finite combinatorial optimization.

**Strategy B: determinantal/matroid route**
1. Restrict to a class of boundary measurement polynomials known to be determinantal or matroidal.
2. Use tropicalization properties of determinantal supports / matroid polytopes.
3. Relate rank or basis-exchange structure to bond dimension.

**Strategy C: perturbative stability**
1. Use catalog perturbation/stability theorems from tropical infrastructure.
2. Show small coefficient perturbations preserve support geometry and gap estimates.
3. Deduce the bond-dimension bound from a simpler normal form.

**Most promising:** B + C. The determinantal/matroid route gives genuine structure; perturbative stability gives robustness and computational relevance.

---

## Strong Cross-Domain Theorem

You are required to include at least one theorem that explicitly bridges domains. The best choice is:

### Theorem 4: Matroidal exchange or M-convexity from tensor network boundary support

If your boundary support model is set up correctly, prove that for a restricted class of planar/free-fermionic/determinantal tensor networks, the support of the boundary measurement polynomial satisfies a basis-exchange or M-convex-type axiom.

#### Suggested Lean theorem signature
```lean
theorem boundary_support_exchange_property
    (T : FiniteTensorNetwork)
    (hdet : determinantalBoundaryModel T) :
    ExchangeLikeProperty (tropicalPolynomialSupport (boundaryMeasurementData T))
```

or if you formalize a set-family version:
```lean
theorem boundary_support_is_matroidal
    (T : FiniteTensorNetwork)
    (hdet : determinantalBoundaryModel T) :
    ∃ M : Matroid α, supportAsSets (boundaryMeasurementData T) = M.bases
```

#### Why this matters
This connects
- tensor network boundary physics,
- tropical geometry,
- matroid theory / Lorentzian combinatorics.

That is exactly the kind of “I never thought of that connection” result we want.

---

## Lean 4 Type Signature Guidance

You asked for precise theorem statements with Lean signatures. Here are condensed candidate signatures you can adapt to actual Mathlib objects:

```lean
theorem support_subset_boundary_flow_polytope
    (T : FiniteTensorNetwork) :
    ∀ m ∈ (boundaryMeasurementData T).support,
      satisfiesBoundaryFlowConstraints T m
```

```lean
theorem tropical_hypersurface_has_competing_boundary_sectors
    {n : ℕ} (D : BoundaryMeasurementData ℝ) (x : Fin n → ℝ) :
    TropicalHypersurfacePoint D x →
    ∃ m1 ∈ D.support, ∃ m2 ∈ D.support, m1 ≠ m2 ∧
      weightEval D.coeff x m1 = weightEval D.coeff x m2
```

```lean
theorem competing_minimizers_yield_tropical_hypersurface
    {n : ℕ} (D : BoundaryMeasurementData ℝ) (x : Fin n → ℝ)
    (hgen : genericBoundaryMeasurement D) :
    (∃ m1 ∈ D.support, ∃ m2 ∈ D.support, m1 ≠ m2 ∧
      isMinimalWeight D x m1 ∧ isMinimalWeight D x m2) →
    TropicalHypersurfacePoint D x
```

```lean
theorem tropicalLorentzianGap_le_bondDimBound
    (T : FiniteTensorNetwork)
    (hfactor : factorizedBoundaryModel T) :
    tropicalLorentzianGap (boundaryMeasurementData T) ≤
      bondDimComplexityBound T.bondDim
```

```lean
theorem boundary_support_exchange_property
    (T : FiniteTensorNetwork)
    (hdet : determinantalBoundaryModel T) :
    ExchangeLikeProperty ((boundaryMeasurementData T).support)
```

These signatures are intentionally modular. If full coefficient semantics become cumbersome, prove support-level theorems first and valuation-level theorems second.

---

## How to Build on Catalog Results

You were given these references:

- `Catalog/Pythagorean/QuantumLorentzianBridge.lean`
  - `QuantumMeasurementModel`
  - `boundaryMass`
- `Catalog/Pythagorean/TropicalLorentzianShadows.lean`
- `Catalog/Pythagorean/TropicalBerggrenZeta.lean`
- `Catalog/Tropical/`

You must explicitly inspect and reuse them.

### Expected reuse pattern

1. **From `QuantumLorentzianBridge.lean`**
   - Reuse `QuantumMeasurementModel` as the semantic ancestor of your boundary measurement data.
   - If `boundaryMass` gives a scalar/weight attached to boundary configurations, lift it into the coefficient map of `BoundaryMeasurementData`.
   - Prove a compatibility lemma:
   ```lean
   theorem boundaryMeasurementData_coeff_eq_boundaryMass ...
   ```

2. **From `TropicalLorentzianShadows.lean`**
   - Reuse any certified tropical/Lorentzian shadow or support separation lemma.
   - Extend shadow/stability lemmas from abstract support data to tensor-network-generated support.
   - If there is a theorem controlling tropical separation under perturbation, use it to show your `tropicalLorentzianGap` is stable under gauge-normalized coefficient changes.

3. **From `Catalog/Tropical/`**
   - Use existing tropical polynomial infrastructure rather than rolling your own wherever feasible.
   - But if the existing infrastructure lacks a tensor-network-facing interface, create a thin wrapper with your new definitions.

4. **From `TropicalBerggrenZeta.lean`**
   - Not because the subject is the same, but because it may contain useful finite-support summation, valuation, or tropical counting patterns.
   - Cross-pollinate proof techniques if they are already certified and robust.

---

## Proof Architecture: 3 Concrete Multi-Step Routes

### Route I: Compositional support calculus
This is the safest backbone.

1. Define local tensor contribution supports.
2. Prove lemmas for support under tropical/product composition:
   - support of sum is contained in union,
   - support of product is contained in Minkowski sum / convolution support.
3. Induct over a decomposition of the network.
4. Derive support constraints and flow conservation.

This route should yield Theorem 1 and prepare Theorem 3.

### Route II: Generic tropical geometry of competing minimizers
This route gives geometric meaning.

1. Define tropical evaluation and tropical hypersurface membership.
2. Prove extraction lemmas for minimizers from finite support.
3. Introduce a genericity hypothesis excluding three-way ties or degenerate support.
4. Prove equivalence between “multiple minimal sectors” and hypersurface membership.

This route yields Theorem 2 and supports the demo.

### Route III: Determinantal/matroidal restricted class
This route gives the deepest cross-domain theorem.

1. Restrict to a class of tensor networks whose boundary polynomial is determinantal/free-fermionic/matroidal.
2. Show support satisfies exchange/M-convex property.
3. Transfer this to a tropical Lorentzian or gap statement.
4. Relate combinatorial rank complexity to bond dimension.

This route is the most visionary and likely the hardest, but even a restricted theorem here would be a major result.

---

## Falsifiable Conjecture with Computational Test

You must state at least one explicit conjecture and make it computationally disprovable.

### Conjecture A: tropical gap vs logarithmic bond dimension
For a family `T_k` of finite PEPS-like rectangular networks with uniform bond dimension `χ_k`,
\[
c_1 \log(\chi_k + 1) \le \operatorname{tropicalLorentzianGap}(P_{\mu,k}) \le c_2 \log(\chi_k + 1)
\]
for constants \(c_1,c_2>0\) after suitable normalization, for all sufficiently regular instances in the family.

#### Computational falsification protocol
- Generate exact small-lattice instances: \(2\times 3\), \(2\times 4\), perhaps \(3\times 3\) if feasible.
- Compute boundary measurement supports and coefficients exactly or with rational surrogates.
- Tropicalize using min-plus evaluation.
- Estimate the gap by searching for near-ties among support monomials over sampled tropical parameter points.
- Fit against `log χ`.
- A systematic failure of monotonicity or logarithmic scaling falsifies the conjecture.

### Conjecture B: exchange property for planar determinantal networks
For planar determinantal tensor networks, the support family of boundary sectors is matroidal.

#### Falsification
- Enumerate support families for small planar networks.
- Check basis-exchange directly.
- Any counterexample kills the conjecture.

Include at least one such conjecture in the Lean comments and in `RESEARCH_PAPER.md`.

---

## Application Keywords

Include these explicitly in your paper and metadata-style summaries:

- tensor networks
- PEPS
- MERA
- tropical geometry
- Lorentzian polynomials
- matroid theory
- M-convexity
- boundary measurement
- entanglement geometry
- bond dimension
- tropical optimization
- quantum many-body systems
- combinatorial complexity
- free-fermionic models
- determinantal varieties
- hypersurface degeneracy
- contraction algorithms

---

## Deliverables You Must Produce

You must produce **all** of the following.

### 1. Lean file with new definitions and at least 3 serious theorems
Requirements:
- No trivial theorem padding.
- At least 3 theorems with proof scripts using combinations of:
  - `induction`
  - `rcases`
  - `by_contra`
  - `field_simp` where genuinely relevant
  - multi-step `calc`
- At least one new mathematical structure not already in the catalog.
- At least one cross-domain theorem.
- Minimize `sorry`; if one remains, isolate it to the hardest frontier lemma and clearly mark it.

### 2. `FUTURE_DIRECTIONS.md`
Provide 3–5 original research directions.
Each direction must include:
- **“The key insight is...”**
- **“Why now?”**
At least one direction must bridge to a different domain, e.g.
- tropical quantum error correction,
- Lorentzian invariants in holography,
- tropical complexity lower bounds for contraction,
- statistical mechanics of tropical boundary phases.

### 3. `RESEARCH_PAPER.md`
A standalone scientific document.
A reader with no code access must understand:
- the theorem statements,
- the definitions,
- why this matters,
- what was computationally tested,
- what the next conjectures are.

This paper must foreground the mathematics and physics, not the verification process.

### 4. `ARTICLE.md`
Write in Scientific American style.
Explain:
- what tensor networks are,
- why tropical geometry unexpectedly enters,
- how “competing dominant boundary sectors” become geometric objects,
- why this could matter for quantum matter and computation.

TABOO: do **not** focus on formal verification machinery.

### 5. Verified algorithm / computational method
You must implement a verified computational method, not just prove a theorem.

Best target:
- an algorithm that, given finite support boundary measurement data, computes or approximates:
  - tropical minimizer sectors,
  - hypersurface witness points,
  - or a lower/upper bound for the tropical Lorentzian gap.

Suggested specification theorem:
```lean
theorem gapEstimator_sound
    (D : BoundaryMeasurementData ℝ) :
    gapEstimator D ≤ tropicalLorentzianGap D
```
or a certified witness theorem:
```lean
theorem witnessAlgorithm_sound
    (D : BoundaryMeasurementData ℝ) (x : Fin n → ℝ) :
    witnessAlgorithm D x = some (m1, m2) →
    m1 ∈ D.support ∧ m2 ∈ D.support ∧ m1 ≠ m2 ∧
    weightEval D.coeff x m1 = weightEval D.coeff x m2
```

### 6. `demo.py`
Interactive demonstration that:
- constructs small finite tensor-network-like examples,
- computes support and tropical evaluations,
- visualizes or prints competing minimizers,
- tests the conjectured relation between tropical gap and bond dimension,
- and searches for counterexamples to the exchange/matroid conjecture on small instances.

---

## Standard of Ambition

Do not settle for “I defined a tropical polynomial for a network.” That is infrastructure. The real goal is a theorem showing that **a geometric object extracted from a quantum boundary polynomial constrains entanglement/combinatorial complexity**.

The strongest acceptable outcome this cycle is:
1. a rigorous finite-model boundary support theorem,
2. a theorem identifying tropical hypersurface points with competing boundary sectors,
3. a first inequality relating a tropical Lorentzian-gap-style invariant to bond complexity,
4. a computational pipeline that can falsify the scaling conjecture.

If you can also prove a restricted matroidal exchange theorem for determinantal/free-fermionic boundary models, that is a genuine breakthrough.

Be bold, but be surgical. Formalize the smallest model in which the theorem is truly new. Then prove the hardest nontrivial statement in that model.

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
