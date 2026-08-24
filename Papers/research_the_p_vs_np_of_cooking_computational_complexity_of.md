# The Computational Complexity of Recipes: A Query-Theoretic Model of Cooking and Tasting

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

The slogan "a recipe is an algorithm, so the cost of cooking versus the cost of tasting is
$\mathrm{P}$ versus $\mathrm{NP}$" is usually left as a metaphor. We make it a theorem. We fix a
computational model — the deterministic adaptive decision-tree (query) model on Boolean pantries —
in which cooking means handling all $n$ ingredients and tasting means adaptively probing individual
ingredients of the finished dish. Within this model we prove: (i) tasting is never more expensive
than cooking, $V(R) \le C(R)$; (ii) a sensitivity lower bound on tasting time; (iii) an
*unconditional* separation of deterministic from nondeterministic verification, realised by the
"some ingredient is spoiled" dish, which admits one-probe badness certificates yet requires $n$
probes deterministically; (iv) a two-sided certificate hardness theorem for the parity ("soufflé")
dish, whose every certificate at every pantry is the entire pantry; (v) full realisation of the
verification spectrum, so that every ratio $C/V = n/k$ occurs; (vi) an *inversion* of the naive
conjecture — break-even recipes $C = V$ are exactly the evasive, maximally hard dishes, while the
easiest dishes attain the extreme ratio $C/V = n$; (vii) a counting theorem showing that at most
$(6n)^{2^d}$ of the $2^{2^n}$ dishes are tastable in $d$ probes, so that almost every recipe is a
soufflé; (viii) an unconditional adaptivity gap; and (ix) a product bound $D(f) \le C_0(f)\,C_1(f)$
— in the kitchen, $\mathrm{NP} \cap \mathrm{co\text{-}NP}$ collapses to $\mathrm{P}$ at the cost of
squaring. We also carry out, exactly, a census of one hundred recipes whose aggregate cook/taste
ratio is $200/101$. We explicitly do *not* claim any Navier–Stokes or $\mathrm{PSPACE}$ content for
the soufflé: the honest combinatorial shadow of that claim is theorem (iv).

**Keywords:** query complexity, decision trees, sensitivity, certificate complexity, evasiveness,
adaptivity gap, P vs NP, recipe complexity.

---

## 1. Introduction

### 1.1 The metaphor and its cost

Every recipe is an algorithm. It consumes inputs (ingredients), performs a sequence of operations,
and produces an output (a dish). It is therefore tempting to ask the question that defines modern
complexity theory: is *producing* a good dish harder than *recognising* one? Writing $C(R)$ for the
cooking time of a recipe $R$ and $V(R)$ for the time needed to determine whether the finished dish
is good, the question reads: is $C(R) > V(R)$?

Left at that level of generality the question is vacuous, because "time" has no meaning until a
computational model is fixed. Worse, the analogy invites overreach. A commonly repeated version of
the claim asserts that soufflé verification is $\mathrm{co}\text{-}\mathrm{NP}$-hard "because
determining whether the soufflé rises requires simulating Navier–Stokes, which is
$\mathrm{PSPACE}$-hard." No amount of culinary data supports such a statement: it presupposes a
physical model, a discretisation, and a reduction, none of which is available. We therefore adopt a
different discipline. We choose the most restrictive model in which the intended phenomena are
genuinely *provable*, we prove them, and we mark precisely where the metaphor breaks.

### 1.2 The model in one paragraph

A **pantry** of $n$ ingredients is a Boolean vector $x \in \{0,1\}^n$; coordinate $x_i$ records the
binary state of ingredient $i$ (fresh/spoiled, whipped/flat, folded/beaten). A **dish** is a Boolean
function $f : \{0,1\}^n \to \{0,1\}$, where $f(x) = 1$ means "this pantry cooks up to something
good." **Cooking** means touching every ingredient, so $C(R) := n$. **Tasting** is modelled by an
adaptive decision tree: probe one coordinate of the finished dish, observe its value, and use the
observation to choose the next probe; eventually announce a verdict. $V(R)$ is the minimum
worst-case depth of a decision tree computing $f$. **Nondeterministic verification** — a garnish
pointing at what to taste — is certificate complexity.

This is the standard deterministic query model. Its virtue is that its separations are theorems
rather than conjectures, so the kitchen analogy can be made load-bearing.

### 1.3 Summary of results

| Result | Statement |
|---|---|
| Path Lemma | A taster probes at most $\mathrm{depth}$ coordinates, and its verdict depends only on those. |
| Cook dominates taste | $V(R) \le C(R) = n$ for every dish. |
| Sensitivity bound | $s(f,x) \le V(R)$ for every pantry $x$. |
| Triviality | $V(R) = 0$ iff $f$ is constant. |
| Kitchen $\mathrm{P} \ne \mathrm{NP}$ | $\mathrm{OR}_n$ has one-probe certificates at all $1$-inputs but $V = n$. |
| Soufflé theorem | Every certificate of $\mathrm{PARITY}_n$ at every input is all of $[n]$. |
| Spectrum | For each $k \le n$ there is a dish with $V = k$ exactly; every ratio $n/k$ occurs. |
| Inversion | For non-constant $f$: $C/V = 1$ iff $f$ is evasive. |
| Menu rigidity | A finite menu is aggregate break-even iff every dish on it is evasive. |
| Census | The hundred-recipe menu has aggregate ratio exactly $200/101$. |
| Rarity | At most $2n+2$ dishes have $V \le 1$; at most $(6n)^{2^d}$ have $V \le d$. |
| Generic hardness | With $n = 16$, at least half of all dishes need more than $7$ probes. |
| Adaptivity gap | The multiplexer needs a $3$-item fixed checklist but only $2$ adaptive probes. |
| Product bound | $V \le C_0 \cdot C_1$; in particular $V \le c^2$ if all certificates have size $\le c$. |

---

## 2. The model

### 2.1 Pantries, dishes, tasters

**Definition 2.1 (Pantry, dish).** For $n \in \mathbb{N}$, a *pantry* is a function
$x : \{1,\dots,n\} \to \{0,1\}$, written $x \in \{0,1\}^n$. A *dish* is a function
$f : \{0,1\}^n \to \{0,1\}$.

**Definition 2.2 (Tasting strategy).** A *tasting strategy* (or *taster*) on $n$ ingredients is a
finite binary tree $T$ generated by the grammar
$$T ::= \mathsf{serve}(b) \ \mid\ \mathsf{probe}(i,\ T_0,\ T_1), \qquad b \in \{0,1\},\ i \in \{1,\dots,n\}.$$
Its *depth* is $\mathrm{depth}(\mathsf{serve}(b)) = 0$ and
$\mathrm{depth}(\mathsf{probe}(i,T_0,T_1)) = 1 + \max(\mathrm{depth}(T_0), \mathrm{depth}(T_1))$.
Its *evaluation* on a pantry $x$ is $\mathrm{ev}(\mathsf{serve}(b), x) = b$ and
$\mathrm{ev}(\mathsf{probe}(i,T_0,T_1), x) = \mathrm{ev}(T_{x_i}, x)$. Its *path* at $x$ is the set of
probed coordinates: $\mathrm{path}(\mathsf{serve}(b),x) = \varnothing$ and
$\mathrm{path}(\mathsf{probe}(i,T_0,T_1),x) = \{i\} \cup \mathrm{path}(T_{x_i},x)$.

We say $T$ *computes* $f$ if $\mathrm{ev}(T,x) = f(x)$ for all $x$.

**Definition 2.3 (Cooking and verification time).** For a dish $f$ on $n$ ingredients,
$$C(f) := n, \qquad V(f) := \min\{\mathrm{depth}(T) : T \text{ computes } f\}.$$
$V(f)$ is the standard deterministic query complexity $D(f)$; we use the two notations
interchangeably. The minimum is attained: there is always an *optimal taster* of depth exactly
$V(f)$.

### 2.2 The path lemma

Everything below rests on two facts, each proved by induction on the tree.

**Lemma 2.4 (Path lemma, part 1).** For every taster $T$ and every pantry $x$,
$|\mathrm{path}(T,x)| \le \mathrm{depth}(T)$.

*Proof sketch.* Induction. A leaf probes nothing. At $\mathsf{probe}(i,T_0,T_1)$ the path is
$\{i\}$ together with the path of the taken subtree, so its size is at most
$1 + \max_b |\mathrm{path}(T_b, x)| \le 1 + \max_b \mathrm{depth}(T_b) = \mathrm{depth}(T)$. $\square$

**Lemma 2.5 (Path lemma, part 2).** If $y_i = x_i$ for every $i \in \mathrm{path}(T,x)$, then
$\mathrm{ev}(T,y) = \mathrm{ev}(T,x)$.

*Proof sketch.* Induction. At $\mathsf{probe}(i,T_0,T_1)$ we have $i \in \mathrm{path}(T,x)$, so
$y_i = x_i$ and both evaluations descend into the same subtree; the remaining path agreement is
exactly the inductive hypothesis for that subtree. $\square$

Together: *a taster sees at most $\mathrm{depth}$ ingredients, and its verdict is a function of
what it saw.* Every lower bound in this paper is an application of Lemma 2.5.

### 2.3 Brute force: tasting never costs more than cooking

**Definition 2.6 (Exhaustive taster).** Fix a default pantry $a$. Define $B_0(a) := \mathsf{serve}(f(a))$
and, for $k < n$, $B_{k+1}(a) := \mathsf{probe}(k, B_k(a[k \mapsto 0]), B_k(a[k \mapsto 1]))$.

**Lemma 2.7.** $\mathrm{depth}(B_k(a)) \le k$ and
$\mathrm{ev}(B_k(a), x) = f\big(j \mapsto \text{if } j < k \text{ then } x_j \text{ else } a_j\big)$.

**Theorem 2.8 (Tasting never exceeds cooking).** $V(f) \le C(f) = n$ for every dish $f$.

*Proof.* $B_n(a)$ has depth at most $n$ and, by Lemma 2.7 with $k = n$, evaluates to $f(x)$ for
every $x$. $\square$

This is the trivial half of the metaphor and it is genuinely true: you can always verify a dish by
redoing the amount of work it took to make it, and never more.

---

## 3. Sensitivity: the universal lower bound

**Definition 3.1 (Pivotal ingredient, sensitivity).** Ingredient $i$ is *pivotal* for $f$ at $x$ if
$f(x^{\oplus i}) \ne f(x)$, where $x^{\oplus i}$ is $x$ with coordinate $i$ flipped. The *pivotal
set* is $\mathrm{piv}(f,x) := \{i : i \text{ pivotal at } x\}$, and $s(f,x) := |\mathrm{piv}(f,x)|$
is the sensitivity of $f$ at $x$.

**Theorem 3.2 (Pivotal ingredients must be probed).** If $T$ computes $f$ and $i$ is pivotal at $x$,
then $i \in \mathrm{path}(T,x)$.

*Proof.* Suppose not. Put $y := x^{\oplus i}$. Then $y$ agrees with $x$ on all of
$\mathrm{path}(T,x)$, since the only disagreement is at $i \notin \mathrm{path}(T,x)$. By Lemma 2.5,
$\mathrm{ev}(T,y) = \mathrm{ev}(T,x)$, hence $f(y) = f(x)$, contradicting pivotality. $\square$

**Corollary 3.3 (Sensitivity lower bound).** For every dish $f$ and pantry $x$, $s(f,x) \le V(f)$.

*Proof.* Take an optimal taster $T$. By Theorem 3.2, $\mathrm{piv}(f,x) \subseteq \mathrm{path}(T,x)$,
and by Lemma 2.4, $|\mathrm{path}(T,x)| \le \mathrm{depth}(T) = V(f)$. $\square$

**Theorem 3.4 (Zero-probe verdicts).** $V(f) = 0$ if and only if $f$ is constant.

*Proof.* If $V(f) = 0$ the optimal taster is a leaf $\mathsf{serve}(b)$, so $f \equiv b$. Conversely
a constant is computed by a leaf. $\square$

In culinary terms: *you cannot judge a dish without tasting it*, unless its quality was decided
before you started cooking.

---

## 4. Three model dishes

### 4.1 Salad: the dictator

**Definition 4.1.** The *salad* $\mathrm{sal}_i(x) := x_i$.

**Proposition 4.2.** $V(\mathrm{sal}_i) = 1$.

*Proof.* The taster $\mathsf{probe}(i, \mathsf{serve}(0), \mathsf{serve}(1))$ computes it with depth
$1$. It is not constant (compare the all-ones and all-zeros pantries), so by Theorem 3.4 its cost is
not $0$. $\square$

Thus $C/V = n$: the salad realises the maximal possible discount of tasting over cooking.

### 4.2 The spoiled-ingredient dish and the kitchen separation

**Definition 4.3.** $\mathrm{spoiled}(x) := 1$ iff $x_i = 1$ for some $i$ (the OR function; here
$x_i = 1$ encodes "ingredient $i$ is spoiled", and the "verdict" is the alarm).

**Definition 4.4 (Certificate).** A set $S \subseteq \{1,\dots,n\}$ is a *certificate* for $f$ at $x$
if every $y$ agreeing with $x$ on $S$ satisfies $f(y) = f(x)$. The certificate complexity of $f$ at
$x$ is the least size of such an $S$; $C_1(f)$ and $C_0(f)$ denote the maxima over $1$-inputs and
$0$-inputs respectively.

**Proposition 4.5 (Nondeterminism is at least as fast).** For every $f$ and $x$ there is a
certificate of size at most $V(f)$ — namely $\mathrm{path}(T,x)$ for an optimal taster $T$.

*Proof.* By Lemma 2.5, any $y$ agreeing with $x$ on $\mathrm{path}(T,x)$ has
$f(y) = \mathrm{ev}(T,y) = \mathrm{ev}(T,x) = f(x)$; the size bound is Lemma 2.4. $\square$

**Proposition 4.6 (Certificates contain pivotal ingredients).** If $S$ is a certificate for $f$ at
$x$, then $\mathrm{piv}(f,x) \subseteq S$.

*Proof.* If $i \notin S$ were pivotal, then $x^{\oplus i}$ agrees with $x$ on $S$, so
$f(x^{\oplus i}) = f(x)$ — contradiction. $\square$

**Proposition 4.7.** If $x_i = 1$ then $\{i\}$ is a certificate for $\mathrm{spoiled}$ at $x$; and at
the all-fresh pantry $\mathbf{0}$ every ingredient is pivotal, so $\mathrm{piv} = \{1,\dots,n\}$.

**Theorem 4.8.** $V(\mathrm{spoiled}) = n$.

*Proof.* $\le$ is Theorem 2.8. $\ge$ follows from Corollary 3.3 applied at $\mathbf 0$, where the
sensitivity is $n$ by Proposition 4.7. $\square$

**Theorem 4.9 (Kitchen $\mathrm{P} \ne \mathrm{NP}$; unconditional).** Let $n \ge 2$. At every pantry
with $\mathrm{spoiled}(x) = 1$ there is a certificate of size exactly $1$, while every deterministic
taster for $\mathrm{spoiled}$ needs $n$ probes. Hence $1 = C_1(\mathrm{spoiled}) < V(\mathrm{spoiled}) = n$.

*Proof.* Combine Propositions 4.7 and Theorem 4.8. $\square$

This is the entire content of "$\mathrm{P}$ versus $\mathrm{NP}$ in the kitchen", and unlike the
Turing-machine statement it is a theorem. A hint — a garnish pointing at the guilty ingredient —
compresses verification from $n$ probes to one, and the gap is unbounded in $n$.

### 4.3 The soufflé: parity, hard from both sides

**Definition 4.10.** The *soufflé* $\mathrm{souf}(x) := \bigoplus_{i} x_i$: it rises exactly when an
odd number of the $n$ critical steps went right.

**Lemma 4.11.** For every $x$ and every $i$, $\mathrm{souf}(x^{\oplus i}) \ne \mathrm{souf}(x)$.

*Proof.* Split the weight $\sum_j x_j$ as $x_i + \sum_{j \ne i} x_j$; flipping $x_i$ changes the
first summand by $\pm 1$ and leaves the second fixed, so it changes the parity. $\square$

**Theorem 4.12 (Evasiveness of the soufflé).** $\mathrm{piv}(\mathrm{souf},x) = \{1,\dots,n\}$ for
every $x$, and hence $V(\mathrm{souf}) = n = C(\mathrm{souf})$.

**Theorem 4.13 (Soufflé Theorem: no nondeterministic shortcut).** Every certificate for
$\mathrm{souf}$ at every pantry is the whole ingredient set. Consequently
$C_0(\mathrm{souf}) = C_1(\mathrm{souf}) = n$.

*Proof.* By Proposition 4.6 a certificate contains $\mathrm{piv}(\mathrm{souf},x) = \{1,\dots,n\}$,
and it is a subset of $\{1,\dots,n\}$. $\square$

This is the defensible replacement for the informal "soufflé verification is
$\mathrm{co}\text{-}\mathrm{NP}$-hard" claim: no thermodynamic input is needed, and the honest
combinatorial content is that the soufflé is hard to verify from *both* sides, unlike the
spoiled-ingredient dish, which is easy from one. Together with Theorem 3.4 this captures the
kitchen's most familiar frustration: you cannot know whether the soufflé rose without cutting into
it, and no partial information helps.

**Corollary 4.14 (Soufflé versus salad).** For $n \ge 2$,
$V(\mathrm{sal}_i) = 1 < n = V(\mathrm{souf}) = C(\mathrm{souf})$.

---

## 5. The spectrum, and the inversion of the conjecture

### 5.1 Every verification time occurs

**Definition 5.1 (Supported parity).** For $S \subseteq \{1,\dots,n\}$, let
$\mathrm{par}_S(x) := \bigoplus_{j \in S} x_j$. Write $f_k := \mathrm{par}_{\{1,\dots,k\}}$.

**Lemma 5.2.** $\mathrm{piv}(\mathrm{par}_S, x) = S$ for every $x$.

*Proof.* For $i \in S$, flipping $x_i$ flips the parity of the $S$-sum (as in Lemma 4.11). For
$i \notin S$, the $S$-sum is unchanged, so the verdict is unchanged. $\square$

**Theorem 5.3 (Spectrum Theorem).** For every $k \le n$, $V(f_k) = k$. Hence every value in
$\{0,1,\dots,n\}$ is the exact verification cost of some dish on $n$ ingredients, and every ratio
$$\frac{C}{V} = \frac{n}{k}, \qquad 1 \le k \le n,$$
is realised by an actual dish.

*Proof.* Upper bound: $f_k$ depends only on the first $k$ coordinates, so the truncated exhaustive
taster $B_k$ computes it in $k$ probes. Lower bound: Lemma 5.2 gives sensitivity exactly $k$ at every
pantry, and Corollary 3.3 applies. $\square$

### 5.2 The inversion

Assign to each dish its *timing record* $(C(f), V(f))$ and define the ratio
$\rho(f) := C(f)/V(f) \in \mathbb{Q}$ (defined when $f$ is non-constant, by Theorem 3.4). Call $f$
*evasive* if $V(f) = n$.

**Theorem 5.4 (Inversion Theorem).** For non-constant $f$, $\rho(f) = 1$ if and only if $f$ is
evasive.

*Proof.* $\rho(f) = 1$ iff $C(f) = V(f)$ iff $V(f) = n$, using $V(f) > 0$ (Theorem 3.4). $\square$

This *contradicts* the naive conjecture in the strongest possible way: the informal claim was that
"quick recipes have $C = V$ while hard recipes have $C \gg V$", whereas in truth $C = V$
characterises the maximally hard dishes and the easiest non-trivial dish, the salad, attains the
extreme ratio $\rho = n$ (Proposition 4.2).

The source of the confusion is a conflation of *absolute* difficulty with *relative discount*. The
ratio $\rho$ measures how much verification saves you compared with cooking. Hard dishes offer no
saving, so $\rho = 1$. Easy dishes offer the maximum saving, so $\rho = n$. Nothing in the metaphor
was wrong except the direction.

### 5.3 Menu rigidity

Let a *menu* be a finite indexed family $(f_\iota)_{\iota \in I}$ of dishes with timing records
$(C_\iota, V_\iota)$, and define the *aggregate* record $\big(\sum_\iota C_\iota, \sum_\iota V_\iota\big)$
with aggregate ratio $\rho_{\mathrm{agg}} := \sum_\iota C_\iota / \sum_\iota V_\iota$.

**Theorem 5.5 (Menu Rigidity).** Let $(f_\iota)_{\iota \in I}$ be a non-empty finite menu of
non-constant dishes on $n$ ingredients. Then $\rho_{\mathrm{agg}} = 1$ if and only if $V(f_\iota) = n$
for *every* $\iota$.

*Proof sketch.* Each dish satisfies $0 < V_\iota \le C_\iota$ (Theorems 3.4 and 2.8), so
$\sum V_\iota \le \sum C_\iota$ with equality iff $V_\iota = C_\iota$ termwise — the rigidity of a
sum of same-signed inequalities. Apply Theorem 5.4 termwise. $\square$

Because the aggregate weights each dish by its *verification* work, a single non-evasive dish (a
salad) is enough to push the whole restaurant off the break-even boundary — and, conversely,
a menu dominated by hard dishes stays near it.

### 5.4 The census of one hundred recipes

The originating concept proposed an experiment: classify one hundred recipes by their $C/V$ ratio. We
carry it out exactly. Take $n = 100$ ingredients and the hundred dishes $f_1, f_2, \dots, f_{100}$
of Definition 5.1.

**Proposition 5.6.** Recipe $k$ has $C = 100$ and $V = k$, hence $\rho = 100/k$. The ratios sweep the
full range from $100$ (the one-probe dish $f_1$) down to $1$ (the evasive dish $f_{100}$).

**Theorem 5.7 (Census).** The aggregate cook time of the menu is $100 \cdot 100 = 10{,}000$, the
aggregate taste time is $\sum_{k=1}^{100} k = 5050$, and therefore
$$\rho_{\mathrm{agg}} = \frac{10000}{5050} = \frac{200}{101} \approx 1.980.$$

The lesson is quantitative and non-obvious: the *mean of the individual ratios*,
$\frac{1}{100}\sum_k 100/k \approx 5.19$, and the *median* ratio, $\approx 1.98$, are wildly
different from each other, and the aggregate is close to the latter, not the former. Aggregating
weights dishes by their verification load, so the hard dishes dominate. A restaurant whose menu
includes soufflés is, in aggregate, nearly break-even no matter how many salads it serves.

---

## 6. Almost every recipe is a soufflé

### 6.1 Classifying quick dishes

**Theorem 6.1 (One-probe classification).** If $V(f) \le 1$ then $f$ is constant, a dictator
$x \mapsto x_i$, or a negated dictator $x \mapsto \lnot x_i$.

*Proof.* An optimal taster of depth $\le 1$ is either a leaf (constant) or
$\mathsf{probe}(i,\mathsf{serve}(a),\mathsf{serve}(c))$, so $f(x) = $ if $x_i$ then $c$ else $a$. The
four choices of $(a,c)$ give the two constants, the dictator and the negated dictator. $\square$

**Corollary 6.2.** At most $2n+2$ dishes on $n$ ingredients satisfy $V \le 1$. Since there are
$2^{2^n}$ dishes in total, and $2n+2 < 2^{2^n}$ for $n \ge 2$, quick recipes are rare — indeed the
gap is doubly exponential.

### 6.2 A structure theorem and a counting recursion

Let $c_d := \#\{f : \{0,1\}^n \to \{0,1\} \mid V(f) \le d\}$.

**Theorem 6.3 (Structure of $(d{+}1)$-quick dishes).** If $V(f) \le d+1$, then either $f$ is constant,
or there are an ingredient $i$ and dishes $g_0, g_1$ with $V(g_0), V(g_1) \le d$ and
$f(x) = $ if $x_i$ then $g_1(x)$ else $g_0(x)$.

*Proof.* Take an optimal taster. If it is a leaf, $f$ is constant. Otherwise it is
$\mathsf{probe}(i,T_0,T_1)$ with both subtrees of depth $\le d$; take $g_b := \mathrm{ev}(T_b,\cdot)$,
which is computed by $T_b$ and so has $V(g_b) \le d$. $\square$

**Corollary 6.4 (Counting recursion).** $c_0 = 2$ and $c_{d+1} \le 2 + n\, c_d^2$.

*Proof.* Theorem 6.3 exhibits every $(d{+}1)$-quick dish as an element of a set of size at most
$2 + n c_d^2$: two constants, or a choice of $i$ and of the pair $(g_0, g_1)$. $\square$

**Theorem 6.5 (Solving the recursion).** For $n \ge 1$ and all $d$,
$$3n\,c_d \le (6n)^{2^d}, \qquad \text{hence} \qquad c_d \le (6n)^{2^d}.$$

*Proof sketch.* Induction on $d$. Base: $3n \cdot 2 = 6n = (6n)^{2^0}$. Step: using $c_d \ge 1$,
$$3n\,c_{d+1} \le 3n(2 + n c_d^2) = 6n + 3n^2c_d^2 \le 6 n^2 c_d^2 + 3n^2c_d^2 = (3nc_d)^2
\le \big((6n)^{2^d}\big)^2 = (6n)^{2^{d+1}}.$$
The middle inequality uses $n \le n^2 c_d^2$. $\square$

The bound is doubly exponential — but in $d$, not in $n$. Against the doubly exponential in $n$
count of all dishes it is negligible.

**Theorem 6.6 (Existence of hard recipes).** If $n \ge 1$ and $(6n)^{2^d} < 2^{2^n}$, then some dish
on $n$ ingredients has $V(f) > d$.

**Theorem 6.7 (Generic hardness).** If $n \ge 1$ and $2\,(6n)^{2^d} \le 2^{2^n}$, then at least half of
all dishes on $n$ ingredients have $V(f) > d$.

**Corollary 6.8 (A concrete instance).** With $n = 16$ ingredients, at least half of all $2^{65536}$
dishes require more than $7$ taste probes.

*Proof.* $(6 \cdot 16)^{2^7} = 96^{128} \le (2^7)^{128} = 2^{896}$, so
$2 \cdot 96^{128} \le 2^{897} \le 2^{65536} = 2^{2^{16}}$. Apply Theorem 6.7. $\square$

Interpretation: the recipes we actually cook are drawn from a vanishingly thin, highly structured
sliver of the space of all conceivable dishes. Culinary tradition is a compression scheme for that
sliver. A *random* dish is a soufflé.

---

## 7. Adaptivity: deciding what to taste next

**Definition 7.1 (Nonadaptive checklist).** A set $S$ is a *nonadaptive checklist* for $f$ if $S$ is a
certificate for $f$ at *every* pantry — i.e. probing exactly $S$, regardless of what is found, always
determines the verdict.

**Definition 7.2 (Relevant ingredient).** Ingredient $i$ is *relevant* for $f$ if it is pivotal at
some pantry. Write $\mathrm{rel}(f)$ for the set of relevant ingredients.

**Lemma 7.3.** Every nonadaptive checklist contains $\mathrm{rel}(f)$.

*Proof.* If $i$ is pivotal at $x$, then by Proposition 4.6 every certificate at $x$ contains $i$; a
checklist is in particular a certificate at $x$. $\square$

**Definition 7.4 (Multiplexer).** On three ingredients — sauce, fish, soup — set
$\mathrm{mux}(x) := $ if $x_{\text{sauce}}$ then $x_{\text{fish}}$ else $x_{\text{soup}}$.

**Proposition 7.5.** $V(\mathrm{mux}) = 2$, and $\mathrm{rel}(\mathrm{mux}) = \{\text{sauce},\text{fish},\text{soup}\}$.

*Proof.* Upper bound: probe the sauce, then the fish or the soup accordingly. Lower bound: at the
pantry (sauce $=1$, fish $=1$, soup $=0$), both the sauce and the fish are pivotal, so $s = 2$ and
Corollary 3.3 applies. Relevance: the sauce is pivotal at that same pantry, the fish there too, and
the soup is pivotal at (sauce $=0$, fish $=1$, soup $=0$). $\square$

**Theorem 7.6 (Adaptivity Gap).** Every nonadaptive checklist for $\mathrm{mux}$ consists of all three
ingredients, while an adaptive taster needs only two probes.

*Proof.* Combine Lemma 7.3 and Proposition 7.5. $\square$

A cook who decides what to taste next in the light of the previous taste is strictly more efficient
than one who commits to a checklist in advance. This is the kitchen instance of the general
adaptive-versus-nonadaptive query separation.

---

## 8. When both proofs are short: the product bound

The separation of Theorem 4.9 shows that certificates can be far shorter than decision trees. But
$\mathrm{spoiled}$ is only easy on *one* side: badness has one-probe proofs, goodness has none short.
What if *both* sides have short proofs? The main theorem of this section says that then the dish is
genuinely quick to taste, up to a product.

**Theorem 8.1 (Certificate overlap).** Let $S$ be a certificate for $f$ at $x$ and $T$ a certificate
for $f$ at $y$, with $f(x) \ne f(y)$. Then $S \cap T \ne \varnothing$.

*Proof.* Suppose $S \cap T = \varnothing$ and define the hybrid pantry
$$u_j := \begin{cases} x_j & j \in S,\\ y_j & j \notin S.\end{cases}$$
Then $u$ agrees with $x$ on $S$, so $f(u) = f(x)$. And $u$ agrees with $y$ on $T$: for $j \in T$ we
have $j \notin S$ (disjointness), so $u_j = y_j$. Hence $f(u) = f(y)$. Therefore $f(x) = f(y)$,
contradicting the hypothesis. $\square$

This is the combinatorial heart of the argument: *proofs of goodness and proofs of badness always
share an ingredient.*

**Definition 8.2 (Restriction).** For a dish $f$, a set $S$ and a pantry $a$, the *restricted dish* is
$$f|_{S \leftarrow a}(y) := f\big(j \mapsto \text{if } j \in S \text{ then } a_j \text{ else } y_j\big).$$

**Lemma 8.3 (Certificates restrict).** If $T$ is a certificate for $f$ at the pantry
$j \mapsto (\text{if } j \in S \text{ then } a_j \text{ else } z_j)$, then $T \setminus S$ is a
certificate for $f|_{S \leftarrow a}$ at $z$.

*Proof.* Direct unfolding: any $y$ agreeing with $z$ on $T \setminus S$ yields a full pantry agreeing
with the original one on all of $T$, so the verdicts coincide. $\square$

**Definition 8.4 (Checklist-then-continue taster).** For a list $L$ of ingredients, a continuation
$\mathrm{cont}$ mapping accumulated knowledge to a taster, and an accumulator $a$, define
$\mathrm{QL}([\,], \mathrm{cont}, a) := \mathrm{cont}(a)$ and
$\mathrm{QL}(i{::}L, \mathrm{cont}, a) := \mathsf{probe}\big(i,\ \mathrm{QL}(L,\mathrm{cont},a[i \mapsto 0]),\ \mathrm{QL}(L,\mathrm{cont},a[i \mapsto 1])\big)$.

**Lemma 8.5.** If every $\mathrm{cont}(a)$ has depth $\le d$, then
$\mathrm{depth}(\mathrm{QL}(L,\mathrm{cont},a)) \le |L| + d$, and
$$\mathrm{ev}(\mathrm{QL}(L,\mathrm{cont},a), x) = \mathrm{ev}\big(\mathrm{cont}(j \mapsto \text{if } j \in L \text{ then } x_j \text{ else } a_j),\ x\big).$$

*Proof sketch.* Both by induction on $L$; the evaluation law says exactly that the strategy
"probe all of $L$, then continue with what you learned" behaves as advertised. $\square$

**Theorem 8.6 (Certificate Product Theorem, $V \le C_0 \cdot C_1$).** Suppose every $0$-input of $f$
has a certificate of size $\le k$, and every $1$-input has a certificate of size $\le m$. Then
$$V(f) \le k \cdot m.$$

*Proof.* Induction on $k$.

*Base $k = 0$.* If $f$ has a $0$-input $x_0$, its certificate is $\varnothing$, so $f \equiv f(x_0) = 0$
and $V(f) = 0$ by Theorem 3.4. If $f$ has no $0$-input it is constantly $1$, again $V(f) = 0$.

*Step $k \to k+1$.* If $f$ has no $1$-input it is constant and $V(f) = 0$. Otherwise fix a $1$-input
$x_1$ with a certificate $S$, $|S| \le m$. Consider any restriction $f|_{S \leftarrow a}$.

- *Badness budget drops.* Let $z$ be a $0$-input of $f|_{S \leftarrow a}$, corresponding to a full
  $0$-input $w$ of $f$; let $T$ be a certificate for $f$ at $w$ with $|T| \le k+1$. Since
  $f(x_1) = 1 \ne 0 = f(w)$, Theorem 8.1 gives some $i \in S \cap T$. By Lemma 8.3,
  $T \setminus S$ is a certificate for the restriction at $z$, and $T \setminus S \subseteq T
  \setminus \{i\}$, so $|T \setminus S| \le |T| - 1 \le k$.
- *Goodness budget survives.* Similarly, $1$-inputs of the restriction inherit certificates
  $T \setminus S$ of size $\le |T| \le m$.

By the inductive hypothesis, $V(f|_{S \leftarrow a}) \le k m$ for every $a$; choose optimal tasters
$t_a$ of that depth. Now run $\mathrm{QL}(S, a \mapsto t_a, \mathbf 0)$: probe all of $S$, then run the
optimal taster for the resulting restriction. By Lemma 8.5 this computes $f$ and has depth at most
$$|S| + km \le m + km = (k+1)m. \qquad \square$$

**Corollary 8.7 (Squaring form).** If every input of $f$ has a certificate of size $\le c$, then
$V(f) \le c^2$.

In the language of the metaphor: *in the kitchen, $\mathrm{NP} \cap \mathrm{co\text{-}NP}$ collapses
into $\mathrm{P}$, at the cost of squaring the tasting time.* A dish with short proofs of both
goodness and badness is genuinely quick to taste outright.

**Proposition 8.8 (Tightness).** For $\mathrm{spoiled}$, $C_1 = 1$ and $C_0 = n$, and Theorem 8.6
yields the bound $1 \cdot n = n$, which is exactly $V(\mathrm{spoiled})$. The bound is attained.

**Proposition 8.9 (Slack).** For $\mathrm{souf}$, $C_0 = C_1 = n$ (Theorem 4.13), so Corollary 8.7
yields only $V \le n^2$ while the truth is $V = n$. The theorem is powerless exactly where there is
nothing to gain.

These two propositions delimit the theorem sharply: the product bound is tight on one-sided-easy
dishes and vacuous on two-sided-hard ones. The soufflé is precisely the dish that escapes the
collapse.

---

## 9. Algorithms

The theory yields four concrete algorithms, each of independent computational interest.

**(A) Exact verification cost by memoised restriction search.** Given the truth table of $f$ on $n$
ingredients, compute $V(f)$ by the recursion
$$V(f) = \begin{cases} 0 & f \text{ constant},\\ 1 + \min_i \max\big(V(f|_{i \leftarrow 0}), V(f|_{i \leftarrow 1})\big) & \text{otherwise}.\end{cases}$$
Correctness is Theorem 6.3 read as an equation. Memoising over restrictions (canonicalised as
sub-truth-tables) gives complexity $O(3^n \cdot n)$ in the worst case, practical up to $n \approx 12$.

**(B) Sensitivity lower bound.** Compute $\max_x s(f,x)$ in $O(2^n n)$ by flipping each coordinate at
each pantry. By Corollary 3.3 this certifies a lower bound on $V(f)$, and for parity-type dishes it is
tight.

**(C) Minimum certificate at a point.** Compute the least $|S|$ with $S$ a certificate for $f$ at $x$
by searching subsets in increasing size, testing the defining condition in $O(2^{n - |S|})$ time per
subset. Proposition 4.6 prunes the search: every candidate must contain $\mathrm{piv}(f,x)$.

**(D) The product-bound taster.** Given certificate oracles, build the adaptive strategy of
Theorem 8.6: repeatedly pick a $1$-input consistent with what you have seen, probe its whole
certificate, and recurse on the restriction. Each round costs at most $C_1$ probes and lowers the
badness budget by one, so the strategy terminates in at most $C_0$ rounds and $C_0 C_1$ probes.

---

## 10. Discussion

### 10.1 What the model buys, and what it costs

The decision-tree model was chosen because it is the largest natural model in which the intended
separations are unconditional. The price is that it is *very* weak: cooking is a single number,
$n$; there is no notion of an ingredient's preparation cost, of sequencing, of parallel burners, or
of destructive measurement. Several culinary phenomena are simply invisible to it.

The most conspicuous absence is *destructiveness*. Cutting a soufflé to check whether it rose
destroys the soufflé; probing coordinate $i$ in our model does not. Theorem 4.13 captures the
*informational* half of that predicament (no partial probe tells you anything) but not the
*physical* half. A model with consumable probes — each ingredient may be tasted at most once, and
tasting reduces the dish — would be the natural next formalism, and it is a genuine departure, not a
reparametrisation.

### 10.2 The claim we deliberately did not prove

We do not claim, and do not believe follows from anything here, that soufflé verification is
$\mathrm{co}\text{-}\mathrm{NP}$-hard by reduction to Navier–Stokes simulation. Such a statement needs
a physical model, a discretisation with a stated error budget, and an actual reduction. What we prove
instead is the exact combinatorial shadow of the claim: the soufflé's certificate complexity is
maximal on both sides (Theorem 4.13), so it is hard to verify in the strongest sense the model can
express. We regard this substitution — a defensible theorem in place of an indefensible one — as the
main methodological point of the work.

### 10.3 The inverted conjecture as a case study

The originating conjecture ("quick recipes have $C = V$, hard recipes have $C \gg V$") was not merely
unproved; it is false, with the inequality exactly reversed (Theorem 5.4). This is worth dwelling on.
The intuition was about *absolute* effort, the formalism about *relative* discount, and the two run in
opposite directions. Precise definitions earn their keep precisely in cases like this, where a plausible
slogan survives casual scrutiny and dies on contact with a definition.

---

## 11. Future directions

**Sensitivity–tasting polynomial equivalence in the kitchen.** *Conjecture:* for every dish $f$,
$V(f) \le \big(\max_x s(f,x)\big)^4$. The sensitivity lower bound of Corollary 3.3 would then be not
merely a bound but polynomially tight: a cook who can find a pivotal ingredient at every pantry can
always design a fast tasting protocol. The product bound of Theorem 8.6 is one leg of the standard
chain from sensitivity to query complexity; the missing layer is block sensitivity, which sits between
the two quantities.

**Evasiveness of monotone kitchen properties.** *Conjecture:* every non-constant *monotone* dish that
is invariant under a transitive group of ingredient permutations (for instance "the stew is salty
enough", symmetric in all ingredients) is evasive, $V(f) = n$. Culinary symmetry — no ingredient plays
a distinguished role — is exactly the hypothesis of the classical evasiveness theorem for transitive
monotone graph properties, so the kitchen intuition "you must check everything in a symmetric recipe"
should be a theorem rather than a heuristic. The pivotal-set machinery is in place; what is needed is
a group action on pantries.

**Randomised tasting saves at most a cubic factor.** *Conjecture:* allowing the cook to taste at
random positions with error probability $1/3$ reduces the number of probes by at most a cubic factor,
$V(f) \le O\big(R(f)^3\big)$ where $R$ is the randomised query complexity. This is the kitchen version
of the classical polynomial relation between deterministic and bounded-error randomised query
complexity, and would say that guessing where to taste is worth at most a polynomial saving.

**A destructive-probe model.** As discussed in §10.1, a model in which probes consume the dish would
capture the specifically culinary phenomenon that the soufflé theorem only half-captures.

**Cost-weighted cooking.** Replacing $C(f) = n$ by $C(f) = \sum_i w_i$ for ingredient-dependent
preparation costs, and correspondingly weighting probes, would turn the spectrum theorem into a
statement about weighted ratios and make the menu-rigidity theorem sensitive to which dishes are
expensive rather than merely how many.

---

## 12. Conclusion

Fixing a computational model turns the recipe metaphor into mathematics, and the mathematics is
richer than the metaphor. Tasting is never harder than cooking; sensitivity is a universal lower
bound; the spoiled-ingredient dish separates deterministic from nondeterministic verification
unconditionally; the soufflé resists certification from both sides; the whole spectrum of cook/taste
ratios is realised; break-even recipes are the *hardest* ones, not the easiest, inverting the naive
conjecture; almost every conceivable dish is a soufflé; adaptivity is strictly powerful; and a dish
with short proofs on both sides is quick to taste outright, up to a product.

The one claim the model refuses to underwrite — that soufflé verification is hard for thermodynamic
reasons — is replaced by one it does: that the soufflé is hard for combinatorial reasons, in the
strongest sense the model can state. That trade is the whole discipline in miniature.
