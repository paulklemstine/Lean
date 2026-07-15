# Repeated Decimal Certificates and Exponential Growth in Orderly Friedman Numbers

**Aristotle**  
**July 15, 2026**

## Abstract

An orderly Friedman number is a positive integer representable by a nontrivial arithmetic expression that uses exactly its decimal digits in their original left-to-right order. We give a precise expression model including addition, multiplication, exponentiation, unary negation, and width-aware decimal concatenation. The identity $127=-1+2^7$ supplies a three-digit orderly certificate. Repeating this certificate and concatenating adjacent copies produces an infinite sequence

$$
127,\ 127127,\ 127127127,\ldots.
$$

Writing its terms as $F_0=127$ and $F_{n+1}=1000F_n+127$, we prove that every $F_n$ is an orderly Friedman number, that the sequence is strictly increasing, and that

$$
999F_n=127igl(1000^{n+1}-1igr).
$$

We derive the congruence $F_n\equiv127\pmod{1000}$, the divisibility $1000^{n+1}-1\mid999F_n$, sharp exponential bounds, and the exact normalized error

$$
\frac{127}{999}-\frac{F_n}{1000^{n+1}}
=
\frac{127}{999\cdot1000^{n+1}}.
$$

We also record two boundary checks: orderly Friedman numbers need not be odd, since $736=7+3^6$, and a commonly supplied list ending in $14641,155$ is not strictly increasing as displayed. The results establish an explicit infinite subfamily and a reusable certificate-composition method, while making no claim to classify or count all orderly Friedman numbers.

## 1. Introduction

Friedman numbers connect decimal notation with arithmetic expression trees. A positive integer is a Friedman number if its own digits can be combined nontrivially to reproduce the integer. The orderly variant imposes a syntactic constraint: the digits must appear in the expression in the same order in which they appear in the numeral. This restriction creates an interaction between two structures that are usually treated separately. Arithmetic controls the value of an expression, while combinatorics on words controls the order of its leaves.

For example,

$$
127=-1+2^7
$$

uses the digits $1$, $2$, and $7$ from left to right and evaluates to $127$. Likewise,

$$
736=7+3^6
$$

uses $7$, $3$, and $6$ in order. These identities are not mere numerical coincidences: they are certificates whose syntax records exactly the decimal word being represented.

The objective of this paper is constructive. Rather than attempt a classification of all orderly Friedman numbers, we show that one certificate can be composed with copies of itself to produce infinitely many. Concatenating copies of the certified block $127$ yields the family

$$
F_n=\underbrace{127127\cdots127}_{n+1\text{ copies}}.
$$

This family admits three equivalent descriptions:

1. a repeated decimal word;
2. a recursively concatenated arithmetic certificate; and
3. an affine recurrence $F_{n+1}=1000F_n+127$.

Their equivalence is the core result. Once it is established, elementary algebra yields an exact closed form, congruences, divisibility, and asymptotic growth.

The construction is deliberately explicit. It separates what is proved from what remains open. It proves an infinite subfamily, not an asymptotic for the full set. It also shows why careful data validation matters: parity is not invariant, and the supplied list

$$
127,343,736,1285,2187,2502,2592,2737,3125,3685,3864,3972,
4096,6455,11264,11664,12850,13825,14641,155
$$

cannot be an increasing list in the order displayed.

## 2. Expression language and decimal semantics

### 2.1 Expressions

We use expressions generated from decimal digits $0,1,\ldots,9$ by the following constructors:

- a single digit;
- unary negation;
- binary addition;
- binary multiplication;
- exponentiation by a nonnegative integer written in decimal;
- decimal concatenation with an explicitly declared width.

The **leaf word** $L(E)$ of an expression $E$ is the list of decimal digits encountered from left to right. A digit $d$ has leaf word $[d]$. Negation does not change the leaf word. For addition, multiplication, and concatenation, the leaf word is the leaf word of the left operand followed by that of the right operand. For a power $E^k$, the decimal digits of the exponent $k$ follow the leaves of $E$. Thus the leaf word of $-1+2^7$ is $[1,2,7]$.

The integer evaluation $\operatorname{ev}(E)$ has the expected meaning for the arithmetic constructors. If $E$ is concatenated with $G$ using right width $k$, then

$$
\operatorname{ev}(E\mathbin{\Vert_k}G)
=
10^k\operatorname{ev}(E)+\operatorname{ev}(G).
$$

A concatenation is **well formed** when $k$ equals the number of digit leaves in $G$, and all subexpressions are well formed. The explicit width prevents an ambiguity that would otherwise arise from leading zeroes or nested concatenations.

### 2.2 Decimal value

For a finite digit word $w=[d_1,\ldots,d_m]$, define its decimal value by

$$
V(w)=\sum_{j=1}^{m}d_j10^{m-j},
$$

with $V([])=0$. The fundamental rule for words is the following.

### Lemma 2.1 (Decimal append identity)

For all finite decimal words $x$ and $y$,

$$
V(xy)=V(x)10^{|y|}+V(y),
$$

where $xy$ denotes concatenation and $|y|$ is the length of $y$.

**Proof sketch.** Induct on the length of $x$. The empty-word case is immediate. If $x$ begins with digit $d$ and has tail $x'$, expand the definition of $V$, apply the induction hypothesis to $x'y$, and collect powers of $10$. The formula is precisely the positional rule for shifting $V(x)$ left by $|y|$ decimal places before appending $y$. $\square$

### 2.3 Orderly certificates

An expression $E$ is an **orderly Friedman certificate** for a positive integer $N$ if:

1. $E$ is well formed;
2. $V(L(E))=N$;
3. $\operatorname{ev}(E)=N$; and
4. $E$ contains at least one arithmetic operation other than concatenation.

A positive integer is an **orderly Friedman number** if it has such a certificate. Condition $4$ excludes the vacuous “certificate” obtained by simply concatenating the digits of $N$ unchanged.

This definition permits a certificate to be reasoned about through two interfaces. The syntactic interface is its leaf word; the semantic interface is its integer evaluation. A successful composition must preserve both.

### Proposition 2.2 (Two seed certificates)

The integers $127$ and $736$ are orderly Friedman numbers.

**Proof sketch.** For $127$, use

$$
-1+2^7=127.
$$

Its leaf word is $[1,2,7]$, whose decimal value is $127$, and it contains negation, addition, and exponentiation. For $736$, use

$$
7+3^6=7+729=736.
$$

Its leaf word is $[7,3,6]$, and it likewise contains genuine arithmetic. $\square$

Other familiar examples include

$$
343=(3+4)^3,
$$

$$
1285=(1+2^8)\cdot5,
$$

and

$$
2592=2^5\cdot9^2,
$$

all of which preserve the displayed digit order. These examples provide context, but the infinite construction below uses only the certificate for $127$.

## 3. Repetition of the certified block

Define a sequence $(F_n)_{n\ge0}$ recursively by

$$
F_0=127,
\qquad
F_{n+1}=1000F_n+127.
$$

Define certificates $(C_n)_{n\ge0}$ in parallel. Let $C_0$ be the expression $-1+2^7$. Given $C_n$, let $C_{n+1}$ be the width-$3$ concatenation of $C_n$ with a fresh copy of $C_0$:

$$
C_{n+1}=C_n\mathbin{\Vert_3}C_0.
$$

The initial values are

$$
F_0=127,
\qquad
F_1=127127,
\qquad
F_2=127127127.
$$

### Lemma 3.1 (Leaf-block structure)

For every $n\ge0$, the leaf word of $C_n$ is $[1,2,7]$ repeated exactly $n+1$ times.

**Proof sketch.** The assertion is immediate for $C_0$. At each recursive step, concatenation appends the leaf word of $C_0$, namely $[1,2,7]$, to the leaf word already present. Induction gives the claimed repetition count. $\square$

### Lemma 3.2 (Certificate evaluation)

For every $n\ge0$,

$$
\operatorname{ev}(C_n)=F_n.
$$

**Proof sketch.** The base case is the identity $-1+2^7=127$. For the induction step, width-$3$ concatenation gives

$$
\operatorname{ev}(C_{n+1})
=1000\operatorname{ev}(C_n)+\operatorname{ev}(C_0).
$$

Substitute the induction hypothesis and $\operatorname{ev}(C_0)=127$ to obtain $1000F_n+127=F_{n+1}$. $\square$

### Lemma 3.3 (Decimal evaluation of the leaves)

For every $n\ge0$,

$$
V(L(C_n))=F_n.
$$

**Proof sketch.** In the base case, $V([1,2,7])=127$. At the next step, Lemma 2.1 and Lemma 3.1 give

$$
V(L(C_{n+1}))
=V(L(C_n))10^3+V([1,2,7]).
$$

Using the induction hypothesis, the right-hand side is $1000F_n+127=F_{n+1}$. $\square$

### Lemma 3.4 (Well-formedness and nontriviality)

Every $C_n$ is well formed and contains a genuine arithmetic operation.

**Proof sketch.** The seed $C_0=-1+2^7$ is well formed and arithmetically nontrivial. Each added right operand has exactly three leaves, so width $3$ is correct. Concatenation preserves the already existing negation, addition, and exponentiation. Induction proves both assertions. $\square$

### Theorem 3.5 (Infinite repeated-certificate family)

For every $n\ge0$, $F_n$ is an orderly Friedman number.

**Proof sketch.** Use $C_n$ as the certificate. Lemma 3.4 supplies well-formedness and nontriviality. Lemma 3.3 says that the leaves spell the decimal numeral $F_n$, and Lemma 3.2 says that the expression evaluates to $F_n$. These are exactly the four certificate conditions. $\square$

## 4. Exact algebraic structure

### Theorem 4.1 (Closed form)

For every $n\ge0$,

$$
999F_n=127igl(1000^{n+1}-1igr).
$$

Consequently,

$$
F_n=127\sum_{j=0}^{n}1000^j
=127\frac{1000^{n+1}-1}{999}.
$$

**Proof sketch.** Induct on $n$. For $n=0$, both sides equal $999\cdot127$. Suppose the identity holds at $n$. From the recurrence,

$$
999F_{n+1}=999(1000F_n+127).
$$

Substitute $999F_n=127(1000^{n+1}-1)$ and simplify:

$$
999F_{n+1}
=127\left(1000(1000^{n+1}-1)+999\right)
=127(1000^{n+2}-1).
$$

Division by $999$ is legitimate in the displayed rational form, while the first identity is division-free over the integers. The finite-sum form follows from the geometric-series identity. $\square$

The formula explains the decimal pattern. In base $1000$, the number $F_n$ consists of $n+1$ identical “digits,” each equal to $127$. Because $127<1000$, no carrying occurs between blocks.

### Corollary 4.2 (Suffix congruence)

For every $n\ge0$,

$$
F_n\equiv127\pmod{1000}.
$$

**Proof sketch.** The base term has the desired residue. For every successor term, the recurrence gives $F_{n+1}=1000F_n+127$, whose first summand is divisible by $1000$. $\square$

### Corollary 4.3 (Repunit divisibility)

For every $n\ge0$,

$$
1000^{n+1}-1\mid999F_n.
$$

**Proof sketch.** The closed form writes $999F_n$ as $127$ times $1000^{n+1}-1$. $\square$

### Theorem 4.4 (Strict increase and infinitude)

The sequence $(F_n)$ is strictly increasing. Hence there are infinitely many pairwise distinct orderly Friedman numbers.

**Proof sketch.** Since $F_n$ is positive,

$$
F_{n+1}-F_n=999F_n+127>0.
$$

Thus $F_{n+1}>F_n$ for every $n$. Theorem 3.5 makes every term orderly, and strict increase makes the terms pairwise distinct. $\square$

It is useful to distinguish the two roles in this conclusion. Certificate composition proves membership in the orderly class; monotonicity proves distinctness. Neither fact alone would establish an infinite set.

## 5. Exponential growth and exact normalization

### Theorem 5.1 (Sharp exponential sandwich)

For every $n\ge0$,

$$
126\cdot1000^{n+1}<999F_n<127\cdot1000^{n+1}.
$$

**Proof sketch.** Let $P=1000^{n+1}$. The closed form gives $999F_n=127(P-1)$. Since $P>1$,

$$
127(P-1)<127P.
$$

For the lower bound, $127(P-1)>126P$ is equivalent to $P>127$, which holds because $P\ge1000$. $\square$

### Corollary 5.2 (Asymptotic growth)

As $n\to\infty$,

$$
F_n\sim\frac{127}{999}1000^{n+1}.
$$

In particular, $F_n=\Theta(1000^{n+1})$.

**Proof sketch.** Divide the inequalities of Theorem 5.1 by $999\cdot1000^{n+1}$, or use the closed form directly. The ratio of $F_n$ to $(127/999)1000^{n+1}$ tends to $1$. $\square$

### Theorem 5.3 (Exact normalized error)

For every $n\ge0$,

$$
\frac{127}{999}-\frac{F_n}{1000^{n+1}}
=
\frac{127}{999\cdot1000^{n+1}}.
$$

**Proof sketch.** Divide the closed form by $999\cdot1000^{n+1}$:

$$
\frac{F_n}{1000^{n+1}}
=
\frac{127}{999}\left(1-\frac{1}{1000^{n+1}}\right).
$$

Subtract this expression from $127/999$. $\square$

The theorem is stronger than a limit statement. It specifies the sign, magnitude, and geometric decay of the error at every index. The normalized sequence approaches its limit from below, and each increment of $n$ divides the error by exactly $1000$.

## 6. Algorithms

### 6.1 Streaming recurrence algorithm

For successive terms, the recurrence is the natural algorithm.

**Input:** a nonnegative integer $n$.  
**Output:** $F_n$.

1. Set $x\leftarrow127$.
2. Repeat $n$ times: set $x\leftarrow1000x+127$.
3. Return $x$.

The algorithm performs $n$ multiplications by a fixed small integer and $n$ additions, so it uses $O(n)$ arithmetic operations. The output has $3(n+1)$ decimal digits. With bit complexity included, the cost is governed by arithmetic on integers whose length grows linearly with $n$.

A useful invariant after $j$ iterations is

$$
x=F_j=\underbrace{127127\cdots127}_{j+1\text{ copies}}.
$$

This invariant proves correctness: initialization establishes it at $j=0$, and one update shifts the numeral by three places and appends $127$.

### 6.2 Closed-form random-access algorithm

For a single distant term, compute

$$
P=1000^{n+1}
$$

by exponentiation by squaring, then return

$$
127(P-1)/999.
$$

Exponentiation by squaring uses $O(\log n)$ large-integer multiplications. The division is exact by the geometric-series identity. This method reduces the number of high-level multiplications, although the output-size lower bound remains: writing $F_n$ requires $\Theta(n)$ decimal digits.

### 6.3 Certificate and identity audit

A numerical audit can compare independent characterizations:

1. recurrence generation;
2. direct repetition of the decimal block $127$;
3. the division-free identity $999F_n=127(1000^{n+1}-1)$;
4. the suffix check $F_n\bmod1000=127$; and
5. the normalized-error formula using exact rational arithmetic.

This audit does not search for arbitrary Friedman representations. It checks the explicit family and the theorems proved about it. For each fixed $n$, all tests use deterministic integer or rational arithmetic.

## 7. Boundary checks and data discipline

### Proposition 7.1 (Parity is not universal)

Not every orderly Friedman number is odd.

**Proof sketch.** The even number $736$ has the orderly certificate

$$
736=7+3^6.
$$

The digits occur in the order $7,3,6$, and the expression is nontrivial. $\square$

This counterexample is important because the seed $127$ and every repeated-$127$ term are odd. A property of one constructed subfamily need not be an invariant of the entire class.

### Proposition 7.2 (The displayed data are not increasing)

The sequence as displayed below is not strictly increasing:

$$
127,343,736,1285,2187,2502,2592,2737,3125,3685,3864,3972,
4096,6455,11264,11664,12850,13825,14641,155.
$$

**Proof sketch.** Its last adjacent comparison would require $14641<155$, which is false. $\square$

The proposition concerns only the ordering of the supplied data. It neither proves nor disproves that $155$ is orderly. It warns against interpreting the displayed position as a rank in an increasing enumeration without first correcting or clarifying the list.

## 8. Applications and broader interpretation

The repeated-certificate family illustrates a general bridge between decimal combinatorics and affine dynamics. Appending a fixed $k$-digit block $b$ transforms a current value $x$ by

$$
T(x)=10^kx+b.
$$

Iteration of $T$ yields

$$
T^{n+1}(0)=b\sum_{j=0}^{n}10^{kj}.
$$

For $b=127$ and $k=3$, this is exactly $F_n$. The arithmetic-expression certificate supplies more than the decimal orbit: it certifies that every orbit point belongs to the orderly Friedman class.

This perspective has several applications.

First, it produces benchmark instances for expression-search algorithms. The family contains arbitrarily long digit strings with known certificates, exact values, and predictable structure. Search procedures can be tested on whether they recover the repeated decomposition rather than merely evaluating numbers.

Second, the suffix congruence and closed form provide inexpensive consistency checks in databases of constructed examples. Every claimed member of this family must end in $127$, satisfy the geometric identity, and have a number of decimal digits divisible by $3$.

Third, the separation between leaf words and evaluations suggests automata-theoretic methods. A parser can track the syntactic word while modular registers track evaluations. Bounded expression depth or bounded exponents may make parts of the recognition problem finite-state after residue abstraction.

Fourth, using several compatible certified blocks could create branching families. A single block yields one term at each depth and therefore only logarithmically many terms below a magnitude bound. A finite grammar of interchangeable blocks could yield exponentially many words at depth $n$, potentially converting syntactic entropy into a power-law lower bound for the counting function.

## 9. A general composition principle

The construction can be abstracted without asserting that every conceivable expression convention supports it. Suppose a positive integer $b$ has exactly $k$ decimal digits and possesses an orderly certificate $E$ whose leaf word is the decimal word of $b$. Assume decimal concatenation is available with width $k$ and that the arithmetic already present in $E$ remains admissible inside a concatenated expression. Define $H_0=b$ and $H_{n+1}=10^kH_n+b$, while recursively concatenating one new copy of $E$ on the right.

Under these hypotheses, the proofs of Lemmas 3.1–3.4 apply word for word with $[1,2,7]$, $127$, and $3$ replaced by the digit word of $b$, the value $b$, and the width $k$. Consequently, every $H_n$ has a certificate made of $n+1$ ordered copies of $E$. The associated algebra is

$$
H_n=b\sum_{j=0}^{n}10^{kj},
$$

and therefore

$$
(10^k-1)H_n=b\bigl(10^{k(n+1)}-1\bigr).
$$

This conditional principle clarifies which features of $127$ are essential. Its numerical value is not special to the recurrence argument; what matters is the agreement among three quantities: the decimal value of the block, the evaluation of its expression, and the width used for concatenation. Nontriviality must also be inherited, or repetition would certify every decimal word vacuously.

The principle also identifies possible failure modes. If the right width is wrong, place value and leaf length diverge. If evaluation of the seed does not equal the block value, the syntactic repetition and numerical recurrence follow different orbits. If an operator convention disallows a seed operation inside a larger expression, closure fails at the syntactic level. Thus fixed-block closure is best viewed as an invariant-preservation theorem, not merely as an observation about repeated strings.

For the present family, all hypotheses are explicit: $b=127$, $k=3$, and $E=-1+2^7$. The general formulation explains why the same proof architecture is likely reusable for other certified blocks while keeping the established claims separate from the broader classification problem.

## 10. Limitations

The principal limitation is scope. The results concern one explicit infinite subfamily. They do not characterize every orderly Friedman number, determine whether a given arbitrary integer is orderly, or establish the density of orderly numbers among Friedman numbers.

The asymptotic statement

$$
F_n\sim\frac{127}{999}1000^{n+1}
$$

describes growth along the constructed sequence; it is not an asymptotic count of orderly Friedman numbers below $x$. Indeed, because the family has one term per block length, the number of its members below $x$ is only on the order of $\log x$.

The expression model includes decimal concatenation with explicit width and requires at least one non-concatenation operation. Different conventions in recreational number theory may allow division, factorials, roots, multi-digit exponent tokens, or other operators. Results should therefore be compared only after conventions are aligned.

Finally, repetition relies on a certificate whose evaluated value equals the block it spells. This self-consistency makes concatenation straightforward. More general composition schemes may require control of carries, signs, widths, and interactions between neighboring expressions.

## 11. Future work

The block-$127$ construction suggests a general fixed-block closure theorem. If a positive $k$-digit block $b$ has a nontrivial orderly certificate and copies can be concatenated without changing the convention, define

$$
G_0=b,
\qquad
G_{n+1}=10^kG_n+b.
$$

One expects every $G_n$ to be orderly and

$$
(10^k-1)G_n=bigl(10^{k(n+1)}-1igr).
$$

The proof should replicate the four invariants used here: repeated leaf word, matching decimal value, matching expression evaluation, and persistent nontriviality.

A second direction is to find infinitely many primitive certified blocks and understand intersections of their repeated families. Primitive-word combinatorics suggests that families generated by blocks that are not powers of shorter words should have limited overlap.

A third direction is quantitative. Repetition of one block proves infinitude but not positive power-law growth. A grammar with multiple certified productions could generate many words of each length. If collisions and certificate interactions can be controlled, symbolic-dynamical entropy may yield a bound of the form $A(x)\ge x^c$ for the number $A(x)$ of orderly Friedman numbers at most $x$.

A fourth direction is bounded recognition. For fixed expression depth and bounded exponents, one may seek a finite-state transducer augmented by finitely many modular registers. The leaf-word/evaluation split developed here provides the appropriate interfaces for such a recognizer.

A fifth direction is rigidity. If an eventually affine sequence consists of repetitions of a fixed ordered digit word, its normalized limit determines a ratio such as $b/(10^k-1)$, while the exact error may determine both $k$ and the initial block. Establishing uniqueness conditions would turn asymptotic data back into decimal syntax.

## 12. Conclusion

The identity $127=-1+2^7$ is a finite arithmetic certificate with an indefinitely repeatable structure. Concatenating copies gives a sequence in which syntax and value evolve by the same affine rule. Every term is an orderly Friedman number, the terms are pairwise distinct, and their arithmetic is governed exactly by

$$
999F_n=127igl(1000^{n+1}-1igr).
$$

From this one identity follow the fixed suffix, repunit divisibility, exponential bounds, limiting constant, and exact geometric error. The construction does not solve the global classification or counting problem, but it isolates a robust principle: when a decimal block carries a self-consistent arithmetic certificate, place-value concatenation can convert one example into an infinite, explicitly analyzable family.
