# Universal Finite Libraries: Exact Probabilities, Numerical Catalogs, and Sharp Storage Bounds

## Abstract

A universal finite library consists of all fixed-length words over a finite alphabet. Although this model is elementary, it cleanly separates several notions that are often conflated: containing every text, assigning every text an index, enumerating all texts compactly, and storing a complete address table. We establish the exact cardinality $q^n$ of a library with alphabet size $q$ and volume length $n$; derive exact uniform probabilities for individual texts and arbitrary decidable acceptance rules; construct a lossless numerical catalog; and analyze the four-symbol, length-sixteen case, which has exactly $2^{32}$ volumes and a $32$-bit index space. We then prove that no single volume can losslessly represent every complete address table when the library has at least two members. More generally, $N$ storage volumes have exactly $q^{nN}$ states, implying the sharp lower bound $N\ge q^n$ for representing every address table. We distinguish this random-access requirement from overlap-based cyclic enumeration by de Bruijn sequences. Finally, a counting argument connects library scale to bounded-description incompressibility for real functions. The results provide a self-contained information-theoretic account of universal text spaces and identify semantic structure as the only possible source of compression beyond worst-case capacity bounds.

## 1. Introduction

The idea of a library containing every possible book is both literary and mathematical. Fix an alphabet and a book length. If every position may contain every alphabet symbol, then all possible books form a finite set. Such a library includes every valid proof that fits, every invalid proof, every meaningful narrative, and every random-looking sequence. Universality at the level of syntax is therefore easy to obtain; finding meaning inside the resulting space is the difficult part.

The distinction matters in several practical settings. Password search explores a finite word space. Randomized software testing samples inputs and asks whether a checker accepts them. Molecular design searches a finite encoding space for candidates with a desired property. Databases map keys to values and face capacity limits when all assignments must be representable. In each case, ambient size, acceptance density, enumeration, indexing, and storage are related but nonidentical quantities.

Let $q$ be the number of symbols and $n$ the number of positions in each volume. We treat a volume as a function from the position set $\{0,\ldots,n-1\}$ to the symbol set $\{0,\ldots,q-1\}$. This functional description makes no assumptions about typography or semantics. It captures only fixed-length strings.

Our main conclusions are as follows.

1. The library contains exactly $q^n$ volumes.
2. Under uniform selection, one prescribed volume has probability $q^{-n}$. For any explicit acceptance predicate, the exact success probability is the number of accepted volumes divided by $q^n$.
3. Every volume has a unique integer index in $\{0,\ldots,q^n-1\}$, obtained by base-$q$ evaluation.
4. A single volume cannot losslessly encode every possible complete address table once the library has at least two books.
5. A distributed store of $N$ volumes has exactly $q^{nN}$ states. Representing every complete address table requires $N\ge q^n$, and this bound is sharp at the raw-storage level.
6. For any library scale $q^n$, bounded expression languages omit some real function even when allowed descriptions of size at most $q^n$.

These statements also clarify the role of de Bruijn sequences. A cyclic word can display every length-$n$ volume exactly once as a moving window, achieving optimal overlap for sequential enumeration. This does not by itself provide a compact complete inverse index mapping each volume to its position. Sequential generation and random-access location are separate algorithmic objectives.

## 2. Mathematical Model

### 2.1 Words and libraries

**Definition 2.1 (Alphabet).** For an integer $q\ge0$, the $q$-symbol alphabet is

$$
\Sigma_q=\{0,1,\ldots,q-1\}.
$$

**Definition 2.2 (Volume).** For an integer $n\ge0$, a volume of length $n$ over $\Sigma_q$ is a tuple

$$
w=(w_0,w_1,\ldots,w_{n-1})\in\Sigma_q^n.
$$

Equivalently, it is a function $w:\{0,\ldots,n-1\}\to\Sigma_q$.

**Definition 2.3 (Universal finite library).** The library $L_{q,n}$ is the set of all length-$n$ volumes over $\Sigma_q$:

$$
L_{q,n}=\Sigma_q^n.
$$

The model permits $q=0$ or $n=0$, using standard finite-product conventions. The principal catalog statements concern nontrivial libraries with $q^n\ge2$.

### 2.2 Uniform probability and acceptance

When $L_{q,n}$ is nonempty, uniform selection assigns equal mass to every volume. Let $P$ be an explicitly decidable property of volumes and define its acceptance set

$$
A_P=\{w\in L_{q,n}:P(w)\}.
$$

**Definition 2.4 (Uniform acceptance probability).** The uniform probability of $P$ is

$$
\mu_{q,n}(P)=\frac{|A_P|}{|L_{q,n}|}.
$$

This definition deliberately separates syntax from semantics. The predicate may test exact equality, grammatical validity, proof validity under fixed rules, a cryptographic pattern, or any other deterministic property. Without specifying the predicate, “the probability of meaning” has no exact mathematical value.

### 2.3 Catalogs and address tables

Three catalog notions must be distinguished.

**Definition 2.5 (Numerical catalog).** A numerical catalog is a bijection

$$
I:L_{q,n}\longrightarrow\{0,1,\ldots,q^n-1\}.
$$

It assigns each volume a unique number.

**Definition 2.6 (Complete address table).** A complete address table is an arbitrary function

$$
T:L_{q,n}\to L_{q,n}.
$$

Each input volume receives an independently chosen volume-sized address. The class of all tables is denoted $L_{q,n}^{L_{q,n}}$.

**Definition 2.7 (Distributed storage).** A store of $N$ volumes is an $N$-tuple in $L_{q,n}^N$. A lossless encoding of an object class $C$ into that store is an injective function $E:C\to L_{q,n}^N$.

A numerical catalog is one fixed bijection. A complete address table is one member of an enormous function space. An encoder capable of storing every table must distinguish all members of that space. This quantifier difference drives the lower bounds below.

## 3. Exact Enumeration and Probability

### 3.1 Cardinality

**Theorem 3.1 (Library Size).** For all nonnegative integers $q$ and $n$,

$$
|L_{q,n}|=q^n.
$$

**Proof sketch.** Each of the $n$ positions admits $q$ independent choices. The multiplication principle gives a product of $n$ factors equal to $q$, namely $q^n$. Equivalently, the number of functions from an $n$-element set to a $q$-element set is $q^n$. $\square$

For the literary parameters $q=25$ and $n=1{,}312{,}000$, this gives the exact count

$$
|L_{25,1{,}312{,}000}|=25^{1{,}312{,}000}.
$$

The base-ten order of magnitude follows from logarithms:

$$
\log_{10}|L_{25,1{,}312{,}000}|=1{,}312{,}000\log_{10}(25)\approx1{,}834{,}097.29.
$$

Thus the count has $1{,}834{,}098$ decimal digits. This approximation is illustrative; the exact result remains the power above.

### 3.2 Exact matches

**Theorem 3.2 (Exact-Volume Probability).** Assume $q\ge1$. For any prescribed $w\in L_{q,n}$, uniform random selection yields

$$
\Pr(X=w)=\frac{1}{q^n}.
$$

**Proof sketch.** The singleton $\{w\}$ contains one favorable outcome and Theorem 3.1 gives $q^n$ total outcomes. Uniformity assigns the ratio $1/q^n$. $\square$

This theorem concerns byte-for-byte identity. It is not automatically the probability of selecting a text equivalent in meaning, a text expressing the same theorem, or any valid proof of that theorem. Those events generally contain multiple volumes and require explicit definitions.

### 3.3 General acceptance rules

**Theorem 3.3 (Exact Checker Probability).** Let $P$ be any decidable acceptance predicate on $L_{q,n}$ and assume $q\ge1$. Then

$$
\mu_{q,n}(P)=\frac{|\{w\in L_{q,n}:P(w)\}|}{q^n}.
$$

**Proof sketch.** Substitute the library cardinality from Theorem 3.1 into Definition 2.4. $\square$

Although immediate, this theorem enforces the correct modeling discipline. Suppose a deterministic grammar and derivation checker accept $a_n$ texts of length $n$. Then exact random-search success is $a_n/q^n$. A heuristic based only on the length or complexity of one proof cannot determine $a_n$. Whitespace policies, encodings, aliases, comments, theorem statements, and proof calculus all alter the accepted set.

**Corollary 3.4 (Unique Accepted Text).** If exactly one length-$n$ volume is accepted, then the acceptance probability is $1/q^n$.

**Proof sketch.** Set the numerator in Theorem 3.3 equal to one. $\square$

**Corollary 3.5 (Multiple Encodings).** If exactly $m$ volumes are accepted, then the probability is $m/q^n$.

**Proof sketch.** Substitute the accepted-set cardinality $m$ into Theorem 3.3. $\square$

This reduction converts semantic probability into finite enumeration. Its difficulty lies not in the denominator but in counting the accepted language.

## 4. Constructive Numerical Catalogs

### 4.1 Base-$q$ indexing

Assume $q\ge1$. Given $w=(w_0,\ldots,w_{n-1})$, define

$$
I(w)=\sum_{i=0}^{n-1}w_iq^{n-1-i}.
$$

**Theorem 4.1 (Numerical Catalog).** The map $I$ is a bijection from $L_{q,n}$ to $\{0,1,\ldots,q^n-1\}$.

**Proof sketch.** The expression is the ordinary base-$q$ value of the digit tuple. Its value lies between $0$ and

$$
(q-1)\sum_{j=0}^{n-1}q^j=q^n-1
$$

when $q>1$; the one-symbol case is immediate. Uniqueness of fixed-length base-$q$ expansions proves injectivity. Conversely, repeated Euclidean division by $q$ recovers $n$ digits for every integer below $q^n$, padding with leading zeros as necessary, which proves surjectivity. $\square$

The inverse algorithm repeatedly records the remainder modulo $q$ and divides the quotient by $q$. Both ranking and unranking require $O(n)$ iterations. If unit-cost arithmetic is assumed, this is $O(n)$ time; bit complexity additionally reflects that intermediate integers contain up to $n\log_2q$ bits.

This theorem establishes a lossless catalog in the sense of naming. It does not assert that all entries can be materialized economically. The indexing rule itself is short because it exploits the regular product structure of the library.

### 4.2 Four-symbol, length-sixteen case

**Theorem 4.2 (Mini-Library Catalog).** A library with $q=4$ symbols and $n=16$ positions has exactly

$$
4^{16}=2^{32}=4{,}294{,}967{,}296
$$

volumes, and these volumes admit a bijective $32$-bit numerical index.

**Proof sketch.** The cardinality follows from Theorem 3.1 and $4=2^2$. Theorem 4.1 gives indices from $0$ through $2^{32}-1$, precisely the unsigned $32$-bit range. $\square$

This case is computationally useful because individual ranks can be calculated instantly even though exhaustive storage or traversal is substantial. For example, the word with digits $(0,1,2,3)$ repeated four times has index obtained by sixteen iterations of $x\leftarrow4x+d$.

### 4.3 Cyclic universal-window enumeration

A de Bruijn cycle of order $n$ over $q$ symbols is a cyclic word of length $q^n$ in which every length-$n$ word appears exactly once as a cyclic consecutive window.

**Theorem 4.3 (Existence of Cyclic Universal-Window Enumeration).** For every $q\ge2$ and $n\ge1$, a de Bruijn cycle of order $n$ over $q$ symbols exists.

**Proof sketch.** Form the directed de Bruijn graph whose vertices are length-$(n-1)$ words. For every length-$n$ word $a_1\cdots a_n$, add an edge from $a_1\cdots a_{n-1}$ to $a_2\cdots a_n$ labeled by that word. Every vertex has indegree and outdegree $q$, and the graph is strongly connected. Hence it has an Eulerian cycle. Reading edge extensions around that cycle produces a cyclic sequence in which each length-$n$ word, corresponding to one edge, occurs once. $\square$

The construction takes $O(q^n)$ output time and $O(q^{n-1})$ graph-scale memory in a direct implementation; specialized generation algorithms can reduce auxiliary space. Its output length is optimal because there are $q^n$ distinct windows to display.

However, a de Bruijn cycle is a compact sequential enumeration, not automatically a complete random-access address table. To locate an arbitrary input word quickly, one needs either computation exploiting a special construction or an auxiliary inverse index. Storing an unconstrained location for every word reintroduces table-capacity costs.

## 5. Impossibility of a Single-Volume Complete Catalog

Let $M=|L_{q,n}|=q^n$. A complete address table is a function from an $M$-element set to itself. Therefore the table space has cardinality

$$
|L_{q,n}^{L_{q,n}}|=M^M=(q^n)^{q^n}.
$$

**Theorem 5.1 (No Single-Volume Complete Catalog).** If $M=q^n\ge2$, there is no injective encoding

$$
E:L_{q,n}^{L_{q,n}}\to L_{q,n}.
$$

In words, no single volume can losslessly represent every possible complete address table.

**Proof sketch.** The source contains $M^M$ objects and the target contains $M$. Since $M\ge2$, one has $M^M>M$. By the finite pigeonhole principle, no injection from the source to the target exists. $\square$

The theorem is a worst-case statement. It does not say that no particular catalog can have a short description. The lexicographic rule, for example, is succinct. Rather, there is no format in which one volume can distinguish every possible assignment of an independent address to every library member. Any claim of universal compression must therefore restrict the table class or permit loss, probabilistic errors, external computation, or shared prior information.

The result is sometimes framed as self-reference, but cardinality is sufficient. No semantic paradox is needed. A volume has enough states to select one of $M$ books; a full table has $M$ independently selected outputs and consequently $M^M$ possibilities.

## 6. Distributed Catalog Capacity

### 6.1 Exact storage law

**Theorem 6.1 (Distributed Storage Cardinality).** A store consisting of $N$ length-$n$ volumes over a $q$-symbol alphabet has exactly

$$
|L_{q,n}^N|=(q^n)^N=q^{nN}
$$

possible states.

**Proof sketch.** There are $nN$ symbol positions across all storage volumes, and each has $q$ choices. Equivalently, multiply $q^n$ choices independently across $N$ blocks. $\square$

**Theorem 6.2 (General Capacity Bound).** Let $C$ be any finite object class. If a lossless encoding $E:C\to L_{q,n}^N$ exists, then

$$
|C|\le q^{nN}.
$$

**Proof sketch.** An injective map between finite sets implies that the source cardinality does not exceed the target cardinality. Apply Theorem 6.1 to the target. $\square$

This theorem is independent of the objects’ interpretation. It is the finite-storage analogue of the basic information bound: $nN\log_2q$ bits cannot distinguish more than $q^{nN}$ states.

### 6.2 Sharp threshold for arbitrary address tables

**Theorem 6.3 (Distributed Complete-Catalog Lower Bound).** Assume $q^n\ge2$. If every complete address table can be encoded losslessly into $N$ storage volumes, then

$$
N\ge q^n.
$$

Equivalently, if $N<q^n$, no injective encoding of all complete address tables into $N$ volumes exists.

**Proof sketch.** The complete table class has $(q^n)^{q^n}=q^{nq^n}$ members. By Theorem 6.2, an encoding would imply

$$
q^{nq^n}\le q^{nN}.
$$

For a nontrivial library the base is at least two, so exponentiation is strictly increasing. Comparison of exponents yields $nq^n\le nN$, hence $q^n\le N$ for positive $n$. Degenerate cases are excluded by $q^n\ge2$. $\square$

**Proposition 6.4 (Raw Attainability).** Exactly $q^n$ storage volumes suffice to represent an arbitrary complete address table by storing one output volume for each input volume in a fixed order.

**Proof sketch.** Use the numerical catalog to order all inputs. In storage block $I(w)$, place the table value $T(w)$. This stores every table without ambiguity using $M=q^n$ blocks. $\square$

Together, Theorem 6.3 and Proposition 6.4 show that the threshold is sharp. At the worst-case raw-data level, a full table requires one address-sized block per key.

### 6.3 Structured and semantic catalogs

Worst-case incompressibility does not prohibit practical compression. Suppose only a subset $C$ of tables is relevant. The general capacity lower bound becomes

$$
N\ge\left\lceil\frac{\log_q|C|}{n}\right\rceil.
$$

If semantic constraints make $|C|$ much smaller than $q^{nq^n}$, fewer blocks may suffice. An algorithm may also answer location queries without storing all answers, trading storage for computation. These possibilities do not violate Theorem 6.3 because they do not represent every arbitrary table as independent raw data.

This distinction parallels data compression. Uniformly random strings are typically incompressible, while natural data often have repeated patterns. Compression relies on a nonuniform source or a restricted model class. In universal libraries, semantics can provide such structure, but syntax alone cannot.

## 7. Bounded-Description Incompressibility

The same counting principle extends beyond books. Consider a fixed expression language with a finite grammar and no arbitrary real constants. Let $D_B$ be the set of valid expressions of size at most $B$, and let each valid expression denote at most one function from $\mathbb{R}$ to $\mathbb{R}$.

Because the grammar and alphabet are finite, $D_B$ is finite for each finite $B$. Therefore only finitely many real functions can be denoted within budget $B$. The class $\mathbb{R}^{\mathbb{R}}$ of all real functions is uncountable and in particular not finite.

**Theorem 7.1 (Library-Scale Incompressibility).** For every $q,n\ge0$, there exists a function $f:\mathbb{R}\to\mathbb{R}$ that is not denoted by any constant-free expression of size at most $q^n$ in the fixed finite expression language.

**Proof sketch.** Set $B=q^n$. There are finitely many expressions of size at most $B$, hence finitely many denoted functions. Since there are more real functions than this finite set, choose one outside it. $\square$

The “constant-free” or otherwise finitely generated qualification is essential. If every real function were admitted as a primitive symbol, the syntax would conceal unlimited information and the finite counting premise would fail. Under a genuinely finite language, the theorem is a direct description-counting result.

The bound $q^n$ is not presented as optimal for a particular function. Its role is conceptual: even a description budget equal to the entire number of books in a universal finite library does not name every real function. Enlarging a finite budget never exhausts an uncountable target class.

## 8. Algorithms and Numerical Demonstrations

### 8.1 Ranking and unranking

The ranking algorithm initializes $r=0$ and processes symbols left to right using

$$
r\leftarrow qr+w_i.
$$

After the final digit, $r=I(w)$. Unranking initializes an array of $n$ zeros and, from right to left, stores $r\bmod q$ before replacing $r$ by $\lfloor r/q\rfloor$. A range check $0\le r<q^n$ ensures validity. Both procedures are inverse by the division algorithm.

### 8.2 Counting accepted words

For small libraries, exact checker probability can be computed by exhaustive enumeration. Generate all $q^n$ words, increment a counter when $P(w)$ is true, and return the rational ratio $a/q^n$. Runtime is $O(q^n(C_P+n))$, where $C_P$ is checker cost, and streaming enumeration uses $O(n)$ auxiliary space. This exponential dependence is unavoidable for a black-box predicate in the worst case, because changing the predicate on one unqueried word can change the exact answer.

### 8.3 de Bruijn generation

An Eulerian-cycle algorithm constructs the graph described in Theorem 4.3 and traverses every edge once. Since edges correspond to words, runtime is $O(q^n)$ plus graph-management overhead. The sequence demonstrates overlap compression: all $q^n$ windows are represented using $q^n$ cyclic symbols rather than $nq^n$ symbols in a concatenated list. It does not compress an arbitrary table of $q^n$ independent addresses.

### 8.4 Capacity audit

Given $(q,n,N)$ and an object count $|C|$, a capacity audit compares $|C|$ with $q^{nN}$. For complete tables, compare $q^{nq^n}$ with $q^{nN}$, or simply test $N\ge q^n$ in nontrivial cases. Working with exponents or logarithms avoids constructing astronomically large integers.

## 9. Applications

### 9.1 Proof-search spaces

Fixing a text encoding and deterministic validity checker produces an accepted language $A_n$. Theorem 3.3 gives exact random success $|A_n|/q^n$. The central research problem is therefore enumerative: derive recurrences, automata, or generating functions for $|A_n|$. Complexity of an individual proof may influence models of $A_n$, but cannot replace its count.

### 9.2 Databases and key-value maps

A complete address table is a key-value map with $M$ keys and $M$ possible values. There are $M^M$ such maps. Any system required to represent all maps needs $M\log_2M$ bits. Here $M=q^n$, and one volume carries $\log_2M=n\log_2q$ bits, giving exactly $M$ volume blocks. Succinct dictionaries beat this bound only by restricting values, exploiting regularity, tolerating errors, or supporting fewer operations.

### 9.3 Security and random search

For uniformly sampled candidate strings, success probability is acceptance density. If trials are independent and one trial succeeds with probability $p$, the probability of at least one success after $t$ trials is

$$
1-(1-p)^t.
$$

For a unique target, $p=q^{-n}$. The expected waiting time is $1/p=q^n$ trials. These consequences quantify why existence inside a universal space does not imply feasible discovery.

### 9.4 Coding and fault tolerance

The noiseless distributed threshold is a baseline for error-correcting catalogs. If symbols can be corrupted, valid storage states must be separated by an error-correcting distance. Sphere-packing and coding-rate bounds then add redundancy beyond $N=q^n$. The exact noiseless capacity $q^{nN}$ identifies the resource before reliability constraints are imposed.

## 10. Discussion

The universal finite library supports four claims of increasing strength:

1. every fixed-length text exists;
2. every text can be assigned a number;
3. every text can be visited in a compact overlapping traversal;
4. every text can have an independently stored address in a complete random-access table.

The first three exploit common structure. The fourth concerns arbitrary independent data and consequently has a sharp linear-in-library-size block cost. Confusing these levels creates apparent paradoxes. A formula for computing an index is not a materialized table. A cyclic enumeration is not an inverse lookup structure. A short description of one special table is not a universal encoding of all tables.

The probability results carry a parallel warning. Ambient cardinality determines the denominator, but semantics determine the numerator. “Meaningful,” “valid,” and “a proof of a given theorem” are properties only after a representation and acceptance rule are fixed. Once fixed, the exact answer is transparent, though counting the accepted set may be difficult.

The incompressibility theorem places these finite observations in a broader setting. Every bounded syntax describes only finitely many objects. A sufficiently rich target class necessarily contains undescribed members. This is not a failure of a particular notation but a consequence of finite information capacity.

## 11. Future Work

Several directions follow naturally. First, one may characterize semantic families whose catalogs are asymptotically smaller than arbitrary address tables while retaining efficient membership and location queries. Second, de Bruijn constructions invite study of optimal inverse indexes: overlap gives optimal sequential output length, but the time-space tradeoff for locating a supplied word depends on construction and auxiliary data. Third, deterministic grammars and proof checkers motivate exact enumeration of accepted texts through generating functions and growth rates. Fourth, adversarial corruption introduces coding-theoretic redundancy into the distributed threshold. Finally, description languages can be compared through typical-case incompressibility and invariance bounds rather than mere existence of an undescribed function.

## 12. Conclusion

A universal fixed-length library is finite, exact, and mathematically tractable. Its $q^n$ books have uniform singleton probability $q^{-n}$ and admit a canonical numerical index. Any explicit checker succeeds with probability equal to its accepted count divided by $q^n$. Yet a complete address table belongs to a space of size $(q^n)^{q^n}$, so no one volume can encode all such tables, and a distributed worst-case representation needs at least $q^n$ volume-sized blocks. This threshold is attained by direct tabulation. Compact overlapping enumeration remains possible because it solves a different problem.

The governing principle is simple: universality of content does not supply universality of access. Meaningful compression and efficient search must come from structure in the objects, the acceptance rule, or the queries. In a space containing every possible text, the scarce resource is not existence but guidance.
