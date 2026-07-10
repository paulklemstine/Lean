# A Complexity Theory of Recipes: Cooking, Verifying, and the Kitchen Analogue of P vs NP

## Abstract

We develop a small, self-contained algebraic theory that takes seriously the analogy *"every recipe is an algorithm."* A recipe is modelled by two non-negative integers: its **cooking time** $C(R)$, the resource required to produce a dish, and its **verification time** $V(R)$, the resource required to taste the finished dish and judge whether it is good. This is the culinary shadow of the central distinction of computational complexity, between *solving* a problem and *verifying* a candidate solution. We classify recipes into three mutually exclusive classes — **quick** ($C = V$, the analogue of $P = NP$), **traditional** ($V < C$, the analogue of $P \ne NP$), and **overhard** ($C < V$, the analogue of an $NP$-hard problem whose verification is itself expensive) — and prove that this trichotomy is exhaustive. We introduce **sequential composition** of recipes and show it endows the set of recipes with the structure of a commutative monoid, under which the classes exhibit natural closure properties. We define the **speedup** $C - V$ and prove it is additive over *physical* recipes ($V \le C$), then use this to establish the central **Batch Quickness Theorem**: a menu of physical recipes is globally quick if and only if every dish on it is quick. We close with a rational-ratio characterization of the three classes and a discussion of numerical experiments classifying sample recipes. Every result stated is fully proved.

**Keywords:** computational complexity, P vs NP, verification, commutative monoid, additive slack, trichotomy, resource models.

---

## 1. Introduction

The question of whether $P$ equals $NP$ asks, informally, whether every problem whose solutions can be *checked* efficiently can also be *solved* efficiently. Despite decades of effort it remains open, and it is widely believed that $P \ne NP$: for a great many problems, producing a solution is fundamentally harder than verifying one.

This paper explores that distinction in an unexpectedly concrete setting: the kitchen. A recipe is a procedure that transforms inputs (ingredients) into an output (a dish). Two resources govern its practice. The first is the effort of *cooking* — actually producing the dish. The second is the effort of *verifying* — tasting the result and deciding whether it meets its standard. The relationship between these two resources is precisely the relationship at the heart of complexity theory, and it varies from dish to dish.

Our contribution is a compact, rigorous algebraic model of this relationship, together with a chain of theorems that mirror — in miniature and with complete proofs — several structural features one expects of a complexity theory: an exhaustive classification, well-behaved composition, closure of classes, additive resource accounting, and a global-versus-local characterization.

The model is deliberately minimal. It discards everything about a recipe except two integers. This austerity is a feature: it isolates the single structural invariant that recipes share with computational problems, and it makes every claim provable by elementary means.

## 2. The model

### 2.1 Recipes

**Definition 2.1 (Recipe).** A *recipe* is a pair $R = (C(R), V(R))$ of non-negative integers, where $C(R)$ is the **cooking time** (the resource to prepare the dish) and $V(R)$ is the **verification time** (the resource to taste and judge the dish).

Two recipes are equal precisely when their cooking times agree and their verification times agree.

### 2.2 The three classes

We classify a recipe by comparing its two times.

**Definition 2.2.** Let $R$ be a recipe.
- $R$ is **quick** if $C(R) = V(R)$.
- $R$ is **traditional** if $V(R) < C(R)$.
- $R$ is **overhard** if $C(R) < V(R)$.
- $R$ is **physical** if $V(R) \le C(R)$.

Quick recipes are the culinary analogue of $P = NP$: producing the dish is no harder than checking it (assemble-and-serve dishes such as a salad). Traditional recipes are the analogue of $P \ne NP$: verifying is strictly cheaper than producing (the overwhelming majority of cooked dishes). Overhard recipes are the analogue of a problem for which even *verification* is expensive — the soufflé being the motivating example, since the only reliable check that it has risen throughout is to cut it open, destroying it. Physical recipes are those in which one never verifies more slowly than one cooks; they are exactly the quick and traditional recipes together.

## 3. Trichotomy and physicality

**Theorem 3.1 (Trichotomy of Recipes).** Every recipe is exactly one of quick, traditional, or overhard. Formally, for every recipe $R$ precisely one of the following holds:
$$C(R) = V(R), \qquad V(R) < C(R), \qquad C(R) < V(R).$$

*Proof.* The values $C(R)$ and $V(R)$ are natural numbers, and for any two natural numbers exactly one of "equal," "first strictly larger," "second strictly larger" holds by the totality and antisymmetry of the order. $\square$

**Theorem 3.2 (Physicality).** A recipe $R$ is physical if and only if it is not overhard: $V(R) \le C(R) \iff \neg\,(C(R) < V(R))$.

*Proof.* Immediate from the definition of $\le$ as the negation of the strict reverse inequality on the integers. $\square$

**Corollary 3.3.** Every physical recipe is quick or traditional. Conversely, quick recipes and traditional recipes are physical.

*Proof.* If $R$ is physical then $V(R) \le C(R)$, so either $V(R) = C(R)$ (quick) or $V(R) < C(R)$ (traditional). If $R$ is quick, $C = V$ gives $V \le C$; if traditional, $V < C$ gives $V \le C$. $\square$

These statements are elementary, but they establish that the classification is *complete and non-redundant*: there is no fourth class, and physicality is exactly the union of the two "reasonable" classes, excising the destructive-verification regime.

## 4. Sequential composition and the monoid structure

Kitchens produce menus, so recipes must compose. The natural operation is to cook one dish and then another.

**Definition 4.1 (Sequential composition).** For recipes $R$ and $S$, their *sequential composition* $R \circ S$ is the recipe
$$R \circ S = \big(C(R) + C(S),\ V(R) + V(S)\big).$$
The **empty recipe** is $\mathbf{1} = (0, 0)$.

Thus $C(R \circ S) = C(R) + C(S)$ and $V(R \circ S) = V(R) + V(S)$: both resources are additive under composition, reflecting that doing two things in sequence costs the sum of their costs.

**Theorem 4.2 (Monoid structure).** The set of recipes, equipped with $\circ$ and identity $\mathbf 1$, is a commutative monoid. That is:
1. **Associativity:** $(R \circ S) \circ T = R \circ (S \circ T)$.
2. **Identity:** $\mathbf 1 \circ R = R = R \circ \mathbf 1$.
3. **Commutativity:** $R \circ S = S \circ R$.

*Proof.* Each identity is checked componentwise and reduces to the corresponding property of integer addition: associativity of $+$, the fact that $0$ is a neutral element, and commutativity of $+$. Two recipes are equal iff both components agree, so componentwise verification suffices. $\square$

Commutativity encodes a genuine culinary fact: the order in which two independent dishes are prepared does not change the total cooking and tasting budgets.

## 5. Closure of the classes

**Theorem 5.1 (Quick closure).** If $R$ and $S$ are quick, then $R \circ S$ is quick.

*Proof.* From $C(R) = V(R)$ and $C(S) = V(S)$ we get $C(R) + C(S) = V(R) + V(S)$, i.e. $C(R \circ S) = V(R \circ S)$. $\square$

**Theorem 5.2 (Traditional absorbs physical).** If $R$ is traditional and $S$ is physical, then $R \circ S$ is traditional.

*Proof.* We have $V(R) < C(R)$ and $V(S) \le C(S)$. Adding, $V(R) + V(S) < C(R) + C(S)$, that is $V(R \circ S) < C(R \circ S)$. $\square$

**Theorem 5.3 (Physical closure).** If $R$ and $S$ are physical, then $R \circ S$ is physical.

*Proof.* From $V(R) \le C(R)$ and $V(S) \le C(S)$, add to obtain $V(R) + V(S) \le C(R) + C(S)$. $\square$

Theorem 5.2 is the most conceptually significant: a genuine slowdown (a traditional dish, where cooking strictly dominates verifying) cannot be undone by composing it with a well-behaved companion. Hardness, once present, is inherited by the whole.

## 6. Speedup and its additivity

**Definition 6.1 (Speedup).** The *speedup* of a recipe is $\operatorname{sp}(R) = C(R) - V(R)$, using truncated subtraction on the non-negative integers (so the value is $0$ when $V(R) > C(R)$).

Speedup measures how much faster tasting is than cooking. It is the "slack" of the recipe.

**Theorem 6.2 (Speedup characterization of quickness).** A recipe $R$ is quick if and only if it is physical and $\operatorname{sp}(R) = 0$.

*Proof.* If $R$ is quick then $C = V$, so $V \le C$ (physical) and $C - V = 0$. Conversely, if $R$ is physical then $V \le C$, so truncated subtraction is genuine subtraction and $\operatorname{sp}(R) = C - V$; if this is $0$ then $C = V$. $\square$

**Theorem 6.3 (Additivity of speedup over physical recipes).** If $R$ and $S$ are physical, then
$$\operatorname{sp}(R \circ S) = \operatorname{sp}(R) + \operatorname{sp}(S).$$

*Proof.* Physicality of $R$ and $S$ gives $V(R) \le C(R)$ and $V(S) \le C(S)$, and by Theorem 5.3, $R\circ S$ is physical, so all subtractions are non-truncating. Then
$$\operatorname{sp}(R \circ S) = \big(C(R)+C(S)\big) - \big(V(R)+V(S)\big) = \big(C(R)-V(R)\big) + \big(C(S)-V(S)\big) = \operatorname{sp}(R)+\operatorname{sp}(S). \qquad \square$$

The physicality hypothesis is not cosmetic. Over the non-negative integers, subtraction is truncated at zero, so without the guarantee $V \le C$ the two sides can differ. Additivity of resource slack holds precisely in the physical regime.

## 7. Repetition: cooking many servings

**Definition 7.1 (Repetition).** For $n \in \mathbb{N}$ and a recipe $R$, the $n$-fold repetition $R^{\circ n}$ is defined by $R^{\circ 0} = \mathbf 1$ and $R^{\circ(n+1)} = R \circ R^{\circ n}$.

**Theorem 7.2 (Linear scaling).** For all $n$ and $R$,
$$C(R^{\circ n}) = n\,C(R), \qquad V(R^{\circ n}) = n\,V(R).$$

*Proof.* By induction on $n$. The base case $n = 0$ gives $C(\mathbf 1) = 0 = 0 \cdot C(R)$ and likewise for $V$. For the inductive step,
$$C(R^{\circ(n+1)}) = C(R) + C(R^{\circ n}) = C(R) + n\,C(R) = (n+1)\,C(R),$$
using the induction hypothesis, and identically for $V$. $\square$

**Corollary 7.3 (Class invariance under batching).** For $n \ge 1$, $R^{\circ n}$ lies in the same class (quick / traditional / overhard) as $R$.

*Proof.* Comparing $C(R^{\circ n}) = nC(R)$ with $V(R^{\circ n}) = nV(R)$ for $n \ge 1$: multiplying both sides of $C(R) = V(R)$, $V(R) < C(R)$, or $C(R) < V(R)$ by the positive integer $n$ preserves the (strict or non-strict) relation. $\square$

Complexity class is scale-invariant: doubling the number of servings changes neither the ratio of the resources nor the classification.

## 8. Batches and the Batch Quickness Theorem

A menu is a finite list of recipes, composed in sequence. Its total cooking and verification times are the sums of those of its constituents. Write $\operatorname{batch}(L)$ for the composition of all recipes in a list $L$; equivalently $C(\operatorname{batch}(L)) = \sum_{R \in L} C(R)$ and $V(\operatorname{batch}(L)) = \sum_{R \in L} V(R)$.

**Theorem 8.1 (Batch Quickness Theorem).** Let $L$ be a menu (finite list) of *physical* recipes. Then $\operatorname{batch}(L)$ is quick if and only if every recipe in $L$ is quick.

*Proof.* By closure (Theorem 5.3), $\operatorname{batch}(L)$ is physical, so by Theorem 6.2 it is quick iff its speedup vanishes. By repeated application of Theorem 6.3 (additivity over the physical constituents),
$$\operatorname{sp}(\operatorname{batch}(L)) = \sum_{R \in L} \operatorname{sp}(R).$$
Each term is a non-negative integer (since each $R$ is physical, $\operatorname{sp}(R) = C(R) - V(R) \ge 0$). A finite sum of non-negative integers is zero if and only if every summand is zero. By Theorem 6.2 again, $\operatorname{sp}(R) = 0$ with $R$ physical is exactly quickness of $R$. Combining, $\operatorname{batch}(L)$ is quick iff every $R \in L$ is quick. $\square$

This is the paper's central result. In culinary terms: **quickness of a physical menu is all-or-nothing** — a single genuinely slow dish forces the whole menu to be slow, and no accumulation of trivial dishes can compensate. In complexity terms it is the statement that global slack vanishes exactly when every local slack vanishes, the discrete analogue of "a sum of non-negative quantities is zero iff each is zero."

## 9. The cooking ratio

For recipes with positive verification time, the classification is captured by a single dimensionless number.

**Definition 9.1 (Cooking ratio).** For a recipe with $V(R) > 0$, the *cooking ratio* is $\rho(R) = C(R)/V(R) \in \mathbb{Q}_{\ge 0}$.

**Theorem 9.2 (Ratio characterization).** For a recipe $R$ with $V(R) > 0$:
- $R$ is quick $\iff \rho(R) = 1$;
- $R$ is traditional $\iff \rho(R) > 1$;
- $R$ is overhard $\iff \rho(R) < 1$.

*Proof.* Since $V(R) > 0$, dividing the defining inequalities of each class by $V(R)$ preserves them: $C = V \iff C/V = 1$, $V < C \iff C/V > 1$, and $C < V \iff C/V < 1$. $\square$

The cooking ratio is a unit-free hardness index: how many times longer it takes to make a dish than to judge it.

## 10. Numerical experiments

To illustrate the framework we classify a corpus of sample recipes by their $(C, V)$ pairs. Representative entries:

| Recipe | $C$ | $V$ | class | $\rho = C/V$ |
|---|---|---|---|---|
| Green salad | 8 | 8 | quick | 1.00 |
| Cheese plate | 5 | 5 | quick | 1.00 |
| Roast chicken | 90 | 3 | traditional | 30.0 |
| Sourdough bread | 1440 | 2 | traditional | 720 |
| Beef stock | 300 | 4 | traditional | 75.0 |
| Soufflé | 40 | 60 | overhard | 0.67 |

Batching experiments confirm the Batch Quickness Theorem: any menu drawn from the two salads is quick (total $C$ equals total $V$), while adding a single traditional dish makes the total cooking time strictly exceed the total verification time. Linear-scaling experiments confirm Theorem 7.2: $n$ servings of any dish preserve its ratio exactly.

## 11. Applications and interpretation

Beyond its playful framing, the model isolates the structural core of the produce-versus-verify distinction and makes several intuitions precise:

- **Hardness propagates (Theorem 5.2).** A single hard sub-task dominates a pipeline; you cannot dilute it with easy work. This is the everyday reason one bottleneck can determine the cost of an entire computation — or an entire dinner service.
- **Slack is additive but only in the physical regime (Theorem 6.3).** The clean accounting of resource margins requires that verification never exceeds production. Reasoning that ignores this — analogous to ignoring truncation of a non-negative quantity — is a classic source of error in resource analysis.
- **Global efficiency is local (Theorem 8.1).** Optimality of a whole schedule reduces to optimality of each part, when all parts are well-behaved.
- **Scale neutrality (Corollary 7.3).** Complexity class is invariant under replication, mirroring the way asymptotic complexity ignores constant multiplicities.

## 12. Discussion and future work

The theory is intentionally elementary; its interest lies in how faithfully a two-integer model reproduces the qualitative architecture of complexity theory. Several natural extensions suggest themselves:

- **Weighted / parallel cooking.** Model a kitchen with $k$ cooks by a *max-plus* rather than *plus* composition, and study when parallelism converts a traditional menu into a quick one.
- **A genuine reduction relation.** Introduce a preorder $R \preceq S$ ("$R$ reduces to $S$") and prove the classes are upward/downward closed, mirroring polynomial-time reductions.
- **Cost hierarchies.** Index recipe families by input size $n$ with $C, V : \mathbb{N} \to \mathbb{N}$ and formalize asymptotic separations such as $V = o(C)$, a faithful analogue of time-hierarchy separations.
- **Amortized speedup.** Study average slack $\operatorname{sp}(\operatorname{batch}(L))/|L|$ and prove averaging inequalities over menus.
- **Overhard closure.** Characterize exactly when composition preserves overhardness, connecting to the destructive-verification motivation of the soufflé.
- **Probabilistic verification.** Replace exact tasting by sampling ("taste a spoonful") and formalize a randomized, error-bounded verification model.

## 13. Conclusion

We have given a complete, elementary algebraic theory of recipes as resource-bounded procedures, classifying every recipe as quick, traditional, or overhard, endowing recipes with a commutative-monoid composition, and proving closure, additivity, scaling, and a Batch Quickness Theorem that reduces global efficiency to local efficiency. Small as it is, the theory captures the essential drama of $P$ versus $NP$: the relationship between the cost of producing and the cost of verifying. In the kitchen, as most believe of computation at large, doing is usually harder than checking.
