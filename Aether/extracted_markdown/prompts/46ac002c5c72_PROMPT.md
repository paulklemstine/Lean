## Assignment: Symmetric Group Generation Probability

**Mode: prove**

Aristotle, do not treat this as a counting exercise. The real target is to formalize a nascent probabilistic Galois theory of random permutations: two random permutations either fall into rigid obstruction families or they overwhelmingly generate the full alternating/symmetric universe. Your task is to isolate those obstruction families, convert them into exact finite formulas where possible, and derive rigorous asymptotic lower/upper bounds that are already mathematically meaningful in Lean 4.

You should build a small formal theory whose center of gravity is:

1. an exact counting formula for the probability that two random permutations preserve a nontrivial block/imprimitive structure or a proper subset,
2. a sharp union-bound framework for failure of transitivity / primitivity,
3. a parity-corrected reduction from generation of `S_n` to generation of a transitive subgroup not contained in `A_n`,
4. a computationally verified asymptotic prediction approaching Dixon’s phenomenon.

This is not “just formalize a known theorem.” It is to create the first reusable Lean infrastructure for **random generation in finite permutation groups**, with symmetric groups as the flagship case.

---

## Core Breakthrough Target

Define the generation probability
\[
P_n := \frac{\#\{(\sigma,\tau)\in S_n\times S_n : \langle \sigma,\tau\rangle = S_n\}}{(n!)^2}.
\]

You may not be able to fully formalize Dixon’s theorem in one cycle, but you **must** formalize a mathematically deep scaffold that makes it inevitable. In particular, prove exact formulas for principal obstruction events and derive explicit asymptotic bounds of the shape
\[
1 - \frac{c_1}{n} - \varepsilon_n \le P_n \le 1 - \frac{c_2}{n}
\]
for explicit constants and computable error terms coming from transitivity/primitivity obstruction estimates and parity.

The key conceptual shift: generation failure is not random chaos; it is governed by a small number of structured subgroup geometries.

---

## Precise Formal Targets

You must introduce at least one genuinely new definition. Suggested definitions:

- `PairGenEvent n σ τ : Prop := Subgroup.closure ({σ, τ} : Set (Equiv.Perm (Fin n))) = ⊤`
- `PairTransitive n σ τ : Prop := MulAction.IsPretransitive (Subgroup.closure ({σ, τ} : Set (Equiv.Perm (Fin n)))) (Fin n)`
- `PreservesSet (σ : Equiv.Perm α) (A : Finset α) : Prop := ∀ x, x ∈ A ↔ σ x ∈ A`
- `PairPreservesSet n σ τ A : Prop := PreservesSet σ A ∧ PreservesSet τ A`
- `BadPair n σ τ : Prop := ¬ PairGenEvent n σ τ`
- `GenerationProbabilityLowerBound (n : ℕ) : ℚ` or `ℝ`

You should also define a finite-set counting object for bad pairs:
- `badPairsFinset (n : ℕ) : Finset ((Equiv.Perm (Fin n)) × (Equiv.Perm (Fin n)))`

where feasible.

### Theorem 1: Exact subset-preservation counting formula
The first theorem should be exact and nontrivial.

Mathematical statement:
For every `n ≥ 1` and every subset `A ⊆ Fin n` of size `k`, the number of pairs `(σ, τ)` in `S_n × S_n` such that both permutations preserve `A` is
\[
(k!(n-k)!)^2.
\]

This is the basic local obstruction count behind transitivity failure.

Suggested Lean-style statement:
```lean
theorem card_pairs_preserving_fixed_finset
    (n k : ℕ) (hk : k ≤ n) (A : Finset (Fin n))
    (hA : A.card = k) :
    Fintype.card
      { p : Equiv.Perm (Fin n) × Equiv.Perm (Fin n) //
          PairPreservesSet n p.1 p.2 A } =
    ((Nat.factorial k * Nat.factorial (n - k)) : ℕ)^2
```

If this exact signature is too rigid for available library lemmas, use a sigma/subtype equivalent formulation, but keep the theorem exact.

Why this matters:
This theorem turns a group-theoretic event into a combinatorial factorization. It is the atomic building block for all probabilistic bounds on non-transitivity.

---

### Theorem 2: Union bound for non-transitivity
Mathematical statement:
If `n ≥ 2`, the probability that two random permutations generate a subgroup that is not transitive is at most
\[
\sum_{k=1}^{n-1} \binom{n}{k}\left(\frac{k!(n-k)!}{n!}\right)^2
= \sum_{k=1}^{n-1} \binom{n}{k}^{-1}.
\]

This is already beautiful: the failure of transitivity is controlled by reciprocals of binomial coefficients.

Suggested Lean-style statement:
```lean
theorem prob_not_transitive_le_binomial_recip_sum
    (n : ℕ) (hn : 2 ≤ n) :
    generationFailureTransitivityProb n ≤
      ∑ k in Finset.Icc 1 (n - 1),
        ((Nat.choose n k : ℚ)⁻¹)
```

or in `ℝ`:
```lean
theorem prob_not_transitive_le_binomial_recip_sum_real
    (n : ℕ) (hn : 2 ≤ n) :
    generationFailureTransitivityProbReal n ≤
      ∑ k in Finset.Icc 1 (n - 1),
        ((Nat.choose n k : ℝ)⁻¹)
```

You must prove this using explicit counting + union bound, not by black-box probability automation.

Why this matters:
This theorem gives a formal, reusable bridge between permutation-group generation and analytic combinatorics. It is the first asymptotic foothold.

---

### Theorem 3: Explicit asymptotic corollary
Derive a clean explicit estimate such as
\[
\sum_{k=1}^{n-1}\binom{n}{k}^{-1} \le \frac{2}{n} + \frac{C}{n^2}
\quad\text{for } n \ge n_0,
\]
hence
\[
\Pr(\text{not transitive}) \le \frac{2}{n} + \frac{C}{n^2}.
\]

A practical target is a theorem of the form:
```lean
theorem binomial_recip_sum_le_two_div_n_add
    (n : ℕ) (hn : 4 ≤ n) :
    (∑ k in Finset.Icc 1 (n - 1), ((Nat.choose n k : ℝ)⁻¹))
      ≤ 2 / n + 8 / (n : ℝ)^2
```

and then
```lean
theorem prob_not_transitive_le_two_div_n_add
    (n : ℕ) (hn : 4 ≤ n) :
    generationFailureTransitivityProbReal n ≤ 2 / n + 8 / (n : ℝ)^2
```

This theorem must involve real inequalities, multi-step `calc`, and nontrivial estimates on binomial coefficients. No trivial automation.

Why this matters:
It yields the first asymptotic theorem in the file and concretely explains why random pairs are “almost always” transitive.

---

### Theorem 4: Parity obstruction theorem
Generation of `S_n` is impossible if both generators are even. Since exactly half of permutations are even for `n ≥ 2`, we get an unavoidable lower obstruction.

Mathematical statement:
For `n ≥ 2`, the probability that both random permutations lie in `A_n` is `1/4`, hence
\[
P_n \le \frac34.
\]

Suggested Lean-style statement:
```lean
theorem prob_both_even_eq_quarter
    (n : ℕ) (hn : 2 ≤ n) :
    probBothEven n = (1 / 4 : ℚ)
```

and
```lean
theorem generation_probability_le_three_quarters
    (n : ℕ) (hn : 2 ≤ n) :
    generationProbability n ≤ (3 / 4 : ℚ)
```

This uses `symmetric_group_card` / `symmetric_group_order` as core catalog ingredients.

Why this matters:
It isolates the first global obstruction to generating `S_n`: parity. This is the reason the limit for generating `S_n` is `3/4`, not `1`.

---

### Theorem 5: Lower bound for generation of `S_n`
Combine parity with transitivity obstruction to prove a lower bound of the shape
\[
P_n \ge \frac34 - \left(\frac{2}{n} + \frac{C}{n^2}\right) - \delta_n,
\]
where `δ_n` accounts for transitive odd proper subgroups not yet eliminated. If a full proof about primitive proper subgroups is out of reach, make `δ_n` an explicitly defined residual term counting transitive proper subgroups:
\[
\delta_n :=
\Pr(\langle \sigma,\tau\rangle \text{ transitive, not contained in }A_n,\text{ but } \neq S_n).
\]

Suggested Lean-style statement:
```lean
theorem generation_probability_lower_bound_with_residual
    (n : ℕ) (hn : 4 ≤ n) :
    (3 / 4 : ℝ)
      - (2 / (n : ℝ) + 8 / (n : ℝ)^2)
      - residualProperTransitiveProb n
    ≤ generationProbabilityReal n
```

This theorem is acceptable even if `residualProperTransitiveProb` is not yet fully crushed. The point is to create the exact decomposition architecture future work needs.

Why this matters:
This is the mathematically honest blueprint of Dixon-type asymptotics in Lean.

---

## Lean 4 Type Signature Guidance

You should use existing finite group and permutation infrastructure. The likely ambient type is:
```lean
Equiv.Perm (Fin n)
```
and the generated subgroup:
```lean
Subgroup.closure ({σ, τ} : Set (Equiv.Perm (Fin n)))
```

Potential probability encoding:
- exact rational probabilities via card ratios in finite types,
- real probabilities via coercion from `ℚ`.

Suggested helper definitions:
```lean
def generatesSymm (n : ℕ) (σ τ : Equiv.Perm (Fin n)) : Prop :=
  Subgroup.closure ({σ, τ} : Set (Equiv.Perm (Fin n))) = ⊤

def preservesFinset {n : ℕ} (σ : Equiv.Perm (Fin n)) (A : Finset (Fin n)) : Prop :=
  ∀ x : Fin n, x ∈ A ↔ σ x ∈ A

def pairPreservesFinset {n : ℕ}
    (σ τ : Equiv.Perm (Fin n)) (A : Finset (Fin n)) : Prop :=
  preservesFinset σ A ∧ preservesFinset τ A
```

For exact counting of permutations preserving a subset, you may also introduce an equivalence between:
- permutations preserving `A`,
- pairs of permutations on `A` and on its complement.

This should be formalized as an explicit `Equiv`, not just cardinality comparison.

---

## Proof Strategy Architecture

### Strategy A: Structural decomposition via stabilizers of subsets
**Most promising.**

1. Define the subgroup of permutations preserving a fixed subset `A`.
2. Construct an explicit equivalence between this subgroup and
   \[
   \mathrm{Sym}(A)\times \mathrm{Sym}(A^c),
   \]
   then deduce its cardinality is `k!(n-k)!`.
3. Square this count for ordered pairs of permutations.
4. Apply a union bound over all nonempty proper `A` to control non-transitivity.
5. Convert the exact sum into binomial reciprocals using
   \[
   \binom{n}{k} = \frac{n!}{k!(n-k)!}.
   \]

Why it is best:
It is exact, combinatorial, and aligned with current Mathlib strengths: finite types, cardinality transport by equivalences, subgroup constructions, and factorial/binomial identities.

---

### Strategy B: Orbit-partition proof of non-transitivity
1. Show that if `⟨σ,τ⟩` is not transitive, then some orbit is a nonempty proper subset preserved by both.
2. Use orbit extraction to reduce the event “not transitive” to a union over preserved subsets.
3. Count each subset-preservation event as in Theorem 1.
4. Conclude the union bound.

Why this matters:
This is conceptually cleaner and ties the probability calculation directly to group actions and orbit theory. It creates infrastructure reusable for random generation in other permutation groups.

---

### Strategy C: Analytic combinatorics of reciprocal binomial sums
1. Isolate edge terms `k=1` and `k=n-1`, each equal to `1/n`.
2. For interior terms, prove lower bounds on `choose n k`, e.g. `choose n k ≥ choose n 2` for `2 ≤ k ≤ n-2`.
3. Bound the interior contribution by
   \[
   \frac{n-3}{\binom{n}{2}},
   \]
   giving an explicit `O(1/n^2)` estimate.
4. Use `field_simp`, positivity lemmas, and monotonicity arguments in `ℝ`.

Why it is useful:
It gives a concrete asymptotic theorem without requiring advanced analytic machinery.

---

## Catalog Theorems to Build On

You already have:
- `symmetric_group_order`
- `symmetric_group_card`

Use them not as decorative citations, but as normalization tools for every probability denominator:
\[
|S_n| = n!.
\]

In particular:
- denominator of pair counts is `(Nat.factorial n)^2`,
- parity counts should be reduced to half of `|S_n|`,
- all subset-preserving probabilities should normalize using the symmetric-group cardinality theorem.

If available in the imported files, also use standard facts about:
- `Fintype.card (Equiv.Perm α)`,
- `Nat.choose`,
- factorial identities,
- cardinality of subtypes via explicit equivalences.

---

## Required Cross-Domain Connection

You must include at least one theorem connecting permutation generation to another domain.

### Recommended connection: random walks / expansion / complexity
Formalize that the obstruction sum
\[
\sum_{k=1}^{n-1}\binom{n}{k}^{-1}
\]
is dominated by edge cuts in the subset lattice, linking generation failure to **isoperimetry of the Boolean cube** and to **mixing heuristics for random walks on Cayley graphs**.

A formal theorem can be elementary but conceptually cross-domain, for example:
```lean
theorem nontransitivity_obstruction_controlled_by_boolean_edge_terms
    (n : ℕ) (hn : 4 ≤ n) :
    generationFailureTransitivityProbReal n ≤
      2 / n + ((n - 3 : ℝ) / (Nat.choose n 2))
```

Interpretation:
The main obstruction comes from singleton and codimension-one cuts, exactly the same phenomenon governing bottlenecks in high-dimensional random walks.

Alternative cross-domain theorem:
Relate the reciprocal-binomial sum to entropy bounds:
\[
\binom{n}{k}^{-1} \le \exp(-n H(k/n))
\]
for central `k`, at least in a weak formalized version. Even a partial theorem for `k = ⌊n/2⌋` would create a bridge to information theory.

**Application keywords:** random generation, permutation groups, probabilistic group theory, asymptotic combinatorics, Boolean isoperimetry, Cayley graph expansion, random walks, entropy method, computational algebra, finite group algorithms.

---

## Conjecture With Testable Prediction

You must include at least one falsifiable conjecture with a clear computational disproof criterion.

### Strong recommended conjecture
```text
Conjecture (quantitative Dixon residual):
For all n ≥ 8,
residualProperTransitiveProb n ≤ 3 / n^2.
```

This is falsifiable:
- compute exact generation statistics for `n ≤ 9` or `10` by exhaustive enumeration or subgroup tests,
- compute the residual term directly,
- search for a counterexample to the inequality.

### Another good conjecture
```text
Conjecture (monotone convergence to 3/4):
For all n ≥ 5,
generationProbability n < generationProbability (n+1)
and lim generationProbability n = 3/4.
```

This is falsifiable by exact computation for small `n`.

Your `demo.py` must numerically test these conjectures for feasible `n`.

---

## Implementation Notes for Lean

- Prefer exact finite counting over measure-theoretic probability.
- Define rational probabilities first; coerce to reals only for asymptotics.
- Use `Finset`, `Fintype.card`, subtype cardinality, and explicit `Equiv`s.
- For asymptotic inequalities, expect to use:
  - `have`,
  - `calc`,
  - `field_simp`,
  - monotonicity of `Nat.choose`,
  - case splits on small `n`,
  - `by_contra` where necessary for positivity arguments.

### Deep proof tactics requirement
At least 3 theorem proofs must genuinely use some of:
- induction on `n`,
- `rcases` to unpack subgroup/orbit/set structure,
- `by_contra` for impossible cardinality or transitivity contradictions,
- `field_simp` in reciprocal-binomial estimates,
- multi-step `calc` blocks converting combinatorial counts to probability bounds.

No theorem should be a dressed-up computation.

---

## Deliverables You Must Produce

You must deliver **all** of the following:

1. **Lean file(s)** containing:
   - at least 3 substantial theorems as above,
   - at least one novel definition,
   - minimal `sorry`,
   - one cross-domain theorem,
   - one explicit conjecture in comments/docstring form with computational test instructions.

2. **FUTURE_DIRECTIONS.md**
   with **3–5 testable scientific hypotheses**, each falsifiable and paired with a concrete experiment/computation. Examples:
   - residual proper transitive subgroup probability is `O(1/n^2)`,
   - primitive-but-proper obstruction is exponentially small,
   - analogous generation probability for `A_n` tends to `1`,
   - `k` random permutations generate `S_n` with threshold behavior already at `k=2`.

3. **RESEARCH_PAPER.md**
   a standalone paper explaining:
   - exact subset-preservation counting,
   - non-transitivity union bound,
   - parity obstruction,
   - asymptotic lower/upper bounds,
   - residual subgroup problem,
   - computational evidence.

4. **ARTICLE.md**
   in Scientific American style, explaining why two random shuffles almost always generate “all possible shuffles,” why the limit is `3/4`, and how this connects to randomness, symmetry, and complexity.

5. **A verified algorithm or computational method**
   for computing or bounding `generationProbability n`, `generationFailureTransitivityProb n`, and the reciprocal-binomial obstruction sum.

6. **demo.py**
   that:
   - computes exact values for small `n` by enumeration when feasible,
   - estimates probabilities for larger `n` by Monte Carlo,
   - plots `generationProbability(n)` against `3/4`,
   - tests the residual conjecture numerically.

---

## Final Scientific Vision

If you execute this correctly, you will not merely prove a few facts about `S_n`. You will create the first Lean-native framework in which **random finite generation becomes a formal asymptotic science**. This opens immediate next steps:

- random generation of `A_n`,
- random generation in classical groups over finite fields,
- probabilistic subgroup growth,
- expansion and mixing in random Cayley graphs,
- algorithmic group recognition from random samples.

The theorem about two random permutations is the hydrogen atom. Formalize it with enough depth that an entire probabilistic algebraic universe can crystallize around it.

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

Research domain: Algebra
Research mode: prove
