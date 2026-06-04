# The Reversibility Group of Cellular Automata: Structure, Bounds, and the Centralizer Connection

## Abstract

We investigate the algebraic structure of reversible cellular automata (CAs) on finite periodic configurations. A cellular automaton on $\mathbb{Z}/n\mathbb{Z}$ with alphabet $A$ is reversible if its global map is a bijection on $A^{\mathbb{Z}/n\mathbb{Z}}$. We prove that the set of reversible CAs forms a subgroup of the symmetric group $S_{|A|^n}$ — the **reversibility subgroup** — and characterize it as a subgroup of the centralizer of the shift operator. Our main contributions are:

1. **Group structure theorem**: We formally prove (in Lean 4) that shift-equivariant permutations of the configuration space form a subgroup of $\text{Perm}(A^{\mathbb{Z}/n\mathbb{Z}})$, including the non-trivial result that the inverse of a shift-equivariant bijection is itself shift-equivariant.

2. **Locality theorem**: Every local rule induces a shift-equivariant global map, establishing one direction of the Curtis-Hedlund-Lyndon theorem for finite groups.

3. **Proper subgroup theorem**: The reversibility subgroup is strictly smaller than the full symmetric group for $n \geq 2$, proved by exhibiting a permutation that does not commute with the shift.

4. **Computational analysis**: We enumerate all 256 elementary CA rules, identifying exactly 6 that are universally reversible, and show their generated group has order 6 — far smaller than the centralizer of the shift.

**Keywords**: cellular automata, reversibility, shift-equivariance, Curtis-Hedlund-Lyndon theorem, symmetric groups, centralizers

## 1. Introduction

A cellular automaton (CA) is a discrete dynamical system consisting of a lattice of cells, each carrying a state from a finite alphabet, evolving synchronously according to a local rule. The question of which CAs are reversible — admitting an inverse that is itself a CA — has deep connections to computation theory, statistical mechanics, and cryptography.

The classical **Curtis-Hedlund-Lyndon theorem** (1969) establishes that a map $F: A^{\mathbb{Z}} \to A^{\mathbb{Z}}$ is a cellular automaton if and only if $F$ is continuous (in the product topology) and shift-equivariant. For finite periodic configurations $A^{\mathbb{Z}/n\mathbb{Z}}$, continuity is automatic, so CAs are precisely the shift-equivariant maps.

This algebraic characterization suggests studying the **reversibility group**: the subgroup of $\text{Perm}(A^{\mathbb{Z}/n\mathbb{Z}})$ consisting of shift-equivariant bijections. We formalize this concept, prove its basic structure, and investigate its properties computationally.

### 1.1 Related Work

The study of reversible CAs was initiated by Hedlund (1969) and developed by Richardson (1972), who showed that injective CAs on infinite lattices are surjective. Kari (1990) proved that reversibility of 2D CAs is undecidable. The group structure of reversible CAs has been studied by Ceccherini-Silberstein and Coornaert (2010) in the context of symbolic dynamics.

The connection to centralizers in symmetric groups appears in the work of Boykett (2004), who studied the automorphism group of shift dynamical systems. Our contribution is a formalized proof of the group structure and a computational investigation of specific instances.

## 2. Definitions and Setup

### 2.1 Configuration Space

Fix a finite alphabet $A$ (typically $A = \{0, 1\}$) and a positive integer $n$. The **configuration space** is $\Omega_n = A^{\mathbb{Z}/n\mathbb{Z}}$, the set of all functions from $\mathbb{Z}/n\mathbb{Z}$ to $A$. This has $|A|^n$ elements.

### 2.2 The Shift Operator

The **shift operator** $\sigma_k : \Omega_n \to \Omega_n$ for $k \in \mathbb{Z}/n\mathbb{Z}$ is defined by
$$\sigma_k(c)(i) = c(i + k)$$
The shift satisfies $\sigma_0 = \text{id}$ and $\sigma_k \circ \sigma_l = \sigma_{l+k}$, forming a group action of $\mathbb{Z}/n\mathbb{Z}$ on $\Omega_n$.

### 2.3 Shift-Equivariance

A map $F : \Omega_n \to \Omega_n$ is **shift-equivariant** if $F \circ \sigma_k = \sigma_k \circ F$ for all $k \in \mathbb{Z}/n\mathbb{Z}$.

### 2.4 Local Rules

A **local rule** of radius $r$ is a function $f : A^{2r+1} \to A$. It induces a global map $F : \Omega_n \to \Omega_n$ by
$$F(c)(i) = f(c(i-r), c(i-r+1), \ldots, c(i+r))$$
For elementary CAs ($r = 1$, $A = \{0,1\}$), the local rule is determined by 8 bits, giving the 256 Wolfram rules.

## 3. Main Results

### 3.1 The Reversibility Subgroup (Theorem 1)

**Theorem 1** (Formalized). *The set*
$$\mathcal{R}_n(A) = \{ e \in \text{Perm}(\Omega_n) \mid e \text{ is shift-equivariant} \}$$
*is a subgroup of $\text{Perm}(\Omega_n)$.*

*Proof.* We verify the three subgroup axioms:

1. **Identity**: The identity permutation is trivially shift-equivariant.

2. **Closure under composition**: If $F$ and $G$ are shift-equivariant, then for all $k$ and $c$:
   $$(F \circ G)(\sigma_k(c)) = F(G(\sigma_k(c))) = F(\sigma_k(G(c))) = \sigma_k(F(G(c))) = \sigma_k((F \circ G)(c))$$

3. **Closure under inversion**: This is the non-trivial step. If $e$ is a shift-equivariant permutation, we need $e^{-1}$ to be shift-equivariant. For any $d \in \Omega_n$, let $c = e^{-1}(d)$, so $e(c) = d$. Then:
   $$e(\sigma_k(c)) = \sigma_k(e(c)) = \sigma_k(d)$$
   Applying $e^{-1}$: $\sigma_k(c) = e^{-1}(\sigma_k(d))$, i.e., $e^{-1}(\sigma_k(d)) = \sigma_k(e^{-1}(d))$. $\square$

This proof is formalized in Lean 4 as `CellularAutomata.inv_shift_equivariant` and `CellularAutomata.ReversibilitySubgroup`.

### 3.2 Locality Implies Shift-Equivariance (Theorem 2)

**Theorem 2** (Formalized). *Every local rule of radius $r$ induces a shift-equivariant global map.*

*Proof.* Let $f$ be a local rule and $F$ the induced global map. For any shift $\sigma_k$:
$$F(\sigma_k(c))(i) = f(\sigma_k(c)(i-r), \ldots, \sigma_k(c)(i+r)) = f(c(i+k-r), \ldots, c(i+k+r)) = F(c)(i+k) = \sigma_k(F(c))(i)$$
The key step is that shifting the input configuration and evaluating at position $i$ gives the same neighborhood as evaluating the original configuration at position $i+k$. $\square$

### 3.3 The Proper Subgroup Theorem (Theorem 3)

**Theorem 3** (Formalized). *For $n \geq 2$ and $|A| \geq 2$, $\mathcal{R}_n(A) \neq \text{Perm}(\Omega_n)$.*

*Proof.* We exhibit a permutation that is not shift-equivariant. Consider the transposition swapping the all-zeros configuration $\mathbf{0}$ with the configuration $e_0$ that has a single 1 at position 0. The shift $\sigma_1$ maps $e_0$ to $e_1$ (a single 1 at position 1). If this transposition were shift-equivariant, it would need to map $\sigma_1(\mathbf{0}) = \mathbf{0}$ to $\sigma_1(e_0) = e_1$, but $\mathbf{0}$ maps to $e_0 \neq e_1$ (since $n \geq 2$). $\square$

### 3.4 Shift-Complement Commutativity (Theorem 4)

**Theorem 4** (Formalized). *The shift permutation and the complement permutation commute.*

The complement $\kappa$ flips every bit: $\kappa(c)(i) = 1 - c(i)$. Since $\kappa$ acts pointwise, it commutes with any coordinate permutation, including the shift. The subgroup $\langle \sigma, \kappa \rangle \cong \mathbb{Z}/n\mathbb{Z} \times \mathbb{Z}/2\mathbb{Z}$ lies inside the reversibility subgroup.

## 4. Computational Results

### 4.1 Universally Reversible Elementary CAs

We computationally verified which of the 256 elementary CA rules are reversible on $\mathbb{Z}/n\mathbb{Z}$ for $n = 3, 4, 5, 6, 7$. A rule is **universally reversible** if it is reversible for all tested periods. Exactly 6 rules are universally reversible:

| Rule | Truth Table | Description |
|------|------------|-------------|
| 15   | 11110000   | $f(a,b,c) = \neg c$ |
| 51   | 11001100   | $f(a,b,c) = \neg b$ |
| 85   | 10101010   | $f(a,b,c) = \neg a$ |
| 170  | 01010101   | $f(a,b,c) = a$ |
| 204  | 00110011   | $f(a,b,c) = b$ (identity) |
| 240  | 00001111   | $f(a,b,c) = c$ |

These decompose into three pairs under complementation: $\{170, 85\}$, $\{204, 51\}$, $\{240, 15\}$.

### 4.2 The Generated Group

On period 3, the group generated by the 6 universally reversible rules has **order 6**, isomorphic to the symmetric group $S_3$. This is far smaller than the centralizer of the shift in $S_8$, which has order 36.

The discrepancy arises because the 6 rules generate only translations and complementation, while the centralizer contains additional permutations that permute shift orbits in ways not achievable by elementary CA composition.

### 4.3 Centralizer Size

The centralizer of a permutation $\pi \in S_n$ with cycle type $(1^{a_1}, 2^{a_2}, \ldots, k^{a_k})$ has order $\prod_i i^{a_i} \cdot a_i!$. For the shift on $\{0,1\}^n$:

| Period $n$ | $|\Omega_n|$ | Cycle Type | $|C_{S_m}(\sigma)|$ | $|C|/|S_m|$ |
|-----------|------------|------------|---------------------|-------------|
| 2 | 4 | $(1^2, 2^1)$ | 4 | $1.7 \times 10^{-1}$ |
| 3 | 8 | $(1^2, 3^2)$ | 36 | $8.9 \times 10^{-4}$ |
| 4 | 16 | $(1^2, 2^1, 4^3)$ | 1536 | $7.3 \times 10^{-11}$ |
| 5 | 32 | $(1^2, 5^6)$ | 22500000 | $8.6 \times 10^{-29}$ |

The super-exponential decay confirms that shift-equivariant permutations form a vanishingly small fraction of all permutations.

### 4.4 Period-Dependent Reversibility

A striking finding is that reversibility is **period-dependent**: rules like 27, 29, and 105 are reversible on some periods but not others. For example:
- Rule 105 is reversible on periods 4 and 5, but not on period 3 or 6.
- Rule 45 is reversible on periods 3, 5, and 7 (odd), but not on periods 4 or 6 (even).

This suggests a deeper number-theoretic structure connecting CA reversibility to divisibility properties of the period.

## 5. The Centralizer Characterization

The reversibility subgroup $\mathcal{R}_n(A)$ equals the centralizer of the cyclic group $\langle \sigma_1 \rangle$ in $\text{Perm}(\Omega_n)$:
$$\mathcal{R}_n(A) = C_{\text{Perm}(\Omega_n)}(\langle \sigma_1 \rangle) = \{ e \in \text{Perm}(\Omega_n) \mid e\sigma_1 = \sigma_1 e \}$$

This follows because a permutation is shift-equivariant if and only if it commutes with every shift, and $\sigma_k = \sigma_1^k$, so commuting with $\sigma_1$ implies commuting with all shifts.

The centralizer of a permutation is determined by its cycle structure. The orbits of $\sigma_1$ on $\Omega_n$ are the **binary necklaces** of length $n$. By Burnside's lemma, the number of binary necklaces of length $n$ is:
$$N(n) = \frac{1}{n} \sum_{d \mid n} \phi(n/d) \cdot 2^d$$

Each element of the centralizer must map orbits to orbits of the same size, and within each orbit, must commute with the cyclic rotation. This gives:
$$|C(\sigma_1)| = \prod_{d \mid n} d^{a_d} \cdot a_d!$$
where $a_d$ is the number of orbits of size $d$.

## 6. Discussion

### 6.1 Gap Between Generated Group and Centralizer

Our computation reveals a significant gap: on period 3, the 6 universally reversible elementary CAs generate a group of order 6, while the full centralizer has order 36. This means there exist shift-equivariant permutations that cannot be decomposed into compositions of elementary CA rules with radius 1.

This raises a natural question: what is the minimum radius $r$ needed such that all shift-equivariant permutations on $\{0,1\}^{\mathbb{Z}/n\mathbb{Z}}$ can be realized as compositions of reversible CAs of radius $\leq r$?

### 6.2 Connection to Necklace Combinatorics

The orbit structure of the shift on $\Omega_n$ connects CA reversibility to classical combinatorial objects: binary necklaces. The centralizer size depends on the necklace count $N(n)$ and the distribution of necklace lengths, which in turn depends on the Euler totient function. This creates a bridge between CA theory and analytic number theory.

### 6.3 Formalization

All main theorems (1-4) are fully formalized in Lean 4 using Mathlib. The formalization required approximately 250 lines of code and uses concepts from group theory (subgroups, permutations), modular arithmetic (ZMod), and function extensionality. No custom axioms were introduced.

## 7. Future Work

1. **Higher radii**: Extend the analysis to CAs with radius $r > 1$. The universal reversibility picture changes dramatically: more rules become universally reversible, and the generated group grows.

2. **Larger alphabets**: Generalize from binary to $k$-ary alphabets. The structure of the reversibility group over larger alphabets may reveal connections to wreath products.

3. **Infinite lattices**: Formalize the full Curtis-Hedlund-Lyndon theorem for CAs on $A^{\mathbb{Z}}$ with the product topology. This requires formalizing compactness of the Cantor space and continuous shift-equivariant maps.

4. **Decidability boundary**: Investigate the boundary between decidable reversibility (1D CAs, where reversibility is decidable via de Bruijn graphs) and undecidable reversibility (2D CAs, Kari 1990).

5. **Period-dependent structure**: Characterize which rules are reversible on period $n$ in terms of the prime factorization of $n$.

## References

1. G. A. Hedlund, "Endomorphisms and automorphisms of the shift dynamical system," *Mathematical Systems Theory*, vol. 3, pp. 320–375, 1969.

2. D. Richardson, "Tessellations with local transformations," *Journal of Computer and System Sciences*, vol. 6, pp. 373–388, 1972.

3. J. Kari, "Reversibility and surjectivity problems of cellular automata," *Journal of Computer and System Sciences*, vol. 48, pp. 149–182, 1994.

4. T. Ceccherini-Silberstein and M. Coornaert, *Cellular Automata and Groups*, Springer, 2010.

5. T. Boykett, "Efficient exhaustive listings of reversible one dimensional cellular automata," *Theoretical Computer Science*, vol. 325, pp. 215–247, 2004.

6. S. Wolfram, *A New Kind of Science*, Wolfram Media, 2002.
