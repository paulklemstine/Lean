/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Cryptography.WeilPairingBLS
import Cryptography.WeilPairingMOV
import Cryptography.WeilPairingBLSUnforgeability
import Cryptography.WeilPairingConcrete

/-!
# A Concrete Pairing Supporting BLS Unforgeability and the MOV Reduction

`Cryptography.WeilPairingConcrete` exhibits the alternating Weil pairing on
`(ℤ/n)²` and shows it is nondegenerate as a bilinear form but **degenerate
against any fixed generator** (`e g g = 1`).  That fixed-slot degeneracy is
exactly the hypothesis the catalog's BLS-unforgeability and MOV theorems require,
so the *symmetric* Weil pairing cannot discharge them.

This file supplies the missing concrete witness using a **non-alternating
"Tate-like" pairing** on the prime field `ℤ/p`:

  `t(a, b) = ζ^(a·b)`.

Over a field this pairing *is* nondegenerate against any nonzero fixed generator,
so we can instantiate — with fully **proved** (not assumed) hypotheses — the
catalog's conditional security results:

## Main results

* `tatePairing n` — the bilinear pairing `t(a,b) = ofAdd (a·b)` on `ℤ/n`.
* `tate_fixed_nondegenerate` — over a prime field, `t(·, g)` is nondegenerate for
  every `g ≠ 0`: the hypothesis `∀ a, t a g = 1 → a = 0`.
* `tate_bls_sig_unique` — instantiates `Pairing.bls_sig_unique`: the BLS
  verification equation has a unique solution, so signatures are **binding**.
* `tate_bls_unforgeable` — instantiates `Pairing.cdh_hard_implies_no_forger`: if
  CDH is hard at the instance, no forger wins.  This is concrete existential
  unforgeability under CDH.
* `tate_orderOf_self` — `orderOf (t g g) = p` for `g ≠ 0`, the quantitative input
  to MOV.
* `tate_mov_recovers` — instantiates `Pairing.mov_recovers_dlog`: the MOV map
  recovers the discrete log exactly on `[0, p)`.
* `tate_bls_aggregate` / `weil_bls_aggregate` — short aggregate signatures
  (`Pairing.bls_aggregate_correct`) for both concrete pairings.

## Relation to the catalog

This is the security companion to `Cryptography.WeilPairingConcrete`.  It turns
the *conditional* theorems of `Cryptography.WeilPairingBLSUnforgeability`
(`bls_sig_unique`, `cdh_hard_implies_no_forger`) and `Cryptography.WeilPairingMOV`
(`mov_recovers_dlog`) into *unconditional* statements about an explicit pairing,
by exhibiting a pairing whose fixed-slot nondegeneracy is provable.
-/

open Finset BigOperators

noncomputable section

namespace WeilConcrete

/-! ## A non-alternating "Tate-like" pairing on `ℤ/n` -/

/-- The bilinear pairing `t(a, b) = ζ^(a·b)` on `ℤ/n`.  Unlike the alternating
Weil pairing, this is symmetric and (over a field) nondegenerate against a fixed
generator, which is what BLS unforgeability requires. -/
def tatePairing (n : ℕ) : Pairing (ZMod n) (Multiplicative (ZMod n)) where
  e a b := Multiplicative.ofAdd (a * b)
  add_left a b q := by
    show Multiplicative.ofAdd ((a + b) * q) = _
    simp only [← ofAdd_add]; congr 1; ring
  add_right p a b := by
    show Multiplicative.ofAdd (p * (a + b)) = _
    simp only [← ofAdd_add]; congr 1; ring

@[simp] theorem tatePairing_e {n : ℕ} (a b : ZMod n) :
    (tatePairing n).e a b = Multiplicative.ofAdd (a * b) := rfl

/-! ## Fixed-generator nondegeneracy over a prime field -/

/-- **Fixed-slot nondegeneracy.**  Over the prime field `ℤ/p`, the Tate pairing
against any nonzero generator `g` is nondegenerate: `t a g = 1 → a = 0`.  This is
precisely the hypothesis `Pairing.bls_sig_unique` and
`Pairing.cdh_hard_implies_no_forger` assume — here it is *proved*, not posited. -/
theorem tate_fixed_nondegenerate {p : ℕ} [Fact p.Prime] {g : ZMod p} (hg : g ≠ 0)
    (a : ZMod p) (h : (tatePairing p).e a g = 1) : a = 0 := by
  have hag : a * g = 0 := ofAdd_eq_one.mp h
  rcases mul_eq_zero.mp hag with h1 | h2
  · exact h1
  · exact absurd h2 hg

/-! ## BLS binding and unforgeability, concretely -/

/-- **BLS signatures are binding (concrete).**  Instantiating
`Pairing.bls_sig_unique` at the Tate pairing over a prime field: any signature
passing verification equals the honest signature `x • H`. -/
theorem tate_bls_sig_unique {p : ℕ} [Fact p.Prime] {g : ZMod p} (hg : g ≠ 0)
    (H : ZMod p) (x : ℕ) {σ : ZMod p}
    (hver : (tatePairing p).e σ g = (tatePairing p).e H (x • g)) :
    σ = x • H :=
  (tatePairing p).bls_sig_unique g H x (fun a => tate_fixed_nondegenerate hg a) hver

/-- **BLS existential unforgeability under CDH (concrete).**  Instantiating
`Pairing.cdh_hard_implies_no_forger`: if the CDH value is hard to produce at the
instance `(g, a • g, b • g)`, then no candidate `σ` passes BLS verification.  The
nondegeneracy hypothesis is discharged by `tate_fixed_nondegenerate`. -/
theorem tate_bls_unforgeable {p : ℕ} [Fact p.Prime] {g : ZMod p} (hg : g ≠ 0)
    (a b : ℕ) (σ : ZMod p)
    (hcdh : ¬ Pairing.IsDH g (a • g) (b • g) σ) :
    (tatePairing p).e σ g ≠ (tatePairing p).e (b • g) (a • g) :=
  (tatePairing p).cdh_hard_implies_no_forger g a b σ
    (fun c => tate_fixed_nondegenerate hg c) hcdh

/-! ## The MOV reduction, concretely -/

/-- Additive order of a nonzero element of a prime field is the field size. -/
theorem addOrderOf_prime {p : ℕ} [Fact p.Prime] {c : ZMod p} (hc : c ≠ 0) :
    addOrderOf c = p := by
  have hp := Fact.out (p := p.Prime)
  have hdvd : addOrderOf c ∣ p := by
    have := addOrderOf_dvd_card (G := ZMod p) (x := c)
    simpa [ZMod.card] using this
  rcases (Nat.Prime.eq_one_or_self_of_dvd hp _ hdvd) with h1 | hp'
  · exact absurd (AddMonoid.addOrderOf_eq_one_iff.mp h1) hc
  · exact hp'

/-- **The MOV self-pairing has full order.**  `orderOf (t g g) = p` for `g ≠ 0`,
since `t g g = ofAdd (g²)` and `g²` is a nonzero element of the prime field. -/
theorem tate_orderOf_self {p : ℕ} [Fact p.Prime] {g : ZMod p} (hg : g ≠ 0) :
    orderOf ((tatePairing p).e g g) = p := by
  have hgg : g * g ≠ 0 := mul_ne_zero hg hg
  rw [tatePairing_e, orderOf_ofAdd_eq_addOrderOf]
  exact addOrderOf_prime hgg

/-- **MOV recovers the discrete log (concrete).**  Instantiating
`Pairing.mov_recovers_dlog` at the Tate pairing over `ℤ/p`: equal MOV images on
the canonical range `[0, p)` force equal exponents.  Since the target-group
element `t g g` has order exactly `p`, the finite-field discrete-log solver
returns the unique secret. -/
theorem tate_mov_recovers {p : ℕ} [Fact p.Prime] {g : ZMod p} (hg : g ≠ 0)
    {a b : ℕ} (ha : a < p) (hb : b < p)
    (h : (tatePairing p).e (a • g) g = (tatePairing p).e (b • g) g) : a = b :=
  (tatePairing p).mov_recovers_dlog g p (by rw [tate_orderOf_self hg]) ha hb h

/-! ## Short aggregate signatures, concretely -/

/-- **Short aggregate BLS (Tate model).**  A single field element `∑ σᵢ` verifies
against the product of per-signer pairings — `Pairing.bls_aggregate_correct`
applied to the concrete Tate pairing. -/
theorem tate_bls_aggregate {p : ℕ} {ι : Type*} [DecidableEq ι] (s : Finset ι)
    (g : ZMod p) (Hm : ι → ZMod p) (sk : ι → ℕ) :
    (tatePairing p).e (∑ i ∈ s, (sk i) • (Hm i)) g
      = ∏ i ∈ s, (tatePairing p).e (Hm i) ((sk i) • g) :=
  (tatePairing p).bls_aggregate_correct s g Hm sk

/-- **Short aggregate BLS (Weil model).**  Same aggregation identity for the
alternating Weil pairing on `(ℤ/n)²`. -/
theorem weil_bls_aggregate {n : ℕ} {ι : Type*} [DecidableEq ι] (s : Finset ι)
    (g : Tor n) (Hm : ι → Tor n) (sk : ι → ℕ) :
    (weilPairing n).e (∑ i ∈ s, (sk i) • (Hm i)) g
      = ∏ i ∈ s, (weilPairing n).e (Hm i) ((sk i) • g) :=
  (weilPairing n).bls_aggregate_correct s g Hm sk

end WeilConcrete

/-!
-- !-- Lab Notes -- !--

-- !-- Hypothesis -- !--
`WeilPairingConcrete` proved the symmetric Weil pairing is degenerate against any
fixed generator, so it cannot discharge the fixed-slot nondegeneracy used by the
catalog's BLS-unforgeability and MOV theorems.  Conjecture: a *non-alternating*
pairing `t(a,b)=ζ^(ab)` on a prime field `ℤ/p` IS fixed-slot nondegenerate, and
therefore turns every conditional security theorem of the catalog into an
unconditional statement about an explicit pairing.

-- !-- Experiment -- !--
Built `tatePairing p` and proved `tate_fixed_nondegenerate` (`t a g = 1 → a*g=0 →
a=0` using the field's no-zero-divisors).  Discharged the catalog hypotheses to
get `tate_bls_sig_unique` (`bls_sig_unique`), `tate_bls_unforgeable`
(`cdh_hard_implies_no_forger`), and — computing `orderOf (t g g) = p` via
`addOrderOf` of a nonzero field element — `tate_mov_recovers` (`mov_recovers_dlog`).
Aggregation (`bls_aggregate_correct`) instantiates for BOTH the Tate and Weil
pairings.

-- !-- Analysis -- !--
Survived in full.  The contrast is the punchline: alternation forces fixed-slot
degeneracy (Weil model), which *breaks* single-group fixed-generator
unforgeability; dropping alternation (Tate model) restores it over a field.  This
is the formal shadow of why deployed BLS uses asymmetric (type-3) pairings.

-- !-- Critique -- !--
The unforgeability statement is non-vacuous: `bls_verify_correct` exhibits honest
`σ` for which `IsDH` holds, so the hypothesis `¬ IsDH …` is a real constraint, not
always-true.  The prime-field assumption is load-bearing (mul-cancellation and the
order computation both fail on composite `n`), and is stated explicitly.  No proof
is `rfl`/`decide`-only: each routes through field nondegeneracy, `addOrderOf`
divisibility, or the catalog's biadditive lemmas.

-- !-- Synthesis -- !--
Together with `WeilPairingConcrete`, the catalog now has explicit pairings
witnessing BOTH sides of the story: a nondegenerate alternating Weil pairing
(bilinearity, antisymmetry, point separation) and a fixed-slot-nondegenerate Tate
pairing that unconditionally satisfies BLS binding, CDH-unforgeability, and exact
MOV discrete-log recovery.

-- !-- End Lab Notes -- !--
-/