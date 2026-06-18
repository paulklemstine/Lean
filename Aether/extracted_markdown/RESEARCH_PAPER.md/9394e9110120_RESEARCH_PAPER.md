# Functorial Entropy: A Rigorous Theory of Information Loss for Functions Between Finite Types

## Abstract

We develop a rigorous theory of **functorial entropy** for functions between finite types. For a function *f : α → β*, we define the entropy *H(f)* as a weighted sum over the fibers of *f*, measuring the information loss when *f* is applied to a uniformly distributed input. We prove three main theorems: (1) the **zero-entropy characterization** (*H(f) = 0* if and only if *f* is injective); (2) the **post-composition monotonicity theorem** (*H(g ∘ f) ≥ H(f)* for all *g*), which is the functorial analog of the data processing inequality; and (3) the **entropy stabilization theorem** for endomorphisms (the entropy sequence *H(f), H(f²), H(f³), ...* eventually becomes constant). We introduce the **entropy rate** of an endomorphism and the **entropy spectrum** of a finite type as novel invariants, and formalize the **Landauer cost** as a bridge to computational thermodynamics. All main results have been formally verified.

**Keywords:** functorial entropy, data processing inequality, information loss, fiber partition, Landauer's principle, entropy rate

---

## 1. Introduction

The measurement of information loss under deterministic transformations is a fundamental problem at the intersection of information theory, algebra, and theoretical computer science. While Shannon's information theory [1] provides tools for measuring the information content of random variables and the capacity of communication channels, the information-destroying properties of the transformations themselves are less systematically studied.

In this paper, we develop a self-contained theory of **functorial entropy** for functions between finite types. Our approach is purely combinatorial: we define the entropy of a function *f : α → β* in terms of the sizes of its fibers (preimage sets), without requiring any measure-theoretic or probabilistic machinery beyond the uniform distribution on the domain.

### 1.1 Main Contributions

1. **Definitions.** We introduce the functorial entropy *H(f)*, the Landauer cost, the entropy rate of an endomorphism, and the entropy spectrum of a finite type.

2. **Zero-Entropy Characterization (Theorem 3.1).** We prove that *H(f) = 0* if and only if *f* is injective, establishing that injectivity is the precise combinatorial condition for zero information loss.

3. **Post-Composition Monotonicity (Theorem 4.1).** We prove that *H(g ∘ f) ≥ H(f)* for any functions *f : α → β* and *g : β → γ*. The proof uses the superadditivity of *t log t*, which we establish from first principles using the monotonicity of the logarithm.

4. **Entropy Stabilization (Theorem 5.1).** For endomorphisms *f : α → α*, the entropy sequence *H(fⁿ)* is monotone non-decreasing and eventually constant. This defines the entropy rate as a well-defined invariant.

5. **Entropy Spectrum.** We define the entropy spectrum of a finite type as the set of achievable entropy rates and prove that it always contains zero.

---

## 2. Definitions

### 2.1 Fiber Cardinality

**Definition 2.1.** Let *α, β* be finite types with *β* having decidable equality. For *f : α → β* and *b ∈ β*, the **fiber cardinality** of *f* at *b* is:

$$\text{fiberCard}(f, b) = |\\{a \in \alpha \mid f(a) = b\\}|$$

The fiber cardinality satisfies basic properties:
- *∑_b fiberCard(f, b) = |α|* (the fibers partition the domain)
- *fiberCard(f, b) ≤ |α|* for all *b*
- *fiberCard(f, b) = 0* if and only if *b ∉ range(f)*
- If *f* is injective, then *fiberCard(f, f(a)) = 1* for all *a*

### 2.2 Functorial Entropy

**Definition 2.2.** The **functorial entropy** of *f : α → β* is:

$$H(f) = \sum_{b \in \beta} \frac{\text{fiberCard}(f, b)}{|\alpha|} \cdot \log(\text{fiberCard}(f, b))$$

where *log* denotes the natural logarithm (with the convention *0 · log(0) = 0*).

**Remark.** This definition arises naturally from information theory. If *X* is uniformly distributed on *α*, then *H(f)* equals the conditional entropy *H(X | f(X))* — the expected uncertainty remaining about the input after observing the output. Equivalently, *H(f) = H(X) - H(f(X)) = log|α| - H_Shannon(fiber distribution)*.

### 2.3 Landauer Cost

**Definition 2.3.** The **Landauer cost** of *f : α → β* is defined as *L(f) = H(f)*. This formalizes Landauer's principle: the minimum thermodynamic work (in units of *kT ln 2*) required to implement *f* irreversibly equals the functorial entropy of *f*.

### 2.4 Entropy Rate and Spectrum

**Definition 2.4.** For an endomorphism *f : α → α* on a finite type:
- The **entropy sequence** is *h_n = H(f^n)* for *n ≥ 0*.
- The **entropy rate** is *ρ(f) = sup_n h_n*.
- The **entropy spectrum** of *α* is *Spec(α) = {ρ(f) : f : α → α}*.

---

## 3. Zero-Entropy Characterization

**Theorem 3.1.** *Let α be a nonempty finite type and f : α → β. Then H(f) = 0 if and only if f is injective.*

**Proof sketch.** The reverse direction is straightforward: if *f* is injective, then every fiber in the range has size 1, so each summand contributes *(1/|α|) · log(1) = 0*.

For the forward direction, suppose *H(f) = 0*. Each summand is non-negative (since *fiberCard(f,b) ∈ ℕ* implies *log(fiberCard(f,b)) ≥ 0*, and the coefficient *fiberCard(f,b)/|α| ≥ 0*). A sum of non-negative terms equaling zero forces each term to be zero. For *b* in the range of *f*, we have *fiberCard(f,b) ≥ 1*, so the coefficient is strictly positive. This forces *log(fiberCard(f,b)) = 0*, which for a natural number ≥ 1 implies *fiberCard(f,b) = 1*. Hence every fiber has size at most 1, and *f* is injective. ∎

**Corollary 3.2.** *A bijection has zero entropy.*

**Corollary 3.3.** *The identity function has zero entropy.*

---

## 4. Post-Composition Monotonicity

### 4.1 Superadditivity of *t log t*

The proof of the data processing inequality rests on a fundamental analytical inequality.

**Lemma 4.1 (Binary Superadditivity).** *For real numbers a, b ≥ 0:*

$$a \log a + b \log b \leq (a + b) \log(a + b)$$

**Proof.** For *a, b > 0*, rewrite the difference as:

$$(a+b)\log(a+b) - a\log a - b\log b = a\log\frac{a+b}{a} + b\log\frac{a+b}{b}$$

Since *a+b ≥ a* and *a+b ≥ b*, both logarithmic terms are non-negative. The cases *a = 0* or *b = 0* follow by direct computation using the convention *0 · log(0) = 0*. ∎

**Lemma 4.2 (Finitary Superadditivity).** *For non-negative reals w₁, ..., wₙ:*

$$\sum_i w_i \log w_i \leq \left(\sum_i w_i\right) \log\left(\sum_i w_i\right)$$

**Proof.** By induction on *n*, using Lemma 4.1 for the inductive step. ∎

### 4.2 Fiber Decomposition

**Lemma 4.3.** *For f : α → β and g : β → γ:*

$$\text{fiberCard}(g \circ f, c) = \sum_{b : g(b) = c} \text{fiberCard}(f, b)$$

**Proof.** The fiber *(g ∘ f)⁻¹(c)* decomposes as the disjoint union *⋃_{g(b)=c} f⁻¹(b)*. ∎

### 4.3 The Main Theorem

**Theorem 4.1 (Post-Composition Monotonicity / Data Processing Inequality).** *For any f : α → β and g : β → γ between finite types with decidable equality:*

$$H(f) \leq H(g \circ f)$$

**Proof sketch.** Factor out *1/|α|* from both sides. Regroup the sum *∑_b fiberCard(f,b) · log(fiberCard(f,b))* according to the fibers of *g*:

$$\sum_b n_b \log n_b = \sum_c \sum_{g(b)=c} n_b \log n_b$$

By Lemma 4.2 applied to each group (with *w_b = fiberCard(f,b)*):

$$\sum_{g(b)=c} n_b \log n_b \leq \left(\sum_{g(b)=c} n_b\right) \log\left(\sum_{g(b)=c} n_b\right) = m_c \log m_c$$

where *m_c = fiberCard(g ∘ f, c)* by Lemma 4.3. Summing over *c* gives the result. ∎

**Corollary 4.2.** *The Landauer cost cannot decrease under post-composition: L(f) ≤ L(g ∘ f).*

---

## 5. Entropy Rate and Stabilization

### 5.1 Monotonicity of the Entropy Sequence

**Proposition 5.1.** *The entropy sequence h_n = H(f^n) is monotone non-decreasing.*

**Proof.** By the iterate identity *f^{n+1} = f ∘ f^n* and post-composition monotonicity, *H(f^n) ≤ H(f ∘ f^n) = H(f^{n+1})*. ∎

### 5.2 The Stabilization Theorem

**Theorem 5.1 (Entropy Stabilization).** *For any endomorphism f : α → α on a finite type, there exists N such that H(f^n) = H(f^N) for all n ≥ N.*

**Proof sketch.** The entropy of *f^n* is determined by the fiber cardinality function *b ↦ fiberCard(f^n, b)*, which is a function *α → ℕ* bounded by *|α|*. There are only finitely many such functions (at most *(|α|+1)^{|α|}*). Therefore the entropy sequence takes values in a finite set. A monotone sequence in a finite set must eventually stabilize. ∎

**Corollary 5.2.** *The entropy rate ρ(f) = sup_n H(f^n) is achieved at some finite N: ρ(f) = H(f^N).*

### 5.3 The Entropy Spectrum

**Proposition 5.2.** *Zero is always in the entropy spectrum: 0 ∈ Spec(α).*

**Proof.** The identity function is a bijection, hence has entropy rate zero. ∎

---

## 6. Connections and Applications

### 6.1 Shannon's Information Theory

The functorial entropy is the conditional entropy *H(X | f(X))* when *X* is uniform on *α*. This connects our work to the full apparatus of Shannon's theory. The post-composition monotonicity theorem is precisely the data processing inequality in this setting.

### 6.2 Landauer's Principle and Reversible Computation

The identification of functorial entropy with Landauer cost provides a rigorous foundation for reasoning about the thermodynamics of computation. Key consequences:
- Reversible computations (bijections) have zero Landauer cost.
- Composing computations can only increase total Landauer cost.
- The entropy rate quantifies the asymptotic irreversibility of iterated computation.

### 6.3 Category Theory

The entropy of a function is a functor from the category of finite sets to *(ℝ, ≤)*. Post-composition monotonicity means this is a covariant functor when we use the opposite order: composing with more functions yields higher entropy. This perspective suggests generalizations to functors between arbitrary categories.

---

## 7. Future Work

1. **Composition Superadditivity.** Conjecture: for surjective *f : α → β* and any *g : β → γ*, *H(g) ≤ H(g ∘ f)*. This would be the "other half" of the data processing inequality.

2. **Entropy Spectrum Characterization.** Characterize which subsets of *[0, log n]* can arise as entropy spectra of *n*-element types.

3. **Entropy Rate Dynamics.** For endomorphisms, study the relationship between the entropy rate and the cycle structure (periodic points, eventual image).

4. **Categorical Generalization.** Extend the theory to functors between finite categories, measuring the "structure-forgetting" of a functor.

5. **Tropical Entropy Bridge.** Connect functorial entropy to tropical semiring computations, linking the min-plus algebra perspective to the information-theoretic perspective.

---

## 8. References

[1] C. E. Shannon, "A Mathematical Theory of Communication," *Bell System Technical Journal*, 27(3):379–423, 1948.

[2] R. Landauer, "Irreversibility and Heat Generation in the Computing Process," *IBM Journal of Research and Development*, 5(3):183–191, 1961.

[3] T. M. Cover and J. A. Thomas, *Elements of Information Theory*, 2nd edition, Wiley, 2006.

[4] S. Mac Lane, *Categories for the Working Mathematician*, 2nd edition, Springer, 1998.

[5] C. H. Bennett, "The Thermodynamics of Computation — A Review," *International Journal of Theoretical Physics*, 21(12):905–940, 1982.
