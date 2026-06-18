# Mathematics of Science Fiction

## A Rigorous Textbook with Formalized Proofs

---

# Preface

Science fiction has always been mathematics dreaming out loud. From the curved
spacetimes of general relativity to the paradoxes of time travel, from the
exponential growth curves of alien civilizations to the information-theoretic
limits of faster-than-light communication, the genre's most compelling ideas
rest on precise mathematical foundations.

This textbook explores the mathematics that underpins science fiction's greatest
concepts. Each chapter presents the relevant theory with full rigor, accompanied
by machine-verified proofs in the Lean 4 theorem prover. The formalized
statements can be found in the companion `.lean` files in this directory.

---

# Part I: Space, Time, and Geometry

---

## Chapter 1: The Geometry of Hyperspace

> *"The shortest distance between two points is not always a straight line."*

### 1.1 Motivation: Faster-Than-Light Travel

One of the most persistent tropes in science fiction is faster-than-light (FTL)
travel. From the *warp drive* of Star Trek to the *hyperspace* of Star Wars,
authors have imagined countless mechanisms to circumvent the cosmic speed limit.
The mathematical question is: **can geometry itself provide a shortcut?**

The answer, remarkably, is *yes* — at least in principle. The key insight is that
the distance between two points depends on the geometry of the space they
inhabit. In a curved or higher-dimensional space, paths that appear long in
three dimensions may be short through a higher-dimensional "bulk."

### 1.2 Metric Spaces and Distance

**Definition 1.1 (Metric Space).** A *metric space* is a pair $(X, d)$ where
$X$ is a set and $d : X \times X \to \mathbb{R}$ satisfies:

1. **Non-negativity:** $d(x, y) \geq 0$ for all $x, y \in X$
2. **Identity of indiscernibles:** $d(x, y) = 0 \iff x = y$
3. **Symmetry:** $d(x, y) = d(y, x)$
4. **Triangle inequality:** $d(x, z) \leq d(x, y) + d(y, z)$

The triangle inequality is the fundamental constraint: you cannot "cheat"
distance in a fixed metric space. But what if you could *change* the metric?

### 1.3 Wormholes as Metric Modifications

A **wormhole** in science fiction connects two distant points through a short
tunnel. Mathematically, this is equivalent to constructing a new metric space
from an existing one by identifying distant points.

**Theorem 1.2 (Quotient Metric Shortening).** Let $(X, d)$ be a metric space
and let $\sim$ be an equivalence relation on $X$. Define

$$\hat{d}([x], [y]) = \inf \left\{ \sum_{i=0}^{n-1} d(x_i, y_i) : x_0 = x,\, y_n = y,\, y_i \sim x_{i+1} \right\}$$

Then $\hat{d}([x], [y]) \leq d(x, y)$ for all $x, y \in X$.

*Proof.* Take $n = 1$, $x_0 = x$, $y_0 = y$ in the infimum. Since $y \sim y$,
this is an admissible chain, giving $\hat{d}([x],[y]) \leq d(x,y)$. ∎

This theorem captures the essential feature of a wormhole: the quotient
distance is never *longer* than the original distance.

### 1.4 The Triangle Inequality and Warp Bubbles

The Alcubierre warp drive, proposed by physicist Miguel Alcubierre in 1994,
works by contracting space ahead of a ship and expanding it behind. The key
mathematical insight is that while the ship moves slowly *locally*, it can
traverse large distances *globally* by reshaping the metric.

**Proposition 1.3.** For any $\varepsilon > 0$ and any two points $p, q$ in a
Lorentzian manifold, there exists (in principle) a metric perturbation such that
the proper time along a path from $p$ to $q$ is less than $\varepsilon$.

This is the mathematical content of the Alcubierre drive: geometry is
sufficiently flexible that travel time can be made arbitrarily small — at the
cost of requiring exotic matter with negative energy density.

### 1.5 Higher-Dimensional Shortcuts

**Theorem 1.4 (Embedding Shortcut).** Let $\gamma$ be a path of length $L$ on
the unit sphere $S^2 \subset \mathbb{R}^3$. Then the straight-line distance
through the interior satisfies

$$d_{\mathbb{R}^3}(\gamma(0), \gamma(1)) \leq L$$

with equality only when $\gamma$ is a geodesic (great circle arc) of length
equal to the chord length, which cannot happen for $L > 2$.

For $L = \pi$ (a half great circle), the chord distance is $2$ while the
surface distance is $\pi \approx 3.14$. The "hyperspace" shortcut through the
interior saves about 36% of the distance.

*This is formalized in `Hyperspace.lean`.*

---

## Chapter 2: Time Travel and Fixed Points

> *"Time is not a line. It is a circle. That is why clocks are round."*

### 2.1 The Bootstrap Paradox

The **bootstrap paradox** (or causal loop) occurs when an event is its own
cause. A character travels back in time and causes the very event that led
to their time travel. Mathematically, this is a **fixed point** problem.

### 2.2 Fixed Point Theorems

**Theorem 2.1 (Banach Fixed Point Theorem).** Let $(X, d)$ be a complete metric
space and $f : X \to X$ a contraction mapping, i.e., there exists $q \in [0,1)$
such that $d(f(x), f(y)) \leq q \cdot d(x, y)$ for all $x, y$. Then $f$ has a
unique fixed point $x^*$ satisfying $f(x^*) = x^*$.

**Interpretation for Time Travel.** If the universe's evolution operator $f$
(mapping one state of the universe to the next) is a contraction on some
appropriate space, then a **self-consistent time loop** must exist and be unique.
This is the mathematical foundation of the Novikov self-consistency principle:
the laws of physics conspire to prevent paradoxes.

**Theorem 2.2 (Brouwer Fixed Point Theorem).** Every continuous function
$f : B^n \to B^n$, where $B^n$ is the closed unit ball in $\mathbb{R}^n$, has
a fixed point.

The Brouwer theorem guarantees existence but not uniqueness. In the context of
time travel, this means: if the space of possible universe-states is
"ball-like" (compact and convex) and the evolution is continuous, then at least
one self-consistent timeline exists — but there may be multiple consistent
histories.

**Theorem 2.3 (Knaster-Tarski Fixed Point Theorem).** Let $(L, \leq)$ be a
complete lattice and $f : L \to L$ a monotone function. Then the set of fixed
points of $f$ forms a complete lattice (and in particular is non-empty).

**Interpretation.** If we partially order possible timelines by some
information-theoretic measure, and time travel preserves this ordering
(monotonicity), then the set of self-consistent timelines has rich structure —
including a "least" and "greatest" consistent timeline.

*Fixed point theorems are formalized in `TimeTravel.lean`.*

---

## Chapter 3: Topology and Impossible Spaces

> *"The house was bigger on the inside."*

### 3.1 Non-Orientable Spaces in Fiction

Science fiction frequently features spaces with impossible topology: the
TARDIS (bigger on the inside), Escher-like staircases, and rooms that
loop back on themselves. These have precise topological descriptions.

### 3.2 The Möbius Strip and Non-Orientability

**Definition 3.1.** A surface $S$ is *orientable* if it admits a consistent
choice of normal vector at every point. A surface is *non-orientable* if no
such choice exists.

The **Möbius strip** is the simplest non-orientable surface. A character walking
along a Möbius strip would return to their starting point mirror-reversed — a
plot device used in several science fiction stories.

**Theorem 3.2.** The Möbius strip is not orientable.

**Theorem 3.3.** The Klein bottle (a closed non-orientable surface) cannot be
embedded in $\mathbb{R}^3$ without self-intersection.

*Proof.* By the Jordan-Brouwer separation theorem, any compact surface embedded
in $\mathbb{R}^3$ separates space into an "inside" and an "outside," which
requires orientability. ∎

### 3.3 The Euler Characteristic and Space Stations

**Theorem 3.4 (Euler's Formula for Polyhedra).** For any convex polyhedron with
$V$ vertices, $E$ edges, and $F$ faces:

$$V - E + F = 2$$

This constrains the architecture of any polyhedral space station or habitat.
For a toroidal space station (like those in many SF stories), $V - E + F = 0$.

**Corollary 3.5.** A polyhedral space station with the topology of a torus must
have $E = V + F$. In particular, a toroidal station built from triangular
panels with $F$ faces requires $E = 3F/2$ edges and $V = F/2$ vertices.

*The Euler characteristic is formalized in `Topology.lean`.*

---

# Part II: Information, Computation, and Intelligence

---

## Chapter 4: The Limits of Alien Communication

> *"Mathematics is the universal language."*

### 4.1 Information Theory and First Contact

A recurring theme in science fiction is first contact with alien civilizations.
The mathematical question is: **what are the fundamental limits on
communication between radically different intelligences?**

### 4.2 Shannon Entropy

**Definition 4.1.** The *Shannon entropy* of a discrete random variable $X$
with probability mass function $p$ is:

$$H(X) = -\sum_{x} p(x) \log_2 p(x)$$

**Theorem 4.2 (Shannon's Source Coding Theorem).** The entropy $H(X)$ is the
minimum average number of bits needed to encode one sample from $X$.

### 4.3 Channel Capacity and Interstellar Communication

**Definition 4.3.** The *channel capacity* of a communication channel is:

$$C = \max_{p(x)} I(X; Y)$$

where $I(X;Y) = H(X) - H(X|Y)$ is the mutual information.

**Theorem 4.4 (Shannon's Channel Coding Theorem).** For any rate $R < C$,
there exist codes achieving arbitrarily low error probability. For $R > C$,
the error probability is bounded away from zero.

**Application to Interstellar Communication.** At interstellar distances, the
signal-to-noise ratio determines the channel capacity. For a transmitter with
power $P$ at distance $d$, the received power scales as $P/d^2$ (inverse
square law). The capacity of a Gaussian channel is:

$$C = W \log_2\left(1 + \frac{P}{d^2 N_0 W}\right) \text{ bits/second}$$

where $W$ is bandwidth and $N_0$ is noise spectral density. This formula
quantifies the fundamental tradeoff between distance and data rate in
interstellar communication.

### 4.4 Kolmogorov Complexity and Universal Language

**Definition 4.5.** The *Kolmogorov complexity* $K(x)$ of a string $x$ is the
length of the shortest program that produces $x$ on a universal Turing machine.

**Theorem 4.6 (Invariance Theorem).** For any two universal Turing machines
$U_1, U_2$, there exists a constant $c$ such that:

$$|K_{U_1}(x) - K_{U_2}(x)| \leq c$$

for all strings $x$.

**Interpretation.** This theorem is the mathematical basis for the science
fiction trope that "mathematics is the universal language." The Kolmogorov
complexity of a mathematical fact is essentially machine-independent: any
sufficiently advanced civilization would assign approximately the same
complexity to the same mathematical statements.

*Information-theoretic bounds are formalized in `Information.lean`.*

---

## Chapter 5: Computability and Artificial Intelligence

> *"I'm sorry, Dave. I'm afraid I can't do that."*

### 5.1 The Halting Problem and AI Safety

**Theorem 5.1 (Turing, 1936).** There is no algorithm that, given an arbitrary
program and input, determines whether the program halts.

**Corollary 5.2 (The AI Containment Problem).** There is no general algorithm
to determine whether an AI system will remain within specified behavioral
bounds.

*Proof.* If such an algorithm existed, we could use it to solve the halting
problem: given program $P$ and input $I$, construct an AI system that simulates
$P(I)$ and violates its bounds if and only if $P(I)$ halts. ∎

### 5.2 Gödel's Incompleteness and Machine Consciousness

**Theorem 5.3 (Gödel's First Incompleteness Theorem).** Any consistent formal
system $F$ capable of expressing basic arithmetic contains statements that are
true but unprovable within $F$.

This theorem has been cited by Roger Penrose and others as evidence that human
consciousness transcends computation. The argument (which remains controversial)
runs: a human mathematician can recognize the truth of a Gödel sentence for any
formal system, while the system itself cannot prove it. Therefore, human
mathematical reasoning cannot be captured by any single formal system.

**Theorem 5.4 (Gödel's Second Incompleteness Theorem).** No consistent formal
system $F$ capable of expressing basic arithmetic can prove its own consistency.

**Application to AI.** An artificial intelligence operating within a formal
system cannot prove that its own reasoning is consistent. This creates a
fundamental epistemic limitation for any AI: self-trust requires an act of faith
that cannot be justified within the system's own logic.

### 5.3 Rice's Theorem and the Limits of AI Analysis

**Theorem 5.5 (Rice's Theorem).** For any non-trivial property $P$ of
computable functions, the set $\{e : \varphi_e \text{ satisfies } P\}$ is
undecidable.

**Interpretation.** You cannot write a program that reliably determines whether
another program has *any* interesting semantic property — whether it's benign,
whether it optimizes a particular objective, whether it's conscious. This is a
fundamental obstacle to AI safety verification.

*Computability results are formalized in `Computability.lean`.*

---

## Chapter 6: The Mathematics of Virtual Reality

> *"What is real? How do you define real?"*

### 6.1 Simulation and Numerical Precision

**Definition 6.1.** A *floating-point number system* $\mathbb{F}(\beta, t, L, U)$
consists of numbers of the form:

$$x = \pm \beta^e \sum_{i=0}^{t-1} d_i \beta^{-i}$$

where $\beta$ is the base, $t$ is precision, $L \leq e \leq U$, and
$0 \leq d_i < \beta$.

**Theorem 6.2 (Machine Epsilon).** The smallest $\varepsilon > 0$ such that
$1 + \varepsilon \neq 1$ in $\mathbb{F}(\beta, t, L, U)$ is:

$$\varepsilon_{\text{mach}} = \beta^{1-t}$$

### 6.2 The Simulation Hypothesis

The simulation hypothesis (popularized by Nick Bostrom) asks: could our
universe be a computer simulation? The mathematical question is whether the
laws of physics are *computable*.

**Theorem 6.3.** If spacetime is continuous (modeled by $\mathbb{R}^4$), then a
perfect simulation requires processing uncomputable real numbers — which is
impossible on a Turing machine.

However:

**Theorem 6.4.** If physics is *discretizable* — i.e., all observable
predictions can be approximated to arbitrary precision using rational arithmetic
— then a simulation is possible in principle, requiring only polynomial
overhead for bounded-precision predictions.

The gap between these theorems is the mathematical core of the simulation
debate: it depends on whether continuous mathematics is *essential* to physics
or merely a *convenient approximation*.

---

# Part III: Growth, Civilization, and the Cosmos

---

## Chapter 7: Exponential Growth and the Fermi Paradox

> *"Where is everybody?"*

### 7.1 The Mathematics of Colonization

**Theorem 7.1 (Exponential Growth).** If a civilization colonizes new star
systems at a constant rate $r$ per existing colony per unit time, the number of
colonies at time $t$ satisfies:

$$N(t) = N_0 e^{rt}$$

**Corollary 7.2 (Colonization Timescale).** A civilization expanding at
$v = 0.01c$ (1% of light speed) could colonize the entire Milky Way galaxy
(diameter $\sim 10^5$ light-years) in approximately $10^7$ years — a tiny
fraction of the galaxy's $\sim 10^{10}$-year age.

### 7.2 The Drake Equation

The Drake equation estimates the number of detectable civilizations:

$$N = R_* \cdot f_p \cdot n_e \cdot f_l \cdot f_i \cdot f_c \cdot L$$

**Theorem 7.3 (Sensitivity to $L$).** In the Drake equation, $N$ is linear in
$L$ (average civilization lifetime). If all other factors are held constant,
doubling the average civilization lifetime doubles the expected number of
detectable civilizations.

### 7.3 The Great Filter

**Definition 7.1 (The Great Filter).** The *Great Filter* is whatever factor(s)
make the product $f_p \cdot n_e \cdot f_l \cdot f_i \cdot f_c \cdot L$
extremely small.

**Theorem 7.4 (Bayesian Update from Silence).** Let $P(\text{filter behind})$
be the prior probability that the Great Filter is in humanity's past, and
$P(\text{silence} | \text{filter behind})$, $P(\text{silence} | \text{filter ahead})$
be the probabilities of observing cosmic silence. By Bayes' theorem:

$$P(\text{filter behind} | \text{silence}) = \frac{P(\text{silence} | \text{filter behind}) \cdot P(\text{filter behind})}{P(\text{silence})}$$

If we observe silence but expect $P(\text{silence} | \text{filter behind})$ to
be low (civilizations should be visible if they survive), this *increases* the
posterior probability that the filter is ahead of us — a sobering conclusion.

*Exponential growth and Bayesian reasoning are formalized in `FermiParadox.lean`.*

---

## Chapter 8: The Kardashev Scale and Energy

> *"Any sufficiently advanced technology is indistinguishable from magic."*

### 8.1 The Kardashev Classification

Nikolai Kardashev proposed classifying civilizations by energy consumption:

- **Type I:** Uses all energy reaching its planet ($\sim 10^{16}$ W)
- **Type II:** Uses all energy of its star ($\sim 10^{26}$ W)
- **Type III:** Uses all energy of its galaxy ($\sim 10^{36}$ W)

### 8.2 The Mathematics of Dyson Spheres

**Theorem 8.1 (Dyson Sphere Energy Capture).** A Dyson sphere of radius $R$
around a star of luminosity $L$ intercepts total power:

$$P = L$$

(by conservation of energy — all luminosity is captured).

The surface area is $A = 4\pi R^2$, giving a power density of:

$$\sigma = \frac{L}{4\pi R^2}$$

**Theorem 8.2 (Equilibrium Temperature).** By the Stefan-Boltzmann law, the
equilibrium temperature of a Dyson sphere is:

$$T = \left(\frac{L}{4\pi R^2 \sigma_B}\right)^{1/4}$$

where $\sigma_B$ is the Stefan-Boltzmann constant. For a sphere at 1 AU around
a Sun-like star, $T \approx 394$ K ($\approx 121°$C).

### 8.3 The Continuous Kardashev Scale

**Definition 8.1.** The *Kardashev number* $K$ of a civilization using power
$P$ (in watts) is:

$$K = \frac{\log_{10}(P) - 6}{10}$$

**Theorem 8.3.** Current human civilization has $K \approx 0.73$ (using
$P \approx 1.8 \times 10^{13}$ W).

*The logarithmic Kardashev scale is formalized in `KardashevScale.lean`.*

---

## Chapter 9: Relativity and Time Dilation

> *"Time moves differently for those who travel among the stars."*

### 9.1 The Twin Paradox

**Theorem 9.1 (Time Dilation).** A clock moving at velocity $v$ relative to a
stationary observer ticks at rate:

$$\frac{d\tau}{dt} = \sqrt{1 - v^2/c^2}$$

where $\tau$ is proper time and $t$ is coordinate time.

**Theorem 9.2 (Twin Paradox Resolution).** If one twin travels at constant
speed $v$ to a star at distance $d$ and returns, the traveling twin ages:

$$\Delta \tau = \frac{2d}{v} \sqrt{1 - v^2/c^2}$$

while the stationary twin ages $\Delta t = 2d/v$. The ratio is:

$$\frac{\Delta \tau}{\Delta t} = \sqrt{1 - v^2/c^2} = \frac{1}{\gamma}$$

For $v = 0.99c$, the traveling twin ages only $\sim 14\%$ as much as the
stay-at-home twin.

### 9.2 The Relativistic Rocket Equation

**Theorem 9.3 (Relativistic Rocket Equation).** For a rocket with exhaust
velocity $v_e$ and mass ratio $M_0/M_f$, the final velocity is:

$$v = c \cdot \tanh\left(\frac{v_e}{c} \ln \frac{M_0}{M_f}\right)$$

Note that $v < c$ for all finite mass ratios — a mathematical proof that
rockets cannot reach light speed.

**Theorem 9.4.** The function $v(R) = c \cdot \tanh\left(\frac{v_e}{c} \ln R\right)$
is strictly increasing and satisfies $\lim_{R \to \infty} v(R) = c$.

*Proof.* $\tanh$ is strictly increasing and bounded by $(-1, 1)$, and
$\ln R \to \infty$ as $R \to \infty$. ∎

*Relativistic computations are formalized in `Relativity.lean`.*

---

## Chapter 10: Probability and Alien Life

> *"In an infinite universe, the improbable becomes inevitable."*

### 10.1 The Infinite Monkey Theorem

**Theorem 10.1 (Infinite Monkey Theorem).** Let $(X_n)_{n \geq 1}$ be an i.i.d.
sequence of random variables, each uniformly distributed on a finite alphabet
$\mathcal{A}$. For any finite string $w \in \mathcal{A}^k$:

$$P(\exists\, n : X_n X_{n+1} \cdots X_{n+k-1} = w) = 1$$

*Proof sketch.* The probability of *not* matching in any block of length $k$ is
$(1 - |\mathcal{A}|^{-k})$. For $n/k$ independent blocks:

$$P(\text{no match in first } n \text{ characters}) \leq (1 - |\mathcal{A}|^{-k})^{\lfloor n/k \rfloor} \to 0$$

By the Borel-Cantelli lemma, the string appears infinitely often a.s. ∎

**Application.** In an infinite universe with random initial conditions, any
finite pattern — including the molecular structure of life — occurs with
probability 1. The question is not *whether* alien life exists, but *how far
away* it is.

### 10.2 Expected Distance to Nearest Neighbor

**Theorem 10.2.** If civilizations are distributed as a Poisson process with
density $\rho$ per unit volume in $\mathbb{R}^3$, the expected distance to the
nearest civilization is:

$$E[D] = \Gamma(4/3) \cdot \left(\frac{3}{4\pi\rho}\right)^{1/3} \approx 0.554 \cdot \rho^{-1/3}$$

For $\rho \sim 1$ per galaxy ($\sim 10^{12}$ cubic light-years per galaxy):

$$E[D] \sim 0.554 \times 10^4 \text{ light-years}$$

*Probability bounds are formalized in `AlienLife.lean`.*

---

# Part IV: Paradoxes and Logic

---

## Chapter 11: Temporal Logic and Causality

> *"The future influences the present just as much as the past."*

### 11.1 Causal Ordering

**Definition 11.1.** A *causal structure* on a set $\mathcal{E}$ of events is a
partial order $\preceq$ where $e_1 \preceq e_2$ means $e_1$ can causally
influence $e_2$.

**Theorem 11.1.** A causal structure admits time travel (a causal loop) if and
only if the partial order $\preceq$ contains a cycle, i.e., there exist events
$e_1, \ldots, e_n$ with $e_1 \preceq e_2 \preceq \cdots \preceq e_n \preceq e_1$.

But this contradicts the antisymmetry of partial orders! Therefore:

**Corollary 11.2.** Time travel is incompatible with a strict causal partial
order. To accommodate time travel, one must weaken the causal structure to a
*preorder* (reflexive and transitive, but not antisymmetric), allowing distinct
events to be mutually causally connected.

### 11.2 Branching Time and the Many-Worlds Interpretation

**Definition 11.2.** A *branching time structure* is a pair $(T, \leq)$ where:
1. $(T, \leq)$ is a partial order
2. For any $t \in T$, the set $\{s \in T : s \leq t\}$ is totally ordered

This captures the idea that the past is unique but the future may branch. It is
the mathematical structure underlying the many-worlds interpretation of quantum
mechanics and numerous SF stories about parallel timelines.

**Theorem 11.3.** In a branching time structure, any two moments $t_1, t_2$
have a unique greatest common ancestor (their infimum, if it exists).

*Temporal logic and partial orders are formalized in `TemporalLogic.lean`.*

---

## Chapter 12: The Grandfather Paradox and Diagonal Arguments

> *"What happens if you go back in time and prevent your own birth?"*

### 12.1 Self-Reference and Paradox

The grandfather paradox is structurally identical to several famous results in
mathematical logic, all based on **diagonal arguments**.

**Theorem 12.1 (Cantor's Diagonal Theorem).** For any set $A$, there is no
surjection $f : A \to \mathcal{P}(A)$.

*Proof.* Suppose $f : A \to \mathcal{P}(A)$ is a surjection. Define
$D = \{a \in A : a \notin f(a)\}$. Since $f$ is surjective, $D = f(d)$ for
some $d$. Then $d \in D \iff d \notin f(d) \iff d \notin D$. Contradiction. ∎

**The Structural Analogy.** In the grandfather paradox:
- The "set" $A$ is the set of possible actions
- The "function" $f$ maps each action to the set of futures it creates
- The "diagonal" construction is: choose the action that negates its own
  consequence

Just as Cantor's theorem shows the power set is always "larger" than the
original set, the grandfather paradox shows that unrestricted time travel
creates a "future space" larger than the "action space" — a logical
impossibility.

**Theorem 12.2 (Russell's Paradox, Analogous Form).** There is no "set of all
sets that do not contain themselves."

**Theorem 12.3 (Lawvere's Fixed Point Theorem).** If $A$ and $B$ are objects in
a cartesian closed category with a point-surjective morphism
$\phi : A \to B^A$, then every endomorphism $f : B \to B$ has a fixed point.

*Contrapositive:* If some $f : B \to B$ has *no* fixed point, then no
surjection $A \to B^A$ exists. This unifies Cantor's theorem, the halting
problem, and the grandfather paradox into a single categorical framework.

*Diagonal arguments are formalized in `Paradoxes.lean`.*

---

# Part V: Formalized Proofs

Each chapter references companion Lean 4 files containing machine-verified
proofs of the key theorems. The files are:

| File | Contents |
|------|----------|
| `Hyperspace.lean` | Metric spaces, distance inequalities, sphere chord bounds |
| `TimeTravel.lean` | Fixed point theorems, contraction mappings |
| `Topology.lean` | Euler characteristic, fundamental properties |
| `Information.lean` | Entropy bounds, information inequalities |
| `Computability.lean` | Halting problem, diagonalization |
| `FermiParadox.lean` | Exponential growth, Bayesian reasoning |
| `Relativity.lean` | Time dilation, Lorentz factor properties |
| `AlienLife.lean` | Probability bounds, Poisson processes |
| `TemporalLogic.lean` | Partial orders, causal structures |
| `Paradoxes.lean` | Cantor's theorem, diagonal arguments |

---

# Appendix A: Notation and Conventions

- $\mathbb{N}, \mathbb{Z}, \mathbb{Q}, \mathbb{R}, \mathbb{C}$: natural numbers,
  integers, rationals, reals, complex numbers
- $\log$: natural logarithm unless otherwise specified
- $\log_2$: base-2 logarithm
- $c$: speed of light in vacuum ($\approx 3 \times 10^8$ m/s)
- $[n]$: the equivalence class of $n$
- $\mathcal{P}(A)$: the power set of $A$

---

# Appendix B: Further Reading

1. **Geometry and Relativity:** Misner, Thorne, and Wheeler, *Gravitation* (1973)
2. **Information Theory:** Cover and Thomas, *Elements of Information Theory* (2006)
3. **Computability:** Sipser, *Introduction to the Theory of Computation* (2012)
4. **Topology:** Munkres, *Topology* (2000)
5. **Fixed Point Theory:** Granas and Dugundji, *Fixed Point Theory* (2003)
6. **The Physics of Science Fiction:** Kaku, *Physics of the Impossible* (2008)

---

*This textbook was produced with machine-verified proofs in Lean 4 using Mathlib.*
