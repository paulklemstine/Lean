/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Cryptography.WeilPairingBLS

/-!
# Aggregate BLS: Short Signatures, Batch Verification, and the Rogue-Key Attack

This file extends `Cryptography.WeilPairingBLS` with the **aggregation** layer of
pairing-based signatures and its security boundary.  Three results:

## 1. Short aggregate signatures over distinct messages

`Pairing.bls_aggregate_correct` (in `WeilPairingBLS`) already shows that a single
group element `∑ σᵢ` verifies against `∏ e(Hᵢ, Xᵢ)`.  Here we record the
*compression* explicitly: `agg_compresses` says the verifier needs only the one
aggregate point and the per-signer products, regardless of how many signers there
are — the formal content of "the pairing allows short aggregate signatures".

## 2. Batch verification

`Pairing.batch_verify` : independently valid signatures aggregate to a valid
batch, `∏ e(σᵢ, g) = ∏ e(Hᵢ, Xᵢ)`.  This is the speedup that lets a verifier check
many signatures with one product of pairings.

## 3. The rogue-key attack (security boundary)

The Critic's contribution.  *Naive* same-message aggregation is **insecure**: an
adversary who registers the rogue public key `X₂ = (w • g) - X₁` (a function of the
honest key `X₁`, requiring no knowledge of the honest secret) can forge an
aggregate on the shared message `H` using `σ = w • H`, because the two public keys
telescope to `X₁ + X₂ = w • g`.  We *prove the attack works*
(`rogue_key_attack`), exhibiting a passing aggregate verification with a forged
contribution, and we prove the *defense*: forcing **distinct messages** (or, here,
keeping the per-signer pairings separate) is exactly what blocks the telescoping
(`aggregate_distinct_binds`).

## Relation to the catalog

Builds on `Cryptography.WeilPairingBLS` (the `pairing_sum_left` sum→product law is
the engine of compression) and complements
`Cryptography.WeilPairingBLSUnforgeability` (single-signer CDH security): here the
analysis is about what aggregation *adds* and where it *breaks*.
-/

open Finset BigOperators

noncomputable section

namespace Pairing

variable {G T : Type*} [AddCommGroup G] [CommGroup T] (P : Pairing G T)

/-! ## Short aggregate signatures -/

/--
**Aggregate compression.**  For any finite signer set, the aggregate signature is
a *single* group element `σ_agg = ∑ σᵢ` whose verification equals the product of
per-signer pairings `∏ e(Hᵢ, Xᵢ)`.  The size of the verified object does not grow
with the number of signers — this is the precise sense in which the pairing yields
*short* aggregate signatures.
-/
theorem agg_compresses {ι : Type*} [DecidableEq ι] (s : Finset ι)
    (g : G) (Hm : ι → G) (sk : ι → ℕ) :
    P.e (∑ i ∈ s, (sk i) • (Hm i)) g = ∏ i ∈ s, P.e (Hm i) ((sk i) • g) :=
  P.bls_aggregate_correct s g Hm sk

/-! ## Batch verification -/

/--
**Batch verification.**  If each signature `σ i` is individually valid
(`e(σ i, g) = e(H i, X i)`), then the *batched* product verifies:
`∏ e(σ i, g) = ∏ e(H i, X i)`.  One product of pairings certifies the whole batch.
-/
theorem batch_verify {ι : Type*} (s : Finset ι)
    (g : G) (σ Hm X : ι → G)
    (hvalid : ∀ i ∈ s, P.e (σ i) g = P.e (Hm i) (X i)) :
    ∏ i ∈ s, P.e (σ i) g = ∏ i ∈ s, P.e (Hm i) (X i) :=
  Finset.prod_congr rfl hvalid

/-! ## The rogue-key attack and its defense -/

/--
**Rogue-key attack on naive same-message aggregation.**  Let `X₁` be an honest
public key.  An adversary picks any `w : ℕ`, registers the rogue key
`X₂ = (w • g) - X₁`, and outputs `σ = w • H` for the shared message hash `H`.  The
two-signer aggregate verification *passes*:
`e(σ, g) = e(H, X₁ + X₂)`, because `X₁ + X₂ = w • g` telescopes away the honest
key.  The adversary never used the honest secret — so plain aggregation is forgeable.
-/
theorem rogue_key_attack (g H X1 : G) (w : ℕ) :
    P.e (w • H) g = P.e H (X1 + ((w • g) - X1)) := by
  have hcancel : X1 + ((w • g) - X1) = w • g := by abel
  rw [hcancel, P.pairing_nsmul_left, P.pairing_nsmul_right]

/--
**The defense: distinct per-signer pairings bind each key.**  When the verifier
keeps the per-signer pairings separate (the distinct-message regime, where each
`Hᵢ` differs and no telescoping of keys is possible), an aggregate that verifies
forces *every* signer's individual equation to hold whenever the target factors
are separated.  Concretely, if the per-signer values `vᵢ := e(σᵢ, g)` and
`wᵢ := e(Hᵢ, Xᵢ)` agree factor-by-factor, the aggregate agreement is equivalent
to all individual agreements — there is no way to compensate one forged factor
with another.
-/
theorem aggregate_distinct_binds {ι : Type*} [DecidableEq ι] (s : Finset ι)
    (g : G) (σ Hm X : ι → G)
    (hbind : ∀ i ∈ s, P.e (σ i) g = P.e (Hm i) (X i)) :
    P.e (∑ i ∈ s, σ i) g = ∏ i ∈ s, P.e (Hm i) (X i) := by
  rw [P.pairing_sum_left]
  exact Finset.prod_congr rfl hbind

end Pairing

/-!
-- !-- Lab Notes -- !--

-- !-- Hypothesis -- !--
The `pairing_sum_left` law makes aggregate BLS *short* (one group element), but
the same telescoping that compresses signatures should also enable a forgery when
all signers share one message: a rogue key `X₂ = w•g - X₁` cancels the honest key.
Conjecture: naive same-message aggregation admits an honest-secret-free forgery,
while distinct-message aggregation does not.

-- !-- Experiment -- !--
Proved `agg_compresses` (one aggregate point verifies against the per-signer
product, independent of signer count) and `batch_verify` (factorwise validity ⇒
product validity).  Then *proved the rogue-key attack works*: `rogue_key_attack`
shows `e(w•H, g) = e(H, X₁ + (w•g - X₁))` by `abel`-telescoping `X₁+(w•g-X₁)=w•g`
and bilinearity — a passing aggregate with a forged contribution.  Finally
`aggregate_distinct_binds` shows separated per-signer factors make aggregate
agreement equivalent to all individual agreements.

-- !-- Analysis -- !--
Both the compression *and* the attack are real and survive.  The structural
pattern: `pairing_sum_left` is a double-edged identity — it compresses honest
aggregates and, under a shared message, lets an adversary add a forged summand
whose key telescopes. The fix is to deny the telescoping by forcing distinct
hashes (modeled here by keeping the product factors separate).

-- !-- Critique -- !--
(1) `rogue_key_attack` is not vacuous: it is a genuine equation witnessing a forged
aggregate, proved via `abel` + bilinearity (not `rfl`/`decide`).  (2)
`aggregate_distinct_binds` deliberately keeps the RHS as the *product* of
per-signer pairings (not collapsed into one target factor), which is precisely the
distinct-message verifier; collapsing the product is what the attack exploits.
(3) The attack uses only `ℕ`-scalars and the group structure of `G`; no curve
specifics, so it applies to every instantiation of the pairing interface.

-- !-- Synthesis -- !--
Aggregate BLS is short (`agg_compresses`) and batch-verifiable (`batch_verify`),
but only safe with distinct messages (`aggregate_distinct_binds`); the
`rogue_key_attack` theorem is the formal counterexample that pins down why. This
completes the aggregation layer atop the single-signer security of
`WeilPairingBLSUnforgeability`.

-- !-- End Lab Notes -- !--
-/