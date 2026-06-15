/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Pairing-Based Cryptography: Bilinear Pairings, BLS Signatures, and Aggregation

This file develops an **abstract bilinear pairing** as the algebraic core of
pairing-based cryptography (the Weil/Tate pairing on an elliptic curve being the
canonical instance), and uses it to verify the correctness and binding
properties of the **Boneh–Lynn–Shacham (BLS) signature scheme** and its
**aggregate** variant.

Rather than constructing the Weil pairing analytically (a major undertaking),
we axiomatize its *characteristic algebraic property* — biadditivity into a
multiplicative target group — and derive every downstream cryptographic
guarantee from it. This is exactly the interface that protocols consume: BLS,
aggregation, and identity-based schemes never use anything about a pairing
beyond bilinearity and (for soundness) nondegeneracy.

## Design

* Source group `G` : `AddCommGroup` (the elliptic-curve point group, written
  additively, with secret keys acting by `ℤ`-scalar multiplication).
* Target group `T` : `CommGroup` (the multiplicative group `μ_r ⊂ K*` of
  `r`-th roots of unity, written multiplicatively).
* `Pairing G T` : a biadditive map `e : G → G → T`.

## Main Results

### Bilinearity (the Weil-pairing interface)
* `Pairing.map_one_left` / `map_one_right` — `e 0 q = 1`, `e p 0 = 1`.
* `Pairing.map_neg_left` — `e (-p) q = (e p q)⁻¹`.
* `Pairing.pairing_nsmul_left` / `pairing_nsmul_right` — `e (n•p) q = (e p q)^n`.
* `Pairing.pairing_zsmul_left` — `ℤ`-graded version `e (n•p) q = (e p q)^n`.
* `Pairing.pairing_bilinear_nsmul` — `e (a•p) (b•q) = (e p q)^(a*b)`.
* `Pairing.pairing_sum_left` — `e (∑ fᵢ) q = ∏ e (fᵢ) q`.

### BLS signatures
* `Pairing.bls_verify_correct` — completeness of BLS verification.
* `Pairing.bls_aggregate_correct` — a single aggregate group element verifies
  against the product of per-signer pairings (short aggregate signatures).

### Soundness / binding
* `Pairing.pairing_left_injective` — under nondegeneracy the pairing separates
  points; this is the algebraic reason BLS verification *binds* a key.

## Relation to the catalog

This extends `Cryptography.ScalarMul` (verified scalar multiplication on
elliptic-curve points): there `n • P` is the costly group operation underlying
key generation and signing; here we show how a *pairing* turns that same scalar
action into the checkable verification equation. It connects to
`Cryptography.ShorECDSA` (the other major EC signature scheme in the catalog)
by exhibiting a verification relation that is *publicly checkable from group
elements alone*, the feature ECDSA lacks and that enables aggregation.
-/

open Finset BigOperators

noncomputable section

/-- An abstract **bilinear pairing** `e : G → G → T` from an additive abelian
group `G` (e.g. the group of points of an elliptic curve) to a multiplicative
abelian group `T` (e.g. a group of roots of unity). This is the algebraic
interface satisfied by the Weil and Tate pairings. -/
structure Pairing (G : Type*) (T : Type*) [AddCommMonoid G] [CommGroup T] where
  /-- The pairing map. -/
  e : G → G → T
  /-- Additivity (→ multiplicativity) in the first argument. -/
  add_left : ∀ a b q, e (a + b) q = e a q * e b q
  /-- Additivity (→ multiplicativity) in the second argument. -/
  add_right : ∀ p a b, e p (a + b) = e p a * e p b

namespace Pairing

/-! ## Bilinearity over a commutative monoid source -/

section Monoid
variable {G T : Type*} [AddCommMonoid G] [CommGroup T] (P : Pairing G T)

-- !-- e 0 q = 1: setting a = b = 0 gives x = x*x in the *group* T, so x = 1. -- !--
theorem map_one_left (q : G) : P.e 0 q = 1 := by
  have h := P.add_left 0 0 q
  simp only [add_zero] at h
  exact right_eq_mul.mp h

-- !-- e p 0 = 1: the mirror argument in the second slot. -- !--
theorem map_one_right (p : G) : P.e p 0 = 1 := by
  have h := P.add_right p 0 0
  simp only [add_zero] at h
  exact right_eq_mul.mp h

-- !-- e (n•p) q = (e p q)^n: induction on n, base = map_one_left, step = add_left. -- !--
theorem pairing_nsmul_left (n : ℕ) (p q : G) : P.e (n • p) q = (P.e p q) ^ n := by
  induction n with
  | zero => simp [P.map_one_left]
  | succ k ih => rw [succ_nsmul, P.add_left, ih, pow_succ]

-- !-- e p (n•q) = (e p q)^n: induction on n in the second slot. -- !--
theorem pairing_nsmul_right (n : ℕ) (p q : G) : P.e p (n • q) = (P.e p q) ^ n := by
  induction n with
  | zero => simp [P.map_one_right]
  | succ k ih => rw [succ_nsmul, P.add_right, ih, pow_succ]

-- !-- Full bilinearity of scalars: combine the two single-slot laws and pow_mul. -- !--
theorem pairing_bilinear_nsmul (a b : ℕ) (p q : G) :
    P.e (a • p) (b • q) = (P.e p q) ^ (a * b) := by
  rw [P.pairing_nsmul_left, P.pairing_nsmul_right, ← pow_mul, Nat.mul_comm]

-- !-- e (∑ fᵢ) q = ∏ e (fᵢ) q: Finset induction, base = map_one_left, step = add_left. -- !--
theorem pairing_sum_left {ι : Type*} [DecidableEq ι] (s : Finset ι) (f : ι → G) (q : G) :
    P.e (∑ i ∈ s, f i) q = ∏ i ∈ s, P.e (f i) q := by
  induction s using Finset.induction with
  | empty => simp [P.map_one_left]
  | insert a s ha ih => rw [Finset.sum_insert ha, P.add_left, ih, Finset.prod_insert ha]

/-! ## BLS signatures

Public parameters: a generator `g : G`. A signer holds secret key `x : ℕ` and
publishes public key `X = x • g`. To sign a message whose hash-to-curve value is
`H : G`, the signer outputs the single group element `σ = x • H`. A verifier with
`(g, X, H, σ)` accepts iff `e σ g = e H X`. -/

-- !-- BLS completeness: e (x•H) g = e H (x•g) is bilinearity moving the scalar across. -- !--
theorem bls_verify_correct (g H : G) (x : ℕ) :
    P.e (x • H) g = P.e H (x • g) := by
  rw [P.pairing_nsmul_left, P.pairing_nsmul_right]

-- !-- Aggregate BLS: the single group element ∑ σᵢ verifies against ∏ e(Hᵢ, Xᵢ). -- !--
-- !-- pairing_sum_left turns the aggregate sum into a product; each factor is BLS-correct. -- !--
theorem bls_aggregate_correct {ι : Type*} [DecidableEq ι] (s : Finset ι)
    (g : G) (Hm : ι → G) (sk : ι → ℕ) :
    P.e (∑ i ∈ s, (sk i) • (Hm i)) g = ∏ i ∈ s, P.e (Hm i) ((sk i) • g) := by
  rw [P.pairing_sum_left]
  exact Finset.prod_congr rfl (fun i _ => P.bls_verify_correct g (Hm i) (sk i))

end Monoid

/-! ## Group source: `ℤ`-bilinearity and nondegeneracy soundness -/

section Group
variable {G T : Type*} [AddCommGroup G] [CommGroup T] (P : Pairing G T)

-- !-- e (-p) q = (e p q)⁻¹: from e(p + (-p)) q = e 0 q = 1 and add_left. -- !--
theorem map_neg_left (p q : G) : P.e (-p) q = (P.e p q)⁻¹ := by
  have h := P.add_left p (-p) q
  rw [add_neg_cancel, P.map_one_left] at h
  exact eq_inv_of_mul_eq_one_right h.symm

-- !-- ℤ-graded scalar law: split n = ±m and reduce to the ℕ case via map_neg_left. -- !--
theorem pairing_zsmul_left (n : ℤ) (p q : G) : P.e (n • p) q = (P.e p q) ^ n := by
  obtain ⟨m, rfl | rfl⟩ := n.eq_nat_or_neg
  · rw [zpow_natCast, natCast_zsmul]; exact P.pairing_nsmul_left m p q
  · rw [neg_zsmul, P.map_neg_left, zpow_neg, zpow_natCast, natCast_zsmul,
        P.pairing_nsmul_left]

-- !-- Nondegeneracy ⇒ separation: if e p₁ q = e p₂ q for all q then p₁ = p₂. -- !--
-- !-- Apply nondegeneracy to p₁ - p₂: e (p₁-p₂) q = e p₁ q * (e p₂ q)⁻¹ = 1 for all q. -- !--
theorem pairing_left_injective (hnd : ∀ a : G, (∀ q, P.e a q = 1) → a = 0)
    {p1 p2 : G} (h : ∀ q, P.e p1 q = P.e p2 q) : p1 = p2 := by
  have key : ∀ q, P.e (p1 - p2) q = 1 := by
    intro q
    rw [sub_eq_add_neg, P.add_left, P.map_neg_left, h q, mul_inv_cancel]
  exact sub_eq_zero.mp (hnd _ key)

end Group

end Pairing

/-!
-- !-- Lab Notebook: Pairing / WeilPairingBLS -- !--
-- !-- Hypothesis: Every cryptographic guarantee of BLS (completeness, aggregation,
--     binding) follows from biadditivity of a pairing alone, with nondegeneracy
--     needed only for soundness — so the heavy analytic construction of the Weil
--     pairing is unnecessary to verify the protocol layer. -- !--
-- !-- Result: Confirmed. `Pairing` (two biadditivity axioms) suffices for
--     map_one/neg, nsmul/zsmul/bilinear scalar laws, the sum→product law,
--     BLS completeness, and aggregate completeness. Nondegeneracy alone yields
--     point-separation (`pairing_left_injective`), the binding property. -- !--
-- !-- Insight: The sum→product law `pairing_sum_left` is the mathematical engine
--     of "short" aggregate signatures: a Finset-sum of group elements collapses
--     verification into a single pairing on the left. The same Finset.induction
--     pattern (empty ↦ map_one_left, insert ↦ add_left) drives both it and any
--     future multi-signature variant. -- !--
-- !-- Failure analysis: (1) A CommMonoid target is too weak — `e 0 q = e 0 q * e 0 q`
--     forces `e 0 q = 1` only with cancellation, so T must be a *group*
--     (`right_eq_mul`). (2) `ℤ`-scalar law needed `natCast_zsmul` to bridge the
--     `(↑m) • p` zsmul against the `m • p` nsmul produced by `neg_zsmul`. -- !--
-- !-- End Lab Notebook -- !--
-/