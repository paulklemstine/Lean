# Quantum Berggren Fourier Duality via Primitive Triple Wavelets and Certified Period-Finding

## Abstract

We develop a rigorous multiresolution analysis (MRA) on the Berggren tree of primitive Pythagorean triples. For each depth n, we identify the 3ⁿ tree nodes with words in a ternary alphabet and construct an explicit Haar wavelet basis on the function space V_n = (BergWord n → ℂ). We prove:

1. **Exact Reconstruction**: A telescoping decomposition via conditional expectations at prefix levels yields perfect signal recovery.
2. **Spectral Sparsity**: Functions constant on k-prefix cylinders have exactly zero wavelet coefficients at all scales ≥ k.
3. **Wavelet Basis Existence**: An explicit orthogonal wavelet system of dimension 3ⁿ spans the full function space.
4. **Certified Robust Recovery**: Under bounded perturbation, fine-scale wavelet coefficients are controlled by the noise level.
5. **Berggren Arithmetic Invariance**: All tree evaluations produce Pythagorean triples, certified via Lorentz form preservation.

All results are formally verified in Lean 4 with the Mathlib library, requiring only the standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

### 1.1 Background

The Berggren tree [Berggren 1934, Barning 1963, Hall 1970] provides a complete enumeration of primitive Pythagorean triples through a ternary branching process. Starting from the root (3, 4, 5), three generator matrices A, B, C ∈ GL₃(ℤ) produce all primitive triples without repetition. The generators preserve the Lorentzian quadratic form Q(a,b,c) = a² + b² - c², placing them in the integer orthogonal group O(2,1;ℤ).

While the combinatorial and number-theoretic properties of the Berggren tree are well-studied, its harmonic-analytic structure has received little attention. This paper establishes the Berggren tree as a natural domain for finite multiresolution analysis, connecting:

- **Algebraic generation** of Diophantine solutions via matrix monoid actions,
- **Finite harmonic analysis** on rooted ternary trees via Haar wavelets,
- **Arithmetic signal processing** with spectral sparsity guarantees,
- **Quantum-inspired period detection** with certified robustness.

### 1.2 Main Contributions

We identify depth-n Berggren nodes with words w ∈ {0,1,2}ⁿ = Fin n → Fin 3, which we denote BergWord n. The function space LayerFun n := BergWord n → ℂ has dimension 3ⁿ. Our main results, all formally verified, are:

**Theorem A (Reconstruction).** For every f ∈ LayerFun n and every word w,
$$f(w) = E_0[f](w) + \sum_{k=0}^{n-1} (E_{k+1}[f](w) - E_k[f](w))$$
where E_k denotes conditional expectation at prefix level k.

**Theorem B (Sparsity).** If f is constant on k-prefix cylinders and j ≥ k, then E_{j+1}[f] - E_j[f] = 0.

**Theorem C (Perfect Reconstruction).** The explicit wavelet transform, defined via detail wavelets ψ_{k,u,0} and ψ_{k,u,1}, satisfies waveletReconstruct(f) = f for all f.

**Theorem D (Arithmetic Invariance).** For all words w, the evaluation berggrenEval(w) satisfies the Pythagorean equation a² + b² = c², proved via preservation of the Lorentz form under matrix multiplication.

**Theorem E (Certified Recovery).** If f is k-prefix-constant, then for j ≥ k, the detail coefficient of any signal g equals the detail coefficient of the perturbation g - f.

## 2. Definitions and Notation

### 2.1 Berggren Words and Evaluation

A **Berggren word** of depth n is a function w : Fin n → Fin 3, equivalently a sequence of n letters from {A, B, C}. The **word matrix** is defined recursively:

```
berggrenWordMat(ε) = I₃
berggrenWordMat(g · w') = M_g · berggrenWordMat(w')
```

where M₀ = A, M₁ = B, M₂ = C are the standard Berggren generators:

```
A = [[1,-2,2],[2,-1,2],[2,-2,3]]
B = [[1,2,2],[2,1,2],[2,2,3]]
C = [[-1,2,2],[-2,1,2],[-2,2,3]]
```

The **evaluation** berggrenEval(w) = berggrenWordMat(w) · (3,4,5)ᵀ produces a primitive Pythagorean triple.

### 2.2 Prefix Operations

The **word prefix** restricts a word to its first k letters:

```
wordPrefix(w, k) = λ i : Fin k. w(i)
```

A function f is **k-prefix-constant** if wordPrefix(w₁, k) = wordPrefix(w₂, k) implies f(w₁) = f(w₂).

The **cylinder set** of a prefix u ∈ BergWord k is:

```
cylSet(k, u) = {w ∈ BergWord n | wordPrefix(w, k) = u}
```

with |cylSet(k, u)| = 3^(n-k).

### 2.3 Conditional Expectation

The **conditional expectation** at level k is:

```
condExp(k, f, w) = (1/3^(n-k)) · Σ_{v ∈ cylOf(k,w)} f(v)
```

where cylOf(k, w) = cylSet(k, wordPrefix(w, k)).

### 2.4 Scaling and Detail Submodules

The **scaling space** at level k is the ℂ-submodule:

```
scalingSpace(n, k) = {f : LayerFun n | f is k-prefix-constant}
```

The **detail space** at level k is:

```
detailSpace(n, k) = {f ∈ scalingSpace(n, k+1) | ∀ u : BergWord k, Σ_{w ∈ cyl(u)} f(w) = 0}
```

We proved: scalingSpace(n, j) ≤ scalingSpace(n, k) for j ≤ k, and detailSpace(n, k) ≤ scalingSpace(n, k+1).

### 2.5 Wavelet Basis Functions

For each level k < n, prefix u ∈ BergWord k, we define two detail wavelets:

**Flavor 0** (child-0 vs child-1 contrast):
```
ψ₀(k,u)(w) = 1  if prefix(w,k)=u and w[k]=0
            = -1 if prefix(w,k)=u and w[k]=1
            = 0  otherwise
```

**Flavor 1** (children {0,1} vs child 2):
```
ψ₁(k,u)(w) = 1  if prefix(w,k)=u and w[k]=0
            = 1  if prefix(w,k)=u and w[k]=1
            = -2 if prefix(w,k)=u and w[k]=2
            = 0  otherwise
```

The **scaling wavelet** is φ(w) = 1 for all w.

## 3. Main Results

### 3.1 Reconstruction Theorem

**Theorem (berggren_reconstruction).** For all f : LayerFun n and w : BergWord n:

$$f(w) = \text{condExp}(0, f, w) + \sum_{k=0}^{n-1} [\text{condExp}(k+1, f, w) - \text{condExp}(k, f, w)]$$

*Proof sketch.* This is a telescoping sum. By condExp_self, condExp(n, f, w) = f(w) (since the cylinder at depth n is {w}). By condExp_zero, condExp(0, f, w) is the global average. The sum telescopes to condExp(n) - condExp(0) + condExp(0) = condExp(n) = f. The formal proof uses Fin.sum_univ_succ and Fin.sum_univ_castSucc to manage the telescoping. □

### 3.2 Spectral Sparsity

**Theorem (detail_vanishes_of_prefix_constant).** If f is k-prefix-constant and j ≥ k, then condExp(j+1, f, w) - condExp(j, f, w) = 0 for all w.

*Proof sketch.* Since f is k-prefix-constant and k ≤ j, f is constant on j-prefix cylinders. Within any j-cylinder, all words share the same j-prefix, hence the same k-prefix, so f is constant there. The conditional expectation E_j[f](w) therefore equals f(w), and similarly E_{j+1}[f](w) = f(w). Their difference is zero. □

**Corollary (sparse_reconstruction_of_prefix_constant).** A k-prefix-constant function is exactly reconstructed from only k detail levels plus the global average.

### 3.3 Wavelet Perfect Reconstruction

**Theorem (berggren_wavelet_perfect_reconstruction).** For all f : LayerFun n and w : BergWord n:

$$f(w) = c_0 \cdot \phi(w) + \sum_{k=0}^{n-1} \sum_{u \in \text{BergWord}(k)} [c_{k,u,0} \cdot \psi_0(k,u)(w) + c_{k,u,1} \cdot \psi_1(k,u)(w)]$$

where c₀ = ⟨f, φ⟩/‖φ‖² is the scaling coefficient and c_{k,u,j} = ⟨f, ψ_j(k,u)⟩/‖ψ_j(k,u)‖² are the detail coefficients.

*Proof sketch.* The proof reduces to the telescoping reconstruction by showing that the wavelet contributions at each level k reconstruct the conditional expectation increment E_{k+1}[f] - E_k[f]. Within each k-cylinder, the two wavelets span the 2-dimensional subspace of mean-zero functions constant on (k+1)-cylinders, which is exactly the detail space. □

### 3.4 Orthogonality

We proved three orthogonality theorems:

1. **Cross-level**: wavelets at different levels are orthogonal (different support structure)
2. **Cross-prefix**: wavelets at the same level but different prefixes are orthogonal (disjoint support)
3. **Cross-flavor**: ψ₀ and ψ₁ at the same node are orthogonal (by the identity 1·1 + (-1)·1 + 0·(-2) = 0)

These together establish that the wavelet system is an orthogonal basis for the counting-measure inner product on LayerFun n.

### 3.5 Certified Robust Recovery

**Theorem (certified_robust_recovery).** If f is k-prefix-constant and j ≥ k, then for any signal g:

$$\text{detailCoeff}_0(j, u, g) = \text{detailCoeff}_0(j, u, g - f)$$

*Proof.* By linearity of detailCoeff₀ and the vanishing theorem: detailCoeff₀(j, u, g) = detailCoeff₀(j, u, g-f) + detailCoeff₀(j, u, f) = detailCoeff₀(j, u, g-f) + 0. □

This means that fine-scale coefficients of a noisy observation g = f + noise depend only on the noise, not on the signal. If the noise is bounded, the fine-scale coefficients are bounded, enabling certified detection of the signal's sparsity structure.

### 3.6 Berggren Arithmetic

**Theorem (berggrenEval_is_pythagorean).** For all words w of any length, the evaluation berggrenEval(w) satisfies the Pythagorean equation.

*Proof.* By induction on word length. The base case is root_is_pythagorean. The inductive step uses berggrenMat_preserves_lorentz: each generator matrix M satisfies Q(Mv) = Q(v) for all v, where Q(a,b,c) = a²+b²-c². Since Q(3,4,5) = 0, we have Q(berggrenEval(w)) = 0 for all w. □

## 4. Algorithms

### 4.1 Forward Wavelet Transform

**Input:** Signal f ∈ ℂ^(3^n), tree depth n
**Output:** Wavelet coefficients {c₀, c_{k,u,j}}

```
FORWARD-TRANSFORM(f, n):
    c₀ ← mean(f)
    for k = 0 to n-1:
        for each prefix u of length k:
            for j ∈ {0, 1}:
                ψ ← WAVELET(k, u, j)
                c_{k,u,j} ← ⟨f, ψ⟩ / ‖ψ‖²
    return all coefficients
```

**Complexity:** O(3ⁿ · n) time, O(3ⁿ) space.

### 4.2 Inverse Transform (Reconstruction)

**Input:** Wavelet coefficients, tree depth n
**Output:** Reconstructed signal f ∈ ℂ^(3^n)

```
INVERSE-TRANSFORM(coefficients, n):
    f ← c₀ · 1
    for k = 0 to n-1:
        for each prefix u of length k:
            for j ∈ {0, 1}:
                f ← f + c_{k,u,j} · WAVELET(k, u, j)
    return f
```

**Complexity:** O(3ⁿ · n) time, O(3ⁿ) space.

### 4.3 Sparse Recovery

**Input:** Noisy signal g, known sparsity level k
**Output:** Recovered signal f̂

```
SPARSE-RECOVERY(g, k, n):
    coefficients ← FORWARD-TRANSFORM(g, n)
    for each (level, u, j) with level ≥ k:
        coefficients[level, u, j] ← 0
    return INVERSE-TRANSFORM(coefficients, n)
```

**Complexity:** O(3ⁿ · n) time.

### 4.4 Period Detection

**Input:** Signal g (possibly noisy), noise bound ε
**Output:** Detected prefix depth k̂

```
DETECT-PREFIX-DEPTH(g, ε, n):
    coefficients ← FORWARD-TRANSFORM(g, n)
    for k = n-1 down to 0:
        max_coeff ← max |c_{k,u,j}| over all u, j
        if max_coeff > ε · √2:
            return k + 1
    return 0
```

**Complexity:** O(3ⁿ · n) time.

## 5. Computational Experiments

### 5.1 Reconstruction Accuracy

We verified perfect reconstruction at depths 1-4:

| Depth | Nodes | Max Error |
|-------|-------|-----------|
| 1 | 3 | 5.55e-17 |
| 2 | 9 | 2.22e-16 |
| 3 | 27 | 2.22e-16 |
| 4 | 81 | 4.44e-16 |

Errors are at machine precision, confirming the theoretical guarantee.

### 5.2 Sparsity Verification

For signals constant on k-prefix cylinders at depth 3 (27 nodes, 26 detail coefficients):

| k | Coarse coeffs | Fine coeffs (=0) |
|---|---------------|-------------------|
| 0 | 0 | 26/26 vanish |
| 1 | 2 | 24/26 vanish |
| 2 | 8 | 18/18 vanish |
| 3 | 26 | 0/0 vanish |

### 5.3 Modular Observables

Hypotenuse mod q exhibits interesting sparsity patterns:

| q | Sparsity | Residue distribution |
|---|----------|---------------------|
| 2 | 100% | {1: 81} (all hypotenuses are odd) |
| 4 | 100% | {1: 81} (all hypotenuses ≡ 1 mod 4) |
| 3 | 45% | {1: 36, 2: 45} |
| 5 | 12.5% | {0:21, 1:18, 2:14, 3:14, 4:14} |

The complete sparsity mod 2 and mod 4 reflects the known fact that hypotenuses of primitive triples are always odd and ≡ 1 (mod 4).

### 5.4 Energy Spectrum

| Observable | Scaling | L0 | L1 | L2 | L3 |
|-----------|---------|-----|-----|-----|-----|
| Hypotenuse c | 0.620 | 0.077 | 0.091 | 0.102 | 0.110 |
| Side a | 0.584 | 0.073 | 0.085 | 0.097 | 0.161 |
| a - b | 0.000 | 0.000 | 0.000 | 0.006 | 0.994 |

The energy spectrum reveals structural information: hypotenuse energy is dominated by the global average (smooth function), while a - b energy is concentrated at the finest scale (maximally rough function).

## 6. Discussion

### 6.1 Significance

This work establishes the Berggren tree as a natural domain for finite harmonic analysis, creating a new interface between:

1. **Number theory**: The Berggren tree is a fundamental object in the theory of Pythagorean triples.
2. **Harmonic analysis**: The wavelet decomposition provides a complete spectral calculus.
3. **Signal processing**: Sparsity and compression theorems have practical algorithmic implications.
4. **Quantum-inspired algorithms**: Period detection on the tree mirrors the structure of quantum Fourier sampling.

### 6.2 Relation to Prior Work

The Berggren tree has been studied extensively from the perspectives of:
- Linear algebra over ℤ (generators as elements of O(2,1;ℤ))
- Combinatorics (tree enumeration, growth rates)
- Cryptographic hardness (search problems on the tree)

Our contribution is to introduce *harmonic analysis* as a new tool for studying this structure, and to provide *machine-verified proofs* of all main results.

### 6.3 Limitations

The current formalization is restricted to bounded-depth trees. Extension to the infinite tree boundary would require measure-theoretic machinery (σ-algebras, conditional expectations in the measure-theoretic sense) that goes beyond finite-dimensional linear algebra.

## 7. Future Work

See FUTURE_DIRECTIONS.md for detailed research roadmap.

## References

1. B. Berggren, "Pytagoreiska trianglar" (Pythagorean triangles), *Tidskrift för Elementär Matematik, Fysik och Kemi* 17, 129–139 (1934).
2. F. J. M. Barning, "Over pythagorische en bijna-pythagorische driehoeken en een generatieproces met behulp van unimodulaire matrices," *Math. Centrum Amsterdam Afd. Zuivere Wisk.* ZW-011 (1963).
3. A. Hall, "Genealogy of Pythagorean triads," *The Mathematical Gazette* 54(390), 377–379 (1970).
4. R. C. Alperin, "The modular tree of Pythagoras," *The American Mathematical Monthly* 112(9), 807–816 (2005).
5. D. Romik, "The dynamics of Pythagorean triples," *Transactions of the AMS* 360, 6045–6064 (2008).
6. S. Mallat, *A Wavelet Tour of Signal Processing*, 3rd ed. (Academic Press, 2009).
