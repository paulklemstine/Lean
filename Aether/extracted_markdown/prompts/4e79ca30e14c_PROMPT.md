## Assignment: Proof-Theoretic Symbolic Dynamics Beyond Rationality

We have already crossed the threshold from combinatorial folklore to machine-certified structure: walk-counting by matrix powers, trace formulas for closed walks, Cayley–Hamilton trace recurrences, transfer-matrix recurrences for nearest-neighbor CA, and linear-constraint unfolding for additive CA over finite fields are now formalized in Lean 4 with zero `sorry`. Do not merely extend these results. Use them as the launch platform for a new synthesis: **symbolic dynamics as proof theory over finite algebraic objects**, where automata complexity, recurrence structure, and finite-field dynamics become formally interoperable.

Your task is to prove genuinely new theorems that expose hidden rigidity in cellular automata spacetime languages and periodic-point statistics.

---

# Mode: prove / discover

You should aim for at least one theorem in each of the two directions below, with Lean statements precise enough to guide implementation. If one conjecture fails, pivot immediately to a counterexample theorem with exact obstruction.

---

# Direction A: Aperiodicity and Star-Freeness of Permutative CA Spacetime Languages

## Breakthrough theorem target

The foundational conjecture is not just that certain CA column languages are regular, but that **permutativity collapses their logical complexity all the way down to FO[<]**. If true, this would be a structural theorem placing a large dynamical class of CA inside the lowest nontrivial fragment of regular language complexity.

### Precise theorem statement

Let `α` be a finite alphabet, let `f : α → α → α` be a nearest-neighbor local rule, and let `h : ℕ+` be a strip height. Suppose `f` is right-permutative in the sense that for each fixed left input `a`, the map `b ↦ f a b` is a bijection. Let `spacetimeColumnLanguage f h : Language (Vector α h)` be the language of vertical columns appearing in valid height-`h` spacetime strips of the CA.

**Primary target theorem**:
For every finite alphabet `α`, every right-permutative nearest-neighbor rule `f`, and every `h ≥ 1`, the language `spacetimeColumnLanguage f h` is star-free.

A stronger algebraic form, more suitable for Lean if star-free infrastructure is incomplete:

> The syntactic monoid of `spacetimeColumnLanguage f h` is aperiodic.

### Lean 4 type signature sketch

You will likely need to define or reuse:
- `RightPermutative (f : α → α → α) : Prop`
- `spacetimeColumnLanguage (f : α → α → α) (h : ℕ) : Language (Fin h → α)`
- `AperiodicMonoid (M : Type*) [Monoid M] : Prop := ∀ m : M, ∃ k : ℕ, m^(k+1) = m^k`

Then the theorem should look morally like:

```lean
theorem syntacticMonoid_aperiodic_of_rightPermutative
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α → α) (h : ℕ)
    (hh : 1 ≤ h)
    (hf : RightPermutative f) :
    AperiodicMonoid (SyntacticMonoid (spacetimeColumnLanguage f h)) := by
```

and, if language-theoretic infrastructure exists or can be built:

```lean
theorem spacetimeColumnLanguage_starFree_of_rightPermutative
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α → α) (h : ℕ)
    (hh : 1 ≤ h)
    (hf : RightPermutative f) :
    StarFree (spacetimeColumnLanguage f h) := by
```

If full syntactic monoid formalization is too expensive, prove a DFA-level surrogate:

```lean
theorem minimalDFA_counterfree_of_rightPermutative
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α → α) (h : ℕ)
    (hh : 1 ≤ h)
    (hf : RightPermutative f) :
    Counterfree (minimalDFA (spacetimeColumnLanguage f h)) := by
```

This would still be revolutionary, because McNaughton–Papert–Schützenberger then gives star-freeness.

## Why this would be a breakthrough

This would connect:
- **symbolic dynamics**: spacetime constraints of CA,
- **finite semigroup theory**: aperiodic syntactic monoids,
- **logic in computer science**: FO[<]-definability,
- **proof theory**: formal certification of low logical complexity for dynamical traces.

It would say that a broad class of locally invertible dynamics generates globally regular but logically weak observational languages. That is a surprising rigidity principle. It would also suggest that certain dynamical prediction tasks for permutative CA live below full regular-language complexity.

## Proof strategy architecture

### Strategy A: Residual-state collapse via right-permutative propagation
Most promising.

1. **Construct the recognition automaton explicitly**  
   Use the transfer-matrix / strip-compatibility formalization already in the catalog to define a DFA/NFA whose states encode admissible boundary data for height-`h` columns.

2. **Exploit right-permutativity to prove eventual idempotence of transition effects**  
   Show that reading a word acts on boundary states by a map whose uncertainty only decreases: because the right coordinate is uniquely recoverable from predecessor data, repeated application of the same transition profile cannot generate nontrivial cycles in the transition monoid.

3. **Promote stabilization to aperiodicity**  
   Prove that every transition monoid element stabilizes after bounded exponent, yielding counter-freeness / aperiodicity.

Why promising: it leverages the existing transfer formalism directly and avoids building abstract semigroup machinery from scratch.

### Strategy B: Forbidden-pattern logic and FO[<] definability
Potentially elegant if automata logic support is manageable.

1. Characterize admissible columns by a local propagation condition along time.
2. Use right-permutativity to eliminate existential branching in the witness configuration.
3. Derive an FO[<] sentence over column positions describing membership.

If successful, star-freeness follows conceptually. But formalizing FO[<] and its equivalence to aperiodicity may be heavier than the semigroup route.

### Strategy C: De Bruijn graph + group obstruction exclusion
A useful intermediate route.

1. Build the de Bruijn / transfer graph for strip evolution.
2. Show right-permutativity forbids permutation subactions on strongly connected components of the minimal recognizer.
3. Deduce absence of nontrivial groups in the transition monoid.

This may be easier to mechanize than full syntactic monoids and still gives strong algebraic content.

## Cross-domain connections

- **Semigroup complexity theory**: Schützenberger’s aperiodicity criterion.
- **Descriptive complexity**: FO[<] vs regular languages.
- **Reversible / permutative dynamics**: local invertibility does not imply global logical complexity.
- **Proof-theoretic automata**: certified low-complexity recognizers for dynamical traces.
- **Program verification**: counter-free automata often admit stronger decision procedures.

## Application keywords

`symbolic dynamics`, `cellular automata`, `syntactic monoid`, `aperiodic monoid`, `star-free language`, `FO[<]`, `counter-free automata`, `descriptive complexity`, `finite semigroup theory`, `formal verification`

---

# Direction B: Cyclotomic/Eventual Periodicity Law for Additive CA Fixed-Point Counts

## Breakthrough theorem target

The current formalization gives linear constraints and recurrence phenomena. The next leap is to prove that **periodic-point counts of additive CA are governed by finite-field spectral arithmetic**, with eventual periods controlled by cyclotomic data of the local polynomial. This would be a precise bridge from symbolic dynamics to arithmetic geometry over finite fields.

Let `T_n` be the additive CA induced on cyclic words of length `n` over `GF(p)` by a local Laurent polynomial
\[
P(U)=aU^{-1}+b+cU.
\]
For fixed iterate `m`, define
\[
F_m(n)=\log_p |\mathrm{Fix}(T_n^m)|.
\]

The conjectural theorem is that `F_m` is eventually periodic in `n`, with period bounded by arithmetic data coming from roots of `P`.

## Precise theorem statement

A clean formalizable version may be:

> Let `𝔽 = GF(p)` and let `P ∈ 𝔽[U,U⁻¹]` define an additive nearest-neighbor CA on cyclic configurations of size `n`. Fix `m ≥ 1`. Then there exist `N, q : ℕ` such that for all `n ≥ N`,
> \[
> F_m(n+q)=F_m(n).
> \]
> Moreover, `q` divides the least common multiple of multiplicative orders of those algebraic numbers `ζ` in finite extensions of `𝔽` for which `P(ζ)^m=1`.

A weaker but still major theorem, probably more Lean-accessible:

> `n ↦ |Fix(T_n^m)|` satisfies a linear recurrence with values in `ℕ`, and after applying `log_p`, the resulting sequence is eventually periodic.

An algebraic reformulation likely best suited for proof:

\[
|Fix(T_n^m)| = p^{\deg \gcd(X^n-1, Q_m(X))}
\]
for a suitable polynomial `Q_m`, hence eventual periodicity reduces to periodicity of `deg gcd(X^n-1, Q_m(X))`.

### Lean 4 type signature sketch

Assuming an additive CA object and a theorem identifying fixed points with kernel dimension of a circulant operator:

```lean
theorem eventual_periodic_log_card_fix_additiveCA
    (p : ℕ) [Fact p.Prime]
    (a b c : ZMod p) (m : ℕ) :
    ∃ N q : ℕ, 0 < q ∧
      ∀ n ≥ N,
        logCardFix (additiveCA a b c) m (n + q) =
        logCardFix (additiveCA a b c) m n := by
```

A stronger arithmetic version:

```lean
theorem period_dvd_lcm_rootOrders_of_additiveCA
    (p : ℕ) [Fact p.Prime]
    (a b c : ZMod p) (m : ℕ) :
    ∃ q : ℕ, 0 < q ∧
      q ∣ rootOrderLcm (localPoly a b c) m ∧
      ∃ N : ℕ, ∀ n ≥ N,
        logCardFix (additiveCA a b c) m (n + q) =
        logCardFix (additiveCA a b c) m n := by
```

An even more structural intermediate theorem:

```lean
theorem card_fix_eq_p_pow_gcd_degree
    (p : ℕ) [Fact p.Prime]
    (P : LaurentPolynomial (ZMod p)) (m n : ℕ) :
    cardFix (additiveCAOfLaurent P) m n =
      p ^ natDegree (Polynomial.gcd (X^n - 1) (annihilatorPoly P m)) := by
```

This intermediate theorem may be the real gateway result.

## Why this would be a breakthrough

This would establish that periodic-point statistics of additive CA are not just recursively describable but **arithmetically spectral**. The dependence on `n` would be controlled by root orders in finite extensions, placing CA periodic orbit counts in direct conversation with:
- cyclotomic factorization,
- rationality phenomena in zeta functions,
- finite-field harmonic analysis,
- arithmetic dynamics.

This is the kind of theorem that changes how one thinks about spacetime counting: from combinatorics of constraints to arithmetic of eigenvalues.

## Proof strategy architecture

### Strategy A: Polynomial module / circulant operator reduction
Most promising.

1. **Identify cyclic configurations with `𝔽_p[X]/(X^n-1)`**  
   Formalize the additive CA action as multiplication by a Laurent polynomial `P(X)` modulo `X^n-1`.

2. **Express fixed points of `T_n^m` as kernel of multiplication by `P(X)^m - 1`**  
   Then
   \[
   \dim \ker = \deg \gcd(X^n-1, P(X)^m-1)
   \]
   or a close Laurent-polynomial variant after clearing denominators.

3. **Reduce eventual periodicity to root-order arithmetic**  
   Over a splitting field, `deg gcd(X^n-1,Q(X))` counts roots of `Q` whose multiplicative order divides `n`. This count is eventually periodic, with period dividing the lcm of those root orders.

This route is conceptually sharp and aligns with existing algebra in Mathlib.

### Strategy B: Rational generating functions + Skolem–Mahler–Lech flavor
Ambitious and beautiful.

1. Use existing transfer-matrix recurrence to prove that `|Fix(T_n^m)|` or its logarithm satisfies a linear recurrence.
2. Show the eigenvalues are roots of unity times powers of `p` in the additive case.
3. Deduce eventual periodicity from the root-of-unity decomposition.

This could reveal a general mechanism beyond nearest-neighbor additive rules, but it may be harder to formalize directly.

### Strategy C: Smith normal form of circulant matrices
Concrete and computational.

1. Represent `T_n^m - I` as a circulant matrix over `GF(p)`.
2. Compute nullity via invariant factors / gcd with `X^n-1`.
3. Extract periodicity from factorization patterns.

This route may mesh well with matrix formalizations already present from the walk/trace side.

## Cross-domain connections

- **Arithmetic dynamics**: periodic point counts controlled by algebraic spectra.
- **Finite-field Fourier analysis**: CA diagonalization on multiplicative characters.
- **Coding theory**: cyclic codes and gcd dimensions in `𝔽_p[X]/(X^n-1)`.
- **Dynamical zeta functions**: periodic orbit enumeration and rationality.
- **Linear systems / signal processing**: circulant operators and spectral kernels.

## Application keywords

`additive cellular automata`, `finite fields`, `cyclotomic orders`, `periodic points`, `circulant matrices`, `cyclic codes`, `dynamical zeta functions`, `arithmetic dynamics`, `Laurent polynomials`, `eventual periodicity`

---

# High-value intermediate lemmas to target first

These are likely the real engines. Prove them cleanly and the flagship theorems become reachable.

## For Direction A

```lean
theorem rightPermutative_unique_backward_extension
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α → α) (hf : RightPermutative f) :
    ∀ a c, ∃! b, f a b = c := by
```

```lean
theorem spacetimeColumnLanguage_regular
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α → α) (h : ℕ) :
    Regular (spacetimeColumnLanguage f h) := by
```

```lean
theorem transition_action_eventually_idempotent
    {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α → α) (h : ℕ)
    (hf : RightPermutative f) :
    ∀ τ in transitionMonoid (spacetimeColumnAutomaton f h),
      ∃ k, τ^(k+1) = τ^k := by
```

## For Direction B

```lean
theorem additiveCA_on_cycle_eq_mul_mod_Xn_sub_one
    (p : ℕ) [Fact p.Prime]
    (a b c : ZMod p) (n : ℕ) :
    cycleMap (additiveCA a b c) n =
      mulByLaurentMod (localPoly a b c) (X^n - 1) := by
```

```lean
theorem fix_submodule_dim_eq_gcd_degree
    (p : ℕ) [Fact p.Prime]
    (Q : Polynomial (ZMod p)) (n : ℕ) :
    finrank (fixSubmoduleMulMod Q (X^n - 1)) =
      natDegree (Polynomial.gcd (X^n - 1) Q) := by
```

```lean
theorem gcd_degree_eventually_periodic
    (p : ℕ) [Fact p.Prime]
    (Q : Polynomial (ZMod p)) :
    ∃ N q : ℕ, 0 < q ∧
      ∀ n ≥ N,
        natDegree (Polynomial.gcd (X^(n+q) - 1) Q) =
        natDegree (Polynomial.gcd (X^n - 1) Q) := by
```

That last lemma is independently important and may become a reusable Mathlib contribution.

---

# What to build explicitly from catalog theorems

Do not ignore the existing formal corpus. Build on it aggressively.

1. **From walk-counting and trace formulas**  
   The transfer matrix already converts combinatorial strip counts into algebraic invariants. Reuse this infrastructure to define recognizers and count fixed strips.

2. **From Cayley–Hamilton trace recurrence**  
   Any transfer-derived sequence is recurrence-controlled. Use this as a fallback route when exact arithmetic classification is difficult.

3. **From CA transfer matrix linear recurrence**  
   This is the bridge from local rule to globally constrained column language. For Direction A, it gives the automaton/transfer object. For Direction B, it gives recurrence and zeta-rationality scaffolding.

4. **From additive CA transfer relation**  
   This is the seed for the module-theoretic reinterpretation. Upgrade “linear constraints” to “kernel of polynomial multiplication modulo `X^n-1`”.

---

# Risk management: if the conjectures fail

If full aperiodicity for all right-permutative rules is false, prove one of these instead:

- every right-permutative binary radius-1 rule has aperiodic column language for heights `h ≤ 5`;
- left/right-permutative **additive** rules have aperiodic column languages;
- the transition monoid is `J`-trivial or group-free under an additional expansiveness hypothesis.

If full cyclotomic divisibility fails, identify the exact obstruction:

- repeated roots / inseparability in characteristic `p`,
- denominator-clearing effects for Laurent polynomials,
- dependence on nilpotent Jordan blocks rather than pure root orders.

A sharp counterexample with formal proof is scientifically valuable.

---

# Deliverables

1. At least one flagship theorem formalized with zero `sorry`, preferably one from each direction.
2. Any necessary supporting definitions around syntactic monoids, transition monoids, cyclic additive CA, or polynomial-action models.
3. A brief note in comments/docstrings explaining how the theorem uses the previously verified transfer/trace infrastructure.
4. A structured `FUTURE_DIRECTIONS.md` containing **3–5 falsifiable scientific hypotheses**, each with:
   - precise conjecture,
   - why it matters,
   - explicit test protocol,
   - what would count as refutation.

---

# Required FUTURE_DIRECTIONS hypotheses

Your `FUTURE_DIRECTIONS.md` must not be vague. Include hypotheses of the following kind:

1. **Height-uniform aperiodicity bound**  
   Conjecture a uniform exponent bound `k = k(|α|, h)` such that every transition monoid element for a right-permutative rule satisfies `m^(k+1)=m^k`.  
   Test: exhaustive computation for binary radius-1 rules and small heights.

2. **Exact period formula for additive CA**  
   Conjecture that the eventual period of `n ↦ log_p |Fix(T_n^m)|` equals, not just divides, the lcm of multiplicative orders of simple roots of `P(U)^m-1`.  
   Test: compare computed periods against factorization data over extension fields.

3. **Zeta/logical complexity correspondence**  
   Conjecture that star-freeness of the spacetime column language implies a pole-structure restriction on the strip-counting zeta function.  
   Test: compute transfer-matrix spectra for examples with known automata complexity.

4. **Proof-theoretic collapse for additive permutative CA**  
   Conjecture that additive right-permutative CA admit quantifier-rank bounds for FO[<] definitions of column languages growing linearly in height.  
   Test: synthesize formulas from automata and measure quantifier rank.

5. **Semigroup/arithmetic duality**  
   Conjecture that aperiodicity of spacetime language and eventual periodicity of fixed-point logarithms are two shadows of a common nilpotent–cyclotomic decomposition of the transfer operator.  
   Test: identify canonical decomposition in formally verified examples.

Go after the theorem that makes an expert stop and say: *this should not have been formalized this early, and yet now the whole landscape looks different*.

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
