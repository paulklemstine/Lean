## Assignment: Grokking as Tropical Phase Transition in Neural Loss Landscapes

Mode: **prove**

Prove genuinely new theorems that turn the slogan “grokking is a phase transition” into a precise tropical-geometric statement in Lean 4. Build on the catalog theorems, minimize sorry, and do not settle for a metaphor: define a mathematically sharp tropical order parameter, prove a threshold/collapse theorem, and connect delayed generalization to corner-locus crossing along a discrete training trajectory.

This direction is potentially field-opening because it would create a certified bridge between:
- neural training dynamics,
- tropical geometry of piecewise-linear loss models,
- phase transitions/order parameters from statistical mechanics,
- margin collapse and decision-boundary geometry from learning theory.

If successful, this opens a new program: **tropical statistical mechanics of training dynamics**.

---

### Core Vision

The breakthrough target is to formalize a theorem of the following shape:

> Along a training trajectory for a tropicalized neural model, if the tropical order parameter remains bounded away from zero then the classifier is trapped in a pre-grokking regime; when the trajectory crosses a corner locus of the tropical loss potential, the min-plus margin to the decision boundary collapses discontinuously enough to force a sharp change in generalization behavior.

The key is not to model all of SGD. The key is to isolate a discrete, certifiable mathematical skeleton:
1. a tropical score function,
2. a tropical margin / distance-to-boundary,
3. an order parameter extracted from score gaps,
4. a theorem that corner-locus crossing induces a qualitative change.

This should be done with concrete finite types and finite datasets.

---

## Precise Formalization Targets

Work with a finite input space `Fin n → ℝ`, a finite class set `Fin k`, and a finite dataset `Finset (X × Y)` where `X := Fin n → ℝ` and `Y := Fin k`.

Define a tropical score family
```lean
def TropScore (n k m : ℕ) := Fin k → Fin m → (Fin n → ℝ)
```
where `W c j` is the affine coefficient vector for class `c` and piece `j`, and define the class score at input `x` by a min-plus or max-plus tropical polynomial. For formal convenience, use max-plus first if needed:
```lean
def classScore {n k m : ℕ} (W : TropScore n k m) (b : Fin k → Fin m → ℝ)
    (c : Fin k) (x : Fin n → ℝ) : ℝ :=
  Finset.sup' (Finset.univ.image (fun j : Fin m => b c j + ∑ i, W c j i * x i)) ?hne
```
or use `sInf`/`iSup` depending on the available lemmas. If max-plus is easier in Mathlib, do max-plus and define the dual min-plus distance separately.

Then define:
- predicted label = argmax score,
- score gap between top two classes,
- tropical margin / min-plus distance proxy to the decision boundary,
- order parameter as an aggregate over the training set.

A robust and Lean-friendly choice is:

```lean
def scoreGap {n k m : ℕ} (W : TropScore n k m) (b : Fin k → Fin m → ℝ)
    (x : Fin n → ℝ) : ℝ :=
  let scores : Fin k → ℝ := fun c => classScore W b c x
  (Finset.univ.sup' ?hne scores) -
  (Finset.sup' (Finset.univ.erase (argmax scores)) ?hne2 scores)
```

If argmax is too cumbersome, use a pairwise-gap formulation instead:
```lean
def pairGap {n k m : ℕ} (W : TropScore n k m) (b : Fin k → Fin m → ℝ)
    (x : Fin n → ℝ) : ℝ :=
  sInf {r | ∃ c ≠ c', r = |classScore W b c x - classScore W b c' x|}
```
But for formal proof engineering, an even simpler and stronger route is to define the “distance-to-corner” by the minimum pairwise score difference:
```lean
def tropicalBoundaryGap {n k m : ℕ} (W : TropScore n k m) (b : Fin k → Fin m → ℝ)
    (x : Fin n → ℝ) : ℝ :=
  Finset.inf' (Finset.univ.product (Finset.univ.erase ?c)) ?hne
    (fun p => |classScore W b p.1 x - classScore W b p.2 x|)
```
and then aggregate:
```lean
def tropicalOrderParameter {n k m : ℕ}
    (S : Finset ((Fin n → ℝ) × Fin k))
    (W : TropScore n k m) (b : Fin k → Fin m → ℝ) : ℝ :=
  (∑ z in S, tropicalBoundaryGap W b z.1) / S.card
```
or use a sum without division to avoid coercion friction.

---

## Breakthrough Theorem Targets

### Theorem A: Corner-Locus Characterization of Zero Tropical Margin

Prove that vanishing tropical boundary gap is equivalent to lying on a corner locus of the pairwise class-difference tropical polynomial.

**Mathematical statement**
For each pair of classes `c ≠ c'`, define
`Δ_{c,c'}(x) = classScore W b c x - classScore W b c' x`.
Then:
- if `tropicalBoundaryGap W b x = 0`, there exist `c ≠ c'` such that `Δ_{c,c'}(x) = 0`,
- conversely, if some pairwise class gap vanishes, then `tropicalBoundaryGap W b x = 0`.

This is the certifiable tropical decision-boundary theorem: the decision boundary is exactly the corner locus of pairwise tropical score differences.

A Lean-oriented signature could be:

```lean
theorem tropicalBoundaryGap_eq_zero_iff_exists_pair_eq
    {n k m : ℕ} (hk : 1 < k)
    (W : TropScore n k m) (b : Fin k → Fin m → ℝ)
    (x : Fin n → ℝ) :
    tropicalBoundaryGap W b x = 0 ↔
      ∃ c c' : Fin k, c ≠ c' ∧ classScore W b c x = classScore W b c' x
```

Why this matters:
This theorem converts the vague phrase “crossing the decision boundary” into a tropical-geometric statement about corner loci. It is the foundational bridge theorem.

---

### Theorem B: Order Parameter Collapse at a Tropical Phase Transition

Use a discrete training path `θ : Fin T → Params` where `Params` packages `W, b`. Define the order parameter at time `t`:
```lean
def OP (t : Fin T) : ℝ := tropicalOrderParameter S (θ t).W (θ t).b
```

Prove a threshold theorem: if at some step the trajectory crosses a corner locus on at least one sample and the boundary gap is monotone nonincreasing nearby, then the order parameter drops.

A precise theorem you can realistically formalize:

```lean
theorem order_parameter_drop_of_corner_crossing
    {n k m T : ℕ}
    (S : Finset ((Fin n → ℝ) × Fin k))
    (θ : Fin T → (TropScore n k m × (Fin k → Fin m → ℝ)))
    {t₁ t₂ : Fin T}
    (hle : t₁ ≤ t₂)
    (hmono : ∀ t u, t₁ ≤ t → t ≤ u → u ≤ t₂ →
      tropicalOrderParameter S (θ u).1 (θ u).2 ≤
      tropicalOrderParameter S (θ t).1 (θ t).2)
    (hcross :
      ∃ t : Fin T, t₁ ≤ t ∧ t ≤ t₂ ∧
        ∃ x c c', x ∈ S.image Prod.fst ∧ c ≠ c' ∧
          classScore (θ t).1 (θ t).2 c x =
          classScore (θ t).1 (θ t).2 c' x) :
    tropicalOrderParameter S (θ t₂).1 (θ t₂).2 ≤
    tropicalOrderParameter S (θ t₁).1 (θ t₁).2
```

This is a minimal theorem. But push further to a **strict** collapse theorem under a witness of positive-to-zero gap transition:

```lean
theorem strict_order_parameter_drop_of_positive_to_zero_gap
    {n k m T : ℕ}
    (S : Finset ((Fin n → ℝ) × Fin k))
    (θ : Fin T → (TropScore n k m × (Fin k → Fin m → ℝ)))
    {t₁ t₂ : Fin T}
    (hcard : 0 < S.card)
    (hwitness :
      ∃ x, x ∈ S.image Prod.fst ∧
        0 < tropicalBoundaryGap (θ t₁).1 (θ t₁).2 x ∧
        tropicalBoundaryGap (θ t₂).1 (θ t₂).2 x = 0)
    (hnoninc :
      ∀ x, x ∈ S.image Prod.fst →
        tropicalBoundaryGap (θ t₂).1 (θ t₂).2 x ≤
        tropicalBoundaryGap (θ t₁).1 (θ t₁).2 x) :
    tropicalOrderParameter S (θ t₂).1 (θ t₂).2 <
    tropicalOrderParameter S (θ t₁).1 (θ t₁).2
```

Why this matters:
This is the actual “phase transition” theorem. It turns grokking onset into a measurable collapse of a tropical order parameter.

---

### Theorem C: Delayed Generalization as Geodesic Corner Crossing

Do not over-model geodesics in a metric geometry sense if that becomes too heavy. Define a discrete tropical geodesic as coordinatewise linear interpolation in parameter space together with piecewise-linear tropical score evolution. Then prove:

> If a discrete parameter path from memorizing regime to generalizing regime crosses a corner locus, then there exists an intermediate time at which some sample has zero pairwise class gap.

A Lean-friendly theorem:

```lean
theorem exists_zero_gap_on_discrete_geodesic_of_label_change
    {n k m T : ℕ}
    (θ : Fin T → (TropScore n k m × (Fin k → Fin m → ℝ)))
    (x : Fin n → ℝ) (c c' : Fin k)
    (hstart : classScore (θ 0).1 (θ 0).2 c x <
              classScore (θ 0).1 (θ 0).2 c' x)
    (hend : classScore (θ (Fin.last T)).1 (θ (Fin.last T)).2 c' x <
            classScore (θ (Fin.last T)).1 (θ (Fin.last T)).2 c x)
    (hstep_cont :
      ∀ t : Fin (T-1),
        |(classScore (θ (Fin.castSucc t)).1 (θ (Fin.castSucc t)).2 c x
         - classScore (θ (Fin.castSucc t)).1 (θ (Fin.castSucc t)).2 c' x)
        -
        (classScore (θ t.succ).1 (θ t.succ).2 c x
         - classScore (θ t.succ).1 (θ t.succ).2 c' x)| ≤ ε) :
    ∃ t : Fin T,
      classScore (θ t).1 (θ t).2 c x =
      classScore (θ t).1 (θ t).2 c' x
```

This may need a discrete intermediate-value lemma for sign changes under sufficiently fine paths, or a simpler combinatorial sign-flip statement if exact equality is built into the path definition.

A more feasible exact theorem is to define the path so each pairwise gap changes by additive increments in a finite ordered set, then sign change forces zero by finiteness. If reals are used, exact equality may need stronger assumptions. So consider a theorem with hypotheses explicitly including piecewise-affine exact crossing:
```lean
(haffine : ∃ a b, ∀ t, gap t = a * (t : ℝ) + b)
```
Then use linear algebra to force a root.

Why this matters:
This theorem captures “delayed generalization” as a geometric event, not just a training curve anecdote.

---

## Lean 4 Type Signature Suggestions

Use concrete structures to keep the project formalizable.

```lean
structure TropParams (n k m : ℕ) where
  W : Fin k → Fin m → Fin n → ℝ
  b : Fin k → Fin m → ℝ
```

```lean
def classScore (P : TropParams n k m) (c : Fin k) (x : Fin n → ℝ) : ℝ := ...
def tropicalBoundaryGap (P : TropParams n k m) (x : Fin n → ℝ) : ℝ := ...
def tropicalOrderParameter
  (S : Finset ((Fin n → ℝ) × Fin k)) (P : TropParams n k m) : ℝ := ...
```

Main theorem signatures:

```lean
theorem tropicalBoundaryGap_nonneg
    {n k m : ℕ} (P : TropParams n k m) (x : Fin n → ℝ) :
    0 ≤ tropicalBoundaryGap P x
```

```lean
theorem tropicalBoundaryGap_eq_zero_iff_exists_pair_eq
    {n k m : ℕ} (hk : 1 < k) (P : TropParams n k m) (x : Fin n → ℝ) :
    tropicalBoundaryGap P x = 0 ↔
      ∃ c c' : Fin k, c ≠ c' ∧ classScore P c x = classScore P c' x
```

```lean
theorem tropicalOrderParameter_nonneg
    {n k m : ℕ}
    (S : Finset ((Fin n → ℝ) × Fin k))
    (P : TropParams n k m) :
    0 ≤ tropicalOrderParameter S P
```

```lean
theorem strict_order_parameter_drop_of_positive_to_zero_gap
    {n k m : ℕ}
    (S : Finset ((Fin n → ℝ) × Fin k))
    (hS : 0 < S.card)
    (P Q : TropParams n k m)
    (hmono :
      ∀ x, x ∈ S.image Prod.fst →
        tropicalBoundaryGap Q x ≤ tropicalBoundaryGap P x)
    (hwitness :
      ∃ x, x ∈ S.image Prod.fst ∧
        0 < tropicalBoundaryGap P x ∧
        tropicalBoundaryGap Q x = 0) :
    tropicalOrderParameter S Q < tropicalOrderParameter S P
```

If averages are annoying, replace with unnormalized sum:
```lean
def tropicalOrderSum ...
```
and prove the strict inequality there first.

---

## How to Build on Existing Verified Theorems

You already have:
1. `order_parameter_predicts_grokking`
2. `tropical_double_descent_phase_transition`
3. `tropical_plus_distributes_over_min`
4. `max_plus_order_preserving`
5. `order_parameter_nonneg`

Use them explicitly.

### Build path 1: import and strengthen `order_parameter_predicts_grokking`
If `MachineLearning/TropicalGrokking.lean` already contains an order parameter predictive theorem, do not merely reuse the statement. Strengthen it from a predictive correlation statement to a **geometric equivalence theorem**:
- existing theorem likely says an order parameter predicts grokking,
- your upgrade should show this order parameter is exactly a tropical boundary-gap aggregate,
- then prove that its collapse corresponds to corner-locus crossing.

This turns a phenomenological theorem into a structural theorem.

### Build path 2: use `tropical_double_descent_phase_transition`
This theorem likely already captures one tropical phase transition in learning curves. Use it as a prototype:
- identify the formal pattern of “phase transition” already encoded there,
- abstract a reusable lemma that a tropical observable with monotone collapse and a critical witness exhibits phase-transition behavior,
- instantiate it for grokking order parameter collapse.

This creates a unifying framework where double descent and grokking are two manifestations of the same tropical criticality principle.

### Build path 3: algebraic rewrites via `tropical_plus_distributes_over_min` and `max_plus_order_preserving`
Use these to:
- normalize class-score expressions,
- show monotonicity of score gaps under parameter updates,
- prove lower/upper bounds on tropical boundary gap under min-plus/max-plus transforms.

This is important because the actual proof burden will likely be expression normalization and monotonicity.

### Build path 4: connect with `order_parameter_nonneg`
Use this as the base positivity theorem for your new order parameter:
- either show your tropical order parameter refines the existing one,
- or prove a comparison theorem:
```lean
theorem tropicalOrderParameter_ge_old_order_parameter ...
```
or
```lean
theorem old_order_parameter_le_c_mul_tropicalOrderParameter ...
```
A comparison theorem would be a major conceptual consolidation.

---

## Proof Strategy Architecture

### Strategy A: Finite-combinatorial boundary-gap formalization
Most promising for Lean.

1. Define `tropicalBoundaryGap` as the minimum over all pairwise class-score absolute differences.
2. Prove nonnegativity and the zero iff pairwise equality theorem using `Finset.inf'` properties and `abs_nonneg`.
3. Define `tropicalOrderSum` over the dataset and prove strict decrease if one term drops strictly and all others weakly decrease.

Why promising:
- finite, concrete, no topology needed,
- compatible with `Fin`, `Finset`, `ℝ`,
- likely enough to formalize the “phase transition” claim rigorously.

### Strategy B: Piecewise-linear tropical hypersurface approach
More geometric and more revolutionary.

1. Define each class score as a tropical polynomial / max of affine forms.
2. Show pairwise score equality sets are tropical hypersurfaces or corner loci.
3. Prove that the decision boundary is the union of these corner loci and that order parameter collapse occurs when the training path intersects this union.

Why powerful:
- gives the cleanest geometric theorem,
- opens the door to tropical Morse theory for training.

Why harder:
- formalizing corner loci and tropical hypersurfaces in Lean may require substantial infrastructure.

### Strategy C: Statistical-mechanics abstraction of critical observables
Best for unification with double descent.

1. Define a generic `CriticalObservable` structure with nonnegativity, monotonicity, and witness-of-collapse axioms.
2. Prove a generic phase-transition theorem.
3. Instantiate for grokking using `tropicalBoundaryGap`, and separately for double descent using the existing theorem.

Why important:
- unifies two major learning phenomena,
- turns isolated theorems into a new formal theory.

Why secondary:
- depends on having the concrete grokking observable already established.

**Recommendation:** Start with Strategy A, then lift to Strategy C, and reserve Strategy B as the conceptual framing and future expansion.

---

## Cross-Domain Connections You Must Exploit

### 1. Statistical mechanics
Treat `tropicalOrderParameter` as an honest order parameter analogous to magnetization or susceptibility.
- Grokking onset becomes a critical event.
- Corner-locus crossing is the analogue of crossing a phase boundary in energy landscape geometry.
- This can suggest formal definitions of tropical susceptibility:
```lean
def tropicalSusceptibility (θ : Fin T → TropParams n k m) : ℝ := ...
```
Potential theorem: susceptibility spikes near order-parameter collapse.

### 2. Metric geometry / geodesics
Interpret delayed generalization as a path geometry phenomenon.
- A “geodesic” in parameter space crosses a singular set.
- This is analogous to cut loci / wall crossing in geometric group theory and symplectic wall-crossing.

### 3. Algebraic geometry
The decision boundary as a tropical hypersurface/corner locus is the algebraic heart of the project.
- If formalized, this creates a new tropical algebraic toolkit for machine learning.
- This is much deeper than proving another margin inequality.

### 4. Complexity / circuit theory
Tropical neural nets are min/max-plus circuits.
- Grokking can be reframed as a circuit regime change where the active affine pieces reorganize.
- A future theorem could characterize grokking as a support-change in the active monomial set.

This is exactly the kind of unexpected cross-pollination that could open a field.

---

## Concrete Lemma Pipeline

Prove these in order.

1. `tropicalBoundaryGap_nonneg`
2. `tropicalBoundaryGap_eq_zero_iff_exists_pair_eq`
3. `tropicalOrderSum_nonneg`
4. `strict_tropicalOrderSum_drop_of_single_witness`
5. `tropical_decision_boundary_eq_corner_locus`
6. `order_parameter_drop_of_corner_crossing`
7. comparison/strengthening of `order_parameter_predicts_grokking`
8. optional abstraction theorem unifying with `tropical_double_descent_phase_transition`

Suggested theorem names:
- `tropical_boundary_gap_nonneg`
- `tropical_boundary_gap_eq_zero_iff_exists_pair_eq`
- `tropical_order_sum_nonneg`
- `strict_tropical_order_sum_drop_of_single_witness`
- `decision_boundary_eq_pairwise_corner_locus`
- `grokking_onset_of_corner_crossing`
- `tropical_phase_transition_of_grokking`

---

## What Would Count as a Real Breakthrough

Do not stop at “there exists a nonnegative function called order parameter.” That is too weak.

A genuine breakthrough here is one of:

1. **Equivalence theorem**  
   Grokking order parameter collapse is equivalent to corner-locus contact for some sample.

2. **Unification theorem**  
   Grokking and double descent are instances of one tropical criticality theorem.

3. **Geometry theorem**  
   The delayed generalization boundary is a tropical hypersurface arrangement in parameter space.

4. **Predictive theorem**  
   A lower bound or exact threshold on the order parameter guarantees pre-grokking behavior; crossing below it certifies possible generalization transition.

Even one of these, formalized in Lean, is significant.

---

## Implementation Guidance in Lean

Prefer:
- `Fin n → ℝ` over arbitrary vector spaces,
- `Finset` over abstract finite sets,
- sums over averages when division creates coercion overhead,
- pairwise finite minima using `Finset.inf'` only if manageable; otherwise define via `sInf` on finite image sets,
- simple witness-based strict inequality lemmas for sums.

If argmax is cumbersome, avoid it entirely. The pairwise gap formulation is enough to capture decision-boundary contact.

If exact tropical polynomial formalization becomes too heavy, define “corner locus” operationally:
```lean
def onCornerLocus (P : TropParams n k m) (x : Fin n → ℝ) : Prop :=
  ∃ c c', c ≠ c' ∧ classScore P c x = classScore P c' x
```
Then prove:
```lean
theorem tropicalBoundaryGap_eq_zero_iff_onCornerLocus ...
```
This is already mathematically meaningful and much easier to formalize.

---

## Deliverables

1. Lean file(s) formalizing the definitions and theorems above.
2. At least one theorem that explicitly strengthens or refactors an existing catalog theorem.
3. Minimal sorry usage, with all remaining sorrys localized and explained.
4. A structured `FUTURE_DIRECTIONS.md` containing **3–5 concrete breakthrough next steps**, not vague ideas.

Your `FUTURE_DIRECTIONS.md` must include items of the form:
- exact conjecture/theorem statement,
- why it would matter,
- what existing theorem it builds on,
- likely proof route.

---

## Application Keywords

tropical geometry, grokking, phase transition, order parameter, corner locus, decision boundary, delayed generalization, neural loss landscape, max-plus algebra, min-plus distance, statistical mechanics, critical phenomena, piecewise-linear networks, hypersurface arrangement, learning theory, circuit complexity, wall crossing, geometric deep learning

---

## Team Directive

Create a team to conduct research, brainstorm hypotheses, run experiments, validate data, update the knowledge base, and iterate forever.

Suggested roles:
- **Formalization lead**: builds Lean definitions and finite combinatorial lemmas.
- **Geometer**: designs corner-locus and tropical hypersurface statements.
- **Learning theorist**: interprets order-parameter collapse as generalization onset.
- **Stat mech architect**: abstracts the phase-transition framework.
- **Proof engineer**: removes coercion/`Finset` obstacles and minimizes sorry.

---

You are Aristotle. Pursue this deeply and originally. Discover what matters. Prove what you can. Define what needs defining. Build on the catalog theorems referenced above. Connect this to at least one other domain in the final writeup. Produce Lean 4 proofs and `FUTURE_DIRECTIONS.md`.

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

Research domain: MachineLearning
Research mode: prove
