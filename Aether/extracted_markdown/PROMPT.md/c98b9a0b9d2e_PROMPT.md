## Assignment: Entanglement wedge

**Mode:** prove

Prove genuinely new theorems that turn the informal “entanglement wedge” intuition into a precise finite tropical reconstruction theory in Lean 4. The target is not a metaphorical restatement, but a mathematically sharp boundary/bulk detectability theorem on finite weighted graphs with a tropical distance functional. Build explicitly on the catalog bridge theorem `reconstructs_bulk_from_boundary_profiles` and, where useful, on `gl3_value_determined_by_boundary_and_levi`, `tropical_security_from_norm_bound`, and the tropical logical identities such as `bool_and_as_tropical_max`.

Minimize sorry. If a definition is missing, define it canonically and prove the first structural lemmas immediately.

---

## Research Direction

Formalize and prove that for a finite weighted bulk-boundary geometry, the **entanglement wedge** of a boundary region `B` is the set of bulk vertices that are strictly closer (in tropical/min-plus distance) to `B` than to its boundary complement, and that any surgery supported inside this wedge is detectable from boundary data restricted to `B`.

This is the finite tropical analogue of an entanglement wedge reconstruction principle from holography, but here it should become a rigorous theorem in discrete mathematics: **strict tropical separation implies localized reconstructability**.

The breakthrough is not “define a wedge.” The breakthrough is:

1. proving a **sharp wedge membership criterion** from min-plus distance profiles,
2. proving a **locality theorem** saying surgeries outside the wedge cannot affect `B`-restricted observables under suitable shielding hypotheses,
3. proving a **detectability theorem** saying surgeries inside the wedge necessarily alter a boundary profile visible from `B`.

This would open a new field of **tropical holographic reconstruction on finite networks**, connecting min-plus geometry, graph algorithms, causal inference, and information localization.

---

## Core Mathematical Framing

Work with a finite vertex type `V`, edge weights in `ℝ`, and a tropical distance
`dist : V → V → ℝ` satisfying the usual metric or pseudometric axioms available or definable in Lean.

Let:
- `boundary : Finset V`
- `bulk : Finset V`
- `B : Finset V` with `B ⊆ boundary`
- `Bᶜ := boundary \ B`

Define the tropical distance from a vertex to a boundary region by
\[
d_B(v) := \inf_{b \in B} dist(v,b),
\]
implemented over `Finset.inf'` or a `sInf` over a finite coercion, depending on what is technically cleaner in Lean.

Then define the entanglement wedge:
\[
\operatorname{Wedge}(B) := \{v \in bulk \mid d_B(v) < d_{B^\complement}(v)\}.
\]

The strict inequality is crucial: it gives a robust “phase separation” and avoids ambiguous tie vertices.

A surgery should be modeled as a perturbation of bulk data or edge weights supported on a set `S ⊆ bulk`. The strongest first theorem will likely treat surgery as a change in a bulk labeling
`φ : V → ℝ` to `φ' : V → ℝ` with support inside `S`, together with a boundary observation map
\[
Obs_B(\phi)(b) \quad \text{or} \quad Profile_B(\phi)(v),
\]
depending on which interface is easier to connect to `reconstructs_bulk_from_boundary_profiles`.

The key principle to formalize:

- **inside wedge ⇒ detectable from B**
- **outside wedge with shielding ⇒ invisible to B**

The second statement may require an additional geometric hypothesis; the first should be provable under a strict-separation and reconstruction hypothesis.

---

## Precise Theorem Targets

You should aim to formalize at least two of the following, and ideally all three.

### 1. Wedge separation theorem

**Mathematical statement**

For any bulk vertex `v`, if `v ∈ Wedge(B)`, then there exists a positive separation gap
\[
\delta_v := d_{B^\complement}(v) - d_B(v) > 0.
\]
Moreover, if a perturbation changes all distances from `v` to `B` by less than `\delta_v/2` and likewise changes distances to `B^\complement` by less than `\delta_v/2`, wedge membership is stable.

This gives a robustness theorem: entanglement wedges are stable under sufficiently small tropical perturbations.

**Lean 4 type signature sketch**
```lean
def distToFinset {V : Type*} [LinearOrder ℝ]
    (d : V → V → ℝ) (s : Finset V) (hs : s.Nonempty) (v : V) : ℝ :=
  s.inf' hs (fun b => d v b)

def entanglementWedge {V : Type*} [DecidableEq V]
    (bulk boundary B : Finset V) (d : V → V → ℝ) : Finset V :=
  bulk.filter (fun v =>
    let Bc := boundary \ B
    if hB : B.Nonempty then
      if hBc : (boundary \ B).Nonempty then
        distToFinset d B hB v < distToFinset d (boundary \ B) hBc v
      else
        False
    else
      False)

theorem mem_entanglementWedge_iff
    {V : Type*} [DecidableEq V]
    {bulk boundary B : Finset V} {d : V → V → ℝ} {v : V}
    (hv : v ∈ bulk)
    (hB : B.Nonempty)
    (hBc : (boundary \ B).Nonempty) :
    v ∈ entanglementWedge bulk boundary B d ↔
      distToFinset d B hB v < distToFinset d (boundary \ B) hBc v := by
  sorry
```

A stronger robustness target:

```lean
theorem wedge_membership_stable_under_uniform_perturbation
    {V : Type*} [DecidableEq V]
    {bulk boundary B : Finset V}
    {d d' : V → V → ℝ} {v : V}
    (hv : v ∈ bulk)
    (hB : B.Nonempty)
    (hBc : (boundary \ B).Nonempty)
    (hmem : v ∈ entanglementWedge bulk boundary B d)
    (hεB : ∀ b ∈ B, |d v b - d' v b| < ε)
    (hεBc : ∀ b ∈ boundary \ B, |d v b - d' v b| < ε)
    (hgap : 2 * ε < distToFinset d (boundary \ B) hBc v - distToFinset d B hB v) :
    v ∈ entanglementWedge bulk boundary B d' := by
  sorry
```

This theorem would be a tropical analogue of stability of causal/entanglement regions under perturbation.

---

### 2. Boundary complement exclusion theorem

**Mathematical statement**

If `v` is strictly closer to `Bᶜ` than to `B`, then `v ∉ Wedge(B)`. More interestingly, if every shortest path from `v` to `B` passes through a separator `Σ` whose vertices are all at least as close to `Bᶜ` as to `B`, then `v ∉ Wedge(B)`.

This is a tropical barrier theorem: separators control wedge penetration.

**Lean 4 type signature sketch**
```lean
theorem not_mem_entanglementWedge_of_ge
    {V : Type*} [DecidableEq V]
    {bulk boundary B : Finset V} {d : V → V → ℝ} {v : V}
    (hv : v ∈ bulk)
    (hB : B.Nonempty)
    (hBc : (boundary \ B).Nonempty)
    (hge : distToFinset d (boundary \ B) hBc v ≤ distToFinset d B hB v) :
    v ∉ entanglementWedge bulk boundary B d := by
  sorry
```

This looks elementary, but it becomes powerful when used as the “negative direction” in a more structural theorem about shielding or separators.

---

### 3. Detectability of wedge-supported surgery

This is the central theorem.

Model a bulk state by `φ : V → ℝ`, and a boundary observation profile over `B` by a min-plus response such as
\[
Obs_B(\phi)(b) := \inf_{v \in bulk} (\phi(v) + dist(v,b)).
\]
This is a tropical convolution / distance transform, and it is extremely Lean-friendly over finite sets.

Now let a surgery be a perturbation `φ ↦ φ'` supported in `S ⊆ bulk`, i.e.
\[
\forall v \notin S,\ \phi'(v)=\phi(v).
\]

Then the ideal theorem is:

**Mathematical statement**

Assume:
- `S ⊆ Wedge(B)`,
- for each `v ∈ S`, there exists `b ∈ B` such that the infimum in `Obs_B(φ)(b)` is uniquely achieved at `v`,
- and surgery changes `φ(v)` at some such witness vertex.

Then `Obs_B(φ) ≠ Obs_B(φ')`.

In words: a surgery supported in the wedge, at a boundary-visible witness vertex, is detectable from `B`.

**Lean 4 type signature sketch**
```lean
def boundaryObs
    {V : Type*} [DecidableEq V]
    (bulk B : Finset V) (d : V → V → ℝ) (hbulk : bulk.Nonempty)
    (φ : V → ℝ) (b : V) : ℝ :=
  bulk.inf' hbulk (fun v => φ v + d v b)

def supportOn
    {V : Type*} (S : Set V) (φ φ' : V → ℝ) : Prop :=
  ∀ ⦃v⦄, v ∉ S → φ' v = φ v

theorem wedge_surgery_detectable
    {V : Type*} [DecidableEq V]
    {bulk boundary B : Finset V} {d : V → V → ℝ}
    (hbulk : bulk.Nonempty)
    {φ φ' : V → ℝ} {S : Set V}
    (hS : S ⊆ ↑(entanglementWedge bulk boundary B d))
    (hsupp : supportOn S φ φ')
    (hwitness :
      ∃ v ∈ bulk, v ∈ S ∧ ∃ b ∈ B,
        (∀ w ∈ bulk, w ≠ v → φ v + d v b < φ w + d w b))
    (hchange : ∃ v, v ∈ S ∧ φ' v ≠ φ v) :
    ∃ b ∈ B, boundaryObs bulk B d hbulk φ b ≠ boundaryObs bulk B d hbulk φ' b := by
  sorry
```

This is already nontrivial and important. It converts wedge membership into operational observability via a tropical argmin uniqueness condition.

---

### 4. Reconstruction theorem from restricted boundary profiles

This is the highest-value bridge theorem if you can connect it to the catalog result `reconstructs_bulk_from_boundary_profiles`.

**Mathematical statement**

Assume a class of bulk states `φ` is reconstructible from full boundary profiles by `reconstructs_bulk_from_boundary_profiles`. Prove a localized version:

If `supp(φ - φ') ⊆ Wedge(B)` and `Obs_B(φ) = Obs_B(φ')`, then `φ = φ'` on `Wedge(B)`.

Or stronger, under a suitable injectivity hypothesis:
\[
Obs_B(\phi)=Obs_B(\phi') \implies \phi|_{Wedge(B)}=\phi'|_{Wedge(B)}.
\]

This is the finite tropical analogue of entanglement wedge reconstruction proper.

**Lean 4 type signature sketch**
```lean
theorem wedge_reconstruction_from_boundary_profiles
    {V : Type*} [DecidableEq V]
    {bulk boundary B : Finset V} {d : V → V → ℝ}
    (hbulk : bulk.Nonempty)
    {φ φ' : V → ℝ}
    (hinj :
      ∀ {v : V}, v ∈ entanglementWedge bulk boundary B d →
        ∃ b ∈ B, ∀ w ∈ bulk, w ≠ v →
          φ v + d v b < φ w + d w b)
    (hobs :
      ∀ b ∈ B, boundaryObs bulk B d hbulk φ b =
               boundaryObs bulk B d hbulk φ' b) :
    ∀ v ∈ entanglementWedge bulk boundary B d, φ v = φ' v := by
  sorry
```

This theorem would be a direct formal bridge between tropical geometry and holographic reconstruction.

---

## Why this is a breakthrough

This project opens a formal theory of **tropical holography on finite graphs**. That is not an incremental graph lemma; it is a new conceptual machine.

It would establish that:

- tropical distance profiles encode localized interior information,
- strict min-plus separation creates reconstructible “wedges,”
- boundary observables obey locality principles analogous to holographic duality,
- reconstruction theorems can be stated and checked algorithmically on finite combinatorial structures.

This creates a new interface among:

- **tropical geometry**: min-plus distance transforms and argmin structures,
- **graph theory**: separators, geodesics, Voronoi cells, shortest-path geometry,
- **information theory**: localization, detectability, and boundary observability,
- **mathematical physics**: discrete analogues of entanglement wedge reconstruction,
- **formal methods**: certified reconstruction and security guarantees in Lean.

The real opportunity is to make “holography” into a theorem schema for finite metric structures, not just a physics analogy.

---

## How to build on the catalog theorems

### 1. `reconstructs_bulk_from_boundary_profiles`
This is your most important bridge. Use it as the global injectivity engine, then prove that wedge hypotheses imply the local injectivity assumptions needed on the restricted boundary subset `B`.

Concretely:
- first define `boundaryObs` as a finite tropical profile,
- show that equality of these profiles on `B` is enough to pin down states on the wedge,
- if the catalog theorem is stated globally, derive your local theorem by restricting to wedge-supported perturbations and proving that only `B` can witness them.

### 2. `gl3_value_determined_by_boundary_and_levi`
Use this as a model of “interior data determined by structured boundary data.” Even if the ambient objects differ, the philosophical pattern is identical: a constrained internal object is fixed by a boundary-facing profile plus a decomposition datum. If possible, formulate your wedge reconstruction as a finite min-plus analogue of Levi/boundary determination.

### 3. `tropical_security_from_norm_bound`
This can support a robustness theorem: if surgery magnitude is norm-bounded below a wedge gap threshold, boundary observables are stable or unstable in a controlled way. This is especially relevant for the perturbative wedge-membership stability theorem.

### 4. `bool_and_as_tropical_max` and `tropical_and_bound`
These can help if you encode logical visibility predicates through tropical operations. For example, “detectable from `B` and invisible from `Bᶜ`” can often be represented by min/max combinations of score functions. This may give a slick algebraic reformulation of wedge membership.

---

## Proof strategy options

### Strategy A: Finite tropical Voronoi geometry
Most promising for the first pass.

1. Define `distToFinset` and `entanglementWedge` using `Finset.inf'`.
2. Prove elementary order lemmas:
   - membership iff strict distance inequality,
   - non-membership under reversed inequality,
   - stability under perturbation by gap estimates.
3. Define `boundaryObs` as a finite tropical convolution and prove that a unique argmin witness inside the wedge forces detectability of surgery.

Why this is promising:
- fully finite,
- compatible with Lean’s `Finset` machinery,
- avoids heavy graph formalization initially,
- already rich enough to prove a real theorem.

### Strategy B: Shortest-path / separator formalization on weighted graphs
Best for deeper geometric significance.

1. Define a weighted graph and path length, then `dist` as shortest path length.
2. Characterize wedge membership via weighted Voronoi cells relative to `B` and `Bᶜ`.
3. Introduce separator sets `Σ` and prove barrier theorems showing when vertices cannot lie in the wedge.
4. Use path-based witnesses to prove detectability/invisibility theorems.

Why this matters:
- gives geometric content beyond abstract finite minima,
- links directly to causal graphs and network science,
- opens algorithmic corollaries.

### Strategy C: Reconstruction-by-injectivity transfer
Best if `reconstructs_bulk_from_boundary_profiles` is strong and reusable.

1. Identify the exact observation map in the catalog theorem.
2. Show your `boundaryObs` is an instance, restriction, or corollary of that map.
3. Prove that wedge-supported perturbations are determined by `B`-restricted observations using the catalog theorem plus a support lemma.
4. Derive localized reconstruction and detectability.

Why this could be revolutionary:
- it turns an existing global reconstruction theorem into a local holographic reconstruction theorem,
- it is the cleanest way to create a genuine bridge result rather than an isolated new definition.

**Recommendation:** Start with Strategy A to get robust Lean traction, then elevate to Strategy C for the strongest theorem, and finally add pieces of Strategy B if separator geometry becomes manageable.

---

## Concrete implementation advice in Lean 4

Use concrete finite types first:
- `V := Fin n` or a finite type with `[Fintype V] [DecidableEq V]`
- `bulk boundary B : Finset V`
- `d : V → V → ℝ`

Prefer `Finset.inf'` over general `sInf` when possible, because nonemptiness hypotheses are explicit and proofs are cleaner.

Good first definitions:
```lean
def distToFinset ...
def entanglementWedge ...
def boundaryObs ...
def supportOn ...
```

Good first lemmas:
```lean
theorem distToFinset_le ...
theorem le_distToFinset_of_forall_le ...
theorem mem_entanglementWedge_iff ...
theorem not_mem_entanglementWedge_of_ge ...
theorem boundaryObs_eq_of_support_disjoint_and_argmin_outside ...
theorem boundaryObs_ne_of_unique_argmin_changed ...
```

If shortest-path formalization is too heavy, abstract over `d` first and only later add hypotheses such as triangle inequality or realization by paths.

Avoid overcommitting to a graph structure before the min-plus profile theorems are in place.

---

## Cross-domain connections to emphasize

1. **Holography / mathematical physics**  
   Entanglement wedge reconstruction becomes a theorem about finite tropical observables. This is a discrete, certifiable analogue of bulk reconstruction.

2. **Tropical geometry**  
   The observation map `φ ↦ (b ↦ inf_v (φ(v)+d(v,b)))` is a tropical linear transform. Wedges are strict tropical Voronoi cells relative to boundary partitions.

3. **Information theory**  
   Detectability and invisibility are localization properties of an observation channel. The wedge is an information-access region defined by tropical signal propagation.

4. **Network science / algorithms**  
   Wedge membership is computable by shortest-path and Voronoi methods. This suggests certified algorithms for local reconstruction in sensor networks.

5. **Security / robustness**  
   Through `tropical_security_from_norm_bound`, one can interpret wedge stability as a certified robustness property against bounded perturbations.

6. **Representation-theoretic analogy**  
   Via `gl3_value_determined_by_boundary_and_levi`, there is a conceptual bridge between algebraic boundary determination and tropical geometric boundary determination.

---

## Application keywords

tropical geometry, entanglement wedge, holographic reconstruction, min-plus algebra, boundary observables, finite metric spaces, shortest-path geometry, Voronoi decomposition, graph reconstruction, information localization, causal holography, tropical convolution, robust reconstruction, certified detectability, formalized mathematical physics

---

## Deliverables

1. Lean 4 definitions for:
   - `distToFinset`
   - `entanglementWedge`
   - `boundaryObs`
   - `supportOn`

2. Lean 4 proofs of at least:
   - `mem_entanglementWedge_iff`
   - `not_mem_entanglementWedge_of_ge`
   - one nontrivial detectability theorem such as `wedge_surgery_detectable`

3. If feasible, a localized reconstruction theorem building on `reconstructs_bulk_from_boundary_profiles`

4. `FUTURE_DIRECTIONS.md` with **3–5 concrete next steps**, each containing:
   - exact theorem statement,
   - likely Lean definitions needed,
   - 2 proof strategies,
   - cross-domain significance.

This file is mandatory and critical. It should drive the next cycle toward separator theorems, algorithmic wedge computation, and a full tropical holography package.

---

## Team Directive

Create a research team workflow:
- one thread for formal definitions and API design,
- one thread for proving finite infimum/order lemmas,
- one thread for bridge analysis with `reconstructs_bulk_from_boundary_profiles`,
- one thread for experiments on tiny `Fin n` examples to test detectability conjectures,
- one thread for writing `FUTURE_DIRECTIONS.md` as soon as the first theorem stabilizes.

Iterate aggressively. If the strongest reconstruction theorem is blocked, prove the detectability theorem first and isolate the missing injectivity lemma as the next frontier.

The goal is to make finite tropical entanglement wedges mathematically real.

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
