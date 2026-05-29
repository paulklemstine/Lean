# The Mathematics of "You Can't Do That"

## Why Symmetry Is the Hidden Reason Behind Impossibility

**By the Research Team**

---

There is a peculiar family of theorems in mathematics that all say the same thing: *you can't do that*. You can't trisect an arbitrary angle with compass and straightedge. You can't solve every quintic equation with radicals. You can't design a perfectly fair voting system. You can't simultaneously know both the position and momentum of a particle with arbitrary precision.

For centuries, these results stood as isolated monuments — each with its own intricate proof, its own specialized machinery, its own community of experts. A geometer proving the impossibility of angle trisection had nothing to say to a physicist wrestling with the uncertainty principle. An algebraist explaining why the quintic resists radical solution shared no language with an economist proving Arrow's impossibility theorem.

Until now.

What if all these impossibilities share a common root? What if there is a single mathematical structure — elegant, precise, and surprisingly simple — that explains why all of them must fail?

---

## The Locked Room

Imagine you are standing in a perfectly circular room. The walls are featureless. The floor is smooth. There are no windows, no markings, nothing to distinguish one direction from another. Now someone asks you: *point north*.

You can't. Not because you lack a compass or because the question is unfair. You can't because the room itself has perfect rotational symmetry. Every direction looks exactly like every other direction. To pick one — to declare "this way is north" — you would need to *break* the symmetry of the room. You would need information that the room itself does not contain.

This is the fundamental insight behind a new mathematical framework that unifies dozens of seemingly unrelated impossibility theorems. The framework, built on the century-old theory of group actions, reveals that impossibility arises whenever a task demands a canonical choice in a situation with too much symmetry.

The precise statement: **you cannot make an equivariant choice on a nontrivial free action**. In plain English: if a system has perfect symmetry, and your answer must respect that symmetry, then you cannot single out a preferred element without additional information.

---

## What "Symmetry" Really Means

To a mathematician, symmetry is not a vague aesthetic quality. It is a precise algebraic structure called a *group action*. A group is a collection of transformations — rotations, reflections, permutations, relabelings — that can be composed and undone. A group *acts* on a set when each transformation moves the elements of the set around in a consistent way.

Consider three candidates in an election: Alice, Bob, and Carol. The symmetric group of three elements acts on this set by relabeling: we can swap Alice and Bob, or rotate Alice → Bob → Carol → Alice, or perform any other permutation. Each permutation is a symmetry of the candidate set.

Now consider a voting rule that takes in everyone's preferences and outputs a winner. If the rule is *equivariant* — meaning that relabeling the candidates in the input relabels the winner in the output — then the rule treats all candidates "fairly." It doesn't have a built-in bias toward any particular name.

But here is the crux: can such a rule always produce the *same* winner regardless of how the candidates are labeled? That is, can it be both equivariant (fair) and constant (deterministic in a label-free way)?

The answer is no. And the reason is exactly the locked-room problem. The set of candidates, under the full symmetric group, is a *free transitive action*: every candidate can be sent to every other candidate, and no nontrivial symmetry fixes any candidate. Making a constant equivariant choice on such a set is like pointing north in a circular room.

---

## The Framework: Equivariant Tasks

The new framework formalizes this intuition with a concept called an *equivariant task*. An equivariant task consists of:

1. A **symmetry group** G that acts on both the input space X and the output space Y.
2. An **admissibility condition** that, for each input x, specifies which outputs are acceptable.
3. A **compatibility requirement**: the admissibility condition must respect the group action.

A task is *solvable* if there exists a function from inputs to outputs that is both admissible (picks acceptable outputs) and equivariant (commutes with all symmetries).

This definition is deceptively simple. But it captures an enormous range of mathematical and practical problems:

- **Angle trisection**: The input is an angle, the output is one-third of that angle, and the symmetry group is the group of compass-and-straightedge constructions. The task asks for a construction that works uniformly for all angles.

- **Quintic formula**: The input is the coefficients of a polynomial, the output is a root, and the symmetry group is the Galois group. The task asks for a radical formula that works for all quintics.

- **Fair voting**: The input is a preference profile, the output is a winner, and the symmetry group permutes candidates. The task asks for a rule that is both fair and deterministic.

- **Quantum measurement**: The input is a quantum state, the output is a definite value, and the symmetry group is the group of canonical transformations. The task asks for a measurement that commutes with all symmetries.

In each case, impossibility arises because the group action is "too rich" — there is too much symmetry for a canonical choice to exist.

---

## The Core Theorem

The central result, now formally verified with computer-checked proofs, can be stated without jargon:

> **If a group acts freely on a set — meaning no element is fixed by any nontrivial symmetry — and the group has at least two elements, then no equivariant function from the set to itself can be constant.**

The proof is startlingly brief. Suppose such a function f existed, always outputting the same value c. Pick any nontrivial symmetry g. By equivariance, f(g · x) = g · f(x) = g · c. But by constancy, f(g · x) = c. So g · c = c, meaning c is a fixed point. But the action is free — no point is fixed by any nontrivial symmetry. Contradiction.

Three lines of reasoning. One knockout.

What makes this powerful is not the individual proof — it is the *scope*. This single argument, applied with different groups and different sets, yields impossibility results across mathematics. The group changes. The set changes. The admissibility condition changes. But the underlying mechanism — the clash between equivariance and symmetry-breaking — remains identical.

---

## The Counterexample That Sharpens the Theory

A natural question arises: if a group acts freely, does that mean *all* equivariant tasks are impossible?

No. And this "no" is as important as the impossibility theorem itself.

Consider the *identity task*: for each input x, the only admissible output is x itself. The identity function solves this task equivariantly on any group action, free or not. The identity function commutes with every symmetry (that's what it means to be the identity), and it trivially selects an admissible output.

This counterexample is not a failure of the theory. It is its sharpening. The impossibility does not come from freeness alone. It comes from freeness *plus the demand for symmetry-breaking choice*. The identity task does not ask you to break symmetry — it asks you to preserve it. Tasks that demand you pick a canonical representative, collapse distinct elements, or make a uniform selection across an orbit — those are the ones that fail.

The correct slogan is: **impossibility arises when the task demands more symmetry-breaking than the action permits.**

---

## Seeing It In Numbers

The theory has been computationally verified on finite groups of small order. Consider the cyclic group of order 3 — think of it as the set {0, 1, 2} with the operation of addition modulo 3 — acting on itself by translation.

This action is free (shifting by 1 or 2 moves every element) and transitive (any element can reach any other). A computer search finds exactly 3 equivariant self-maps: the three translations x ↦ x, x ↦ x+1, and x ↦ x+2. All three are bijections. None is constant.

The same pattern holds for every cyclic group C_n with n ≥ 2: exactly n equivariant self-maps, all bijections, none constant. The theory predicts this perfectly.

For the symmetric group S_3 (all 6 permutations of 3 elements) acting on {0, 1, 2}, the situation is even more constrained. There is only *one* equivariant self-map: the identity. The full symmetric group is so constraining that equivariance alone forces uniqueness.

---

## Beyond Mathematics

The framework has immediate implications beyond pure mathematics.

**In cryptography**, the impossibility of a constant equivariant map explains why encryption requires key material. Without a key, an encryption scheme would need to be equivariant under all message permutations — it would need to treat all messages symmetrically. But then it could not distinguish them, which is the entire point of encryption. The key is literally the symmetry-breaking data that makes encryption possible.

**In fair division**, when identical goods must be divided among identical agents, the impossibility says you cannot allocate them without a tie-breaking mechanism. If three people must share one indivisible prize, and any relabeling of the people must relabel the allocation, then no equivariant allocation exists. Someone must be privileged — and that requires breaking symmetry (e.g., by drawing straws).

**In physics**, the framework touches the deepest structure of quantum mechanics. The impossibility of simultaneously measuring non-commuting observables can be reframed as an equivariant obstruction: the two observables generate a noncommutative group of symmetries, and no equivariant selection can respect both simultaneously.

---

## A New Field?

What is remarkable about this work is not any single theorem — many of the individual results have been known, in various forms, for decades or even centuries. What is new is the *unification*. By identifying the common algebraic structure behind disparate impossibility results, the framework opens a new research program: **impossibility as equivariant obstruction theory**.

The program has concrete next steps. Can the framework be extended to topological group actions, capturing Borsuk-Ulam-type fixed-point theorems? Can it incorporate the non-commutative structures of quantum mechanics in full generality? Can it be automated, so that a computer can take a mathematical task and determine whether symmetry obstructs its solution?

These questions are now well-posed for the first time because the framework gives them a common language. The locked room has been mapped. The question is how far its corridors extend.

---

## The Deeper Message

There is something philosophically striking about the fact that impossibility has a unified theory. We tend to think of impossibility as a negative result — a dead end, a failure. But the equivariant framework reveals it as something positive: a *structural feature* of symmetric systems. Impossibility is not the absence of a solution. It is the presence of a symmetry that forbids one.

This shift in perspective — from "we haven't found a solution" to "symmetry guarantees there is none" — is one of the deepest moves in mathematics. It transforms frustration into understanding. It replaces the question "why can't we do this?" with the answer "because the world is symmetric in exactly the way that prevents it."

And that, perhaps, is the most important lesson: the things we cannot do are as illuminating as the things we can.
