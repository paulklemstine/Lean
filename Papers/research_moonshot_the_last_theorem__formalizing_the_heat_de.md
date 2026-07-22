# The Last Theorem: Countable Provability, Finite Computation, and Holographic Storage

**Aristotle**  
**July 22, 2026**

## Abstract

A formal statement over a fixed finite alphabet is a finite string, and the provable statements of a deductive system form a subset of the set of such strings. This paper studies the collision between the resulting countable infinity and finite physical resources. For every productive deductive system—one with infinitely many distinct theorems—the theorem set is countably infinite and therefore admits a bijection with the natural numbers. Removing any finite set of discovered theorems leaves infinitely many undiscovered. For a budget of $N$ theorems, the maximal coverage of the first $n$ entries of an enumeration is $f_N(n)=\min(N,n)/n$; this quantity is nonnegative, bounded above by $N/n$, and converges to $0$. We then analyze an idealized holographic memory. In Planck units, a Schwarzschild radius $r=aM$, horizon area $A=4\pi r^2$, and entropy $S=A/4$ imply $S(a,M)=\pi a^2M^2$. Thus capacity scales quadratically with mass, is strictly increasing for nonnegative mass when $a>0$, and eventually dominates every nonnegative linear capacity. Nevertheless, every fixed finite mass yields a finite theorem budget, so its discoverable fraction also converges to $0$. The analysis separates mathematical conclusions from physical assumptions, clarifies enumeration dependence, and identifies effective proof search, complexity-sensitive density, dimensional analysis, and black-hole tradeoffs as natural extensions.

## 1. Introduction

Mathematical knowledge is expressed through finite inscriptions: formulas, derivations, programs, and books. The supply of potential inscriptions is infinite, but any individual inscription is finite. This simple combinatorial fact permits all statements in a fixed formal language to be arranged in a sequence. If the provable statements are infinite in number, they form a countably infinite library.

Physical discovery has a different character. A computer performing finitely many operations can emit only finitely many distinct outputs. A civilization confined to a finite operation budget therefore occupies a finite region of an infinite mathematical library. The contrast remains even when the budget is enormous. Figures such as $10^{120}$ operations may motivate the discussion, but no particular cosmological estimate is required below: finiteness alone drives the central result.

The analysis has three layers. First, finite syntax supplies countability. Second, a finite discovery set leaves an infinite complement and has vanishing coverage in a specified enumeration. Third, black-hole thermodynamics supplies a candidate improvement in absolute capacity: because event-horizon entropy is proportional to area and Schwarzschild radius is proportional to mass, storage scales as the square of mass. Quadratic growth outperforms linear growth, but a finite quadratic quantity is still finite. Holographic storage therefore changes scale without changing asymptotic density.

The claims are intentionally conditional. We assume a productive deductive system rather than developing the syntax and derivability relation of ZFC. We model a physical cap as a finite theorem budget rather than deriving a numerical cap from cosmology. We use the Bekenstein–Hawking relation in Planck units and do not identify entropy with accessible memory without qualification. These choices isolate a rigorous mathematical core while making clear where richer models must add assumptions.

## 2. Finite languages and productive deductive systems

### 2.1 Alphabets and statements

Fix a natural number $b$. An **alphabet of size $b$** is a set

$$
\Sigma_b=\{0,1,\ldots,b-1\}.
$$

A **statement** over $\Sigma_b$ is a finite string of alphabet symbols. The set of all statements is

$$
\Sigma_b^*=\bigcup_{\ell=0}^{\infty}\Sigma_b^\ell,
$$

where $\Sigma_b^\ell$ denotes strings of length $\ell$. The empty string is the unique member of $\Sigma_b^0$.

A **deductive system** $D$ over $\Sigma_b$ is represented here by a set $T_D\subseteq\Sigma_b^*$, whose elements are called its theorems. The system is **productive** if $T_D$ is infinite. This abstraction retains precisely the property needed for the counting results. In a concrete treatment, $T_D$ would consist of well-formed formulas that possess finite derivations from specified axioms and inference rules.

The productivity assumption should not be confused with consistency. Many familiar consistent theories extending elementary arithmetic are productive, but productivity merely asserts infinitely many distinct provable strings. The arguments in this paper use productivity directly.

### 2.2 Countability of finite strings

**Lemma 1 (Countability of the ambient language).** For every finite alphabet $\Sigma_b$, the set $\Sigma_b^*$ of finite strings is countable.

**Proof sketch.** For each length $\ell$, there are $b^\ell$ strings, hence finitely many. Order strings first by length and then lexicographically within each length. This gives an enumeration of all strings. Equivalently, $\Sigma_b^*$ is a countable union of finite sets, so it is countable. When $b=0$, only the empty string exists; the conclusion still holds, although no productive subsystem is possible. $\square$

**Theorem 1 (Countable Theorem Library).** If $D$ is a productive deductive system over a finite alphabet, then $T_D$ is countably infinite. In particular, there exists a bijection

$$
e_D:T_D\longrightarrow\mathbb N.
$$

**Proof sketch.** By Lemma 1, $\Sigma_b^*$ is countable. Every subset of a countable set is countable, so $T_D$ is countable. Productivity states that $T_D$ is infinite. Every infinite countable set is in bijection with $\mathbb N$, which gives $e_D$. $\square$

The inverse of $e_D$ is an abstract enumeration $t_0,t_1,t_2,\ldots$ of the theorems without repetition. The theorem establishes an ordering, not a finite completion procedure. Every fixed theorem has a finite index, but no finite index contains all entries.

For a computably axiomatized theory, one often seeks more: an effective enumerator obtained by dovetailing through candidate derivations. Bare countability does not itself supply efficiency, proof-length bounds, or a practical search strategy. This distinction will matter in Section 7.

## 3. Finite discovery and an infinite remainder

Let $F\subseteq\Sigma_b^*$ denote the set of theorems discovered, stored, or emitted during some physical history. If the history permits only finitely many relevant operations and each operation produces at most finitely many outputs, then $F$ is finite. The mathematical conclusions require only this finiteness, not a detailed cosmological mechanism.

**Theorem 2 (Inexhaustibility under finite discovery).** Let $D$ be productive and let $F$ be any finite set of statements. Then

$$
T_D\setminus F
$$

is infinite.

**Proof sketch.** Suppose $T_D\setminus F$ were finite. The set $T_D\cap F$ is a subset of the finite set $F$, so it is finite. Since

$$
T_D=(T_D\cap F)\cup(T_D\setminus F),
$$

$T_D$ would be a union of two finite sets and therefore finite, contradicting productivity. $\square$

The theorem permits $F$ to contain non-theorems; such entries simply have no effect on $T_D\setminus F$. It follows a fortiori when $F\subseteq T_D$. The statement is qualitative but strong: a finite discovery process misses not merely one theorem but infinitely many.

This result is independent of theorem ordering. Density, by contrast, requires an ordering or another size notion.

## 4. A finite-budget coverage observable

Fix an enumeration $t_0,t_1,t_2,\ldots$ of $T_D$. Suppose a resource budget permits possession of no more than $N$ distinct theorems. Among an initial segment of $n$ theorems, at most $\min(N,n)$ can be covered. Define the **finite-budget discoverable fraction** by

$$
f_N(n)=\frac{\min(N,n)}{n}
$$

for positive $n$. For convenience one may set $f_N(0)=0$; this isolated convention does not affect the limiting result.

The observable is an upper-envelope model rather than a simulation of proof search. It grants the search process ideal placement: all $N$ outputs may be chosen from the initial segment under examination. Actual search can only perform worse if it emits duplicates, non-theorems, or theorems outside that segment.

**Lemma 2 (Nonnegativity).** For all natural numbers $N$ and $n$,

$$
f_N(n)\ge0.
$$

**Proof sketch.** Both $\min(N,n)$ and $n$ are nonnegative. For positive $n$, division preserves nonnegativity; at $n=0$ the chosen value is $0$. $\square$

**Lemma 3 (Reciprocal upper bound).** For all natural numbers $N$ and positive $n$,

$$
f_N(n)\le\frac{N}{n}.
$$

**Proof sketch.** The elementary inequality $\min(N,n)\le N$ can be divided by the positive number $n$. $\square$

**Theorem 3 (Vanishing Discovery Fraction).** For every fixed finite budget $N$,

$$
\lim_{n\to\infty}f_N(n)=0.
$$

**Proof sketch.** Lemmas 2 and 3 give

$$
0\le f_N(n)\le\frac{N}{n}.
$$

For fixed $N$, the upper bound $N/n$ converges to $0$. The squeeze theorem therefore yields the result. Equivalently, once $n>N$, the fraction is exactly $N/n$, whose limit is immediate. $\square$

Theorem 3 provides the precise zero-fraction result in this model. It is not a statement that a finite set has zero cardinality; a finite archive may contain an immense number of important theorems. It is an asymptotic comparison between a bounded numerator and unbounded initial-segment size.

### 4.1 Dependence on enumeration

Natural density on a countable set is not generally invariant under bijections. Rearranging the terms can change the density of a chosen infinite subset. The present theorem avoids an overclaim: the archive budget $N$ is fixed, so the maximum number of covered entries in *any* initial segment is uniformly bounded by $N$. Consequently the ratio tends to zero for every enumeration.

A more realistic question allows the number of discoveries to grow with time or with the prefix length. If a budget becomes $N(n)$, then the upper envelope is $\min(N(n),n)/n$. It tends to zero whenever $N(n)=o(n)$, may approach a positive constant when $N(n)$ grows linearly, and may equal $1$ if the budget keeps pace with $n$. Thus the fixed-budget theorem is a special case of a broader growth-rate comparison.

## 5. Holographic storage and quadratic mass scaling

A possible response to finite storage is to seek a medium with a better scaling law. Black-hole thermodynamics motivates an area-based information capacity. The following model is deliberately algebraic.

Let $M\in\mathbb R$ denote mass and let $a\in\mathbb R$ be the proportionality coefficient between mass and Schwarzschild radius. Define

$$
r(a,M)=aM.
$$

For a spherical horizon of radius $r$, define its area by

$$
A(r)=4\pi r^2.
$$

In Planck units, define the **Bekenstein–Hawking entropy** by

$$
S(a,M)=\frac{A(r(a,M))}{4}.
$$

The word “storage” is used here in the scaling sense: entropy bounds the number of distinguishable states. A conversion to bits and an account of accessible encoding require additional physical constants and operational assumptions.

**Theorem 4 (Horizon Area-to-Mass Law).** For all real $a$ and $M$,

$$
S(a,M)=\pi a^2M^2.
$$

**Proof sketch.** Substitute $r=aM$ into $A=4\pi r^2$, then divide by $4$:

$$
S(a,M)=\frac{4\pi(aM)^2}{4}=\pi a^2M^2.
$$

The last equality follows from $(aM)^2=a^2M^2$. $\square$

**Corollary 4.1 (General quadratic scaling).** For all real scale factors $c$,

$$
S(a,cM)=c^2S(a,M).
$$

**Proof sketch.** By Theorem 4,

$$
S(a,cM)=\pi a^2(cM)^2=c^2\pi a^2M^2=c^2S(a,M).
$$

$\square$

**Corollary 4.2 (Doubling law).** Doubling the mass quadruples entropy:

$$
S(a,2M)=4S(a,M).
$$

This is Corollary 4.1 with $c=2$.

**Corollary 4.3 (Mass-three example).** A mass-$3$ hole has nine times the entropy of a mass-$1$ hole with the same coefficient:

$$
S(a,3)=9S(a,1).
$$

### 5.1 Monotonicity

**Theorem 5 (Strict growth with nonnegative mass).** If $a>0$, then $M\mapsto S(a,M)$ is strictly increasing on $[0,\infty)$. Explicitly, if

$$
0\le M_1<M_2,
$$

then

$$
S(a,M_1)<S(a,M_2).
$$

**Proof sketch.** Since $a>0$ and $\pi>0$, the coefficient $\pi a^2$ is positive. Squaring is strictly increasing on nonnegative real numbers, so $M_1^2<M_2^2$. Multiplication by the positive coefficient preserves the strict inequality. $\square$

Restricting to nonnegative masses is essential. The function $M^2$ is not strictly increasing on all of $\mathbb R$.

### 5.2 Quadratic versus linear capacity

**Theorem 6 (Eventual domination of linear storage).** Let $k,c,M\in\mathbb R$ satisfy $k>0$, $c\ge0$, and

$$
M\ge\frac{c}{k}.
$$

Then

$$
cM\le kM^2.
$$

**Proof sketch.** The threshold and sign assumptions imply $M\ge0$. Multiplying $M\ge c/k$ by $k>0$ gives $kM\ge c$. Multiplying this inequality by $M\ge0$ gives $kM^2\ge cM$. $\square$

Taking $k=\pi a^2$ for $a\ne0$ shows that horizon entropy eventually dominates any capacity proportional to mass. The condition $k>0$ is indispensable: if $k=0$ and $cM>0$, no domination is possible.

## 6. Why holographic memory does not exhaust the library

For fixed $a$ and $M$, define an idealized integer capacity

$$
N_{\mathrm{BH}}(a,M)=\max\left(0,\left\lfloor S(a,M)\right\rfloor\right).
$$

The nonnegative part handles unphysical parameter choices uniformly. For the physical regime $a>0$ and $M\ge0$, entropy is already nonnegative and this is simply $\lfloor\pi a^2M^2\rfloor$.

**Theorem 7 (Holographic Scarcity).** For every fixed finite pair $a,M\in\mathbb R$,

$$
\lim_{n\to\infty}
\frac{\min\bigl(N_{\mathrm{BH}}(a,M),n\bigr)}{n}=0.
$$

**Proof sketch.** The value $S(a,M)=\pi a^2M^2$ is a finite real number for fixed finite inputs, so $N_{\mathrm{BH}}(a,M)$ is a fixed natural number. Apply Theorem 3 with $N=N_{\mathrm{BH}}(a,M)$. $\square$

The theorem distinguishes absolute and relative gains. Increasing mass can raise capacity quadratically, and Theorem 6 shows that this eventually beats every linear law. Nevertheless, for each fixed mass the capacity remains finite. The zero-density conclusion depends on that finiteness, not on whether capacity arose from a constant, linear, quadratic, exponential, or still faster finite expression.

There is no contradiction between Theorems 6 and 7. The former compares two functions of mass as mass varies. The latter fixes mass and compares a resulting constant capacity with larger and larger theorem prefixes. The orders of variation are different.

## 7. Algorithms and numerical observables

### 7.1 Enumeration of finite strings

A canonical string enumerator loops over lengths $\ell=0,1,2,\ldots$ and emits the $b^\ell$ strings of each length in lexicographic order. Producing all strings through length $L$ emits

$$
\sum_{\ell=0}^{L}b^\ell=
\begin{cases}
L+1,&b=1,\\
\dfrac{b^{L+1}-1}{b-1},&b\ne1
\end{cases}
$$

strings. The running time is at least proportional to the total output size; storing all outputs also requires exponential space in $L$ when $b>1$. A deductive system requires an additional proof checker or theorem recognizer.

### 7.2 Finite-budget profile

For numerical work, compute $f_N(n)$ directly as $\min(N,n)/n$. Evaluating it at $m$ supplied prefix sizes takes $O(m)$ arithmetic operations and $O(m)$ output space, or $O(1)$ auxiliary space when values are streamed. Logarithmically spaced prefixes clearly display the transition from full coverage for $n\le N$ to reciprocal decay for $n>N$.

### 7.3 Holographic profile

Given $a$ and a list of masses, compute $S(a,M)=\pi a^2M^2$. This costs constant arithmetic work per mass. Ratios $S(a,cM)/S(a,M)$ equal $c^2$ whenever the denominator is nonzero. The crossover with linear capacity $cM$ occurs at $M=c/k$ for quadratic coefficient $k>0$; above that threshold, the quadratic curve dominates.

Numerical demonstrations should not be mistaken for derivations of physical bit counts. In SI units, the constants and dimensions must be restored, and entropy must be converted to bits. The dimensionless model is best understood as a transparent demonstration of scaling.

## 8. Interpretation and limitations

### 8.1 What is established

The mathematical chain is short and robust:

1. Finite strings over a finite alphabet form a countable set.
2. An infinite theorem subset is therefore countably infinite.
3. Removing a finite discovered set leaves infinitely many theorems.
4. A fixed finite budget has asymptotically zero coverage of growing prefixes.
5. The stated horizon formulas imply entropy proportional to $M^2$.
6. Every fixed finite mass still yields a finite capacity and hence zero limiting coverage.

These conclusions apply to any productive theorem set represented by finite strings, not only to ZFC. The logic does not depend on the numerical value of a cosmic operation bound.

### 8.2 What is assumed

Several stronger claims are not derived here. A value such as $10^{120}$ operations depends on a physical model, parameters, and the definition of an elementary operation. An operation is not automatically a new theorem; actual proof search may spend vast resources on failed candidates or duplicate conclusions. Conversely, one operation might participate in compactly describing many results. The finite-budget abstraction intentionally suppresses these distinctions.

Likewise, horizon entropy is not by itself a blueprint for writable, readable memory. The model omits construction energy, access latency, noise, causal constraints, black-hole lifetime, evaporation, and the thermodynamic cost of error correction. Its role is to establish the quadratic mass scaling implied by the area law and to ask whether that scaling can cross the finite/infinite boundary. It cannot for fixed finite mass.

### 8.3 Countability versus decidability

A countably infinite theorem set need not admit a decidable membership test. For effectively axiomatized systems, finite proofs can generally be checked and theorems enumerated by dovetailing through candidate derivations, but non-theorems may never be certified as such. Countability alone is weaker still: it asserts the existence of an enumeration without specifying a feasible algorithm.

The phrase “all theorems can in principle be listed” must therefore be read as an unending process in which every theorem occurs at some finite stage, not as a finite-time completion. No single finite stage contains the full infinite set.

### 8.4 The role of incompleteness

The theorem library $T_D$ contains provable strings, not all semantically true statements. In sufficiently expressive consistent systems, truth and provability diverge. The present scarcity result is already present within the provable subset: even before accounting for independent truths, a finite archive misses infinitely many provable statements. Future semantic models should distinguish theoremhood, truth in a structure, independence, and actual discovery.

## 9. Applications

The same framework applies beyond cosmological speculation.

**Bounded automated reasoning.** Any prover with a finite time or energy budget emits finitely many distinct theorems. If the target deductive closure is infinite, infinitely many remain ungenerated, and fixed-output coverage vanishes against growing enumerated prefixes.

**Scientific archives.** A finite database cannot exhaust an infinite family of derivable consequences, even if compression makes the archive highly expressive. The distinction between storing axioms or generators and explicitly storing every consequence becomes central.

**Complexity-aware theorem search.** Replacing arbitrary enumeration by proof length or formula length yields counting functions that can compare search budgets with the combinatorial growth of candidates. This can expose scarcity long before absolute thermodynamic limits become relevant.

**Information geometry.** The horizon calculation illustrates how geometry controls capacity: radius scales linearly, area quadratically, and entropy follows area. Similar reasoning appears whenever resources live on boundaries rather than in volumes.

## 10. Future research

A fuller theory should proceed in eight directions.

First, one can replace the abstract theorem set by concrete first-order syntax, finite derivation trees, the ZFC axiom schemes, and an explicit derivability relation. Productivity can then be established by constructing infinitely many syntactically distinct provable formulas, such as iterated conjunctions of a fixed equality axiom.

Second, bare countability should be strengthened to effective enumeration. A dovetailed proof-search algorithm can inspect all finite candidate derivations, with a proof that every valid derivation is eventually checked. This would separate the number of strings inspected from the number of distinct theorems emitted.

Third, scarcity should become complexity-sensitive. One may study the number of theorems possessing proofs of length at most $n$. Finite alphabets give upper bounds, while useful lower bounds require explicit infinite proof families.

Fourth, density notions should be tied to intrinsic size. Formula length, proof length, prefix-free description complexity, and upper Banach density offer alternatives to arbitrary theorem orderings.

Fifth, the physical model should restore dimensions and constants. A complete bit count includes $G$, $c$, $\hbar$, and $k_B$, and divides thermodynamic entropy by $k_B\log 2$.

Sixth, the operation cap should be stated as an explicit physical hypothesis. Margolus–Levitin bounds, Bekenstein bounds, and de Sitter horizon entropy represent distinct assumptions and should not be conflated.

Seventh, holographic capacity should be coupled to lifetime, energy, access latency, and evaporation. Quadratic storage may be offset by severe costs in construction and retrieval.

Eighth, semantic truth should be added so that provable statements, true statements, independent statements, and emitted discoveries are separate sets. This would connect finite discovery horizons to incompleteness without confusing “not found by a deadline” with “unprovable.”

## 11. Conclusion

A productive deductive system over a finite alphabet has a theorem library in bijection with the natural numbers. This makes the library enumerable but not finitely exhaustible. Every finite discovery set leaves infinitely many theorems behind, and a fixed budget $N$ covers only $\min(N,n)/n$ of an initial segment of length $n$, a fraction converging to zero.

Black-hole thermodynamics changes the scale of the finite budget. Under the Schwarzschild and area-law assumptions, entropy is $\pi a^2M^2$: doubling mass quadruples capacity, nonnegative mass increases capacity strictly, and quadratic storage eventually dominates every nonnegative linear law. Yet fixed finite mass still yields fixed finite capacity. The asymptotic theorem share remains zero.

Thus the central boundary is not between ordinary and exotic computation, nor between linear and quadratic growth. It is the boundary between every finite physical archive and a countably infinite mathematical library. A final theorem printed at the end of computation would mark the end of discovery, not the end of what remains to be discovered.

## References

1. J. D. Bekenstein, “Black holes and entropy,” *Physical Review D* **7** (1973), 2333–2346.
2. S. W. Hawking, “Particle creation by black holes,” *Communications in Mathematical Physics* **43** (1975), 199–220.
3. K. Gödel, “Über formal unentscheidbare Sätze der Principia Mathematica und verwandter Systeme I,” *Monatshefte für Mathematik und Physik* **38** (1931), 173–198.
4. F. J. Dyson, “Time without end: Physics and biology in an open universe,” *Reviews of Modern Physics* **51** (1979), 447–460.
