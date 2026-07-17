# Dark Mathematics: When Existence Outruns Identification

Mathematics often treats existence as the beginning of a search. Prove that a solution exists, and the natural next question is: which one? For a polynomial, we seek a root. For a graph-coloring problem, we ask for a coloring. For a theorem asserting that some natural number has a property, we expect at least one numeral eventually to emerge.

But existence and identification are not the same logical achievement. A deductive system may certify the sentence “there is an object with property $P$” while failing to certify $P$ for every object on a fixed list of names. Such a sentence casts a mathematical shadow: the system sees that something is there, yet none of the named candidates becomes visible.

This is the central idea of **dark existence**. It is striking, but it must be handled with care. Once the idea is stated precisely, a tempting hierarchy based on the number of hidden witnesses collapses for a simple reason: one invisible witness can be dressed in arbitrarily many irrelevant finite tags. The tags create distinct objects without creating new mathematical information.

That observation changes the research question. Instead of asking how many dark witnesses there are, we should ask what remains after inessential recodings have been removed.

## What “dark” means

Fix three ingredients. First, let $\text{Prov}(A)$ mean that a chosen deductive system proves the proposition $A$. No special assumptions about the system are built into the notation. Second, let $\nu(0),\nu(1),\nu(2),\ldots$ be the objects selected by a naming scheme. Third, let $P(x)$ be a property of those objects.

The property $P$ is **dark relative to $\text{Prov}$ and $\nu$** when both of the following hold:

1. the system proves
$$
\exists x\,P(x),
$$
2. for every natural number $n$, the system does not prove
$$
P(\nu(n)).
$$

The word “relative” matters. Darkness depends on the proof system, the language, and the naming scheme. It is not merely a synonym for “hard to compute” or “not yet known.” It is a precise mismatch between provable existential information and provable named instances.

To count witnesses, say that $P$ has **at least $r$ witnesses** if there is a finite set $S$ of cardinality $r$ such that every $x\in S$ satisfies $P(x)$. A property is **dark at level $r$** when the system proves that $P$ has at least $r$ distinct witnesses but proves no named instance $P(\nu(n))$.

At first sight, this suggests a ladder. Perhaps level $2$ darkness is deeper than level $1$, and level $3$ deeper still. The main result shows why that conclusion does not follow from witness count alone.

## The tag machine

Suppose $P$ is dark on a type of objects $X$. Choose a positive integer $r$. Replace each object $x\in X$ by a tagged object
$$
(i,x),\qquad i\in\{0,1,\ldots,r-1\}.
$$
Define a new property $Q_r$ by ignoring the tag:
$$
Q_r(i,x)\quad\text{means exactly}\quad P(x).
$$

If $x$ is a witness to $P$, then
$$
(0,x),(1,x),\ldots,(r-1,x)
$$
are $r$ distinct witnesses to $Q_r$. Their distinction lies entirely in the tags. The underlying payload is unchanged.

The naming scheme must also be extended. Every natural-number code $c$ can be divided by $r$ with quotient and remainder:
$$
c=r\left\lfloor\frac{c}{r}\right\rfloor+(c\bmod r).
$$
Use the remainder as a tag and the quotient as the old name index:
$$
\nu_r(c)=\left(c\bmod r,\nu\!\left(\left\lfloor\frac{c}{r}\right\rfloor\right)\right).
$$
This interleaves all tags over all old names. Indeed, the pair $(i,\nu(n))$ is named by the code $rn+i$.

Now assume the deductive system supports the elementary transformation that turns a proof of $\exists x\,P(x)$ into a proof that $Q_r$ has at least $r$ tagged witnesses. Ordinary syntactic calculi are expected to support such finite bookkeeping, but the assumption is stated openly because the argument is meant to apply abstractly.

The central theorem is then immediate but consequential.

**Finite-Tag Amplification Theorem.** If $P$ is dark and the proof system supports finite tagging, then for every positive integer $r$, the tag-extended property $Q_r(i,x)\equiv P(x)$ is dark at level $r$ under the interleaved naming scheme $\nu_r$.

Why does named-instance darkness survive? If the system proved $Q_r(\nu_r(c))$, it would prove
$$
P\!\left(\nu\!\left(\left\lfloor\frac{c}{r}\right\rfloor\right)\right),
$$
contradicting the original darkness condition. The tag contributes no logical content that could reveal the payload.

Thus one dark existential yields explicit level-$1$, level-$2$, and level-$3$ dark predicates—and, uniformly, one at every positive finite level. These are not independent discoveries. They are copies of the same hidden witness placed in differently colored boxes.

## Why the naive hierarchy collapses

Imagine a locked room known to contain one person. Give that person three badges and describe the occupants as “the person wearing badge zero,” “the person wearing badge one,” and “the person wearing badge two.” There are now three distinct person-badge pairs, but no additional person has been found.

Finite tags do the same thing mathematically. Cardinality increases in the product space, yet proof-theoretic information does not. Therefore raw witness number is not an invariant measure of logical hardness.

This does not say that every possible hierarchy of darkness is meaningless. It says that any serious hierarchy must identify constructions that differ only by irrelevant finite decoration. One might quotient predicates by finite tags, computable bijections, or other harmless changes of representation. Only then can “higher level” plausibly mean “strictly more informative or more difficult.”

There is also a downward principle. Mathematically, if a property has at least $n$ witnesses and $m\le n$, then it has at least $m$ witnesses: select an $m$-element subset. At the proof level, if the deductive system can transform a proof of “at least $n$” into a proof of “at least $m$,” then level-$n$ darkness implies level-$m$ darkness. So the raw levels are monotone downward and cheaply amplifiable upward—another sign that they do not, by themselves, measure depth.

## When darkness is impossible

The framework also isolates a clean obstruction.

**Named Witness-Extraction Theorem.** Suppose a proof system has the following property for $P$: whenever it proves $\exists x\,P(x)$, there is some natural number $n$ for which it proves $P(\nu(n))$. Then $P$ cannot be dark.

The reason is direct. Darkness requires provable existence and simultaneously forbids every provable named instance. Witness extraction supplies exactly the instance that darkness excludes.

This theorem clarifies what dark existence demands from a deductive setting. A system with a suitable numerical or named-witness property leaves no room for it. Any genuine example must therefore exploit a setting where existential proofs need not yield proofs of named instances, or where the naming map fails to capture the witnesses in the relevant intensional sense.

## Famous independence results are not automatic examples

It is tempting to point immediately to celebrated statements independent of Peano arithmetic, such as the Paris–Harrington principle or the Kirby–Paris hydra theorem. They demonstrate genuine limits of arithmetic proof. Yet their usual forms do not automatically satisfy the definition above.

The issue is logical shape. Standard independence results often assert a universal termination or finite-combinatorial principle that the theory cannot prove. Dark existence asks for something different: the theory must prove an existential statement while proving none of its named instances. Independence of a universal principle does not supply that pair of facts.

An explicit arithmetic example would require a fixed arithmetization of syntax, an exact naming map, and a carefully designed—likely intensional or nonstandard—predicate. For every standard name, one would need a metamathematical argument excluding a proof of that instance, while still exhibiting a proof of the existential. Citing an independence theorem alone does not bridge this gap.

## Why “most statements are dark” is not yet a theorem

A second tempting claim is that dark statements are dense among true $\Pi_2$ sentences. But density requires a notion of space and size. Formula strings can be padded with harmless symbols or rewritten through equivalent constructions. Such changes may radically alter simple counts while leaving the mathematics untouched.

Before asking whether darkness is common, one must choose a topology, a grammar-based bounded-length density, a probability distribution on programs, or another explicit measure. Then one must show that the conclusion is robust under acceptable changes of coding. Without this work, “most formulas” describes typography more than mathematics.

The tag theorem is a warning in miniature. If irrelevant tags can manufacture arbitrarily high witness levels, irrelevant syntax can also manufacture misleading frequencies. Representation-sensitive statistics must not be mistaken for intrinsic structure.

## From shadows to invariants

Dark existence remains a fertile idea, but its most durable lesson is methodological. Existence, naming, and extraction are separate notions. Counting witnesses before controlling representation can confuse duplicated descriptions with new information. Counting formulas before controlling syntax can confuse padding with prevalence.

A stronger theory should proceed in three stages. First, instantiate provability with a concrete arithmetic proof calculus and verify that finite tagging corresponds to effective transformations of derivations. Second, search for a genuine predicate satisfying provable existence and universal failure of named-instance provability. Third, quotient away finite tags and computable renamings before defining any hierarchy or density.

The result is not the proposed tower of increasingly dark theorems. It is something more foundational: a theorem explaining why that tower, as first imagined, cannot measure what it intends to measure. A single shadow can be split into any finite number of silhouettes by changing the screen. The challenge is to identify the darkness that survives when the screen itself is allowed to move.
