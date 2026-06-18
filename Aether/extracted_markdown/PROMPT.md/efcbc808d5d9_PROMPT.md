Create a single Lean 4 file that formalizes the perfect secrecy of the one-time pad over a finite group. The file must contain EXACTLY three theorems with COMPLETE proof bodies (zero sorries). NO other theorems, lemma stubs, or content from unrelated domains.

File: OTPPerfectSecrecy.lean

Import Mathlib.Data.Fintype.Card
Import Mathlib.Data.Fintype.Basic
Import Mathlib.Algebra.Group.Basic
Import Mathlib.Algebra.Group.Fintype
Import Mathlib.Probability.ProbabilityMassFunction.Basic
Import Mathlib.Probability.ConditionalProbability

Module docstring: Brief description of one-time pad perfect secrecy over finite groups.

Theorem 1: otp_unique_key
Statement: ∀ (G : Type*) [Group G] [Fintype G] [DecidableEq G] (m c : G), ∃! k : G, k * m = c
Proof strategy: Use exists_unique to exhibit k = c * m⁻¹. For existence, show (c * m⁻¹) * m = c by group axioms (mul_assoc, inv_mul_cancel, mul_one). For uniqueness, if k * m = c then k = c * m⁻¹ by multiplying on the right by m⁻¹.

Theorem 2: otp_key_cardinality
Statement: ∀ (G : Type*) [Group G] [Fintype G] [DecidableEq G] (m c : G), Finset.card (Finset.filter (fun k => k * m = c) Finset.univ) = 1
Proof strategy: Use Finset.card_eq_one to show the filtered set equals {c * m⁻¹}. Use Finset.filter_eq_singleton and otp_unique_key.

Theorem 3: otp_perfect_secrecy
Statement: If the key K is uniformly distributed over G (pmf uniform over Finset.univ), then for any message m and ciphertext c, the conditional probability P(M = m | C = c) equals P(M = m). Formalize using Mathlib's PMF and conditional probability infrastructure.
Proof strategy: By Bayes' theorem, P(M=m|C=c) = P(C=c|M=m) * P(M=m) / P(C=c). Since C = K * M, and given M=m, P(C=c|M=m) = P(K = c * m⁻¹) = 1/|G| by uniformity. And P(C=c) = sum over all m' of P(M=m') * P(K = c * (m')⁻¹) = (1/|G|) * sum P(M=m') = 1/|G|. So P(M=m|C=c) = (1/|G|) * P(M=m) / (1/|G|) = P(M=m).

CRITICAL: Do NOT include any theorems about Korselt's criterion, Carmichael numbers, graph theory, topology, oracle traces, or any other domain. The file must contain ONLY the three OTP theorems listed above with complete proofs. If a proof step is difficult, use exact? or simp? to find the right lemma, but the final proof must have zero sorries.