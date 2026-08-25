# Parameter-Derived Depth: The Exact Maximal Refinement Level of a Budgeted Hierarchical Cascade

**Aristotle**

**2026-08-25**

---

## Abstract

A hierarchical physical model — a renormalisation cascade, a recursively refined
spacetime lattice, a nested error-correcting code — is built level by level, and is
constrained by a finite resource: an information-theoretic threshold $T$ bounding the
number of distinguishable cells a region may carry. For a $B$-ary refinement, in which
every cell of level $k$ splits into $B$ cells of level $k+1$, the cumulative cost of a
depth-$d$ cascade is $S_B(d) = 1 + B + \cdots + B^d$, and depth $d$ is *supported* when
$S_B(d) \le T$.

We determine the largest supported depth exactly, as a closed-form function of the two
parameters, and prove its maximality rather than exhibiting a selected numerical instance:
$$d_{\max}(B,T) = \bigl\lfloor \log_B((B-1)T+1)\bigr\rfloor - 1.$$
Around this closed form we develop a complete structure theory. (i) *Scaling*: the depth
obeys the uniform two-sided estimate $\log_B T - 2 < d_{\max} \le \log_B T$, whence the
finest resolvable length $\ell = \ell_0 B^{-d_{\max}}$ satisfies
$\ell_0/T \le \ell < B^2 \ell_0 / T$ — resolution scales *inversely* in the budget with a
$B$-dependent constant only. (ii) *Universality*: for any strictly increasing cost
geometrically sandwiched as $B^d \le \mathrm{cost}(d) \le K B^d$, the maximal depth satisfies
$\log_B T - (\log_B K + 1) \le d_{\max} \le \log_B T$; the entire modelling freedom in how
one charges for a level is worth $\log_B K + 1$ levels and no more. (iii) *Composition*:
budgets multiply under tensoring of independent regions and depth is additive to within
an absolute two levels, $d(T_1) + d(T_2) \le d(T_1T_2) \le d(T_1)+d(T_2)+2$, with both ends
attained. (iv) *Deficit statistics*: charging for the coarse levels rather than only the
leaves costs at most one level; within each scale block $B^L \le T < B^{L+1}$ the lossy
budgets form the explicit interval $[B^L, S_B(L))$ of cardinality $S_B(L-1)$, and their
density converges to $1/(B-1)^2$ — equal to $1$ for binary branching. (v) *Disorder*: a
branching schedule quenched between $B_{\min}$ and $B_{\max}$ keeps the depth inside
$[\log_{B_{\max}} T - O(1),\, \log_{B_{\min}} T]$.

Every bound is explicit and uniform; no statement is asymptotic in the loose sense.

**Keywords.** hierarchical refinement, holographic bound, quantum foam, information
threshold, geometric series, integer logarithm, renormalisation depth, quenched disorder.

---

## 1. Introduction

### 1.1 The physical setting

Many physical models are *hierarchies indexed by scale*. A block-spin renormalisation
scheme coarse-grains a lattice by a fixed factor at each step. A Wheeler-type quantum foam
posits nested structure in spacetime down to some smallest scale. A concatenated quantum
error-correcting code embeds each logical qubit into a block of physical qubits, and
repeats. A causal-set or spin-network discretisation refines a region recursively.

All of these share a common combinatorial skeleton and a common constraint. The skeleton:
a rooted $B$-ary tree of cells, where a cell of level $k$ contains $B$ cells of level
$k+1$. The constraint: the region can only carry finitely much distinguishable structure.
In a holographic or Bekenstein-type setting that constraint takes the form of a bound $T$
on the number of distinguishable configurations, equivalently on the number of
distinguishable cells. In a laboratory setting it may instead be a detector resolution or
an energy budget. In every case one obtains the same question:

> Given the branching number $B$ and the threshold $T$, what is the greatest refinement
> depth the model can support?

The literature typically answers "about $\log_B T$" and moves on. That answer is correct
to within an additive constant but is not a theorem about the parameters: it does not say
which integer, it does not say that the integer it names is *maximal*, and it does not say
how much the answer depends on the accounting convention chosen for "cost".

### 1.2 Contribution

This paper answers the question exactly. We work throughout with integers, since depth is
an integer and the threshold is a count, and we recover the analytic statements as
corollaries with explicit constants.

The main object is the *parameter-derived depth* $d_{\max}(B,T)$, defined as the greatest
$d$ with $S_B(d) \le T$ and computed in closed form (Theorem 3.4). We then prove:

1. **Maximality and rigidity** (§3): the support set is exactly the initial segment
   $[0, d_{\max}]$; the depth $d_{\max}+1$ provably overshoots; and any greatest supported
   depth coincides with $d_{\max}$, so the closed form is *the* answer, independent of how
   it is found.
2. **Scaling laws** (§4): $\log_B T - 2 < d_{\max} \le \log_B T$ uniformly, and resolution
   scales as $\Theta(\ell_0/T)$ within a window of width $B^2$.
3. **Universality** (§5): the logarithmic law holds for every geometrically sandwiched
   cost model, with additive slack determined by the sandwich constant alone. Two
   instances — the pure tree count and a perturbed model with per-level overhead — are
   worked out.
4. **Composition** (§6): depth is additive under tensoring of budgets up to a sharp $+2$.
5. **Deficit statistics** (§7): the coarse-level overhead costs at most one level; the
   lossy budgets are an explicit interval per scale block, self-similarly counted, with
   limiting density $1/(B-1)^2$.
6. **Quenched disorder** (§8): a non-uniform branching schedule confines the depth between
   the extreme logarithms.

§2 sets up an abstract budget/threshold layer with minimal hypotheses so that all of the
above can be stated once and instantiated repeatedly. §9 gives worked numerical data, §10
discusses applications and limitations, and §11 lists open directions.

---

## 2. The abstract budget–threshold layer

We first isolate the order-theoretic content, so that later sections may instantiate it
with different cost models without repeating arguments.

**Definition 2.1 (Support).** Let $\mathrm{cost} : \mathbb{N} \to \mathbb{N}$ and let
$T \in \mathbb{N}$ be a threshold. Depth $d$ is **supported** by $T$ if
$\mathrm{cost}(d) \le T$. The **support set** is
$\mathcal{S}(\mathrm{cost}, T) = \{ d : \mathrm{cost}(d) \le T \}$.

**Definition 2.2 (Maximal depth).** $\displaystyle d_{\max}(\mathrm{cost}, T)$ is the
greatest element of $\mathcal{S}(\mathrm{cost}, T)$, when it exists.

The following minimal hypotheses suffice and are satisfied by every model in this paper:
$\mathrm{cost}$ is strictly monotone, and the ground level is affordable,
$\mathrm{cost}(0) \le T$.

**Lemma 2.3 (Finiteness).** If $\mathrm{cost}$ is strictly monotone then every supported
depth satisfies $d \le T$.

*Proof.* A strictly monotone map $\mathbb{N}\to\mathbb{N}$ satisfies $d \le \mathrm{cost}(d)$
(immediate induction). Combining with $\mathrm{cost}(d) \le T$ gives $d \le T$. $\square$

Consequently the greatest supported depth may be computed by a bounded search over
$\{0,\dots,T\}$; the search terminates and returns the greatest $d \le T$ with
$\mathrm{cost}(d)\le T$.

**Lemma 2.4 (Downward closure).** If $\mathrm{cost}$ is monotone, $e \le d$, and $d$ is
supported, then $e$ is supported.

*Proof.* $\mathrm{cost}(e) \le \mathrm{cost}(d) \le T$. $\square$

**Theorem 2.5 (Maximality and initial-segment structure).** Let $\mathrm{cost}$ be
strictly monotone with $\mathrm{cost}(0) \le T$. Then $d_{\max}(\mathrm{cost},T)$ exists,
is the greatest element of $\mathcal{S}(\mathrm{cost},T)$, and
$$d \text{ is supported} \iff d \le d_{\max}(\mathrm{cost},T).$$
Moreover $d_{\max}+1$ is not supported.

*Proof.* Existence and greatestness follow from Lemma 2.3 (the search bound is legitimate)
together with $\mathrm{cost}(0)\le T$ (the search set is non-empty). The forward
implication of the equivalence is greatestness; the reverse is Lemma 2.4 applied to
$d \le d_{\max}$ together with supportedness of $d_{\max}$. If $d_{\max}+1$ were supported
it would satisfy $d_{\max}+1 \le d_{\max}$, absurd. $\square$

**Corollary 2.6 (Uniqueness).** If $d$ is a greatest element of $\mathcal{S}(\mathrm{cost},T)$
then $d = d_{\max}(\mathrm{cost},T)$. Greatest elements of a set are unique.

**Lemma 2.7 (Frontier certificate).** If $\mathrm{cost}$ is strictly monotone, $d$ is
supported, and $d+1$ is not, then $d_{\max}(\mathrm{cost},T) = d$.

*Proof.* $d \le d_{\max}$ by greatestness. If $d < d_{\max}$ then $d + 1 \le d_{\max}$, so
$d+1$ is supported by Theorem 2.5 — contradiction. $\square$

Lemma 2.7 is the workhorse for concrete computations: to identify the maximal depth one
exhibits a single fitting level whose successor fails. Every numerical instance in this
paper is certified this way, so maximality is part of the statement rather than an
afterthought.

**Lemma 2.8 (Parameter monotonicity).** With $\mathrm{cost}$ strictly monotone:
(i) if $T \le T'$ and $\mathrm{cost}(0)\le T$, then $d_{\max}(\mathrm{cost},T) \le d_{\max}(\mathrm{cost},T')$;
(ii) if $\mathrm{cost}(d) \le \mathrm{cost}'(d)$ for all $d$ and $\mathrm{cost}'(0)\le T$,
then $d_{\max}(\mathrm{cost}',T) \le d_{\max}(\mathrm{cost},T)$.

*Proof.* (i) $d_{\max}(\mathrm{cost},T)$ is supported by $T$, hence by $T' \ge T$, hence at
most $d_{\max}(\mathrm{cost},T')$. (ii) $\mathrm{cost}(d_{\max}(\mathrm{cost}',T)) \le
\mathrm{cost}'(d_{\max}(\mathrm{cost}',T)) \le T$. $\square$

**Remark 2.9 (Degenerate regime).** If even the ground level exceeds the threshold,
$\mathrm{cost}(0) > T$, the bounded search returns $0$. We record this so that no statement
above is silently vacuous; all substantive theorems below carry the hypothesis $T \ge 1$,
which in the tree model is exactly $\mathrm{cost}(0) = 1 \le T$.

---

## 3. The $B$-ary cascade and its exact depth

**Definition 3.1 (Cascade cell count).** For $B, d \in \mathbb{N}$,
$$S_B(d) \;=\; \sum_{k=0}^{d} B^k \;=\; 1 + B + B^2 + \cdots + B^d.$$

This counts *all* cells of a $B$-ary refinement carried down to level $d$, not merely the
leaves. The choice is deliberate: if the threshold $T$ bounds the number of
distinguishable cells in the region, intermediate cells are distinguishable and must be
charged for. §7 quantifies exactly what this honesty costs.

Two immediate facts:

**Lemma 3.2.** $S_B(0) = 1$ and $S_B(d+1) = S_B(d) + B^{d+1}$. Consequently, for $B \ge 2$,
$S_B$ is strictly monotone; and $B^d \le S_B(d)$ for all $B, d$.

*Proof.* The recursion is the last-term split of the sum. Strict monotonicity follows since
$B^{d+1} > 0$. The inequality $B^d \le S_B(d)$ holds because $B^d$ is one summand of a sum
of non-negative terms. $\square$

The following identity is the algebraic pivot of the entire paper.

**Lemma 3.3 (Finite geometric identity).** For $B \ge 1$ and all $d$,
$$(B-1)\,S_B(d) + 1 \;=\; B^{\,d+1}.$$

*Proof.* Write $B = C+1$ with $C = B-1 \ge 0$. Induct on $d$. For $d = 0$:
$C \cdot 1 + 1 = C+1 = B^1$. Assuming $C\,S_B(d) + 1 = B^{d+1}$, the recursion of Lemma 3.2
gives
$$C\,S_B(d+1) + 1 = C\,S_B(d) + C\,B^{d+1} + 1 = B^{d+1} + C B^{d+1} = (C+1)B^{d+1} = B^{d+2}. \square$$

(The identity is stated in $\mathbb{N}$ with truncated subtraction, which is harmless since
$B \ge 1$.)

**Definition 3.4 (Parameter-derived depth).** For $B \ge 2$, $T \ge 1$,
$$d_{\max}(B,T) \;:=\; \bigl\lfloor \log_B\bigl((B-1)T + 1\bigr) \bigr\rfloor - 1,$$
where $\lfloor \log_B n \rfloor$ denotes the integer logarithm, i.e. the greatest $m$ with
$B^m \le n$.

**Lemma 3.5 (Budget $\Leftrightarrow$ power).** For $B \ge 2$ and all $T, d$,
$$S_B(d) \le T \iff B^{\,d+1} \le (B-1)T + 1.$$

*Proof.* ($\Rightarrow$) Multiplying by $B-1 > 0$ and adding $1$, Lemma 3.3 gives
$B^{d+1} = (B-1)S_B(d) + 1 \le (B-1)T + 1$. ($\Leftarrow$) Substituting Lemma 3.3 into the
hypothesis yields $(B-1)S_B(d) + 1 \le (B-1)T + 1$, and cancelling the positive factor
$B-1$ gives $S_B(d) \le T$. $\square$

**Theorem 3.6 (Support characterisation).** Let $B \ge 2$ and $T \ge 1$. Then for every $d$,
$$S_B(d) \le T \iff d \le d_{\max}(B,T).$$

*Proof.* By Lemma 3.5 the left side is $B^{d+1} \le (B-1)T+1$, which by the defining
property of the integer logarithm is $d + 1 \le \lfloor\log_B((B-1)T+1)\rfloor$. Since
$T \ge 1$ we have $(B-1)\cdot 1 + 1 \le (B-1)T + 1$, i.e. $B^1 \le (B-1)T+1$, so
$\lfloor\log_B((B-1)T+1)\rfloor \ge 1$ and the truncated subtraction in Definition 3.4 is
harmless: $d+1 \le \Lambda \iff d \le \Lambda - 1$ where $\Lambda \ge 1$. $\square$

**Theorem 3.7 (Maximality).** For $B \ge 2$, $T \ge 1$, the number $d_{\max}(B,T)$ is the
greatest element of $\{ d : S_B(d) \le T \}$. In particular $S_B(d_{\max}+1) > T$: one
level deeper always breaks the budget.

*Proof.* Take $d = d_{\max}$ in Theorem 3.6 for membership; take the forward direction for
greatestness. If $S_B(d_{\max}+1) \le T$ then $d_{\max}+1 \le d_{\max}$, absurd. $\square$

**Corollary 3.8 (Agreement and uniqueness).** The closed form agrees with the abstract
bounded search of §2: $d_{\max}(S_B, T) = d_{\max}(B,T)$. Any greatest supported depth
equals $d_{\max}(B,T)$.

*Proof.* Both are greatest elements of the same set (Theorem 2.5 with $\mathrm{cost}=S_B$,
which is strictly monotone by Lemma 3.2 and satisfies $S_B(0)=1\le T$; and Theorem 3.7).
Greatest elements are unique. $\square$

**Corollary 3.9 (Parameter monotonicity).** For $B \ge 2$, $T \ge 1$:
(i) $T \le T' \implies d_{\max}(B,T) \le d_{\max}(B,T')$;
(ii) $B \le B' \implies d_{\max}(B',T) \le d_{\max}(B,T)$.

*Proof.* (i) is Lemma 2.8(i). (ii) follows from $S_B(d) \le S_{B'}(d)$ (termwise, since
$B^k \le B'^k$) and Lemma 2.8(ii). More branching per level buys less depth for the same
budget. $\square$

**Worked instances.** Each is certified by the frontier (Lemma 2.7): the stated depth fits,
the next does not.

| $B$ | $T$ | $S_B(d)$ | $S_B(d+1)$ | $d_{\max}$ |
|---|---|---|---|---|
| $2$ | $1000$ | $511$ | $1023$ | $8$ |
| $3$ | $100$ | $40$ | $121$ | $3$ |
| $10$ | $10^6$ | $111111$ | $1111111$ | $5$ |
| $5$ | $10^6$ | $488281$ | $2441406$ | $8$ |
| $4$ | $1000$ | $341$ | $1365$ | $4$ |

Spelled out for the first row: $8$ is the greatest element of $\{ d : S_2(d) \le 1000 \}$.

---

## 4. Scaling laws

The closed form of §3 is arithmetic. We now convert it into the analytic statements a
physicist would quote, with explicit, uniform constants.

**Theorem 4.1 (Lower power bound).** For $B \ge 2$, $T \ge 1$: $B^{\,d_{\max}(B,T)} \le T$.

*Proof.* $B^{d_{\max}} \le S_B(d_{\max}) \le T$ by Lemma 3.2 and Theorem 3.7. $\square$

**Theorem 4.2 (Upper power bound).** For $B \ge 2$, $T \ge 1$:
$T < B^{\,d_{\max}(B,T) + 2}$.

*Proof.* Write $d = d_{\max}$. By Theorem 3.7, $S_B(d+1) > T$. By Lemma 3.3 applied at
$d+1$, $(B-1)S_B(d+1) + 1 = B^{d+2}$, and since $B-1 \ge 1$ we have
$S_B(d+1) \le (B-1)S_B(d+1) < B^{d+2}$. Chaining, $T < S_B(d+1) < B^{d+2}$. $\square$

Together: the maximal depth is trapped by
$$B^{\,d_{\max}} \;\le\; T \;<\; B^{\,d_{\max}+2}. \tag{4.1}$$

**Theorem 4.3 (Logarithmic depth law).** For $B \ge 2$, $T \ge 1$, with $\log_B$ the real
base-$B$ logarithm,
$$\log_B T - 2 \;<\; d_{\max}(B,T) \;\le\; \log_B T.$$

*Proof.* Apply the strictly increasing map $\log_B$ (valid since $B > 1$) to the two
inequalities of (4.1) and use $\log_B(B^m) = m$. $\square$

The additive constant $2$ is absolute: it depends neither on $B$ nor on $T$.

**Theorem 4.4 (Resolution scaling).** Let the coarsest cell have linear size $\ell_0 > 0$,
so that the finest cell of the maximal cascade has size
$\ell = \ell_0 B^{-d_{\max}(B,T)}$. Then for $B \ge 2$, $T \ge 1$,
$$\frac{\ell_0}{T} \;\le\; \ell \;<\; B^2 \cdot \frac{\ell_0}{T}.$$

*Proof.* Lower bound: $B^{d_{\max}} \le T$ (Theorem 4.1) and $x \mapsto \ell_0/x$ is
decreasing on positives, so $\ell_0/T \le \ell_0/B^{d_{\max}} = \ell$. Upper bound:
$T < B^{d_{\max}+2} = B^{d_{\max}} \cdot B^2$ (Theorem 4.2), so
$\ell_0 T < \ell_0 B^{d_{\max}} B^2$, i.e. $\ell_0 / B^{d_{\max}} < B^2 \ell_0 / T$. $\square$

**Interpretation.** Depth grows *logarithmically* in the budget while resolution improves
*linearly* in it, up to a $B^2$ window that never widens with $T$. In hierarchical
modelling, therefore, the information budget purchases spatial resolution at a fair linear
exchange rate but purchases *scales* at a punishing logarithmic one. If the observable of
interest is the finest length, a holographic budget is generous. If it is the number of
renormalisation steps, no budget is generous.

**Theorem 4.5 (Exact calibration).** For $B \ge 2$ and every $N$, $d_{\max}(B, S_B(N)) = N$.

*Proof.* $S_B(N) \le S_B(N)$ gives $N \le d_{\max}$ by Theorem 3.6. Conversely if
$N < d_{\max}$ then $N+1 \le d_{\max}$, so $S_B(N+1) \le S_B(N)$ by Theorem 3.6 — impossible
since $S_B$ is strictly monotone. $\square$

**Corollary 4.6 (No universal depth).** For every $N$ there is a budget $T \ge 1$ with
$d_{\max}(B,T) \ge N$: take $T = S_B(N)$. Hence the supported depth is unbounded in the
budget, and both bounds of Theorem 4.3 are attained on a subsequence.

---

## 5. Universality of the logarithmic law

Is the closed form an artefact of the particular bookkeeping "one unit per cell of the
tree"? It is not. The following is the central robustness statement of the paper.

**Definition 5.1 (Geometric sandwich).** A cost function $\mathrm{cost}$ is
**$(B,K)$-sandwiched** if $B^d \le \mathrm{cost}(d) \le K \cdot B^d$ for all $d$.

**Theorem 5.2 (Upper half).** Let $B \ge 2$, $T \ge 1$, $\mathrm{cost}(0) \le T$, and
$B^d \le \mathrm{cost}(d)$ for all $d$. Then
$d_{\max}(\mathrm{cost},T) \le \lfloor\log_B T\rfloor$.

*Proof.* Write $d = d_{\max}(\mathrm{cost},T)$. It is supported, so
$B^{d} \le \mathrm{cost}(d) \le T$, and by the defining property of the integer logarithm
$d \le \lfloor\log_B T\rfloor$. $\square$

**Theorem 5.3 (Lower half).** Let $B \ge 2$, $T \ge 1$, $\mathrm{cost}$ strictly monotone,
and $\mathrm{cost}(d) \le K B^d$ for all $d$. Then
$$\lfloor\log_B T\rfloor - \bigl(\lfloor\log_B K\rfloor + 1\bigr) \;\le\; d_{\max}(\mathrm{cost},T).$$

*Proof.* Set $L = \lfloor\log_B T\rfloor$ and $e = \lfloor\log_B K\rfloor + 1$. If $L \le e$
the left-hand side is $0$ (truncated subtraction) and there is nothing to prove. Otherwise
consider the depth $L - e$. By the defining property of the integer logarithm,
$K < B^{e}$. Hence
$$\mathrm{cost}(L-e) \;\le\; K\,B^{L-e} \;<\; B^{e}\,B^{L-e} \;=\; B^{L} \;\le\; T,$$
the last inequality because $B^{\lfloor\log_B T\rfloor} \le T$. So $L-e$ is supported, and
therefore $L - e \le d_{\max}(\mathrm{cost},T)$. $\square$

**Theorem 5.4 (Universality of the logarithmic depth law).** If $\mathrm{cost}$ is strictly
monotone and $(B,K)$-sandwiched, $B \ge 2$, $T \ge 1$, and $\mathrm{cost}(0)\le T$, then
$$\lfloor\log_B T\rfloor - \bigl(\lfloor\log_B K\rfloor + 1\bigr) \;\le\; d_{\max}(\mathrm{cost},T) \;\le\; \lfloor\log_B T\rfloor.$$

*Proof.* Theorems 5.2 and 5.3. $\square$

The width of the window is $\lfloor\log_B K\rfloor + 1$, which depends on the sandwich
constant $K$ **only** — not on $T$, not on the shape of the cost inside the sandwich. This
is the precise sense in which "$d \approx \log_B T$" is a law rather than a coincidence of
one accounting scheme.

### 5.1 Instance: the tree count is sandwiched with $K = 2$

**Lemma 5.5.** For $B \ge 2$ and all $d$: $S_B(d) \le 2 B^d$.

*Proof.* Write $B = C + 2$, $C \ge 0$. By Lemma 3.3, $(C+1)S_B(d) + 1 = (C+2)^{d+1} =
(C+2)(C+2)^d$. It suffices to prove $(C+1)S_B(d) \le (C+1)\cdot 2 B^d$, i.e. (using the
identity) $(C+2)(C+2)^d - 1 \le 2(C+1)(C+2)^d$. Since
$2(C+1) - (C+2) = C \ge 0$, we have $(C+2)(C+2)^d \le 2(C+1)(C+2)^d$, and subtracting $1$
only helps. $\square$

Hence by Theorem 5.4 the tree model has
$\lfloor\log_B T\rfloor - (\lfloor\log_B 2\rfloor + 1) \le d_{\max}(B,T) \le \lfloor\log_B T\rfloor$,
recovering the logarithmic law *independently* of the exact arithmetic of §3. (§7 sharpens
the lower end to $\lfloor\log_B T\rfloor - 1$ using that arithmetic.)

### 5.2 Instance: per-cell weight and per-level overhead

**Definition 5.6.** Fix $a \ge 1$, $c \ge 0$. The **energy cost** of a depth-$d$ cascade in
which each cell costs $a$ units and each level carries an extra fixed overhead $c$ is
$$E_{a,c,B}(d) \;=\; a\,S_B(d) + c\,(d+1).$$
The term $c(d+1)$ models a boundary or gauge-fixing charge levied once per scale.

**Lemma 5.7.** For $B \ge 2$ and all $d$: $d + 1 \le B^d$.

*Proof.* Induction. $d=0$: $1 \le 1$. Step: $B^{d+1} = B \cdot B^d \ge 2 B^d \ge B^d + 1 \ge (d+1)+1$,
using $B^d \ge 1$ and the inductive hypothesis. $\square$

**Lemma 5.8.** $E_{a,c,B}$ is strictly monotone (for $a \ge 1$, $B \ge 2$), satisfies
$B^d \le E_{a,c,B}(d)$, and $E_{a,c,B}(d) \le (2a+c)B^d$.

*Proof.* Strict monotonicity: $S_B$ is strictly monotone and $a \ge 1$, while $c(d+1)$ is
monotone. Lower bound: $B^d \le S_B(d) \le a S_B(d) \le E_{a,c,B}(d)$. Upper bound: by
Lemma 5.5, $a S_B(d) \le 2a B^d$; by Lemma 5.7, $c(d+1) \le c B^d$; sum. $\square$

**Theorem 5.9 (Robustness under model perturbation).** For $a \ge 1$, $c \ge 0$, $B \ge 2$,
$T \ge 1$ with $E_{a,c,B}(0) \le T$,
$$\lfloor\log_B T\rfloor - \bigl(\lfloor\log_B(2a+c)\rfloor + 1\bigr) \;\le\; d_{\max}(E_{a,c,B},T) \;\le\; \lfloor\log_B T\rfloor.$$

*Proof.* Theorem 5.4 with $K = 2a+c$ and Lemma 5.8. $\square$

Adding a per-level overhead therefore changes only the *offset* of the depth law, never the
law. As a concrete instance, with $a = 2$, $c = 3$, $B = 2$, $T = 10^6$ one has
$\lfloor\log_2 10^6\rfloor = 19$ and $\lfloor\log_2 7\rfloor + 1 = 3$, so the maximal depth
is pinned to $[16, 19]$.

---

## 6. Composition of independent subsystems

Budgets count distinguishable configurations. For two independent regions with budgets
$T_1$ and $T_2$ the joint budget is the product $T_1 T_2$. The following says depth is
additive under this tensoring, up to an absolute and sharp slack of two levels.

**Lemma 6.1.** For $B \ge 2$ and all $x$: $S_B(x) \le B^{x+1}$.

*Proof.* $S_B(x) \le (B-1)S_B(x) < (B-1)S_B(x)+1 = B^{x+1}$ by Lemma 3.3 and $B-1\ge1$. $\square$

**Lemma 6.2 (Superadditivity of cost).** For all $B, x, y$: $S_B(x+y) \le S_B(x)\,S_B(y)$.

*Proof.* Induct on $y$. For $y=0$: $S_B(x)\cdot 1 = S_B(x)$. Step: using
$S_B(x+y+1) = S_B(x+y) + B^{x+y+1}$ and
$S_B(x)S_B(y+1) = S_B(x)S_B(y) + S_B(x)B^{y+1}$, it suffices that
$B^{x+y+1} = B^x B^{y+1} \le S_B(x)B^{y+1}$, which holds since $B^x \le S_B(x)$
(Lemma 3.2), together with the inductive hypothesis. $\square$

**Lemma 6.3 (Subadditivity of cost).** For $B \ge 2$ and all $x,y$:
$S_B(x)\,S_B(y) \le S_B(x+y+1)$.

*Proof.* Induct on $y$. For $y=0$: $S_B(x) \le S_B(x+1)$ by monotonicity. Step: using the
same two splittings as in Lemma 6.2, it suffices that
$S_B(x)B^{y+1} \le B^{x+1}B^{y+1} = B^{x+(y+1)+1}$, which is Lemma 6.1, plus the inductive
hypothesis for the remaining terms. $\square$

**Theorem 6.4 (Superadditivity of depth).** For $B \ge 2$, $T_1, T_2 \ge 1$,
$$d_{\max}(B,T_1) + d_{\max}(B,T_2) \;\le\; d_{\max}(B, T_1T_2).$$

*Proof.* Write $d_i = d_{\max}(B,T_i)$. By Lemma 6.2 and Theorem 3.7,
$$S_B(d_1+d_2) \le S_B(d_1)S_B(d_2) \le T_1 T_2,$$
so $d_1+d_2$ is supported by $T_1T_2$; apply Theorem 3.6. $\square$

**Theorem 6.5 (Subadditivity of depth).** For $B \ge 2$, $T_1,T_2 \ge 1$,
$$d_{\max}(B, T_1T_2) \;\le\; d_{\max}(B,T_1) + d_{\max}(B,T_2) + 2.$$

*Proof.* Suppose not; then $d_1 + d_2 + 3 \le d_{\max}(B,T_1T_2)$, so by Theorem 3.6
$$S_B(d_1+d_2+3) \le T_1 T_2. \tag{6.1}$$
On the other hand each factor is strictly below its own frontier: $S_B(d_i + 1) > T_i$,
i.e. $S_B(d_i+1) \ge T_i + 1$. Hence
$$T_1T_2 < (T_1+1)(T_2+1) \le S_B(d_1+1)\,S_B(d_2+1) \le S_B\bigl((d_1+1)+(d_2+1)+1\bigr) = S_B(d_1+d_2+3),$$
using Lemma 6.3. This contradicts (6.1). $\square$

**Theorem 6.6 (Composition law).** For $B \ge 2$, $T_1,T_2 \ge 1$,
$$d_{\max}(B,T_1) + d_{\max}(B,T_2) \;\le\; d_{\max}(B,T_1T_2) \;\le\; d_{\max}(B,T_1)+d_{\max}(B,T_2)+2,$$
and both ends are attained.

*Proof.* Theorems 6.4 and 6.5. Attainment, with $B = 2$:
*Additive end.* $d_{\max}(2,7) = 2$ (since $S_2(2)=7\le 7 < 15 = S_2(3)$) and
$d_{\max}(2,49) = 4$ (since $S_2(4)=31 \le 49 < 63 = S_2(5)$), and $4 = 2+2$.
*Maximal-gap end.* $d_{\max}(2,5)=1$ ($3 \le 5 < 7$), $d_{\max}(2,13)=2$ ($7 \le 13 < 15$),
and $d_{\max}(2,65)=5$ ($63 \le 65 < 127$); indeed $5 = 1+2+2$. Hence the $+2$ cannot be
improved. $\square$

**Corollary 6.7 (Extensivity).** For $B \ge 2$, $T \ge 1$, $n \ge 0$:
$n \cdot d_{\max}(B,T) \le d_{\max}(B, T^n)$.

*Proof.* Induct on $n$ using Theorem 6.4 with $T_1 = T^n$, $T_2 = T$. $\square$

Depth therefore grows at least linearly in the number of tensor factors — the discrete
counterpart of extensivity of the information budget.

---

## 7. The coarse-level deficit and its statistics

We now quantify the modelling choice made in Definition 3.1. Had we charged only for the
finest level, the cost would be $B^d$ and the maximal depth exactly $\lfloor\log_B T\rfloor$.

**Proposition 7.1 (Leaf-only model).** For $B \ge 2$, $T \ge 1$, the greatest $d$ with
$B^d \le T$ is $\lfloor\log_B T\rfloor$.

*Proof.* This is the defining property of the integer logarithm. $\square$

**Definition 7.2 (Deficit).** $\delta(B,T) = \lfloor\log_B T\rfloor - d_{\max}(B,T)$.

**Theorem 7.3 (One-level deficit).** For $B \ge 2$, $T \ge 1$: $\delta(B,T) \in \{0,1\}$,
i.e.
$$\lfloor\log_B T\rfloor - 1 \;\le\; d_{\max}(B,T) \;\le\; \lfloor\log_B T\rfloor.$$

*Proof.* Upper: $B^{d_{\max}} \le S_B(d_{\max}) \le T$, so $d_{\max} \le \lfloor\log_B T\rfloor$
by Proposition 7.1. Lower: write $L = \lfloor\log_B T\rfloor$; if $L = 0$ the claim is
trivial. If $L \ge 1$, then $B^L \le T$, and by Lemma 3.3 at $L-1$,
$$S_B(L-1) \le (B-1)S_B(L-1) < (B-1)S_B(L-1)+1 = B^{L} \le T,$$
so $L - 1$ is supported and $L-1 \le d_{\max}$ by Theorem 3.6. $\square$

**Proposition 7.4 (Exact losslessness criterion).**
$\delta(B,T) = 0 \iff S_B(\lfloor\log_B T\rfloor) \le T$.

*Proof.* ($\Rightarrow$) $d_{\max} = \lfloor\log_B T\rfloor$ and $d_{\max}$ is supported.
($\Leftarrow$) The hypothesis makes $\lfloor\log_B T\rfloor$ supported, so
$\lfloor\log_B T\rfloor \le d_{\max}$; combine with Theorem 7.3. $\square$

### 7.1 Which budgets pay?

Organise budgets by scale.

**Definition 7.5 (Scale block).** For $B \ge 2$, $L \ge 0$, the scale-$L$ block is
$\mathcal{B}(B,L) = \{T : B^L \le T < B^{L+1}\}$, i.e. exactly the budgets with
$\lfloor\log_B T\rfloor = L$. Its cardinality is $B^{L+1} - B^L = (B-1)B^L$.

**Theorem 7.6 (Explicit intervals).** For $B \ge 2$, $L \ge 0$:
$$\{T \in \mathcal{B}(B,L) : \delta(B,T)=0\} = [\,S_B(L),\; B^{L+1}), \qquad
\{T \in \mathcal{B}(B,L) : \delta(B,T)=1\} = [\,B^L,\; S_B(L)).$$

*Proof.* By Proposition 7.4, within the block $\delta(B,T)=0$ iff $S_B(L) \le T$, which
combined with $T < B^{L+1}$ gives the first interval. Its complement in the block is
$[B^L, S_B(L))$, and by Theorem 7.3 the complement is exactly the deficit-one set. Both
descriptions are consistent because $B^L \le S_B(L) \le B^{L+1}$ (Lemma 3.2 and Lemma 6.1),
so both intervals are well-formed subsets of the block. $\square$

**Theorem 7.7 (Self-similarity of the deficit set).** For $B \ge 2$, $L \ge 1$, the number
of lossy budgets at scale $L$ is
$$\#\{T \in \mathcal{B}(B,L) : \delta(B,T)=1\} \;=\; S_B(L) - B^{L} \;=\; S_B(L-1).$$
Equivalently, $(B-1)\cdot\#\{\text{lossy at scale } L\} + 1 = B^{L}$.

*Proof.* The cardinality of $[B^L, S_B(L))$ is $S_B(L) - B^L$, and
$S_B(L) = S_B(L-1) + B^L$ by Lemma 3.2. The geometric form is Lemma 3.3 at $L-1$. $\square$

The population of budgets that lose a level at scale $L$ is thus counted by the same
cascade function, one scale shallower — a genuine self-similarity.

**Theorem 7.8 (Limiting density of the depth penalty).** For $B \ge 2$,
$$\lim_{L\to\infty} \frac{\#\{T\in\mathcal{B}(B,L):\delta(B,T)=1\}}{\#\mathcal{B}(B,L)} \;=\; \frac{1}{(B-1)^2}.$$

*Proof.* By Theorem 7.7 and Lemma 3.3, the numerator equals $(B^L-1)/(B-1)$ for $L \ge 1$,
while the denominator is $(B-1)B^L$. The ratio is
$$\frac{B^L-1}{(B-1)^2 B^L} \;=\; \frac{1-B^{-L}}{(B-1)^2} \;\longrightarrow\; \frac{1}{(B-1)^2}$$
since $0 < 1/B < 1$ implies $B^{-L}\to 0$. $\square$

**Interpretation.** For $B = 2$ the density is $1$: *almost every* binary budget pays the
extra level. This explains, and is not merely consistent with, the empirical observation
that every sampled binary threshold below has deficit $1$. For $B=3$ the density is $1/4$;
for $B = 10$, $1/81$. The physical reading: the coarse-grained levels of a hierarchical
model are a negligible part of its information budget precisely when branching is large,
and are essentially never negligible for binary branching.

---

## 8. Quenched disorder in the branching schedule

Nothing forces a physical cascade to branch uniformly.

**Definition 8.1 (Branching schedule).** A schedule is a map $r : \mathbb{N}\to\mathbb{N}$
assigning to each level the branching number used there. The size of a level-$k$ family is
$$w_r(k) = \prod_{j<k} r(j),$$
and the cost of a depth-$d$ disordered cascade is
$$W_r(d) = \sum_{k=0}^{d} w_r(k).$$
The homogeneous schedule $r \equiv B$ recovers $W_r = S_B$ exactly.

**Lemma 8.2.** If $B_{\min} \le r(k)$ for all $k$ then $B_{\min}^k \le w_r(k)$, hence
$B_{\min}^d \le W_r(d)$. If $r(k) \le B_{\max}$ for all $k$ then $w_r(k) \le B_{\max}^k$,
hence $W_r(d) \le S_{B_{\max}}(d)$. If $r(k) \ge 1$ for all $k$ then $W_r$ is strictly
monotone.

*Proof.* Termwise comparison of products, then of sums. Strict monotonicity holds since
$w_r(d+1) \ge 1 > 0$. $\square$

**Theorem 8.3 (Disorder cannot break the logarithmic law).** Let $2 \le B_{\min}$ and
$B_{\min} \le r(k) \le B_{\max}$ for all $k$. Then for every $T \ge 1$,
$$\lfloor\log_{B_{\max}} T\rfloor - \bigl(\lfloor\log_{B_{\max}} 2\rfloor + 1\bigr) \;\le\; d_{\max}(W_r, T) \;\le\; \lfloor\log_{B_{\min}} T\rfloor.$$

*Proof.* Upper bound: $B_{\min}^d \le W_r(d)$ (Lemma 8.2), so Theorem 5.2 with
$B = B_{\min}$ applies (note $W_r(0)=1\le T$). Lower bound: by Lemma 8.2 and Lemma 5.5,
$W_r(d) \le S_{B_{\max}}(d) \le 2 B_{\max}^d$, so $W_r$ is $(B_{\max},2)$-sandwiched from
above and Theorem 5.3 with $K=2$ applies. $\square$

Setting $B_{\min}=B_{\max}=B$ closes the window to the constant
$\lfloor\log_B 2\rfloor + 1 \le 2$ of the ordered theory.

**Worked disordered instance.** Let $r$ alternate $2,3,2,3,\dots$, i.e. $r(k) = 2$ for
even $k$ and $3$ for odd $k$. Then $w_r = 1, 2, 6, 12, 36, 72, \dots$ and
$W_r = 1, 3, 9, 21, 57, 129, \dots$. With $T = 100$: $W_r(4) = 57 \le 100 < 129 = W_r(5)$,
so by the frontier certificate (Lemma 2.7) the maximal depth is exactly $4$. Theorem 8.3
predicts the window $\lfloor\log_3 100\rfloor - (\lfloor\log_3 2\rfloor+1) = 4-1 = 3 \le d \le 6 = \lfloor\log_2 100\rfloor$,
and indeed $3 \le 4 \le 6$.

---

## 9. Numerical study

All entries are frontier-certified: the stated depth fits, the next fails.

**Run 1 — depth versus threshold at fixed $B = 2$.**

| $T$ | $S_2(d)$ | $S_2(d+1)$ | $d_{\max}$ | $\lfloor\log_2 T\rfloor$ | $\delta$ |
|---|---|---|---|---|---|
| $10$ | $7$ | $15$ | $2$ | $3$ | $1$ |
| $100$ | $63$ | $127$ | $5$ | $6$ | $1$ |
| $1000$ | $511$ | $1023$ | $8$ | $9$ | $1$ |
| $10000$ | $8191$ | $16383$ | $12$ | $13$ | $1$ |

Every sampled binary budget has deficit $1$ — the prediction of Theorem 7.8, whose limiting
density at $B=2$ equals $1$.

**Run 2 — depth versus branching at fixed $T = 1000$.**

| $B$ | $2$ | $4$ | $10$ |
|---|---|---|---|
| $d_{\max}$ | $8$ | $4$ | $2$ |

Depth falls off like $1/\log B$, consistent with Theorem 4.3 and monotone in $B$ as
Corollary 3.9(ii) requires.

**Run 3 — large-budget spot check.** $B=5$, $T = 10^6$: $S_5(8) = 488281 \le 10^6 <
2441406 = S_5(9)$, so $d_{\max} = 8$. Theorem 4.3 requires
$\log_5 10^6 - 2 < 8 \le \log_5 10^6$; numerically $\log_5 10^6 \approx 8.5836$, and indeed
$6.58 < 8 \le 8.58$.

**Run 4 — deficit block counts.** Counting deficit-one budgets in $B^L \le T < B^{L+1}$
reproduces $S_B(L-1)$ for $B \in \{2,3,4,5\}$ and $L \le 5$, in agreement with Theorem 7.7.
The block densities approach $1/(B-1)^2$: $1$, $1/4$, $1/9$, $1/16$ respectively.

**Run 5 — composition sharpness.** $(T_1,T_2) = (7,7)$ realises the additive end,
$(5,13)$ the maximal-gap end (Theorem 6.6).

---

## 10. Discussion

### 10.1 What is actually being claimed

The claim is not that hierarchies in nature are $B$-ary trees, nor that any particular
holographic bound is correct. It is conditional and structural: *given* a branching rule
and *given* an information threshold, the maximal refinement depth is determined, is
computable in closed form, and is provably maximal — and this conclusion is stable under a
wide class of perturbations to the cost model.

The stability is the substantive part. A reader may reasonably distrust the exact formula
$\lfloor\log_B((B-1)T+1)\rfloor - 1$ because it presupposes a bookkeeping convention.
Theorem 5.4 removes that objection: any cost trapped between $B^d$ and $KB^d$ yields the
same law with an offset controlled by $K$. Since essentially every sensible per-level
charging scheme — count leaves, count all cells, weight cells by $a$, add per-level
overhead $c$ — is geometrically sandwiched, the logarithmic law is not a convention.

### 10.2 Depth versus resolution

The most transferable physical statement is Theorem 4.4. Two quantities scale
qualitatively differently in the same budget:
$$d_{\max} = \Theta(\log T), \qquad \ell = \Theta(\ell_0/T).$$
A model whose predictions depend on the *number of scales* (e.g. a renormalisation flow
requiring many decimations, or a concatenated code needing many levels to suppress errors)
is budget-starved: each additional level costs a multiplicative factor $B$ in resource. A
model whose predictions depend on the *finest length* is budget-rich: resolution improves
in direct proportion to the budget. Design decisions in nested error correction and in
multiscale simulation both live on this trade-off.

### 10.3 Composition and extensivity

Theorem 6.6 says depth behaves like a logarithm of an extensive quantity: additive over
independent subsystems, up to a bounded correction. The correction is genuinely there —
$+2$ is attained — and it is exactly the granularity artefact of forcing an integer depth
onto a continuous budget. In the continuum idealisation $d = \log_B T$ the composition law
would be exactly additive.

### 10.4 Statistics of the deficit

Theorem 7.8 is a small but appealing instance of an arithmetic counting identity producing
a genuine analytic limit. It also settles a practical question: *should a modeller bother
charging for coarse levels?* For $B \ge 5$ the answer is that it changes the depth for
fewer than $1/16$ of budgets. For $B = 2$ it changes the depth for asymptotically all of
them.

### 10.5 Limitations

Three deserve mention. First, the model is one-dimensional in the resource: a single
scalar budget $T$. Realistic settings may have several competing constraints (energy *and*
area *and* time). Second, the branching number is a natural number; fractal or
non-integer effective branching would require replacing $S_B$ by a Dirichlet-type sum.
Third, in the disordered setting Theorem 8.3 only localises the depth between the extreme
logarithms; the true location should be governed by the *geometric mean* of the schedule,
which is the first open direction below.

---

## 11. Future directions

**Direction 1 — second-order term of the disordered depth.** Between
$\log_{B_{\max}} T$ and $\log_{B_{\min}} T$ the disordered depth must have a definite
location determined by the geometric mean of the schedule, not by its extremes.
*Conjecture:* for a schedule whose log-averages converge, $d_{\max}(W_r, T)$ equals
$\log T / \overline{\log r}$ up to $O(1)$, where $\overline{\log r}$ is the limiting
average of $\log r(j)$. The mechanism is that $w_r(k) = \exp\bigl(\sum_{j<k}\log r(j)\bigr)$
turns the budget inequality into an ergodic-average statement, so the depth is governed by
a Birkhoff average rather than by the endpoints of the quench window. The two inequalities
of Theorem 8.3 isolate exactly what must be sharpened, and the sandwich machinery of
Theorem 5.4 generalises verbatim once the constant base $B^d$ is replaced by $w_r(d)$.

**Direction 2 — exact density spectrum of the depth deficit.** Theorem 7.8 gives density
$1/(B-1)^2$ for the deficit-one set inside a scale block. *Conjecture:* for the perturbed
cost models of §5 (per-cell weight $a$, per-level overhead $c$) the analogous deficit takes
values in $\{0,\dots,\lfloor\log_B(2a+c)\rfloor+1\}$ and each value has a limiting density
which is a rational function of $B$, $a$, $c$. The mechanism is that the deficit is decided
by the position of $T$ relative to the finitely many thresholds $\mathrm{cost}(L-j)$ inside
a block, so the density vector is a partition of a geometric block into finitely many
explicitly computable intervals — precisely the block decomposition of §7.1.

**Direction 3 — several competing budgets.** Replace the scalar $T$ by a vector of
constraints (cells, boundary area, energy) each with its own cost function. The support set
becomes an intersection of initial segments, hence still an initial segment, and the
maximal depth is the minimum of the individual maximal depths. Quantifying *which*
constraint binds, as a function of the parameters, is a natural next step.

**Direction 4 — non-integer effective branching.** Replace $S_B(d)$ by
$\sum_{k\le d}\mu^k$ for real $\mu>1$ (an effective, possibly fractal branching). All of
§3–§6 should survive with $\lfloor\cdot\rfloor$ replacing exact integer logarithms; the
deficit statistics of §7 would then concern equidistribution of $\log_\mu T$ modulo $1$
rather than a clean interval count.

---

## 12. Conclusion

For a $B$-ary refinement cascade constrained by an information threshold $T$, the largest
supported depth is
$$d_{\max}(B,T) = \bigl\lfloor\log_B((B-1)T+1)\bigr\rfloor - 1,$$
and it is maximal, unique, and computed rather than sampled: the supported depths are
exactly $0,\dots,d_{\max}$, and depth $d_{\max}+1$ provably exceeds the budget. This
closed form is embedded in a structure theory that is uniform in the parameters: the depth
equals $\log_B T$ to within an absolute additive $2$; the finest resolvable length obeys
$\ell_0/T \le \ell < B^2\ell_0/T$; the law is universal across all geometrically sandwiched
cost models with slack $\log_B K + 1$; depth is additive under composition of independent
regions up to a sharp $+2$; the price of charging for coarse levels is at most one level,
paid with limiting density $1/(B-1)^2$; and quenched disorder in the branching schedule
merely relocates the depth within the window between the extreme logarithms.

The recurring theme is that a statement usually made qualitatively — "hierarchical depth is
logarithmic in the information budget" — can be made exact, uniform, and robust, with every
constant named.
