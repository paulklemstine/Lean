# The Hidden Ladder Beneath Every Proof

## When "shorter" becomes a science

Every mathematician has felt it: some proofs are slick, a single luminous page;
others grind on for a hundred grim lemmas. We have an intuition that one proof can
be "essentially the same as" another but shorter, or that some statements are
*intrinsically* hard to certify, no matter how clever you are. For most of human
history that intuition stayed exactly that — an intuition.

In the 1970s Stephen Cook and Robert Reckhow turned it into mathematics. They asked
a deceptively simple question: *what is a proof system, in the abstract?* Strip away
the syntax of logic — the axioms, the inference rules, the Greek letters — and what
remains? Their answer was startlingly minimal. A proof system is just a way of
**checking certificates**. You hand it a string of symbols (a "proof"), it tells you
which theorem that string certifies, and the checking is efficient. Completeness
means every true statement *has* some certificate. That's it.

Once proofs are just certificates, two systems can be compared by a single yardstick:
**length**. And length is where the deepest open problem in computer science hides.
Cook and Reckhow proved a remarkable equivalence: there exists a proof system in which
*every* tautology has a short (polynomial-size) proof **if and only if** NP equals
coNP. The quest for short proofs and the quest to understand the limits of efficient
computation are, secretly, the same quest.

This article is about the *order* that lurks beneath this picture — the ladder of
proof systems ranked by how efficiently they can imitate one another — and about a
surprising bridge connecting it to one of the oldest sequences in mathematics: the
Fibonacci numbers. Everything described here has been formalized and machine-verified,
so the claims are not merely plausible; they are certified true down to the logical
foundations.

## Simulation: when one system can "speak for" another

Suppose you have two proof systems, `P` and `Q`. Maybe `P` is a powerful modern system
and `Q` is a humble one. We say **`P` p-simulates `Q`** if there's an efficient
translation that takes any `Q`-proof of a theorem and rewrites it as a `P`-proof of the
*same* theorem, with the length growing by no more than a polynomial factor.

Think of it like translation between programming languages. If you can compile every
Python program into C with only a modest blow-up in size, then C "simulates" Python in
this sense — anything Python can express compactly, C can express compactly too. The
key phrase is *only a modest blow-up*. A translation that turned a one-page proof into a
proof the size of the observable universe would be useless; "p-simulation" insists the
growth stays polynomial.

To make this precise, you need to pin down what "polynomial blow-up" means as a class
of functions. We call a function `f` from naturals to naturals **polynomially bounded**
if there's a fixed power `k` such that

> `f(n) + 1 ≤ (n + 2)^k` for every `n`.

The little `+2` in the base and `+1` on the left look like fussy bookkeeping, but they
are the secret to the whole edifice. They guarantee the class behaves well at the very
smallest inputs (the `n = 0` corner that trips up naive definitions), and — crucially —
they make the class **closed under composition**: plug one polynomially bounded function
into another and you get a third. That single algebraic fact is the engine that makes
the entire theory click into place, as we'll see.

A simulation's translation can grow, but it should never *shrink* relevant quantities
out of order, so we also ask the blow-up function to be **monotone** (bigger proofs
map to bigger bounds). Putting it together: a *blow-up function* is one that is both
monotone and polynomially bounded.

With this vocabulary, the definition of simulation is crisp:

> **`P` p-simulates `Q`** when there exists a monotone, polynomially bounded function
> `f` such that every `Q`-proof `q` has a `P`-proof of the same theorem whose size is at
> most `f(size of q)`.

## The shape of the relation: a preorder

Here is the first beautiful fact. The relation "p-simulates" is a **preorder** — it is
reflexive and transitive.

Reflexivity is easy: every system simulates itself by doing nothing (the identity
blow-up). Transitivity is where the magic lives. If `P` simulates `Q` with blow-up `f`,
and `Q` simulates `R` with blow-up `g`, then `P` simulates `R` — and the combined
blow-up is exactly the *composition* `f ∘ g`. Why is `f ∘ g` a legitimate blow-up?
Precisely because the polynomial class is closed under composition. The structural fact
"simulation chains together" is not some separate miracle; it is *literally the same
statement* as "polynomials compose to polynomials." The order theory and the growth
theory are two faces of one coin.

Because we have a preorder, we get a free notion of equivalence. Two systems are
**p-equivalent** if each simulates the other. P-equivalence is a genuine equivalence
relation, and its equivalence classes have a name: **p-degrees**. Two systems share a
p-degree exactly when they are interchangeable up to polynomial overhead — different
clothes, same body. Collapse the preorder along p-equivalence and you obtain a genuine
**partial order on p-degrees**: the cleaned-up skeleton of the whole landscape of proof
systems, a poset whose height measures how rich the world of proofs really is.

The grand open questions of proof complexity are questions about this poset. Is there a
top element — a single system that simulates *everything* efficiently? (That would be the
"super proof system," and it exists if and only if NP = coNP.) How long are the chains?
How wide are the antichains? Each separation result in the literature — resolution
cannot efficiently simulate Frege systems, and so on — is a statement that two specific
points of this poset are distinct.

## The unexpected guest: Fibonacci

To populate a poset with at least two distinct points, you need a **separation**: a pair
of systems where one provably *cannot* simulate the other. And to prove a separation you
need a hardness witness — a family of theorems that one system proves cheaply but the
other can only prove expensively.

Here the story takes a turn that no one would have scripted. The hardness witness comes
from the **Fibonacci numbers** — `1, 1, 2, 3, 5, 8, 13, 21, …`, each the sum of the two
before it, the sequence of sunflower spirals and rabbit populations and the golden ratio.

The relevant fact is that Fibonacci numbers grow *too fast to be polynomial*. They grow
exponentially. The cleanest way to see this, and the way it was verified, is a tidy
lower bound:

> **`2^n ≤ F(2n + 1)`** for every `n`.

The proof is a one-line induction resting on the recurrence `F(m + 2) = F(m + 1) + F(m)
≥ 2·F(m)`: every two steps, the Fibonacci sequence at least doubles, so after `n`
doublings it has overtaken `2^n`. From this exponential floor it follows that

> **Fibonacci growth is not polynomially bounded** — no fixed power `k` makes
> `F(n) + 1 ≤ (n + 2)^k` hold for all `n`.

This is the place where analysis enters: exponentials eventually crush every polynomial,
a fact made rigorous by comparing the ratio `(n)^k / 2^n`, which tends to zero. Once you
know Fibonacci escapes the polynomial class, a corollary drops out for free: **no
polynomially bounded function can stay above Fibonacci** pointwise. If it did, it would
itself be a polynomial bound on something exponential — impossible.

## The separation theorem

Now we can state the payoff, the bridge between a 12th-century counting sequence and a
1970s theory of computation.

> **Separation via Fibonacci lower bounds.** Suppose a system `Q` proves a family of
> theorems `t(0), t(1), t(2), …` with proofs of size at most `n`, while every `P`-proof
> of `t(n)` is forced to have size at least `F(n)`. Then `P` does **not** p-simulate `Q`.

The argument is almost embarrassingly clean once the pieces are in place. Suppose, for
contradiction, that `P` *did* simulate `Q` with some blow-up `f`. Then for each `n`,
`Q`'s cheap (size `≤ n`) proof of `t(n)` would translate into a `P`-proof of size at
most `f(n)`. But every `P`-proof of `t(n)` costs at least `F(n)`. So `F(n) ≤ f(n)` for
all `n` — the blow-up function would have to dominate Fibonacci. We just said that's
impossible. Contradiction. The simulation cannot exist.

In one sentence: **super-polynomial lower bounds are exactly the currency that buys
separations.** A theorem family that is genuinely hard for `P` but easy for `Q` proves
that `P` and `Q` sit at *different* points of the p-degree poset.

## From abstract to concrete: two honest systems

A skeptic might worry that this is all shadow-boxing — maybe the conditions of the
separation theorem can never actually be met, and the poset secretly has just one point.
So the theory is anchored with two completely explicit, honest proof systems whose
theorems are simply the natural numbers (`Thm = ℕ`), each natural number standing in for
"the `n`-th tautology."

- The **linear system** `linSystem`: a proof of `n` is just `n` itself, and its size is
  `n`. Cheap and cheerful.
- The **Fibonacci system** `fibSystem`: a proof of `n` is again `n`, but its size is
  declared to be `F(n)`. Same theorems, wildly more expensive certificates.

Both are complete — every number has a proof — because the "proves" map is the identity,
which is surjective. And the separation theorem applies immediately:

> **The linear system is *not* p-simulated by the Fibonacci system.**

There is nothing vacuous here; the witnessing theorems and proofs are concrete, and the
contradiction is real. This single example proves the simulation preorder is genuinely
non-trivial: **the poset of p-degrees has at least two distinct points.** The world of
proof systems is not a single blob; it has structure, and we can put our finger on two
of its layers.

## The template: it was never really about Fibonacci

The most illuminating insight comes when you ask *what the separation argument actually
used.* Re-read it. The word "Fibonacci" appears, but the argument never touches the
recurrence, the golden ratio, or any special property of `F`. It uses exactly one thing:
that the hardness function is **not polynomially bounded**.

So the theorem generalizes, with no extra work, into a **generic separation template**:

> Replace `F` by *any* function `s` that is not polynomially bounded. If `Q` proves its
> theorems in size `≤ n` while every `P`-proof needs size `≥ s(n)`, then `P` cannot
> simulate `Q`.

Fibonacci was never special; it was simply a *convenient, concrete, easily-bounded*
super-polynomial sequence we already understood. Any super-polynomial growth rate —
quasi-polynomial, sub-exponential, doubly-exponential — drops into the same slot and
manufactures a fresh separation. The Fibonacci bridge is one instance of an infinite
family of bridges.

The deepest lesson, then, is a kind of disenchantment that is really an enlightenment.
The hard, domain-specific labor of proof complexity — the ingenious combinatorial lower
bounds for resolution, cutting planes, Frege systems — all of it ultimately feeds into a
single, simple order-theoretic machine. The art is in *finding* a super-polynomial
hardness witness for a real system. The moment you have one, the separation is automatic;
it is pure growth theory wearing the costume of logic.

## Why this matters

It would be easy to read all of this as an elegant formalism with no stakes. The
opposite is true. The poset of p-degrees is the arena in which P versus NP, NP versus
coNP, and the very possibility of automated theorem proving all play out. Knowing that
this arena has at least two points — that not all proof systems collapse together —
is the first brick in a wall we are still, decades later, trying to build to the sky.

And there is something quietly wonderful about the cast of characters. The abstract
machinery of 20th-century complexity theory turns out to be powered, at its separating
core, by the doubling growth of a sequence Leonardo of Pisa wrote down in 1202 to count
rabbits. The continuity of mathematics — the way an idea from one millennium becomes the
load-bearing lemma of another — is on full display.

The order beneath all proofs is real, it is rich, and its first separations are written
in the language of Fibonacci.
