# Future Directions: Cap Set Polynomial Method Formalization

## Overview

This document outlines concrete breakthrough research opportunities opened by the formalization of the Ellenberg–Gijswijt cap-set polynomial method infrastructure. Each direction is specific enough for a research team to pursue with clear hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Complete the Polynomial Expansion and Rank Decomposition

### Status
The current formalization proves the structural heart of the EG argument: the kernel matrix M(a,b) = Σ_c Δ(a+b+c) is the identity on any cap set A. The remaining gap is the polynomial expansion of this kernel into a bounded number of rank-1 matrix summands.

### Concrete Next Steps
1. **Formalize the monomial expansion of (1 − (x+y+z)²)^n over F₃**: This requires working with `MvPolynomial (Fin (3*n)) (ZMod 3)` and showing the expansion has specific monomial structure.
2. **Prove the three-variable degree classification**: Each monomial x^α·y^β·z^γ in the expansion satisfies |α|+|β|+|γ| ≤ 2n, and by the (already formalized) degree splitting lemma, min(|α|,|β|,|γ|) ≤ ⌊2n/3⌋.
3. **Formalize the matrix rank bound**: If M = Σ_{j=1}^r v_j · w_j^T, then rank(M) ≤ r. This is basic linear algebra but needs a clean Lean statement for matrices over ZMod 3.
4. **Connect the pieces**: The kernel matrix equals the identity (rank = |A|), and it decomposes into ≤ 3·D₀ rank-1 pieces, giving |A| ≤ 3·D₀.

### Hypothesis
The bottleneck is step 1 (polynomial expansion), not the linear algebra. A dedicated effort on multivariate polynomial manipulation over finite fields would break through.

### Cross-Domain Impact
This infrastructure would immediately enable formal slice-rank arguments, which are the foundation of the entire polynomial method in combinatorics.

---

## Direction 2: Extension from F₃ⁿ to F_pⁿ

### Status
The current development is specific to F₃. The Croot–Lev–Pach method generalizes to F_p for any prime p, with the indicator polynomial Δ(v) = ∏_i(1 − v_i^{p-1}).

### Concrete Next Steps
1. **Generalize `deltaIndicator` to `ZMod p`**: Replace the exponent 2 with p−1. The key identity becomes: over F_p, x^{p-1} = 0 iff x = 0, and x^{p-1} = 1 iff x ≠ 0 (Fermat's little theorem).
2. **Generalize the cap set definition**: Replace the three-element sum condition with a p-element progression-free condition.
3. **Generalize degree splitting**: Replace 2n/3 with (p-1)n/p in the degree bound.
4. **Prove the generalized monomial count bound**: |A| ≤ p · D_{(p-1)n/p} where monomials have individual degrees ≤ p−1.

### Hypothesis
The generalization is mostly straightforward once the F₃ case is fully formalized. The main challenge is making `decide` tactics work for general primes (they won't — need to use algebraic proofs instead of finite case analysis).

### Cross-Domain Impact
- **Coding theory**: Bounds on codes avoiding arithmetic progressions over F_p.
- **Additive combinatorics**: Formal bounds on Roth-type problems in finite fields.
- **Number theory**: Connections to Szemerédi-type results.

---

## Direction 3: Formal Slice-Rank Theory

### Status
The current development deliberately avoids tensors and slice rank. However, the matrix-rank approach we use is a shadow of the full slice-rank formalism.

### Concrete Next Steps
1. **Define tensors over finite fields**: Formalize k-tensors T : (F_q^n)^k → F_q as multilinear functions.
2. **Define slice rank**: The minimum number of "slices" (functions of the form f_i(x_j) · g_i(rest)) needed to decompose T.
3. **Prove the diagonal tensor lemma**: A tensor supported on the diagonal {(x,x,...,x)} has slice rank equal to |support|.
4. **Prove the slice-rank upper bound from monomial expansion**: This generalizes the matrix-rank argument.
5. **Derive the cap set bound as a corollary**.

### Hypothesis
A general slice-rank theory in Lean would be a major contribution to formal mathematics, enabling a whole family of polynomial method results (sunflower lemma, partition regularity, etc.).

### Cross-Domain Impact
- **Algebraic complexity**: Slice rank directly connects to tensor rank and matrix multiplication barriers.
- **Communication complexity**: Multiparty communication lower bounds via tensor methods.
- **Quantum information**: Entanglement rank and stabilizer formalism connections.

---

## Direction 4: Finite-Field Function Algebra Infrastructure

### Status
The current development uses `deltaIndicator` as a concrete function, not as an element of a formal polynomial algebra.

### Concrete Next Steps
1. **Formalize the quotient ring R_n = F_q[x_1,...,x_n]/(x_i^q − x_i)**: Show this is isomorphic to the ring of all functions (F_q)^n → F_q.
2. **Prove reduced monomials form a basis**: {x^α : 0 ≤ α_i ≤ q−1} is a vector space basis of R_n.
3. **Define the degree filtration**: R_n^{≤d} = span of monomials with |α| ≤ d.
4. **Prove dimension formulas**: dim(R_n^{≤d}) = |{α : 0 ≤ α_i ≤ q−1, |α| ≤ d}|.
5. **Connect evaluation to polynomial representation**: The evaluation map MvPolynomial → R_n is surjective with explicitly described kernel.

### Hypothesis
This infrastructure is the most impactful single investment. It would make ALL polynomial method arguments over finite fields dramatically easier to formalize.

### Cross-Domain Impact
- **Finite geometry**: Counting arguments in AG(n,q) and PG(n,q).
- **Coding theory**: Weight distribution bounds via polynomial methods.
- **Cryptography**: Formal analysis of algebraic attacks on symmetric ciphers.

---

## Direction 5: Computational Verification and Asymptotic Analysis

### Status
We have computed numLowDegMonomials for small n. The asymptotic behavior (showing the exponential base is strictly less than 3) has not been formalized.

### Concrete Next Steps
1. **Prove the generating function identity**: |{α ∈ {0,...,q-1}^n : |α| = k}| = [x^k](1 + x + ... + x^{q-1})^n.
2. **Prove the saddle-point asymptotic**: For d = ⌊2n/3⌋, the sum Σ_{k≤d} [x^k](1+x+x²)^n ~ C · c^n where c = 3 · (2/3)^{2/3} · (1/3)^{1/3} ≈ 2.756.
3. **Formalize the exponential bound**: 3 · D_{2n/3} ≤ C · (2.756)^n for some explicit constant C.
4. **Connect to cap set density**: |A|/3^n ≤ C · (2.756/3)^n → 0 exponentially.

### Hypothesis
The asymptotic analysis requires real analysis infrastructure (saddle-point method or Stirling bounds). The generating function identity is purely combinatorial and should be formalizable now.

### Cross-Domain Impact
- **Analytic combinatorics**: Formal saddle-point methods for coefficient extraction.
- **Information theory**: Entropy-based capacity arguments for constrained codes.

---

## Cross-Domain Bridge Theorems

### Bridge to Communication Complexity
The kernel matrix M(a,b) = δ_{a,b} on a cap set has a natural interpretation as a communication matrix. The monomial decomposition bounds the communication complexity of the equality function restricted to cap sets. Formalizing this connection would create a bridge between additive combinatorics and communication complexity.

### Bridge to Quantum Information
Reduced polynomial functions over F₃ⁿ are closely related to stabilizer states in quantum computation. The Kronecker delta polynomial Δ(v) = ∏(1−v_i²) resembles the discrete Wigner function of a stabilizer state. Formalizing this connection could enable formal bounds on magic state distillation and quantum contextuality.

### Bridge to Algebraic Complexity
The matrix rank decomposition M = Σ v_j ⊗ w_j is a special case of tensor decomposition. The degree-splitting argument is a precursor to barrier results in algebraic circuit complexity. A formal version could enable certified lower bounds for arithmetic circuits.

---

## Priority Ranking

1. **Direction 4** (Function algebra) — Highest long-term impact, enables everything else
2. **Direction 1** (Complete EG proof) — Most immediate, directly extends current work
3. **Direction 3** (Slice rank) — Highest mathematical value, opens entire polynomial method
4. **Direction 2** (General F_p) — Natural generalization, moderate effort
5. **Direction 5** (Asymptotics) — Important for applications, requires analysis infrastructure

---

## Team Directive

Create a research team with the following roles:
- **Polynomial algebra specialist**: Formalize the function algebra quotient (Direction 4)
- **Linear algebra specialist**: Formalize matrix/tensor rank bounds (Directions 1 & 3)
- **Combinatorics specialist**: Prove monomial counting identities and degree bounds (Direction 5)
- **Cross-domain connector**: Develop bridge theorems to complexity and quantum (Bridges)

Each team member should:
1. State precise theorem targets as Lean `theorem ... := by sorry`
2. Validate statements with computational checks (`#eval`, `#check`)
3. Prove bottom-up from simplest lemmas to main results
4. Document mathematical significance in docstrings
5. Iterate: when proofs fail, decompose further rather than retrying
