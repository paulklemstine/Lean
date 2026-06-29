# Cryptography from the Collatz Conjecture: When a One-Way Street Has a Secret Shortcut

## A function that only runs forward

Take any whole number. If it is even, cut it in half. If it is odd, triple it and add one. Then do it again. And again.

This little rule is one of the most famous unsolved puzzles in mathematics. It is called the **Collatz map**, and we can write it compactly as

$$T(n) = \begin{cases} n/2 & \text{if } n \text{ is even},\\ 3n+1 & \text{if } n \text{ is odd}.\end{cases}$$

The *Collatz conjecture* says that no matter which number you start with, repeating this rule eventually drags you down to $1$. Start with $6$: you get $3, 10, 5, 16, 8, 4, 2, 1$. Start with $27$ and you wander for $111$ steps, soaring as high as $9232$, before crashing back to $1$. Despite eighty years of effort and computer checks past $2^{68}$, nobody has proved that *every* number behaves this way. The mathematician Paul Erdős famously said, "Mathematics is not yet ready for such problems."

This article is not about whether the conjecture is true. It is about a quieter, sneakier observation: the Collatz map *looks like* it should be hard to undo. And in cryptography, "hard to undo" is the most valuable property in the world.

## The dream: a lock with no key

Modern cryptography is built on **one-way functions**: recipes that are cheap to compute forward but ruinously expensive to reverse. Multiplying two large primes is easy; factoring the product back into those primes is, as far as we know, astronomically hard. That single asymmetry powers much of the security on the internet.

Now look again at the Collatz map. Going *forward* is trivial: halve or triple-and-add-one, a few arithmetic operations. But going *backward* is genuinely confusing. Suppose I tell you that after one step I landed on the number $4$. Where did I come from? Maybe I came from $8$, because $8/2 = 4$. Or maybe I came from $1$, because $3 \cdot 1 + 1 = 4$. Two completely different starting points, the same destination.

That tiny ambiguity is the seed of the whole story. Formally, we can record it as the equation

$$T(1) = T(8) = 4.$$

The forward map *forgets* where it came from. And in cryptography, a function that forgets its input is exactly the raw material from which you try to build locks. The tempting dream: chain many Collatz steps together, $f(a, n) = T^a(n)$ ("apply $T$ a total of $a$ times"), and use the number of steps $a$ as a security parameter. Forward computation costs $a$ cheap operations. Reversing it seems to require exploring a branching tree of preimages — an exponential search.

So far, so seductive. But seduction is not security. The central lesson of this work is a sharp, formally verified warning: **building a hash function naively out of the Collatz map fails, and it fails for a beautifully concrete reason.**

## Two kinds of hardness, and why they are not the same

Cryptographers care about several different flavors of "hard," and a primitive can have one without the others. Two of them matter here.

**One-wayness.** Given the *output*, you cannot recover *an* input. (Given $4$, find a number that maps to it.)

**Collision resistance.** You cannot find *two different inputs* that produce the *same* output. (Find $x \neq y$ with the same hash.)

These sound similar, but they are logically independent. A function can be hard to invert yet trivially easy to collide. The Collatz construction turns out to be a textbook example of exactly this gap, and that is what we make rigorous.

The very feature that makes the Collatz map *attractive* as a one-way function — that it forgets information, that $1$ and $8$ both flow to $4$ — is precisely the feature that *destroys* its collision resistance. The forgetting is not a bug you can patch around; it is the whole point of the dynamical system. You cannot have an information-destroying map that is also collision-free. The two desires are in direct conflict.

## How real hash functions are assembled

To make the failure precise, we need to know how serious hash functions are actually built. The dominant blueprint for decades was the **Merkle–Damgård construction**, the skeleton inside MD5, SHA-1, and SHA-2.

The idea is an assembly line. You start with a small, fixed gadget called a **compression function**,

$$f : \text{State} \times \text{Block} \to \text{State},$$

which eats a running "state" (a chaining value) together with one block of the message, and spits out a new state. To hash a long message, you chop it into blocks $b_1, b_2, \dots, b_k$, start from a fixed *initialization vector* $\mathrm{iv}$, and fold the blocks in one at a time:

$$\mathrm{state}_0 = \mathrm{iv}, \qquad \mathrm{state}_i = f(\mathrm{state}_{i-1}, b_i),$$

and the final $\mathrm{state}_k$ is the hash. In our formalization this fold is exactly

$$\mathrm{mdHash}(f, \mathrm{iv}, \text{msg}) = \text{msg.foldl } f\ \mathrm{iv}.$$

Here is the elegant theorem that makes this design worth using. It says collision resistance is *inherited*: if your tiny compression gadget has no collisions, the whole assembly line has no collisions either (on messages of equal length). Equivalently, in its constructive contrapositive form — the form we actually rely on — **any collision in the big hash can be mechanically dismantled into a collision of the small gadget.** We call this the *Merkle–Damgård collision-extraction theorem*:

> **Collision extraction.** Given a compression function $f$ and any two distinct messages $m_1 \neq m_2$ of the *same length* that hash to the same value, $\mathrm{mdHash}(f, \mathrm{iv}, m_1) = \mathrm{mdHash}(f, \mathrm{iv}, m_2)$, one can explicitly produce a collision of $f$ itself: states $s, s'$ and blocks $b, b'$ with $(s, b) \neq (s', b')$ but $f(s, b) = f(s', b')$.

The proof is a clean reverse induction: compare the *last* blocks of the two messages. Either they already disagree at the final fold (giving the collision immediately), or they agree, and the problem shrinks to two strictly shorter messages. Peel from the back until something gives. The equal-length requirement is not cosmetic decoration — it is genuinely necessary, because messages of different lengths can collide through a degenerate start rather than a real compression collision.

There is also a humbling companion fact, a pigeonhole argument: if there are more possible message blocks than possible states, then collisions in the compression function *must exist*. There are simply more inputs than outputs. This is why collision resistance can only ever be a *computational* notion — collisions are always lurking; the entire game is whether you can *find* one. With the Collatz hash, finding one takes no effort at all.

## The construction, and its instant downfall

Now we assemble the would-be Collatz hash and watch it collapse.

We build the compression function in the simplest way imaginable: mix the running state and the incoming block by adding them, then apply one Collatz step,

$$\mathrm{collatzCompress}(s, b) = T(s + b).$$

This is a faithful single-step Collatz primitive dropped into the Merkle–Damgård frame. To attack it we do not need clever cryptanalysis, supercomputers, or any unproven assumption about the Collatz conjecture. We just reuse the ambiguity we noticed at the very beginning.

Take the initialization vector $\mathrm{iv} = 0$ and the two one-block messages

$$m_1 = [1], \qquad m_2 = [8].$$

They are different, and they have the same length. Now hash them:

$$\mathrm{mdHash}(\mathrm{collatzCompress}, 0, [1]) = \mathrm{collatzCompress}(0, 1) = T(0+1) = T(1) = 4,$$
$$\mathrm{mdHash}(\mathrm{collatzCompress}, 0, [8]) = \mathrm{collatzCompress}(0, 8) = T(0+8) = T(8) = 4.$$

Both messages hash to $4$. That is a full-blown collision of the hash, found by hand. Feeding this collision into the extraction theorem instantly yields a collision of the compression function $\mathrm{collatzCompress}$ itself. The would-be cryptographic hash fails collision resistance — not asymptotically, not probabilistically, but with a single, explicit, two-element counterexample.

Every step of this argument has been verified by a proof checker, so there is no hidden gap, no "and one can show," no appeal to intuition. The collision $T(1) = T(8)$, the equality of the two hashes, and the final extraction of a compression collision are all machine-confirmed facts.

## Why this is good news, not bad news

It might sound like we built something only to demolish it. But a clean, decisive negative result is one of the most useful things in cryptography. The history of the field is littered with primitives that *seemed* secure until someone found the crack. Knowing *exactly why* a natural idea fails is how the field matures.

The lesson crystallizes a principle that every designer should internalize: **information-destroying dynamics and collision resistance are fundamentally at odds.** The Collatz map's charm as a one-way candidate — the way many numbers funnel into the same value — is the very thing a collision-resistant hash must never do. You cannot get collision resistance for free by bolting a hash wrapper onto a map whose job is to forget.

This does *not* kill the dream of dynamical-systems cryptography. It refocuses it. The forward-easy, backward-hard asymmetry of iterated maps is real and worth pursuing. But the right target is **one-wayness** (and its keyed cousins), not collision resistance from a single squashing step. In fact, the Collatz map points toward something subtler: the "hardness" of going backward is really the cost of recovering *one missing bit per step* — the parity of the unknown predecessor — rather than any deep arithmetic secret. Recover those bits (say, as a key stream) and the map becomes a perfectly invertible permutation; withhold them and you face the branching backward tree. That is a one-time-pad-like structure hiding inside a chaotic-looking dynamical system, and it is a far more promising place to look for genuine cryptography.

## Counting the backward tree

There is one more thread worth pulling, because it sharpens the picture of just how hard inversion really is.

When you try to run the Collatz map backward by $a$ steps, you face a branching tree: at each step you might have arrived by halving (always possible) or by the $3n+1$ rule (sometimes possible). A crude bound says the number of predecessors $a$ steps back is at most $2^a$ — two choices per step. That $2^a$ is the naive "security parameter" you would advertise.

But that bound is wildly pessimistic, and that turns out to matter. The odd, triple-and-add-one branch is not always available: a number $k$ can only have an odd predecessor when $k \equiv 4 \pmod 6$. So the genuine backward branchings are *gated* by a congruence condition. The realizable "parity transcripts" of true Collatz orbits are not free $a$-bit strings; they form a sparse, self-similar subset of all possible bit patterns. Counting them is a constrained-string problem whose true growth rate is governed by a number strictly smaller than $2$. The honest size of the backward tree grows like $c^a$ for some $c < 2$ — still exponential, but meaningfully thinner than the naive estimate. The asymmetry is real; it is just not as large as the back-of-the-envelope $2^a$ suggests.

## The takeaway

The Collatz map is a glorious mathematical mystery and a tempting cryptographic muse. Its forward-easy, backward-confusing personality really does look one-way. But the same forgetfulness that makes it attractive as a lock makes it useless as a fingerprint: $1$ and $8$ both stamp out $4$, and from that single observation the entire hash construction falls apart in one line.

The deeper moral outlives the specific failure. One-wayness and collision resistance are different demands, and a primitive can satisfy one while flagrantly violating the other. The Collatz hash is a perfectly clean, fully verified specimen of that separation — a cautionary tale told with mathematical certainty, and a signpost pointing toward the kinds of dynamical cryptography that might actually work.
