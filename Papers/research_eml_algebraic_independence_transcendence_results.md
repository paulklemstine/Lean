# Algebraic Independence and Transcendence of Exponential–Logarithmic Special Values

**Aristotle**  
**30 July 2026**

## Abstract

For real $a$ in the domain of the logarithm, define the exponential–logarithmic special value

$$
E(a)=e^a\log(1+a).
$$

We separate unconditional facts about these values from conjectural transcendence claims. First, $E(a)>0$ for every $a>0$, and therefore $E(a)\ne0$. Second, we prove a general algebraic lemma: if two real numbers $x$ and $y$ are algebraically independent over $\mathbb Q$, then $xy$ is transcendental over $\mathbb Q$. Consequently, algebraic independence of $e^a$ and $\log(1+a)$ is sufficient for transcendence of $E(a)$. We then study the concrete pair

$$
U=e^{\sqrt2}\log(1+\sqrt2),\qquad
V=e^{\sqrt3}\log(1+\sqrt3).
$$

Both values are unconditionally positive and nonzero. If $U$ and $V$ are algebraically independent, every rational-coefficient bivariate polynomial vanishing at $(U,V)$ is necessarily the zero polynomial. The independence hypothesis itself remains open. In particular, separate transcendence of the factors in a product does not imply transcendence of the product, so Lindemann–Weierstrass and Gelfond–Schneider cannot simply be combined to settle the proposed one-variable statement. We formulate the precise conjectures, give proof sketches for all established results, describe responsible numerical algorithms, and place the problem in the broader setting of Schanuel-type algebraic-independence questions.

## 1. Introduction

Expressions combining exponentials and logarithms occupy a delicate part of transcendental number theory. Each operation is analytically familiar, but arithmetic classification asks a different kind of question: does a resulting number satisfy a polynomial equation over $\mathbb Q$? Even when classical theorems establish transcendence for individual components, sums and products can conceal algebraic cancellations.

This paper considers the function

$$
E(a)=e^a\log(1+a),
$$

with primary attention to algebraic real inputs. A tempting argument for transcendence runs as follows: establish that $e^a$ is transcendental, establish that $\log(1+a)$ is transcendental, and conclude that their product is transcendental. The final inference is false in general. For example, $\pi$ and $1/\pi$ are transcendental, whereas their product is $1$. Any valid product argument must control the algebraic relation between the factors, not merely classify each factor separately.

Our objective is therefore twofold. We prove the unconditional and conditional statements that follow from current algebraic principles, and we isolate the genuinely open inputs without overstating what classical transcendence theorems provide. The main general result says that algebraic independence of $x$ and $y$ forces transcendence of $xy$. Applied to $e^a$ and $\log(1+a)$, this yields a rigorous sufficient condition for the desired one-variable transcendence. For the concrete inputs $\sqrt2$ and $\sqrt3$, we prove positivity and nonvanishing and formulate the exact polynomial-elimination consequence of their conjectured algebraic independence.

The distinction between theorem and conjecture is essential. Numerical experiments can evaluate special values and search bounded families of candidate polynomial relations, but no finite-precision computation can certify algebraic independence. The algorithms described below are accordingly diagnostic rather than decisional.

## 2. Algebraic preliminaries

### 2.1 Algebraic and transcendental numbers

**Definition 2.1.** A real number $z$ is **algebraic over $\mathbb Q$** if there exists a nonzero polynomial $p(T)\in\mathbb Q[T]$ such that $p(z)=0$. It is **transcendental over $\mathbb Q$** if no such polynomial exists.

Thus transcendence is the absence of every nontrivial rational polynomial relation in one variable. The definition makes no reference to decimal expansion or numerical complexity.

**Definition 2.2.** Real numbers $x_1,\ldots,x_n$ are **algebraically independent over $\mathbb Q$** if, for every polynomial $P\in\mathbb Q[X_1,\ldots,X_n]$,

$$
P(x_1,\ldots,x_n)=0
$$

implies $P=0$. Otherwise they are algebraically dependent.

For $n=1$, algebraic independence is precisely transcendence. For $n\ge2$, it is stronger than requiring each coordinate to be transcendental. The pair $(\pi,1/\pi)$ demonstrates the distinction: both coordinates are transcendental, but they satisfy $XY-1=0$.

**Definition 2.3.** Real numbers $a_1,\ldots,a_n$ are **linearly independent over $\mathbb Q$** if

$$
q_1a_1+\cdots+q_na_n=0,
\qquad q_i\in\mathbb Q,
$$

implies $q_1=\cdots=q_n=0$.

Linear independence excludes only degree-one homogeneous relations. Algebraic independence excludes polynomial relations of every degree and is much stronger.

### 2.2 The special-value function

**Definition 2.4.** For a real number $a$ with $1+a>0$, define

$$
E(a)=e^a\log(1+a),
$$

where $\log$ denotes the real natural logarithm.

The condition $1+a>0$ is the natural real-analytic domain condition. The central conjectures concern nonzero algebraic inputs in this domain. The unconditional positivity theorem will use the stronger assumption $a>0$.

### 2.3 Why separate transcendence is insufficient

The arithmetic class of a product cannot be deduced from the separate transcendence of its factors. More generally, if $t$ is any nonzero transcendental real and $c$ is any nonzero algebraic real, then $c/t$ is transcendental: if $c/t$ were algebraic, multiplying by the algebraic number $t(c/t)=c$ does not itself yield a contradiction because $t$ is transcendental, but in the special case $c=1$ and $t=\pi$, $1/\pi$ is transcendental since the reciprocal of a nonzero algebraic number is algebraic. Yet $t(c/t)=c$ is algebraic. Thus a product theorem requires joint information.

Classical theorems about exponentials of algebraic numbers or special powers do not automatically furnish that joint information for the pair $e^a$ and $\log(1+a)$. Any claim that the one-variable transcendence of $E(a)$ follows solely by multiplying two known transcendental quantities contains a logical gap.

## 3. Unconditional analytic results

We begin with statements that hold for all positive real inputs, without algebraicity assumptions.

**Theorem 3.1 (Positivity).** If $a>0$, then

$$
E(a)=e^a\log(1+a)>0.
$$

**Proof sketch.** The real exponential is strictly positive at every real argument, hence $e^a>0$. Since $a>0$, one has $1+a>1$. The natural logarithm is strictly increasing and $\log 1=0$, so $\log(1+a)>0$. The product of two positive real numbers is positive. $\square$

**Corollary 3.2 (Nonvanishing).** If $a>0$, then $E(a)\ne0$.

**Proof sketch.** A strictly positive real number cannot equal zero. $\square$

For completeness, the sign on the entire real domain can also be described.

**Proposition 3.3 (Sign classification).** For $a>-1$,

$$
E(a)
\begin{cases}
<0,&-1<a<0,\\
=0,&a=0,\\
>0,&a>0.
\end{cases}
$$

**Proof sketch.** The factor $e^a$ is always positive. The logarithm $\log(1+a)$ is negative, zero, or positive according as $1+a$ lies in $(0,1)$, equals $1$, or exceeds $1$. Multiplication by $e^a>0$ preserves this sign. $\square$

Proposition 3.3 is elementary but useful when designing numerical tests. A computed value with the wrong sign signals inadequate precision or an implementation error. It does not address algebraicity.

## 4. Algebraic independence forces product transcendence

The central algebraic result is independent of the analytic origin of the factors.

**Theorem 4.1 (Product transcendence from algebraic independence).** Let $x,y\in\mathbb R$. If $x$ and $y$ are algebraically independent over $\mathbb Q$, then $xy$ is transcendental over $\mathbb Q$.

**Proof.** Assume for contradiction that $xy$ is algebraic. Then there is a nonzero polynomial

$$
p(T)=\sum_{k=0}^{d}c_kT^k\in\mathbb Q[T]
$$

such that $p(xy)=0$. Define the bivariate polynomial

$$
Q(X,Y)=p(XY)=\sum_{k=0}^{d}c_kX^kY^k.
$$

Evaluation at $(x,y)$ gives

$$
Q(x,y)=p(xy)=0.
$$

By algebraic independence, $Q$ must be the zero polynomial. The monomials $X^kY^k$ are pairwise distinct, so every coefficient $c_k$ must be zero. Hence $p=0$, contradicting the choice of $p$. Therefore $xy$ is transcendental. $\square$

The proof can be understood as an injectivity statement. The substitution homomorphism

$$
\Phi:\mathbb Q[T]\longrightarrow\mathbb Q[X,Y],
\qquad \Phi(p)=p(XY),
$$

is injective. One explicit left inverse is obtained by substituting $X=T$ and $Y=1$, because

$$
\Phi(p)(T,1)=p(T).
$$

Therefore a polynomial relation for $xy$ lifts to a nonzero polynomial relation for $(x,y)$.

The same idea extends immediately to more factors.

**Corollary 4.2 (Finite product version).** If $x_1,\ldots,x_n$ are algebraically independent over $\mathbb Q$ and $n\ge1$, then $x_1\cdots x_n$ is transcendental over $\mathbb Q$.

**Proof sketch.** If a nonzero $p(T)$ vanished at $x_1\cdots x_n$, then

$$
P(X_1,\ldots,X_n)=p(X_1\cdots X_n)
$$

would be a nonzero multivariate polynomial vanishing at the independent tuple. Nonzeroness follows by setting $X_2=\cdots=X_n=1$. $\square$

The converse of Theorem 4.1 is false. A transcendental product does not force the factors to be algebraically independent. Thus factor independence is a sufficient condition tailored to the product argument, not a necessary characterization.

## 5. Conditional transcendence of the special values

Applying Theorem 4.1 to the two factors in Definition 2.4 gives the principal conditional statement.

**Theorem 5.1 (Conditional special-value transcendence).** Let $a$ be real with $1+a>0$. If $e^a$ and $\log(1+a)$ are algebraically independent over $\mathbb Q$, then

$$
E(a)=e^a\log(1+a)
$$

is transcendental over $\mathbb Q$.

**Proof sketch.** Set $x=e^a$ and $y=\log(1+a)$. The hypothesis is exactly the hypothesis of Theorem 4.1, whose conclusion is that $xy=E(a)$ is transcendental. $\square$

This theorem identifies a precise missing input. It is stronger to conjecture algebraic independence of the factors than merely to conjecture transcendence of their product.

**Conjecture 5.2 (One-variable special-value transcendence).** If $a$ is a nonzero algebraic real number and $1+a>0$, then $E(a)$ is transcendental over $\mathbb Q$.

**Conjecture 5.3 (Factor independence).** If $a$ is a nonzero algebraic real number and $1+a>0$, then $e^a$ and $\log(1+a)$ are algebraically independent over $\mathbb Q$.

Theorem 5.1 proves that Conjecture 5.3 implies Conjecture 5.2. The implication need not reverse. A product may be transcendental even if its factors obey a polynomial relation. It is consequently important not to blur the target conjecture with the stronger mechanism proposed to establish it.

The condition $a\ne0$ in Conjectures 5.2 and 5.3 is necessary. At $a=0$,

$$
E(0)=e^0\log 1=0,
$$

which is algebraic. The domain condition $1+a>0$ keeps the logarithm real.

## 6. The concrete square-root pair

Define

$$
U=E(\sqrt2)=e^{\sqrt2}\log(1+\sqrt2)
$$

and

$$
V=E(\sqrt3)=e^{\sqrt3}\log(1+\sqrt3).
$$

These inputs are positive algebraic numbers and are linearly independent over $\mathbb Q$. Indeed, if $q\sqrt2+r\sqrt3=0$ with $q,r\in\mathbb Q$, then, unless one coefficient is zero, squaring would imply a rational identity forcing $2q^2=3r^2$, incompatible with the parity of prime exponents in rational squares. If one coefficient is zero, so is the other.

**Theorem 6.1 (Positivity of the square-root values).** The values $U$ and $V$ satisfy

$$
U>0,\qquad V>0.
$$

**Proof sketch.** Both $\sqrt2$ and $\sqrt3$ are positive. Apply Theorem 3.1 to each input. $\square$

**Corollary 6.2 (Nonvanishing of the square-root values).** One has

$$
U\ne0,\qquad V\ne0.
$$

**Proof sketch.** Apply Corollary 3.2, or use Theorem 6.1 directly. $\square$

The main arithmetic proposal is substantially stronger.

**Conjecture 6.3 (Square-root pair independence).** The numbers $U$ and $V$ are algebraically independent over $\mathbb Q$.

The exact consequence of this conjecture is worth stating as a theorem because it clarifies the quantifiers and the burden of proof.

**Theorem 6.4 (Conditional elimination of polynomial relations).** Assume Conjecture 6.3. For every polynomial $P(X,Y)\in\mathbb Q[X,Y]$, if

$$
P(U,V)=0,
$$

then $P=0$.

**Proof sketch.** This is precisely the defining property of algebraic independence applied to the pair $(U,V)$. $\square$

The theorem is conditional; it does not establish Conjecture 6.3. In particular, finite numerical testing cannot replace its hypothesis.

## 7. Finite families and Schanuel-type expectations

The square-root pair suggests a family-level conjecture.

**Conjecture 7.1 (Finite-family special-value independence).** Let $a_1,\ldots,a_n$ be positive algebraic real numbers that are linearly independent over $\mathbb Q$. Then

$$
E(a_1),\ldots,E(a_n)
$$

are algebraically independent over $\mathbb Q$.

For $n=1$, linear independence means simply $a_1\ne0$, and the conclusion reduces to Conjecture 5.2. For $n=2$ with $a_1=\sqrt2$ and $a_2=\sqrt3$, it specializes to Conjecture 6.3.

The conjecture is Schanuel-like because it predicts algebraic independence for values built from exponentials at rationally independent algebraic arguments. The logarithmic factor $\log(1+a_i)$ introduces an additional layer. Its multiplicative coupling with $e^{a_i}$ gives a clear algebraic substitution mechanism, but no known principle allows one to infer the independence of the products from separate transcendence data alone.

A counterexample to Conjecture 7.1 would consist of explicit linearly independent positive algebraic inputs and an explicit nonzero rational multivariate polynomial vanishing at the associated special values. This falsifiability distinguishes the conjecture from vague claims of arithmetic complexity.

## 8. Computational methods and their limits

### 8.1 High-precision evaluation

A direct evaluation algorithm computes $e^a$ and $\log(1+a)$ at precision exceeding the requested output precision, multiplies them, and then reports the result. Guard digits reduce rounding error. For positive $a$, the output should be positive by Theorem 3.1.

For fixed precision $p$, the practical bit complexity depends on the multiprecision library. Fast algorithms for elementary functions are quasi-linear in $p$ up to logarithmic factors, though implementation constants and argument reduction matter. This evaluation is suitable for illustration, not arithmetic classification.

### 8.2 Bounded polynomial-relation screening

Fix a total-degree bound $d$ and coefficient bound $H$. Enumerate integer polynomials

$$
P(X,Y)=\sum_{i+j\le d}c_{ij}X^iY^j,
\qquad |c_{ij}|\le H,
$$

excluding the zero polynomial. Evaluate each $P(U,V)$ at high precision and record the smallest absolute residual.

There are

$$
N=\frac{(d+1)(d+2)}2
$$

admissible monomials and $(2H+1)^N-1$ coefficient vectors. Exhaustive enumeration is therefore exponential in $N$ and becomes infeasible rapidly. Lattice-reduction methods can search more intelligently, but a small residual remains numerical evidence rather than proof of an exact relation.

### 8.3 Positivity and nonvanishing checks

For a list of positive inputs, compute each special value and compare its sign against the theorem. This is a useful software test because it has an exact mathematical expectation. Nevertheless, a matching numerical sign is merely confirmation of the implementation on sampled inputs; the theorem itself comes from the analytic sign argument.

### 8.4 Why numerical evidence cannot certify independence

Two obstacles are fundamental. First, finite precision cannot distinguish exact zero from a sufficiently small nonzero number. Second, algebraic independence quantifies over infinitely many polynomials with no a priori degree or height bound. A search that finds no relation within $(d,H)$ establishes only that no tested candidate produced a residual detectable at the chosen precision. It does not prove that no exact relation exists.

Responsible computation should therefore report the precision, search bounds, normalization of coefficients, and observed residuals. It should avoid labels such as “verified independent.”

## 9. Applications and conceptual consequences

The product theorem is a reusable bridge from multivariate independence to one-variable transcendence. Whenever a special value decomposes as $xy$, a proof that $(x,y)$ is algebraically independent immediately excludes all algebraic values of the product. The argument extends to finite products and, with similar substitutions, to nonconstant monomials.

**Proposition 9.1 (Monomial consequence).** Let $x_1,\ldots,x_n$ be algebraically independent over $\mathbb Q$, and let $m_1,\ldots,m_n$ be nonnegative integers not all zero. Then

$$
x_1^{m_1}\cdots x_n^{m_n}
$$

is transcendental over $\mathbb Q$.

**Proof sketch.** If a nonzero $p(T)$ vanished at this monomial, substitute $T=X_1^{m_1}\cdots X_n^{m_n}$. The resulting polynomial is nonzero because distinct powers produce distinct exponent vectors, yet it vanishes at the independent tuple, a contradiction. $\square$

For the special-value problem, the principal application is diagnostic: it identifies algebraic independence of the exponential and logarithmic factors as sufficient data. This guides future theoretical work toward joint relations rather than isolated transcendence statements.

Potential connections to periods, exponential periods, and special values of analytic functions should be approached cautiously. The present results supply an algebraic reduction and elementary positivity facts; they do not establish new unconditional transcendence statements for the proposed special values. Their value lies in correctly locating the open frontier.

## 10. Discussion

Several logical distinctions organize the subject:

1. Positivity and nonvanishing are analytic and unconditional for positive inputs.
2. Transcendence of each factor separately does not control the product.
3. Algebraic independence of the factors does control the product.
4. The factor-independence conjecture is stronger than the one-variable product-transcendence conjecture.
5. The square-root pair independence statement remains open, although its consequences can be stated exactly.

The substitution $p(T)\mapsto p(XY)$ is the algebraic core. Its simplicity can obscure the strength of the hypothesis needed to use it. If $p(xy)=0$, one obtains a relation between $x$ and $y$; only algebraic independence rules out every such nonzero relation. Separate transcendence rules out merely the relations depending on one coordinate alone.

This perspective also prevents misuse of major classical results. Lindemann–Weierstrass controls exponentials of algebraic numbers in powerful ways, and Gelfond–Schneider controls certain algebraic powers. Neither theorem, without additional argument, says that an arbitrary product of two transcendental quantities is transcendental. The gap is structural, not cosmetic.

## 11. Future work

The most direct target is Conjecture 5.2: prove that $e^a\log(1+a)$ is transcendental for every nonzero algebraic real $a>-1$. A stronger route is Conjecture 5.3, the algebraic independence of its two factors. Work on this route must confront possible mixed polynomial relations rather than merely proving separate transcendence.

The concrete pair $(U,V)$ offers a sharply defined two-variable benchmark. Any progress could take the form of excluding polynomial relations in a restricted but theoretically meaningful class, obtaining transcendence-degree lower bounds under standard conjectures, or deriving the claim from a carefully stated Schanuel-type hypothesis.

At the family level, Conjecture 7.1 asks whether rational linear independence of positive algebraic inputs propagates to algebraic independence of their exponential–logarithmic values. Intermediate questions include pairwise transcendence, independence of selected factors, and conditional implications from conjectures in exponential algebra.

Computationally, improved bounded searches can identify suspicious low-height relations and test implementations. Interval arithmetic can rigorously certify that a particular polynomial evaluation is nonzero when the interval excludes zero. Even then, each certificate concerns one polynomial; no finite collection proves algebraic independence. The correct role of computation is to eliminate candidates, discover patterns, and support—not replace—theoretical arguments.

## 12. Methodological principles

The analysis suggests a general protocol for mixed special values. First, separate analytic domain questions from arithmetic classification. Here the inequality $1+a>0$ makes the real logarithm meaningful, while $a>0$ yields positivity. Second, write the desired arithmetic conclusion in its quantified polynomial form. “The pair is algebraically independent” means that every rational bivariate polynomial vanishing at the pair is zero. Third, test whether known theorems control the full expression or only its components. Componentwise transcendence is not stable under multiplication. Finally, formulate the weakest target conjecture and distinguish it from stronger sufficient hypotheses.

This protocol avoids two opposite errors. It prevents an unjustified claim of transcendence, but it also prevents the absence of an unconditional proof from obscuring genuine results. The positivity theorems, the product theorem, and the exact conditional reductions all remain informative. They identify which aspects are elementary, which are algebraic, and which require genuinely new transcendence theory.

A similar discipline applies to reported computations. Numerical values should be accompanied by precision and error information. Polynomial searches should state degree and coefficient bounds. Most importantly, the conclusion should match the quantifiers actually tested: a bounded search may reject candidates in a finite box, whereas algebraic independence rejects every nonzero rational polynomial. Keeping those claims distinct allows computation and theory to reinforce rather than misrepresent one another.

## 13. Conclusion

For the special values $E(a)=e^a\log(1+a)$, the established landscape is clear. Positive inputs produce positive, nonzero outputs. Algebraic independence of two real factors implies transcendence of their product, and hence algebraic independence of $e^a$ and $\log(1+a)$ suffices to prove transcendence of $E(a)$. The concrete values at $\sqrt2$ and $\sqrt3$ are positive and nonzero; their algebraic independence, and therefore the unconditional absence of rational polynomial relations between them, remains open.

This separation of unconditional theorem, conditional reduction, and open conjecture is mathematically substantive. It replaces an invalid multiplication of transcendence statements with the exact independence hypothesis needed for a valid argument, and it provides a precise agenda for future work on exponential–logarithmic arithmetic.
