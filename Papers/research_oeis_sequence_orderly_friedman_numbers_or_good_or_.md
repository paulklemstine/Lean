# Composable Certificates and an Infinite Family of Orderly Friedman Numbers

## Abstract

An orderly Friedman number is a positive integer whose decimal digits, used exactly once and in their original left-to-right order, can be equipped with arithmetic operations to form an expression equal to the integer itself. This paper gives a self-contained expression model incorporating decimal concatenation, specifies the conditions that exclude trivial certificates, and develops an explicit infinite family. The identities $-1+2^7=127$ and $7+3^6=736$ certify the orderly character of $127$ and $736$, with the latter showing that orderly Friedman numbers need not be odd. Starting from the three-digit certificate for $127$, repeated decimal concatenation produces the recurrence

$$
F_0=127,
\qquad
F_{n+1}=1000F_n+127.
$$

Every $F_n$ is shown to be orderly. The family satisfies the exact division-free closed form

$$
999F_n=127\left(1000^{n+1}-1\right),
$$

and is strictly increasing, proving the existence of infinitely many distinct orderly Friedman numbers. We give certificate-validation and family-generation algorithms, discuss their complexity, derive the asymptotic scale $F_n\sim(127/999)1000^{n+1}$, and explain how composable blocks suggest a broader program for counting and searching for orderly Friedman numbers.

## 1. Introduction

Friedman numbers turn decimal notation into raw material for arithmetic self-description. In the broad version of the problem, the digits of an integer are used to build an expression equal to that integer, often with considerable freedom in their arrangement. The orderly variant imposes a severe syntactic constraint: digits must occur in precisely the order in which they appear in the original numeral. This restriction changes both the search problem and the structure of proofs. A candidate identity must simultaneously satisfy an arithmetic equation and preserve a word in the decimal alphabet.

For example,

$$
-1+2^7=127
$$

is an orderly certificate because its visible digits, read left to right, are $1,2,7$. Likewise,

$$
7+3^6=736
$$

uses $7,3,6$ in order and evaluates correctly. These identities are more than isolated curiosities. The first is a composable three-digit block: copies of its certificate can be joined by decimal concatenation to produce certificates for $127127$, $127127127$, and so on.

The purpose of this paper is to formulate this composition cleanly and establish four concrete results:

1. $127$ has the orderly certificate $-1+2^7$.
2. $736$ has the orderly certificate $7+3^6$, disproving the claim that every orderly Friedman number is odd.
3. Repeating the certified block $127$ gives an orderly Friedman number for every positive number of repetitions.
4. The resulting sequence has an exact closed form and is strictly increasing, hence supplies infinitely many distinct examples.

The construction is deliberately explicit. It avoids reliance on a database search or an unproved pattern inferred from initial terms. Each member comes with a canonical certificate assembled from copies of one fixed expression.

## 2. Expression model and definitions

### 2.1 Decimal words

A **decimal word** is a finite list of digits $d_1,d_2,\ldots,d_m$, where each $d_i$ belongs to $\{0,1,\ldots,9\}$. Its decimal value is

$$
\operatorname{Dec}(d_1,\ldots,d_m)
=
\sum_{i=1}^{m}d_i10^{m-i}.
$$

The empty word is assigned value $0$. Leading zeros may occur in a word, although the principal examples below have none.

The fundamental concatenation identity is the following.

### Lemma 2.1: Decimal concatenation

If $u$ and $v$ are decimal words and $|v|$ denotes the length of $v$, then

$$
\operatorname{Dec}(uv)
=
\operatorname{Dec}(u)10^{|v|}+\operatorname{Dec}(v),
$$

where $uv$ is the word obtained by appending $v$ to $u$.

**Proof sketch.** Expand the defining sum for $\operatorname{Dec}(uv)$. Every digit from $u$ acquires $|v|$ additional positions to its right and therefore contributes its old place value multiplied by $10^{|v|}$. The digits from $v$ retain their original place values. Summing the two portions gives the formula. Equivalently, one may induct on the length of $u$.

### 2.2 Arithmetic expressions and leaves

We consider expressions generated from decimal digits by the following operations:

- a single digit;
- unary negation;
- addition;
- multiplication;
- exponentiation by a nonnegative integer whose decimal digits are part of the written expression; and
- decimal concatenation.

Every expression has a **leaf word**, obtained by reading all displayed decimal digits from left to right while ignoring parentheses and operation symbols. Thus the leaf word of $-1+2^7$ is $(1,2,7)$, and that of $7+3^6$ is $(7,3,6)$.

Every expression also has an integer value, defined by the usual arithmetic rules. If expressions $E$ and $G$ are concatenated and the right expression occupies $k$ decimal positions, then

$$
\operatorname{val}(E\Vert_k G)
=
10^k\operatorname{val}(E)+\operatorname{val}(G).
$$

The notation records the width $k$ because zero-padding is significant in decimal concatenation. A concatenation is **well formed** when $k$ equals the length of the leaf word of its right operand and both subexpressions are themselves well formed. Digits are well formed; negation and exponentiation preserve well-formedness; addition and multiplication are well formed exactly when both operands are.

This model treats the decimal notation of an exponent as part of the digit supply. In the applications here all exponents are single digits, so no ambiguity arises. A richer grammar could allow an arbitrary expression as exponent, but that extension is not needed for the results below.

### 2.3 Genuine arithmetic and orderly certificates

Concatenation alone must not count as arithmetic. Otherwise the displayed numeral, parsed as a concatenation of its own digits, would certify every positive integer. We therefore say that an expression contains **genuine arithmetic** if it uses at least one of negation, addition, multiplication, or exponentiation.

### Definition 2.2: Orderly Friedman certificate

Let $N$ be a positive integer with decimal digit word $w_N$. A well-formed expression $E$ is an **orderly Friedman certificate** for $N$ if:

1. the leaf word of $E$ is exactly $w_N$;
2. $\operatorname{val}(E)=N$; and
3. $E$ contains genuine arithmetic.

A positive integer is an **orderly Friedman number** if it has an orderly Friedman certificate.

This definition separates three issues that are easy to conflate: preservation of digit order, correctness of decimal widths, and correctness of arithmetic value. It also excludes the vacuous certificate consisting only of the numeral itself.

## 3. Two elementary certificates

### Theorem 3.1: The number $127$ is orderly

The integer $127$ is an orderly Friedman number.

**Proof.** Consider

$$
E=-1+2^7.
$$

Its leaf word is $(1,2,7)$, which is the decimal word of $127$. Its value is

$$
-1+2^7=-1+128=127.
$$

The expression uses negation, addition, and exponentiation, so it contains genuine arithmetic. No concatenation occurs, making well-formedness immediate. Hence $E$ is an orderly certificate for $127$.

### Theorem 3.2: The number $736$ is orderly

The integer $736$ is an orderly Friedman number.

**Proof.** Use the expression

$$
E=7+3^6.
$$

Its leaf word is $(7,3,6)$ and

$$
7+3^6=7+729=736.
$$

Addition and exponentiation supply genuine arithmetic, so the certificate satisfies every requirement.

### Corollary 3.3: Parity is unrestricted

Not every orderly Friedman number is odd.

**Proof.** The orderly Friedman number $736$ is even.

This elementary counterexample is useful methodologically. Patterns suggested by a few small entries should not be elevated to structural laws without checking the full certificate rules.

## 4. Repetition of a certified block

### 4.1 The recurrent family

Define a sequence $(F_n)_{n\ge0}$ by

$$
F_0=127,
\qquad
F_{n+1}=1000F_n+127.
$$

The first values are

$$
127,\quad
127127,\quad
127127127,\quad
127127127127.
$$

Since multiplication by $1000$ shifts a decimal numeral three places left, the recurrence appends one copy of $127$ at each step.

Let $C$ denote the expression $-1+2^7$. Define certificate expressions recursively by

$$
R_0=C,
\qquad
R_{n+1}=R_n\Vert_3 C.
$$

Thus $R_n$ consists of $n+1$ copies of $C$, joined by width-three concatenations.

### Lemma 4.1: Leaf structure

For every $n\ge0$, the leaf word of $R_n$ is the concatenation of $n+1$ copies of $(1,2,7)$.

**Proof sketch.** The assertion is immediate for $R_0=C$. If it holds for $R_n$, then $R_{n+1}$ appends one copy of $C$, whose leaf word is $(1,2,7)$. Hence the number of blocks rises from $n+1$ to $n+2$. Induction proves the claim.

### Lemma 4.2: Well-formedness

For every $n\ge0$, the expression $R_n$ is well formed.

**Proof sketch.** The base expression $C$ contains no concatenation. At the inductive step, both $R_n$ and $C$ are well formed, and the right operand $C$ has exactly three leaves. Therefore the recorded width $3$ is correct.

### Lemma 4.3: Evaluation

For every $n\ge0$,

$$
\operatorname{val}(R_n)=F_n.
$$

**Proof.** For $n=0$, both values are $127$. Assuming the equality at $n$, the definition of width-three concatenation gives

$$
\operatorname{val}(R_{n+1})
=1000\operatorname{val}(R_n)+\operatorname{val}(C)
=1000F_n+127
=F_{n+1}.
$$

The result follows by induction.

### Lemma 4.4: Decimal value of the leaf word

For every $n\ge0$, the decimal value of the leaf word of $R_n$ is $F_n$.

**Proof sketch.** At $n=0$, the leaf word $(1,2,7)$ has value $127$. At the next step, three leaves are appended. Lemma 2.1 therefore multiplies the previous decimal value by $10^3=1000$ and adds $127$. This is exactly the recurrence defining $F_{n+1}$.

### Theorem 4.5: Infinite block-family theorem

For every integer $n\ge0$, $F_n$ is an orderly Friedman number.

**Proof.** Use $R_n$ as the certificate. Lemma 4.2 gives well-formedness. Lemma 4.1 identifies its leaves as the decimal digits of $n+1$ consecutive copies of $127$, while Lemma 4.4 says that this word represents $F_n$. Lemma 4.3 gives the same value arithmetically. Finally, every $R_n$ contains the genuine arithmetic operations already present in each copy of $C$. Thus all certificate conditions hold.

The theorem is uniform and constructive: given $n$, the proof prescribes both the integer and a certificate for it.

## 5. Exact formula and growth

### Theorem 5.1: Division-free closed form

For every integer $n\ge0$,

$$
999F_n=127\left(1000^{n+1}-1\right).
$$

**Proof.** At $n=0$,

$$
999F_0=999\cdot127=127(1000-1).
$$

Suppose the identity holds for $n$. Then

$$
\begin{aligned}
999F_{n+1}
&=999(1000F_n+127)\\
&=1000(999F_n)+999\cdot127\\
&=1000\cdot127(1000^{n+1}-1)+999\cdot127\\
&=127(1000^{n+2}-1000+999)\\
&=127(1000^{n+2}-1).
\end{aligned}
$$

This is the desired statement at $n+1$.

### Corollary 5.2: Geometric-sum form

For every $n\ge0$,

$$
F_n
=127\sum_{j=0}^{n}1000^j
=\frac{127(1000^{n+1}-1)}{999}.
$$

**Proof sketch.** Iterating the recurrence yields the finite geometric sum. Multiplying that sum by $999=1000-1$ causes all intermediate powers to cancel, recovering Theorem 5.1. Since $1000^{n+1}-1$ is divisible by $999$, the quotient is an integer.

### Theorem 5.3: Strict growth

The sequence $(F_n)_{n\ge0}$ is strictly increasing.

**Proof.** Every $F_n$ is positive, and

$$
F_{n+1}-F_n
=999F_n+127>0.
$$

Hence $F_{n+1}>F_n$ for every $n$.

### Corollary 5.4: Infinitude

There are infinitely many distinct orderly Friedman numbers.

**Proof.** Theorem 4.5 says every $F_n$ is orderly. Theorem 5.3 says no two terms coincide. Since there are infinitely many indices, there are infinitely many distinct orderly Friedman numbers.

### Corollary 5.5: Asymptotic scale

As $n\to\infty$,

$$
F_n\sim\frac{127}{999}1000^{n+1}.
$$

More precisely,

$$
\frac{F_n}{1000^{n+1}}
=
\frac{127}{999}\left(1-1000^{-(n+1)}\right)
\longrightarrow
\frac{127}{999}.
$$

The family therefore has exponential growth. Its consecutive ratio also satisfies

$$
\frac{F_{n+1}}{F_n}=1000+\frac{127}{F_n}\longrightarrow1000.
$$

The limiting ratio reflects the addition of a fixed three-digit block at each step.

## 6. Algorithms

### 6.1 Certificate validation

A general validator receives a proposed integer $N$ and an expression tree $E$. A postorder traversal computes four pieces of data for each subtree:

1. its leaf word;
2. its integer value;
3. whether all concatenations are width-correct; and
4. whether genuine arithmetic occurs.

At a digit, the leaf word has length one and the value is that digit. Unary and binary arithmetic nodes combine child values according to the chosen operation and concatenate their leaf words in syntactic order. At a concatenation node $A\Vert_k B$, the validator checks $k=|\operatorname{leaves}(B)|$ and computes

$$
10^k\operatorname{val}(A)+\operatorname{val}(B).
$$

The final certificate is accepted precisely when it is well formed, its leaf word equals the canonical decimal word of $N$, its value equals $N$, and its arithmetic flag is true.

If the tree has $s$ nodes and values fit in fixed-size machine words, traversal takes $O(s)$ time and $O(h)$ call-stack space, where $h$ is the tree height. With arbitrary-precision integers, arithmetic cost depends on operand length; leaf collection should use a buffer or rope to avoid quadratic copying.

### 6.2 Recurrent generation

The family can be generated without constructing expression trees.

**Input:** a nonnegative integer $m$.

**Output:** $F_0,F_1,\ldots,F_m$.

**Procedure:** initialize $x\leftarrow127$; output $x$; repeat $m$ times: set $x\leftarrow1000x+127$ and output $x$.

There are $m$ recurrence steps. The final integer has $3(m+1)$ decimal digits. Under a digit-cost model, multiplying by $1000$ is a shift and adding $127$ is linear only in the short carry chain, so the overall practical cost is proportional to the total amount of output, $O(m^2)$ digit writes if every prefix is printed and $O(m)$ storage for the largest term. If only $F_m$ is required, direct creation by repeating the string “127” is also linear in the output length.

### 6.3 Closed-form cross-check

For testing, one may compute both

$$
F_n\quad\text{by recurrence}
$$

and

$$
Q_n=\frac{127(1000^{n+1}-1)}{999}
$$

by integer exponentiation and exact division, then compare them. Binary exponentiation uses $O(\log n)$ large-integer multiplications, though the operands themselves have $O(n)$ digits. This is useful as an independent numerical realization of the same theorem.

## 7. General block principle

The repeated-$127$ family exemplifies a broader mechanism. Let $B$ be a positive $d$-digit integer possessing an orderly certificate $C_B$ whose leaf word is exactly the $d$ digits of $B$. Define

$$
G_0=B,
\qquad
G_{n+1}=10^dG_n+B.
$$

By joining copies of $C_B$ with width-$d$ concatenation, one obtains the following conditional theorem.

### Theorem 7.1: Repetition principle for certified blocks

Suppose a $d$-digit positive integer $B$ has a well-formed orderly certificate containing genuine arithmetic. Then every number formed by writing $n+1$ copies of the decimal block $B$ consecutively is an orderly Friedman number. These numbers satisfy

$$
(10^d-1)G_n=B\left(10^{d(n+1)}-1\right)
$$

and form a strictly increasing sequence.

**Proof sketch.** Repeat the arguments of Sections 4 and 5 with $1000$ replaced by $10^d$ and $127$ replaced by $B$. The leaf word appends one $d$-digit block per step; well-formedness follows from the width $d$; evaluation follows the recurrence; and genuine arithmetic remains inside each copy. The geometric identity follows by induction. Finally,

$$
G_{n+1}-G_n=(10^d-1)G_n+B>0.
$$

The theorem explains why a short certificate can have disproportionate consequences. It is not merely one solution but a reusable component. Different certified blocks may yield different infinite subfamilies, potentially overlapping but often distinguishable by decimal structure.

## 8. Counting consequences

Let $A(X)$ denote the number of orderly Friedman numbers not exceeding $X$. The $127$ family gives a direct lower bound. By the closed form, $F_n\le X$ is equivalent to

$$
1000^{n+1}
\le
1+\frac{999X}{127}.
$$

Thus every integer $n\ge0$ satisfying

$$
n+1
\le
\log_{1000}\left(1+\frac{999X}{127}\right)
$$

contributes a distinct orderly Friedman number at most $X$. Consequently, for $X\ge127$,

$$
A(X)
\ge
\left\lfloor
\log_{1000}\left(1+\frac{999X}{127}
ight)
\right\rfloor.
$$

This lower bound is logarithmic. It proves infinitude but not positive density, nor even polynomial growth of the counting function. Several independent block families would improve the constant and might reveal richer combinatorial closure operations. More substantial growth would require certificates that can be combined in branching rather than purely repetitive ways.

## 9. Data quality and falsified conjectures

Three observations clarify what the present results do and do not establish.

First, the parity conjecture “every orderly Friedman number is odd” is false by Theorem 3.2.

Second, an advertised list ending in $14641,155$ is not strictly increasing as written, because $155<14641$. This may signal a truncated or transcribed term rather than a mathematical phenomenon. Any computational study should preserve original data while flagging such defects rather than silently sorting or repairing them.

Third, the claim that orderly Friedman numbers are only sporadic is incompatible with Corollary 5.4. Nevertheless, “infinitely many” is not synonymous with “common.” The repeated-block family is exponentially spaced, so by itself it occupies a zero proportion of the positive integers. Determining the true density or order of growth of $A(X)$ remains open within this framework.

## 10. Applications and broader connections

Although motivated by recreational number theory, the construction illustrates several general ideas.

**Syntax-directed evaluation.** A certificate carries both a word and a value. Validation resembles parsing an arithmetic language while preserving source order, a standard concern in compilers and symbolic algebra.

**Composable witnesses.** A local identity can be packaged so that a structure-preserving operation combines copies into larger witnesses. Similar strategies appear in automata, tilings, coding constructions, and inductively generated combinatorial classes.

**Exact arithmetic testing.** The recurrence and closed form provide two independent algorithms for the same integers. Comparing them is a useful pattern in reliable numerical software: derive one value operationally and another algebraically.

**Self-reference without paradox.** The numeral supplies symbols used to reconstruct its own value, but the process is finite and explicit. This places Friedman phenomena among benign forms of self-description, alongside self-enumerating sentences and digit identities.

**Search-space pruning.** Order preservation sharply reduces expression search. A dynamic program can split a digit interval into consecutive subintervals, compute attainable values for each, and combine them. The interval property follows precisely because leaves may not be permuted.

## 11. Future work

A fuller theory should broaden both grammar and enumeration.

First, one may add factorial, roots, division under exactness conditions, and arbitrary exponent expressions. Each operation requires a precise domain convention. Roots, for example, must specify whether only exact integer roots are allowed; division must avoid undefined denominators and decide whether intermediate rational values are permitted.

Second, a total parser and evaluator can connect printed expressions to the abstract certificate conditions. Such a parser should prove, mathematically, that successful parsing preserves the left-to-right leaf word and that evaluation agrees with the declarative semantics.

Third, bounded certificate search can be organized by intervals of the digit string. For each interval, store attainable values together with witness expressions and arithmetic flags. Combining adjacent intervals respects order automatically. Bounds on exponent size and intermediate magnitude are necessary to make the search finite.

Fourth, suspicious supplied data should be investigated. In particular, a terminal $155$ after $14641$ may be a truncated entry. A reproducible bounded search could determine whether $155$ itself has a certificate under the chosen grammar and compare that finding with plausible longer completions.

Fifth, multiple repetition blocks and mixed-block grammars may strengthen lower bounds for $A(X)$. If two compatible blocks can be chosen independently at each stage while preserving certification, the number of certified words of a given length could grow exponentially in the number of blocks, converting a logarithmic counting lower bound into a power-law bound in $X$.

Finally, asymptotic questions remain. The present exact identity completely describes one family, but not the full set of orderly Friedman numbers. Natural targets include upper and lower bounds for $A(X)$, the distribution of digit lengths, parity frequencies, and the effect of enlarging or restricting the operation set.

## 12. Conclusion

The identity

$$
-1+2^7=127
$$

is a compact arithmetic certificate whose digits are already in proper order. Treating it as a repeatable decimal block yields the sequence

$$
F_0=127,
\qquad
F_{n+1}=1000F_n+127.
$$

Every term is an orderly Friedman number, and

$$
999F_n=127(1000^{n+1}-1).
$$

The sequence is strictly increasing, so it establishes infinitely many distinct examples. The companion identity $7+3^6=736$ shows that even values occur. Together, these results replace several tempting empirical impressions with exact statements: orderliness does not force oddness, orderly examples are not merely finite curiosities, and a simple compositional mechanism accounts for an explicit exponentially growing family.

The larger lesson is structural. Once certificate syntax, decimal width, and arithmetic value are separated cleanly, concatenation becomes a theorem-producing operation. A single three-digit self-description can then be amplified without limit.
