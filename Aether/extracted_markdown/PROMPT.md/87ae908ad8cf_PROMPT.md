## Assignment: This document identifies five falsifiable scientific hypotheses emerging from

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

### Research Direction
# Future Directions: Formal Additive Prime Decomposition Theory

## Overview

This document identifies five falsifiable scientific hypotheses emerging from our formalization of Goldbach-type additive prime decompositions. The immediate goal is not another bounded verification, but a structural theory of additive prime decompositions inside Lean 4: parity laws, multiplicity rigidity, semiprime relaxations, and asymptotic-combinatorial shadows that can be formalized now and scaled later.

This direction becomes genuinely field-opening if we can convert “there exists a decomposition” into a hierarchy of formally certified conservation laws and multiplicity constraints. The breakthrough is to treat additive prime representations as a discrete statistical mechanics of primes: parity is the conserved charge, semiprimes are the first effective excitation above primes, and representation counts are partition functions. Formalizing this viewpoint in Lean would create a reusable architecture for additive number theory, analytic heuristics, and certified computation.

Build aggressively on existing catalog results about Goldbach witnesses, parity of primes, finite witness sets, and interval verification. Every theorem below should be formulated to exploit finite set/cardinality lemmas, `Nat.Prime` parity facts, list/multiset counting identities, and native_decide-based bounded certification.

Every thread below must culminate in a structured `FUTURE_DIRECTIONS.md` containing **3–5 falsifiable hypotheses**, each with:
1. a precise statement,
2. a computational or proof-theoretic test,
3. a clear falsifier,
4. a short note on downstream consequences.

---

## Hypothesis 1: Universal Goldbach Multiplicity Lower Bound

**Visionary claim:** Goldbach existence is only the zeroth-order phenomenon. The first structural layer is that beyond the trivial low-energy exceptions, the prime self-convolution never drops back to multiplicity one.

### Precise theorem statement

Let `goldbachWitnesses n` denote the finite set of ordered prime pairs `(p,q)` with `p + q = n`.

**Mathematical statement**
\[
\forall n \in \mathbb{N},\ 8 \le n \to Even\ n \to 2 \le (goldbachWitnesses\ n).card.
\]

Equivalently: `4 = 2+2` and `6 = 3+3` are the only even integers with exactly one ordered Goldbach representation.

### Suggested Lean 4 type signature
```lean
theorem goldbach_multiplicity_ge_two
    (n : ℕ) (hn : 8 ≤ n) (he : Even n) :
    2 ≤ (goldbachWitnesses n).card
```

A stronger and more elegant version, if your API supports ordered/unordered conversion:
```lean
theorem unique_goldbach_representation_iff
    (n : ℕ) (he : Even n) (h4 : 4 ≤ n) :
    (goldbachWitnesses n).card = 1 ↔ n = 4 ∨ n = 6
```

### Why this would be a breakthrough

This upgrades Goldbach from an existence phenomenon to a **multiplicity rigidity theorem**. It says the additive prime landscape has a forbidden phase: once past 6, the self-convolution of the prime indicator cannot attain its smallest nontrivial value. Formally, this is the first step from “nonempty support” to “geometric shape” of the support.

### Proof strategy options

**Strategy A: Symmetry + diagonal obstruction analysis**  
Most promising if the witness set is ordered.
1. Show that any witness `(p,q)` with `p ≠ q` produces a distinct witness `(q,p)`.
2. Conclude that a singleton witness set forces `p = q`, hence `n = 2p`.
3. Use parity of primes for `n ≥ 8`: if `p ≥ 4`, then `p` odd prime implies `n = 2p` with `p ≥ 5`; now search for a second decomposition or reduce to bounded exceptional analysis.  
Why promising: it leverages existing finite-cardinality infrastructure and only needs a sharp analysis of the diagonal case.

**Strategy B: Exhaust diagonal cases via constructive prime perturbation**
1. Assume unique ordered representation, deduce it must be diagonal.
2. Show that for `n = 2p` with `p ≥ 5`, one can derive another representation by testing small prime offsets (`3 + (n-3)`, `5 + (n-5)`) under certified finite search up to a threshold.
3. Combine structural reduction with bounded computation for the residual range.  
Why promising: ideal if catalog already contains certified interval verification.

**Strategy C: Convolution/cardinality viewpoint**
1. Define the ordered representation count as a finite convolution of the prime predicate.
2. Show parity/symmetry forces counts away from 1 except in the two diagonal base cases.
3. Refine with explicit decomposition of the diagonal contribution.  
Why promising: opens the door to later asymptotic formalization, though likely heavier for the immediate theorem.

### Cross-domain connections

- **Additive combinatorics:** support and multiplicity of self-convolutions.
- **Statistical mechanics:** representation counts as discrete partition functions; uniqueness as a forbidden low-entropy phase.
- **Formal verification:** certifying nontrivial lower bounds on arithmetic combinatorial counts, not just existence.
- **Complexity theory:** search-to-count transition for NP-style witnesses.

### Application keywords

`Goldbach`, `representation multiplicity`, `prime convolution`, `finite combinatorics`, `native_decide`, `ordered pairs`, `formal additive number theory`

---

## Hypothesis 2: k-ary Parity Census Law

**Visionary claim:** In any prime decomposition, the prime `2` is not an anomaly but a conserved parity carrier. The count of twos is governed exactly by the ambient parity of the target sum and the arity.

### Precise theorem statement

For any prime decomposition
\[
a_1+\cdots+a_k=n,
\]
the number of indices with `a_i = 2` satisfies
\[
\#\{i : a_i = 2\} \equiv n + k \pmod 2.
\]

This is the universal parity census law for additive prime decompositions.

### Suggested Lean 4 type signatures

A list-based version is the right abstraction:
```lean
def countTwos (L : List ℕ) : ℕ := L.count 2

theorem count_twos_parity_of_prime_sum
    (L : List ℕ) (hprime : ∀ x ∈ L, Nat.Prime x) :
    countTwos L % 2 = (L.sum + L.length) % 2
```

A target-sum corollary:
```lean
theorem count_twos_parity_of_prime_decomposition
    (L : List ℕ) (n : ℕ)
    (hprime : ∀ x ∈ L, Nat.Prime x)
    (hsum : L.sum = n) :
    countTwos L % 2 = (n + L.length) % 2
```

Concrete arity-4 version:
```lean
theorem count_twos_parity_4
    (n a b c d : ℕ)
    (ha : Nat.Prime a) (hb : Nat.Prime b)
    (hc : Nat.Prime c) (hd : Nat.Prime d)
    (hsum : a + b + c + d = n) :
    (countTwos [a,b,c,d]) % 2 = (n + 4) % 2
```

### Why this would be a breakthrough

This is a **universal conservation law** across all arities. It does not depend on Goldbach, weak Goldbach, or any conjectural existence theorem. It is a structural theorem about every additive prime decomposition simultaneously. Once formalized, it becomes a foundational invariant for every later decomposition theorem.

### Proof strategy options

**Strategy A: Prime-by-prime local parity decomposition**  
Most promising.
1. Prove for a prime `p` that `p % 2 = if p = 2 then 0 else 1`.
2. Sum over the list and show
   \[
   L.sum \equiv L.length - countTwos(L) \pmod 2.
   \]
3. Rearrange mod 2 to obtain
   \[
   countTwos(L) \equiv L.sum + L.length \pmod 2.
   \]
Why promising: entirely elementary, list-inductive, and reusable.

**Strategy B: Induction on list length**
1. Base case `[]`.
2. For `p :: L`, split on `p = 2`.
3. Track mod-2 changes in both `countTwos` and `sum + length`.  
Why promising: ideal for Lean recursion and list APIs.

**Strategy C: Multiset/Finsupp parity accounting**
1. Push the decomposition into a multiset of prime values.
2. Separate mass at atom `2` from odd-prime support.
3. Use parity of odd support cardinality contribution.  
Why promising: more abstract, better if later moving toward generating functions.

### Cross-domain connections

- **Physics analogy:** count of `2`s as a conserved parity charge.
- **Coding theory:** parity-check law on prime decompositions.
- **Combinatorics on multisets:** exact mod-2 census identity.
- **Probabilistic number theory:** constraint on admissible decomposition ensembles.

### Application keywords

`parity law`, `k-ary decomposition`, `prime 2 census`, `list induction`, `mod 2 invariant`, `conservation law`

---

## Hypothesis 3: Weak Chen Prevalence with Explicit Bounds

**Visionary claim:** The right next layer beyond Goldbach is not merely “prime + semiprime exists,” but a formal bridge between exact primality and controlled almost-primality. This is where additive number theory starts interacting with algorithmic factorization and sieve-like formal structures.

### Precise theorem statement

Define `Semiprime s` to mean `∃ a b, Nat.Prime a ∧ Nat.Prime b ∧ a * b = s`. Define:
```lean
def HasWeakChenDecomposition (n : ℕ) : Prop :=
  ∃ p s : ℕ, Nat.Prime p ∧ (Nat.Prime s ∨ Semiprime s) ∧ p + s = n
```

Primary conjecture:
\[
\forall n \in \mathbb{N},\ 4 \le n \to Even\ n \to HasWeakChenDecomposition\ n.
\]

### Suggested Lean 4 type signature
```lean
def Semiprime (n : ℕ) : Prop :=
  ∃ a b : ℕ, Nat.Prime a ∧ Nat.Prime b ∧ a * b = n

def HasWeakChenDecomposition (n : ℕ) : Prop :=
  ∃ p s : ℕ, Nat.Prime p ∧ (Nat.Prime s ∨ Semiprime s) ∧ p + s = n

theorem weak_chen_decomposition
    (n : ℕ) (hn : 4 ≤ n) (he : Even n) :
    HasWeakChenDecomposition n
```

A bounded-certification milestone:
```lean
theorem weak_chen_decomposition_upto
    (N : ℕ) :
    ∀ n, 4 ≤ n → n ≤ N → Even n → HasWeakChenDecomposition n
```

A stronger prevalence direction:
```lean
def weakChenWitnesses (n : ℕ) : Finset (ℕ × ℕ) := ...

theorem weak_chen_multiplicity_linear_lower_bound
    ∃ C > 0, ∀ n ≥ N0, Even n →
      C * n ≤ (weakChenWitnesses n).card
```
This last one is aspirational and may first appear in `FUTURE_DIRECTIONS.md` rather than as an immediate target.

### Why this would be a breakthrough

Formal additive prime theory currently lives at the brittle exact-prime level. Weak Chen decompositions create a **robust relaxation layer**, analogous to passing from pure states to stable perturbations. This is the natural interface with sieve methods, semiprime complexity, and factorization-aware certified search.

### Proof strategy options

**Strategy A: Certified bounded theorem first, then abstract API**
1. Formalize `Semiprime` and `HasWeakChenDecomposition`.
2. Build an efficient checker for prime-or-semiprime targets.
3. Prove the theorem on a large interval by native computation.  
Why promising: gives immediate mathematically meaningful output and creates infrastructure for later structural work.

**Strategy B: Goldbach reduction when available**
1. If `n = p + q` with both prime, then trivially `HasWeakChenDecomposition n`.
2. Therefore any already-certified Goldbach interval transfers automatically.
3. Extend residual cases by direct weak-Chen search.  
Why promising: maximally exploits catalog theorems.

**Strategy C: Decomposition via small prime subtraction**
1. Try fixed small primes `p ∈ {2,3,5,7,...}`.
2. Show the residual `n-p` is often prime or semiprime by bounded certification.
3. Package this as a deterministic witness-search algorithm.  
Why promising: algorithmically simple and scalable.

### Cross-domain connections

- **Sieve theory:** semiprimes as first almost-prime class.
- **Complexity theory:** primality vs semiprimality as layered certificate complexity.
- **Cryptography:** semiprimes as computationally significant objects.
- **Formal algorithms:** verified decomposition search with mixed predicates.

### Application keywords

`Chen theory`, `semiprime`, `almost prime`, `sieve formalization`, `certified search`, `cryptographic arithmetic`

---

## Hypothesis 4: Ordered/Unordered Representation Transfer Law

**Visionary claim:** Before asymptotics, formal additive number theory needs exact control over how symmetry changes witness counts. This is the representation-theoretic skeleton behind every multiplicity theorem.

### Precise theorem statement

Let `goldbachWitnessesOrdered n` be ordered pairs `(p,q)` and `goldbachWitnessesUnordered n` be canonicalized pairs with `p ≤ q`. Then for every even `n ≥ 4`,
\[
\#\mathrm{ordered}(n)
=
2 \cdot \#\mathrm{unordered\ offdiag}(n)
+
\#\mathrm{diagonal}(n),
\]
where diagonal means pairs `(p,p)` with `2p=n`.

Equivalently,
\[
\#\mathrm{ordered}(n) =
2 \cdot \#\mathrm{unordered}(n) - \mathbf{1}_{\exists p\ \text{prime},\ 2p=n}.
\]

### Suggested Lean 4 type signatures
```lean
def GoldbachDiagonal (n : ℕ) : Prop := ∃ p : ℕ, Nat.Prime p ∧ n = p + p

theorem ordered_unordered_goldbach_count
    (n : ℕ) :
    (goldbachWitnessesOrdered n).card
      = 2 * (goldbachWitnessesUnordered n).card
        - (if GoldbachDiagonal n then 1 else 0)
```

Or in a subtraction-free form:
```lean
theorem ordered_goldbach_count_split
    (n : ℕ) :
    (goldbachWitnessesOrdered n).card
      =
      2 * ((goldbachWitnessesUnordered n).filter fun pq => pq.1 < pq.2).card
      +
      ((goldbachWitnessesUnordered n).filter fun pq => pq.1 = pq.2).card
```

### Why this would be a breakthrough

This is the formal symmetry law needed to move between existential, uniqueness, and multiplicity statements. It turns witness counting into a precise orbit decomposition under the `S₂` action swapping coordinates. Once in place, every later theorem about Goldbach counts becomes cleaner.

### Proof strategy options

**Strategy A: Explicit involution/orbit decomposition**  
Most promising.
1. Define the swap action on ordered witness pairs.
2. Show off-diagonal orbits have size 2 and diagonal orbits have size 1.
3. Count by partition into fixed points and non-fixed orbits.  
Why promising: conceptually perfect and highly reusable.

**Strategy B: Canonicalization map**
1. Map ordered pairs to unordered pairs by sorting.
2. Compute fiber cardinalities: 2 off-diagonal, 1 diagonal.
3. Sum fibers over the codomain.  
Why promising: likely easier if unordered witnesses are already encoded canonically.

**Strategy C: Finset bijection on filtered subsets**
1. Split ordered witnesses into `p < q`, `p = q`, `q < p`.
2. Construct explicit bijection between `<` and `>` parts by swap.
3. Reassemble cardinalities.  
Why promising: elementary and Lean-friendly.

### Cross-domain connections

- **Group actions:** orbit-stabilizer in a finite arithmetic setting.
- **Representation theory:** symmetry classes of additive decompositions.
- **Enumerative combinatorics:** canonicalization and quotient counting.
- **Computer algebra:** exact witness accounting under symmetry reduction.

### Application keywords

`group action`, `swap symmetry`, `orbit counting`, `Goldbach witnesses`, `ordered vs unordered`, `finite set cardinality`

---

## Hypothesis 5: Prime Decomposition Generating Function as a Formal Partition Law

**Visionary claim:** The long-range goal is to internalize additive prime decomposition into formal power series, where witness counts become coefficients and parity laws become algebraic identities. This would open a route from finite witness enumeration to a certified algebra of additive number theory.

### Precise theorem statement

Let
\[
P(X) = \sum_{p\ \mathrm{prime}} X^p
\]
as a formal power series over `ℕ` or `ℤ`. Then the coefficient of `X^n` in `P(X)^k` is exactly the number of ordered `k`-tuples of primes summing to `n`.

### Suggested Lean 4 type signatures

Depending on available Mathlib power series APIs, a finite-truncation theorem may be the right first target:
```lean
def primeSeries : MvPowerSeries Unit ℕ := ...

def orderedPrimeTuples (k n : ℕ) : Finset (Vector ℕ k) := ...

theorem coeff_primeSeries_pow_eq_ordered_prime_tuples
    (k n : ℕ) :
    coeff ℕ n (primeSeries ^ k) = (orderedPrimeTuples k n).card
```

If full infinite series is too heavy, start with finitely supported truncations:
```lean
def primeSeriesTrunc (N : ℕ) : Polynomial ℕ := ...

theorem coeff_primeSeriesTrunc_pow_eq_ordered_prime_tuples_bounded
    (N k n : ℕ) (hn : n ≤ N) :
    (primeSeriesTrunc N ^ k).coeff n =
      ((orderedPrimeTuplesBounded k n N).card)
```

### Why this would be a breakthrough

This reframes additive prime decomposition as **algebraic coefficient extraction**. Once formalized, Goldbach-type counts are no longer isolated combinatorial objects; they become coefficients of a universal prime partition function. This creates a bridge to generatingfunctionology, analytic number theory, and eventually Fourier/circle-method formalization.

### Proof strategy options

**Strategy A: Finite truncation polynomial model**  
Most promising.
1. Define the polynomial whose coefficient at `m` is `1` if `m` is prime and `0` otherwise, up to bound `N`.
2. Expand powers and identify coefficients with ordered bounded prime tuples.
3. Remove the bound under `n ≤ N`.  
Why promising: avoids heavy infinite-series infrastructure and still captures the exact combinatorics.

**Strategy B: Direct induction on `k`**
1. Base case `k = 0,1`.
2. Use convolution identity for coefficients of powers.
3. Match recursive decomposition of ordered tuples by last summand.  
Why promising: algebraically natural and theorem-reusable.

**Strategy C: Finsupp encoding of sparse arithmetic functions**
1. Encode the prime indicator as a finitely supported function on `[0,N]`.
2. Use convolution powers.
3. Interpret coefficient extraction as witness counting.  
Why promising: may integrate better with existing combinatorial APIs.

### Cross-domain connections

- **Statistical mechanics:** prime partition function and energy shells.
- **Signal processing:** convolution powers of sparse indicators.
- **Analytic number theory:** circle-method precursor in formal algebraic dress.
- **Automated reasoning:** coefficient identities as certified counting engines.

### Application keywords

`generating functions`, `formal power series`, `coefficient extraction`, `prime partitions`, `convolution algebra`, `circle method precursor`

---

## Recommended execution order

1. **Prove Hypothesis 2 first**: it is purely structural, unconditional, and gives immediate reusable lemmas.
2. **Prove Hypothesis 4 next**: exact symmetry control will sharpen all multiplicity statements.
3. **Attack Hypothesis 1** using the ordered/unordered transfer law plus diagonal analysis.
4. **Formalize Hypothesis 3 definitions and bounded certification**, even if the full theorem remains conjectural.
5. **Prototype Hypothesis 5 with finite truncation polynomials**, not full infinite power series.

This ordering maximizes theorem reuse and minimizes sorry accumulation.

---

## Lean architecture targets

You should create or refine APIs around:

- `goldbachWitnesses`, `goldbachWitnessesOrdered`, `goldbachWitnessesUnordered`
- `Semiprime`, `HasWeakChenDecomposition`
- `countTwos : List ℕ → ℕ`
- list/multiset parity lemmas for prime-valued entries
- cardinality lemmas under involutions and orbit decomposition
- bounded polynomial/series encodings of prime indicators

The critical design principle is to isolate:
1. **structural arithmetic lemmas**,
2. **finite combinatorial witness machinery**,
3. **bounded certified computation**.

That separation will let later analytic ideas plug in without refactoring.

---

## Scientific significance

If these theorems land, they establish the first coherent **formal additive prime decomposition theory** with:
- exact parity conservation laws,
- symmetry-resolved witness counting,
- semiprime relaxation layers,
- and algebraic generating-function semantics.

That opens at least four new formal research programs:
1. certified additive number theory,
2. formalized sieve-like almost-prime methods,
3. algebraic/combinatorial prime partition theory,
4. computational-experimental theorem discovery inside Lean.

This is not “more Goldbach verification.” It is the construction of a formal language for the thermodynamics of prime sums.

---

## Mandatory deliverable

Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 falsifiable scientific hypotheses** extending the strongest theorem you prove. Each hypothesis must include:
- **Precise statement**
- **Lean-facing formulation sketch**
- **Test**
- **Falsifier**
- **Why it matters**

Good examples:
- a sharp threshold conjecture for multiplicity lower bounds,
- a mod-`m` generalization of the parity census law,
- a semiprime density lower bound on bounded intervals,
- a coefficient-identity extension from primes to almost-primes,
- an orbit-count theorem for higher symmetric-group actions on `k`-ary decompositions.

Be bold: formulate hypotheses that could fail, and whose failure would itself reveal new structure.

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
