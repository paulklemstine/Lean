# The Locksmith Who Could Always Pick the Lock

## Why secret-keeping is a race against the clock, not a wall against the universe

Imagine a padlock so perfect that no key in the world could open it. Not a
lock that is merely hard to pick, but one that is *theoretically* unpickable —
a lock for which the opening key simply does not exist anywhere in the cosmos.
Such a lock would be a cryptographer's dream. With it, you could scramble a
message so thoroughly that not even a god with infinite time and infinite
computers could ever read it.

Here is the unsettling truth at the heart of modern cryptography: **that lock
cannot exist.** Every function that scrambles data can, in principle, be
un-scrambled. The only thing standing between a secret and its exposure is
*time* — the sheer, staggering, astronomical amount of computation an attacker
would need to perform. Cryptography is not a wall against the universe. It is
a race against the clock.

This article is about making that idea mathematically precise. We will see
exactly why no function can be "one-way" in the deepest, information-theoretic
sense, and we will discover a beautiful, sharp number — the size of a
function's *image* — that measures precisely how much an all-powerful attacker
can recover. Along the way, we will assemble the four great primitives of
cryptography into a single, tidy ladder.

---

## What is a one-way function, really?

A **one-way function** is the cornerstone of modern cryptography. Informally,
it is a function `f` that is easy to compute but hard to reverse. Give it an
input `x`, and it spits out `f(x)` almost instantly. But hand someone the
output `f(x)` and ask them to find an input that produces it, and they are
stuck — supposedly for billions of years.

Password storage is the everyday example. When you type your password, the
server does not store the password itself. It stores `f(password)` for some
one-way function `f`. When you log in, it recomputes `f` on what you typed and
checks for a match. If a hacker steals the database, they see only the
scrambled outputs. To recover your actual password, they would have to reverse
`f` — the hard direction.

But here is the subtle question that cryptographers had to confront, and that
our story is about: **what does "hard" really mean?** Is the password truly
*gone*, irretrievably destroyed, the way information is lost when you burn a
letter? Or is it merely *hidden*, sitting there in plain sight but guarded by
a wall of computation?

The answer turns out to be the second one. And we can prove it.

---

## The attacker with all the time in the world

To pin down the idea, imagine the most powerful adversary conceivable. Call
her the *Oracle*. The Oracle has no time limit. She has unlimited memory. She
can perform any computation, no matter how vast, in the blink of an eye. The
only thing she does not have is *information she was never given*. If a fact is
genuinely not determined by what she can see, even the Oracle cannot conjure
it.

Now we play a game. We pick a function `f` and let the Oracle see an output
`f(x)`. Her job: produce *some* input that `f` maps to that same output. Note
the careful wording. She does not have to find the *original* `x` you chose —
that may be impossible if several inputs collide to the same output. She only
has to find *a* valid preimage, an input `x'` with `f(x') = f(x)`. After all,
for breaking a system, any valid key is as good as the "real" one.

Can the Oracle always win this game?

**Yes. Always. For every function, over any (nonempty) collection of inputs.**

The proof is almost insultingly simple, and that simplicity is exactly the
point. Before the game even begins, the Oracle does the following. For every
possible output value `y` that the function can produce, she scans through all
inputs, finds one that maps to `y`, and writes it down in a giant lookup
table. This table is her *weak inverse*. When she is later handed an output,
she just looks it up.

Formally, mathematics already hands us this table for free. There is a
canonical construction, which in the Lean formalization is written
`Function.invFun f`, that for each output value selects a preimage whenever one
exists. We define a map `g` to be a **weak inverse** of `f` when, for every
input `x`,

> `f(g(f(x))) = f(x)`.

Read that aloud: feed `x` through `f`, then through `g`, then through `f`
again, and you get back exactly where you started after the first step. In
words: `g` does not necessarily recover `x` itself, but it always recovers
*something that `f` treats identically to `x`*. That is all an attacker ever
needs.

The central theorem — call it the **Impossibility of Information-Theoretic
One-Wayness** — says:

> **For any function `f` over a nonempty domain, no inverter fails everywhere.
> There is always a weak inverse `g` that succeeds on every single input.**

In the formalization this is the pair of results `exists_weakInverse` (the
weak inverse exists) and `not_infoTheoreticOneWay` (so no function can defeat
*every* inverter). The Oracle always wins.

The consequence is profound. One-wayness is *never* a property of information.
It is *always* a property of computation. The only reason `f(password)` keeps
your password safe is that building the Oracle's lookup table for a realistic
function would require more steps than there are atoms in the universe. The
table exists. It is just unimaginably expensive to build. **Cryptography lives
entirely in the gap between "exists" and "can be computed in your lifetime."**

This is why, in the foundations of cryptography, the existence of one-way
functions is *assumed*, never *proved*. We now understand the deep reason: it
*cannot* be proved by counting information, because information always allows
inversion. It can only ever be a statement about complexity.

---

## How well can the Oracle really do?

We have established that the Oracle always finds *a* preimage. But let us be
more demanding. Suppose she wants not just any preimage, but the *exact*
original input — she wants `g(f(x)) = x` on the nose. How many of the inputs
can she nail exactly?

Here, at last, she meets a genuine wall, and the wall is built out of
*collisions*.

A **collision** happens when two different inputs produce the same output:
`f(a) = f(b)` with `a ≠ b`. When the Oracle is handed that shared output, she
has no way to tell whether it came from `a` or from `b`. She must guess one,
and she will be exactly right for at most one of them. The other becomes an
unavoidable error.

So the number of inputs she can pin down *exactly* is limited by how many
distinct outputs the function has. We call the set of distinct outputs the
**image** of `f`, written `Im f`, and its size `|Im f|`. The theorem
(`exact_inversions_le_image`) is razor-sharp:

> **No inverter — not even the Oracle — can exactly recover more than `|Im f|`
> of the inputs.**

The reasoning is a clean pigeonhole argument. On the set of inputs she
recovers exactly, the function `f` must be injective: if she gets both `a` and
`b` exactly right, then `a = g(f(a))` and `b = g(f(b))`, and if `f(a) = f(b)`
these force `a = b`. An injective map cannot send more elements into the image
than the image contains. Hence at most `|Im f|`.

And — this is the satisfying part — **this bound is achieved.** The Oracle's
canonical lookup table `Function.invFun f` hits the maximum exactly
(`invFun_exact_inversions`):

> **The canonical inverter recovers exactly `|Im f|` inputs — the best possible.**

The achievability requires a touch more care than the upper bound. The recipe
is a bijection: each distinct output value `y` in the image corresponds to
precisely one input that the lookup table fixes, namely the entry
`g(y) = invFun f (y)`. Running over all `|Im f|` distinct outputs produces
exactly `|Im f|` perfectly-recovered inputs, no more and no less.

Put the two halves together and a striking picture emerges. The image size
`|Im f|` is not just *an* answer. It is *the* answer — the exact
**information-theoretic capacity of exact inversion.** A function that crushes
many inputs down to few outputs (a *lossy* function, with small image) is
intrinsically hard to invert exactly, no matter how clever the attacker,
because the lost information is genuinely gone. A function with a large image
leaks almost everything to a determined Oracle.

We can even read the capacity as a deficit. Every input lands in exactly one
output, so the total number of inputs equals the sum, over all output values,
of how many inputs map there (the *fiber* sizes). The image size is therefore
the number of inputs *minus* the "collision deficit" — the surplus of inputs
crammed into fibers that hold more than one element. Exact-recovery capacity is
domain size minus collisions. The slogan writes itself.

---

## A ladder of locks

One-way functions do not live alone. They sit at the bottom of a celebrated
ladder of cryptographic primitives, each strictly stronger than the last:

1. **One-Way Functions (OWF)** — easy forward, hard backward. The foundation.
2. **Pseudorandom Generators (PRG)** — stretch a short random seed into a long
   stream that no efficient test can distinguish from true randomness.
3. **Pseudorandom Functions (PRF)** — an entire family of functions that, to an
   efficient observer, behaves like a perfectly random lookup table.
4. **Secure Encryption (ENC)** — the full IND-CPA guarantee, where ciphertexts
   reveal nothing about the messages they hide.

The classical theory shows you can build each rung from the one below: OWFs
give PRGs (the famous Håstad–Impagliazzo–Levin–Luby construction), PRGs give
PRFs (the Goldreich–Goldwasser–Micali tree), and PRFs give secure encryption.
The arrows point in one direction; the hierarchy does not collapse.

In the formalization, this ladder is captured by an enumeration
`CryptoLevel` with four members `OWF, PRG, PRF, ENC`, each assigned a *rank*
`0, 1, 2, 3`. "Level A implies level B" precisely when A's rank is at least
B's. The structural results upgrade what was a mere chain of implications into
a genuine **total order with a smallest and a largest element**:

- The rank assignment is *injective* — the four levels are genuinely distinct,
  never accidentally equal (`rank_injective`).
- Any two levels are comparable — given any pair, one implies the other
  (`level_total`).
- **OWF is the weakest:** it sits at the bottom, implied by everything above
  (`owf_weakest`).
- **ENC is the strongest:** it sits at the top, implying everything below
  (`enc_strongest`).

Mathematically, the cryptographic hierarchy is order-isomorphic to the simple
chain `0 < 1 < 2 < 3`. All the rich machinery of reductions, hybrids, and tree
constructions resolves, at the level of pure structure, into the most familiar
order in mathematics: counting to four.

This is the quiet beauty of formalization. The towering edifice of
cryptographic reductions has, hiding inside it, the skeleton of a children's
counting rhyme — and the proof that one-wayness can never be more than a
deadline.

---

## So is your password safe?

Yes — for now, and for a long time to come. But not because the universe
forbids recovering it. It is safe because the Oracle's lookup table, though it
provably exists, is so colossal that no machine humanity can build, running for
the entire age of the cosmos, could finish assembling it. Your secret is
guarded not by an impossibility but by an inconceivability.

That distinction matters more than it might seem. It tells us where to look for
danger. A faster algorithm, a clever shortcut, or a quantum computer does not
need to break a law of nature to read your secrets — the information was never
truly destroyed, only buried. It only needs to make the Oracle's table cheap
enough to build. Every advance in computation chips away at the wall, and the
defenders must keep the wall taller than the attackers can climb.

Cryptography, then, is not a fortress. It is a footrace, run on a track whose
length we can now measure exactly: the gap between what *exists* and what can
be *computed* in time. The mathematics in this article makes that track
visible. The information is always there. Whether anyone can ever reach it is,
and always will be, a question of speed.
