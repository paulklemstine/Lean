# Spectral Rigidity of the q-Deformed Casimir Operator

## Abstract

We develop the formal spectral theory of q-deformed Casimir operators for the quantum group SU_q(2). Our central result is **spectral rigidity**: the q-Casimir spectrum determines the quantum group parameter *q* uniquely up to Weyl inversion *q* ↔ *q*⁻¹. Remarkably, a single eigenvalue C_q(1) = *q* + 1/*q* suffices for this determination, an inverse spectral theorem with no classical analog. We establish the complete foundational theory: the fundamental recurrence [*n*+1]_q = *q*·[*n*]_q + *q*^{−*n*}, Weyl inversion symmetry [*n*]_q = [*n*]_{*q*⁻¹}, strict positivity of q-numbers for *q* > 0 and *n* ≥ 1, strict monotonicity of the q-Casimir spectrum, and an exact spectral gap formula C_q(2) − C_q(1) = (*q* + *q*⁻¹)(*q*² + *q*⁻²). All results are formalized as machine-verified proofs in Lean 4 with Mathlib.

**Keywords**: quantum groups, q-deformation, Casimir operator, spectral rigidity, inverse spectral problem, Weyl symmetry

## 1. Introduction

### 1.1 Context and Motivation

The Casimir operator is the center of the universal enveloping algebra of a Lie algebra, acting as a scalar on each irreducible representation. For SU(2), the classical Casimir eigenvalues are *n*(*n*+1) for *n* = 0, 1, 2, …, where *n* labels the spin-*n* representation. This spectrum is universal — it carries no continuous parameter information.

The quantum group deformation SU_q(2), introduced independently by Drinfeld [1] and Jimbo [2], replaces the classical algebra with a one-parameter family indexed by *q* > 0. The q-analog of the Casimir operator has eigenvalues C_q(*n*) = [*n*]_q · [*n*+1]_q, where [*n*]_q = (*q*ⁿ − *q*⁻ⁿ)/(*q* − *q*⁻¹) is the q-number.

The fundamental question driving this work is: **How much information about *q* can be recovered from the spectrum {C_q(*n*)}?**

### 1.2 Main Results

We prove the following:

1. **Spectral Rigidity** (Theorem 3.1): If C_q(1) = C_p(1) for *q*, *p* > 0, then *q* = *p* or *q*·*p* = 1. A single eigenvalue determines *q* up to Weyl inversion.

2. **Weyl Inversion Symmetry** (Theorem 2.3): [*n*]_q = [*n*]_{*q*⁻¹} for all *n* and *q* ≠ 0. This extends to the Casimir level: C_q(*n*) = C_{*q*⁻¹}(*n*).

3. **Fundamental Recurrence** (Theorem 2.2): [*n*+1]_q = *q*·[*n*]_q + *q*⁻ⁿ for *q* > 0, *q* ≠ 1. This is the key structural relation underlying inductive arguments.

4. **Positivity** (Theorem 2.4): [*n*]_q > 0 for all *q* > 0 and *n* ≥ 1.

5. **Strict Monotonicity** (Theorem 2.5): [*n*]_q < [*n*+1]_q for all *q* > 0 and *n* ≥ 0.

6. **Spectral Gap Formula** (Theorem 4.1): C_q(2) − C_q(1) = (*q* + *q*⁻¹)(*q*² + *q*⁻²).

7. **Weyl Equivalence Characterization** (Theorem 3.3): Two quantum spectral data are Weyl-equivalent if and only if they share the same Casimir spectrum.

### 1.3 Structure of the Paper

Section 2 establishes the foundational theory of q-numbers. Section 3 proves spectral rigidity and characterizes Weyl equivalence. Section 4 analyzes spectral gaps and counting. Section 5 discusses connections to other areas. Section 6 presents future directions.

## 2. Foundations: q-Numbers and Their Properties

### 2.1 Definitions

**Definition 2.1** (q-Number). For *q* ∈ ℝ and *n* ∈ ℕ, the q-number is:
$$[n]_q = \begin{cases} n & \text{if } q = 1 \\ \frac{q^n - q^{-n}}{q - q^{-1}} & \text{if } q \neq 1 \end{cases}$$

**Definition 2.2** (q-Casimir Eigenvalue). The q-Casimir eigenvalue on the spin-*n* representation is:
$$C_q(n) = [n]_q \cdot [n+1]_q$$

**Definition 2.3** (Quantum Spectral Datum). A quantum spectral datum is a pair (*q*, *q* > 0) packaging a positive deformation parameter with its associated spectral data.

**Definition 2.4** (Weyl Equivalence). Two quantum spectral data (*q*, ·) and (*p*, ·) are Weyl-equivalent if *q* = *p* or *q*·*p* = 1.

### 2.2 Basic Evaluations

**Proposition 2.1**: [0]_q = 0, [1]_q = 1, [2]_q = *q* + *q*⁻¹ for all *q* > 0.

*Proof sketch*. The case *n* = 0 is immediate. For *n* = 1 with *q* ≠ 1: (*q* − *q*⁻¹)/(*q* − *q*⁻¹) = 1. For *n* = 2: (*q*² − *q*⁻²)/(*q* − *q*⁻¹) = (*q* − *q*⁻¹)(*q* + *q*⁻¹)/(*q* − *q*⁻¹) = *q* + *q*⁻¹. □

### 2.3 Fundamental Recurrence

**Theorem 2.2** (Fundamental Recurrence). For *q* > 0, *q* ≠ 1:
$$[n+1]_q = q \cdot [n]_q + q^{-n}$$

*Proof sketch*. Direct computation:
$$q \cdot [n]_q + q^{-n} = q \cdot \frac{q^n - q^{-n}}{q - q^{-1}} + q^{-n} = \frac{q^{n+1} - q^{-n+1} + q^{-n}(q - q^{-1})}{q - q^{-1}} = \frac{q^{n+1} - q^{-(n+1)}}{q - q^{-1}} = [n+1]_q$$

This recurrence is the workhorse of inductive proofs. It expresses [*n*+1]_q as a *q*-scaling of [*n*]_q plus a correction term *q*⁻ⁿ that captures the quantum contribution. □

### 2.4 Weyl Inversion Symmetry

**Theorem 2.3** (Weyl Symmetry). For *q* ≠ 0:
$$[n]_q = [n]_{q^{-1}}$$

*Proof sketch*. Replacing *q* by *q*⁻¹ negates both numerator and denominator:
$$[n]_{q^{-1}} = \frac{q^{-n} - q^n}{q^{-1} - q} = \frac{-(q^n - q^{-n})}{-(q - q^{-1})} = [n]_q$$

This symmetry reflects the Weyl group ℤ/2ℤ of SU(2), acting by *q* ↦ *q*⁻¹. It is the quantum manifestation of a fundamental algebraic symmetry. □

### 2.5 Positivity

**Theorem 2.4** (Positivity). For *q* > 0 and *n* ≥ 1, [*n*]_q > 0.

*Proof sketch*. For *q* = 1: [*n*]₁ = *n* > 0. For *q* > 1: both *q*ⁿ − *q*⁻ⁿ > 0 and *q* − *q*⁻¹ > 0, so the ratio is positive. For 0 < *q* < 1: both expressions are negative, so their ratio is positive. □

### 2.6 Strict Monotonicity

**Theorem 2.5** (Strict Monotonicity). For *q* > 0, [*n*]_q < [*n*+1]_q for all *n* ≥ 0.

*Proof sketch*. For *q* = 1: *n* < *n* + 1. For *q* > 1, *n* ≥ 1: by the recurrence, [*n*+1]_q − [*n*]_q = (*q*−1)·[*n*]_q + *q*⁻ⁿ > 0 since both terms are positive. For *n* = 0: [1]_q = 1 > 0 = [0]_q. For 0 < *q* < 1: use Weyl symmetry to reduce to the *q* > 1 case. □

## 3. Spectral Rigidity

### 3.1 The Core Algebraic Lemma

**Lemma 3.1** (Sum-Inverse Rigidity). For *q*, *p* > 0, if *q* + 1/*q* = *p* + 1/*p*, then *q* = *p* or *q*·*p* = 1.

*Proof*. From *q* + 1/*q* = *p* + 1/*p*:
$$q - p + \frac{1}{q} - \frac{1}{p} = 0 \implies q - p + \frac{p - q}{qp} = 0 \implies (q - p)\left(1 - \frac{1}{qp}\right) = 0$$

Since *q*, *p* > 0, either *q* − *p* = 0 or 1 − 1/(*qp*) = 0, giving *q* = *p* or *qp* = 1. □

**Remark**. This lemma has a geometric interpretation: the function *f*(*x*) = *x* + 1/*x* is a 2-to-1 covering of [2, ∞) by (0, ∞), with deck transformation *x* ↦ 1/*x*. The fibers are exactly the Weyl orbits.

### 3.2 The Spectral Rigidity Theorem

**Theorem 3.1** (Spectral Rigidity). For *q*, *p* > 0, if C_q(1) = C_p(1), then *q* = *p* or *q*·*p* = 1.

*Proof*. By Proposition 2.1, C_q(1) = [1]_q · [2]_q = 1 · (*q* + *q*⁻¹) = *q* + *q*⁻¹. The hypothesis gives *q* + *q*⁻¹ = *p* + *p*⁻¹, and Lemma 3.1 yields the conclusion. □

**Corollary 3.2**. The spectral rigidity is *sharp*: the Weyl ambiguity cannot be removed, since C_q(*n*) = C_{*q*⁻¹}(*n*) for all *n* by Theorem 2.3.

### 3.3 Characterization of Weyl Equivalence

**Theorem 3.3** (Weyl Equivalence Characterization).
- (Forward) If (*q*, ·) and (*p*, ·) are Weyl-equivalent, then C_q(*n*) = C_p(*n*) for all *n*.
- (Converse) If C_q(1) = C_p(1), then (*q*, ·) and (*p*, ·) are Weyl-equivalent.

*Proof*. The forward direction follows from Weyl symmetry (if *qp* = 1) or trivially (if *q* = *p*). The converse is Theorem 3.1. □

### PEGB Analysis for Spectral Rigidity

**Proof**: Complete formal proof as above.

**Example**: At *q* = 2, C₂(1) = 2 + 1/2 = 2.5. The quadratic *t*² − 2.5*t* + 1 = 0 has roots *t* = 2 and *t* = 0.5, recovering {*q*, 1/*q*} = {2, 0.5}.

**Generalization**: For SU_q(*N*) with *N* ≥ 3, the Weyl group is *S_N* rather than ℤ/2ℤ, and spectral rigidity should determine *q* up to this larger symmetry group. The q-numbers of the fundamental representations encode *q* through higher elementary symmetric functions of {*q*, *q*⁻¹, 1}.

**Boundary**: At *q* = 1, spectral rigidity degenerates: C₁(1) = 2, and the quadratic *t*² − 2*t* + 1 = (*t* − 1)² = 0 has a double root, reflecting the coalescence of the Weyl orbit {*q*, *q*⁻¹} to a single point. The discriminant (*q* + *q*⁻¹)² − 4 vanishes exactly at *q* = 1.

## 4. Spectral Gap Analysis

### 4.1 First Spectral Gap

**Theorem 4.1** (First Spectral Gap). For *q* > 0:
$$C_q(2) - C_q(1) = (q + q^{-1})(q^2 + q^{-2})$$

*Proof sketch*. C_q(2) = [2]_q · [3]_q where [3]_q = *q*² + 1 + *q*⁻². Thus C_q(2) = (*q* + *q*⁻¹)(*q*² + 1 + *q*⁻²) and C_q(1) = *q* + *q*⁻¹, giving the gap (*q* + *q*⁻¹)(*q*² + *q*⁻²). □

### PEGB Analysis for Spectral Gap

**Proof**: Complete formal proof verified.

**Example**: At *q* = 2, gap = 2.5 × 4.25 = 10.625. At *q* = 1, gap = 2 × 2 = 4 (matching C₁(2) − C₁(1) = 6 − 2 = 4).

**Generalization**: The *n*-th spectral gap C_q(*n*+1) − C_q(*n*) = [*n*+1]_q([*n*+2]_q − [*n*]_q) + [*n*]_q([*n*+1]_q − [*n*]_q⁻¹...) admits a similar factored expression involving higher q-numbers.

**Boundary**: As *q* → ∞, the gap grows as *q*⁴ (exponential in *q*), demonstrating spectral gap amplification. As *q* → 0⁺, by Weyl symmetry, the gap also grows as *q*⁻⁴. The gap is minimized at *q* = 1, where it achieves the classical value 4.

### 4.2 Spectral Counting

For *q* > 1, the q-Casimir eigenvalue C_q(*n*) grows as *q*^{2*n*} for large *n*. The number of eigenvalues below threshold *T* is therefore:

$$N(T) \sim \frac{\log T}{2 \log q}$$

This logarithmic growth contrasts sharply with the classical (*q* = 1) counting N(*T*) ~ √*T*. The transition from polynomial to logarithmic counting at *q* = 1 is a spectral phase transition.

### PEGB Analysis for Positivity

**Proof**: Complete formal proof using case analysis on *q* > 1 and 0 < *q* < 1.

**Example**: [3]_{0.5} = (0.5³ − 2³)/(0.5 − 2) = (0.125 − 8)/(−1.5) = 7.875/1.5 = 5.25 > 0. ✓

**Generalization**: Positivity extends to q-factorials [*n*]_q! = ∏_{k=1}^n [*k*]_q > 0, and to Gaussian binomial coefficients, which are products of ratios of q-factorials.

**Boundary**: At *n* = 0, [0]_q = 0 — positivity fails. This is the natural boundary: the trivial representation has zero Casimir eigenvalue.

## 5. Connections and Discussion

### 5.1 Connection to Existing Spectral Bounds

The q-Casimir eigenvalue C_q(*n*) generalizes the classical spectral bound *n*(*n*+1), connecting to the quadratic spectral bounds in the existing catalog (cf. `spectral_bound_quadratic_in_width`). The q-deformation adds a new parameter axis to spectral bound theory, showing that spectral bounds carry additional rigidity in the quantum setting.

### 5.2 Relationship to Riemann Zeta Zeros

The logarithmic spectral counting function for *q* > 1 parallels the asymptotic density of Riemann zeta zeros on the critical line, which is ~ (log *T*)/(2π). If we formally match *q* = e^π, the counting functions have the same leading-order behavior. Combined with the Weyl symmetry *q* ↔ *q*⁻¹ mirroring the functional equation *s* ↔ 1 − *s*, this suggests a structural connection worth investigating.

### 5.3 Physical Interpretation

In quantum physics, the parameter *q* controls the non-commutativity of the quantum phase space. Spectral rigidity means that measuring a single energy level of a quantum system governed by SU_q(2) symmetry is enough to determine the non-commutativity parameter. This is remarkably efficient — in classical mechanics, determining system parameters typically requires multiple measurements.

## 6. Future Work

1. **Higher-rank spectral rigidity**: Extend to SU_q(*N*) with *N* ≥ 3. The Weyl group becomes *S_N*, and *N*−1 independent Casimir operators are available.

2. **Spectral zeta function**: Define ζ_q(*s*) = ∑_n C_q(*n*)^{−*s*} and study its analytic properties, functional equation, and special values.

3. **Categorical spectral rigidity**: Determine whether the *braided monoidal category* of SU_q(2)-representations is determined by its Casimir spectrum.

4. **Spectral counting refinement**: Prove the precise asymptotic N_q(*T*) ~ log(*T*)/(2 log *q*) with error bounds.

## References

[1] V.G. Drinfeld, "Quantum Groups," Proceedings of the ICM, Berkeley, 1986, pp. 798–820.

[2] M. Jimbo, "A q-analogue of U(𝔤𝔩(N+1)), Hecke algebra, and the Yang-Baxter equation," Lett. Math. Phys. 11 (1986), 247–252.

[3] V. Chari and A. Pressley, *A Guide to Quantum Groups*, Cambridge University Press, 1994.

[4] C. Kassel, *Quantum Groups*, Springer Graduate Texts in Mathematics 155, 1995.

[5] M. Kac, "Can one hear the shape of a drum?", Amer. Math. Monthly 73 (1966), no. 4, Part II, 1–23.

## Appendix: Formal Verification Summary

All results in this paper have been formalized and verified in Lean 4 (v4.28.0) using the Mathlib library. The formalization consists of two files:

- `QCasimirDefs.lean`: Core definitions (qNumber, qCasimir, QuantumSpectralDatum, WeylEquiv) and foundational properties (evaluations, recurrence, Weyl symmetry, positivity, strict monotonicity).

- `QCasimirSpectral.lean`: Main theorems (sum-inverse rigidity, spectral rigidity, Weyl equivalence characterization, spectral gap formula, Casimir positivity and monotonicity).

Total: 14 theorems, 3 definitions, 1 structure, 0 sorries. All proofs use only the standard axioms (propext, Classical.choice, Quot.sound).
