/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Black-Box Separations as Conserved Invariants

This file isolates the *structural engine* behind black-box separations of
cryptographic primitives. The slogan is again **conservation**: a black-box
construction calculus admits a conserved scalar — the `rank` of a primitive —
that is monotone along every constructor. A separation is then nothing but an
*inequality between ranks*, dispatched by `omega`.

We model the standard symmetric-key tower

```
OWF  ⟶  PRG  ⟶  PRF  ⟶  ENC (IND-CPA encryption)
```

as an inductive *construction calculus* `CryptoImplies`, where `CryptoImplies X Y`
means "primitive `Y` can be built (black-box) from primitive `X`". The calculus
is closed under reflexivity, transitivity, and the three classical upgrades
(HILL/GGM/encryption-from-PRF). The conserved scalar `rank` increases by exactly
one along each upgrade, so `CryptoImplies X Y → rank X ≤ rank Y`.

## Main results

* `cryptoImplies_rank_mono` — the rank invariant: rank is monotone along
  every derivation.
* `enc_not_implies_owf` — you cannot derive the strictly weaker `OWF` from the
  strictly stronger `ENC` inside the (rank-increasing) construction calculus.
* `prf_not_implies_prg` — a `PRF` does not collapse downward to a `PRG`.
* `owf_implies_enc` — non-triviality: the full tower `OWF ⟹ ENC` is derivable.

-- !-- Lab Notebook -- !--
Hypothesis: Black-box separations are *order* phenomena. If the construction
  calculus carries a monotone scalar invariant, then any separation reduces to
  a numeric inequality, with no probabilistic oracle argument required at the
  structural level.
Result: Confirmed. A single inductive `CryptoImplies` with a `ℕ`-valued `rank`
  invariant makes `cryptoImplies_rank_mono` a 5-case induction, and each
  separation a one-liner after specializing the invariant.
Insight: `rank` is simultaneously (i) an *obstruction* — distinct ranks witness
  separations — and (ii) a *metric* — the rank gap lower-bounds derivation
  length. The same scalar drives both the impossibility and the tightness story.
Failure analysis: A one-dimensional `rank` is necessarily a *total* order, so it
  can only express separations between comparable (symmetric-key) primitives. It
  cannot witness the Minicrypt/Cryptomania incomparability, which needs a
  two-dimensional invariant (see FUTURE_DIRECTIONS.md, Direction 3).
-- !-- Lab Notebook -- !--
-/

namespace Cryptography.ImpagliazzoWorlds

/-- The symmetric-key cryptographic primitives we model, in increasing strength. -/
inductive Primitive : Type
  | OWF  -- one-way function
  | PRG  -- pseudorandom generator
  | PRF  -- pseudorandom function
  | ENC  -- IND-CPA secure (symmetric) encryption
  deriving DecidableEq, Repr

open Primitive

/-- The conserved scalar invariant: the height of a primitive in the tower. -/
def rank : Primitive → ℕ
  | OWF => 0
  | PRG => 1
  | PRF => 2
  | ENC => 3

/-- The black-box construction calculus. `CryptoImplies X Y` reads
"`Y` is constructible from `X`". It is closed under reflexivity, transitivity,
and the three classical upgrades of the symmetric-key tower. -/
inductive CryptoImplies : Primitive → Primitive → Prop
  | refl  (X : Primitive) : CryptoImplies X X
  | trans {X Y Z : Primitive} :
      CryptoImplies X Y → CryptoImplies Y Z → CryptoImplies X Z
  | owf_prg : CryptoImplies OWF PRG   -- HILL: PRG from any OWF
  | prg_prf : CryptoImplies PRG PRF   -- GGM: PRF from any PRG
  | prf_enc : CryptoImplies PRF ENC   -- IND-CPA encryption from any PRF

-- !-- Induction on the derivation: `refl` gives reflexivity of `≤`, `trans`
-- chains by transitivity, and each upgrade increases rank by exactly one. -- !--
/-- **The rank invariant.** Rank is monotone along every black-box derivation:
constructing `Y` from `X` can never decrease the conserved scalar. -/
theorem cryptoImplies_rank_mono {X Y : Primitive} (h : CryptoImplies X Y) :
    rank X ≤ rank Y := by
  induction h with
  | refl X => exact le_refl _
  | trans _ _ ih₁ ih₂ => exact le_trans ih₁ ih₂
  | owf_prg => decide
  | prg_prf => decide
  | prf_enc => decide

-- !-- If `ENC ⟹ OWF` were derivable, monotonicity would give
-- `rank ENC = 3 ≤ 0 = rank OWF`, impossible. -- !--
/-- **Separation: ENC ⇏ OWF (in the calculus).** The strictly stronger `ENC`
cannot derive the strictly weaker `OWF`, because the rank invariant is
conserved upward. -/
theorem enc_not_implies_owf : ¬ CryptoImplies ENC OWF := by
  intro h
  have := cryptoImplies_rank_mono h
  simp [rank] at this

-- !-- A `PRF` has rank `2` and a `PRG` rank `1`; a derivation would force
-- `2 ≤ 1`. -- !--
/-- **Separation: PRF ⇏ PRG (in the calculus).** A PRF does not collapse
downward to a PRG. -/
theorem prf_not_implies_prg : ¬ CryptoImplies PRF PRG := by
  intro h
  have := cryptoImplies_rank_mono h
  simp [rank] at this

-- !-- Chain the three upgrades by transitivity: OWF → PRG → PRF → ENC. -- !--
/-- **Non-triviality: OWF ⟹ ENC.** The full symmetric-key tower is derivable,
so the calculus is not vacuously rank-monotone. -/
theorem owf_implies_enc : CryptoImplies OWF ENC :=
  CryptoImplies.trans (CryptoImplies.trans CryptoImplies.owf_prg CryptoImplies.prg_prf)
    CryptoImplies.prf_enc

end Cryptography.ImpagliazzoWorlds