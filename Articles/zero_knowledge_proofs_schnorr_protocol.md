# How to Prove You Know a Secret — Without Revealing It

Imagine you want to convince a stranger that you know the password to a vault,
but you refuse to say the password, type it, or even hint at a single one of its
characters. At the end of the conversation the stranger should be *completely
convinced* that you know the secret — yet should have learned *nothing whatsoever*
that could help them open the vault themselves. Worse, anyone eavesdropping should
be just as clueless.

This sounds paradoxical. How can a conversation transmit *certainty* without
transmitting *information*? Yet it is one of the most beautiful and consequential
ideas in modern cryptography. It is called a **zero-knowledge proof**, and one of
its oldest, simplest, and most widely deployed incarnations is the **Schnorr
identification protocol**, invented by Claus-Peter Schnorr in the late 1980s.
Schnorr's idea lives at the heart of digital signatures used in Bitcoin, in the
EdDSA signatures protecting secure web connections, and in countless
authentication systems.

This article tells the story of why Schnorr's protocol works — and, more
unusually, what it means to be *absolutely sure* that it works. Every claim below
has been pinned down as a precise mathematical theorem and checked to the last
symbol.

## The setting: a one-way street

Cryptography runs on functions that are easy to compute but hard to reverse —
mathematical "one-way streets." Schnorr's street is built from *modular
exponentiation*, or in the cleaner additive language we will use, *scalar
multiplication in a finite cyclic group*.

Fix a prime number $p$ and work inside the world of integers modulo $p$, written
$\mathbb{Z}/p\mathbb{Z}$. Pick a fixed nonzero element $g$, the **generator**.
Your secret is a number $x$. Your **public key** is

$$Y = x \cdot g.$$

Everyone can see $Y$ and $g$. The "one-way" assumption — the famous **discrete
logarithm problem** — is that, knowing only $Y$ and $g$, no one can feasibly
recover $x$. (In our formal model the group is the additive structure of a prime
field, where the algebra is transparent; in real deployments $g$ generates a
large cyclic group inside an elliptic curve, where reversing the multiplication is
believed to be astronomically hard.) Your goal: convince a verifier that you know
$x$, without leaking $x$.

## The three-move dance

Schnorr's protocol is a **Σ-protocol** ("sigma protocol"), named for the
zig-zag shape of its three messages: *commit, challenge, respond.*

1. **Commit.** You secretly pick a random number $r$ and send the *commitment*
   $t = r \cdot g$. Notice you have committed to $r$ without revealing it — $t$ is
   the public key of $r$, and recovering $r$ from $t$ is exactly as hard as the
   discrete logarithm problem.

2. **Challenge.** The verifier flips coins and sends back a random *challenge*
   $c$.

3. **Respond.** You compute and send the *response*
   $s = r + c \cdot x$.

The verifier accepts your proof of knowledge if and only if the single equation

$$s \cdot g = t + c \cdot Y$$

holds. That's the whole protocol. Three messages, one verification equation.

A complete record of one run — the triple $(t, c, s)$ — is called a
**transcript**.

## Why it convinces: the three pillars

A zero-knowledge identification protocol must satisfy three properties, and each
one is a theorem.

### Pillar 1 — Completeness: honesty always works

If you genuinely know $x$ and follow the rules, you *always* pass. Plug the honest
values into the verification equation:

$$s \cdot g = (r + c\,x)\cdot g = r\cdot g + c\,(x\cdot g) = t + c \cdot Y.$$

The equation holds identically. There are no flukes, no negligible failure
probability — honest provers pass with certainty. Formally:

> **Completeness.** For every secret $x$, randomness $r$, and challenge $c$, the
> honest transcript $(r\cdot g,\; c,\; r + c\,x)$ satisfies the verification
> equation against the public key $Y = x\cdot g$.

### Pillar 2 — Soundness: cheating almost never works

Now suppose an impostor does *not* know $x$. Could they get lucky? Here is the
crux. Imagine an impostor who has somehow committed to a particular $t$ and is then
challenged. The remarkable fact is that **for each commitment $t$ there is exactly
one challenge $c$ the impostor could successfully answer.** If they could answer
*two* different challenges $c_1 \ne c_2$ for the same commitment, then we could
extract their secret — which means they must have known it all along.

Why? Suppose two transcripts $(t, c_1, s_1)$ and $(t, c_2, s_2)$ both verify and
share the commitment $t$. Subtracting their verification equations,

$$(s_1 - s_2)\cdot g = (c_1 - c_2)\cdot Y.$$

Because $p$ is prime, $\mathbb{Z}/p\mathbb{Z}$ is a *field*: every nonzero number
has a multiplicative inverse. Since $c_1 \ne c_2$, the difference $c_1 - c_2$ is
invertible, and we can solve outright for the secret:

$$x^\star = (c_1 - c_2)^{-1}\,(s_1 - s_2).$$

This number is a *genuine* witness — even if we never assumed a secret existed in
the first place. Just two accepting answers to two different challenges *prove that
$Y$ has a discrete logarithm and hand it to us explicitly.* This is called
**special soundness** (or, in its strongest form, **knowledge soundness**), and
it is the engine that turns "passing the test" into "actually knowing the secret":

> **Knowledge soundness.** For an arbitrary public key $Y$, any two accepting
> transcripts $(t, c_1, s_1)$ and $(t, c_2, s_2)$ with $c_1 \ne c_2$ yield a value
> $x^\star = (c_1 - c_2)^{-1}(s_1 - s_2)$ satisfying $x^\star \cdot g = Y$.

The consequence for cheating is sharp. An impostor who has fixed a commitment can
satisfy *exactly one* of the $p$ possible challenges (any second one would betray
the secret they don't have). So a random challenge catches them with probability
$1 - 1/p$, and they slip through with probability exactly $1/p$. This is the
**soundness error**, and for a large prime $p$ — think of a 256-bit number — the
chance of a successful bluff is smaller than the chance of guessing a specific
atom in the observable universe.

### Pillar 3 — Zero knowledge: the verifier learns nothing

This is the magical pillar. We must show that the transcript — even though it
convinces — contains no usable information about $x$. The standard way to make
"learns nothing" precise is the **simulation paradigm**: we exhibit a *simulator*
that, *without ever knowing $x$*, produces transcripts that are statistically
indistinguishable from real ones. If fake transcripts (made with no secret) look
exactly like real ones, then real transcripts cannot be leaking the secret.

Schnorr's simulator is delightfully simple. To fake a transcript, run the protocol
*backwards*: first pick the challenge $c$ and the response $s$ at random, then
*back out* the commitment that makes the equation balance:

$$t = s\cdot g - c\cdot Y.$$

By construction $(t, c, s)$ passes verification — no secret was used anywhere.

But "looks plausible" is not enough. We want **perfect** zero knowledge: the fake
transcripts should follow *exactly* the same probability distribution as the real
ones. The key is an explicit, reversible dictionary between the two worlds. In the
honest world a transcript is determined by the pair $(r, c)$; in the simulated
world by the pair $(s, c)$. The map

$$(r, c) \longmapsto (r + x\,c,\; c)$$

is a perfect one-to-one correspondence (a *bijection*) between these two worlds —
its inverse is simply $(s, c)\mapsto(s - x\,c,\,c)$ — and it sends each honest
transcript to an identical simulated one. Because it is a bijection on a finite,
uniformly random space, it preserves all probabilities:

> **Perfect honest-verifier zero knowledge.** For *every* event $E$ on
> transcripts, the number of honest random choices producing a transcript in $E$
> equals the number of simulator random choices producing a transcript in $E$.
> Dividing by the total number $p^2$ of choices, the honest and simulated
> transcripts assign $E$ *exactly* the same probability.

The phrase "for every event $E$" is what makes this airtight. It does not matter
how clever or adaptive an eavesdropper is, what statistical test they run, or what
feature of the transcript they fixate on: the honest and simulated distributions
are *identical*, so no test can tell them apart. Since the fakes carry zero
information about $x$ and are indistinguishable from the real thing, the real
transcripts carry zero information too. That is zero knowledge in its strongest,
exact form — not "close," but equal.

## From conversation to signature: the Fiat–Shamir trick

The protocol so far is *interactive*: it needs a live verifier to toss the
challenge. But the most valuable applications — digital signatures — must work
offline, with no one on the other end. The **Fiat–Shamir transform** performs a
small miracle: it removes the verifier entirely.

The idea is to let the prover generate their *own* challenge, but in a way they
cannot manipulate. We use a cryptographic hash function $H$ — a function that
behaves, for all practical purposes, like a random, unpredictable oracle. Instead
of waiting for a challenge, the prover computes it from their own commitment:

$$c = H(t).$$

A non-interactive proof is now just the pair $(t, s)$; the verifier recomputes
$c = H(t)$ and checks the same old equation $s\cdot g = t + H(t)\cdot Y$. To turn
this into a *signature* on a message $m$, one simply folds $m$ into the hash,
$c = H(t, m)$, binding the proof to the message.

Crucially, all the security carries over intact:

> **Fiat–Shamir completeness.** The honest non-interactive prover is always
> accepted, for *any* hash function $H$.

> **Fiat–Shamir = interactive with a self-chosen challenge.** A non-interactive
> proof $(t, s)$ verifies if and only if the interactive transcript
> $(t, H(t), s)$ verifies. The transform adds no new algebra; it only *fixes* the
> challenge.

> **Forking extraction.** If an attacker can produce two accepting proofs for the
> same commitment $t$ but under two different oracle answers $c_1 \ne c_2$ — a
> situation a security reduction engineers by "rewinding" the attacker and feeding
> the oracle a fresh answer — then the very same extraction formula recovers the
> secret. This is the algebraic heart of the **Forking Lemma**, the classic tool
> proving Schnorr signatures unforgeable.

There is even a tidy uniqueness fact underpinning this: for a fixed commitment and
a fixed oracle answer, *the accepting response is unique.* So the oracle's answer
completely pins down the only proof that can work — which is exactly why a second,
different oracle answer is so revealing.

## Why certainty matters here

Cryptographic protocols are notoriously subtle. A single overlooked case, a
misplaced assumption, a "negligible" probability that is not actually negligible —
any of these can collapse a security argument and, with it, the systems built on
top. Schnorr's protocol is simple enough to fit on a napkin, yet its security rests
on a delicate interplay of field arithmetic (every nonzero challenge difference is
invertible), probability (the soundness error is *exactly* $1/p$, not merely
"small"), and combinatorics (a bijection that preserves *every* event's
probability).

Every theorem quoted above — completeness, special and knowledge soundness, the
exact $1/p$ soundness error, perfect honest-verifier zero knowledge as equality of
event probabilities, and the full Fiat–Shamir package — has been stated with
mathematical precision and verified down to the smallest logical step. The witness
extractor really does return a value $x^\star$ with $x^\star\cdot g = Y$ for an
*arbitrary* public key. The simulator really does match the honest distribution on
*every* event, not just on average.

The result is a piece of cryptographic infrastructure whose trustworthiness rests
not on the reputation of its designers or the absence of known attacks, but on
proof. In a world that increasingly runs on the promise that secrets can be proven
without being revealed, that kind of certainty is worth a great deal.

## The takeaway

Zero-knowledge proofs resolve a paradox that sounds impossible: convincing someone
of a fact while teaching them nothing. Schnorr's protocol achieves it with three
short messages and a single equation, $s\cdot g = t + c\cdot Y$. Completeness makes
honesty effortless; soundness makes deception cost a secret you don't have;
zero knowledge makes the transcript a perfect blank. And the Fiat–Shamir transform
quietly turns this living conversation into the signatures that secure much of the
digital world. The deepest part of the story is not just that it works — it is
that we can *prove*, with absolute certainty, exactly why.
