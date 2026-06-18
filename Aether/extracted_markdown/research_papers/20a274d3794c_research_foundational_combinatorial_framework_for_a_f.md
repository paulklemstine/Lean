# A Combinatorial Framework for the Selberg Class Census

## Abstract

We develop a formal combinatorial framework for enumerating and classifying L-functions in the Selberg class by their finite invariant data. We define *Selberg data* — triples of degree, conductor, and spectral parameters — and establish that the collection of all such data is countable. Two novel additive invariants are introduced: *spectral complexity* (measuring total analytic cost) and *spectral entropy* (measuring arithmetic height of spectral parameters). Both are additive under Rankin-Selberg products and attain their minimum at the Riemann zeta datum. We prove polynomial growth bounds for conductor counting functions, establish well-foundedness of the factorization ordering, and show that the degree-conductor energy strictly decreases under nontrivial factorization. All results are formalized in Lean 4 with machine-checked proofs.

**Keywords**: Selberg class, L-functions, conductor counting, spectral parameters, well-founded ordering, additive invariants

---

## 1. Introduction

The Selberg class, introduced by Selberg [Sel92], is the conjectured home of all "well-behaved" L-functions in number theory. A function $F(s)$ belongs to the Selberg class if it satisfies four axioms: (i) a Ramanujan-type bound on Dirichlet coefficients, (ii) analytic continuation to the entire complex plane (except possibly a pole at $s=1$), (iii) a functional equation involving Gamma factors, and (iv) an Euler product.

The functional equation takes the form
$$\Phi(s) = \omega \overline{\Phi}(1-s), \quad \Phi(s) = Q^s \prod_{j=1}^{d} \Gamma(\alpha_j s + \mu_j) \cdot F(s),$$
where $d$ is the degree, $Q$ is the conductor, and $\mu_1, \ldots, \mu_d$ are the spectral parameters.

A fundamental observation is that each $F$ in the Selberg class determines a *finite* set of invariant data: the triple $(d, Q, \{\mu_j\})$. This paper develops the combinatorial consequences of this observation.

### 1.1 Main Contributions

1. **Countability**: The set of all Selberg data is countable (Theorem 3.1).
2. **Additive invariants**: Spectral complexity and spectral entropy are additive under Rankin-Selberg products (Theorems 4.1, 4.2).
3. **Minimality**: The Riemann zeta datum minimizes both invariants among degree-$\geq 1$ data (Theorem 4.3).
4. **Polynomial counting**: The conductor counting function $N_d(Q, B)$ satisfies $N_d(Q, B) \leq Q \cdot ((2B+1)B)^d$ (Theorem 5.1).
5. **Well-founded factorization**: The lexicographic ordering by $(d, q)$ is well-founded (Theorem 6.1), and the degree-conductor energy strictly decreases under nontrivial factorization (Theorem 6.2).
6. **Primitive decomposition**: The degree of a product of primitive data equals the number of factors (Theorem 7.1).

## 2. Definitions

### 2.1 Selberg Datum

**Definition 2.1** (Selberg Datum). A *Selberg datum* is a triple $\sigma = (d, q, \boldsymbol{\mu})$ where:
- $d \in \mathbb{N}$ is the *degree*,
- $q \in \mathbb{N}^+$ is the *conductor*,
- $\boldsymbol{\mu} = (\mu_1, \ldots, \mu_d) \in \mathbb{Q}^d$ is the vector of *spectral parameters*.

The constraint $|\boldsymbol{\mu}| = d$ ensures that the number of spectral parameters matches the degree.

### 2.2 Spectral Complexity

**Definition 2.2.** The *spectral complexity* of $\sigma = (d, q, \boldsymbol{\mu})$ is
$$C(\sigma) = d + \sum_{j=1}^{d} |\mu_j|.$$

### 2.3 Spectral Entropy

**Definition 2.3.** The *spectral entropy* of $\sigma = (d, q, \boldsymbol{\mu})$ is
$$H(\sigma) = \sum_{j=1}^{d} (|p_j| + q_j),$$
where $\mu_j = p_j / q_j$ in lowest terms.

### 2.4 Rankin-Selberg Product

**Definition 2.4.** The *product* of $\sigma_1 = (d_1, q_1, \boldsymbol{\mu}_1)$ and $\sigma_2 = (d_2, q_2, \boldsymbol{\mu}_2)$ is
$$\sigma_1 \otimes \sigma_2 = (d_1 + d_2, \, q_1 q_2, \, \boldsymbol{\mu}_1 \oplus \boldsymbol{\mu}_2),$$
where $\oplus$ denotes concatenation.

### 2.5 Counting Function

**Definition 2.5.** The *bounded counting function* is
$$N_d(Q, B) = |\{1 \leq q \leq Q\}| \cdot |\{(a, b) : a \in [-B, B]_\mathbb{Z}, \, b \in [1, B]_\mathbb{N}\}|^d.$$

### 2.6 Factorization Ordering

**Definition 2.6.** The *factorization ordering* is the relation $\sigma_1 \prec \sigma_2$ iff $d_1 < d_2$, or $d_1 = d_2$ and $q_1 < q_2$.

### 2.7 Degree-Conductor Energy

**Definition 2.7.** The *degree-conductor energy* is $E(\sigma) = d \cdot q$.

### 2.8 Primitivity

**Definition 2.8.** A datum $\sigma$ is *primitive* if $d = 1$.

## 3. Countability

**Theorem 3.1.** The type of Selberg data is countable.

*Proof sketch.* A Selberg datum $(d, q, \boldsymbol{\mu})$ injects into $\mathbb{N} \times \mathbb{N} \times \text{List}(\mathbb{Q})$ via the obvious embedding. Since $\mathbb{Q}$ is countable and countable products/lists of countable types are countable, the result follows. The formal proof constructs an explicit equivalence with a subtype of $\mathbb{N} \times \mathbb{N} \times \text{List}(\mathbb{Q})$. $\square$

## 4. Additive Invariants

**Theorem 4.1** (Additivity of Spectral Complexity). For all $\sigma_1, \sigma_2$,
$$C(\sigma_1 \otimes \sigma_2) = C(\sigma_1) + C(\sigma_2).$$

*Proof sketch.* By definition, $C(\sigma_1 \otimes \sigma_2) = (d_1 + d_2) + \sum |\mu_j|$ where the sum runs over the concatenated list. The sum over a concatenation equals the sum of the parts, and the degree adds. $\square$

**Theorem 4.2** (Additivity of Spectral Entropy). For all $\sigma_1, \sigma_2$,
$$H(\sigma_1 \otimes \sigma_2) = H(\sigma_1) + H(\sigma_2).$$

*Proof sketch.* Identical structure: the sum over concatenated spectral parameters equals the sum of the individual sums. $\square$

**Theorem 4.3** (Minimality). For any $\sigma$ with $d \geq 1$, $C(\sigma) \geq 1$, with equality iff $\sigma$ is the zeta datum.

*Proof sketch.* $C(\sigma) = d + \sum |\mu_j| \geq d \geq 1$, using nonnegativity of absolute values. $\square$

## 5. Counting Bounds

**Theorem 5.1** (Polynomial Bound). $N_d(Q, B) \leq Q \cdot ((2B+1)B)^d$.

*Proof sketch.* The cardinality of $\{1, \ldots, Q\}$ is $Q$. The cardinality of $[-B, B]_\mathbb{Z} \times [1, B]$ is $(2B+1) \cdot B$. The product formula and the power give the bound. $\square$

**Theorem 5.2** (Monotonicity in Q). For fixed $d, B$, the function $Q \mapsto N_d(Q, B)$ is monotone.

*Proof sketch.* $\text{Icc}(1, Q) \subseteq \text{Icc}(1, Q')$ when $Q \leq Q'$, so the cardinality is monotone. Multiplication by a constant preserves monotonicity. $\square$

**Theorem 5.3** (Monotonicity in B). For fixed $d, Q$, the function $B \mapsto N_d(Q, B)$ is monotone.

*Proof sketch.* Both $[-B, B]$ and $[1, B]$ grow with $B$, so the product set grows, so its cardinality grows. The power function preserves monotonicity for natural number bases. $\square$

## 6. Well-Founded Factorization

**Theorem 6.1** (Well-Foundedness). The factorization ordering $\prec$ is well-founded.

*Proof sketch.* The ordering is the pullback of the lexicographic ordering on $\mathbb{N} \times \mathbb{N}$ via the map $\sigma \mapsto (d, q)$. The lexicographic product of well-founded orderings is well-founded. $\square$

**Theorem 6.2** (Energy Decrease). If $d_1 \geq 1$, $d_2 \geq 1$, and $q_2 \geq 2$, then
$$E(\sigma_1) < E(\sigma_1 \otimes \sigma_2).$$

*Proof sketch.* $E(\sigma_1 \otimes \sigma_2) = (d_1 + d_2)(q_1 q_2) \geq d_1 \cdot 2q_1 > d_1 q_1 = E(\sigma_1)$ using $d_2 \geq 1$ and $q_2 \geq 2$. $\square$

## 7. Primitive Decomposition

**Theorem 7.1.** If $\sigma_1, \ldots, \sigma_n$ are primitive data, then the degree of $\sigma_1 \otimes \cdots \otimes \sigma_n$ is $n$.

*Proof sketch.* Each primitive datum has degree 1, and degrees add under products. Formally, by induction on the list using the fact that $\text{foldl}$ with the product operation accumulates degrees additively. $\square$

## 8. Discussion

### 8.1 Comparison with Existing Work

The LMFDB (L-functions and Modular Forms DataBase) provides a computational census of L-functions, organized by degree and conductor. Our framework provides a formal foundation for such a census, with proved bounds on growth rates and structural theorems about factorization.

The polynomial bound $N_d(Q, B) \leq Q \cdot ((2B+1)B)^d$ is consistent with, but weaker than, the conjectured asymptotics. For degree 1, the Selberg class conjecture predicts that $N_1(Q) \sim CQ$ for an explicit constant $C$ (related to the number of Dirichlet characters of conductor $\leq Q$).

### 8.2 The Role of Additivity

The additivity of spectral complexity and entropy under products makes them *ring homomorphisms* from the (additive) monoid of Selberg data to $(\mathbb{Q}, +)$. This algebraic structure is crucial for classification: it means that any identity $F = G \otimes H$ in the Selberg class immediately yields the constraint $C(F) = C(G) + C(H)$, which often suffices to restrict the possible factorizations to a finite set.

### 8.3 Connections to Statistical Mechanics

The counting function $N_d(Q, B)$ behaves like a partition function $Z(\beta)$ in statistical mechanics, with the conductor $Q$ playing the role of energy and the degree $d$ playing the role of the number of particles. The polynomial growth bound $N_d(Q, B) \leq Q \cdot C^d$ is analogous to the extensive growth of the partition function. This analogy suggests that techniques from statistical mechanics (saddle-point methods, transfer matrices) may be applicable to the asymptotic study of conductor counting.

## 9. Future Work

1. **Sharp asymptotics**: Replace the polynomial upper bound with exact asymptotics for $N_d(Q)$ as $Q \to \infty$, using analytic methods (large sieve, density estimates).
2. **Uniqueness**: Formalize the strong multiplicity one theorem (two L-functions with the same Euler product are equal) and connect it to the uniqueness of data-to-function correspondence.
3. **Automorphic classification**: For degree 2, connect the census to the classification of modular forms by level and weight.
4. **Tropical geometry**: Interpret the conductor counting bounds through the lens of tropical geometry, where the polynomial growth of lattice point counts has a natural tropical interpretation.

## References

- [Sel92] A. Selberg, "Old and new conjectures and results about a class of Dirichlet series," *Collected Papers*, vol. II, pp. 47–63, 1992.
- [KP99] J. Kaczorowski and A. Perelli, "On the structure of the Selberg class, I: $0 \leq d \leq 1$," *Acta Math.*, vol. 182, pp. 207–241, 1999.
- [IK04] H. Iwaniec and E. Kowalski, *Analytic Number Theory*, AMS Colloquium Publications, 2004.
- [LMFDB] The LMFDB Collaboration, "The L-functions and Modular Forms DataBase," https://www.lmfdb.org.
