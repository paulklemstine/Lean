## Assignment: Phase 2 (Months 3–6): Core Development

Prove genuinely new, non-trivial theorems that turn the current tropical catalog into a bridge between certification, information theory, and geometric compilation. Minimize `sorry`, but do not think locally: the objective is to create a formal nucleus from which an entire tropical theory of verified computation can grow.

This cycle should aim at three tightly coupled breakthroughs:

1. **Kinetic certification framework**: certify stability of tropical argmax/nearest-facet decisions under time evolution.
2. **Tropical information-theoretic connections**: prove max-plus/min-plus analogues of monotonicity and data processing phenomena.
3. **Nearest-facet compilation**: formalize the geometric reduction from classification decisions to facet margins of polyhedral regions.

The existing catalog already contains seeds:
- `tropical_mirror_theorem`
- `birthday_bound_tropical_hash`
- `tropical_spectral_bound`
- `tropical_fundamental_theorem_of_arithmetic`
- `tropical_young_ineq`

Use them not as endpoints but as primitive lemmas in a larger architecture: spectral bounds for dynamical control, Young/Fenchel-style inequalities for information monotonicity, and tropical algebraic identities for piecewise-linear certification.

---

## Primary Breakthrough Target A: Kinetic Tropical Certification

### Vision
Build a theorem showing that if two competing tropical affine scores are separated by a positive margin at time `t = 0`, and their coefficients evolve with bounded speed, then the winning class remains unchanged for an explicit nonzero time interval. This is the formal skeleton of **certified temporal robustness** for tropicalized networks and polyhedral decision systems.

This is not a small extension of static certification. It opens a verified theory of **dynamical robustness**, where decisions are guaranteed stable under motion, streaming data, or adversarial temporal drift.

### Precise theorem statement
Let
- `w₁ w₂ : Fin n → ℝ` be two weight vectors,
- `b₁ b₂ : ℝ` be biases,
- `x0 v : Fin n → ℝ` define a trajectory `x(t) = x0 + t • v`,
- margin at `t=0` be
  \[
  m = (b₁ + \max_i (w₁ i + x0 i)) - (b₂ + \max_i (w₂ i + x0 i)).
  \]
If `m > 0`, then for sufficiently small `|t|`, the first score remains strictly larger than the second.

A Lean-oriented formulation:

```lean
def tropAffineScore {n : ℕ} (w x : Fin n → ℝ) (b : ℝ) : ℝ :=
  b + Finset.univ.sup' Finset.univ_nonempty (fun i => w i + x i)

def linePath {n : ℕ} (x0 v : Fin n → ℝ) (t : ℝ) : Fin n → ℝ :=
  fun i => x0 i + t * v i

theorem kinetic_tropical_margin_stability
    {n : ℕ} (hn : 0 < n)
    (w₁ w₂ x0 v : Fin n → ℝ) (b₁ b₂ : ℝ)
    (hmargin :
      0 <
        tropAffineScore w₁ x0 b₁ -
        tropAffineScore w₂ x0 b₂) :
    ∃ ε > 0, ∀ t : ℝ, |t| < ε →
      tropAffineScore w₁ (linePath x0 v t) b₁ >
      tropAffineScore w₂ (linePath x0 v t) b₂ := by
  sorry
```

### Stronger explicit quantitative version
You should also target an explicit lower bound using a velocity norm:
\[
| \max_i a_i(t) - \max_i a_i(0) | \le |t| \cdot \max_i |v_i|.
\]
From this derive a concrete certificate:
\[
|t| < \frac{m}{2L} \implies \text{decision unchanged},
\]
for a suitable Lipschitz constant `L`.

Lean signature sketch:

```lean
theorem max_along_line_lipschitz
    {n : ℕ} (hn : 0 < n)
    (a v : Fin n → ℝ) :
    ∀ t : ℝ,
      |(Finset.univ.sup' Finset.univ_nonempty (fun i => a i + t * v i)) -
       (Finset.univ.sup' Finset.univ_nonempty (fun i => a i))|
      ≤ |t| * Finset.univ.sup' Finset.univ_nonempty (fun i => |v i|) := by
  sorry
```

and then:

```lean
theorem kinetic_tropical_margin_stability_explicit
    {n : ℕ} (hn : 0 < n)
    (w₁ w₂ x0 v : Fin n → ℝ) (b₁ b₂ : ℝ)
    (hmargin :
      0 <
        tropAffineScore w₁ x0 b₁ -
        tropAffineScore w₂ x0 b₂) :
    let L :=
      Finset.univ.sup' Finset.univ_nonempty (fun i => |v i|)
    ∀ t : ℝ,
      |t| < (tropAffineScore w₁ x0 b₁ - tropAffineScore w₂ x0 b₂) / (2 * L + 1) →
      tropAffineScore w₁ (linePath x0 v t) b₁ >
      tropAffineScore w₂ (linePath x0 v t) b₂ := by
  sorry
```

If the denominator above is awkward when `L = 0`, split into cases `L = 0` and `L > 0`.

### Why this is a breakthrough
This theorem is the tropical analogue of a verified **reachability-safe margin theorem**. It would create a formal language for:
- temporal robustness of piecewise-linear classifiers,
- certified hybrid systems with tropical guards,
- geometric compilation of decision boundaries into kinetic certificates.

This is the beginning of a theorem-proving interface between **tropical geometry, control theory, and AI verification**.

### Proof strategy options

#### Strategy A: Direct max perturbation estimate
1. Prove a general lemma:
   \[
   \max_i (a_i + \delta_i) \le \max_i a_i + \max_i \delta_i.
   \]
   and its lower-bound counterpart using `-δ`.
2. Specialize to `δ_i = t * v_i` and bound by `|t| * max_i |v_i|`.
3. Apply the estimate to both scores and preserve strict positivity of the gap.

**Most promising** because it is finite-dimensional, elementary, and aligns cleanly with `Finset.sup'` lemmas in Mathlib.

#### Strategy B: Convex/Lipschitz route
1. Observe tropical affine scores are convex piecewise-linear functions.
2. Prove each score is globally Lipschitz along the line `x0 + t v`.
3. Use the difference estimate to preserve a positive margin on a small interval.

This is conceptually elegant and scales toward future generalizations to tropical polynomials and support functions.

#### Strategy C: Argmax cell decomposition
1. Partition time near `0` by which index realizes the max.
2. On each cell, the score is affine in `t`.
3. Use finiteness of candidate breakpoints to extract a uniform positive interval.

This is geometrically profound and will be useful for nearest-facet compilation, but is probably more work in Lean than Strategy A.

### Cross-domain connections
- **Control theory**: invariant decision regions under bounded flow.
- **Formal verification**: certified robustness under temporal perturbations.
- **Computational geometry**: polyhedral cell persistence.
- **Tropical optimization**: max-plus support functions as dynamic value functions.

### Application keywords
`tropical robustness`, `kinetic certification`, `temporal verification`, `piecewise-linear dynamics`, `support function stability`, `polyhedral safety`

---

## Primary Breakthrough Target B: Tropical Data Processing Inequality for Deterministic Coarse-Graining

### Vision
Formalize a tropical information quantity and prove it cannot increase under deterministic aggregation. This is the right scale of theorem for a cold start: strong enough to be conceptually field-opening, yet concrete enough to formalize over `Finset`, `Real`, and finite maps.

A full Shannon-style tropical mutual information may be premature, but a robust first theorem is available now: **the spread of a score vector cannot increase under tropical coarse-graining by maxima over blocks**. This is a max-plus information monotonicity principle.

Interpretation: if information is encoded by score separation, then merging states by a deterministic observation map cannot create new distinguishability.

### Definitions
For `x : Fin n → ℝ`, define tropical spread
\[
\mathrm{spread}(x) = \max_i x_i - \min_i x_i.
\]
For a surjective block map `π : Fin n → Fin m`, define coarse-graining
\[
(T_\pi x)(j) = \max_{i : \pi(i)=j} x_i.
\]
Then prove
\[
\mathrm{spread}(T_\pi x) \le \mathrm{spread}(x).
\]

Lean-oriented definitions may use explicit fibers via `Finset.univ.filter`.

```lean
def tropSpread {n : ℕ} (x : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty x -
  Finset.univ.inf' Finset.univ_nonempty x

def coarseGrainMax {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (π : Fin n → Fin m) (hπ : Function.Surjective π)
    (x : Fin n → ℝ) : Fin m → ℝ :=
  fun j =>
    ((Finset.univ.filter (fun i => π i = j)).sup' (by
      obtain ⟨i, rfl⟩ := hπ j
      exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, rfl⟩)
      x)
```

### Precise theorem statement

```lean
theorem tropSpread_coarseGrainMax_le
    {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (π : Fin n → Fin m) (hπ : Function.Surjective π)
    (x : Fin n → ℝ) :
    tropSpread (coarseGrainMax hn hm π hπ x) ≤ tropSpread x := by
  sorry
```

### Why this is a breakthrough
This is a legitimate tropical analogue of a **data processing inequality**: deterministic observation cannot increase information-like spread. It provides a formal entry point into tropical information theory without requiring measure-theoretic entropy on day one.

This theorem could seed:
- tropical channel theory,
- verified abstractions of neural score maps,
- max-plus signal compression bounds,
- geometric semantics of information loss under quotienting.

### Proof strategy options

#### Strategy A: Bound max and min separately
1. Show `max (coarseGrainMax x) ≤ max x` and `max x ≤ max (coarseGrainMax x)`; hence the maxima are actually equal.
2. Show `min (coarseGrainMax x) ≥ min x`.
3. Subtract to get `spread(coarseGrainMax x) ≤ spread(x)`.

**Most promising**: it is elementary, exact, and uses only finite extrema lemmas.

#### Strategy B: View coarse-graining as tropical linear operator
1. Encode coarse-graining as a max-plus matrix with entries `0` on allowed edges and `-∞` otherwise; approximate in Lean using finite max over admissible fibers.
2. Prove such operators are nonexpansive for Hilbert-like seminorm/spread.
3. Deduce the theorem as a finite deterministic case.

This is more visionary and points toward a full tropical Perron–Frobenius/information interface.

#### Strategy C: Galois-connection viewpoint
1. Regard blockwise max as left Kan extension / supremal pushforward.
2. Prove order-preservation and interval contraction on image sets.
3. Extract spread monotonicity.

Harder formally, but it opens category-theoretic tropical semantics.

### Cross-domain connections
- **Information theory**: deterministic data processing inequality.
- **Category theory**: left Kan extension along a finite map.
- **Signal processing**: pooling/compression cannot increase score resolution.
- **Machine learning**: max-pooling monotonicity as an information contraction principle.

### Application keywords
`tropical information theory`, `data processing inequality`, `max-pooling`, `coarse-graining`, `score compression`, `finite channel semantics`

---

## Primary Breakthrough Target C: Nearest-Facet Compilation as Margin Computation

### Vision
Prototype a theorem reducing polyhedral region membership certification to finitely many affine inequalities, then prove that a positive minimum slack certifies local stability under perturbation. This is the geometric compiler theorem: from a decision region to a computable margin certificate.

Let a polyhedral region be given by inequalities
\[
A_k(x) := \sum_i c_{k,i} x_i \le b_k, \quad k \in K.
\]
Define the slack
\[
s_k(x) = b_k - \sum_i c_{k,i}x_i.
\]
If all slacks are positive, the point is interior; if the minimum slack exceeds a perturbation bound, membership is stable.

Even if full Euclidean nearest-facet distance is heavy, a first formal theorem in `ℓ∞` or coordinatewise perturbation is absolutely worthwhile.

### Precise theorem statement
Use finite index types and affine forms over `Fin n`.

```lean
def affineForm {n : ℕ} (c : Fin n → ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, c i * x i

def polySlack {n k : ℕ} (A : Fin k → Fin n → ℝ) (b : Fin k → ℝ)
    (x : Fin n → ℝ) (j : Fin k) : ℝ :=
  b j - affineForm (A j) x

def inPolyhedron {n k : ℕ} (A : Fin k → Fin n → ℝ) (b : Fin k → ℝ)
    (x : Fin n → ℝ) : Prop :=
  ∀ j, affineForm (A j) x ≤ b j
```

Target theorem:

```lean
theorem polyhedral_membership_stable_of_positive_slack
    {n k : ℕ}
    (A : Fin k → Fin n → ℝ) (b : Fin k → ℝ)
    (x : Fin n → ℝ)
    (hinside : inPolyhedron A b x)
    (hslack : ∀ j, 0 < polySlack A b x j) :
    ∃ ε > 0, ∀ y : Fin n → ℝ,
      (∀ i, |y i - x i| < ε) →
      inPolyhedron A b y := by
  sorry
```

A stronger quantitative theorem should bound `ε` using row sums:
\[
\left|\sum_i c_i(y_i-x_i)\right| \le \sum_i |c_i|\,|y_i-x_i|
\le \varepsilon \sum_i |c_i|.
\]
Hence if
\[
\varepsilon < \min_j \frac{s_j(x)}{\sum_i |A_{j,i}| + 1},
\]
membership is preserved.

### Why this is a breakthrough
This theorem turns geometric compilation into proof-producing certification. It is the formal backbone of:
- verified nearest-facet search,
- robust classification by polyhedral guards,
- static-to-dynamic transfer when combined with Target A.

This is where tropical and classical polyhedral geometry meet operational semantics.

### Proof strategy options

#### Strategy A: Direct slack perturbation bound
1. Expand `polySlack A b y j - polySlack A b x j`.
2. Bound the affine perturbation by triangle inequality and a row-wise coefficient norm.
3. Choose `ε` below the minimum normalized slack.

**Most promising**, because it is explicit, constructive, and computationally meaningful.

#### Strategy B: Continuity of finitely many affine forms
1. Prove each constraint map is continuous.
2. Intersect finitely many open preimages of `(-∞, b_j)`.
3. Extract a uniform neighborhood using finiteness.

Cleaner analytically, but less quantitative.

#### Strategy C: Dual support-function perspective
1. Interpret each facet as a support functional.
2. Show positive slack means strict separation from every supporting hyperplane.
3. Convert separation into a certified neighborhood.

Most conceptually powerful for future tropical-polyhedral duality.

### Cross-domain connections
- **Computational geometry**: facet certificates and region stability.
- **Program compilation**: decision regions as compiled guards.
- **Optimization**: feasible-set interior certificates.
- **Neural verification**: polyhedral abstractions of piecewise-linear models.

### Application keywords
`nearest-facet compilation`, `polyhedral certification`, `robust feasibility`, `guard verification`, `affine slack bounds`, `compiled geometry`

---

## Build on Catalog Theorems Explicitly

Do not merely cite the catalog; exploit it structurally.

1. **`tropical_spectral_bound`**
   - Use it as a conceptual precursor for growth control in kinetic systems.
   - Even if the final proof of Target A is elementary, connect the theorem to future matrix-driven dynamics `x_{t+1} = A ⊗ x_t`.
   - State in `FUTURE_DIRECTIONS.md` how a spectral tropical bound could yield long-time certification horizons.

2. **`tropical_young_ineq`**
   - Use it as evidence that a Fenchel/duality viewpoint is already present in the library.
   - Position Target B as the next step: from one-step inequality to monotonicity of information-like functionals.
   - If possible, derive a small corollary about upper bounds on score differences via convex conjugate heuristics.

3. **`tropical_mirror_theorem`**
   - Trivial as stated, but symbolically important: idempotence and max-stability are foundational.
   - Use it to motivate why max-plus aggregation behaves like deterministic observation/compression in Target B.

4. **`birthday_bound_tropical_hash`**
   - Connect to collision/compression phenomena.
   - In `FUTURE_DIRECTIONS.md`, propose a theorem relating coarse-graining collisions to tropical spread loss.

5. **`tropical_fundamental_theorem_of_arithmetic`**
   - Use only if a clean algebraic encoding emerges.
   - Otherwise mention as evidence the catalog already supports nontrivial structural tropical statements.

---

## Secondary Tactical Objective: Sorry-Fill Opportunity

Because this is a cold start, if there are accessible priority placeholders for `CarmichaelComposite` or `Fib_gcd_identity`, close them quickly before or alongside the breakthrough work. But do not let these consume the cycle. They are tactical debt reduction; the strategic objective is Targets A–C.

If you find the files, use exact `sorry_fill` mode with theorem names and local context. Otherwise proceed with the new theorem development above.

---

## Lean Design Guidance

Prefer concrete finite types:
- `Fin n → ℝ`
- `Finset.univ.sup'` / `Finset.univ.inf'`
- `∑ i, ...`
- row-wise coefficient bounds via finite sums of absolute values

Avoid premature abstraction to topological vector spaces unless it shortens the proof.

Useful supporting lemmas to prove first:
1. `max ≤ max + max perturbation`
2. `inf ≤ x i ≤ sup`
3. affine perturbation triangle bound
4. finite minimum positive implies existence of a uniform epsilon
5. blockwise-max output remains between global min and max of input

These lemmas will likely unlock all three primary targets.

---

## Suggested execution order

### Phase 2.1
Prove finite extrema perturbation lemmas:
- max perturbation under additive noise
- spread monotonicity ingredients
- affine form perturbation bound

### Phase 2.2
Complete **Target B** first if you want momentum:
- it is conceptually rich and technically finite.

### Phase 2.3
Complete **Target C**:
- gives explicit certification machinery.

### Phase 2.4
Use the perturbation lemmas to prove **Target A**:
- then connect C + A into kinetic nearest-facet certification.

A particularly strong combined theorem would say:
if a point lies in a polyhedral decision region with positive slack and moves along a bounded-speed path, then region membership is preserved for an explicit time horizon.

That synthesis theorem would be a major result.

---

## Deliverables

Required:
- Lean 4 files with theorems above, or sharpened variants that are strictly nontrivial.
- Minimal `sorry`.
- `FUTURE_DIRECTIONS.md`

Optional but strongly encouraged:
- `ARTICLE.md` explaining the emerging theory of tropical certified computation.
- `RESEARCH_PAPER.md` with theorem statements, proof architecture, and domain impact.
- small examples or demos showing coarse-graining, spread contraction, and kinetic stability.

---

## FUTURE_DIRECTIONS.md requirements

This file is critical. Include **3–5 concrete next theorems**, each with:
1. exact statement,
2. Lean-oriented type signature sketch,
3. proof strategy,
4. cross-domain significance.

At least one future direction must be truly breakthrough-level, such as:

- **Tropical Markov contraction theorem**: prove repeated coarse-graining/max-plus transfer decreases tropical spread under iteration.
- **Matrix-driven kinetic certification**: certify decision stability for trajectories generated by tropical linear dynamics using `tropical_spectral_bound`.
- **Tropical channel capacity prototype**: define a finite tropical distinguishability capacity and prove monotonicity under composition.
- **Nearest-facet/argmax equivalence theorem**: show a class decision margin equals distance to a polyhedral decision boundary in a formalized normed setting.
- **Tropical Fenchel-information duality**: connect `tropical_young_ineq` to a formally defined tropical divergence.

Make the file ambitious enough to direct the next research cycle toward a new subfield, not just a backlog.

---

## Team Directive

Create a real internal research loop:
- one subteam for finite-extrema lemmas,
- one for information-theoretic formalization,
- one for polyhedral certification and examples,
- one for proof refactoring and theorem packaging.

Run experiments on small `Fin n` cases to guess sharp formulations, then prove the strongest true statements. Update the knowledge base continuously. Seek the theorem that makes a mathematician say: *this is the beginning of tropical certified information dynamics*.

The goal is not just to prove isolated facts. The goal is to make Lean host the first rigorous bridge between **tropical geometry, information monotonicity, and verified dynamical decision systems**.

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

Research domain: Tropical
Research mode: prove
