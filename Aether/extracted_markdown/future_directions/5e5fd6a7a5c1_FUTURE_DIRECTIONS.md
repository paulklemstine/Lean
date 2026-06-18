# Future Directions: Hadamard Matrix Theory

## Conjecture 1: Paley–Sylvester Spectral Separation

**Conjecture.** For every order n where both a Sylvester-type and a Paley-type Hadamard matrix exist, the two constructions yield inequivalent matrices (under row/column permutations and sign flips) that can be distinguished by their second-order Walsh spectral correlation:

$$C_2(H) = \sum_{i \neq j} \left(\sum_k H_{ik} H_{jk}\right)^4$$

takes different values for Sylvester and Paley matrices at orders n ≥ 8.

**Test.** Compute $C_2$ for both constructions at orders 4, 8, 12, 24, 32, 48. If $C_2$ agrees at any order ≥ 8, the conjecture is refuted. Enumerate all Hadamard equivalence classes at small orders and check whether $C_2$ is a complete invariant for distinguishing Sylvester from Paley families.

**Impact.** If true, this provides a polynomial-time test to classify Hadamard matrices by construction origin, which would be valuable for understanding the structure of the Hadamard equivalence classes and for guiding computational search at unknown orders.

---

## Conjecture 2: Excess Rigidity at Dyadic Orders

**Conjecture.** Among all Hadamard matrices of order $n = 2^k$ (k ≥ 3), the Sylvester matrix uniquely maximizes the absolute excess $|\sigma(H)|$ within its Hadamard equivalence class. That is, for any Hadamard matrix H of order $2^k$ that is not equivalent to a Sylvester matrix, $|\sigma(H)| < |\sigma(S_k)|$ where $S_k$ is the Sylvester matrix.

**Test.** Enumerate all inequivalent Hadamard matrices at orders 8, 16, and 32 (databases exist up to order 32). Compute the excess of each. If any non-Sylvester matrix has excess equal to the Sylvester excess, the conjecture is refuted. At order 16, there are 5 inequivalent Hadamard matrices—all five excess values can be computed.

**Impact.** If true, this provides a simple arithmetic invariant that detects the "most structured" Hadamard matrix at each dyadic order, and could guide optimization-based construction methods for non-dyadic orders.

---

## Conjecture 3: Tensor-Factor Detectability via Row-Sum Profile

**Conjecture.** If a Hadamard matrix H of order $mn$ (where $m, n > 1$ and $4 | m$, $4 | n$) has the property that its sorted row-sum vector equals the Kronecker product of the sorted row-sum vectors of some Hadamard matrices of orders $m$ and $n$, then H is Hadamard-equivalent to a Kronecker product $H_1 \otimes H_2$.

**Test.** For orders 16 = 4×4, compare the row-sum profiles of all known inequivalent H₁₆ matrices against the Kronecker profile $[s_1 \cdot t_1, s_1 \cdot t_2, \ldots, s_m \cdot t_n]$ for all H₄ pairs. A counterexample (matching profile but not decomposable) would refute the conjecture. If the profile is never matching for indecomposable matrices, the conjecture survives.

**Impact.** If true, this gives a polynomial-time necessary condition for tensor decomposability of Hadamard matrices, enabling efficient search for "primitive" (non-decomposable) Hadamard matrices at composite orders.

---

## Conjecture 4: BIBD Lambda Monotonicity Under Kronecker Extension

**Conjecture.** Let $H_{4t}$ be a normalized Hadamard matrix inducing a symmetric 2-$(4t-1, 2t-1, t-1)$ design $D_t$. Let $H_{8t} = H_2 \otimes H_{4t}$ and let $D_{2t}$ be the induced 2-$(8t-1, 4t-1, 2t-1)$ design. Then the automorphism group of $D_{2t}$ has order strictly greater than that of $D_t$ if and only if $H_{4t}$ is equivalent to a Sylvester matrix.

**Test.** Compute automorphism groups of the BIBDs induced by Sylvester and Paley constructions at orders 4, 8, 12, 24. Compare group orders before and after Kronecker doubling. A single counterexample (non-Sylvester matrix whose BIBD automorphism group grows under doubling) refutes the conjecture.

**Impact.** If true, this establishes a structural dichotomy between "generic" and "maximally symmetric" Hadamard matrices, with consequences for the classification of symmetric BIBDs and the structure of the Hadamard equivalence poset.

---

## Conjecture 5: Quadratic Residue Coverage for Small Primes

**Conjecture.** For every multiple of 4 up to 200, at least one of the following produces a Hadamard matrix of that order:
1. A Sylvester construction (order is a power of 2),
2. A Paley Type I construction (order = p + 1 for prime p ≡ 3 mod 4),
3. A Paley Type II construction (order = 2(p + 1) for prime p ≡ 1 mod 4),
4. A Kronecker product of two matrices from categories 1–3.

**Test.** For each multiple of 4 from 4 to 200, attempt to express n in one of the forms above. The smallest currently open Hadamard order is 668. If any order ≤ 200 cannot be expressed, the conjecture is refuted.

**Impact.** If true, this demonstrates that the three classical construction families, combined with Kronecker closure, cover all small orders—suggesting that the Hadamard conjecture may be provable by a finite extension of known methods. If false, it identifies the smallest "genuinely hard" order and focuses computational search effort.
