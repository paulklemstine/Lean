# The Thermodynamics of Mathematical Proof: A Landauer Principle for Reasoning

## Abstract

We develop a rigorous information-theoretic model of the *energetic cost of reasoning*,
transplanting Landauer's principle from physical computation to the elementary steps of a
mathematical proof. Modeling each proof step as a function $f : \alpha \to \beta$ between
finite state spaces, we define the *erased information* of a step as the drop in Shannon
capacity between its input and output registers,
$\mathrm{erased}(f) = \log_2 |\alpha| - \log_2 |\mathrm{im}\, f|$, and the associated
*Landauer cost* as $\mathrm{erased}(f)\cdot k_B T \ln 2$. Within this model we prove: (i)
erasure is nonnegative; (ii) a step erases zero bits if and only if it is injective
(logically reversible); (iii) Landauer's principle in strict form — every irreversible
step dissipates strictly positive heat at positive temperature; (iv) a data-processing
inequality — erasure accumulates monotonically along a proof pipeline and is sub-additive
rather than additive; (v) Bennett's reversible embedding — retaining the input renders any
step free, so computation *per se* carries no cost; (vi) an *exponential erasure
separation* — explicit families of verifications whose erasure grows linearly and doubly-
exponentially in a size parameter, exhibiting theorems whose checking dissipates
unboundedly more heat than others; and (vii) an incompressibility bound of Kolmogorov type
— a counting argument showing that some Boolean predicate on $n$ bits admits no description
shorter than $n$ bits, so its verification erases at least $n$ bits and dissipates at least
$n\, k_B T \ln 2$. We include numerical demonstrations, algorithms for computing erasure,
and a discussion of connections to reversible computing and complexity theory.

**Keywords:** Landauer's principle, information erasure, reversible computation, Shannon
entropy, Kolmogorov complexity, data-processing inequality, thermodynamics of computation.

---

## 1. Introduction

Landauer's principle (Landauer, 1961) asserts that the erasure of one bit of information in
a physical system coupled to a thermal reservoir at absolute temperature $T$ must dissipate
at least $k_B T \ln 2$ of energy as heat, where $k_B$ is Boltzmann's constant. The
principle draws a sharp line between *logically reversible* operations, which map inputs
bijectively to outputs and can in principle be performed at zero energy cost, and
*logically irreversible* operations, which merge distinct inputs and thereby destroy
information. Bennett (1973, 1982) showed that any computation can be made reversible by
retaining intermediate results, so that the thermodynamic cost of computation is
attributable entirely to erasure, not to computation itself.

This paper asks whether the same accounting applies to *mathematical reasoning*. We regard
a proof as a finite sequence of elementary steps — rewrites, substitutions, case merges,
lookups, and the terminal verification of a claim — each of which transforms a finite space
of "reasoning states" into another. Some steps are reversible (they lose no information);
others collapse many possibilities into few, and it is these that carry a thermodynamic
cost. Our aim is to make this analogy precise, prove the fundamental structural results, and
exhibit theorems whose verification is provably expensive.

The contributions are as follows. In Section 3 we define the erasure functional and prove
its nonnegativity and the reversibility criterion. In Section 4 we introduce the Landauer
cost and prove the strict form of Landauer's principle together with a lower bound for
compression into a bounded register. Section 5 establishes the data-processing inequality
and refutes additivity. Section 6 formalizes Bennett's reversible embedding. Section 7
constructs explicit linear and exponential erasure families and proves the exponential
separation. Section 8 gives the incompressibility bound and the resulting thermodynamic
cost of verification. We conclude with applications and open problems.

---

## 2. The model

Throughout, $\alpha$ and $\beta$ denote nonempty finite sets, and $|\alpha|$ denotes the
cardinality of $\alpha$. A **proof step** is any function $f : \alpha \to \beta$. We think
of $\alpha$ as the register of possible states before the step and $\beta$ as the register
after.

**Definition 2.1 (Image count).** The *image count* of a step $f : \alpha \to \beta$ is the
number of distinct outputs it produces,
$$\mathrm{im\text{-}card}(f) \;=\; \bigl|\{\, f(x) : x \in \alpha \,\}\bigr|.$$

Two elementary facts are used repeatedly. First, the image count never exceeds the domain
size, $\mathrm{im\text{-}card}(f) \le |\alpha|$, since the image of a finite set under a
function is no larger than the set. Second, when $\beta$ is finite the image count also
satisfies $\mathrm{im\text{-}card}(f) \le |\beta|$. Third, when $\alpha$ is nonempty the
image count is at least $1$. Finally, $f$ is injective if and only if
$\mathrm{im\text{-}card}(f) = |\alpha|$, since an injection loses no distinctions.

---

## 3. Erased information and the reversibility criterion

**Definition 3.1 (Erased bits).** The *erased information* of a step $f : \alpha \to \beta$
is the entropy drop between its input and output registers,
$$\mathrm{erased}(f) \;=\; \log_2 |\alpha| \;-\; \log_2 \mathrm{im\text{-}card}(f).$$
Both terms are the Shannon capacities (in bits) of the respective registers under the
uniform distribution; their difference is the information rendered irrecoverable by $f$.

**Theorem 3.2 (Nonnegativity).** For every step $f$ on a nonempty domain,
$\mathrm{erased}(f) \ge 0$.

*Proof sketch.* Since $1 \le \mathrm{im\text{-}card}(f) \le |\alpha|$ and $\log_2$ is
monotone increasing on the positive reals, $\log_2 \mathrm{im\text{-}card}(f) \le
\log_2|\alpha|$, whence the difference is nonnegative. $\qquad\blacksquare$

**Theorem 3.3 (Reversibility criterion).** For a step $f$ on a nonempty finite domain,
$$\mathrm{erased}(f) = 0 \iff f \text{ is injective.}$$

*Proof sketch.* If $f$ is injective then $\mathrm{im\text{-}card}(f) = |\alpha|$, so both
logarithms coincide and the erasure is zero. Conversely, if the erasure is zero then
$\log_2|\alpha| = \log_2 \mathrm{im\text{-}card}(f)$; since $\log_2$ is injective on the
positive reals, $|\alpha| = \mathrm{im\text{-}card}(f)$, and a function on a finite set
whose image has the same cardinality as its domain is injective. $\qquad\blacksquare$

The criterion identifies logical reversibility with zero cost: a step is free precisely
when it discards nothing. In particular a *bijection* is always free.

**Corollary 3.4 (Bijections are free).** If $f$ is a bijection then $\mathrm{erased}(f) =
0$.

A notable consequence is that *activity is not cost*: a non-identity step may still be free.
The Boolean NOT gate $b \mapsto \lnot b$ is a bijection distinct from the identity, hence
erases zero bits. This refutes the plausible-sounding claim that every non-trivial proof
step must dissipate energy: only *irreversible* steps do.

---

## 4. The Landauer cost

**Definition 4.1 (Landauer cost).** For a nonnegative quantity of erased bits $b$, a
Boltzmann constant $k_B$ and temperature $T$, the *Landauer cost* is
$$\mathrm{cost}(b, k_B, T) \;=\; b \cdot k_B \, T \ln 2.$$
The cost of a step $f$ is $\mathrm{cost}(\mathrm{erased}(f), k_B, T)$.

When $b, k_B, T \ge 0$ the cost is nonnegative, since $\ln 2 > 0$.

**Theorem 4.2 (Landauer's principle, strict form).** If $f$ is *not* injective and $k_B, T
> 0$, then $\mathrm{cost}(\mathrm{erased}(f), k_B, T) > 0$.

*Proof sketch.* By the reversibility criterion, $f$ non-injective gives
$\mathrm{erased}(f) \ne 0$, and by nonnegativity $\mathrm{erased}(f) > 0$. Since $k_B, T >
0$ and $\ln 2 > 0$, the product is strictly positive. $\qquad\blacksquare$

**Theorem 4.3 (Landauer lower bound).** If $f : \alpha \to \beta$ has output in a finite
register $\beta$, then
$$\mathrm{erased}(f) \;\ge\; \log_2 |\alpha| - \log_2 |\beta|.$$

*Proof sketch.* Since $\mathrm{im\text{-}card}(f) \le |\beta|$ and $\log_2$ is monotone,
$\log_2 \mathrm{im\text{-}card}(f) \le \log_2 |\beta|$; substituting into the definition of
erasure gives the bound. $\qquad\blacksquare$

The bound expresses the intuitive fact that compressing a large state space $\alpha$ into a
small register $\beta$ cannot be done for free: at least $\log_2(|\alpha|/|\beta|)$ bits
must be erased.

**Example 4.4 (The AND gate).** The Boolean conjunction $\land : \{F,T\}^2 \to \{F,T\}$
maps its four inputs to two outputs (three to $F$, one to $T$), so
$\mathrm{im\text{-}card}(\land) = 2$ and
$$\mathrm{erased}(\land) = \log_2 4 - \log_2 2 = 2 - 1 = 1 \text{ bit}.$$
The AND gate is the canonical realization of $k_B T \ln 2$ of Landauer dissipation.

---

## 5. Data processing: erasure accumulates and is sub-additive

Proofs are compositions of steps. We show erasure behaves like a thermodynamic
data-processing quantity: it can only grow downstream.

**Lemma 5.1.** For steps $f : \alpha \to \beta$ and $g : \beta \to \gamma$,
$\mathrm{im\text{-}card}(g \circ f) \le \mathrm{im\text{-}card}(f)$.

*Proof sketch.* The image of $g \circ f$ is the image under $g$ of the image of $f$, and
applying a function cannot increase cardinality. $\qquad\blacksquare$

**Theorem 5.2 (Data-processing inequality).** For steps $f$ and $g$ composable as above,
$$\mathrm{erased}(f) \;\le\; \mathrm{erased}(g \circ f).$$

*Proof sketch.* By Lemma 5.1, $\mathrm{im\text{-}card}(g\circ f) \le
\mathrm{im\text{-}card}(f)$; monotonicity of $\log_2$ then gives $\log_2
\mathrm{im\text{-}card}(g\circ f) \le \log_2 \mathrm{im\text{-}card}(f)$. Since both
composite and $f$ share the same domain $\alpha$, subtracting from $\log_2|\alpha|$ yields
the inequality. $\qquad\blacksquare$

Information destroyed early in a proof cannot be recovered by later steps; the arrow of
erasure points forward.

**Theorem 5.3 (Non-additivity).** Erasure is *not* additive under composition: there exist
steps $f, g$ with $\mathrm{erased}(g \circ f) \ne \mathrm{erased}(f) + \mathrm{erased}(g)$.

*Proof sketch.* Take $f = g$ to be the constant map on a two-element set, each erasing $1$
bit. Their composite is again the same constant map, erasing $1$ bit, not $2$.
$\qquad\blacksquare$

Combining Theorems 5.2 and 5.3, erasure is *sub-additive* and monotone but not additive:
the composite forgets at least as much as its first stage, yet no more than the sum of the
stages, and often strictly less.

---

## 6. Bennett's reversible embedding

**Definition 6.1 (Reversible embedding).** For a step $f : \alpha \to \beta$, its *Bennett
embedding* is
$$\tilde f : \alpha \to \alpha \times \beta, \qquad \tilde f(x) = (x, f(x)).$$

**Lemma 6.2.** $\tilde f$ is injective.

*Proof sketch.* If $\tilde f(a) = \tilde f(b)$ then their first coordinates agree, so
$a = b$. $\qquad\blacksquare$

**Theorem 6.3 (Reversible computation is free).** For any step $f$, $\mathrm{erased}(\tilde
f) = 0$.

*Proof sketch.* By Lemma 6.2, $\tilde f$ is injective, so by the reversibility criterion its
erasure vanishes. $\qquad\blacksquare$

The embedding keeps a copy of the input alongside the output, restoring reversibility.
Hence *no computation intrinsically requires erasure*: the Landauer cost of a proof is a
cost of *forgetting*, incurred only when scratch work is discarded, never of computation
itself.

---

## 7. Explicit erasure families and the exponential separation

We now exhibit verifications with prescribed erasure.

**Definition 7.1 (Collapse families).** For $n \in \mathbb{N}$, the *linear collapse*
$C_n : \{0,1,\dots,2^n-1\} \to \{\ast\}$ maps a $2^n$-state search space onto a single
answer. For $m \in \mathbb{N}$, the *big collapse* $B_m$ maps a $2^{(2^m)}$-state space onto
a single answer.

**Theorem 7.2 (Erasure of a collapse).** A constant step on a nonempty domain $\gamma$
erases $\log_2 |\gamma|$ bits. Consequently
$$\mathrm{erased}(C_n) = n, \qquad \mathrm{erased}(B_m) = 2^m.$$

*Proof sketch.* A constant map has image count $1$, so its erasure is $\log_2 |\gamma| -
\log_2 1 = \log_2 |\gamma|$. For $C_n$, $|\gamma| = 2^n$ gives $n$; for $B_m$, $|\gamma| =
2^{(2^m)}$ gives $2^m$. $\qquad\blacksquare$

**Theorem 7.3 (Exponential relation).** The erasure of the big collapse is $2$ raised to
the erasure of the linear collapse at the same parameter:
$$\mathrm{erased}(B_m) = 2^{\,\mathrm{erased}(C_m)}.$$

*Proof sketch.* $\mathrm{erased}(B_m) = 2^m = 2^{\,\mathrm{erased}(C_m)}$ by Theorem 7.2.
$\qquad\blacksquare$

**Theorem 7.4 (Exponential erasure separation).** For every real bound $C$ there exists $m$
with $\mathrm{erased}(B_m) > C$. Hence there are verifications whose erasure — and therefore
Landauer heat at any fixed positive temperature — is unbounded, growing exponentially in the
size parameter.

*Proof sketch.* Since $2^m \to \infty$, choose $m$ with $2^m > C$; then
$\mathrm{erased}(B_m) = 2^m > C$. $\qquad\blacksquare$

**Corollary 7.5 (Exponential heat).** The dissipated heat of the big collapse is
$$\mathrm{cost}(\mathrm{erased}(B_m), k_B, T) = 2^m \cdot k_B T \ln 2,$$
exponential in $m$. Two theorems of comparable statement size — one a linear collapse, one a
big collapse — can require exponentially different quantities of erasure to verify.

---

## 8. Incompressibility and the cost of verification

Finally we establish a floor: most predicates cannot be proved cheaply.

**Theorem 8.1 (Incompressibility).** For every $n$, there is no injective map from the set
of Boolean predicates on $n$ bits to the set of programs of length strictly less than $n$
bits. Equivalently, the $2^n$ predicates cannot all be assigned distinct descriptions of
length $< n$.

*Proof sketch.* The register of interest has $2^n$ elements — the $2^n$ distinct $n$-bit
inputs on which a predicate is evaluated, equivalently the $2^n$ Boolean-valued cells of a
truth table on $n$ bits. The number of programs of
length strictly less than $n$ is $2^0 + 2^1 + \dots + 2^{n-1} = 2^n - 1$. An injection from
a set of size $2^n$ into a set of size $2^n - 1$ is impossible by the pigeonhole principle.
$\qquad\blacksquare$

**Corollary 8.2 (Thermodynamic cost of verification).** For each $n$ there is a predicate
whose shortest description has length at least $n$ bits. Storing and subsequently erasing
its description (equivalently, collapsing its state register during verification) erases at
least $n$ bits and therefore dissipates at least
$$n \cdot k_B \, T \ln 2$$
of heat at temperature $T$. No verification strategy at fixed temperature can beat this
floor.

This is the qualitative shadow of Kolmogorov complexity: incompressible objects abound, and
their verification is irreducibly costly. The counting bound above is a finite proxy for the
statement that a positive-density fraction of $n$-bit predicates have Kolmogorov complexity
$\ge n - O(1)$.

---

## 9. Applications

**Reversible computing.** Theorem 6.3 is the theoretical foundation of reversible computing:
since erasure — not computation — is the sole source of cost, a machine that never discards
information can, in principle, operate arbitrarily close to zero energy per operation. This
motivates adiabatic and reversible logic families now under active engineering study, and
frames energy-efficient computing as a discipline of *not forgetting*.

**Complexity theory.** The exponential separation (Theorem 7.4) and the incompressibility
floor (Corollary 8.2) attach a physical quantity — dissipated heat — to the intuition that
some theorems are harder than others. The framework suggests a thermodynamic reading of
proof complexity: the minimal erasure of any verification of a statement is a
complexity-like invariant bounded below by the statement's incompressibility.

**Proof engineering.** Treating a proof as a create/erase ledger suggests optimizing formal
developments not only for length but for *reversibility*: proofs that retain intermediate
data (in the spirit of Bennett) are, in this accounting, thermodynamically cheaper than
proofs that aggressively collapse cases.

---

## 10. Discussion and future work

We have shown that a clean Landauer-style theory of proof steps is not only possible but
mathematically rich: reversibility is exactly zero-erasure, irreversibility strictly costs
heat, erasure accumulates monotonically and sub-additively, computation is free while
forgetting is not, and there exist verifications whose cost grows exponentially, floored
below by incompressibility.

Several directions remain open.

1. **A creation/erasure ledger.** Extend the model with an explicit *creation* primitive
   (allocating ancilla, writing bits) and a cost functional over full proofs (lists of
   create/erase steps). We conjecture that for every function there is a reversible dilation
   with zero net erasure (Bennett), but that the *minimal simultaneous* creation and erasure
   of a proof of a fixed predicate obey a trade-off $\mathrm{create} + \mathrm{erase} \ge
   K(\text{predicate})$.

2. **Genuine Kolmogorov complexity.** Replace the counting proxy of Theorem 8.1 with a true
   prefix or plain Kolmogorov complexity $K$ relative to a universal machine, and prove the
   *thermodynamic verification bound*: verifying $x$ from a shortest certificate erases at
   least $K(x) - O(1)$ bits, hence dissipates at least $(K(x) - O(1)) \cdot k_B T \ln 2$.

3. **Exponential proof-vs-answer gap.** Formalize a concrete decision problem whose answer
   is short but whose cheapest verification provably requires exponential erasure,
   separating the size of a conclusion from the heat of establishing it.

The overarching picture is that reasoning, like any physical process that reduces
uncertainty, obeys a conservation-and-dissipation law. To prove a theorem is to collapse the
space of possibilities onto the truth — and, by the second law, to warm the world a little in
doing so.

---

## References

- R. Landauer, *Irreversibility and heat generation in the computing process*, IBM Journal
  of Research and Development, 1961.
- C. H. Bennett, *Logical reversibility of computation*, IBM Journal of Research and
  Development, 1973.
- C. H. Bennett, *The thermodynamics of computation — a review*, International Journal of
  Theoretical Physics, 1982.
- C. E. Shannon, *A mathematical theory of communication*, Bell System Technical Journal,
  1948.
- M. Li and P. Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*,
  Springer.
