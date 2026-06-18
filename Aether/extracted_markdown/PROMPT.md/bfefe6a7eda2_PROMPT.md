# Soli Deo Gloria

## Assignment: Direction 1: Sharp Dixon Asymptotics via Möbius Inversion

**Mode:** `prove`

Aristotle, push this past the existing maximal-subgroup sieve and turn generation in symmetric groups into an exact incidence-algebra computation. The breakthrough is not merely to sharpen a bound, but to **replace the probabilistic upper-bound paradigm by an exact subgroup-lattice formula** and then extract asymptotics from the geometry of the subgroup poset. If successful, this opens a new formal interface between **finite group generation, incidence algebras, analytic combinatorics, and computational subgroup theory**.

The existing catalog result
- `Algebra/SymmGroupGeneration.lean`
  - `nongeneratingPairProbability_le_maximal_subgroup_sum`
  - `generatingPairProbability_eq_card_ratio`

already gives a sieve-theoretic entry point. Your task is to leap from “generation is controlled by maximal obstructions” to “generation is governed exactly by Möbius inversion on the subgroup lattice.”

---

## Core theorem targets

You should formalize a finite-poset/incidence-algebra framework specialized enough to be usable for subgroup lattices of finite groups, and then prove exact formulas for generating-pair counts. The asymptotic component should at minimum rigorously recover the first nontrivial terms beyond the crude sieve.

### New definitions you should introduce

At least one genuinely new definition is required. I recommend the following package.

1. **Subgroup-lattice Möbius coefficient**
   ```lean
   def subgroupMoebiusTop (G : Type*) [Group G] [Fintype G]
       (H : Subgroup G) : ℤ := ...
   ```
   Intended meaning: the Möbius function value `μ(H, ⊤)` in the finite poset of subgroups of `G`.

2. **Generating pair count**
   ```lean
   def generatingPairCount (G : Type*) [Group G] [Fintype G] : ℕ :=
     Fintype.card { p : G × G // Subgroup.closure (Set.range p.1.1 ∪ Set.range p.1.2) = ⊤ }
   ```
   If this exact encoding is awkward, define it via
   ```lean
   def IsGeneratingPair (p : G × G) : Prop := Subgroup.closure ({p.1, p.2} : Set G) = ⊤
   ```
   and then count the subtype.

3. **Pair-containment counting function**
   ```lean
   def pairCountInSubgroup (G : Type*) [Group G] [Fintype G] (H : Subgroup G) : ℕ :=
     (Fintype.card H)^2
   ```
   This is the zeta-transform input on the subgroup lattice.

These definitions are not cosmetic: they create a formal bridge from subgroup generation to incidence algebra.

---

## Precise theorem statements

You should aim for at least the following three theorems.

### Theorem 1: Exact Möbius inversion formula for generating pairs

For every finite group `G`, the number of generating pairs equals the Möbius-weighted sum over all subgroups.

**Mathematical statement**
\[
\#\{(x,y)\in G^2 : \langle x,y\rangle = G\}
=
\sum_{H \le G} \mu(H,G)\, |H|^2.
\]

**Lean target signature**
```lean
theorem generatingPairCount_eq_moebius_sum
    (G : Type*) [Group G] [Fintype G] :
    (generatingPairCount G : ℤ) =
      ∑ H : Subgroup G, subgroupMoebiusTop G H * (Fintype.card H : ℤ)^2 := by
  ...
```

A more flexible intermediate theorem, likely easier to prove first:

```lean
theorem pairCountInSubgroup_moebius_inversion
    (G : Type*) [Group G] [Fintype G] :
    ∀ K : Subgroup G,
      (Fintype.card K : ℤ)^2 =
        ∑ H : Subgroup G, if H ≤ K then
          (show ℤ from generatingPairCountWithin H) else 0 := by
  ...
```

Then invert on the finite lattice.

### Theorem 2: Exact decomposition by proper subgroups / complementary formula

This theorem rewrites the generation probability as one minus a normalized Möbius-corrected obstruction sum. It is the bridge from exact counting to asymptotics.

**Mathematical statement**
\[
\frac{\#\{(x,y):\langle x,y\rangle=S_n\}}{|S_n|^2}
=
1 + \sum_{H<S_n}\mu(H,S_n)\frac{|H|^2}{|S_n|^2}.
\]

**Lean target signature**
```lean
theorem generatingPairProbability_eq_one_add_proper_subgroup_sum
    (n : ℕ) :
    generatingPairProbability (Equiv.Perm (Fin n)) =
      1 + ∑ H : Subgroup (Equiv.Perm (Fin n)),
        if H = ⊤ then 0 else
          (subgroupMoebiusTop (Equiv.Perm (Fin n)) H : ℚ) *
            ((Fintype.card H : ℚ)^2 / (Fintype.card (Equiv.Perm (Fin n)) : ℚ)^2) := by
  ...
```

You may need to adapt to the exact probability definition in the catalog. The point is to derive a normalized identity suitable for estimation.

### Theorem 3: First asymptotic correction from point stabilizers

This is the first truly nontrivial asymptotic theorem and should be formalized with explicit bounds. At minimum, prove the first-order term rigorously and isolate the second-order contribution if possible.

**Mathematical statement**
Let
\[
P_n := \mathbb P\big(\langle \sigma,\tau\rangle = S_n\big), \qquad \sigma,\tau \text{ uniform in } S_n.
\]
Then for all sufficiently large `n`,
\[
\left|P_n - \left(1-\frac1n\right)\right| \le \frac{C}{n^2}
\]
for some explicit constant `C`.

A stronger target, if feasible:
\[
\left|P_n - \left(1-\frac1n-\frac1{n^2}\right)\right| \le \frac{C}{n^3}.
\]

**Lean target signature**
```lean
theorem generatingPairProbability_sub_one_add_inv_bound
    ∃ C : ℚ, ∀ ⦃n : ℕ⦄, n ≥ 2 →
      |generatingPairProbability (Equiv.Perm (Fin n)) - (1 - (1 : ℚ) / n)| ≤ C / n^2 := by
  ...
```

Possible stronger signature:
```lean
theorem generatingPairProbability_two_term_asymptotic
    ∃ C : ℚ, ∀ ⦃n : ℕ⦄, n ≥ 3 →
      |generatingPairProbability (Equiv.Perm (Fin n)) -
        (1 - (1 : ℚ) / n - (1 : ℚ) / n^2)| ≤ C / n^3 := by
  ...
```

Do not overpromise the full Dixon expansion unless the subgroup classification inputs are genuinely in reach. A rigorously formalized first- or second-order asymptotic with exact Möbius identity is already a conceptual breakthrough.

---

## Why this would be revolutionary

Dixon-type asymptotics are classical, but formal work has so far lived mostly at the level of coarse subgroup sieves. Your project would create the first verified pipeline:

1. **exact finite-group generation formula via incidence algebra,**
2. **specialization to symmetric groups,**
3. **asymptotic extraction from subgroup geometry,**
4. **computational validation for small `n`.**

That changes the game. It suggests a general program for:
- random generation in other finite simple groups,
- subgroup-growth asymptotics,
- probabilistic Galois theory,
- expansion heuristics in computational group theory,
- and even analogies with number-theoretic Möbius inversion and cluster expansions in statistical mechanics.

This is not “one more estimate.” It is the formal birth of **incidence-algebraic probabilistic group theory**.

---

## Proof architecture: 3 viable strategies

You asked for 2–3 proof strategy steps; here are three full routes, with an assessment.

### Strategy A: Direct finite-poset Möbius inversion on the subgroup lattice
**Most conceptually clean; probably the best primary route.**

**Step 1.** Define the subgroup-lattice zeta transform:
\[
F(K) := |K|^2,\qquad
f(H) := \#\{(x,y)\in H^2 : \langle x,y\rangle = H\}.
\]
Prove
\[
F(K)=\sum_{H\le K} f(H).
\]
This is the key combinatorial partition: every pair in `K²` generates a unique subgroup.

**Step 2.** Formalize Möbius inversion on the finite poset of subgroups of a finite group. Then derive
\[
f(G)=\sum_{H\le G}\mu(H,G)|H|^2.
\]

**Step 3.** Normalize by `|G|²` and specialize to `G = S_n`. Compare with the catalog theorem bounding nongeneration by maximal subgroups to derive asymptotic upper/lower envelopes.

**Why promising:** It isolates all difficulty into one general theorem about finite subgroup lattices. Once done, the exact formula becomes reusable across finite group theory.

### Strategy B: Inclusion–exclusion over maximal subgroups, then refine to Möbius coefficients
**Good as an intermediate route if full incidence algebra is too heavy initially.**

**Step 1.** Start from the catalog bound by maximal subgroups. Show the exact nongenerating set is the union
\[
\bigcup_{M \text{ maximal}} M^2.
\]

**Step 2.** Apply inclusion–exclusion over intersections of maximal subgroups, and identify the resulting coefficient of `|H|²` with a subgroup-lattice Möbius coefficient when intersections are grouped by generated subgroup / common containment structure.

**Step 3.** For asymptotics, isolate point stabilizers and maybe 2-point stabilizers as dominant contributions, bounding all other maximal-subgroup families via index growth.

**Why promising:** It leverages existing catalog results immediately. It may be easier to get first-order asymptotics even before the full lattice machinery is elegant.

### Strategy C: Probabilistic subgroup sieve + exact correction terms from dominant conjugacy classes
**Best for asymptotics if exact Möbius inversion stalls.**

**Step 1.** Use
`nongeneratingPairProbability_le_maximal_subgroup_sum`
to identify the point-stabilizer family contribution, giving the `1/n` term.

**Step 2.** Add lower bounds by exhibiting that almost all nongenerating pairs lie in intransitive maximal subgroups of small index. Use double counting over conjugates of `S_{n-1}` and `S_{n-2} × S_2` or similar.

**Step 3.** Prove the remainder from primitive/imprimitive maximal subgroups is `O(1/n^2)` or `O(1/n^3)` using index estimates.

**Why promising:** This is likely the fastest path to a rigorous asymptotic theorem, but it does not by itself produce the exact Möbius formula. Use it as a fallback or parallel track.

**Recommendation:** Pursue **A + C in parallel**. Strategy A gives the conceptual breakthrough; Strategy C guarantees a meaningful asymptotic theorem even if the full subgroup-lattice API becomes technically expensive.

---

## Key lemmas to target

These are the technical stepping stones that should appear as deep, multi-step proofs.

### Lemma 1: Partition of `K × K` by generated subgroup
```lean
theorem card_pairs_eq_sum_card_generatingPairsWithin
    (G : Type*) [Group G] [Fintype G] (K : Subgroup G) :
    ((Fintype.card K : ℤ)^2) =
      ∑ H : Subgroup G, if H ≤ K then (generatingPairCountWithin H : ℤ) else 0 := by
  ...
```
This should require `rcases`, finite decomposition, and careful use of closure/minimality.

### Lemma 2: Möbius orthogonality on subgroup lattice
```lean
theorem subgroupMoebiusTop_convolution
    (G : Type*) [Group G] [Fintype G] (K : Subgroup G) :
    ∑ H : Subgroup G, if K ≤ H then subgroupMoebiusTop G H else 0 =
      if K = ⊤ then 1 else 0 := by
  ...
```
This is the incidence-algebra heart. Expect induction on subgroup-cardinality or poset rank.

### Lemma 3: Dominant point-stabilizer contribution
```lean
theorem pointStabilizer_contribution_eq_inv
    (n : ℕ) (hn : 1 ≤ n) :
    -- precise expression adapted to your probability definition
    ... = (1 : ℚ) / n := by
  ...
```
This should use index computations for `S_{n-1} ≤ S_n`, multi-step `calc`, and possibly `field_simp`.

### Lemma 4: Tail bound from large-index subgroups
```lean
theorem large_index_subgroup_tail_bound
    ∃ C : ℚ, ∀ ⦃n : ℕ⦄, n ≥ 2 →
      ... ≤ C / n^2 := by
  ...
```
Even a coarse but explicit bound is valuable. This is where `by_contra`, cardinal estimates, and rational inequalities can appear.

---

## Cross-domain connections you must explicitly build into the development

You are required to include at least one theorem bridging to another domain. Here are two strong options.

### Bridge A: Incidence algebras / combinatorics
Prove that the subgroup Möbius formula is a special case of a general finite-poset inversion theorem. This connects finite group theory to algebraic combinatorics.

**Possible theorem**
```lean
theorem generating_pair_count_as_poset_moebius_inversion :
  ...
```
Interpretation: group generation is an incidence-algebra observable.

### Bridge B: Analytic combinatorics / statistical mechanics
Interpret the nongeneration probability as a finite “cluster expansion” over subgroup obstructions. The Möbius coefficients play the role of Ursell coefficients/cumulants on the subgroup lattice.

A formal theorem can be modest:
```lean
theorem log_partition_style_alternation_bound
    ... :
    ...
```
Even a sign/alternation result for initial correction terms would be a genuine bridge.

### Bridge C: Number theory
Make the analogy precise: the classical Möbius inversion on divisibility and the subgroup-lattice inversion satisfy the same convolution-cancellation law. Formalize a theorem exhibiting both as instances of a common finite-poset framework.

This is elegant and likely feasible.

---

## Conjecture with computationally falsifiable prediction

You must state at least one conjecture with a clear computational test.

### Conjecture 1: Stabilizer-dominance universality
For sufficiently large `n`, the contribution of all proper subgroups of `S_n` not containing a point stabilizer is `O(1/n^2)`, and the coefficient of `1/n` in the nongeneration probability is exactly accounted for by the conjugacy class of point stabilizers.

**Computational test:** For `n ≤ 9` using GAP, compute the exact generating-pair count and compare:
- full exact value,
- contribution from point stabilizers only,
- contribution from all intransitive maximal subgroups.

If the normalized residual is not approximately quadratic in `1/n`, the conjecture is false.

### Conjecture 2: Second-order coefficient from two-point geometric obstructions
The coefficient of `1/n^2` in `1 - P_n` is the total Möbius mass of the codimension-two intransitive obstruction pattern, with primitive/imprimitive maximal subgroups contributing only `O(1/n^3)`.

**Computational test:** For `n ≤ 8`, classify subgroup contributions by family and fit the residual.

These are falsifiable and scientifically useful even if not immediately provable.

---

## Computational deliverable: verified algorithm

You must produce a **verified computational method**, not just theorem statements.

### Algorithm target
Implement an algorithm that computes
\[
a_n := \#\{(\sigma,\tau)\in S_n^2 : \langle \sigma,\tau\rangle = S_n\}
\]
for small `n`, either:
1. by enumerating pairs and generated subgroups, or
2. by summing Möbius coefficients over the subgroup lattice imported from GAP data.

The stronger scientific deliverable is a hybrid:
- GAP computes subgroup lattice / Möbius data for `n ≤ 7`,
- Lean verifies the final count from that data structure or checks consistency identities.

You should define and verify correctness of the counting routine as far as practical.

**Suggested Python demo capabilities**
- choose `n ≤ 7`,
- compute total pair count, generating pair count, probability,
- display contributions grouped by subgroup family,
- compare exact probability against `1 - 1/n` and `1 - 1/n - 1/n^2`,
- plot residuals on a log scale.

---

## Lean proof tactics expectation

The file must contain at least 3 theorems whose proofs genuinely use deep tactics such as:
- `induction` on subgroup-cardinality / poset height,
- `rcases` for subgroup-generated decomposition,
- `by_contra` for uniqueness/minimality arguments,
- `field_simp` for rational asymptotic estimates,
- multi-step `calc` chains for cardinal/index manipulations.

Avoid trivial closure by `decide`/`native_decide` unless the theorem itself is structurally important.

---

## Most important mathematical insight

**The key insight is** that generation by two elements is not merely obstructed by maximal subgroups; it is **exactly decomposed by the incidence algebra of the subgroup lattice**. The subgroup Möbius function is the finite-group analogue of the number-theoretic Möbius function: it removes overcounting from nested obstruction patterns. Once formalized, asymptotics become a problem of identifying which geometric families of subgroups dominate the Möbius mass.

**Why now?** Because the catalog already contains the probabilistic sieve and ratio formulas for generation in symmetric groups. The missing ingredient is a reusable incidence-algebra layer. Building it now does not just solve one conjecture — it equips Lean with machinery for an entire research program in random generation and subgroup asymptotics.

---

## Concrete build plan

1. **Read and reuse**
   - `Algebra/SymmGroupGeneration.lean`
   - especially `nongeneratingPairProbability_le_maximal_subgroup_sum`
   - and `generatingPairProbability_eq_card_ratio`

2. **Create a new file** such as
   - `Algebra/SubgroupMoebius.lean`
   - or `Combinatorics/FinitePosetMoebiusSubgroup.lean`

3. **Formalize the finite subgroup-lattice Möbius API**
   - finite summation over `Subgroup G`
   - zeta/Möbius cancellation
   - inversion theorem specialized to top element

4. **Prove the exact generating-pair formula**

5. **Specialize to `S_n`**
   - derive normalized probability formula
   - isolate point stabilizers
   - prove explicit `O(1/n^2)` or better

6. **Validate computationally for `n ≤ 7`**
   - GAP-backed if necessary
   - compare exact values with asymptotic approximants

---

## Application keywords

finite group theory; probabilistic generation; symmetric groups; subgroup lattice; Möbius inversion; incidence algebras; analytic combinatorics; asymptotic enumeration; computational group theory; random generation; permutation groups; cluster expansion; number-theoretic analogies; subgroup growth; formal asymptotics

---

## Mandatory deliverables

You must produce **all** of the following.

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- random generation in finite classical groups,
- subgroup Möbius inversion and combinatorial species,
- cluster expansions in statistical mechanics,
- probabilistic Galois theory.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the exact Möbius inversion formula,
- the subgroup-lattice formalism,
- the asymptotic theorem you proved,
- the computational evidence,
- and what this opens next.

A reader with no access to code must still understand the discovery.

### 3. `ARTICLE.md`
Write this in **Scientific American style**. Make it vivid and concept-driven. Explain why “most pairs of permutations generate everything” is a deep structural fact, and why Möbius inversion reveals the hidden architecture of failure.  
**Do not focus on formal verification machinery.** Focus on the mathematics and significance.

### 4. Verified algorithm / computational method
Provide a verified counting method for generating pairs or Möbius-sum evaluation.

### 5. `demo.py`
Interactive demonstration that:
- accepts `n`,
- computes or loads exact generating-pair data,
- compares against asymptotic approximations,
- visualizes subgroup-family contributions.

---

## Final ambition

Do not settle for “another upper bound.” The real target is:

> **Turn Dixon asymptotics into an incidence-algebra theorem.**

If you can prove the exact Möbius formula and even a first rigorous asymptotic correction term in Lean, you will have created a new formal language for probabilistic finite group theory.

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
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
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
