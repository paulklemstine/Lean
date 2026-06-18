## Assignment: Inductive soundness

Mode: **prove**

Prove a genuinely new soundness theorem for the inductive step of the sum-check protocol in Lean 4, isolating the exact mechanism by which a cheating prover is caught when they transmit an incorrect round polynomial. Do not settle for a slogan like “by Schwartz–Zippel”; formalize the precise finite-field statement that turns disagreement of partial-sum polynomials into a quantitative cheating bound.

Minimize `sorry`. If you need auxiliary lemmas, create them cleanly and in reusable form.

### Research Direction

The core target is the **one-round inductive soundness principle** behind sum-check:

If in round `i` the prover sends a univariate polynomial `sᵢ` that is not equal to the true partial-sum polynomial `tᵢ`, then for a uniformly random verifier challenge `r ∈ 𝔽_q`, the probability that the cheating polynomial passes the consistency check
\[
sᵢ(r)=tᵢ(r)
\]
is at most `deg(sᵢ - tᵢ) / q`, and in the affine-linear case at most `1 / q`.

This is the algebraic “fault line” of interactive proof soundness. Formalizing it cleanly in Lean 4 opens the door to machine-verified soundness of PCP/IOP primitives, polynomial commitment verification logic, and eventually verified cryptographic proof systems.

### Precise Theorem Statement

Work over a finite field `F` with `Fintype F`. Let `p q : Polynomial F`. The fundamental theorem should state that if `p ≠ q`, then the set of points where they agree is small.

A mathematically precise target:

\[
\forall p q : F[X],\ p \neq q \to
\#\{x : F \mid p.eval x = q.eval x\} \le \natDegree(p-q).
\]

This bound is strongest when `natDegree (p - q) < Fintype.card F`; if needed, prove the more standard capped form:

\[
\#\{x : F \mid p.eval x = q.eval x\} \le \natDegree(p-q),
\quad\text{hence}\quad
\Pr_x[p.eval x = q.eval x] \le \frac{\natDegree(p-q)}{|F|}.
\]

For the sum-check use case, also isolate the affine-linear corollary:

\[
\forall p q : F[X],\ p \neq q \to p.natDegree \le 1 \to q.natDegree \le 1 \to
\#\{x : F \mid p.eval x = q.eval x\} \le 1.
\]

Then derive the probabilistic statement:

\[
\Pr_{x \sim \mathrm{unif}(F)}[p.eval x = q.eval x] \le \frac{1}{|F|}.
\]

### Lean 4 Type Signature Targets

Aim to prove variants close to the following signatures. Adjust names and assumptions to match Mathlib APIs exactly, but keep the mathematical content unchanged.

```lean
theorem card_eq_eval_le_natDegree_sub
    {F : Type*} [Field F] [Fintype F]
    (p q : Polynomial F) (hne : p ≠ q) :
    Fintype.card {x : F // p.eval x = q.eval x} ≤ (p - q).natDegree := by
  ...
```

A more API-friendly finite-set version may be easier:

```lean
theorem card_roots_sub_le_natDegree
    {F : Type*} [Field F] [Fintype F]
    (p q : Polynomial F) (hne : p ≠ q) :
    (((Finset.univ.filter fun x : F => p.eval x = q.eval x).card)
      ≤ (p - q).natDegree) := by
  ...
```

Probabilistic/counting corollary:

```lean
theorem cheating_success_prob_le_degree_div_card
    {F : Type*} [Field F] [Fintype F]
    (p q : Polynomial F) (hne : p ≠ q) :
    ((Finset.univ.filter fun x : F => p.eval x = q.eval x).card : ℚ)
      / Fintype.card F ≤ (p - q).natDegree / Fintype.card F := by
  ...
```

Affine-linear special case:

```lean
theorem affine_disagreement_caught_except_at_most_one_point
    {F : Type*} [Field F] [Fintype F]
    (p q : Polynomial F) (hne : p ≠ q)
    (hp : p.natDegree ≤ 1) (hq : q.natDegree ≤ 1) :
    (Finset.univ.filter fun x : F => p.eval x = q.eval x).card ≤ 1 := by
  ...
```

And the sum-check round lemma itself, phrased abstractly:

```lean
theorem sumcheck_round_soundness_degree_one
    {F : Type*} [Field F] [Fintype F]
    (sent truePoly : Polynomial F)
    (hne : sent ≠ truePoly)
    (hs : sent.natDegree ≤ 1)
    (ht : truePoly.natDegree ≤ 1) :
    (Finset.univ.filter fun r : F => sent.eval r = truePoly.eval r).card
      ≤ 1 := by
  ...
```

If Mathlib’s `natDegree` behavior around zero causes friction, introduce a theorem with explicit nonzeroness of `p - q`, deduced from `hne`.

### Why This Is a Breakthrough

This is not merely a finite-field exercise. It is the first certified algebraic brick in a formal theory of **interactive proof soundness**. Once this theorem exists in reusable form, Aristotle can stack it into:

- verified sum-check protocol soundness,
- verified low-degree testing,
- verified polynomial commitment opening checks,
- certified Fiat–Shamir soundness reductions in algebraic models,
- formal bridges from theorem proving to cryptographic proof systems.

The real breakthrough is to make “a cheating prover is caught with high probability” into a theorem that is not handwaved, but mechanized and compositional.

### Proof Strategy Architecture

#### Strategy A: Reduce equality points to roots of `p - q` (most promising)

1. Prove pointwise equivalence:
   \[
   p.eval x = q.eval x \iff (p - q).eval x = 0.
   \]
   In Lean this should follow from `Polynomial.eval_sub`.

2. Identify the set
   \[
   \{x \mid p.eval x = q.eval x\}
   \]
   with the roots of `p - q`, either as a `Multiset`, `Finset`, or subtype.

3. Apply the catalog/Mathlib root bound theorem for nonzero polynomials:
   cardinality of roots is at most `natDegree`.

This is the best route because it matches the conceptual cryptographic proof exactly: cheating means a nonzero discrepancy polynomial, and passing means hitting one of its roots.

#### Strategy B: Factor theorem via a reusable Schwartz–Zippel lemma

1. First prove a univariate Schwartz–Zippel theorem over finite fields:
   for nonzero `f : Polynomial F`,
   \[
   \#\{x : F \mid f.eval x = 0\} \le f.natDegree.
   \]

2. Then instantiate with `f = p - q`.

3. Derive degree-1 and probability corollaries.

This route is slightly more ambitious but more reusable. It packages the algebraic counting principle in exactly the form future protocol work will need.

#### Strategy C: Affine-linear classification

1. For degree ≤ 1 polynomials, show `p - q` also has degree ≤ 1.
2. If `p ≠ q`, then `p - q` is nonzero and has at most one root.
3. Conclude the verifier catches cheating except possibly at one challenge.

This is ideal for a first polished theorem if full generality becomes API-heavy. It already proves the canonical sum-check round bound in the multilinear setting.

### Most Promising Route

Start with **Strategy A**, then derive Strategy C as a corollary. If successful, refactor the key lemma into a Schwartz–Zippel-style theorem afterward. That ordering minimizes implementation risk while maximizing eventual reuse.

### Mathematical Framing

The soundness induction for sum-check is a recursive integrity statement about partial summation operators. At round `i`, the honest polynomial is the compression of a higher-dimensional polynomial into a one-variable marginal:
\[
t_i(X_i)=\sum_{b_{i+1},\dots,b_n \in \{0,1\}} g(r_1,\dots,r_{i-1},X_i,b_{i+1},\dots,b_n).
\]
A cheating prover sends some `s_i`. If `s_i ≠ t_i`, then `δ_i := s_i - t_i` is a nonzero low-degree univariate polynomial. The verifier’s challenge `r_i` samples the discrepancy at a random point. Soundness is therefore a statement about the inability of a nonzero low-degree polynomial to vanish too often.

This is exactly the algebraic analogue of:
- error detection in coding theory,
- identity testing in complexity theory,
- collision rarity in hashing,
- resonance avoidance in physics-inspired transfer operators.

### Cross-Domain Connections

Connect this theorem to at least one other domain in the writeup and file structure.

1. **Coding theory**  
   A false round polynomial is an error word; the verifier’s random evaluation is a spot-check against a Reed–Solomon-like codeword. This theorem is a local testability primitive.

2. **Complexity theory / PCPs / IOPs**  
   Sum-check is a foundational interactive proof protocol. Formalizing this lemma builds toward certified IP = PSPACE infrastructure at the proof-object level.

3. **Cryptography**  
   Polynomial identity checks underlie polynomial commitments, SNARK arithmetization, and Fiat–Shamir transcripts. This theorem is a formal micro-foundation for modern proof systems.

4. **Sheaf/gluing perspective**  
   Use `round_trip_exact_with_gluing` conceptually: local consistency constraints determine global validity. Here, consistency at random points is a probabilistic gluing test for algebraic sections.

5. **Dynamical systems / contraction analogies**  
   The existing partial-sum and contraction theorems suggest an abstract pattern: repeated reduction preserves a bounded defect measure. Sum-check soundness can be seen as defect propagation controlled by algebraic sparsity.

### How to Build on Catalog Theorems

The listed catalog theorems are not directly about finite fields, but they suggest a reusable architecture:

- `geometric_partial_sum_bound` and `geometric_contraction_partial_sum`: use them as a conceptual template for controlling accumulated error across rounds. After proving one-round soundness, formulate a multi-round union bound theorem in the same spirit: total cheating success decays by summing per-round failure probabilities.

- `nilpotent_partial_sum_bound`: this hints at finite termination of iterated error propagation. Analogously, discrepancy polynomials collapse to zero only if every round polynomial is honest; otherwise a nonzero witness persists and can be detected.

- `round_trip_exact_with_gluing`: use this as a bridge principle in the exposition. Honest local consistency equations should glue to the true global sum polynomial; failure to glue creates a detectable discrepancy section.

- `reduction_terminates_with_height_bound`: use this as inspiration for an induction on protocol rounds. Each round reduces dimension/arity while preserving a quantitative soundness invariant.

Do not force artificial dependencies in Lean if they are mathematically orthogonal, but do explicitly position your theorem as the algebraic analogue of these “controlled reduction” results.

### Concrete Deliverables

1. A Lean file formalizing one or more of the target theorems above.
2. At least one theorem in a reusable Schwartz–Zippel/root-bound form.
3. At least one theorem explicitly named for sum-check round soundness.
4. Minimal `sorry`.
5. A structured `FUTURE_DIRECTIONS.md`.

### Suggested Auxiliary Lemmas

You will likely need clean helper lemmas such as:

```lean
lemma eval_eq_eval_iff_eval_sub_eq_zero
    {F : Type*} [Field F] (p q : Polynomial F) (x : F) :
    p.eval x = q.eval x ↔ (p - q).eval x = 0 := by
  ...
```

```lean
lemma sub_ne_zero_of_ne
    {F : Type*} [Ring F] {p q : Polynomial F} (h : p ≠ q) :
    p - q ≠ 0 := by
  ...
```

```lean
lemma natDegree_sub_le_max
    {F : Type*} [Field F] (p q : Polynomial F) :
    (p - q).natDegree ≤ max p.natDegree q.natDegree := by
  ...
```

The last lemma is useful for deriving the degree-1 corollary.

### Stretch Goal: Multi-round Inductive Soundness

If the one-round theorem lands cleanly, push to a true inductive statement:

For polynomials of individual degree at most `d`, if the prover first deviates at round `i`, then conditioned on reaching round `i`, the probability of escaping detection from that round onward is at most `d / |F|`.

A possible Lean-facing skeleton:

```lean
theorem sumcheck_inductive_soundness_step
    {F : Type*} [Field F] [Fintype F]
    (d : ℕ)
    (sent truePoly : Polynomial F)
    (hne : sent ≠ truePoly)
    (hdeg : (sent - truePoly).natDegree ≤ d) :
    (Finset.univ.filter fun r : F => sent.eval r = truePoly.eval r).card ≤ d := by
  ...
```

Then specialize to `d = 1`.

### Application Keywords

sum-check, Schwartz–Zippel, finite fields, polynomial identity testing, interactive proofs, PCP, IOP, SNARK foundations, Reed–Solomon codes, formal cryptography, mechanized soundness, algebraic complexity, certified randomness, low-degree testing

### Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, each including:
- a precise theorem statement,
- why it is breakthrough-level,
- likely Lean proof strategy,
- cross-domain connection.

Suggested directions include:
1. Full multi-round sum-check soundness with union bound.
2. Multivariate Schwartz–Zippel over finite grids.
3. Formal low-degree testing for Reed–Muller/Reed–Solomon style codes.
4. Soundness bridge from sum-check to polynomial commitments.
5. A categorical/sheaf-theoretic formulation of local algebraic consistency tests.

You are Aristotle. Build the algebraic detection theorem that modern proof systems quietly rely on, and make it machine-verifiable.

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
