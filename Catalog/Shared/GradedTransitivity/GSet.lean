import Shared.GradedTransitivity.BinomialGF

/-!
# Graded `G`-sets, `r`-transitivity, and rational Hilbert series

Let `Y = ⨆_n Y_n` be a graded `G`-set (a family of `G`-sets indexed by the
grade `n`).  Following Mathlib's `MulAction.IsMultiplyPretransitive`, the
`r`-tuple object of a `G`-set `Y` is the `G`-set `Fin r ↪ Y` of injective
`r`-tuples, and we write

`t_r(Y) = #(orbits of G on Fin r ↪ Y)`.

The grade `Y_n` is *`r`-transitive* when `G` acts transitively on the nonempty
set `Fin r ↪ Y_n`, which is exactly `t_r(Y_n) = 1`.

## Main results

* `torbits_eq_one_iff` : `t_r(Y) = 1` iff `Y` is `r`-transitive.
* `gen_torbits_rational` : if `Y_n` is `r`-transitive for all large `n` then
  `∑_n t_r(Y_n) qⁿ` is `P(q)/(1-q)^{r+1}` with `P` a polynomial; moreover
  the denominator can be taken to be the divisor `1-q` of `(1-q)^{r+1}`.
* `gen_torbits_eq_of_exactly` : the exact Hilbert series `q^N/(1-q)` in the
  clean case where the grades below `N` carry no injective `r`-tuple.
* `perm_graded_gen` : the symmetric-group family `Y_n = Fin n`,
  `G_n = Equiv.Perm (Fin n)` realises `∑_n t_r(Y_n) qⁿ = q^r/(1-q)`.

The companion file `BinomialGF` shows that the exponent `r+1` is optimal for
general polynomial growth, so the theorem here is a genuine strengthening in
the transitive regime: eventual `r`-transitivity forces denominator `1-q`.
-/

namespace GradedTransitivity

open Polynomial MulAction

/-- The number `t_r(Y)` of `G`-orbits on the set `Fin r ↪ Y` of injective
`r`-tuples of `Y`. -/
noncomputable def torbits (G : Type*) [Group G] (Y : Type*) [MulAction G Y] (r : ℕ) : ℕ :=
  Nat.card (MulAction.orbitRel.Quotient G (Fin r ↪ Y))

/-- A `G`-set is `r`-transitive when it carries at least one injective
`r`-tuple and `G` permutes those transitively. -/
def IsRTransitive (G : Type*) [Group G] (Y : Type*) [MulAction G Y] (r : ℕ) : Prop :=
  MulAction.IsMultiplyPretransitive G Y r ∧ Nonempty (Fin r ↪ Y)

section Basic

variable {G : Type*} [Group G] {Y : Type*} [MulAction G Y]

/-- The orbit space of a pretransitive action is a subsingleton. -/
theorem subsingleton_orbitQuotient {α : Type*} [MulAction G α] [IsPretransitive G α] :
    Subsingleton (MulAction.orbitRel.Quotient G α) := by
  constructor
  intro x y
  induction x using Quotient.inductionOn with
  | h a =>
    induction y using Quotient.inductionOn with
    | h b =>
      have hab : a ∈ MulAction.orbit G b :=
        MulAction.mem_orbit_iff.2 (MulAction.exists_smul_eq G b a)
      exact Quotient.sound hab

/-- `r`-transitivity is exactly the statement `t_r(Y) = 1`. -/
theorem torbits_eq_one_iff (r : ℕ) : torbits G Y r = 1 ↔ IsRTransitive G Y r := by
  constructor
  · intro h
    obtain ⟨hsub, hne⟩ := Nat.card_eq_one_iff_unique.1 h
    have hY : Nonempty (Fin r ↪ Y) := by
      obtain ⟨q⟩ := hne
      induction q using Quotient.inductionOn with
      | h a => exact ⟨a⟩
    refine ⟨⟨fun x y => ?_⟩, hY⟩
    have : (Quotient.mk (MulAction.orbitRel G (Fin r ↪ Y)) x)
        = Quotient.mk (MulAction.orbitRel G (Fin r ↪ Y)) y := Subsingleton.elim _ _
    have hmem : x ∈ MulAction.orbit G y := Quotient.exact this
    obtain ⟨g, hg⟩ := MulAction.mem_orbit_iff.1 hmem
    exact ⟨g⁻¹, by rw [← hg, inv_smul_smul]⟩
  · rintro ⟨htr, hne⟩
    have : IsPretransitive G (Fin r ↪ Y) := htr
    have hsub : Subsingleton (MulAction.orbitRel.Quotient G (Fin r ↪ Y)) :=
      subsingleton_orbitQuotient
    have hnq : Nonempty (MulAction.orbitRel.Quotient G (Fin r ↪ Y)) :=
      ⟨Quotient.mk _ hne.some⟩
    exact Nat.card_eq_one_iff_unique.2 ⟨hsub, hnq⟩

/-- If there is no injective `r`-tuple at all, `t_r(Y) = 0`. -/
theorem torbits_eq_zero (r : ℕ) (h : IsEmpty (Fin r ↪ Y)) : torbits G Y r = 0 := by
  have hE : IsEmpty (MulAction.orbitRel.Quotient G (Fin r ↪ Y)) := by
    constructor
    intro q
    induction q using Quotient.inductionOn with
    | h a => exact h.elim a
  exact Nat.card_eq_zero.2 (Or.inl hE)

end Basic

/-! ### Rationality of the Hilbert series of a graded `G`-set -/

variable {G : ℕ → Type*} [∀ n, Group (G n)] {Y : ℕ → Type*} [∀ n, MulAction (G n) (Y n)]

/-- The `r`-transitivity Hilbert series `∑_n t_r(Y_n) qⁿ` of a graded
`G`-set. -/
noncomputable def hilbertSeq (G : ℕ → Type*) [∀ n, Group (G n)] (Y : ℕ → Type*)
    [∀ n, MulAction (G n) (Y n)] (r : ℕ) : ℕ → ℚ :=
  fun n => (torbits (G n) (Y n) r : ℚ)

/-- **Main theorem.**  If the grades of a graded `G`-set are eventually
`r`-transitive, the Hilbert series `∑_n t_r(Y_n) qⁿ` is a rational function
whose denominator divides `(1-q)^{r+1}`: indeed already `(1-q)` clears it. -/
theorem gen_hilbertSeq_rational (r N : ℕ) (h : ∀ n ≥ N, IsRTransitive (G n) (Y n) r) :
    ∃ P : ℚ[X], (1 - PowerSeries.X) * gen (hilbertSeq G Y r) = (P : PowerSeries ℚ) := by
  have hz : EventuallyZero (sdiff^[1] (hilbertSeq G Y r)) := by
    refine ⟨N, fun n hn => ?_⟩
    simp only [Function.iterate_one, sdiff, hilbertSeq]
    rw [(torbits_eq_one_iff r).2 (h (n + 1) (by omega)),
      (torbits_eq_one_iff r).2 (h n hn)]
    ring
  obtain ⟨P, hP⟩ := exists_poly_pow_mul_gen 1 (hilbertSeq G Y r) hz
  exact ⟨P, by simpa using hP⟩

/-- The statement in the form requested: denominator `(1-q)^{r+1}`. -/
theorem gen_hilbertSeq_rational_pow (r N : ℕ) (h : ∀ n ≥ N, IsRTransitive (G n) (Y n) r) :
    ∃ P : ℚ[X], (1 - PowerSeries.X) ^ (r + 1) * gen (hilbertSeq G Y r) = (P : PowerSeries ℚ) := by
  obtain ⟨P, hP⟩ := gen_hilbertSeq_rational r N h
  refine ⟨(1 - X) ^ r * P, ?_⟩
  have : (1 - PowerSeries.X) ^ (r + 1) * gen (hilbertSeq G Y r)
      = (1 - PowerSeries.X) ^ r * ((1 - PowerSeries.X) * gen (hilbertSeq G Y r)) := by ring
  rw [this, hP]
  push_cast
  ring

/-- The honest "rational function" formulation: the Hilbert series is the
quotient of a polynomial by `(1-q)^{r+1}` inside `PowerSeries ℚ`. -/
theorem hilbertSeq_eq_div (r N : ℕ) (h : ∀ n ≥ N, IsRTransitive (G n) (Y n) r) :
    ∃ P : ℚ[X], gen (hilbertSeq G Y r)
      = (P : PowerSeries ℚ) * (((1 - PowerSeries.X) ^ (r + 1))⁻¹) := by
  obtain ⟨P, hP⟩ := gen_hilbertSeq_rational_pow r N h
  exact ⟨P, eq_poly_div_of_pow_mul hP⟩

/-- Denominator bookkeeping: there is a denominator `D` dividing `(1-q)^{r+1}`,
with `D(0) ≠ 0`, clearing the Hilbert series. -/
theorem hilbertSeq_denominator_dvd (r N : ℕ) (h : ∀ n ≥ N, IsRTransitive (G n) (Y n) r) :
    ∃ P D : ℚ[X], D ∣ (1 - X) ^ (r + 1) ∧ D.eval 0 ≠ 0 ∧
      (D : PowerSeries ℚ) * gen (hilbertSeq G Y r) = (P : PowerSeries ℚ) := by
  obtain ⟨P, hP⟩ := gen_hilbertSeq_rational r N h
  refine ⟨P, 1 - X, ⟨(1 - X) ^ r, by ring⟩, by simp, ?_⟩
  rw [← hP]
  push_cast
  ring

/-! ### The exact Hilbert series in the clean case -/

/-- The generating series of the step sequence `n ↦ [n ≥ N]` is `q^N/(1-q)`. -/
theorem one_sub_X_mul_gen_step (N : ℕ) :
    (1 - PowerSeries.X) * gen (fun n => if N ≤ n then (1 : ℚ) else 0)
      = (PowerSeries.X : PowerSeries ℚ) ^ N := by
  rw [one_sub_X_mul_gen]
  ext n
  cases n with
  | zero =>
      simp only [map_add, PowerSeries.coeff_zero_X_mul, PowerSeries.coeff_C,
        PowerSeries.coeff_X_pow, zero_add]
      by_cases hN : N = 0
      · simp [hN]
      · simp [hN]
        omega
  | succ m =>
      simp only [map_add, PowerSeries.coeff_succ_X_mul, coeff_gen, sdiff,
        PowerSeries.coeff_C, PowerSeries.coeff_X_pow, Nat.succ_ne_zero, if_false, add_zero]
      by_cases h1 : N ≤ m
      · simp [h1, (by omega : N ≤ m + 1)]
        omega
      · by_cases h2 : N ≤ m + 1
        · have hmN : m + 1 = N := by omega
          simp [h1, hmN]
        · simp [h1, h2]
          omega

/-- If every grade `≥ N` is `r`-transitive and every grade `< N` carries no
injective `r`-tuple, the Hilbert series is *exactly* `q^N/(1-q)`. -/
theorem gen_hilbertSeq_eq_of_exactly (r N : ℕ)
    (h : ∀ n ≥ N, IsRTransitive (G n) (Y n) r)
    (h' : ∀ n < N, IsEmpty (Fin r ↪ Y n)) :
    (1 - PowerSeries.X) * gen (hilbertSeq G Y r) = (PowerSeries.X : PowerSeries ℚ) ^ N := by
  have hseq : hilbertSeq G Y r = fun n => if N ≤ n then (1 : ℚ) else 0 := by
    funext n
    by_cases hn : N ≤ n
    · simp only [hilbertSeq, hn, if_true]
      rw [(torbits_eq_one_iff r).2 (h n hn)]
      norm_num
    · simp only [hilbertSeq, hn, if_false]
      rw [torbits_eq_zero r (h' n (by omega))]
      norm_num
  rw [hseq, one_sub_X_mul_gen_step]

/-! ### A concrete graded `G`-set: the symmetric groups -/

/-- Each grade of the symmetric-group family `Y_n = Fin n`,
`G_n = Equiv.Perm (Fin n)` is `r`-transitive as soon as `r ≤ n`. -/
theorem perm_isRTransitive (r n : ℕ) (h : r ≤ n) :
    IsRTransitive (Equiv.Perm (Fin n)) (Fin n) r := by
  refine ⟨Equiv.Perm.isMultiplyPretransitive (Fin n) r, ?_⟩
  exact ⟨⟨fun i => ⟨(i : ℕ), lt_of_lt_of_le i.2 h⟩, by
    intro i j hij
    simpa [Fin.ext_iff] using hij⟩⟩

/-- Below the diagonal there is no injective `r`-tuple in `Fin n`. -/
theorem perm_isEmpty (r n : ℕ) (h : n < r) : IsEmpty (Fin r ↪ Fin n) := by
  constructor
  intro f
  have := Fintype.card_le_of_injective f f.injective
  simp only [Fintype.card_fin] at this
  omega

/-- **The symmetric-group graded set realises `q^r/(1-q)`.**  For
`Y_n = Fin n` with `G_n = Equiv.Perm (Fin n)` one has
`∑_n t_r(Y_n) qⁿ = q^r/(1-q)`; in particular the denominator is the divisor
`1-q` of `(1-q)^{r+1}`, and the numerator is `q^r`. -/
theorem perm_graded_gen (r : ℕ) :
    (1 - PowerSeries.X) *
        gen (hilbertSeq (fun n => Equiv.Perm (Fin n)) (fun n => Fin n) r)
      = (PowerSeries.X : PowerSeries ℚ) ^ r :=
  gen_hilbertSeq_eq_of_exactly r r (fun n hn => perm_isRTransitive r n hn)
    (fun n hn => perm_isEmpty r n hn)

end GradedTransitivity