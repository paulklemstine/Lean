# A Finite Calculus of Integrated Information: Minima, Composition, Refinement, and Exclusion

**Aristotle**  
**August 3, 2026**

## Abstract

We develop a self-contained finite mathematical model of integrated information. A causal structure is represented by a finite nonempty set of admissible cuts together with a nonnegative real loss assigned to each cut. Its integrated information $\Phi$ is the minimum cut loss. This elementary definition supports a coherent calculus. The minimum is attained; $\Phi$ is nonnegative and is the greatest lower bound of all cut losses; and $\Phi=0$ precisely when a lossless cut exists. Independent parallel composition is modeled by Cartesian products of cut spaces and addition of component losses, under which $\Phi$ is exactly additive. Causal refinements are cut translations that weakly increase loss; they compose, admit identities, and make $\Phi$ monotone. For a finite nonempty family of candidate complexes, the exclusion value is the maximum of their $\Phi$-values. A maximizing candidate always exists, every candidate lies below the exclusion value, and strict dominance implies uniqueness. Finally, the number of represented nontrivial cuts of an $n$-element mechanism is bounded by $2^n$, yielding an exponential worst-case bound for exhaustive evaluation. We give proof sketches, algorithms, numerical examples, applications, limitations, and extensions toward probabilistic causal semantics, interacting composites, categorical structure, and symmetry-reduced computation.

## 1. Introduction

Integrated-information approaches begin with an intuition about causal wholeness. A system is integrated when dividing it destroys causal organization that cannot be assigned independently to the resulting pieces. The intuition has two nested optimization problems. Within a fixed system, one searches over possible cuts and asks which cut does the least damage. Across candidate subsystems or scales, one asks which candidate is most integrated.

This paper isolates the finite order-theoretic core of those ideas. The model deliberately begins after the empirical or probabilistic work of assigning losses has been completed. Each admissible intervention has a nonnegative real cost, interpreted as destroyed causal information. The integrated information of a system is the smallest such cost. This choice enforces a weakest-seam principle: a structure counts as strongly integrated only if every admissible cut is costly.

Despite its economy, the model supports several structural results. Finite minimization ensures an actual minimum-information cut. Nonnegativity gives a precise reducibility criterion. Product cut spaces and additive losses yield an exact composition law for independent systems. Pointwise comparison of losses gives a category-like refinement relation and a monotonic numerical invariant. Finite maximization yields an exclusion principle, including a sufficient condition for uniqueness. A power-set estimate exposes the exponential combinatorics behind exhaustive computation.

The results are mathematical implications of the abstract loss model, not a claim that integrated information alone constitutes a complete theory of consciousness. In particular, the model does not prescribe how losses arise from neural dynamics, transition kernels, interventions, or statistical divergences. Its purpose is to separate universal finite optimization facts from domain-specific causal semantics.

## 2. Finite causal structures

### 2.1. Basic definition

**Definition 2.1 (Finite causal structure).** A finite causal structure $S$ is a triple

$$
S=(C_S,L_S,\mathcal{N}_S),
$$

where $C_S$ is a finite nonempty set of admissible cuts, $L_S:C_S\to\mathbb{R}$ is a loss function, and $\mathcal{N}_S$ is the condition

$$
L_S(c)\ge 0\qquad\text{for every }c\in C_S.
$$

The interpretation is that $c$ specifies an allowed causal intervention or partition, while $L_S(c)$ quantifies the causal information destroyed by that intervention. The abstract definition allows different applications to choose different notions of admissibility and different loss metrics.

**Definition 2.2 (Integrated information).** The integrated information of $S$ is

$$
\Phi(S)=\min_{c\in C_S}L_S(c).
$$

The finite and nonempty hypotheses are substantive. Finiteness makes exhaustive minima and maxima available without compactness or continuity assumptions. Nonemptiness prevents the minimum from being undefined.

### 2.2. Attainment and universal properties

**Theorem 2.3 (Minimum-cut attainment).** For every finite causal structure $S$, there exists a cut $c_*\in C_S$ such that

$$
L_S(c_*)=\Phi(S).
$$

**Proof sketch.** The image $L_S(C_S)$ is a finite nonempty subset of $\mathbb{R}$. Every finite nonempty linearly ordered set has a least element. By definition, that least element is the loss of at least one cut and equals $\Phi(S)$. $\square$

The minimum satisfies two complementary inequalities.

**Lemma 2.4 (Lower comparison with each cut).** For every $c\in C_S$,

$$
\Phi(S)\le L_S(c).
$$

**Proof sketch.** A minimum is no greater than any member of the set over which it is taken. $\square$

**Lemma 2.5 (Greatest-lower-bound property).** If $a\in\mathbb{R}$ satisfies

$$
a\le L_S(c)\qquad\text{for every }c\in C_S,
$$

then

$$
a\le\Phi(S).
$$

**Proof sketch.** Since $a$ is a lower bound for every loss, it is a lower bound for the least loss in particular. $\square$

Together, Lemmas 2.4 and 2.5 characterize $\Phi(S)$ uniquely as the greatest lower bound of the finite loss landscape. This formulation is useful because many later arguments prove an equality by giving one feasible cut for an upper bound and a common lower bound for all cuts.

### 2.3. Nonnegativity and exact reducibility

**Corollary 2.6 (Nonnegativity).** Every finite causal structure satisfies

$$
\Phi(S)\ge 0.
$$

**Proof sketch.** Zero is a lower bound for every cut loss by Definition 2.1. Apply Lemma 2.5 with $a=0$. $\square$

**Theorem 2.7 (Zero-integration criterion).** For every finite causal structure $S$,

$$
\Phi(S)=0
\quad\Longleftrightarrow\quad
\exists c\in C_S\text{ such that }L_S(c)=0.
$$

**Proof sketch.** If $\Phi(S)=0$, Theorem 2.3 supplies a minimizing cut $c_*$ with $L_S(c_*)=\Phi(S)=0$. Conversely, if some cut $c$ has zero loss, Lemma 2.4 gives $\Phi(S)\le 0$, while Corollary 2.6 gives $0\le\Phi(S)$. Antisymmetry yields equality. $\square$

This theorem gives exact mathematical content to reducibility. A structure has zero integration precisely when an admissible division preserves all information represented by the loss function. Positive $\Phi$ means every admissible cut destroys a positive amount, although it does not by itself specify how large a positive amount should count as empirically important.

## 3. Independent parallel composition

### 3.1. Product construction

Let $S$ and $T$ be finite causal structures. Independent parallel composition treats a composite cut as one cut in each component.

**Definition 3.1 (Independent parallel composite).** The composite $S\otimes T$ has cut space

$$
C_{S\otimes T}=C_S\times C_T
$$

and loss

$$
L_{S\otimes T}(s,t)=L_S(s)+L_T(t).
$$

This is again a finite causal structure: the Cartesian product of finite nonempty sets is finite and nonempty, and the sum of nonnegative losses is nonnegative.

The definition encodes two assumptions. First, cuts can be selected independently in the two components. Second, the damage caused by a paired cut is the sum of its component damages. It is therefore appropriate for parallel systems without cross-component causal interaction in the chosen representation.

### 3.2. Additivity

**Theorem 3.2 (Parallel composition law).** For finite causal structures $S$ and $T$,

$$
\Phi(S\otimes T)=\Phi(S)+\Phi(T).
$$

**Proof sketch.** Choose minimizing cuts $s_*\in C_S$ and $t_*\in C_T$. The paired cut $(s_*,t_*)$ has loss

$$
L_{S\otimes T}(s_*,t_*)=L_S(s_*)+L_T(t_*)=\Phi(S)+\Phi(T),
$$

so $\Phi(S\otimes T)\le\Phi(S)+\Phi(T)$. Conversely, for every $(s,t)$, Lemma 2.4 gives $\Phi(S)\le L_S(s)$ and $\Phi(T)\le L_T(t)$. Adding yields

$$
\Phi(S)+\Phi(T)\le L_S(s)+L_T(t)=L_{S\otimes T}(s,t).
$$

Thus $\Phi(S)+\Phi(T)$ is a common lower bound for every composite cut. Lemma 2.5 gives the reverse inequality. $\square$

**Example 3.3.** Suppose $S$ has losses $2.0$, $5.0$, and $3.5$, while $T$ has losses $1.0$ and $4.0$. Then $\Phi(S)=2.0$ and $\Phi(T)=1.0$. The six composite losses are $3.0$, $6.0$, $6.0$, $9.0$, $4.5$, and $7.5$, whose minimum is $3.0=2.0+1.0$.

Additivity extends by induction to any finite sequence of independently composed structures:

$$
\Phi(S_1\otimes\cdots\otimes S_k)=\sum_{j=1}^{k}\Phi(S_j).
$$

This iterated formula is an immediate consequence of Theorem 3.2 and associativity of real addition, provided the composite is built repeatedly by the same product-and-sum rule.

## 4. Causal refinement

### 4.1. Definition and composition

Causal descriptions may differ in resolution or admissible intervention vocabulary. We compare them using cut translations that control loss.

**Definition 4.1 (Causal refinement).** A refinement from $S$ to $T$ is a function

$$
f:C_T\to C_S
$$

such that

$$
L_S(f(c))\le L_T(c)
$$

for every $c\in C_T$.

The direction is worth noting: a cut of the target $T$ is translated back to a cut of the source $S$. The inequality says that the translated cut in $S$ is no more destructive than the original cut in $T$.

**Proposition 4.2 (Identity refinement).** Every structure $S$ has an identity refinement $\operatorname{id}_S:S\to S$ given by $\operatorname{id}_S(c)=c$.

**Proof sketch.** For each cut, $L_S(c)\le L_S(c)$ by reflexivity. $\square$

**Proposition 4.3 (Composition of refinements).** If $g:R\to S$ and $f:S\to T$ are refinements, then the composite cut map $g\circ f:C_T\to C_R$ is a refinement $R\to T$.

**Proof sketch.** For every $c\in C_T$,

$$
L_R(g(f(c)))\le L_S(f(c))\le L_T(c).
$$

Transitivity gives the required inequality. $\square$

The identity and composition constructions suggest a category of causal structures and refinements. The present development needs only the explicit laws, but this viewpoint organizes longer chains of model comparison.

### 4.2. Monotonicity of integrated information

**Theorem 4.4 (Refinement monotonicity).** If there is a causal refinement $f:S\to T$, then

$$
\Phi(S)\le\Phi(T).
$$

**Proof sketch.** Choose a minimizing cut $c_*\in C_T$. The translated cut $f(c_*)$ belongs to $C_S$. Hence

$$
\Phi(S)
\le L_S(f(c_*))
\le L_T(c_*)
=\Phi(T).
$$

The first inequality follows from Lemma 2.4, the second from the refinement condition, and the equality from minimum attainment. $\square$

**Corollary 4.5 (Monotonicity along composable refinements).** If $R\to S$ and $S\to T$ are causal refinements, then

$$
\Phi(R)\le\Phi(T).
$$

**Proof sketch.** Apply Theorem 4.4 to each refinement to obtain $\Phi(R)\le\Phi(S)$ and $\Phi(S)\le\Phi(T)$, then use transitivity. Equivalently, apply Theorem 4.4 directly to the composite refinement from Proposition 4.3. $\square$

Thus $\Phi$ is an order-valued invariant of the refinement calculus. It sends identity refinements to reflexive inequalities and composite refinements to transitive inequalities. If refinements exist in both directions, monotonicity gives equality of the two $\Phi$-values, a useful observation for future notions of causal equivalence.

## 5. Exclusion among candidate complexes

### 5.1. Candidate families and the exclusion value

A physical network can support many candidate complexes, distinguished by boundary, scale, or coarse-graining. Let $I$ be a finite nonempty index set, and let $S_i$ be a finite causal structure for each $i\in I$.

**Definition 5.1 (Finite candidate family).** A candidate family is the indexed collection

$$
\mathcal{F}=\{S_i:i\in I\},
$$

where $I$ is finite and nonempty.

**Definition 5.2 (Exclusion value).** The exclusion value of $\mathcal{F}$ is

$$
\widehat{\Phi}(\mathcal{F})=\max_{i\in I}\Phi(S_i).
$$

This outer maximum is conceptually distinct from the inner minimum defining each candidate's integrated information. The full optimization has the max-min form

$$
\widehat{\Phi}(\mathcal{F})
=
\max_{i\in I}\min_{c\in C_{S_i}}L_{S_i}(c).
$$

A candidate is rewarded only after surviving its own weakest cut.

### 5.2. Existence and order characterization

**Theorem 5.3 (Exclusion).** Every finite nonempty candidate family contains a maximizing candidate. That is, there exists $i_*\in I$ such that

$$
\Phi(S_{i_*})=\widehat{\Phi}(\mathcal{F}).
$$

**Proof sketch.** The set $\{\Phi(S_i):i\in I\}$ is finite and nonempty, so it has a greatest member. That member is attained by at least one index. $\square$

**Lemma 5.4 (Candidate upper bound).** Every candidate lies below the exclusion value:

$$
\Phi(S_i)\le\widehat{\Phi}(\mathcal{F})
\qquad\text{for every }i\in I.
$$

**Proof sketch.** A maximum is at least every element of the set being maximized. $\square$

**Lemma 5.5 (Least-upper-bound property).** If $a\in\mathbb{R}$ satisfies

$$
\Phi(S_i)\le a
\qquad\text{for every }i\in I,
$$

then

$$
\widehat{\Phi}(\mathcal{F})\le a.
$$

**Proof sketch.** The maximum is one of the candidate values, and all candidate values are bounded above by $a$. $\square$

Lemmas 5.4 and 5.5 characterize the exclusion value as the least upper bound of the finite $\Phi$-landscape.

### 5.3. Strict dominance and uniqueness

**Theorem 5.6 (Unique exclusion under strict dominance).** Suppose $w\in I$ satisfies

$$
\Phi(S_i)<\Phi(S_w)
\qquad\text{for every }i\ne w.
$$

Then $w$ is the unique exclusion winner: for every $i\in I$,

$$
\Phi(S_i)=\widehat{\Phi}(\mathcal{F})
\quad\Longrightarrow\quad
i=w.
$$

**Proof sketch.** Candidate $w$ is an upper bound for the family because every other value is strictly smaller and its own value is equal to itself. By Lemma 5.5, $\widehat{\Phi}(\mathcal{F})\le\Phi(S_w)$. Lemma 5.4 gives the reverse inequality, so $\widehat{\Phi}(\mathcal{F})=\Phi(S_w)$. If another $i\ne w$ attained the exclusion value, strict dominance would imply

$$
\widehat{\Phi}(\mathcal{F})=\Phi(S_i)<\Phi(S_w)=\widehat{\Phi}(\mathcal{F}),
$$

an impossibility. $\square$

The strict condition is sufficient and, in a finite family, exactly captures uniqueness at the level of numerical values: a unique maximizer must strictly exceed every other candidate. Without strict dominance, exclusion still has at least one winner, but ties may persist.

## 6. Finite combinatorics and algorithms

### 6.1. Counting represented cuts

Let an $n$-element mechanism have underlying set $V$ with $|V|=n$. Represent a cut by selecting a subset $A\subseteq V$ as one side. A represented cut is nontrivial when $A\ne\varnothing$ and $A\ne V$.

**Theorem 6.1 (Nontrivial cut-count bound).** If $N_{\mathrm{nt}}(n)$ denotes the number of represented nonempty proper subsets of an $n$-element mechanism, then

$$
N_{\mathrm{nt}}(n)\le 2^n.
$$

**Proof sketch.** The collection of nonempty proper subsets is obtained by filtering the power set $\mathcal{P}(V)$. Filtering cannot increase cardinality, and $|\mathcal{P}(V)|=2^n$. $\square$

In this particular subset representation the exact count is $2^n-2$ for $n\ge 1$, but the stated theorem requires only the robust upper bound. If $A$ and $V\setminus A$ represent the same unordered bipartition, further quotienting can nearly halve the count. The bound nevertheless establishes exponential worst-case growth.

### 6.2. Exhaustive computation of $\Phi$

For explicit losses, integrated information can be computed by a one-pass minimum scan.

**Algorithm 6.2 (Exhaustive integrated-information evaluation).** Given a finite nonempty list of cuts and a loss oracle:

1. evaluate the loss of the first cut and store it as the current minimum;
2. scan each remaining cut;
3. whenever a smaller loss is found, update the minimum and the minimizing cut;
4. return the final cut and loss.

If there are $m$ admissible cuts and one loss evaluation costs $T_L$, the running time is $O(mT_L)$ and the additional storage is $O(1)$ beyond the cut representation. Under subset enumeration, $m\le 2^n$, so the worst-case number of evaluations is $O(2^n)$.

Correctness follows from a loop invariant: after processing the first $k$ cuts, the stored value is the minimum among precisely those $k$ losses. At termination all cuts have been processed, so the stored value is $\Phi(S)$ and the stored cut realizes it.

### 6.3. Parallel composition algorithm

Given explicit component loss arrays, one could enumerate all $|C_S||C_T|$ pairwise sums and take their minimum. Theorem 3.2 makes that unnecessary. Compute the two component minima independently and add them. The direct product method costs $O(|C_S||C_T|)$ additions and comparisons, whereas the theorem-guided method costs $O(|C_S|+|C_T|)$ loss inspections. It also returns a minimizing paired cut by pairing the component minimizers.

### 6.4. Exclusion algorithm

For candidates $S_1,\ldots,S_k$, compute each inner minimum $\Phi(S_i)$ and then scan those $k$ values for the maximum. If candidate $i$ has $m_i$ cuts, the total number of loss inspections is $\sum_i m_i$, followed by $O(k)$ comparisons. Store all maximizing indices if ties matter; report a unique winner only when one value strictly exceeds all others.

The correctness argument has two layers. Each inner scan is correct by Algorithm 6.2. The outer scan maintains the maximum of the integrated-information values processed so far. At termination it equals $\widehat{\Phi}$, and its stored index set contains exactly the exclusion winners.

## 7. Applications and interpretation

### 7.1. Causal network analysis

In a directed or weighted network, admissible cuts can be graph bipartitions and losses can quantify severed causal influence. The abstract theorems then become templates. The zero criterion detects a partition with no measured cross-cut dependence. Refinement monotonicity compares alternative representations when a cut translation satisfies the required inequality. The cut-count bound explains why exact evaluation becomes difficult as the node count grows.

### 7.2. Modular distributed systems

For independent modules, additive losses and product cuts are natural. The composition theorem shows that integrated information accumulates exactly across independent parallel components under this convention. Conversely, if empirical composite losses violate the product-and-sum model, the discrepancy identifies interaction or a mismatch in the loss semantics. Thus additivity is both a computational shortcut and a diagnostic assumption.

### 7.3. Multiscale candidate selection

Candidate complexes can represent subnetworks, spatial regions, time scales, or coarse-grainings. The exclusion value chooses the candidate with the strongest weakest-cut performance. This max-min structure resembles robust optimization: each candidate is evaluated against its most revealing vulnerability, and candidates are then ranked by that worst case.

### 7.4. Order-valued invariants

The refinement calculus separates structural comparison from numerical measurement. A refinement is not defined merely by comparing two final $\Phi$-values; it compares all target cuts through a coherent translation. Monotonicity is then a consequence. This distinction matters: many unrelated systems can share the same scalar value, while a refinement supplies explicit structural evidence for the inequality.

## 8. Scope and limitations

The model is intentionally abstract. It assumes that admissible cuts and nonnegative losses have already been specified. Consequently, its theorems do not choose a divergence, define a causal repertoire, infer interventions from observational data, or establish a link between $\Phi$ and subjective experience. They state what is mathematically guaranteed for any finite nonnegative cut-loss landscape.

Additivity is conditional on independent parallel composition as defined in Section 3. Interacting systems may contain synergy or redundancy, causing composite loss to differ from the sum of component losses. Such settings require a modified composition rule and may yield subadditivity or superadditivity instead of equality.

Exclusion guarantees existence but not uniqueness without strict dominance. Tied candidates remain a genuine possibility, especially under symmetries. A richer theory may quotient candidates by causal equivalence, select equivalence classes, or add principled tie information.

Finally, the exponential bound warns against naive scaling. It is an upper bound on represented subsets, not a claim that every application must inspect all of them. Graph structure, lower bounds, dynamic programming, branch-and-bound, and symmetries may reduce computation substantially.

## 9. Future research

A first priority is **causal semantics**. Abstract cut losses can be replaced by finite transition-probability kernels, explicit interventions, cause-effect repertoires, and divergence-based loss. One should then prove that these constructions always satisfy nonnegativity and instantiate the present framework. Perturbation bounds could quantify stability of $\Phi$ and exclusion winners under bounded changes in losses.

A second direction concerns **composition and exclusion**. Interacting composites should be studied to characterize when $\Phi$ is additive, subadditive, or superadditive. Exclusion should be developed modulo causal equivalence and in the presence of ties. Its behavior under refinement and parallel composition may reveal useful distributive or monotonic laws.

A third direction is **category theory**. Causal structures and refinements naturally suggest a category, while independent parallel composition suggests a monoidal product. In that language, $\Phi$ behaves as an order-valued monotone invariant, and additivity expresses compatibility with the monoidal structure. Suitable equivalences should preserve $\Phi$.

A fourth direction is **finite combinatorics and complexity**. Quotienting cuts by complementation gives unordered bipartitions and supports exact counts. Correctness and runtime guarantees are needed for exhaustive, branch-and-bound, and symmetry-reduced algorithms. When losses correspond to weighted graph cuts, standard approximation methods may transfer useful guarantees to $\Phi$.

## 10. Conclusion

A finite nonnegative landscape of causal cut losses is enough to support a compact theory of integrated information. The minimum loss is attained, is nonnegative, and vanishes exactly at a lossless cut. Independent parallel products make the minimum additive. Cut-translating refinements make it monotone. Finite candidate families possess exclusion winners, with uniqueness under strict dominance. The represented search space is bounded by $2^n$ for an $n$-element mechanism.

These results clarify the mathematical commitments behind the language of integration and exclusion. They distinguish universal consequences of finite optimization from assumptions about causal modeling and consciousness. The framework's central quantity has a simple meaning: $\Phi(S)$ is the cost of the weakest admissible seam. Its usefulness lies not in replacing richer causal science, but in providing that science with a precise and compositional foundation.
