# Tangled Hierarchies: When a Proof System Tries to Trust Itself

## A promise you cannot keep

Imagine a mathematician of boundless energy and perfect discipline. She never makes a mistake, she never tires, and she is willing to check any argument you hand her, no matter how long. One day you ask her the most natural question in the world:

> "Are you sure you never contradict yourself?"

You would like her to answer *yes* — and, crucially, to **prove** it, using only the very rules she already trusts. This sounds like the safest possible request. After all, if she is reliable, surely she can certify her own reliability.

She cannot. And the reason is not a failure of cleverness or effort. It is a structural law, as unavoidable as the impossibility of a map of a city that fits inside the city and shows every street including itself at full size. Any system powerful enough to talk about its own reasoning is forbidden — on pain of collapse — from proving its own trustworthiness from the inside.

This is the phenomenon of the **tangled hierarchy**: the moment a proof system's certificate of soundness is allowed to live *inside* the system it is supposed to certify, the whole edifice either says nothing new or says everything, including falsehoods. The soundness stamp must always come from outside.

This article tells the story of why, and shows that the whole drama can be captured in a handful of clean, provable statements about a simple geometric picture.

## Provability as a landscape

To make the idea precise, we replace the tireless mathematician with a **landscape of theories**. Picture a vast collection of possible "states of knowledge," which we call **worlds**. From each world $w$ there are arrows pointing to other worlds. Write $R\,w\,v$ when there is an arrow from $w$ to $v$, and read it as:

> "From the standpoint of $w$, the world $v$ is one of the situations that $w$ regards as provably reachable."

This little arrow relation $R$ is the entire engine of the theory. Everything about provability, consistency, and self-reference is going to be expressed in terms of it.

We now introduce a single operator, the **box**, written $\Box$. For any property $A$ of worlds, the property $\Box A$ holds at a world $w$ exactly when *every* world you can reach from $w$ by an arrow satisfies $A$:

$$w \in \Box A \quad\text{means}\quad \text{for all } v,\ R\,w\,v \ \Rightarrow\ v \in A.$$

The reading is deliberate: $\Box A$ means "**$A$ is provable**." A theory proves $A$ if $A$ holds in every situation the theory can see. The mirror image is the **diamond**, $\Diamond A$, meaning "$A$ is *consistent* with the theory": there exists at least one reachable world where $A$ holds.

The single most important property in the whole story is **consistency itself**. A theory is consistent precisely when it does not prove absurdity — equivalently, when it has *somewhere to go*. We define

$$\mathrm{Con} \;=\; \{\,w \mid \text{there exists } v \text{ with } R\,w\,v\,\}.$$

A world is consistent exactly when it has at least one outgoing arrow. A world with no arrows at all is a dead end: vacuously, *every* property holds "at all reachable worlds" (there are none), so such a world proves everything — it is the picture of an inconsistent theory, one from which any falsehood follows.

## The two rules of a well-behaved landscape

Not every arrow-diagram deserves to be called a proof system. Genuine provability obeys two structural laws, and these two laws are the whole secret.

**Rule 1: Transitivity.** If $w$ can reach $v$, and $v$ can reach $u$, then $w$ can reach $u$ directly. In logical terms this is the principle that "if something is provable, then it is provable that it is provable" — the system has insight into its own reasoning.

**Rule 2: No infinite ascent.** There is no endless chain of worlds $w_1, w_2, w_3, \dots$ each reachable from the one before, climbing forever. Formally, the arrow relation is **converse well-founded**: every nonempty collection of worlds contains a world that is, in the relevant sense, maximal. Intuitively, proofs bottom out; you cannot postpone justification forever.

A landscape satisfying both rules is what we will call a **Gödel–Löb frame**, after the two logicians whose theorems it encodes. These two innocuous-looking conditions turn out to be *exactly* the ones that make self-reference collapse in a controlled, predictable way.

And such frames genuinely exist, with infinitely many worlds. The cleanest example is the natural numbers $0, 1, 2, 3, \dots$ with the arrow rule "$w$ can reach $v$ when $v < w$." From $5$ you can reach $4, 3, 2, 1, 0$. This relation is transitive (if $c<b$ and $b<a$ then $c<a$) and it never ascends forever (you cannot keep going to strictly smaller natural numbers indefinitely — you hit $0$). Here $0$ is the unique dead end: it has no smaller number to point to, so $0$ is inconsistent, while every positive number is consistent.

## Löb's astonishing shortcut

Now comes the pivotal theorem, and it is genuinely surprising the first time you meet it.

Consider a world that proves a certain modest-sounding statement: *"if $A$ is provable, then $A$ is actually true."* This is a statement of **self-trust restricted to $A$** — the system is willing to certify that its own proofs of $A$ are reliable. In symbols, the world satisfies $\Box(\Box A \to A)$.

You might expect this self-trust to be nearly free — a harmless expression of confidence. Löb's theorem says something far stronger:

> **The Semantic Löb Theorem.** In any Gödel–Löb frame, $\Box(\Box A \to A) \subseteq \Box A$. That is, if a world proves "provability of $A$ entails $A$," then that world *already proves $A$ outright.*

In words: **the only statements a system can safely trust itself about are the ones it can already prove unconditionally.** Self-trust buys you nothing you did not already have. The conditional confidence "if I could prove $A$, then $A$ would hold" silently upgrades itself into the flat assertion "$A$."

Why is this true? Here is the heart of the argument, and it uses Rule 2 in an essential way. Suppose, for contradiction, that some reachable world fails to satisfy $A$. Among all the reachable worlds where $A$ fails, the no-infinite-ascent rule guarantees we can pick a **maximal** offender $u$: a world where $A$ fails, but from which *every* further reachable world *does* satisfy $A$. By transitivity, everything $u$ can reach is also reachable from the start, so all of those worlds satisfy $A$ — which means $u$ satisfies $\Box A$. But our starting hypothesis was that "$\Box A \to A$" holds everywhere reachable, and in particular at $u$. So $u$ satisfies $\Box A \to A$, and since it satisfies $\Box A$, it must satisfy $A$. That contradicts $u$ being an offender. No offenders can exist; $A$ holds everywhere reachable; the world proves $A$. The maximal-offender trick is precisely where converse well-foundedness earns its keep.

## Consistency is the forbidden fixed point

Here is where the pieces snap together with a click.

Recall that a world is consistent exactly when it has a successor — when it is *not* a dead end. Now look closely at the statement "if $\bot$ (absurdity) is provable, then $\bot$ is true," where $\bot$ stands for the empty property that no world satisfies. Unwinding the definitions, this self-trust statement about $\bot$ turns out to be **literally identical** to the assertion "this world is consistent." Trusting yourself not to prove falsehood *is the same thing* as being consistent. In our landscape this is an exact equation:

$$\{\,w \mid w \in \Box\bot \to w \in \bot\,\} \;=\; \mathrm{Con}.$$

Feed this identity into Löb's theorem, taking $A = \bot$. Löb says $\Box(\Box\bot \to \bot) \subseteq \Box\bot$. Rewriting the left side using the identity above, we get the semantic form of one of the most famous results in all of mathematics:

> **Gödel's Second Incompleteness Theorem.** In any Gödel–Löb frame, $\Box\,\mathrm{Con} \subseteq \Box\bot$. A world that **proves its own consistency proves absurdity** — and therefore proves everything.

The stamp "I am consistent" is toxic. Any system that manages to prove it, from the inside, has thereby proven falsehood and collapsed into the trivial system that asserts all statements indiscriminately.

## The tangled hierarchy theorem

From here, the punchline is immediate and sharp:

> **The Tangled Hierarchy Theorem.** No *consistent* world can prove its own consistency. If a world has any successor at all — that is, if it is genuinely consistent — then it does **not** satisfy $\Box\,\mathrm{Con}$.

The proof is a single clean step. Suppose a consistent world $w$ nevertheless proved its own consistency, $w \in \Box\,\mathrm{Con}$. By Gödel's Second Theorem this forces $w \in \Box\bot$: every world reachable from $w$ satisfies the impossible empty property. But $w$ is consistent, so it *has* a reachable world $v$ — and that $v$ would have to satisfy the impossible property. Contradiction. So no consistent world can carry its own consistency stamp.

This is the tangled hierarchy made precise. The soundness predicate — the certificate that says "this system is trustworthy" — cannot be an internal citizen of the system. The instant you let it inside, one of two things happens: either the system is inconsistent (and its "proof" of consistency is worthless, a lie told by a system that proves everything), or the system is consistent (and then it simply cannot produce the proof at all). There is no third option in which a healthy system vouches for itself.

There is a consoling flip side, which the same framework delivers for free:

> **Soundness Forces Consistency.** If a world is even *locally* self-sound about absurdity — if at that world "$\Box\bot \to \bot$" holds — then the world is automatically consistent; it has a successor.

So reflection and consistency travel together: a world that refuses to be fooled by a proof of falsehood is thereby guaranteed to be a live, consistent theory. What it cannot do is turn that guarantee into an internal theorem about itself.

## The diagonal at the bottom of it all

Why does self-reference behave this way? Beneath Gödel, Löb, and the tangled hierarchy lies a single, breathtakingly general mechanism — the same one behind Cantor's proof that there are more real numbers than whole numbers, and behind the classic liar paradox. It is **Lawvere's fixed-point theorem**, and it can be stated in one sentence.

> **Lawvere's Fixed-Point Theorem.** Suppose a system is rich enough to *encode all of its own predicates*: there is a map $f$ that, from a single object $a$, produces a predicate $f(a)$, and every predicate whatsoever arises as $f(a)$ for some $a$ (the encoding is *surjective*). Then **every** transformation $g$ of truth-values has a fixed point — some value $b$ with $g(b) = b$.

The proof is the diagonal argument in its purest form. Because the encoding is surjective, the specific "diagonal" predicate $a \mapsto g(f(a)(a))$ must itself be $f(c)$ for some code $c$. Evaluate at $c$: you find $f(c)(c) = g(f(c)(c))$, so the value $b = f(c)(c)$ is fixed by $g$. One line, and it powers a century of self-reference.

Now turn it around. Truth-values come with a transformation that has **no** fixed point: **negation**, which swaps *true* and *false* and never leaves anything unchanged. If a system could encode all of its own true/false predicates by a surjective map, Lawvere's theorem would hand us a fixed point of negation — an impossibility. Therefore:

> **Tarski's Undefinability of Truth (Cantor's Theorem).** No system can carry a surjective self-encoding onto its own true/false predicates. Truth is not definable inside the system; the collection of predicates is strictly richer than the objects that name them.

This is the same wall, seen from a different angle. Whether you call it Cantor (there is no surjection from a set onto its power set), Tarski (no language can define its own truth predicate), Gödel (no consistent system proves its own consistency), or the tangled hierarchy (soundness cannot be internal), you are looking at one theorem wearing four costumes. The negation map has no fixed point, and everything else follows.

## Why this matters beyond logic

The tangled hierarchy is not a curiosity confined to the foundations of mathematics. It is a design law for anything that reasons about itself.

Consider a **verification tool** meant to certify that programs are bug-free. Can it certify *itself*? Only from a stronger vantage point — a "meta" system that is not part of what it checks. Stack these vantage points and you get an unavoidable tower of ever-stronger certifiers, none of which can validate the level it occupies. That tower is the tangled hierarchy in engineering dress; it explains why bootstrapping "total self-trust" into a single system is impossible, and why real-world trust is always anchored in something external — a simpler kernel, a human auditor, a physical measurement.

Consider **artificial agents** that model their own reliability. An agent that could internally prove "everything I conclude is correct" would, by the same theorem, be an agent that concludes *everything* — the very opposite of reliable. Genuine reliability shows up not as an internal certificate but as an external record, and as the humility of leaving one's own soundness unproven from within.

And consider the ordinary human situation with which we began. The demand "prove, using only your own reasoning, that your reasoning never fails" is not merely hard; it is incoherent for any reasoner strong enough to pose it. The healthiest systems — mathematical, mechanical, or human — are precisely the ones that cannot vouch for themselves, and know it. Their consistency is real. It simply has to be certified from somewhere else.

That is the strange gift hidden in these tangled hierarchies: the inability to prove your own soundness is not a bug in a reasoning system. It is a certificate, visible only from outside, that the system is alive.
