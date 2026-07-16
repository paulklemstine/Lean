# Universal Finite Libraries: Enumeration, Acceptance Probabilities, Catalog Limits, and Distributed Storage

**Aristotle**  
**July 16, 2026**

## Abstract

A universal finite library consists of every word of a fixed length $n$ over an alphabet of size $q$. This elementary model separates four notions that are often conflated in discussions of universal information spaces: existence, addressability, recognizability, and storage. We prove that the library has exactly $q^n$ books and construct a canonical bijection between books and the addresses $0,\ldots,q^n-1$ using base-$q$ expansion. Consequently, a uniformly sampled complete text has probability exactly $q^{-n}$. More generally, for any Boolean acceptance rule, the acceptance probability is the number of accepted books divided by $q^n$, and an accepted witness guarantees positive probability. We then count all book-valued tables on the library: there are $(q^n)^{q^n}$, so when at least two books exist, no single book can injectively encode every possible table. This does not preclude concise descriptions of particular structured catalogs, including the canonical address map. Finally, we prove an exact distributed-storage criterion: $T$ distinct records fit into $N$ books of capacity $c$ records each if and only if $T\le Nc$. The alphabet-four, length-sixteen library is treated explicitly; it contains $4^{16}=4{,}294{,}967{,}296$ books. Algorithms and numerical experiments demonstrate encoding, decoding, finite acceptance counting, and distributed placement. We close by distinguishing base-$q$ enumeration from the stronger, still separate construction of de Bruijn cycles.

## 1. Introduction

The Library of Babel can be made mathematically precise without invoking an infinite collection. Fix a finite alphabet and a fixed book length, and include every possible word of that length. The resulting universe is finite, but its size grows exponentially with the number of positions. Its finiteness permits exact counting; its scale makes naive search effectively useless.

This model is relevant well beyond literary combinatorics. Password spaces, bounded program spaces, exhaustive test suites, finite language models, archival identifiers, and brute-force searches all share the same structure. A candidate is a word; an address is a numeral; a recognizer selects a subset; and a storage system assigns selected objects to bounded containers.

Several claims require careful separation. First, one particular structured catalog can have a short algorithmic description. Second, the collection of all arbitrary tables on the library is vastly larger than the library itself. There is no contradiction: describing one regular function is different from encoding every function. Likewise, the statement that every finite text exists does not imply that a meaningful text is likely under random sampling.

The contributions are as follows.

1. We define length-$n$ libraries over $q$ symbols and derive their exact cardinality.
2. We give mutually inverse base-$q$ encoding and decoding algorithms, establishing a canonical catalog.
3. We derive exact uniform probabilities for fixed texts and arbitrary finite Boolean acceptance rules.
4. We prove a counting obstruction to encoding all complete book-valued tables in single books.
5. We establish a necessary-and-sufficient distributed-capacity theorem, together with an explicit placement algorithm.
6. We specialize the construction to $q=4$ and $n=16$ and discuss what would additionally be required for a de Bruijn catalog.

Throughout, $q$ and $n$ are nonnegative integers unless additional restrictions are stated. For addressing by conventional positional notation we assume $q\ge 2$.

## 2. Finite universal libraries

### 2.1 Definitions

**Definition 2.1 (Alphabet).** An alphabet of size $q$ is the set

$$
\Sigma_q=\{0,1,\ldots,q-1\}.
$$

The numerical labels carry no semantic content; they merely choose a convenient representation.

**Definition 2.2 (Book and library).** A length-$n$ book over $\Sigma_q$ is a tuple

$$
b=(b_0,b_1,\ldots,b_{n-1}),\qquad b_i\in\Sigma_q.
$$

The universal finite library is the set

$$
\mathcal L(q,n)=\Sigma_q^n
$$

of all such books.

The definition includes edge cases. If $n=0$, there is one empty book. If $q=0$ and $n>0$, there are no books. Most applications concern $q\ge2$ and $n\ge1$.

### 2.2 Exact enumeration

**Theorem 2.3 (Library Cardinality Theorem).** For all finite $q$ and $n$,

$$
|\mathcal L(q,n)|=q^n.
$$

**Proof sketch.** Each of the $n$ positions can be filled independently in $q$ ways. The product rule gives $q\cdot q\cdots q=q^n$. Equivalently, induction on $n$ starts with one empty word and observes that appending one symbol multiplies the count by $q$. $\square$

For the classical numerical parameters $q=25$ and $n=1{,}312{,}000$, this yields $25^{1{,}312{,}000}$ books. Since

$$
\log_{10}(25^{1{,}312{,}000})
=1{,}312{,}000\log_{10}25,
$$

the count has $\lfloor1{,}312{,}000\log_{10}25\rfloor+1$ decimal digits, approximately $1.83$ million.

## 3. A canonical base-$q$ catalog

### 3.1 Address map

**Definition 3.1 (Canonical address).** Assume $q\ge2$. For $b\in\mathcal L(q,n)$, define

$$
\operatorname{addr}(b)=\sum_{i=0}^{n-1}b_iq^{n-1-i}.
$$

This treats the symbols as the digits of an $n$-digit base-$q$ numeral, allowing leading zeros.

**Lemma 3.2 (Address range).** Every book satisfies

$$
0\le \operatorname{addr}(b)<q^n.
$$

**Proof sketch.** Nonnegativity is immediate. Since $b_i\le q-1$,

$$
\operatorname{addr}(b)
\le(q-1)\sum_{j=0}^{n-1}q^j
=(q-1)\frac{q^n-1}{q-1}
=q^n-1.
$$

Thus the address lies in the required half-open interval. $\square$

### 3.2 Decoding

**Algorithm 3.3 (Fixed-length base-$q$ decoding).** Given $a$ with $0\le a<q^n$, set $x=a$. For positions $i=n-1,n-2,\ldots,0$, let $b_i$ be the remainder of $x$ on division by $q$, and replace $x$ by $\lfloor x/q\rfloor$. Return $(b_0,\ldots,b_{n-1})$.

Each remainder belongs to $\Sigma_q$. The bound $a<q^n$ ensures that after $n$ divisions the quotient is zero.

**Lemma 3.4 (Decoding inverts encoding).** If $b\in\mathcal L(q,n)$, decoding $\operatorname{addr}(b)$ returns $b$.

**Proof sketch.** Reduction modulo $q$ extracts the final digit $b_{n-1}$ because all other terms are multiples of $q$. Subtracting that remainder and dividing by $q$ shifts the remaining numeral one place. Repeating extracts all digits from right to left. $\square$

**Lemma 3.5 (Encoding inverts decoding).** If $0\le a<q^n$, encoding the fixed-length decoded form of $a$ returns $a$.

**Proof sketch.** At every division step, Euclidean division gives $x=q\lfloor x/q\rfloor+(x\bmod q)$. Repeated substitution reconstructs $a$ as the positional sum of the extracted remainders. $\square$

**Theorem 3.6 (Canonical Address Theorem).** For $q\ge2$, the address map is a bijection

$$
\mathcal L(q,n)\longleftrightarrow\{0,1,\ldots,q^n-1\}.
$$

**Proof sketch.** Lemmas 3.4 and 3.5 provide a two-sided inverse, which proves both injectivity and surjectivity. $\square$

The theorem supplies a complete catalog without materializing a table of $q^n$ rows. Encoding uses $n$ multiply-add steps, and decoding uses $n$ quotient-remainder steps. In a unit-cost arithmetic model the running time is $O(n)$; bit complexity also depends on the cost of operations on numbers containing up to $n\log_2q$ bits. Storage is $O(n)$ symbols for the returned book and $O(1)$ auxiliary big integers beyond the output.

### 3.3 The four-symbol, length-sixteen library

**Corollary 3.7 (Mini-library Enumeration).** The library $\mathcal L(4,16)$ contains exactly

$$
4^{16}=2^{32}=4{,}294{,}967{,}296
$$

books, and the canonical address map bijects it with the unsigned $32$-bit integers from $0$ through $4{,}294{,}967{,}295$.

**Proof sketch.** Substitute $q=4$ and $n=16$ into Theorems 2.3 and 3.6, and use $4^{16}=(2^2)^{16}=2^{32}$. $\square$

This is a convenient experimental scale: individual addresses and books are easy to manipulate, even though exhaustive traversal of all books remains substantial.

## 4. Uniform probability and finite recognizers

### 4.1 Fixed texts

Equip $\mathcal L(q,n)$ with the uniform distribution, assigning equal probability to every book.

**Theorem 4.1 (Uniform Text Theorem).** For every fixed $t\in\mathcal L(q,n)$ with $q^n>0$,

$$
\Pr(B=t)=\frac{1}{q^n},
$$

where $B$ is uniformly sampled from the library.

**Proof sketch.** A singleton event contains one outcome among $q^n$ equally likely outcomes. $\square$

### 4.2 Arbitrary acceptance rules

**Definition 4.2 (Finite Boolean checker).** A checker is a function

$$
C:\mathcal L(q,n)\to\{0,1\}.
$$

The accepted set and accepted count are

$$
A_C=\{b\in\mathcal L(q,n):C(b)=1\},
\qquad M_C=|A_C|.
$$

The word “checker” is intentionally general. It may test a substring property, syntax, a checksum, a bounded computation, or any other deterministic yes-or-no condition.

**Theorem 4.3 (Exact Acceptance Probability).** Under uniform sampling,

$$
\Pr(C(B)=1)=\frac{M_C}{q^n}.
$$

**Proof sketch.** The acceptance event is exactly $A_C$. Uniform probability on a finite set assigns probability $|A_C|/|\mathcal L(q,n)|$, and Theorem 2.3 supplies the denominator. $\square$

**Corollary 4.4 (Witness Positivity).** If there exists a book $w$ such that $C(w)=1$, then $M_C\ge1$ and

$$
\Pr(C(B)=1)>0.
$$

**Proof sketch.** The witness belongs to $A_C$, so that set is nonempty. $\square$

The exact probability that a random volume represents a valid proof under a particular proof language is therefore not determined by $q$ and $n$ alone. One must fix the symbol encoding, target proposition, parser, background library, admissible inference rules, resource bounds, and checker version. Once those choices define a finite Boolean checker, Theorem 4.3 gives the exact answer. Computing $M_C$ by exhaustive search requires $q^n$ checker evaluations in the worst case, which is infeasible at the full scale but exact for small instances.

### 4.3 Fixed patterns and the common heuristic

Suppose a target pattern $p$ has length $k\le n$. At any one prescribed starting position, exactly $q^{n-k}$ books contain $p$ there, because the other $n-k$ symbols are free. Therefore the matching probability at that position is $q^{-k}$.

There are $r=n-k+1$ ordinary, noncyclic starting positions. Let $X$ count occurrences of $p$. By linearity of expectation,

$$
\mathbb E[X]=rq^{-k}.
$$

Moreover, the union bound gives

$$
\Pr(X\ge1)\le rq^{-k}.
$$

Thus “number of locations times $q^{-k}$” is an exact expected count and an upper bound for occurrence probability. It is only an approximation to that probability when overlaps are sufficiently negligible. For self-overlapping patterns, the location events are dependent and must not simply be added as though disjoint.

## 5. Counting all catalog tables

A word such as “catalog” can denote either a specific rule or arbitrary tabular data. The distinction is crucial.

Let $L=|\mathcal L(q,n)|=q^n$.

**Definition 5.1 (Complete book-valued table).** A complete table is any function

$$
f:\mathcal L(q,n)\to\mathcal L(q,n).
$$

Such a table chooses one book-valued entry independently for each input book.

**Theorem 5.2 (Table Count).** The number of complete book-valued tables is

$$
L^L=(q^n)^{q^n}.
$$

**Proof sketch.** There are $L$ choices for the value at each of $L$ inputs. The product rule gives $L$ multiplied by itself $L$ times. $\square$

**Theorem 5.3 (Single-Book Universal Table Impossibility).** If $L\ge2$, no injective encoding can assign every complete book-valued table to a single book.

**Proof sketch.** The domain of any proposed encoding has $L^L$ elements, while the codomain has $L$ elements. For $L\ge2$, one has $L^L\ge L^2>L$. The pigeonhole principle therefore forces at least two tables to share an encoded book. $\square$

The theorem is not a claim that no catalog can fit in one volume as an algorithmic description. The canonical address map of Section 3 is a particular structured catalog with a short definition. Rather, the theorem says that one cannot uniquely encode *every possible* table as one member of the original library. Arbitrary data and structured procedures have different descriptional behavior.

A bit-counting version reaches the same conclusion. Distinguishing all $L^L$ tables requires at least

$$
\log_2(L^L)=L\log_2L
$$

bits in any fixed-length injective representation, while distinguishing the $L$ books themselves requires only $\log_2L$ bits. The ratio is $L$. This information comparison is exact when interpreted as a lower bound on the number of binary codewords needed; it should not be confused with the symbol capacity of a particular physical volume unless an encoding has been specified.

## 6. Distributed storage

### 6.1 Exact criterion

Suppose $T$ distinct records must be placed into $N$ books, each with $c$ distinguishable record slots. A placement must assign different records to different slots.

**Theorem 6.1 (Distributed Capacity Theorem).** Such a placement exists if and only if

$$
T\le Nc.
$$

**Proof sketch.** For necessity, there are only $Nc$ book-slot pairs, so an injective assignment of $T$ records requires $T\le Nc$ by the pigeonhole principle. For sufficiency, number records $i=0,\ldots,T-1$. If $c>0$, assign record $i$ to

$$
\left(\left\lfloor\frac{i}{c}\right\rfloor,	hinspace i\bmod c\right).
$$

The first coordinate is the book and the second is its slot. Euclidean division makes this assignment injective, and $i<T\le Nc$ implies $\lfloor i/c\rfloor<N$. If $c=0$, the inequality forces $T=0$, for which the empty placement suffices. $\square$

**Corollary 6.2 (Minimum Number of Books).** For $c>0$, the least number of capacity-$c$ books capable of storing $T$ records is

$$
N_{\min}=\left\lceil\frac{T}{c}\right\rceil.
$$

**Proof sketch.** The least integer $N$ satisfying $T\le Nc$ is the ceiling of $T/c$. $\square$

### 6.2 Algorithmic form

The constructive half of Theorem 6.1 gives an online placement rule. Processing records in increasing order, quotient and remainder identify a unique location. The algorithm runs in $O(T)$ arithmetic operations to materialize all placements and uses $O(T)$ output space; each location can instead be computed on demand in $O(1)$ arithmetic operations.

This theorem is a precise model of sharding. It assumes fixed-size records and fixed slot capacity. Variable-length compression, replication, failures, and update locality require richer models, but the basic capacity inequality remains a necessary foundation.

## 7. Algorithms and numerical demonstrations

### 7.1 Canonical encoding and decoding

Horner’s rule evaluates the address without explicitly computing every power:

$$
x_0=0,\qquad x_{i+1}=qx_i+b_i.
$$

After processing all digits, $x_n=\operatorname{addr}(b)$. The reverse algorithm repeatedly applies quotient and remainder. Assertions that decoding follows encoding and vice versa provide direct finite tests of the bijection.

### 7.2 Exact acceptance counting on small libraries

For manageable $q^n$, enumerate addresses $0$ through $q^n-1$, decode each address, evaluate $C$, and count acceptances. The result divided by $q^n$ is Theorem 4.3’s exact probability. The running time is $O(q^n(n+\tau_C))$, where $\tau_C$ is the checker cost, and the traversal can use $O(n)$ working space if books are processed one at a time.

As an example, on binary words of length eight, a checker accepting words with exactly four ones has

$$
M_C=\binom84=70,
\qquad
\Pr(C(B)=1)=\frac{70}{256}.
$$

Exhaustive enumeration reproduces this value.

### 7.3 Distributed placement

For $T=23$ records and capacity $c=5$, the minimum number of books is

$$
\left\lceil\frac{23}{5}\right\rceil=5.
$$

Records $0$ through $4$ occupy book $0$, records $5$ through $9$ occupy book $1$, and so forth; records $20$ through $22$ use the first three slots of book $4$.

## 8. De Bruijn cycles and what remains distinct

**Definition 8.1 (de Bruijn cycle).** A de Bruijn cycle of order $n$ over $\Sigma_q$ is a cyclic word of length $q^n$ in which every member of $\mathcal L(q,n)$ occurs exactly once as a cyclic window of length $n$.

A de Bruijn cycle is not the same artifact as the base-$q$ catalog. The latter assigns a numerical address independently to each word. The former orders all words through maximal overlaps, so consecutive windows share $n-1$ symbols.

For $q=4$ and $n=16$, a de Bruijn cycle would have cyclic length $4^{16}$. A standard construction proceeds through a directed graph whose vertices are words of length $15$. Each word of length $16$ is an edge from its first $15$ symbols to its last $15$ symbols. Every vertex has indegree and outdegree $4$. After proving the relevant connectivity, an Eulerian circuit uses every edge once; reading edge labels produces the desired cycle.

This construction is a natural continuation, but it is not needed for any theorem above and should not be inferred from the existence of the arithmetic enumeration. Establishing it rigorously requires explicit cyclic-window definitions, graph balance and connectivity arguments, an Eulerian-circuit theorem, and a proof of unique window occurrence.

## 9. Applications

### 9.1 Exhaustive testing

A bounded input format with $q$ symbols and length $n$ has exactly $q^n$ test cases. Canonical addresses support deterministic partitioning across workers: assign disjoint address intervals, decode locally, and test each candidate. The acceptance-count formula then turns exhaustive results into exact finite probabilities.

### 9.2 Search and security

Key spaces and password spaces are universal finite libraries. Uniform guessing succeeds against one fixed secret with probability $q^{-n}$ per independent attempt. If a policy accepts $M$ secrets, the accepted fraction is $M/q^n$. The formulas do not model nonuniform human choices, but they provide the baseline from which entropy loss is measured.

### 9.3 Content-addressable archives

The canonical map is reversible positional addressing, not hashing: it has no collisions and offers no compression. It is useful when every object has the same fixed format. The table impossibility theorem warns that arbitrary metadata for every object generally requires much more information than one object-sized carrier.

### 9.4 Distributed databases

The capacity theorem abstracts fixed-size sharding. Quotient chooses a shard and remainder chooses a local slot. The method is balanced up to one record and gives immediate capacity planning through $\lceil T/c\rceil$.

## 10. Discussion

The model yields exact results because all relevant spaces are finite. It also reveals three recurring conceptual boundaries.

First, **existence is not discoverability**. The universal library contains every fixed-length target, but random discovery of a specified target has probability $q^{-n}$. A recognizer helps define success but may itself be computationally expensive.

Second, **a structured map is not an arbitrary table**. The canonical catalog is concise because positional notation supplies regularity. Counting all tables removes that regularity and produces $L^L$ possibilities, too many for injective single-book representation.

Third, **symbol count is not semantics**. Exact acceptance probabilities depend on a fully specified finite checker. Phrases such as “valid proof” or “meaningful book” do not determine a subset until their syntax and decision procedure are fixed.

The results are elementary in technique—product counting, Euclidean division, uniform finite probability, and the pigeonhole principle—but their combination gives a disciplined account of a universal information space. It replaces vague immensity with exact cardinalities and separates what can be enumerated, what can be recognized, and what can be stored.

## 11. Future work

The most direct extension is a complete de Bruijn development: define cyclic words and windows, construct the order-$(n-1)$ directed graph, prove balanced degree and connectivity, obtain an Eulerian circuit, and extract a cycle whose length-$n$ windows are unique. The specialization $q=4$, $n=16$ would then complement the arithmetic mini-catalog with an overlap-optimal cyclic traversal.

A second direction is to instantiate the checker model with a concrete finite tokenization and a bounded proof-like language. Such a model must specify encoding, target statement, parser, inference environment, and resource limits. Exact acceptance probability would still be $M_C/q^n$, while computational work would focus on calculating or bounding $M_C$.

Further work may consider nonuniform distributions, automata-based pattern counting, variable-length books, compression, replicated distributed storage, erasure tolerance, and complexity-sensitive notions of catalog description. These refinements would preserve the finite combinatorial foundation while bringing the model closer to realistic information systems.

## 12. Conclusion

A finite universal library over $q$ symbols and length $n$ contains exactly $q^n$ books. Base-$q$ numeration gives every book a unique address and retrieves every address uniquely. Uniform sampling assigns probability $q^{-n}$ to a specified book and $M_C/q^n$ to any checker accepting $M_C$ books. There are $(q^n)^{q^n}$ complete book-valued tables, which prevents all such tables from being injectively represented by single books whenever at least two books exist. Distributed storage, by contrast, has the exact and constructive criterion $T\le Nc$.

Together these results provide a compact mathematics of universal finite information: complete in content, canonical in address, measurable under recognition, limited in arbitrary self-description, and expandable through distribution.