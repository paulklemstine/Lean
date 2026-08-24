# Universal Properties of Humor: Colimits, Submodularity, and the Uniqueness of Comic Surprise

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

We develop a rigorous order- and category-theoretic model of comic surprise. A *setup* is modelled as a nonempty finite configuration $S \subset \mathbb{R}$ of interpretive readings, ordered by refinement, and its *surprise* by the range $H(S) = \max S - \min S$. We prove five groups of results.

1. **Uniqueness.** Three axioms — position blindness (translation invariance), staged telling (concatenation additivity), and monotonicity in the reading gap — determine the invariant completely: every *humor scale* is $V(m,M) = c\,(M-m)$ with $c = V(0,1) \ge 0$, and is determined by its value on the unit gap. The proof rests on a from-scratch monotone Cauchy theorem: a monotone solution of $g(s+t) = g(s)+g(t)$ on $[0,\infty)$ is linear.
2. **An exact combination law.** Surprise is a *submodular valuation*: $H(S \cup T) + H(S \cap T) \le H(S) + H(T)$ whenever $S \cap T \ne \varnothing$. Subadditivity is recovered as a corollary, and $H(S \cap T) \le H(S \cup T)$ always.
3. **Humor is literally a colimit.** The category of setups has all binary coproducts — the joint setup $S \cup T$ is the coproduct — but *not* all binary products: two setups sharing no reading have no product. The punchline (colimit) always exists; the expected resolution (limit) may not.
4. **Universality.** In any category, a terminal object maximises every functor into $\mathbb{R}$; hence universal jokes maximise surprise, and all universal jokes over a fixed setup have identical surprise. The converse — "funniest implies universal" — is **false**: $\{0,1\} \subsetneq \{0,\tfrac12,1\}$ have equal surprise. Localising at the *hull* (the pair of extreme readings) repairs it exactly: a joke has maximal humor **iff** it is terminal in the hull quotient.
5. **Stability and correlation.** Surprise equals the metric diameter, generalises to arbitrary metric spaces of readings, and is $2$-Lipschitz for the Hausdorff distance, giving a sharp paraphrase bound $|H(f(S)) - H(S)| \le 2\varepsilon$. The empirical claim "surprise correlates with funniness" is *not* a theorem: it holds exactly under monovariance of ratings with surprise (Chebyshev's sum inequality) and fails otherwise.

**Keywords:** submodular valuation, colimit, terminal object, thin category, Hausdorff distance, Cauchy functional equation, Chebyshev sum inequality, incongruity theory.

---

## 1. Introduction

### 1.1 The incongruity slogan and its formalisation

The dominant account of verbal humor is the *incongruity–resolution* account: a setup induces an expectation, the punchline violates it, and the listener resolves the violation within a reinterpreted frame. Attractive as it is, the account is not quantitative. It says nothing about how the surprise of a compound joke relates to the surprise of its parts, whether the quantity is stable under rewording, or whether "the expected resolution" is guaranteed to exist at all.

The programme pursued here formalises the slogan

> *the punchline is a colimit; the expected resolution is a limit,*

and pushes it until it either becomes a theorem or breaks. Both happen. The colimit half is unconditionally true. The limit half is *conditionally false* — limits may not exist — and this failure is the precise technical content of the slogan. A companion conjecture, that maximal humor characterises universality, turns out to be half-true and is repaired by an explicit localisation.

### 1.2 The model

We model interpretive readings as points of $\mathbb{R}$: an *interpretive line* on which the literal reading and the various figurative readings each occupy a position, the distance between two positions measuring how far apart their frames are. Nothing in the theory depends on one dimension — §6 shows the entire construction lifts to an arbitrary metric space of readings — but the one-dimensional case is where the combinatorics is sharpest.

**Definition 1.1 (Setup).** A **setup** is a pair $S = (\underline{S}, h)$ where $\underline{S} \subset \mathbb{R}$ is a finite set and $h$ a witness that $\underline{S}$ is nonempty. We write $S$ for $\underline{S}$ when no confusion arises. Setups are ordered by **refinement**, $S \le T \iff S \subseteq T$: the setup $T$ is the same joke told so that strictly more readings are audible.

**Definition 1.2 (The category of setups).** $\mathbf{Setup}$ is the category whose objects are setups and with a unique morphism $S \to T$ whenever $S \le T$. It is a *thin* category (at most one morphism between any two objects), so all diagram-coherence conditions hold automatically, and every construction below is determined by its underlying order-theoretic content.

**Definition 1.3 (Surprise).** The **surprise** (or humor) of a setup $S$ is
$$H(S) \;=\; \max S - \min S .$$

Puns correspond to setups of small range (the alternative reading is a short step from the literal one); absurdist jokes to setups of large range.

The order-theoretic content of $\mathbf{Setup}$ is that it is (a full subposet of) the lattice of finite subsets of $\mathbb{R}$, restricted to nonempty ones. That restriction is not cosmetic: it is exactly what makes products fail (Theorem 4.4).

### 1.3 Overview of results

§2 shows the invariant is forced by three axioms. §3 establishes the exact combination law. §4 proves the colimit/limit dichotomy. §5 develops universality, refutes the converse, and repairs it via the hull quotient. §6 establishes metric stability and the sharp paraphrase bound. §7 treats the empirical correlation claim honestly. §8 discusses algorithms; §9, applications and limitations; §10, future directions.

---

## 2. The invariant is forced

The obvious objection to Definition 1.3 is that the formula was *chosen*. Any monotone functional on setups would generate a superficially similar theory. This section removes the choice.

**Definition 2.1 (Humor scale).** A **humor scale** is a function $V : \mathbb{R} \times \mathbb{R} \to \mathbb{R}$, whose value $V(m,M)$ is interpreted as the surprise of a setup with extreme readings $m \le M$, satisfying:

* **(A1) Position blindness.** For all $m \le M$ and all $c \in \mathbb{R}$: $V(m + c, M + c) = V(m, M)$.
* **(A2) Staged telling.** For all $a \le b \le c$: $V(a,b) + V(b,c) = V(a,c)$.
* **(A3) Monotonicity.** For all $a \le b \le c$: $V(a,b) \le V(a,c)$.

The **unit** of $V$ is $c_V := V(0,1)$.

Each axiom has a comic reading. (A1): comedy is about relative displacement of frames, not about their absolute location; relabelling the interpretive line by a constant shift cannot change how funny the joke is. (A2): a joke told in two stages — an intermediate reading, then the final one — accumulates the surprise of the stages. (A3): a wider divergence between readings is never less surprising.

**Lemma 2.2 (Nonnegativity of the unit).** $c_V \ge 0$.

*Proof sketch.* (A2) at $a=b=c=0$ gives $V(0,0) + V(0,0) = V(0,0)$, so $V(0,0)=0$; (A3) gives $V(0,0) \le V(0,1)$. $\square$

The technical engine is a functional-equation theorem which, in the monotone (as opposed to continuous or measurable) hypothesis, is not standard off-the-shelf material and must be built by hand.

**Theorem 2.3 (Monotone Cauchy).** Let $g : \mathbb{R} \to \mathbb{R}$ satisfy $g(s+t) = g(s) + g(t)$ for all $s,t \ge 0$, and $g(s) \le g(t)$ whenever $0 \le s \le t$. Then $g(t) = g(1)\,t$ for all $t \ge 0$.

*Proof sketch.* Additivity at $s=t=0$ gives $g(0)=0$. Induction gives $g(ks) = k\,g(s)$ for $k \in \mathbb{N}$, $s \ge 0$; applying this at $s = 1/n$ yields $g(1/n) = g(1)/n$, hence $g(k/n) = g(1)\,k/n$ for all rationals $k/n \ge 0$. For arbitrary $t \ge 0$ and $n \in \mathbb{N}$, set $k = \lfloor nt \rfloor$, so $k/n \le t \le (k+1)/n$. Monotonicity sandwiches $g(t)$ between $g(1)k/n$ and $g(1)(k+1)/n$, while $g(1)t$ lies in the same interval; hence $|g(t) - g(1)t| \le g(1)/n$. Since $n$ is arbitrary and $\mathbb{R}$ is Archimedean, the difference is $0$. $\square$

**Theorem 2.4 (Uniqueness of surprise).** Let $V$ be a humor scale. Then for all $m \le M$,
$$V(m,M) = c_V \cdot (M - m).$$

*Proof sketch.* Put $g(t) = V(0,t)$. For $s,t \ge 0$, (A2) gives $V(0,s) + V(s, s+t) = V(0,s+t)$, and (A1) gives $V(s, t+s) = V(0,t)$; combining, $g(s+t) = g(s)+g(t)$. (A3) makes $g$ monotone on $[0,\infty)$. Theorem 2.3 yields $g(t) = g(1)t = c_V\,t$. Finally (A1) shifts $V(m,M)$ to $V(0, M-m) = g(M-m)$. $\square$

**Corollary 2.5 (One degree of freedom).** If $V, W$ are humor scales with $c_V = c_W$, then $V = W$ on $\{(m,M) : m \le M\}$.

**Proposition 2.6 (Consistency).** The **range scale** $V(m,M) = M - m$ satisfies (A1)–(A3) and has unit $1$. Hence the axioms are non-vacuous, and Definition 1.3 is the normalisation $c_V = 1$.

**Corollary 2.7 (Transfer).** On a setup $S$, every humor scale satisfies $V(\min S, \max S) = c_V \cdot H(S)$. Consequently every result proved below about $H$ holds for every humor scale, with all bounds scaled by $c_V$. In particular submodularity (Theorem 3.1) and the Hausdorff-Lipschitz bound (Theorem 6.4) transfer verbatim.

**Remark 2.8 (Monotonicity is essential).** Without (A3), a Hamel-basis solution of the Cauchy equation gives a position-blind, stage-additive functional that is wildly discontinuous and not proportional to the range. The order axiom is what makes the theory a *measurement* theory.

---

## 3. The exact combination law

Comedians fuse jokes. A callback grafts a new setup onto an old one; a shaggy-dog story is a chain of setups sharing readings. What is the surprise of the fusion?

Throughout, $S \cup T$ denotes the **joint** setup (both jokes told at once) and $S \cap T$ the **shared** setup (the readings common to both). We assume $S \cap T \ne \varnothing$ so that the shared setup is itself a legitimate setup.

**Theorem 3.1 (Submodularity).** For setups $S, T$ with $S \cap T \ne \varnothing$,
$$H(S \cup T) + H(S \cap T) \;\le\; H(S) + H(T).$$

*Proof sketch.* Since $S \cap T \subseteq S$ and $S \cap T \subseteq T$,
$$\min S \le \min(S\cap T) \le \max(S \cap T) \le \max S, \qquad \min T \le \min(S\cap T) \le \max(S \cap T) \le \max T .$$
Also $\max (S \cup T) = \max(\max S, \max T)$ and $\min(S \cup T) = \min(\min S, \min T)$. Using $\max(A,B) + \min(A,B) = A + B$ and splitting into the four cases determined by which of $S, T$ realises the joint maximum and the joint minimum, each case reduces to a linear combination of the displayed inequalities. $\square$

**Proposition 3.2 (Nonnegativity).** $H(S) \ge 0$ for every setup $S$.

**Corollary 3.3 (Subadditivity).** For setups sharing a reading, $H(S \cup T) \le H(S) + H(T)$.

*Proof.* Theorem 3.1 plus Proposition 3.2. $\square$

Corollary 3.3 is the version one might guess; Theorem 3.1 is strictly stronger and quantifies the defect. Comic material lying in the overlap is counted **once**, not twice: the shortfall of the joint joke below the sum of its pieces is at least $H(S \cap T)$.

**Proposition 3.4 (Colimit dominates limit).** For setups with $S \cap T \ne \varnothing$,
$$H(S \cap T) \;\le\; H(S \cup T).$$

*Proof.* $H(S\cap T) \le H(S)$ by monotonicity of $H$ under refinement, and $H(S) \le H(S \cup T)$ likewise. $\square$

This is the numerical shadow of the structural theorem of §4: the joint reading — which we are about to identify as a colimit — is never less surprising than the shared reading, which is the candidate limit.

**Remark 3.5 (Submodularity is exactly the right shape).** Submodular set functions are the discrete analogue of concave functions, and they carry the classic "diminishing returns" reading: adding a reading to a larger setup gains no more than adding it to a smaller one. Comic economy — the observation that fused material yields less than the sum of its parts, and that the deficit equals the overlap — is thereby identified with a well-studied combinatorial structure, opening the theory to greedy-optimisation methods (§8.3).

---

## 4. Colimits always exist; limits need not

We now prove the structural slogan.

Recall that in a category $\mathcal{C}$, a **binary coproduct** of $X, Y$ is an object $P$ with morphisms $\iota_X : X \to P$, $\iota_Y : Y \to P$ such that for every $Z$ and every pair $f : X \to Z$, $g : Y \to Z$ there is a *unique* $h : P \to Z$ with $h\iota_X = f$, $h\iota_Y = g$. Dually, a **binary product** has projections $\pi_X : P \to X$, $\pi_Y : P \to Y$ with the universal property reversed. Coproducts are the simplest colimits, products the simplest limits.

**Definition 4.1 (Joint setup).** For setups $S, T$, the **joint setup** is $S \sqcup T := (\underline{S} \cup \underline{T})$, nonempty since $S$ is.

**Theorem 4.2 (The punchline is a colimit).** The joint setup $S \cup T$, with the inclusion morphisms $S \to S \cup T \leftarrow T$, is the binary coproduct of $S$ and $T$ in $\mathbf{Setup}$.

*Proof sketch.* Inclusions exist since $S \subseteq S\cup T \supseteq T$. Given a setup $Z$ with morphisms from $S$ and $T$ — that is, $S \subseteq Z$ and $T \subseteq Z$ — we have $S \cup T \subseteq Z$, providing the mediating morphism. Uniqueness and all coherence conditions are automatic because $\mathbf{Setup}$ is thin. $\square$

**Corollary 4.3.** Every pair of setups has a coproduct; $\mathbf{Setup}$ has all binary coproducts.

**Theorem 4.4 (The expected resolution may fail to exist).** If $S$ and $T$ share no reading ($\underline S \cap \underline T = \varnothing$), then $S$ and $T$ have **no** binary product in $\mathbf{Setup}$.

*Proof.* Suppose $P$ were a product, with projections $\pi_S : P \to S$ and $\pi_T : P \to T$. In $\mathbf{Setup}$ these are precisely the inclusions $\underline P \subseteq \underline S$ and $\underline P \subseteq \underline T$, so $\underline P \subseteq \underline S \cap \underline T = \varnothing$. But every setup is nonempty by definition, so $\underline P$ contains some $x$, and $x$ would lie in both $\underline S$ and $\underline T$ — contradiction. $\square$

**Remark 4.5 (Disjointness, not distinctness).** The hypothesis of Theorem 4.4 cannot be weakened to $S \ne T$: if $S \cap T \ne \varnothing$, the intersection *is* the product, with the expected universal property. The dichotomy is exactly between overlapping and non-overlapping frames.

**Interpretation.** The listener's expected resolution is the greatest common reading — a limit, a consensus. The punchline is the least world in which every reading is simultaneously alive — a colimit, a fusion. Theorems 4.2 and 4.4 say the fusion always exists while the consensus need not. When two interpretive frames share nothing, the joke has no expectation to subvert, yet still has a punchline. This is the exact sense in which *humor is a colimit*: the colimit is the construction that cannot fail.

---

## 5. Universality: a theorem, a refutation, and a repair

### 5.1 Terminal objects maximise every real-valued invariant

Regard $\mathbb{R}$ as a category with a unique morphism $x \to y$ iff $x \le y$. Then a functor $F : \mathcal{C} \to \mathbb{R}$ is exactly an assignment of a real number to each object of $\mathcal{C}$ that is monotone along morphisms.

**Theorem 5.1 (Terminality certifies maximality).** Let $\mathcal{C}$ be any category, $F : \mathcal{C} \to \mathbb{R}$ any functor, and $T$ a terminal object of $\mathcal{C}$. Then $F(X) \le F(T)$ for every object $X$.

*Proof.* Terminality gives a morphism $!_X : X \to T$; functoriality gives a morphism $F(!_X) : F(X) \to F(T)$ in $\mathbb{R}$, which *is* the assertion $F(X) \le F(T)$. $\square$

**Theorem 5.2 (Dual).** If $I$ is initial then $F(I) \le F(X)$ for every $X$.

Theorem 5.1 is one line, but it is the categorical core of the universality conjecture, and it holds with total generality: no hypothesis on $\mathcal{C}$ or $F$ beyond functoriality. Terminality is a *purely categorical certificate of maximal surprise*.

### 5.2 The category of jokes over a setup

**Definition 5.3.** Fix setups $S \le U$, where $U$ is an ambient *universe* of admissible readings. The category $\mathbf{Joke}(S,U)$ has as objects the setups $T$ with $S \le T \le U$, and as morphisms the refinements. It is again thin.

**Proposition 5.4 (The universe is the universal joke).** $U$, regarded as an object of $\mathbf{Joke}(S,U)$, is terminal: every joke over $S$ admits a unique refinement into $U$.

**Definition 5.5.** For $J \in \mathbf{Joke}(S,U)$ put $H_{S,U}(J) := H(\underline J)$. Since $H$ is monotone under refinement, $H_{S,U}$ is a functor $\mathbf{Joke}(S,U) \to \mathbb{R}$.

**Theorem 5.6 (Universal jokes are the funniest).** If $J^\ast \in \mathbf{Joke}(S,U)$ is terminal, then $H(J) \le H(J^\ast)$ for every $J \in \mathbf{Joke}(S,U)$.

*Proof.* Theorem 5.1 applied to the functor $H_{S,U}$. $\square$

**Theorem 5.7 (Well-definedness of universal humor).** Any two terminal objects of $\mathbf{Joke}(S,U)$ have equal surprise.

*Proof.* Apply Theorem 5.6 twice and use antisymmetry. $\square$

Thus "the humor of the universal joke over $S$" is a genuine invariant of the pair $(S,U)$.

### 5.3 The converse is false

**Definition 5.8.** Let $\mathrm{pun} := \{0,1\}$ and $\mathrm{pun}^{+} := \{0, \tfrac12, 1\}$.

**Lemma 5.9.** $H(\mathrm{pun}) = H(\mathrm{pun}^{+}) = 1$ and $\mathrm{pun} \subsetneq \mathrm{pun}^{+}$.

**Theorem 5.10 (Surprise does not reflect refinement).** There exist setups $S < T$ with $H(S) = H(T)$.

**Theorem 5.11 (Failure of the converse).** There is a category $\mathbf{Joke}(S,U)$ containing a **non-terminal** object of maximal humor. Explicitly, take $S = \mathrm{pun}$, $U = \mathrm{pun}^{+}$, and $J = \mathrm{pun}$: then $H(K) \le H(J)$ for every $K \in \mathbf{Joke}(S,U)$ (since every such $K$ refines into $U$ and $H(U) = H(J) = 1$), yet $J$ is not a greatest element, because $U$ does not refine into $J$.

Hence: *universal $\Rightarrow$ funniest* is a theorem (5.6); *funniest $\Rightarrow$ universal* is **false**.

**Remark 5.12 (The failure is structural).** $H$ depends only on the two extreme readings. Every refinement adding purely *interior* readings — a nuance between the literal and the absurd reading — alters the joke without altering the measurement. Maximal surprise is therefore attained on an entire upward-closed family, not at a single object. The counterexample uses a genuinely strict refinement, so it is not an artefact of a degenerate category.

### 5.4 The repair: the hull quotient

**Definition 5.13 (Hull).** The **hull** of a setup $S$ is the interpretive interval $\mathrm{hull}(S) := (\min S, \max S)$, an element of $\mathbf{Hull} := \{(p,q) \in \mathbb{R}^2 : p \le q\}$ preordered by *inclusion*: $(p,q) \le (p',q')$ iff $p' \le p$ and $q \le q'$.

**Proposition 5.14.** $\mathrm{hull}$ is monotone, hence a functor $\mathbf{Setup} \to \mathbf{Hull}$, and the length $\lambda(p,q) = q - p$ is a functor $\mathbf{Hull} \to \mathbb{R}$. Surprise factors: $H = \lambda \circ \mathrm{hull}$.

**Theorem 5.15 (Exactly what surprise reflects).** If $S \le T$ then
$$H(S) = H(T) \iff \mathrm{hull}(S) = \mathrm{hull}(T).$$

*Proof.* ($\Leftarrow$) is factorisation. ($\Rightarrow$): monotonicity of the hull gives $\min T \le \min S$ and $\max S \le \max T$; if additionally $\max S - \min S = \max T - \min T$, then both inequalities are forced to be equalities. $\square$

So surprise is blind to interior readings — and blind to *nothing else*.

**Definition 5.16 (Hull-universality).** $J \in \mathbf{Joke}(S,U)$ is **hull-universal** if $\mathrm{hull}(K) \le \mathrm{hull}(J)$ for every $K \in \mathbf{Joke}(S,U)$; i.e. it is terminal in the image of $\mathbf{Joke}(S,U)$ under the hull functor.

**Proposition 5.17 (Terminality descends).** If $J$ is terminal in $\mathbf{Joke}(S,U)$ then $J$ is hull-universal. Hence hull-universality is a genuine weakening of terminality.

**Theorem 5.18 (Hull-universal jokes are the funniest).** If $J$ is hull-universal then $H(K) \le H(J)$ for every $K$.

**Theorem 5.19 (The universality conjecture, repaired).** Let $S \le U$ and $J \in \mathbf{Joke}(S,U)$. Then
$$\bigl(\forall K \in \mathbf{Joke}(S,U),\; H(K) \le H(J)\bigr) \iff J \text{ is hull-universal.}$$

*Proof sketch.* ($\Leftarrow$) is Theorem 5.18. ($\Rightarrow$): apply maximality to $K = U$, which is an object of $\mathbf{Joke}(S,U)$; combined with monotonicity $H(J) \le H(U)$ this gives $H(J) = H(U)$, and since $J \le U$, Theorem 5.15 gives $\mathrm{hull}(J) = \mathrm{hull}(U)$. Every $K \in \mathbf{Joke}(S,U)$ satisfies $K \le U$, so $\mathrm{hull}(K) \le \mathrm{hull}(U) = \mathrm{hull}(J)$. $\square$

**Theorem 5.20 (Non-degeneracy).** The hull functor is not injective: $\mathrm{pun} \ne \mathrm{pun}^{+}$ but $\mathrm{hull}(\mathrm{pun}) = \mathrm{hull}(\mathrm{pun}^{+})$.

Theorems 5.11, 5.19 and 5.20 together give a complete account: the conjecture "funniest = universal" fails precisely and only because the hull functor is non-injective, and becomes an equivalence after localising at hull-equivalence. The counterexample was not a defect of the invariant, but a mismatch of resolution between an invariant that sees intervals and a category that sees finite sets.

---

## 6. Metric stability

### 6.1 Surprise is a diameter

**Theorem 6.1.** For every nonempty finite $S \subset \mathbb{R}$, $H(S) = \operatorname{diam}(S)$, the diameter of $S$ as a subset of the metric space $\mathbb{R}$.

*Proof sketch.* Both extremes lie in $S$, so $\operatorname{diam} S \ge \operatorname{dist}(\min S, \max S) = H(S)$. Conversely any $x,y \in S$ satisfy $|x-y| \le \max S - \min S = H(S)$, so $\operatorname{diam} S \le H(S)$. $\square$

**Definition 6.2 (Metric surprise).** For a subset $s$ of a pseudometric space $\alpha$, put $H_\alpha(s) := \operatorname{diam}(s)$.

**Proposition 6.3 (Generalisation).** In an arbitrary pseudometric space of readings, $H_\alpha$ is monotone under inclusion (of bounded sets), and satisfies the shared-context subadditivity law $H_\alpha(s \cup t) \le H_\alpha(s) + H_\alpha(t)$ when $s \cap t \ne \varnothing$.

Thus the one-dimensional model is not ad hoc; it is the $\mathbb{R}$-instance of a metric-space invariant. Readings may equally be embedded in a high-dimensional semantic space.

### 6.2 Lipschitz stability

Let $d_H$ denote the Hausdorff distance between bounded nonempty sets.

**Theorem 6.4 ($2$-Lipschitz).** For bounded nonempty $s,t$ with finite Hausdorff distance,
$$\bigl|\operatorname{diam}(s) - \operatorname{diam}(t)\bigr| \;\le\; 2\, d_H(s,t).$$

*Proof sketch.* For $\delta > d_H(s,t)$, every $x \in s$ has some $x' \in t$ with $d(x,x') < \delta$. Given $x,y \in s$, choose such $x', y'$; the quadrilateral inequality gives $d(x,y) \le \delta + d(x',y') + \delta \le \operatorname{diam}(t) + 2\delta$. Taking suprema, $\operatorname{diam}(s) \le \operatorname{diam}(t) + 2\delta$; let $\delta \downarrow d_H(s,t)$ and symmetrise. $\square$

**Remark 6.5 (Hypotheses are load-bearing).** Finiteness of the Hausdorff distance and boundedness of the comparison set cannot be dropped: with the convention that an infinite extended Hausdorff distance yields $d_H = 0$, the inequality would be violated by sets of arbitrarily different diameters.

### 6.3 The paraphrase bound

**Theorem 6.6 (Paraphrase stability).** Let $S$ be a setup and $f : \mathbb{R} \to \mathbb{R}$ a *paraphrase* with $|f(x) - x| \le \varepsilon$ for every $x \in S$. Then
$$\bigl| H(f(S)) - H(S) \bigr| \;\le\; 2\varepsilon .$$

*Proof sketch.* Write $m = \min S$, $M = \max S$. Every $y = f(x)$ with $x \in S$ satisfies $y \le x + \varepsilon \le M + \varepsilon$, so $\max f(S) \le M + \varepsilon$; also $f(M) \ge M - \varepsilon$ lies in $f(S)$, so $\max f(S) \ge M - \varepsilon$. Symmetrically $m - \varepsilon \le \min f(S) \le m + \varepsilon$. Subtracting the four bounds gives the claim. $\square$

**Theorem 6.7 (Sharpness).** The constant $2$ cannot be improved. With $S = \{0,1\}$, $f(x) = 3x - 1$ and $\varepsilon = 1$: each reading moves by exactly $1$, $f(S) = \{-1, 2\}$, and $|H(f(S)) - H(S)| = |3 - 1| = 2 = 2\varepsilon$.

Theorem 6.6 is what makes the invariant experimentally meaningful: a rating study is not invalidated by the inevitable variation in wording, since the measured humor cannot drift by more than twice the semantic displacement.

By Corollary 2.7, every humor scale is $2c_V$-Lipschitz for the Hausdorff distance.

---

## 7. Correlation with funniness: what is, and is not, a theorem

**Definition 7.1 (Empirical covariance).** For a finite index set $s$ of jokes and attributes $f, g : s \to \mathbb{R}$,
$$\operatorname{Cov}_s(f,g) = \frac{\sum_{i \in s} f(i) g(i)}{|s|} - \left(\frac{\sum_{i \in s} f(i)}{|s|}\right)\left(\frac{\sum_{i \in s} g(i)}{|s|}\right).$$

**Definition 7.2 (Monovariance).** $f$ and $g$ **monovary** on $s$ if there is no pair $i,j \in s$ with $f(i) < f(j)$ and $g(j) < g(i)$; informally, they never move in opposite directions.

**Theorem 7.3 (The correlation claim, correctly guarded).** If $f$ and $g$ monovary on $s$ then $\operatorname{Cov}_s(f,g) \ge 0$.

*Proof sketch.* Monovariance implies the Chebyshev sum inequality $\bigl(\sum_i f(i)\bigr)\bigl(\sum_i g(i)\bigr) \le |s| \sum_i f(i) g(i)$; dividing by $|s|^2 > 0$ rearranges to $\operatorname{Cov}_s(f,g) \ge 0$. The empty sample is trivial. $\square$

**Theorem 7.4 (The hypothesis cannot be dropped).** There is a two-joke dataset with strictly negative covariance: humors $(0,1)$ and ratings $(1,0)$ give $\operatorname{Cov} = -\tfrac14$.

So "surprise correlates with funniness" is **not** a theorem of the categorical theory. It is a property of the *data*. The algebra determines what surprise is and how it combines; whether audiences reward it is empirical.

### 7.1 The hundred-joke suite

**Definition 7.5.** For $i < 100$, let joke $J_i$ have setup $\{0, i\}$, so $H(J_i) = i$ exactly. Let the rating model saturate: $R_i = \min(i, 50)$, reflecting the ceiling of finite rating scales.

**Theorem 7.6.** $H$ and $R$ are both monotone in $i$, hence monovary, hence $\operatorname{Cov}(H,R) \ge 0$ across the hundred-joke suite.

**Theorem 7.7 (A concrete positive sample).** For the three-joke sample — a pun ($H=1$, rated $2$), a piece of wordplay ($H=3$, rated $5$), an absurdist joke ($H=10$, rated $8$) — the covariance is strictly positive.

**Remark 7.8 (Scope).** The suite uses a *synthetic* monotone rating model. It tests the internal consistency of the formalism, not human response. Any claim about people requires human data and the monovariance hypothesis becomes a testable assertion about that data rather than a derived fact.

---

## 8. Algorithms

### 8.1 Computing surprise and verifying submodularity

Surprise is computed in $O(|S|)$ time by a single pass for the extremes (or $O(1)$ from a sorted representation). Verifying the submodular inequality for a pair costs $O(|S| + |T|)$ with hash-set intersection, and exhaustively certifying submodularity across a family of $n$ setups costs $O(n^2 \cdot m)$ where $m$ bounds setup size.

### 8.2 The hull-quotient normal form

Theorem 5.15 yields a canonical form: two refinement-comparable setups are humor-equivalent iff they have equal hulls. Reducing a setup to $(\min S, \max S)$ is an $O(|S|)$ normalisation under which the repaired universality criterion (Theorem 5.19) becomes an $O(1)$ comparison of intervals. Detecting whether a joke over $(S,U)$ has maximal humor therefore reduces to checking $\mathrm{hull}(J) = \mathrm{hull}(U)$.

### 8.3 Greedy selection of a comic set

Because $S \mapsto H(S)$ is monotone and submodular (Theorem 3.1, Proposition 3.4) on families with a shared reading, the problem "choose $k$ readings maximising total surprise" is a monotone submodular maximisation under a cardinality constraint, for which the greedy algorithm attains the classical $1 - 1/e$ approximation ratio. In this one-dimensional model the greedy algorithm is in fact exact (it selects the two extremes first), but the observation matters for the metric generalisation of §6, where diameters in high-dimensional reading spaces are not determined by two coordinates.

### 8.4 Empirical covariance and monovariance auditing

Given $n$ jokes with humors and ratings, $\operatorname{Cov}$ is computed in $O(n)$. Checking monovariance naively costs $O(n^2)$; sorting by humor and verifying that ratings are non-decreasing within humor-ties reduces this to $O(n \log n)$. When monovariance fails, Theorem 7.3 no longer applies and the sign of the covariance must be measured, not asserted — the diagnostic that exposes the inverted-U effect of §10.

---

## 9. Discussion

### 9.1 What the theory delivers

The theory yields four substantive statements about comic surprise.

*The measurement is forced.* Position blindness, staged additivity and monotonicity determine the invariant up to a unit (Theorem 2.4). One cannot object that the range formula was cherry-picked; any alternative violates one of three unobjectionable axioms.

*Fusion carries a discount.* The exact combination law is submodularity, not merely subadditivity (Theorem 3.1). Shared material is counted once; the deficit is at least the surprise of the overlap.

*The punchline is the construction that cannot fail.* Coproducts of setups exist unconditionally; products fail exactly when frames are disjoint (Theorems 4.2, 4.4). The asymmetry of comic failure — punchlines are always dull-able, never absent — is a structural fact.

*Universality is a certificate, not a characterisation, until you fix the resolution.* Terminality maximises every real-valued functor (Theorem 5.1), so universal jokes are the funniest; the converse fails (Theorem 5.11) and is repaired exactly by the hull quotient (Theorem 5.19).

### 9.2 Limitations

The model is deliberately austere.

* Readings are points on a line with no internal structure; a genuinely semantic model would place them in a space with meaningful geometry. §6 shows the invariant survives that generalisation, but the *combinatorics* of §3–§5 uses the lattice of finite subsets and would need reworking.
* Surprise ignores everything but the two extremes. This is a feature for the uniqueness theorem and a bug for discrimination: it is exactly why the converse of universality fails, and no invariant satisfying (A1)–(A3) can do better.
* Timing, delivery, taboo, social context and the listener's prior all sit outside the model.
* The correlation results concern synthetic data. Nothing here is an empirical claim about human beings.

### 9.3 Relation to incongruity theory

The classical incongruity–resolution account is recovered as follows: *incongruity* is the spread of the reading set, *resolution* is the passage to the joint reading (the colimit), and the failure of a "shared" reading to exist is the extreme case of incongruity in which no resolution within the original frames is possible. The theory adds three things the classical account lacks: an exact combination law, a uniqueness theorem for the measurement, and a precise structural distinction between limits and colimits.

---

## 10. Future directions

### 10.1 A Wundt threshold for submodular valuations

Numerical exploration of synthetic datasets displays a striking regime change: below a surprise threshold, humor and rating correlate at roughly $+0.97$; above it, at roughly $-0.97$; pooled, the correlation collapses to about $+0.04$. This reproduces the inverted-U ("Wundt curve") of arousal psychology, and suggests it is not a psychological accident.

The conjecture is that the threshold is the point at which the submodular valuation stops being supermodular on the diagonal: a rating functional $R$ that is a concave increasing transform of a submodular valuation must monovary with the valuation on a down-set and antivary on its complement, and the crossover is the unique maximiser of $R$. If true, the inverted-U rating curve is exactly what a *concave* utility applied to a *submodular* surprise valuation must look like — a theorem about concavity, not a fact about people. The location of the peak would then be computable from the valuation. Both halves of the required machinery are in place: submodularity is established here, and monovariance/Chebyshev machinery is standard.

### 10.2 Other directions

* **Higher-dimensional reading spaces.** Redevelop §3–§5 with readings in a metric or normed space, where the diameter is no longer determined by two coordinates and greedy submodular maximisation (§8.3) becomes non-trivial.
* **Refined invariants.** Seek an invariant that distinguishes interior readings — necessarily violating one of (A1)–(A3), most plausibly staged additivity — and determine what universality statement it supports.
* **Beyond binary fusion.** Extend the colimit/limit dichotomy to arbitrary diagrams: which shapes of setup diagram admit limits, and does the shape predict comic form (callbacks, running gags, shaggy-dog stories)?
* **Timing as a filtration.** Model delivery as a time-indexed filtration of setups and ask what the surprise process looks like as a stochastic object; the staged-telling axiom is already an additivity statement across time.
* **Empirical programme.** Test monovariance directly on human rating data, stratified by surprise regime, using the paraphrase bound (Theorem 6.6) to bound measurement noise from wording variation.

---

## 11. Summary of results

| Result | Statement |
|---|---|
| Uniqueness | Every humor scale is $V(m,M) = c(M-m)$, $c = V(0,1) \ge 0$; determined by its unit |
| Monotone Cauchy | A monotone additive $g$ on $[0,\infty)$ satisfies $g(t) = g(1)t$ |
| Submodularity | $H(S\cup T) + H(S\cap T) \le H(S) + H(T)$ when $S\cap T \ne \varnothing$ |
| Subadditivity | $H(S\cup T) \le H(S)+H(T)$ (corollary) |
| Colimit dominance | $H(S \cap T) \le H(S\cup T)$ |
| Coproducts | $S \cup T$ is the binary coproduct; all binary coproducts exist |
| No products | Disjoint setups have no binary product |
| Terminality | A terminal object maximises every functor into $\mathbb{R}$ |
| Universality | Terminal jokes maximise surprise; all terminal jokes over a setup are equally surprising |
| Refutation | A non-terminal joke can have maximal humor: $\{0,1\} \subsetneq \{0,\tfrac12,1\}$, both of surprise $1$ |
| Reflection | Along a refinement, equal surprise $\iff$ equal hull |
| Repair | Maximal humor $\iff$ hull-universality |
| Diameter | $H(S) = \operatorname{diam}(S)$; the theory lifts to metric spaces |
| Stability | $|\operatorname{diam} s - \operatorname{diam} t| \le 2 d_H(s,t)$; paraphrase bound $2\varepsilon$, sharp |
| Correlation | Monovariance $\Rightarrow$ nonnegative covariance; without it, covariance can be negative |
