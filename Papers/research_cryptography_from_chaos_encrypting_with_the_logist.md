# Structural Cryptanalysis of the Parameter-Four Logistic Map

## Abstract

The parameter-four logistic map $f(x)=4x(1-x)$ is often presented as a candidate source of cryptographic pseudorandomness because typical nearby trajectories separate exponentially and because the degree of the $n$th iterate is $2^n$. We show that neither observation supports one-wayness. The map has a universal reflection collision, $f(1-x)=f(x)$, so reflected seeds generate identical orbit suffixes after one update. Every real target $y\le 1$ has the explicit preimage $(1-\sqrt{1-y})/2$, replacing generic high-degree inversion by a sequence of quadratic inverse steps. Under the coordinate $x=\sin^2\theta$, the dynamics obey the exact semiconjugacy $f(\sin^2\theta)=\sin^2(2\theta)$ and the closed iterate formula $f^n(\sin^2\theta)=\sin^2(2^n\theta)$. Exceptional seeds, including $0$ and $1/2$, disprove claims of seed-independent limiting behavior and universal long periods. Finally, every $p$-bit deterministic realization repeats within its first $2^p+1$ visited states, an upper bound on first collision rather than a lower bound on period. These results establish a structural cryptanalytic obstruction: chaotic sensitivity, algebraic degree, finite statistical tests, and large state spaces do not by themselves imply cryptographic pseudorandomness.

## 1. Introduction

Consider the logistic recurrence

$$
x_{n+1}=4x_n(1-x_n), \qquad x_0\in[0,1].
$$

At parameter $4$, typical trajectories exhibit sensitive dependence on initial conditions. A perturbation in a typical initial state grows exponentially in an average logarithmic sense, with Lyapunov exponent $\log 2$. The orbit also has a well-known invariant probability density

$$
\rho(x)=\frac{1}{\pi\sqrt{x(1-x)}}
$$

on the open unit interval. These properties make the recurrence appear attractive as a keystream generator: choose a secret seed, discard an initial prefix, extract bits from later states, and combine the resulting stream with a plaintext by exclusive-or.

A cryptographic claim, however, requires more than irregular plots or favorable aggregate statistics. A deterministic generator should resist efficient prediction and inversion when its design is public. Equivalent keys, exact symmetries, special orbits, coordinate transformations, numerical representations, and extraction functions must all be included in the analysis.

This paper gives an exact structural analysis of the parameter-four map. Its conclusions are negative for the simplest logistic-map cipher but constructive for the study of chaos-based generators. The main results are:

1. reflection about $1/2$ produces universal seed collisions;
2. every nonempty orbit suffix is identical for a reflected pair;
3. one-step inversion has explicit square-root branches;
4. the map is semiconjugate to angle doubling and therefore has a closed iterate formula;
5. short exceptional orbits invalidate universal ergodicity and period claims; and
6. finite state cardinality provides only an upper bound on first repetition.

The central distinction is between **dynamical instability** and **computational one-wayness**. Forward sensitivity says that nearby inputs can have distant future states. One-wayness says that, given an output, recovering a compatible input is computationally difficult. The former does not entail the latter.

## 2. Definitions and cryptographic model

### 2.1 The logistic map and its iterates

**Definition 2.1 (Parameter-four logistic map).** For a real state $x$, define

$$
f(x)=4x(1-x).
$$

On $[0,1]$, the map takes values in $[0,1]$. Define $f^0(x)=x$ and recursively

$$
f^{n+1}(x)=f(f^n(x)).
$$

The degree of $f^n$, viewed as a polynomial, is $2^n$ for $n\ge 0$. Degree growth describes expanded symbolic expressions, but does not by itself determine the complexity of evaluating or inverting the function.

### 2.2 A logistic-map stream cipher

**Definition 2.2 (Orbit-suffix keystream).** Given a seed $x_0$, a positive starting index $s$, and a requested length $L$, the real-valued orbit suffix is

$$
K_{s,L}(x_0)=\bigl(f^s(x_0),f^{s+1}(x_0),\ldots,f^{s+L-1}(x_0)\bigr).
$$

A practical generator applies a deterministic quantizer or bit extractor $Q$ to these values. The extracted stream may be written

$$
B_{s,L}(x_0)=\bigl(Q(f^s(x_0)),\ldots,Q(f^{s+L-1}(x_0))\bigr).
$$

A message bit string $M$ is encrypted as $C=M\oplus B_{s,L}(x_0)$. Decryption repeats the generator and computes $M=C\oplus B_{s,L}(x_0)$.

This definition deliberately separates exact dynamics from implementation. In exact arithmetic the state is real. In software, the state belongs to a finite set determined by a number format, operation order, and rounding rule. Security conclusions about one model do not automatically transfer to the other.

### 2.3 Security properties under consideration

Four properties are often conflated:

- **Sensitivity:** nearby seeds may generate separated future states.
- **Statistical quality:** selected finite-sample statistics resemble those of a chosen random model.
- **One-wayness:** recovering a suitable predecessor or key from observed output is computationally difficult.
- **Cryptographic pseudorandomness:** no feasible adversary can distinguish the output from an ideal random source with non-negligible advantage under a specified experiment.

Sensitivity is a dynamical property. Statistical quality depends on tests and sample sizes. One-wayness and pseudorandomness are adversarial computational properties. None follows automatically from another.

## 3. Reflection symmetry and equivalent seeds

The logistic parabola folds the unit interval at $1/2$. That fold yields an exact family of collisions.

**Theorem 3.1 (Reflection Collision Theorem).** For every real number $x$,

$$
f(1-x)=f(x).
$$

**Proof sketch.** Direct expansion gives

$$
f(1-x)=4(1-x)(1-(1-x))=4(1-x)x=4x(1-x)=f(x).
$$

The argument uses only commutativity of multiplication, so the identity remains valid in any commutative ring. $\square$

**Corollary 3.2 (Non-injectivity).** The logistic map is not injective on $[0,1]$, on $\mathbb R$, or on any nontrivial commutative ring interpreted through the same polynomial.

**Proof sketch.** On $[0,1]$, $f(0)=f(1)=0$ while $0\ne1$. More generally, Theorem 3.1 identifies $x$ and $1-x$ whenever those elements are distinct. $\square$

The collision propagates through every later update.

**Theorem 3.3 (Permanent Merging of Reflected Orbits).** For every real $x$ and every integer $n\ge1$,

$$
f^n(1-x)=f^n(x).
$$

**Proof sketch.** The case $n=1$ is Theorem 3.1. If the states agree after $n$ updates, applying the deterministic function $f$ to both sides shows agreement after $n+1$ updates. Induction completes the argument. $\square$

**Corollary 3.4 (Finite Keystream Collision).** Let $s\ge1$ and $L\ge0$. Then

$$
K_{s,L}(x)=K_{s,L}(1-x).
$$

Consequently, for every deterministic extraction function $Q$,

$$
B_{s,L}(x)=B_{s,L}(1-x).
$$

**Proof sketch.** For each index $j$ with $0\le j<L$, the exponent $s+j$ is positive. Apply Theorem 3.3 componentwise. Applying $Q$ preserves equality. $\square$

This is an equivalent-key phenomenon. If the key is represented directly by the seed, then almost every seed has a reflected partner that generates the same stream after one update. Increasing the discarded prefix or the observed suffix does not remove the ambiguity. The collision occurs before quantization, so no bit extractor can distinguish the two trajectories afterward.

The result does not by itself recover a seed from an arbitrary stream, but it invalidates unique seed recovery and reduces the effective key space whenever reflected seeds are counted separately. More broadly, it demonstrates why key-space cardinality must be measured after quotienting by output equivalence.

## 4. Explicit inversion and the failure of the degree heuristic

The polynomial $f^n(x)$ has degree $2^n$. It is therefore tempting to frame inversion as solving an unstructured polynomial of exponentially large degree. The map’s special form makes that framing inappropriate.

**Theorem 4.1 (Explicit Lower-Branch Preimage).** For every real target $y\le1$, define

$$
g_-(y)=\frac{1-\sqrt{1-y}}{2}.
$$

Then

$$
f(g_-(y))=y.
$$

For $0\le y\le1$, the value $g_-(y)$ belongs to $[0,1/2]$.

**Proof sketch.** Put $a=\sqrt{1-y}$. Since $y\le1$, $a^2=1-y$. Then

$$
4\left(\frac{1-a}{2}\right)\left(1-\frac{1-a}{2}\right)
=(1-a)(1+a)=1-a^2=y.
$$

The range statement follows from $0\le a\le1$ when $0\le y\le1$. $\square$

**Corollary 4.2 (Two Inverse Branches on the Unit Interval).** For $0\le y\le1$, define

$$
g_\pm(y)=\frac{1\pm\sqrt{1-y}}{2}.
$$

Both branches satisfy $f(g_\pm(y))=y$, and they obey

$$
g_+(y)=1-g_-(y).
$$

They are distinct except at the critical value $y=1$, where both equal $1/2$.

**Proof sketch.** The lower branch is covered by Theorem 4.1. The upper branch is its reflection, so Theorem 3.1 gives the same image. Equality of branches occurs precisely when $\sqrt{1-y}=0$. $\square$

**Algorithm 4.3 (Branch-Guided Ancestor Recovery).** Given a target $y_0\in[0,1]$ and a branch sequence $b_1,\ldots,b_n\in\{-,+\}$, compute

$$
y_k=g_{b_k}(y_{k-1}), \qquad 1\le k\le n.
$$

Then $f^n(y_n)=y_0$.

**Proof sketch.** Each step satisfies $f(y_k)=y_{k-1}$. Composing these equalities gives the claim. $\square$

In a unit-cost real-arithmetic model, recovering one ancestor selected by a branch sequence takes $n$ square roots and $O(n)$ arithmetic operations. Enumerating all generic depth-$n$ ancestors requires $O(2^n)$ outputs and therefore cannot take less than exponential time merely because the requested output itself is exponentially large. This output-size fact is entirely different from asserting that finding one compatible ancestor is exponentially hard.

The branch tree has exceptions. At $y=1$, the two branches merge. Endpoints, critical points, periodic points, and previously merged paths affect the number of distinct ancestors. Thus “exactly $2^n$ real preimages” is not universally valid even though the expanded polynomial has degree $2^n$ over an algebraic closure when multiplicities are counted appropriately.

## 5. Semiconjugacy to angle doubling

The logistic map’s structure becomes clearest under a trigonometric coordinate.

**Definition 5.1 (Angular observation map).** Define

$$
h(\theta)=\sin^2\theta.
$$

This map sends every real angle into $[0,1]$. It is many-to-one because it is periodic and invariant under several reflections.

**Theorem 5.2 (Angle-Doubling Semiconjugacy).** For every real $\theta$,

$$
f(h(\theta))=h(2\theta),
$$

or equivalently,

$$
f(\sin^2\theta)=\sin^2(2\theta).
$$

**Proof sketch.** Use $1-\sin^2\theta=\cos^2\theta$ and the double-angle identity:

$$
f(\sin^2\theta)
=4\sin^2\theta\cos^2\theta
=(2\sin\theta\cos\theta)^2
=\sin^2(2\theta).
$$

$\square$

The relation is a semiconjugacy rather than a conjugacy because $h$ is not injective. This non-injectivity is not a technical nuisance: it encodes the folding and collisions of the logistic map.

**Theorem 5.3 (Closed Formula for Every Iterate).** For every real $\theta$ and every integer $n\ge0$,

$$
f^n(\sin^2\theta)=\sin^2(2^n\theta).
$$

**Proof sketch.** At $n=0$, both sides equal $\sin^2\theta$. Assume the identity at $n$. Applying $f$ and then Theorem 5.2 gives

$$
f^{n+1}(\sin^2\theta)
=f(\sin^2(2^n\theta))
=\sin^2(2\cdot2^n\theta)
=\sin^2(2^{n+1}\theta).
$$

Induction proves the result. $\square$

### 5.1 Computational significance

The closed formula avoids constructing the degree-$2^n$ polynomial. In exact symbolic reasoning, the $n$th state is represented by an exponentiation and a trigonometric evaluation. In numerical work, angular reduction modulo $\pi$ may be used because $\sin^2$ has period $\pi$. Repeated modular doubling gives an $O(n)$ orbit algorithm, while binary exponentiation can form the multiplier $2^n$ in $O(\log n)$ integer multiplications before an appropriate modular-angle calculation. Precision requirements must be analyzed separately: exponential sensitivity means that fixed absolute error in the angle can strongly affect a distant state.

### 5.2 Dynamical significance

The same formula explains sensitivity. A small angular displacement $\delta$ becomes $2^n\delta$ before observation by $\sin^2$. For typical points away from derivative degeneracies, this produces exponential separation. But the angular system is also highly structured. After normalizing an angle to a unit circle, multiplication by $2$ shifts the binary expansion. Thus chaotic appearance in the observed coordinate coexists with exact shift-like dynamics in a hidden coordinate.

This coexistence refutes a common dichotomy. A system can be chaotic and algebraically transparent at the same time. Indeed, here the mechanism that creates sensitivity also provides the simplest exact description of the orbit.

## 6. Exceptional trajectories and invariant-measure claims

An invariant measure is not the same as convergence from every seed. The distinction is decisive for both dynamics and cryptographic claims.

**Theorem 6.1 (Absorbing Zero Orbit).** For every integer $n\ge0$,

$$
f^n(0)=0.
$$

**Proof sketch.** Since $f(0)=0$, repeated application leaves the state unchanged. $\square$

**Theorem 6.2 (Collapse of the Half Seed).** The seed $1/2$ follows

$$
\frac12\mapsto1\mapsto0,
$$

and therefore, for every $n\ge0$,

$$
f^{n+2}\left(\frac12\right)=0.
$$

**Proof sketch.** Direct calculation gives $f(1/2)=1$ and $f(1)=0$. Apply Theorem 6.1 thereafter. $\square$

**Corollary 6.3 (Failure of Seed-Independent Distributional Convergence).** It is false that the empirical orbit measures converge to the arcsine distribution for every seed in $[0,1]$.

**Proof sketch.** The empirical measure of the zero orbit is the point mass at $0$ for every averaging length. It cannot converge to the continuous arcsine distribution. The half seed becomes the same zero orbit after two transients and has the same limiting empirical measure. $\square$

A correct ergodic statement must quantify its seed class, typically using an almost-everywhere condition relative to a specified invariant measure. Periodic and preperiodic seeds form explicit exceptional families. Through the angular coordinate, periodicity is connected to angles whose normalized binary expansions are eventually periodic. The full sharp exceptional-set theorem requires care, but the universal claim is already disproved by the fixed and preperiodic examples above.

For cryptography, exceptional seeds matter even if they have measure zero in an ideal continuum. Keys are sampled from finite representations, not from a metaphysical uniform distribution over all real numbers. A finite encoding can overrepresent special rational or dyadic structures, and implementation rounding can create new basins leading to short cycles.

## 7. Finite-state implementations and period bounds

Every digital implementation has finitely many representable states. The resulting recurrence is a function on a finite set, regardless of whether its arithmetic is fixed-point, floating-point, or custom.

**Theorem 7.1 (Finite-State Repetition Theorem).** Let $S$ be a finite set with $N$ elements, let $F:S\to S$ be any deterministic update, and let $x\in S$. Among the $N+1$ states

$$
x,F(x),F^2(x),\ldots,F^N(x),
$$

there exist indices $0\le i<j\le N$ such that

$$
F^i(x)=F^j(x).
$$

**Proof sketch.** There are $N+1$ listed states but only $N$ possible values. The pigeonhole principle forces a repeated value. $\square$

**Corollary 7.2 ($p$-Bit State Bound).** If the complete internal state consists of $p$ bits, then some two states among the first $2^p+1$ visited states are equal.

**Proof sketch.** A $p$-bit state space has $2^p$ elements. Apply Theorem 7.1 with $N=2^p$. $\square$

Once a state repeats, determinism makes all subsequent states repeat with the same offset. Every finite orbit therefore consists of a transient tail followed by a cycle. If $i<j$ is the first suitable collision, the cycle length is $j-i$, which is at most $N$. Crucially, this is an upper bound. State-space size supplies no nontrivial universal lower bound on period.

The parameter-four logistic recurrence already suggests short behavior: encodings containing an exact zero have a fixed point, and encodings that evaluate $1/2\mapsto1\mapsto0$ exactly contain a rapidly collapsing trajectory. Other rounding rules may create additional cycles and merge distinct real trajectories. Therefore a claim such as “$p$ bits imply period at least $2^p$” reverses the conclusion justified by finiteness.

**Algorithm 7.3 (Cycle Decomposition by First-Occurrence Table).** Starting from a finite encoded state $x$, store the first index at which each state appears. Repeatedly apply $F$ until the current state has appeared before. If its first index is $\mu$ and the current index is $t$, then the transient length is $\mu$ and the cycle length is $t-\mu$.

The algorithm uses $O(\mu+\lambda)$ update steps and memory, where $\lambda$ is the cycle length. Memory-reduced algorithms such as tortoise-and-hare cycle finding can recover the same two quantities in $O(\mu+\lambda)$ time and $O(1)$ state memory. Neither method can infer a period spectrum without specifying the exact finite update function.

## 8. Statistical testing versus cryptographic security

A statistical battery samples finitely many properties of finitely many outputs. It may test monobit frequency, run lengths, block frequencies, spectral features, or correlations. Passing such tests is compatible with serious structural weaknesses.

First, Theorem 3.3 creates equivalent keys even if the common stream has ideal-looking statistics. A single-stream test does not ask whether another key generates exactly the same output. Second, Theorem 5.3 exposes an angular relation that generic tests may not target. Third, explicit inverse branches exist regardless of observed frequency balance. Finally, finite tests always leave untested distinguishers.

Cryptographic pseudorandomness must be defined through an adversarial experiment. A typical formulation compares access to a generator’s output against access to an ideal random source and measures the advantage of a computationally bounded distinguisher. A next-bit formulation asks whether an adversary, after observing a prefix, can predict the next bit with advantage over one half. The exact result depends on the seed distribution, extraction function, precision model, and attacker’s observations.

Accordingly, passing a standard battery can be a useful necessary diagnostic for some applications, but it is not a sufficient security theorem. Conversely, failure of a test can reveal a defect without identifying its structural cause. Statistical evaluation and mathematical cryptanalysis should be treated as complementary, not interchangeable.

## 9. Algorithms and numerical demonstrations

Three computational procedures illustrate the exact results.

### 9.1 Paired-orbit collision demonstration

Choose $x\in[0,1]$ and form $1-x$. Iterate both in parallel. In ideal real arithmetic, the states agree from the first update onward by Theorem 3.3. In binary floating-point, the initial computation may differ at the last few bits because the expression $1-(1-x)$ need not reproduce $x$ exactly and operation rounding depends on representation. This discrepancy illustrates a modeling issue rather than a failure of the real identity. Using exact rational arithmetic shows exact merging whenever all operations remain represented as rationals.

The algorithm takes $O(L)$ arithmetic operations for a length-$L$ comparison and constant memory if values are streamed.

### 9.2 Inverse-tree construction

For a target $y\in[0,1]$, apply both inverse branches $g_-$ and $g_+$, deduplicate at the critical point, and repeat to a chosen depth. Every reported depth-$n$ value maps forward to $y$ in $n$ updates. A breadth-first implementation takes $O(A_n)$ storage and arithmetic operations proportional to the number $A_n$ of generated ancestors, with $A_n\le2^n$. The exponential cost reflects enumeration of an exponentially large set, not difficulty in producing one selected branch path.

### 9.3 Exact versus angular orbit evaluation

Given $x\in[0,1]$, select the principal angle

$$
\theta=\arcsin\sqrt{x}.
$$

Compare repeated logistic updates with

$$
\sin^2(2^n\theta).
$$

In exact mathematics the values coincide. In finite floating-point arithmetic, errors eventually grow because both methods round differently and the dynamics amplify phase discrepancies. This is a useful numerical experiment: it simultaneously confirms the structural formula at modest depths and demonstrates why sensitivity creates reproducibility problems rather than automatic security.

## 10. Security implications

The results support the following conclusions for a cipher whose security is claimed solely from the parameter-four logistic recurrence.

**Equivalent keys.** Reflected seeds $x$ and $1-x$ yield identical streams after one update. A key specification that treats them as distinct overstates the effective key space.

**Structured inversion.** One predecessor is obtained with one square root, and a selected depth-$n$ predecessor is obtained through $n$ branch choices. Polynomial degree is therefore an invalid standalone hardness argument.

**Closed-form evolution.** The orbit has an exact angular description. Any extraction rule should be analyzed in that coordinate, especially when bits correspond to interval partitions that may become shift-like under angle doubling.

**Weak exceptional keys.** Zero is fixed and $1/2$ collapses to zero after two steps. A secure key schedule would at least need to exclude weak states and their finite-precision basins, but exclusions do not remove the reflection or inversion structure.

**No period guarantee from width.** A $p$-bit state space guarantees a collision within $2^p+1$ observations. It does not guarantee a cycle near $2^p$. Period claims must be established for the exact rounding-dependent functional graph.

**Tests are not reductions.** Statistical test performance cannot prove next-bit unpredictability, key recovery hardness, or indistinguishability.

These findings do not claim that every construction containing a logistic map is insecure. A larger system might derive security from an independently secure primitive. In that case, however, the security comes from the complete construction and its reduction or analysis, not from chaos as such.

## 11. Discussion

The logistic map is an unusually instructive case because its chaotic and cryptanalytic properties arise from one structure. The angular doubling map expands differences by a factor of two while remaining exactly describable. The observation $\sin^2\theta$ folds angular states together, producing reflection collisions. The invariant arcsine density is naturally related to transporting a uniform angular distribution through this observation, while exceptional angular points generate periodic and preperiodic state orbits.

This unified picture suggests a hierarchy for analyzing deterministic generators:

1. identify exact symmetries and quotient equivalent keys;
2. search for conjugacies, semiconjugacies, recurrences, and closed forms;
3. derive explicit forward and inverse algorithms;
4. classify critical, periodic, and preperiodic states;
5. specify the finite arithmetic and analyze its functional graph;
6. define extraction and adversarial experiments precisely; and
7. use statistical tests only after structural analysis.

The hierarchy prevents several category errors. A positive Lyapunov exponent measures average local expansion, not computational hardness. A degree statement measures an expanded polynomial, not the shortest algorithm. An invariant measure is a stationary distribution, not necessarily the limit from every point. A state-count bound limits maximum preperiod-plus-period, not minimum period. A finite battery assesses selected statistics, not every efficient distinguisher.

## 12. Future work

A first direction is quantified prediction. For fixed bit-extraction rules with finitely many interval boundaries, one can ask whether angle doubling yields a polynomial-time next-bit predictor with non-negligible advantage on a positive-measure seed set. The closed iterate formula identifies the correct coordinate for this analysis.

A second direction is complete inverse-tree classification. The exact number of distinct depth-$n$ real ancestors should be derived while accounting for reflection, the critical value, endpoints, periodic branches, and collisions between branch paths. The apparent degree $2^n$ counts algebraic structure differently from distinct reachable ancestors.

A third direction is the precision-specific period spectrum. For every explicit rounding rule and word size $p$, one should determine or estimate the full functional graph, including maximum, median, and distribution of cycle lengths and basin sizes. This replaces an invalid universal lower bound with a meaningful arithmetic classification.

A fourth direction is a sharp invariant-measure theorem. The strongest seed class for which empirical orbit measures converge to the arcsine law should be identified, together with a precise description of periodic, preperiodic, and other exceptional seeds. Angle doubling connects this question to binary expansions and normality.

A fifth direction separates statistical quality from cryptographic indistinguishability. One can construct logistic-map streams that pass prescribed finite batteries while retaining an explicit distinguisher based on reflection, inverse branches, or angular relations. Such examples would make the logical gap operationally concrete.

## 13. Conclusion

For the parameter-four logistic map, chaos does not imply cryptographic one-wayness. Reflection produces exact seed collisions and permanently merges orbit suffixes. One-step inversion is a quadratic calculation with explicit square-root branches. The substitution $x=\sin^2\theta$ transforms the recurrence into angle doubling and yields the closed formula $f^n(\sin^2\theta)=\sin^2(2^n\theta)$. Fixed and preperiodic seeds disprove universal distribution and period claims. A $p$-bit implementation must repeat within $2^p+1$ visited states, but may repeat far sooner.

These are structural results, independent of how random a selected output sample appears. They show that sensitivity, degree growth, state-space size, and statistical testing are insufficient foundations for a security claim. The logistic map remains a rich dynamical system; its principal cryptographic value may be as a warning that apparent disorder must always be tested against exact mathematical structure.