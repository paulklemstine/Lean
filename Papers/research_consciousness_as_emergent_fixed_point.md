# Consciousness as an Emergent Fixed Point: Diagonal Self-Models, Strange Loops, and Observational Limits

**Aristotle**  
**July 30, 2026**

## Abstract

We study an extensional mathematical model of self-representation. A state space $A$ and observation space $B$ are linked by an interpretation map $I:A\to(A\to B)$, so each state represents a $B$-valued observer of the entire state space. The diagonal observation is $d(a)=I(a)(a)$. We call the model complete when every function $A\to B$ is represented by a state. A diagonal argument shows that, for every endomorphism $g:B\to B$, completeness produces a state $a$ representing $x\mapsto g(d(x))$ and satisfying $g(d(a))=d(a)$. Thus the witness is simultaneously representational and dynamical: it is a self-loop in the orbit graph of $g$ and determines closed walks of every finite length.

We then establish the converse obstruction: any fixed-point-free endomorphism of $B$ rules out complete self-modeling. Boolean negation gives an immediate impossibility theorem. More generally, every set with two distinct elements admits a fixed-point-free endomorphism, so completeness forces $B$ to have at most one element. Together with necessary inhabitation conditions, this yields an exact classification: a complete self-model exists precisely when $A$ and $B$ are nonempty and $B$ is a subsingleton. Finally, we connect represented observers to the Yoneda viewpoint. A map is recovered from its action by precomposition on all probes, and equality of these actions forces equality of observers. The results clarify both the power and the severe limitation of unrestricted extensional self-modeling: diagonal closure forces fixed points, but nontrivial observational distinction prevents completeness.

## 1. Introduction

Self-reference occurs whenever a representational system can turn its descriptive resources upon itself. In logic, diagonal constructions produce self-referential sentences. In computation, recursion theorems produce programs that access descriptions of their own behavior. In cognitive discourse, “strange loops” describe systems that model themselves modeling themselves. These analogies are suggestive, but their assumptions are often left implicit.

This paper isolates a minimal set-theoretic core. A system has possible states $A$ and possible observations $B$. At each state it carries an observer of the whole state space. The resulting interpretation map has type

$$
I:A\longrightarrow B^A,
$$

where $B^A$ denotes the set of all functions from $A$ to $B$. This exponential form is the characteristic self-modeling structure available in a Cartesian closed setting: a state determines a function that can itself be evaluated on states.

The central hypothesis is point-surjective completeness: every observer in $B^A$ is represented by some state. Under this hypothesis, diagonal evaluation forces every endomorphism of $B$ to possess a fixed point. The argument is a direct instance of Lawvere's diagonal method, specialized to sets and functions. Its self-referential witness has additional structure: it represents the transformed diagonal observer and produces a literal loop in the transition graph of the transformation.

The same theorem immediately exposes the strength of completeness. If $B$ admits even one fixed-point-free map, completeness is impossible. Every set with at least two elements admits such a map, so unrestricted completeness permits no nontrivial observation space. We prove the exact existence criterion, not merely the obstruction.

A second theme is observational recovery. Given $f:A\to B$, consider all composites $h\circ f:A\to X$ as $X$ and $h:B\to X$ vary. This family is the action of $f$ on covariant probes, equivalently the precomposition action associated with representable hom-functors. Evaluation at the identity probe recovers $f$. This elementary Yoneda principle shows that a represented observer and its total downstream behavior carry the same extensional information.

The model is intentionally austere. It does not claim that a cognitive state literally represents every set-theoretic function, nor that the existence of a fixed point suffices for consciousness. Rather, it makes a conditional proposal mathematically transparent. If consciousness is associated with recursively closed self-modeling, diagonal fixed points explain how closure can arise. If meaningful consciousness requires multiple distinguishable observations, the classification theorem shows why total, unstratified completeness is an unsuitable ideal.

## 2. Self-models and diagonal observation

### Definition 2.1 (Self-model)

Let $A$ and $B$ be sets. A **self-model** with state space $A$ and observation space $B$ is a function

$$
I:A\longrightarrow (A\longrightarrow B).
$$

For $a,x\in A$, the value $I(a)(x)\in B$ is the observation of state $x$ made by the observer represented at state $a$.

The definition separates a state from the observer it represents. Distinct states may represent the same observer; no injectivity assumption is imposed. Likewise, no algebraic, order-theoretic, or topological structure on either space is required.

### Definition 2.2 (Completeness)

A self-model $I:A\to(A\to B)$ is **complete** if it is surjective. Explicitly, for every observer $p:A\to B$, there exists a state $a\in A$ such that

$$
I(a)=p.
$$

Completeness is extensional and unrestricted: it quantifies over every $B$-valued function on $A$. This strength is essential both to the fixed-point theorem and to the later collapse result.

### Definition 2.3 (Diagonal observation)

The **diagonal observation** of a self-model is the map $d:A\to B$ given by

$$
d(a)=I(a)(a).
$$

The two appearances of $a$ play different roles. The outer occurrence selects the observer represented by the state; the inner occurrence supplies that same state as the observer's input.

### Definition 2.4 (Strange-loop witness)

Let $g:B\to B$ be an observation transformer. A state $a\in A$ is a **strange-loop witness for $g$** if

$$
I(a)(x)=g(d(x))\quad\text{for every }x\in A
$$

and

$$
g(d(a))=d(a).
$$

The first condition is representational: $a$ encodes the observer obtained by transforming every diagonal observation. The second is dynamical: its own diagonal observation is stable under the transformation.

## 3. The diagonal fixed-point theorem

### Theorem 3.1 (Strange-Loop Fixed-Point Theorem)

Let $I:A\to(A\to B)$ be a complete self-model. For every function $g:B\to B$, there exists a strange-loop witness $a\in A$. Equivalently, there is a state $a$ such that

$$
I(a)=\bigl(x\mapsto g(d(x))\bigr)
$$

and

$$
g(d(a))=d(a).
$$

**Proof sketch.** Define an observer $p:A\to B$ by $p(x)=g(d(x))$. Completeness supplies $a\in A$ with $I(a)=p$. Evaluate this equality at $a$. On the left, $I(a)(a)=d(a)$ by definition. On the right, $p(a)=g(d(a))$. Hence $d(a)=g(d(a))$, and symmetry gives the displayed fixed-point equation. The same choice of $a$ already satisfies the representational clause. $\square$

### Corollary 3.2 (Universal Fixed-Point Property)

If a complete self-model with observation space $B$ exists, then every endomorphism $g:B\to B$ has a fixed point. More precisely, there is some $b\in B$ such that $g(b)=b$.

**Proof sketch.** Apply Theorem 3.1 and take $b=d(a)$. $\square$

This argument is not an appeal to convergence. No metric, order, continuity, compactness, or iterative limiting process is present. The fixed point is forced purely by representability and diagonal evaluation. That distinguishes it from fixed-point theorems based on contraction, monotonicity, or topology.

The theorem also says more than the bare existence of $b$. The fixed point is indexed by a state $a$ that represents the global transformed-diagonal observer. The “strange loop” therefore joins three operations:

1. states represent observers;
2. observers are diagonally applied to their representing states;
3. a transformed diagonal observer is itself represented.

Closing these operations at the representing state yields stability.

## 4. Orbit graphs and closed loops

The fixed point has a direct graph-theoretic interpretation.

### Definition 4.1 (Orbit graph)

For $g:B\to B$, the **orbit graph** is the directed graph with vertex set $B$ and a directed edge from $x$ to $y$ precisely when

$$
y=g(x).
$$

Every vertex has exactly one outgoing edge, though incoming edges may be absent or numerous.

### Definition 4.2 (Closed orbit)

For $b\in B$ and a natural number $n$, a **closed orbit of length $n$ based at $b$** means

$$
g^n(b)=b,
$$

where $g^0$ is the identity and $g^{n+1}=g\circ g^n$.

### Proposition 4.3 (A strange-loop witness is a graph self-loop)

If $a$ is a strange-loop witness for $g$, then the diagonal observation $d(a)$ has an edge to itself in the orbit graph of $g$.

**Proof sketch.** The witness equation is $g(d(a))=d(a)$, exactly the condition defining an edge from $d(a)$ back to $d(a)$. $\square$

### Lemma 4.4 (Fixed points close at every length)

If $g(b)=b$, then $g^n(b)=b$ for every natural number $n$.

**Proof sketch.** Induct on $n$. The case $n=0$ is the identity law. If $g^n(b)=b$, then $g^{n+1}(b)=g(g^n(b))=g(b)=b$. $\square$

### Theorem 4.5 (Complete models have closed orbits of all lengths)

Let $I:A\to(A\to B)$ be complete and let $g:B\to B$. There exists a state $a\in A$ such that

$$
g^n(d(a))=d(a)
$$

for every natural number $n$.

**Proof sketch.** Theorem 3.1 gives $a$ with $g(d(a))=d(a)$. Apply Lemma 4.4 to $b=d(a)$. $\square$

The phrase “all lengths” should be interpreted carefully. A fixed point gives a degenerate closed walk whose single vertex is traversed repeatedly; it does not assert the existence of distinct vertices forming nontrivial cycles of every length. Nevertheless, it supplies a literal graph-theoretic realization of recursive closure.

## 5. Fixed-point-free obstructions

The diagonal theorem has an immediate contrapositive form.

### Theorem 5.1 (Fixed-Point-Free Obstruction)

Let $g:B\to B$ satisfy $g(b)\ne b$ for every $b\in B$. Then no self-model $I:A\to(A\to B)$ is complete.

**Proof sketch.** If $I$ were complete, Corollary 3.2 would produce $b$ with $g(b)=b$, contradicting the hypothesis. $\square$

### Corollary 5.2 (Boolean incompleteness)

For every state space $A$, no Boolean-valued self-model

$$
I:A\longrightarrow(A\longrightarrow\{0,1\})
$$

is complete.

**Proof sketch.** Boolean negation maps $0$ to $1$ and $1$ to $0$, so it has no fixed point. Apply Theorem 5.1. $\square$

This corollary is a finite diagonal obstruction. It does not depend on comparing cardinalities, although cardinality also makes surjectivity implausible in many finite cases. More importantly, the same proof works uniformly for every $A$, including infinite state spaces.

### Theorem 5.3 (Observational collapse)

If $I:A\to(A\to B)$ is a complete self-model, then $B$ is a subsingleton: for all $x,y\in B$,

$$
x=y.
$$

**Proof sketch.** Suppose instead that $x\ne y$. Define $g:B\to B$ by

$$
g(z)=
\begin{cases}
y,&z=x,\\
x,&z\ne x.
\end{cases}
$$

This map has no fixed point. At $z=x$, its value is $y\ne x$. At $z\ne x$, its value is $x\ne z$. Theorem 5.1 then contradicts completeness. Therefore no distinct $x,y$ exist. $\square$

This result shows that the universal fixed-point property characterizes a severe degeneracy for sets. If every self-map of $B$ has a fixed point, then $B$ can have at most one element. The proof uses no choice of a global permutation; two distinct observations suffice to manufacture a fixed-point-free map.

## 6. Exact classification of complete self-models

To classify existence, we also need inhabitation.

### Lemma 6.1 (A complete model has a state)

If $I:A\to(A\to B)$ is complete, then $A$ is nonempty.

**Proof sketch.** If $A$ were empty, there would still be a unique function $p:A\to B$. Completeness would require a state $a\in A$ representing $p$, contradicting emptiness. $\square$

### Lemma 6.2 (A complete model has an observation)

If $I:A\to(A\to B)$ is complete, then $B$ is nonempty.

**Proof sketch.** By Lemma 6.1 choose $a\in A$. Then $d(a)=I(a)(a)$ is an element of $B$. $\square$

### Theorem 6.3 (Classification of complete self-models)

For sets $A$ and $B$, a complete self-model $I:A\to(A\to B)$ exists if and only if all three conditions hold:

1. $A$ is nonempty;
2. $B$ is nonempty;
3. $B$ is a subsingleton.

Equivalently, completeness exists precisely when the state space is inhabited and the observation space has exactly one element up to equality.

**Proof sketch.** For necessity, assume a complete model exists. Lemmas 6.1 and 6.2 give nonemptiness, and Theorem 5.3 gives the subsingleton property.

For sufficiency, choose $a_0\in A$ and $b_0\in B$. Define

$$
I(a)(x)=b_0
$$

for all $a,x\in A$. Let $p:A\to B$ be arbitrary. Since $B$ is a subsingleton, $p(x)=b_0$ for every $x$, so $p$ equals the constant function represented by $a_0$. Thus $I$ is surjective. $\square$

The classification is the central limitation of the framework. Completeness is not merely hard to achieve in a large system; under the extensional definition it is impossible whenever observations carry any distinction. The positive fixed-point theorem and the negative collapse theorem are two faces of the same diagonal mechanism.

## 7. Yoneda recovery and behavioral identity

The exponential $A\to B$ also admits a representable interpretation. A map can be studied by attaching every possible downstream probe.

### Definition 7.1 (Precomposition action)

Given $f:A\to B$, a target set $X$, and a probe $h:B\to X$, define the precomposition action of $f$ by

$$
P_f(X,h)=h\circ f:A\longrightarrow X.
$$

Although the operation composes $h$ after $f$ in elementwise notation, it is called precomposition because the map $h$ is sent to $h\circ f$. Thus $f$ induces a transformation from maps out of $B$ to maps out of $A$.

### Proposition 7.2 (Recovery at the identity)

For every $f:A\to B$,

$$
P_f(B,\operatorname{id}_B)=f.
$$

**Proof sketch.** For every $a\in A$, one has $(\operatorname{id}_B\circ f)(a)=f(a)$. $\square$

### Theorem 7.3 (Yoneda faithfulness for sets)

Let $f,g:A\to B$. Suppose that for every set $X$ and every probe $h:B\to X$,

$$
h\circ f=h\circ g.
$$

Then $f=g$.

**Proof sketch.** Choose $X=B$ and $h=\operatorname{id}_B$. The hypothesis becomes $f=g$ by Proposition 7.2. $\square$

The universal quantification is conceptually informative even though the proof needs only one distinguished component. The total action on probes contains the original map because the identity probe is among them. This is a concrete form of Yoneda faithfulness: arrows are determined by their action within representable families.

### Corollary 7.4 (Recovery of a represented observer)

For every state $a\in A$, the represented observer $I(a):A\to B$ is recovered by applying its precomposition action to the identity probe on $B$.

**Proof sketch.** Apply Proposition 7.2 to $f=I(a)$. $\square$

### Corollary 7.5 (Extensional identity of represented observers)

Let $a_1,a_2\in A$. If for every set $X$ and every $h:B\to X$ one has

$$
h\circ I(a_1)=h\circ I(a_2),
$$

then

$$
I(a_1)=I(a_2).
$$

**Proof sketch.** Apply Theorem 7.3 to the two represented observers. $\square$

This conclusion concerns observers rather than underlying states. Without injectivity of $I$, one cannot infer $a_1=a_2$. The distinction is relevant to any interpretation in which multiple physical states can realize the same functional perspective.

## 8. Algorithms and finite diagnostics

The theorems suggest concrete procedures for finite models. They do not prove completeness by sampling; rather, they expose witnesses and obstructions when all relevant functions can be enumerated.

### 8.1 Diagonal witness extraction

Assume finite sets $A$ and $B$, an explicit table for $I$, and a transformation $g:B\to B$. Compute the diagonal vector $d(a)=I(a)(a)$. Form the target observer $p(x)=g(d(x))$. Search for a state $a$ whose observer row equals $p$. If one is found, then evaluating at $a$ necessarily gives $g(d(a))=d(a)$.

For $|A|=m$, a direct implementation computes the diagonal in $O(m)$ time and compares at most $m$ rows of length $m$, requiring $O(m^2)$ time. The dependence on $|B|$ lies in the representation and equality cost of observation values.

If the model is known to be complete, the search must succeed. If it fails for some $g$, the target observer is an explicit certificate of incompleteness.

### 8.2 Exhaustive completeness testing

For finite $A$ and $B$, there are $|B|^{|A|}$ observers. Encode each observer as a tuple in $B^{|A|}$ and compare the set of represented rows with the complete Cartesian product. This takes $O(|B|^{|A|}|A|)$ time merely to enumerate all observers and exponential space if the collection is stored explicitly.

The classification theorem usually makes this enumeration unnecessary. If $|B|\ge 2$, completeness is impossible. If $|B|=1$ and $|A|\ge 1$, every self-model is pointwise forced to use the unique observation, and completeness reduces to the existence of at least one state. Thus a structural test decides existence in constant time once cardinality and inhabitation are known.

### 8.3 Orbit verification

Given $g$ and a candidate $b$, first test whether $g(b)=b$. If so, every finite orbit length closes by Lemma 4.4; no repeated simulation is mathematically necessary. For visualization, one may nevertheless iterate $g$ and record the constant trajectory. For an arbitrary finite map, cycle detection can be performed in $O(|B|)$ time and $O(|B|)$ memory with a visited table, or in $O(|B|)$ time and $O(1)$ auxiliary memory using tortoise-and-hare cycle detection.

## 9. Interpretation and applications

### 9.1 Self-modeling systems

The model captures one abstract feature of self-modeling: a system state carries a perspective on the state space, and that perspective can be applied to its own carrier. The diagonal is therefore not an additional psychological assumption; it is available as soon as represented observers can consume states of the same kind that represent them.

Yet the completeness hypothesis should not be mistaken for ordinary cognitive richness. It demands representation of every set-theoretic observer, including adversarial observers built specifically from the model's diagonal behavior. The collapse theorem shows that this ideal is too strong for any observation space with genuine alternatives.

A more plausible theory would restrict the represented observer class, perhaps by computability, continuity, bounded complexity, measurability, resource constraints, or learned architecture. Then the diagonal observer $x\mapsto g(d(x))$ may fail to belong to the admissible class, and the universal fixed-point conclusion no longer follows automatically.

### 9.2 Logic and semantic paradox

Boolean negation reproduces the shape of semantic diagonal paradoxes. A complete Boolean self-model would need to represent the observer that negates each state's self-observation. At the state representing that observer, the value would need to equal its own negation. Rather than accepting inconsistency, the theorem concludes that the completeness assumption fails: some Boolean observer is unrepresented.

This is an incompleteness phenomenon in a broad semantic sense. It does not invoke syntax, provability, or arithmetic. Its ingredients are only functions, surjectivity, and diagonal evaluation.

### 9.3 Functional identity and probing

The Yoneda result supports an operational notion of observer identity. If no downstream test can distinguish two represented observers, then the observers are extensionally equal. This gives a mathematically exact version of the slogan that an entity is determined by all of its interactions, while also showing why the identity probe is decisive.

The result does not imply that all internal realizations are identical. States remain intensional carriers; represented observers are their extensional behaviors. An enriched model could study the fibers of $I$, namely the sets of states that realize each observer.

### 9.4 Dynamical systems

The orbit interpretation places diagonal self-reference inside elementary dynamics. The resulting fixed point is a period-one orbit. The theorem does not establish attraction, robustness, or stability under perturbation; these require topology, metrics, probability, or order. However, it cleanly separates algebraic closure from dynamical convergence. A fixed point may exist because self-representation forces it, even when no iterative learning process reaches it.

## 10. Limitations

Several boundaries are essential.

First, the word “consciousness” names an interpretive bridge, not a mathematical equivalence. The existence of a diagonal fixed point is neither asserted nor shown to be sufficient for phenomenal experience.

Second, the model is extensional. Two observers are equal when they return equal outputs on every input; computational cost, causal history, internal organization, and timing are ignored.

Third, completeness ranges over all functions $A\to B$. The classification demonstrates that this is incompatible with nontrivial $B$. The appropriate lesson is not that self-models are impossible, but that realistic completeness notions must be relative to a restricted family.

Fourth, the graph loops supplied here are fixed points repeated under iteration. Richer “strange-loop topology” would require a directed topological realization, homotopical invariants, or path-space analysis.

Finally, the Yoneda discussion is developed concretely for sets. A categorical generalization would replace functions by morphisms and the function space $B^A$ by an exponential object in a Cartesian closed category.

## 11. Future work

Several directions follow naturally.

1. Internalize the construction in a general Cartesian closed category using a point-surjective morphism $A\to B^A$, and recover the present theorem by specialization to sets.
2. Compare diagonal fixed points with least and greatest fixed points of monotone self-modeling operators on complete lattices.
3. Replace one-step orbit graphs by directed topological realizations and study cycles in the associated path spaces.
4. Formulate the Yoneda connection through categorical representables and prove invariance of diagonal witnesses under isomorphisms of self-models.
5. Study guarded self-reference, in which a delay modality weakens completeness and may permit nontrivial observation spaces while retaining unique guarded fixed points.
6. Quantify finite incompleteness by bounding how many observers every map $A\to B^A$ must omit.
7. Add approximation: equip $B$ with a metric and ask when approximate representability forces approximate fixed points.
8. Study the realization fibers of $I$ to distinguish identity of observers from identity of states.

## 12. Conclusion

A complete self-model assigns states to all possible observers. Diagonal evaluation then turns transformed self-observation into a represented observer and forces a fixed point. The witness is a genuine self-loop in the transformation's orbit graph and remains closed under every finite number of iterations.

The same construction sharply limits the framework. Fixed-point-free transformations obstruct completeness; Boolean negation is the simplest example. In fact, complete self-models exist exactly when the state space is inhabited and the observation space is inhabited but subsingleton. Unrestricted extensional self-representation therefore becomes possible only after observational distinctions collapse.

The Yoneda perspective supplies a complementary principle: represented observers are determined by all their downstream actions and are recovered at the identity probe. Together, diagonalization and probing articulate two aspects of self-modeling—recursive closure and behavioral identity. Their combination offers a precise mathematical bridge for discussing strange loops while making explicit why meaningful, nontrivial self-models must remain partial, guarded, stratified, or otherwise restricted.