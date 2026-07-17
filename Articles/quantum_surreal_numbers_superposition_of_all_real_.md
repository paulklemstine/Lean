# Quantum Surreal Observation: When Infinitesimal Possibilities Disappear

## A probability smaller than every ordinary number

Imagine a detector facing two doors. Behind the first is an ordinary signal. Behind the second is a signal so faint that its strength is positive, yet smaller than every positive real threshold one could name. The second signal is not zero. It lives on an infinitesimal scale.

Ordinary real numbers cannot express that distinction: a positive real number always exceeds some positive threshold. Non-Archimedean number systems can. They contain positive infinitesimals such as $\varepsilon$, satisfying

$$
0<\varepsilon<r
$$

for every positive real number $r$. They can also contain infinitely large values and still obey familiar algebraic rules. This makes them natural candidates for describing idealized physical hierarchies in which one effect is present exactly, but invisible at ordinary resolution.

Now add quantum superposition. Let basis states be labelled by surreal numbers, the vast ordered field that contains all real numbers together with infinite and infinitesimal quantities. A finite quantum surreal state has the form

$$
|\psi\rangle=\sum_i a_i|s_i\rangle,
$$

where each $s_i$ is a surreal label and each amplitude $a_i$ belongs to a non-Archimedean extension of the real numbers. The state may therefore contain branches with ordinary amplitudes and branches with genuinely infinitesimal amplitudes.

The central question is simple to ask: what does an ordinary observer see?

## Standard part as an observation map

A finite non-Archimedean number $x$ lies infinitely close to a unique ordinary real number. That real number is called its **standard part**, written $\operatorname{st}(x)$. Thus $\operatorname{st}(3+\varepsilon)=3$, while $\operatorname{st}(\varepsilon)=0$. Standard part does not claim that $\varepsilon$ equals zero. It says that the distinction disappears at real-valued observational resolution.

For a state $|\psi\rangle$, define its squared norm by

$$
\|\psi\|^2=\sum_i a_i^2.
$$

For simplicity the amplitudes here are real; complex amplitudes would replace $a_i^2$ by $|a_i|^2$. The exact Born weight of branch $i$ is

$$
w_i=\frac{a_i^2}{\|\psi\|^2},
$$

and its observed probability is

$$
p_i=\operatorname{st}(w_i).
$$

This two-level description separates exact non-Archimedean probability from ordinary observed probability.

The first basic result is normalization. For every state with nonzero squared norm, the exact weights sum to one:

$$
\sum_i w_i=1.
$$

The proof is the same cancellation familiar from ordinary quantum theory: summing the numerators reproduces $\|\psi\|^2$, which is then divided by itself. The result matters because infinitesimal probabilities are not discarded before normalization; they participate in an exact probability calculus.

The second result is the **Infinitesimal Branch Theorem**. If $a_j$ is infinitesimal and the total squared norm $\|\psi\|^2$ is appreciable—that is, not infinitesimal—then

$$
p_j=0.
$$

Indeed, $a_j^2$ is infinitesimal. Dividing it by an appreciable finite quantity leaves it infinitesimal, and standard part sends that weight to zero. The appreciability condition is essential. If the entire state lived at an even smaller scale, normalization could magnify one infinitesimal amplitude into an observed probability of one.

## The decisive two-branch experiment

Take the state

$$
|\psi_\varepsilon\rangle=|0\rangle+\varepsilon|1\rangle.
$$

Its exact squared norm is $1+\varepsilon^2$. The exact Born weights are

$$
w_0=\frac{1}{1+\varepsilon^2},\qquad
w_1=\frac{\varepsilon^2}{1+\varepsilon^2}.
$$

Both are legitimate nonnegative quantities and they add to one. Yet their observed probabilities are

$$
\operatorname{st}(w_0)=1,
\qquad
\operatorname{st}(w_1)=0.
$$

The infinitesimal branch is mathematically present but observationally absent.

There is, however, a crucial trap. Suppose one instead writes

$$
|\phi\rangle=\frac{1}{\sqrt2}|0\rangle+rac{1}{\sqrt2}|\varepsilon\rangle.
$$

The label $\varepsilon$ is infinitesimal, but its amplitude is not. Measurement probabilities depend on amplitudes, not on the arithmetic sizes of labels. More generally, if $s\ne t$ are any two surreal labels and $a\ne0$ is a common amplitude, then

$$
|\phi\rangle=a|s\rangle+a|t\rangle
$$

has squared norm $2a^2$, exact weight $1/2$ on each branch, and observed probability $1/2$ on each branch. This is the **Equal-Amplitude Obstruction**: making a basis label infinitesimal cannot suppress a branch whose amplitude remains appreciable.

That distinction is the conceptual hinge of the theory. Labels identify alternatives. Amplitudes allocate probability mass.

## A finite reservoir of infinitesimal mass

The same phenomenon appears without quantum notation. Consider $n$ visible atoms $v_1,\ldots,v_n$ and one reservoir atom $r$. Use ordered pairs of rational numbers to represent quantities

$$
(a,b)\equiv a+b\varepsilon,
$$

ordered lexicographically: the ordinary component $a$ is compared first, and the infinitesimal component $b$ breaks ties. Give every visible atom weight $\varepsilon=(0,1)$ and the reservoir weight

$$
1-n\varepsilon=(1,-n).
$$

The total is exactly one. For an event $A$, let $k(A)$ be the number of visible atoms in $A$, and let $\chi_r(A)$ equal $1$ when $r\in A$ and $0$ otherwise. Then its exact probability is

$$
\mu(A)=\bigl(\chi_r(A),\,k(A)-n\chi_r(A)\bigr).
$$

Taking standard part means retaining the first coordinate. Therefore

$$
\operatorname{st}(\mu(A))=
\begin{cases}
1,&r\in A,\\
0,&r\notin A.
\end{cases}
$$

This is precisely the Dirac probability concentrated at the reservoir. Every visible atom has exact positive infinitesimal mass but observed mass zero; the whole space has observed mass one. Moreover, because both exact probability and standard part are additive here, disjoint events remain additive after observation.

This finite model gives the quantum collapse a classical shadow. In both settings an additive non-Archimedean theory retains infinitesimal mass exactly, while standard part produces an ordinary probability supported only on appreciable branches.

## The tropical shadow

There is another way to forget small scales: tropical, or max-plus, mathematics. Ordinary addition is replaced by maximum, while multiplication becomes addition. This algebra often appears when exponential scales are converted into logarithmic rates. On a finite outcome space, a max-plus integral takes the form

$$
\mathcal{T}_W(f)=\max_x\bigl(f(x)+W(x)\bigr),
$$

where $W(x)$ is a tropical weight and $f$ is an observable.

Give the reservoir weight $W(r)=0$ and every visible atom the same negative penalty $W(v_i)=M$, where $M<0$. Then

$$
\mathcal{T}_W(f)=\max\left(f(r),\max_i(f(v_i)+M)\right).
$$

The **Reservoir Selection Theorem** says that if

$$
f(v_i)+M\le f(r)
$$

for every visible atom, then

$$
\mathcal{T}_W(f)=f(r).
$$

The proof simply examines the finite maximum: every penalized visible value is bounded above by the reservoir value, and the reservoir itself is among the candidates.

This creates a bridge between standard-part observation and tropical selection. Standard part turns the infinitesimal measure into a Dirac probability at $r$. Max-plus selection also chooses $r$, provided the observable does not reward a visible outcome enough to overcome its penalty.

The condition cannot be omitted. A visible value with $f(v_i)>f(r)-M$ wins the tropical maximum even though its standard-part probability is still zero. The two procedures therefore do not become the same arithmetic. Standard part is additive and produces probabilities; tropicalization is idempotent and selects dominant logarithmic scales. What they share is a support-selection law in a stable regime.

## A microscope with adjustable resolution

One way to picture standard part is as a microscope with a fixed macroscopic screen. The exact theory records the specimen at arbitrarily fine scale; the screen displays only its real shadow. If two finite quantities differ by an infinitesimal, the screen gives them the same reading. This is not an approximation inserted midway through the calculation. Exact arithmetic is completed first, and observation is applied afterward.

That order matters. In the epsilon state, replacing $\varepsilon$ by zero before computing the norm would happen to give the same final observed probabilities, but it would destroy the exact positive weight of the weak branch and conceal the normalization mechanism. The non-Archimedean calculation instead preserves

$$
\frac{\varepsilon^2}{1+\varepsilon^2}>0
$$

all the way to the observation map. It can therefore distinguish an impossible event, whose exact weight is zero, from an infinitesimally possible event, whose exact weight is positive but whose standard part vanishes.

The reservoir model makes this distinction especially vivid. The $n$ visible atoms jointly carry exact mass $n\varepsilon$. Their observed union still has mass zero because a finite sum of infinitesimals is infinitesimal. Meanwhile the reservoir carries $1-n\varepsilon$, slightly less than one in the exact ordering, but has observed mass one. Nothing is lost from the exact total:

$$
(1-n\varepsilon)+n\varepsilon=1.
$$

Observation changes resolution, not the prior algebra.

Tropicalization offers a different microscope. Rather than taking the real number infinitely close to a finite value, it converts competition among scales into a maximum among scores. A negative penalty marks visible branches as subdominant. The observable $f$ can tilt the competition, and the inequality $f(v_i)+M\le f(r)$ tells exactly how much tilt the reservoir can withstand. The stability margin

$$
\Delta=f(r)-\max_i\bigl(f(v_i)+M\bigr)
$$

measures the remaining protection. If $\Delta>0$, reservoir selection is robust under perturbations smaller than $\Delta$. At $\Delta=0$, the system lies on a tie boundary. If $\Delta<0$, a visible outcome escapes.

## Why the distinction matters

Infinitesimals offer a disciplined language for idealization. A branch can be nonzero without surviving ordinary observation. That idea is relevant wherever models combine exact small effects with finite-resolution outputs: rare-event asymptotics, perturbation theory, hierarchical optimization, Bayesian models with vanishing priors, and multiscale physical systems.

The results also impose boundaries. One cannot hide an outcome by giving it a tiny label. One cannot equate standard-part expectation with tropical maximization for arbitrary observables. And one cannot erase the appreciability hypothesis from the infinitesimal branch theorem. Each limitation reveals which structure is doing the work.

The emerging picture has three layers. Exact non-Archimedean normalization remembers every infinitesimal contribution. Standard part maps that exact theory to ordinary additive probability. Tropicalization records dominant scale and, under a quantitative stability inequality, selects the same surviving outcome. The reservoir stands at the intersection: probability one in the classical shadow, maximal weight in the tropical shadow, and the sole appreciable branch in the quantum example.

A probability may be positive and still leave no ordinary trace. The mathematics does not confuse absence with invisibility; it explains precisely how one becomes the other.