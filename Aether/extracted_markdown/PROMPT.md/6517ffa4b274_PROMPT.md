## Assignment: Percolation Threshold

Mode: **formalize + prove + discover**

This direction is only worth pursuing if we avoid the trap of pretending to solve the open problem of the exact square **site** percolation threshold in full generality. The breakthrough is to build a Lean-native percolation architecture that cleanly separates:
1. **exactly solvable thresholds** (triangular/honeycomb bond models via duality and self-duality),
2. **finite-box crossing and monotonicity technology**,
3. **a formally precise reduction interface** connecting threshold phenomena to planar duality, graph embeddings, and eventually conformal-invariance-style scaling observables.

The real theorem targets should therefore be exact where mathematics permits exactness, and structural where the square-site problem remains open. If you do this right, you will not merely formalize folklore; you will create the first serious Mathlib-ready percolation substrate on which sharp-threshold theory, RSW-type inequalities, and discrete complex analysis can be layered.

## Core Research Mandate

You should **not** claim an analytic closed form for the square site percolation threshold unless you can prove it from first principles in Lean. Instead, pursue the following three-tier program:

1. **Formalize Bernoulli bond and site percolation on finite and locally finite graphs.**
2. **Prove exact threshold statements in planar self-dual settings where exactness is classical and robust.**
3. **Construct a rigorous interface between finite crossing probabilities and threshold candidates for square site percolation, isolating the exact obstruction.**

This is scientifically valuable because it turns a vague grand challenge into a reusable theorem engine.

---

## Precise Theorem Targets

### Target A: Finite-graph monotonicity of percolation connectivity
Define Bernoulli site and bond percolation on a finite graph and prove monotonicity of connection probabilities in the parameter `p`.

A concrete Lean-oriented statement:

```lean
def siteConfig (V : Type _) := V → Bool

def siteOpenProb
  {V : Type _} [Fintype V] (p : ℝ) (η : siteConfig V) : ℝ := sorry

def connectedInSitePercolation
  {V : Type _} (G : SimpleGraph V) (η : siteConfig V) (u v : V) : Prop := sorry

def siteConnProb
  {V : Type _} [Fintype V] (G : SimpleGraph V) (u v : V) (p : ℝ) : ℝ := sorry

theorem siteConnProb_monotone
  {V : Type _} [Fintype V] (G : SimpleGraph V) (u v : V) :
  Monotone (siteConnProb G u v)
```

And analogously for bond percolation:

```lean
def bondConfig {V : Type _} (G : SimpleGraph V) := Sym2 V → Bool

def connectedInBondPercolation
  {V : Type _} (G : SimpleGraph V) (ω : bondConfig G) (u v : V) : Prop := sorry

def bondConnProb
  {V : Type _} [Fintype V] (G : SimpleGraph V) (u v : V) (p : ℝ) : ℝ := sorry

theorem bondConnProb_monotone
  {V : Type _} [Fintype V] (G : SimpleGraph V) (u v : V) :
  Monotone (bondConnProb G u v)
```

This is foundational: it gives the order-theoretic skeleton for threshold definitions.

---

### Target B: Threshold existence on finite approximants
For an increasing family of finite boxes in `ℤ²`, define crossing events and show the associated crossing probability is monotone in `p`, allowing a formal definition of finite-volume critical windows.

Possible theorem:

```lean
def boxCrossingEvent (n : ℕ) (η : (Fin n × Fin n) → Bool) : Prop := sorry

def boxCrossingProb (n : ℕ) (p : ℝ) : ℝ := sorry

theorem boxCrossingProb_monotone (n : ℕ) :
  Monotone (boxCrossingProb n)

theorem exists_finite_volume_threshold (n : ℕ) :
  ∃ p : ℝ, IsGreatest {q : ℝ | boxCrossingProb n q ≤ (1 / 2 : ℝ)} p
```

This does **not** solve infinite-volume percolation, but it creates a machine-checkable notion of “critical proxy” suitable for experiments and asymptotic conjectures.

---

### Target C: Exact self-dual threshold for bond percolation on the square lattice finite torus / planar approximants
The mathematically honest exact theorem to aim for is bond, not site, on a self-dual planar setting. The classical critical value is `1/2`, and finite planar duality can be formalized without immediately requiring full infinite-lattice machinery.

A Lean-facing theorem target:

```lean
theorem square_bond_self_dual_threshold_finite
  (n : ℕ) :
  bondCrossingProbSquare n (1 / 2 : ℝ) =
    dualBondCrossingProbSquare n (1 / 2 : ℝ)
```

and, if definitions are set up correctly,

```lean
theorem square_bond_duality_fixed_point :
  squareDualityMap (1 / 2 : ℝ) = (1 / 2 : ℝ)
```

This is not yet the full statement `p_c = 1/2`, but it is the exact algebraic heart of the threshold computation and is fully formalizable.

---

### Target D: Exact critical equation for triangular/honeycomb bond percolation
This is the genuine exact-threshold theorem that can be formalized as a polynomial root statement. For homogeneous bond percolation on the triangular lattice, the critical parameter `p` is the unique root in `(0,1)` of

\[
p^3 - 3p + 1 = 0,
\]

equivalently
\[
1 - p - p^2 + p^3 = 0.
\]

A precise theorem target:

```lean
def triangularCriticalPolynomial (p : ℝ) : ℝ := p^3 - 3*p + 1

theorem exists_unique_triangular_bond_threshold :
  ∃! p : ℝ, p ∈ Set.Ioo (0 : ℝ) 1 ∧ triangularCriticalPolynomial p = 0
```

If you want the explicit trigonometric closed form:

```lean
theorem triangular_bond_threshold_closed_form :
  let p : ℝ := 2 * Real.sin (Real.pi / 18)
  p ∈ Set.Ioo (0 : ℝ) 1 ∧ triangularCriticalPolynomial p = 0
```

A dual honeycomb statement should then follow via `p ↦ 1 - p` duality:

```lean
theorem honeycomb_bond_threshold_closed_form :
  let p : ℝ := 1 - 2 * Real.sin (Real.pi / 18)
  p ∈ Set.Ioo (0 : ℝ) 1 ∧ triangularCriticalPolynomial (1 - p) = 0
```

This would be a real formal milestone: exact threshold theory in Lean, not numerics.

---

### Target E: Site–bond comparison inequality on square finite boxes
Because exact square-site threshold is open, the right theorem is a comparison theorem. For example, define a star-triangle-style or coupling-based map from site configurations to bond configurations and prove inequalities between crossing probabilities.

A viable theorem form:

```lean
theorem square_site_to_bond_crossing_lower_bound
  (n : ℕ) :
  ∃ f : ℝ → ℝ, Monotone f ∧
    ∀ p ∈ Set.Icc (0 : ℝ) 1,
      boxCrossingProbSite n p ≤ boxCrossingProbBond n (f p)
```

Even a coarse universal comparison is valuable. It creates a formal reduction framework and makes the square-site problem mathematically operational in Lean.

---

## Why this would be a breakthrough

If you succeed, you will have created the first serious **formal percolation threshold platform** in Lean 4:
- exact algebraic threshold theorems for solvable planar models,
- monotonicity and threshold extraction on finite boxes,
- a duality interface connecting primal and dual crossing events,
- a precise formal obstruction to the square site threshold problem.

That changes the game. It opens:
- formal sharp-threshold theory,
- Russo-type derivative formulas,
- RSW inequalities,
- Smirnov-style conformal observables,
- computationally certified percolation experiments with theorem-backed semantics.

This is not “formalizing a textbook chapter.” This is laying rails for rigorous probability at the phase-transition frontier.

---

## Recommended Proof Architecture

### Strategy A: Finite combinatorial probability first, then asymptotics
This is the most promising route.

1. **Finite product measure formalization**  
   Encode site and bond configurations on finite graphs as functions to `Bool`; define Bernoulli product weights explicitly as finite products over vertices/edges.

2. **Monotonicity via event inclusion and termwise comparison**  
   For increasing events, prove probability monotonicity by summing weights over configurations or by constructing a monotone coupling from `p ≤ q`.

3. **Specialize to planar lattices and crossing events**  
   Work first on finite rectangular boxes and triangulations. Exact threshold algebra appears in finite duality identities before any infinite-volume limit is attempted.

Why this is strongest: it stays entirely within finite combinatorics and real algebra, where Lean is currently strongest.

---

### Strategy B: Coupling-theoretic formalization
A more probabilistic route.

1. Define a common source of randomness `U : V → [0,1]` and derive percolation at parameter `p` by thresholding `U`.
2. Show that if `p ≤ q`, then every open set at level `p` is open at level `q`.
3. Push this coupling through connectivity and crossing predicates to get monotonicity.

Why it matters: this is conceptually elegant and prepares for stochastic domination, FKG-type statements, and future sharp-threshold work.  
Risk: formalizing probability spaces may be heavier than direct finite sums.

---

### Strategy C: Algebraic self-duality / star-triangle route for exact thresholds
Best for the triangular/honeycomb exact theorem.

1. Formalize the local transformation equating connection probabilities under a triangle–star move.
2. Derive the polynomial criticality equation `1 - p - p^2 + p^3 = 0`.
3. Prove uniqueness of the root in `(0,1)` using calculus or monotonicity of the polynomial derivative on the relevant interval.

Why this is transformative: it gives an exact threshold theorem with a symbolic closed form and bridges combinatorics, algebra, and analysis.

---

## Most Promising Sequence

1. `siteConnProb_monotone` / `bondConnProb_monotone`
2. finite box crossing definitions and monotonicity
3. planar dual crossing complement theorem on rectangular boxes
4. triangular/honeycomb critical polynomial and unique-root theorem
5. square bond self-dual fixed-point theorem
6. site–bond comparison inequalities
7. only then: formulate square-site threshold conjectures precisely

This sequence minimizes sorrys while maximizing mathematical depth.

---

## Cross-Domain Connections You Must Exploit

### 1. Statistical mechanics
Percolation is the `q → 1` limit of the Fortuin–Kasteleyn random cluster model. If you define your events cleanly now, you are one abstraction away from Potts-model phase transitions. This is a future theorem factory.

### 2. Complex analysis / conformal invariance
Crossing probabilities in planar critical percolation are the gateway to Cardy’s formula and Smirnov observables. Even if full conformal invariance is beyond current formalization reach, define finite-box crossing events in a way compatible with mesh refinement. That will matter later.

### 3. Boolean function analysis
Crossing events are monotone Boolean functions. This means KKL, sharp thresholds, influences, and Russo–Margulis formulas are the natural next layer. You are not just doing probability—you are building formal phase-transition complexity theory.

### 4. Algebraic geometry / exact solvability
The triangular threshold equation is an algebraic curve phenomenon. Exact thresholds emerge as polynomial fixed points of local transformation symmetries. This is the right place to connect with symbolic computation and certified root isolation.

### 5. Verified scientific computing
Finite-box crossing probabilities can be computed exactly for small `n` by enumeration. This creates a rare and powerful loop between theorem proving and experiment: Lean definitions become executable scientific objects.

---

## How to Build on the Existing Catalog Theorems

The listed catalog theorems are not directly percolation theorems, but use them opportunistically as architectural inspiration:

- `spectral_amplification_threshold` and `compression_threshold_exists` suggest a reusable **threshold-existence pattern**: define a monotone observable, prove boundedness/continuity, extract a critical parameter. Mirror this pattern for crossing probabilities.
- `exists_refinement_cell_for_pair` hints at a **refinement framework**. Reinterpret this philosophically for box subdivisions or mesh refinements in planar lattices. If you can define crossing events compatibly across refinements, you set up future scaling-limit work.
- `euler_four_square` is less directly relevant, but if symbolic exact algebra is needed for polynomial root manipulations, it is a reminder to lean on explicit arithmetic certification rather than handwaving.

Do not force these theorems into the proof. Use their structural style: certified existence, refinement, threshold extraction.

---

## Concrete Lean 4 Formalization Targets

You should create definitions with concrete finite types first.

Suggested objects:
- `Fin n × Fin m` as rectangular lattice vertices,
- nearest-neighbor adjacency as a `SimpleGraph`,
- `Bool`-valued configurations,
- event predicates as `Set (Config ...)` or direct `Prop` on configs,
- probability as finite sums over all configurations.

Suggested theorem signatures:

```lean
theorem increasing_event_prob_monotone
  {α : Type _} [Fintype α]
  (A : Set (α → Bool))
  (hA : ∀ η ξ, (∀ a, η a = true → ξ a = true) → η ∈ A → ξ ∈ A) :
  Monotone (fun p => bernoulliProbOfEvent p A)
```

```lean
theorem triangularCriticalPolynomial_strictMono_on_unit :
  StrictMonotoneOn triangularCriticalPolynomial (Set.Icc ((1 / Real.sqrt 3 : ℝ)) 1)
```

or a derivative-based uniqueness lemma:

```lean
theorem triangularCriticalPolynomial_unique_root_in_unit :
  ∃! p : ℝ, p ∈ Set.Ioo (0 : ℝ) 1 ∧ triangularCriticalPolynomial p = 0
```

Also consider a finite duality theorem:

```lean
theorem planar_rect_dual_crossing_complement
  (n m : ℕ) (hposn : 0 < n) (hposm : 0 < m) :
  ∀ ω, horizontalOpenCrossing ω ↔ ¬ verticalDualCrossing ω
```

This theorem, if formalized carefully, is a cornerstone.

---

## Experimental Component

You are instructed to create executable validation, not just proofs.

Implement optional `demo.py` or Lean evaluation code to:
- enumerate crossing probabilities for small boxes,
- numerically approximate the triangular critical root,
- compare finite-volume site and bond crossing curves,
- test candidate comparison maps `f(p)` for square site vs bond.

This matters because exact theorem design often becomes obvious only after data reveals the right monotone quantities.

---

## Anti-Goal: Do Not Fake the Square Site Threshold

The exact value of the square **site** percolation threshold is not known in classical mathematics. Therefore the visionary move is not to overclaim; it is to **formalize the frontier**:
- exact thresholds where exactness is known,
- reduction principles where exactness is unknown,
- finite-volume surrogates and testable hypotheses for the open case.

That is far more valuable than an unverifiable “solution.”

---

## Deliverables

1. Lean 4 files defining finite site and bond percolation.
2. At least one exact threshold theorem fully proved:
   - preferably `exists_unique_triangular_bond_threshold`,
   - plus a closed-form corollary.
3. Monotonicity theorem(s) for connection/crossing probabilities.
4. A finite planar duality theorem or a site–bond comparison theorem.
5. `FUTURE_DIRECTIONS.md` with **3–5 falsifiable hypotheses**.
6. Optional: `ARTICLE.md`, `RESEARCH_PAPER.md`, `demo.py`.

Minimize sorrys aggressively. Prefer one deep complete theorem over five hollow declarations.

---

## Required FUTURE_DIRECTIONS.md

You must produce a structured `FUTURE_DIRECTIONS.md` with 3–5 **testable scientific hypotheses**, each a falsifiable conjecture with a clear confirming/refuting test.

Use this format exactly:

### [Direction title]
- **Conjecture:** precise mathematical statement.
- **Why it matters:** what theorem family or scientific domain it could unlock.
- **Test:** exact finite computation, asymptotic experiment, or formal lemma sequence that could confirm/refute it.
- **Minimal Lean target:** the first theorem/definition to implement.

Suggested hypotheses:

### Finite-size convergence of square site crossing thresholds
- **Conjecture:** The finite-volume threshold `p_n` defined by `boxCrossingProbSite n p_n = 1/2` converges, and the convergence is monotone after some explicit `n₀`.
- **Why it matters:** first formal route toward an infinite-volume critical parameter.
- **Test:** compute `p_n` for `n ≤ 8` by exact enumeration or Monte Carlo with certified intervals.
- **Minimal Lean target:** `exists_finite_volume_threshold`.

### Dual crossing dichotomy on planar rectangular grids
- **Conjecture:** For every rectangular planar bond configuration, exactly one of primal horizontal crossing or dual vertical crossing occurs.
- **Why it matters:** the combinatorial core of self-dual threshold proofs.
- **Test:** exhaustive verification on small grids plus formal graph-theoretic proof.
- **Minimal Lean target:** `planar_rect_dual_crossing_complement`.

### Russo-type derivative formula for finite increasing events
- **Conjecture:** For any increasing event on a finite product space, the derivative of its Bernoulli probability equals the sum of influences.
- **Why it matters:** opens the door to sharp-threshold theory and Boolean analysis.
- **Test:** first prove for explicit finite sums over `Bool`-configurations.
- **Minimal Lean target:** derivative lemma for `bernoulliProbOfEvent`.

### Algebraic certification of the triangular threshold
- **Conjecture:** The unique root of `p^3 - 3p + 1 = 0` in `(0,1)` is exactly `2 * sin(π/18)`.
- **Why it matters:** exact solvability in formal probability.
- **Test:** prove trigonometric identity and interval bounds in Lean.
- **Minimal Lean target:** `triangular_bond_threshold_closed_form`.

### Site–bond comparison on square boxes
- **Conjecture:** There exists an explicit monotone map `f : [0,1] → [0,1]` such that `site` crossing probability is bounded above by `bond` crossing probability at parameter `f p` on every finite square box.
- **Why it matters:** formal reduction technology for the open square-site problem.
- **Test:** search for candidate `f` numerically on small boxes, then prove combinatorial coupling.
- **Minimal Lean target:** `square_site_to_bond_crossing_lower_bound`.

---

## Application Keywords

Percolation threshold, planar duality, self-duality, triangular lattice, honeycomb lattice, square lattice, crossing probability, Bernoulli product measure, monotone Boolean function, sharp threshold, Russo formula, influence, random cluster model, Potts model, conformal invariance, Cardy formula, Smirnov observable, finite-size scaling, verified scientific computing, exact solvability, algebraic criticality, discrete complex analysis.

Pursue the exact solvable models first, build the finite-box engine second, and make the square-site frontier mathematically precise rather than mythical.

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
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Speculative
Research mode: prove
