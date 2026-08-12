import Cryptography.AsymmetricExponent.FermatLiars
import Cryptography.AsymmetricExponent.CRTBarrier

/-!
# Reveal density of the gcd variant `gcd(a^(N-1) - 1, N)`

The third experimental claim about `Q` concerns its gcd variant: for how many
bases `a` does `gcd(Q(a) - 1, N)` actually return a factor?  The measurement
reported a density tracking `g/p + g/q` with `g = gcd(p-1, q-1)`.  Here that is
proved exactly.

Main results.

* `AsymmetricExponent.gcd_reveal_left` / `gcd_reveal_right` — the arithmetic
  criterion: the gcd returns `p` exactly when `a^(N-1) ≡ 1 (mod p)` while
  `a^(N-1) ≢ 1 (mod q)`, i.e. (by `Core.lean`) when `ord_p(a) ∣ q-1` but
  `ord_q(a) ∤ p-1`.
* `AsymmetricExponent.card_left_liars` — exactly `g·(q-1)` units satisfy the
  left condition.
* `AsymmetricExponent.card_revealing` — the number of revealing units is
  `g·(q-1) + g·(p-1) - 2g²`, i.e. a fraction
  `g/(p-1) + g/(q-1) - 2g²/φ(N)` of all units: the measured `g/p + g/q` law.
-/

namespace AsymmetricExponent

open scoped Classical

/-! ## The arithmetic criterion -/

/-- **The gcd variant returns `p`.** If `a^(N-1) ≡ 1 (mod p)` but not modulo
`q`, then `gcd(a^(N-1) - 1, N) = p`. -/
theorem gcd_reveal_left {p q a : ℕ} (hq : q.Prime) (ha : 0 < a)
    (h1 : a ^ (p * q - 1) ≡ 1 [MOD p]) (h2 : ¬ (a ^ (p * q - 1) ≡ 1 [MOD q])) :
    Nat.gcd (a ^ (p * q - 1) - 1) (p * q) = p := by
  have hpow : 1 ≤ a ^ (p * q - 1) := Nat.one_le_pow _ _ ha
  have hp1 : p ∣ a ^ (p * q - 1) - 1 := (Nat.modEq_iff_dvd' hpow).mp h1.symm
  have hq1 : ¬ q ∣ a ^ (p * q - 1) - 1 := by
    intro hdvd
    exact h2 ((Nat.modEq_iff_dvd' hpow).mpr hdvd).symm
  exact gcd_eq_of_dvd_of_not_dvd hq hp1 hq1

/-- **The gcd variant returns `q`.** -/
theorem gcd_reveal_right {p q a : ℕ} (hp : p.Prime) (ha : 0 < a)
    (h1 : a ^ (p * q - 1) ≡ 1 [MOD q]) (h2 : ¬ (a ^ (p * q - 1) ≡ 1 [MOD p])) :
    Nat.gcd (a ^ (p * q - 1) - 1) (q * p) = q := by
  have hpow : 1 ≤ a ^ (p * q - 1) := Nat.one_le_pow _ _ ha
  have hq1 : q ∣ a ^ (p * q - 1) - 1 := (Nat.modEq_iff_dvd' hpow).mp h1.symm
  have hp1 : ¬ p ∣ a ^ (p * q - 1) - 1 := by
    intro hdvd
    exact h2 ((Nat.modEq_iff_dvd' hpow).mpr hdvd).symm
  exact gcd_eq_of_dvd_of_not_dvd hp hq1 hp1

/-! ## Counting the revealing bases -/

variable {p q : ℕ}

/-- Units whose *left* CRT component is a Fermat liar: there are `g·(q-1)`. -/
theorem card_left_liars [Fact p.Prime] [Fact q.Prime] :
    Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ // v.1 ^ (p * q - 1) = 1}
      = eulerGap p q * (q - 1) := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  have e : {v : (ZMod p)ˣ × (ZMod q)ˣ // v.1 ^ (p * q - 1) = 1} ≃
      {x : (ZMod p)ˣ // x ^ (p * q - 1) = 1} × (ZMod q)ˣ :=
    { toFun := fun v => (⟨v.1.1, v.2⟩, v.1.2)
      invFun := fun w => ⟨(w.1.1, w.2), w.1.2⟩
      left_inv := fun v => by cases v; rfl
      right_inv := fun w => by obtain ⟨⟨x, hx⟩, y⟩ := w; rfl }
  rw [Nat.card_congr e, Nat.card_prod, card_pow_eq_one_units p,
    Nat.gcd_comm (p - 1) (p * q - 1), gcd_exp_left hp.pos hq.pos, eulerGap,
    Nat.gcd_comm (q - 1) (p - 1), Nat.card_eq_fintype_card, ZMod.card_units q]

/-- Units whose *right* CRT component is a Fermat liar: there are `g·(p-1)`. -/
theorem card_right_liars [Fact p.Prime] [Fact q.Prime] :
    Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ // v.2 ^ (p * q - 1) = 1}
      = eulerGap p q * (p - 1) := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  have e : {v : (ZMod p)ˣ × (ZMod q)ˣ // v.2 ^ (p * q - 1) = 1} ≃
      (ZMod p)ˣ × {y : (ZMod q)ˣ // y ^ (p * q - 1) = 1} :=
    { toFun := fun v => (v.1.1, ⟨v.1.2, v.2⟩)
      invFun := fun w => ⟨(w.1, w.2.1), w.2.2⟩
      left_inv := fun v => by cases v; rfl
      right_inv := fun w => by obtain ⟨x, ⟨y, hy⟩⟩ := w; rfl }
  rw [Nat.card_congr e, Nat.card_prod, card_pow_eq_one_units q,
    Nat.gcd_comm (q - 1) (p * q - 1), gcd_exp_right hp.pos hq.pos, eulerGap,
    Nat.card_eq_fintype_card, ZMod.card_units p, Nat.mul_comm]

/-- Units that are liars in *both* components: `g²` of them (the Fermat liars
of `N` itself, transported through the CRT isomorphism). -/
theorem card_both_liars [Fact p.Prime] [Fact q.Prime] :
    Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ //
        v.1 ^ (p * q - 1) = 1 ∧ v.2 ^ (p * q - 1) = 1} = (eulerGap p q) ^ 2 := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  rw [Nat.card_congr (Equiv.subtypeProdEquivProd
      (p := fun x : (ZMod p)ˣ => x ^ (p * q - 1) = 1)
      (q := fun y : (ZMod q)ˣ => y ^ (p * q - 1) = 1)),
    Nat.card_prod, card_pow_eq_one_units p, card_pow_eq_one_units q,
    Nat.gcd_comm (p - 1) (p * q - 1), Nat.gcd_comm (q - 1) (p * q - 1),
    gcd_exp_left hp.pos hq.pos, gcd_exp_right hp.pos hq.pos, eulerGap,
    Nat.gcd_comm (q - 1) (p - 1), sq]

/-- Splitting a count along a predicate. -/
theorem card_split {α : Type*} [Fintype α] (A B : α → Prop) :
    Nat.card {x // A x ∧ B x} + Nat.card {x // A x ∧ ¬ B x} = Nat.card {x // A x} := by
  classical
  simp only [Nat.card_eq_fintype_card, Fintype.card_subtype]
  rw [← Finset.filter_filter, ← Finset.filter_filter]
  exact Finset.card_filter_add_card_filter_not _

/-- **Reveal count, one side.** The gcd variant returns the factor `p` for
exactly `g·(q-1) - g²` units. -/
theorem card_reveal_left [Fact p.Prime] [Fact q.Prime] :
    Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ //
        v.1 ^ (p * q - 1) = 1 ∧ ¬ v.2 ^ (p * q - 1) = 1}
      = eulerGap p q * (q - 1) - (eulerGap p q) ^ 2 := by
  have h := card_split (α := (ZMod p)ˣ × (ZMod q)ˣ)
    (fun v => v.1 ^ (p * q - 1) = 1) (fun v => v.2 ^ (p * q - 1) = 1)
  rw [card_both_liars, card_left_liars] at h
  omega

/-- **Reveal count, other side.** -/
theorem card_reveal_right [Fact p.Prime] [Fact q.Prime] :
    Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ //
        v.2 ^ (p * q - 1) = 1 ∧ ¬ v.1 ^ (p * q - 1) = 1}
      = eulerGap p q * (p - 1) - (eulerGap p q) ^ 2 := by
  have h := card_split (α := (ZMod p)ˣ × (ZMod q)ˣ)
    (fun v => v.2 ^ (p * q - 1) = 1) (fun v => v.1 ^ (p * q - 1) = 1)
  have hboth : Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ //
      v.2 ^ (p * q - 1) = 1 ∧ v.1 ^ (p * q - 1) = 1} = (eulerGap p q) ^ 2 := by
    rw [← card_both_liars]
    exact Nat.card_congr (Equiv.subtypeEquivRight (fun _ => and_comm))
  rw [hboth, card_right_liars] at h
  omega

/-- **The reveal density law.** Adding the two sides, the gcd variant
`gcd(a^(N-1) - 1, N)` returns a factor for exactly

  `g·(q-1) + g·(p-1) - 2g²`

of the `φ(N) = (p-1)(q-1)` units — a fraction `≈ g/(p-1) + g/(q-1)`, the
measured `g/p + g/q` law.  In particular the reveal density is governed by the
Euler gap alone, and drops to the negligible `(p-1) + (q-1) - 2` when `g = 1`. -/
theorem card_revealing [Fact p.Prime] [Fact q.Prime] :
    Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ //
        v.1 ^ (p * q - 1) = 1 ∧ ¬ v.2 ^ (p * q - 1) = 1}
      + Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ //
        v.2 ^ (p * q - 1) = 1 ∧ ¬ v.1 ^ (p * q - 1) = 1}
      = eulerGap p q * (q - 1) + eulerGap p q * (p - 1) - 2 * (eulerGap p q) ^ 2 := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  have hgq : eulerGap p q * (q - 1) ≥ (eulerGap p q) ^ 2 := by
    have : eulerGap p q ≤ q - 1 :=
      Nat.le_of_dvd (by have := hq.two_le; omega) (Nat.gcd_dvd_right _ _)
    calc (eulerGap p q) ^ 2 = eulerGap p q * eulerGap p q := sq _
      _ ≤ eulerGap p q * (q - 1) := Nat.mul_le_mul_left _ this
  have hgp : eulerGap p q * (p - 1) ≥ (eulerGap p q) ^ 2 := by
    have : eulerGap p q ≤ p - 1 :=
      Nat.le_of_dvd (by have := hp.two_le; omega) (Nat.gcd_dvd_left _ _)
    calc (eulerGap p q) ^ 2 = eulerGap p q * eulerGap p q := sq _
      _ ≤ eulerGap p q * (p - 1) := Nat.mul_le_mul_left _ this
  rw [card_reveal_left, card_reveal_right]
  omega

/-- **Minimal reveals when the Euler gap is trivial.** For `g = 1` only the
`(p-1) + (q-1) - 2` units that are `1` in exactly one CRT component reveal a
factor: a density of order `1/p + 1/q`, i.e. cryptographically negligible. -/
theorem card_revealing_of_eulerGap_one [Fact p.Prime] [Fact q.Prime]
    (hg : eulerGap p q = 1) :
    Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ //
        v.1 ^ (p * q - 1) = 1 ∧ ¬ v.2 ^ (p * q - 1) = 1}
      + Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ //
        v.2 ^ (p * q - 1) = 1 ∧ ¬ v.1 ^ (p * q - 1) = 1} = (q - 1) + (p - 1) - 2 := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  have h := card_revealing (p := p) (q := q)
  rw [hg] at h
  have h2 : 2 ≤ p := hp.two_le
  have h3 : 2 ≤ q := hq.two_le
  omega

end AsymmetricExponent