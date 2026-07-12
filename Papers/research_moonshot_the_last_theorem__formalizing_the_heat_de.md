# The Last Theorem: Countable Provability against a Finite Physical Budget

## Abstract

We formalize a simple but far-reaching tension between the structure of provable
mathematics and the physical limits of computation. Modeling a *theorem* as a
finite string over a fixed finite alphabet that is derivable from the standard
axioms of set theory (ZFC), we prove that the collection $T$ of all theorems is
**countably infinite**. Countability guarantees that every theorem occupies a
finite position in a single enumeration, so each is discoverable after finitely
many steps: nothing provable lies "at infinity." We then model any physically
realizable discovery process as an enumerator with a finite operation budget
$N_{\max}$, motivated by the cosmological bound $N_{\max} \approx 10^{120}$ on the
total number of elementary operations available before the heat death of the
universe. Confronting the countable-infinite target with the finite budget, we
prove that the **discoverable fraction is zero**: the natural density of any
finite set within a countably infinite enumeration vanishes. We then examine
whether holographic memory can help. Using the Bekenstein–Hawking relation, we
show a black hole of mass $M$ stores $I(M) \propto M^2$ bits — a quadratic
*area* law rather than a volume law. We prove that quadratic storage strictly
dominates any fixed linear budget beyond an explicit crossover mass, yet we also
prove a robustness theorem: any storage law that is finite for every finite mass
leaves the discoverable fraction at zero. The governing dichotomy is
finite-versus-infinite, not slow-versus-fast. We close with numerical
illustrations, algorithms for enumeration and capacity accounting, and a
discussion of the resulting "thermodynamic horizon of discovery."

**Keywords:** countable sets, recursive enumerability, ZFC, natural density,
heat death, Landauer/Lloyd bound, Bekenstein bound, holographic principle,
Bekenstein–Hawking entropy, limits of computation.

---

## 1. Introduction

Two intuitions about mathematics pull in opposite directions. The first is that
mathematics is *inexhaustible*: there is always another theorem to prove, another
truth to uncover. The second is that mathematics is, in some sense, *complete and
enumerable*: fix your axioms and rules of inference, and the set of consequences
is fully determined and can be mechanically generated.

Both intuitions are correct, and both are made precise by the same observation:
the set of provable statements over a finite alphabet is **countably infinite**.
Infinite captures inexhaustibility; countable captures enumerability. The purpose
of this paper is to take these classical facts seriously as *physical* statements
and to ask what happens when an idealized, but physically constrained, agent tries
to discover theorems.

The constraint we impose is the one the universe imposes: a finite total budget of
elementary operations, ultimately capped by the heat death of the cosmos. Against
a countably infinite target, any finite budget captures a set of **density zero**.
This is our central result (Theorem 4). We then ask whether exotic physical
storage — specifically, black-hole (holographic) memory obeying an area law —
alters the verdict. It does not (Theorem 6), because the decisive dichotomy is
finite versus infinite capacity, and every finite mass yields finite capacity.

Our contribution is not any single fact — each ingredient is classical — but their
assembly into a single, rigorous chain of reasoning connecting the *countability
of proof* to the *thermodynamics of computation*, with sharp quantitative
statements (the crossover mass, the density limit, the robustness dichotomy) at
each junction.

---

## 2. Definitions and setup

### 2.1 Statements as strings

Fix a finite alphabet $\Sigma$ with $|\Sigma| = a \ge 2$ symbols, rich enough to
express the language of first-order set theory (variables, the membership and
equality relations, logical connectives, quantifiers, and punctuation).

**Definition 2.1 (Strings).** A *statement* is a finite string over $\Sigma$. The
set of all finite strings is
$$\Sigma^{*} = \bigcup_{n \ge 0} \Sigma^{n},$$
where $\Sigma^{n}$ is the set of strings of length exactly $n$, with
$|\Sigma^{n}| = a^{n}$.

**Definition 2.2 (Theorems).** Fix the axiom system ZFC together with a sound and
complete deductive calculus for first-order logic. A statement $\varphi \in
\Sigma^{*}$ is a *theorem* if there is a finite derivation of $\varphi$ from the
axioms of ZFC. Let
$$T = \{\varphi \in \Sigma^{*} : \text{ZFC} \vdash \varphi\}.$$

We assume throughout that ZFC is consistent, so $T$ is a proper subset of the
well-formed sentences (it does not contain both $\varphi$ and $\lnot\varphi$).

### 2.2 Enumerators and budgets

**Definition 2.3 (Enumerator).** An *enumerator* is a function $E : \mathbb{N} \to
\Sigma^{*}$ whose range is contained in $T$ and which, given unbounded time,
outputs each element of some target subset of $T$. Because provability is
semi-decidable (a derivation, once found, can be checked in finitely many steps),
$T$ is recursively enumerable, and such an enumerator exists.

**Definition 2.4 (Operation budget).** A *budgeted enumerator* is a pair
$(E, N)$ where $N \in \mathbb{N}$ is the maximum number of elementary operations
the process may perform. It exhibits at most a finite set
$$D(E,N) = \{E(0), E(1), \dots, E(m-1)\} \subseteq T,$$
where $m = m(E,N)$ is finite because each output consumes at least one operation,
so $m \le N$.

### 2.3 Discoverable fraction

**Definition 2.5 (Natural density along an enumeration).** Fix a bijective
enumeration $t : \mathbb{N} \to T$, $t(k) = t_k$. For a subset $D \subseteq T$,
its *density along $t$* is
$$\delta_t(D) = \lim_{n \to \infty} \frac{\#\{k < n : t_k \in D\}}{n},$$
when the limit exists. The *discoverable fraction* of a budgeted enumerator is
$\delta_t\big(D(E,N)\big)$.

### 2.4 Physical storage laws

**Definition 2.6 (Storage law).** A *storage law* is a monotone nondecreasing
function $I : [0,\infty) \to [0,\infty)$, where $I(M)$ is the number of bits
storable using resources of mass $M$. A law is *linear* if $I(M) = \beta M$, and
*area/quadratic (holographic)* if $I(M) = \gamma M^{2}$, for constants
$\beta, \gamma > 0$. A storage law is *finitary* if $I(M) < \infty$ for every
finite $M$.

---

## 3. Countability of the set of theorems

### Theorem 1 (Countability of strings).
*For a finite alphabet with $a \ge 1$ symbols, the set $\Sigma^{*}$ of all finite
strings is countably infinite.*

**Proof sketch.** Partition $\Sigma^{*}$ by length: $\Sigma^{*} =
\bigsqcup_{n \ge 0} \Sigma^{n}$ with $|\Sigma^{n}| = a^{n} < \infty$. A countable
union of finite sets is countable, so $\Sigma^{*}$ is countable. It is infinite
because $\Sigma^{n}$ is nonempty for every $n$ (choosing a fixed symbol repeated
$n$ times yields distinct strings of every length). Concretely, enumerate in
*shortlex* order — first by length, then lexicographically within each length —
to obtain an explicit bijection $\mathbb{N} \to \Sigma^{*}$. $\qquad\blacksquare$

### Theorem 2 (Countable infinitude of theorems).
*The set $T$ of theorems is countably infinite.*

**Proof sketch.** As a subset of the countable set $\Sigma^{*}$, $T$ is countable.
For infinitude, exhibit an injection $\mathbb{N} \hookrightarrow T$. The family of
sentences $\varphi_n :\equiv \big(\underline{0} \ne \underline{n+1}\big)$ — the
numeral for $0$ is distinct from the numeral for $n+1$ — are pairwise distinct
strings, and each is a theorem of ZFC (indeed of much weaker arithmetic). Hence
$T$ is infinite. A countable infinite set admits a bijection with $\mathbb{N}$.
$\qquad\blacksquare$

### Theorem 3 (Finite-index discoverability).
*Fix a bijective enumeration $t : \mathbb{N} \to T$. Then for every theorem
$\varphi \in T$ there is a finite index $k$ with $t_k = \varphi$; consequently an
unbudgeted enumerator reaches $\varphi$ after finitely many steps.*

**Proof sketch.** Immediate from bijectivity: $k = t^{-1}(\varphi) \in
\mathbb{N}$ is finite by definition. No theorem sits "at infinity." $\qquad
\blacksquare$

Theorem 3 is the optimistic pole of the paper: **in principle**, with unbounded
resources, all of mathematics is discoverable. The remaining results supply the
pessimistic pole.

---

## 4. The finite budget forces density zero

### Lemma 4.1 (Budget bounds output).
*A budgeted enumerator $(E, N)$ satisfies $|D(E,N)| \le N$.*

**Proof sketch.** Producing and recording each distinct output consumes at least
one elementary operation; with a total of $N$ operations, at most $N$ distinct
outputs are produced. $\qquad\blacksquare$

### Theorem 4 (Discoverable fraction is zero).
*Let $t : \mathbb{N} \to T$ be any bijective enumeration and let $D \subseteq T$
be finite (e.g. $D = D(E,N)$ for a budgeted enumerator). Then*
$$\delta_t(D) = \lim_{n \to \infty} \frac{\#\{k < n : t_k \in D\}}{n} = 0.$$

**Proof sketch.** Since $D$ is finite, $\#\{k < n : t_k \in D\} \le |D|$ for all
$n$. Hence
$$0 \le \frac{\#\{k < n : t_k \in D\}}{n} \le \frac{|D|}{n} \xrightarrow[n \to
\infty]{} 0.$$
By the squeeze principle the limit is $0$. $\qquad\blacksquare$

**Corollary 4.2 (Thermodynamic horizon).** With the cosmological bound $N \le
N_{\max} \approx 10^{120}$, any physically realizable discovery process has
discoverable fraction $0$. Almost every theorem, in the sense of density one, is
physically undiscoverable.

The estimate $N_{\max} \approx 10^{120}$ arises from three physical inputs: (i) a
maximum state-transition rate proportional to available energy (the
Margolus–Levitin / Lloyd bound), (ii) a finite energy budget within the cosmic
horizon, and (iii) the eventual exhaustion of free energy at heat death, after
which no operation can be driven. Their product bounds the lifetime operation
count of the observable universe.

---

## 5. Holographic storage and the Bekenstein bound

Confronted with a finite budget, one may try to *enlarge memory*. The maximal
information density permitted by physics is holographic: it scales with area, not
volume. We make this quantitative.

### Theorem 5 (Quadratic (area) storage law for black holes).
*A Schwarzschild black hole of mass $M$ stores a number of bits proportional to
$M^{2}$:*
$$I(M) = \frac{4\pi G}{\hbar c \ln 2}\, M^{2} \;=\; \gamma\, M^{2}, \qquad
\gamma = \frac{4\pi G}{\hbar c \ln 2} > 0.$$

**Proof sketch.** The Schwarzschild radius is $r_s = 2GM/c^{2}$, so the horizon
area is
$$A = 4\pi r_s^{2} = \frac{16\pi G^{2}}{c^{4}} M^{2}.$$
The Bekenstein–Hawking entropy is $S_{\mathrm{BH}} = \dfrac{k_B c^{3}}{4 G \hbar}
A$. Substituting the area,
$$S_{\mathrm{BH}} = \frac{k_B c^{3}}{4 G \hbar}\cdot \frac{16\pi G^{2}}{c^{4}}
M^{2} = \frac{4\pi k_B G}{\hbar c} M^{2}.$$
Converting entropy to bits via $I = S/(k_B \ln 2)$ gives
$I(M) = \dfrac{4\pi G}{\hbar c \ln 2} M^{2}$, which is $\gamma M^{2}$. The
essential point is structural: horizon *radius* scales as $M$, horizon *area*
scales as $M^{2}$, and storable information scales with area — the holographic
(area) law. $\qquad\blacksquare$

### Theorem 6a (Quadratic strictly dominates linear beyond a crossover).
*For a linear budget $I_{\mathrm{lin}}(M) = \beta M$ and the area law
$I_{\mathrm{hol}}(M) = \gamma M^{2}$, define the crossover mass
$M^{\star} = \beta/\gamma$. Then $I_{\mathrm{hol}}(M) > I_{\mathrm{lin}}(M)$ for
all $M > M^{\star}$, with equality at $M = M^{\star}$.*

**Proof sketch.** $\gamma M^{2} - \beta M = M(\gamma M - \beta)$, which is
positive precisely when $M > \beta/\gamma$ (for $M > 0$) and zero at $M =
\beta/\gamma$. The crossover mass depends only on the two coefficients and is
explicit and computable. $\qquad\blacksquare$

The crossover $M^\star$ marks a genuine phase boundary in the *character* of
discovery: below $M^\star$ a process is **budget-limited** (memory is the binding
constraint), while above $M^\star$ it is **enumeration-limited** (time to
generate, not room to store, is the binding constraint). The two regimes carry
distinct scaling of statements exhibited per unit resource.

### Theorem 6b (Robustness: any finitary storage still gives density zero).
*Let $I$ be any finitary storage law and let the mass be any finite $M$. Then the
number of theorems storable is $I(M) < \infty$, and by Theorem 4 the discoverable
fraction is $0$. The fraction is positive only if the stored set is infinite,
which requires $I(M) = \infty$ at some finite $M$.*

**Proof sketch.** A finite bit-capacity encodes only finitely many distinct
strings, hence a finite subset $D \subseteq T$; apply Theorem 4. Conversely, a
positive density requires an infinite $D$, which requires infinite capacity at
finite mass — excluded for every finitary law, in particular for the quadratic
area law and for any super-polynomial-but-finite law. $\qquad\blacksquare$

**Corollary 6c (The decisive dichotomy).** Increasing the growth rate of a
finitary storage law (linear $\to$ quadratic $\to$ super-polynomial) changes the
*rate* at which the discoverable fraction approaches zero and shifts the crossover
mass, but never changes the *limit*, which is zero. The operative distinction is
**finite versus infinite** capacity, not **slow versus fast** growth.

---

## 6. Algorithms

We record three procedures underlying the results. Full type-hinted
implementations accompany this paper.

**(A) Shortlex enumeration of strings / theorem candidates.** Generate
$\Sigma^{*}$ in shortlex order to realize the bijection of Theorem 1, providing
the backbone enumeration $t$ used throughout.

**(B) Budgeted discovery simulation.** Given an operation budget $N$ and a per-item
cost model, count how many list positions a process reaches, illustrating Lemma
4.1 and the density collapse of Theorem 4.

**(C) Holographic capacity and crossover accounting.** Compute $I(M)$ from the
Bekenstein–Hawking constants, compare against a linear budget, and solve for the
crossover mass $M^\star = \beta/\gamma$ of Theorem 6a.

---

## 7. Numerical illustrations

Representative figures (reproduced by the accompanying code):

- **Density collapse.** With a fixed discovered count $N$, the ratio $N/n$ falls
  as $1/n$; for $N = 10^{120}$ and $n = 10^{240}$ the discovered fraction is
  $10^{-120}$, already indistinguishable from zero and formally $\to 0$.
- **Black-hole storage.** A solar-mass black hole ($M \approx 2\times10^{30}$ kg)
  stores on the order of $10^{77}$ bits; a supermassive black hole of
  $10^{9}$ solar masses stores on the order of $10^{95}$ bits — vast, finite, and
  still a density-zero slice of $T$.
- **Crossover.** For any fixed linear coefficient $\beta$, the area law overtakes
  it at $M^\star = \beta/\gamma$; beyond $M^\star$ storage grows quadratically
  while the linear budget lags, yet the discoverable fraction of both is zero.

---

## 8. Discussion

The results assemble into a single narrative with a sharp moral. Provable
mathematics is *inexhaustible in the mildest way*: it is a single countable list
in which every entry has a finite index (Theorems 1–3). The physical universe is
*exhaustible in the strongest way*: it admits only finitely many operations before
heat death (Corollary 4.2). Between a countable-infinite target and a finite
budget, the discoverable fraction is exactly zero (Theorem 4), and this verdict is
robust to any finitary enhancement of memory, including the holographic area law
that governs black-hole storage (Theorems 5, 6a–6c).

Three points deserve emphasis. First, the zero is *structural*, not
technological: it follows from cardinality and a squeeze, not from any assumption
about the cleverness of algorithms. Second, holography genuinely helps — the
area law strictly dominates any linear budget past an explicit crossover mass — but
"more" is not "enough" when the target is infinite. Third, the true dividing line
is finite versus infinite capacity; growth *rate* controls only the approach to
zero, never the destination.

A conceptual caveat: we identify "theorems" with derivable strings and measure
"fraction" by density along an enumeration. Other natural weightings (e.g. by
proof length or by a probability measure on formulas) yield the same qualitative
conclusion, since any finite discovered set has weight-zero limit under any measure
that spreads mass over infinitely many formulas without atoms of unbounded size.

---

## 9. Future directions

**1. Density-graded inexhaustibility.** For every productive deductive system
there should be a length-graded enumeration in which the discoverable fraction
decays no faster than the reciprocal of the enumeration index, and this rate is
conjecturally optimal across all enumerations — making finiteness of the budget,
not the growth law of the resource, the true controller of asymptotic density.

**2. Area-law optimality of holographic memory.** Among all monotone storage laws
bounded by the surface area of a region, the quadratic-in-mass Bekenstein–Hawking
law is conjecturally the unique maximizer of total storable information at fixed
enclosed energy — because the horizon *area*, not the enclosed volume, is the true
capacity variable.

**3. The quadratic-beats-linear crossover as a phase boundary.** The crossover
mass $M^\star$ conjecturally marks a genuine threshold with distinct scaling
exponents on either side: budget-limited below, enumeration-limited above.

**4. Robustness of fraction-zero under super-polynomial storage.** Replacing the
area law by any storage law finite for every finite mass — including hypothetical
super-polynomial laws — should leave the discoverable fraction tending to zero; a
positive fraction requires storage that becomes actually infinite at some finite
mass.

---

## 10. Conclusion

The book of mathematics has no final page: its theorems form a countable, infinite
list, each reachable in finitely many steps. Yet the universe grants only a finite
prefix — sealed by heat death, and unrescued even by writing our knowledge on the
event horizons of black holes. The discoverable fraction is, and remains, zero.
The endless frontier is guaranteed by a theorem; how we spend our finite budget
upon it is a choice.
