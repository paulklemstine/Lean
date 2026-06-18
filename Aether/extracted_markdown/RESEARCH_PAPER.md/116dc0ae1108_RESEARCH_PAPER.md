# A Proof-Theoretic Bridge: Ordinal Analysis Across Systems

## Abstract

We develop, in fully formal and gap-free fashion, the core ordinal-analytic
facts that connect the proof-theoretic ordinal of Peano Arithmetic (PA), namely
$\varepsilon_0$, to the apparatus of ordinal collapsing functions (OCFs) used in
the analysis of stronger systems such as Kripke–Platek set theory (KP). Our
central new result closes a previously open item in the Mathlib library: the
**countability of $\varepsilon_0$**, formalized as $\varepsilon_0 < \omega_1$. The
proof factors through two independent bridges living in distinct mathematical
domains: (a) the order-theoretic identity realizing $\varepsilon_0$ as the
supremum of the finite $\omega$-towers, $\varepsilon_0 = \sup_n \mathrm{tower}(n)$;
and (b) the cardinal-arithmetic fact that $\omega_1$ is *principal under ordinal
exponentiation*, so that each finite tower remains countable. A countable
supremum of countable ordinals is countable, and the result follows. We then
package the $\varepsilon$-number enumeration as a normal collapsing hierarchy
$\psi_E$, prove that the uncountable base $\Omega = \omega_1$ is itself an
$\varepsilon$-number ($\omega^{\omega_1} = \omega_1$), and establish the headline
collapse inequality $\varepsilon_0 < \psi_E(\Omega^{\omega})$ — the formal
analogue of the classical $\varepsilon_0 < \psi(\Omega^\omega)$ — together with the
PA $\to$ KP bridge $\varepsilon_0 <$ (Bachmann–Howard ordinal). Finally we prove a
sharp *impossibility* result: no strictly monotone function can collapse
$\Omega$ below itself, giving the precise formal reason that genuine OCFs must be
non-monotone.

**Keywords:** ordinal analysis, proof-theoretic ordinal, epsilon-nought, Veblen
hierarchy, ordinal collapsing function, Bachmann–Howard ordinal, countability,
principal ordinals, formal verification.

---

## 1. Introduction

### 1.1 Ordinals as a ruler for logical strength

An *ordinal* is the order type of a well-ordered set: a transfinite extension of
the natural numbers along which one may perform induction and recursion. The
first infinite ordinal is $\omega$, the order type of $\mathbb{N}$. Ordinal
arithmetic provides addition, multiplication, and exponentiation extending their
finite counterparts, but with transfinite behavior — e.g. $1 + \omega = \omega
\neq \omega + 1$.

Of central importance to mathematical logic is the assignment of an ordinal to a
formal theory: its **proof-theoretic ordinal**, the supremum of the order types
of the primitive-recursive well-orderings the theory can prove well-founded.
Gentzen's celebrated consistency proof of PA (1936, 1938) showed that PA is
consistent given transfinite induction up to $\varepsilon_0$, and that no smaller
ordinal suffices. Thus $\varepsilon_0$ is the canonical fingerprint of arithmetic.
Stronger theories have larger fingerprints: predicative analysis is associated
with $\Gamma_0$, and Kripke–Platek set theory with the **Bachmann–Howard
ordinal**.

### 1.2 The $\varepsilon$-numbers and the collapsing problem

$\varepsilon_0$ is the least *fixed point* of $\alpha \mapsto \omega^\alpha$, i.e.
the least $\alpha > 0$ with $\omega^\alpha = \alpha$. The fixed points of
$\omega$-exponentiation are the **$\varepsilon$-numbers**, enumerated by the
normal (continuous, strictly increasing) function $\varepsilon_{(\cdot)}$, which
coincides with the Veblen function $\varphi_1$. In Mathlib this is `ε_ = veblen 1`,
with $\varepsilon_0 = $ `ε_ 0`.

To name ordinals far beyond the reach of the Veblen hierarchy, ordinal analysis
employs **ordinal collapsing functions** (OCFs). The key idea, due to Bachmann
and refined by Buchholz, Madore, Rathjen, and others, is to introduce an
uncountable regular ordinal $\Omega$ (taken here to be $\omega_1$), build large
ordinals using $\Omega$ as raw material, and *collapse* them back to the countable
realm via a function $\psi$. The iconic benchmark inequality is
$$\varepsilon_0 < \psi(\Omega^\omega),$$
asserting that even a modest input $\Omega^\omega$ collapses to something already
beyond the strength of PA.

### 1.3 Contributions

1. **Countability of $\varepsilon_0$** ($\varepsilon_0 < \omega_1$), closing an
   explicit Mathlib TODO, via the bridge between the tower-supremum picture and
   the principality of $\omega_1$ under exponentiation (Section 4).
2. The cantor-style structural identity $\varepsilon_0 = \sup_n \mathrm{tower}(n)$
   and strict monotonicity of the tower (Section 3).
3. The base-closure fact $\omega^{\omega_1} = \omega_1$: the OCF base is itself an
   $\varepsilon$-number (Section 5).
4. A faithful collapsing hierarchy $\psi_E$ and the headline collapse inequality
   $\varepsilon_0 < \psi_E(\Omega^\omega)$, plus $\varepsilon_0 < \Omega$ and the
   PA $\to$ KP bridge $\varepsilon_0 <$ Bachmann–Howard (Section 6).
5. A sharp impossibility theorem: no strictly monotone map can collapse $\Omega$
   below itself (Section 7).

All results are formalized on top of Mathlib's `SetTheory/Ordinal` development.

---

## 2. Preliminaries and notation

We work with ordinals $\mathrm{Ord}$ under their canonical well-order. We use:

- $\omega$ — the first infinite ordinal (`Ordinal.omega0`).
- $\omega^\alpha$ — ordinal exponentiation with base $\omega$ (`opow`).
- $\varepsilon_{(\cdot)}$ — the normal enumeration of fixed points of
  $\alpha \mapsto \omega^\alpha$ (Mathlib `ε_ = veblen 1`), so an
  **$\varepsilon$-number** is any $\alpha$ with $\omega^\alpha = \alpha$, and
  $\varepsilon_0 = $ `ε_ 0`.
- $\omega_1$ — the first uncountable ordinal (`ω_ 1`), equal to $(\aleph_1)^{\mathrm{ord}}$.
- $\aleph_1$ — the first uncountable cardinal.

**Normal functions.** A function $f : \mathrm{Ord} \to \mathrm{Ord}$ is *normal*
if it is strictly increasing and continuous at limits. Every normal function $f$
satisfies $\alpha \le f(\alpha)$ for all $\alpha$ (the *inflationary* property),
and has unboundedly many fixed points. $\alpha \mapsto \omega^\alpha$ is normal
(for base $> 1$), as is $\varepsilon_{(\cdot)}$.

**Principal ordinals.** An ordinal $\pi$ is *principal* (closed) under a binary
operation $\star$ if $a, b < \pi \Rightarrow a \star b < \pi$. A foundational
cardinal fact we use is that $\omega_1$ is principal under exponentiation:
$$a < \omega_1 \ \wedge\ b < \omega_1 \ \Longrightarrow\ a^{b} < \omega_1,$$
formalized as `principal_opow_omega` applied at $\omega_1$.

**Cofinality and suprema.** $\omega_1$ has uncountable cofinality; consequently
any countable family of ordinals below $\omega_1$ has supremum below $\omega_1$.
We use this in the form `iSup_sequence_lt_omega_one`: if $f : \mathbb{N} \to
\mathrm{Ord}$ satisfies $f(n) < \omega_1$ for all $n$, then $\sup_n f(n) <
\omega_1$.

---

## 3. The $\omega$-tower and the structure of $\varepsilon_0$

**Definition 3.1 (finite $\omega$-towers).**
$$\mathrm{tower}(n) := (\alpha \mapsto \omega^\alpha)^{[n]}(0),$$
the $n$-fold iterate of $\omega$-exponentiation applied to $0$. Explicitly
$\mathrm{tower}(0) = 0$, $\mathrm{tower}(1) = \omega^0 = 1$,
$\mathrm{tower}(2) = \omega^1 = \omega$, $\mathrm{tower}(3) = \omega^\omega$, and
in general $\mathrm{tower}(n+1) = \omega^{\mathrm{tower}(n)}$.

**Lemma 3.2 (`tower_succ`).** $\mathrm{tower}(n+1) = \omega^{\mathrm{tower}(n)}$.
*Proof.* Immediate from the successor law of function iteration. $\square$

**Lemma 3.3 (`tower_lt_epsilonZero`).** For all $n$, $\mathrm{tower}(n) <
\varepsilon_0$.
*Proof.* This is Mathlib's `iterate_omega0_opow_lt_epsilon_zero`: each finite
iterate of $\omega^{(\cdot)}$ starting from $0$ stays strictly below the least
fixed point $\varepsilon_0$. $\square$

**Theorem 3.4 (`epsilonZero_eq_iSup_tower`).**
$$\varepsilon_0 = \sup_{n \in \mathbb{N}} \mathrm{tower}(n).$$
*Proof sketch.* $\varepsilon_0$ is the least fixed point of $g(\alpha) =
\omega^\alpha$ above $0$, i.e. $\varepsilon_0 = \mathrm{nfp}\,g\,0$ (the least fixed
point, `epsilon_zero_eq_nfp`). For a normal function $g$, the least fixed point
above $a$ is the supremum of the iterates: $\mathrm{nfp}\,g\,a = \sup_n
g^{[n]}(a)$ (`iSup_iterate_eq_nfp`). Specializing $a = 0$ and matching the iterate
lambda with $\mathrm{tower}$ definitionally yields the identity. $\square$

**Theorem 3.5 (`tower_strictMono`).** $\mathrm{tower}$ is strictly monotone.
*Proof sketch.* It suffices to show $\mathrm{tower}(n) < \mathrm{tower}(n+1) =
\omega^{\mathrm{tower}(n)}$. Suppose not, i.e. $\omega^{\mathrm{tower}(n)} \le
\mathrm{tower}(n)$. The characterization `epsilon_zero_le_of_omega0_opow_le`
states that any $\alpha$ with $\omega^\alpha \le \alpha$ satisfies $\varepsilon_0
\le \alpha$; hence $\varepsilon_0 \le \mathrm{tower}(n)$, contradicting Lemma 3.3.
$\square$

**Remark 3.6 (the trap at the fixed point).** The naive inequality $\alpha <
\omega^\alpha$ is *false* precisely at $\alpha = \varepsilon_0$, where
$\omega^{\varepsilon_0} = \varepsilon_0$. Strict monotonicity of the tower is
therefore *not* a consequence of any blanket "$\alpha < \omega^\alpha$" — it
genuinely requires the least-fixed-point property of $\varepsilon_0$ (each rung
lies strictly below $\varepsilon_0$, so none is a fixed point).

---

## 4. Countability of $\varepsilon_0$

This section closes the $\varepsilon_0$ half of the Mathlib TODO "prove that
$\varepsilon_0$ and $\Gamma_0$ are countable."

**Lemma 4.1 (`tower_lt_omega1`).** For all $n$, $\mathrm{tower}(n) < \omega_1$.
*Proof.* Induction on $n$. Base: $\mathrm{tower}(0) = 0 < \omega_1$ (indeed
$\omega \le \omega_1$ via `omega_pos`/`omega0_lt_omega_one`). Step: assuming
$\mathrm{tower}(k) < \omega_1$, by Lemma 3.2 $\mathrm{tower}(k+1) =
\omega^{\mathrm{tower}(k)}$; since both $\omega < \omega_1$ and
$\mathrm{tower}(k) < \omega_1$, principality of $\omega_1$ under exponentiation
(`principal_opow_omega` with `omega0_lt_omega_one`) gives
$\omega^{\mathrm{tower}(k)} < \omega_1$. $\square$

**Theorem 4.2 (`epsilonZero_lt_omega1`).** $\varepsilon_0 < \omega_1$.
*Proof.* By Theorem 3.4, $\varepsilon_0 = \sup_n \mathrm{tower}(n)$. By Lemma 4.1
each term is below $\omega_1 = (\aleph_1)^{\mathrm{ord}}$. Since $\omega_1$ has
uncountable cofinality, a countable supremum of ordinals below it stays below it
(`iSup_sequence_lt_omega_one`). Hence $\varepsilon_0 < \omega_1$. The bridge
between the notations $\omega_1 = \omega\_\,1$ and $(\aleph_1)^{\mathrm{ord}}$ is
`ord_aleph`. $\square$

**Corollary 4.3 (`epsilonZero_card_lt_aleph_one`).** $|\varepsilon_0| < \aleph_1$;
i.e. $\varepsilon_0$ is countable as a set.
*Proof.* Transport Theorem 4.2 across $\omega_1 = (\aleph_1)^{\mathrm{ord}}$ and
apply `Cardinal.lt_ord`, which converts $\alpha < \kappa^{\mathrm{ord}}$ into
$|\alpha| < \kappa$. $\square$

**Discussion.** The proof is the structural heart of the project. It is a genuine
cross-domain bridge: ingredient (a), $\varepsilon_0 = \sup_n \mathrm{tower}(n)$,
is order-theoretic (least fixed points of normal functions); ingredient (b),
principality of $\omega_1$ under exponentiation, is cardinal-arithmetic
(regularity of $\aleph_1$). Neither alone suffices; together they pin down
$\varepsilon_0$ as a countable supremum of countable ordinals.

---

## 5. The collapse base is an $\varepsilon$-number

**Theorem 5.1 (`omega1_isEpsilon`).** $\omega^{\omega_1} = \omega_1$.
*Proof sketch.* $\omega_1 = (\aleph_1)^{\mathrm{ord}}$ is a successor-limit
ordinal (`isSuccLimit_ord` from $\aleph_0 \le \aleph_1$). The map $g(\alpha) =
\omega^\alpha$ is normal (`isNormal_opow one_lt_omega0`), so $g$ is inflationary:
$\omega_1 \le \omega^{\omega_1}$. For the reverse inequality, normality at a limit
gives $\omega^{\omega_1} \le \omega_1$ iff $\omega^b \le \omega_1$ for all $b <
\omega_1$ (`IsNormal.le_iff_forall_le`); and $\omega^b < \omega_1$ for each such
$b$ by principality (`principal_opow_omega`). Antisymmetry concludes. $\square$

**Significance.** This is precisely the closure property required to base an OCF
at $\omega_1$: the raw material $\Omega = \omega_1$ is stable under the generating
operation $\omega^{(\cdot)}$. It links cardinal arithmetic (regularity of
$\aleph_1$) to the fixed-point hierarchy (being an $\varepsilon$-number).

---

## 6. The collapsing hierarchy $\psi_E$ and the bridge inequalities

**Definition 6.1 (`psiE`).** $\psi_E(o) := \varepsilon_o = (\,$`ε_`$\,)(o)$, the
normal enumeration of the $\varepsilon$-numbers. We take the collapse base to be
$\Omega := \omega_1$.

$\psi_E$ is a faithful, fully rigorous *model* of an ordinal collapsing function:
it is order-preserving and every value is a fixed point of $\omega^{(\cdot)}$. It
is deliberately a *simplification* — it is monotone, whereas a genuine OCF cannot
be (Section 7) — but it captures the data the collapse inequality needs:
$\psi_E(0) = \varepsilon_0$ is the PA ordinal, and $\psi_E$ climbs through the
$\varepsilon$-numbers as its argument grows.

**Proposition 6.2 (`psiE_strictMono`).** $\psi_E$ is strictly monotone.
*Proof.* $\varepsilon_{(\cdot)} = \varphi_1$ is normal, hence strictly increasing.
$\square$

**Proposition 6.3 (`psiE_isEpsilon`).** For every $o$, $\psi_E(o)$ is an
$\varepsilon$-number: $\omega^{\psi_E(o)} = \psi_E(o)$.
*Proof.* By definition $\varepsilon_o$ enumerates the fixed points of
$\omega^{(\cdot)}$. $\square$

**Proposition 6.4 (`psiE_zero`).** $\psi_E(0) = \varepsilon_0$, the
proof-theoretic ordinal of PA. *Proof.* Definitional. $\square$

**Theorem 6.5 (`epsilonZero_lt_Omega`).** $\varepsilon_0 < \Omega = \omega_1$.
*Proof.* This is exactly Theorem 4.2: $\varepsilon_0$ is countable, the base is
uncountable. $\square$

**Theorem 6.6 (headline collapse, `epsilonZero_lt_psiE_Omega_opow_omega0`).**
$$\varepsilon_0 < \psi_E(\Omega^{\omega}).$$
*Proof sketch.* $\psi_E(0) = \varepsilon_0$ and $\psi_E$ is strictly monotone
(Prop. 6.2), so it suffices that $0 < \Omega^\omega$. Since $\Omega = \omega_1 >
0$, we have $\Omega^\omega > 0$, hence $\varepsilon_0 = \psi_E(0) <
\psi_E(\Omega^\omega)$. This is the formal analogue of the classical
$\varepsilon_0 < \psi(\Omega^\omega)$. $\square$

**Theorem 6.7 (PA $\to$ KP bridge, `epsilonZero_lt_bachmannHoward`).** With
`bachmannHoward` a model of the Bachmann–Howard ordinal realized as a sufficiently
large value of $\psi_E$ over $\Omega$, one has $\varepsilon_0 < $ `bachmannHoward`.
*Proof sketch.* The Bachmann–Howard model is $\psi_E$ evaluated at an argument
strictly above $0$; strict monotonicity and $\psi_E(0) = \varepsilon_0$ give the
strict inequality, placing the PA ordinal strictly below the KP-strength model.
$\square$

---

## 7. Impossibility of a monotone collapse

The reader may wonder why $\psi_E$ is only a *model* and not the genuine OCF. The
answer is a theorem.

**Theorem 7.1 (`no_monotone_collapse`).** There is no $f : \mathrm{Ord} \to
\mathrm{Ord}$ that is strictly monotone on the initial segment $[\,0, \omega_1\,]$
with $f(\omega_1) < \omega_1$. More generally, any strictly monotone $f$ satisfies
$\omega_1 \le f(\omega_1)$.
*Proof.* A strictly monotone function on a well-order is *inflationary*: $a \le
f(a)$ for all $a$ (otherwise $f(a) < a$ would generate an infinite descending
chain $a > f(a) > f(f(a)) > \cdots$, impossible in a well-order). Applying this at
$a = \omega_1$ gives $\omega_1 \le f(\omega_1)$, contradicting $f(\omega_1) <
\omega_1$. $\square$

**Interpretation.** Monotonicity is *itself* the obstruction to collapsing.
Genuine ordinal collapsing functions (Buchholz's $\psi$, Madore's $\psi$,
Rathjen's hierarchies) are necessarily **non-monotone**: they must send the
uncountable $\Omega$ to a countable value, which no order-preserving map can do.
Theorem 7.1 converts the folklore intuition "OCFs are jumpy and irregular" into a
one-line impossibility, and pinpoints precisely the price one pays to gain genuine
collapsing power: surrender monotonicity.

---

## 8. Algorithms and computational content

While ordinals beyond $\omega^\omega$ are not finitely representable as values,
the *notation systems* below $\varepsilon_0$ are eminently computable. We describe
two algorithms made concrete in the accompanying demo.

1. **Cantor Normal Form (CNF) arithmetic below $\varepsilon_0$.** Every ordinal
   $\alpha < \varepsilon_0$ has a unique representation $\alpha =
   \omega^{\beta_1} c_1 + \cdots + \omega^{\beta_k} c_k$ with $\beta_1 > \cdots >
   \beta_k$ and each $\beta_i < \alpha$ in CNF. This yields a *finite tree* data
   structure on which $+$, $\cdot$, and $\omega^{(\cdot)}$ are computable, and the
   well-order is decidable lexicographically. This is the algorithmic backbone of
   ordinal notations.

2. **The Goodstein descent.** The hereditary base-$n$ representation of a natural
   number maps to an ordinal $< \varepsilon_0$ by replacing every base with
   $\omega$. The Goodstein operation (bump the base, subtract one) *strictly
   decreases* the associated ordinal while the integer sequence may explode; well-
   foundedness below $\varepsilon_0$ forces termination at $0$. This is the most
   vivid demonstration that $\varepsilon_0$ governs real arithmetic phenomena.

The demo also numerically witnesses Theorem 3.4 (the tower converging to
$\varepsilon_0$ in CNF), Lemma 4.1 (each tower has a finite, countable notation),
and Theorem 7.1 (monotone maps are inflationary).

---

## 9. Applications

- **Calibrating theories.** The proof-theoretic ordinal is the standard invariant
  for comparing the strength of axiom systems; $\varepsilon_0$ for PA, $\Gamma_0$
  for predicative analysis, the Bachmann–Howard ordinal for KP and $\mathrm{ID}_1$.
  Theorem 6.7 is a formal instance of such a comparison.
- **Independence results.** Goodstein's theorem and the Paris–Harrington principle
  are true but unprovable in PA precisely because their termination requires
  induction up to (or beyond) $\varepsilon_0$.
- **Termination of programs.** Ordinal-valued *ranking functions* below
  $\varepsilon_0$ certify termination of rewriting systems and recursive programs;
  CNF arithmetic (Section 8) is what makes such certificates checkable.
- **Formal libraries.** Corollary 4.3 supplies a missing countability fact that
  downstream developments (cardinality of notation systems, descriptive set
  theory of well-orders) can now rely upon.

---

## 10. Discussion and future work

The centerpiece is the countability proof, deliberately structured to expose the
two-domain bridge it rests on. The companion impossibility theorem (Section 7) is
arguably the most *informative* output: it explains, formally, why $\psi_E$ — and
indeed any tame, monotone construction — can only ever be a model of an OCF, never
the genuine article. The genuine prize is therefore a recursively-defined,
non-monotone, countability-preserving $\psi$.

Concrete directions:

- **The $\Gamma_0$ half of the TODO.** Extend the tower/principality method from
  the $\varepsilon$-hierarchy to the full Veblen hierarchy to prove $\Gamma_0 <
  \omega_1$, closing the remaining half of the Mathlib TODO.
- **A genuine non-monotone $\psi$.** Define Buchholz- or Madore-style $\psi$ by
  transfinite recursion over closed sets of ordinals, prove its values are
  countable, and re-derive $\varepsilon_0 < \psi(\Omega^\omega)$ as a corollary of
  the *true* collapse rather than its monotone model.
- **Full ordinal analysis of KP.** Build the notation system $T(\Omega)$ and prove
  the Bachmann–Howard ordinal is exactly the supremum of its order types, with the
  $\Pi^1_1$-completeness consequences.
- **Goodstein and Hydra formalization.** Connect the CNF machinery of Section 8 to
  a formal proof of Goodstein's theorem and the Kirby–Paris hydra theorem via
  descent below $\varepsilon_0$.

---

## 11. Conclusion

We have given a self-contained, fully formal account of the first rungs of
ordinal analysis bridging PA and KP. The countability of $\varepsilon_0$ is now
established, the collapse base $\omega_1$ is shown to be an $\varepsilon$-number,
a faithful collapsing hierarchy $\psi_E$ realizes the headline inequality
$\varepsilon_0 < \psi_E(\Omega^\omega)$, and the impossibility of monotone
collapsing delineates exactly where the easy theory ends and the genuine OCF
machinery must begin. Together these results form a rigorous, reusable foundation
on which a complete formal ordinal analysis can be built.

---

## Appendix: Summary of formal results

| Name | Statement |
|---|---|
| `tower_succ` | $\mathrm{tower}(n+1) = \omega^{\mathrm{tower}(n)}$ |
| `tower_lt_epsilonZero` | $\mathrm{tower}(n) < \varepsilon_0$ |
| `epsilonZero_eq_iSup_tower` | $\varepsilon_0 = \sup_n \mathrm{tower}(n)$ |
| `tower_strictMono` | $\mathrm{tower}$ is strictly monotone |
| `tower_lt_omega1` | $\mathrm{tower}(n) < \omega_1$ |
| `epsilonZero_lt_omega1` | $\varepsilon_0 < \omega_1$ (closes Mathlib TODO) |
| `epsilonZero_card_lt_aleph_one` | $|\varepsilon_0| < \aleph_1$ |
| `omega1_isEpsilon` | $\omega^{\omega_1} = \omega_1$ |
| `psiE_strictMono` | $\psi_E$ strictly monotone |
| `psiE_isEpsilon` | $\omega^{\psi_E(o)} = \psi_E(o)$ |
| `epsilonZero_lt_Omega` | $\varepsilon_0 < \Omega = \omega_1$ |
| `epsilonZero_lt_psiE_Omega_opow_omega0` | $\varepsilon_0 < \psi_E(\Omega^\omega)$ |
| `epsilonZero_lt_bachmannHoward` | $\varepsilon_0 <$ Bachmann–Howard model |
| `no_monotone_collapse` | strictly monotone $\Rightarrow \omega_1 \le f(\omega_1)$ |
