/-
# Mixed-radix digit expansion of Gaussian binomial coefficients modulo `ℓ`

The `q`-Lucas theorem of `Catalog/NumberTheory/QKummer/Lucas.lean` peels off *one* base-`d`
digit (`d = ord_ℓ(q)`) and leaves a classical binomial coefficient in the block indices.
Iterating the classical Lucas theorem on that block coefficient expands it into base-`ℓ` digits.
The result is a **mixed-radix** expansion in the radix vector `(d, ℓ, ℓ, ℓ, …)`:

`binom(n,k)_q ≡ binom(n % d, k % d)_q · ∏_{i<a} C(⌊n/d⌋ / ℓ^i % ℓ, ⌊k/d⌋ / ℓ^i % ℓ)  (mod ℓ)`.

Exactly one `q`-binomial factor survives — the one attached to the anomalous radix `d` — and
every remaining factor is a classical binomial coefficient of single base-`ℓ` digits.  This is
the congruence-theoretic analogue of the `q`-Kummer valuation formula, in which one base-`d`
carry is followed by a string of base-`ℓ` carries.

The last section transports the congruence across `QKummer.gaussBinom_eq_qBinom` to the object it
counts: the number of `k`-dimensional subspaces of a finite vector space.
-/
import Catalog.NumberTheory.QKummer.Lucas
import Catalog.NumberTheory.QKummer.Bridge

namespace QKummer

open Finset

section MixedRadix

variable {q ℓ d : ℕ} [hp : Fact ℓ.Prime]

/-- **Mixed-radix `q`-Lucas theorem.**  With `d` a `q`-Lucas period for `ℓ` and
`⌊n/d⌋ < ℓ^a`, the Gaussian binomial coefficient factors modulo `ℓ` as a single `q`-binomial
coefficient of the base-`d` digits times the classical base-`ℓ` Lucas product of the block
indices. -/
theorem qBinom_cast_mixed_radix (h : IsQLucas q ℓ d) {n k a : ℕ} (hk : k ≤ n)
    (hn : n / d < ℓ ^ a) :
    ((qBinom q n k : ℕ) : ZMod ℓ)
      = ((qBinom q (n % d) (k % d) : ℕ) : ZMod ℓ)
        * ∏ i ∈ range a, (((n / d / ℓ ^ i % ℓ).choose (k / d / ℓ ^ i % ℓ) : ℕ) : ZMod ℓ) := by
  have hkd : k / d ≤ n / d := Nat.div_le_div_right hk
  have hlucas := Choose.choose_modEq_prod_range_choose_nat (p := ℓ) (a := a) hn
    (lt_of_le_of_lt hkd hn)
  have hcast : (((n / d).choose (k / d) : ℕ) : ZMod ℓ)
      = ((∏ i ∈ range a, (n / d / ℓ ^ i % ℓ).choose (k / d / ℓ ^ i % ℓ) : ℕ) : ZMod ℓ) :=
    (ZMod.natCast_eq_natCast_iff _ _ _).mpr hlucas
  rw [qBinom_cast_lucas h hk, hcast, Nat.cast_prod]
  ring

/-- **Mixed-radix `q`-Lucas theorem, order form.**  For `q ≥ 2` and a prime `ℓ ∤ q`, with
`d = ord_ℓ(q)`. -/
theorem qBinom_cast_mixed_radix_orderOf {q : ℕ} (hq : 2 ≤ q) (hnd : ¬ ℓ ∣ q) {n k a : ℕ}
    (hk : k ≤ n) (hn : n / orderOf ((q : ℕ) : ZMod ℓ) < ℓ ^ a) :
    ((qBinom q n k : ℕ) : ZMod ℓ)
      = ((qBinom q (n % orderOf ((q : ℕ) : ZMod ℓ))
            (k % orderOf ((q : ℕ) : ZMod ℓ)) : ℕ) : ZMod ℓ)
        * ∏ i ∈ range a, (((n / orderOf ((q : ℕ) : ZMod ℓ) / ℓ ^ i % ℓ).choose
            (k / orderOf ((q : ℕ) : ZMod ℓ) / ℓ ^ i % ℓ) : ℕ) : ZMod ℓ) := by
  set d := orderOf ((q : ℕ) : ZMod ℓ) with hddef
  have hkd : k / d ≤ n / d := Nat.div_le_div_right hk
  have hlucas := Choose.choose_modEq_prod_range_choose_nat (p := ℓ) (a := a) hn
    (lt_of_le_of_lt hkd hn)
  have hcast : (((n / d).choose (k / d) : ℕ) : ZMod ℓ)
      = ((∏ i ∈ range a, (n / d / ℓ ^ i % ℓ).choose (k / d / ℓ ^ i % ℓ) : ℕ) : ZMod ℓ) :=
    (ZMod.natCast_eq_natCast_iff _ _ _).mpr hlucas
  rw [qBinom_cast_lucas_orderOf hq hnd hk, ← hddef, hcast, Nat.cast_prod]
  ring

end MixedRadix

section Subspaces

open Module

variable (K V : Type*) [Field K] [Fintype K] [AddCommGroup V] [Module K V] [Finite V]

/-- **`q`-Lucas congruence for subspace counts.**

For a prime `ℓ` not dividing the order `q` of the finite field `K`, the number of
`k`-dimensional subspaces of an `n`-dimensional `K`-vector space satisfies, modulo `ℓ`,

`#{W : dim W = k} ≡ C(⌊n/d⌋, ⌊k/d⌋) · binom(n % d, k % d)_q`,

where `d = ord_ℓ(q)`.  Unlike the valuation statement `padicValNat_card_submodule`, this needs
no oddness hypothesis on `ℓ` and no carry hypothesis. -/
theorem card_submodule_cast_lucas {ℓ k : ℕ} [Fact ℓ.Prime] (hnd : ¬ ℓ ∣ Fintype.card K)
    (hk : k ≤ finrank K V) :
    ((Nat.card {W : Submodule K V // finrank K W = k} : ℕ) : ZMod ℓ)
      = (((finrank K V / orderOf ((Fintype.card K : ℕ) : ZMod ℓ)).choose
            (k / orderOf ((Fintype.card K : ℕ) : ZMod ℓ)) : ℕ) : ZMod ℓ)
        * ((qBinom (Fintype.card K) (finrank K V % orderOf ((Fintype.card K : ℕ) : ZMod ℓ))
              (k % orderOf ((Fintype.card K : ℕ) : ZMod ℓ)) : ℕ) : ZMod ℓ) := by
  have hq : 2 ≤ Fintype.card K := Fintype.one_lt_card
  rw [SubspaceCounting.card_submodule_finrank_eq_gaussBinom K V hk, gaussBinom_eq_qBinom hq hk]
  exact qBinom_cast_lucas_orderOf hq hnd hk

end Subspaces

end QKummer