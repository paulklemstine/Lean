import Pythagorean.ConicKernelDefect

/-!
# The Fermat–conic pencil `A xᵖ + B yᵖ = C zᵖ` and its equal-legs pattern

`Pythagorean.FermatKernelSpectrum` proves that for every exponent `p ≥ 2` the equal-legs
pattern `![0,0,2]` is blocked for `xᵖ + yᵖ = zᵖ`, the proof being a `2`-adic valuation
argument.  This file shows that this is *not* a fact about the exponent but about the
coefficient `C = 1`: with the same exponent `p = 3` and the coefficient `C = 16` the
equal-legs pattern is realised, by `2³ + 2³ = 16 · 1³`.

The engine is a descent theorem generalising `PythagoreanKernel.isSquare_of_mul_sq_eq_sq`
from squares to arbitrary `p`-th powers.

Main results.

* `FermatConic.exists_pow_of_mul_pow_eq_pow` — if `k · aᵖ = cᵖ` with `a ≠ 0` then `k` is a
  `p`-th power.
* `FermatConic.mul_pow_eq_mul_pow_ne_iff` — for `Q ≠ 0` and `p ≥ 1`, `P uᵖ = Q vᵖ` has a
  solution with `u ≠ 0`, `u ≠ v` iff `P · Q^(p-1)` is a `p`-th power and `P ≠ Q`.
* `FermatConic.two_mul_pow_ne_pow'` — a one-line re-derivation of
  `FermatKernel.two_mul_pow_ne_pow` from the descent theorem.
* `FermatConic.isosceles_iff` — the exact criterion for the equal-legs pattern of
  `A xᵖ + B yᵖ = C zᵖ`.
* `FermatConic.isosceles_blocked_of_coeff_one` and `FermatConic.isosceles_cubic_sixteen` —
  the two ends of the story: blocked for every `p ≥ 2` when `A = B = C = 1`, realised at
  `p = 3`, `C = 16`.
-/

open KernelPattern PythagoreanKernel ConicKernel

namespace FermatConic

/-! ## Descent for `p`-th powers -/

/-- **Descent.**  If `k · aᵖ = cᵖ` with `a ≠ 0`, then `k` is a `p`-th power.  (Divide out
`gcd a c`; the leg becomes a unit because it is coprime to the hypotenuse.) -/
theorem exists_pow_of_mul_pow_eq_pow {k a c p : ℕ} (ha : a ≠ 0) (h : k * a ^ p = c ^ p) :
    ∃ r, k = r ^ p := by
  rcases Nat.eq_zero_or_pos p with rfl | hp
  · exact ⟨k, by simpa using h⟩
  set g := Nat.gcd a c with hg
  have hg0 : 0 < g := Nat.gcd_pos_of_pos_left _ (Nat.pos_of_ne_zero ha)
  set a' := a / g with ha'
  set c' := c / g with hc'
  have hga : g * a' = a := Nat.mul_div_cancel' (Nat.gcd_dvd_left a c)
  have hgc : g * c' = c := Nat.mul_div_cancel' (Nat.gcd_dvd_right a c)
  have hcop : Nat.Coprime a' c' := Nat.coprime_div_gcd_div_gcd hg0
  have key : k * a' ^ p = c' ^ p := by
    have h2 : g ^ p * (k * a' ^ p) = g ^ p * c' ^ p := by
      calc g ^ p * (k * a' ^ p) = k * (g * a') ^ p := by ring
        _ = k * a ^ p := by rw [hga]
        _ = c ^ p := h
        _ = (g * c') ^ p := by rw [hgc]
        _ = g ^ p * c' ^ p := by ring
    exact Nat.eq_of_mul_eq_mul_left (by positivity) h2
  have hdvd : a' ^ p ∣ c' ^ p := ⟨k, by rw [← key]; ring⟩
  have ha'1 : a' = 1 := by
    have hcp : Nat.Coprime (a' ^ p) (c' ^ p) := Nat.Coprime.pow p p hcop
    have h1 : a' ^ p = 1 := Nat.Coprime.eq_one_of_dvd hcp hdvd
    exact (Nat.pow_eq_one.mp h1).resolve_right (by omega)
  exact ⟨c', by rw [← key, ha'1, one_pow, mul_one]⟩

/-- Solvability of `P uᵖ = Q vᵖ` with `u ≠ 0`, in terms of a `p`-th power condition. -/
theorem mul_pow_eq_mul_pow_iff {P Q p : ℕ} (hp : p ≠ 0) (hQ : Q ≠ 0) :
    (∃ u v : ℕ, u ≠ 0 ∧ P * u ^ p = Q * v ^ p) ↔ ∃ r, P * Q ^ (p - 1) = r ^ p := by
  have hQp : Q ^ (p - 1) * Q = Q ^ p := by
    rw [← pow_succ]
    congr 1
    omega
  constructor
  · rintro ⟨u, v, hu, h⟩
    refine exists_pow_of_mul_pow_eq_pow (a := u) (c := Q * v) hu ?_
    calc P * Q ^ (p - 1) * u ^ p = Q ^ (p - 1) * (P * u ^ p) := by ring
      _ = Q ^ (p - 1) * (Q * v ^ p) := by rw [h]
      _ = (Q ^ (p - 1) * Q) * v ^ p := by ring
      _ = Q ^ p * v ^ p := by rw [hQp]
      _ = (Q * v) ^ p := by ring
  · rintro ⟨r, hr⟩
    refine ⟨Q, r, hQ, ?_⟩
    calc P * Q ^ p = Q * (P * Q ^ (p - 1)) := by rw [← hQp]; ring
      _ = Q * r ^ p := by rw [hr]

/-- The non-degenerate version: `u ≠ v` is possible exactly when moreover `P ≠ Q`. -/
theorem mul_pow_eq_mul_pow_ne_iff {P Q p : ℕ} (hp : p ≠ 0) (hQ : Q ≠ 0) :
    (∃ u v : ℕ, u ≠ 0 ∧ u ≠ v ∧ P * u ^ p = Q * v ^ p) ↔
      (∃ r, P * Q ^ (p - 1) = r ^ p) ∧ P ≠ Q := by
  have hQp : Q ^ (p - 1) * Q = Q ^ p := by
    rw [← pow_succ]
    congr 1
    omega
  constructor
  · rintro ⟨u, v, hu, huv, h⟩
    refine ⟨(mul_pow_eq_mul_pow_iff hp hQ).1 ⟨u, v, hu, h⟩, ?_⟩
    rintro rfl
    have : u ^ p = v ^ p := Nat.eq_of_mul_eq_mul_left (Nat.pos_of_ne_zero hQ) h
    exact huv (Nat.pow_left_injective (by omega) this)
  · rintro ⟨⟨r, hr⟩, hPQ⟩
    refine ⟨Q, r, hQ, ?_, ?_⟩
    · rintro rfl
      have hQpos : 0 < Q ^ (p - 1) := Nat.pow_pos (Nat.pos_of_ne_zero hQ)
      refine hPQ (Nat.eq_of_mul_eq_mul_right hQpos ?_)
      calc P * Q ^ (p - 1) = Q ^ p := hr
        _ = Q ^ (p - 1) * Q := hQp.symm
        _ = Q * Q ^ (p - 1) := by ring
    · calc P * Q ^ p = Q * (P * Q ^ (p - 1)) := by rw [← hQp]; ring
        _ = Q * r ^ p := by rw [hr]

/-- `2` is not a `p`-th power for `p ≥ 2`. -/
theorem not_exists_pow_two {p : ℕ} (hp : 2 ≤ p) : ¬ ∃ r, (2 : ℕ) = r ^ p := by
  rintro ⟨r, hr⟩
  match r, hr with
  | 0, hr => simp [zero_pow (show p ≠ 0 by omega)] at hr
  | 1, hr => simp at hr
  | (n + 2), hr =>
      have hle : (n + 2) ^ 2 ≤ (n + 2) ^ p := Nat.pow_le_pow_right (by omega) hp
      have h4 : 4 ≤ (n + 2) ^ 2 := by
        calc (4 : ℕ) = 2 ^ 2 := by norm_num
          _ ≤ (n + 2) ^ 2 := Nat.pow_le_pow_left (by omega) 2
      omega

/-- A re-derivation of `FermatKernel.two_mul_pow_ne_pow` from the descent theorem: no
`2`-adic valuation computation is needed. -/
theorem two_mul_pow_ne_pow' {p a c : ℕ} (hp : 2 ≤ p) (ha : a ≠ 0) : 2 * a ^ p ≠ c ^ p := fun h =>
  not_exists_pow_two hp (exists_pow_of_mul_pow_eq_pow ha h)

/-! ## The Fermat–conic pencil -/

/-- The pencil `A xᵖ + B yᵖ = C zᵖ`, as a predicate on triples. -/
def IsFermatConic (p A B C : ℕ) (t : Fin 3 → ℕ) : Prop :=
  A * t 0 ^ p + B * t 1 ^ p = C * t 2 ^ p

instance (p A B C : ℕ) : DecidablePred (IsFermatConic p A B C) :=
  fun t => inferInstanceAs (Decidable (A * t 0 ^ p + B * t 1 ^ p = C * t 2 ^ p))

theorem isFermatConic_iff (p A B C a b c : ℕ) :
    IsFermatConic p A B C ![a, b, c] ↔ A * a ^ p + B * b ^ p = C * c ^ p := Iff.rfl

/-- **The equal-legs criterion for the Fermat–conic pencil.**  The pattern `![0,0,2]` is
realised iff `(A+B)·C^(p-1)` is a `p`-th power and `A + B ≠ C`. -/
theorem isosceles_iff {p A B C : ℕ} (hp : p ≠ 0) (hC : C ≠ 0) :
    (∃ t : Fin 3 → ℕ, IsFermatConic p A B C t ∧ canon t = ![0, 0, 2]) ↔
      (∃ r, (A + B) * C ^ (p - 1) = r ^ p) ∧ A + B ≠ C := by
  constructor
  · rintro ⟨t, ht, hcan⟩
    obtain ⟨h01, h02⟩ := (canon_002_iff t).1 hcan
    have ht' : (A + B) * t 0 ^ p = C * t 2 ^ p := by
      have h := ht
      rw [IsFermatConic, ← h01] at h
      rw [add_mul]
      exact h
    have ha : t 0 ≠ 0 := by
      rintro h0
      rw [h0, zero_pow hp, mul_zero] at ht'
      have h2 : t 2 = 0 := by
        rcases Nat.mul_eq_zero.1 ht'.symm with h | h
        · exact absurd h hC
        · exact pow_eq_zero_iff hp |>.1 h
      exact h02 (by rw [h0, h2])
    exact (mul_pow_eq_mul_pow_ne_iff hp hC).1 ⟨t 0, t 2, ha, h02, ht'⟩
  · intro h
    obtain ⟨a, z, ha, haz, hz⟩ := (mul_pow_eq_mul_pow_ne_iff hp hC).2 h
    refine ⟨![a, a, z], ?_, (canon_002_iff _).2 ⟨rfl, ?_⟩⟩
    · show A * a ^ p + B * a ^ p = C * z ^ p
      rw [← hz, add_mul]
    · simpa using haz

/-- For the classical Fermat equation (`A = B = C = 1`) the equal-legs pattern is blocked at
every exponent `p ≥ 2`, recovering `FermatKernel.canon_ne_isosceles`. -/
theorem isosceles_blocked_of_coeff_one {p : ℕ} (hp : 2 ≤ p) :
    ¬ ∃ t : Fin 3 → ℕ, IsFermatConic p 1 1 1 t ∧ canon t = ![0, 0, 2] := by
  rw [isosceles_iff (by omega) one_ne_zero]
  rintro ⟨hsq, -⟩
  exact not_exists_pow_two hp (by simpa using hsq)

/-- **The blocking is a fact about the coefficient, not the exponent.**  At the cubic
exponent `p = 3` with `C = 16` the equal-legs pattern *is* realised, by `2³ + 2³ = 16·1³`. -/
theorem isosceles_cubic_sixteen :
    ∃ t : Fin 3 → ℕ, IsFermatConic 3 1 1 16 t ∧ canon t = ![0, 0, 2] :=
  ⟨![2, 2, 1], by decide, by decide⟩

/-- The criterion, checked against the explicit witness: `2 · 16² = 8³` and `2 ≠ 16`. -/
theorem isosceles_cubic_sixteen_criterion :
    (∃ r, (1 + 1) * (16 : ℕ) ^ (3 - 1) = r ^ 3) ∧ (1 : ℕ) + 1 ≠ 16 :=
  ⟨⟨8, by norm_num⟩, by norm_num⟩

/-- **Diagonal degeneracy for the pencil.**  Even when the `p`-th power condition holds, the
pattern is blocked as soon as `A + B = C`, i.e. as soon as `(1,1,1)` lies on the curve.  For
example the cubic `x³ + y³ = 2z³` satisfies the power condition (`2·2² = 2³`) yet has no
equal-legs point with distinct hypotenuse. -/
theorem isosceles_blocked_cubic_two :
    ¬ ∃ t : Fin 3 → ℕ, IsFermatConic 3 1 1 2 t ∧ canon t = ![0, 0, 2] := by
  rw [isosceles_iff (by norm_num) (by norm_num)]
  rintro ⟨-, hne⟩
  exact hne (by norm_num)

theorem isosceles_cubic_two_power_condition : ∃ r, (1 + 1) * (2 : ℕ) ^ (3 - 1) = r ^ 3 :=
  ⟨2, by norm_num⟩

/-- Summary of the cycle: at the fixed exponent `p = 3` the equal-legs pattern of the pencil
`x³ + y³ = C z³` is blocked for `C = 1` (power obstruction), blocked for `C = 2`
(degeneracy obstruction, even though the power condition holds), and realised for `C = 16`.
So the two obstructions are genuinely independent. -/
theorem cubic_pencil_trichotomy :
    (¬ ∃ t : Fin 3 → ℕ, IsFermatConic 3 1 1 1 t ∧ canon t = ![0, 0, 2]) ∧
      (¬ ∃ t : Fin 3 → ℕ, IsFermatConic 3 1 1 2 t ∧ canon t = ![0, 0, 2]) ∧
      (∃ r, (1 + 1) * (2 : ℕ) ^ (3 - 1) = r ^ 3) ∧
      (∃ t : Fin 3 → ℕ, IsFermatConic 3 1 1 16 t ∧ canon t = ![0, 0, 2]) :=
  ⟨isosceles_blocked_of_coeff_one (by norm_num), isosceles_blocked_cubic_two,
    isosceles_cubic_two_power_condition, isosceles_cubic_sixteen⟩

end FermatConic