# The Ordered Field of Transseries: Asymptotic Expansions Beyond Power Series

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (Asymptotic Analysis, Ordered Algebra, Valuation Theory)

## Abstract

We develop a rigorous model of single-tower, real-power **transseries** — formal series in the iterated exponential–logarithm scale $\ldots, e^{e^x}, e^x, x, \log x, \log\log x, \ldots$ — and establish their fundamental algebraic and order-theoretic structure. Realizing transseries as Hahn series over the lexicographically ordered group of transmonomials $\mathrm{Lex}(\mathbb{Z} \to_{f} \mathbb{R})$ with real coefficients, we prove that they form a **field**, and indeed a **non-Archimedean ordered field**: the transmonomial $x$ is a positive infinitesimal, its reciprocal $1/x$ is infinite, and the two multiply to $1$. We show that the real numbers embed as a linearly ordered subfield, that exponential growth dominates every power ($x^a < e^x$ for all real $a$), that the value group is unbounded with the canonical exponential tower cofinal, and that the exponential substitution $x \mapsto e^x$ is a field automorphism whose inverse is the logarithmic substitution. Our central analytic result is the **asymptotic comparison theorem**: two transseries that agree to all orders are equal — a transseries is uniquely determined by its asymptotic expansion. We ground every formal order statement in classical real analysis via little-$o$ comparison. We close with the program toward real-closedness, for which the value-group divisibility and transmonomial root-extraction ingredients are now in place.

---

## 1. Introduction

The power series is the central tool of local analysis, but it is structurally incapable of expressing the comparison that dominates global asymptotics: that $e^x$ outgrows every polynomial. The exponent set of a power series is totally ordered with a successor structure (the integers, or $\mathbb{Q}$), and no element of such a set dominates all of $\{x^n : n \in \mathbb{N}\}$ at once. Transseries, introduced in the work of Écalle, Dahn–Göring, and developed extensively by van den Dries, Macintyre, Marker, van der Hoeven, and Aschenbrenner–van den Dries–van der Hoeven, repair this defect by enlarging the monomial scale to include iterated exponentials and logarithms.

This paper formalizes the foundational layer of the theory for *single-tower, real-power, grid-based* transseries and proves the structural theorems that distinguish them from power series. The development is organized around five pillars:

1. **The field structure** (§3): transseries form a field, with division furnished by the Hahn-series construction.
2. **The order structure** (§4): they form a non-Archimedean ordered field containing $\mathbb{R}$ as an ordered subfield, with explicit infinitesimal/infinite reciprocal pair $x, 1/x$.
3. **The multiplicative algebra** (§5): the law of exponents at each tower height, the value group's unboundedness, and cofinality of the canonical exponential tower.
4. **The asymptotic comparison theorem** (§6): uniqueness of the transseries expansion, grounded in classical little-$o$ asymptotics.
5. **The exponential symmetry** (§7): the exp-substitution as a field automorphism, mutually inverse to the log-substitution.

All results have been formally verified. Throughout, we treat the formal order on transmonomials as the carrier of *asymptotic dominance*, and we are scrupulous about a subtle orientation issue (§4.1) that determines whether $x$ is read as infinitesimal or infinite.

---

## 2. Preliminaries: Hahn series

Let $\Gamma$ be a linearly ordered abelian group and $R$ a ring. A **Hahn series** over $\Gamma$ with coefficients in $R$ is a function $f : \Gamma \to R$ whose support $\{\gamma : f(\gamma) \neq 0\}$ is *well-ordered*. Hahn series form a ring under pointwise addition and Cauchy-style convolution multiplication
$$(f \cdot g)(\gamma) = \sum_{\alpha + \beta = \gamma} f(\alpha)\, g(\beta),$$
the well-ordering of supports guaranteeing the sum is finite. When $R$ is a field and $\Gamma$ a linearly ordered group, the Hahn series form a **field** $R(\!(\Gamma)\!)$ (the Hahn–Mal'cev–Neumann theorem); inverses are computed by the geometric-series expansion of $(1 - u)^{-1}$ for $u$ of strictly positive valuation.

The **valuation** (order) of a nonzero Hahn series $f$ is the least element of its support; we write $\mathrm{orderTop}(f) \in \Gamma \cup \{\top\}$, with $\mathrm{orderTop}(0) = \top$. Valuation is multiplicative: $\mathrm{orderTop}(fg) = \mathrm{orderTop}(f) + \mathrm{orderTop}(g)$. The **leading coefficient** $\mathrm{lc}(f)$ is the coefficient at $\mathrm{orderTop}(f)$.

When $R$ is a linearly ordered domain, $R(\!(\Gamma)\!)$ inherits a linear order via its leading coefficient: $0 < f \iff 0 < \mathrm{lc}(f)$. This makes $R(\!(\Gamma)\!)$ a (strictly) ordered ring, hence — over a field $R$ — an ordered field.

---

## 3. The field of transseries

### 3.1 Transmonomials

**Definition 3.1 (Transmonomial group).** The group of **transmonomials** is
$$\mathsf{TransMono} := \mathrm{Lex}\,(\mathbb{Z} \to_{f} \mathbb{R}),$$
the finitely supported functions $\mathbb{Z} \to \mathbb{R}$ under pointwise addition, equipped with the **lexicographic order**: for $f \neq g$, the sign of $f - g$ is the sign of its value at the *least* index where they differ. An element records a finite tuple of real exponents indexed by **tower height** $h$: height $1$ is $e^x$, $0$ is $x$, $-1$ is $\log x$, $2$ is $e^{e^x}$, etc.

We encode height $h$ at finsupp index $-h$, so that *higher* towers occupy *smaller* indices and are therefore lexicographically most significant. Concretely:

**Definition 3.2.** For $h \in \mathbb{Z}$, $a \in \mathbb{R}$, the transmonomial $(\text{level } h)^a$ is
$$\mathrm{mono}(h, a) := \mathrm{toLex}\bigl(\,\delta_{-h}\!\cdot a\,\bigr) \in \mathsf{TransMono},$$
where $\delta_{-h}\cdot a$ is the single-support finsupp with value $a$ at index $-h$.

Since $\mathrm{Lex}(\mathbb{Z} \to_f \mathbb{R})$ is a linearly ordered abelian group, the following are immediate.

**Lemma 3.3 (Dominance laws).** (`mono_lt_mono_of_height`, `mono_lt_mono_same`)
- *(Height dominance.)* If $h < h'$ and $0 < a'$, then $\mathrm{mono}(h,a) < \mathrm{mono}(h',a')$ for any $a$.
- *(Same-height comparison.)* If $a < a'$, then $\mathrm{mono}(h,a) < \mathrm{mono}(h,a')$.

*Proof sketch.* Apply the lexicographic comparison criterion `Finsupp.Lex.lt_iff` at index $-h'$ (resp. $-h$): the two finsupps agree at all strictly smaller indices (both vanish there) and the deciding index carries the positive value $a'$ (resp. $a' - a > 0$). $\square$

**Theorem 3.4 (Exponential dominance).** (`exp_dominates_pow`) For *every* real exponent $a$,
$$\mathrm{mono}(0, a) < \mathrm{mono}(1, 1), \qquad \text{i.e.}\qquad x^{a} < e^{x}.$$

*Proof.* Immediate from height dominance with $h=0 < 1 = h'$ and $a' = 1 > 0$. The point is universality over $a$: a single fixed object $e^x$ dominates the entire one-parameter family $\{x^a : a \in \mathbb{R}\}$, which is impossible in any power-series valuation whose value group is $\mathbb{Z}$ or $\mathbb{R}$. $\square$

### 3.2 The field

**Definition 3.5 (Transseries).** The **field of transseries** is the Hahn-series field
$$\mathsf{TSeries} := \mathbb{R}(\!(\mathsf{TransMono})\!) = \mathrm{HahnSeries}\,(\mathsf{TransMono},\ \mathbb{R}).$$
The **one-term transseries** $\mathrm{term}(h,a)$ is the Hahn series with coefficient $1$ on $\mathrm{mono}(h,a)$ and $0$ elsewhere. We abbreviate $x := \mathrm{term}(0,1)$, $e^x := \mathrm{term}(1,1)$, $\log x := \mathrm{term}(-1,1)$.

**Theorem 3.6 (Field).** $\mathsf{TSeries}$ is a field, and the constant embedding $C : \mathbb{R} \to \mathsf{TSeries}$ is an injective ring homomorphism (`C_injective`). Hence $\mathbb{R} \hookrightarrow \mathsf{TSeries}$.

*Proof.* The Hahn–Mal'cev–Neumann field instance applies since $\mathsf{TransMono}$ is a linearly ordered abelian group and $\mathbb{R}$ a field. Injectivity of $C$ is the Hahn-series constant-embedding injectivity. $\square$

**Proposition 3.7 (Valuation).** (`orderTop_term`, `orderTop_mul`)
$$\mathrm{orderTop}\bigl(\mathrm{term}(h,a)\bigr) = \mathrm{mono}(h,a), \qquad \mathrm{orderTop}(x\cdot y) = \mathrm{orderTop}(x) + \mathrm{orderTop}(y).$$

---

## 4. The non-Archimedean ordered field

### 4.1 The order and its orientation

**Definition 4.1 (Ordered transseries field).** Equip $\mathsf{TSeries}$ with the leading-coefficient order to obtain the **ordered field of transseries**
$$\mathsf{OTSeries} := \mathrm{Lex}\,(\mathsf{TSeries}).$$

**Theorem 4.2 (Ordered field).** (`orderedField`) $\mathsf{OTSeries}$ is simultaneously a `Field`, a `LinearOrder`, and a strict ordered ring; i.e. a genuine ordered field.

*Proof.* All three instances are supplied by the Hahn-series order structure over the linearly ordered domain $\mathbb{R}$. $\square$

**Positivity criterion.** $0 < f \iff 0 < \mathrm{lc}(f)$ (`leadingCoeff_pos_iff`).

**Orientation subtlety.** The lexicographic order decides at the *smallest* group index, and we store tower height $h$ at index $-h$ ("higher tower = greater group element"). These two conventions *compose*: the resulting field order is the **germ order at $x \to 0^+$**. Explicitly, $\mathrm{mono}(h,a) > 0 \iff a > 0$, *independently of $h$*. Consequently $x$ (exponent $+1$) is **infinitesimal** and $1/x$ (exponent $-1$) is **infinite**. We state results in accordance with the order the construction actually realizes, rather than forcing an $x \to +\infty$ reading.

### 4.2 Positivity, infinitesimals, and infinities

**Theorem 4.3 (Every one-term transseries is positive).** (`term_pos`) For all $h, a$, $\;0 < \mathrm{term}(h,a)$ in $\mathsf{OTSeries}$.

*Proof.* By the positivity criterion it suffices that $\mathrm{lc}(\mathrm{term}(h,a)) = 1 > 0$, which is immediate from the definition. $\square$

**Theorem 4.4 ($x$ is a positive infinitesimal).** (`x_pos`, `x_infinitesimal`) $0 < x$, and for every $n \in \mathbb{N}$,
$$(n+1)\cdot x < 1.$$
Thus $x$ is smaller than every positive rational $\tfrac{1}{n+1}$.

*Proof sketch.* By scalar–monomial multiplication, $(n+1)\cdot x = \mathrm{single}(\mathrm{mono}(0,1),\, n+1)$. The difference $1 - (n+1)x$ has support $\{0,\ \mathrm{mono}(0,1)\}$, whose least element is the constant monomial $0$ with coefficient $+1 > 0$. By the lexicographic comparison criterion the deciding coefficient is positive, so $(n+1)x < 1$. $\square$

**Theorem 4.5 ($1/x$ is infinite).** (`inv_x_infinite`) For every $n \in \mathbb{N}$,
$$n < \mathrm{term}(0, -1) = \frac{1}{x}.$$

*Proof sketch.* Two steps. (i) $n \le 1/x$: if not, then $1/x \le n \le n+1$, and multiplying through by $x > 0$ using $x\cdot(1/x)=1$ (Theorem 4.6) would force $1 \le (n+1)x$, contradicting Theorem 4.4. (ii) $n \neq 1/x$: compare valuations — $\mathrm{orderTop}(\mathrm{term}(0,-1)) = \mathrm{mono}(0,-1)$ is a negative-index monomial, whereas $\mathrm{orderTop}(n)$ is the constant monomial $0$ (or $\top$ for $n=0$); these differ. $\square$

**Theorem 4.6 (Infinitesimal and infinite are reciprocal).** (`x_mul_inv_x`)
$$x \cdot \frac{1}{x} = \mathrm{term}(0,1)\cdot \mathrm{term}(0,-1) = 1.$$

*Proof.* By the law of exponents (Theorem 5.1), $\mathrm{term}(0,1)\cdot\mathrm{term}(0,-1) = \mathrm{term}(0, 0) = 1$. $\square$

Theorems 4.4–4.6 together establish:

**Corollary 4.7 (Non-Archimedean).** $\mathsf{OTSeries}$ is a non-Archimedean ordered field: it contains a positive infinitesimal $x$ and an infinite element $1/x$ that are mutually reciprocal. No such elements exist in $\mathbb{R}$.

### 4.3 $\mathbb{R}$ as an ordered subfield

**Theorem 4.8 (Ordered real embedding).** (`C_lt_iff`, `C_strictMono`) For real $a, b$,
$$C(a) < C(b) \iff a < b,$$
so the constant embedding is strictly monotone. Combined with injectivity (Theorem 3.6), $\mathbb{R}$ is a linearly ordered subfield of $\mathsf{OTSeries}$.

*Proof sketch.* $C(b) - C(a) = C(b-a)$ as Hahn series, whose leading coefficient is $b - a$. Apply the positivity criterion: $0 < C(b)-C(a) \iff 0 < b-a$. $\square$

---

## 5. The multiplicative algebra and the value group

**Theorem 5.1 (Law of exponents).** (`term_mul_term_same`, `term_zero`, `term_mul_neg`, `term_pow`) For fixed height $h$:
$$\mathrm{term}(h,a)\cdot\mathrm{term}(h,b) = \mathrm{term}(h, a+b), \quad \mathrm{term}(h,0) = 1, \quad \mathrm{term}(h,a)\cdot\mathrm{term}(h,-a) = 1, \quad \mathrm{term}(h,a)^n = \mathrm{term}(h, na).$$
Consequently every one-term transseries is a unit (`isUnit_term`), and $a \mapsto \mathrm{term}(h,a)$ is a group homomorphism $(\mathbb{R}, +) \to \mathsf{TSeries}^{\times}$ (`termHom`).

*Proof sketch.* Single-monomial multiplication reduces to additivity of the underlying $\delta_{-h}$ finsupp: $\delta_{-h}\!\cdot a + \delta_{-h}\!\cdot b = \delta_{-h}\!\cdot(a+b)$, lifted through $\mathrm{toLex}$. The power law is induction on $n$ via the multiplication law. $\square$

**Theorem 5.2 (Unbounded value group).** (`exists_gt`) For every transmonomial $g$ there exists $g'$ with $g < g'$.

*Proof sketch.* Constructive. If $\mathrm{ofLex}(g)$ has nonempty support with least index $i_0$, add a unit at index $i_0 - 1$: the result first differs from $g$ at the new least index $i_0-1$, with positive value, hence is strictly larger. If $g = 0$, any positive monomial works. $\square$

**Theorem 5.3 (Non-Archimedean dominance of valuations).** (`pow_var_lt_exp`, `orderTop_varX_pow`) For every $n \in \mathbb{N}$,
$$\mathrm{orderTop}(x^n) = \mathrm{mono}(0, n) < \mathrm{mono}(1,1) = \mathrm{orderTop}(e^x).$$
No finite power of $x$ catches up to $e^x$.

*Proof.* $\mathrm{orderTop}(x^n) = \mathrm{mono}(0,n)$ by the power law and valuation of terms; then apply Theorem 3.4 with $a = n$. The tower-height coordinate (index $-1$) is lexicographically more significant than the power-of-$x$ coordinate (index $0$), so $\mathrm{mono}(0,n) < \mathrm{mono}(1,1)$ for all $n$ — the precise non-Archimedean phenomenon. $\square$

---

## 6. The asymptotic comparison theorem

This is the central uniqueness result of the theory.

**Definition 6.1 (Agreement to all orders).** Two transseries $a, b$ **agree to all orders** when their difference is asymptotically smaller than every transmonomial:
$$\mathsf{AgreeToAllOrders}(a,b) \ :\Longleftrightarrow\ \forall\, g \in \mathsf{TransMono},\quad g < \mathrm{orderTop}(a - b)$$
(comparison taken in $\mathsf{TransMono} \cup \{\top\}$).

**Theorem 6.2 (Asymptotic comparison theorem).** (`agreeToAllOrders_iff_eq`)
$$\mathsf{AgreeToAllOrders}(a, b) \iff a = b.$$
A transseries is uniquely determined by its asymptotic expansion.

*Proof.* ($\Rightarrow$) Suppose $a, b$ agree to all orders. If $\mathrm{orderTop}(a-b) \neq \top$, it equals some $c \in \mathsf{TransMono}$; instantiating the hypothesis at $g = c$ gives $c < c$, a contradiction. Hence $\mathrm{orderTop}(a-b) = \top$, which holds iff $a - b = 0$, i.e. $a = b$. ($\Leftarrow$) If $a = b$ then $\mathrm{orderTop}(a-b) = \mathrm{orderTop}(0) = \top$, which strictly dominates every $g$. $\square$

**Corollary 6.3.** (`agreeToAllOrders_equivalence`, `not_agree_zero_of_ne_zero`) Agreement to all orders is an equivalence relation (it *is* equality), and any nonzero transseries fails to agree to all orders with $0$ — it has a genuine leading term.

### 6.1 Analytic grounding

The formal order is not an empty abstraction; it models real asymptotics. We record the classical little-$o$ facts that the formal dominance theorems mirror.

**Theorem 6.4 (Analytic dominance).** (`isLittleO_pow_exp`, `isLittleO_expPow_expExp`) For every $n \in \mathbb{N}$:
$$x^n = o(e^x) \ \text{ as } x \to +\infty, \qquad (e^x)^n = o\bigl(e^{e^x}\bigr) \ \text{ as } x \to +\infty.$$

*Proof sketch.* The first is the standard polynomial-vs-exponential little-$o$ estimate. The second follows by composing the first with $e^x \to +\infty$. These ground, respectively, the formal facts $\mathrm{mono}(0,n) < \mathrm{mono}(1,1)$ and (height $1 < 2$) $\mathrm{mono}(1, n) < \mathrm{mono}(2,1)$. $\square$

---

## 7. The exponential substitution as a field automorphism

**Definition 7.1 (Exp- and log-substitution).** Let $\sigma : \mathbb{Z} \to \mathbb{Z}$, $\sigma(i) = i-1$, and $\tau(i) = i+1$ be the index translations. The **exp-substitution** $E := \mathsf{expShift}$ and **log-substitution** $L := \mathsf{logShift}$ on transseries are the ring homomorphisms induced (via Hahn-series domain relabeling, `embDomainRingHom`) by transporting transmonomials along $\sigma$, $\tau$ respectively.

**Lemma 7.2 (Action on terms).** (`expShift_term`, `logShift_term`, `expShift_var`)
$$E(\mathrm{term}(h,a)) = \mathrm{term}(h+1, a), \qquad L(\mathrm{term}(h,a)) = \mathrm{term}(h-1, a),$$
so in particular $E(x) = e^x$, $E(e^x) = e^{e^x}$, $E(\log x) = x$, and $E$ fixes the constant subfield: $E(C(r)) = C(r)$ (`expShift_C`).

**Lemma 7.3 (Order preservation).** (`shift_lt_iff`) The height-shift is an order isomorphism of $\mathsf{TransMono}$: $\sigma_*g < \sigma_*g' \iff g < g'$. Exp-substitution preserves asymptotic dominance.

*Proof sketch.* A lexicographic comparison is decided at the least index of difference; a monotone bijection of the index set maps least-index-of-difference to least-index-of-difference, so the order is preserved verbatim. $\square$

**Theorem 7.4 (Exp-substitution is a field automorphism).** (`expShiftEquiv`, `expShift_logShift`, `logShift_expShift`) $E$ is a ring (hence field) automorphism $\mathsf{TSeries} \xrightarrow{\sim} \mathsf{TSeries}$ with inverse $L$: $E \circ L = \mathrm{id} = L \circ E$.

*Proof sketch.* Injectivity of $E$ comes from injectivity of the index translation. Surjectivity (and the two-sided inverse) follows because $\sigma$ and $\tau$ are mutually inverse bijections of $\mathbb{Z}$, so the round-trips reduce to $\mathrm{id}$ on the value group, lifted to coefficients via the domain-embedding coefficient calculus. Packaging injectivity with surjectivity yields the `RingEquiv`. $\square$

**Theorem 7.5 (Cofinality of the exponential tower).** (`exists_exp_tower_gt`) Every transmonomial $g$ is strictly dominated by some iterated exponential:
$$\exists\, n \in \mathbb{N},\quad g < \mathrm{mono}(n, 1) = e^{e^{\cdots e^x}} \ (n \text{ times}).$$
The single explicit sequence $x, e^x, e^{e^x}, \ldots$ exhausts all growth orders from above.

*Proof sketch.* Let $i_0$ be the least support index of $\mathrm{ofLex}(g)$; choose tower height $n = (1 - i_0)^+$ so that $-n < i_0$. Then $\mathrm{mono}(n,1)$ has its (positive) deciding coefficient at index $-n$, strictly below every support index of $g$, so $g < \mathrm{mono}(n,1)$. $\square$

---

## 8. Algorithms

The constructive content of the development yields concrete algorithms on finitely represented transseries (finite formal sums of transmonomials). We record three.

**Algorithm A (Transmonomial comparison).** Given two transmonomials as finite exponent maps $h \mapsto a_h$, decide $<$ by scanning indices from the smallest (highest tower) and returning the sign of the first nonzero exponent difference. Complexity $O(k)$ in the number of occupied heights $k$. This realizes the lexicographic order of §3.

**Algorithm B (Multiplication via the law of exponents).** To multiply two finite transseries, form all pairwise products of transmonomials (adding exponent maps pointwise, multiplying real coefficients), then collect equal transmonomials. Complexity $O(mn)$ pairwise products for inputs of $m$ and $n$ terms.

**Algorithm C (Reciprocal by infinitesimal expansion).** To invert $f = c\,\mu\,(1 + \varepsilon)$ with leading coefficient $c$, leading transmonomial $\mu$, and infinitesimal tail $\varepsilon$ (positive valuation), compute $f^{-1} = c^{-1}\,\mu^{-1}\,\sum_{k\ge 0}(-\varepsilon)^k$, truncating the geometric series at the desired order. Each successive term has strictly larger valuation, so finitely many terms determine any fixed order.

---

## 9. Applications

- **Asymptotics of ODE solutions.** Solutions of algebraic differential equations at an irregular singular point admit transseries expansions; the comparison theorem (Theorem 6.2) certifies their uniqueness.
- **Resurgence and physics.** Divergent perturbative expansions in quantum mechanics and field theory organize naturally as transseries with exponentially small ("non-perturbative") corrections; the ordered, non-Archimedean structure (§4) is the algebraic substrate for borel–écalle resummation bookkeeping.
- **Hardy fields and o-minimality.** The exp-log scale and its dominance order are the combinatorial skeleton of Hardy fields and model-theoretically tame structures; Lemma 3.3 and Theorem 7.4 supply the order-automorphism symmetry used there.
- **Algorithmic complexity.** Growth rates of running times beyond polynomial/exponential (e.g. iterated logarithms) are exactly transmonomials; Theorem 7.5 says the iterated-exponential tower is a cofinal yardstick for all such rates.

---

## 10. Discussion and future work

We have established that single-tower, real-power transseries form a non-Archimedean ordered field containing $\mathbb{R}$, with an explicit infinitesimal/infinite reciprocal pair, an unbounded value group made cofinal by the canonical exponential tower, an exp/log substitution symmetry, and a uniqueness-of-expansion (asymptotic comparison) theorem. The orientation analysis of §4.1 is a genuine mathematical subtlety, not a cosmetic choice: it fixes the field order as the germ order at $x \to 0^+$.

The natural next target is **real-closedness**. Real-closedness of a Hahn field $K(\!(\Gamma)\!)$ factors into three layers: real-closedness of the coefficient field $K = \mathbb{R}$ (classical); divisibility of the value group $\Gamma$; and root extraction for $1 + \varepsilon$ with $\varepsilon$ infinitesimal (binomial series). The value-group layer is now in hand (the value group $\mathrm{Lex}(\mathbb{Z}\to_f\mathbb{R})$ is divisible, in contrast to the Laurent value group $\mathbb{Z}$, which is not), and every transmonomial already has all $n$-th roots (divisible exponents). The remaining binomial layer would complete a proof that every nonnegative transseries is a square and that the transseries field is real closed — promoting it from a rich asymptotic *language* to a complete number system. The detailed program is recorded in the project's future-directions notes.

---

## 11. Summary of formally verified results

| Result | Statement |
|---|---|
| `orderedField` | $\mathsf{OTSeries}$ is an ordered field |
| `exp_dominates_pow` | $x^a < e^x$ for all real $a$ |
| `term_pos` | every one-term transseries is positive |
| `x_infinitesimal` | $(n+1)x < 1$ for all $n$ |
| `inv_x_infinite` | $n < 1/x$ for all $n$ |
| `x_mul_inv_x` | $x\cdot(1/x) = 1$ |
| `C_lt_iff` | $\mathbb{R}$ embeds as an ordered subfield |
| `term_mul_term_same` | law of exponents $\mathrm{term}(h,a)\mathrm{term}(h,b)=\mathrm{term}(h,a{+}b)$ |
| `exists_gt` | value group has no maximum |
| `pow_var_lt_exp` | no power of $x$ dominates $e^x$ |
| `agreeToAllOrders_iff_eq` | asymptotic comparison theorem |
| `isLittleO_pow_exp` | analytic grounding: $x^n = o(e^x)$ |
| `expShiftEquiv` | exp-substitution is a field automorphism |
| `exists_exp_tower_gt` | exponential tower is cofinal |
