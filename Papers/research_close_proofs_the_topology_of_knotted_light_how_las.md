# Mixed-Radix Positional Number Systems: A Unified Theory of Uniqueness and Existence, with the Factorial System as a Special Case

## Abstract

We develop, from first principles, the theory of **mixed-radix positional number systems**: positional numeral systems in which each digit position carries its own base. Fixing a sequence of positive bases $b_0, b_1, b_2, \dots$, the place value of position $i$ is the running product $P_i = \prod_{j<i} b_j$, a digit $c_i$ is *valid* when $c_i < b_i$, and a length-$k$ numeral $c_0, \dots, c_{k-1}$ represents the integer $\sum_{i<k} c_i P_i$. We prove two structural theorems. First, a **uniqueness theorem**: two valid length-$k$ numerals with the same value are identical digit-for-digit. Second, an **existence theorem**: every integer $n$ with $0 \le n < P_k$ is represented by an explicit valid numeral obtained by greedy digit extraction. Together these establish that, for every length $k$, valid numerals biject with the integer interval $[0, P_k)$. The proof of uniqueness is **direct and non-circular**: it uses only a size bound and the Euclidean splitting identities, never surjectivity, cardinality, or an enumeration. As special cases we recover ordinary base-$N$ notation (constant bases $b_i = N$, giving $P_i = N^i$) and the **factorial number system** (bases $b_i = i+1$, giving $P_i = i!$). Finally, we show that the classical factorial-system uniqueness theorem is a one-line corollary of the general theorem, transported along the identity $\prod_{j<i}(j+1) = i!$; this demonstrates that the general theory genuinely subsumes, rather than merely restates, the factorial case. We also discuss the degenerate base $b_i = 0$, the role of the running product as the sole carrier of counting information, algorithms, applications to permutation ranking, and directions for future work.

**Keywords:** mixed-radix, positional number system, factorial number system, factoradic, radix, Euclidean division, uniqueness of representation, permutation ranking.

## 1. Introduction

A positional (place-value) number system represents an integer as a weighted sum of digits, where the weights are determined by position. In the ubiquitous base-$N$ systems the weight of position $i$ is $N^i$, a single fixed base $N$ raised to the position. Mixed-radix systems relax this rigidity: they allow a *different* base at each position. Familiar examples abound — timekeeping (seconds, minutes, hours, days), historical monetary systems, and the odometer-like counters that mix units — but the phenomenon is best studied abstractly, at the level where all such systems are instances of one construction.

Two systems anchor the discussion. The first is ordinary base-$N$ notation, the constant-base case. The second is the **factorial number system** (also called *factoradic*), in which the place values are the factorials $1!, 2!, 3!, \dots$ and the digit at position $i$ ranges over $0, 1, \dots, i$. The factorial system is the natural coordinate system for permutations: since there are $i!$ arrangements of $i$ symbols, factoradic digits encode the *Lehmer code* of a permutation and support direct ranking and unranking without enumeration.

The purpose of this paper is to present a single parameterized theory that contains both systems, to prove its two foundational theorems (uniqueness and existence) by elementary and non-circular arguments, and to exhibit the factorial system precisely as the instance $b_i = i+1$, deducing its uniqueness theorem as a corollary. A guiding methodological point is that the proofs depend only on two features of a system — the *running product* of the bases and the *local digit bound* — and never on the arithmetic of any individual base. This is what makes the generalization faithful: the specialized factorial proof survives the generalization unchanged in structure.

## 2. Definitions

Throughout, digits and bases are natural numbers, and division is Euclidean (quotient and remainder over $\mathbb{N}$).

**Definition 2.1 (Bases and running product).** A *base sequence* is a function $b : \mathbb{N} \to \mathbb{N}$. Its *running product* is
$$P_k := \prod_{i<k} b_i = b_0 b_1 \cdots b_{k-1}, \qquad P_0 = 1.$$
Equivalently, $P_0 = 1$ and $P_{k+1} = P_k \cdot b_k$.

**Definition 2.2 (Value).** For a digit function $c : \mathbb{N} \to \mathbb{N}$ and a length $k$, the *length-$k$ value* is
$$V(c, k) := \sum_{i<k} c_i\, P_i.$$
It satisfies $V(c, 0) = 0$ and the peeling recurrence $V(c, k+1) = V(c, k) + c_k\, P_k$.

**Definition 2.3 (Validity).** A digit function $c$ is *valid up to length $k$*, written $\mathrm{Valid}(c, k)$, if $c_i < b_i$ for all $i < k$. Validity is monotone: $\mathrm{Valid}(c, k+1)$ implies $\mathrm{Valid}(c, k)$.

**Definition 2.4 (Digit extraction).** For an integer $n$, the *extracted digit* at position $i$ is
$$d_i(n) := \left\lfloor \frac{n}{P_i} \right\rfloor \bmod b_i.$$

Two instances organize the whole paper.

**Example 2.5 (Base-$N$).** With $b_i = N$ constant, $P_k = N^k$, and Definition 2.2 is ordinary base-$N$ notation; validity is the familiar $0 \le c_i < N$.

**Example 2.6 (Factorial system).** With $b_i = i+1$, the running product is $P_k = \prod_{i<k}(i+1) = k!$, so the place values are the factorials. Validity $c_i < i+1$ is equivalent to the factoradic bound $c_i \le i$.

## 3. The Size Bound

The linchpin of the entire development is that a valid numeral cannot reach the next place value.

**Lemma 3.1 (Positivity of the running product under validity).** If $\mathrm{Valid}(c, k+1)$, then $P_k > 0$.

*Proof sketch.* Each factor $b_i$ for $i < k$ satisfies $b_i > c_i \ge 0$, hence $b_i \ge 1$. A product of positive naturals is positive. $\square$

**Lemma 3.2 (Size bound).** If $\mathrm{Valid}(c, k)$, then
$$V(c, k) < P_k.$$

*Proof sketch.* Induction on $k$. For $k = 0$ both sides are $0 < 1$. For the step, assume the bound for length $k$. By the recurrence,
$$V(c, k+1) = V(c, k) + c_k P_k < P_k + c_k P_k = (c_k + 1) P_k \le b_k P_k = P_{k+1},$$
using the induction hypothesis $V(c, k) < P_k$ and the validity $c_k + 1 \le b_k$. $\square$

This is the mixed-radix analogue of "a $k$-digit base-$N$ number is less than $N^k$."

## 4. The Splitting Identities

Because the tail can never accumulate a whole top place value, the top digit and the tail decouple under Euclidean division by $P_k$.

**Lemma 4.1 (Division recovers the top digit).** If $\mathrm{Valid}(c, k+1)$, then
$$\left\lfloor \frac{V(c, k+1)}{P_k} \right\rfloor = c_k.$$

*Proof sketch.* Write $V(c, k+1) = V(c, k) + c_k P_k$. Since $V(c, k) < P_k$ by Lemma 3.2 (applied to the restriction, valid by monotonicity) and $P_k > 0$ by Lemma 3.1, the quotient of $V(c,k) + c_k P_k$ by $P_k$ is $c_k$ (the low part contributes nothing to the quotient). $\square$

**Lemma 4.2 (Remainder recovers the tail).** If $\mathrm{Valid}(c, k+1)$, then
$$V(c, k+1) \bmod P_k = V(c, k).$$

*Proof sketch.* Again $V(c, k+1) = V(c, k) + c_k P_k$; the term $c_k P_k$ is a multiple of $P_k$, and $V(c, k) < P_k$, so the remainder is exactly $V(c, k)$. $\square$

## 5. Uniqueness

**Theorem 5.1 (Uniqueness of valid representations).** *If $\mathrm{Valid}(c, k)$, $\mathrm{Valid}(d, k)$, and $V(c, k) = V(d, k)$, then $c_i = d_i$ for all $i < k$.*

*Proof sketch.* Induction on $k$. The base case $k=0$ is vacuous. For the step, suppose the two valid length-$(k+1)$ numerals share a value. Applying Lemma 4.1 to both and equating quotients gives $c_k = d_k$; applying Lemma 4.2 to both and equating remainders gives $V(c, k) = V(d, k)$. The induction hypothesis (validity restricts by monotonicity) yields $c_i = d_i$ for all $i < k$, and combined with $c_k = d_k$ this covers all $i < k+1$. $\square$

We stress that this proof is **direct and non-circular**: it invokes only the size bound (Lemma 3.2) and the splitting identities (Lemmas 4.1, 4.2), each proved from arithmetic and the definition of validity. It does not pass through cardinality, surjectivity, a counting bijection, or any enumeration theorem. In particular the existence results of the next section are logically downstream of uniqueness and are not used in its proof.

## 6. Existence and the Counting Bijection

**Lemma 6.1 (Extracted digits are valid).** If $b_i > 0$ for all $i$, then $\mathrm{Valid}(d(n), k)$ for every $n$ and $k$; indeed $d_i(n) = \lfloor n/P_i\rfloor \bmod b_i < b_i$ whenever $b_i > 0$.

*Proof sketch.* A remainder modulo a positive number is strictly below it. $\square$

**Theorem 6.2 (Existence / surjectivity).** *If $0 \le n < P_k$, then $V(d(n), k) = n$.*

*Proof sketch.* One proves, for every $m$, the "long division" identity
$$n = \sum_{i<m} \Big(\big\lfloor n/P_i\big\rfloor \bmod b_i\Big) P_i + \big\lfloor n/P_m \big\rfloor\, P_m,$$
by induction on $m$, using $\lfloor n / P_{m+1}\rfloor = \lfloor \lfloor n/P_m\rfloor / b_m\rfloor$ (since $P_{m+1} = P_m b_m$) and the Euclidean identity $\lfloor n/P_m\rfloor = (\lfloor n/P_m\rfloor \bmod b_m) + b_m\lfloor n/P_{m+1}\rfloor$. Setting $m = k$ and using $\lfloor n/P_k\rfloor = 0$ (from $n < P_k$) collapses the trailing term, leaving $n = V(d(n), k)$. Note $n < P_k$ already forces $P_k > 0$, so no separate positivity hypothesis on the bases is needed for this statement. $\square$

**Corollary 6.3 (Counting bijection).** For each $k$, the map $c \mapsto V(c, k)$ is a bijection from the set of valid length-$k$ digit functions onto the integer interval $\{0, 1, \dots, P_k - 1\}$. Injectivity is Theorem 5.1; surjectivity onto the interval is Lemma 3.2 (values land in the interval) together with Theorem 6.2 (every point is hit).

Thus the representable set at length $k$ is exactly the interval $[0, P_k)$, of size $P_k$. All counting information is carried by the running product alone.

## 7. Special Cases and the Factorial Bridge

**Proposition 7.1 (Base-$N$ place values).** For $b_i = N$, $P_k = N^k$.

*Proof sketch.* $\prod_{i<k} N = N^k$. $\square$

**Proposition 7.2 (Factorial place values).** For $b_i = i+1$, $P_k = k!$.

*Proof sketch.* Induction: $P_0 = 1 = 0!$ and $P_{k+1} = P_k \cdot (k+1) = k!\,(k+1) = (k+1)!$. This is the identity $\prod_{j<i}(j+1) = i!$. $\square$

**Proposition 7.3 (Factorial validity).** For $b_i = i+1$, $\mathrm{Valid}(c, k)$ holds iff $c_i \le i$ for all $i < k$.

*Proof sketch.* $c_i < i+1 \iff c_i \le i$ over the naturals. $\square$

We now define the classical factorial system independently and match it to the instance. The *factoradic value* is $V^{!}(c, k) = \sum_{i<k} c_i\, i!$, with factoradic validity $c_i \le i$.

**Proposition 7.4 (Values agree).** $V(c, k) = V^{!}(c, k)$ when $b_i = i+1$.

*Proof sketch.* Term-by-term, the mixed-radix place value $P_i$ equals $i!$ by Proposition 7.2; summing gives the identical total. $\square$

**Proposition 7.5 (Validity agrees).** For $b_i = i+1$, mixed-radix validity coincides with factoradic validity, by Proposition 7.3.

**Theorem 7.6 (Factorial uniqueness as a corollary).** *If two factoradic-valid digit functions $c, d$ satisfy $V^{!}(c, k) = V^{!}(d, k)$, then $c_i = d_i$ for all $i < k$.*

*Proof sketch.* Transport the hypotheses along Propositions 7.4 and 7.5 to the instance $b_i = i+1$: factoradic validity becomes mixed-radix validity, and equality of factoradic values becomes equality of mixed-radix values. Apply the general Uniqueness Theorem 5.1. The conclusion transports back verbatim. $\square$

This corollary is the crux of the unification. The factorial system is not merely *similar* to a mixed-radix system; it *is* the mixed-radix system with bases $b_i = i+1$, and its uniqueness theorem is a specialization of the general one, with the only nontrivial ingredient being the running-product identity $\prod_{j<i}(j+1) = i!$. Everything else is transport along that equality. Base-$N$ notation is another point in the same family (Proposition 7.1).

## 8. The Degenerate Base and Vacuity

A pleasant robustness feature: if $b_i = 0$ for some $i$, then no digit is valid at position $i$ (there is no natural number strictly below $0$). Consequently $\mathrm{Valid}(c, k)$ is unsatisfiable for $k > i$, and every theorem whose hypothesis includes such validity holds vacuously. These are honest universally quantified statements about valid representations, not disguised falsehoods; the framework absorbs the degenerate case without special handling. Notably, Theorem 6.2 sidesteps positivity entirely because $n < P_k$ already forces $P_k > 0$.

## 9. Algorithms

The theory yields immediately usable algorithms; all run in time proportional to the number of digits (with school-book bignum arithmetic, near-linear in the bit length for reasonable base sequences).

**Encoding (integer $\to$ digits).** Given $n$ and length $k$, extract digits by repeated division. Two equivalent formulations:
- *Global:* $c_i = \lfloor n / P_i\rfloor \bmod b_i$, precomputing the running products $P_i$.
- *Streaming:* maintain a running quotient $q_0 = n$; at step $i$ set $c_i = q_i \bmod b_i$ and $q_{i+1} = \lfloor q_i / b_i\rfloor$. This avoids materializing the (possibly huge) products $P_i$.

**Decoding (digits $\to$ integer).** Evaluate by Horner's method against the local bases:
$$V = (\cdots((c_{k-1})\,b_{k-2} + c_{k-2})\,b_{k-3} + \cdots)\,b_0 + c_0.$$

**Successor / carry propagation.** To add one to a valid numeral, increment $c_0$; while a digit reaches its local base $b_i$, set it to $0$ and carry into position $i+1$. Correctness (that the result is the numeral of value one larger) follows from the same local bound $c_i < b_i$ that governs validity — a base-independent phenomenon.

## 10. Applications

**Permutation ranking (Lehmer codes).** The factorial instance is the natural coordinate system for permutations of $n$ symbols. The factoradic digits of a rank $r \in [0, n!)$ are exactly the Lehmer code, and Corollary 6.3 (the bijection $[0, n!) \leftrightarrow$ valid factoradic strings) is precisely the ranking/unranking correspondence. This supports $O(n)$ selection of the $r$-th permutation in lexicographic order without enumerating predecessors.

**Combinatorial number systems and counters.** Mixed-radix counters model odometers, calendar arithmetic, and any nested-unit measurement. The counting bijection guarantees such counters cycle through exactly $P_k$ states before overflow.

**Hashing and enumeration.** The explicit bijection with an integer interval provides perfect, collision-free indexing of structured objects (tuples with per-coordinate bounds) into a contiguous integer range — a mixed-radix flattening frequently used to index multidimensional arrays with heterogeneous dimensions.

## 11. Discussion

The organizing insight is that uniqueness and existence never depend on the arithmetic of any individual base — only on the running product $P_i$ and the local bound $c_i < b_i$. This has three consequences worth emphasizing. First, it explains *why* the factorial system behaves like a number system at all: it inherits the general theorems automatically. Second, it identifies the running product as the sole carrier of "how many numbers fit," since the representable set at length $k$ is always the interval $[0, P_k)$. Third, it makes the degenerate base harmless, because validity — the hypothesis of every theorem — simply becomes unsatisfiable.

The non-circularity of the uniqueness proof is a deliberate structural choice. Many treatments derive uniqueness from a cardinality/counting argument (there are $P_k$ valid strings and $P_k$ target values, and surjectivity forces injectivity). We instead prove uniqueness *directly* from the size bound and Euclidean splitting, so that existence and the counting bijection are genuine consequences rather than prerequisites. This clean dependency order clarifies exactly which facts each result needs.

## 12. Future Directions

Several natural extensions grow directly out of the unification.

1. **A single counting bijection for arbitrary positive bases.** Package the uniqueness (injectivity) and existence (surjectivity) halves as one bijection $c \mapsto \sum_{i<k} c_i P_i$ from valid length-$k$ digit functions onto $[0, P_k)$, for every positive base sequence. Both halves depend only on the running product and the local bound $c_i < b_i$; uniqueness comes from Euclidean division by the running product, surjectivity from greedy extraction. This is the capstone turning two one-sided facts into a structural equivalence.

2. **Base-independent carry propagation.** Prove that incrementing a valid mixed-radix numeral by one — resolving carries digit by digit against the local bases — always yields the numeral of value one larger, for any positive base sequence. A carry at position $i$ fires exactly when a digit reaches its local base $b_i$, so successor correctness is governed by the same $c_i < b_i$ bound as validity, uniformly across factorial, binary, decimal, and every mixed system. This is the gateway to base-independent addition.

3. **Representable intervals determined by the product.** Prove that two positive base sequences represent exactly the same set of integers at every length iff their running products agree at every length, and that the representable set at length $k$ is precisely $[0, P_k)$. All combinatorial information about "how many numbers fit" is a function of the product sequence rather than the individual bases; the factorial-versus-mixed bridge already exhibits one nontrivial pair of distinct-looking definitions that coincide because their products coincide.

## 13. Conclusion

Mixed-radix positional systems form a single parameterized family governed by two elementary theorems: valid numerals are unique, and every integer below the running product is represented. The proofs turn only on the running product and the local digit bound, and thereby subsume both ordinary base-$N$ notation and the factorial number system. In particular, the factorial system's uniqueness theorem is a corollary of the general one, obtained by transport along $\prod_{j<i}(j+1) = i!$. The result is a tidy, non-circular foundation in which decimal, binary, sexagesimal, and factoradic notation are visibly the same construction viewed at different bases.
