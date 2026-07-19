# Periodicity Obstructs Instantaneous Mixing in Finite Quantum Walks

## Abstract

Quantum walks on finite Cayley graphs are often compared with classical random walks through mixing times and spectral gaps. Such a comparison requires care because closed quantum evolution is unitary and reversible, whereas classical Markov evolution is generally contractive. This paper proves a general obstruction to instantaneous pointwise mixing. A positive-period periodic sequence in any Hausdorff space can converge only to its initial value. If a quantum evolution operator satisfies $U^k=I$ for some positive integer $k$, then every coordinate Born-probability sequence is periodic with period $k$. Consequently, if those probabilities converge pointwise, their limit is exactly the initial Born distribution. Uniform convergence is therefore possible only from an initially uniform probability profile, and a basis-state start on any finite space with more than one point cannot converge pointwise to uniform. Cyclic shifts provide explicit counterexamples in every finite cardinality. We also explain why the classical modulus gap $1-|\lambda_2|$ cannot control unitary relaxation, present algorithms for detecting and illustrating the obstruction, and distinguish instantaneous convergence from time-averaged, decoherent, measured, and continuous-time notions of quantum mixing.

## 1. Introduction

Let $G$ be a finite group and $S$ a generating set. The Cayley graph $\operatorname{Cay}(G,S)$ has vertex set $G$ and connects $g$ to $sg$ or $gs$, according to convention, for each $s\in S$. Its symmetry makes it a natural setting for both classical and quantum walks. In the classical case, a probability distribution is repeatedly transformed by a stochastic operator. Under irreducibility and aperiodicity hypotheses, nonstationary spectral components decay and the distribution approaches a stationary law, often the uniform law on a regular Cayley graph.

A closed discrete-time quantum walk is fundamentally different. Its state is a vector of complex amplitudes, and one time step is represented by a unitary operator. Measurement probabilities arise only after taking squared moduli. The state evolution is reversible, its norm is conserved, and its spectral modes rotate rather than decay. These facts do not prevent useful quantum transport or algorithmic speedups, but they do obstruct a direct transfer of classical pointwise convergence claims.

We isolate the obstruction in its simplest exact form. Assume the evolution has finite positive order: $U^k=I$ for some $k>0$. Then the complete state, and hence every Born probability, repeats after $k$ steps. A periodic sequence can have a limit only when that limit equals every value in its cycle, in particular its initial value. The result immediately rules out pointwise convergence to uniform from a localized state on a nontrivial finite space.

The argument is independent of the graph structure and does not require unitarity beyond whatever is used to justify the chosen evolution. Finite order alone is enough. This generality clarifies that the obstruction is topological and dynamical, not an artifact of a specific group or representation.

The paper proceeds as follows. Section 2 defines amplitude evolution, Born probabilities, periodicity, and mixing. Section 3 proves the periodic convergence theorem. Section 4 transfers it to finite-order quantum dynamics and derives the no-go theorem. Section 5 gives cyclic-shift examples. Section 6 analyzes the mismatch between classical and unitary spectral gaps. Section 7 discusses valid constructions of Cayley-graph quantum walks. Section 8 presents computational algorithms and numerical diagnostics. Section 9 identifies alternative notions of mixing, and Sections 10–12 discuss applications, limitations, and future work.

## 2. Definitions and setting

### 2.1 Finite quantum state spaces

Let $G$ be a nonempty finite set. The Hilbert space of complex amplitudes on $G$ is

$$
\mathcal H_G=\ell^2(G)\cong \mathbb C^{|G|}.
$$

A state is a function $\psi:G\to\mathbb C$ satisfying

$$
\sum_{x\in G}|\psi(x)|^2=1.
$$

The normalization condition ensures that squared moduli form a probability distribution. Let $U:\mathcal H_G\to\mathcal H_G$ be a linear evolution operator. For a closed quantum system, $U$ is unitary, meaning

$$
U^*U=UU^*=I.
$$

Given an initial state $\psi$, define the amplitude at time $n\in\mathbb N$ and position $x\in G$ by

$$
a_n(x)=(U^n\psi)(x).
$$

The associated Born probability is

$$
P_n(x)=|a_n(x)|^2=|(U^n\psi)(x)|^2.
$$

### 2.2 Localized and uniform distributions

For an origin $o\in G$, the localized basis state is

$$
\delta_o(x)=
\begin{cases}
1,&x=o,\\
0,&x\ne o.
\end{cases}
$$

Its Born distribution is the point mass at $o$. The uniform probability distribution on $G$ is

$$
\pi(x)=\frac{1}{|G|}
$$

for all $x\in G$.

A state has an initially uniform Born profile if

$$
|\psi(x)|^2=\frac{1}{|G|}
$$

for every $x$. This condition allows arbitrary phases: $\psi(x)=e^{i\theta_x}/\sqrt{|G|}$ is permitted for any real phases $\theta_x$.

### 2.3 Periodicity

A sequence $f:\mathbb N\to X$ has period $k>0$ if

$$
f(n+k)=f(n)
$$

for every $n\in\mathbb N$. The period need not be minimal.

An evolution operator has finite order if there is a positive integer $k$ such that

$$
U^k=I.
$$

It follows that $U^{n+k}=U^n$ for every $n$. Thus every orbit under $U$ is periodic with common period $k$.

### 2.4 Instantaneous pointwise mixing

We say that the walk converges pointwise to a probability distribution $p:G\to[0,1]$ if

$$
\lim_{n\to\infty}P_n(x)=p(x)
$$

for every $x\in G$. It mixes pointwise to uniform if $p=\pi$, or equivalently,

$$
\lim_{n\to\infty}|(U^n\psi)(x)|^2=\frac{1}{|G|}
$$

for every $x\in G$.

Because $G$ is finite, coordinatewise convergence is equivalent to convergence in every standard norm on $\mathbb R^G$, including total variation:

$$
\|P_n-p\|_{\mathrm{TV}}=\frac12\sum_{x\in G}|P_n(x)-p(x)|.
$$

Thus the pointwise no-go result below also excludes convergence in total variation for finite $G$.

### 2.5 Time-averaged mixing

Instantaneous convergence must be distinguished from Cesàro convergence. Define

$$
\overline P_T(x)=\frac1T\sum_{n=0}^{T-1}P_n(x).
$$

A walk mixes in the time-averaged sense if $\overline P_T$ converges to a specified distribution as $T\to\infty$. A periodic sequence may fail to converge instantaneously while its Cesàro average converges. The main theorem does not prohibit this behavior.

## 3. A topological theorem for periodic sequences

The essential argument uses only the uniqueness of limits.

**Theorem 3.1 (Periodic Convergence Theorem).** Let $X$ be a Hausdorff topological space, let $f:\mathbb N\to X$, and let $k$ be a positive integer. Suppose

$$
f(n+k)=f(n)
$$

for every $n$. If $f(n)\to L$ as $n\to\infty$, then

$$
f(0)=L.
$$

**Proof sketch.** Consider the subsequence indexed by multiples of $k$:

$$
f(0),f(k),f(2k),\ldots.
$$

Periodicity gives $f(mk)=f(0)$ for every $m$, so this subsequence is constant and converges to $f(0)$. Since $mk\to\infty$, it is a cofinal subsequence of the original convergent sequence and therefore also converges to $L$. Limits are unique in a Hausdorff space, so $f(0)=L$. $\square$

The statement can be sharpened.

**Corollary 3.2 (Convergent periodic sequences are constant).** Under the hypotheses of Theorem 3.1, if $f(n)$ converges, then

$$
f(n)=f(0)
$$

for every $n$.

**Proof sketch.** For any residue $r$ with $0\le r<k$, the subsequence $f(r+mk)$ is constantly $f(r)$ and must converge to the same limit $L$. Hence $f(r)=L=f(0)$. Every index has such a residue modulo $k$. $\square$

The Hausdorff hypothesis is exactly what ensures uniqueness of limits. All metric spaces, including $\mathbb R$, $\mathbb C$, and finite-dimensional probability simplices, are Hausdorff.

## 4. Consequences for finite-order quantum evolution

### 4.1 Periodicity of Born probabilities

**Lemma 4.1 (Finite order induces probability periodicity).** Let $U$ be an evolution operator on $\mathcal H_G$, let $\psi$ be any initial amplitude, and suppose $U^k=I$ for some positive integer $k$. Then for every $x\in G$,

$$
P_{n+k}(x)=P_n(x)
$$

for all $n\in\mathbb N$.

**Proof sketch.** The iterate law gives

$$
U^{n+k}\psi=U^n(U^k\psi)=U^n\psi.
$$

Evaluating at $x$ and taking squared complex modulus yields the claim. $\square$

This lemma does not require $U$ to be unitary. Any finite-order transformation has periodic iterates. Unitarity is nevertheless the natural physical context.

### 4.2 Identification of every possible pointwise limit

**Theorem 4.2 (Periodic Quantum Limit Theorem).** Let $U^k=I$ for some positive integer $k$. Suppose there is a function $p:G\to\mathbb R$ such that

$$
P_n(x)\longrightarrow p(x)
$$

for every $x\in G$. Then

$$
p(x)=P_0(x)=|\psi(x)|^2
$$

for every $x\in G$.

**Proof sketch.** Fix $x$. By Lemma 4.1, the real sequence $n\mapsto P_n(x)$ is periodic with period $k$. It converges to $p(x)$ by assumption. Theorem 3.1 therefore gives $P_0(x)=p(x)$. Since $U^0=I$, one has $P_0(x)=|\psi(x)|^2$. Apply this argument independently at every coordinate. $\square$

Combining Theorem 4.2 with Corollary 3.2 shows more: if all coordinate probabilities converge at all, then the probability distribution is constant in time. The amplitudes may still change through phases or transformations invisible to position measurement, but the measured position law cannot follow a nonconstant periodic cycle and converge.

### 4.3 Uniform mixing forces initial uniformity

**Corollary 4.3 (Initial Uniformity Corollary).** Let $G$ be finite and nonempty, and suppose $U^k=I$ for some positive integer $k$. If

$$
P_n(x)\longrightarrow \frac1{|G|}
$$

for every $x\in G$, then

$$
|\psi(x)|^2=\frac1{|G|}
$$

for every $x\in G$.

**Proof sketch.** Apply Theorem 4.2 with $p(x)=1/|G|$. $\square$

This condition is necessary, not by itself sufficient for time independence. An initially uniform Born profile can evolve into a nonuniform profile and return periodically; in that case it still does not converge. If it does converge under finite-order evolution, Corollary 3.2 implies that its Born profile must remain uniform at every time.

### 4.4 No-go theorem for localized starts

**Theorem 4.4 (Localized-Start No-Go Theorem).** Let $G$ be a finite set with $|G|>1$, choose $o\in G$, and start from the basis state $\delta_o$. If $U^k=I$ for some positive integer $k$, then it is false that

$$
P_n(x)\longrightarrow \frac1{|G|}
$$

for every $x\in G$.

**Proof sketch.** If uniform pointwise mixing occurred, Corollary 4.3 would imply

$$
|\delta_o(o)|^2=\frac1{|G|}.
$$

The left side is $1$. Since $|G|>1$, the right side is strictly less than $1$, a contradiction. $\square$

**Corollary 4.5 (Total-variation obstruction).** Under the hypotheses of Theorem 4.4, $P_n$ cannot converge to uniform in total variation.

**Proof sketch.** On a finite set, total-variation convergence implies coordinatewise convergence because

$$
|P_n(x)-\pi(x)|\le 2\|P_n-\pi\|_{\mathrm{TV}}.
$$

Theorem 4.4 excludes coordinatewise convergence. $\square$

These results refute any universal instantaneous mixing claim that includes finite-order coherent evolutions started from a basis state.

## 5. Explicit counterexample family: cyclic shifts

Let $G=\mathbb Z/N\mathbb Z$ with $N>1$. Define the shift operator $S$ on amplitudes by

$$
(S\psi)(x)=\psi(x-1),
$$

with arithmetic modulo $N$. This is a permutation matrix and hence unitary. It also satisfies

$$
S^N=I.
$$

Starting from $\delta_0$, one obtains

$$
S^n\delta_0=\delta_{n\bmod N}.
$$

Therefore

$$
P_n(x)=
\begin{cases}
1,&x\equiv n\pmod N,\\
0,&\text{otherwise}.
\end{cases}
$$

The instantaneous distribution is always localized and returns to its initial value every $N$ steps. Its total-variation distance from uniform is constant:

$$
\|P_n-\pi\|_{\mathrm{TV}}
=\frac12\left(1-\frac1N+(N-1)\frac1N\right)
=1-\frac1N.
$$

Thus there is no trend toward uniformity.

The time average behaves differently. Write $T=qN+r$ with $0\le r<N$. Each vertex is visited either $q$ or $q+1$ times among the first $T$ steps. Hence

$$
\left|\overline P_T(x)-\frac1N\right|\le \frac1T.
$$

In particular, if $N$ divides $T$, then

$$
\overline P_T(x)=\frac1N
$$

exactly for every $x$. More generally,

$$
\|\overline P_T-\pi\|_{\mathrm{TV}}
\le \frac{N}{2T}.
$$

This family separates instantaneous and averaged mixing with complete transparency: the first fails maximally, while the second converges at an elementary rate.

## 6. Spectral analysis and the gap mismatch

### 6.1 Classical contraction gaps

For a finite irreducible reversible Markov chain with transition matrix $M$, the stationary eigenvalue is $1$. Other eigenvalues often satisfy $|\lambda_j|<1$. Decomposing an initial distribution into eigenmodes gives terms of the form $\lambda_j^n$, whose magnitudes decay geometrically. A modulus gap such as

$$
\gamma=1-\max_{j\ne 1}|\lambda_j|
$$

can therefore control relaxation and mixing times.

For random transpositions on the symmetric group, representation theory supplies precise information about the classical Markov spectrum and leads to mixing on the scale of $n\log n$ under the standard formulation. This is a statement about a stochastic operator.

### 6.2 Unitary eigenvalues do not decay

If $U$ is unitary and $Uv=\lambda v$ for nonzero $v$, then

$$
\|v\|=\|Uv\|=\|\lambda v\|=|\lambda|\|v\|,
$$

so $|\lambda|=1$. Every eigenvalue can be written as

$$
\lambda_j=e^{i\theta_j}.
$$

Therefore a proposed unitary modulus gap

$$
1-|\lambda_2|
$$

is identically zero. It cannot yield a finite relaxation time through $1/\gamma$. Repeated evolution produces $e^{in\theta_j}$, a rotation of unit magnitude, rather than a decaying factor.

**Proposition 6.1 (Vanishing unitary modulus gap).** For every finite-dimensional unitary operator $U$, every eigenvalue has modulus $1$. Consequently, any spectral gap defined as $1-|\lambda|$ for a nontrivial eigenvalue vanishes.

**Proof sketch.** The norm-preservation calculation above proves $|\lambda|=1$. Substitution gives $1-|\lambda|=0$. $\square$

This does not mean that all quantum spectral information is trivial. Differences of eigenphases govern interference. If

$$
\psi=\sum_j c_jv_j,
$$

then

$$
U^n\psi=\sum_j c_je^{in\theta_j}v_j.
$$

Born probabilities contain cross-terms proportional to

$$
e^{in(\theta_j-\theta_\ell)}.
$$

These oscillate rather than decay.

### 6.3 Why time averaging can converge

For $\omega\ne 1$ on the unit circle,

$$
\frac1T\sum_{n=0}^{T-1}\omega^n
=\frac{1-\omega^T}{T(1-\omega)}.
$$

Its magnitude is bounded by

$$
\frac{2}{T|1-\omega|},
$$

which tends to zero. Thus cross-terms with unequal eigenphases vanish under Cesàro averaging. Equal-eigenphase terms persist. The limiting time-averaged distribution is determined by projections onto eigenspaces, including degeneracies, and need not be uniform.

The relevant quantitative parameter for averaging is therefore related to eigenphase separation, not the modulus contraction gap used for Markov chains.

## 7. Constructing quantum walks on Cayley graphs

A mathematical expression for one step must specify a linear operator on the entire Hilbert space and satisfy unitarity. Sending a single reference basis vector to an unnormalized sum over generators does not accomplish this. If $|S|>1$, the vector

$$
\sum_{s\in S}|s\rangle
$$

has norm $\sqrt{|S|}$, not $1$, and an action on one vector does not define the operator on its orthogonal complement.

A common discrete-time construction is the coined walk. Use the Hilbert space

$$
\mathcal H=\ell^2(G)\otimes\ell^2(S).
$$

The first register stores the group element and the second stores a direction. Let $C$ be a unitary coin on $\ell^2(S)$. Define a conditional shift, for example, by

$$
T|g,s\rangle=|sg,s\rangle.
$$

Since left multiplication by $s$ is a permutation of $G$, $T$ is unitary. One step is

$$
U=T(I\otimes C),
$$

which is unitary as a composition of unitaries.

Another model is continuous time. If $A$ is the Hermitian adjacency matrix of an undirected Cayley graph, define

$$
U(t)=e^{-itA}.
$$

This is unitary for every real $t$. Neither construction creates dissipative relaxation. Instantaneous convergence remains exceptional, while time-averaged probabilities, hitting behavior, state transfer, and response to measurement are meaningful subjects.

## 8. Algorithms and numerical diagnostics

The theoretical obstruction is elementary enough to test directly. The following procedures are useful for examples and model validation.

### 8.1 Algorithm A: coordinate evolution and recurrence audit

Given a complex matrix $U$, an initial unit vector $\psi$, a candidate period $k$, and a tolerance $\varepsilon$, compute $U^k$ and compare it with $I$ in a matrix norm. If

$$
\|U^k-I\|\le\varepsilon,
$$

then generate $P_n(x)=|(U^n\psi)(x)|^2$ for $0\le n\le k$. Compare $P_k$ with $P_0$ and report coordinate trajectories.

For a dense $d\times d$ matrix, exponentiation by repeated squaring costs $O(d^3\log k)$ arithmetic operations, while generating all $k$ iterates by matrix-vector multiplication costs $O(kd^2)$. Permutation or sparse operators can reduce the latter cost substantially.

### 8.2 Algorithm B: instantaneous and Cesàro distance comparison

For each time $n$, compute

$$
d_n=\frac12\sum_x\left|P_n(x)-\frac1d\right|
$$

and

$$
\overline d_n=\frac12\sum_x\left|\frac1n\sum_{t=0}^{n-1}P_t(x)-\frac1d\right|.
$$

A cyclic shift exhibits constant $d_n=1-1/d$ but decreasing $\overline d_n$. This diagnostic prevents an averaged phenomenon from being mislabeled as instantaneous convergence. For $T$ dense iterations, the cost is $O(Td^2)$; updating the running average costs only $O(d)$ per step.

### 8.3 Algorithm C: spectral modulus and eigenphase audit

Compute the eigenvalues $\lambda_j$ of the proposed step matrix. Report the maximum deviation of $|\lambda_j|$ from $1$. If $U$ is unitary to numerical precision, all deviations should be small. Then compute pairwise wrapped phase separations

$$
\Delta_{j\ell}=\min_{m\in\mathbb Z}|\theta_j-\theta_\ell+2\pi m|.
$$

This separates two concepts: modulus contraction, which is absent for unitary dynamics, and eigenphase spacing, which influences oscillatory averaging. Dense eigendecomposition costs $O(d^3)$, and all pairwise phase gaps cost $O(d^2)$.

### 8.4 Numerical examples

For the shift on $\mathbb Z/5\mathbb Z$, the distributions for times $0$ through $4$ are the five standard basis vectors. At every time,

$$
d_n=1-\frac15=0.8.
$$

At $T=5$, the averaged distribution is exactly

$$
(0.2,0.2,0.2,0.2,0.2),
$$

so $\overline d_5=0$. The same holds whenever $T$ is a multiple of $5$.

A second example uses the two-state swap

$$
U=\begin{pmatrix}0&1\\1&0\end{pmatrix}.
$$

Here $U^2=I$. Starting from $(1,0)^\mathsf T$, probabilities alternate between $(1,0)$ and $(0,1)$. The instantaneous distance from uniform remains $1/2$, while every even-time Cesàro average is uniform.

A third example starts from the uniform-amplitude eigenstate of the same cyclic shift:

$$
\psi(x)=\frac1{\sqrt N}.
$$

The state is fixed by the shift, so the Born distribution is uniform at every time. This illustrates the necessity and attainability of initial uniformity without contradicting the no-go theorem: no relaxation occurs because the walk begins at equilibrium.

## 9. Alternative notions of quantum mixing

### 9.1 Time-averaged mixing

Cesàro averaging is compatible with persistent oscillation. For finite-dimensional unitary evolution, the geometric-sum calculation shows that time averages always suppress cross-terms between distinct eigenvalues. The limit can depend on spectral degeneracies and the initial state. Determining when it is uniform is a nontrivial representation-theoretic question.

### 9.2 Decoherent and measured walks

An open quantum system evolves by a completely positive trace-preserving map $\Phi$ on density matrices. Unlike a unitary conjugation, $\Phi$ may have nontrivial eigenvalues strictly inside the unit disk. If the fixed state is unique and the remaining spectrum is contractive, then a genuine modulus gap can produce exponential convergence:

$$
\|\Phi^n(\rho)-\rho_*\|\le C r^n
$$

for some $r<1$. Repeated measurement, dephasing, and environmental noise can therefore create a meaningful mixing time.

### 9.3 Continuous-time averaging and hitting

For $U(t)=e^{-itA}$, instantaneous probabilities are quasiperiodic finite sums of phases. Pointwise convergence to a new distribution is again not expected. Time-integrated occupation, hitting probabilities under measurement protocols, and transport rates are better-adapted observables.

### 9.4 Approximate mixing over finite windows

One may ask whether $P_n$ is close to uniform for some time or for most times in a finite interval, without requiring a limit. A coherent walk can pass near uniform and later recur. Such transient uniformity is compatible with the present theorem, but it requires definitions that include an error tolerance and a time window.

## 10. Applications to group-based models

For finite abelian groups, characters diagonalize convolution operators. If a translation-invariant unitary is diagonal in the character basis, its eigenvalues are phases. Character expansions can then calculate return amplitudes, time averages, and recurrences explicitly.

For nonabelian groups, irreducible representations replace scalar characters with matrix-valued Fourier transforms. This framework is relevant to symmetric groups and alternating groups. In particular, transpositions generate the symmetric group, and the corresponding classical random-transposition chain has a well-studied Markov spectrum. A quantum analogue must specify a valid unitary model—such as a coined walk, a Szegedy-type construction, or continuous-time adjacency evolution—before any spectral or mixing claim can be assessed.

The no-go theorem applies immediately whenever that chosen unitary has finite order. More broadly, approximate recurrence suggests that even infinite-order unitaries in finite dimension cannot exhibit ordinary relaxation to a distinct position distribution under persistent returns.

## 11. Discussion and limitations

The main result has a precise scope. It assumes exact finite order and concerns instantaneous pointwise convergence of Born probabilities. It does not claim that every finite-dimensional unitary has finite order; irrational eigenphase ratios produce quasiperiodic rather than exactly periodic evolution. It does not exclude temporary proximity to uniform, convergence of time averages, mixing caused by measurements or noise, or computational speedups in other tasks.

Exact finite order is sufficient but not necessary for the obstruction. Suppose there is a subsequence $n_j\to\infty$ such that

$$
U^{n_j}\psi\longrightarrow\psi.
$$

Then continuity of coordinate evaluation and squared modulus gives

$$
P_{n_j}(x)\longrightarrow P_0(x).
$$

If the full sequence $P_n(x)$ converged to $p(x)$, the same subsequence would converge to $p(x)$, forcing $p(x)=P_0(x)$. Thus recurrence of the orbit, rather than exact periodicity itself, is the deeper mechanism.

Finite-dimensional unitary evolution is generated by finitely many eigenphases on a compact torus. Simultaneous approximation suggests arbitrarily accurate returns, providing a route to a general recurrence obstruction. Establishing quantitative bounds for such returns and translating them into lower bounds against sustained mixing are natural next steps.

The result also highlights a modeling issue. A graph and a generating set do not uniquely determine a discrete-time quantum walk. Choices of coin space, coin operator, shift convention, boundary behavior, and measurement protocol all matter. Universal complexity claims must quantify over a clearly specified class of dynamics and a clearly specified notion of convergence.

## 12. Future directions

1. **Time-averaged mixing.** Develop exact limiting formulas for $\overline P_T$ using spectral projections. Quantify convergence through finite geometric sums and eigenphase separation, with careful treatment of degeneracies.

2. **Decoherent or measured walks.** Replace the unitary step with a quantum channel. Determine conditions under which nontrivial eigenvalues have modulus below $1$ and derive trace-distance or total-variation mixing bounds.

3. **Coined walks on Cayley graphs.** Study the vertex-generator Hilbert space and compare different coin operators. Identify when the time-averaged vertex marginal is uniform.

4. **Continuous-time walks.** Analyze $e^{-itA}$ for Cayley adjacency operators, emphasizing average occupation, hitting protocols, and state transfer rather than unsupported instantaneous limits.

5. **Representation-theoretic diagonalization.** Use characters for abelian groups and matrix-valued Fourier analysis for groups such as $S_n$ and $A_5$. Keep the classical random-transposition operator and each quantum model spectrally distinct.

6. **Quantitative recurrence obstruction.** Extend the exact theorem to approximate returns. If $P_{n_j}$ repeatedly approaches $P_0$, derive explicit incompatibility bounds for convergence to a distribution separated from $P_0$.

7. **Counterexample families.** Collect cyclic shifts and other permutation unitaries. These offer transparent examples in which instantaneous distance from uniform remains fixed while Cesàro averages converge.

## 13. Conclusion

Finite-order coherent evolution cannot forget its initial probability profile. The proof is a direct consequence of periodicity and uniqueness of limits: the subsequence sampled every period is constantly equal to the initial value, so any alleged limit must equal that value. Applied coordinatewise to Born probabilities, this yields a complete obstruction to instantaneous pointwise uniform mixing from a localized state on a nontrivial finite space.

The conclusion changes how quantum and classical walks should be compared. A classical modulus spectral gap measures contraction, while a unitary operator has all eigenvalues on the unit circle and no such contraction gap. Quantum interference can accelerate particular tasks, but it does not turn reversible dynamics into universal relaxation. Meaningful quantum mixing theories should instead use time averages, open-system channels, measurement protocols, transient criteria, or observables adapted to recurrence.