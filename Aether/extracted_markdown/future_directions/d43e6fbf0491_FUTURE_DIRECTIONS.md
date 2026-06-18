# Future Directions: Certified Finite Abelian Harmonic Analysis

## Conjecture 1: Plancherel Isometry for Finite Abelian Groups

**Conjecture:** For any finite abelian group $G$ and function $f: G \to \mathbb{C}$:
$$\sum_{g \in G} |f(g)|^2 = \frac{1}{|G|} \sum_{\chi \in \widehat{G}} |\hat{f}(\chi)|^2$$

**Test:** Verify computationally for all abelian groups of order ≤ 30 with 1000 random functions each. A counterexample would be any function where the two sides differ by more than numerical tolerance.

**Formal test:** State and prove in Lean 4 using `charVec_orthogonality` and `charVec_self_inner_product` as the key lemmas, together with `exists_full_character_family` to expand in the character basis.

**Impact:** This would complete the formal Fourier analysis package, enabling certified norm-preserving spectral computations. It is the essential ingredient for formal signal processing on finite groups.

---

## Conjecture 2: Spectral Rigidity of Translation-Equivariant Operators

**Conjecture:** For every finite abelian group $G$, every complex-linear translation-equivariant operator on $G \to \mathbb{C}$ is a convolution operator. That is, if $T$ commutes with all left translations, then there exists $f: G \to \mathbb{C}$ such that $T(v) = f * v$ for all $v$.

**Test:** For groups of order ≤ 12, enumerate all $|G|^2 \times |G|^2$ matrices that commute with all translation matrices. Verify that the space of such matrices has dimension exactly $|G|$ (matching the space of convolution operators). A counterexample would be a translation-equivariant operator that is not a convolution.

**Impact:** If true, this establishes that the character basis simultaneously diagonalizes *all* translation-equivariant operators — not just convolution operators. This is the finite-group analogue of the fact that every translation-invariant operator on $L^2(\mathbb{R})$ is a Fourier multiplier.

---

## Conjecture 3: Optimal Condition Number of Character Basis

**Conjecture:** Among all orthogonal eigenbases of the regular representation of a finite abelian group $G$, the normalized character basis $\{\chi/\sqrt{|G|}\}$ achieves condition number 1 (i.e., the basis is unitary).

**Test:** For groups of order ≤ 16, compute the condition number of the normalized character table matrix. Verify it equals 1.0 (up to numerical precision). Construct alternative eigenbases by arbitrary unitary rotations within each eigenspace and verify they have condition number ≥ 1.

**Impact:** This would establish the character basis as the unique "best-conditioned" spectral basis, providing a formal optimality result for numerical spectral methods on finite groups. It connects representation theory to numerical linear algebra.

---

## Conjecture 4: Formal Pontryagin Duality Yields Constructive Character Enumeration

**Conjecture:** The group isomorphism $G \cong \widehat{G}$ (where $\widehat{G} = \mathrm{Hom}(G, \mathbb{C}^\times)$) can be made constructive for finite abelian groups, yielding an algorithm that, given a presentation of $G$ as a product of cyclic groups, produces an explicit list of all characters with certified distinctness.

**Test:** Implement the construction for $G = \mathbb{Z}/n_1 \times \cdots \times \mathbb{Z}/n_k$ using roots of unity $\omega_{n_i} = e^{2\pi i/n_i}$. Verify that the resulting list has $|G|$ elements, all distinct, and that composition with any group automorphism permutes the list.

**Formal test:** State the construction as a `Decidable` or computable `Fintype` instance for `G →* ℂˣ` (currently only `Finite` is available via `Fintype.ofFinite`).

**Impact:** Would enable `#eval`-based character table computation in Lean, bridging formal proof and computation. This would make the spectral decomposition not just provably correct but also executable within the proof assistant.

---

## Conjecture 5: Character Sums Detect Subgroup Structure

**Conjecture:** For a finite abelian group $G$ and subgroup $H \leq G$:
$$\frac{1}{|H|}\sum_{h \in H} \chi(h) = \begin{cases} 1 & \text{if } H \leq \ker(\chi) \\ 0 & \text{otherwise} \end{cases}$$

**Test:** For all subgroups of all abelian groups of order ≤ 24, compute the character sum and verify the dichotomy. A counterexample would be a subgroup-character pair where the sum is neither 0 nor 1.

**Formal test:** Prove in Lean using `sum_char_eq_zero` restricted to the subgroup (viewing $\chi|_H$ as a character of $H$).

**Impact:** This result is the foundation of formal subgroup detection via spectral methods. It connects to:
- **Coding theory**: Syndrome decoding in linear codes over abelian groups
- **Number theory**: Detection of elements in ideal class subgroups via L-functions
- **Quantum computing**: Phase estimation for abelian hidden subgroup problems (the mathematical core of Shor's algorithm)

If formalized, it would provide the first certified spectral subgroup detector, enabling verified algorithms for the abelian hidden subgroup problem.
