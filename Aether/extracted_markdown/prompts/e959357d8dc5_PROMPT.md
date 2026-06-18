## Assignment: Kakeya Conjecture — Incidence Geometry, Dimension Growth, and Formal Bridges to Restriction/Additive Combinatorics

You are not being asked for a cosmetic formalization of folklore. You are being asked to carve out a **Lean-certified research program around Kakeya phenomena** that isolates genuinely provable structural theorems now, while architecting the formal language needed for eventual attacks on the full conjecture.

The full Euclidean Kakeya conjecture

> Every Besicovitch set in `ℝ^n` has Hausdorff dimension `n`

is likely beyond immediate full formal proof in current Mathlib. So the right move is **not** to fake completeness. The right move is to produce a suite of new, deep, formally verified theorems that collectively build the missing infrastructure:
- a rigorous formal notion of Kakeya/Besicovitch sets,
- dimension lower bounds from geometric incidence structure,
- finite-field/discretized analogues,
- explicit bridges to restriction-type counting inequalities and additive combinatorics,
- a computational pipeline that tests conjectural extremizers.

Your work should feel like the beginning of a field-opening Lean library:
**formal geometric measure theory meets additive combinatorics meets harmonic analysis**.

## Mode
**prove + formalize + discover**

---

## Primary Research Objective

Construct a Lean 4 development proving **nontrivial lower-bound theorems for Kakeya-type sets** and formalizing at least one rigorous bridge:
1. **geometric incidence ⇒ size/dimension lower bound**, and
2. **additive energy / sumset control ⇒ obstruction to Kakeya compression**, or
3. **discrete restriction-style inequality ⇒ Kakeya lower bound**.

Do **not** promise the full Euclidean Kakeya conjecture unless you can actually prove it. Instead, prove the strongest verified theorems you can around it, and clearly isolate the conjectural gap.

---

## Exact Theorem Targets

You must include at least **3 substantial theorems** with multi-step proofs. At least one should introduce a genuinely new definition.

### New definitions to introduce

Define a formal structure capturing finite/discretized Kakeya geometry. For example:

```lean
structure DiscreteKakeyaConfig (α : Type*) [Fintype α] [DecidableEq α] where
  Point : Type*
  Dir   : Type*
  line  : Dir → Finset Point
  carrier : Finset Point
  line_subset_carrier : ∀ d, line d ⊆ carrier
  nonempty_line : ∀ d, (line d).Nonempty
```

and/or a Euclidean surrogate:

```lean
def ContainsUnitSegmentInDirection (E : Set (Fin n → ℝ)) (v : Fin n → ℝ) : Prop :=
  ∃ x : Fin n → ℝ, ∀ t : ℝ, t ∈ Set.Icc (0 : ℝ) 1 → x + t • v ∈ E

def IsBesicovitchSet (E : Set (Fin n → ℝ)) : Prop :=
  ∀ v : Fin n → ℝ, ‖v‖ = 1 → ContainsUnitSegmentInDirection E v
```

and at least one combinatorial statistic such as overlap multiplicity or energy:

```lean
def pointMultiplicity (K : DiscreteKakeyaConfig α) (p : K.Point) : ℕ :=
  ((Finset.univ.filter fun d => p ∈ K.line d).card)

def kakeyaEnergy (K : DiscreteKakeyaConfig α) : ℕ :=
  ∑ p in K.carrier, (pointMultiplicity K p)^2
```

If Mathlib already has nearby notions, refine rather than duplicate; but you must add at least one genuinely new concept.

---

## Core Theorem 1: Incidence Cauchy–Schwarz Lower Bound

Prove a sharp combinatorial lower bound showing that many direction-lines force many points unless overlap energy is huge.

### Precise statement
For a finite Kakeya configuration with all lines of constant size `L`, show
\[
(\#\mathrm{Dir} \cdot L)^2 \le |K.carrier| \cdot \mathrm{kakeyaEnergy}(K).
\]

### Lean-style target
```lean
theorem sq_total_line_mass_le_card_mul_energy
  (K : DiscreteKakeyaConfig α)
  (L : ℕ)
  (hL : ∀ d, (K.line d).card = L) :
  ((Fintype.card K.Dir) * L)^2
    ≤ K.carrier.card * K.kakeyaEnergy
```

### Why this matters
This is the formal gateway from **incidence counting** to **dimension/size lower bounds**. It is the finite-combinatorial skeleton of Kakeya theory: if every direction contributes a line, then either the carrier is large or line overlaps are forced into highly non-generic concentration. This is the precise point where additive combinatorics enters.

### Proof strategy options
**Strategy A: Double-counting + Cauchy–Schwarz on multiplicity**
1. Show `∑ p in carrier, pointMultiplicity K p = ∑ d, (line d).card = |Dir| * L`.
2. Apply the finite Cauchy–Schwarz inequality to the function `pointMultiplicity`.
3. Rearrange into the claimed inequality.

**Strategy B: Incidence bipartite graph**
1. Define the incidence graph between directions and carrier points.
2. Count edges in two ways.
3. Apply `(|E|)^2 ≤ |V_right| * ∑ deg(p)^2`.

**Most promising:** Strategy A, because Mathlib is friendlier with `Finset.sum` and algebraic inequalities than with graph abstractions.

---

## Core Theorem 2: Pairwise-Transverse Line Family Gives Quadratic Growth

Formalize a theorem saying that if lines in distinct directions have uniformly bounded intersections, then the carrier must be large.

### Precise statement
If each line has `L` points and any two distinct directions have intersection size at most `T`, then
\[
|K.carrier| \ge \frac{(|D|L)^2}{|D|L + |D|(|D|-1)T}.
\]
In particular, if `T = 1`, then the carrier has order at least `|D|L^2/(L+|D|)` and hence exhibits genuine growth.

### Lean-style target
```lean
theorem card_lower_bound_of_pairwise_intersection_bound
  (K : DiscreteKakeyaConfig α)
  (L T : ℕ)
  (hL : ∀ d, (K.line d).card = L)
  (hT : ∀ d₁ d₂, d₁ ≠ d₂ → ((K.line d₁ ∩ K.line d₂).card ≤ T)) :
  ((Fintype.card K.Dir) * L)^2
    ≤ K.carrier.card *
      ((Fintype.card K.Dir) * L +
       (Fintype.card K.Dir) * (Fintype.card K.Dir - 1) * T)
```

A cleaned corollary can then extract a lower bound on `K.carrier.card`.

### Why this matters
This is a rigorous **discrete Kakeya expansion theorem**. It captures the philosophical core of the Kakeya problem: many differently oriented tubes cannot all live in a tiny set unless there is large-scale intersection structure. This theorem becomes the formal bridge to:
- Wolff-style hairbrush heuristics,
- polynomial method finite-field Kakeya lower bounds,
- restriction estimates where overlap counts control norm inflation.

### Proof strategy options
**Strategy A: Bound energy via pair intersections**
1. Expand `kakeyaEnergy` as sum over ordered pairs of directions of intersection cardinalities.
2. Bound diagonal terms by `L` and off-diagonal terms by `T`.
3. Combine with Core Theorem 1.

**Strategy B: Inclusion–exclusion truncation**
1. Estimate the union size of all lines from first and second moments.
2. Use pairwise intersection control to lower-bound the union.
3. Transfer to `carrier.card`.

**Most promising:** Strategy A, because it directly reuses Core Theorem 1 and packages the argument in a way compatible with future additive-energy refinements.

---

## Core Theorem 3: Additive-Combinatorial Obstruction via Difference Sets

Introduce a theorem connecting line-rich geometry to additive combinatorics. For subsets of an additive abelian group, if a set contains many arithmetic progressions in many directions, then its difference set must be large or its additive energy must be high.

### Possible formal target
Let `A : Finset G` in a finite additive commutative group. Suppose for each direction `v` in a finite direction set `V`, there exists `x` such that `{x + k • v | k ∈ I}` lies in `A`. Prove a lower bound on additive energy or difference-set size.

A more Lean-manageable version:

```lean
def additiveEnergy (A : Finset G) : ℕ :=
  (((A.product A).product (A.product A)).filter
    (fun q => q.1.1 + q.1.2 = q.2.1 + q.2.2)).card

theorem large_progression_family_forces_large_energy_or_large_diffset
  (A V : Finset G)
  (m : ℕ)
  (hprog : ∀ v ∈ V, ∃ x : G, ∀ k : ℕ, k < m → x + k • v ∈ A) :
  ∃ E D : ℕ,
    E = additiveEnergy A ∧
    D = (A.image fun a => (A.image fun b => a - b)).sup Finset.card ∧
    (V.card * m)^2 ≤ A.card * E
```

You may need to adapt the exact statement to available algebraic structures (`ℤ`, `ZMod p`, or finite-dimensional vector spaces over `ZMod p` are especially promising).

### Why this matters
This is the first real bridge from **Kakeya geometry to additive combinatorics** in the formal library. It expresses the meta-principle:
> compressing many directional segments into a small set creates additive structure.

That is the beating heart of the sum-product/incidence/restriction ecosystem.

### Proof strategy options
**Strategy A: Encode each progression as a “line” in an additive group**
1. Instantiate `DiscreteKakeyaConfig` using arithmetic progressions.
2. Apply Core Theorem 1.
3. Interpret multiplicity/energy additively.

**Strategy B: Direct quadruple counting**
1. Count pairs `(v,k)` and collisions `x_v + kv = x_w + ℓw`.
2. Convert collisions into additive quadruples.
3. Infer a lower bound on additive energy.

**Most promising:** Strategy B if you work in `ZMod p` or finite abelian groups; Strategy A if you want maximal code reuse.

---

## Cross-Domain Theorem Requirement

You must include at least one theorem explicitly linking Kakeya ideas to a different domain.

### Recommended cross-domain connection: harmonic analysis / restriction
Formalize a discrete surrogate of the heuristic:
**restriction estimates imply Kakeya lower bounds**.

A manageable theorem is a finite Fourier-analytic inequality over `ZMod p` or finite abelian groups:

```lean
theorem line_indicator_large_fourier_mass_implies_energy_bound
  (A : Finset G) :
  ...
```

or a clean `L²` Plancherel-based result showing that overlap concentration of directional line indicators forces Fourier mass concentration.

### Why this is revolutionary
This opens a formal route to one of the deepest architectures in modern analysis:
- Kakeya
- restriction
- decoupling
- additive energy
- incidence geometry

A verified discrete version would be a major conceptual beachhead.

### Alternative cross-domain connection: mathematical physics
Use the catalog theorem
- `gw_energy_has_IR_cutoff` from `FINAL/Geometry/GravitationalWaves.lean`

as conceptual inspiration for an **infrared/ultraviolet decomposition** of tube overlap energy: define coarse/fine scales and prove monotonicity or lower bounds across scales. Even if not directly imported into the proof, explicitly connect the Kakeya multiscale decomposition to energy cascades in wave physics. This is scientifically fertile and article-worthy.

### Alternative cross-domain connection: geometric measure theory
Use
- `null_sphere_has_measure_zero` from `FINAL/Geometry/GapMatterResearch.lean`

to prove at least one theorem of the form:
if a set of directions excluded from a Besicovitch condition lies in a sphere-null exceptional set, then “almost every direction” still satisfies a measurable segment-containment property. Even a weak measurable surrogate is valuable.

---

## Suggested Lean 4 Type Signatures

Use or adapt these signatures to make the project concrete.

```lean
def ContainsUnitSegmentInDirection (E : Set (Fin n → ℝ)) (v : Fin n → ℝ) : Prop :=
  ∃ x : Fin n → ℝ, ∀ t : ℝ, t ∈ Set.Icc (0 : ℝ) 1 → x + t • v ∈ E

def IsBesicovitchSet (E : Set (Fin n → ℝ)) : Prop :=
  ∀ v : Fin n → ℝ, ‖v‖ = 1 → ContainsUnitSegmentInDirection E v
```

```lean
structure DiscreteKakeyaConfig where
  Point : Type
  Dir : Type
  [instPointFintype : Fintype Point]
  [instPointDecidableEq : DecidableEq Point]
  [instDirFintype : Fintype Dir]
  [instDirDecidableEq : DecidableEq Dir]
  line : Dir → Finset Point
  carrier : Finset Point
  line_subset_carrier : ∀ d, line d ⊆ carrier
  nonempty_line : ∀ d, (line d).Nonempty
```

```lean
def pointMultiplicity (K : DiscreteKakeyaConfig) (p : K.Point) : ℕ :=
  ((Finset.univ.filter fun d => p ∈ K.line d).card)

def kakeyaEnergy (K : DiscreteKakeyaConfig) : ℕ :=
  ∑ p in K.carrier, (pointMultiplicity K p)^2
```

```lean
theorem total_multiplicity_eq_sum_card_lines
  (K : DiscreteKakeyaConfig) :
  ∑ p in K.carrier, pointMultiplicity K p
    = ∑ d : K.Dir, (K.line d).card
```

```lean
theorem sq_total_line_mass_le_card_mul_energy
  (K : DiscreteKakeyaConfig)
  (L : ℕ)
  (hL : ∀ d, (K.line d).card = L) :
  ((Fintype.card K.Dir) * L)^2 ≤ K.carrier.card * K.kakeyaEnergy
```

```lean
theorem energy_le_of_pairwise_intersection_bound
  (K : DiscreteKakeyaConfig)
  (L T : ℕ)
  (hL : ∀ d, (K.line d).card = L)
  (hT : ∀ d₁ d₂, d₁ ≠ d₂ → ((K.line d₁ ∩ K.line d₂).card ≤ T)) :
  K.kakeyaEnergy ≤
    (Fintype.card K.Dir) * L +
    (Fintype.card K.Dir) * (Fintype.card K.Dir - 1) * T
```

```lean
theorem card_lower_bound_of_pairwise_intersection_bound
  (K : DiscreteKakeyaConfig)
  (L T : ℕ)
  (hL : ∀ d, (K.line d).card = L)
  (hT : ∀ d₁ d₂, d₁ ≠ d₂ → ((K.line d₁ ∩ K.line d₂).card ≤ T)) :
  ((Fintype.card K.Dir) * L)^2 ≤
    K.carrier.card *
    ((Fintype.card K.Dir) * L +
     (Fintype.card K.Dir) * (Fintype.card K.Dir - 1) * T)
```

If Hausdorff dimension is too heavy to fully formalize, define a surrogate notion such as dyadic covering complexity or finite-scale Minkowski lower growth and prove lower bounds there.

---

## How to Build on Existing Verified Theorems

The catalog theorems are not directly Kakeya theorems, but they provide useful formal and conceptual anchors.

1. **`null_sphere_has_measure_zero`**  
   File: `FINAL/Geometry/GapMatterResearch.lean`  
   Use this as a gateway to reason about exceptional direction sets on the sphere. A viable theorem:
   - if a property fails only on a spherical null set, then an “almost-every-direction Kakeya” predicate is measurable/nontrivial.
   This helps formalize the distinction between full Besicovitch and almost-everywhere directional coverage.

2. **`integer_inputs_finite_set`**  
   File: `FINAL/Geometry/InverseStereoMobiusNext.lean`  
   This can inspire or support finite/discretized encodings: line directions or arithmetic progressions sampled on integer grids. Use it to justify finite witness extraction from infinite geometric conditions when building toy models on `ℤ^n`.

3. **`gw_energy_has_IR_cutoff`**  
   File: `FINAL/Geometry/GravitationalWaves.lean`  
   This is conceptually valuable for defining a multiscale “energy cutoff” for line overlaps:
   - coarse overlap energy,
   - fine overlap energy,
   - monotonicity under scale refinement.
   Even if the exact theorem is independent, explicitly cite the analogy and consider proving a scale-truncated energy inequality.

4. **`trace_sq_and_discriminant`**  
   File: `FINAL/Geometry/PadicMobius.lean`  
   Use as inspiration for algebraic invariants controlling geometry. In a finite-field Kakeya variant, define a line-family invariant analogous to discriminant/trace that detects degeneracy (e.g. parallel clustering, repeated intersections).

Do not merely name-drop these results. Show how they inform your formal architecture.

---

## Proof Tactics Requirements

At least 3 theorems must use deep proof patterns such as:
- induction over finite sets / cardinality,
- `rcases` on witness-bearing hypotheses,
- `by_contra` for extremal lower bounds,
- `field_simp` if you derive rational lower bounds,
- multi-step `calc` chains for incidence-energy inequalities.

The file should visibly contain real mathematics, not tactic trivialities.

---

## Conjecture With Testable Prediction

You must state at least one falsifiable conjecture with a computational disproof protocol.

### Recommended conjecture
For finite-field Kakeya-type configurations in `𝔽_q^2`, among all families with one affine line in each direction, the minimum carrier size is achieved by a near-star configuration maximizing concurrency.

A Lean-adjacent statement in prose:
> **Conjecture (Finite extremizer shape).** For line families in `ZMod p × ZMod p` containing one affine line in each slope, the minimal union size is attained by configurations with maximal point multiplicity concentrated at a single point, up to affine equivalence.

### Computational test
For small primes `p = 3,5,7,11`:
1. Enumerate one-line-per-direction families.
2. Compute union size and multiplicity profile.
3. Check whether every minimizer is affinely equivalent to a maximal-concurrency family.

This is falsifiable: a single counterexample family disproves it.

### Stronger speculative conjecture
A discretized restriction-to-Kakeya principle:
> Any family of directional line indicators in `𝔽_q^n` with near-extremal Fourier concentration must exhibit near-extremal overlap multiplicity.

Test by exhaustive search for small `q,n`.

---

## Deliverables You Must Produce

You must produce **all** of the following.

### 1. Lean file with verified mathematics
It must contain:
- at least one novel definition,
- at least 3 nontrivial theorems,
- at least one cross-domain theorem,
- minimized `sorry`s,
- no fake “deep theorem” proved only by `native_decide`/`decide`/`norm_num`/`rfl`.

### 2. `FUTURE_DIRECTIONS.md`
Include **3–5 falsifiable scientific hypotheses**, each with:
- exact conjecture,
- what data or formal experiment would test it,
- what outcome would refute it.

Suggested hypotheses:
1. finite-field extremizers are star-like;
2. bounded pairwise intersections force near-optimal quadratic growth;
3. Fourier concentration predicts multiplicity concentration;
4. dyadic Minkowski lower bounds can be bootstrapped to Hausdorff surrogates;
5. almost-every-direction versions are stable under null exceptional sets.

### 3. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the Kakeya problem,
- what exact theorems were proved,
- what formal definitions were introduced,
- why the incidence/additive-combinatorics bridge matters,
- where the full conjecture remains open,
- what experiments suggest next.

A reader with no code access must still understand the discovery.

### 4. `ARTICLE.md`
Scientific American style:
- why “needles in all directions” force hidden structure,
- why this touches Fourier analysis, combinatorics, and physics,
- what was actually proved in the verified system,
- why formal mathematics matters here.

### 5. Verified algorithm / computational method
Implement an algorithm that, for a finite-field or finite-grid model:
- constructs line families,
- computes carrier size,
- computes multiplicity and energy,
- tests conjectured extremizers.

This is not optional.

### 6. `demo.py`
Interactive or script-based demo showing:
- generation of finite Kakeya configurations,
- visualization of union size and overlap multiplicity,
- numerical comparison against your proved lower bounds,
- tests of the falsifiable conjecture for small parameters.

---

## Recommended Development Path

### Path A: Finite-field/discrete first, then Euclidean surrogates
1. Define `DiscreteKakeyaConfig`.
2. Prove incidence-energy identity.
3. Prove pairwise-intersection lower bound.
4. Add additive-energy theorem in `ZMod p` or finite abelian groups.
5. Define Euclidean Besicovitch predicates and state the full conjecture as a formal conjecture/theorem stub with surrounding infrastructure.

**Best balance of rigor and ambition.**

### Path B: Measure-theoretic surrogate first
1. Define Besicovitch sets in `Fin n → ℝ`.
2. Formalize “contains segment in every direction”.
3. Prove measurable/exceptional-set lemmas using `null_sphere_has_measure_zero`.
4. Add discretization theorem passing from Euclidean segment families to finite sampled configurations.
5. Apply discrete lower bounds.

**Harder but more visionary.**

### Path C: Restriction/additive-combinatorics bridge first
1. Work in finite abelian groups.
2. Define line/progression families and additive energy.
3. Prove energy lower bounds from directional richness.
4. Interpret as discrete Kakeya obstruction.
5. Add Fourier-analytic corollary.

**Most cross-disciplinary.**

---

## Revolutionary Significance

A successful project here does not “solve Kakeya.” It does something almost as important for formal mathematics: it creates the **first serious certified architecture for Kakeya-style reasoning**, where:
- geometric incidence,
- additive energy,
- exceptional direction sets,
- multiscale overlap,
- and restriction heuristics

all coexist in one formal ecosystem.

This would open:
- formalized incidence geometry,
- finite-field harmonic analysis,
- certified extremal combinatorics,
- future attacks on restriction/decoupling,
- machine-checked geometric measure theory.

This is how one eventually gets to the full conjecture: by making the hidden skeleton of the subject formal and computable.

## Application Keywords
Kakeya conjecture; Besicovitch sets; Hausdorff dimension; Minkowski dimension; finite-field Kakeya; incidence geometry; additive combinatorics; additive energy; restriction estimates; Fourier analysis; geometric measure theory; multiscale analysis; extremal configurations; formalized harmonic analysis; certified combinatorics; Lean 4; Mathlib.

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

Research domain: Geometry
Research mode: prove
