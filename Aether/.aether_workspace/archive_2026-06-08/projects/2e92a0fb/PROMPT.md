## Soli Deo Gloria

# Assignment: Direction 5 — Phase Transitions in Generation Probability for Random Subgroup Families

Work in **mode: `prove`**.

The mission is not to compute a few small examples of generation probability for wreath products. The mission is to isolate and formalize a **structural mechanism for phase transition** in random generation: a theorem showing that generation probability in permutation groups is governed not by size alone, but by a competition between **entropy of subgroup families** and **index barriers**. The wreath product family \(S_k \wr S_m\) in product action is the first laboratory where this can be made precise.

You should turn the vague slogan

> “imprimitive structure suppresses random generation when block complexity dominates”

into a sequence of exact Lean theorems, a verified computational method, and a compelling scientific narrative.

The catalog reference
`Algebra/SymmGroupGeneration.lean` — especially
`nongeneratingPairProbability_le_maximal_subgroup_sum`
must be used as the core sieve inequality. But do **not** stop at plugging in a bound. The breakthrough is to define and analyze a new complexity statistic for subgroup coverings that predicts the transition.

---

## Central mathematical object to introduce

Define a new notion, not currently in the catalog:

### New definition: subgroup family pressure
For a finite group \(G\) and a finite family \(\mathcal F\) of proper subgroups, define the **pair-generation obstruction mass**
\[
\mathrm{obstruct}(G,\mathcal F) := \sum_{H \in \mathcal F} [G:H]^{-2}.
\]
More generally, for a family indexed by a parameter space \(I\),
\[
\mathrm{pressure}(G,\mathcal F) := \sum_{H \in \mathcal F} \frac{1}{[G:H]^2}.
\]

This is the correct finite-group analogue of a partition function in statistical physics: each subgroup is a “defect state,” and index contributes an energy penalty \(2 \log [G:H]\), while multiplicity contributes entropy.

You should formalize a version specialized to finite families of subgroups of a finite group. This is the right new concept because the subgroup sieve exactly bounds nongeneration probability by such a pressure term.

### Suggested Lean 4 definition shape
You may need to adapt to existing Mathlib APIs for finite groups and subgroup indexing, but the target shape should be close to:

```lean
def subgroupPairPressure
    (G : Type*) [Group G] [Fintype G]
    (ι : Type*) [Fintype ι]
    (H : ι → Subgroup G) : ℚ :=
  ∑ i, ((Nat.card (G ⧸ H i)) : ℚ)⁻¹ ^ (2 : ℕ)
```

or, if quotient cardinality is inconvenient, use subgroup cardinality:

```lean
def subgroupPairPressure'
    (G : Type*) [Group G] [Fintype G]
    (ι : Type*) [Fintype ι]
    (H : ι → Subgroup G) : ℚ :=
  ∑ i, ((Nat.card (H i) : ℚ) / Nat.card G) ^ (2 : ℕ)
```

and prove equivalence when Lagrange/index lemmas are available.

This definition is novel and scientifically meaningful.

---

## Exact theorem targets

You must prove at least **3 nontrivial theorems**, with multi-step proofs. At least one theorem must connect to another domain. Avoid toy statements.

### Theorem 1: Pressure bound for nongeneration
Abstract and foundational.

**Mathematical statement.**  
Let \(G\) be a finite group, and let \(\mathcal F\) be a finite family of proper subgroups such that every nongenerating pair \((x,y)\in G^2\) lies in some member of \(\mathcal F\). Then
\[
\mathbb P(\langle x,y\rangle \neq G) \le \sum_{H\in\mathcal F} [G:H]^{-2}.
\]
This should be obtained by combining the catalog sieve theorem with your pressure definition.

**Lean target signature sketch**
```lean
theorem nongeneratingPairProbability_le_pressure
    (G : Type*) [Group G] [Fintype G]
    (ι : Type*) [Fintype ι]
    (H : ι → Subgroup G)
    (hcover :
      ∀ x y : G, Subgroup.closure ({x, y} : Set G) ≠ ⊤ →
        ∃ i, x ∈ H i ∧ y ∈ H i) :
    nongeneratingPairProbability G ≤ subgroupPairPressure G ι H
```

If the catalog theorem is phrased using maximal subgroups, prove an intermediate theorem reducing an arbitrary covering family to a maximal-subgroup family, or package your family as a covering family and then invoke
`nongeneratingPairProbability_le_maximal_subgroup_sum`.

**Why this matters.**  
This theorem is the bridge from group theory to statistical mechanics. It says that random generation is controlled by a partition function over defect subgroups. This is the conceptual breakthrough: “generation probability” becomes an emergent observable from subgroup thermodynamics.

---

### Theorem 2: Monotonicity under family refinement / entropy-energy comparison
This theorem extracts the phase-transition mechanism.

**Mathematical statement.**  
If \(\mathcal F\) and \(\mathcal F'\) are subgroup families with
\[
\forall H \in \mathcal F,\ \exists H' \in \mathcal F',\ H \subseteq H',
\]
then under suitable index comparison hypotheses,
\[
\mathrm{obstruct}(G,\mathcal F) \le \mathrm{obstruct}(G,\mathcal F').
\]
A more useful version: if a family contains \(N\) subgroups each of index at most \(d\), then
\[
\mathrm{obstruct}(G,\mathcal F) \ge N d^{-2}.
\]
And if every subgroup in \(\mathcal F\) has index at least \(D\), then
\[
\mathrm{obstruct}(G,\mathcal F) \le |\mathcal F| D^{-2}.
\]

These inequalities create the **entropy-energy principle**:
- many moderate-index subgroups force nongeneration,
- sparse high-index subgroups are negligible.

**Lean target signature sketches**
```lean
theorem subgroupPairPressure_le_card_mul_invIndexSq
    (G : Type*) [Group G] [Fintype G]
    (ι : Type*) [Fintype ι]
    (H : ι → Subgroup G)
    (D : ℕ)
    (hD : ∀ i, D ≤ Nat.card (G ⧸ H i)) :
    subgroupPairPressure G ι H ≤ Fintype.card ι / (D : ℚ)^2
```

```lean
theorem card_mul_invIndexSq_le_subgroupPairPressure
    (G : Type*) [Group G] [Fintype G]
    (ι : Type*) [Fintype ι]
    (H : ι → Subgroup G)
    (d : ℕ)
    (hd : ∀ i, Nat.card (G ⧸ H i) ≤ d) :
    (Fintype.card ι : ℚ) / (d : ℚ)^2 ≤ subgroupPairPressure G ι H
```

You may need positivity hypotheses and field manipulations. This is good: use `field_simp`, `nlinarith`, `calc`, monotonicity of inversion on positive rationals/reals.

**Why this matters.**  
This theorem is the formal skeleton of phase transition. It separates **entropy** (number of bad subgroups) from **energy** (index penalty), exactly mirroring free-energy competition in statistical physics.

---

### Theorem 3: Product-family factorization
This is the first genuinely new structural theorem and the most promising route to a phase transition statement for wreath-like constructions.

Suppose \(G\) and \(K\) are finite groups, with subgroup families \(\mathcal F\) in \(G\) and \(\mathcal E\) in \(K\). Consider the product family
\[
\mathcal F \times \mathcal E := \{H \times L : H \in \mathcal F,\ L \in \mathcal E\}
\]
inside \(G \times K\). Then
\[
\mathrm{obstruct}(G\times K,\mathcal F\times\mathcal E)
= \mathrm{obstruct}(G,\mathcal F)\,\mathrm{obstruct}(K,\mathcal E).
\]

This is the exact multiplicative law expected of a partition function. It gives a rigorous mechanism for sharp transitions in iterated product or block-structured families.

**Lean target signature sketch**
```lean
theorem subgroupPairPressure_prod
    (G K : Type*) [Group G] [Fintype G] [Group K] [Fintype K]
    (ι κ : Type*) [Fintype ι] [Fintype κ]
    (H : ι → Subgroup G) (L : κ → Subgroup K) :
    subgroupPairPressure (G × K) (ι × κ)
      (fun p => (H p.1).prod (L p.2))
      =
    subgroupPairPressure G ι H * subgroupPairPressure K κ L
```

This theorem will likely require:
- quotient cardinality multiplicativity for product subgroups,
- `Finset.univ.product`,
- a nontrivial `calc` chain converting a double sum to product of sums.

**Why this matters.**  
This is the cleanest formal route from group generation to statistical physics. It says obstruction pressure behaves like a genuine partition function under independent composition. That is a field-opening insight.

---

### Theorem 4: A wreath-product surrogate theorem
Do not wait for full O’Nan–Scott classification before proving something meaningful. Formalize a **surrogate phase transition theorem** for a canonical block-system family inside a product-type model.

Let \(G = (S_k)^m\), viewed as the base group of the wreath product. For each block \(j\), let \(\pi_j : G \to S_k\) be the projection, and for each proper subgroup \(M \le S_k\), define
\[
H_{j,M} := \{ g \in G : \pi_j(g) \in M \}.
\]
Then
\[
[G : H_{j,M}] = [S_k : M],
\]
and therefore
\[
\sum_{j=1}^m \sum_{M \in \mathcal M_k} [G:H_{j,M}]^{-2}
= m \sum_{M \in \mathcal M_k} [S_k:M]^{-2},
\]
where \(\mathcal M_k\) is a chosen family of proper subgroups of \(S_k\), ideally maximal subgroups if available.

This gives a **linear-in-\(m\)** obstruction mass from block defects alone. That is already a rigorous precursor of the conjectured \(m \gg k\) suppression regime.

**Lean target signature sketch**
```lean
theorem blockDefectPressure_eq_mul
    (α : Type*) [Finite α] [DecidableEq α]
    (m : ℕ)
    (ι : Type*) [Fintype ι]
    (M : ι → Subgroup (Equiv.Perm α)) :
    subgroupPairPressure ((Fin m) → Equiv.Perm α) (Fin m × ι)
      (fun p => { g | g p.1 ∈ M p.2 } ) -- adapt to subgroup structure
      =
    m * subgroupPairPressure (Equiv.Perm α) ι M
```

You may need to work with finite direct products as functions `Fin m → G` rather than arbitrary wreath products. That is acceptable if the theorem is explicit about being a surrogate model for the base-group contribution in \(S_k \wr S_m\).

**Why this matters.**  
This is where the conjecture becomes mathematically testable. It shows one side of the competition scales like \(m\), so if the corresponding \(k\)-dependent subgroup pressure does not decay too fast, nongeneration grows with block count. This is a real phase-transition mechanism.

---

### Theorem 5: Cross-domain theorem — logarithmic pressure as free energy
You are required to connect to a different domain. Do it precisely.

Define the **free energy**
\[
F(G,\mathcal F) := -\log \mathrm{obstruct}(G,\mathcal F),
\]
whenever the pressure is positive. Then product-family factorization yields additivity:
\[
F(G\times K,\mathcal F\times\mathcal E) = F(G,\mathcal F) + F(K,\mathcal E).
\]

This is a theorem in the language of statistical mechanics: independent defect systems have additive free energy.

**Lean target signature sketch**
```lean
theorem log_subgroupPairPressure_prod
    (G K : Type*) [Group G] [Fintype G] [Group K] [Fintype K]
    (ι κ : Type*) [Fintype ι] [Fintype κ]
    (H : ι → Subgroup G) (L : κ → Subgroup K)
    (hH : 0 < subgroupPairPressure G ι H)
    (hL : 0 < subgroupPairPressure K κ L) :
    Real.log (subgroupPairPressure (G × K) (ι × κ) (fun p => (H p.1).prod (L p.2)))
      =
    Real.log (subgroupPairPressure G ι H) +
    Real.log (subgroupPairPressure K κ L)
```

Or equivalently with a minus sign if you define free energy directly.

**Why this matters.**  
This is not decorative. It makes the subgroup sieve legible as a thermodynamic theory, and it opens contact with large deviations, percolation thresholds, and entropy methods.

---

## Main conjecture to state explicitly

You must include a falsifiable conjecture with computational content.

### Conjecture: structural phase transition for imprimitive families
Let \(W_{k,m} = S_k \wr S_m\) in product action on \(km\) points, and let \(\mathcal I_{k,m}\) be the family of maximal imprimitive subgroups preserving a nontrivial block system compatible with the wreath structure. Then there exists a critical window for the ratio \(\rho = k/m\) such that:

1. if \(\rho \to \infty\) with \(m\) fixed or slowly growing, then
   \[
   \mathbb P(\langle x,y\rangle = W_{k,m}) = 1 - O(k^{-1});
   \]
2. if \(\rho \to 0\) with \(k\) fixed and \(m \to \infty\), then
   \[
   \mathbb P(\langle x,y\rangle = W_{k,m}) \le \exp(-c m)
   \]
   for some \(c = c(k) > 0\) or at least is bounded away from \(1\);
3. the transition is governed by the sign change of an effective free energy
   \[
   \Phi(k,m) := \log |\mathcal I_{k,m}| - 2 \log \operatorname{mindegIndex}(\mathcal I_{k,m}).
   \]

This is falsifiable: compute subgroup-family counts and index data for \(km \le 12\) and compare observed generation probability to the sign/magnitude of \(\Phi(k,m)\).

### Computational test
Using GAP or Sage/GAP:
- enumerate \(W_{k,m}\) for \(km \le 12\),
- estimate exact or Monte Carlo pair-generation probability,
- enumerate imprimitive maximal subgroups or a certified covering subfamily,
- compute pressure
  \[
  \sum_H [W_{k,m}:H]^{-2},
  \]
- plot against \(k/m\),
- identify whether the empirical transition correlates with the pressure/free-energy statistic.

A single counterexample with badly mismatched pressure and generation probability would refute the strongest version of the conjecture.

---

## Proof strategy architecture

You must not present one route only. Build 2–3 pathways.

### Strategy A: Abstract pressure theory first, wreath later
Most promising.

1. Define `subgroupPairPressure` and prove universal inequalities:
   - positivity,
   - upper/lower bounds via cardinality and minimal/maximal index,
   - compatibility with coverings.
2. Prove product factorization and logarithmic additivity.
3. Model wreath-product block defects via direct products/functions `Fin m → G`.
4. Use catalog generation-sieve theorems to turn these pressure bounds into nongeneration bounds.

**Why most promising:** it creates a reusable theory independent of the full O’Nan–Scott classification and gives immediate publishable structure even before the full wreath-product theorem is complete.

### Strategy B: Maximal-subgroup enumeration for small wreath families
Concrete and computational.

1. For low-dimensional cases \(S_k \wr S_m\) with \(km \le 12\), identify the relevant maximal imprimitive subgroups explicitly.
2. Prove exact pressure formulas for these cases.
3. Compare exact pressure with exact generation probability.
4. Infer candidate asymptotics and formulate the general theorem/conjecture.

**Why useful:** it grounds the theory experimentally and may reveal the right critical parameter before full general formalization.

### Strategy C: Base-group surrogate + asymptotic transfer
Ambitious hybrid.

1. Work first with \(G^m\) and coordinate-defect subgroups.
2. Prove linear growth of pressure in \(m\) for block-defect families.
3. Show how semidirect permutation of coordinates by \(S_m\) preserves or amplifies obstruction families.
4. Transfer the surrogate theorem to heuristic or partial bounds for \(S_k \wr S_m\).

**Why useful:** avoids immediate dependence on the entire subgroup classification while still targeting the genuine wreath-product phenomenon.

---

## Cross-domain connections you must explicitly develop

At least one theorem and one discussion section must bridge to another area.

### 1. Statistical physics
Interpret pressure as a partition function and \(-\log\) pressure as free energy.  
Keywords: **partition function, free energy, entropy-energy competition, phase transition, defect states**.

### 2. Probabilistic combinatorics
Generation probability becomes a covering/rare-event problem over structured bad events.  
Keywords: **Janson inequalities, union bound sharpness, threshold phenomena, random structures**.

### 3. Information theory
Pressure is a complexity measure for the “bad set” of nongenerating pairs. Explore whether
\[
-\log \mathrm{obstruct}(G,\mathcal F)
\]
behaves like a code length or surprisal for structural obstructions.  
Keywords: **entropy, surprisal, coding complexity**.

### 4. Permutation-group complexity
The key insight is that **structural complexity** of maximal subgroup geometry, not order alone, controls random generation.  
Keywords: **O’Nan–Scott, imprimitive action, maximal subgroup geometry, subgroup growth**.

---

## Lean formalization guidance

You should target finite groups with APIs already comfortable in Mathlib:
- `Group`, `Fintype`, `Finite`
- `Subgroup`
- finite sums over `Finset.univ`
- quotient cardinalities if available; otherwise use subgroup cardinality ratios and prove conversion lemmas
- direct products `G × K`
- finite products `(Fin m) → G`

If quotient cardinality is cumbersome, define pressure via subgroup cardinality:
\[
\sum_H (|H|/|G|)^2
\]
and prove equivalence with index form using Lagrange.

Useful intermediate lemmas likely needed:
- cardinality of product subgroup,
- cardinality/index of coordinate-cylinder subgroup in a finite product,
- positivity of index/cardinality terms,
- sum over product type equals product of sums.

You must avoid trivialized proofs. Use:
- `rcases` to unpack covering hypotheses,
- `by_contra` for positivity/nonvanishing arguments if needed,
- `field_simp` for rational identity proofs,
- induction on finite products or `Fin m`,
- multi-step `calc` chains for sum-factorization.

---

## Minimum theorem list to include in the Lean file

At least these 3, preferably 4–5:

1. `nongeneratingPairProbability_le_pressure`
2. `subgroupPairPressure_le_card_mul_invIndexSq`
3. `subgroupPairPressure_prod`
4. one block-family theorem for `(Fin m → G)` or `(G × K)`
5. one cross-domain logarithmic/free-energy theorem

All proofs should be mathematically substantive.

---

## Verified algorithm / computational method

You must produce a verified computational method, not just a theorem.

### Required algorithm
Implement a pressure estimator / exact calculator for finite subgroup families:

- input:
  - a finite group \(G\),
  - a finite family of subgroups \(H_i\),
- output:
  - `subgroupPairPressure`,
  - upper bound on nongeneration probability,
  - free energy `-log pressure` when pressure > 0.

In Lean, certify correctness of the formula. In Python/GAP, compute examples for wreath products and direct-product surrogates.

### Required `demo.py`
`demo.py` must:
- compute or query GAP for \(S_k \wr S_m\) with \(km \le 12\),
- estimate/compute pair-generation probability,
- compute subgroup-family pressure for selected imprimitive/block families,
- plot probability and pressure/free-energy against \(k/m\),
- print candidate transition regions.

This demo is essential: science requires theorem ↔ experiment feedback.

---

## Deliverables — all mandatory

You must produce all of the following:

### 1. `FUTURE_DIRECTIONS.md`
3–5 original research directions.  
Each direction must include the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as statistical physics, information theory, or random matrix theory.

Possible examples to consider:
- free-energy principles for subgroup growth in almost simple groups,
- generation thresholds for classical groups,
- large deviations for random generation,
- coding-theoretic interpretations of subgroup coverings,
- analogies with percolation on subgroup lattices.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper. Someone reading only this document must understand:
- the new definitions,
- the exact theorems,
- why pressure/free energy is the right concept,
- how this illuminates wreath-product phase transitions,
- what experiments support the conjecture,
- what the next conjectures are.

Do not assume access to code.

### 3. `ARTICLE.md`
Scientific American style.  
Explain the discovery as a story about how hidden subgroup structure creates a tipping point in randomness.  
**Taboo:** do not focus on formal verification machinery. Focus on the mathematics, the idea of phase transition, and why it changes how we think about symmetry.

### 4. Verified algorithm / computational method
As above.

### 5. `demo.py`
Interactive demonstration as above.

---

## Application keywords

Include these explicitly in the paper and metadata-style comments:

**application keywords:** random generation, permutation groups, wreath products, imprimitive subgroups, subgroup sieve, phase transitions, statistical physics, partition function, free energy, entropy-energy competition, probabilistic combinatorics, O’Nan–Scott theory, subgroup growth, threshold phenomena.

---

## Final ambition

Do not treat this as “prove a bound for a special family.” Treat it as the birth of a new theory:

> **subgroup thermodynamics** — a framework in which random generation is governed by a partition function over structural obstructions.

If you can formalize even the surrogate product/block theorem cleanly, together with pressure bounds and convincing experiments for \(S_k \wr S_m\), that already opens a new field. The full O’Nan–Scott classification can come next. The point now is to identify and certify the invariant that explains the transition.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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
