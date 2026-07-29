# Exact Complete-Period Formulas for Character-Twisted Power Sums Modulo Four

**Aristotle**  
**July 29, 2026**

## Abstract

Let $\chi_4$ denote the primitive quadratic character modulo four, defined by $\chi_4(a)=1$ for $a\equiv1\pmod4$, $\chi_4(a)=-1$ for $a\equiv3\pmod4$, and $\chi_4(a)=0$ for even $a$. We study the finite twisted power sums

$$
S_k(m,x)=\sum_{a=1}^{m}\chi_4(a)(x+a)^k,
$$

where $k,m$ are nonnegative integers and $x$ is an integer. We establish the append and translation identities that govern these sums and obtain exact complete-period evaluations in degrees one and two:

$$
S_1(4q,x)=-2q,
\qquad
S_2(4q,x)=-4q(x+2q).
$$

The first identity is independent of $x$; the second yields a complete sign classification around the threshold $x=-2q$. As Diophantine consequences, for every positive $q$ and every even exponent $n$, the linear equation $S_1(4q,x)=y^n$ has no integral solutions, while the quadratic equation $S_2(4q,x)=y^n$ has no integral solutions in the range $x>-2q$. We give direct blockwise proofs, constant-time evaluation algorithms, numerical examples, and a precise account of how these elementary results fit into the broader study of character-twisted analogues of Schäffer-type equations.

## 1. Introduction

Power sums of consecutive integers are classical objects at the intersection of algebra, number theory, and Diophantine analysis. One begins with an expression such as

$$
(x+1)^k+(x+2)^k+\cdots+(x+m)^k
$$

and asks when it can equal a perfect power $y^n$. Character twisting enriches the problem by assigning periodic arithmetic weights to the summands. If $\chi$ is a Dirichlet character, the corresponding equation is

$$
\sum_{a=1}^{m}\chi(a)(x+a)^k=y^n.
$$

The zeros of $\chi$ remove indices that are not coprime to its conductor, while its nonzero values introduce oscillation. The resulting cancellation can make the twisted problem structurally different from the untwisted one.

This paper treats the primitive quadratic character of conductor four, the simplest real nonprincipal character. Its pattern is

$$
1,0,-1,0,1,0,-1,0,\ldots.
$$

We focus on lengths divisible by four, so that the summation interval consists of complete character periods. For degrees one and two, each period can be evaluated explicitly. Summing these block contributions produces closed forms from which perfect-power exclusions follow by sign.

The scope is deliberately exact and concrete. We do not claim a density-one result for arbitrary primitive quadratic characters, nor do we invoke irreducibility of generalized Bernoulli polynomials. Instead, we prove unconditional statements for one character in low degrees. These results provide a transparent model of the mechanisms—periodicity, cancellation, polynomial compression, and sign obstruction—that underlie more general character-twisted Diophantine equations.

The principal conclusions are as follows.

1. Over $q$ complete periods, the degree-one sum is exactly $-2q$, independently of $x$.
2. Over the same interval, the degree-two sum factors as $-4q(x+2q)$.
3. A negative integer cannot be an even power. Hence the linear equation has no solutions for positive $q$ and even $n$, while the quadratic equation has no solutions for even $n$ whenever $x>-2q$.
4. The closed forms lead to constant-time evaluation and furnish immediate consistency checks against direct summation.

## 2. Definitions and elementary structure

### 2.1. The quadratic character modulo four

**Definition 2.1 (Quadratic character modulo four).** For a positive integer $a$, define

$$
\chi_4(a)=
\begin{cases}
1,&a\equiv1\pmod4,\\
-1,&a\equiv3\pmod4,\\
0,&a\equiv0\pmod4\text{ or }a\equiv2\pmod4.
\end{cases}
$$

This function is periodic with period four. More explicitly, for every nonnegative integer $j$,

$$
\chi_4(4j+1)=1,
\quad \chi_4(4j+2)=0,
\quad \chi_4(4j+3)=-1,
\quad \chi_4(4j+4)=0.
$$

It is the primitive quadratic Dirichlet character of conductor four. Only its displayed residue-class values and periodicity are needed below.

**Definition 2.2 (Finite character-twisted power sum).** Let $k,m$ be nonnegative integers and $x$ an integer. Define

$$
S_k(m,x)=\sum_{a=1}^{m}\chi_4(a)(x+a)^k.
$$

The empty sum is $S_k(0,x)=0$. The use of integer $x$ allows both positive and negative translations, which is important for the sign boundary in degree two.

### 2.2. Append and translation laws

The following identities hold for any integer-valued weight function, not only $\chi_4$.

**Lemma 2.3 (Append recurrence).** If $w$ is any integer-valued function on the positive integers, and

$$
T_k(m,x)=\sum_{a=1}^{m}w(a)(x+a)^k,
$$

then

$$
T_k(m+1,x)=T_k(m,x)+w(m+1)(x+m+1)^k.
$$

**Proof sketch.** Split the sum indexed by $1\le a\le m+1$ into the first $m$ terms and the final term $a=m+1$. No property of $w$ is required. $\square$

**Lemma 2.4 (Translation identity).** For every integer $t$,

$$
T_k(m,x+t)=\sum_{a=1}^{m}w(a)(x+(t+a))^k.
$$

**Proof sketch.** In each summand, associativity of integer addition gives $(x+t)+a=x+(t+a)$. $\square$

These lemmas supply useful implementation checks, but complete-period grouping is the decisive tool for the exact evaluations.

## 3. Degree-one complete-period evaluation

Consider one period beginning at $4j+1$. By Definition 2.1, its weighted linear contribution is

$$
\begin{aligned}
&\chi_4(4j+1)(x+4j+1)
+\chi_4(4j+2)(x+4j+2)\\
&\quad+\chi_4(4j+3)(x+4j+3)
+\chi_4(4j+4)(x+4j+4).
\end{aligned}
$$

Substitution of the four character values reduces this expression to

$$
(x+4j+1)-(x+4j+3)=-2.
$$

This proves the local statement.

**Lemma 3.1 (Linear block lemma).** For every nonnegative integer $j$ and every integer $x$, a complete period contributes $-2$ to the degree-one twisted sum:

$$
\sum_{r=1}^{4}\chi_4(4j+r)(x+4j+r)=-2.
$$

**Proof sketch.** The terms with $r=2$ and $r=4$ vanish. The remaining terms have coefficients $1$ and $-1$, and their difference is $-2$. $\square$

Summing the block identity yields the exact formula.

**Theorem 3.2 (Linear Complete-Period Theorem).** For every nonnegative integer $q$ and every integer $x$,

$$
S_1(4q,x)=-2q.
$$

**Proof sketch.** Partition the indices $1,2,\ldots,4q$ into $q$ disjoint blocks

$$
\{4j+1,4j+2,4j+3,4j+4\},
\qquad 0\le j<q.
$$

By Lemma 3.1, each block contributes $-2$. Therefore their total contribution is $q(-2)=-2q$. The case $q=0$ agrees with the empty-sum convention. $\square$

A second proof proceeds by induction on $q$: appending four terms and applying the character pattern changes the sum by $-2$. The block proof makes the cancellation more visible.

**Corollary 3.3 (Translation invariance in degree one).** For every nonnegative integer $q$ and all integers $x,t$,

$$
S_1(4q,x+t)=S_1(4q,x).
$$

**Proof sketch.** Both sides equal $-2q$ by Theorem 3.2. $\square$

This independence of $x$ may also be understood by expanding each linear term. The coefficient of $x$ is the character sum over complete periods, and within each period it is $1+0-1+0=0$.

### 3.1. Exclusion of even powers

**Lemma 3.4 (Nonnegativity of even powers).** Let $n$ be a nonnegative even integer and $y$ an integer. Then $y^n\ge0$.

**Proof sketch.** Write $n=2r$. Then

$$
y^n=y^{2r}=(y^r)^2\ge0.
$$

$\square$

**Theorem 3.5 (Linear Even-Power Exclusion Theorem).** Let $q$ be a positive integer, let $n$ be an even nonnegative integer, and let $x,y$ be integers. Then

$$
S_1(4q,x)\ne y^n.
$$

In particular, this holds for every even exponent $n\ge2$ relevant to a perfect-power equation.

**Proof sketch.** By Theorem 3.2, $S_1(4q,x)=-2q<0$ because $q>0$. By Lemma 3.4, $y^n\ge0$. A negative integer cannot equal a nonnegative integer. $\square$

The exclusion is uniform in $x$ and $y$. It also covers all positive multiples $m=4q$ of the conductor, not merely a density-one subset, provided the degree is one and the exponent is even.

## 4. Degree-two complete-period evaluation

For degree two, the $j$th complete period contributes

$$
(x+4j+1)^2-(x+4j+3)^2.
$$

The difference-of-squares identity gives

$$
\begin{aligned}
(x+4j+1)^2-(x+4j+3)^2
&=((x+4j+1)-(x+4j+3))\\
&\quad\cdot((x+4j+1)+(x+4j+3))\\
&=(-2)(2x+8j+4)\\
&=-4(x+4j+2).
\end{aligned}
$$

**Lemma 4.1 (Quadratic block lemma).** For every nonnegative integer $j$ and every integer $x$,

$$
\sum_{r=1}^{4}\chi_4(4j+r)(x+4j+r)^2=-4(x+4j+2).
$$

**Proof sketch.** The even-indexed terms vanish. Apply the difference-of-squares identity to the two remaining odd-indexed terms. $\square$

**Theorem 4.2 (Quadratic Complete-Period Theorem).** For every nonnegative integer $q$ and every integer $x$,

$$
S_2(4q,x)=-4q(x+2q).
$$

**Proof sketch.** Sum Lemma 4.1 over $j=0,1,\ldots,q-1$:

$$
S_2(4q,x)=-4\sum_{j=0}^{q-1}(x+4j+2).
$$

The inner sum is an arithmetic progression:

$$
\begin{aligned}
\sum_{j=0}^{q-1}(x+4j+2)
&=q(x+2)+4\sum_{j=0}^{q-1}j\\
&=q(x+2)+4\frac{q(q-1)}2\\
&=qx+2q+2q(q-1)\\
&=qx+2q^2\\
&=q(x+2q).
\end{aligned}
$$

Multiplication by $-4$ gives the result. When $q=0$, both sides are zero. $\square$

### 4.1. Sign classification

The factorization in Theorem 4.2 immediately determines the sign when $q>0$.

**Corollary 4.3 (Quadratic sign trichotomy).** Let $q$ be a positive integer and $x$ an integer. Then:

1. if $x>-2q$, then $S_2(4q,x)<0$;
2. if $x=-2q$, then $S_2(4q,x)=0$;
3. if $x<-2q$, then $S_2(4q,x)>0$.

**Proof sketch.** Since $q>0$, the factor $-4q$ is strictly negative. The sign of $S_2(4q,x)$ is therefore opposite to the sign of $x+2q$. $\square$

The threshold is sharp. At $x=-2q$, the value is $0$, which equals $0^n$ for every positive $n$. Thus no nonexistence theorem valid for all integers $y$ can include the boundary point. For $x<-2q$, positivity alone does not decide whether the sum is an even power.

**Theorem 4.4 (Quadratic Even-Power Exclusion Theorem).** Let $q$ be a positive integer, let $n$ be an even nonnegative integer, and let $x,y$ be integers. If $x>-2q$, then

$$
S_2(4q,x)\ne y^n.
$$

In particular, this excludes all even perfect-power exponents $n\ge2$ in the stated range.

**Proof sketch.** Corollary 4.3 gives $S_2(4q,x)<0$, whereas Lemma 3.4 gives $y^n\ge0$. Hence equality is impossible. $\square$

## 5. Numerical consequences and validation examples

The exact formulas generate numerical examples without term-by-term expansion.

**Corollary 5.1 (First four linear period values).** For every integer $x$,

$$
\begin{aligned}
S_1(4,x)&=-2, & S_1(8,x)&=-4,\\
S_1(12,x)&=-6, & S_1(16,x)&=-8.
\end{aligned}
$$

**Proof sketch.** Substitute $q=1,2,3,4$ into Theorem 3.2. $\square$

**Corollary 5.2 (First four quadratic values at the origin).** At $x=0$,

$$
\begin{aligned}
S_2(4,0)&=-8, & S_2(8,0)&=-32,\\
S_2(12,0)&=-72, & S_2(16,0)&=-128.
\end{aligned}
$$

**Proof sketch.** Setting $x=0$ in Theorem 4.2 gives

$$
S_2(4q,0)=-8q^2.
$$

Now substitute $q=1,2,3,4$. $\square$

Every value in Corollaries 5.1 and 5.2 is negative. Hence none equals an even power of an integer. These finite examples illustrate, rather than establish, the general theorems.

A useful additional example shows the quadratic sign transition. Let $q=3$, so $m=12$. Then

$$
S_2(12,x)=-12(x+6).
$$

Thus $S_2(12,-5)=-12$, $S_2(12,-6)=0$, and $S_2(12,-7)=12$. The sign flips exactly at $x=-6=-2q$.

## 6. Algorithms

### 6.1. Direct evaluation

The definition itself gives a general-purpose algorithm for any degree $k$ and length $m$.

**Algorithm 6.1 (Direct twisted summation).** Given integers $k,m,x$ with $k,m\ge0$:

1. initialize $s=0$;
2. for $a=1,\ldots,m$, determine $a\bmod4$;
3. add $(x+a)^k$ if $a\equiv1\pmod4$;
4. subtract $(x+a)^k$ if $a\equiv3\pmod4$;
5. do nothing if $a$ is even;
6. return $s$.

With ordinary integer arithmetic, this uses $O(m)$ character evaluations and additions. Exponentiation by repeated squaring takes $O(\log k)$ multiplications per nonzero term, so a coarse arithmetic-operation bound is $O(m\log k)$. Bit complexity additionally depends on the sizes of $x$, $m$, and the resulting powers.

### 6.2. Closed-form evaluation in degree one

**Algorithm 6.2 (Linear complete-period evaluator).** Given $q\ge0$ and integer $x$, return $-2q$.

The input $x$ is accepted to match the mathematical sum but does not affect the output. The algorithm performs a constant number of arithmetic operations, hence has $O(1)$ arithmetic complexity. Its bit complexity is quasi-linear in the bit length of $q$ under standard fast-integer models, or simply linear for multiplication by the fixed constant $2$.

### 6.3. Closed-form evaluation in degree two

**Algorithm 6.3 (Quadratic complete-period evaluator).** Given $q\ge0$ and integer $x$:

1. compute $u=x+2q$;
2. return $-4qu$.

This also takes $O(1)$ arithmetic operations. Its bit complexity is governed by one general integer multiplication involving numbers of size comparable to $q$ and $x+2q$.

### 6.4. Even-power obstruction certificate

For degree one and positive $q$, the value $-2q$ itself certifies impossibility: it is negative. For degree two, the data $q>0$ and $x>-2q$ certify that both $q$ and $x+2q$ are positive, so $-4q(x+2q)<0$. In either case, an even power is nonnegative.

This certificate-based viewpoint avoids searching over $y$. Once negativity is established, every integer $y$ is ruled out simultaneously.

## 7. Interpretation through periodic cancellation

The modulo-four character acts as a finite-difference mask. On a block, it evaluates a polynomial $P$ at two odd positions and subtracts:

$$
P(4j+1)-P(4j+3).
$$

For $P(t)=x+t$, this difference is constant. For $P(t)=(x+t)^2$, it is affine in $j$. More generally, if $P$ has degree $k$, the difference $P(t)-P(t+2)$ has degree at most $k-1$. Summing over $q$ blocks then produces a polynomial in $q$ whose degree is at most $k$. This degree reduction explains why the low-degree cases simplify so strongly.

The cancellation of the leading behavior is a consequence of the zero mean of the character over one period:

$$
\chi_4(1)+\chi_4(2)+\chi_4(3)+\chi_4(4)=0.
$$

In degree one, that cancellation removes all dependence on $x$. In degree two, expansion gives

$$
(x+a)^2=x^2+2ax+a^2.
$$

The $x^2$ coefficient vanishes over complete periods, leaving only linear dependence on $x$. This is consistent with the factor $x+2q$ in Theorem 4.2.

## 8. Relation to character-twisted Schäffer equations

A general character-twisted Schäffer-type equation takes the form

$$
\sum_{a=1}^{m}\chi(a)(x+a)^k=y^n,
\qquad n\ge2,
$$

where $\chi$ is a primitive quadratic character of conductor $f$. For lengths $m$ divisible by $f$, periodicity makes complete-period analysis natural. In higher degrees and for general conductors, generalized Bernoulli polynomials encode finite power sums and can transform the left side into a polynomial expression.

The present results establish only the following special regime:

- the character is $\chi_4$;
- the length is $m=4q$;
- the degrees are $k=1$ and $k=2$;
- the target exponent is even;
- in degree two, the translation satisfies $x>-2q$.

Within that regime, the conclusions are exact and unconditional. They should not be conflated with a statement that, under irreducibility assumptions, almost all conductor multiples admit no solutions for arbitrary exponents. Odd powers can be negative, so the sign obstruction used here does not address odd $n$. Likewise, when $x<-2q$ in degree two, the sum is positive and further arithmetic analysis is required.

Nevertheless, the example displays a useful general pipeline:

1. identify the period of the character;
2. partition the sum into complete periods;
3. evaluate one block as a polynomial in the block index;
4. sum the resulting polynomial;
5. factor the closed form;
6. apply sign, divisibility, or valuation arguments to exclude perfect powers.

## 9. Applications

### 9.1. Fast exact computation

For large $q$, direct summation over $4q$ terms is unnecessary in degrees one and two. The exact formulas reduce evaluation to constant-time arithmetic. This is useful when such sums appear inside a larger search or when one needs exact values with arbitrary-precision integers.

### 9.2. Search-space pruning

Suppose a program searches for solutions to $S_k(4q,x)=y^n$. For $k=1$, every case with $q>0$ and even $n$ can be discarded before considering $x$ or $y$. For $k=2$, every case with $q>0$, even $n$, and $x>-2q$ can likewise be discarded. Such symbolic pruning is stronger than any finite numerical bound.

### 9.3. Regression tests for general implementations

A generic implementation of twisted power sums should reproduce the formulas

$$
S_1(4q,x)=-2q,
\qquad
S_2(4q,x)=-4q(x+2q).
$$

Testing these identities over varied positive, zero, and negative values of $x$ supplies a robust check of indexing, residue classes, and sign conventions.

### 9.4. A model for higher-degree block analysis

The block method extends mechanically. For fixed $k$,

$$
(x+4j+1)^k-(x+4j+3)^k
$$

is a polynomial of degree at most $k-1$ in $x+4j$. Summing over $j$ can be handled through ordinary power-sum formulas. The resulting expressions become more complicated, but the low-degree theorems identify the essential mechanism.

## 10. Boundary phenomena and sharpness

The hypotheses in the nonexistence theorems deserve separate analysis. In the linear case, positivity of $q$ is essential. If $q=0$, then the summation interval is empty and

$$
S_1(0,x)=0=0^n
$$

for every positive exponent $n$. Once $q>0$, however, the sum is strictly negative for every integer $x$, so no further condition on the translation is required.

In the quadratic case, the condition $x>-2q$ is exactly the negativity region and cannot be replaced by $x\ge-2q$. At the endpoint,

$$
S_2(4q,-2q)=0,
$$

which is an even power when $y=0$. Thus the endpoint provides an actual family of solutions, not merely a gap in the proof. When $x<-2q$, the value becomes positive. Some positive values are visibly even powers: for example, with $q=1$ and $x=-3$,

$$
S_2(4,-3)=-4(-1)=4=2^2.
$$

Accordingly, no unconditional even-power exclusion can hold throughout the positive region. The threshold in Theorem 4.4 separates a uniformly impossible half-line from a region where solutions can occur.

Parity of the exponent is equally structural. If $n$ is odd, then $y^n$ may be negative, so negativity supplies no contradiction. For example, the linear formula asks whether $-2q$ can be an odd power. Taking $q=4$, one obtains

$$
S_1(16,x)=-8=(-2)^3
$$

for every integer $x$. Hence the restriction to even exponents cannot be removed from the linear theorem. These examples show that the assumptions are mathematically sharp for the sign-based conclusions proved here.

## 11. Limitations and future work

Several natural extensions remain.

First, one may replace $\chi_4$ with primitive quadratic characters of arbitrary conductor. Their periods contain more nonzero residues, so block contributions involve richer signed combinations.

Second, generalized Bernoulli polynomials attached to a character can organize the finite sums uniformly in $k$. Establishing the precise polynomial-difference identity would connect elementary block calculations to the standard analytic-algebraic framework.

Third, concrete irreducibility criteria for these generalized Bernoulli polynomials are needed if one wishes to derive broad perfect-power nonexistence results.

Fourth, moving from exact low-degree sign arguments to density-one assertions requires arithmetic geometry capable of controlling perfect-power values of irreducible polynomials, together with a precise treatment of natural density among multiples of a conductor.

Finally, even in the present modulo-four setting, odd exponents and the positive region $x<-2q$ in degree two remain outside the reach of sign alone. Divisibility, congruence, factorization, and valuation methods may yield additional exclusions.

## 12. Reproducible numerical protocol

The closed forms can be tested by a transparent numerical protocol that does not presuppose either theorem. Choose finite sets of values for $q$ and $x$. For each pair, generate the weights from the residue of $a$ modulo four, evaluate the defining sum term by term for $a=1,\ldots,4q$, and compare the result with the relevant formula. In degree one, compare against $-2q$; in degree two, compare against $-4q(x+2q)$.

A robust test set should include $q=0$ to check the empty sum, several positive values of $q$, and translations on both sides of the quadratic threshold. Negative translations are particularly useful because they expose errors that may remain hidden when only nonnegative inputs are sampled. For the quadratic formula, the three values $x=-2q-1$, $x=-2q$, and $x=-2q+1$ should produce a positive value, zero, and a negative value, respectively.

The protocol is a validation aid rather than a proof: a finite computation cannot establish an identity over all integers. Its role is to demonstrate the formulas, test software that implements them, and reveal the sharp boundary behavior. The blockwise arguments in Sections 3 and 4 supply the universal justification.

## 13. Conclusion

The primitive quadratic character modulo four turns complete-period power sums into rigid algebraic expressions. In degree one, every block contributes $-2$, giving

$$
S_1(4q,x)=-2q.
$$

In degree two, each block contributes an affine term whose arithmetic-progression sum factors as

$$
S_2(4q,x)=-4q(x+2q).
$$

These identities yield immediate Diophantine consequences. For positive $q$, the linear sum is always negative and hence never an even power. The quadratic sum is negative throughout the sharp range $x>-2q$ and is likewise excluded from being an even power there.

The argument illustrates the effectiveness of complete-period grouping: periodic character values create cancellation, cancellation lowers polynomial complexity, and factorization converts the resulting identities into global nonexistence statements. In this setting, structural algebra replaces exhaustive search.
