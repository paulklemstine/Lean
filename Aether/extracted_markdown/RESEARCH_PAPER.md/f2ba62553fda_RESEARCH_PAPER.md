# Spectral Counting Theory for Quantum Shell Systems: From Madelung Diagonals to Weyl's Law

## Abstract

We develop a spectral counting theory for quantum shell systems, establishing a rigorous mathematical framework that connects the combinatorial structure of the periodic table to spectral theory. We introduce the **spectral staircase** — an abstract structure encoding discrete counting functions with positive jumps — and prove a discrete inverse spectral theorem: the staircase function uniquely determines the underlying multiplicity sequence. For the electronic shell system, we establish the closed-form Madelung cumulative formula, cubic Weyl-type bounds, strict gap monotonicity, and a gap ratio stability theorem. We also prove that the harmonic oscillator staircase has cumulative value 2·C(N+3,3) and is dominated by the electronic staircase from the first shell onward, reflecting the enhanced symmetry of the Coulomb potential.

**Keywords**: spectral counting function, quantum shell structure, Madelung rule, Weyl's law, inverse spectral problem, periodic table

## 1. Introduction

The periodic table of elements exhibits a remarkably structured pattern: periods of length 2, 8, 8, 18, 18, 32, 32, ... governed by the quantum mechanical shell-filling rules. The mathematical foundation of this pattern rests on three pillars:

1. **The sum-of-odd-numbers identity**: Σ_{l=0}^{n-1}(2l+1) = n², giving shell degeneracy 2n².
2. **The Madelung ordering**: Subshells fill in order of (n+l, n), a well-founded total order on ℕ×ℕ.
3. **Cumulative formulas**: The total electron count through shell N admits closed-form expressions involving binomial coefficients and polynomial formulas.

While each of these facts is well-known individually, their unification through the lens of spectral theory reveals deeper structure. In this paper, we develop this connection systematically.

### 1.1 Main Contributions

- **Diagonal capacity theorem** (Theorem 3.1): Each Madelung diagonal N has total capacity 2(N+1)², directly from the Pythagorean sum-of-odd-numbers identity.
- **Cumulative formula** (Theorem 4.1): The Madelung cumulative satisfies 3·C(N) = (N+1)(N+2)(2N+3).
- **Weyl-type bounds** (Theorems 4.2–4.3): Cubic bounds 2(N+1)³/3 ≤ C(N) < (N+2)³.
- **Spectral staircase** (Definition 5.1): Abstract structure capturing discrete spectral counting functions.
- **Discrete inverse spectral theorem** (Theorem 5.5): The staircase function uniquely determines all multiplicities.
- **Dominance comparison** (Theorem 6.1): The electronic staircase dominates the harmonic oscillator staircase for N ≥ 1.
- **Gap ratio stability** (Theorem 7.1): Consecutive gap ratios for the electronic system converge to 1.

All results are formally verified with no unproven assumptions beyond the standard axioms of mathematics.

## 2. Preliminaries

### 2.1 The Madelung Order

The **Madelung order** on ℕ × ℕ is defined by:

(a₁, b₁) ≺ (a₂, b₂) ⟺ a₁+b₁ < a₂+b₂, or (a₁+b₁ = a₂+b₂ and a₁ < a₂)

This is a well-founded total order (previously established). The level sets {(a,b) : a+b = N} are the **Madelung diagonals**. Each diagonal N contains N+1 pairs: (0,N), (1,N-1), ..., (N,0).

### 2.2 Orbital Degeneracy

The orbital degeneracy of a subshell with azimuthal quantum number l is 2(2l+1): there are (2l+1) magnetic substates and 2 spin states. For a pair (n,l) on diagonal N (so n+l = N), the degeneracy is 2(2l+1).

## 3. Diagonal Capacity

**Definition 3.1** (Diagonal Capacity). For N ∈ ℕ:
```
diagonalCapacity(N) = Σ_{l=0}^{N} 2(2l+1)
```

**Theorem 3.1** (Diagonal Capacity Formula). *For all N ∈ ℕ:*
```
diagonalCapacity(N) = 2(N+1)²
```

*Proof sketch.* Factor out 2: diagonalCapacity(N) = 2·Σ_{l=0}^{N}(2l+1). By the classical sum-of-odd-numbers identity Σ_{l=0}^{N}(2l+1) = (N+1)², the result follows. □

This theorem bridges the Pythagorean identity to atomic physics: the reason diagonal N contributes 2(N+1)² states is precisely because the first N+1 odd numbers sum to (N+1)².

## 4. Cumulative Formula and Weyl Bounds

**Definition 4.1** (Madelung Cumulative). For N ∈ ℕ:
```
madelungCumulative(N) = Σ_{k=0}^{N} 2(k+1)²
```

**Theorem 4.1** (Cumulative Closed Form). *For all N ∈ ℕ:*
```
3 · madelungCumulative(N) = (N+1)(N+2)(2N+3)
```

*Proof sketch.* By induction on N. The base case is 3·2 = 1·2·3 = 6. For the inductive step, 3·(C(N) + 2(N+2)²) = (N+1)(N+2)(2N+3) + 6(N+2)², and algebraic manipulation yields (N+2)(N+3)(2N+5). □

**Theorem 4.2** (Cubic Lower Bound). *For all N ∈ ℕ:*
```
3 · madelungCumulative(N) ≥ 2(N+1)³
```

*Proof sketch.* By Theorem 4.1, we need (N+1)(N+2)(2N+3) ≥ 2(N+1)³, i.e., (N+2)(2N+3) ≥ 2(N+1)². Expanding: 2N²+7N+6 ≥ 2N²+4N+2, which reduces to 3N+4 ≥ 0. □

**Theorem 4.3** (Cubic Upper Bound). *For all N ∈ ℕ:*
```
madelungCumulative(N) < (N+2)³
```

*Proof sketch.* We need (N+1)(N+2)(2N+3)/3 < (N+2)³, i.e., (N+1)(2N+3) < 3(N+2)². Expanding: 2N²+5N+3 < 3N²+12N+12, which reduces to N²+7N+9 > 0. □

The cubic bounds together establish that the "Weyl exponent" of the Madelung cumulative is 3, reflecting the three-dimensional nature of the underlying quantum system.

## 5. Spectral Staircases

### 5.1 Definition

**Definition 5.1** (Spectral Staircase). A spectral staircase S consists of:
- A sequence of **jumps** (multiplicities) jump : ℕ → ℕ
- A positivity constraint: jump(n) > 0 for all n

The **value** (counting function) of S at step n is:
```
value(n) = Σ_{k=0}^{n} jump(k)
```

### 5.2 Basic Properties

**Theorem 5.1** (Recurrence). *value(n+1) = value(n) + jump(n+1).*

**Theorem 5.2** (Strict Monotonicity). *The value function of any spectral staircase is strictly increasing.*

*Proof.* By Theorem 5.1, value(n+1) - value(n) = jump(n+1) > 0. □

**Theorem 5.3** (Lower Bound). *value(n) ≥ n+1 for all n.*

*Proof.* Each of the n+1 terms in the sum contributes at least 1. □

### 5.3 The Inverse Spectral Theorem

**Theorem 5.4** (Gap Recovery). *For all n: jump(n+1) = value(n+1) - value(n).*

**Theorem 5.5** (Discrete Inverse Spectral Theorem). *If two spectral staircases S₁ and S₂ satisfy value₁ = value₂, then jump₁ = jump₂.*

*Proof.* By induction on n. For n = 0: jump₁(0) = value₁(0) = value₂(0) = jump₂(0). For n+1: jump₁(n+1) = value₁(n+1) - value₁(n) = value₂(n+1) - value₂(n) = jump₂(n+1), using Theorem 5.4. □

This result is the discrete analogue of the famous "Can you hear the shape of a drum?" question. In the discrete setting, the answer is an unqualified yes.

## 6. Electronic and Harmonic Oscillator Staircases

### 6.1 Definitions

The **electronic staircase** has jump(n) = 2(n+1)².
The **harmonic oscillator staircase** has jump(n) = (n+1)(n+2).

### 6.2 Dominance

**Theorem 6.1** (Electronic Dominance). *For all n ≥ 1: (n+1)(n+2) ≤ 2(n+1)².*

*Proof.* Divide by (n+1): n+2 ≤ 2(n+1) = 2n+2, which holds for all n ≥ 0. □

**Theorem 6.2** (Dominance Implies Value Ordering). *If S₁ dominates S₂ (all jumps of S₁ ≥ corresponding jumps of S₂), then value₁(n) ≥ value₂(n) for all n.*

*Proof.* Direct from the monotonicity of finite sums. □

### 6.3 Harmonic Oscillator Binomial Identity

**Theorem 6.3**. *The harmonic oscillator cumulative with spin satisfies:*
```
hoStaircase.value(N) = 2 · C(N+3, 3)
```

*Proof sketch.* By induction using the identity C(N+4,3) = C(N+3,3) + C(N+3,2) and the fact that C(N+3,2) = (N+2)(N+3)/2 = hoShellDegeneracy(N+1)/2. □

## 7. Quadratic Growth and Gap Stability

### 7.1 Growth Classification

**Definition 7.1**. A staircase has **quadratic growth** with constants (c₁, c₂) if 0 < c₁ ≤ c₂ and c₁(n+1)² ≤ jump(n) ≤ c₂(n+1)² for all n.

**Theorem 7.1**. *The electronic staircase has exact quadratic growth with c₁ = c₂ = 2.*

**Theorem 7.2**. *Any staircase with quadratic growth satisfies value(N) ≥ c₁(N+1)².*

### 7.2 Gap Ratio Stability

**Theorem 7.3** (Gap Ratio Bound). *For the electronic staircase:*
```
jump(n+1) · (n+1)² ≤ jump(n) · (n+2)²
```

*Proof.* Both sides equal 2(n+1)²(n+2)². □

This means the ratio jump(n+1)/jump(n) = ((n+2)/(n+1))² → 1, establishing that consecutive gaps grow at asymptotically the same rate.

## 8. Discussion

### 8.1 The Weyl Exponent

The cubic bounds on the Madelung cumulative establish that its Weyl exponent is 3. This is consistent with Weyl's law for the eigenvalue counting function of the Laplacian on a 3-dimensional domain, where N(λ) ~ C·λ^{3/2}. The connection is not merely analogical: the hydrogen atom's energy levels are eigenvalues of the Laplacian (plus Coulomb potential) on ℝ³, and the shell multiplicities are precisely the eigenvalue multiplicities.

### 8.2 Beyond Hydrogen: Screening Effects

Real atoms don't have hydrogen-like degeneracy. Electron-electron repulsion "screens" the nuclear charge, breaking the SO(4) symmetry and splitting the l-degeneracy within each n-shell. The Madelung rule (filling by n+l, then by n) is an empirical observation about how this screening modifies the filling order.

A major open question is whether the Madelung rule can be derived from first principles — specifically, from the spectral theory of the screened Coulomb Hamiltonian. Our framework provides the order-theoretic foundation; what remains is connecting it to the spectrum of specific operators.

### 8.3 Connections to Graph Spectral Theory

The spectral staircase framework applies equally to graph eigenvalue counting. For a d-regular graph on n vertices, the spectral counting function N(λ) = #{i : λᵢ ≤ λ} is a staircase with jumps equal to eigenvalue multiplicities. The gap stability results for the electronic staircase have analogues in graph spectral theory, where eigenvalue gap ratios govern mixing time bounds for random walks.

## 9. Future Work

1. **Deriving the Madelung rule from screened Coulomb spectra** — connecting the abstract ordering to physical Hamiltonians.
2. **Non-integer Weyl exponents** — characterizing staircases with polynomial growth of non-integer degree, relevant to fractal-dimensional quantum systems.
3. **Spectral rigidity for perturbed staircases** — quantifying how perturbations of the jump sequence affect the counting function, connecting to perturbation theory.

## References

1. Weyl, H. "Über die asymptotische Verteilung der Eigenwerte." *Nachr. Ges. Wiss. Göttingen* (1911), 110–117.
2. Madelung, E. *Die mathematischen Hilfsmittel des Physikers.* Springer, 1936.
3. Pauli, W. "Über das Wasserstoffspektrum vom Standpunkt der neuen Quantenmechanik." *Z. Physik* 36 (1926), 336–363.
4. Kac, M. "Can one hear the shape of a drum?" *Amer. Math. Monthly* 73 (1966), 1–23.
5. Allen, L. C. and Knight, E. T. "The Löwdin challenge: Origin of the n+l, n (Madelung) rule for filling the orbital configurations of the periodic table." *Int. J. Quantum Chem.* 90 (2002), 80–88.
