## Assignment: Direction 1: Discrete Noether Shadow for Variational Integrators

**Mode:** prove

You are not being asked for a cosmetic extension of continuous Noether theory. You are being asked to formalize a genuinely new bridge: a **discrete shadow principle** showing that variational integrators inherit conservation laws not exactly as smooth equalities, but as **quantitatively controlled almost-invariants**. If completed cleanly in Lean 4, this opens a formal theory of structure-preserving numerics inside theorem proving: not just “the scheme converges,” but “the scheme carries a certified geometric memory of the original physics.”

The target is a mathematically serious discrete counterpart to continuous energy conservation, built on the catalog theorem

- `energy_conserved` in `Physics/NoetherTheorems.lean`

and conceptually linked to

- `tropical_vacuum_energy_eq_minimal_action` in `FINAL/Physics/TropicalVacuumEnergy.lean`

through the principle that discretization selects extremal action through finite-step combinatorics, a min-plus / tropical shadow of variational mechanics.

---

## Core Vision

For a symmetric discrete Lagrangian approximating an autonomous smooth Lagrangian on `ℝⁿ`, prove that the associated discrete variational integrator admits a **discrete Noether shadow energy** whose stepwise defect is `O(h^3)` and whose cumulative drift over a fixed time interval is `O(h^2)`. This is stronger and more conceptually important than a generic convergence estimate: it says the variational scheme formally remembers the continuous conservation law.

This would be a breakthrough because it internalizes a central idea from backward error analysis and geometric integration into Lean in a theorem form that can actually drive certified scientific computing.

---

## Precise Mathematical Targets

You should introduce a new structure encoding a discrete variational system. This is mandatory and should not merely duplicate an existing catalog object.

### New definition: discrete autonomous variational system

A possible design:

```lean
structure DiscreteLagrangianSystem where
  n : ℕ
  Ld : ℝ → (Fin n → ℝ) → (Fin n → ℝ) → ℝ
  smooth_Ld : Prop
  symmetric : ∀ h q₀ q₁, Ld h q₀ q₁ = Ld h q₁ q₀
  autonomous : Prop
```

You should also define:

- discrete action on a finite path,
- discrete Euler–Lagrange residual,
- discrete energy shadow / Noether defect,
- compact energy shell predicate.

For trajectories `q : ℕ → (Fin n → ℝ)`, define a discrete Euler–Lagrange equation of the form
\[
D_2 L_d(h,q_{k-1},q_k) + D_1 L_d(h,q_k,q_{k+1}) = 0.
\]

Then define a **discrete energy shadow** `Esh h qk qk1` by differentiating `Ld` in the step-size direction or by a finite-difference proxy if Fréchet derivatives are too expensive to deploy globally in the first pass.

---

## Theorem 1: Discrete Noether cancellation identity

This is the structural theorem. Prove an exact telescoping identity before introducing asymptotics.

### Mathematical statement
For any discrete trajectory satisfying the discrete Euler–Lagrange equations, the variation of the discrete action under time-translation or a one-parameter symmetry reduces to a boundary term. In the autonomous case this yields a step-to-step balance law for the discrete energy shadow.

### Lean-oriented target
A realistic signature, allowing some flexibility in derivative formalization, is:

```lean
theorem discrete_noether_balance
  (S : DiscreteLagrangianSystem)
  (h : ℝ)
  (q : ℕ → (Fin S.n → ℝ))
  (N : ℕ)
  (hpos : 0 < h)
  (hEL : ∀ k < N,
    discreteEL S h (q k) (q (k+1)) (q (k+2)) = 0) :
  ∑ k in Finset.range N, noetherDefect S h (q k) (q (k+1))
    = boundaryCharge S h (q 0) (q 1) (q N) (q (N+1))
```

If exact differentiability machinery becomes cumbersome, formulate `noetherDefect` and `boundaryCharge` abstractly first and prove the telescoping theorem from their defining relation.

### Why it matters
This is the discrete analogue of the cancellation mechanism in continuous Noether theory. It is the theorem that all later quantitative estimates stand on.

---

## Theorem 2: Stepwise defect is cubic for symmetric quadrature

This is the first genuinely new asymptotic theorem.

### Mathematical statement
Let `L : ℝⁿ × ℝⁿ → ℝ` be a smooth autonomous Lagrangian, and let `Ld(h,q₀,q₁)` be a symmetric second-order consistent discrete Lagrangian. Then the one-step discrete Noether defect satisfies
\[
|E_d(q_k,q_{k+1};h) - E_d(q_{k-1},q_k;h)| \le C h^3
\]
uniformly for trajectories contained in a fixed compact energy shell.

### Lean 4 type signature sketch
You may need to package consistency and shell-boundedness as predicates.

```lean
theorem discrete_energy_step_defect_bound
  (S : DiscreteLagrangianSystem)
  (shell : Set (Fin S.n → ℝ))
  (C h : ℝ)
  (q : ℕ → (Fin S.n → ℝ))
  (hsmall : 0 < h)
  (hsym : SymmetricSecondOrder S)
  (htraj : ∀ k, q k ∈ shell)
  (hEL : ∀ k, discreteEL S h (q k) (q (k+1)) (q (k+2)) = 0)
  (hC : 0 ≤ C) :
  ∀ k, |discreteEnergy S h (q (k+1)) (q (k+2))
        - discreteEnergy S h (q k) (q (k+1))| ≤ C * h^3
```

### Why it is nontrivial
This is where symmetry of quadrature matters. Without symmetric quadrature, there is no reason for odd-order cancellation to survive. This theorem isolates the mechanism by which variational structure upgrades raw approximation into geometric fidelity.

---

## Theorem 3: Uniform `O(h²)` drift over a fixed time horizon

This is the flagship theorem.

### Mathematical statement
Fix `T > 0`. Let `N = ⌊T / h⌋`. Under the hypotheses above, there exists `C_T` depending only on the Lagrangian and the chosen compact energy shell such that
\[
\max_{0 \le k \le N}
|E_d(q_k,q_{k+1};h)-E_d(q_0,q_1;h)|
\le C_T h^2.
\]

The heuristic is simple and deep: `N ≈ T/h`, each step contributes `O(h^3)`, so the cumulative defect is `O(h^2)`.

### Lean 4 type signature sketch

```lean
theorem discrete_energy_drift_uniform_bound
  (S : DiscreteLagrangianSystem)
  (shell : Set (Fin S.n → ℝ))
  (T C h : ℝ)
  (q : ℕ → (Fin S.n → ℝ))
  (N : ℕ)
  (hT : 0 < T)
  (hsmall : 0 < h)
  (hN : N = Nat.floor (T / h))
  (hsym : SymmetricSecondOrder S)
  (htraj : ∀ k ≤ N+1, q k ∈ shell)
  (hEL : ∀ k < N, discreteEL S h (q k) (q (k+1)) (q (k+2)) = 0)
  (hstep : ∀ k < N,
    |discreteEnergy S h (q (k+1)) (q (k+2))
      - discreteEnergy S h (q k) (q (k+1))| ≤ C * h^3) :
  ∃ C_T ≥ 0,
    ∀ k ≤ N,
      |discreteEnergy S h (q k) (q (k+1))
        - discreteEnergy S h (q 0) (q 1)| ≤ C_T * h^2
```

A more explicit theorem with `C_T = C * T + C * h` or similar is even better.

### Why it is revolutionary
This would be among the first machine-checked geometric integration theorems that captures not merely local truncation error but a global, structure-preserving invariant shadow. It turns a folklore theorem from geometric numerical analysis into certified mathematics.

---

## Theorem 4: Exact discrete momentum conservation from discrete symmetry

You are required to include at least one cross-domain theorem. This one bridges mechanics, Lie symmetry, and numerical analysis.

### Mathematical statement
If the discrete Lagrangian is invariant under a linear action `A : G → GL(n,ℝ)` of a symmetry group, then the associated discrete momentum map is exactly preserved by the discrete Euler–Lagrange flow.

### Lean signature sketch

```lean
theorem discrete_momentum_conserved
  (S : DiscreteLagrangianSystem)
  (G : Type*) [Group G]
  (ρ : G → LinearMap ℝ (Fin S.n → ℝ) (Fin S.n → ℝ))
  (hρ : discreteInvariant S ρ)
  (h : ℝ) (q : ℕ → (Fin S.n → ℝ))
  (hEL : ∀ k, discreteEL S h (q k) (q (k+1)) (q (k+2)) = 0) :
  ∀ k, discreteMomentum S ρ h (q k) (q (k+1))
      = discreteMomentum S ρ h (q (k+1)) (q (k+2))
```

For the Kepler problem with rotationally invariant discrete Lagrangian, this predicts angular momentum conservation to numerical precision.

### Cross-domain connection
This theorem unites:
- geometric mechanics,
- representation theory of symmetry groups,
- certified numerical analysis.

---

## Theorem 5: Tropical/optimization shadow of the discrete action principle

You are explicitly asked for a cross-domain bridge. Here is the bold one.

### Mathematical statement
For a finite path space and a discretized action functional with additive composition law, the discrete least-action principle induces a min-plus dynamic programming recursion. In the small-step or finite-state regime, the action selector behaves as a tropical semigroup.

This need not be overclaimed as full tropicalization of mechanics; even a clean theorem that pathwise action minimization satisfies Bellman-style min-plus composition is already a serious bridge.

### Lean target
Define a path action and prove:

```lean
theorem discrete_action_minplus
  (S : DiscreteLagrangianSystem)
  (h : ℝ)
  (m n : ℕ)
  (q₀ q₂ : Fin S.n → ℝ) :
  valueFn S h (m + n) q₀ q₂
    = sInf {a | ∃ q₁, a = valueFn S h m q₀ q₁ + valueFn S h n q₁ q₂}
```

If `sInf` over `ℝ` is awkward, use finite state approximations first. The conceptual link to `tropical_vacuum_energy_eq_minimal_action` is then explicit: **minimal action is a tropical composition law**.

### Why this matters
This opens a new field direction: tropical variational mechanics. The variational integrator is not only symplectic; its action algebra is naturally min-plus.

---

## Proof Strategy Architecture

You must not pursue only one route. Develop at least 2–3 proof paths and choose the most viable.

### Strategy A: Telescoping first, asymptotics second
1. Define the discrete action on finite paths and derive the exact first-variation formula.
2. Under the discrete Euler–Lagrange equations, show all interior terms cancel, leaving only boundary terms.
3. Package the boundary term as the discrete Noether charge / energy shadow.
4. Use symmetry + second-order consistency to prove the charge increment is `O(h^3)`.
5. Sum over `N ≈ T/h` steps to obtain `O(h^2)` drift.

**Why promising:** This mirrors the continuous Noether proof and should align best with `energy_conserved` and any existing variational formalization.

### Strategy B: Backward-error-lite via modified discrete energy
1. Define a corrected energy `Ē_h = E_d + h^2 R_h`.
2. Show exact preservation of `Ē_h` up to higher-order residuals.
3. Deduce that `E_d` itself has bounded drift by comparing with `Ē_h`.

**Why promising:** Conceptually strongest, closest to geometric integration literature.  
**Why risky:** Requires more sophisticated formal asymptotics and smoothness estimates.

### Strategy C: Finite-difference defect calculus
1. Avoid full Fréchet derivative infrastructure initially.
2. Define a discrete defect operator by explicit finite differences in `h` and path variables.
3. Prove algebraic cancellation identities directly using `calc`, induction on path length, and shell-boundedness hypotheses.
4. Only later identify this defect with the derivative-based discrete energy.

**Why promising:** Most Lean-friendly for a first breakthrough.  
**Why risky:** Less canonical mathematically unless carefully packaged.

**Recommendation:** Start with **Strategy A**, keep **Strategy C** as a fallback implementation path, and reserve **Strategy B** for FUTURE_DIRECTIONS unless the derivative machinery becomes unexpectedly smooth.

---

## How to Build on Catalog Theorems

### 1. `energy_conserved` from `Physics/NoetherTheorems.lean`
Do not merely cite it. Use it as the continuous archetype:
- isolate the exact cancellation pattern in the proof,
- mimic the proof combinatorics in the discrete action setting,
- compare the continuous conserved quantity with your discrete shadow quantity,
- state explicitly that the discrete theorem reduces to the continuous one in the formal `h → 0` limit.

### 2. `tropical_vacuum_energy_eq_minimal_action` from `FINAL/Physics/TropicalVacuumEnergy.lean`
Use it as a conceptual bridge:
- in the tropical theorem, energy selection is encoded by an extremal/minimal principle;
- in your setting, discrete action minimization over finite paths induces a min-plus composition;
- formulate a theorem showing that discrete variational propagation is compatible with tropical optimization on path spaces.

This is not decorative. It is the seed of a new language connecting numerical mechanics and tropical geometry.

---

## Required Deep Proof Tactics

Your file must include at least 3 nontrivial theorem proofs using substantial tactics or structured proof steps such as:
- induction on `N` for telescoping drift bounds,
- `rcases` for extracting witnesses from path decompositions / shell compactness assumptions,
- `by_contra` for uniqueness or nonexistence of zero-defect violations,
- `field_simp` when manipulating discrete quotient expressions in step-size formulas,
- multi-step `calc` chains for action decomposition and drift summation.

No trivial theorem-padding. Every theorem should advance the main architecture.

---

## Suggested Lean File Scope

Create a focused file, e.g.

`Physics/DiscreteNoetherShadow.lean`

with sections such as:
1. `DiscreteLagrangianSystem`
2. `DiscreteAction`
3. `DiscreteEulerLagrange`
4. `DiscreteNoether`
5. `EnergyShadowBounds`
6. `SymmetryMomentum`
7. `TropicalActionBridge`

---

## Computational / Algorithmic Deliverable

You must produce a **verified algorithm** for computing the discrete energy drift certificate:

- implement the discrete variational integrator for the Kepler Lagrangian,
- compute the discrete energy shadow along trajectories,
- return a certified upper bound candidate for `max_k |ΔE_k| / h^2`,
- numerically verify exact/near-exact angular momentum conservation for rotationally invariant schemes.

The algorithm should not be an afterthought: the theorem and experiment must talk to each other.

A possible Python workflow in `demo.py`:
1. sample 100 random initial conditions on a fixed negative-energy shell,
2. integrate to time `T = 100` for `h ∈ {1e-1, 1e-2, 1e-3, 1e-4}`,
3. compute max energy drift,
4. perform log-log regression to estimate slope near `2`,
5. plot angular momentum drift separately,
6. optionally compare symmetric vs non-symmetric quadrature to show the theorem’s hypothesis is real.

---

## Testable Conjectures for FUTURE_DIRECTIONS.md

You must include 3–5 falsifiable hypotheses. At least one should be computationally testable in the current codebase. Strong candidates:

1. **Long-time metastability conjecture**  
   For analytic autonomous Lagrangians and symmetric discrete Lagrangians, the discrete energy drift over times `T = exp(c/h)` remains `O(h^2)` on compact non-resonant shells.  
   **Test:** numerical experiments with increasing `T` and fitted drift envelope.

2. **Symmetry rigidity conjecture**  
   Exact discrete momentum conservation characterizes discrete group invariance of `Ld` among a broad class of local two-point schemes.  
   **Test:** perturb a rotationally invariant Kepler discretization by an anisotropic term and observe momentum drift.

3. **Tropical action selector conjecture**  
   On finite-state discretizations of configuration space, the discrete value function converges after rescaling to a tropical eigenfunction of a min-plus transfer operator.  
   **Test:** compute repeated Bellman updates and detect projective convergence.

4. **Shadow-energy universality conjecture**  
   The `O(h^2)` drift constant depends primarily on curvature of the energy shell and not on dimension `n` for separable Lagrangians.  
   **Test:** compare harmonic oscillator, Kepler, and weakly coupled many-body systems.

5. **Discrete-to-continuous Noether convergence conjecture**  
   As `h → 0`, the normalized discrete Noether charge converges uniformly on compact shells to the continuous Noether invariant from `energy_conserved`.  
   **Test:** compare discrete and continuous charges on exact or high-precision reference trajectories.

---

## Cross-Domain Connections You Should Make Explicit

- **Geometric mechanics ↔ numerical analysis:** variational integrators as theorem-prover-certified structure-preserving dynamics.
- **Mechanics ↔ tropical geometry:** least action over discretized paths as min-plus composition.
- **Symmetry theory ↔ computation:** group invariance becomes machine-checkable momentum preservation.
- **Hamiltonian physics ↔ formal verification:** certified near-conservation laws for long-time integration.
- **Dynamical systems ↔ optimization:** discrete action minimization is Bellman recursion in disguise.

---

## Application Keywords

variational integrators; geometric numerical integration; discrete Noether theorem; shadow Hamiltonians; backward error analysis; symplectic methods; Kepler problem; angular momentum conservation; certified scientific computing; formal mechanics; tropical optimization; min-plus algebra; Bellman recursion; theorem-prover-verified physics; structure-preserving algorithms

---

## Nonnegotiable Deliverables

You must produce **all** of the following:

1. **Lean formalization** with at least 3 substantial theorem proofs and at least one novel definition.
2. **`FUTURE_DIRECTIONS.md`** containing 3–5 falsifiable scientific hypotheses, each with a clear computational or mathematical test.
3. **`RESEARCH_PAPER.md`** as a standalone scientific paper: statement of results, context, proof ideas, significance, and next questions.
4. **`ARTICLE.md`** in Scientific American style: accessible, vivid, and faithful to the mathematics.
5. **A verified algorithm or computational method** implementing and testing the discrete Noether shadow.
6. **`demo.py`** demonstrating the result interactively on the Kepler problem and plotting energy/momentum drift.

Do not settle for a weak “toy” formalization. The objective is to found a certified theory of **discrete Noether shadows** that can become the backbone of machine-checked geometric integration.

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
