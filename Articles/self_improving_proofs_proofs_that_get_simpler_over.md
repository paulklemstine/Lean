# Proofs That Get Simpler Over Time

## A living idea

We usually think of a mathematical proof as a finished, frozen thing. It is checked once, printed in a book, and left alone forever. But anyone who has taught the same theorem twice knows a quieter truth: proofs *change*. The first time you prove that $\sqrt{2}$ is irrational, you drag in a small mountain of assumptions, case splits, and side lemmas. A year later you find a cleaner route. A decade later you can do it in two lines. The theorem is the same; the *proof* has been improving all along.

What if we took this seriously and asked: **can a proof be treated as a living object that gets simpler over time — and if so, does the simplification ever end?**

This article tells the story of a small, precise theory that answers exactly that. It says that proof-simplification is a genuinely *well-behaved* process: it can be arbitrarily long, but it can never go on forever, and it always converges to a simplest possible form whose complexity is an honest invariant of the theorem itself.

## Measuring a proof

To talk about "simpler," we need a number. Give every proof $P$ a **complexity**
$$C(P) = \text{length}(P) + \text{depth}(P) + (\text{number of lemmas used}).$$
Here *length* counts the steps, *depth* measures how deeply nested the reasoning is (how many "sub-arguments inside sub-arguments" appear), and *number of lemmas* counts the auxiliary results you had to invoke. Each of these is a nonnegative whole number, so their sum $C(P)$ is a nonnegative whole number too.

That last observation is the whole game. Whatever elaborate structure a proof has, its complexity is ultimately a single natural number. And the natural numbers have a magical property that the rational numbers and the real numbers lack: **you cannot descend through them forever.** There is no infinite strictly decreasing sequence $n_0 > n_1 > n_2 > \cdots$ of natural numbers. Sooner or later you hit bottom. This principle — the *well-ordering* of the natural numbers — is the engine behind everything that follows.

## What "refinement" means

Fix a theorem $T$. A **proof of $T$** is, for our purposes, a package: a complexity value $C(P)$ together with a certificate that $P$ really does establish $T$. This second part matters. A proof of $T$ can only exist if $T$ is actually true, so when we compare two proofs we are always comparing two *genuine proofs of the same theorem*. We are never smuggling in a fake.

Now define the key relation. We say a proof $P'$ **refines** a proof $P$ when
$$C(P') < C(P),$$
i.e. $P'$ proves the very same theorem, strictly more simply. Refinement is exactly "made this proof simpler."

This relation behaves like a strict order. It is **transitive**: if $P''$ refines $P'$ and $P'$ refines $P$, then $P''$ refines $P$ — chaining two simplifications is again a simplification. And it is **irreflexive**: no proof refines *itself*, because no number is strictly less than itself. So far, so intuitive. The surprises come when we ask what refinement does in the limit.

## Every family has a simplest member

Here is the first real theorem.

> **Existence of a simplest proof.** Let $S$ be any nonempty collection of proofs of $T$. Then $S$ contains a proof $P$ that no member of $S$ can refine — a member of minimal complexity.

Why is this true? Because refinement is the pullback of "$<$ on $\mathbb{N}$" through the complexity map, and "$<$ on $\mathbb{N}$" is well-founded. Concretely: the complexities of the members of $S$ form a nonempty set of natural numbers, and every nonempty set of natural numbers has a least element. Any proof achieving that least complexity is a simplest member — nothing in $S$ is strictly below it. There is no fine print, no continuity hypothesis, no need for $S$ to be finite. A simplest member simply *has to be there*.

## The limit $P_\infty$ always exists

Apply this to the collection of *all* proofs of $T$, and you get the theorem that gives the whole subject its slogan.

> **The limit of refinement always exists.** As soon as $T$ has even a single proof, it has a globally simplest proof $P_\infty$ — one that *no* proof of $T$ whatsoever can refine.

Think of the refinement process as an imaginary sculptor who keeps chipping away at a proof, making it simpler and simpler. The theorem says the sculpture is never bottomless: there is a final form, a $P_\infty$, past which no chisel can cut. And it exists the instant the theorem is provable at all — you do not have to *find* the simplest proof for it to be guaranteed to exist. This is a purely existential promise, and it is unconditional.

## The simplest complexity is an invariant of the theorem

Different people might reach different "simplest" proofs — perhaps two genuinely distinct arguments both bottom out at the same low complexity. Does that ruin the notion of a canonical simplest form? No.

> **Uniqueness of the minimal complexity.** Any two globally simplest proofs of $T$ have exactly the same complexity.

The argument is a one-liner in disguise. If $P$ and $Q$ are both simplest, then $Q$ cannot refine $P$ (so $C(P) \le C(Q)$) and $P$ cannot refine $Q$ (so $C(Q) \le C(P)$); hence $C(P) = C(Q)$. This means the number $C(P_\infty)$ does not depend on *which* simplest proof you land on. It is a property of the theorem $T$ itself — the intrinsic, irreducible cost of proving $T$ within our measure. It is the honest, down-to-earth cousin of Kolmogorov complexity: the length of the shortest description, here reincarnated as the complexity of the simplest proof.

## It can never run forever…

The sculptor metaphor suggests a dynamic picture: not a single collection, but a *sequence* of proofs, each refining the last. What happens to such a sequence?

> **No infinite refinement.** There is no infinite sequence of proofs $P_0, P_1, P_2, \dots$ in which every $P_{n+1}$ strictly refines $P_n$.

Suppose there were. Its terms form a nonempty family, which (by the theorem above) must contain a simplest member $P_k$. But the sequence keeps going, so $P_{k+1}$ strictly refines $P_k$ — contradicting minimality. The would-be infinite descent collapses. In plain terms: **you cannot keep making a proof simpler indefinitely.** Every simplification campaign hits a wall.

## …and it always halts

The strongest dynamical statement upgrades "no infinite strict descent" to "eventually constant."

> **Termination.** Any non-increasing sequence of proofs — one where complexity never goes *up* — is eventually constant. There is a stage $N$ after which $C(P_N) = C(P_{N+1}) = \cdots$, all equal to the limiting complexity.

This is the precise form of the intuition that the refinement process "settles down." You are allowed to keep tinkering, sometimes changing the proof without changing its complexity; but the complexity itself freezes forever after some finite stage $N$. The improving stops, permanently. Note the subtlety: the *proofs* may keep changing after stage $N$ (you can rearrange a two-line proof endlessly), but their *complexity* is locked. It is the number, not the object, that reaches its final value.

## …but it can take practically forever

Termination might sound like it makes the whole thing tame. It does not. The last theorem is a warning against complacency.

> **Chains can be arbitrarily long.** For every $N$, there is a strictly descending refinement chain of length $N+1$: proofs of complexities $N, N-1, \dots, 1, 0$, each refining the previous.

So although *every* refinement process halts, there is *no bound whatsoever* on how long it might take to do so. Give me any astronomically large number — $10^{100}$, say — and I can hand you a valid, strictly-improving chain that runs for that many steps before stopping. This is the formal shadow of a real phenomenon: the four-color theorem, or the classification of finite simple groups, may have a breathtakingly simple proof waiting at the end of their refinement processes — but the road there could be longer than anyone will ever walk. *Guaranteed to terminate* and *terminates soon* are very different promises, and only the first one is true in general.

## The tortoise made concrete: $\sqrt{2}$

None of this would be satisfying without an example you can hold in your hand, so consider the oldest chestnut in mathematics: **$\sqrt{2}$ is irrational.**

There are many ways to prove it, and they differ sharply in complexity.

- **Strategy A — full classical contradiction ($C = 7$).** Assume $\sqrt{2} = a/b$ in lowest terms, square to get $a^2 = 2b^2$, deduce $a$ is even, write $a = 2c$, substitute to get $b^2 = 2c^2$, deduce $b$ is even, and derive a contradiction with "lowest terms." Many steps, nested case analysis, several arithmetic lemmas.
- **Strategy B — via a prime-divisibility lemma ($C = 4$).** Invoke the fact that if a prime $p$ divides $n^2$ then $p$ divides $n$. For $p = 2$ this collapses the "$a$ even, $b$ even" bookkeeping into a single reusable principle, shrinking the proof.
- **Strategy C — the packaged theorem ($C = 2$).** Cite the finished, once-and-for-all result that $\sqrt{2}$ is irrational. Two steps: state it, invoke it.

We thus have a concrete refinement chain
$$7 \;\rightsquigarrow\; 4 \;\rightsquigarrow\; 2,$$
where each arrow is a genuine refinement (strictly smaller complexity), and Strategy C is the simplest of the three — the limit of *this* refinement process. It is exactly the abstract theory playing out on a familiar stage: a nonempty family of three proofs, a guaranteed minimal member, a well-defined minimal complexity.

## Why this matters

The picture that emerges is quietly radical. A proof is not a monument; it is a point in a landscape, and refinement is a downhill flow on that landscape. The flow can meander for an unimaginably long time, but it can never cycle, never run forever, and never miss the valley floor. Every theorem has a valley floor — a simplest proof — and the *height* of that floor, the minimal complexity, is a fixed number attached to the theorem for all time.

This reframes some old instincts. Mathematical elegance stops being a purely aesthetic judgment and becomes something with structure: the simplest proof exists, its cost is well-defined, and "finding the elegant proof" is literally a descent to a guaranteed minimum. The difficulty of a theorem splits cleanly into two independent axes — *how low is the floor* (the minimal complexity) and *how far away is it* (the possible length of the refinement chain) — and the theory shows these can be wildly different. A theorem can have a trivial simplest proof that is nonetheless hidden at the end of a mile-long simplification.

There is honesty here too about what is *not* claimed. Bundling length, depth, and lemma-count into one number gives a well-defined *minimal complexity value*, but not a unique simplest proof *object*: many different arguments can tie for the lead. And this down-to-earth minimum is a cousin of Kolmogorov complexity, not the uncomputable original. What survives — and what is genuinely reassuring — is the core promise: **proofs are living things, they can always be improved until they cannot, and the endpoint of that improvement always exists.**
