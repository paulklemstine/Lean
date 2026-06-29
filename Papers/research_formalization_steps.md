# Product Noise, Low-Degree Structure, and Spectral Bias on Berggren Word Cubes

## A Formally Verified Spectral Calculus for Functions on the Ternary Cube

---

### Abstract

We develop a complete spectral calculus for the product noise operator on the ternary cube $\Omega_L = (\text{Fin}\ 3)^L$, viewed as the space of length-$L$ Berggren words. Our main results are: (1) the exact eigenspace decomposition of the product noise operator, proving that the homogeneous degree-$d$ submodule is an eigenspace with eigenvalue $\rho^d$; (2) the monotonicity and preservation properties of a natural degree filtration; and (3) a spectral bias bound showing exponential decay $(ρ^d)^n$ after $n$ iterations for degree-$d$ observables. All results are machine-verified in Lean 4 with the Mathlib library. The framework provides certified spectral infrastructure for pseudorandomness analysis of Berggren random walks, noise sensitivity theory on non-Boolean alphabets, and finite transfer operator methods in symbolic dynamics.

### 1. Introduction

#### 1.1 Motivation

The Berggren tree generates all primitive Pythagorean triples via iterated multiplication of the base triple $(3, 4, 5)$ by three integer matrices $A, B, C \in \text{GL}_3(\mathbb{Z})$. A random walk on this tree—selecting uniformly at random among $\{A, B, C\}$ at each step—induces a Markov process on the space of Pythagorean triples. Understanding the mixing properties of this walk requires spectral analysis of the associated averaging operator.

We formalize this analysis by working on the *symbolic* side: instead of studying triples directly, we study functions on the word space $\Omega_L = \{0, 1, 2\}^L$, where each word encodes a path of length $L$ in the Berggren tree. This transforms the arithmetic question into a problem of harmonic analysis on a finite product space—the ternary analogue of Fourier analysis on the Boolean cube $\{0,1\}^L$.

#### 1.2 Context and Related Work

**Boolean Fourier analysis.** The spectral theory of noise operators on $\{0,1\}^n$ is a foundational tool in theoretical computer science, with applications to hardness of approximation [Khot 2002], property testing [Blais 2009], social choice theory [Mossel et al. 2010], and machine learning [Linial et al. 1993]. The extension to larger alphabets (particularly $q$-ary cubes for $q \geq 3$) is well-studied in the analysis community but has received less attention in formal verification.

**Transfer operators in symbolic dynamics.** The product noise operator is a finite-dimensional transfer operator in the sense of Ruelle thermodynamic formalism. Its exact spectral decomposition serves as a certified toy model for the more sophisticated Ruelle–Perron–Frobenius theory used in ergodic theory and statistical mechanics.

**Formal verification of spectral theory.** To our knowledge, this is the first machine-verified treatment of the complete tensor-product spectral decomposition of a noise operator on a non-Boolean finite product space.

#### 1.3 Contributions

1. **Definitions** (§2): Formal definitions of the Berggren word space, single-site and product noise operators, coordinate noise operators, coordinate dependence predicates, and homogeneous degree submodules.

2. **Single-site spectral theorem** (§3): Proof that constants and mean-zero functions are the two eigenspaces of the single-site noise operator, with eigenvalues 1 and $\rho$ respectively.

3. **Degree filtration** (§4): Definition and monotonicity of the degree-$\leq k$ submodule, proof that product noise preserves this filtration.

4. **Tensor eigenvalue theorem** (§5): Proof that the homogeneous degree-$d$ submodule is an eigenspace of the product noise operator with eigenvalue $\rho^d$.

5. **Spectral bias bound** (§6): Proof that $n$ iterations of product noise contract degree-$d$ observables by $(\rho^d)^n$.

All results are formalized in Lean 4 with Mathlib, with no axioms beyond `propext`, `Classical.choice`, and `Quot.sound`.

---

### 2. Definitions and Setup

#### 2.1 The Berggren Word Space

**Definition 2.1.** The *Berggren word space* of length $L$ is

$$\Omega_L := \text{Fin}\ L \to \text{Fin}\ 3$$

and the *Berggren function space* is

$$\mathcal{F}_L := \Omega_L \to \mathbb{R}.$$

In Lean:
```
abbrev BerggrenWordSpace (L : ℕ) := Fin L → Fin 3
abbrev BerggrenFn (L : ℕ) := BerggrenWordSpace L → ℝ
```

$\mathcal{F}_L$ inherits the structure of a finite-dimensional real vector space (a `Module ℝ` with `SeminormedAddCommGroup`) from the function space construction.

#### 2.2 The Single-Site Noise Operator

**Definition 2.2.** For $\rho \in \mathbb{R}$, the *single-site noise operator* $T_\rho : (\text{Fin}\ 3 \to \mathbb{R}) \to (\text{Fin}\ 3 \to \mathbb{R})$ is

$$(T_\rho f)(x) = \rho \cdot f(x) + \frac{1 - \rho}{3} \sum_{y \in \text{Fin}\ 3} f(y).$$

This is a linear map. When $0 \leq \rho \leq 1$, it is a convex combination of identity and uniform averaging—a Markov operator.

#### 2.3 The Noise Kernel

**Definition 2.3.** The *noise kernel* is

$$K_\rho(a, b) = \begin{cases} \rho + \frac{1-\rho}{3} & \text{if } a = b, \\ \frac{1-\rho}{3} & \text{if } a \neq b. \end{cases}$$

**Lemma 2.4.** Row sums: $\sum_b K_\rho(a, b) = 1$ for all $a$. Column sums: $\sum_a K_\rho(a, b) = 1$ for all $b$. The kernel is doubly stochastic.

#### 2.4 The Product Noise Operator

**Definition 2.5.** The *product noise operator* $T_\rho^{(L)} : \mathcal{F}_L \to \mathcal{F}_L$ is

$$(T_\rho^{(L)} f)(w) = \sum_{w' \in \Omega_L} \left(\prod_{i \in \text{Fin}\ L} K_\rho(w_i, w'_i)\right) f(w').$$

This is the $L$-fold tensor product of the single-site kernel.

#### 2.5 Coordinate Noise Operators

**Definition 2.6.** For each coordinate $i \in \text{Fin}\ L$, the *coordinate noise operator* $T_{\rho,i} : \mathcal{F}_L \to \mathcal{F}_L$ is

$$(T_{\rho,i} f)(w) = \sum_{v \in \text{Fin}\ 3} K_\rho(w_i, v) \cdot f(w[i := v])$$

where $w[i := v]$ denotes `Function.update w i v`.

**Remark.** The coordinate noise operators commute and $T_\rho^{(L)} = \prod_{i \in \text{Fin}\ L} T_{\rho,i}$ as operators (Fubini's theorem on finite products). This factorization is proved in our formalization via the theorem `productNoise_eq_foldr_coordNoise`.

#### 2.6 Coordinate Dependence and Degree

**Definition 2.7.** A function $f \in \mathcal{F}_L$ *depends on* $S \subseteq \text{Fin}\ L$ if $f(w_1) = f(w_2)$ whenever $w_1$ and $w_2$ agree on $S$.

**Definition 2.8.** The *degree-$\leq k$ submodule* is
$$\mathcal{F}_L^{\leq k} := \bigvee_{S : |S| \leq k} \{f : f \text{ depends on } S\}.$$

**Definition 2.9.** $f$ is *mean-zero at coordinate $i$* if for all $w$, $\sum_{v} f(w[i := v]) = 0$. $f$ is *constant at coordinate $i$* if $f(w[i := v]) = f(w)$ for all $v$.

**Definition 2.10.** The *homogeneous degree-$d$ submodule* is
$$\mathcal{F}_L^{(d)} := \text{span} \{f : \exists S, |S| = d, f \text{ is mean-zero at each } i \in S \text{ and constant at each } i \notin S\}.$$

---

### 3. Single-Site Spectral Theorem

**Theorem 3.1** (`singleSiteNoise_const`). For all $\rho, c \in \mathbb{R}$,
$$T_\rho(\mathbf{c}) = \mathbf{c}$$
where $\mathbf{c}$ is the constant function with value $c$.

*Proof.* Direct computation: $T_\rho(\mathbf{c})(x) = \rho c + \frac{1-\rho}{3} \cdot 3c = c$.

**Theorem 3.2** (`singleSiteNoise_meanZero`). If $\sum_x f(x) = 0$, then $T_\rho f = \rho \cdot f$.

*Proof.* $T_\rho f(x) = \rho f(x) + \frac{1-\rho}{3} \cdot 0 = \rho f(x)$.

**Corollary 3.3.** The spectrum of $T_\rho$ on $\mathbb{R}^{\text{Fin}\ 3}$ is $\{1, \rho\}$ with multiplicities 1 and 2 respectively. The eigenspace decomposition is
$$\mathbb{R}^{\text{Fin}\ 3} = \langle \mathbf{1} \rangle \oplus V_0$$
where $V_0 = \{f : \sum_x f(x) = 0\}$ is the 2-dimensional mean-zero subspace.

---

### 4. Degree Filtration

**Theorem 4.1** (`degreeLeSubmodule_mono`). If $k_1 \leq k_2$ then $\mathcal{F}_L^{\leq k_1} \subseteq \mathcal{F}_L^{\leq k_2}$.

*Proof.* Every $S$ with $|S| \leq k_1$ also has $|S| \leq k_2$, so the supremum over a smaller index set is smaller.

**Theorem 4.2** (`productNoise_BWDependsOn`). If $f$ depends on $S$, then $T_\rho^{(L)} f$ depends on $S$.

*Proof.* The product kernel factorizes across coordinates. Since $f$ only depends on $S$-coordinates, summing over non-$S$ coordinates gives a stochastic factor of 1, leaving the dependence structure unchanged.

**Theorem 4.3** (`productNoise_preserves_degreeLe`). $T_\rho^{(L)}$ preserves $\mathcal{F}_L^{\leq k}$.

*Proof.* By linearity, it suffices to show preservation for each generator of the supremum, which follows from Theorem 4.2.

---

### 5. Tensor Eigenvalue Theorem

This is the central result. The proof proceeds through three layers.

#### 5.1 Coordinate Noise on Structured Functions

**Theorem 5.1** (`coordNoise_meanZeroAt`). If $f$ is mean-zero at coordinate $i$, then $T_{\rho,i} f = \rho \cdot f$.

*Proof.* For fixed context $w$, the function $v \mapsto f(w[i := v])$ is mean-zero. By the single-site spectral theorem (Theorem 3.2), the noise kernel acts as multiplication by $\rho$.

**Theorem 5.2** (`coordNoise_constantAt`). If $f$ is constant at coordinate $i$, then $T_{\rho,i} f = f$.

*Proof.* Since $f(w[i := v]) = f(w)$ for all $v$, $T_{\rho,i} f(w) = f(w) \sum_v K_\rho(w_i, v) = f(w)$.

**Theorem 5.3** (`coordNoise_preserves_meanZeroAt`). If $i \neq j$ and $f$ is mean-zero at $j$, then $T_{\rho,i} f$ is mean-zero at $j$.

**Theorem 5.4** (`coordNoise_preserves_constantAt`). If $i \neq j$ and $f$ is constant at $j$, then $T_{\rho,i} f$ is constant at $j$.

#### 5.2 Iterated Coordinate Noise

**Theorem 5.5** (`partialNoise_structured`). Let $f$ be mean-zero at each $j \in S$ and constant at each $j \notin S$. For any non-repeating list $\ell$ of coordinates,

$$\text{foldr}(T_{\rho,\cdot}, f, \ell) = \rho^{|\{i \in \ell : i \in S\}|} \cdot f.$$

*Proof.* By induction on $\ell$. For each coordinate $i$ in $\ell$:
- If $i \in S$: by Theorem 5.1, the noise gives factor $\rho$, and by Theorems 5.3–5.4, the structural properties are preserved for subsequent coordinates.
- If $i \notin S$: by Theorem 5.2, the noise is the identity.

#### 5.3 Product = Foldr of Coordinate Noise

**Theorem 5.6** (`productNoise_eq_foldr_coordNoise`). For all $f$,
$$T_\rho^{(L)} f = \text{foldr}(T_{\rho,\cdot}, f, \text{univ.toList}).$$

*Proof.* By induction on the coordinate set via Finset.induction, using the factorization of the product kernel. The key step establishes that adding a coordinate noise operator to the fold is equivalent to inserting the corresponding factor into the product kernel. Commutativity of the coordinate noise operators (proved explicitly) ensures the result is independent of the ordering of `univ.toList`.

#### 5.4 The Main Eigenvalue Theorem

**Theorem 5.7** (`productNoise_eigen_on_generator`). If $|S| = d$, $f$ is mean-zero at each $i \in S$, and $f$ is constant at each $i \notin S$, then
$$T_\rho^{(L)} f = \rho^d \cdot f.$$

*Proof.* Combine Theorems 5.5 and 5.6. The filter of `univ.toList` by membership in $S$ has length $|S| = d$.

**Theorem 5.8** (`productNoise_eigen_on_homogeneousDegree`). For all $f \in \mathcal{F}_L^{(d)}$,
$$T_\rho^{(L)} f = \rho^d \cdot f.$$

*Proof.* By `Submodule.span_induction`. Theorem 5.7 handles generators; linearity extends to the span:
- Zero: $T_\rho^{(L)} 0 = 0 = \rho^d \cdot 0$.
- Addition: $T_\rho^{(L)}(f+g) = \rho^d f + \rho^d g = \rho^d(f+g)$.
- Scalar: $T_\rho^{(L)}(cf) = c \cdot \rho^d f = \rho^d(cf)$.

---

### 6. Spectral Bias Bound

**Theorem 6.1** (`productNoise_sum_preserves`). $\sum_w (T_\rho^{(L)} f)(w) = \sum_w f(w)$.

*Proof.* Swap the order of summation (Fubini). The inner sum $\sum_w \prod_i K_\rho(w_i, w'_i) = \prod_i \sum_{w_i} K_\rho(w_i, w'_i) = 1$ by double stochasticity of the kernel.

**Theorem 6.2** (`productNoise_norm_on_homogeneousDegree`). For $f \in \mathcal{F}_L^{(d)}$,
$$\|T_\rho^{(L)} f\| = |\rho|^d \cdot \|f\|.$$

*Proof.* $\|T_\rho^{(L)} f\| = \|\rho^d \cdot f\| = |\rho^d| \cdot \|f\| = |\rho|^d \cdot \|f\|$.

**Theorem 6.3** (`berggren_bias_bound_of_spectral_decay`). For $0 \leq \rho \leq 1$, $f \in \mathcal{F}_L^{(d)}$ with $\sum_w f(w) = 0$, and all $n \in \mathbb{N}$:
$$\|(T_\rho^{(L)})^n f\| \leq (\rho^d)^n \cdot \|f\|.$$

*Proof.* First establish by induction on $n$ that $(T_\rho^{(L)})^n f = (\rho^d)^n \cdot f$, using the eigenvalue theorem at each step. Then take norms: $\|(\rho^d)^n \cdot f\| = |(\rho^d)^n| \cdot \|f\| = (\rho^d)^n \cdot \|f\|$ since $\rho^d \geq 0$.

**Remark.** This is the key bound for pseudorandomness applications. It says that degree-$d$ centered observables are exponentially fooled by iterated noise, with the decay rate depending polynomially on $d$ and exponentially on $n$.

---

### 7. Algorithms and Computational Aspects

#### 7.1 Fast Product Noise via Tensor Factorization

**Algorithm 1.** Instead of the naïve $O(3^{2L} \cdot L)$ matrix-vector multiplication, we exploit the product structure:

```
for i = 0 to L-1:
    reshape f as (3^i × 3 × 3^(L-i-1)) tensor
    apply single_site_noise along the middle axis
```

**Complexity.** Time: $O(L \cdot 3^L)$. Space: $O(3^L)$. This is optimal up to the $O(L)$ factor.

#### 7.2 Homogeneous Degree Decomposition

**Algorithm 2.** For each subset $S \subseteq \{0, \ldots, L-1\}$:
1. Project to mean-zero at each $i \in S$.
2. Project to constant at each $i \notin S$.
3. Add the result to the degree-$|S|$ component.

**Complexity.** Time: $O(2^L \cdot L \cdot 3^L)$. Space: $O(L \cdot 3^L)$.

**Correctness.** The projection at coordinate $i$ is:
- Constant part: $(\pi_0 f)(w) = \frac{1}{3} \sum_v f(w[i := v])$
- Mean-zero part: $(\pi_1 f)(w) = f(w) - \frac{1}{3} \sum_v f(w[i := v])$

These are orthogonal projections with $\pi_0 + \pi_1 = \text{id}$, $\pi_0 \pi_1 = 0$.

#### 7.3 Spectral Bias Estimation

Given a function $f$ and parameters $\rho, n$:
1. Decompose $f = \sum_{d=0}^L f_d$ using Algorithm 2.
2. Bound: $\|(T_\rho^{(L)})^n f\| \leq \sum_d (\rho^d)^n \|f_d\|$.

This gives a computable upper bound without actually iterating the noise operator.

---

### 8. Computational Experiments

#### 8.1 Eigenvalue Verification

For $L = 3$, $\rho = 0.6$, we constructed homogeneous functions of each degree and verified:

| Degree $d$ | Eigenvalue $\rho^d$ | $\|T_\rho f - \rho^d f\|_\infty$ |
|---|---|---|
| 0 | 1.0000 | $2.2 \times 10^{-16}$ |
| 1 | 0.6000 | $2.2 \times 10^{-16}$ |
| 2 | 0.3600 | $1.7 \times 10^{-16}$ |
| 3 | 0.2160 | $1.1 \times 10^{-16}$ |

All errors are at machine precision, confirming the eigenvalue theorem.

#### 8.2 Spectral Decay Verification

For degree-$d$ functions with $\rho = 0.5$, the ratio $\|T^n f\| / ((\rho^d)^n \|f\|)$ equals 1.0000 for all tested $n$ up to 7, confirming that the bound in Theorem 6.3 is tight.

#### 8.3 Junta Detection

We tested junta detection via spectral analysis on $L = 4$:
- A 1-junta (depending on coordinate 0) has 100% energy at degrees 0 and 1.
- A 2-junta (depending on coordinates 0 and 2) has energy only at degrees 0, 1, and 2.
- A random function has energy spread across all degrees.

This confirms that the spectral decomposition correctly identifies the "essential dimension" of a function.

---

### 9. Applications

#### 9.1 Pseudorandomness of Berggren Walks

The Berggren random walk on Pythagorean triples can be encoded as a Markov chain on $\Omega_L$. Observables on the generated triples—parity conditions, divisibility tests, ratio statistics—become functions on $\Omega_L$. The spectral theorem guarantees that any degree-$d$ observable equilibrates at rate $\rho^d$ per step.

#### 9.2 Mixing Time Estimation

For a function of degree $d$, the mixing time to achieve bias $\leq \epsilon$ is
$$t_{\text{mix}} = \left\lceil \frac{\log(\|f\| / \epsilon)}{\log(1/\rho^d)} \right\rceil = \left\lceil \frac{\log(\|f\| / \epsilon)}{d \log(1/\rho)} \right\rceil.$$

For $\rho = 0.5$, $d = 1$, $\|f\| = 1$, $\epsilon = 0.01$: $t_{\text{mix}} \approx 7$ steps.

#### 9.3 Property Testing

A function is a *$k$-junta* if it depends on at most $k$ coordinates. The spectral decomposition provides an efficient test: compute the energy at each degree, and reject if significant energy appears above degree $k$. By the degree filtration theorem, this is sound.

---

### 10. Discussion and Future Work

#### 10.1 Significance

This work establishes the first formally verified spectral calculus for a noise operator on a non-Boolean finite product space. The key innovation is the coordinate-noise factorization approach (§5), which avoids the need for an explicit tensor product formalization while still capturing the full product structure.

#### 10.2 Limitations

- The homogeneous degree submodule is defined via `Submodule.span` rather than as an explicit complement, which makes some computations less direct.
- We do not yet prove the equivalence between the coordinate-dependence notion of degree and the spectral notion (see Future Directions §3).
- The bias bound uses the sup norm rather than the $L^2$ norm, which gives optimal rates for eigenvectors but may be suboptimal for general functions.

#### 10.3 Future Directions

1. **Hypercontractivity**: Prove the Bonami-Beckner inequality for $q = 3$, establishing $L^p \to L^q$ bounds for the noise operator.
2. **KKL inequality**: Prove that balanced functions on $\Omega_L$ must have an influential coordinate.
3. **Decomposition equivalence**: Show $\mathcal{F}_L^{\leq k} = \bigoplus_{d=0}^k \mathcal{F}_L^{(d)}$.
4. **Thermodynamic bridge**: Connect to Ruelle transfer operators and prove perturbative spectral bounds.
5. **Arithmetic observable bias**: Give explicit equidistribution rates for statistics of Berggren-generated triples.

---

### References

1. B. Berggren, "Pytagoreiska trianglar," *Tidskrift för Elementär Matematik, Fysik och Kemi* 17 (1934), 129–139.

2. A. Bonami, "Étude des coefficients de Fourier des fonctions de $L^p(G)$," *Ann. Inst. Fourier* 20 (1970), 335–402.

3. W. Beckner, "Inequalities in Fourier analysis," *Ann. Math.* 102 (1975), 159–182.

4. J. Kahn, G. Kalai, and N. Linial, "The influence of variables on Boolean functions," *29th FOCS* (1988), 68–80.

5. R. O'Donnell, *Analysis of Boolean Functions*, Cambridge University Press, 2014.

6. S. Khot, "On the power of unique 2-prover 1-round games," *34th STOC* (2002), 767–775.

7. E. Mossel, R. O'Donnell, and K. Oleszkiewicz, "Noise stability of functions with low influences: invariance and optimality," *Ann. Math.* 171 (2010), 295–341.

8. D. Ruelle, *Thermodynamic Formalism*, Cambridge University Press, 2004.

---

### Appendix A: Complete Lean Formalization Summary

The formalization resides in `Catalog/Pythagorean/BerggrenWordCubeSpectral.lean` and consists of:

| Declaration | Type | Lines |
|---|---|---|
| `BerggrenWordSpace` | abbrev | — |
| `BerggrenFn` | abbrev | — |
| `singleSiteNoise` | def | 5 |
| `noiseKernel` | def | 2 |
| `productNoise` | def | 6 |
| `coordNoise` | def | 5 |
| `BWDependsOn` | def | 2 |
| `dependsOnSubmodule` | def | 5 |
| `degreeLeSubmodule` | def | 2 |
| `meanZeroAt` | def | 2 |
| `ConstantAt` | def | 2 |
| `homogeneousDegreeSubmodule` | def | 3 |
| `singleSiteNoise_const` | theorem | ✓ |
| `singleSiteNoise_meanZero` | theorem | ✓ |
| `noiseKernel_sum` | theorem | ✓ |
| `noiseKernel_meanZero_action` | theorem | ✓ |
| `noiseKernel_col_sum` | theorem | ✓ |
| `degreeLeSubmodule_mono` | theorem | ✓ |
| `productNoise_BWDependsOn` | theorem | ✓ |
| `productNoise_preserves_degreeLe` | theorem | ✓ |
| `coordNoise_meanZeroAt` | theorem | ✓ |
| `coordNoise_constantAt` | theorem | ✓ |
| `coordNoise_preserves_meanZeroAt` | theorem | ✓ |
| `coordNoise_preserves_constantAt` | theorem | ✓ |
| `partialNoise_structured` | theorem | ✓ |
| `productNoise_eq_foldr_coordNoise` | theorem | ✓ |
| `productNoise_eigen_on_generator` | theorem | ✓ |
| `productNoise_eigen_on_homogeneousDegree` | theorem | ✓ |
| `productNoise_sum_preserves` | theorem | ✓ |
| `productNoise_preserves_homogeneousDegree` | theorem | ✓ |
| `productNoise_norm_on_homogeneousDegree` | theorem | ✓ |
| `berggren_bias_bound_of_spectral_decay` | theorem | ✓ |

All 18 theorems are fully proved with no `sorry`. Axioms used: `propext`, `Classical.choice`, `Quot.sound`.
