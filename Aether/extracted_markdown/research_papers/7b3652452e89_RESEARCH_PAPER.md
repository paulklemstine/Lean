# Bilinear Pairings as the Algebraic Core of BLS Signatures and Aggregation

## Abstract

Pairing-based cryptography underpins some of the most widely deployed primitives
in modern systems: the Boneh–Lynn–Shacham (BLS) signature scheme, signature
aggregation for blockchain consensus, identity-based encryption, and succinct
zero-knowledge proofs. The canonical instance of the pairing it relies on is the
**Weil pairing** on an elliptic curve, whose construction is a substantial piece
of algebraic geometry. We isolate the *algebraic interface* that the protocol
layer actually consumes — a biadditive map `e : G → G → T` from an additive
abelian group to a multiplicative abelian group — and show that the entire ladder
of cryptographic guarantees follows from this interface alone. Concretely, from
two axioms (additivity in each argument) we derive: the identity laws
`e 0 q = e p 0 = 1`; the negation law `e (-p) q = (e p q)⁻¹`; the
scalar-to-exponent laws `e (n • p) q = (e p q)ⁿ` over both `ℕ` and `ℤ`; joint
bilinearity `e (a • p) (b • q) = (e p q)^(a·b)`; and the sum-to-product law
`e (∑ᵢ fᵢ) q = ∏ᵢ e(fᵢ) q`. We then prove **completeness** of BLS verification
and **completeness of aggregate BLS**, showing that a single summed group element
verifies against the product of per-signer pairings. Finally, we identify
**nondegeneracy** as the single additional hypothesis — used nowhere in
completeness — that makes the pairing *bind*: a nondegenerate pairing separates
points, the algebraic reason a verifier cannot be deceived by a substituted key.
The central methodological claim is a clean separation of concerns: the heavy
analytic construction of the Weil/Tate pairing is required only to *instantiate*
the interface, never to *use* it.

**Keywords:** bilinear pairing, Weil pairing, BLS signatures, signature
aggregation, elliptic-curve cryptography, nondegeneracy, key binding.

---

## 1. Introduction

### 1.1 Motivation

Elliptic-curve cryptography rests on the difficulty of inverting *scalar
multiplication*: given a generator `g` of the point group and a multiple
`X = x • g`, recovering the scalar `x` (the elliptic-curve discrete logarithm
problem) is believed intractable. This asymmetry yields key exchange and digital
signatures. However, the plain group law alone does not provide a *publicly
checkable* relation that ties together multiple secret scalars applied to
different points — the feature that enables, for example, aggregating many
signatures into one.

A **bilinear pairing** supplies exactly this. By mapping pairs of points to a
target group in a way that converts addition to multiplication, a pairing exposes
products of secret scalars `e (a • p) (b • q) = (e p q)^{ab}` while leaving the
scalars themselves hidden. This single capability is the foundation of the BLS
signature scheme (Boneh, Lynn, and Shacham, 2001), its aggregate variant (Boneh,
Gentry, Lynn, and Shacham, 2003), identity-based encryption (Boneh and Franklin,
2001), and a large family of succinct proof systems.

### 1.2 Contribution

We make the following observations precise and prove them within a single
self-contained algebraic framework.

1. **An interface, not a construction.** We define a pairing abstractly as a
   biadditive map and show that *all* protocol-level guarantees of BLS depend
   only on this interface. The analytic construction of the Weil or Tate pairing
   is orthogonal: it certifies that the interface is inhabited on a given curve,
   but contributes nothing to the proofs of completeness, aggregation, or
   binding.

2. **A complete ladder of scalar laws.** From biadditivity alone we derive the
   identity, negation, natural-power, integer-power, joint-bilinearity, and
   sum-to-product laws, each by a short, structurally uniform argument.

3. **Completeness of BLS and aggregation.** We prove that honest BLS signatures
   verify, and that the *sum* of per-signer signatures — a single group element —
   verifies against the *product* of per-signer pairings. Aggregation is revealed
   as the sum-to-product law in disguise.

4. **Isolation of binding.** We show that completeness never uses nondegeneracy,
   and that nondegeneracy is exactly the property needed to make the pairing
   separate points, hence to bind a public key to its holder.

### 1.3 Scope and non-goals

This work develops the *algebraic* layer. It deliberately does not formalize a
game-based, probabilistic proof of existential unforgeability under the
computational Diffie–Hellman (CDH) assumption; that argument requires an
adversary model (random oracles, negligible functions, reductions) outside the
present purely algebraic development. We discuss this frontier in §7.

---

## 2. Preliminaries and Definitions

Throughout, `G` denotes the **source group**, written additively, and `T` the
**target group**, written multiplicatively.

### 2.1 The source and target groups

- For the *monoid-level* results (§3, §4) we require `G` to be an additive
  commutative monoid and `T` a commutative group. The target being a group — not
  merely a monoid — is essential and is used immediately in the identity law
  (Theorem 3.1).
- For the *group-level* results (§5) we strengthen `G` to an additive abelian
  group, so that negation `-p` and integer scalar multiplication `n • p` (for
  `n ∈ ℤ`) are available.

In the canonical instance, `G` is the group `E(K)` of `K`-rational points of an
elliptic curve `E` over a field `K` (or its `r`-torsion subgroup `E[r]`), and `T`
is the group `μ_r ⊂ K̄*` of `r`-th roots of unity, written multiplicatively.

### 2.2 Definition (Bilinear pairing)

A **bilinear pairing** from `G` to `T` is a map `e : G → G → T` satisfying, for
all `a, b, p, q ∈ G`:

- **(add_left)**  `e (a + b) q = e a q · e b q`,
- **(add_right)** `e p (a + b) = e p a · e p b`.

That is, `e` is additive in each argument separately, sending the additive
structure of `G` to the multiplicative structure of `T`. We refer to the pair of
axioms collectively as *biadditivity* or *bilinearity*.

### 2.3 Definition (Nondegeneracy)

A pairing `e` is **nondegenerate** (on the left) if for all `a ∈ G`,

> `(∀ q ∈ G, e a q = 1)  ⟹  a = 0`.

Equivalently, the only point that pairs trivially with every point is the
identity. The Weil pairing on `E[r]` is nondegenerate.

### 2.4 Remark (Why the target must be a group)

The relation `e 0 q = e 0 q · e 0 q` (obtained by setting `a = b = 0`) only forces
`e 0 q = 1` via cancellation, which requires inverses in `T`. This mirrors the
fact that real pairing targets are groups of roots of unity. A monoid target
would not suffice.

---

## 3. The Bilinearity Ladder (monoid source)

We assume `G` is an additive commutative monoid and `T` a commutative group.

### Theorem 3.1 (Identity laws — `map_one_left`, `map_one_right`)

For all `p, q ∈ G`:  `e 0 q = 1`  and  `e p 0 = 1`.

*Proof sketch.* Apply **add_left** with `a = b = 0`: since `0 + 0 = 0`,
`e 0 q = e 0 q · e 0 q`. Writing `x := e 0 q`, we have `x = x · x` in the group
`T`; cancelling one factor of `x` gives `x = 1`. The right identity is the mirror
argument using **add_right**. ∎

### Theorem 3.2 (Natural-power laws — `pairing_nsmul_left`, `pairing_nsmul_right`)

For all `n ∈ ℕ` and `p, q ∈ G`:

> `e (n • p) q = (e p q)ⁿ`   and   `e p (n • q) = (e p q)ⁿ`.

*Proof sketch.* Induction on `n`. Base case `n = 0`: `0 • p = 0`, so by Theorem
3.1 the left side is `e 0 q = 1 = (e p q)⁰`. Inductive step: write
`(k+1) • p = (k • p) + p`; then by **add_left** and the inductive hypothesis,
`e ((k+1) • p) q = e (k • p) q · e p q = (e p q)ᵏ · e p q = (e p q)^{k+1}`. The
right law is symmetric, using **add_right**. ∎

### Theorem 3.3 (Joint bilinearity — `pairing_bilinear_nsmul`)

For all `a, b ∈ ℕ` and `p, q ∈ G`:  `e (a • p) (b • q) = (e p q)^{a·b}`.

*Proof sketch.* Apply Theorem 3.2 in the left slot to get
`e (a • p) (b • q) = (e p (b • q))^a`, then in the right slot
`e p (b • q) = (e p q)^b`, giving `((e p q)^b)^a = (e p q)^{a·b}` by the
power-of-power law. ∎

This is the equation underlying the Diffie–Hellman tuple check: a pairing can
detect the product `a·b` of two independently chosen scalars.

### Theorem 3.4 (Sum-to-product law — `pairing_sum_left`)

Let `ι` be an index type with decidable equality, `s ⊆ ι` a finite set,
`f : ι → G`, and `q ∈ G`. Then

> `e (∑_{i ∈ s} f i) q = ∏_{i ∈ s} e (f i) q`.

*Proof sketch.* Finite-set induction on `s`. Empty case: the empty sum is `0`, so
by Theorem 3.1 the left side is `e 0 q = 1`, equal to the empty product.
Insertion case (`a ∉ s`): the sum splits as `f a + ∑_{i ∈ s} f i`; by **add_left**
and the inductive hypothesis,
`e (f a + ∑ f i) q = e (f a) q · ∏_{i ∈ s} e (f i) q = ∏_{i ∈ insert a s} e (f i) q`. ∎

This law is the structural heart of aggregation (§4.2): it converts a single
pairing of a *sum* of group elements into a *product* of individual pairings.

---

## 4. BLS Signatures

### 4.1 The scheme

Fix a public generator `g ∈ G`.

- **Key generation.** A signer samples a secret key `x ∈ ℕ` (in practice `x ∈ ℤ`
  modulo the group order) and publishes the public key `X := x • g ∈ G`.
- **Signing.** A message `m` is hashed to a group element `H := Hash(m) ∈ G`
  (hash-to-curve). The signature is the single group element `σ := x • H ∈ G`.
- **Verification.** Given `(g, X, H, σ)`, accept iff `e σ g = e H X`.

### Theorem 4.1 (Completeness of BLS — `bls_verify_correct`)

For all `g, H ∈ G` and `x ∈ ℕ`:  `e (x • H) g = e H (x • g)`.

*Proof sketch.* By Theorem 3.2 applied on the left, `e (x • H) g = (e H g)^x`; by
Theorem 3.2 applied on the right, `e H (x • g) = (e H g)^x`. The two sides are
equal. ∎

Interpretation: substituting `σ = x • H` and `X = x • g`, an honest signature
satisfies the verification equation `e σ g = e H X`, and the verifier learns
nothing about `x` — the scalar merely migrates between the two pairing slots.

### 4.2 Aggregate signatures

Let signers be indexed by a finite set `s ⊆ ι`. Signer `i` holds secret key
`sk i ∈ ℕ`, signs a message hashing to `Hm i ∈ G`, and produces
`σ_i = (sk i) • (Hm i)`. The **aggregate signature** is the single group element

> `σ_agg := ∑_{i ∈ s} (sk i) • (Hm i)`.

### Theorem 4.2 (Completeness of aggregate BLS — `bls_aggregate_correct`)

With public keys `X_i = (sk i) • g`,

> `e (∑_{i ∈ s} (sk i) • (Hm i)) g = ∏_{i ∈ s} e (Hm i) ((sk i) • g)`.

*Proof sketch.* Apply the sum-to-product law (Theorem 3.4) to the left side with
`f i = (sk i) • (Hm i)`:
`e (σ_agg) g = ∏_{i ∈ s} e ((sk i) • (Hm i)) g`. Each factor is then a single BLS
completeness instance (Theorem 4.1): `e ((sk i) • (Hm i)) g = e (Hm i) ((sk i) • g)`.
Substituting termwise (a congruence of finite products) yields the claim. ∎

**Consequence (short aggregate signatures).** The aggregate `σ_agg` is one group
element — the size of a single signature — yet it verifies against the product of
all signers' verification equations. For `n` signers this replaces `n` separate
signatures and `n` independent checks by one group element and one product of
pairings, the property that makes BLS aggregation practical at blockchain scale.

---

## 5. Integer Scalars and Nondegeneracy (group source)

We now take `G` to be an additive abelian group, so that `-p` and integer scalar
multiplication are available.

### Theorem 5.1 (Negation law — `map_neg_left`)

For all `p, q ∈ G`:  `e (-p) q = (e p q)⁻¹`.

*Proof sketch.* By **add_left**, `e (p + (-p)) q = e p q · e (-p) q`. The left side
is `e 0 q = 1` (Theorem 3.1, since `p + (-p) = 0`). Hence
`e p q · e (-p) q = 1`, so `e (-p) q` is the inverse of `e p q`. ∎

### Theorem 5.2 (Integer-power law — `pairing_zsmul_left`)

For all `n ∈ ℤ` and `p, q ∈ G`:  `e (n • p) q = (e p q)ⁿ`.

*Proof sketch.* Write `n = m` or `n = -m` for some `m ∈ ℕ`. If `n = m`, the claim
reduces to Theorem 3.2 after identifying integer and natural scalar
multiplication. If `n = -m`, then `n • p = -(m • p)`; by Theorem 5.1,
`e (-(m • p)) q = (e (m • p) q)⁻¹ = ((e p q)^m)⁻¹ = (e p q)^{-m}`, matching the
target exponent. ∎

This extends the scalar-to-exponent law to the full integer-graded action present
on a genuine elliptic-curve point group, where secret keys naturally live in
`ℤ / (order)`.

### Theorem 5.3 (Left separation under nondegeneracy — `pairing_left_injective`)

Suppose `e` is nondegenerate (Definition 2.3). If `p₁, p₂ ∈ G` satisfy
`e p₁ q = e p₂ q` for all `q ∈ G`, then `p₁ = p₂`.

*Proof sketch.* Consider the difference `p₁ - p₂`. For every `q`,
`e (p₁ - p₂) q = e (p₁ + (-p₂)) q = e p₁ q · e (-p₂) q = e p₁ q · (e p₂ q)⁻¹`,
using **add_left** and Theorem 5.1. By hypothesis `e p₁ q = e p₂ q`, so this
product is `1`. Thus `p₁ - p₂` pairs trivially with every `q`; nondegeneracy
forces `p₁ - p₂ = 0`, i.e. `p₁ = p₂`. ∎

**Interpretation (binding).** Theorem 5.3 is the algebraic reason BLS verification
binds a key. Two distinct points cannot induce identical verification behavior;
hence a verifier presented with a substituted public key will observe a
distinguishable verification equation. Crucially, *nondegeneracy is used nowhere
in §3–§4*: completeness is a consequence of biadditivity alone, while binding is
the precise additional contribution of nondegeneracy. This clean factorization —
biadditivity ⇒ completeness, nondegeneracy ⇒ soundness — is one of the main
conceptual outputs of the development.

---

## 6. Algorithms

The proofs above are constructive and translate directly into verification
algorithms. We summarize the two principal ones.

### Algorithm 6.1 (BLS verification)

```
Input:  generator g, public key X, message hash H, signature σ
Output: accept / reject
1. compute L ← e(σ, g)        # one pairing evaluation
2. compute R ← e(H, X)        # one pairing evaluation
3. if L == R then accept else reject
```

Correctness is Theorem 4.1: for an honest `σ = x • H` and `X = x • g`, both `L`
and `R` equal `(e(H,g))^x`.

### Algorithm 6.2 (Aggregate BLS verification)

```
Input:  generator g, public keys X_1..X_n, message hashes H_1..H_n,
        aggregate signature σ_agg = Σ σ_i
Output: accept / reject
1. L ← e(σ_agg, g)                       # one pairing evaluation
2. R ← Π_{i=1..n} e(H_i, X_i)            # n pairings, one product in T
3. if L == R then accept else reject
```

Correctness is Theorem 4.2. The aggregate signature occupies the space of a
single group element regardless of `n`.

---

## 7. Discussion and Future Work

### 7.1 Separation of concerns

The development substantiates a precise version of a folklore principle: the
protocol layer of pairing-based cryptography is a *consumer of an interface*. A
structure carrying exactly the two biadditivity axioms suffices to derive the
entire scalar-law ladder, completeness, and aggregation; nondegeneracy is a
single, separable hypothesis responsible exclusively for binding. Any
construction — Weil pairing, Tate pairing, optimal Ate pairing on a pairing-
friendly curve — that inhabits this interface yields all the same guarantees
without re-proof.

### 7.2 Aggregation as a recurring pattern

Theorem 4.2 exposes aggregation as the sum-to-product law (Theorem 3.4) composed
with completeness. The same finite-set induction skeleton (`empty ↦` identity
law, `insert ↦` additivity) that proves the sum-to-product law will prove
multi-signature and threshold variants; the pattern is reusable verbatim.

### 7.3 Toward unforgeability under CDH

The principal omission is a game-based proof of existential unforgeability under
chosen-message attack (EUF-CMA) reducing to the computational Diffie–Hellman
assumption in the pairing group. This requires modeling a probabilistic
adversary with access to a signing oracle and a random oracle for hash-to-curve,
defining negligible advantage, and exhibiting a reduction that turns a forger
into a CDH solver. Such a model is orthogonal to — and would build atop — the
algebraic interface developed here.

### 7.4 Further directions

- **Type-III pairings.** Generalize from the symmetric setting `e : G × G → T` to
  the asymmetric `e : G₁ × G₂ → T` used in deployed systems, where `G₁ ≠ G₂` and
  no efficient isomorphism is assumed.
- **Identity-based encryption.** Build the Boneh–Franklin IBE on the same
  interface; its correctness is again a bilinearity computation.
- **Batch and threshold verification.** Formalize randomized batch verification
  and `t`-of-`n` threshold signatures, both expressible through the sum-to-product
  law.
- **Nondegeneracy on both slots and perfect pairings.** Strengthen Theorem 5.3 to
  two-sided separation and connect to the perfectness of the Weil pairing on
  `E[r] × E[r]`.

---

## 8. Conclusion

We have shown that the cryptographically essential content of the Weil pairing,
as consumed by BLS signatures and their aggregate variant, is captured by a
two-axiom algebraic interface. From biadditivity alone follow the identity,
negation, natural- and integer-power, joint-bilinearity, and sum-to-product laws,
and from these the completeness of BLS verification and of aggregate
verification — the latter exhibiting short aggregate signatures as a direct
corollary of the sum-to-product law. Nondegeneracy enters as a single, isolable
hypothesis that endows the pairing with point separation and thereby with key
binding. The heavy analytic construction of the pairing is needed only to
instantiate the interface, never to reason about the protocols built upon it — a
separation of concerns that makes the resulting theory both robust and reusable.

---

## References

- D. Boneh, B. Lynn, and H. Shacham. *Short signatures from the Weil pairing.*
  ASIACRYPT 2001.
- D. Boneh, C. Gentry, B. Lynn, and H. Shacham. *Aggregate and verifiably
  encrypted signatures from bilinear maps.* EUROCRYPT 2003.
- D. Boneh and M. Franklin. *Identity-based encryption from the Weil pairing.*
  CRYPTO 2001.
- J. H. Silverman. *The Arithmetic of Elliptic Curves.* Springer GTM 106
  (for the construction and properties of the Weil pairing).
