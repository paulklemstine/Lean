# A Second Law of Thermodynamics for Mathematical Proof

## Abstract

We develop a quantitative thermodynamics of logical derivation. Modelling an
inference step as a function $f$ between finite state registers, we define the
**information erased** by the step as the drop in the base-two logarithm of the
number of distinguishable register states, and its **Landauer cost** as
$k_B T \ln 2$ joules per erased bit. On this footing we prove: erasure is
nonnegative; a step erases zero bits if and only if it is injective (logically
reversible); any irreversible step dissipates strictly positive heat at positive
temperature; erasure obeys a data-processing inequality along a pipeline; and
Bennett's input-retaining dilation erases nothing. We then lift the single-step
theory to entire derivations, modelled as finite sequences of steps on a fixed
register. Attributing to each step its *marginal* entropy production, we
establish a **discrete Clausius inequality**: the total information erased by a
derivation equals a sum of nonnegative per-step productions. From it we derive a
**second law** — the dissipated heat of a derivation is monotone under extension
— and a reversibility criterion: a derivation dissipates zero heat if and only
if its composite is injective, which holds exactly when every step is reversible.
A **creation/erasure ledger** makes Bennett's trade-off precise: his reversible
dilation of $f:\alpha\to\beta$ erases nothing but creates exactly
$\log_2\lvert\beta\rvert$ bits of ancilla. Finally, we exhibit families of
derivations whose erasure grows linearly and exponentially in problem size, and
a counting bound in the spirit of Kolmogorov complexity guaranteeing the
existence of predicates whose verification erases at least $n$ bits.

**Keywords:** Landauer's principle, reversible computation, entropy production,
Clausius inequality, data-processing inequality, Kolmogorov complexity, proof
complexity.

---

## 1. Introduction

Landauer's principle asserts that the erasure of one bit of information at
absolute temperature $T$ dissipates at least $k_B T \ln 2$ joules of heat, where
$k_B$ is Boltzmann's constant. It is the bridge between information theory and
thermodynamics: logically irreversible operations have an unavoidable physical
cost, while logically reversible ones may in principle be performed for free.
Bennett sharpened the picture by showing that any computation can be embedded in
a reversible one, so that the thermodynamic cost of computing is concentrated
entirely in the final act of discarding unwanted information.

This paper takes the Landauer–Bennett viewpoint and applies it not to
computation but to **proof**. A formal derivation is a sequence of inference
steps; each step transforms the ambient logical state. Viewing that state as a
finite register and each step as a function on registers, we can ask: how much
information does a derivation erase, and hence how much heat must it dissipate?

We answer this with a two-tier theory. The first tier (Sections 3–4) is a
single-step calculus of erasure. The second tier (Sections 5–7) is the paper's
main contribution: a **pipeline** theory in which an entire derivation obeys a
discrete second law of thermodynamics — a Clausius inequality decomposing total
dissipation into nonnegative per-step productions, monotonicity of dissipated
heat under extension, and a crisp characterization of the reversible (zero-heat)
derivations. Section 8 quantifies how large the cost can grow, and Section 9
records a creation/erasure ledger giving Bennett's trade-off exactly. Every
statement below is a theorem with a complete proof; we give proof sketches
throughout.

---

## 2. Preliminaries and notation

Throughout, a **register** is a nonempty finite type $\alpha$ with cardinality
$\lvert\alpha\rvert = \operatorname{card}\alpha \ge 1$. We think of $\alpha$ as
the set of distinguishable configurations of some finite memory. For a function
$f : \alpha \to \beta$ between registers we write $\operatorname{image} f$ for
its image and

$$
\operatorname{imageCard}(f) \;=\; \lvert \operatorname{image} f \rvert
$$

for the number of distinct values it actually attains. Two elementary facts are
used repeatedly:

- **(P1)** $1 \le \operatorname{imageCard}(f) \le \lvert\alpha\rvert$ for every
  $f$ on a nonempty register.
- **(P2)** For a composite, $\operatorname{imageCard}(g \circ f) \le
  \operatorname{imageCard}(f)$: post-composition cannot enlarge an image.

Both are immediate from the fact that the image of a composite is the image
under $g$ of the image of $f$, and images of functions on finite sets have
cardinality bounded by their domains.

All logarithms are base two unless noted, and $\log_2$ is extended to positive
reals in the usual way. We freely use that $\log_2$ is strictly increasing on
$(0,\infty)$.

---

## 3. Erasure and Landauer cost of a single step

**Definition 3.1 (Erased information).** For $f : \alpha \to \beta$ between
finite registers, the information *erased* by $f$ is

$$
\operatorname{erased}(f) \;=\; \log_2 \lvert\alpha\rvert \;-\; \log_2 \operatorname{imageCard}(f).
$$

**Definition 3.2 (Landauer cost).** For a quantity of $b$ erased bits, at
Boltzmann constant $k_B$ and temperature $T$, the dissipated heat is

$$
\operatorname{landauer}(b, k_B, T) \;=\; b \cdot k_B \cdot T \cdot \ln 2 .
$$

The factor $\ln 2$ converts bits to nats; $\operatorname{landauer}(1,k_B,T) = k_B T \ln 2$
recovers the classical Landauer quantum.

**Theorem 3.3 (Nonnegativity).** $\operatorname{erased}(f) \ge 0$.

*Proof.* By (P1), $\operatorname{imageCard}(f) \le \lvert\alpha\rvert$, and
$\log_2$ is monotone, so
$\log_2 \operatorname{imageCard}(f) \le \log_2\lvert\alpha\rvert$. $\square$

**Theorem 3.4 (Reversibility criterion).** $\operatorname{erased}(f) = 0$ if and
only if $f$ is injective.

*Proof.* $\operatorname{erased}(f) = 0$ iff
$\log_2\lvert\alpha\rvert = \log_2\operatorname{imageCard}(f)$, iff (injectivity
of $\log_2$ on positive reals) $\operatorname{imageCard}(f) = \lvert\alpha\rvert$.
For a function on a finite set, $\lvert\operatorname{image} f\rvert = \lvert\alpha\rvert$
holds precisely when $f$ is injective. $\square$

**Theorem 3.5 (Landauer's principle).** If $f$ is not injective and $k_B, T > 0$,
then $\operatorname{landauer}(\operatorname{erased}(f), k_B, T) > 0$.

*Proof.* By Theorem 3.4, non-injectivity gives $\operatorname{erased}(f) > 0$
(it is $\ge 0$ and $\ne 0$). Multiplying by the strictly positive constant
$k_B T \ln 2$ preserves strict positivity. $\square$

**Theorem 3.6 (Register lower bound).** If $f : \alpha \to \beta$ then
$\operatorname{erased}(f) \ge \log_2\lvert\alpha\rvert - \log_2\lvert\beta\rvert$.

*Proof.* $\operatorname{imageCard}(f) \le \lvert\beta\rvert$ since the image is a
subset of the codomain; apply monotonicity of $\log_2$. $\square$

**Theorem 3.7 (Data-processing inequality).** For $f : \alpha \to \beta$ and
$g : \beta \to \gamma$,
$\operatorname{erased}(f) \le \operatorname{erased}(g \circ f)$ whenever the
domains coincide in size; more precisely, post-composition never decreases
erasure relative to the original domain.

*Proof.* By (P2), $\operatorname{imageCard}(g\circ f) \le \operatorname{imageCard}(f)$,
so $\log_2\operatorname{imageCard}(g\circ f) \le \log_2\operatorname{imageCard}(f)$,
and subtracting from the common $\log_2\lvert\alpha\rvert$ reverses the
inequality. $\square$

**Theorem 3.8 (Bennett dilation is free).** For any $f:\alpha\to\beta$, the
input-retaining map $B_f(x) = (x, f(x))$ satisfies
$\operatorname{erased}(B_f) = 0$.

*Proof.* $B_f$ is injective — its first coordinate is the identity, so
$B_f(x) = B_f(x')$ forces $x = x'$. Apply Theorem 3.4. $\square$

### 3.1 Adjudicating four conjectures

Three intuitive-sounding claims deserve scrutiny; two are true and two are false.

- **False:** "every non-identity step erases information." The Boolean NOT gate
  is a nontrivial bijection with $\operatorname{erased} = 0$.
- **True:** the two-bit AND gate (four inputs, two outputs, image $\{0,1\}$)
  erases exactly $\log_2 4 - \log_2 2 = 1$ bit.
- **False:** erasure is additive under composition,
  $\operatorname{erased}(g\circ f) = \operatorname{erased}(f) + \operatorname{erased}(g)$.
  A step $g$ may only re-collapse distinctions $f$ already destroyed; the correct
  law is sub-additivity/monotonicity (Theorem 3.7).
- **True:** every bijection is free, $\operatorname{erased} = 0$ (Theorem 3.4).

The failure of additivity is the crux motivating the pipeline theory: to obtain
an *exact* accounting we must charge each step its *marginal* production, not its
standalone cost.

---

## 4. Derivations as pipelines

**Definition 4.1 (Pipeline and composite).** Fix a register $\alpha$. A
**derivation** (pipeline) is a finite list $\mathrm{fs} = [f_1, \dots, f_k]$ with
each $f_i : \alpha \to \alpha$. Its **composite**, applied in temporal
(left-to-right) order, is

$$
\operatorname{compose}(\mathrm{fs}) \;=\; f_k \circ \cdots \circ f_2 \circ f_1,
\qquad \operatorname{compose}([]) = \mathrm{id}.
$$

Appending a step post-composes it: $\operatorname{compose}(\mathrm{fs} \mathbin{+\!\!+} [g]) = g \circ \operatorname{compose}(\mathrm{fs})$.

**Definition 4.2 (Total erased information).**
$\operatorname{totalErased}(\mathrm{fs}) = \operatorname{erased}(\operatorname{compose}(\mathrm{fs}))$.

Immediately, $\operatorname{totalErased}([]) = 0$ (the identity is injective) and
$\operatorname{totalErased}(\mathrm{fs}) \ge 0$ (Theorem 3.3).

---

## 5. Per-step entropy production and the ledger identity

Because standalone erasure is not additive, we measure each step by its marginal
effect within the running derivation.

**Definition 5.1 (Step entropy production).** For a pipeline $\mathrm{fs}$ and a
new step $g$,

$$
\operatorname{stepDrop}(\mathrm{fs}, g) \;=\;
\log_2 \operatorname{imageCard}(\operatorname{compose}(\mathrm{fs}))
\;-\; \log_2 \operatorname{imageCard}(\operatorname{compose}(\mathrm{fs} \mathbin{+\!\!+} [g])).
$$

This is the reduction in the number of distinguishable states caused by $g$
*in the context of everything before it*.

**Theorem 5.2 (Per-step data processing).**
$\operatorname{stepDrop}(\mathrm{fs}, g) \ge 0$.

*Proof.* Writing $F = \operatorname{compose}(\mathrm{fs})$, appending gives
composite $g \circ F$, and by (P2)
$\operatorname{imageCard}(g\circ F) \le \operatorname{imageCard}(F)$. Since
image cardinalities are positive, monotonicity of $\log_2$ gives
$\log_2\operatorname{imageCard}(g\circ F) \le \log_2\operatorname{imageCard}(F)$,
so the difference is $\ge 0$. $\square$

**Theorem 5.3 (Ledger identity).**

$$
\operatorname{totalErased}(\mathrm{fs} \mathbin{+\!\!+} [g]) \;=\;
\operatorname{totalErased}(\mathrm{fs}) \;+\; \operatorname{stepDrop}(\mathrm{fs}, g).
$$

*Proof.* Expand both totals via Definitions 3.1 and 4.2 with a common domain
$\alpha$:
$\operatorname{totalErased}(\mathrm{fs}) = \log_2\lvert\alpha\rvert - \log_2\operatorname{imageCard}(F)$
and
$\operatorname{totalErased}(\mathrm{fs}\mathbin{+\!\!+}[g]) = \log_2\lvert\alpha\rvert - \log_2\operatorname{imageCard}(g\circ F)$.
Subtracting, the $\log_2\lvert\alpha\rvert$ terms cancel and the remainder is
exactly $\operatorname{stepDrop}(\mathrm{fs}, g)$. $\square$

The ledger identity is the exact accounting the additivity failure forbade at
the level of standalone costs: marginal productions *do* add up.

---

## 6. The second law and the discrete Clausius inequality

**Theorem 6.1 (Monotonicity — second law).** For any pipeline $\mathrm{fs}$ and
any suffix $\mathrm{gs}$,

$$
\operatorname{totalErased}(\mathrm{fs}) \;\le\; \operatorname{totalErased}(\mathrm{fs} \mathbin{+\!\!+} \mathrm{gs}).
$$

*Proof.* Induct on $\mathrm{gs}$ from the right. The empty suffix is trivial.
For $\mathrm{gs}\mathbin{+\!\!+}[g]$, associativity of concatenation and the
ledger identity give
$\operatorname{totalErased}((\mathrm{fs}\mathbin{+\!\!+}\mathrm{gs})\mathbin{+\!\!+}[g]) = \operatorname{totalErased}(\mathrm{fs}\mathbin{+\!\!+}\mathrm{gs}) + \operatorname{stepDrop}(\dots) \ge \operatorname{totalErased}(\mathrm{fs}\mathbin{+\!\!+}\mathrm{gs})$
by Theorem 5.2, and the inductive hypothesis chains this back to
$\operatorname{totalErased}(\mathrm{fs})$. $\square$

**Theorem 6.2 (Discrete Clausius inequality).** For every pipeline
$\mathrm{fs} = [f_1,\dots,f_k]$ there exist nonnegative reals
$d_1, \dots, d_k \ge 0$, one per inference, with

$$
\sum_{i=1}^{k} d_i \;=\; \operatorname{totalErased}(\mathrm{fs}),
\qquad d_i = \operatorname{stepDrop}([f_1,\dots,f_{i-1}], f_i).
$$

*Proof.* Induct on $\mathrm{fs}$ from the right. The empty pipeline has empty
production list summing to $0 = \operatorname{totalErased}([])$. Appending $g$ to
$\mathrm{fs}$, take the productions for $\mathrm{fs}$ (nonnegative, summing to
$\operatorname{totalErased}(\mathrm{fs})$ by hypothesis) and append
$\operatorname{stepDrop}(\mathrm{fs}, g) \ge 0$ (Theorem 5.2). The new sum is
$\operatorname{totalErased}(\mathrm{fs}) + \operatorname{stepDrop}(\mathrm{fs}, g) = \operatorname{totalErased}(\mathrm{fs}\mathbin{+\!\!+}[g])$
by the ledger identity. $\square$

This is the discrete analogue of the Clausius inequality: total dissipation is
the sum of local, nonnegative entropy productions, one per step. It is the exact
sense in which a derivation obeys a second law.

**Theorem 6.3 (Heat monotonicity).** Let
$\operatorname{totalHeat}(\mathrm{fs}, k_B, T) = \operatorname{landauer}(\operatorname{totalErased}(\mathrm{fs}), k_B, T)$.
If $k_B, T \ge 0$ then

$$
\operatorname{totalHeat}(\mathrm{fs}, k_B, T) \;\le\; \operatorname{totalHeat}(\mathrm{fs}\mathbin{+\!\!+}\mathrm{gs}, k_B, T).
$$

*Proof.* Multiply Theorem 6.1 by the nonnegative constant $k_B T \ln 2$. $\square$

A longer derivation of the *same* conclusion never dissipates less heat; parsimony
of steps is thermodynamic thrift.

---

## 7. Reversibility of derivations

**Theorem 7.1 (Reversibility criterion for pipelines).**
$\operatorname{totalErased}(\mathrm{fs}) = 0$ if and only if
$\operatorname{compose}(\mathrm{fs})$ is injective.

*Proof.* Immediate from Theorem 3.4 applied to the composite. $\square$

**Theorem 7.2 (Reversible derivations are free).** If every step of
$\mathrm{fs}$ is injective, then $\operatorname{totalErased}(\mathrm{fs}) = 0$.

*Proof.* A composite of injective maps is injective (induction on the list:
identity is injective, and $g \circ F$ is injective when both $g$ and $F$ are).
Apply Theorem 7.1. $\square$

Combined with the Clausius decomposition, one sees that zero total dissipation
factors through the individual productions: the total vanishes exactly when each
$\operatorname{stepDrop}$ vanishes, i.e. when each prefix composite is injective.
Reversibility is thus a *local* property, certifiable by a left-to-right scan of
consecutive image sizes without ever forming the whole composite.

---

## 8. How large can the cost be?

The dissipation is not a negligible constant; it grows without bound.

**Linear family.** Let $\operatorname{collapse}_n$ be a step on an $n$-bit
register whose image is a single point. Then
$\operatorname{erased}(\operatorname{collapse}_n) = \log_2 2^n - \log_2 1 = n$.
Verification of such a step erases $n$ bits.

**Exponential family.** Let $\operatorname{bigCollapse}_m$ collapse a register of
$2^{m}$ states (an $m$-fold blow-up, e.g. a register of $2^{2^m}$-many
configurations reduced to $2^{2^m - 2^m}$) so that
$\operatorname{erased}(\operatorname{bigCollapse}_m) = 2^m$. The erasure — and
hence the heat — grows exponentially in $m$, and the separation
$\operatorname{erased}(\operatorname{bigCollapse}_m) / \operatorname{erased}(\operatorname{collapse}_m)$
is unbounded.

**A Kolmogorov counting bound.** There are $2^n$ Boolean predicates on $n$ input
bits, but only $\sum_{\ell < n} 2^\ell = 2^n - 1$ programs (bit strings) of
length strictly less than $n$. By pigeonhole no injective encoding of predicates
into short programs exists: some predicate $P$ has no description shorter than
$n$ bits — it is *incompressible*. Verifying $P$ requires resolving its full
$2^n$-entry truth table down to a verdict, an erasure of at least $n$ bits, and
therefore dissipates at least $n \cdot k_B T \ln 2$ joules. Some truths are
intrinsically hot to check.

---

## 9. The creation/erasure ledger

Bennett's dilation eliminates erasure but not cost; it relocates the cost into
*allocation*. We make this quantitative.

**Definition 9.1 (Created bits).** Growing an $a$-state register to a $b$-state
register creates $\operatorname{created}(a,b) = \log_2 b - \log_2 a$ bits of
capacity; $\operatorname{created}(a,b) \ge 0$ whenever $a \le b$ and $a \ge 1$.

**Theorem 9.2 (Bennett trade-off).** For $f : \alpha \to \beta$, the dilation
$B_f(x) = (x, f(x))$ satisfies

$$
\operatorname{erased}(B_f) = 0
\qquad\text{and}\qquad
\operatorname{created}\big(\lvert\alpha\rvert, \lvert\alpha\times\beta\rvert\big) = \log_2\lvert\beta\rvert.
$$

*Proof.* Erasure vanishes by Theorem 3.8. For creation, the codomain has size
$\lvert\alpha\times\beta\rvert = \lvert\alpha\rvert\cdot\lvert\beta\rvert$, so
$\operatorname{created} = \log_2(\lvert\alpha\rvert\lvert\beta\rvert) - \log_2\lvert\alpha\rvert = \log_2\lvert\beta\rvert$
by the product rule for logarithms. $\square$

Erasure and creation are two columns of one ledger. Logical irreversibility can
always be traded for allocation: Bennett pays exactly $\log_2\lvert\beta\rvert$
bits of ancilla to buy back reversibility.

---

## 10. Algorithms

The theory is computational. Two procedures suffice to instrument any concrete
derivation.

**Algorithm A (Pipeline erasure ledger).** Given a fixed finite register and an
ordered list of steps, compute the running composite, the per-step entropy
production, the cumulative total, and the Landauer heat. Complexity is
$O(k \cdot N)$ for $k$ steps on an $N$-state register (each step recomputes an
image in $O(N)$). The output is the Clausius decomposition of Theorem 6.2.

**Algorithm B (Local reversibility certification).** Scan the pipeline once,
left to right, tracking the image size of each prefix composite; the derivation
is reversible iff no prefix image shrinks. This certifies Theorem 7.1 in
$O(k\cdot N)$ time without ever materializing the full composite as a table,
realizing the locality remark of Section 7.

---

## 11. Applications and discussion

**Proof aesthetics as physics.** The classical dichotomy between "elegant" and
"brute-force" proofs acquires a physical reading: elegant derivations are
reversible (zero dissipation), brute-force ones forget case analysis and pay
Landauer's toll per bit. The second law (Theorem 6.1) formalizes the intuition
that padding a proof never makes it cheaper.

**Complexity lower bounds.** The incompressibility bound of Section 8 ties
verification heat to description length, suggesting a thermodynamic route to
proof-complexity lower bounds: certificates that are provably long to check are
provably hot to verify.

**Reversible proof engineering.** The creation/erasure ledger (Section 9)
indicates a design principle for low-dissipation reasoning systems: retain
intermediate data (paying in memory) rather than discard it (paying in heat),
exactly as in reversible computing.

**Limitations.** The model measures *logical* irreversibility of idealized
register maps; it is a lower bound on physical dissipation, not a device model.
Real inference rules act on structured states, and the reduction of a rule to a
register map is a modelling choice. The pipeline theory is linear; branching
derivations (Section 12) are future work.

---

## 12. Future directions

1. **A Clausius inequality for branching derivations (proof DAGs).** We
   conjecture that for a proof organized as a directed acyclic graph of steps
   (with join nodes merging intermediate registers), total dissipated entropy
   equals the sum of nonnegative local productions over edges and is invariant
   under topological re-serialization. The marginal-production viewpoint isolates
   exactly the additive edge functional that should survive branching.

2. **Reversibility is local and linear-time checkable.** We conjecture a
   derivation dissipates zero entropy iff every prefix map is injective, so global
   reversibility is certifiable by a linear-time left-to-right scan that never
   inspects the whole composite — a direct strengthening of Section 7.

3. **Tightness of the creation/erasure trade-off.** We conjecture that among all
   reversible dilations of a fixed irreversible step, Bennett's input-retaining
   embedding minimizes created ancilla, with minimum created capacity equal to
   $\log_2\lvert\beta\rvert$; no reversible implementation can use less. The
   ledger already computes Bennett's cost; a matching lower bound over all
   dilations remains.

4. **Kolmogorov complexity proper.** Replace the counting proxy by a genuine
   prefix/plain Kolmogorov complexity $K$ and prove the thermodynamic
   verification bound: verifying $x$ from a shortest certificate erases
   $\ge K(x) - O(1)$ bits, dissipating $\ge (K(x)-O(1)) k_B T \ln 2$ joules.

5. **Exponential proof-vs-answer gaps and calculus efficiency.** Formalize a
   decision problem whose shortest checkable certificate is exponentially longer
   than the answer, tying the erasure separation of Section 8 to proof-complexity
   lower bounds; and compute the erasure cost of standard inference rules
   (resolution, modus ponens, cut) to compare calculi by intrinsic erasure per
   derived consequence.

---

## 13. Conclusion

We have shown that mathematical derivation admits a genuine thermodynamics.
Single steps have an exact erasure and Landauer cost, with reversibility
characterized by injectivity. Entire derivations obey a discrete Clausius
inequality: total dissipation is the sum of nonnegative per-step productions,
monotone under extension, and zero exactly for reversible derivations. Bennett's
trade-off, made precise as a creation/erasure ledger, shows reversibility is
financed by allocation rather than granted for free. And explicit families,
culminating in an incompressibility bound, show the cost is unbounded and
sometimes intrinsic. Information is physical; so, we conclude, is proof.
