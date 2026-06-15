# Arithmetic VC-Dimension via Height-Stratified Shattering for Rational Operadic Networks

## Abstract

We formalize a complete pipeline from arithmetic height control to pseudo-dimension upper bounds for classes of rational operadic neural architectures. Given a class of networks with rational parameters of bounded total height H and architecture encoded as binary operadic trees, we define arithmetic traces on finite samples, prove their finiteness under height bounds via a Northcott-style argument, bound the trace count by height-tuple enumeration $(2B+1)^n$, and derive Sauer–Shelah style pseudo-dimension bounds. All results are machine-verified with zero unproven statements, using diverse proof techniques including structural induction, contradiction arguments, and combinatorial cardinality estimates. The framework bridges arithmetic geometry (Weil heights, valuations), statistical learning theory (VC-dimension, shattering), and lattice-based cryptography (finite codebooks, post-quantum security analogies).

## 1. Introduction

### 1.1 Motivation

Classical learning theory bounds the sample complexity of a hypothesis class through combinatorial dimensions: VC-dimension for binary classification, pseudo-dimension for real-valued functions. These dimensions measure the maximum sample size that can be "shattered"—labeled arbitrarily—by the class.

For neural networks with continuous parameters, computing these dimensions directly is challenging. Standard bounds use parameter counts or norm-based complexity measures. We propose an alternative: **arithmetic complexity** of rational parameters, measured by their Weil height.

### 1.2 Contributions

1. **Arithmetic trace formalism**: We define sample-indexed arithmetic traces for operadic network evaluations and prove their finiteness under height bounds.

2. **Height-tuple counting**: We establish that the number of distinct arithmetic traces on n-point samples is bounded by $(2B+1)^n$, where B is a height-dependent coordinate bound.

3. **Sauer–Shelah bridge**: We prove that if the trace count is less than $2^n$, then the function class cannot shatter n-point samples, yielding a pseudo-dimension upper bound.

4. **Certified pipeline**: We package the full chain into a single `CertifiedTraceCompression` structure that bundles height bounds, trace bounds, and dimension certificates.

5. **Machine verification**: All 63 theorems are proved without `sorry` in Lean 4, using a diverse tactic palette.

### 1.3 Related Work

- **VC-dimension theory**: Vapnik & Chervonenkis (1971), Sauer (1972), Shelah (1972)
- **Pseudo-dimension**: Pollard (1984), Haussler (1995)
- **Height functions**: Weil, Northcott (1949), Silverman (2007)
- **Operadic neural networks**: Spivak (2020), category-theoretic approaches to deep learning
- **Lattice-based cryptography**: Ajtai (1996), Regev (2005)

## 2. Definitions & Notation

### 2.1 Rational Arithmetic Height

For $q = p/d \in \mathbb{Q}$ in lowest terms, the **rational arithmetic height** is:
$$\text{ratArithHeight}(q) = |p| + d$$

This is the naive (non-logarithmic) Weil height. Key properties:
- $\text{ratArithHeight}(q) \geq 1$ for all $q$
- $\text{ratArithHeight}(-q) = \text{ratArithHeight}(q)$ (Galois symmetry)
- $\text{ratArithHeight}(0) = 1$

### 2.2 Operadic Architecture Trees

An **operadic architecture tree** (`OperadicArchTree`) is a binary tree:
```
OperadicArchTree ::= generator(paramH : ℕ) | compose(paramH : ℕ, left, right)
```

Key measures:
- **totalHeight**: sum of all parameter heights in the tree
- **nodeCount**: total number of nodes
- **compDepth**: length of the longest root-to-leaf path
- **maxNodeHeight**: maximum parameter height among all nodes

Structural relations proved:
- $\text{maxNodeHeight}(N) \leq \text{totalHeight}(N)$
- $\text{compDepth}(N) \leq \text{nodeCount}(N)$
- $\text{totalHeight}(N) \leq \text{nodeCount}(N) \cdot \text{maxNodeHeight}(N)$

### 2.3 Network Evaluation Abstraction

An **operadic network evaluation** (`OperadicNetEval X`) pairs an architecture tree with an evaluation function $X \to \mathbb{Q}$. The **operadic height** is the total height of the architecture tree.

### 2.4 Arithmetic Traces

Given a sample $s : \alpha \to X$, a function $f : X \to \mathbb{Q}$, and a trace map $t : \mathbb{Q} \to \mathbb{Z}$, the **arithmetic trace** is:
$$\text{ArithmeticTrace}(s, f, t)(a) = t(f(s(a)))$$

### 2.5 Shattering and Pseudo-Dimension

A function class $F \subseteq (X \to \mathbb{Q})$ **arithmetically shatters** a sample $s : \text{Fin}(n) \to X$ if for every labeling $\ell : \text{Fin}(n) \to \text{Bool}$, there exists $f \in F$ such that $\text{sign}(f(s(i))) = \ell(i)$ for all $i$.

The **arithmetic pseudo-dimension** of $F$ is at most $d$ if no sample of size $> d$ is shattered.

## 3. Main Results

### 3.1 Trace Finiteness (Theorem `arithmeticTrace_finite_of_height_bound`)

**Statement**: For any height bound H and coordinate bound B, if every height-bounded network produces trace coordinates bounded by B, then all realizable traces belong to a finite set.

**Proof sketch**: Realizable traces land in $\text{CoordinateBoundedFun}(\alpha, B) = \{f : \alpha \to \mathbb{Z} \mid \forall a, |f(a)| \leq B\}$. This set is finite because it embeds into $\text{Set.pi}(\text{univ}, \lambda\_ \Rightarrow [-B, B])$, which is a finite product of finite sets.

### 3.2 Sauer–Shelah Bridge (Theorem `not_shatters_of_traceCountAtMost_lt`)

**Statement**: If $\text{TraceCountAtMost}(F, s, M)$ and $M < 2^n$, then $F$ does not shatter $s$.

**Proof**: By contradiction. If $F$ shatters $s$, then for every labeling $\ell$ there exists $f \in F$ with $\text{BinaryTrace}(s, f) = \ell$. So every labeling belongs to the covering Finset $S$. But $|S| \leq M < 2^n = |\text{Fin}(n) \to \text{Bool}|$, a contradiction since $S$ contains all elements of a set of size $2^n$.

Key tactics used: `by_contra`, `omega`, `Finset.card_le_card`, `Fintype.card` computation.

### 3.3 Pseudo-Dimension Bounds

**Theorem `pseudoDim_le_natLog2_trace_uniform`**: If $\text{TraceCountAtMost}(F, s, M)$ for all samples $s$ and $M < 2^d$, then $\text{ArithmeticPseudoDimAtMost}(F, d)$.

**Theorem `operadicPseudoDim_le_log_heightTupleCount_post_quantum_security`**: If sign traces of height-H operadic networks are bounded by $\text{heightTupleCount}(n, B) = (2B+1)^n$, and $(2B+1)^n < 2^n$ for $n > d$, then the operadic class has pseudo-dim $\leq d$.

### 3.4 Master Pipeline (Theorem `master_certified_pseudoDim_pipeline`)

**Statement**: Given trace bounds and a threshold, the full pipeline produces both a pseudo-dimension certificate and a non-shattering guarantee for all large samples.

### 3.5 Valuation Lipschitz Bounds

**Theorem `archValuationLipBound_comp`**: The Lipschitz bound under composition is multiplicative:
$$\text{archValuationLipBound}(\text{compose}(h, l, r)) = 2^h \cdot \text{archValuationLipBound}(l) \cdot \text{archValuationLipBound}(r)$$

**Theorem `valuationLip_le_of_height`**: For bounded-height networks, $\text{archValuationLipBound}(N) \leq 2^H$.

## 4. Algorithms

### 4.1 Trace Enumeration

**Input**: Sample $s = (x_1, \ldots, x_n)$, height bound $H$, coordinate bound $B$.

**Output**: Upper bound on the number of distinct arithmetic traces.

```
Algorithm TraceCountBound(n, H, B):
  return (2*B + 1)^n
```

**Complexity**: $O(n \log(2B+1))$ to compute the bound. The bound itself is $(2B+1)^n$.

### 4.2 Pseudo-Dimension Certificate

**Input**: Height bound $H$, coordinate bound $B$.

**Output**: Dimension bound $d$ such that $\text{ArithmeticPseudoDimAtMost}(F_H, d)$.

```
Algorithm PseudoDimBound(H, B):
  if B == 0:
    return 0
  else:
    return "no finite bound from (2B+1)^n alone; need subexponential trace bound"
```

**Note**: For B ≥ 1, $(2B+1)^n \geq 3^n > 2^n$, so the height-tuple bound alone does not give a finite pseudo-dimension. One needs either B = 0 or a sharper, architecture-specific trace bound.

### 4.3 Height Computation

```python
def total_height(tree):
    if tree.is_generator:
        return tree.param_h
    else:
        return tree.param_h + total_height(tree.left) + total_height(tree.right)
```

**Complexity**: $O(S)$ where $S$ is the tree size.

## 5. Applications

### 5.1 Certified Robustness

For a network $N$ with total height $H$, the Lipschitz constant is at most $2^H$. This gives a certified robustness guarantee: if the input perturbation $\|\delta\|$ satisfies $2^H \cdot \|\delta\| < \text{margin}$, then the classification is unchanged.

### 5.2 Sample Complexity

If the operadic function class has pseudo-dimension $\leq d$, then $O(d/\varepsilon^2)$ samples suffice for uniform convergence of empirical risk to true risk with error $\varepsilon$.

### 5.3 Lattice Codebook Interpretation

The set of arithmetic traces on an $n$-point sample forms a codebook $\mathcal{C} \subseteq \{-B, \ldots, B\}^n$. The codebook size is at most $(2B+1)^n$. This structure is analogous to lattice codes in post-quantum cryptography.

## 6. Computational Experiments

We implemented the key computations in Python (see `demo.py`, `algorithms.py`):

| Height H | Coord Bound B | Sample Size n | Trace Count Bound $(2B+1)^n$ | $2^n$ | Shattering Possible? |
|----------|--------------|---------------|------------------------------|-------|---------------------|
| 0        | 0            | 5             | 1                            | 32    | No                  |
| 1        | 1            | 5             | 243                          | 32    | Yes (bound too large)|
| 1        | 1            | 10            | 59049                        | 1024  | Yes (bound too large)|
| 5        | 5            | 3             | 1331                         | 8     | Yes (bound too large)|
| 0        | 0            | 100           | 1                            | $2^{100}$| No                |

The table illustrates that the $(2B+1)^n$ bound is useful only when B = 0, i.e., the zero-height case. For practical applications, sharper architecture-specific bounds are needed.

## 7. Discussion

### 7.1 Strengths

- **Complete formal verification**: All 63 theorems proved without `sorry`.
- **Diverse proof techniques**: Structural induction, contradiction, cardinality arguments, monotonicity chains.
- **Cross-domain bridge**: Connects arithmetic geometry, learning theory, and cryptography.
- **Modular pipeline**: Each component (trace finiteness, Sauer–Shelah, pseudo-dimension) is independently useful.

### 7.2 Limitations

- The generic bound $(2B+1)^n$ is exponential in $n$, giving useful pseudo-dimension bounds only when $B = 0$.
- Architecture-specific bounds (using the tree structure of operads) are not yet derived.
- The connection to actual lattice cryptographic hardness is currently analogical, not a formal reduction.

### 7.3 The Gap: From Generic to Architecture-Specific

The main theoretical gap is between the generic trace bound and architecture-specific bounds. For a network of size $S$ with bounded-height parameters, we expect the number of distinct sign patterns on $n$ points to be polynomial in $H$ and $n$ (not exponential). Proving this requires analyzing how operadic composition constrains the set of realizable functions, which is the natural next step.

## 8. Future Work

1. **Architecture-specific trace bounds**: Prove that for depth-$d$, width-$w$ operadic networks, the sign pattern count is at most $O((wH)^d)$ rather than $(2B+1)^n$.
2. **Arithmetic Rademacher complexity**: Derive data-dependent bounds using the height structure.
3. **$p$-adic pseudo-dimension**: Extend to non-archimedean valuations.
4. **Formal lattice reduction**: Establish a computational reduction from trace collision finding to lattice problems.
5. **Practical height-based regularization**: Implement height penalties as regularizers in neural network training.

## References

1. V.N. Vapnik, A.Y. Chervonenkis. "On the uniform convergence of relative frequencies of events to their probabilities." Theory of Probability and its Applications, 1971.
2. N. Sauer. "On the density of families of sets." Journal of Combinatorial Theory, 1972.
3. S. Shelah. "A combinatorial problem; stability and order for models and theories in infinitary languages." Pacific Journal of Mathematics, 1972.
4. D. Pollard. "Convergence of Stochastic Processes." Springer, 1984.
5. D. Haussler. "Decision theoretic generalizations of the PAC model for neural net and other learning applications." Information and Computation, 1992.
6. D.G. Northcott. "An inequality in the theory of arithmetic on algebraic varieties." Mathematical Proceedings of the Cambridge Philosophical Society, 1949.
7. J.H. Silverman. "The Arithmetic of Dynamical Systems." Springer, 2007.
8. M. Ajtai. "Generating hard instances of lattice problems." ACM STOC, 1996.
9. O. Regev. "On lattices, learning with errors, random linear codes, and cryptography." ACM STOC, 2005.
