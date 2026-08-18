/-
# Finite-level rigidity index and its Euler factor (Cycle 5)

This file closes conjecture **N2** of `FUTURE_DIRECTIONS.md` for the Conjecture-C thread
(`Catalog/Probability/RenormalizedNormalizedFactorization.lean`,
`Catalog/Probability/RenormalizedFactorizationValuation.lean`,
`Catalog/Probability/RenormalizedFactorizationExact.lean`).

In the valuation setting the fibre of the renormalized-product map over a realizable target is
`n = m - 1` free copies of the valuation-zero group
(`DiscreteVal.card_factorizations`).  Conjecture N2 predicted what happens when one *truncates*
the valuation ring modulo `π ^ D`, i.e. replaces the valuation-zero group by the unit group of a
finite local ring.  Here this is proved:

* `card_fibre` — for **any** commutative group `U` and any target `g`, the fibre of the
  `m = n + 1`-fold product map has exactly `#U ^ n` elements; the zeroth slot is determined and
  the other `n` are free.  (This is the truncated analogue of `card_factorizations`, proved by an
  explicit `Fin.cons` bijection rather than by transport, since a finite ring has no
  uniformizer.)
* `card_fibre_zmod_prime_pow` — at level `D ≥ 1` over `ℤ_p`, i.e. in `(ZMod (p ^ D))ˣ`, the fibre
  has exactly `((p - 1) * p ^ (D - 1)) ^ n` elements, which is the predicted
  `((q₀ - 1) q₀^{D-1})^{m-1}` with residue-field size `q₀ = p`.
* `card_fibre_zmod_succ` — the level-to-level recursion `#fibre_{D+1} = p ^ n · #fibre_D`.
* `euler_factor_identity` — the resulting generating function is rational with denominator
  exactly `1 - p ^ n T`:
  `(1 - p^n T) * ∑_{D < N} #fibre_{D+1} · T^{D+1} = (p-1)^n · T · (1 - (p^n T)^N)`.
  So the rigidity index `n = m - 1` is literally the exponent appearing in the Euler factor.
* `card_fibre_eq_one_iff` / `zmod_finite_rigidity_dichotomy` — the finite-level dichotomy: the
  truncated factorization is unique iff `m = 1` or the truncated unit group is trivial.  The
  second alternative is a genuine corner case that does **not** occur in the valuation setting
  (`(ZMod 2)ˣ` is trivial, so `p = 2, D = 1` is rigid for every `m`); this sharpens N2.

No `sorry`, no `native_decide`, no new axioms.
-/
import Mathlib

namespace Catalog.Probability.RenormalizedFactorizationFiniteLevel

open Finset

/-! ## The truncated fibre -/

variable {U : Type*} [CommGroup U]

/-- **The fibre of the `m = n + 1`-fold product map is `n` free slots.**  An `m`-tuple with
prescribed product is the same thing as an arbitrary choice of its last `n` entries: the zeroth
entry is forced to be `g * (∏ rest)⁻¹`. -/
def fibreEquivFun (n : ℕ) (g : U) :
    {f : Fin (n + 1) → U // ∏ i, f i = g} ≃ (Fin n → U) where
  toFun f := fun j => f.1 j.succ
  invFun w := ⟨Fin.cons (g * (∏ j, w j)⁻¹) w, by rw [Fin.prod_univ_succ]; simp⟩
  left_inv := by
    intro f
    apply Subtype.ext
    have h' : f.1 0 * ∏ j : Fin n, f.1 j.succ = g := by
      rw [← Fin.prod_univ_succ]; exact f.2
    funext i
    dsimp only
    refine Fin.cases ?_ ?_ i
    · rw [Fin.cons_zero]; exact (eq_mul_inv_of_mul_eq h').symm
    · intro j; rw [Fin.cons_succ]
  right_inv := by
    intro w; funext j; simp

/-- **Truncated rigidity index.**  For `m = n + 1` slots the fibre over *any* target has exactly
`#U ^ n` elements: the rigidity index is `m - 1`, exactly as in the valuation setting.  (Both
sides are `0` for infinite `U` and `n ≥ 1`, the `Nat.card` reading of "infinitely many
factorizations".) -/
theorem card_fibre (n : ℕ) (g : U) :
    Nat.card {f : Fin (n + 1) → U // ∏ i, f i = g} = Nat.card U ^ n := by
  rw [Nat.card_congr (fibreEquivFun n g), Nat.card_fun, Nat.card_eq_fintype_card (α := Fin n),
    Fintype.card_fin]

/-- **Finite-level dichotomy.**  For a finite group `U` the truncated factorization into
`m = n + 1` slots is unique iff `m = 1` or the group itself is trivial.  The second alternative
is invisible in the valuation setting, where the valuation-zero group is always infinite. -/
theorem card_fibre_eq_one_iff [Finite U] (n : ℕ) (g : U) :
    Nat.card {f : Fin (n + 1) → U // ∏ i, f i = g} = 1 ↔ n = 0 ∨ Nat.card U = 1 := by
  rw [card_fibre, Nat.pow_eq_one]
  exact or_comm

/-! ## Level `D` over `ℤ_p`: the predicted count `((q₀ - 1) q₀ ^ (D-1)) ^ (m-1)` -/

variable (p D n : ℕ) [Fact p.Prime]

/-- The unit group of `ZMod (p ^ D)` is nontrivial as a finite type. -/
instance : NeZero (p ^ D) := ⟨pow_ne_zero _ (Nat.Prime.ne_zero Fact.out)⟩

/-- **Finite-level fibre count (conjecture N2, main statement).**  Modulo `p ^ D` with `D ≥ 1`
the fibre of the `m = n + 1`-fold product map over any target has exactly
`((p - 1) * p ^ (D - 1)) ^ n` elements — the predicted `((q₀ - 1) q₀ ^ (D - 1)) ^ (m - 1)` for
residue-field size `q₀ = p`. -/
theorem card_fibre_zmod_prime_pow (hD : 1 ≤ D) (g : (ZMod (p ^ D))ˣ) :
    Nat.card {f : Fin (n + 1) → (ZMod (p ^ D))ˣ // ∏ i, f i = g}
      = ((p - 1) * p ^ (D - 1)) ^ n := by
  rw [card_fibre]
  congr 1
  rw [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient,
    Nat.totient_prime_pow Fact.out (by omega)]
  ring

/-- **Level-to-level recursion.**  Raising the truncation level by one multiplies the fibre count
by `p ^ n`: the rigidity index `n = m - 1` is the exponent of the growth rate. -/
theorem card_fibre_zmod_succ (hD : 1 ≤ D) (g : (ZMod (p ^ D))ˣ) (g' : (ZMod (p ^ (D + 1)))ˣ) :
    Nat.card {f : Fin (n + 1) → (ZMod (p ^ (D + 1)))ˣ // ∏ i, f i = g'}
      = p ^ n * Nat.card {f : Fin (n + 1) → (ZMod (p ^ D))ˣ // ∏ i, f i = g} := by
  rw [card_fibre_zmod_prime_pow p D n hD g, card_fibre_zmod_prime_pow p (D + 1) n (by omega) g']
  have hDD : D + 1 - 1 = (D - 1) + 1 := by omega
  rw [hDD, pow_succ, ← mul_pow]
  ring

/-! ## The Euler factor

The counting function `D ↦ #fibre_D = (p-1)^n p^{n(D-1)}` is geometric with ratio `p ^ n`,
so its generating function is rational with denominator `1 - p ^ n T`.  The following identity
states exactly that, in the strong finite-`N` form (no convergence hypotheses are needed). -/

variable {R : Type*} [CommRing R]

/-- **Euler factor of the rigidity index (conjecture N2, generating-function form).**
`(1 - p^n T) · ∑_{D < N} #fibre_{D+1} · T^{D+1} = (p-1)^n · T · (1 - (p^n T)^N)`,
where `#fibre_{D+1} = ((p-1) p^D)^n` is the level-`D+1` fibre count of
`card_fibre_zmod_prime_pow`.  Hence the generating function is rational with denominator exactly
`1 - p^{m-1} T`: the rigidity index is the degree of the Euler factor. -/
theorem euler_factor_identity (N : ℕ) (T : R) :
    (1 - (p : R) ^ n * T) * ∑ D ∈ range N, (((p - 1) * p ^ D : ℕ) ^ n : R) * T ^ (D + 1)
      = (((p : R) - 1) ^ n) * T * (1 - ((p : R) ^ n * T) ^ N) := by
  have hp1 : ((p - 1 : ℕ) : R) = (p : R) - 1 := by
    have : 1 ≤ p := Nat.Prime.one_le Fact.out
    push_cast [Nat.cast_sub this]
    ring
  have hsum : ∑ D ∈ range N, (((p - 1) * p ^ D : ℕ) ^ n : R) * T ^ (D + 1)
      = (((p : R) - 1) ^ n) * T * ∑ D ∈ range N, ((p : R) ^ n * T) ^ D := by
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl (fun D _ => ?_)
    rw [Nat.cast_mul, Nat.cast_pow, hp1, mul_pow, mul_pow, ← pow_mul, ← pow_mul, mul_comm D n]
    ring
  have hg : (1 - ((p : R) ^ n * T)) * ∑ D ∈ range N, ((p : R) ^ n * T) ^ D
      = 1 - ((p : R) ^ n * T) ^ N := mul_neg_geom_sum _ _
  rw [hsum]
  linear_combination ((p : R) - 1) ^ n * T * hg

/-- **Finite-level rigidity dichotomy over `ℤ_p`.**  As soon as the truncated unit group is
nontrivial — i.e. `p` is odd, or `p = 2` and `D ≥ 2` — the truncated factorization is unique
exactly when `m = 1`, matching the valuation-level dichotomy `rigidity_dichotomy`. -/
theorem zmod_finite_rigidity_dichotomy (hD : 1 ≤ D) (hne : 2 ≤ (p - 1) * p ^ (D - 1))
    (g : (ZMod (p ^ D))ˣ) :
    Nat.card {f : Fin (n + 1) → (ZMod (p ^ D))ˣ // ∏ i, f i = g} = 1 ↔ n = 0 := by
  rw [card_fibre_zmod_prime_pow p D n hD g]
  constructor
  · intro h
    rcases Nat.pow_eq_one.mp h with h' | h'
    · omega
    · exact h'
  · rintro rfl; simp

/-- **The exceptional level.**  For `p = 2, D = 1` the truncated unit group is trivial, so the
truncated factorization is unique for *every* `m` — the one corner case where finite-level
rigidity is strictly stronger than valuation-level rigidity. -/
theorem zmod_two_level_one_rigid (n : ℕ) (g : (ZMod (2 ^ 1))ˣ) :
    Nat.card {f : Fin (n + 1) → (ZMod (2 ^ 1))ˣ // ∏ i, f i = g} = 1 := by
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  rw [card_fibre_zmod_prime_pow 2 1 n le_rfl g]
  norm_num

/-! ## Level transition maps (first step of conjecture N6)

The finite levels form an inverse system: a factorization can be pushed forward along any
surjective homomorphism, and *every* factorization downstairs lifts.  Applied to the reduction
`(ZMod (p ^ (D+1)))ˣ → (ZMod (p ^ D))ˣ` this says the tower of fibres has surjective transition
maps, which is what makes its inverse limit nonempty. -/

section Transition

variable {V : Type*} [CommGroup V]

/-- Push a factorization forward along a group homomorphism. -/
def pushFibre (φ : U →* V) (n : ℕ) (g : U) :
    {f : Fin (n + 1) → U // ∏ i, f i = g} → {f : Fin (n + 1) → V // ∏ i, f i = φ g} :=
  fun f => ⟨fun i => φ (f.1 i), by rw [← map_prod, f.2]⟩

/-- **Every factorization downstairs lifts.**  If `φ` is a surjective homomorphism then the
induced map on fibres is surjective: one lifts the `n` free slots arbitrarily and repairs the
zeroth slot. -/
theorem pushFibre_surjective (φ : U →* V) (hφ : Function.Surjective φ) (n : ℕ) (g : U) :
    Function.Surjective (pushFibre φ n g) := by
  intro f'
  choose lift hlift using hφ
  refine ⟨⟨Fin.cons (g * (∏ j : Fin n, lift (f'.1 j.succ))⁻¹)
      (fun j : Fin n => lift (f'.1 j.succ)), by rw [Fin.prod_univ_succ]; simp⟩, ?_⟩
  apply Subtype.ext
  funext i
  dsimp only [pushFibre]
  refine Fin.cases ?_ ?_ i
  · rw [Fin.cons_zero, map_mul, map_inv, map_prod]
    simp only [hlift]
    have h : f'.1 0 * ∏ j : Fin n, f'.1 j.succ = φ g := by
      rw [← Fin.prod_univ_succ]; exact f'.2
    exact (eq_mul_inv_of_mul_eq h).symm
  · intro j
    rw [Fin.cons_succ]
    exact hlift _

end Transition

/-- **The `p`-adic tower of fibres has surjective transition maps.**  Every factorization modulo
`p ^ D` is the reduction of a factorization modulo `p ^ (D + 1)`; combined with
`card_fibre_zmod_prime_pow` this is the inverse system whose limit is the valuation-level
fibre. -/
theorem zmod_level_transition_surjective (g : (ZMod (p ^ (D + 1)))ˣ) :
    Function.Surjective
      (pushFibre (ZMod.unitsMap (pow_dvd_pow p (Nat.le_succ D))) n g) :=
  pushFibre_surjective _ (ZMod.unitsMap_surjective _) n g

/-! ## Lab notes (cycle 5)

Exhaustive enumeration of `#{f : Fin m → (ZMod N)ˣ | ∏ f = g}` (computed by brute force over the
whole unit group, `g = 1` unless stated):

| `N` | `m = 1` | `m = 2` | `m = 3` | predicted `#U^{m-1}` |
|---|---|---|---|---|
| `3 = 3^1` | `1` | `2` | `4` | `2^{m-1}` |
| `9 = 3^2` | `1` | `6` | `36` | `6^{m-1}` |
| `27 = 3^3` | `1` | `18` | — | `18^{m-1}` |
| `81 = 3^4` | `1` | `54` | — | `54^{m-1}` |
| `4 = 2^2` | `1` | `2` | `4` | `2^{m-1}` |
| `8 = 2^3` | `1` | `4` | `16` | `4^{m-1}` |
| `25 = 5^2` | `1` | `20` | — | `20^{m-1}` |
| `2 = 2^1` | `1` | `1` | `1` | `1^{m-1}` (trivial unit group) |

The target does not matter: for `N = 9`, `m = 2` the fibre over `g = -1` also has `6` elements,
as `card_fibre` (which is uniform in `g`) requires.  The `3`-adic column
`2, 6, 18, 54` has constant ratio `3 = p^{m-1}` at `m = 2`, which is the recursion
`card_fibre_zmod_succ` and the denominator `1 - p^{m-1} T` of `euler_factor_identity`.
The row `N = 2` is the exceptional case isolated in `zmod_two_level_one_rigid`.
-/

end Catalog.Probability.RenormalizedFactorizationFiniteLevel