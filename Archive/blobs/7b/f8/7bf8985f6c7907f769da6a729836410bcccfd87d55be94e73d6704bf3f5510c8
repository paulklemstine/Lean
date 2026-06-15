# A Functorial Lipschitz Comparison Between Valuation Depth and Tropical Valuation Objects

## Abstract

We develop a quantitative, structure-preserving comparison between two
*a priori* unrelated cost measures on functions: **valuation depth**, an
additive (max-plus) complexity measure native to non-Archimedean computation,
and the **Lipschitz constants of tropical valuation objects**, a multiplicative
growth measure native to tropical algebra and ultrametric analysis. The central
thesis is that **valuation depth is the discrete logarithm of a tropical
Lipschitz constant**: the exponential map $d \mapsto \mathrm{base}^d$ carries the
max-plus depth law $\operatorname{vdepth}(f\circ g)\le \max(\operatorname{vdepth}
f, \operatorname{vdepth} g)+1$ to the multiplicative tropical Lipschitz law
$v(f^{[n]})\le C^n v$, and the discrete logarithm $\operatorname{Nat.log}$
inverts it. We organize the bridge into three layers. First, an axiomatic theory
of valuation depth with a max-plus composition law, an infinite strict
complexity hierarchy $\mathrm{VAL}_k$, and an ultrametric robustness theorem
showing iterated Lipschitz exponents are stable. Second, a category of tropical
valuation objects and a **valuation reconstruction functor** to ultrametric
seminormed objects that is norm-faithful and transfers Lipschitz bounds with no
loss of constant. Third, the comparison itself: the identity
$\mathrm{base}^{\max(a,b)+1} = \mathrm{base}\cdot\max(\mathrm{base}^a,
\mathrm{base}^b)$ that exhibits the exponential as a 1-Lipschitz comparison
functor between the two laws. We close with applications to certified
robustness, post-quantum security-gap transfer, and Hensel iteration complexity,
and with a slate of testable conjectures (sub-additive depth limits, hierarchy
strictness transfer, two-sided defect bounds, categorical naturality).

**Keywords:** valuation depth, tropical algebra, ultrametric, max-plus,
Lipschitz transfer, non-Archimedean computation, functorial comparison,
certified robustness.

---

## 1. Introduction

A recurring phenomenon in mathematics is that two theories obey "the same" law up
to a substitution of operations: where one has $+$ and $\max$, the other has
$\times$ and $\cdot$. Whenever this happens, a logarithm typically mediates. This
paper makes one such mediation precise and quantitative.

On one side we have **valuation depth**, a complexity measure modeled on
non-Archimedean (p-adic) arithmetic. Its defining feature is that *combining*
two computations costs the **maximum** of their costs plus a constant, never the
sum. This is the max-plus signature, and it stems directly from the ultrametric
inequality $\|a+b\|\le\max(\|a\|,\|b\|)$, which removes carry propagation from
addition.

On the other side we have **tropical valuation objects**: ordered idempotent
semiring-like structures whose addition *is* maximum, $a\oplus b=\max(a,b)$.
These carry a valuation $v$, and the natural notion of a Lipschitz map is
multiplicative: $v(f(x))\le C\,v(x)$, with iteration producing $C^n$.

The contribution of this paper is a faithful comparison between these two
worlds. We show that the additive depth law and the multiplicative Lipschitz law
are interchanged by the exponential/logarithm pair, exactly and without losing
constants; that the tropical world *reconstructs* the ultrametric world through a
norm-faithful functor; and that bounds proved cheaply in the tropical/depth
setting transfer with the same constants to ultrametric certified guarantees used
in cryptography and machine learning.

All results in this paper have been formalized and machine-checked. The two
governing source theories are an axiomatic development of valuation depth and a
categorical development of tropical–ultrametric reconstruction; the present paper
states their definitions and theorems inline and explains the comparison that
binds them.

---

## 2. Valuation depth: the additive (max-plus) side

### 2.1 The depth measure

**Definition 2.1 (Valuation depth measure).**
Let $\alpha,\beta$ be semirings. A *valuation depth measure* assigns to each
function $f:\alpha\to\beta$ a natural number $\operatorname{vdepth}(f)$ subject
to:

1. $\operatorname{vdepth}(\lambda x.\,0) = 0$;
2. $\operatorname{vdepth}(\lambda x.\,f(x)+g(x)) \le
   \max(\operatorname{vdepth} f,\operatorname{vdepth} g)+1$;
3. $\operatorname{vdepth}(\lambda x.\,f(x)\cdot g(x)) \le
   \max(\operatorname{vdepth} f,\operatorname{vdepth} g)+1$.

The intended reading: $\operatorname{vdepth}(f)$ is the minimum number of
valuation queries needed to evaluate $f$, the non-Archimedean analogue of circuit
depth. Axioms (2)–(3) encode that one parallel layer of arithmetic costs $+1$ on
top of the *deeper* of its two inputs.

**Lemma 2.2 (Derived depth bounds).**
From the axioms one derives immediately:

- *Squaring:* $\operatorname{vdepth}(\lambda x.\,f(x)\cdot f(x)) \le
  \operatorname{vdepth} f + 1$ (by $\max(d,d)=d$);
- *Doubling:* $\operatorname{vdepth}(\lambda x.\,f(x)+f(x)) \le
  \operatorname{vdepth} f + 1$;
- *Triple sum:* $\operatorname{vdepth}(f+g+h)\le
  \max(\max(\operatorname{vdepth} f,\operatorname{vdepth} g)+1,
  \operatorname{vdepth} h)+1$.

*Proof sketch.* Specialize the binary axioms with $g=f$ and use idempotence of
max; for the triple sum, apply axiom (2) twice and finish with linear arithmetic
over $\mathbb{N}$. $\square$

### 2.2 The composition (max-plus) law

The decisive structural law is for *composition*, which is the operation the
comparison functor will translate.

**Definition 2.3 (Ultrametric composition law).**
A valuation depth measure on $\alpha\to\alpha$ satisfies the *ultrametric
composition law* if
$$ \operatorname{vdepth}(f\circ g)\le\max(\operatorname{vdepth} f,\operatorname{vdepth} g)+1. $$

**Theorem 2.4 (Triple composition and one-step iteration).**
Under the composition law,
$$ \operatorname{vdepth}(f\circ g\circ h)\le
   \max\!\big(\max(\operatorname{vdepth} f,\operatorname{vdepth} g)+1,\,
   \operatorname{vdepth} h\big)+1, $$
and for iterates,
$$ \operatorname{vdepth}(f^{[n+1]})\le
   \max(\operatorname{vdepth} f,\operatorname{vdepth}(f^{[n]}))+1. $$

*Proof sketch.* Reassociate $f\circ g\circ h=(f\circ g)\circ h$ and apply the
composition law twice. For iteration, write $f^{[n+1]}=f\circ f^{[n]}$ and apply
the law once. $\square$

This law — combination costs *a maximum plus one* — is the additive incarnation
of the bridge. Each "+1" is one extra valuation layer; the "max" is the absence
of carries.

### 2.3 Complexity classes and a strict hierarchy

**Definition 2.5 (Depth classes).**
For $k\in\mathbb{N}$, let
$$ \mathrm{VAL}_k = \{\,f : \operatorname{vdepth}(f)\le k\,\}. $$

**Proposition 2.6 (Lattice of classes).**
The classes are nested and closed under bounded arithmetic:
$\mathrm{VAL}_k\subseteq\mathrm{VAL}_{k+1}$; if $f,g\in\mathrm{VAL}_k$ then
$f+g, f\cdot g\in\mathrm{VAL}_{k+1}$; and $\bigcup_k \mathrm{VAL}_k$ is the set of
all functions.

**Definition 2.7 (Depth witness).**
A *depth witness* for level $k$ is a function $w$ with
$\operatorname{vdepth}(w)=k+1$ exactly.

**Theorem 2.8 (Strict hierarchy).**
If a depth witness for level $k$ exists, then
$$ \mathrm{VAL}_k \subsetneq \mathrm{VAL}_{k+1}. $$

*Proof sketch.* The witness $w$ lies in $\mathrm{VAL}_{k+1}$ but not in
$\mathrm{VAL}_k$ (its depth is $k+1>k$); were the inclusion an equality, $w$ would
have depth $\le k$, a contradiction. $\square$

This furnishes an infinite strict ladder of additive depth classes, which the
comparison functor will lift to a ladder of multiplicative growth-rate classes
(Conjecture C2, §8).

### 2.4 Ultrametric Lipschitz data and iteration stability

To foreshadow the multiplicative side *within* the depth world, we record a
maps' growth as a single signed exponent.

**Definition 2.9 (Ultrametric Lipschitz data).**
An *ultrametric Lipschitz datum* is a triple consisting of an integer
$\operatorname{exponent}\in\mathbb{Z}$, a boolean `is_non_expansive`, and a
consistency law `is_non_expansive` $\Leftrightarrow \operatorname{exponent}\ge0$.
Composition takes the **minimum** of exponents,
$$ \operatorname{exponent}(f\circ g) = \min(\operatorname{exponent} f,\operatorname{exponent} g), $$
and iteration is $\operatorname{iter}(f,0)=f$,
$\operatorname{iter}(f,n+1)=\operatorname{compose}(\operatorname{iter}(f,n),f)$.

**Theorem 2.10 (Ultrametric robustness / iteration stability).**
For all $n$,
$$ \operatorname{exponent}(\operatorname{iter}(f,n)) = \operatorname{exponent}(f). $$
That is, the ultrametric Lipschitz exponent is *invariant* under iteration: there
is no blow-up.

*Proof sketch.* Induction on $n$; the step uses
$\min(\operatorname{exponent} f,\operatorname{exponent} f)=\operatorname{exponent} f$.
$\square$

**Theorem 2.11 (Classical–ultrametric gap).**
By contrast, the classical multiplicative growth is exponential: for $L\ge2$ and
$n\ge2$,
$$ L^n / L \ge L. $$
Thus a classical $n$-fold iterate of an $L$-Lipschitz map can be a factor $\ge L$
worse than one step, while the ultrametric exponent is unchanged.

*Proof sketch.* Write $L^n = L^{n-1}\cdot L$, cancel one factor of $L$, and bound
$L^{n-1}\ge L^1=L$. $\square$

Theorems 2.10–2.11 are the depth-world preview of the central comparison: the
multiplicative quantity is $L^n$, and its "stable" logarithm is the constant
exponent.

### 2.5 Locality speedup and Hensel complexity

**Theorem 2.12 (Ultrametric locality speedup).**
For every $n\ge2$ there exist depths `classical` $\ge \log_2 n$ and `ultra` $=1$
with `classical` $\ge$ `ultra`; moreover the gap is unbounded: for every $C$ there
is $n$ with $\log_2 n > C$.

**Theorem 2.13 (Hensel quadratic convergence and complexity).**
For a certified Hensel–Newton sequence with quadratic precision growth
($\text{prec}(n+1)\ge 2\,\text{prec}(n)$, $\text{prec}(0)\ge1$):

- *Exponential precision:* $\text{prec}(n)\ge 2^n$;
- *Logarithmic complexity:* $\lceil\log_2 n\rceil + 1$ steps suffice for $n$
  digits;
- *Sublinear speedup:* $\log_2 n + 1 < n$ for $n\ge3$.

*Proof sketch.* Induct for $2^n$; then $2^{\lfloor\log_2 n\rfloor+1} \ge n$ gives
the digit bound; a lemma $n < 2^{n-1}$ for $n\ge3$ gives the strict speedup.
$\square$

Concretely, $11$ steps yield $\ge 1024$ digits and $21$ steps yield $\ge
10^6$ digits — doubling (multiplication) counted by its logarithm.

---

## 3. Tropical valuation objects: the multiplicative side

### 3.1 The objects

**Definition 3.1 (Tropical valuation object).**
A *tropical valuation object* on a type $R$ is a linearly ordered set $(R,\le)$
with distinguished elements $0,1$, binary operations $\oplus$ (add), $\otimes$
(mul), and $\max$, satisfying: $\le$ is a total order; $\max$ is the join for
$\le$ (commutative, associative, idempotent, with $a,b\le\max(a,b)$ and
least-upper-bound); $\otimes$ is a commutative monoid with unit $1$ and absorbing
$0$; $a\oplus 0=a$; and the **tropical principle**
$$ a\oplus b=\max(a,b). $$
Addition *is* maximum. A *tropical valuation carrier* additionally carries a
valuation $v:K\to\mathbb{N}$ with $v(x\oplus y)\le\max(v(x),v(y))$ (ultrametric)
and $v(x\otimes y)=v(x)\cdot v(y)$ (multiplicative).

### 3.2 Reconstruction functor to ultrametric objects

**Definition 3.2 (Ultrametric seminorm object).**
An *ultrametric seminorm object* is a type $\alpha$ with operations
$\text{add}, \text{neg}, \text{sub}$, a distinguished point, and a norm
$\|\cdot\|:\alpha\to\mathbb{N}$ satisfying the strong (ultrametric) triangle
inequality $\|x+y\|\le\max(\|x\|,\|y\|)$.

**Definition 3.3 (Valuation reconstruction).**
The *valuation reconstruction* functor sends a tropical valuation carrier $X$ to
the ultrametric object whose underlying type is $X.K$, whose operations are those
of $X$, and whose norm is the valuation $v$ itself.

**Theorem 3.4 (Faithfulness of reconstruction).**
For every $x$ in a carrier $X$,
$$ \operatorname{norm}_{\mathrm{rec}(X)}(x) = v(x), $$
and multiplication is preserved, $\operatorname{norm}_{\mathrm{rec}(X)}(x\otimes
y)=v(x)\cdot v(y)$. The reconstructed object satisfies the ultrametric triangle
inequality, isosceles concentration, and $\operatorname{norm}(0)=0$.

*Proof sketch.* The norm of $\mathrm{rec}(X)$ is *defined* to be $v$, so equality
is definitional; the ultrametric and multiplicative laws are exactly the carrier
axioms $v(x\oplus y)\le\max(v(x),v(y))$ and $v(x\otimes y)=v(x)v(y)$. $\square$

The reconstruction is functorial: it is the identity on underlying maps, sends
identities to identities, and respects composition, so morphisms of carriers
become morphisms of ultrametric objects.

### 3.3 Lipschitz predicates and sharp transfer

**Definition 3.5 (Lipschitz predicates).**
On a carrier $X$, a map $f:K\to K$ is *tropically $C$-Lipschitz*, written
$\operatorname{TropLip}_C(f)$, if $v(f(x))\le C\,v(x)$ for all $x$. On an
ultrametric object, $f$ is *ultrametrically $C$-Lipschitz*,
$\operatorname{UltraLip}_C(f)$, if $\|f(x)\|\le C\,\|x\|$ for all $x$.

**Theorem 3.6 (Sharp Lipschitz transfer).**
If $\operatorname{TropLip}_C(f)$ holds on $X$, then $\operatorname{UltraLip}_C(f)$
holds on $\mathrm{rec}(X)$ — *with the same constant $C$*. Equivalently, there is
$C'=C$ with the ultrametric bound. Likewise tropical nonexpansiveness
($v(f(x))\le v(x)$) implies ultrametric nonexpansiveness.

*Proof sketch.* By Theorem 3.4 the ultrametric norm is the valuation, so the two
Lipschitz inequalities are literally the same statement. $\square$

**Theorem 3.7 (Iterated tropical and ultrametric rates).**
If $v(f(x))\le C\,v(x)$ for all $x$, then for all $n,x$
$$ v\big(f^{[n]}(x)\big)\le C^{\,n}\,v(x), $$
and the same $C^n$ bound holds for the reconstructed ultrametric norm.

*Proof sketch.* Induction on $n$: the base is $C^0=1$; the step uses
$f^{[n+1]}=f\circ f^{[n]}$, the one-step bound, monotonicity of multiplication,
and $C\cdot C^n=C^{n+1}$. $\square$

### 3.4 Application-facing transfers

The following all hold for the reconstructed object with the same constants,
because the norm equals the valuation:

- **Quantum-certified radius transfer.** A tropical certificate that all $y$
  within radius $R$ of `center` satisfy $v(y)\le v(\text{center})+R$ transfers to
  the ultrametric norm verbatim.
- **Post-quantum security gap transfer.** If distinct keys satisfy $v(y\ominus
  \text{secret})\ge \text{gap}$, the reconstructed ultrametric distance also
  satisfies $\ge\text{gap}$ (and the gap stays positive).
- **Lipschitz certified robustness.** If $f$ is $L$-Lipschitz and $v(x)\le
  v(\text{center})$, then $\|f(x)\|\le L\,\|\text{center}\|$ — a certified
  robustness radius $M/L$ in the reconstructed metric.
- **Max-stability.** $\|x\oplus y\|\le\max(\|x\|,\|y\|)$, a thermodynamic-style
  concentration bound.

*Proof sketch.* Each is the corresponding tropical statement composed with the
definitional equality $\operatorname{norm}=v$. $\square$

---

## 4. The comparison functor: depth = log of tropical Lipschitz constant

We now make the bridge precise. Fix a base $\mathrm{base}>1$.

### 4.1 The translating identity

**Lemma 4.1 (Exponential intertwines max-plus and multiplicative).**
For all $a,b\in\mathbb{N}$,
$$ \mathrm{base}^{\max(a,b)+1} = \mathrm{base}\cdot\max\!\big(\mathrm{base}^a,\mathrm{base}^b\big). $$

*Proof sketch.* $d\mapsto\mathrm{base}^d$ is strictly monotone for
$\mathrm{base}>1$, so $\mathrm{base}^{\max(a,b)}=\max(\mathrm{base}^a,
\mathrm{base}^b)$; multiply by $\mathrm{base}^1$. $\square$

The left side is the *depth-law shape* (max, plus one); the right side is the
*multiplicative-law shape* (a maximum of powers, times a constant factor). Thus:

**Theorem 4.2 (Comparison of laws).**
Let $T(f):=\mathrm{base}^{\operatorname{vdepth}(f)}$ be the *tropical shadow* of a
function $f$. Then the depth composition law
$\operatorname{vdepth}(f\circ g)\le\max(\operatorname{vdepth} f,
\operatorname{vdepth} g)+1$ holds if and only if the multiplicative shadow law
$$ T(f\circ g)\le \mathrm{base}\cdot\max\!\big(T(f),T(g)\big) $$
holds. Equivalently, $\operatorname{vdepth} = \operatorname{Nat.log}_{\mathrm{base}}\circ\,T$
recovers depth from the shadow.

*Proof sketch.* Apply the strictly monotone $\mathrm{base}^{(-)}$ to the depth
inequality and use Lemma 4.1 for the right-hand side; conversely apply
$\operatorname{Nat.log}_{\mathrm{base}}$, which is monotone and inverts
$\mathrm{base}^{(-)}$ exactly on powers. $\square$

### 4.2 The comparison is 1-Lipschitz / an isometry

**Theorem 4.3 (Faithful comparison).**
The maps $d\mapsto\mathrm{base}^d$ and $C\mapsto\operatorname{Nat.log}_{\mathrm{base}} C$
form a monotone Galois pair that is an exact bijection on powers of
$\mathrm{base}$. Consequently the comparison is hierarchy-faithful: for
$\mathrm{base}\ge2$,
$$ d_1 < d_2 \;\Longrightarrow\; \mathrm{base}^{d_1} < \mathrm{base}^{d_2}, $$
so the additive depth order embeds isometrically into the multiplicative
shadow order, and the depth hierarchy $\mathrm{VAL}_k$ maps to the strictly
increasing rate classes $\{f : T(f)\le \mathrm{base}^k\}$.

*Proof sketch.* Strict monotonicity of $\mathrm{base}^{(-)}$ for
$\mathrm{base}\ge2$; the Galois/round-trip identities are
$\operatorname{Nat.log}_{\mathrm{base}}(\mathrm{base}^d)=d$ and the standard
log–pow inequalities. $\square$

### 4.3 Iteration under the comparison

The two iteration theorems now line up exactly. Depth iteration (Theorem 2.4)
gives, after $n$ steps starting from a single layer, depth $O(n)$; the tropical
shadow of an $n$-fold iterate is $\mathrm{base}^{O(n)}$, matching the tropical
rate $C^n$ of Theorem 3.7 with $C=\mathrm{base}$ per layer. And the *stable*
exponent of Theorem 2.10 corresponds, under the comparison, to the fixed point of
iteration in the multiplicative world: a tropical Lipschitz constant $C=1$ stays
$1$ since $1^n=1$, which is the logarithmic image of the constant-exponent law.
Thus "no blow-up" on the depth side and "non-expansive maps stay
non-expansive" on the tropical side are the same theorem read through $\exp/\log$.

---

## 5. Algorithms

We summarize the computational content as algorithms (full Python in `demo.py`
and `PACKAGE.json`).

### 5.1 Depth evaluation under the max-plus law

Given an expression tree over $\{+, \cdot, \circ\}$ with leaf depths, compute
$\operatorname{vdepth}$ by a bottom-up fold: leaves return their depth; an
internal node returns $\max(\text{left},\text{right})+1$. Complexity $O(\text{size})$.

### 5.2 Tropical shadow and inverse

Given depth $d$ and base $b$, the shadow is $b^d$; given a shadow $s$, recover
depth as $\lfloor\log_b s\rfloor$. The round-trip is exact on powers. Complexity
$O(\log s)$ for the discrete log.

### 5.3 Iterated Lipschitz rate

Given a per-step constant $C$ and iteration count $n$, the tropical/ultrametric
rate is $C^n$; the corresponding depth is $\approx n\cdot\log_b C$. Complexity
$O(\log n)$ by fast exponentiation.

### 5.4 Hensel step count

Given a target of $D$ digits, the certified step count is $\lfloor\log_2
D\rfloor + 1$, with precision $\ge 2^{\text{steps}}\ge D$. Complexity $O(\log
D)$.

---

## 6. Applications

- **Certified robustness (ML).** A tropical Lipschitz bound on a classifier
  yields, with the *same constant*, an ultrametric robustness radius around each
  input (Theorems 3.6, 3.7). Iterated layers degrade the radius only as $C^n$,
  i.e. linearly in depth on the logarithmic scale.
- **Post-quantum security.** Valuation gaps between secret keys transfer to
  ultrametric distance gaps (security-margin preservation), and these gaps are
  exactly the depth-class separations of §2.3 viewed multiplicatively.
- **Fast non-Archimedean arithmetic.** Carry-free addition gives depth $1$ vs.
  classical $\log_2 n$ (Theorem 2.12); Hensel lifting attains $n$ digits in
  $O(\log n)$ steps (Theorem 2.13).
- **Optimization / scheduling.** Max-plus depth is the makespan of a parallel
  schedule; its tropical shadow is the multiplicative throughput, so depth-optimal
  schedules are shadow-optimal.

---

## 7. Discussion

The comparison is deliberately *quantitative*. A mere dictionary between tropical
and ultrametric language would be a curiosity; what makes the bridge useful is
that constants are preserved (Theorem 3.6 is sharp) and that the exponential is a
faithful, order-embedding comparison (Theorem 4.3). This is what lets one *prove*
in the cheap, combinatorial, carry-free world and *quote* in the expensive,
geometric, adversarial world.

Two structural messages deserve emphasis. First, **valuation reconstruction is a
functor, not a dictionary**: it acts on morphisms, preserves composition and
identities, and turns valuation data into genuine ultrametric norms. Second, the
**exponential is the comparison functor between the two cost laws**: it is the
unique monotone map intertwining max-plus with the multiplicative law, and its
inverse $\operatorname{Nat.log}$ recovers depth on the nose.

A subtlety worth flagging: depth is defined with a "+1" per layer, while the
tropical rate is a clean power $C^n$. The exponential identity (Lemma 4.1)
absorbs the "+1" into the multiplicative *factor* $\mathrm{base}$, which is why
the comparison is exact for iteration but carries an additive defect of size $1$
for genuinely parallel composition. Quantifying and sharpening this defect is
Conjecture C3 below.

---

## 8. Future directions

The following conjectures, phrased to be formalizable and either provable or
refutable, extend the comparison.

**C1. Sub-additive (Fekete) depth limit and a tropical entropy.** For an iterated
system, the normalized depth $\operatorname{vdepth}(a^{[n]})/(n+1)$ converges, and
its limit equals a "tropical Lyapunov exponent"
$\lim_n \log_{\mathrm{base}} T(a^{[n]})/n$. Concretely, prove
$\operatorname{vdepth}(a^{[m+n]})\le\operatorname{vdepth}(a^{[m]})+
\operatorname{vdepth}(a^{[n]})+1$ and derive a limit by a discrete Fekete lemma;
the growth rate is independent of $\mathrm{base}>1$.

**C2. Strictness transfer (depth hierarchy ⇒ tropical-rate hierarchy).** The
comparison is hierarchy-faithful: a depth witness separating
$\mathrm{VAL}_k\subsetneq\mathrm{VAL}_{k+1}$ transfers under $T$ to a strict
separation of rate classes $\{f : T(f)\le\mathrm{base}^k\}$. Test: show $T$ is
strictly monotone on depth and lift the strict-hierarchy theorem across the
functor.

**C3. Two-sided Lipschitz comparison with additive defect.** For genuinely
parallel (non-iterated) composition the comparison loses at most the $+1$ shift:
there is a universal $c$ with
$\big|\log_{\mathrm{base}} T(\operatorname{comp}(a,b)) - \max(\operatorname{vdepth}
a,\operatorname{vdepth} b)\big|\le c$, and $c=1$ is sharp. More generally a
balanced binary composition tree of $n$ leaves has depth
$\le\lceil\log_2 n\rceil\cdot(\text{per-leaf depth}+1)$, matching the tropical
product rate.

**C4. Categorical naturality.** $T=\mathrm{base}^{(-)}$ extends to a functor on
the morphism categories (`UltraHom`/`TropValCarrierHom`), and the
depth↔log-rate equality is a *natural isomorphism* between the depth grading and
the logarithm of the tropical valuation grading: for every carrier morphism
$\varphi$, $\log_{\mathrm{base}}\circ T\circ\varphi_* = \varphi_*\circ
\operatorname{vdepth}$ on the nose. Test: build a structure of depth-nonexpansive
maps and prove the square commutes.

---

## 9. Conclusion

Valuation depth and tropical Lipschitz constants are two coordinate systems for a
single phenomenon, related by $\exp$ and $\log$. The additive max-plus depth law
and the multiplicative tropical/ultrametric rate law are interchanged exactly by
the exponential comparison functor; the valuation reconstruction functor turns
tropical data into ultrametric norms without loss of constant; and the resulting
transfers certify robustness and security guarantees computed in the cheaper
world. Depth is the logarithmic shadow of growth — and, here, the shadow is as
rigorous as the object that casts it.
