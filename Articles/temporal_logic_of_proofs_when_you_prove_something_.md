# Temporal Logic of Proofs: When You Prove Something Matters

## Mathematics with a clock

Mathematics is usually narrated outside time. A theorem is true; a proof exists; the page does not record whether the crucial idea arrived yesterday or will arrive next year. Yet mathematical practice is intensely temporal. Lemmas are established before the theorems that depend on them. A database grows. A research group may know today that a claim is still open while expecting that a newly developed method will settle it tomorrow.

To reason clearly about this evolving landscape, we need to separate two kinds of reachability. One asks which conclusions are supported by the present proof state. The other asks which stages of inquiry lie in the future. Once those relations are separated, familiar-looking sentences become surprisingly delicate. In particular, “this is proved now, so it will still count as proved later” is very different from “this is not proved now, but it will be proved later.” The first expresses persistence; the second expresses discovery.

The central result developed here is a boundary result. A proposed bridge between proof and time,

$$
\Box A\longrightarrow \Box\Box\Diamond_t A,
$$

is valid under extremely modest assumptions. Here $\Box A$ means that $A$ holds at every proof-accessible state, while $\Diamond_t A$ means that there is a temporally accessible stage at which $A$ holds. But this validity does not, by itself, create a stronger provability logic: the principle factors into an ordinary transitivity law for proof accessibility and the elementary fact that the present is temporally accessible from itself.

That observation changes the research question. Instead of treating the displayed principle as evidence for a new logic, we should ask which genuinely temporal interactions cannot already be reconstructed from old modal laws plus a reflexive clock.

## Two maps of possibility

Consider a collection $W$ of states. A state can represent a stage of mathematical knowledge, a proof environment, or a point in an idealized discovery process. Put two directed relations on $W$.

* Write $wRv$ when $v$ is accessible from $w$ through proof reasoning.
* Write $wTv$ when $v$ is at the same time as, or later than, $w$.

For a proposition $A$ interpreted at states, define

$$
\Box A(w) \quad\text{to mean}\quad \text{for every }v,\; wRv\text{ implies }A(v).
$$

Define the temporal possibility operator by

$$
\Diamond_t A(w) \quad\text{to mean}\quad \text{there exists }v\text{ with }wTv\text{ and }A(v),
$$

and the temporal necessity operator by

$$
G A(w) \quad\text{to mean}\quad \text{for every }v,\; wTv\text{ implies }A(v).
$$

The proof relation is assumed transitive: if $wRv$ and $vRu$, then $wRu$. Time is assumed reflexive: $wTw$ for every state $w$. In applications one also imposes a compatibility condition ensuring persistence of established provability along time:

$$
\Box A(w)\ \text{and}\ wTv\quad\Longrightarrow\quad \Box A(v).
$$

This last condition says that the system may gain proofs but does not forget proofs already established.

## Why the proposed temporal axiom is already familiar

Suppose $\Box A$ holds at $w$. We want to understand why $\Box\Box\Diamond_t A$ must also hold there.

Choose any $v$ with $wRv$, and then any $u$ with $vRu$. Transitivity gives $wRu$. Since $\Box A$ holds at $w$, the proposition $A$ holds at $u$. Reflexivity of time gives $uTu$, so $u$ itself witnesses $\Diamond_t A$ at $u$. Because $v$ and $u$ were arbitrary, $\Box\Box\Diamond_t A$ holds at $w$.

This proves the **Temporal Interaction Theorem**: if proof accessibility is transitive and time is reflexive, then for every proposition $A$ and every state $w$,

$$
\Box A(w)\longrightarrow \Box\Box\Diamond_t A(w).
$$

Notice what was not used. We did not need time to be linear. We did not need every inquiry to terminate. We did not need a special causal law connecting proof steps to future stages. Transitivity and reflexivity did all the work.

The proof also exposes a factorization. Transitivity validates the ordinary modal principle often called axiom $4$:

$$
\Box A\longrightarrow \Box\Box A.
$$

Temporal reflexivity validates

$$
A\longrightarrow \Diamond_t A,
$$

because “now” is one of the temporally accessible times. Applying the second implication inside the double box gives the proposed interaction principle. Thus the principle is a useful consistency check, but it is not by itself evidence that the temporal system strictly extends ordinary transitive provability logic.

## The tomorrow sentence splits in two

Now consider the sentence “provable tomorrow but not today.” Its apparent paradox comes from sliding between two readings.

The first reading describes **proof loss**:

$$
\Box A(\text{today})\ \wedge\ \neg\Box A(\text{tomorrow}).
$$

If today precedes tomorrow and established provability persists, this conjunction is impossible. The **No-Proof-Loss Theorem** states that whenever $today\,T\,tomorrow$,

$$
\neg\bigl(\Box A(\text{today})\wedge\neg\Box A(\text{tomorrow})\bigr).
$$

The reason is immediate but important: persistence carries $\Box A$ from today to tomorrow, contradicting its alleged failure there.

The second reading describes **proof gain**:

$$
\neg\Box A(\text{today})\ \wedge\ \Box A(\text{tomorrow}).
$$

This is not paradoxical. It is exactly what discovery looks like.

A two-state example makes the distinction vivid. Let the states be $0$ and $1$, with $0$ today and $1$ tomorrow. Let time relate each state to itself and relate $0$ to $1$. Let the only proof edge run from $0$ to $1$. Choose $A$ to be false at state $1$. Then $\Box A$ is false at state $0$, because its proof-accessible successor fails $A$. At state $1$ there are no proof successors, so $\Box A$ is true there. Consequently,

$$
\neg\Box A(0)\ \wedge\ \Box A(1)
$$

holds. The **Proof-Gain Satisfiability Theorem** therefore says that there is a temporal proof model in which a proposition is not provable today and is provable tomorrow.

The asymmetry is the heart of the matter: forgetting is forbidden, discovery is allowed. Any temporal logic of mathematical growth that refuted both would erase the very phenomenon it was intended to describe.

## A second lesson from trees: local scarcity controls global structure

A seemingly distant result about tree-shaped diagrams reinforces the same methodological theme: global claims should be tested against the smallest structural constraints.

A finite tree is a connected graph with no cycles. If it has $n$ vertices, it has exactly $n-1$ edges. Every edge contributes $1$ to the degree of each endpoint, so the total degree is

$$
\sum_{v}\deg(v)=2(n-1).
$$

This is the **Tree Degree-Sum Theorem**.

If every vertex had degree at least $2$, the same sum would be at least $2n$. But $2(n-1)<2n$. Therefore every nonempty finite tree has a vertex of degree at most $1$. Such a vertex is a leaf, with the one-vertex tree included by allowing degree $0$. This is the **Leaf Existence Theorem**.

The graph fact becomes a representation-theoretic obstruction in a simply-laced tree diagram. Let the vertices index simple roots $\alpha_v$, let $\rho$ be the usual half-sum of positive roots, and let $\beta_I$ denote the diagram correction associated with the full vertex set $I$. For a singleton marking $\{v\}$, consider

$$
\lambda_{\{v\},I}=2\rho-\beta_I-\alpha_v.
$$

The relevant dominance criterion says that this singleton correction is $\rho$-dominant exactly when

$$
\deg(v)\ge 2.
$$

Combining the criterion with leaf existence yields the **Leaf Obstruction Theorem**: every nonempty simply-laced tree diagram contains a vertex $v$ for which the singleton correction $\lambda_{\{v\},I}$ is not $\rho$-dominant.

The proof is only two steps. A tree contains a vertex with $\deg(v)\le 1$; the singleton criterion requires $\deg(v)\ge 2$. The inequalities are incompatible. A global classification indexed by marked diagrams must therefore exclude at least one singleton marking in every tree component. The allowed marks must be anchored at vertices with enough local connectivity.

## What computation can and cannot settle

Both stories suggest efficient finite tests.

For a temporal model with $N$ states, represent $R$ and $T$ by Boolean $N\times N$ matrices. Transitivity and reflexivity can be checked directly. Given the truth set of $A$, compute $\Box A$ by inspecting every proof successor and compute $\Diamond_t A$ by searching temporal successors. Exhausting all $2^N$ truth assignments then tests the interaction formula on that fixed frame. This does not establish completeness of a deductive system, but it quickly finds small countermodels to overambitious axioms.

For a finite graph, the tree results are even cheaper. Count vertices and edges, test connectedness, and verify acyclicity. Degrees are obtained in linear time in the size of the graph. Any vertex of degree at most $1$ witnesses both leaf existence and, in the simply-laced setting, failure of singleton dominance.

These computations embody a broader discipline: separate theorem from conjecture. The temporal interaction principle is sound, proof loss is impossible under persistence, and proof gain is satisfiable. By contrast, decidability, a finite-model bound, and arithmetical completeness for a time-indexed theory remain open until a specific calculus and a precise clock are fixed.

## A research program after the boundary

The next step is not to add more suggestive notation, but to specify the system sharply. One promising calculus would combine ordinary provability logic, a reflexive-transitive temporal logic, the persistence law $\Box A\to G\Box A$, and explicit interaction axioms. One can then ask whether validity on finite temporal proof frames coincides with derivability.

A finite-model theorem would turn that question into an algorithm. If every non-derivable formula $A$ had a countermodel with at most

$$
2^{2s(A)}
$$

states, where $s(A)$ counts subformulas, bounded model search would decide derivability. The bound is a conjectural target, not an established theorem.

Arithmetic demands another choice: a clock. Let $(PA_t)$ be an increasing sequence of recursively axiomatized fragments of Peano arithmetic, and interpret $\Box_t A$ as “$PA_t$ proves $A$.” Only after fixing this sequence and a recursively enumerable modal calculus does an arithmetical completeness claim become precise.

The resulting picture is more measured, and more useful, than the original slogan. Time can be added to provability semantics. Some temporal principles then follow almost for free; others encode genuine discovery. The decisive question is not merely whether a formula mentions tomorrow. It is whether tomorrow contributes mathematical content that cannot already be supplied by transitivity and the fact that the present counts as a possible future.
