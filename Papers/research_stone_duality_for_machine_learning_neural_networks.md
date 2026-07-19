# Finite Stone Semantics for Neural Activation Patterns

**Aristotle**  
**July 19, 2026**

## Abstract

A neural system with $k$ binary gates determines an activation map from its input space into the Boolean cube $\{0,1\}^k$. The correct finite semantic space is not generally the entire cube, but the range of this map: the set of feasible activation patterns. This paper develops a self-contained finite Stone-style representation of activation-invariant classifiers and decision regions. The feasible space has at most $2^k$ points, with equality exactly when every formal pattern is realizable. Every classifier constant on activation fibres factors uniquely through the feasible space. Pullback along the activation map embeds its powerset Boolean algebra into the input-space regions, preserving Boolean operations, and its image consists exactly of activation-invariant regions. The atoms of this algebra are singleton feasible patterns. Consequently, their number equals the feasible-pattern count and is at most $2^k$. Finally, the full powerset concept family on the feasible space has VC dimension exactly equal to its cardinality, whereas one fixed concept cannot shatter a nonempty set. These results distinguish formal patterns from feasible patterns, atoms from Boolean-algebra elements, hypothesis families from fixed classifiers, and activation patterns from geometric linear regions. Algorithms for enumerating finite feasible spaces, descending classifiers, constructing invariant regions, and measuring the resulting capacity are presented together with examples and applications.

## 1. Introduction

Rectified and thresholded neural networks combine continuous computation with discrete switching. Each gate records one of two states, and the simultaneous gate states form a binary activation pattern. It is tempting to identify a network with the entire Boolean cube of such patterns and to infer that $k$ gates always produce $2^k$ semantic states. It is equally tempting to identify activation states with linear regions and then equate either count with a VC dimension. These conclusions fail without qualifications.

The obstruction is feasibility. An input can realize only patterns lying in the range of the activation map. Gate correlations, duplicate neurons, geometric incompatibility, and degeneracy may exclude much of the formal cube. The resulting range is nevertheless rich enough to support a complete representation theorem. Any output that is insensitive to distinctions within an activation fibre descends to this finite range. Likewise, every decision region insensitive to such distinctions is the pullback of a unique subset of the range.

This construction is naturally interpreted through finite Stone duality. For a finite set $F$, the powerset $\mathcal P(F)$ is a Boolean algebra. Endowed with the discrete topology, $F$ is a Stone space: compact, Hausdorff, and totally disconnected, with every subset clopen. The points of $F$ correspond to the atoms of $\mathcal P(F)$, while arbitrary clopen sets correspond to Boolean combinations of atoms. In the neural setting, $F$ is the feasible activation space, and pullback translates clopen pattern sets into activation-invariant regions of the original input space.

The theory developed here is deliberately agnostic about the nature of the input space. It may be finite or infinite, Euclidean or combinatorial. Finiteness of the gate set ensures that the semantic quotient is finite. When cardinality is discussed, it suffices that the range itself be finite, which follows automatically from its inclusion in $\{0,1\}^k$. For elementary enumeration algorithms we assume a finite sample domain or an external feasibility oracle.

The principal conclusions are:

1. the feasible activation space has at most $2^k$ points, with equality precisely under surjectivity;
2. activation-invariant classifiers factor uniquely through this space;
3. its powerset realizes exactly the activation-invariant input regions and preserves Boolean structure;
4. its atoms are singleton feasible patterns;
5. the full family of subsets has VC dimension equal to the feasible-pattern count;
6. a singleton concept family cannot shatter any nonempty set.

These results establish an exact syntax–semantics bridge while locating the assumptions required for stronger geometric claims.

## 2. Definitions and basic setting

Let $X$ be a nonempty or empty input set, let $k\ge 0$ be an integer, and write

$$
Q_k=\{0,1\}^k
$$

for the Boolean activation cube. An element $p\in Q_k$ is a function from the $k$ gate indices to $\{0,1\}$, equivalently a binary word of length $k$. The cube contains exactly

$$
|Q_k|=2^k
$$

patterns, including one empty pattern when $k=0$.

**Definition 2.1 (Activation map).** An activation map is a function

$$
a:X\longrightarrow Q_k.
$$

For a neural network, $a(x)$ records the active or inactive status of each selected gate at input $x$.

**Definition 2.2 (Feasible activation space).** The feasible activation space is the range

$$
F_a=a(X)=\{p\in Q_k:\exists x\in X,\ a(x)=p\}.
$$

The canonical projection is the same rule with restricted codomain,

$$
\pi_a:X\longrightarrow F_a,\qquad \pi_a(x)=a(x).
$$

By the definition of a range, $\pi_a$ is surjective.

**Definition 2.3 (Activation fibre).** For $p\in F_a$, the activation fibre over $p$ is

$$
a^{-1}(p)=\{x\in X:a(x)=p\}.
$$

The fibres partition $X$. The quotient of $X$ by the equivalence relation $x\sim_a y$ if and only if $a(x)=a(y)$ is canonically identified with $F_a$.

**Definition 2.4 (Activation-invariant classifier).** A function $f:X\to Y$ is activation-invariant with respect to $a$ if

$$
a(x)=a(y)\Longrightarrow f(x)=f(y)
$$

for every $x,y\in X$.

**Definition 2.5 (Realization of a pattern region).** For $U\subseteq F_a$, its realization in input space is

$$
\mathcal R_a(U)=\pi_a^{-1}(U)=\{x\in X:a(x)\in U\}.
$$

**Definition 2.6 (Activation-invariant region).** A set $R\subseteq X$ is activation-invariant if membership is constant on activation fibres:

$$
a(x)=a(y)\Longrightarrow (x\in R\Longleftrightarrow y\in R).
$$

**Definition 2.7 (Atom).** In a powerset Boolean algebra, a set $A\subseteq F_a$ is an atom if it is nonempty and every nonempty subset $B\subseteq A$ satisfies $B=A$.

**Definition 2.8 (Shattering).** Let $\mathcal C\subseteq\mathcal P(Z)$ be a concept family. It shatters $S\subseteq Z$ if for every $T\subseteq S$ there is $C\in\mathcal C$ such that

$$
C\cap S=T.
$$

For finite $Z$, the VC dimension of $\mathcal C$ is the largest cardinality of a shattered subset, when such a largest cardinality exists.

## 3. Cardinality of the semantic space

The first theorem replaces an often-assumed equality by a sharp inequality and an exact equality criterion.

**Theorem 3.1 (Feasible-pattern bound).** For every activation map $a:X\to Q_k$,

$$
|F_a|\le 2^k.
$$

Equality holds if and only if $a$ is surjective onto $Q_k$.

**Proof sketch.** The set $F_a$ is a subset of $Q_k$, which has $2^k$ elements, proving the inequality. If $a$ is surjective, then $F_a=Q_k$ and equality follows. Conversely, a subset of a finite set having the same cardinality as the ambient set must be the entire set. Thus $|F_a|=|Q_k|$ implies $F_a=Q_k$, which is surjectivity. $\square$

This result is valid even when $X$ is infinite because the range lies in a finite cube. If $X$ is empty, then $F_a$ is empty, so equality can occur only in no ordinary finite cube; indeed $Q_k$ is always nonempty.

**Example 3.2 (Nested thresholds).** Let $X=\mathbb R$, $k=2$, and

$$
a(x)=\bigl(\mathbf 1[x>0],\mathbf 1[x>1]\bigr).
$$

Then

$$
F_a=\{(0,0),(1,0),(1,1)\}.
$$

The pattern $(0,1)$ is infeasible because $x>1$ implies $x>0$. Hence $|F_a|=3<4$.

**Example 3.3 (Independent signs).** Let $X=\mathbb R^k$ and define $a_i(x)=\mathbf 1[x_i>0]$. Every pattern is realized by choosing coordinate signs, so $F_a=Q_k$ and $|F_a|=2^k$.

**Example 3.4 (Duplicate gates).** If every gate repeats the same Boolean function $b:X\to\{0,1\}$, then at most the all-zero and all-one patterns occur. For $k$ large, the formal cube grows exponentially while the feasible space remains of size at most two.

## 4. Universal factorization through feasible patterns

The finite semantic space is characterized not only by counting but also by a universal property.

**Theorem 4.1 (Classifier factorization).** Let $f:X\to Y$ be activation-invariant. There exists a unique map $\bar f:F_a\to Y$ such that

$$
f=\bar f\circ\pi_a.
$$

**Proof sketch.** For $p\in F_a$, choose $x\in X$ with $a(x)=p$ and set $\bar f(p)=f(x)$. If $y$ is another witness, then $a(x)=a(y)$, and activation invariance yields $f(x)=f(y)$. Hence $\bar f$ is well-defined. The defining equation follows by choosing $x$ itself as a witness for $a(x)$. If $g:F_a\to Y$ also satisfies $f=g\circ\pi_a$, then for each $p$ choose a witness $x$; surjectivity gives $g(p)=g(\pi_a(x))=f(x)=\bar f(p)$. Therefore $g=\bar f$. $\square$

The theorem says that $F_a$ is a lossless compression for every activation-invariant observable. It is also the quotient universal property: maps constant on equivalence classes descend uniquely to the quotient.

**Corollary 4.2 (Binary labels).** If $f:X\to\{0,1\}$ is activation-invariant, then its positive decision region is a union of activation fibres. Equivalently, there is a unique $U\subseteq F_a$ such that

$$
f(x)=1\Longleftrightarrow a(x)\in U.
$$

**Proof sketch.** Apply Theorem 4.1 and take $U=\bar f^{-1}(\{1\})$. Uniqueness also follows from the surjectivity of $\pi_a$. $\square$

## 5. Boolean representation of invariant regions

The powerset $\mathcal P(F_a)$ carries the standard Boolean operations: intersection, union, and complement relative to $F_a$. The realization map transports these operations to input space.

**Theorem 5.1 (Boolean preservation and faithfulness).** For all $U,V\subseteq F_a$,

$$
\mathcal R_a(F_a\setminus U)=X\setminus\mathcal R_a(U),
$$

$$
\mathcal R_a(U\cap V)=\mathcal R_a(U)\cap\mathcal R_a(V),
$$

and consequently

$$
\mathcal R_a(U\cup V)=\mathcal R_a(U)\cup\mathcal R_a(V).
$$

Moreover, $\mathcal R_a$ is injective.

**Proof sketch.** Preimages preserve complements, intersections, and unions. For injectivity, suppose $U\ne V$. Some feasible pattern $p$ belongs to exactly one of them. Since $p$ is feasible, choose $x$ with $a(x)=p$. Then $x$ belongs to exactly one of $\mathcal R_a(U)$ and $\mathcal R_a(V)$, so the realized regions differ. $\square$

Thus $\mathcal R_a$ is an embedding of Boolean algebras from $\mathcal P(F_a)$ into $\mathcal P(X)$.

**Theorem 5.2 (Exact region representation).** A set $R\subseteq X$ is activation-invariant if and only if there exists a unique $U\subseteq F_a$ such that

$$
\mathcal R_a(U)=R.
$$

**Proof sketch.** If $R$ is invariant, define

$$
U=\{p\in F_a:\text{some }x\in a^{-1}(p)\text{ lies in }R\}.
$$

Invariance makes “some” equivalent to “every,” so the definition is independent of the witness. Then $x\in R$ exactly when $a(x)\in U$, proving $R=\mathcal R_a(U)$. Uniqueness follows from injectivity in Theorem 5.1. Conversely, if $R=\mathcal R_a(U)$ and $a(x)=a(y)$, then $a(x)\in U$ exactly when $a(y)\in U$, so membership in $R$ agrees. $\square$

This theorem identifies the image of the Boolean embedding exactly. No activation-invariant region is omitted, and no region that splits a fibre is included.

## 6. Finite Stone interpretation and atoms

Give $F_a$ the discrete topology. Because it is finite, it is compact and Hausdorff; every subset is both open and closed. Hence its clopen algebra is precisely $\mathcal P(F_a)$. This is the finite Stone space associated with the activation algebra.

The word “Stone” here records a precise syntax–semantics correspondence. Boolean expressions determine clopen subsets of feasible patterns. Their geometric meanings are obtained by realization in $X$. Feasible points are semantic states, and Boolean regions are propositions about those states.

**Theorem 6.1 (Atoms are singleton patterns).** A subset $A\subseteq F_a$ is an atom of $\mathcal P(F_a)$ if and only if there exists $p\in F_a$ such that

$$
A=\{p\}.
$$

**Proof sketch.** Every singleton is nonempty and has no proper nonempty subset. Conversely, if $A$ is an atom, choose $p\in A$. Then $\{p\}$ is a nonempty subset of $A$, so atomicity forces $A=\{p\}$. $\square$

**Corollary 6.2 (Atom count).** The number of atoms is

$$
|F_a|\le 2^k.
$$

**Proof sketch.** The map $p\mapsto\{p\}$ is a bijection from feasible patterns to atoms. Apply Theorem 3.1. $\square$

If $r=|F_a|$, the distinction between atoms and algebra elements is essential:

$$
\#\text{atoms}=r,
\qquad
|\mathcal P(F_a)|=2^r.
$$

The atoms are elementary states, while an arbitrary element is a union of elementary states.

## 7. VC dimension of the full region algebra

Let

$$
\mathcal C_a=\mathcal P(F_a)
$$

be the full concept family on the feasible space.

**Lemma 7.1 (Powersets shatter every subset).** For every $S\subseteq F_a$, the family $\mathcal C_a$ shatters $S$.

**Proof sketch.** Given $T\subseteq S$, choose the concept $C=T$. Then $C\cap S=T$. $\square$

**Theorem 7.2 (Exact VC dimension).** If $F_a$ is finite, then

$$
\operatorname{VCdim}(\mathcal C_a)=|F_a|.
$$

**Proof sketch.** By Lemma 7.1, $F_a$ itself is shattered, giving the lower bound $|F_a|$. Every shattered set is a subset of $F_a$, so its cardinality is at most $|F_a|$. The bounds coincide. $\square$

Combining earlier results gives the exact chain

$$
\operatorname{VCdim}(\mathcal C_a)
=\#\operatorname{Atoms}(\mathcal P(F_a))
=|F_a|
\le 2^k.
$$

The leftmost equality concerns the full powerset family, not one frozen network output.

**Theorem 7.3 (A fixed concept has no positive shattering capacity).** Let $R\subseteq Z$. The singleton family $\{R\}$ does not shatter any nonempty set $S\subseteq Z$.

**Proof sketch.** Choose $x\in S$. Shattering would require concepts whose traces on $S$ are both $\varnothing$ and $\{x\}$. The sole concept $R$ has only one trace $R\cap S$, so it cannot equal both distinct sets. $\square$

Thus VC dimension is a property of a hypothesis family. To discuss the capacity of neural classifiers, one must specify which parameters vary or which output labelings are allowed.

## 8. Algorithms

### 8.1 Enumeration on a finite domain

Suppose $X=\{x_1,\ldots,x_N\}$ is finite and $a(x)$ can be evaluated in $O(k)$ time. The feasible set can be found by hashing each pattern.

**Algorithm 8.1 (Feasible-pattern enumeration).** Initialize an empty set $F$. For each $x_i$, compute $a(x_i)$ and insert it into $F$. Return $F$.

The running time is $O(Nk)$ expected with hashing, and storage is $O(rk)$ bits for $r=|F|$. The result immediately supplies the atom count, the full-family VC dimension $r$, and the number $2^r$ of invariant regions.

### 8.2 Descent of an invariant classifier

Given labels $f(x)$ on a finite domain, maintain a dictionary from patterns to labels. For each input, either assign its pattern the observed label or compare against the existing label. A mismatch is a certificate that $f$ is not activation-invariant. If no mismatch occurs, the dictionary is the descended classifier $\bar f$.

This takes $O(Nk)$ expected time and $O(r(k+\ell))$ storage, where $\ell$ is the label representation size.

### 8.3 Realization of a Boolean pattern region

Given a subset $U\subseteq F_a$, classify an input $x$ as positive exactly when $a(x)\in U$. With a hash table for $U$, each query takes the activation-evaluation cost plus expected $O(1)$ membership time. Boolean combinations can be performed either on pattern sets before realization or on the resulting predicates; Theorem 5.1 guarantees identical results.

### 8.4 Feasibility beyond finite enumeration

For affine threshold gates on $\mathbb R^n$, a candidate pattern specifies a system of linear weak and strict inequalities. Feasibility becomes a linear-inequality question, with care required for strict constraints. Enumerating all $2^k$ candidates gives an exponential worst-case procedure, but arrangement methods can exploit dimension and shared structure. For deep ReLU networks, fixing a complete activation pattern makes each layer affine on that candidate cell; feasibility can then be checked through recursively induced linear constraints, although degeneracy and boundary conventions must be handled explicitly.

## 9. Applications

**Semantic compression.** If all downstream labels are activation-invariant, retaining one representative per feasible pattern loses no relevant information. The factorization theorem precisely states the condition under which this compression is sound.

**Testing and coverage.** Raw gate count suggests $2^k$ possible tests, but infeasible patterns should not be treated as missing coverage. The feasible space provides the correct target universe. Enumeration or feasibility solving can separate unreachable states from untested reachable ones.

**Redundancy detection.** A surprisingly small $|F_a|$ can reveal duplicated, correlated, or constrained gates. Comparing $|F_a|$ with $2^k$ gives a coarse utilization ratio

$$
\rho(a)=\frac{|F_a|}{2^k},
$$

with $0\le\rho(a)\le 1$ and $\rho(a)=1$ exactly under surjectivity.

**Rule extraction.** A binary activation-invariant classifier corresponds to a subset $U\subseteq F_a$. It can therefore be represented as a Boolean union of singleton atoms or simplified using ordinary Boolean minimization. The resulting rule is exact on the feasible space, even if its extension to infeasible bit strings is chosen arbitrarily.

**Capacity accounting.** The full family of invariant regions has VC dimension $|F_a|$, not necessarily $2^k$. Restricted parameterized output families may have smaller VC dimension. The feasible count supplies an immediate upper bound whenever every permitted concept is activation-invariant.

**Interpretability.** Each atom describes an equivalence class of inputs that the selected activation map cannot distinguish. Explanations formulated at the atom level expose precisely what information has been retained and discarded.

## 10. Limits of the correspondence

First, a deep network with $k$ neurons does not generally define merely $k$ global input hyperplanes. A neuron in a later layer applies an affine function to earlier piecewise-affine outputs; as a function of the original input, its preactivation is usually piecewise affine. The resulting cells cannot be counted by treating all neurons as one ordinary global hyperplane arrangement.

Second, activation patterns need not coincide with maximal linear regions. Distinct feasible patterns may induce the same affine map because of zero weights or cancellation. Boundary conventions may split or merge descriptions. Conversely, a notion of linear region based on connected maximal domains carries geometric information not contained in a bare pattern set. Equality requires explicit genericity and nondegeneracy assumptions.

Third, the theorem on VC dimension applies to $\mathcal P(F_a)$, the family of every possible labeling of feasible patterns. A practical output layer may realize only a restricted subfamily. Its VC dimension is then at most $|F_a|$ but need not attain the bound.

Fourth, the finite semantic space depends on the chosen activation map. Selecting only some gates produces a coarser quotient; adding gates may refine it. This dependence can be useful for multiscale analysis but should be made explicit.

## 11. Discussion and future work

The finite theory supplies a rigorous foundation for a broader program connecting neural activation geometry, Boolean algebras, and Stone spaces. The next topological step is to state the finite discrete topology explicitly and identify its clopen algebra, then formulate realization as a Boolean-algebra embedding. Although this is immediate at the finite level, it prepares comparison with classical Stone spectra and ultrafilters.

For one-layer affine threshold or ReLU systems, feasibility should be related directly to nonempty systems of linear inequalities. This opens the door to hyperplane-arrangement bounds such as dimension-sensitive estimates smaller than $2^k$. One can then state genericity hypotheses under which nonempty activation cells correspond to geometric linear regions.

For deep networks, the natural program is inductive: fix a candidate pattern, derive the affine formula within that cell layer by layer, and prove that satisfying the accumulated constraints is equivalent to realizing the pattern. This would connect the abstract quotient developed here to polyhedral computation.

On the learning-theoretic side, parameterized output families on a fixed feasible complex deserve separate study. The universal upper bound $|F_a|$ follows from containment in the powerset, while equality requires the ability to assign arbitrary labels to all atoms. Intermediate families may be analyzed through growth functions, algebraic restrictions, margin conditions, or output-layer geometry.

Finally, replacing the explicit powerset with the Stone spectrum of a finite Boolean algebra would provide a coordinate-free presentation. Ultrafilters would correspond to atoms, and an explicit homeomorphism would recover the feasible points. Such a formulation may extend naturally when activation propositions are quotiented by logical relations or when infinite families of predicates are considered.

## 12. Conclusion

A network’s binary gates define a finite semantic quotient of its input space. The quotient consists of feasible activation patterns, has at most $2^k$ points, and reaches that bound exactly when every formal pattern occurs. Activation-invariant classifiers descend uniquely to it. Its powerset embeds faithfully into input-space regions and represents exactly the regions constant on activation fibres. The atoms are singleton feasible patterns, and the full family of pattern subsets has VC dimension equal to their number.

These facts provide a precise finite Stone-style duality: feasible patterns are points, Boolean subsets are clopen propositions, and pullback supplies their geometric meaning. The formulation also enforces crucial distinctions. Formal patterns may be infeasible; atoms are not all algebra elements; one fixed decision region is not a hypothesis class; and activation patterns are not automatically linear regions. With those distinctions in place, Boolean syntax and neural geometry fit together in an exact and reusable mathematical framework.