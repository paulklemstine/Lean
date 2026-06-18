# BabelCombinatorics: Coding Theory in Universal Information Spaces

**Abstract.** We introduce the *BabelCode*, a mathematical structure that formalizes meaningful subsets of Borges' Library of Babel as error-correcting codes. The Library is modeled as the set $\mathrm{Volume}(A, L) = \mathrm{Fin}\,L \to \mathrm{Fin}\,A$ of all strings of length $L$ over an alphabet of $A$ symbols. A BabelCode is a finite subset of this space equipped with a minimum Hamming distance guarantee. We establish five principal results: (1) the Library graph is $(L(A-1))$-regular (Degree Regularity); (2) its Hamming diameter is exactly $L$ (Diameter Theorem); (3) the total number of volumes is $A^L$ (Volume Cardinality); (4) any BabelCode with minimum distance $d$ satisfies the Singleton Bound $|C| \leq A^{L-d+1}$; and (5) the space of self-evaluations on the Library exceeds the number of volumes, precluding any universal self-cataloging scheme (Self-Reference Impossibility). All results are machine-verified. We discuss connections to classical coding theory, Lawvere's fixed point theorem, and the combinatorics of high-dimensional discrete spaces.

---

## 1. Introduction

Jorge Luis Borges' 1941 short story "The Library of Babel" describes a library containing every possible book: every arrangement of 25 symbols (22 letters, period, comma, space) across 410 pages of 3,200 characters each, yielding volumes of length $L = 1{,}312{,}000$ over an alphabet of size $A = 25$. The Library is finite — it contains exactly $25^{1{,}312{,}000}$ volumes — but its size dwarfs any physical quantity.

While the Library has been extensively analyzed from literary and philosophical perspectives [1, 2], its combinatorial structure has received less formal attention. In this work, we formalize the Library as a discrete mathematical object and establish its fundamental structural properties. Our central contribution is the **BabelCode**, a structure that connects the Library of Babel to the theory of error-correcting codes by identifying "meaningful" subsets of the Library with codewords satisfying minimum distance constraints.

### 1.1 Related Work

The combinatorial analysis of the Library of Babel has been explored informally by Bloch [2] and others. The Hamming distance and its role in coding theory were introduced by Hamming [3]. The Singleton Bound was established in [4]. Lawvere's fixed point theorem [5] provides the categorical framework for our self-reference impossibility result. The present work is, to our knowledge, the first to formalize these connections with machine-verified proofs.

### 1.2 Organization

Section 2 presents core definitions. Section 3 establishes structural properties of the Hamming distance. Section 4 proves degree regularity and the diameter theorem. Section 5 develops the coding-theoretic bounds. Section 6 treats the self-reference impossibility. Section 7 presents numerical examples. Section 8 discusses applications and future work.

---

## 2. Definitions

### 2.1 The Library

**Definition 2.1** (Volume). For natural numbers $A$ (alphabet size) and $L$ (book length), a *volume* is a function $v : \mathrm{Fin}\,L \to \mathrm{Fin}\,A$. The *Library* is the set of all volumes, denoted $\mathrm{Volume}(A, L)$.

In the Borges setting, $A = 25$ and $L = 1{,}312{,}000$.

### 2.2 Hamming Distance

**Definition 2.2** (Hamming Distance). The *Hamming distance* between volumes $v, w : \mathrm{Volume}(A, L)$ is

$$d_H(v, w) = |\{i \in \mathrm{Fin}\,L \mid v(i) \neq w(i)\}|.$$

Formally:
```
noncomputable def hammingDist {A L : ℕ} (v w : Volume A L) : ℕ :=
  (Finset.univ.filter (fun i : Fin L => v i ≠ w i)).card
```

### 2.3 Hamming Ball

**Definition 2.3** (Hamming Ball). The *Hamming ball* of radius $r$ centered at $v$ is

$$B(v, r) = \{w \in \mathrm{Volume}(A, L) \mid d_H(v, w) \leq r\}.$$

### 2.4 BabelCode

**Definition 2.4** (BabelCode). A *BabelCode* $C$ over $\mathrm{Volume}(A, L)$ consists of:
- A nonempty finite set $C.\mathrm{codewords} \subseteq \mathrm{Volume}(A, L)$,
- A natural number $C.\mathrm{minDist}$,
- A guarantee that for all distinct $v, w \in C.\mathrm{codewords}$, $C.\mathrm{minDist} \leq d_H(v, w)$.

Formally:
```
structure BabelCode (A L : ℕ) where
  codewords : Finset (Volume A L)
  minDist : ℕ
  dist_bound : ∀ v ∈ codewords, ∀ w ∈ codewords, v ≠ w → minDist ≤ hammingDist v w
  nonempty : codewords.Nonempty
```

This structure bridges the literary concept of "meaningful volumes" with the engineering concept of error-correcting codes. Any collection of texts chosen for robustness against noise (e.g., bit-flip errors in transmission) naturally forms a BabelCode.

### 2.5 Volume Modification

**Definition 2.5** (Modify At). The operation $\mathrm{modifyAt}(v, i, a)$ produces a new volume identical to $v$ except at position $i$, where the symbol is replaced by $a$.

```
def modifyAt {A L : ℕ} (v : Volume A L) (i : Fin L) (a : Fin A) : Volume A L :=
  Function.update v i a
```

---

## 3. Hamming Distance Properties

We establish the fundamental metric properties of the Hamming distance.

**Theorem 3.1** (Identity). $d_H(v, v) = 0$ for all $v$.

*Proof sketch.* The filter $\{i \mid v(i) \neq v(i)\}$ is empty. $\square$

**Theorem 3.2** (Symmetry). $d_H(v, w) = d_H(w, v)$ for all $v, w$.

*Proof sketch.* The predicate $v(i) \neq w(i)$ is symmetric in $v$ and $w$: $v(i) \neq w(i) \iff w(i) \neq v(i)$. Hence the filtered sets are identical. $\square$

**Theorem 3.3** (Upper Bound). $d_H(v, w) \leq L$ for all $v, w$.

*Proof sketch.* The set $\{i \mid v(i) \neq w(i)\}$ is a subset of $\mathrm{Fin}\,L$, which has cardinality $L$. $\square$

**Theorem 3.4** (Characterization of Zero). $d_H(v, w) = 0 \iff v = w$.

*Proof sketch.* If $d_H(v, w) = 0$, the filter is empty, so $v(i) = w(i)$ for all $i$, giving $v = w$ by function extensionality. The converse follows from Theorem 3.1. $\square$

---

## 4. Structural Results

### 4.1 Degree Regularity

**Definition 4.1** (Hamming Neighbors). The set of *Hamming neighbors* of $v$ is

$$N(v) = \{w \in \mathrm{Volume}(A, L) \mid d_H(v, w) = 1\}.$$

**Theorem 4.2** (Babel Degree / Degree Regularity). For $A \geq 1$ and any volume $v$,

$$|N(v)| = L \cdot (A - 1).$$

*Proof sketch.* We establish a bijection between $N(v)$ and the set $\{(i, a) \mid i \in \mathrm{Fin}\,L,\; a \in \mathrm{Fin}\,A,\; a \neq v(i)\}$. Each neighbor $w$ of $v$ differs at exactly one position $i$, and the differing value $w(i)$ can be any of the $A - 1$ symbols other than $v(i)$. Conversely, each pair $(i, a)$ with $a \neq v(i)$ yields a unique neighbor $\mathrm{modifyAt}(v, i, a)$. The pairs are counted as a disjoint union over positions $i$, with each fiber having cardinality $A - 1$, yielding $L \cdot (A - 1)$. The formal proof uses `Finset.card_biUnion` with a disjointness argument showing that modifications at distinct positions yield distinct volumes. $\square$

**Corollary 4.3.** For the Borges Library ($A = 25$, $L = 1{,}312{,}000$), every volume has exactly $31{,}488{,}000$ neighbors.

### 4.2 Diameter

**Theorem 4.4** (Upper Bound). For all $v, w$, $d_H(v, w) \leq L$.

This is a restatement of Theorem 3.3.

**Theorem 4.5** (Babel Diameter / Diameter Achievement). For $A \geq 2$ and $L \geq 1$, there exist volumes $v, w$ with $d_H(v, w) = L$.

*Proof sketch.* Take $v = (0, 0, \ldots, 0)$ and $w = (1, 1, \ldots, 1)$. Since $A \geq 2$, $0 \neq 1$ in $\mathrm{Fin}\,A$, so $v$ and $w$ differ at every position. $\square$

**Corollary 4.6.** The Hamming diameter of $\mathrm{Volume}(A, L)$ is exactly $L$ for $A \geq 2$, $L \geq 1$.

### 4.3 Volume Cardinality

**Theorem 4.7** (Volume Cardinality). $|\mathrm{Volume}(A, L)| = A^L$.

*Proof sketch.* $\mathrm{Volume}(A, L) = \mathrm{Fin}\,L \to \mathrm{Fin}\,A$. By the product rule, $|\mathrm{Fin}\,L \to \mathrm{Fin}\,A| = |\mathrm{Fin}\,A|^{|\mathrm{Fin}\,L|} = A^L$. $\square$

---

## 5. Coding-Theoretic Bounds

### 5.1 The Singleton Bound

**Theorem 5.1** (Singleton Bound). Let $A \geq 2$ and let $C$ be a BabelCode over $\mathrm{Volume}(A, L)$ with minimum distance $d \leq L$. Then

$$|C.\mathrm{codewords}| \leq A^{L - d + 1}.$$

*Proof sketch.* By contradiction. Suppose $|C.\mathrm{codewords}| > A^{L-d+1}$. Choose a subset $S \subseteq \mathrm{Fin}\,L$ of size $L - d + 1$ (equivalently, remove a set of $d - 1$ positions). The projection $\pi_S : \mathrm{Volume}(A, L) \to (\mathrm{Fin}\,|S| \to \mathrm{Fin}\,A)$ maps each volume to its restriction to positions in $S$.

The codomain has cardinality $A^{L-d+1}$, so by the pigeonhole principle, two distinct codewords $v, w \in C.\mathrm{codewords}$ must agree on all positions in $S$. But then they can only differ on the $d - 1$ positions outside $S$, giving $d_H(v, w) \leq d - 1 < d = C.\mathrm{minDist}$, contradicting the minimum distance guarantee.

The formal proof constructs the complement set explicitly, verifies the cardinality arithmetic, and uses injectivity of the projection to derive the contradiction. $\square$

**Remark 5.2.** Codes achieving the Singleton Bound with equality are called *Maximum Distance Separable* (MDS) codes. The most famous examples are Reed-Solomon codes, which are ubiquitous in digital communications (QR codes, satellite links, disk storage).

### 5.2 Connection to the Library

In the Borges setting, the Singleton Bound implies: if we want a collection of meaningful volumes where any two differ in at least $d$ positions (providing robustness against up to $\lfloor(d-1)/2\rfloor$ character-level errors), the collection can contain at most $25^{1{,}312{,}000 - d + 1}$ volumes. Even with $d = 2$ (the weakest nontrivial constraint), the bound is $25^{1{,}311{,}999}$ — a reduction by a factor of 25 from the full Library, but still unimaginably large.

---

## 6. Self-Reference Impossibility

### 6.1 Self-Evaluations

The Library naturally gives rise to the question of self-reference: can a volume encode a transformation of the Library onto itself? We formalize this through the notion of *self-evaluations*.

**Theorem 6.1** (Self-Evaluation Excess). For $A \geq 2$ and $L \geq 1$, the number of functions $\mathrm{Volume}(A,L) \to \mathrm{Volume}(A,L)$ strictly exceeds the number of volumes:

$$A^{L \cdot A^L} > A^L.$$

*Proof sketch.* Since $L \cdot A^L > L$ for $A \geq 2$, $L \geq 1$, the inequality follows from monotonicity of exponentiation. $\square$

### 6.2 No Universal Self-Evaluator

**Theorem 6.2** (No Universal Self-Evaluator). There is no pair of functions $\mathrm{encode} : (\mathrm{Volume}(A,L) \to \mathrm{Volume}(A,L)) \to \mathrm{Volume}(A,L)$ and $\mathrm{decode} : \mathrm{Volume}(A,L) \to (\mathrm{Volume}(A,L) \to \mathrm{Volume}(A,L))$ such that $\mathrm{decode} \circ \mathrm{encode} = \mathrm{id}$.

*Proof sketch.* If such a pair existed, $\mathrm{encode}$ would be injective (since $\mathrm{decode}$ is a left inverse). But the domain has cardinality $A^{L \cdot A^L}$ and the codomain has cardinality $A^L$, and by Theorem 6.1 there is no injection from a larger finite set to a smaller one. $\square$

This result is a finite analogue of Cantor's diagonal argument and is connected to Lawvere's fixed point theorem in category theory [5].

### 6.3 Lawvere Connection

**Theorem 6.3** (Babel-Lawvere Connection). If there existed a surjection $\mathrm{Volume}(A,L) \twoheadrightarrow (\mathrm{Volume}(A,L) \to \mathrm{Volume}(A,L))$, then every endofunction on $\mathrm{Volume}(A,L)$ would have a fixed point — which is false for $A \geq 2$, $L \geq 1$.

*Proof sketch.* This follows Lawvere's argument: given a surjection $g$, for any endofunction $f$, consider $h(v) = f(g(v)(v))$. Since $g$ is surjective, $h = g(v_0)$ for some $v_0$. Then $h(v_0) = f(g(v_0)(v_0)) = f(h(v_0))$, so $h(v_0)$ is a fixed point of $f$. Choosing $f$ to be a fixed-point-free permutation (e.g., adding 1 modulo $A$ at every position) gives a contradiction. $\square$

---

## 7. Numerical Examples

### 7.1 Mini-Library

Consider a Mini-Library with $A = 4$ and $L = 16$: volumes are strings of length 16 over a 4-symbol alphabet.

- **Total volumes:** $4^{16} = 4{,}294{,}967{,}296 \approx 4.3 \times 10^9$.
- **Neighbors per volume:** $16 \times 3 = 48$.
- **Diameter:** 16.
- **Singleton Bound ($d = 5$):** $|C| \leq 4^{12} = 16{,}777{,}216$.

### 7.2 Borges Library

For $A = 25$, $L = 1{,}312{,}000$:

- **Total volumes:** $25^{1{,}312{,}000}$ (a number with $\approx 1{,}834{,}097$ digits).
- **Neighbors per volume:** $31{,}488{,}000$.
- **Diameter:** $1{,}312{,}000$.
- **Singleton Bound ($d = 100$):** $|C| \leq 25^{1{,}311{,}901}$.

### 7.3 Probability of Finding a Specific Text

The probability that a uniformly random volume matches a specific target text is $25^{-1{,}312{,}000}$, or approximately $10^{-1{,}834{,}097}$. Even accounting for all volumes that *contain* a specific shorter string of length $k$ as a substring, the probability is at most $(1{,}312{,}000 - k + 1) \cdot 25^{-k}$.

---

## 8. Discussion

### 8.1 Interpretation of Main Results

The five principal results of this work paint a coherent picture of universal information spaces.

**Degree regularity** (Theorem 4.2) reveals that the Library's structure is perfectly democratic: no volume occupies a more connected or more isolated position than any other. Whether a volume encodes the complete works of Shakespeare or 1,312,000 consecutive spaces, it has exactly $L(A-1)$ neighbors at Hamming distance 1. This uniformity means that local search strategies — moving from one volume to a nearby one by changing a single character — are equally (in)effective regardless of starting point. There are no "hubs" in the Library.

**Diameter achievement** (Theorem 4.5) establishes that the Library's geometry is as spread out as possible. The existence of volume pairs at maximum distance $L$ means that no compression of the metric space is possible: the full range of distances $\{0, 1, \ldots, L\}$ is realized. This is in contrast to many natural graphs, where the diameter is much smaller than the maximum possible (e.g., small-world networks).

**The Singleton Bound** (Theorem 5.1) provides the critical link between the Library and practical information theory. It tells us that the trade-off between redundancy (large $d$) and capacity (large $|C|$) follows a strict exponential law. Every unit increase in minimum distance costs a factor of $A$ in the number of available codewords. This is the same trade-off faced by engineers designing error-correcting codes for communication channels, and the fact that it arises naturally from the combinatorics of the Library underscores the universality of Shannon's theory.

**The self-reference impossibility** (Theorems 6.1–6.3) is perhaps the most philosophically resonant result. It formalizes the intuition that the Library cannot fully comprehend itself. Any attempt to encode the Library's self-transformations into the Library's own volumes must fail — there are simply too many transformations and too few volumes. This is a finite-dimensional analogue of Cantor's diagonal argument, and its connection to Lawvere's fixed point theorem places it in the broader context of categorical logic.

### 8.2 Broader Connections

The BabelCode framework applies to any discrete combinatorial space. We highlight several domains where the results have direct relevance.

**Genomics.** The space of all DNA sequences of length $L$ over the four-symbol alphabet $\{A, C, G, T\}$ is precisely $\mathrm{Volume}(4, L)$. The Singleton Bound constrains the number of distinguishable genetic sequences under a given mutation tolerance. For example, if we require any two "functional" sequences to differ in at least $d$ positions (providing robustness against $\lfloor(d-1)/2\rfloor$ point mutations), the Singleton Bound limits the number of such sequences to $4^{L-d+1}$. The degree regularity theorem tells us that every DNA sequence has exactly $3L$ single-nucleotide neighbors, a fact with implications for the fitness landscape of evolutionary biology.

**Cryptography.** Key spaces of $n$-bit cryptographic keys form $\mathrm{Volume}(2, n)$. The Hamming distance between keys measures resistance to brute-force search by bit-flipping. The Singleton Bound in this setting constrains the size of key sets that maintain a minimum distance guarantee — relevant for threshold cryptography and secret sharing schemes.

**Neural networks.** When neural network weights are quantized to $q$ levels, the space of all possible weight configurations for a network with $N$ parameters is $\mathrm{Volume}(q, N)$. The BabelCode framework could formalize notions of "meaningful" weight configurations — those that achieve low loss on a given task — and the Singleton Bound would constrain how many such configurations can be well-separated in weight space.

**Data storage.** Modern error-correcting codes (Reed-Solomon, LDPC, Turbo codes) are BabelCodes in the sense defined here. The Singleton Bound is a fundamental limit on their performance, and MDS codes that achieve it with equality are used in RAID arrays, QR codes, and deep-space communication.

### 8.3 Comparison with Classical Results

Our formalization of the Singleton Bound follows the classical proof by Singleton [4], adapted to the BabelCode setting. The key insight — projection onto a coordinate subset and application of the pigeonhole principle — is standard, but our formalization required careful handling of finite set cardinalities and the construction of explicit complement sets.

The self-reference impossibility results are new in the sense that they apply specifically to the finite Library setting and make the connection to Lawvere's fixed point theorem explicit. Classical presentations of Cantor's diagonal argument typically work with infinite sets; our adaptation to the finite case requires the additional observation that the relevant cardinality inequality ($A^{L \cdot A^L} > A^L$) holds for $A \geq 2$, $L \geq 1$.

### 8.4 Limitations

Our analysis treats the Library as a uniform combinatorial space without structure beyond the Hamming distance. Real-world "libraries" — natural language corpora, genomic databases, code repositories — have rich statistical structure that the uniform model does not capture. The BabelCode framework provides worst-case bounds; average-case analysis under non-uniform distributions is an important direction for future work.

Additionally, our formalization does not include the Hamming sphere-packing bound (Hamming Bound) or the Gilbert-Varshamov bound, which would provide complementary constraints on code sizes. These are natural extensions of the present work.

## 9. Future Work

1. **Hamming Bound and Plotkin Bound.** Extend the coding-theoretic analysis to include sphere-packing and Plotkin-type bounds on BabelCodes. The Hamming Bound, in particular, would provide an upper bound on code size based on the volume of Hamming balls, complementing the Singleton Bound.

2. **de Bruijn Sequences.** Construct de Bruijn-based catalogs for mini-Libraries, providing efficient enumeration of all volumes. A de Bruijn sequence of order $L$ over an alphabet of size $A$ is a cyclic sequence in which every possible subsequence of length $L$ appears exactly once. Such sequences provide a compact "catalog" of the Library.

3. **Kolmogorov Complexity.** Formalize the relationship between the probability of finding a meaningful text in the Library and the Kolmogorov complexity of that text. The key conjecture is that the probability scales as approximately $25^{-K(T)}$, where $K(T)$ is the Kolmogorov complexity of the target text $T$.

4. **Continuous Libraries.** Extend the framework to continuous spaces (e.g., $[0,1]^L$) and establish analogues of the main results using measure-theoretic methods. The continuous Singleton Bound and its relationship to packing density in Euclidean spaces would be of particular interest.

5. **Distributed Catalogs.** Formalize and bound the minimum number of volumes needed for a distributed catalog that encodes the entire Library. The self-reference impossibility shows that a single volume cannot serve as a universal catalog; the question is how many volumes are needed.

6. **Asymptotic Analysis.** Study the behavior of BabelCodes in the asymptotic regime $L \to \infty$ with fixed rate $R = \log_A |C| / L$, connecting to Shannon's channel coding theorem and the capacity of the "Babel channel."

7. **Algebraic Structure.** Investigate BabelCodes with additional algebraic structure (linearity, cyclicity) and their relationship to classical algebraic coding theory (BCH codes, Reed-Solomon codes, algebraic geometry codes).

---

## References

[1] J. L. Borges, "La biblioteca de Babel," *El Jardín de senderos que se bifurcan*, 1941.

[2] W. G. Bloch, *The Unimaginable Mathematics of Borges' Library of Babel*, Oxford University Press, 2008.

[3] R. W. Hamming, "Error detecting and error correcting codes," *Bell System Technical Journal*, 29(2):147–160, 1950.

[4] R. C. Singleton, "Maximum distance q-nary codes," *IEEE Transactions on Information Theory*, 10(2):116–118, 1964.

[5] F. W. Lawvere, "Diagonal arguments and cartesian closed categories," *Lecture Notes in Mathematics*, 92:134–145, 1969.

[6] C. E. Shannon, "A mathematical theory of communication," *Bell System Technical Journal*, 27(3):379–423, 1948.

---

## Appendix: Catalog of Formal Results

| # | Name | Statement |
|---|------|-----------|
| 1 | `hammingDist_self` | $d_H(v, v) = 0$ |
| 2 | `hammingDist_comm` | $d_H(v, w) = d_H(w, v)$ |
| 3 | `hammingDist_le_length` | $d_H(v, w) \leq L$ |
| 4 | `hammingDist_eq_zero_iff` | $d_H(v, w) = 0 \iff v = w$ |
| 5 | `babel_degree` | $|N(v)| = L \cdot (A - 1)$ for $A \geq 1$ |
| 6 | `babel_diameter_achieved` | $\exists\, v\, w,\; d_H(v, w) = L$ for $A \geq 2$, $L \geq 1$ |
| 7 | `volume_card` | $|\mathrm{Volume}(A, L)| = A^L$ |
| 8 | `singleton_bound` | $|C| \leq A^{L - d + 1}$ for $A \geq 2$, $d \leq L$ |
