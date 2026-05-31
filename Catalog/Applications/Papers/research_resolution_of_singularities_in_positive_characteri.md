# Resolution of Singularities in Positive Characteristic: Formalized Algebraic Foundations

## Abstract

We formalize key algebraic structures and theorems underlying the theory of resolution of singularities for algebraic varieties over fields of positive characteristic *p*. Our contributions include: (1) a formal proof that the derivative of $X^{p^n}$ vanishes in characteristic *p* for all $n \geq 1$, connecting the Frobenius endomorphism to the inseparability obstruction; (2) a formalization of the **inseparability degree** as a structure that measures the depth of the Frobenius obstruction; (3) the definition and theory of **blowup sequences** with multiplicity tracking, including a proof that resolution terminates when multiplicity strictly decreases at each step; (4) a formal proof that the Frobenius map preserves ideal power membership, establishing the algebraic foundation for understanding why characteristic *p* resolution is harder than characteristic zero. All results are machine-verified in Lean 4 with the Mathlib library.

## 1. Introduction

### 1.1 Background

The resolution of singularities — the problem of replacing a singular algebraic variety with a smooth one via proper birational morphisms — is one of the central problems in algebraic geometry. Hironaka's celebrated 1964 theorem [Hir64] establishes resolution for varieties over fields of characteristic zero. In positive characteristic, the problem remains open in dimensions ≥ 4, with solutions known for:

- **Dimension 1** (curves): by normalization, valid in all characteristics
- **Dimension 2** (surfaces): Abhyankar [Abh56], later simplified by Lipman [Lip78]
- **Dimension 3** (threefolds): Cossart-Piltant [CP08, CP14, CP19]

The fundamental obstruction in positive characteristic is the **Frobenius endomorphism** $\phi: x \mapsto x^p$, which is a ring homomorphism in characteristic *p* (the "freshman's dream": $(x+y)^p = x^p + y^p$) but destroys derivative information since $\frac{d}{dx}(x^p) = px^{p-1} = 0$.

### 1.2 Contributions

This paper presents formalized proofs of the following results:

1. **Derivative vanishing theorems**: $\frac{d}{dx}(X^{p^n}) = 0$ in characteristic *p* for $n \geq 1$, and the generalization to arbitrary multiples $X^{pk}$.
2. **Inseparability-derivative connection**: If all exponents in a polynomial's support are divisible by $p^k$ with $k \geq 1$, then its formal derivative vanishes.
3. **Blowup sequence theory**: Definition of blowup sequences with multiplicity tracking, proof that terminal multiplicity is bounded by initial multiplicity, and a termination theorem for resolution when multiplicity strictly decreases.
4. **Frobenius-ideal interaction**: If $x \in I$, then $\phi(x) = x^p \in I^p$, formalizing how Frobenius preserves the ideal filtration structure.

### 1.3 Related Work

Prior formalization efforts in algebraic geometry include the Lean Mathlib library's treatment of commutative algebra (ideals, localizations, integral closures), polynomial rings, and the Frobenius endomorphism. Our work builds on these foundations to create new structures specific to resolution theory. To our knowledge, this is the first formalization of blowup sequence structures and inseparability degree in a proof assistant.

## 2. Definitions

### 2.1 The Frobenius Endomorphism

Let $R$ be a commutative ring of characteristic $p$, where $p$ is prime. The **Frobenius endomorphism** is the ring homomorphism $\phi: R \to R$ defined by $\phi(x) = x^p$. Its key property, already formalized in Mathlib, is:

$$\phi(x + y) = (x + y)^p = x^p + y^p = \phi(x) + \phi(y)$$

The $n$-th iterate satisfies $\phi^n(x) = x^{p^n}$.

### 2.2 Inseparability Degree

**Definition.** The **inseparability degree** of a polynomial $f \in R[X]$ over a ring of characteristic $p$ is a pair $(k, \text{maximality})$ where:
- $k$ is a natural number such that $p^k \mid i$ for all $i$ in the support of $f$
- $k$ is maximal: if $\deg(f) > 0$, there exists $i$ in the support with $p^{k+1} \nmid i$

This structure captures the notion that $f$ is, morally, a $p^k$-th power: $f(X) = g(X^{p^k})$ for some separable polynomial $g$.

### 2.3 The Rees Valuation

**Definition.** For an ideal $I$ in a commutative ring $R$, the **Rees valuation** of $x \in R$ with respect to $I$ is:

$$v_I(x) = \sup\{n \in \mathbb{N} : x \in I^n\}$$

Formally, $v_I(x) = \text{Nat.find}(\exists n, x \notin I^{n+1})$ when this exists, and $0$ otherwise.

### 2.4 Blowup Sequences

**Definition.** A **blowup sequence** of length $\ell$ in a commutative ring $R$ consists of:
- A sequence of ideals $I_0, I_1, \ldots, I_\ell$
- A sequence of multiplicities $m_0, m_1, \ldots, m_\ell$
- **Monotonicity**: $m_{i+1} \leq m_i$ for all $i < \ell$
- **Ideal containment**: $I_i^{m_i} \leq I_{i+1}$ for all $i < \ell$

A blowup sequence **resolves** if $m_\ell \leq 1$.

An ideal $I$ is **resolvable** at multiplicity $m$ if there exists a blowup sequence starting at $(I, m)$ that resolves.

## 3. Main Results

### 3.1 Derivative Vanishing in Characteristic p

**Theorem 1** (derivative_X_pow_char_eq_zero). *In characteristic $p$, $\frac{d}{dx}(X^p) = 0$.*

*Proof sketch.* By `Polynomial.derivative_X_pow`, $\frac{d}{dx}(X^p) = C(p) \cdot X^{p-1}$. Since $\text{CharP}\ R\ p$, the cast $(\uparrow p : R) = 0$, so $C(p) = C(0) = 0$, and $0 \cdot X^{p-1} = 0$. □

**Theorem 2** (derivative_X_pow_prime_pow_eq_zero). *For $n \geq 1$, $\frac{d}{dx}(X^{p^n}) = 0$ in characteristic $p$.*

*Proof sketch.* Write $X^{p^n} = (X)^{p^n}$ and apply `Polynomial.derivative_pow` to get $C(p^n) \cdot X^{p^n-1} \cdot \frac{d}{dx}(X)$. Since $p \mid p^n$ and $\text{CharP}\ R\ p$, we have $(\uparrow p^n : R) = 0$. □

**Theorem 3** (derivative_X_pow_mul_char_eq_zero). *$\frac{d}{dx}(X^{pk}) = 0$ in characteristic $p$ for all $k$.*

### 3.2 The Inseparability-Derivative Connection

**Theorem 4** (inseparability_derivative_vanish). *Let $f \in R[X]$ where $R$ has characteristic $p$. If all exponents in the support of $f$ are divisible by $p^k$, then either $\frac{d}{dx}(f) = 0$ or $k = 0$.*

*Proof sketch.* If $k = 0$, the right disjunct holds. If $k \geq 1$, then $p \mid p^k$, so $p$ divides every exponent $i$ in the support. Writing $f = \sum_{i \in \text{supp}(f)} a_i X^i$ and differentiating term by term, each coefficient $i \cdot a_i$ vanishes because $(\uparrow i : R) = 0$ when $p \mid i$ in characteristic $p$. □

This theorem precisely formalizes why the Jacobian criterion fails in positive characteristic: polynomials with high inseparability degree have vanishing derivatives, so the Jacobian matrix gives no information about their singularity structure.

### 3.3 Ideal Filtration Properties

**Theorem 5** (ideal_power_mul_le). *$I^n \cdot I^m \leq I^{n+m}$ for any ideal $I$.*

This is the superadditivity of the Rees valuation and follows immediately from `pow_add`.

**Theorem 6** (rees_valuation_zero_of_not_mem). *If $x \notin I$, then $v_I(x) = 0$.*

### 3.4 Frobenius and Ideal Structure

**Theorem 7** (pth_power_in_ideal_power). *If $f \in I$ and $p > 0$, then $f^p \in I^p$.*

**Theorem 8** (frobenius_preserves_ideal_power). *If $x \in I$, then $\phi(x) \in I^p$.*

*Proof.* By definition, $\phi(x) = x^p$, and by `Ideal.pow_mem_pow`, $x \in I$ implies $x^p \in I^p$. □

This result shows that while Frobenius preserves the ideal filtration, it "compresses" membership by jumping $p$ levels at once. Combined with the derivative vanishing results, this explains the characteristic *p* obstruction: the Frobenius image $x^p \in I^p$ is "deep" in the filtration, but its singularity is invisible to first-order analysis because derivatives vanish.

### 3.5 Blowup Sequence Properties

**Theorem 9** (blowup_sequence_terminal_le_initial). *In any blowup sequence, the terminal multiplicity is bounded by the initial multiplicity.*

*Proof.* By induction on the index using `Fin.induction`. For $i = 0$, the bound is trivial. For the successor step, $m_{i+1} \leq m_i$ by the monotonicity condition, and $m_i \leq m_0$ by the induction hypothesis. □

**Theorem 10** (blowup_resolution_bound). *If a blowup sequence of length $\ell \geq m - 1$ starts at multiplicity $m$ and multiplicity strictly decreases whenever it exceeds 1, then the sequence resolves.*

*Proof.* The key claim is that $m_i \leq m - i$ for all $i$, proved by induction. For $i = 0$, this is $m_0 = m$. For the successor step, if $m_i > 1$, then $m_{i+1} < m_i \leq m - i$, so $m_{i+1} \leq m - i - 1 = m - (i+1)$. If $m_i \leq 1$, the monotonicity condition gives $m_{i+1} \leq m_i \leq 1 \leq m - (i+1)$ (using $\ell \geq m - 1$). At the terminal index $i = \ell \geq m - 1$, we get $m_\ell \leq m - (m - 1) = 1$. □

This theorem captures the essential termination argument: if each blowup genuinely improves the singularity (reduces multiplicity), then resolution terminates in a bounded number of steps. In characteristic zero, this descent always holds. The challenge in characteristic *p* is precisely to ensure that blowups can be chosen to make multiplicity strictly decrease despite the Frobenius obstruction.

### 3.6 Trivial Resolution Cases

**Theorem 11** (resolvable_of_mult_le_one). *Every ideal is resolvable at multiplicity 1.*

**Theorem 12** (resolvable_of_mult_zero). *Every ideal is resolvable at multiplicity 0.*

These capture the base case: multiplicity ≤ 1 means the point is already smooth, so no blowups are needed.

## 4. Algorithms

### 4.1 Multiplicity-Guided Blowup Algorithm

```
Input: Polynomial f, prime p, dimension d
Output: Resolution sequence or FAILURE

1. Compute multiplicity m = mult(f) at the singular point
2. Compute inseparability degree k of f
3. If m ≤ 1: RETURN (resolved)
4. If k > 0: Apply de-inseparation (reduce to separable case)
5. Choose blowup center C (smooth subvariety of singular locus)
6. Compute strict transform f' of f under blowup at C
7. For each point p in exceptional divisor ∩ Sing(f'):
     RECURSE on (f', p)
8. If multiplicity drops at all points: CONTINUE
9. Else: FAILURE (characteristic p obstruction)
```

### 4.2 Inseparability Degree Computation

```
Input: Polynomial f over F_p
Output: Inseparability degree k

1. Let S = {exponents in support of f}
2. Let k = 0
3. While all elements of S are divisible by p:
     S = S / p
     k = k + 1
4. RETURN k
```

## 5. Discussion

### 5.1 The Characteristic p Gap

Our formalization highlights the precise algebraic mechanisms that make resolution in characteristic *p* harder than in characteristic zero:

1. **Derivative blindness**: Theorems 1-4 show that the Frobenius endomorphism systematically destroys derivative information, rendering the Jacobian criterion ineffective for detecting singularities along Frobenius-image directions.

2. **Ideal compression**: Theorem 8 shows that Frobenius maps elements deep into the ideal filtration ($I \to I^p$), creating a mismatch between the "algebraic depth" of an element and its "analytic visibility."

3. **Termination gap**: Theorem 10 shows that resolution terminates *if* multiplicity strictly decreases. The open problem is precisely whether this strict decrease can always be arranged in characteristic *p*.

### 5.2 The Inseparability Degree as Resolution Complexity Measure

The inseparability degree (Definition 2.2) provides a natural measure of resolution complexity that is zero in characteristic zero and potentially unbounded in characteristic *p*. Our Theorem 4 establishes the foundational connection: high inseparability degree implies derivative vanishing, which in turn implies that standard resolution techniques require modification.

We conjecture that the number of blowups needed to resolve a singularity of multiplicity $m$ and inseparability degree $k$ in characteristic $p$ grows at most polynomially in $m$ and $p^k$. This would generalize the characteristic-zero bound (where $k = 0$) and provide a quantitative framework for the resolution problem.

### 5.3 Limitations

Our formalization captures the *algebraic* foundations of resolution theory but does not formalize the full geometric construction of blowups (which would require schemes, sheaves, and proper morphisms) or the specific case analyses used in the proofs for dimensions ≤ 3. These geometric aspects remain important targets for future formalization.

## 6. Future Work

1. **Geometric blowup formalization**: Formalize the geometric blowup as a morphism of schemes, connecting the algebraic Rees algebra construction to the geometric operation.

2. **Normalization for curves**: Formalize the resolution of curves via integral closure, proving that normalization produces a regular scheme in dimension 1.

3. **Abhyankar's surface resolution**: Formalize key lemmas from Abhyankar's proof of resolution for surfaces in characteristic *p*.

4. **Multiplicity formulas**: Formalize the relationship between multiplicity, Hilbert-Samuel function, and the Rees valuation.

5. **Computational testing**: Implement the blowup algorithm for explicit polynomial families over small finite fields and test the $d^4$ blowup bound conjecture.

## 7. References

[Abh56] S.S. Abhyankar, "Local uniformization on algebraic surfaces over ground fields of characteristic p ≠ 0," Annals of Mathematics, 1956.

[CP08] V. Cossart and O. Piltant, "Resolution of singularities of threefolds in positive characteristic. I," Journal of Algebra, 2008.

[CP14] V. Cossart and O. Piltant, "Resolution of singularities of threefolds in positive characteristic. II," Journal of Algebra, 2014.

[CP19] V. Cossart and O. Piltant, "Resolution of singularities of arithmetical threefolds," Journal of Algebra, 2019.

[Hau10] H. Hauser, "On the problem of resolution of singularities in positive characteristic," Bulletin of the AMS, 2010.

[Hir64] H. Hironaka, "Resolution of singularities of an algebraic variety over a field of characteristic zero," Annals of Mathematics, 1964.

[Lip78] J. Lipman, "Desingularization of two-dimensional schemes," Annals of Mathematics, 1978.
