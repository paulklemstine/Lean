# The Factorial That Learned to Count in Polynomials

*How a single letter $q$ turns the most familiar formula in combinatorics into a machine for factoring — and why every Gaussian binomial coefficient secretly records the carries of grade-school addition.*

---

## A formula you already know

Every student who has met binomial coefficients has met this identity:

$$k!\,(n-k)!\,\binom{n}{k} \;=\; n!.$$

It is usually read as a recipe for computing $\binom{n}{k}$: divide $n!$ by $k!(n-k)!$. But it is better read as a *story about counting*. To arrange $n$ distinct books on a shelf, first decide which $k$ of them go on the left half ($\binom{n}{k}$ ways), then arrange those $k$ books ($k!$ ways), then arrange the remaining $n-k$ ($(n-k)!$ ways). Every one of the $n!$ arrangements arises exactly once. No division appears anywhere in the story — only multiplication.

This article is about what happens when you replace every number in that story by a polynomial in a new variable $q$. The resulting identity is just as short, but it is far richer: it tells you how to factor certain polynomials completely, and it reveals that hidden inside each "quantum" binomial coefficient is a precise record of the carries you make when adding two numbers on paper.

## Numbers that remember where they came from

The idea of a "$q$-analogue" goes back to the nineteenth century, to Gauss and to Heine. The basic move is to replace the positive integer $n$ by the polynomial

$$[n]_q \;=\; 1 + q + q^2 + \cdots + q^{n-1}.$$

Setting $q = 1$ gives back $1 + 1 + \cdots + 1 = n$, so nothing is lost. But for other values of $q$ the number "$n$" has become a whole polynomial, carrying extra information. These $[n]_q$ are called **$q$-integers**.

From $q$-integers we build the **$q$-factorial**, by analogy with $n! = 1\cdot 2\cdots n$:

$$[n]_q! \;=\; [1]_q\,[2]_q\,[3]_q\cdots[n]_q, \qquad [0]_q! = 1.$$

For instance,

$$[3]_q! = 1\cdot(1+q)\cdot(1+q+q^2) = 1 + 2q + 2q^2 + q^3,$$

and setting $q=1$ gives $1+2+2+1 = 6 = 3!$. The coefficients $1,2,2,1$ are not random: they count the six permutations of $\{1,2,3\}$ according to how many pairs are "out of order" (one permutation has no such inversions, two have one, two have two, one has three). The $q$-factorial is a census of permutations, sorted by disorder.

There is a second, more striking interpretation. If $q$ is a prime power, so that there is a finite field with $q$ elements, then $[n]_q!$ counts the **complete flags** in the $n$-dimensional vector space over that field — the nested chains of subspaces $0 \subset V_1 \subset V_2 \subset \cdots \subset V_n$ with each $V_i$ of dimension $i$. A permutation is, in a precise sense, "a flag over the field with one element", which is why setting $q=1$ recovers $n!$.

## The Gaussian binomial, defined without division

Now for the binomial coefficients. One could simply *define* the **Gaussian binomial coefficient** as a quotient,

$$\binom{n}{k}_q \;\overset{?}{=}\; \frac{[n]_q!}{[k]_q!\,[n-k]_q!},$$

but this is unsatisfying: it is not obvious that the division comes out to be a polynomial at all, and in many settings (such as working with numbers where division is not available) the formula does not even make sense.

So we take a different route. We define the Gaussian binomial purely by a recursion — a $q$-version of Pascal's triangle:

$$\binom{n}{0}_q = 1, \qquad \binom{0}{k+1}_q = 0, \qquad \binom{n+1}{k+1}_q = \binom{n}{k}_q + q^{k+1}\binom{n}{k+1}_q.$$

Only addition and multiplication appear, so these are automatically polynomials with nonnegative integer coefficients. Setting $q=1$ returns the ordinary Pascal rule. A typical entry is

$$\binom{4}{2}_q = 1 + q + 2q^2 + q^3 + q^4,$$

whose coefficients add to $6 = \binom{4}{2}$. Over a field with $q$ elements, $\binom{n}{k}_q$ counts the $k$-dimensional subspaces of an $n$-dimensional space: for $q=2$ and $n=4$ there are $1+2+2\cdot 4+8+16 = 35$ two-dimensional subspaces of the space of binary 4-vectors.

## The headline theorem: the product formula, with no division in sight

The central result is the faithful $q$-analogue of the shelf-of-books identity.

> **The $q$-Factorial Product Formula.** For all $0 \le k \le n$,
> $$[k]_q!\;[n-k]_q!\;\binom{n}{k}_q \;=\; [n]_q!.$$

The remarkable feature is the *generality*. The formula holds not only for polynomials with integer coefficients, but with $q$ taken to be an element of *any* commutative semiring — any number system where you can add and multiply, with the usual laws, but where subtraction and division may be unavailable. That includes the natural numbers, polynomials with natural-number coefficients, and even exotic systems such as the "tropical" numbers, where "addition" means taking a maximum and "multiplication" means ordinary addition.

**Why it is true.** The proof is a short induction on $n$, and it is worth seeing because it explains the shape of the recursion. The key fact is that $q$-integers add with a twist:

$$[a+b]_q = [a]_q + q^a\,[b]_q,$$

which just says that $1+q+\cdots+q^{a+b-1}$ splits into its first $a$ terms and the remaining $b$ terms, the latter all sharing a factor $q^a$. In particular $[n+1]_q = [k+1]_q + q^{k+1}[n-k]_q$.

Now expand the left side for $\binom{n+1}{k+1}_q$ using the Pascal recursion. One piece becomes $[k]_q!\,[n-k]_q!\binom{n}{k}_q$ times $[k+1]_q$, and the other becomes $[k+1]_q!\,[n-k-1]_q!\binom{n}{k+1}_q$ times $q^{k+1}[n-k]_q$. By the induction hypothesis, both bracketed products equal $[n]_q!$. So the total is

$$[n]_q!\,\big([k+1]_q + q^{k+1}[n-k]_q\big) = [n]_q!\,[n+1]_q = [n+1]_q!.$$

The twisted addition law for $q$-integers and the twist $q^{k+1}$ in Pascal's rule fit together like gears.

Setting $q=1$ immediately gives back $k!(n-k)!\binom{n}{k} = n!$, so the classical identity is a shadow of the quantum one.

## A small gift from the tropics

Because the formula holds in every commutative semiring, it can be evaluated in places where it says something unexpected. Take the tropical numbers, where $a \oplus b = \max(a,b)$ and $a \otimes b = a + b$, and put $q = 1$ there. Then the tropical $q$-integer $[i]_q$ is $\max(0,1,\ldots,i-1) = i-1$, the tropical $q$-factorial is $0+1+\cdots+(n-1) = \binom{n}{2}$, and the tropical Gaussian binomial computes the *degree* of the ordinary one. The product formula becomes

$$\binom{k}{2} + \binom{n-k}{2} + \deg\binom{n}{k}_q = \binom{n}{2},$$

which forces $\deg \binom{n}{k}_q = k(n-k)$. One theorem, two worlds: the identity that counts subspaces also measures polynomial degrees.

## Factorials in the polynomial world are uniquely determined

In ordinary arithmetic we could recover $\binom{n}{k}$ from the product formula by dividing. In the world of integer polynomials we can still do this, because $[n]_q!$ is never zero; indeed it is *monic* (leading coefficient $1$) of degree exactly $\binom{n}{2} = n(n-1)/2$. So:

> **Uniqueness.** If a polynomial $P(q)$ with integer coefficients satisfies $[k]_q!\,[n-k]_q!\,P(q) = [n]_q!$, then $P(q) = \binom{n}{k}_q$.

This turns the product formula into a *characterisation*: to prove that some cleverly constructed polynomial is the Gaussian binomial, it suffices to check that it satisfies the product formula. That is exactly how the most surprising result below is proved.

There is also a neat link to another classical object, the $q$-Pochhammer symbol $(q;q)_n = (1-q)(1-q^2)\cdots(1-q^n)$, which appears throughout the theory of partitions and in Euler's pentagonal number theorem. Because $(1-q)[i]_q = 1-q^i$, one has

$$(q;q)_n = (1-q)^n\,[n]_q!.$$

## Breaking polynomials into atoms

Every integer factors uniquely into primes. Polynomials with integer coefficients also factor into irreducible "atoms", and for polynomials like $q^n - 1$ the atoms are the famous **cyclotomic polynomials** $\Phi_d(q)$. These are defined by the rule

$$q^n - 1 = \prod_{d \mid n} \Phi_d(q),$$

so that $\Phi_1 = q - 1$, $\Phi_2 = q+1$, $\Phi_3 = q^2+q+1$, $\Phi_4 = q^2+1$, $\Phi_6 = q^2 - q + 1$, and so on. The roots of $\Phi_d$ are exactly the primitive $d$-th roots of unity — the points on the unit circle that return to $1$ after exactly $d$ steps.

Dividing out $\Phi_1 = q-1$ shows that each $q$-integer is a product of cyclotomic atoms: $[n]_q = \prod_{d\mid n,\ d\ge 2}\Phi_d(q)$. Multiplying these together for $n = 1, 2, \ldots$ and simply counting how many multiples of $d$ lie between $1$ and $n$ gives:

> **Cyclotomic factorisation of the $q$-factorial.**
> $$[n]_q! \;=\; \prod_{d=2}^{n} \Phi_d(q)^{\lfloor n/d\rfloor}.$$

For example, $[6]_q! = \Phi_2^3\,\Phi_3^2\,\Phi_4\,\Phi_5\,\Phi_6$. This is the polynomial analogue of Legendre's classical formula for the prime factorisation of $n!$, where the number of times a prime appears is governed by the floors $\lfloor n/p\rfloor, \lfloor n/p^2\rfloor,\ldots$.

## The punchline: Gaussian binomials record the carries

Combine the cyclotomic factorisation with the product formula and the uniqueness theorem. The exponent of $\Phi_d$ in $\binom{n}{k}_q$ must be

$$\left\lfloor \tfrac{n}{d}\right\rfloor - \left\lfloor \tfrac{k}{d}\right\rfloor - \left\lfloor \tfrac{n-k}{d}\right\rfloor.$$

Here is the delightful part. This difference can only ever be $0$ or $1$, and it is $1$ precisely when adding $k$ and $n-k$ "in base $d$" produces a carry out of the last digit — that is, when the remainders overflow:

$$k \bmod d \;+\; (n-k) \bmod d \;\ge\; d.$$

> **The Carry Theorem.** For $0 \le k \le n$,
> $$\binom{n}{k}_q \;=\; \prod_{\substack{2 \le d \le n\\ k \bmod d \,+\, (n-k)\bmod d \,\ge\, d}} \Phi_d(q).$$
> In particular every Gaussian binomial coefficient is a product of *distinct* cyclotomic polynomials — no atom ever appears twice.

Check it on $\binom{4}{2}_q$. For $d=2$: $0+0<2$, no carry. For $d=3$: $2+2 = 4 \ge 3$, carry. For $d = 4$: $2 + 2 = 4 \ge 4$, carry. So the theorem predicts $\binom{4}{2}_q = \Phi_3\Phi_4 = (1+q+q^2)(1+q^2) = 1+q+2q^2+q^3+q^4$. Exactly right.

A bigger example: $\binom{10}{4}_q = \Phi_5\,\Phi_7\,\Phi_8\,\Phi_9\,\Phi_{10}$, because adding $4$ and $6$ overflows the last digit precisely in the bases $5,7,8,9,10$.

One immediate consequence: taking $d = n$, the remainders are $k$ and $n-k$, which add to exactly $n$. So **$\Phi_n(q)$ divides every interior Gaussian binomial $\binom{n}{k}_q$ with $0<k<n$** — the polynomial counterpart of the fact that a prime $p$ divides $\binom{p}{k}$ for $0<k<p$.

## Back to whole numbers: Kummer's carries

What happens to the Carry Theorem when we set $q=1$? It becomes a statement about ordinary binomial coefficients:

$$\binom{n}{k} = \prod_{\text{carry moduli } d} \Phi_d(1).$$

The values $\Phi_d(1)$ are classical: $\Phi_d(1) = p$ if $d$ is a power $p^a$ of a prime $p$, and $\Phi_d(1) = 1$ otherwise. So only the prime-power carry moduli contribute, each contributing its prime. For $\binom{10}{4} = 210$ the carry moduli $5,7,8,9,10$ contribute $5\cdot 7\cdot 2\cdot 3\cdot 1 = 210$.

This is the shadow of a celebrated nineteenth-century theorem of Kummer: the exponent of a prime $p$ in $\binom{n}{k}$ equals the number of carries when $k$ and $n-k$ are added in base $p$. In the polynomial world, Kummer's carries for all primes simultaneously are encoded by one squarefree product of cyclotomic polynomials. Likewise, evaluating the factorial factorisation at $q=1$ gives $n! = \prod_{d=2}^n \Phi_d(1)^{\lfloor n/d\rfloor}$, a repackaging of Legendre's formula.

## Why it matters

The $q$-binomial coefficients are not museum pieces. They count subspaces of vector spaces over finite fields, which underlie error-correcting codes and the design of network codes. They are generating functions for partitions fitting in a box, central in statistical mechanics and the theory of integer partitions. They appear as the "quantum binomial theorem" in quantum groups, where variables satisfy $yx = qxy$. And their values at roots of unity drive the *cyclic sieving phenomenon*, which counts symmetric configurations by plugging roots of unity into polynomials.

The Carry Theorem tells you exactly where those values vanish: $\binom{n}{k}_q$ is zero at a primitive $d$-th root of unity precisely when adding $k$ and $n-k$ in base $d$ carries. A question about complex numbers on the unit circle reduces to schoolbook arithmetic.

## The moral

A formula you learned in high school, $k!(n-k)!\binom{n}{k} = n!$, turns out to be the $q=1$ snapshot of a statement that holds in every number system where you can add and multiply. Written without division, it becomes a characterisation of the Gaussian binomials; combined with the atomic structure of cyclotomic polynomials, it shows that each $\binom{n}{k}_q$ is built from distinct atoms, chosen by the carries in elementary addition. Remove the $q$ and you recover Kummer's theorem; keep it and you can see all primes at once.

Several natural questions remain open for exploration: extending the carry description to $q$-multinomial coefficients (where an atom can now appear up to $r-1$ times), deriving Kummer's theorem in full from the cyclotomic picture, counting rotation-symmetric subsets by evaluating at roots of unity, and proving that the coefficient sequences of $[n]_q!$ rise and then fall without wobbling.
