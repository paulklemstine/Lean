# The Locked Door That Anyone Can Open (Given Forever)

## Why every secret you have ever sent online rests on a subtle distinction between *information* and *effort*

Imagine a padlock with no key. You can snap it shut, but there is no physical way to open it again — not with a tool, not with a trick, not with infinite patience. That, in spirit, is what people imagine when they hear that modern cryptography is built on **one-way functions**: operations that are easy to perform but impossible to reverse.

It is a beautiful image. It is also wrong — and understanding *why* it is wrong turns out to be the single most important idea in theoretical cryptography. The truth is stranger and more interesting: there is no such thing as a mathematical function that genuinely cannot be reversed. Every locked door *can* be opened. The entire edifice of digital security — the padlock icon in your browser, your bank's encryption, the signatures on software updates — rests not on impossibility, but on something far more delicate: the gap between *having enough information* and *having enough time*.

This article tells the story of that gap, and of a small cluster of theorems that pin it down with mathematical precision.

## The dream of the unbreakable function

Let us be concrete. A "one-way function" `f` takes an input `x` and produces an output `f(x)`. Multiplying two large prime numbers is the classic example: given `p = 1{,}000{,}003` and `q = 1{,}000{,}033`, computing `p \times q = 1{,}000{,}036{,}000{,}099` is a few microseconds of work. But handed only the product `1{,}000{,}036{,}000{,}099`, finding the two primes that made it is — for numbers hundreds of digits long — a task that would outlast the universe on every computer ever built.

So far, so good. This *feels* one-way. The dream is that it might be one-way in an absolute, information-theoretic sense: that the output `f(x)` simply does not *contain* enough information to recover the input, the way a shredded document cannot be reassembled because the information is truly gone.

Here is the deflating truth. The information is never gone.

## A weak inverse always exists

Suppose you are an adversary with unlimited time and memory — a godlike codebreaker who can do anything except violate logic itself. You are handed an output value `y` and asked to find *some* input that produces it. Can you always succeed?

Yes. Always. Here is the recipe, and it is almost insultingly simple. Go through every possible input, one by one, and compute its output. Build a giant lookup table: output `\to` an input that produces it. Now, when someone hands you `y`, you simply look it up.

This is what mathematicians call a **weak inverse**, and it is the technical heart of the matter. Let us define it carefully, because the precision is where the insight lives. A function `g` is a weak inverse of `f` when, for *every* input `x`,

> `f(g(f(x))) = f(x)`.

Read that slowly. It does *not* say `g(f(x)) = x` — that would be asking `g` to recover the *exact* original input, which is genuinely impossible when two different inputs collide to the same output. (If both `3` and `-3` square to `9`, no inverter can know which one you started with.) Instead, the weak-inverse condition asks only that `g` recover *a* valid preimage: something that `f` maps to the same place. The lookup table does exactly this.

The formal result, proved and machine-verified, is crisp:

> **Existence of weak inverses.** For any function `f` defined on a nonempty domain, there exists a function `g` such that `f(g(f(x))) = f(x)` for every `x`.

The proof uses a canonical construction — mathematicians call it `invFun f`, the "choose-any-preimage" function — and verifies that it satisfies the weak-inverse equation by definition. No cleverness required. The witness is the lookup table, formalized.

## The theorem that names the enemy

Now we can state the central conceptual result, the one that quietly governs every cryptographic system in the world. Define a function to be **information-theoretically one-way** if *no* inverter ever works — if for every candidate `g`, there is some input `x` where `g` fails to find a preimage. This is the formalization of the padlock-with-no-key dream.

The theorem says: that dream is impossible.

> **No function is information-theoretically one-way.** For any function `f` on a nonempty domain, it is *not* the case that every inverter fails. At least one inverter — the lookup table — succeeds everywhere.

The proof is two lines of logic. Suppose, for contradiction, that `f` were information-theoretically one-way. Then every inverter fails somewhere. But we just built an inverter (the weak inverse) that succeeds *everywhere*. Apply the "fails somewhere" claim to *that* inverter and you get a point where it both succeeds and fails — a contradiction. Done.

This little theorem is doing enormous work. It tells us that **one-wayness can never come from information theory**. The output of factoring, of hashing, of any function whatsoever, always contains enough information to recover an input. The shredded document can always, in principle, be reassembled.

So where does security come from? From the word "in principle." Building that lookup table for a function on 256-bit inputs requires enumerating `2^{256}` entries — more than the number of atoms in the observable universe, by a factor of billions of billions. The information is there. The *time* to extract it is not. One-wayness, the theorem teaches us, "lives entirely in complexity." It is a statement about computational effort, never about information. This is why cryptographers must *assume* the existence of one-way functions as a hardness hypothesis: they cannot be conjured from pure logic, because pure logic always defeats them.

## How much can you recover? The arithmetic of collisions

Having established that *weak* inversion always succeeds perfectly, a natural question sharpens itself: how much can an adversary recover *exactly*? Not just *a* preimage, but *the* original input, on the nose?

This is where the geometry of collisions enters. If a function squashes many inputs onto the same output — think of all the different documents that hash to the same fingerprint — then no inverter can untangle them. Faced with a shared output, the best any `g` can do is pick one input and be right only for that one. Each "collision cluster" (mathematicians call it a **fiber**) yields at most one exact recovery.

Counting this precisely gives a clean and sharp law. Let `|\mathrm{Im}\, f|` denote the number of *distinct outputs* the function produces — its image size. Then:

> **Exact-inversion upper bound.** Any inverter `g` whatsoever recovers the exact original input for at most `|\mathrm{Im}\, f|` of the inputs.

The reasoning is a small gem. On the set of inputs that `g` *does* recover exactly, the function `f` must be injective — distinct exact-recoveries force distinct outputs, because if `g` returns the true input it can only do so for one input per output. So `f` embeds that set into its image, and a set cannot be larger than something it embeds into. Hence the count is at most the image size.

And this bound is not merely an upper limit that nobody reaches — it is *achieved*:

> **Optimality of the canonical inverter.** The lookup-table inverter `invFun f` recovers exactly `|\mathrm{Im}\, f|` inputs — the maximum possible.

The proof exhibits a perfect pairing: each distinct output `y` corresponds to exactly one input that the lookup table "gets right," namely `invFun f(y)`, and this correspondence is a bijection between the image and the set of exactly-recovered inputs. The two theorems together say something quietly profound: **the image size of a function is the exact information-theoretic capacity of perfect recovery.** A function that crushes a billion inputs down to ten outputs can be perfectly inverted on at most ten inputs — and the simple lookup strategy already hits that ceiling. Lossiness is precisely measured, and it is precisely the obstacle.

There is even a companion fact worth savoring for its contrast. While *exact* recovery is capped at the image size, *weak* recovery — finding any valid preimage — is uncapped. A weak inverter succeeds on **every single input**:

> **Weak inverters are perfect.** If `g` is a weak inverse of `f`, then the number of inputs `x` on which `g` succeeds (in the sense `f(g(f(x))) = f(x)`) equals the full size of the domain.

So the same function can be utterly uninvertible in the exact sense yet trivially invertible in the weak sense. The distinction between "find the original" and "find an original" is the whole ballgame.

## A ladder of assumptions

These results are not isolated curiosities. They sit at the foundation of a tower — a hierarchy of cryptographic building blocks, each stronger than the last:

> **one-way functions `\to` pseudorandom generators `\to` pseudorandom functions `\to` secure encryption.**

A one-way function (OWF) is the humblest assumption: something easy to compute, hard to invert. From it, a celebrated chain of constructions builds *pseudorandom generators* (which stretch a short random seed into a long random-looking string), then *pseudorandom functions* (random-looking lookup tables you can carry in your pocket as a short key), and finally full *secure encryption*. Each arrow is a theorem in the cryptographic literature, and each one *amplifies* the same fragile assumption — that inversion is hard — into ever richer guarantees.

The framework formalizes this ladder as four ranked levels, and proves the ladder is a genuine, rigid *chain*: the four primitives are totally ordered by strength, OWF sits at the bottom as the weakest assumption, and secure encryption sits at the top as the strongest. There is no ambiguity, no incomparable rungs — it is order-isomorphic to the simple counting `0 < 1 < 2 < 3`. "A stronger assumption" turns out to mean, literally, "a higher number." This makes the folklore picture of cryptography mathematically exact: the whole field is a chain anchored, at its very bottom, by the one assumption that — as our central theorem shows — *cannot* be proved, only assumed, because information theory will never grant it.

## Why this matters

Step back and look at what these few theorems accomplish together. They take a fuzzy, much-misunderstood slogan — "some functions can't be reversed" — and replace it with a precise and slightly unsettling truth:

- **No function is truly irreversible.** A weak inverse always exists; the information is always there.
- **Security is a budget, not a wall.** One-wayness is purely about computational cost — the cost of building or searching that universe-sized lookup table.
- **Lossiness is measurable.** The exact number of inputs any adversary can perfectly recover equals the function's image size, and the naive strategy already achieves it.
- **Everything rests on the bottom rung.** The entire cryptographic hierarchy, from random-number generators to encryption, amplifies one unprovable-but-plausible assumption.

The next time you see the little padlock in your browser, remember: it is not a door that cannot be opened. It is a door that *can* be opened — by anyone willing to wait until long after the stars burn out. Cryptography is the art of making "in principle possible" and "in practice impossible" peacefully coexist. And these theorems are the survey markers that show exactly where the line between them falls.

The information was never the secret. The *time* was the secret all along.
