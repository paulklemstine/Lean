# Machines That Argue Like Mathematicians: Building Trustworthy Shortcuts for Proof

Every working mathematician keeps a private toolbox of reflexes. Faced with
a routine step — "of course this simplifies," "obviously that number is
prime," "clearly the answer can't be larger than this" — they don't reprove
the underlying theory from scratch. They reach for a habit, a shortcut, a
move so well-worn it feels automatic. The danger of shortcuts, of course, is
that they can be wrong. A slick move that *feels* right but hides a false
assumption is how careful arguments quietly collapse.

This is the story of three such shortcuts, redesigned so that they can never
be wrong. Each is a small, reusable procedure — a *tactic* — that automates a
family of routine arguments. And each comes with a companion theorem, proved
once and for all, guaranteeing that the shortcut only ever produces true
statements. The three live in very different corners of mathematics: the
strange arithmetic of "tropical" algebra, the ancient problem of recognizing
prime numbers, and the geometry of how matrices stretch space. What unites
them is a single design philosophy: **never trust a shortcut you haven't
proved sound.**

## Shortcut one: doing algebra where plus means "take the smaller"

Imagine an arithmetic in which addition and multiplication have been quietly
swapped for stranger operations. In the *min-plus* world — often called
*tropical* mathematics — the "sum" of two numbers is their minimum, and the
"product" of two numbers is their ordinary sum. Write $a \oplus b = \min(a,b)$
and $a \odot b = a + b$. It looks like a typo, but it is a perfectly
consistent algebra, and it turns up everywhere: in scheduling and shortest-path
problems, in the geometry of polynomials, and — strikingly — as the exact
algebra describing modern neural networks built from piecewise-linear
activation functions.

Tropical algebra has its own catalog of identities, and many of them are
delightfully counterintuitive. Since "adding" a number to itself means taking
$\min(a,a)$, we get the law of *idempotency*:
$$a \oplus a = a.$$
Addition never accumulates. Multiplication distributes over this new
addition exactly as you'd hope:
$$a \odot (b \oplus c) = (a \odot b) \oplus (a \odot c),$$
which unfolds to the ordinary statement $a + \min(b,c) = \min(a+b, a+c)$.

The crown jewel is what algebraists affectionately call the **tropical
freshman's dream**. In ordinary algebra, the eager student who writes
$(a+b)^2 = a^2 + b^2$ is wrong. In the tropical world, that same student is
*right* — and not just for the square, but for every power:
$$(a \oplus b)^{\,n} = a^{\,n} \oplus b^{\,n} \quad\text{for every } n.$$
Translated back to ordinary numbers, this says $n \cdot \min(p,q) =
\min(np, nq)$, which is true precisely because scaling by a non-negative
number preserves order. (Try it with a negative scale and it fails — a
reminder that the "dream" has fine print.)

The first shortcut, a tactic we call the *tropical simplifier*, mechanizes
all of this. Its core idea is disarmingly simple. There is a faithful
translation `untrop` that carries every tropical number back to an ordinary
number, converting $\oplus$ into $\min$ and $\odot$ into $+$. This translation
is *injective*: two tropical expressions are equal exactly when their
ordinary translations are equal. So to check any min-plus identity, the tactic
translates both sides into ordinary arithmetic and hands the resulting
statement about $\min$ and $+$ to a routine decision procedure for linear
arithmetic. Idempotency, distributivity, absorption, and three-variable
identities all fall instantly. The freshman's dream needs one extra idea —
the monotonicity of scaling — precisely because it steps outside pure linear
arithmetic. That boundary is not a bug; it is the exact line where the easy
part of the theory ends.

The soundness guarantee is a single, quotable fact: the translation `untrop`
is injective and turns $\oplus, \odot$ into $\min, +$. Because every rewrite the
tactic performs is one of these proven identities, any goal it closes is
genuinely true, and any goal it *produces* is logically equivalent to the one
it started with. The shortcut invents nothing and loses nothing.

## Shortcut two: recognizing primes, with a receipt

How do you know that $97$ is prime? You check that no smaller number (other
than $1$) divides it. That is *trial division*, the oldest primality test
there is, and for small numbers it is unbeatable in its simplicity.

The subtle point is trust. A computer can announce "97 is prime" in a
microsecond, but *why* should you believe it? The announcement is only as
trustworthy as the code that produced it — and code can have bugs. The second
shortcut, a tactic we call the *number-theory decider*, closes this gap by
turning the announcement into a *receipt* that can itself be checked.

Here is the construction. We define an explicit yes/no test. Say a number $n$
"has a proper divisor" if there is some $d$ with $2 \le d < n$ that divides
$n$. Then declare $n$ to pass the trial-division test exactly when $n \ge 2$
and $n$ has no proper divisor. This is a completely concrete, mechanically
computable predicate — no cleverness, just a scan over candidate divisors.

The heart of the matter is a theorem, proved once, stating that this humble
test agrees with genuine primality on the nose:
$$\textsf{trialPrime}(n) = \textsf{true} \iff n \text{ is prime.}$$
The proof is not a shrug. Both directions require translating between "the
scan found no divisor" and the mathematical definition "every divisor below
$n$ equals $1$." With that equivalence established, the tactic works by
*reflection*: to prove that $97$ is prime, it rewrites the goal into "the
trial-division test returns true for $97$," and then simply *runs* the test.
The computation is checked by the same trusted core that checks every other
step, so the primality claim comes with a receipt that leaves no room for a
hidden bug. The same machinery certifies non-primality too: it cheerfully
confirms that $91 = 7 \times 13$ is *not* prime.

This is more than a party trick. Verified cryptographic libraries increasingly
demand not merely "the answer is correct" but "here is a checkable reason it is
correct." A self-certifying primality test is exactly such a reason, delivered
in a form a machine can independently audit.

## Shortcut three: fencing in the eigenvalues

Our third shortcut lives in linear algebra. A square matrix $A$ acts on
vectors by stretching, rotating, and shearing them. Certain special
directions — the *eigenvectors* — are merely scaled, not turned: applying $A$
to such a vector $v$ just multiplies it by a number $\lambda$, its
*eigenvalue*, so that $Av = \lambda v$. Eigenvalues govern an enormous range
of phenomena: whether a bridge resonates, whether an iterative algorithm
converges, whether a diffusion process settles down or blows up. Knowing
even a rough bound on how large an eigenvalue can be is often decisive.

There is a beautifully elementary bound. For each row of the matrix, add up
the absolute values of its entries; call this the row's *absolute row sum*.
The claim is that **no eigenvalue can be larger in magnitude than the biggest
absolute row sum**:
$$|\lambda| \le \max_i \sum_j |A_{ij}|.$$
This is the accessible half of a classical result known as the Gershgorin
circle theorem, and its proof is a small gem. Take an eigenvector $v$, and
look at the coordinate $i_0$ where $v$ is largest in absolute value. The
$i_0$-th line of the equation $Av = \lambda v$ reads
$\lambda\, v_{i_0} = \sum_j A_{i_0 j}\, v_j$. Take absolute values and apply
the triangle inequality:
$$|\lambda|\,|v_{i_0}| = \Big|\sum_j A_{i_0 j} v_j\Big| \le \sum_j |A_{i_0 j}|\,|v_j| \le \Big(\sum_j |A_{i_0 j}|\Big)\,|v_{i_0}|,$$
where the last step uses that $|v_{i_0}|$ is the largest coordinate. Since a
genuine eigenvector is nonzero, that largest coordinate is strictly positive,
so we may divide it out and conclude $|\lambda| \le \sum_j |A_{i_0 j}|$, which
is at most the maximum row sum.

The third shortcut, a tactic we call the *spectral bounder*, packages this
argument into a single move. Given a goal of the form "this eigenvalue has
magnitude at most $B$," it applies the proven bound and reduces everything to
checking that each absolute row sum is at most $B$ — a purely mechanical
verification. Because the tactic is nothing but an application of the proved
theorem, every bound it produces is guaranteed correct. The mathematical
content — the argmax coordinate, the triangle inequality, the division by a
strictly positive number — has been discharged once, so the user never has to
revisit it.

## The common thread

Three shortcuts, three worlds — but one idea. In each case we did not merely
*write* an automated procedure; we *proved* that the procedure can only ever
tell the truth. The tropical simplifier is sound because a faithful,
injective translation underlies every rewrite it makes. The number-theory
decider is sound because its yes/no test has been proved equivalent to true
primality. The spectral bounder is sound because it is a thin wrapper around a
proved inequality.

This is the difference between a fast answer and a trustworthy one. Automation
that is merely fast can be subtly, dangerously wrong; automation that is
*proved sound* extends a mathematician's reach without extending their risk.
As machines take on more of the routine labor of mathematics — and of the
software that mathematics increasingly underwrites — this discipline of
verified shortcuts is what lets us hand over the tedium while keeping the
certainty. The shortcuts do the work. The theorems make sure the work is right.
