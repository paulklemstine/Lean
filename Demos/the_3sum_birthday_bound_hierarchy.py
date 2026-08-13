"""Assemble PACKAGE.json from the deliverable files and the inline assets."""

from __future__ import annotations

import json
import pathlib
from typing import Any, Dict, List

ROOT = pathlib.Path(__file__).resolve().parent.parent


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


LEAN_FILES: List[str] = [
    "Catalog/Speculative/AutoResearch/ThreeSumBirthdayHierarchy.lean",
    "Catalog/Logic/ThreeSumRevealDensity.lean",
    "Catalog/Logic/GcdQueryLowerBound.lean",
    "Catalog/Logic/BirthdayCountingBound.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== FILE: {f} =====\n\n{read(f)}" for f in LEAN_FILES
)

FUTURE_DIRECTIONS = r"""# Future Directions

**What survived this cycle:** the factor-reveal lemma and its four-case classification; the arity-uniform pigeonhole pair (more than $p$ tuples necessary **and** sufficient at every arity); the reveal-density count of $q-1$ successes out of $q$ witnesses per period; the arity-reduction identity 3SUM = sumset table + $k$ lookups; the unconditional gcd-query lower bound $|Q| \ge (|P|-1)/\log_2 M$; and the counting birthday bound.

**What did *not* survive:** the claim that *all* rows of the hierarchy table cost $\Theta(\sqrt{N})$. That is correct for deterministic guarantees only; the counting bound shows the randomised threshold is $\Theta(\sqrt{p}) = \Theta(N^{1/4})$. The corrected statement is a two-level barrier: deterministic $\sqrt{N}$ and randomised $N^{1/4}$.

---

## Conjecture 1 (arity-independence is an information-theoretic law)

*Statement.* For every arity $r$ and every family $F$ of $r$-subsets of a $k$-set, a search that guarantees a sum collision mod $p$ must satisfy $|F| > p$, and moreover for randomised search with success probability $\varepsilon$ the requirement is $|F| \ge \sqrt{2\varepsilon p}$ — with **no dependence on $r$ in either bound**.

**The key insight is** that the arity only re-packages the same $|F|$ residue evaluations, so the entropy available to the searcher is $\log|F|$ regardless of how the tuples are structured; the exponent $1/r$ lives in the *size of the generating set*, never in the *cost*.

*Why now?* Both endpoints (more than $p$ deterministic, $\Omega(\sqrt{p})$ randomised) are already proved here for subset-sum evaluations; the remaining step is to replace "subset sum" by an arbitrary evaluation, which the adversary construction behind the optimality of the threshold already supports.

## Conjecture 2 (gcd-query barrier is tight up to $\log$)

*Statement.* For every $n$ there is a query set $Q$ with $|Q| = O(n \log n / \log M)$ that reveals a factor of every semiprime built from the first $n$ primes below $M$; combined with the gcd-query lower bound $|Q| \ge (n-1)/\log_2 M$, the gcd-query complexity of factoring over a prime pool of size $n$ is $\tilde\Theta(n/\log M)$.

**The key insight is** that the lower bound counts *touched primes*, and a matching upper bound is obtained by packing primes into products of size $\le M$ — a covering-design problem, not a number-theoretic one.

*Why now?* The lower bound is proved unconditionally; the upper bound is a finite combinatorial construction (product trees), so the conjecture is falsifiable by an explicit $Q$ for small $n$ and testable by exhaustive check.

## Conjecture 3 (3SUM-hardness transfer)

*Statement.* If 3SUM over $n$ integers requires $n^{2-o(1)}$ time, then any factoring algorithm that only inspects sums of at most $3$ elements of an adaptively chosen set $S \subseteq \mathbb{Z}/p\mathbb{Z}$, and gcds thereof, requires $p^{2/3-o(1)}$ operations; conversely, a truly subquadratic 3SUM algorithm would yield a corresponding speedup for such structured searches.

**The key insight is** that the arity-reduction identity places 3SUM exactly one layer above the sumset, so a hardness statement about triples transfers to a statement about the pair table that every collision-based factoring method already builds.

## Further questions

- Does the two-level barrier persist for evaluations with algebraic structure, such as the polynomial iteration $x \mapsto x^2 + 1$ used by the classical rho method?
- Can the integer union bound be sharpened to a matching upper bound, turning the $\sqrt{p}$ barrier into a genuine threshold?
- Is there an arity-graded analogue of the reveal density, counting revealing $r$-tuples rather than revealing residues?
- Can the gcd-query lower bound be extended to *adaptive* queries, where each query may depend on the gcds returned so far?
"""

INTERACTIVE_LAYOUT = r"""# Three Numbers That Add to Nothing

### A guided tour of the 3SUM–birthday-bound hierarchy

Take the number $143$. Take three small numbers, $1$, $4$ and $6$, and add them: $1 + 4 + 6 = 11$. Now ask for the greatest common divisor of $11$ and $143$ — a computation so cheap it is essentially free — and out drops $11$, a prime factor of $143$.

That is not a coincidence, and it is not special to $143$. This page is a tour of what is really going on: a bridge between **3SUM**, the innocuous question of whether three numbers add to zero, and **integer factoring**, the problem that guards most encrypted traffic on the planet. At the end of the bridge there is not a shortcut but a **wall** — and the wall, it turns out, has two different heights.

---

## 1. The reveal

Here is the whole mechanism, in one line.

> **Factor Reveal.** Let $N = pq$ be a product of two distinct primes. For any integer $s$,
> $$\gcd(s, N) = p \iff p \mid s \ \text{ and } \ q \nmid s.$$

Read left to right: producing *any* multiple of the hidden prime $p$ that is not also a multiple of $q$ is as good as factoring $N$. You never need to know $p$ — the gcd extracts it for you.

Read right to left: it is an exact characterisation, so the two ways of failing are completely understood. Hit both primes and the gcd returns $N$; hit neither and it returns $1$. Either way, nothing is learned.

<details>
<summary>The complete four-case classification (click to expand)</summary>

For distinct primes $p \ne q$ and any integer $s$,
$$\gcd(s, pq) = \begin{cases} pq, & p \mid s \text{ and } q \mid s,\\ p, & p \mid s,\ q \nmid s,\\ q, & q \mid s,\ p \nmid s,\\ 1, & \text{neither divides } s.\end{cases}$$

*Proof of the informative case.* Since $p \mid s$ and $p \mid pq$ we have $p \mid \gcd(s,pq)$, so write $\gcd(s,pq) = pt$. From $pt \mid pq$ we get $t \mid q$, so $t = 1$ or $t = q$ by primality. If $t = q$ then $q$ divides the gcd, which divides $s$ — contradicting $q \nmid s$. Hence $t = 1$ and the gcd is exactly $p$. $\blacksquare$

Specialising to $s = a + b + c$ gives the **3SUM factor reveal**: a triple whose sum vanishes modulo a hidden prime factor exposes that factor.
</details>

Play with it. Choose the two hidden primes and a range of small numbers; the widget enumerates every triple $a < b < c$ whose sum is a multiple of the hidden prime and shows what the gcd actually returns. Green cells reveal; red cells are the one failure mode.

{{interactive_demo:0}}

**What to notice in Tab 1.** For $N = 143$ with triples drawn from $1 \dots 11$, exactly $15$ triples have a sum divisible by $11$, and **none** has a sum divisible by $143$ — so all $15$ reveal the factor. That is not luck: the largest sum available is $9 + 10 + 11 = 30 < 143$, so the failure mode is out of reach. Widen the range and you will eventually see red cells appear.

<details>
<summary>How often does the reveal misfire? An exact count.</summary>

> **Reveal Density.** Among $0 < s \le N = pq$, exactly $q$ values are multiples of $p$, and exactly $q-1$ of them satisfy $\gcd(s,N) = p$. The single exception is $s = N$ itself.

So conditioned on having produced a multiple of $p$, the reveal succeeds with probability $(q-1)/q$ — for $N = 143$, twelve times out of thirteen. The non-degeneracy hypothesis "$q$ does not divide $s$" attached to every reveal theorem is therefore genuine but negligible: for cryptographic parameters, $1/q$ has hundreds of zeros after the decimal point.
</details>

---

## 2. Turning the reveal into an algorithm

The gcd step is free. Everything expensive happens *before* it. Here is the atomic operation, isolated:

{{algorithm:0}}

Note the asymmetry that will drive the rest of the page: **testing a witness costs one Euclidean algorithm; finding a witness is the entire problem.**

---

## 3. Three ways to hunt for a witness — and why they cost the same

You cannot search modulo $p$, because you do not know $p$. But you can search for *collisions*, and a collision modulo the hidden prime produces a difference divisible by it. There are three natural styles, graded by **arity**:

| Arity | Collision sought | Search set needed | Tuples enumerated |
|---|---|---|---|
| $1$ | two residues coincide | $k \gtrsim p$ | $k$ |
| $2$ | $a + b \equiv c + d$ | $k \gtrsim \sqrt{2p}$ | $\binom{k}{2}$ |
| $3$ | $a + b + c \equiv 0$ | $k \gtrsim (6p)^{1/3}$ | $\binom{k}{3}$ |

The search set shrinks dramatically as the arity grows — the exponent improves from $1$ to $1/2$ to $1/3$. Surely something is gained? Switch to **Tab 2** of the explorer above and change the modulus: watch the middle column collapse while the last column refuses to move.

The reason is a matching pair of bounds.

> **Arity-Uniform Threshold.** An arity-$r$ collision search over a $k$-set is guaranteed to find a collision modulo $p$ — against *every* possible evaluation — **if and only if** $\binom{k}{r} > p$.

<details>
<summary>Why the threshold $p+1$ is exactly optimal (both directions)</summary>

**Sufficiency (pigeonhole).** If $\binom{k}{r} > p$, the $\binom{k}{r}$ subset sums cannot all be distinct in a set of $p$ residues; two must coincide.

**Necessity (adversary).** If at most $p$ tuples are enumerated, there is room to assign them *all distinct* residues — an injection into $\{0,\dots,p-1\}$ exists. So the guarantee fails for that evaluation, and no bound below $p+1$ can be claimed.

Since $\lfloor\sqrt{pq}\rfloor \le p$ whenever $q \le p$, a guaranteed collision search on a semiprime $N = pq$ enumerates more than $\sqrt{N}$ tuples — **at every arity**. The arity repackages the work; it never removes it.
</details>

The generic engine, covering all three rows as one procedure:

{{algorithm:1}}

And there is a structural reason arity $3$ cannot secretly be cheaper than arity $2$:

> **Arity Reduction.** A 3SUM solution inside $S$ exists precisely when $-c$ lies in the sumset $S+S$ for some $c \in S$.

In other words, the triple search *is* the pair table plus $|S|$ lookups. Nothing hides in the extra dimension.

{{algorithm:2}}

---

## 4. The same lemma wearing four costumes

3SUM is not the only source of witnesses, and that is precisely the point of calling this a *hierarchy*. All of the following feed the identical divisibility test:

- **Sumset differences.** A collision $x \equiv y \pmod p$ with $y \le x$ gives $p \mid x - y$.
- **3SUM sums.** $a+b+c \equiv 0 \pmod p$ gives $p \mid a+b+c$.
- **Pollard's $p-1$.** If $(p-1) \mid k$ and $p \nmid a$, then Fermat's little theorem gives $p \mid a^k - 1$.
- **Singular-moduli differences,** and any other algebraic construction producing a multiple of $p$.

Four mechanisms, one lemma, one gcd. That unification is what licenses treating them as a single hierarchy rather than four unrelated tricks — and it is what makes a single barrier theorem meaningful.

---

## 5. Closing the loophole: forget collisions, count the queries

A sceptic will object: all of that bounds one *mechanism*. What if a cleverer algorithm produces its multiples of $p$ some entirely different way?

The objection can be answered without assuming anything about the mechanism, by bounding the one interface every such method must use — the gcd itself.

> **gcd-Query Bound.** Let $Q$ be a finite set of nonzero integers, each at most $M$. If some query of $Q$ has a nontrivial gcd with *every* semiprime built from two distinct primes of a pool $P$, then
> $$|P| \le |Q| \log_2 M + 1, \qquad\text{equivalently}\qquad |Q| \ge \frac{|P| - 1}{\log_2 M}.$$

<details>
<summary>The ambush, in three lines</summary>

1. A number $x \le M$ has at most $\log_2 M$ distinct prime factors, because the product of $t$ distinct primes is at least $2^t$.
2. So the entire query set *touches* at most $|Q|\log_2 M$ primes.
3. If the pool exceeds the touched set by two, pick two untouched primes $p, q$ from it. Against the semiprime $pq$, *every* query returns gcd $1$. The algorithm learns nothing.

Since the primes usable for a balanced semiprime $N$ number about $\sqrt N/\log\sqrt N$, this reproduces the $\sqrt N$ wall unconditionally — no pigeonhole hypothesis, no assumption on how the queries are built.
</details>

The adversary is constructive; you can build it yourself:

{{algorithm:3}}

---

## 6. The twist: the wall has two heights

Everything so far concerns **guarantees**. But nobody factors numbers with a guarantee. Pollard's rho, the workhorse of small-factor extraction, is *randomised* and finds a collision modulo $p$ after roughly $\sqrt p$ steps, not $p$ steps — the ordinary [birthday paradox](https://en.wikipedia.org/wiki/Birthday_problem), the same reason that $23$ people probably share a birthday among $365$ days. If the deterministic wall were the whole story, rho could not exist.

So the honest thing to do is to prove where the randomised wall actually stands — and it can be done by pure counting, with no probability theory at all.

> **Exact count.** Of the $p^m$ ways to assign residues to $m$ enumerated tuples, exactly
> $$p^{\underline m} = p(p-1)(p-2)\cdots(p-m+1)$$
> are collision-free, because a collision-free assignment is precisely an injection of $m$ items into $p$ boxes.

<details>
<summary>From the exact count to the barrier</summary>

Clearing denominators in the classical union bound gives the integer inequality
$$p^{m+1} \le p \cdot p^{\underline m} + \binom{m}{2} p^m,$$
one term for each pair that could collide — i.e. the collision probability is at most $\binom{m}{2}/p$. It is proved by induction on $m$: multiply the previous case by $p$, split $p = (p-m) + m$ in the leading term, use $p^{\underline m}\le p^m$, and recognise $(p-m)p^{\underline m} = p^{\underline{m+1}}$ and $\binom{m}{2}+m = \binom{m+1}{2}$.

**Consequence.** If $2\binom{m}{2} < p$ — in particular if $m^2 < p$ — then $p^m < 2 p^{\underline m}$: a *strict majority* of all evaluations are collision-free. So any search succeeding with probability above one half must enumerate at least $\sqrt p$ tuples.
</details>

{{algorithm:4}}

Now go back to the explorer and open **Tab 3**. Drag the slider and watch the exact collision-probability curve cross the one-half line at about $1.2\sqrt p$, right next to the green $\sqrt p$ marker — while the deterministic requirement at the same modulus sits at more than $p$, two orders of magnitude to the right. At $p = 10007$: $2\binom{100}{2} = 9900 < 10007$, so even $100$ tuples leave a majority of evaluations collision-free, whereas certainty demands more than $10007$.

The corrected picture is a **two-level barrier**:

| Regime | Tuples needed | For a balanced $N = pq$ |
|---|---|---|
| Deterministic guarantee | more than $p$ | $\sqrt N$ |
| Randomised, success probability $> 1/2$ | at least $\sqrt p$ | $N^{1/4}$ |

Both rows are *lower* bounds. Both hold at every arity.

---

## 7. Seeing all of it at once

The picture below puts the three phenomena side by side: the birthday curves collapsing onto a single shape when rescaled by $\sqrt p$; the arity collapse of the search set against the stubbornly flat tuple count; and the two barrier levels drawn against $N$ on log-log axes.

{{visualization:0}}

---

## 8. Check it yourself

Every number quoted on this page is recomputable. The following script verifies the classification over a full period, performs the exhaustive $N = 143$ census, tabulates the arity thresholds, cross-validates the arity reduction against a brute-force cubic search, builds an explicit gcd-query adversary, computes the falling-factorial counts and the empirical randomised threshold ($m \approx 1.18\sqrt p$ across four moduli), and finally factors three semiprimes end-to-end with a budget of a few multiples of $N^{1/4}$.

{{demo:0}}

---

## 9. What to take away

1. **A bridge.** A 3SUM solution modulo a hidden prime is a factoring witness. Two canonical problems — one from [fine-grained complexity](https://en.wikipedia.org/wiki/3SUM), one from [cryptography](https://en.wikipedia.org/wiki/Integer_factorization) — meet at a single divisibility lemma.
2. **A conservation law.** Raising the arity compresses the *search set* like $p^{1/r}$ and leaves the *cost* untouched at more than $p$. When an exponent improves, always ask which quantity it improved.
3. **A correction.** "Everything costs $\sqrt N$" is false as stated — it would rule out Pollard's rho. The truth is two-level: $\sqrt N$ for a guarantee, $N^{1/4}$ for a coin flip, and both are provable lower bounds rather than heuristics.

None of this is a factoring breakthrough. It is something arguably more useful: a precise account of why a whole family of appealing ideas cannot be one, and of exactly where — at $N^{1/4}$, not $\sqrt N$ — the ground actually gives way.
"""

ALGO_REVEAL = '''"""Algorithm 1: witness-to-factor extraction by the gcd reveal."""

from math import gcd
from typing import Optional, Tuple


def classify_gcd(s: int, p: int, q: int) -> Tuple[int, str]:
    """The four-case classification of gcd(s, p*q) for distinct primes p, q."""
    dp, dq = (s % p == 0), (s % q == 0)
    if dp and dq:
        return p * q, "both primes divide s: gcd = N, no information"
    if dp:
        return p, "only p divides s: gcd = p, factor revealed"
    if dq:
        return q, "only q divides s: gcd = q, factor revealed"
    return 1, "neither prime divides s: gcd = 1, no information"


def extract_factor(n: int, witness: int) -> Optional[int]:
    """Return a proper nontrivial factor of n from a candidate witness, or None.

    Correctness: for n = p*q with distinct primes p, q, one has gcd(s, n) = p
    exactly when p | s and q does not divide s. Cost: one Euclidean algorithm,
    O(log^2 n) bit operations.
    """
    g = gcd(witness % n, n)
    return g if 1 < g < n else None


def three_sum_witness(a: int, b: int, c: int, n: int) -> Optional[int]:
    """The 3SUM specialisation: offer a + b + c to the reveal."""
    return extract_factor(n, a + b + c)
'''

ALGO_COLLISION = '''"""Algorithm 2: arity-r collision search with gcd extraction."""

from itertools import combinations
from math import comb, gcd
from typing import Dict, FrozenSet, Optional, Sequence, Tuple


def arity_r_collision_search(
    n: int, base: Sequence[int], r: int, budget: Optional[int] = None
) -> Optional[Tuple[int, FrozenSet[int], FrozenSet[int]]]:
    """Enumerate r-subsets of `base`, hash their sums mod n, factor on a collision.

    The modulus of interest is the unknown prime p dividing n, so sums are keyed
    modulo n and it is the *difference* of two colliding sums that is offered to
    the gcd: a collision modulo p makes that difference a multiple of p.

    Guarantee: once C(|base|, r) > p a sum collision modulo p must exist
    (pigeonhole), and no smaller enumeration can guarantee one (an adversary can
    assign at most p tuples distinct residues). Time and space Theta(C(|base|,r)).
    """
    seen: Dict[int, FrozenSet[int]] = {}
    count = 0
    for subset in combinations(base, r):
        if budget is not None and count >= budget:
            return None
        count += 1
        key = sum(subset) % n
        a_set = frozenset(subset)
        for prev_key, prev in seen.items():
            g = gcd(abs(sum(a_set) - sum(prev)), n)
            if 1 < g < n:
                return g, a_set, prev
        seen.setdefault(key, a_set)
    return None


def guaranteed_enumeration(p: int, r: int) -> Tuple[int, int]:
    """Minimal search-set size k with C(k, r) > p, and the resulting tuple count."""
    k = r
    while comb(k, r) <= p:
        k += 1
    return k, comb(k, r)
'''

ALGO_ARITY = '''"""Algorithm 3: arity reduction — 3SUM as a sumset table plus lookups."""

from typing import Dict, Optional, Sequence, Tuple


def sumset_table(s_set: Sequence[int], p: int) -> Dict[int, Tuple[int, int]]:
    """Map each achievable value a + b (mod p) to a witnessing pair (a, b)."""
    table: Dict[int, Tuple[int, int]] = {}
    for a in s_set:
        for b in s_set:
            table.setdefault((a + b) % p, (a, b))
    return table


def three_sum_via_sumset(s_set: Sequence[int], p: int) -> Optional[Tuple[int, int, int]]:
    """Find a, b, c in S with a + b + c = 0 mod p.

    Correctness: a 3SUM solution inside S exists if and only if -c lies in the
    sumset S + S for some c in S. Hence the arity-3 search is exactly the arity-2
    table (|S|^2 additions) plus |S| membership lookups: raising the arity cannot
    reduce the work below the size of the pair table.
    """
    table = sumset_table(s_set, p)
    for c in s_set:
        pair = table.get((-c) % p)
        if pair is not None:
            return pair[0], pair[1], c
    return None
'''

ALGO_QUERY = '''"""Algorithm 4: the gcd-query adversary."""

from math import gcd
from typing import Iterable, List, Optional, Sequence, Set, Tuple


def prime_factors(x: int) -> List[int]:
    """Distinct prime factors of x >= 1, by trial division."""
    out: List[int] = []
    d, m = 2, x
    while d * d <= m:
        if m % d == 0:
            out.append(d)
            while m % d == 0:
                m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        out.append(m)
    return out


def touched_primes(queries: Iterable[int]) -> Set[int]:
    """Every prime a query set could possibly reveal."""
    touched: Set[int] = set()
    for x in queries:
        touched.update(prime_factors(x))
    return touched


def coverage_bound(num_queries: int, bound_m: int) -> int:
    """|Q| * log2(M) + 1: the largest prime pool a query set can possibly cover."""
    return num_queries * bound_m.bit_length() + 1


def find_adversary(queries: Sequence[int], pool: Sequence[int]) -> Optional[Tuple[int, int]]:
    """Two primes of the pool untouched by every query.

    Their product defeats the whole query set: each query has trivial gcd with it.
    Since a query x <= M has at most log2(M) distinct prime factors, a set Q
    touches at most |Q| log2(M) primes, so a pool with more than
    |Q| log2(M) + 1 primes always admits such an adversary.
    """
    touched = touched_primes(queries)
    free = [p for p in pool if p not in touched]
    return (free[0], free[1]) if len(free) >= 2 else None


def all_queries_trivial(queries: Sequence[int], p: int, q: int) -> bool:
    """Confirm that every query returns gcd 1 against the adversary semiprime."""
    return all(gcd(x, p * q) == 1 for x in queries)
'''

ALGO_BIRTHDAY = '''"""Algorithm 5: the counting birthday bound and the randomised threshold."""

from math import comb, isqrt
from typing import Tuple


def falling_factorial(p: int, m: int) -> int:
    """p(p-1)...(p-m+1): the exact number of collision-free evaluations."""
    out = 1
    for i in range(m):
        out *= (p - i)
    return out


def union_bound_holds(p: int, m: int) -> bool:
    """Check the integer union bound p^(m+1) <= p * p^(m falling) + C(m,2) p^m."""
    return p ** (m + 1) <= p * falling_factorial(p, m) + comb(m, 2) * p ** m


def majority_collision_free(p: int, m: int) -> bool:
    """True iff strictly more than half of the p^m evaluations are injective.

    Guaranteed by the counting bound whenever 2*C(m,2) < p, in particular
    whenever m^2 < p. Exact integer arithmetic, no floating point.
    """
    return p ** m < 2 * falling_factorial(p, m)


def randomised_threshold(p: int) -> Tuple[int, int]:
    """(smallest m at which collisions become the majority, isqrt(p))."""
    m = 1
    while majority_collision_free(p, m):
        m += 1
    return m, isqrt(p)
'''

package: Dict[str, Any] = {
    "title": "The 3SUM–Birthday-Bound Hierarchy: Factor Reveals, Arity-Uniform Collision Thresholds, and a Two-Level Barrier",
    "domain": "Logic",
    "description": (
        "A 3SUM solution modulo a hidden prime factor of a semiprime N = pq reveals that factor exactly, "
        "and the cost of producing such a witness obeys a two-level barrier: more than p enumerated tuples "
        "for a deterministic guarantee at every arity (so about the square root of N), and at least the "
        "square root of p — i.e. N^(1/4) — for randomised search, both proved as unconditional lower bounds."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-13",
    "key_results": [
        "Exact factor reveal: for distinct primes p and q, gcd(s, pq) = p if and only if p divides s and q does not; specialised to s = a + b + c this turns a 3SUM solution modulo a hidden prime into a factoring witness, with the complete four-case classification of gcd(s, pq).",
        "Reveal density: in one period 0 < s ≤ pq exactly q values are multiples of p and exactly q − 1 of them reveal the factor, the sole exception being s = pq; for N = 143 this is 12 of 13, and all 15 triples 1 ≤ a < b < c ≤ 11 with sum divisible by 11 reveal the factor.",
        "Arity-uniform collision threshold: an arity-r collision search over a k-set guarantees a sum collision modulo p against every evaluation if and only if the binomial coefficient C(k, r) exceeds p; sufficiency is the pigeonhole principle and necessity is a matching adversary, so the threshold of p + 1 enumerated tuples is exactly optimal at every arity and yields a √N wall for a balanced semiprime, while the search-set size improves as p, √(2p), (6p)^(1/3).",
        "Arity reduction: a 3SUM solution inside a set S exists precisely when −c lies in the sumset S + S for some c in S, so the arity-3 search is the arity-2 table plus |S| lookups, and Pollard's p − 1 values a^k − 1 feed the very same reveal lemma.",
        "Unconditional gcd-query lower bound: a query set Q of nonzero integers bounded by M that reveals a factor of every semiprime built from a prime pool P must satisfy |P| ≤ |Q| log₂ M + 1, equivalently |Q| ≥ (|P| − 1)/log₂ M, recovering the √N wall with no assumption on how the queries are generated.",
        "Counting birthday bound and randomised barrier: exactly p(p−1)⋯(p−m+1) of the p^m evaluations of m tuples are collision-free, the integer union bound p^(m+1) ≤ p·p(p−1)⋯(p−m+1) + C(m,2)·p^m holds, and m² < p forces a strict majority of collision-free evaluations — so success probability above one half needs at least √p tuples, i.e. N^(1/4), strictly below the deterministic wall.",
    ],
    "keywords": [
        "3SUM",
        "birthday bound",
        "integer factoring",
        "semiprime",
        "pigeonhole principle",
        "gcd queries",
        "falling factorial",
        "query complexity",
    ],
    "article": read("ARTICLE.md"),
    "research_paper": read("RESEARCH_PAPER.md"),
    "research_paper_tex": read("RESEARCH_PAPER.tex"),
    "demo": read("demo.py"),
    "demos": [
        {
            "name": "End-to-End Verification of the Reveal, the Thresholds and the Two-Level Barrier",
            "description": (
                "A single self-contained script that recomputes every quantitative claim of the work. It verifies the "
                "four-case classification of gcd(s, pq) for all s in one period; performs the exhaustive census of "
                "triples 1 ≤ a < b < c ≤ 11 for N = 143 (15 triples with sum divisible by 11, none divisible by 143, "
                "all 15 revealing); confirms the reveal density q − 1 out of q across several semiprimes; tabulates the "
                "arity-uniform thresholds, showing the minimal search-set size collapsing from 101 to 15 to 10 at p = 100 "
                "while the tuple counts 101, 105, 120 all stay above p; cross-validates the arity reduction against a "
                "cubic 3SUM search; exhibits an explicit gcd-query adversary whose semiprime returns gcd 1 on every query; "
                "computes the exact falling-factorial collision-free counts, the integer union bound and the empirical "
                "randomised threshold (m ≈ 1.18√p across four moduli); and finally factors three semiprimes end to end "
                "with a collision search using a budget of only a few multiples of N^(1/4)."
            ),
            "code": read("demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Witness-to-Factor Extraction via the Greatest Common Divisor Reveal",
            "description": (
                "The atomic step shared by every method in the hierarchy. Given a semiprime N = pq and a candidate "
                "witness s, a single Euclidean algorithm returns gcd(s, N), which by the classification theorem is one "
                "of 1, p, q or N according to which hidden primes divide s. The informative cases are exactly those in "
                "which s hits precisely one of the two primes, and then the gcd equals that prime. Complexity: "
                "O(log² N) bit operations, i.e. negligible; the entire difficulty of factoring by this route lies in "
                "producing s, never in testing it. Over one period the reveal succeeds on q − 1 of the q multiples of p, "
                "a failure rate of 1/q."
            ),
            "pseudocode": (
                "function EXTRACT-FACTOR(N, s):\n"
                "    g <- GCD(s mod N, N)            # Euclidean algorithm, O(log^2 N)\n"
                "    if 1 < g < N then return g      # g is p or q, a proper nontrivial factor\n"
                "    else return FAIL                # g = 1 (s hit neither prime) or g = N (s hit both)\n"
                "\n"
                "function THREE-SUM-WITNESS(N, a, b, c):\n"
                "    return EXTRACT-FACTOR(N, a + b + c)\n"
                "\n"
                "Correctness (classification): for distinct primes p, q and any integer s,\n"
                "    gcd(s, pq) = pq  if p | s and q | s\n"
                "    gcd(s, pq) = p   if p | s and q does not divide s\n"
                "    gcd(s, pq) = q   if q | s and p does not divide s\n"
                "    gcd(s, pq) = 1   otherwise."
            ),
            "code": ALGO_REVEAL,
        },
        {
            "name": "Arity-r Collision Search with Guaranteed Pigeonhole Threshold",
            "description": (
                "The generic engine of the hierarchy, covering single evaluations (r = 1), sumset collisions (r = 2) and "
                "3SUM (r = 3) as one procedure. All C(k, r) subsets of a k-element base set are enumerated, their sums "
                "are hashed modulo the public N (the hidden prime p is unavailable), and the difference of two colliding "
                "sums is offered to the gcd: a collision modulo p makes that difference a multiple of p. The pigeonhole "
                "principle guarantees a collision once C(k, r) > p, and a matching adversary shows that at most p "
                "enumerated tuples can always be assigned distinct residues, so the threshold p + 1 is exactly optimal — "
                "at every arity. Time and space are Θ(C(k, r)) = Ω(p) = Ω(√N) for guaranteed success; the arity only "
                "shrinks the base set, from k ≈ p at arity 1 to k ≈ √(2p) at arity 2 and k ≈ (6p)^(1/3) at arity 3."
            ),
            "pseudocode": (
                "function GUARANTEED-ENUMERATION(p, r):\n"
                "    k <- r\n"
                "    while C(k, r) <= p do k <- k + 1     # minimal search-set size\n"
                "    return (k, C(k, r))                  # C(k, r) > p tuples will be enumerated\n"
                "\n"
                "function ARITY-R-COLLISION-SEARCH(N, base, r):\n"
                "    seen <- empty dictionary : residue -> subset\n"
                "    for each r-subset A of base do\n"
                "        key <- (sum of A) mod N\n"
                "        for each stored subset B do\n"
                "            g <- GCD(|sum(A) - sum(B)|, N)\n"
                "            if 1 < g < N then return (g, A, B)\n"
                "        store A under key if key unused\n"
                "    return FAIL\n"
                "\n"
                "Guarantee: if C(|base|, r) > p a sum collision mod p exists; if C(|base|, r) <= p\n"
                "some evaluation assigns all tuples distinct residues, so no guarantee is possible."
            ),
            "code": ALGO_COLLISION,
        },
        {
            "name": "Arity Reduction: 3SUM as a Sumset Table with Linear Lookups",
            "description": (
                "A structural procedure showing that the arity-3 search accesses no richer structure than the arity-2 "
                "search. A 3SUM solution a + b + c ≡ 0 inside S exists if and only if −c lies in the sumset S + S for "
                "some c ∈ S. The algorithm therefore builds a hash table of all pairwise sums, mapping each achievable "
                "value to a witnessing pair, and then performs one lookup per element of S. Complexity: |S|² additions "
                "and O(|S|²) space for the table, plus |S| constant-time lookups — so the triple search costs the pair "
                "table plus a linear afterthought, which is the structural reason raising the arity cannot lower the cost "
                "below the size of the pair table."
            ),
            "pseudocode": (
                "function SUMSET-TABLE(S, p):\n"
                "    table <- empty dictionary : value -> pair\n"
                "    for a in S do\n"
                "        for b in S do\n"
                "            v <- (a + b) mod p\n"
                "            if v not in table then table[v] <- (a, b)\n"
                "    return table                       # |S|^2 additions, at most |S|^2 entries\n"
                "\n"
                "function THREE-SUM-VIA-SUMSET(S, p):\n"
                "    table <- SUMSET-TABLE(S, p)\n"
                "    for c in S do                      # |S| lookups\n"
                "        if (-c mod p) in table then\n"
                "            (a, b) <- table[-c mod p]\n"
                "            return (a, b, c)           # a + b + c = 0 mod p\n"
                "    return NONE\n"
                "\n"
                "Correctness: (exists a,b,c in S with a+b+c = 0) iff (exists c in S with -c in S+S)."
            ),
            "code": ALGO_ARITY,
        },
        {
            "name": "The gcd-Query Adversary and the Touched-Prime Counting Bound",
            "description": (
                "A constructive witness for the unconditional query lower bound. Any factoring method in this family "
                "ultimately hands a finite set Q of integers to the gcd. Each query x ≤ M has at most log₂ M distinct "
                "prime factors, since the product of t distinct primes is at least 2^t; hence Q touches at most "
                "|Q| log₂ M primes in total. If a candidate pool P is larger than the touched set by two, the adversary "
                "picks two untouched primes p, q and returns the semiprime pq, against which every query has gcd 1. "
                "This proves |P| ≤ |Q| log₂ M + 1 with no hypothesis on how the queries were generated. Complexity: "
                "factoring the queries by trial division dominates; the counting itself is linear in |Q| plus |P|."
            ),
            "pseudocode": (
                "function TOUCHED-PRIMES(Q):\n"
                "    U <- empty set\n"
                "    for x in Q do U <- U union {distinct prime factors of x}\n"
                "    return U                            # |U| <= |Q| * log2(M) when all x <= M\n"
                "\n"
                "function FIND-ADVERSARY(Q, P):\n"
                "    U <- TOUCHED-PRIMES(Q)\n"
                "    free <- [p in P : p not in U]\n"
                "    if |free| >= 2 then return (free[0], free[1]) else return NONE\n"
                "\n"
                "Theorem: if Q solves every semiprime built from two distinct primes of P,\n"
                "then FIND-ADVERSARY(Q, P) must return NONE, hence |P| <= |Q| log2(M) + 1,\n"
                "equivalently |Q| >= (|P| - 1) / log2(M)."
            ),
            "code": ALGO_QUERY,
        },
        {
            "name": "Exact Counting Birthday Bound and the Randomised Square-Root Threshold",
            "description": (
                "The randomised half of the two-level barrier, computed in exact integer arithmetic. Of the p^m ways to "
                "assign residues to m enumerated tuples, exactly p(p−1)⋯(p−m+1) are collision-free, because a "
                "collision-free assignment is precisely an injection of m items into p boxes. Clearing denominators in "
                "the classical union bound gives the integer inequality p^(m+1) ≤ p·p(p−1)⋯(p−m+1) + C(m,2)·p^m, i.e. a "
                "collision probability of at most C(m,2)/p. Whenever 2·C(m,2) < p — in particular whenever m² < p — a "
                "strict majority of assignments are collision-free, so a search succeeding with probability above one "
                "half must enumerate at least √p tuples. Complexity: the falling factorial costs m multiplications; the "
                "threshold scan costs O(√p) such evaluations."
            ),
            "pseudocode": (
                "function FALLING-FACTORIAL(p, m):\n"
                "    out <- 1\n"
                "    for i from 0 to m-1 do out <- out * (p - i)\n"
                "    return out                          # exact count of collision-free evaluations\n"
                "\n"
                "function MAJORITY-COLLISION-FREE(p, m):\n"
                "    return p^m < 2 * FALLING-FACTORIAL(p, m)\n"
                "\n"
                "function RANDOMISED-THRESHOLD(p):\n"
                "    m <- 1\n"
                "    while MAJORITY-COLLISION-FREE(p, m) do m <- m + 1\n"
                "    return m                            # empirically m is about 1.18 * sqrt(p)\n"
                "\n"
                "Theorem: 2*C(m,2) < p implies p^m < 2 * FALLING-FACTORIAL(p, m);\n"
                "in particular m^2 < p implies a strict majority of collision-free evaluations."
            ),
            "code": ALGO_BIRTHDAY,
        },
    ],
    "visualizations": [
        {
            "name": "One Wall, Two Heights: Birthday Curves, the Arity Collapse, and the Two-Level Barrier",
            "description": (
                "A three-panel figure. Panel (a) plots the exact collision probability 1 − p(p−1)⋯(p−m+1)/p^m against "
                "the number m of enumerated tuples, rescaled in units of √p, for three moduli; the curves collapse onto "
                "one another and cross one half at about 1.2√p, which is the randomised barrier. Panel (b) plots, for a "
                "fixed modulus, the minimal search-set size k against the number of tuples C(k, r) actually enumerated, "
                "as the arity r runs from 1 to 5: the set size collapses by orders of magnitude while the tuple count "
                "stays pinned just above p. Panel (c) plots, on log-log axes and against N = p², the deterministic "
                "requirement (> p ≈ √N) beside the randomised one (≈ √p = N^(1/4)), with the two reference slopes drawn "
                "in — the visual statement of the two-level barrier."
            ),
            "code": read("assets/viz_two_level_barrier.py"),
        }
    ],
    "interactive_demos": [
        {
            "title": "The 3SUM–Birthday-Bound Explorer: Reveal, Hierarchy, and the Two Heights of the Wall",
            "description": (
                "A three-tab interactive laboratory. Tab 1 lets the reader choose two small primes and a range, then "
                "enumerates every triple a < b < c whose sum is divisible by the hidden prime, colouring each cell by "
                "what its gcd with N actually returns — green for a successful reveal, red for the sole failure mode in "
                "which the sum is divisible by both primes. Tab 2 recomputes the arity table live for any modulus, "
                "showing the minimal search-set size collapsing like p^(1/r) while the enumerated tuple count remains "
                "just above p, with the matching sufficiency and necessity arguments folded away behind a disclosure. "
                "Tab 3 draws the exact collision-probability curve together with the union bound C(m,2)/p on a canvas, "
                "with movable markers at √p and at the reader's chosen m, so the crossing of the one-half line at "
                "about 1.2√p can be located by hand and compared with the deterministic requirement of more than p "
                "tuples at the same modulus."
            ),
            "html": read("assets/widget.html"),
        }
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {"demo": read("demo.py")},
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size} bytes)")


"""
Visualisation: the two-level barrier and the arity-uniform threshold.

Produces a single figure with three panels.

  (a) Collision probability 1 - p^(m falling)/p^m as a function of the number m
      of enumerated tuples, for several moduli p, with the sqrt(p) mark and the
      1/2 crossing shown. This is the randomised barrier: below sqrt(p) a strict
      majority of evaluations are collision-free.

  (b) The arity-uniform threshold. For a fixed modulus p and each arity r, the
      minimal search-set size k with C(k, r) > p (which falls off like p^(1/r))
      against the number of tuples C(k, r) actually enumerated (which stays
      pinned just above p). The search set shrinks; the work does not.

  (c) The two-level barrier for balanced semiprimes N = p^2: the deterministic
      requirement (> p ~ sqrt(N)) against the randomised one (~ sqrt(p) =
      N^(1/4)), plotted against N on log-log axes.

Run with:  python3 viz_two_level_barrier.py
Requires matplotlib and numpy.
"""

from __future__ import annotations

from math import comb, isqrt
from typing import List, Sequence

import matplotlib.pyplot as plt
import numpy as np


def collision_probability(p: int, m: int) -> float:
    """Exact probability 1 - p(p-1)...(p-m+1)/p^m of some collision."""
    free = 1.0
    for i in range(m):
        free *= (p - i) / p
    return 1.0 - free


def minimal_k(p: int, r: int) -> int:
    """Smallest search-set size k with C(k, r) > p."""
    k = r
    while comb(k, r) <= p:
        k += 1
    return k


def randomised_threshold(p: int) -> int:
    """Smallest m with collision probability at least 1/2."""
    m = 1
    while collision_probability(p, m) < 0.5:
        m += 1
    return m


def panel_birthday(ax: plt.Axes, moduli: Sequence[int]) -> None:
    for p in moduli:
        top = 4 * isqrt(p)
        ms = np.arange(1, top + 1)
        probs = [collision_probability(p, int(m)) for m in ms]
        line, = ax.plot(ms / isqrt(p), probs, label=f"$p = {p}$")
        ax.axvline(1.0, color="0.7", lw=0.8, ls=":")
        ax.plot([randomised_threshold(p) / isqrt(p)], [0.5], "o",
                color=line.get_color(), ms=5)
    ax.axhline(0.5, color="0.4", lw=0.9, ls="--")
    ax.set_xlabel(r"tuples enumerated, in units of $\sqrt{p}$")
    ax.set_ylabel("probability of a collision")
    ax.set_title("(a) randomised barrier: the curve turns at $\\sqrt{p}$")
    ax.legend(fontsize=8)
    ax.grid(alpha=0.3)


def panel_arity(ax: plt.Axes, p: int, arities: Sequence[int]) -> None:
    ks: List[int] = [minimal_k(p, r) for r in arities]
    tuples: List[int] = [comb(k, r) for k, r in zip(ks, arities)]
    ax.semilogy(arities, ks, "o-", label="search-set size $k$")
    ax.semilogy(arities, tuples, "s-", label=r"tuples $\binom{k}{r}$")
    ax.axhline(p, color="crimson", lw=1.2, ls="--", label=f"modulus $p = {p}$")
    for r, k, t in zip(arities, ks, tuples):
        ax.annotate(str(k), (r, k), textcoords="offset points", xytext=(0, 7),
                    ha="center", fontsize=8)
        ax.annotate(str(t), (r, t), textcoords="offset points", xytext=(0, -12),
                    ha="center", fontsize=8)
    ax.set_xticks(list(arities))
    ax.set_xlabel("arity $r$")
    ax.set_ylabel("count (log scale)")
    ax.set_title("(b) the set shrinks, the work does not")
    ax.legend(fontsize=8)
    ax.grid(alpha=0.3, which="both")


def panel_two_level(ax: plt.Axes, primes: Sequence[int]) -> None:
    ns = [p * p for p in primes]
    deterministic = [p for p in primes]
    randomised = [randomised_threshold(p) for p in primes]
    ax.loglog(ns, deterministic, "o-", label=r"deterministic: $>p \approx \sqrt{N}$")
    ax.loglog(ns, randomised, "s-", label=r"randomised: $\approx\sqrt{p}=N^{1/4}$")
    ax.loglog(ns, [n ** 0.5 for n in ns], "--", color="0.6", lw=0.9,
              label=r"$\sqrt{N}$")
    ax.loglog(ns, [n ** 0.25 for n in ns], ":", color="0.6", lw=0.9,
              label=r"$N^{1/4}$")
    ax.set_xlabel("$N = p^2$ (balanced semiprime)")
    ax.set_ylabel("tuples required")
    ax.set_title("(c) the barrier has two heights")
    ax.legend(fontsize=8)
    ax.grid(alpha=0.3, which="both")


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(16, 4.8))
    panel_birthday(axes[0], (101, 1009, 10007))
    panel_arity(axes[1], 10007, (1, 2, 3, 4, 5))
    panel_two_level(axes[2], (101, 1009, 10007, 100003, 1000003))
    fig.suptitle("The 3SUM-birthday-bound hierarchy: one wall, two heights",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("two_level_barrier.png", dpi=160)
    print("wrote two_level_barrier.png")


if __name__ == "__main__":
    main()


"""
The 3SUM-Birthday-Bound Hierarchy -- numerical demonstrations.

This self-contained script demonstrates, by direct computation, every
quantitative claim of the accompanying paper:

  1. The factor reveal and its complete four-case classification:
         gcd(s, p*q) = p  <=>  p | s and not q | s.
  2. The exhaustive N = 143 instance: 15 triples 1 <= a < b < c <= 11 have
     11 | a+b+c, none has 143 | a+b+c, and all 15 reveal the factor 11.
  3. Reveal density: exactly q of the s in (0, pq] are multiples of p, and
     exactly q - 1 of them satisfy gcd(s, pq) = p.
  4. The arity-uniform threshold table: minimal k with C(k, r) > p, showing
     the search set shrinking while the tuple count stays above p.
  5. Arity reduction: a 3SUM solution in S exists iff -c lies in S + S.
  6. The gcd-query lower bound |P| <= |Q| log2(M) + 1, together with an
     explicit adversary that defeats an under-sized query set.
  7. The counting birthday bound: the exact collision-free count p^(m_falling),
     the integer union bound, and the randomised sqrt(p) barrier.
  8. An end-to-end collision search that actually factors a semiprime.

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

from itertools import combinations
from math import comb, gcd, isqrt
from typing import Dict, Iterable, List, Optional, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1. The factor reveal
# ---------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (adequate for demo sizes)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    f = 3
    while f * f <= n:
        if n % f == 0:
            return False
        f += 2
    return True


def classify_gcd(s: int, p: int, q: int) -> Tuple[int, str]:
    """Return (gcd(s, p*q), case label) predicted by the classification theorem.

    For distinct primes p != q the gcd is p*q, p, q or 1 according to which of
    the two primes divides s.
    """
    dp, dq = (s % p == 0), (s % q == 0)
    if dp and dq:
        return p * q, "both  -> gcd = N (no information)"
    if dp:
        return p, "p only -> gcd = p (REVEAL)"
    if dq:
        return q, "q only -> gcd = q (REVEAL)"
    return 1, "neither -> gcd = 1 (no information)"


def check_classification(p: int, q: int, bound: int) -> bool:
    """Verify the four-case classification for every 0 < s <= bound."""
    return all(gcd(s, p * q) == classify_gcd(s, p, q)[0] for s in range(1, bound + 1))


def demo_factor_reveal() -> None:
    print("=" * 74)
    print("1. THE FACTOR REVEAL:  gcd(s, pq) = p  <=>  p | s  and  q does not | s")
    print("=" * 74)
    p, q = 11, 13
    n = p * q
    print(f"N = {n} = {p} * {q}")
    for s in (11, 22, 143, 7, 13):
        g, label = classify_gcd(s, p, q)
        print(f"  s = {s:4d}:  gcd(s, N) = {gcd(s, n):4d}   {label}")
    ok = check_classification(p, q, n)
    print(f"  classification verified for all 0 < s <= {n}: {ok}")
    print(f"  headline witness: 1 + 4 + 6 = {1 + 4 + 6}, gcd = {gcd(1 + 4 + 6, n)}")
    print()


# ---------------------------------------------------------------------------
# 2. Exhaustive 3SUM instance for N = 143
# ---------------------------------------------------------------------------

def three_sum_reveal_census(p: int, q: int, top: int) -> Tuple[int, int, int, int]:
    """Census of triples 1 <= a < b < c <= top for the semiprime N = p*q.

    Returns (total triples, triples with p | a+b+c, triples with p*q | a+b+c,
    triples whose gcd with N equals p).
    """
    n = p * q
    total = mod_p = mod_both = revealing = 0
    for a, b, c in combinations(range(1, top + 1), 3):
        s = a + b + c
        total += 1
        if s % p == 0:
            mod_p += 1
            if s % n == 0:
                mod_both += 1
        if gcd(s, n) == p:
            revealing += 1
    return total, mod_p, mod_both, revealing


def demo_143_census() -> None:
    print("=" * 74)
    print("2. EXHAUSTIVE INSTANCE  N = 143 = 11 * 13,  triples 1 <= a < b < c <= 11")
    print("=" * 74)
    total, mod_p, mod_both, revealing = three_sum_reveal_census(11, 13, 11)
    print(f"  all triples                       : {total}")
    print(f"  triples with 11 | a+b+c           : {mod_p}   (expected 15)")
    print(f"  triples with 143 | a+b+c          : {mod_both}   (expected 0)")
    print(f"  triples with gcd(a+b+c, 143) = 11 : {revealing}")
    print("  every mod-p triple reveals the factor:",
          mod_p == revealing and mod_both == 0)
    witnesses = [t for t in combinations(range(1, 12), 3) if sum(t) % 11 == 0][:5]
    print("  first witnesses:", ", ".join(f"{a}+{b}+{c}={a+b+c}" for a, b, c in witnesses))
    print()


# ---------------------------------------------------------------------------
# 3. Reveal density
# ---------------------------------------------------------------------------

def reveal_density(p: int, q: int) -> Tuple[int, int, int]:
    """Counts over one period 0 < s <= p*q.

    Returns (# multiples of p, # multiples of p*q, # s with gcd(s, pq) = p).
    """
    n = p * q
    mult_p = sum(1 for s in range(1, n + 1) if s % p == 0)
    mult_n = sum(1 for s in range(1, n + 1) if s % n == 0)
    reveal = sum(1 for s in range(1, n + 1) if gcd(s, n) == p)
    return mult_p, mult_n, reveal


def demo_reveal_density() -> None:
    print("=" * 74)
    print("3. REVEAL DENSITY:  q multiples of p per period, exactly q-1 reveal")
    print("=" * 74)
    print(f"  {'p':>5} {'q':>5} {'#(p|s)':>8} {'#(N|s)':>8} {'#reveal':>8} "
          f"{'predicted q-1':>14} {'success rate':>13}")
    for p, q in ((11, 13), (13, 11), (7, 23), (17, 19), (5, 31)):
        mult_p, mult_n, reveal = reveal_density(p, q)
        rate = reveal / mult_p
        print(f"  {p:5d} {q:5d} {mult_p:8d} {mult_n:8d} {reveal:8d} "
              f"{q - 1:14d} {rate:13.6f}")
    print("  the single failure per period is always s = N itself.")
    print()


# ---------------------------------------------------------------------------
# 4. The arity-uniform threshold table
# ---------------------------------------------------------------------------

def minimal_k(p: int, r: int) -> int:
    """Smallest k with C(k, r) > p: the minimal search-set size at arity r."""
    k = r
    while comb(k, r) <= p:
        k += 1
    return k


def threshold_table(p: int, arities: Sequence[int] = (1, 2, 3, 4)) -> List[Tuple[int, int, int, int]]:
    """Rows (arity, minimal k, C(k-1, r) [insufficient], C(k, r) [tuples])."""
    rows: List[Tuple[int, int, int, int]] = []
    for r in arities:
        k = minimal_k(p, r)
        rows.append((r, k, comb(k - 1, r), comb(k, r)))
    return rows


def demo_threshold_table() -> None:
    print("=" * 74)
    print("4. ARITY-UNIFORM THRESHOLD: search set shrinks, tuple count does not")
    print("=" * 74)
    for p in (100, 10007):
        print(f"  modulus p = {p}   (a guaranteed collision needs > p tuples)")
        print(f"    {'arity':>6} {'min k':>10} {'C(k-1,r) short':>16} {'C(k,r) tuples':>15} {'> p?':>6}")
        for r, k, short, tuples in threshold_table(p):
            print(f"    {r:6d} {k:10d} {short:16d} {tuples:15d} {str(tuples > p):>6}")
        print()


# ---------------------------------------------------------------------------
# 5. Arity reduction: 3SUM = sumset table + k lookups
# ---------------------------------------------------------------------------

def sumset_table(s_set: Sequence[int], p: int) -> Dict[int, Tuple[int, int]]:
    """Hash map value -> witnessing pair, for all sums a+b mod p with a,b in S."""
    table: Dict[int, Tuple[int, int]] = {}
    for a in s_set:
        for b in s_set:
            table.setdefault((a + b) % p, (a, b))
    return table


def three_sum_via_sumset(s_set: Sequence[int], p: int) -> Optional[Tuple[int, int, int]]:
    """Find a, b, c in S with a+b+c = 0 mod p, using |S|^2 work + |S| lookups."""
    table = sumset_table(s_set, p)
    for c in s_set:
        pair = table.get((-c) % p)
        if pair is not None:
            return pair[0], pair[1], c
    return None


def three_sum_brute(s_set: Sequence[int], p: int) -> Optional[Tuple[int, int, int]]:
    """Reference cubic search, for cross-validation of the reduction."""
    for a in s_set:
        for b in s_set:
            for c in s_set:
                if (a + b + c) % p == 0:
                    return a, b, c
    return None


def demo_arity_reduction() -> None:
    print("=" * 74)
    print("5. ARITY REDUCTION:  a+b+c = 0 in S  <=>  -c in S+S for some c in S")
    print("=" * 74)
    p = 101
    cases: List[List[int]] = [
        [3, 17, 42, 58, 77],
        [1, 2, 4, 8, 16, 32, 64],
        [5, 25, 45, 65, 85],
    ]
    for s_set in cases:
        fast = three_sum_via_sumset(s_set, p)
        slow = three_sum_brute(s_set, p)
        agree = (fast is None) == (slow is None)
        print(f"  S = {s_set}")
        print(f"    sumset table size = {len(sumset_table(s_set, p))} "
              f"(<= |S|^2 = {len(s_set) ** 2}), lookups = {len(s_set)}")
        print(f"    reduction finds {fast}, cubic search finds {slow}, consistent: {agree}")
    print()


# ---------------------------------------------------------------------------
# 6. The gcd-query lower bound and its adversary
# ---------------------------------------------------------------------------

def prime_factors(x: int) -> List[int]:
    """Distinct prime factors of x >= 1."""
    out: List[int] = []
    d, m = 2, x
    while d * d <= m:
        if m % d == 0:
            out.append(d)
            while m % d == 0:
                m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        out.append(m)
    return out


def touched_primes(queries: Iterable[int]) -> set:
    """The set of primes that any query can possibly reveal."""
    touched: set = set()
    for x in queries:
        touched.update(prime_factors(x))
    return touched


def gcd_query_bound(num_queries: int, bound_m: int) -> int:
    """Max size of a prime pool a query set of this size can possibly cover."""
    return num_queries * bound_m.bit_length() + 1


def find_adversary(queries: Sequence[int], pool: Sequence[int]) -> Optional[Tuple[int, int]]:
    """Two untouched primes of the pool, whose semiprime defeats every query."""
    touched = touched_primes(queries)
    free = [p for p in pool if p not in touched]
    return (free[0], free[1]) if len(free) >= 2 else None


def demo_gcd_query_bound() -> None:
    print("=" * 74)
    print("6. GCD-QUERY LOWER BOUND:  |P| <= |Q| * log2(M) + 1")
    print("=" * 74)
    pool = [p for p in range(100, 400) if is_prime(p)]
    bound_m = 10 ** 6
    queries = [2 * 3 * 5 * 7 * 11 * 13, 101 * 103 * 107, 109 * 113 * 127, 999983]
    covered = gcd_query_bound(len(queries), bound_m)
    print(f"  prime pool |P| = {len(pool)} primes in [100, 400)")
    print(f"  queries   |Q| = {len(queries)}, all <= M = {bound_m} (log2 M ~ {bound_m.bit_length()})")
    print(f"  bound: such a Q can cover at most |Q|*log2(M)+1 = {covered} primes")
    print(f"  touched primes: {sorted(touched_primes(queries))}")
    adv = find_adversary(queries, pool)
    if adv is not None:
        p, q = adv
        n = p * q
        results = {x: gcd(x, n) for x in queries}
        print(f"  adversary semiprime N = {p} * {q} = {n}")
        print(f"  every query returns a trivial gcd: {sorted(set(results.values()))}")
        print(f"  a single revealing query would suffice: gcd({p} * 4, N) = {gcd(4 * p, n)}")
    print(f"  minimum queries to cover the whole pool: "
          f"ceil(({len(pool)}-1)/{bound_m.bit_length()}) = "
          f"{-(-(len(pool) - 1) // bound_m.bit_length())}")
    print()


# ---------------------------------------------------------------------------
# 7. The counting birthday bound and the randomised barrier
# ---------------------------------------------------------------------------

def falling_factorial(p: int, m: int) -> int:
    """p^(m falling) = p (p-1) ... (p-m+1): the exact collision-free count."""
    out = 1
    for i in range(m):
        out *= (p - i)
    return out


def union_bound_holds(p: int, m: int) -> bool:
    """Integer union bound  p^(m+1) <= p * p^(m falling) + C(m,2) * p^m."""
    return p ** (m + 1) <= p * falling_factorial(p, m) + comb(m, 2) * p ** m


def majority_collision_free(p: int, m: int) -> bool:
    """True iff more than half of all p^m evaluations are collision-free."""
    return p ** m < 2 * falling_factorial(p, m)


def collision_probability(p: int, m: int) -> float:
    """Exact 1 - p^(m falling)/p^m, computed in floating point."""
    prob_free = 1.0
    for i in range(m):
        prob_free *= (p - i) / p
    return 1.0 - prob_free


def randomised_threshold(p: int) -> int:
    """Smallest m for which a collision is more likely than not."""
    m = 1
    while majority_collision_free(p, m):
        m += 1
    return m


def demo_counting_birthday() -> None:
    print("=" * 74)
    print("7. COUNTING BIRTHDAY BOUND AND THE RANDOMISED sqrt(p) BARRIER")
    print("=" * 74)
    p = 10007
    print(f"  modulus p = {p},  sqrt(p) ~ {isqrt(p)}")
    print(f"    {'m':>6} {'2*C(m,2)':>10} {'< p?':>6} {'union bd':>9} "
          f"{'majority free':>14} {'P[collision]':>13}")
    for m in (10, 50, 100, 120, 141, 160, 200):
        print(f"    {m:6d} {2 * comb(m, 2):10d} {str(2 * comb(m, 2) < p):>6} "
              f"{str(union_bound_holds(p, m)):>9} {str(majority_collision_free(p, m)):>14} "
              f"{collision_probability(p, m):13.6f}")
    thr = randomised_threshold(p)
    print(f"  empirical randomised threshold: m = {thr}  (sqrt(p) = {isqrt(p)}, "
          f"ratio {thr / isqrt(p):.3f})")
    print(f"  deterministic guarantee at the same modulus: > {p} tuples")
    print(f"  gap factor: {p / thr:.1f}x")
    print()
    print("  the sqrt(p) law across moduli (balanced semiprime N = p^2):")
    print(f"    {'p':>10} {'sqrt(p)':>10} {'threshold m':>12} {'m/sqrt(p)':>11} "
          f"{'det. > p':>10} {'N^(1/4)~':>10}")
    for p in (101, 1009, 10007, 100003):
        thr = randomised_threshold(p)
        print(f"    {p:10d} {isqrt(p):10d} {thr:12d} {thr / isqrt(p):11.3f} "
              f"{p:10d} {isqrt(p):10d}")
    print()


# ---------------------------------------------------------------------------
# 8. End-to-end: a collision search that really factors
# ---------------------------------------------------------------------------

def collision_factor(n: int, values: Sequence[int]) -> Optional[Tuple[int, int, int]]:
    """Offer pairwise differences of the given values to the gcd.

    Returns (factor, x, y) for the first pair whose difference has a nontrivial
    gcd with n. This is the arity-2 row of the hierarchy, executed literally:
    a collision modulo the hidden prime p becomes a difference divisible by p.
    """
    seen: List[int] = []
    for x in values:
        for y in seen:
            g = gcd(abs(x - y), n)
            if 1 < g < n:
                return g, x, y
        seen.append(x)
    return None


def rho_sequence(n: int, length: int, seed: int = 2) -> List[int]:
    """The classical iteration x -> x^2 + 1 mod n, a cheap pseudo-random source."""
    out: List[int] = []
    x = seed
    for _ in range(length):
        x = (x * x + 1) % n
        out.append(x)
    return out


def demo_end_to_end() -> None:
    print("=" * 74)
    print("8. END TO END: collisions modulo a hidden prime factor the semiprime")
    print("=" * 74)
    for p, q in ((10007, 10009), (65537, 65539), (1000003, 1000033)):
        n = p * q
        budget = 8 * isqrt(isqrt(n))  # a few multiples of N^(1/4)
        values = rho_sequence(n, budget)
        found = collision_factor(n, values)
        label = "found" if found else "not found"
        factor = found[0] if found else 0
        print(f"  N = {n} = {p} * {q}")
        print(f"    budget {budget} values (~{budget / isqrt(isqrt(n)):.1f} * N^(1/4) = "
              f"{isqrt(isqrt(n))}), factor {label}: {factor}")
        print(f"    deterministic guarantee would need > p = {p} values "
              f"(~sqrt(N) = {isqrt(n)})")
    print("  randomised search lives at N^(1/4); the deterministic wall is sqrt(N).")
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    print()
    print("THE 3SUM-BIRTHDAY-BOUND HIERARCHY -- NUMERICAL DEMONSTRATIONS")
    print()
    demo_factor_reveal()
    demo_143_census()
    demo_reveal_density()
    demo_threshold_table()
    demo_arity_reduction()
    demo_gcd_query_bound()
    demo_counting_birthday()
    demo_end_to_end()
    print("=" * 74)
    print("Summary: the reveal is exact, the deterministic threshold is > p at")
    print("every arity (so sqrt(N) for a balanced semiprime), the gcd-query bound")
    print("reproduces it unconditionally, and the randomised threshold sits at")
    print("sqrt(p) = N^(1/4) -- a two-level barrier.")
    print("=" * 74)


if __name__ == "__main__":
    main()
