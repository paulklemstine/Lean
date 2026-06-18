# Certified Additive and Combinatorial Designs: A Formal Framework for Goldbach Decompositions and the Paley–Hadamard Correspondence

## Abstract

We present a formally verified framework unifying two classical existence
problems under a single methodological banner — the *certificate of existence*.
The first component develops the theory of **additive prime decompositions**:
decidable predicates for two- and three-prime representability, a fuel-bounded
verified search algorithm for Goldbach pairs, a soundness-carrying certificate
structure, and a graph-theoretic covering reformulation of the binary Goldbach
conjecture. The second component formalizes the algebraic heart of the **Paley I
construction** for Hadamard matrices, establishing a bijective correspondence
between *skew conference matrices* of order `n` and *skew-Hadamard matrices* of
order `n`. The central result is that the existence of a skew conference matrix
of order `n` implies that `n` is a Hadamard order — yielding orders (12, 20, 24,
…) provably unreachable by the Sylvester doubling construction. We give the
definitions, main theorems with proof sketches, the underlying algorithms, and a
discussion of applications and open frontiers, including the symmetric (Paley II)
doubling conjecture. All results are machine-checked.

**Keywords:** Goldbach conjecture, additive number theory, prime decomposition,
Hadamard matrices, conference matrices, Paley construction, quadratic residues,
formal verification, certified computation.

---

## 1. Introduction

Existence problems occupy a peculiar place in mathematics. The question "does an
object of type `X` and size `n` exist?" can be either utterly intractable
(Goldbach's conjecture, open since 1742) or richly constructive (Paley's 1933
construction of Hadamard matrices). This paper studies one representative of each
extreme and argues that a common discipline — making existence *certified*,
*decidable*, and *modular* — serves both.

The two case studies are:

1. **The additive Goldbach problem.** Every even integer greater than 2 is
   conjecturally a sum of two primes. We do not resolve the conjecture; rather we
   build the formal infrastructure that renders every *finite* instance
   machine-auditable and recasts the global problem in two illuminating ways
   (weak/ternary representability and a covering graph).

2. **The Paley–Hadamard correspondence.** Hadamard matrices of order `n` exist
   only for `n ∈ {1, 2}` or `4 | n`; whether they exist for *every* multiple of
   4 (the Hadamard conjecture) is open. Paley's construction settles infinitely
   many orders. We formalize its algebraic core: a bijection between skew
   conference matrices and skew-Hadamard matrices.

The contributions are: (i) a self-contained, decidable formalization of additive
prime representability with a verified search and certificate abstraction; (ii) a
graph-covering reformulation of binary Goldbach; (iii) a complete, machine-checked
proof of the skew conference ↔ skew-Hadamard bijection and the resulting Hadamard
order corollary; and (iv) a precise statement of the symmetric (Paley II) doubling
frontier as a conjecture.

---

## 2. Part I — Additive prime decomposition

### 2.1 Definitions

We work over the natural numbers `ℕ` and write `Prime` for the standard primality
predicate.

**Definition 2.1 (Two-prime representability).**
A natural number `n` is *two-prime representable* if
```
TwoPrimeRepresentable n  :≡  ∃ p q, Prime p ∧ Prime q ∧ p + q = n.
```

**Definition 2.2 (Three-prime representability).**
```
ThreePrimeRepresentable n  :≡  ∃ p q r, Prime p ∧ Prime q ∧ Prime r ∧ p + q + r = n.
```

**Definition 2.3 (Binary Goldbach up to a bound).**
```
GoldbachUpTo N  :≡  ∀ n, 4 ≤ n → n ≤ N → Even n → TwoPrimeRepresentable n.
```

**Definition 2.4 (General k-fold representation).** For a set `s ⊆ ℕ`,
```
RepresentsAsSumFrom s k n  :≡  ∃ f : Fin k → ℕ, (∀ i, f i ∈ s) ∧ (∑ i, f i) = n.
```
Two- and three-prime representability are the instances `s = Primes`, `k ∈ {2,3}`.

### 2.2 Decidability

**Theorem 2.5 (Decidability of two-prime representability).**
For every `n`, the predicate `TwoPrimeRepresentable n` is decidable.

*Proof sketch.* `TwoPrimeRepresentable n` is logically equivalent to the bounded
statement
```
∃ p ∈ range (n+1), ∃ q ∈ range (n+1), Prime p ∧ Prime q ∧ p + q = n,
```
because any witness pair `(p, q)` with `p + q = n` satisfies `p, q ≤ n`. The
bounded form is a decidable predicate over finite ranges (`Finset.range`), and
`decidable_of_iff` transports decidability across the equivalence. The forward
direction of the equivalence forgets the range membership; the reverse supplies
`p, q ≤ n` from `p + q = n` via `omega`. ∎

Decidability is the linchpin: it means every finite Goldbach claim
(`GoldbachUpTo N` for concrete `N`) is settled by computation rather than by
trust.

### 2.3 A verified search algorithm

We give an explicit, terminating search for Goldbach pairs.

**Algorithm 2.6 (`findGoldbachPair`).** Defined via a fuel-bounded auxiliary:
```
findGoldbachPairAux n fuel k :
  if fuel = 0                       then none
  else if k > n                     then none
  else if Prime k ∧ Prime (n − k)  then some (k, n − k)
  else                                   findGoldbachPairAux n (fuel−1) (k+1)

findGoldbachPair n := findGoldbachPairAux n n 2.
```
The fuel parameter (initialized to `n`) guarantees structural termination; the
guard `k > n` guarantees the scan stays in range. By construction, any returned
pair `(p, q)` satisfies `Prime p`, `Prime q`, and `p + q = n`, so the output is
*self-certifying*: the witness pair is itself the proof.

The auxiliary `leastGoldbachPrime n` returns the first prime component found (or
`none`), i.e. the least prime `p` with `n − p` prime.

### 2.4 The certificate abstraction

**Definition 2.7 (`AdditiveBasisCertificate`).** A certificate is a structure
bundling
- a finite `carrier : Finset ℕ` of primes,
- a witness map `witness : ℕ → Option (ℕ × ℕ)`,

together with three soundness fields:
```
sound_prime_left  : ∀ n p q, witness n = some (p, q) → Prime p
sound_prime_right : ∀ n p q, witness n = some (p, q) → Prime q
sound_sum         : ∀ n p q, witness n = some (p, q) → p + q = n.
```

The design intent is **modular extension of verified ranges**. A certificate is a
first-class object that can be generated independently and verified independently;
soundness travels with the data, so extending a verified range from `N` to `N'`
amounts to supplying a larger certificate, with no need to revisit prior cases.

### 2.5 Graph-theoretic covering reformulation

**Definition 2.8 (Prime sets and pairs).**
```
primesBelow N      := (range (N+1)).filter Prime
goldbachPairsUpTo N := (primesBelow N ×ˢ primesBelow N).filter (λ (p,q). p + q ≤ N)
CoveredEvens N     := { n | ∃ p q, (p, q) ∈ goldbachPairsUpTo N ∧ p + q = n }.
```

Interpret `primesBelow N` as vertices and `goldbachPairsUpTo N` as (ordered)
edges weighted by their sum. Binary Goldbach up to `N` is then exactly the
statement that `CoveredEvens N` contains every even integer in `[4, N]`:
```
GoldbachUpTo N  ⟺  {even n : 4 ≤ n ≤ N} ⊆ CoveredEvens N.
```
This recasts an additive number-theoretic question as a covering question on a
finite, explicitly computable graph — a reformulation that exposes the problem to
combinatorial and algorithmic tooling.

### 2.6 Status and context

Binary Goldbach remains open; the *ternary* Goldbach conjecture (every odd
`n > 5` is a sum of three primes) was proved by Helfgott (2013). By recording
`ThreePrimeRepresentable` alongside `TwoPrimeRepresentable`, the framework keeps
the solved and unsolved siblings in one formal home, and the verified search +
certificate machinery makes all *finite* binary claims auditable to the last
addition.

---

## 3. Part II — The Paley–Hadamard correspondence

### 3.1 Definitions

All matrices are over `ℤ`, indexed by `Fin n`. We write `I` for the identity, `M·N`
for matrix product, `Mᵀ` for transpose, and `c • M` for scalar multiplication.

**Definition 3.1 (Hadamard matrix).**
`H : Matrix (Fin n) (Fin n) ℤ` is *Hadamard* if
```
IsHadamard H  :≡  (∀ i j, H i j = 1 ∨ H i j = −1)  ∧  H · Hᵀ = n • I.
```
An order `n` is a *Hadamard order* (`HadamardOrder n`) if some Hadamard `H` of
that order exists.

**Definition 3.2 (Skew conference matrix).**
```
IsSkewConference C  :≡  (∀ i, C i i = 0)
                     ∧ (∀ i j, i ≠ j → C i j = 1 ∨ C i j = −1)
                     ∧ Cᵀ = −C
                     ∧ C · Cᵀ = (n − 1) • I.
```
i.e. zero diagonal, ±1 off-diagonal, anti-symmetric, and satisfying the
*conference identity*.

**Definition 3.3 (Skew-Hadamard matrix).**
```
IsSkewHadamard H  :≡  IsHadamard H  ∧  H + Hᵀ = 2 • I.
```
The extra condition `H + Hᵀ = 2•I` says the diagonal is all 1's and the
off-diagonal part is anti-symmetric.

### 3.2 The algebraic core

**Theorem 3.4 (Square of a skew conference matrix).**
If `IsSkewConference C` (order `n`), then
```
C · C = (1 − n) • I.
```

*Proof sketch.* From anti-symmetry `Cᵀ = −C`, substitute into the conference
identity: `C · Cᵀ = C · (−C) = −(C · C)`. But `C · Cᵀ = (n − 1)•I`, so
`−(C · C) = (n − 1)•I`. Negating both sides gives `C · C = −(n − 1)•I = (1 − n)•I`.
Stating the conclusion with the coefficient `(1 − n)` rather than `−(n − 1)`
avoids friction with scalar-negation normal forms. ∎

This single identity drives the entire construction.

### 3.3 Forward construction (Paley I)

**Theorem 3.5 (Skew conference ⟹ skew-Hadamard).**
If `IsSkewConference C` (order `n`), then `I + C` is skew-Hadamard:
```
IsSkewHadamard (I + C).
```

*Proof sketch.* Two obligations.

*(±1 entries.)* On the diagonal, `(I + C) i i = 1 + 0 = 1`. Off the diagonal,
`(I + C) i j = C i j ∈ {1, −1}`. Hence all entries are ±1.

*(Hadamard identity.)* Expand using `(I + C)ᵀ = I + Cᵀ = I − C` (anti-symmetry):
```
(I + C)(I + C)ᵀ = (I + C)(I − C) = I − C + C − C·C = I − C·C.
```
By Theorem 3.4, `C·C = (1 − n)•I`, so
```
I − C·C = I − (1 − n)•I = I + (n − 1)•I = n • I.
```
The anti-symmetric cross terms `−C + C` cancel — the crux. Finally
`(I + C) + (I + C)ᵀ = (I + C) + (I − C) = 2•I`, giving the skew condition. ∎

**Corollary 3.6 (Hadamard from skew conference).**
`IsSkewConference C ⟹ IsHadamard (I + C)`; forgetting the skew refinement.

**Corollary 3.7 (Existence of Hadamard orders).**
If a skew conference matrix of order `n` exists, then `n` is a Hadamard order:
```
(∃ C, IsSkewConference C) → HadamardOrder n.
```
This is the bridge to non-power-of-two Hadamard orders.

### 3.4 The converse and the bijection

**Theorem 3.8 (Skew-Hadamard ⟹ skew conference).**
If `IsSkewHadamard H` (order `n`), then `H − I` is a skew conference matrix:
```
IsSkewConference (H − I).
```

*Proof sketch.* Let `C := H − I`.
- *Zero diagonal.* Reading `H + Hᵀ = 2•I` on the diagonal gives `2·H i i = 2`,
  so `H i i = 1` and `C i i = 0`.
- *±1 off-diagonal.* For `i ≠ j`, `C i j = H i j ∈ {1, −1}`.
- *Anti-symmetry.* `Cᵀ = Hᵀ − I`; from `H + Hᵀ = 2•I` we get `Hᵀ = 2•I − H`, so
  `Cᵀ = I − H = −(H − I) = −C`.
- *Conference identity.* Using `H·Hᵀ = n•I` and `H + Hᵀ = 2•I`:
  ```
  C·Cᵀ = (H − I)(Hᵀ − I) = H·Hᵀ − (H + Hᵀ) + I = n•I − 2•I + I = (n − 1)•I.
  ```
  ∎

**Theorem 3.9 (Bijective correspondence).**
Theorems 3.5 and 3.8 establish that `C ↦ I + C` and `H ↦ H − I` are mutually
inverse bijections between skew conference matrices and skew-Hadamard matrices of
order `n`. The two classes are equivalent and the translation is information-
preserving.

### 3.5 Instantiation via quadratic residues

For a prime power `q ≡ 3 (mod 4)`, the quadratic-residue (Jacobsthal) character
`χ` over `GF(q)` — with `χ(0) = 0`, `χ(a) = 1` if `a` is a nonzero square,
`χ(a) = −1` otherwise — satisfies `χ(−1) = −1`. Bordering the Jacobsthal matrix
`Q i j = χ(i − j)` with a leading row/column produces a skew conference matrix of
order `n = q + 1`. Combined with Corollary 3.7, this yields Hadamard matrices for
all such `n`:
```
q = 3, 7, 11, 19, 23, …   ⟹   n = 4, 8, 12, 20, 24, ….
```
The companion implementation constructs these explicitly and verifies every
hypothesis (Section 5). Orders **12 and 20** appear — orders the Sylvester
doubling construction (which produces only powers of two) can never reach.

### 3.6 The symmetric frontier (Paley II) — open

For primes `q ≡ 1 (mod 4)` one obtains a *symmetric* conference matrix
(`Cᵀ = C`), and the `I + C` trick fails because `I + C` is no longer Hadamard.

**Definition 3.10 (Symmetric conference matrix).**
```
IsSymmetricConference C :≡ (∀ i, C i i = 0) ∧ (∀ i j, i ≠ j → C i j = ±1)
                        ∧ Cᵀ = C ∧ C·Cᵀ = (n − 1)•I.
```

**Conjecture 3.11 (Paley II doubling).**
A symmetric conference matrix of order `n` yields a Hadamard matrix of order
`2n`:
```
(∃ C, IsSymmetricConference C) → HadamardOrder (2 n).
```
The expected construction uses the block matrix
```
[ C + I    C − I ]
[ C − I  −(C + I) ]
```
over `Fin n ⊕ Fin n`. This is recorded as an explicit open goal and is the first
item in the future-directions program.

---

## 4. Algorithms

### 4.1 Verified Goldbach search (Algorithm 2.6)

The fuel-bounded scan runs in `O(n · primality(n))` time, where `primality(n)`
is `O(√n)` by trial division; overall `O(n^{1.5})` per query. It is total and
self-certifying. Crucially, decidability (Theorem 2.5) means a *decision
procedure* for `GoldbachUpTo N` is obtained by iterating the search over even
`n ∈ [4, N]`.

### 4.2 Certificate verification

Given a candidate pair `(p, q)` for `n`, verification is `O(√n)`: confirm `Prime
p`, `Prime q`, and `p + q = n`. Verification is independent of how the pair was
produced — the separation of *generation* from *checking* is what makes the
certificate abstraction (Definition 2.7) valuable.

### 4.3 Paley construction and verification

Building a skew conference matrix of order `q + 1` costs `O(q^2)` character
evaluations (each `O(q)` after an `O(q)` precomputation of the residue set), i.e.
`O(q^2)`. Verifying the Hadamard property of `I + C` is an `O(q^3)` matrix
multiplication. The pipeline — build `C`, form `I + C`, verify
`(I+C)(I+C)ᵀ = nI`, then confirm `H − I = C` — exercises Theorems 3.4–3.9
end to end.

---

## 5. Numerical validation

The companion `demo.py` confirms, with concrete arithmetic:

- Goldbach pairs for `n ∈ {4, 10, 28, 100, 1000}` with verified certificates
  (e.g. `1000 = 3 + 997`);
- `GoldbachUpTo 10000` holds (no even `n` in `[4, 10000]` fails);
- `leastGoldbachPrime(100) = 3`; weak decomposition `27 = 2 + 2 + 23`;
- the prime-pair covering graph covers every even number in `[4, 50]`;
- for `q ∈ {3, 7, 11, 19, 23}` (orders `4, 8, 12, 20, 24`): the constructed `C`
  is skew conference, `C·C = (1−n)I`, `I + C` is skew-Hadamard (hence Hadamard),
  and `H − I = C` recovers the original — directly witnessing the bijection of
  Theorem 3.9 at non-power-of-two orders 12 and 20.

---

## 6. Applications

**Hadamard matrices** underpin: error-correcting codes (the Reed–Muller / Hadamard
codes used in deep-space telemetry, e.g. Mariner/Voyager), spreading sequences in
CDMA communications, optimal weighing and factorial designs in statistics,
quantum information (mutually unbiased bases, fast transforms), and compressed
sensing. The Paley family supplies orders unreachable by Sylvester doubling,
widening the menu of usable code lengths and design sizes.

**Certified additive search** is a template for *trust-minimized* number-theoretic
computation: the certificate pattern (self-certifying witnesses + independent
verification) is exactly the discipline used in computer-assisted proofs and in
verified computational mathematics generally.

---

## 7. Discussion

The two parts illustrate a spectrum of what formalization buys you. For an open
problem (Goldbach), it buys *auditable finiteness*: decidable predicates, a total
verified search, soundness-carrying certificates, and reformulations that move the
problem into new territory (covering graphs). For a constructive theory (Paley),
it buys a *complete and bidirectional* account: not merely "Hadamard matrices of
these orders exist," but a structural bijection explaining *why*, with the
construction and its inverse both certified.

A recurring design lesson is the value of stating identities in their friendliest
normal form (the `(1 − n)` coefficient in Theorem 3.4; bounded-existential
restatements for decidability). Such choices materially ease mechanical proof.

---

## 8. Future directions

1. **Paley II doubling (Conjecture 3.11).** Formalize the block construction over
   `Fin n ⊕ Fin n` turning a symmetric conference matrix of order `n` into a
   Hadamard matrix of order `2n`, closing the symmetric frontier.
2. **Jacobsthal matrix formalization.** Internalize the quadratic-residue
   construction of skew conference matrices so that `HadamardOrder (q + 1)` for
   primes `q ≡ 3 (mod 4)` becomes a theorem rather than an instantiated
   hypothesis.
3. **Certificate-driven verified Goldbach ranges.** Generate and machine-verify
   `GoldbachUpTo N` for large `N` via the certificate abstraction, with reusable,
   composable certificates.
4. **Covering-graph methods.** Exploit the graph reformulation (Section 2.5) to
   import combinatorial covering and matching techniques into additive
   prime-representation questions.

(The accompanying package also bundles a complementary research program on
**Collatz reachability and proof-theoretic barriers**, included verbatim in the
distribution's future-directions record.)

---

## 9. Conclusion

We have formalized two pillars of additive and combinatorial design theory under
the unifying discipline of certified existence. On the additive side: a decidable,
self-certifying, modular framework for Goldbach decompositions with a
graph-covering reformulation. On the combinatorial side: a complete bijective
account of the Paley I correspondence between skew conference and skew-Hadamard
matrices, delivering Hadamard orders beyond the powers of two. Together they
demonstrate that whether a problem is open or constructive, the right unit of
mathematical certainty is the certificate — a witness one can check.
