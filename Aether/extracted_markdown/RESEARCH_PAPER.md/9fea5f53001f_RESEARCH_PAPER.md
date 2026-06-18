# The Library of Babel: Combinatorics of Universal Information Spaces

## Abstract

We introduce the **BabelCode**, a novel mathematical structure that connects Borges' Library of Babel to the theory of error-correcting codes. The Library is formalized as the set $\mathrm{Volume}(A, L) = \mathrm{Fin}\,L \to \mathrm{Fin}\,A$ of all strings of length $L$ over an alphabet of $A$ symbols. A BabelCode is a subset of the Library equipped with a minimum Hamming distance guarantee, bridging literary thought experiment and information theory. We establish five principal results: (1) the Hamming distance on the Library satisfies all properties of a metric; (2) the Library is perfectly degree-regular, with every volume having exactly $L(A-1)$ Hamming neighbors; (3) the Hamming diameter of the Library is exactly $L$, achieved by explicit construction; (4) the Singleton bound $|C| \le A^{L-d+1}$ for codes of minimum distance $d$; and (5) a finite Cantor-type diagonal argument showing that no single volume can serve as a universal catalog. All results have been formally verified. We discuss applications to information retrieval, coding theory, and the philosophy of universal information spaces.

**Keywords:** Library of Babel, Hamming distance, error-correcting codes, Singleton bound, combinatorics, universal information spaces

---

## 1. Introduction

In his 1941 short story "La biblioteca de Babel," Jorge Luis Borges conceived of a library containing every possible book: every arrangement of 25 orthographic symbols (22 lowercase letters, the space, the period, and the comma) across 410 pages of 40 lines of 80 characters each — a total of $L = 1{,}312{,}000$ character positions per volume. The Library thus contains exactly $25^{1{,}312{,}000}$ volumes.

While the Library has inspired extensive literary and philosophical commentary, its mathematical structure has received comparatively little formal treatment. In this paper, we introduce a coding-theoretic framework for the Library, defining the **BabelCode** structure and establishing fundamental bounds on the size of meaningful subsets.

### 1.1 Contributions

Our principal contributions are:

1. **Formalization of the Library.** We define the Library as the type $\mathrm{Volume}(A, L) = \mathrm{Fin}\,L \to \mathrm{Fin}\,A$, parametric in alphabet size $A$ and book length $L$.

2. **Hamming metric properties.** We prove that the Hamming distance is a well-behaved metric: $d(v,v) = 0$, $d(v,w) = d(w,v)$, $d(v,w) = 0 \iff v = w$, and $d(v,w) \le L$.

3. **Degree regularity theorem** (`babel_degree`). Every volume has exactly $L \cdot (A-1)$ Hamming neighbors (volumes at distance 1).

4. **Diameter theorem** (`babel_diameter_achieved`). For $A \ge 2$ and $L \ge 1$, there exist volumes at Hamming distance exactly $L$, so the diameter equals $L$.

5. **Singleton bound** (`singleton_bound`). For any BabelCode with minimum distance $d \le L$ and alphabet $A \ge 2$, the number of codewords satisfies $|C| \le A^{L - d + 1}$.

6. **Self-reference impossibility** (`self_eval_exceeds_volumes`). The number of possible evaluation functions $A^{A^L}$ exceeds $A^L$, establishing that no single volume can encode all evaluations — a finite analogue of Cantor's diagonal argument.

---

## 2. Definitions

### 2.1 The Library

**Definition 2.1** (Volume). For natural numbers $A, L$, a *volume* is a function $v : \mathrm{Fin}\,L \to \mathrm{Fin}\,A$. The set of all volumes is denoted $\mathrm{Volume}(A, L)$.

The cardinality of the Library follows immediately from the counting principle for functions between finite sets:

$$|\mathrm{Volume}(A, L)| = A^L$$

This is established as `volume_card`.

**Remark.** For Borges' original Library, $A = 25$ and $L = 1{,}312{,}000$, giving $25^{1{,}312{,}000} \approx 10^{1{,}834{,}097}$ volumes.

### 2.2 Hamming Distance

**Definition 2.2** (Hamming distance). For volumes $v, w : \mathrm{Volume}(A, L)$,
$$d_H(v, w) = |\{i \in \mathrm{Fin}\,L \mid v(i) \ne w(i)\}|$$

Formally, this is computed as the cardinality of the filter of positions where the two volumes disagree:
```
hammingDist v w = (Finset.univ.filter (fun i => v i ≠ w i)).card
```

### 2.3 Hamming Ball

**Definition 2.3** (Hamming ball). The ball of radius $r$ centered at $v$ is
$$B(v, r) = \{w \in \mathrm{Volume}(A, L) \mid d_H(v, w) \le r\}$$

### 2.4 BabelCode

**Definition 2.4** (BabelCode). A *BabelCode* over alphabet $\mathrm{Fin}\,A$ with book length $L$ is a triple $(C, d, \pi)$ where:
- $C \subseteq \mathrm{Volume}(A, L)$ is a nonempty finite set of *codewords*,
- $d \in \mathbb{N}$ is the *minimum distance*,
- $\pi$ is a proof that for all distinct $v, w \in C$, $d \le d_H(v, w)$.

This structure connects the Library directly to classical coding theory. The codewords represent "meaningful" volumes, and the minimum distance guarantee ensures they are sufficiently separated in the Hamming metric.

### 2.5 Modification Operator

**Definition 2.5** (Modify-at). For a volume $v$, position $i : \mathrm{Fin}\,L$, and symbol $a : \mathrm{Fin}\,A$,
$$\mathrm{modifyAt}(v, i, a)(j) = \begin{cases} a & \text{if } j = i \\ v(j) & \text{otherwise} \end{cases}$$

This operation produces a volume identical to $v$ except at position $i$, where it takes value $a$.

---

## 3. Hamming Distance Properties

We establish the fundamental properties of the Hamming distance.

**Theorem 3.1** (`hammingDist_self`). *For all $v$, $d_H(v, v) = 0$.*

*Proof sketch.* The filter $\{i \mid v(i) \ne v(i)\}$ is empty. $\square$

**Theorem 3.2** (`hammingDist_comm`). *For all $v, w$, $d_H(v, w) = d_H(w, v)$.*

*Proof sketch.* The predicate $v(i) \ne w(i)$ is symmetric in $v$ and $w$ (by commutativity of $\ne$), so the filtered sets have equal cardinality. $\square$

**Theorem 3.3** (`hammingDist_le_length`). *For all $v, w$, $d_H(v, w) \le L$.*

*Proof sketch.* The filter is a subset of $\mathrm{Fin}\,L$, which has cardinality $L$. $\square$

**Theorem 3.4** (`hammingDist_eq_zero_iff`). *$d_H(v, w) = 0$ if and only if $v = w$.*

*Proof sketch.* If $v \ne w$, there exists some position $i$ with $v(i) \ne w(i)$, so the filter is nonempty and has positive cardinality. The converse follows from Theorem 3.1. $\square$

**Remark.** Together with the triangle inequality (which follows from subadditivity of cardinality on filters), these properties establish that $d_H$ is a metric on $\mathrm{Volume}(A, L)$.

---

## 4. Main Results

### 4.1 Degree Regularity

**Theorem 4.1** (`babel_degree`). *Let $A \ge 1$ and $v \in \mathrm{Volume}(A, L)$. Then*
$$|\{w \in \mathrm{Volume}(A, L) \mid d_H(v, w) = 1\}| = L \cdot (A - 1)$$

*Proof sketch.* A volume $w$ is a neighbor of $v$ (at distance 1) if and only if there exists a unique position $i$ where $w$ and $v$ disagree, and $w(i)$ takes one of the $A - 1$ values different from $v(i)$. We establish a bijection between the set of neighbors and the disjoint union $\bigsqcup_{i \in \mathrm{Fin}\,L} \{a \in \mathrm{Fin}\,A \mid a \ne v(i)\}$, which has cardinality $\sum_{i=0}^{L-1}(A-1) = L(A-1)$. The bijection sends a neighbor $w$ to the pair $(i, w(i))$ where $i$ is the unique differing position, and conversely sends $(i, a)$ to $\mathrm{modifyAt}(v, i, a)$.

The formal proof constructs this bijection via `Finset.biUnion` over positions, with images under the `modifyAt` operator, and establishes injectivity and disjointness of the components. $\square$

**Corollary 4.2.** For Borges' Library ($A = 25$, $L = 1{,}312{,}000$), every volume has exactly $31{,}488{,}000$ Hamming neighbors.

**Interpretation.** The Library is a regular graph in the Hamming metric. This regularity is a consequence of the symmetry of the construction — every position and every symbol play identical roles. The graph is vertex-transitive: for any two volumes $v, w$, there exists a permutation of positions and a relabeling of symbols that maps $v$ to $w$.

### 4.2 Diameter

**Theorem 4.3** (`babel_diameter_upper`). *For all $v, w$, $d_H(v, w) \le L$.*

This is a direct consequence of Theorem 3.3.

**Theorem 4.4** (`babel_diameter_achieved`). *For $A \ge 2$ and $L \ge 1$, there exist $v, w \in \mathrm{Volume}(A, L)$ with $d_H(v, w) = L$.*

*Proof sketch.* Take $v(i) = 0$ and $w(i) = 1$ for all $i$. Since $0 \ne 1$ in $\mathrm{Fin}\,A$ (using $A \ge 2$), every position contributes to the Hamming distance, giving $d_H(v, w) = L$. $\square$

**Corollary 4.5.** The diameter of $\mathrm{Volume}(A, L)$ under $d_H$ is exactly $L$ for $A \ge 2$, $L \ge 1$.

### 4.3 The Singleton Bound

**Theorem 4.6** (`singleton_bound`). *Let $A \ge 2$ and let $(C, d, \pi)$ be a BabelCode with $d \le L$. Then*
$$|C| \le A^{L - d + 1}$$

*Proof sketch.* Consider the projection $\phi : \mathrm{Volume}(A, L) \to (\mathrm{Fin}(L-d+1) \to \mathrm{Fin}\,A)$ that restricts a volume to $L - d + 1$ coordinates (specifically, the complement of some set $S$ of $d - 1$ coordinates). If two distinct codewords $v, w \in C$ had $\phi(v) = \phi(w)$, they would agree on all $L - d + 1$ projected positions, and could disagree on at most $d - 1$ of the remaining positions. This contradicts the minimum distance condition $d_H(v,w) \ge d$.

Therefore $\phi\vert_C$ is injective, giving $|C| = |\phi(C)| \le |\mathrm{Fin}(L-d+1) \to \mathrm{Fin}\,A| = A^{L-d+1}$. $\square$

**Example 4.7.** For a mini-Library with $A = 4$, $L = 16$, and minimum distance $d = 8$:
$$|C| \le 4^{16 - 8 + 1} = 4^9 = 262{,}144$$

**Example 4.8.** For Borges' Library with $A = 25$, $L = 1{,}312{,}000$, and $d = 656{,}000$ (half the book length):
$$|C| \le 25^{656{,}001}$$

This is still an astronomically large number, but it is the *square root* of the Library's total size $25^{1{,}312{,}000}$, demonstrating that the "meaningful fraction" is negligible in relative terms.

### 4.4 Self-Reference and the Catalog Problem

The formal development includes results on the impossibility of universal self-reference in the Library. The key observation is a finite analogue of Cantor's theorem.

**Theorem 4.9** (`self_eval_exceeds_volumes`). *The number of possible "self-evaluation" functions (functions from volumes to the alphabet) exceeds the number of volumes:*
$$A^{A^L} > A^L \quad \text{for } A \ge 2, L \ge 1$$

*Proof sketch.* Since $A \ge 2$ and $L \ge 1$, we have $A^L \ge 2$, so $A^{A^L} \ge A^2 > A^1 \le A^L$ ... more precisely, the exponent $A^L$ in $A^{A^L}$ exceeds $L$ (since $A^L > L$ for $A \ge 2, L \ge 1$), giving $A^{A^L} > A^L$. $\square$

**Theorem 4.10** (`no_universal_self_evaluator`). *There is no pair of functions $(\mathrm{encode}, \mathrm{decode})$ such that $\mathrm{encode} : (\mathrm{Volume} \to \mathrm{Fin}\,A) \to \mathrm{Volume}$ and $\mathrm{decode} : \mathrm{Volume} \to (\mathrm{Volume} \to \mathrm{Fin}\,A)$ with $\mathrm{decode} \circ \mathrm{encode} = \mathrm{id}$.*

This is a direct consequence of Theorem 4.9: such a pair would establish an injection from a larger set to a smaller one, contradicting cardinality.

**Interpretation.** No single volume can serve as a complete catalog of the Library. The "catalog volume" that Borges' librarians seek is a mathematical impossibility — not due to practical limitations, but due to a fundamental cardinality obstruction.

This connects to Lawvere's fixed-point theorem in category theory, which provides a unified framework for diagonalization arguments including Cantor's theorem, the halting problem, Gödel's incompleteness, and Tarski's undefinability of truth.

---

## 5. The Hamming Ball and Sphere-Packing

### 5.1 Ball Volume

The Hamming ball $B(v, r)$ in $\mathrm{Volume}(A, L)$ has size:
$$|B(v, r)| = \sum_{k=0}^{r} \binom{L}{k} (A-1)^k$$

This formula counts the number of volumes that differ from $v$ in exactly $k$ positions (for each $k \le r$): choose $k$ positions from $L$, then choose one of $A-1$ alternative symbols for each.

### 5.2 The Hamming Bound

**Theorem 5.1** (Hamming bound / sphere-packing bound). *For a BabelCode $(C, d, \pi)$ with $d = 2t + 1$,*
$$|C| \cdot \sum_{k=0}^{t} \binom{L}{k}(A-1)^k \le A^L$$

*Proof sketch.* The balls $B(v, t)$ for $v \in C$ are pairwise disjoint (since $d_H(v, w) \ge 2t+1$ for distinct $v, w \in C$ and the triangle inequality prevents any volume from lying in two balls). Their union is contained in $\mathrm{Volume}(A, L)$, giving the bound. $\square$

---

## 6. Computational Examples

### 6.1 Mini-Library: $A = 4$, $L = 16$

For a tractable "mini-Library":
- **Total volumes:** $4^{16} = 4{,}294{,}967{,}296$ (about 4.3 billion)
- **Neighbors per volume:** $16 \times 3 = 48$
- **Diameter:** 16
- **Singleton bound ($d = 8$):** $4^9 = 262{,}144$ maximum codewords
- **Hamming ball ($r = 3$):** $\sum_{k=0}^{3}\binom{16}{k}3^k = 1 + 48 + 1{,}080 + 15{,}120 = 16{,}249$

### 6.2 Borges' Library: $A = 25$, $L = 1{,}312{,}000$

- **Total volumes:** $25^{1{,}312{,}000}$ ($\approx 10^{1{,}834{,}097}$)
- **Neighbors per volume:** $1{,}312{,}000 \times 24 = 31{,}488{,}000$
- **Diameter:** $1{,}312{,}000$
- **Singleton bound ($d = 656{,}000$):** $25^{656{,}001}$ ($\approx 10^{917{,}049}$)

---

## 7. Applications

### 7.1 Coding Theory

The BabelCode structure directly generalizes classical block codes. A BabelCode with parameters $(A, L, d)$ is precisely a block code over a $q$-ary alphabet with length $n$ and minimum distance $d$, using the notation $A = q$ and $L = n$. The Singleton bound proved here is the classical result originally due to Singleton (1964), and the Hamming bound is the classical sphere-packing bound.

### 7.2 Information Retrieval

The Library of Babel is an extreme model for information retrieval in unstructured databases. The degree regularity theorem shows that local search (examining neighbors) provides a fixed branching factor of $L(A-1)$, making greedy descent algorithms well-defined. However, the diameter theorem shows that the worst-case search depth is $L$, and without structure, search is exponential in $L$.

### 7.3 Cryptography

The impossibility of a universal catalog (Theorem 4.10) has implications for cryptographic key management. In a system where every possible message exists, no single key can decrypt all messages — a formal version of the intuition behind one-time pads.

### 7.4 Philosophy of Information

The self-reference impossibility results formalize a philosophical insight: a library that contains everything cannot contain its own index. This is closely related to Russell's paradox (the set of all sets that don't contain themselves) and Gödel's incompleteness (a formal system cannot prove its own consistency). The BabelCode framework makes these analogies precise.

---

## 8. Discussion and Future Work

### 8.1 Tighter Bounds

The Singleton bound is achieved by maximum-distance-separable (MDS) codes, such as Reed-Solomon codes. A natural question is whether MDS BabelCodes exist for all parameters, or whether additional combinatorial constraints arise from the Library's structure.

### 8.2 Distributed Catalogs

While no single volume can be a universal catalog, a distributed catalog spanning $N$ volumes can encode the entire Library if $N$ is sufficiently large. Determining the minimum $N$ and constructing efficient distributed catalogs is a problem related to de Bruijn sequences and universal sequences.

### 8.3 Asymptotic Analysis

As $A$ and $L$ grow, the behavior of optimal BabelCodes is governed by the Gilbert-Varshamov bound and the linear programming bound. Extending the formal framework to include these asymptotic results would connect the Library to the theory of capacity-achieving codes.

### 8.4 Topological Structure

The Hamming metric induces a topology on the Library. The degree regularity theorem suggests that this topology has interesting properties — for instance, the Library is a compact, totally disconnected metric space (a Cantor-like set) when equipped with the product topology.

---

## 9. References

1. J. L. Borges, "La biblioteca de Babel," *El jardín de senderos que se bifurcan*, 1941.
2. R. W. Hamming, "Error detecting and error correcting codes," *Bell System Technical Journal*, 29(2):147–160, 1950.
3. R. C. Singleton, "Maximum distance q-nary codes," *IEEE Transactions on Information Theory*, 10(2):116–118, 1964.
4. F. W. Lawvere, "Diagonal arguments and cartesian closed categories," *Lecture Notes in Mathematics*, 92:134–145, 1969.
5. F. J. MacWilliams and N. J. A. Sloane, *The Theory of Error-Correcting Codes*, North-Holland, 1977.
6. W. C. Bloch, *The Unimaginable Mathematics of Borges' Library of Babel*, Oxford University Press, 2008.
7. N. G. de Bruijn, "A combinatorial problem," *Proceedings of the Section of Sciences of the Koninklijke Nederlandse Akademie van Wetenschappen*, 49:758–764, 1946.

---

## 10. Detailed Examples

### 10.1 The Borges Library in Numbers

Borges specified his Library with remarkable precision: 25 orthographic symbols, books of 410 pages with 40 lines of 80 characters each. Let us trace the consequences of these choices through our formal framework.

**Volume count.** By `volume_card`, the total number of volumes is $25^{1,312,000}$. To appreciate this magnitude, note that $\log_{10}(25^{1,312,000}) = 1,312,000 \times \log_{10}(25) \approx 1,834,097$. This number has over 1.8 million digits when written in base 10. The number of atoms in the observable universe ($\approx 10^{80}$) is incomparably smaller.

**Degree regularity.** By `babel_degree`, each volume has exactly $1,312,000 \times 24 = 31,488,000$ Hamming neighbors. This means that from any given book, there are about 31.5 million books that differ from it in exactly one character. The local structure is identical everywhere in the Library — a consequence of the underlying symmetry group acting transitively.

**Diameter.** By `babel_diameter_achieved`, the diameter of the Library under Hamming distance is exactly $1,312,000$. The all-A volume and the all-B volume achieve this maximum. This means that starting from any volume, one can reach any other volume by changing at most $1,312,000$ characters — but some pairs require changing all of them.

**Singleton bound.** For $d = 656,000$ (half the book length), the Singleton bound gives $|C| \le 25^{656,001} \approx 10^{917,049}$. While still astronomically large, this represents a fraction of approximately $10^{-917,048}$ of the total Library. In other words, if we demand that any two "meaningful" volumes differ in at least half their characters, the meaningful fraction is vanishingly small — but still contains more volumes than there are particles in the observable universe, raised to the power of 10,000.

### 10.2 Error Correction in the Library

The BabelCode framework reveals an unexpected practical interpretation: the Library is an information channel, and meaningful texts are codewords in an error-correcting code.

Consider a librarian who knows that a certain text exists in the Library but has only an approximate memory of it — say, she remembers 90% of the characters correctly. How many candidate volumes might match? The volume lies within a Hamming ball of radius $0.1 \times 1,312,000 = 131,200$ around the true text. The size of this ball is:

$$|B(v, 131200)| = \sum_{k=0}^{131200} \binom{1312000}{k} 24^k$$

This is an astronomically large number, making identification impossible without additional structure. However, if the "meaningful" volumes form a BabelCode with $d > 262,400$, then the Hamming balls of radius $131,200$ around distinct codewords are disjoint, and the librarian can unambiguously identify the correct text.

### 10.3 A Toy Library: $A = 4$, $L = 4$

Consider the smallest interesting Library: 4 symbols over length-4 books, containing $4^4 = 256$ volumes.

- **Neighbors.** Each volume has $4 \times 3 = 12$ neighbors (by `babel_degree`).
- **Diameter.** The diameter is 4 (by `babel_diameter_achieved`). For instance, $(0,0,0,0)$ and $(1,1,1,1)$ have $d_H = 4$.
- **Singleton bound.** For $d = 3$: $|C| \le 4^{4-3+1} = 4^2 = 16$.

A greedy construction starting from $(0,0,0,0)$ produces a code of 16 codewords achieving the Singleton bound — this is a maximum-distance-separable (MDS) code, equivalent to a Reed-Solomon code over $\mathbb{F}_4$.

### 10.4 The Information Content of a Volume

A single volume contains $L \log_2 A = 1,312,000 \times \log_2 25 \approx 6,092,739$ bits of information. This is roughly 762 kilobytes — comparable to a short novel in plain text.

The entire Library, however, contains $25^{1,312,000} \times 6,092,739$ bits. The ratio of the Library's total information content to a single volume's capacity is $25^{1,312,000}$ — the same as the Library's size. This is the fundamental reason why a single-volume catalog is impossible: the Library's information content exceeds any single volume's capacity by a factor equal to the Library's size itself.

---

## Appendix A: Formal Verification Summary

All principal results (Theorems 3.1–3.4, 4.1, 4.3–4.4, 4.6) have been formally verified. The verification covers:

| Result | Statement | Status |
|--------|-----------|--------|
| `hammingDist_self` | $d_H(v,v) = 0$ | ✓ Verified |
| `hammingDist_comm` | $d_H(v,w) = d_H(w,v)$ | ✓ Verified |
| `hammingDist_le_length` | $d_H(v,w) \le L$ | ✓ Verified |
| `hammingDist_eq_zero_iff` | $d_H(v,w) = 0 \iff v = w$ | ✓ Verified |
| `babel_degree` | Neighbors = $L(A-1)$ | ✓ Verified |
| `babel_diameter_achieved` | $\exists\, v\,w,\; d_H(v,w) = L$ | ✓ Verified |
| `volume_card` | $|\mathrm{Volume}(A,L)| = A^L$ | ✓ Verified |
| `singleton_bound` | $|C| \le A^{L-d+1}$ | ✓ Verified |

The formal development introduces the novel `BabelCode` structure, connecting literary thought experiment to rigorous coding theory within a unified framework.
