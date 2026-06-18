
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

**Title**: The current formalization proves existence of a QBER threshold Q* via the interm
**Domain**: Novelty
**Mathematical framing**: # Future Directions: BB84 QKD Security Formalization

## 1. Continuous Monotonicity and Exact QBER Threshold Computation

The current formalization proves existence of a QBER threshold Q* via the intermediate value theorem but does not pin down its exact value. A natural next step is to prove that binEntropy₂ is strictly increasing on [0, 1/2] and strictly decreasing on [1/2, 1], which would give uniqueness of Q*. Combined with numerical bounds on log, one could prove 0.110 < Q* < 0.111, formalizing the well-known ≈11% threshold.

The key insight is that strict monotonicity of h₂ on [0, 1/2] follows from the strict concavity of binEntropy, which in turn follows from the strict convexity of x ↦ x log x (whose second derivative is 1/x > 0).

Why now? Mathlib already has `Real.binEntropy_nonneg` and `Real.binEntropy_le_log_two`. The concavity/convexity infrastructure for `Real.log` is well-developed (`Real.strictConvexOn_mul_log`), so the strict monotonicity proof is within reach.

## 2. Finite-Key Security Bounds

The current key rate theorem is asymptotic: r = 1 - 2h₂(Q) applies in the limit n → ∞. Real implementations use finite key lengths, where the key rate must account for statistical fluctuations in parameter estimation. The finite-key formula involves tail bounds (Serfling's inequality or Azuma-Hoeffding) and produces a key rate r_n ≈ 1 - 2h₂(Q + δ(n)) - O(1/√n) where δ(n) is the statistical confidence interval.

The key insight is that formalizing the finite-key correction separates into three independent components: (1) a concentration inequality for hypergeometric sampling, (2) the smooth min-entropy chain rule, and (3) the finite-size privacy amplification bound. Each is a self-contained mathematical result.

Why now? Mathlib has strong measure-theoretic probability foundations and many concentration inequalities. The modular structure means each component can be formalized independently and composed.

## 3. Entanglement-Based QKD and the CSS Code Reduction

The Shor-Preskill proof reduces BB84 security to the security of an entanglement-based protocol via CSS (Calderbank-Shor-Steane) error-correcting codes. Formalizing this reduction would connect our information-theoretic results to the quantum-mechanical security guarantee. The reduction shows that if a CSS code can correct t errors, then BB84 with QBER ≤ t/n is secure.

The key insight is that the CSS code reduction is primarily algebraic (over GF(2)) rather than quantum-mechanical. The quantum part reduces to the statement that measuring in conjugate bases commutes with CSS encoding — which can be stated as a linear-algebraic fact over F₂.

Why now? Mathlib has extensive support for linear algebra over finite fields (`ZMod 2`), making the algebraic core of the CSS reduction formalizable without quantum mechanics infrastructure.

## 4. Composable Security and the Universal Composability Framework

Our current security definition is stand-alone: it bounds Eve's information about a single key. Modern QKD security proofs use the universal composability (UC) framework, where security means the real protocol is indistinguishable from an ideal key-generation functionality. The composable security bound involves trace distance between quantum states, generalizing our classical statistical distance.

The key insight is that composable security follows from the stand-alone bound plus a "lifting lemma" showing that statistical distance in the classical post-processing is preserved under composition. This lifting lemma is a purely classical result about statistical distance and can be formalized using our `statDistance_triangle`.

Why now? The `statDistance` metric space structure we formalized provides the foundation. The lifting lemma is a direct consequence of the triangle inequality and data processing inequality for statistical distance.

## 5. Privacy Amplification Against Quantum Adversaries

Our privacy amplification result treats the security parameter classically. Against quantum adversaries, the leftover hash lemma requires quantum min-entropy (conditional on Eve's quantum side information). The quantum leftover hash lemma states: if ρ_AE has conditional min-entropy H_min(A|E) ≥ k, then hashing A to l bits leaves Eve with trace distance ≤ 2^{-(k-l)/2} from uniform.

The key insight is that the quantum leftover hash lemma's proof reduces to a bound on the operator norm of ρ_AE, which can be stated as: Tr(ρ_AE²) ≤ 2^{-k}. This "collision entropy" characterization is a finite-dimensional matrix inequality that could be formalized using Mathlib's matrix analysis.

Why now? Mathlib's `Matrix` library includes trace, operator norms, and positive semidefiniteness. The key inequality is a consequence of the Cauchy-Schwarz inequality for the Hilbert-Schmidt inner product, which is available in Mathlib.

**Concept description**: # Future Directions: BB84 QKD Security Formalization

## 1. Continuous Monotonicity and Exact QBER Threshold Computation

The current formalization proves existence of a QBER threshold Q* via the intermediate value theorem but does not pin down its exact value. A natural next step is to prove that binEntropy₂ is strictly increasing on [0, 1/2] and strictly decreasing on [1/2, 1], which would give uniqueness of Q*. Combined with numerical bounds on log, one could prove 0.110 < Q* < 0.111, formalizing the well-known ≈11% threshold.

The key insight is that strict monotonicity of h₂ on [0, 1/2] follows from the strict concavity of binEntropy, which in turn follows from the strict convexity of x ↦ x log x (whose second derivative is 1/x > 0).

Why now? Mathlib already has `Real.binEntropy_nonneg` and `Real.binEntropy_le_log_two`. The concavity/convexity infrastructure for `Real.log` is well-developed (`Real.strictConvexOn_mul_log`), so the strict monotonicity proof is within reach.

## 2. Finite-Key Security Bounds

The current key rate theorem is asymptotic: r = 1 - 2h₂(Q) applies in the limit n → ∞. Real implementations use finite key lengths, where the key rate must account for statistical fluctuations in parameter estimation. The finite-key formula involves tail bounds (Serfling's inequality or Azuma-Hoeffding) and produces a key rate r_n ≈ 1 - 2h₂(Q + δ(n)) - O(1/√n) where δ(n) is the statistical confidence interval.

The key insight is that formalizing the finite-key correction separates into three independent components: (1) a concentration inequality for hypergeometric sampling, (2) the smooth min-entropy chain rule, and (3) the finite-size privacy amplification bound. Each is a self-contained mathematical result.

Why now? Mathlib has strong measure-theoretic probability foundations and many concentration inequalities. The modular structure means each component can be formalized independently and composed.

## 3. Entanglement-Based QKD and the CSS Code Reduction

The Shor-Preskill proof reduces BB84 security to the security of an entanglement-based protocol via CSS (Calderbank-Shor-Steane) error-correcting codes. Formalizing this reduction would connect our information-theoretic results to the quantum-mechanical security guarantee. The reduction shows that if a CSS code can correct t errors, then BB84 with QBER ≤ t/n is secure.

The key insight is that the CSS code reduction is primarily algebraic (over GF(2)) rather than quantum-mechanical. The quantum part reduces to the statement that measuring in conjugate bases commutes with CSS encoding — which can be stated as a linear-algebraic fact over F₂.

Why now? Mathlib has extensive support for linear algebra over finite fields (`ZMod 2`), making the algebraic core of the CSS reduction formalizable without quantum mechanics infrastructure.

## 4. Composable Security and the Universal Composability Framework

Our current security definition is stand-alone: it bounds Eve's information about a single key. Modern QKD security proofs use the universal composability (UC) framework, where security means the real protocol is indistinguishable from an ideal key-generation functionality. The composable security bound involves trace distance between quantum states, generalizing our classical statistical distance.

The key insight is that composable security follows from the stand-alone bound plus a "lifting lemma" showing that statistical distance in the classical post-processing is preserved under composition. This lifting lemma is a purely classical result about statistical distance and can be formalized using our `statDistance_triangle`.

Why now? The `statDistance` metric space structure we formalized provides the foundation. The lifting lemma is a direct consequence of the triangle inequality and data processing inequality for statistical distance.

## 5. Privacy Amplification Against Quantum Adversaries

Our privacy amplification result treats the security parameter classically. Against quantum adversaries, the leftover hash lemma requires quantum min-entropy (conditional on Eve's quantum side information). The quantum leftover hash lemma states: if ρ_AE has conditional min-entropy H_min(A|E) ≥ k, then hashing A to l bits leaves Eve with trace distance ≤ 2^{-(k-l)/2} from uniform.

The key insight is that the quantum leftover hash lemma's proof reduces to a bound on the operator norm of ρ_AE, which can be stated as: Tr(ρ_AE²) ≤ 2^{-k}. This "collision entropy" characterization is a finite-dimensional matrix inequality that could be formalized using Mathlib's matrix analysis.

Why now? Mathlib's `Matrix` library includes trace, operator norms, and positive semidefiniteness. The key inequality is a consequence of the Cauchy-Schwarz inequality for the Hilbert-Schmidt inner product, which is available in Mathlib.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
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

**6b. FUTURE_DIRECTIONS.md** (MANDATORY — your output WILL BE REJECTED if missing):

You MUST produce a FUTURE_DIRECTIONS.md file with this EXACT structure.
Copy the section headers below verbatim. Do NOT use freeform prose.

## Synthesis

[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary

[For EACH theorem: name, status (proved/conjecture/disproved), one-sentence
significance. Format as a bullet list:]

- `theoremName`: status — one-sentence significance

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

IMPORTANT: The ## Synthesis and ## Results Summary sections are NOT optional.
If your FUTURE_DIRECTIONS.md is missing either section, it will be treated as
incomplete and the next research team will have no context to build on your work.

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
