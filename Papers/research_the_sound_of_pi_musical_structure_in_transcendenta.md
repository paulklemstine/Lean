# Cyclic Autocorrelation, Interval Energy, and Fourier Reconstruction in Finite Digit Melodies

## Abstract

Mapping the digits of a real number to pitches produces a finite numerical signal whose apparent musical structure can be studied by standard methods of cyclic signal analysis. This paper establishes a model-independent foundation for such studies. For a real signal $s$ on a cyclic index set of size $n$, we define its lag-$k$ autocorrelation $C_s(k)$, total energy $E(s)$, and squared interval energy $D_s(k)$. The main identity is

$$
2C_s(k)=2E(s)-D_s(k).
$$

Consequently, autocorrelation is bounded above by zero-lag energy, and equality holds precisely when the signal is invariant under the corresponding cyclic shift. Thus a large finite-sample correlation is exactly a small squared shift cost; by itself it is not evidence for a privileged musical interval or an arithmetic property of the number supplying the digits. We also show that, whenever the discrete Fourier transform is invertible, Fourier coordinates determine the signal and hence its complete cyclic autocorrelation function. We distinguish temporal lag from pitch interval, explain why irrationality imposes no sign condition on finite-prefix correlations, and give reproducible algorithms for autocorrelation, interval energy, equality testing, Fourier reconstruction checks, and controlled empirical studies of decimal expansions.

## 1. Introduction

A decimal expansion can be turned into sound by assigning a pitch or frequency to each digit. For example, one may map the digits $0,1,\ldots,9$ to ten consecutive chromatic pitches or to frequencies of the form

$$
f_d=220\cdot 2^{d/12}\ \text{Hz}.
$$

The initial digits of $\pi$, $e$, or $\sqrt2$ then become a melody. This construction is mathematically legitimate and artistically flexible, but interpretations of the resulting patterns require care. Three notions are often conflated:

1. a **temporal lag**, the displacement between positions in a sequence;
2. a **pitch interval**, the difference between pitch values;
3. an **arithmetic property**, such as irrationality, transcendence, or restrictions on continued fractions.

A peak at temporal lag $12$ compares notes twelve time steps apart. It does not count octave intervals, which require a pitch difference of twelve semitones. Likewise, the irrationality of a number excludes eventual periodicity of its infinite decimal expansion but supplies no predetermined sign or significance level for a statistic computed from a finite prefix.

The purpose of this paper is to isolate the exact deterministic content of finite cyclic autocorrelation. The central result is a polarization identity equating autocorrelation with total energy minus half the squared discrepancy from a shift. It gives a sharp bound, a complete equality condition, and an immediate geometric interpretation. The result applies to arbitrary finite real signals; decimal digits are one possible source of data, not an additional hypothesis.

A second result connects this time-domain description with Fourier reconstruction. In any algebraic setting where the length-$n$ discrete Fourier transform has a valid inverse, the Fourier coefficients determine the signal, and therefore determine every cyclic autocorrelation. This establishes a structural bridge between lag statistics and spectral coordinates without asserting that any particular constant possesses an exceptional spectrum.

The paper is organized as follows. Section 2 defines digit melodies and cyclic statistics. Section 3 proves translation invariance of energy and the main identity. Section 4 derives the sharp upper bound and equality criterion. Section 5 develops the Fourier determination result. Section 6 separates temporal and pitch statistics. Section 7 discusses finite-prefix inference, and Section 8 presents algorithms and examples. Sections 9–11 cover applications, limitations, and future directions.

## 2. Signals, shifts, and digit melodies

### 2.1 Finite cyclic signals

Fix a positive integer $n$. Let $\mathbb Z/n\mathbb Z$ denote the cyclic set of indices, represented by $0,1,\ldots,n-1$ with addition modulo $n$.

**Definition 2.1 (finite cyclic signal).** A finite cyclic real signal of length $n$ is a function

$$
s:\mathbb Z/n\mathbb Z\to\mathbb R.
$$

We write its values as $s(0),\ldots,s(n-1)$. The cyclic model makes every lag comparable over exactly $n$ ordered pairs. If an application should not connect the last sample back to the first, a noncyclic statistic must instead be used; the theorems below concern the cyclic convention.

**Definition 2.2 (cyclic shift).** For $k\in\mathbb Z/n\mathbb Z$, the lag-$k$ shift $T_k s$ is

$$
(T_k s)(i)=s(i+k).
$$

The addition in the argument is modulo $n$. The family of shifts satisfies $T_0s=s$ and $T_j(T_ks)=T_{j+k}s$.

### 2.2 Encodings of decimal digits

Let $d_0,\ldots,d_{n-1}\in\{0,\ldots,9\}$ be a decimal prefix. An encoding is a map $g:\{0,\ldots,9\}\to\mathbb R$, producing the signal $s(i)=g(d_i)$.

Several encodings answer different questions. The direct digit encoding uses $g(d)=d$. A semitone encoding may also use $g(d)=d$, interpreted as pitch displacement rather than raw magnitude. A frequency encoding uses $g(d)=220\cdot 2^{d/12}$. A centered signal subtracts the empirical mean

$$
\bar s=\frac1n\sum_{i=0}^{n-1}s(i),\qquad s_c(i)=s(i)-\bar s.
$$

Centering is important when correlation is intended to measure fluctuation rather than a positive baseline. All deterministic results below hold equally for raw, centered, pitch-number, or frequency-valued signals.

### 2.3 Three energy quantities

**Definition 2.3 (cyclic autocorrelation).** The unnormalized cyclic autocorrelation of $s$ at lag $k$ is

$$
C_s(k)=\sum_{i=0}^{n-1}s(i)(T_ks)(i)
      =\sum_{i=0}^{n-1}s(i)s(i+k).
$$

**Definition 2.4 (signal energy).** The total squared amplitude is

$$
E(s)=\sum_{i=0}^{n-1}s(i)^2.
$$

In particular, $C_s(0)=E(s)$.

**Definition 2.5 (interval energy).** The squared cost of displacement by lag $k$ is

$$
D_s(k)=\sum_{i=0}^{n-1}\bigl(s(i)-(T_ks)(i)\bigr)^2
      =\sum_{i=0}^{n-1}\bigl(s(i)-s(i+k)\bigr)^2.
$$

The term “interval energy” here denotes a temporal shift cost. It is not a histogram of musical pitch intervals.

## 3. The energy identity

The main argument rests on the fact that cyclic translation permutes the index set.

**Lemma 3.1 (shift invariance of signal energy).** For every finite cyclic real signal $s$ and every lag $k$,

$$
E(T_ks)=E(s).
$$

**Proof sketch.** By definition,

$$
E(T_ks)=\sum_{i=0}^{n-1}s(i+k)^2.
$$

The map $i\mapsto i+k$ is a bijection of $\mathbb Z/n\mathbb Z$. Reindexing the finite sum therefore yields $\sum_i s(i)^2=E(s)$. $\square$

**Theorem 3.2 (Autocorrelation–Interval Energy Identity).** For every finite cyclic real signal $s$ and every lag $k$,

$$
2C_s(k)=2E(s)-D_s(k).
$$

Equivalently,

$$
C_s(k)=E(s)-\frac12D_s(k).
$$

**Proof sketch.** Expand the square at each index:

$$
\bigl(s(i)-s(i+k)\bigr)^2
=s(i)^2+s(i+k)^2-2s(i)s(i+k).
$$

Summing gives

$$
D_s(k)=E(s)+E(T_ks)-2C_s(k).
$$

Lemma 3.1 identifies the two energy terms, giving $D_s(k)=2E(s)-2C_s(k)$. Rearrangement proves both displayed forms. $\square$

The theorem is a finite-dimensional polarization identity. If signals are viewed as vectors in $\mathbb R^n$ with inner product $\langle x,y\rangle=\sum_i x(i)y(i)$, then

$$
C_s(k)=\langle s,T_ks\rangle,
\qquad
D_s(k)=\|s-T_ks\|_2^2.
$$

Because $T_k$ is norm-preserving, the usual relation

$$
\|x-y\|_2^2=\|x\|_2^2+\|y\|_2^2-2\langle x,y\rangle
$$

reduces exactly to Theorem 3.2.

### 3.1 Interpretation

For fixed $s$, the quantity $E(s)$ does not depend on $k$. Therefore ranking lags by descending autocorrelation is identical to ranking them by ascending interval energy. A correlation peak at $k$ is precisely a low-cost approximate repetition after $k$ time steps. No further arithmetic conclusion is contained in the identity.

The identity also supplies an implementation check. Independently computed arrays should satisfy

$$
2C_s(k)+D_s(k)=2E(s)
$$

up to numerical roundoff for every lag.

## 4. Sharp bounds and equality

**Theorem 4.1 (Sharp Autocorrelation Bound).** For every finite cyclic real signal $s$ and every lag $k$,

$$
C_s(k)\le E(s).
$$

**Proof sketch.** Every summand defining $D_s(k)$ is a square, so $D_s(k)\ge0$. Theorem 3.2 gives

$$
C_s(k)=E(s)-\frac12D_s(k)\le E(s).
$$

The bound is sharp because equality always holds at lag $0$. $\square$

This upper bound is one-sided. Autocorrelation may be negative. A complementary estimate $|C_s(k)|\le E(s)$ follows from Cauchy–Schwarz and shift invariance, but the exact identity is stronger for the upper boundary because it characterizes the defect $E(s)-C_s(k)$ as a sum of squares.

**Theorem 4.2 (Shift-Invariance Equality Criterion).** For every finite cyclic real signal $s$ and every lag $k$, the following conditions are equivalent:

1. $C_s(k)=E(s)$;
2. $D_s(k)=0$;
3. $T_ks=s$, meaning $s(i+k)=s(i)$ for every $i$.

**Proof sketch.** Theorem 3.2 shows that the first condition is equivalent to $D_s(k)=0$. Since $D_s(k)$ is a finite sum of nonnegative squares, it vanishes exactly when every difference $s(i)-s(i+k)$ is zero. This is precisely $T_ks=s$. $\square$

The equality condition can be described by cycle structure. Let $g=\gcd(n,k)$. The shift $i\mapsto i+k$ partitions the indices into $g$ cycles. A signal is fixed by this shift exactly when it is constant on each cycle. Thus maximal correlation at a nonzero lag need not force a globally constant signal, but it forces a cyclic repetition compatible with $k$.

**Corollary 4.3 (strict inequality without shift symmetry).** If there exists an index $i$ such that $s(i+k)\ne s(i)$, then

$$
C_s(k)<E(s).
$$

**Proof sketch.** At least one summand in $D_s(k)$ is then strictly positive, while all others are nonnegative. Hence $D_s(k)>0$, and Theorem 3.2 gives strict inequality. $\square$

**Corollary 4.4 (quantitative stability).** If

$$
C_s(k)\ge E(s)-\varepsilon
$$

for some $\varepsilon\ge0$, then

$$
\|s-T_ks\|_2^2=D_s(k)\le2\varepsilon.
$$

Conversely, $D_s(k)\le2\varepsilon$ implies $C_s(k)\ge E(s)-\varepsilon$.

**Proof sketch.** Both implications are immediate rearrangements of Theorem 3.2. $\square$

This stability statement is deterministic: closeness to the upper ceiling is equivalent to closeness to shift invariance in squared Euclidean distance. It does not by itself define statistical significance.

## 5. Fourier determination of autocorrelation

### 5.1 Algebraic Fourier coordinates

Let $F$ be a field, let $n$ be positive, and let $\omega\in F$ be a primitive $n$th root of unity. Assume that the field element represented by $n$ is nonzero, so division by $n$ is permitted. For a signal $v:\mathbb Z/n\mathbb Z\to F$, define its discrete Fourier transform by a conventional choice such as

$$
\widehat v(r)=\sum_{j=0}^{n-1}v(j)\omega^{-rj}.
$$

The corresponding inverse is

$$
v(j)=\frac1n\sum_{r=0}^{n-1}\widehat v(r)\omega^{rj}.
$$

The signs may be reversed by convention without affecting the determination result.

**Theorem 5.1 (Fourier Determination of Cyclic Autocorrelation).** Let $v,w:\mathbb Z/n\mathbb Z\to F$ be two signals. Suppose $F$ contains a primitive $n$th root of unity and $n$ is nonzero in $F$, so that Fourier inversion holds. If

$$
\widehat v(r)=\widehat w(r)
$$

for every frequency $r$, then for every lag $k$,

$$
\sum_{i=0}^{n-1}v(i)v(i+k)
=
\sum_{i=0}^{n-1}w(i)w(i+k).
$$

**Proof sketch.** Apply the inverse Fourier formula to the common coefficient vector. It reconstructs $v(j)$ and $w(j)$ by the same expression for every $j$, hence $v=w$. Substitution into the two autocorrelation sums gives equality at every lag. $\square$

The theorem asserts determination, not a claim that autocorrelation uniquely determines the signal. In general, phase ambiguities can cause distinct signals to share related correlation information. Complete Fourier coordinates retain sufficient information because inversion reconstructs the entire signal.

### 5.2 Spectral interpretation of shifts

For complex-valued Fourier analysis, shifting multiplies the $r$th Fourier coefficient by a unit phase:

$$
\widehat{T_ks}(r)=\omega^{rk}\widehat s(r)
$$

up to the sign convention. Therefore $T_ks\approx s$ when the signal’s Fourier energy is concentrated on frequencies for which $\omega^{rk}\approx1$. Combined with Theorem 3.2, this links three descriptions:

- high autocorrelation $C_s(k)$;
- low interval energy $D_s(k)$;
- spectral concentration on modes nearly stabilized by the lag-$k$ phase.

A quantitative two-sided spectral stability theorem is a natural extension, but the basic determination statement already guarantees that complete Fourier data fixes all lag statistics.

## 6. Temporal lag versus musical interval

Suppose decimal digits are interpreted as semitone labels $0$ through $9$. A temporal lag $k$ concerns the pair of sequence positions $(i,i+k)$. A pitch interval concerns a difference in values, for example

$$
\Delta(i,j)=|s(i)-s(j)|.
$$

An octave in twelve-tone equal temperament is a pitch separation of $12$ semitones. Under the ten-label map $s(i)\in\{0,\ldots,9\}$,

$$
|s(i)-s(j)|\le9,
$$

so octave pairs are impossible. Nevertheless, temporal lag $12$ is well-defined whenever the sequence is long enough. Its autocorrelation measures twelve-step alignment, not octave frequency.

**Proposition 6.1 (absence of octave intervals under a ten-semitone digit map).** If each digit is assigned its numerical value in semitones, then no two encoded digits differ by $12$ semitones.

**Proof sketch.** Both values lie between $0$ and $9$, so their absolute difference is at most $9<12$. $\square$

A pitch-interval histogram should therefore be defined independently. For an integer interval $q\ge0$, one possible all-pairs count is

$$
H_s(q)=\#\{(i,j):0\le i<j<n,\ |s(i)-s(j)|=q\}.
$$

A local version may restrict $j-i$ to selected temporal separations. In either case, the temporal and pitch coordinates remain explicit.

## 7. What irrationality does and does not imply

A real number has an eventually periodic decimal expansion if and only if it is rational. Hence an irrational number such as $\pi$, $e$, or $\sqrt2$ cannot have a decimal tail that repeats forever. This fact is sometimes overextended.

A statistic of the first $n$ digits depends only on that finite word. Irrationality is a property of the infinite continuation. For any finite decimal word, there exist rational numbers and irrational numbers beginning with that word. Therefore irrationality alone cannot determine the sign of a finite-prefix autocorrelation or identify a preferred finite lag.

The same caution applies to transcendence. Transcendence is stronger than irrationality, but it does not by itself provide a finite-sample null distribution for decimal digits. Likewise, continued-fraction coefficients and decimal digits are generated by different symbolic dynamical systems. Any proposed relationship between bounded partial quotients and decimal “consonance” requires a controlled ensemble and a predeclared consonance statistic.

Finite evidence can still be meaningful when the inferential protocol is explicit. A study should specify:

1. the constants and prefix lengths before inspection;
2. the digit-to-signal encoding;
3. whether and how the signal is centered or normalized;
4. cyclic or noncyclic boundary treatment;
5. the lags and pitch intervals tested;
6. a null distribution, such as exact permutation conditional on observed digit counts;
7. correction for multiple testing across lags and constants.

The deterministic theorems then identify exactly what each observed autocorrelation means, while the statistical layer assesses whether the observation is unusual under the chosen null.

## 8. Algorithms and numerical examples

### 8.1 Direct cyclic analysis

Given a length-$n$ vector and a set of $m$ lags, direct computation takes $O(mn)$ arithmetic operations and $O(m)$ output memory. For all $n$ lags, the cost is $O(n^2)$. The procedure is:

1. compute $E=\sum_i s(i)^2$;
2. for each lag $k$, compute $C(k)=\sum_i s(i)s(i+k)$;
3. compute $D(k)=\sum_i(s(i)-s(i+k))^2$;
4. verify $2C(k)=2E-D(k)$ within a floating-point tolerance.

For long signals, all correlations can be accelerated by fast Fourier transforms to $O(n\log n)$, provided the correlation convention and conjugation are handled consistently.

### 8.2 Exact periodic example

Let

$$
s=(1,2,1,2).
$$

Its energy is

$$
E(s)=1^2+2^2+1^2+2^2=10.
$$

At lag $2$, the shifted signal equals $s$, so $D_s(2)=0$ and $C_s(2)=10$. At lag $1$, the shift is $(2,1,2,1)$, giving

$$
C_s(1)=1\cdot2+2\cdot1+1\cdot2+2\cdot1=8.
$$

The interval energy is

$$
D_s(1)=(-1)^2+1^2+(-1)^2+1^2=4,
$$

and indeed $C_s(1)=10-4/2=8$.

### 8.3 Nonperiodic finite example

Let

$$
t=(3,1,4,1,5,9,2,6),
$$

an initial digit block of $\pi$. Its energy is

$$
E(t)=3^2+1^2+4^2+1^2+5^2+9^2+2^2+6^2=173.
$$

For any selected cyclic lag, the two independently computed quantities $C_t(k)$ and $D_t(k)$ satisfy the exact identity. This is a deterministic statement about the eight-number vector. It does not establish a population-level preference of $\pi$.

### 8.4 Pitch-interval counting

For semitone labels $0$ through $9$, a histogram over absolute differences has bins only from $0$ through $9$. The count in bin $12$ is identically zero. If frequencies $220\cdot2^{d/12}$ are used instead, octave equivalence still corresponds to digit differences of $12$, which remain unavailable within a single ten-digit alphabet unless the encoding is extended or octave registers are assigned separately.

## 9. Applications

The theory applies wherever a finite cyclic signal is compared with its translates.

**Digit sonification.** It provides an exact interpretation of correlation peaks in melodies derived from decimal or other radix expansions.

**Rhythm and loop detection.** A near-maximal lag correlation is equivalent to low squared discrepancy from repeating the loop at that lag. The equality theorem detects exact cyclic repetition.

**Texture and image analysis.** Rows, contours, or cyclic boundary samples can be analyzed through the same shift-energy identity.

**Quality assurance.** Computing both sides of the identity catches indexing, wrapping, or normalization mistakes in numerical code.

**Spectral pipelines.** If a signal is stored or transmitted through complete invertible Fourier coordinates, all cyclic autocorrelations are determined without ambiguity because the signal itself can be reconstructed.

These applications share the same mathematical core. None requires the signal values to be digits or pitches.

## 10. Discussion and limitations

The principal strength of the framework is its universality. The main identity assumes only a finite real signal and cyclic indexing. Its equality criterion is exact, and its defect term is directly interpretable as squared distance from shift invariance.

That universality also marks the limit of what the result can say. Because it holds for every signal, it cannot by itself distinguish $\pi$ from a random sequence or from a designed musical loop. Such distinctions require data and a statistical model. Positive uncentered autocorrelation may be dominated by a positive mean; centering changes the question and should be declared. Cyclic wrapping introduces pairs across the endpoint that a noncyclic analysis would omit. Frequency encodings distort equal digit steps multiplicatively, while pitch-number encodings preserve semitone differences linearly.

The phrase “statistically significant” is incomplete without a null hypothesis and a correction policy. Testing thirteen lags for each of several constants creates multiple opportunities for a chance peak. Exact permutation tests conditional on observed symbol counts provide one transparent finite-prefix baseline. Other models may be appropriate, but they must be stated independently of the observed peak.

Finally, musical consonance is not identical to numerical autocorrelation. Consonance depends on pitch ratios, tuning, register, simultaneity, timbre, cultural context, and perceptual organization. A scalar lag statistic may support an aspect of musical analysis, but it does not exhaust it.

## 11. Future research

Several concrete programs follow from the present framework.

First, fixed prefixes of $\pi$, $e$, and $\sqrt2$ can be subjected to exact permutation tests for centered autocorrelations at lags $1$ through $12$, with family-wise error controlled across all tests. This would determine whether advertised peaks survive a predeclared finite-sample analysis.

Second, temporal-lag statistics should be paired with an independent pitch-interval histogram. Under a ten-semitone digit map, octave counts are structurally zero, making the separation especially clear.

Third, the time-domain identity and Fourier shift law invite a quantitative theorem characterizing exceptional autocorrelation through concentration of spectral power on nearly shift-invariant phases, uniformly in signal length.

Fourth, proposed links between continued fractions and decimal consonance can be tested on controlled ensembles. Numbers drawn from bounded-partial-quotient sets should be compared with matched controls after conditioning on prefix length and digit frequencies.

Fifth, finite-prefix obstruction results can clarify the logical limits of inference: prescribed finite decimal behavior can be shared by numbers of very different arithmetic types, so no finite statistic alone can certify transcendence or a universal arithmetic law.

## 12. Conclusion

For a finite cyclic melody, autocorrelation and squared shift cost are complementary quantities:

$$
C_s(k)=E(s)-\frac12D_s(k).
$$

This identity yields the sharp bound $C_s(k)\le E(s)$ and shows that equality occurs exactly at shifts fixing the signal. Under invertible Fourier analysis, the complete spectrum determines the signal and all its cyclic correlations. Together, these results give a rigorous language for repetition in digit melodies.

The framework supports creative sonification while enforcing conceptual separation. Temporal lag is not pitch interval; finite-prefix behavior is not a consequence of irrationality; and deterministic correlation is not statistical significance. Once these distinctions are observed, experiments with the digits of mathematical constants can be both imaginative and mathematically precise.