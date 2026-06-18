# The Numbers That Fool Fermat: A Group-Theoretic Window into Korselt's Criterion

## A test that almost never lies

In 1640, Pierre de Fermat noticed something elegant about prime numbers. Pick a
prime `p`, then pick any number `a` that is not a multiple of `p`. Raise `a` to
the power `p - 1` and divide by `p`. The remainder is always `1`. Always. This is
*Fermat's Little Theorem*, and it is one of the load-bearing walls of number
theory.

It also looks, at first glance, like a free lunch for anyone who wants to test
whether a number is prime. Suppose someone hands you a large number `n` and asks
whether it is prime. You could try to factor it — but factoring is famously hard.
Instead, you could just *check Fermat's signature*: pick a base `a`, compute the
remainder of `a^(n-1)` when divided by `n`, and see whether it equals `1`. If it
doesn't, then `n` cannot be prime, and you've discovered this without factoring
anything. This is the **Fermat primality test**, and it is blisteringly fast.

There is only one problem, and it is a beautiful one. Some composite numbers are
impostors. They pass Fermat's test for *every* base coprime to them, perfectly
mimicking a prime. These are the **Carmichael numbers** (also called *absolute
Fermat pseudoprimes*), and the smallest is `561 = 3 × 11 × 17`. To Fermat's test,
`561` is indistinguishable from a prime. It is a number wearing a very convincing
disguise.

How does a composite number pull off such a perfect forgery? The answer was given
in 1899 by Alwin Korselt, and it is a small miracle of structure. This article is
about one crisp, fully verified piece of that miracle — a single arithmetic step
that turns out to be, underneath, a clean statement about the *orders* of elements
in a group.

## Korselt's criterion

Korselt found exactly the fingerprint that every Carmichael number carries.

> **Korselt's Criterion.** A composite number `n > 1` fools Fermat's test for
> every coprime base if and only if two conditions hold:
> 1. `n` is **squarefree** — no prime divides it twice; and
> 2. for **every** prime `p` dividing `n`, the number `p - 1` divides `n - 1`.

Look at `561 = 3 × 11 × 17`. It is squarefree. And `n - 1 = 560`. The primes are
`3, 11, 17`, so the relevant numbers are `p - 1 = 2, 10, 16`. Indeed `2 | 560`,
`10 | 560`, and `16 | 560`. Every condition checks out — and that is *exactly* why
`561` is a Carmichael number. The next ones, `1105 = 5 × 13 × 17` and
`1729 = 7 × 13 × 19` (yes, the famous taxicab number), pass the same test.

Korselt's criterion is a biconditional — an "if and only if." It has two
directions, and they have very different personalities. One direction is
constructive: *given* the divisibility conditions, build the pseudoprimality. The
other direction is the converse: *from* pseudoprimality, extract the divisibility
conditions. The piece we focus on here lives at the heart of the converse, and it
is where the group theory shines through.

## The bridge: from "everything dies" to "the right things divide"

Here is the exact statement that has been proved and machine-verified, expressed
in plain mathematics.

> **The Arithmetic Bridge.** Let `n` be squarefree, let `p` be a prime dividing
> `n`, and suppose that **every** unit `u` modulo `n` satisfies `u^(n-1) ≡ 1`.
> Then `(p - 1)` divides `(n - 1)`.

A "unit modulo `n`" is simply a residue class that has a multiplicative inverse —
equivalently, a number coprime to `n`. The hypothesis "every unit `u` satisfies
`u^(n-1) ≡ 1`" is precisely the algebraic essence of being a Fermat pseudoprime:
every coprime base, raised to the `n - 1`, collapses to `1`. The conclusion
`(p - 1) | (n - 1)` is exactly one of Korselt's two conditions.

So this bridge says: *if the whole multiplicative world modulo `n` is annihilated
by the exponent `n - 1`, then each local prime factor's "size minus one" must
divide `n - 1`.* This is the converse direction's beating heart, isolated and made
rigorous.

## Why it's really a statement about orders

The proof is short, but it is short the way a good magic trick is short — all the
work is in the setup. The key idea is the notion of the **order** of a group
element. If `g` is an element of a group and `g^m = 1`, we say `m` is an exponent
that "kills" `g`. The smallest positive such `m` is the *order* of `g`, written
`ord(g)`. A foundational fact — true with no finiteness assumptions whatsoever —
is:

> **Order divides every killing exponent.** If `g^m = 1`, then `ord(g)` divides
> `m`.

This is the first ingredient. The hypothesis of the bridge says the exponent
`n - 1` kills *every* unit modulo `n`. So `ord(u)` divides `n - 1` for every such
`u`. Fine — but how does that tell us anything about `p`?

This is where the second ingredient enters: a *reduction map*. Because `p` divides
`n`, there is a natural way to "project" arithmetic modulo `n` down to arithmetic
modulo `p`. Crucially, this projection sends units to units, defining a group
homomorphism

> `f : (ℤ/nℤ)ˣ → (ℤ/pℤ)ˣ`,

and — this is the non-obvious part — it is **surjective**: every unit modulo `p`
is the image of some unit modulo `n`. (Squarefreeness guarantees `n` is nonzero,
which is all that is needed to make this machinery turn.)

Surjectivity lets us *transport* the killing hypothesis downstairs. Take any unit
`v` modulo `p`. Lift it to a unit `u` modulo `n` with `f(u) = v`. Then

> `v^(n-1) = f(u)^(n-1) = f(u^(n-1)) = f(1) = 1`,

using only that `f` is a homomorphism. So the exponent `n - 1` kills *every* unit
modulo `p` as well. The forgery propagates downward.

Now we deploy the deepest classical fact in play: the group of units modulo a
prime, `(ℤ/pℤ)ˣ`, is **cyclic**. It has a single generator — a *primitive root* —
and that generator has order exactly `p - 1`, the full size of the group.
Concretely, there exists an element `g` with `ord(g) = p - 1`.

Put the pieces together. The element `g` has order `p - 1`. The exponent `n - 1`
kills `g` (because it kills everything modulo `p`). By "order divides every
killing exponent," `ord(g) = p - 1` divides `n - 1`. That is the conclusion. ∎

There is a small, satisfying bonus hiding in the proof. A general lemma states
that **a group homomorphism never increases orders**: `ord(f(g))` always divides
`ord(g)`. Reduction maps cannot manufacture new periodicity; they can only inherit
or shrink it. This monotonicity of order under homomorphisms is the abstract
reason the forgery can flow from modulo `n` down to modulo `p` but never the other
way around.

## The shape of the whole argument

It helps to see the four moves in one frame:

1. **Uniform annihilation bounds every order.** `g^m = 1` for all `g` implies
   `ord(g) | m` for all `g`. (No finiteness needed.)
2. **Homomorphisms shrink orders.** For a group hom `f`, `ord(f(g)) | ord(g)`.
3. **The reduction map is surjective.** `(ℤ/nℤ)ˣ ↠ (ℤ/pℤ)ˣ` whenever `p | n`.
4. **Local units are cyclic.** `(ℤ/pℤ)ˣ` has an element of order exactly `p - 1`.

Combine (3) to push the hypothesis down to `(ℤ/pℤ)ˣ`, then (4) to find a maximal-
order element, then (1) to conclude `p - 1` divides `n - 1`. The surjectivity in
(3) is what lets the hypothesis travel; the cyclicity in (4) is what makes the
travel *worthwhile*, because it guarantees an element large enough to feel the
full constraint.

## Why anyone should care

This is not just a curiosity about a 19th-century criterion. It sits at a busy
intersection of pure mathematics and modern cryptography.

**Primality testing in the real world.** The Fermat test's blind spot — Carmichael
numbers — is the reason practitioners use the stronger **Miller–Rabin test**
instead. Miller–Rabin refines the Fermat check by inspecting *square roots of 1*
along the way, and it provably catches Carmichael numbers that Fermat misses.
Understanding *why* Carmichael numbers fool Fermat — which is exactly what the
order-divisibility conditions explain — is what motivates and justifies the
refinement. Every time a web browser generates an RSA key or a Diffie–Hellman
parameter, a primality test like Miller–Rabin runs underneath, and its design is a
direct response to the structure laid bare by Korselt's criterion.

**A clean separation of "global" and "local."** The bridge is a small parable
about a recurring theme in number theory: a *global* condition modulo `n`
(everything is killed by `n - 1`) is shown to imply a *local* condition at each
prime `p` (the order `p - 1` divides `n - 1`). The translation device is a
surjective reduction homomorphism, exactly the kind of "glue" that the Chinese
Remainder Theorem provides when you reassemble the local facts into a global one.
This local-to-global dialogue is one of the oldest and most productive ideas in
mathematics, and here it appears in miniature, fully transparent.

**The exponent `n - 1` is a red herring.** A striking lesson from this analysis is
that the number `n - 1` plays *no special role* in the forward reasoning. The proof
only ever uses that some fixed exponent `e` annihilates the units. Replace `n - 1`
by any exponent `e`, and the same argument shows: if `a^e ≡ 1` for all coprime
`a`, then `(p - 1) | e` for every prime `p | n`. The value `n - 1` is a historical
artifact of Fermat's test, not a mathematical necessity. The true invariant
lurking underneath is the **Carmichael function** `λ(n)`, the least universal
exponent — the least common multiple of the `p - 1` over all prime factors. The
bridge, generalized, says exactly that the universal exponents of `(ℤ/nℤ)ˣ` are
precisely the common multiples of the local `p - 1`.

## The disguise, explained

Return one last time to `561 = 3 × 11 × 17`. We can now narrate its forgery
exactly. Modulo each prime factor, the units form a cyclic group: of orders `2`,
`10`, and `16`. Raising to the `560`-th power kills each of these groups, because
`560` is a common multiple of `2`, `10`, and `16`. The Chinese Remainder Theorem
stitches these three local annihilations into a single global one modulo `561`:
*every* coprime base, raised to the `560`, returns `1`. Fermat's test, peering only
at this global behavior, sees a perfect prime. It cannot see that `561` is secretly
three primes in a trench coat, each contributing a cyclic group whose order
happens to divide `560`.

The arithmetic bridge proved and verified here is the lens that reveals the trench
coat. It shows that any number capable of this disguise must, at each of its prime
factors, satisfy `(p - 1) | (n - 1)` — and it shows it not by clever computation
but by recognizing that the whole phenomenon is, at bottom, a statement about how
orders of group elements behave under reduction. The impostor's secret was group
theory all along.
