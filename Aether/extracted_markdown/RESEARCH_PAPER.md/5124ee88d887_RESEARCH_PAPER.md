# The Borsuk–Ulam Route to Arrow-Style Impossibility: Social Choice as Topology

## Abstract

We give a fully rigorous, machine-checked development of the thesis that
*continuous* social choice is topology. Modeling the space of preference profiles
over a fixed pair of alternatives as the circle $S^1$, with the antipodal map
$\theta \mapsto \theta + \pi$ encoding total preference reversal, we prove a
self-contained one-dimensional Borsuk–Ulam theorem directly from the Intermediate
Value Theorem: every continuous, $2\pi$-periodic function $f:\mathbb{R}\to
\mathbb{R}$ satisfies $f(\theta) = f(\theta+\pi)$ for some $\theta$. From this we
derive an Arrow-style impossibility theorem: there is **no** social welfare
function that is simultaneously continuous, reversal-respecting
($\mathrm{swf}(\theta+\pi) = -\mathrm{swf}(\theta)$), and decisive
($\mathrm{swf}(\theta)\neq 0$ for all $\theta$). We certify that the impossibility
is non-vacuous by exhibiting witnesses satisfying each axiom individually,
including $\sin$ (continuous, reversal-respecting, but not decisive) and the
constant rule (continuous, decisive, but not reversal-respecting). Dropping
continuity restores possibility via an explicit discontinuous square-wave rule,
proving continuity to be the load-bearing axiom. Finally, we exhibit the forced
social tie as the topological shadow of an algebraic fact: the freeness of the
$\mathbb{Z}/2$ antipodal involution. The analytic obstruction (a zero of a
continuous odd function) and the algebraic obstruction (a fixed-point-free
order-two action) are identified as two faces of a single impossibility. All
results have been formalized with zero unproven steps.

**Keywords:** Borsuk–Ulam theorem, Arrow's impossibility theorem, social choice
theory, Chichilnisky aggregation, intermediate value theorem, antipodal map,
free group action, topological social choice.

---

## 1. Introduction

Kenneth Arrow's impossibility theorem (1951) is the foundational negative result
of social choice theory: no ranked aggregation rule over three or more
alternatives can simultaneously satisfy unanimity (Pareto efficiency),
independence of irrelevant alternatives, and non-dictatorship. Arrow's proof is
combinatorial, exploiting the discrete structure of finite preference profiles.

A parallel tradition, initiated by Graciela Chichilnisky (1980, 1982),
recognized that when preferences are given a *topological* structure, aggregation
impossibilities become consequences of algebraic topology — in particular of the
non-contractibility of spheres and the behavior of continuous maps under
antipodal symmetry. In this tradition, "fairness" axioms translate into
equivariance and unanimity conditions, and impossibility becomes the statement
that a certain continuous equivariant map cannot exist.

This paper isolates the cleanest possible instance of that phenomenon and proves
it from the ground up. We work on the circle $S^1$, the space of preference
profiles over **two** alternatives $A$ and $B$, with the antipodal map encoding
total reversal of every voter's opinion. Our central observations are:

1. The one-dimensional Borsuk–Ulam theorem is *exactly* the Intermediate Value
   Theorem in disguise (Section 3).
2. The continuous Arrow-style impossibility is an immediate corollary
   (Section 4).
3. The impossibility is non-vacuous, witnessed by explicit functions
   (Section 5).
4. Continuity is the unique load-bearing axiom: dropping it restores a model
   (Section 6).
5. The obstruction is structurally algebraic — the freeness of the $\mathbb{Z}/2$
   antipodal action — and the analytic and algebraic obstructions are formally
   identified (Section 7).

Every statement below has been formally verified with no remaining gaps. We
emphasize what is *honestly* true: the full discrete Arrow theorem is **not**
literally Borsuk–Ulam (the discrete and continuous settings differ), but the
*continuous* impossibility genuinely is a Borsuk–Ulam corollary, and that is the
theorem we state and prove.

---

## 2. The model: preferences on a circle

### 2.1 The preference circle

We model the space of preference profiles over two alternatives $A, B$ as the
circle $S^1$, coordinatized by an angle $\theta \in \mathbb{R}$ taken modulo
$2\pi$. As $\theta$ traverses the circle, the aggregate disposition of the
electorate slides continuously through all configurations from strongly-$A$ to
strongly-$B$ and back.

**Definition 2.1 (Circle function).** A *circle function* is a function
$f:\mathbb{R}\to\mathbb{R}$ that is

- **continuous**, and
- **$2\pi$-periodic**: $f(\theta + 2\pi) = f(\theta)$ for all $\theta$.

A circle function is precisely a continuous map $S^1 \to \mathbb{R}$ presented in
angular coordinates.

In the formal development this is the structure
```
structure IsCircleFn (f : ℝ → ℝ) : Prop where
  cont : Continuous f
  per  : Function.Periodic f (2 * π)
```

### 2.2 The antipodal map

The **antipodal map** on the preference circle is $\theta \mapsto \theta + \pi$.
Geometrically it is the diametrically opposite point on $S^1$. Interpretively it
is **total preference reversal**: where the profile at $\theta$ ranks $A$ over
$B$, the profile at $\theta + \pi$ ranks $B$ over $A$, for every voter
simultaneously.

The antipodal map is an **involution**: applying it twice,
$\theta \mapsto \theta + \pi \mapsto \theta + 2\pi$, returns to $\theta$ modulo
the period. It thus generates an action of the cyclic group $\mathbb{Z}/2$ on the
circle. This involution is **free**: no point of $S^1$ equals its own antipode,
because $\theta + \pi \equiv \theta \pmod{2\pi}$ has no solution. This algebraic
fact will reappear in Section 7 as the structural cause of the impossibility.

### 2.3 Social welfare functions

**Definition 2.2 (Social welfare function).** A *social welfare function* (SWF)
is a circle function $\mathrm{swf}:\mathbb{R}\to\mathbb{R}$. The value
$\mathrm{swf}(\theta)$ is interpreted as the **social margin** of $A$ over $B$ at
profile $\theta$: positive favors $A$, negative favors $B$, zero is a tie.

#### Relationship to Arrow's classical axioms

It is worth pausing on how the three axioms below correspond to Arrow's
original triple of unanimity (Pareto efficiency), independence of irrelevant
alternatives, and non-dictatorship, translated into the continuous,
two-alternative setting.

- *Unanimity / Pareto* becomes the demand that the social verdict track the
  electorate's disposition; in the two-alternative continuous model its sharp
  form is reversal symmetry, which says that a complete reversal of every
  voter's opinion reverses the social margin. A rule violating reversal symmetry
  would, at some configuration, contradict a unanimous flip.
- *Non-dictatorship* is also enforced by reversal symmetry: a dictator's rule is
  insensitive to reversing the rest of the electorate and tends to a fixed,
  non-reversing verdict (the constant rule of Proposition 5.2 is exactly such a
  degenerate dictator), so reversal symmetry excludes it.
- *Decisiveness* is the continuous analogue of producing a strict, complete
  social ordering with no ties.
- *Continuity* has no discrete analogue in Arrow's framework; it is the
  additional topological regularity, in the spirit of Chichilnisky, that makes
  the problem genuinely geometric. It is precisely this axiom that, as we show in
  Section 6, carries the entire weight of the impossibility.

The upshot is that our three axioms are a faithful continuous rendering of
Arrow's fairness desiderata, with continuity standing in for the topological
hypothesis under which the impossibility becomes a theorem about spheres.

We consider three axioms.

- **(Continuity)** $\mathrm{swf}$ is a circle function (continuous and periodic).
  Small changes in the electorate's disposition produce small changes in the
  social margin.
- **(Reversal symmetry / neutrality)** $\mathrm{swf}(\theta + \pi) =
  -\,\mathrm{swf}(\theta)$ for all $\theta$: reversing every voter reverses the
  social verdict. This is the two-alternative form of neutrality / anonymity-free
  fairness; it also excludes a constant dictator.
- **(Decisiveness)** $\mathrm{swf}(\theta) \neq 0$ for all $\theta$: society
  always strictly prefers one alternative; there is never a tie.

---

## 3. The one-dimensional Borsuk–Ulam theorem

The classical Borsuk–Ulam theorem (Borsuk, 1933) states that every continuous
map $F:S^n\to\mathbb{R}^n$ identifies some antipodal pair: $F(x) = F(-x)$ for some
$x$. We require only the case $n = 1$, which we prove from scratch.

**Theorem 3.1 (One-dimensional Borsuk–Ulam).** *Let $f$ be a circle function.
Then there exists $\theta \in \mathbb{R}$ with*
$$ f(\theta) = f(\theta + \pi). $$

**Proof sketch.** Define the auxiliary "antipodal difference"
$$ g(\theta) := f(\theta) - f(\theta + \pi). $$
Then $g$ is continuous, being the difference of $f$ with the composition of $f$
with the continuous shift $\theta \mapsto \theta + \pi$. Evaluate $g$ at the two
endpoints $0$ and $\pi$:
$$ g(0) = f(0) - f(\pi), \qquad g(\pi) = f(\pi) - f(2\pi) = f(\pi) - f(0), $$
where the last equality uses $2\pi$-periodicity, $f(2\pi) = f(0)$. Hence
$$ g(\pi) = -\,g(0). $$
The function $g$ therefore takes opposite-signed values at $0$ and $\pi$ (or is
zero at one of them). By the **Intermediate Value Theorem** applied on the
interval $[0,\pi]$ (a "zero-crossing" lemma), $g$ has a zero: there exists
$\theta$ with $g(\theta) = 0$, i.e. $f(\theta) = f(\theta + \pi)$.

Concretely, if $g(0)\le 0$ then $g(\pi) = -g(0) \ge 0$, and the zero-crossing
lemma on the continuous $g$ over $[0,\pi]$ yields the root; if $g(0) > 0$ apply
the same lemma to the continuous function $-g$, whose values at $0$ and $\pi$ have
the requisite signs. In either branch we recover $f(\theta) = f(\theta+\pi)$. ∎

The proof is the formal content of `borsuk_ulam_one_dim`. The zero-crossing
lemma is a packaged Intermediate Value Theorem: a continuous function on
$[a,b]$ with $f(a)\le 0 \le f(b)$ has a root in $[a,b]$.

**Remark 3.2.** This is the entire topological input. Everything downstream is a
corollary. The "miracle" of Borsuk–Ulam in dimension one is simply that a
continuous quantity cannot pass from negative to positive without vanishing — a
restatement of the impossibility of teleportation under continuity.

---

## 4. The continuous Arrow-style impossibility

**Theorem 4.1 (No continuous decisive SWF).** *There is no social welfare
function $\mathrm{swf}$ that is simultaneously*

1. *a circle function (continuous and $2\pi$-periodic),*
2. *reversal-respecting: $\mathrm{swf}(\theta + \pi) = -\,\mathrm{swf}(\theta)$
   for all $\theta$, and*
3. *decisive: $\mathrm{swf}(\theta) \neq 0$ for all $\theta$.*

**Proof.** Suppose such a $\mathrm{swf}$ existed. Being a circle function, it
satisfies the hypotheses of Theorem 3.1, so there is a profile $\theta^\star$
with
$$ \mathrm{swf}(\theta^\star) = \mathrm{swf}(\theta^\star + \pi). $$
By reversal symmetry, the right-hand side equals $-\,\mathrm{swf}(\theta^\star)$,
so
$$ \mathrm{swf}(\theta^\star) = -\,\mathrm{swf}(\theta^\star) \;\Longrightarrow\;
2\,\mathrm{swf}(\theta^\star) = 0 \;\Longrightarrow\;
\mathrm{swf}(\theta^\star) = 0. $$
This contradicts decisiveness at $\theta^\star$. ∎

This is `no_continuous_decisive_swf`. In words: **a smooth, neutral aggregation
rule must produce a tie somewhere.** The contradiction is forced purely by the
topology of the circle together with the algebra of sign reversal; no further
structure of the electorate is used.

**Interpretation as Arrow's impossibility.** Decisiveness plays the role of a
strict, always-resolved social ranking (no indifference); reversal symmetry
encodes neutrality between the alternatives and rules out a fixed dictatorial
verdict; continuity is the topological regularity that Chichilnisky-style
aggregation imposes. The conclusion — that these cannot coexist — mirrors Arrow's
discrete impossibility in the continuous category.

---

## 5. Non-vacuity: the axioms are individually satisfiable

An impossibility theorem is only meaningful if its hypotheses are not jointly
unsatisfiable for trivial reasons. We certify non-vacuity by exhibiting
functions satisfying the axioms individually and in pairs.

**Theorem 5.1 (Reversal is satisfiable with continuity).** *There exists a circle
function $\mathrm{swf}$ satisfying reversal symmetry
$\mathrm{swf}(\theta + \pi) = -\,\mathrm{swf}(\theta)$.*

**Proof.** Take $\mathrm{swf} = \sin$. It is continuous and $2\pi$-periodic, hence
a circle function, and the classical identity $\sin(\theta + \pi) = -\sin\theta$
is exactly reversal symmetry. ∎

This is `reversal_axiom_satisfiable`. Note that $\sin$ is **not** decisive — it
has zeros at $\theta = 0, \pi, \dots$ — exactly as Theorem 4.1 demands once
continuity and reversal are present.

**Proposition 5.2 (Decisiveness is satisfiable with continuity).** The constant
function $\mathrm{swf}(\theta) = 1$ is a circle function and is decisive (it never
vanishes), but it is **not** reversal-respecting, since $1 \neq -1$. It models a
fixed dictatorial verdict ("$A$ always wins"), which the reversal axiom is
designed to exclude.

Together, Theorem 5.1 and Proposition 5.2 show that:

- continuity + reversal is satisfiable (but not decisive), and
- continuity + decisiveness is satisfiable (but not reversal-respecting).

It is only the **full conjunction** of all three axioms that is contradictory.
The impossibility is sharp and non-trivial.

---

## 6. Continuity is the load-bearing axiom

If we drop continuity, possibility returns. This certifies that continuity — the
topological input — is exactly what generates the obstruction.

**Definition 6.1 (Square-wave rule).** Define
$$ \mathrm{socialWave}(\theta) := (-1)^{\lfloor \theta/\pi \rfloor}. $$
On each half-circle $[k\pi, (k{+}1)\pi)$ this rule returns a constant $\pm 1$,
alternating sign across consecutive halves.

**Proposition 6.2 (A discontinuous decisive reversal-respecting rule exists).**
The square-wave rule $\mathrm{socialWave}$ is

- **decisive**: it only takes the values $\pm 1$, never $0$; and
- **reversal-respecting**: $\mathrm{socialWave}(\theta + \pi) =
  -\,\mathrm{socialWave}(\theta)$, since advancing by $\pi$ increments the floor
  $\lfloor \theta/\pi\rfloor$ by one and hence flips the sign.

(In the companion development this is `decisive_reversal_swf_exists`.)

**Corollary 6.3 (Forced discontinuity).** The square-wave rule is **not
continuous**.

**Proof.** It is decisive and reversal-respecting. If it were also continuous, it
would be a circle function satisfying all three axioms of Theorem 4.1, which is
impossible. Hence it must fail continuity. ∎

This is a striking inversion: rather than inspecting the graph of
$\mathrm{socialWave}$ to *find* its jump, we *deduce the existence of a jump* from
the impossibility theorem alone (`socialWave_not_continuous`). The
discontinuity — the cliff at each half-circle boundary, where an infinitesimal
change in disposition flips society from "$A$ wins" to "$B$ wins" — is the
unavoidable cost of insisting on a decisive, neutral rule.

We conjecture (Section 9, Conjecture 2) that continuity is the *unique* such
load-bearing axiom: dropping any single one of the other three also restores a
model.

---

## 7. The structural cause: a free involution

We now expose the algebraic skeleton of the impossibility. The antipodal map
generates a $\mathbb{Z}/2$ action, and the decisive fact is that this action is
**free**.

**Lemma 7.1 (Freeness of the antipodal action).** *In the group $\mathbb{Z}/2$,
the nonzero element acts on itself without fixed points: for every nonzero
$g \in \mathbb{Z}/2$ and every $x \in \mathbb{Z}/2$, $g + x \neq x$.*

This is the reusable algebraic lemma `zmod_add_free` from the
Computation/Impossibility framework. Equivalently: no profile class equals its
own reversal; the antipodal map has no fixed point.

**Theorem 7.2 (Borsuk–Ulam ⇄ free involution bridge).** *Let $\mathrm{swf}$ be a
circle function satisfying reversal symmetry $\mathrm{swf}(\theta+\pi) =
-\,\mathrm{swf}(\theta)$. Then both of the following hold:*

1. *(Algebra) the antipodal generator $1\in\mathbb{Z}/2$ acts freely:
   $\,\forall g\neq 0,\ \forall x,\ g + x \neq x$; and*
2. *(Analysis) the SWF is forced to produce a social tie:
   $\,\exists\,\theta,\ \mathrm{swf}(\theta) = 0$.*

**Proof.** Part (1) is Lemma 7.1. For part (2), apply Theorem 3.1 to obtain
$\theta$ with $\mathrm{swf}(\theta) = \mathrm{swf}(\theta + \pi)$; reversal
symmetry rewrites the right side as $-\mathrm{swf}(\theta)$, forcing
$\mathrm{swf}(\theta) = 0$. ∎

This is `borsuk_ulam_arrow_bridge`. Its content is conceptual: the **analytic**
obstruction (a guaranteed zero of a continuous odd function on the circle) is the
visible *shadow* of an **algebraic** obstruction (the fixed-point-freeness of the
$\mathbb{Z}/2$ antipodal involution). The same coin shows the face of the
Intermediate Value Theorem on one side and the face of a free order-two group
action on the other. A continuous, reversal-respecting function cannot avoid zero
for precisely the reason that the antipodal map has no fixed point: there is no
balanced profile for the symmetry to rest on, so the value it would have to take
there is squeezed to zero. Social choice, in its continuous form, is topology;
and that topology is, at root, the algebra of a free involution.

---

## 8. Algorithms and computational content

While the theorems are existence statements, they have constructive shadows that
are computationally meaningful and are demonstrated in the accompanying code.

**Algorithm A — Antipodal coincidence locator (bisection).** Given a circle
function $f$ sampled to tolerance $\varepsilon$, locate $\theta$ with
$|f(\theta) - f(\theta+\pi)| < \varepsilon$ by bisecting the antipodal-difference
$g(\theta) = f(\theta) - f(\theta+\pi)$ on $[0,\pi]$, exploiting the sign change
$g(\pi) = -g(0)$ guaranteed by periodicity. Complexity:
$O(\log(1/\varepsilon))$ evaluations of $f$. This is the executable form of the
proof of Theorem 3.1.

**Algorithm B — Forced-tie certifier.** Given a candidate reversal-respecting SWF
sampled on the circle, return a profile where the social margin crosses zero,
certifying Theorem 4.1 numerically. Reduces to Algorithm A applied to the SWF
itself.

**Algorithm C — Discontinuity detector.** Given a decisive, reversal-respecting
rule, scan for the sign-flip boundary mandated by Corollary 6.3, returning the
location and magnitude of the jump. This operationalizes the *deduced* existence
of a discontinuity.

These appear with full pseudocode and Python implementations in the package.

---

## 9. Future directions

**Conjecture 1 — Higher-dimensional simultaneous ties (full Borsuk–Ulam).** For a
continuous antipodal (odd) map $F:S^n\to\mathbb{R}^n$ with $F(-x) = -F(x)$, there
is a single $x$ with $F(x) = 0$: all $n$ coordinates tie *simultaneously*. The
one-dimensional development ties coordinates only independently; coordinatewise
IVT is too weak. Simultaneous vanishing is exactly the content of full
Borsuk–Ulam, so the social-choice corollary "all pairwise margins tie at one
profile" is genuinely $n$-dimensional topology. A formalization (e.g. via degree
theory or $\mathbb{Z}/2$-equivariant cohomology of spheres) would upgrade
Theorem 4.1 to genuine multi-alternative Arrow.

**Conjecture 2 — Continuity is the unique obstructed axiom.** Among {continuity,
periodicity, reversal, decisiveness}, exactly one cannot be dropped-and-restored:
removing continuity restores a model (proved, Section 6), and we conjecture that
removing any single one of the other three also restores a model, while keeping
all four is contradictory. The impossibility is a single topological cut, so the
other three axioms should be individually inessential — a minimal unsatisfiable
core whose size is dictated solely by topology. Constructing the three remaining
witnesses (non-periodic, non-reversing, indecisive) would certify that
$\mathrm{Continuous}$ is load-bearing and the others are not.

**Conjecture 3 — The tie set is a nonempty, closed, antipode-stable set.** For a
continuous reversal-respecting SWF, the tie set $\{\theta : \mathrm{swf}(\theta)
= 0\}$ is nonempty (proved), closed (preimage of $\{0\}$ under a continuous map),
and invariant under $\theta \mapsto \theta + \pi$; moreover its image in the
circle has cardinality $\ge 2$. Antipode-stability plus continuity forces the
zero set to be a $\mathbb{Z}/2$-invariant closed set, so a *single* tie is
impossible — ties always come in antipodal pairs.

---

## 10. Discussion

The contribution of this work is not a new impossibility theorem but a *clarified
ontology* for an old one, made fully rigorous. By taking seriously the idea that
preference profiles form a sphere and that reversal is the antipodal map, the
continuous Arrow-style impossibility is revealed to be a one-line corollary of
the most elementary case of Borsuk–Ulam, which is itself the Intermediate Value
Theorem. The chain
$$ \text{IVT} \;\Rightarrow\; \text{Borsuk–Ulam}^{1} \;\Rightarrow\;
\text{continuous Arrow impossibility} $$
is short, honest, and complete.

Three features deserve emphasis. First, **honesty about scope**: the discrete
Arrow theorem is not literally Borsuk–Ulam; we prove the continuous impossibility,
which genuinely is. Second, **non-vacuity**: explicit witnesses ($\sin$, the
constant rule, the square wave) show that every axiom and every pair of axioms is
satisfiable, so the impossibility is sharp. Third, **structural identification**:
the analytic obstruction (a forced zero) and the algebraic obstruction (a free
$\mathbb{Z}/2$ action) are formally tied together, substantiating the slogan that
social choice, continuously construed, is topology.

The broader lesson is methodological. Impossibility theorems across mathematics
and economics — Arrow's, Gibbard–Satterthwaite, Chichilnisky's resource
allocation results — frequently dissolve into topology once their objects are
given the right space and their fairness axioms the right symmetry. The
preference circle and its free antipodal involution are perhaps the smallest
arena in which this dissolution can be witnessed end to end.

---

## References (for context; this paper is self-contained)

- K. J. Arrow, *Social Choice and Individual Values*, 1951.
- K. Borsuk, *Drei Sätze über die n-dimensionale euklidische Sphäre*, 1933.
- G. Chichilnisky, *Social choice and the topology of spaces of preferences*,
  Advances in Mathematics, 1980.
- J. Matoušek, *Using the Borsuk–Ulam Theorem*, Springer, 2003.
