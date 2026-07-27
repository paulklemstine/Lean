# Finite-Volume Spin-Flip Symmetry, Transfer Matrices, and the Peierls Route to Ising Order

## Abstract

We develop a self-contained account of several exact structures surrounding the Ising model and clarify a crucial scope distinction in the language of spontaneous magnetization. For a finite state space, we define the partition function and Gibbs expectation and prove a general cancellation theorem: if an involution preserves energy and reverses an observable, then the Gibbs expectation of that observable is exactly zero at every inverse temperature. Applied to global spin flip, this rules out strictly positive signed magnetization in every finite zero-field symmetric ensemble, regardless of how low the temperature is. We then describe the periodic square-lattice Hamiltonian, its elementary energy and magnetization bounds, the exact diagonalization of the zero-field $2\times2$ transfer matrix, and the resulting periodic-chain partition function. The distinguished two-dimensional self-dual parameters

$$
\beta_c=\frac{\log(1+\sqrt2)}2,
\qquad
T_c=\frac2{\log(1+\sqrt2)}
$$

are characterized by $\sinh(2\beta_c)=1$, together with equivalent bond identities. Finally, we analyze the geometric contour majorant underlying the Peierls method and prove the algebraic implication from a defect probability below $1/2$ to positive local magnetization. These results separate exact finite-volume symmetry from phase-selected infinite-volume order and identify the additional geometric and thermodynamic steps required for a complete phase-transition theorem.

## 1. Introduction

The Ising model is a minimal model of cooperative order. A spin $\sigma_x\in\{-1,+1\}$ occupies each lattice site $x$, neighboring spins interact, and temperature determines the balance between energetic alignment and entropic disorder. The simplicity of the local rule conceals several logically distinct mathematical questions:

- How are finite-volume energy, magnetization, and Gibbs expectations defined?
- What does global spin-flip symmetry force in a finite box?
- How can transfer matrices compress sums over many configurations?
- Which exact identity determines the square-lattice self-dual parameter?
- How does a Peierls contour estimate imply positive magnetization in a phase-selected state?

A common informal statement says that below the critical temperature a finite zero-field Ising magnet has positive expected magnetization. Taken literally for the symmetric Gibbs measure, this is false. The global spin flip pairs every configuration of magnetization $m$ with one of magnetization $-m$ and identical energy. Hence the expectation is exactly zero. Low-temperature order is instead visible through even observables, through a bimodal magnetization distribution, or through a state selected by boundary conditions or an external field before the thermodynamic limit.

The purpose of this paper is to make that distinction precise while collecting exact algebraic and analytic ingredients used in the standard Ising narrative. The strongest theorem is deliberately model-independent: every finite Gibbs system with an energy-preserving involution has zero expectation for every odd observable. We then specialize the surrounding discussion to Ising spins.

Throughout, the coupling strength $J$ and Boltzmann constant $k_B$ are set equal to one. Thus inverse temperature is $\beta=1/T$.

## 2. Finite periodic square-lattice model

### 2.1 Sites and configurations

Fix positive integers $m,n$. The periodic square lattice is

$$
\Lambda_{m,n}=\mathbb Z/m\mathbb Z\times\mathbb Z/n\mathbb Z.
$$

Its cardinality is $N=mn$. Each site has a right neighbor and an upward neighbor, with coordinates interpreted cyclically. A spin configuration is a function

$$
\sigma:\Lambda_{m,n}\longrightarrow\{-1,+1\}.
$$

Counting each horizontal and vertical bond once, the zero-field ferromagnetic Hamiltonian is

$$
H(\sigma)
=-\sum_{x\in\Lambda_{m,n}}
\left(\sigma_x\sigma_{x+e_1}+\sigma_x\sigma_{x+e_2}\right).
$$

The total magnetization is

$$
M(\sigma)=\sum_{x\in\Lambda_{m,n}}\sigma_x.
$$

These definitions have immediate extremal consequences.

**Proposition 2.1 (All-up energy).** For the configuration $\sigma_x=+1$ at every site,

$$
H(\sigma)=-2N.
$$

**Proof sketch.** Every one of the $2N$ counted bonds has product $+1$, and each contributes $-1$. $\square$

**Proposition 2.2 (Universal ground-energy bound).** Every configuration satisfies

$$
H(\sigma)\ge -2N.
$$

**Proof sketch.** Each bond product is either $-1$ or $+1$, so each Hamiltonian summand is at least $-1$. There are $2N$ summands. $\square$

**Proposition 2.3 (Magnetization bound).** Every configuration satisfies

$$
|M(\sigma)|\le N.
$$

**Proof sketch.** Apply the triangle inequality to the sum of $N$ spins, each of absolute value one. $\square$

### 2.2 Global spin flip

Define the global flip by

$$
(F\sigma)_x=-\sigma_x.
$$

Then $F(F\sigma)=\sigma$. Moreover,

$$
H(F\sigma)=H(\sigma)
$$

because each bond product acquires two minus signs, while

$$
M(F\sigma)=-M(\sigma).
$$

Thus energy is even and magnetization is odd under the same involution. This is the structural input for the finite-volume cancellation theorem.

## 3. Finite Gibbs ensembles and exact cancellation

The cancellation mechanism does not depend on a lattice or on pair interactions, so we state it abstractly.

### 3.1 Definitions

Let $\Omega$ be a finite, nonempty state space, let $E:\Omega\to\mathbb R$ be an energy function, and let $A:\Omega\to\mathbb R$ be an observable. For inverse temperature $\beta\in\mathbb R$, define the partition function

$$
Z_\beta(E)=\sum_{\omega\in\Omega}e^{-\beta E(\omega)}.
$$

Define the unnormalized first moment

$$
N_\beta(E,A)=
\sum_{\omega\in\Omega}e^{-\beta E(\omega)}A(\omega),
$$

and the Gibbs expectation

$$
\langle A\rangle_{\beta,E}
=\frac{N_\beta(E,A)}{Z_\beta(E)}.
$$

**Lemma 3.1 (Positivity of the partition function).** If $\Omega$ is nonempty, then

$$
Z_\beta(E)>0
$$

for every real $\beta$ and every real-valued energy $E$.

**Proof sketch.** Every exponential $e^{-\beta E(\omega)}$ is strictly positive, and a nonempty finite sum of positive terms is positive. $\square$

The positivity lemma ensures that Gibbs expectation is a genuine normalization rather than a potentially singular quotient.

### 3.2 The symmetry theorem

Suppose $F:\Omega\to\Omega$ is involutive:

$$
F(F(\omega))=\omega
\quad\text{for all }\omega\in\Omega.
$$

Assume also

$$
E(F(\omega))=E(\omega)
$$

and

$$
A(F(\omega))=-A(\omega).
$$

**Theorem 3.2 (Vanishing of odd first moments).** Under these assumptions,

$$
N_\beta(E,A)=0
$$

for every $\beta\in\mathbb R$.

**Proof sketch.** Since an involution is a bijection, reindexing the finite sum by $F$ does not change it:

$$
N_\beta(E,A)
=\sum_{\omega\in\Omega}
 e^{-\beta E(F(\omega))}A(F(\omega)).
$$

Energy invariance and oddness transform the right-hand side into

$$
\sum_{\omega\in\Omega}e^{-\beta E(\omega)}[-A(\omega)]
=-N_\beta(E,A).
$$

Hence $N_\beta(E,A)=-N_\beta(E,A)$, which implies $N_\beta(E,A)=0$. Equivalently, one may partition the state space into two-element flip orbits and fixed points. Contributions cancel on each two-element orbit, while a fixed point must have $A(\omega)=0$. $\square$

**Theorem 3.3 (Finite-volume symmetry theorem).** Under the assumptions of Theorem 3.2,

$$
\langle A\rangle_{\beta,E}=0
$$

for every $\beta\in\mathbb R$.

**Proof sketch.** The numerator vanishes by Theorem 3.2 and the denominator is positive by Lemma 3.1. $\square$

**Corollary 3.4 (No positive finite-volume symmetric magnetization).** In a finite zero-field Ising ensemble with global spin-flip symmetry, there exists no inverse temperature $\beta$ for which

$$
\langle M\rangle_\beta>0.
$$

**Proof sketch.** Global spin flip is involutive, preserves the Hamiltonian, and negates total magnetization. Theorem 3.3 therefore gives $\langle M\rangle_\beta=0$ for every $\beta$, contradicting strict positivity. $\square$

### 3.3 Interpretation

Corollary 3.4 does not say that a cold finite sample is disordered. The magnetization distribution may place almost all its mass near $+N$ and $-N$ while assigning equal weight to both regions. Signed expectation then vanishes, but even observables such as $|M|$ and $M^2$ can be large.

Spontaneous magnetization is obtained only after selecting a phase. Two standard prescriptions are:

1. impose plus boundary conditions and take an increasing-volume limit;
2. introduce a field $h>0$, take the thermodynamic limit, and then let $h\downarrow0$.

The order of these operations matters. Removing the selector in each finite volume restores exact cancellation.

## 4. Transfer-matrix calculation

### 4.1 The zero-field bond matrix

For a nearest-neighbor pair $s,t\in\{-1,+1\}$, the Boltzmann factor is $e^{\beta st}$. In the ordered basis $+1,-1$, this yields

$$
V_\beta=
\begin{pmatrix}
e^\beta&e^{-\beta}\\
e^{-\beta}&e^\beta
\end{pmatrix}.
$$

The vectors $(1,1)^T$ and $(1,-1)^T$ are eigenvectors. Their eigenvalues are

$$
\lambda_+=e^\beta+e^{-\beta}=2\cosh\beta,
$$

and

$$
\lambda_-=e^\beta-e^{-\beta}=2\sinh\beta.
$$

Let

$$
P_+=\frac12
\begin{pmatrix}1&1\\1&1\end{pmatrix},
\qquad
P_-=\frac12
\begin{pmatrix}1&-1\\-1&1\end{pmatrix}.
$$

These are complementary projectors: $P_+^2=P_+$, $P_-^2=P_-$, $P_+P_-=0$, and $P_++P_-=I$. Therefore

$$
V_\beta=\lambda_+P_++\lambda_-P_-
$$

and, for every integer $n\ge0$,

$$
V_\beta^n=\lambda_+^nP_++\lambda_-^nP_-.
$$

Written entrywise,

$$
V_\beta^n=rac12
\begin{pmatrix}
\lambda_+^n+\lambda_-^n&\lambda_+^n-\lambda_-^n\\
\lambda_+^n-\lambda_-^n&\lambda_+^n+\lambda_-^n
\end{pmatrix}.
$$

**Theorem 4.1 (Periodic-chain partition function).** For a zero-field periodic Ising chain of length $n$,

$$
Z_n(\beta)=\operatorname{tr}(V_\beta^n)
=(2\cosh\beta)^n+(2\sinh\beta)^n.
$$

**Proof sketch.** Expanding the trace of the transfer-matrix product sums $e^{\beta\sum_i\sigma_i\sigma_{i+1}}$ over all periodic spin configurations. Diagonalization then gives the trace as the sum of the two eigenvalues raised to the $n$th power. $\square$

The calculation replaces a sum over $2^n$ configurations by exponentiation of two scalars. Numerically, the closed form requires a constant number of transcendental evaluations and exponentiations, whereas direct enumeration requires $O(n2^n)$ elementary spin operations.

## 5. The square-lattice self-dual point

Define

$$
\beta_c=\frac12\log(1+\sqrt2)
$$

and

$$
T_c=\frac1{\beta_c}
=\frac2{\log(1+\sqrt2)}.
$$

The logarithm is positive because $1+\sqrt2>1$, so both parameters are positive.

**Theorem 5.1 (Kramers–Wannier fixed-point identity).** The parameter $\beta_c$ satisfies

$$
\sinh(2\beta_c)=1.
$$

**Proof sketch.** Set $a=1+\sqrt2$. Then $e^{2\beta_c}=a$ and $e^{-2\beta_c}=a^{-1}$. Rationalizing gives

$$
a^{-1}=\frac1{1+\sqrt2}=\sqrt2-1.
$$

Therefore

$$
\sinh(2\beta_c)
=\frac{a-a^{-1}}2
=\frac{(1+\sqrt2)-(\sqrt2-1)}2=1.
$$

$\square$

Because $\sinh x$ is strictly increasing, the equation $\sinh(2\beta)=1$ has at most one real solution and hence $\beta_c$ is its unique positive solution.

**Proposition 5.2 (Reciprocity).** The temperature and inverse temperature obey

$$
\beta_cT_c=1.
$$

**Proof sketch.** This follows immediately from the definitions and positivity of $\log(1+\sqrt2)$. $\square$

**Proposition 5.3 (Equivalent bond identities).** At the self-dual point,

$$
e^{-2\beta_c}=\sqrt2-1
$$

and

$$
\tanh\beta_c=\sqrt2-1.
$$

**Proof sketch.** The first identity is the rationalization used above. For the second, write $x=e^{2\beta_c}=1+\sqrt2$ and use

$$
\tanh\beta_c=\frac{x-1}{x+1}.
$$

Substitution and simplification yield $\sqrt2-1$. $\square$

**Proposition 5.4 (Numerical bracket).** The self-dual temperature satisfies

$$
2<T_c<3.
$$

**Proof sketch.** The claim is equivalent to

$$
\frac23<\log(1+\sqrt2)<1.
$$

These inequalities follow from standard monotonic bounds for the exponential and logarithm, together with elementary bounds on $\sqrt2$. Numerically, $T_c\approx2.2691853$. $\square$

The identity $\sinh(2\beta_c)=1$ characterizes the positive self-dual point exactly. Identifying this point with the unique thermodynamic singularity additionally requires an infinite-volume free-energy analysis; self-duality by itself is not a proof of singular behavior.

## 6. Peierls contour majorants

### 6.1 Energetic suppression and contour counting

Consider a square region with plus boundary conditions. If the spin at a chosen interior site is minus, the cluster of minus spins containing that site is separated from the surrounding plus phase by one or more dual-lattice contours. A contour of length $L$ crosses $L$ disagreeing bonds. Flipping the enclosed droplet changes each crossed bond from disagreeing to agreeing and lowers the energy by $2L$. Consequently the relative Boltzmann factor carries an energetic penalty $e^{-2\beta L}$.

A coarse contour count bounds the number of possible continuations at each step by $3$, leading to a majorant proportional to $3^L$. The resulting analytic series is

$$
S_{L_0}(\beta)=
\sum_{L=L_0}^{\infty}\left(3e^{-2\beta}\right)^L.
$$

The starting length $L_0$ depends on the geometry; for a square-lattice contour it is at least $4$. The following statements hold for arbitrary positive $L_0$.

**Theorem 6.1 (Convergence and closed form).** If

$$
q(\beta)=3e^{-2\beta}<1,
$$

then

$$
S_{L_0}(\beta)=\frac{q(\beta)^{L_0}}{1-q(\beta)}.
$$

**Proof sketch.** This is the geometric-series identity. Since $0<q(\beta)<1$, the tail $q^L$ tends to zero and the partial sums converge to the displayed quotient. $\square$

The condition $q(\beta)<1$ is equivalent to

$$
\beta>\frac12\log3.
$$

Furthermore, $q(\beta)$ decreases to zero as $\beta$ increases, so the closed form also decreases to zero.

**Theorem 6.2 (Existence of a Peierls threshold).** For every fixed positive integer $L_0$, there is a finite $\beta_0$ such that, for all $\beta>\beta_0$,

$$
S_{L_0}(\beta)<\frac12.
$$

**Proof sketch.** Since $q(\beta)=3e^{-2\beta}\to0$, choose any $r\in(0,1)$ satisfying $r^{L_0}/(1-r)<1/2$. Then choose $\beta_0$ so that $q(\beta)<r$ for $\beta>\beta_0$. Monotonicity of $q^{L_0}/(1-q)$ on $(0,1)$ gives the result. This also yields an explicit threshold once a concrete rational $r$ is selected. $\square$

### 6.2 From defect probability to magnetization

Let $p$ denote the probability that a chosen spin is $-1$ in a phase-selected ensemble. Its local expected spin is

$$
\mathbb E[\sigma_x]
=(+1)(1-p)+(-1)p=1-2p.
$$

**Theorem 6.3 (Peierls probability criterion).** If $p\le C$ and $C<1/2$, then

$$
\mathbb E[\sigma_x]=1-2p>0.
$$

**Proof sketch.** From $p\le C<1/2$ we have $2p<1$, hence $1-2p>0$. $\square$

This theorem is the algebraic endpoint of the Peierls argument. To invoke it for an actual finite-volume Gibbs probability, one must prove the geometric estimate $p\le S_{L_0}(\beta)$, including a contour construction, an injection or multiplicity control, and treatment of boundary geometry. The convergence and threshold of the analytic majorant do not alone prove that probabilistic estimate.

## 7. Algorithms and numerical demonstrations

### 7.1 Direct finite-ensemble expectation

Given a finite list of states with energies $E_i$ and observables $A_i$, compute stable weights by subtracting the largest log-weight. Let

$$
\ell_i=-\beta E_i,
\qquad
m=\max_i\ell_i,
\qquad
\widetilde w_i=e^{\ell_i-m}.
$$

Then

$$
\langle A\rangle=
\frac{\sum_i\widetilde w_iA_i}{\sum_i\widetilde w_i}.
$$

The common factor $e^m$ cancels. The algorithm uses $O(|\Omega|)$ time and $O(1)$ auxiliary space if processed in two passes. Pairing states under an exact flip makes the theoretical zero transparent; floating-point output should be interpreted with a tolerance.

### 7.2 Transfer-matrix partition function

For a periodic chain, evaluate $\lambda_+=2\cosh\beta$ and $\lambda_-=2\sinh\beta$, then return $\lambda_+^n+\lambda_-^n$. This takes $O(1)$ arithmetic operations when scalar exponentiation is treated as primitive, or $O(\log n)$ multiplications under exponentiation by squaring. For very large $n$, a logarithmic implementation avoids overflow.

### 7.3 Peierls majorant

Compute $q=3e^{-2\beta}$. If $q\ge1$, the geometric majorant does not converge. If $q<1$, return $q^{L_0}/(1-q)$. This is constant-time apart from elementary function evaluation. Comparing the result with $1/2$ determines whether the analytic criterion is strong enough to imply positivity, provided a corresponding contour probability bound has been established.

## 8. Applications and conceptual consequences

### 8.1 Symmetry as an orbit decomposition

The proof of the cancellation theorem may be understood as a decomposition of $\Omega$ into orbits of the two-element symmetry group. Every orbit is either a pair $\{\omega,F(\omega)\}$ or a singleton fixed point. The Gibbs weight is constant on each orbit. An odd observable sums to zero on a paired orbit, and it must itself be zero on a singleton orbit. This orbitwise view shows that no probabilistic limiting argument is involved and that fixed-point freeness is unnecessary.

More generally, the same idea extends to finite group actions. If a finite group preserves the energy, then Gibbs expectation commutes with averaging an observable over the group. Any observable whose group average is identically zero consequently has zero Gibbs expectation. The involutive theorem is the simplest instance and is sufficient for Ising spin reversal.

### 8.2 Finite-size observables

The vanishing first moment motivates better diagnostics for finite systems. Under spin flip, $M^2$, $|M|$, and every even function of $M$ are invariant. They can therefore distinguish a high-temperature distribution concentrated near zero from a low-temperature bimodal distribution concentrated near $\pm m_*N$, even though both distributions have zero signed mean. The susceptibility is commonly related to the variance

$$
\operatorname{Var}(M)=\langle M^2\rangle-\langle M\rangle^2.
$$

In the symmetric finite ensemble, $\langle M\rangle=0$, so this reduces to $\langle M^2\rangle$. Correlations such as $\langle\sigma_x\sigma_y\rangle$ are also even and survive symmetry averaging.

The finite-volume cancellation theorem applies well beyond ferromagnets. Whenever a finite statistical model has an involution preserving energy, all odd observables have zero expectation. Examples include particle-hole symmetries, sign-reversal symmetries in field truncations, and paired combinatorial ensembles. The theorem is insensitive to whether the symmetry has fixed points; oddness forces the observable to vanish at each fixed point.

For simulation practice, the theorem is a diagnostic. A zero-field finite simulation that reports a persistent nonzero signed magnetization may be insufficiently equilibrated, trapped in one metastable sector, deliberately phase-selected, or affected by numerical or implementation bias. Conversely, a mean near zero does not prove disorder. Histograms, absolute magnetization, susceptibility, correlation length, and finite-size scaling reveal information hidden by the first moment.

The transfer-matrix formula gives a compact benchmark for numerical codes. Direct enumeration of small periodic chains must agree with

$$
(2\cosh\beta)^n+(2\sinh\beta)^n.
$$

Likewise, the self-dual identities provide mutually reinforcing numerical checks:

$$
\sinh(2\beta_c)=1,
\qquad
\tanh\beta_c=e^{-2\beta_c}=\sqrt2-1,
\qquad
\beta_cT_c=1.
$$

The Peierls majorant illustrates energy–entropy competition. Energy suppresses long interfaces by $e^{-2\beta L}$, while entropy multiplies their number exponentially. Order is accessible when energetic decay wins, here at least when the coarse factor $3e^{-2\beta}$ is sufficiently small.

## 9. Scope, limitations, and future work

The exact results assembled here establish finite periodic-lattice definitions and elementary bounds, exact spin-flip behavior, transfer-matrix diagonalization for the $2\times2$ zero-field matrix, the periodic-chain partition function, characterization of the positive square-lattice self-dual point, convergence and evaluation of a Peierls contour majorant, and the final probability-to-magnetization implication.

Two boundaries should be explicit.

First, the equation $\sinh(2\beta_c)=1$ determines the Kramers–Wannier self-dual point. A complete derivation of the two-dimensional thermodynamic phase transition requires the infinite-volume free energy and a proof identifying its singularity. The self-dual identity alone is not that derivation.

Second, the analytic contour series is ready for use once one has bounded a minus-spin event by the contour sum. Completing a lattice-specific Peierls theorem requires the geometric contour injection and its connection to the Gibbs probability under phase-selecting boundary conditions.

Natural future work therefore includes: constructing the contour map for finite square boxes with plus boundary conditions; proving the required multiplicity and energy-change estimates; passing local magnetization bounds to an infinite-volume Gibbs state; developing finite-width row transfer matrices for the two-dimensional model; deriving the thermodynamic free energy; and proving that the self-dual point is the unique singular point. It would also be useful to analyze even observables and the bimodal finite-volume magnetization distribution quantitatively, thereby connecting exact symmetry cancellation to finite-size scaling.

## 10. Conclusion

Finite-volume symmetry and spontaneous symmetry breaking are compatible because they refer to different mathematical objects. In every finite zero-field ensemble with exact global spin-flip symmetry, signed magnetization has expectation zero at every temperature. This is an exact consequence of pairing states, not an approximation and not a high-temperature phenomenon.

To obtain positive magnetization, one must select a phase before removing the finite-volume regulator. The Peierls strategy explains how low temperature stabilizes that choice: contours cost energy, sufficiently long domain walls become rare, and a defect probability below $1/2$ forces positive local magnetization. Transfer matrices and self-duality add exact algebraic structure, including the periodic-chain partition function and the distinguished parameter $T_c=2/\log(1+\sqrt2)$.

Together these results provide a precise hierarchy: symmetry determines what cannot occur in a finite unbiased ensemble; transfer matrices calculate finite systems efficiently; duality identifies a distinguished candidate critical point; and contour geometry supplies a route to phase-selected order. Keeping those layers separate is essential to a rigorous understanding of the Ising transition.

A useful practical principle follows. Before interpreting a nonzero order parameter, one should specify the finite or infinite volume, the boundary condition, the external field, and the order in which limits are taken. Before interpreting a zero order parameter, one should ask whether symmetry cancellation may conceal a broad or bimodal distribution. These questions turn an apparent contradiction into a coherent picture of collective order.

The framework also separates universal reasoning from model-specific geometry. The involution theorem needs only finiteness and symmetry; the transfer-matrix calculation needs the particular nearest-neighbor bond weight; the self-dual identity uses the square-lattice duality parameter; and the Peierls estimate needs a contour representation. This modular structure indicates exactly which conclusions survive when the lattice, interaction, or state space changes.