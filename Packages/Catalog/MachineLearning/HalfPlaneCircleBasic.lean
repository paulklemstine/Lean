import Mathlib

/-!
# The half-plane circle count: basic definitions

For a modulus `N` we study the *modular circle*

  `Circle(N) = {(x, y) ∈ [0,N)² : x² + y² ≡ 1 (mod N)}`

together with the **non-CRT-separable** half-plane cut `x + y < N/2`
(the sum `x + y` is taken as an *integer*, not modulo `N`, which is exactly
what destroys separability).

This file sets up:

* `circleFinset N`  — the circle as a finite set of pairs of naturals,
* `circleCount N`   — its cardinality `C(N)`,
* `halfPlaneCount N`— the count `H(N)` of circle points in the low half-plane
  `2(x+y) < N`,
* `highCount N`     — the count of circle points with `2(x+y) > 3N`,
* `unitRootCount N` — the number of square roots of `1` below `N/2`,

and the bridge to the algebraic description of the circle inside `ZMod N`,
which is what makes the Chinese Remainder analysis possible.
-/

namespace HalfPlane

open Finset

/-- The modular circle `x² + y² ≡ 1 (mod N)` with representatives in `[0,N)`. -/
def circleFinset (N : ℕ) : Finset (ℕ × ℕ) :=
  (Finset.range N ×ˢ Finset.range N).filter (fun p => (p.1 ^ 2 + p.2 ^ 2) % N = 1 % N)

/-- `C(N)`: the number of points of the modular circle. -/
def circleCount (N : ℕ) : ℕ := (circleFinset N).card

/-- `H(N)`: the number of circle points in the half-plane `x + y < N/2`. -/
def halfPlaneCount (N : ℕ) : ℕ :=
  ((circleFinset N).filter (fun p => 2 * (p.1 + p.2) < N)).card

/-- The number of circle points in the *opposite* corner `x + y > 3N/2`. -/
def highCount (N : ℕ) : ℕ :=
  ((circleFinset N).filter (fun p => 3 * N < 2 * (p.1 + p.2))).card

/-- The number of square roots of `1` modulo `N` lying below `N/2`. -/
def unitRootCount (N : ℕ) : ℕ :=
  ((Finset.range N).filter (fun u => 2 * u < N ∧ u ^ 2 % N = 1 % N)).card

/-- The circle described inside `ZMod N`. -/
def circleZ (N : ℕ) [NeZero N] : Finset (ZMod N × ZMod N) :=
  Finset.univ.filter (fun q => q.1 ^ 2 + q.2 ^ 2 = 1)

section Basic

variable {N : ℕ}

lemma mem_circleFinset {N : ℕ} {p : ℕ × ℕ} :
    p ∈ circleFinset N ↔ p.1 < N ∧ p.2 < N ∧ (p.1 ^ 2 + p.2 ^ 2) % N = 1 % N := by
  simp [circleFinset, Finset.mem_filter, Finset.mem_product, and_assoc]

lemma mem_circleZ {N : ℕ} [NeZero N] {q : ZMod N × ZMod N} :
    q ∈ circleZ N ↔ q.1 ^ 2 + q.2 ^ 2 = 1 := by
  simp [circleZ]

/-- Congruence form of membership: for representatives in `[0,N)`, being on the
circle is the same as the corresponding pair in `ZMod N` being on the circle. -/
lemma circle_cast_iff (N : ℕ) (a b : ℕ) :
    ((a ^ 2 + b ^ 2) % N = 1 % N) ↔ ((a : ZMod N) ^ 2 + (b : ZMod N) ^ 2 = 1) := by
  have h : ((a ^ 2 + b ^ 2 : ℕ) : ZMod N) = ((1 : ℕ) : ZMod N) ↔
      (a ^ 2 + b ^ 2) ≡ 1 [MOD N] := by
    exact (ZMod.natCast_eq_natCast_iff _ _ _)
  rw [Nat.ModEq] at h
  rw [← h]
  push_cast
  simp

/-- The natural-number model and the `ZMod` model of the circle have the same size. -/
theorem circleCount_eq_card_circleZ (N : ℕ) [NeZero N] :
    circleCount N = (circleZ N).card := by
  refine Finset.card_bij (fun p _ => ((p.1 : ZMod N), (p.2 : ZMod N))) ?_ ?_ ?_
  · intro p hp
    rw [mem_circleFinset] at hp
    rw [mem_circleZ]
    exact (circle_cast_iff N p.1 p.2).mp hp.2.2
  · intro p hp q hq hpq
    rw [mem_circleFinset] at hp hq
    have h1 : (p.1 : ZMod N) = (q.1 : ZMod N) := congrArg Prod.fst hpq
    have h2 : (p.2 : ZMod N) = (q.2 : ZMod N) := congrArg Prod.snd hpq
    have e1 : p.1 = q.1 := by
      have := congrArg ZMod.val h1
      rwa [ZMod.val_natCast_of_lt hp.1, ZMod.val_natCast_of_lt hq.1] at this
    have e2 : p.2 = q.2 := by
      have := congrArg ZMod.val h2
      rwa [ZMod.val_natCast_of_lt hp.2.1, ZMod.val_natCast_of_lt hq.2.1] at this
    exact Prod.ext e1 e2
  · intro q hq
    rw [mem_circleZ] at hq
    refine ⟨(q.1.val, q.2.val), ?_, ?_⟩
    · rw [mem_circleFinset]
      refine ⟨ZMod.val_lt _, ZMod.val_lt _, ?_⟩
      rw [circle_cast_iff]
      simpa using hq
    · simp

end Basic

/-! ### Small-case data (Lab Notes)

```
N :  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20
C :  1  2  4  8  4  8  8 16 12  8 12 32 12 16 16 32 16 24 20 32
H :  1  0  2  2  2  2  2  4  4  2  2  6  2  2  4  6  3  4  4  6
```
-/

example : circleCount 15 = 16 := by decide
example : circleCount 3 * circleCount 5 = 16 := by decide
example : halfPlaneCount 35 = 6 := by decide
example : halfPlaneCount 5 * halfPlaneCount 7 = 4 := by decide

end HalfPlane