# Temporal Provability, Persistence, and Structural Obstructions in Tree Diagrams

**Aristotle**  
**August 2, 2026**

## Abstract

We study a bimodal semantics that distinguishes proof accessibility from temporal accessibility. The proof modality $\Box$ is interpreted universally along a transitive relation $R$, while the future modality $\Diamond_t$ is interpreted existentially along a reflexive temporal relation $T$. The proposed interaction scheme

$$
\Box A\to\Box\Box\Diamond_t A
$$

is shown to be valid under only transitivity of $R$ and reflexivity of $T$. More precisely, it factors through the ordinary transitivity principle $\Box A\to\Box\Box A$ and the temporal reflexivity principle $A\to\Diamond_t A$. Consequently, this interaction scheme alone does not demonstrate a strict increase over ordinary transitive provability logic. Under a persistence condition, established provability cannot be lost at a later stage. In contrast, a concrete two-state model shows that proof gain—failure of $\Box A$ today followed by $\Box A$ tomorrow—is satisfiable. This separates two readings of “provable tomorrow but not today” that are often conflated.

We also present an independent structural application of the same scarcity-based method. For a finite tree on $n$ vertices, the degree sum is $2(n-1)$, so a nonempty tree has a vertex of degree at most $1$. In a simply-laced tree diagram where singleton $\rho$-dominance is equivalent to degree at least $2$, such a leaf necessarily obstructs singleton dominance. We give finite algorithms for checking the temporal principles and detecting the tree obstruction, discuss applications to evolving proof databases and diagram classifications, and delineate the unproved steps required for finite-frame completeness, decidability, and arithmetic interpretations with a precise clock.

## 1. Introduction

Classical provability logic abstracts from the time at which proofs are found. This abstraction is appropriate when the only issue is whether a formal theory proves a sentence, but it suppresses information central to mathematical practice and proof search. Results are established in an order; proof repositories grow; later arguments depend on earlier lemmas; and a statement may move from open to settled without any previously established theorem becoming unsettled.

A temporal treatment therefore needs at least two relations. One relation describes proof accessibility: which states must satisfy a proposition if it is presently provable. A second describes temporal accessibility: which states count as present or future stages. The distinction permits precise formulations of persistence, discovery, and interaction between proof and time.

A natural proposed interaction law is

$$
\Box A\to\Box\Box\Diamond_t A.
$$

Informally, if $A$ is provably established now, then it is provable that it is provable that $A$ holds at some temporally accessible stage. Its nested modalities make the formula appear stronger than the standard modal transitivity law. The first aim of this paper is to identify its exact structural content. We show that transitivity of proof accessibility and reflexivity of time suffice. Indeed, ordinary axiom $4$ produces $\Box\Box A$, and temporal reflexivity changes the innermost $A$ into $\Diamond_t A$. No stronger temporal-probabilistic or arithmetic machinery is required.

The second aim is to resolve an ambiguity in the phrase “provable tomorrow but not today.” One reading says that a proof present today disappears tomorrow. A persistence condition refutes this. The opposite reading says that a proof absent today appears tomorrow. That is satisfiable in a two-state model. A logic intended to describe discovery should preserve this asymmetry rather than refute both readings.

The final aim is to place these temporal results beside a finite graph obstruction arising in simply-laced tree diagrams. The connection is methodological rather than a claim that the two semantics are identical. In both settings, an apparently global restriction is controlled by a small structural fact. For temporal interaction, the fact is reflexivity at the innermost world. For tree diagrams, the fact is that average degree is below $2$, forcing a leaf. Once singleton dominance is characterized by degree at least $2$, the leaf becomes an unavoidable obstruction.

The established results are deliberately separated from open claims. We do not assert completeness or decidability for an unspecified temporal calculus, nor arithmetic completeness for an unspecified sequence of theories. Instead, we formulate the semantic core needed to ask those questions precisely and describe bounded algorithms that can test candidate principles on finite frames.

## 2. Temporal proof frames

### 2.1 Syntax

Fix a set $P$ of atomic propositions. Formulas are generated from atoms, falsity $\bot$, implication $\to$, a proof modality $\Box$, a temporal universal modality $G$, and a temporal existential modality $\Diamond_t$. Thus, if $A$ and $B$ are formulas, then so are

$$
A\to B,\qquad \Box A,\qquad GA,\qquad \Diamond_t A.
$$

Negation is defined by $\neg A:=A\to\bot$. Other Boolean connectives may be introduced in the usual way. The modality $\Box$ quantifies over proof-accessible states; $G$ means “at every temporally accessible stage”; and $\Diamond_t$ means “at some temporally accessible stage.”

### 2.2 Frames and valuations

A **temporal proof frame** is a triple

$$
\mathcal F=(W,R,T),
$$

where $W$ is a nonempty set of states, $R\subseteq W\times W$ is proof accessibility, and $T\subseteq W\times W$ is temporal accessibility. For the core interaction theorem we require:

1. **Proof transitivity:** if $wRv$ and $vRu$, then $wRu$.
2. **Temporal reflexivity:** $wTw$ for every $w\in W$.

Additional applications may assume that $R$ is conversely well-founded or that $T$ is transitive, but neither property is needed for the principal interaction theorem.

A valuation $V$ assigns to each atom $p\in P$ a subset $V(p)\subseteq W$. Satisfaction, written $\mathcal F,V,w\vDash A$, is defined recursively. Atoms obey the valuation, falsity is never satisfied, and implication has its classical truth condition. The modal clauses are

$$
\mathcal F,V,w\vDash\Box A
\quad\Longleftrightarrow\quad
\forall v\in W\,(wRv\Rightarrow \mathcal F,V,v\vDash A),
$$

$$
\mathcal F,V,w\vDash GA
\quad\Longleftrightarrow\quad
\forall v\in W\,(wTv\Rightarrow \mathcal F,V,v\vDash A),
$$

and

$$
\mathcal F,V,w\vDash\Diamond_t A
\quad\Longleftrightarrow\quad
\exists v\in W\,(wTv\wedge \mathcal F,V,v\vDash A).
$$

These clauses also make sense for an arbitrary predicate $A:W\to\{\mathrm{false},\mathrm{true}\}$. We freely use that predicate-level notation when the internal syntax is irrelevant.

### 2.3 Persistence

To model a growing body of established results, we impose the following semantic property when needed.

**Definition 2.1 (Persistence of provability).** A temporal proof frame is persistent if, for every predicate $A$ and states $w,v$,

$$
wTv\ \text{and}\ \Box A(w)\quad\Longrightarrow\quad\Box A(v).
$$

Equivalently, the frame validates the scheme

$$
\Box A\to G\Box A.
$$

Persistence is monotonicity of established provability along time. It allows a later state to acquire new proofs; it only forbids the loss of proofs already available.

## 3. The temporal interaction principle

We now determine the exact assumptions behind the formula

$$
\Box A\to\Box\Box\Diamond_t A.
$$

### 3.1 Soundness under minimal relational assumptions

**Theorem 3.1 (Temporal Interaction Theorem).** Let $(W,R,T)$ be a frame in which $R$ is transitive and $T$ is reflexive. For every predicate $A$ on $W$ and every $w\in W$,

$$
\Box A(w)\quad\Longrightarrow\quad\Box\Box\Diamond_t A(w).
$$

Consequently, every formula instance $\Box A\to\Box\Box\Diamond_t A$ is valid on every such frame.

**Proof sketch.** Assume $\Box A(w)$. To prove $\Box\Box\Diamond_t A(w)$, choose $v$ with $wRv$ and then choose $u$ with $vRu$. By transitivity, $wRu$. The initial assumption gives $A(u)$. By reflexivity, $uTu$, so the state $u$ itself witnesses $\Diamond_t A(u)$. Since $u$ and $v$ were arbitrary, the two universal proof quantifiers are satisfied. $\square$

The proof uses neither temporal transitivity nor a compatibility law between $R$ and $T$. It also uses no well-foundedness assumption on $R$. This minimality matters because it reveals that the temporal content of the theorem occurs only in the final reflexive witness.

### 3.2 Factorization through axiom $4$

**Lemma 3.2 (Proof-transitivity principle).** If $R$ is transitive, then for every predicate $A$,

$$
\Box A\to\Box\Box A
$$

is valid.

**Proof sketch.** If $\Box A(w)$, $wRv$, and $vRu$, transitivity gives $wRu$, hence $A(u)$. Therefore $\Box A(v)$ for every $R$-successor $v$ of $w$. $\square$

**Lemma 3.3 (Reflexive-time principle).** If $T$ is reflexive, then for every predicate $A$,

$$
A\to\Diamond_t A
$$

is valid.

**Proof sketch.** If $A(w)$, temporal reflexivity gives $wTw$, so $w$ witnesses $\Diamond_t A(w)$. $\square$

**Theorem 3.4 (Factorization Theorem).** On any frame with transitive $R$ and reflexive $T$, an assumption $\Box A(w)$ yields both

$$
\Box\Box A(w)
$$

and

$$
\Box\Box\Diamond_t A(w).
$$

The second conclusion is obtained from the first by applying $A\to\Diamond_t A$ at each innermost proof-accessible state.

**Proof sketch.** The first conjunct is Lemma 3.2. For the second, expand $\Box\Box A(w)$. At every state $u$ reached by two $R$-steps, $A(u)$ holds. Lemma 3.3 changes this to $\Diamond_t A(u)$, preserving both outer universal quantifiers. $\square$

**Corollary 3.5.** The formula $\Box A\to\Box\Box\Diamond_t A$ does not, by itself, witness a strict extension of any modal logic that already validates $\Box A\to\Box\Box A$ and is combined with reflexive temporal semantics.

This is a statement about the evidential role of the formula, not a claim that every temporal provability calculus collapses to ordinary modal logic. A richer calculus may be strictly stronger for other reasons. The corollary only says that strictness cannot be inferred from this interaction scheme alone.

## 4. Proof persistence and proof gain

### 4.1 Loss of an established proof

**Theorem 4.1 (No-Proof-Loss Theorem).** Let $(W,R,T)$ be a persistent temporal proof frame. For every predicate $A$ and states $today,tomorrow\in W$ satisfying $today\,T\,tomorrow$,

$$
\neg\bigl(\Box A(today)\wedge\neg\Box A(tomorrow)\bigr).
$$

**Proof sketch.** Suppose both conjuncts hold. Persistence applied to $today\,T\,tomorrow$ and $\Box A(today)$ gives $\Box A(tomorrow)$, contradicting the second conjunct. $\square$

The theorem refutes a “tomorrow but not today” paradox only if the phrase is being used to describe loss: established today, unestablished tomorrow. It does not address the converse order.

### 4.2 Gain of a proof

**Theorem 4.2 (Proof-Gain Satisfiability Theorem).** There exists a temporal proof frame, a predicate $A$, and states $today,tomorrow$ such that

$$
today\,T\,tomorrow,
$$

$$
\neg\Box A(today),
$$

and

$$
\Box A(tomorrow).
$$

**Proof sketch.** Take $W=\{0,1\}$, with $today=0$ and $tomorrow=1$. Let

$$
T=\{(0,0),(0,1),(1,1)\}
$$

and

$$
R=\{(0,1)\}.
$$

The relation $R$ is transitive because there is no composable pair of $R$-edges. The relation $T$ is reflexive and transitive. Define $A(1)$ to be false; the value at $0$ may be arbitrary. At state $0$, the sole $R$-successor is $1$, where $A$ fails, so $\Box A(0)$ is false. At state $1$, there are no $R$-successors, so $\Box A(1)$ is true by universal vacuity. Thus proof gain is realized. This frame also satisfies persistence: the only nontrivial temporal move is from $0$ to $1$, and the antecedent $\Box A(0)$ fails for the selected predicate; more generally, if a predicate is boxed at $0$, it holds at $1$, while boxing at $1$ is automatic. $\square$

The use of a terminal proof state makes the example especially small. If an intended interpretation rejects vacuous provability at terminal states, one can add a reflexive proof loop at $1$ and set $A(1)$ true, but then transitivity forces an additional edge structure and the frame class must be adjusted if irreflexive provability accessibility is required. The two-state model above is sufficient for the stated relational semantics.

**Corollary 4.3.** No calculus sound for all temporal proof frames of this class can derive the negation of proof gain,

$$
\neg\bigl(\neg\Box A(today)\wedge\Box A(tomorrow)\bigr),
$$

when the two times may be interpreted as in Theorem 4.2.

Theorems 4.1 and 4.2 establish the desired asymmetry. Monotone knowledge rules out regression but permits progress.

## 5. Tree diagrams and the leaf obstruction

We now turn to a finite graph result with a parallel structural lesson.

### 5.1 Finite trees

A **finite simple graph** consists of a finite vertex set $V$ and an irreflexive symmetric adjacency relation. The degree $\deg(v)$ of a vertex $v$ is the number of its neighbors. A **tree** is a connected simple graph containing no cycle. We include the one-vertex graph as a tree; its unique vertex has degree $0$.

**Lemma 5.1 (Edge count for trees).** A finite tree with $n$ vertices has exactly $n-1$ edges.

**Proof sketch.** Induct on $n$. The one-vertex tree has no edges. For $n>1$, a standard maximal-path argument supplies a leaf. Removing the leaf and its incident edge leaves a tree on $n-1$ vertices. By induction it has $n-2$ edges, so the original tree has $n-1$. Equivalently, the result follows by induction from connectedness and acyclicity. $\square$

**Lemma 5.2 (Handshaking Lemma).** For every finite simple graph,

$$
\sum_{v\in V}\deg(v)=2|E|.
$$

**Proof sketch.** Count incidences $(v,e)$ where vertex $v$ is an endpoint of edge $e$. Summing by vertices gives the left side. Summing by edges gives $2|E|$ because every simple edge has two endpoints. $\square$

**Theorem 5.3 (Tree Degree-Sum Theorem).** If $G$ is a tree on $n$ vertices, then

$$
\sum_{v\in V}\deg(v)=2(n-1).
$$

**Proof sketch.** Combine Lemma 5.1, which gives $|E|=n-1$, with Lemma 5.2. $\square$

**Theorem 5.4 (Leaf Existence Theorem).** Every nonempty finite tree has a vertex $v$ with

$$
\deg(v)\le 1.
$$

**Proof sketch.** Suppose instead that every vertex had degree at least $2$. Summing would give

$$
2n\le\sum_v\deg(v).
$$

By Theorem 5.3 the right side is $2(n-1)$, so $2n\le 2n-2$, a contradiction. $\square$

For a tree with at least two vertices, connectedness excludes degree $0$, so the resulting vertex has degree exactly $1$. The weaker degree-at-most-$1$ formulation uniformly includes the one-vertex case.

### 5.2 Singleton dominance

Consider a simply-laced diagram whose underlying graph is a finite tree with vertex set $I$. Let $\alpha_v$ denote the simple root indexed by $v$, let $\rho$ denote the half-sum of positive roots, and let $\beta_I$ denote the correction associated with the full diagram. For a singleton marked set $\{v\}$, define the corrected weight

$$
\lambda_{\{v\},I}=2\rho-\beta_I-\alpha_v.
$$

The representation-theoretic input is the following local criterion.

**Definition 5.5 (Singleton $\rho$-dominance criterion).** In the simply-laced setting considered here, the singleton correction at $v$ is called $\rho$-dominant precisely when

$$
\deg(v)\ge 2.
$$

Equivalently,

$$
\lambda_{\{v\},I}\text{ is $\rho$-dominant}
\quad\Longleftrightarrow\quad
\deg(v)\ge 2.
$$

This criterion translates a weight inequality into a graph-degree condition.

**Theorem 5.6 (Leaf Obstruction Theorem).** Every nonempty simply-laced tree diagram contains a vertex $v$ such that the singleton correction

$$
\lambda_{\{v\},I}=2\rho-\beta_I-\alpha_v
$$

is not $\rho$-dominant.

**Proof sketch.** By Theorem 5.4, choose $v$ with $\deg(v)\le 1$. Definition 5.5 says singleton dominance requires $\deg(v)\ge 2$. Therefore the correction at $v$ is not $\rho$-dominant. $\square$

**Corollary 5.7.** In every nonempty tree component, at least one singleton marking is excluded by the dominance condition. More generally, every leaf is excluded.

This obstruction is intrinsic to acyclicity. A cycle can have every vertex of degree $2$ and therefore need not exhibit the same singleton failure. Thus the forest hypothesis is not merely a simplifying convention: it forces low-degree vertices that prune the possible marked data.

## 6. Finite algorithms

### 6.1 Model checking temporal formulas

For a finite frame with $N$ states, store $R$ and $T$ as Boolean adjacency matrices. A valuation of an atom is a Boolean vector of length $N$. The modal operations are computed by

$$
(\Box A)[w]=\bigwedge_{v:R[w,v]}A[v],
$$

$$
(GA)[w]=\bigwedge_{v:T[w,v]}A[v],
$$

and

$$
(\Diamond_t A)[w]=\bigvee_{v:T[w,v]}A[v].
$$

A bottom-up traversal of a formula with $m$ subformulas takes $O(mN^2)$ time with dense matrices and $O(m(N+|R|+|T|))$ time with adjacency lists. Memory use is $O(mN)$ if the value of each subformula is retained at every state.

To test the interaction scheme for one propositional atom on a fixed frame, enumerate all $2^N$ truth vectors $A$ and all states $w$. For each vector, compare $\Box A$ with $\Box\Box\Diamond_t A$. The resulting exhaustive procedure takes $O(2^N N(N+|R|+|T|))$ time in a straightforward adjacency-list implementation. It is exponential because validity quantifies over valuations, but it is practical for small countermodel searches.

Structural assumptions can be checked first. Reflexivity of $T$ takes $O(N)$ adjacency queries. Transitivity of $R$ takes $O(N^3)$ time with a dense triple loop, or can be tested using transitive closure. If both checks succeed, Theorem 3.1 certifies the interaction scheme for all valuations without enumerating them.

### 6.2 Detecting proof gain and proof loss

Given designated states $today$ and $tomorrow$ and a valuation $A$, compute $\Box A$ at both states. The pattern

$$
\Box A(today)=\mathrm{true},\qquad
\Box A(tomorrow)=\mathrm{false}
$$

is proof loss. The reverse pattern is proof gain. A persistence checker can test whether each temporal edge $wTv$ preserves $\Box A$ for every enumerated valuation. At the frame level, one may seek a relational characterization, but direct exhaustive checking is sufficient for small experiments.

### 6.3 Tree and dominance checking

For a graph with $n$ vertices and $m$ edges, depth-first search checks connectedness and acyclicity in $O(n+m)$ time. During the same traversal, one computes all degrees. If the graph is a tree, verify the identity

$$
\sum_v\deg(v)=2(n-1).
$$

Scanning the degree array then finds all leaves in $O(n)$ time. Under the singleton criterion, the same list is exactly a list of immediate non-dominance witnesses. The full procedure is linear in the graph size.

## 7. Applications

### 7.1 Growing proof repositories

A versioned theorem repository naturally supplies temporal states. The persistence law expresses an idealized guarantee that accepted results remain available after an update. Proof gain represents newly added lemmas. The distinction can guide regression testing: loss is an anomaly to detect, while gain is expected behavior.

### 7.2 Dependency-aware search

In automated proof search, a state may record the lemmas currently discovered. Temporal edges represent search expansion or database growth. Proof edges represent semantic or deductive accessibility. The interaction theorem warns that some apparently temporal guarantees are consequences of ordinary transitivity plus reflexive time and therefore contribute no new pruning power. More informative axioms must relate genuinely later states to proof structure in a nontrivial way.

### 7.3 Proof mining and provenance

Time stamps can express when a lemma became available, while proof accessibility records where it can be used. Persistence allows provenance queries such as: if a theorem was established at release $t$, is it established at every later release? Proof-gain witnesses identify the first release at which a theorem becomes available. A richer system could add explicit “next” or “strict future” operators, avoiding the reflexive witness that trivializes $A\to\Diamond_t A$.

### 7.4 Diagram classifications

The leaf obstruction reduces a weight-theoretic exclusion to graph preprocessing. Before evaluating more expensive representation-theoretic data, one may compute degrees. Every leaf is immediately known to reject a singleton marking. In large forests this creates a simple linear-time pruning stage.

## 8. Discussion and limitations

The temporal results establish soundness statements, not completeness. To state a completeness theorem, one must first specify a deductive calculus: its axioms, inference rules, and intended frame class. “Temporal provability logic” is not a unique object until those choices are made.

Likewise, decidability does not follow merely from the validity of one interaction scheme. A finite model property with an explicit size bound would support bounded countermodel search, but such a property remains to be proved. Filtration is a plausible route; interaction between the two relations must be shown to survive the quotient construction.

Arithmetic introduces further choices. A time-stamped interpretation requires an increasing sequence of recursively axiomatized theories $(PA_t)$. Different clocks can validate different interaction principles. One might let $PA_t$ be bounded fragments, stages of an enumeration, or iterated extensions. An arithmetical completeness theorem must name the sequence and the modal calculus and prove both soundness and completeness under every arithmetic substitution.

The phrase “provable tomorrow but not today” also requires care about self-reference. The model in Theorem 4.2 treats $A$ as an ordinary predicate and shows that non-self-referential proof gain is satisfiable. A self-referential sentence asserting its own future provability and present unprovability raises additional diagonal and coding issues not settled by that model. The semantic distinction nevertheless blocks a common overstatement: persistence refutes proof loss, not proof gain.

Finally, the tree result depends on the singleton criterion specific to the simply-laced dominance setting. The graph lemmas are universal, but translating low degree into failure of dominance requires that criterion. For diagrams with multiple bonds or modified weights, the threshold may change.

## 9. Future work

A precise research program follows from these boundaries.

1. **Finite-frame completeness.** Define a Hilbert calculus containing ordinary provability logic, temporal $S4$, persistence $\Box A\to G\Box A$, and explicit interaction axioms. Determine whether every formula valid on all finite temporal proof frames is derivable.

2. **Finite model property.** Investigate the conjecture that every non-derivable formula $A$ has a countermodel with at most

   $$
   2^{2s(A)}
   $$

   states, where $s(A)$ is its number of subformulas. Filtration and exhaustive bounded search provide a testable route.

3. **Decidability.** If the preceding bound and completeness theorem hold, construct a terminating finite-frame model checker that decides derivability.

4. **Non-refutability of proof gain.** Generalize the two-state countermodel to characterize frame classes in which proof gain remains possible. Any proposed universally sound refutation must fail on the explicit model unless additional assumptions exclude it.

5. **Arithmetic clocks.** Fix an increasing recursively axiomatized sequence $(PA_t)$ and interpret $\Box_t A$ as

   $$
   \operatorname{Prov}_{PA_t}(\ulcorner A\urcorner).
   $$

   Then compare the theorems of a specified recursively enumerable modal calculus with formulas valid under all arithmetic substitutions.

6. **Strict future.** Replace reflexive $\Diamond_t$ by a modality quantifying over genuinely later states. The implication $A\to\Diamond_t A$ then fails in general, so the factorization theorem no longer applies automatically. This may isolate genuinely temporal interaction principles.

7. **Forest-wide dominance counts.** Count excluded singleton markings componentwise and investigate stronger lower bounds based on the number of leaves, branching structure, or degree distribution.

## 10. Conclusion

The main temporal interaction formula is valid, but its validity has a simple source: proof transitivity supplies two nested boxes, and temporal reflexivity lets the present witness future possibility. The factorization prevents the formula from serving alone as evidence of a strict temporal extension of ordinary provability logic.

Persistence yields a sharp and useful conclusion: a proof established today cannot disappear at a specified later stage. Yet discovery remains possible. A two-state model realizes a proposition that is not boxed today but is boxed tomorrow. Any adequate temporal account of mathematical growth should preserve this difference between loss and gain.

The tree application provides a complementary structural principle. Since the total degree of a tree is $2(n-1)$, a nonempty tree has a leaf. When singleton dominance requires degree at least $2$, every tree diagram contains a forbidden singleton. In both settings, a local witness—reflexivity at one state or low degree at one vertex—settles a global-looking claim. These results clarify what is established, expose what remains conjectural, and provide concrete finite procedures for the next stage of investigation.
