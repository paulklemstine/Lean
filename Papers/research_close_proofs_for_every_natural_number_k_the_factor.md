# Equivariant Factorial Codes: Recursive Permutation Coordinates, Torsor Structure, and an Additive Boundary

**Aristotle**  
**July 15, 2026**

## Abstract

For each natural number $k$, consider the mixed-radix factorial-code space whose digit in position $i$ lies in $\{0,1,\ldots,i\}$. We give a recursive classification of this space by the symmetric group $S_k$. The construction splits off the highest-radix digit and matches it with the standard decomposition of a permutation obtained by selecting one distinguished image and reducing to a permutation on $k-1$ symbols. Consequently, encoding and decoding are mutually inverse, and the code space has exactly $k!$ elements. Transporting left multiplication through this classification equips factorial codes with a canonical $S_k$-action. We prove that this action is free and transitive; equivalently, the factorial-code space is an $S_k$-torsor, so every ordered pair of codes admits a unique transporting permutation. We then distinguish this equivariant classification from an additive Chinese-remainder interpretation. At length $4$, the code space has $24$ elements and classifies $S_4$, but $\mathbb Z/24\mathbb Z$ is not additively isomorphic to $\mathbb Z/2\mathbb Z\times\mathbb Z/3\mathbb Z\times\mathbb Z/4\mathbb Z$, since the former has exponent $24$ and the latter exponent $12$. We describe ranking, unranking, permutation encoding, action evaluation, computational complexity, and implications for permutation-equivariant representations.

## 1. Introduction

The factorial identity

$$
|S_k|=k!=\prod_{j=1}^{k}j
$$

suggests that a permutation can be represented by a sequence of choices with radices $1,2,\ldots,k$. This is the basis of factorial number systems and Lehmer-type permutation codes. The elementary count, however, does not by itself identify which structural features of permutations survive in the digit representation. An arbitrary bijection between two finite sets of size $k!$ would establish cardinality but would say nothing about recursion, composition, or symmetry.

The purpose of this paper is to isolate a recursive equivalence and develop its equivariant consequences. A factorial code of length $k$ is a tuple $c=(c_0,\ldots,c_{k-1})$ satisfying $0\le c_i\le i$. The highest digit has $k$ choices, and deleting it leaves a code of length $k-1$. A permutation of $k$ symbols admits a parallel decomposition: choose one distinguished image, remove it, and standardize the remaining bijection to a permutation of $k-1$ symbols. Matching these decompositions recursively gives a natural classification.

Once a code is identified with a permutation, left multiplication in $S_k$ can be transported to the code space. The resulting action is not merely transitive. It is regular: no nonidentity permutation fixes a code, and there is exactly one group element carrying any chosen code to any other. Thus factorial codes form a torsor for $S_k$.

This result clarifies both the power and the limitations of factorial coordinates. They perfectly encode the underlying set and its regular symmetry. They do not, however, turn factorial digits into independent additive residue coordinates. The first decisive failure occurs at length $4$. Although $2\cdot3\cdot4=24$, the cyclic group of order $24$ is not the direct product of cyclic groups of orders $2$, $3$, and $4$. Cardinality agrees, but exponent does not.

The distinction is relevant in computation and machine learning. Permutation-valued states arise in ranking, matching, assignment, sorting, anonymous multi-agent systems, and set-based models. Recursive factorial coordinates provide compact, exact representations and support ranking and unranking. Their torsor structure gives an exact language for equivariance. The additive obstruction warns that coordinatewise arithmetic does not automatically preserve the intended transformation law.

## 2. Factorial codes and recursive decompositions

### 2.1. Basic definitions

Let $k$ be a natural number, and write

$$
[k]=\{0,1,\ldots,k-1\}.
$$

A **factorial code of length $k$** is a tuple

$$
c=(c_0,c_1,\ldots,c_{k-1})
$$

such that

$$
0\le c_i<i+1
$$

for every $i\in[k]$. Denote the set of these codes by $C_k$. Equivalently,

$$
C_k=\prod_{i=0}^{k-1}\{0,1,\ldots,i\}.
$$

The empty product $C_0$ contains one empty code. Let $S_k$ denote the group of all permutations of $[k]$, with multiplication given by composition.

The digit order used in this definition has increasing radices. Classical Lehmer codes are often written in decreasing-radix order. The two conventions differ only by reversal, and all structural statements are unaffected once a convention is fixed.

### 2.2. Splitting the highest digit

A code in $C_{k+1}$ consists of the initial $k$ digits, which form an element of $C_k$, and a final digit $c_k\in\{0,\ldots,k\}$. Hence there is a canonical bijection

$$
C_{k+1}\cong [k+1]\times C_k.
$$

This is not a numerical coincidence; it is the defining recursive structure of the code space.

Permutations have a matching decomposition. Fix the distinguished domain element $0$. Given $\pi\in S_{k+1}$, record $a=\pi(0)\in[k+1]$. Remove $0$ from the domain and $a$ from the codomain. Order-preserving relabelings identify both remaining $k$-element sets with $[k]$, producing a reduced permutation $\rho\in S_k$. Conversely, from $(a,\rho)$ one inserts the distinguished domain element and maps it to $a$, using $\rho$ to match the remaining ordered elements. Therefore

$$
S_{k+1}\cong [k+1]\times S_k.
$$

Other distinguished-element conventions produce equivalent recursive encodings. What matters is that the choice be fixed and that deletion and insertion be inverse operations.

### 2.3. Recursive classification theorem

**Theorem 1 (Recursive Factorial-Code Classification).** For every natural number $k$, there is a bijection

$$
E_k:S_k\longrightarrow C_k
$$

obtained recursively by matching the distinguished-image decomposition of $S_k$ with the highest-digit decomposition of $C_k$. Its inverse

$$
D_k:C_k\longrightarrow S_k
$$

satisfies

$$
D_k(E_k(\pi))=\pi
\qquad\text{and}\qquad
E_k(D_k(c))=c
$$

for all $\pi\in S_k$ and $c\in C_k$.

**Proof sketch.** At $k=0$, both $S_0$ and $C_0$ are singleton sets, so there is a unique bijection. Assume $E_k$ has been constructed. Decompose a permutation in $S_{k+1}$ into a distinguished image $a\in[k+1]$ and a reduced permutation $\rho\in S_k$. Apply $E_k$ to $\rho$, then combine $a$ with the resulting code using the highest-digit split of $C_{k+1}$. Define the inverse by reversing these steps: split off the highest digit, decode the shorter code using $D_k$, and insert the distinguished image. Since deletion and insertion are inverse and $E_k,D_k$ are inverse by induction, the new maps are inverse. Induction completes the construction. $\square$

The theorem supplies more than an abstract bijection. It aligns the filtration

$$
C_0,C_1,\ldots,C_k
$$

with the standard chain

$$
S_0,S_1,\ldots,S_k.
$$

Each stage introduces exactly one digit and one coset choice.

### 2.4. Cardinality

**Corollary 2 (Factorial Cardinality).** For every natural number $k$,

$$
|C_k|=k!.
$$

**Proof sketch.** The classification theorem gives $|C_k|=|S_k|$, and $|S_k|=k!$. Directly, the product rule also yields

$$
|C_k|=\prod_{i=0}^{k-1}(i+1)=k!.
$$

The recursive bijection strengthens this count by giving explicit inverse maps. $\square$

## 3. Concrete encoding, decoding, ranking, and unranking

The recursive theorem admits several computational realizations. A standard Lehmer realization uses decreasing radices. Let a permutation be represented as a list

$$
p=(p_0,p_1,\ldots,p_{k-1})
$$

containing every element of $[k]$ exactly once. Maintain the sorted list $L$ of unused values. At stage $j$, let $d_j$ be the zero-based index of $p_j$ in $L$, then remove $p_j$. The resulting digits satisfy

$$
0\le d_j<k-j.
$$

Thus $(d_0,\ldots,d_{k-1})$ is a decreasing-radix code. Reversing it gives an element of $C_k$.

**Algorithm 1 (Permutation to Factorial Code).** Initialize $L=[0,1,\ldots,k-1]$. For $j=0$ through $k-1$, find the index $d_j$ of $p_j$ in $L$, record it, and delete that entry. Return $(d_{k-1},\ldots,d_0)$.

**Correctness sketch.** At stage $j$, the list $L$ has $k-j$ entries, so $d_j$ is a valid digit. Deletion ensures no value is selected twice. The decoding algorithm below selects the same indexed entry at every stage, proving mutual inversion by induction on the stages.

**Algorithm 2 (Factorial Code to Permutation).** Reverse the increasing-radix code to obtain decreasing-radix digits. Initialize $L=[0,1,\ldots,k-1]$. For each digit $d_j$, append the element at index $d_j$ of $L$ to the output and delete it from $L$.

With an array-backed list, index lookup and deletion each cost $O(k)$ in the worst case, so both elementary algorithms use $O(k^2)$ time and $O(k)$ auxiliary space. An order-statistic tree supports selection, rank, and deletion in $O(\log k)$ time, reducing the total to $O(k\log k)$ while retaining $O(k)$ space.

Factorial codes also rank permutations. For an increasing-radix code $c\in C_k$, define

$$
R(c)=\sum_{i=0}^{k-1}c_i i!.
$$

**Proposition 3 (Factorial Ranking).** The map $R$ is a bijection from $C_k$ to $\{0,1,\ldots,k!-1\}$.

**Proof sketch.** For $k=0$, both sets have one element. Recursively write a code in $C_{k+1}$ as $(c',a)$ with $c'\in C_k$ and $0\le a\le k$. Then

$$
R(c',a)=R(c')+a k!.
$$

By induction, $R(c')$ ranges uniquely over $0$ through $k!-1$. The intervals

$$
[ak!,(a+1)k!-1]
$$

for $a=0,\ldots,k$ are disjoint and partition $0$ through $(k+1)!-1$. Hence ranking is bijective. $\square$

Unranking repeatedly extracts mixed-radix remainders. Starting from $n<k!$, for $i=1,2,\ldots,k$, set

$$
c_{i-1}=n\bmod i,
\qquad
n\leftarrow\left\lfloor\frac{n}{i}\right\rfloor.
$$

The resulting digits satisfy $c_{i-1}<i$. The division algorithm shows that ranking and unranking are inverse. Arithmetic unranking requires $O(k)$ divisions; the bit complexity depends on the integer representation and the size of $k!$.

## 4. The transported symmetric-group action

### 4.1. Definition and action laws

Let $E_k:S_k\to C_k$ and $D_k:C_k\to S_k$ be the mutually inverse maps of Theorem 1. For $\sigma\in S_k$ and $c\in C_k$, define

$$
\sigma\cdot c=E_k\bigl(\sigma D_k(c)\bigr).
$$

This is left multiplication transported through the classification.

**Proposition 4 (Equivariance of Decoding and Encoding).** For all $\sigma,\tau\in S_k$ and $c\in C_k$,

$$
D_k(\sigma\cdot c)=\sigma D_k(c)
$$

and

$$
E_k(\sigma\tau)=\sigma\cdot E_k(\tau).
$$

**Proof sketch.** Apply the inverse identities $D_kE_k=\operatorname{id}_{S_k}$ and $E_kD_k=\operatorname{id}_{C_k}$ directly to the definition. $\square$

**Proposition 5 (Group-Action Laws).** The operation above is a left action of $S_k$ on $C_k$. If $e$ is the identity permutation, then

$$
e\cdot c=c,
$$

and for all $\sigma,\tau\in S_k$,

$$
(\sigma\tau)\cdot c=\sigma\cdot(\tau\cdot c).
$$

**Proof sketch.** For the identity law,

$$
e\cdot c=E_k(D_k(c))=c.
$$

For compatibility, decode the intermediate action and use associativity:

$$
\sigma\cdot(\tau\cdot c)
=E_k\bigl(\sigma D_k(E_k(\tau D_k(c)))\bigr)
=E_k\bigl(\sigma\tau D_k(c)\bigr)
=(\sigma\tau)\cdot c.
$$

$\square$

### 4.2. Freeness and transitivity

An action of a group $G$ on a set $X$ is **free** if $g\cdot x=x$ implies $g=e$. It is **transitive** if for every $x,y\in X$, some $g\in G$ satisfies $g\cdot x=y$. An action that is both free and transitive is called **regular**, and the set $X$ is called a **$G$-torsor**.

**Theorem 6 (Freeness).** The transported action of $S_k$ on $C_k$ is free.

**Proof sketch.** Suppose $\sigma\cdot c=c$. Decode both sides to obtain

$$
\sigma D_k(c)=D_k(c).
$$

Right-multiplying by $D_k(c)^{-1}$ yields $\sigma=e$. $\square$

**Theorem 7 (Transitivity).** The transported action of $S_k$ on $C_k$ is transitive.

**Proof sketch.** Given $c,d\in C_k$, define

$$
\sigma=D_k(d)D_k(c)^{-1}.
$$

Then

$$
\sigma\cdot c
=E_k\bigl(D_k(d)D_k(c)^{-1}D_k(c)\bigr)
=E_k(D_k(d))
=d.
$$

$\square$

**Theorem 8 (Factorial-Code Torsor Theorem).** For every natural number $k$ and every ordered pair $c,d\in C_k$, there exists a unique $\sigma\in S_k$ such that

$$
\sigma\cdot c=d.
$$

The unique transporter is

$$
\sigma=D_k(d)D_k(c)^{-1}.
$$

**Proof sketch.** Existence is Theorem 7. If both $\sigma$ and $\tau$ carry $c$ to $d$, then

$$
(\tau^{-1}\sigma)\cdot c=c.
$$

Freeness gives $\tau^{-1}\sigma=e$, hence $\sigma=\tau$. The displayed formula follows from the existence proof. $\square$

The torsor theorem is the principal structural conclusion. The code space has no preferred group identity until a base code is chosen. Once a base code $c_*$ is fixed, the map $\sigma\mapsto\sigma\cdot c_*$ identifies $S_k$ with $C_k$. Changing the base code changes this identification by right translation.

### 4.3. Computing the action and transporter

To compute $\sigma\cdot c$, one may decode $c$, compose permutations, and re-encode. Using elementary list algorithms, decoding and encoding cost $O(k^2)$ and composition costs $O(k)$, so total time is $O(k^2)$ with $O(k)$ space. With order-statistic trees, the conversion stages can be reduced to $O(k\log k)$.

To compute the unique transporter from $c$ to $d$, decode both, invert $D_k(c)$, and compose:

$$
T(c,d)=D_k(d)D_k(c)^{-1}.
$$

Permutation inversion and composition are linear once the decoded arrays are available. This formula is useful when relative alignment is primary and no absolute reference code is distinguished.

## 5. The additive Chinese-remainder boundary

### 5.1. Equal size does not imply equal group structure

The product formula for code cardinality may suggest that the digit components are independent residue rings. For $k=4$, omitting the trivial radix $1$ gives the additive product

$$
A=\mathbb Z/2\mathbb Z\times\mathbb Z/3\mathbb Z\times\mathbb Z/4\mathbb Z.
$$

Its cardinality is

$$
|A|=2\cdot3\cdot4=24,
$$

which equals the cardinality of

$$
B=\mathbb Z/24\mathbb Z.
$$

There are therefore set bijections between $A$ and $B$. The question is whether one can preserve addition.

For a finite group $G$, its **exponent** is the least positive integer $m$ such that $mg=0$ for every $g\in G$. The exponent of a cyclic group of order $n$ is $n$. The exponent of a direct product of cyclic groups of orders $n_1,\ldots,n_r$ is

$$
\operatorname{lcm}(n_1,\ldots,n_r).
$$

This follows because the order of a tuple is the least common multiple of the orders of its components.

**Theorem 9 (Length-Four Additive Obstruction).** There is no additive group isomorphism

$$
\mathbb Z/24\mathbb Z
\cong
\mathbb Z/2\mathbb Z\times\mathbb Z/3\mathbb Z\times\mathbb Z/4\mathbb Z.
$$

**Proof sketch.** The class of $1$ in $\mathbb Z/24\mathbb Z$ has order $24$, so the exponent of the left side is $24$. The exponent of the right side is

$$
\operatorname{lcm}(2,3,4)=12.
$$

An isomorphism preserves element orders and therefore preserves exponent. Since $24\ne12$, no additive isomorphism exists. $\square$

**Corollary 10 (Classification with CRT Boundary).** At length $4$, factorial codes are in bijection with permutations in $S_4$, and both sets have $24$ elements; nevertheless, the radix groups do not provide independent additive coordinates for $\mathbb Z/24\mathbb Z$.

**Proof sketch.** The classification and cardinality assertions follow from Theorem 1 and Corollary 2. The additive failure is Theorem 9. $\square$

### 5.2. Why the classical Chinese Remainder Theorem does not apply

The Chinese Remainder Theorem gives

$$
\mathbb Z/(mn)\mathbb Z
\cong
\mathbb Z/m\mathbb Z\times\mathbb Z/n\mathbb Z
$$

as rings, and hence as additive groups, when $m$ and $n$ are coprime. Iterated versions require pairwise coprime moduli. The factorial radices $2,3,4$ are not pairwise coprime; in particular, $2$ and $4$ share a factor. Their prime-power content overlaps, so the product does not contain an element combining component orders into order $24$.

Factorial digits are independent for enumeration: every permitted tuple is a valid code. They are not independent under componentwise modular addition if the goal is to model addition modulo $k!$. Carries encode the missing interaction. This distinction between a Cartesian-product parameterization and an algebraic product decomposition is essential.

## 6. Examples

### 6.1. Length four

The code space $C_4$ consists of tuples

$$
(0,c_1,c_2,c_3)
$$

with $c_1\in\{0,1\}$, $c_2\in\{0,1,2\}$, and $c_3\in\{0,1,2,3\}$. It has $1\cdot2\cdot3\cdot4=24$ members. Ranking sends these codes bijectively to $0,\ldots,23$ by

$$
R(c)=c_1+2c_2+6c_3.
$$

This set is simultaneously a coordinate space for $S_4$. Yet if one performs componentwise addition modulo $2$, $3$, and $4$, every element has additive order dividing $12$. Ranking does not turn this operation into addition modulo $24$.

### 6.2. A permutation code

Consider

$$
p=(3,1,4,0,2).
$$

Starting with $L=[0,1,2,3,4]$, the successive indices are $3,1,2,0,0$. Thus the decreasing-radix code is $(3,1,2,0,0)$, and the increasing-radix code is

$$
(0,0,2,1,3).
$$

Its factorial rank is

$$
0\cdot0!+0\cdot1!+2\cdot2!+1\cdot3!+3\cdot4!=82.
$$

Since $0\le82<5!=120$, this is a valid rank. Unranking $82$ by successive divisions with radices $1,2,3,4,5$ recovers the same increasing-radix digits, and decoding recovers $p$.

### 6.3. A unique transporter

Let codes $c,d\in C_k$ decode to permutations $\tau_c,\tau_d$. The transporter is not found by search. It is given directly by

$$
T(c,d)=\tau_d\tau_c^{-1}.
$$

Applying it to $c$ gives $d$. If another permutation had the same effect, right cancellation after decoding would force it to equal $T(c,d)$.

## 7. Applications

### 7.1. Exact enumeration and sampling

Ranking and unranking provide random access to the permutation space. Uniformly sampling an integer from $0$ through $k!-1$ and unranking it yields a uniform random permutation. Conversely, a permutation can be stored by its rank using approximately

$$
\log_2(k!)
$$

bits, close to the information-theoretic minimum. Exhaustive searches can partition rank intervals among workers without overlap.

### 7.2. Permutation-equivariant models

Suppose data are naturally indexed by interchangeable labels. A transformation is permutation-equivariant if relabeling the input relabels the output compatibly. The transported action gives an exact action on factorial coordinates rather than on permutation arrays. Since $C_k$ is a single regular orbit, an equivariant construction can be analyzed through one base code and the group element relating every other code to it.

For scalar functions invariant under the regular left action, transitivity implies constancy. For maps between torsors with compatible group actions, the image of one base point strongly constrains the entire map. These observations can guide parameter sharing, data augmentation, and canonicalization. They also caution that digitwise neural operations need not be equivariant: a valid architecture must respect the transported group action, not merely the Cartesian shape of the code.

### 7.3. Relative alignment

A torsor records differences without selecting an origin. In matching and synchronization problems, two states $c$ and $d$ determine the unique relative permutation $T(c,d)$. This is useful when absolute labels are arbitrary but pairwise alignments are meaningful, as in anonymous agents, cluster labels, graph matchings, and repeated measurements with unknown ordering.

### 7.4. Hierarchical computation

The recursive split $C_{k+1}\cong[k+1]\times C_k$ suggests stagewise algorithms. A model may process a short code and then incorporate one new digit, mirroring insertion of one new object into a permutation. This hierarchy aligns with the subgroup chain $S_1\subset S_2\subset\cdots\subset S_k$ and may support multiscale representations. The present results establish the exact finite structure on which such designs can be based.

## 8. Discussion

The results separate three notions that are easy to conflate.

First, there is **enumerative independence**: the digits range freely and independently over sets of sizes $1,2,\ldots,k$, giving $k!$ tuples. Second, there is **equivariant completeness**: recursive encoding identifies every code with a unique permutation and transports the regular group action. Third, there is **additive independence**: componentwise cyclic addition would need to reproduce a cyclic group of order $k!$. The first two hold; the third already fails at $k=4$.

The recursive nature of the classification is crucial. Cardinality alone could produce a nonconstructive or structurally arbitrary bijection. By matching deletion and insertion on permutations with digit splitting and adjoining on codes, the classification respects a natural hierarchy. This makes the representation suitable for algorithms and for studying group actions.

The torsor theorem is equally important. Saying that $C_k$ has $k!$ points does not explain how those points are related. Saying that it is an $S_k$-torsor specifies the relation exactly: every ordered pair has a unique group-valued displacement. This is the finite analogue of a homogeneous coordinate space with no preferred origin.

The additive obstruction illustrates why representation choices must be evaluated against their intended operations. A bijective encoding preserves information, but only an equivariant encoding preserves a specified symmetry, and only a homomorphism preserves an algebraic operation. Factorial codes are bijective and can be made equivariant for permutation multiplication; their raw digit product is not additively equivalent to a single cyclic counter at length $4$.

## 9. Future work

Several directions follow naturally. One is to describe the transported effect of adjacent transpositions directly on digits and determine whether the affected interval is uniformly local. A second is to characterize strong Bruhat order using intrinsic digit carries, without decoding to permutations. A third is to generalize the exponent obstruction: for $k\ge4$, one expects the product $\mathbb Z/2\mathbb Z\times\cdots\times\mathbb Z/k\mathbb Z$ to have exponent $\operatorname{lcm}(2,\ldots,k)$, strictly below $k!$.

The recursive subgroup chain also invites harmonic analysis. Transporting the regular representation to factorial codes may yield a multiscale Fourier transform whose stagewise conditional expectations reflect restriction along $S_1\subset\cdots\subset S_k$. Finally, equivariant architectures can exploit recursive digit splits and parameter sharing. The torsor theorem suggests that an equivariant map is controlled by its value at a base point, while the computational challenge is to realize this control efficiently in digit coordinates.

## 10. Conclusion

Factorial codes provide recursive mixed-radix coordinates for permutations. For every $k$, encoding and decoding give inverse bijections between $C_k$ and $S_k$, proving that $|C_k|=k!$. Transported left multiplication makes $C_k$ a free and transitive $S_k$-space, so every ordered pair of codes has a unique transporting permutation. These properties support exact ranking, unranking, sampling, alignment, and equivariant computation.

At the same time, the length-four exponent obstruction establishes a clean algebraic boundary. Although the factorial digit product and $\mathbb Z/24\mathbb Z$ have equal cardinality, their additive groups are not isomorphic. Factorial codes should therefore be understood as recursive equivariant coordinates, not as independent Chinese-remainder coordinates. That distinction identifies both their structural strength and the role of carries in any arithmetic built upon them.