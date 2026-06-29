# A Counterexample to "Every Maximal-Fitness Limit Theory is Primitive and Rank-Minimal"

## Abstract

We study an evolutionary model of mathematical theories in which each theory $T$ carries a rational-valued **fitness**
$$f(T) = \frac{\text{connections}(T)\cdot\text{proofDensity}(T)}{\text{axiomCount}(T)},$$
together with a strict **sub-theory order** $\sqsubset$ and a natural-number **rank**. A natural conjecture in this setting asserts that *every maximal-fitness limit theory is primitive (order-irreducible) and rank-minimal among maximal-fitness theories*, with the intended justification resting on two structural hypotheses: **extension monotonicity** ($S \sqsubset T \Rightarrow f(S) \le f(T)$) and **well-founded rank descent** ($S \sqsubset T \Rightarrow \text{rank}(S) < \text{rank}(T)$). We refute this conjecture. We exhibit an explicit two-element model in which both hypotheses hold, a designated theory is simultaneously of maximal fitness, rank-minimal among maximal-fitness theories, and terminal (admitting no fitness-increasing mutation), and yet **fails to be primitive**. The refutation is established by finite case analysis and exact arithmetic over $\mathbb{Q}$, so it is non-circular and fully verifiable. We analyze the root cause — a conflation of *local* terminality with *global* order-minimality, compounded by an alignment between fitness and the sub-theory order in the "wrong" direction — and identify a precise repair: replacing extension monotonicity by an anti-monotone *parsimony* hypothesis restores the conclusion.

## 1. Introduction

A recurring program treats the corpus of mathematical theories as an evolving ecosystem: theories are born, extend one another, compete, and persist according to a fitness valuation. Within such models one wants structural theorems predicting the shape of the long-run survivors. One especially attractive prediction is that the *fittest* surviving theories should be the *simplest* — irreducible foundations from which nothing smaller can be carved.

This paper isolates and tests a sharp form of that prediction. We call a theory **primitive** when it has no proper sub-theory, **terminal** when no fitness-increasing extension exists, and we ask whether maximal fitness, together with two standard structural hypotheses, forces primitivity. We show it does not.

The contribution is threefold:

1. A minimal, self-contained finite model (two theories) demonstrating that extension monotonicity and well-founded rank descent are jointly **insufficient** to imply primitivity.
2. A structural diagnosis: terminality is a local optimality condition while primitivity is a global minimality condition, and the two decouple precisely when fitness is permitted to *increase* along the sub-theory order.
3. A constructive repair: an anti-monotone parsimony hypothesis re-aligns fitness with the order and recovers the conclusion.

All quantitative claims reduce to exact rational arithmetic, making the refutation immune to the circularity that often threatens "impossibility" arguments.

## 2. The model

### 2.1 Theories, order, rank, and traits

We work over a finite type of toy theories.

**Definition 2.1 (Theory landscape).** Let $\mathcal{T} = \{\mathsf{base}, \mathsf{ext}\}$ be the set of theories.

**Definition 2.2 (Proper sub-theory order).** The relation $\sqsubset$ on $\mathcal{T}$ is defined by
$$\mathsf{base} \sqsubset \mathsf{ext}, \qquad \text{and } S \sqsubset T \text{ is false for all other pairs.}$$
Thus $\mathsf{base}$ is the unique proper sub-theory of $\mathsf{ext}$, and $\mathsf{ext}$ has no proper extension.

**Definition 2.3 (Rank).** $\text{rank}: \mathcal{T} \to \mathbb{N}$ is given by $\text{rank}(\mathsf{base}) = 0$ and $\text{rank}(\mathsf{ext}) = 1$.

**Definition 2.4 (Traits).** Each theory carries three rational traits:
$$\text{connections}(\mathsf{base}) = 1,\quad \text{connections}(\mathsf{ext}) = 2,$$
$$\text{proofDensity}(T) = 1 \text{ for all } T,\qquad \text{axiomCount}(T) = 1 \text{ for all } T.$$

### 2.2 Fitness

**Definition 2.5 (Fitness).** The fitness of a theory is
$$f(T) = \frac{\text{connections}(T)\cdot\text{proofDensity}(T)}{\text{axiomCount}(T)} \in \mathbb{Q}.$$

A theory is rewarded for many connections and high proof density, and penalized for a large axiom count. In the present model proof density and axiom count are normalized to $1$, isolating the role of connections.

### 2.3 Derived predicates

**Definition 2.6 (Primitive).** $T$ is *primitive* iff there is no $S$ with $S \sqsubset T$; symbolically $\text{Primitive}(T) :\Leftrightarrow \lnot \exists S,\ S \sqsubset T$.

**Definition 2.7 (Maximal fitness).** $T$ has *maximal fitness* iff $f(U) \le f(T)$ for every $U \in \mathcal{T}$.

**Definition 2.8 (Rank-minimal among maximal-fitness theories).**
$$\text{RankMinimalAmongMax}(T) :\Leftrightarrow \text{MaxFitness}(T)\ \wedge\ \big(\forall U,\ \text{MaxFitness}(U) \Rightarrow \text{rank}(T) \le \text{rank}(U)\big).$$

**Definition 2.9 (Mutation and terminality).** A *mutation* from $S$ to $T$ is a fitness-increasing proper extension:
$$\text{Mutation}(S,T) :\Leftrightarrow S \sqsubset T\ \wedge\ f(S) < f(T).$$
$T$ is *terminal* iff it admits no outgoing mutation: $\text{Terminal}(T) :\Leftrightarrow \lnot \exists U,\ \text{Mutation}(T, U)$.

### 2.4 The structural hypotheses under scrutiny

The conjecture's proof strategy invokes two hypotheses, both of which hold in our model:

- **(EM) Extension monotonicity:** $S \sqsubset T \Rightarrow f(S) \le f(T)$.
- **(WF) Well-founded rank descent:** $S \sqsubset T \Rightarrow \text{rank}(S) < \text{rank}(T)$.

(WF) guarantees the absence of infinite $\sqsubset$-descending chains, since rank is a $\mathbb{N}$-valued strictly decreasing measure along descent.

## 3. The conjecture

> **Conjecture (refuted).** In any landscape satisfying (EM) and (WF), every maximal-fitness limit theory is primitive and rank-minimal among maximal-fitness theories.

The intended argument: by (EM) fitness never decreases as one extends, so an optimum should be reachable by extension; by (WF) the order is well-founded below, so descent terminates at an irreducible bottom; therefore the optimum should coincide with a primitive minimum. We now show this reasoning is fallacious.

## 4. Main results

We first record the two base computations, then verify each hypothesis and predicate, and finally assemble the refutation. Throughout, proofs are by exhaustive case analysis over the two-element type and exact arithmetic over $\mathbb{Q}$.

**Lemma 4.1 (`fitness_base`).** $f(\mathsf{base}) = 1$.

*Proof sketch.* Substitute the traits: $f(\mathsf{base}) = (1 \cdot 1)/1 = 1$. $\qquad\blacksquare$

**Lemma 4.2 (`fitness_ext`).** $f(\mathsf{ext}) = 2$.

*Proof sketch.* Substitute the traits: $f(\mathsf{ext}) = (2 \cdot 1)/1 = 2$. $\qquad\blacksquare$

**Lemma 4.3 (`proper_sub_rank_decreases`, WF).** For all $S, T$, if $S \sqsubset T$ then $\text{rank}(S) < \text{rank}(T)$.

*Proof sketch.* The relation $\sqsubset$ is nonempty only on the pair $(\mathsf{base}, \mathsf{ext})$. Case analysis on $S, T$: the only case with $S \sqsubset T$ true is $(\mathsf{base}, \mathsf{ext})$, where $\text{rank}(\mathsf{base}) = 0 < 1 = \text{rank}(\mathsf{ext})$; all other cases discharge the hypothesis as false. $\qquad\blacksquare$

**Lemma 4.4 (`extension_monotone`, EM).** For all $S, T$, if $S \sqsubset T$ then $f(S) \le f(T)$.

*Proof sketch.* As above, only $(\mathsf{base}, \mathsf{ext})$ has $S \sqsubset T$, and there $f(\mathsf{base}) = 1 \le 2 = f(\mathsf{ext})$ by Lemmas 4.1–4.2. $\qquad\blacksquare$

**Lemma 4.5 (`base_mutates_to_ext`).** $\text{Mutation}(\mathsf{base}, \mathsf{ext})$ holds.

*Proof sketch.* We have $\mathsf{base} \sqsubset \mathsf{ext}$ by definition, and $f(\mathsf{base}) = 1 < 2 = f(\mathsf{ext})$ by Lemmas 4.1–4.2. $\qquad\blacksquare$

**Lemma 4.6 (`ext_maximal_fitness`).** $\text{MaxFitness}(\mathsf{ext})$.

*Proof sketch.* We must show $f(U) \le f(\mathsf{ext}) = 2$ for every $U$. For $U = \mathsf{base}$, $f(\mathsf{base}) = 1 \le 2$; for $U = \mathsf{ext}$, $f(\mathsf{ext}) = 2 \le 2$. $\qquad\blacksquare$

**Lemma 4.7 (`ext_rank_minimal_among_max`).** $\text{RankMinimalAmongMax}(\mathsf{ext})$.

*Proof sketch.* By Lemma 4.6, $\mathsf{ext}$ is maximal-fitness. For minimality of rank: let $U$ be any maximal-fitness theory. If $U = \mathsf{base}$, then $\text{MaxFitness}(\mathsf{base})$ would entail $f(\mathsf{ext}) \le f(\mathsf{base})$, i.e. $2 \le 1$, a contradiction; hence $\mathsf{base}$ is not maximal-fitness and the only such $U$ is $\mathsf{ext}$, for which $\text{rank}(\mathsf{ext}) \le \text{rank}(\mathsf{ext})$. $\qquad\blacksquare$

**Lemma 4.8 (`ext_terminal`).** $\text{Terminal}(\mathsf{ext})$.

*Proof sketch.* A mutation $\text{Mutation}(\mathsf{ext}, U)$ requires $\mathsf{ext} \sqsubset U$. But $\sqsubset$ has no edge out of $\mathsf{ext}$ (case analysis on $U$ makes the hypothesis false in every case), so no such $U$ exists. $\qquad\blacksquare$

**Lemma 4.9 (`ext_not_primitive`).** $\lnot\,\text{Primitive}(\mathsf{ext})$.

*Proof sketch.* Primitivity of $\mathsf{ext}$ would assert no $S$ with $S \sqsubset \mathsf{ext}$, but $\mathsf{base} \sqsubset \mathsf{ext}$ is a witness; hence $\mathsf{ext}$ is not primitive. $\qquad\blacksquare$

**Theorem 4.10 (`counterexample_to_maximal_fitness_primitive_claim`).** There exists a theory $T$ such that
$$\text{MaxFitness}(T)\ \wedge\ \text{RankMinimalAmongMax}(T)\ \wedge\ \text{Terminal}(T)\ \wedge\ \lnot\,\text{Primitive}(T).$$

*Proof sketch.* Take $T = \mathsf{ext}$ and combine Lemmas 4.6, 4.7, 4.8, and 4.9. $\qquad\blacksquare$

**Corollary 4.11 (Insufficiency).** Hypotheses (EM) and (WF) — verified in this model by Lemmas 4.4 and 4.3 — do not imply that maximal-fitness, rank-minimal, terminal theories are primitive. The conjecture of §3 is false.

## 5. Structural diagnosis

Why does the natural argument fail? Two confusions are at work.

**Local versus global optimality.** Terminality (Definition 2.9) is a *local* property: $T$ has no improving neighbor *above* it in $\sqsubset$. Primitivity (Definition 2.6) is a *global* property: $T$ has no element *below* it at all. The witness $\mathsf{ext}$ is a local maximum of fitness that nonetheless sits atop the proper sub-theory $\mathsf{base}$. Local terminality says nothing about global irreducibility; the proposed proof silently equates them.

**Direction of the fitness–order coupling.** Extension monotonicity (EM) permits fitness to *increase* along the order $\sqsubset$. With fitness and order co-oriented, the fitness optimum migrates *up* the order — toward maximal, hence non-primitive, elements — exactly the opposite of the bottom-seeking behavior the conjecture assumes. Well-founded descent (WF) controls only the *length* of descending chains; it places no constraint on *where* the fitness optimum lands.

In short, (EM) and (WF) constrain monotonicity and chain length but leave the optimum's reducibility entirely free.

## 6. A repair: parsimony-corrected optimality

The diagnosis pinpoints the missing ingredient. Replace (EM) by its converse:

- **(PAR) Parsimony:** $S \sqsubset T \Rightarrow f(T) \le f(S)$.

Under (PAR), fitness is non-increasing along extension, so smaller theories are at least as fit and the optimum is pulled *down* the order toward irreducible elements.

**Proposition 6.1 (Repaired claim, informal).** In a well-founded landscape satisfying (PAR), a maximal-fitness terminal theory is primitive and rank-minimal among maximal-fitness theories.

*Argument.* Suppose $T$ is maximal-fitness but not primitive, so some $S \sqsubset T$ exists. By (PAR), $f(T) \le f(S)$, and by maximality $f(S) \le f(T)$, so $f(S) = f(T)$ and $S$ is itself maximal-fitness. By (WF), $\text{rank}(S) < \text{rank}(T)$, so $T$ is not rank-minimal among maximal-fitness theories. Iterating, well-foundedness forces a primitive maximal-fitness element at the bottom of any descending chain. Thus the conclusion follows once the offending inequality is flipped. $\qquad\blacksquare$

In the two-theory model, (PAR) would require $f(\mathsf{ext}) \le f(\mathsf{base})$ — false as stated, which is *precisely why* the original model is a counterexample to the (EM)-based conjecture. Re-instantiating the same landscape with traits satisfying (PAR) (e.g. swapping the connection counts) crowns the primitive $\mathsf{base}$, confirming that the single inequality's direction is decisive.

## 7. Algorithms

Although the model is finite, the verification generalizes to arbitrary finite landscapes via the following decidable procedures.

**Algorithm A (Fitness evaluation).** Given traits, compute $f(T) = \text{connections}(T)\cdot\text{proofDensity}(T)/\text{axiomCount}(T)$ in exact rational arithmetic. $O(1)$ per theory.

**Algorithm B (Predicate checking on a finite landscape).** Given a finite set of theories with $\sqsubset$, rank, and traits: maximal fitness is checked by comparing $f(T)$ against the maximum over the landscape ($O(n)$); terminality by scanning outgoing $\sqsubset$-edges for a fitness increase ($O(\deg T)$); primitivity by scanning incoming $\sqsubset$-edges ($O(n)$); rank-minimality among maxima by an $O(n)$ pass over maximal-fitness theories. The full counterexample search over a landscape is $O(n^2)$ in the number of theories.

**Algorithm C (Counterexample search).** Enumerate theories; for each $T$ that is maximal-fitness, rank-minimal among maxima, and terminal, report it if non-primitive. The first hit witnesses the refutation. On the two-theory model this returns $\mathsf{ext}$ immediately.

## 8. Applications and discussion

The result is a methodological caution for any framework that derives *global structural* properties (irreducibility, minimality) from *local optimality* under a valuation. The pattern recurs widely: in optimization (local optima are not global), in search dynamics over discrete landscapes (fixed points need not be ground states), and in foundational modeling (a fittest theory need not be a simplest one). The model also doubles as a regression test: any proposed proof of an optimality-implies-irreducibility theorem must survive instantiation on this two-element landscape.

A philosophical corollary: under an extension-monotone fitness, there is no reason to expect a "simplest final theory" at the base of mathematics. Selection pressure points toward whatever the landscape rewards, and rich, well-connected extensions may dominate irreducible cores.

## 9. Future work

- **Parsimony-corrected theorems.** Formalize Proposition 6.1 in full generality and verify it against this landscape as the canonical regression test.
- **Order-theoretic abstraction.** Replace the concrete two-theory type with an arbitrary preorder equipped with a valuation into a linear order, proving the optimality/minimality interplay once and instantiating it.
- **Dynamics over larger landscapes.** Treat $\text{Mutation}$ as a discrete dynamical system; characterize fixed points and basins of attraction, exploiting that terminality is local while primitivity is global.
- **Quantitative separation.** Bound how far a maximal-fitness theory can be from primitive (rank gap, length of the $\sqsubset$-chain below it) as a function of the fitness increase along extensions, generalizing the rank-$1$ tip exhibited here to chains of length $n$.

## 10. Conclusion

A two-element model with elementary rational traits suffices to refute the claim that maximal-fitness limit theories must be primitive and rank-minimal. The hypotheses usually marshaled in support — extension monotonicity and well-founded rank descent — control monotonicity and chain length but not the optimum's reducibility, because terminality is local while primitivity is global, and fitness was permitted to climb the very order along which primitivity is sought. Flipping that single inequality, via a parsimony hypothesis, restores the conclusion. The smallest possible counterexample thus both demolishes the conjecture and prescribes its cure.
