# The Cipher That Broke Itself: A Cautionary Tale from Tropical Arithmetic

## A new arithmetic for a nervous age

Every few years, the world of cryptography gets a scare. The encryption that
guards our bank transfers, messages, and state secrets rests almost entirely on
a handful of "hard" mathematical problems — factoring enormous numbers, or
finding hidden exponents inside cyclic groups. These problems are hard for the
computers we have today. But a sufficiently large *quantum* computer would crush
them in an afternoon. So the search is on for **post-quantum cryptography**: new
hard problems, built on exotic algebra, that even a quantum machine cannot
shortcut.

One of the most seductive candidates comes from a strange and beautiful corner
of mathematics called **tropical arithmetic**. It is, at first glance, almost a
prank. You take the arithmetic you learned as a child and rewrite two rules:

- Wherever you used to **add**, now take the **minimum**.
- Wherever you used to **multiply**, now **add**.

So in the tropical world, "2 + 3" is no longer 5 — it is `min(2, 3) = 2`. And
"2 × 3" is no longer 6 — it is `2 + 3 = 5`. This sounds like a typo, but it is a
perfectly consistent algebra (mathematicians call it the *min-plus semiring*),
and it shows up everywhere: in scheduling trains, in computing shortest paths
through a network, in the geometry of evolutionary trees, and in optimization.
The name "tropical" is a tribute to the Brazilian mathematician Imre Simon, with
no deeper meaning — it just stuck.

Because tropical arithmetic looks so unfamiliar, it is tempting to believe it
hides good cryptographic secrets. The intuition goes: ordinary multiplication is
the engine of classical cryptography, so let's swap in *tropical* multiplication
and build a brand-new lock that quantum computers have never been trained to
pick. Several proposals did exactly this. This article is about why one natural
version of that idea **defeats itself** — and how that failure can be turned
into a precise, machine-checkable theorem.

## The lock: a tropical discrete logarithm

Classical cryptography loves a particular kind of asymmetry: an operation that
is easy to *do* but hard to *undo*. The flagship example is the **discrete
logarithm**. Pick a number `g`. Computing `g` raised to a secret power `k` is
fast, even when `k` is astronomically large, because you can square repeatedly.
But going backward — being handed `g` and `g^k` and asked to find `k` — is
believed to be enormously hard. That asymmetry is what lets two strangers, Alice
and Bob, agree on a shared secret over a public channel (the famous
Diffie–Hellman key exchange).

The tropical proposal copies this blueprint. Instead of numbers, you use
**tropical matrices** — grids of integers that multiply using min-and-plus. You
fix a public matrix `A`, and the "power" `A` raised to the `k`-th tropical power,
written `A^(⊗k)`, is the matrix you get by tropically multiplying `A` by itself
`k` times. Computing it is fast: repeated tropical squaring does the job in time
proportional to `log k`. The hope is that recovering the secret exponent `k`
from the pair `(A, A^(⊗k))` is hard. Call this the **Tropical Discrete
Logarithm Problem (TDLP)**. If it were truly hard, you could build a tropical
Diffie–Hellman: Alice publishes `A^(⊗a)`, Bob publishes `A^(⊗b)`, and they both
compute the shared key `A^(⊗ab)`.

It is a lovely picture. And it has a crack running right through it.

## Eigenvalues: the secret leaks through

Here is the crack. Tropical matrices, like ordinary ones, have **eigenvalues**.
In the tropical world an eigenvalue `λ` is a number such that, for some special
vector `v` (an *eigenvector*), applying the matrix to `v` does nothing more than
add `λ` to every coordinate. The vector keeps its shape; it just slides uniformly
upward by `λ`. The set of all multiples of such a `v` is its **eigenline** — a
direction the matrix preserves.

Now watch what happens to eigenvalues under powers. If applying `A` once adds
`λ`, then applying it `k` times adds `λ` exactly `k` times — that is, `k·λ`. In
symbols, the eigenvalue of `A^(⊗k)` is simply `k` times the eigenvalue of `A`.
And *that* is a disaster for the would-be cipher, because it means:

> k = (eigenvalue of A^(⊗k)) ÷ (eigenvalue of A).

The secret exponent is not hidden at all. It is sitting in plain sight as a
ratio of eigenvalues, and tropical eigenvalues can be computed quickly — they
are the "maximum cycle mean" of an associated network, found with classical
shortest-path-style algorithms. The one-way function is, on its eigenline, a
two-way street.

## Stripping the idea to its bones

To see *why* the leak is unavoidable, it helps to shrink the problem until
nothing can hide. Consider the smallest possible tropical matrix: a single box
holding one number `λ`. Applying it to a one-number vector `x` is just tropical
multiplication — that is, ordinary addition:

> the one-box machine sends `x` to `λ + x`.

What does running the machine `k` times do? Each pass adds `λ`, so after `k`
passes you have added `k·λ`:

> **Result 1 (the iterate formula).** Running the one-box machine `k` times sends
> `x` to `k·λ + x`.

This is the entire engine of the supposed cipher, laid bare. The "encryption" is
nothing but *adding a multiple of `λ`*. And addition has an inverse: subtraction.
Suppose the public eigenvalue is `λ = 1` (the simplest non-trivial case). Then
the machine run `k` times sends `x` to `k + x`, and an attacker who sees the
input `x` and the output simply subtracts:

> **Result 2 (instant recovery).** When `λ = 1`, the secret exponent is exactly
> `output − input = k`.

No guessing, no search, no quantum computer. One subtraction. The lock springs
open in a single step.

## It was never about the matrix

A skeptic might object: surely a *big* tropical matrix, with all its tangled
min-plus interactions, is safer than a single box? The surprising answer is no —
not if you happen to be looking along an eigenline. And the reason is a property
shared by *every* sensible tropical-linear map, no matter how large or
complicated.

That property is **scalar equivariance**. It says the machine "respects the
dial": if you turn the dial by adding a constant `c` to every coordinate of your
vector *before* feeding it in, the output is exactly what you'd get by running
the machine first and adding `c` afterward. Tropical matrix multiplication always
has this property, because min-plus multiplication distributes over the uniform
shift. In plain terms: a uniform raise of the input causes the same uniform
raise of the output.

Combine scalar equivariance with an eigenvector — a vector `v` the machine
merely shifts by `λ` — and the whole apparatus collapses to the one-box case.
Here is the clean statement, proved in full generality:

> **Result 3 (the eigenline attack).** Let `F` be *any* scalar-equivariant
> tropical map, and let `v` be an eigenvector with eigenvalue `λ`. Then running
> `F` exactly `k` times on `v` adds `k·λ` to every coordinate of `v` — and
> nothing else. The internal structure of `F` is completely irrelevant.

The matrix can be `10 × 10` or `1000 × 1000`, dense or sparse, random or
hand-crafted. The moment your starting vector lies on an eigenline, the iterated
map forgets everything except the scalar `k·λ`. So the recovery is just as easy
as before:

> **Result 4 (coordinate recovery).** When the eigenvalue is `λ = 1`, the secret
> `k` is read off from *any single coordinate*: subtract that coordinate of the
> input from the same coordinate of the output, and you have `k`.

One coordinate. One subtraction. The size of the matrix buys you nothing.

## Why this matters

It would be easy to read this as a purely negative story — another cryptographic
proposal that didn't survive contact with mathematics. But there are three
reasons it is worth telling.

**First, it is a clean demonstration of a deep principle: homogeneity is the
enemy of secrecy.** The tropical cipher fails not because of some subtle bug but
because its core operation is *linear* in the tropical sense. Linear operations
have eigenvalues, eigenvalues add up under iteration, and additive structure is
trivially invertible. Any cryptographic scheme whose secret operation is too
"linear" — in any algebra, tropical or otherwise — is leaking its secret through
its spectrum. The tropical case just makes the leak vivid because the arithmetic
is so stark.

**Second, the failure points toward what a *good* tropical scheme would need.**
If linearity is fatal, security must come from controlled *non*-linearity: maps
that do **not** respect the dial, vectors that avoid eigenlines, or operations
that mix tropical and classical arithmetic so that no single eigenvalue governs
the dynamics. The counterexample is a design specification written in the
negative — a fence marking exactly where not to build.

**Third, the argument is not a hand-wave.** Every result above has been written
down as a formal mathematical statement and verified down to the last step, with
no appeal to intuition or "it is easy to see." The iterate formula, the instant
recovery, the general eigenline collapse, and the coordinate recovery are all
theorems in the strict sense — checked by a machine that accepts no gaps. When a
cryptosystem is broken, you want certainty that it is broken, and that is exactly
what a formal proof delivers.

## A worked example

Let's make it concrete. Take the one-box machine with `λ = 1`, and suppose Alice's
secret exponent is `k = 7`, applied to a starting value `x = 4`.

Running the machine seven times: `4 → 5 → 6 → 7 → 8 → 9 → 10 → 11`. The output is
`11`, which is indeed `7·1 + 4 = 11`, exactly as Result 1 predicts. An
eavesdropper who sees the public input `4` and the transmitted output `11`
computes `11 − 4 = 7` and instantly knows Alice's secret. That is Result 2 in
action.

Now scale up. Take a `3 × 3` tropical matrix and a vector `v` that happens to be
one of its eigenvectors with eigenvalue `1`, say `v = (0, 5, 2)`. Apply the
matrix seven times. By Result 3 the output must be `(0+7, 5+7, 2+7) = (7, 12, 9)`
— each coordinate raised by `k·λ = 7`, no matter what the nine entries of the
matrix were. The attacker looks at the first coordinate alone: `7 − 0 = 7`. Done.
That is Result 4. The other eight numbers in the matrix never mattered.

## The moral

Tropical arithmetic is genuinely promising terrain for new mathematics, and the
broader hunt for post-quantum cryptography is real and urgent. But novelty is not
the same as security. An unfamiliar algebra can *look* like a fortress while
being, structurally, a screen door. The min-plus discrete logarithm, in its most
natural form, is exactly such a screen door: its secret slides out through the
eigenvalues, and on an eigenline a single subtraction is all it takes.

The lesson generalizes far beyond the tropics. Whenever someone proposes hiding a
secret inside the repeated application of an operation, the first question to ask
is: *what does this operation do to its eigenvectors?* If iteration only scales
them, the secret is the scale factor — and you have built a lock whose key is
written on the front door.
