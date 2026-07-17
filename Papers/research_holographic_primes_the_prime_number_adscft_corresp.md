# Holographic Primes: Finite Euler Products, Bulk Occupation Sums, and Tropical Vacua

**Aristotle**  
**17 July 2026**

## Abstract

We develop a finite and unconditional partition-function model in which local prime modes form a boundary description and their joint occupation profiles form a bulk description. For an arbitrary finite mode set $I$, real local energies $E_i$, occupation cutoff $N$, and inverse temperature $\beta$, the product of local geometric partition sums is exactly the Gibbs sum over all occupation profiles. Specializing to primes $p<x$ with energy $E_p=\log p$ yields a finite prime holographic factorization. Removing the occupation and prime cutoffs in the region of absolute convergence recovers the Euler product $\prod_p(1-p^{-\beta})^{-1}=\zeta(\beta)$ for $\beta>1$, together with its exponential logarithmic representation. We then tropicalize the bulk model: nonnegative local energies imply that the minimum bulk energy is the vacuum value $0$, and logarithmic prime energies satisfy this hypothesis. A finite-state bound quantifies convergence of normalized log partition functions to the tropical value. Algorithms for product evaluation, direct bulk enumeration, and cutoff diagnostics are presented. The results isolate an exact algebraic core for the holographic metaphor while distinguishing it from unproved claims about analytic continuation, the completed functional equation, zero statistics, or the Riemann Hypothesis.

## 1. Introduction

Euler products compress global arithmetic into independent local factors. Statistical mechanics performs a related compression: when a Hamiltonian is a sum of uncoupled local energies, its partition function factors into local partition functions. The common algebra is distributivity together with the exponential law. The present model makes this common structure explicit by treating each selected prime as a local bosonic mode and each vector of occupation numbers as a bulk configuration.

The word *holographic* is used here in a restricted mathematical sense. The boundary is the factored collection of local partition sums, while the bulk is the expanded occupation lattice. The two descriptions are exactly equal at finite cutoffs. No geometric spacetime or gravitational dynamics is assumed. This disciplined use of the analogy is important: a finite Euler factorization does not itself imply the reflection law of the completed zeta function, random-matrix statistics for zeta zeros, or a stability interpretation of the critical line.

Three levels of the construction should be kept separate. First, finite factorization is an algebraic theorem valid for arbitrary real energies and arbitrary real $\beta$. Second, the infinite prime identity is analytic and is asserted only for $\beta>1$, where the Euler product converges absolutely. Third, tropicalization is an order-theoretic statement: when energies are nonnegative, minimization selects the vacuum.

This separation clarifies both the scope and the utility of the model. The finite identity provides exact test cases and efficient algorithms. The infinite identity connects the system to $\zeta$. The tropical theorem identifies a stable zero-energy ground state. Together they form a foundation on which sharper questions about cutoff removal, archimedean completion, and spectral correlations can be posed.

## 2. Finite occupation systems

### 2.1 Modes, occupations, and energies

Let $I$ be a finite set. A function $E:I\to\mathbb{R}$ assigns a local energy $E_i$ to each mode $i$. Fix an integer $N\geq0$. The finite occupation space is

$$
\Omega_{I,N}=\{a:I\to\{0,1,\ldots,N\}\}.
$$

Thus $a_i$ records the number of quanta occupying mode $i$. The cardinality of this space is

$$
|\Omega_{I,N}|=(N+1)^{|I|}.
$$

**Definition 2.1 (Bulk Hamiltonian).** For $a\in\Omega_{I,N}$, define

$$
H_{E,N}(a)=\sum_{i\in I}a_iE_i.
$$

The system is noninteracting because the Hamiltonian contains no cross-terms between distinct modes.

**Definition 2.2 (Bulk Gibbs partition function).** For inverse temperature $\beta\in\mathbb{R}$, define

$$
Z_{\mathrm{bulk}}(E,N,\beta)
=\sum_{a\in\Omega_{I,N}}e^{-\beta H_{E,N}(a)}.
$$

**Definition 2.3 (Boundary partition function).** Define the local partition sum at mode $i$ by

$$
Z_i(E_i,N,\beta)=\sum_{n=0}^{N}e^{-\beta nE_i},
$$

and the boundary partition function by

$$
Z_{\mathrm{boundary}}(E,N,\beta)
=\prod_{i\in I}Z_i(E_i,N,\beta).
$$

The bulk representation has exponentially many summands in $|I|$, whereas the factored boundary representation has $|I|$ sums of $N+1$ terms.

### 2.2 Factorization

**Lemma 2.4 (Boltzmann factorization).** For every occupation profile $a\in\Omega_{I,N}$,

$$
e^{-\beta H_{E,N}(a)}
=\prod_{i\in I}e^{-\beta a_iE_i}.
$$

**Proof sketch.** Substitute the definition of $H_{E,N}$ and apply $e^{u+v}=e^ue^v$ repeatedly over the finite sum. No positivity assumption is required. $\square$

**Theorem 2.5 (Finite Holographic Factorization).** For every finite set $I$, every energy function $E:I\to\mathbb{R}$, every $N\geq0$, and every $\beta\in\mathbb{R}$,

$$
Z_{\mathrm{boundary}}(E,N,\beta)
=Z_{\mathrm{bulk}}(E,N,\beta).
$$

**Proof sketch.** Expand the finite product

$$
\prod_{i\in I}\left(\sum_{n=0}^{N}e^{-\beta nE_i}\right).
$$

A term in the expansion is obtained by choosing one $n=a_i$ at each mode, so choices are in bijection with functions $a\in\Omega_{I,N}$. The resulting term is $\prod_i e^{-\beta a_iE_i}$, which equals $e^{-\beta H_{E,N}(a)}$ by Lemma 2.4. Summing over all choices gives the bulk sum. $\square$

The theorem is the precise boundary/bulk dictionary in this model. It is stronger than a numerical coincidence: the expansion establishes a weight-preserving bijection between product choices and occupation profiles.

### 2.3 Edge cases

The identity includes $N=0$, when every mode is forced into its vacuum and both sides equal $1$. It also includes $I=\varnothing$, when the empty product equals $1$ and the unique empty occupation profile has energy $0$. Negative energies and negative $\beta$ do not invalidate finite factorization, although they change its thermodynamic interpretation. Positivity becomes relevant only for ground-state results and infinite convergence.

## 3. Prime modes and arithmetic states

Fix an integer cutoff $x\geq0$ and define

$$
P_x=\{p\in\mathbb{N}:p<x\text{ and }p\text{ is prime}\}.
$$

This is a finite mode set.

**Definition 3.1 (Prime energy).** For $p\in P_x$, let

$$
E_p=\log p.
$$

Every prime satisfies $p\geq2$, hence $E_p\geq0$.

For an occupation profile $a:P_x\to\{0,\ldots,N\}$, define

$$
H_{x,N}(a)=\sum_{p\in P_x}a_p\log p.
$$

The associated integer is

$$
m(a)=\prod_{p\in P_x}p^{a_p}.
$$

Taking logarithms gives $H_{x,N}(a)=\log m(a)$, while exponentiation gives

$$
e^{-\beta H_{x,N}(a)}=m(a)^{-\beta}.
$$

Unique factorization makes $a\mapsto m(a)$ injective. Its image is precisely the positive integers all of whose prime divisors are below $x$ and whose prime exponents do not exceed $N$.

**Theorem 3.2 (Finite Prime Hologram).** For every $x,N\in\mathbb{N}$ and every $\beta\in\mathbb{R}$,

$$
\prod_{p\in P_x}\sum_{n=0}^{N}p^{-\beta n}
=
\sum_{a:P_x\to\{0,\ldots,N\}}
\exp\!\left(-\beta\sum_{p\in P_x}a_p\log p\right).
$$

Equivalently,

$$
\prod_{p\in P_x}\sum_{n=0}^{N}p^{-\beta n}
=
\sum_{m\in S_{x,N}}m^{-\beta},
$$

where $S_{x,N}$ is the finite set of positive integers whose prime factors lie below $x$ and whose prime exponents are at most $N$.

**Proof sketch.** Apply Theorem 2.5 to $I=P_x$ and $E_p=\log p$. The identity $e^{-\beta n\log p}=p^{-\beta n}$ gives the displayed boundary factors. The integer formulation follows from unique factorization. $\square$

**Example 3.3.** Let $P_x=\{2,3\}$ and $N=2$. Then

$$
Z=(1+2^{-\beta}+2^{-2\beta})(1+3^{-\beta}+3^{-2\beta}).
$$

The nine bulk profiles correspond to $2^a3^b$ with $0\leq a,b\leq2$. At $\beta=1$, both descriptions sum the reciprocals of $1,2,3,4,6,9,12,18,36$.

## 4. Infinite occupation and the zeta function

For fixed $p$ and real $\beta>0$, the occupation cutoff may be removed by the geometric-series identity

$$
\sum_{n=0}^{\infty}p^{-\beta n}=(1-p^{-\beta})^{-1}.
$$

For finitely many primes this limit poses no difficulty. Removing the prime cutoff requires stronger convergence.

**Definition 4.1 (Infinite prime partition function).** For real $\beta>1$, define

$$
Z_{\mathrm{prime}}(\beta)
=\prod_p(1-p^{-\beta})^{-1},
$$

where the product ranges over all primes.

**Theorem 4.2 (Infinite Prime Partition Identity).** If $\beta>1$, then

$$
Z_{\mathrm{prime}}(\beta)=\zeta(\beta).
$$

**Proof sketch.** In the half-plane $\operatorname{Re}(s)>1$, the Dirichlet series $\sum_{n\geq1}n^{-s}$ converges absolutely. Unique factorization expands the absolutely convergent product of geometric series into that Dirichlet series, with each integer occurring exactly once. Setting $s=\beta$ gives the claim. $\square$

**Corollary 4.3 (Logarithmic representation).** If $\beta>1$, then

$$
\exp\!\left(\sum_p-\log(1-p^{-\beta})\right)=\zeta(\beta).
$$

**Proof sketch.** Absolute convergence permits taking logarithms of the positive Euler factors and summing them, after which exponentiation recovers the product. $\square$

The condition $\beta>1$ is essential to this argument. The completed zeta function and its reflection law require analytic continuation and an archimedean gamma factor. They are not consequences of finite distributivity.

## 5. Tropical dequantization and the vacuum

Tropicalization replaces a thermal sum by extremal energy data. For a finite nonempty configuration space $\Omega$ and Hamiltonian $H:\Omega\to\mathbb{R}$, define

$$
\mathcal{T}(H)=\inf_{a\in\Omega}H(a).
$$

Because $\Omega$ is finite, the infimum is a minimum.

**Lemma 5.1 (Nonnegativity of the bulk Hamiltonian).** If $E_i\geq0$ for all $i\in I$, then $H_{E,N}(a)\geq0$ for every $a\in\Omega_{I,N}$.

**Proof sketch.** Every occupation number $a_i$ is nonnegative, so each product $a_iE_i$ is nonnegative. Their finite sum is nonnegative. $\square$

**Lemma 5.2 (Vacuum energy).** The vacuum profile $a^{(0)}$, defined by $a_i^{(0)}=0$ for every $i$, satisfies

$$
H_{E,N}(a^{(0)})=0.
$$

**Proof sketch.** Every summand is $0\cdot E_i=0$. $\square$

**Theorem 5.3 (Tropical Vacuum Theorem).** If every local energy is nonnegative, then

$$
\mathcal{T}(H_{E,N})=0.
$$

**Proof sketch.** Lemma 5.1 gives the lower bound $\mathcal{T}(H_{E,N})\geq0$. Lemma 5.2 exhibits a configuration of energy $0$, giving the reverse bound. $\square$

**Corollary 5.4 (Prime Tropical Vacuum).** For every prime cutoff $x$ and occupation cutoff $N$,

$$
\mathcal{T}(H_{x,N})=0.
$$

**Proof sketch.** Prime energies satisfy $\log p\geq0$, so Theorem 5.3 applies. This includes an empty prime set, whose unique empty profile has energy $0$. $\square$

### 5.1 Quantitative low-temperature convergence

For nonnegative energies, the vacuum contributes $1$ to the partition sum and every Boltzmann weight is at most $1$. Writing $M=(N+1)^{|I|}$ therefore gives

$$
1\leq Z_{\mathrm{bulk}}(E,N,\beta)\leq M
$$

for $\beta>0$. Consequently,

$$
0\leq\frac{1}{\beta}\log Z_{\mathrm{bulk}}(E,N,\beta)
\leq\frac{|I|\log(N+1)}{\beta}.
$$

Thus the normalized log partition converges to $0$, the tropical vacuum energy, as $\beta\to\infty$. This bound depends only on the number of states; sharper estimates can use the first excitation gap.

## 6. Algorithms

### 6.1 Boundary product evaluation

Given a list of primes $p_1,\ldots,p_k$, $N$, and $\beta$, compute each local sum $\sum_{n=0}^Np_j^{-\beta n}$ and multiply. Direct summation uses $O(kN)$ arithmetic operations and $O(1)$ auxiliary storage. A closed geometric formula can reduce the arithmetic count to $O(k)$ away from the removable case $p_j^{-\beta}=1$.

### 6.2 Bulk enumeration

Iterate over all $(N+1)^k$ occupation vectors, compute $H(a)=\sum_ja_j\log p_j$, and accumulate $e^{-\beta H(a)}$. This costs $O(k(N+1)^k)$ operations and is exponentially slower, but it directly exposes the state space and is ideal for validating factorization on small instances.

### 6.3 Tropical ground-state evaluation

For logarithmic prime energies, no enumeration is needed: all energies are nonnegative and the vacuum exists, so the answer is $0$. For a general finite noninteracting model with occupations from $0$ through $N$, the same conclusion holds whenever all local energies are nonnegative. If negative energies are allowed, each such mode minimizes energy at occupation $N$, giving the separable minimum $\sum_i\min(0,NE_i)$.

### 6.4 Cutoff diagnostics

For $\beta>1$, one may compare the finite product with a numerical approximation to $\zeta(\beta)$. Two errors are conceptually independent. The occupation-tail error comes from replacing each infinite geometric series by its first $N+1$ terms. The prime-tail error comes from omitting primes at or above $x$. Exact finite factorization ensures that these are approximation errors, not boundary/bulk discrepancies.

## 7. Applications and interpretation

The model offers a compact representation of a large combinatorial space. A bulk with $(N+1)^k$ states is represented by $k$ local factors. This is the same computational advantage exploited by generating functions, independent-particle models, and tensor factorizations.

Arithmetically, each occupation profile is a bounded prime factorization. The Hamiltonian is the logarithm of the represented integer, and the Gibbs weight is its inverse power. The zeta function therefore appears as a grand canonical partition function for unrestricted prime exponents in its convergence region.

Tropically, logarithmic energies turn multiplication of integers into addition of energies, while low temperature turns the logarithm of a sum into an extremum. The vacuum theorem is the min-plus shadow of the thermal system. It is robust but limited: it reports the ground energy, not the excited spectrum or correlations.

The holographic terminology highlights a change of organization rather than a new equality beyond Euler factorization. The “boundary” lists independent local modes; the “bulk” lists simultaneous global configurations. Exact equality follows because the modes do not interact. Introducing interactions would generally destroy the simple product and would require a more sophisticated boundary encoding.

## 8. Error structure and finite-size analysis

The exact factorization permits a clean distinction among three limits: the low-temperature limit $\beta\to\infty$, the occupation limit $N\to\infty$, and the prime limit $x\to\infty$. These limits answer different questions and need not be taken at the same rate.

For a fixed finite prime set and $\beta>0$, put $q_p=p^{-\beta}$. The omitted tail of the local geometric series is

$$
\sum_{n=N+1}^{\infty}q_p^n=\frac{q_p^{N+1}}{1-q_p}.
$$

Equivalently, the truncated local factor satisfies

$$
\sum_{n=0}^{N}q_p^n
=\frac{1-q_p^{N+1}}{1-q_p}.
$$

Thus the finite-occupation boundary partition can be written exactly as

$$
Z_{x,N}(\beta)
=\prod_{p\in P_x}\frac{1-p^{-\beta(N+1)}}{1-p^{-\beta}}.
$$

Relative to the same finite prime system with unrestricted occupations, the ratio is

$$
\frac{Z_{x,N}(\beta)}{Z_{x,\infty}(\beta)}
=\prod_{p\in P_x}\left(1-p^{-\beta(N+1)}\right).
$$

This formula isolates the occupation error exactly. In particular, for fixed $x$ and $\beta>0$, the ratio tends to $1$ as $N\to\infty$.

When $\beta>1$, the remaining prime-tail ratio is

$$
\frac{\zeta(\beta)}{Z_{x,\infty}(\beta)}
=\prod_{p\geq x}(1-p^{-\beta})^{-1}.
$$

Its logarithm is a positive tail

$$
\sum_{p\geq x}-\log(1-p^{-\beta}),
$$

which tends to zero by absolute convergence. The occupation and prime errors therefore enter through distinct products. This independence is one of the practical benefits of the finite formulation.

Low temperature behaves differently. With fixed $x$ and $N$, let $\Delta$ denote the least positive energy, if an excited state exists. Since the least prime mode has energy at least $\log2$, one may take $\Delta\geq\log2$ whenever the finite prime set is nonempty and $N\geq1$. Then

$$
0\leq Z_{x,N}(\beta)-1\leq\bigl((N+1)^{|P_x|}-1\bigr)e^{-\beta\Delta}.
$$

This exponential estimate sharpens the state-count bound and shows direct concentration on the vacuum. It also explains why the tropical limit discards most thermal information: all excited contributions vanish exponentially, leaving only the minimum energy and, under a finer normalization, its degeneracy.

### 8.1 Numerical invariants

Several quantities provide robust diagnostics. The factorization residual is

$$
R=\left|Z_{\mathrm{boundary}}-Z_{\mathrm{bulk}}\right|,
$$

which should vanish up to rounding error. The normalized tropical proxy is $\beta^{-1}\log Z$, which approaches $0$. The occupation ratio compares $Z_{x,N}$ with $Z_{x,\infty}$, while the prime ratio compares $Z_{x,\infty}$ with $\zeta(\beta)$ for $\beta>1$. Reporting all four prevents one source of approximation from being mistaken for another.

### 8.2 Order of limits

Although the three limits are compatible in familiar regimes, their meanings should not be conflated. Taking $\beta\to\infty$ first at fixed cutoffs erases all excited states and returns the vacuum, so subsequent enlargement of the prime set still leaves the tropical value at $0$. Taking $N\to\infty$ first at fixed $x$ and $\beta>0$ produces a finite Euler product. Taking $x\to\infty$ after that requires $\beta>1$ to reach the ordinary zeta Euler product. At $\beta\leq1$, the positive-real product diverges, and no rearrangement of the finite factorization supplies a convergent ordinary limit.

This observation prevents a common conceptual error. The tropical vacuum is stable under all finite cutoffs, but that stability does not imply convergence of the thermal partition at fixed finite temperature. Ground-state energy and total state weight are different observables. An infinite system can have a perfectly well-defined minimum energy while its unnormalized partition sum diverges because too many excited states contribute.

### 8.3 Compact encoding and computational scale

Suppose there are $k$ prime modes and each allows $N+1$ occupations. The bulk table contains $(N+1)^k$ entries. By contrast, the boundary data consist of $k$ lists, each with $N+1$ weights. Thus the factored form requires $O(kN)$ explicit local data rather than $O((N+1)^k)$ global data. This is an exponential compression in the number of modes.

The compression is exact only because the Hamiltonian is additive. If one adds an interaction term such as $J_{pq}a_pa_q$, then the Boltzmann weight no longer splits into independent one-mode factors. One can still seek structured representations—factor graphs, transfer matrices, or tensor networks—but the elementary Euler product is lost. In this sense, exact prime factorization corresponds to a noninteracting arithmetic gas.

There is a complementary probabilistic interpretation. After division by $Z$, the Gibbs weights define a probability distribution on occupation profiles. Finite factorization implies that the coordinates are independent, with

$$
\mathbb{P}(a_p=n)=
\frac{p^{-\beta n}}{\sum_{j=0}^{N}p^{-\beta j}}.
$$

Consequently, expectations of additive observables split into sums of local expectations. For example,

$$
\mathbb{E}[H]=\sum_{p\in P_x}(\log p)\,\mathbb{E}[a_p].
$$

This independence explains both the product formula and its limitation for spectral questions. Nontrivial connected correlations vanish between distinct modes in the basic ensemble. Any proposed comparison with correlated zero statistics must therefore introduce conditioning, smoothing, collective observables, interactions, or another mechanism that creates correlations rather than assuming they follow from normalization alone.

## 9. Scope and limitations

The established conclusions are:

1. finite boundary products equal finite bulk occupation sums for arbitrary local energies;
2. logarithmic prime energies yield an exact finite prime specialization;
3. the unrestricted prime partition equals $\zeta(\beta)$ for $\beta>1$;
4. nonnegative energies force tropical ground energy $0$;
5. finite normalized log partition functions approach that value with a state-count bound.

Several attractive statements remain outside these conclusions. The functional equation concerns a completed zeta function containing an archimedean factor and depends on analytic continuation. Pair correlation concerns the distribution of complex zeros, not merely the positive-real Euler product. The Riemann Hypothesis cannot be identified with stability until a precise dynamical system and an equivalence between its stability spectrum and zeta zeros are constructed. Calling these directions conjectural is not a weakness; it identifies exactly what additional mathematics must be supplied.

## 10. Future research

A first problem is joint removal of the prime and occupation cutoffs with an explicit error decomposition. Since the finite theorem makes the boundary/bulk equality exact, the only errors arise from omitted prime modes and geometric tails.

A second problem is archimedean completion. The gamma factor should be treated as a distinguished local sector at infinity. Any reflection law resembling $s\mapsto1-s$ must incorporate this sector and analytic continuation.

A third direction is tropicalizing the completed functional equation. Suitable logarithmic scaling may produce a piecewise-linear reflection principle with a controlled finite-temperature defect.

A fourth direction is spectral. Centered fluctuations of occupation energies can be studied through two-point functions and compared, after explicit smoothing and scaling, with conjectural pair-correlation kernels for high zeta zeros. The finite model is useful here because every cutoff is transparent and numerical claims are falsifiable.

Finally, a stability interpretation of the critical line requires a defined geometry, perturbation operator, and theorem relating spectral stability to zero locations. The present vacuum theorem supplies only the finite nonnegative ground-state component of such a program.

## 11. Conclusion

A finite product of local partition sums and a finite Gibbs sum over occupation profiles are two exact descriptions of one system. Assigning energy $\log p$ to prime mode $p$ turns the bulk into bounded prime factorizations and the boundary into a truncated Euler product. In the absolute-convergence region, removing cutoffs recovers $\zeta(\beta)$. Under tropical dequantization, nonnegative prime energies select the vacuum energy $0$.

These statements provide a precise mathematical core for “holographic primes.” Their strength comes from maintaining clear boundaries: finite algebraic factorization, convergent infinite analysis, and tropical minimization are established; completed duality and spectral stability remain research questions. That distinction makes the framework both reliable and extensible.
