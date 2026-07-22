# Deterministic Causal Loops, Fixed-Point Consistency, and Acyclic Branching Histories

**Aristotle**  
**July 22, 2026**

## Abstract

We present a minimal discrete mathematics of causal loops and branching timelines. A deterministic causal law is a map $f:X\to X$, and a closed orbit of positive period $p$ is a state $x$ satisfying $f^p(x)=x$. We distinguish this periodic closure from pointwise Novikov consistency, which requires every visited state $f^k(x)$, for $0\le k<p$, to be fixed by $f$. The central theorem proves that, on any nonempty deterministic closed orbit, pointwise consistency is equivalent to the presence of a fixed point on the orbit. The key mechanism is a collapse principle: one fixed point on a deterministic closed orbit forces the starting state, and hence the entire orbit, to equal that point. For idempotent laws satisfying $f^2=f$, every positive closed orbit collapses automatically.

Boolean negation provides a minimal grandfather-intervention model. It has no fixed point; odd-period closure is impossible; and every positive even period closes while remaining inconsistent. Thus periodicity alone is strictly weaker than self-consistency, and idempotence is essential to the automatic collapse result. We then replace history-overwriting by a finite-prefix branching model. An intervention appends an event to a finite history, producing a strict descendant. Strict descent is transitive and irreflexive, while distinct interventions produce incomparable sibling branches. These results supply precise criteria for distinguishing recurrence, equilibrium, contradiction, and branch creation. We conclude with algorithms, applications, limitations, and extensions to relational, probabilistic, temporal, and geometric models.

## 1. Introduction

Time-travel paradoxes are often expressed in narrative terms: an event causes an intervention that prevents the event itself. Their logical core, however, can be studied without assuming a physical mechanism for time travel. One needs only a space of event-states, a rule for causal succession, and a precise meaning of consistency.

The first challenge is terminological. A process may return to its starting state after several updates without being stable at any intermediate point. In dynamical systems, this is the distinction between a periodic orbit and an equilibrium. In discussions of causal loops, the same distinction separates mere closure from local self-consistency. A two-state system that alternates forever is periodic, but neither state survives one application of the rule. Calling such a loop “consistent” without qualification conceals the central issue.

We study two small models. The first is deterministic and cyclic. It describes causal succession by a function and treats a closed history as a periodic point. Within this model we impose a strong, pointwise version of Novikov consistency: every state encountered before closure must be fixed under the causal law. This definition makes the local requirement explicit and supports a complete characterization by fixed points.

The second model is branching rather than cyclic. A timeline is a finite sequence of events, and an intervention appends a new event. Ancestry is prefix inclusion. Because every intervention strictly increases length, causal descent is acyclic. This captures a minimal many-worlds intuition: the traveler does not overwrite the source history but creates a descendant history.

The purpose is not to claim a theory of relativistic spacetime. In particular, a closed timelike curve is a geometric object, whereas the consistency considered here is a property of a specified evolution law. The discrete results identify what can be concluded from deterministic dynamics and finite ancestry alone, and equally importantly, what cannot.

## 2. Deterministic causal dynamics

Let $X$ be a nonempty or empty set of possible event-states; no algebraic or topological structure is required. A **deterministic causal law** is a function

$$
f:X\to X.
$$

For $n\in\mathbb N$, write $f^n$ for the $n$-fold iterate, with $f^0$ the identity and $f^{n+1}=f\circ f^n$. The elementary composition rule is

$$
f^{m+n}(x)=f^m\bigl(f^n(x)\bigr).
$$

### 2.1. Closure, consistency, and fixed points

**Definition 2.1 (closed orbit).** Given $p\in\mathbb N$ and $x\in X$, the orbit from $x$ is closed after $p$ steps when

$$
f^p(x)=x.
$$

The main results concern positive periods $p>0$. Positivity is necessary because $f^0(x)=x$ for every state, so period zero carries no dynamical information.

**Definition 2.2 (pointwise Novikov consistency).** The length-$p$ orbit from $x$ is pointwise self-consistent when

$$
f\bigl(f^k(x)\bigr)=f^k(x)
$$

for every integer $k$ satisfying $0\le k<p$.

Thus every state listed in the finite orbit segment

$$
x,f(x),f^2(x),\ldots,f^{p-1}(x)
$$

must be stable under one further causal update.

**Definition 2.3 (fixed point on the loop).** The length-$p$ orbit from $x$ contains a fixed point when there is an index $k$ with $0\le k<p$ such that

$$
f\bigl(f^k(x)\bigr)=f^k(x).
$$

Definitions 2.2 and 2.3 differ only in quantifier: pointwise consistency requires stability at every visited state, whereas fixed-point existence requires stability at at least one visited state. On arbitrary finite sequences, the difference is substantial. Determinism and closure make it disappear.

### 2.2. Elementary fixed-point lemmas

**Lemma 2.4 (consistency supplies a fixed point).** Let $p>0$. If the length-$p$ orbit from $x$ is pointwise Novikov-consistent, then it contains a fixed point.

**Proof sketch.** The index $k=0$ lies in the range $0\le k<p$. Pointwise consistency at that index says $f(f^0(x))=f^0(x)$, which is exactly $f(x)=x$. Hence the starting state is already a fixed point. $\square$

This observation reflects the strength of the chosen consistency condition. It also motivates the converse starting from a fixed initial event.

**Lemma 2.5 (fixed start gives consistency).** If $f(x)=x$, then $f^n(x)=x$ for every $n\in\mathbb N$. Consequently, for every period $p$, the length-$p$ orbit from $x$ is pointwise Novikov-consistent.

**Proof sketch.** Induct on $n$. The case $n=0$ is immediate. If $f^n(x)=x$, then

$$
f^{n+1}(x)=f(f^n(x))=f(x)=x.
$$

Every visited state therefore equals $x$ and is fixed. $\square$

The next lemma uses closure to turn a fixed point encountered later into a fixed starting point.

**Lemma 2.6 (fixed-event collapse).** Suppose $f^p(x)=x$ and the orbit contains a fixed point $y=f^k(x)$ for some $0\le k<p$. Then $y=x$, $f(x)=x$, and every state on the orbit equals $x$.

**Proof sketch.** Since $f(y)=y$, induction gives $f^n(y)=y$ for every $n\ge0$. Because $k<p$, write $p=k+(p-k)$. Then

$$
f^p(x)=f^{p-k}(f^k(x))=f^{p-k}(y)=y.
$$

Closure says $f^p(x)=x$, so $x=y$. The fixed-point identity $f(y)=y$ becomes $f(x)=x$. Lemma 2.5 then makes every iterate equal to $x$. $\square$

The inequality $k<p$ matters only to ensure the orbit point is represented before closure and to make the decomposition by $p-k$ transparent. The argument expresses a general property of deterministic maps: once an orbit reaches a fixed point, it cannot leave; if that orbit must later return to its start, the start was the fixed point all along.

### 2.3. The fixed-point characterization

**Theorem 2.7 (Novikov fixed-point equivalence).** Let $p>0$ and suppose $f^p(x)=x$. The orbit from $x$ is pointwise Novikov-consistent if and only if it contains a fixed point.

**Proof sketch.** If the orbit is pointwise consistent, Lemma 2.4 supplies a fixed point. Conversely, if the orbit contains a fixed point, Lemma 2.6 shows that the starting state is fixed. Lemma 2.5 then gives pointwise consistency throughout the orbit. $\square$

**Corollary 2.8 (no mixed deterministic loop).** A positive closed orbit of a deterministic map cannot contain both a fixed state and a distinct moving state. If any visited state is fixed, the orbit is constant.

**Proof sketch.** Apply Lemma 2.6. $\square$

This is the main structural result. The phrase “the loop has a fixed point” may sound weaker than “every point is consistent,” but on a deterministic closed orbit it is not. A fixed event is absorbing, and closure forces the whole orbit into it.

## 3. Idempotent laws and automatic collapse

A particularly rigid class of causal laws settles after one update.

**Definition 3.1 (idempotent causal law).** A causal law $f:X\to X$ is idempotent if

$$
f(f(x))=f(x)
$$

for every $x\in X$.

Equivalently, $f^2=f$. Such maps include projections and canonicalization procedures. Their images consist entirely of fixed points.

**Lemma 3.2 (positive iterates are fixed).** If $f$ is idempotent, then for every $x\in X$ and every $n>0$,

$$
f^n(x)=f(x)
$$

and hence

$$
f(f^n(x))=f^n(x).
$$

**Proof sketch.** Write $n=m+1$. Starting from $f(x)$, every additional application of $f$ leaves the state unchanged by idempotence. An induction on $m$ yields $f^{m+1}(x)=f(x)$. Applying $f$ once more changes nothing. $\square$

**Theorem 3.3 (idempotent causal-loop collapse).** Let $f$ be idempotent, let $p>0$, and suppose $f^p(x)=x$. Then $f(x)=x$. The closed orbit is constant and pointwise Novikov-consistent.

**Proof sketch.** Lemma 3.2 says that $f^p(x)$ is fixed and, more specifically, equals $f(x)$. Closure gives $f^p(x)=x$. Therefore $f(x)=x$, and Lemma 2.5 completes the argument. $\square$

**Theorem 3.4 (three-way characterization under idempotence).** Under the hypotheses of Theorem 3.3, the following are equivalent:

1. the orbit is pointwise Novikov-consistent;
2. the starting state is fixed and the orbit contains a fixed point;
3. the starting state is fixed.

**Proof sketch.** Theorem 3.3 already gives the fixed-start condition from idempotence and closure. A consistent positive orbit contains a fixed point by Lemma 2.4. Conversely, a fixed start gives consistency by Lemma 2.5 and itself supplies a fixed point at index $0$. $\square$

Idempotence is sufficient rather than necessary for a particular closed orbit to collapse. A non-idempotent map may still have fixed points. Its importance is uniform: it ensures every state reaches a fixed point after one application, so no nontrivial positive cycle can occur anywhere.

## 4. The Boolean grandfather intervention

We now exhibit the sharp separation between periodic closure and self-consistency.

Let the state space be $B=\{0,1\}$. Interpret $1$ as “the ancestor survives” and $0$ as “the ancestor does not survive.” Define the intervention law $g:B\to B$ by

$$
g(a)=1-a.
$$

Thus each application reverses the survival status.

**Theorem 4.1 (absence of a self-consistent grandfather state).** There is no $a\in B$ satisfying $g(a)=a$.

**Proof sketch.** Directly, $g(0)=1\ne0$ and $g(1)=0\ne1$. These exhaust $B$. $\square$

**Lemma 4.2 (parity of iterated intervention).** For every $m\in\mathbb N$ and $a\in B$,

$$
g^{2m}(a)=a,
$$

while

$$
g^{2m+1}(a)=g(a)=1-a.
$$

**Proof sketch.** Two applications cancel: $g^2(a)=a$. Group an even iterate into $m$ pairs. An odd iterate is one flip followed by an even number of flips. $\square$

**Theorem 4.3 (odd-period no-go).** For every odd positive integer $p$ and every $a\in B$,

$$
g^p(a)\ne a.
$$

Hence no odd-period grandfather orbit closes.

**Proof sketch.** Write $p=2m+1$. Lemma 4.2 gives $g^p(a)=1-a$, which differs from $a$ for both Boolean states. $\square$

**Theorem 4.4 (even closure without consistency).** For every positive even integer $p$ and every $a\in B$, the orbit closes:

$$
g^p(a)=a.
$$

Nevertheless it is not pointwise Novikov-consistent. In particular, the two-step orbit closes but is inconsistent.

**Proof sketch.** Write $p=2m$ with $m>0$. Even closure follows from Lemma 4.2. Pointwise consistency would require stability at index $0$, namely $g(a)=a$, contradicting Theorem 4.1. $\square$

**Corollary 4.5 (non-idempotence).** The grandfather law is not idempotent.

**Proof sketch.** For either Boolean state, $g(g(a))=a$ while $g(a)=1-a$, so $g(g(a))\ne g(a)$. $\square$

These results precisely locate the paradox. The update rule is well-defined, deterministic, and periodic. What fails is the fixed-point equation demanded by local self-consistency. The two-step orbit $0\mapsto1\mapsto0$ is a closed cycle, but neither $0$ nor $1$ is stable. Thus any principle equating recurrence with consistency is false without additional hypotheses.

## 5. Finite branching histories

The preceding model sends states around a single deterministic orbit. A branching model instead treats a history as an immutable prefix that may have multiple continuations.

Let $E$ be a set of events. A **timeline** is a finite list

$$
H=[e_1,e_2,\ldots,e_n]
$$

with entries in $E$. Its length is denoted $|H|$. For lists $H$ and $R$, write $H\mathbin{+\!+}R$ for concatenation.

**Definition 5.1 (travel by extension).** Given a source timeline $H$ and an intervention $a\in E$, define the resulting timeline by

$$
T(H,a)=H\mathbin{+\!+}[a].
$$

**Definition 5.2 (ancestry).** A timeline $A$ is an ancestor of $B$ if $A$ is a prefix of $B$, meaning that there exists a finite list $R$ with

$$
B=A\mathbin{+\!+}R.
$$

**Definition 5.3 (strict descent).** A timeline $B$ is a strict descendant of $A$ if $A$ is an ancestor of $B$ and $A\ne B$.

The prefix relation is reflexive and transitive. Strict descent removes reflexivity and orients branch growth from a source toward a longer continuation.

**Lemma 5.4 (source preservation).** For every source $H$ and intervention $a$, the source $H$ is an ancestor of $T(H,a)$.

**Proof sketch.** Take the remainder list to be $[a]$ in Definition 5.2. $\square$

**Lemma 5.5 (unit length growth).** For every $H$ and $a$,

$$
|T(H,a)|=|H|+1.
$$

**Proof sketch.** List concatenation adds lengths, and the singleton list $[a]$ has length $1$. $\square$

**Theorem 5.6 (branch creation).** For every source $H$ and intervention $a$, $T(H,a)\ne H$, and $T(H,a)$ is a strict descendant of $H$.

**Proof sketch.** Equality would imply equal lengths, contradicting Lemma 5.5. Combine inequality with source preservation from Lemma 5.4. $\square$

**Theorem 5.7 (transitivity of strict descent).** If $B$ is a strict descendant of $A$ and $C$ is a strict descendant of $B$, then $C$ is a strict descendant of $A$.

**Proof sketch.** Prefix transitivity makes $A$ a prefix of $C$. Proper prefix extension strictly increases length: $|A|<|B|<|C|$. Therefore $A\ne C$. $\square$

**Theorem 5.8 (acyclicity).** No timeline is its own strict descendant. Consequently, no finite chain of strict branch extensions can return to its starting timeline.

**Proof sketch.** Self-descent would require a timeline both to equal and not equal itself. For a chain, repeated use of Theorem 5.7 would turn a return into self-descent. Equivalently, length strictly increases at every branch-creation step and therefore cannot return to its original value. $\square$

**Theorem 5.9 (distinct sibling creation).** If $a,b\in E$ and $a\ne b$, then

$$
T(H,a)\ne T(H,b).
$$

**Proof sketch.** If the appended lists were equal, cancellation of their common prefix $H$ would give $[a]=[b]$, hence $a=b$, a contradiction. $\square$

**Theorem 5.10 (sibling incomparability).** If $a\ne b$, neither $T(H,a)$ nor $T(H,b)$ is an ancestor of the other.

**Proof sketch.** Both children have length $|H|+1$. If one finite list is a prefix of another of equal length, the lists are equal. That contradicts Theorem 5.9. The argument is symmetric. $\square$

Theorems 5.6–5.10 define the core geometry of the branch model. Travel preserves the complete source history, adds one event, and produces a genuinely new child. Distinct interventions are not competing descriptions of one overwritten timeline; they are incomparable siblings sharing a common ancestor.

## 6. Algorithms and computational interpretation

The finite models support direct algorithms. Assume equality testing on states and events takes constant time unless noted otherwise.

### 6.1. Orbit audit

Given a finite-state update table for $f$, a start $x$, and a proposed positive period $p$, iterate the law $p$ times. Record whether each visited state $y$ satisfies $f(y)=y$, whether any visited state does, and whether the final state equals $x$.

The algorithm takes $O(p)$ time. If all $p$ visited states are retained, it uses $O(p)$ memory; if only the three Boolean audit flags are needed, it uses $O(1)$ auxiliary memory. On a closed deterministic orbit, Theorem 2.7 predicts equality between the “all fixed” and “some fixed” outcomes.

### 6.2. Idempotence audit

For a finite state space of size $N$, test $f(f(x))=f(x)$ for each state $x$. This takes $O(N)$ table lookups and $O(1)$ auxiliary space. If the test succeeds, every proposed positive closed orbit can be classified immediately as constant by Theorem 3.3.

### 6.3. Branch construction and comparison

Creating $T(H,a)$ conceptually appends one event. With immutable arrays or lists, construction may require $O(|H|)$ copying; with persistent linked structures, it can take $O(1)$ time while sharing the prefix. Testing whether two explicit arrays have a prefix relation takes $O(\min(|A|,|B|))$ time. Sibling incomparability is cheaper when metadata records a common parent and distinct final interventions.

These algorithms are demonstrations of the mathematics rather than physical simulations. Their role is to expose closure, fixed points, and ancestry in transparent finite examples.

## 7. Applications and conceptual connections

The fixed-point distinction appears in several fields.

In **dynamical systems**, a closed orbit is periodic, while a fixed point is an equilibrium. The Boolean grandfather model is the smallest nontrivial limit cycle. Theorem 2.7 is stronger than a generic dynamical statement because its consistency predicate requires every visited point to be an equilibrium.

In **distributed systems**, a global configuration may recur while component transitions continue to change local state. Detecting recurrence does not establish quiescence. Idempotent operations are especially important because retries do not create further changes; the collapse theorem is an abstract version of this stabilization property.

In **data processing**, normalization maps are often idempotent. Once data are canonicalized, repeating the transformation changes nothing. A closed workflow built only from one such deterministic normalization cannot support a nontrivial cycle through the same state.

In **version control and event sourcing**, immutable histories naturally form a prefix tree. A new commit or event extends a prior record. Distinct continuations from one parent are siblings, and ancestry is acyclic as long as histories are built by extension rather than destructive rewriting. The branch model abstracts exactly this pattern.

In **philosophy of time**, the analysis warns against deriving dynamical consistency from geometric or narrative closure. One must specify both the state space and the evolution law. Different choices produce different results: a negating law yields closed inconsistent cycles, an idempotent law collapses loops, and an append-only law replaces loops with branches.

## 8. Scope and limitations

The deterministic model is intentionally narrow. Pointwise Novikov consistency is a strong local condition: every state on the orbit must be fixed by one update. Other notions might require only that constraints around the entire cycle be jointly satisfiable. Under such relational semantics, a consistent cycle may contain changing states, and one fixed state need not collapse the rest.

The branching model records finite event lists but does not include probabilities, branch weights, merging, erasure, concurrency, or physical conservation laws. Its acyclicity follows from append-only growth. Allowing histories to merge or be rewritten would require new invariants.

Most importantly, no theorem here establishes that closed timelike curves exist or are self-consistent in a Gödel universe. A closed timelike curve belongs to Lorentzian geometry. Self-consistency requires an additional law for matter or information transported along that curve. A faithful treatment would define a spacetime manifold, a Lorentzian metric, timelike curves, the Gödel metric, and a dynamical relation on fields or particles. Only then could consistency be stated relative to that evolution. Geometric closure alone is insufficient.

## 9. Future research

A natural first extension replaces the function $f:X\to X$ by a relation $R\subseteq X\times X$. Nondeterministic causality permits several successors, so reaching a fixed state need not prevent another branch from leaving it. The hypotheses needed for a fixed-point equivalence then become nontrivial.

A second direction models local laws as constraints around a directed cycle. Global consistency becomes the existence of an assignment satisfying all edge constraints. Finite instances connect to constraint satisfaction, while compactness principles may address infinite causal networks.

A probabilistic version replaces states by distributions and deterministic updates by stochastic matrices or Markov kernels. The analogue of a fixed point is a stationary distribution. Finite-state existence is accessible by convex or algebraic methods; uniqueness requires assumptions such as irreducibility, aperiodicity, or contraction.

The branch model can be enlarged to rooted trees with explicit branch identities, common ancestry, least common ancestors, and controlled merge operations. The principal question is which merge policies preserve acyclicity and which reintroduce overwrite-like loops.

Temporal logic offers another bridge. Safety properties can be interpreted over finite prefixes, and one can ask which properties are preserved under branch extension. This links the append-only model to linear-time and branching-time modal logics.

Finally, the geometric boundary should be crossed carefully. A future theory combining Lorentzian geometry and matter evolution could distinguish a closed worldline from a globally consistent assignment of physical states along it. The present results suggest the correct order: define geometry, define dynamics, define consistency, and only then ask for existence.

## 10. Conclusion

A deterministic causal loop is a periodic orbit, but periodicity is not self-consistency. Under the pointwise Novikov condition studied here, a positive closed orbit is consistent exactly when it contains a fixed point. Determinism and closure make that fixed point decisive: once reached, it absorbs the future, and closure forces it to equal the start. Idempotent laws strengthen this into automatic collapse of every positive closed orbit.

Boolean negation shows why the distinctions matter. It has no fixed point, admits no odd closed orbit, and admits closed even orbits that remain inconsistent. The grandfather paradox is therefore represented not by a failure of iteration or recurrence, but by the absence of a solution to the fixed-point equation.

Branching histories provide a different resolution. Appending an intervention preserves the source as a prefix and creates a longer strict descendant. Strict descent is transitive and irreflexive; distinct interventions create incomparable siblings. The resulting causal structure is a tree-like order rather than a loop.

These small theorems offer a disciplined vocabulary for larger theories. Closure is recurrence. Consistency is a constraint. A fixed point is equilibrium. Branching is extension without overwrite. Keeping those notions separate turns a family of time-travel stories into a clear mathematics of maps, cycles, and histories.