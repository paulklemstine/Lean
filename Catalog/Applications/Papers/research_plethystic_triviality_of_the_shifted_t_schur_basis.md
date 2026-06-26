# Plethystic Triviality of the Shifted $t$-Schur Basis

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Applications (Algebraic Combinatorics / Symmetric Functions)

## Abstract

We study a one-parameter deformation of the Schur $Q$-functions, the *shifted
$t$-Schur functions* $S^t_\lambda$, constructed via $t$-deformed odd vertex
operators in the spirit of the odd Ginzburg–Joyal–Zhu (GJZ) construction. Our
main result is that this deformation is *plethystically trivial*: there is a
single algebra endomorphism $\varphi_t$ of the ring $\Gamma = R[p_1, p_3, p_5,
\dots]$ of symmetric functions in the odd power sums, defined by $\varphi_t(p_n)
= (1 - t^n) p_n$ for odd $n$, such that

$$S^t_\lambda = \varphi_t(Q_\lambda) \qquad \text{for every strict partition }
\lambda.$$

The shifted $t$-Schur family is therefore obtained from the Schur $Q$ basis by
the odd plethystic substitution $p_n \mapsto (1 - t^n) p_n$. The proof is
*non-circular*: the family $S^t_\lambda$ is defined entirely from $t$-deformed
data, never as $\varphi_t(Q_\lambda)$, and the identity emerges from an
intertwining (Pieri-compatible) relation between the deformed and classical
vertex operators. The argument splits into a creation-part intertwining
($q^t_n = \varphi_t(q_n)$) and an annihilation-part chain rule
($\mathrm{annShiftT}(\varphi_t f) = (\mathrm{annShift}\, f)$ with $\varphi_t$
applied to coefficients), assembled by induction on the number of parts of
$\lambda$. All results have been mechanically verified to be free of unproved
assumptions. We also record several falsifiable conjectures, including a
uniqueness statement isolating Schur $Q$ as the unique plethystically trivial
member of a natural interpolating family.

## 1. Introduction

### 1.1 Context

Symmetric functions form one of the central algebraic structures of modern
combinatorics and representation theory. Over a commutative base ring $R
\supseteq \mathbb{Q}$, the ring $\Lambda_R$ of symmetric functions is a
polynomial algebra in the power sums: $\Lambda_R = R[p_1, p_2, p_3, \dots]$. A
distinguished subalgebra, generated only by the *odd* power sums,

$$\Gamma_R = R[p_1, p_3, p_5, \dots],$$

is the natural home of Issai Schur's $Q$-functions, the symmetric functions
governing projective (spin) representations of symmetric groups and the
cohomology of isotropic Grassmannians. The Schur $Q$-functions $\{Q_\lambda\}$,
indexed by strict partitions $\lambda$, form a basis of $\Gamma_R$.

Deformations of classical symmetric-function bases — Hall–Littlewood,
Macdonald, and their many relatives — are a perennial source of structure and
difficulty. A recurring meta-question is whether a given one-parameter
deformation is *genuinely new* or whether it is a re-coordinatization of a known
family through a plethystic substitution. The present work answers this question,
decisively in the latter direction, for a specific deformation of the Schur $Q$
basis arising from $t$-deformed odd vertex operators.

### 1.2 Main result

Define the *plethystic endomorphism* $\varphi_t$ as the $R$-algebra
endomorphism of $\Gamma_R$ determined on generators by

$$\varphi_t(p_n) = (1 - t^n)\, p_n \quad (n \text{ odd}).$$

Let $Q_\lambda$ denote the Schur $Q$-function in the vertex-operator
normalization of the odd GJZ construction (the $t = 0$ case), and let
$S^t_\lambda$ denote the shifted $t$-Schur function produced by the analogous
$t$-deformed vertex operator. Our theorem is:

> **Theorem (Plethystic triviality, `shifted_tSchur_eq_phiT_Q`).** For every
> strict partition $\lambda$,
> $$S^t_\lambda = \varphi_t(Q_\lambda).$$

Equivalently, the entire shifted $t$-Schur basis is the $\varphi_t$-image of the
Schur $Q$ basis.

### 1.3 Falsifiability and faithfulness

The statement is *falsifiable* by direct coefficient comparison: in the finite
odd power-sum polynomial ring truncated to degree at most $|\lambda|$, both
sides are explicit polynomials in $p_1, p_3, p_5, \dots$ with coefficients in
$R(t)$, and equality can be checked coefficient-by-coefficient. The numerical
demonstrations accompanying this paper carry out exactly this comparison for
small $\lambda$.

The construction is *faithful*: we model $\Gamma$ as a polynomial ring with one
variable $X_k$ standing for the odd power sum $p_{2k+1}$, we define $Q_\lambda$
and $S^t_\lambda$ through honest vertex-operator data, and the identity is never
assumed. In particular, $S^t_\lambda$ is defined from $t$-deformed power sums
alone, so the theorem genuinely identifies two independently constructed
families.

## 2. The polynomial model of $\Gamma$

We work over the base field $K = \mathbb{Q}(t)$ of rational functions in a
transcendental parameter $t$.

**Definition 2.1 (Ring of odd symmetric functions).** Let

$$\Lambda := \mathrm{MvPolynomial}(\mathbb{N}, K),$$

the polynomial ring over $K$ in countably many variables $X_0, X_1, X_2, \dots$.
We interpret the variable $X_k$ as the odd power sum $p_{2k+1}$, and write

$$p(k) := X_k = p_{2k+1}.$$

Thus $\Lambda$ is the polynomial realization of $\Gamma_K = K[p_1, p_3, p_5,
\dots]$. The parameter is $t = $ the transcendental indeterminate of $K =
\mathbb{Q}(t)$.

**Definition 2.2 (Deformation scalars).** For $k \in \mathbb{N}$ define

$$c_k := 1 - t^{2k+1} \in K.$$

**Lemma 2.3 (`cc_ne`).** $c_k \neq 0$ for every $k$.

*Proof sketch.* Write $1 - t^{2k+1}$ as the image under the fraction-field
embedding $\mathbb{Q}[t] \hookrightarrow \mathbb{Q}(t)$ of the nonzero
polynomial $1 - X^{2k+1}$. Since the embedding is injective and $1 - X^{2k+1}$
is nonzero (it evaluates to $1$ at $X = 0$), its image is nonzero. $\square$

The nonvanishing of $c_k$ is essential: the $t$-deformed annihilation operator
divides by $c_k$, and $\varphi_t$ is injective precisely because each generator
is scaled by a unit of $K$.

## 3. The plethystic endomorphism

**Definition 3.1 (`phiT`).** Let $\varphi_t : \Lambda \to \Lambda$ be the
$K$-algebra endomorphism defined by aeval on generators,

$$\varphi_t(X_k) = c_k \cdot X_k = (1 - t^{2k+1})\, X_k.$$

Being an algebra map, $\varphi_t$ extends multiplicatively and $K$-linearly to
all of $\Lambda$.

**Lemma 3.2 (`phiT_X`, `phiT_p`).** For all $k$,

$$\varphi_t(X_k) = c_k X_k, \qquad \varphi_t(p(k)) = (1 - t^{2k+1})\, p(k).$$

*Proof sketch.* Immediate from the definition of aeval on generators. $\square$

Because every generator is scaled by a unit $c_k \in K^\times$, $\varphi_t$ is in
fact an automorphism of $\Lambda$, with inverse $X_k \mapsto c_k^{-1} X_k$. (We
use only that it is an injective algebra endomorphism in what follows.)

## 4. Creation functions and the Newton recursion

The Schur $Q$ one-row functions are the coefficients of the generating kernel

$$\prod_i \frac{1 + x_i z}{1 - x_i z}
   = \exp\!\Big(\sum_{r \text{ odd}} \frac{2}{r}\, p_r\, z^{r}\Big).$$

Taking the logarithmic derivative in $z$ yields the first-order ODE
$F'(z) = F(z)\cdot\big(2 \sum_{k \ge 0} p_{2k+1} z^{2k}\big)$, whose
coefficient-by-coefficient reading is the Newton recursion we adopt as the
definition.

**Definition 4.1 (Generic creation functions, `qGen`).** Given a coefficient
sequence $\mathrm{cf} : \mathbb{N} \to \Lambda$, define $q^{\mathrm{cf}}_m \in
\Lambda$ by

$$q^{\mathrm{cf}}_0 = 1, \qquad
q^{\mathrm{cf}}_{m+1} = \frac{1}{m+1}\sum_{k=0}^{\lfloor m/2\rfloor}
   2\,\mathrm{cf}(k)\, q^{\mathrm{cf}}_{\,m - 2k}.$$

The recursion terminates because $m - 2k < m + 1$ for all $k \ge 0$.

**Definition 4.2 (Schur $Q$ and deformed one-row functions, `q`, `qt`).**

$$q_n := q^{\mathrm{cf}}_n \text{ with } \mathrm{cf}(k) = X_k, \qquad
q^t_n := q^{\mathrm{cf}}_n \text{ with } \mathrm{cf}(k) = c_k X_k.$$

So $q_n = Q_{(n)}$ is the one-row Schur $Q$-function, and $q^t_n$ its
$t$-deformation built from the deformed odd power sums $c_k X_k = (1 -
t^{2k+1}) p_{2k+1}$.

For example, the recursion produces
$$q_0 = 1,\quad q_1 = 2X_0,\quad q_2 = 2X_0^2,\quad q_3 = \tfrac{4}{3}X_0^3 + \tfrac{2}{3}X_1,$$
in the vertex-operator normalization fixed by the $\tfrac{1}{m+1}$ prefactor of
the recursion (recall $X_0 = p_1$, $X_1 = p_3$).

**Proposition 4.3 (Creation-part intertwining, `qt_eq_phiT_q`).** For all $n$,

$$q^t_n = \varphi_t(q_n).$$

*Proof sketch.* Strong induction on $n$. The base cases $q_0 = q^t_0 = 1$ and the
$n=1$ case are direct. For the inductive step, unfold the recursion: the deformed
sum has summands $2\, c_k X_k\, q^t_{m-2k}$ while the image $\varphi_t$ of the
undeformed sum has summands $2\,\varphi_t(X_k)\,\varphi_t(q_{m-2k}) = 2\, c_k
X_k\, \varphi_t(q_{m-2k})$. Since $\varphi_t$ is an algebra map it commutes with
the scalar factor $\tfrac{1}{m+1}$ and with the finite sum and products, and the
induction hypothesis gives $q^t_{m-2k} = \varphi_t(q_{m-2k})$ termwise. The two
expressions therefore agree. $\square$

This proposition is the "easy half": $\varphi_t$ is an algebra homomorphism, so
it passes through the polynomial recursion verbatim once the generators are
matched.

## 5. Annihilation operators and the chain rule

The full vertex operator $B(z) = B_+(z) \circ B_-(z)$ factors into a creation
half $B_+(z)$ (multiplication by $\sum_n q_n z^n$) and an annihilation half
$B_-(z) = \exp\big(-\sum_{k} d_k\, \partial_{p_{2k+1}} z^{-(2k+1)}\big)$. Because
the coefficients $d_k$ are constant in the power-sum variables, $B_-(z)$ acts as
a *Taylor shift*.

**Definition 5.1 (Generic annihilation, `annGen`).** Given $d : \mathbb{N} \to
K$, let $\mathrm{annGen}(d) : \Lambda \to \Lambda[u]$ be the $K$-algebra map
(into the polynomial ring $\Lambda[u]$, with $u = z^{-1}$) defined on generators
by the Taylor shift

$$X_k \longmapsto X_k - d_k\, u^{2k+1}.$$

**Definition 5.2 (Classical and deformed shifts, `annShift`, `annShiftT`).**

$$\mathrm{annShift} := \mathrm{annGen}(k \mapsto 4), \qquad
\mathrm{annShiftT} := \mathrm{annGen}\!\big(k \mapsto 4/c_k\big).$$

The constant $4$ is the adjoint normalization of the creation part with respect
to the Schur $Q$ (Hall–Littlewood at $t=-1$) inner product. The deformed
operator uses the matching dual constant $4/c_k = 4/(1 - t^{2k+1})$; the final
identity is independent of this overall choice of constant, as the matching dual
guarantees.

**Proposition 5.3 (Annihilation chain rule, `annShiftT_phiT`).** For all $f \in
\Lambda$,

$$\mathrm{annShiftT}(\varphi_t f) = \big(\mathrm{annShift}\, f\big)
   .\mathrm{map}(\varphi_t),$$

where the right-hand side applies $\varphi_t$ coefficientwise to the polynomial
in $u$.

*Proof sketch.* Both sides are $K$-algebra maps $\Lambda \to \Lambda[u]$, so it
suffices to check equality on generators and extend by the algebra structure
(via `MvPolynomial.induction_on`). On the generator $X_k$:

- The left side is $\mathrm{annShiftT}(\varphi_t X_k) = \mathrm{annShiftT}(c_k
  X_k) = c_k\big(X_k - (4/c_k)\, u^{2k+1}\big) = c_k X_k - 4\, u^{2k+1}$.
- The right side is $\mathrm{map}(\varphi_t)\big(X_k - 4\, u^{2k+1}\big) =
  \varphi_t(X_k) - 4\, u^{2k+1} = c_k X_k - 4\, u^{2k+1}$.

The two coincide. The crucial cancellation is $c_k \cdot (4/c_k) = 4$ — the
deformation scalar of the creation side exactly cancels the inverse scalar in the
dual annihilation constant, which is why the chain rule produces the *undeformed*
shift constant $4$ transported by $\varphi_t$, rather than some $t$-dependent
hybrid. The induction over sums and products closes the proof; the additive and
multiplicative compatibilities are exactly `Polynomial.map_mul`,
`Polynomial.map_pow`, and `Polynomial.map_X`. $\square$

This is the "hard half": it is *not* the statement that $\varphi_t$ commutes with
the shift on the nose (it does not — the constants differ), but that the deformed
shift after $\varphi_t$ equals the classical shift with coefficients transported.
The mismatch of constants is reconciled precisely by the unit $c_k$.

## 6. The vertex operators and the main theorem

**Definition 6.1 (Vertex operators and basis functions).** Assembling the
creation and annihilation halves gives, for each mode $n$, operators $B_n$
(classical) and $B^t_n$ (deformed) on $\Lambda$. For a strict partition
$\lambda = (\lambda_1 > \cdots > \lambda_\ell)$ define

$$Q_\lambda := B_{\lambda_1}\!\big(\cdots B_{\lambda_\ell}(1)\big), \qquad
S^t_\lambda := B^t_{\lambda_1}\!\big(\cdots B^t_{\lambda_\ell}(1)\big).$$

Crucially, $S^t_\lambda$ is defined purely from the $t$-deformed data $(q^t,
\mathrm{annShiftT})$ — never as $\varphi_t(Q_\lambda)$.

**Proposition 6.2 (Operator intertwining, `Bt_phiT`).** For every mode $n$ and
every $f \in \Lambda$,

$$B^t_n(\varphi_t f) = \varphi_t\big(B_n f\big).$$

*Proof sketch.* The mode $B_n$ extracts a fixed coefficient of the composite
$B_+ \circ B_-$. By Proposition 4.3 the creation half intertwines with
$\varphi_t$ (the deformed creation series is the $\varphi_t$-image of the
classical one), and by Proposition 5.3 the annihilation half intertwines as a
coefficientwise chain rule. Since $\varphi_t$ is an algebra map, it commutes with
the multiplication by the creation series and with extraction of the relevant
coefficient. Composing the two intertwinings yields the operator-level identity.
$\square$

**Theorem 6.3 (Plethystic triviality, `Sfun_eq_phiT_Qfun` /
`shifted_tSchur_eq_phiT_Q`).** For every strict partition $\lambda$,

$$S^t_\lambda = \varphi_t(Q_\lambda).$$

*Proof sketch.* Induction on the number of parts $\ell$ of $\lambda$. For
$\ell = 0$ (the empty partition), both sides equal $\varphi_t(1) = 1$. For the
inductive step, write $\lambda = (\lambda_1, \mu)$ with $\mu$ the tail. Then

$$S^t_\lambda = B^t_{\lambda_1}(S^t_\mu)
   \stackrel{\text{IH}}{=} B^t_{\lambda_1}(\varphi_t Q_\mu)
   \stackrel{\text{Prop 6.2}}{=} \varphi_t(B_{\lambda_1} Q_\mu)
   = \varphi_t(Q_\lambda).$$

The middle step uses the inductive hypothesis $S^t_\mu = \varphi_t(Q_\mu)$, and
the third uses the operator intertwining of Proposition 6.2. $\square$

## 7. Algorithms

The proof yields an effective procedure for computing shifted $t$-Schur
functions without ever running the deformed vertex operator.

### 7.1 One-row functions by Newton recursion

To compute $q_n$ in odd-power-sum coordinates, iterate

$$q_0 = 1, \qquad q_{m+1} = \frac{1}{m+1}\sum_{k=0}^{\lfloor m/2\rfloor}
   2\, p_{2k+1}\, q_{m-2k}.$$

Each step is a single $K$-linear combination of previously computed polynomials;
the total cost to reach degree $N$ is $O(N)$ multiplications of polynomials whose
support is bounded by the partitions of $\le N$ into odd parts.

### 7.2 Shifted $t$-Schur via plethysm

Given $Q_\lambda$ as a polynomial in $\{p_{2k+1}\}$:

1. For each monomial $\prod_j p_{2k_j+1}^{a_j}$ appearing in $Q_\lambda$,
2. multiply its coefficient by $\prod_j (1 - t^{2k_j+1})^{a_j}$,
3. leaving the monomial unchanged.

The result is $\varphi_t(Q_\lambda) = S^t_\lambda$. This is linear in the number
of monomials of $Q_\lambda$ and requires no vertex-operator machinery — the
content of Theorem 6.3.

### 7.3 Falsification check

To verify (or attempt to falsify) the theorem for a given $\lambda$, compute
$S^t_\lambda$ independently from the deformed recursion/operator, compute
$\varphi_t(Q_\lambda)$ by the plethysm above, and compare the two as polynomials
in the finite ring $K[p_1, \dots, p_{2\lfloor |\lambda|/2\rfloor+1}]$ truncated
to total degree $|\lambda|$. Equality of all coefficients confirms the identity.

## 8. Applications and discussion

**Reduction of deformed questions to classical ones.** Theorem 6.3 means every
structural question about $\{S^t_\lambda\}$ — expansion in any basis,
specialization, multiplication (Littlewood–Richardson-type) coefficients — pulls
back along the algebra automorphism $\varphi_t$ to the corresponding question
about $\{Q_\lambda\}$, and pushes forward again. Because $\varphi_t$ is diagonal
on the power-sum generators, this transport is completely explicit.

**Schur $Q$ as a distinguished fixed point.** The deformation interpolates
between recognizable regimes as $t$ varies. The "odd-only" support that
characterizes Schur $Q$ — the vanishing of the even power sums in the log-kernel
— is the structural fingerprint preserved by $\varphi_t$. This motivates the
uniqueness conjecture in §9 isolating the special parameter value.

**Vertex-operator methodology.** The proof showcases a robust template: encode a
deformation as a substitution on generators, prove a *creation* intertwining
(easy, because substitutions are algebra maps) and an *annihilation* chain rule
(the real content, reconciling mismatched normalization constants), and lift to
all indices by induction. The same template applies to other vertex-operator
constructions of symmetric functions.

**On normalization independence.** The annihilation constant $4$ is an artifact
of the chosen inner-product normalization. The deformed operator uses the
matching dual $4/c_k$, and the proof of Proposition 5.3 shows the product
$c_k\cdot(4/c_k) = 4$ erases any dependence on this choice. Thus the identity is
robust: it does not hinge on the specific value $4$.

## 9. Future directions

The following falsifiable conjectures, stated for follow-up work, sharpen and
extend the present results.

**C1. Exponential closed form.** Over $\mathrm{MvPolynomial}(\mathrm{Fin}\,n,
\mathbb{Q})$ with `PowerSeries.exp`, the generating series satisfies
$\mathrm{qGen}\,n = \exp\big(2 \sum_{k \ge 1,\ k\text{ odd}} p_k T^k / k\big)$,
upgrading the first-order ODE $(\mathrm{qGen}\,n)' = \mathrm{qGen}\,n \cdot (2
\sum_{k\ge 0} p_{2k+1} T^{2k})$ to integrated form. This is the cleanest
statement that "Schur $Q$ lives in $\mathbb{Q}[p_1, p_3, p_5, \dots]$." Test
path: build a power-series antiderivative $I$ with $I' = $ odd power-sum series
and constant term $0$, and prove both $\mathrm{qGen}\,n$ and $\exp I$ satisfy
$F' = F\cdot g$, $F(0)=1$, then invoke uniqueness.

**C2. Subalgebra membership.** Each coefficient $q_r = \mathrm{coeff}_r(\mathrm{
qGen}\,n)$ lies in the subalgebra $\mathbb{Q}[p_1, p_3, p_5, \dots]$ generated by
the odd power sums; the even power sums are not needed. Concretely $q_r$ is a
rational polynomial in $\{p_{2j+1} : 2j+1 \le r\}$. Test path: the Newton-type
recurrence $r\, q_r = 2\sum_{j\ge 0} p_{2j+1} q_{r-(2j+1)}$ extracted by reading
degree-$(r-1)$ coefficients of the ODE, then induction.

**C3. Newton recurrence for the shifted basis.** For all $r \ge 1$,
$$r\cdot \mathrm{coeff}_r(\mathrm{qGen}\,n) = 2 \sum_{j:\,2j+1\le r} p_{2j+1}
\cdot \mathrm{coeff}_{r-(2j+1)}(\mathrm{qGen}\,n).$$
This coefficient-$(r-1)$ reading of the log-derivative ODE gives an effective
algorithm for $q_r$ purely from odd power sums — the discrete shadow of C1/C2.

**C4. $t$-deformation and the "shift by $t$."** Introduce a deformation
$\mathrm{oneRowQ}_t$ with kernel factor $(1 - t x_i T)$, a one-parameter family
interpolating between $t=1$ (Schur $Q$) and $t=0$ (the trivial/Schur case). The
falsifiable claim: the set of $t \in \mathbb{Q}$ for which the log-derivative
potential is supported on even $T$-degrees (odd power sums only) is exactly
$\{1\}$, isolating Schur $Q$ as the unique plethystically trivial member of the
family.

## 10. Conclusion

We have proved that the shifted $t$-Schur basis is the plethystic image of the
Schur $Q$ basis under the single odd substitution $p_n \mapsto (1 - t^n) p_n$.
The result is established non-circularly, with $S^t_\lambda$ defined from
deformed data alone, via a creation-part intertwining and an annihilation-part
chain rule lifted by induction. The deformation, despite its elaborate
vertex-operator definition, carries no new structure beyond a diagonal change of
coordinates on the odd power sums — it is *plethystically trivial*. This both
tames the deformed family computationally and crystallizes the special role of
Schur $Q$ among interpolating families.
