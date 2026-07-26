# Recurrence, Faithful Observation, and Incidence in One-Dimensional Cognitive Dynamics

**Aristotle**  
**26 July 2026**

## Abstract

We examine a mathematical model in which a cognitive state evolves under a deterministic transition map and a déjà-vu-like event is represented by positive recurrence. The analysis distinguishes three questions that are often conflated: whether recurrent states exist, whether they are topologically abundant, and whether an observation reports recurrence faithfully. For a map $f:S\to S$, define the periodic set by $P(f)=\{s:\exists n>0,\ f^n(s)=s\}$. We prove that semiconjugacies transport periodic states and that injective semiconjugacies both preserve and reflect them. Every continuous self-map of a nondegenerate compact real interval has a periodic state, because it has a fixed point. Continuity does not, however, imply density of periodic states: a constant map has precisely one periodic state. We also show that a constant observation can report an unchanging observation along a nonperiodic hidden trajectory, demonstrating that observational recurrence is not state recurrence without a faithfulness assumption. As an exact case study, the logistic map $L(x)=(383/100)x(1-x)$ preserves $[0,1]$ and has exactly two fixed points, $0$ and $283/383$. These structural and algebraic results do not determine an empirical incidence rate. We conclude by specifying the additional measure-theoretic and observational ingredients required for a defensible model of reported recurrence.

## 1. Introduction

Déjà vu suggests a return: the present is experienced as if it coincided with something already encountered. A natural mathematical abstraction treats cognition as a dynamical system. A state space records possible cognitive configurations, a transition map advances the system, and a recurrence occurs when a state returns after finitely many transitions.

This abstraction is deliberately spare. It does not claim that a cognitive state is literally one real number, that cognition is deterministic, or that exact state recurrence is identical to a subjective report. Its value is diagnostic. Once the objects are defined, one can separate claims that otherwise sound similar:

1. **Existence:** Must some state recur?
2. **Abundance:** Are recurrent states dense or probabilistically common?
3. **Representational invariance:** Does recurrence survive a change of coordinates or encoding?
4. **Observability:** Does a repeated observation imply that the hidden state repeated?
5. **Incidence:** Can a dynamical property predict a population percentage?

The answers differ. Continuous interval dynamics force at least one fixed point, hence at least one recurrent state. They do not force recurrent states to be dense. Recurrence passes forward through every dynamics-respecting encoding, but it passes backward only when that encoding is injective. A maximally lossy observation can report recurrence everywhere while the hidden trajectory is nonperiodic. Finally, topology alone does not define a probability, so it cannot produce a lifetime incidence rate.

The logistic family supplies a useful case study because its elementary formula supports both exact analysis and numerical exploration. At parameter $r=3.83$, the unit interval is invariant and the fixed points admit a complete rational classification. Numerical experiments can then illustrate trajectories, near returns, and observation-induced false positives without confusing those demonstrations with exact classifications of higher periods.

The central thesis is therefore conditional and layered: recurrence is unavoidable in continuous compact-interval models, but widespread or frequently *observed* recurrence requires substantially more structure.

## 2. Dynamical and observational framework

### 2.1 State evolution and iteration

Let $S$ be a nonempty set and let $f:S\to S$ be a transition map. Define the iterates recursively by

$$
f^0=\operatorname{id}_S,\qquad f^{n+1}=f\circ f^n.
$$

The forward trajectory of $s\in S$ is the sequence $(f^n(s))_{n\ge0}$.

**Definition 2.1 (Periodic state).** A state $s\in S$ is periodic if there exists an integer $n>0$ such that

$$
f^n(s)=s.
$$

The set of periodic states is

$$
P(f)=\{s\in S:\exists n\in\mathbb{N},\ n>0\text{ and }f^n(s)=s\}.
$$

A state satisfying $f(s)=s$ is a **fixed point**, hence a periodic point with return time one. If the least positive return time is $p$, then $s$ has **minimal period** $p$. The present results concern positive recurrence and fixed points; they do not classify all minimal periods.

### 2.2 Topological abundance

When $S$ is a topological space, a subset $A\subseteq S$ is **dense** if its closure is all of $S$. Equivalently, every nonempty open set intersects $A$. Density expresses approximation, not probability. A countable set can be dense, and a dense set can have measure zero under a natural probability measure.

This distinction is essential. The existence of one periodic point, density of $P(f)$, positive measure of $P(f)$, and high probability of observing an apparent return are four separate properties.

### 2.3 Semiconjugacy and faithful encoding

Let $f:S\to S$ and $g:T\to T$ be dynamical systems. A map $h:S\to T$ is a **semiconjugacy** from $f$ to $g$ if

$$
h\circ f=g\circ h,
$$

or pointwise,

$$
h(f(s))=g(h(s))\qquad\text{for every }s\in S.
$$

The space $T$ may be another coordinate representation, a compressed state space, or an observation space with its own induced dynamics. A semiconjugacy is **faithful** here when it is injective. If it is a homeomorphism and has a dynamics-respecting inverse, it is a topological conjugacy, but continuity is not needed for the set-theoretic recurrence results below.

### 2.4 Observation versus hidden state

An observation map $q:S\to O$ associates an observable value with each hidden state. Unless $q$ is injective, equality of observations does not imply equality of states. Consequently,

$$
q(f^n(s))=q(s)
$$

need not imply

$$
f^n(s)=s.
$$

This elementary distinction becomes decisive when a subjective report is treated as evidence for recurrence in a hidden cognitive system.

## 3. Recurrence under changes of representation

The first result establishes that a dynamics-respecting encoding always sends recurrent states to recurrent states.

**Theorem 3.1 (Recurrence Transport).** Let $f:S\to S$ and $g:T\to T$, and let $h:S\to T$ satisfy $h\circ f=g\circ h$. Then

$$
h(P(f))\subseteq P(g).
$$

**Proof sketch.** Induction on $n$ gives the iterated intertwining identity

$$
h(f^n(s))=g^n(h(s))
$$

for every $n\ge0$. If $s\in P(f)$, choose $n>0$ with $f^n(s)=s$. Applying $h$ and using the iterated identity yields

$$
g^n(h(s))=h(f^n(s))=h(s),
$$

so $h(s)\in P(g)$. $\square$

The forward implication requires no injectivity. Even a heavily compressed representation records a return of the hidden system as a return of the encoded system, provided the encoding truly intertwines the dynamics.

The converse requires faithfulness.

**Theorem 3.2 (Faithful Encoding Characterization).** Under the hypotheses of Theorem 3.1, suppose additionally that $h$ is injective. Then

$$
h^{-1}(P(g))=P(f).
$$

Equivalently, for every $s\in S$,

$$
s\in P(f)\quad\Longleftrightarrow\quad h(s)\in P(g).
$$

**Proof sketch.** The forward implication is Theorem 3.1. Conversely, if $h(s)$ is periodic, choose $n>0$ such that $g^n(h(s))=h(s)$. The iterated intertwining identity rewrites the left side as $h(f^n(s))$. Hence $h(f^n(s))=h(s)$. Injectivity gives $f^n(s)=s$, so $s$ is periodic. $\square$

**Corollary 3.3 (Coordinate invariance).** A bijective dynamics-respecting change of coordinates preserves and reflects all positive returns. In particular, the existence of periodic points is not an artifact of a faithful relabeling of states.

The theorem concerns return, not yet minimal period. A refinement would show that an injective semiconjugacy preserves the least positive return time: if the encoded point returned earlier, injectivity would force the original point to return earlier as well. Under a topological conjugacy, one may further ask whether exact-period strata are homeomorphic.

## 4. Existence without abundance

### 4.1 The interval recurrence theorem

We now impose topology. Let $a,b\in\mathbb{R}$ with $a<b$, and let $f:[a,b]\to[a,b]$ be continuous.

**Theorem 4.1 (Interval Recurrence).** Every continuous self-map of a nondegenerate closed real interval has a periodic state. More strongly, there exists $s\in[a,b]$ such that

$$
f(s)=s.
$$

**Proof sketch.** Define $F(x)=f(x)-x$. Since $f(a)\in[a,b]$, one has $F(a)\ge0$. Since $f(b)\in[a,b]$, one has $F(b)\le0$. The function $F$ is continuous, so the intermediate value theorem supplies $s\in[a,b]$ with $F(s)=0$. Thus $f(s)=s$, and $s\in P(f)$ with return time one. $\square$

Compactness is encoded by the closed bounded interval, while order provides opposite endpoint inequalities. The theorem establishes a minimal form of inevitability: a continuous interval model cannot be entirely free of recurrence.

It does not say that every trajectory returns, that recurrence is experimentally accessible, or that periodic points occupy a large portion of the state space.

### 4.2 Exact periodic set of a constant transition

**Lemma 4.2 (Constant Dynamics).** For a fixed $c\in\mathbb{R}$, let $f_c:\mathbb{R}\to\mathbb{R}$ be $f_c(x)=c$. Then

$$
P(f_c)=\{c\}.
$$

**Proof sketch.** The point $c$ is fixed. For every $x$ and every $n\ge1$, the iterate $f_c^n(x)$ equals $c$. Therefore, if $f_c^n(x)=x$ for some $n>0$, then $x=c$. $\square$

This simple classification refutes the claim that continuity alone yields dense periodic points.

**Theorem 4.3 (Continuity Does Not Imply Dense Recurrence).** There exists a continuous map $f:\mathbb{R}\to\mathbb{R}$ for which $P(f)$ is not dense.

**Proof sketch.** Take $f(x)=0$. By Lemma 4.2, $P(f)=\{0\}$. The closure of this singleton is itself, not all of $\mathbb{R}$; for example, the open interval $(1/2,3/2)$ does not meet it. $\square$

The same counterexample restricts to any nondegenerate closed interval containing $0$ and another point. Thus compactness and continuity guarantee existence but still do not guarantee density.

### 4.3 Logical separation of recurrence claims

Theorems 4.1 and 4.3 jointly establish a useful separation:

$$
\text{continuous interval self-map}
\Longrightarrow P(f)\ne\varnothing,
$$

but

$$
\text{continuous interval self-map}
\not\Longrightarrow \overline{P(f)}=[a,b].
$$

Stronger chaotic hypotheses can imply density on an invariant subsystem. For example, a full two-branch horseshoe is expected to support symbolic coding in which periodic words are dense. Even there, the appropriate conclusion concerns the horseshoe’s invariant set and need not extend to the whole interval.

## 5. Lossy observation and false recurrence

A recurrence model becomes cognitively meaningful only through an observation process. The next result shows why observation cannot be omitted.

**Theorem 5.1 (Constant-Observation False Positive).** Let $f:S\to S$ be any dynamical system, let $s\in S$ be nonperiodic, and let $q:S\to O$ be the constant observation $q(x)=o$. Then the observation is fixed at every step,

$$
q(f^n(s))=o=q(s)\qquad\text{for every }n\ge0,
$$

although

$$
s\notin P(f).
$$

**Proof sketch.** Both observed values equal $o$ by definition of $q$, independently of the hidden states. The nonperiodicity is part of the hypothesis. $\square$

This is not merely a pathological curiosity. Any finite-resolution observation partitions the hidden state space into equivalence classes. Distinct hidden states in one class produce the same report. A repeated report can therefore indicate exact state recurrence, return to the same observational cell, or merely persistent insensitivity of the instrument.

**Remark 5.2 (Necessary direction of faithfulness).** If an observation map participates in a semiconjugacy, hidden recurrence always implies observed recurrence by Theorem 3.1. To infer hidden recurrence from observed recurrence, injectivity is sufficient by Theorem 3.2. In realistic settings global injectivity may be too strong, but some weaker identifiability condition is still required for valid inference.

A finite-resolution event can be modeled explicitly. Given a metric $d_O$ on $O$ and resolution $\varepsilon>0$, one might declare an observed return by

$$
d_O(q(f^n(s)),q(s))\le\varepsilon.
$$

This is a different event from exact periodicity. It may be more appropriate for empirical work, but its incidence depends on $q$, $\varepsilon$, $n$, and a probability distribution.

## 6. The logistic map at parameter $3.83$

Consider

$$
L(x)=\frac{383}{100}x(1-x).
$$

### 6.1 Invariance of the unit interval

**Theorem 6.1 (Unit-Interval Invariance).** If $x\in[0,1]$, then $L(x)\in[0,1]$.

**Proof sketch.** For $0\le x\le1$, the factors $x$ and $1-x$ are nonnegative, so $L(x)\ge0$. Completing the square gives

$$
x(1-x)=\frac14-\left(x-\frac12\right)^2\le\frac14.
$$

Consequently,

$$
L(x)\le\frac{383}{100}\cdot\frac14=\frac{383}{400}<1.
$$

Thus $0\le L(x)\le1$. $\square$

This theorem ensures that trajectories initialized in the unit interval remain in the intended state space.

### 6.2 Complete fixed-point classification

**Theorem 6.2 (Fixed Points at $r=3.83$).** For real $x$,

$$
L(x)=x
$$

if and only if

$$
x=0\qquad\text{or}\qquad x=\frac{283}{383}.
$$

**Proof sketch.** Multiply the fixed-point equation by $100$ and rearrange:

$$
383x(1-x)=100x,
$$

so

$$
283x-383x^2=0.
$$

Equivalently,

$$
x(383x-283)=0.
$$

The zero-product property yields the two listed solutions. Direct substitution proves both are fixed. $\square$

Both fixed points lie in $[0,1]$. Numerically, $283/383\approx0.7389$. The classification is exact and complete for period one.

### 6.3 What this does not establish

At parameter $3.83$, numerical trajectories may approach a pattern of three clusters. Such computation motivates the conjecture that an attracting orbit of exact period three exists and that the critical point $1/2$ lies in its basin. However, a finite floating-point trajectory cannot certify exact equality $L^3(x)=x$, exclude periods dividing three, or establish attraction with exact bounds.

A rigorous period-three certification would proceed in stages:

1. Expand or otherwise evaluate the equation $L^3(x)-x=0$.
2. Isolate three relevant roots in disjoint rational intervals.
3. Exclude the two fixed-point factors identified by Theorem 6.2.
4. Verify that the three roots map cyclically between the isolating intervals.
5. Bound the multiplier

$$
\left|(L^3)'(x)\right|
=|L'(x)L'(L(x))L'(L^2(x))|
$$

below $1$ on the cycle intervals to certify attraction.

The present exact results provide the invariant domain and fixed-point exclusions needed for that program, but they do not assert the period-three conclusion.

## 7. Numerical algorithms and demonstrations

Numerical computation is valuable when its role is stated correctly. It can illustrate exact theorems, identify conjectural structures, and quantify finite-resolution events. It cannot replace exact proof of periodicity or generate an empirical population model without data and assumptions.

### 7.1 Orbit iteration

Given $r$, an initial state $x_0$, and a length $N$, compute

$$
x_{k+1}=rx_k(1-x_k),\qquad 0\le k<N.
$$

The algorithm uses $N$ evaluations and constant auxiliary storage if states are streamed, or $O(N)$ storage if the whole orbit is retained. For $r=3.83$ and $x_0\in[0,1]$, Theorem 6.1 ensures exact real iterates remain in $[0,1]$; small floating-point roundoff should nevertheless be monitored.

### 7.2 Tolerance-based near-return detection

For a finite orbit $(x_0,\ldots,x_N)$ and tolerance $\varepsilon>0$, define a detected near return at lag $p$ when

$$
|x_i-x_{i-p}|\le\varepsilon.
$$

Scanning all lags up to $P$ costs $O(NP)$ time and $O(N)$ storage. This algorithm detects observational or numerical proximity, not exact periodicity. The distinction should be printed alongside every output.

### 7.3 Exact fixed-point residuals

The fixed points can be represented as rational numbers. Evaluating

$$
L(0)-0
$$

and

$$
L\left(\frac{283}{383}\right)-\frac{283}{383}
$$

with rational arithmetic returns exactly zero. This demonstration avoids roundoff and directly mirrors Theorem 6.2.

### 7.4 Observation comparison

To demonstrate Theorem 5.1, one may iterate a nonperiodic-looking trajectory and compare two observation rules: an informative quantizer and a constant observation. The constant channel returns the same symbol at every time, thereby exhibiting observed stability without establishing hidden recurrence. Changing quantization resolution shows that observed recurrence is protocol-dependent.

## 8. Why topology cannot predict lifetime incidence

An empirical statement such as “a fraction $p$ of people experience déjà vu during their lifetime” requires a probability space. A minimal model would include:

- a subject space $\Omega$ with probability measure $\mathbb{P}$;
- subject-dependent parameters or maps $f_\omega$;
- a distribution of initial states $s_0(\omega)$;
- an observation map $q_\omega$;
- a resolution criterion and a time horizon $T$;
- a measurable event specifying what counts as a report.

For example, with metric observation space and tolerance $\varepsilon$, one could define

$$
E_{T,\varepsilon}
=
\left\{\omega:\exists 0\le i<j\le T,
\ d_O\bigl(q_\omega(s_i),q_\omega(s_j)\bigr)\le\varepsilon\right\},
$$

where $s_{k+1}=f_\omega(s_k)$. The modeled incidence would then be

$$
\mathbb{P}(E_{T,\varepsilon}).
$$

Every ingredient affects the result. Exact periodic points might have zero measure under a continuous initial-state distribution even when they are dense. Conversely, coarse observations may produce a large near-return probability even when no sampled initial state is exactly periodic.

Accordingly, none of the following quantities can be identified without additional theorems and modeling assumptions:

1. topological density of $P(f)$;
2. natural density of a discretized collection of periodic points;
3. invariant-measure mass assigned to recurrent or near-recurrent events;
4. finite-time observed-return probability;
5. lifetime population incidence of a subjective report.

The fixed-point classification at $r=3.83$ assigns no probability to either fixed point. Nor does the existence of a chaotic invariant subsystem determine the distribution of subjects, observations, or reports.

## 9. Discussion

### 9.1 What is genuinely inevitable

Within the assumptions of Theorem 4.1, a fixed point is unavoidable. Thus a continuous scalar state variable confined to a closed interval always admits at least one state that reproduces itself after one update. This is a clean structural statement.

The word “inevitable” must not migrate beyond those assumptions. The theorem does not show that a generic initial condition reaches the fixed point, that a human trajectory revisits a complete cognitive state, or that a person experiences familiarity when recurrence occurs.

### 9.2 The role of period three

An exact period-three orbit for a continuous interval map has profound consequences in one-dimensional dynamics. It motivates the construction of covering intervals, symbolic itineraries, and scrambled trajectory pairs. Yet those consequences belong to a theorem whose premise must first be established. At $r=3.83$, interval invariance and period-one classification are exact; exact period three remains a separate certification problem.

Even after period three is certified, chaos and incidence remain distinct. Symbolic complexity describes the organization of trajectories. Population frequency describes a measure on subjects and observations.

### 9.3 Faithfulness as an experimental requirement

Theorems 3.2 and 5.1 bracket observation quality. Injective dynamical encoding permits exact inference of hidden recurrence from encoded recurrence. Constant observation permits none. Real measurements lie between these extremes.

This suggests an experimental program centered not only on transition dynamics but on identifiability. One should ask which distinctions between hidden states the measurement preserves, over what temporal scale, and at what resolution. Without such an account, repeated observations are ambiguous.

### 9.4 Determinism and model scope

The framework uses deterministic maps, whereas cognition may involve noise, external inputs, and nonstationarity. Stochastic extensions would replace exact trajectories by sample paths or transition kernels and would distinguish return probabilities from deterministic periodicity. The deterministic theory remains useful as a baseline and as the local structure of more elaborate models.

## 10. Future research

Five directions follow naturally.

**Exact period-three certification.** For $L(x)=3.83x(1-x)$, isolate roots of $L^3(x)-x$ in rational intervals, exclude fixed points, verify cyclic mapping, and bound the derivative product to establish attraction and the basin behavior of $1/2$.

**Minimal-period invariance.** Strengthen the faithful encoding theorem from positive recurrence to exact minimal periods, then show that a topological conjugacy induces homeomorphisms between exact-period strata.

**Measure-theoretic incidence.** Equip a parameterized map family with distributions of subjects and initial states, a finite-resolution observation rule, and a finite horizon. Prove measurability and study how incidence depends on parameter and resolution.

**Symbolic dynamics from period three.** Starting from an ordered exact three-cycle, construct covering intervals and an invariant subsystem with a symbolic factor. Use this structure to obtain nonperiodic and nonconvergent trajectory pairs.

**Local density under a horseshoe hypothesis.** Prove density of periodic points in the invariant set of a full two-branch horseshoe while explicitly avoiding the stronger and generally false claim of density in the entire ambient interval.

## 11. Conclusion

A recurrence-based account of déjà vu becomes mathematically coherent only after three levels are separated. State recurrence is the equation $f^n(s)=s$. Observed recurrence is equality or proximity after applying an observation map. Incidence is the probability of a specified observed event in a population and time window.

The structural results are exact. Semiconjugacies transport recurrence; injective semiconjugacies preserve and reflect it. Every continuous self-map of a nondegenerate closed interval has a fixed point. Continuity alone does not make periodic states dense. Constant observations can create false positives. The logistic map at parameter $3.83$ preserves the unit interval and has exactly the fixed points $0$ and $283/383$.

Together these results support a restrained conclusion. Recurrence existence is robust in continuous interval dynamics, but prevalence is not a topological consequence, and perception is not transparent access to hidden state. A predictive cognitive model must therefore combine dynamics with an explicit observation mechanism and a probability measure. Only then can the mathematics of return become a mathematics of reported experience.
