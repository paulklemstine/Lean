# Perfect Secrecy of the Group One-Time Pad: A Formal Account over Arbitrary Finite Groups

## Abstract

We give a self-contained development of Shannon perfect secrecy for the
one-time pad (OTP) in its most natural algebraic setting: an arbitrary finite
group `G`, with encryption defined by group multiplication `c = k · m`. We prove
three results that together constitute a complete proof of perfect secrecy.
First, a *unique-key* lemma: for every message `m` and ciphertext `c` there is a
unique key `k` with `k · m = c`, namely `k = c · m⁻¹`. Second, a *combinatorial*
restatement: the number of keys mapping a fixed message to a fixed ciphertext is
exactly one, independent of the message. Third, the *information-theoretic* main
theorem: when the key is uniform on `G` and independent of the message, the
posterior probability of the message given the ciphertext equals the prior,
`P(M = m | C = c) = P(M = m)`. The proof factors through the observation that the
ciphertext marginal is uniform, `P(C = c) = 1/|G|`, regardless of the message
distribution. The development requires no commutativity and works for any finite
group, recovering the classical XOR-based OTP as the special case `G = (ℤ/2)^n`.
All results have been formally verified in the Lean 4 proof assistant on top of
Mathlib's measure-theoretic probability library (`PMF`). We close with
algorithms, numerical illustrations, and a discussion of optimality (Shannon's
key-length bound) and the failure modes that break secrecy in practice.

**Keywords.** One-time pad, perfect secrecy, Shannon, information-theoretic
security, finite groups, conditional probability, uniform distribution,
formal verification.

---

## 1. Introduction

Modern public-key cryptography is *computationally* secure: its guarantees are
conditional on the presumed intractability of problems such as integer
factorization or the learning-with-errors problem, and on bounds on the
adversary's running time. By contrast, **information-theoretic** (or
*unconditional*) security makes no assumption about the adversary's
computational power. The paradigmatic example is the one-time pad, whose perfect
secrecy was established by Shannon [Shannon, 1949].

The usual textbook treatment fixes the message space to be bit strings of a
fixed length and the combining operation to be bitwise XOR. This obscures the
fact that XOR is used *only* as the group operation of `(ℤ/2)^n`, and that the
entire argument depends on a single structural property: in a finite group,
multiplication by a fixed element is a bijection. We therefore present the OTP
over an arbitrary finite group `G`, not necessarily abelian, with encryption
`Enc_k(m) = k · m` and decryption `Dec_k(c) = k⁻¹ · c`.

The contribution of this paper is a clean, modular, and fully formalized proof
of perfect secrecy in this generality. The argument is organized into three
layers:

1. **Algebraic layer** (Section 3): existence and uniqueness of the connecting
   key.
2. **Combinatorial layer** (Section 4): the key-count is identically one.
3. **Probabilistic layer** (Section 5): Bayesian perfect secrecy, via uniformity
   of the ciphertext marginal.

Each layer feeds the next, and each is independently meaningful. All three have
been verified in Lean 4 / Mathlib; we describe the formalization choices in
Section 6.

---

## 2. Preliminaries and definitions

Throughout, `G` denotes a finite group, written multiplicatively, with identity
`e`, and `|G| = card G` its order. We assume `G` is inhabited (it is, since it
contains `e`), so `|G| ≥ 1`.

**Definition 2.1 (Encryption and decryption).**
For a key `k ∈ G`, define
- `Enc_k : G → G`, `Enc_k(m) = k · m` (encryption of message `m`);
- `Dec_k : G → G`, `Dec_k(c) = k⁻¹ · c` (decryption of ciphertext `c`).

**Proposition 2.2 (Correctness).** For all `k, m ∈ G`, `Dec_k(Enc_k(m)) = m`.

*Proof.* `Dec_k(Enc_k(m)) = k⁻¹ · (k · m) = (k⁻¹ · k) · m = e · m = m.` ∎

**Definition 2.3 (Probability model).** Let `messageDist` be an arbitrary
probability mass function (PMF) on `G`, the *prior* message distribution. Let
`K` be uniform on `G`, i.e. `P(K = k) = 1/|G|` for all `k`, drawn independently
of the message `M ~ messageDist`. The ciphertext is the random variable
`C = K · M`. The *joint distribution* of `(M, C)` is the PMF on `G × G`
given by
```
joint = messageDist.bind (λ m'. (Uniform G).map (λ k. (m', k · m'))),
```
that is, `joint(x, c) = Σ_k P(M = x) · P(K = k) · 1[k · x = c]`.

We write `P(M = m | C = c) = joint(m, c) / P(C = c)`, where the ciphertext
marginal is `P(C = c) = Σ_x joint(x, c)`. (When `P(C = c) > 0` this is the
elementary conditional probability; in our setting `P(C = c) = 1/|G| > 0`
always.)

**Definition 2.4 (Perfect secrecy).** A scheme has *perfect secrecy* for a given
key distribution if for every prior `messageDist`, every message `m`, and every
ciphertext `c`,
```
P(M = m | C = c) = P(M = m).
```
Equivalently, `M` and `C` are independent random variables.

We work in the extended non-negative reals `ℝ≥0∞` (Mathlib's `ENNReal`), the
natural codomain for PMF values, which makes the `tsum` (unconditional sum)
manipulations below total and avoids subtraction.

---

## 3. The algebraic layer: a unique connecting key

**Theorem 3.1 (Unique key).** For every `m, c ∈ G` there exists a unique `k ∈ G`
with `k · m = c`; explicitly, `k = c · m⁻¹`.

*Proof.* *Existence.* With `k = c · m⁻¹`,
```
(c · m⁻¹) · m = c · (m⁻¹ · m) = c · e = c.
```
*Uniqueness.* If `k · m = c`, then right-multiplying by `m⁻¹`,
```
k = k · e = k · (m · m⁻¹) = (k · m) · m⁻¹ = c · m⁻¹.
```
Hence any solution equals `c · m⁻¹`. ∎

This is the only place the group axioms are used essentially, and it is exactly
the statement that left-translation `L_m : k ↦ k · m` (with `m` fixed) is a
bijection of `G`. In Lean this is `otp_unique_key`, an `∃!` statement whose
witness is `c * m⁻¹` and whose uniqueness clause is the right-multiplication
calculation above.

**Remark 3.2.** No commutativity is used. The same proof handles non-abelian
`G`; one simply must be careful that encryption multiplies the key on a fixed
side (here, the left: `c = k · m`). Decryption then divides on the same side.

---

## 4. The combinatorial layer: the key-count is one

**Theorem 4.1 (Key count).** For every `m, c ∈ G`,
```
#{ k ∈ G : k · m = c } = 1.
```

*Proof.* By Theorem 3.1 the predicate `k · m = c` is satisfied by a unique
element `k₀ = c · m⁻¹`. Hence the filtered finite set `{k ∈ G : k · m = c}`
equals the singleton `{k₀}`, which has cardinality one. ∎

In Lean this is `otp_key_cardinality`, proved by extracting the unique witness
from `otp_unique_key`, rewriting via `Finset.card_eq_one`, and showing the
filtered `Finset.univ` equals `{k₀}` by extensionality.

The decisive feature is that the count `1` is **independent of `m` and `c`**.
This message-independence is the combinatorial shadow of perfect secrecy and the
hinge of the probabilistic argument: it is what makes each message equally
consistent with each observed ciphertext.

**Corollary 4.2 (Per-message ciphertext uniformity).** For a fixed message `m`,
as the key ranges uniformly over `G`, the ciphertext `Enc_K(m) = K · m` is
uniformly distributed on `G`.

*Proof.* `Enc_·(m)` is a bijection `G → G` (Theorem 3.1, varying `c`), and the
pushforward of the uniform distribution along a bijection of a finite set is
uniform. ∎

---

## 5. The probabilistic layer: perfect secrecy

We now prove the main theorem. The strategy is:

(i) compute the joint PMF pointwise, `joint(x, c) = messageDist(x) · |G|⁻¹`;
(ii) sum over `x` to get the ciphertext marginal, `P(C = c) = |G|⁻¹`;
(iii) divide to obtain the posterior, which equals the prior.

**Lemma 5.1 (Pointwise joint).** For all `x, c ∈ G`,
```
joint(x, c) = messageDist(x) · |G|⁻¹.
```

*Proof sketch.* Expand the inner pushforward. For fixed `a`,
```
((Uniform G).map (λ k. (a, k · a)))(x, c)
   = Σ_{k : k·a = c, a = x} |G|⁻¹.
```
If `x ≠ a` the indicator on the first coordinate kills every term and the value
is `0`. If `x = a`, the condition `k · x = c` has the unique solution
`k = c · x⁻¹` (Theorem 3.1), so exactly one term survives and the value is
`|G|⁻¹`. Thus the inner map equals `1[x = a] · |G|⁻¹`. Now expand the outer
`bind`:
```
joint(x, c) = Σ_a messageDist(a) · 1[x = a] · |G|⁻¹
            = messageDist(x) · |G|⁻¹,
```
the single surviving term being `a = x`. ∎

In Lean, Lemma 5.1 is the `hpt` step. The inner computation uses
`PMF.map_apply`, `tsum_eq_single (c * x⁻¹)`, and `PMF.uniformOfFintype_apply`;
the outer one uses `PMF.bind_apply` and `tsum_eq_single x`.

**Lemma 5.2 (Uniform ciphertext marginal).** For all `c ∈ G`,
```
P(C = c) = Σ_x joint(x, c) = |G|⁻¹.
```

*Proof.* Using Lemma 5.1 and pulling out the constant `|G|⁻¹`,
```
Σ_x joint(x, c) = Σ_x messageDist(x) · |G|⁻¹
               = (Σ_x messageDist(x)) · |G|⁻¹
               = 1 · |G|⁻¹ = |G|⁻¹,
```
since `messageDist` is a PMF and so sums to one. ∎

In Lean this is `hden`, using `ENNReal.tsum_mul_right` and `PMF.tsum_coe`
(the total mass of a PMF is `1`).

**Theorem 5.3 (Perfect secrecy of the group OTP).** Let `messageDist` be any PMF
on the finite group `G`, let the key be uniform on `G` and independent of the
message, and let `C = K · M`. Then for every `m, c ∈ G`,
```
P(M = m | C = c) = joint(m, c) / P(C = c) = messageDist(m).
```

*Proof.* By Lemmas 5.1 and 5.2,
```
joint(m, c) / P(C = c) = (messageDist(m) · |G|⁻¹) / |G|⁻¹.
```
Since `|G| ≥ 1`, the value `|G|⁻¹` is a nonzero, finite element of `ℝ≥0∞`, so it
cancels: `(a · t)/t = a` for `t ≠ 0, t ≠ ∞`. Hence the ratio equals
`messageDist(m) = P(M = m)`. ∎

In Lean this is `otp_perfect_secrecy`. The cancellation uses
`ENNReal.div_self` with the side conditions `|G|⁻¹ ≠ 0`
(`ENNReal.inv_ne_zero` + `ENNReal.natCast_ne_top`) and `|G|⁻¹ ≠ ∞`
(`ENNReal.inv_ne_top` + `Fintype.card_ne_zero`).

**Corollary 5.4 (Independence of message and ciphertext).** Under the
hypotheses of Theorem 5.3, `M` and `C` are independent:
`P(M = m, C = c) = P(M = m) · P(C = c)` for all `m, c`. *Proof.* Immediate from
`joint(m, c) = messageDist(m) · |G|⁻¹` (Lemma 5.1) and `P(C = c) = |G|⁻¹`
(Lemma 5.2). ∎

---

## 6. Formalization notes

The development is carried out in Lean 4 against Mathlib. We highlight the
modeling choices.

- **Carrier and instances.** `G` is a type with `[Group G] [Fintype G]
  [DecidableEq G]`. Finiteness supplies `|G| = Fintype.card G` and the uniform
  PMF; decidable equality supports the `Finset.filter` in Theorem 4.1.

- **Probabilities as PMFs.** We use Mathlib's `PMF G`, with values in `ℝ≥0∞`.
  The uniform key is `PMF.uniformOfFintype G`, satisfying
  `uniformOfFintype_apply : (uniformOfFintype G) k = (card G)⁻¹`. Composition of
  the random message and random key is expressed by monadic `bind`/`map`,
  matching Definition 2.3.

- **Sums.** Marginals are `tsum` over `G`. Because `G` is finite and values lie
  in `ℝ≥0∞`, all sums converge unconditionally; the key lemmas are
  `tsum_eq_single` (collapse to the unique nonzero term), `ENNReal.tsum_mul_right`
  (factor a constant), and `PMF.tsum_coe` (total mass one).

- **No subtraction, no division pitfalls.** Working in `ℝ≥0∞` avoids signed
  cancellation; the only division is the final Bayesian quotient, discharged by
  `ENNReal.div_self` once non-vanishing and finiteness of `|G|⁻¹` are checked.

- **Soundness.** The proofs use only Mathlib and the standard logical axioms; no
  additional axioms or unverified implementations are introduced.

---

## 7. Algorithms

We make the constructive content explicit. Throughout, group elements are
encoded as residues `0, …, n-1` of `ℤ/n`, with `·` being addition mod `n`
(an abelian instance of the general theorem); the XOR pad is the case
`n = 2^L` with component-wise addition, equivalently `G = (ℤ/2)^L`.

**Algorithm A (Encrypt / Decrypt).** Given the shared key `k` and message `m`,
output `c = k · m`; to decrypt, output `k⁻¹ · c`. Complexity: one group
operation, `O(1)` group ops (or `O(L)` bit ops for an `L`-bit pad).

**Algorithm B (Connecting key).** Given `m, c`, output the unique key
`k = c · m⁻¹` (Theorem 3.1). This is the witness used pervasively in the proofs
and in attack/diagnostic tooling. Complexity: one inverse and one product.

**Algorithm C (Posterior verifier).** Given a prior on `G` and an observed
ciphertext `c`, compute the empirical/analytic posterior `P(M = m | C = c)` for
each `m` and verify it equals the prior `P(M = m)` (Theorem 5.3). This is the
numerical witness of perfect secrecy. Complexity: `O(|G|²)` to form the joint
table, `O(|G|)` to normalize per ciphertext.

---

## 8. Applications and consequences

- **The classical XOR one-time pad** is the instance `G = (ℤ/2)^L`. Theorem 5.3
  yields the standard statement: a uniformly random `L`-bit pad, used once,
  gives perfect secrecy for `L`-bit messages.

- **Modular additive pads** (`G = ℤ/n`) cover the Vernam cipher on alphabets of
  size `n` (e.g. `n = 26` for letters, `n = 10` for digit pads used by
  intelligence services).

- **Non-abelian pads.** The theorem licenses perfectly-secret pads over any
  finite group — permutation groups, matrix groups over finite fields — provided
  the key is applied on a fixed side. This is mostly of theoretical interest but
  clarifies that *commutativity is irrelevant* to secrecy.

- **Quantum key distribution.** QKD protocols (BB84 and successors) produce fresh
  shared uniform randomness; their security promise is exactly that this
  randomness can drive a one-time pad, to which Theorem 5.3 then applies.

---

## 9. Optimality and limitations

**Shannon's key-length bound.** Perfect secrecy is not free. If a scheme with a
deterministic decryptor is perfectly secret, then `|K| ≥ |M|` (the key space is
at least as large as the message space). The group OTP meets this with equality,
`|K| = |M| = |G|`, so it is optimal: one cannot do better than a key as long as
the message. (A short argument: fix a ciphertext `c` with positive probability;
for the posterior to equal the prior, every message must be decryptable from `c`
under some key, so the keys must cover all messages, forcing `|K| ≥ |M|`.)

**Failure modes.** The hypotheses of Theorem 5.3 are tight:

- *Non-uniform key.* If the key is biased, Lemma 5.1's factor is no longer the
  message-independent `|G|⁻¹`, the cancellation in Theorem 5.3 fails, and the
  ciphertext leaks.
- *Key–message dependence.* Independence is used in Definition 2.3 / Lemma 5.1;
  correlation breaks the product form.
- *Key reuse (the "two-time pad").* If one key encrypts two messages `m₁, m₂`,
  then in the abelian case `c₁ · c₂⁻¹ = m₁ · m₂⁻¹`, revealing the quotient of
  the plaintexts and destroying secrecy. This is the most common real-world
  break and the reason for the strict "one-time" discipline.

---

## 10. Future directions

The following directions, stated as testable conjectures, extend the present
formalization (companion files in the catalog formalize RSA correctness and the
combinatorial OTP):

- **C1. Textbook-RSA homomorphism is total.** RSA encryption `m ↦ m^e mod (pq)`
  is a multiplicative monoid homomorphism on `ℤ/(pq)`, with `dec ∘ enc = id` on
  *all* of `ℤ/(pq)`; upgrade correctness to an `Equiv`/`MonoidHom` and expose the
  malleability that motivates padding.
- **C2. CRT speedup is correct.** The Chinese-Remainder decryption (compute mod
  `p` and mod `q` separately and recombine) agrees with the direct
  `c^d mod (pq)`.
- **C3. Characterizing perfectly-secret OTPs.** For a finite cancellative magma
  `(G, ⋆)` with `Enc_k(m) = k ⋆ m`, message-independence of the key count holds
  iff every left-translation is a bijection — i.e. iff `(G, ⋆)` is a
  (quasi)group.
- **C4. Key-length lower bound (Shannon).** Formalize a `PerfectlySecret`
  structure and prove `|M| ≤ |K|`, with the group OTP attaining equality.
- **C5. Two-time-pad distinguisher.** Construct an explicit distinguisher
  witnessing that key reuse breaks secrecy.

---

## 11. Conclusion

We have presented and formally verified the perfect secrecy of the one-time pad
over an arbitrary finite group. The proof isolates the single structural fact
that powers the result — that translation by a fixed group element is a
bijection — and shows how it propagates from a unique connecting key
(Theorem 3.1), through a message-independent key count (Theorem 4.1), to the
uniformity of the ciphertext marginal (Lemma 5.2) and finally to Bayesian
perfect secrecy (Theorem 5.3). The generality clarifies that neither
commutativity nor any feature of XOR is needed, and the accompanying optimality
discussion (Shannon's bound) explains why this unconditional guarantee comes at
the irreducible cost of a key as long as the message.

## References

- C. E. Shannon, *Communication Theory of Secrecy Systems*, Bell System
  Technical Journal, 28(4):656–715, 1949.
