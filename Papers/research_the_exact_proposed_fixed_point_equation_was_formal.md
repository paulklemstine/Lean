# Data-Valued Dependent-Product Fixed Points: Non-Collapse, a Boolean Model, and Finite Cardinality

**Aristotle**  
**31 July 2026**

## Abstract

We study self-indexed dependent-product equations of the form

$$
T\simeq\prod_{x\in T}F(x),
$$

where $T$ is a type, $F(x)$ is a type of data attached to $x$, and $\simeq$ denotes an equivalence. The behavior differs sharply from the proposition-valued variant. When every fiber is a proposition, proof irrelevance makes the section space a subsingleton; the fixed-point equation then forces $T$ to be a singleton. For data-valued fibers, this collapse fails. We give an explicit genuinely dependent solution over the Boolean type: the fiber over $\mathsf{false}$ is Boolean, while the fiber over $\mathsf{true}$ is a singleton. Evaluation at $\mathsf{false}$ and insertion of the unique value at $\mathsf{true}$ give inverse maps between Booleans and sections. The two fibers are inequivalent, the section space has two distinct elements, and hence data-valued fixed points need not be subsingletons. For arbitrary finite $T$ and finite fibers, we prove the cardinality constraint

$$
|T|=\prod_{x\in T}|F(x)|.
$$

We interpret this identity as a distribution-of-information law, describe algorithms for constructing and checking finite examples, contrast dependent and constant families, and formulate concrete classification problems suggested by the Boolean model.

## 1. Introduction

Fixed-point equations indexed by their own solution space occur naturally in logic, semantics, combinatorics, and the theory of data structures. A particularly transparent form asks for a type $T$ and a family of fibers $F:T\to\mathrm{Type}$ such that $T$ is equivalent to the type of all sections of $F$:

$$
T\simeq\prod_{x\in T}F(x).
$$

An element on the right chooses, for each $x\in T$, a value in the possibly varying fiber $F(x)$. Thus the equation says that one global state can be reversibly represented by one choice in every local fiber.

The equation is self-indexed, but self-indexing alone does not imply paradox, incompleteness, or undecidability. The mathematical character of the equation depends on the codomain of the fiber family. If the fibers are propositions, their inhabitants carry no distinguishable choice: pointwise proof irrelevance collapses the entire product. If the fibers are ordinary data types, local alternatives survive and can encode a nontrivial global state.

This paper develops the first nontrivial data-valued example and extracts its finite arithmetic invariant. The Boolean type already suffices. Put a two-element fiber over one Boolean point and a singleton fiber over the other. A section then stores exactly one bit. Reading that bit decodes the section; writing it and filling the remaining coordinate with its unique value encodes a Boolean. The construction is genuinely dependent because the two fibers have unequal cardinality.

Our principal results are as follows.

1. **Proposition-Valued Collapse.** A proposition-valued fixed point is equivalent to a singleton.
2. **Boolean Data Fixed Point.** The Boolean type is a data-valued dependent-product fixed point.
3. **Genuine Dependence.** The two fibers in the Boolean model are not equivalent.
4. **Non-Collapse of Sections.** The Boolean section space is not a subsingleton.
5. **Finite Cardinality Product Law.** Every finite data-valued fixed point satisfies $|T|=\prod_x|F(x)|$; in the Boolean model the product is $2\cdot1=2$.

The distinction between propositions and data is the conceptual center of the paper. The Boolean model demonstrates existence; the product law begins the classification theory.

## 2. Definitions and preliminary observations

### 2.1. Dependent families and sections

Let $T$ be a type. A **dependent family over $T$** is an assignment $F$ that associates to each $x\in T$ a type $F(x)$. A **section** of $F$ is a dependent function $s$ satisfying

$$
s(x)\in F(x)\qquad\text{for every }x\in T.
$$

The type of sections is denoted

$$
\prod_{x\in T}F(x).
$$

When $F(x)=A$ for every $x$, the dependent product reduces to the ordinary function type $T\to A$. For a genuinely dependent family, the permitted output type changes with the input.

Two types $A$ and $B$ are **equivalent**, written $A\simeq B$, if there are maps $e:A\to B$ and $d:B\to A$ such that $d(e(a))=a$ for every $a\in A$ and $e(d(b))=b$ for every $b\in B$. For finite sets, this is simply a bijection, but the inverse-map formulation remains useful because it exhibits the encoding and decoding operations.

### 2.2. Data-valued fixed points

**Definition 2.1 (Data-valued dependent-product fixed point).** A type $T$ is a data-valued dependent-product fixed point if there exists a family $F:T\to\mathrm{Type}$ and an equivalence

$$
T\simeq\prod_{x\in T}F(x).
$$

The family is part of the witness. The definition does not demand that $F$ be constant, and the Boolean model below shows why allowing dependence matters.

A type is a **subsingleton** if any two of its elements are equal. It is a **singleton** if it is inhabited and a subsingleton. These notions isolate the collapse question: does the fixed-point equation force all global states to coincide?

### 2.3. The proposition-valued comparison

The earlier, more restrictive equation takes $P(x)$ to be a proposition:

$$
T\simeq\prod_{x\in T}P(x).
$$

A proposition may be true or false, but any two proofs of the same proposition are indistinguishable. This has an immediate pointwise consequence.

**Lemma 2.2 (Subsingleton section space for propositions).** For every family of propositions $P:T\to\mathrm{Prop}$, the dependent product $\prod_{x\in T}P(x)$ is a subsingleton.

**Proof sketch.** Let $s$ and $t$ be two sections. For each $x\in T$, both $s(x)$ and $t(x)$ prove $P(x)$, so proof irrelevance gives $s(x)=t(x)$. Pointwise equality of functions yields $s=t$. ∎

**Theorem 2.3 (Proposition-Valued Collapse Theorem).** A type $T$ satisfies

$$
\exists P:T\to\mathrm{Prop},\qquad T\simeq\prod_{x\in T}P(x)
$$

if and only if $T$ is equivalent to a singleton.

**Proof sketch.** If such $P$ and an equivalence exist, Lemma 2.2 transfers the subsingleton property from the product to $T$. The type $T$ cannot be empty: if it were empty, the product over the empty index type would still contain the unique empty section, contradicting the equivalence. Thus $T$ is inhabited and a subsingleton, hence a singleton. Conversely, for a singleton $T$, take every $P(x)$ to be the always-true proposition. Both $T$ and its section space have one element, giving an equivalence. ∎

This theorem explains exactly why the proposition-valued equation cannot support a hierarchy of nontrivial fixed points. Up to equivalence, it has one solution class. Every solution has decidable equality and cardinality one, and every predicate on it is extensionally constant.

## 3. The Boolean dependent family

Let

$$
\mathbb B=\{\mathsf{false},\mathsf{true}\}
$$

be the Boolean type, and let $\mathbf 1=\{\star\}$ be a singleton. Define a family $F:\mathbb B\to\mathrm{Type}$ by

$$
F(\mathsf{false})=\mathbb B,
\qquad
F(\mathsf{true})=\mathbf 1.
$$

A section $s$ contains a Boolean value $s(\mathsf{false})$ and a value $s(\mathsf{true})$ in the singleton fiber. The second value is necessarily $\star$, so the section has precisely one free component.

### 3.1. Explicit equivalence

Define the encoding map

$$
E:\mathbb B\longrightarrow\prod_{b\in\mathbb B}F(b)
$$

by

$$
E(a)(\mathsf{false})=a,
\qquad
E(a)(\mathsf{true})=\star.
$$

Define the decoding map

$$
D:\left(\prod_{b\in\mathbb B}F(b)\right)\longrightarrow\mathbb B
$$

by evaluation at the informative coordinate:

$$
D(s)=s(\mathsf{false}).
$$

**Theorem 3.1 (Boolean Data Fixed-Point Theorem).** The maps $E$ and $D$ are inverse equivalences. Consequently,

$$
\mathbb B\simeq\prod_{b\in\mathbb B}F(b),
$$

so the Boolean type is a data-valued dependent-product fixed point.

**Proof sketch.** For $a\in\mathbb B$,

$$
D(E(a))=E(a)(\mathsf{false})=a.
$$

Conversely, let $s$ be a section. At $\mathsf{false}$,

$$
E(D(s))(\mathsf{false})=D(s)=s(\mathsf{false}).
$$

At $\mathsf{true}$, both $E(D(s))(\mathsf{true})$ and $s(\mathsf{true})$ belong to the singleton $\mathbf 1$, so both equal $\star$. Hence the sections agree at every coordinate and are equal. ∎

The proof is constructive and algorithmic: encoding writes one bit; decoding reads it.

### 3.2. Genuine dependence

The family is not pointwise equivalent to a constant family. In particular, its two fibers cannot be equivalent.

**Theorem 3.2 (Fiber Inequivalence).** There is no equivalence

$$
F(\mathsf{false})\simeq F(\mathsf{true}).
$$

**Proof sketch.** The first fiber has two distinct elements, while the second has one. If an equivalence existed, the two Boolean values would map into the singleton and hence have equal images. Injectivity would then force $\mathsf{false}=\mathsf{true}$, a contradiction. ∎

Thus the model is genuinely dependent: its local data shape varies essentially with the base point.

### 3.3. Failure of collapse

**Theorem 3.3 (Non-Subsingleton Section Theorem).** The section space $\prod_{b\in\mathbb B}F(b)$ is not a subsingleton.

**Proof sketch.** The sections $E(\mathsf{false})$ and $E(\mathsf{true})$ differ at $\mathsf{false}$. Equivalently, if all sections were equal, these two encoded sections would be equal; applying the injective inverse equivalence would imply $\mathsf{false}=\mathsf{true}$. ∎

**Corollary 3.4 (Data-Valued Non-Collapse Theorem).** There exists a data-valued dependent-product fixed point that is not a subsingleton.

**Proof sketch.** Take $T=\mathbb B$ and use Theorem 3.1. The two Boolean values are distinct. ∎

This corollary identifies the precise failure of the proposition-valued proof: ordinary data fibers need not be subsingletons, so their section spaces need not be subsingletons either.

## 4. Finite cardinality theory

The Boolean example belongs to a general counting framework. Assume $T$ is finite and every $F(x)$ is finite. A section is obtained by independently selecting one element from each fiber.

**Lemma 4.1 (Cardinality of a finite dependent product).** For finite $T$ and finite fibers $F(x)$,

$$
\left|\prod_{x\in T}F(x)\right|
=
\prod_{x\in T}|F(x)|.
$$

**Proof sketch.** Induct on the finite index set. The product over no indices has one empty section, matching the empty numerical product $1$. Adding an index $x$ pairs a section over the remaining indices with one of the $|F(x)|$ choices at $x$, multiplying the count by $|F(x)|$. ∎

**Theorem 4.2 (Finite Cardinality Product Theorem).** If $T$ and all fibers $F(x)$ are finite and

$$
T\simeq\prod_{x\in T}F(x),
$$

then

$$
|T|=\prod_{x\in T}|F(x)|.
$$

**Proof sketch.** Equivalent finite types have equal cardinality. Apply this to the given equivalence and then use Lemma 4.1. ∎

**Corollary 4.3 (Boolean Fiber Product).** For the Boolean family,

$$
\prod_{b\in\mathbb B}|F(b)|=2.
$$

**Proof.** Directly,

$$
|F(\mathsf{false})|\,|F(\mathsf{true})|=2\cdot1=2.
$$

This equals $|\mathbb B|$. ∎

Theorem 4.2 is a necessary condition for every finite solution. It is also sufficient for the bare existence of some bijection between the two finite sets, provided the cardinal equality is known. Nevertheless, an explicit equivalence remains mathematically valuable: it explains the representation rather than merely counting it.

### 4.1. Information interpretation

For nonempty finite fibers, define the information capacity of a finite type $A$ as $\log_2|A|$. The product law becomes

$$
\log_2|T|=\sum_{x\in T}\log_2|F(x)|.
$$

Singleton fibers contribute zero bits. The Boolean fiber contributes one bit. Hence the Boolean global state is represented by concentrating one bit at $\mathsf{false}$ and placing no variable information at $\mathsf{true}$.

An empty fiber would make the entire product empty. Therefore an inhabited fixed point cannot contain an empty fiber. In finite inhabited solutions, every cardinal factor is positive.

### 4.2. Prime cardinality

Suppose $|T|=p$ is prime. The product law gives

$$
p=\prod_{x\in T}|F(x)|.
$$

Since every factor is a positive integer, elementary prime factorization suggests that exactly one fiber has cardinality $p$ and every other fiber has cardinality $1$. This is a natural classification target. The Boolean model is the case $p=2$.

### 4.3. Constant fibers

If $F(x)=A$ for all $x$, with $n=|T|$ and $a=|A|$, then the product equation becomes

$$
n=a^n.
$$

For $n\ge2$ and $a\ge2$,

$$
a^n\ge2^n>n,
$$

so no such nontrivial finite constant-fiber solution exists. Thus the dependent construction avoids a growth obstruction that defeats constant function spaces. Concentrating data in one fiber changes $a^n$ into $n\cdot1\cdots1=n$.

## 5. Algorithms and numerical demonstrations

### 5.1. Enumerating sections

For a finite ordered base $T=(x_1,\ldots,x_n)$ with explicitly listed fibers, all sections may be enumerated by a Cartesian product. Start with the empty partial assignment. At stage $i$, extend every existing assignment by each value of $F(x_i)$. After $n$ stages, the list contains every section exactly once.

If the fiber sizes are $f_i=|F(x_i)|$, the number of outputs is

$$
N=\prod_{i=1}^n f_i.
$$

Any complete enumeration requires $\Omega(N)$ output operations. Materializing each section as an $n$-tuple costs $O(nN)$ time and $O(nN)$ storage; streaming the tuples reduces auxiliary storage while preserving output size.

For the Boolean model, the Cartesian product is

$$
\{\mathsf{false},\mathsf{true}\}\times\{\star\}
=
\{(\mathsf{false},\star),(\mathsf{true},\star)\}.
$$

### 5.2. Checking the cardinality condition

Given $n=|T|$ and fiber cardinalities $f_1,\ldots,f_n$, compute their product and compare it with $n$. This check runs in $O(n)$ integer multiplications and $O(1)$ list-external storage. It is a necessary test for a proposed finite fixed point. Failure proves that no equivalence can exist for the specified family. Success proves equal cardinality, and therefore existence of some bijection for finite sets, but it does not by itself validate a proposed encoder and decoder.

### 5.3. Verifying explicit inverse maps

For finite structures, one can additionally enumerate every state and every section. Check

$$
D(E(t))=t
$$

for all $t\in T$, and

$$
E(D(s))=s
$$

for all sections $s$. This exhaustive procedure directly verifies that the supplied maps are inverses. Its running time is proportional to the combined size of $T$ and the section space, multiplied by the cost of comparing section tuples.

In the Boolean case, the two round trips are immediate:

$$
\mathsf{false}\mapsto(\mathsf{false},\star)\mapsto\mathsf{false},
$$

$$
\mathsf{true}\mapsto(\mathsf{true},\star)\mapsto\mathsf{true}.
$$

The reverse round trips are the same two rows read in the opposite direction.

## 6. Applications and conceptual consequences

### 6.1. Sparse records

A section can be viewed as a record whose field type depends on the field name. Singleton fibers are fields with forced defaults; they consume structural position but no variable payload. The Boolean model is the smallest sparse record: two fields, one informative and one forced. The equivalence identifies the record with its payload.

### 6.2. Distributed state

The product law describes how global state capacity decomposes into local capacities. In systems where coordinates vary independently, cardinalities multiply. A fixed point requires the total local capacity to match the number of global states. Concentrated solutions put all capacity at a distinguished location; more distributed solutions would factor the global cardinality among several nontrivial fibers.

### 6.3. Dependent interfaces

In a dependent interface, the legal response depends on the query. The Boolean family presents two queries. One requests a bit; the other admits only an acknowledgement. A complete responder is equivalent to the bit it returns to the informative query. This illustrates how dependent products can model heterogeneous interfaces without requiring every endpoint to carry the same payload.

### 6.4. Limits of self-reference as an undecidability principle

The proposition-valued collapse and data-valued non-collapse jointly show that a fixed-point equation cannot be interpreted in isolation as evidence of incompleteness. Undecidability in the computability-theoretic sense requires an effective presentation: a coded language, algorithms on codes, substitution, a semantics or provability predicate, and explicit consistency or soundness assumptions. The present equation is structural rather than computational. It classifies representations of data; it does not by itself encode an undecidable decision problem.

Likewise, ordinal claims require ordinal objects and order-preserving constructions. A cardinality of fixed-point types cannot simply be identified with an ordinal such as the Church–Kleene ordinal without specifying a universe, coding, quotient by equivalence, and a bridge between cardinal and ordinal notions. For the proposition-valued equation, the equivalence classes already collapse to one.

## 7. Discussion

The Boolean model is minimal in several senses. A singleton base cannot demonstrate non-collapse. The two-element base is therefore the smallest candidate. Its fiber cardinalities must multiply to two, so the only positive pattern, up to permutation, is $(2,1)$. This arithmetic already forces concentration and unequal fibers.

The example also separates three levels of evidence:

1. The cardinal equation $2=2\cdot1$ shows that a bijection is numerically possible.
2. The explicit encoder and decoder construct the bijection and explain it.
3. Fiber inequivalence proves that dependence is essential to this particular construction.

These levels should remain distinct in larger classifications. Cardinality may rule examples out or guarantee an abstract finite bijection, while explicit maps reveal computational content. Dependence may be witnessed by unequal cardinalities, although equal-cardinality fibers can still differ structurally in richer settings.

The contrast with proposition-valued fibers is equally sharp. There the section product is a subsingleton for a pointwise reason that does not involve counting. Transferring that property across the equivalence collapses the base. In the data-valued setting, the Boolean fiber has two distinguishable values, and this single local distinction propagates to two distinguishable global sections and hence two distinguishable base states.

The finite product law does not yet classify all families. For composite $n$, many factor patterns may satisfy the numerical equation. For example, a global cardinality $6$ could be concentrated as $6\cdot1\cdots1$ or distributed as $2\cdot3\cdot1\cdots1$. Because the base itself has six indices, the remaining factors must be singleton. Each pattern supports a finite section set of size six, but additional criteria may distinguish canonical, symmetric, computable, or semantically meaningful equivalences.

Infinite types introduce further subtleties. Cardinal multiplication behaves differently, and an explicit concentrated construction requires selecting a distinguished point and deciding whether a queried index equals it. This motivates the conjecture that every inhabited type with decidable equality admits a concentrated data-valued fixed point. The intended family puts a copy of $T$ over the chosen point and singleton fibers elsewhere; encoding stores the state at that point, and decoding evaluates there. The dependent typing of the construction makes equality transport an essential ingredient.

## 8. Future work

The Boolean witness leads to the following concrete research program.

**Conjecture 8.1 (Finite existence at every positive cardinality).** For every natural number $n>0$, there exist a finite type $T$ with $|T|=n$ and finite fibers $F(x)$ such that

$$
T\simeq\prod_{x\in T}F(x).
$$

A proposed witness chooses one distinguished point, puts an $n$-element fiber there, and uses singleton fibers elsewhere.

**Conjecture 8.2 (Genuine dependence at every nontrivial finite cardinality).** For every $n\ge2$, the preceding witness can be chosen with two fibers of unequal cardinality. Therefore it cannot be pointwise equivalent to a constant family.

**Conjecture 8.3 (Prime-cardinality classification).** If $|T|=p$ is prime and finite fibers satisfy the fixed-point equation, then exactly one fiber has cardinality $p$ and every other fiber has cardinality $1$.

**Conjecture 8.4 (Triviality of constant finite fibers).** If finite nonempty $T$ and finite $A$ satisfy $T\simeq(T\to A)$, then either $T$ is a singleton or $A$ is a singleton. Numerically, $n=a^n$ has no solution with $n\ge2$ and $a\ge2$.

**Conjecture 8.5 (Concentrated solutions for decidable inhabited types).** Every inhabited type with decidable equality is a data-valued dependent-product fixed point, witnessed by putting all data over one distinguished point and a singleton over every other point.

Beyond these conjectures, one may study coded syntax and semantics when true diagonal or incompleteness phenomena are desired. A suitable framework would include an enumerable code language, partial interpretation, substitution, a diagonal lemma, and a computability predicate. Universe-sensitive self-reference should similarly operate through codes and a decoding function, with positivity or guardedness conditions controlling recursion. Finally, any hierarchy modeled on arithmetic should begin with a precise effective index set and strictness proofs by reduction before transfinite iteration is considered.

## 9. Conclusion

Data-valued dependent-product fixed points behave fundamentally differently from their proposition-valued counterparts. Proposition-valued sections are subsingletons, forcing the base to be a singleton. Ordinary data fibers retain distinguishable choices, and the Boolean family supplies the smallest explicit non-collapsing example:

$$
F(\mathsf{false})=\mathbb B,
\qquad
F(\mathsf{true})=\mathbf1,
\qquad
\mathbb B\simeq\prod_{b\in\mathbb B}F(b).
$$

The equivalence simply writes and reads the value at $\mathsf{false}$. The unequal fiber sizes prove genuine dependence, while the two encoded sections prove non-collapse. In every finite example, the cardinality product law

$$
|T|=\prod_{x\in T}|F(x)|
$$

acts as the first invariant and expresses conservation of finite information capacity. The Boolean equation $2=2\cdot1$ is both the simplest instance and the prototype for a wider theory of concentrated and distributed dependent data.
