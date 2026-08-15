import Mathlib
import Physics.DerivedModulusNoGo

/-!
# The barrier at its natural level of generality: congruence transport

Every proof of the polynomial barrier in this development uses exactly one
property of the modulus map: `a - b ∣ F(a) - F(b)`.  This file isolates that
property, proves the barrier and its exact classification for the whole class,
and shows the class is a subring of `ℤ → ℤ` closed under composition — while
the exponential modulus `2^N - 1` (which does leak, see
`Physics.DerivedModulusExponentialSharp`) is *not* in the class.  So the class
of congruence-transporting maps is precisely the natural boundary of the
MULTIMOD no-go.

## Main results

* `Physics.DerivedModulus.Transports` and `polynomial_transports`.
* `Physics.DerivedModulus.gcd_transport_eq` : `gcd(N, F N) = gcd(N, F 0)`.
* `Physics.DerivedModulus.transport_coprime_iff` : universal coprimality holds
  iff `F 0` is a unit.
* `Physics.DerivedModulus.transportsSubring` and `Transports.comp` : closure
  under `+`, `*`, `-` and composition.
* `Physics.DerivedModulus.expModulus_not_transports` : the exponential modulus
  is outside the class, which is exactly why it can leak.
-/

namespace Physics.DerivedModulus

open Polynomial

/-- A modulus construction *transports congruences* if `a ≡ b (mod m)` always
implies `F a ≡ F b (mod m)`, equivalently `a - b ∣ F a - F b`. -/
def Transports (F : ℤ → ℤ) : Prop := ∀ a b : ℤ, (a - b) ∣ F a - F b

/-- Polynomial moduli transport congruences. -/
theorem polynomial_transports (f : ℤ[X]) : Transports (fun N => f.eval N) :=
  fun a b => Polynomial.sub_dvd_eval_sub a b f

/-- Congruence transport in the `Int.ModEq` formulation. -/
theorem Transports.modEq {F : ℤ → ℤ} (hF : Transports F) {a b m : ℤ}
    (h : a ≡ b [ZMOD m]) : F a ≡ F b [ZMOD m] := by
  have hm : m ∣ a - b := h.symm.dvd
  have hd : m ∣ F b - F a := by
    simpa using dvd_neg.mpr (hm.trans (hF a b))
  exact Int.modEq_iff_dvd.mpr hd

/-- **The barrier, abstractly.**  For any congruence-transporting modulus the
overlap with `N` is frozen at `F 0`. -/
theorem gcd_transport_eq {F : ℤ → ℤ} (hF : Transports F) (N : ℤ) :
    Int.gcd N (F N) = Int.gcd N (F 0) := by
  have h : N ∣ F N - F 0 := by simpa using hF N 0
  have key : ∀ u v : ℤ, N ∣ u - v → Int.gcd N u ∣ Int.gcd N v := by
    intro u v huv
    have h1 : (Int.gcd N u : ℤ) ∣ N := Int.gcd_dvd_left N u
    have h2 : (Int.gcd N u : ℤ) ∣ u := Int.gcd_dvd_right N u
    have h4 : (Int.gcd N u : ℤ) ∣ v := by simpa using dvd_sub h2 (h1.trans huv)
    exact Int.dvd_gcd h1 h4
  exact Nat.dvd_antisymm (key _ _ h) (key _ _ (by simpa using dvd_neg.mpr h))

/-- **Exact classification for the whole class.**  A congruence-transporting
modulus is coprime to `N` for every `N` iff its value at `0` is a unit. -/
theorem transport_coprime_iff {F : ℤ → ℤ} (hF : Transports F) :
    (∀ N : ℤ, Int.gcd N (F N) = 1) ↔ (F 0 = 1 ∨ F 0 = -1) := by
  constructor
  · intro h
    have h0 := h 0
    rw [gcd_transport_eq hF 0] at h0
    have : (F 0).natAbs = 1 := by simpa [Int.gcd] using h0
    rcases Int.natAbs_eq (F 0) with h' | h' <;> rw [this] at h'
    · exact Or.inl (by simpa using h')
    · exact Or.inr (by simpa using h')
  · intro h0 N
    rw [gcd_transport_eq hF N]
    rcases h0 with h | h <;> rw [h] <;> simp [Int.gcd]

/-! ## Closure properties -/

theorem Transports.add {F G : ℤ → ℤ} (hF : Transports F) (hG : Transports G) :
    Transports (F + G) := by
  intro a b
  have : F a + G a - (F b + G b) = (F a - F b) + (G a - G b) := by ring
  simpa [Pi.add_apply, this] using dvd_add (hF a b) (hG a b)

theorem Transports.mul {F G : ℤ → ℤ} (hF : Transports F) (hG : Transports G) :
    Transports (F * G) := by
  intro a b
  have hsplit : F a * G a - F b * G b = (F a - F b) * G a + F b * (G a - G b) := by ring
  simpa [Pi.mul_apply, hsplit] using
    dvd_add ((hF a b).mul_right _) ((hG a b).mul_left _)

theorem Transports.neg {F : ℤ → ℤ} (hF : Transports F) : Transports (-F) := by
  intro a b
  have : -F a - -F b = -(F a - F b) := by ring
  simpa [Pi.neg_apply, this] using (hF a b).neg_right

theorem transports_const (c : ℤ) : Transports (fun _ => c) := by
  intro a b; simp

theorem transports_id : Transports (fun N => N) := fun _ _ => dvd_rfl

/-- Congruence-transporting maps form a subring of `ℤ → ℤ`. -/
def transportsSubring : Subring (ℤ → ℤ) where
  carrier := {F | Transports F}
  one_mem' := transports_const 1
  zero_mem' := transports_const 0
  add_mem' := Transports.add
  mul_mem' := Transports.mul
  neg_mem' := Transports.neg

/-- …and they are closed under composition. -/
theorem Transports.comp {F G : ℤ → ℤ} (hF : Transports F) (hG : Transports G) :
    Transports (F ∘ G) := fun a b => (hG a b).trans (hF (G a) (G b))

/-! ## The boundary of the class -/

/-- The exponential derived modulus `N ↦ 2^|N| - 1`. -/
def expModulus : ℤ → ℤ := fun N => 2 ^ N.natAbs - 1

/-- **The exponential modulus is outside the class** — which is exactly why it
can share primes with `N` (see `Physics.DerivedModulusExponentialSharp`): the
witness is `a = 6`, `b = 0`, where `6 ∤ 63`. -/
theorem expModulus_not_transports : ¬ Transports expModulus := by
  intro h
  have h6 := h 6 0
  norm_num [expModulus] at h6

/-- Summary of the boundary: the barrier holds for every congruence-transporting
modulus with unit value at `0`, and fails outside the class. -/
theorem transport_boundary :
    (∀ F : ℤ → ℤ, Transports F → (F 0 = 1 ∨ F 0 = -1) → ∀ N : ℤ, Int.gcd N (F N) = 1) ∧
    ¬ Transports expModulus :=
  ⟨fun _ hF h0 => (transport_coprime_iff hF).mpr h0, expModulus_not_transports⟩

end Physics.DerivedModulus