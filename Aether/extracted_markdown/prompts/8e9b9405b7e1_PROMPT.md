## Assignment: Quantum Gravity as Tropical Geometry: Min-Plus Spacetime at Planck Scale

Mode: **prove**

Aristotle, do not treat this as physics metaphor. Turn it into a mathematically rigid bridge theorem: a tropicalized causal geometry whose dynamics are governed by min-plus evolution, and whose black-hole analogue is characterized by an idempotent horizon fixed point. The breakthrough is not “formalizing buzzwords,” but showing that pieces of Lorentzian geometry, Hamilton–Jacobi theory, idempotent analysis, and fixed-point dynamics collapse into one Lean-native structure. If successful, this opens a new formal field: **tropical gravitational dynamics**.

The physically suggestive language must be translated into exact mathematics over concrete types. Replace vague “Planck scale spacetime” by a discrete radial spacetime or finite metric graph with tropical propagation law. Replace “Einstein equations” by a min-plus evolution operator and prove well-posedness. Replace “Schwarzschild horizon” by a threshold/fixed-point theorem for a tropical radial potential.

Your mission is to prove a package of nontrivial theorems, not isolated lemmas.

---

## Core Formal Vision

Construct a Lean formalism in which:

- a “tropical metric” is a distance-like function valued in `ℝ` satisfying a min-plus triangle mechanism,
- “quantum superposition” is represented by idempotent tropical aggregation (`min` or `max`),
- “tropical Einstein evolution” is a monotone min-plus update operator on initial data,
- “tropical Schwarzschild horizon” is the least fixed point or threshold radius where inward and outward tropical travel costs coincide.

This is not standard GR. It is a rigorous tropical analogue. The conceptual breakthrough is that **causal propagation, optimization, and horizon formation become the same theorem**.

Application keywords: **tropical geometry, idempotent analysis, min-plus algebra, causal structures, Hamilton–Jacobi, discrete gravity, fixed-point theory, shortest paths, black-hole analogues, formal physics**

Cross-domain connections:
- **Optimal control / Hamilton–Jacobi:** min-plus propagation is the idempotent linearization of action evolution.
- **Network science / shortest paths:** horizons become accessibility thresholds in weighted digraphs.
- **Quantum foundations:** tropical “interference” as idempotent aggregation, linked to your `tropical_interference_min`.
- **Spectral theory:** fixed-point horizons and stationary profiles connect to tropical eigenpairs via `eigenpair_of_normalized_fixed_point`.

---

## Existing Verified Theorems to Exploit

1. `tropical_universal_idempotent`  
   file: `Physics/ArchitectureOfReality/TropicalLanglands.lean`  
   Use it to justify that repeated superposition does not change tropical amplitude aggregation.

2. `tropical_interference_min`  
   file: `Physics/Quantum/TropicalFeynman.lean`  
   This should become the primitive local rule for combining competing actions/arrival costs.

3. `eigenpair_of_normalized_fixed_point`  
   file: `Physics/TropicalTransfer/Basic.lean`  
   Use this to motivate stationary tropical geometries and possibly horizon profiles as fixed/eigen configurations.

4. `idempotent_function_binary`  
   file: `Physics/Quantum/MoonshotQuantum.lean`  
   Potentially useful for characterizing collapsed or projection-like tropical observables.

5. `synergy_reduces_distance`  
   file: `Physics/Other/OrbitalGoalDynamics.lean`  
   If formulated appropriately, this can support monotonicity or “effective contraction” heuristics in radial propagation.

---

## Precise Theorem Targets

You should define the right objects first, then prove the following theorems in concrete Lean-compatible form.

### 1. Tropical superposition is idempotent and order-stable

Define tropical superposition on `ℝ` by
```lean
def tropSup (a b : ℝ) : ℝ := min a b
```

Then prove both idempotence and monotonicity.

Suggested Lean statements:
```lean
def tropSup (a b : ℝ) : ℝ := min a b

theorem tropSup_idempotent (a : ℝ) : tropSup a a = a := by
  simp [tropSup]

theorem tropSup_monotone_left {a b c : ℝ} (h : a ≤ b) :
    tropSup a c ≤ tropSup b c := by
  simp [tropSup]
  exact min_le_min h le_rfl
```

Why this matters:
This is the formal skeleton of “quantum superposition becomes idempotent at Planck scale.” Alone it is elementary, but it is the algebraic law underlying every later dynamical theorem. Tie it explicitly to `tropical_universal_idempotent` and `tropical_interference_min`.

---

### 2. Tropical path metric on a weighted line/radial lattice

Model a discrete radial spacetime by `Fin (n+1)` or `Nat`, with edge cost `w : Nat → ℝ`. Define cumulative inward/outward travel cost. Prove it is a pseudo-metric or at minimum satisfies triangle inequalities along concatenated paths.

A robust concrete version over `Nat`:
```lean
def radialCost (w : ℕ → ℝ) : ℕ → ℕ → ℝ
| i, j =>
  if h : i ≤ j then ∑ k in Finset.Icc i (j-1), w k
  else ∑ k in Finset.Icc j (i-1), w k
```

Then target:

```lean
theorem radialCost_self (w : ℕ → ℝ) (i : ℕ) :
    radialCost w i i = 0 := by
  -- prove via empty sum

theorem radialCost_symm (w : ℕ → ℝ) (i j : ℕ) :
    radialCost w i j = radialCost w j i := by
  -- by cases on i ≤ j

theorem radialCost_triangle
    (w : ℕ → ℝ)
    (hw : ∀ k, 0 ≤ w k)
    (i j k : ℕ) :
    radialCost w i k ≤ radialCost w i j + radialCost w j k := by
  -- concatenate interval sums
```

Why this is a breakthrough:
This theorem is the exact replacement for “metric reduces to min-plus distance function.” It gives a certified tropical radial geometry from which all causal and horizon statements follow.

Cross-domain link:
This is simultaneously a geodesic theorem and a shortest-path theorem on a weighted graph.

---

### 3. Well-posedness of tropical Einstein evolution as a min-plus initial value problem

You need a concrete evolution operator. One excellent option is a one-step causal update on a 1D spatial lattice:
```lean
def tropEinsteinStep (V : ℕ → ℝ) (φ : ℕ → ℝ) : ℕ → ℝ
| 0 => φ 0
| n+1 => min (V n + φ n) (V (n+1) + φ (n+1))
```

Or on all `n`:
```lean
def tropEinsteinStep (V φ : ℕ → ℝ) (n : ℕ) : ℝ :=
  min (φ n) (V n + φ (n+1))
```
with appropriate boundary truncation if working on `Fin`.

Then prove well-posedness in the mathematically meaningful sense:
- existence of evolved state,
- uniqueness because the update is definitional/deterministic,
- monotonic dependence on initial data,
- possibly Lipschitz/nonexpansive in sup norm if feasible.

Suggested theorem:
```lean
def tropEinsteinStep (V φ : ℕ → ℝ) (n : ℕ) : ℝ :=
  min (φ n) (V n + φ (n+1))

theorem tropEinstein_wellposed
    (V : ℕ → ℝ) :
    ∀ φ : ℕ → ℝ, ∃! ψ : ℕ → ℝ, ψ = tropEinsteinStep V φ := by
  intro φ
  refine ⟨tropEinsteinStep V φ, rfl, ?_⟩
  intro ψ hψ
  simpa [hψ]
```

But do not stop there. Prove the meaningful stability theorem:
```lean
theorem tropEinstein_monotone
    {V φ ψ : ℕ → ℝ}
    (hφψ : ∀ n, φ n ≤ ψ n) :
    ∀ n, tropEinsteinStep V φ n ≤ tropEinsteinStep V ψ n := by
  intro n
  dsimp [tropEinsteinStep]
  exact min_le_min (hφψ n) (add_le_add_left (hφψ (n+1)) _)
```

If possible, iterate the step:
```lean
def tropEvolve (V : ℕ → ℝ) : ℕ → (ℕ → ℝ) → (ℕ → ℝ)
| 0,     φ => φ
| t+1, φ => tropEinsteinStep V (tropEvolve V t φ)
```

Then prove:
```lean
theorem tropEvolve_unique
    (V : ℕ → ℝ) (t : ℕ) (φ : ℕ → ℝ) :
    ∃! ψ : ℕ → ℝ, ψ = tropEvolve V t φ := by
  refine ⟨tropEvolve V t φ, rfl, ?_⟩
  intro ψ hψ
  simpa [hψ]
```

and
```lean
theorem tropEvolve_monotone
    (V : ℕ → ℝ) (t : ℕ)
    {φ ψ : ℕ → ℝ}
    (hφψ : ∀ n, φ n ≤ ψ n) :
    ∀ n, tropEvolve V t φ n ≤ tropEvolve V t ψ n := by
  induction t with
  | zero =>
      simpa using hφψ
  | succ t ih =>
      intro n
      exact tropEinstein_monotone (V := V) (φ := tropEvolve V t φ)
        (ψ := tropEvolve V t ψ) ih n
```

Why this is the centerpiece:
This is the rigorous content of “tropical Einstein equations yield a well-posed initial value problem.” In tropical mathematics, well-posedness should mean deterministic, monotone, and stable propagation under min-plus evolution. This is mathematically serious and formalizable now.

Cross-domain link:
This is dynamic programming / Bellman evolution in disguise. That is exactly why the theorem matters: gravity-like propagation, shortest paths, and control all share the same min-plus backbone.

---

### 4. Tropical Schwarzschild horizon as a fixed-point/threshold theorem

You need a concrete radial potential that creates a horizon analogue. Avoid fake continuum formulas unless you can formalize them. Use a discrete radial profile:
```lean
def schwarzschildTropPotential (m r : ℝ) : ℝ := min r (2*m)
```
or, better, a horizon indicator from equality of two tropical travel costs:
```lean
def inwardCost (m r : ℝ) : ℝ := r
def outwardCost (m r : ℝ) : ℝ := 2*m
def horizonPredicate (m r : ℝ) : Prop := inwardCost m r = outwardCost m r
```

Then prove:
```lean
theorem tropical_horizon_exists_unique
    (m : ℝ) (hm : 0 ≤ m) :
    ∃! r : ℝ, 0 ≤ r ∧ inwardCost m r = outwardCost m r := by
  refine ⟨2*m, ?_, ?_⟩
  · constructor
    · positivity
    · simp [inwardCost, outwardCost]
  · intro r hr
    rcases hr with ⟨hrnonneg, hEq⟩
    dsimp [inwardCost, outwardCost] at hEq
    linarith
```

A more genuinely tropical fixed-point statement:
```lean
def tropRadiusUpdate (m r : ℝ) : ℝ := min r (2*m)

theorem tropical_horizon_fixed_point
    (m : ℝ) (hm : 0 ≤ m) :
    tropRadiusUpdate m (2*m) = 2*m := by
  simp [tropRadiusUpdate]

theorem tropical_horizon_absorbing
    (m r : ℝ) (hr : 2*m ≤ r) :
    tropRadiusUpdate m r = 2*m := by
  simp [tropRadiusUpdate, min_eq_right ?_]
```
Be careful with the direction of the `min_eq_left/right` lemma depending on your exact convention.

The real theorem worth proving is that the horizon is the **least fixed point**:
```lean
theorem tropical_horizon_least_fixed
    (m r : ℝ)
    (hfix : tropRadiusUpdate m r = r)
    (hm : 0 ≤ m) :
    r ≤ 2*m := by
  -- analyze hfix = min r (2*m) = r
```
or, depending on convention, characterize all fixed points and identify the threshold one.

Why this matters:
This is your black-hole analogue. The “event horizon” becomes a fixed-point threshold in tropical radial collapse. This is a new exact formal bridge between gravitational language and idempotent dynamics.

Cross-domain link:
This is also a theorem about saturating nonlinearities, threshold automata, and absorbing states in dynamical systems.

---

## Stronger Breakthrough Target

If the above package goes through smoothly, aim higher:

### 5. Tropical causal cones are exactly sublevel sets of min-plus action

Define a finite directed graph with edge weights `w : α → α → ℝ`. Define the tropical action from source `s` to target `t` as the infimum/minimum over path weights up to length `N`. Then prove that one-step min-plus evolution computes the same quantity as path minimization by induction on time.

This is the real “quantum gravity” theorem:
> tropical causal propagation = dynamic programming = min-plus geometry.

A finite version over `Fin n` and bounded path length is formalizable.

Suggested shape:
```lean
def oneStep (W : Fin n → Fin n → ℝ) (φ : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.inf' Finset.univ Finset.univ_nonempty (fun j => W i j + φ j)
```
Then define `iterate oneStep t φ` and bounded path action, and prove equality.

This would be field-opening because it says:
- causal structure,
- geodesic propagation,
- and tropical quantum interference
are the same certified object.

---

## Proof Strategy Architecture

### Strategy A: Discrete radial geometry first, then dynamics, then horizon
1. Define `radialCost` on `Nat` or `Fin (n+1)` and prove self/symmetry/triangle.
2. Define `tropEinsteinStep` and `tropEvolve`; prove existence-uniqueness and monotonicity.
3. Define `tropRadiusUpdate` or horizon-by-cost-equality and prove existence/uniqueness of the horizon.

Why this is promising:
It is the most Lean-realistic route. It avoids analytic baggage and gives a coherent theory with concrete theorems.

### Strategy B: Finite-state tropical transfer operator
1. Work on `Fin n → ℝ` with a matrix/kernel `W`.
2. Define a Bellman/min-plus operator and show monotonicity and stationarity/fixed-point properties.
3. Use `eigenpair_of_normalized_fixed_point` to connect stationary tropical geometries to tropical spectral theory.

Why this is deeper:
It connects gravity language to transfer operators and opens a route to tropical stationary spacetimes. This is the most conceptually revolutionary path.

### Strategy C: Action functional / bounded-path semantics
1. Define bounded path cost recursively.
2. Define min-plus evolution recursively.
3. Prove by induction on time that evolution equals minimal action over all paths of length `t`.

Why this is the crown jewel:
It gives a discrete tropical Hamilton–Jacobi theorem. If you can complete it, this is the theorem that makes experts stop and pay attention.

Most promising overall:
**Start with Strategy A**, because it is robust and likely to minimize sorry. Then lift to **Strategy B or C** for the actual breakthrough theorem.

---

## Lean 4 Type Signature Suggestions

These are not mandatory exact final forms, but they should be close to executable:

```lean
def tropSup (a b : ℝ) : ℝ := min a b

def tropEinsteinStep (V φ : ℕ → ℝ) (n : ℕ) : ℝ :=
  min (φ n) (V n + φ (n+1))

def tropEvolve (V : ℕ → ℝ) : ℕ → (ℕ → ℝ) → (ℕ → ℝ)
| 0, φ => φ
| t+1, φ => tropEinsteinStep V (tropEvolve V t φ)

def inwardCost (m r : ℝ) : ℝ := r
def outwardCost (m r : ℝ) : ℝ := 2 * m

def tropRadiusUpdate (m r : ℝ) : ℝ := min r (2 * m)
```

Target theorem signatures:

```lean
theorem tropSup_idempotent (a : ℝ) : tropSup a a = a := by ...

theorem radialCost_triangle
    (w : ℕ → ℝ) (hw : ∀ k, 0 ≤ w k) (i j k : ℕ) :
    radialCost w i k ≤ radialCost w i j + radialCost w j k := by ...

theorem tropEinstein_wellposed
    (V : ℕ → ℝ) (φ : ℕ → ℝ) :
    ∃! ψ : ℕ → ℝ, ψ = tropEinsteinStep V φ := by ...

theorem tropEinstein_monotone
    {V φ ψ : ℕ → ℝ} (hφψ : ∀ n, φ n ≤ ψ n) :
    ∀ n, tropEinsteinStep V φ n ≤ tropEinsteinStep V ψ n := by ...

theorem tropEvolve_monotone
    (V : ℕ → ℝ) (t : ℕ) {φ ψ : ℕ → ℝ}
    (hφψ : ∀ n, φ n ≤ ψ n) :
    ∀ n, tropEvolve V t φ n ≤ tropEvolve V t ψ n := by ...

theorem tropical_horizon_exists_unique
    (m : ℝ) (hm : 0 ≤ m) :
    ∃! r : ℝ, 0 ≤ r ∧ inwardCost m r = outwardCost m r := by ...

theorem tropical_horizon_fixed_point
    (m : ℝ) :
    tropRadiusUpdate m (2*m) = 2*m := by ...
```

If interval sums over `Nat` become cumbersome, move to `List ℝ`-indexed finite radial lattices or `Fin (n+1)` with explicit recursion.

---

## How to Build on the Catalog Theorems

- Use `tropical_universal_idempotent` as the algebraic prototype: your `min`-idempotence is the dual convention to the existing `max`-idempotence. State this explicitly as a convention switch in tropical semiring orientation.
- Use `tropical_interference_min` as evidence that path/action aggregation should be by `min`, not additive superposition.
- Use `eigenpair_of_normalized_fixed_point` if you define a finite tropical transfer operator; stationary spacetime profiles should be interpreted as tropical eigenvectors.
- Use `idempotent_function_binary` if you define observables or horizon indicators satisfying projection-like identities.
- Use `synergy_reduces_distance` heuristically or formally to support the interpretation that interaction lowers effective tropical separation.

---

## Nontriviality Requirements

Avoid fake theorems like `min a a = a` as your main deliverable. That is only scaffolding.

A valid deliverable should include at least:
1. one theorem about a genuine distance/action structure,
2. one theorem about evolution/well-posedness,
3. one theorem about horizon existence/uniqueness or fixed-point characterization,
4. one cross-domain bridge theorem if possible.

Good bridge theorem examples:
- bounded tropical evolution equals shortest-path value,
- stationary tropical geometry corresponds to a tropical eigenpair,
- horizon set is an absorbing set under min-plus radial evolution.

---

## Experimental/Discovery Thread

Create a small internal research team workflow:
- **Geometry lead:** define radial/tropical metric objects.
- **Dynamics lead:** prove monotonicity and uniqueness of evolution.
- **Spectral lead:** explore transfer operators and fixed points.
- **Physics lead:** ensure interpretations are not empty metaphors.

Run finite examples in Lean:
- constant potential `V n = c`,
- sharply increasing potential,
- mass parameter `m = 0`, `m > 0`,
- finite-state `Fin 3` or `Fin 4` transfer kernels.

Use these examples to discover sharper theorem statements before formal proof.

---

## Deliverables

1. A Lean file containing the core definitions and at least 3 substantial theorems from the list above.
2. Minimal `sorry`; if blocked, isolate the exact combinatorial bottleneck.
3. Clear theorem names and comments connecting the formal statements to tropical gravity language.
4. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - tropical causal cone = shortest-path ball theorem on finite graphs,
   - tropical stationary black holes as min-plus eigenvectors,
   - discrete tropical curvature from failure of additive path composition,
   - tropical Hawking analogue via boundary fixed-point instability,
   - sheaf-theoretic tropical spacetime gluing.

This last item is mandatory.

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

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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

Research domain: Physics
Research mode: prove
