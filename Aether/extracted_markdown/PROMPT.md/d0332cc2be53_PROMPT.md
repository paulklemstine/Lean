
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: The file `Core.lean` distills the (empirical, ML-flavored) conjecture
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Universal Scaling of Minimal PDE-Solver Size at a Spectral Phase Transition

## Synthesis

The file `Core.lean` distills the (empirical, ML-flavored) conjecture
*"minimal neural-operator size diverges as a universal power law near an
operator-spectrum phase transition"* into a fully formal, machine-checked core.
The central object is the **minimal iteration / depth count**
`Nmin ρ ε = least n with ρ^n ≤ ε`, the scalar shadow of how many Neumann /
power-iteration terms (equivalently, how much polynomial depth) a solver needs to
invert a discretized solution operator with contraction factor `ρ = 1 - g`,
where `g` is the spectral gap.

The headline theorem `Nmin_sandwich` proves a **two-sided power law**

```
(1 - ε)/g  ≤  Nmin (1-g) ε  ≤  log(1/ε)/g + 1 ,
```

so the size diverges as `g⁻¹` with a *class-universal exponent* and an
*ε-dependent prefactor band* `[1-ε, log(1/ε)]`. The whole "critical exponent"
content collapses onto two elementary inequalities — Bernoulli
`1 - n·g ≤ (1-g)^n` (which *forces* divergence) and `1 - g ≤ e^{-g}` (which
*controls* it). This separation is the engine behind every corollary:

* `Nmin_sandwich_accelerated` — feeding the *square-root* contraction `1 - √g`
  (Chebyshev / conjugate-gradient acceleration) halves the exponent to `1/2`.
* `power_law_control` / `power_law_control_accelerated` — composing with a gap
  `g = D^α` that closes as a power of the control parameter `D = |λ - λc|` yields
  divergence `D^{-α}` (unaccelerated) versus `D^{-α/2}` (accelerated), i.e.
  critical exponents `ν = α` versus `ν = α/2`.
* `accelerated_exponent_lt` — the two universality classes are genuinely
  distinguished: `α/2 < α`.
* `power_law_discretization_independent` — replacing `g` by `c·D^α` for any
  microscopic discretization constant `c ∈ (0,1]` leaves the exponent equal to
  `α`; only the prefactor moves. This is the renormalization-style statement that
  the exponent is independent of microscopic details.

A computable rational analogue `NminQ` makes the divergence concrete: as the gap
shrinks tenfold (`ρ = 0.9 → 0.99`) the count grows ≈ tenfold (`44 → 459`),
numerically confirming the `g⁻¹` law.

## Results Summary

| Theorem | Statement | Exponent ν |
|---|---|---|
| `Nmin_sandwich` | `(1-ε)/g ≤ Nmin (1-g) ε ≤ log(1/ε)/g + 1` | 1 (in `g`) |
| `Nmin_sandwich_accelerated` | same with `g ↦ √g` | 1/2 (in `g`) |
| `power_law_control` | `Nmin ~ D^{-α}` for `g = D^α` | `α` |
| `power_law_control_accelerated` | `Nmin ~ D^{-α/2}` | `α/2` |
| `accelerated_exponent_lt` | `α/2 < α` | — |
| `power_law_discretization_independent` | `g = c·D^α ⇒` exponent `= α` | `α` (∀ `c`) |

All proofs are `sorry`-free and use only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Research Directions

### 1. Logarithmic correction at the exact critical point (a sharper ceiling)

The current upper bound `log(1/ε)/g + 1` and lower bound `(1-ε)/g` pin down the
exponent but leave a constant-factor gap of `log(1/ε)/(1-ε)` in the prefactor.
Conjecture: there is a *sharp* asymptotic `Nmin (1-g) ε = log(1/ε)/g · (1 + o(1))`
as `g → 0⁺` with `ε` fixed, and the next-order term is a pure logarithmic
correction independent of `g`. **The key insight is** that
`-1/log(1-g) = 1/g · (1 - g/2 + o(g))`, so the gap between the two sandwich
bounds is itself governed by a convergent power series in `g`, meaning the
prefactor band must collapse to a single value in the limit. **Why now?** We
already have both one-sided bounds formalized; tightening to a genuine
`Filter.Tendsto`/`IsEquivalent` statement only requires the `Real.log (1 - g)`
expansion, which is in Mathlib, and would upgrade the qualitative power law to a
quantitative scaling collapse — falsifiable by exhibiting any `ε` for which the
ratio `Nmin·g / log(1/ε)` fails to converge to 1.

### 2. The square-root acceleration barrier is optimal (a lower bound across all schemes)

We proved that acceleration `g ↦ √g` halves the exponent, but not that `1/2` is
the *best possible* exponent for any polynomial scheme. Conjecture: among all
contraction families `ρ(g)` realizable by degree-`d` polynomial solvers of a
self-adjoint operator with gap `g`, no scheme achieves exponent below `1/2`; i.e.
`Nmin ≥ c·g^{-1/2}` uniformly. **The key insight is** that the Chebyshev
polynomials are extremal for the min-max problem `min_p max_{x∈[g,1]} |1 - x·p(x)|`,
so the `g^{-1/2}` rate is not an artifact of our particular `1 - √g` model but a
hard floor coming from approximation theory. **Why now?** Mathlib's Chebyshev
polynomial library plus our `Nmin` skeleton make the extremality argument
self-contained; the conjecture is falsifiable by constructing a polynomial family
with provably smaller asymptotic degree, which would overturn 70 years of
iterative-solver lower-bound folklore.

### 3. Exponent additivity under composed (tensor) phase transitions

Real multiphysics solvers face *several* gaps closing at once (e.g. an elliptic
gap and a parabolic gap). Model this by the product contraction
`ρ = (1 - g₁)(1 - g₂)` with independent gaps `g₁ = D^{α₁}`, `g₂ = D^{α₂}`.
Conjecture: the composed exponent is `ν = max(α₁, α₂)`, *not* `α₁ + α₂` — the
slowest-closing gap dominates, exactly like a rate-limiting step. **The key
insight is** that `1 - (1-g₁)(1-g₂) = g₁ + g₂ - g₁g₂ ≈ g₁ + g₂`, whose power-law
exponent near `D → 0` is set by the larger of `α₁, α₂`, so divergence is governed
by a single critical mode even in a coupled system. **Why now?** Our
`Nmin_sandwich` already accepts an arbitrary effective gap, so the result reduces
to an elementary `D^{α₁} + D^{α₂} ≍ D^{min(α₁,α₂)}` estimate; it is falsifiable by
any coupled model whose measured exponent exceeds `max(α₁, α₂)`.

### 4. Width–depth tradeoff: a conserved product near criticality

We modeled "solver size" as a single depth-like count. In practice architectures
trade width `W` against depth `L`. Conjecture: near `λc` there is a conserved
quantity `W^a · L^b ~ |λ - λc|^{-ν}` so that for fixed target error the feasible
`(W, L)` pairs lie on a hyperbola whose position diverges with the same exponent
`ν` derived here, independent of how the budget is split. **The key insight is**
that a degree-`n` polynomial of the operator can be realized either by `n`
sequential applications (depth) or by a width-`n` parallel Krylov basis, so the
*product* — not either factor alone — is what the spectral gap forces to diverge.
**Why now?** The `Nmin` count is exactly the polynomial degree, the invariant
both realizations share; formalizing the two realizations as bounds on `W·L`
turns the heuristic "expressivity = degree" into a theorem, falsifiable by an
architecture that beats the hyperbola at fixed error.

### 5. Non-self-adjoint exceptional points give a strictly larger exponent

For *defective* (Jordan-block / exceptional-point) operators the resolvent norm
blows up faster than `1/g` because of nilpotent coupling between coalescing modes.
Conjecture: for a size-`m` Jordan block whose eigenvalue approaches the spectrum
edge as `D^α`, the minimal solver size diverges as `D^{-α·m}` — the exponent is
multiplied by the Jordan size, a strictly different universality class from the
diagonalizable (`m = 1`) case. **The key insight is** that
`‖(A - z)^{-1}‖ ∼ g^{-m}` for an `m`-fold defective eigenvalue, so the *effective*
contraction seen by any polynomial solver is `1 - g^{m}` rather than `1 - g`,
feeding straight into our sandwich with exponent `α·m`. **Why now?** The model
needs only a scalar effective-gap input, which `Core.lean` already isolates, so
the conjecture is testable by instantiating the sandwich with `g^m` and is
falsifiable by any defective family whose measured exponent stays at `α`,
independent of Jordan size.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/MarkovBases/Geodesic.lean
import Mathlib
import Algebra.MarkovBases.NoThreeWay

/-!
# Algebraic Statistics: Geodesics in the Markov Graph of the No-Three-Way Model

Building directly on `Algebra.MarkovBases.NoThreeWay`, this file upgrades the *qualitative*
Fundamental Theorem of Markov Bases (`noThreeWay_fiber_connected` — "the single move `M3`
connects every fiber") to a *quantitative* one: it computes the **exact graph distance**
between two tables in the Markov graph of the `2 × 2 × 2` no-three-way interaction model.

The Markov graph of a fiber has the non-negative tables as vertices and a `± M3` move as an
edge.  We define a length-counted walk `Walk u v n` (a path of `n` legal `± M3` steps) and
prove:

* every `± M3` step changes the corner cell `u 0 0 0` by exactly one
  (`step_corner_natAbs_le`);
* hence any walk of length `n` satisfies `|v₀₀₀ − u₀₀₀| ≤ n` — a **geodesic lower bound**
  (`walk_corner_bound`);
* conversely there is a walk of length exactly `|t|` realising `u ⇝ u + t • M3`
  (`walk_add_smul`), staying non-negative throughout (discrete convexity);
* therefore the graph distance between any two equal-margin non-negative tables is **exactly**
  `|v₀₀₀ − u₀₀₀|` (`noThreeWay_geodesic`): the natural corner coordinate is an isometry from
  the fiber onto an integer interval.

## Catalog synthesis

This extends `Algebra.MarkovBases.NoThreeWay` (rank-one move lattice + connectivity) and is
the `2×2×2` analogue of the interval picture in `Algebra.MarkovBases.TwoWay`
(`twoWay_fiber_card_interval`).  Where those files show *that* one move suffices, this file
quantifies the *cost*: the Markov graph of every fiber is a path graph, and the corner cell
is a graph isometry onto `ℤ`.  The lower bound is a potential-function argument (a discrete
1-Lipschitz invariant), a reusable bridge between lattice walks (catalog: combinatorial step
relations) and metric geometry on graphs.
-/

namespace MarkovBases.NoThreeWay

/-- A length-counted walk in the Markov graph: a path of `n` legal `± M3` steps from `u`
to `v`, every intermediate table non-negative (the `Step` relation enforces this). -/
inductive Walk : Table3 → Table3 → ℕ → Prop
  | refl (u : Table3) : Walk u u 0
  | cons {u v w : Table3} {n : ℕ} : Step u v → Walk v w n → Walk u w (n + 1)

-- !-- step_corner_natAbs_le: a ±M3 move changes the corner cell by exactly M3 0 0 0 = ±1,
-- so a single Markov step moves the corner coordinate by one. -- !--
/-- A single legal `± M3` step changes the corner cell `u 0 0 0` by exactly one:
`M3 0 0 0 = 1`, so `v 0 0 0 - u 0 0 0 = ±1`. -/
theorem step_corner_natAbs_le {u v : Table3} (h : Step u v) :
    (v 0 0 0 - u 0 0 0).natAbs ≤ 1 := by
  rcases h with ⟨hu, hv, huv⟩
  rcases huv with (rfl | rfl) <;> norm_num [M3]

-- !-- walk_corner_bound: induct on the walk; the corner coordinate is 1-Lipschitz along edges,
-- so its total change is at most the number of steps — the geodesic lower bound. -- !--
/-- **Geodesic lower bound.** Any walk of `n` legal `± M3` steps from `u` to `v` satisfies
`|v 0 0 0 - u 0 0 0| ≤ n`: the corner cell is a `1`-Lipschitz potential, so no path can be
shorter than the corner displacement. -/
theorem walk_corner_bound {u v : Table3} {n : ℕ} (h : Walk u v n) :
    (v 0 0 0 - u 0 0 0).natAbs ≤ n := by
  induction h with
  | refl u => norm_num
  | cons s _ ih =>
      have := step_corner_natAbs_le s
      omega

-- !-- walk_add_smul: induct on |t|; one unit step (±M3) toward the target stays non-negative
-- by discrete convexity, giving a walk of length exactly |t|. -- !--
/-- **Existence of a length-`|t|` geodesic.** If both `u` and `u + t • M3` are non-negative
then there is a walk of length exactly `t.natAbs` between them, staying non-negative at every
step.  (Refines `connected_add_smul`, which forgets the length.) -/
theorem walk_add_smul (t : ℤ) (u : Table3)
    (hu : Nonneg u) (hv : Nonneg (u + t • M3)) :
    Walk u (u + t • M3) t.natAbs := by
  induction' n : t.natAbs with n ih generalizing u t
  · rw [Int.natAbs_eq_zero.mp n]; simp +decide [Walk.refl]
  · rcases Int.natAbs_eq_iff.mp n with (rfl | rfl)
    · -- positive case: first add M3, then recurse with exponent n
      have h_ind : Walk (u + M3) (u + (↑(Nat.succ ‹_›) : ℤ) • M3) ‹_› := by
        convert ih (↑‹ℕ› : ℤ) (u + M3) _ _ _ using 1 <;> norm_num [add_smul_M3_apply]
        · ext i j k; simp; ring
        · intro i j k; specialize hv i j k; specialize hu i j k
          simp_all +decide
          cases M3_apply_eq i j k <;> nlinarith
        · convert hv using 1; ext i j k; simp +decide; ring
      refine Walk.cons ?_ h_ind
      constructor <;> norm_num [hu, hv]
      intro i j k; specialize hv i j k; simp_all +decide [M3]
      split_ifs at * <;> linarith [hu i j k]
    · -- negative case: first subtract M3, then recurse with exponent n
      refine Walk.cons (v := u - M3) ?_ ?_
      · constructor <;> norm_num [Step]
        · assumption
        · intro i j k; have := hu i j k; have := hv i j k
          simp_all +decide [M3]
          split_ifs at * <;> linarith
      · convert ih (-↑‹ℕ›) (u - M3) _ _ _ using 1 <;> norm_num [sub_eq_add_neg]
        · ext i j k; norm_num; ring
        · intro i j k; have := hu i j k; have := hv i j k
          simp_all +decide [M3]
          split_ifs at * <;> linarith
        · convert hv using 1; ext i j k; norm_num; ring

-- !-- noThreeWay_geodesic: the kernel theorem writes v = u + (v000-u000)•M3; walk_add_smul gives
-- a walk of that length and walk_corner_bound shows none is shorter — distance = |v000-u000|. -- !--
/-- **Markov-graph geodesic distance.** For any two non-negative tables `u`, `v` with the same
two-way margins, the corner displacement `|v 0 0 0 - u 0 0 0|` is realised by some walk and is
a lower bound for every walk.  Hence it is *exactly* the graph distance between `u` and `v` in
the Markov graph of the fiber: the corner cell is an isometry onto an integer interval. -/
theorem noThreeWay_geodesic (u v : Table3)
    (hu : Nonneg u) (hv : Nonneg v) (h : SameMargins u v) :
    Walk u v (v 0 0 0 - u 0 0 0).natAbs ∧
      ∀ n, Walk u v n → (v 0 0 0 - u 0 0 0).natAbs ≤ n := by
  refine ⟨?_, fun n hn => walk_corner_bound hn⟩
  have hk := noThreeWay_kernel u v h
  convert walk_add_smul (v 0 0 0 - u 0 0 0) u hu _
  exact hk ▸ hv

end MarkovBases.NoThreeWay


-- NEW_FILE: Catalog/Bridges/ArithmeticHeightUltrametric.lean
/-
  # Arithmetic-Height-Induced Ultrametrics
  ## A nonarchimedean bridge from p-adic arithmetic height/depth data to
  ## ultrametric distances and to the catalog's tropical–ultrametric object layer.

  Bridge: Number theory (p-adic valuation / arithmetic height) ↔ Metric geometry
  (ultrametric / strong triangle inequality) ↔ the categorical tropical–ultrametric
  interface (`CategoricalTropicalUltrametric.UltraNormObj`).

  **Core principle.** A valuation-style *arithmetic depth* on rational differences
  induces a genuine ultrametric distance `d(x,y) = padicNorm p (x - y)`, and the
  *integer* divisibility-depth packages as a multiplicative ℕ-valued seminorm — a
  bona fide `TropicalValuationCarrier`, hence (via `valuationReconstruct`) an
  `UltraNormObj`.  A representation/rigidity result explains *why* the carrier must
  live on the integers rather than the field: on a field every multiplicative
  ℕ-valued norm is trivial on nonzero elements.

  -- !-- Lab Notebook -- !--
  Hypothesis: arithmetic height/depth data on ℚ yields a strong (max-type) triangle
    inequality, and the discrete divisibility depth on ℤ is a multiplicative
    ultrametric ℕ-seminorm that instantiates the catalog `UltraNormObj` interface.
  Result: proved identity / symmetry / strong-triangle for `hDist p` on ℚ, built
    `arithDepthCarrier p : TropicalValuationCarrier`, reconstructed it into an
    ultrametric object via the catalog's `valuationReconstruct`, and proved the
    field-rigidity obstruction forcing the carrier to be ℤ rather than ℚ.
  Insight: the catalog `UltraNormObj` norm axioms (
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Universal Scaling of Minimal PDE-Solver Size at a Spectral Phase Transition

## Synthesis

`Core.lean` distills the empirical, ML-flavored conjecture *"minimal
neural-operator size diverges as a universal power law near an operator-spectrum
phase transition"* into a fully formal, machine-checked core. The central object
is the **minimal iteration / depth count** `Nmin ρ ε = least n with ρ^n ≤ ε`, the
scalar shadow of how many Neumann / power-iteration terms (equivalently, how much
polynomial depth) a solver needs to invert a discretized solution operator with
contraction factor `ρ = 1 - g`, where `g` is the spectral gap.

The headline theorem `Nmin_sandwich` proves a **two-sided power law**

```
(1 - ε)/g  ≤  Nmin (1-g) ε  ≤  log(1/ε)/g + 1 ,
```

so the size diverges as `g⁻¹` with a class-universal exponent and an
`ε`-dependent prefactor band `[1-ε, log(1/ε)]`. The entire "critical exponent"
content collapses onto two elementary inequalities — Bernoulli
`1 - n·g ≤ (1-g)^n` (which *forces* divergence) and `1 - g ≤ e^{-g}` (which
*controls* it). This separation is the engine behind every corollary:

* `Nmin_sandwich_accelerated` — feeding the square-root contraction `1 - √g`
  (Chebyshev / conjugate-gradient acceleration) halves the exponent to `1/2`.
* `power_law_control` / `power_law_control_accelerated` — composing with a gap
  `g = D^α` closing as a power of the control parameter `D = |λ - λc|` yields
  divergence `D^{-α}` (unaccelerated) versus `D^{-α/2}` (accelerated).
* `accelerated_exponent_lt` — the two universality classes are genuinely
  distinguished: `α/2 < α`.
* `power_law_discretization_independent` — replacing `g` by `c·D^α` for any
  microscopic discretization constant `c ∈ (0,1]` leaves the exponent equal to
  `α`; only the prefactor moves (renormalization-style universality).

The computable rational analogue `NminQ` makes divergence concrete: as the gap
shrinks tenfold (`ρ = 0.9 → 0.99`) the count grows tenfold (`44 → 459`, both
`#eval`-confirmed), numerically validating the `g⁻¹` law.

## Results Summary

| Theorem | Statement | Exponent ν |
|---|---|---|
| `Nmin_sandwich` | `(1-ε)/g ≤ Nmin (1-g) ε ≤ log(1/ε)/g + 1` | 1 (in `g`) |
| `Nmin_sandwich_accelerated` | same with `g ↦ √g` | 1/2 (in `g`) |
| `power_law_control` | `Nmin ~ D^{-α}` for `g = D^α` | `α` |
| `power_law_control_accelerated` | `Nmin ~ D^{-α/2}` | `α/2` |
| `accelerated_exponent_lt` | `α/2 < α` | — |
| `power_law_discretization_independent` | `g = c·D^α ⇒` exponent `= α` | `α` (∀ `c`) |

All proofs are `sorry`-free and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Logarithmic correction at the exact critical point (a sharper ceiling)

The current bounds pin the exponent but leave a constant-factor gap of
`log(1/ε)/(1-ε)` in the prefactor. **Conjecture:** there is a sharp asymptotic
`Nmin (1-g) ε = log(1/ε)/g · (1 + o(1))` as `g → 0⁺` with `ε` fixed, the
next-order term a pur
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
