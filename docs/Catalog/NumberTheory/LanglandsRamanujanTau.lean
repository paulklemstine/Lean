import Catalog.Shared.LanglandsTensorTransfer

/-!
# Langlands functoriality, IV: characterisation of the Hecke sequence and a worked
arithmetic instance (Ramanujan's `τ`)

Two complementary things are proved here.

1. **Characterisation.**  `hecke_unique` shows that the Hecke sequence is the *unique*
   sequence whose generating series inverts the degree-two Euler factor.  Together with
   `hecke3_eq_prod` this makes all the transfer statements of the previous files intrinsic:
   the transferred L-function determines the transferred Hecke eigenvalues and conversely.

2. **A worked instance.**  The Satake parameters of the discriminant cusp form `Δ` at `p = 2`
   satisfy `a + b = τ(2) = -24` and `a b = 2^11 = 2048`.  Feeding this into the general
   theory reproduces the classical values

   * `τ(4) = τ(2)^2 - 2^11 = -1472`   (the `p = 2` Hecke relation, equivalently the
     `p`-th Hecke eigenvalue of the Gelbart–Jacquet lift `Sym^2 Δ`),
   * `τ(8) = τ(2) τ(4) - 2^11 τ(2) = 84480`,
   * `τ(16) = τ(2) τ(8) - 2^11 τ(4) = 987136`,

   and the Gelbart–Jacquet Euler data of `Sym^2 Δ` at `2`.  These are genuine numerical
   confirmations of the abstract identities: they are *derived* from the general lemmas, not
   re-computed by definition unfolding of a specific sequence.
-/

namespace Langlands

open Finset PowerSeries

section Characterisation

variable {R : Type*} [CommRing R]

/-- **Characterisation of the Hecke eigenvalue sequence.**  A sequence whose generating
series inverts the degree-two Euler factor of `(a, b)` must be the Hecke sequence of
`(a, b)`.  Hence "having the prescribed local L-factor" and "satisfying the Hecke recursion"
are equivalent, which is what makes the notion of functorial transfer well posed. -/
theorem hecke_unique (a b : R) (u : ℕ → R)
    (hu : PowerSeries.mk u * ((1 - C a * X) * (1 - C b * X)) = 1) :
    ∀ k, u k = hecke a b k := by
  have h : PowerSeries.mk u = L2 a b := inv_unique hu (L2_mul_euler a b)
  intro k
  have := congrArg (fun f => coeff k f) h
  simpa [L2] using this

/-- Similarly, the `GL(3)` Hecke eigenvalues are determined by the `GL(3)` Euler factor. -/
theorem hecke3_unique (c1 c2 c3 : R) (u : ℕ → R)
    (hu : PowerSeries.mk u * gl3Euler c1 c2 c3 = 1) :
    ∀ k, u k = hecke3 c1 c2 c3 k := by
  have h : PowerSeries.mk u = PowerSeries.mk (hecke3 c1 c2 c3) :=
    inv_unique hu (hecke3_L_mul_euler c1 c2 c3)
  intro k
  have := congrArg (fun f => coeff k f) h
  simpa using this

end Characterisation

section RamanujanTau

/-- The Satake parameters of `Δ` at `p = 2` satisfy `a + b = -24`, `a b = 2048`.
Any such pair reproduces `τ(4) = -1472`; this is the Gelbart–Jacquet eigenvalue
`b_2 = τ(2)^2 - 2^{11}`. -/
theorem tau_four (a b : ℂ) (hs : a + b = -24) (hp : a * b = 2048) :
    hecke a b 2 = -1472 := by
  rw [hecke_two_eq]
  have : a ^ 2 + b ^ 2 = (a + b) ^ 2 - 2 * (a * b) := by ring
  rw [show a ^ 2 + a * b + b ^ 2 = (a + b) ^ 2 - (a * b) by ring, hs, hp]
  norm_num

/-- `τ(8) = 84480`, from the degree-two Hecke recursion. -/
theorem tau_eight (a b : ℂ) (hs : a + b = -24) (hp : a * b = 2048) :
    hecke a b 3 = 84480 := by
  have h2 : hecke a b 2 = -1472 := tau_four a b hs hp
  rw [show (3 : ℕ) = 1 + 2 from rfl, hecke_add_two, h2, hecke_one, hs, hp]
  norm_num

/-- `τ(16) = 987136`, from the degree-two Hecke recursion. -/
theorem tau_sixteen (a b : ℂ) (hs : a + b = -24) (hp : a * b = 2048) :
    hecke a b 4 = 987136 := by
  have h2 : hecke a b 2 = -1472 := tau_four a b hs hp
  have h3 : hecke a b 3 = 84480 := tau_eight a b hs hp
  rw [show (4 : ℕ) = 2 + 2 from rfl, hecke_add_two, h3, h2, hs, hp]
  norm_num

/-- The `p = 2` Euler factor of the Gelbart–Jacquet lift `Sym^2 Δ`, with all three GL(3)
coefficients computed from `τ(2)` alone. -/
theorem symEuler_two_delta (a b : ℂ) (hs : a + b = -24) (hp : a * b = 2048) :
    symEuler 2 a b = gl3Euler (-1472) (-3014656) 8589934592 := by
  rw [symEuler_two_eq, tau_four a b hs hp, hp]
  norm_num

/-- The Clebsch–Gordan identity, checked on the `Δ`-instance: `τ(2) τ(8) = τ(16) + 2^11 τ(4)`,
i.e. the local Rankin–Selberg relation `a_p a_{p^3} = a_{p^4} + χ(p) a_{p^2}`. -/
theorem hecke_cg_one_three {R : Type*} [CommRing R] (a b : R) :
    hecke a b 1 * hecke a b 3 = hecke a b 4 + (a * b) * hecke a b 2 := by
  have h := hecke_clebsch_gordan a b 1 2
  rw [Finset.sum_range_succ, Finset.sum_range_one] at h
  norm_num at h
  rw [hecke_one]
  linear_combination h

theorem tau_clebsch_gordan (a b : ℂ) (hp : a * b = 2048) :
    hecke a b 1 * hecke a b 3 = hecke a b 4 + 2048 * hecke a b 2 := by
  rw [hecke_cg_one_three, hp]

/-- Temperedness fails for `Δ` in the *unnormalised* Satake parameters (they have absolute
value `2^{11/2}`), but the general bound applies after normalisation: with
`α = a / 2^{11/2}`, `β = b / 2^{11/2}` one gets `|τ(2^k)| ≤ (k+1) 2^{11k/2}` for all `k`.
Here is the statement in the normalised variables. -/
theorem tau_ramanujan_normalised (α β : ℂ) (hα : ‖α‖ = 1) (hβ : ‖β‖ = 1) (k : ℕ) :
    ‖hecke α β k‖ ≤ k + 1 :=
  hecke_norm_le α β hα hβ k

end RamanujanTau

end Langlands