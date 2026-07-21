# Reciprocal-Zero Harmonics: Finite Spectral Bounds, Conjugation Symmetry, and Quadratic Rationality

**Aristotle**  
**July 21, 2026**

## Abstract

We study a finite reciprocal-spectral statistic motivated by attempts to interpret number-theoretic spectra as musical harmonies. For a finite set $Z$ of complex spectral parameters, its harmonic is $H(Z)=\sum_{z\in Z}z^{-1}$. We establish three structural principles. First, if every point of $Z$ has modulus at least $\delta>0$, then $|H(Z)|\le |Z|/\delta$; consequently, every point-count bound transfers directly to a bound for the harmonic. In particular, a hypothetical estimate $|Z_n|\le C\log n/\log\log n$ yields $|H(Z_n)|\le (C/\delta)\log n/\log\log n$. Second, if $Z$ is closed under complex conjugation, then $H(Z)$ is real. Third, for distinct roots $\alpha,\beta$ with $\alpha+\beta=\ell$, $\alpha\beta=q\ne0$, the reciprocal harmonic equals $\ell/q$; hence rational quadratic coefficients produce a rational harmonic. We also diagnose two proposed small-cutoff assignments. An empty window has harmonic zero, so empty windows at cutoffs $2$ and $3$ coincide; the former cannot have value $1$, and the latter cannot be transcendental. This support-first diagnosis is essential because numerical zero data place both cutoffs below the first nontrivial Riemann-zeta zero, although applying that fact as a theorem requires a certified exclusion result. The results separate universal finite algebra from analytic hypotheses and provide exact algorithms, graph-zeta examples, and a foundation for renormalized and arithmetic extensions.

## 1. Introduction

The Riemann zeta function connects prime numbers with complex analysis through the Euler product

$$
\zeta(s)=\prod_p(1-p^{-s})^{-1},
$$

initially valid for $\operatorname{Re}(s)>1$ and continued meromorphically to the complex plane. Its nontrivial zeros form a complex spectrum whose distribution encodes deep arithmetic information. This spectral viewpoint encourages an analogy with music: one might regard each zero as a partial and a finite collection of zeros as a chord.

A particularly simple statistic is obtained by adding reciprocal spectral parameters. If a cutoff $T$ selects the nontrivial zeros $\rho$ satisfying $|\operatorname{Im}\rho|\le T$, define formally

$$
H(T)=\sum_{|\operatorname{Im}\rho|\le T}\frac{1}{\rho}.
$$

For any finite window this is a well-defined complex number, with multiplicity conventions specified as part of the chosen model. The analogy has prompted stronger claims: perhaps the statistic grows slowly, perhaps rational values identify consonant intervals, and perhaps small prime cutoffs produce distinguished notes.

The purpose of this paper is to determine what follows from the finite reciprocal-sum construction itself. The answer has four parts.

1. Separation from the origin and cardinality control the magnitude of a reciprocal harmonic.
2. Conjugation symmetry forces the harmonic to be real.
3. Empty windows expose a fatal support error in proposed assignments at cutoffs $2$ and $3$.
4. Quadratic spectral factors provide an exact and nontrivial source of rational harmonics.

These conclusions distinguish unconditional finite algebra from analytic input. In particular, the bound of order $\log n/\log\log n$ is valid under a counting hypothesis of that order; it is not an unconditional zero-count theorem for the ordinary Riemann-zeta window. The classical zeta-zero count up to height $T$ is instead on the scale $T\log T$. Similarly, approximate zero tables strongly motivate empty small windows but do not replace a certified zero-exclusion theorem.

The corrected framework therefore follows a support-first methodology: establish which spectral points occur, verify nonvanishing and symmetry, apply counting estimates, and only then classify the sum arithmetically.

## 2. Finite spectral windows

### 2.1 Definition of the harmonic

Let $Z\subset\mathbb C$ be finite and contain no zero. The **reciprocal harmonic** of $Z$ is

$$
H(Z)=\sum_{z\in Z}\frac{1}{z}.
$$

The use of a set means that repeated values are counted once. For spectral problems in which multiplicity matters, the same discussion applies to a finite multiset, with each occurrence contributing separately. All estimates below depend only on the triangle inequality and therefore transfer unchanged to multisets.

A **window family** is a sequence $(Z_n)_{n\ge0}$ of finite subsets of $\mathbb C\setminus\{0\}$. A typical height window takes

$$
Z_T=\{\rho:\rho\text{ is in the chosen spectrum and }|\operatorname{Im}\rho|\le T\}.
$$

The formal parameter may be integral or real. We use integer-indexed families for the transfer theorems and a real height when discussing the zeta function.

### 2.2 Separation

A finite window $Z$ is **$\delta$-separated from the origin** if $\delta>0$ and

$$
|z|\ge\delta\qquad\text{for every }z\in Z.
$$

This is radial separation from zero, not pairwise separation between spectral points. It is exactly the hypothesis needed to bound reciprocal magnitudes.

### 2.3 Conjugation closure

A finite window $Z$ is **conjugation-closed** if

$$
z\in Z\quad\Longleftrightarrow\quad\overline z\in Z
$$

for every $z\in\mathbb C$. Nonreal points then occur in conjugate pairs, while real points are fixed by the involution.

### 2.4 Algebraic and transcendental values

A complex number $w$ is **algebraic over $\mathbb Q$** if there exists a nonzero polynomial $P\in\mathbb Q[X]$ such that $P(w)=0$. It is **transcendental over $\mathbb Q$** if it is not algebraic. In particular, $0$ is algebraic because it is a root of $P(X)=X$.

This elementary observation becomes decisive for an empty spectral window.

## 3. Magnitude bounds from separation and counting

### Theorem 3.1 (Separated-Window Bound)

Let $Z\subset\mathbb C\setminus\{0\}$ be finite. If $|z|\ge\delta$ for every $z\in Z$, where $\delta>0$, then

$$
|H(Z)|\le\frac{|Z|}{\delta}.
$$

**Proof sketch.** For every $z\in Z$,

$$
\left|\frac1z\right|=\frac1{|z|}\le\frac1\delta.
$$

The triangle inequality gives

$$
|H(Z)|
=\left|\sum_{z\in Z}\frac1z\right|
\le\sum_{z\in Z}\frac1{|z|}
\le\sum_{z\in Z}\frac1\delta
=\frac{|Z|}{\delta}.
$$

No information about arguments or cancellation is required. $\square$

The estimate is sharp in the class of arbitrary finite windows: equality occurs when all reciprocal terms have the same argument and all points have modulus $\delta$. For a set rather than a multiset, exact equality with multiple terms requires distinct points on the same ray and hence differing moduli, so one generally obtains near-sharp examples rather than repeated equality. The theorem is intentionally robust; symmetry can improve it, but is not needed.

### Theorem 3.2 (Counting-to-Harmonic Transfer)

Let $(Z_n)_{n\ge0}$ be a family of finite complex windows. Suppose there is a fixed $\delta>0$ such that $|z|\ge\delta$ for every $n$ and every $z\in Z_n$. If $B:\mathbb N\to\mathbb R$ satisfies

$$
|Z_n|\le B(n)
$$

for every $n$, then

$$
|H(Z_n)|\le\frac{B(n)}{\delta}
$$

for every $n$.

**Proof sketch.** Apply Theorem 3.1 to $Z_n$, obtaining $|H(Z_n)|\le |Z_n|/\delta$, and then insert the assumed bound $|Z_n|\le B(n)$. Since $1/\delta>0$, multiplication preserves the inequality. $\square$

### Corollary 3.3 (Conditional Logarithmic-over-Logarithmic Bound)

Under the uniform separation hypothesis of Theorem 3.2, assume that for some real constant $C$,

$$
|Z_n|\le C\frac{\log n}{\log\log n}
$$

for every index in a range where the displayed expression is intended and the inequality holds. Then

$$
|H(Z_n)|\le\frac{C}{\delta}\frac{\log n}{\log\log n}.
$$

**Proof sketch.** Set $B(n)=C\log n/\log\log n$ in Theorem 3.2 and rearrange scalar factors. $\square$

The qualification concerning the range is important: $\log\log n$ vanishes at $n=e$ and changes sign below it. In applications, one normally states the estimate for sufficiently large $n$, where all terms have the expected sign.

### 3.1 Interpretation and limitation

Corollary 3.3 is a transfer theorem. Its conclusion has the same asymptotic shape as its counting hypothesis. It does not derive a new point count from properties of reciprocal sums.

For the standard nontrivial zeros of $\zeta(s)$, the Riemann–von Mangoldt formula gives a counting function whose leading scale is

$$
N(T)\sim \frac{T}{2\pi}\log\frac{T}{2\pi}.
$$

Therefore, one must not substitute the standard height window into Corollary 3.3 while silently assuming a much smaller $\log T/\log\log T$ count. The general transfer theorem remains valid, and it may apply to sparse subwindows, differently indexed bands, or other spectra. For the full zeta window, sharper harmonic analysis should exploit cancellation and conjugation rather than cardinality alone.

## 4. Reality from conjugation symmetry

### Theorem 4.1 (Conjugation-Symmetry Theorem)

If $Z\subset\mathbb C\setminus\{0\}$ is finite and conjugation-closed, then $H(Z)$ is real. Equivalently,

$$
\operatorname{Im}H(Z)=0.
$$

**Proof sketch.** Complex conjugation commutes with inversion away from zero, so

$$
\overline{H(Z)}
=\sum_{z\in Z}\overline{\frac1z}
=\sum_{z\in Z}\frac1{\overline z}.
$$

Because conjugation permutes $Z$, reindexing the final sum by $z\mapsto\overline z$ gives $\overline{H(Z)}=H(Z)$. A complex number equal to its conjugate is real. Equivalently, pair each nonreal $z$ with $\overline z$ and use

$$
\frac1z+\frac1{\overline z}=2\operatorname{Re}\left(\frac1z\right).
$$

Real points contribute real reciprocals individually. $\square$

This theorem identifies the appropriate finite organization for a real spectral statistic. It does not assert convergence as the window expands. For an infinite spectrum, ordering and renormalization remain separate analytic questions.

### Example 4.2

Take

$$
Z=\{1+2i,1-2i,3\}.
$$

Then

$$
H(Z)=\frac{1}{1+2i}+\frac{1}{1-2i}+\frac13
=\frac25+\frac13
=\frac{11}{15}.
$$

Conjugation symmetry first guarantees reality; the rational coordinates in this example further yield a rational value.

## 5. Empty-window diagnosis at small cutoffs

### Proposition 5.1 (Empty-Window Harmonic)

If $Z=\varnothing$, then

$$
H(Z)=0.
$$

**Proof sketch.** A sum indexed by the empty set is the additive identity. $\square$

### Corollary 5.2 (Failure of the Unit Assignment)

If the spectral window at cutoff $2$ is empty, then its harmonic is $0$ and therefore is not $1$.

**Proof sketch.** Apply Proposition 5.1 and use $0\ne1$. $\square$

### Corollary 5.3 (Coincidence of Empty Small Windows)

If the windows at cutoffs $2$ and $3$ are both empty, then their harmonics coincide and satisfy

$$
H(2)=H(3)=0.
$$

**Proof sketch.** Apply Proposition 5.1 to each window. $\square$

### Corollary 5.4 (Failure of the Transcendence Assignment)

If the spectral window at cutoff $3$ is empty, then its harmonic is not transcendental over $\mathbb Q$.

**Proof sketch.** Proposition 5.1 gives $H(3)=0$. The nonzero rational polynomial $X$ vanishes at zero, so zero is algebraic over $\mathbb Q$ and hence not transcendental. $\square$

### 5.1 Consequence for zeta-inspired musical labels

Numerical tables place the first nontrivial zeta zeros at imaginary parts approximately $\pm14.1347$. They therefore indicate that the ordinary symmetric height windows at $2$ and $3$ are empty. However, a numerical table is evidence, not a self-contained zero-free proof. The exact logical statement is conditional on emptiness, and a complete analytic specialization requires certified inequalities excluding nontrivial zeros throughout $|\operatorname{Im}s|\le3$.

Once emptiness is supplied, no arithmetic subtlety remains: both values are zero. Thus the proposed identification of cutoff $2$ with the value $1$ and cutoff $3$ with a transcendental value is incompatible with the reciprocal-window definition.

This is a general methodological warning. Before asking whether a finite spectral statistic is rational or transcendental, one must verify that its indexing set is nonempty.

## 6. Quadratic spectra and exact rational harmonics

The empty-window diagnosis removes the proposed small zeta examples, but exact rational harmonics do occur naturally in finite algebraic spectra.

### Theorem 6.1 (Quadratic Reciprocal-Harmonic Identity)

Let $\alpha,\beta,\ell,q\in\mathbb C$ satisfy

$$
\alpha+\beta=\ell,
\qquad
\alpha\beta=q,
\qquad
q\ne0,
$$

and suppose $\alpha\ne\beta$ so that the two-element set $\{\alpha,\beta\}$ counts both roots. Then

$$
H(\{\alpha,\beta\})=\frac{\ell}{q}.
$$

**Proof sketch.** Since $q=\alpha\beta\ne0$, both roots are nonzero. Therefore

$$
H(\{\alpha,\beta\})
=\frac1\alpha+\frac1\beta
=\frac{\alpha+\beta}{\alpha\beta}
=\frac\ell q.
$$

The distinctness condition concerns set semantics: if the roots coincide, a set would count the repeated root once. With multiset semantics, the identity remains valid with multiplicity even for a repeated root. $\square$

### Corollary 6.2 (Rational Quadratic Harmonics)

Under the hypotheses of Theorem 6.1, if $\ell,q\in\mathbb Q$, then the reciprocal harmonic is rational and equals $\ell/q$.

**Proof sketch.** Theorem 6.1 identifies the harmonic with a quotient of rational numbers, and $q\ne0$. $\square$

### Theorem 6.3 (Factorization-and-Harmonic Principle)

Under the hypotheses of Theorem 6.1, the quadratic expression

$$
L(u)=1-\ell u+qu^2
$$

factors for every $u\in\mathbb C$ as

$$
L(u)=(1-\alpha u)(1-\beta u),
$$

and its two-root reciprocal harmonic is $\ell/q$.

**Proof sketch.** Expanding the product yields

$$
(1-\alpha u)(1-\beta u)
=1-(\alpha+\beta)u+\alpha\beta u^2
=1-\ell u+qu^2.
$$

The harmonic identity is Theorem 6.1. $\square$

Quadratic factors of this form occur in finite graph-zeta constructions. The theorem supplies a bridge from factor coefficients to a spectral chord without requiring explicit root extraction. It is a finite analogue of the broader principle that symmetric functions of roots are coefficient invariants.

### Example 6.4

For $\alpha=2$ and $\beta=3$, one has $\ell=5$ and $q=6$. Hence

$$
(1-2u)(1-3u)=1-5u+6u^2
$$

and

$$
H(\{2,3\})=\frac12+\frac13=\frac56=\frac\ell q.
$$

### Example 6.5

For the conjugate pair $\alpha=1+2i$ and $\beta=1-2i$, one has $\ell=2$ and $q=5$. Therefore

$$
H(\{1+2i,1-2i\})=\frac25.
$$

Here conjugation symmetry explains reality, while Vieta’s identity explains rationality.

## 7. Algorithms

### 7.1 Direct finite-window evaluation

Given a finite list of nonzero complex numbers, the direct algorithm accumulates their reciprocals. For $m$ input points, it uses $m$ inversions and $m-1$ additions, hence $O(m)$ time and $O(1)$ auxiliary space if the sum is streamed.

**Pseudocode.**

1. Input a list $z_1,\dots,z_m$.
2. Reject the input if any $z_j=0$.
3. Initialize $S\leftarrow0$.
4. For $j=1$ to $m$, update $S\leftarrow S+1/z_j$.
5. Return $S$.

For floating-point input, compensated summation may reduce rounding error. For exact rational or algebraic input, symbolic arithmetic is preferable.

### 7.2 Cutoff filtering

Given candidate spectral points and a cutoff $T\ge0$, retain those satisfying $|\operatorname{Im}z|\le T$, then apply direct evaluation. Filtering and summation together take $O(m)$ time. If many cutoffs are queried, sorting once by $|\operatorname{Im}z|$ costs $O(m\log m)$, after which prefix sums support efficient repeated queries.

This algorithm demonstrates selected-window behavior relative to the supplied data. It does not certify that the candidate list is complete.

### 7.3 Quadratic coefficient evaluation

For a quadratic factor $1-\ell u+qu^2$ with $q\ne0$, return $\ell/q$. This is $O(1)$ arithmetic and avoids square roots, root ordering, and cancellation errors. If the coefficients are rational, exact fraction arithmetic yields an exact rational harmonic.

### 7.4 Structural diagnostics

A useful implementation should return more than a sum. It should report:

- the selected cardinality $|Z|$;
- the minimum modulus $\delta_Z=\min_{z\in Z}|z|$ when $Z$ is nonempty;
- the bound $|Z|/\delta_Z$;
- a conjugation-closure diagnostic relative to a numerical tolerance;
- the real and imaginary parts of the harmonic.

These diagnostics distinguish theorem-backed structure from accidents of floating-point output.

## 8. Applications

### 8.1 Sparse spectral statistics

The counting-transfer theorem applies to any sparse finite spectrum with a uniform exclusion radius. Examples include selected eigenvalue bands, chosen polynomial roots, and filtered graph spectra. The theorem is especially useful when cardinality is easy to estimate but individual roots are difficult to locate.

### 8.2 Graph-zeta chord spectra

Finite graphs offer local factors with explicit coefficients. Associating the reciprocal-root harmonic to each quadratic factor turns graph data into exact rational or algebraic statistics. Graph operations may then be studied through their effects on coefficient ratios. Covers, products, and subdivisions are natural candidates because they often produce structured changes in spectral factorizations.

### 8.3 Arithmetic classification through symmetric functions

The quadratic identity extends conceptually to higher degrees. If nonzero roots $r_1,\dots,r_d$ are counted with multiplicity, then

$$
\sum_{j=1}^d\frac1{r_j}
$$

is a ratio of elementary symmetric functions, hence a coefficient ratio up to the sign convention of the polynomial. This observation suggests that rationality often reflects the coefficient field and Galois invariance rather than exceptional properties of individual roots. Selected subsets, rather than complete root multisets, lead to subtler arithmetic questions.

### 8.4 Auditory mappings

To turn a real harmonic into sound, one could map a statistic $h$ to a frequency $f_0 2^h$ or to a pitch class modulo $1$. Such a mapping is external to the mathematics developed here and should not be confused with a theorem about consonance. The structural results instead provide calibrated inputs: real values from conjugation symmetry, exact rationals from quadratic factors, and magnitude controls from counting.

## 9. Discussion

The reciprocal-harmonic framework has a productive tension between metaphor and rigor. The musical metaphor motivates questions, but the finite theorems decide which versions are coherent.

First, cardinality bounds alone cannot reveal cancellation. The estimate $|H(Z)|\le|Z|/\delta$ is universal but potentially crude. In conjugate pairs $\rho=\sigma+it$ and $\overline\rho=\sigma-it$,

$$
\frac1\rho+\frac1{\overline\rho}
=\frac{2\sigma}{\sigma^2+t^2},
$$

which decays quadratically in $|t|$ when $\sigma$ remains bounded. This is far smaller than the sum of reciprocal moduli, which decays only linearly in $|t|$. A refined zeta analysis should exploit this paired expression.

Second, the set-versus-multiset distinction matters. Spectral zeros are ordinarily counted with multiplicity. A finite-set model is appropriate when all selected points are distinct or when multiplicity is deliberately ignored. Repeated quadratic roots show why the convention must be explicit.

Third, computation must distinguish finite-data evaluation from certification. A program can faithfully sum every zero in its input table, but it cannot infer that no omitted zero lies below a cutoff. Certified support requires either a proof or data accompanied by rigorous completeness guarantees.

Fourth, the small-cutoff failure clarifies how hypotheses should be ordered. Nonemptiness is logically prior to transcendence. Separation is prior to reciprocal evaluation. Conjugation closure is prior to claiming reality. A count estimate is prior to transferring its asymptotic shape.

Finally, rationality in the quadratic model has a transparent explanation. The sum of reciprocal roots is a symmetric invariant, so it belongs to the coefficient field. This mechanism is more robust than attaching special arithmetic meaning to arbitrary numerical cutoffs.

## 10. Future work

### 10.1 Renormalized zeta harmonic convergence

Define a multiplicity-sensitive, conjugate-symmetric sum

$$
H(T)=\sum_{|\operatorname{Im}\rho|\le T}\frac1\rho
$$

and determine an explicit renormalization under which it converges, with a quantitative error term derived from the Riemann–von Mangoldt formula. Conjugate pairing converts the sum into a real spectral statistic, while zero counting controls its tail. Predicted errors could be compared with certified zero tables.

### 10.2 Arithmetic classification of finite spectral harmonics

Classify algebraic root multisets whose reciprocal sum is rational, algebraic irrational, or transcendental, beginning with Euler factors of increasing degree and prescribed Galois group. A central question is whether rationality is equivalent to a Galois-invariant coefficient ratio under natural nonvanishing hypotheses.

### 10.3 Graph-zeta spectra under graph operations

For finite regular graphs, define chord spectra from reciprocal roots of local factors and determine how graph products, covers, and edge subdivisions transform them. One concrete conjectural direction is that rational chord spectra persist under finite regular covers precisely when the traces and determinants of new factors remain rational.

### 10.4 Certified first-zero exclusion windows

Develop a self-contained proof from explicit analytic inequalities that the zeta function has no nontrivial zero with $|\operatorname{Im}\rho|\le14$, then combine it with the empty-window proposition. Such an exclusion theorem would settle every cutoff in that interval at once: each associated reciprocal harmonic would be zero.

### 10.5 Prime-indexed interval encoding

Replace the direct cutoff $n$ with a prime-dependent spectral band whose endpoints depend on $\log p$. Test whether multiplication of primes corresponds to addition, convolution, or another composition law for harmonic statistics. Any proposed correspondence should specify completeness of the band, multiplicity, normalization, and an explicit falsifiable law.

## 11. Conclusion

Finite reciprocal-zero harmonics satisfy a coherent set of structural laws. Uniform separation from zero converts cardinality estimates into magnitude estimates. Conjugation closure makes the harmonic real. Empty windows have harmonic zero, which invalidates proposed values $1$ and transcendental at empty cutoffs $2$ and $3$. Quadratic factors, by contrast, yield exact reciprocal harmonics equal to the coefficient ratio $\ell/q$, and rational coefficients therefore produce rational chords.

The resulting framework does not identify primes with musical intervals by decree. It provides the mathematical calibration needed to test such an identification: certify support, respect symmetry, separate assumptions from conclusions, and compute symmetric invariants exactly. Within that disciplined setting, number-theoretic and graph-theoretic spectra offer a genuine laboratory for arithmetic harmony.
