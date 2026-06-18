## Assignment: Break the current ceiling in formal meta-complexity

You are not being asked for another small lemma about Karchmer–Wigderson witnesses. You are being asked to turn the witness-counting viewpoint into a mathematically sharp, structurally complete theory for symmetric and monotone Boolean functions in Lean 4. The right target is not “more examples,” but a theorem schema that upgrades brute-force computational evidence into exact formulas, asymptotic laws, and complexity equivalences.

Build on the catalog objects already present around `MetaComplexity.KWWitness`, `MetaComplexity.hammingWeight`, `MetaComplexity.IsSymmetric`, threshold functions, and any exact or lower-bound results already certified this cycle. Minimize sorry. If a conjecture is too strong, pivot to the strongest true theorem and formalize the counterexample cleanly.

---

# Mode: `prove`

# Core Breakthrough Target

## Theorem 1: Exact symmetric witness formula

Formalize and prove the exact enumeration of KW witnesses for symmetric Boolean functions by Hamming-weight profile.

### Mathematical statement

Let `f : (Fin n → Bool) → Bool` be symmetric, so there exists a profile
`p : Fin (n+1) → Bool` such that for every `x`,
`f x = p ⟨hammingWeight x, ...⟩`.

Then the total number of KW witnesses is exactly

\[
|KWWitness(f)| =
\sum_{k=0}^{n}\sum_{l=0}^{n}
\mathbf{1}_{p(k)=\mathrm{true}}
\mathbf{1}_{p(l)=\mathrm{false}}
\binom{n}{k}\binom{n}{l}|k-l|.
\]

This is not merely a counting identity. It says that for symmetric functions, the KW relation collapses to a one-dimensional transport law on the Hamming cube: the full witness structure is controlled solely by the profile and the metric separation of weight layers.

### Proposed Lean 4 type signature

You may need to adapt names to the exact catalog, but the target should look essentially like:

```lean
theorem card_KWWitness_eq_sum_choose_mul_dist_of_symmetric
    {n : ℕ} {f : (Fin n → Bool) → Bool}
    (hsym : MetaComplexity.IsSymmetric f) :
    Fintype.card (MetaComplexity.KWWitness f) =
      ∑ k : Fin (n + 1), ∑ l : Fin (n + 1),
        (if hsym.profile k = true ∧ hsym.profile l = false then
          Nat.choose n k.val * Nat.choose n l.val * Nat.dist k.val l.val
         else 0)
```

If `IsSymmetric` does not package a canonical profile, first prove an existence/choice lemma:

```lean
theorem exists_profile_of_isSymmetric
    {n : ℕ} {f : (Fin n → Bool) → Bool}
    (hsym : MetaComplexity.IsSymmetric f) :
    ∃ p : Fin (n + 1) → Bool,
      ∀ x, f x = p ⟨MetaComplexity.hammingWeight x, by ...⟩
```

and then state the exact formula relative to a supplied profile:

```lean
theorem card_KWWitness_eq_sum_choose_mul_dist
    {n : ℕ} {f : (Fin n → Bool) → Bool} (p : Fin (n + 1) → Bool)
    (hp : ∀ x, f x = p ⟨MetaComplexity.hammingWeight x, by ...⟩) :
    Fintype.card (MetaComplexity.KWWitness f) =
      ∑ k : Fin (n + 1), ∑ l : Fin (n + 1),
        (if p k = true ∧ p l = false then
          Nat.choose n k.val * Nat.choose n l.val * Nat.dist k.val l.val
         else 0)
```

### Why this is a breakthrough

This theorem would convert witness counting from a combinatorial black box into an exact algebra of profiles. For symmetric functions, lower bounds stop being “proofs” and become exact arithmetic. That opens a new program: classify communication and meta-complexity invariants via weight-layer geometry, then transfer them to monotone complexity, decision-tree depth, and entropy methods.

---

## Theorem 2: Threshold specialization as a closed form

Once Theorem 1 is established, immediately extract the threshold case.

For the threshold function `Thresh n t`, where `f(x)=true` iff `hammingWeight x ≥ t`, prove

\[
|KWWitness(\mathrm{Thresh}_{n,t})|
=
\sum_{k=t}^{n}\sum_{l=0}^{t-1}\binom{n}{k}\binom{n}{l}(k-l).
\]

Then prove the boundary-dominance lower bound

\[
\binom{n}{t}\binom{n}{t-1}
\le |KWWitness(\mathrm{Thresh}_{n,t})|,
\]

and ideally the stronger exact boundary slice contribution

\[
\binom{n}{t}\binom{n}{t-1}
\]
is the contribution of the adjacent layers `(k,l) = (t,t-1)` alone.

### Proposed Lean 4 type signatures

```lean
theorem card_KWWitness_threshold
    {n t : ℕ} (ht : t ≤ n) :
    Fintype.card (MetaComplexity.KWWitness (MetaComplexity.thresh n t)) =
      ∑ k in Finset.Icc t n, ∑ l in Finset.range t,
        Nat.choose n k * Nat.choose n l * (k - l)
```

and

```lean
theorem choose_mul_choose_le_card_KWWitness_threshold
    {n t : ℕ} (ht0 : 0 < t) (htn : t ≤ n) :
    Nat.choose n t * Nat.choose n (t - 1) ≤
      Fintype.card (MetaComplexity.KWWitness (MetaComplexity.thresh n t))
```

You may need to replace `k - l` by `Nat.dist k l`; on the threshold support region `k ≥ t > l`, prove the simplification to subtraction.

### Why this matters

This makes threshold functions the first family where the KW witness relation is not just bounded but explicitly solved. That gives a canonical testbed for comparing witness entropy, protocol cost, and circuit parameters.

---

## Theorem 3: Symmetric witness decomposition by weight fibers

The structural theorem underlying Theorem 1 should be formalized explicitly, because it is independently reusable.

### Mathematical statement

For a symmetric `f` with profile `p`, the witness set decomposes as a disjoint union over weight pairs `(k,l)` with `p(k)=true`, `p(l)=false`, and for each fixed pair the number of witnesses contributed by inputs `(x,y)` of weights `(k,l)` is exactly

\[
\binom{n}{k}\binom{n}{l}|k-l|.
\]

Equivalently, if one defines the fiber

\[
W_{k,l} = \{(x,y,i) \mid |x|=k,\ |y|=l,\ f(x)=1,\ f(y)=0,\ x_i \ne y_i\},
\]

then

\[
|W_{k,l}| = \binom{n}{k}\binom{n}{l}|k-l|.
\]

### Proposed Lean 4 type signature

```lean
theorem card_weightFiber_KWWitness
    {n : ℕ} (k l : Fin (n + 1)) :
    Fintype.card
      { w : MetaComplexity.KWWitnessOnWeights n k l // True } =
        Nat.choose n k.val * Nat.choose n l.val * Nat.dist k.val l.val
```

If no such object exists, define an auxiliary finite type for triples `(x,y,i)` with fixed weights and differing coordinate `i`.

### Why this is strategically important

This is the reusable engine. Once formalized, it can drive not only exact formulas for symmetric functions, but also stability results under profile perturbation, asymptotics via central binomial estimates, and entropy comparisons.

---

# Proof strategy architecture

## Strategy A: Double-counting via triples `(x,y,i)` — most promising

1. Define the finite type of triples `(x,y,i)` where `x,y : Fin n → Bool`, `hammingWeight x = k`, `hammingWeight y = l`, and `x i ≠ y i`.
2. Count the same set in two ways:
   - Directly by summing over pairs `(x,y)` and counting differing coordinates.
   - Using the identity `HammingDist(x,y) = k + l - 2|supp(x) ∩ supp(y)|`, then summing over all pairs of fixed weights and showing the average number of differing coordinates is exactly `|k-l|` in the witness-relevant regime.
3. Better: avoid averages entirely. For witness triples when `f` is symmetric and `f(x)=1`, `f(y)=0`, every differing coordinate is a valid witness, and the total over all pairs is exactly the sum of Hamming distances. Then prove the classical identity
   \[
   \sum_{|x|=k, |y|=l} d_H(x,y)=\binom{n}{k}\binom{n}{l}|k-l|
   \]
   if your witness notion counts only one-sided coordinates, or
   \[
   = \binom{n}{k}\binom{n}{l}(k-l)
   \]
   in the regime `k ≥ l` relevant for monotone thresholds.
   
Why most promising: it aligns perfectly with finite-type counting in Lean, avoids sophisticated generating functions, and leverages `Fintype.card`, `Finset.sum`, and coordinatewise decomposition.

## Strategy B: Orbit-stabilizer / `SymmGroup` viewpoint on the Hamming cube

1. Use the action of permutations of coordinates on `{0,1}^n`.
2. Show symmetry implies the witness relation depends only on orbits of pairs `(x,y)`, classified by weights and overlap size.
3. Sum witness multiplicities over orbit representatives, collapsing overlap statistics to `|k-l|`.

Why useful: conceptually elegant and future-proof for extending from symmetric to partially symmetric functions, junta decompositions, and representation-theoretic refinements. But likely heavier in Lean unless the group-action infrastructure is already in the catalog.

## Strategy C: Generating-function extraction

1. Encode weight layers by the polynomial `(1+z)^n`.
2. Realize witness counting as a coefficient-extraction identity involving profile indicators and a differential operator tracking coordinate disagreements.
3. Derive the exact formula algebraically.

Why interesting: this opens direct asymptotic analysis and links to entropy/cumulant methods. But for Lean 4 this is probably less efficient unless the necessary polynomial coefficient lemmas are already present.

Recommendation: execute Strategy A first, then optionally expose Strategy B or C in `FUTURE_DIRECTIONS.md` as scaling routes.

---

# Cross-domain connections you should exploit explicitly

## 1. Communication complexity
The KW witness relation is a communication object. Exact witness counts for symmetric functions suggest a new “enumerative communication complexity” where profile geometry controls protocol complexity. If you can derive even partial inequalities comparing `log₂ |KWWitness f|` to exact KW protocol cost for thresholds or symmetric monotone functions, that would be field-opening.

## 2. Information theory
The formula
\[
|KWWitness(f)| = \sum_{k,l} \mu_f(k,l)\,|k-l|
\]
looks like an expected transport cost under a profile-induced measure. This invites an entropy-transport interpretation: witness count as a discrete Wasserstein-1–like statistic on the Hamming-weight line. Even a formal remark or lemma in this direction could launch a new bridge between meta-complexity and optimal transport.

## 3. Extremal combinatorics
The threshold specialization isolates boundary layers as extremal contributors. This is directly adjacent to isoperimetry on the Boolean cube, Kruskal–Katona type shadow arguments, and edge-boundary minimization. A theorem showing thresholds maximize or minimize witness count under fixed profile constraints would be a major next step.

## 4. Statistical mechanics
Symmetric Boolean functions are radial observables on the hypercube; the profile is an energy landscape over Hamming shells. The witness formula becomes a partition-function-like sum weighted by shell multiplicities and shell separation. This is exactly the kind of formal analogy that can turn asymptotic witness counting into saddle-point analysis later.

## 5. Proof complexity / monotone circuit complexity
If witness entropy tracks protocol cost up to logarithmic loss for monotone families, then exact witness formulas could become a practical lower-bound technology. Even proving this equivalence for thresholds, majority, or exact-count functions would be meaningful.

---

# Immediate theorem cascade to pursue after the core result

If Theorem 1 lands cleanly, do not stop. Push one or more of these in the same cycle if feasible.

## A. Majority closed form or asymptotic lower bound
For `Maj n`, derive a simplified expression or asymptotic lower bound using central binomial coefficients.

Possible target:

```lean
theorem lowerBound_card_KWWitness_majority
    {n : ℕ} :
    Nat.choose n (n / 2) * Nat.choose n (n / 2 - 1) ≤
      Fintype.card (MetaComplexity.KWWitness (MetaComplexity.majority n))
```

## B. Monotone symmetric layer-monotonicity
Show that for monotone symmetric profiles, all witness contributions come from `k > l`, so `Nat.dist k l = k - l`.

```lean
theorem monotone_symmetric_profile_true_false_imp_lt
    {n : ℕ} {p : Fin (n+1) → Bool}
    (hmono : Monotone p) :
    p k = true → p l = false → l.val < k.val
```

This is a small theorem, but it unlocks simplifications across the whole framework.

## C. Exact formula for exact-count / parity-like profiles
For `EXACT_t`, derive the witness count from the profile formula. If parity fails monotonicity but remains symmetric, that is a feature, not a bug: it demonstrates the full theorem’s reach beyond monotone complexity.

---

# Building blocks from the catalog to leverage

Use any existing catalog theorems about:
- `MetaComplexity.KWWitness`
- `MetaComplexity.hammingWeight`
- `MetaComplexity.IsSymmetric`
- threshold or majority definitions
- finite cardinality lemmas for Boolean vectors of fixed Hamming weight
- `Nat.choose` cardinality of weight layers
- `Nat.dist` / arithmetic simplification lemmas
- any previously proved lower bounds like `C(n,t)·C(n,t-1) ≤ |KWWitness|`

In particular, if the catalog already contains:
- a theorem giving `Fintype.card {x : (Fin n → Bool) // hammingWeight x = k} = Nat.choose n k`
- a lemma that symmetric functions factor through Hamming weight
- an existing threshold lower bound

then your job is to fuse them into a single exact theorem. That synthesis is the breakthrough.

---

# Lean engineering guidance

## Suggested auxiliary definitions
If absent, define:
- fixed-weight Boolean vectors as a subtype
- a finite type of witness triples `(x,y,i)`
- profile-induced shell fibers
- possibly `support : (Fin n → Bool) → Finset (Fin n)` if useful

## Suggested auxiliary lemmas
1. Cardinality of weight shell:
```lean
theorem card_vectors_of_weight
    {n k : ℕ} :
    Fintype.card {x : (Fin n → Bool) // MetaComplexity.hammingWeight x = k} =
      Nat.choose n k
```

2. Weight difference from one-sided disagreement count:
for `|x|=k`, `|y|=l`, the number of coordinates with `x i = true`, `y i = false` minus the number with `x i = false`, `y i = true` equals `k-l`.

3. In monotone/symmetric regimes, every witness coordinate is exactly a one-sided disagreement of the right orientation.

These are the kind of local lemmas that annihilate future sorrys.

---

# If the exact conjecture fails, pivot decisively

If your formalization reveals that `KWWitness` counts only a restricted orientation of differing coordinates, or includes additional data not reflected in the raw formula, do not force the statement. Instead prove the corrected exact formula. For example, the true factor may be:
- `k - l` instead of `Nat.dist k l`,
- or zero outside the regime `k > l`,
- or depend on the exact witness encoding.

A corrected exact theorem with a formal counterexample to the original conjectural wording would be more valuable than an unprincipled approximation.

In that case, include a machine-checkable counterexample theorem such as:

```lean
theorem counterexample_exactSymmetricWitnessFormula_originalVersion : False := ...
```

or more appropriately a concrete inequality showing mismatch for a specific `n` and profile.

---

# Revolutionary significance

If you succeed, you will have created the first exact enumerative calculus for KW witnesses of symmetric functions inside Lean. That does three things at once:

1. **Foundational:** It turns witness counting into a precise invariant rather than a source of ad hoc lower bounds.
2. **Algorithmic:** It gives a tractable formula for exhaustive computation, asymptotic estimation, and protocol comparison.
3. **Conceptual:** It reframes meta-complexity in terms of shell geometry on the Boolean cube, creating bridges to information theory, transport, extremal combinatorics, and statistical mechanics.

This is the kind of result that changes what questions can even be asked formally.

---

# Application keywords

Karchmer–Wigderson, communication complexity, meta-complexity, symmetric Boolean functions, threshold functions, witness counting, entropy method, Hamming cube, shell decomposition, extremal combinatorics, monotone complexity, exact enumeration, Boolean isoperimetry, optimal transport, statistical mechanics on the cube.

---

# Deliverables

1. Lean file(s) proving the strongest exact theorem above.
2. Minimal supporting lemmas with clear names and reusable statements.
3. If necessary, a corrected theorem plus formal counterexample to the naive version.
4. Computational sanity checks for small `n` reflected in theorem statements or examples if appropriate.
5. A structured `FUTURE_DIRECTIONS.md` containing **3–5 falsifiable scientific hypotheses**, each with:
   - a precise conjecture,
   - what Lean objects/theorems would be involved,
   - a concrete computational or formal test,
   - a clear refutation criterion.

Your hypotheses must be testable, not vague. Good examples include:
- asymptotic equivalence between `log₂ |KWWitness|` and protocol cost for threshold families,
- extremality of thresholds among monotone symmetric profiles with fixed measure,
- witness-count concentration near boundary layers for majority,
- transport/entropy inequalities for profile measures,
- exact formulas for other symmetric families like `EXACT_t` or parity.

Do not merely extend the previous cycle. Consolidate it into a theory.

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
