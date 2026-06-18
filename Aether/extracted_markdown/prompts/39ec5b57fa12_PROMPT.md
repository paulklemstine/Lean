## Assignment: Musical Counterpoint as Tropical Voice-Leading Optimization

Mode: **prove**

This is not a metaphor project. The target is to turn a body of stylistic musical rules into a mathematically precise optimization theory over the tropical semiring, then prove structural theorems that distinguish strict counterpoint from harmonically richer but less globally optimal practice. If this works, it opens a new field: **formal tropical music theory**, where compositional grammars become certifiable optimization problems, style classes become semiring-geometric strata, and voice-leading can be studied with the same algebraic tools now used in verification, phylogenetics, and idempotent information theory.

You should aim for a theorem package that is both formalizable in Lean 4 and conceptually explosive: local musical legality becomes a weighted constraint system; global style becomes a statement about tropical minimizers, Pareto optima, and constrained saddle behavior.

### Core Vision

Model a two-voice composition of length `n` as a pair of pitch sequences in `ℤ` or `ℕ`, with:
- **vertical interval cost** penalizing dissonant simultaneities,
- **horizontal motion cost** penalizing large melodic leaps,
- **parallel-motion cost** penalizing forbidden consecutive perfect intervals,
- **variety reward/cost transform** measuring harmonic diversity.

Then prove:

1. **Species counterpoint feasibility and optimality theorem**: legal first-species counterpoint is exactly the zero-penalty locus of a tropical constraint functional, and among all realizations over a fixed cantus firmus, the Palestrina-style admissible solutions are tropical minimizers of total voice-leading cost.

2. **Strict-style dominance theorem**: if forbidden intervals and forbidden parallels receive penalties larger than any possible aggregate motion advantage, then every tropical minimizer must satisfy the strict contrapuntal rules.

3. **Bach-style constrained saddle theorem**: after adding a harmonic-variety term with opposite optimization sign, chorale-like configurations are not global minima of the strict counterpoint functional but become Pareto-optimal / saddle-type points balancing low contrapuntal penalty against maximal harmonic diversity.

The breakthrough is that “style” becomes a theorem about geometry of weighted path spaces. This would connect:
- tropical algebra,
- combinatorial optimization,
- computational music theory,
- formal methods / constraint verification,
- and potentially categorical semantics of composition.

---

## Precise Formal Targets

Work with finite sequences indexed by `Fin n`. Use concrete definitions with `Nat`, `Int`, `Real`, `Finset`, and `Matrix` where appropriate.

### Suggested basic definitions

Use integer pitches for musical intervals.

```lean
def Melody (n : ℕ) := Fin n → ℤ

def interval {n : ℕ} (u v : Melody n) (i : Fin n) : ℤ := v i - u i

def stepCost (x y : ℤ) : ℝ := |(y - x : ℤ)|

def perfectConsonance (k : ℤ) : Prop := k.natAbs ∈ ({0, 7, 12} : Finset ℕ)

def imperfectConsonance (k : ℤ) : Prop := k.natAbs ∈ ({3, 4, 8, 9} : Finset ℕ)

def consonant (k : ℤ) : Prop := perfectConsonance k ∨ imperfectConsonance k

def forbiddenVerticalPenalty (k : ℤ) : ℝ := if consonant k then 0 else 1

def melodicLeapPenalty (x y : ℤ) : ℝ := max 0 (|(y - x : ℤ)| - 2)

def parallelPerfectPenalty {n : ℕ} (u v : Melody n) (i : Fin (n-1)) : ℝ :=
  let i' : Fin n := ⟨i.1, Nat.lt_trans i.2 (Nat.pred_lt (Nat.ne_of_gt (Nat.succ_lt_succ_iff.mp i.2)))⟩
  let j' : Fin n := ⟨i.1 + 1, Nat.succ_lt_of_lt i.2⟩
  if perfectConsonance (interval u v i') ∧ perfectConsonance (interval u v j')
  then 1 else 0
```

You may simplify indexing by using lists or `Fin (n+1)` if cleaner. The exact representation is less important than making the theorem statements executable.

### Tropical total cost functional

Define total cost as a sum of local penalties; then interpret optimization tropically by taking minimum over admissible upper voices.

```lean
def totalCost {n : ℕ} (u v : Melody n) : ℝ :=
  (∑ i, forbiddenVerticalPenalty (interval u v i)) +
  (∑ i : Fin (n-1), melodicLeapPenalty (v ⟨i.1, Nat.lt_trans i.2 (Nat.pred_lt (Nat.ne_of_gt (Nat.succ_lt_succ_iff.mp i.2)))⟩)
                                         (v ⟨i.1+1, Nat.succ_lt_of_lt i.2⟩)) +
  (∑ i : Fin (n-1), parallelPerfectPenalty u v i)
```

Then define tropical optimum over a finite candidate class:

```lean
def tropicalOptimum {n : ℕ} (S : Finset (Melody n)) (u : Melody n) : ℝ :=
  S.inf' (by sorry) (fun v => totalCost u v)
```

If `Finset (Melody n)` is awkward due to decidable equality, encode melodies as `Fin n → Fin M` or vectors over bounded pitch classes.

---

## Primary Theorems to Prove

### Theorem 1: Strict counterpoint equals zero tropical penalty

This is the foundational equivalence theorem.

```lean
def FirstSpeciesLegal {n : ℕ} (u v : Melody n) : Prop :=
  (∀ i, consonant (interval u v i)) ∧
  (∀ i : Fin (n-1), ¬ (perfectConsonance (interval u v ⟨i.1, by omega⟩) ∧
                       perfectConsonance (interval u v ⟨i.1+1, by omega⟩))) ∧
  (∀ i : Fin (n-1), |(v ⟨i.1+1, by omega⟩ - v ⟨i.1, by omega⟩ : ℤ)| ≤ 2)

theorem firstSpecies_iff_zeroCost
  {n : ℕ} (hn : 0 < n) (u v : Melody n) :
  FirstSpeciesLegal u v ↔ totalCost u v = 0
```

Why this matters: it identifies species counterpoint as an exact feasibility locus of a tropical weighted CSP. That is a genuine bridge theorem between music theory and idempotent optimization.

### Theorem 2: Large forbidden-penalty regime forces legality of minimizers

Formalize weighted penalties with parameters `A B C : ℝ` for vertical illegality, melodic leaps, and parallels. Then prove that if `A` and `C` dominate any total possible savings from motion terms, minimizers must satisfy strict legality.

```lean
def weightedTotalCost {n : ℕ} (A B C : ℝ) (u v : Melody n) : ℝ := ...

theorem minimizer_is_legal_of_large_penalties
  {n M : ℕ} (hn : 0 < n)
  (S : Finset (Melody n)) (u : Melody n)
  (hbounded : ∀ v ∈ S, ∀ i : Fin (n-1), |(v ⟨i.1+1, by omega⟩ - v ⟨i.1, by omega⟩ : ℤ)| ≤ M)
  (A B C : ℝ)
  (hA : A > (n-1) * B * M)
  (hC : C > (n-1) * B * M)
  {v : Melody n} (hvS : v ∈ S)
  (hmin : weightedTotalCost A B C u v = tropicalOptimum S u) :
  FirstSpeciesLegal u v
```

You may need a cleaner finite-bound statement, e.g. over melodies valued in `Fin P` or `Int` with bounded range. That is fine. The conceptual theorem is what matters: **sufficient separation of scales converts soft penalties into hard style laws**.

### Theorem 3: Tropical decomposition over local constraints

Show that local costs combine tropically in a dynamic-programming sense. This is the algebraic engine and where the catalog theorem `tropical_plus_distributes_over_min` should be used explicitly.

For a bounded pitch alphabet `α = Fin P`, define admissible continuations and prove Bellman-style factorization:

```lean
def localCost : Fin P → Fin P → Fin P → ℝ := ...
def dpCost : ℕ → Fin P → ℝ := ...

theorem tropical_bellman
  (k : ℕ) (x : Fin P) :
  dpCost (k+1) x = ⨅ y, (localUnaryCost x y + dpCost k y)
```

Or in a finite `Finset` form:

```lean
theorem tropical_dynamic_programming
  (k : ℕ) (x : Fin P) (Y : Finset (Fin P)) (hY : Y.Nonempty) :
  nextCost k x Y =
    Y.inf' hY (fun y => transitionCost x y + stateCost k y)
```

Use `tropical_plus_distributes_over_min` to justify distributivity of additive transition cost over tropical minimization. This theorem is the computational heart: it turns counterpoint search into a certified tropical shortest-path problem.

### Theorem 4: Harmonic variety creates saddle/Pareto structure

Do not overclaim analytic Morse theory if the formal infrastructure is not there. Instead prove a rigorous finite optimization theorem.

Define harmonic variety as the number of distinct interval classes used:

```lean
def intervalClassSet {n : ℕ} (u v : Melody n) : Finset ℤ := ...
def harmonicVariety {n : ℕ} (u v : Melody n) : ℕ := (intervalClassSet u v).card
```

Then define a two-objective functional:
- minimize contrapuntal penalty,
- maximize harmonic variety.

Convert to scalarized form:
```lean
def bachScore {n : ℕ} (λ : ℝ) (u v : Melody n) : ℝ :=
  totalCost u v - λ * harmonicVariety u v
```

Target theorem:

```lean
theorem exists_pareto_point_with_positive_variety_gain
  {n : ℕ} (hn : 1 < n) (S : Finset (Melody n)) (hS : S.Nonempty) (u : Melody n) :
  ∃ v ∈ S, ∃ w ∈ S,
    totalCost u v ≤ totalCost u w ∧
    harmonicVariety u w ≤ harmonicVariety u v ∧
    ¬ (totalCost u v ≤ totalCost u w ∧ harmonicVariety u v ≤ harmonicVariety u w)
```

A cleaner theorem is acceptable: prove existence of nontrivial Pareto-optimal points when the feasible set contains one strict-style melody and one higher-variety melody. This is the formal surrogate for the “Bach chorales occupy saddle points” slogan. In the brief and comments, explain that in finite tropical optimization this means **not globally minimizing strict penalty, but extremizing a mixed objective under contrapuntal constraints**.

---

## Proof Strategy Architecture

### Strategy A: Exact zero-cost characterization via nonnegativity
Most promising for Theorem 1.

1. Prove every summand in `totalCost` is nonnegative.
2. Prove each legal rule is equivalent to vanishing of its corresponding local penalty.
3. Use `Finset.sum_eq_zero_iff_of_nonneg` (or a custom lemma over `ℝ`) to conclude total cost is zero iff each local term is zero.

Why promising: this is structurally simple, Lean-friendly, and gives immediate modularity. Each musical rule becomes an independent algebraic lemma.

### Strategy B: Dominating-penalty separation argument
Best for Theorem 2.

1. Bound the total possible improvement coming from melodic motion terms over the finite candidate space.
2. Show any illegal vertical interval or forbidden parallel incurs a penalty exceeding that total possible improvement.
3. Conclude a minimizer cannot contain any illegality, otherwise replacing it by a legal local repair would strictly reduce cost.

Why promising: this turns style into a theorem about **energy-scale separation**, a powerful concept that can generalize to richer composition models.

### Strategy C: Tropical dynamic programming / shortest path
Best for Theorem 3 and computational consequences.

1. Encode a melody of length `n` over finite pitch set `Fin P` as a path in a layered DAG.
2. Assign edge weights equal to local contrapuntal penalties.
3. Prove total cost equals path weight, and tropical optimum equals shortest-path value.
4. Use `tropical_plus_distributes_over_min` to formalize Bellman recursion.

Why promising: this creates an algorithmic bridge to verification and synthesis. It also makes future extraction of certified composition algorithms realistic.

### Strategy D: Finite Pareto frontier theorem
Best for Theorem 4.

1. Show the image of `S` under `(totalCost u ·, harmonicVariety u ·)` is a finite subset of `ℝ × ℕ`.
2. Use finite partial-order arguments to obtain Pareto-optimal points.
3. Exhibit hypotheses ensuring at least two incomparable points: one strict low-cost/low-variety point and one higher-cost/high-variety point.

Why promising: avoids forcing continuous saddle-point machinery into Lean too early, while preserving the mathematically meaningful claim.

---

## How to Build on Catalog Theorems

Use the catalog theorem
- `tropical_plus_distributes_over_min`

not as decoration, but as the formal algebraic backbone of dynamic programming identities. The intended use is:
- when proving that adding a fixed local transition cost commutes with taking tropical minima over next states,
- when refactoring a global optimization over melodies into nested local minimizations.

Use
- `tropical_and_bound : min a b ≤ a`

to prove monotonicity and pruning lemmas:
- adding extra candidate melodies cannot increase tropical optimum,
- restricting to legal subfamilies gives an upper/lower bound on optimum depending on formulation,
- branch-and-bound arguments for compositional search.

This is important: the music theorem should visibly inherit its computational semantics from existing tropical infrastructure in the catalog.

---

## Cross-Domain Connections You Must Exploit

### 1. Formal verification
Interpret `FirstSpeciesLegal u v` as a safety specification and `totalCost` as a robustness certificate. Then strict counterpoint becomes analogous to:
- zero violation in temporal logic monitoring,
- weighted model checking over idempotent semirings,
- certified synthesis of safe trajectories.

Potential theorem phrasing: legal counterpoint is the zero-robustness region of a finite-horizon specification.

### 2. Tropical phylogenetics / sequence alignment
Voice leading is a path optimization over discrete symbols with local transition penalties, exactly as in alignment and evolutionary scoring. This suggests:
- interval sequences as “musical genomes,”
- species rules as conserved-structure constraints,
- chorale style as diversity-preserving optimization under local admissibility.

This connection is not cosmetic; it may suggest reusable dynamic-programming lemmas and matrix formulations.

### 3. Idempotent information theory
Harmonic variety can be viewed as an idempotent entropy surrogate: not probabilistic uncertainty, but support-size richness in interval classes. Bach-style optimization then resembles a tropical rate-distortion tradeoff:
- distortion = contrapuntal penalty,
- rate/diversity = harmonic variety.

This is a genuinely surprising bridge and could lead to a future theorem: tropical data-processing inequalities for musical transformations.

### 4. Optimal transport / discrete geometry
Voice-leading distance is a transport cost between pitch configurations. Even in two voices, this hints that counterpoint lives on a discrete transport polytope with tropical objective. Mention this in comments and future directions.

---

## Lean 4 Formalization Advice

- Start with a **bounded pitch alphabet** (`Fin P` or `Int` with a finite candidate `Finset`) to keep optimization statements finite.
- Separate theorem layers:
  1. local penalty lemmas,
  2. zero-cost iff legality,
  3. optimization/minimizer theorems,
  4. dynamic programming recursion,
  5. Pareto frontier theorem.
- If absolute values over `ℤ` become cumbersome, define melodic penalty using `Int.natAbs` and cast to `ℝ`.
- Avoid premature generality. A theorem over `Fin P` with explicit `Finset` search is much better than an abstract semiring theorem that never closes.
- If function extensionality and decidable equality on melodies become awkward, represent melodies as `Vector ℤ n` or `Fin n → Fin P`.
- Use helper lemmas:
  - nonnegativity of each penalty,
  - sum zero iff all zero,
  - cardinality/diversity monotonicity under set inclusion,
  - finite existence of minima over `Finset`.

---

## Concrete Milestone Theorem List

A strong deliverable would include at least these formally proved results:

1. `forbiddenVerticalPenalty_nonneg`
2. `melodicLeapPenalty_nonneg`
3. `parallelPerfectPenalty_nonneg`
4. `firstSpeciesLegal_of_zeroCost`
5. `zeroCost_of_firstSpeciesLegal`
6. `firstSpecies_iff_zeroCost`
7. `tropical_optimum_exists` for finite candidate sets
8. `tropical_dynamic_programming`
9. `minimizer_is_legal_of_large_penalties`
10. `exists_pareto_optimal_melody`
11. one explicit worked finite example showing:
    - a strict/Palestrina minimizer,
    - a distinct higher-variety melody with larger strict cost.

That last example matters. It converts philosophy into a certified witness.

---

## Revolutionary Significance

If you can prove these theorems, you will have created a formal mathematical language in which:
- style rules in Renaissance counterpoint become exact tropical feasibility conditions,
- compositional search becomes certified min-plus optimization,
- harmonic richness becomes an information-like dual objective,
- and historical style difference becomes geometry of objective landscapes rather than vague aesthetics.

This would open:
- machine-checked computational music theory,
- verified algorithmic composition,
- tropical aesthetics as a branch of idempotent mathematics,
- and new bridges from music to formal verification and information theory.

The truly radical implication is that artistic style may admit **semiring invariants**: not just descriptive statistics, but theorem-level optimization signatures.

---

## Application Keywords

`tropical algebra`, `min-plus optimization`, `counterpoint`, `voice leading`, `formal music theory`, `constraint satisfaction`, `dynamic programming`, `Pareto optimality`, `idempotent information theory`, `verified synthesis`, `discrete geometry`, `shortest paths`, `finite-horizon control`, `symbolic composition`

---

## Nontriviality Constraint

Do not stop at definitions plus a toy lemma. The minimum acceptable endpoint is:
- one exact equivalence theorem (`iff`),
- one optimization theorem about minimizers under separated penalties,
- one dynamic-programming/tropical recursion theorem,
- and one theorem formalizing the strict-style vs high-variety tradeoff.

If a full Bach “saddle point” theorem is too ambitious in the first pass, prove a rigorous finite Pareto frontier theorem and state clearly that it is the correct formal precursor.

---

## Required Deliverable

In addition to Lean code, produce a structured `FUTURE_DIRECTIONS.md` containing **3–5 concrete breakthrough-level next steps**, for example:
1. extend from two voices to four-part chorale writing via layered tropical hypergraphs;
2. prove a tropical rate-distortion theorem for harmonic variety vs contrapuntal legality;
3. define categorical composition operators on tropical style spaces;
4. connect voice-leading cost to discrete optimal transport and prove stability under transposition;
5. formalize mod-12 pitch-class counterpoint and compare interval-class vs register-sensitive theories.

Be specific, bold, and mathematically actionable.

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

Research domain: Bridges
Research mode: prove
