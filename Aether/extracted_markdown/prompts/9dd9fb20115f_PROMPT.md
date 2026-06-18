## Assignment: This document identifies five falsifiable scientific hypotheses arising from

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

### Research Direction
# Future Directions: Formal Additive Prime Decomposition Theory

This document identifies five falsifiable scientific hypotheses arising from
our formalization of Goldbach-type additive prime decompositions. Each
conjecture is precise enough to confirm or refute computationally or
proof-theoretically. But the real opportunity is larger: use additive prime
decomposition as a formally verified bridge between analytic number theory,
finite convolution algebra, parity forcing, and certified computation in Lean 4.

The immediate target is not merely to verify more examples. It is to extract
structural theorems from the existing Goldbach infrastructure that begin to
look like a formal additive theory of the prime indicator function. The
breakthrough would be to turn witness enumeration into theorem-producing
machinery: parity rigidity theorems, monotonicity or lower-bound phenomena,
weak Chen decomposability, and convolution-growth statements that connect
proof assistants to experimental analytic number theory.

Application keywords: **formal number theory, additive combinatorics, prime convolution, certified computation, decidable witness extraction, parity rigidity, semiprime decomposition, analytic heuristics, verified asymptotics, theorem-guided search**

---

## Hypothesis 1: Goldbach Count Lower Bound

**Conjecture.** For every even integer \(n \geq 8\), the ordered Goldbach
representation count satisfies \(r_2(n) \geq 2\).

Equivalently: every even \(n \ge 8\) has at least two ordered prime pairs
\((p,q)\) with \(p+q=n\). This isolates \(4=2+2\) and \(6=3+3\) as the only
even numbers with unique ordered Goldbach representation.

### Precise theorem target

If the catalog already contains `goldbachCount : ℕ → ℕ` and a predicate
expressing Goldbach decompositions, aim for a theorem of the following form:

```lean
theorem goldbachCount_ge_two_of_even_ge_eight
    (n : ℕ) (hne : 8 ≤ n) (heven : Even n) :
    2 ≤ goldbachCount n
```

A stronger and more structural version would be:

```lean
theorem exists_two_distinct_ordered_goldbach_witnesses
    (n : ℕ) (hne : 8 ≤ n) (heven : Even n) :
    ∃ p₁ q₁ p₂ q₂ : ℕ,
      Nat.Prime p₁ ∧ Nat.Prime q₁ ∧
      Nat.Prime p₂ ∧ Nat.Prime q₂ ∧
      p₁ + q₁ = n ∧ p₂ + q₂ = n ∧
      (p₁, q₁) ≠ (p₂, q₂)
```

If the exact global theorem is too ambitious, prove a certified finite-range
version first:

```lean
theorem goldbachCount_ge_two_of_even_ge_eight_up_to
    (B : ℕ) :
    ∀ n, 8 ≤ n → n ≤ B → Even n → 2 ≤ goldbachCount n
```

with `native_decide` closing explicit instances for large \(B\).

### Why this would be a breakthrough

This is not just a stronger Goldbach witness theorem. It upgrades existence
into **multiplicity rigidity**. In additive combinatorics language, it says
the prime self-convolution never attains its minimal nontrivial value beyond
the exceptional low-energy regime \(n=4,6\). Formally verified, this would be
one of the first examples where a proof assistant certifies a nontrivial
global lower-bound phenomenon for an arithmetic convolution arising from
primes.

### Proof strategy architecture

**Strategy A: symmetry + diagonal exclusion + existing existence theorem**
1. Use the existing Goldbach existence theorem to obtain one pair \((p,q)\).
2. Use the proved parity theorem `goldbach_pair_even_gt_four_both_odd` to show
   all witnesses for \(n>4\) are odd, excluding \(2\).
3. Show that if \(p \neq q\), then \((q,p)\) is a second distinct ordered
   witness; if \(p=q\), then \(n=2p\), and prove for \(n \ge 8\) there exists
   another non-diagonal witness or reduce this to finite computation on the
   diagonal cases.

This is promising because it converts the theorem into a structural statement
about ordered vs unordered representations and uses parity machinery already
proved.

**Strategy B: direct certified computation plus theorem extraction**
1. Define a decidable predicate for “exactly one ordered Goldbach witness.”
2. Compute and certify nonexistence of such \(n\) on a large interval.
3. Combine this with any catalog theorem giving existence for all even \(n\ge4\),
   or with a verified finite-cover theorem if the current formalization is
   computationally bounded.

This is the best route if the current library already has strong witness
enumeration and `native_decide` infrastructure.

**Strategy C: convolutional reformulation**
1. Define the prime indicator \(1_{\mathbb P}\) and its additive convolution.
2. Show `goldbachCount n` equals the convolution value
   \((1_{\mathbb P} * 1_{\mathbb P})(n)\).
3. Prove lower bounds by structural properties of the support and symmetry.

This is the most visionary approach because it opens a path to formal analytic
number theory, but it may require the most infrastructure.

### Cross-domain connections

- **Additive combinatorics:** representation functions and sumset multiplicity.
- **Signal processing:** `goldbachCount` as a discrete autocorrelation of the
  prime indicator.
- **Statistical mechanics:** low-count exceptional states \(4,6\) as boundary
  defects, with bulk redundancy emerging for larger energy levels.
- **Formal methods:** theorem extraction from certified exhaustive search.

### How to test

Compute `goldbachCount n` for all even \(n\in[8,B]\) for increasing \(B\),
starting with \(B=10^4\), then \(10^5\), and package the result as a reusable
certified theorem.

### Falsifier

An even \(n \ge 8\) with `goldbachCount n < 2`.

---

## Hypothesis 2: Weak Chen Prevalence

**Conjecture.** Every even integer \(n \geq 4\) admits a weak Chen
decomposition: \(n = p + s\) where \(p\) is prime and \(s\) is either prime or
semiprime.

This is the universal finite version of the “prime + almost-prime” paradigm.
The key formal advance is to make semiprimality computationally and
theorem-theoretically tractable in Lean.

### Precise theorem target

First define semiprimality:

```lean
def IsSemiprime (n : ℕ) : Prop :=
  ∃ a b : ℕ, Nat.Prime a ∧ Nat.Prime b ∧ a * b = n
```

Then define the decomposition predicate:

```lean
def HasWeakChenDecomposition (n : ℕ) : Prop :=
  ∃ p s : ℕ, Nat.Prime p ∧ (Nat.Prime s ∨ IsSemiprime s) ∧ p + s = n
```

Main target:

```lean
theorem weakChen_of_even_ge_four
    (n : ℕ) (hge : 4 ≤ n) (heven : Even n) :
    HasWeakChenDecomposition n
```

If the universal theorem is beyond current infrastructure, prove:

```lean
theorem weakChen_of_even_ge_four_up_to
    (B : ℕ) :
    ∀ n, 4 ≤ n → n ≤ B → Even n → HasWeakChenDecomposition n
```

with large certified bounds.

### Why this would be a breakthrough

This formalizes a shadow of Chen’s theorem inside Lean, but with a crucially
different flavor: not asymptotic, but explicit, decidable, and witness-bearing.
A verified library for weak Chen decompositions would create a new foundation
for formal additive sieve theory. It also gives a realistic path toward
hybrid theorem/computation results that are scientifically meaningful even
before a full formalization of classical analytic proofs.

### Proof strategy architecture

**Strategy A: reduce to Goldbach when possible**
1. Observe that every Goldbach decomposition is automatically a weak Chen
   decomposition because “prime” is allowed on the \(s\)-side.
2. Use existing Goldbach theorems for all even \(n\) already covered.
3. Only the gap between current Goldbach coverage and universal weak Chen needs
   independent semiprime search.

This is strongest if the catalog already proves broad Goldbach existence.

**Strategy B: decidable search over \(p\), semiprime witness extraction**
1. Build a decidable predicate for `IsSemiprime`.
2. Search over \(p < n\) prime and test whether \(n-p\) is prime or semiprime.
3. Package the search as an existence theorem over finite intervals via
   `native_decide`.

This is likely the fastest way to obtain substantial new certified results.

**Strategy C: multiplicative-additive factor interface**
1. Develop lemmas showing small even numbers have trivial weak Chen witnesses.
2. For larger even \(n\), use modular restrictions and parity to reduce the
   search space.
3. Prove a bounded-complexity witness theorem: there exists a witness with
   \(p \le n-4\) and \(s\neq1\), excluding degenerate cases cleanly.

This strategy is attractive because it begins building a reusable formal sieve
interface.

### Cross-domain connections

- **Sieve theory:** formal approximation to prime + almost-prime decompositions.
- **Computational complexity:** decidability and witness extraction for mixed
  additive/multiplicative predicates.
- **Program verification:** semiprime recognition as a certified factorization
  subroutine.
- **Cryptography:** semiprimes are central objects; this creates formal bridges
  between arithmetic structure and decomposition algorithms.

### How to test

Extend the `HasWeakChenDecomposition` decidability infrastructure and verify
computationally up to large bounds. Compare witness statistics against the pure
Goldbach counts.

### Falsifier

An explicit even \(n \ge 4\) with no prime + (prime-or-semiprime)
decomposition.

---

## Hypothesis 3: Parity Regularity of Ternary Witnesses

**Conjecture.** For every odd \(n > 5\), any prime triple \((a,b,c)\) with
\(a+b+c=n\) contains **exactly one** occurrence of the prime \(2\).

This is the natural ternary analogue of the already proved binary parity
rigidity theorem `goldbach_pair_even_gt_four_both_odd`. It is stronger than
the informal “at most one \(2\)” statement: because the sum of three odd
primes is odd, one of the three primes must be even, hence must be \(2\).

### Precise theorem target

Define ternary decomposition:

```lean
def IsPrimeTripleSum (n a b c : ℕ) : Prop :=
  Nat.Prime a ∧ Nat.Prime b ∧ Nat.Prime c ∧ a + b + c = n
```

Then prove:

```lean
theorem prime_triple_sum_odd_gt_five_exactly_one_two
    {n a b c : ℕ}
    (hn : 5 < n)
    (hodd : ¬ Even n)
    (h : IsPrimeTripleSum n a b c) :
    ((a = 2 ∧ b ≠ 2 ∧ c ≠ 2) ∨
     (b = 2 ∧ a ≠ 2 ∧ c ≠ 2) ∨
     (c = 2 ∧ a ≠ 2 ∧ b ≠ 2))
```

A cleaner counting formulation:

```lean
theorem prime_triple_sum_odd_gt_five_num_twos_eq_one
    {n a b c : ℕ}
    (hn : 5 < n)
    (hodd : ¬ Even n)
    (ha : Nat.Prime a) (hb : Nat.Prime b) (hc : Nat.Prime c)
    (hsum : a + b + c = n) :
    ((if a = 2 then 1 else 0) +
     (if b = 2 then 1 else 0) +
     (if c = 2 then 1 else 0)) = 1
```

### Why this would be a breakthrough

This would be the first genuinely structural theorem in a formal ternary prime
decomposition theory. It converts witness existence into a classification law.
Once formalized, it becomes a template for parity-forcing in higher additive
decompositions, and it suggests a hierarchy: binary even sums force zero twos;
ternary odd sums force exactly one two; \(k\)-ary decompositions should admit
systematic parity census laws.

### Proof strategy architecture

**Strategy A: parity counting argument**
1. Use `Nat.Prime.eq_two_or_odd` (or prove an equivalent lemma if needed) for
   each of \(a,b,c\).
2. Exclude the case of zero twos because odd+odd+odd is odd? Wait carefully:
   that actually equals odd, so zero twos is possible unless all three are odd.
   The key is that all odd primes are odd, so zero twos indeed gives an odd
   sum. Therefore the “exactly one two” claim is false in full generality.
3. This means the correct theorem is weaker: **at most one** of \(a,b,c\) can
   be \(2\), not exactly one.

This reveals an important correction: \(3+5+7=15\) is an odd sum of three odd
primes with no \(2\). So the right theorem is a parity exclusion theorem, not
an exact census theorem.

**Corrected theorem target**

```lean
theorem prime_triple_sum_odd_gt_five_at_most_one_two
    {n a b c : ℕ}
    (hn : 5 < n)
    (hodd : ¬ Even n)
    (ha : Nat.Prime a) (hb : Nat.Prime b) (hc : Nat.Prime c)
    (hsum : a + b + c = n) :
    ¬ ((a = 2 ∧ b = 2) ∨ (a = 2 ∧ c = 2) ∨ (b = 2 ∧ c = 2))
```

**Strategy B: contradiction by parity**
1. Assume two of \(a,b,c\) are \(2\).
2. Then their sum contributes \(4\), and the remaining prime contributes either
   \(2\) or an odd number.
3. Hence the total sum is even, contradicting `¬ Even n`.

This is the cleanest and most robust proof.

**Strategy C: modular strengthening**
1. Prove the stronger statement modulo \(2\): the number of odd prime summands
   must have the same parity as \(n\).
2. Specialize to ternary sums of an odd target.
3. Deduce constraints on the number of occurrences of \(2\).

This is the most reusable strategy for higher-arity generalization.

### Cross-domain connections

- **Boolean Fourier analysis:** parity constraints as mod-2 conservation laws.
- **Constraint solving:** additive prime decompositions as SAT-like parity
  systems with arithmetic atoms.
- **Homological flavor:** parity as an invariant surviving under witness
  permutations.

### How to test

Formalize ternary decomposition predicates and search for odd \(n\) with
triples containing two twos. Exhaustive search should immediately support the
theorem and catch any mistaken stronger conjecture.

### Falsifier

A ternary decomposition of an odd \(n > 5\) where two of the three primes are
\(2\). This should be impossible.

---

## Hypothesis 4: Convolution Growth Heuristic

**Conjecture.** The average Goldbach count over even integers up to \(B\),
\[
\bar r_2(B) = \frac{1}{\lfloor B/2 \rfloor}\sum_{\substack{n \le B \\ \text{\(n\) even}}} r_2(n),
\]
is eventually nondecreasing in \(B\), and in particular satisfies a certified
finite-growth theorem on explicit intervals.

The scientifically meaningful formal target is not immediate asymptotics but a
verified monotonicity or lower-growth statement for computable windows.

### Precise theorem target

A finite-window theorem:

```lean
def evenAverageGoldbachCount (B : ℕ) : Rat := sorry
```

Then aim for:

```lean
theorem evenAverageGoldbachCount_mono_on_interval
    {B₁ B₂ : ℕ} (h0 : 8 ≤ B₁) (h1 : B₁ ≤ B₂) (hB : B₂ ≤ 10000) :
    evenAverageGoldbachCount B₁ ≤ evenAverageGoldbachCount B₂
```

Or a denominator-cleared natural-number formulation avoiding `Rat` overhead:

```lean
theorem goldbachCount_partial_sum_growth
    {B₁ B₂ : ℕ} (h0 : 8 ≤ B₁) (h1 : B₁ ≤ B₂) (hB : B₂ ≤ 10000) :
    (B₂ / 2) * (∑ n in Finset.Icc 1 (B₁ / 2), goldbachCount (2*n)) ≤
    (B₁ / 2) * (∑ n in Finset.Icc 1 (B₂ / 2), goldbachCount (2*n))
```

A more structural theorem, if convolution infrastructure is built:

```lean
theorem goldbachCount_eq_prime_indicator_add_convolution
    (n : ℕ) :
    goldbachCount n =
      ∑ x in Finset.range (n + 1),
        (if Nat.Prime x then 1 else 0) *
        (if Nat.Prime (n - x) then 1 else 0)
```

### Why this would be a breakthrough

This is the gateway from witness enumeration to formal analytic heuristics.
Once `goldbachCount` is recognized as a discrete convolution, the entire
language of average order, spectral heuristics, and additive energy becomes
available. Even finite certified monotonicity results would be a prototype for
machine-checked experimental mathematics in additive number theory.

### Proof strategy architecture

**Strategy A: exact convolution identity first**
1. Prove that `goldbachCount` is literally the self-convolution of the prime
   indicator on \(\mathbb N\).
2. Rewrite averages as normalized partial sums of this convolution.
3. Use this identity to derive finite-window monotonicity computationally.

This is the most important foundational step.

**Strategy B: cumulative witness injection**
1. Compare witness sets for neighboring even numbers.
2. Construct injections or lower-bound maps from witnesses of smaller numbers
   into larger windows.
3. Use coarse lower bounds rather than exact asymptotics.

This is more combinatorial and may avoid heavy summation infrastructure.

**Strategy C: FFT-inspired certified computation**
1. Use array-based prime indicator lists.
2. Compute finite convolutions efficiently.
3. Prove the resulting values agree with `goldbachCount`, then certify window
   inequalities.

This is ideal if performance becomes the bottleneck.

### Cross-domain connections

- **Harmonic analysis:** prime indicator convolution.
- **Data science:** moving averages and empirical growth trends.
- **Theoretical computer science:** verified fast convolution algorithms.
- **Experimental mathematics:** machine-certified heuristic discovery.

### How to test

Compute the average Goldbach count on increasing even windows and certify
monotonicity over explicit ranges. Compare the growth curve with classical
Hardy–Littlewood heuristics.

### Falsifier

A pair \(B_1 \le B_2\) in the tested range with
\(\bar r_2(B_2) < \bar r_2(B_1)\).

---

## Hypothesis 5: Stability of Goldbach Witnesses Under Small Perturbation

**Conjecture.** For sufficiently many even integers \(n\), a Goldbach witness
for \(n\) can be locally transported to a witness for \(n+2\) by adjusting one
prime summand by a small amount. The formalizable version should begin as a
bounded-gap witness-transfer theorem on explicit finite ranges.

This is deliberately bolder: it asks whether witness structure exhibits local
coherence rather than isolated existence.

### Precise theorem target

A finite-range existential transport statement:

```lean
def HasNearbyGoldbachTransfer (n K : ℕ) : Prop :=
  ∃ p q p' q' : ℕ,
    Nat.Prime p ∧ Nat.Prime q ∧
    Nat.Prime p' ∧ Nat.Prime q' ∧
    p + q = n ∧ p' + q' = n + 2 ∧
    |(Int.ofNat p' - Int.ofNat p)| ≤ K ∧
    |(Int.ofNat q' - Int.ofNat q)| ≤ K
```

Then certify:

```lean
theorem nearby_goldbach_transfer_up_to
    (K B : ℕ) :
    ∀ n, 8 ≤ n → n + 2 ≤ B → Even n →
      HasNearbyGoldbachTransfer n K
```

for explicit constants \(K,B\) discovered experimentally.

A weaker but realistic theorem is density-based:

```lean
theorem many_even_numbers_have_nearby_goldbach_transfer_up_to
    (K B : ℕ) :
    ∃ S : Finset ℕ,
      (∀ n ∈ S, 8 ≤ n ∧ n + 2 ≤ B ∧ Even n ∧ HasNearbyGoldbachTransfer n K) ∧
      -- lower bound on density of S among even numbers up to B
      ...
```

### Why this would be a breakthrough

This reframes Goldbach theory dynamically. Instead of asking whether each even
number has a decomposition, ask whether decompositions vary continuously across
the even lattice. That is a new formal object: a **Goldbach witness graph** on
even integers, with edges representing controlled witness transport. Such a
graph could support notions of expansion, clustering, and stability that are
invisible in isolated existential statements.

### Proof strategy architecture

**Strategy A: computational discovery then theorem packaging**
1. Enumerate Goldbach witnesses for consecutive even numbers.
2. Search for a small universal \(K\) on finite intervals.
3. Prove the result for the discovered \(K\) using certified computation.

This is the best first attack.

**Strategy B: fix one prime and vary the complement**
1. For a witness \(n=p+q\), inspect whether \(q+2\) or \(p+2\) remains prime.
2. Use prime-gap data heuristics to motivate a finite certified theorem.
3. Where direct transport fails, allow witness replacement but bounded total
   displacement.

This offers a conceptual route but may not globalize.

**Strategy C: witness graph connectivity**
1. Define the bipartite graph of even \(n\) and their Goldbach pairs.
2. Add transport edges between nearby pairs.
3. Prove local connectivity properties computationally and extract a theorem.

This is the most visionary and may open an entirely new subfield.

### Cross-domain connections

- **Dynamical systems:** witness evolution across parameter shifts.
- **Graph theory:** connectivity and expansion in decomposition graphs.
- **Topological data analysis:** persistence of witness structures under
  perturbation.
- **Physics:** local stability of microstates under energy increments.

### How to test

Compute witnesses for all even \(n \le B\), estimate the smallest \(K\) giving
local transfer on a large fraction of cases, then formalize the exact finite
statement actually supported by data.

### Falsifier

An explicit even \(n\) in the tested range for which no witness of \(n\) can be
matched to any witness of \(n+2\) within the claimed bound \(K\).

---

## Immediate theorem priorities

1. **Prove the corrected ternary parity theorem** (`at_most_one_two`) with no
   sorry or minimal sorry. This is low-cost and structurally important.
2. **Define `IsSemiprime` and `HasWeakChenDecomposition`** and obtain a
   decidability pipeline.
3. **Prove a convolution identity for `goldbachCount`** if the current
   implementation permits it.
4. **Package finite certified bounds** (`up_to 10^4`, then higher) as reusable
   theorems, not just ad hoc computations.
5. **Investigate whether Hypothesis 1 can be proved structurally** using
   ordered-pair symmetry plus finite diagonal analysis.

---

## Lean 4 formalization guidance

Exploit:
- existing prime parity lemmas such as “prime is two or odd,”
- existing theorem `goldbach_pair_even_gt_four_both_odd`,
- decidable finite search over bounded intervals,
- `Finset`-based witness enumeration,
- `native_decide` for explicit finite certification,
- denominator-clearing to avoid unnecessary `Rat` proof overhead.

When introducing new definitions, favor predicates that are:
- computable,
- extensional,
- easy to rewrite,
- compatible with witness extraction theorems.

---

## Required deliverable: FUTURE_DIRECTIONS.md

Produce a structured `FUTURE_DIRECTIONS.md` containing **3–5 testable scientific hypotheses**, each with:
1. a precise conjecture,
2. why it matters,
3. how to test it in Lean or by certified computation,
4. a clear falsifier.

At least:
- one hypothesis must concern **convolution/algebraic structure** of prime
  decomposition counts,
- one must concern **parity or modular rigidity** in higher-arity
  decompositions,
- one must concern **weak Chen or semiprime-enhanced decomposition**.

Be bold, but every conjecture must be falsifiable and executable as science.

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
