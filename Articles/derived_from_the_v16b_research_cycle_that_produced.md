# The Liars That Almost Fool Everyone: A Hidden Rule Inside Carmichael Numbers

## A test that should have worked

In the seventeenth century, Pierre de Fermat noticed something elegant about prime
numbers. Pick a prime `p`, then pick any number `a` that isn't a multiple of `p`.
Raise `a` to the power `p - 1` and divide by `p`. The remainder is always `1`. This
is *Fermat's Little Theorem*, and for three centuries it has been one of the most
useful facts in all of arithmetic.

It is useful because it suggests a way to *detect* primes without factoring them.
Suppose someone hands you a giant number `n` and claims it is prime. You don't have
time to search for divisors — `n` might have hundreds of digits. So instead you run
the cheap experiment: pick a random `a`, compute `a^(n-1)` modulo `n`, and check
whether you get `1`. If you don't, then `n` is *definitely* not prime, and you've
caught the lie with a single multiplication chain. This is the *Fermat primality
test*, and it is the conceptual ancestor of the algorithms that quietly protect every
credit-card transaction and encrypted message on Earth.

There is just one problem. A few composite numbers pass the test anyway. Not for one
unlucky choice of `a`, but for *every* `a` that shares no factor with `n`. These
numbers are perfect impostors: they are not prime, yet they satisfy the defining
congruence of primes for all admissible bases. They are called **Carmichael numbers**,
after Robert Carmichael, who in 1910 catalogued the first few. The smallest is `561`.
The next are `1105`, `1729`, `2465`. They are rare — but in 1994 it was proved that
there are infinitely many of them. The Fermat test, run naively, will be fooled by
all of them forever.

So a natural question becomes urgent: **what secret structure makes a number a
Carmichael number?** If we could describe these liars exactly, we could understand
precisely where the Fermat test breaks, and we could reason about the security of the
cryptography built on top of it.

## Korselt's rule

The answer was found astonishingly early — in 1899, more than a decade *before*
Carmichael's list and at a time when not a single Carmichael number had yet been
written down. A French mathematician named Alwin Korselt proved a clean criterion:

> A composite number `n` fools the Fermat test for every base coprime to it
> **exactly when** two conditions hold:
> 1. `n` is **squarefree** — no prime divides it twice; and
> 2. for every prime `p` dividing `n`, the number `p - 1` divides `n - 1`.

Look at `561 = 3 × 11 × 17`. It is squarefree. Now check the second condition:
`3 - 1 = 2` divides `560`, `11 - 1 = 10` divides `560`, and `17 - 1 = 16` divides
`560`. All three conditions hold, and indeed `561` is the smallest Carmichael number.
Korselt's criterion turns a question about *infinitely many bases `a`* into a finite
checklist about the *prime factors of `n`* — a spectacular compression.

This article is about one direction of that criterion, isolated, sharpened, and made
machine-checkable. We will explain *why* the divisibility condition `(p - 1) ∣ (n - 1)`
is forced on any number that fools the Fermat test — and we will tell the story
through the language that makes the proof inevitable: the language of *symmetry
groups*.

## The hidden group

Here is the central shift in perspective. Instead of thinking about individual numbers
`a` modulo `n`, think about all of them *at once* as a single algebraic object.

The numbers from `1` to `n - 1` that share no factor with `n` can be multiplied
together (modulo `n`) and every one of them has a multiplicative inverse. In modern
language they form a **group**, written `(ℤ/nℤ)ˣ` and called the *group of units
modulo `n`*. This is not an abstract indulgence; it is exactly the set of bases `a`
on which the Fermat test is allowed to run.

Now the Fermat-fooling property has a beautifully compact restatement. Saying that
`a^(n-1) ≡ 1` for *every* admissible base `a` is the same as saying:

> **Every element `u` of the group `(ℤ/nℤ)ˣ` satisfies `u^(n-1) = 1`.**

In group-theoretic terms, the exponent `n - 1` *annihilates the entire group*. Every
single symmetry, raised to the power `n - 1`, collapses to the identity.

This is where a single, powerful idea takes over: the **order** of an element. The
order of a group element `u` is the smallest positive number of times you must
multiply `u` by itself to get back to the identity `1`. It is a fundamental fact —
true in every group — that if `u^(n-1) = 1`, then the order of `u` *divides* `n - 1`.
You can never reach the identity "early" except at multiples of the true period.

So the Fermat-fooling hypothesis says something sharp: **the order of every unit
divides `n - 1`.**

## Zooming into a single prime

We now have a global fact about the big group `(ℤ/nℤ)ˣ`. We want a *local* fact: a
statement about a single prime factor `p` of `n`. How do we travel from the whole to
the part?

The bridge is a **reduction map**. If `p` divides `n`, there is a natural way to take
a unit modulo `n` and "read it" modulo `p`. This operation, written `ZMod.unitsMap`,
is a group homomorphism: it respects multiplication. Crucially — and this is the first
load-bearing theorem of our formalization — this reduction map is **surjective** when
`p ∣ n`. Every unit modulo `p` is the shadow of some unit modulo `n`:

> **Theorem (surjectivity of reduction).** *For `p ∣ n`, the reduction map
> `(ℤ/nℤ)ˣ → (ℤ/pℤ)ˣ` is surjective.*

Surjectivity is exactly what we need, because group homomorphisms transport the
annihilation property forward. If every `u` in the big group satisfies `u^(n-1) = 1`,
and every element `v` of the small group is the image `φ(u)` of some `u`, then
`v^(n-1) = φ(u)^(n-1) = φ(u^(n-1)) = φ(1) = 1`. The fooling property *descends* from
modulo `n` to modulo `p`:

> **Every element of `(ℤ/pℤ)ˣ` also satisfies `v^(n-1) = 1`.**

We have successfully zoomed in. Now we exploit a special feature of primes.

## Why primes have a perfect generator

The group of units modulo a *prime* `p` is not just any group — it is **cyclic**. This
is a classical and deep theorem (a primitive root always exists): there is a single
element `g`, a "generator," whose powers `g, g², g³, …` sweep out the *entire* group
before returning to the identity. Because the group has exactly `p - 1` elements, this
generator has order precisely `p - 1`. It is the element of maximal possible order —
the one that takes the longest to cycle back home.

Combine the two facts. The generator `g` satisfies `g^(n-1) = 1` (because *every*
element does), so its order divides `n - 1`. But its order *is* `p - 1`. Therefore:

> **`(p - 1) ∣ (n - 1)`.**

That is exactly the second half of Korselt's criterion, and it now stands as a
rigorously verified theorem:

> **Main Theorem (the Korselt divisibility, units form).** *Let `n` be a positive
> integer and `p` a prime dividing `n`. If every unit `u` of `ℤ/nℤ` satisfies
> `u^(n-1) = 1`, then `(p - 1) ∣ (n - 1)`.*

The entire argument is a chain of four ideas, each elementary on its own:

1. *Order divides any annihilating exponent.* If `u^(n-1) = 1`, then `ord(u) ∣ n - 1`.
2. *Homomorphisms shrink orders.* The order of an image divides the order of the
   element — so annihilation passes through maps.
3. *Reduction modulo a prime factor is onto.* The map `(ℤ/nℤ)ˣ → (ℤ/pℤ)ˣ` is
   surjective when `p ∣ n`, so the fooling property descends.
4. *Primes have a maximal generator.* `(ℤ/pℤ)ˣ` is cyclic with a generator of order
   exactly `p - 1`.

Stack them and the divisibility `(p - 1) ∣ (n - 1)` falls out with no room for error.

## A small surprise about squarefreeness

Korselt's full criterion has two clauses: squarefree *and* the divisibility. You might
expect that proving the divisibility would lean on squarefreeness. It is a pleasant
twist that **it does not**. The argument above never uses the assumption that `n` is
squarefree. The reduction map to `(ℤ/pℤ)ˣ` is surjective for *any* prime divisor `p`,
squarefree or not, and the cyclic-generator argument needs nothing more.

In the formalization, the squarefreeness hypothesis is deliberately kept in the
statement — because it is part of the classical "interface" of Korselt's theorem that
a reader expects to see — but it is flagged honestly as unused for this particular
arithmetic step. Squarefreeness is what the *other* direction of the criterion and the
*other* clause require; it is not what forces `(p - 1) ∣ (n - 1)`. Separating the two
roles is one of the clarifying benefits of writing the proof out with full precision.

## Why the exponent `n - 1` is a historical accident

There is a second, deeper liberation hidden in the proof. Trace through the four steps
and ask: where did the specific value `n - 1` actually get *used*? The answer is:
nowhere essential. Every step works verbatim if we replace `n - 1` by *any* exponent
`e`. The argument really proves the following more general statement:

> If every unit of `(ℤ/nℤ)ˣ` satisfies `u^e = 1`, then `(p - 1) ∣ e` for every prime
> `p ∣ n`.

The number `n - 1` is special only because it is the exponent the *Fermat test*
happens to use. Mathematically, the true object of interest is the smallest exponent
that annihilates the entire group — a quantity known as the **Carmichael function**
`λ(n)`. For squarefree `n`, it is the least common multiple of all the `p - 1`. A
number fools the Fermat test precisely when `λ(n)` divides `n - 1`. Our theorem is the
local atom from which this whole picture is assembled, one prime at a time.

## Why this matters beyond curiosity

The story is not merely a charming episode in number theory. The group `(ℤ/nℤ)ˣ` and
its order structure sit at the foundation of public-key cryptography. The RSA
cryptosystem, the Diffie–Hellman key exchange, and a host of modern "group-action"
schemes all stake their security on the *size and structure* of such groups — on the
idea that certain exponentiation problems are computationally hard because the
underlying group is large and its element orders are spread out.

Carmichael numbers are a cautionary tale about exactly this assumption. When `n` is a
Carmichael number, the universal relation `u^(n-1) = 1` secretly *shrinks* the
effective complexity of the group: every element's order is forced to divide `n - 1`,
collapsing the spectrum of possible orders. A modulus chosen carelessly — one that
turns out to be Carmichael — can quietly hand an attacker a smaller search space than
intended. The same divisibility `(p - 1) ∣ (n - 1)` that defines a mathematical
impostor can translate into a concrete cryptographic weakness. Number-theoretic
defects become security defects.

This is why pinning the criterion down with total rigor is worth the trouble. The
theorem we have described is the precise, verified hinge connecting "this number fools
a classical primality test" to "the orders inside this group are constrained." It is a
bridge, in the literal sense: a single arithmetic fact that carries weight from pure
number theory across into algebra and onward into cryptography.

## The shape of the idea

Strip away the machinery and the heart of the matter is one sentence: **a number fools
the Fermat test exactly when an exponent is forced to kill every symmetry of its unit
group, and that can only happen when each prime's natural period `p - 1` already
divides `n - 1`.** Fermat gave us a test. Korselt told us when it fails. And the
language of groups tells us *why* the failure is inevitable — not as a coincidence, but
as a theorem, now checked down to the last symbol.

The liars, it turns out, cannot help but leave a fingerprint. Every one of them
carries the equation `(p - 1) ∣ (n - 1)` stamped on each of its prime factors. Read
that fingerprint, and the impostor is unmasked.
