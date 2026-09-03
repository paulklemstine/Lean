# When Are Two Things the Same? A Story of Observers, Diamonds, and Names

## The oldest question in mathematics

Ask a mathematician what the hardest question in the subject is, and you will get many answers. Ask what the *most frequent* question is, and there is only one candidate: **when should we call two things the same?**

Two chessboards with the pieces in identical positions are "the same position", even though one is walnut and one is plastic. Two vending machines are "the same machine" if, whatever sequence of coins and buttons you feed them, they dispense the same things — even if one has twice as many internal relays. Two computer programs are "the same program" if you can never catch them behaving differently, even if their source code has nothing in common.

In each case, sameness is not a property of the objects. It is a property of *the questions you are allowed to ask*. Change the questions and you change what counts as the same.

This article is about making that slogan into a theorem — and then about a surprise. There is a natural, very old candidate for "sameness up to observation" in the theory of transition systems, called **bisimulation**. There is an equally natural candidate for "literally the same shape", called **isomorphism**. Everyone knows these differ. The interesting question is: *how* do they differ? What exactly is the extra information that an isomorphism sees and an observer cannot?

The natural guess — the one we set out to prove — is **multiplicity**: the observer cannot count. An isomorphism knows whether a state has one successor or two; an observer, who can only probe behaviour, cannot tell a state apart from one where a successor has been duplicated. Counting, the guess says, is exactly the missing information.

That guess is *half right*, and its failure is the most interesting thing in this story.

---

## The stage: worlds that can only look downwards

Everything happens in a very concrete arena. The **worlds** are the natural numbers $0, 1, 2, 3, \dots$. There is a family of transition relations indexed by a **tag** $i$ (think of tags as different types of move, or different agents), and the rule is:

> World $m$ can step, at tag $i$, to world $n$ **only if $n < m$**.

That single inequality does an enormous amount of work. It means every world has only finitely many successors — its successors live below it, and there are only $m$ numbers below $m$. It also means you can never step forever: every path strictly decreases, so it must halt. In the jargon, such systems are *image-finite* and *converse well-founded*. In plainer language: **the world has a floor, and every state can see only finitely far.**

The **observer's language** is modal logic. Its sentences are built from falsehood $\bot$, atomic observations $p$, implication $a \to b$, and, for each tag $i$, the box $\Box_i a$, read: *"every $i$-successor of the current world satisfies $a$."* From these one can define everything else: negation $\neg a$ is $a \to \bot$, conjunction is the usual dance with implications, and the diamond $\Diamond_i a = \neg\Box_i\neg a$ says *"some $i$-successor satisfies $a$"*. Notice what the language cannot say. It can say "some successor is red" and "every successor is red". It cannot say "exactly two successors are red". **It has no numbers.**

A **valuation** $V$ decides which atoms hold at which world. The pair (transition system, valuation) is a *model*, and a *pointed model* is a model with a chosen starting world. All our questions are about pointed models: this world, in this system.

---

## Sameness by observation

Two pointed models are **modally equivalent** if no sentence of the language separates them: every formula true at one is true at the other. This is sameness-by-interrogation. You are handed two black boxes; you may ask any modal question you like, as many as you like, at any depth of nesting; you never catch a difference.

Two pointed models are **bisimilar** if there is a relation $E$ between their worlds, linking the two roots, such that whenever $x \mathrel{E} y$:

* $x$ and $y$ satisfy exactly the same atoms;
* (**forth**) every $i$-step from $x$ to some $x'$ is matched by an $i$-step from $y$ to some $y'$ with $x' \mathrel{E} y'$;
* (**back**) symmetrically, every $i$-step from $y$ is matched by one from $x$.

This is sameness-by-simulation: a strategy for a copycat who must mirror every move you make, forever, without ever getting stuck. Bisimilarity is an equivalence relation — reflexive by the identity relation, symmetric by reversing, and transitive by composing two bisimulations, which is again a bisimulation.

The first theorem says these two notions coincide.

> **Hennessy–Milner Theorem.** In these systems, two pointed models are bisimilar if and only if they are modally equivalent.

One direction is a routine induction: along a bisimulation, every formula has the same truth value at related worlds, by matching each box using *forth* in one direction and *back* in the other.

The other direction is the beautiful one, and it is where finiteness earns its keep. One shows that **modal equivalence is itself a bisimulation**. Suppose $m$ and $n$ are modally equivalent and $m$ steps to $m'$. If no successor of $n$ were modally equivalent to $m'$, then for each of the finitely many successors $n'$ of $n$ we could pick a formula $a_{n'}$ true at $m'$ and false at $n'$. Because there are finitely many, we can take their **conjunction** $A$ — a single finite formula, true at $m'$ and false at every successor of $n$. Then $\Box_i \neg A$ holds at $n$; by modal equivalence it holds at $m$; but $m$ steps to $m'$, where $A$ is true. Contradiction. Finiteness is what turns infinitely many potential differences into one witnessing sentence.

An immediate corollary is the statement we really wanted. Call an assignment $I$ of values to pointed models an **interpretation**. Then:

> **Factorization Theorem.** An interpretation is invariant under all modal observations if and only if it is invariant under bisimulation. Equivalently, every observationally invariant quantity is a function of the *modal theory* of a pointed model, and of nothing finer.

That is the positive half of the story, and it is exactly as clean as one hopes: **the resolution of modal observation is bisimulation.** Not isomorphism, not anything finer.

---

## The ladder below: what depth buys you

There is a whole staircase underneath. Say two pointed models are **depth-$k$ equivalent** if they agree on every formula with at most $k$ nested boxes. Then modal equivalence is precisely the intersection of all the depth-$k$ equivalences — bisimilarity is the *limit* of the depth ladder.

Is the ladder strict? Yes, and the witness is delightfully simple: the **chain**, in which world $m+1$ sees exactly world $m$ and nothing else, a single infinite descending path $\cdots \to 3 \to 2 \to 1 \to 0$.

Define the *height formula* $\Box^j\bot$ — the box iterated $j$ times over falsehood. It says "you cannot take $j$ steps". A short induction shows

$$\Box^j\bot \text{ holds at world } m \text{ of the chain} \iff m < j.$$

So $\Box^{k+1}\bot$ is true at world $k$ and false at world $k+1$: the two worlds are separated at depth $k+1$. But they *agree* at depth $k$ — an observer with a budget of $k$ nested boxes runs out of moves before reaching the floor. Every rung of the ladder is therefore strict, and no finite depth reaches bisimulation:

$$\text{depth-}0 \subsetneq \text{depth-}1 \subsetneq \text{depth-}2 \subsetneq \cdots \subsetneq \text{modal} = \text{bisimulation} \subsetneq \text{isomorphism}.$$

That last strict inclusion is the one we came for.

---

## The gap, and the tempting explanation

Here is the smallest witness. Take five worlds with edges
$$1 \to 0, \qquad 2 \to 0, \qquad 3 \to 1, \quad 3 \to 2, \qquad 4 \to 1.$$

Worlds $1$ and $2$ are twins: each has a single dead-end successor. World $3$ has *two* successors, both of them twins; world $4$ has *one*. The relation "same behavioural class" — dead ends together, twins together, $\{3,4\}$ together — satisfies forth and back, so it is a bisimulation. Hence:

> **The Multiplicity Gap.** Worlds $3$ and $4$ are bisimilar, hence satisfy exactly the same modal formulas of every depth — and yet no isomorphism of the systems they generate can match them, because the out-degree of $3$ is $2$ and the out-degree of $4$ is $1$.

The out-degree is an isomorphism invariant (an isomorphism is a bijection preserving edges both ways, so it matches successors one-for-one) but not a modal invariant. So invariance under bisimulation is *strictly stronger* than invariance under isomorphism, and the separating quantity is a **count**.

This is the moment where the tempting conjecture appears, fully formed:

> *The gap between bisimulation and isomorphism is characterized by multiplicity-sensitive observations. Add counting to the language and you recover isomorphism.*

It is a good conjecture. It fits the evidence. It is also **false**.

---

## The shared diamond: where counting fails

Consider two systems on the same root, world $5$.

**The shared diamond.** $5 \to 3$, $5 \to 4$, $3 \to 1$, $4 \to 1$. The two branches diverge at the root and then *meet again* at world $1$. Four worlds are reachable.

**Its unravelling.** $5 \to 3$, $5 \to 4$, $3 \to 1$, $4 \to 2$. Identical, except that the two branches end at *different* leaves. Five worlds are reachable.

Draw them. One is a rhombus; the other is a Y. They are visibly different pictures.

Now compare them observationally. Match worlds by behavioural class: the root has class $2$, the two middle worlds have class $1$, the leaves have class $0$. This matching satisfies forth and back — the diamond's root can send you to $3$ or $4$, and so can the tree's; from a middle world both must go to a leaf; leaves are stuck in both. So the two systems are **bisimilar**, and therefore no modal sentence at any depth tells them apart.

So far, so expected. But now count. Along the matching:

* root vs root: out-degree $2$ and $2$;
* middle vs middle: out-degree $1$ and $1$;
* leaf vs leaf: out-degree $0$ and $0$.

**The multiplicities agree everywhere.** Adding counting to the observer's language buys nothing here.

And yet the two systems are not isomorphic. The proof is a pigeonhole so short it fits in a sentence. An isomorphism must send the tree's root to the diamond's root, and hence the tree's two middle worlds to the diamond's two middle worlds. Each of the tree's leaves is the unique successor of a middle world, so both must land on the unique leaf of the diamond, namely world $1$. But an isomorphism is injective, and the tree's two leaves are distinct. Contradiction.

> **Multiplicity Does Not Close the Gap.** There exist two pointed systems that are bisimilar, whose corresponding worlds have equal out-degrees at every tag, and which are nevertheless non-isomorphic.

So the conjecture is refuted, and the refutation is informative. What an isomorphism sees that counting cannot is not multiplicity but **sharing** — whether two behaviourally identical successors are literally the same world or two distinct copies. Unravelling a system into a tree changes no behaviour and no out-degree; it changes only *identity of destinations*. The correct picture is a **two-step ladder**:

$$\text{bisimulation} \;\subsetneq\; \text{bisimulation} + \text{multiplicity} \;\subsetneq\; \text{isomorphism},$$

with the first gap measured by counting and the second by sharing — concretely, by the number of reachable worlds, which is $4$ for the diamond and $5$ for its unravelling.

---

## What *does* close the gap: names

If counting is not enough, what is? The answer is disarmingly simple: **names**.

Suppose the valuation is *nominal* — there is one atom per world, and the atom $p$ is true at exactly the world $p$. Then modal equivalence collapses instantly. To see it, test the single atom $m$ at the world $m$: it is true. If $n$ is modally equivalent to $m$, then atom $m$ is true at $n$ too, which by definition means $n = m$. **The worlds are literally equal** — and this uses no modality at all, only the atomic fragment.

So the whole gap of the previous two sections is an artefact of *atom-poor* languages. Both witnesses — the multiplicity frame and the shared diamond — carried the constant valuation, where atoms tell you nothing and only structure is observable. That is not a coincidence but a necessity.

But one atom per world is a preposterously wasteful language. How many names do you actually need?

> **The Naming Budget.** With $k$ atoms it is possible to separate $2^k$ worlds, and impossible to separate more.

The upper bound is *binary naming*: let atom $p$ be true at world $m$ exactly when the $p$-th bit of $m$ is a $1$. Two worlds below $2^k$ that agree on the first $k$ atoms agree on all their bits, hence are equal. So $k$ atoms name $2^k$ worlds — and again, entirely within the atomic fragment.

The lower bound is a pigeonhole. A language with $k$ atoms assigns each world one of $2^k$ possible atomic types. If you have $2^k + 1$ worlds, two of them must collide: no valuation whatsoever, however cleverly designed, can name them apart atomically.

So the collapse threshold is exactly $\lceil \log_2 N \rceil$ atoms for $N$ worlds. The entire hierarchy — every rung of the depth ladder, the multiplicity gap, the sharing gap — is a phenomenon of languages that are logarithmically too poor to name what they are looking at. **The gap is an information-theoretic deficit, and it is measured in bits.**

---

## How long must you interrogate?

One more question, and it has a pleasingly sharp answer. Bisimilarity is the limit of an infinite ladder of depths. On a fixed finite chunk of the system, when does the ladder stop?

> **Collapse Threshold.** If two worlds both have height at most $k$ — that is, no path from either is longer than $k$ steps — then agreeing on all formulas of depth $\le k$ already forces agreement on *all* formulas, and hence bisimilarity.

The mechanism is a *trimming* operation: replace every box nested deeper than $k$ by "true". At a world of height at most $k$, this changes nothing — the deep boxes are vacuous, since the semantics runs out of worlds to visit before reaching them. So every formula is truth-equivalent, at such a world, to a formula of depth $\le k$.

And the bound is tight: in the chain, worlds $N$ and $N+1$ agree up to depth $N$ and are separated at depth $N+1$ by the height formula. Interrogation takes exactly as many rounds as the system is deep. The ladder is infinite only because we refuse to bound the system.

---

## The proof-theoretic shadow

Finally, a consequence that reaches beyond semantics. Attach to a system and a cutoff $N$ its **truncated theory**: the set of sentences valid at every world $\le N$. This is a genuine deductive theory of the Gödel–Löb kind — the provability logic of well-founded systems — and one can measure its strength by which *reflection rules* it admits: for which depths $d$ does provability of $\Box_i a$ (for $a$ of depth at most $d$) already imply provability of $a$?

> **Theory Transfer.** If a single bisimulation covers the truncated world-sets of two systems in both directions, then their truncated theories prove exactly the same sentences and admit exactly the same reflection rules.

Applied to the shared diamond and its unravelling: their theories are *literally equal* at every cutoff, and their entire reflection spectra coincide, even though the systems are not isomorphic and even though their out-degrees also match. **No amount of proof-theoretic strength can detect sharing.** Whatever an unravelling costs you in world count, it is invisible not merely to observation but to deduction.

---

## The moral

We began with a conjecture that observation resolves systems exactly to bisimulation, and that the residue — the part isomorphism sees and observation does not — is counting. The first half survived intact and became a theorem with a clean factorization: every observationally invariant quantity is a function of the modal theory, full stop.

The second half broke, and broke productively. Counting is a real gap, but it is not *the* gap. Beneath it lies a second, subtler one: sharing. Two systems can agree on all behaviour and all counts and still differ in whether their branches reconverge. And above both lies the resolution: names. A logarithmic supply of atoms — $\lceil \log_2 N\rceil$ bits, no more and no less — dissolves the entire hierarchy at once, in the atomic fragment, before a single modality is used.

This is a lesson that reaches well past modal logic. When we ask whether two objects are "really" the same, we are asking about a budget: how many distinctions our language can afford to draw. Behaviour is what you see when the budget is zero; identity is what you see when the budget is total; and the mathematics of everything in between is the mathematics of what your questions can pay for.
