## Assignment: Goldbach Conjecture — Formalize the Additive Prime Frontier, Not Just the Headline

Mode: **prove + formalize + discover**

You should not spend the cycle merely restating the binary Goldbach conjecture in Lean and getting stuck on the full open problem. The breakthrough target is to **build a formal additive-prime infrastructure** in Lean 4 that makes major analytic number theory statements expressible, composable, and partially provable, while extracting new certified bridge theorems between primality, semiprimality, finite convolution, and asymptotic additive decompositions.

The scientifically serious goal is:

1. **Formalize exact finite Goldbach-type predicates** for naturals.
2. **Prove unconditional structural theorems** about Goldbach witness sets and prime/semiprime decompositions.
3. **Package sufficiently-large asymptotic statements** (Vinogradov/Chen style) into Lean-ready theorem schemas, even if some deepest analytic lemmas must be isolated as axioms/interfaces first.
4. **Create cross-domain bridges** from additive number theory to convolution algebras, finite combinatorics, and certified primality infrastructure.

This is not an incremental exercise. If done correctly, it opens a formal path toward a machine-checked fragment of the Hardy–Littlewood world.

---

## Core Definitions to Introduce

Use concrete computable predicates on `ℕ`.

```lean
def IsSemiprime (n : ℕ) : Prop :=
  ∃ a b : ℕ, Nat.Prime a ∧ Nat.Prime b ∧ a * b = n

def GoldbachPair (n p q : ℕ) : Prop :=
  Nat.Prime p ∧ Nat.Prime q ∧ p + q = n

def HasGoldbachDecomposition (n : ℕ) : Prop :=
  ∃ p q : ℕ, GoldbachPair n p q

def ChenPair (n p s : ℕ) : Prop :=
  Nat.Prime p ∧ IsSemiprime s ∧ p + s = n

def HasChenDecomposition (n : ℕ) : Prop :=
  ∃ p s : ℕ, ChenPair n p s

def OddVinogradovTriple (n a b c : ℕ) : Prop :=
  Nat.Prime a ∧ Nat.Prime b ∧ Nat.Prime c ∧ a + b + c = n

def HasOddVinogradovDecomposition (n : ℕ) : Prop :=
  ∃ a b c : ℕ, OddVinogradovTriple n a b c
```

Also define witness finsets for bounded computation:

```lean
def primeDivisorCandidates (n : ℕ) : Finset ℕ := (Finset.range (n+1)).filter Nat.Prime

def goldbachWitnesses (n : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.range (n+1)).product (Finset.range (n+1))).filter
    (fun pq => Nat.Prime pq.1 ∧ Nat.Prime pq.2 ∧ pq.1 + pq.2 = n)
```

These will let you prove finitary existence ↔ nonemptiness theorems and support computational experiments.

---

## Precise Theorem Targets

You should aim to prove the following theorems, in roughly increasing ambition.

### Theorem 1: Even-number reduction from ternary Goldbach
This is a genuine structural bridge theorem: if sufficiently large odd integers are sums of three odd primes, then sufficiently large even integers are sums of a prime and a semiprime.

**Mathematical statement**  
For every threshold `N`, if every odd `m ≥ N+1` is a sum of three primes, then every even `n ≥ N` is a sum of a prime and a semiprime.

Reason: from `n+1 = a+b+c`, rewrite `n = a + (bc)` only if you have multiplicative control? No — that is false. So do **not** claim this. Instead, prove the correct reduction:

### Theorem 1 (corrected): Binary Goldbach implies ternary Goldbach for odd integers > 5
```lean
theorem binary_goldbach_implies_ternary
  (hG : ∀ n : ℕ, Even n → 2 < n → HasGoldbachDecomposition n) :
  ∀ n : ℕ, Odd n → 5 < n → HasOddVinogradovDecomposition n
```

**Proof idea:** write `n = 3 + (n - 3)`, note `n - 3` is even and > 2 for odd `n > 5`, apply binary Goldbach to `n - 3`, then prepend prime `3`.

This is elementary, formalizable, and conceptually important: it shows how a hypothetical binary theorem would propagate into the ternary world.

---

### Theorem 2: Goldbach witness finiteness and decidable search equivalence
```lean
theorem hasGoldbachDecomposition_iff_witnesses_nonempty
  (n : ℕ) :
  HasGoldbachDecomposition n ↔ (goldbachWitnesses n).Nonempty
```

This theorem is not deep analytically, but it is foundational for certified computation. It turns a classical existential statement into a concrete finite-search object.

A stronger version:

```lean
theorem hasGoldbachDecomposition_decidable
  (n : ℕ) : Decidable (HasGoldbachDecomposition n)
```

using bounded search over `0..n`.

This is a critical formal infrastructure theorem because it allows verified exploration of Goldbach up to large bounds by extraction.

---

### Theorem 3: Symmetry of Goldbach witnesses
```lean
theorem goldbach_pair_symm {n p q : ℕ} :
  GoldbachPair n p q → GoldbachPair n q p
```

and at the finset level:

```lean
theorem mem_goldbachWitnesses_swap {n p q : ℕ} :
  (p, q) ∈ goldbachWitnesses n → (q, p) ∈ goldbachWitnesses n
```

This matters because later counting arguments should quotient by the involution `(p,q) ↔ (q,p)`.

---

### Theorem 4: Parity forcing in Goldbach decompositions
```lean
theorem goldbach_pair_even_gt_four_both_odd
  {n p q : ℕ}
  (hn_even : Even n)
  (hn_gt : 4 < n)
  (h : GoldbachPair n p q) :
  Odd p ∧ Odd q
```

This is a clean theorem with actual mathematical content: the only even prime is `2`, and if one summand were `2`, the other would be `n-2`, forcing exceptional small cases. This isolates the parity geometry of Goldbach decompositions.

A useful corollary:

```lean
theorem goldbach_decomposition_of_even_gt_four_avoids_two
  {n p q : ℕ}
  (hn_even : Even n)
  (hn_gt : 4 < n)
  (h : GoldbachPair n p q) :
  p ≠ 2 ∧ q ≠ 2
```

---

### Theorem 5: Chen-type decomposition from actual Goldbach decomposition
This is not Chen’s theorem, but it is a formally useful bridge.

```lean
theorem goldbach_implies_chen
  {n : ℕ}
  (h : HasGoldbachDecomposition n) :
  HasChenDecomposition n
```

because every prime is “morally simpler than” a semiprime? Careful: your `IsSemiprime` definition does **not** include primes. So this theorem is false as stated.

Instead define an “almost prime of level 2” predicate:

```lean
def PrimeOrSemiprime (n : ℕ) : Prop :=
  Nat.Prime n ∨ IsSemiprime n

def HasWeakChenDecomposition (n : ℕ) : Prop :=
  ∃ p s : ℕ, Nat.Prime p ∧ PrimeOrSemiprime s ∧ p + s = n
```

Then prove:

```lean
theorem goldbach_implies_weakChen
  {n : ℕ}
  (h : HasGoldbachDecomposition n) :
  HasWeakChenDecomposition n
```

This is a clean interface theorem between exact Goldbach and Chen-style additive decompositions.

---

### Theorem 6: Small verified range theorem
Do not underestimate the value of a formally verified finite range. Prove a theorem of the form:

```lean
theorem goldbach_up_to_bound :
  ∀ n ∈ Finset.Icc 4 1000, Even n → HasGoldbachDecomposition n
```

or a larger bound if performance permits.

This theorem is mathematically modest but strategically crucial: it produces certified data and a reusable computational pattern. If you can connect to `aks_congruence_holds_for_prime`, you gain a principled bridge to verified primality checking rather than opaque automation.

---

### Theorem 7: Formal schema for ternary asymptotic Goldbach
If a full Vinogradov proof is out of scope, create a theorem interface that isolates the analytic core.

```lean
theorem vinogradov_schema
  (N : ℕ)
  (hMajorMinorArcEstimate :
    -- precise analytic hypothesis you define
    True) :
  ∀ n : ℕ, Odd n → n ≥ N → HasOddVinogradovDecomposition n
```

The point is not to fake the proof; the point is to **architect the formal statement** so future analytic lemmas can plug into it. This is high-value formalization work.

---

## Recommended Lean 4 Type Signatures

Use these exact signatures or close variants.

```lean
def IsSemiprime (n : ℕ) : Prop :=
  ∃ a b : ℕ, Nat.Prime a ∧ Nat.Prime b ∧ a * b = n

def GoldbachPair (n p q : ℕ) : Prop :=
  Nat.Prime p ∧ Nat.Prime q ∧ p + q = n

def HasGoldbachDecomposition (n : ℕ) : Prop :=
  ∃ p q : ℕ, GoldbachPair n p q

def HasOddVinogradovDecomposition (n : ℕ) : Prop :=
  ∃ a b c : ℕ, Nat.Prime a ∧ Nat.Prime b ∧ Nat.Prime c ∧ a + b + c = n

theorem binary_goldbach_implies_ternary
  (hG : ∀ n : ℕ, Even n → 2 < n → HasGoldbachDecomposition n) :
  ∀ n : ℕ, Odd n → 5 < n → HasOddVinogradovDecomposition n := by
  sorry

theorem hasGoldbachDecomposition_iff_witnesses_nonempty
  (n : ℕ) :
  HasGoldbachDecomposition n ↔ (goldbachWitnesses n).Nonempty := by
  sorry

theorem goldbach_pair_even_gt_four_both_odd
  {n p q : ℕ}
  (hn_even : Even n)
  (hn_gt : 4 < n)
  (h : GoldbachPair n p q) :
  Odd p ∧ Odd q := by
  sorry

def PrimeOrSemiprime (n : ℕ) : Prop :=
  Nat.Prime n ∨ IsSemiprime n

def HasWeakChenDecomposition (n : ℕ) : Prop :=
  ∃ p s : ℕ, Nat.Prime p ∧ PrimeOrSemiprime s ∧ p + s = n

theorem goldbach_implies_weakChen
  {n : ℕ}
  (h : HasGoldbachDecomposition n) :
  HasWeakChenDecomposition n := by
  sorry
```

---

## Proof Strategy Architecture

You must pursue at least 2–3 proof pathways in parallel.

### Strategy A: Elementary parity-combinatorial infrastructure
Most promising for immediate Lean success.

1. Define `GoldbachPair`, `HasGoldbachDecomposition`, `IsSemiprime`, witness finsets.
2. Prove parity lemmas: primes > 2 are odd; in an even prime sum above 4, both summands are odd.
3. Build search equivalences and finite certified range theorems.

**Why promising:** Mathlib already has parity and primality lemmas on `Nat`; this path produces real theorems with minimal analytic overhead and establishes the formal substrate for deeper results.

---

### Strategy B: Reduction theorems between binary, ternary, and weak-Chen worlds
Best conceptual payoff.

1. Prove `binary_goldbach_implies_ternary`.
2. Prove exact logical implications:
   - Goldbach ⇒ weak Chen
   - explicit small-range ternary ⇒ corresponding odd-range decompositions
3. Package these as transfer principles.

**Why promising:** Even if the full open conjectures remain unproved, these reduction theorems clarify the dependency graph of additive prime conjectures in a machine-checked way.

---

### Strategy C: Analytic-number-theory interface formalization
Most visionary, highest risk.

1. Define arithmetic functions as finitely supported sums on initial intervals:
   - prime indicator
   - semiprime indicator
   - Goldbach representation count `r₂(n)`
2. Express `r₂(n)` as an additive convolution:
   ```lean
   r₂(n) = ∑ x in Finset.range (n+1), primeIndicator x * primeIndicator (n-x)
   ```
3. Formalize a schema where positivity of the convolution implies a Goldbach witness.
4. Isolate major-arc/minor-arc estimates as assumptions or future lemmas.

**Why promising:** This is the bridge to the circle method, Fourier analysis on finite intervals, and eventually asymptotic additive combinatorics in Lean.

---

## How to Build on the Catalog Theorems

The injected catalog is sparse and partially speculative, but you should still mine it intelligently.

- `semiprime_eq_iInter_prime_theories`  
  Use this as conceptual motivation for `IsSemiprime` and for bridge lemmas connecting semiprimality to structured decompositions. Even if the theorem is abstract/algebraic, reinterpret it as evidence that semiprimes admit multiple equivalent characterizations. Build a concrete arithmetic-facing lemma layer on top.

- `aks_congruence_holds_for_prime`  
  This is the most relevant theorem operationally. Use it to justify a verified primality testing workflow for bounded search. If you implement `goldbach_up_to_bound`, connect primality checks to this theorem or its surrounding file, rather than relying purely on simplification. This creates a bridge between additive number theory and certified complexity-theoretic primality.

- `krull_height_theorem_security_prime`  
  At first glance remote, but there is a visionary angle: prime objects often control extremal decomposition behavior across algebra and arithmetic. If you can extract a “prime obstruction” metaphor or a structural statement about irreducibility vs additive decomposition, include it in discussion, not as forced formal dependency.

- `prime_two_zeros` and `count_sum_two_sq_0`  
  These are not directly Goldbach, but they suggest a theme: counting representations by structured arithmetic forms. Use this as a cross-domain analogy—Goldbach counts are another representation-counting problem, and the right abstraction is a representation function over arithmetic predicates.

---

## Cross-Domain Connections You Must Explicitly Develop

### 1. Additive combinatorics / finite convolution
Define a representation count:
```lean
def goldbachCount (n : ℕ) : ℕ := ...
```
and prove:
```lean
theorem goldbachCount_pos_iff
  (n : ℕ) :
  0 < goldbachCount n ↔ HasGoldbachDecomposition n
```
This reframes Goldbach as positivity of a convolution coefficient. That is the correct formal gateway to circle-method ideas.

### 2. Complexity theory / certified primality
Leverage `aks_congruence_holds_for_prime` to connect existence theorems with executable verification. Keywords: **AKS**, **certificate extraction**, **proof-producing primality tests**.

### 3. Algebraic signal processing / Fourier viewpoint
Even if not fully formalized, state the roadmap: Goldbach counts are coefficients of convolutions of prime-indicator functions; circle method approximates these coefficients by harmonic analysis. In Lean, finite interval convolution is the discrete algebraic shadow of this.

### 4. Probabilistic number theory
Use experiments on `goldbachCount n` to formulate hypotheses about growth, local fluctuations, and parity-bias effects. These become entries in `FUTURE_DIRECTIONS.md`.

---

## Breakthrough Significance

A successful cycle here does **not** mean “solve Goldbach.” It means:

- establishing the first robust Lean infrastructure for **formal additive prime decomposition theory**;
- making Goldbach/Vinogradov/Chen statements machine-expressible in interoperable forms;
- bridging primality certification with additive representation counting;
- creating a reusable formal scaffold for future work on the circle method, sieve methods, and additive combinatorics.

This opens an entire field: **certified analytic number theory in Lean**, where asymptotic statements are not isolated folklore but composable verified artifacts.

If you can prove even a handful of strong infrastructure theorems plus a nontrivial verified finite range, you create a platform others can extend toward:
- Hardy–Littlewood heuristics,
- explicit Goldbach verification,
- Chen-style almost-prime decompositions,
- finite Fourier-analytic additive number theory.

---

## Application Keywords

Goldbach, Vinogradov theorem, Chen theorem, additive number theory, circle method, sieve methods, semiprimes, prime decomposition, finite convolution, representation functions, certified primality, AKS, asymptotic combinatorics, formalized analytic number theory, discrete Fourier analysis, theorem proving, Lean 4, Mathlib.

---

## Concrete Deliverables

1. Lean file formalizing the core predicates and theorems above.
2. At least one theorem with no sorry among:
   - `binary_goldbach_implies_ternary`
   - `hasGoldbachDecomposition_iff_witnesses_nonempty`
   - `goldbach_pair_even_gt_four_both_odd`
   - `goldbach_implies_weakChen`
3. One verified bounded-range theorem by computation.
4. A representation-count definition and at least one positivity/existence equivalence.
5. `FUTURE_DIRECTIONS.md` with **3–5 falsifiable scientific hypotheses**.

---

## Required FUTURE_DIRECTIONS.md Content

Include 3–5 testable hypotheses, each with:
- precise conjecture,
- why it matters,
- how to test in Lean/computation,
- what outcome would falsify it.

You must include hypotheses of this style:

1. **Goldbach count lower-bound hypothesis**  
   Conjecture: for all even `n ≥ 8` up to tested bound `B`, `goldbachCount n ≥ 2`.  
   Test: compute exactly for increasing `B`.  
   Falsifier: an even `n ≥ 8` with `goldbachCount n < 2`.

2. **Weak Chen prevalence hypothesis**  
   Conjecture: every even `n ≥ 4` up to bound `B` has `HasWeakChenDecomposition n`.  
   Test: bounded exhaustive search with prime/semiprime witnesses.  
   Falsifier: explicit counterexample.

3. **Parity-regularity hypothesis for witness counts**  
   Conjecture: for even `n > 4`, all Goldbach witnesses involve odd primes only.  
   Test: immediate theorem proof and bounded search sanity check.  
   Falsifier: witness involving `2`.

4. **Convolution-growth heuristic**  
   Conjecture: empirical average of `goldbachCount n` over even `n ≤ B` grows faster than `B^α` for some tested `α > 0`.  
   Test: compute averages at dyadic scales.  
   Falsifier: sub-threshold growth across scales.

5. **Ternary-from-binary transfer robustness**  
   Conjecture: any formal local binary theorem on interval `[4, B]` induces a ternary theorem on odd interval `[7, B+3]`.  
   Test: formal interval lemma in Lean.  
   Falsifier: failed derivation or boundary counterexample.

---

## Final Directive

Be ruthless about correctness: do **not** smuggle in false implications between Goldbach, Vinogradov, and Chen. If a proposed theorem is too strong, weaken it to a true structural bridge and prove that cleanly.

The real opportunity is to invent the formal language in which future analytic number theory can live. Build the additive prime calculus. Prove the transfer theorems. Certify the finite evidence. Then leave a sharp `FUTURE_DIRECTIONS.md` that turns Goldbach from a slogan into a research program.

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
