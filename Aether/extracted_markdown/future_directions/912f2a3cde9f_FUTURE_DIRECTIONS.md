# Future Directions — Cryptography Cycle

This cycle added two fully-verified files (0 sorries) extending the
`Catalog/Cryptography` directory:

* `RSACorrectness.lean` — general (non-coprime) RSA correctness via a per-prime
  Fermat engine and CRT recombination (`pow_modEq_self_of_prime`,
  `rsa_correctness`, `rsa_decrypt_eq`).
* `OneTimePadSecrecy.lean` — Shannon perfect secrecy of the group one-time pad,
  in both combinatorial (`otp_key_count`, `otp_perfect_secrecy`) and
  probabilistic (`otp_cipher_uniform`, `otp_cipher_indep`) form, for an
  arbitrary finite (not necessarily abelian) group.

Below are bold, testable conjectures for follow-up cycles. Each is stated so
that it can be turned into a precise Lean theorem.

## C1. Textbook-RSA homomorphism is total
**Conjecture.** Define RSA encryption `enc m = m ^ e % (p*q)` and decryption
`dec c = c ^ d % (p*q)` under the standard key relation. Then `enc` is a
*multiplicative monoid homomorphism* on `ZMod (p*q)`, i.e.
`enc (m₁ * m₂) = enc m₁ * enc m₂` in `ZMod (p*q)`, and `dec ∘ enc = id` on all of
`ZMod (p*q)` (not merely on residues `< p*q`). This upgrades `rsa_decrypt_eq` to
a clean `Equiv`/`MonoidHom` statement and exposes the malleability that
motivates padding.
**Test.** State `rsa_perm : ZMod (p*q) ≃ ZMod (p*q)` and prove it is the power
map `x ↦ x ^ e`, with inverse `x ↦ x ^ d`.

## C2. CRT speedup is correct
**Conjecture.** The CRT-based RSA decryption — compute `c^d mod p` and `c^d mod q`
separately and recombine via `Nat.chineseRemainder` — agrees with the direct
computation `c^d mod (p*q)` for every ciphertext `c`. This formalizes the
3–4× implementation speedup used in practice.
**Test.** Prove `Nat.chineseRemainder hcop (c^d % p) (c^d % q) = c^d % (p*q)`
under the RSA key hypotheses, reusing `pow_modEq_self_of_prime`.

## C3. Group OTP perfect secrecy is *characterized* by the group axioms
**Conjecture.** For a finite cancellative magma `(G, ⋆)` with encryption
`enc k m = k ⋆ m`, the perfect-secrecy property "`#{k | k ⋆ m = c}` is
independent of `m`" holds **iff** left-translations `k ↦ k ⋆ m` are all
bijections, which for a finite set is equivalent to `G` being a (quasi)group.
This pins down exactly which algebraic structures admit a perfectly-secret OTP.
**Test.** Prove the forward direction (group ⇒ uniform key count, already done as
`otp_key_count`) and the converse (uniform key count for all `m,c` ⇒ each
translation is a bijection) for `Fintype` carriers.

## C4. Key-length lower bound (Shannon's theorem)
**Conjecture.** Any perfectly-secret symmetric scheme with message space `M`,
key space `K`, and ciphertext space `C` (finite, with a deterministic decryptor)
must satisfy `Fintype.card K ≥ Fintype.card M`. The group OTP meets this with
equality (`card K = card M`), so it is optimal.
**Test.** Formalize a `PerfectlySecret` structure (a key PMF plus enc/dec with
correctness and ciphertext-independence) and prove `card M ≤ card K`.

## C5. Two-time pad leaks: distinguisher exists
**Conjecture.** Reusing an OTP key is insecure: for the group OTP there is an
explicit function of the *pair* of ciphertexts `(k⋆m₁, k⋆m₂)` that recovers
`m₁⁻¹ ⋆ m₂` (the "difference" of plaintexts) independent of the key `k`. Hence
the joint ciphertext distribution for `(m₁, m₂)` depends on `m₁⁻¹ ⋆ m₂`,
breaking secrecy.
**Test.** Prove `(k ⋆ m₁)⁻¹ ⋆ (k ⋆ m₂) = m₁⁻¹ ⋆ m₂` and conclude the joint
distribution is non-constant in the plaintext pair, formalizing the attack.
