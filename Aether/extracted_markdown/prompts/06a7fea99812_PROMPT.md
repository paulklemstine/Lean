
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.


## Concept

**Title**: The spectral form factor K(τ) = |∑_p exp(2πiτp)|² / N², summed over primes p ≤ N
**Domain**: Shared
**Mathematical framing**: # Future Directions: Prime Resonance Spectroscopy

## 1. Spectral Form Factor Convergence for Prime-Encoded Graphs

The spectral form factor K(τ) = |∑_p exp(2πiτp)|² / N², summed over primes p ≤ N, should exhibit a transition from Poisson statistics (K(τ) → 1) at short correlation scales to a structured non-universal regime at scales comparable to the average prime gap. The key insight is that the Hardy-Littlewood conjecture on prime pair correlations implies K(τ) has a specific non-random correction term involving the singular series, which can be formalized as a deviation from the GUE form factor. Why now? Our `resonance_decomposition` theorem provides the formal infrastructure to separate diagonal from off-diagonal contributions, and the `spectral_rigidity_eq_iff` characterization gives a precise criterion for when the form factor matches the equidistributed (arithmetic progression) baseline.

**Testable conjecture**: For N primes, define K_N(τ) = (1/π(N)²) · resonanceSum(primesUpTo N, exp(2πiτ·)). Then K_N(1/log N) - 1 converges to the Hardy-Littlewood constant C₂ as N → ∞. This can be verified computationally for N up to 10⁸ and formalized using the existing resonanceSum framework.

## 2. Gap Moment Hierarchy and Spectral Universality Breaking

The k-th spectral moment M_k(N) = ∑_{i<π(N)-1} (p_{i+1} - p_i)^k of prime gaps encodes increasingly fine-grained arithmetic structure. For random (Poisson) spectra, M_k grows as k! · (mean gap)^k, but for primes the growth rate should be strictly slower due to the Cramér-Granville conjecture bounding maximal gaps. The key insight is that our spectral rigidity bound n·M₂ ≥ M₁² is the k=2 case of a hierarchy of moment inequalities, and the *ratio* M_k / M₁^k for primes should converge to a value strictly between the Poisson prediction and the rigid (arithmetic progression) prediction, creating a "spectral fingerprint" unique to primes. Why now? The `spectral_rigidity_bound` and `spectral_rigidity_eq_iff` formalized in this cycle provide the base case; extending to k > 2 requires formalizing higher-order Cauchy-Schwarz inequalities (power mean inequalities) which are available in Mathlib.

**Testable conjecture**: M₃(N) / M₁(N)³ → c₃ where c₃ is a computable constant strictly between 1/(π(N)-1)² (rigid bound) and 6 (Poisson prediction). Compute c₃ for N up to 10⁸.

## 3. Resonance Symmetry and Twin Prime Detection

Define the "twin resonance" R₂(N) = offDiagResonance(primesUpTo N, δ₂) where δ₂(x) = 1 if |x| = 2, else 0. Then R₂(N) counts twin prime pairs up to N. The key insight is that the resonance decomposition theorem separates the twin prime counting problem into a spectral measurement problem: R₂(N) = resonanceSum - N·δ₂(0) - (non-twin off-diagonal), and the growth rate of R₂(N) relative to N/log²N is exactly the content of the Hardy-Littlewood twin prime conjecture. Why now? The `resonance_decomposition` and `resonance_decomposition_weighted` theorems provide the formal decomposition framework, and formalizing the conjecture as a precise asymptotic statement about `offDiagResonance` with a specific test function would create the first Lean formalization connecting spectral pair correlations to the twin prime conjecture.

**Testable conjecture**: R₂(N) = 2C₂ · N/log²N · (1 + o(1)) where C₂ is the twin prime constant. This is equivalent to Hardy-Littlewood but stated in resonance-spectroscopic language.

## 4. Spectral Rigidity Gap for Siegel Zeros

If Siegel zeros exist (i.e., L(s, χ) has a real zero very close to s = 1 for some Dirichlet character χ), then the prime distribution in arithmetic progressions mod q exhibits anomalous clustering. The key insight is that this clustering would manifest as a violation of the spectral rigidity bound *restricted to primes in a single residue class*: specifically, for primes p ≡ a (mod q), the ratio n·M₂/M₁² would approach 1 (perfect rigidity / arithmetic progression behavior) much faster than for the full prime sequence, because the Siegel zero forces primes into near-arithmetic-progression patterns within that residue class. Why now? The `spectral_rigidity_eq_iff` theorem provides the exact characterization of when rigidity equality holds (constant gaps = arithmetic progression), so detecting near-equality in residue-restricted prime spectra becomes a formalized diagnostic for Siegel zeros.

**Testable conjecture**: For the primes p ≡ 1 (mod 4) up to N, compute the rigidity ratio R(N) = M₁²/(n·M₂). If R(N) → 1 faster than O(1/log N), this signals anomalous regularity consistent with a Siegel zero for χ₄.

## 5. Quantum Graph Trace Formula and Prime Orbit Correspondence

For a quantum graph with edge lengths ℓ₁, ..., ℓ_E, the trace of the resolvent has poles (resonances) determined by a secular equation involving products exp(ikℓⱼ). When edge lengths are consecutive primes, the trace formula becomes a sum over periodic orbits whose lengths are integer combinations of primes. The key insight is that the gap telescoping identity `gap_telescope` applied to the prime sequence gives ∑(p_{i+1} - p_i) = p_n - 2, which means the *total* orbit-length contribution is controlled by boundary data (the largest prime), but the *distribution* of orbit lengths encodes the full prime gap structure — exactly the content of the off-diagonal resonance. Why now? Formalizing the secular equation det(I - S·D(k)) = 0 for quantum graphs (where S is the scattering matrix and D(k) = diag(exp(ikℓⱼ))) is feasible in Lean using Mathlib's matrix determinant theory, and connecting it to our resonanceSum via the trace formula would create the first formal bridge between quantum graph spectroscopy and prime arithmetic.

**Testable conjecture**: For a star graph with n edges of prime lengths p₁, ..., pₙ, the resonance counting function N(R) = #{resonances with |k| < R} satisfies N(R) = (R/π)·∑pᵢ + O(R^{1-δ}) where δ > 0 depends on the prime gap variance M₂/M₁².

**Concept description**: # Future Directions: Prime Resonance Spectroscopy

## 1. Spectral Form Factor Convergence for Prime-Encoded Graphs

The spectral form factor K(τ) = |∑_p exp(2πiτp)|² / N², summed over primes p ≤ N, should exhibit a transition from Poisson statistics (K(τ) → 1) at short correlation scales to a structured non-universal regime at scales comparable to the average prime gap. The key insight is that the Hardy-Littlewood conjecture on prime pair correlations implies K(τ) has a specific non-random correction term involving the singular series, which can be formalized as a deviation from the GUE form factor. Why now? Our `resonance_decomposition` theorem provides the formal infrastructure to separate diagonal from off-diagonal contributions, and the `spectral_rigidity_eq_iff` characterization gives a precise criterion for when the form factor matches the equidistributed (arithmetic progression) baseline.

**Testable conjecture**: For N primes, define K_N(τ) = (1/π(N)²) · resonanceSum(primesUpTo N, exp(2πiτ·)). Then K_N(1/log N) - 1 converges to the Hardy-Littlewood constant C₂ as N → ∞. This can be verified computationally for N up to 10⁸ and formalized using the existing resonanceSum framework.

## 2. Gap Moment Hierarchy and Spectral Universality Breaking

The k-th spectral moment M_k(N) = ∑_{i<π(N)-1} (p_{i+1} - p_i)^k of prime gaps encodes increasingly fine-grained arithmetic structure. For random (Poisson) spectra, M_k grows as k! · (mean gap)^k, but for primes the growth rate should be strictly slower due to the Cramér-Granville conjecture bounding maximal gaps. The key insight is that our spectral rigidity bound n·M₂ ≥ M₁² is the k=2 case of a hierarchy of moment inequalities, and the *ratio* M_k / M₁^k for primes should converge to a value strictly between the Poisson prediction and the rigid (arithmetic progression) prediction, creating a "spectral fingerprint" unique to primes. Why now? The `spectral_rigidity_bound` and `spectral_rigidity_eq_iff` formalized in this cycle provide the base case; extending to k > 2 requires formalizing higher-order Cauchy-Schwarz inequalities (power mean inequalities) which are available in Mathlib.

**Testable conjecture**: M₃(N) / M₁(N)³ → c₃ where c₃ is a computable constant strictly between 1/(π(N)-1)² (rigid bound) and 6 (Poisson prediction). Compute c₃ for N up to 10⁸.

## 3. Resonance Symmetry and Twin Prime Detection

Define the "twin resonance" R₂(N) = offDiagResonance(primesUpTo N, δ₂) where δ₂(x) = 1 if |x| = 2, else 0. Then R₂(N) counts twin prime pairs up to N. The key insight is that the resonance decomposition theorem separates the twin prime counting problem into a spectral measurement problem: R₂(N) = resonanceSum - N·δ₂(0) - (non-twin off-diagonal), and the growth rate of R₂(N) relative to N/log²N is exactly the content of the Hardy-Littlewood twin prime conjecture. Why now? The `resonance_decomposition` and `resonance_decomposition_weighted` theorems provide the formal decomposition framework, and formalizing the conjecture as a precise asymptotic statement about `offDiagResonance` with a specific test function would create the first Lean formalization connecting spectral pair correlations to the twin prime conjecture.

**Testable conjecture**: R₂(N) = 2C₂ · N/log²N · (1 + o(1)) where C₂ is the twin prime constant. This is equivalent to Hardy-Littlewood but stated in resonance-spectroscopic language.

## 4. Spectral Rigidity Gap for Siegel Zeros

If Siegel zeros exist (i.e., L(s, χ) has a real zero very close to s = 1 for some Dirichlet character χ), then the prime distribution in arithmetic progressions mod q exhibits anomalous clustering. The key insight is that this clustering would manifest as a violation of the spectral rigidity bound *restricted to primes in a single residue class*: specifically, for primes p ≡ a (mod q), the ratio n·M₂/M₁² would approach 1 (perfect rigidity / arithmetic progression behavior) much faster than for the full prime sequence, because the Siegel zero forces primes into near-arithmetic-progression patterns within that residue class. Why now? The `spectral_rigidity_eq_iff` theorem provides the exact characterization of when rigidity equality holds (constant gaps = arithmetic progression), so detecting near-equality in residue-restricted prime spectra becomes a formalized diagnostic for Siegel zeros.

**Testable conjecture**: For the primes p ≡ 1 (mod 4) up to N, compute the rigidity ratio R(N) = M₁²/(n·M₂). If R(N) → 1 faster than O(1/log N), this signals anomalous regularity consistent with a Siegel zero for χ₄.

## 5. Quantum Graph Trace Formula and Prime Orbit Correspondence

For a quantum graph with edge lengths ℓ₁, ..., ℓ_E, the trace of the resolvent has poles (resonances) determined by a secular equation involving products exp(ikℓⱼ). When edge lengths are consecutive primes, the trace formula becomes a sum over periodic orbits whose lengths are integer combinations of primes. The key insight is that the gap telescoping identity `gap_telescope` applied to the prime sequence gives ∑(p_{i+1} - p_i) = p_n - 2, which means the *total* orbit-length contribution is controlled by boundary data (the largest prime), but the *distribution* of orbit lengths encodes the full prime gap structure — exactly the content of the off-diagonal resonance. Why now? Formalizing the secular equation det(I - S·D(k)) = 0 for quantum graphs (where S is the scattering matrix and D(k) = diag(exp(ikℓⱼ))) is feasible in Lean using Mathlib's matrix determinant theory, and connecting it to our resonanceSum via the trace formula would create the first formal bridge between quantum graph spectroscopy and prime arithmetic.

**Testable conjecture**: For a star graph with n edges of prime lengths p₁, ..., pₙ, the resonance counting function N(R) = #{resonances with |k| < R} satisfies N(R) = (R/π)·∑pᵢ + O(R^{1-δ}) where δ > 0 depends on the prime gap variance M₂/M₁².

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Shared
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Research Team Protocol

You are leading a research team. Your team has different roles:
- The **Hypothesizer** generates bold, falsifiable conjectures
- The **Experimenter** proves or disproves them in Lean 4
- The **Analyst** examines what survived, what failed, and WHY
- The **Critic** searches for weaknesses, constructs counterexamples,
  and identifies where proofs might break down. A well-constructed
  counterexample is as valuable as a proof.
- The **Synthesist** upgrades the knowledge base and writes the
  FUTURE_DIRECTIONS.md that seeds the next cycle

You run this loop: **Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate**.
Each cycle is not a one-shot task. It is one iteration of an infinite
research process. Your notes (FUTURE_DIRECTIONS.md, Lab Notebooks,
proof sketches) determine whether the next team builds on your work
or starts over.

**Take good notes.** A cycle without useful notes is a wasted cycle.

### STEP 1: THEOREM DECLARATIONS (required -- before any code)

List every theorem you intend to prove or investigate. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `hypothesis` | `conjecture` | `proved` | `proved_with_lemma_sorry` | `disproved`
- **Why it matters**: One sentence on what this result would mean if true,
  and what it would teach us if false

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective -- proved -- constructive inverse -- confirms decidability of Nat x Nat
2. `cantorPairing_injective`: Cantor pairing is injective -- proved -- diagonal argument -- confirms invertibility
3. `cantorPairing_bijection`: Cantor pairing is a bijection -- proved_with_lemma_sorry -- follows from 1+2 -- completing the characterization

Use `hypothesis` for statements you are not yet sure you can prove but
want to investigate. Use `conjecture` for statements you believe are true
but cannot prove in this cycle. Use `disproved` for statements where you
found a counterexample. Use `proved` for statements with complete Lean
proofs. Use `proved_with_lemma_sorry` when the main proof is complete but
one or more supporting lemmas use `sorry`.

### STEP 2: EXPERIMENT (prove or disprove in Lean 4)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its
status to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it is deferred

**Disproofs count.** If a hypothesis is false, prove its negation or
construct an explicit counterexample. A well-constructed counterexample
is as valuable as a proof. Change the status to `disproved` and state
the counterexample clearly.

### STEP 3: CRITIQUE (find the weaknesses)

For your best theorem, the Critic must:
- Identify the strongest assumption that could be weakened
- Construct a boundary case: where does the result break down?
- If possible, state a `conjecture` for the generalized version and
  explain what would need to change in the proof

This is NOT optional. A theorem without a critique is incomplete.

### STEP 4: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` -- unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures, generalizations, and boundary cases.

### STEP 5: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### STEP 6: TAKE GOOD NOTES (first-class deliverables)

Your notes determine what the next research team investigates. They are NOT
an afterthought. They are your most important output after the proofs themselves.

**6a. Lab Notebook** (in each .lean file, as `-- !-- Lab Notebook -- !--` blocks):

For each major theorem, include a Lab Notebook comment block:
```lean
-- !-- Lab Notebook: cantorPairing_bijection -- !--
-- !-- Hypothesis: Cantor pairing is bijective because both surjective and injective -- !--
-- !-- Result: Proved via composition of surjective and injective proofs -- !--
-- !-- Insight: The constructive inverse of surjectivity is key; diagonal argument handles injectivity -- !--
-- !-- Failure analysis: Initial attempt to prove bijection directly failed; decomposition into surjective+injective was necessary -- !--
-- !-- End Lab Notebook -- !--
```

**6b. FUTURE_DIRECTIONS.md** (structured, not freeform):

Required structure:

## Synthesis
[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary
[For each theorem: name, status (proved/conjecture/disproved), one-sentence
significance. This is the lab notebook summary -- be precise.]

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

### STEP 7: Generalization loop

For your BEST theorem, attempt one level of generalization:
- State a stronger version (can use sorry if proving would take too long)
- Identify the boundary: where does the result break down?
- If the generalization is itself interesting, mark it as a `conjecture`
  in your theorem declarations and explain it in FUTURE_DIRECTIONS.md

### Output format

Your output must include:
1. `.lean` files with proofs and Lab Notebook blocks (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with Synthesis, Results Summary, and 3-5 research
   directions (structured as in Step 6b)

Both are required. A cycle with proofs but no Lab Notebook or
FUTURE_DIRECTIONS.md is a cycle where the next team starts from scratch.
Take good notes.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
