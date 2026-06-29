# One-Way Functions Are Computational, Not Information-Theoretic: Weak Inverses, Exact-Inversion Capacity, and the Order Structure of the Hardness Hierarchy

## Abstract

One-way functions (OWFs) are the foundational primitive of modern cryptography, yet the precise reason they are a *complexity-theoretic* rather than an *information-theoretic* object is often relegated to folklore. We isolate and formalize this conceptual core over arbitrary nonempty domains. Our central result is that **no function is information-theoretically one-way**: every function admits a *weak inverse* — a map that, for every input, recovers some genuine preimage of the corresponding output — and consequently an unbounded adversary always inverts perfectly. One-wayness therefore can never arise from a lack of information; it can only arise from a bound on computation. We then quantify the combinatorial structure of inversion over finite domains. While weak inversion always succeeds on the entire domain, *exact* inversion — recovering the precise original input — is fundamentally limited by collisions: we prove that any inverter recovers at most `|\mathrm{Im}\, f|` inputs exactly, that this bound is sharp, and that the canonical inverter `\mathrm{invFun}\, f` attains it. The image size of a function is thus exactly the information-theoretic capacity of exact recovery. Finally, we expose the order-theoretic skeleton of the cryptographic hardness hierarchy `\mathrm{OWF} \to \mathrm{PRG} \to \mathrm{PRF} \to \mathrm{ENC}`: the rank map is injective, the implication relation is a total order order-isomorphic to a four-element chain, and OWF and ENC are its extremal elements. All results are fully machine-checked.

**Keywords:** one-way functions, weak inverse, information-theoretic security, computational hardness, preimage counting, cryptographic hierarchy, order theory.

---

## 1. Introduction

### 1.1 Motivation

The padlock metaphor for cryptography — a function easy to apply but impossible to reverse — is pedagogically irresistible and mathematically misleading. Taken literally it suggests that the output of a one-way function fails to *contain* the information needed to recover the input, in analogy with a one-time pad, whose security is genuinely information-theoretic (Shannon, 1949). This analogy is false, and the falsehood is not a technicality: it is the defining feature of the entire subject. One-wayness is a statement about *bounded computation*, and the moment one removes the resource bound, every function becomes trivially invertible.

This paper formalizes that statement and its quantitative refinements. Our goal is not to introduce new cryptographic constructions but to pin down, with complete rigor, the conceptual boundary between information and effort that the whole field presupposes.

### 1.2 Contributions

1. **Information-theoretic impossibility of one-wayness** (§3). We define weak inverses, prove every function over a nonempty domain has one, and deduce that no function is information-theoretically one-way.
2. **Quantitative inversion over finite domains** (§4). A weak inverter succeeds on the entire domain (`|\alpha|` inputs).
3. **Exact-inversion capacity** (§5). We prove a sharp bound: any inverter recovers at most `|\mathrm{Im}\, f|` inputs exactly, and `\mathrm{invFun}\, f` attains this optimum, identifying `|\mathrm{Im}\, f|` as the exact-recovery capacity.
4. **Order structure of the hierarchy** (§6). We upgrade the discrete rank chain `\mathrm{OWF} \to \mathrm{PRG} \to \mathrm{PRF} \to \mathrm{ENC}` to a genuine total order with explicit extrema, plus supporting structural and combinatorial theorems (lossy collision bounds, PRG stretch obstructions, hybrid-argument decomposition, fiber partitions, reduction composition, amplification).

### 1.3 Relation to standard cryptographic theory

The construction-level content of the hierarchy — that OWFs yield pseudorandom generators (Håstad–Impagliazzo–Levin–Luby, 1999), PRGs yield pseudorandom functions (Goldreich–Goldwasser–Micali, 1986), and PRFs yield IND-CPA encryption — is classical. Our contribution is to isolate the *structural and combinatorial invariants* underneath these reductions and the *existence layer* beneath the hierarchy: the precise reason OWF existence must be *assumed*.

---

## 2. Preliminaries and Notation

Throughout, `\alpha` and `\beta` are types (sets); `f : \alpha \to \beta` is an arbitrary function. We write `\mathrm{Im}\, f` for the image of `f`, and over finite domains identify it with the finite set of distinct output values, of cardinality `|\mathrm{Im}\, f|`. We write `|\alpha|` for the cardinality of a finite type `\alpha`.

**Canonical inverter.** For a function `f` on a nonempty domain, `\mathrm{invFun}\, f : \beta \to \alpha` denotes the canonical choice function: for `y \in \mathrm{Im}\, f`, `\mathrm{invFun}\, f(y)` is some fixed element with `f(\mathrm{invFun}\, f(y)) = y`; for `y \notin \mathrm{Im}\, f` it returns an arbitrary fixed element of `\alpha`. Its defining property is:

> **(invFun-eq)** If `y \in \mathrm{Im}\, f`, then `f(\mathrm{invFun}\, f(y)) = y`.

**Fiber.** For `y \in \beta`, the *fiber* of `f` over `y` is `f^{-1}(y) = \{x : f(x) = y\}`, the set of inputs mapping to `y`. A *collision* is a pair of distinct inputs in a common fiber.

---

## 3. Weak Inverses and Information-Theoretic Impossibility

### 3.1 Definitions

The naive notion of inversion — a left inverse `g` with `g(f(x)) = x` — is unattainable for non-injective `f`: two inputs sharing an output cannot both be recovered. The correct, always-attainable notion recovers *a* preimage, not *the* input.

> **Definition 3.1 (Weak inverse).** A map `g : \beta \to \alpha` is a *weak inverse* of `f : \alpha \to \beta` if
> ```
> for all x:   f(g(f(x))) = f(x).
> ```
> Equivalently, `g(f(x))` always lies in the fiber of `f(x)`.

> **Definition 3.2 (Information-theoretic one-wayness).** A function `f` is *information-theoretically one-way* if *no* inverter succeeds everywhere; formally,
> ```
> for all g : β → α,   there exists x   with   f(g(f(x))) ≠ f(x).
> ```

Definition 3.2 is the faithful formalization of the "padlock with no key" intuition: every candidate inverter must fail on at least one input.

### 3.2 The canonical inverter is always weak

> **Theorem 3.3 (`invFun_weakInverse`).** For any `f : \alpha \to \beta` over a nonempty domain `\alpha`, the canonical inverter `\mathrm{invFun}\, f` is a weak inverse of `f`.

*Proof.* Fix `x`. Since `f(x) \in \mathrm{Im}\, f` (witnessed by `x` itself), property (invFun-eq) applied to `y = f(x)` gives `f(\mathrm{invFun}\, f(f(x))) = f(x)`. This is exactly the weak-inverse condition at `x`. ∎

> **Corollary 3.4 (`exists_weakInverse`).** Every `f` over a nonempty domain has a weak inverse.

*Proof.* Take `g = \mathrm{invFun}\, f` and apply Theorem 3.3. ∎

### 3.3 No function is information-theoretically one-way

> **Theorem 3.5 (`not_infoTheoreticOneWay`).** For any `f` over a nonempty domain, `f` is *not* information-theoretically one-way.

*Proof.* Suppose for contradiction that `f` is information-theoretically one-way. By Corollary 3.4 there is a weak inverse `g`, so `f(g(f(x))) = f(x)` for all `x`. Applying the one-wayness hypothesis to this particular `g` yields some `x_0` with `f(g(f(x_0))) \neq f(x_0)`, contradicting the weak-inverse identity at `x_0`. ∎

**Discussion.** Theorem 3.5 is the conceptual keystone. It shows that one-wayness can never be derived from information theory: the output `f(x)` always carries enough information to reconstruct a valid preimage, and an unbounded adversary realizes this via the lookup table `\mathrm{invFun}\, f`. Security must therefore come from *computational* bounds — the cost of constructing or searching that table, which for an `n`-bit domain is `\Theta(2^n)`. This is precisely why the existence of one-way functions is *assumed* as a hardness hypothesis rather than proved; it is also, ultimately, equivalent to `\mathbf{P} \neq \mathbf{NP}`-flavored separations being insufficient on their own and to the existence of hard-on-average problems.

---

## 4. Quantitative Inversion over Finite Domains

We now restrict to finite `\alpha` (with decidable equality on `\beta`) and count successes.

> **Theorem 4.1 (`weakInverse_inverts_all`).** If `g` is a weak inverse of `f`, then
> ```
> | { x ∈ α : f(g(f(x))) = f(x) } |  =  |α|.
> ```

*Proof.* By Definition 3.1 the predicate `f(g(f(x))) = f(x)` holds for every `x`, so the filtered set is the entire universe, whose cardinality is `|\alpha|`. ∎

Thus, in the weak sense, an unbounded adversary inverts with *perfect* advantage on all `|\alpha|` inputs. The interesting limitations appear only when we demand *exact* recovery, which we treat next.

---

## 5. The Combinatorial Capacity of Exact Inversion

### 5.1 Exact inversions

> **Definition 5.1 (`exactInversions`).** The set of inputs that `g` recovers *exactly* is
> ```
> ExactInv(f, g) = { x ∈ α : g(f(x)) = x }.
> ```

Unlike weak inversion, exact inversion is constrained by collisions: within a single fiber `f^{-1}(y)`, at most one element `x` can satisfy `g(y) = x`, since `g(y)` is a single value.

### 5.2 The upper bound

> **Theorem 5.2 (`exact_inversions_le_image`).** For any `f` and any inverter `g`,
> ```
> | ExactInv(f, g) |  ≤  |Im f|.
> ```

*Proof.* We show `f` is injective on `S := \mathrm{ExactInv}(f,g)`; the claim then follows since `f` maps `S` into `\mathrm{Im}\, f` and an injection cannot increase cardinality. Let `x, y \in S` with `f(x) = f(y)`. Then
```
x = g(f(x)) = g(f(y)) = y,
```
using `x, y \in S` for the outer equalities and `f(x) = f(y)` for the middle one. Hence `f` is injective on `S`, and `|S| = |f(S)| \le |\mathrm{Im}\, f|`. ∎

### 5.3 Sharpness: the canonical inverter attains the optimum

> **Theorem 5.3 (`invFun_exact_inversions`).** For any `f` over a nonempty domain,
> ```
> | ExactInv(f, invFun f) |  =  |Im f|.
> ```

*Proof.* We exhibit a set identity and a bijection.

*Step 1 (set identity).* We claim `\mathrm{ExactInv}(f, \mathrm{invFun}\, f) = \mathrm{invFun}\, f(\mathrm{Im}\, f)`, i.e. the exactly-recovered inputs are exactly the canonical representatives of the fibers.
- (⊆) If `\mathrm{invFun}\, f(f(x)) = x`, then `x = \mathrm{invFun}\, f(y)` for `y = f(x) \in \mathrm{Im}\, f`.
- (⊇) If `x = \mathrm{invFun}\, f(f(a))` for some `a`, then by (invFun-eq), `f(\mathrm{invFun}\, f(f(a))) = f(a)`, so `f(x) = f(a)`, hence `\mathrm{invFun}\, f(f(x)) = \mathrm{invFun}\, f(f(a)) = x`; thus `x \in \mathrm{ExactInv}`.

*Step 2 (injectivity of the representative map).* The map `y \mapsto \mathrm{invFun}\, f(y)` is injective on `\mathrm{Im}\, f`: if `y = f(a)`, `z = f(b)` and `\mathrm{invFun}\, f(y) = \mathrm{invFun}\, f(z)`, then applying `f` and using (invFun-eq) twice gives `y = f(\mathrm{invFun}\, f(y)) = f(\mathrm{invFun}\, f(z)) = z`.

By Steps 1–2, the canonical representative map is a bijection from `\mathrm{Im}\, f` onto `\mathrm{ExactInv}(f, \mathrm{invFun}\, f)`, so the two sets have equal cardinality `|\mathrm{Im}\, f|`. ∎

### 5.4 Interpretation

Theorems 5.2–5.3 jointly identify `|\mathrm{Im}\, f|` as the **exact-inversion capacity** of `f`: the maximum number of inputs any adversary can pin down precisely, and a maximum the *simplest* strategy already achieves. A lossy function with small image — the defining feature of the lossy-OWF model — is intrinsically hard to invert *exactly* on most of its domain, even though it is trivially invertible *weakly* everywhere (Theorem 4.1). The contrast between Theorem 4.1 (`|\alpha|` weak successes) and Theorem 5.2 (`\le |\mathrm{Im}\, f|` exact successes) precisely localizes where collision structure becomes an obstruction.

---

## 6. Structural and Order-Theoretic Skeleton of the Hierarchy

The four canonical primitives form a chain
```
OWF  →  PRG  →  PRF  →  ENC,
```
modeled as an enumeration `\mathrm{CryptoLevel}` with a rank function `\mathrm{rank}(\mathrm{OWF}) = 0`, `\mathrm{rank}(\mathrm{PRG}) = 1`, `\mathrm{rank}(\mathrm{PRF}) = 2`, `\mathrm{rank}(\mathrm{ENC}) = 3`. The implication order is defined by `A \le B \iff \mathrm{rank}(B) \le \mathrm{rank}(A)` (a stronger primitive sits "below" a weaker assumption in implication order, i.e. assuming the stronger primitive implies the weaker one).

> **Theorem 6.1 (`rank_injective`).** The rank map `\mathrm{CryptoLevel} \to \mathbb{N}` is injective: distinct levels have distinct ranks.

> **Theorem 6.2 (`level_total`).** For all levels `A, B`, either `A \le B` or `B \le A`. The implication relation is a total order.

*Proof.* Totality of `\le` on ranks transfers across the definition: `A \le B \lor B \le A` reduces to `\mathrm{rank}(B) \le \mathrm{rank}(A) \lor \mathrm{rank}(A) \le \mathrm{rank}(B)`, which holds in `\mathbb{N}`. ∎

> **Theorem 6.3 (`owf_weakest`).** For every level `A`, `A \le \mathrm{OWF}`. One-way functions are the weakest assumption (the implication-order top), implied by every other primitive.

> **Theorem 6.4 (`enc_strongest`).** For every level `A`, `\mathrm{ENC} \le A`. Secure encryption is the strongest assumption (the implication-order bottom), implying every other primitive.

Together, Theorems 6.1–6.4 say the hierarchy is order-isomorphic to the four-element chain `0 < 1 < 2 < 3`, with explicit extremal elements — a precise formalization of the informal "tower of assumptions."

### 6.1 Supporting combinatorial theorems

The chain rests on a body of structural results, each capturing the mathematical content of a classical reduction:

- **Lossy collision bound (`lossy_collision_exists`).** If a function's image size is strictly below its domain size, a collision exists (pigeonhole). This is the combinatorial heart of lossiness.
- **PRG stretch obstruction (`prg_stretch_not_surjective`, `prg_output_gap`).** A map from a smaller to a larger finite type cannot be surjective; the number of unreachable outputs is at least `|\beta| - |\alpha|`. This formalizes why a length-stretching generator's output is sparse in the codomain — the basis of its distinguishability-from-random analysis.
- **Fiber partition (`fiber_sum_eq_card`).** The fiber sizes sum to the domain size, `\sum_{y \in \mathrm{Im}\, f} |f^{-1}(y)| = |\alpha|`; consequently a large fiber (size `\ge 2`) must exist whenever `|\mathrm{Im}\, f| < |\alpha|` (`large_fiber_exists`), yielding an explicit collision (`collision_from_large_fiber`).
- **Hybrid argument (`hybrid_advantage_triangle`, `hybrid_advantage_lower`).** For a sequence of `n` hybrid experiments with per-step advantages `\varepsilon_i \ge 0`, the total advantage satisfies `\max_i \varepsilon_i \le \sum_i \varepsilon_i \le n \cdot \max_i \varepsilon_i`. This is the standard telescoping bound underlying PRG-to-PRF and encryption security proofs.
- **GGM image bound (`ggm_image_bounded`).** The Goldreich–Goldwasser–Micali tree evaluated over any path set has image at most `|\alpha|`, reflecting the seed-space bottleneck of the PRG-to-PRF construction.
- **Reduction composition (`reduction_compose_loss`).** Composing reductions multiplies their loss factors: from `\mathrm{adv}_B \le L_1 \cdot \mathrm{adv}_A` and `\mathrm{adv}_C \le L_2 \cdot \mathrm{adv}_B` one gets `\mathrm{adv}_C \le (L_1 L_2)\,\mathrm{adv}_A`. The accompanying `SecurityProfile` structure tracks end-to-end degradation through a chain, with total degradation `\prod_i d_i \ge 1` and `\mathrm{security}_0 \le (\prod_i d_i)\,\mathrm{security}_{\mathrm{top}}`.
- **Amplification (`amplification_bound`, `amplification_monotone`).** Failure probability `(1-p)^k` stays `\le 1` and is non-increasing in `k`, the quantitative basis of weak-to-strong OWF amplification.
- **Collision-free counting (`collision_free_le_domain`, `injective_all_collision_free`).** The number of outputs with a unique preimage is at most `|\alpha|`, with equality for injective `f`.

---

## 6.5 A Fully Worked Example

To make the abstract quantities concrete, consider the domain `\alpha = \{0,1,2,3,4,5\}` and the function `f(x) = x \bmod 3`, so `\beta = \{0,1,2\}` and:
```
  f(0)=0  f(1)=1  f(2)=2  f(3)=0  f(4)=1  f(5)=2.
```
The image is `\mathrm{Im}\, f = \{0,1,2\}`, so `|\mathrm{Im}\, f| = 3`, while `|\alpha| = 6`. The three fibers are
```
  f^{-1}(0) = {0,3},   f^{-1}(1) = {1,4},   f^{-1}(2) = {2,5},
```
each of size `2`, and indeed `\sum_y |f^{-1}(y)| = 2+2+2 = 6 = |\alpha|` (the fiber partition `fiber_sum_eq_card`). Since `|\mathrm{Im}\, f| = 3 < 6 = |\alpha|`, a large fiber must exist (`large_fiber_exists`) — in fact all three fibers exhibit collisions (`collision_from_large_fiber`).

*Weak inversion.* The canonical inverter records, for each output, the first preimage seen: `\mathrm{invFun}\, f(0) = 0`, `\mathrm{invFun}\, f(1) = 1`, `\mathrm{invFun}\, f(2) = 2`. Then for every `x`, `f(\mathrm{invFun}\, f(f(x))) = f(x)`: e.g. for `x = 4`, `f(4) = 1`, `\mathrm{invFun}\, f(1) = 1`, `f(1) = 1 = f(4)`. All six inputs succeed weakly (Theorem 4.1), so `f` is not information-theoretically one-way (Theorem 3.5).

*Exact inversion.* On the same example `\mathrm{ExactInv}(f, \mathrm{invFun}\, f) = \{0,1,2\}` — exactly the three canonical representatives — of size `3 = |\mathrm{Im}\, f|` (Theorem 5.3). No inverter can do better: any `g` recovers at most one input per fiber, hence at most `3` total (Theorem 5.2). For instance the alternative inverter `g(0)=3, g(1)=4, g(2)=5` also achieves exactly `3` exact recoveries, namely `\{3,4,5\}`, but never `4` — there are only three fibers to anchor to. This is the sense in which `|\mathrm{Im}\, f|` is a hard capacity, independent of the adversary's cleverness or resources.

*Hierarchy.* Viewing this `f` as a lossy compressing map `6 \to 3` places it conceptually at the OWF rung: it is the kind of many-to-one map whose hardness, were it computationally infeasible to invert, would seed the entire chain `\mathrm{OWF} \to \mathrm{PRG} \to \mathrm{PRF} \to \mathrm{ENC}` analyzed in §6.

## 7. Algorithms

The proofs are constructive and induce concrete algorithms.

**Algorithm A (Weak Inverter / Lookup-Table Construction).** Build a table `T : \beta \rightharpoonup \alpha` by scanning all `x \in \alpha` and recording `T[f(x)] \leftarrow x` (first writer wins). On query `y`, return `T[y]` if present, else any fixed default. This realizes `\mathrm{invFun}\, f`. Time `\Theta(|\alpha|)` to build, `O(1)` per query (hashed). It is a weak inverse (Theorem 3.3) and an *optimal* exact inverter (Theorem 5.3).

**Algorithm B (Exact-Inversion Capacity).** Compute `|\mathrm{Im}\, f|` by inserting all `f(x)` into a set; by Theorems 5.2–5.3 this number is both the maximum exact-recovery count over all inverters and the count achieved by Algorithm A. Time `\Theta(|\alpha|)`.

**Algorithm C (Hierarchy Order Oracle).** Given two levels, compare ranks to decide implication; totality (Theorem 6.2) guarantees a definite answer, and the extremal checks (Theorems 6.3–6.4) are `O(1)`.

---

## 8. Applications

1. **Pedagogy and foundations.** Theorem 3.5 gives a one-line, fully rigorous justification for *why* OWF existence is an assumption — useful in any rigorous treatment of cryptographic foundations.
2. **Lossy cryptography.** The exact-inversion capacity `|\mathrm{Im}\, f|` (§5) quantifies the "lossiness budget" exploited by lossy trapdoor functions and lossy encryption; it bounds how much an adversary can recover even with unlimited time, separating information loss from computational hardness.
3. **Security bookkeeping.** The reduction-composition and `SecurityProfile` machinery (§6.1) give a clean, machine-checkable accounting of concrete security degradation through multi-step reductions.
4. **Order-theoretic API.** The total-order skeleton (§6) lets downstream formal developments treat "primitive strength" as a linear order with extrema, simplifying meta-theorems about which assumptions imply which.

---

## 9. Discussion

The unifying theme is the strict separation of *information* from *effort*. Information-theoretically, inversion is free (Theorems 3.3–3.5, 4.1); the only genuine obstruction to *exact* recovery is the function's collision structure, captured exactly by `|\mathrm{Im}\, f|` (Theorems 5.2–5.3). Cryptographic hardness lives entirely in the computational cost of executing the otherwise-trivial inversion algorithm — a cost the order-theoretic hierarchy then organizes into a clean chain of amplifications. A notable design lesson, recorded during formalization, is that the *weak*-inverse identity `f(g(f(x))) = f(x)` — not the false left-inverse identity `g(f(x)) = x` — is the correct invariant; this single choice makes the entire impossibility argument go through over arbitrary, non-injective functions.

---

## 10. Future Directions

See the dedicated future-directions discussion accompanying this package. Briefly: (i) extend the exact-inversion capacity analysis to *approximate* recovery and to weighted/probabilistic domains, deriving expected-recovery formulas in terms of the fiber-size distribution; (ii) formalize concrete-security versions of the reduction-composition theorems with explicit runtime overheads; (iii) connect the order-theoretic skeleton to a richer lattice of assumptions (collision-resistant hashing, trapdoor permutations) beyond the linear chain; (iv) develop the average-case analogue of the collision-free conjecture, characterizing the expected number of collision-free outputs of a random function `f : \{0,1\}^n \to \{0,1\}^{2n}` (empirically `\approx N/e`).

---

## References

- O. Goldreich. *Foundations of Cryptography*, Vol. 1. Cambridge University Press, 2001.
- O. Goldreich, S. Goldwasser, S. Micali. *How to Construct Random Functions*. JACM, 1986.
- J. Håstad, R. Impagliazzo, L. Levin, M. Luby. *A Pseudorandom Generator from any One-Way Function*. SIAM J. Comput., 1999.
- C. E. Shannon. *Communication Theory of Secrecy Systems*. Bell System Technical Journal, 1949.
