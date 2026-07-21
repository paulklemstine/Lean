# Counted Proof Spaces: Entropy, Sparsity, and Critical Indices

## Abstract

We study a finite-alphabet model of proof space in which all words of length at most $n$ form the ambient syntactic population and a cumulative function $P(n)$ counts a distinguished derivable subfamily. Three observables are separated: combinatorial volume, derivability density, and entropy density. For an alphabet of size $k\ge2$, the ambient volume is $S_k(n)=\sum_{i=0}^n k^i$. If $P(n)\le Ca^n$ for constants $C\ge0$ and $0\le a<k$, then the derivability density $\rho(n)=P(n)/S_k(n)$ tends to zero, while the ambient entropy density $h(n)=\log S_k(n)/n$ tends to $\log k$. Hence the two-coordinate phase observable converges to $\bigl(0,\log k\bigr)$: derivability is asymptotically sparse despite persistent positive syntactic entropy. If $\rho$ is additionally antitone, every positive level not exceeding the initial density has a unique finite critical index, and the indices are partitioned exactly into those before and after the crossing. We also analyze a homogeneous geometric model of statement lengths and prove that its successive probability ratio is constant, equal to $1/k$; exponential language growth therefore does not imply a power-law length distribution. The results give rigorous sufficient conditions for threshold behavior while clarifying dependence on encoding, observation level, and monotonicity. They do not assert a canonical numerical threshold arising from incompleteness alone.

## 1. Introduction

The suggestion that major theorems behave like phase transitions in a space of possible proofs combines ideas from logic, combinatorics, information theory, and statistical physics. To make that suggestion mathematical, one must identify a state space, a size parameter, and an order parameter. A finite alphabet supplies a basic state space: all finite words that could encode statements or deductions. A length cutoff supplies scale. The fraction of words belonging to a selected derivable family supplies an order parameter.

This model is intentionally austere. It does not identify raw strings with meaningful formulas, nor does it prescribe a canonical encoding of a deductive system. Instead, it isolates consequences that follow from counting assumptions alone. This distinction is essential. Syntactic volume, derivability, semantic truth, and incompleteness are related concepts, but they are not interchangeable.

The main conclusion is an entropy–sparsity separation. If the ambient language has exponential base $k$ while a derivable subfamily has an upper exponential base $a<k$, then the subfamily has zero asymptotic density. Nevertheless, the ambient entropy per unit length converges to the positive constant $\log k$. Thus a low-density derivable phase coexists with a highly expansive syntactic background.

A second conclusion turns asymptotic sparsity into a finite threshold. Convergence to zero alone allows oscillation and repeated crossings. Under the additional hypothesis that density is antitone, each admissible positive observation level $\varepsilon$ has a unique last index $c$ at which density is at least $\varepsilon$. For all $n$, density is below $\varepsilon$ exactly when $n>c$. This is a precise sharp-transition statement, conditional on monotonicity.

A third conclusion concerns theorem-length predictions. A natural homogeneous length model determined by alphabet entropy is geometric, with constant successive ratio $1/k$. That behavior is incompatible with a genuine power law, whose successive ratio varies with length. A power-law tail therefore requires additional structure, such as a mixture of geometric regimes, rather than following from exponential word growth alone.

The paper proceeds from definitions through limit theorems, a threshold theorem, algorithms, examples, applications, and limitations. All logarithms are natural logarithms. The natural numbers include $0$.

## 2. Counted languages and observables

### 2.1. Ambient syntactic volume

Fix an alphabet with $k$ symbols, where $k\in\mathbb N$ and $k\ge2$. There are exactly $k^i$ words of length $i$. Including the empty word, the number of words of length at most $n$ is

$$
S_k(n)=\sum_{i=0}^{n}k^i.
$$

The geometric-series identity gives

$$
S_k(n)=\frac{k^{n+1}-1}{k-1}.
$$

The boundary convention matters: $S_k(0)=1$, so the ambient population is positive at every cutoff. We will repeatedly use the elementary lower bound

$$
k^n\le S_k(n).
$$

For $k\ge2$, another convenient upper bound is

$$
S_k(n)\le k^{n+1}.
$$

Indeed, the closed form yields $S_k(n)<k^{n+1}/(k-1)\le k^{n+1}$ when interpreted with the appropriate non-strict endpoint bound.

### 2.2. Distinguished counted families

Let $P:\mathbb N\to\mathbb N$ be a cumulative count. The intended interpretation is that $P(n)$ counts members of a distinguished derivable family represented by words of length at most $n$. For a genuine subfamily we require

$$
0\le P(n)\le S_k(n)
$$

at each relevant cutoff. No monotonicity is initially imposed on the ratio, although a literal cumulative count $P$ itself would normally be nondecreasing.

**Definition 1 (Derivability density).** The density of the distinguished family at cutoff $n$ is

$$
\rho(n)=\frac{P(n)}{S_k(n)}.
$$

The term “derivability” labels the intended application; mathematically, the same definition applies to any counted subfamily.

**Lemma 1 (Unit-interval bound).** If $P(n)\le S_k(n)$, then

$$
0\le\rho(n)\le1.
$$

**Proof sketch.** Both counts are nonnegative and $S_k(n)>0$, so the quotient is nonnegative. Dividing $P(n)\le S_k(n)$ by the positive denominator gives the upper bound. $\square$

### 2.3. Entropy density and phase observable

**Definition 2 (Ambient entropy density).** For $n>0$, define

$$
h(n)=\frac{\log S_k(n)}{n}.
$$

This quantity measures logarithmic ambient volume per unit cutoff. Its limiting value is insensitive to multiplicative constants in $S_k(n)$ and captures the exponential growth rate of the language.

**Definition 3 (Two-coordinate phase observable).** Define

$$
\Phi(n)=\bigl(\rho(n),h(n)\bigr).
$$

The two coordinates are retained because they measure distinct phenomena. The first concerns the relative abundance of a selected family; the second concerns the growth of the entire syntax.

## 3. Entropy–sparsity separation

We now impose an exponential upper bound on the selected family.

**Assumption (Exponential sparsity).** There exist real constants $C\ge0$ and $a$ with $0\le a<k$ such that

$$
P(n)\le Ca^n
$$

for every $n$.

This assumption allows $P(n)$ to grow exponentially. It requires only that its exponential base be strictly smaller than that of the ambient language.

**Theorem 1 (Vanishing density under exponential sparsity).** Let $k\ge2$, $C\ge0$, and $0\le a<k$. If $P(n)\le Ca^n$ for all $n$, then

$$
\lim_{n\to\infty}\rho(n)=0.
$$

**Proof sketch.** The ambient lower bound $S_k(n)\ge k^n$ gives

$$
0\le \rho(n)=\frac{P(n)}{S_k(n)}
\le\frac{Ca^n}{k^n}
=C\left(\frac ak\right)^n.
$$

Because $0\le a/k<1$, the geometric sequence on the right tends to zero. The squeeze theorem proves the claim. $\square$

The strict rate gap $a<k$ is decisive. If $a=k$, the estimate only yields $\rho(n)\le C$ and supplies no decay. Thus the theorem records a comparison of exponential dimensions rather than mere unboundedness of the denominator.

**Theorem 2 (Ambient entropy limit).** If $k\ge2$, then

$$
\lim_{n\to\infty}h(n)=\log k.
$$

**Proof sketch.** From $k^n\le S_k(n)\le k^{n+1}$ for positive $n$, monotonicity of the logarithm gives

$$
n\log k\le\log S_k(n)\le(n+1)\log k.
$$

After division by $n$,

$$
\log k\le h(n)\le\left(1+\frac1n\right)\log k.
$$

Both bounds tend to $\log k$, so another squeeze argument completes the proof. $\square$

**Theorem 3 (Entropy–sparsity separation).** Under the assumptions of Theorem 1,

$$
\lim_{n\to\infty}\Phi(n)=\bigl(0,\log k\bigr).
$$

**Proof sketch.** The first coordinate converges to $0$ by Theorem 1, and the second converges to $\log k$ by Theorem 2. Coordinatewise convergence in the product gives the stated limit. $\square$

The result is not a contradiction between scarcity and abundance. Density is relative. Even if $P(n)$ grows rapidly in absolute terms, it becomes negligible if $S_k(n)$ grows at a strictly larger exponential rate. The phase vector keeps this distinction visible: $(0,\log k)$ represents sparse distinguished structure embedded in a positive-entropy universe.

## 4. Critical indices and sharp crossings

### 4.1. Why convergence is insufficient

Suppose only that $\rho(n)\to0$. For each $\varepsilon>0$, density is eventually below $\varepsilon$, but it may cross the level repeatedly before becoming permanently small. Hence a limit guarantees an eventual region, not a unique crossing boundary.

To obtain a sharp threshold, assume antitonicity:

$$
m\le n\quad\Longrightarrow\quad \rho(n)\le\rho(m).
$$

This condition states that enlarging the cutoff never increases the relative density. It is stronger than monotonicity of the cumulative numerator $P(n)$, because the numerator and denominator may grow at competing rates.

**Definition 4 (Level critical index).** Given $\varepsilon>0$, a natural number $c$ is a critical index at level $\varepsilon$ if

$$
\varepsilon\le\rho(c),\qquad \rho(c+1)<\varepsilon,
$$

and density lies below $\varepsilon$ exactly after $c$:

$$
\rho(n)<\varepsilon\quad\Longleftrightarrow\quad c<n.
$$

The final equivalence contains both sides of the transition, not merely the adjacent crossing inequalities.

### 4.2. Existence and uniqueness

**Theorem 4 (Unique critical index with positive ambient entropy).** Let $k\ge2$, $C\ge0$, and $0\le a<k$. Suppose

$$
P(n)\le Ca^n
$$

for every $n$, and suppose $\rho$ is antitone. For every level $\varepsilon$ satisfying

$$
0<\varepsilon\le\rho(0),
$$

the phase observable converges to $\bigl(0,\log k\bigr)$, and there exists a unique critical index $c\in\mathbb N$ such that

$$
\varepsilon\le\rho(c),
$$

$$
\rho(c+1)<\varepsilon,
$$

and, for every $n$,

$$
\rho(n)<\varepsilon\quad\Longleftrightarrow\quad c<n.
$$

**Proof sketch.** The phase limit is Theorem 3. Since $\rho(n)\to0$ and $\varepsilon>0$, some $N$ satisfies $\rho(n)<\varepsilon$ for every $n\ge N$. Meanwhile $\rho(0)\ge\varepsilon$, so the finite set

$$
A=\{n<N:\varepsilon\le\rho(n)\}
$$

is nonempty. Let $c$ be its greatest element. Then $\varepsilon\le\rho(c)$, while maximality gives $\rho(c+1)<\varepsilon$. If $n>c$, antitonicity gives $\rho(n)\le\rho(c+1)<\varepsilon$. Conversely, if $n\le c$, antitonicity gives $\rho(c)\le\rho(n)$, so $\rho(n)\ge\varepsilon$. This proves the exact equivalence. Any other index satisfying the same equivalence must have the same successor region and therefore equals $c$. $\square$

This theorem is the precise form of a counted phase transition. It is “sharp” because no transition window remains: the level classification changes between two consecutive cutoffs. It is “conditional” because antitonicity, the rate gap, and the initial-level condition are indispensable parts of the statement.

### 4.3. A quantitative search bound

The proof suggests a practical upper bound. From

$$
\rho(n)\le C(a/k)^n,
$$

any $N$ satisfying

$$
C\left(\frac ak\right)^N<\varepsilon
$$

lies strictly after the critical index. When $C>0$ and $0<a<k$, one may choose

$$
N>\frac{\log(C/\varepsilon)}{\log(k/a)}.
$$

Boundary cases are simpler: if $C=0$, then $P(n)=0$ and no positive $\varepsilon\le\rho(0)$ exists; if $a=0$, sparsity forces $P(n)=0$ for positive $n$, so any admissible crossing occurs immediately.

## 5. Length distributions: geometric rather than scale-free

A separate question concerns the distribution of lengths. Consider the normalized geometric model

$$
L_k(n)=\left(1-\frac1k\right)\exp(-n\log k),
$$

where now $k>1$ may be treated as a real parameter. Since $\exp(-n\log k)=k^{-n}$,

$$
L_k(n)=\left(1-\frac1k\right)k^{-n}.
$$

The prefactor normalizes the sum over $n\ge0$ to $1$.

**Theorem 5 (Entropy controls the geometric length ratio).** For every real $k>1$ and every $n\in\mathbb N$,

$$
\frac{L_k(n+1)}{L_k(n)}=\exp(-\log k)=\frac1k.
$$

**Proof sketch.** Substitute the definition at $n+1$ and $n$. The common normalization cancels, and the exponential law leaves $\exp(-\log k)$. Since $k>0$, this equals $1/k$. $\square$

This identity distinguishes geometric tails from power laws. If $Q(n)$ is proportional to $n^{-\alpha}$ for positive $n$, then

$$
\frac{Q(n+1)}{Q(n)}=\left(\frac{n}{n+1}\right)^\alpha,
$$

which depends on $n$ and tends to $1$. The geometric ratio remains fixed below $1$. Therefore an entropy parameter that generates a single exponential regime does not, by itself, determine a power-law exponent.

A power law can emerge from a mixture. For example, writing a geometric tail as $e^{-\lambda n}$ and integrating over small rates $\lambda$ with a mixing density behaving like $\lambda^{\alpha-1}$ suggests

$$
\int_0^\infty e^{-\lambda n}\lambda^{\alpha-1}\,d\lambda
=\Gamma(\alpha)n^{-\alpha}.
$$

This calculation motivates, but does not by itself prove for a concrete deductive system, a heterogeneity mechanism: scale-free aggregate behavior may arise from mixing many geometric proof regimes.

## 6. Algorithms

### 6.1. Exact ambient counting

The ambient count can be computed either by summation or by the closed form. Integer arithmetic avoids floating-point error:

1. Input integers $k\ge2$ and $n\ge0$.
2. Initialize $S=0$ and $p=1$.
3. For $i=0,\ldots,n$, add $p$ to $S$ and replace $p$ by $kp$.
4. Return $S$.

This requires $O(n)$ integer multiplications and additions and $O(1)$ stored integer variables. The closed form $(k^{n+1}-1)/(k-1)$ uses fast exponentiation in $O(\log n)$ multiplications, though the bit complexity depends on the exponentially growing output size.

### 6.2. Density and entropy trajectory

Given tabulated counts $P(0),\ldots,P(N)$, compute $S_k(n)$ iteratively, then evaluate

$$
\rho(n)=P(n)/S_k(n)
$$

and, for $n>0$,

$$
h(n)=\log S_k(n)/n.
$$

This produces the finite phase trajectory $\Phi(n)$. Exact rational arithmetic is available for density; entropy requires a real approximation unless represented symbolically.

### 6.3. Critical-index detection

When antitonicity holds and $0<\varepsilon\le\rho(0)$, scan from $n=0$ until $\rho(n+1)<\varepsilon$. Return $n$. For tabulated data through $N$, the algorithm costs $O(N)$ count comparisons. One should explicitly check antitonicity before interpreting the result as the unique global critical index. Without it, the scan finds only a first local crossing.

If only the sparse upper bound is available, first choose a guaranteed terminal index from $C(a/k)^N<\varepsilon$, then evaluate counts up to that point. Binary search is possible if density can be queried at arbitrary indices and antitonicity has been established, reducing the number of queries to $O(\log N)$.

## 7. Numerical examples

### 7.1. Binary ambient volume

For $k=2$ and $n=3$,

$$
S_2(3)=2^0+2^1+2^2+2^3=1+2+4+8=15.
$$

This confirms that the empty word is included. At cutoff $0$, there is one word; at cutoff $3$, there are fifteen.

### 7.2. Uniformly bounded families

Suppose $k=2$ and $P(n)\le7$ for all $n$. Taking $C=7$ and $a=1$ gives

$$
\rho(n)\le7\left(\frac12\right)^n.
$$

Thus density tends to zero. This example highlights that the numerator need not decrease. A fixed or bounded family becomes sparse because the ambient denominator grows exponentially.

### 7.3. A model antitone crossing

Let $k=3$ and define $P(n)=2^n$. Since $S_3(n)\ge3^n$,

$$
\rho(n)\le\left(\frac23\right)^n.
$$

Direct values are

$$
\rho(0)=1,
\quad
\rho(1)=\frac24=\frac12,
\quad
\rho(2)=\frac4{13},
\quad
\rho(3)=\frac8{40}=\frac15.
$$

For the level $\varepsilon=1/4$, the last density at or above the level occurs at $c=2$, because $4/13>1/4$ while $8/40<1/4$. In this model the density is decreasing, so all later indices remain below the level.

### 7.4. Geometric ratio

For $k=2$, the length model is

$$
L_2(n)=2^{-(n+1)}.
$$

Its first values are $1/2$, $1/4$, $1/8$, and $1/16$, with every successive ratio equal to $1/2$. For $k=4$, the ratio is $1/4$. These constant ratios visibly differ from power-law ratios, which drift upward toward $1$.

## 8. Applications and interpretation

### 8.1. Deductive systems

For a fixed encoding of a deductive calculus, $P(n)$ may count encoded theorems or another derivable class. The results then state conditional facts about relative abundance. They do not equate uncounted words with falsehood: many words may be malformed, redundant, or encode semantically equivalent objects. The model describes the chosen representation.

### 8.2. Program spaces

Replace “derivable statement” by “program satisfying a specification.” If valid programs grow at a smaller exponential rate than all source strings, their density vanishes while the language retains positive entropy. Under a monotone-density condition, a specification-dependent critical cutoff exists for every admissible density level.

### 8.3. Coding and constrained languages

In coding theory, valid codewords or constrained sequences may form a lower-entropy subset of all strings. The phase vector separates channel capacity from code-family density. Similar reasoning applies to grammatically valid expressions, protocol-compliant messages, and combinatorial structures encoded as words.

### 8.4. Search complexity

Vanishing density suggests that uniform random search in the ambient syntax becomes inefficient: the probability of hitting the distinguished family approaches zero. This observation is qualitative. Translating density into algorithmic hardness requires a specified sampling distribution and computational model; sparse sets can still be easy to generate directly.

## 9. Scope and limitations

The framework supports four guarded conclusions.

First, exponentially sparse derivability can coexist with positive syntactic entropy. Second, sparsity plus antitone density forces a unique finite crossing at every admissible level. Third, the crossing argument needs only an exponential upper bound, not exact formulas for $P(n)$. Fourth, a fixed entropy parameter controls a geometric successive ratio.

Several stronger claims do not follow.

A power law for raw theorem lengths does not follow from exponential word growth. A universal critical index does not survive arbitrary recoding. Abstract incompleteness does not determine a numerical threshold. Incompleteness concerns the existence of statements not derivable within suitable systems; it does not specify the counting rate $P(n)$, establish antitonicity of $\rho(n)$, choose $\varepsilon$, or canonically measure length.

Encoding dependence is unavoidable at the present level. Adding syntactic padding can move lengths and distort finite crossings. Even efficiently equivalent encodings require a comparison theorem before their thresholds can be related.

The antitone hypothesis is also substantive. A cumulative numerator may jump when a new proof schema becomes available, causing temporary increases in density. Exponential sparsity still guarantees convergence to zero but permits finite oscillations. Smoothed observables or transition windows may be more robust for empirical systems.

Finally, ambient entropy is not a Hausdorff dimension in the full geometric sense unless a metric and limiting construction are specified. It is an exponential growth rate. Relations to fractal dimensions require additional definitions and hypotheses.

## 10. Future research

A first direction is quasi-invariance under efficient recoding. If two prefix-free encodings translate with additive overhead at most $b$, their length balls are shifted by at most $b$. After correcting for alphabet entropies, one may conjecture that corresponding level-critical indices differ by a controlled amount.

A second direction is the treatment of oscillation. For cumulative derivability counts that are submultiplicative up to polynomial factors, logarithmic smoothing may yield eventual antitonicity or at least a transition window whose width is bounded independently of the cutoff.

A third direction is a dimension spectrum. Partitioning derivable statements by proof-theoretic complexity and assigning each stratum an entropy growth rate could distinguish several lower-dimensional mechanisms hidden by the single limit $\rho(n)\to0$. Union and intersection laws would then become central questions.

A fourth direction is the derivation of power laws from mixtures. If geometric regimes with decay parameter $\lambda$ are mixed using a density proportional to a power of $\lambda$ near zero, the aggregate may have a regularly varying tail. A rigorous theory would identify sufficient conditions and prove converse results under Tauberian regularity assumptions.

## 11. Conclusion

Counted proof spaces admit a precise but conditional phase-transition theory. The ambient language over $k\ge2$ symbols has entropy density tending to $\log k$. Any distinguished family bounded by $Ca^n$ with $a<k$ has density tending to zero. Together these facts yield the limiting phase vector $\bigl(0,\log k\bigr)$, expressing derivational sparsity amid syntactic abundance.

When density is antitone, every positive level below the initial density has a unique critical index, with an exact before-and-after classification. Without antitonicity, convergence gives eventual sparsity but not a unique crossing. In the homogeneous length model, entropy produces a constant geometric ratio $1/k$, not a power law.

These distinctions replace a broad metaphor with specific mathematical statements. They identify which assumptions create a sharp threshold, which observable captures ambient growth, and which proposed consequences require new mechanisms. The result is not a universal Gödel threshold, but a reusable framework for asking when a counted structured family changes phase relative to an exponentially expanding language.