# Certificates of Existence: From Goldbach's Primes to Hadamard's Matrices

## A tale of two "does it exist?" questions

Mathematics is full of questions that sound deceptively simple. *Can every
even number be written as the sum of two prime numbers?* *For which sizes can
you build a square grid of pluses and minuses whose rows are all mutually
"perpendicular"?* Both questions are about **existence**: they ask whether a
certain kind of object can be assembled out of simpler ingredients.

What's striking is that questions of existence have two completely different
flavors of answer. Sometimes the honest answer is "we have no idea, and the
greatest minds have failed for centuries" — that's Goldbach's conjecture.
Other times the answer is "yes, and here is a *recipe* that builds the object
for infinitely many sizes" — that's the Paley construction for Hadamard
matrices. This article is about a single framework that treats both flavors
with the same currency: the **certificate**, a small bundle of data that a
skeptic can check, line by line, to become convinced the object really exists.

The two stories — prime sums and ±1 matrices — seem unrelated. But they share
a deep methodological spine. In both, the *existence* of a structure is the
hard part, and in both, the right move is to stop arguing about existence in
the abstract and instead **produce a witness and verify it**. That shift, from
"I believe it's true" to "here is a checkable certificate," is the heartbeat of
modern certified mathematics.

---

## Part one: Goldbach, or the stubbornest sum in arithmetic

In 1742, the mathematician Christian Goldbach wrote a letter to Leonhard Euler
with an observation so simple a schoolchild can grasp it:

> **Every even number greater than two is the sum of two primes.**

Try it. 4 = 2 + 2. 10 = 3 + 7. 28 = 5 + 23. 100 = 3 + 97. 1000 = 3 + 997. It
never seems to fail. Computers have now checked it for every even number up
into the quintillions, and not a single counterexample has ever surfaced. Yet
nearly three centuries later, **nobody has proved it**. Goldbach's conjecture
remains one of the oldest open problems in all of mathematics.

So how do you do rigorous, machine-checked work on a problem that no one can
solve? You change the question. Instead of asking the impossible — "prove it
for *all* even numbers at once" — you ask the *finite* version: prove it for
all even numbers up to some bound, and make every single case carry a proof
you can independently audit.

We formalize the core vocabulary precisely. A number `n` is called
**two-prime representable** if there exist primes `p` and `q` with `p + q = n`.
In symbols:

> `TwoPrimeRepresentable n  :=  ∃ p q, Prime p ∧ Prime q ∧ p + q = n`.

The statement "binary Goldbach holds up to `N`" then becomes a crisp, finite
claim:

> `GoldbachUpTo N  :=  for every even n with 4 ≤ n ≤ N, n is two-prime representable`.

Here is the crucial design decision. Rather than treat "is two-prime
representable" as an opaque assertion, we make it **decidable** — a property a
computer can settle with a finite search. To check whether `n` is a sum of two
primes, you only ever need to look at primes below `n`. So the search is bounded,
terminates, and either returns a witness pair `(p, q)` or proves none exists.

The engine is a small, verified search procedure. Conceptually:

> To find a Goldbach pair for `n`, scan candidate primes `p = 2, 3, 5, …`. For
> each one, test whether `n − p` is also prime. The first time both `p` and
> `n − p` are prime, return the pair `(p, n − p)`.

When this returns `(3, 97)` for `n = 100`, it isn't asking you to trust it.
The pair *is* the proof: anyone can confirm that 3 is prime, that 97 is prime,
and that 3 + 97 = 100. That little triple — two primality checks and one
addition — is a **certificate**.

To make certificates first-class citizens, the framework introduces an
`AdditiveBasisCertificate`: a bundle containing a witness function (which, given
`n`, optionally returns a pair) together with three *soundness guarantees* baked
in — the left entry is always prime, the right entry is always prime, and the
two always sum to `n`. The beauty of packaging it this way is **modularity**.
If tomorrow someone extends the verified range from a million to a billion, they
don't need to re-examine the old proofs; they just supply a bigger certificate,
and the soundness guarantees travel with it automatically.

### Two reframings that change how you see the problem

The framework also captures two enriching perspectives.

The first is the **weak (three-prime) version**. A number is *three-prime
representable* if it's a sum of three primes. This isn't an idle variation: the
"every odd number above 5 is a sum of three primes" statement — the *ternary*
Goldbach conjecture — was actually **proved** in 2013 by Harald Helfgott, making
it one of the great recent triumphs of analytic number theory. Our framework
records the three-prime predicate side by side with the two-prime one, so the
solved cousin and the unsolved original live in the same formal home. (In the
companion demo, 27 = 2 + 2 + 23.)

The second is a **graph-theoretic reframing**. Picture every prime up to `N` as
a dot. Draw an edge between two primes whenever their sum is an even number ≤ N.
Now Goldbach's conjecture becomes a *covering* question: do these prime-pair
edges cover every even target between 4 and `N`? The framework defines exactly
this — the set of `goldbachPairsUpTo N` and the `CoveredEvens` they reach — and
the demo confirms that for `N = 50`, the prime-pair graph covers every even
number from 4 to 50 with none left out. Translating a number-theory problem into
a covering problem about a graph is the kind of change of scenery that
occasionally cracks a problem open; at minimum it gives a new place to look.

The honest summary: Goldbach itself is still open. What the framework delivers
is the *infrastructure of certainty* around it — decidable predicates, an
auditable search, soundness-carrying certificates, and two reformulations — so
that every finite claim we *can* make is machine-checkable down to the last
addition.

---

## Part two: Hadamard, or the perfect arrangement of pluses and minuses

Now flip to a question where the answer is a resounding, constructive **yes**.

Imagine a square grid filled with only `+1` and `−1`. Call it a **Hadamard
matrix** if every pair of rows is "perpendicular" — meaning if you multiply two
different rows entry by entry and add up the results, you always get zero. The
rows are as different from each other as it is possible to be. Compactly, an
`n × n` matrix `H` of ±1's is Hadamard when

> `H · Hᵀ = n · I`,

where `I` is the identity matrix. These objects are not mathematical
curiosities. They are the backbone of **error-correcting codes** that let the
Voyager spacecraft beam pictures across billions of kilometers, of the spreading
codes in CDMA cellphone networks, and of optimal designs in statistics where you
want to extract maximum information from minimum measurement.

There's an immediate puzzle: for which sizes `n` do Hadamard matrices exist? A
short argument shows that beyond the tiny cases, `n` must be a multiple of 4. The
famous **Hadamard conjecture** says that's the *only* obstruction — that a
Hadamard matrix exists for *every* multiple of 4. Like Goldbach, it's still open.
But unlike Goldbach, we have powerful *recipes* that construct them for vast
families of sizes.

The most elementary recipe, due to Sylvester, doubles a matrix you already have:
from sizes 1, 2, 4, 8, 16, … it marches up the **powers of two**. Elegant — but
it can *never* produce a Hadamard matrix of size 12, or 20, or 24. Those orders
need a fundamentally different idea. That idea is the **Paley construction**, and
it is the mathematical centerpiece of this package.

### The hidden skeleton: skew conference matrices

Paley's insight is to build a Hadamard matrix from a slightly different object
called a **skew conference matrix**. Picture again a grid of ±1's, but this time
with **zeros down the diagonal**, and with a beautiful anti-symmetry: flipping the
matrix across its diagonal turns every entry into its negative (`Cᵀ = −C`). Plus
a balance condition called the *conference identity*:

> `C · Cᵀ = (n − 1) · I`.

Where do such matrices come from? From prime numbers, fittingly enough. Take a
prime `q` that leaves remainder 3 when divided by 4 — like 3, 7, 11, 19, 23 — and
use the **quadratic-residue character** of the field with `q` elements (the
function that records whether a number is a perfect square modulo `q`). Bordering
that pattern with a row and column produces a skew conference matrix of size
`q + 1`. So we get sizes 4, 8, 12, 20, 24, … — crucially including the
non-powers-of-two that Sylvester misses.

### The theorems that make the recipe rigorous

Here is the mathematical payload of the package, stated plainly. Each of these is
a fully verified theorem.

**The algebraic core.** If `C` is a skew conference matrix of order `n`, then

> `C · C = (1 − n) · I`.

This looks like a small computation, but it is the engine of everything. It comes
straight from the anti-symmetry: because `Cᵀ = −C`, the conference identity
`C · Cᵀ = (n − 1)·I` turns into `−(C · C) = (n − 1)·I`, and negating both sides
gives the result. One identity, and the rest is bookkeeping.

**The forward construction (Paley I).** If `C` is a skew conference matrix of
order `n`, then `I + C` — the same matrix with 1's placed on its diagonal — is a
genuine **skew-Hadamard matrix** of order `n`. ("Skew-Hadamard" means it is
Hadamard *and* satisfies `H + Hᵀ = 2·I`, the trace of its anti-symmetric
origins.) Why does it work? The off-diagonal entries are ±1 and the diagonal
entries become `1 + 0 = 1`, so all entries are ±1. And when you compute
`(I + C)(I + C)ᵀ`, the anti-symmetry makes the cross terms cancel, leaving exactly
`I − C·C = I + (n − 1)·I = n·I`. That's the Hadamard condition, on the nose.

**The existence corollary.** Consequently, *whenever a skew conference matrix of
order `n` exists, `n` is a Hadamard order.* This is the bridge that delivers
Hadamard matrices of orders like 12 and 20 — sizes forever out of Sylvester's
reach.

**The converse, and a perfect dictionary.** The correspondence runs both ways:
if `H` is any skew-Hadamard matrix of order `n`, then `H − I` is a skew conference
matrix. Forward and backward together establish a **bijection** — a flawless
two-way dictionary — between skew conference matrices and skew-Hadamard matrices
of each order. The two worlds are really the same world seen from two angles, and
the translation `C ↔ I + C` never loses a drop of information.

The companion demo builds these matrices explicitly for `q = 3, 7, 11, 19, 23`,
checks the core identity `C·C = (1−n)I`, verifies that `I + C` is Hadamard, and
confirms that subtracting the identity gets you right back to `C`. Orders 12 and
20 appear in the list — concrete proof that we have escaped the powers of two.

### The frontier left open

Skew conference matrices come from primes `q ≡ 3 (mod 4)`. Their mirror image,
**symmetric conference matrices**, come from primes `q ≡ 1 (mod 4)` — and there
the simple `I + C` trick *fails*. To turn a symmetric conference matrix into a
Hadamard matrix you must instead **double the size**, gluing four copies into a
2×2 block pattern to reach order `2n`. The framework records this as an explicit
open conjecture, a sharply stated frontier for the next round of work.

---

## The shared lesson

Put the two halves side by side and a single philosophy emerges. Goldbach is a
question we cannot yet answer in general, so we surround it with **certificates**
— decidable predicates and auditable search that make every finite instance
bulletproof. Hadamard via Paley is a question we *can* answer constructively, so
we capture the construction as **theorems with a built-in dictionary** between
two equivalent worlds.

Different fates, same instinct: never ask the reader to *trust* that an object
exists. Hand them the object, and hand them the means to check it. Whether the
witness is a pair of primes summing to 100 or a 12×12 grid of pluses and minuses
with perpendicular rows, the certificate is the thing. It is what turns a belief
into knowledge — and what lets a machine, with no intuition and infinite
patience, agree.
