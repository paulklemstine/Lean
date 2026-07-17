# Holographic Primes: From Boundary Products to Bulk Worlds

## A finite universe hidden inside multiplication

Prime numbers are usually introduced as indivisible building blocks. Every positive integer factors uniquely into primes, so primes seem to live at the smallest scale of arithmetic. Yet a simple partition function reveals a second personality: each prime can also act as an independent physical mode, capable of holding any prescribed number of identical quanta. When the contributions of those local modes are multiplied, the result is exactly a sum over an entire many-body universe.

This is the finite prime hologram. It is “holographic” in a precise but modest sense. A product assembled locally at a boundary and a sum over global configurations in a bulk are not merely analogous; with finite cutoffs, they are equal term by term after expansion. The identity requires no speculative geometry. It follows from distributivity and the elementary law that turns sums in an exponential into products. Its value lies in exposing the configuration space concealed inside an Euler product.

The construction also has a tropical, or zero-temperature, shadow. If the energy of the mode associated with a prime $p$ is $\log p$, then every excitation costs nonnegative energy. The empty configuration costs exactly zero. Consequently, as temperature falls and the partition function concentrates on the cheapest states, the selected ground-state energy is always zero.

These facts establish a rigorous core for a broader metaphor connecting prime numbers, statistical mechanics, and holography. They also draw a sharp border around what has *not* been established: the functional equation of the completed zeta function, the statistics of its zeros, and the Riemann Hypothesis do not follow from finite factorization alone.

## Local prime modes

Begin with a finite collection $I$ of modes. Assign to each mode $i\in I$ a real energy $E_i$. Fix an occupation cutoff $N\geq 0$, so mode $i$ may contain $0,1,\ldots,N$ quanta. An occupation profile is a function

$$
a:I\longrightarrow \{0,1,\ldots,N\}.
$$

Its bulk Hamiltonian is the additive energy

$$
H(a)=\sum_{i\in I}a_iE_i.
$$

At inverse temperature $\beta$, the profile receives Boltzmann weight $e^{-\beta H(a)}$. Summing over all profiles gives the bulk partition function

$$
Z_{\mathrm{bulk}}(\beta)=\sum_{a:I\to\{0,\ldots,N\}}e^{-\beta H(a)}.
$$

A boundary observer can instead study each mode separately. For mode $i$, the local partition sum is

$$
Z_i(\beta)=\sum_{n=0}^{N}e^{-\beta nE_i}.
$$

Multiplying all local sums gives

$$
Z_{\mathrm{boundary}}(\beta)=\prod_{i\in I}Z_i(\beta).
$$

At first glance, the two formulas organize information differently. The boundary expression is a product of short one-dimensional sums. The bulk expression is one enormous sum over $(N+1)^{|I|}$ profiles. The Finite Holographic Factorization Theorem says they are identical:

$$
Z_{\mathrm{boundary}}(\beta)=Z_{\mathrm{bulk}}(\beta).
$$

Why? Expand the product. Choosing one summand from each local factor is the same as choosing one occupation number $a_i$ for every mode. The selected term is

$$
\prod_{i\in I}e^{-\beta a_iE_i}
=e^{-\beta\sum_{i\in I}a_iE_i}
=e^{-\beta H(a)}.
$$

Every bulk profile appears exactly once. The theorem is therefore an exact dictionary: local multiplication and global enumeration encode the same finite system.

## Why primes fit the dictionary

Choose a cutoff $x$ and let the modes be the primes $p<x$. Give prime $p$ the energy

$$
E_p=\log p.
$$

The local Boltzmann factor then becomes

$$
e^{-\beta n\log p}=p^{-\beta n}.
$$

The boundary partition function is the finite product

$$
Z_{x,N}^{\mathrm{boundary}}(\beta)
=\prod_{\substack{p<x\\p\ \mathrm{prime}}}
\sum_{n=0}^{N}p^{-\beta n},
$$

while the bulk partition function is

$$
Z_{x,N}^{\mathrm{bulk}}(\beta)
=\sum_{a}
\exp\!\left(-\beta\sum_{\substack{p<x\\p\ \mathrm{prime}}}a_p\log p\right),
$$

where each $a_p$ lies between $0$ and $N$. The Prime Holographic Factorization Theorem states that these quantities agree for every cutoff $x$, every occupation cap $N$, and every real $\beta$.

There is also a classical arithmetic picture. A profile $a$ determines the integer

$$
m(a)=\prod_{p<x}p^{a_p}.
$$

Its energy is $H(a)=\log m(a)$, and its weight is $m(a)^{-\beta}$. Unique factorization says that different exponent profiles produce different integers. Thus the bulk is a space of integers whose prime factors and exponents obey the chosen cutoffs. The boundary product does not merely approximate this space; it generates it exactly.

For example, with modes $2$ and $3$ and cutoff $N=2$, the boundary is

$$
(1+2^{-\beta}+2^{-2\beta})(1+3^{-\beta}+3^{-2\beta}).
$$

Expanding yields nine terms, corresponding to the nine integers

$$
1,\ 2,\ 4,\ 3,\ 6,\ 12,\ 9,\ 18,\ 36.
$$

The order is irrelevant; the occupation lattice and the product expansion contain the same nine weighted states.

## Removing the occupation cutoff

If the cap $N$ is allowed to grow without bound while the prime cutoff remains finite, each local sum becomes geometric:

$$
\sum_{n=0}^{\infty}p^{-\beta n}=\frac{1}{1-p^{-\beta}}
$$

whenever $\beta>0$. This gives a finite Euler product over the selected primes. If the prime cutoff is then removed in the region $\beta>1$, absolute convergence gives the Infinite Prime Partition Identity:

$$
Z_{\mathrm{prime}}(\beta)
=\prod_{p}\frac{1}{1-p^{-\beta}}
=\zeta(\beta).
$$

Here $\zeta$ is the Riemann zeta function. Equivalently, the additive logarithmic free-energy representation is

$$
\exp\!\left(\sum_p-\log(1-p^{-\beta})\right)=\zeta(\beta),
\qquad \beta>1.
$$

This is the global statement justified by the convergent Euler product. It should not be silently extended past $\beta=1$: there the product ceases to converge in the ordinary sense, even though the zeta function has an analytic continuation. Analytic continuation contains information not supplied by the elementary occupation expansion.

## Tropicalization: cooling the prime universe

A partition sum blends all states, but low temperature favors those of least energy. Tropical mathematics captures this passage from addition to minimization. For a finite Hamiltonian $H$, define its tropical partition function to be the infimum of its energies:

$$
Z_{\mathrm{trop}}(H)=\inf_a H(a).
$$

For prime energies, every term $a_p\log p$ is nonnegative because $a_p\geq 0$ and $\log p\geq 0$ for every prime. Therefore $H(a)\geq 0$ for every profile. The vacuum profile, in which every occupation number is zero, has $H=0$. The Tropical Vacuum Theorem follows:

$$
Z_{\mathrm{trop}}(H)=0.
$$

This remains true even when the prime set is empty: then there is one empty profile, again with zero energy. The result is stable under every finite prime cutoff and every occupation cutoff.

The ordinary partition function also displays this concentration. If $M=(N+1)^{|I|}$ is the number of profiles and all energies are nonnegative, then

$$
1\leq Z_{\mathrm{bulk}}(\beta)\leq M.
$$

Hence the normalized logarithmic free energy satisfies

$$
0\leq \frac{1}{\beta}\log Z_{\mathrm{bulk}}(\beta)
\leq \frac{1}{\beta}\log M,
$$

which tends to zero as $\beta\to\infty$. The thermal description therefore converges to the tropical vacuum value, with an elementary finite-state error bound.

## What the holographic language adds

The identity is algebraically simple, but its organization is useful. The boundary stores one local rule for each prime. The bulk stores all simultaneous occupation patterns. Multiplication on one side becomes enumeration on the other. Additive energies become multiplicative arithmetic through

$$
\exp\!\left(-\beta\sum_pa_p\log p\right)
=\prod_pp^{-\beta a_p}.
$$

This is a general design pattern in statistical mechanics, generating functions, and combinatorics. A factored representation can be exponentially more compact than explicit state enumeration: the boundary description uses roughly $|I|(N+1)$ local terms, while the bulk contains $(N+1)^{|I|}$ states. The equality explains why dynamic programming and tensor-product methods can calculate global quantities without listing every configuration.

The prime case is especially evocative because unique factorization gives each bulk state a familiar arithmetic identity. It also points toward computation. One may compare direct enumeration with product evaluation, measure the truncation error as $N$ grows, and watch the normalized free energy approach zero as $\beta$ increases.

## A laboratory small enough to inspect

The cutoffs make the model unusually transparent. A researcher can calculate the same quantity in two independent ways: multiply the local prime sums, or enumerate every occupation vector and add its weight. Agreement tests the exact theorem; changing $N$, $x$, or $\beta$ then reveals different phenomena. Raising $N$ admits larger prime powers. Raising $x$ adds new prime species. Raising $\beta$ cools the system and suppresses every excited state.

This separation matters in numerical work. If the two finite calculations disagree, the cause is computational error, not approximation. If both agree but differ from $\zeta(\beta)$, the gap comes from finite cutoffs. One can therefore diagnose the model layer by layer rather than confronting an opaque global discrepancy.

The temperature parameter offers the most immediate visual story. Near $\beta=0$, all finite profiles have nearly equal weight and the partition sum approaches the number of states. At large positive $\beta$, profiles representing large integers fade first, then smaller excitations, until the integer $1$—the vacuum with no prime factors—dominates. Arithmetic size becomes physical energy through the logarithm, and cooling sorts integers by that energy.

## The frontier beyond the finite theorem

The completed zeta function includes an archimedean gamma factor and obeys a reflection law relating $s$ to $1-s$. Neither feature emerges from a finite product of ordinary prime modes. A credible extension must add the missing infinite-place sector and explain analytic continuation, rather than declaring the finite identity to be a proof of a global duality.

Likewise, pair correlations of high zeta zeros and their resemblance to random-matrix statistics are genuinely spectral questions. Independent prime occupations settle the one-point partition normalization but do not automatically produce those correlations. Finally, interpreting the Riemann Hypothesis as “stability” is a research proposal until a precise geometry, perturbation theory, and equivalence theorem are supplied.

The finite prime hologram is valuable precisely because it separates theorem from aspiration. What is established is clean: boundary Euler products are bulk Gibbs sums; the convergent infinite prime partition equals $\zeta(\beta)$ for $\beta>1$; and tropicalization selects a zero-energy vacuum. What lies beyond is a focused program: control both cutoffs, construct the archimedean sector, tropicalize the functional equation, and test whether fluctuation statistics carry truly spectral information.

A small algebraic identity has opened a wide conceptual window. Behind a product over primes stands a many-body landscape of occupations; beneath its thermal sum lies a tropical vacuum. The hologram is finite, exact, and already rich enough to show how arithmetic can be read as statistical mechanics—without asking metaphor to do the work of proof.
