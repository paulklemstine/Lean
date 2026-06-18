## Assignment: prove

### Title
**Tropical Factor-Rank-1 Equivalence via Min-Plus, Additive Separability, and the Vanishing of Tropical 2×2 Minors**

Prove a genuinely structural theorem, not a definitional reformulation: the rank-1 part of min-plus matrix factorization is exactly the same object as additive cocycle triviality, and for finite matrices it is exactly detected by the 2×2 tropical minor equalities. This is the first formal bridge between tropical linear algebra, Monge-type geometry, and discrete potential theory in this codebase.

You should aim to formalize this in a new file such as:

```lean
Tropical/LinearAlgebra/MinPlusRankOne.lean
```

or, if the existing directory structure suggests it, a nearby file under `Tropical/Core/`.

---

## Core mathematical target

Let `A : Fin n → Fin m → ℝ`. Define min-plus factor rank ≤ `k` by
\[
A(i,j)=\min_{t\in \mathrm{Fin}\,k} (U(i,t)+V(t,j)).
\]
For `k = 1`, this should collapse to additive separability:
\[
A(i,j)=p(i)+q(j).
\]

The breakthrough theorem is that for nonempty finite index sets, this is equivalent to the **tropical 2×2 minor condition**
\[
A(i,j)+A(i',j') = A(i,j')+A(i',j)
\]
for all indices. This is the exact vanishing of the discrete mixed second derivative. In other words: min-plus rank 1 is not merely a factorization notion; it is a flatness condition.

This opens a path toward a formal tropical linear algebra hierarchy:
- rank-1 as exact separability,
- higher rank as tropical convex generation,
- minors as discrete curvature obstructions.

---

## Precise Lean 4 formalization target

You should first define the factorization predicate in a way that avoids awkward partiality for `k = 0`. Since `Fin 1` is the key case, the cleanest route is to define the general predicate using `sInf` over the finite image set, or to restrict the main theorem to `k = 1` via an explicit definition.

A practical definition:

```lean
def MinPlusFactorRankLE (k : ℕ) {n m : ℕ} (A : Fin n → Fin m → ℝ) : Prop :=
  ∃ U : Fin n → Fin k → ℝ, ∃ V : Fin k → Fin m → ℝ,
    ∀ i j, A i j = sInf (Set.range (fun t : Fin k => U i t + V t j))
```

Then define the rank-1 additive-separable predicate:

```lean
def AdditivelySeparable {n m : ℕ} (A : Fin n → Fin m → ℝ) : Prop :=
  ∃ p : Fin n → ℝ, ∃ q : Fin m → ℝ, ∀ i j, A i j = p i + q j
```

And the tropical 2×2 minor vanishing predicate:

```lean
def TropicalRankOneMinorCondition {n m : ℕ} (A : Fin n → Fin m → ℝ) : Prop :=
  ∀ i i' j j', A i j + A i' j' = A i j' + A i' j
```

### Primary theorem statements

The first exact theorem should be:

```lean
theorem minPlusFactorRankLE_one_iff_additivelySeparable
    {n m : ℕ} (A : Fin n → Fin m → ℝ) :
    MinPlusFactorRankLE 1 A ↔ AdditivelySeparable A := by
```

Then the structural characterization:

```lean
theorem additivelySeparable_iff_tropicalRankOneMinorCondition
    {n m : ℕ} [NeZero n] [NeZero m] (A : Fin n → Fin m → ℝ) :
    AdditivelySeparable A ↔ TropicalRankOneMinorCondition A := by
```

And hence the flagship synthesis theorem:

```lean
theorem minPlusFactorRankLE_one_iff_minorCondition
    {n m : ℕ} [NeZero n] [NeZero m] (A : Fin n → Fin m → ℝ) :
    MinPlusFactorRankLE 1 A ↔ TropicalRankOneMinorCondition A := by
```

You should also consider proving a normalized basepoint reconstruction theorem, which is mathematically central and likely the most reusable lemma:

```lean
theorem additive_separable_of_minorCondition
    {n m : ℕ} [NeZero n] [NeZero m]
    (A : Fin n → Fin m → ℝ)
    (hA : TropicalRankOneMinorCondition A) :
    ∃ i0 : Fin n, ∃ j0 : Fin m,
      let p : Fin n → ℝ := fun i => A i j0
      let q : Fin m → ℝ := fun j => A i0 j - A i0 j0
      ∀ i j, A i j = p i + q j := by
```

This theorem exhibits rank-1 matrices as exact potentials determined by one row and one column. It is the tropical analogue of “vanishing curl implies gradient potential” on a rectangular discrete grid.

---

## Why this is a breakthrough

This is not just a toy tropical algebra lemma. It formalizes a hidden unification of at least four domains:

1. **Tropical linear algebra:** rank-1 min-plus factorization.
2. **Discrete differential geometry:** vanishing mixed second difference / zero curvature.
3. **Monge arrays and optimization:** equality form of Monge structure.
4. **Graph potentials / cohomology:** every 1-cocycle on the complete bipartite grid is exact.

A successful formalization gives Aristotle a foundational platform for:
- tropical matrix rank theory,
- exact certificates for low tropical complexity,
- algorithmic recognition of separable costs,
- future tropical SVD / tropical NMF analogues,
- formal links to shortest-path semiring factorizations.

This is field-opening because the next theorems become obvious targets:
- tropical rank stratification by minor inequalities,
- uniqueness of normalized decompositions,
- stability of approximate rank-1 under bounded minor defects,
- algorithmic extraction of factors from certified minor identities.

---

## Build explicitly on catalog theorems

Even though the main proof is elementary, you should consciously connect to the existing catalog:

1. **`min_max_duality`** and **`negation_max_to_min`**  
   Use these to derive the max-plus analogue for free by negation:
   if `A` is min-plus rank 1, then `-A` is max-plus rank 1, and the same 2×2 condition is preserved under sign changes.  
   This should lead to a corollary theorem:
   ```lean
   theorem maxPlusRankLE_one_iff_minorCondition ...
   ```
   obtained with minimal new work.

2. **`finset_inf_add_right`**  
   If you choose a `Finset.univ.inf'` formulation instead of `sInf`, this lemma can help normalize expressions of the form
   \[
   \inf_t (U(i,t)+V(t,j))
   \]
   by pulling out constants in future generalizations. Even if not strictly necessary for `k = 1`, proving your statements in a way compatible with this lemma will pay off for rank ≤ `k`.

3. **`tropical_lattice_min_max`**  
   Use it as conceptual evidence that the codebase already treats tropical operations algebraically; your theorem upgrades this to a matrix-level structural law.

Do not merely cite these theorems by name. Integrate them into corollaries or helper lemmas so this file becomes a hub, not an isolated proof.

---

## Proof architecture: three viable strategies

### Strategy A: basepoint reconstruction from minor equalities
This is the most promising and should likely be the main formal proof.

**Step 1.** Pick base indices `i0 : Fin n`, `j0 : Fin m` using `[NeZero n] [NeZero m]`.  
Define
\[
p(i)=A(i,j0), \qquad q(j)=A(i0,j)-A(i0,j0).
\]

**Step 2.** Apply the minor condition with `(i,i0,j,j0)` to get
\[
A(i,j)+A(i0,j0)=A(i,j0)+A(i0,j).
\]
Rearrange in `ℝ`:
\[
A(i,j)=A(i,j0)+A(i0,j)-A(i0,j0)=p(i)+q(j).
\]

**Step 3.** Prove the converse by direct expansion:
if `A i j = p i + q j`, then both sides of the 2×2 identity equal
\[
p(i)+p(i')+q(j)+q(j').
\]

**Why this is best:**  
It is algebraically transparent, produces canonical witnesses, and immediately suggests normalization lemmas and uniqueness-up-to-constant theorems.

---

### Strategy B: reduce rank-1 factorization through `Fin 1`
This is the best route for the theorem
`MinPlusFactorRankLE 1 A ↔ AdditivelySeparable A`.

**Step 1.** Show that every function `Fin 1 → ℝ` is determined by its value at `0`, using extensionality:
```lean
have hU : ∀ i t, U i t = U i 0 := ...
have hV : ∀ t j, V t j = V 0 j := ...
```

**Step 2.** Prove that
\[
sInf(\{U(i,0)+V(0,j)\}) = U(i,0)+V(0,j)
\]
or, in the `Finset.inf'` formulation, that the infimum over a singleton finite set is the unique element.

**Step 3.** Set
\[
p(i)=U(i,0), \quad q(j)=V(0,j)
\]
and conclude additive separability. The reverse implication is immediate by defining constant-width-1 factor matrices.

**Why this matters:**  
This is the theorem that legitimizes the definition of tropical rank ≤ `k`; it proves the `k = 1` case is the exact expected notion, not an artifact of formal encoding.

---

### Strategy C: cocycle/cohomological formulation
This is more ambitious but highly reusable.

Define the defect
\[
\delta_A(i,i',j,j') := A(i,j)+A(i',j')-A(i,j')-A(i',j).
\]
Then rank-1 is exactly `δ_A = 0`.

**Step 1.** Introduce `delta₂` as a helper definition and prove:
```lean
delta₂ A i i' j j' = 0 ↔
A i j + A i' j' = A i j' + A i' j
```

**Step 2.** Show additive separability implies `delta₂ = 0` by ring simplification.

**Step 3.** Reconstruct potentials from `delta₂ = 0` using a basepoint.

**Why this is powerful:**  
It turns the theory into discrete curvature. Future approximate-rank results can then be stated as bounds on `|delta₂|`, opening a route to robust tropical factorization and certified near-separability.

---

## Recommended theorem dependency graph

A clean implementation order:

1. `AdditivelySeparable`
2. `TropicalRankOneMinorCondition`
3. `additivelySeparable_of_exists_vectors`
   ```lean
   theorem additivelySeparable_of_minPlusRankLE_one ...
   ```
4. `minorCondition_of_additivelySeparable`
5. `additivelySeparable_of_minorCondition`
6. `additivelySeparable_iff_tropicalRankOneMinorCondition`
7. `minPlusFactorRankLE_one_iff_additivelySeparable`
8. `minPlusFactorRankLE_one_iff_minorCondition`
9. max-plus dual corollaries via `min_max_duality` / `negation_max_to_min`
10. optional normalization/uniqueness lemmas

---

## Important edge cases and formal design decisions

### 1. Nonempty dimensions
The minor-condition-to-separability direction needs a chosen row and column. So either:
- assume `[NeZero n] [NeZero m]`, or
- use explicit hypotheses `h_n : 0 < n`, `h_m : 0 < m`.

Using `[NeZero n] [NeZero m]` is idiomatic and cleaner with `Fin`.

### 2. `ℝ` versus `WithTop ℝ`
For the first theorem, stay with `ℝ`.  
Do **not** overcomplicate the initial formalization with infinities. Once done, the obvious next leap is to `WithTop ℝ` for true tropical semiring semantics.

### 3. `sInf` versus `Finset.inf'`
For immediate proof ergonomics, `sInf (Set.range ...)` may be easier conceptually but can trigger order-theoretic obligations.  
For finite index types, `Finset.univ.inf'` can be more computationally tractable, but requires a witness that the finset is nonempty. Since `Fin k` is empty when `k = 0`, you may want:
- either a specialized definition for `k = 1`,
- or define `MinPlusFactorRankLE` only for `k > 0`,
- or use `Option`/`WithTop` carefully.

For this project, prioritize getting the rank-1 theorem proved cleanly over maximal generality.

A practical variant:

```lean
def MinPlusFactorRankLE' (k : ℕ) {n m : ℕ} (hk : 0 < k) (A : Fin n → Fin m → ℝ) : Prop :=
  ∃ U : Fin n → Fin k → ℝ, ∃ V : Fin k → Fin m → ℝ,
    ∀ i j, A i j = Finset.univ.inf' (by simpa using Finset.univ_nonempty)
      (fun t : Fin k => U i t + V t j)
```

Then the rank-1 theorem specializes with `hk : 0 < 1`.

---

## High-value corollaries to include if time permits

### 1. Normalization uniqueness up to additive gauge
If
\[
A(i,j)=p(i)+q(j)=p'(i)+q'(j),
\]
then there exists `c : ℝ` such that
\[
p'(i)=p(i)+c,\qquad q'(j)=q(j)-c.
\]

Lean target:
```lean
theorem additive_decomposition_unique_up_to_constant
    {n m : ℕ} [NeZero n] [NeZero m]
    {A : Fin n → Fin m → ℝ}
    {p p' : Fin n → ℝ} {q q' : Fin m → ℝ}
    (h : ∀ i j, A i j = p i + q j)
    (h' : ∀ i j, A i j = p' i + q' j) :
    ∃ c : ℝ, (∀ i, p' i = p i + c) ∧ ∀ j, q' j = q j - c := by
```

This is the gauge symmetry of tropical rank-1 factorization.

### 2. Row-difference invariance characterization
Additive separability is equivalent to:
for all `i i'`, the function `j ↦ A i j - A i' j` is constant in `j`.

This is an excellent alternate characterization and useful for algorithms.

### 3. Max-plus dual theorem
Using `negation_max_to_min` and `min_max_duality`, derive the exact max-plus analogue. This creates immediate symmetry in the library.

---

## Cross-domain connections you should make explicit in comments/docstrings

1. **Discrete Hodge theory / cohomology**  
   The minor condition is exactness of a 1-cocycle on the grid graph / complete bipartite incidence structure.

2. **Optimization / Monge arrays**  
   Equality in the Monge relation gives exact separability. Inequality is the gateway to transport and dynamic programming; equality is the rigid rank-1 stratum.

3. **Machine learning / low-rank structure discovery**  
   Tropical rank-1 matrices model exact decompositions of cost tables and can serve as symbolic certificates for latent additive structure.

4. **Mathematical physics / zero curvature**  
   The 2×2 identity is a discrete zero-curvature equation. Higher tropical rank should be viewed as a superposition principle in idempotent geometry.

5. **Category-theoretic semantics**  
   Additive separability is a decoupling law: a bivariate cost factors through a product of one-variable potentials. This is a tropical analogue of tensor rank-1.

These connections are not fluff; they should inform naming, theorem comments, and future theorem statements.

---

## Suggested helper lemmas

You will probably want some or all of:

```lean
lemma fin1_eq_zero (t : Fin 1) : t = 0 := by
  fin_cases t
```

```lean
lemma sInf_range_fin_one (f : Fin 1 → ℝ) :
    sInf (Set.range f) = f 0 := by
```

or the `Finset.inf'` analogue:

```lean
lemma finset_inf'_univ_fin_one (f : Fin 1 → ℝ) :
    Finset.univ.inf' (by simp) f = f 0 := by
```

and an algebraic expansion lemma:

```lean
lemma minorCondition_of_additive
    {n m : ℕ} {p : Fin n → ℝ} {q : Fin m → ℝ} :
    TropicalRankOneMinorCondition (fun i j => p i + q j) := by
```

These lemmas will reduce proof brittleness.

---

## Most promising implementation plan

1. Start with `AdditivelySeparable` and `TropicalRankOneMinorCondition`.
2. Prove `minorCondition_of_additive` by `ring`.
3. Prove `additivelySeparable_of_minorCondition` using basepoints from `[NeZero n] [NeZero m]`.
4. Package the equivalence.
5. Only then define `MinPlusFactorRankLE` and prove the `k = 1` theorem.
6. Finish with the synthesized equivalence and a max-plus dual corollary.

This order minimizes time spent wrestling with `inf` machinery before the key geometry is secured.

---

## Application keywords

`tropical linear algebra`, `min-plus rank`, `max-plus duality`, `tropical minors`, `Monge arrays`, `discrete curvature`, `zero-curvature equation`, `cohomological exactness`, `low-rank factorization`, `idempotent analysis`, `optimization`, `symbolic certification`

---

## Deliverables

1. A fully formalized Lean file proving the three main equivalences.
2. At least one reusable normalization or uniqueness lemma.
3. A max-plus dual corollary using the existing negation/min-max catalog theorems.
4. Minimize `sorry`; if any remain, isolate them into tiny helper lemmas with explicit comments.
5. Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - approximate rank-1 from bounded minor defects,
   - tropical rank stratification via higher minors,
   - `WithTop ℝ` extension,
   - algorithmic extraction and certification procedures,
   - tropical convex geometry of rank-`k` factorizations.

Be bold: this file should become the seed crystal for a formal tropical matrix theory, not just a solved exercise.

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
