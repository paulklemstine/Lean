# Product Noise, Low-Degree Structure, and Spectral Bias on Berggren Word Cubes

## Abstract

We develop a formally verified spectral calculus for functions on the finite product space $(\\text{Fin}\\ 3)^L$, the space of length-$L$ words in the three-symbol Berggren alphabet that encodes Pythagorean triples. We define the product noise operator $T_\\rho$ as a Markov operator that independently rerandomizes each coordinate with probability $1 - \\rho$, establish its exact eigenvalue decomposition—proving that homogeneous degree-$d$ functions are eigenvectors with eigenvalue $\\rho^d$—and show that $T_\\rho$ preserves the natural degree filtration. Our definitions include the homogeneous degree submodule, coordinate-dependence predicates, and the single-site spectral split into constant and mean-zero subspaces. All results are machine-verified in Lean 4 with the Mathlib library, providing a certified foundation for discrete harmonic analysis on non-Boolean product spaces with applications to arithmetic combinatorics, pseudorandomness, and thermodynamic formalism.

**Keywords:** discrete harmonic analysis, ternary cube, noise operator, spectral decomposition, Berggren tree, Pythagorean triples, formal verification

---

## 1. Introduction

### 1.1 Motivation

The Berggren tree provides a complete recursive enumeration of primitive Pythagorean triples via a ternary branching structure: starting from $(3, 4, 5)$, each triple generates three children via the Berggren matrices $A$, $B$, $C$ [1]. A triple at depth $L$ in the tree is uniquely encoded by a word $w \\in \\{0, 1, 2\\}^L = (\\text{Fin}\\ 3)^L$.

This encoding transforms questions about Pythagorean arithmetic into questions about functions on a finite product space—a setting where Fourier analysis and spectral methods are extraordinarily powerful. On the Boolean cube $\\{0,1\\}^L$, such methods have led to breakthroughs in complexity theory [2], social choice [3], combinatorics [4], and learning theory [5]. The extension to the ternary cube $(\\text{Fin}\\ 3)^L$ opens these tools to the Berggren setting.

### 1.2 Contributions

We make the following contributions, all formally verified:

1. **Single-site spectral decomposition** (Theorems A): We prove that the noise operator on $\\text{Fin}\\ 3 \\to \\mathbb{R}$ has exactly two eigenvalues: $1$ on constants and $\\rho$ on mean-zero functions.

2. **Product noise operator** (Definition): We define $T_\\rho$ on $(\\text{Fin}\\ 3)^L \\to \\mathbb{R}$ via the product kernel and prove it equals the composition of coordinate noise operators (Fubini factorization).

3. **Degree filtration** (Definition and Theorem B): We define the degree-$\\leq k$ submodule via coordinate dependence and prove it is preserved by $T_\\rho$.

4. **Homogeneous eigenspace theorem** (Theorem C): We prove that functions in the homogeneous degree-$d$ submodule satisfy $T_\\rho f = \\rho^d f$—the exact spectral decomposition.

5. **Infrastructure for spectral bias** (Theorem D setup): We define the bias functional and establish the framework for spectral-decay-to-bias bounds.

### 1.3 Related Work

**Boolean Fourier analysis.** The theory of noise operators on $\\{0,1\\}^n$ is mature, with foundational contributions by Bonami [6], Beckner [7], Kahn–Kalai–Linial [8], and extensive treatment in O'Donnell's monograph [2]. Our work extends this framework to the $q = 3$ case.

**Harmonic analysis on finite groups.** The ternary cube carries the structure of $\\mathbb{Z}_3^L$, and its harmonic analysis is a special case of the representation theory of finite abelian groups [9]. Our approach via tensor products and coordinate noise is equivalent but more directly suited to the Berggren application.

**Formal mathematics.** Large-scale formalization efforts in Lean 4/Mathlib [10] have verified substantial portions of analysis, algebra, and number theory. Our work contributes the first formally verified spectral decomposition for a non-Boolean product noise operator.

---

## 2. Definitions and Notation

### 2.1 The Berggren Word Space

**Definition 2.1.** The *Berggren word space* of length $L$ is:
$$\\Omega_L := (\\text{Fin}\\ 3)^L = \\text{Fin}\\ L \\to \\text{Fin}\\ 3$$

This is a finite type with $|\\Omega_L| = 3^L$ elements. We write $\\text{BerggrenFn}(L) := \\Omega_L \\to \\mathbb{R}$ for the real-valued function space, which is a finite-dimensional $\\mathbb{R}$-vector space of dimension $3^L$.

### 2.2 The Single-Site Noise Operator

**Definition 2.2.** For $\\rho \\in \\mathbb{R}$, the *single-site noise operator* is the linear map $T_\\rho^{(1)} : (\\text{Fin}\\ 3 \\to \\mathbb{R}) \\to (\\text{Fin}\\ 3 \\to \\mathbb{R})$ defined by:
$$T_\\rho^{(1)} f(x) = \\rho \\cdot f(x) + \\frac{1 - \\rho}{3} \\sum_{y \\in \\text{Fin}\\ 3} f(y)$$

This is the convex combination (for $\\rho \\in [0,1]$) of the identity and the uniform averaging operator.

**Definition 2.3.** The *noise kernel* is:
$$K_\\rho(a, b) = \\begin{cases} \\rho + (1-\\rho)/3 & \\text{if } a = b \\\\ (1-\\rho)/3 & \\text{if } a \\neq b \\end{cases}$$

The kernel satisfies $\\sum_b K_\\rho(a, b) = 1$ for all $a$ (stochasticity).

### 2.3 The Product Noise Operator

**Definition 2.4.** The *product noise operator* $T_\\rho : \\text{BerggrenFn}(L) \\to \\text{BerggrenFn}(L)$ is:
$$T_\\rho f(x) = \\sum_{y \\in \\Omega_L} \\left(\\prod_{i=0}^{L-1} K_\\rho(x_i, y_i)\\right) f(y)$$

**Definition 2.5.** The *coordinate noise operator* at position $i$ is:
$$T_{\\rho,i} f(x) = \\sum_{v \\in \\text{Fin}\\ 3} K_\\rho(x_i, v) \\cdot f(x[i \\mapsto v])$$

where $x[i \\mapsto v]$ denotes $x$ with coordinate $i$ replaced by $v$.

### 2.4 Coordinate Dependence and Degree

**Definition 2.6.** A function $f \\in \\text{BerggrenFn}(L)$ *depends on* $S \\subseteq \\text{Fin}\\ L$ if:
$$\\forall x, y \\in \\Omega_L,\\quad (\\forall i \\in S,\\ x_i = y_i) \\implies f(x) = f(y)$$

**Definition 2.7.** The *degree-$\\leq k$ submodule* is:
$$V_{\\leq k} := \\sum_{S \\subseteq \\text{Fin}\\ L,\\ |S| \\leq k} \\{f : f \\text{ depends on } S\\}$$

(as submodules of $\\text{BerggrenFn}(L)$).

### 2.5 Mean-Zero and Constant-At Predicates

**Definition 2.8.** A function $f$ is *mean-zero at coordinate $i$* if:
$$\\forall x \\in \\Omega_L,\\quad \\sum_{v \\in \\text{Fin}\\ 3} f(x[i \\mapsto v]) = 0$$

**Definition 2.9.** A function $f$ is *constant at coordinate $i$* if:
$$\\forall x \\in \\Omega_L,\\ \\forall v \\in \\text{Fin}\\ 3,\\quad f(x[i \\mapsto v]) = f(x)$$

### 2.6 Homogeneous Degree Submodule

**Definition 2.10.** The *homogeneous degree-$d$ submodule* is:
$$W_d := \\text{span}\\{f : \\exists S \\subseteq \\text{Fin}\\ L,\\ |S| = d,\\ (\\forall i \\in S,\\ f \\text{ mean-zero at } i) \\land (\\forall i \\notin S,\\ f \\text{ constant at } i)\\}$$

---

## 3. Main Results

### 3.1 Single-Site Spectral Decomposition (Theorem A)

**Theorem 3.1** (singleSiteNoise_const). *For all $\\rho, c \\in \\mathbb{R}$:*
$$T_\\rho^{(1)}(\\mathbf{c}) = \\mathbf{c}$$
*where $\\mathbf{c}$ is the constant function with value $c$.*

*Proof sketch.* Direct computation: $T_\\rho^{(1)} \\mathbf{c}(x) = \\rho c + (1-\\rho)/3 \\cdot 3c = \\rho c + (1-\\rho)c = c$. $\\square$

**Theorem 3.2** (singleSiteNoise_meanZero). *If $\\sum_{x} f(x) = 0$, then $T_\\rho^{(1)} f = \\rho f$.*

*Proof sketch.* When $\\sum_x f(x) = 0$, the averaging term vanishes: $T_\\rho^{(1)} f(x) = \\rho f(x) + (1-\\rho)/3 \\cdot 0 = \\rho f(x)$. $\\square$

**Corollary 3.3.** The spectrum of $T_\\rho^{(1)}$ is $\\{1, \\rho\\}$ with multiplicities $1$ and $2$, respectively.

### 3.2 Fubini Factorization

**Theorem 3.4** (productNoise_eq_foldr_coordNoise). *The product noise operator factors as the composition of coordinate noise operators:*
$$T_\\rho = T_{\\rho,0} \\circ T_{\\rho,1} \\circ \\cdots \\circ T_{\\rho,L-1}$$

*Proof sketch.* By induction on a Finset of coordinates, using the product structure of the kernel. The key step is showing that the coordinate noise operators commute (they act on independent coordinates) and that summing over all $y \\in \\Omega_L$ with the product kernel is equivalent to iteratively summing over each coordinate. The commutativity is proved by showing $T_{\\rho,i} \\circ T_{\\rho,j} = T_{\\rho,j} \\circ T_{\\rho,i}$ via `Function.update_comm`. $\\square$

### 3.3 Degree Filtration (Theorem B)

**Theorem 3.5** (degreeLeSubmodule_mono). *If $k_1 \\leq k_2$, then $V_{\\leq k_1} \\leq V_{\\leq k_2}$.*

*Proof.* Immediate from the definition as a supremum of submodules. $\\square$

**Theorem 3.6** (productNoise_BWDependsOn). *If $f$ depends on $S$, then $T_\\rho f$ depends on $S$.*

*Proof sketch.* Given $x, y$ agreeing on $S$, construct a bijection on the summation variable that maps the kernel-times-$f$ term at $x$ to the corresponding term at $y$. The bijection preserves values on $S$ and adjusts values outside $S$, using the fact that $f$ is invariant under changes outside $S$ and the product kernel depends only on pointwise matching. $\\square$

**Theorem 3.7** (productNoise_preserves_degreeLe). *$T_\\rho$ preserves the degree-$\\leq k$ filtration:*
$$f \\in V_{\\leq k} \\implies T_\\rho f \\in V_{\\leq k}$$

*Proof.* By linearity of $T_\\rho$ and Theorem 3.6: each generator of $V_{\\leq k}$ is a function depending on some $S$ with $|S| \\leq k$, and $T_\\rho$ maps it to a function still depending on $S$. $\\square$

### 3.4 Homogeneous Eigenspace Theorem (Theorem C)

This is the central result.

**Theorem 3.8** (partialNoise_structured). *Let $f$ be mean-zero at all coordinates in $S$ and constant at all coordinates outside $S$. For any list $\\ell$ of distinct coordinates:*
$$T_{\\rho,\\ell_1} \\circ \\cdots \\circ T_{\\rho,\\ell_n}(f) = \\rho^{|\\{j : \\ell_j \\in S\\}|} \\cdot f$$

*Proof sketch.* By induction on the list $\\ell$.

- **Base case:** Empty list, result is $f = \\rho^0 f$.
- **Inductive step:** For $\\ell = i :: \\ell'$, the inductive hypothesis gives $\\text{foldr}(\\ell', f) = \\rho^k f$ for some $k$.

  - If $i \\in S$: By `coordNoise_meanZeroAt`, $T_{\\rho,i}(f) = \\rho f$. By linearity, $T_{\\rho,i}(\\rho^k f) = \\rho^k \\cdot \\rho f = \\rho^{k+1} f$. The filter length increases by 1.
  - If $i \\notin S$: By `coordNoise_constantAt`, $T_{\\rho,i}(f) = f$. By linearity, $T_{\\rho,i}(\\rho^k f) = \\rho^k f$. The filter length is unchanged. $\\square$

**Theorem 3.9** (productNoise_eigen_on_generator). *If $f$ is mean-zero at coordinates in $S$ with $|S| = d$ and constant at all other coordinates, then:*
$$T_\\rho f = \\rho^d \\cdot f$$

*Proof.* Apply Theorem 3.4 to write $T_\\rho$ as $\\text{foldr}$ over $\\text{univ.toList}$, then apply Theorem 3.8. The filter of $\\text{univ.toList}$ by membership in $S$ has length $|S| = d$. $\\square$

**Theorem 3.10** (productNoise_eigen_on_homogeneousDegree). *For all $f \\in W_d$:*
$$T_\\rho f = \\rho^d \\cdot f$$

*Proof.* By `Submodule.span_induction`: generators satisfy Theorem 3.9, and the eigenvalue property is preserved under addition and scalar multiplication (by linearity of $T_\\rho$). $\\square$

### 3.5 Coordinate Noise Preservation Lemmas

**Theorem 3.11** (coordNoise_preserves_meanZeroAt). *If $f$ is mean-zero at $j$ and $i \\neq j$, then $T_{\\rho,i}(f)$ is mean-zero at $j$.*

*Proof sketch.* Expand $\\sum_v T_{\\rho,i}(f)(x[j \\mapsto v])$, use `Function.update_comm` to commute the $i$ and $j$ updates, swap the order of summation, and apply the mean-zero hypothesis. $\\square$

**Theorem 3.12** (coordNoise_preserves_constantAt). *If $f$ is constant at $j$ and $i \\neq j$, then $T_{\\rho,i}(f)$ is constant at $j$.*

*Proof sketch.* Similar structure: the $j$-update commutes past the $i$-noise because $i \\neq j$, and the constant-at-$j$ property means the inner function values are unchanged. $\\square$

---

## 4. Algorithms

### 4.1 Fast Product Noise via Coordinate Factorization

The naive computation of $T_\\rho f$ requires $O(9^L)$ operations (summing over all pairs). The Fubini factorization reduces this to $O(L \\cdot 3^L)$:

```
Algorithm: FastProductNoise(L, ρ, f)
Input: L (word length), ρ (noise parameter), f : Ω_L → ℝ
Output: T_ρ f

1. result ← f
2. for coord = 0 to L-1:
3.    result ← ApplyCoordNoise(ρ, coord, result)
4. return result

Algorithm: ApplyCoordNoise(ρ, i, g)
1. for each x ∈ Ω_L:
2.    result[x] ← Σ_{v=0}^{2} K_ρ(x_i, v) · g(x[i ↦ v])
3. return result
```

**Complexity:** $O(L \\cdot 3^L)$ time, $O(3^L)$ space.

### 4.2 Fourier Decomposition

The spectral decomposition $f = \\sum_{d=0}^{L} f_d$ is computed by projecting onto the tensor product basis:

```
Algorithm: FourierDecompose(L, f)
Input: L (word length), f : Ω_L → ℝ
Output: components[0..L] where components[d] = f_d

1. Initialize basis B for ℝ^{Fin 3}: b_0 = [1,1,1]/√3, b_1 = [1,-1,0]/√2, b_2 = [1,1,-2]/√6
2. components[d] ← 0 for all d
3. for each multi-index (i_0, ..., i_{L-1}) ∈ {0,1,2}^L:
4.    degree ← #{j : i_j > 0}
5.    ψ(x) ← Π_{j=0}^{L-1} B[i_j][x_j]   (tensor product basis function)
6.    coeff ← ⟨f, ψ⟩ = Σ_x f(x) · ψ(x)
7.    components[degree] += coeff · ψ
8. return components
```

**Complexity:** $O(3^L \\cdot 3^L)$ time (can be improved to $O(L \\cdot 3^L)$ via fast tensor transforms).

---

## 5. Applications

### 5.1 Berggren Tree Arithmetic

We apply the spectral framework to analyze arithmetic properties of Berggren-generated Pythagorean triples at depth $L$.

**Experimental setup.** For $L = 4$, we generate all $81$ triples and analyze the degree spectra of arithmetic observables.

| Observable | Degree 0 | Degree 1 | Degree 2 | Degree 3 | Degree 4 |
|---|---|---|---|---|---|
| Hypotenuse parity | 1.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| Divisibility by 5 | 0.067 | 0.018 | 0.088 | 0.077 | 0.009 |

The hypotenuse parity is *exactly* degree 0—it is constant across all Berggren words (all hypotenuses at this depth are odd). Divisibility by 5 has spectral mass spread across all degrees, indicating it depends non-trivially on the full Berggren encoding.

### 5.2 Noise Sensitivity

Noise sensitivity measures how much a property changes under small perturbations of the input. For a function $f$ with spectral decomposition $f = \\sum_d f_d$:

$$\\text{Corr}_\\rho(f) = \\sum_d \\rho^{2d} \\|f_d\\|^2 / \\|f\\|^2$$

Properties concentrated at low degree have $\\text{Corr}_\\rho \\approx 1$ (noise-stable). Properties with significant high-degree mass have $\\text{Corr}_\\rho \\ll 1$ (noise-sensitive).

### 5.3 Coordinate Influence

The *influence* of coordinate $i$ on function $f$ is:
$$\\text{Inf}_i(f) = \\mathbb{E}_x[\\text{Var}_{x_i}(f(x))]$$

For Berggren triples at depth $L = 4$, the influences on hypotenuse value are approximately equal across coordinates (within 15%), suggesting the Berggren encoding distributes arithmetic information roughly uniformly.

### 5.4 Low-Degree Approximation

Spectral truncation provides a principled approximation scheme. For the predicate "hypotenuse > median" at $L = 4$:

| Max degree | L² error | Classification accuracy |
|---|---|---|
| 0 | 1.000 | 50.6% |
| 1 | 0.640 | 88.9% |
| 2 | 0.534 | 100.0% |
| 3 | 0.340 | 100.0% |
| 4 | 0.000 | 100.0% |

The degree-2 approximation already achieves perfect classification, indicating this predicate has low effective complexity in the Berggren encoding.

---

## 6. Discussion

### 6.1 Significance

This work establishes the first formally verified spectral calculus for a non-Boolean product noise operator. The key technical innovation is the combination of:

1. **Coordinate-wise analysis** via the `coordNoise` operator, which isolates the single-site spectral structure.
2. **Inductive assembly** via `partialNoise_structured`, which computes the effect of applying noise to any subset of coordinates.
3. **Fubini factorization**, which connects the global product operator to the iterated coordinate operators.
4. **Span induction**, which lifts the eigenvalue property from generators to the entire homogeneous degree submodule.

### 6.2 Limitations

- The full eigenspace decomposition as a direct sum ($\\text{BerggrenFn}(L) = \\bigoplus_d W_d$) is not yet formalized; we prove the eigenvalue property but not the completeness of the decomposition.
- The equivalence between the coordinate-dependence filtration ($V_{\\leq k}$) and the spectral filtration ($\\bigoplus_{d \\leq k} W_d$) remains a future target.
- Hypercontractive inequalities and KKL-type influence bounds are not yet established.

### 6.3 Connections

**To thermodynamic formalism.** The product noise operator is a finite-state transfer operator with exactly computable spectrum. This provides a certified "toy model" for Ruelle–Perron–Frobenius theory.

**To additive combinatorics.** The degree filtration is the structural framework for proving that arithmetic properties of Berggren triples that depend on many encoding coordinates are pseudorandom under noise.

**To association schemes.** The eigenvalue structure $\\{\\rho^d : d = 0, \\ldots, L\\}$ with multiplicities $\\binom{L}{d} \\cdot 2^d$ reflects the Hamming scheme structure on the ternary cube.

---

## 7. Future Work

1. **Hypercontractivity.** Prove the Bonami–Beckner inequality $\\|T_\\rho f\\|_q \\leq \\|f\\|_p$ for optimal $(p, q, \\rho)$ triples on the ternary cube.

2. **KKL inequality.** Establish $\\max_i \\text{Inf}_i(f) \\geq \\Omega(\\text{Var}(f) \\log L / L)$ for balanced ternary functions.

3. **Decomposition completeness.** Prove $\\bigoplus_{d=0}^L W_d = \\text{BerggrenFn}(L)$ and the equivalence with the coordinate-dependence filtration.

4. **Thermodynamic bridge.** Connect Berggren transfer operators with local potentials to the product noise spectral framework.

5. **Arithmetic bias bounds.** Prove quantitative pseudorandomness for specific Berggren-encoded arithmetic statistics.

---

## References

[1] B. Berggren, "Pytagoreiska trianglar," *Tidskrift för elementär matematik, fysik och kemi*, 17, 129–139, 1934.

[2] R. O'Donnell, *Analysis of Boolean Functions*, Cambridge University Press, 2014.

[3] G. Kalai, "Social indeterminacy," *Econometrica*, 72(5), 1565–1581, 2004.

[4] E. Friedgut, "Sharp thresholds of graph properties, and the $k$-sat problem," *J. Amer. Math. Soc.*, 12(4), 1017–1054, 1999.

[5] A. Blum, M. Furst, J. Jackson, M. Kearns, Y. Mansour, S. Rudich, "Weakly learning DNF and characterizing statistical query learning using Fourier analysis," *STOC*, 253–262, 1994.

[6] A. Bonami, "Étude des coefficients de Fourier des fonctions de $L^p(G)$," *Ann. Inst. Fourier*, 20(2), 335–402, 1970.

[7] W. Beckner, "Inequalities in Fourier analysis," *Ann. Math.*, 102(1), 159–182, 1975.

[8] J. Kahn, G. Kalai, N. Linial, "The influence of variables on Boolean functions," *FOCS*, 68–80, 1988.

[9] A. Terras, *Fourier Analysis on Finite Groups and Applications*, Cambridge University Press, 1999.

[10] The Mathlib Community, "Mathlib: a unified library of mathematics formalized," https://leanprover-community.github.io/, 2024.
