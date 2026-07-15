# Factorial Coordinates for Finite Permutations

## A canonical classification by bounded mixed-radix codes

**Author:** Aristotle  
**Date:** 15 July 2026

## Abstract

For each natural number $k$, consider the factorial-code space consisting of digit vectors $c=(c_0,\ldots,c_{k-1})$ satisfying $0\le c_i<i+1$. The factoradic value of such a vector is

$$
V_k(c)=\sum_{i=0}^{k-1}c_i i!.
$$

We establish a complete classification of these codes, numerical ranks, and permutations of $k$ elements. First, factorial evaluation always lies in the interval $0\le V_k(c)<k!$ and is injective. Since the code space has cardinality $k!$, evaluation is therefore a bijection onto the integers $0,\ldots,k!-1$. Second, a recursive quotient-remainder decomposition gives a bijection between this rank interval and permutations: at the successor step, one chooses one of $k+1$ positions for a distinguished element and recursively permutes the remaining $k$ elements. Composing the two maps yields a canonical correspondence between factorial codes and finite permutations, with rank exactly equal to factoradic value. We derive unique representation, equality criteria, and the factorial enumeration of permutations. We also present executable ranking and unranking algorithms, analyze their complexity, and discuss applications to exhaustive search, random generation, compact indexing, and inversion statistics.

## 1. Introduction

The equality between the number of permutations of $k$ objects and the factorial $k!$ is elementary. A more structural question asks whether every permutation can be assigned a canonical integer address below $k!$, with an arithmetic representation that reflects the recursive choices used to build the permutation.

The factorial number system supplies precisely such coordinates. Unlike a fixed-base positional system, it uses place values

$$
0!,1!,2!,\ldots,(k-1)!
$$

and allows the digit at place $i$ to range from $0$ through $i$. The number of legal length-$k$ digit vectors is therefore

$$
\prod_{i=0}^{k-1}(i+1)=k!.
$$

This numerical match suggests a relation with permutations, but cardinality alone gives only an unspecified bijection. The central aim of this paper is to exhibit a correspondence whose arithmetic and combinatorial recursions agree.

The development has three layers. The first is arithmetic: bounded factorial digits represent exactly the integers below $k!$. The second is combinatorial: ranks below $k!$ recursively classify permutations of $k$ elements. The third identifies the layers: the rank assigned to a code is its weighted factorial value. This yields a canonical factorial-code classification and several useful consequences.

Throughout, $\mathbb N=\{0,1,2,\ldots\}$, $[k]=\{0,1,\ldots,k-1\}$, and $S_k$ denotes the set of bijections from $[k]$ to itself. We take $0!=1$ and $(k+1)!=(k+1)k!$.

## 2. Factorial codes and their values

### Definition 2.1 (factorial-code space)

For $k\in\mathbb N$, the factorial-code space of length $k$ is

$$
\mathcal C_k=\prod_{i=0}^{k-1}\{0,1,\ldots,i\}.
$$

Thus an element $c\in\mathcal C_k$ is a vector $c=(c_0,\ldots,c_{k-1})$ satisfying

$$
0\le c_i<i+1
$$

for every $i\in[k]$. When $k=0$, the empty product contains the unique empty code.

### Definition 2.2 (factoradic evaluation)

For $c\in\mathcal C_k$, define

$$
V_k(c)=\sum_{i=0}^{k-1}c_i i!.
$$

The code is written in ascending place order: $c_i$ multiplies $i!$. Since $c_0=0$, the formally present $0!$ digit carries no choice, but including it makes the recursive indexing uniform.

### Proposition 2.3 (recursive splitting)

If $c\in\mathcal C_{k+1}$ and $c^-=(c_0,\ldots,c_{k-1})\in\mathcal C_k$ is its lower part, then

$$
V_{k+1}(c)=c_k k!+V_k(c^-).
$$

#### Proof sketch

Split the defining sum into its terms with indices below $k$ and its final term at index $k$. The first part is $V_k(c^-)$ and the last is $c_k k!$.

### Theorem 2.4 (factoradic range)

For every $k\in\mathbb N$ and every $c\in\mathcal C_k$,

$$
0\le V_k(c)<k!.
$$

#### Proof sketch

Proceed by induction on $k$. The empty code has value $0<1=0!$. For a code of length $k+1$, Proposition 2.3 and the induction hypothesis give

$$
V_{k+1}(c)=c_k k!+V_k(c^-),
$$

where $0\le c_k\le k$ and $0\le V_k(c^-)<k!$. Hence

$$
V_{k+1}(c)
\le k\,k!+(k!-1)
=(k+1)k!-1
=(k+1)!-1.
$$

Nonnegativity is immediate from the sum.

The proof reveals a block decomposition. For fixed $c_k=q$, the represented values lie in the half-open interval

$$
[qk!,(q+1)k!),
$$

and the $k+1$ possible final digits partition the entire interval $[0,(k+1)!)$.

### Theorem 2.5 (uniqueness of bounded factorial expansion)

For every $k\in\mathbb N$ and $c,d\in\mathcal C_k$,

$$
V_k(c)=V_k(d)\quad\Longrightarrow\quad c=d.
$$

#### Proof sketch

Use induction on $k$. At length zero there is only the empty code. At length $k+1$, write

$$
V_{k+1}(c)=c_k k!+r,
\qquad
V_{k+1}(d)=d_k k!+s,
$$

where $r=V_k(c^-)$ and $s=V_k(d^-)$. The range theorem yields $0\le r,s<k!$. Therefore $c_k$ and $d_k$ are the quotients obtained by division by $k!$, while $r$ and $s$ are the corresponding remainders. Equality of values implies $c_k=d_k$ and $r=s$. The induction hypothesis gives $c^-=d^-$, so all digits agree.

Equivalently, the half-open blocks $[qk!,(q+1)k!)$ are disjoint, making the highest digit recoverable before recursion on the remainder.

### Proposition 2.6 (cardinality of the code space)

For every $k\in\mathbb N$,

$$
|\mathcal C_k|=k!.
$$

#### Proof sketch

Digit $c_i$ has $i+1$ possible values, independently of all other digits. Thus

$$
|\mathcal C_k|=\prod_{i=0}^{k-1}(i+1)=1\cdot2\cdots k=k!.
$$

The empty product gives $|\mathcal C_0|=1=0!$.

### Corollary 2.7 (complete numerical classification)

Factoradic evaluation is a bijection

$$
V_k:\mathcal C_k\longrightarrow\{0,1,\ldots,k!-1\}.
$$

#### Proof sketch

Theorem 2.4 places the image in the indicated rank set, and Theorem 2.5 proves injectivity. Proposition 2.6 shows that the domain and codomain both contain $k!$ elements. An injection between finite sets of equal cardinality is a bijection.

This corollary also gives existence of bounded factorial expansions: every integer $n$ with $0\le n<k!$ has a unique representation

$$
n=\sum_{i=0}^{k-1}c_i i!,
\qquad 0\le c_i<i+1.
$$

## 3. Recursive ranks for permutations

The arithmetic recursion

$$
[0,(k+1)!)\cong [0,k+1)\times[0,k!)
$$

has a direct combinatorial counterpart.

### Lemma 3.1 (distinguished-element decomposition)

A permutation of $[k+1]$ is uniquely determined by:

1. one position $q\in\{0,1,\ldots,k\}$ occupied by the distinguished element $k$; and
2. a permutation of the remaining ordered set $[k]$.

Consequently there is a bijection

$$
S_{k+1}\cong [k+1]\times S_k.
$$

#### Proof sketch

Given a permutation written as a sequence, record the position of $k$, remove $k$, and retain the order of the remaining symbols. Conversely, insert $k$ into the recorded position of the smaller permutation. Removal and insertion are inverse operations.

### Definition 3.2 (recursive permutation unranking)

Define maps

$$
U_k:\{0,1,\ldots,k!-1\}\longrightarrow S_k
$$

recursively. For $k=0$, map $0$ to the empty permutation. Given $n<(k+1)!$, use Euclidean division to write

$$
n=qk!+r,
$$

where $0\le q<k+1$ and $0\le r<k!$. Recursively form $U_k(r)$ and insert the distinguished element $k$ at position $q$.

### Definition 3.3 (recursive permutation ranking)

Define the inverse rank map

$$
R_k:S_k\longrightarrow\{0,1,\ldots,k!-1\}
$$

recursively. Set $R_0$ of the empty permutation equal to $0$. For $\sigma\in S_{k+1}$, remove $k$, let $q$ be its former position, and let $\tau\in S_k$ be the remaining permutation. Then set

$$
R_{k+1}(\sigma)=qk!+R_k(\tau).
$$

### Theorem 3.4 (recursive rank-unrank equivalence)

For every $k\in\mathbb N$, the maps $U_k$ and $R_k$ are mutually inverse bijections between the rank set $\{0,\ldots,k!-1\}$ and $S_k$.

#### Proof sketch

Induct on $k$. The base case is immediate. At the successor step, Euclidean quotient and remainder uniquely decompose a rank into an element of $[k+1]$ and a smaller rank. Lemma 3.1 uniquely decomposes a permutation into a distinguished position and a smaller permutation. By the induction hypothesis, the smaller rank and smaller permutation are in bijection. Since quotient-remainder decomposition and removal-insertion are each inverse pairs, their product and hence the recursive construction are inverse pairs.

This is stronger than the numerical identity $|S_k|=k!$: it specifies the bijection and its inverse.

## 4. The factorial-code classification

### Definition 4.1 (factorial-code permutation)

For $c\in\mathcal C_k$, define its classified permutation by

$$
\Phi_k(c)=U_k(V_k(c)).
$$

The range theorem ensures that $V_k(c)$ is a valid input to $U_k$.

### Theorem 4.2 (Factorial-Code Classification Theorem)

For every natural number $k$, the map

$$
\Phi_k:\mathcal C_k\longrightarrow S_k
$$

is a bijection. Moreover, its permutation rank is exactly its factoradic value:

$$
R_k(\Phi_k(c))=V_k(c)
$$

for every $c\in\mathcal C_k$.

#### Proof sketch

Corollary 2.7 says that $V_k$ is a bijection from codes to ranks. Theorem 3.4 says that $U_k$ is a bijection from ranks to permutations. Their composition $\Phi_k=U_k\circ V_k$ is therefore a bijection. Since $R_k$ is inverse to $U_k$,

$$
R_k(\Phi_k(c))
=R_k(U_k(V_k(c)))
=V_k(c).
$$

This identity is the compatibility statement at the center of the classification. The numerical coordinate is not appended after the combinatorial construction; it is preserved by it.

### Corollary 4.3 (unique code for every permutation)

For every $k\in\mathbb N$ and every $\sigma\in S_k$, there exists a unique code $c\in\mathcal C_k$ such that

$$
\Phi_k(c)=\sigma.
$$

#### Proof sketch

Existence follows from surjectivity of $\Phi_k$, and uniqueness follows from injectivity.

### Corollary 4.4 (digitwise equality criterion)

For all $c,d\in\mathcal C_k$,

$$
\Phi_k(c)=\Phi_k(d)
\quad\Longleftrightarrow\quad
c=d.
$$

#### Proof sketch

The forward implication is injectivity of $\Phi_k$. The reverse implication follows because every function preserves equality.

### Corollary 4.5 (numerical equality criterion)

For all $c,d\in\mathcal C_k$,

$$
\Phi_k(c)=\Phi_k(d)
\quad\Longleftrightarrow\quad
V_k(c)=V_k(d).
$$

#### Proof sketch

If the permutations agree, Corollary 4.4 gives $c=d$, so their values agree. Conversely, equal values imply equal codes by Theorem 2.5, and hence equal classified permutations.

### Corollary 4.6 (factorial enumeration of permutations)

For every $k\in\mathbb N$,

$$
|S_k|=k!.
$$

#### Proof sketch

Theorem 4.2 gives a bijection between $S_k$ and $\mathcal C_k$, and Proposition 2.6 gives $|\mathcal C_k|=k!$.

### Example 4.7 (small cardinalities)

For $k=0,1,2,3,4,5$, the common cardinalities of the code space, rank interval, and permutation space are respectively

$$
1,1,2,6,24,120.
$$

The case $k=0$ is substantive for recursion: there is one empty code and one empty permutation, corresponding to the sole rank $0$ below $0!=1$.

## 5. Executable algorithms

The existence proof in Corollary 2.7 can be realized by repeated division. For practical permutation handling, it is convenient to use the conventional selection form of Lehmer unranking. It is equivalent to a recursive distinguished-element convention after fixing the orientation of digits and positions.

### Algorithm 5.1 (factoradic digit extraction)

Given $n$ with $0\le n<k!$, compute digits in ascending order by repeatedly setting

$$
c_i=n\bmod(i+1),
\qquad
n\leftarrow\left\lfloor\frac{n}{i+1}\right\rfloor
$$

for $i=0,1,\ldots,k-1$.

#### Correctness sketch

At stage $i$, division by $i+1$ produces a remainder in $\{0,\ldots,i\}$, so every digit satisfies its bound. Reversing the recurrence shows that the original integer equals $\sum_i c_i i!$. The uniqueness theorem ensures that these are the only valid digits.

The algorithm performs $k$ quotient-remainder operations. Under a unit-cost arithmetic model it takes $O(k)$ time and $O(k)$ output space. Bit complexity depends on the cost of division for integers of up to $\Theta(k\log k)$ bits.

### Algorithm 5.2 (selection-based permutation unranking)

Start with the ordered pool

$$
L=[0,1,\ldots,k-1].
$$

For $i=k-1,k-2,\ldots,0$, select and remove the item at index $c_i$ from $L$, appending it to the output permutation.

#### Correctness sketch

Before the step indexed by $i$, the pool has $i+1$ elements, and the digit bound $0\le c_i<i+1$ makes the selection valid. Each sequence of selections yields a permutation because every symbol is removed exactly once. Conversely, a permutation determines each selection index uniquely by locating its next symbol in the remaining sorted pool. Thus selection is bijective.

With an array or list, indexed deletion costs $O(k)$ in the worst case, giving $O(k^2)$ total time and $O(k)$ space. An order-statistics tree reduces selection and deletion to $O(\log k)$ each, yielding $O(k\log k)$ time.

### Algorithm 5.3 (selection-based permutation ranking)

Given a permutation $p=(p_0,\ldots,p_{k-1})$, initialize the same ordered pool $L$. At step $j$, find the index $a_j$ of $p_j$ in $L$, remove that item, and add

$$
a_j(k-1-j)!
$$

to the rank.

#### Correctness sketch

At each step, the index records exactly which available item the unranking procedure would select. Therefore the resulting descending digit sequence is inverse to Algorithm 5.2. The weighted sum reconstructs the unique rank. A list implementation is $O(k^2)$; an order-statistics tree supports $O(k\log k)$ ranking.

### Example 5.4

Let $k=4$ and $n=17$. Factorial digit extraction gives ascending digits

$$
(c_0,c_1,c_2,c_3)=(0,1,2,2),
$$

and indeed

$$
17=0\cdot0!+1\cdot1!+2\cdot2!+2\cdot3!.
$$

Selection from $[0,1,2,3]$ using descending digits $(2,2,1,0)$ gives

$$
[2,3,1,0].
$$

Ranking this permutation finds the same successive indices and returns $17$. Exhausting all ranks from $0$ through $23$ produces all $24$ permutations exactly once.

## 6. Applications

### 6.1 Compact indexing and storage

A permutation can be represented by one integer in $[0,k!)$. This is information-theoretically natural: distinguishing $k!$ possibilities requires approximately

$$
\log_2(k!)
$$

bits. The factorial representation additionally exposes the recursive structure of that integer. It is useful for database keys, canonical serialization, and reproducible identifiers for arrangements.

### 6.2 Exhaustive and parallel search

Algorithms that inspect all permutations often need to divide work without overlap. Ranks provide a linear interval that can be partitioned among processors. The highest factorial digit divides the space into $k$ blocks of $(k-1)!$ permutations, and subsequent digits refine each block recursively. Unique representation guarantees both coverage and disjointness.

### 6.3 Uniform random generation

Sampling an integer uniformly from $\{0,\ldots,k!-1\}$ and unranking it produces a uniform random permutation, because unranking is a bijection. Equivalently, one may independently sample each digit $c_i$ uniformly from $\{0,\ldots,i\}$ and apply the classification. Every code then has probability

$$
\prod_{i=0}^{k-1}\frac{1}{i+1}=\frac{1}{k!},
$$

so every permutation has the same probability.

### 6.4 Inversion statistics

In the conventional Lehmer interpretation, each selection digit counts the number of currently available smaller elements skipped before choosing the next element. Consequently the digits refine the inversion structure of a permutation. This supplies a path from the present classification to formulas for inversion count and permutation sign. Establishing the exact semantic identification requires fixing the chosen recursive orientation, but the bounded digits and unique rank already provide the required coordinate space.

### 6.5 Neighboring ranks and carry propagation

Incrementing a rank by one changes its factorial digits according to mixed-radix carrying. A digit $c_i$ carries when it advances beyond $i$. Under unranking, that arithmetic event induces a structured transformation of the permutation. Characterizing this transformation can lead to permutation-generation orders that update arrangements locally rather than unranking each rank from scratch.

### 6.6 Canonical testing and reproducibility

The rank coordinate supplies a simple protocol for testing software that manipulates permutations. For a fixed $k$, one may iterate through every integer $n$ in the interval $0\le n<k!$, unrank $n$ to a permutation, rank the result, and require recovery of $n$. In the opposite direction, one may enumerate permutations, rank each one, and verify that the resulting set of integers is exactly

$$
\{0,1,\ldots,k!-1\}.
$$

These two round trips test complementary properties. The identity

$$
R_k(U_k(n))=n
$$

tests that no rank is lost or altered, while

$$
U_k(R_k(\sigma))=\sigma
$$

tests that no permutation is confused with another. The classification theorem guarantees both identities for every size, while finite experiments provide useful checks of an implementation's indexing conventions.

The coordinate system is also reproducible across applications. A rank is meaningful only after one fixes the ground-set order and the orientation used for insertion or selection. Once those conventions are declared, the integer is a complete portable description. This distinction matters: two valid recursive conventions can enumerate the same permutation set in different orders. The theorem does not claim that every convention gives the same visible permutation at rank $n$; it claims that the specified arithmetic and combinatorial recursions form mutually inverse maps, and that every code receives exactly its factoradic rank within that fixed system.

### 6.7 Information content and mixed-radix optimality

A factorial code uses one digit with $i+1$ possible values at each place $i$. Its total information capacity is therefore

$$
\sum_{i=0}^{k-1}\log_2(i+1)=\log_2(k!).
$$

This exactly matches the information needed to distinguish $k!$ permutations. There are no unused legal codewords and no collisions. In this sense the mixed-radix representation is combinatorially optimal: its Cartesian product of digit ranges has precisely the target size.

This does not imply that a naive in-memory digit array is the most compact binary encoding, because machine words may waste capacity on small radices. Rather, the statement concerns abstract information content. The single rank can be stored in a binary integer using $\lceil\log_2(k!)\rceil$ bits, while the factorial digits expose the decision structure needed for ranking and unranking. Applications may move between these two views according to whether compact storage or local combinatorial access is more important.

## 7. Discussion

The classification rests on a precise parallel:

$$
(k+1)!=(k+1)k!.
$$

Arithmetically, a number below $(k+1)!$ consists of a quotient below $k+1$ and a remainder below $k!$. Combinatorially, a permutation of $k+1$ objects consists of the position of one distinguished object and a permutation of the other $k$. Factorial digits iterate the arithmetic decomposition; recursive insertion iterates the combinatorial one.

This perspective separates three claims that are sometimes conflated. First, there are $k!$ legal codes. Second, their weighted values are distinct and fill the rank interval. Third, ranks canonically determine permutations. Proving each layer yields more than the familiar counting formula: it yields an equality-preserving coordinate system with explicit inverse procedures.

The word “Lehmer” often refers specifically to inversion-vector digits attached to a one-line permutation. The classification here is stated at the structural level: factorial evaluation followed by a fixed recursive rank-unrank bijection. A selection implementation realizes the conventional semantics after an orientation convention is chosen. Making that identification explicit is a natural next refinement, particularly for parity and inversion-count results.

## 8. Future directions

Several extensions follow directly from the present structure.

1. **Computable ranking and unranking.** One may develop a decoder based entirely on repeated division by factorial radices and prove that it agrees extensionally with the abstract finite classification.

2. **Concrete inversion-vector semantics.** Each digit can be related to the number of smaller entries preceding or following the corresponding symbol. This would identify the recursive equivalence with the conventional Lehmer code under a precise orientation.

3. **Order and parity.** Factoradic rank gives a total enumeration of permutations. A further goal is the sign formula

$$
\operatorname{sgn}(\sigma)=(-1)^{\sum_i c_i}.
$$

4. **Adjacent ranks.** Incrementing a factorial rank triggers mixed-radix carry propagation. Describing its exact effect on the classified permutation may produce efficient generation schemes.

5. **Arbitrary finite ordered types.** The classification can be transported from $[k]$ to any finite linearly ordered set of cardinality $k$, with naturality under order-preserving equivalences.

6. **Algorithmic complexity.** Implementations using order-statistics data structures should support rank and unrank in $O(k\log k)$ time. Precise bit-complexity and verified complexity bounds remain to be developed.

## 9. Conclusion

For every natural number $k$, bounded factorial digits, integers below $k!$, and permutations of $k$ elements form three equivalent descriptions of the same finite structure. Factorial evaluation maps a code into range and never identifies distinct codes. Cardinality then makes it a complete numerical classification. Recursive quotient-remainder decomposition matches recursive insertion of a distinguished element, producing a rank-unrank bijection for permutations. Their composition gives a canonical correspondence in which permutation rank is exactly

$$
\sum_{i=0}^{k-1}c_i i!.
$$

Every permutation consequently has one unique factorial code; equality may be checked digitwise or numerically; and the classical count $|S_k|=k!$ emerges from an explicit, reversible coordinate system. The result turns a collection of rearrangements into a structured number line and supplies a foundation for indexing, sampling, exhaustive search, and further study of inversions, parity, and adjacency.
