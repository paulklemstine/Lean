# Formally Verified Mathematical Foundations of Periodic Table Structure

## Abstract

We establish rigorous mathematical foundations connecting quantum mechanics to the structure of the periodic table through three main results. First, we prove that the electron shell degeneracy formula 2n² reduces to the classical Pythagorean sum-of-odd-numbers identity, providing a number-theoretic explanation for shell capacities. Second, we show that the Madelung (n+l, n) filling order constitutes a well-founded relation on quantum subshells, proving the logical consistency of the aufbau principle and explaining why period lengths appear in doubled pairs. Third, we demonstrate that nuclear harmonic oscillator magic numbers arise from cumulative binomial coefficients, with the formula C(N+3, 3) governing shell closures. We unify these results through an abstract SpectralShellSystem framework that captures the essential mathematical structure of periodic table-like systems. All results are formally verified in Lean 4 with the Mathlib library.

**Keywords**: periodic table, quantum shell structure, Madelung rule, well-founded ordering, binomial coefficients, formal verification

## 1. Introduction

The periodic table of elements is one of the most successful organizational schemes in science, yet its mathematical foundations are rarely treated with full rigor. The period lengths 2, 8, 8, 18, 18, 32, 32, ... follow from quantum mechanics, but the precise mathematical structures that force this pattern — and the connections to classical number theory — deserve careful analysis.

This paper makes three contributions:

1. **Shell degeneracy via Pythagorean identity** (Section 3): We prove that the quantum mechanical shell capacity 2n² is a direct consequence of the sum 1 + 3 + 5 + ⋯ + (2n−1) = n², connecting atomic physics to ancient Greek mathematics.

2. **Well-foundedness of the Madelung order** (Section 4): We define the Madelung ordering on ℕ × ℕ and prove it is a well-order, establishing that the electron filling sequence is logically well-defined and explaining the period-doubling phenomenon.

3. **Nuclear magic numbers as binomial coefficients** (Section 5): We prove that cumulative harmonic oscillator shell closures equal C(N+3, 3), connecting nuclear physics to Pascal's triangle.

4. **Abstract periodic table framework** (Section 6): We define SpectralShellSystem, an abstract structure capturing periodic-table-like partitions, and prove a universality theorem showing every positive integer belongs to exactly one period.

## 2. Preliminaries

### 2.1 Notation

We work in ℕ (natural numbers including 0). For a function f : ℕ → ℕ, we write ∑_{k=0}^{n} f(k) for the Finset sum over range(n+1). The binomial coefficient C(n,k) is Nat.choose n k.

### 2.2 Quantum Mechanical Background

In the hydrogen atom, electron states are characterized by four quantum numbers:
- **Principal quantum number** n ∈ {1, 2, 3, ...}: determines the energy level
- **Azimuthal quantum number** l ∈ {0, 1, ..., n−1}: determines orbital angular momentum
- **Magnetic quantum number** m ∈ {−l, −l+1, ..., l}: determines spatial orientation
- **Spin quantum number** s ∈ {−1/2, +1/2}: determines spin orientation

The degeneracy of a subshell (n, l) — the number of distinct quantum states — is 2(2l+1), accounting for (2l+1) magnetic quantum numbers and 2 spin states.

## 3. Shell Degeneracy and the Sum of Odd Numbers

### Definition 3.1 (Orbital Degeneracy)
For l ∈ ℕ, define orbitalDegeneracy(l) = 2(2l + 1).

### Theorem 3.2 (Sum of Odd Numbers)
For all n ∈ ℕ, ∑_{k=0}^{n-1} (2k + 1) = n².

*Proof sketch*: By induction on n. The base case n = 0 is trivial. For the inductive step, ∑_{k=0}^{n} (2k+1) = n² + (2n+1) = (n+1)². □

### Theorem 3.3 (Shell Degeneracy)
For all n ∈ ℕ, ∑_{l=0}^{n-1} orbitalDegeneracy(l) = 2n².

*Proof sketch*: Factor out 2: ∑ 2(2l+1) = 2 · ∑ (2l+1) = 2n² by Theorem 3.2. □

### Remark 3.4
The connection to SO(3) representation theory is immediate: so3IrrepDim(l) = 2l+1 is the dimension of the l-th irreducible representation, and ∑_{l=0}^{n-1} so3IrrepDim(l) = n² is a combinatorial shadow of the Clebsch-Gordan decomposition.

## 4. The Madelung Order

### Definition 4.1 (Madelung Order)
Define MadelungLt on ℕ × ℕ by:
(a₁, b₁) <_M (a₂, b₂) ⟺ a₁+b₁ < a₂+b₂ ∨ (a₁+b₁ = a₂+b₂ ∧ a₁ < a₂).

### Theorem 4.2 (Irreflexivity)
MadelungLt is irreflexive: ¬(p <_M p) for all p.

### Theorem 4.3 (Transitivity)
MadelungLt is transitive.

*Proof sketch*: Case analysis on the four combinations of disjuncts. In each case, the conclusion follows from transitivity of < and = on ℕ. □

### Theorem 4.4 (Trichotomy)
For any a, b ∈ ℕ × ℕ, exactly one of a <_M b, a = b, or b <_M a holds.

### Theorem 4.5 (Well-foundedness)
MadelungLt is well-founded.

*Proof sketch*: The key insight is that MadelungLt is isomorphic to the lexicographic order on (a+b, a), which is a sub-relation of the well-founded lexicographic order on ℕ × ℕ. Given any nonempty set S, we first find an element minimizing the sum a+b (using well-foundedness of ℕ), then among elements with minimal sum, we find one minimizing the first component. This element is minimal in S under MadelungLt.

The well-foundedness proof is the most technically demanding result in this section, requiring careful use of the minimum principle for finite subsets of ℕ. □

### Corollary 4.6 (Period Doubling)
The Madelung ordering produces period lengths that appear in doubled pairs: 2, 8, 8, 18, 18, 32, 32, ... This follows from the structure of Madelung groups (subshells with the same value of n+l).

## 5. Harmonic Oscillator Magic Numbers

### Definition 5.1 (HO Degeneracy)
For N ∈ ℕ, define hoDegeneracy(N) = (N+1)(N+2)/2.

### Theorem 5.2 (HO Degeneracy as Binomial Coefficient)
hoDegeneracy(N) = C(N+2, 2).

### Theorem 5.3 (Cumulative HO Formula)
∑_{k=0}^{N} hoDegeneracy(k) = C(N+3, 3).

*Proof sketch*: By induction on N. Base: hoDegeneracy(0) = 1 = C(3,3). Inductive step: C(N+3,3) + C(N+3,2) = C(N+4,3) by Pascal's rule. □

### Theorem 5.4 (Choose-Three Formula)
6 · C(N+3, 3) = (N+1)(N+2)(N+3).

### Corollary 5.5 (First Magic Numbers)
The cumulative orbital states at N = 0, 1, 2, 3 are 1, 4, 10, 20. Doubling for spin gives 2, 8, 20, 40, matching the first three nuclear magic numbers.

## 6. Abstract Spectral Shell Systems

### Definition 6.1 (SpectralShellSystem)
A SpectralShellSystem is a structure (multiplicity, mult_pos) where:
- multiplicity : ℕ → ℕ assigns a positive capacity to each shell
- mult_pos : ∀ n, 0 < multiplicity(n)

### Definition 6.2 (Cumulative Function)
For a SpectralShellSystem S, define S.cumulative(n) = ∑_{k=0}^{n} S.multiplicity(k).

### Theorem 6.3 (Strict Monotonicity)
The cumulative function of any SpectralShellSystem is strictly monotone.

*Proof*: cumulative(n+1) = cumulative(n) + multiplicity(n+1) > cumulative(n) since multiplicity(n+1) > 0. □

### Theorem 6.4 (Period Uniqueness — Universality Theorem)
For any SpectralShellSystem S and any z > 0, there exists a unique n such that either:
- n = 0 and z ≤ S.cumulative(0), or
- n > 0 and S.cumulative(n−1) < z ≤ S.cumulative(n).

*Proof sketch*: Existence follows from the fact that cumulative(n) → ∞ (since each term is positive), so eventually z ≤ cumulative(n). Uniqueness follows from strict monotonicity: if two indices n₁ < n₂ both satisfy the condition, then cumulative(n₁) ≥ z > cumulative(n₂−1) ≥ cumulative(n₁), a contradiction. □

### Example 6.5
The electronic periodic table is a SpectralShellSystem with multiplicity(n) = 2(n+1)². Its cumulative function satisfies cumulative(n) = ∑_{k=0}^{n} 2(k+1)².

## 7. Algorithms

### Algorithm 7.1: Madelung Filling Order Enumeration
```
Input: Maximum atomic number Z
Output: Ordered list of subshells (n, l) in Madelung filling order

1. Generate all (n, l) pairs with 1 ≤ n, 0 ≤ l ≤ n-1, n+l ≤ ceil(sqrt(2Z))
2. Sort by (n+l, n) lexicographically
3. Enumerate subshells, accumulating 2(2l+1) electrons per subshell
4. Stop when cumulative count reaches Z
```

### Algorithm 7.2: Magic Number Computation
```
Input: Maximum shell number N_max
Output: List of magic numbers (harmonic oscillator approximation)

1. For N = 0, 1, ..., N_max:
   a. Compute deg(N) = (N+1)(N+2)/2
   b. Compute spin_deg(N) = (N+1)(N+2)  [doubling for spin]
   c. Accumulate cumulative(N) = sum of spin_deg(k) for k = 0 to N
2. Return list of cumulative values
```

## 8. Discussion

### 8.1 Cross-domain Connections

The results in this paper reveal deep connections across mathematical domains:

- **Number theory ↔ Quantum mechanics**: The Pythagorean sum-of-odd-numbers identity directly produces atomic shell capacities.
- **Order theory ↔ Chemistry**: Well-foundedness of the Madelung order ensures the aufbau principle is logically consistent.
- **Combinatorics ↔ Nuclear physics**: Binomial coefficients govern nuclear magic numbers through harmonic oscillator degeneracies.
- **Abstract algebra ↔ Periodic structure**: The SpectralShellSystem framework shows that periodic table-like partitions arise from any sequence of positive multiplicities.

### 8.2 Open Problems

The most significant open problem is *deriving* the Madelung rule from first principles. While the rule is empirically valid for most elements, it has never been proven from the Schrödinger equation. A formal derivation would require showing that for a screened Coulomb potential with monotonically decreasing effective nuclear charge, the single-particle eigenvalues satisfy the (n+l, n) ordering.

### 8.3 Relation to Spectral Theory

The SpectralShellSystem framework is a discrete analogue of continuous spectral theory. The cumulative function plays the role of a spectral counting function, and the strict monotonicity theorem is analogous to the Weyl asymptotic law. Connecting this discrete framework to continuous spectral theory (particularly the spectral gaps studied in Lorentzian geometry) is a promising direction.

## 9. Conclusion

We have established formally verified mathematical foundations for the periodic table's structure, connecting quantum mechanics to classical number theory through the Pythagorean identity, combinatorics through binomial coefficients, and order theory through well-foundedness. The abstract SpectralShellSystem framework reveals that periodic structure is a general mathematical phenomenon arising whenever positive multiplicities accumulate.

## References

1. Madelung, E. (1936). *Die mathematischen Hilfsmittel des Physikers*. Springer.
2. Klechkovskii, V.M. (1962). "On the first part of the periodic table of D.I. Mendeleev." *Doklady Akademii Nauk SSSR* 145, 1301–1304.
3. Goeppert Mayer, M. (1950). "Nuclear configurations in the spin-orbit coupling model." *Physical Review* 78, 16–21.
4. Allen, L.C. & Knight, E.T. (2002). "The Löwdin challenge: Origin of the n+l, n (Madelung) rule for filling the orbital configurations of the periodic table." *International Journal of Quantum Chemistry* 90, 80–88.
