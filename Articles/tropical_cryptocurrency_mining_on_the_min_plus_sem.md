# Mining on the Min-Plus World: A Cryptocurrency Where the Hash Is a Shortest Path

## A puzzle at the heart of every coin

Every cryptocurrency you have ever heard of is, underneath the branding, a
gigantic guessing game. To add a block to the ledger, a miner must find a
special number — a *nonce* — so that when the block and the nonce are fed through
a cryptographic hash function, the output lands below a target threshold. The
hash function is deliberately chaotic: change one bit of the input and the output
scrambles completely. There is no shortcut, no cleverness, no insight that helps.
You just try nonces, billions upon billions of them, until one works. That brute
search is what consumes small nations' worth of electricity.

It is hard not to ask: what if the puzzle were *mathematics* instead of noise?
What if, to mine a coin, you had to solve a genuine optimization problem — the
kind that engineers actually care about — so that the energy poured into mining
produced something more than a lottery ticket?

This article explores exactly that fantasy through a strange and beautiful
arithmetic called the **min-plus semiring**, better known as *tropical*
mathematics. We will build a hash function out of it, prove two clean theorems
about how it behaves, and discover both why the idea is seductive and why the
naive version is spectacularly insecure — a failure that is itself a theorem.

## Arithmetic from another planet

In ordinary arithmetic, you add and multiply. Tropical arithmetic keeps two
operations too, but redefines them:

$$a \oplus b = \min(a, b), \qquad a \otimes b = a + b.$$

"Addition" becomes *taking the smaller of two numbers*, and "multiplication"
becomes *ordinary addition*. It sounds like a typo, but this system obeys almost
all the familiar laws — it is associative, commutative, and distributive — which
is why mathematicians call it a *semiring*. The one thing it lacks is
subtraction: you cannot un-take a minimum.

Why would anyone care? Because tropical arithmetic is the native language of
optimization. The shortest path through a network, the cheapest schedule for a
factory, the critical delay in a computer chip — all of these are computed by
chains of "add the costs, then keep the minimum," which is precisely tropical
multiplication followed by tropical addition. In the tropical world, a shortest
path *is* a product, and finding the best route *is* evaluating a polynomial.

## Building a tropical hash

Let a message be a list of $k$ numbers, $m = (m_1, \dots, m_k)$. Fix a secret
*key*, another list $h = (h_1, \dots, h_k)$. Define the **tropical hash** of the
message to be the tropical dot product of the two:

$$\mathrm{TSHA}(h, m) = \min_{1 \le i \le k} \left( m_i + h_i \right).$$

In plain words: add the key to the message coordinate by coordinate, then report
the smallest sum. That is the whole function.

The forward direction is trivially fast. Computing $\mathrm{TSHA}$ requires $k$
additions and $k-1$ comparisons — it is linear in the length of the message, the
cheapest thing imaginable. The dream is that the *reverse* direction is hard:
given only the output value $y$ and the key $h$, reconstruct a message $m$ whose
minimum sum equals $y$. This inversion is a constrained shortest-path selection
problem, exactly the sort of thing that is easy to check but conjectured to be
hard to solve at scale. If that asymmetry held, then mining a "tropical coin"
would amount to solving optimization problems, and the ledger's security would
rest on the difficulty of tropical inversion rather than on brute force.

That is the vision. Now for the mathematics that tells us how much of it survives
contact with reality.

## First theorem: the hash is gentle, not chaotic

A cryptographic hash function is supposed to be an avalanche: nudge the input and
the output explodes. Our tropical hash is the opposite. It is *stable*, and we
can say exactly how stable.

Measure the distance between two messages by their largest coordinate-wise gap,
the *supremum norm* $\lVert m - m' \rVert_\infty = \max_i |m_i - m'_i|$. Then:

> **Stability Theorem (1-Lipschitz property).** For any key $h$ and any two
> messages $m, m'$,
> $$\bigl|\,\mathrm{TSHA}(h, m) - \mathrm{TSHA}(h, m')\,\bigr| \;\le\; \max_{1 \le i \le k} |m_i - m'_i|.$$

In words: the hash value can never move further than the largest change you made
to the message. If you tweak every coordinate by at most $\varepsilon$, the
digest moves by at most $\varepsilon$. There is no avalanche at all.

The proof is a short, satisfying argument about minima. If you shift every term
$m_i + h_i$ by an amount no larger than $\varepsilon$, then the smallest term
also cannot move by more than $\varepsilon$ — the minimum of a family of numbers
is a $1$-Lipschitz function of that family. Applying this to the two shifted
families $m_i + h_i$ and $m'_i + h_i$, whose gaps are exactly $|m_i - m'_i|$,
gives the bound immediately.

This is lovely mathematics and terrible cryptography. A stable hash leaks
information: outputs that are close correspond to inputs that are close, so an
attacker can hill-climb toward a preimage instead of searching blindly. The
avalanche that protects real hash functions is exactly what this theorem
forbids.

## Second theorem: collisions are guaranteed, not rare

A good hash should make *collisions* — two different inputs with the same output
— astronomically unlikely to find. The tropical hash hands them to you for free.

> **Generic Collision Theorem (preimages are never unique).** Suppose the message
> has at least two coordinates. Then for *every* key $h$ and *every* message $m$,
> there exists a different message $m' \ne m$ with the identical digest,
> $$\mathrm{TSHA}(h, m') = \mathrm{TSHA}(h, m).$$

The reason cuts to the essence of the min operation. The digest of $m$ is
determined by a single *winning* coordinate — the index $i$ where $m_i + h_i$ is
smallest. Every other coordinate is a bystander; it does not touch the answer as
long as it stays above the winner. So take any losing coordinate and *increase*
it. The winner is unchanged, the minimum is unchanged, and yet the message is
genuinely different. You have manufactured a collision by hand, with no search at
all.

The construction in the proof is exactly this: locate a minimizing coordinate,
pick any other coordinate (which exists precisely because there are at least two),
and add $1$ to it. The new message differs from the old one, but every sum that
mattered is untouched, so the digest is identical. Collisions are not a
probabilistic hazard here — they are a structural certainty.

## The twist, and why it is only half a rescue

The concept behind a tropical coin anticipated this weakness and proposed a fix:
use *two* independent keys instead of one. Define

$$\mathrm{TSHA2}(m) = \Bigl( \min_i (m_i + h_i),\ \min_i (m_i + h'_i) \Bigr).$$

Now a collision must fool both keys at once. The single-key trick — inflating a
loser of the first key — will generally disturb the second key's minimum, because
a coordinate that loses under $h$ may be the winner under $h'$. Two independent
keys therefore *separate* many pairs that one key confuses, which is the germ of a
real security improvement.

But "many" is not "all," and honesty compels the caveat: adding a second key
raises the bar without slamming the door. The single-key collision changes just one
losing coordinate, and a fresh independent second key notices that change only when
that very coordinate happens to be *its* winner — an event of probability about
$1/k$. So a random second key *breaks* a given collision only about one time in
$k$; the improvement is inverse-linear, not the exponential cliff that industrial
hash functions enjoy. The stability theorem still applies coordinate by
coordinate, so approximate inversion remains easy. The tropical hash, even
doubled, is a fascinating object but not a drop-in replacement for the
cryptographic workhorses.

## So is "mining as mathematics" dead?

Not at all — it is *redirected*. The two theorems together deliver a precise
verdict on the naive dream and a precise map of where the real difficulty lives.

Stability and guaranteed collisions kill the single-key hash as a *pre*-image
puzzle: it is too smooth and too leaky. But the same structure points to where
genuine hardness hides. Inverting the *two-key* digest under natural range
constraints on the message is no longer a smooth hill to climb; it becomes a
simultaneous shortest-path selection on a layered min-plus network, where the two
minima must be witnessed jointly. That is the flavor of problem that is easy to
verify and believed to be hard to solve — the correct home for any "proof of
optimization" scheme.

The moral is a familiar one in mathematics, delivered here with unusual clarity.
The features that make an object *analytically beautiful* — smoothness,
predictability, a minimum that depends on a single clean coordinate — are exactly
the features that make it *cryptographically useless*. Security lives in
roughness, in avalanche, in the refusal of an answer to reveal anything about its
question. Tropical arithmetic is almost the platonic ideal of a smooth,
well-behaved world. And that is precisely why, if you want to hide a secret in
it, you must build the hiding place out of the one hard problem it does
contain: the shortest path.

## The bigger picture

There is something poetic in watching a would-be cryptocurrency dissolve into two
short theorems. The min-plus semiring was invented to *solve* optimization
problems efficiently; asking it to *hide* the solution runs against its entire
grain. The stability theorem says the digest is a faithful shadow of the message;
the collision theorem says the shadow can always be cast by more than one object.
Neither is a bug in our construction — both are unavoidable consequences of what
"minimum" means.

And yet the failed dream is more instructive than a bland success would have
been. It sharpens the real question for anyone who still wants mining to be
mathematics: not "can we hash tropically?" but "can we make tropical *inversion*
— a real, honest shortest-path problem — the thing miners must solve?" That is a
harder and far more interesting road, and the two theorems here are the signposts
that tell you where it begins.
