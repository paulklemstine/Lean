/-
# The residue dial at discriminant `-84`: a Klein four-group of dials

Second instance of the `factor3` experiment RANDOM-BQF (#370).  Discriminant
`D = -84` has class number `h = 4` and *four* genera, so — exactly as for
`D = -20` — each class is a genus and the representation vector degenerates to a
function of `N mod 84`.

The four reduced forms of discriminant `-84` are

  `f₁ = x² + 21y²`,  `f₂ = 2x² + 2xy + 11y²`,
  `f₃ = 3x² + 7y²`,  `f₄ = 5x² + 4xy + 5y²`,

indexed here by `Bool × Bool` with `f₁ ↔ (false, false)`, `f₂ ↔ (true, false)`,
`f₃ ↔ (false, true)`, `f₄ ↔ (true, true)`.

Main results:

* `sound84` / `disj84` : the unit values of `fᵢ` lie in three residues mod `84`
  (`f₁ : {1,25,37}`, `f₂ : {11,23,71}`, `f₃ : {19,31,55}`, `f₄ : {5,17,41}`),
  and these four triples are pairwise disjoint (finite checks in `ZMod 84`).
* `dial84` : hence a `ResidueDial 84 (Bool × Bool)`; by
  `ResidueDial.readout_eq` the observed class is a function of `N mod 84`.
* `comp84` : Gauss composition — ten explicit bilinear identities realise the
  Klein four-group law `Cl(-84) ≅ (ℤ/2)²` on represented integers.
* `obs84_collision` : three *different* factorisation types (`f₂·f₂`, `f₃·f₃`,
  `f₄·f₄`) all produce the *same* observation vector `(8,0,0,0)`-shaped support.
  With `h = 4` the collapse is strictly worse than at `D = -20`: the dial has
  four positions but only ever reports the class of `N`, which is already
  determined by `N mod 84`.
-/
import Mathlib
import Algebra.ClassGroupResidueDial

namespace ClassGroupResidueDial

/-! ## 1. The four reduced forms of discriminant `-84` -/

/-- Principal form `x² + 21y²`. -/
def Reprf1 (N : ℤ) : Prop := ∃ x y : ℤ, x ^ 2 + 21 * y ^ 2 = N

/-- `2x² + 2xy + 11y²`. -/
def Reprf2 (N : ℤ) : Prop := ∃ x y : ℤ, 2 * x ^ 2 + 2 * x * y + 11 * y ^ 2 = N

/-- `3x² + 7y²`. -/
def Reprf3 (N : ℤ) : Prop := ∃ x y : ℤ, 3 * x ^ 2 + 7 * y ^ 2 = N

/-- `5x² + 4xy + 5y²`. -/
def Reprf4 (N : ℤ) : Prop := ∃ x y : ℤ, 5 * x ^ 2 + 4 * x * y + 5 * y ^ 2 = N

/-- The four classes of discriminant `-84`, indexed by the Klein four-group
`Bool × Bool`. -/
def repr84 : Bool × Bool → ℤ → Prop
  | (false, false) => Reprf1
  | (true, false) => Reprf2
  | (false, true) => Reprf3
  | (true, true) => Reprf4

/-- The genus characters mod `84`. -/
def res84 : Bool × Bool → Finset (ZMod 84)
  | (false, false) => {1, 25, 37}
  | (true, false) => {11, 23, 71}
  | (false, true) => {19, 31, 55}
  | (true, true) => {5, 17, 41}

/-- The `24` units of `ZMod 84`, as a Boolean test. -/
def isU84 (v : ZMod 84) : Bool :=
  v = 1 || v = 5 || v = 11 || v = 13 || v = 17 || v = 19 || v = 23 || v = 25 || v = 29 ||
  v = 31 || v = 37 || v = 41 || v = 43 || v = 47 || v = 53 || v = 55 || v = 59 || v = 61 ||
  v = 65 || v = 67 || v = 71 || v = 73 || v = 79 || v = 83

set_option maxRecDepth 100000

set_option maxHeartbeats 2000000 in
/-- Anything invertible mod `84` passes the unit test. -/
theorem isU84_of_unit : ∀ v u : ZMod 84, u * v = 1 → isU84 v = true := by decide

set_option maxHeartbeats 4000000 in
theorem key84_f1 : ∀ a b : ZMod 84, isU84 (a ^ 2 + 21 * b ^ 2) = true →
    (a ^ 2 + 21 * b ^ 2) ∈ ({1, 25, 37} : Finset (ZMod 84)) := by decide

set_option maxHeartbeats 4000000 in
theorem key84_f2 : ∀ a b : ZMod 84, isU84 (2 * a ^ 2 + 2 * a * b + 11 * b ^ 2) = true →
    (2 * a ^ 2 + 2 * a * b + 11 * b ^ 2) ∈ ({11, 23, 71} : Finset (ZMod 84)) := by decide

set_option maxHeartbeats 4000000 in
theorem key84_f3 : ∀ a b : ZMod 84, isU84 (3 * a ^ 2 + 7 * b ^ 2) = true →
    (3 * a ^ 2 + 7 * b ^ 2) ∈ ({19, 31, 55} : Finset (ZMod 84)) := by decide

set_option maxHeartbeats 4000000 in
theorem key84_f4 : ∀ a b : ZMod 84, isU84 (5 * a ^ 2 + 4 * a * b + 5 * b ^ 2) = true →
    (5 * a ^ 2 + 4 * a * b + 5 * b ^ 2) ∈ ({5, 17, 41} : Finset (ZMod 84)) := by decide

theorem sound84 : ∀ (i : Bool × Bool) (N : ℤ), (∃ u : ZMod 84, u * (N : ZMod 84) = 1) →
    repr84 i N → ((N : ZMod 84) ∈ res84 i) := by
  rintro ⟨(_ | _), (_ | _)⟩ N ⟨u, hu⟩ ⟨x, y, rfl⟩
  · have h : ((x ^ 2 + 21 * y ^ 2 : ℤ) : ZMod 84)
        = (x : ZMod 84) ^ 2 + 21 * (y : ZMod 84) ^ 2 := by push_cast; ring
    rw [h] at hu ⊢
    exact key84_f1 _ _ (isU84_of_unit _ _ hu)
  · have h : ((3 * x ^ 2 + 7 * y ^ 2 : ℤ) : ZMod 84)
        = 3 * (x : ZMod 84) ^ 2 + 7 * (y : ZMod 84) ^ 2 := by push_cast; ring
    rw [h] at hu ⊢
    exact key84_f3 _ _ (isU84_of_unit _ _ hu)
  · have h : ((2 * x ^ 2 + 2 * x * y + 11 * y ^ 2 : ℤ) : ZMod 84)
        = 2 * (x : ZMod 84) ^ 2 + 2 * (x : ZMod 84) * (y : ZMod 84)
          + 11 * (y : ZMod 84) ^ 2 := by push_cast; ring
    rw [h] at hu ⊢
    exact key84_f2 _ _ (isU84_of_unit _ _ hu)
  · have h : ((5 * x ^ 2 + 4 * x * y + 5 * y ^ 2 : ℤ) : ZMod 84)
        = 5 * (x : ZMod 84) ^ 2 + 4 * (x : ZMod 84) * (y : ZMod 84)
          + 5 * (y : ZMod 84) ^ 2 := by push_cast; ring
    rw [h] at hu ⊢
    exact key84_f4 _ _ (isU84_of_unit _ _ hu)

theorem disj84 : ∀ i j : Bool × Bool, i ≠ j → ∀ a : ZMod 84, a ∈ res84 i → a ∉ res84 j := by
  decide

/-- The discriminant `-84` residue dial: four classes, four disjoint residue
triples mod `84`. -/
def dial84 : ResidueDial 84 (Bool × Bool) where
  repr := repr84
  res := res84
  sound := sound84
  disj := disj84

/-! ## 2. Exclusivity and the dial -/

/-- At most one of the four classes represents a given `N` coprime to `84`. -/
theorem index84_unique {N : ℤ} (hN : IsCoprime N 84) {i j : Bool × Bool}
    (hi : repr84 i N) (hj : repr84 j N) : i = j :=
  dial84.index_unique (unit_cast_of_isCoprime (by exact_mod_cast hN)) hi hj

/-- **Residue dial at `D = -84`.**  The class index is a function of `N mod 84`. -/
theorem dial84_factor_blind {N M : ℤ} (hN : IsCoprime N 84) (hM : IsCoprime M 84)
    (hres : (N : ZMod 84) = (M : ZMod 84)) {i j : Bool × Bool}
    (hi : repr84 i N) (hj : repr84 j M) : i = j :=
  dial84.factor_blind (unit_cast_of_isCoprime (by exact_mod_cast hN))
    (unit_cast_of_isCoprime (by exact_mod_cast hM)) hres hi hj

theorem dial84_readout {N : ℤ} {i : Bool × Bool} (hN : IsCoprime N 84) (hi : repr84 i N) :
    dial84.readout (N : ZMod 84) = i :=
  dial84.readout_eq (unit_cast_of_isCoprime (by exact_mod_cast hN)) hi

/-! ## 3. Gauss composition: `Cl(-84) ≅ (ℤ/2)²` -/

/-- The Klein four-group law on class indices. -/
def klein (i j : Bool × Bool) : Bool × Bool := (xor i.1 j.1, xor i.2 j.2)

set_option maxHeartbeats 1000000 in
/-- **Composition law at `D = -84`.**  Represented integers multiply and the
class indices add in the Klein four-group.  Ten explicit bilinear identities
(plus their transposes) realise all sixteen products. -/
theorem comp84 : ∀ (i j : Bool × Bool) (a b : ℤ), repr84 i a → repr84 j b →
    repr84 (klein i j) (a * b) := by
  rintro ⟨(_ | _), (_ | _)⟩ ⟨(_ | _), (_ | _)⟩ a b <;>
    simp only [repr84, klein, Reprf1, Reprf2, Reprf3, Reprf4, Bool.xor_false, Bool.xor_true,
      Bool.not_false, Bool.not_true] <;>
    rintro ⟨x, y, rfl⟩ ⟨u, v, rfl⟩ <;>
  first
    | (refine ⟨-x*u -x*v -2 * y*u + 3 * y*v, x*u -x*v -y*u -4 * y*v, ?_⟩; ring1)
    | (refine ⟨-u*x -u*y -2 * v*x + 3 * v*y, u*x -u*y -v*x -4 * v*y, ?_⟩; ring1)
    | (refine ⟨-x*u + x*v -4 * y*u -3 * y*v, -x*u -x*v + y*u -2 * y*v, ?_⟩; ring1)
    | (refine ⟨-u*x + u*y -4 * v*x -3 * v*y, -u*x -u*y + v*x -2 * v*y, ?_⟩; ring1)
    | (refine ⟨-2 * x*u + x*v -3 * y*u -4 * y*v, x*u + x*v -y*u + y*v, ?_⟩; ring1)
    | (refine ⟨-2 * u*x + u*y -3 * v*x -4 * v*y, u*x + u*y -v*x + v*y, ?_⟩; ring1)
    | (refine ⟨-x*u -x*v -y*u + 10 * y*v, x*v + 2 * y*u + y*v, ?_⟩; ring1)
    | (refine ⟨-u*x -u*y -v*x + 10 * v*y, u*y + 2 * v*x + v*y, ?_⟩; ring1)
    | (refine ⟨-x*u + 7 * y*v, -x*v -3 * y*u, ?_⟩; ring1)
    | (refine ⟨-u*x + 7 * v*y, -u*y -3 * v*x, ?_⟩; ring1)
    | (refine ⟨-x*u -2 * y*u -5 * y*v, -x*v + 5 * y*u + 2 * y*v, ?_⟩; ring1)
    | (refine ⟨-u*x -2 * v*x -5 * v*y, -u*y + 5 * v*x + 2 * v*y, ?_⟩; ring1)
    | (refine ⟨-2 * x*u -x*v -y*u + 10 * y*v, -x*v -y*u -y*v, ?_⟩; ring1)
    | (refine ⟨-3 * x*u + 7 * y*v, -x*v -y*u, ?_⟩; ring1)
    | (refine ⟨-5 * x*u -2 * x*v -2 * y*u -5 * y*v, -x*v + y*u, ?_⟩; ring1)
    | (refine ⟨x*u -21 * y*v, x*v + y*u, ?_⟩; ring1)

/-- Every class squares to the principal one: `Cl(-84)` is `2`-torsion. -/
theorem sq_principal (i : Bool × Bool) (a b : ℤ) (ha : repr84 i a) (hb : repr84 i b) :
    Reprf1 (a * b) := by
  have h := comp84 i i a b ha hb
  rcases i with ⟨(_ | _), (_ | _)⟩ <;> simpa [klein, repr84] using h

/-! ## 4. The refutation at `D = -84`

With four classes there are three distinct "same-class pair" factorisation types
(`f₂f₂`, `f₃f₃`, `f₄f₄`) beyond the principal one; all of them are mapped by the
representation vector to the *same* observation, namely "represented by the
principal form and by nothing else". -/

open Classical in
/-- The four-entry observation vector (support form). -/
noncomputable def obs84 (N : ℤ) : Bool × Bool × Bool × Bool :=
  (decide (Reprf1 N), decide (Reprf2 N), decide (Reprf3 N), decide (Reprf4 N))

/-- Only the principal class can represent a product of two integers of the same
class (and, for `N` coprime to `84`, nothing else can). -/
theorem obs84_of_same_class {i : Bool × Bool} {p q : ℤ} (hp : repr84 i p) (hq : repr84 i q)
    (hN : IsCoprime (p * q) 84) : obs84 (p * q) = (true, false, false, false) := by
  classical
  have h1 : Reprf1 (p * q) := sq_principal i p q hp hq
  have hne : ∀ j : Bool × Bool, j ≠ (false, false) → ¬ repr84 j (p * q) := by
    intro j hj hcon
    exact hj (index84_unique hN hcon h1)
  have h2 : ¬ Reprf2 (p * q) := hne (true, false) (by decide)
  have h3 : ¬ Reprf3 (p * q) := hne (false, true) (by decide)
  have h4 : ¬ Reprf4 (p * q) := hne (true, true) (by decide)
  simp [obs84, h1, h2, h3, h4]

/-- **Collision.**  Semiprimes built from two `f₂`-primes, from two `f₃`-primes,
or from two `f₄`-primes are all reported identically by the discriminant `-84`
representation vector.  Three distinct factorisation types, one observation. -/
theorem obs84_collision {p₂ q₂ p₃ q₃ p₄ q₄ : ℤ}
    (h2 : Reprf2 p₂) (h2' : Reprf2 q₂) (h3 : Reprf3 p₃) (h3' : Reprf3 q₃)
    (h4 : Reprf4 p₄) (h4' : Reprf4 q₄)
    (c2 : IsCoprime (p₂ * q₂) 84) (c3 : IsCoprime (p₃ * q₃) 84)
    (c4 : IsCoprime (p₄ * q₄) 84) :
    obs84 (p₂ * q₂) = obs84 (p₃ * q₃) ∧ obs84 (p₃ * q₃) = obs84 (p₄ * q₄) := by
  have e2 := obs84_of_same_class (i := (true, false)) h2 h2' c2
  have e3 := obs84_of_same_class (i := (false, true)) h3 h3' c3
  have e4 := obs84_of_same_class (i := (true, true)) h4 h4' c4
  exact ⟨by rw [e2, e3], by rw [e3, e4]⟩

/-! ## 5. Lab notes: two colliding semiprimes at `D = -84`

| `N`   | factorisation | class type | `N mod 84` | `r_{f₁}(N)` |
|-------|---------------|------------|------------|-------------|
| `253` | `11 · 23`     | `f₂ · f₂`  | `1`        | `8`         |
| `589` | `19 · 31`     | `f₃ · f₃`  | `1`        | `8`         |

Both vectors are `(8, 0, 0, 0)`: the zero entries are *forced* by
`index84_unique`, and the value `8` is certified below by exhaustive search in a
provably sufficient box. -/

/-- All representations of `N` by `x² + 21y²` inside an explicit box. -/
def boxf1 (N Bx By : ℤ) : Finset (ℤ × ℤ) :=
  ((Finset.Icc (-Bx) Bx) ×ˢ (Finset.Icc (-By) By)).filter (fun p => p.1 ^ 2 + 21 * p.2 ^ 2 = N)

theorem repsf1_eq_boxf1 (N Bx By : ℤ) (hBx : N ≤ Bx ^ 2) (hBy : N ≤ 21 * By ^ 2)
    (hBx0 : 0 ≤ Bx) (hBy0 : 0 ≤ By) :
    {p : ℤ × ℤ | p.1 ^ 2 + 21 * p.2 ^ 2 = N} = ↑(boxf1 N Bx By) := by
  ext ⟨x, y⟩
  simp only [Set.mem_setOf_eq, boxf1, Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_product,
    Finset.mem_Icc]
  constructor
  · intro h
    refine ⟨⟨⟨?_, ?_⟩, ?_, ?_⟩, h⟩
    · nlinarith [sq_nonneg y, sq_nonneg (x + Bx)]
    · nlinarith [sq_nonneg y, sq_nonneg (x - Bx)]
    · nlinarith [sq_nonneg x, sq_nonneg (y + By)]
    · nlinarith [sq_nonneg x, sq_nonneg (y - By)]
  · tauto

/-- `r_{f₁}(253) = 8` for `253 = 11 · 23` (type `f₂ · f₂`). -/
theorem reps_253_ncard : {p : ℤ × ℤ | p.1 ^ 2 + 21 * p.2 ^ 2 = 253}.ncard = 8 := by
  rw [repsf1_eq_boxf1 253 16 4 (by norm_num) (by norm_num) (by norm_num) (by norm_num),
    Set.ncard_coe_finset]
  decide

/-- `r_{f₁}(589) = 8` for `589 = 19 · 31` (type `f₃ · f₃`) — the same value, from
a different factorisation type at the same residue `1 mod 84`. -/
theorem reps_589_ncard : {p : ℤ × ℤ | p.1 ^ 2 + 21 * p.2 ^ 2 = 589}.ncard = 8 := by
  rw [repsf1_eq_boxf1 589 25 6 (by norm_num) (by norm_num) (by norm_num) (by norm_num),
    Set.ncard_coe_finset]
  decide

end ClassGroupResidueDial