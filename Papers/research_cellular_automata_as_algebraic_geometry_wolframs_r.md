# Cellular Automata as Algebraic Geometry: Boolean Polynomial Models and the Limits of Fixed-Point Complexity

## Abstract

Elementary cellular automata are synchronous dynamical systems on binary arrays whose local update depends on three adjacent cells. This paper develops a self-contained algebraic description of these systems and evaluates the proposal that the size or dimension of a fixed-point variety measures dynamical complexity. There are exactly $256$ elementary local rules, and every such rule has a unique algebraic normal form over $\mathbb F_2$ of degree at most $3$. For arbitrary finite neighbor maps, the global update is consequently a polynomial self-map of the Boolean state space. Its stable configurations are the $\mathbb F_2$-rational solutions of the update equations together with the Boolean relations. Three exact results show that fixed-point abundance does not track computational richness: Rule $0$ has exactly one fixed state; Rule $204$ fixes all $2^n$ states; and Rule $110$ has a nonempty but nonmaximal fixed-point set on every nonempty finite array. More strongly, if the right-neighbor map has a single forward orbit, Rule $110$ has exactly one fixed configuration, the all-zero state. The proof rests on a zero-propagation lemma. These facts separate fixed-point count, Krull dimension, and dynamical complexity. We give algorithms for rule decoding, algebraic-normal-form conversion, fixed-point enumeration, and numerical comparison, and identify periodic-orbit equations and explicitly constructed local-to-global structures as more appropriate future invariants.

## 1. Introduction

An elementary cellular automaton (ECA) evolves a one-dimensional binary array in discrete time. At each step, every site simultaneously consults its left neighbor, its current value, and its right neighbor. A fixed truth table determines the next value. Despite this small local input, the resulting global dynamics include extinction, periodic textures, apparent randomness, coherent moving structures, and universal computation.

The finite truth table invites an algebraic translation. If $0$ and $1$ are regarded as elements of the field $\mathbb F_2$, exclusive-or becomes addition and conjunction becomes multiplication. Every ternary Boolean function is then represented by a multilinear polynomial of degree at most $3$. A finite ECA is therefore a polynomial dynamical system on $\mathbb F_2^n$.

This observation motivates a geometric question. Fixed configurations solve $F(s)=s$, so they can be regarded as rational points of an algebraically defined locus. Could the dimension of this locus measure the complexity of a rule? A particularly strong version would predict a small fixed-point locus for simple rules and a maximal one for a computationally universal rule such as Rule $110$.

The exact results below refute that prediction while preserving the valuable algebraic framework. Rule $204$, the center-copying rule, has no evolution at all and nevertheless fixes the entire state space. Rule $110$ can have a unique fixed state under standard cyclic connectivity. The central conceptual conclusion is that fixed points describe equilibrium, whereas computational universality concerns unbounded spacetime evolution. Point count, geometric dimension, and dynamical complexity must therefore be kept distinct.

## 2. Finite elementary cellular automata

### 2.1. States, local rules, and boundary data

Fix an integer $n\ge 0$. Let

$$
I_n=\{0,1,\ldots,n-1\}
$$

be the set of sites, and let

$$
X_n=\{0,1\}^{I_n}
$$

be the set of binary configurations. A state $s\in X_n$ assigns a bit $s_i$ to each site $i$. Since each of the $n$ coordinates has two choices,

$$
|X_n|=2^n.
$$

A local elementary rule is a function

$$
f:\{0,1\}^3\to\{0,1\}.
$$

To allow a general finite boundary convention, choose maps

$$
L,R:I_n\to I_n,
$$

where $L(i)$ and $R(i)$ designate the left and right inputs used at site $i$. The synchronous global update $F_f:X_n\to X_n$ is

$$
(F_f(s))_i=f(s_{L(i)},s_i,s_{R(i)}).
$$

For a cyclic array with $n>0$, the standard choice is $L(i)=i-1\pmod n$ and $R(i)=i+1\pmod n$. The abstract formulation also covers self-loops, reflecting boundaries encoded inside a finite site set, and directed network couplings.

A state $s$ is **fixed** if $F_f(s)=s$. Denote the fixed-point set by

$$
\operatorname{Fix}(F_f)=\{s\in X_n:F_f(s)=s\}.
$$

### 2.2. Counting elementary rules

**Theorem 2.1 (Enumeration of elementary rules).** There are exactly $256$ elementary local rules.

**Proof sketch.** The domain $\{0,1\}^3$ contains $2^3=8$ neighborhoods. A rule independently assigns either $0$ or $1$ to each neighborhood. Hence the number of functions is $2^8=256$. $\square$

The Wolfram rule number records these eight outputs as bits. We use increasing neighborhood order

$$
000,001,010,011,100,101,110,111.
$$

If the corresponding outputs are $b_0,\ldots,b_7$, then the rule number is $\sum_{j=0}^7 b_j2^j$.

## 3. Algebraic normal form over $\mathbb F_2$

### 3.1. Boolean arithmetic

Identify $\{0,1\}$ with $\mathbb F_2$. In this field,

$$
1+1=0,
$$

so addition is exclusive-or. Multiplication agrees with conjunction on Boolean values. Every Boolean input satisfies $x^2=x$.

For coefficients $a_0,\ldots,a_7\in\mathbb F_2$, define the ternary multilinear polynomial

$$
P(l,c,r)=a_0+a_1l+a_2c+a_3lc+a_4r+a_5lr+a_6cr+a_7lcr.
$$

### 3.2. Representation theorem

**Theorem 3.1 (Algebraic Normal Form).** For every local rule $f:\mathbb F_2^3\to\mathbb F_2$, there exists a unique coefficient vector $(a_0,\ldots,a_7)\in\mathbb F_2^8$ such that

$$
f(l,c,r)=a_0+a_1l+a_2c+a_3lc+a_4r+a_5lr+a_6cr+a_7lcr
$$

for every $(l,c,r)\in\mathbb F_2^3$. In particular, every elementary rule is represented by a polynomial of degree at most $3$.

**Proof sketch.** Evaluate successively on the Boolean cube. At $(0,0,0)$ one obtains $a_0=f(0,0,0)$. At $(1,0,0)$ one obtains $a_1=f(1,0,0)+a_0$; similarly one recovers $a_2$ and $a_4$. Evaluations at points with two nonzero coordinates recover $a_3,a_5,a_6$, and evaluation at $(1,1,1)$ recovers $a_7$. This triangular procedure proves existence. If two such polynomials represented the same function, applying the same recovery procedure to their difference would force every coefficient to vanish, proving uniqueness. Equivalently, the coefficients are the Möbius transform of the truth table on the Boolean lattice. $\square$

Explicitly,

$$
\begin{aligned}
a_0&=f(0,0,0),\\
a_1&=f(1,0,0)+f(0,0,0),\\
a_2&=f(0,1,0)+f(0,0,0),\\
a_3&=f(1,1,0)+f(1,0,0)+f(0,1,0)+f(0,0,0),
\end{aligned}
$$

with analogous formulas for $a_4,a_5,a_6$, while $a_7$ is the sum of all eight truth-table values.

### 3.3. Global polynomial dynamics

Replacing $f$ by its algebraic normal form yields, for every site $i$,

$$
(F_f(s))_i=P(s_{L(i)},s_i,s_{R(i)}).
$$

Thus $F_f$ is a polynomial map $\mathbb F_2^n\to\mathbb F_2^n$, with coordinate degree at most $3$. This statement concerns the update itself; iterating the map may increase unreduced symbolic degree, although reduction by the Boolean relations restores multilinearity in each state variable.

## 4. Fixed-point equations and their geometry

The fixed-state condition is the polynomial system

$$
P(s_{L(i)},s_i,s_{R(i)})-s_i=0
\qquad (i\in I_n).
$$

To ensure that algebraic solutions represent binary states, adjoin the Boolean equations

$$
s_i^2-s_i=0
\qquad (i\in I_n).
$$

Over $\mathbb F_2$, define the ideal

$$
J_f=\left\langle P(s_{L(i)},s_i,s_{R(i)})-s_i,\ s_i^2-s_i:i\in I_n\right\rangle
$$

inside $\mathbb F_2[s_0,\ldots,s_{n-1}]$. Its $\mathbb F_2$-rational zero set is exactly $\operatorname{Fix}(F_f)$.

The coordinate ring is

$$
A_f=\mathbb F_2[s_0,\ldots,s_{n-1}]/J_f.
$$

A crucial distinction follows. Because every variable is idempotent modulo the Boolean relations, $A_f$ is finite-dimensional as an $\mathbb F_2$-vector space, spanned by squarefree monomials. Therefore it is an Artinian ring and has Krull dimension $0$ whenever it is nonzero. Consequently, for fixed finite $n$, both a singleton fixed set and the full set of $2^n$ Boolean points have Krull dimension $0$ in this Boolean coordinate-ring model. Cardinality can distinguish them; Krull dimension cannot.

One could study other schemes by omitting or changing the Boolean relations, but then their points need not coincide with binary configurations. Any proposed dimension invariant must specify the coordinate ring precisely.

## 5. Three exact fixed-point theorems

### 5.1. Rule $0$

Rule $0$ is the constant local function

$$
f_0(l,c,r)=0.
$$

**Theorem 5.1 (Unique fixed state for Rule $0$).** For every finite size $n$ and every choice of neighbor maps $L,R$, Rule $0$ has exactly one fixed configuration, namely the all-zero state.

**Proof sketch.** The global update sends every configuration to the all-zero configuration. If $s$ is fixed, then $s=F_{f_0}(s)$ is all zero. Conversely, the all-zero configuration is unchanged. $\square$

### 5.2. Rule $204$

Rule $204$ copies the center input:

$$
f_{204}(l,c,r)=c.
$$

**Theorem 5.2 (Maximal fixed set for Rule $204$).** For every finite size $n$ and every choice of neighbor maps $L,R$, every binary configuration is fixed by Rule $204$. Hence

$$
|\operatorname{Fix}(F_{f_{204}})|=2^n.
$$

**Proof sketch.** At each site, $(F_{f_{204}}(s))_i=f_{204}(s_{L(i)},s_i,s_{R(i)})=s_i$. Thus $F_{f_{204}}$ is the identity map on $X_n$. $\square$

This theorem supplies a decisive counterexample to interpreting a maximal fixed-point count as high dynamical complexity: Rule $204$ performs no state change.

### 5.3. Rule $110$

In increasing neighborhood order, Rule $110$ is defined by

$$
\begin{array}{c|cccccccc}
(l,c,r)&000&001&010&011&100&101&110&111\\
\hline
f_{110}(l,c,r)&0&1&1&1&0&1&1&0.
\end{array}
$$

**Proposition 5.3 (Nonmaximality for Rule $110$).** On every nonempty finite array and for arbitrary neighbor maps, the all-zero state is fixed, the all-one state is not fixed, and therefore

$$
0<|\operatorname{Fix}(F_{f_{110}})|<2^n.
$$

**Proof sketch.** Every site of the all-zero state sees $000$, whose output is $0$. Every site of the all-one state sees $111$, whose output is $0$, so on a nonempty array the update differs from the original all-one state. The fixed-point set therefore contains at least the zero state and omits at least the one state. $\square$

A local implication gives a much sharper statement.

**Lemma 5.4 (Zero propagation).** Let $s$ be a fixed state of Rule $110$. If $s_i=0$, then $s_{R(i)}=0$.

**Proof sketch.** Since $s$ is fixed, the output at $i$ must equal the center value $s_i=0$. Inspect the four Rule $110$ neighborhoods with center bit $0$: $000$ and $100$ output $0$, whereas $001$ and $101$ output $1$. Thus output $0$ with center $0$ is possible only when the right input is $0$. Hence $s_{R(i)}=0$. $\square$

Call $R$ **forward transitive** if

$$
\forall i,j\in I_n\ \exists k\ge 0\quad R^k(i)=j.
$$

For a finite set, this means that $R$ consists of a single directed cycle. The standard right shift on a cyclic array satisfies this condition.

**Theorem 5.5 (Rule $110$ Singleton Fixed-Point Theorem).** Let $n>0$ and suppose the right-neighbor map $R$ is forward transitive. Then Rule $110$ has exactly one fixed configuration, the all-zero state.

**Proof sketch.** The all-zero state is fixed. Now let $s$ be any fixed state. It cannot be all one, because the all-one state is not fixed; hence some site $i$ has $s_i=0$. Repeated application of the zero-propagation lemma gives $s_{R^k(i)}=0$ for every $k\ge 0$. Forward transitivity says that every site $j$ equals $R^k(i)$ for some $k$, so $s_j=0$ for every $j$. Thus $s$ is all zero. $\square$

**Corollary 5.6 (Periodic boundary).** On every nonempty cyclic array with the standard nearest-neighbor shifts, Rule $110$ has exactly one fixed state.

**Proof sketch.** Repeated right shifts visit all sites of a finite cycle, so Theorem 5.5 applies. $\square$

## 6. Consequences for complexity claims

The preceding theorems invalidate a monotone relation between fixed-point abundance and Wolfram-style dynamical complexity. Rule $204$ has the maximum possible number of fixed states but trivial evolution. Rule $110$, despite its capacity for universal computation in unbounded spacetime, can have the minimum nonzero number of fixed states.

This is not paradoxical. A fixed point records only an equilibrium. Universal computation in a cellular automaton is carried by encoded initial conditions, long-lived patterns, signal propagation, collisions, and an unbounded number of time steps. An automaton may have a sparse equilibrium set and a rich transient or periodic orbit structure. Conversely, an identity map has an enormous equilibrium set because nothing evolves.

Nor can the word “dimension” repair the claim without further definitions. Three quantities are easily conflated:

1. **Fixed-point count:** the finite number $|\operatorname{Fix}(F_f)|$.
2. **Krull dimension:** the maximal length of chains of prime ideals in a specified coordinate ring.
3. **Asymptotic growth:** the behavior of fixed-point or periodic-point counts as $n\to\infty$.

These are genuinely different. With Boolean relations imposed at finite $n$, Krull dimension is $0$. Fixed-point counts vary between $0$ and $2^n$. An asymptotic rate such as

$$
h_{\mathrm{fix}}(f)=\limsup_{n\to\infty}\frac{1}{n}\log_2 |\operatorname{Fix}(F_{f,n})|
$$

may carry more information, but it still measures equilibria and must not be identified with universality without evidence.

## 7. Algorithms

### 7.1. Decoding a rule number

Given $w\in\{0,\ldots,255\}$, define

$$
b_j=\left\lfloor\frac{w}{2^j}\right\rfloor\bmod 2.
$$

The output on the neighborhood whose binary value is $j$ is $b_j$. This requires constant work for ECAs; viewed as a function of the truth-table length, it is linear.

### 7.2. Fast Möbius transform for algebraic normal form

Initialize an array $a$ with the eight truth-table values. For each variable bit $q\in\{0,1,2\}$, and each mask $m$ containing that bit, replace

$$
a_m\leftarrow a_m+a_{m\setminus\{q\}}
$$

in $\mathbb F_2$. After the transform, $a_m$ is the coefficient of the monomial indexed by $m$. For $k$ inputs, the method takes $O(k2^k)$ time and $O(2^k)$ memory; here $k=3$.

### 7.3. Exhaustive fixed-point enumeration

For each integer $x$ from $0$ to $2^n-1$, decode its bits as a configuration $s$. Compute all $n$ updated cells simultaneously from the original state. Retain $s$ exactly when every updated cell equals the corresponding original cell. The running time is $O(n2^n)$ and storage is $O(n)$ if fixed states are counted rather than retained.

For special rules, structural theorems replace enumeration. Rule $0$ and Rule $204$ have closed formulas. Under a forward-transitive right map, Rule $110$ also has the closed answer $1$.

### 7.4. Fixed-point polynomial construction

For symbolic analysis, create variables $s_0,\ldots,s_{n-1}$ over $\mathbb F_2$, insert the local algebraic normal form into every coordinate, and append both the fixed equations $F_f(s)_i+s_i=0$ and Boolean equations $s_i^2+s_i=0$. Gröbner-basis methods or Boolean satisfiability solvers may then compute solution structure. Complexity is exponential in the worst case, as expected for general finite Boolean systems.

## 8. Numerical illustrations

Consider cyclic arrays. The exact fixed-point counts for the three rules are

$$
\begin{array}{c|ccc}
n&\text{Rule }0&\text{Rule }110&\text{Rule }204\\
\hline
1&1&1&2\\
2&1&1&4\\
3&1&1&8\\
4&1&1&16\\
8&1&1&256\\
12&1&1&4096.
\end{array}
$$

No empirical extrapolation is needed for these entries: the formulas follow from Theorems 5.1, 5.2, and Corollary 5.6. Enumeration is nevertheless useful as a transparent demonstration and as a testing method for arbitrary rules and boundary maps.

The algebraic-normal-form transform supplies a second numerical experiment. Starting from any of the $256$ truth tables, transforming to coefficients and evaluating the resulting polynomial on all eight inputs reproduces the original table. This gives an exact computational realization of Theorem 3.1.

## 9. Applications and broader interpretation

Polynomial encodings make cellular automata accessible to several mature toolkits. Boolean equation solving can classify stable motifs. Elimination can remove hidden cells and derive constraints on observed regions. Transfer matrices can count configurations satisfying local equations on long chains. Algebraic normal forms expose additive and nonlinear components of a rule, and periodic-point equations

$$
F_f^p(s)=s
$$

extend the analysis beyond equilibrium.

The framework also applies beyond nearest-neighbor lines. Arbitrary maps $L$ and $R$ define updates on directed finite networks. The zero-propagation argument for Rule $110$ then becomes a graph-theoretic statement: zeros spread along directed right edges, and a single forward orbit forces global extinction in equilibrium. More generally, implications extracted from a truth table can constrain fixed states through reachability.

A sheaf-theoretic treatment could organize compatible local patterns, but it requires explicit data: a site or topology, objects assigned to regions, restriction maps, and a theorem identifying global sections with the intended configurations. Merely calling local data a sheaf does not determine an invariant, and richness of global sections must be defined before it can be compared with computation.

## 10. Discussion

The algebraic description succeeds exactly where it is precise. There are $256$ ternary Boolean rules. Each has a unique cubic-or-lower multilinear polynomial. Every finite global update is a polynomial map. Fixed points are solutions to explicit equations. Local truth-table implications can yield global classification theorems.

The proposed complexity interpretation fails for equally precise reasons. Rule $204$ shows that a maximal fixed set may signal total dynamical inactivity. Rule $110$ shows that computational richness need not produce many equilibria. Boolean coordinate rings show that finite point count is not Krull dimension.

The correction suggests a broader principle: invariants should match the phenomenon being studied. Equilibrium invariants are appropriate for memory states and attractor analysis. Universality is temporal and may require orbit growth, simulation embeddings, spacetime languages, or families indexed by both size and time. Algebraic geometry can still contribute, but the relevant geometric object may need to encode trajectories rather than merely stationary points.

## 11. Future work

Several concrete developments follow naturally.

First, periodic left and right shifts should be treated explicitly, making the cyclic Rule $110$ singleton result a direct concrete instance of the forward-orbit theorem. Second, the global update should be represented in a multivariate polynomial ring over $\mathbb F_2$, with an exact comparison between polynomial evaluation and synchronous evolution. Third, the coordinate ring formed from update equations and Boolean relations should be studied separately from its rational-point count.

Fourth, all $256$ rules can be generated from their numeric codes, and the decoding map can be shown to be a bijection. Fifth, fixed-point counts can be computed over declared size ranges and boundary conventions, then compared with a precisely specified complexity classification. Any statistical correlation must state its data and statistic.

Sixth, periodic orbits of length greater than one deserve priority. For $p\ge 2$, equations $F_f^p(s)=s$ capture both shorter divisors of $p$ and exact-$p$ cycles after exclusion; their growth may better reflect dynamical richness. Finally, any local-to-global or sheaf construction should state its topology, restriction maps, and intended classification theorem explicitly.

## 12. Conclusion

Elementary cellular automata admit a clean algebraic geometry of Boolean polynomial equations. Every local rule is a degree-at-most-three polynomial over $\mathbb F_2$, and stable finite configurations are rational solutions of a canonical fixed-point system once boundary data are specified. Exact examples, however, overturn the claim that fixed-point abundance measures computational complexity. Rule $0$ has one fixed state, Rule $204$ has all $2^n$, and Rule $110$ has exactly one under a single-forward-orbit right shift. The resulting lesson is constructive: retain the polynomial bridge, distinguish point count from dimension, and design temporal invariants for temporal complexity.
## Appendix A. A direct coefficient-recovery argument

For completeness, the algebraic-normal-form construction can be read without invoking Möbius inversion. Order the monomials as $1,l,c,lc,r,lr,cr,lcr$. Evaluation at $000$ isolates the constant coefficient. Evaluation at $100$, after subtracting the known constant, isolates the coefficient of $l$; evaluations at $010$ and $001$ similarly isolate the coefficients of $c$ and $r$. At $110$, all terms involving $r$ vanish, so subtracting the already known constant, $l$, and $c$ contributions isolates the coefficient of $lc$. The points $101$ and $011$ recover the coefficients of $lr$ and $cr$. Finally, evaluation at $111$ contains every monomial, and subtracting the seven known contributions isolates the coefficient of $lcr$. Because subtraction equals addition over $\mathbb F_2$, each step is an exclusive-or of selected truth-table entries. This proves both existence and uniqueness and gives an executable algorithm.

## Appendix B. Boundary conventions and the orbit hypothesis

The fixed-point statements for Rules $0$ and $204$ are independent of boundary data because their outputs ignore, respectively, all inputs or both neighboring inputs. Rule $110$ is more sensitive. Proposition 5.3 remains independent of the boundary convention: constant states present the same neighborhood at every site. The singleton theorem requires only forward transitivity of the right map and makes no assumption about the left map. This asymmetry comes directly from the Rule $110$ truth table and the direction of zero propagation.

On a standard cyclic array, $R(i)=i+1\pmod n$, and for any $i,j$ one may take $k$ congruent to $j-i$ modulo $n$. If $R$ instead has several directed cycles, a zero propagates around its own cycle but need not reach the others. If a finite functional graph has trees feeding cycles, forward transitivity from every starting site fails. The theorem therefore identifies exactly the graph property used by the proof rather than hiding it inside the phrase “periodic boundary.” This formulation allows the same argument to apply to any relabeling of a single cycle.
