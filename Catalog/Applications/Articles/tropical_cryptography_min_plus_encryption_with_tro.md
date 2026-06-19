# The Cryptosystem That Wore Its Secret on Its Sleeve

## A code that hid a key in the way numbers add up

Every secure conversation on the internet rests on a simple, almost magical
idea: some computations are easy to do but practically impossible to undo. It
is trivial to multiply two enormous prime numbers together; it is staggeringly
hard to take the product and recover the primes. That single asymmetry — easy
forward, hopeless backward — is the engine behind the padlock icon in your
browser.

But the engine is showing its age. The classic asymmetries that protect us
today, like factoring and the ordinary discrete logarithm, will crumble the
moment a large quantum computer arrives. So cryptographers have gone hunting
for *new* kinds of one-way streets, ones a quantum machine cannot speed back
down. The search has reached into surprising corners of mathematics. One of
the most exotic destinations is **tropical algebra** — a strange arithmetic
where addition and multiplication are quietly swapped for something else.

This is the story of a tropical cryptosystem that looked promising, the precise
conjecture that it would be secure, and the clean mathematical reason it is
not. The secret it was meant to hide turns out to be sitting in plain view,
encoded in a single number you can read straight off the public data. We will
build the whole argument from scratch, and by the end you will be able to break
the scheme yourself with a pocket calculator.

## A world where "plus" means "minimum"

Tropical arithmetic begins with a playful act of vandalism on ordinary algebra.
Take the real numbers, and redefine the two basic operations:

- Wherever you used to **add**, instead take the **minimum**.
- Wherever you used to **multiply**, instead **add**.

So "2 plus 5" becomes `min(2, 5) = 2`, and "2 times 5" becomes `2 + 5 = 7`.
This min-plus world (some prefer the mirror-image max-plus version) is called
the **tropical semiring**. The name has nothing to do with the weather; it was
coined in honor of the Brazilian mathematician Imre Simon, and it stuck.

Why would anyone mutilate arithmetic like this? Because the result is
spectacularly useful. The tropical world is the natural home of *optimization*.
If the weight of a path through a network is the ordinary sum of its edge
weights, and you want the *shortest* such path, then you are taking a minimum
over sums — which is exactly a tropical multiplication followed by a tropical
addition. Shortest paths, scheduling, dynamic programming, even the geometry of
certain algebraic curves: all of them speak min-plus.

This connection to optimization is what attracted cryptographers. Many hard
optimization problems are genuinely hard. If you could bottle that hardness
into a key-exchange protocol, you might get security for free.

## Tropical matrices and their strange powers

To build a cryptosystem we need objects to compute with. The natural choice is
**tropical matrices**: square grids of real numbers, multiplied with the
tropical rules. If `A` and `B` are two such matrices, their tropical product
`A ⊗ B` is defined entry by entry by replacing the usual "sum of products" with
a "minimum of sums":

> **Tropical matrix product.** The `(i, j)` entry of `A ⊗ B` is
> `min over all k of ( A(i,k) + B(k,j) )`.

Read that as: to get from row `i` to column `j`, hop through some intermediate
index `k`, paying `A(i,k)` to get there and `B(k,j)` to continue, and choose the
cheapest hop. If `A` is the weight matrix of a network, then `A ⊗ A` is exactly
the matrix of cheapest two-step trips. Tropical matrix multiplication *is*
shortest-path computation in disguise.

Now we can form **tropical powers**. Just as `A^3` means `A × A × A` in ordinary
algebra, the tropical power `A^{⊗k}` means `A ⊗ A ⊗ ... ⊗ A` with `k` factors.
Concretely, `A^{⊗k}` records the cheapest `k`-step journeys between every pair of
points. Crucially, you can compute it *fast*. By repeated squaring —
`A^{⊗2}`, then `A^{⊗4}`, then `A^{⊗8}`, and so on — you reach `A^{⊗k}` in only
about `log k` multiplications, each costing on the order of `n³` arithmetic
operations for an `n × n` matrix. So the forward direction is cheap even for
astronomically large exponents.

And tropical powers behave: they obey the same exponent laws you would expect.

> **Power multiplicativity.** `A^{⊗a} ⊗ A^{⊗b} = A^{⊗(a+b)}`.
>
> **Commutativity of powers.** `(A^{⊗a})^{⊗b} = (A^{⊗b})^{⊗a} = A^{⊗ab}`.

That second identity is the whole reason a key exchange is even possible, as we
are about to see.

## The protocol: a tropical handshake

The proposal mimics the famous Diffie–Hellman key exchange, the protocol that
lets two strangers agree on a shared secret over a public channel while an
eavesdropper listens to every word.

Here is the tropical version. A matrix `A` is published for everyone to see.

1. **Alice** secretly picks an integer `a`, computes `A^{⊗a}`, and sends it
   across the open channel.
2. **Bob** secretly picks an integer `b`, computes `A^{⊗b}`, and sends it too.
3. **Alice** takes Bob's matrix and raises it to her secret power: `(A^{⊗b})^{⊗a}`.
4. **Bob** takes Alice's matrix and raises it to his: `(A^{⊗a})^{⊗b}`.

By the commutativity of powers, both arrive at the same matrix `A^{⊗ab}`. That
shared matrix becomes their secret key. The eavesdropper, by contrast, has seen
only `A`, `A^{⊗a}`, and `A^{⊗b}`. To compute `A^{⊗ab}` they would seemingly need
to find `a` or `b` from the public data.

That last step is the security assumption. It is called the **Tropical Discrete
Logarithm Problem (TDLP)**:

> **TDLP.** Given a public matrix `A` and the power `B = A^{⊗k}`, recover the
> exponent `k`.

The conjecture that launched the scheme was that the TDLP is hard — that for a
random tropical matrix of modest size (say `10 × 10` or larger), no efficient
algorithm can dig the exponent `k` out of `(A, B)`. If that were true, the
tropical handshake would be a candidate for post-quantum security.

It is not true. And the reason is beautiful.

## The crack: eigenvalues that simply add up

The vulnerability lives in the **spectral theory** of tropical matrices — their
analog of eigenvalues and eigenvectors.

In ordinary linear algebra, an eigenvector `v` of a matrix `A` is a special
direction that the matrix merely stretches: `A v = λ v`, where the stretch
factor `λ` is the eigenvalue. The tropical world has a perfect mirror. First we
need the tropical action of a matrix on a vector:

> **Tropical matrix–vector product.** The `i`-th entry of `A ⊗ v` is
> `min over all k of ( A(i,k) + v(k) )`.

Then "stretching by `λ`" becomes "adding `λ` to every coordinate," because in
the tropical dictionary multiplication is addition. So:

> **Tropical eigenpair.** A pair `(λ, v)` is a *tropical eigenpair* of `A` if
> `(A ⊗ v)_i = v(i) + λ` for every coordinate `i`.

The number `λ` is the tropical eigenvalue, and `v` is its eigenvector. Such
eigenpairs are not rare curiosities; they exist for broad, natural families of
matrices. For instance, if a matrix has a constant value `d` down its diagonal
and its off-diagonal entries are not too small, then `(d, v)` is an eigenpair
for a suitable vector `v`. Eigenvalues are everywhere.

Now watch what happens when you take powers. Apply the matrix to its
eigenvector once, and every coordinate goes up by `λ`. Apply it again, and they
go up by another `λ`. After `m` applications, every coordinate has risen by
exactly `m·λ`. Formally:

> **Iterated action on an eigenvector.** If `(λ, v)` is an eigenpair of `A`,
> then applying the tropical action `m` times gives, in every coordinate,
> `v(i) + m·λ`.

But applying the action `m` times is the same as acting once with the `m`-th
tropical power `A^{⊗m}`. (This is the tropical echo of the familiar fact that
`A^m v = A(A(...(A v)))`.) Putting the two together yields the punchline of the
whole story:

> **Eigenvalue additivity.** If `(λ, v)` is a tropical eigenpair of `A`, then
> `(m·λ, v)` is a tropical eigenpair of `A^{⊗m}`. In words: **raising the matrix
> to the power `m` multiplies its eigenvalue by `m`.**

This single identity, `λ(A^{⊗m}) = m·λ(A)`, is the scheme's undoing. The
tropical eigenvalue is a perfect *homomorphism*: it converts the mysterious
tropical exponentiation `⊗` into ordinary, transparent multiplication by the
exponent. And ordinary multiplication is the easiest thing in the world to
invert — you just divide.

## Reading the secret off the public matrix

Here is the attack in full. The eavesdropper sees the public base `A` and a
public power `B = A^{⊗m}`. They proceed:

1. Find any tropical eigenpair `(λ, v)` of `A` — and compute `λ`, the eigenvalue
   of the base. (For tropical matrices this is a fast computation, equivalent to
   finding the minimum mean cycle in the associated weighted graph — a
   classical, polynomial-time graph problem.)
2. Read the eigenvalue of the public power `B`. By eigenvalue additivity it
   equals `m·λ`.
3. Divide: `m = λ(B) / λ(A)`.

The secret exponent falls out in closed form. No search, no guessing, no
exponential blowup. As long as `λ(A)` is not zero, the division is legal and the
answer is exact. This is the central theorem, stated cleanly:

> **Exponent recovery.** Let `(λ, v)` be a tropical eigenpair of `A` with
> `λ ≠ 0`, and let `B = A^{⊗m}`. Then, reading the eigenvalue residual of `B` on
> the eigenvector `v` and dividing by `λ`, one recovers exactly `m`.

The "residual" here is just the amount each coordinate of `v` grows under the
action of `B`, which equals `m·λ`; dividing by `λ` returns `m`. The conjecture
that the TDLP is hard is therefore **false** for every instance that has an
eigenvector with a nonzero eigenvalue — which is the overwhelmingly typical case.

## A concrete break you can check by hand

Abstractions are convincing, but a worked example is decisive. Consider the
smallest interesting case, a `2 × 2` tropical matrix with `1` on the diagonal
and `100` off the diagonal:

```
A =  [  1   100 ]
     [ 100    1  ]
```

Take the all-zero vector `v = (0, 0)`. Let us check it is an eigenvector. The
tropical action computes, in each coordinate, the minimum of `(diagonal entry +
0)` and `(off-diagonal entry + 0)`, that is `min(1, 100) = 1`. So `A ⊗ v = (1,
1) = v + 1`. The eigenvalue is `λ = 1`.

By eigenvalue additivity, the power `A^{⊗m}` has eigenvalue `m` on the same
vector. So if Alice publishes `A^{⊗m}` for *any* secret `m`, the eavesdropper
acts with it on `(0, 0)`, reads off the growth `m`, divides by `λ = 1`, and
recovers `m` exactly. Every exponent leaks, perfectly, every time. This is not a
statistical weakness or an approximate attack; it is an identity. The formal
version of this example confirms that the measured value on the public power is
precisely `m`, for all `m` at once.

## The one place the secret could hide — and why it is useless

Is there *any* escape? The recovery step divides by `λ(A)`, so it fails in
exactly one situation: when `λ(A) = 0`. This is the boundary case, and it is
worth understanding because it marks the precise frontier of the scheme's
hardness.

When the eigenvalue is zero, additivity reads `m·0 = 0`. The eigenvector grows
by nothing, no matter how large the exponent. The residual is identically zero
for *every* `m`:

> **Boundary no-leak.** If `(0, v)` is an eigenpair of `A`, then for every
> exponent `m` the residual of `A^{⊗m}` on `v` is `0`.

At first glance this looks like good news for the defender: the attack carries
no information, because all exponents produce the same null signature. But the
cure is worse than the disease. A zero eigenvalue means the eigenvector is a
*tropical fixed point*: the matrix leaves it completely unchanged, so
`A^{⊗m} ⊗ v = v` for all `m`. The very operation that was supposed to scramble
the secret does nothing at all on that orbit. The key space collapses; there is
no secret left to protect. The scheme is either **leaky** (when `λ ≠ 0`, the
exponent is exposed) or **trivial** (when `λ = 0`, the power map is the
identity). There is no secure middle ground.

This dichotomy is sharp. For the natural family of tropical matrices coming from
weighted networks — nonnegative edge weights, zero-cost self-loops — one can
prove that *every* eigenvalue is at most zero, and the value zero is always
attained by the constant vectors. The boundary is not some exotic edge case to
be engineered away; it is baked into the geometry.

## Why this matters

It is tempting to read this as a purely negative result: another cryptographic
proposal joins the graveyard. But the deeper lesson is constructive, and it
echoes a recurring theme in the search for post-quantum security.

A one-way function must *hide* its secret. The fatal flaw of the tropical scheme
is an excess of **structure**: the eigenvalue map is a homomorphism, a
structure-preserving bridge from the complicated world of tropical powers to the
trivial world of ordinary multiplication. Homomorphisms are the cryptographer's
double-edged sword. They make protocols *work* — the commutativity that lets
Alice and Bob agree on a key is itself a structural identity — but the same
structure that enables the handshake can betray the secret. The art of building
a secure scheme is to retain *just enough* structure to make the protocol
function while denying the attacker any structural shortcut. Tropical powers
keep too much: the exponent passes through the eigenvalue channel completely
unobscured.

There is also a methodological moral. The break here is not a clever
exploitation of a numerical bug or an implementation slip. It is a theorem, and
its negation — the security conjecture — is a theorem's false twin. By stating
the additivity identity precisely, proving it once and for all, and chasing it to
its boundary, we learn not only that *this* scheme fails but *why* any close
relative will fail too. Variants that publish a tropical-linear image of a
secret integer — twisted powers, semidirect-product constructions — inherit the
same eigenvalue homomorphism and the same leak. The frontier of the problem has
been mapped, and it tells future designers exactly which terrain to avoid.

Tropical algebra remains a gorgeous and genuinely useful branch of mathematics,
and the broader dream of post-quantum cryptography is very much alive. But the
tropical discrete logarithm, at least in this form, is a one-way street with a
giant arrow painted on the pavement pointing the way back. The secret it
promised to keep was written, all along, in the way its numbers add up.
