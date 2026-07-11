# Proving Things About Proving Things

## A sentence that talks about itself

Some sentences are dangerous because they talk about themselves. "This sentence is false" ties logic in knots. But there is a cousin of that sentence that is not paradoxical at all — it is merely *deep*. It says:

> "This statement is provable, but it is not provable that it is provable."

At first hearing this sounds like a riddle, or a trick. Provable but not provably provable? If something can be proved, surely you can also prove that it can be proved — just point at the proof! And yet, once we make the words precise, this innocent-looking sentence turns out to sit exactly on the fault line that runs through the foundations of mathematics. Whether it can be true depends on one subtle property of the notion of "provable": whether provability is *provably transitive*. Where it can be true, mathematics is, in a precise sense, blind to some of its own powers. Where it cannot be true, we recover the great limitative theorems of the twentieth century — Gödel's incompleteness and Löb's theorem — as clean, inevitable consequences.

This article is about how to make that sentence precise, when it can hold, and why the answer illuminates the limits of formal reasoning.

## The provability operator

The key move is to introduce a single new symbol, the box $\Box$, and read $\Box A$ as **"$A$ is provable."** With it we can build a small language of propositions. We start from basic atoms $A_0, A_1, A_2, \dots$ (think of them as unspecified statements), a symbol $\bot$ for a contradiction ("false"), the implication arrow $\to$, and the box $\Box$. From implication and $\bot$ we recover everything else in classical logic: negation is $\neg A := (A \to \bot)$, and conjunction is $A \wedge B := \neg(A \to \neg B)$. The dual of the box is the *diamond*, $\Diamond A := \neg \Box \neg A$, read "$A$ is consistent" — it is *not* provable that $A$ is false.

Now the self-referential sentence at the heart of this article can be written down as a perfectly ordinary, well-formed expression. Call it the **Gödelian reflection** of $A$:

$$ G(A) \;:=\; \Box A \,\wedge\, \neg\,\Box\Box A. $$

In words: $A$ is provable, but it is not provable that $A$ is provable. Nothing about this expression is ill-formed or paradoxical. The question is not whether we can *write* it — we just did — but whether it can ever be *true*.

## A world of worlds

To ask whether $G(A)$ can be true, we need a notion of truth for statements containing $\Box$. The standard tool is a **possible-worlds model**. Picture a collection of worlds $W$. Between worlds there is an *accessibility relation*: we write $w \mathrel{R} v$ to mean "world $v$ is reachable from world $w$." Finally, each atom is declared true or false at each world.

Truth of a formula at a world is defined by walking through its structure:

- An atom is true at $w$ exactly when the model declares it so.
- $\bot$ is never true.
- $A \to B$ is true at $w$ if, whenever $A$ is true at $w$, so is $B$.
- **$\Box A$ is true at $w$ exactly when $A$ is true at every world $v$ reachable from $w$.**

That last clause is the whole game. To say "$A$ is provable at $w$" is to say "$A$ holds in every world you can get to from $w$." The accessible worlds represent the situations your reasoning cannot rule out; something is provable precisely when it survives all of them.

With this reading, $\Box\Box A$ is true at $w$ when, at every world $v$ reachable from $w$, and every world $u$ reachable from *that* $v$, $A$ holds. So $\Box\Box A$ reaches *two steps out*, while $\Box A$ reaches only one. The gap between one step and two steps is exactly where our sentence lives.

## Building a world where the impossible happens

Here is the surprise: $G(A) = \Box A \wedge \neg\Box\Box A$ **can** be true. To see it, we build the smallest possible model that does the job — three worlds in a chain.

Call the worlds $a$, $b$, $c$. The accessibility relation is a simple two-link chain:
$$ a \longrightarrow b \longrightarrow c, $$
that is, $a \mathrel{R} b$ and $b \mathrel{R} c$, and nothing else. We make the atom $A$ true at exactly one world: $b$.

Now evaluate our sentence at the starting world $a$.

- **Is $\Box A$ true at $a$?** We must check every world reachable from $a$ in one step. There is only one: $b$. And $A$ is true at $b$. So yes — from $a$'s vantage point, $A$ is provable.
- **Is $\Box\Box A$ true at $a$?** This asks whether $\Box A$ holds at every world reachable from $a$ — in particular at $b$. But $\Box A$ at $b$ would require $A$ to hold at every world reachable from $b$, and $b$ reaches $c$, where $A$ is *false*. So $\Box A$ fails at $b$, and therefore $\Box\Box A$ fails at $a$.

Putting the two together: at world $a$, $A$ is provable but not provably provable. The sentence $G(A)$ holds. In the language of models, **$\Box A \wedge \neg\Box\Box A$ is satisfiable.** The riddle has an answer: yes, such a state of affairs is genuinely possible.

Why doesn't this contradict the intuition that "if you can prove it, you can prove that you can prove it"? Because that intuition secretly assumes something about the relation $R$: that it is *transitive*. Transitivity says whenever $w \to v$ and $v \to u$, then also $w \to u$ — reachability composes. Our chain deliberately violates this: $a$ reaches $b$ and $b$ reaches $c$, but $a$ does **not** reach $c$. The world $c$ is invisible to $a$ directly; it can only be seen *through* $b$. That one missing link is what lets provability and provable-provability come apart.

## The hinge: transitivity

The three-world chain is not a cheat; it is a diagnosis. It tells us that everything depends on a single structural property. Suppose the accessibility relation *is* transitive. Then the following principle, known classically as **axiom 4**, is guaranteed to hold at every world:

$$ \Box A \;\to\; \Box\Box A. $$

The proof is a single line of reasoning. Suppose $\Box A$ holds at $w$; we want $\Box\Box A$. Take any $v$ with $w \to v$, and any $u$ with $v \to u$. By transitivity $w \to u$, so from $\Box A$ at $w$ we get $A$ at $u$. Since $u$ was arbitrary, $\Box A$ holds at $v$; since $v$ was arbitrary, $\Box\Box A$ holds at $w$. Done.

Axiom 4 is the formal shape of a property logicians call **$\Sigma_1$-completeness**: for the actual provability predicate of a reasonable theory of arithmetic, whatever is provable is *provably* provable, because a proof is a finite object whose existence the theory can verify. Transitivity of the worlds is precisely the semantic mirror of this fact.

And once axiom 4 holds, our sentence is dead on arrival. If $\Box A$ implies $\Box\Box A$, then $\Box A \wedge \neg\Box\Box A$ demands both $\Box\Box A$ (via the implication) and $\neg\Box\Box A$ (the second conjunct) — a flat contradiction. So **on every transitive model, $\Box A \wedge \neg\Box\Box A$ is unsatisfiable.** "Provable but not provably provable" is impossible exactly when provability is provably transitive.

This is the clean dichotomy the whole subject turns on:

- **Non-transitive provability** (the chain $a \to b \to c$): the Gödelian reflection can be true. A system can be genuinely uncertain about the reach of its own proofs.
- **Transitive provability** (real arithmetic): the Gödelian reflection is impossible. The system's confidence in its proofs propagates without limit.

## From structure to the great theorems

The reward for building this machinery is that the twentieth century's most famous limitative results fall out of it almost for free — they are simply what happens on the *right kind* of transitive frames.

The provability logic **GL** (for Gödel and Löb) is obtained by insisting that the accessibility relation be transitive **and converse-well-founded** — meaning there are no infinite forward chains $w_0 \to w_1 \to w_2 \to \cdots$. Converse-well-foundedness captures the idea that proofs terminate: you cannot keep passing to a strictly "further out" world forever.

On these frames one can validate **Löb's theorem**, one of the strangest and most beautiful facts in logic:

$$ \Box(\Box A \to A) \;\to\; \Box A. $$

Read it slowly. It says: if it is provable that "*being provable is enough to make $A$ true*," then $A$ is already provable outright. The mere provable promise that a proof would suffice is itself as good as a proof. This captures, in one line, the self-referential punch of Gödel's arguments.

And now the crown jewel. Take the special case $A := \bot$. Since $\Box\bot$ says "a contradiction is provable" — i.e. "the system is inconsistent" — its negation $\neg\Box\bot$ says "the system is consistent." Löb's schema, specialized and rearranged on GL frames, yields:

$$ \Box(\neg\Box\bot) \;\to\; \Box\bot. $$

In words: **if a system can prove its own consistency, then it is in fact inconsistent.** Contrapositively, a consistent system can never prove its own consistency. This is **Gödel's second incompleteness theorem**, emerging as a one-line corollary of the possible-worlds analysis of the box.

## Why it matters

There is something bracing about watching Gödel's second theorem — usually presented as a labyrinth of arithmetization, coding, and diagonal lemmas — reappear as a short remark about chains of worlds. The self-referential sentence "provable but not provably provable" is the thread that ties it all together. Its satisfiability in a non-transitive world shows that reflection *can* fail; its unsatisfiability in transitive worlds shows exactly *why* real mathematics is different; and pushing on into the well-founded frames of GL turns the same ideas into the incompleteness phenomena themselves.

The practical resonance is growing, too. Modern systems increasingly reason about their own reasoning: programs that check other programs, verifiers that certify their own outputs, learning systems asked to estimate their own reliability. Every such system faces a version of our question. When it says "I can establish this," can it also establish that it can establish it — and should it trust that meta-claim? The box calculus gives a precise vocabulary for these questions, and a precise warning: the moment a system's confidence in its proofs becomes *provable* to itself, it inherits Gödel's boundary. It can be right about everything it proves, and it still cannot certify, from the inside, that it will never contradict itself.

"This is provable but not provably provable" is not a paradox. It is a compass. Follow where it can point and where it cannot, and you trace the exact edge of what a formal system can know about its own knowing.
