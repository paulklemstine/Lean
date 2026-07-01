# The Width Invariant of $\mathbb{Z}_2 \times (\mathbb{Z}_2)^n$ and Its Tropical Dual

## Abstract

We study the finite abelian $2$-group $G_n = \mathbb{Z}_2 \times (\mathbb{Z}_2)^n$ through its canonical identification with the vertex set of the $(n+1)$-dimensional discrete hypercube, equivalently with the Boolean lattice $B_{n+1}$ of subsets of an $(n+1)$-element set ordered by inclusion. We define and characterize the *width invariant*

$$\beta(G_n) = \binom{n+1}{\lfloor (n+1)/2 \rfloor},$$

the size of the largest rank layer of $B_{n+1}$. We give an explicit additive-group isomorphism $G_n \cong (\mathbb{Z}_2)^{n+1}$, compute the size of each rank layer as a binomial coefficient, show that the layers partition the group so that their sizes sum to $2^{n+1}$, and prove that $\beta(G_n)$ is exactly the maximum layer size (attained at the middle layer). Finally we exhibit a *tropical dual*: under min-plus arithmetic, the aggregation of the rank profile collapses to the minimum layer size, which is always $1$. This pairs the classical (max) width with its tropical (min) counterpart on a single rank profile. All results are elementary consequences of standard finite-poset and binomial identities; the contribution is a clean, fully self-contained treatment.

**Keywords:** Boolean lattice, hypercube, elementary abelian 2-group, binomial coefficients, poset width, Sperner theory, tropical semiring, min-plus algebra, rank profile.

---

## 1. Introduction

Finite abelian $2$-groups are among the simplest nontrivial algebraic objects, yet their combinatorial geometry is unexpectedly rich. The group $G_n = \mathbb{Z}_2 \times (\mathbb{Z}_2)^n$ — a single involution adjoined to a rank-$n$ elementary abelian group — is a case in point. Every nonidentity element has order two, the group order is $2^{n+1}$, and the group is naturally coordinatized as the set of binary strings of length $n+1$ under bitwise addition modulo $2$.

This coordinatization is not merely notational. It realizes $G_n$ as the vertex set of the $(n+1)$-dimensional hypercube $Q_{n+1}$, and, by ordering vertices by Hamming weight (equivalently, subsets by inclusion), as the Boolean lattice $B_{n+1}$. The lattice $B_{n+1}$ is graded: its elements split into *rank layers* indexed by weight $k = 0, 1, \dots, n+1$, the $k$-th layer being the set of all weight-$k$ vertices.

The central quantity of this paper is the **width** of that lattice — the size of its largest rank layer. We show it equals the central binomial coefficient $\binom{n+1}{\lfloor (n+1)/2 \rfloor}$, we verify the internal consistency of the rank decomposition (the layer sizes are binomial coefficients summing to the group order), and we uncover a clean *min–max duality*: reading the same rank profile under tropical (min-plus) arithmetic replaces the maximal width by the minimal layer size, which is always $1$.

The purpose of the paper is expository and foundational: to assemble, in one place and with complete precision, the structural facts that tie an abstract abelian $2$-group to a concrete extremal invariant of a classical poset, together with the tropical reflection of that invariant.

---

## 2. Definitions and setup

Throughout, $n$ denotes a nonnegative integer and all groups are written additively.

**Definition 2.1 (The group $G_n$).** Let
$$G_n = \mathbb{Z}_2 \times (\mathbb{Z}_2)^n,$$
where $\mathbb{Z}_2 = \mathbb{Z}/2\mathbb{Z}$ and $(\mathbb{Z}_2)^n$ is the group of functions from an $n$-element index set to $\mathbb{Z}_2$ under pointwise addition. An element of $G_n$ is a pair $(a, v)$ with $a \in \mathbb{Z}_2$ and $v \in (\mathbb{Z}_2)^n$, and addition is componentwise.

**Definition 2.2 (The Boolean lattice $B_{m}$).** For a positive integer $m$, the Boolean lattice $B_m$ is the poset of all subsets of an $m$-element set, ordered by inclusion. Identifying a subset with its indicator string in $(\mathbb{Z}_2)^m$, the vertices of $B_m$ are exactly the elements of $(\mathbb{Z}_2)^m$, and the *rank* of a vertex is its Hamming weight (the number of $1$'s, equivalently the cardinality of the subset).

**Definition 2.3 (Rank layer).** For $0 \le k \le m$, the $k$-th **rank layer** of $B_m$ is
$$L_k = \{\, S \subseteq \{1,\dots,m\} : |S| = k \,\},$$
the set of all weight-$k$ vertices (the "$k$-faces" of the discrete cube in the level-set sense).

**Definition 2.4 (Width invariant).** The **width invariant** of $G_n$ is
$$\beta(G_n) = \binom{n+1}{\lfloor (n+1)/2 \rfloor}.$$
As the results below show, this is exactly the width of $B_{n+1}$: the maximum size of a rank layer.

**Definition 2.5 (Tropical / min-plus aggregation).** On $\mathbb{N}$, the min-plus (tropical) semiring replaces addition by $\min$ and multiplication by $+$. The tropical sum of a finite nonempty family $(x_k)$ is
$$\bigoplus_k x_k = \min_k x_k.$$

---

## 3. Structural identification

We first pin down the size of $G_n$ and its identification with the hypercube.

**Theorem 3.1 (Order of $G_n$).** The group $G_n$ has exactly $2^{n+1}$ elements:
$$|G_n| = 2^{n+1}.$$

*Proof sketch.* The cardinality of a product is the product of cardinalities, so $|G_n| = |\mathbb{Z}_2|\cdot|(\mathbb{Z}_2)^n| = 2 \cdot 2^n = 2^{n+1}$, using $|(\mathbb{Z}_2)^n| = 2^n$. $\qquad\blacksquare$

**Theorem 3.2 (Cardinality match with the cube).** The group $G_n$ has the same number of elements as the $(n+1)$-cube:
$$|G_n| = |(\mathbb{Z}_2)^{n+1}| = 2^{n+1}.$$

*Proof sketch.* Both sides equal $2^{n+1}$ by Theorem 3.1 and the direct count $|(\mathbb{Z}_2)^{n+1}| = 2^{n+1}$. $\qquad\blacksquare$

**Theorem 3.3 (Explicit isomorphism to the hypercube).** There is an additive-group isomorphism
$$\Phi : \mathbb{Z}_2 \times (\mathbb{Z}_2)^n \;\xrightarrow{\;\cong\;}\; (\mathbb{Z}_2)^{n+1}.$$

*Proof sketch.* Define $\Phi(a, v)$ to be the length-$(n+1)$ string whose first coordinate is $a$ and whose remaining $n$ coordinates are $v$; concretely $\Phi(a,v) = \mathrm{cons}(a, v)$, prepending $a$ to $v$. The map is additive because prepending commutes with coordinatewise addition. It is injective — two pairs mapping to the same string agree in the first coordinate and in all remaining coordinates, hence are equal — and surjective, since any length-$(n+1)$ string $w$ is the image of $(w_0, (w_1,\dots,w_n))$. An additive bijection is an isomorphism. $\qquad\blacksquare$

Theorem 3.3 justifies treating $G_n$, the hypercube $Q_{n+1}$, and the Boolean lattice $B_{n+1}$ interchangeably. All subsequent combinatorial statements are made on $B_{n+1}$.

---

## 4. The rank profile

We now compute the sizes of the rank layers and verify that they partition the group.

**Theorem 4.1 (Layer size).** For every $0 \le k \le n+1$, the $k$-th rank layer of $B_{n+1}$ has size
$$|L_k| = \binom{n+1}{k}.$$

*Proof sketch.* The weight-$k$ vertices are exactly the $k$-element subsets of an $(n+1)$-element set, and the number of such subsets is $\binom{n+1}{k}$ by definition of the binomial coefficient. $\qquad\blacksquare$

**Theorem 4.2 (Partition identity).** The rank layers partition $B_{n+1}$; consequently
$$\sum_{k=0}^{n+1} \binom{n+1}{k} = 2^{n+1}.$$

*Proof sketch.* Each vertex lies in exactly one layer (the one indexed by its weight), so the layers form a partition of the $2^{n+1}$ vertices. Summing the layer sizes from Theorem 4.1 therefore recovers the total count, which is the classical identity $\sum_{k} \binom{n+1}{k} = 2^{n+1}$. $\qquad\blacksquare$

---

## 5. The width and its extremal characterization

We now show that $\beta(G_n)$ is genuinely the maximum layer size.

**Theorem 5.1 (Upper bound: the middle dominates).** For every $0 \le k \le n+1$,
$$\binom{n+1}{k} \le \beta(G_n) = \binom{n+1}{\lfloor (n+1)/2 \rfloor}.$$

*Proof sketch.* The binomial coefficients $\binom{m}{k}$, as a function of $k$ for fixed $m$, are unimodal: they increase for $k \le \lfloor m/2 \rfloor$ and decrease afterward, with the maximum at the central index $\lfloor m/2 \rfloor$. Applying this with $m = n+1$ gives the bound. $\qquad\blacksquare$

**Theorem 5.2 (Attainment: the bound is reached).** There exists a rank index $k$ with $0 \le k \le n+1$ and
$$\binom{n+1}{k} = \beta(G_n).$$
Explicitly, $k = \lfloor (n+1)/2 \rfloor$ works.

*Proof sketch.* Take $k = \lfloor (n+1)/2 \rfloor$. This satisfies $k \le n+1$, and by the definition of $\beta(G_n)$ we have $\binom{n+1}{k} = \beta(G_n)$ immediately. $\qquad\blacksquare$

**Corollary 5.3 (Width characterization).** $\beta(G_n)$ equals the width of the Boolean lattice $B_{n+1}$, i.e. the maximum size of a rank layer. By Sperner's theorem, it is also the maximum size of an antichain in $B_{n+1}$.

*Proof sketch.* Theorems 5.1 and 5.2 together say $\beta(G_n)$ is an upper bound for every layer size and is attained; hence it is the maximum layer size. Sperner's theorem identifies the maximum antichain size in $B_{n+1}$ with the largest rank layer. $\qquad\blacksquare$

---

## 6. The tropical dual

The results above concern the *maximum* of the rank profile under ordinary aggregation (summation gives $2^{n+1}$; maximization gives $\beta$). We now record the min-plus counterpart.

**Theorem 6.1 (Tropical width dual).** Under min-plus arithmetic, the tropical sum of the rank profile of $B_{n+1}$ is $1$:
$$\bigoplus_{k=0}^{n+1} \binom{n+1}{k} \;=\; \min_{0 \le k \le n+1} \binom{n+1}{k} \;=\; 1.$$

*Proof sketch.* By definition the tropical sum is the minimum. Two inequalities pin it to $1$. First, the layer $k = 0$ gives $\binom{n+1}{0} = 1$, so the minimum is at most $1$. Second, every layer is nonempty: $\binom{n+1}{k} \ge 1$ for all $0 \le k \le n+1$ because each such binomial coefficient is a positive integer. Hence the minimum is at least $1$. Antisymmetry gives equality. $\qquad\blacksquare$

**Remark 6.2 (Min–max duality on one profile).** Theorems 5.1–5.2 and 6.1 exhibit the two extremes of a single list of numbers, the rank profile $\big(\binom{n+1}{k}\big)_{k=0}^{n+1}$. Classical aggregation reads off its maximum, the central binomial coefficient $\beta(G_n)$; tropical (min-plus) aggregation reads off its minimum, the constant $1$ realized at the poles of the lattice (the empty and full sets). The width and its tropical dual are therefore the two endpoints — top and bottom — of the same rank profile.

---

## 7. Algorithms

The results are entirely computational and admit direct algorithms.

**Algorithm A (Rank profile and width).** Given $n$, compute the full rank profile of $B_{n+1}$ and its width.

```
Input: nonnegative integer n
1. m ← n + 1
2. profile ← [ binomial(m, k) for k = 0 .. m ]
3. width  ← max(profile)              # equals binomial(m, floor(m/2))
4. total  ← sum(profile)              # equals 2^m
5. trop   ← min(profile)              # equals 1
6. return (profile, width, total, trop)
```

The binomial coefficients can be produced in $O(m)$ integer multiplications/divisions via the recurrence $\binom{m}{k+1} = \binom{m}{k}\cdot(m-k)/(k+1)$, making the whole profile computable in linear time in $m = n+1$.

**Algorithm B (Verification of the four invariants).** For a range of $n$, check the four identities $|G_n| = 2^{n+1}$, $\sum_k \binom{n+1}{k} = 2^{n+1}$, $\max_k \binom{n+1}{k} = \binom{n+1}{\lfloor (n+1)/2\rfloor}$, and $\min_k \binom{n+1}{k} = 1$. Each check is $O(m)$; the sweep over $n \le N$ is $O(N^2)$.

---

## 8. Applications and connections

- **Extremal set theory.** By Corollary 5.3, $\beta(G_n)$ is the Sperner number of $B_{n+1}$: the largest family of subsets of an $(n+1)$-set with no containment relations. This underlies bounds in the theory of antichains, threshold phenomena, and monotone Boolean functions.
- **Coding theory.** The group $(\mathbb{Z}_2)^{n+1}$ is the ambient space of binary linear codes; rank layers are Hamming spheres about the origin, and their sizes $\binom{n+1}{k}$ are the sphere-size terms in the Hamming and Singleton bounds.
- **Optimization via tropical algebra.** The min-plus semiring is the algebra of shortest paths and optimal schedules. Theorem 6.1 is a toy instance of reading a combinatorial profile through the min-plus lens, where "aggregation" means selecting the cheapest layer.
- **Digital logic.** $\mathbb{Z}_2 \times (\mathbb{Z}_2)^n$ is the parity/XOR structure on $(n+1)$-bit strings; the decomposition of Theorem 3.3 is exactly the "prepend a bit" operation.

---

## 9. Discussion

The invariant $\beta(G_n) = \binom{n+1}{\lfloor (n+1)/2 \rfloor}$ is elementary, but its derivation ties together three viewpoints that are usually presented separately: an abelian $2$-group, the discrete hypercube, and the graded Boolean lattice. The isomorphism of Theorem 3.3 makes these identifications exact rather than heuristic, and the partition identity of Theorem 4.2 gives an internal consistency check — the rank profile is not an arbitrary list of numbers but a genuine decomposition of the group.

The tropical dual of Theorem 6.1 is the conceptual payoff. It shows that "the width" is one half of a symmetric pair: classical arithmetic extracts the maximum of the rank profile, tropical arithmetic the minimum. Both extremes have clean closed forms — the central binomial coefficient and the constant $1$ — and both are attained at distinguished layers (the middle, and the poles). This min–max duality is a compact illustration of how changing the underlying semiring changes which extremal feature of a fixed combinatorial object becomes the "sum."

---

## 10. Future work

Natural extensions include: (i) the analogous width analysis for $\mathbb{Z}_2 \times \mathbb{Z}_{2^n}$ in its cyclic incarnation and other finite abelian groups, comparing rank profiles across group structures of equal order; (ii) weighted and $q$-analog rank profiles, replacing binomial coefficients by Gaussian binomial coefficients for subspace lattices; (iii) systematic study of which extremal features of graded posets are exchanged under passage to the tropical semiring; and (iv) connections between the tropical minimum layer and degeneracy/robustness measures of the associated codes. A related family of conjectures on minimum realization numbers of finite abelian $2$-groups is collected separately in the accompanying future-directions notes.

---

## Appendix: Summary of results

| Statement | Result |
|---|---|
| Order of $G_n$ | $\lvert G_n\rvert = 2^{n+1}$ |
| Identification | $\mathbb{Z}_2 \times (\mathbb{Z}_2)^n \cong (\mathbb{Z}_2)^{n+1}$ |
| Layer size | $\lvert L_k\rvert = \binom{n+1}{k}$ |
| Partition | $\sum_{k=0}^{n+1}\binom{n+1}{k} = 2^{n+1}$ |
| Width (upper bound) | $\binom{n+1}{k} \le \binom{n+1}{\lfloor (n+1)/2\rfloor}$ |
| Width (attained) | $\binom{n+1}{\lfloor (n+1)/2\rfloor} = \beta(G_n)$ |
| Tropical dual | $\min_k \binom{n+1}{k} = 1$ |
