# Dark Existence and the Collapse of the Finite Witness-Count Hierarchy

**Aristotle**  
**17 July 2026**

## Abstract

We study an abstract notion of *dark existence*: a deductive system proves that some object satisfies a predicate, yet proves the predicate for none of the objects selected by a fixed naming map. A proposed refinement declares a predicate dark at level $k$ when the system proves the existence of at least $k$ distinct witnesses while proving no named instance. We show that this raw level is not an invariant measure of proof-theoretic strength. Given one dark predicate, adjoining an irrelevant finite tag produces dark predicates at every positive finite level, provided the proof relation supports the elementary finite-tag transformation. The tagged naming map is explicit and enumerates every tag over every originally named object. We also prove mathematical and proof-relative downward monotonicity and show that any named witness-extraction principle excludes darkness. These results establish a structural obstruction to strict hierarchies based only on witness count. We explain why standard formulations of the Paris–Harrington and Kirby–Paris hydra independence theorems do not by themselves furnish dark predicates, and why density claims for $\Pi_2$ statements require a coding-robust measure. The appropriate next step is a representation-invariant theory based on equivalence under finite tags and effective recodings.

## 1. Introduction

An existential theorem and an identified witness are different forms of information. In familiar constructive settings, a proof of $\exists x\,P(x)$ may provide a witness. In classical or intensional settings, however, provable existence need not automatically become a proof of $P(a)$ for a designated name $a$. This motivates the study of *dark predicates*: predicates whose existential closure is provable although none of their named instances is provable.

The definition is deliberately relative. It depends on a proof predicate, a domain of objects, a predicate on that domain, and a sequence of names. This relativity is essential: changing the proof system can change which sentences are provable, and changing the naming map can change which instances count as visible.

A natural proposal is to grade darkness by the number of witnesses whose existence is provable. At level $k$, the system proves that there are at least $k$ distinct witnesses, but still proves no named instance. One might then conjecture that greater $k$ represents greater proof-theoretic difficulty.

The principal result of this paper refutes that interpretation without refuting the underlying notion of darkness. Starting from any dark predicate $P$ and any positive integer $r$, we form the tagged predicate
$$
P^{[r]}(i,x)\quad\Longleftrightarrow\quad P(x),
$$
where $i$ ranges over $r$ finite tags. One original witness gives $r$ distinct tagged witnesses. An explicit quotient-remainder coding names every pair consisting of a finite tag and an old named object. Since the predicate ignores its tag, any proof of a tagged named instance would reveal an old named instance. Consequently, darkness survives while the provable witness count is amplified to $r$.

This proves that one dark existential generates all positive finite levels. The amplification adds no mathematical information; it changes only the representation of witnesses. Raw witness count therefore cannot support a strict intrinsic hierarchy unless predicates related by finite decoration are first identified.

Two companion results sharpen the diagnosis. First, witness count is downward monotone: at least $n$ witnesses implies at least $m$ whenever $m\le n$, and the corresponding darkness implication holds when the proof system internalizes this finite selection. Second, a named witness-extraction principle is incompatible with darkness. Together, these results locate dark existence precisely between existential provability and witness extraction.

The paper does not claim that a concrete dark predicate for Peano arithmetic has been produced. Standard Paris–Harrington and Kirby–Paris hydra results have a different logical profile from the definition studied here. Nor do we claim a density theorem among $\Pi_2$ sentences, because no coding-invariant topology or measure has yet been specified. The contribution is instead structural: it determines what any viable hierarchy or density theory must quotient out or control.

## 2. Framework and definitions

### 2.1 Proof predicates and names

Let $X$ be a type or collection of mathematical objects. Let
$$
\operatorname{Prov}(A)
$$
mean that a fixed deductive system proves proposition $A$. We treat $\operatorname{Prov}$ abstractly; no soundness, consistency, completeness, or closure assumptions are implicit.

A **naming map** is a function
$$
\nu:\mathbb N\to X.
$$
It lists the objects regarded as explicitly named. Surjectivity is not assumed. Repetitions are permitted. In an arithmetical application, $X$ could be the natural numbers and $\nu$ the usual numeral map, but keeping $X$ and $\nu$ abstract exposes which conclusions are structural.

Let $P:X\to\mathrm{Prop}$ be a predicate.

### 2.2 Dark predicates

**Definition 2.1 (Dark predicate).** The predicate $P$ is *dark relative to $\operatorname{Prov}$ and $\nu$* if
$$
\operatorname{Prov}(\exists x\in X\;P(x))
$$
and
$$
\forall n\in\mathbb N,\quad \neg\operatorname{Prov}(P(\nu(n))).
$$

The first condition is positive: the system proves existence. The second is a metatheoretic family of negative conditions: no instance selected by the naming map is provable.

This definition should not be conflated with several nearby notions. It is stronger than merely having an existential statement whose truth is known externally but unprovable internally, because the existential itself must be provable. It is different from an independent universal termination statement. It is also different from requiring each instance to be undecidable: darkness asks only that no positive named instance be provable.

### 2.3 Finite witness count

**Definition 2.2 (At least $k$ witnesses).** For $k\in\mathbb N$, write $\operatorname{AtLeast}_k(P)$ when there exists a finite set $S\subseteq X$ such that
$$
|S|=k
$$
and
$$
\forall x\in S,\quad P(x).
$$

This formulation requires genuine distinctness: a set of cardinality $k$ cannot count one object repeatedly.

**Definition 2.3 (Darkness at level $k$).** The predicate $P$ is *dark at level $k$* relative to $\operatorname{Prov}$ and $\nu$ if
$$
\operatorname{Prov}(\operatorname{AtLeast}_k(P))
$$
and
$$
\forall n\in\mathbb N,\quad \neg\operatorname{Prov}(P(\nu(n))).
$$

For $k=0$, the witness-count assertion is vacuous, so the meaningful hierarchy begins at positive levels. Ordinary darkness provides a provable existential, which is naturally associated with level $1$ when the proof system can pass between these equivalent finite formulations.

## 3. Finite tags and interleaved naming

### 3.1 Tagged objects

Fix $r\ge 1$ and let
$$
[r]=\{0,1,\ldots,r-1\}.
$$
The tagged domain is $[r]\times X$. Define the tagged predicate $P^{[r]}$ by
$$
P^{[r]}(i,x)\quad\Longleftrightarrow\quad P(x).
$$
The tag $i$ is intentionally irrelevant to truth. It serves only to distinguish objects in the product domain.

**Lemma 3.1 (Tagged witness multiplication).** If $\exists x\in X\;P(x)$, then $\operatorname{AtLeast}_r(P^{[r]})$.

**Proof sketch.** Choose a witness $x$ to $P$. Consider
$$
S_x=\{(0,x),(1,x),\ldots,(r-1,x)\}.
$$
Different tags give different ordered pairs, so $|S_x|=r$. Every member $(i,x)$ satisfies $P^{[r]}$ because $P(x)$ holds. Hence $S_x$ is an $r$-element witness set. $\square$

**Lemma 3.2 (Existential preservation under tagging).** For every $r\ge1$,
$$
\exists(i,x)\in[r]\times X\;P^{[r]}(i,x)
\quad\Longleftrightarrow\quad
\exists x\in X\;P(x).
$$

**Proof sketch.** A tagged witness projects to a witness in $X$. Conversely, if $x$ witnesses $P$, then $(0,x)$ witnesses $P^{[r]}$. $\square$

Thus tagging changes neither the underlying existential content nor the payload property.

### 3.2 The quotient-remainder naming map

Define
$$
\nu_r(c)=\left(c\bmod r,\nu\!\left(\left\lfloor\frac cr\right\rfloor\right)\right),
\qquad c\in\mathbb N.
$$
This map interleaves all $r$ tags over the original sequence of names. The first $r$ codes name every tag over $\nu(0)$, the next $r$ codes name every tag over $\nu(1)$, and so forth.

**Lemma 3.3 (Coverage of tagged names).** For every $i\in[r]$ and $n\in\mathbb N$, there exists $c\in\mathbb N$ such that
$$
\nu_r(c)=(i,\nu(n)).
$$
In fact, one may take $c=rn+i$.

**Proof sketch.** Since $0\le i<r$, Euclidean division gives
$$
(rn+i)\bmod r=i
$$
and
$$
\left\lfloor\frac{rn+i}{r}\right\rfloor=n.
$$
Substitution into the definition of $\nu_r$ proves the claim. $\square$

The converse computation is equally important: for any code $c$, the payload named by $\nu_r(c)$ is
$$
\nu\!\left(\left\lfloor\frac cr\right\rfloor\right).
$$
Therefore a tagged named instance contains no payload that was absent from the original naming sequence.

## 4. The finite-tag amplification theorem

The mathematical implication in Lemma 3.1 does not by itself imply that an entirely abstract proof relation transports proofs through it. We therefore state exactly the closure property required.

**Definition 4.1 (Finite-tag support).** A proof predicate $\operatorname{Prov}$ *supports finite tagging on $X$* if, for every predicate $P$ on $X$ and every $r\ge1$,
$$
\operatorname{Prov}(\exists x\in X\;P(x))
\quad\Longrightarrow\quad
\operatorname{Prov}(\operatorname{AtLeast}_r(P^{[r]})).
$$

In an ordinary recursively presented deductive calculus, this is expected to arise from a uniform finite syntactic transformation of derivations: duplicate the existential witness under all finite tags and prove that the tags are distinct. For the abstract theorem, however, it is kept as an explicit hypothesis.

**Theorem 4.2 (Finite-Tag Amplification).** Let $P$ be dark relative to $\operatorname{Prov}$ and $\nu$. If $\operatorname{Prov}$ supports finite tagging on $X$, then for every integer $r\ge1$, the tagged predicate $P^{[r]}$ is dark at level $r$ relative to $\operatorname{Prov}$ and $\nu_r$.

**Proof sketch.** Since $P$ is dark, the system proves $\exists x\,P(x)$. Finite-tag support transforms this proof into one of $\operatorname{AtLeast}_r(P^{[r]})$.

It remains to exclude every tagged named instance. Fix $c\in\mathbb N$ and suppose, toward a contradiction, that
$$
\operatorname{Prov}(P^{[r]}(\nu_r(c))).
$$
By definition of $P^{[r]}$ and $\nu_r$, this proposition is exactly
$$
P\!\left(\nu\!\left(\left\lfloor\frac cr\right\rfloor\right)\right).
$$
Hence the supposition is
$$
\operatorname{Prov}\!\left(P\!\left(\nu\!\left(\left\lfloor\frac cr\right\rfloor\right)\right)\right),
$$
which contradicts darkness of $P$ at the natural-number index $\lfloor c/r\rfloor$. Thus no tagged named instance is provable, and $P^{[r]}$ is dark at level $r$. $\square$

**Corollary 4.3 (All positive finite levels).** Under the hypotheses of Theorem 4.2, one dark predicate yields a dark predicate at every positive finite level.

**Proof sketch.** Apply Theorem 4.2 separately for each $r\ge1$. $\square$

**Corollary 4.4 (Levels one, two, and three).** Under the same hypotheses, the predicates
$$
P^{[1]},\qquad P^{[2]},\qquad P^{[3]}
$$
are dark at levels $1$, $2$, and $3$, respectively.

These corollaries are uniform. They do not use three unrelated combinatorial principles. All levels arise from the same original existential information by finite decoration.

## 5. Consequences for proposed hierarchies

### 5.1 Failure of strictness by raw cardinality

Suppose one interprets level $r$ as proof-theoretic hardness: more provably existing but individually unprovable witnesses are intended to indicate greater darkness. Theorem 4.2 shows that this interpretation is representation-dependent. The map
$$
x\longmapsto(i,x)
$$
creates $r$ distinct tagged copies of each witness, but $P^{[r]}(i,x)$ contains exactly the same substantive condition $P(x)$ for every $i$.

The amplification is therefore informationally conservative at the level of existential content, as Lemma 3.2 makes explicit. The increased cardinality records multiplicity in a product representation, not additional inaccessible mathematical facts.

**Proposition 5.1 (Obstruction to a strict witness-count hierarchy).** Any proposed darkness rank that strictly increases with the finite number of provably existing witnesses, while treating finite tag extensions as mathematically inessential, is not well-defined.

**Proof sketch.** A predicate $P$ and its tag extension $P^{[r]}$ must receive the same rank if finite tags are inessential. But Theorem 4.2 assigns $P^{[r]}$ every desired raw finite level $r$. A rank that both respects tag equivalence and strictly follows raw level would therefore assign both equal and unequal ranks to the same equivalence class. $\square$

This proposition does not exclude every hierarchy. It requires a better invariant.

### 5.2 Downward monotonicity

**Lemma 5.2 (Mathematical witness-count monotonicity).** If $m\le n$ and $\operatorname{AtLeast}_n(P)$, then $\operatorname{AtLeast}_m(P)$.

**Proof sketch.** Let $S$ be an $n$-element set of witnesses. Since $m\le n$, choose an $m$-element subset $T\subseteq S$. Every member of $T$ satisfies $P$, so $T$ witnesses $\operatorname{AtLeast}_m(P)$. $\square$

To lift this statement through an abstract proof predicate, closure must again be explicit.

**Theorem 5.3 (Proof-relative downward monotonicity).** Let $m\le n$. Suppose the proof predicate admits the transformation
$$
\operatorname{Prov}(\operatorname{AtLeast}_n(P))
\Longrightarrow
\operatorname{Prov}(\operatorname{AtLeast}_m(P)).
$$
If $P$ is dark at level $n$, then $P$ is dark at level $m$.

**Proof sketch.** Apply the assumed transformation to the provable witness-count statement. The prohibition on provable named instances is unchanged, because it does not depend on the level. $\square$

Thus the naive levels descend under mild closure and ascend through finite tagging. Their order structure does not encode strict increases in intrinsic difficulty.

## 6. Witness extraction as an exact obstruction

Darkness cannot occur when existential proofs yield named witnesses.

**Definition 6.1 (Named witness extraction for $P$).** A proof predicate has named witness extraction for $P$ and $\nu$ if
$$
\operatorname{Prov}(\exists x\in X\;P(x))
\Longrightarrow
\exists n\in\mathbb N\;\operatorname{Prov}(P(\nu(n))).
$$

**Theorem 6.2 (No Darkness under Named Witness Extraction).** If named witness extraction holds for $P$ and $\nu$, then $P$ is not dark relative to $\operatorname{Prov}$ and $\nu$.

**Proof sketch.** Assume $P$ is dark. Its existential closure is provable. Named witness extraction then supplies $n$ such that $P(\nu(n))$ is provable. This contradicts the second clause of darkness, which excludes such a proof for every $n$. $\square$

The theorem is elementary, but conceptually decisive. To construct a genuine dark predicate, one must locate a failure of the relevant witness-extraction principle. This failure may arise from classical reasoning, intensional coding, a naming map that does not capture all objects, or nonstandard semantic behavior. Each route requires precise formulation.

## 7. Algorithmic realization

Although the central claims concern provability, the finite bookkeeping is completely explicit and computational.

### 7.1 Encoding and decoding tagged names

For a fixed $r\ge1$, encode a tag-index pair $(i,n)$, where $0\le i<r$, by
$$
\operatorname{encode}_r(i,n)=rn+i.
$$
Decode a natural number $c$ by
$$
\operatorname{decode}_r(c)=\left(c\bmod r,\left\lfloor\frac cr\right\rfloor\right).
$$

**Proposition 7.1 (Round-trip identities).** For $0\le i<r$,
$$
\operatorname{decode}_r(\operatorname{encode}_r(i,n))=(i,n),
$$
and for every $c\in\mathbb N$,
$$
\operatorname{encode}_r(\operatorname{decode}_r(c))=c.
$$

**Proof sketch.** Both identities are the quotient-remainder theorem for division by $r$. $\square$

Arithmetic on fixed-width integers takes constant machine time; with unbounded integers, division and multiplication cost depends quasi-linearly on the bit length under modern algorithms. Enumerating the first $N$ tagged names takes $O(N)$ arithmetic operations and constant auxiliary storage if streamed.

### 7.2 Constructing tagged witness sets

Given $r$ and a payload $x$, the witness-set constructor outputs
$$
[(0,x),(1,x),\ldots,(r-1,x)].
$$
It uses $O(r)$ time and $O(r)$ output space. Distinctness follows from the tags alone. Evaluating the tagged predicate requires one evaluation of $P(x)$ and does not depend substantively on the tag.

These algorithms do not discover a dark witness. Rather, they demonstrate the representation mechanism behind the theorem: once existential proof information is available, finite multiplicity can be manufactured without learning the payload.

## 8. Why standard independence examples require caution

The Paris–Harrington theorem strengthens finite Ramsey theory and is not provable in Peano arithmetic. The Kirby–Paris hydra result similarly gives a termination phenomenon independent of Peano arithmetic in its standard presentation. These results establish profound limits on arithmetic proof, but they do not automatically instantiate Definition 2.1.

The logical mismatch has two parts. First, the standard statements are universal or termination principles whose full assertion is not provable in the target theory. In contrast, darkness requires the target theory to prove an existential statement. Second, darkness requires a separate nonprovability theorem for every named instance of the predicate. Independence of one global statement does not automatically imply that family of instance-by-instance exclusions.

A concrete example over Peano arithmetic must therefore specify:

1. an arithmetized proof predicate for Peano arithmetic;
2. the exact domain and naming map, usually standard numerals or codes;
3. a predicate $P$ whose existential closure Peano arithmetic proves;
4. for every standard $n$, a metatheorem that Peano arithmetic does not prove $P(\nu(n))$.

The fourth item must be compatible with the first: the existential proof must not already yield a named instance through the available proof transformations. Candidate constructions may require nonstandard models, Rosser-style diagonalization, recursively inseparable sets, or deliberately intensional predicates. None follows merely from citing a familiar independence theorem.

This distinction also separates three phenomena:

- a theory proves an existential but no named positive instance;
- an existential is true externally while its instances have some undecidability property;
- a universal $\Pi_2$ principle is independent of the theory.

These notions may interact, but they are not interchangeable.

## 9. Density, coding, and invariance

A statement that dark theorems are “dense among true $\Pi_2$ statements” is incomplete until density is defined. A topology requires specified open sets. An asymptotic density requires a sequence of finite sampling spaces. A probability requires a measure. Formula codes by themselves provide none of these canonically.

Raw bounded-length counting is particularly vulnerable. Logically equivalent formulas may have very different lengths. A grammar may permit arbitrarily many harmless parentheses, repeated conjunctions with tautologies, unused quantified variables, or definitional expansions. Such padding can change limiting frequencies without changing semantic content.

Gödel numberings introduce a related issue. Acceptable computable recodings preserve computability-theoretic structure but need not preserve naive numerical density. A set sparse under one coding can become frequent under another if the translation distorts lengths or intervals.

The finite-tag theorem gives a direct analogy. Tags alter cardinality-based levels while preserving payload content. Syntactic padding can alter formula frequencies while preserving propositions. Accordingly, a meaningful density program should:

1. choose an explicit grammar, topology, or probability model;
2. state whether formulas, sentences, theories, or equivalence classes are sampled;
3. control logical equivalence and harmless definitional extension;
4. prove robustness under a specified class of acceptable recodings.

Possible approaches include bounded-length density under a fixed canonical grammar, prefix-free program probability, or measures on normal forms. Each has advantages and biases. No unqualified conclusion that “most true statements are dark” follows before these choices are made and their invariance properties are established.

## 10. Applications and interpretation

### 10.1 Proof theory

The framework isolates the exact proof transformation needed for finite amplification. When instantiated with a recursively presented calculus, finite-tag support should be witnessed by primitive-recursive maps on proof codes. Establishing this would turn the abstract theorem into a concrete metatheorem for the chosen arithmetic theory.

### 10.2 Constructive versus classical arithmetic

The named witness-extraction theorem suggests a comparative program. Constructive systems with strong numerical existence properties resist darkness for suitably numerical predicates and naming maps. Classical systems may permit existential proofs without comparable extraction. Care is required: witness properties vary with formula class, theory, and representation.

### 10.3 Complexity and search

Darkness is not computational complexity. A witness may be computationally hard to find but still have a provable named instance, or it may be easy to compute externally while its instance remains unprovable in a specified system. Nevertheless, the distinction between existence certificates and extractable witnesses parallels practical questions in program synthesis, optimization, and verification: what information can be recovered from a proof of feasibility?

### 10.4 Representation-invariant ranks

The main application is diagnostic. Any rank intended to measure darkness should be invariant under finite products with a nonempty decidable set of tags and, plausibly, under primitive-recursive bijections of names. One can define an equivalence relation generated by such transformations and seek ranks on equivalence classes. A successful strict hierarchy would then have to reflect genuine differences in existential proof content or extraction obstruction.

## 11. Limitations

The results are conditional on the existence of an initial dark predicate. They do not provide a concrete example for Peano arithmetic under the external reading “Peano arithmetic does not prove $P(n)$” for every standard numeral $n$.

Finite-tag support is assumed abstractly rather than derived for a particular arithmetized calculus. This is intentional: it separates the combinatorial argument from proof-code engineering. A concrete application must prove that the relevant syntactic transformations are representable and preserve derivability.

The results invalidate strictness based solely on raw finite witness count, not every conceivable darkness hierarchy. A quotient-based or complexity-sensitive hierarchy may remain viable.

Finally, no density theorem is established. The discussion explains prerequisites for a meaningful statement and identifies coding dependence as an obstacle.

## 12. Future work

The immediate priority is to instantiate $\operatorname{Prov}$ with a concrete first-order proof calculus for Peano arithmetic and implement finite tagging by primitive-recursive transformations of derivations. This will make all assumptions explicit at the syntactic level.

A second direction is the search for genuine dark predicates under the exact external nonprovability condition. This should be compared with numerical existence properties and witness properties in Heyting arithmetic and constructive fragments.

Third, predicates differing only by finite tags or primitive-recursive bijections should be identified through an equivalence relation. Ranks can then be sought on equivalence classes rather than raw presentations.

Fourth, any prevalence claim should use a specified measure, such as prefix-free program probability or bounded-length density under a canonical grammar, followed by invariance analysis under acceptable recodings.

Fifth, the distinctions among provable dark existence, instance undecidability, and independent universal $\Pi_2$ principles should be developed systematically. Finally, candidate examples from nonstandard models, Rosser-style constructions, and recursively inseparable sets should be tested against both required clauses: a proof of the existential and a uniform metatheorem excluding every standard named instance.

## 13. Conclusion

Dark existence separates provable existential information from provable identification. That separation is mathematically coherent, but counting hidden witnesses does not automatically measure its depth. A single dark predicate can be extended by $r$ irrelevant finite tags to produce a level-$r$ dark predicate for every positive finite $r$. The quotient-remainder naming map explicitly covers every tag over every old name, and the tagged predicate preserves the original existential content exactly.

The same framework proves downward monotonicity under elementary proof closure and shows that named witness extraction makes darkness impossible. Together, these results replace a naive strict hierarchy with a sharper structural picture: darkness concerns the failure of extraction, while finite witness multiplicity can be an artifact of representation.

A robust future theory must therefore quotient out harmless tags and recodings, instantiate its proof predicate precisely, and define prevalence through coding-resistant measures. The central methodological conclusion is simple: before measuring how many shadows a theorem casts, one must determine whether the shadows come from different objects or merely from different labels on the same object.
