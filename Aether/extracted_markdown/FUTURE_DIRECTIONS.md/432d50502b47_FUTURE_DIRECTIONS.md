# Future Directions: Certified Refutation Layers for Automated Theorem Discovery

## Executive Summary

The present work establishes the foundational layer of **formal metamathematics of automated theorem-discovery pipelines**: finite stress-testing of conjectures is now a mathematically certified operation with soundness, exactness, monotonicity, and extremal witness guarantees. The following directions extend this into a full theory of **adversarial falsification for automated research**.

---

## Direction 1: Optimal Test Design Theorem

**Hypothesis.** For a fixed budget of $k$ test points drawn from a finite domain of size $n$, there exists a characterization of the test set $T^*$ that minimizes the worst-case false-positive count over all conjecture families of bounded VC-dimension.

**Key question.** Given a finite family of $m$ decidable conjectures over a domain of size $n$, and a budget of $k$ test points, what is the minimum achievable false-positive count $\text{FP}^*(k, m, n)$?

**Proof strategy.**
1. Define the *discrimination matrix* $D \in \{0,1\}^{m \times n}$ where $D_{i,j} = 1$ iff conjecture $i$ fails on input $j$.
2. The false-positive count for test set $T$ equals the number of rows of $D$ whose restriction to columns in $T$ is all-zero but whose full row is nonzero.
3. Optimal test design becomes a *set cover* variant: choose $k$ columns to maximize the number of nonzero rows that are "hit."
4. Prove that this is NP-hard in general (reduction from Set Cover), but admits a greedy $(1 - 1/e)$-approximation via submodularity of the "kill count" function.
5. Formalize the submodularity of the kill-count function and the greedy approximation guarantee.

**Cross-domain connections.** This connects to *optimal experimental design* in statistics, *active learning* in ML, and *combinatorial optimization*. The kill-count function's submodularity mirrors influence maximization in social networks.

**Deliverable.** A formalized theorem: `theorem greedy_test_design_approximation ...` proving the greedy algorithm achieves $\geq (1 - 1/e)$ of optimal kill count.

---

## Direction 2: Sample-Complexity Bounds for Conjecture Families

**Hypothesis.** The number of test points needed to reduce the false-positive count below $\varepsilon \cdot |\mathcal{H}|$ (for a family $\mathcal{H}$ of conjectures) is $O(d \log(1/\varepsilon))$ where $d$ is a combinatorial dimension of the conjecture family analogous to VC-dimension.

**Key question.** Define a *refutation dimension* $\text{rdim}(\mathcal{H})$ for a finite conjecture family $\mathcal{H}$ such that $O(\text{rdim}(\mathcal{H}) \cdot \log |\mathcal{H}|)$ test points suffice to eliminate all false conjectures.

**Proof strategy.**
1. Define refutation dimension as the minimum $d$ such that every sub-family of $d+1$ false conjectures shares a common counterexample.
2. Prove that if $\text{rdim}(\mathcal{H}) = d$, then a random test set of size $O(d \log m)$ eliminates all false conjectures with high probability (probabilistic method on finite domains).
3. Alternatively, formalize a deterministic version: if every false conjecture has at least $n/d$ counterexamples, then $d$ well-chosen test points suffice.
4. Connect to the *Helly property* for set families: refutation dimension measures how "Helly-like" the counterexample structure is.

**Cross-domain connections.** VC-dimension theory, PAC learning, Helly's theorem, fractional combinatorics.

**Deliverable.** A formalized theorem relating refutation dimension to test-set size, with concrete bounds for Boolean and arithmetic conjecture families.

---

## Direction 3: Counterexample Hardness Hierarchy

**Hypothesis.** Score-maximizing counterexamples have maximal *elimination power* over conjecture families: a single high-score counterexample refutes more false conjectures than a random counterexample.

**Key question.** Define *elimination power* $\text{EP}(x) = |\{i \in \mathcal{H} : \neg Q_i(x)\}|$ and prove that score-maximizing witnesses (under an appropriate score function) correspond to high-elimination-power witnesses.

**Proof strategy.**
1. Define elimination power as a function $\text{EP} : \alpha \to \mathbb{N}$ counting how many conjectures a point refutes.
2. Prove that if the score function correlates with elimination power (formally: $\text{score}(x) \geq f(\text{EP}(x))$ for monotone $f$), then score-maximal counterexamples have near-maximal elimination power.
3. Formalize a *hardness hierarchy*: partition counterexamples into levels $L_0, L_1, \ldots$ by elimination power, prove that higher levels are smaller (pigeonhole), and that the top level contains the "hardest" counterexamples.
4. Prove a theorem: testing the top-level counterexample achieves the largest single-step reduction in false-positive count.

**Cross-domain connections.** Adversarial examples in ML, influence functions, the Lovász Local Lemma (counterexample independence), proof complexity (hardness of refutation).

**Deliverable.** Formalized theorems `theorem max_score_max_elimination ...` and `theorem hardness_hierarchy_stratification ...`.

---

## Direction 4: Syntax-to-Semantics Bridge with Verified Tactic Reflection

**Hypothesis.** For a restricted proposition language (bounded first-order arithmetic, quantifier-free Boolean, linear inequalities over `Fin n`), the stress-testing framework can be compiled into a verified *tactic* that automatically refutes false conjectures or certifies survival.

**Key question.** Define a syntactic type `Expr` for a restricted proposition language, an interpretation function `⟦·⟧ : Expr → (α → Prop)`, and prove that the computable `findCounterexample?` applied to `⟦e⟧` is sound and complete.

**Proof strategy.**
1. Define `Expr` as an inductive type for quantifier-free Boolean formulas with atoms of the form `f(x) = g(x)` over finite domains.
2. Define `⟦e⟧ : Fin n → Prop` by structural recursion.
3. Prove `DecidablePred ⟦e⟧` by structural induction.
4. Apply `findAnyCounterexample?` to `⟦e⟧` and prove the composite is sound/complete.
5. Implement as a Lean `tactic` using `Lean.Elab.Tactic` that reflects the goal into `Expr`, runs the search, and either produces a counterexample term or applies `stress_test_complete_iff_forall`.

**Cross-domain connections.** Reflection in proof assistants, SMT solving, bounded model checking, the `decide` tactic's implementation.

**Deliverable.** A working `aether_refute` tactic for quantifier-free Boolean formulas with a formal soundness certificate.

---

## Direction 5: End-to-End Pipeline Dominance Theorem

**Hypothesis.** Inserting a certified stress-test layer before proof search *weakly dominates* a proof-attempt-only pipeline in expected resource expenditure over any finite conjecture ensemble.

**Key question.** Model a conjecture pipeline as: generate conjectures → (optionally) stress test → attempt proof. Define cost functions for stress testing and proof search. Prove that the pipeline with stress testing has lower expected cost.

**Proof strategy.**
1. Define a pipeline model with:
   - Conjecture generation cost $c_g$
   - Stress test cost $c_s(|T|)$ (linear in test set size)
   - Proof attempt cost $c_p$ (fixed per conjecture)
   - Success probability: $p_{\text{true}}$ for true conjectures, $0$ for false ones
2. The cost of the naive pipeline: $m \cdot (c_g + c_p)$.
3. The cost of the stress-test pipeline: $m \cdot c_g + m \cdot c_s + \text{survivors} \cdot c_p$.
4. Prove: if $c_s < c_p \cdot \text{FP-fraction}$, the stress-test pipeline strictly dominates.
5. Use `falsePositiveCount_strict_drop` to prove that survivors < total false conjectures.
6. Formalize the expected cost comparison as a theorem over finite ensembles (no probability needed — just counting).

**Cross-domain connections.** Decision theory, optimal stopping, cost-benefit analysis in automated reasoning, the *generate-and-test* paradigm in AI.

**Deliverable.** A formalized theorem `theorem pipeline_dominance ...` proving cost reduction under explicit conditions on $c_s/c_p$ ratio and false-positive fraction.

---

## Meta-Direction: Toward a Complexity Theory of Conjecture Triage

The five directions above converge on a **complexity theory of conjecture triage**: classifying conjectures by their refutation difficulty, characterizing optimal triage strategies, and proving resource bounds for certified conjecture pipelines. This is a new mathematical discipline at the intersection of proof complexity, combinatorial optimization, and formal metamathematics.

Key open problems in this meta-direction:
- **Refutation complexity classes**: Define analogs of P, NP, coNP for conjecture refutability under bounded test sets.
- **Proof-refutation duality**: Formalize the duality between "easy to refute" (small counterexamples) and "hard to prove" (deep theorems).
- **Active conjecture discovery**: Formalize the sequential optimization problem of choosing which conjectures to generate and test next, given a budget.
- **Compositional stress testing**: Prove that stress-testing compositional conjectures (e.g., "A ∧ B") can be decomposed into component tests with quantifiable loss.

---

## Team Directive

Create a research team with the following roles:
1. **Formalization lead**: Maintains the growing certified refutation library, ensures all new theorems compile.
2. **Combinatorics researcher**: Develops the sample-complexity and optimal test design theory (Directions 1–2).
3. **Proof complexity researcher**: Develops the hardness hierarchy and complexity-theoretic aspects (Direction 3).
4. **Tactic engineer**: Implements the syntax-to-semantics bridge and verified tactic (Direction 4).
5. **Systems researcher**: Benchmarks the pipeline on real conjecture ensembles and validates the dominance theorem (Direction 5).

Each team member should:
- Start with concrete `#eval` experiments to validate hypotheses.
- State theorems as `by sorry` skeletons before attempting proofs.
- Use the existing `AetherStressTesting` module as the foundation.
- Cross-reference results across directions (e.g., Direction 2's bounds feed into Direction 5's cost model).
