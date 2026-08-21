import Shared.GradedTransitivity.Newton

/-!
# Sharpness of the exponent in the `G`-set setting

The main theorem says that *eventual `r`-transitivity* gives denominator
`(1-q)`, hence a fortiori a denominator dividing `(1-q)^{r+1}`.  Is the
exponent `r+1` in the general statement wasteful?  No: as soon as
transitivity is dropped, the exponent `r+1` is attained *and needed*.

We exhibit this with the graded `G`-set `Y_n = Fin n` acted on by the trivial
group `G_n = ⊥ ≤ Perm (Fin n)`.  Here every injective `r`-tuple is its own
orbit, so

`t_r(Y_n) = n(n-1)⋯(n-r+1) = r! · C(n,r)`,

whose generating function is `r!·q^r/(1-q)^{r+1}` — a genuine pole of order
`r+1` at `q = 1`.

## Main results

* `torbits_of_trivial_action` : trivial actions count injective tuples.
* `torbits_bot` : `t_r = n.descFactorial r` for the trivial-group family.
* `trivial_family_generating_function` : the exact Hilbert series.
* `trivial_family_denominator_sharp` : `(1-q)^r` does *not* suffice, so the
  exponent `r+1` of the main theorem is optimal in the absence of
  transitivity.
-/

namespace GradedTransitivity

open Polynomial

/-! ### Trivial actions -/

/-- If `G` acts trivially on `Y`, then `t_r(Y)` is just the number of injective
`r`-tuples of `Y`. -/
theorem torbits_of_trivial_action {G : Type*} [Group G] {Y : Type*} [MulAction G Y]
    (htriv : ∀ (g : G) (y : Y), g • y = y) (r : ℕ) :
    torbits G Y r = Nat.card (Fin r ↪ Y) := by
  have hfix : ∀ (g : G) (f : Fin r ↪ Y), g • f = f := by
    intro g f
    ext i
    exact htriv g (f i)
  have hwd : ∀ x y : Fin r ↪ Y, (MulAction.orbitRel G (Fin r ↪ Y)) x y → id x = id y := by
    intro x y hxy
    have hmem : x ∈ MulAction.orbit G y := hxy
    obtain ⟨g, hg⟩ := MulAction.mem_orbit_iff.1 hmem
    rw [id, id, ← hg, hfix]
  refine Nat.card_congr (Equiv.ofBijective
    (Quotient.lift (s := MulAction.orbitRel G (Fin r ↪ Y)) id hwd) ⟨?_, ?_⟩)
  · intro q q' hq
    induction q using Quotient.inductionOn with
    | h a =>
      induction q' using Quotient.inductionOn with
      | h b =>
        simpa using congrArg (Quotient.mk (MulAction.orbitRel G (Fin r ↪ Y))) hq
  · intro f
    exact ⟨Quotient.mk _ f, rfl⟩

/-! ### The trivial-group graded set -/

/-- For the trivial subgroup of `Perm (Fin n)` acting on `Fin n`, the number of
orbits of injective `r`-tuples is the falling factorial. -/
theorem torbits_bot (r n : ℕ) :
    torbits (⊥ : Subgroup (Equiv.Perm (Fin n))) (Fin n) r = n.descFactorial r := by
  rw [torbits_of_trivial_action (fun g y => by
    have : (g : Equiv.Perm (Fin n)) = 1 := by
      simpa using (Subgroup.mem_bot.1 g.2)
    show (g : Equiv.Perm (Fin n)) • y = y
    rw [this, one_smul]) r]
  simp [Nat.card_eq_fintype_card, Fintype.card_embedding_eq]

/-- Scaling a sequence scales its generating series. -/
theorem gen_const_mul (c : ℚ) (a : ℕ → ℚ) :
    gen (fun n => c * a n) = PowerSeries.C c * gen a := by
  ext n
  simp [PowerSeries.coeff_C_mul]

/-- The Hilbert series of the trivial-group family is `r! · C(n,r)`. -/
theorem hilbertSeq_bot (r : ℕ) :
    hilbertSeq (fun n => (⊥ : Subgroup (Equiv.Perm (Fin n)))) (fun n => Fin n) r
      = fun n => (r.factorial : ℚ) * chooseSeq r n := by
  funext n
  simp only [hilbertSeq, torbits_bot, chooseSeq]
  rw [Nat.descFactorial_eq_factorial_mul_choose]
  push_cast
  ring

/-- **The trivial-group graded set has a pole of order exactly `r+1`.**
`(1-q)^{r+1} ∑_n t_r(Y_n) qⁿ = r!·q^r`. -/
theorem trivial_family_generating_function (r : ℕ) :
    (1 - PowerSeries.X) ^ (r + 1) *
        gen (hilbertSeq (fun n => (⊥ : Subgroup (Equiv.Perm (Fin n)))) (fun n => Fin n) r)
      = PowerSeries.C (r.factorial : ℚ) * (PowerSeries.X : PowerSeries ℚ) ^ r := by
  rw [hilbertSeq_bot r, gen_const_mul, ← mul_assoc,
    mul_comm ((1 - PowerSeries.X) ^ (r + 1)) (PowerSeries.C (r.factorial : ℚ)), mul_assoc,
    binomial_generating_function r]

/-- **Sharpness in the `G`-set setting.**  For the trivial-group graded set the
denominator `(1-q)^r` does not suffice: the exponent `r+1` in the main theorem
cannot be lowered without a transitivity hypothesis. -/
theorem trivial_family_denominator_sharp (r : ℕ) :
    ¬ ∃ P : ℚ[X], (1 - PowerSeries.X) ^ r *
        gen (hilbertSeq (fun n => (⊥ : Subgroup (Equiv.Perm (Fin n)))) (fun n => Fin n) r)
      = (P : PowerSeries ℚ) := by
  intro h
  rw [hilbertSeq_bot r] at h
  have hz : EventuallyZero (sdiff^[r] (fun n => (r.factorial : ℚ) * chooseSeq r n)) :=
    (sdiff_iter_eventuallyZero_iff r _).1 h
  rw [sdiff_iter_const_mul (r.factorial : ℚ) (chooseSeq r) r] at hz
  obtain ⟨N, hN⟩ := hz
  have hval := hN N le_rfl
  rw [show chooseSeq r = chooseSeq (0 + r) by rw [Nat.zero_add], sdiff_iter_choose r 0] at hval
  simp only [chooseSeq, Nat.choose_zero_right, Nat.cast_one, mul_one] at hval
  have : (r.factorial : ℚ) ≠ 0 := by
    exact_mod_cast Nat.cast_ne_zero.2 (Nat.factorial_ne_zero r)
  exact this hval

/-- Contrast: the *same* underlying graded set `Y_n = Fin n`, but with the full
symmetric group acting, has a simple pole.  Transitivity, not the size of the
grades, is what collapses the denominator. -/
theorem transitivity_collapses_denominator (r : ℕ) :
    ((1 - PowerSeries.X) *
        gen (hilbertSeq (fun n => Equiv.Perm (Fin n)) (fun n => Fin n) r)
      = (PowerSeries.X : PowerSeries ℚ) ^ r)
    ∧ ¬ ∃ P : ℚ[X], (1 - PowerSeries.X) ^ r *
        gen (hilbertSeq (fun n => (⊥ : Subgroup (Equiv.Perm (Fin n)))) (fun n => Fin n) r)
      = (P : PowerSeries ℚ) :=
  ⟨perm_graded_gen r, trivial_family_denominator_sharp r⟩

end GradedTransitivity