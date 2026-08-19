import Physics.GradedTransitivityGSet

/-!
# Graded `G`-sets: the trivial action, exact denominators, and boundaries

The theorem `denom_of_eventually_transitive` gives denominator `(1 − q)` (hence a
fortiori `(1 − q)^{r+1}`) as soon as the grades are eventually `r`-transitive.  This
file exhibits the *opposite extreme* inside the same framework: the graded `G`-set
`Yₙ = Fin n` with the **trivial** action.  There

  `t r Yₙ = n^{\underline r} = n (n−1) ⋯ (n−r+1)`,

a polynomial of degree exactly `r` in `n`.  Consequently:

* the denominator `(1 − q)^{r+1}` is attained and cannot be improved
  (`denom_trivFin`, `not_denom_trivFin_pow_le`);
* eventual `r`-transitivity genuinely fails for this family when `r ≥ 1`
  (`not_eventually_transitive_trivFin`), so the two regimes are disjoint and the
  hypothesis of the main theorem is not vacuous.

## Main results

* `Physics.GradedTransitivity.transCount_of_trivial` — for a trivial action,
  `t r Y = (#Y)^{\underline r}`.
* `Physics.GradedTransitivity.transCount_trivFin` — `t r (Fin n) = n^{\underline r}`.
* `Physics.GradedTransitivity.denom_trivFin` — denominator divides `(1 − q)^{r+1}`.
* `Physics.GradedTransitivity.not_denom_trivFin_pow_le` — for `s ≤ r` the series
  `(1 − q)^s ∑ₙ t r Yₙ qⁿ` is *not* polynomial: the denominator is exactly
  `(1 − q)^{r+1}`.
* `Physics.GradedTransitivity.not_eventually_transitive_trivFin` — the family is never
  eventually `r`-transitive for `r ≥ 1`.
-/

namespace Physics.GradedTransitivity

open Finset Function PowerSeries MulAction

variable {G : Type*} [Group G]

/-! ## Orbit counts for a trivial action -/

/-- For a trivial action every orbit is a singleton. -/
lemma orbitNum_of_trivial {Y : Type*} [MulAction G Y] (htriv : ∀ (g : G) (y : Y), g • y = y) :
    orbitNum G Y = Nat.card Y := by
  refine (Nat.card_eq_of_bijective (Quotient.mk (orbitRel G Y)) ⟨?_, ?_⟩).symm
  · intro x y hxy
    rw [Quotient.eq] at hxy
    obtain ⟨g, hg⟩ := hxy
    rw [← hg]
    exact htriv g y
  · exact Quotient.mk_surjective

/-- **Transitivity counts of a trivial action** are descending factorials: for the trivial
action nothing is identified, so `t r Y` counts all injective `r`-tuples. -/
theorem transCount_of_trivial {Y : Type*} [Fintype Y] [MulAction G Y]
    (htriv : ∀ (g : G) (y : Y), g • y = y) (r : ℕ) :
    transCount G r Y = (Fintype.card Y).descFactorial r := by
  have htrivTuple : ∀ (g : G) (a : InjTuple r Y), g • a = a := by
    intro g a
    ext i
    simp [htriv]
  rw [transCount, orbitNum_of_trivial htrivTuple, card_injTuple]

/-! ## The graded `G`-set `Yₙ = Fin n` with trivial action -/

/-- `Fin n` regarded as a `G`-set with the trivial action; the `n`-th grade of a graded
`G`-set with no symmetry at all. -/
def TrivFin (_G : Type*) (n : ℕ) : Type := Fin n

instance (G : Type*) (n : ℕ) : Fintype (TrivFin G n) := inferInstanceAs (Fintype (Fin n))
instance (G : Type*) (n : ℕ) : DecidableEq (TrivFin G n) := inferInstanceAs (DecidableEq (Fin n))

instance (G : Type*) [Group G] (n : ℕ) : MulAction G (TrivFin G n) where
  smul _ y := y
  one_smul _ := rfl
  mul_smul _ _ _ := rfl

lemma trivFin_smul (n : ℕ) (g : G) (y : TrivFin G n) : g • y = y := rfl

omit [Group G] in
@[simp] lemma card_trivFin (n : ℕ) : Fintype.card (TrivFin G n) = n := Fintype.card_fin n

/-- `t r (Fin n) = n^{\underline r}` for the trivial action. -/
theorem transCount_trivFin (r n : ℕ) :
    transCount G r (TrivFin G n) = n.descFactorial r := by
  rw [transCount_of_trivial (fun g y => trivFin_smul n g y) r, card_trivFin]

/-! ## Exact denominator for the trivial-action family -/

lemma descFactorial_eq_descPochhammer_eval (r n : ℕ) :
    ((n.descFactorial r : ℤ)) = (descPochhammer ℤ r).eval (n : ℤ) :=
  (descPochhammer_eval_eq_descFactorial ℤ n r).symm

/-- The `r`-th transitivity counts of the trivial-action family form a polynomial sequence
of degree `r`, so the generating function has denominator dividing `(1 − q)^{r+1}`. -/
theorem denom_trivFin (r : ℕ) :
    IsPoly ((1 - X : PowerSeries ℤ) ^ (r + 1)
      * gf (fun n => (transCount G r (TrivFin G n) : ℤ))) := by
  refine denom_of_eventually_polynomial (P := descPochhammer ℤ r) (N := 0) (r := r) ?_ ?_
  · exact le_of_eq (descPochhammer_natDegree ℤ r)
  · intro n _
    rw [transCount_trivFin]
    exact descFactorial_eq_descPochhammer_eval r n

/-- The `r`-th forward difference of `n ↦ n^{\underline r}` is the constant `r !`. -/
lemma fwdDiff_iter_descFactorial (r n : ℕ) :
    ((fwdDiff 1)^[r] (fun k : ℕ => (k.descFactorial r : ℤ))) n = ((Nat.factorial r : ℕ) : ℤ) := by
  have hfun : (fun k : ℕ => (k.descFactorial r : ℤ))
      = fun k : ℕ => (descPochhammer ℤ r).eval (k : ℤ) := by
    funext k
    exact descFactorial_eq_descPochhammer_eval r k
  rw [hfun, fwdDiff_iter_natCast]
  have hdeg : (descPochhammer ℤ r).natDegree = r := descPochhammer_natDegree ℤ r
  have hmain := Polynomial.fwdDiff_iter_degree_eq_factorial (descPochhammer ℤ r)
  rw [hdeg] at hmain
  have hlead : (descPochhammer ℤ r).leadingCoeff = 1 := monic_descPochhammer ℤ r
  rw [hlead] at hmain
  have := congrFun hmain (n : ℤ)
  simpa using this

/-- **Exactness.**  For the trivial-action family the denominator is *exactly*
`(1 − q)^{r+1}`: no smaller power of `1 − q` clears the denominator. -/
theorem not_denom_trivFin_pow_le {s r : ℕ} (hs : s ≤ r) :
    ¬ IsPoly ((1 - X : PowerSeries ℤ) ^ s
      * gf (fun n => (transCount G r (TrivFin G n) : ℤ))) := by
  intro hpoly
  -- pass from `s` up to `r`, then use the criterion
  have hmul := (isPoly_one_sub_X_pow (r - s)).mul hpoly
  have hrs : (r - s) + s = r := Nat.sub_add_cancel hs
  have hrw : (1 - X : PowerSeries ℤ) ^ (r - s)
      * ((1 - X : PowerSeries ℤ) ^ s * gf (fun n => (transCount G r (TrivFin G n) : ℤ)))
      = (1 - X : PowerSeries ℤ) ^ r * gf (fun n => (transCount G r (TrivFin G n) : ℤ)) := by
    rw [← mul_assoc, ← pow_add, hrs]
  rw [hrw] at hmul
  obtain ⟨N, hN⟩ := (denom_pow_iff_fwdDiff_eventually_zero r _).mp hmul
  have hseq : (fun n => (transCount G r (TrivFin G n) : ℤ))
      = fun n : ℕ => (n.descFactorial r : ℤ) := by
    funext n; rw [transCount_trivFin]
  rw [hseq] at hN
  have hzero := hN N le_rfl
  rw [fwdDiff_iter_descFactorial] at hzero
  have : (0 : ℤ) < ((Nat.factorial r : ℕ) : ℤ) := by exact_mod_cast Nat.factorial_pos r
  omega

/-! ## The two regimes are disjoint -/

lemma two_le_descFactorial {r n : ℕ} (hr : 1 ≤ r) (hn : r + 2 ≤ n) : 2 ≤ n.descFactorial r := by
  obtain ⟨k, rfl⟩ : ∃ k, r = k + 1 := ⟨r - 1, by omega⟩
  rw [Nat.descFactorial_succ]
  have hpos : 1 ≤ n.descFactorial k := by
    have : ¬ n < k := by omega
    have h0 : n.descFactorial k ≠ 0 := by
      simpa [Nat.descFactorial_eq_zero_iff_lt] using this
    omega
  have : 2 ≤ n - k := by omega
  calc 2 = 2 * 1 := by ring
    _ ≤ (n - k) * n.descFactorial k := Nat.mul_le_mul this hpos

/-- For `r ≥ 1` the trivial-action family is **never** eventually `r`-transitive: the
hypothesis of the main theorem genuinely restricts the graded `G`-sets it applies to. -/
theorem not_eventually_transitive_trivFin {r : ℕ} (hr : 1 ≤ r) (N : ℕ) :
    ¬ (∀ n, N ≤ n → IsTransitiveDeg G r (TrivFin G n)) := by
  intro h
  set n := N + r + 2 with hn
  have hone : transCount G r (TrivFin G n) = 1 :=
    (transCount_eq_one_iff r (TrivFin G n)).mpr (h n (by omega))
  rw [transCount_trivFin] at hone
  have := two_le_descFactorial (n := n) hr (by omega)
  omega

end Physics.GradedTransitivity