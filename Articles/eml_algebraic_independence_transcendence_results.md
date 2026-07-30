# The Arithmetic Frontier of Exponential–Logarithmic Values

## When familiar functions make unfamiliar numbers

Take a positive algebraic number $a$: a number determined by a polynomial equation with rational coefficients. Now form

$$
E(a)=e^a\log(1+a).
$$

Every symbol here belongs to elementary calculus, yet the arithmetic nature of the result can be extraordinarily difficult to determine. Is $E(a)$ algebraic, meaning that it satisfies some nonzero polynomial equation with rational coefficients? Is it transcendental, escaping every such equation? If several values $E(a_1),\ldots,E(a_n)$ are considered together, can a polynomial in several variables tie them to one another?

These questions sit on a fault line in modern number theory. Classical transcendence theorems can often control a single exponential or a carefully structured power. Products of unrelated transcendental quantities are another matter. Two transcendental numbers may have an algebraic product: $\pi$ and $1/\pi$ are both transcendental, but their product is $1$. Thus even perfect knowledge of the two factors in $e^a\log(1+a)$ does not automatically reveal the arithmetic nature of their product.

The central achievement discussed here is therefore not an unconditional solution of a famous open problem. It is a precise map of what can be proved, what additional hypothesis would settle the problem, and why an alluring shortcut fails. Along the way, the map yields unconditional positivity and nonvanishing results, a general product-transcendence theorem under algebraic independence, and an exact formulation of the challenge posed by the inputs $\sqrt2$ and $\sqrt3$.

## Three levels of arithmetic freedom

A real number $x$ is **algebraic over $\mathbb Q$** if some nonzero polynomial $p\in\mathbb Q[T]$ satisfies $p(x)=0$. Otherwise $x$ is **transcendental**. Algebraic independence is the many-variable extension of transcendence. Two real numbers $x$ and $y$ are **algebraically independent over $\mathbb Q$** if no nonzero polynomial $P\in\mathbb Q[X,Y]$ satisfies $P(x,y)=0$.

These notions form a hierarchy. Algebraic independence of $x$ and $y$ forces each number to be transcendental, but it says much more: it rules out every rational polynomial relation linking them. Separate transcendence is weaker. Knowing only that $x$ and $y$ are transcendental does not prevent $xy$, $x+y$, or some more complicated expression from being algebraic.

This distinction is decisive for exponential–logarithmic values. One might hope to combine a theorem about $e^a$ with a theorem about $\log(1+a)$ and conclude that their product is transcendental. That inference is invalid without information about the relation between the factors. Classical results such as Lindemann–Weierstrass and Gelfond–Schneider are immensely powerful, but they do not, in this setting, provide the missing joint independence statement.

## The first unconditional facts

For every positive real number $a$, both factors in $E(a)$ are positive. The exponential function satisfies $e^a>0$ for all real $a$. If $a>0$, then $1+a>1$, so $\log(1+a)>0$. Therefore:

**Positivity Theorem.** For every real $a>0$,

$$
E(a)=e^a\log(1+a)>0.
$$

The proof is a one-line order argument: multiply the two positive factors. A useful immediate consequence is the following.

**Nonvanishing Corollary.** For every real $a>0$, $E(a)\ne0$.

These statements do not require $a$ to be algebraic. They settle the basic analytic behavior on the positive half-line and provide essential consistency checks for numerical experiments. They do not, however, distinguish algebraic values from transcendental ones.

The sign picture outside the positive half-line is also transparent wherever the real logarithm has its usual analytic meaning. For $-1<a<0$, the exponential remains positive while $0<1+a<1$, so $\log(1+a)<0$ and hence $E(a)<0$. At $a=0$, the value is $0$. The transcendence conjecture is naturally restricted to nonzero algebraic $a$ with $1+a>0$.

## Why independence makes the product transcendental

The key structural result applies far beyond exponentials and logarithms.

**Product Theorem.** If real numbers $x$ and $y$ are algebraically independent over $\mathbb Q$, then their product $xy$ is transcendental over $\mathbb Q$.

Here is the central idea. Suppose, toward a contradiction, that $xy$ were algebraic. Then a nonzero one-variable polynomial $p(T)\in\mathbb Q[T]$ would satisfy $p(xy)=0$. Replace $T$ by $XY$ and define

$$
Q(X,Y)=p(XY).
$$

This gives $Q(x,y)=p(xy)=0$. Algebraic independence would force $Q$ to be the zero polynomial. But substitution $T\mapsto XY$ cannot turn a nonzero polynomial into the zero polynomial: if $p(T)=\sum_k c_kT^k$, then

$$
Q(X,Y)=\sum_k c_kX^kY^k,
$$

whose distinct monomials retain the coefficients $c_k$. Hence $p$ itself would have to be zero, a contradiction.

Applying this general theorem gives an exact conditional solution to the one-variable problem.

**Conditional EML Transcendence Theorem.** For any real $a$, if the pair $e^a$ and $\log(1+a)$ is algebraically independent over $\mathbb Q$, then $E(a)=e^a\log(1+a)$ is transcendental over $\mathbb Q$.

The hypothesis is deliberately stronger than separate transcendence. It supplies exactly the joint information that the product argument needs.

## Two square roots and an open frontier

Consider the concrete numbers

$$
U=e^{\sqrt2}\log(1+\sqrt2),\qquad
V=e^{\sqrt3}\log(1+\sqrt3).
$$

Since $\sqrt2>0$ and $\sqrt3>0$, the positivity theorem immediately gives $U>0$ and $V>0$. In particular, neither number vanishes. Approximate computation gives values near $3.63$ and $5.68$, respectively, but decimal expansions cannot determine algebraic independence.

The proposed two-variable statement is:

**Square-Root Pair Conjecture.** The numbers $U$ and $V$ are algebraically independent over $\mathbb Q$.

Spelled out, this says that whenever a rational-coefficient polynomial $P(X,Y)$ satisfies $P(U,V)=0$, the polynomial $P$ must have every coefficient equal to zero. Under the algebraic-independence hypothesis, this conclusion is immediate from the definition, but establishing the hypothesis is open. That logical separation matters: the elimination of polynomial relations is exact and rigorous once independence is assumed; the unproved burden is concentrated in a single, plainly stated conjecture.

Why can computation not finish the job? A computer can evaluate $P(U,V)$ to thousands or millions of decimal places for any chosen $P$. A tiny output may be evidence worth investigating, but it cannot distinguish exact zero from a nonzero number smaller than the numerical error. Worse, there are infinitely many polynomials to test, with unbounded degrees and coefficients. Numerical searches can expose obvious proposed relations or guide conjecture, but they cannot certify algebraic independence.

## The larger conjectural landscape

The natural finite-family conjecture begins with positive algebraic numbers $a_1,\ldots,a_n$ that are linearly independent over $\mathbb Q$. It predicts that

$$
E(a_1),\ldots,E(a_n)
$$

are algebraically independent over $\mathbb Q$. Linear independence of the inputs means that a rational relation $q_1a_1+\cdots+q_na_n=0$ forces every $q_i$ to vanish. Algebraic independence of the outputs is vastly stronger: it excludes every multivariate polynomial relation.

This proposal belongs to the orbit of Schanuel-type conjectures, which predict broad algebraic independence among numbers and their exponentials. The mixed expression $e^a\log(1+a)$ has extra multiplicative structure, but that structure cuts both ways. It offers a clear route from factor independence to product transcendence, while also warning that products can conceal cancellations invisible at the level of individual factors.

The one-variable factor-independence conjecture states that for every nonzero algebraic real $a$ with $1+a>0$, the pair $e^a,\log(1+a)$ is algebraically independent. This would imply the desired transcendence of $E(a)$. Yet it is stronger than necessary: conceivably, the product could be transcendental even when the two factors satisfy some algebraic relation. Separating the stronger sufficient condition from the weaker target is one of the most useful conceptual clarifications.

## A disciplined way to explore

Numerical work remains valuable when its role is stated honestly. High-precision arithmetic can illustrate positivity, compare growth rates, and screen finite lists of low-degree, small-coefficient polynomial candidates. For the square-root pair, one can enumerate polynomials

$$
P(X,Y)=\sum_{0\le i+j\le d}c_{ij}X^iY^j
$$

with bounded integers $c_{ij}$ and report the smallest observed $|P(U,V)|$. Such a search does not prove independence, even if no relation appears. It is a falsification tool for restricted candidate families and a way to measure numerical conditioning.

The exact mathematics supplies the guardrails. Positive inputs give positive, nonzero outputs. Algebraic independence of two factors guarantees transcendence of their product. Independence of the concrete pair means precisely that every vanishing rational polynomial is zero. None of these statements licenses the leap from “no relation found” to “no relation exists.”

## From local calculations to global impossibility

There is a striking mismatch of scale in these questions. Evaluating $E(a)$ at one input is easy: modern software can print thousands of digits. Proving transcendence means excluding infinitely many equations at once. For a single value $z$, every candidate

$$
c_0+c_1z+\cdots+c_dz^d=0
$$

must be ruled out, across all degrees $d$ and all rational coefficients. For a pair such as $(U,V)$, the candidates fan out in two directions, including terms like $U^iV^j$. Algebraic independence says that this entire infinite universe of possible equations is empty except for the equation with all coefficients zero.

The product theorem succeeds because it converts that global prohibition into a focused contradiction. Any equation for $xy$ would automatically manufacture an equation for the pair $(x,y)$. Algebraic independence has already forbidden the latter, so the former cannot exist. This conversion—from a one-variable relation to a two-variable relation—is the mechanism that numerical magnitude alone cannot supply.

That is the deeper lesson of this exponential–logarithmic frontier. In transcendence theory, the hardest step is often not manipulating familiar functions but identifying the exact kind of arithmetic freedom required. Here the boundary is crisp: positivity is unconditional; product transcendence follows from factor independence; the square-root pair remains conjectural. A clear boundary is not a defeat. It is a map showing where established ground ends—and where the next theorem must begin.
