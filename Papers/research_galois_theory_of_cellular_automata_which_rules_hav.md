# Universal Finite-Cycle Reversibility of Elementary Cellular Automata

**Aristotle**  
**July 30, 2026**

## Abstract

We classify the elementary binary cellular automata whose global dynamics are reversible on every nonempty finite cycle. A local elementary rule maps a three-bit neighborhood to one bit, and its simultaneous application induces a self-map of the $2^n$ configurations on a cycle of length $n$. Reversibility is therefore a global bijectivity property, not a permutation property of the eight local neighborhoods. Exactly six Wolfram rules are universally finite-cycle reversible:

$$
15,\ 51,\ 85,\ 170,\ 204,\ 240.
$$

Their global actions are, respectively, complemented left shift, complement, complemented right shift, right shift, identity, and left shift. Explicit inverse formulas prove reversibility for every $n\ge 1$. An exhaustive finite criterion shows that bijectivity on the four cycles of lengths $1,2,3,4$ already restricts an elementary rule to these six. Consequently, every other elementary rule has a non-bijective global map on a cycle of length at most four. We present the definitions, structural lemmas, classification proof, enumeration algorithm, complexity analysis, and implications for the group-theoretic study of reversible cellular dynamics.

## 1. Introduction

Cellular automata turn a local transition law into a global dynamical system. Their defining tension is that each cell uses only nearby information, while all cells update simultaneously and their neighborhoods overlap. This makes global properties—surjectivity, injectivity, periodicity, and reversibility—substantially more subtle than the truth table of a single cell.

An elementary cellular automaton has alphabet $A=\{0,1\}$, radius one, and a local map

$$
f:A^3\to A.
$$

There are $2^8=256$ such maps. On a finite cycle of length $n$, a configuration is a word in $A^n$, with wraparound boundary conditions. The local rule induces a global map $F_{f,n}:A^n\to A^n$. Our central notion is universal finite-cycle reversibility: $F_{f,n}$ must be bijective for every positive integer $n$.

This paper establishes a complete classification. The result corrects a common category error in attempts to place elementary rules directly inside a symmetric group on neighborhoods. A local map $A^3\to A$ is not a permutation of $A^3$: its domain has eight elements and its codomain has two. The relevant permutations are bijective global maps of a configuration space. Furthermore, rules of exactly fixed radius are generally not closed under composition, because composing radii $r$ and $s$ can produce radius $r+s$. Thus the natural group consists of reversible, finite-radius, shift-equivariant global maps, possibly equipped with a radius filtration.

The elementary classification proceeds in two complementary parts. First, six candidate rules are identified with shifts and pointwise complement, yielding explicit inverses for arbitrary cycle length. Second, all $256$ rules are tested on the cycles of lengths $1$ through $4$. Exactly those six survive. This pairing of finite exhaustion with uniform structural proof is essential: finite testing selects the candidates, while explicit formulas establish the infinite family of claims indexed by $n$.

## 2. Definitions and conventions

### 2.1 Cyclic configurations

Fix $n\ge 1$. The cyclic index set is $\mathbb Z/n\mathbb Z$, represented by integers modulo $n$. A binary configuration is a function

$$
x:\mathbb Z/n\mathbb Z\to\{0,1\}.
$$

Equivalently, $x=(x_0,\ldots,x_{n-1})\in\{0,1\}^n$. The configuration space has cardinality $2^n$.

Define the predecessor and successor of an index $i$ by

$$
i^- = i-1\pmod n,\qquad i^+=i+1\pmod n.
$$

These operations are mutual inverses: $(i^+)^-=i$ and $(i^-)^+=i$.

### 2.2 Elementary local rules and Wolfram numbers

An elementary local rule is a function

$$
f:\{0,1\}^3\to\{0,1\}.
$$

For a neighborhood $(l,c,r)$, define its index by

$$
\iota(l,c,r)=4l+2c+r\in\{0,1,\ldots,7\}.
$$

For a Wolfram number $w\in\{0,1,\ldots,255\}$, the associated local rule $f_w$ is

$$
f_w(l,c,r)=\left\lfloor\frac{w}{2^{\iota(l,c,r)}}\right\rfloor\bmod 2.
$$

Thus the eight binary digits of $w$ are precisely the eight outputs of the local rule.

### 2.3 Global dynamics and reversibility

The global map induced by $f$ on the $n$-cycle is

$$
F_{f,n}(x)_i=f(x_{i^-},x_i,x_{i^+}).
$$

For rule number $w$, write $F_{w,n}=F_{f_w,n}$.

**Definition 2.1 (Reversibility on a cycle).** An elementary rule $w$ is reversible on the cycle of length $n$ if $F_{w,n}:\{0,1\}^n\to\{0,1\}^n$ is bijective.

**Definition 2.2 (Universal finite-cycle reversibility).** An elementary rule $w$ is universally finite-cycle reversible if it is reversible on every cycle of positive length:

$$
\forall n\ge 1,\quad F_{w,n}\text{ is bijective}.
$$

Because the domain and codomain are the same finite set, injectivity, surjectivity, and bijectivity are equivalent for each fixed $n$. A collision $F_{w,n}(x)=F_{w,n}(y)$ with $x\ne y$ is therefore a complete witness of non-reversibility.

### 2.4 Shift and complement operators

Define left shift $L_n$, right shift $R_n$, and complement $C_n$ on configurations by

$$
(L_nx)_i=x_{i^-},\qquad (R_nx)_i=x_{i^+},\qquad (C_nx)_i=1-x_i.
$$

The identity map is denoted $I_n$. The index identities immediately imply

$$
L_nR_n=R_nL_n=I_n.
$$

Pointwise Boolean complementation gives

$$
C_n^2=I_n.
$$

Finally, shifts commute with complement:

$$
C_nL_n=L_nC_n,\qquad C_nR_n=R_nC_n.
$$

## 3. Structural analysis of the six candidates

We begin with elementary but decisive inverse lemmas.

**Lemma 3.1 (Cyclic shift inverse).** For every $n\ge 1$, $L_n$ and $R_n$ are mutual inverses. Consequently, both are bijections of $\{0,1\}^n$.

**Proof sketch.** For each index $i$, successor followed by predecessor and predecessor followed by successor both return $i$. Hence

$$
(L_nR_nx)_i=x_{(i^-)^+}=x_i,
$$

and similarly $(R_nL_nx)_i=x_i$. Therefore each shift is an explicit two-sided inverse of the other. $\square$

**Lemma 3.2 (Complement involution).** For every $n\ge 1$, $C_n$ is an involution and hence a bijection.

**Proof sketch.** At each site,

$$
(C_nC_nx)_i=1-(1-x_i)=x_i.
$$

Thus $C_n^{-1}=C_n$. $\square$

**Lemma 3.3 (Complemented shifts).** For every $n\ge 1$, $C_nR_n$ and $C_nL_n$ are bijective, and they are mutual inverses.

**Proof sketch.** Composition of bijections is bijective. More explicitly, using commutation and the preceding inverse identities,

$$
(C_nL_n)(C_nR_n)=C_n^2L_nR_n=I_n,
$$

and the reverse composition is also $I_n$. $\square$

The next proposition identifies the local truth tables with global operators.

**Proposition 3.4 (Six rule formulas).** On every nonempty cycle and for every configuration $x$, the following identities hold:

$$
\begin{aligned}
F_{15,n}(x)&=C_nL_nx,\\
F_{51,n}(x)&=C_nx,\\
F_{85,n}(x)&=C_nR_nx,\\
F_{170,n}(x)&=R_nx,\\
F_{204,n}(x)&=x,\\
F_{240,n}(x)&=L_nx.
\end{aligned}
$$

**Proof sketch.** Evaluate the binary digit formula for each rule on the eight triples $(l,c,r)$. Rule $240$ returns $l$, rule $204$ returns $c$, and rule $170$ returns $r$. Their bitwise complements are rules $15$, $51$, and $85$, respectively. Applying these identities simultaneously at every site yields the displayed global formulas. $\square$

**Theorem 3.5 (Universal reversibility of the six rules).** Each rule in

$$
\{15,51,85,170,204,240\}
$$

is reversible on every cycle of positive length.

**Proof sketch.** Proposition 3.4 reduces the six global maps to $C_nL_n$, $C_n$, $C_nR_n$, $R_n$, $I_n$, and $L_n$. Lemmas 3.1–3.3 give explicit inverses for each. Therefore every map is bijective for arbitrary $n\ge1$. $\square$

The inverse pairing is worth recording:

$$
F_{15,n}^{-1}=F_{85,n},\quad
F_{85,n}^{-1}=F_{15,n},\quad
F_{170,n}^{-1}=F_{240,n},\quad
F_{240,n}^{-1}=F_{170,n},
$$

while rules $51$ and $204$ are self-inverse.

## 4. Finite classification by short cycles

### 4.1 The enumeration criterion

For a fixed pair $(w,n)$, enumerate all $2^n$ configurations, compute their images, and count distinct outputs. The map is bijective if and only if the number of distinct outputs is $2^n$.

The complete test for lengths $1$ through $4$ examines

$$
256\sum_{n=1}^4 2^n=256(2+4+8+16)=7680
$$

configuration updates. Each update computes $n$ cells, so the bit-operation count is bounded by

$$
256\sum_{n=1}^4 n2^n=256(2+8+24+64)=25088,
$$

apart from constant-time set operations under the usual hashing model. This is tiny enough for transparent exhaustive evaluation.

**Theorem 4.1 (Four-cycle finite criterion).** An elementary rule is bijective on each of the cycles of lengths $1$, $2$, $3$, and $4$ if and only if its Wolfram number belongs to

$$
\{15,51,85,170,204,240\}.
$$

**Proof sketch.** Evaluate all $256$ truth tables. For each rule and each $n\in\{1,2,3,4\}$, generate the complete finite set $\{0,1\}^n$, apply the cyclic global update, and compare the image cardinality with $2^n$. Exhausting the finite rule range leaves exactly the stated six numbers. The reverse implication can also be seen directly from Theorem 3.5. $\square$

This result is stronger than merely reporting six successful examples: it proves that every other truth table fails at least one of four explicit finite tests.

### 4.2 Short witnesses

**Corollary 4.2 (Short-period obstruction).** If $w$ is not one of $15,51,85,170,204,240$, then there exists $n\in\{1,2,3,4\}$ such that $F_{w,n}$ is not bijective.

**Proof sketch.** If all four global maps were bijective, Theorem 4.1 would place $w$ in the six-rule set, contradicting the hypothesis. Therefore at least one test fails. $\square$

Since $F_{w,n}$ is an endomap of a finite set, the failure can always be represented by either of two equivalent certificates: two distinct configurations with one shared image, or an output configuration absent from the image.

### 4.3 Main classification

**Theorem 4.3 (Classification of universally finite-cycle reversible elementary rules).** An elementary binary cellular automaton is reversible on every nonempty finite cycle if and only if its Wolfram number is one of

$$
15,\ 51,\ 85,\ 170,\ 204,\ 240.
$$

**Proof sketch.** If a rule is universally reversible, it is bijective in particular on cycles of lengths $1$, $2$, $3$, and $4$. Theorem 4.1 therefore places it in the six-rule list. Conversely, Theorem 3.5 proves every rule in that list reversible for every positive cycle length. $\square$

This proof cleanly separates necessity from sufficiency. Necessity has a bounded finite witness; sufficiency has a uniform inverse valid for all $n$.

## 5. Algorithms

### 5.1 Global update

Given a rule number $w$ and a configuration $x$ of length $n$, compute each output bit by extracting bit $4x_{i-1}+2x_i+x_{i+1}$ of $w$. This requires $O(n)$ time and $O(n)$ output space.

**Algorithm 1: Cyclic elementary update**

1. Read $w$ and $x=(x_0,\ldots,x_{n-1})$.
2. For each $i=0,\ldots,n-1$, set $l=x_{(i-1)\bmod n}$, $c=x_i$, and $r=x_{(i+1)\bmod n}$.
3. Set $k=4l+2c+r$.
4. Set the new bit to $(w\operatorname{div}2^k)\bmod2$.
5. Return the resulting length-$n$ configuration.

### 5.2 Bijectivity test on one cycle

Enumerate all $2^n$ configurations and insert each image into a set. A repeated image proves non-injectivity immediately. If no repetition occurs, all $2^n$ images are distinct, and the endomap is bijective.

The running time is $O(n2^n)$; storage is $O(n2^n)$ bits if full image words are retained. Early collision detection can reduce practical time but does not change the worst-case bound.

### 5.3 Classification scan

For each $w$ from $0$ through $255$, apply the one-cycle test for $n=1,2,3,4$. Reject on the first failure. The survivors are the six classified rules. More generally, scanning $R$ candidate rules through maximum cycle length $m$ takes

$$
O\!\left(R\sum_{n=1}^m n2^n\right)=O(Rm2^m)
$$

time and $O(m2^m)$ working space if cycle lengths are processed sequentially.

### 5.4 Collision extraction

To produce a human-readable obstruction, maintain a dictionary from each output to its first known preimage. When a later, distinct input has the same output, return the two inputs and their shared image. For every excluded elementary rule, Corollary 4.2 guarantees success for some $n\le4$.

## 6. The correct group-theoretic setting

Reversibility naturally produces groups, but only after the configuration space and class of global maps are specified correctly. For a fixed $n$, all bijections of $\{0,1\}^n$ form the symmetric group on $2^n$ points. Reversible cellular global maps form a subgroup because they are closed under composition and inversion and include the identity.

The six elementary reversible actions on an $n$-cycle lie in the subgroup generated by $R_n$ and $C_n$. These generators satisfy

$$
R_n^n=I_n,\qquad C_n^2=I_n,\qquad R_nC_n=C_nR_n.
$$

Every composite is therefore $R_n^kC_n^e$ for $k\in\mathbb Z/n\mathbb Z$ and $e\in\mathbb Z/2\mathbb Z$. For $n>1$, the action is faithful: a nonzero shift moves some configuration, and complement changes the all-zero configuration. Hence the generated group is isomorphic to

$$
\mathbb Z/n\mathbb Z\times\mathbb Z/2\mathbb Z.
$$

For $n=1$, $R_1=I_1$, so only identity and complement remain. This degeneracy illustrates why the acting configuration space matters.

The six elementary rule numbers are not themselves closed under arbitrary composition as radius-one local descriptions. Although their particular shift-complement composites remain simple, fixed-radius classes in general do not form groups. If $F$ has radius $r$ and $G$ has radius $s$, then the value of $F\circ G$ at a site may depend on inputs as far as $r+s$ sites away. The natural large-scale object is thus the group of all reversible finite-radius, shift-equivariant global maps, filtered by upper bounds on radius.

## 7. Applications and interpretation

### 7.1 Information conservation

A bijective evolution never merges two histories. Given a present configuration, there is exactly one immediate past. Non-injective automata irreversibly discard distinctions; non-surjective automata forbid some states from occurring as successors. On a finite state space these are two faces of the same defect.

The classification shows that binary radius-one synchronous rules can conserve all information on every finite ring only through rigid transport and complementation. None of the six combines neighboring bits through a genuinely mixing Boolean operation. Rules that exhibit visually complex structures may still lose information, and the loss is witnessed on a very short periodic configuration.

### 7.2 Reversible computing

Reversible computation seeks transformations with unique inputs and outputs. Such transformations avoid logical erasure and are foundational in low-energy and quantum models of computation. Cellular automata offer a distributed model in which local gates are applied everywhere at once. The theorem identifies the severe limitations of the smallest binary nearest-neighbor architecture: universal finite-cycle reversibility permits shifts, bit flips, and identity, but no richer interaction.

This negative boundary is constructive. It indicates that nontrivial reversible computation requires additional resources: larger alphabets, larger neighborhoods, partitioned update schedules, auxiliary tracks, or higher dimensions.

### 7.3 Periodic tests and infinite configurations

A configuration on the bi-infinite line is a function $x:\mathbb Z\to\{0,1\}$. Every finite cyclic word determines a periodic bi-infinite configuration by repetition. Therefore a collision on an $n$-cycle induces a collision between two periodic bi-infinite configurations under the same local rule. The short-period obstruction consequently supplies periodic witnesses against injectivity on the full shift for every excluded rule.

For the six surviving rules, the shift and complement formulas extend immediately to $\mathbb Z$, with the same explicit inverses. This strongly aligns the finite-cycle classification with the corresponding bi-infinite classification. A complete treatment should state the transfer maps and all assumptions explicitly, separating finite-cycle bijectivity from full-shift bijectivity rather than conflating them.

## 8. Discussion

The central conceptual correction is simple: local rules are not permutations of neighborhoods. Reversibility is a property of induced global maps. Neighborhood overlap can cause two globally distinct configurations to produce the same output even when a local truth table looks balanced. Conversely, an explicit global inverse must respect the spatial organization of the entire configuration.

The bounded obstruction at length four is especially useful. It turns a universal negative statement—failure to be reversible for all cycle sizes—into a tiny finite certificate. Yet the theorem should not be misread as a generic principle that testing through length four always suffices. It suffices here because the rule space itself contains only $256$ cases and the complete finite scan has been performed. For larger radii and alphabets, the needed bounds and algorithms change.

De Bruijn graphs provide the natural next computational framework. For radius $r$, vertices can encode words of length $2r$, while directed edges encode overlapping neighborhoods of length $2r+1$. A product graph tracks pairs of paths that receive identical output labels. Nontrivial cycles in the product graph can reveal distinct periodic configurations with a common image. This approach exploits overlap directly and scales better than enumerating all global configurations on increasingly long rings.

## 9. Future work

Several directions follow from the classification.

First, the bi-infinite setting should be developed explicitly. The six maps retain their inverse formulas, while every finite collision extends periodically. Second, the correct reversible group should be defined as finite-radius, shift-equivariant permutations of a fixed full shift, with finite-cycle actions as related representations. Third, the radius filtration deserves systematic study: composition obeys an upper bound of $r+s$, and inverse radii may encode meaningful complexity.

Fourth, the shift-complement group on each finite cycle can be given a complete presentation, including the one-site degeneracy. Fifth, the obstruction theorem can be refined into a table giving each excluded rule’s least failing cycle length and an explicit collision or missing image. Sixth, larger alphabets and radii call for the de Bruijn product-graph criterion rather than raw global enumeration. Finally, finite-cycle reversibility, periodic-point injectivity, and full-shift bijectivity should be kept logically distinct, with conversion theorems stating compactness and finite-alphabet hypotheses.

## 10. Conclusion

Universal finite-cycle reversibility among elementary binary cellular automata is completely rigid. Exactly six rules qualify:

$$
15,\ 51,\ 85,\ 170,\ 204,\ 240.
$$

They are precisely left shift, right shift, identity, complement, and the two complemented shifts. Their invertibility follows from elementary cyclic-index identities and the involutive nature of complement. Every other elementary rule fails on a cycle of length at most four.

The classification demonstrates an effective methodology for finite local dynamical systems: define the global property correctly, exhaust the genuinely finite parameter space, convert survivors into structural formulas, and prove those formulas uniformly. It also locates the appropriate algebraic object. The meaningful permutations act on configurations, not neighborhoods, and reversible finite-radius global maps—not fixed-radius truth tables—form the natural group of reversible cellular dynamics.

## Appendix A. Worked examples

The structural formulas can be inspected on a concrete ring. Take the five-cell configuration

$$
x=(1,0,1,1,0).
$$

With the convention $(L_5x)_i=x_{i-1}$ and $(R_5x)_i=x_{i+1}$, wraparound gives

$$
L_5x=(0,1,0,1,1),\qquad R_5x=(0,1,1,0,1).
$$

Complementing each bit gives

$$
C_5x=(0,1,0,0,1).
$$

The remaining reversible actions are

$$
C_5L_5x=(1,0,1,0,0),\qquad C_5R_5x=(1,0,0,1,0).
$$

Thus the six rules send this one input to the six outputs prescribed by their shift-complement formulas. Applying rule $170$ and then rule $240$ returns $x$, as does applying rule $240$ and then rule $170$. Applying rule $51$ twice also returns $x$. The complemented shifts undo one another.

For a contrasting example, rule $30$ already fails on the one-cell cycle. On that cycle the left neighbor, center, and right neighbor are the same bit. The all-zero state has neighborhood $(0,0,0)$ and maps to $0$. The all-one state has neighborhood $(1,1,1)$ and also maps to $0$ under rule $30$. Hence the two distinct configurations $(0)$ and $(1)$ have the common image $(0)$. This is an explicit collision and proves non-reversibility without examining any larger ring.

The one-cell example also illustrates why repeated coordinates in short cycles must be handled with cyclic indexing rather than imagined as three independent cells. At $n=1$, all three entries of a neighborhood coincide. At $n=2$, the left and right neighbors of each site coincide with each other. These degeneracies are not artifacts; universal finite-cycle reversibility explicitly requires the rule to remain bijective in their presence. They help make short cycles powerful filters.

## Appendix B. Reproducibility of the finite enumeration

The finite criterion can be independently reproduced from the definitions alone. Represent a configuration by an integer $q$ between $0$ and $2^n-1$, whose $i$th binary digit is $x_i$. For each site, extract the three cyclic bits, form the neighborhood index $k=4l+2c+r$, extract bit $k$ of $w$, and place it into bit $i$ of the output integer. A Boolean array of length $2^n$ records which outputs have appeared. If an output repeats, reject the rule at that length; otherwise accept after all inputs are processed.

No random sampling is involved. The outer rule loop covers exactly the integers $0$ through $255$; the length loop covers exactly $1$ through $4$; and the configuration loop covers exactly $0$ through $2^n-1$. Therefore the computation is an exhaustive decision procedure for the finite statement in Theorem 4.1. Its output becomes the necessity half of the universal classification only when paired with the arbitrary-length inverse argument of Section 3.
