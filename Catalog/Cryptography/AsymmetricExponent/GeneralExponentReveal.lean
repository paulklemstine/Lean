import Cryptography.AsymmetricExponent.RevealDensity

/-!
# Round 34: the general-exponent reveal identity and the solvable extreme

`RevealDensity.lean` counts the units `v = (v₁, v₂) ∈ (ℤ/p)ˣ × (ℤ/q)ˣ` for which
the gcd variant `gcd(a^(N-1) - 1, N)` reveals a factor, for the single exponent
`E = N - 1`.  This file removes the restriction on the exponent.

Main results.

* `AsymmetricExponent.card_reveal_left_exp` — for **every** exponent `E`, exactly
  `d_p·(q-1) - d_p·d_q` units have `v₁^E = 1` but `v₂^E ≠ 1`, where
  `d_p = gcd(E, p-1)`, `d_q = gcd(E, q-1)`.
* `AsymmetricExponent.card_revealing_exp` — the **general-exponent reveal
  identity** `R(E) = d_p(q-1) + d_q(p-1) - 2·d_p·d_q`.
* `AsymmetricExponent.card_revealing_exp_recovers` — at `E = N - 1` it recovers
  `card_revealing` (both gcds collapse to the Euler gap).
* `AsymmetricExponent.reveal_partition` — the four-cell partition identity
  `d_p d_q + R(E) + (p-1-d_p)(q-1-d_q) = (p-1)(q-1)`.
* `AsymmetricExponent.extreme_discriminant_square` — for `q = k(p-1) + s`, the
  quadratic `k p² + (s-k) p - N = 0` has the **exactly square** discriminant
  `(s-k)² + 4kN = (2kp + s - k)²`.
* `AsymmetricExponent.extreme_factor_by_sqrt` (`s = 1`) and
  `AsymmetricExponent.extreme_factor_by_sqrt_neg` (`s = -1`): one integer square
  root recovers `p`.
* `AsymmetricExponent.max_reveal_extreme` — when `(p-1) ∣ (q-1)` (the maximal
  Euler gap `g = p-1`, the high-density end of the family) the reveal count is
  `(p-1)(q-p)`, and that same case is the `s = 1` algebraically solvable case.
-/

namespace AsymmetricExponent

open scoped Classical

variable {p q : ℕ}

/-! ## Counting for an arbitrary exponent -/

/-- Units whose left component satisfies `x^E = 1`: `gcd(E, p-1)·(q-1)` of them. -/
theorem card_left_exp [Fact p.Prime] [Fact q.Prime] (E : ℕ) :
    Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ // v.1 ^ E = 1}
      = Nat.gcd E (p - 1) * (q - 1) := by
  have e : {v : (ZMod p)ˣ × (ZMod q)ˣ // v.1 ^ E = 1} ≃
      {x : (ZMod p)ˣ // x ^ E = 1} × (ZMod q)ˣ :=
    { toFun := fun v => (⟨v.1.1, v.2⟩, v.1.2)
      invFun := fun w => ⟨(w.1.1, w.2), w.1.2⟩
      left_inv := fun v => by cases v; rfl
      right_inv := fun w => by obtain ⟨⟨x, hx⟩, y⟩ := w; rfl }
  rw [Nat.card_congr e, Nat.card_prod, card_pow_eq_one_units p, Nat.gcd_comm,
    Nat.card_eq_fintype_card, ZMod.card_units q]

/-- Units liar in both components for the exponent `E`: `d_p·d_q` of them. -/
theorem card_both_exp [Fact p.Prime] [Fact q.Prime] (E : ℕ) :
    Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ // v.1 ^ E = 1 ∧ v.2 ^ E = 1}
      = Nat.gcd E (p - 1) * Nat.gcd E (q - 1) := by
  rw [Nat.card_congr (Equiv.subtypeProdEquivProd
      (p := fun x : (ZMod p)ˣ => x ^ E = 1) (q := fun y : (ZMod q)ˣ => y ^ E = 1)),
    Nat.card_prod, card_pow_eq_one_units p, card_pow_eq_one_units q,
    Nat.gcd_comm (p - 1), Nat.gcd_comm (q - 1)]

/-- **Left reveals for an arbitrary exponent.** -/
theorem card_reveal_left_exp [Fact p.Prime] [Fact q.Prime] (E : ℕ) :
    Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ // v.1 ^ E = 1 ∧ ¬ v.2 ^ E = 1}
      = Nat.gcd E (p - 1) * (q - 1) - Nat.gcd E (p - 1) * Nat.gcd E (q - 1) := by
  have h := card_split (α := (ZMod p)ˣ × (ZMod q)ˣ)
    (fun v => v.1 ^ E = 1) (fun v => v.2 ^ E = 1)
  rw [card_both_exp, card_left_exp] at h
  omega

/-- **Right reveals for an arbitrary exponent.** -/
theorem card_reveal_right_exp [Fact p.Prime] [Fact q.Prime] (E : ℕ) :
    Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ // v.2 ^ E = 1 ∧ ¬ v.1 ^ E = 1}
      = Nat.gcd E (q - 1) * (p - 1) - Nat.gcd E (p - 1) * Nat.gcd E (q - 1) := by
  have h := card_split (α := (ZMod p)ˣ × (ZMod q)ˣ)
    (fun v => v.2 ^ E = 1) (fun v => v.1 ^ E = 1)
  have hboth : Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ // v.2 ^ E = 1 ∧ v.1 ^ E = 1}
      = Nat.gcd E (p - 1) * Nat.gcd E (q - 1) := by
    rw [← card_both_exp]
    exact Nat.card_congr (Equiv.subtypeEquivRight (fun _ => and_comm))
  have hright : Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ // v.2 ^ E = 1}
      = Nat.gcd E (q - 1) * (p - 1) := by
    have e : {v : (ZMod p)ˣ × (ZMod q)ˣ // v.2 ^ E = 1} ≃
        (ZMod p)ˣ × {y : (ZMod q)ˣ // y ^ E = 1} :=
      { toFun := fun v => (v.1.1, ⟨v.1.2, v.2⟩)
        invFun := fun w => ⟨(w.1, w.2.1), w.2.2⟩
        left_inv := fun v => by cases v; rfl
        right_inv := fun w => by obtain ⟨x, ⟨y, hy⟩⟩ := w; rfl }
    rw [Nat.card_congr e, Nat.card_prod, card_pow_eq_one_units q, Nat.gcd_comm,
      Nat.card_eq_fintype_card, ZMod.card_units p, Nat.mul_comm]
  rw [hboth, hright] at h
  omega

/-- `gcd(E, r-1)·gcd(E, s-1) ≤ gcd(E, r-1)·(s-1)` for a prime `s`. -/
theorem gcd_mul_gcd_le (E r s : ℕ) (hs : s.Prime) :
    Nat.gcd E (r - 1) * Nat.gcd E (s - 1) ≤ Nat.gcd E (r - 1) * (s - 1) :=
  Nat.mul_le_mul_left _ (Nat.le_of_dvd (by have := hs.two_le; omega) (Nat.gcd_dvd_right _ _))

/-- **★ The general-exponent reveal identity.** For every exponent `E`,
the number of units for which exactly one CRT component satisfies `x^E = 1`
(i.e. for which `gcd(a^E - 1, N)` is a proper factor) is

  `R(E) = d_p(q-1) + d_q(p-1) - 2·d_p·d_q`,  `d_p = gcd(E,p-1)`, `d_q = gcd(E,q-1)`. -/
theorem card_revealing_exp [Fact p.Prime] [Fact q.Prime] (E : ℕ) :
    Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ // v.1 ^ E = 1 ∧ ¬ v.2 ^ E = 1}
      + Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ // v.2 ^ E = 1 ∧ ¬ v.1 ^ E = 1}
      = Nat.gcd E (p - 1) * (q - 1) + Nat.gcd E (q - 1) * (p - 1)
          - 2 * (Nat.gcd E (p - 1) * Nat.gcd E (q - 1)) := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  have h1 := gcd_mul_gcd_le E p q hq
  have h2 : Nat.gcd E (p - 1) * Nat.gcd E (q - 1) ≤ Nat.gcd E (q - 1) * (p - 1) := by
    rw [Nat.mul_comm]; exact gcd_mul_gcd_le E q p hp
  rw [card_reveal_left_exp, card_reveal_right_exp]
  omega

/-- **The identity recovers `card_revealing` at `E = N - 1`.** Both gcds collapse to
the Euler gap `g`, giving `g(q-1) + g(p-1) - 2g²`. -/
theorem card_revealing_exp_recovers [Fact p.Prime] [Fact q.Prime] :
    Nat.gcd (p * q - 1) (p - 1) * (q - 1) + Nat.gcd (p * q - 1) (q - 1) * (p - 1)
        - 2 * (Nat.gcd (p * q - 1) (p - 1) * Nat.gcd (p * q - 1) (q - 1))
      = eulerGap p q * (q - 1) + eulerGap p q * (p - 1) - 2 * (eulerGap p q) ^ 2 := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  rw [gcd_exp_left hp.pos hq.pos, gcd_exp_right hp.pos hq.pos, eulerGap,
    Nat.gcd_comm (q - 1) (p - 1), sq]

/-- The two counts agree, as counts: the general identity specialises to the
round-33 law with no extra hypothesis. -/
theorem card_revealing_via_exp [Fact p.Prime] [Fact q.Prime] :
    Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ //
        v.1 ^ (p * q - 1) = 1 ∧ ¬ v.2 ^ (p * q - 1) = 1}
      + Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ //
        v.2 ^ (p * q - 1) = 1 ∧ ¬ v.1 ^ (p * q - 1) = 1}
      = eulerGap p q * (q - 1) + eulerGap p q * (p - 1) - 2 * (eulerGap p q) ^ 2 := by
  rw [card_revealing_exp, card_revealing_exp_recovers]

/-- **The four-cell partition identity.** Writing `P = p-1`, `Q = q-1`, `x = d_p`,
`y = d_q` with `x ≤ P`, `y ≤ Q`: (both liars) + (exactly one) + (neither) = `PQ`. -/
theorem reveal_partition (P Q x y : ℕ) (hx : x ≤ P) (hy : y ≤ Q) :
    x * y + (x * Q + y * P - 2 * (x * y)) + (P - x) * (Q - y) = P * Q := by
  obtain ⟨a, rfl⟩ := Nat.exists_eq_add_of_le hx
  obtain ⟨b, rfl⟩ := Nat.exists_eq_add_of_le hy
  have e1 : x * (y + b) + y * (x + a) - 2 * (x * y) = x * b + y * a := by
    have : x * (y + b) + y * (x + a) = 2 * (x * y) + (x * b + y * a) := by ring
    omega
  rw [e1, Nat.add_sub_cancel_left, Nat.add_sub_cancel_left]
  ring

/-! ## The algebraically solvable extreme -/

/-- **★ Square discriminant.** If `q = k(p-1) + s` then `N = pq` satisfies
`k p² + (s-k) p - N = 0`, and its discriminant is an exact square:
`(s-k)² + 4kN = (2kp + s - k)²`. -/
theorem extreme_discriminant_square (p k s : ℤ) :
    (s - k) ^ 2 + 4 * k * (p * (k * (p - 1) + s)) = (2 * k * p + s - k) ^ 2 := by
  ring

/-- The quadratic relation itself. -/
theorem extreme_quadratic (p k s : ℤ) :
    k * p ^ 2 + (s - k) * p - p * (k * (p - 1) + s) = 0 := by ring

/-- **One integer square root factors the `s = 1` extreme.** If `q = k(p-1) + 1`
with `k ≥ 1`, `p ≥ 1`, then `Nat.sqrt((k-1)² + 4kN) = 2kp - (k-1)` and
`p = (Nat.sqrt((k-1)² + 4kN) + (k-1)) / (2k)`. -/
theorem extreme_factor_by_sqrt (p k : ℕ) (hk : 1 ≤ k) (hp : 1 ≤ p) :
    (Nat.sqrt ((k - 1) ^ 2 + 4 * k * (p * (k * (p - 1) + 1))) + (k - 1)) / (2 * k) = p := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hk
  obtain ⟨p, rfl⟩ := Nat.exists_eq_add_of_le hp
  have hsq : (1 + k - 1) ^ 2 + 4 * (1 + k) * ((1 + p) * ((1 + k) * (1 + p - 1) + 1))
      = (2 * (1 + k) * p + k + 2) ^ 2 := by
    simp only [Nat.add_sub_cancel_left]; ring
  rw [hsq, Nat.sqrt_eq', Nat.add_sub_cancel_left]
  rw [show 2 * (1 + k) * p + k + 2 + k = (1 + p) * (2 * (1 + k)) by ring]
  exact Nat.mul_div_cancel _ (by omega)

/-- **One integer square root factors the `s = -1` extreme** (`q = k(p-1) - 1`, the
`eulergap2` case): `kp² - (k+1)p - N = 0` with discriminant `(2kp - (k+1))²`. -/
theorem extreme_factor_by_sqrt_neg (p k : ℕ) (hk : 1 ≤ k) (hp : 2 ≤ p) :
    (Nat.sqrt ((k + 1) ^ 2 + 4 * k * (p * (k * (p - 1) - 1))) + (k + 1)) / (2 * k) = p := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hk
  obtain ⟨p, rfl⟩ := Nat.exists_eq_add_of_le hp
  have h1 : (1 + k) * (2 + p - 1) - 1 = k + p + k * p := by
    have : (1 + k) * (2 + p - 1) = 1 + (k + p + k * p) := by
      rw [show 2 + p - 1 = 1 + p by omega]; ring
    omega
  have hsq : (1 + k + 1) ^ 2 + 4 * (1 + k) * ((2 + p) * ((1 + k) * (2 + p - 1) - 1))
      = (2 * k * p + 2 * p + 3 * k + 2) ^ 2 := by
    rw [h1]; ring
  rw [hsq, Nat.sqrt_eq']
  rw [show 2 * k * p + 2 * p + 3 * k + 2 + (1 + k + 1) = (2 + p) * (2 * (1 + k)) by ring]
  exact Nat.mul_div_cancel _ (by omega)

/-- **★ The maximal-gap extreme reveals `(p-1)(q-p)` units and is solvable.**
If `(p-1) ∣ (q-1)` (Euler gap `g = p-1`, the largest it can be when `p < q`), the
reveal count is `(p-1)(q-p)` — a density `(q-p)/(q-1) = 1 - 1/k` tending to `1` —
and writing `q = k(p-1) + 1`, the factor `p` is returned by a single integer square
root.  The high-density end of the gcd-reveal family is the algebraically solvable
end. -/
theorem max_reveal_extreme [Fact p.Prime] [Fact q.Prime] (hpq : p < q)
    (hdvd : (p - 1) ∣ (q - 1)) :
    Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ //
        v.1 ^ (p * q - 1) = 1 ∧ ¬ v.2 ^ (p * q - 1) = 1}
      + Nat.card {v : (ZMod p)ˣ × (ZMod q)ˣ //
        v.2 ^ (p * q - 1) = 1 ∧ ¬ v.1 ^ (p * q - 1) = 1} = (p - 1) * (q - p) ∧
    (Nat.sqrt (((q - 1) / (p - 1) - 1) ^ 2 + 4 * ((q - 1) / (p - 1)) * (p * q))
        + ((q - 1) / (p - 1) - 1)) / (2 * ((q - 1) / (p - 1))) = p := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  have hp2 := hp.two_le
  have hg : eulerGap p q = p - 1 := Nat.gcd_eq_left hdvd
  obtain ⟨k, hk⟩ := hdvd
  have hkpos : 1 ≤ k := by
    rcases Nat.eq_zero_or_pos k with h | h
    · subst h; omega
    · exact h
  have hkdiv : (q - 1) / (p - 1) = k := by
    rw [hk]; exact Nat.mul_div_cancel_left _ (by omega)
  have hqk : q = k * (p - 1) + 1 := by rw [Nat.mul_comm]; omega
  refine ⟨?_, ?_⟩
  · rw [card_revealing, hg]
    have hqp : q - 1 = (p - 1) + (q - p) := by omega
    rw [hqp, sq]
    have : (p - 1) * (p - 1 + (q - p)) + (p - 1) * (p - 1) = 2 * ((p - 1) * (p - 1))
        + (p - 1) * (q - p) := by ring
    omega
  · rw [hkdiv, hqk]
    exact extreme_factor_by_sqrt p k hkpos (by omega)

end AsymmetricExponent