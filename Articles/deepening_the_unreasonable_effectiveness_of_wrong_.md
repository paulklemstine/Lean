# The Unreasonable Effectiveness of Wrong Theories

Every physical theory ever written down is wrong. Newton's mechanics fails near the speed of light. Its successor, special relativity, ignores gravity. General relativity, in turn, refuses to shake hands with quantum mechanics. And yet engineers still send probes to distant planets using Newton's centuries-old equations, and they arrive. A theory known to be false continues to earn its keep — sometimes outperforming the very theories that dethroned it.

This is not an accident of history or a failure of nerve. It is a theorem. Below is a precise, self-contained account of *why* wrong theories are not merely tolerable but, on carefully chosen questions, unbeatable — beating not just one rival but an entire field of competitors at once.

## Theories as points in a space

The trick is to stop thinking of a theory as a bundle of equations and start thinking of it as a single geometric object: a point.

Imagine a space $E$ in which every conceivable physical theory is a point. This is not a metaphor to be admired and set aside; it is a working assumption with real teeth. We equip $E$ with the structure of an **inner-product space** — the same structure that governs ordinary Euclidean geometry, where we can measure lengths, angles, and the degree to which two directions align. The inner product of two elements $x$ and $y$ is written $\langle x, y\rangle$, and the length of a vector is $\|x\| = \sqrt{\langle x, x\rangle}$.

Somewhere in this space sits one privileged point: the **truth**, written $\mathsf{truth}$, the theory that describes nature exactly. No human has ever held it, but there is no harm in naming it. Every actual theory $T$ is some *other* point, and the natural measure of how badly it misses is simply the distance between them:
$$\mathrm{wrongness}(T) = \|T - \mathsf{truth}\|.$$
A theory's wrongness is its distance from the truth. Newton's point sits far from $\mathsf{truth}$; Einstein's sits closer; both sit at a strictly positive distance.

## Phenomena as directions, predictions as shadows

Wrongness is a single global number, but science does not test theories globally. It asks specific questions: *What is the perihelion precession of Mercury? What is the deflection of starlight? What is the half-life of this isotope?* Each such question is a **phenomenon** — a direction $u$ in theory-space along which we choose to look.

A theory's **prediction** for the phenomenon $u$ is the shadow the theory casts in that direction, the inner product $\langle T, u\rangle$. The truth casts its own shadow, $\langle \mathsf{truth}, u\rangle$. The gap between them is the theory's **prediction error** on that phenomenon:
$$\mathrm{predErr}(T, u) = \bigl|\langle T - \mathsf{truth},\, u\rangle\bigr|.$$
This is the quantity a laboratory actually measures: not the total wrongness of a theory, but its error on one particular question.

The distinction between global wrongness and local prediction error is the whole story. A theory can be badly wrong overall yet cast *exactly the right shadow* in some specific direction — because its error vector $T - \mathsf{truth}$, though long, might point sideways to the direction $u$ we happen to be probing.

## The first law: you cannot err more than you are wrong

Before celebrating wrong theories, we should reassure ourselves that wrongness still means something. It does, and the guarantee is the oldest inequality in the inner-product playbook, Cauchy–Schwarz.

> **Theorem (Errors are bounded by wrongness).** For every theory $T$ and every phenomenon $u$,
> $$\mathrm{predErr}(T, u) \le \mathrm{wrongness}(T)\cdot \|u\|.$$

The proof is a single line: $|\langle T - \mathsf{truth}, u\rangle| \le \|T - \mathsf{truth}\|\,\|u\|$, which is exactly Cauchy–Schwarz applied to the error vector and the phenomenon. In words: a theory that is close to the truth *cannot* make a large error on any bounded question. Global accuracy really does buy local accuracy. Wrongness is a genuine ceiling on error, never a floor.

## Perturbation theory always converges — where it counts

Physicists rarely leap from a wrong theory to the truth. They *correct* it, adding one small term at a time: a relativistic correction here, a quantum loop there. Model this as a starting theory $T_0$ together with a stream of corrections $c_0, c_1, c_2, \dots$, and define the $n$-th corrected theory as
$$T_0 + \sum_{i<n} c_i.$$
Suppose the corrections genuinely close the gap, meaning the infinite series of corrections sums to $\mathsf{truth} - T_0$. Then something clean happens.

> **Theorem (Predictions converge).** If the corrections sum to $\mathsf{truth} - T_0$, then for *every fixed phenomenon* $u$, the prediction error of the corrected theories tends to zero:
> $$\mathrm{predErr}\!\left(T_0 + \sum_{i<n} c_i,\ u\right) \longrightarrow 0 \quad \text{as } n \to \infty.$$

The argument is a squeeze. By the first theorem, each prediction error is trapped between $0$ and $\mathrm{wrongness}\bigl(T_0 + \sum_{i<n}c_i\bigr)\cdot\|u\|$. As the corrections accumulate, the corrected theory converges *in theory-space* to the truth, so its wrongness tends to zero; the upper bound collapses, dragging the prediction error down with it. Convergence of the theory forces convergence of every prediction. Perturbation theory, when it converges at all, converges on every question at once.

## The main event: a wrong theory that cannot be beaten

Now the surprise. Take our wrong theory $A$ and a rival theory $B$. We ask: is there a phenomenon on which the *wrong* theory $A$ predicts perfectly while $B$ does not? Astonishingly, as long as the two theories are wrong in genuinely *different ways*, the answer is always yes — and we can write the winning question down explicitly.

Let $a = A - \mathsf{truth}$ and $b = B - \mathsf{truth}$ be the two error vectors. Say the errors are *non-parallel* if $b$ is not a scalar multiple of $a$ — the theories don't fail in the same direction. Form the part of $B$'s error that is orthogonal to $A$'s error, the Gram–Schmidt residue
$$q = b - \frac{\langle b, a\rangle}{\langle a, a\rangle}\, a.$$

> **Theorem (A wrong theory beats its rival, quantitatively).** If $A \ne \mathsf{truth}$ and $b$ is not parallel to $a$, then on the phenomenon $q$ the wrong theory $A$ is *exactly right*,
> $$\mathrm{predErr}(A, q) = 0,$$
> while the rival $B$ errs by exactly the squared length of that residue,
> $$\mathrm{predErr}(B, q) = \|q\|^2 > 0.$$

The mechanism is pure geometry. By construction $q$ is orthogonal to $a$, so $A$'s error casts no shadow along $q$ — its prediction is flawless. But $q$ is the leftover piece of $B$'s own error, so $B$'s error projects onto $q$ with full strength $\|q\|^2$, and non-parallelism guarantees this leftover is not zero. The wrong theory doesn't just tie the rival on this question; it wins by an explicit, computable margin. Newton, asked exactly the right question, can outshine Einstein.

## Beating the entire field at once

One rival is a curiosity. The real theorem defeats *all* of them together.

The engine is a lemma about avoiding hyperplanes. Given any finite list of nonzero directions $q_1, \dots, q_k$, there is a *single* vector $u$ that pairs nontrivially with every one of them — $\langle q_i, u\rangle \ne 0$ for all $i$ — and that moreover lies in their combined span (it is orthogonal to anything all the $q_i$ annihilate). The proof builds $u$ one direction at a time: having found a witness for the first $k-1$ directions, nudge it by a small multiple $t\,q_k$ of the new direction. Only *finitely many* values of $t$ can spoil any of the existing pairings, and the real line is infinite, so a safe $t$ always exists. Finiteness versus the continuum: the continuum wins.

> **Theorem (A wrong theory beats a whole field of rivals).** Let $A \ne \mathsf{truth}$ be our wrong theory and let $B_1, \dots, B_k$ be *any finite family* of rivals, none of whose errors is parallel to $A$'s error. Then there is a *single* phenomenon $u$ on which $A$ is exactly right, $\mathrm{predErr}(A, u) = 0$, while *every* rival simultaneously errs, $\mathrm{predErr}(B_j, u) > 0$ for all $j$.

The construction is exactly what the story so far demands: orthogonalize each rival's error against $A$'s error to get residues $q_1, \dots, q_k$, apply the hyperplane-avoidance lemma to obtain a single $u$ pairing nontrivially with all of them, and check that $u$ stays orthogonal to $A$'s own error. On that one question, the wrong theory is flawless and the entire assembled competition is wrong. There is no committee of correct-but-different theories that can gang up to shut out a wrong theory — provided the wrong theory fails in its own distinctive direction.

## What it means

The moral is not that truth is relative or that anything goes. Wrongness remains a hard ceiling on error, and the truth remains the unique point where *all* prediction errors vanish at once. What the theorems reveal is subtler and, in its way, more humane. Being wrong is not a scalar disgrace but a *direction*. A theory that errs along its own axis will always cast a perfect shadow somewhere off that axis — and if its way of being wrong is genuinely its own, it can find a single question on which it outpredicts every rival ever proposed.

This is why the history of physics is not a graveyard of discarded theories but a working toolkit. Newtonian gravity, thermodynamics without atoms, the Bohr model of the atom — each is wrong, each survives, each is on some questions the sharpest instrument we own. The unreasonable effectiveness of wrong theories is, at last, entirely reasonable. It is geometry.
