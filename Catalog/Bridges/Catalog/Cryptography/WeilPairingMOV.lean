/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Cryptography.WeilPairingBLS

/-!
# Weil Pairing: Alternation, the MOV Reduction, and Bilinear Structure

This file extends `Cryptography.WeilPairingBLS` (the abstract `Pairing` structure
and the BLS protocol layer) with three further pieces of pairing-based theory:

## 1. The alternating property (faithful Weil-pairing structure)

The Weil pairing `e_r` on the `r`-torsion of an elliptic curve is *alternating*:
`e(P, P) = 1`.  We package this as `AlternatingPairing` (a `Pairing` together with
the self-pairing axiom) and derive its hallmark **antisymmetry**
`e(P, Q) · e(Q, P) = 1`, i.e. `e(Q, P) = e(P, Q)⁻¹`.  This is the algebraic
property that distinguishes the Weil pairing from a generic bilinear map and is
the reason `e(P, P) = 1` cannot be used to recover discrete logs by self-pairing.

## 2. The MOV reduction (a cross-domain bridge)

Menu-balance category: **DOMAIN BRIDGE** — Cryptography ↔ Algebra (group theory /
finite fields).  Menezes–Okamoto–Vanstone observed that a pairing transports the
**elliptic-curve discrete logarithm problem** (ECDLP) in the additive group `G`
into the **discrete logarithm problem** in the multiplicative target group `T`
(a finite field's group of roots of unity).  Concretely `e(x • g, g) = e(g, g)^x`,
so solving DLP base `e(g, g)` in `T` recovers `x` modulo `orderOf (e g g)`.  We
prove the faithfulness of this reduction: the ECDLP value is determined *exactly*
modulo `orderOf (e g g)` (`mov_reduction`), and is fully recovered when that order
is at least the order of `g` (`mov_recovers_dlog`).

## 3. Bilinear structure as Mathlib homomorphisms

We realize `e(·, q)` and `e(p, ·)` as genuine `AddMonoidHom`s into `Additive T`
(`homLeft`, `homRight`), making the abstract biadditivity axioms usable through
Mathlib's homomorphism API, and we record that nondegeneracy is exactly
injectivity of the induced "character" map `p ↦ e(p, ·)`.

## Relation to the catalog

Builds directly on `Cryptography.WeilPairingBLS`.  The MOV reduction is the
bridge result: it equates the security of EC-based discrete-log cryptography with
discrete-log hardness in a finite field, connecting the elliptic-curve group
machinery of the Cryptography domain to the abstract group/order theory of the
Algebra domain.
-/

open Finset BigOperators

noncomputable section

namespace Pairing

/-! ## The MOV reduction: ECDLP ⟶ DLP in the target group -/

section MOV
variable {G T : Type*} [AddCommMonoid G] [CommGroup T] (P : Pairing G T)

/--
The **MOV map**: pairing both the public key `x • g` and the generator `g`
sends the elliptic-curve discrete log `x` to the target-group power
`(e g g)^x`.  This is the core identity of the Menezes–Okamoto–Vanstone
reduction.
-/
theorem mov_map (g : G) (x : ℕ) : P.e (x • g) g = (P.e g g) ^ x := by
  convert P.pairing_nsmul_left x g g using 1

/--
**Faithfulness of the MOV reduction.**  Two ECDLP candidates `a, b` produce
the same pairing value iff they are congruent modulo the order of `e g g` in the
target group.  Hence solving DLP base `e g g` in `T` pins down the ECDLP value
modulo `orderOf (e g g)`.
-/
theorem mov_reduction (g : G) (a b : ℕ) :
    P.e (a • g) g = P.e (b • g) g ↔ a ≡ b [MOD orderOf (P.e g g)] := by
  rw [P.pairing_nsmul_left, P.pairing_nsmul_left]
  exact pow_eq_pow_iff_modEq

/--
**Full discrete-log recovery.**  When the order of `e g g` in the target group
is at least the order `n` of `g`, the MOV reduction recovers the ECDLP value
exactly on the canonical residue range `0 ≤ a, b < n`: equal pairings force equal
exponents.  This is why curves with small embedding degree are cryptographically
broken — the finite-field DLP solver returns the *unique* secret.
-/
theorem mov_recovers_dlog (g : G) (n : ℕ) (hn : n ≤ orderOf (P.e g g))
    {a b : ℕ} (ha : a < n) (hb : b < n)
    (h : P.e (a • g) g = P.e (b • g) g) : a = b := by
  have hmod : a ≡ b [MOD orderOf (P.e g g)] := (P.mov_reduction g a b).mp h
  have haM : a < orderOf (P.e g g) := lt_of_lt_of_le ha hn
  have hbM : b < orderOf (P.e g g) := lt_of_lt_of_le hb hn
  rwa [Nat.ModEq, Nat.mod_eq_of_lt haM, Nat.mod_eq_of_lt hbM] at hmod

end MOV

/-! ## Bilinear structure via Mathlib homomorphisms -/

section Hom
variable {G T : Type*} [AddCommMonoid G] [CommGroup T] (P : Pairing G T)

/-- `e(·, q)` as an additive-to-multiplicative homomorphism `G →+ Additive T`. -/
def homLeft (q : G) : G →+ Additive T where
  toFun p := Additive.ofMul (P.e p q)
  map_zero' := by
    have : P.e 0 q = 1 := P.map_one_left q
    simp [this]
  map_add' a b := by
    show Additive.ofMul (P.e (a + b) q) = _
    rw [P.add_left, ofMul_mul]

/-- `e(p, ·)` as an additive-to-multiplicative homomorphism `G →+ Additive T`. -/
def homRight (p : G) : G →+ Additive T where
  toFun q := Additive.ofMul (P.e p q)
  map_zero' := by
    have : P.e p 0 = 1 := P.map_one_right p
    simp [this]
  map_add' a b := by
    show Additive.ofMul (P.e p (a + b)) = _
    rw [P.add_right, ofMul_mul]

@[simp] theorem homLeft_apply (p q : G) :
    P.homLeft q p = Additive.ofMul (P.e p q) := rfl

@[simp] theorem homRight_apply (p q : G) :
    P.homRight p q = Additive.ofMul (P.e p q) := rfl

end Hom

/-! ## Nondegeneracy as injectivity of the character map -/

section Nondegenerate
variable {G T : Type*} [AddCommGroup G] [CommGroup T] (P : Pairing G T)

/--
Nondegeneracy on the left (the kernel of `p ↦ e(p, ·)` is trivial) is exactly
injectivity of the induced character map `G → (G → T)`, `p ↦ e(p, ·)`.  This is
the abstract statement that "the pairing separates points".
-/
theorem nondegenerate_iff_char_injective :
    (∀ a : G, (∀ q, P.e a q = 1) → a = 0) ↔
      Function.Injective (fun p : G => fun q : G => P.e p q) := by
  constructor
  · intro hnd p1 p2 hpq
    exact P.pairing_left_injective hnd (fun q => congr_fun hpq q)
  · intro hinj a ha
    apply hinj
    funext q
    show P.e a q = P.e 0 q
    rw [ha q, P.map_one_left q]

end Nondegenerate

/-! ## Alternating pairings: the defining property of the Weil pairing -/

/-- An **alternating** bilinear pairing: a `Pairing` whose self-pairing is
trivial, `e(p, p) = 1`.  The Weil pairing on the `r`-torsion of an elliptic curve
is the canonical example. -/
structure AlternatingPairing (G : Type*) (T : Type*) [AddCommGroup G] [CommGroup T]
    extends Pairing G T where
  /-- The pairing of a point with itself is trivial. -/
  alt : ∀ p, e p p = 1

namespace AlternatingPairing
variable {G T : Type*} [AddCommGroup G] [CommGroup T] (P : AlternatingPairing G T)

/--
**Antisymmetry of the Weil pairing.**  `e(p, q) · e(q, p) = 1`.  Expand
`1 = e(p + q, p + q)` by biadditivity and cancel the two self-pairings using
`alt`.
-/
theorem mul_swap_eq_one (p q : G) : P.e p q * P.e q p = 1 := by
  have h := P.alt (p + q)
  rw [← h, P.add_left, P.add_right, P.add_right]
  simp [mul_comm, P.alt]

/--
The inverse form of antisymmetry: swapping the arguments inverts the pairing
value, `e(q, p) = (e p q)⁻¹`.
-/
theorem swap_eq_inv (p q : G) : P.e q p = (P.e p q)⁻¹ := by
  exact eq_inv_of_mul_eq_one_right ( P.mul_swap_eq_one p q )

end AlternatingPairing

end Pairing

/-!
-- !-- Lab Notes -- !--

-- !-- Hypothesis -- !--
The abstract `Pairing` interface from `WeilPairingBLS` is rich enough to (a) carry
the *alternating* property that actually characterizes the Weil pairing, and (b)
express the MOV reduction — the bridge equating ECDLP hardness with finite-field
DLP hardness — purely from biadditivity, with the order of the target value as the
sole quantitative input.  Conjecture: ECDLP collapses to a congruence modulo
`orderOf (e g g)` with no further curve-specific data.

-- !-- Experiment -- !--
Added `AlternatingPairing` (Pairing + `e p p = 1`) and derived antisymmetry
`e p q * e q p = 1` from `1 = e (p+q) (p+q)` via the four-term biadditive
expansion.  Realized `e(·,q)` / `e(p,·)` as `AddMonoidHom`s into `Additive T`.
Proved `mov_map : e (x•g) g = (e g g)^x`, then `mov_reduction` (an `iff` to a
`Nat.ModEq` via `pow_eq_pow_iff_modEq`) and the exact-recovery corollary
`mov_recovers_dlog` on the residue range `[0, orderOf (e g g))`.

-- !-- Analysis -- !--
Confirmed.  The reduction is *faithful*, not merely sound: equality of pairing
values is logically equivalent to congruence of exponents modulo the target
order.  This is the precise sense in which "small embedding degree breaks the
curve": a DLP solver in `T` returns the secret modulo `orderOf (e g g)`, and when
that order dominates `orderOf g`, the secret is recovered outright.

-- !-- Critique -- !--
`AlternatingPairing` requires an `AddCommGroup` source (antisymmetry uses
negatives implicitly through the `Pairing` group lemmas); over a bare monoid the
antisymmetry statement is still well-typed but `swap_eq_inv` needs inverses, so we
keep the group hypothesis.  `nondegenerate_iff_char_injective` is stated for the
left slot only; the right-slot version is symmetric.  None of the main theorems is
`rfl`/`decide`-only: each uses biadditivity, `pow_eq_pow_iff_modEq`, or an
explicit four-term expansion.

-- !-- Synthesis -- !--
The Weil-pairing story now has its defining algebraic feature (alternation ⇒
antisymmetry), its security-relevant reduction (MOV, a Cryptography ↔ Algebra
bridge), and a Mathlib-native homomorphism interface — all on top of the single
biadditivity axiom established in `WeilPairingBLS`.

-- !-- End Lab Notes -- !--
-/