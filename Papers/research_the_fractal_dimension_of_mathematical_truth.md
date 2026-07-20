# The Fractal Dimension of a Locally Constrained Truth Language

**Aristotle**  
**July 20, 2026**

## Abstract

We study a precise symbolic model for a constrained space of truth values. Infinite binary streams represent successive yes-or-no answers, and a local consistency condition forbids adjacent positive answers. Finite admissible prefixes form the golden-mean language. We give a self-contained combinatorial analysis: every admissible word has the prescribed length; the recursive branches are disjoint; the number of length-$n$ words is exactly the Fibonacci number $F_{n+2}$; and every finite admissible word extends to an infinite admissible stream. We prove explicit bounds

$$
2^{\lfloor n/2\rfloor}\le F_{n+2}<2^n \qquad (n\ge2),
$$

and a two-step contraction inequality for the density of admissible cylinders. With the Cantor prefix scale $2^{-n}$, the exponential growth parameter, entropy, and standard box-dimension value are

$$
D=\frac{\log\varphi}{\log2},
\qquad
\varphi=\frac{1+\sqrt5}{2},
$$

with $0<D<1$. The model therefore exhibits a rigorous sparse-but-nonnegligible regime. We also present linear-time recognition and generation algorithms, discuss connections with constrained coding and symbolic dynamics, and delimit the model’s relation to mathematical truth and Chaitin-style constructions. In particular, this decidable language does not support an uncomputability claim without additional semantic and machine-specific structure.

## 1. Introduction

Binary streams provide a common language for logic, information theory, computation, and symbolic dynamics. A stream $x:\mathbb N\to\{0,1\}$ may encode answers to an ordered collection of questions, successive states of a device, or a trajectory through a two-symbol dynamical system. The full set of streams is Cantor space. Its natural geometry is determined by prefixes: two streams are close if their first disagreement occurs far in the future.

The full binary tree has $2^n$ prefixes of length $n$. Local restrictions prune this tree and may produce an infinite set whose number of surviving depth-$n$ cylinders grows at an intermediate exponential rate. Such sets are elementary examples of fractal symbolic spaces. Their geometry can often be read directly from combinatorics.

We consider the simplest nontrivial rule of this kind: the block $11$ is forbidden. Interpreting $1$ as a positive answer, the rule says that no two successive answers may both be positive. We call the resulting set the **golden-mean truth language**. The terminology “truth language” describes the binary interpretation, not a claim that this system captures all mathematical truth. Its consistency condition is intentionally local and transparent.

Three features make the model useful. First, it admits exact counting. The number of length-$n$ admissible words is $F_{n+2}$, where $F_n$ is the Fibonacci sequence. Second, no admissible finite prefix is a dead end: every one extends to an infinite admissible stream. Third, its growth rate is neither constant nor maximal. At scale $2^{-n}$ the number of inhabited cylinders is asymptotic to a constant times $\varphi^n$, so the associated dimension is $\log_2\varphi$, strictly between $0$ and $1$.

The paper develops these statements from first principles. Section 2 defines prefix scales, admissibility, and cylinders. Section 3 proves structural properties and exact Fibonacci enumeration. Section 4 establishes extension to infinite streams. Section 5 proves quantitative sparsity and density contraction. Section 6 derives entropy and dimension. Section 7 gives algorithms and numerical methods. Sections 8 and 9 discuss applications, scope, and generalization.

## 2. Definitions and geometric setting

### 2.1 Binary words and streams

Let $\mathbb B=\{0,1\}$. A **binary word of length $n$** is an element

$$
w=(w_0,w_1,\ldots,w_{n-1})\in\mathbb B^n.
$$

A **binary stream** is a function $x:\mathbb N\to\mathbb B$. A word or stream is **locally consistent** if it contains no adjacent pair of ones. Thus a finite word $w$ is locally consistent when

$$
\neg(w_k=1\ \text{and}\ w_{k+1}=1)
$$

for every $k<n-1$. A stream $x$ is locally consistent when

$$
\neg(x_k=1\ \text{and}\ x_{k+1}=1)
$$

for every $k\in\mathbb N$.

Let $W_n$ denote the set of locally consistent words of length $n$. We call its elements **admissible truth patterns**. Let

$$
X=\{x\in\mathbb B^{\mathbb N}:x\text{ is locally consistent}\}
$$

be the infinite golden-mean language.

### 2.2 Recursive description

The family $W_n$ has the initial values

$$
W_0=\{\varepsilon\},
\qquad
W_1=\{0,1\},
$$

where $\varepsilon$ is the empty word. For $n\ge0$, define recursively

$$
W_{n+2}=0W_{n+1}\ \cup\ 10W_n,
$$

where $0W_{n+1}$ consists of words formed by prefixing $0$ to a member of $W_{n+1}$, and $10W_n$ consists of words formed by prefixing $10$ to a member of $W_n$.

This recursion expresses the first-symbol dichotomy. An admissible word either begins with $0$, after which any admissible tail is allowed, or begins with $1$, which forces the next symbol to be $0$.

### 2.3 Prefix agreement and cylinders

For streams $x,y$ and $n\in\mathbb N$, say that $x$ and $y$ **agree to depth $n$**, written informally as $x\sim_n y$, if

$$
x_k=y_k\qquad\text{for all }k<n.
$$

For each fixed $n$, this is an equivalence relation. It is reflexive because every coordinate equals itself, symmetric because equality is symmetric, and transitive because coordinatewise equality is transitive. The relations are nested in the reverse direction: if $m\le n$ and $x\sim_n y$, then $x\sim_m y$.

Given a word $w\in\mathbb B^n$, its **cylinder** is

$$
[w]=\{x\in\mathbb B^{\mathbb N}:x_k=w_k\text{ for every }k<n\}.
$$

The depth-$n$ cylinders partition Cantor space into $2^n$ pieces. Under the standard Cantor ultrametric, in which the distance between distinct streams whose first disagreement occurs at index $r$ is $2^{-r}$, these cylinders are balls at scale comparable to $2^{-n}$. The geometry needed below can therefore be expressed entirely through prefix depth.

## 3. Structural lemmas and exact enumeration

We begin by justifying the recursive construction and then count its words.

### Lemma 3.1 (Length preservation)

Every word in $W_n$ has length exactly $n$.

**Proof sketch.** The claim is immediate for $n=0$ and $n=1$. For the recursive step, a word in the first branch has the form $0u$ with $u\in W_{n+1}$; by induction its length is $1+(n+1)=n+2$. A word in the second branch has the form $10v$ with $v\in W_n$; its length is $2+n=n+2$. Hence every recursively generated word has the advertised length. $\square$

### Lemma 3.2 (Disjoint branch decomposition)

For every $n\ge0$, the sets $0W_{n+1}$ and $10W_n$ are disjoint.

**Proof sketch.** Every word in $0W_{n+1}$ begins with $0$, whereas every word in $10W_n$ begins with $1$. No binary word can satisfy both conditions. $\square$

### Lemma 3.3 (Cylinder-count recurrence)

For every $n\ge0$,

$$
|W_{n+2}|=|W_{n+1}|+|W_n|.
$$

**Proof sketch.** By the recursive description, $W_{n+2}$ is the union of $0W_{n+1}$ and $10W_n$. Prefixing a fixed finite word is injective, so these branches have cardinalities $|W_{n+1}|$ and $|W_n|$. Lemma 3.2 makes their union disjoint, and cardinalities therefore add. $\square$

Let the Fibonacci numbers be defined by

$$
F_0=0,
\qquad
F_1=1,
\qquad
F_{m+2}=F_{m+1}+F_m.
$$

### Theorem 3.4 (Exact Cylinder Count Theorem)

For every $n\ge0$, the number of admissible truth patterns of length $n$ is

$$
|W_n|=F_{n+2}.
$$

**Proof sketch.** The initial counts are $|W_0|=1=F_2$ and $|W_1|=2=F_3$. Lemma 3.3 gives the Fibonacci recurrence. Induction on $n$ identifies the two sequences term by term. $\square$

The theorem yields the sequence

$$
|W_0|,|W_1|,|W_2|,\ldots=1,2,3,5,8,13,21,\ldots.
$$

For example,

$$
W_3=\{000,001,010,100,101\}.
$$

The exact count also has a matrix interpretation. If $a_n$ and $b_n$ count admissible words of length $n$ ending in $0$ and $1$, respectively, then

$$
\begin{pmatrix}a_{n+1}\\b_{n+1}\end{pmatrix}
=
\begin{pmatrix}1&1\\1&0\end{pmatrix}
\begin{pmatrix}a_n\\b_n\end{pmatrix}.
$$

The leading eigenvalue of this matrix is $\varphi=(1+\sqrt5)/2$. This linear-algebraic description anticipates the entropy computation and generalizes to arbitrary finite forbidden-block systems.

## 4. Extension from finite patterns to infinite streams

Counting finite words measures inhabited cylinders only if every admissible prefix can occur in an infinite admissible stream. In the present model, extension is unconditional.

### Theorem 4.1 (Consistent Extension Theorem)

Let $w\in W_n$. There exists a stream $x\in X$ whose first $n$ coordinates equal $w$.

**Proof sketch.** Define $x_k=w_k$ for $k<n$ and $x_k=0$ for $k\ge n$. No forbidden pair occurs within the prefix because $w$ is admissible. The boundary pair, if present, ends in the appended symbol $0$, and the infinite tail consists entirely of zeros. Thus $x$ contains no $11$ and extends $w$. $\square$

### Corollary 4.2 (Inhabited-cylinder count)

At depth $n$, exactly $F_{n+2}$ cylinders intersect $X$.

**Proof sketch.** A cylinder intersects $X$ exactly when its defining word is admissible. The forward implication follows because every prefix of a locally consistent stream is locally consistent. The reverse implication is Theorem 4.1. Theorem 3.4 supplies the count. $\square$

This extension property distinguishes genuine geometric branches from temporary combinatorial possibilities. It also implies that $X$ has no isolated point: after any admissible prefix, one can extend by zeros, and sufficiently far beyond that prefix one may choose either $0$ or, when preceded by $0$, $1$, producing distinct streams with arbitrarily long common prefixes.

## 5. Quantitative sparsity

The exact Fibonacci formula allows asymptotic analysis, but elementary inequalities already certify intermediate growth.

### Proposition 5.1 (Binary upper bound)

For every $n\ge0$,

$$
F_{n+2}\le2^n.
$$

**Proof sketch.** Since $W_n\subseteq\mathbb B^n$, one immediately has $|W_n|\le2^n$. Equivalently, the inequality follows by induction from the Fibonacci recurrence and the identity $2^{n+1}=2^n+2^n$. $\square$

### Theorem 5.2 (Strict Sparsity Theorem)

For every $n\ge2$,

$$
|W_n|=F_{n+2}<2^n.
$$

**Proof sketch.** At $n=2$, the admissible words are $00$, $01$, and $10$, so $|W_2|=3<4$. Suppose the strict inequality is known at two consecutive indices. Then

$$
|W_{n+2}|=|W_{n+1}|+|W_n|<2^{n+1}+2^n<2^{n+2}.
$$

Together with the initial cases, induction proves strictness at every depth at least two. $\square$

### Theorem 5.3 (Exponential Lower Bound Theorem)

For every $n\ge0$,

$$
2^{\lfloor n/2\rfloor}\le |W_n|=F_{n+2}.
$$

**Proof sketch.** For even length $n=2m$, independently choose each two-symbol block to be either $00$ or $10$. Concatenating the chosen blocks creates no adjacent ones, including across block boundaries, because every block ends in $0$. This injects $2^m$ choices into $W_{2m}$. For odd length $n=2m+1$, prepend or append a zero to the same construction, again obtaining $2^m$ distinct admissible words. Since $m=\lfloor n/2\rfloor$, the bound follows. $\square$

### Corollary 5.4 (Intermediate Fractal Growth)

For every $n\ge2$,

$$
2^{\lfloor n/2\rfloor}\le |W_n|<2^n.
$$

The lower and upper exponents already imply that any limiting normalized logarithmic growth lies in $[1/2,1]$, while the exact Fibonacci formula sharpens this to a single value strictly inside the interval.

Define the depth-$n$ density by

$$
d_n=\frac{|W_n|}{2^n}.
$$

### Theorem 5.5 (Two-Step Density Contraction Theorem)

For every $n\ge0$,

$$
d_{n+2}\le\frac34d_n.
$$

Equivalently,

$$
2^n|W_{n+2}|\le3\cdot2^n|W_n|.
$$

**Proof sketch.** Using $|W_m|=F_{m+2}$, it is enough to show $F_{n+4}\le3F_{n+2}$. The Fibonacci recurrence gives

$$
F_{n+4}=F_{n+3}+F_{n+2}=2F_{n+2}+F_{n+1}\le3F_{n+2},
$$

because $F_{n+1}\le F_{n+2}$. Dividing by $2^{n+2}$ gives the density form. $\square$

### Corollary 5.6 (Vanishing density)

The proportion $d_n$ tends to $0$ exponentially as $n\to\infty$.

**Proof sketch.** Iterating Theorem 5.5 separately along even and odd indices gives $d_{2m}\le(3/4)^m d_0$ and $d_{2m+1}\le(3/4)^m d_1$. Both bounds tend to zero. $\square$

Thus absolute abundance and relative rarity coexist: $|W_n|$ is exponentially large, while its fraction among all binary words vanishes exponentially.

## 6. Entropy and dimension

### 6.1 Exponential growth rate

The golden ratio

$$
\varphi=\frac{1+\sqrt5}{2}
$$

satisfies $\varphi^2=\varphi+1$. Binet’s formula states

$$
F_m=\frac{\varphi^m-\psi^m}{\sqrt5},
\qquad
\psi=\frac{1-\sqrt5}{2},
$$

with $|\psi|<1$. Therefore

$$
F_{n+2}=\frac{\varphi^{n+2}}{\sqrt5}\left(1-\left(\frac{\psi}{\varphi}\right)^{n+2}\right),
$$

and hence

$$
\lim_{n\to\infty}\frac1n\log F_{n+2}=\log\varphi.
$$

The **topological entropy** of the language, measured in natural logarithmic units per symbol, is therefore $\log\varphi$. In bits per symbol it is $\log_2\varphi$.

### 6.2 Box-counting interpretation

At Cantor scale $2^{-n}$, Corollary 4.2 shows that exactly

$$
N_n=F_{n+2}
$$

depth-$n$ cylinders are needed to cover $X$. The corresponding normalized logarithmic count is

$$
D_n=\frac{\log N_n}{\log(2^n)}
=
\frac{\log F_{n+2}}{n\log2}.
$$

Taking the limit gives

$$
D=\lim_{n\to\infty}D_n
=
\frac{\log\varphi}{\log2}.
$$

This is the standard box-dimension value associated with the golden-mean subshift in the binary Cantor metric.

### Theorem 6.1 (Intermediate Dimension Theorem)

The entropy-normalized dimension parameter

$$
D=\frac{\log\varphi}{\log2}
$$

satisfies

$$
0<D<1.
$$

**Proof sketch.** Since $\sqrt5>1$, one has $\varphi>1$. Since $\sqrt5<3$, one has $\varphi<2$. The logarithm is strictly increasing on positive real numbers, so

$$
0=\log1<\log\varphi<\log2.
$$

Because $\log2>0$, division by $\log2$ yields $0<D<1$. Numerically,

$$
D\approx0.694241913630617.
$$

$\square$

The dimension has a direct operational interpretation. Among all $n$-bit strings, the admissible set has approximately $\varphi^n$ elements. Naming one admissible word therefore requires approximately $n\log_2\varphi$ bits, rather than $n$ unrestricted bits. The same constant is simultaneously a geometric dimension, a symbolic entropy in base two, and an asymptotic coding rate.

## 7. Algorithms and numerical experiments

The theory leads to simple and useful computations.

### 7.1 Linear-time recognition

Given a word $w$ of length $n$, scan adjacent pairs from left to right. Reject as soon as $11$ appears; otherwise accept after the final symbol.

**Correctness.** Rejection occurs exactly when the defining local condition fails. If the scan finishes, every adjacent pair has been inspected and none equals $11$, so the word is admissible.

**Complexity.** The algorithm uses $O(n)$ time and $O(1)$ auxiliary space.

### 7.2 Recursive generation

The decomposition

$$
W_{n+2}=0W_{n+1}\cup10W_n
$$

gives a generator. Recursively generate the two smaller languages, prefix their words, and concatenate the disjoint outputs.

**Correctness.** Every generated word is admissible by construction. Conversely, every admissible word begins in exactly one of the two forms, so no word is missed or duplicated.

**Complexity.** Any explicit generator must spend $\Omega(nF_{n+2})$ time merely to write all output symbols. A straightforward implementation achieves $O(nF_{n+2})$ output-sensitive time and stores $O(n)$ state when implemented as a depth-first iterator.

### 7.3 Fast counting

For moderate sizes, iterate the recurrence with two integers. Starting from $c_0=1$ and $c_1=2$, update

$$
(c_k,c_{k+1})\leftarrow(c_{k+1},c_k+c_{k+1}).
$$

After $n-1$ updates, $c_n=F_{n+2}$.

This takes $O(n)$ integer additions and $O(1)$ integer registers. In bit complexity, the operands contain $O(n)$ bits, so arithmetic cost must also be accounted for. Matrix exponentiation or Fibonacci fast doubling computes the count in $O(\log n)$ recursive arithmetic steps.

### 7.4 Dimension approximation

For $n\ge1$, define

$$
D_n=\frac{\log_2 |W_n|}{n}.
$$

Exact counting followed by a logarithm gives a convergent numerical estimate of $D$. Because $F_{n+2}=C\varphi^n(1+o(1))$ for a positive constant $C$, the error is of order $O(1/n)$ in this uncorrected estimator. A ratio estimator,

$$
R_n=\log_2\left(\frac{|W_{n+1}|}{|W_n|}\right),
$$

converges more rapidly to $\log_2\varphi$ because the Fibonacci ratio converges geometrically to $\varphi$.

A numerical demonstration can tabulate $n$, $F_{n+2}$, $2^{\lfloor n/2\rfloor}$, $2^n$, the density $d_n$, and $D_n$. It can also enumerate short words to compare direct counts with the recurrence and plot the decay of $d_n$ alongside convergence of $D_n$.

## 8. Applications and broader connections

### 8.1 Constrained coding

In magnetic and optical storage, certain local patterns may be undesirable because they impair timing recovery or produce unreliable physical states. A finite-state constraint removes those patterns. The number of valid codewords determines the achievable information rate. For the no-$11$ rule, that rate is $\log_2\varphi$ bits per stored symbol. The present counting and dimension calculation are therefore identical to a basic capacity computation for a constrained channel.

### 8.2 Symbolic dynamics

The shift map removes the first symbol of a stream. The set $X$ is invariant under this operation and is a shift of finite type. Its allowed transitions can be represented by the matrix

$$
A=\begin{pmatrix}1&1\\1&0\end{pmatrix},
$$

where states record the previous symbol. The number of paths grows according to the spectral radius $\rho(A)=\varphi$. This explains why a local combinatorial rule determines a global entropy.

### 8.3 Finite automata and regular languages

A two-state automaton recognizes the language. One state records that the previous symbol was $0$ or that no symbol has appeared; the other records that the previous symbol was $1$. Reading $1$ from the second state enters rejection. The language is regular, decidable, and efficiently enumerable. Its generating function is rational:

$$
\sum_{n\ge0}|W_n|z^n
=
\sum_{n\ge0}F_{n+2}z^n
=
\frac{1+z}{1-z-z^2}.
$$

The poles of this generating function again encode golden-ratio growth.

### 8.4 A disciplined metaphor for truth

If bits are interpreted as answers to statements, local rules can model dependencies among neighboring answers. The no-$11$ condition is deliberately minimal. It demonstrates that restricting patterns of answers can create a set with nonintegral geometric complexity. But semantic conclusions depend on the encoding, the ordering of statements, and the chosen theory. The model’s strength is that these assumptions are explicit rather than hidden.

## 9. Scope, limitations, and future directions

The results concern a decidable golden-mean language, not the collection of truths of arithmetic or any other foundational theory. The dimension $\log_2\varphi$ is computable. Consequently, the present model does not prove that a “dimension of mathematical truth” is uncomputable.

To formulate a semantic theorem, one would need at least the following data: an effective encoding of formulas, a fixed theory or intended structure, and an explicit order in which truth values are read. Different encodings can change prefix geometry, and different theories can change the stream. Claims of invariance require separate arguments.

A connection with Chaitin’s $\Omega$ would require a specified prefix-free machine $U$ and the halting probability

$$
\Omega_U=\sum_{U(p)\ \mathrm{halts}}2^{-|p|}.
$$

One would then define finite approximants, prove monotonicity and convergence, and only afterward address machine-dependent randomness or uncomputability. Fibonacci growth by itself supplies none of these ingredients.

Several natural mathematical extensions remain.

1. Define the Cantor ultrametric explicitly from first disagreement and identify radius-$2^{-n}$ balls with depth-$n$ agreement classes.
2. Develop the covering-number argument in full generality and establish equality of upper and lower box dimensions directly from the Fibonacci logarithmic limit.
3. Replace the single forbidden block $11$ by an arbitrary finite forbidden language. A finite adjacency matrix $A$ then governs cylinder counts, and the expected dimension is

$$
\frac{\log\rho(A)}{\log2},
$$

where $\rho(A)$ is the spectral radius.
4. Separate syntax from semantics by selecting a prefix-free formula encoding and a specific theory, then study the resulting theoremhood stream.
5. Introduce computability questions only after the coding and proof system are fixed.
6. For a genuine algorithmic-information direction, construct prefix-free machines, halting domains, and finite $\Omega$ approximants before studying randomness.

## 10. Conclusion

A single forbidden block produces a complete chain of consequences. The local rule $11$ forbidden yields the disjoint recursion

$$
W_{n+2}=0W_{n+1}\cup10W_n.
$$

The recursion yields the exact count $|W_n|=F_{n+2}$. Every counted prefix extends to an infinite admissible stream. The counts satisfy

$$
2^{\lfloor n/2\rfloor}\le |W_n|<2^n
$$

for $n\ge2$, while their relative density contracts by a factor of at most $3/4$ every two levels. Finally, Fibonacci asymptotics yield the entropy and box-dimension value

$$
D=\frac{\log\varphi}{\log2}\in(0,1).
$$

The golden-mean truth language is therefore sparse among all binary streams but retains positive exponential complexity. It offers a fully transparent example of how local constraints generate global fractal structure, and it provides a principled starting point for broader investigations of finite-state languages, symbolic dimensions, constrained information, and carefully specified semantic encodings.
