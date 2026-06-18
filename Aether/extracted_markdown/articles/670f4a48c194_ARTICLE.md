# The Hidden Algebra of Unbreakable Hashes

## A digital fingerprint for everything

Every time you log into a website, download a piece of software, or send a
message that promises to be tamper-proof, you are relying on a quiet workhorse
of modern computing: the **cryptographic hash function**. A hash function takes
a chunk of data of *any* size — a one-line password, a feature-length film, the
entire text of an encyclopedia — and crushes it down to a short, fixed-length
fingerprint. Change a single comma in the original, and the fingerprint changes
completely and unpredictably.

For this fingerprint to be trustworthy, one property matters above all others:
it should be effectively impossible to find two *different* inputs that produce
the *same* fingerprint. Such a coincidence is called a **collision**, and a hash
function for which collisions are hard to find is called **collision resistant**.
If collisions were easy, a forger could swap a malicious file for a trusted one
without anyone noticing, because both would carry the same fingerprint.

There is a beautiful engineering problem hiding here. A hash function must accept
inputs of unbounded length, yet the only building block we really know how to
design and scrutinize carefully is a *small, fixed-size* mixing function — one
that takes a fixed-size internal state plus a fixed-size block of new data and
returns a new fixed-size state. How do you bootstrap an unbounded-length,
collision-resistant hash from a tiny fixed-size ingredient? And once you have,
how do you *prove* the big construction is as safe as its small ingredient?

The classical answer is a fifty-year-old design called the **Merkle–Damgård
construction**, the skeleton inside famous hash functions such as MD5 and the
SHA-2 family. This article tells the story of that construction — and of a
surprising discovery: underneath its security proof lies a clean piece of
abstract algebra. The act of hashing a message is, quite literally, an action of
words on a space of states. Seeing it this way does not just make the theory
prettier; it makes the central security guarantee *stronger* and more general.

## The conveyor belt

Picture a conveyor belt. At the start sits a fixed lump of clay called the
**initialization vector**, or **IV** — a publicly known starting state. The
message to be hashed is chopped into equal-size blocks, and the blocks ride down
the belt one after another. At each station, a single machine — the **compression
function** `f` — takes the current lump of clay (the running state) together with
the next block, kneads them together, and produces a new lump. When the last
block has been processed, the final lump *is* the hash.

In symbols, if the running state is `a` and the next block is `b`, the machine
computes `f a b`. Processing a whole message is just doing this over and over,
folding each block into the state in turn. Mathematicians call this a *left fold*.
We write the whole process as

> **merkleDamgard f iv msg** = fold the blocks of `msg` into `iv`, one at a time,
> using `f`.

Two facts about this conveyor belt are immediate but important. First, an empty
message changes nothing: with no blocks to process, the output is just the IV
itself. Second — and this is the structural heart of the whole design — if you
glue two messages together, you can hash them in stages:

> **Domain extension.** Hashing the concatenation `m₁ ++ m₂` starting from `iv`
> gives exactly the same result as first hashing `m₁` to get an intermediate
> state `h`, and then hashing `m₂` starting from `h`. In symbols,
>
> `merkleDamgard f iv (m₁ ++ m₂) = merkleDamgard f (merkleDamgard f iv m₁) m₂`.

This says the belt has no memory beyond its current lump of clay. The only thing
that survives from the first half of a message into the second half is the single
intermediate state. Hold onto that picture — it is the seed of everything that
follows.

## From a small promise to a big one

Now comes the security argument, and it is one of the most elegant reductions in
all of cryptography. We want to prove:

> **If the little machine `f` never produces a collision, then the whole conveyor
> belt never produces a collision either — at least among messages of the same
> length.**

What does "the little machine never collides" mean precisely? It means that `f`,
viewed as a function of the *pair* (state, block), is **injective**: distinct
pairs always give distinct outputs. You can never reach the same new state from
two genuinely different (state, block) combinations.

The key technical fact is what we might call **joint injectivity of the fold**.
Suppose two equal-length messages, started from two possibly-different states,
end at the *same* final state. Then — provided the little machine `f` is
injective — the two starting states must have been equal *and* the two messages
must have been identical:

> **Joint injectivity.** If `f` is injective on pairs, and two equal-length block
> sequences `l₁`, `l₂` folded from initial states `a₁`, `a₂` reach the same
> result, then `a₁ = a₂` and `l₁ = l₂`.

The proof is a small marvel of recursion. Run the argument backwards from the
end of the belt. The two messages reach the same final lump. Strip off their last
blocks: the states just before the final station, together with the final blocks,
both feed into `f` and come out equal. By the inductive hypothesis, the shorter
prefixes must already have matched — same intermediate states, same earlier
blocks. Now invoke the injectivity of `f` one last time: equal outputs from `f`
force equal inputs, so the last states matched and the last blocks matched too.
Layer by layer, the equality peels off like the skin of an onion, until nothing
but identity remains.

From joint injectivity, the headline security theorem is a one-line corollary.
Fix a single IV and feed it two equal-length messages that produce the same hash.
Joint injectivity (with both starting states equal to the IV) immediately forces
the two messages to coincide:

> **Collision resistance is preserved.** If the compression function is
> injective, then `merkleDamgard f iv` is injective on messages of equal length.

Read in reverse — by contraposition — this is exactly the reduction a security
engineer wants:

> **The collision reduction.** If two *distinct* equal-length messages hash to
> the same value under the belt, then there must exist two distinct input pairs
> `(a₁, b₁) ≠ (a₂, b₂)` with `f a₁ b₁ = f a₂ b₂` — a genuine collision in the
> little machine.

In other words, breaking the big hash *requires* breaking the small one. All the
scrutiny we lavish on the fixed-size compression function pays off automatically
for messages of every length. That is the magic of Merkle–Damgård, and it is why
a handful of carefully designed mixing functions can secure the entire internet.

## A constructive twist

The reduction above is a proof by contradiction: it tells you a collision in `f`
*exists*, but does not hand it to you. There is a sharper, fully *constructive*
version. Suppose two genuinely different starting states are funneled through the
same message and converge to the same endpoint. Then somewhere along the belt
there is an identifiable station where two distinct states, fed *the same block*,
produced the same output:

> **Constructive convergence.** If `a₁ ≠ a₂` but folding the same message from
> both yields the same result, then there exist states `s₁ ≠ s₂` and a block `b`
> with `f s₁ b = f s₂ b`.

Walk down the belt block by block. At the very first station, either the two
states already collide under the first block — and we are done — or they stay
distinct, in which case the problem repeats with the two new states and the rest
of the message. Since the states are equal at the end but unequal at the start,
the collision station must exist somewhere in between. This version even tells you
something extra: the collision it finds always uses the *same block* on both
sides, isolating the disagreement entirely in the chaining state.

## The danger of forgetting length

Notice the recurring fine print: *messages of the same length*. It is not
decorative. Drop it and the belt becomes genuinely insecure, through a flaw with
a name — the **length extension attack**. Recall the domain-extension property:
appending a suffix `s` to a message `m₁` simply continues the fold from the hash
of `m₁`. An attacker who knows only the hash of `m₁` — not `m₁` itself — can
therefore compute the hash of `m₁ ++ s` for any suffix `s` of their choosing:

> **Length extension.** `merkleDamgard f iv (m₁ ++ s) = merkleDamgard f (hash of m₁) s`.

This is why real-world hashes pad their inputs with an encoding of the original
message length before hashing — a trick called **Merkle–Damgård strengthening**.
If the padding scheme is injective and always produces equal-length outputs for
equal-length inputs, the same injectivity machinery now applies to messages of
*every* length at once:

> **Strengthened security.** If `f` is injective and the padding is injective and
> length-regular, then the padded construction is injective on *all* messages,
> not merely same-length ones.

Length, it turns out, is not a nuisance to be swept under the rug; it is part of
what is being hashed.

## The twist: hashing is an action

Here is where the story takes its most beautiful turn. So far we have treated the
IV as fixed and asked questions about messages. But look again at the conveyor
belt and ask a different question: *what does a message do?* A message `m` is a
recipe for transforming states. Hand it any starting lump `a`, and it returns a
finished lump. So a message is not really a piece of data at all — it is a
**function from states to states**:

> **mdEnd f m** = the transformation `a ↦ merkleDamgard f a m`.

These transformations live in a well-studied algebraic home: the monoid of
self-maps of the state space, where the "multiplication" is just composition of
functions and the identity element is the do-nothing map. The empty message is
precisely that do-nothing identity. And the domain-extension property we met
earlier is reborn as a clean algebraic law. Concatenating messages *composes*
their transformations — but in reverse order, because you must run the first
message before the second:

> **The action law.** `mdEnd f (m₁ ++ m₂) = mdEnd f m₂ ∘ mdEnd f m₁`.

This reversal is not a blemish; it is a signpost. When concatenation maps to
composition *backwards*, the natural algebraic target is the **opposite monoid** —
the same set of transformations, but with multiplication order flipped. Once we
respect that, the entire Merkle–Damgård construction collapses into a single
algebraic object: a **homomorphism** from the free monoid of message blocks (the
set of all finite block sequences under concatenation) into the opposite monoid
of state transformations.

> **The Merkle–Damgård homomorphism.** There is a structure-preserving map
> `mdHom f` sending each word of blocks to its state transformation, turning
> message concatenation into composition. Evaluating it at the IV recovers the
> ordinary hash.

A monoid homomorphism is the algebraist's way of saying "this map respects
structure." Recasting Merkle–Damgård as a homomorphism means the messy details of
folding are packaged once and for all, and every later fact about hashing becomes
a fact about an algebraic map.

## Faithfulness is just collision resistance in disguise

What, in this new language, is collision resistance? An algebraic action is
called **faithful** when distinct elements act differently — when no two distinct
words produce the very same transformation. And that is *exactly* what we want
from a hash: distinct messages should not be interchangeable. Faithfulness is
collision resistance, spelled in algebra.

The payoff is a genuinely *stronger* theorem, obtained almost for free. The
original security result fixed one IV. The action viewpoint hands us a version
that holds for *all* IVs simultaneously:

> **Faithful action ⇒ collision resistance (IV-free).** If the compression
> function is injective and the state space is nonempty, then two equal-length
> messages that induce the *same state transformation* must be the same message.

Why "almost for free"? Because two messages induce the same transformation
precisely when they agree on *every* starting state — in particular on any one
state we care to pick. Pick any state (this is the only place we need the harmless
assumption that the state space is not empty), and the original joint-injectivity
fact finishes the job in a single line. The same theorem, in homomorphism
language, says the Merkle–Damgård homomorphism is injective on words of any fixed
length.

It is worth savouring why this is strictly stronger. The classical statement
says: "for this particular IV, the hash separates equal-length messages." The
action statement says: "as functions of *all possible* IVs at once, the messages
are different." The first is a single snapshot; the second is the whole movie.

## Where the analogy stops

A good abstraction also tells you precisely *where it breaks*, and the action
picture is honest about its limits. One might hope the converse holds — that a
faithful action forces the compression function to be injective. It does not.
There are nonempty state spaces and *non-injective* compression functions whose
action is nonetheless faithful. The reason is illuminating: the action only ever
sees the compression function through the *reachable* chaining states. If the
collisions of `f` hide among states the belt never actually visits, the action is
blind to them. (A clean way this happens: over an alphabet with a single possible
block, any two equal-length messages are *automatically* identical, so
faithfulness on equal-length words is vacuously true regardless of `f`.)
Faithfulness, then, is genuinely weaker than injectivity of `f` — a subtlety the
algebra makes precise rather than hiding.

## Climbing the ladder: from chains to trees

There is one more rung to climb. The conveyor belt is a *line* — each block
depends on the one before. But the same collision-resistance idea works on
*trees*. In a **Merkle tree**, data sits at the leaves; each internal node hashes
together the fingerprints of its two children; and the single fingerprint at the
root certifies the entire tree at once. Merkle trees are the backbone of
blockchains, version-control systems, and large-scale file integrity checks,
precisely because you can prove a single leaf belongs to the tree without
revealing all the others.

The line is just the simplest tree — a path. And the security proof generalizes
along with the structure:

> **Tree collision resistance.** For trees of a *fixed shape*, an injective node
> combiner yields an injective tree hash: two trees of the same shape with the
> same root fingerprint must be identical.

The proof rhymes exactly with the conveyor-belt argument — *shape determines
structure, and injectivity peels off one layer at a time* — only now the recursion
branches instead of marching in a straight line. And once again the fine print
matters: the **same-shape** hypothesis cannot be dropped. Without it, a leaf could
collide with an internal node, and security evaporates. That single observation
points toward an active research frontier known as **domain separation**:
designing hashes so that data of different *kinds* — a leaf versus a branch, a
short message versus a long one — can never be confused.

## Why this matters

The Merkle–Damgård construction has secured digital signatures, software updates,
password storage, and blockchains for half a century. Its security proof — that
breaking the whole requires breaking a single small part — is a textbook example
of how cryptographers turn a modest, well-studied gadget into a guarantee about
arbitrarily large data.

What the algebraic retelling adds is *perspective*. By recognizing that a message
is a transformation, that concatenation is composition, and that the whole scheme
is a single homomorphism, the security property sheds its dependence on an
arbitrary starting state and becomes a statement about a clean mathematical map.
Collision resistance becomes faithfulness; domain extension becomes a
multiplication law; and the leap from chains to trees becomes the leap from a
free monoid to a free magma. The mathematics that protects your data, it turns
out, was algebra all along.
