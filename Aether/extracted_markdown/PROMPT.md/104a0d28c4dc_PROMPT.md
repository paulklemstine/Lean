## Assignment: Algebra–EML–MachineLearning Tropical Information Bottleneck Duality via Closure Capacities and Neural Operad Rate Regions

**Mode:** prove

Work in:
`Bridges/EMLMachineLearning/TropicalInformationBottleneckDuality.lean`

This is not an incremental extension. The objective is to forge a rigorous min-plus information bottleneck theorem in an idempotent/EML setting that unifies three structures that are usually treated separately:

1. **closure-theoretic semantics** of representation,
2. **operadic compositional complexity** of neural architectures,
3. **rate–distortion duality** in tropical algebra.

The breakthrough is to prove that these are not merely analogous but *Legendre dual* in a precise certified sense. If successful, this opens an entirely new formal field: **tropical information theory for compositional learning systems**.

---

## Core Theorem to Prove

Let `S` be a finitely generated idempotent semiring of features, let `cl` be an extensive/monotone/idempotent closure operator on a family of `S`-representations, and let `O` be a neural operad acting on latent representations. Assume a finite family of canonical observer layers induces a finite set of candidate latent summaries `Z`. Define:

- `Cap_cl X Z` = closure capacity of encoding `X` into latent `Z`,
- `Dist Z Y` = tropical reconstruction distortion of `Z` relative to target `Y`,
- `Spec O` = finite operadic complexity spectrum consisting of pairs `(c,d)` of closure-capacity and distortion values realized by canonical observer factors.

Define the tropical bottleneck value function
\[
B_{O,\mathrm{cl}}(\beta) = \inf_Z \bigl(\mathrm{Cap}_{\mathrm{cl}}(X \to Z) \oplus (\beta \otimes D_{\trop}(Z,Y))\bigr),
\]
which in ordinary ordered-language is the infimum of
\[
\mathrm{Cap}_{\mathrm{cl}}(X \to Z) + \beta\, D_{\trop}(Z,Y).
\]

### Precise target theorem
Under finite generation / finite observer / realizability hypotheses:

\[
\forall \beta,\quad
B_{O,\mathrm{cl}}(\beta)
=
\min_{(c,d)\in \mathrm{Spec}(O,\mathrm{cl},X,Y)} (c + \beta d).
\]

Equivalently, `B_O_cl` is the lower envelope of finitely many affine tropical functionals, hence piecewise-linear and concave in the min-plus sense. Moreover, the set of slopes of affine pieces coincides with the realized distortion coordinates of the operadic compression spectrum, and the breakpoints correspond to extreme closure-stable observer factors.

This is the exact bridge you should formalize: **closure capacities are primal objects, tropical bottleneck values are their min-plus convex conjugates, and operadic spectra are the dual certificates**.

---

## Lean 4 Formal Target

You will likely need to introduce a finite abstract interface rather than fully committing to every semantic object immediately. The theorem should be stated at a level Lean can digest while still preserving the mathematics.

A plausible central theorem signature is:

```lean
theorem tropical_bottleneck_eq_min_legendre_of_finite_spectrum
  {ι βT : Type*}
  [LinearOrder βT]
  [CanonicallyOrderedAddMonoid βT]
  (Obs : Finset ι)
  (cap dist : ι → βT)
  (B : βT → βT)
  (hB : ∀ β, B β = Obs.inf' (by simpa using Finset.nonempty_coe_sort.mp ?h_nonempty)
      (fun i => cap i + dist i + β)) :
  ∀ β, ∃ i ∈ Obs, B β = cap i + β + dist i
```

But this is too weak mathematically. A better target, if you set up scalar multiplication on the codomain, is:

```lean
theorem tropical_bottleneck_eq_inf_affine
  {ι R : Type*}
  [LinearOrderedSemiring R]
  (Obs : Finset ι)
  (cap dist : ι → R) :
  ∀ β : R,
    (Obs.inf' (by exact ?hne) (fun i => cap i + β * dist i))
      = Obs.inf' (by exact ?hne) (fun i => cap i + β * dist i)
```

This is tautological, so not enough.

The *real* formal theorem should package a latent family `Z : ι → Latent` together with an abstract bottleneck functional:

```lean
theorem bottleneck_eq_min_over_observer_spectrum
  {ι R X Y Z : Type*}
  [LinearOrderedSemiring R]
  (Obs : Finset ι)
  (enc : ι → Z)
  (Cap : X → Z → R)
  (Dist : Z → Y → R)
  (x : X) (y : Y)
  (B : R → R)
  (hB : ∀ β, B β = sInf ((fun i : ι => Cap x (enc i) + β * Dist (enc i) y) '' (↑Obs : Set ι)))
  (hreal :
    ∀ z, IsCanonicalObserverFactor z →
      ∃ i ∈ Obs, Cap x z = Cap x (enc i) ∧ Dist z y = Dist (enc i) y)
  (hopt :
    ∀ z, AdmissibleLatent z →
      ∃ z', IsCanonicalObserverFactor z' ∧
        Cap x z' ≤ Cap x z ∧ Dist z' y ≤ Dist z y) :
  ∀ β, ∃ i ∈ Obs, B β = Cap x (enc i) + β * Dist (enc i) y
```

Then prove a stronger corollary giving piecewise linearity by finite slope set:

```lean
theorem bottleneck_piecewise_linear_of_finite_observers
  {ι R X Y Z : Type*}
  [LinearOrderedRing R]
  (Obs : Finset ι)
  (enc : ι → Z)
  (Cap : X → Z → R)
  (Dist : Z → Y → R)
  (x : X) (y : Y) :
  ∃ slopes intercepts : Finset R,
    ∀ β, ∃ m ∈ slopes, ∃ b ∈ intercepts,
      bottleneck Obs enc Cap Dist x y β = b + β * m
```

And the dual-spectrum statement:

```lean
theorem slopes_subset_operadic_spectrum
  {ι R X Y Z : Type*}
  [LinearOrderedRing R]
  (Obs : Finset ι)
  (enc : ι → Z)
  (Cap : X → Z → R)
  (Dist : Z → Y → R)
  (x : X) (y : Y) :
  slopeSet (bottleneck Obs enc Cap Dist x y)
    ⊆ (Finset.image (fun i => Dist (enc i) y) Obs : Finset R)
```

If defining `slopeSet` is too expensive in this cycle, prove the equivalent finite-envelope theorem and record the slope statement in comments/theorem stubs.

---

## Exact Mathematical Statement You Should Aim to Formalize

Let `Obs` be a finite set of canonical observer factors for the operad action on latent representations, and assume:

1. **Observer sufficiency:** every admissible latent `z` is dominated by some observer factor `z' ∈ Obs` with
   \[
   \mathrm{Cap}_{\mathrm{cl}}(X \to z') \le \mathrm{Cap}_{\mathrm{cl}}(X \to z),\qquad
   D_{\trop}(z',Y) \le D_{\trop}(z,Y).
   \]

2. **Finite realizability:** each observer factor gives a well-defined pair
   \[
   (c_i,d_i)=\bigl(\mathrm{Cap}_{\mathrm{cl}}(X\to Z_i),D_{\trop}(Z_i,Y)\bigr).
   \]

3. **Monotone scalarization:** for `β ≥ 0`,
   \[
   \Phi_\beta(z)=\mathrm{Cap}_{\mathrm{cl}}(X\to z)+\beta D_{\trop}(z,Y)
   \]
   is order-preserving under coordinatewise domination.

Then
\[
\forall \beta\ge 0,\quad
B_{O,\mathrm{cl}}(\beta)
=
\min_{i\in Obs}(c_i+\beta d_i).
\]

Further:

- `B_{O,cl}` is piecewise affine;
- every linear piece is realized by some observer factor;
- breakpoints occur only when two observer factors exchange optimality;
- extreme observer factors determine the certified rate region
  \[
  \mathcal R = \{(c,d): \exists i\in Obs,\ c\ge c_i,\ d\ge d_i\}.
  \]

This is the theorem. Not an analogy, not a slogan.

---

## How to Build on Existing Catalog Theorems

### 1. `prime_capacity_le_rate_distortion`
From `Bridges/LawvereRateDistortionDuality.lean`

Use it as a *prototype dual inequality*: it already encodes a capacity-vs-distortion comparison principle. Your task is not to restate it, but to **abstract its proof skeleton**:

- identify the monotone scalarization step,
- isolate the infimum-over-representations mechanism,
- upgrade from a scalar inequality to a **finite dual representation theorem**.

In particular, if `prime_capacity_le_rate_distortion` proves a bound of the form
\[
\mathrm{Cap} \le \mathrm{RD},
\]
you should extract the pattern that capacity behaves as a primal resource and distortion as a penalized dual observable. The new theorem should make this exact in the tropical bottleneck setting by turning a one-sided inequality into a **Fenchel/Legendre-style equality over a finite operadic spectrum**.

### 2. `machineLearning_speculative_operadic_diagonalization_via_neural_proof_semirings`
Use this as the source of compositional/operadic architecture semantics:

- the theorem likely already provides a way to encode architecture-level decomposition,
- extract the notion that canonical factors or diagonals generate a finite semantic family,
- reinterpret those generators as the finite observer set `Obs`.

The key upgrade is conceptual: from “operads organize proofs/networks” to “operads generate a finite compression spectrum whose tropical conjugate is the bottleneck value function.”

That is the new bridge.

---

## Proof Strategy A: Finite Dominating Family → Envelope Theorem
**Most promising.** This is the cleanest route in Lean and the strongest mathematically.

### Step 1
Define an abstract admissible latent class `Adm` and a finite family `Obs : Finset Z` of canonical observers. Formalize the domination hypothesis:
```lean
∀ z, Admissible z →
  ∃ i ∈ Obs, Cap x i ≤ Cap x z ∧ Dist i y ≤ Dist z y
```

### Step 2
For fixed `β`, define
\[
\Phi_\beta(z)=\mathrm{Cap}(x,z)+\beta\mathrm{Dist}(z,y).
\]
Use monotonicity to show every admissible `z` is no better than some `i ∈ Obs`. Hence
\[
\inf_{z \in Adm}\Phi_\beta(z)=\min_{i\in Obs}\Phi_\beta(i).
\]

### Step 3
Conclude the finite-envelope representation. Then derive:
- realizers exist,
- the bottleneck is piecewise affine,
- the set of candidate slopes is finite.

**Why this is most promising:** it reduces the hard semantics to one domination lemma. Once that is in place, all duality statements are finite-order arguments, highly Lean-friendly, and naturally extensible to algorithms.

---

## Proof Strategy B: Epigraph/Lower-Hull Argument in Tropical Convexity
This is conceptually deeper and may yield a more elegant statement.

### Step 1
Define the operadic spectrum
\[
\Sigma = \{(c_i,d_i)\}_{i\in Obs}\subseteq R^2.
\]
Interpret the bottleneck value as support function of the lower hull:
\[
B(\beta)=\min_{(c,d)\in\Sigma}(c+\beta d).
\]

### Step 2
Show that only extreme points of the lower tropical convex hull contribute. This gives the representation theorem identifying optimal encoders with closure-stable extreme observer factors.

### Step 3
Extract breakpoint and slope information from pairwise equalities
\[
c_i+\beta d_i = c_j+\beta d_j.
\]

**Why this is valuable:** it gives geometric meaning and directly produces the certified rate region.  
**Why it is less Lean-friendly:** tropical convex hull machinery may not already exist in Mathlib in the exact form you need, so some geometry will have to be encoded from scratch.

---

## Proof Strategy C: Dynamic Programming via Residuated Operad Composition
This is the algorithmic route and should be pursued after Strategy A establishes the theorem.

### Step 1
Use operadic composition to recursively compute capacity/distortion pairs for composite architectures.

### Step 2
Show the scalarized objective satisfies Bellman optimality in the idempotent semiring:
\[
V_v(\beta)=\min_{u \to v}\bigl(c(u,v)+\beta d(u,v)\bigr).
\]

### Step 3
Prove the DP enumerates exactly the observer spectrum and therefore computes `B`.

**Why this matters:** it turns the theorem into a certifying algorithm, not just an existence result.  
**Why secondary:** formalizing residuation and Bellman recursion may be more expensive than first proving the finite-spectrum duality abstractly.

---

## Cross-Domain Connections You Should Explicitly Exploit

### Tropical geometry
The bottleneck function is a tropical polynomial / lower envelope. Its breakpoints are tropical hypersurface events where two observer factors tie. This imports geometry into representation learning.

### Convex analysis / Legendre duality
This is a min-plus Fenchel transform story. The “slope set” is a discrete subdifferential, and the operadic spectrum plays the role of a dual support set.

### Information theory
This is an idempotent analogue of the information bottleneck and rate–distortion function, but with closure capacity replacing Shannon mutual information. If formalized, it suggests a whole tropical information theory.

### Category theory / EML / Lawvere metrics
Closure capacity should be read as an enriched resource measure; distortion is a Lawvere-style cost observable. The theorem says operadic composition and enriched closure semantics admit a dual scalarized optimization principle.

### Machine learning theory
The resulting finite rate region gives certified compression–generalization tradeoffs for compositional architectures in non-probabilistic settings. This is a new style of certificate distinct from PAC–Bayes and norm-based control.

### Program semantics / verification
Observer factors are interpretable witnesses. The theorem yields certifiable architecture summaries: every optimal tradeoff point has a finite semantic witness.

---

## Concrete Corollaries to Prove If Time Permits

### Corollary 1: Certified rate region
Define
\[
\mathcal R = \{(c,d)\mid \exists i\in Obs,\ c_i\le c,\ d_i\le d\}.
\]
Prove that admissible compression-distortion pairs are exactly the upward closure of the observer spectrum under the domination hypothesis.

Possible Lean form:
```lean
theorem admissible_pair_iff_dominated_by_observer_pair
  ...
```

### Corollary 2: Extreme-point representation
Show every optimizer at parameter `β` can be replaced by an extreme closure-stable observer factor.

Possible Lean form:
```lean
theorem exists_extreme_observer_minimizer
  ...
```

### Corollary 3: Generalization-style bound
If tropical risk is monotone in distortion and closure complexity, derive a certified bound:
\[
\mathrm{GenRisk}(Z)\le F(\mathrm{Cap}_{cl}(X\to Z),D_{\trop}(Z,Y)).
\]
Then minimizing the bottleneck yields a certified tradeoff point.

Keep this abstract if necessary; the important thing is to produce a theorem schema rather than overcommit to a probabilistic generalization framework.

### Corollary 4: Computability
Prove finite computability of the bottleneck by exhaustive evaluation over `Obs`.

Possible Lean form:
```lean
theorem bottleneck_computable_from_finite_observers
  ...
```

---

## Lean Engineering Guidance

You should strongly prefer an abstract finite-order formalization over trying to formalize all semantics at once. A good decomposition is:

1. **Section A:** abstract finite bottleneck envelope theorem over a linearly ordered semiring/ring;
2. **Section B:** abstract closure/observer hypotheses implying the envelope theorem;
3. **Section C:** optional operadic packaging showing how observer families arise from neural generators.

Suggested definitions:
- `ClosureCapacity`
- `TropicalDistortion`
- `AdmissibleLatent`
- `IsCanonicalObserverFactor`
- `ObserverDominates`
- `OperadicSpectrum`
- `BottleneckValue`

Try to keep the main theorem independent of heavy operad internals. The operad should enter through finite generation and observer sufficiency assumptions, not through full syntax of trees unless already available in the catalog.

---

## What Would Make This a Breakthrough

If you prove this cleanly, you will have established:

- a formal **tropical information bottleneck theorem**,
- a new **duality between closure semantics and neural operad complexity**,
- a machine-checkable **rate-region certificate** for compositional learning systems,
- a platform for future tropical analogues of data processing, sufficiency, and representation phase transitions.

This is not a variant of existing rate–distortion work. It is the beginning of a new algebraic information theory for neural architectures.

---

## Application Keywords

tropical information bottleneck; idempotent semiring learning; closure capacity; operadic neural architectures; min-plus Legendre transform; rate–distortion duality; certified compression; tropical generalization bounds; residuated dynamic programming; enriched category learning; Lawvere metric semantics; tropical convexity; finite observer models; semantic compression certificates

---

## Deliverables

1. Formalize the main finite-envelope duality theorem in
   `Bridges/EMLMachineLearning/TropicalInformationBottleneckDuality.lean`.
2. Prove at least one nontrivial corollary: piecewise-linearity, finite slope set, or computability from observers.
3. Use the existing catalog theorems explicitly in comments/docstrings to explain the bridge.
4. Minimize sorry aggressively; if any remain, isolate them to semantic interface lemmas rather than the core duality theorem.
5. Produce `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - tropical data processing inequality for closure capacities,
   - Blackwell sufficiency in idempotent operadic channels,
   - multi-observer tropical rate regions and Pareto fronts,
   - phase-transition theorems for breakpoint geometry,
   - tropical variational principles for deep compositional encoders.

Be bold: the theorem should read like the first page of a new subject.

### Catalog Reference Files
@MachineLearning/OperadicDeepLearning/Foundations.lean
```lean
import Mathlib

/-! # Operadic Deep Learning: Foundations

This file formalizes the algebraic foundations of operadic deep learning theory.
We define symmetric operads, neural layers, and their compositional structure,
then prove foundational theorems connecting neural network composition to operadic
algebraic structure.

## Main Results

### Structures and Definitions (7 novel)
* `NeuralOperad` — typeclass capturing operadic structure of neural modules
* `NeuralLayer` — parameterized affine-activation maps with Lipschitz certification
* `OperadicExpression` — tree-structured operadic expressions (free operad elements)
* `DepthSeparationWitness` — certified depth separation between architectures
* `ApproximationCertificate` — operadic approximation with error and Lipschitz bounds
* `OperadicRankBound` — combined rank + Lipschitz robustness certificate
* `operadicLipschitz` — compositional Lipschitz constant computation

### Theorems (35+ proved, zero sorry)
* Neural operad identity, associativity, and Σ₂-equivariance axioms
* Depth separation via generator count and depth-width product
* Lipschitz-certified compositional robustness bounds (L^k for depth k)
* Universal approximation certificates with operadic rate bounds
* Tropical operadic bridge: linear regions and piecewise-linear analysis
* Robustness-expressivity tradeoff theorem
* Parallel vs sequential architecture comparison

## Bridge: connects algebraic topology (operads) → ML (neural networks) →
   analysis (Lipschitz continuity) → cryptography (certified robustness) →
   tropical geometry (piecewise-linear maps) → complexity theory (circuit depth)
-/

noncomputable section

open NNReal

/-! ## I. Core Algebraic Structures -/

/-- `NeuralOperad`: A typeclass capturing the operadic structure of parameterized
    computation modules. Each arity `n` has an associated type of n-input operations,
    with composition satisfying identity and associativity.

    Bridge: connects category theory (operadic composition) to ML (layer stacking). -/
class NeuralOperad (Op : ℕ → Type*) where
  /-- The identity operation -/
  id_op : Op 1
  /-- Operadic composition -/
  compose : {m : ℕ} → Op m → (Fin m → Op 1) → Op m
  /-- Left identity law -/
  compose_id_left : ∀ {m : ℕ} (f : Op m), compose f (fun _ => id_op) = f
  /-- Right identity law -/
  compose_id_right : ∀ (f : Op 1), compose id_op (fun _ => f) = f

/-- `NeuralLayer`: A parameterized affine map ℝⁿ → ℝᵐ composed with activation,
    equipped with a Lipschitz bound for certified robustness.

    Bridge: connects ML (neural layers) to analysis (Lipschitz continuity)
    to cryptography (adversarial robustness certification). -/
structure NeuralLayer (n m : ℕ) where
  /-- Weight matrix entries -/
  weights : Fin m → Fin n → ℝ
  /-- Bias vector -/
  bias : Fin m → ℝ
  /-- Lipschitz constant of the activation function -/
  activationLipschitz : NNReal
  /-- The Lipschitz constant is positive -/
  lipschitz_pos : (0 : NNReal) < activationLipschitz

/-- `OperadicExpression`: A tree-structured expression in the free operad,
    representing a composed neural architecture.

    Bridge: connects algebraic topology (free operads) to ML (architecture design)
    to computational complexity (circuit depth). -/
inductive OperadicExpression where
  | generator : OperadicExpression
  | identity : OperadicExpression
  | compose : OperadicExpression → OperadicExpression → OperadicExpression
  | parallel : OperadicExpression → OperadicExpression → OperadicExpression
  deriving Repr, BEq

namespace OperadicExpression

/-- The depth of an operadic expression: length of the longest sequential chain.
    Parallel composition takes max (branches run concurrently). -/
def depth : OperadicExpression → ℕ
  | generator => 1
  | identity => 0
  | compose e₁ e₂ => e₁.depth + e₂.depth
  | parallel e₁ e₂ => max e₁.depth e₂.depth

/-- The generator count: total number of generator nodes.
    This is the algebraic analog of parameter block count. -/
def generatorCount : OperadicExpression → ℕ
  | generator => 1
  | identity => 0
  | compose e₁ e₂ => e₁.generatorCount + e₂.generatorCount
  | parallel e₁ e₂ => e₁.generatorCount + e₂.generatorCount

/-- Width = generator count (defined separately for conceptual clarity). -/
def width : OperadicExpression → ℕ
  | generator => 1
  | identity => 0
  | compose e₁ e₂ => e₁.width + e₂.width
  | parallel e₁ e₂ => e₁.width + e₂.width

/-- The depth-width product: key combined invariant for approximation rate. -/
def depthWidthProduct (e : OperadicExpression) : ℕ :=
  e.depth * e.generatorCount

end OperadicExpression

/-! ## II. Certified Structures -/

/-- `OperadicRankBound`: Combined rank + Lipschitz robustness certificate.

    Bridge: connects ML model complexity to adversarial robustness
    to post-quantum security (Lipschitz hash functions). -/
structure OperadicRankBound where
  rankBound : ℕ
  lipschitzBound : NNReal
  lipschitz_pos : (0 : NNReal) < lipschitzBound

/-- `DepthSeparationWitness`: Certificate that two architectures at
    different depths have provably different expressivity. -/
structure DepthSeparationWitness (k₁ k₂ : ℕ) where
  shallow : OperadicExpression
  deep : OperadicExpression
  shallow_depth : shallow.depth = k₁
  deep_depth : deep.depth = k₂
  rank_gap : deep.generatorCount > shallow.generatorCount

/-- `ApproximationCertificate`: Operadic approximation with error and Lipschitz bounds. -/
structure ApproximationCertificate where
  expression : OperadicExpression
  errorBound : ℝ
  error_pos : 0 < errorBound
  lipschitzConst : NNReal

/-! ## III. k-Deep Expressions -/

/-- Composing k generators sequentially: the canonical depth-k architecture. -/
def kDeepExpression : ℕ → OperadicExpression
  | 0 => .identity
  | k + 1 => .compose .generator (kDeepExpression k)

/-- A wide parallel arrangement of n generators (depth 1, width n). -/
def wideParallel : ℕ → OperadicExpression
  | 0 => .identity
-- ... (truncated, full file has 631 lines)
```

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above.

            Use concrete types (Nat, Real, Finset, Matrix). Avoid trivial tautologies.
            If a direct proof fails, try the contrapositive, a constructive witness,
            or structural induction. Connect to at least one other domain for impact.

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md
            Optional: ARTICLE.md, RESEARCH_PAPER.md, demo.py, diagram.svg

            FUTURE_DIRECTIONS.md is critical — it drives the next research cycle.
            Structure it with specific theorem statements, proof strategies, and
            cross-domain connections.


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
    "algorithms": [ { "name": "...", "pseudocode": "..." } ],
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
