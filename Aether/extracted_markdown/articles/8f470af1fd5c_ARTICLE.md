# The Numbers That Fool Fermat: Inside Korselt's Criterion

## A test that almost works

In 1640, Pierre de Fermat noticed something beautiful about prime numbers. Pick a prime `p`, pick any whole number `a` that is not a multiple of `p`, and raise `a` to the power `p − 1`. The remainder you get when you divide by `p` is always exactly `1`. In modern shorthand,

> if `p` is prime and `p` does not divide `a`, then `a^(p−1) ≡ 1 (mod p)`.

This is *Fermat's Little Theorem*, and it is one of the most useful facts in all of mathematics. It is the engine behind much of modern cryptography, and it suggests a tantalizingly simple way to test whether a number is prime: pick a base `a`, compute `a^(n−1) mod n`, and if the answer is not `1`, then `n` is definitely *not* prime.

This test is fast. It is easy to program. And it has one fatal flaw: there exist composite numbers that pass it anyway — for *every* base coprime to them. These impostors are called **Carmichael numbers**, and they are the secret villains of computational number theory. The smallest is `561 = 3 × 11 × 17`. It is not prime, yet it satisfies `a^560 ≡ 1 (mod 561)` for every `a` that shares no factor with it. To Fermat's test, `561` looks exactly like a prime. It is a perfect counterfeit.

So how do you catch a counterfeit? You need a *structural* description — a fingerprint that the impostors cannot fake. That fingerprint was discovered by the Belgian mathematician Alwin Korselt in 1899, and the heart of his argument is the subject of this article.

## Korselt's fingerprint

Korselt's criterion says, in full:

> A composite number `n` is a Carmichael number **if and only if** `n` is squarefree (no prime divides it twice) and, for every prime `p` dividing `n`, the number `p − 1` divides `n − 1`.

Look at `561 = 3 × 11 × 17` through this lens. It is squarefree. And the three primes give us `p − 1` values of `2`, `10`, and `16`. Does each divide `560`?

- `560 / 2 = 280` ✓
- `560 / 10 = 56` ✓
- `560 / 16 = 35` ✓

All three. So `561` is a Carmichael number, confirmed not by testing it against every possible base — an impossible task — but by a single, finite, mechanical check on its prime factors. Korselt turned an infinite verification into a finite one. That is the magic.

The deepest and most surprising part of Korselt's theorem is the **forward direction**: *if* a number fools Fermat's test on every base, *then* its prime factors must satisfy the divisibility condition `(p − 1) ∣ (n − 1)`. Why should fooling a test about powers force such a clean arithmetic relationship? This article is about that "why," and about a fully rigorous, machine-checked proof of exactly this implication.

## From "all bases" to "all units"

The first move is a change of language. Instead of speaking about every base `a` modulo `n`, we speak about the *units* of the ring `ℤ/nℤ` — the numbers from `0` to `n − 1` that have a multiplicative inverse, which are precisely the ones coprime to `n`. These units form a group under multiplication, written `(ℤ/nℤ)ˣ`. Fermat's test, applied to all coprime bases, becomes the single statement:

> **Universal Fermat condition:** every unit `u` of `ℤ/nℤ` satisfies `u^(n−1) = 1`.

This is exactly what it means for `n` to fool Fermat's test on every base it can. Our goal is to extract, from this one group-theoretic fact, the arithmetic consequence `(p − 1) ∣ (n − 1)` for each prime `p ∣ n`.

The result we prove is precise and unconditional in its arithmetic core:

> **Main theorem (the arithmetic heart of Korselt).** Let `n` be a positive integer and let `p` be a prime dividing `n`. If every unit `u` of `ℤ/nℤ` satisfies `u^(n−1) = 1`, then `(p − 1)` divides `(n − 1)`.

Interestingly, the squarefreeness hypothesis — usually quoted as part of Korselt's criterion — is *not needed* for this particular step. The divisibility `(p − 1) ∣ (n − 1)` follows from the unit condition alone. Squarefreeness enters elsewhere in the full criterion (it is what lets the local conditions glue back into a global one), but the local-divisibility extraction is cleaner than the textbook statement suggests. Discovering that a hypothesis is unnecessary is one of the quiet pleasures of building a proof carefully from the ground up.

## The proof in three movements

The argument has the elegance of a good chess combination: three moves, each natural, that together force the conclusion.

### Movement 1: Pushing the condition down to `p`

We know something about the big group `(ℤ/nℤ)ˣ`. We want to know something about the small group `(ℤ/pℤ)ˣ`. The bridge between them is **reduction modulo `p`**. Because `p` divides `n`, there is a natural ring map `ℤ/nℤ → ℤ/pℤ` (just reduce further), and it restricts to a group homomorphism on units,

> `reduce : (ℤ/nℤ)ˣ → (ℤ/pℤ)ˣ`.

The crucial fact is that this map is **surjective** — every unit modulo `p` is the image of some unit modulo `n`. This is not obvious: lifting a number coprime to `p` to a number coprime to *all* the prime factors of `n` requires a Chinese-Remainder-style argument. But it is true, and once we have it, the universal Fermat condition transports downward. Take any unit `v` of `ℤ/pℤ`. Pull it back to a unit `u` of `ℤ/nℤ` with `reduce(u) = v`. Then

> `v^(n−1) = reduce(u)^(n−1) = reduce(u^(n−1)) = reduce(1) = 1`.

So *every* unit `v` modulo `p` also satisfies `v^(n−1) = 1`. We have shifted the entire condition onto the small, well-understood group `(ℤ/pℤ)ˣ`.

### Movement 2: The order divides the exponent

Here we use a foundational principle of group theory, true in any monoid:

> **Lemma.** If every element `g` of a group satisfies `g^m = 1`, then the *order* of every element — the smallest positive power that returns it to the identity — divides `m`.

The order of `g` is the period of its cycle of powers; if `g^m = 1`, then `m` must be a whole number of full periods, so the order divides `m`. Applied with `m = n − 1`, this tells us that the order of every unit modulo `p` divides `n − 1`.

### Movement 3: Cyclicity delivers the punchline

The final ingredient is a jewel of classical number theory, going back to Gauss:

> **The group `(ℤ/pℤ)ˣ` is cyclic**, of order exactly `p − 1`.

"Cyclic" means there is a single generator `g` — a *primitive root* modulo `p` — whose powers run through every nonzero residue before repeating. Its order is therefore the full size of the group: `p − 1`.

Now combine the movements. By Movement 1, this generator `g` satisfies `g^(n−1) = 1`. By Movement 2, its order divides `n − 1`. But its order *is* `p − 1`. Therefore

> `(p − 1) ∣ (n − 1)`.

That is exactly Korselt's local condition. The three movements — *push down, extract the order, invoke the primitive root* — convert a statement about all powers into a statement about pure divisibility. The proof is complete.

## Why the primitive root is the hero

It is worth pausing on the role of cyclicity, because it is what makes the whole thing work. If `(ℤ/pℤ)ˣ` were some complicated group, knowing that every element's order divides `n − 1` would only tell us that the *exponent* of the group (the least common multiple of all orders) divides `n − 1`. That could be much smaller than `p − 1`. The conclusion `(p − 1) ∣ (n − 1)` would fail.

But because there is a single element whose order is the *entire* group size `p − 1`, the exponent and the group order coincide. The existence of a primitive root is precisely what upgrades "the exponent divides `n − 1`" to "`p − 1` divides `n − 1`." Gauss's theorem on primitive roots is doing the heavy lifting, even though it appears only in the final line.

## The bridge in context

This result is what we call an **arithmetic bridge**. It does not, by itself, classify Carmichael numbers — that requires gluing the local conditions back together and handling squarefreeness, the converse direction, and the composite-versus-prime distinction. What it does is forge one indispensable link in the chain, and forge it with complete rigor: every step, from the surjectivity of reduction to the cyclicity of `(ℤ/pℤ)ˣ`, is verified down to the foundations.

The payoff is conceptual clarity. Carmichael numbers are mysterious when you meet them as raw counterexamples — `561`, `1105`, `1729`, `2465`, a thinning sequence of impostors with no obvious pattern. Korselt's criterion reveals the pattern: they are exactly the squarefree composites whose prime factors `p` all satisfy `(p − 1) ∣ (n − 1)`. The arithmetic bridge proved here is the reason the "`(p − 1) ∣ (n − 1)`" clause has to be there. It is not a coincidence or an empirical observation; it is forced by the structure of finite multiplicative groups.

## A wider view

The pattern of this proof — *take a condition on a big object, transport it along a surjection to a small object, then use the small object's special structure to draw a sharp conclusion* — recurs throughout mathematics. It is the same reflex that lets topologists compute the homotopy groups of spheres from exact sequences, where the vanishing of the "ends" of a sequence forces a map in the middle to be an isomorphism. It is the same reflex that lets geometers read off curvature from how probability distributions deform. The local-to-global, big-to-small dance is one of the great unifying themes of modern mathematics, and Korselt's criterion is one of its most charming instances.

There is also a practical epilogue. Modern primality tests — the Miller–Rabin test, the Solovay–Strassen test, and the deterministic AKS algorithm — are all, in part, sophisticated responses to the existence of Carmichael numbers. Knowing exactly *why* the impostors exist, and exactly which structural condition they satisfy, is what allowed cryptographers and computer scientists to design tests the impostors cannot fool. The clean fingerprint `(p − 1) ∣ (n − 1)` is not just a theorem; it is a tool that shaped how we secure digital communication.

## The moral

Fermat gave us a test that almost works. The Carmichael numbers are the cracks in it. And Korselt, with an argument that fits in a paragraph once you see it, explained the cracks completely. The mathematics rewards us with something better than a faster test: it gives us *understanding*. We no longer fear the impostors, because we know precisely what they are made of — squarefree products of primes locked together by the single elegant relation `(p − 1) ∣ (n − 1)`.

That is the difference between detecting a counterfeit and understanding the mint. Korselt understood the mint. And now, line by verified line, so do we.
