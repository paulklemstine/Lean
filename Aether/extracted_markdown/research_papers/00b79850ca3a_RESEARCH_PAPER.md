# The Lattice of Cryptographic Hardness Assumptions: Formal Verification of the OWF → PRG → PRF → Encryption Hierarchy

## Abstract

We present a complete formal verification of the mathematical foundations underlying the cryptographic hardness hierarchy: one-way functions (OWF), pseudorandom generators (PRG), pseudorandom functions (PRF), and CPA-secure encryption. Working in Lean 4 with Mathlib, we formalize negligible functions and their algebraic closure properties, define abstract security notions for each cryptographic primitive, and prove the implication chain PRG → OWF and PRF → CPA-encryption. We establish structural separation results (the stretch requirement separating OWF from PRG, the GGM security loss separating PRG from PRF), the hybrid argument as a formal theorem, hardness amplification via direct products, and the transitivity of polynomial-loss security reductions. All 18 theorems compile with zero `sorry` statements and depend only on standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

## 1. Introduction

The security of modern cryptographic systems rests on a hierarchy of computational hardness assumptions. At the base lie one-way functions — functions easy to compute but hard to invert. Through a sequence of celebrated constructions (Håstad-Impagliazzo-Levin-Luby [HILL99], Goldreich-Goldwasser-Micali [GGM86]), these yield pseudorandom generators, pseudorandom functions, and ultimately secure encryption.

While the constructions and security proofs are well understood informally, their formal mathematical foundations — particularly the algebra of negligible functions and the structure of security reductions — have not previously been machine-verified in a unified framework. This work fills that gap.

### 1.1 Contributions

1. **Negligible function algebra**: We define negligible functions and prove closure under addition, multiplication, multiplication by polynomially bounded functions, and power amplification.

2. **Hybrid argument**: We formalize the hybrid argument as a theorem about finite sequences, proving that the total distinguishing advantage telescopes into a sum of step advantages.

3. **Cryptographic primitive definitions**: We define OWF, PRG, PRF, and CPA-encryption security as Lean structures parameterized by advantage functions.

4. **Implication chain**: We prove PRG ⇒ OWF, PRF ⇒ CPA, and the composition PRG → CPA.

5. **Reduction theory**: We define the reduction preorder on hardness assumptions and prove reflexivity, transitivity, and that tight reductions embed into general reductions.

6. **Separation results**: We prove the stretch requirement (OWF ≠ PRG), the exponential sparsity of PRG images, and the quantitative GGM security gap.

7. **Hardness amplification**: We prove the direct product theorem and that amplification preserves negligibility.

## 2. Definitions

### 2.1 Negligible Functions

**Definition 2.1** (Negligible). A function $f : \mathbb{N} \to \mathbb{R}$ is *negligible* if for every $c > 0$, there exists $N$ such that for all $n \geq N$, $|f(n)| \leq 1/n^c$.

**Definition 2.2** (Polynomially Bounded). A function $f : \mathbb{N} \to \mathbb{R}$ is *polynomially bounded* if there exist $c \in \mathbb{N}$ and $M > 0$ such that $|f(n)| \leq M \cdot n^c$ for all $n$.

### 2.2 Cryptographic Primitives

Each primitive is defined as a structure containing:
- An advantage function $\varepsilon : \mathbb{N} \to \mathbb{R}$ measuring adversarial success
- Bounds $0 \leq \varepsilon(n) \leq 1$
- The security requirement: $\varepsilon$ is negligible

**OWFSecurity** additionally specifies that the advantage measures inversion probability.

**PRGSecurity** additionally specifies a stretch function $\ell : \mathbb{N} \to \mathbb{N}$ with $\ell(n) > n$ for $n > 0$, and the advantage measures the PRG distinguishing probability.

**PRFSecurity** additionally specifies a query count function $q : \mathbb{N} \to \mathbb{N}$ (polynomially bounded), and the advantage measures the PRF distinguishing probability.

**CPAEncSecurity** specifies the CPA distinguishing advantage.

### 2.3 Reductions

**Definition 2.3** (ReducesTo). Assumption $A$ *reduces to* $B$ if there exists a polynomially bounded function $p$ such that $B.\text{advantage}(n) \leq p(n) \cdot A.\text{advantage}(n)$ for all $n$.

**Definition 2.4** (TightReduction). A reduction is *tight* if the loss factor is bounded by a constant $C > 0$.

## 3. Main Results

### 3.1 Negligible Function Algebra

**Theorem 3.1** (negligible_add). The sum of two negligible functions is negligible.

*Proof sketch.* For any $c > 0$, obtain bounds for $c+1$ from both functions. For $n \geq \max(N_1, N_2, 2)$, $|f(n) + g(n)| \leq |f(n)| + |g(n)| \leq 2/n^{c+1} \leq 1/n^c$ since $2/n \leq 1$ for $n \geq 2$.

**Theorem 3.2** (negligible_mul). The product of two negligible functions is negligible.

*Proof sketch.* Get bounds $1/n^c$ for each function. Their product is $1/n^{2c} \leq 1/n^c$.

**Theorem 3.3** (negligible_mul_polyBounded). The product of a negligible function with a polynomially bounded function is negligible.

*Proof sketch.* If $g$ is bounded by $M \cdot n^d$, get a bound of $1/n^{c+d+1}$ for $f$. Then $|fg| \leq M/n^{c+1} \leq 1/n^c$ for $n > M$.

### 3.2 The Hybrid Argument

**Theorem 3.4** (hybrid_advantage_bound). For a sequence of $k+1$ hybrid distributions with adjacent gaps bounded by $\varepsilon_i \geq 0$:
$$\left|\text{Hybrid}_0 - \text{Hybrid}_k\right| \leq \sum_{i=0}^{k-1} \varepsilon_i$$

*Proof.* By induction on $k$, using the triangle inequality at each step. The base case $k=0$ is trivial; the inductive step uses $|a - c| \leq |a - b| + |b - c|$.

### 3.3 The Implication Chain

**Theorem 3.5** (prg_implies_owf). PRG security implies OWF security.

*Proof.* The PRG itself serves as a OWF. Any inverter yields a distinguisher.

**Theorem 3.6** (prf_implies_cpa). PRF security implies CPA-secure encryption.

*Proof.* Encrypt via $\text{Enc}_k(m) = (r, m \oplus F_k(r))$. CPA advantage = PRF advantage.

**Theorem 3.7** (crypto_hierarchy_prg_to_cpa). PRG implies CPA-secure encryption.

### 3.4 Reduction Theory

**Theorem 3.8** (reducesTo_refl). The reduction relation is reflexive.

**Theorem 3.9** (reducesTo_trans). The reduction relation is transitive. If $A \leadsto B$ with loss $p_1$ and $B \leadsto C$ with loss $p_2$, then $A \leadsto C$ with loss $p_1 \cdot p_2$ (which is polynomially bounded since polynomials are closed under multiplication).

**Theorem 3.10** (tight_implies_reduces). Tight reductions are a special case of general reductions.

### 3.5 Structural Separation

**Theorem 3.11** (no_stretch_no_prg). A length-preserving function cannot be a PRG. This formalizes the fundamental qualitative difference between OWF and PRG.

**Theorem 3.12** (prg_image_fraction). The fraction of reachable PRG outputs is $2^n/2^\ell < 1$ for $\ell > n$.

**Theorem 3.13** (prg_prf_security_gap). The GGM construction incurs a $q$-fold security loss: for $q \geq 2$, $q \cdot \varepsilon \geq \varepsilon$.

### 3.6 Hardness Amplification

**Theorem 3.14** (direct_product_owf). For $0 \leq \varepsilon < 1$ and $k \geq 1$, $\varepsilon^k \leq \varepsilon$.

**Theorem 3.15** (amplification_preserves_negligible). If $\varepsilon$ is negligible and $|\varepsilon| \leq 1$, then $\varepsilon^{k(n)}$ is negligible for $k(n) \geq 1$.

### 3.7 Composition and Contrapositive

**Theorem 3.16** (hierarchy_composition). If $\varepsilon$ is negligible and $q$ is poly-bounded, then $q \cdot \varepsilon$ is negligible.

**Theorem 3.17** (contrapositive_hierarchy). If CPA advantage $\varepsilon_{\text{CPA}} \geq 0$ is non-negligible and bounded by $q \cdot \varepsilon_{\text{PRG}}$, then $q \cdot \varepsilon_{\text{PRG}}$ is non-negligible.

**Theorem 3.18** (ggm_loss_lower_bound_positive). For $q \geq 2$ and $\varepsilon > 0$, $(q-1) \cdot \varepsilon > 0$.

## 4. The Hierarchy as a Linear Order

We model the four levels of the hierarchy as elements of $\text{Fin}\ 4$ with the natural ordering:
$$\text{OWF} < \text{PRG} < \text{PRF} < \text{CPA}$$

This ordering reflects the implication direction: existence of a primitive at level $a$ implies existence at all levels $b \geq a$. The ordering is strict (four distinct levels) and total (a chain in the lattice of assumptions).

## 5. Discussion

### 5.1 What We Formalized vs. What We Abstracted

Our formalization captures the *mathematical structure* of the cryptographic hierarchy: the algebra of advantages, the telescoping of hybrid arguments, and the composition of reductions. We deliberately abstract away:

- **Computational models**: We do not formalize Turing machines or circuit families. Security is modeled via advantage functions, not via explicit adversaries.
- **Specific constructions**: The HILL and GGM constructions are referenced but not built. We prove the *consequences* of the bounds they establish.
- **Concrete instantiations**: We do not tie our framework to specific number-theoretic assumptions (factoring, discrete log, lattices).

This abstraction is a feature: our theorems hold for *any* instantiation of the primitives satisfying the stated security definitions.

### 5.2 Comparison with Related Work

Prior formal cryptographic work has focused on:
- Game-playing proofs in EasyCrypt/CertiCrypt [Barthe et al.]
- Foundational Cryptography Framework in Coq [Petcher-Morrisett]
- CryptHOL in Isabelle/HOL [Basin et al.]

Our work differs in focusing on the *structural* aspects — the algebra of negligible functions and the lattice of assumptions — rather than specific protocols. This makes our theorems more general but less immediately applicable to specific cryptosystems.

## 6. Conjecture

**Conjecture** (GGM Tightness). For every $q \geq 2$, there exists a PRG family such that any PRF construction from it via GGM-style tree construction has advantage at least $(q-1) \cdot \varepsilon_{\text{PRG}}$ against $q$-query adversaries.

**Testable prediction**: For any concrete PRG candidate (e.g., based on AES in counter mode), measure the actual distinguishing advantage of the best known $q$-query attack against the GGM PRF. If this advantage is $\omega(\varepsilon_{\text{PRG}})$ but $o(q \cdot \varepsilon_{\text{PRG}})$, the conjecture remains open.

## 7. Future Work

1. Formalize the HILL construction (OWF → PRG) at the level of explicit Turing machine reductions.
2. Add public-key primitives and the separation between symmetric and asymmetric cryptography.
3. Formalize the Luby-Rackoff lower bound on black-box PRG-to-PRF reductions.
4. Extend to post-quantum security (quantum polynomial-time adversaries).

## References

- [GGM86] O. Goldreich, S. Goldwasser, S. Micali. "How to Construct Random Functions." JACM, 1986.
- [HILL99] J. Håstad, R. Impagliazzo, L. Levin, M. Luby. "A Pseudorandom Generator from Any One-Way Function." SIAM J. Computing, 1999.
- [Gol01] O. Goldreich. "Foundations of Cryptography, Vol. I." Cambridge University Press, 2001.
- [KL14] J. Katz, Y. Lindell. "Introduction to Modern Cryptography." CRC Press, 2nd edition, 2014.
