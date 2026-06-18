# EML Transcendence Theory: Algebraic Independence and Conditional Transcendence via Schanuel's Conjecture

## Abstract

We develop the transcendence theory of EML (exp-minus-log) numbers — real numbers built from rationals using the operation eml(x, y) = exp(x) − log(y) together with field operations, exponentiation, and logarithms. Our main contributions are threefold:

1. **Algebraic Independence Propagation**: We prove that if two real numbers are algebraically independent over ℚ, then their difference, sum, and product are transcendental. The proof introduces a polynomial lifting-and-retraction technique that embeds univariate polynomials into multivariate polynomial rings and exploits the injectivity of the evaluation map.

2. **Conditional Transcendence from Schanuel**: We show that Schanuel's conjecture implies the algebraic independence of (e, log 2) and (e, e^e), and consequently that the EML numbers eml(1,2) = e − log 2 and exp(exp(1)) = e^e are transcendental.

3. **EML Closure Structure**: We define EML-constructible numbers as an inductive class and prove closure under field operations, exp, log, and the EML operation itself.

All results are fully formalized in Lean 4 with Mathlib, with no axioms beyond the standard foundational axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

### 1.1 Background

Schanuel's conjecture, formulated in the 1960s, is one of the most powerful open conjectures in transcendence theory. It states:

**Conjecture (Schanuel).** If z₁, ..., zₙ ∈ ℂ are linearly independent over ℚ, then the transcendence degree of ℚ(z₁, ..., zₙ, e^{z₁}, ..., e^{zₙ}) over ℚ is at least n.

This conjecture implies virtually all known transcendence results (Hermite-Lindemann, Gelfond-Schneider) and many open ones (algebraic independence of e and π, transcendence of e^e).

### 1.2 The EML Operation

We define the EML function as:

$$\text{eml}(x, y) = \exp(x) - \log(y)$$

This operation naturally combines the two fundamental transcendental functions. The class of **EML-constructible numbers** consists of all reals obtainable from rationals by iterated application of eml, exp, log, and field operations (+, −, ×, ÷).

### 1.3 Our Contributions

We establish a systematic framework for proving transcendence of EML numbers conditional on Schanuel's conjecture. The key innovation is the **polynomial lifting technique**, which reduces transcendence questions about combinations (a − b, a + b, a × b) to algebraic independence questions about pairs {a, b}.

## 2. Definitions

### 2.1 Schanuel's Conjecture (Real Version)

We work with the following formulation, specialized to real numbers:

**Definition 2.1** (RealSchanuelConjecture). For all n ∈ ℕ and z : Fin n → ℝ, if z is ℚ-linearly independent, then there exists an injection e : Fin n ↪ Fin n ⊕ Fin n such that the family (Sum.elim z (exp ∘ z)) ∘ e is algebraically independent over ℚ.

This states that among the 2n values {z₁, ..., zₙ, e^{z₁}, ..., e^{zₙ}}, at least n are algebraically independent.

### 2.2 EML Expression Trees

**Definition 2.2** (EMLExpr). An EML expression is defined inductively:
- rat(q) for q ∈ ℚ
- exp(e), log(e) for subexpressions e
- add(e₁, e₂), sub(e₁, e₂), mul(e₁, e₂), div(e₁, e₂)
- emlOp(e₁, e₂) ≡ exp(e₁) − log(e₂)

**Definition 2.3** (Depth). The depth of an EML expression counts the maximal nesting of exp/log:
- depth(rat(q)) = 0
- depth(exp(e)) = depth(log(e)) = depth(e) + 1
- depth(binop(e₁, e₂)) = max(depth(e₁), depth(e₂))
- depth(emlOp(e₁, e₂)) = max(depth(e₁) + 1, depth(e₂) + 1)

## 3. Main Results

### 3.1 Polynomial Lifting and Retraction

**Definition 3.1.** The *subtraction lift* liftSubPoly : ℚ[X] →+* MvPolynomial(Fin 2, ℚ) is the ring homomorphism sending X ↦ X₀ − X₁:

$$\text{liftSubPoly}(p) = p(X_0 - X_1)$$

**Definition 3.2.** The *retraction* retractPoly : MvPolynomial(Fin 2, ℚ) →ₐ[ℚ] ℚ[X] sends X₀ ↦ X and X₁ ↦ 0.

**Theorem 3.1** (retract_comp_lift_eq_id). The retraction is a left inverse of the lift:

$$\text{retractPoly} \circ \text{liftSubPoly} = \text{id}_{\mathbb{Q}[X]}$$

*Proof.* Both sides are ring homomorphisms from ℚ[X]; they agree on the generators C(r) and X, hence are equal. □

**Corollary 3.2** (liftSubPoly_injective). liftSubPoly is injective.

**Theorem 3.3** (aeval_liftSubPoly). For p ∈ ℚ[X] and a, b ∈ ℝ:

$$\text{aeval}_{[a,b]}(\text{liftSubPoly}(p)) = \text{aeval}_{a-b}(p)$$

*Proof.* Both sides are ring homomorphisms in p agreeing on generators. □

### 3.2 Algebraic Independence Implies Transcendence of Combinations

**Theorem 3.4** (algIndep_pair_sub_transcendental). If {a, b} ⊂ ℝ is algebraically independent over ℚ, then a − b is transcendental over ℚ.

*Proof sketch.* Suppose a − b is algebraic. Then ∃ nonzero p ∈ ℚ[X] with aeval(a−b, p) = 0. By Theorem 3.3, aeval([a,b], liftSubPoly(p)) = 0. By algebraic independence, liftSubPoly(p) = 0. By Corollary 3.2, p = 0. Contradiction. □

**Theorem 3.5** (algIndep_pair_add_transcendental). Same result for a + b.

**Theorem 3.6** (algIndep_pair_mul_transcendental). Same result for a · b.

**PEGB Analysis for Theorem 3.4:**
- **P**roof: Complete Lean 4 proof using the lifting technique.
- **E**xample: {e, log 2} algebraically independent ⟹ e − log 2 transcendental. The value e − log 2 ≈ 2.025 cannot satisfy any polynomial over ℚ.
- **G**eneralization: The technique extends to any polynomial combination p(a, b) where p is a nonzero element of ℚ[X, Y]. In fact, if {a, b} is algebraically independent, then for ANY nonzero p ∈ ℚ[X, Y], the value p(a, b) is transcendental. Our proof specializes to p = X − Y, X + Y, X · Y.
- **B**oundary: The result breaks for trivial combinations: if p is constant (p ∈ ℚ), then p(a, b) ∈ ℚ is algebraic regardless of independence. Also, algebraic independence of {a, b} is strictly stronger than both being transcendental — e.g., e and e + 1 are both transcendental but not algebraically independent.

### 3.3 Schanuel Implies Algebraic Independence

**Theorem 3.7** (schanuel_e_log2_algIndep). Under RealSchanuelConjecture, {e, log 2} is algebraically independent over ℚ.

*Proof sketch.* Apply Schanuel with z = (1, log 2). First establish ℚ-linear independence: if a + b · log 2 = 0 with a, b ∈ ℚ, then log 2 = −a/b ∈ ℚ. But log 2 is irrational (if log 2 = p/q, then e^(p/q) = 2, so e^p = 2^q. Under Schanuel with z = (p), e^p is transcendental, contradicting 2^q ∈ ℚ).

The combined tuple is (1, log 2, e, 2). The algebraically independent pair cannot include 1 or 2 (algebraic values). Careful case analysis of all possible embeddings Fin 2 ↪ Fin 2 ⊕ Fin 2 shows the only valid pair is {e, log 2} or {log 2, e}. □

**PEGB Analysis for Theorem 3.7:**
- **P**roof: Complete Lean 4 proof with explicit embedding analysis.
- **E**xample: e ≈ 2.718 and log 2 ≈ 0.693 satisfy no polynomial P(x, y) ∈ ℚ[x, y] with P(e, log 2) = 0.
- **G**eneralization: The same technique works for any pair (exp(α), log(β)) where α is algebraic, β is rational, and {α, log β} is ℚ-linearly independent.
- **B**oundary: Fails when the z-values are ℚ-linearly dependent (e.g., z = (1, 2) gives log dependence).

**Theorem 3.8** (schanuel_e_expexp_algIndep). Under RealSchanuelConjecture, {e, e^e} is algebraically independent over ℚ.

*Proof sketch.* Apply Schanuel with z = (1, e). ℚ-linear independence follows from irrationality of e (which in turn follows from Schanuel with n = 1). The combined tuple (1, e, e, e^e) has the subtlety that e appears twice (as z₂ and e^{z₁}). Case analysis eliminates all embeddings except those selecting {e, e^e}. □

### 3.4 Conditional Transcendence of EML Numbers

**Theorem 3.9** (schanuel_eml_one_two_transcendental). Under RealSchanuelConjecture:

$$\text{eml}(1, 2) = e - \log 2 \text{ is transcendental over } \mathbb{Q}.$$

*Proof.* Combine Theorem 3.7 and Theorem 3.4. □

**PEGB Analysis:**
- **P**roof: One-line composition of two non-trivial results.
- **E**xample: eml(1, 2) ≈ 2.025 is not a root of any polynomial with rational coefficients.
- **G**eneralization: For any nonzero algebraic α and rational β > 0 with {α, log β} ℚ-linearly independent, the EML value exp(α) − log(β) is transcendental under Schanuel.
- **B**oundary: When β = 1, eml(x, 1) = exp(x), reducing to the Hermite-Lindemann case.

**Theorem 3.10** (schanuel_exp_exp_one_transcendental). Under RealSchanuelConjecture, e^e is transcendental.

**Theorem 3.11** (schanuel_exp_exp_add_log2_transcendental). Under algebraic independence of {e^e, log 2}, the number e^e + log 2 is transcendental.

### 3.5 EML Transcendence Propagation

**Theorem 3.12** (eml_transcendence_propagation). If {exp(x), log(y)} is algebraically independent, then eml(x, y) is transcendental.

This is the fundamental bridge result: algebraic independence of the component functions guarantees transcendence of the EML output.

### 3.6 Depth-1 Transcendence

**Theorem 3.13** (depth_one_transcendental_exp). Under RealSchanuelConjecture, exp(q) is transcendental for any nonzero q ∈ ℚ.

*Proof.* Apply Schanuel with n = 1, z = (q). ℚ-linear independence of {q} follows from q ≠ 0. The combined tuple is (q, e^q). Since q is algebraic, the algebraically independent element must be e^q, making it transcendental. □

## 4. EML Closure Properties

**Theorem 4.1.** The class of EML-constructible reals is closed under:
- Field operations (+, −, ×, ÷)
- Exponentiation (exp)
- Logarithm (log)
- The EML operation

*Proof.* Direct from the inductive definition of EMLExpr. □

The closure properties ensure that the EML class forms a rich mathematical structure containing all "elementary" transcendental constants.

## 5. Algorithms

### 5.1 EML Expression Evaluation

```
Algorithm: EML_EVAL(expr)
Input: EML expression tree
Output: Real number (floating-point approximation)

match expr with
| rat(q) → return float(q)
| exp(e) → return exp(EML_EVAL(e))
| log(e) → return log(EML_EVAL(e))
| add(e1, e2) → return EML_EVAL(e1) + EML_EVAL(e2)
| sub(e1, e2) → return EML_EVAL(e1) - EML_EVAL(e2)
| mul(e1, e2) → return EML_EVAL(e1) * EML_EVAL(e2)
| div(e1, e2) → return EML_EVAL(e1) / EML_EVAL(e2)
| emlOp(e1, e2) → return exp(EML_EVAL(e1)) - log(EML_EVAL(e2))
```

### 5.2 Schanuel Independence Checker

```
Algorithm: SCHANUEL_CHECK(z1, ..., zn)
Input: Real numbers z1, ..., zn
Output: Whether Schanuel predicts algebraic independence

1. Check ℚ-linear independence of z1, ..., zn
   (using LLL or exact arithmetic if rational)
2. Compute exp(z1), ..., exp(zn)
3. Identify algebraic values among {z1, ..., zn, exp(z1), ..., exp(zn)}
4. Remaining values form the candidate algebraically independent set
5. If |candidate set| ≥ n, report "Schanuel predicts independence"
```

## 6. Discussion

### 6.1 Relation to Prior Work

Our results build on the formalization of Schanuel's conjecture in the project catalog (`Algebra/Schanuel/Theorems.lean`), extending it with:
- The polynomial lifting technique (new)
- Specific algebraic independence derivations for (e, log 2) and (e, e^e) (new)
- The EML closure structure and depth hierarchy (new)

### 6.2 The Lifting Technique as a General Tool

The polynomial lifting-and-retraction technique introduced in Section 3.1 is more general than our specific applications suggest. For any polynomial expression p(x₁, ..., xₙ) in k variables, the map ℚ[X] → MvPolynomial(Fin n, ℚ) sending X ↦ p(X₁, ..., Xₙ) is injective whenever p is transcendental over ℚ in the polynomial ring. This provides a systematic method for converting algebraic independence results into transcendence results for arbitrary polynomial combinations.

### 6.3 Limitations

1. All transcendence results are conditional on Schanuel's conjecture, which remains unproven.
2. The depth hierarchy is conjectural — we have not proved unconditionally that depth-2 EML numbers cannot be expressed at depth 1.
3. The algebraic independence of (e^e, log 2) is stated as a hypothesis rather than derived from Schanuel (the derivation requires a 3-variable application that is more complex).

## 7. Future Work

1. **Three-variable Schanuel applications**: Derive algebraic independence of {e, e^e, log 2} from Schanuel directly, completing the proof of transcendence of e^e + log 2.
2. **Effective transcendence measures**: Combine the algebraic independence framework with Diophantine approximation to obtain effective transcendence measures for EML numbers.
3. **Tropical-EML bridge**: Connect the EML hierarchy to tropical geometry, where min-plus operations replace exponential operations under logarithmic degeneration.

## References

1. S. Lang, *Introduction to Transcendental Numbers*, Addison-Wesley, 1966.
2. M. Waldschmidt, *Diophantine Approximation on Linear Algebraic Groups*, Springer, 2000.
3. A. Baker, *Transcendental Number Theory*, Cambridge University Press, 1975.
4. Catalog: `Algebra/Schanuel/Theorems.lean` — formalization of Schanuel's conjecture and Lindemann-Weierstrass consequences.
5. Catalog: `EML/EMLv17Core.lean` — core EML function definitions and properties.
6. Catalog: `MachineLearning/Schanuel/Defs.lean` — transcendence degree formulation of Schanuel.
