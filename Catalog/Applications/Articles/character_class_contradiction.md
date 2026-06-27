# The Ghost in the Counting Machine: When a Zeta Function Refuses to Vanish

## A number that should have been zero

There is a kind of arithmetic that physicists, geometers, and number theorists all
secretly play together, even when they pretend to be working on different problems.
It goes like this: you take some mathematical object — a shape, a system, a matrix —
and you *count* something about it, over and over, at larger and larger scales. Then
you bundle all of those counts into a single, infinitely long expression called a
**zeta function**, and you stare at it until it tells you a secret.

This article is about a tiny object that tells a surprisingly loud secret. The object
is almost embarrassingly small: a $2 \times 2$ grid of ones,

$$A = \begin{pmatrix} 1 & 1 \\ 1 & 1 \end{pmatrix}.$$

That's it. Four ones. And yet, when we run this matrix through the zeta-function
machine, it produces a clean, beautiful answer — and along the way it *demolishes* a
tempting but wrong intuition that anyone who has dabbled in this area might be forgiven
for holding. The wrong intuition says: "the interesting count happens only once, at the
first level; after that, everything should cancel to zero." The matrix $A$ says:
"absolutely not." And it proves it.

Let us follow the argument from the ground up. No prior knowledge of zeta functions is
required — only a willingness to multiply a few small matrices.

## Counting by taking traces

The first move in this game is to decide what we are counting. When mathematicians
study a system that can be iterated — a map applied again and again, a dynamical system
ticking forward in time, or the symmetries of a geometric object seen at successive
scales — the natural thing to count is the number of configurations that "close up"
after $r$ steps. Periodic orbits. Fixed configurations. Closed paths.

For a matrix, there is a single number that captures this idea perfectly: the **trace**
of its $r$-th power. The trace of a square matrix is just the sum of its diagonal
entries, and the trace of $A^r$ counts, in a precise combinatorial sense, the number of
length-$r$ closed walks in the network encoded by $A$. We will call these counts

$$N_r = \operatorname{trace}(A^r).$$

So before we do anything clever, let's compute. Our matrix $A$ has a special property
that makes its powers trivially easy to understand. Multiply $A$ by itself:

$$A^2 = \begin{pmatrix} 1 & 1 \\ 1 & 1 \end{pmatrix}\begin{pmatrix} 1 & 1 \\ 1 & 1 \end{pmatrix} = \begin{pmatrix} 2 & 2 \\ 2 & 2 \end{pmatrix} = 2A.$$

This is the heartbeat of the whole story. Squaring $A$ just doubles it. In symbols,

$$A \cdot A = 2A,$$

a fact that in our formal development is recorded as the theorem **`A_mul_A_eq_two_mul_A`**.
Once you know this, every higher power falls into line like dominoes. Since $A^2 = 2A$,
we get $A^3 = A \cdot A^2 = A \cdot 2A = 2A^2 = 4A$, and $A^4 = 8A$, and in general

$$A^{n+1} = 2^n A.$$

That clean formula is the theorem **`A_pow_succ`**: every power of $A$ is just $A$ scaled
by a power of two. The matrix never grows new shapes; it only inflates.

Now the trace. The diagonal of $A$ is $1 + 1 = 2$, so $\operatorname{trace}(A) = 2$
(the theorem **`trace_A`**). And because $A^{n+1} = 2^n A$, taking the trace of both
sides and using the fact that trace plays nicely with scaling gives

$$N_r = \operatorname{trace}(A^r) = 2^{r}, \qquad \text{for every } r \ge 1.$$

This is the theorem **`trace_pow_two_shift`**. The point counts are
$N_1 = 2,\ N_2 = 4,\ N_3 = 8,\ N_4 = 16, \dots$ — the powers of two, marching off to
infinity. Nothing vanishes. Nothing cancels.

## The fine print at step zero

There is one delicious subtlety, and it is worth pausing on because it is exactly the
kind of detail that separates a correct theorem from a plausible-sounding mistake.

The formula $N_r = 2^r$ holds for $r \ge 1$, but **not** at $r = 0$. Why? Because
$A^0$, by universal convention, is the identity matrix $\begin{pmatrix} 1 & 0 \\ 0 & 1 \end{pmatrix}$,
whose trace is $1 + 1 = 2$. But $2^0 = 1$. So at the very bottom rung we have
$\operatorname{trace}(A^0) = 2 \ne 1 = 2^0$. The pattern $2^r$ is off by one at the start.

This is not a flaw; it is a feature, and the formal statement is honest about it: the
theorem **`trace_pow_two_shift`** explicitly carries the hypothesis $1 \le r$. As we'll
see, the zeta function we build is engineered so that the $r = 0$ term is multiplied by
zero and never matters — but a careless writer who forgot the fine print would have
"proved" a false identity. Precision here is the difference between mathematics and
hand-waving.

## Folding the counts into a zeta function

We have an infinite list of counts, $N_1, N_2, N_3, \dots$. The zeta function is the
ritual that compresses this list into one object. Following the recipe used everywhere
from the Weil conjectures in algebraic geometry to the Ruelle–Bowen theory of
dynamical systems, we define

$$Z(t) = \exp\!\left( \sum_{r \ge 1} \frac{N_r}{r}\, t^r \right).$$

The exponential and the division by $r$ look fussy, but they are precisely what turn a
sum of *counts* into a *product over the underlying orbits* — the same algebraic trick
that makes the Riemann zeta function factor into a product over primes. For our matrix,
substitute $N_r = 2^r$ and watch what happens. The exponent becomes

$$\sum_{r \ge 1} \frac{(2t)^r}{r}.$$

Anyone who has met calculus will recognize this. The series $\sum_{r \ge 1} x^r / r$ is
the Taylor expansion of $-\log(1 - x)$, valid whenever $|x| < 1$. With $x = 2t$, the
exponent is exactly $-\log(1 - 2t)$, and exponentiating undoes the logarithm:

$$Z(t) = \exp\bigl(-\log(1 - 2t)\bigr) = \frac{1}{1 - 2t}.$$

This is the centerpiece, the theorem **`zeta_function`**: for $|t| < \tfrac12$ (the radius
where the defining series converges),

$$Z(t) = \frac{1}{1 - 2t}.$$

A messy infinite sum of powers of two, wrapped in an exponential, collapses into a
single elementary fraction. This is the magic that zeta functions exist to perform:
they take an infinite amount of counting data and reveal that it was secretly governed
by a simple **rational function** — a ratio of polynomials. The denominator $1 - 2t$ is
the whole story.

## Reading the denominator: the spectral determinant

Where does that denominator $1 - 2t$ come from, structurally? Not from summing a series,
but from a determinant — and this is the bridge between counting and linear algebra.

Consider the matrix $1 - tA$, meaning the identity minus $t$ times $A$:

$$1 - tA = \begin{pmatrix} 1 - t & -t \\ -t & 1 - t \end{pmatrix}.$$

Its determinant is $(1-t)^2 - (-t)(-t) = (1 - 2t + t^2) - t^2 = 1 - 2t$. So

$$\det(1 - tA) = 1 - 2t,$$

which is the theorem **`det_one_sub_t_mul_A`**. And there it is: the denominator of the
zeta function is exactly this determinant. This is no coincidence. It is a baby case of
a profound identity — sometimes called the *Bowen–Lanford formula* in dynamics, and a
cousin of the Weil conjectures' rationality statement in geometry — which says that the
exponential-of-traces construction always equals the reciprocal of a characteristic
polynomial:

$$\exp\!\left( \sum_{r \ge 1} \frac{\operatorname{trace}(A^r)}{r}\, t^r \right) = \frac{1}{\det(1 - tA)}.$$

The eigenvalues of $A$ are $0$ and $2$ (you can read this off: $\det(1 - tA) = (1-0\cdot t)(1 - 2t)$).
The eigenvalue $0$ contributes nothing to the counts, and the eigenvalue $2$ contributes
everything. The zeta function is, in disguise, a portrait of the spectrum.

## The contradiction

Now we can name the "Character Class Contradiction" that gives this story its title.

There is a seductive expectation, common when one first meets rank-one or otherwise
"degenerate" objects, that the only genuine information lives at the first level, and
that higher levels should produce *nothing* — that the counts $N_r$ should vanish for
all $r \ne 1$. In the language of characteristic classes and zeta functions, one might
guess that a rank-one object has a trivial "higher signature," that everything beyond
the first trace cancels to zero.

Our matrix is the perfect test case, because it really is rank one — its two rows are
identical, so it carries only one dimension's worth of information. If any matrix were
going to have vanishing higher counts, surely it would be this one.

It doesn't. The theorem **`naive_expectation_false`** states, flatly, that it is **not**
true that $\operatorname{trace}(A^r) = 0$ for all $r \ne 1$. The proof is a single
counterexample with no wiggle room: at $r = 2$,

$$\operatorname{trace}(A^2) = 2^2 = 4 \ne 0.$$

Four is not zero. The naive expectation is dead. And notice *how* it dies: not by some
exotic obstruction, but because rank-one degeneracy does not mean dynamical triviality.
A rank-one matrix can still have a nonzero eigenvalue — here, the eigenvalue $2$ — and
that single surviving eigenvalue powers an entire infinite tower of nonzero counts
$2, 4, 8, 16, \dots$. Degeneracy in *space* (rank one) is not the same as triviality in
*time* (the iterated counts). Conflating the two is the error, and the matrix $A$ is the
proof.

## Why such a small example matters

It would be easy to dismiss four ones in a box as a toy. But the lesson scales. The
identity

$$\exp\!\left( \sum_{r \ge 1} \frac{N_r}{r}\, t^r \right) = \frac{1}{\det(1 - tA)}$$

is the same identity that, for matrices of zeros and ones, computes the zeta functions of
**subshifts of finite type** — the symbolic dynamical systems that model everything from
data compression to the orbits of chaotic maps. Our $A$ is, up to relabeling, the
counting matrix of the *full shift on two symbols*: a system whose length-$r$ words
number exactly $2^r$. The same matrices reappear in operator algebra as the defining
data of **Cuntz–Krieger algebras**, where the determinant $\det(1 - A) = 1 - 2 = -1$
controls a deep invariant ($K$-theory) of an infinite-dimensional algebra. One small
matrix, and it simultaneously governs a dynamical count, a rational zeta function, and an
algebraic invariant. That triple coincidence is the real reason mathematicians care.

And the contradiction we proved is a permanent guardrail. Every time someone studies a
degenerate object and is tempted to declare its higher invariants trivial "by symmetry,"
this example stands as a warning: compute the trace of the square first. If it is not
zero, the symmetry argument is wrong, and the object has an infinite, geometric tower of
structure hiding inside it.

## The shape of the truth

Let us collect what we have established, all of it proven with full rigor:

- **The quadratic relation:** $A^2 = 2A$.
- **The powers:** $A^{n+1} = 2^n A$, so every power of $A$ is a scaled copy of $A$.
- **The trace and the counts:** $\operatorname{trace}(A) = 2$, and $N_r = \operatorname{trace}(A^r) = 2^r$ for every $r \ge 1$.
- **The spectral determinant:** $\det(1 - tA) = 1 - 2t$.
- **The zeta function:** $Z(t) = \dfrac{1}{1 - 2t}$ for $|t| < \tfrac12$.
- **The contradiction:** it is false that $\operatorname{trace}(A^r) = 0$ for all $r \ne 1$; indeed $\operatorname{trace}(A^2) = 4$.

There is a particular pleasure in a result this clean. We started with the dullest
matrix imaginable — four ones — and by asking it the right question, we extracted an
infinite sequence, a transcendental-looking exponential series, and a rational
function, all locked together by a single eigenvalue. Along the way we caught a
plausible falsehood in the act and dispatched it with one line of arithmetic.

The deepest theorems in number theory and geometry — the Weil conjectures, the
rationality of zeta functions over finite fields, the trace formulas of dynamical
systems — are all, in their hearts, statements that *counting at every scale is secretly
governed by a few eigenvalues*. The matrix of four ones is the smallest honest window
onto that idea. Look through it, and you can see the whole cathedral.
