# Factorial Mixed-Radix Coordinates and the Obstruction to a Residue-Product Decomposition

## Abstract

Factorial notation represents every integer in $[0,k!)$ uniquely by digits $c_i$ satisfying $0\le c_i\le i$ and the evaluation formula $\sum_{i<k}c_i i!$. This paper places that representation inside the general theory of mixed-radix systems and asks whether its local digit alphabets can be promoted from a set-theoretic product to additive or multiplicative residue coordinates. The answer changes sharply between the third and fourth stages. At length three, the Chinese Remainder Theorem gives a ring isomorphism $\mathbb Z/6\mathbb Z\cong\mathbb Z/2\mathbb Z\times\mathbb Z/3\mathbb Z$. At length four, although both $\mathbb Z/24\mathbb Z$ and $\mathbb Z/2\mathbb Z\times\mathbb Z/3\mathbb Z\times\mathbb Z/4\mathbb Z$ contain $24$ elements, they are not even isomorphic as additive groups. The obstruction is their exponent: $12$ annihilates every element of the product, but does not annihilate $1$ modulo $24$. Thus factorial digits are canonical mixed-radix coordinates but not independent residue coordinates. We give constructive conversion algorithms, numerical examples, and a structural interpretation in terms of carry propagation, nested filtrations, and prospective inverse limits.

## 1. Introduction

A positional numeral system does two jobs. First, it supplies a finite alphabet at each position and thereby gives names to numbers. Second, it prescribes arithmetic on those names. These jobs coincide so smoothly in familiar fixed-base notation that it is easy to conflate them. The factorial number system separates them.

At position $i$, factorial notation uses the place value $i!$ and permits $i+1$ possible digits. A length-$k$ code therefore has $1\cdot2\cdots k=k!$ possible states, matching the cardinality of both the interval $[0,k!)$ and the cyclic ring $\mathbb Z/k!\mathbb Z$. Unique factorial representation turns this cardinality match into a canonical bijection of sets.

The local digit at position $i$ can also be read as an element of $\mathbb Z/(i+1)\mathbb Z$. This suggests a stronger question: is the factorial representation an additive, or even multiplicative, decomposition

$$
\mathbb Z/k!\mathbb Z\overset{?}{\cong}
\prod_{r=2}^{k}\mathbb Z/r\mathbb Z?
$$

The orders match. At $k=3$, the proposed identification is exactly the Chinese Remainder Theorem. Nevertheless, at $k=4$ it fails at the additive level. The issue is not a defective choice of bijection. No additive bijection exists.

The decisive invariant is the additive exponent. Every element of a product of cyclic groups of orders $2$, $3$, and $4$ is annihilated by $\operatorname{lcm}(2,3,4)=12$, whereas the cyclic group of order $24$ contains an element of order $24$. The repeated factor $2$ in the radices creates overlap rather than an independent component.

This paper develops that conclusion from first principles. Section 2 defines mixed-radix and factorial codes. Section 3 proves that factorial notation is precisely the mixed-radix system with radices $i+1$. Section 4 gives finite reconstruction and conversion algorithms. Sections 5 and 6 establish the positive third-stage result and negative fourth-stage result. Section 7 interprets the obstruction as carry propagation and nonsplitting. Sections 8 and 9 discuss algorithms and applications, while the final sections present broader consequences and research directions.

## 2. Mixed-radix systems

### 2.1 Radices, place values, and valid codes

Let $(b_i)_{i\ge0}$ be a sequence of positive integers. Define its place values by

$$
P_0=1,
\qquad
P_i=\prod_{j=0}^{i-1}b_j\quad(i\ge1).
$$

A **valid mixed-radix code of length $k$** is a sequence of natural-number digits $(c_i)_{i\ge0}$ for which

$$
0\le c_i<b_i\qquad\text{for every }0\le i<k.
$$

Only the first $k$ digits matter. Its value is

$$
M_k(c)=\sum_{i=0}^{k-1}c_iP_i.
$$

The recursion $P_{i+1}=b_iP_i$ is the arithmetic source of carrying: $b_i$ units at position $i$ equal one unit at position $i+1$.

### 2.2 Finite reconstruction

The product $P_k=\prod_{i<k}b_i$ is both the number of valid codes and the size of the interval they represent.

**Theorem 2.1 (Mixed-Radix Reconstruction and Uniqueness).**  Let $b_i\ge1$ for $0\le i<k$. Every integer $n$ with $0\le n<P_k$ has a unique valid code $(c_0,\ldots,c_{k-1})$ such that

$$
n=\sum_{i=0}^{k-1}c_iP_i.
$$

**Proof sketch.** Extract digits successively. Set $q_0=n$, and for $i=0,\ldots,k-1$ use Euclidean division by $b_i$:

$$
c_i=q_i\bmod b_i,
\qquad
q_{i+1}=\left\lfloor\frac{q_i}{b_i}\right\rfloor.
$$

Then $q_i=c_i+b_iq_{i+1}$. Iterating this identity gives

$$
n=c_0+b_0c_1+b_0b_1c_2+\cdots+P_{k-1}c_{k-1}+P_kq_k.
$$

The bound $n<P_k$ forces $q_k=0$, yielding the representation. For uniqueness, reduce two equal evaluations modulo $b_0$ to identify $c_0$, subtract it, divide by $b_0$, and repeat. Equivalently, induction on $k$ identifies one digit at a time. ∎

The theorem is an extensional classification: it identifies the represented integer and all valid digits. It does not assert that arithmetic on the interval becomes coordinatewise arithmetic in the digit product.

## 3. The factorial specialization

### 3.1 Definitions

Choose

$$
b_i=i+1.
$$

The corresponding place values are

$$
P_i=\prod_{j=0}^{i-1}(j+1)=1\cdot2\cdots i=i!.
$$

A **factorial code of length $k$** is therefore a tuple $(c_0,\ldots,c_{k-1})$ satisfying

$$
0\le c_i\le i,
$$

and its **factoradic value** is

$$
F_k(c)=\sum_{i=0}^{k-1}c_i i!.
$$

The digit $c_0$ is necessarily $0$. It is retained because it makes the indexing and recurrence uniform.

**Theorem 3.1 (Factorial–Mixed-Radix Bridge).** For the radix sequence $b_i=i+1$, mixed-radix evaluation equals factoradic evaluation for every code and every length:

$$
M_k(c)=F_k(c).
$$

Moreover, mixed-radix validity $0\le c_i<b_i$ is equivalent to the factorial bound $0\le c_i\le i$.

**Proof sketch.** The place-value identity $P_i=i!$ follows directly from the finite product defining factorial. Substitution into $M_k(c)$ gives the evaluation identity term by term. Since the digits are integers, $c_i<i+1$ is equivalent to $c_i\le i$. ∎

**Corollary 3.2 (Factorial Representation Theorem).** Every integer $n$ with $0\le n<k!$ has a unique expansion

$$
n=\sum_{i=0}^{k-1}c_i i!,
\qquad 0\le c_i\le i.
$$

**Proof sketch.** Apply Theorem 2.1 to $b_i=i+1$ and use Theorem 3.1. ∎

**Corollary 3.3 (Factorial Value Uniqueness).** If $c$ and $d$ are valid factorial codes of length $k$ and $F_k(c)=F_k(d)$, then $c_i=d_i$ for every $i<k$.

This result is stronger than a cardinality argument: it says evaluation itself is injective on valid codes.

### 3.2 Example

For $k=4$, the weights are $0!=1$, $1!=1$, $2!=2$, and $3!=6$, while the digit bounds are $c_0=0$, $c_1\in\{0,1\}$, $c_2\in\{0,1,2\}$, and $c_3\in\{0,1,2,3\}$. For example,

$$
17=2\cdot3!+2\cdot2!+1\cdot1!+0\cdot0!,
$$

so its high-to-low display is $(2,2,1,0)$. The $24$ valid codes represent exactly $0$ through $23$.

## 4. Algorithms for factorial codes

### 4.1 Digit extraction

The reconstruction proof yields a direct algorithm. Given $0\le n<k!$, initialize $q=n$. For each $i$ from $0$ to $k-1$, compute

$$
c_i=q\bmod(i+1),
\qquad
q\leftarrow\left\lfloor\frac{q}{i+1}\right\rfloor.
$$

The resulting low-to-high list is the factorial code.

**Proposition 4.1 (Correctness of Factoradic Extraction).** For $0\le n<k!$, the extraction algorithm returns the unique digits satisfying $0\le c_i\le i$ and $n=\sum_{i<k}c_i i!$.

**Proof sketch.** Each remainder lies in $[0,i]$. The Euclidean identities telescope as in Theorem 2.1, and $n<k!$ makes the final quotient zero. Uniqueness follows from Corollary 3.3. ∎

Using arithmetic on machine integers, the algorithm performs $k$ divisions and remainders. Its arithmetic-operation count is $O(k)$. Bit complexity depends on the integer multiplication and division model; all intermediate quotients have at most $O(\log(k!))=O(k\log k)$ bits.

### 4.2 Evaluation

Given valid digits, one may evaluate the sum directly after generating successive factorials. A Horner-like recurrence is also available. If digits are stored high-to-low as $(c_{k-1},\ldots,c_1,c_0)$, nested multiplication by descending radices reconstructs the value. A straightforward weighted sum uses $O(k)$ additions and multiplications.

### 4.3 Carry normalization

Unrestricted digits can be normalized locally. Whenever a digit $a_i$ satisfies $a_i\ge i+1$, divide it as

$$
a_i=q(i+1)+r,
\qquad 0\le r<i+1,
$$

replace $a_i$ by $r$, and add $q$ to $a_{i+1}$. Value is preserved because

$$
q(i+1)i!=q(i+1)!.
$$

A low-to-high pass normalizes any finite nonnegative digit list, extending the list when the top digit produces a carry.

**Proposition 4.2 (Value Preservation of Local Carry).** A local carry at position $i$ leaves the represented integer unchanged.

**Proof.** Before the carry, the affected contribution is $a_i i!+a_{i+1}(i+1)!$. Writing $a_i=q(i+1)+r$ turns it into

$$
r i!+(a_{i+1}+q)(i+1)!,
$$

which is exactly the post-carry contribution. ∎

For a finite input list, a single low-to-high pass is sufficient because carries move only upward. The operation count is linear in the number of positions visited, although the output can gain positions depending on the represented value.

## 5. Residue coordinates and the third-stage theorem

### 5.1 The proposed decomposition

A length-$k$ factorial code has local alphabets of sizes $1,2,\ldots,k$. Omitting the singleton factor suggests the residue product

$$
R_k=\prod_{r=2}^{k}\mathbb Z/r\mathbb Z.
$$

Its cardinality is

$$
|R_k|=\prod_{r=2}^{k}r=k!=|\mathbb Z/k!\mathbb Z|.
$$

The factorial representation theorem therefore gives a set-level correspondence between $mathbb Z/k!\mathbb Z$ and the underlying digit set. The question is whether some correspondence can be an additive or ring isomorphism.

### 5.2 Positive result at length three

**Theorem 5.1 (Stage-Three Chinese-Remainder Decomposition).** There is a canonical ring isomorphism

$$
\Phi_3:\mathbb Z/3!\mathbb Z\longrightarrow
\mathbb Z/2\mathbb Z\times\mathbb Z/3\mathbb Z
$$

specified by

$$
\Phi_3([n]_6)=([n]_2,[n]_3).
$$

**Proof sketch.** Since $3!=6=2\cdot3$ and $\gcd(2,3)=1$, simultaneous reduction modulo $2$ and modulo $3$ is a ring homomorphism. If two residues modulo $6$ have the same reductions, their difference is divisible by both $2$ and $3$, hence by $6$, so the map is injective. Source and target each have six elements, hence it is bijective. Alternatively, Bézout coefficients reconstruct each residue explicitly. ∎

For example, $[5]_6$ maps to $([1]_2,[2]_3)$. Addition and multiplication may be performed independently in the two components and then reconstructed modulo $6$.

This positive result depends on coprimality, not merely on matching cardinalities.

## 6. The fourth-stage obstruction

### 6.1 Additive exponent

For a finite additive group $G$, its **exponent** is the least positive integer $m$ such that $mg=0$ for every $g\in G$. The cyclic group $\mathbb Z/n\mathbb Z$ has exponent $n$. A direct product of cyclic groups of orders $n_1,\ldots,n_s$ has exponent

$$
\operatorname{lcm}(n_1,\ldots,n_s).
$$

The reason is coordinatewise: $m$ annihilates the product precisely when every $n_j$ divides $m$.

**Lemma 6.1 (Annihilation of Fourth-Stage Residues).** Every element $x$ of

$$
R_4=\mathbb Z/2\mathbb Z\times\mathbb Z/3\mathbb Z\times\mathbb Z/4\mathbb Z
$$

satisfies $12x=0$.

**Proof.** The integer $12$ is divisible by $2$, $3$, and $4$. Multiplication by $12$ therefore gives zero in each coordinate. ∎

The source behaves differently.

**Lemma 6.2 (A Nonannihilated Source Element).** In $\mathbb Z/24\mathbb Z$,

$$
12[1]_{24}=[12]_{24}\ne[0]_{24}.
$$

**Proof.** The integer $24$ does not divide $12$. ∎

### 6.2 Main negative result

**Theorem 6.3 (Stage-Four Additive Obstruction).** There is no additive-group isomorphism

$$
\mathbb Z/4!\mathbb Z
\cong
\mathbb Z/2\mathbb Z\times\mathbb Z/3\mathbb Z\times\mathbb Z/4\mathbb Z.
$$

**Proof.** Suppose an additive isomorphism $T$ existed. Set $x=T([1]_{24})$. Lemma 6.1 gives $12x=0$. Since $T$ preserves repeated addition,

$$
T(12[1]_{24})=12T([1]_{24})=0=T(0).
$$

Injectivity of $T$ would imply $12[1]_{24}=0$, contradicting Lemma 6.2. ∎

**Corollary 6.4 (Stage-Four Ring Obstruction).** There is no ring isomorphism between the same two rings.

**Proof.** Every ring isomorphism induces an additive-group isomorphism, which Theorem 6.3 excludes. ∎

The result is stronger than failure of a particular factorial-digit map. It rules out every possible additive bijection. Both sets have $24$ elements, but their additive geometries differ: one has an element whose successive multiples traverse a cycle of length $24$, while every orbit in the other closes after at most $12$ steps.

## 7. Carries as the structural obstruction

### 7.1 Set coordinates versus algebraic coordinates

A valid length-four factorial code is a member of the Cartesian set

$$
\{0\}\times\{0,1\}\times\{0,1,2\}\times\{0,1,2,3\}.
$$

As a set, this is naturally identified with the underlying set of $R_4$. But transporting addition from $mathbb Z/24\mathbb Z$ through factorial evaluation does not produce coordinatewise modular addition. It produces carry-normalized addition.

For example, low-to-high digits for $11$ are $(0,1,2,1)$. Adding the code for $1$, namely $(0,1,0,0)$, first overflows the radix-$2$ position, then the radix-$3$ position, yielding $(0,0,0,2)$, the code for $12$. The update propagates across positions.

In the direct residue product, by contrast,

$$
(1\bmod2,2\bmod3,1\bmod4)+(1\bmod2,0\bmod3,0\bmod4)
=(0\bmod2,2\bmod3,1\bmod4),
$$

and no coordinate can communicate with another. These tuples should not be confused with factoradic digits: the calculation merely illustrates the independent wrapping built into a product ring.

### 7.2 Coprime decomposition versus overlapping radices

The Chinese Remainder Theorem decomposes a modulus into pairwise coprime factors. At stage three, $2$ and $3$ satisfy this condition. At stage four, the new radix $4$ overlaps with $2$. Their product counts the prime $2$ too many times for independent residue reconstruction.

The numerical signature is

$$
\operatorname{lcm}(2,3,4)=12<24=2\cdot3\cdot4.
$$

The product controls cardinality; the least common multiple controls additive exponent. Equality between these quantities holds exactly when the factors are pairwise coprime. Factorial radices cease to be pairwise coprime as soon as $4$ appears.

### 7.3 A filtration viewpoint

Factorial truncations are naturally nested:

$$
(1!)\supseteq(2!)\supseteq(3!)\supseteq(4!)\supseteq\cdots
$$

inside the integers. Passing from modulus $k!$ to modulus $(k+1)!$ introduces a fiber of size $k+1$. A factorial digit selects one representative in that fiber. Such a selection is set-theoretic; it need not define a homomorphic splitting.

Carries record the extension data between adjacent layers. Treating digits as independent residue coordinates would amount to splitting all layers simultaneously. The fourth-stage theorem shows that this cannot occur even for the additive structure.

## 8. Computational demonstrations

Three finite experiments reveal the theory directly.

First, enumerate all valid codes of length $k$. Their evaluated values are exactly $0,1,\ldots,k!-1$. Sorting is unnecessary if codes are generated in rank order, but exhaustive enumeration provides an independent check of coverage and uniqueness.

Second, at stage three, test simultaneous reduction modulo $2$ and $3$. The six residues modulo $6$ yield six distinct pairs, and componentwise addition and multiplication agree with operations modulo $6$.

Third, at stage four, enumerate the $24$ triples in $R_4$. Multiplying each by $12$ gives zero. In $mathbb Z/24\mathbb Z$, however, the list of multiples of $1$ has period $24$, and its twelfth entry is $12$, not zero. This finite witness captures the invariant used in Theorem 6.3.

These experiments are pedagogical rather than substitutes for the proofs. Their algorithms are transparent: enumeration costs $O(k!)$ outputs for all length-$k$ codes, extraction costs $O(k)$ arithmetic operations per integer, and testing an annihilator over the full residue product costs $O(k!)$ coordinate operations.

## 9. Applications and broader connections

### 9.1 Permutation ranking

A permutation of $k$ objects can be described by successive choices from sets of sizes $k,k-1,\ldots,1$. Reversing the order produces the factorial digit ranges. The resulting Lehmer-style code ranks permutations lexicographically in $[0,k!)$. The factorial representation theorem guarantees unique recovery of the rank from the code and vice versa.

The additive obstruction warns against interpreting these choice coordinates as independent modular quantities. Advancing a rank can alter several choices at once, just as incrementing $11$ to $12$ causes a cascade of factorial carries.

### 9.2 Hierarchical counters and calendars

Mixed-radix systems model counters whose units roll over at different thresholds. If thresholds share factors, a Cartesian list of local states still classifies the global states, but global addition generally requires carry propagation. Calendar units are an irregular version of the same phenomenon. A product of independent cyclic clocks does not by itself model the rule that enough seconds increment minutes.

### 9.3 Data encoding

A tuple of bounded categorical values can be packed into a single integer by mixed-radix evaluation. The bridge theorem supplies correctness when the category sizes are $1,2,\ldots,k$. The distinction between set and algebra matters whenever encoded values are combined: arithmetic on packed integers does not usually correspond to coordinatewise arithmetic on categories.

### 9.4 Genuine CRT coordinates

For multiplicative decomposition, the appropriate factors are the maximal prime powers dividing $k!$. If

$$
k!=\prod_{p\le k}p^{v_p(k!)},
$$

then these prime powers are pairwise coprime, and the Chinese Remainder Theorem gives

$$
\mathbb Z/k!\mathbb Z
\cong
\prod_{p\le k}\mathbb Z/p^{v_p(k!)}\mathbb Z.
$$

These are genuine ring coordinates. A factorial code may be evaluated and then reduced into these components, but individual factorial digits are not themselves the CRT factors.

## 10. Discussion

The main results draw a sharp line between three notions of coordinate system.

1. **Combinatorial coordinates** provide a bijection of finite sets. Factorial digits do this for every length $k$.
2. **Additive coordinates** identify the corresponding additive groups. They exist for the proposed radix product at $k=3$ but fail at $k=4$.
3. **Multiplicative coordinates** identify rings. They likewise exist at $k=3$ and fail at $k=4$.

The stage-four failure occurs before multiplication enters the picture. Therefore any attempted repair that changes only the digitwise multiplication law is insufficient; addition itself must include carries.

The exponent argument is particularly effective because it is invariant under all additive isomorphisms. It does not depend on how one labels elements or chooses a candidate map. It also indicates a prospective general classification. For

$$
R_k=\prod_{r=2}^{k}\mathbb Z/r\mathbb Z,
$$

the exponent is $\operatorname{lcm}(2,3,\ldots,k)$, whereas the exponent of $mathbb Z/k!\mathbb Z$ is $k!$. If

$$
\operatorname{lcm}(2,3,\ldots,k)<k!,
$$

then no additive isomorphism can exist. At $k=4$ this strict inequality is immediate. Establishing it uniformly for all $k\ge4$ would prove the exact finite classification: the direct radix-residue product agrees additively with the factorial cyclic group only in the low stages where no harmful overlap has yet appeared.

## 11. Future work

A first objective is a uniform proof that the proposed direct product is additively equivalent to $\mathbb Z/k!\mathbb Z$ exactly for $k\le3$, with trivial factors interpreted appropriately. The expected invariant is the strict inequality between the least common multiple and the product for $k\ge4$.

A second objective is to compare factorial digits with the genuine prime-power CRT decomposition. Evaluation followed by residue projection gives a canonical map, but understanding its digit-level behavior may reveal efficient conversion algorithms.

A third direction is to formulate factorial codes as sections of successive quotients in the filtration by factorial ideals. The central question is which extensions split and how the carry law represents the obstruction to splitting.

A fourth direction concerns infinite expansions. Because $k!$ divides $(k+1)!$, the rings $\mathbb Z/k!\mathbb Z$ form an inverse system. Coherent finite factorial codes should describe its inverse limit, with topology supplied by truncation and addition supplied by carry normalization. The finite obstruction shows that raw coordinatewise residue addition cannot be the correct infinite operation.

Finally, unrestricted finitely supported factorial digits admit local carry rewrites. Proving that this rewrite system is terminating and confluent would establish that every sequence has an algorithm-independent normal form, precisely the valid factorial code of the same value.

## 12. Conclusion

Factorial notation is exactly the mixed-radix system with radices $i+1$. Its evaluation, validity conditions, extraction algorithm, and uniqueness all descend from the general mixed-radix framework. This yields a canonical classification of the $k!$ integers in $[0,k!)$ by bounded factorial digits.

That classification does not generally respect coordinatewise algebra. At the third stage, coprimality permits the genuine ring decomposition

$$
\mathbb Z/6\mathbb Z\cong\mathbb Z/2\mathbb Z\times\mathbb Z/3\mathbb Z.
$$

At the fourth stage, the overlap between radices $2$ and $4$ forces the target exponent down to $12$, while the source remains cyclic of exponent $24$. Hence no additive, and therefore no ring, isomorphism exists.

The carry is the conceptual boundary between the two pictures. Factorial digits are independent as choices but dependent under arithmetic. Their product counts states; their carries encode structure.