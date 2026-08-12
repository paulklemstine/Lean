/-
# The birthday-bound hierarchy of collision-based factoring

Companion to `Catalog/Applications/ThreeSumFactoring.lean`.

A *level-`r` collision search* modulo an unknown prime `p ∣ N` picks `r` families
`A 0, …, A (r-1)` of `k` residues each and looks for two distinct selections
`x ≠ y` with `∑ j, A j (x j) = ∑ j, A j (y j)` in `ZMod p`; such a collision is a
nonzero integer combination divisible by `p`, hence (Theorem
`ThreeSumFactoring.reveal_of_pos_lt`) a factor reveal.

* `r = 2` is the sumset / birthday-paradox level (`a + b ≡ c + d`),
* `r = 3` is the 3SUM level (`a + b + c ≡ a' + b' + c'`),
* `r` large is the general `r`-SUM level.

The main results are:

* `collisionGuaranteed_iff` — a level-`r` search of family size `k` is guaranteed
  to succeed **iff** `p < k ^ r`.  The forward direction is pigeonhole; the
  converse is a sharpness construction (base-`k` digits) showing that with
  `k ^ r ≤ p` an adversary can make all `k ^ r` sums distinct.
* `collisionGuaranteed_mono_level` — raising the level never costs more elements:
  the required `k` drops like `p ^ (1/r)`.  This is the "exponent improves
  `1/2 → 1/3`" row of the hierarchy table.
* `birthday_barrier_sqrt` — nevertheless the *work* `k ^ r` (the number of
  selections examined) always exceeds `p`, so for a balanced semiprime
  `N = p*q`, `q ≤ 2p`, every level satisfies `N < 2 * (k ^ r) ^ 2`: the `√N`
  barrier is level-independent.
* `evaluation_barrier` — the same bound for the third row of the table, an
  exhaustive evaluation search that must hit a prescribed residue class.
-/
import Mathlib
import Applications.ThreeSumFactoring

namespace BirthdayBoundHierarchy

open Finset

/-! ## Level-`r` collisions -/

/-- The sum of the selection `x` against the family system `A`. -/
def selSum {p k r : ℕ} (A : Fin r → Fin k → ZMod p) (x : Fin r → Fin k) : ZMod p :=
  ∑ j, A j (x j)

/-- A level-`r` search with family size `k` is *guaranteed* modulo `p` if **every**
system of `r` families of `k` residues admits two distinct selections with equal
sum. -/
def CollisionGuaranteed (p k r : ℕ) : Prop :=
  ∀ A : Fin r → Fin k → ZMod p, ∃ x y : Fin r → Fin k, x ≠ y ∧ selSum A x = selSum A y

/-- **Pigeonhole (birthday) direction.**  If the number `k ^ r` of selections
exceeds the modulus `p`, a collision is unavoidable. -/
theorem collisionGuaranteed_of_lt {p k r : ℕ} [NeZero p] (h : p < k ^ r) :
    CollisionGuaranteed p k r := by
  intro A
  have hcard : Fintype.card (ZMod p) < Fintype.card (Fin r → Fin k) := by
    simpa [ZMod.card, Fintype.card_fun] using h
  obtain ⟨x, y, hxy, hEq⟩ := Fintype.exists_ne_map_eq_of_card_lt (selSum A) hcard
  exact ⟨x, y, hxy, hEq⟩

/-- **Sharpness (adversary) direction.**  If `k ^ r ≤ p`, the base-`k` digit
system makes all `k ^ r` selection sums pairwise distinct, so no collision
occurs.  Consequently a level-`r` search examining at most `p` selections can
fail. -/
theorem exists_collisionFree {p k r : ℕ} (h : k ^ r ≤ p) :
    ∃ A : Fin r → Fin k → ZMod p, Function.Injective (selSum A) := by
  refine ⟨fun j i => ((i : ℕ) * k ^ (j : ℕ) : ℕ), ?_⟩
  intro x y hxy
  have key : ∀ z : Fin r → Fin k,
      selSum (fun j i => (((i : ℕ) * k ^ (j : ℕ) : ℕ) : ZMod p)) z
        = ((finFunctionFinEquiv z : ℕ) : ZMod p) := by
    intro z
    rw [finFunctionFinEquiv_apply]
    simp [selSum, Nat.cast_sum]
  rw [key x, key y] at hxy
  have hx : (finFunctionFinEquiv x : ℕ) < p :=
    lt_of_lt_of_le (finFunctionFinEquiv x).isLt h
  have hy : (finFunctionFinEquiv y : ℕ) < p :=
    lt_of_lt_of_le (finFunctionFinEquiv y).isLt h
  have : (finFunctionFinEquiv x : ℕ) = (finFunctionFinEquiv y : ℕ) := by
    have := congrArg ZMod.val hxy
    rwa [ZMod.val_natCast_of_lt hx, ZMod.val_natCast_of_lt hy] at this
  have : (finFunctionFinEquiv x : Fin (k ^ r)) = finFunctionFinEquiv y := Fin.ext this
  exact finFunctionFinEquiv.injective this

/-- **Exact threshold for a level-`r` collision search.**  Guaranteed success is
*equivalent* to examining more than `p` selections. -/
theorem collisionGuaranteed_iff {p k r : ℕ} (hp : 0 < p) :
    CollisionGuaranteed p k r ↔ p < k ^ r := by
  haveI : NeZero p := ⟨hp.ne'⟩
  refine ⟨fun hG => ?_, collisionGuaranteed_of_lt⟩
  by_contra hle
  push_neg at hle
  obtain ⟨A, hA⟩ := exists_collisionFree hle
  obtain ⟨x, y, hxy, hEq⟩ := hG A
  exact hxy (hA hEq)

/-! ## The hierarchy: the exponent improves, the work does not -/

/-- **Going up the hierarchy never costs more elements.**  If a level-`r` search
with family size `k ≥ 1` is guaranteed, so is the level-`r'` search for every
`r' ≥ r`.  Concretely the sumset level (`r = 2`) needs `k > p ^ (1/2)` while the
3SUM level (`r = 3`) already succeeds at `k > p ^ (1/3)`. -/
theorem collisionGuaranteed_mono_level {p k r r' : ℕ} (hp : 0 < p) (hk : 1 ≤ k)
    (hrr : r ≤ r') (h : CollisionGuaranteed p k r) : CollisionGuaranteed p k r' := by
  rw [collisionGuaranteed_iff hp] at h ⊢
  exact lt_of_lt_of_le h (Nat.pow_le_pow_right hk hrr)

/-- Sumset level (`a + b ≡ c + d`): threshold `k ^ 2 > p`. -/
theorem sumset_threshold {p k : ℕ} (hp : 0 < p) :
    CollisionGuaranteed p k 2 ↔ p < k ^ 2 := collisionGuaranteed_iff hp

/-- 3SUM level (`a + b + c ≡ a' + b' + c'`): threshold `k ^ 3 > p`. -/
theorem threeSum_threshold {p k : ℕ} (hp : 0 < p) :
    CollisionGuaranteed p k 3 ↔ p < k ^ 3 := collisionGuaranteed_iff hp

/-- **The work is level-independent.**  Whatever the level `r`, a guaranteed
search inspects `k ^ r > p` selections. -/
theorem work_exceeds_modulus {p k r : ℕ} (hp : 0 < p) (h : CollisionGuaranteed p k r) :
    p < k ^ r := (collisionGuaranteed_iff hp).1 h

/-! ## Translation to the `√N` barrier -/

/-- For `N = p*q` with `p ≤ q`, the small prime is at most `√N`. -/
theorem prime_le_sqrt {N p q : ℕ} (hN : N = p * q) (hpq : p ≤ q) : p ≤ Nat.sqrt N := by
  have h2 : p ^ 2 ≤ N := by rw [hN, pow_two]; exact Nat.mul_le_mul_left p hpq
  exact Nat.le_sqrt'.2 h2

/-- **The `√N` barrier, uniformly over the hierarchy.**  For a balanced semiprime
`N = p * q` with `q ≤ 2p`, any guaranteed level-`r` collision search inspects
`W = k ^ r` selections with `N < 2 * W ^ 2`, i.e. `W > √(N/2)`.  The level `r`
does not appear in the bound: improving the collision exponent from `1/2` to
`1/3` (and beyond) does not move the barrier. -/
theorem birthday_barrier_sqrt {N p q k r : ℕ} (hN : N = p * q) (hp : 0 < p)
    (hbal : q ≤ 2 * p) (h : CollisionGuaranteed p k r) : N < 2 * (k ^ r) ^ 2 := by
  have hw : p < k ^ r := work_exceeds_modulus hp h
  have hNle : N ≤ 2 * p * p := by
    rw [hN]; calc p * q ≤ p * (2 * p) := Nat.mul_le_mul_left p hbal
      _ = 2 * p * p := by ring
  nlinarith [hw, hNle, hp]

/-! ## Third row: exhaustive evaluation searches -/

/-- An evaluation search testing a set `S` of residues can only be certain to hit
an arbitrary prescribed class when it tests *all* `p` classes. -/
theorem evaluation_search_complete_iff {p : ℕ} [NeZero p] (S : Finset (ZMod p)) :
    (∀ z : ZMod p, z ∈ S) ↔ S.card = p := by
  constructor
  · intro h
    have : S = Finset.univ := Finset.eq_univ_iff_forall.2 h
    rw [this, Finset.card_univ, ZMod.card]
  · intro h z
    have : S = Finset.univ :=
      Finset.eq_univ_of_card S (by simp [h, ZMod.card])
    simp [this]

/-- **Same barrier for the evaluation row.**  A complete evaluation search on a
balanced semiprime performs `W = S.card` tests with `N < 2 * W ^ 2`. -/
theorem evaluation_barrier {N p q : ℕ} [NeZero p] (S : Finset (ZMod p)) (hN : N = p * q)
    (hp : 0 < p) (hbal : q < 2 * p) (hS : ∀ z : ZMod p, z ∈ S) : N < 2 * S.card ^ 2 := by
  have hcard : S.card = p := (evaluation_search_complete_iff S).1 hS
  have hNlt : N < 2 * p * p := by
    rw [hN]
    calc p * q < p * (2 * p) := by
          exact Nat.mul_lt_mul_of_pos_left hbal hp
      _ = 2 * p * p := by ring
  rw [hcard]
  nlinarith [hNlt, hp]

/-! ## From a collision to an actual factor -/

/-- **Collision ⇒ factor.**  A collision produces two integers `u > v` congruent
mod `p`, whose difference is below `N`; the difference then reveals `p`
by `ThreeSumFactoring.reveal_of_pos_lt`. -/
theorem collision_reveals_factor {p q u v : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (hlt : v < u) (hsmall : u - v < p * q) (hdvd : p ∣ u - v) :
    Nat.gcd (u - v) (p * q) = p :=
  ThreeSumFactoring.reveal_of_pos_lt hp hq hpq (by omega) hsmall hdvd

/-- **The full pipeline at the 3SUM level.**  With `k ^ 3 > p` a 3SUM collision
exists for every family system; if the two colliding sums are distinct integers
lying below `N`, their difference is a nontrivial factor of `N = p * q`. -/
theorem threeSum_pipeline {p q k : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hk : p < k ^ 3) (u v : ℕ) (hlt : v < u) (hsmall : u - v < p * q)
    (hdvd : p ∣ u - v) :
    CollisionGuaranteed p k 3 ∧ Nat.gcd (u - v) (p * q) = p := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  exact ⟨collisionGuaranteed_of_lt hk, collision_reveals_factor hp hq hpq hlt hsmall hdvd⟩

end BirthdayBoundHierarchy