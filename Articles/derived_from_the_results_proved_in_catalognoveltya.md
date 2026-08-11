# The Two Rulers: How Deep Can a Theory Trust Itself?

## A machine that measures its own doubt

Imagine a mathematical theory as a person who has been handed a very peculiar
sentence about themselves: *"I am consistent."* Gödel's second incompleteness theorem
says that a sufficiently strong, consistent theory cannot prove that sentence. But the
story does not end there — it *begins* there. Once you accept that a theory can talk
about its own provability, you can start asking quantitative questions. Not just
"is it consistent?" but *how much* consistency does it prove, and *how far* does its
self-trust extend before it breaks?

This article is about two such measurements, and about the surprising discovery that
they are almost completely independent of one another. Along the way we will see
exactly which theories in a natural infinite family can be *weakened* into which
others — and the answer turns out to be far more rigid, and far prettier, than anyone
expected.

## The language of self-reference

We work with a small formal language. Its sentences are built from:

* the absurdity $\bot$ (a statement that is always false),
* atoms $p_0, p_1, \dots$ (unanalyzed statements),
* implication $a \to b$,
* and a family of **provability operators** $\Box_i$, one for each *tag* $i = 0, 1, 2, \dots$

Read $\Box_i a$ as "*system number $i$ proves $a$*". The tags are there because we want
to compare several formal systems at once — arithmetic, set theory, a physical theory,
a fragment of one of these — each with its own notion of proof.

The single most important sentence in this language is
$$\Box_i \bot,$$
which says "*system $i$ proves a contradiction*", i.e. "*system $i$ is inconsistent*".
Its negation $\neg \Box_i \bot$ is the consistency statement $\mathrm{Con}_i$.
And you can iterate:
$$\Box_i^k \bot \;=\; \underbrace{\Box_i \Box_i \cdots \Box_i}_{k}\, \bot,$$
which says "*system $i$ proves that it proves that it proves … a contradiction*", $k$
levels deep. These iterated sentences form a ruler. Slide up it until you find the
first level a theory can prove, and you have measured something real about the theory.

The rules governing $\Box$ are those of the logic of provability, known as **GL**: the
theory is closed under modus ponens; it proves everything it can prove is provable
(necessitation, "$\vdash a$ implies $\vdash \Box_i a$"); provability distributes over
implication; provability is transitive ($\Box_i a \to \Box_i \Box_i a$); and — the deep
one, Löb's axiom —
$$\Box_i(\Box_i a \to a) \;\to\; \Box_i a .$$
Löb's axiom is the formal shadow of Gödel's theorem: a theory can only prove
"if I prove $a$ then $a$" in the cases where it can simply prove $a$ outright. Self-trust
is not free.

## Ruler one: the inconsistency height

Some perfectly consistent theories are nevertheless *wrong about* their own
consistency. A theory might not prove $\bot$, yet prove $\Box_i \bot$ — "I am
inconsistent" — and be entirely coherent in doing so. Such theories are exactly the
inhabitants of the interesting part of provability logic.

Define the **inconsistency height** of a theory at tag $i$ to be the number $n$ such
that
$$\vdash \Box_i^k \bot \quad \text{exactly for } k > n .$$
A height of $0$ means the theory already proves "$i$ is inconsistent". A height of $n$
means it takes $n+1$ nested boxes before the theory will commit. Height $\infty$ is the
honest case: the theory never claims $i$ is inconsistent at any depth.

There is a beautifully concrete way to build theories of each finite height. Picture a
ladder of *worlds* $0, 1, 2, \dots, N$, where world $m$ can "see" all the worlds below
it. A sentence is a *theorem* of the ladder theory when it is true at every world of the
ladder. On this ladder, $\Box_i^k \bot$ turns out to be true exactly at the worlds
$m < k$: it is a plumb line measuring the distance down to the ground. So the ladder of
height $N$ proves $\Box_i^k\bot$ precisely when $k > N$.

Now make it *tag-sensitive*. Give each tag $i$ its own **height** $c(i)$, and decree
that at world $m$, the operator $\Box_i$ can see downwards only if $m \le c(i)$; above
that level, tag $i$ is **dead** and $\Box_i$ becomes vacuously true ("a dead system
proves everything"). The resulting theory — call it $\mathcal{L}(c,N)$, the ladder
theory of the height function $c$ truncated at $N$ — proves
$$\Box_i^k \bot \quad\text{exactly when}\quad k \ge 1 \text{ and } \min(N, c(i)) < k .$$
So the theory only ever sees the **truncated height**
$$d_c(i) \;=\; \min\bigl(N, c(i)\bigr),$$
which we call the **depth vector**. Two height functions with the same depth vector
generate literally the same theory; two with different depth vectors do not. The depth
vector is a *complete invariant*.

## The failed guess

Here is the natural question. The theories $\mathcal{L}(c,N)$ come in a huge family,
one for each depth vector. Some of them are weaker than others: everything provable in
one is provable in the other. Which is weaker than which?

The obvious guess — and it was the standing conjecture — is: *make the depths bigger,
without disturbing their relative order*. Formally, $\mathcal{L}(c,N)$ should be weaker
than $\mathcal{L}(c',N)$ exactly when

1. $d_c(i) \le d_{c'}(i)$ for every tag $i$, and
2. whenever $d_{c'}(i) \le d_{c'}(j)$, also $d_c(i) \le d_c(j)$.

It is a reasonable guess. Condition 1 is certainly necessary, because the iterated
boxed falsa read the depths off the theory directly. Condition 2 is also necessary, as
it happens. And yet the guess is **false**.

The counterexample is tiny. Take $N = 2$, and two depth vectors
$$d_c = (0, 1, 1, 1, \dots), \qquad d_{c'} = (1, 2, 2, 2, \dots).$$
Both conditions hold: every depth goes up by exactly one, and the ordering of the tags
is untouched — tag $0$ is the shallowest in both. But the sentence
$$\Box_0 \bot \;\to\; \bigl(\neg \Box_1 \bot \to \neg \Box_1 \Box_1 \bot\bigr)$$
is a theorem of the upper theory and is *refuted* by the lower one.

What does that sentence say? Read it as: *if system $0$ is (provably) dead, then system
$1$ does not have depth exactly $1$.* In the upper model, tag $0$ survives to level $1$,
so wherever "$0$ is dead" holds, we are already above everything; the sentence cannot be
falsified. In the lower model, world $1$ is exactly a place where tag $0$ has already
died while tag $1$ is alive with depth precisely $1$ — a **witness world** that the
sentence rules out. Raising tag $0$'s depth from $0$ to $1$ *destroys* that world, and
nothing in the new model replaces it.

So the failure is not about the sizes of the depths, nor about their order. It is about
which *combinations of aliveness and death* survive as actual worlds.

## The right answer: depths may only rise at the top

The correct criterion is a single, sharp condition, and it took the counterexample to
see it. Say that $c'$ **depth-dominates** $c$ (at height $N$) when

1. $d_c(i) \le d_{c'}(i)$ for every tag $i$ — depths may only increase, and
2. if $d_c(i) < d_{c'}(i)$ for some tag $i$, then $d_c(j) \le d_c(i)$ for *every* tag $j$
   — a depth may increase strictly **only at a tag that was already of maximal depth**.

**Theorem (Depth Domination Criterion).** *Every theorem of $\mathcal{L}(c',N)$ is a
theorem of $\mathcal{L}(c,N)$ if and only if $c'$ depth-dominates $c$.*

Look what this forbids. In the failed counterexample, tag $0$ had depth $0$ while other
tags had depth $1$: it was *not* of maximal depth, and yet its depth was raised. The new
criterion rejects the pair immediately.

The criterion has an equivalent formulation that explains the whole picture in one
phrase. **A theory can only be weakened by truncation.**

**Theorem (Truncation).** *$\mathcal{L}(c,N)$ is weaker than $\mathcal{L}(c',N)$ if and
only if there is a single number $D \le N$ with*
$$d_c(i) \;=\; \min\bigl(D,\, d_{c'}(i)\bigr) \quad \text{for every tag } i.$$

In other words: you cannot rearrange the depth profile of a theory to get a weaker
theory. You can only take a pair of scissors, choose one cut level $D$, and lop off
everything above it — uniformly, across all tags at once.

Two consequences follow instantly and are worth stating on their own.

**Theorem (Chain).** *The theories weaker than a fixed $\mathcal{L}(c',N)$ are linearly
ordered by inclusion.* Any two of them are comparable — the "downward cone" of a theory
in this family is not a complicated partial order at all, but a chain, indexed by the
cut level $D$.

**Theorem (Pigeonhole).** *A theory has at most $N+1$ weakenings inside the family.*
Among any $N+2$ height functions all of whose theories sit below a fixed one, two of
them generate exactly the same theory. There are only $N+1$ places to cut.

And how badly wrong was the old conjecture? Exactly one height too optimistic:

**Theorem (Exact threshold).** *The conjectured criterion implies inclusion for all
height functions if and only if $N \le 1$.* For ladders of height $0$ or $1$ the guess
is a theorem; from height $2$ upward it is strictly weaker than the truth, and the
counterexample above lives at exactly that first failing height.

## Ruler two: the reflection depth

Now for the second measurement, and the second surprise.

A theory *reflects* when it can pass from "I prove $a$" to $a$ itself: from
$\vdash \Box_i a$ to $\vdash a$. Full reflection is too much to ask, but we can ask for
it *up to a certain complexity*. Define the **reflection depth** of a theory at tag $i$
as the largest $d$ such that
$$\vdash \Box_i a \;\Longrightarrow\; \vdash a \qquad \text{for every } a \text{ with fewer than } d \text{ nested boxes}.$$
Depth $0$ is vacuous. Depth $1$ says the theory is right about the box-free facts it
claims to prove. Higher depths say it is right about ever more self-referential ones.

There is one obvious constraint linking the two rulers, and it holds for *any* proof
system whatsoever, with no semantics involved:

**Theorem (Height bounds depth).** *If a theory proves $\Box_i^{n+1}\bot$ but not
$\Box_i^{n}\bot$, it fails the depth-$(n+1)$ reflection rule.* The reason is a
one-liner: the sentence $\Box_i^n \bot$ has exactly $n$ nested boxes, and
$\Box_i(\Box_i^n\bot)$ *is* $\Box_i^{n+1}\bot$. So the theory proves the boxed version
and refutes the unboxed one — reflection fails on the nose. Hence
$$\text{reflection depth} \;\le\; \text{inconsistency height}.$$

In the simplest ladder theories the two rulers give the *same number*, and it is tempting
to conclude that they measure the same thing. They do not. That coincidence is an
artefact of a modelling choice: in the plain ladder, every atom is true at every world,
so the only sentences with any content are the ones built from $\bot$ — and the only
ruler available is the boxed-falsum ruler.

Give the atoms a real valuation and the two invariants come apart completely. Fix a
height $n$ and a **shift point** $w \le n$, and let every atom be true at the worlds
$0, 1, \dots, w-1$ and false from $w$ upward. Call the resulting theory
$\mathcal{B}(n,w)$: the **block theory**. It is consistent, and it satisfies every
axiom and rule of GL, Löb included.

The engine is a *locality* principle: a sentence with at most $k$ nested boxes can look
down at most $k$ rungs, so it cannot tell apart two worlds that both sit at height at
least $w + k$ — up there, the valuation is constant and everything looks the same. The
sharpest witnesses are the **depth probes**
$$\Box_i^k\, p_0,$$
shifted copies of the iterated boxed falsum: the probe of depth $k$ is true exactly at
the worlds $m < w + k$, and is a theorem exactly when $n < w + k$.

Putting these together gives the exact computation:

**Theorem (Reflection depth of the block theories).** *For $w \le n$, the reflection
depth of $\mathcal{B}(n,w)$ is exactly $n - w$*, while its provable iterated boxed
falsa are those $\Box_i^k \bot$ with $k > n$ — *independently of $w$*.

Two corollaries land immediately.

**Theorem (Exact realizability).** *There is a consistent theory of the logic of
provability with inconsistency height $n$ and reflection depth exactly $d$ if and only
if $d \le n$.* The one inequality forced by the syntactic argument above is the *only*
constraint. The simplest ladder theories occupy just the diagonal $d = n$ of a full
triangle of possibilities.

**Theorem (Independence).** *The reflection depth is not a function of the inconsistency
spectrum.* For every $n \ge 1$, the two block theories $\mathcal{B}(n,0)$ and
$\mathcal{B}(n,n)$ prove *exactly the same* iterated boxed falsa, yet the first obeys
depth-$n$ reflection and the second fails already at depth $1$. No amount of staring at
which sentences $\Box_i^k \bot$ a theory proves will tell you how far its self-trust
reaches.

And how low does the chain of reflection rules start? Right at the bottom, and not
lower:

**Theorem (Optimal separation).** *Depth-$1$ reflection is strictly stronger than
minimal soundness.* Minimal soundness — the theory does not prove $\Box_i \bot$ — is a
consequence of the depth-$1$ rule for consistent theories, but not conversely: the
two-world block theory $\mathcal{B}(1,1)$, whose atoms are true at the root only, is
consistent, is a theory of the logic of provability, and is minimally sound, yet it
proves $\Box_i p_0$ while refuting $p_0$. Since the depth-$0$ rule is vacuous, this is
the best possible separation. Notably, it *cannot* be witnessed in the atom-trivial
ladders, where box-free sentences have the same truth value everywhere.

## Rigid and floppy

The two families we have met behave in exactly opposite ways, and the contrast is the
punchline.

The tag-sensitive ladders $\mathcal{L}(c,N)$ are **floppy**: an infinite-dimensional
space of height functions collapses onto finitely many depth vectors, whose ordering is
the rigid one-parameter truncation order — a chain of length at most $N+1$ below each
theory.

The block theories $\mathcal{B}(n,w)$ are **rigid**: from the theory alone you can read
back both parameters. One block theory contains another exactly when it is no taller and
their valuations agree at every world of the smaller model; two are equal exactly when
they have the same height and the same block below it. Within a fixed height $n$ the
shift point is recoverable, so the $n+1$ block theories of height $n$ are pairwise
distinct, and they are classified precisely by their reflection depth $n-w$.

## Why it matters

Arithmetized consistency statements are how one theory certifies another: "if physics is
consistent then arithmetic is", "if this fragment is sound then that one is". The
results above say something quite concrete about the bookkeeping of such certificates.

First, **strength profiles cannot be reshuffled**. If you want a weaker system than the
one you have, in this family, your only option is a uniform truncation — you cannot
selectively deepen the self-knowledge of one component while keeping the rest intact and
still expect the result to be weaker. Local surgery on a strength profile is a global
operation.

Second, **two natural notions of "how much a theory trusts itself" are genuinely
different quantities**. The depth at which a theory starts declaring itself inconsistent,
and the complexity up to which its provability claims are actually correct, satisfy one
inequality and nothing more. Every legal pair occurs. Anyone measuring one and inferring
the other is making an unjustified leap — one that the simplest examples, where the two
coincide, make dangerously tempting.

And third, there is a moral about conjectures. The failed guess about the inclusion
order was correct in all the cases small enough to check by hand — heights $0$ and $1$ —
and wrong at the very next one. It failed not because it was crude but because it was
formulated in the wrong currency: it spoke about the *sizes and order* of the depths,
while the truth is about which *worlds survive*. The right criterion, once seen, is
shorter than the wrong one.

Two rulers, one ladder, and a pair of scissors that can only cut straight across.
