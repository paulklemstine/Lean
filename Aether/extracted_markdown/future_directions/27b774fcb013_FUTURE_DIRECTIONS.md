# Future Directions: Product Noise Spectral Calculus on Berggren Word Cubes

This document outlines breakthrough-level research opportunities opened by the formalization of exact spectral decomposition for the product noise operator on `(Fin 3)^L`.

---

## 1. Hypercontractivity on Ternary Product Spaces

**Theorem target (Bonami–Beckner for q = 3):**
For `1 ≤ p ≤ q` and `ρ² ≤ (p − 1)/(q − 1)`,

$$\|T_\rho f\|_q \leq \|f\|_p$$

where $T_\rho$ is the product noise operator `productNoise L ρ` and norms are with respect to the uniform measure on `(Fin 3)^L`.

**Why it matters:**
Hypercontractivity is the engine behind sharp threshold phenomena, optimal influence inequalities, and noise sensitivity analysis. On the Boolean cube ($q = 2$), this inequality due to Bonami and Beckner is one of the most consequential results in discrete analysis. Extending it to the ternary cube unlocks the same toolkit for three-valued symbolic systems—directly relevant to Berggren-generated structures.

**Proof strategy:**
1. Prove the single-site ($L = 1$) Bonami–Beckner inequality for $\text{Fin } 3 \to \mathbb{R}$ by explicit computation on the 3-dimensional space.
2. Tensorize: show that the $L$-site inequality follows from the $L = 1$ case by the product structure of the noise operator. Use the eigenspace decomposition from `productNoise_eigen_on_homogeneousDegree` to reduce to degree-by-degree bounds.
3. Derive consequences: level-$d$ inequalities, moment bounds.

**Dependencies:** `productNoise_eigen_on_homogeneousDegree`, `singleSiteNoise_meanZero`, `berggrenInner`.

---

## 2. KKL/Influence Theory for Ternary Observables

**Theorem target (KKL-type inequality):**
For any balanced function $f : (\text{Fin } 3)^L \to \{-1, 0, 1\}$ with $\mathbb{E}[f] = 0$:

$$\max_i \text{Inf}_i(f) \geq \text{Var}(f) \cdot \frac{C \log L}{L}$$

where $\text{Inf}_i(f) = \mathbb{E}_x[\text{Var}_{x_i}(f)]$ is the influence of coordinate $i$.

**Why it matters:**
The Kahn–Kalai–Linial theorem is the foundation of the theory of Boolean functions. Its ternary analogue would give sharp lower bounds on the influence of coordinates in any balanced observable on Berggren word space—relevant to understanding which positions in a Berggren encoding are "most important" for arithmetic properties.

**Proof strategy:**
1. Define coordinate influence via the degree-1 Fourier mass at coordinate $i$.
2. Express total influence as the sum of squared Fourier coefficients weighted by degree, using the homogeneous decomposition.
3. Prove the logarithmic lower bound via hypercontractivity (Direction 1) and a level-$d$ inequality.

**Dependencies:** `homogeneousDegreeSubmodule`, `meanZeroAt`, `berggrenInner`, Direction 1.

---

## 3. Exact Decomposition Equivalence

**Theorem target:**
The degree-$\leq k$ submodule defined via coordinate dependence equals the direct sum of homogeneous degree sectors:

$$\texttt{degreeLeSubmodule } L\, k = \bigoplus_{d=0}^{k} \texttt{homogeneousDegreeSubmodule } L\, d$$

**Why it matters:**
The current formalization defines two natural notions of "low-degree": functions depending on at most $k$ coordinates (`degreeLeSubmodule`) and functions in the span of pure tensors with at most $k$ mean-zero factors (`homogeneousDegreeSubmodule`). Their equivalence is mathematically natural but non-trivial. Proving it formally bridges the combinatorial (coordinate dependence) and spectral (Fourier degree) perspectives.

**Proof strategy:**
1. Show that generators of `homogeneousDegreeSubmodule L d` depend on at most `d` coordinates, giving `⊕_{d ≤ k} ⊆ degreeLeSubmodule L k`.
2. For the reverse inclusion, take any function depending on coordinates in $S$ with $|S| \leq k$. Decompose it via the ternary Fourier expansion restricted to coordinates in $S$. Show each Fourier component is in the appropriate homogeneous degree submodule.
3. Prove that the homogeneous degree submodules are linearly independent (they have distinct eigenvalues under `productNoise` for generic $\rho$).

**Dependencies:** `degreeLeSubmodule`, `homogeneousDegreeSubmodule`, `productNoise_eigen_on_homogeneousDegree`, `productNoise_preserves_degreeLe`.

---

## 4. Thermodynamic Formalism Bridge

**Theorem target:**
For a Berggren transfer operator $\mathcal{L}_\beta$ defined by

$$\mathcal{L}_\beta f(x) = \sum_{y : \sigma(y) = x} e^{-\beta E(y)} f(y)$$

where $\sigma$ is the shift map and $E$ is an energy functional that decomposes as a sum of local potentials, show that the spectral decomposition of $\mathcal{L}_\beta$ can be expressed in terms of `productNoise`-like operators with coordinate-dependent noise parameters.

**Why it matters:**
Transfer operators (Ruelle–Perron–Frobenius operators) are the central objects in thermodynamic formalism and dynamical systems. Connecting them to the product noise framework creates a certified spectral laboratory: exact eigenvalues, controlled spectral gaps, and provable decay-of-correlations estimates—all within the same Lean framework.

**Proof strategy:**
1. Define the Berggren shift operator on `BerggrenFn L` for cylinder functions.
2. For separable potentials $E(x) = \sum_i \phi(x_i)$, show $\mathcal{L}_\beta$ factors as a product of single-site operators.
3. Compute the spectrum of each single-site factor and apply the tensor product eigenvalue theorem.
4. For non-separable potentials, express $\mathcal{L}_\beta$ as a perturbation of a product operator and bound the spectral gap using `productNoise_eigen_on_homogeneousDegree`.

**Dependencies:** `productNoise`, `coordNoise`, `homogeneousDegreeSubmodule`, thermodynamic formalism definitions from `Pythagorean.ThermodynamicFormalism.Core`.

---

## 5. Arithmetic Observable Bias via Spectral Decay

**Theorem target:**
Let $f : (\text{Fin } 3)^L \to \mathbb{R}$ encode an arithmetic observable on Berggren-generated Pythagorean triples (e.g., divisibility by a prime $p$, parity of the hypotenuse). Then:

$$|\text{Bias}_\rho(f)| \leq |\rho|^{k+1} \cdot \|f_{\geq k+1}\|_2$$

where $f_{\geq k+1}$ is the projection onto homogeneous degrees $> k$ and $\text{Bias}_\rho(f) = \langle T_\rho f, \mathbf{1} \rangle$.

**Why it matters:**
This gives quantitative pseudorandomness for Berggren-generated arithmetic data: if the noise parameter $\rho$ is bounded away from 1, high-degree observables have exponentially small correlation with constants. This means arithmetic statistics that depend on many coordinates of the Berggren encoding are "random-looking" under noise—a formal bridge between symbolic dynamics and arithmetic statistics.

**Proof strategy:**
1. Decompose $f = \sum_d f_d$ using `productNoise_eigen_on_homogeneousDegree`.
2. Observe that $T_\rho f = \sum_d \rho^d f_d$, so $\langle T_\rho f, \mathbf{1} \rangle = \rho^0 \langle f_0, \mathbf{1} \rangle$ since $\langle f_d, \mathbf{1} \rangle = 0$ for $d > 0$ (mean-zero).
3. For the bias relative to a test function $g$ with $g \in \text{degreeLeSubmodule } L\, k$: use Cauchy–Schwarz and the eigenvalue bound $|\rho^d| \leq |\rho|^{k+1}$ for $d > k$.

**Dependencies:** `productNoise_eigen_on_homogeneousDegree`, `berggrenInner`, `noiseBias`, Direction 3 (decomposition equivalence).

---

## Cross-Cutting Themes

All five directions converge on a single vision: **the ternary cube as a certified spectral laboratory** for arithmetic, dynamical, and combinatorial phenomena. The product noise operator is the universal tool—its exact spectrum is the key that unlocks sharp quantitative results across domains.

### Priority Order
1. **Direction 3** (decomposition equivalence) — foundational, enables all others
2. **Direction 1** (hypercontractivity) — most impactful single result
3. **Direction 5** (arithmetic bias) — most directly applicable to the Berggren program
4. **Direction 2** (KKL/influence) — deep consequences for understanding arithmetic complexity
5. **Direction 4** (thermodynamic bridge) — longest-term payoff, connects to broadest audience
