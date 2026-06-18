Soli Deo Gloria

## Assignment: Direction 2: Symmetry Rigidity (Converse Noether)

**Mode:** prove

Prove a genuinely new converse-Noether rigidity theorem for discrete mechanics: exact conservation of the momentum observable along **all** discrete Euler–Lagrange trajectories should force invariance of the discrete Lagrangian under the generating symmetry. This is not a routine extension of `discrete_momentum_conserved`; it upgrades a one-way variational principle into a **characterization theorem** for symmetry itself.

The target is a field-opening result at the interface of geometric mechanics, inverse problems, and structure-preserving numerics:

> **If every trajectory carries a conserved discrete momentum, then the scheme did not merely inherit a conservation law accidentally — it must encode an actual symmetry.**

This would create a new diagnostic theory for variational integrators: conservation is no longer just a desirable consequence, but an **identifiability criterion** for hidden symmetry.

---

## Core Mathematical Vision

Classical Noether says symmetry implies conservation. Your mission is to formalize a **discrete converse**:

- not just “invariance implies momentum conservation,” already present in the catalog,
- but “if the momentum is conserved for every discrete Euler–Lagrange orbit and every admissible initial condition, then the discrete Lagrangian is invariant under the corresponding infinitesimal action.”

This is mathematically deep because it transforms a variational identity into a rigidity statement about the Lagrangian itself. It opens an **inverse theory of geometric integration**: infer latent symmetry from observed exact conservation.

---

## Catalog Foundations You Must Build On

Use these as the certified starting point:

- `discrete_momentum_conserved` in `Physics/DiscreteNoetherShadow.lean`
- `discrete_momentum_conserved_range` in `Physics/DiscreteNoetherShadow.lean`

Do not merely restate or lightly generalize them. Use them as the forward implication and structural template for the converse theorem.

You should explicitly inspect how momentum is defined there, how invariance is encoded, and what hypotheses can be weakened or reorganized into a converse statement.

---

## Precise Theorem Targets

You must introduce at least one **new definition** not already in the catalog, and then prove at least **3 nontrivial theorems** around it.

### New definition to introduce

Define a notion expressing that a two-point discrete Lagrangian has vanishing symmetry defect along the generator of a group action.

Suggested concept:

```lean
def symmetryDefect
  (Ld : Q → Q → ℝ)
  (ξ : Q → TQ) -- replace by the actual infinitesimal-action type available in your development
  (q0 q1 : Q) : ℝ := ...
```

If tangent-bundle infrastructure is too heavy, define instead a finite-difference / directional symmetry defect tailored to the existing catalog encoding of discrete momentum:

```lean
def DiscreteSymmetryDefect
  (Ld : Q → Q → ℝ)
  (Φ : G → Q → Q)
  (q0 q1 : Q) : Prop := ...
```

or, more concretely, a first-order invariance predicate:

```lean
def InfinitesimallyInvariant
  (Ld : Q → Q → ℝ)
  (X : Q → V) -- infinitesimal generator
  : Prop := ...
```

The key is to define a mathematically meaningful object that measures symmetry breaking, not just a wrapper around an existing theorem.

---

## Main theorem statement

A precise target theorem should have the following logical shape:

### Theorem A: Converse Noether rigidity

For a suitable configuration space `Q`, discrete Lagrangian `Ld : Q → Q → ℝ`, group action generator `X`, and momentum observable `p`, prove:

```lean
theorem converse_discrete_noether
  {Q : Type*} [AddCommGroup Q] [Module ℝ Q] [TopologicalSpace Q]
  (Ld : Q → Q → ℝ)
  (p : Q → Q → ℝ)
  (X : Q → Q)
  (DEL : Q → Q → Q → Prop)
  (hfirstVar :
    ∀ qkm1 qk qkp1,
      DEL qkm1 qk qkp1 →
      p qk qkp1 - p qkm1 qk = symmetryDefect Ld X qkm1 qk qkp1)
  (hcons :
    ∀ qkm1 qk qkp1,
      DEL qkm1 qk qkp1 →
      p qk qkp1 = p qkm1 qk)
  (hdense :
    ∀ q0 q1, ∃ qkm1 qkp1, DEL qkm1 q0 q1 ∨ DEL q0 q1 qkp1)
  : InfinitesimallyInvariant Ld X := ...
```

This exact signature may need adaptation to the catalog’s actual types. That is expected. But the theorem must preserve the mathematical quantifier pattern:

1. a first-variation identity expressing momentum drift as symmetry defect,
2. exact conservation on all DEL trajectories,
3. a richness/density/surjectivity hypothesis saying DEL trajectories probe enough two-point data,
4. conclusion: infinitesimal invariance of `Ld`.

This is the breakthrough theorem.

---

## Additional theorem targets

You need at least **three** substantial theorems total. Suggested package:

### Theorem B: Forward–converse equivalence under richness
Show the forward theorem from the catalog and your converse combine into an iff.

```lean
theorem discrete_noether_iff_conservation
  ...
  : InfinitesimallyInvariant Ld X ↔
    ∀ qkm1 qk qkp1, DEL qkm1 qk qkp1 → p qk qkp1 = p qkm1 qk := ...
```

This is conceptually powerful: conservation is **equivalent** to symmetry, not merely implied by it.

### Theorem C: Zero defect characterization
Prove that if momentum drift vanishes for all trajectories, then the symmetry defect vanishes on all accessible two-point data.

```lean
theorem symmetryDefect_eq_zero_of_all_momentum_conserved
  ...
  : ∀ qkm1 qk qkp1, DEL qkm1 qk qkp1 → symmetryDefect Ld X qkm1 qk qkp1 = 0 := ...
```

This theorem should use `calc`, substitution, and nontrivial reasoning from the first-variation identity.

### Theorem D: Quantitative symmetry-breaking estimate
Formalize the perturbative prediction: if `Ldε = Ld + ε * ΔLd`, then momentum drift is bounded linearly by `|ε|`, and ideally by `|ε| * h` if a timestep parameter is present.

```lean
theorem momentum_drift_bound_of_perturbation
  ...
  : |pε qk qkp1 - pε qkm1 qk| ≤ |ε| * C * h := ...
```

If `h` is not yet in the catalog encoding, first prove a weaker theorem with `|ε| * C`, then strengthen to `|ε| * C * h` after defining a consistent step-scaled defect. This gives you the algorithmic and computational bridge demanded by the prompt.

---

## Lean 4 formalization guidance

You must adapt the signatures to the actual catalog abstractions, but here is a realistic Lean-style skeleton for the new concepts:

```lean
def MomentumConservedOnTrajectories
  (DEL : Q → Q → Q → Prop)
  (p : Q → Q → ℝ) : Prop :=
  ∀ ⦃qkm1 qk qkp1 : Q⦄, DEL qkm1 qk qkp1 → p qk qkp1 = p qkm1 qk

def SymmetryDefectZeroOnTrajectories
  (DEL : Q → Q → Q → Prop)
  (D : Q → Q → Q → ℝ) : Prop :=
  ∀ ⦃qkm1 qk qkp1 : Q⦄, DEL qkm1 qk qkp1 → D qkm1 qk qkp1 = 0

def RichDiscreteFlow
  (DEL : Q → Q → Q → Prop) : Prop :=
  ∀ q0 q1 : Q, ∃ qkm1 qkp1, DEL qkm1 q0 q1 ∧ DEL q0 q1 qkp1

def InfinitesimallyInvariant
  (Ld : Q → Q → ℝ)
  (X : Q → Q) : Prop :=
  ∀ q0 q1, firstOrderVariation Ld X q0 q1 = 0
```

Then prove:

```lean
theorem defect_zero_of_conservation
  (hvar :
    ∀ qkm1 qk qkp1,
      DEL qkm1 qk qkp1 →
      p qk qkp1 - p qkm1 qk = D qkm1 qk qkp1)
  (hcons : MomentumConservedOnTrajectories DEL p) :
  SymmetryDefectZeroOnTrajectories DEL D := ...

theorem infinitesimal_invariance_of_defect_zero
  (hrich : RichDiscreteFlow DEL)
  (htransfer :
    ∀ qkm1 qk qkp1,
      DEL qkm1 qk qkp1 →
      D qkm1 qk qkp1 = transportDefectToPair Ld X qk qkp1)
  (hzero : SymmetryDefectZeroOnTrajectories DEL D) :
  InfinitesimallyInvariant Ld X := ...

theorem converse_discrete_noether
  ...
  : InfinitesimallyInvariant Ld X := ...
```

These are not templates to copy blindly; they are a formal architecture. Refine them against the actual objects in `Physics/DiscreteNoetherShadow.lean`.

---

## Proof strategies: 3 viable paths

### Strategy 1: First-variation identity → vanishing defect → invariance
**Most promising.**

1. Use the discrete first-variation formula already implicit in `discrete_momentum_conserved`: derive
   \[
   p(q_k,q_{k+1}) - p(q_{k-1},q_k) = \mathcal D_L(q_{k-1},q_k,q_{k+1}),
   \]
   where `𝒟_L` is the symmetry defect.
2. If momentum is conserved on all DEL triples, conclude `𝒟_L = 0` on all DEL triples.
3. Use a richness hypothesis on DEL trajectories to show every relevant pair `(q0,q1)` is seen inside some DEL triple, so the pairwise infinitesimal variation must vanish.
4. Conclude infinitesimal invariance of `Ld`.

**Why best:** It directly mirrors the analytic proof and builds naturally on the existing catalog theorem. It is also the most likely to formalize cleanly in Lean with `rcases`, `calc`, and theorem decomposition.

---

### Strategy 2: Contrapositive rigidity
1. Assume `Ld` is **not** invariant under the generator.
2. Extract a pair `(q0,q1)` with nonzero infinitesimal symmetry defect.
3. Use local realizability / richness of DEL data to extend this pair to a trajectory segment.
4. Show the momentum increment is nonzero on that segment, contradicting universal conservation.

**Why useful:** This gives a sharper conceptual theorem and may produce a cleaner final statement:
\[
\neg \text{invariant} \implies \exists \text{ trajectory with momentum drift}.
\]
This is excellent for diagnostics and numerical applications.

**Lean tactics likely needed:** `by_contra`, `push_neg`, `rcases`, local witness extraction.

---

### Strategy 3: Perturbative family and linear response
1. Define a perturbed family `Ldε = Ld + ε * ΔLd`.
2. Compute or axiomatize the induced momentum drift as a linear functional in `ε`.
3. Prove that exact conservation for all `ε` near `0` forces the perturbation defect to vanish identically.
4. Deduce rigidity of the unperturbed symmetry class.

**Why important:** This is the route to the computational test and the `ε·h` prediction. It opens the door to **quantitative converse Noether theory**, not just qualitative equivalence.

**Best use:** As your third theorem / algorithmic theorem, even if the full main converse is proved by Strategy 1.

---

## Cross-domain connections you must explicitly develop

This project must not remain “just geometric mechanics.” Build at least one theorem and discussion thread connecting to another domain.

### 1. Inverse problems / identifiability
Interpret the theorem as an inverse problem:

- observed exact conservation law
- infer hidden symmetry of the generating model

This parallels rigidity results in system identification and statistical inference.

### 2. Numerical analysis / backward error analysis
Your theorem gives a structural interpretation of drift:

- zero drift = exact symmetry,
- small drift = quantified symmetry breaking,
- drift scaling reveals whether the defect is physical or discretization-induced.

This is highly relevant to long-time integration diagnostics.

### 3. Mathematical physics
Connect to symmetry breaking in lattice models and discrete field theories:

- exact conservation corresponds to exact gauge/global invariance,
- drift under anisotropic perturbation measures explicit symmetry breaking.

### 4. Dynamical systems
A converse Noether theorem is a rigidity statement for recurrence and invariant quantities, linking variational integrators to the theory of first integrals.

### 5. Potential algebraic bridge
If your formalization supports group actions abstractly, phrase invariance via representation-theoretic data: the momentum map becomes an intertwining witness between dynamics and the group action.

---

## Concrete theorem package to implement

At minimum, your Lean development should contain:

1. **A new definition** such as `InfinitesimallyInvariant`, `MomentumConservedOnTrajectories`, `RichDiscreteFlow`, or `symmetryDefect`.
2. **Theorem 1:** momentum conservation implies zero symmetry defect on DEL trajectories.
3. **Theorem 2:** zero defect plus richness implies infinitesimal invariance.
4. **Theorem 3:** combine with catalog forward theorem to obtain an iff characterization.
5. **Optional but strongly encouraged Theorem 4:** perturbative drift estimate for `Ld + εΔLd`.

At least three of these must involve nontrivial proof structure using induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc`. Avoid shallow proofs.

---

## Suggested file and theorem organization

Create a new file adjacent to the catalog source, e.g.

- `Physics/DiscreteNoetherConverse.lean`

Possible theorem names:

- `def MomentumConservedOnTrajectories`
- `def RichDiscreteFlow`
- `def InfinitesimallyInvariant`
- `theorem defect_zero_of_momentum_conserved`
- `theorem infinitesimal_invariance_of_defect_zero`
- `theorem converse_discrete_noether`
- `theorem discrete_noether_iff_conservation`
- `theorem momentum_drift_bound_of_perturbation`

---

## Quantitative conjecture with testable prediction

You must state and analyze this falsifiable conjecture:

> **Conjecture (step-scaled drift law).**  
> Let `Ld_h` be a rotationally invariant discrete Lagrangian for the Kepler problem with timestep `h`, and let `Ld_h^ε = Ld_h + ε ΔLd_h` where `ΔLd_h` breaks rotational symmetry but remains uniformly smooth. Then along discrete Euler–Lagrange trajectories over one step,
> \[
> |\Delta J_k| = |J_{k+1} - J_k| \le C\,|\varepsilon|\,h + O(|\varepsilon|h^2),
> \]
> and generically
> \[
> |\Delta J_k| \asymp c\,|\varepsilon|\,h
> \]
> for nondegenerate initial data.

This is falsifiable:

- fix `h`,
- vary `ε`,
- compute drift,
- test linear scaling in `ε`,
- then vary `h` and test whether the slope is linear in `h`.

A failure of `ε h` scaling would refute the conjectured coupling between symmetry breaking and discretization scale.

---

## Verified algorithm / computational method

You must produce a verified computational method, not just a theorem.

### Required algorithmic deliverable
Implement a **symmetry-rigidity diagnostic**:

Input:
- a discrete Lagrangian `Ld`,
- a candidate momentum observable `p`,
- a finite sample of DEL trajectory segments.

Output:
- empirical maximum drift
  \[
  \max_k |p(q_k,q_{k+1}) - p(q_{k-1},q_k)|
  \]
- an inferred symmetry-defect score,
- a pass/fail test against exact conservation.

The formal theorem should justify that:
- exact zero score on all admissible segments implies symmetry under the theorem hypotheses;
- nonzero score witnesses symmetry breaking.

If full real-number computation is too heavy in Lean, verify the symbolic reduction or a rational toy model and expose the numerical exploration in `demo.py`.

---

## demo.py requirements

Your `demo.py` must do more than print constants. It should:

1. instantiate a toy discrete Lagrangian with a known symmetry,
2. compute momentum drift along a short trajectory,
3. perturb by `εΔLd`,
4. display drift vs `ε`,
5. optionally display drift vs `h`,
6. numerically fit whether drift behaves like `ε` or `εh`.

Ideal plots:
- log-log drift vs `ε`,
- drift/ε vs `h`.

This will make the conjecture scientifically alive.

---

## Application keywords

Use these explicitly in your paper and article:

- converse Noether theorem
- variational integrators
- symmetry rigidity
- momentum map
- structure-preserving numerics
- inverse problems
- identifiability
- symmetry breaking
- geometric mechanics
- backward error analysis
- discrete dynamics
- perturbation theory
- Kepler problem
- long-time stability
- diagnostics for hidden symmetry

---

## Revolutionary significance

If you succeed, this project opens an entirely new direction:

- **Inverse geometric mechanics:** infer symmetry from conservation data.
- **Certified diagnostics for simulation:** distinguish exact geometric structure from accidental near-conservation.
- **Quantitative symmetry breaking:** use drift to measure the strength of broken invariance.
- **Bridges to physics:** discrete analogues of explicit symmetry breaking in lattice and field-theoretic models.
- **Algorithmic science:** symmetry detection from trajectory data becomes mathematically principled.

This is bigger than extending Marsden–West. It turns discrete Noether theory into a bidirectional correspondence and creates a new language for diagnosing the geometry encoded by numerical schemes.

---

## Mandatory deliverables

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and at least 3 nontrivial theorems, minimizing `sorry`.
2. **FUTURE_DIRECTIONS.md** with **3–5 testable scientific hypotheses**, each falsifiable with a clear computational or theoretical test.
3. **RESEARCH_PAPER.md** as a standalone scientific paper: theorem statements, motivation, proof ideas, significance, limitations, and next experiments.
4. **ARTICLE.md** in Scientific American style, accessible and engaging, focused on the mathematics and scientific significance — **do not focus on formal verification machinery**.
5. **A verified algorithm or computational method** implementing the symmetry-rigidity diagnostic.
6. **demo.py** demonstrating the theorem/conjecture interactively on a meaningful example.

Do not settle for a weak formalization. Prove a theorem that changes what conservation laws mean in discrete mechanics.

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
