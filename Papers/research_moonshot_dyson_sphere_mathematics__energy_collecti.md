# Geometry, Convex Thermal Allocation, and Computation in an Ideal Dyson Swarm

**Aristotle**  
**July 22, 2026**

## Abstract

We develop a self-contained mathematical model of energy collection and computation for an ideal Dyson swarm. An isotropic star of luminosity $L$ produces flux $L/(4\pi R^2)$ at orbital radius $R>0$, so collectors with total nonoverlapping projected area $A$ capture $LA/(4\pi R^2)$. Consequently, a disconnected swarm whose total projected area equals $4\pi R^2$ captures the same power as a complete shell, and no partial coverage with area at most $4\pi R^2$ captures more than $L$. To quantify one aspect of thermal management, we assign panel areas $a_i$ the convex quadratic load $Q=\sum_i a_i^2$. The finite Cauchy inequality gives $Q\ge A^2/n$ for $n$ panels of fixed total area $A$, with equality at the uniform allocation $a_i=A/n$. Thus equal partition is globally optimal in this metric, and splitting a positive monolithic collector into two equal independent radiators strictly halves its load.

We then separate geometric collection from resource accounting. For energy $E$ and positive charged cost $c$, operation or bit capacity is $E/c$. This yields general budget bounds, a conditional certificate of $10^{40}$ operations per second from $10^{26}$ watts when each operation costs at most $10^{-14}$ joules, and a calibrated criterion for at least $10^{50}$ bits. Finally, deterministic entropy loss gives a nonnegative Landauer heat expression at nonnegative temperature. The framework identifies both the strength and the limits of common Dyson-scale estimates: connectivity is irrelevant to ideal projected-area collection, but occlusion, duration, temperature, and the meaning of information capacity cannot be omitted from physical conclusions.

## 1. Introduction

A Dyson structure is often pictured as a rigid spherical shell enclosing a star. For energy accounting, however, the essential object is not mechanical connectivity but projected collecting area. A collection of independently orbiting panels can, in an ideal no-occlusion model, present the same total area to stellar radiation as a shell. This observation replaces a difficult structural question with a geometric one and opens a second question: how should fixed collecting area be divided among independently radiating units?

The present model deliberately separates four layers. The **geometric layer** specifies sphere area, inverse-square flux, and intercepted power. The **allocation layer** introduces a quadratic proxy for thermal concentration and solves its finite optimization problem. The **resource layer** divides available energy by a positive cost per operation or bit. The **information layer** expresses the sign of heat required by entropy-losing deterministic computation.

This separation prevents several common category errors. Radius determines flux but does not by itself determine stored bits. Luminosity is power, not energy, until an operating duration is supplied. Landauer’s principle concerns logically irreversible entropy loss, not every form of passive storage. Finally, a claim that a swarm has “better thermal management” requires a stated objective function. Here that objective is explicitly the sum of squared assigned areas.

The main results are exact within their assumptions. Full spherical projected area captures full isotropic luminosity. Partial area cannot exceed it. Equal partition uniquely attains the lower bound of the quadratic load when allocations are compared as real vectors, and the optimal value scales as $1/n$. Energy-budget certificates follow by division through positive costs. These elementary ingredients provide a transparent baseline for more realistic models involving shadowing, Stefan–Boltzmann radiation, orbital dynamics, and finite-time computation.

## 2. Geometric collection model

### 2.1 Definitions and assumptions

Let $L\ge0$ denote stellar luminosity and let $R>0$ be a common orbital radius. The surface area of the centered sphere is defined by

$$
S(R)=4\pi R^2.
$$

The strict condition $R>0$ excludes the singular center of the inverse-square model. Assuming isotropic emission, the radiant flux through the sphere is

$$
F(L,R)=\frac{L}{S(R)}=\frac{L}{4\pi R^2}.
$$

Let $A$ be the total effective projected area of the collectors normal to the incident rays. We assume that projected areas add: collectors do not shadow one another and no portion of the incoming wavefront is counted twice. Captured power is

$$
P(L,R,A)=F(L,R)A=\frac{LA}{4\pi R^2}.
$$

The quantity $A$ is effective area, not necessarily physical sheet area. Orientation, optical efficiency, and conversion losses can be incorporated later through multiplicative factors or through a refined definition of effective area.

### 2.2 Full coverage and the luminosity bound

**Theorem 1 (Full-Coverage Theorem).** Let $R$ be such that $S(R)\ne0$. A collection system with total projected area $S(R)$ captures the full luminosity:

$$
P(L,R,S(R))=L.
$$

**Proof sketch.** Substitute the definitions:

$$
P(L,R,S(R))=\frac{L}{S(R)}S(R)=L.
$$

The nonzero-area premise permits cancellation. No property of the collectors other than their total projected area appears. $\square$

**Theorem 2 (Luminosity Bound).** If $L\ge0$, $R>0$, and $A\le S(R)$, then

$$
P(L,R,A)\le L.
$$

**Proof sketch.** Since $R>0$ and $\pi>0$, one has $S(R)>0$. Hence $F(L,R)=L/S(R)\ge0$. Multiplying $A\le S(R)$ by this nonnegative flux gives

$$
F(L,R)A\le F(L,R)S(R)=L.
$$

This is the asserted inequality. $\square$

**Corollary 3 (Swarm–Shell Area Equivalence).** Consider finitely many collectors with projected areas $a_1,\ldots,a_n$. If

$$
\sum_{i=1}^{n}a_i=S(R),
$$

then their total captured power equals that of a complete shell at radius $R$.

**Proof sketch.** Captured power depends on the list of collectors only through its sum $A=\sum_i a_i$. Replacing this sum by $S(R)$ makes both expressions identical. $\square$

This equivalence is geometric rather than structural. It does not assert that shell and swarm have equal mass, stability, reliability, temperature, or construction cost. It establishes that connectivity is absent from the ideal interception formula.

### 2.3 Scale at one astronomical unit

Taking $R\approx1.496\times10^{11}$ meters gives

$$
S(R)\approx 4\pi(1.496\times10^{11})^2\approx2.81\times10^{23}\ \mathrm{m}^2.
$$

For a solar-like luminosity $L\approx3.828\times10^{26}$ watts, the flux is approximately $1.36\times10^3$ watts per square meter. A coverage fraction $f=A/S(R)$ captures $fL$. This proportionality is exact in the model: $10\%$ coverage captures $10\%$ of luminosity, while $100\%$ coverage captures all of it.

## 3. Convex thermal allocation

### 3.1 Quadratic concentration metric

Real radiative equilibrium is governed by physical area, emissivity, temperature, incident angle, and the Stefan–Boltzmann law. Our objective is not to replace that theory but to isolate the effect of distributing a fixed responsibility among independent units. For a finite swarm with area allocation $(a_1,\ldots,a_n)$, define the quadratic thermal concentration load

$$
Q(a_1,\ldots,a_n)=\sum_{i=1}^{n}a_i^2.
$$

The function $x\mapsto x^2$ is convex. Therefore concentration is penalized: assigning twice as much area to one unit produces four times its individual contribution. The units of $Q$ are area squared, confirming that it is a proxy or normalized design objective rather than heat in joules.

Let the fixed total area be

$$
A=\sum_{i=1}^{n}a_i,
$$

where $n>0$. The allocation problem is to minimize $Q$ subject to this linear constraint.

### 3.2 The governing inequality

**Lemma 4 (Quadratic Thermal-Load Inequality).** For every real allocation $(a_1,\ldots,a_n)$,

$$
\left(\sum_{i=1}^{n}a_i\right)^2\le n\sum_{i=1}^{n}a_i^2.
$$

**Proof sketch.** Apply the Cauchy–Schwarz inequality to vectors

$$
(a_1,\ldots,a_n)\quad\text{and}\quad(1,\ldots,1).
$$

Their inner product is $\sum_i a_i$, and their squared norms are $\sum_i a_i^2$ and $n$. Thus the square of the inner product is at most the product of squared norms. $\square$

An illuminating equivalent identity is

$$
\sum_{i=1}^{n}\left(a_i-\frac{A}{n}\right)^2
=Q-\frac{A^2}{n}\ge0.
$$

The excess above optimum is exactly the unnormalized variance of the allocation. Unevenness and thermal penalty are therefore the same quantity in this model.

### 3.3 Uniform optimum

**Lemma 5 (Load of a Uniform Swarm).** For $n>0$, if every panel has area $A/n$, then

$$
Q_{\mathrm{uniform}}=\frac{A^2}{n}.
$$

**Proof sketch.** There are $n$ identical squared terms, so

$$
n\left(\frac{A}{n}\right)^2=\frac{A^2}{n}.
$$

$\square$

**Theorem 6 (Uniform-Swarm Optimality Theorem).** Among all real allocations with $n>0$ panels and fixed total area $A$, the uniform allocation $a_i=A/n$ minimizes the quadratic thermal concentration load. In particular,

$$
Q(a_1,\ldots,a_n)\ge\frac{A^2}{n},
$$

and the uniform allocation attains equality.

**Proof sketch.** Lemma 4 gives $A^2\le nQ$. Division by positive $n$ yields $A^2/n\le Q$. Lemma 5 shows that the uniform allocation has precisely this value. The variance identity also shows that equality requires every difference $a_i-A/n$ to vanish, so the optimizer is unique among real allocations. $\square$

**Theorem 7 (Strict Two-Panel Improvement).** If $A>0$, splitting one collector of area $A$ into two independent collectors of area $A/2$ strictly reduces the quadratic load:

$$
2\left(\frac{A}{2}\right)^2<A^2.
$$

**Proof sketch.** The left side is $A^2/2$. Since $A>0$, one has $A^2>0$, and therefore $A^2/2<A^2$. $\square$

More generally, the minimum at panel count $n$ is $A^2/n$. Replacing $n$ by $mn$ divides the minimum by $m$. This inverse-linear law is the exact sense in which more equally sized independent radiators provide better thermal management here.

### 3.4 Combined collection–allocation result

**Corollary 8 (Optimal Full-Area Swarm).** Fix $R>0$ and a positive panel count $n$. Among all $n$-panel swarms whose areas sum to $S(R)$, every swarm captures luminosity $L$, while the equal-area swarm minimizes quadratic thermal load at

$$
Q_{\min}=\frac{S(R)^2}{n}=\frac{16\pi^2R^4}{n}.
$$

**Proof sketch.** Corollary 3 supplies collection equivalence for every allocation with the prescribed sum. Theorem 6 supplies the load minimum, and substitution of $S(R)=4\pi R^2$ gives the final expression. $\square$

The result cleanly separates invariance and optimization: captured power is invariant under repartition of fixed total area, whereas quadratic load is not.

## 4. Energetic capacities

### 4.1 General budget theorem

Let $E$ be an available energy budget and let $c>0$ be the charged energy per event. Define capacity by

$$
C(E,c)=\frac{E}{c}.
$$

The event may be an operation, a bit erasure, or another process, provided the meaning and units of $c$ are fixed.

**Theorem 9 (Energy-Budget Bound).** If $c>0$ and a proposed event count $N$ satisfies

$$
Nc\le E,
$$

then

$$
N\le C(E,c)=\frac{E}{c}.
$$

**Proof sketch.** Divide $Nc\le E$ by the positive quantity $c$, which preserves the inequality. $\square$

For operation accounting we write $C_{\mathrm{op}}(E,c)=E/c$. For bit accounting we write $C_{\mathrm{bit}}(E,c_b)=E/c_b$. The algebra is identical, but separate notation prevents an operation cost from being silently substituted for a bit cost.

### 4.2 Type II throughput

**Theorem 10 (Type II Throughput Certificate).** Suppose a system has power $10^{26}$ watts and each operation costs a positive amount no greater than $10^{-14}$ joules. Then the system can energetically support at least $10^{40}$ operations per second.

**Proof sketch.** During one second the available energy is $10^{26}$ joules. The energy required for $10^{40}$ operations is bounded by

$$
10^{40}c\le10^{40}\cdot10^{-14}=10^{26}\ \mathrm{J}.
$$

Theorem 9 then places $10^{40}$ within the one-second capacity. $\square$

This is a conservative conditional certificate, not an identification of $10^{-14}$ joules with the Landauer limit. The conclusion changes with the charged cost. At $10^{-16}$ joules per operation, the same power budget gives $10^{42}$ operations per second; at $10^{-12}$ joules, it gives $10^{38}$.

### 4.3 Calibrated bit capacity

**Theorem 11 (Calibrated $10^{50}$-Bit Certificate).** Let $E$ be an energy budget and let $c_b>0$ be the charged energy per bit. If

$$
c_b\le\frac{E}{10^{50}},
$$

then

$$
10^{50}\le C_{\mathrm{bit}}(E,c_b).
$$

**Proof sketch.** Multiplying the assumed bound by the positive number $10^{50}$ gives $10^{50}c_b\le E$. Apply Theorem 9. $\square$

The premise is the necessary calibration hidden by an unconditional “$10^{50}$ bits at one astronomical unit” slogan. An orbital radius determines neither $E$ nor $c_b$. If the swarm captures power $P$ for duration $t$, then one may set $E=Pt$ after accounting for efficiency and other uses. A thermodynamic model may then determine or bound $c_b$ from temperature and entropy loss.

## 5. Deterministic entropy loss and heat

Let $X$ and $Y$ be finite state spaces, let $f:X\to Y$ be deterministic, and let $p(x)\ge0$ be input weights. The output weight at $y$ is the pushforward

$$
(f_*p)(y)=\sum_{x:f(x)=y}p(x).
$$

Write the Shannon entropy functional as $H(p)$, with a consistent logarithmic convention and normalization. Deterministic merging of distinguishable inputs into common outputs does not increase entropy in the relevant coarse-graining inequality, so

$$
H(p)-H(f_*p)\ge0.
$$

**Theorem 12 (Nonnegative Deterministic Dissipation).** If the Boltzmann factor $k\ge0$ and temperature $T\ge0$, then

$$
kT\bigl(H(p)-H(f_*p)\bigr)\ge0.
$$

**Proof sketch.** The entropy difference is nonnegative under deterministic pushforward. The product $kT$ is also nonnegative. The product of nonnegative quantities is nonnegative. $\square$

This statement captures the sign of the Landauer lower-bound expression. A quantitative per-bit value requires the entropy loss associated with the logical transformation and the reservoir temperature. Reversible transformations may preserve entropy and evade an erasure charge at this level, while many-to-one transformations lose logical information.

## 6. Algorithms and numerical diagnostics

The model supports three direct computational procedures.

First, a **geometric collection evaluator** computes $S=4\pi R^2$, flux $F=L/S$, coverage fraction $A/S$, and power $P=FA$. It rejects nonpositive radius and can flag $A>S$ as a violation of the no-overcounting coverage model. Its arithmetic complexity is constant.

Second, a **uniform allocation optimizer** takes total area $A$ and integer panel count $n>0$, returns $n$ copies of $A/n$, and reports minimum load $A^2/n$. Constructing the full list costs $O(n)$ time and memory; computing only the optimum costs $O(1)$. For an arbitrary supplied allocation, summing areas and squares costs $O(n)$ and the optimality gap is

$$
Q-\frac{A^2}{n}=\sum_i\left(a_i-\frac{A}{n}\right)^2.
$$

Third, a **capacity evaluator** computes $E/c$ for positive cost $c$. If the input is power and duration, it first forms $E=Pt$. The arithmetic cost is constant, although interpretation requires consistent units.

These procedures are diagnostic rather than high-fidelity simulations. Their role is to expose scaling laws, test assumptions, and provide baselines against which occlusion-aware or radiative-equilibrium models can be compared.

### 6.1 Representative calculations

At one astronomical unit, a solar-luminosity source illustrates the geometric cancellation. With $R=1.496\times10^{11}$ meters and $L=3.828\times10^{26}$ watts, the spherical area is approximately $2.813\times10^{23}$ square meters and the flux is approximately $1.361\times10^3$ watts per square meter. A collector population presenting $2.813\times10^{22}$ square meters, or one tenth of full coverage, captures approximately $3.828\times10^{25}$ watts. Multiplying the area by ten restores the full luminosity; no extra factor is introduced by whether that area belongs to one object or many.

For a normalized total area $A=12$, one panel has load $144$. Two equal panels have allocation $(6,6)$ and load $72$; four equal panels have allocation $(3,3,3,3)$ and load $36$; twelve equal panels have load $12$. By contrast, the four-panel allocation $(6,3,2,1)$ has the same total area but load

$$
6^2+3^2+2^2+1^2=50,
$$

which exceeds the uniform minimum by $14$. The same number is obtained from the variance identity:

$$
(6-3)^2+(3-3)^2+(2-3)^2+(1-3)^2=14.
$$

This equality provides a useful numerical check and an interpretation of the optimality gap.

For computation, a $10^{26}$-watt budget sustained for one second provides $10^{26}$ joules. At $10^{-14}$ joules per operation its capacity is exactly $10^{40}$ operations; at $10^{-18}$ joules it is $10^{44}$. If only a fraction $f$ of luminosity is captured and a fraction $\eta$ of captured power reaches computation, the one-second energy becomes $E=\eta fL$. Thus the capacity is

$$
C_{\mathrm{op}}=\frac{\eta fL}{c}.
$$

The formula makes each engineering assumption visible. Doubling coverage or efficiency doubles throughput, while halving event cost doubles it. Duration enters in exactly the same linear manner when a finite total count rather than a per-second rate is desired.

## 7. Applications and design implications

The area theorem favors modular construction. A civilization need not complete a connected shell before obtaining benefit: each additional nonoverlapping collector adds captured power linearly. This permits incremental deployment and makes the coverage fraction a natural progress variable.

The thermal theorem favors equal responsibility. In the quadratic metric, unequal allocations incur a variance penalty. If manufacturing permits standardized panels, uniformity is not merely convenient; it is optimal for the stated objective. The inverse dependence $Q_{\min}=A^2/n$ also quantifies the marginal value of subdivision, though a realistic design would balance this benefit against communication, station-keeping, collision risk, and fixed per-panel overhead.

The computation theorems supply an auditable bridge from watts to throughput. A power figure alone is insufficient; the cost per event must accompany it. Likewise, a bit count must identify whether it concerns erasures, writes, maintained states, or another resource. The calibrated form allows different temperatures, durations, and technology assumptions to be inserted without changing the algebraic core.

## 8. Limitations

The no-occlusion assumption is decisive. Once collectors shadow one another, effective areas do not simply add, and coverage becomes a geometric union problem. The common-radius assumption also suppresses variation in flux. Multiple shells require weighting each panel by its local inverse-square flux and tracking shadows between shells.

The quadratic load is an abstract convex proxy. It neither states panel temperature nor enforces radiative equilibrium. Stefan–Boltzmann emission would introduce terms proportional to emitting area times $T^4$, while material constraints and maximum temperature would produce a constrained optimization problem. The present theorem should therefore be read exactly: equal allocation minimizes the sum of squared assigned areas.

The resource model assumes a fixed positive cost. Real operation costs may depend on speed, error rate, architecture, and temperature. Landauer’s principle bounds logically irreversible entropy loss; it does not alone set the cost of arbitrary quantum gates, communication, error correction, or passive storage. Finally, luminosity is power. Any finite information count based on harvested starlight must specify an integration time and efficiency.

## 9. Future work

A first extension replaces $x^2$ by a strictly convex radiator cost $\phi(x)$. Jensen’s inequality suggests that equal allocation remains the unique optimum, and majorization should characterize the improvement obtained by splitting a collector.

A second extension couples collection to Stefan–Boltzmann rejection under a material budget. Inverse-square incident flux and fourth-power thermal emission may produce an optimal orbital radius where collection and rejection constraints are simultaneously active.

A third extension treats occlusion on one or more shells. Effective capture then resembles a submodular coverage function, suggesting greedy approximation algorithms subject to per-panel thermal constraints.

A fourth extension develops finite-time Landauer capacity. Given luminosity, coverage, efficiency, duration, reservoir temperature, and reversible overhead, one seeks matching upper and lower bounds on irreversible erasures. Such a theory would replace radius-only capacity slogans with parameterized physical estimates.

## 10. Conclusion

The ideal Dyson swarm is governed by a useful contrast. Stellar power collection is linear in nonoverlapping projected area, so a disconnected swarm can equal a shell and cannot exceed the star’s luminosity within full coverage. Quadratic thermal concentration is convex, so equal partition minimizes load and improves inversely with panel count. Energy-accounted computation is likewise transparent once positive cost per event is stated: capacity is energy divided by cost.

Together these results provide a disciplined mathematical baseline for stellar-scale engineering. They justify the swarm’s collection equivalence and one precise thermal advantage while refusing to infer information capacity from orbital radius alone. The resulting picture is both ambitious and constrained: modular collectors can harvest a star, but every claim about heat or computation must name the metric, energy budget, temperature, and timescale on which it depends.
