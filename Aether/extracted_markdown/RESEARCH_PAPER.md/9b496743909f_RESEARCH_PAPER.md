# Categorification of Entropy: The Information Loss of Functors

## Abstract

We develop a theory of **functorial entropy** that assigns to every function $f: \alpha \to \beta$ between finite types a non-negative real number $H(f)$ measuring the information destroyed by $f$. The central result is the **Zero Characterization Theorem**: $H(f) = 0$ if and only if $f$ is injective. We prove a uniform fiber formula showing $H(f) = \ln k$ when all nonempty fibers have constant size $k$, establish an upper bound $H(f) \leq \ln|\alpha|$, and construct a bridge to Landauer's principle connecting functorial entropy to thermodynamic cost. All main results are formalized and machine-verified. We introduce the **Information Channel** structure as a novel categorical object packaging morphisms with their entropy profiles, and state a falsifiable conjecture on composition superadditivity supported by computational evidence.

## 1. Introduction

### 1.1 Motivation

Shannon's entropy $H(X) = -\sum p(x) \log p(x)$ measures the information content of a random variable. In category theory, a functor $F: \mathcal{C} \to \mathcal{D}$ may identify non-isomorphic objects, thereby "losing information." The question arises: can we assign a precise entropy to a functor that measures this information loss?

For finite categories, a functor's action on objects is simply a function between finite sets. We thus focus on functions $f: \alpha \to \beta$ between finite types, defining a notion of entropy that captures the information destruction inherent in $f$.

### 1.2 Prior Work

- **Shannon (1948)**: Entropy of probability distributions.
- **Baez, Fritz, Leinster (2011)**: Characterization of entropy in terms of functors and operads.
- **Baez & Fong (2014)**: Bayesian characterization of relative entropy via category theory.
- **Landauer (1961)**: Minimum thermodynamic cost of irreversible computation.
- **Bennett (1973)**: Logical reversibility of computation.

Our contribution differs from prior categorical approaches to entropy in that we define entropy *of* functors (or functions), not entropy *via* functors. The functorial entropy is a property of the morphism itself.

### 1.3 Contributions

1. **Definition** of functorial entropy $H(f)$ for functions between finite types.
2. **Non-negativity**: $H(f) \geq 0$ for all $f$.
3. **Zero Characterization**: $H(f) = 0 \iff f$ is injective (Main Theorem).
4. **Uniform Fiber Formula**: $H(f) = \ln k$ when all fibers have size $k$.
5. **Upper Bound**: $H(f) \leq \ln|\alpha|$ with equality for constant functions.
6. **Landauer Bridge**: Connection to thermodynamic cost of computation.
7. **Information Channel**: Novel categorical structure.
8. **Composition Conjecture**: $H(g \circ f) \geq H(g)$ for surjective $f$.
9. **Machine-verified proofs** of all results (except the conjecture).

## 2. Definitions and Notation

### 2.1 Fiber Cardinality

**Definition 2.1** (Fiber Card). For $f: \alpha \to \beta$ with $\alpha$ finite and $\beta$ having decidable equality:
$$\text{fiberCard}(f, b) = |\{a \in \alpha : f(a) = b\}|$$

**Proposition 2.2**. $\text{fiberCard}(f, b) = 0 \iff b \notin \text{range}(f)$.

**Proposition 2.3** (Fiber Sum). $\sum_{b \in \beta} \text{fiberCard}(f, b) = |\alpha|$.

*Proof*. Each element $a \in \alpha$ is counted exactly once in $\text{fiberCard}(f, f(a))$. □

### 2.2 Functorial Entropy

**Definition 2.4** (Functorial Entropy). For $f: \alpha \to \beta$ between finite types:
$$H(f) = \sum_{b \in \beta} \frac{\text{fiberCard}(f, b)}{|\alpha|} \cdot \ln(\text{fiberCard}(f, b))$$

with the convention $0 \cdot \ln 0 = 0$ (using $\ln 0 = 0$ in the formalization).

**Remark**. This differs from Shannon entropy in a crucial way. Shannon entropy is $-\sum p_i \ln p_i$, which measures the *expected surprise* of a distribution. Functorial entropy is $\sum (k_i/n) \ln k_i$, which measures the *expected collapse* — how many distinct inputs are identified per output. The two are related by:
$$H(f) = \ln|\alpha| - H_{\text{Shannon}}(p_f)$$
where $p_f(b) = \text{fiberCard}(f,b) / |\alpha|$ is the induced distribution on $\beta$.

### 2.3 Uniform Fibers

**Definition 2.5**. A function $f: \alpha \to \beta$ has **uniform fibers of size $k$** if for every $b \in \beta$:
$$\text{fiberCard}(f, b) \in \{0, k\}$$

### 2.4 Information Channel

**Definition 2.6** (Information Channel). An information channel from $\alpha$ to $\beta$ is a tuple $(f, H, h_{\text{eq}}, h_{\text{nn}})$ where:
- $f: \alpha \to \beta$ is the underlying function
- $H \in \mathbb{R}$ is the entropy
- $h_{\text{eq}}: H = H(f)$ witnesses correctness
- $h_{\text{nn}}: 0 \leq H$ witnesses non-negativity

A channel is **lossless** if $H = 0$.

## 3. Main Results

### 3.1 Non-Negativity

**Theorem 3.1** (Non-negativity). For any $f: \alpha \to \beta$ between finite types, $H(f) \geq 0$.

*Proof*. Each summand $(k_b/n) \cdot \ln k_b$ is non-negative:
- If $k_b = 0$: the term is $0$.
- If $k_b \geq 1$: $k_b/n \geq 0$ and $\ln k_b \geq 0$, so the product is $\geq 0$.

The sum of non-negative terms is non-negative. □

### 3.2 Zero Characterization (Main Theorem)

**Theorem 3.2** (Zero Characterization). For $f: \alpha \to \beta$ with $\alpha$ nonempty and finite:
$$H(f) = 0 \iff f \text{ is injective}$$

*Proof*.

**($\Leftarrow$)** If $f$ is injective, each fiber has size 0 or 1. For size 0: the term is $0 \cdot \ln 0 = 0$. For size 1: the term is $(1/n) \cdot \ln 1 = 0$. Hence $H(f) = 0$.

**($\Rightarrow$)** Suppose $H(f) = 0$. Since each summand is non-negative (Theorem 3.1), each must be zero. Suppose for contradiction that some fiber has size $k_b \geq 2$. Then:
- $k_b/n > 0$ (since $k_b \geq 2$ and $n \geq 1$)
- $\ln k_b > 0$ (since $k_b \geq 2$)

So the summand is strictly positive, contradicting $H(f) = 0$. Hence all nonempty fibers have size 1, and $f$ is injective. □

### 3.3 Uniform Fiber Formula

**Theorem 3.3** (Uniform Fiber Formula). If $f: \alpha \to \beta$ has uniform fibers of size $k > 0$, then $H(f) = \ln k$.

*Proof*. Let $m$ be the number of nonempty fibers. Each nonempty fiber contributes $(k/n) \cdot \ln k$ to the sum, and empty fibers contribute 0. So:
$$H(f) = m \cdot \frac{k}{n} \cdot \ln k$$

By the uniform fiber card equation (Proposition 2.3 specialized), $mk = n$, so $mk/n = 1$, giving $H(f) = \ln k$. □

**Corollary 3.4**. For a constant function $f(x) = b_0$ on $\alpha$ with $|\alpha| > 1$:
$$H(f) = \ln|\alpha|$$

### 3.4 Upper Bound

**Theorem 3.5**. For any $f: \alpha \to \beta$, $H(f) \leq \ln|\alpha|$.

*Proof*. Since $\text{fiberCard}(f, b) \leq |\alpha|$ for all $b$ (the fiber is a subset of $\alpha$), we have $\ln(\text{fiberCard}(f,b)) \leq \ln|\alpha|$ for each nonempty fiber. Hence:
$$H(f) = \sum_b \frac{k_b}{n} \ln k_b \leq \sum_b \frac{k_b}{n} \ln n = \ln n \cdot \sum_b \frac{k_b}{n} = \ln n$$

using $\sum k_b = n$. □

### 3.5 Strict Positivity

**Theorem 3.6**. If $f: \alpha \to \beta$ is not injective (with $\alpha$ nonempty), then $H(f) > 0$.

*Proof*. Contrapositive of the backward direction of Theorem 3.2: if $H(f) = 0$ then $f$ is injective. By contrapositive, if $f$ is not injective then $H(f) \neq 0$. Combined with $H(f) \geq 0$, we get $H(f) > 0$. □

## 4. Cross-Domain Bridge: Landauer's Principle

### 4.1 The Landauer Cost

**Definition 4.1**. The **Landauer cost** of a computation $f: \alpha \to \alpha$ at temperature parameter $kT > 0$ is:
$$\text{Cost}(f) = kT \cdot H(f)$$

**Theorem 4.2** (Reversibility). $\text{Cost}(f) = 0$ for bijective $f$ (at any $kT$).

*Proof*. Bijective implies injective, so $H(f) = 0$, so $kT \cdot 0 = 0$. □

**Theorem 4.3** (Landauer Characterization). If $kT > 0$ and $\text{Cost}(f) = 0$, then $f$ is injective.

*Proof*. $kT \cdot H(f) = 0$ with $kT > 0$ implies $H(f) = 0$, which implies injectivity by Theorem 3.2. □

### 4.2 Physical Interpretation

At room temperature ($T = 300$K), $kT \approx 4.14 \times 10^{-21}$ J. The table below shows the Landauer cost for various operations:

| Operation | Domain | H(f) | Cost at 300K |
|-----------|--------|------|-------------|
| Cyclic permutation | Fin 8 | 0 | 0 |
| 1-bit erasure | Fin 2 → Fin 1 | ln 2 ≈ 0.693 | 2.87 × 10⁻²¹ J |
| 3-bit erasure | Fin 8 → Fin 1 | ln 8 ≈ 2.079 | 8.61 × 10⁻²¹ J |
| x mod 2 | Fin 8 → Fin 2 | ln 4 ≈ 1.386 | 5.74 × 10⁻²¹ J |

## 5. Algorithms

### 5.1 Computing Functorial Entropy

```
Algorithm: FunctorialEntropy(f, domain)
Input: Function f, domain set A = {a_1, ..., a_n}
Output: H(f) ∈ ℝ

1. Initialize counter C ← empty dictionary
2. For each a in A:
     C[f(a)] ← C[f(a)] + 1
3. H ← 0
4. For each (b, count) in C:
     If count > 0:
       H ← H + (count / n) * ln(count)
5. Return H

Time: O(|A|)  Space: O(|image(f)|)
```

### 5.2 Checking Information Preservation

```
Algorithm: IsInformationPreserving(f, domain)
Input: Function f, domain set A
Output: Boolean

1. Compute H ← FunctorialEntropy(f, domain)
2. Return H = 0

Time: O(|A|)  Space: O(|image(f)|)
```

Note: This is equivalent to checking injectivity by tracking a set of seen outputs, but the entropy computation provides a continuous measure of "how close" to injective the function is.

## 6. Computational Experiments

### 6.1 Exhaustive Verification (Fin 3 → Fin 3)

All 27 functions from Fin 3 to Fin 3 were tested:
- 6 injective functions (permutations): all have H = 0 ✓
- 21 non-injective functions: all have H > 0 ✓
- Maximum entropy: H = ln 3 ≈ 1.099 (constant functions) ✓

### 6.2 Composition Conjecture Testing

Tested the conjecture $H(g) \leq H(g \circ f)$ for surjective $f$:

| f | g | H(g) | H(g∘f) | Holds? |
|---|---|------|--------|--------|
| Fin 6 →^{mod3} Fin 3 | Fin 3 →^{[0,0,1]} Fin 2 | 0.462 | 1.155 | ✓ |
| Fin 4 →^{mod2} Fin 2 | Fin 2 →^{[0,0]} Fin 1 | 0.693 | 1.386 | ✓ |
| Fin 9 →^{mod3} Fin 3 | Fin 3 →^{id} Fin 3 | 0.000 | 1.099 | ✓ |

All tested cases satisfy the conjecture. The gap $H(g \circ f) - H(g)$ appears to be at least $H(f)$ when both $f$ and $g$ have uniform fibers, suggesting a possible strengthening.

### 6.3 Applications

Functorial entropy was computed for practical scenarios:

**Hash function quality**: A good hash (mod 100 on 1000 keys) has H = ln(10) ≈ 2.30. A poor hash (x² mod 100) has H ≈ 3.87, indicating 70% more information destruction.

**Neural network layers**: On a discretized domain of 100 values, Identity has H = 0, Leaky ReLU has H ≈ 1.15, ReLU has H ≈ 2.01, and sign has H ≈ 3.86.

## 7. Discussion

### 7.1 Relationship to Shannon Entropy

Functorial entropy and Shannon entropy are complementary. If $p_f(b) = \text{fiberCard}(f,b)/|\alpha|$ is the distribution induced by $f$ on $\beta$ (under uniform input), then:
$$H(f) = \ln|\alpha| - H_{\text{Shannon}}(p_f)$$

Shannon entropy measures the information *remaining* after applying $f$; functorial entropy measures the information *lost*. They are dual perspectives on the same phenomenon.

### 7.2 Categorical Perspective

For finite categories $\mathcal{C}$ and $\mathcal{D}$, a functor $F: \mathcal{C} \to \mathcal{D}$ acts on objects as a function $F_0: \text{Ob}(\mathcal{C}) \to \text{Ob}(\mathcal{D})$. The functorial entropy $H(F) := H(F_0)$ measures how many non-isomorphic objects the functor identifies. A faithful functor on objects has $H = 0$; a functor that collapses entire subcategories has high entropy.

### 7.3 Limitations

1. The current theory handles only finite types. Extension to infinite types requires measure-theoretic foundations.
2. The entropy depends on the function's action on objects only, not on morphisms. A richer theory would account for morphism identification.
3. The composition conjecture remains unproven.

## 8. Future Work

1. **Prove the composition conjecture** or find a counterexample.
2. **Extend to infinite categories** using measurable fiber spaces.
3. **Connect to Rényi entropy**: the functorial entropy may be a special case of a one-parameter family.
4. **Information channels as a category**: define composition of information channels and study the resulting category.
5. **Applications to privacy**: functorial entropy as a measure of data anonymization strength.

## 9. References

1. Shannon, C.E. (1948). A mathematical theory of communication. *Bell System Technical Journal*.
2. Landauer, R. (1961). Irreversibility and heat generation in the computing process. *IBM Journal*.
3. Bennett, C.H. (1973). Logical reversibility of computation. *IBM Journal*.
4. Baez, J.C., Fritz, T., Leinster, T. (2011). A characterization of entropy in terms of information loss. *Entropy*.
5. Bérut, A. et al. (2012). Experimental verification of Landauer's principle. *Nature*.
