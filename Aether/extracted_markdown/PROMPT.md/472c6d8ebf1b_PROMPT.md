Soli Deo Gloria

## Assignment: The Diagonal Ramsey Gap — Closing the Exponential Window

**Mode:** `prove`

Aristotle, do not merely formalize a folklore estimate. Build the first genuinely structural Lean 4 theory of the probabilistic method for diagonal Ramsey lower bounds, with the Lovász Local Lemma as the engine that breaks the first-moment barrier. The target is not an isolated inequality: it is a reusable architecture for dependent-event combinatorics, asymptotic lower bounds, and verified probabilistic existence.

Your mission is to prove new, non-trivial theorems around the statement that for sufficiently large `k`,
\[
R(k,k) \;>\; c\,2^{k/2}
\]
with an explicit constant `c > 1`, by formalizing the dependency graph of monochromatic clique events and deriving the classical LLL-based improvement
\[
R(k,k) \;>\; \frac{\sqrt 2}{e}\,k\,2^{k/2}
\]
or at minimum a rigorously certified explicit lower bound of the form
\[
R(k,k) \;>\; C\,k\,2^{k/2}
\quad\text{for some concrete } C>0.
\]
This is the real breakthrough: the first-moment argument only sees expectation; the Local Lemma sees the sparse geometry of dependencies. Formalizing that leap opens a new verified theory of high-dimensional rare-event avoidance.

## Core theorem targets

You must prove at least **3 substantial theorems** with nontrivial proof structure. At least one must introduce a **new definition** not already in the catalog, and at least one must make a **cross-domain connection**.

### New definitions to introduce

1. **Ramsey bad event family** for `k`-subsets of vertices in a 2-coloring.
2. **Dependency degree** of a bad event under clique overlap.
3. **LLL admissibility predicate** specialized to diagonal Ramsey events.

Suggested Lean-level structures:

```lean
def monochromaticOn (χ : Sym2 α → Fin 2) (s : Finset α) : Prop := ...
def ramseyBadEvent (χ : Sym2 α → Fin 2) (s : Finset α) (k : ℕ) : Prop := ...
def ramseyDependency (s t : Finset α) : Prop := ...
def lllRamseyAdmissible (n k : ℕ) : Prop := ...
```

If `Sym2 α` is inconvenient, use an equivalent edge type already present in Mathlib/catalog references. But define the event family explicitly enough that the dependency graph theorem is transparent.

---

## Precise theorem statements

### Theorem 1: Exact dependency criterion for clique bad events
Two monochromatic-`k`-clique bad events are independent unless the underlying `k`-sets share at least two vertices.

Mathematically:
For distinct `k`-subsets `S,T ⊆ V`, if `|S ∩ T| ≤ 1`, then the edge sets induced by `S` and `T` are disjoint, hence the corresponding bad events depend on disjoint coordinates of the random coloring and are independent.

Suggested Lean 4 signature:
```lean
theorem edge_disjoint_of_intersection_card_le_one
    {α : Type*} [DecidableEq α]
    {s t : Finset α}
    (hs : 2 ≤ s.card) (ht : 2 ≤ t.card)
    (hinter : (s ∩ t).card ≤ 1) :
    Disjoint
      ((s.sym2Filter fun _ => True))
      ((t.sym2Filter fun _ => True)) := ...
```

If `sym2Filter` is not the right existing API, replace with your own finite edge-set construction:
```lean
def inducedEdges (s : Finset α) : Finset (Sym2 α) := ...
```
and prove
```lean
theorem inducedEdges_disjoint_of_inter_card_le_one ... : Disjoint (inducedEdges s) (inducedEdges t) := ...
```

**Why this matters:** this is the combinatorial skeleton of the LLL argument. It isolates dependency in overlap geometry rather than probability theory.

---

### Theorem 2: Explicit upper bound on dependency degree
For a fixed `k`-subset `S` of an `n`-vertex set, the number of `k`-subsets `T` with `|S ∩ T| ≥ 2` is at most
\[
\binom{k}{2}\binom{n-2}{k-2}.
\]

Suggested Lean 4 signature:
```lean
theorem ramsey_dependency_degree_le
    (n k : ℕ) :
    ramseyDependencyDegree n k ≤ Nat.choose k 2 * Nat.choose (n - 2) (k - 2) := ...
```

Or, if you index events by `Finset (Fin n)`:
```lean
theorem card_k_subsets_intersecting_in_two_or_more_le
    (n k : ℕ) :
    Fintype.card {t : Finset (Fin n) //
      t.card = k ∧ 2 ≤ (t ∩ s).card}
    ≤ Nat.choose k 2 * Nat.choose (n - 2) (k - 2) := ...
```

This theorem should use genuine counting, injections, or double counting—not brute force.

**Why this matters:** this is where dependency becomes quantitatively sparse enough for the Local Lemma to fire.

---

### Theorem 3: Probability of a monochromatic `k`-clique bad event
For a uniformly random red/blue edge coloring, the probability that a fixed `k`-set spans a monochromatic clique is exactly
\[
p_k = 2^{1-\binom{k}{2}}.
\]

Suggested Lean 4 signature:
```lean
theorem prob_ramseyBadEvent_eq
    (k : ℕ) :
    ramseyBadEventProb k = (2 : ℝ) ^ (1 - Nat.choose k 2) := ...
```

If exact probability is too API-heavy in the current probability stack, prove a certified upper bound:
```lean
theorem prob_ramseyBadEvent_le
    (k : ℕ) :
    ramseyBadEventProb k ≤ (2 : ℝ) * (2 : ℝ) ^ (-(Nat.choose k 2 : ℤ)) := ...
```

But the exact expression is strongly preferred.

**Why this matters:** this theorem converts clique geometry into an exponential rare-event estimate.

---

### Theorem 4: LLL criterion specialized to diagonal Ramsey
Prove a usable one-parameter Local Lemma criterion:
if
\[
e\,p\,(d+1) \le 1,
\]
where `p = 2^{1-\binom{k}{2}}` and `d` is the dependency degree bound, then there exists a 2-coloring of `K_n` with no monochromatic `K_k`, hence
\[
R(k,k) > n.
\]

Suggested Lean 4 signature:
```lean
theorem ramsey_lower_bound_of_lll
    {n k : ℕ}
    (hlll :
      Real.exp 1 * ramseyBadEventProb k * (ramseyDependencyDegree n k + 1) ≤ 1) :
    diagonalRamsey k > n := ...
```

You may need a formal definition:
```lean
def diagonalRamsey (k : ℕ) : ℕ := ...
```
or use an existing one from the catalog if already present. If a direct definition of `R(k,k)` is not available, prove the existence statement in equivalent graph-coloring form:
```lean
theorem exists_coloring_without_mono_clique_of_lll ... :
  ∃ χ : Sym2 (Fin n) → Fin 2, ¬ ∃ s : Finset (Fin n), s.card = k ∧ monochromaticOn χ s := ...
```

**Why this matters:** this is the theorem that turns probabilistic combinatorics into verified existential mathematics.

---

### Theorem 5: Explicit asymptotic lower bound
Derive an explicit corollary of the form
\[
\exists k_0,\ \forall k \ge k_0,\quad R(k,k) > \left\lfloor \frac{\sqrt 2}{e}\,k\,2^{k/2} \right\rfloor
\]
or a nearby explicit constant that your formal inequalities can support.

Suggested Lean 4 signature:
```lean
theorem eventually_diagonalRamsey_gt_explicit
    ∃ k0 : ℕ, ∀ k ≥ k0,
      diagonalRamsey k >
        Nat.floor (((Real.sqrt 2) / Real.exp 1) * k * 2^(k/2 : ℝ)) := ...
```

If floor/coercion complexity becomes prohibitive, a weaker but still explicit natural-number statement is acceptable:
```lean
theorem eventually_diagonalRamsey_gt_linear_times_pow
    ∃ k0 C : ℕ, C > 0 ∧
      ∀ k ≥ k0, diagonalRamsey k > C * k * 2^(k/2) := ...
```

But the scientifically meaningful target is the classical `(\sqrt 2/e) k 2^{k/2}` scale.

**Why this matters:** this closes the conceptual gap between local dependency counting and asymptotic Ramsey growth.

---

## Lean 4 proof architecture: 3 proof strategies

### Strategy A: Event-family-first LLL formalization
1. Define bad events as predicates on edge colorings restricted to induced edge sets of `k`-subsets.
2. Prove independence from edge disjointness using product probability on finite coordinate spaces.
3. Apply a symmetric LLL theorem from the catalog, or formalize the needed symmetric finite version if absent.

**Why promising:** modular, reusable, and scales to hypergraph Ramsey and van der Waerden-type statements. Best route if `Algebra/Ramsey/Probabilistic` already contains finite random-coloring infrastructure.

---

### Strategy B: Pure finite-combinatorial encoding before probability
1. Build the finite edge universe `E = Sym2 (Fin n)`.
2. Encode each bad event by a finite subset `A_s ⊆ E`.
3. Prove all structural lemmas combinatorially: disjointness, overlap, dependency degree.
4. Only then attach the uniform product measure and discharge the probability calculation.

**Why promising:** reduces probability-theory friction. Most of the mathematical substance is finite-set combinatorics, where Lean is strong once the right lemmas exist.

---

### Strategy C: Entropy/rare-event reinterpretation for cross-domain theorem
1. Interpret a coloring as a binary string over edges.
2. Show bad-event avoidance is a constrained code in Hamming cube language.
3. Use the LLL criterion to certify nonemptiness of a high-dimensional constraint-satisfaction code.

**Why promising:** this yields the required cross-domain connection to information theory and statistical mechanics. It may not be the shortest path to the main theorem, but it can produce a striking auxiliary theorem and future research platform.

**Recommended route:** Combine **B → A**, then add **C** as a conceptual corollary. First nail the finite dependency graph and exact counts; then invoke probability; then reinterpret the result as a sparse constraint-satisfaction phenomenon in the Boolean cube.

---

## Cross-domain connection requirement

You must include at least one theorem connecting Ramsey-Lovász-local-lemma combinatorics to another field.

### Cross-domain theorem candidate: constraint satisfaction / statistical mechanics
Interpret edge colorings of `K_n` as spin configurations in an Ising-type system on the complete graph, with each monochromatic `K_k` as a forbidden local pattern. Then prove:

> If the LLL criterion holds, the zero-temperature hard-constraint Gibbs state has nonempty support.

Suggested Lean statement:
```lean
theorem nonempty_hardcore_ramsey_configuration_space_of_lll
    {n k : ℕ}
    (hlll :
      Real.exp 1 * ramseyBadEventProb k * (ramseyDependencyDegree n k + 1) ≤ 1) :
    Nonempty {χ : Sym2 (Fin n) → Fin 2 // avoidsMonochromaticKCliques χ k} := ...
```

This is mathematically equivalent to the Ramsey lower bound existence statement, but conceptually it links:
- probabilistic combinatorics,
- statistical mechanics of hard constraints,
- coding theory in the Boolean cube.

### Alternative cross-domain theorem candidate: coding-theoretic interpretation
Prove that the family of valid colorings avoiding monochromatic `K_k` forms a nonempty constrained binary code of block length `choose n 2`.

Application keywords: **probabilistic combinatorics, Lovász Local Lemma, random structures, dependency graphs, coding theory, hard-constraint spin systems, extremal combinatorics, entropy method, rare-event geometry**.

---

## Catalog leverage

Build explicitly on `Algebra/Ramsey/Probabilistic` and any vetted final theorem therein about:
- existence of random graph/coloring objects,
- first-moment Ramsey lower bounds,
- finite clique counting,
- combinatorial counting over `Fin n`,
- probability on finite product spaces.

Do not merely cite these. Explain in comments and paper text exactly how each catalog theorem is upgraded:
- first-moment bound uses only `E[number of bad events] < 1`,
- your LLL framework replaces global expectation with local dependency degree,
- the dependency graph is extracted from overlap cardinality,
- the asymptotic constant is improved by sparse dependence rather than better union bounds.

If a catalog theorem already proves a first-moment lower bound such as
\[
R(k,k) > c_0 \sqrt{k}\,2^{k/2}
\]
or a nearby expression, your theorem must explicitly dominate it for all sufficiently large `k` and computationally verify the crossover range.

---

## Scientific significance

This project is not “formalizing a known proof.” It is the verified birth of **dependent-event probabilistic combinatorics** as an executable theory. Once the Local Lemma machinery is established in this concrete Ramsey setting, the same architecture can attack:
- hypergraph Ramsey lower bounds,
- van der Waerden and Szemerédi-type avoidance constructions,
- sparse SAT existence,
- random CSP thresholds,
- container-method precursors,
- coding-theoretic forbidden-pattern constructions.

The revolutionary point is this: verification has handled many deterministic extremal arguments and some independent-event probability. But the Local Lemma is where combinatorics becomes genuinely nonlocal. Capturing that dependence geometry in Lean would open an entire frontier.

---

## Conjecture with testable prediction

You must include at least one falsifiable conjecture with a clear computational disproof criterion.

### Required conjecture
**Conjecture.**
There exists `k0` such that for all `k ≥ k0`,
\[
R(k,k) > \left\lfloor 1.1 \cdot 2^{k/2}\right\rfloor.
\]

This is weaker than the classical `(\sqrt2/e)k2^{k/2}` scale and should follow from your stronger theorem if achieved.

### Computational test
Implement a function computing:
1. the first-moment lower-bound witness `n_FM(k)`,
2. the LLL lower-bound witness `n_LLL(k)` from your certified dependency formula.

Then verify for `k = 4,\dots,10` that
\[
n_{LLL}(k) \ge n_{FM}(k),
\]
and identify the first `k` where strict inequality appears.

**Falsification criterion:** if the certified implementation produces `n_LLL(k) < n_FM(k)` for any tested `k`, then either the formalized formulas or the computational extraction is wrong. This is a genuine software-science falsifier for the pipeline.

### Stronger scientific conjecture
**Hypothesis A.**
The dependency-graph formalization developed here extends with only definitional changes to `r`-color Ramsey lower bounds:
\[
R_r(k) > C_r\,k^{\alpha_r} r^{k/2}
\]
for explicit constants from the symmetric LLL.

**Test:** instantiate the same machinery for `Fin r` edge colors and compare computed lower-bound witnesses for `r=3`.

---

## Implementation expectations

Your Lean development must contain:
- at least **3 nontrivial theorems** proved by induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc`,
- at least **1 new definition**,
- at least **1 cross-domain theorem**,
- no fake depth via decidable brute force,
- minimized `sorry`.

If a deep theorem must temporarily remain partially blocked by missing API, isolate it behind small helper lemmas and prove as much of the combinatorial core as possible. But the final artifact should strive to leave only narrow technical gaps, not conceptual ones.

---

## Deliverables (ALL mandatory)

1. **Lean file(s)** with the new definitions and at least 3 deep theorems.
2. **FUTURE_DIRECTIONS.md** containing **3–5 testable scientific hypotheses**, each falsifiable with a clear computational or formal test.
3. **RESEARCH_PAPER.md** as a **standalone scientific paper**: motivation, theorem statements, proof ideas, significance, computational experiments, and next problems. A reader with no code access must understand the discovery.
4. **ARTICLE.md** in **Scientific American style**, accessible and engaging, focused on the mathematical ideas and why dependent randomness changes the Ramsey landscape. Do **not** focus on verification machinery.
5. **A verified algorithm/computational method** computing certified first-moment and LLL lower-bound witnesses.
6. **demo.py** demonstrating the result interactively: input `k`, output the certified bounds, compare first-moment vs LLL, and visualize dependency degree growth.

---

## Concrete build order

1. Formalize finite induced edge sets of `k`-vertex subsets.
2. Prove edge-disjointness from intersection size `≤ 1`.
3. Count or bound the number of dependent bad events.
4. Compute the bad-event probability exactly.
5. State and apply the symmetric finite LLL.
6. Derive explicit Ramsey lower bounds.
7. Add the coding/statistical-mechanics interpretation.
8. Implement the certified bound calculator and demo.

---

## Application keywords

**Ramsey theory, probabilistic combinatorics, Lovász Local Lemma, dependency graphs, random colorings, extremal graph theory, coding theory, Boolean cube, statistical mechanics, hard constraints, entropy, rare events, asymptotic lower bounds, executable mathematics**

---

## Final charge

Do not settle for “the LLL can probably be formalized.” Formalize the dependency geometry so cleanly that it becomes a reusable language. The theorem to aim for is not just a better bound on `R(k,k)`; it is the emergence of a verified calculus of sparse dependence. That is the field-opening move.

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
