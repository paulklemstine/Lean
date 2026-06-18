## Assignment: **prove**

# Breakthrough Program: Certified Generation Probability, Maximal-Subgroup Obstructions, and the First Lean Blueprint Toward Dixon’s Theorem

You should turn the small-case computational story for symmetric-group generation into a structurally organized formal theory of **probabilistic generation via subgroup obstructions**. The immediate targets are exact theorems for `S₄` and `S₅`, but the real objective is larger: create the Lean infrastructure that makes a machine-checked version of Dixon-style asymptotic generation plausible.

This is not a request to “compute more examples.” It is a request to formalize the philosophy that:

> a pair `(σ, τ)` fails to generate `S_n` precisely because it is trapped inside a proper subgroup, and for large `n` the dominant trap is intransitivity, especially point stabilizers.

That perspective connects finite group theory, probabilistic combinatorics, asymptotic enumeration, and certified computation.

---

## Core Theorem Targets

### Theorem A: Exact generation probability for `S₄`

Formalize and prove that exactly `216` ordered pairs in `S₄ × S₄` generate the full symmetric group, hence the generation probability is `216 / 576 = 3 / 8`.

A Lean-facing statement should look like:

```lean
theorem card_generate_top_pairs_equiv_perm_fin_4 :
    Fintype.card
      { p : Equiv.Perm (Fin 4) × Equiv.Perm (Fin 4) |
        Subgroup.closure (Set.range fun i : Fin 2 =>
          if h : i = 0 then p.1 else p.2) = ⊤ } = 216
```

and then the probability statement:

```lean
theorem generationProbability_perm_fin_4 :
    ((Fintype.card
      { p : Equiv.Perm (Fin 4) × Equiv.Perm (Fin 4) |
        Subgroup.closure (Set.range fun i : Fin 2 =>
          if h : i = 0 then p.1 else p.2) = ⊤ }) : ℚ)
      / (Fintype.card (Equiv.Perm (Fin 4) × Equiv.Perm (Fin 4))) = (3 : ℚ) / 8
```

If the existing catalog already has a predicate like `PairGenerates`, `generates_top`, or a generation probability definition, use that exact abstraction instead of rebuilding it. But the theorem should end in a literal exact rational identity.

---

### Theorem B: Exact generation probability for `S₅`

Prove the corresponding exact result for `S₅`:

```lean
theorem card_generate_top_pairs_equiv_perm_fin_5 :
    Fintype.card
      { p : Equiv.Perm (Fin 5) × Equiv.Perm (Fin 5) |
        Subgroup.closure (Set.range fun i : Fin 2 =>
          if h : i = 0 then p.1 else p.2) = ⊤ } = 6840
```

and

```lean
theorem generationProbability_perm_fin_5 :
    ((Fintype.card
      { p : Equiv.Perm (Fin 5) × Equiv.Perm (Fin 5) |
        Subgroup.closure (Set.range fun i : Fin 2 =>
          if h : i = 0 then p.1 else p.2) = ⊤ }) : ℚ)
      / (Fintype.card (Equiv.Perm (Fin 5) × Equiv.Perm (Fin 5))) = (19 : ℚ) / 40
```

The exact normalization must certify that `|S₅ × S₅| = 120² = 14400`.

---

### Theorem C: Point-stabilizer contribution formula

You should extract and prove the exact probability that two random permutations both lie in a common point stabilizer.

For `n ≥ 1`, let `Stab(i) ≤ S_n` be the stabilizer of `i : Fin n`. Then the union-bound contribution from point stabilizers is exactly `1/n` when counted by expectation and at most `1/n` as a failure contribution.

A good finite-cardinality theorem target is:

```lean
theorem prob_two_random_perms_fix_common_point
    (n : ℕ) [Fact (0 < n)] :
    ((Fintype.card
      { p : Equiv.Perm (Fin n) × Equiv.Perm (Fin n) |
        ∃ i : Fin n, p.1 i = i ∧ p.2 i = i }) : ℚ)
      / (Fintype.card (Equiv.Perm (Fin n) × Equiv.Perm (Fin n)))
      ≤ (1 : ℚ) / n
```

Even stronger, if you can formalize the expectation identity:

```lean
theorem expected_number_common_fixed_points
    (n : ℕ) [Fact (0 < n)] :
    -- suitable expectation statement over uniform pairs in S_n × S_n
    True
```

then it becomes the probabilistic seed for asymptotic obstruction analysis.

---

### Theorem D: Intransitive obstruction sum bound

For each `1 ≤ k ≤ n-1`, the subgroup `S_k × S_{n-k}` embedded as a set stabilizer of a `k`-subset contributes

\[
\binom{n}{k}\left(\frac{k!(n-k)!}{n!}\right)^2
\]

to the union bound for the event that both permutations lie in some conjugate of that intransitive subgroup.

You should formalize the exact algebraic simplification

\[
\binom{n}{k}\left(\frac{k!(n-k)!}{n!}\right)^2 = \frac{1}{\binom{n}{k}}.
\]

This is the hidden structural simplification that makes the asymptotics transparent.

Lean-facing theorem:

```lean
theorem intransitive_obstruction_term
    (n k : ℕ) (hk1 : 1 ≤ k) (hk2 : k ≤ n) :
    ((Nat.choose n k : ℚ) *
      (((Nat.factorial k * Nat.factorial (n - k) : ℚ) / Nat.factorial n) ^ 2))
    = (1 : ℚ) / Nat.choose n k
```

From there derive the half-sum bound

```lean
theorem intransitive_union_bound
    (n : ℕ) :
    (∑ k in Finset.Icc 1 (n / 2), (1 : ℚ) / Nat.choose n k)
      ≥
    -- encoded upper bound on probability of lying in some intransitive maximal subgroup
    0
```

and then seek a concrete explicit estimate such as

```lean
theorem intransitive_obstruction_le_four_over_n
    (n : ℕ) (hn : 5 ≤ n) :
    (∑ k in Finset.Icc 1 (n / 2), (1 : ℚ) / Nat.choose n k) ≤ (4 : ℚ) / n
```

This is not yet Dixon’s theorem, but it is the combinatorial backbone of a certified obstruction calculus.

---

### Theorem E: Point-stabilizer dominance

Formalize the asymptotic statement that the `k=1` term dominates the intransitive obstruction sum.

Mathematically:

\[
\frac{1/n}{\sum_{k=1}^{\lfloor n/2\rfloor} 1/\binom{n}{k}} \to 1.
\]

Equivalently,

\[
\sum_{k=2}^{\lfloor n/2\rfloor} \frac{1}{\binom{n}{k}} = o(1/n).
\]

A Lean target may be ambitious if asymptotics infrastructure is heavy, so a staged version is acceptable:

1. first prove explicit inequalities like
   \[
   \sum_{k=2}^{\lfloor n/2\rfloor} \frac{1}{\binom{n}{k}} \le \frac{C}{n^2}
   \]
   for `n ≥ N`,
2. then derive the ratio tends to `1`.

A possible theorem shape:

```lean
theorem intransitive_tail_le_const_over_n_sq :
    ∃ C N : ℚ, 0 < C ∧ ∀ n : ℕ, N ≤ n →
      (∑ k in Finset.Icc 2 (n / 2), (1 : ℚ) / Nat.choose n k) ≤ C / (n : ℚ)^2
```

and then

```lean
theorem point_stabilizer_dominance :
    Tendsto
      (fun n : ℕ =>
        ((1 : ℚ) / n) /
        (∑ k in Finset.Icc 1 (n / 2), (1 : ℚ) / Nat.choose n k))
      atTop (nhds 1)
```

If this exact asymptotic form is too difficult in current Mathlib, prove the explicit tail bound and record the asymptotic theorem as a sharply isolated conjectural endpoint.

---

## Why this is a breakthrough

If you succeed, you will not merely certify `S₄` and `S₅`. You will have created:

1. a **formal probabilistic-generation framework** for finite groups,
2. a **subgroup-obstruction decomposition** that mirrors classical research proofs,
3. the first realistic Lean route toward **Dixon’s theorem**,
4. a reusable methodology for other families: `A_n`, classical groups over finite fields, random generation of matrix groups, and even Galois-group heuristics.

The conceptual shift is this: instead of brute-force finite verification, you formalize **why generation is overwhelmingly likely**, via subgroup geometry and counting. That is the bridge from computational algebra to asymptotic group theory.

---

## Proof Strategy Architecture

### Strategy 1: Native certified enumeration for `S₄` and `S₅`
Most promising for Theorems A and B.

**Step 1.** Define or reuse a decidable predicate
`GeneratesTopPair : (Perm (Fin n) × Perm (Fin n)) → Prop`
that checks whether the subgroup generated by the pair is all of `Perm (Fin n)`.

**Step 2.** Compute
```lean
Fintype.card {p | GeneratesTopPair p}
```
via `native_decide`, reducing exact cardinality to a finite exhaustive check.

**Step 3.** Convert the cardinality output to the rational probability identity by explicit cardinal arithmetic:
`|S₄| = 24`, `|S₅| = 120`.

Why promising: this is closest to existing infrastructure and gives immediate exact theorems. It also produces a trusted testbed for later abstract lemmas.

---

### Strategy 2: Subgroup-classification counting for `S₄` and `S₅`
Most conceptually powerful; best if the catalog already contains subgroup classification facts.

**Step 1.** Enumerate proper maximal subgroups of `S₄` and `S₅` up to conjugacy:
- intransitive subgroups,
- imprimitive subgroups,
- `A_n`,
- exceptional small subgroups where relevant.

**Step 2.** Count ordered pairs lying in each maximal subgroup and subtract overlaps using exact incidence information.

**Step 3.** Deduce the number of generating pairs as the complement of the union of proper-subgroup-contained pairs.

Why promising: this creates the exact conceptual template needed for the asymptotic theory. If done well, it transforms small-case computation into structural mathematics.

---

### Strategy 3: Obstruction calculus via action on subsets and block systems
Best for Theorems C–E and for a first formal Dixon-style bound.

**Step 1.** For each `k`, count the probability that both permutations preserve the same `k`-subset:
\[
\binom{n}{k}\left(\frac{k!(n-k)!}{n!}\right)^2 = \frac{1}{\binom{n}{k}}.
\]

**Step 2.** Sum over `k` using a union bound, restricting to `k ≤ n/2` by symmetry.

**Step 3.** Show the `k=1` term is `1/n` and the tail is `O(1/n^2)` by lower bounds on binomial coefficients, e.g.
\[
\binom{n}{k} \ge \binom{n}{2}
\quad\text{for } 2 \le k \le n/2.
\]

Why promising: this is the exact combinatorial skeleton behind Dixon-style asymptotics, but formalizable with elementary inequalities.

---

## Building on catalog theorems

Use any existing catalog results about:
- exact generation probability for `S₁`, `S₂`, `S₃`,
- `native_decide` enumeration of generating pairs,
- cardinality lemmas for `Equiv.Perm (Fin n)`,
- subgroup closure of finite generating sets,
- rational simplification and factorial/binomial identities.

In particular, if the catalog already has the certified values
\[
p_1 = 1,\quad p_2 = 3/4,\quad p_3 = 1/2,
\]
then Theorems A and B extend this into the first nontrivial region where subgroup geometry becomes visible. You should explicitly refactor the earlier small-`n` proofs so that `n=4,5` are instances of a common computational theorem rather than isolated scripts.

Also, if there is already a theorem expressing
`Fintype.card (Equiv.Perm (Fin n)) = n!`,
build all probability identities from that theorem rather than hardcoding cardinalities.

---

## Cross-domain connections you should exploit

### 1. Probabilistic combinatorics
The subgroup-union viewpoint is a finite-group analog of rare-event decomposition. The point-stabilizer dominance theorem is a discrete large-deviations statement: among all ways generation can fail, the cheapest obstruction asymptotically dominates.

### 2. Statistical mechanics
Think of proper subgroups as low-entropy “phases” trapping random generators. The asymptotic theorem says the system’s defect measure concentrates on the least costly defect class. This analogy can guide how to package obstruction families and compare their weights.

### 3. Galois theory and arithmetic statistics
Random permutation generation is the model behind “generic Galois group is `S_n` or `A_n`.” Formal subgroup-obstruction bounds for `S_n` are proto-tools for certified arithmetic-statistics heuristics.

### 4. Computational complexity / certified randomized algorithms
Generation probability controls the success rate of random-generator algorithms for black-box groups. Exact formal probabilities for small groups and asymptotic lower bounds for large families connect directly to certified Monte Carlo methods.

### 5. Information theory
The failure-to-generate event is a structural compression phenomenon: two random permutations carry insufficient “group-theoretic information” because both land in the same low-index subgroup. This perspective suggests future entropy-like invariants of subgroup traps.

---

## Concrete technical subgoals

1. Introduce a reusable predicate for “the subgroup generated by a pair is top.”
2. Prove cardinality lemmas for pair spaces of permutations.
3. Package exact `native_decide` computations for `Fin 4` and `Fin 5`.
4. Formalize the binomial-factorial identity
   \[
   \binom{n}{k}(k!(n-k)!/n!)^2 = 1/\binom{n}{k}.
   \]
5. Prove explicit tail bounds for
   \[
   \sum_{k=2}^{\lfloor n/2\rfloor} 1/\binom{n}{k}.
   \]
6. Isolate a theorem schema for subgroup-union upper bounds on non-generation probability.

---

## Suggested Lean design choices

Prefer a finite-set formulation over measure theory at first. Probability over finite groups can be encoded as rational cardinality ratios, which is robust and computation-friendly.

If closure of a 2-element generating set is awkward, define a helper set:
```lean
def pairGenerators {G : Type*} [Group G] (p : G × G) : Set G := {p.1, p.2}
```
or directly use the subgroup closure of `{p.1, p.2}` if Mathlib’s finite-set-to-set coercions are smoother.

For exact computation, isolate all reducible definitions and use `native_decide` only at the final cardinality lemma, so the proof terms remain maintainable.

---

## Nontrivial conjectural endpoint beyond the exact computations

If the exact `S₄` and `S₅` theorems land cleanly, immediately push to the certified bound:

```lean
theorem prob_not_generate_An_or_Sn_le_four_over_n
    (n : ℕ) (hn : 5 ≤ n) :
    -- suitable rational probability of failure to generate A_n or S_n
    True
```

You do not need the final polished theorem in one cycle, but you should produce the combinatorial obstruction lemmas that make it inevitable.

---

## Revolutionary significance

A successful development opens a new lane in formal mathematics:

- **formal asymptotic finite group theory**, not just exact finite computation;
- **machine-checked random generation theory** for algebraic structures;
- a pathway from certified small examples to **certified universal laws**.

This would make Lean relevant not only for theorem verification but for the formalization of classical probabilistic algebra at research depth. The endgame is not `S₅`; the endgame is a formal theory of why random algebraic objects are usually generic.

---

## Application keywords

`finite group theory`, `probabilistic generation`, `symmetric groups`, `Dixon theorem`, `subgroup growth`, `asymptotic combinatorics`, `certified computation`, `native_decide`, `formal verification`, `black-box groups`, `arithmetic statistics`, `Galois groups`, `random generation algorithms`, `maximal subgroups`, `binomial tail bounds`

---

## Deliverables

1. Lean theorems for exact generation probabilities of `S₄` and `S₅`.
2. Supporting lemmas for subgroup-obstruction counting.
3. At least one explicit intransitive-obstruction upper bound of order `1/n`.
4. Clear documentation of which pieces are computational and which are structural.
5. **A structured `FUTURE_DIRECTIONS.md` with 3–5 falsifiable scientific hypotheses**, each including:
   - precise conjecture,
   - exact Lean/formal test,
   - expected obstruction,
   - criterion for refutation.

At least three candidate hypotheses should be among:

- **Hypothesis A:** For all `n ≥ 6`, the intransitive obstruction sum satisfies
  \[
  \sum_{k=1}^{\lfloor n/2\rfloor} \frac{1}{\binom{n}{k}} \le \frac{1}{n} + \frac{3}{n^2}.
  \]
  **Test:** verify numerically in Lean for `6 ≤ n ≤ 200`, then prove analytically.

- **Hypothesis B:** The probability that two random permutations generate a transitive subgroup but not `A_n` or `S_n` is `O(1/n^2)`.
  **Test:** formalize primitive/imprimitive obstruction families and compare with explicit rational bounds.

- **Hypothesis C:** For fixed `r ≥ 2`, the probability that `r` random permutations fail to generate `S_n` is asymptotic to `1/n^{r-1}` from common point stabilizers.
  **Test:** generalize the point-stabilizer calculation from pairs to `r`-tuples.

- **Hypothesis D:** Exact generation probabilities for `S_n` for `n ≤ 7` can be certified with optimized finite computation inside Lean.
  **Test:** benchmark and compare `native_decide`, reflection, and subgroup-caching approaches.

- **Hypothesis E:** The subgroup-obstruction formalism extends to `A_n` with analogous point-stabilizer-dominance after parity correction.
  **Test:** define the random-generation probability for `Alt (Fin n)` and compare the first obstruction terms.

Be bold: the real theorem is not just `3/8` for `S₄`. The real theorem is that formal mathematics can capture the geometry of generic generation.

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

Research domain: Speculative
Research mode: prove
