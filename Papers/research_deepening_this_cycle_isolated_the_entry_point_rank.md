# The Pisano Period as the Order of the Fibonacci Shift: A Representation-Theoretic View

## Abstract

The **Pisano period** `π(m)` is the period of the Fibonacci sequence reduced modulo a positive integer `m`. It is traditionally introduced as an analytic property of a sequence and studied through congruence identities. We recast `π(m)` as a purely *representation-theoretic* invariant: it is the **order of a single group element**, the Fibonacci **shift**

```
Q : (a, b) ↦ (b, a + b),
```

regarded as a permutation of the finite set `(ℤ/mℤ)²`. Under this dictionary the Fibonacci sequence modulo `m` is the forward orbit of the seed `(0, 1)` under `Q`, the recurrence is encoded once and for all in a closed iterate formula, and periodicity, a divisibility duality, an apparition bound, and a Chinese-Remainder multiplication law become consequences of generic `orderOf` theory rather than ad hoc congruence manipulation.

Our principal results are: (1) a **closed form** for `Qᵏ` exhibiting it as the classical Fibonacci `Q`-matrix; (2) a **representation theorem** identifying the sequence with the orbit of `(0, 1)`; (3) **existence/finiteness** of `π(m)` for `m ≥ 1`; (4) the **period–return duality** `π(m) ∣ k ⟺ (F_k ≡ 0 ∧ F_{k+1} ≡ 1 \bmod m)`; (5) **periodicity** `F_{n+π(m)} ≡ F_n`; (6) the **apparition bound** `m ∣ F_{π(m)}`, hence `z(m) ∣ π(m)` where `z(m)` is the entry point; and (7) the **spectral/CRT decomposition** `π(mn) = \mathrm{lcm}(π(m), π(n))` for coprime `m, n`. All Fibonacci-specific content is localized in a single induction (the iterate formula); everything downstream is group theory and elementary divisibility.

**Keywords.** Fibonacci sequence, Pisano period, rank of apparition, entry point, permutation order, Chinese Remainder Theorem, dynamical systems, representation.

---

## 1. Introduction

Reducing the Fibonacci sequence `F_0 = 0, F_1 = 1, F_{n+2} = F_{n+1} + F_n` modulo a fixed integer `m` produces an eventually — in fact immediately — periodic sequence. Its minimal period, the **Pisano period** `π(m)`, has been studied since the early twentieth century: its values are erratic, its prime-power behaviour subtle, and its exact-value conjectures (notably that `π(p²) ≠ π(p)` for all primes `p`) remain open. The usual development proceeds through congruence identities for `F_{m+n}` and case analysis on residues.

This paper takes a structural route. The two-term recurrence is first-order on *pairs*: the map sending the state `(F_n, F_{n+1})` to the next state `(F_{n+1}, F_{n+2}) = (F_{n+1}, F_n + F_{n+1})` is the single function

```
Q(a, b) = (b, a + b).
```

Over `ℤ/mℤ` the state space `(ℤ/mℤ)²` is finite and `Q` is a bijection (its inverse is `(a,b) ↦ (b−a, a)`), so `Q` is an element of the finite symmetric group `\mathrm{Sym}((ℤ/mℤ)²)`. The Pisano period is then nothing but the **order** of `Q` in that group. This is the analogue, for the *whole plane*, of the well-known fact that the **entry point** (rank of apparition) `z(m)` — the least `k > 0` with `m ∣ F_k` — measures the order of the induced action on the *line* through `(0, 1)`.

The benefit of the reframing is economy. Periodicity, the divisibility characterization of the period, the bound relating the period to the entry point, and the Chinese-Remainder multiplicativity all follow from generic facts about element orders, once a single closed-form computation of `Qᵏ` is in hand.

### 1.1 Notation

Throughout, `F_k` denotes the `k`-th Fibonacci number with `F_0 = 0`, `F_1 = 1`. For `m ≥ 1` we write `R = ℤ/mℤ` for the ring of residues and reduce Fibonacci numbers via the ring homomorphism `ℤ → R` (denoted by a bar or by an explicit cast). We write `\mathrm{Sym}(X)` for the group of permutations of a set `X`, `\mathrm{ord}(g)` for the order of a group element `g`, and `\gcd`, `\mathrm{lcm}` for the natural-number greatest common divisor and least common multiple.

### 1.2 Historical and mathematical context

The periodicity of Fibonacci residues was already noted by Lagrange in the eighteenth century, and the systematic study of the periods `π(m)` is associated with the work of D. D. Wall in the 1960s, whose name is attached to the still-open conjecture that `π(p²) ≠ π(p)` for every prime `p`. The companion notion of the rank of apparition — the first index at which a given modulus divides a Fibonacci number — goes back to É. Lucas and underlies the Lucas primality test and the theory of Lucas sequences `U_n(P, Q)`. The Fibonacci `Q`-matrix `[[1,1],[1,0]]`, whose `k`-th power displays consecutive Fibonacci numbers, is a standard tool for fast computation and identity-proving. The present work does not introduce new numerical phenomena; rather it reorganizes these classical strands around a single algebraic object, the order of the shift permutation, so that the period's defining and structural properties become corollaries of elementary group theory. The same lens applies verbatim to general Lucas sequences by replacing the shift with `(a,b) ↦ (b, Pb − Qa)`, suggesting a uniform treatment of their periods and apparition ranks.

---

## 2. The Fibonacci shift and its iterates

### 2.1 Definition (the shift permutation)

For `m ≥ 1` define the **Fibonacci shift** `Q = Q_m : (ℤ/mℤ)² → (ℤ/mℤ)²` by

```
Q(a, b) = (b, a + b),       Q⁻¹(a, b) = (b − a, a).
```

A direct check that `Q⁻¹ ∘ Q = \mathrm{id}` and `Q ∘ Q⁻¹ = \mathrm{id}` shows `Q ∈ \mathrm{Sym}((ℤ/mℤ)²)`. Because `(ℤ/mℤ)²` is finite, `\mathrm{Sym}((ℤ/mℤ)²)` is a finite group.

### 2.2 Definition (Pisano period)

The **Pisano period** of `m` is

```
π(m) := ord(Q_m),
```

the order of the Fibonacci shift in `\mathrm{Sym}((ℤ/mℤ)²)`.

### 2.3 Theorem (closed form for the iterate)

For all `m, k ≥ 0` and all `a, b ∈ ℤ/mℤ`,

```
Qᵏ(a, b) = ( a·(F_{k+1} − F_k) + b·F_k ,  a·F_k + b·F_{k+1} ).
```

Equivalently, `Qᵏ` acts on the column vector `(a, b)ᵀ` as the matrix

```
       | F_{k−1}   F_k    |
Qᵏ  =  | F_k       F_{k+1} | ,
```

the classical **Fibonacci Q-matrix** (using `F_{k+1} − F_k = F_{k−1}` for `k ≥ 1`, with the `k = 0` case `(a, b)` recovered since `F_1 − F_0 = 1`, `F_0 = 0`, `F_1 = 1`).

*Proof sketch.* Induction on `k`. The base case `k = 0` is `Q⁰(a,b) = (a, b)`, matching `(a·1 + b·0, a·0 + b·1)`. For the inductive step write `Q^{k+1} = Q ∘ Qᵏ`, apply the induction hypothesis, then `Q`, and simplify using `F_{k+2} = F_{k+1} + F_k`. Concretely, if `Qᵏ(a,b) = (x, y)` then `Q^{k+1}(a,b) = (y, x+y)`; substituting the inductive expressions for `x, y` and collecting coefficients of `a` and `b` reproduces the stated formula with `k` replaced by `k+1`. This is the **only** step in the entire theory that invokes the Fibonacci recurrence. ∎

### 2.4 Theorem (representation of the sequence as an orbit)

For all `m, k`,

```
Qᵏ(0, 1) = ( F_k , F_{k+1} )   in (ℤ/mℤ)².
```

Hence the Fibonacci sequence modulo `m` is the sequence of first coordinates of the forward orbit of the seed `(0, 1)` under `Q`.

*Proof sketch.* Specialize Theorem 2.3 at `(a, b) = (0, 1)`: the first coordinate becomes `0·(F_{k+1}−F_k) + 1·F_k = F_k` and the second `0·F_k + 1·F_{k+1} = F_{k+1}`. (Alternatively, a one-line induction using `Q(F_k, F_{k+1}) = (F_{k+1}, F_k + F_{k+1}) = (F_{k+1}, F_{k+2})`.) ∎

This is the *representation theorem*: the dynamical object (the orbit) and the arithmetic object (the sequence) coincide.

---

## 3. Existence and the period–return duality

### 3.1 Theorem (existence/finiteness)

For every `m ≥ 1`, `π(m) > 0`; that is, the Pisano period exists and is a positive integer.

*Proof sketch.* `Q_m` is an element of a finite group, so it has finite positive order: by the pigeonhole principle some power `Q^k` with `k > 0` equals the identity, and the least such `k` is `ord(Q_m) = π(m) > 0`. Formally, `ord(g) ∣ k` for any `k > 0` with `g^k = 1`, and a positive divisor of a positive integer is positive. ∎

### 3.2 Lemma (triviality of a power)

For all `m, k`,

```
Qᵏ = identity  ⟺  ( F_k ≡ 0  and  F_{k+1} ≡ 1 )   in ℤ/mℤ.
```

*Proof sketch.* (⇒) If `Qᵏ` is the identity it fixes the seed `(0,1)`; by Theorem 2.4 this says `(F_k, F_{k+1}) = (0, 1)`. (⇐) If `F_k ≡ 0` and `F_{k+1} ≡ 1`, substitute into the closed form 2.3: the first coordinate becomes `a·(1 − 0) + b·0 = a` and the second `a·0 + b·1 = b`, so `Qᵏ(a, b) = (a, b)` for all `(a, b)`; by extensionality `Qᵏ = \mathrm{id}`. ∎

The forward direction needs only the orbit of the seed; the backward direction is where the *full* iterate formula earns its keep, propagating "the seed is fixed" to "every point is fixed."

### 3.3 Theorem (period–return duality)

For all `m, k`,

```
π(m) ∣ k  ⟺  ( F_k ≡ 0  and  F_{k+1} ≡ 1 )   in ℤ/mℤ.
```

*Proof sketch.* By definition `π(m) = ord(Q)`, and the generic fact `ord(g) ∣ k ⟺ g^k = 1` rewrites the left side as `Qᵏ = \mathrm{id}`. Apply Lemma 3.2. ∎

This duality is the conceptual hinge of the paper. The left-hand side is an *algebraic* statement about the period (a divisibility). The right-hand side is a *dynamical* statement (the state has returned to its seed). The two are literally the same.

### 3.4 Theorem (periodicity)

For all `m, n`,

```
F_{n + π(m)} ≡ F_n   in ℤ/mℤ.
```

*Proof sketch.* Compare first coordinates of `Q^{n+π(m)}(0,1)` and `Qⁿ(0,1)`. Since `Q^{π(m)} = 1` (Theorem 3.3 with `k = π(m)`), we have `Q^{n+π(m)} = Qⁿ ∘ Q^{π(m)} = Qⁿ`, so the two orbit points are equal; their first coordinates are `F_{n+π(m)}` and `F_n` by Theorem 2.4. ∎

Periodicity, the statement that originally *defines* the Pisano period, is here a corollary of `Q^{π(m)} = 1` with no recourse to congruence identities.

---

## 4. The bridge to the entry point

### 4.1 Definition (entry point / rank of apparition)

The **entry point** `z(m)` is the least `k > 0` with `m ∣ F_k`. Classical apparition theory provides the **ideal law**

```
m ∣ F_n  ⟺  z(m) ∣ n,
```

i.e. the set of indices at which `m` divides a Fibonacci number is exactly the multiples of `z(m)`.

### 4.2 Theorem (the period is an apparition index)

For all `m`,

```
m ∣ F_{π(m)}.
```

*Proof sketch.* Apply the period–return duality (Theorem 3.3) with `k = π(m)`. Since `π(m) ∣ π(m)`, the right-hand side gives in particular `F_{π(m)} ≡ 0` in `ℤ/mℤ`, which is exactly `m ∣ F_{π(m)}`. ∎

### 4.3 Corollary (entry point divides period)

```
z(m) ∣ π(m).
```

*Proof sketch.* By Theorem 4.2, `m ∣ F_{π(m)}`, so `π(m)` is one of the apparition indices; by the ideal law (4.1), every apparition index is a multiple of `z(m)`. ∎

**Geometric reading.** The entry point `z(m)` is the order of `Q` acting on the cyclic *line* through `(0,1)` (when the first coordinate first returns to 0), while the Pisano period `π(m)` is the order of `Q` on the whole *plane* `(ℤ/mℤ)²`. The plane returning forces the line to return, giving `z(m) ∣ π(m)`. Classically the quotient `π(m)/z(m) ∈ {1, 2, 4}`; in this picture it is the order of the scalar by which `Q^{z(m)}` acts on the seed line — a unit in `(ℤ/mℤ)ˣ` — see §7.

---

## 5. The spectral / Chinese-Remainder decomposition

### 5.1 Theorem (multiplicativity on coprime moduli)

If `\gcd(m, n) = 1`, then

```
π(mn) = lcm( π(m), π(n) ).
```

*Proof sketch.* By the Chinese Remainder Theorem the ring isomorphism `ℤ/mnℤ ≅ ℤ/mℤ × ℤ/nℤ` induces a `Q`-equivariant bijection `(ℤ/mnℤ)² ≅ (ℤ/mℤ)² × (ℤ/nℤ)²` under which the shift `Q_{mn}` corresponds to the product permutation `Q_m × Q_n`. The order of a product permutation acting componentwise is the lcm of the component orders, so `ord(Q_{mn}) = \mathrm{lcm}(ord(Q_m), ord(Q_n))`.

A self-contained route avoiding the equivariance bookkeeping uses the period–return duality directly. For any `k`,

```
π(mn) ∣ k
  ⟺ F_k ≡ 0 (mod mn)  and  F_{k+1} ≡ 1 (mod mn)            (Thm 3.3)
  ⟺ (mn ∣ F_k)  and  (mn ∣ F_{k+1} − 1).
```

Because `\gcd(m, n) = 1`, the coprime divisibility law `mn ∣ a ⟺ (m ∣ a ∧ n ∣ a)` splits each conjunct:

```
  ⟺ (m ∣ F_k ∧ n ∣ F_k) ∧ (m ∣ F_{k+1}−1 ∧ n ∣ F_{k+1}−1)
  ⟺ [F_k ≡ 0 ∧ F_{k+1} ≡ 1 (mod m)] ∧ [F_k ≡ 0 ∧ F_{k+1} ≡ 1 (mod n)]
  ⟺ π(m) ∣ k  and  π(n) ∣ k                                  (Thm 3.3, twice)
  ⟺ lcm(π(m), π(n)) ∣ k.
```

Two natural numbers with the same set of multiples are equal, so `π(mn) = \mathrm{lcm}(π(m), π(n))`. The phrasing through `ℕ`-divisibility of `F_k` and `F_{k+1} − 1` (using `1 ≤ F_{k+1}` so the subtraction is honest) avoids all `ℤ/mℤ`-cast friction. ∎

### 5.2 Corollary (reduction to prime powers)

Writing `m = ∏_i p_i^{e_i}`,

```
π(m) = lcm_i  π(p_i^{e_i}).
```

*Proof sketch.* Induct on the number of distinct prime factors using Theorem 5.1, the prime-power factors being pairwise coprime. ∎

This reduces every Pisano-period computation to prime powers, exactly mirroring the entry point's lcm law `z(mn) = \mathrm{lcm}(z(m), z(n))` for coprime `m, n`.

### 5.3 Worked examples

The spectral law turns period computation into a small factor-and-lcm exercise.

- **`m = 15 = 3 · 5`.** The sequence modulo 3 is `0,1,1,2,0,2,2,1,(0,1)...` with `π(3) = 8`; modulo 5 it is `0,1,1,2,3,0,3,3,1,4,0,4,4,3,2,0,2,2,4,1,(0,1)...` with `π(5) = 20`. Since `gcd(3,5)=1`, `π(15) = lcm(8,20) = 40`.
- **`m = 100 = 4 · 25`.** Here `π(4) = 6` and `π(25) = 100`, so `π(100) = lcm(6,100) = 300`.
- **`m = 14 = 2 · 7`.** With `π(2) = 3` and `π(7) = 16`, `π(14) = lcm(3,16) = 48`. The period–return duality then certifies the answer: `F_{48} ≡ 0` and `F_{49} ≡ 1` modulo 14, while no proper divisor of 48 is a return index.
- **`m = 143 = 11 · 13`.** From `π(11) = 10` and `π(13) = 28`, `π(143) = lcm(10,28) = 140`.

The entry-point/period ratios in these examples illustrate the trichotomy: `z(7) = 8` gives `π/z = 2`; `z(5) = 5` gives `π/z = 4`; `z(11) = 10` gives `π/z = 1`. In every case the ratio is `1`, `2`, or `4`, never anything else.

### 5.4 A note on the bound `π(m) ≤ 6m`

The direct-iteration algorithm of §6.1 loops up to `6m` because the Pisano period never exceeds `6m`, with equality precisely for `m = 2·5^k`. This crude but explicit bound suffices to guarantee termination of the naïve search; the spectral law of §5.1 is what makes the search *fast* by replacing `m` with its prime-power parts. Our development does not require the sharp `6m` constant — only that the order of a finite-group element is finite (Theorem 3.1) — so the bound is used purely as an algorithmic convenience.

---

## 6. Algorithms

### 6.1 Naïve period by direct iteration

Iterate the state `(a, b)` from `(0, 1)` until it returns to `(0, 1)`, counting steps. Correct by Theorem 2.4 and the definition of order; runs in `O(π(m))` ring operations and `O(1)` extra memory. Suitable for moderate `m`.

### 6.2 Certified period via the duality

To verify a *candidate* period `P`, check by the period–return duality (Theorem 3.3) that `F_P ≡ 0` and `F_{P+1} ≡ 1` modulo `m` (a *certificate* that `π(m) ∣ P`), and that for every prime `q ∣ P` the reduced index `P/q` fails the same test (a certificate of *minimality*). Each test costs `O(log P)` ring operations via fast matrix exponentiation of `Q` (Theorem 2.3), giving a total `O((log P)·(number of prime factors of P))`.

### 6.3 Period by prime-power decomposition

Factor `m = ∏ p_i^{e_i}`, compute each `π(p_i^{e_i})` (by §6.1 on the small modulus or by known closed-ish prime-power rules), and return `lcm_i π(p_i^{e_i})` (Corollary 5.2). This replaces a search of length up to `~6m` by several much shorter searches.

---

## 7. Discussion

**One induction, then pure symmetry.** The entire Fibonacci-specific content lives in Theorem 2.3. After it, every statement about the period — existence, the divisibility duality, periodicity, the apparition bound, and CRT-multiplicativity — is generic group theory (`ord(g) ∣ k ⟺ g^k = 1`, orders of product permutations) plus elementary `ℕ` divisibility. This is the methodological payoff of treating `π(m)` as an *order* rather than a *period length*.

**A unified frame for two classical invariants.** The entry point `z(m)` and the Pisano period `π(m)` are the orders of the *same* representation `Q` restricted to two `Q`-stable objects: the cyclic line through `(0,1)`, and the whole plane. Their parallel lcm-multiplicativity laws are the *same* CRT fact applied to the two orbits. The relation `z(m) ∣ π(m)` is the inclusion of orbits.

**The ratio `π/z`.** Classically `π(m)/z(m) ∈ {1, 2, 4}`. In the present language, `Q^{z(m)}` maps the seed line back to the horizontal axis, acting on it by a scalar `s ∈ (ℤ/mℤ)ˣ`; the ratio is `ord(s)`. The closed form 2.3 makes `s` explicit (it is built from `F_{z−1}` and `F_{z+1}`), opening a route to a fully structural proof of the `{1,2,4}` trichotomy — a natural next target.

**Relation to known facts.** None of the *values* are new: Pisano periods, the Q-matrix, and apparition theory are classical. What is new is the *organization* — collapsing scattered congruence arguments into the order of one permutation — and the resulting brevity and reusability of the proofs.

---

## 8. Future work

1. **The trichotomy `π(m)/z(m) ∈ {1,2,4}`.** Prove it as `ord(s)` for the explicit scalar `s = Q^{z(m)}|_{line}`, using the closed form to show `s² = 1` or `s⁴ = 1` according to residue conditions.
2. **Prime-power growth.** Investigate `π(p^{e+1})` versus `π(p^e)` through the action of `Q` on `(ℤ/p^{e+1}ℤ)²` and its reduction map, aiming at the open conjecture `π(p²) ≠ π(p)`.
3. **General Lucas sequences.** Replace `Q` by `(a,b) ↦ (b, Pb − Qa)` for parameters `P, Q` to obtain a uniform period theory for Lucas sequences `U_n`, with the same order-of-a-permutation framing.
4. **Spectral language.** Formalize "the product dynamical system factors into prime-power spectral components" as a statement about the cycle-type/eigenstructure of `Q`, connecting to the characteristic polynomial `x² − x − 1` over `ℤ/p^eℤ`.
5. **Algorithmic certificates.** Develop the §6.2 certificate scheme into a verified fast Pisano-period checker.

---

## Appendix A. Summary of results

| Result | Statement |
|---|---|
| Iterate formula (2.3) | `Qᵏ(a,b) = (a(F_{k+1}−F_k)+bF_k,\ aF_k+bF_{k+1})` |
| Representation (2.4) | `Qᵏ(0,1) = (F_k, F_{k+1})` |
| Existence (3.1) | `π(m) > 0` for `m ≥ 1` |
| Triviality (3.2) | `Qᵏ = 1 ⟺ F_k ≡ 0 ∧ F_{k+1} ≡ 1` |
| Duality (3.3) | `π(m) ∣ k ⟺ F_k ≡ 0 ∧ F_{k+1} ≡ 1` |
| Periodicity (3.4) | `F_{n+π(m)} ≡ F_n` |
| Apparition bound (4.2–4.3) | `m ∣ F_{π(m)}`, hence `z(m) ∣ π(m)` |
| Spectral law (5.1) | `gcd(m,n)=1 ⟹ π(mn) = lcm(π(m), π(n))` |

All results hold for every `m ≥ 1` and depend only on the standard foundational axioms.
