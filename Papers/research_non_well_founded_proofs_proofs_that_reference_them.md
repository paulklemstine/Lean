# Guarded Circular Proof Graphs: Ordinal Descent, Soundness, and the Limits of Self-Reference

**Aristotle**  
**17 July 2026**

## Abstract

Proofs are conventionally represented by well-founded trees, whereas recursive programs, protocol reductions, and cyclic derivations are naturally represented by graphs. This paper studies a minimal implication calculus in which proof graphs may have arbitrary node types and dependency structure, while validity is controlled by an ordinal-valued progress certificate. A graph is locally well typed when each node satisfies the assumption or implication-introduction rule indicated by its label, and it is guarded when ordinal rank strictly decreases along every dependency edge. The central soundness theorem states that every guarded, locally well-typed proof graph unfolds nodewise into an ordinary natural-deduction derivation. The proof uses well-founded induction on ordinal rank.

Several boundary results sharpen the interpretation of this theorem. The standard proof of $P\to P$ is a height-one, two-node derivation with a rank-$1$ implication node and a rank-$0$ assumption leaf; it is not genuinely circular. No direct self-loop admits a decreasing ordinal rank, and, more generally, strict descent forbids every nonempty finite dependency cycle. Thus edgewise ordinal guarding validates graph compression and apparent back-reference but cannot validate genuinely cyclic justification. A complementary diagonal result explains why, in a sound self-referential system, a Gödel sentence asserting its own unprovability remains unprovable. The structural and semantic obstructions are carefully distinguished. We conclude with certificate-checking algorithms, applications to recursive security arguments, and directions involving Scott domains, trace conditions, and guarded modalities.

## 1. Introduction

Self-reference occupies an ambiguous place in logic. Recursion is indispensable in mathematics and computation: functions call themselves on smaller inputs, infinite streams reveal one constructor before continuing, and inductive arguments invoke hypotheses at lower complexity. Yet the inference “$P$ holds because this proof of $P$ says so” is empty. Both productive recursion and vicious circularity contain a backward reference; the difference is progress.

This paper isolates that difference in a small setting. The language contains atomic propositions and implication. Ordinary derivations use assumptions and implication introduction. We enlarge the syntax from finite proof trees to proof graphs whose nodes carry local instructions and may, at the representational level, have arbitrary dependencies. We then impose a global ordinal ranking. Every dependency must lead to a node of strictly smaller rank.

The approach deliberately separates three notions:

1. **Graph syntax:** a collection of labelled nodes with dependency pointers;
2. **Local correctness:** each node's instruction agrees with its context and conclusion;
3. **Global justification:** dependency traversal is controlled by a well-founded progress measure.

This separation prevents two common mistakes. First, local rule compliance does not by itself make a cyclic diagram sound. Second, the familiar proof of $P\to P$ is not circular merely because it temporarily assumes $P$. Its assumption occurs in an enlarged local context and is discharged by implication introduction.

Our principal result is a conservativity theorem: ordinal-guarded graphs yield nothing beyond ordinary derivations. This is a positive result because graph presentations can compactly share structure and express recursive organization. It is also a limitation: if strict rank descent is imposed on every edge, no genuine finite cycle survives. Any future semantics for truly cyclic proofs must weaken edgewise descent while preserving a global progress condition.

The cryptographic relevance lies in recursive reductions. Security arguments are often organized as graphs of games and adversary transformations. A reduction that returns to the same claim without lowering any well-founded measure is no argument at all. A rank certificate can make progress explicit and mechanically checkable at the mathematical level: protocol phase, remaining rounds, syntactic complexity, or a lexicographic combination may supply the rank.

The paper is self-contained. Section 2 defines formulas and ordinary derivability. Section 3 introduces proof graphs, local typing, and guardedness. Section 4 proves soundness. Sections 5 and 6 establish the height-one identity example and the impossibility of ranked cycles. Section 7 distinguishes the structural loop obstruction from diagonal unprovability. Sections 8 and 9 give algorithms and applications. Sections 10 and 11 discuss fixed points, limitations, and future research.

## 2. Implication logic and ordinary derivations

### 2.1 Formulas

Fix an arbitrary set $\mathcal A$ of atomic propositions.

**Definition 2.1 (Formulas).** The set $\mathsf{Form}(\mathcal A)$ is generated inductively by:

- every $a\in\mathcal A$ determines an atomic formula;
- if $A,B\in\mathsf{Form}(\mathcal A)$, then $A\to B\in\mathsf{Form}(\mathcal A)$.

A **context** $\Gamma$ is a finite list of formulas. Writing $A::\Gamma$ means adjoining $A$ at the front of the list. The order will not matter for the results below, but lists provide a concrete representation.

### 2.2 Natural deduction

**Definition 2.2 (Ordinary derivability).** The judgment $\Gamma\vdash A$ is generated by two rules:

$$
\frac{A\in\Gamma}{\Gamma\vdash A}
\quad\text{(assumption)}
$$

and

$$
\frac{A::\Gamma\vdash B}{\Gamma\vdash A\to B}
\quad\text{(implication introduction).}
$$

Derivability is inductively generated, so every ordinary derivation is a finite well-founded tree. We intentionally omit implication elimination because it is unnecessary for the central phenomenon. The method extends to additional finitary rules when every premise is assigned smaller rank than its conclusion node.

The assumption rule must be read locally: it concludes $A$ only in a context where $A$ is available. It is not an unconditional proof of $A$. This distinction becomes decisive in the identity example.

## 3. Proof graphs and progress certificates

### 3.1 Graph instructions

Let $V$ be any set of nodes. No finiteness, acyclicity, or decidability assumption is imposed on $V$.

**Definition 3.1 (Local instruction).** A node carries one of the following instructions:

1. **Assumption:** no child is required.
2. **Implication introduction:** data $A$, $B$, and a designated child $m\in V$ are supplied.

**Definition 3.2 (Proof graph).** A proof graph $G$ consists of three assignments on $V$:

- a context $\Gamma_n$ for each node $n$;
- a conclusion $C_n$ for each node $n$;
- a local instruction $I_n$ for each node $n$.

This terminology does not presuppose validity. A proof graph is initially only a candidate derivation diagram.

### 3.2 Local typing

**Definition 3.3 (Local well-typedness).** A proof graph is locally well typed when every node obeys the following condition.

- If $I_n$ is the assumption instruction, then $C_n\in\Gamma_n$.
- If $I_n$ is implication introduction with formulas $A,B$ and child $m$, then

$$
C_n=A\to B,\qquad \Gamma_m=A::\Gamma_n,\qquad C_m=B.
$$

Local well-typedness verifies that each node looks like a legal rule application. It does not examine unbounded chains of dependencies. In particular, it cannot by itself guarantee that repeatedly following children eventually reaches an assumption.

### 3.3 Ordinal guards

We use only two standard properties of ordinals: strict order is transitive and irreflexive, and it is well founded. The latter means that induction is available for any relation obtained by pulling ordinal order back along a rank function.

**Definition 3.4 (Ordinal ranking and guardedness).** An ordinal ranking is a map

$$
\rho:V\longrightarrow \mathsf{Ord}.
$$

A proof graph is **guarded by $\rho$** if every implication-introduction node $n$ with child $m$ satisfies

$$
\rho(m)<\rho(n).
$$

Assumption nodes have no outgoing dependency and impose no inequality.

The terminology “guarded” expresses a progress discipline. An edge may point anywhere in the concrete representation, including to a node displayed earlier, but it must point downward in rank. Thus textual or graphical back-reference is separated from logical circularity.

## 4. Soundness by well-founded unfolding

We now prove the central theorem.

**Theorem 4.1 (Guarded Graph Soundness).** *Let $G$ be a locally well-typed proof graph on a node set $V$, and let $\rho:V\to\mathsf{Ord}$ guard every dependency. Then, for every node $n\in V$, there exists an ordinary derivation*

$$
\Gamma_n\vdash C_n.
$$

**Proof sketch.** Define a dependency order by $m\prec n$ exactly when $\rho(m)<\rho(n)$. Since strict ordinal order is well founded, so is $\prec$. Apply well-founded induction to an arbitrary node $n$.

If $n$ is an assumption node, local well-typedness gives $C_n\in\Gamma_n$, and the ordinary assumption rule yields $\Gamma_n\vdash C_n$.

If $n$ is an implication-introduction node with formulas $A,B$ and child $m$, local well-typedness gives

$$
C_n=A\to B,
\qquad
\Gamma_m=A::\Gamma_n,
\qquad
C_m=B.
$$

Guardedness gives $\rho(m)<\rho(n)$, so the induction hypothesis applies to $m$ and yields

$$
A::\Gamma_n\vdash B.
$$

Implication introduction now gives $\Gamma_n\vdash A\to B$, which is the required judgment after substituting $C_n=A\to B$. These are all possible instructions. $\square$

### 4.1 Interpretation

The theorem is a conservativity statement. A guarded graph cannot derive a proposition unavailable to ordinary natural deduction. Every graph node can be unfolded into a finite derivation, although the entire graph may use an infinite node set and ordinal ranks need not be natural numbers.

The theorem also identifies the load-bearing assumption. Local typing supplies the rule-specific equalities, but well-founded descent licenses recursive use of child derivations. Without descent, the attempted proof would invoke itself without reaching a base case.

### 4.2 Generalization pattern

The same argument applies to any finitary proof system. For a rule with children $m_1,\ldots,m_k$, require $\rho(m_i)<\rho(n)$ for every premise. Local typing must assert that the children carry precisely the rule's premise sequents. Well-founded induction then reconstructs an ordinary derivation. Infinitary rules require additional care because the target ordinary calculus must itself permit the corresponding family of premises.

## 5. The height-one identity derivation

Fix a formula $P$. Consider two nodes, a root $r$ and a leaf $\ell$.

- At $r$, set $\Gamma_r=[]$, $C_r=P\to P$, and use implication introduction with child $\ell$.
- At $\ell$, set $\Gamma_\ell=[P]$, $C_\ell=P$, and use the assumption instruction.
- Assign ranks $\rho(r)=1$ and $\rho(\ell)=0$.

The graph is locally well typed: the leaf conclusion occurs in its context, and the child of the root has exactly the context and conclusion demanded by implication introduction. It is guarded because $0<1$.

**Theorem 5.1 (Height-One Identity).** *For every formula $P$, the construction above has root ordinal height $1$, leaf height $0$, and yields an ordinary derivation*

$$
[]\vdash P\to P.
$$

**Proof sketch.** The leaf derives $P$ from context $[P]$ by assumption. The root discharges that occurrence of $P$ by implication introduction. Equivalently, Theorem 4.1 applies to the locally typed rank-$1$ graph. $\square$

This theorem directly addresses a misleading description of identity as “proving $P$ by assuming $P$.” The temporary assumption proves $P$ only inside the hypothetical context $[P]$. The final conclusion is the implication $P\to P$, not the unconditional proposition $P$. The construction is an ordinary two-node tree and contains no self-reference.

## 6. Strict descent excludes cycles

### 6.1 Direct self-reference

**Theorem 6.1 (No Guarded Self-Reference).** *For every node $n$ and every ordinal ranking $\rho$, the inequality $\rho(n)<\rho(n)$ is false. Hence a direct self-dependency cannot satisfy edgewise ordinal guardedness.*

**Proof sketch.** Strict ordinal order is irreflexive. $\square$

A pure one-node loop therefore has no ordinal height compatible with strict descent.

**Corollary 6.2 (Pure Loop Obstruction).** *There exists no ordinal ranking of a singleton proof graph whose unique dependency edge begins and ends at its sole node and strictly decreases rank.*

This is the minimal structural model of unsupported circularity. The failure is not that an appropriate large ordinal has yet to be found. No ordinal can be strictly below itself.

### 6.2 Arbitrary finite cycles

The obstruction propagates along paths.

**Theorem 6.3 (Acyclicity of Ranked Dependencies).** *Let $E(a,b)$ mean that node $a$ depends on node $b$. Suppose $\rho(b)<\rho(a)$ whenever $E(a,b)$. For every integer $k>0$ and every path*

$$
n_0\,E\,n_1\,E\,\cdots\,E\,n_k,
$$

*one has $n_0\ne n_k$. In particular, the dependency relation has no nonempty finite directed cycle.*

**Proof sketch.** Each path edge yields a strict decrease. By transitivity,

$$
\rho(n_k)<\rho(n_0).
$$

If $n_k=n_0$, substitution gives $\rho(n_0)<\rho(n_0)$, contradicting irreflexivity. $\square$

A stronger observation follows from well-foundedness: there is no infinite dependency chain either. Thus edgewise ordinal descent converts any reachable dependency structure into a well-founded one, irrespective of how the graph is drawn.

### 6.3 Consequence for the fixed-point proposal

A proposed semantics might identify a circular proof with the limit of finite unfoldings. Theorems 6.1 and 6.3 show that strict decrease on every dependency edge cannot implement this proposal for genuine cycles. If a back-edge completes a cycle, composing strict inequalities around the cycle is contradictory.

This does not refute all cyclic proof theories. It identifies the necessary change: progress cannot be required at every edge. A valid cyclic system must instead use a global trace criterion, a modal delay, parity acceptance, or another condition that permits recurrence while ruling out unproductive loops.

## 7. Diagonal self-reference and unprovability

Structural circularity and semantic diagonalization should not be conflated.

Consider a sufficiently expressive deductive system equipped with a sentence $G$ that asserts its own unprovability. Assume the system is sound in the relevant semantics: every provable sentence is true. Then $G$ is true but unprovable under the standard diagonal conditions.

**Theorem 7.1 (Diagonal Unprovability).** *In a sound diagonal system, the Gödel sentence asserting “I am not provable in this system” is not provable in that system.*

**Proof sketch.** Suppose $G$ were provable. By soundness, $G$ would be true. But the content of $G$ is that $G$ is not provable, contradicting the supposition. Therefore $G$ is unprovable. Under the usual diagonal specification and soundness assumptions, its assertion is consequently true. $\square$

Theorem 7.1 is semantic: it relies on the intended meaning of the provability predicate, the fixed-point construction of $G$, and soundness. Theorem 6.1 is structural: it uses only irreflexivity of ordinal order. The latter says that a pure self-loop has no decreasing rank; it does not independently establish Gödel's theorem. Conversely, diagonal unprovability does not imply that every graph containing a syntactic back-reference is invalid.

The two results nevertheless illuminate a common boundary. Neither a bare dependency loop nor a negative assertion of its own provability status creates evidence. Self-description is not self-justification.

## 8. Algorithms and certificate checking

For finite graphs and effectively represented ranks, the definitions lead to simple validation procedures.

### 8.1 Local typing and guardedness

Assume a graph has $|V|$ nodes and $|E|$ dependency edges. Each formula and context has an explicit finite representation.

**Algorithm 8.1 (Guarded Proof-Graph Validator).**

1. For each assumption node $n$, test whether $C_n$ occurs in $\Gamma_n$.
2. For each implication node $n$ labelled by $A,B$ with child $m$:
   - test $C_n=A\to B$;
   - test $\Gamma_m=A::\Gamma_n$;
   - test $C_m=B$;
   - test $\rho(m)<\rho(n)$.
3. Accept exactly when every test succeeds.

With hashed or canonical formulas, the graph traversal costs $O(|V|+|E|)$ apart from context comparison and rank comparison. If ranks are natural numbers, rank checks are ordinary integer comparisons. If ordinals below a fixed notation system are represented in canonical form, complexity additionally depends on the notation length.

**Proposition 8.2 (Validator Correctness).** *If Algorithm 8.1 accepts, every node's sequent is ordinarily derivable.*

**Proof sketch.** Acceptance is exactly local well-typedness plus guardedness, so Theorem 4.1 applies. $\square$

### 8.2 Cycle diagnosis

A separate finite procedure can expose an immediate impossibility before rank checking.

**Algorithm 8.3 (Dependency-Cycle Diagnostic).**

1. Run depth-first search while marking unvisited, active, and completed nodes.
2. If an edge reaches an active node, report the corresponding directed cycle.
3. Otherwise, output a reverse topological ordering.

The running time is $O(|V|+|E|)$. By Theorem 6.3, finding a directed cycle proves that no edgewise strictly decreasing ordinal ranking exists. For a finite acyclic graph, natural-number ranks suffice: assign each node the maximum remaining dependency-path length. Hence, in the finite case, acyclicity is not merely necessary but sufficient for the existence of a decreasing natural-number rank.

### 8.3 Constructing ranks on finite acyclic graphs

**Proposition 8.4 (Finite Rank Construction).** *Every finite directed acyclic dependency graph admits a ranking $h:V\to\mathbb N$ such that $h(m)<h(n)$ whenever $n$ depends on $m$.*

**Proof sketch.** In reverse topological order, set an assumption or sink node to height $0$. For every other node $n$, set

$$
h(n)=1+\max\{h(m):n\text{ depends on }m\}.
$$

Every dependency child then has height at most $h(n)-1$. $\square$

This construction also computes the minimum possible maximum natural rank when height is measured by longest dependency path.

## 9. Applications

### 9.1 Recursive security reductions

A cryptographic reduction transforms an adversary against one claim into an adversary against another. Complex proofs may share subreductions or revisit protocol components. A dependency graph can compress this organization, while a rank can measure remaining rounds, unresolved game hops, oracle nesting, or a tuple ordered lexicographically.

Theorem 4.1 provides a discipline for such recursive arguments: every recursive invocation must lower the measure. A purported reduction of security claim $S$ to exactly $S$ with unchanged parameters is rejected as a self-loop. A reduction from $S(k)$ to $S(k-1)$ is potentially legitimate when $k$ is a natural-number rank and a base case is supplied.

The theorem does not establish cryptographic security by itself. Local nodes must still encode sound reduction steps, and quantitative losses must be tracked separately. Its role is structural: it prevents recursive organization from concealing circular dependence.

### 9.2 Termination and recursive programs

The analogy with recursion is exact at the level of well-founded induction. A recursive function may call itself on an argument of smaller rank. A guarded proof node may invoke a child derivation of smaller rank. In both cases, well-foundedness converts a recursive specification into a finite computation or derivation for each input node.

The analogy also clarifies why a fixed-point slogan is insufficient. The equation $x=x$ has every value as a fixed point and selects none. Likewise, a proof node that merely points to itself provides no constructor and no base evidence. Productive definitions require guarded structure, not only algebraic self-equality.

### 9.3 Proof compression

Directed acyclic graphs can represent repeated subderivations once rather than duplicating them in a tree. Theorem 4.1 justifies unfolding this compressed representation. The unfolded tree may be exponentially larger than the graph, so validation of the graph and rank certificate can be more economical than explicit expansion.

This observation distinguishes intensional size from extensional derivation size. A compact certificate can encode shared work without introducing new logical strength.

### 9.4 Cyclic reasoning about inductive predicates

Established cyclic proof methods often permit cycles but impose an infinite-trace progress condition. The present acyclicity theorem explains why: demanding strict decrease at every local edge would collapse the method to directed acyclic graphs. To gain genuine cyclic compression, some edges must preserve or increase a local measure while every infinite trace repeatedly encounters progress.

Thus edgewise guarding is a baseline semantics, not a complete theory of cyclic proof.

## 10. Domain-theoretic perspective

One may order partial proof trees by information content. An unfinished leaf is below any refinement that replaces it by a rule and further partial subtrees. Directed families of finite approximants can then have infinite trees as least upper bounds. This suggests a Scott-domain semantics for proof objects.

However, completion alone does not separate valid proofs from arbitrary infinite trees. The infinite unfolding of a pure self-loop may exist as a mathematical tree-like object while still containing no assumption leaf and no finite justification. The domain can house syntax more generously than the logic admits proofs.

Two choices arise. A **least-fixed-point semantics** includes only objects generated from finite rule applications and well-founded approximation; unsupported loops are excluded. A **greatest-fixed-point semantics** naturally admits infinite locally correct behavior but needs an independent productivity, fairness, or trace condition to prevent every self-loop from becoming a proof.

The guarded soundness theorem characterizes a robust fragment of the least-fixed-point side. Ordinal rank supplies a transfinite schedule of approximation: a node is justified after all lower-ranked dependencies. Yet because every dependency decreases, each individual path is well founded. The semantics does not validate circularity as a source of truth.

## 11. Limitations and future work

The calculus studied here contains only implication introduction and assumptions. Additional connectives and rules should follow the same induction pattern, but systems with infinitary rules, coinductive predicates, or semantic side conditions require separate analysis.

The results are qualitative. They do not bound the size of the unfolded ordinary derivation relative to a shared graph. Nor do they establish an asymptotic complexity theorem for ordinal notation comparison. They show soundness given a rank certificate, not how to find an optimal certificate in every setting.

Four directions are especially natural.

### 11.1 Algebraic-domain completion of finite approximants

Order finite partial proof trees by information content, placing an unfinished leaf below all its refinements. The conjecture is that ideal completion gives an algebraic Scott domain whose compact elements are exactly finite partial trees. The central problem is to characterize the least admissible fixed point selected by ordinal-guarded approximation. The key distinction must remain explicit: the domain may contain every infinite tree, while only a subset denotes valid derivations.

### 11.2 Trace conditions for genuine cyclic proofs

For cyclic proofs of inductive predicates, validity may correspond to a progress measure into a well-order such that every infinite branch contains infinitely many strict decreases between designated regeneration points. This Büchi-style condition would permit recurrence while requiring recurring progress. Theorem 6.3 pinpoints why such a weakening is necessary: edgewise descent eliminates the very cycles one hopes to study.

### 11.3 Modal productive self-reference

A guarded modal calculus can place recursive occurrences beneath a “later” modality. A recursive equation should have a unique productive solution when every self-reference is delayed by an observable constructor. The height-one identity and the rejected pure loop are elementary boundary tests: the former exposes a rule constructor and reaches an assumption, while the latter reveals nothing before recurring.

### 11.4 Complexity of ordinal certificates

For finite graphs with ranks in Cantor normal form below a fixed ordinal such as $\varepsilon_0$, one may ask whether checking local typing and descent is polynomial in graph size and rank-encoding length. Finding a minimum-rank certificate appears related to longest-path ranking on directed acyclic graphs and may define a harder optimization problem than verification itself.

## 12. Conclusion

Proof graphs allow sharing, recursive organization, and representations that need not look like trees. Their mathematical legitimacy, however, cannot rest on appearance or local syntax alone. An ordinal rank that decreases on every dependency edge supplies a transparent global certificate.

The Guarded Graph Soundness Theorem shows that every locally correct guarded graph unfolds into ordinary natural deduction. The standard identity $P\to P$ occupies the smallest positive case: a rank-$1$ root discharges a rank-$0$ assumption leaf. It is hypothetical reasoning, not self-justification. At the negative boundary, no direct loop can have smaller rank than itself, and no nonempty finite dependency cycle can survive transitive descent. A Gödel sentence's unprovability provides a complementary semantic warning, but it must not be conflated with the structural rank obstruction.

The resulting message is precise. Non-tree-shaped proof syntax is safe when it abbreviates well-founded justification. Strict ordinal descent certifies exactly such abbreviation and therefore does not create a new class of genuinely circular truths. Richer cyclic systems remain possible, but they must articulate a more global notion of productivity—through traces, modalities, or admissible fixed points—while continuing to reject the empty promise of a proof that cites only itself.
