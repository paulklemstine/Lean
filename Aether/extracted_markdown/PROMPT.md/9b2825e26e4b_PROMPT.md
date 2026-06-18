
## PHASE A: LEAN 4 ONLY — DOING THE MATH

You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

### DELIVERABLES (strict — only this):
1. **1-3 .lean files in `Catalog/{concept.domain}/<package_name>/`**
2. **3-5 non-trivial theorems with `sorry = 0` (PROVED, not admitted)**
3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
   conjectures as a freeform narrative (NOT a form). Each direction MUST
   include a "The key insight is..." sentence and a "Why now?" justification.
   This file drives the next research cycle — make it count.

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

**Title**: spinVal_proof
**Domain**: Novelty
**Mathematical framing**: Complete the proof of spinVal in Speculative/AutoResearch/IsingPartitionStability.lean.
**Concept description**: Fill the sorry in Speculative/AutoResearch/IsingPartitionStability.lean (2 sorries remaining). Key declarations: spinVal, spinConfigs, spinVal_sq, spinVal_abs, spinConfigs_nonempty. This advances a known open problem in Novelty.
**Novelty estimate**: 0.85
**Breakthrough potential**: 0.9
Research domain: Novelty
Research mode: sorry_fill



### Catalog Context
@Speculative/AutoResearch/IsingPartitionStability.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Stability of Ising Partition Functions Under Noisy Couplings

This file develops a **quantitative robustness theory for Ising partition functions
under coupling perturbations**, building on the Lorentzian polynomial stability
framework from `LorentzianSharpStability.lean` and `LorentzianStability.lean`.

## Mathematical Overview

For an Ising system on `n` spins with couplings `J : Fin n → Fin n → ℝ`, inverse
temperature `β > 0`, and external field `h : Fin n → ℝ`, the partition function is:

  Z_J(h) = ∑_{σ ∈ {±1}^n} exp(β · E(J, h, σ))

where E(J, h, σ) = ∑_i h_i σ_i + ∑_{i,j} J_{ij} σ_i σ_j.

We prove that:
1. The partition function is always strictly positive.
2. The energy changes in a controlled way under coupling perturbations.
3. The log partition function is Lipschitz in the coupling matrix.
4. The Gibbs expectation values are stable under coupling noise.
5. A quadratic covariance form identity connects the Hessian of log Z to
   spin covariances, bridging Lorentzian geometry to statistical physics.

The key insight is that the `1/(β n²)` perturbation scale from Lorentzian
stability theory translates directly into a physically meaningful robustness
scale for thermodynamic observables.

## Main Results

* `isingPartition_pos` — Partition function is strictly positive
* `isingEnergy_diff_bound` — Energy difference bounded by n² · δ under coupling noise
* `isingPartition_ratio_bound` — Multiplicative bound on partition function ratio
* `isingPartition_logLipschitz` — Log partition function is Lipschitz in couplings
* `gibbs_weight_ratio_bound` — Gibbs weights are stable under coupling noise
* `covarianceForm_eq_variance` — Cross-domain covariance identity
* `covarianceForm_nonneg` — Susceptibility positive semidefiniteness
* `certified_robustness_preserves_signature` — Verified robustness certificate

## Application Keywords

Ising model, partition function, log-concavity, Gibbs measure, covariance,
susceptibility, phase transition, noisy couplings, robustness certificate,
Lorentzian polynomial, Hodge theory, free energy stability

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finset BigOperators

noncomputable section

-- ... (truncated, full file has 477 lines)
```


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## Depth Requirements (MANDATORY — WORLD-CLASS STANDARD)

Your output must satisfy ALL of these. This is not incremental work.
This is the frontier. Act accordingly.

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`,
   `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **DEEPEN an existing catalog result** (CORE REQUIREMENT): Your cycle
   must take a STRONG, WELL-ESTABLISHED theorem from the Catalog and
   EXTEND it. Choose ONE of the following:
   (a) **Generalize** the result to a more abstract or broader setting
       (e.g., real numbers → complex, finite groups → topological groups).
   (b) **Strengthen** the conclusion: drop assumptions, sharpen bounds,
       prove a stronger equality where the original was an inequality.
   (c) **Bridge** to another domain: take a result from domain A and
       prove the analog in domain B, showing the deep connection.

   You must produce at least 3 theorems that PROVE non-obvious properties
   of the generalized/strengthened/bridged result. The contribution is
   the structural insight that extends what is already known.

   Think like Cauchy generalizing Euler, or Noether extending Hilbert, or
   Grothendieck's student extending Grothendieck. The contribution is taking
   a known theorem and showing it's the shadow of a deeper truth.

3. **PEGB for every major theorem** (Proof + Example + Generalization + Boundary):
   For each of your top 3-5 theorems, you MUST produce all four:
   - **P**roof: A complete, non-trivial Lean 4 proof
   - **E**xample: A concrete worked example showing the extension
   - **G**eneralization: Why this extension is natural (what's the next level up?)
   - **B**oundary: Where does the extension break down?

4. **Cite your sources**: Your ARTICLE.md and RESEARCH_PAPER.md MUST
   reference the specific catalog results you built upon. Use the
   references provided in the prompt below.

5. **Cross-connection**: At least one theorem should build a BRIDGE
   between the original catalog result and a different mathematical area.
   The deepening should illuminate something broader, not just be an
   isolated exercise.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
