# The Silent Arithmetic: How "Min-Plus" Algebra Hides — and Sometimes Reveals — a Secret

## A different way to add and multiply

Imagine a world where arithmetic has been quietly rewired. Instead of adding two
numbers, you keep the **smaller** of them. Instead of multiplying, you **add**.
In this world the number 3 "times" 5 is 8, and 3 "plus" 5 is 3. It sounds like a
joke, but mathematicians take it seriously enough to give it a name: the
**tropical** (or **min-plus**) semiring. The word "tropical" is a tribute to the
Brazilian mathematician Imre Simon, who pioneered the subject; there is nothing
hot about it beyond the name.

Why on earth would anyone replace honest addition and multiplication with `min`
and `+`? Because this strange arithmetic is the native language of the *shortest
path*. If `A(i,k)` is the length of a road from city `i` to city `k`, and `v(k)`
is the cost of finishing your journey from `k`, then the cheapest way to start at
`i` is

> the **minimum**, over all first stops `k`, of `A(i,k) + v(k)`.

That single expression — a minimum of sums — is exactly tropical
matrix–vector multiplication. Highway planners, internet routers, and
scheduling algorithms all secretly compute in the tropical semiring. In this
article we write `A ⊗ v` for this operation, where

> **(A ⊗ v)ᵢ = minₖ ( A(i,k) + v(k) ).**

Multiplying two matrices works the same way: `(A ⊗ B)(i,j) = minₖ (A(i,k) +
B(k,j))`, which finds the cheapest two-hop route from `i` to `j`.

## The dream of tropical cryptography

Here is the seductive idea that motivates everything below. Ordinary
cryptography — the padlock on your bank's website — rests on arithmetic that is
*easy in one direction and hard to reverse*. Multiplying two large primes is
quick; factoring their product back apart is, as far as we know, hopeless for a
classical computer. But quantum computers threaten exactly this kind of problem,
and the world is hunting for **post-quantum** alternatives whose hardness does
not melt away on a quantum machine.

Tropical arithmetic is a tempting candidate. Computing `A ⊗ B` is fast: just
`n³` additions and comparisons. Going *backwards* — recovering the factors `A`
and `B` from their tropical product — is genuinely murky, because the product
forgets information. In fact one can prove that **infinitely many different pairs
of matrices share the same tropical product**: for any target `C` there are
matrices `A, B, A', B'` with `A ⊗ B = C` and `A' ⊗ B' = C` but `A ≠ A'`. The
forward map is many-to-one, so naive inversion is doomed. This is precisely the
flavor a cryptographer wants from a "one-way function."

The proposal that follows from this is a tropical version of the famous
Diffie–Hellman key exchange. Pick a public matrix `A`. Alice secretly raises it
to a tropical power `a` (multiply `A` by itself `a` times, tropically) and
publishes `A⊗ᵃ`. Bob does the same with a secret `b` and publishes `A⊗ᵇ`. Each
can then form the shared key `A⊗ᵃᵇ`. An eavesdropper who sees `A`, `A⊗ᵃ`, and
`A⊗ᵇ` must recover a secret exponent — the **tropical discrete logarithm
problem** — which is conjectured to be hard.

## The crack in the wall: eigenvalues

Every beautiful cryptographic dream needs a stress test, and the natural attack
on the tropical discrete logarithm runs through **eigenvalues**.

In ordinary linear algebra, an eigenvector `v` of a matrix `A` is a special
direction that the matrix merely stretches: `A v = λ v`, where the number `λ` is
the eigenvalue. Tropical algebra has its own version. A pair `(λ, v)` is a
**tropical eigenpair** of `A` when applying the matrix simply adds the same
constant `λ` to every coordinate of `v`:

> **(A ⊗ v)ᵢ = vᵢ + λ for every i.**

Here `λ` plays the role of a per-step "drift." And crucially, tropical
eigenvalues are *additive under powers*: the eigenvalue of `A⊗ᵏ` is exactly `k`
times the eigenvalue of `A`. If you can read off `λ(A⊗ᵏ)` and you know `λ(A)`,
you simply divide:

> **k = λ(A⊗ᵏ) / λ(A).**

The secret exponent falls out in one step. The eavesdropper wins — *provided the
eigenvalue is not zero.* The entire security of the scheme balances on the
knife-edge value `λ = 0`. Understanding that boundary, rigorously, is the heart
of the mathematics we present here.

## Measuring the leak: the tropical residual

To talk precisely about what an attacker can *measure*, we need an honest notion
of subtraction. Tropical algebra famously has none — there is no number you can
"min" with 5 to undo it. But there is one place where ordinary subtraction
carries real meaning: the **residual**. Given a matrix `A` and a vector `v`,
define, coordinate by coordinate,

> **tropResidual(A, v)ᵢ = (A ⊗ v)ᵢ − vᵢ.**

This is the gap between where the tropical map sends coordinate `i` and where
that coordinate started. It is exactly the signal a side-channel attacker might
hope to read off a running tropical computation. And it has a clean meaning.

**Result 1 (the residual *is* the eigenvalue).** If `(λ, v)` is a tropical
eigenpair of `A`, then the residual equals `λ` at *every single coordinate*:
`tropResidual(A, v)ᵢ = λ` for all `i`. (In the formal development this is the
theorem `tropResidual_eq_eigenvalue`.)

This is wonderful and dangerous at once. Wonderful, because it confirms the
attack: the eigenvalue is sitting in plain sight, identical in every coordinate,
ready to be averaged out of noisy measurements. Dangerous for the same reason.
An immediate consequence is that **the eigenvalue is uniquely determined by the
eigenvector**: if both `(λ, v)` and `(μ, v)` are eigenpairs of the same `A` with
the same `v`, then `λ = μ` (the theorem `tropical_eigenvalue_unique`). There is
no ambiguity for the attacker to hide behind — except at the boundary.

## The boundary theorem: why zero is special

So when is `λ = 0`? First, a clean characterization.

**Result 2 (zero means "fixed").** A pair `(0, v)` is a tropical eigenpair of `A`
exactly when `v` is a **fixed point** of the tropical map — that is, `A ⊗ v = v`,
unchanged in every coordinate (`eigenzero_iff_fixed`). Zero drift means the
vector simply stands still under repeated application of `A`. In fact, applying
`A` any number of times `k` leaves it exactly where it was: `A⊗ᵏ ⊗ v = v`
(`eigenzero_iterate`).

Now the punchline, the result that gives this package its name.

**Main Result (eigenzero_no_leak).** *At the boundary eigenvalue `λ = 0`, the
tropical residual vanishes identically.* For a fixed-point eigenvector `v`,

> **tropResidual(A, v)ᵢ = 0 for every coordinate i.**

The residual signal — the very quantity an eavesdropper measures to extract the
eigenvalue — is flat zero. It carries **no positional information** about the
secret vector `v` whatsoever. The attack that worked so beautifully when `λ ≠ 0`
collapses to reading off a column of zeros. This is the formal statement of the
intuition that `λ = 0` is the secure regime: there, the eigenvalue channel is
silent.

Why should `λ = 0` be a *natural* place to land, rather than a contrived corner?
Because of the geometry of graphs.

**Result 3 (the boundary theorem).** Consider a weighted directed graph with two
mild, realistic properties: all edge weights are non-negative (distances are not
negative), and every vertex has a zero-weight self-loop (staying put costs
nothing). For such a graph, *every* tropical eigenvalue satisfies

> **λ ≤ 0.**

This is the theorem `digraph_eigenvalue_nonpos`, and its proof is almost a
one-liner once you have the residual: the zero self-loop guarantees that `(A ⊗
v)ᵢ ≤ vᵢ` (you can always "stay home"), so the residual is never positive
(`digraph_residual_nonpos`), and the residual equals the eigenvalue. The
spectrum of any such graph lives entirely at or below zero, with `λ = 0` as its
ceiling — the tropical analogue of a bound on the spectral radius.

And that ceiling is genuinely reached.

**Result 4 (the ceiling is attained).** Every *constant* vector — say `v = (c, c,
…, c)` — is a tropical eigenvector of such a graph, with eigenvalue exactly `0`
(`digraph_eigenzero_const`). Constant vectors stand perfectly still: from any
city, the cheapest move is the free self-loop, so nothing changes.

Put these together and a clear picture emerges. Graph-based tropical systems
naturally accumulate eigenvectors at the `λ = 0` boundary, and precisely there
the eigenvalue side-channel goes dark. The dangerous, easily-attacked regime is
`λ < 0`, where the drift is measurable; the boundary `λ = 0` is the one place the
leak shuts off.

## Why a global shift makes the secret slippery

There is one more structural fact that sharpens the security story. Tropical maps
are **equivariant under a global shift**: if you add the same constant `c` to
every coordinate of `v`, the output simply shifts by `c` too — `A ⊗ (v + c) = (A
⊗ v) + c`. (This is `tropMatVecMul_shift`, the tropical version of "scaling the
input scales the output.")

The consequence is that an eigenvector is never pinned down to a single vector;
it is only ever determined *up to a global offset*. The whole sliding family `v,
v+1, v+2, …` behaves identically. At the boundary `λ = 0` this combines with the
no-leak theorem to make any two boundary eigenvectors — and any shifted copies of
them — produce the *identical* (zero) residual signature. An adversary measuring
residuals cannot tell them apart. The accompanying formal development pushes this
all the way to the min-plus hash function, showing that the hash of a boundary
eigenvector leaks **at most** the single global offset constant and nothing about
the secret's shape.

## A concrete miniature

Let's make this tangible with a tiny three-city example. Put the weight matrix

```
        to A   to B   to C
from A    0      2      5
from B    3      0      4
from C    6      1      0
```

Notice the zeros down the diagonal: free self-loops, as required. All other
weights are positive. Now take the constant vector `v = (7, 7, 7)`.

Apply the tropical map. For city A:
`(A ⊗ v)_A = min(0+7, 2+7, 5+7) = min(7, 9, 12) = 7`.
For city B: `min(3+7, 0+7, 4+7) = min(10, 7, 11) = 7`.
For city C: `min(6+7, 1+7, 0+7) = min(13, 8, 7) = 7`.

The output is `(7, 7, 7)` — unchanged. So `(0, v)` is an eigenpair, the residual
is `(7−7, 7−7, 7−7) = (0, 0, 0)`, and the eigenvalue `λ = 0` is invisible in the
signal. Exactly as the theorems predict. Try instead a *non-constant* vector and
you will generally find a strictly negative residual that betrays a negative
eigenvalue — the leaky regime.

## What it all means

The story this mathematics tells is not "tropical cryptography is broken" nor
"tropical cryptography is safe." It is something more useful: a precise map of
*where the danger lives*. The eigenvalue attack — divide the powered eigenvalue
by the base eigenvalue to recover the secret exponent — is devastatingly
effective whenever the eigenvalue is nonzero. The single point that defeats it is
the boundary `λ = 0`, and there the leak provably vanishes. Because real
graph-based constructions pile up eigenvectors at exactly that boundary, the
boundary is not an exotic special case but the natural design target.

For a would-be designer of post-quantum tropical schemes, the lesson is sharp:
**engineer your secrets to live at the zero-eigenvalue boundary**, where the
eigenvalue channel is silent — and understand that silence on that channel is
*necessary* but not by itself *sufficient* for security. The harder questions —
whether some other channel leaks, whether distinguishing exponents at the
boundary can be reduced to an independently hard problem like tropical matrix
factorization — are exactly where this line of research goes next.

It is a small, beautiful instance of a recurring theme in mathematics: the most
interesting behavior almost always happens at the boundary. Here the boundary is
the value zero, the silence is a column of zeros, and the secret — for once —
keeps its shape.
