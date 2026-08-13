import Mathlib
import Physics.DerivedModulusNoGo

/-!
# Exact classification of transparent polynomial moduli, and closure of the corner

The MULTIMOD experiment tested six derived moduli.  A natural objection is that
some *combination* of them — a product, an iterate, a substitution `N ↦ N^k` —
might escape the barrier.  This file closes that loophole completely.

We call a polynomial `f ∈ ℤ[X]` **transparent** when its constant term is a
unit, `f(0) = ±1`.  The results are:

* `Physics.DerivedModulus.universally_coprime_iff_transparent` : a polynomial
  modulus satisfies `gcd(N, f(N)) = 1` for *every* integer `N` **iff** it is
  transparent.  This is an exact classification, not a one-way barrier: the
  failure of transparency is always witnessed by an explicit `N`.
* `Physics.DerivedModulus.transparentSubmonoid` : the transparent polynomials
  form a submonoid of `(ℤ[X], ·)`, and they are stable under precomposition
  with any polynomial without constant term (`N ↦ 2N`, `N ↦ N^k`, …).
* `Physics.DerivedModulus.familyPoly_mem_transparent` and
  `Physics.DerivedModulus.closure_no_go` : the whole multiplicative and
  substitutional closure of the MULTIMOD family stays inside the transparent
  monoid, hence stays invisible to `N`.  No combination of derived moduli can
  ever expose a factor of `N`.
-/

namespace Physics.DerivedModulus

open Polynomial

/-- A polynomial modulus is *transparent* when its constant term is a unit;
equivalently (see `universally_coprime_iff_transparent`) when `f(N)` is coprime
to `N` for every `N`. -/
def IsTransparent (f : ℤ[X]) : Prop := f.eval 0 = 1 ∨ f.eval 0 = -1

theorem isTransparent_iff_natAbs (f : ℤ[X]) :
    IsTransparent f ↔ (f.eval 0).natAbs = 1 := by
  constructor
  · rintro (h | h) <;> rw [h] <;> rfl
  · intro h
    rcases Int.natAbs_eq (f.eval 0) with h' | h' <;> rw [h] at h'
    · exact Or.inl (by simpa using h')
    · exact Or.inr (by simpa using h')

/-! ## The classification -/

/-- Transparency is sufficient (this is the barrier of the companion file). -/
theorem coprime_of_transparent {f : ℤ[X]} (hf : IsTransparent f) (N : ℤ) :
    Int.gcd N (f.eval N) = 1 :=
  gcd_eval_eq_one f hf N

/-- Transparency is necessary: a non-unit constant term is always exposed by an
explicit `N`, namely a prime divisor of `f(0)` (or `N = 2` if `f(0) = 0`). -/
theorem exists_common_factor_of_not_transparent {f : ℤ[X]} (hf : ¬ IsTransparent f) :
    ∃ N : ℤ, Int.gcd N (f.eval N) ≠ 1 := by
  by_cases h0 : f.eval 0 = 0
  · refine ⟨2, ?_⟩
    have hdvd : (2 : ℤ) ∣ f.eval 2 := by
      have := dvd_eval_sub_eval_zero f 2
      rw [h0, sub_zero] at this
      exact this
    have h2 : (2 : ℕ) ∣ Int.gcd 2 (f.eval 2) :=
      Int.dvd_gcd (by norm_num) hdvd
    intro hcon
    rw [hcon] at h2
    omega
  · -- `|f(0)| ≥ 2`; take `N` to be its least prime factor
    have hna : (f.eval 0).natAbs ≠ 1 := fun h => hf ((isTransparent_iff_natAbs f).mpr h)
    have hna0 : (f.eval 0).natAbs ≠ 0 := fun h => h0 (Int.natAbs_eq_zero.mp h)
    set r : ℕ := (f.eval 0).natAbs.minFac with hr
    have hrp : r.Prime := Nat.minFac_prime hna
    have hrdvd : (r : ℤ) ∣ f.eval 0 := by
      have : r ∣ (f.eval 0).natAbs := Nat.minFac_dvd _
      exact Int.dvd_natAbs.mp (Int.natCast_dvd_natCast.mpr this)
    refine ⟨(r : ℤ), ?_⟩
    have hsub : (r : ℤ) ∣ f.eval (r : ℤ) - f.eval 0 := dvd_eval_sub_eval_zero f (r : ℤ)
    have hrf : (r : ℤ) ∣ f.eval (r : ℤ) := by
      simpa using dvd_add hsub hrdvd
    have hgcd : r ∣ Int.gcd (r : ℤ) (f.eval (r : ℤ)) := Int.dvd_gcd dvd_rfl hrf
    intro hcon
    rw [hcon] at hgcd
    exact hrp.one_lt.ne' (Nat.dvd_one.mp hgcd)

/-- **Exact classification of `N`-transparent polynomial moduli.**  A derived
modulus `f(N)` is coprime to `N` for every integer `N` precisely when the
constant term of `f` is a unit.  Everything outside this class leaks — but only
at the finitely many `N` divisible by a prime factor of `f(0)`, which are known
in advance and independent of the factorisation of `N`. -/
theorem universally_coprime_iff_transparent (f : ℤ[X]) :
    (∀ N : ℤ, Int.gcd N (f.eval N) = 1) ↔ IsTransparent f := by
  constructor
  · intro h
    by_contra hf
    obtain ⟨N, hN⟩ := exists_common_factor_of_not_transparent hf
    exact hN (h N)
  · intro hf N
    exact coprime_of_transparent hf N

/-! ## Closure properties: no combination escapes -/

theorem isTransparent_one : IsTransparent (1 : ℤ[X]) := Or.inl (by simp)

theorem IsTransparent.mul {f g : ℤ[X]} (hf : IsTransparent f) (hg : IsTransparent g) :
    IsTransparent (f * g) := by
  rcases hf with h | h <;> rcases hg with h' | h' <;>
    simp [IsTransparent, Polynomial.eval_mul, h, h']

/-- Transparent polynomials form a submonoid of `(ℤ[X], ·)`: the corner is
closed under taking products of derived moduli. -/
def transparentSubmonoid : Submonoid ℤ[X] where
  carrier := {f | IsTransparent f}
  one_mem' := isTransparent_one
  mul_mem' := IsTransparent.mul

/-- Transparency is stable under precomposition with any polynomial with zero
constant term: substitutions such as `N ↦ 2N`, `N ↦ N^k`, `N ↦ N² + N` cannot
break the barrier. -/
theorem IsTransparent.comp {f g : ℤ[X]} (hf : IsTransparent f) (hg : g.eval 0 = 0) :
    IsTransparent (f.comp g) := by
  rcases hf with h | h <;> simp [IsTransparent, Polynomial.eval_comp, hg, h]

/-- Composition law for the barrier: the overlap of `N` with `f(g(N))` is
governed by `f(g(0))`. -/
theorem gcd_comp_eq (f g : ℤ[X]) (N : ℤ) :
    Int.gcd N ((f.comp g).eval N) = Int.gcd N (f.eval (g.eval 0)) := by
  rw [gcd_eval_eq_gcd_const (f.comp g) N, Polynomial.eval_comp]

/-- Products of arbitrarily many transparent moduli remain transparent. -/
theorem isTransparent_listProd {L : List ℤ[X]} (hL : ∀ f ∈ L, IsTransparent f) :
    IsTransparent L.prod := by
  induction L with
  | nil => simpa using isTransparent_one
  | cons a t ih =>
      rw [List.prod_cons]
      exact (hL a (by simp)).mul (ih fun f hf => hL f (by simp [hf]))

/-! ## The MULTIMOD family inside the transparent monoid -/

/-- The six MULTIMOD moduli as polynomials. -/
noncomputable def familyPoly : Fin 6 → ℤ[X]
  | 0 => X - 1
  | 1 => X + 1
  | 2 => X ^ 2 + 1
  | 3 => X ^ 2 + X + 1
  | 4 => 2 * X - 1
  | 5 => 2 * X + 1

@[simp] theorem eval_familyPoly (i : Fin 6) (N : ℤ) :
    (familyPoly i).eval N = family i N := by
  fin_cases i <;> simp [familyPoly, family]

theorem familyPoly_mem_transparent (i : Fin 6) : IsTransparent (familyPoly i) := by
  fin_cases i <;> simp [IsTransparent, familyPoly]

/-- **The corner is closed.**  Every modulus obtained from the MULTIMOD family
by products and by substitution of any constant-term-free polynomial is still
coprime to `N`, for every `N`.  In particular no product such as
`(N-1)(N+1)(N²+1)` and no iterate such as `(2N)² + 1` can expose a factor. -/
theorem closure_no_go {L : List (Fin 6)} {g : ℤ[X]} (hg : g.eval 0 = 0) (N : ℤ) :
    Int.gcd N (((L.map familyPoly).prod.comp g).eval N) = 1 := by
  have hprod : IsTransparent (L.map familyPoly).prod := by
    refine isTransparent_listProd ?_
    intro f hf
    obtain ⟨i, -, rfl⟩ := List.mem_map.mp hf
    exact familyPoly_mem_transparent i
  exact coprime_of_transparent (hprod.comp hg) N

/-- Concrete instance of the closure theorem: the "full derived modulus"
`(N-1)(N+1)(N²+1)(N²+N+1)(2N-1)(2N+1)`, the product of everything MULTIMOD
tested, is coprime to `N` for every `N`. -/
theorem full_product_coprime (N : ℤ) :
    Int.gcd N ((N - 1) * (N + 1) * (N ^ 2 + 1) * (N ^ 2 + N + 1) * (2 * N - 1) * (2 * N + 1))
      = 1 := by
  have h := closure_no_go (L := [0, 1, 2, 3, 4, 5]) (g := X) (by simp) N
  simpa [familyPoly, mul_assoc] using h

end Physics.DerivedModulus