import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.LinearAlgebra.Matrix.ToLinearEquiv
import Mathlib.NumberTheory.LegendreSymbol.QuadraticReciprocity
import Mathlib.Algebra.CharP.Lemmas
import Mathlib.Data.ZMod.Basic
import Mathlib.GroupTheory.OrderOfElement
import Mathlib.Tactic.NoncommRing
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.LinearCombination
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.Ring

/-!
# p-adic Berggren dynamics

The Berggren (Barning–Hall) moves are the three integer matrices

```
B₁ = !![1,-2,2; 2,-1,2; 2,-2,3]   B₂ = !![1,2,2; 2,1,2; 2,2,3]   B₃ = !![-1,2,2; -2,1,2; -2,2,3]
```

acting on column vectors `(a,b,c)` and generating the ternary tree of primitive Pythagorean
triples.  They preserve the Lorentz form `q(a,b,c) = a² + b² − c²`.  The catalog already
contains the real/hyperbolic geometry of the tree and the exact spectral data of the
generators over `ℤ` (`Catalog/Cryptography/BerggrenSpectral/Generators.lean`:
`charpoly B₁ = charpoly B₃ = (X−1)³`, `charpoly B₂ = (X+1)(X²−6X+1)`).

This file develops the **p-adic / mod `p^k` dynamics** of the same three matrices.  Everything
below is proved for the reductions of the *same* generators, over `ZMod (p^k)`.

## Main results

Structural (any commutative ring `R`):

* `lorentz_B₁`, `lorentz_B₂`, `lorentz_B₃` : the moves preserve `a² + b² − c²` over any `R`;
  in particular the null cone mod `p^k` is invariant.
* `bijOn_nullCone_B₁/₂/₃` : each move is a *bijection* of the null cone; mod `p^k` the tree
  therefore becomes a finite invertible dynamical system.
* `B₁_eq_one_add`, `N₁_cube`, `N₁_sq_ne_zero` : `B₁ = 1 + N₁` with `N₁³ = 0`, and the
  nilpotency index is exactly `3` **iff `4 ≠ 0`** in `R`.  Mod `2` and mod `4` the index drops
  to `2`: the unipotent p-adic classification is uniform except at the prime `2`.

Unipotent generators (p odd):

* `pow_unipotent_formula` : `(1+X)^n = 1 + n X + C(n,2) X²` whenever `X³ = 0`.
* `B₁_pow_p_pow`, `B₃_pow_p_pow` : `B₁^(p^k) = 1` and `B₃^(p^k) = 1` in `ZMod (p^k)`.
* `B₁_order_exact` : conversely `B₁^m = 1` mod `p^k` forces `p^k ∣ m`, so the order of `B₁`
  mod `p^k` is *exactly* `p^k` — a pure `p`-power ("pro-`p`", nilpotent behaviour).
* `B₁_pow_ne_one_padic` : sharpness of the depth — `B₁^(p^k) = 1` mod `p^k` but not mod
  `p^(k+1)`.
* `B₁_fixes_null_line`, `B₁_fixed_iff` : `B₁` fixes exactly the null line spanned by `(0,1,1)`
  (a boundary point of the light cone), and `B₃` fixes the null line `(1,0,1)`.

Hyperbolic generator (p odd):

* `Um_pow_card` : Frobenius applied to the hyperbolic `2×2` block `U = !![3,2;4,3] = 3 + 2J`,
  `J² = 2` : `U^p = 3 + 2·(2^((p−1)/2))·J`.
* `B₂_pow_p_sub_one_of_isSquare_two` / `B₂_pow_p_add_one_of_not_isSquare_two` :
  the order of `B₂` mod `p` divides `p − 1` if `2` is a square mod `p` and divides `p + 1`
  otherwise.  By quadratic reciprocity this is decided by `p mod 8`.
* `B₂_pow_card_sq_sub_one`, `B₂_orderOf_dvd` : in all cases the order divides `p² − 1`,
  confirming the conjectured bound.
* `B₂_null_eigenvector_iff_isSquare_two`, `B₂_null_eigenvector_iff_mod_eight` :
  `B₂` has a nonzero eigenvector **on the null cone** iff `2` is a square mod `p`, iff
  `p ≡ ±1 (mod 8)`.  This is the exact p-adic split/inert (hyperbolic/elliptic) dichotomy.
* `B₂_no_nonzero_fixed_point` : `B₂` has no nonzero fixed vector mod `p`, in sharp contrast
  with the unipotent generators.

Depth (`p^k`) statements:

* `lift_pow` : an entrywise Hensel lift, `A ≡ 1 (mod p) → A^(p^k) ≡ 1 (mod p^(k+1))`.
* `B₂_pow_eq_one_padic` : `B₂^((p²−1)·p^(k−1)) = 1` in `ZMod (p^k)`.
* `B₂_padic_contraction` : the p-adic distance `|B₂^N v − v|_p ≤ p^(−k)` for `N = (p²−1)p^(k−1)`
  and every integer vector `v`: the hyperbolic generator is *periodic to any p-adic precision*.
* `tree_collision_mod` : the `3^d` words of length `d` collide mod `m` as soon as `m³ < 3^d`,
  so the reduction of the boundary of the tree is **not** injective: there is no p-adic Cantor
  set inside a fixed finite level `ZMod (p^k)` (see `FUTURE_DIRECTIONS.md`).
-/

namespace PadicBerggren

open Matrix

/-! ## The generators and the Lorentz form -/

section Defs
variable (R : Type*) [CommRing R]

/-- First Berggren generator (unipotent). -/
def B₁ : Matrix (Fin 3) (Fin 3) R := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Second Berggren generator (hyperbolic). -/
def B₂ : Matrix (Fin 3) (Fin 3) R := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Third Berggren generator (unipotent). -/
def B₃ : Matrix (Fin 3) (Fin 3) R := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Inverse of `B₁`. -/
def C₁ : Matrix (Fin 3) (Fin 3) R := !![1, 2, -2; -2, -1, 2; -2, -2, 3]

/-- Inverse of `B₂`. -/
def C₂ : Matrix (Fin 3) (Fin 3) R := !![1, 2, -2; 2, 1, -2; -2, -2, 3]

/-- Inverse of `B₃`. -/
def C₃ : Matrix (Fin 3) (Fin 3) R := !![-1, -2, 2; 2, 1, -2; -2, -2, 3]

/-- The Lorentz form `a² + b² − c²` preserved by the Berggren moves. -/
def lorentz (v : Fin 3 → R) : R := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- The null cone of the Lorentz form: the "Pythagorean" locus mod `p^k`. -/
def nullCone : Set (Fin 3 → R) := {v | lorentz R v = 0}

/-- The nilpotent part of `B₁`. -/
def N₁ : Matrix (Fin 3) (Fin 3) R := !![0, -2, 2; 2, -2, 2; 2, -2, 2]

/-- The nilpotent part of `B₃`. -/
def N₃ : Matrix (Fin 3) (Fin 3) R := !![-2, 2, 2; -2, 0, 2; -2, 2, 2]

end Defs

variable {R : Type*} [CommRing R]

theorem lorentz_B₁ (v : Fin 3 → R) : lorentz R (B₁ R *ᵥ v) = lorentz R v := by
  simp [lorentz, B₁, Matrix.mulVec, dotProduct, Fin.sum_univ_three]
  ring

theorem lorentz_B₂ (v : Fin 3 → R) : lorentz R (B₂ R *ᵥ v) = lorentz R v := by
  simp [lorentz, B₂, Matrix.mulVec, dotProduct, Fin.sum_univ_three]
  ring

theorem lorentz_B₃ (v : Fin 3 → R) : lorentz R (B₃ R *ᵥ v) = lorentz R v := by
  simp [lorentz, B₃, Matrix.mulVec, dotProduct, Fin.sum_univ_three]
  ring

theorem lorentz_C₁ (v : Fin 3 → R) : lorentz R (C₁ R *ᵥ v) = lorentz R v := by
  simp [lorentz, C₁, Matrix.mulVec, dotProduct, Fin.sum_univ_three]
  ring

theorem lorentz_C₂ (v : Fin 3 → R) : lorentz R (C₂ R *ᵥ v) = lorentz R v := by
  simp [lorentz, C₂, Matrix.mulVec, dotProduct, Fin.sum_univ_three]
  ring

theorem lorentz_C₃ (v : Fin 3 → R) : lorentz R (C₃ R *ᵥ v) = lorentz R v := by
  simp [lorentz, C₃, Matrix.mulVec, dotProduct, Fin.sum_univ_three]
  ring

/-! ### Determinants and inverses -/

theorem det_B₁ : (B₁ R).det = 1 := by simp [B₁, Matrix.det_fin_three]; ring

theorem det_B₂ : (B₂ R).det = -1 := by simp [B₂, Matrix.det_fin_three]; ring

theorem det_B₃ : (B₃ R).det = 1 := by simp [B₃, Matrix.det_fin_three]; ring

theorem B₁_mul_C₁ : B₁ R * C₁ R = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [B₁, C₁, Matrix.mul_apply, Fin.sum_univ_three] <;> ring

theorem C₁_mul_B₁ : C₁ R * B₁ R = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [B₁, C₁, Matrix.mul_apply, Fin.sum_univ_three] <;> ring

theorem B₂_mul_C₂ : B₂ R * C₂ R = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [B₂, C₂, Matrix.mul_apply, Fin.sum_univ_three] <;> ring

theorem C₂_mul_B₂ : C₂ R * B₂ R = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [B₂, C₂, Matrix.mul_apply, Fin.sum_univ_three] <;> ring

theorem B₃_mul_C₃ : B₃ R * C₃ R = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [B₃, C₃, Matrix.mul_apply, Fin.sum_univ_three] <;> ring

theorem C₃_mul_B₃ : C₃ R * B₃ R = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [B₃, C₃, Matrix.mul_apply, Fin.sum_univ_three] <;> ring

/-! ### The moves are bijections of the null cone

Over `ZMod (p^k)` the null cone is a finite set, so each Berggren move becomes a permutation
of a finite set: the tree reduces to an invertible finite dynamical system. -/

theorem bijOn_of_inverse (M N : Matrix (Fin 3) (Fin 3) R) (hMN : M * N = 1) (hNM : N * M = 1)
    (hM : ∀ v, lorentz R (M *ᵥ v) = lorentz R v)
    (hN : ∀ v, lorentz R (N *ᵥ v) = lorentz R v) :
    Set.BijOn (fun v => M *ᵥ v) (nullCone R) (nullCone R) := by
  refine ⟨fun v hv => ?_, fun v _ w _ h => ?_, fun w hw => ⟨N *ᵥ w, ?_, ?_⟩⟩
  · simpa [nullCone, Set.mem_setOf_eq, hM v] using hv
  · have := congrArg (fun u => N *ᵥ u) h
    simpa [Matrix.mulVec_mulVec, hNM, Matrix.one_mulVec] using this
  · simpa [nullCone, Set.mem_setOf_eq, hN w] using hw
  · simp [Matrix.mulVec_mulVec, hMN, Matrix.one_mulVec]

theorem bijOn_nullCone_B₁ : Set.BijOn (fun v => B₁ R *ᵥ v) (nullCone R) (nullCone R) :=
  bijOn_of_inverse _ _ B₁_mul_C₁ C₁_mul_B₁ lorentz_B₁ lorentz_C₁

theorem bijOn_nullCone_B₂ : Set.BijOn (fun v => B₂ R *ᵥ v) (nullCone R) (nullCone R) :=
  bijOn_of_inverse _ _ B₂_mul_C₂ C₂_mul_B₂ lorentz_B₂ lorentz_C₂

theorem bijOn_nullCone_B₃ : Set.BijOn (fun v => B₃ R *ᵥ v) (nullCone R) (nullCone R) :=
  bijOn_of_inverse _ _ B₃_mul_C₃ C₃_mul_B₃ lorentz_B₃ lorentz_C₃

/-! ## Unipotent generators -/

theorem B₁_eq_one_add : B₁ R = 1 + N₁ R := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [B₁, N₁] <;> ring

theorem B₃_eq_one_add : B₃ R = 1 + N₃ R := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [B₃, N₃] <;> ring

theorem N₁_sq : (N₁ R) ^ 2 = !![0, 0, 0; 0, -4, 4; 0, -4, 4] := by
  rw [pow_two]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [N₁, Matrix.mul_apply, Fin.sum_univ_three] <;> ring

theorem N₁_cube : (N₁ R) ^ 3 = 0 := by
  rw [pow_succ, N₁_sq]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [N₁, Matrix.mul_apply, Fin.sum_univ_three]

theorem N₃_sq : (N₃ R) ^ 2 = !![-4, 0, 4; 0, 0, 0; -4, 0, 4] := by
  rw [pow_two]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [N₃, Matrix.mul_apply, Fin.sum_univ_three] <;> ring

theorem N₃_cube : (N₃ R) ^ 3 = 0 := by
  rw [pow_succ, N₃_sq]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [N₃, Matrix.mul_apply, Fin.sum_univ_three]

/-- **Sharp nilpotency index.**  `N₁² ≠ 0` exactly when `4 ≠ 0` in `R`; so mod `2` and mod `4`
the unipotent generators have nilpotency index `2`, and index exactly `3` at every other
prime power.  This is the one place where the p-adic classification is not uniform. -/
theorem N₁_sq_ne_zero (h4 : (4 : R) ≠ 0) : (N₁ R) ^ 2 ≠ 0 := by
  intro h
  rw [N₁_sq] at h
  have := congrFun (congrFun h 1) 2
  simp at this
  exact h4 (by linear_combination this)

theorem N₁_sq_eq_zero_of_four_eq_zero (h4 : (4 : R) = 0) : (N₁ R) ^ 2 = 0 := by
  rw [N₁_sq]
  ext i j
  fin_cases i <;> fin_cases j <;> simp [h4]

/-- **The unipotent power formula.**  If `X³ = 0` then `(1+X)^n = 1 + nX + C(n,2)X²`. -/
theorem pow_unipotent_formula {S : Type*} [Ring S] (X : S) (hX : X ^ 3 = 0) (n : ℕ) :
    (1 + X) ^ n = 1 + (n : S) * X + ((n.choose 2 : ℕ) : S) * X ^ 2 := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hc : (((n + 1).choose 2 : ℕ) : S) = ((n.choose 2 : ℕ) : S) + (n : S) := by
        rw [Nat.choose_succ_succ' n 1, Nat.choose_one_right]
        push_cast
        exact add_comm _ _
      have expand : (1 + (n : S) * X + ((n.choose 2 : ℕ) : S) * X ^ 2) * (1 + X)
          = (1 + ((n : S) + 1) * X + (((n.choose 2 : ℕ) : S) + (n : S)) * X ^ 2)
            + ((n.choose 2 : ℕ) : S) * X ^ 3 := by
        noncomm_ring
      rw [pow_succ, ih, expand, hX, mul_zero, add_zero]
      push_cast [hc]
      noncomm_ring

/-! ### Order of the unipotent generators mod `p^k` -/

/-- A natural number scalar matrix multiplies entrywise. -/
theorem natCast_matrix_mul {n : Type*} [Fintype n] [DecidableEq n] (m : ℕ)
    (M : Matrix n n R) : ((m : Matrix n n R)) * M = (m : R) • M := by
  have h : ((m : ℕ) : Matrix n n R) = (m : R) • (1 : Matrix n n R) := by
    ext i j
    simp [Matrix.natCast_apply, Matrix.one_apply, apply_ite ((↑) : ℕ → R)]
  rw [h, Matrix.smul_mul, one_mul]

theorem natCast_matrix_eq_zero {n : Type*} [Fintype n] [DecidableEq n] (m : ℕ)
    (h : (m : R) = 0) : ((m : ℕ) : Matrix n n R) = 0 := by
  ext i j
  simp [Matrix.natCast_apply, apply_ite ((↑) : ℕ → R), h]

/-- For an odd prime power `p^k`, `p^k` divides the binomial coefficient `C(p^k, 2)`. -/
theorem pow_dvd_choose_two (p k : ℕ) (hp : p.Prime) (hodd : p ≠ 2) :
    p ^ k ∣ (p ^ k).choose 2 := by
  have h2 : p % 2 = 1 := (Nat.Prime.eq_two_or_odd hp).resolve_left hodd
  have hodd' : p ^ k % 2 = 1 := by simp [Nat.pow_mod, h2]
  obtain ⟨t, ht⟩ : ∃ t, p ^ k = 2 * t + 1 := ⟨p ^ k / 2, by omega⟩
  refine ⟨t, ?_⟩
  have h1 : 2 * t + 1 - 1 = 2 * t := by omega
  have key : (2 * t + 1) * (2 * t) = ((2 * t + 1) * t) * 2 := by ring
  rw [Nat.choose_two_right, ht, h1, key]
  generalize (2 * t + 1) * t = A
  omega

/-- For an odd prime power `p^k`, the binomial coefficient `C(p^k, 2)` vanishes mod `p^k`. -/
theorem choose_two_cast_eq_zero (p k : ℕ) (hp : p.Prime) (hodd : p ≠ 2) :
    (((p ^ k).choose 2 : ℕ) : ZMod (p ^ k)) = 0 := by
  rw [ZMod.natCast_eq_zero_iff]
  exact pow_dvd_choose_two p k hp hodd

/-- **The unipotent generators are `p`-adically pro-`p`.**  For odd `p`,
`B₁^(p^k) = 1` in `ZMod (p^k)`. -/
theorem B₁_pow_p_pow (p k : ℕ) (hp : p.Prime) (hodd : p ≠ 2) :
    (B₁ (ZMod (p ^ k))) ^ (p ^ k) = 1 := by
  have hpk : ((p ^ k : ℕ) : ZMod (p ^ k)) = 0 := ZMod.natCast_self _
  have hchoose := choose_two_cast_eq_zero p k hp hodd
  rw [B₁_eq_one_add, pow_unipotent_formula _ N₁_cube]
  rw [natCast_matrix_eq_zero _ hpk, natCast_matrix_eq_zero _ hchoose]
  simp

theorem B₃_pow_p_pow (p k : ℕ) (hp : p.Prime) (hodd : p ≠ 2) :
    (B₃ (ZMod (p ^ k))) ^ (p ^ k) = 1 := by
  have hpk : ((p ^ k : ℕ) : ZMod (p ^ k)) = 0 := ZMod.natCast_self _
  have hchoose := choose_two_cast_eq_zero p k hp hodd
  rw [B₃_eq_one_add, pow_unipotent_formula _ N₃_cube]
  rw [natCast_matrix_eq_zero _ hpk, natCast_matrix_eq_zero _ hchoose]
  simp

/-- **The order of `B₁` mod `p^k` is exactly `p^k`.**  Combined with `B₁_pow_p_pow` this pins
down the order of the unipotent generator: it is a pure `p`-power, with no prime-to-`p` part —
the p-adic incarnation of "unipotent". -/
theorem B₁_order_exact (p k m : ℕ) (hp : p.Prime) (hodd : p ≠ 2)
    (h : (B₁ (ZMod (p ^ k))) ^ m = 1) : p ^ k ∣ m := by
  rw [B₁_eq_one_add, pow_unipotent_formula _ N₁_cube] at h
  have h01 := congrFun (congrFun h 0) 1
  rw [natCast_matrix_mul, natCast_matrix_mul, N₁_sq] at h01
  simp [Matrix.add_apply, N₁] at h01
  -- `h01 : (m : ZMod (p^k)) * (-2) = 0` up to normalisation
  have h2 : ((2 * m : ℕ) : ZMod (p ^ k)) = 0 := by
    push_cast
    linear_combination h01
  rw [ZMod.natCast_eq_zero_iff] at h2
  have hcop : Nat.Coprime (p ^ k) 2 :=
    Nat.Coprime.pow_left _ ((Nat.coprime_primes hp Nat.prime_two).mpr hodd)
  exact (Nat.Coprime.dvd_of_dvd_mul_left hcop h2)

/-- **Sharpness of the unipotent p-adic depth.**  `B₁^(p^k) = 1` mod `p^k` but *not* mod
`p^(k+1)`: the contraction `B₁_padic_contraction` gains exactly one digit of p-adic precision
per unipotent step, never more. -/
theorem B₁_pow_ne_one_padic (p k : ℕ) (hp : p.Prime) (hodd : p ≠ 2) :
    (B₁ (ZMod (p ^ (k + 1)))) ^ (p ^ k) ≠ 1 := by
  intro h
  have hdvd := B₁_order_exact p (k + 1) (p ^ k) hp hodd h
  have hle := Nat.le_of_dvd (Nat.pow_pos hp.pos) hdvd
  have hlt : p ^ k < p ^ (k + 1) := Nat.pow_lt_pow_right hp.one_lt (by omega)
  omega

/-! ### The unipotent generators fix a single null line -/

theorem B₁_fixes_null_line : B₁ R *ᵥ ![0, 1, 1] = ![0, 1, 1] := by
  funext i
  fin_cases i <;>
    simp [B₁, Matrix.mulVec, dotProduct, Fin.sum_univ_three] <;> ring

theorem lorentz_B₁_fixed_vector : lorentz R ![0, 1, 1] = 0 := by
  simp [lorentz]

theorem B₃_fixes_null_line : B₃ R *ᵥ ![1, 0, 1] = ![1, 0, 1] := by
  funext i
  fin_cases i <;>
    simp [B₃, Matrix.mulVec, dotProduct, Fin.sum_univ_three] <;> ring

theorem lorentz_B₃_fixed_vector : lorentz R ![1, 0, 1] = 0 := by
  simp [lorentz]

/-- Modulo an odd prime the fixed space of `B₁` is exactly the null line `(0,t,t)`. -/
theorem B₁_fixed_iff (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (v : Fin 3 → ZMod p) :
    B₁ (ZMod p) *ᵥ v = v ↔ v = ![0, v 1, v 1] := by
  have h2 : (2 : ZMod p) ≠ 0 := by
    intro h
    have h' : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
    rw [ZMod.natCast_eq_zero_iff] at h'
    exact hp ((Nat.prime_dvd_prime_iff_eq (Fact.out) Nat.prime_two).mp h')
  constructor
  · intro h
    have h0 := congrFun h 0
    have h1 := congrFun h 1
    simp [B₁, Matrix.mulVec, dotProduct, Fin.sum_univ_three] at h0 h1
    have hv2 : v 2 = v 1 := by
      have : (2 : ZMod p) * (v 2 - v 1) = 0 := by linear_combination h0
      rcases mul_eq_zero.mp this with h | h
      · exact absurd h h2
      · linear_combination h
    have hv0 : v 0 = 0 := by
      have : (2 : ZMod p) * v 0 = 0 := by linear_combination h1 - 2 * hv2
      rcases mul_eq_zero.mp this with h | h
      · exact absurd h h2
      · exact h
    funext i
    fin_cases i <;> simp [hv0, hv2]
  · intro h
    rw [h]
    funext i
    fin_cases i <;>
      simp [B₁, Matrix.mulVec, dotProduct, Fin.sum_univ_three] <;> ring

/-! ## The hyperbolic generator

`B₂` is conjugate (over `ℤ[1/2]`) to `diag(−1) ⊕ U` with `U = !![3,2;4,3]`, the matrix of
multiplication by the square `3 + 2√2` of the silver ratio on `ℤ[√2]`.  We prove everything
through the concrete conjugation `B₂ · W = W · (S · emb U)`. -/

/-- The hyperbolic `2×2` block. -/
def Um (R : Type*) [CommRing R] : Matrix (Fin 2) (Fin 2) R := !![3, 2; 4, 3]

/-- The "`√2`" matrix: `J² = 2`. -/
def Jm (R : Type*) [CommRing R] : Matrix (Fin 2) (Fin 2) R := !![0, 1; 2, 0]

/-- Scalar `2×2` matrices. -/
def scal2 (c : R) : Matrix (Fin 2) (Fin 2) R := c • (1 : Matrix (Fin 2) (Fin 2) R)

theorem scal2_eq (c : R) : scal2 c = !![c, 0; 0, c] := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [scal2]

theorem scal2_mul (a b : R) : scal2 a * scal2 b = scal2 (a * b) := by
  simp only [scal2_eq]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_two]

theorem scal2_pow (a : R) (n : ℕ) : (scal2 a) ^ n = scal2 (a ^ n) := by
  induction n with
  | zero => simp [scal2]
  | succ n ih => rw [pow_succ, ih, scal2_mul, pow_succ]

theorem scal2_commute (a : R) (M : Matrix (Fin 2) (Fin 2) R) : Commute (scal2 a) M := by
  unfold Commute SemiconjBy scal2
  rw [Matrix.smul_mul, Matrix.mul_smul, one_mul, mul_one]

theorem Um_decomp : Um R = scal2 (3 : R) + scal2 (2 : R) * Jm R := by
  simp only [scal2_eq]
  ext i j
  fin_cases i <;> fin_cases j <;>
    (simp [Um, Jm]; try ring)

theorem Jm_sq : (Jm R) ^ 2 = scal2 (2 : R) := by
  rw [pow_two]
  simp only [scal2_eq]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Jm, Matrix.mul_apply, Fin.sum_univ_two]

theorem Um_mul_inv : Um R * !![3, -2; -4, 3] = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Um, Matrix.mul_apply, Fin.sum_univ_two] <;> ring

theorem Um_conj_mul : (scal2 (3 : R) + scal2 (-2 : R) * Jm R) * Um R = 1 := by
  simp only [scal2_eq]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Um, Jm, Matrix.mul_apply, Fin.sum_univ_two] <;> ring

/-- Block embedding `2×2 ↪ 3×3` (identity on the first coordinate). -/
def emb (A : Matrix (Fin 2) (Fin 2) R) : Matrix (Fin 3) (Fin 3) R :=
  !![1, 0, 0; 0, A 0 0, A 0 1; 0, A 1 0, A 1 1]

theorem emb_one : emb (1 : Matrix (Fin 2) (Fin 2) R) = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [emb]

theorem emb_mul (A B : Matrix (Fin 2) (Fin 2) R) : emb (A * B) = emb A * emb B := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [emb, Matrix.mul_apply, Fin.sum_univ_two, Fin.sum_univ_three]

theorem emb_pow (A : Matrix (Fin 2) (Fin 2) R) (n : ℕ) : emb (A ^ n) = (emb A) ^ n := by
  induction n with
  | zero => simpa using emb_one (R := R)
  | succ n ih => rw [pow_succ, emb_mul, ih, pow_succ]

/-- The sign block carrying the `−1` eigenvalue of `B₂`. -/
def Sm (R : Type*) [CommRing R] : Matrix (Fin 3) (Fin 3) R := !![-1, 0, 0; 0, 1, 0; 0, 0, 1]

/-- Conjugating matrix: its columns are the eigenvectors `(1,−1,0)`, `(1,1,0)`, `(0,0,1)`. -/
def Wm (R : Type*) [CommRing R] : Matrix (Fin 3) (Fin 3) R := !![1, 1, 0; -1, 1, 0; 0, 0, 1]

/-- `2 · Wm⁻¹`, an integral matrix. -/
def Vm (R : Type*) [CommRing R] : Matrix (Fin 3) (Fin 3) R := !![1, -1, 0; 1, 1, 0; 0, 0, 2]

theorem Sm_sq : (Sm R) ^ 2 = 1 := by
  rw [pow_two]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Sm, Matrix.mul_apply, Fin.sum_univ_three]

theorem Sm_pow_even {m : ℕ} (hm : Even m) : (Sm R) ^ m = 1 := by
  obtain ⟨t, ht⟩ := hm
  rw [show m = 2 * t by omega, pow_mul, Sm_sq, one_pow]

theorem Sm_commute_emb_Um : Commute (Sm R) (emb (Um R)) := by
  unfold Commute SemiconjBy
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Sm, emb, Um, Matrix.mul_apply, Fin.sum_univ_three]

theorem B₂_mul_Wm : B₂ R * Wm R = Wm R * (Sm R * emb (Um R)) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [B₂, Wm, Sm, emb, Um, Matrix.mul_apply, Fin.sum_univ_three] <;> ring

theorem Wm_mul_Vm : (Wm R) * Vm R = (2 : R) • 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Wm, Vm, Matrix.mul_apply, Fin.sum_univ_three] <;> ring

theorem B₂_pow_mul_Wm (n : ℕ) : (B₂ R) ^ n * Wm R = Wm R * (Sm R * emb (Um R)) ^ n := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [pow_succ, mul_assoc, B₂_mul_Wm, ← mul_assoc, ih, mul_assoc, ← pow_succ]

/-- If the conjugated block is trivial, so is the power of `B₂` (over a field of odd
characteristic, where `2` is invertible). -/
theorem B₂_pow_eq_one_of_block (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) {m : ℕ}
    (hU : (Um (ZMod p)) ^ m = 1) (hm : Even m) : (B₂ (ZMod p)) ^ m = 1 := by
  have h2 : (2 : ZMod p) ≠ 0 := by
    intro h
    have h' : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
    rw [ZMod.natCast_eq_zero_iff] at h'
    exact hp ((Nat.prime_dvd_prime_iff_eq (Fact.out) Nat.prime_two).mp h')
  have hblock : (Sm (ZMod p) * emb (Um (ZMod p))) ^ m = 1 := by
    rw [Commute.mul_pow Sm_commute_emb_Um, Sm_pow_even hm, ← emb_pow, hU, emb_one, one_mul]
  have key : (B₂ (ZMod p)) ^ m * Wm (ZMod p) = Wm (ZMod p) := by
    rw [B₂_pow_mul_Wm, hblock, mul_one]
  have key2 : (B₂ (ZMod p)) ^ m * ((2 : ZMod p) • 1) = (2 : ZMod p) • 1 := by
    rw [← Wm_mul_Vm, ← mul_assoc, key]
  rw [Matrix.mul_smul, mul_one] at key2
  ext i j
  have := congrFun (congrFun key2 i) j
  simp only [Matrix.smul_apply, smul_eq_mul] at this
  exact mul_left_cancel₀ h2 this

/-! ### Frobenius on the hyperbolic block -/

instance matrixCharP (n : Type*) [Fintype n] [DecidableEq n] [Nonempty n] (p : ℕ)
    [Fact p.Prime] : CharP (Matrix n n (ZMod p)) p := by
  constructor
  intro m
  constructor
  · intro h
    have h0 : ((m : ℕ) : ZMod p) = 0 := by
      have := congrFun (congrFun h (Classical.arbitrary n)) (Classical.arbitrary n)
      simpa [Matrix.natCast_apply] using this
    exact (ZMod.natCast_eq_zero_iff m p).mp h0
  · intro h
    have h0 : ((m : ℕ) : ZMod p) = 0 := (ZMod.natCast_eq_zero_iff m p).mpr h
    exact natCast_matrix_eq_zero _ h0

theorem Jm_pow_card (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    (Jm (ZMod p)) ^ p = scal2 ((2 : ZMod p) ^ (p / 2)) * Jm (ZMod p) := by
  have hpp : p.Prime := Fact.out
  have h2 : p % 2 = 1 := (Nat.Prime.eq_two_or_odd hpp).resolve_left hp
  have hp' : p = 2 * (p / 2) + 1 := by omega
  calc (Jm (ZMod p)) ^ p = ((Jm (ZMod p)) ^ 2) ^ (p / 2) * Jm (ZMod p) := by
        rw [← pow_mul, ← pow_succ]; exact congrArg _ hp'
    _ = scal2 ((2 : ZMod p) ^ (p / 2)) * Jm (ZMod p) := by rw [Jm_sq, scal2_pow]

/-- **Frobenius on the hyperbolic Berggren block.**  `U = 3 + 2J` with `J² = 2`, so in
characteristic `p` we get `U^p = 3 + 2·2^((p−1)/2)·J`: the Frobenius acts on `ℤ[√2] ⊗ 𝔽_p`
by `√2 ↦ ±√2` according to the quadratic character of `2`. -/
theorem Um_pow_card (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    (Um (ZMod p)) ^ p
      = scal2 (3 : ZMod p) + scal2 (2 * (2 : ZMod p) ^ (p / 2)) * Jm (ZMod p) := by
  have hcomm : Commute (scal2 (3 : ZMod p)) (scal2 (2 : ZMod p) * Jm (ZMod p)) :=
    scal2_commute _ _
  rw [Um_decomp, add_pow_char_of_commute p hcomm,
    Commute.mul_pow (scal2_commute (2 : ZMod p) (Jm (ZMod p))), scal2_pow, scal2_pow,
    Jm_pow_card p hp, ZMod.pow_card, ZMod.pow_card, ← mul_assoc, scal2_mul]

/-- Euler's criterion in the form we need: `2^((p−1)/2) = ±1`. -/
theorem two_pow_div_two_eq (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    (2 : ZMod p) ^ (p / 2) = 1 ∨ (2 : ZMod p) ^ (p / 2) = -1 := by
  have hpp : p.Prime := Fact.out
  have hmod : p % 2 = 1 := (Nat.Prime.eq_two_or_odd hpp).resolve_left hp
  have h2 : (2 : ZMod p) ≠ 0 := by
    intro h
    have h' : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
    rw [ZMod.natCast_eq_zero_iff] at h'
    exact hp ((Nat.prime_dvd_prime_iff_eq hpp Nat.prime_two).mp h')
  have hsq : ((2 : ZMod p) ^ (p / 2)) * ((2 : ZMod p) ^ (p / 2)) = 1 := by
    rw [← pow_add]
    have : p / 2 + p / 2 = p - 1 := by omega
    rw [this]
    exact ZMod.pow_card_sub_one_eq_one h2
  exact mul_self_eq_one_iff.mp hsq

/-- **Split case.**  If `2` is a square mod `p`, the hyperbolic generator has order dividing
`p − 1`. -/
theorem B₂_pow_p_sub_one_of_isSquare_two (p : ℕ) [Fact p.Prime] (hp : p ≠ 2)
    (h : IsSquare (2 : ZMod p)) : (B₂ (ZMod p)) ^ (p - 1) = 1 := by
  have hpp : p.Prime := Fact.out
  have hmod : p % 2 = 1 := (Nat.Prime.eq_two_or_odd hpp).resolve_left hp
  have h2 : (2 : ZMod p) ≠ 0 := by
    intro hh
    have h' : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast hh
    rw [ZMod.natCast_eq_zero_iff] at h'
    exact hp ((Nat.prime_dvd_prime_iff_eq hpp Nat.prime_two).mp h')
  have heps : (2 : ZMod p) ^ (p / 2) = 1 := (ZMod.euler_criterion p h2).mp h
  have hUp : (Um (ZMod p)) ^ p = Um (ZMod p) := by
    rw [Um_pow_card p hp, heps, mul_one, ← Um_decomp]
  have hU : (Um (ZMod p)) ^ (p - 1) = 1 := by
    have hsplit : (Um (ZMod p)) ^ p = (Um (ZMod p)) ^ (p - 1) * Um (ZMod p) := by
      rw [← pow_succ]
      congr 1
      omega
    have : (Um (ZMod p)) ^ (p - 1) * Um (ZMod p) = Um (ZMod p) := by rw [← hsplit, hUp]
    calc (Um (ZMod p)) ^ (p - 1)
        = (Um (ZMod p)) ^ (p - 1) * (Um (ZMod p) * !![3, -2; -4, 3]) := by
          rw [Um_mul_inv, mul_one]
      _ = ((Um (ZMod p)) ^ (p - 1) * Um (ZMod p)) * !![3, -2; -4, 3] := by rw [mul_assoc]
      _ = Um (ZMod p) * !![3, -2; -4, 3] := by rw [this]
      _ = 1 := Um_mul_inv
  refine B₂_pow_eq_one_of_block p hp hU ?_
  exact (Nat.even_sub (by omega)).mpr (by simp [Nat.not_even_iff.mpr hmod])

/-- **Inert case.**  If `2` is not a square mod `p`, the hyperbolic generator has order
dividing `p + 1`: p-adically the generator is *elliptic*, not hyperbolic. -/
theorem B₂_pow_p_add_one_of_not_isSquare_two (p : ℕ) [Fact p.Prime] (hp : p ≠ 2)
    (h : ¬ IsSquare (2 : ZMod p)) : (B₂ (ZMod p)) ^ (p + 1) = 1 := by
  have hpp : p.Prime := Fact.out
  have hmod : p % 2 = 1 := (Nat.Prime.eq_two_or_odd hpp).resolve_left hp
  have h2 : (2 : ZMod p) ≠ 0 := by
    intro hh
    have h' : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast hh
    rw [ZMod.natCast_eq_zero_iff] at h'
    exact hp ((Nat.prime_dvd_prime_iff_eq hpp Nat.prime_two).mp h')
  have heps : (2 : ZMod p) ^ (p / 2) = -1 := by
    rcases two_pow_div_two_eq p hp with h1 | h1
    · exact absurd ((ZMod.euler_criterion p h2).mpr h1) h
    · exact h1
  have hU : (Um (ZMod p)) ^ (p + 1) = 1 := by
    rw [pow_succ, Um_pow_card p hp, heps]
    have : (2 : ZMod p) * (-1) = -2 := by ring
    rw [this]
    exact Um_conj_mul
  refine B₂_pow_eq_one_of_block p hp hU ?_
  exact Nat.even_add_one.mpr (Nat.not_even_iff.mpr hmod)

/-- **The conjectured bound.**  For every odd prime the hyperbolic Berggren generator is
periodic mod `p` with period dividing `p² − 1`. -/
theorem B₂_pow_card_sq_sub_one (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    (B₂ (ZMod p)) ^ (p ^ 2 - 1) = 1 := by
  have hpp : p.Prime := Fact.out
  have hp1 : 1 ≤ p := hpp.one_lt.le.trans' (by omega)
  have hfac : p ^ 2 - 1 = (p + 1) * (p - 1) := by
    have := Nat.sq_sub_sq p 1
    simpa using this
  by_cases h : IsSquare (2 : ZMod p)
  · rw [hfac, mul_comm, pow_mul, B₂_pow_p_sub_one_of_isSquare_two p hp h, one_pow]
  · rw [hfac, pow_mul, B₂_pow_p_add_one_of_not_isSquare_two p hp h, one_pow]

theorem B₂_orderOf_dvd (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    orderOf (B₂ (ZMod p)) ∣ p ^ 2 - 1 :=
  orderOf_dvd_of_pow_eq_one (B₂_pow_card_sq_sub_one p hp)

/-! ### Fixed points and the split/inert dichotomy on the null cone -/

/-- The hyperbolic generator has **no** nonzero fixed vector mod an odd prime — in sharp
contrast with the unipotent generators, each of which fixes a null line. -/
theorem B₂_no_nonzero_fixed_point (p : ℕ) [Fact p.Prime] (hp : p ≠ 2)
    (v : Fin 3 → ZMod p) (h : B₂ (ZMod p) *ᵥ v = v) : v = 0 := by
  have hpp : p.Prime := Fact.out
  have h2 : (2 : ZMod p) ≠ 0 := by
    intro hh
    have h' : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast hh
    rw [ZMod.natCast_eq_zero_iff] at h'
    exact hp ((Nat.prime_dvd_prime_iff_eq hpp Nat.prime_two).mp h')
  have h0 := congrFun h 0
  have h1 := congrFun h 1
  have h2' := congrFun h 2
  simp [B₂, Matrix.mulVec, dotProduct, Fin.sum_univ_three] at h0 h1 h2'
  have e0 : (2 : ZMod p) * (v 1 + v 2) = 0 := by linear_combination h0
  have e1 : (2 : ZMod p) * (v 0 + v 2) = 0 := by linear_combination h1
  have e2 : (2 : ZMod p) * (v 0 + v 1 + v 2) = 0 := by linear_combination h2'
  have f0 : v 1 + v 2 = 0 := by
    rcases mul_eq_zero.mp e0 with hh | hh
    · exact absurd hh h2
    · exact hh
  have f1 : v 0 + v 2 = 0 := by
    rcases mul_eq_zero.mp e1 with hh | hh
    · exact absurd hh h2
    · exact hh
  have f2 : v 0 + v 1 + v 2 = 0 := by
    rcases mul_eq_zero.mp e2 with hh | hh
    · exact absurd hh h2
    · exact hh
  have hv2 : v 2 = 0 := by linear_combination f0 + f1 - f2
  have hv1 : v 1 = 0 := by linear_combination f0 - hv2
  have hv0 : v 0 = 0 := by linear_combination f1 - hv2
  funext i
  fin_cases i <;> simp [hv0, hv1, hv2]

/-- **The p-adic split/inert dichotomy.**  `B₂` has a nonzero eigenvector on the null cone
mod `p` if and only if `2` is a quadratic residue mod `p`.  The eigenvectors are `(1,1,±√2)`
with eigenvalues `3 ± 2√2` — the p-adic shadow of the silver ratio. -/
theorem B₂_null_eigenvector_iff_isSquare_two (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    (∃ (lam : ZMod p) (v : Fin 3 → ZMod p), v ≠ 0 ∧ lorentz (ZMod p) v = 0 ∧
      B₂ (ZMod p) *ᵥ v = lam • v) ↔ IsSquare (2 : ZMod p) := by
  have hpp : p.Prime := Fact.out
  have h2 : (2 : ZMod p) ≠ 0 := by
    intro hh
    have h' : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast hh
    rw [ZMod.natCast_eq_zero_iff] at h'
    exact hp ((Nat.prime_dvd_prime_iff_eq hpp Nat.prime_two).mp h')
  constructor
  · rintro ⟨lam, v, hv0, hvnull, hveq⟩
    have hker : (B₂ (ZMod p) - lam • (1 : Matrix (Fin 3) (Fin 3) (ZMod p))) *ᵥ v = 0 := by
      rw [Matrix.sub_mulVec, hveq]
      funext i
      fin_cases i <;>
        simp [Matrix.mulVec, dotProduct, Matrix.smul_apply, Matrix.one_apply]
    have hdet : (B₂ (ZMod p) - lam • (1 : Matrix (Fin 3) (Fin 3) (ZMod p))).det = 0 :=
      Matrix.exists_mulVec_eq_zero_iff.mp ⟨v, hv0, hker⟩
    have hpoly : (lam + 1) * (lam ^ 2 - 6 * lam + 1) = 0 := by
      rw [Matrix.det_fin_three] at hdet
      simp [B₂, Matrix.sub_apply, Matrix.smul_apply, smul_eq_mul] at hdet
      linear_combination -hdet
    rcases mul_eq_zero.mp hpoly with hlam | hlam
    · -- eigenvalue −1: its eigenline `(t,−t,0)` is not null
      exfalso
      have hlam' : lam = -1 := by linear_combination hlam
      subst hlam'
      have h0 := congrFun hveq 0
      have h1 := congrFun hveq 1
      have h2' := congrFun hveq 2
      simp [B₂, Matrix.mulVec, dotProduct, Fin.sum_univ_three] at h0 h1 h2'
      have e2 : (2 : ZMod p) * v 2 = 0 := by linear_combination h2' - h0
      have hv2 : v 2 = 0 := by
        rcases mul_eq_zero.mp e2 with hh | hh
        · exact absurd hh h2
        · exact hh
      have esum : (2 : ZMod p) * (v 0 + v 1) = 0 := by linear_combination h0 - 2 * hv2
      have hsum : v 0 + v 1 = 0 := by
        rcases mul_eq_zero.mp esum with hh | hh
        · exact absurd hh h2
        · exact hh
      have hv1 : v 1 = -v 0 := by linear_combination hsum
      have hnull : (2 : ZMod p) * (v 0 * v 0) = 0 := by
        simp [lorentz, hv1, hv2] at hvnull
        linear_combination hvnull
      have hv0' : v 0 = 0 := by
        rcases mul_eq_zero.mp hnull with hh | hh
        · exact absurd hh h2
        · exact (mul_self_eq_zero.mp hh)
      apply hv0
      funext i
      fin_cases i <;> simp [hv0', hv1, hv2]
    · -- eigenvalue 3 ± 2√2 forces 2 to be a square
      refine ⟨(lam - 3) / 2, ?_⟩
      field_simp
      linear_combination -hlam
  · rintro ⟨s, hs⟩
    refine ⟨3 + 2 * s, ![1, 1, s], ?_, ?_, ?_⟩
    · intro hcon
      have := congrFun hcon 0
      simp at this
    · simp [lorentz]
      linear_combination hs
    · funext i
      fin_cases i <;>
        simp [B₂, Matrix.mulVec, dotProduct, Fin.sum_univ_three] <;>
        first
          | ring1
          | linear_combination (2 : ZMod p) * hs

/-- Quadratic reciprocity turns the dichotomy into a congruence condition on `p`. -/
theorem B₂_null_eigenvector_iff_mod_eight (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    (∃ (lam : ZMod p) (v : Fin 3 → ZMod p), v ≠ 0 ∧ lorentz (ZMod p) v = 0 ∧
      B₂ (ZMod p) *ᵥ v = lam • v) ↔ p % 8 = 1 ∨ p % 8 = 7 :=
  (B₂_null_eigenvector_iff_isSquare_two p hp).trans (ZMod.exists_sq_eq_two_iff hp)

/-! ## Depth: lifting from `ZMod p` to `ZMod (p^k)` -/

/-- Entrywise divisibility of an integer matrix. -/
def EntryDvd (d : ℤ) (A : Matrix (Fin 3) (Fin 3) ℤ) : Prop := ∀ i j, d ∣ A i j

namespace EntryDvd

theorem mono {d e : ℤ} {A : Matrix (Fin 3) (Fin 3) ℤ} (h : d ∣ e) (hA : EntryDvd e A) :
    EntryDvd d A := fun i j => h.trans (hA i j)

theorem add {d : ℤ} {A B : Matrix (Fin 3) (Fin 3) ℤ} (hA : EntryDvd d A) (hB : EntryDvd d B) :
    EntryDvd d (A + B) := fun i j => by
  simpa [Matrix.add_apply] using dvd_add (hA i j) (hB i j)

theorem mul {d e : ℤ} {A B : Matrix (Fin 3) (Fin 3) ℤ} (hA : EntryDvd d A)
    (hB : EntryDvd e B) : EntryDvd (d * e) (A * B) := fun i j => by
  rw [Matrix.mul_apply]
  exact Finset.dvd_sum fun k _ => mul_dvd_mul (hA i k) (hB k j)

theorem mul_right {d : ℤ} {A : Matrix (Fin 3) (Fin 3) ℤ} (hA : EntryDvd d A)
    (B : Matrix (Fin 3) (Fin 3) ℤ) : EntryDvd d (A * B) := fun i j => by
  rw [Matrix.mul_apply]
  exact Finset.dvd_sum fun k _ => Dvd.dvd.mul_right (hA i k) _

end EntryDvd

/-- Entrywise divisibility passes to matrix–vector products. -/
theorem entryDvd_mulVec {d : ℤ} {A : Matrix (Fin 3) (Fin 3) ℤ} (h : EntryDvd d A)
    (v : Fin 3 → ℤ) (i : Fin 3) : d ∣ (A *ᵥ v) i := by
  have hsum : (A *ᵥ v) i = ∑ j : Fin 3, A i j * v j := by
    simp [Matrix.mulVec, dotProduct]
  rw [hsum]
  exact Finset.dvd_sum fun j _ => Dvd.dvd.mul_right (h i j) _

/-- Generic binomial bound: `(1+X)^n = 1 + nX + X²·C`. -/
theorem pow_one_add_eq {S : Type*} [Ring S] (X : S) (n : ℕ) :
    ∃ C : S, (1 + X) ^ n = 1 + (n : S) * X + X ^ 2 * C := by
  induction n with
  | zero => exact ⟨0, by simp⟩
  | succ n ih =>
      obtain ⟨C, hC⟩ := ih
      refine ⟨C + (n : S) + C * X, ?_⟩
      have hcom : (n : S) * X * X = X ^ 2 * (n : S) := by
        rw [mul_assoc, ← pow_two]
        exact (Nat.cast_commute n (X ^ 2)).eq
      have expand : (1 + (n : S) * X + X ^ 2 * C) * (1 + X)
          = (1 + ((n : S) + 1) * X + X ^ 2 * (C + (n : S) + C * X))
            + ((n : S) * X * X - X ^ 2 * (n : S)) := by
        noncomm_ring
      rw [pow_succ, hC, expand, hcom]
      push_cast
      noncomm_ring

/-- Scalar-matrix multiplication is entrywise multiplication (integer version). -/
theorem natCast_matrix_mul_int (m : ℕ) (M : Matrix (Fin 3) (Fin 3) ℤ) :
    ((m : Matrix (Fin 3) (Fin 3) ℤ)) * M = (m : ℤ) • M := natCast_matrix_mul m M

/-- **Hensel step.**  If `A ≡ 1 mod p^j` (with `j ≥ 1`) then `A^p ≡ 1 mod p^(j+1)`. -/
theorem lift_step (A : Matrix (Fin 3) (Fin 3) ℤ) (p j : ℕ) (hj : 1 ≤ j)
    (h : EntryDvd ((p : ℤ) ^ j) (A - 1)) : EntryDvd ((p : ℤ) ^ (j + 1)) (A ^ p - 1) := by
  obtain ⟨C, hC⟩ := pow_one_add_eq (A - 1) p
  have hA : (1 : Matrix (Fin 3) (Fin 3) ℤ) + (A - 1) = A := by
    rw [add_sub_cancel]
  rw [hA] at hC
  have hsplit : A ^ p - 1
      = (p : Matrix (Fin 3) (Fin 3) ℤ) * (A - 1) + (A - 1) ^ 2 * C := by
    rw [hC]
    noncomm_ring
  rw [hsplit]
  refine EntryDvd.add ?_ ?_
  · rw [natCast_matrix_mul_int]
    intro i j'
    rw [Matrix.smul_apply, smul_eq_mul, pow_succ']
    exact mul_dvd_mul_left _ (h i j')
  · have hsq : EntryDvd ((p : ℤ) ^ j * (p : ℤ) ^ j) ((A - 1) ^ 2) := by
      rw [pow_two]
      exact h.mul h
    have hprod : EntryDvd ((p : ℤ) ^ j * (p : ℤ) ^ j) ((A - 1) ^ 2 * C) := hsq.mul_right C
    refine EntryDvd.mono ?_ hprod
    rw [← pow_add]
    exact pow_dvd_pow _ (by omega)

/-- **Hensel lift.**  `A ≡ 1 mod p` implies `A^(p^k) ≡ 1 mod p^(k+1)`. -/
theorem lift_pow (A : Matrix (Fin 3) (Fin 3) ℤ) (p : ℕ) (h : EntryDvd (p : ℤ) (A - 1))
    (k : ℕ) : EntryDvd ((p : ℤ) ^ (k + 1)) (A ^ (p ^ k) - 1) := by
  induction k with
  | zero => simpa using h
  | succ k ih =>
      have hstep := lift_step (A ^ (p ^ k)) p (k + 1) (by omega) ih
      rwa [← pow_mul, ← pow_succ] at hstep

/-- Reduction of an integer matrix mod `m`. -/
def redRing (m : ℕ) : Matrix (Fin 3) (Fin 3) ℤ →+* Matrix (Fin 3) (Fin 3) (ZMod m) :=
  (Int.castRingHom (ZMod m)).mapMatrix

theorem redRing_B₂ (m : ℕ) : redRing m (B₂ ℤ) = B₂ (ZMod m) := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [redRing, RingHom.mapMatrix_apply, B₂]

theorem entryDvd_iff_red (m : ℕ) (A : Matrix (Fin 3) (Fin 3) ℤ) :
    EntryDvd (m : ℤ) A ↔ redRing m A = 0 := by
  constructor
  · intro h
    ext i j
    simpa [redRing, RingHom.mapMatrix_apply] using
      (ZMod.intCast_zmod_eq_zero_iff_dvd (A i j) m).mpr (h i j)
  · intro h i j
    have := congrFun (congrFun h i) j
    simp only [redRing, RingHom.mapMatrix_apply, Matrix.map_apply, Matrix.zero_apply,
      Int.coe_castRingHom] at this
    exact (ZMod.intCast_zmod_eq_zero_iff_dvd (A i j) m).mp this

/-- The mod-`p` periodicity of the hyperbolic generator, transported to `ℤ`. -/
theorem B₂_int_pow_sub_one_dvd (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    EntryDvd (p : ℤ) ((B₂ ℤ) ^ (p ^ 2 - 1) - 1) := by
  rw [entryDvd_iff_red]
  rw [map_sub, map_pow, map_one, redRing_B₂, B₂_pow_card_sq_sub_one p hp, sub_self]

/-- **p-adic periodicity of the hyperbolic generator.**  Mod `p^k` the hyperbolic Berggren
move is periodic with period dividing `(p² − 1)·p^(k−1)`: a prime-to-`p` part bounded by
`p² − 1` (the "spectral" period) times a `p`-power coming from the depth. -/
theorem B₂_pow_eq_one_padic (p k : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    (B₂ (ZMod (p ^ (k + 1)))) ^ ((p ^ 2 - 1) * p ^ k) = 1 := by
  have hlift := lift_pow ((B₂ ℤ) ^ (p ^ 2 - 1)) p (B₂_int_pow_sub_one_dvd p hp) k
  rw [← pow_mul] at hlift
  have hcast : ((p : ℤ) ^ (k + 1)) = ((p ^ (k + 1) : ℕ) : ℤ) := by push_cast; ring
  rw [hcast, entryDvd_iff_red] at hlift
  rw [map_sub, map_pow, map_one, redRing_B₂] at hlift
  have := sub_eq_zero.mp hlift
  exact this

/-- **p-adic contraction.**  For every integer vector `v`, the orbit point
`B₂^((p²−1)p^k) v` agrees with `v` to p-adic precision `p^(k+1)`; i.e. the p-adic distance
`|B₂^N v − v|_p ≤ p^(−(k+1))`. -/
theorem B₂_padic_contraction (p k : ℕ) [Fact p.Prime] (hp : p ≠ 2)
    (v : Fin 3 → ℤ) (i : Fin 3) :
    ((p : ℤ) ^ (k + 1)) ∣ (((B₂ ℤ) ^ ((p ^ 2 - 1) * p ^ k)) *ᵥ v) i - v i := by
  have hlift := lift_pow ((B₂ ℤ) ^ (p ^ 2 - 1)) p (B₂_int_pow_sub_one_dvd p hp) k
  rw [← pow_mul] at hlift
  have key := entryDvd_mulVec hlift v i
  rwa [Matrix.sub_mulVec, Matrix.one_mulVec, Pi.sub_apply] at key

/-- **The unipotent generator is a p-adic contraction of depth `k`.**
`B₁^(p^k) ≡ 1 mod p^k` already over `ℤ`. -/
theorem B₁_int_pow_sub_one (p k : ℕ) (hp : p.Prime) (hodd : p ≠ 2) :
    EntryDvd ((p : ℤ) ^ k) ((B₁ ℤ) ^ (p ^ k) - 1) := by
  have hform := pow_unipotent_formula (N₁ ℤ) N₁_cube (p ^ k)
  rw [← B₁_eq_one_add] at hform
  have hsub : (B₁ ℤ) ^ (p ^ k) - 1
      = ((p ^ k : ℕ) : Matrix (Fin 3) (Fin 3) ℤ) * N₁ ℤ
        + (((p ^ k).choose 2 : ℕ) : Matrix (Fin 3) (Fin 3) ℤ) * (N₁ ℤ) ^ 2 := by
    rw [hform]
    noncomm_ring
  rw [hsub]
  refine EntryDvd.add ?_ ?_
  · rw [natCast_matrix_mul_int]
    intro i j
    refine ⟨(N₁ ℤ) i j, ?_⟩
    rw [Matrix.smul_apply, smul_eq_mul]
    push_cast
    ring
  · obtain ⟨t, ht⟩ := pow_dvd_choose_two p k hp hodd
    rw [natCast_matrix_mul_int]
    intro i j
    refine ⟨(t : ℤ) * ((N₁ ℤ) ^ 2) i j, ?_⟩
    rw [Matrix.smul_apply, smul_eq_mul, ht]
    push_cast
    ring

/-- **p-adic contraction for the unipotent generator.**  `|B₁^(p^k) v − v|_p ≤ p^(−k)`. -/
theorem B₁_padic_contraction (p k : ℕ) (hp : p.Prime) (hodd : p ≠ 2)
    (v : Fin 3 → ℤ) (i : Fin 3) :
    ((p : ℤ) ^ k) ∣ (((B₁ ℤ) ^ (p ^ k)) *ᵥ v) i - v i := by
  have key := entryDvd_mulVec (B₁_int_pow_sub_one p k hp hodd) v i
  rwa [Matrix.sub_mulVec, Matrix.one_mulVec, Pi.sub_apply] at key

/-- **The reduced dynamical system is genuinely nonabelian for every odd `p`:**
the unipotent and hyperbolic generators do not commute mod `p`. -/
theorem B₁_B₂_noncommute (p : ℕ) [hp' : Fact p.Prime] (hp : p ≠ 2) :
    B₁ (ZMod p) * B₂ (ZMod p) ≠ B₂ (ZMod p) * B₁ (ZMod p) := by
  intro h
  have h00 : (B₁ (ZMod p) * B₂ (ZMod p)) 0 0 = (B₂ (ZMod p) * B₁ (ZMod p)) 0 0 := by rw [h]
  have e1 : (B₁ (ZMod p) * B₂ (ZMod p)) 0 0 = 1 := by
    simp [B₁, B₂, Matrix.mul_apply, Fin.sum_univ_three]
  have e2 : (B₂ (ZMod p) * B₁ (ZMod p)) 0 0 = 9 := by
    simp [B₂, B₁, Matrix.mul_apply, Fin.sum_univ_three]
    norm_num
  rw [e1, e2] at h00
  have h8 : ((8 : ℕ) : ZMod p) = 0 := by
    push_cast
    linear_combination -h00
  have hdvd : p ∣ 8 := (ZMod.natCast_eq_zero_iff _ _).mp h8
  have hdvd2 : p ∣ 2 ^ 3 := by simpa using hdvd
  exact hp ((Nat.prime_dvd_prime_iff_eq hp'.out Nat.prime_two).mp
    (hp'.out.dvd_of_dvd_pow hdvd2))

/-- **Periodic orbits.**  Every point of `(ZMod p^(k+1))³` — in particular every point of the
null cone — is a periodic point of the hyperbolic generator, with period dividing
`(p²−1)·p^k`. -/
theorem B₂_orbit_periodic (p k : ℕ) [Fact p.Prime] (hp : p ≠ 2)
    (v : Fin 3 → ZMod (p ^ (k + 1))) :
    (B₂ (ZMod (p ^ (k + 1)))) ^ ((p ^ 2 - 1) * p ^ k) *ᵥ v = v := by
  rw [B₂_pow_eq_one_padic p k hp, Matrix.one_mulVec]

/-! ## The boundary of the tree does not survive reduction

The Berggren tree is a ternary tree: `3^d` vertices at depth `d`.  Reducing mod `m` lands in a
set of size `m³`, so the reduction map on words is massively non-injective; the "boundary at
infinity" cannot be embedded in a fixed finite level `ZMod (p^k)`.  (What does survive is the
inverse-limit statement `B₂_padic_contraction`.) -/

/-- The three generators indexed by `Fin 3`. -/
def gen (R : Type*) [CommRing R] (i : Fin 3) : Matrix (Fin 3) (Fin 3) R :=
  ![B₁ R, B₂ R, B₃ R] i

/-- The matrix attached to a word in the generators. -/
def wordMat (R : Type*) [CommRing R] (w : List (Fin 3)) : Matrix (Fin 3) (Fin 3) R :=
  (w.map (gen R)).prod

/-- The root of the tree, the triple `(3,4,5)`. -/
def root (R : Type*) [CommRing R] : Fin 3 → R := ![3, 4, 5]

theorem lorentz_root : lorentz R (root R) = 0 := by
  simp [lorentz, root]
  ring

/-- Each generator preserves the Lorentz form. -/
theorem lorentz_gen (i : Fin 3) (v : Fin 3 → R) : lorentz R (gen R i *ᵥ v) = lorentz R v := by
  fin_cases i <;>
    simp [gen, lorentz, B₁, B₂, B₃, Matrix.mulVec, dotProduct, Fin.sum_univ_three] <;> ring

/-- Every vertex of the tree lies on the null cone. -/
theorem lorentz_wordMat (w : List (Fin 3)) :
    lorentz R (wordMat R w *ᵥ root R) = 0 := by
  induction w with
  | nil => simpa [wordMat, Matrix.one_mulVec] using lorentz_root (R := R)
  | cons a w ih =>
      have hstep : wordMat R (a :: w) *ᵥ root R = gen R a *ᵥ (wordMat R w *ᵥ root R) := by
        simp [wordMat, List.map_cons, List.prod_cons, Matrix.mulVec_mulVec]
      rw [hstep, lorentz_gen]
      exact ih

/-- **Collapse of the boundary.**  As soon as `m³ < 3^d`, two distinct words of length `d`
have the same image mod `m`. -/
theorem tree_collision_mod (m d : ℕ) [NeZero m] (h : m ^ 3 < 3 ^ d) :
    ∃ w₁ w₂ : Fin d → Fin 3, w₁ ≠ w₂ ∧
      wordMat (ZMod m) (List.ofFn w₁) *ᵥ root (ZMod m)
        = wordMat (ZMod m) (List.ofFn w₂) *ᵥ root (ZMod m) := by
  have hcard : Fintype.card (Fin 3 → ZMod m) < Fintype.card (Fin d → Fin 3) := by
    simpa [Fintype.card_fun, ZMod.card] using h
  obtain ⟨w₁, w₂, hne, heq⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt
      (fun w : Fin d → Fin 3 => wordMat (ZMod m) (List.ofFn w) *ᵥ root (ZMod m)) hcard
  exact ⟨w₁, w₂, hne, heq⟩

end PadicBerggren