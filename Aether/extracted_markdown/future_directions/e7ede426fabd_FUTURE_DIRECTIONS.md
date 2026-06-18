# Future Directions: Model-Shrinkage Proof-Complexity Invariant

## Hypothesis 1: Resolution Bounded-Shrinkage Hypothesis

**Conjecture:** Every width-*w* Resolution inference (resolving two clauses to produce a clause of width at most *w*) shrinks the satisfying assignment set by a factor of at most 2^w. Formally, if clause *C* is derived from clauses *C₁* and *C₂* by resolution, then:

    |Mod(Γ ∪ {C})| ≥ |Mod(Γ)| / 2^w

where Γ is the current clause set and *w* = width(C).

**Test:** For n = 6, 8, 10 variables, enumerate all possible width-*w* resolvents of random 3-CNF formulas. For each resolvent, compute the exact model count before and after adding the clause. Check whether the shrinkage ratio |Mod(Γ)|/|Mod(Γ ∪ {C})| ≤ 2^w in all cases.

**Impact:** If true, this would directly connect the bounded-shrinkage lower bound theorem to Resolution proof length, giving:

    Resolution_length(φ → ψ) ≥ shrinkage_distance(φ, ψ) / w

This would provide a new, purely information-theoretic proof of the Ben-Sasson–Wigderson width-length relationship and could potentially extend to stronger bounds for restricted Resolution systems.

---

## Hypothesis 2: Direct-Sum Hypothesis for Semantic Proof Burden

**Conjecture:** For formulas φ₁ on variables {x₁,...,xₘ} and φ₂ on disjoint variables {y₁,...,yₙ}, the minimum derivation length in any bounded-shrinkage proof system satisfies:

    L(φ₁ ∧ φ₂) ≥ L(φ₁) + L(φ₂) − O(1)

where L(φ) denotes the minimum number of steps in a B-bounded shrinkage derivation from the full cube to Mod(φ).

**Test:** For n = 4, 5, 6, enumerate all possible bounded-shrinkage derivation chains for simple constraint pairs (e.g., fixing *k* variables on disjoint blocks). Compute the minimum chain length for the product constraint and compare with the sum of individual minimum lengths.

The deficiency additivity theorem (deficiency_add_of_pow2) provides theoretical support: for power-of-2 model counts, the total deficiency is exactly additive. The question is whether this additive structure persists at the level of derivation length.

**Impact:** A proof would establish that independent proof obligations are genuinely additive in the model-shrinkage framework, ruling out "parallelization tricks" that might shortcut the combined proof. This is the semantic analogue of direct-sum theorems in communication complexity and circuit complexity, and would be a significant structural result.

---

## Hypothesis 3: Codimension-Realization Hypothesis

**Conjecture:** Every exact codimension-*k* affine subcube of {0,1}ⁿ can be reached from the full cube by exactly *k* steps in a 2-bounded shrinkage system (B = 2), and this is optimal: no chain of fewer than *k* steps with B = 2 can reach any codimension-*k* subcube.

**Test:** For n = 4, 5, 6 and each codimension k = 1, ..., n:
1. Verify that the standard derivation (fixing one variable per step) achieves B = 2 in exactly *k* steps.
2. Exhaustively search over all possible B = 2 bounded chains of length < *k* ending at any codimension-*k* subcube.
3. Confirm that no shorter chain exists.

The length_lower_bound_of_bounded_shrink theorem gives k ≥ log₂(2ⁿ/2^{n−k}) = k, so the bound is tight. The question is whether the bound is achieved only by the standard variable-fixing chain or whether alternative chains also achieve it.

**Impact:** If the standard chain is essentially unique (up to variable reordering), this would establish coordinate restriction as the "canonical" atomic operation in bounded-shrinkage systems, analogous to how Gaussian elimination provides canonical operations in linear algebra.

---

## Hypothesis 4: Refutation Hypothesis for the Strong Conjecture

**Conjecture (to be refuted):** There exists a family of formula pairs (φₙ, ψₙ) with ψₙ ⊨ φₙ such that:
- Model-shrinkage distance d(φₙ, ψₙ) grows as Ω(n), but
- Extended Frege proof length for ψₙ given φₙ grows as poly(n).

**Test:** Search among extension-variable constructions. Specifically:
1. Let φₙ be a tautology with 2ⁿ models (e.g., a trivially satisfiable formula on n variables).
2. Let ψₙ be obtained by adding n independent unit clauses on fresh coordinates, giving |Mod(ψₙ)| = 1.
3. Shrinkage distance is exactly n.
4. Check whether Extended Frege can derive ψₙ from φₙ in O(n) steps using extension variables.

If Extended Frege can derive such a chain in O(n) steps (each introducing one extension variable and one unit clause), then each step shrinks by a factor of 2, and the bound k ≥ log₂(2ⁿ) = n is tight. This would *confirm* the conjecture for this family.

To *refute* the strong form, one would need a family where the semantic shrinkage is much larger than what the proof length suggests. Candidate families:
- Formulas where extension variables enable "batch shrinkage" — compressing multiple bits of information loss into a single proof step.
- Formulas with highly structured model sets (e.g., error-correcting codes) where algebraic structure allows shortcuts.

**Impact:** A refutation would identify a sharp separation between semantic information loss and syntactic proof cost, showing that model-shrinkage alone cannot characterize proof complexity. A confirmation would strengthen the case for the conjectured invariance principle.

---

## Hypothesis 5: Entropy-Barrier Hypothesis

**Conjecture:** Any proof system P satisfying a *local data-processing inequality* — meaning each inference step can reduce the model-set entropy by at most C bits, for some system-dependent constant C — automatically admits semantic lower bounds:

    proof_length_P(φ → ψ) ≥ (def(ψ) − def(φ)) / C

**Test:** Formalize the notion of "local data-processing inequality" for toy proof systems:
1. Define a proof system where each step adds one clause of bounded width w (Resolution-like).
2. Verify that each step reduces ⌊log₂ |Mod|⌋ by at most w (this is the bounded-shrinkage hypothesis for Resolution).
3. Apply the length lower bound theorem to derive the entropy-barrier bound.
4. Compare with known Resolution lower bounds for specific formula families (pigeonhole principle, random k-CNF).

Extend to:
- Bounded-depth Frege: each step is a bounded-depth formula, bounding shrinkage by 2^{poly(n^{1/d})}.
- Cutting Planes: each step is a linear inequality, bounding shrinkage by the geometric properties of the feasible polytope.

**Impact:** If the entropy-barrier hypothesis holds for multiple proof systems, it would unify diverse proof-complexity lower bound techniques under a single information-theoretic umbrella. The deficiency would serve as a universal proof-complexity measure, analogous to how entropy serves as a universal information measure across coding theory, statistical mechanics, and machine learning.

---

## Summary of Testable Predictions

| # | Hypothesis | Predicted outcome | Key test | Falsifiable by |
|---|-----------|-------------------|----------|----------------|
| 1 | Resolution bounded-shrinkage | Shrinkage ≤ 2^w per step | Exact model counting for small n | Finding a width-w resolvent with shrinkage > 2^w |
| 2 | Direct-sum | L(φ₁∧φ₂) ≥ L(φ₁)+L(φ₂)−O(1) | Brute-force chain search | Finding a product derivation shorter than sum |
| 3 | Codimension-realization | Exactly k steps needed for codim-k | Exhaustive search for short chains | Finding a chain of length < k |
| 4 | Strong conjecture refutation | Shrinkage ≫ proof length for some family | Extension-variable constructions | Proving shrinkage always bounds proof length |
| 5 | Entropy barrier | def(ψ)−def(φ) / C bounds proof length | Formalize for Resolution, Frege | Finding a system violating local DPI but with short proofs |
