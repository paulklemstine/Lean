# Algebraic Foundations of q-Casimir Spectral Theory

## Abstract

We develop the algebraic foundations of q-Casimir spectral theory, establishing rigorously proved identities for q-integers, q-Casimir eigenvalues, and spectral gaps. Our central results are: (1) a closed-form factorization of spectral gaps Δ_n = [n+1]_q · q^n · (1+q), (2) a first-order linear recurrence Δ_{n+1} = q²·Δ_n + q^{n+1}·(1+q) that generates the entire spectral gap sequence, (3) the q-integer multiplication formula [nm]_q = [n]_q · [m]_{q^n}, and (4) a formal equivalence between the spectral gap sequence and the orbit of a 2D affine dynamical system. All results are machine-verified in Lean 4 with Mathlib.

**Keywords**: q-integers, quantum groups, Casimir operator, spectral gaps, dynamical systems, q-analog

---

## 1. Introduction

The Casimir operator of a Lie algebra plays a fundamental role in representation theory, providing a canonical element of the center of the universal enveloping algebra whose eigenvalues label irreducible representations. For the quantum group U_q(𝔰𝔩₂), the q-Casimir element has eigenvalues determined by q-integers, the standard q-analogs of natural numbers.

Despite the centrality of q-Casimir eigenvalues in quantum group theory, their spectral properties — particularly the structure of gaps between consecutive eigenvalues — have received relatively little systematic algebraic treatment. This paper addresses this gap by establishing a complete algebraic description of the q-Casimir spectral gap sequence.

### 1.1 Main Results

Our principal contributions are:

1. **Spectral Gap Closed Form** (Theorem 4.1): The gap between consecutive q-Casimir eigenvalues factorizes as Δ_n = [n+1]_q · q^n · (1+q), separating algebraic, geometric, and universal contributions.

2. **Spectral Gap Recurrence** (Theorem 4.2): The gap sequence satisfies Δ_{n+1} = q²·Δ_n + q^{n+1}·(1+q), a first-order inhomogeneous linear recurrence with geometric forcing.

3. **q-Integer Multiplication Formula** (Theorem 6.1): The identity [nm]_q = [n]_q · [m]_{q^n} establishes a "twisted multiplicativity" of q-integers.

4. **Dynamical Systems Bridge** (Theorem 7.1): The spectral gap sequence is the first-component orbit of the 2D affine map (Δ, p) ↦ (q²Δ + pq(1+q), pq) from initial condition (1+q, 1).

### 1.2 Related Work

q-integers and q-analogs have a long history going back to Euler and Gauss. The algebraic theory of quantum groups, developed by Drinfeld and Jimbo in the 1980s, provides the representation-theoretic context for q-Casimir operators. The spectral gap structure we study here is implicit in the representation theory of U_q(𝔰𝔩₂) but has not, to our knowledge, been explicitly isolated and studied as a dynamical system.

---

## 2. Definitions

**Definition 2.1** (q-Integer). For q ∈ ℝ and n ∈ ℕ, the q-integer is
$$[n]_q := \sum_{i=0}^{n-1} q^i = 1 + q + q^2 + \cdots + q^{n-1}$$

This polynomial form avoids the rational expression (1-q^n)/(1-q) and is well-defined for all q, including q = 1.

**Definition 2.2** (q-Casimir Eigenvalue). The q-Casimir eigenvalue is
$$\lambda_n(q) := [n]_q \cdot [n+1]_q$$

**Definition 2.3** (Spectral Gap). The n-th spectral gap is
$$\Delta_n(q) := \lambda_{n+1}(q) - \lambda_n(q)$$

**Definition 2.4** (Spectral Gap Dynamical System). The spectral gap dynamics is the map F_q : ℝ² → ℝ² defined by
$$F_q(\Delta, p) = (q^2 \Delta + pq(1+q),\; pq)$$

---

## 3. Basic Properties

**Theorem 3.1** (q-Integer Recurrences).
- (a) [n+1]_q = [n]_q + q^n (additive recurrence)
- (b) [n+1]_q = 1 + q·[n]_q (multiplicative recurrence)
- (c) [a+b]_q = [a]_q + q^a·[b]_q (additive splitting)

*Proof*. Part (a) follows from ∑_{i=0}^n q^i = ∑_{i=0}^{n-1} q^i + q^n. Part (b) follows from ∑_{i=0}^n q^i = 1 + q·∑_{i=0}^{n-1} q^i. Part (c) follows by induction on b using part (a). □

**Theorem 3.2** (Positivity). For q > 0 and n ≥ 1, [n]_q > 0.

*Proof*. Each summand q^i > 0, and the sum has at least one term. □

**Theorem 3.3** (Classical Limit). [n]_1 = n and λ_n(1) = n(n+1).

*Proof*. At q = 1, each summand equals 1, so [n]_1 = n. Then λ_n(1) = n·(n+1). □

---

## 4. Spectral Gap Theory

**Theorem 4.0** (Shift Identity). [n+2]_q - [n]_q = q^n·(1+q).

*Proof*. By the additive recurrence applied twice:
[n+2]_q = [n+1]_q + q^{n+1} = [n]_q + q^n + q^{n+1} = [n]_q + q^n(1+q). □

**Theorem 4.1** (Spectral Gap Closed Form).
$$\Delta_n = [n+1]_q \cdot q^n \cdot (1+q)$$

*Proof*. Expanding the definition:
$$\Delta_n = [n+1]_q[n+2]_q - [n]_q[n+1]_q = [n+1]_q([n+2]_q - [n]_q)$$
By the Shift Identity, [n+2]_q - [n]_q = q^n(1+q). □

**Theorem 4.2** (Spectral Gap Recurrence).
$$\Delta_{n+1} = q^2 \cdot \Delta_n + q^{n+1} \cdot (1+q)$$

*Proof*. By the closed form:
$$\Delta_{n+1} = [n+2]_q \cdot q^{n+1} \cdot (1+q)$$
$$= (1 + q[n+1]_q) \cdot q^{n+1} \cdot (1+q)$$
$$= q^{n+1}(1+q) + q^2 \cdot [n+1]_q \cdot q^n \cdot (1+q)$$
$$= q^{n+1}(1+q) + q^2 \cdot \Delta_n$$
using the multiplicative recurrence [n+2]_q = 1 + q·[n+1]_q. □

---

## 5. Monotonicity

**Theorem 5.1** (Spectral Gap Positivity). For q > 0, Δ_n > 0 for all n.

*Proof*. By the closed form, Δ_n = [n+1]_q · q^n · (1+q). Each factor is positive: [n+1]_q > 0 by Theorem 3.2, q^n > 0, and 1+q > 0. □

**Corollary 5.2** (Strict Monotonicity). For q > 0, λ_{n+1}(q) > λ_n(q) for all n.

---

## 6. The Multiplication Formula

**Theorem 6.1** (q-Integer Multiplication).
$$[nm]_q = [n]_q \cdot [m]_{q^n}$$

*Proof*. By induction on m. The base case [0]_q = 0 is immediate. For the inductive step:
$$[n(m+1)]_q = [nm + n]_q = [nm]_q + q^{nm} \cdot [n]_q$$
$$= [n]_q \cdot [m]_{q^n} + (q^n)^m \cdot [n]_q = [n]_q \cdot ([m]_{q^n} + (q^n)^m) = [n]_q \cdot [m+1]_{q^n}$$
using the additive splitting (Theorem 3.1c) and the additive recurrence at parameter q^n. □

### 6.1 Connection to Euler Products

The multiplication formula has a structural parallel with the Euler product of the Riemann zeta function. If we define a spectral zeta function
$$\zeta_C(s) = \sum_{n=1}^{\infty} \lambda_n(q)^{-s}$$
then the multiplicative structure of q-integers suggests the possibility of a factorization over "spectral primes." This remains a conjecture (see Section 9).

---

## 7. Dynamical Systems Bridge

**Theorem 7.1** (Faithful Generation). The map F_q^n(1+q, 1) = (Δ_n, q^n) for all n ≥ 0.

*Proof*. By induction on n. The base case n = 0: the initial state is (1+q, 1), and Δ_0 = [1]_q · 1 · (1+q) = 1+q, q^0 = 1. ✓

For the inductive step, assuming (Δ_n, q^n):
- Gap: q²·Δ_n + q^n·q·(1+q) = q²·Δ_n + q^{n+1}·(1+q) = Δ_{n+1} (by the recurrence).
- Power: q^n · q = q^{n+1}. □

### 7.1 Interpretation

The spectral gap dynamical system F_q is an affine map on ℝ² of the form
$$F_q\begin{pmatrix} \Delta \\ p \end{pmatrix} = \begin{pmatrix} q^2 & q(1+q) \\ 0 & q \end{pmatrix} \begin{pmatrix} \Delta \\ p \end{pmatrix}$$

The eigenvalues of the linear part are q² and q. For 0 < q < 1, both eigenvalues have magnitude less than 1, so the system is contracting and the spectral gaps decay geometrically. For q > 1, both eigenvalues exceed 1, so the gaps grow. The ratio of eigenvalues is q, which measures the relative rate of spectral stretching versus power growth.

---

## 8. Spectral Gap Ratio

**Theorem 8.1** (Gap Ratio Formula). For [n+1]_q ≠ 0:
$$\frac{\Delta_{n+1}}{\Delta_n} = q \cdot \frac{[n+2]_q}{[n+1]_q}$$

This follows immediately from the closed form.

**Conjecture 8.2** (Asymptotic Gap Ratio). For q > 0, q ≠ 1:
- If 0 < q < 1, then Δ_{n+1}/Δ_n → q as n → ∞
- If q > 1, then Δ_{n+1}/Δ_n → q² as n → ∞

*Evidence*: For 0 < q < 1, [n]_q → 1/(1-q), so the ratio [n+2]_q/[n+1]_q → 1. For q > 1, [n]_q = (q^n - 1)/(q-1) ~ q^n/(q-1), so the ratio → q.

---

## 9. Future Directions

### 9.1 Spectral Euler Product

The multiplication formula [nm]_q = [n]_q · [m]_{q^n} suggests investigating whether the spectral zeta function ζ_C(s) = Σ λ_n^{-s} admits a product decomposition over a distinguished subset of "spectral primes."

### 9.2 Complex Deformation

Extending q to the unit circle q = e^{iθ} would connect the theory to roots of unity, cyclotomic fields, and potentially to the Riemann zeros via the Hilbert-Pólya conjecture.

### 9.3 Higher-Rank Quantum Groups

The techniques developed here for U_q(𝔰𝔩₂) should extend to higher-rank quantum groups U_q(𝔤), where the Casimir spectrum is multi-dimensional and the dynamical systems become higher-dimensional.

---

## 10. Conclusion

We have established a complete algebraic description of the q-Casimir spectral gap sequence, revealing it as the output of a simple 2D affine dynamical system. The key identities — the closed form, the recurrence, and the multiplication formula — provide a rigorous foundation for studying the spectral theory of quantum group Casimir operators. The bridge to dynamical systems opens new avenues for applying ergodic theory and spectral analysis tools to representation-theoretic problems.

---

## References

1. V. G. Drinfeld, "Quantum groups," Proc. ICM Berkeley, 1986.
2. M. Jimbo, "A q-difference analogue of U(𝔤) and the Yang-Baxter equation," Lett. Math. Phys., 1985.
3. V. Chari and A. Pressley, *A Guide to Quantum Groups*, Cambridge University Press, 1994.
4. G. Gasper and M. Rahman, *Basic Hypergeometric Series*, Cambridge University Press, 2004.
5. C. Kassel, *Quantum Groups*, Springer GTM 155, 1995.
