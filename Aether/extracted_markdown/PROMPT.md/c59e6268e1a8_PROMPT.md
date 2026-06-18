## Assignment: Formal Prime Gap Infrastructure — from admissible tuples to certified finite sieve laws and optimization thresholds

Prove new, non-trivial theorems in Lean 4, building directly on the existing admissible-tuple and CRT-sieve catalog. Minimize `sorry`. The goal is not another local lemma: it is to create the first machine-verified combinatorial backbone on which bounded-gap prime technology can actually stand.

---

## Research Direction
# Future Directions: Formal Prime Gap Infrastructure

## Strategic Vision

You now have the seed objects of modern prime-gap technology: admissibility, local obstruction avoidance, and CRT realization. The next breakthrough is to turn this from existence theory into **quantitative finite sieve infrastructure**. That means proving exact counting theorems for residue-class survivors, formalizing multiplicative local densities, and extracting finite-dimensional positivity criteria that mirror the conceptual heart of Maynard–Tao without yet invoking the deepest analytic input.

This is revolutionary because it shifts formalized number theory from “there exists a compatible residue class” to “we can exactly count and optimize survivor structures.” That transition is the combinatorial threshold between elementary modular infrastructure and genuine sieve theory.

The immediate target is a package of theorems that make the finite combinatorics of prime-gap arguments executable, certifiable, and extensible to future analytic layers.

Application keywords: **analytic number theory, sieve theory, prime gaps, CRT, local-global principle, multiplicative combinatorics, finite optimization, formal verification, executable mathematics, certified search**

Cross-domain connections:
- **Coding theory:** admissible tuples behave like forbidden residue patterns; survivor classes are codewords avoiding local constraints.
- **statistical mechanics:** the local density product is a partition function of independent local exclusions.
- **probabilistic combinatorics:** the exact finite sieve count is the deterministic analog of an independence heuristic.
- **optimization / spectral methods:** the Maynard positivity core is a Rayleigh-quotient phenomenon in finite dimension.
- **computational complexity:** decidable admissibility and exact survivor counts enable certified search over huge tuple databases.

---

## Theorem Cluster A: Executable decidability of admissibility

### Target theorem
Strengthen the already-proved bounded-prime characterization into a genuine computational decision procedure.

### Precise mathematical statement
For every finite set `H : Finset ℕ`, admissibility is decidable by finite search over primes `p ≤ H.card`, and over residues `a < p`.

A strong target is:

```lean
def Admissible (H : Finset ℕ) : Prop := 
  ∀ p : ℕ, Nat.Prime p → ∃ a : ℕ, a < p ∧ ∀ h ∈ H, (a + h) % p ≠ 0

instance instDecidableAdmissible (H : Finset ℕ) : Decidable (Admissible H) := by
  -- implement via finite prime checking up to H.card
  sorry
```

and the correctness theorem exposing the finite search boundary:

```lean
theorem admissible_iff_decidable_bounded_check
    (H : Finset ℕ) :
    Admissible H ↔
      ∀ p : ℕ, Nat.Prime p → p ≤ H.card →
        ∃ a : ℕ, a < p ∧ ∀ h ∈ H, (a + h) % p ≠ 0 := by
  simpa using admissible_iff_check_primes_le_card H
```

If the catalog already contains `admissible_iff_check_primes_le_card`, build the `Decidable` instance on top of it rather than reproving it.

### Why this matters
This converts admissibility from an abstract predicate into an executable certified object. That is the gateway to formal verification of admissible tuple databases, Polymath-style searches, and future automated discovery of near-optimal tuples.

### Proof strategy options

#### Strategy A: direct finite search extraction
1. Rewrite `Admissible H` using `admissible_iff_check_primes_le_card`.
2. Show that the set of primes `p ≤ H.card` is finite and effectively enumerable.
3. For each such `p`, decide whether there exists `a < p` avoiding all residues `-h mod p`.

Most promising because it is completely constructive and matches Lean’s strengths.

#### Strategy B: encode local obstruction set cardinality
1. For each prime `p`, define the forbidden residue set
   ```lean
   Hp p := (H.image fun h => (p - h % p) % p)
   ```
2. Show admissibility at `p` is equivalent to `Hp p`.card `< p`.
3. Decide by cardinal comparison.

This is conceptually cleaner and prepares the density theorems below.

#### Strategy C: Boolean reflection
1. Define a boolean function `admissibleB : Finset ℕ → Bool`.
2. Prove `admissibleB H = true ↔ Admissible H`.
3. Use `decide`.

This is attractive if you want executable computation and `#eval` immediately.

### Concrete test
Verify:
```lean
#eval decide (Admissible ({0, 2} : Finset ℕ))
#eval decide (Admissible ({0, 2, 4} : Finset ℕ))
```

---

## Theorem Cluster B: Exact finite density law for CRT survivors

This is the central breakthrough target.

### Definitions to formalize
For `H : Finset ℕ` and prime `p`, define the number of forbidden residue classes:
```lean
def localObstructionCount (H : Finset ℕ) (p : ℕ) : ℕ :=
  ((H.image fun h => h % p)).card
```
or equivalently via `(-h) mod p`; prove equality if needed.

For a bound `B`, define the squarefree modulus:
```lean
def primorialUpTo (B : ℕ) : ℕ :=
  ∏ p in (Finset.range (B+1)).filter Nat.Prime, p
```

Define the survivor set modulo `M = primorialUpTo B`:
```lean
def survivorsMod (H : Finset ℕ) (B : ℕ) : Finset ℕ :=
  ((Finset.range (primorialUpTo B)).filter fun n =>
    ∀ p ∈ (Finset.range (B+1)).filter Nat.Prime,
      ∀ h ∈ H, (n + h) % p ≠ 0)
```

### Exact theorem statement
The finite counting law should say that the number of residues modulo the primorial surviving all local obstructions is exactly the product of local survivor counts.

A strong Lean target:

```lean
theorem card_survivorsMod_eq_product
    (H : Finset ℕ) (B : ℕ) :
    (survivorsMod H B).card =
      ∏ p in (Finset.range (B+1)).filter Nat.Prime,
        (p - localObstructionCount H p) := by
  sorry
```

Then derive the normalized density identity:

```lean
theorem density_survivorsMod
    (H : Finset ℕ) (B : ℕ) :
    ((survivorsMod H B).card : ℚ) / (primorialUpTo B : ℚ) =
      ∏ p in (Finset.range (B+1)).filter Nat.Prime,
        ((p - localObstructionCount H p : ℚ) / p) := by
  sorry
```

Under admissibility, every factor is positive:

```lean
theorem local_factor_pos_of_admissible
    (H : Finset ℕ) (hH : Admissible H)
    {p : ℕ} (hp : Nat.Prime p) :
    localObstructionCount H p < p := by
  sorry
```

and hence:
```lean
theorem survivorsMod_nonempty_of_admissible
    (H : Finset ℕ) (B : ℕ) (hH : Admissible H) :
    0 < (survivorsMod H B).card := by
  sorry
```

### Why this is a breakthrough
This is the first exact formal finite sieve law: not merely that a CRT solution exists, but that the number of such classes is a multiplicative Euler-product-like quantity. This is the combinatorial skeleton of the Selberg and Maynard sieves. Once formalized, it becomes possible to compare exact counts with heuristic densities, optimize tuple choice, and eventually attach weighted analytic estimates.

### Proof strategy options

#### Strategy A: iterative CRT product decomposition
1. Prove the theorem first for a single prime `p`: survivor residues modulo `p` are exactly `p - ν_p(H)`.
2. Show that for coprime moduli `m, n`, survivor classes modulo `mn` correspond bijectively to pairs of survivor classes modulo `m` and modulo `n`.
3. Induct over the finite set of primes `p ≤ B`.

This is the most promising route. It uses the CRT infrastructure you already have and turns multiplicativity into an actual equivalence of finite sets.

#### Strategy B: define a residue-profile equivalence and count fibers
1. Map each `n mod M` to its tuple of residues `(n mod p)_p`.
2. Show this map is bijective by CRT.
3. The survivor condition factors coordinatewise, so the count factors as a product of coordinate survivor counts.

This is conceptually superior and closer to the Euler product philosophy. It may require more machinery for tuples over a filtered prime set, but the theorem architecture is beautiful.

#### Strategy C: finite inclusion–exclusion over forbidden classes
1. For each prime `p`, define the forbidden subset of `Z/MZ`.
2. Use independence from coprimeness to compute exact intersection sizes.
3. Derive the product formula.

This is less elegant than CRT-factorization, but could be useful if finite set APIs are already in place.

### Key intermediate lemmas
You should likely prove:

```lean
theorem card_survivors_mod_prime
    (H : Finset ℕ) {p : ℕ} (hp : Nat.Prime p) :
    (((Finset.range p).filter fun a =>
      ∀ h ∈ H, (a + h) % p ≠ 0).card) =
      p - localObstructionCount H p := by
  sorry
```

and a coprime multiplicativity statement of the form:

```lean
theorem card_survivors_mul_of_coprime
    (H : Finset ℕ) {m n : ℕ} (hcop : Nat.Coprime m n) :
    -- appropriately defined survivor sets modulo m, n, mn
    survivorCount H (m * n) = survivorCount H m * survivorCount H n := by
  sorry
```

This theorem is bigger than the bounded-prime version; if achieved, it opens an abstract multiplicative sieve algebra.

### Concrete test
For `H = {0,2}` and `B = 30`, verify computationally that the exact cardinality in `[0, primorialUpTo 30)` matches the product formula.

---

## Theorem Cluster C: Finite-dimensional positivity core of the Maynard sieve

Do not overreach to full bounded gaps yet. Formalize the finite optimization statement that isolates the combinatorial heart.

### Mathematical target
Let `k : ℕ`, `w : Fin k → ℝ`, and define
```lean
def S1 {k : ℕ} (w : Fin k → ℝ) : ℝ := ∑ i, (w i)^2
def S2 {k : ℕ} (w : Fin k → ℝ) : ℝ := (∑ i, w i)^2
```

Prove the exact extremal theorem:

```lean
theorem sum_sq_le_card_mul_sq_sum_div
    {k : ℕ} (w : Fin k → ℝ) :
    S2 w ≤ k * S1 w := by
  sorry
```

equivalently:
```lean
theorem rayleigh_quotient_bound
    {k : ℕ} (w : Fin k → ℝ) (hk : 0 < k) :
    S2 w / S1 w ≤ k := by
  sorry
```
with appropriate nonzero hypotheses for division.

And characterize equality:
```lean
theorem rayleigh_quotient_eq_iff_constant
    {k : ℕ} (hk : 0 < k) (w : Fin k → ℝ) :
    S2 w = k * S1 w ↔ ∃ c : ℝ, ∀ i, w i = c := by
  sorry
```

### Why this matters
This is not merely Cauchy–Schwarz in disguise. In the prime-gap context, it identifies the sharp finite-dimensional barrier for “first moment squared over second moment” optimization. That is exactly the algebraic shape later used in Maynard-type constructions. Formalizing this now gives a certified optimization backbone before analytic distribution estimates enter.

### Cross-domain significance
- In **spectral graph theory**, this is a rank-one extremal eigenvalue statement.
- In **information theory**, it is the collision-vs-mass inequality.
- In **quantum mechanics**, it is the maximization of overlap with the uniform state.
- In **statistics**, it is the sharp relation between mean and second moment.

### Proof strategy options

#### Strategy A: direct Cauchy–Schwarz on `Fin k`
1. Apply Cauchy–Schwarz to vectors `w` and `1`.
2. Rewrite the right-hand side as `k * ∑ w_i^2`.
3. Isolate equality conditions.

Most robust in Lean because `Finset`-sum lemmas over `Fin k` are standard.

#### Strategy B: variance decomposition
1. Expand `∑ (w_i - μ)^2 ≥ 0` where `μ = (∑ w_i)/k`.
2. Rearrange to obtain `S2 ≤ k S1`.
3. Equality iff all deviations vanish.

This route is elegant and better aligned with future probabilistic interpretations.

#### Strategy C: linear algebra / inner product spaces
1. Regard `w` as a vector in `EuclideanSpace ℝ (Fin k)`.
2. Use the norm of projection onto the constant vector.
3. Read off the operator norm.

This is the most conceptual and future-proof if you plan to connect to higher-rank weight optimization.

### Stretch theorem: weighted admissibility surrogate
Once the inequality is formalized, define a threshold predicate:
```lean
def PositiveWeightProfile {k : ℕ} (τ : ℝ) (w : Fin k → ℝ) : Prop :=
  S2 w / S1 w > τ
```
and prove:
```lean
theorem positiveWeightProfile_exists_iff
    {k : ℕ} (hk : 0 < k) (τ : ℝ) :
    (∃ w : Fin k → ℝ, 0 < S1 w ∧ PositiveWeightProfile τ w) ↔ τ < k := by
  sorry
```

This is a clean, exact finite-dimensional threshold theorem. It is the correct abstraction of “there exists a weight vector beating threshold `τ(k)`.”

That theorem would be genuinely field-opening in the formal setting: it isolates an optimization phase of the Maynard sieve as a complete and decidable finite problem.

---

## How to build on catalog theorems

You already have:
- admissibility definitions,
- bounded prime reduction (`admissible_iff_check_primes_le_card`),
- CRT realization / local avoidance infrastructure.

Use them in the following way:
1. **For Cluster A**, treat bounded-prime checking as the certified finite search frontier.
2. **For Cluster B**, use CRT realization not just for existence of one residue class, but as a bijection-of-solutions engine to count all classes.
3. **For Cluster C**, isolate the weight optimization independently of primes, so later analytic hypotheses can plug into a fully formal finite optimization theorem.

The intellectual move is: **existence → exact counting → optimization**. That is the real architecture of prime-gap machinery.

---

## Recommended execution order

1. Implement executable decidability of `Admissible`.
2. Define `localObstructionCount`, `primorialUpTo`, and survivor sets modulo a modulus.
3. Prove single-prime survivor count.
4. Prove multiplicativity under coprime moduli.
5. Specialize to primorials and derive the exact product formula.
6. Formalize the `S2 ≤ k S1` optimization theorem and its equality characterization.
7. If time remains, prove the threshold existence theorem `∃ w, ratio > τ ↔ τ < k`.

This order minimizes risk and maximizes theorem reuse.

---

## Deliverables

Produce:
- Lean theorem files with the exact counting and optimization results above.
- At least one executable example (`#eval`) for admissibility and one computational check of the survivor count formula.
- Minimal `sorry`.
- A short note explaining which APIs were missing and which reusable abstractions were created.

---

## Required FUTURE_DIRECTIONS.md

You must also produce a structured `FUTURE_DIRECTIONS.md` containing **3–5 falsifiable scientific hypotheses**, each with:
1. a precise conjecture,
2. a concrete formal test,
3. what theorem infrastructure would be needed,
4. what mathematical consequence would follow if true.

These must be real hypotheses, not vague directions. Strong candidates include:
- multiplicativity of survivor counts for arbitrary squarefree moduli,
- exact comparison between survivor density and inclusion–exclusion truncations,
- formalization of Selberg sieve quadratic forms,
- extremal admissible tuples minimizing local obstruction entropy,
- certified search for optimal small-diameter admissible tuples.

Be bold. The destination is not another lemma about residues; it is a machine-verified combinatorial theory robust enough to carry the first formal prime-gap arguments.

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
