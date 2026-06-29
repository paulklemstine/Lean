# The Trap with Two Doors: How Hard Math Becomes an Unbreakable Hash

Every time you log into a website, install a software update, or send money
through a banking app, you are trusting a tiny, invisible piece of mathematics
called a *hash function*. A hash takes a message of any length — a password, a
multi-gigabyte file, an entire database — and crushes it down into a short,
fixed-size fingerprint. Change a single comma in the original, and the
fingerprint changes completely. Two different messages should *never* produce
the same fingerprint. When they do, it is called a **collision**, and a single
collision can forge a signature, swap a legitimate download for malware, or
break a blockchain.

So here is the trillion-dollar question: *why should we believe collisions are
hard to find?* A fingerprint has only finitely many possible values, but there
are infinitely many possible messages. By sheer counting, collisions must exist.
The whole edifice of digital security rests on the bet that, even though
collisions exist, nobody can actually *find* one. This article tells the story
of how mathematicians turn that bet into a theorem — how they connect "finding a
collision" to "solving a famously hard problem," so that breaking the hash would
mean breaking something we already believe is unbreakable.

## Collisions must exist — that's the catch

Let's make the counting argument precise, because it is the source of all the
trouble. A *compression function* is the workhorse inside a hash: it takes a
current internal state plus one chunk of message, and produces a new state.
Think of it as a function $f(s, b)$ that eats a state $s$ and a block $b$ and
spits out a new state.

If there are more possible inputs $(s, b)$ than possible outputs, then by the
*pigeonhole principle* two different inputs must land on the same output. That
is a collision, guaranteed. In the formalization behind this article, this
inevitability is a theorem: for finite state and block types with more than one
possible block,

$$\text{every compression function } f \text{ has a collision.}$$

Stated carefully: if the state space is nonempty and there are at least two
distinct blocks, then there exist $(s, b) \neq (s', b')$ with $f(s,b) = f(s',b')$.
There is no escape. Collisions are not a flaw to be engineered away; they are a
mathematical certainty. The art of cryptography is not to *eliminate* collisions
but to *hide* them so well that no computer can dig one up before the sun burns
out.

## From one block to a whole message: Merkle–Damgård

Real messages are long, but a compression function only eats one block at a
time. The standard way to bridge that gap — used inside MD5, SHA-1, SHA-256, and
many others — is the **Merkle–Damgård construction**. The idea is beautifully
simple: chain the compression function down the message like links in a chain.

Start with a fixed *initialization vector* $iv$. Feed in the first block to get a
new state; feed that state and the second block back in; and so on until the
message runs out. The final state is the hash. In one line, if $msg$ is the list
of blocks,

$$\text{mdHash}(f, iv, msg) = \text{foldl}(f, iv, msg),$$

the left fold of $f$ over the blocks. Two facts make this construction tick.
First, hashing the empty message just returns the $iv$. Second, hashing a
message that ends in a block $b$ is the same as hashing everything before $b$ and
then applying $f$ one last time:

$$\text{mdHash}(f, iv,\ \ell \,{+}{+}\, [b]) = f\big(\text{mdHash}(f, iv, \ell),\ b\big).$$

This "last block" decomposition is the lever for the central theorem.

## The reduction: a chain is only as collision-free as its links

Here is the first jewel. Suppose someone hands you a collision in the *full*
Merkle–Damgård hash: two **different messages of the same length** that produce
the same final fingerprint. The **collision-extraction theorem** says you can
always, mechanically, dig out of that a collision in the underlying compression
function $f$ — a single pair of distinct inputs that $f$ maps to the same place.

Why same length? Because length matters. If you allow messages of different
lengths, you can sometimes cheat using a so-called free-start collision, where
the chaining values line up without $f$ ever truly colliding. Restricting to
equal-length messages closes that loophole, and the theorem holds at exactly
this tight boundary.

The proof works backward from the last block. Compare the final blocks of the
two messages. Either they differ, and you have your compression collision on the
spot; or they agree, in which case the states feeding that last block must have
already collided — so you shorten both messages by one block and repeat. Peel
the chain link by link and a genuine collision in $f$ falls out.

Flip this around and you get the headline corollary, the reason the construction
is trusted: **if the compression function has no collision, then the
Merkle–Damgård hash is injective on each fixed message length.** Distinct
equal-length messages can never collide. Collision resistance of one small,
fixed-size gadget is automatically inherited by the unbounded-length hash. Build
the link well, and the whole chain is strong.

## But where does the hard part come from?

We have reduced the security of a long hash to the security of a single
compression function. That is real progress — but it just relocates the
question. *Why* should the compression function be collision-resistant?

A natural hope is to build it from a **one-way function** — a function easy to
compute but hard to invert, the most basic object in all of cryptography. Surely
"hard to invert" should give us "hard to collide"? Astonishingly, the answer is
*no*, at least not by any general-purpose ("black-box") argument. A celebrated
1998 result of Daniel Simon shows there is a fundamental barrier: you cannot, in
a black-box way, turn an arbitrary one-way function into a collision-resistant
hash. Plain one-wayness is simply too weak.

The fix, due to Ivan Damgård in 1987, is to demand a little more structure. That
structure is the **claw-free pair**, and it is the mathematical heart of this
article.

## Two doors, one room: the claw-free pair

Picture two functions, $g_0$ and $g_1$, each a *permutation* — a perfect
shuffle, scrambling a set onto itself with no information lost. Think of them as
two different doors leading into the same room of states.

A **claw** is a pair of keys, one for each door, that lands you in the *exact
same spot*: inputs $x$ and $y$ with

$$g_0(x) = g_1(y).$$

The two doors, used on different keys, meet. A pair of permutations is
**claw-free** when no such coincidence can be *found* — when, as far as any
feasible computation is concerned, the two doors never overlap. Claw-freeness is
the precise "hard problem" assumption, and it is exactly what concrete number
theory provides: from the difficulty of *factoring* large integers, or computing
*discrete logarithms*, one can build pairs of permutations for which finding a
claw is as hard as the underlying number-theoretic problem.

Now comes the construction. Use the two doors as your compression function. The
state is a point in the room; the message block is a single bit deciding which
door to use:

$$\text{clawCompress}(g_0, g_1)(s, b) = \begin{cases} g_1(s) & \text{if } b = \text{true} \\ g_0(s) & \text{if } b = \text{false.}\end{cases}$$

One bit of message per step, processed by walking through door $0$ or door $1$.

## The punchline: a collision *is* a claw

Here is the structural identity that makes everything click — the main theorem.
**When $g_0$ and $g_1$ are injective permutations, a collision of this
compression function is exactly a claw of the pair, and vice versa.**

$$\text{HasClaw}(g_0, g_1) \iff \text{HasCompressionCollision}\big(\text{clawCompress}(g_0, g_1)\big).$$

Let's see why, because the argument is short and gorgeous. Suppose two distinct
inputs $(s, b)$ and $(s', b')$ collide. Look at the bits:

- If both bits are $0$, the collision says $g_0(s) = g_0(s')$. But $g_0$ is
  injective, so $s = s'$ — making the inputs identical, contradicting that they
  were distinct. Impossible.
- Same-bit collisions with both bits $1$ are ruled out identically by
  injectivity of $g_1$.
- So the bits must differ. Say one input went through door $0$ and the other
  through door $1$. Then $g_0(s) = g_1(s')$ — and that is precisely a claw!

The converse is even easier: a claw $g_0(x) = g_1(y)$ is, by definition, two
inputs $(x, \text{false})$ and $(y, \text{true})$ — distinct because their bits
differ — that the compression function sends to the same place. A claw *is* a
collision.

The injectivity hypothesis is not decoration; it is at the tight boundary of the
theorem. Drop it, and a same-door collision $g_0(s) = g_0(s')$ with $s \neq s'$
would be a compression collision that is *not* a claw, and the clean equivalence
breaks.

## Hard problem in, unbreakable hash out

Chain the two jewels together and you get the constructive reduction that this
whole story was building toward. If the claw-free pair is genuinely hard — if no
claw can be found — then:

1. The compression function has no findable collision (a collision *would be* a
   claw, and there are none to find).
2. By the Merkle–Damgård extraction theorem, the iterated hash inherits this:
   **distinct equal-length messages never collide.**

In the language of the formalization, claw-freeness lifts through the chain to
give an injective hash on each message length. Spelled out: if the pair is
claw-free, and two equal-length bit-strings hash to the same value, then the two
strings must have been equal all along. A collision in the full hash would
unwind — block by block through Merkle–Damgård, then bit by bit through the two
doors — into a claw, which by assumption nobody can produce. Breaking the hash
would mean solving the hard problem. *That* is what it means to base security on
mathematics.

## It isn't vacuously true

A skeptic might worry that all this elegant machinery describes something that
never happens — that the hypotheses are so restrictive no real example satisfies
them. The formalization closes that door with a concrete witness, the smallest
one imaginable, living on just two states $\{0, 1\}$ (the integers modulo $2$).

Take door $0$ to be the identity, $g_0(x) = x$, and door $1$ to be "add one,"
$g_1(x) = x + 1$. Both are genuine permutations of $\{0, 1\}$. And they have a
real claw:

$$g_0(1) = 1 = 0 + 1 = g_1(0).$$

Door $0$ with key $1$ and door $1$ with key $0$ both land on state $1$. This
honest claw immediately produces an honest compression collision, certifying
that every hypothesis in the grand equivalence is actually satisfiable. The
theorems are about something real.

## Why this matters beyond the blackboard

The story you've just read is the skeleton inside the hash functions guarding
the modern world. The Merkle–Damgård chain is the literal architecture of
SHA-256, the function that anchors Bitcoin, secures TLS connections, and signs
software updates billions of times a day. The principle that a chain inherits
the strength of its weakest link is *why* designers can focus all their effort
on one small compression function and trust the rest. And the claw-free
philosophy — convert a precise, well-studied hard problem into a precise
security guarantee — is the template for *provable* cryptography, the discipline
that replaces "we tried hard to break it and couldn't" with "breaking it is
provably as hard as factoring."

There is a deeper lesson here too, almost philosophical. Collisions *must*
exist; the pigeonhole principle forbids any escape. Security does not come from
making the impossible happen. It comes from arranging the universe so that the
thing you fear, though it certainly exists, is buried under a mountain of
computation no adversary can climb. The claw is always there in the room with
two doors. We just make sure no one can ever find it.
