import Mathlib
import Shared.QSRelationPoolRandom

/-!
# The multi-polynomial column set *is* the single-polynomial split set

The campaign record once claimed that the multiple-polynomial quadratic sieve
(MPQS) confines relations to a column set of density `~1/4` of the factor base,
half of the single-polynomial density.  The measured density was `0.487–0.505`,
i.e. the same `1/2`.  This file proves why: **changing the polynomial cannot
change the column set.**

The single-polynomial facts live in `Catalog.Shared.QSRelationPoolRandom`
(`QSRelationPool.qsValue`, `exists_dvd_qsValue_iff_isSquare`,
`card_admissible_residues`).  Here we add:

* `mpqsValue N a b x = (a x + b)^2 - N`, the shifted/scaled sieve polynomial, and
  `mpqsReduced a b c x = a x^2 + 2 b x + c` with `b^2 - a c = N`, the actual
  MPQS polynomial (`a · Q(x) = (a x + b)^2 - N`).
* `exists_dvd_mpqsValue_iff_isSquare`, `exists_dvd_mpqsReduced_iff_isSquare`:
  for every prime `p ∤ a`, `p` divides *some* value of the polynomial iff `N` is
  a square mod `p` — exactly the single-polynomial criterion.
* `family_columns_iff`: for an arbitrary (nonempty) family of polynomials, the
  union of their column sets, restricted to primes coprime to all leading
  coefficients, is precisely the split set.  No family enlarges or shrinks it.
* `mpqs_column_density`: the number of residues `N mod p` for which `p` is a
  column of a given MPQS polynomial is exactly `(p-1)/2`: density `1/2`, not
  `1/4`.
-/

namespace FactoringFrontier.MultiPoly

open QSRelationPool

/-- The scaled-and-shifted sieve polynomial `(a x + b)^2 - N`. -/
def mpqsValue (N a b x : ℤ) : ℤ := (a * x + b) ^ 2 - N

/-- The reduced MPQS polynomial `a x^2 + 2 b x + c`. -/
def mpqsReduced (a b c x : ℤ) : ℤ := a * x ^ 2 + 2 * b * x + c

/-- The MPQS identity: if `b^2 - a c = N` then `a · Q(x) = (a x + b)^2 - N`. -/
theorem mpqsReduced_scale {N a b c : ℤ} (hN : b ^ 2 - a * c = N) (x : ℤ) :
    a * mpqsReduced a b c x = mpqsValue N a b x := by
  unfold mpqsReduced mpqsValue
  rw [← hN]; ring

/-- `mpqsValue` is the single-polynomial value at the shifted point `a x + b`. -/
theorem mpqsValue_eq_qsValue (N a b x : ℤ) : mpqsValue N a b x = qsValue N (a * x + b) := rfl

/-- **Multi-polynomial column criterion.**  For a prime `p` not dividing the
leading coefficient `a`, the prime `p` divides some value `(a x + b)^2 - N` iff
`N` is a quadratic residue mod `p`. -/
theorem exists_dvd_mpqsValue_iff_isSquare {p : ℕ} [hp : Fact p.Prime] {a : ℤ}
    (ha : ¬ (p : ℤ) ∣ a) (N b : ℤ) :
    (∃ x : ℤ, (p : ℤ) ∣ mpqsValue N a b x) ↔ IsSquare (N : ZMod p) := by
  constructor
  · rintro ⟨x, hx⟩
    exact isSquare_of_dvd_qsValue (x := a * x + b) hx
  · intro hsq
    obtain ⟨y, hy⟩ := (exists_dvd_qsValue_iff_isSquare (p := p) N).2 hsq
    -- solve `a x + b ≡ y (mod p)` using that `a` is a unit mod `p`
    have ha' : (a : ZMod p) ≠ 0 := by
      rwa [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
    set x0 : ZMod p := (a : ZMod p)⁻¹ * ((y : ZMod p) - b)
    refine ⟨(x0.val : ℤ), ?_⟩
    rw [mpqsValue_eq_qsValue, dvd_qsValue_iff_sq_eq]
    rw [dvd_qsValue_iff_sq_eq] at hy
    have hx0 : ((x0.val : ℕ) : ZMod p) = x0 := ZMod.natCast_zmod_val x0
    push_cast
    rw [hx0]
    have : (a : ZMod p) * x0 + b = y := by
      simp only [x0]; field_simp; ring
    rw [this, hy]

/-- **Reduced MPQS column criterion.**  With `b^2 - a c = N` and `p ∤ a`, the
prime `p` divides some value of `a x^2 + 2 b x + c` iff `N` is a square mod `p`. -/
theorem exists_dvd_mpqsReduced_iff_isSquare {p : ℕ} [hp : Fact p.Prime] {N a b c : ℤ}
    (hN : b ^ 2 - a * c = N) (ha : ¬ (p : ℤ) ∣ a) :
    (∃ x : ℤ, (p : ℤ) ∣ mpqsReduced a b c x) ↔ IsSquare (N : ZMod p) := by
  rw [← exists_dvd_mpqsValue_iff_isSquare ha N b]
  have hpr : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp.out
  refine exists_congr fun x => ?_
  rw [← mpqsReduced_scale hN x]
  constructor
  · intro h; exact Dvd.dvd.mul_left h a
  · intro h
    rcases hpr.dvd_or_dvd h with h' | h'
    · exact absurd h' ha
    · exact h'

/-- **No polynomial family changes the column set.**  For any nonempty family of
shifted sieve polynomials `(a_i x + b_i)^2 - N` and any prime `p` coprime to all
leading coefficients, `p` is a column of *some* member of the family iff it is
in the single-polynomial split set (`N` a square mod `p`). -/
theorem family_columns_iff {ι : Type*} [Nonempty ι] (A B : ι → ℤ) {p : ℕ} [Fact p.Prime]
    (hA : ∀ i, ¬ (p : ℤ) ∣ A i) (N : ℤ) :
    (∃ i, ∃ x : ℤ, (p : ℤ) ∣ mpqsValue N (A i) (B i) x) ↔ IsSquare (N : ZMod p) := by
  constructor
  · rintro ⟨i, h⟩
    exact (exists_dvd_mpqsValue_iff_isSquare (hA i) N (B i)).1 h
  · intro h
    obtain ⟨i⟩ := ‹Nonempty ι›
    exact ⟨i, (exists_dvd_mpqsValue_iff_isSquare (hA i) N (B i)).2 h⟩

open Classical in
/-- **Column density is `1/2`, not `1/4`.**  For an odd prime `p` and a fixed
leading coefficient `a` with `p ∤ a`, the set of nonzero residues `n mod p` for
which `p` divides some value `(a x + b)^2 - n` has exactly `(p-1)/2` elements. -/
theorem mpqs_column_density {p : ℕ} [Fact p.Prime] (hp2 : p ≠ 2) {a : ℤ}
    (ha : ¬ (p : ℤ) ∣ a) (b : ℤ) :
    (Finset.univ.filter
        (fun n : ZMod p => n ≠ 0 ∧ ∃ x : ℤ, (p : ℤ) ∣ mpqsValue (n.val : ℤ) a b x)).card
      = (p - 1) / 2 := by
  rw [← card_admissible_residues hp2]
  apply congrArg Finset.card
  ext n
  simp only [admissible, Set.mem_toFinset, Set.mem_setOf_eq, Finset.mem_filter,
    Finset.mem_univ, true_and]
  rw [exists_dvd_mpqsValue_iff_isSquare ha]
  simp

/-! ## Lab notes (kernel-checked instances)

`p = 7`, `a = 3`, `b = 5`.  `N = 2` is a square mod `7` (`3^2 = 9 ≡ 2`) and the
shifted polynomial `(3x+5)^2 - 2` has exactly two roots per period, `x = 2`
(`11^2 - 2 = 119 = 7·17`) and `x = 4` (`17^2 - 2 = 287 = 7·41`).  `N = 3` is a
non-residue and the polynomial is never divisible by `7`. -/

/-- `(3x+5)^2 - 2 ≡ 0 (mod 7)` has exactly two roots in one period. -/
example : ((Finset.range 7).filter (fun x : ℕ => (3 * x + 5) ^ 2 % 7 = 2)).card = 2 := by
  decide

/-- `(3x+5)^2 - 3 ≡ 0 (mod 7)` has no root: `3` is a non-residue mod `7`. -/
example : ((Finset.range 7).filter (fun x : ℕ => (3 * x + 5) ^ 2 % 7 = 3)).card = 0 := by
  decide

end FactoringFrontier.MultiPoly