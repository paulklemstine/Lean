# Stability and Generic Collisions of the Tropical Min-Plus Hash

## Abstract

We study a hash function built from the min-plus (tropical) semiring, defined on a
message $m = (m_1,\dots,m_k) \in \mathbb{R}^k$ and a fixed key $h \in \mathbb{R}^k$
by $\mathrm{TSHA}(h, m) = \min_i (m_i + h_i)$. Although the forward evaluation is
optimal — linear in the message length — we prove two structural results that
together explain why the single-key construction cannot serve as a cryptographic
hash. First, a **stability theorem**: the digest is $1$-Lipschitz in the message
with respect to the supremum norm, so small input perturbations produce
proportionally small output changes, in direct contradiction to the avalanche
property required of cryptographic hashes. Second, a **generic collision
theorem**: whenever the message has at least two coordinates, every message admits
an explicitly constructible distinct message with the identical digest, so
preimages are never unique. We give complete proof sketches, analyze the proposed
two-key remedy $\mathrm{TSHA2}$ and its collision behavior, present algorithms for
evaluation and collision generation, and discuss the correct locus of hardness —
constrained two-key inversion as a layered shortest-path problem. The overall
message is a sharp instance of a general principle: analytic regularity and
cryptographic strength are antagonistic.

## 1. Introduction

### 1.1 Motivation

Proof-of-work cryptocurrencies secure their ledgers by requiring miners to find a
nonce $n$ such that $H(\text{header} \,\|\, n) < T$ for a cryptographic hash $H$
and target $T$. The security and the energy cost both stem from a single
property: $H$ is a pseudorandom function with no exploitable structure, so the
only method is exhaustive trial. A recurring aspiration is to replace this
structureless search with a *meaningful* computation — an optimization problem
whose solution has independent value — so that "mining is mathematics."

The min-plus semiring is a natural candidate arithmetic for such a scheme,
because in it the fundamental operations *are* the operations of combinatorial
optimization: shortest paths, scheduling, and network flow are all evaluated by
alternating additions and minima. We therefore ask whether a hash built from
min-plus arithmetic can be one-way, and we answer, precisely, why the simplest
such construction fails.

### 1.2 The min-plus semiring

The **tropical** (min-plus) semiring is the set $\mathbb{R} \cup \{+\infty\}$
equipped with
$$a \oplus b = \min(a, b), \qquad a \otimes b = a + b.$$
Tropical addition $\oplus$ is associative, commutative, and idempotent, with
identity $+\infty$; tropical multiplication $\otimes$ is ordinary addition, with
identity $0$; and $\otimes$ distributes over $\oplus$. There is no additive
inverse: the structure is a semiring, not a ring. A tropical inner product of two
vectors $u, v \in \mathbb{R}^k$ is
$$\langle u, v \rangle_{\text{trop}} = \bigoplus_i (u_i \otimes v_i) = \min_i (u_i + v_i),$$
which is exactly the kernel of shortest-path and assignment computations.

### 1.3 Contributions

1. A precise **stability theorem**: $\mathrm{TSHA}(h,\cdot)$ is $1$-Lipschitz in
   the supremum norm (Theorem 3.1).
2. A **generic collision theorem** with an explicit construction: for $k \ge 2$
   every message has a distinct sibling with the same digest (Theorem 4.1),
   supported by structural lemmas on the minimizer (Lemmas 2.1–2.4).
3. An analysis of the two-key remedy $\mathrm{TSHA2}$: why it strictly refines the
   single-key collision relation, and a conjectured $\Theta(1/k)$ residual
   collision rate (Section 5).
4. Algorithms for evaluation, deterministic collision generation, and the
   inversion-as-shortest-path reformulation (Section 6), with numerical
   corroboration (Section 7).

## 2. Definitions and structural lemmas

Throughout, $\iota$ is a finite nonempty index set of size $k$, and messages and
keys are functions $\iota \to \mathbb{R}$, equivalently vectors in
$\mathbb{R}^k$.

**Definition 2.1 (Tropical hash).** For a key $h : \iota \to \mathbb{R}$ and
message $m : \iota \to \mathbb{R}$,
$$\mathrm{TSHA}(h, m) = \inf_{i \in \iota} \bigl( m_i + h_i \bigr) = \min_{i \in \iota} \bigl(m_i + h_i\bigr),$$
the infimum being a minimum because $\iota$ is finite and nonempty.

We isolate four elementary facts about the minimum that drive everything else.

**Lemma 2.1 (Reduction to a finite minimum).** The digest equals the minimum of
the finite family $\{m_i + h_i\}_{i \in \iota}$ over the (nonempty) index set.
*Proof sketch.* For a finite nonempty family the infimum over the type agrees with
the finite minimum. $\square$

**Lemma 2.2 (Lower envelope).** For every index $i$, $\mathrm{TSHA}(h, m) \le m_i + h_i$.
*Proof sketch.* The minimum of a finite family is a lower bound for each member. $\square$

**Lemma 2.3 (Attained minimizer).** There exists an index $i^\star$ with
$\mathrm{TSHA}(h, m) = m_{i^\star} + h_{i^\star}$.
*Proof sketch.* A finite nonempty family attains its minimum. $\square$

**Lemma 2.4 (Minimizer characterization).** If an index $i$ satisfies
$m_i + h_i \le m_j + h_j$ for all $j$, then $\mathrm{TSHA}(h, m) = m_i + h_i$.
*Proof sketch.* Such $i$ is both a lower bound (it is $\le$ every term) and a
member of the family, so it equals the minimum by antisymmetry. $\square$

## 3. Stability: the tropical hash is 1-Lipschitz

**Theorem 3.1 (Stability / $1$-Lipschitz property).** For every key $h$ and all
messages $m, m'$,
$$\bigl| \mathrm{TSHA}(h, m) - \mathrm{TSHA}(h, m') \bigr| \;\le\; \sup_{i \in \iota} |m_i - m'_i| \;=\; \lVert m - m' \rVert_\infty.$$

*Proof sketch.* Write $a_i = m_i + h_i$ and $b_i = m'_i + h_i$; then
$a_i - b_i = m_i - m'_i$, so $\sup_i |a_i - b_i| = \lVert m - m' \rVert_\infty$.
It therefore suffices to prove the general fact that the minimum of a finite
nonempty family is $1$-Lipschitz:
$$\bigl| \min_i a_i - \min_i b_i \bigr| \le \sup_i |a_i - b_i|.$$
Let $\varepsilon = \sup_i |a_i - b_i|$. For each $i$, $a_i \le b_i + \varepsilon$,
hence $\min_i a_i \le b_{i} + \varepsilon$ for every $i$ and thus
$\min_i a_i \le \min_i b_i + \varepsilon$. By symmetry
$\min_i b_i \le \min_i a_i + \varepsilon$, which is the claim. Substituting the
identity for $\sup_i |a_i - b_i|$ finishes the proof. $\square$

**Remark 3.2 (Sharpness).** The bound is attained: with $k = 1$ (or by moving only
the winning coordinate), shifting the minimizing term by $\varepsilon$ shifts the
digest by exactly $\varepsilon$. Thus the Lipschitz constant $1$ cannot be
improved.

**Corollary 3.3 (No avalanche).** A cryptographic hash requires that flipping one
input bit changes roughly half the output bits (the strict avalanche criterion).
Theorem 3.1 shows the opposite: bounded input changes cause bounded output
changes, so an adversary can perform gradient-free hill climbing on the digest.
The single-key tropical hash is therefore unsuitable as a preimage-resistant
primitive.

## 4. Generic collisions: preimages are never unique

**Theorem 4.1 (Generic collision).** Suppose $|\iota| \ge 2$. Then for every key
$h$ and every message $m$ there is a message $m' \ne m$ with
$$\mathrm{TSHA}(h, m') = \mathrm{TSHA}(h, m).$$

*Proof sketch.* By Lemma 2.3 pick a minimizer $i^\star$, so
$\mathrm{TSHA}(h, m) = m_{i^\star} + h_{i^\star}$. Because $|\iota| \ge 2$ there is
an index $k^\star \ne i^\star$. Define $m'$ by increasing the message at that
single non-minimizing coordinate:
$$m'_i = \begin{cases} m_i + 1, & i = k^\star, \\ m_i, & i \ne k^\star. \end{cases}$$
Then $m' \ne m$ because $m'_{k^\star} = m_{k^\star} + 1 \ne m_{k^\star}$.
To see the digest is unchanged, we verify that $i^\star$ is still a minimizer of
$m'$ and apply Lemma 2.4. For $j \ne k^\star$ we have $m'_j = m_j$, so
$m'_{i^\star} + h_{i^\star} = m_{i^\star} + h_{i^\star} \le m_j + h_j = m'_j + h_j$
by Lemma 2.2. For $j = k^\star$, $m'_{k^\star} + h_{k^\star} = m_{k^\star} + h_{k^\star} + 1 \ge m_{k^\star} + h_{k^\star} \ge m_{i^\star} + h_{i^\star} = m'_{i^\star} + h_{i^\star}$,
again using Lemma 2.2. Hence $i^\star$ minimizes $m'$ as well, and by Lemma 2.4
$\mathrm{TSHA}(h, m') = m'_{i^\star} + h_{i^\star} = m_{i^\star} + h_{i^\star} = \mathrm{TSHA}(h, m)$. $\square$

**Remark 4.2 (Structure of the collision fiber).** The proof does more than
exhibit one collision: it shows that *any* increase of *any* non-minimizing
coordinate, and more generally any modification that keeps some coordinate the
active minimizer at its current value, preserves the digest. Consequently the
preimage of a generic value is a full-dimensional polyhedral region — a union of
tropical half-spaces — rather than a thin set. The digest destroys exactly one
degree of freedom (the value of the winning coordinate) and leaves the other
$k-1$ coordinates free above a threshold. This is the geometric reason collisions
are generic rather than accidental.

## 5. The two-key construction TSHA2

To combat the guaranteed collisions of Theorem 4.1, one may use two independent
keys $h, h' : \iota \to \mathbb{R}$ and define
$$\mathrm{TSHA2}(m) = \bigl( \mathrm{TSHA}(h, m),\ \mathrm{TSHA}(h', m) \bigr) = \Bigl( \min_i (m_i + h_i),\ \min_i (m_i + h'_i) \Bigr).$$

**Why it helps.** The single-key collision of Theorem 4.1 inflates a coordinate
$k^\star$ that loses under $h$. That same coordinate need not lose under $h'$: if
$k^\star$ is the *active minimizer* of the second key, inflating it strictly
increases $\mathrm{TSHA}(h', \cdot)$ and thereby breaks the collision in the second
component. Two independent keys thus *separate* pairs that a single key confuses;
the two-key collision relation is a strict refinement of the single-key one.

**Why it is not a full fix.** A pair $(m, m')$ collides under $\mathrm{TSHA2}$ iff
it collides under *both* keys. The single-key construction of Theorem 4.1 perturbs
exactly one coordinate $k^\star$. An independent second key $h'$ *separates* (breaks)
that collision precisely when $k^\star$ is the unique active minimizer of $h'$ —
for keys drawn from a continuous distribution over $k$ coordinates, an event of
probability $\Theta(1/k)$. Consequently the pair *still collides* under the second
key with probability $1 - \Theta(1/k)$: a fresh second key rarely helps.

**Conjecture 5.1 (Sharp two-key separation rate).** For two independent keys drawn
from a continuous distribution over $k$ coordinates, the probability that the
second key separates a single-key collision produced by perturbing one coordinate
is $\Theta(1/k)$; equivalently the pair still collides with probability
$1 - \Theta(1/k)$, and no uncorrelated second key can asymptotically beat the
$1/k$ separation rate.

The improvement from a second key is therefore *inverse-linear*, not exponential.
Because
Theorem 3.1 still applies to each component, approximate inversion remains easy,
and $\mathrm{TSHA2}$ — while strictly stronger than $\mathrm{TSHA}$ — does not
attain the avalanche behavior of standard cryptographic hashes.

## 6. Algorithms

### 6.1 Forward evaluation

Evaluating $\mathrm{TSHA}$ is a single linear scan.

```
function TSHA(h, m):            # h, m in R^k
    best <- +infinity
    for i in 1..k:
        best <- min(best, m[i] + h[i])
    return best
```

Complexity: $k$ additions and $k-1$ comparisons, i.e. $O(k)$ time and $O(1)$
extra space. The two-key digest $\mathrm{TSHA2}$ is two such scans, still $O(k)$.

### 6.2 Deterministic collision generation

Theorem 4.1 is constructive, so a collision requires no search.

```
function collide(h, m, delta > 0):        # returns m' != m, same digest
    i_star <- argmin_i (m[i] + h[i])
    choose k_star != i_star               # exists when k >= 2
    m' <- copy(m)
    m'[k_star] <- m'[k_star] + delta      # inflate a losing coordinate
    return m'
```

Complexity: $O(k)$ to find the minimizer, $O(1)$ to perturb. The output satisfies
$\mathrm{TSHA}(h, m') = \mathrm{TSHA}(h, m)$ for every $\delta > 0$ by the proof
of Theorem 4.1.

### 6.3 Inversion as a shortest-path selection

Given a target value $y$, a key $h$, and per-coordinate ranges
$m_i \in [\ell_i, u_i]$, a message with $\mathrm{TSHA}(h, m) = y$ exists iff
(a) some coordinate can achieve $m_i + h_i = y$ with $m_i \in [\ell_i, u_i]$
(the *active* coordinate), and (b) all other coordinates can stay at or above $y$,
i.e. $u_i + h_i \ge y$. This is a feasibility scan for one key. For the two-key
digest $(y, y')$, the active coordinates for $h$ and $h'$ must be chosen jointly
so that both minima are witnessed while all range constraints hold — a
simultaneous selection on a layered min-plus network.

```
function invert_single(h, y, lower, upper):
    active <- { i : lower[i] + h[i] <= y <= upper[i] + h[i] }
    if active is empty: return INFEASIBLE
    feasible_others <- for all i: upper[i] + h[i] >= y
    if not feasible_others: return INFEASIBLE
    pick a in active; set m[a] = y - h[a]
    for i != a: set m[i] = clamp(y - h[i], lower[i], upper[i])  # any value >= y - h[i]
    return m
```

Single-key inversion is thus $O(k)$ and easy — another symptom of insecurity. The
conjectured hardness appears only for the two-key, range-constrained variant.

**Conjecture 6.1 (Hardness of constrained two-key inversion).** Recovering a
message consistent with a prescribed two-key digest $(y, y')$ subject to
per-coordinate range constraints that couple the two keys is polynomially
equivalent to a min-cost feasibility problem on a layered min-plus network and is
NP-hard once the constraints couple the keys.

## 7. Numerical corroboration

The companion demonstrations verify the theorems empirically over random keys and
messages:

- **Stability.** Across many random pairs $(m, m')$, the observed ratio
  $|\mathrm{TSHA}(h,m) - \mathrm{TSHA}(h,m')| / \lVert m - m'\rVert_\infty$ never
  exceeds $1$ and is attained (equals $1$) when only the winning coordinate is
  moved, confirming Theorem 3.1 and its sharpness (Remark 3.2).
- **Guaranteed collisions.** The deterministic constructor of Section 6.2 yields a
  distinct message with an identical digest in $100\%$ of trials for $k \ge 2$,
  confirming Theorem 4.1.
- **Two-key refinement.** A random independent second key separates a single-key
  collision with an empirical frequency that scales as $\Theta(1/k)$ (the product
  $k \times (\text{separation rate})$ stays near a constant), consistent with
  Conjecture 5.1 and confirming that the improvement is only inverse-linear.
- **Difficulty comparison.** Whereas a SHA-style target requires
  $\Theta(1/p)$ expected trials to hit a probability-$p$ target, the tropical
  digest is invertible in one linear pass, quantifying the security gap.

## 8. Discussion

The two theorems form a clean impossibility argument for the naive scheme.
Theorem 3.1 shows the digest is a *faithful, Lipschitz shadow* of the message;
Theorem 4.1 shows that shadow is *never cast by a unique object*. Both follow
inexorably from the meaning of "minimum," which depends only on a single active
coordinate and is insensitive to the others. The very regularity that makes
min-plus arithmetic the right language for optimization is what disqualifies it as
a source of one-wayness.

This is a concrete instance of a general antagonism: cryptographic strength
demands the destruction of structure (avalanche, pseudorandomness), whereas the
tropical semiring is defined by its structure. The productive reading of these
results is not "tropical mining is impossible" but "tropical mining must be
anchored in inversion, not evaluation": the honest hard problem is the
constrained two-key shortest-path selection of Conjecture 6.1, not the forward
hash.

## 9. Future work

- **Exact collision-fiber dimension.** Make Remark 4.2 quantitative: prove that
  the preimage of a generic value is generically a $(k-1)$-dimensional polyhedral
  region, a union of $k$ tropical half-spaces.
- **Sharp two-key collision rate.** Prove Conjecture 5.1's $\Theta(1/k)$ rate and
  the matching lower bound for uncorrelated keys.
- **Hardness of constrained inversion.** Prove Conjecture 6.1, establishing the
  polynomial equivalence to layered min-plus feasibility and NP-hardness under
  coupling constraints — the property a genuine proof-of-optimization coin would
  require.

## 10. Conclusion

We proved that the single-key tropical hash $\mathrm{TSHA}(h,m) = \min_i(m_i+h_i)$
is $1$-Lipschitz in the supremum norm and admits guaranteed, explicitly
constructible collisions whenever $k \ge 2$. These results rule out the naive
"mining as tropical hashing" proposal but sharply relocate the potential
hardness to constrained two-key inversion, framed as a shortest-path selection
problem. The tropical semiring cannot hide a secret by evaluation; if it is to
secure anything, it must do so through the one genuinely hard problem it
contains.
