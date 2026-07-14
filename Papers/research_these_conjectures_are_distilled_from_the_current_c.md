# Canonical Digit Streams and Carry-Free Addition in Arbitrary Mixed-Radix Systems

**Aristotle**  
**July 14, 2026**

## Abstract

A mixed-radix numeral uses a base that may vary with position. Given nonnegative integer bases $(b_i)_{i\ge0}$, define the running products $P_0=1$ and $P_k=\prod_{j<k}b_j$. A length-$k$ digit string $c$ has value $V_k(c)=\sum_{i<k}c_iP_i$ and is valid when $c_i<b_i$ for every $i<k$. This paper develops the representation theory directly from Euclidean division, without regularity or global positivity assumptions on the base sequence. Valid representations are unique, every $n<P_k$ is represented by the digits $D_i(n)=\lfloor n/P_i\rfloor\bmod b_i$, and the factorial number system is recovered by $b_i=i+1$. The principal results are an unconditional reconstruction identity

$$
V_k(D(n))=n\bmod P_k,
$$

and a length-independence theorem

$$
D_i(n\bmod P_k)=D_i(n)\quad(i<k).
$$

Thus extraction defines a canonical infinite digit stream whose finite prefixes reconstruct the corresponding residues. We also separate the linearity of evaluation from the nonlinear process of carrying. Evaluation is always additive on pointwise coefficient sums, while addition is carry-free exactly under the local inequalities $c_i+d_i<b_i$ throughout the chosen block. The results apply uniformly to constant-base notation, factoradics, clocks, multidimensional array indexing, and nested cyclic counters, including a precise treatment of degenerate zero bases.

## 1. Introduction

Ordinary base-$q$ notation uses place values $1,q,q^2,\ldots$ and digits in $\{0,\ldots,q-1\}$. Its uniqueness and extraction algorithms are consequences of Euclidean division. Mixed-radix notation replaces the constant $q$ by a sequence $b_0,b_1,b_2,\ldots$, allowing each position to have its own capacity. The associated place values are not powers but running products.

Examples are widespread. Time notation combines seconds, minutes, hours, and days. A row-major array with varying axis lengths converts a linear offset into a tuple of coordinates. Nested loop counters have one local range per level. The factorial number system uses successive bases $1,2,3,\ldots$ and place values $i!$, providing a natural ranking of permutations. These examples are usually introduced independently, although the same arithmetic controls all of them.

This paper gives a unified finite theory and emphasizes two structural consequences. First, digit extraction is local: the digit at position $i$ depends only on the number modulo the next running product $P_{i+1}$. Since the running products form a divisibility chain, truncating at any later place cannot alter that digit. Hence an integer possesses a canonical infinite mixed-radix digit stream, independent of the length at which it is viewed. Second, evaluation is linear even though normalized digit arithmetic involves carries. The pointwise sum of two digit strings always evaluates to the sum of their values; carrying is needed only when that pointwise sum violates a local digit bound.

No assumption $b_i\ge2$, or even $b_i>0$, is imposed globally. This is useful conceptually: positivity needed in a valid block follows from validity itself. If a zero base occurs inside the block, there are no valid strings of that length. The representation theorems remain correct rather than requiring separately patched statements.

The paper proceeds from definitions to the finite capacity bound and Euclidean splitting identities, then establishes uniqueness, existence, reconstruction, stable truncation, carry-free addition, algorithms, and applications.

## 2. Mixed-radix preliminaries

### 2.1. Running products, values, and validity

Let $b:\mathbb N\to\mathbb N$ be any sequence. Define its **running products** by

$$
P_k=\prod_{j=0}^{k-1}b_j,
$$

with the empty product $P_0=1$. Equivalently,

$$
P_{k+1}=P_kb_k.
$$

The quantity $P_i$ is the place value at position $i$, and $P_k$ is the nominal capacity of the first $k$ positions.

A **digit function** is a sequence $c:\mathbb N\to\mathbb N$. Only its first $k$ entries matter for a length-$k$ numeral. Define its length-$k$ value by

$$
V_k(c)=\sum_{i=0}^{k-1}c_iP_i.
$$

The digit function is **valid through length $k$** if

$$
c_i<b_i\qquad\text{for every }i<k.
$$

The recursive value identity is immediate:

$$
V_{k+1}(c)=V_k(c)+c_kP_k.
$$

A digit at a position with base $0$ cannot be valid, since no natural number is less than $0$. Thus validity through position $k$ implies $b_i>0$ for every $i<k$, and hence $P_k>0$. Positivity need not be separately postulated.

### 2.2. Explicit digit extraction

For $n,i\in\mathbb N$, define the extracted digit

$$
D_i(n)=\left\lfloor\frac{n}{P_i}\right\rfloor\bmod b_i.
$$

Here quotient and remainder are the natural-number operations, with the standard conventions $n\bmod0=n$ and $n/0=0$. The formula first removes all positions below $i$ by division by $P_i$, then isolates the residue in the local base $b_i$.

The definition contains no length parameter. This apparently minor feature becomes the source of the canonical normal form in Section 5.

## 3. Finite representation theory

### 3.1. The capacity bound

**Lemma 3.1 (Capacity bound).** If $c$ is valid through length $k$, then

$$
V_k(c)<P_k.
$$

**Proof sketch.** The result is proved by induction on $k$. At $k=0$, $V_0(c)=0<P_0=1$. Suppose the claim holds at $k$. Validity gives $c_k<b_k$, and

$$
V_{k+1}(c)=V_k(c)+c_kP_k.
$$

Using $V_k(c)<P_k$ and $c_k\le b_k-1$ gives

$$
V_{k+1}(c)<P_k+(b_k-1)P_k=b_kP_k=P_{k+1}.
$$

The induction also shows that all factors needed in the inequalities are positive, because validity forces the relevant bases to be positive. $\square$

The bound captures the combinatorial meaning of $P_k$: a valid block occupies exactly the numerical interval below its capacity.

### 3.2. Euclidean splitting

**Lemma 3.2 (Top-digit splitting).** If $c$ is valid through length $k+1$, then

$$
\left\lfloor\frac{V_{k+1}(c)}{P_k}\right\rfloor=c_k
$$

and

$$
V_{k+1}(c)\bmod P_k=V_k(c).
$$

**Proof sketch.** Write

$$
V_{k+1}(c)=V_k(c)+c_kP_k.
$$

By Lemma 3.1, $0\le V_k(c)<P_k$. This is precisely the quotient-remainder decomposition of $V_{k+1}(c)$ upon division by $P_k$, with quotient $c_k$ and remainder $V_k(c)$. $\square$

The two identities are the engine of the general theory. The top digit is exposed by a quotient; the lower block is exposed by a remainder.

### 3.3. Uniqueness

**Theorem 3.3 (Universal uniqueness).** Let $c$ and $d$ be valid through length $k$. If

$$
V_k(c)=V_k(d),
$$

then

$$
c_i=d_i\qquad\text{for every }i<k.
$$

**Proof sketch.** Induct on $k$. The claim is empty for $k=0$. At length $k+1$, divide the common value by $P_k$. Lemma 3.2 gives $c_k=d_k$. Removing the equal top contributions from

$$
V_k(c)+c_kP_k=V_k(d)+d_kP_k
$$

shows $V_k(c)=V_k(d)$. The induction hypothesis then identifies every lower digit. $\square$

No regularity of the base sequence appears. In particular, the argument does not require the bases to increase, to be bounded, or to share a common value.

### 3.4. Existence and exact counting

**Theorem 3.4 (Extraction and finite existence).** For every $n,k\in\mathbb N$ satisfying $n<P_k$,

$$
V_k(D(n))=n,
$$

where $D(n)$ denotes the digit function $i\mapsto D_i(n)$. Moreover, $D(n)$ is valid through length $k$.

**Proof sketch.** Whenever $b_i>0$, the remainder definition gives $D_i(n)<b_i$. The hypothesis $n<P_k$ implies $P_k>0$, and therefore each earlier factor in the product is positive, so validity follows.

For reconstruction, repeatedly apply Euclidean division to $\lfloor n/P_i\rfloor$ by $b_i$. Since $P_{i+1}=P_ib_i$,

$$
\left\lfloor\frac{n}{P_i}\right\rfloor
=D_i(n)+b_i\left\lfloor\frac{n}{P_{i+1}}\right\rfloor.
$$

Multiplying by $P_i$ gives

$$
P_i\left\lfloor\frac{n}{P_i}\right\rfloor
=D_i(n)P_i+P_{i+1}\left\lfloor\frac{n}{P_{i+1}}\right\rfloor.
$$

Summing from $i=0$ to $k-1$ telescopes to

$$
n=\sum_{i<k}D_i(n)P_i+P_k\left\lfloor\frac{n}{P_k}\right\rfloor.
$$

The final quotient is $0$ because $n<P_k$, proving the identity. $\square$

**Corollary 3.5 (Finite bijection).** Evaluation is a bijection between valid length-$k$ digit strings and the interval

$$
\{0,1,\ldots,P_k-1\}.
$$

**Proof sketch.** Theorem 3.4 supplies a valid preimage for every integer in the interval, while Theorem 3.3 supplies injectivity. The capacity bound ensures that every valid string evaluates into the interval. $\square$

When $P_k=0$, the target interval is empty and validity through length $k$ is impossible: some $b_i=0$ occurs below $k$. Thus the corollary also handles degenerate sequences exactly.

### 3.5. Digit recovery

**Corollary 3.6 (Recovery of valid digits).** If $c$ is valid through length $k$, then for every $i<k$,

$$
D_i(V_k(c))=c_i.
$$

**Proof sketch.** By Lemma 3.1, $V_k(c)<P_k$. Theorem 3.4 says that extracting and evaluating the digits of $V_k(c)$ returns the same value. Both the extracted digit string and $c$ are valid, so uniqueness identifies them position by position. $\square$

## 4. Factoradics as a specialization

Set

$$
b_i=i+1.
$$

Then

$$
P_i=\prod_{j<i}(j+1)=i!.
$$

The validity condition $c_i<b_i$ becomes $c_i\le i$, and evaluation becomes

$$
V_k(c)=\sum_{i<k}c_i i!.
$$

**Corollary 4.1 (Factorial representation).** Every $n<k!$ has a unique expression

$$
n=\sum_{i=0}^{k-1}c_i i!
$$

with $0\le c_i\le i$. Its digits are

$$
c_i=\left\lfloor\frac{n}{i!}\right\rfloor\bmod(i+1).
$$

**Proof sketch.** Substitute $b_i=i+1$ and $P_i=i!$ into Theorems 3.3 and 3.4. $\square$

Thus factoradic uniqueness is not an isolated factorial identity. It is the universal mixed-radix uniqueness theorem evaluated at one base sequence. Constant-base notation is another specialization: setting every $b_i=q$ gives $P_i=q^i$ and the usual base-$q$ digits.

## 5. Length-independent normal forms

### 5.1. The divisibility chain

**Lemma 5.1 (Nested capacities).** If $i<k$, then

$$
P_{i+1}\mid P_k.
$$

**Proof sketch.** The later running product factors as

$$
P_k=P_{i+1}\prod_{j=i+1}^{k-1}b_j.
$$

This identity remains valid if some factor vanishes. $\square$

### 5.2. Locality of one digit

**Theorem 5.2 (Local digit dependence).** For every $n$ and $i$,

$$
D_i(n\bmod P_{i+1})=D_i(n).
$$

**Proof sketch.** Write $P_{i+1}=P_ib_i$. Reducing $n$ modulo $P_ib_i$ changes $n$ by a multiple of $P_ib_i$. After division by $P_i$, the quotient therefore changes by a multiple of $b_i$, which disappears upon reduction modulo $b_i$. If $P_i$ or $b_i$ is zero, the adopted quotient-remainder conventions make both sides agree directly. $\square$

The theorem says that position $i$ sees only the residue class of $n$ modulo the capacity through that position.

### 5.3. Truncation commutes with extraction

**Theorem 5.3 (Length-independent normal form).** For every $n$ and all $i<k$,

$$
D_i(n\bmod P_k)=D_i(n).
$$

**Proof sketch.** By Lemma 5.1, $P_{i+1}$ divides $P_k$. Consequently,

$$
(n\bmod P_k)\bmod P_{i+1}=n\bmod P_{i+1}.
$$

Apply Theorem 5.2 first to $n\bmod P_k$ and then to $n$. Both digits reduce to the digit of the same residue modulo $P_{i+1}$. $\square$

A direct consequence is **prefix stability**: computing $D_0(n),\ldots,D_{k-1}(n)$ and later extending to length $\ell>k$ never alters the first $k$ digits. Hence

$$
D(n)=(D_0(n),D_1(n),D_2(n),\ldots)
$$

is a canonical infinite stream, while a finite numeral is its prefix interpreted modulo the corresponding capacity.

### 5.4. Master reconstruction law

**Theorem 5.4 (Truncated reconstruction).** For every base sequence, every $n$, and every length $k$,

$$
V_k(D(n))=n\bmod P_k.
$$

**Proof sketch.** The telescoping calculation in Theorem 3.4 did not fundamentally require $n<P_k$; it established

$$
n=V_k(D(n))+P_k\left\lfloor\frac{n}{P_k}\right\rfloor.
$$

The first term is therefore the remainder modulo $P_k$. If $P_k=0$, then the quotient term is $0$ and the convention $n\bmod0=n$ gives the same identity. $\square$

Theorem 3.4 is the special case $n<P_k$. More conceptually, Theorem 5.4 says that finite extraction and evaluation implement the canonical projection

$$
\mathbb N\longrightarrow\mathbb N/P_k\mathbb N
$$

at the level of nonnegative residue representatives.

### 5.5. Compatible residue towers

For positive bases, the finite reconstructions

$$
r_k=V_k(D(n))=n\bmod P_k
$$

satisfy

$$
r_{k+1}\bmod P_k=r_k.
$$

Thus the sequence $(r_k)$ is compatible under reduction. This compatibility is the finite algebraic pattern underlying inverse-limit completions. If every base equals a prime $p$, the capacities are $p^k$, giving the familiar residue tower associated with $p$-adic arithmetic. Variable bases provide a broader family of nested moduli.

## 6. Additivity and carries

### 6.1. Linearity of evaluation

For digit functions $c$ and $d$, let $(c+d)_i=c_i+d_i$.

**Proposition 6.1 (Unconditional additivity).** For every $b,c,d$, and $k$,

$$
V_k(c+d)=V_k(c)+V_k(d).
$$

**Proof sketch.** Distribute multiplication over $c_i+d_i$ and split the finite sum:

$$
\sum_{i<k}(c_i+d_i)P_i
=\sum_{i<k}c_iP_i+
\sum_{i<k}d_iP_i.
$$

No validity or carry hypothesis is involved. $\square$

This proposition distinguishes semantic evaluation from syntactic normalization. Carries do not repair a false numerical equation; they transform an invalid coefficient list into the unique valid list with the same value or residue.

### 6.2. Carry-free addition

**Theorem 6.2 (Carry-free digitwise addition).** Suppose

$$
c_i+d_i<b_i\qquad\text{for every }i<k.
$$

Then, for every $i<k$,

$$
D_i\bigl(V_k(c)+V_k(d)\bigr)=c_i+d_i.
$$

**Proof sketch.** The hypotheses say that $c+d$ is valid through length $k$. Proposition 6.1 gives

$$
V_k(c)+V_k(d)=V_k(c+d).
$$

Corollary 3.6 recovers the valid digits of the right-hand side, yielding the claim. Notice that separate validity assumptions on $c$ and $d$ are unnecessary: the strict bound on their sum already implies each individual nonnegative digit lies below the same base. $\square$

**Proposition 6.3 (Local obstruction to a carry-free sum).** At a position $i$, the raw sum digit $c_i+d_i$ is valid if and only if

$$
c_i+d_i<b_i.
$$

Equivalently, a local overflow is forced exactly when

$$
b_i\le c_i+d_i.
$$

**Proof sketch.** This is the definition of validity applied to the pointwise sum, together with the total order on natural numbers. $\square$

Theorem 6.2 concerns the fully carry-free regime: every local sum in the block is valid. Proposition 6.3 identifies where that regime fails. It does not by itself describe the complete propagated carry pattern, because an incoming carry generated at a lower position can alter a higher local sum. A general normalization algorithm addresses that issue.

### 6.3. Carry normalization algorithm

Assume $b_i>0$ for the positions being normalized. Given arbitrary coefficients $a_i$ and an incoming carry $q_0=0$, compute

$$
t_i=a_i+q_i,
$$

$$
r_i=t_i\bmod b_i,
$$

$$
q_{i+1}=\left\lfloor\frac{t_i}{b_i}\right\rfloor.
$$

Then $0\le r_i<b_i$, and

$$
t_i=r_i+b_iq_{i+1}.
$$

Multiplication by $P_i$ converts the carried term into $q_{i+1}P_{i+1}$. Summing over positions telescopes, proving that normalization preserves value apart from the explicit final overflow $q_kP_k$. When every $a_i=c_i+d_i<b_i$, all carries vanish and the algorithm reduces to Theorem 6.2.

## 7. Algorithms and complexity

### 7.1. Running-product extraction

For a requested length $k$, digits can be extracted by maintaining $P_i$ incrementally.

**Algorithm.** Initialize $P\leftarrow1$. For $i=0,\ldots,k-1$, output

$$
\left\lfloor\frac{n}{P}\right\rfloor\bmod b_i,
$$

then set $P\leftarrow Pb_i$.

The algorithm uses $O(k)$ arithmetic steps and $O(k)$ output storage, or $O(1)$ auxiliary storage if digits are streamed. Bit complexity depends on the growth of $P_i$ and on the integer division algorithm. Prefix stability permits later extension without recomputing prior digits.

For positive bases, an alternative repeated-division algorithm maintains a quotient $q$. Set $q\leftarrow n$ and repeatedly output $q\bmod b_i$, then replace $q$ by $\lfloor q/b_i\rfloor$. The invariant $q=\lfloor n/P_i\rfloor$ proves equivalence with the explicit extraction formula.

### 7.2. Reconstruction

Given digits and bases, initialize $P\leftarrow1$ and $v\leftarrow0$. At position $i$, update

$$
v\leftarrow v+c_iP,
\qquad
P\leftarrow Pb_i.
$$

This takes $O(k)$ arithmetic operations. Validity can be checked simultaneously by testing $c_i<b_i$.

### 7.3. Carry-free addition test

Given two length-$k$ digit arrays, inspect each position. If every inequality $c_i+d_i<b_i$ holds, return their pointwise sum. Otherwise report the overflow positions or invoke carry normalization. The scan takes $O(k)$ local additions and comparisons. It may terminate early after the first overflow if only a yes-or-no decision is required.

## 8. Worked examples and applications

### 8.1. A heterogeneous numeral

Take bases

$$
(b_0,b_1,b_2,b_3)=(10,6,4,5).
$$

The running products are

$$
(P_0,P_1,P_2,P_3,P_4)=(1,10,60,240,1200).
$$

For $n=731$, the extracted digits are

$$
D_0(731)=731\bmod10=1,
$$

$$
D_1(731)=\left\lfloor\frac{731}{10}\right\rfloor\bmod6=73\bmod6=1,
$$

$$
D_2(731)=\left\lfloor\frac{731}{60}\right\rfloor\bmod4=12\bmod4=0,
$$

$$
D_3(731)=\left\lfloor\frac{731}{240}\right\rfloor\bmod5=3.
$$

Reconstruction gives

$$
1\cdot1+1\cdot10+0\cdot60+3\cdot240=731.
$$

At length $3$, the reconstructed value is

$$
1+10=11=731\bmod240.
$$

Extending from three positions to four leaves $(1,1,0)$ unchanged, illustrating prefix stability.

### 8.2. Clock arithmetic

With bases $(60,60,24)$, the running products are $(1,60,3600,86400)$. The number $45{,}296$ seconds has digits

$$
(56,34,12),
$$

because

$$
45{,}296=56+34\cdot60+12\cdot3600.
$$

The first two digits reconstruct $45{,}296\bmod3600=2{,}096$, corresponding to $34$ minutes and $56$ seconds. Adding a day-level position cannot alter those lower fields.

### 8.3. Array coordinates

For a row-major array with axis lengths $(4,3,5)$, a linear offset $n<60$ has coordinates

$$
\left(n\bmod4,
\left\lfloor\frac n4\right\rfloor\bmod3,
\left\lfloor\frac n{12}\right\rfloor\bmod5\right).
$$

This is mixed-radix extraction. If a new outer axis is appended, all existing coordinates remain unchanged. The length-independent normal form therefore justifies extensible hierarchical layouts.

### 8.4. Factorial digits and permutation ranks

For $b_i=i+1$, the first running products are $1,1,2,6,24,120$. A number $n<120$ has unique digits satisfying $c_0=0$, $c_1\le1$, $c_2\le2$, $c_3\le3$, and $c_4\le4$. For example,

$$
83=0\cdot0!+1\cdot1!+2\cdot2!+1\cdot3!+3\cdot4!.
$$

Thus its low-to-high factoradic digits are $(0,1,2,1,3)$. Such bounded digits align with successive choices in permutation ranking.

## 9. Discussion

The theory rests on a simple design principle: place values form a divisibility staircase. The recurrence $P_{i+1}=P_ib_i$ has three consequences. It makes quotient and remainder expose a digit, makes later capacities multiples of earlier capacities, and turns carries at one position into units at the next.

Several distinctions are worth emphasizing.

First, **uniqueness is combinatorial but proved arithmetically**. Counting valid strings gives $\prod_{i<k}b_i=P_k$ when all bases are positive, matching the size of the target interval. Counting alone does not prove that evaluation has no collisions. Top-digit splitting supplies injectivity, while explicit extraction supplies surjectivity.

Second, **digit locality is stronger than finite existence**. Existence says a number below $P_k$ has a representation of length $k$. Locality says digit $i$ is already determined by the residue modulo $P_{i+1}$ and remains fixed under every later extension. This turns a family of finite encodings into one coherent infinite normal form.

Third, **linearity and carrying belong to different layers**. Evaluation accepts arbitrary coefficients and is additive. Valid numerals are canonical representatives selected by local bounds. A carry is a normalization event caused by leaving those bounds. The carry-free theorem follows by combining linearity with uniqueness, rather than by simulating an addition procedure.

Finally, allowing arbitrary natural bases clarifies edge cases. A zero base is not a malformed arithmetic operation; it is a position with no admissible natural digit. Before that position, finite valid representations behave normally. At and beyond it, the valid representation space is empty, while the unconditional reconstruction identity continues to make sense under natural-number division conventions.

## 10. Future work

A first direction is a complete classification of carry patterns. The fully carry-free criterion is local, but propagated carries require a state transition depending on incoming overflow. One may ask when two base sequences induce identical carry behavior on all sums in a bounded interval, and whether this behavior is determined by suitable initial segments of their running products.

A second direction concerns digit-sum congruences. In constant base $q$, a number is congruent to its digit sum modulo $q-1$ because every place value $q^i$ is congruent to $1$. In mixed radix, one can seek moduli $m$ for which the varying products $P_i$ have a simple residue pattern, producing weighted or unweighted digit tests.

A third direction develops infinite completions. Compatible residues modulo $P_k$ form an inverse system. Under hypotheses ensuring that capacities grow and do not collapse, one can study the resulting mixed-radix completion, its topology, arithmetic, and relation to products of local digit spaces. Prefix-stable extraction supplies the canonical embedding of natural numbers.

A fourth direction is algorithmic. Parallel extraction, vectorized carry scans, random generation of valid numerals, and conversion between systems can exploit the separation between running-product computation and local residues. Applications include tensor indexing, hierarchical identifiers, scheduling, and combinatorial ranking.

## 11. Conclusion

Arbitrary mixed-radix systems admit a uniform representation theory. Running products $P_k$ serve simultaneously as place values, capacities, truncation moduli, and carry scales. Valid values lie below capacity; quotient-remainder splitting yields unique digits; and explicit extraction represents every integer below capacity.

The unconditional identity

$$
V_k(D(n))=n\bmod P_k
$$

shows that a finite prefix exactly reconstructs the corresponding residue. Because $P_{i+1}$ divides every later $P_k$, truncation commutes with digit extraction, giving a length-independent canonical stream. Evaluation is always additive, and whenever all local pointwise sums remain below their bases, the addition is carry-free and extraction returns those sums unchanged.

Constant-base notation, factoradics, clocks, nested counters, and multidimensional coordinates are therefore instances of one architecture. Their shared foundation is not constancy of base, but the interaction of cumulative products, Euclidean division, and local digit bounds.