# The Last Word Wins: How Changing Your Mind Forgets Its Own History

## A dream that keeps rewriting itself

You are dreaming. In the dream you believe your house has a red door. A moment later, without any sense of contradiction, you believe the door is *not* red. Later still it is red again. When you wake and try to reconstruct the dream, you do not recall a debate, an argument, or a resolution. You recall only the last thing you believed: the door was red.

This is not just a curiosity of dreams. It is the behaviour of almost every system that stores beliefs by *overwriting* them: a configuration file, a database row, a sensor cache, a whiteboard in a meeting room. Something new arrives, the old value is wiped, the new value is written. Nothing remembers the struggle.

The question this article is about is deceptively simple. **If a system revises its beliefs one small fact at a time, over and over, what exactly does the whole history of revisions do?** Can you compress a thousand mind-changes into a short summary? Is that summary unique? And can a contradiction lurking in one corner of the system corrupt the rest?

The answers turn out to be sharp, complete, and — pleasantly — geometric.

## The setup: signed facts

Fix a collection of *atoms*: elementary propositions like "the door is red", "it is raining", "the account is locked". Write them as $a, b, c, \dots$.

A **literal** is an atom paired with a sign: $(a, \mathrm{T})$ means "$a$ holds" and $(a, \mathrm{F})$ means "$a$ fails". The two literals $(a,\mathrm{T})$ and $(a,\mathrm{F})$ are **complementary**; write $\overline{\ell}$ for the complement of the literal $\ell$, so that $\overline{(a,\mathrm{T})} = (a,\mathrm{F})$.

A **state** is simply *any* set $B$ of literals. That single design choice is the interesting one. A state is allowed to contain both $(a,\mathrm{T})$ and $(a,\mathrm{F})$ at once — we then call it **contradictory at $a$**. States with no such atom are **consistent**. Crucially, contradiction is not catastrophe here: a state that is contradictory at $a$ does not thereby accept every literal. It merely happens to hold both sides of one particular question. Dreamers do this constantly; so, more prosaically, do distributed databases mid-reconciliation.

The state $B$ **accepts** a literal $\ell$ precisely when $\ell \in B$. Nothing more: no closure, no inference, no explosion.

## The one move you are allowed

Now the dynamics. Given a state $B$ and a literal $\ell$, the **revision** of $B$ by $\ell$ is

$$\mathrm{rev}(B,\ell) \;=\; \bigl(B \setminus \{\overline{\ell}\}\bigr) \cup \{\ell\}.$$

In words: *assert $\ell$, and retract only its direct opposite.* Nothing else is touched. This is the minimal possible edit that guarantees two things at once — **success** ($\ell$ is now accepted) and **local consistency** (the atom of $\ell$ is no longer contradictory, and no other atom's status changed). If $B$ was consistent, so is $\mathrm{rev}(B,\ell)$; if $B$ was finite, so is $\mathrm{rev}(B,\ell)$.

A **revision history** is a finite list $\ell_1, \ell_2, \dots, \ell_n$ of literals, applied left to right:

$$\mathrm{rev}^*(B; \ell_1,\dots,\ell_n) \;=\; \mathrm{rev}\bigl(\cdots \mathrm{rev}(\mathrm{rev}(B,\ell_1),\ell_2)\cdots, \ell_n\bigr).$$

That is the whole apparatus. Two definitions and one operation. Everything below follows.

## Two local laws

Everything hinges on two rules that describe how adjacent revisions interact.

**Independence.** *If $\ell$ and $k$ are literals over **different** atoms, then*
$$\mathrm{rev}(\mathrm{rev}(B,\ell),k) = \mathrm{rev}(\mathrm{rev}(B,k),\ell).$$
Changing your mind about the door and changing your mind about the rain are independent acts; the order does not matter. The proof is a two-line membership chase: revising at $\ell$ can only insert $\ell$ and delete $\overline{\ell}$, both of which sit over $\ell$'s atom, and are therefore invisible to a revision at $k$'s atom.

**Last write wins.** *If $\ell$ and $k$ are literals over the **same** atom, then*
$$\mathrm{rev}(\mathrm{rev}(B,\ell),k) = \mathrm{rev}(B,k).$$
The earlier revision leaves no trace whatsoever. Note the strength of this: it holds whether $\ell = k$ (idempotence) or $\ell = \overline{k}$ (the genuinely contrary case). Either way, the second write erases the first — because $\mathrm{rev}(\cdot,k)$ deletes $\overline{k}$ and inserts $k$, and those are exactly the two literals that $\mathrm{rev}(\cdot,\ell)$ could have disturbed.

Those two laws sound modest. Together they are complete.

## The Last-Occurrence Normalization Theorem

Given a history $L = (\ell_1,\dots,\ell_n)$ and an atom $a$, define the **last sign** $\mathrm{last}_L(a)$ to be the sign of the *final* literal in $L$ based at $a$ — and *undefined* if $L$ never mentions $a$ at all. So $\mathrm{last}_L$ is a partial map from atoms to signs, a kind of receipt of what the history ultimately decided.

> **Theorem (Last-Occurrence Normalization).** For every state $B$, every history $L$, and every literal $p = (a,s)$,
> $$p \in \mathrm{rev}^*(B;L) \quad\Longleftrightarrow\quad \mathrm{last}_L(a) = s, \ \text{ or } \ \mathrm{last}_L(a) \text{ is undefined and } p \in B.$$

Read it aloud: **a revision history overwrites every atom it mentions with that atom's last sign, and leaves every other atom exactly as it found it.** All the intermediate flailing — the door was red, then not red, then red, then not, then red — collapses into a single verdict per atom.

The proof is an induction on the history using nothing but the two local laws. In particular, from the empty state $\varnothing$, a history produces exactly its own receipt:
$$\mathrm{rev}^*(\varnothing;L) = \{(a,s) : \mathrm{last}_L(a) = s\}.$$

## Rigidity: the empty state already knows everything

Here is a surprisingly strong corollary. Suppose two histories $L$ and $M$ happen to agree when applied to the *single* state $\varnothing$. Do they agree on all states?

> **Theorem (Extensional Rigidity).** For histories $L$ and $M$, the following are equivalent:
> 1. $\mathrm{rev}^*(B;L) = \mathrm{rev}^*(B;M)$ for **every** state $B$;
> 2. $\mathrm{rev}^*(\varnothing;L) = \mathrm{rev}^*(\varnothing;M)$;
> 3. $\mathrm{last}_L(a) = \mathrm{last}_M(a)$ for every atom $a$.

One test input — the empty state — decides behavioural equivalence for the entire (typically infinite) space of inputs. This is the kind of statement that makes a testing engineer sit up. The reason is that revision is *overwrite-or-passthrough* per atom: the empty state exposes the overwrite part, and passthrough is forced by definition.

## The shortest way to say it, and why it is unique

Rigidity says histories with the same receipt are interchangeable. Can we always pick a canonical shortest representative?

Define the **normal form** $\mathrm{nf}(L)$ by scanning $L$ left to right and deleting every literal whose atom occurs again later. What survives is exactly the last occurrence of each mentioned atom, in their original relative order.

> **Theorem (Normal Form).** $\mathrm{nf}(L)$ is a sublist of $L$; it mentions each atom at most once; it has the same last-sign receipt as $L$; and consequently $\mathrm{rev}^*(B;\mathrm{nf}(L)) = \mathrm{rev}^*(B;L)$ for every $B$.

> **Theorem (Uniqueness up to Permutation).** If a history $M$ mentions each atom at most once and has the same last-sign receipt as $L$, then $M$ is a permutation of $\mathrm{nf}(L)$.

Permutation is the sharpest conclusion available, and that is a feature rather than a defect: by the Independence law, revisions at distinct atoms genuinely commute, so no canonical *ordering* can be recovered. What is canonical is the multiset — indeed the *set* — of surviving literals. A history of length one million over five atoms is equivalent to a history of length at most five, and that short history is unique except for shuffling.

So the answer to "can you compress a thousand mind-changes?" is: yes, to at most one per atom, canonically.

## Contradiction does not spread

Classical logic has a famous vice: from a contradiction, everything follows. A single inconsistent belief poisons the entire theory. Real cognitive systems — and real databases — are not like this, and the framework here explains why in a precise way.

> **Theorem (Frame Property).** If no literal in the history $L$ is based at atom $a$, then for both signs $s$, $(a,s) \in \mathrm{rev}^*(B;L)$ if and only if $(a,s) \in B$.

> **Theorem (Persistent Non-Explosion).** Suppose $B$ is contradictory at some atom $a$ — it contains both $(a,\mathrm{T})$ and $(a,\mathrm{F})$ — and suppose $B$ does not accept some literal $\ell$ based at an atom other than $a$. Then for **every** revision history $L$ that never mentions $\ell$'s atom, the resulting state $\mathrm{rev}^*(B;L)$ still does not accept $\ell$ — no matter how many times, and in what order, the contradictory atom $a$ is revised.

You can hammer on the broken atom forever. The rest of the state is untouched. A contradiction in this system is a *local defect*, not a global disease. Amusingly, the contradiction hypothesis in the theorem is not even used in the argument — it is the frame property alone that does the work, which is exactly the point: locality, not any special treatment of inconsistency, is what stops explosion.

## The geometry underneath: states as a cube, revisions as edges

Now step back and look at the whole space of states at once.

First, an identification. A state $B$ is consistent exactly when it never holds both signs of an atom. That is precisely the data of a partial function from atoms to signs:

> **Theorem (Consistency as Partial Assignment).** A state $B$ is consistent if and only if there is a function $f$ from atoms to $\{\mathrm{T},\mathrm{F},\text{undefined}\}$ with $B = \{(a,s) : f(a) = s\}$.

So a consistent state picks *at most one* of the two complementary vertices over each atom. If you picture, over each atom, an edge with endpoints labelled $\mathrm{T}$ and $\mathrm{F}$, a consistent state is a choice of at most one endpoint per edge — a face of a cube-like complex, where "undefined" means "this coordinate is still free".

Now watch what revision does to that picture. Define the **assigned set** $\mathrm{asg}(B)$ to be the atoms on which $B$ has at least one sign. Then:

> **Theorem (Monotone Support).** $\mathrm{asg}(\mathrm{rev}(B,\ell)) = \mathrm{asg}(B) \cup \{\text{atom of } \ell\}$.

A single revision either fixes a coordinate that was free, or flips/reaffirms one already fixed. It never frees a coordinate. Hence the assigned set only grows along a history — support is monotone, information is never forgotten in the sense of *which questions have been answered*, only in the sense of *how they were answered*.

Say $C$ is **reachable** from $B$ if some history carries $B$ to $C$. Monotonicity forces $\mathrm{asg}(B) \subseteq \mathrm{asg}(C)$. The striking fact is that this necessary condition is also sufficient, and it gives a complete classification of the "cycles" of the system:

> **Theorem (Component Classification).** Let $B$ and $C$ be finite consistent states. Then $B$ and $C$ are *mutually* reachable — each from the other — if and only if $\mathrm{asg}(B) = \mathrm{asg}(C)$.

Put differently: build the directed graph whose vertices are the finite consistent states and whose edges are single revisions. Its strongly connected components are indexed precisely by *which atoms have been decided*. Inside one component you can shuffle the answers freely, in any pattern, forever. Between components you can only move in one direction: toward more decided atoms. The whole graph is a stack of "answer-shuffling" cubes, wired together by one-way edges that enlarge the set of answered questions, and the resulting hierarchy is ordered exactly like the lattice of subsets of the atom set.

The proof of sufficiency is constructive and pleasingly direct: to travel from $B$ to a finite consistent $C$ with the same support, simply list the literals of $C$ in any order and perform them. By Normalization, the resulting state has, at each atom mentioned, the last sign — which by consistency of $C$ is the unique sign $C$ assigns — and at each unmentioned atom, whatever $B$ had. Since $B$ and $C$ have the same support, there is nothing left over. You arrive exactly at $C$.

## Why this matters outside the dream

Strip away the dream imagery and you have a rigorous account of a pattern that is everywhere.

**Last-write-wins registers.** Distributed systems people have long used "LWW" as an engineering heuristic for reconciling concurrent updates. Normalization is a theorem-level statement of what an LWW store *is*: its entire behaviour is a partial map from keys to final values, and two update logs are behaviourally identical exactly when their last-occurrence records agree. Extensional Rigidity says you can test log equivalence against a single empty store.

**Log compaction.** Every append-only log eventually needs compaction. The Normal Form Theorem is a correctness proof for the obvious compaction algorithm (keep the last write per key) and, better, a proof that no smaller correct compaction exists and that the compacted log is unique up to reordering.

**Belief revision.** In the classical theory of belief change, revision operators are constrained by postulates like success and minimal change. The operator here is the extreme "syntactic" case, and what it buys is a complete algebra: two local rewrite laws generate the entire theory of iterated revision, with no residual complexity.

**Paraconsistency.** Systems that must keep functioning while holding contradictory data — merged medical records, conflicting sensors, adversarial inputs — need a guarantee that the contradiction is quarantined. Persistent Non-Explosion is exactly such a guarantee, and its proof shows the guarantee comes for free from locality of the update rule.

## The frontier

Several sharp questions remain open, and the theorems above make them precise rather than vague.

Is the two-law rewrite system *complete*? Normalization shows the action of a history depends only on its receipt; the open half is whether any two histories with the same receipt can be connected by a finite chain of the Independence and Last-Write-Wins rewrites alone. The normal form is the obvious confluence target, so this is a question about whether a rewriting system converges to it.

How large are the components? Classification pins down the *vertices* of each strongly connected component — the finite consistent states with a given support $S$ — but not its metric. The natural conjecture is that each component is the $|S|$-dimensional hypercube graph, with $2^{|S|}$ vertices and diameter $|S|$: to get from one answer pattern to another you must flip exactly the coordinates on which they differ, and you can do no better. Relatedly, the minimal length of a history steering $B$ to $C$ ought to be exactly the number of literals of $C$ not already in $B$, with every minimal history a permutation of those literals.

Is the operator itself forced? Among all update rules satisfying success — after updating by $\ell$, the state accepts $\ell$ — the frame law "coordinates over other atoms are unchanged" appears to pin down $\mathrm{rev}$ uniquely. If so, consistency preservation is not an extra postulate at all but a consequence, and the whole theory is the unique theory of *local* belief change.

And finally, the infinite picture. Finite states form a directed system under inclusion whose ideals should reconstruct arbitrary states under a natural topology, with consistent ideals corresponding exactly to globally consistent states — a compactness statement asserting that the arbitrary dreamer is nothing but a limit of finitary ones.

## Coda

The dreamer who believes the door is red, then isn't, then is, has not accumulated a tangled history. She has, provably, a single belief about the door and untouched beliefs about everything else. The tangle exists only in the telling. Mathematics, here, does what it does best: it shows that a process which looks hopelessly path-dependent is in fact governed by a receipt of last words — and that the receipt is unique, testable against a single empty state, and geometrically a walk on a cube whose dimension is the number of questions you have bothered to answer.
