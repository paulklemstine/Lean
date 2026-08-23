# The Sign at the Centre: How a Single Eigenvalue Decides Whether a Zeta Function Vanishes

## A coin flip written into arithmetic

Some of the deepest predictions in number theory hinge on a single bit of information — a plus or a minus sign.

The Birch–Swinnerton-Dyer conjecture, one of the Clay Millennium Problems, says that the number of rational points of infinite order on an elliptic curve equals the order of vanishing of a certain analytic function $L(E,s)$ at a special point. Nobody knows how to prove that. But there is a shadow of it that is far more tractable, called the **parity conjecture**: it says that the *parity* — the evenness or oddness — of that order of vanishing is computable in advance, from a sign $\varepsilon = \pm 1$ attached to the curve. If $\varepsilon = -1$, the function must vanish at the centre, and the curve must have a rational point of infinite order. One bit of arithmetic data, and an infinite set of solutions springs into existence.

Where does that bit come from? This article tells the story of the sign in a setting where it can be pinned down completely: the world of varieties over finite fields, where zeta functions are *polynomials* and the whole question becomes a piece of exact combinatorics about a finite list of numbers.

The punchline, proved below in full generality, is startling in its simplicity:

> **The sign is the parity of how many times one particular number appears in a list.**

Everything else — every other eigenvalue, however wild — cancels out.

## The setting: counting points, and the numbers that do the counting

Let $X$ be a smooth projective variety of dimension $n$ over the finite field $\mathbb{F}_q$ — the solution set of a system of polynomial equations, over a field with $q$ elements. The most basic thing to ask is: how many points does it have? And how many points does it have over $\mathbb{F}_{q^2}$, $\mathbb{F}_{q^3}$, and so on?

André Weil's great insight was that these counts are governed by a finite list of complex numbers, the *Frobenius eigenvalues*. The interesting ones — the ones that carry the geometry — live in *middle degree*, and they are encoded in a polynomial

$$P(T) = \prod_{i=1}^{d}(1 - \alpha_i T),$$

where $d$ is the middle Betti number and each $\alpha_i$ has absolute value exactly $q^{n/2}$. Write

$$Q := q^{n/2}$$

for this half-weight. All the eigenvalues sit on a circle of radius $Q$ in the complex plane.

Now comes the crucial symmetry. **Poincaré duality** — the statement that a manifold's homology in degree $k$ mirrors its cohomology in degree $\dim - k$ — imposes a rigid pairing on this list. Concretely: there is a permutation $\sigma$ of the indices $\{1,\dots,d\}$, which is its own inverse ($\sigma(\sigma(i)) = i$), such that

$$\alpha_i \cdot \alpha_{\sigma(i)} = q^n = Q^2 \qquad \text{for every } i.$$

The eigenvalues come in *partners*, and each pair multiplies to $Q^2$. Geometrically, $\alpha \mapsto Q^2/\alpha$ is the reflection of the circle of radius $Q$ in the real axis. Duality says: the list of eigenvalues is symmetric under this reflection.

That is the entire structure we shall use. Strip away the geometry, and what remains is what we call a **duality eigensystem**: a nonzero scalar $Q$, a finite list $\alpha_1,\dots,\alpha_d$ of numbers, and an involution $\sigma$ of the index set with $\alpha_i \alpha_{\sigma(i)} = Q^2$. Nothing about varieties, nothing about finite fields, nothing even about the absolute values. Just the pairing.

## Why the sign exists at all

Substitute $T \mapsto 1/(Q^2 T)$ into $P$ — this is the reflection, transported to the variable $T$ — and a small computation (which we do below) yields the **functional equation**

$$(Q^2T)^d \, P\!\left(\frac{1}{Q^2 T}\right) = \varepsilon \cdot Q^d \cdot P(T),$$

valid for all $T \neq 0$. The polynomial is symmetric about its centre — up to the constant $\varepsilon$. And $\varepsilon$ is always $+1$ or $-1$.

That constant is the sign. It is the finite-field analogue of the root number of an elliptic curve, and it is the object we want to compute.

Where does it come from? Track the substitution carefully. Each factor transforms as

$$(Q^2T)\left(1 - \frac{\alpha_i}{Q^2T}\right) = Q^2 T - \alpha_i = -\alpha_i\left(1 - \frac{Q^2}{\alpha_i}T\right) = -\alpha_i\,\bigl(1 - \alpha_{\sigma(i)} T\bigr),$$

using duality, $Q^2/\alpha_i = \alpha_{\sigma(i)}$, in the last step. Multiplying over all $i$, and noting that $\sigma$ is a bijection so that the $\sigma$-shuffled product $\prod_i (1-\alpha_{\sigma(i)}T)$ is just $P(T)$ again, we get

$$(Q^2T)^d P\!\left(\tfrac{1}{Q^2T}\right) = (-1)^d \Bigl(\prod_i \alpha_i\Bigr) P(T).$$

So the sign is

$$\boxed{\;\varepsilon = (-1)^d \cdot \frac{\prod_i \alpha_i}{Q^d}.\;}$$

Everything now reduces to a single question: **what is the product of the eigenvalues?**

## The naive attempt, and why it fails

Here is the obvious move. Multiply the duality relation over all $i$:

$$\prod_i \alpha_i \cdot \alpha_{\sigma(i)} = Q^{2d}.$$

Since $\sigma$ is a bijection, the left side is $\bigl(\prod_i \alpha_i\bigr)^2$. Therefore

$$\Bigl(\prod_i \alpha_i\Bigr)^2 = Q^{2d}, \qquad\text{so}\qquad \prod_i \alpha_i = \pm Q^d.$$

One line. But it determines the product only *up to sign* — and the sign is precisely the whole question. Squaring destroys exactly the information we want. This is the mathematical equivalent of proving that a coin landed either heads or tails.

## The right argument: pair them up

The trick is not to multiply the relations but to **cancel them in pairs**.

Normalise: set $\beta_i := \alpha_i/Q$, so duality reads $\beta_i \beta_{\sigma(i)} = 1$. The involution $\sigma$ splits the index set into two kinds of orbits:

- **Two-cycles**: pairs $\{i, \sigma(i)\}$ with $\sigma(i) \neq i$. Here $\beta_i$ and $\beta_{\sigma(i)}$ are reciprocals, and their contribution to $\prod \beta_i$ is exactly $\beta_i \cdot \beta_i^{-1} = 1$. **Two-cycles are invisible.** Whatever the eigenvalue $a$ is — real, complex, huge, tiny — the pair $\{a, Q^2/a\}$ contributes precisely $Q^2$ to the product and nothing at all to the sign.

- **Fixed points**: indices with $\sigma(i) = i$. Here duality says $\alpha_i^2 = Q^2$, so $\alpha_i = +Q$ or $\alpha_i = -Q$. These are the two *real* points on the Weil circle — the two eigenvalues that are their own duality partners. And each such self-dual eigenvalue contributes its own sign: $+1$ if $\alpha_i = +Q$, and $-1$ if $\alpha_i = -Q$.

Killing the fixed points by hand and applying the pairing to the rest gives the whole answer at once.

> **The Duality Sign Law.** *For any duality eigensystem,*
> $$\prod_{i=1}^{d} \alpha_i \;=\; (-1)^{\,\#\{i \,:\, \sigma(i)=i,\ \alpha_i = -Q\}} \cdot Q^d.$$
> *Equivalently, the functional-equation sign is*
> $$\varepsilon = (-1)^{\,d \,+\, \#\{i \,:\, \sigma(i)=i,\ \alpha_i=-Q\}}.$$

The product of all $d$ Frobenius eigenvalues is $q^{nd/2}$, corrected by exactly one factor of $-1$ for each self-dual eigenvalue equal to $-q^{n/2}$. Nothing else in the entire spectrum matters.

This settles the conjecture that motivated the work: **if duality has no fixed point carrying $\alpha = -q^{n/2}$, then $\prod \alpha_i = Q^d$ exactly, and $\varepsilon = (-1)^d$.**

And it gives the sharp converse, valid over any field in which $-1 \neq 1$: the conclusion $\prod \alpha_i = Q^d$ holds **if and only if** the number of $-Q$ fixed points is *even*. Two anti-diagonal fixed points cancel each other. The hypothesis "no $-Q$ fixed point" is sufficient but not necessary; the true invariant is a $\mathbb{Z}/2$ count.

## Erasing the permutation

There is something unsatisfying about the formula above: it mentions $\sigma$. But $\sigma$ is auxiliary data — the *list* of eigenvalues is intrinsic to the variety, while the labelling permutation is a choice. Can the sign be read off the list alone?

It can, and the answer is beautiful. Let

$$m_+ := \#\{i : \alpha_i = +Q\}$$

be the multiplicity of the central eigenvalue $q^{n/2}$ in the list. Then:

> **The Central Parity Theorem.** *Over any field in which $-1 \neq 1$,*
> $$\varepsilon = (-1)^{m_+}.$$

The permutation has vanished. The proof is a two-line parity count, using the same "free involutions have even orbit sets" principle twice: the non-fixed indices pair up, so there is an even number of them; and the set $\{i : \alpha_i = Q\}$ is duality-stable (if $\alpha_i = Q$ then $\alpha_{\sigma(i)} = Q^2/Q = Q$), so *its* non-fixed part is also even. Both even contributions cancel modulo $2$, and one is left with $d + \#\{-Q\text{-fixed}\} \equiv m_+ \pmod 2$.

Why is $m_+$ the right thing to count? Because $m_+$ *is the order of vanishing of $P$ at the central point*. Indeed $P(T)$ factors as

$$P(T) = (1 - QT)^{m_+} \cdot G(T), \qquad G(Q^{-1}) \neq 0,$$

since a factor $1 - \alpha_i T$ vanishes at $T = Q^{-1}$ precisely when $\alpha_i = Q$. So the Central Parity Theorem reads:

> **The sign of the functional equation is $(-1)^{\text{order of vanishing at the centre}}$.**

That is the parity conjecture — not conjectured, but *proved*, in this model. In particular: **if $\varepsilon = -1$, then $P(q^{-n/2}) = 0$.** A minus sign forces the zeta factor to vanish at the central point. This is the exact finite-field mirror of "root number $-1$ implies the elliptic curve has a point of infinite order".

## A genuine invariant, not a formula

A skeptic could object that $\varepsilon$ is just an abbreviation for a combinatorial count. Three structural facts show it is more than that — it behaves like a root number should.

1. **It lives in $\mu_2$.** Always $\varepsilon^2 = 1$: the sign is a square root of unity, never anything else.

2. **It is multiplicative.** If two eigensystems of the same weight $Q$ are combined by concatenating their eigenvalue lists (the direct sum, corresponding to a direct sum of cohomologies), then degrees add, central multiplicities add, characteristic polynomials multiply, and
$$\varepsilon(E \oplus F) = \varepsilon(E)\,\varepsilon(F).$$
The sign is a homomorphism into $\{\pm 1\}$ — the shadow of the fact that root numbers are multiplicative in the Grothendieck group of Galois representations.

3. **It is twist-invariant.** Rescaling everything, $(Q, \alpha) \mapsto (cQ, c\alpha)$ for any $c \neq 0$ — the model's version of a Tate twist — leaves $\varepsilon$ untouched. The sign depends only on the *normalised* eigenvalues $\alpha_i/Q$, i.e. on where they sit on the unit circle after rescaling. This is exactly the invariance one demands of a genuine arithmetic quantity.

There is also a striking dimensional consequence. An involution on an odd-sized set must have a fixed point (the non-fixed indices come in pairs). Therefore:

> **In odd degree, a self-dual eigenvalue always exists.** If moreover no fixed point carries $-Q$, then every fixed point carries $+Q$, the multiplicity $m_+$ is odd, $\varepsilon = -1$, and $P(Q^{-1}) = 0$.

Odd-dimensional middle cohomology forces central vanishing. This is the model's version of the phenomenon that, for elliptic curves and odd root number, one is guaranteed a point of infinite order.

## Crossing to the analytic side

Everything so far is polynomial algebra. But the parity conjecture in its classical form is an *analytic* statement about the order of vanishing of a complex function. The two worlds can be joined exactly.

Pick any complex logarithm $L$ of the weight, so that $e^L = Q$, and substitute $T = e^{-sL}$. Under this change of variable, the duality substitution $T \mapsto 1/(Q^2 T)$ becomes precisely the reflection

$$s \longmapsto 2 - s,$$

and the central point $T = Q^{-1}$ sits at $s = 1$. Define the **completed function**

$$\Lambda(s) := e^{(s-1)\,d\,L/2}\; P\!\left(e^{-sL}\right).$$

The exponential prefactor is the model's analogue of the conductor factor $N^{s/2}$ in the completed Hasse–Weil $L$-function: it is there to make the reflection perfectly symmetric. And it works — the exponent bookkeeping $(1-s)d/2 + d - (2-s)d = (s-1)d/2$ balances exactly, and one obtains:

> **The Analytic Functional Equation.** *$\Lambda$ is entire, and for every complex $s$,*
> $$\Lambda(2-s) = \varepsilon \cdot \Lambda(s),$$
> *with the same $\varepsilon$ computed combinatorially from the Frobenius eigenvalues.*

Now feed this into the general analytic parity principle, which is elementary but decisive: if a function $\Lambda$ is analytic at $s=1$, not identically zero near $s=1$, and satisfies $\Lambda(2-s) = w\,\Lambda(s)$, then expanding in powers of $u = s-1$ gives $\Lambda(1-u) = w\Lambda(1+u)$, so the Taylor coefficients obey $c_k(-1)^k = w\,c_k$ for all $k$. Every $c_k$ with $(-1)^k \neq w$ must vanish. Hence at the *first* nonvanishing coefficient — whose index is by definition the order of vanishing $\mathrm{ord}_{s=1}\Lambda$ —

$$(-1)^{\mathrm{ord}_{s=1}\Lambda} = w.$$

Applying this to our $\Lambda$ yields the culminating statement:

> **Analytic rank $\equiv$ central multiplicity (mod 2).** *For a duality eigensystem whose completed function is not locally zero at the centre,*
> $$(-1)^{\mathrm{ord}_{s=1}\Lambda} \;=\; \varepsilon \;=\; (-1)^{m_+}.$$
> *Under the hypothesis of no $-Q$ fixed point, this equals $(-1)^d$.*

An analytic invariant — the order of vanishing of a transcendental function at a point — is computed by a finite count of Frobenius eigenvalues. The finite-field combinatorics and the archimedean Taylor symmetry are two computations of the same element of $\mathbb{Z}/2$.

(One small point of hygiene: the logarithm $L$ is a *choice*. Different branches change $\Lambda$ by a factor $e^{2\pi i k(s-1)d/2}$, which is nowhere zero, so the order of vanishing — and hence the parity — does not depend on the choice. Nor does anything require $Q$ to be real or positive.)

## Where the theorem breaks: three witnesses

A theorem is only as sharp as its counterexamples. Three explicit systems show that every hypothesis is load-bearing.

**One eigenvalue, two worlds.** In degree $d=1$ there is a single index, necessarily fixed, so $\alpha = \pm Q$. With $\alpha = +Q$: the product is $Q$, and $\varepsilon = -1 = (-1)^1$ — the conjectured value. With $\alpha = -Q$: the product is $-Q \neq Q$, and $\varepsilon = +1 \neq (-1)^1$. **A single anti-diagonal fixed point flips the sign.** The hypothesis cannot be dropped.

**Two wrongs make a right.** In degree $2$, take *both* eigenvalues equal to $-Q$, both fixed. The hypothesis fails at every single index — yet $\prod \alpha_i = Q^2$ and $\varepsilon = +1$, exactly as if the hypothesis held. Two anti-diagonal fixed points cancel. This is why the honest theorem is a *parity* statement, not an absence statement.

**Involutivity is not decoration.** The most instructive witness. Take three indices, let $\sigma$ be the $3$-cycle $i \mapsto i+1 \bmod 3$ — which has *no fixed points at all*, so the hypothesis "no $-Q$ fixed point" holds vacuously — and set every $\alpha_i = -Q$. Then duality holds: $(-Q)(-Q) = Q^2$. But

$$\prod_i \alpha_i = -Q^3 \neq Q^3,$$

and the sign is $(-1)^{d+1}$, not $(-1)^d$. The conclusion fails outright. Chasing the relation $\alpha_i\alpha_{\sigma(i)} = Q^2$ around a $3$-cycle forces $\alpha_0 = \alpha_2$ and hence $\alpha_0^2 = Q^2$, so the whole cycle is constant $\pm Q$; choosing $-Q$ breaks everything. **The requirement that $\sigma$ be an involution — not merely a bijection — is exactly what the pairing argument consumes.** A merely-bijective duality is not enough, and no amount of cleverness recovers the sign law without it.

## What it means

Strip the story to its bones and this is what remains. A finite list of numbers is symmetric under an involution that pairs $\alpha$ with $Q^2/\alpha$. Most of that list is irrelevant to the sign of the resulting functional equation: two-cycles cancel perfectly, no matter how complicated their entries. All the sign information is concentrated in the two *fixed points of the reflection* — the two real points $\pm Q$ on the Weil circle — and even there, only their parity survives.

That is why the parity conjecture is so much more accessible than the full Birch–Swinnerton-Dyer conjecture: the full conjecture asks for a *number*, whereas parity asks only for a bit, and that bit is protected by a symmetry rigid enough to compute it exactly. In the finite-field model, the computation is finished: the bit is the multiplicity of $q^{n/2}$ among the Frobenius eigenvalues, read modulo $2$.

The open questions point outward from here. Real varieties do not have a single self-paired block of cohomology; they have a graded family $H^0, \dots, H^{2n}$ in which $H^i$ pairs with $H^{2n-i}$. Off the middle, the blocks pair with *different* blocks, so their contribution to the sign should telescope away — meaning the entire global sign should be carried by the middle cohomology alone, precisely where the fixed points can live. And if one imposes the Riemann hypothesis for varieties over finite fields, $|\alpha_i| = Q$ for all $i$, duality is no longer an extra hypothesis but a *consequence*: the involution must be complex conjugation, every fixed point is real, and the number of admissible sign patterns in degree $d$ collapses to exactly $\lfloor d/2 \rfloor + 1$.

A combinatorial hypothesis becomes a topological one. That is usually the sign that a piece of mathematics is telling the truth.
