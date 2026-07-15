# Universal Libraries, Passage Probabilities, and Optimal Cyclic Indexes

**Aristotle**

**15 July 2026**

## Abstract

A universal finite library is the set of all strings of a fixed length $L$ over an alphabet of size $A$. This elementary model isolates three questions often blurred together in discussions of universal information spaces: how many objects exist, how frequently a prescribed passage occurs, and how efficiently shorter objects can be indexed by overlapping windows. We prove that the library contains exactly $A^L$ volumes; prescribing symbols at $d$ distinct positions leaves exactly $A^{L-d}$ compatible volumes; and a fixed passage of length $m$ occurs at a fixed injective family of positions in exactly $A^{L-m}$ volumes. For contiguous occurrence anywhere in a volume, the number of matching volumes is at most $(L-m+1)A^{L-m}$, yielding the probability bound $(L-m+1)A^{-m}$ under uniform sampling. The bound’s prefactor is the number of possible placements, not the target length, and exact probabilities depend on self-overlap. We also exhibit the cyclic word $0010203112132233$, whose sixteen length-two cyclic windows list every ordered pair over a four-symbol alphabet exactly once. This construction attains the window-capacity lower bound and illustrates the de Bruijn graph method. Finally, we separate syntactic occurrence from semantic validity and explain why catalog claims require an explicit coding and decoding model.

## 1. Introduction

The idea of a library containing every possible book is simultaneously finite and disorienting. Once the alphabet and book length are fixed, the collection is a finite Cartesian power. Every possible text occurs, but almost all texts lack any interpretation of interest. The resulting tension—complete existence versus practical unfindability—appears in exhaustive search, information theory, sequence design, software testing, and biological motif detection.

This paper develops the finite combinatorics needed to reason precisely about such a library. Let $A$ be the alphabet size and $L$ the common volume length. The principal example has $A=25$ and $L=1{,}312{,}000$, giving $25^{1{,}312{,}000}$ volumes. The scale is immense, but the governing arguments remain transparent.

There are three layers.

1. **Global counting.** A volume is a function from $L$ positions to $A$ symbols, so the library has cardinality $A^L$.
2. **Local constraints and passage occurrence.** Prescribing symbols at distinct positions removes one factor of $A$ per position. This gives exact fixed-location counts and an anywhere-in-the-volume union bound.
3. **Cyclic indexing.** Overlapping windows can list all shorter words at optimal capacity. An explicit four-symbol cycle lists all sixteen length-two words exactly once.

The distinction between syntax and semantics is central. The event that a volume contains a fixed character string is mathematically well-defined. The event that it contains a valid proof is not numerically determined until an encoding, grammar, theorem, acceptance procedure, and resource bound have been specified. The results below therefore make exact claims about prescribed symbols and explain how a semantic model could be added without pretending that meaning has an encoding-independent density.

## 2. Definitions and conventions

### 2.1 Alphabets, volumes, and libraries

Let $\Sigma$ be a finite alphabet with cardinality $|\Sigma|=A$, where $A$ is a nonnegative integer. For a nonnegative integer $L$, define a **volume of length $L$** to be a function

$$
s:\{0,1,\ldots,L-1\}\longrightarrow\Sigma.
$$

Equivalently, a volume is a string $s_0s_1\cdots s_{L-1}$. The **universal library** $\mathcal L(A,L)$ is the set of all such volumes.

For $A>0$, uniform random sampling from $\mathcal L(A,L)$ means that each volume has probability $A^{-L}$. Equivalently, the symbols at the $L$ positions are independent and uniformly distributed over $\Sigma$.

### 2.2 Prescribed positions

Let $S\subseteq\{0,1,\ldots,L-1\}$ be a set of positions and let $p$ prescribe a symbol $p(i)\in\Sigma$ for each $i\in S$. A volume $s$ **matches $p$ on $S$** if $s(i)=p(i)$ for every $i\in S$.

A more general indexed pattern consists of a map

$$
\iota:\{0,1,\ldots,m-1\}\longrightarrow\{0,1,\ldots,L-1\}
$$

and a word $q$ of length $m$. We say that $q$ **occurs along $\iota$ in $s$** if

$$
s(\iota(j))=q(j)\qquad\text{for every }0\leq j<m.
$$

The map $\iota$ must be injective for the clean count below. If an index repeats, two constraints may duplicate one another or demand conflicting symbols at the same location.

### 2.3 Contiguous windows

Assume $m\leq L$. For each starting position $i\in\{0,1,\ldots,L-m\}$, the contiguous length-$m$ window beginning at $i$ is the injective map $j\mapsto i+j$. A pattern $q$ **occurs somewhere** in $s$ if there is at least one such $i$ for which

$$
s(i+j)=q(j)\qquad(0\leq j<m).
$$

There are exactly $L-m+1$ possible starting positions.

### 2.4 Cyclic windows

For a cyclic word $c_0c_1\cdots c_{n-1}$, indices are read modulo $n$. Its length-$k$ cyclic window at $i$ is

$$
(c_i,c_{i+1},\ldots,c_{i+k-1}),
$$

where subscripts are reduced modulo $n$. A cyclic word is a **complete order-$k$ index** over $\Sigma$ if its cyclic length-$k$ windows list every member of $\Sigma^k$ exactly once.

This terminology emphasizes the indexing function of a de Bruijn cycle: a starting location is an address for the unique short word visible there.

## 3. Fundamental counting results

### Theorem 1 (Library cardinality)

For all nonnegative integers $A$ and $L$, the universal library satisfies

$$
|\mathcal L(A,L)|=A^L.
$$

#### Proof sketch

At each of the $L$ positions there are $A$ independent symbol choices. The multiplication principle gives a product of $L$ factors equal to $A$, hence $A^L$. Equivalently, the number of functions from an $L$-element set to an $A$-element set is $A^L$. The usual convention $A^0=1$ accounts for the unique empty volume.

For $A=25$ and $L=1{,}312{,}000$, the exact cardinality is

$$
25^{1{,}312{,}000}.
$$

Its decimal digit count is

$$
1+\left\lfloor1{,}312{,}000\log_{10}25\right\rfloor=1{,}834{,}098.
$$

### Theorem 2 (Constrained-content count)

Let $S$ be a set of $d$ distinct positions in a length-$L$ volume, and prescribe one alphabet symbol at each position in $S$. Then exactly

$$
A^{L-d}
$$

volumes satisfy all prescriptions.

#### Proof sketch

The symbols on $S$ are fixed, while every position in the complement $S^c$ is free. Since $|S^c|=L-d$, restriction to $S^c$ gives a bijection between matching volumes and arbitrary functions $S^c\to\Sigma$. Conversely, any assignment on $S^c$ can be glued to the prescribed assignment on $S$, producing a unique volume. There are $A^{L-d}$ assignments on the complement.

This theorem is the reusable core of the counting theory. The library cardinality is recovered by taking $S$ empty. Fixed-location passage counts arise by taking $S$ to be the image of an injective family of pattern positions.

### Corollary 3 (Exact fixed-position pattern count)

Let $q$ be a pattern of length $m$, and let $\iota$ select $m$ distinct positions in a volume of length $L$. Then the number of volumes in which $q$ occurs along $\iota$ is exactly

$$
A^{L-m}.
$$

If $A>0$ and the library is sampled uniformly, the corresponding probability is exactly

$$
A^{-m}.
$$

#### Proof sketch

The injective image of $\iota$ contains exactly $m$ positions. Prescribing $q(j)$ at $\iota(j)$ therefore invokes Theorem 2 with $d=m$. Dividing the resulting count $A^{L-m}$ by the total count $A^L$ gives $A^{-m}$.

### Remark 4 (Why injectivity matters)

Without injectivity, the conclusion can fail in two ways. If $\iota(j)=\iota(k)$ and $q(j)=q(k)$, the second constraint is redundant, so fewer than $m$ independent positions are fixed. If $q(j)\neq q(k)$, no volume satisfies the constraints. Thus the clean exponent $L-m$ reflects the number of distinct, mutually compatible prescriptions, not merely the number of entries in a list.

## 4. Passage occurrence anywhere

For a fixed pattern $q$ of length $m\leq L$, let $E_i$ be the set of volumes in which $q$ begins at position $i$. Corollary 3 gives

$$
|E_i|=A^{L-m}
$$

for every $0\leq i\leq L-m$. The set of volumes containing $q$ somewhere is $\bigcup_iE_i$.

### Theorem 5 (Occurrence union bound)

Let $q$ be a fixed length-$m$ pattern over an alphabet of size $A$, with $m\leq L$. Then

$$
\left|\left\{s\in\mathcal L(A,L):q\text{ occurs contiguously in }s\right\}\right|
\leq (L-m+1)A^{L-m}.
$$

If $A>0$, the uniform occurrence probability satisfies

$$
\Pr(q\text{ occurs somewhere})
\leq \frac{L-m+1}{A^m}.
$$

#### Proof sketch

There are $L-m+1$ starting windows. Each event $E_i$ has cardinality $A^{L-m}$. The cardinality of a finite union is at most the sum of the cardinalities, so

$$
\left|\bigcup_{i=0}^{L-m}E_i\right|
\leq\sum_{i=0}^{L-m}|E_i|
=(L-m+1)A^{L-m}.
$$

Dividing by $A^L$ yields the probability inequality.

### Corollary 6 (Babel-scale passage bound)

For $A=25$ and $L=1{,}312{,}000$, any fixed pattern of length $m\leq1{,}312{,}000$ satisfies

$$
\Pr(q\text{ occurs somewhere})
\leq\frac{1{,}312{,}001-m}{25^m}.
$$

Since every probability is at most $1$, a numerically sharper presentation is

$$
\Pr(q\text{ occurs somewhere})
\leq\min\left\{1,\frac{1{,}312{,}001-m}{25^m}\right\}.
$$

### 4.1 Why the bound is not generally exact

Events at different windows overlap. For binary strings of length $3$ and the target $11$, the possible windows begin at positions $0$ and $1$. Each event contains $2$ strings, so their summed size is $4$. Their union consists of $011$, $110$, and $111$, hence has size $3$. The word $111$ belongs to both events. Thus the exact probability is $3/8$, while the union bound is $1/2$.

The size of such intersections depends on the target’s self-overlap. A pattern has a **border** of length $r$ if its prefix of length $r$ equals its suffix of length $r$. Overlapping occurrences at displacement $d<m$ are compatible precisely when the overlap of length $m-d$ agrees, which is a border condition. Consequently, exact global occurrence probabilities depend not only on $A$, $L$, and $m$, but on the autocorrelation structure of the particular pattern.

This also identifies the correct polynomial prefactor in a first-order rare-event estimate. For literal occurrence of a fixed length-$m$ string, the number of candidate placements is $L-m+1$, not $m$. When occurrence events are rare and overlaps negligible, one expects a value near

$$
(L-m+1)A^{-m},
$$

but the theorem established here is the always-valid upper bound.

## 5. A complete four-symbol cyclic index

Let the alphabet be $\Sigma=\{0,1,2,3\}$. Consider the cyclic word

$$
C=0010203112132233.
$$

Its sixteen cyclic length-two windows, in order, are

$$
00,01,10,02,20,03,31,11,12,21,13,32,22,23,33,30.
$$

### Theorem 7 (Complete mini-library index)

The cyclic length-two windows of $C$ are in bijection with $\Sigma^2$. In particular, every two-symbol word over $\Sigma$ occurs at a unique cyclic starting position in $C$.

#### Proof sketch

The displayed list contains sixteen distinct ordered pairs. The complete two-symbol library also contains $|\Sigma^2|=4^2=16$ pairs. Therefore the window map from the sixteen cyclic positions to $\Sigma^2$ is injective between finite sets of equal cardinality and hence bijective. Existence and uniqueness of a location follow immediately.

### Proposition 8 (Optimality by window capacity)

Any cyclic word whose length-two windows list every word in $\Sigma^2$ must have length at least $16$. The word $C$ attains this lower bound.

#### Proof sketch

A cyclic word of length $n$ has exactly $n$ cyclic starting positions and therefore at most $n$ distinct length-two windows. Listing all $4^2=16$ pairs requires $n\geq16$. Theorem 7 supplies a collision-free example with $n=16$.

### 5.1 Cyclic versus linear presentation

The final pair $30$ uses the last symbol $3$ and the first symbol $0$. If the construction is displayed as an ordinary linear string without wraparound, that pair is absent. A linear string displaying the same sixteen windows must repeat the first symbol at the end:

$$
00102031121322330.
$$

It then has length $17$ and exactly $16$ consecutive length-two windows.

### 5.2 Graph interpretation

Construct a directed graph with one vertex for each symbol in $\Sigma$. For every ordered pair $ab$, include one directed edge from $a$ to $b$. A cyclic word determines a walk: successive symbols give successive vertices, and every two-symbol window is the edge traversed between them. A complete order-two index is therefore an Eulerian circuit, a closed walk using every directed edge exactly once.

The displayed sequence corresponds to such a circuit in the complete directed graph with loops on four vertices. Every vertex has four incoming and four outgoing edges, and the graph is connected in the relevant directed sense, which explains why an Eulerian tour exists. Hierholzer’s algorithm constructs one in time linear in the number of edges, here $O(A^2)$. For general order $k$, vertices are words of length $k-1$ and edges are words of length $k$, directed from a word’s prefix to its suffix. An Eulerian circuit then yields a cyclic word whose length-$k$ windows list all $A^k$ words.

The explicit theorem above concerns the concrete four-symbol, order-two cycle. The graph discussion gives the structural route to the general construction and clarifies why overlap achieves optimal capacity.

## 6. Algorithms

### 6.1 Enumeration for exact finite experiments

For small $A$ and $L$, an exact occurrence probability can be computed by enumerating all $A^L$ volumes, testing each possible start, and counting successes. The time complexity is $O(A^L(L-m+1)m)$ under direct comparison, and the memory can be $O(L)$ if volumes are streamed. This is exponential in $L$ and serves as a validation method, not a scalable search procedure.

### 6.2 Exact counting by automata

A scalable exact method builds a prefix automaton for the target pattern. A state records the length of the longest suffix of the text seen so far that is also a prefix of the pattern. Appending a symbol updates this state. A dynamic program over positions and states counts strings that have not yet reached the accepting state. If $N_{\mathrm{avoid}}(L)$ is the number avoiding the target, then

$$
N_{\mathrm{contain}}(L)=A^L-N_{\mathrm{avoid}}(L).
$$

With a precomputed transition table, the complexity is $O(LmA)$ time and $O(m)$ rolling memory. The automaton automatically captures all self-overlaps, turning the qualitative border discussion into exact arithmetic.

### 6.3 Eulerian construction of cyclic indexes

For alphabet size $A$ and order $k$, form the overlap graph whose $A^{k-1}$ vertices are length-$(k-1)$ words and whose $A^k$ directed edges are length-$k$ words. An edge $x_1\cdots x_k$ runs from $x_1\cdots x_{k-1}$ to $x_2\cdots x_k$. Every vertex has equal indegree and outdegree $A$. An Eulerian circuit gives a cyclic index of length $A^k$.

Hierholzer’s algorithm traverses each edge once, so its running time and storage are $O(A^k)$, proportional to the unavoidable output size. The order-two mini-index can be checked by this graph model or directly by the sixteen displayed windows.

## 7. Catalog capacity and coding assumptions

A universal library contains $A^L$ volumes. A direct fixed-width address identifying one volume requires

$$
\log_2(A^L)=L\log_2 A
$$

bits. A literal table containing one full independent address for every volume would therefore require

$$
A^L L\log_2 A
$$

bits, ignoring delimiters and metadata. By contrast, one length-$L$ volume over the same alphabet carries $L\log_2 A$ bits under the elementary fixed-width encoding. It cannot hold that literal address table.

This is a counting obstruction, not a prohibition on every possible notion of a catalog. A short algorithm may generate addresses; entries may share prefixes; a distributed index may spread data across volumes; and a de Bruijn cycle may encode objects as overlapping windows rather than independent records. Each changes the decoding model. Statements about minimum catalog size are meaningful only after specifying:

- what constitutes an address;
- whether entries must be independently accessible;
- whether an algorithm may generate entries rather than store them;
- how delimiters are represented;
- whether cyclic overlap is allowed;
- and what computational resources the decoder may use.

The complete mini-library index catalogs all two-symbol volumes using sixteen cyclic positions. It does **not** catalog the $4^{16}$ possible length-sixteen volumes. This difference is exactly the difference between the order of the indexed windows and the length of the carrier cycle.

## 8. Semantic validity as language density

The counting theorems concern prescribed symbols. They do not assign an encoding-independent probability to meaningfulness or proof validity. To pose a precise proof-density problem, fix:

1. a finite character alphabet and encoding;
2. a decidable grammar of candidate texts;
3. a theorem or specification to be established;
4. a deterministic acceptance procedure;
5. and a resource bound, if termination or finite computation is required.

These choices define a language $P\subseteq\Sigma^*$ of accepted proof strings. One can then ask for the number of length-$m$ members of $P$, or for the probability that a random length-$L$ volume contains some member of $P$ as a substring. If $P_m=P\cap\Sigma^m$, a direct union bound gives

$$
\Pr(\text{some accepted length-}m\text{ string occurs})
\leq |P_m|(L-m+1)A^{-m}.
$$

This follows by applying Theorem 5 to each accepted string and then taking another finite union. It may overcount both overlapping placements of one proof and occurrences of different accepted proofs. Nevertheless, it cleanly separates two sources of rarity: the syntactic penalty $A^{-m}$ and the number $|P_m|$ of accepted encodings.

For a bounded-memory deterministic checker, accepted strings can often be modeled by a finite automaton. Their counts are then entries of powers of a finite transition matrix, and their exponential growth rate is controlled by that matrix’s spectral radius. Thus “proof probability” becomes a language-density question, rather than a property of meaning in isolation.

## 9. Applications

### 9.1 Motif detection

In genomics, a fixed nucleotide motif of length $m$ over an idealized four-letter alphabet has fixed-location probability $4^{-m}$ under the uniform independent model and anywhere-in-sequence upper bound $(L-m+1)4^{-m}$. Real genomes require nonuniform and dependent models, but the universal-library calculation supplies a baseline and makes overlap corrections explicit.

### 9.2 Signature scanning

A fixed byte signature of length $m$ in a uniformly random byte stream has alphabet size $256$ and fixed-position probability $256^{-m}$. The union bound estimates false positives across a buffer. Multiple signatures introduce a second union, while automata provide exact or efficient multi-pattern scanning.

### 9.3 Exhaustive testing and sequence design

A de Bruijn cycle of order $k$ supplies every possible length-$k$ local input exactly once cyclically. This minimizes the carrier length and is useful for testing finite-state systems, sensor encoders, and communication channels. The overlap graph explains both construction and optimality.

### 9.4 Information retrieval

The universal-library model emphasizes that recall without discrimination is useless. A database containing every string has perfect existential coverage but no intrinsic relevance ranking. Index structure, decoding rules, and semantic filters supply the information absent from mere inclusion.

## 10. Discussion

The principal formulas are simple because the model is intentionally clean. Their value lies in enforcing distinctions that grand claims about universal libraries often erase.

First, exact fixed-position counting is stronger and cleaner than an informal independence heuristic. Prescribing $m$ distinct symbols gives exactly $A^{L-m}$ compatible books.

Second, moving from one position to “somewhere” changes the problem from a product count to a union. The universally valid result is an upper bound. Exactness requires intersection data, and for a single repeated pattern those intersections are governed by borders and autocorrelation.

Third, semantic claims require a language model. A literal string has a length; a mathematical proof can have many encodings. Without specifying what is accepted, “the probability of a proof” is not a single mathematical quantity.

Fourth, catalog size depends on the representation of entries. A de Bruijn index uses overlapping windows and achieves one short object per cyclic position. A table of independently decodable full addresses has different capacity requirements. An algorithm that generates addresses is different again.

The four-symbol construction demonstrates the sharp local indexing phenomenon without overclaiming. Its sixteen positions index the sixteen words of length two. It reaches the unavoidable lower bound, and its graph structure points toward arbitrary alphabets and orders.

## 11. Future work

Several directions naturally extend this framework.

**Exact autocorrelation laws.** For every alphabet size at least two and every finite pattern, the exact probability of occurrence in a random fixed-length volume should be expressible from the pattern’s border lattice through a finite cluster expansion. Patterns of equal length are expected to have identical occurrence probabilities in every ambient length precisely when their overlap autocorrelation polynomials agree.

**Optimal distributed catalogs under block coding.** If each catalog volume decodes into independently addressable entries under a prefix-free delimiter scheme, the minimum number of carrier volumes should be determined by the maximum number of complete addresses per carrier, with delimiter redundancy controlled by Kraft-type inequalities. This would reconcile competing capacity estimates by making the unit of an entry explicit.

**General sharp cyclic index theorem.** For positive $A$ and $k$, one seeks a cyclic word of length $A^k$ whose length-$k$ cyclic windows list every word once, together with the characterization of optimal collision-free indexes as Eulerian circuits in the order-$(k-1)$ overlap graph. The explicit order-two example is the smallest nonbinary illustration of this structure.

**Semantic proof density under certified grammars.** Once an encoding, decidable grammar, resource-bounded checker, and theorem are fixed, accepted proof strings form a precise language. Computable upper and lower density bounds should be derived from its automata or transfer-matrix structure. For bounded-memory deterministic checkers, the exponential rate should be algebraic and computable from a finite matrix.

## 12. Conclusion

A universal finite library is governed by exact combinatorics. It contains $A^L$ volumes. Prescribing $d$ distinct symbols leaves $A^{L-d}$ possibilities. A specified length-$m$ passage at one location occupies exactly the fraction $A^{-m}$, while occurrence anywhere has probability at most $(L-m+1)A^{-m}$. Exact global probabilities require the pattern’s overlap structure.

The cyclic word $0010203112132233$ provides a complementary result: its sixteen cyclic pairs list all two-symbol words over four symbols exactly once, attaining the capacity lower bound. Its success comes from overlap organized as an Eulerian circuit.

Together, these results sharpen the central paradox of universal information spaces. Containing every possible text solves existence but not retrieval, interpretation, or compression. Those tasks require additional structure—a pattern model, an index, a decoder, or a semantics—and each such structure is itself constrained by counting.
