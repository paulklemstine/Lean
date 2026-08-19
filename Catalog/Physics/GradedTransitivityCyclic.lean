import Physics.GradedTransitivityGSet

/-!
# An interpolating graded `G`-set: `ℤ` translating the cyclic grades `ZMod (n+1)`

Fix the group `G = Multiplicative ℤ` and let the `n`-th grade be `ZMod (n+1)` with `G`
acting by translation.  This graded `G`-set is `1`-transitive in *every* grade, so the
main theorem applies with `r = 1` and gives denominator `(1 − q)`.  Its `2`-nd
transitivity counts, however, grow linearly:

  `t₂(ZMod (n+1)) = n`,

so `∑ₙ t₂(Yₙ) qⁿ` has denominator exactly `(1 − q)^2`.  This exhibits the intermediate
regime between the two extremes proved elsewhere in this development (eventual
`r`-transitivity gives `(1 − q)`; the trivial action gives exactly `(1 − q)^{r+1}`).

## Main results

* `Physics.GradedTransitivity.isTransitiveDeg_one_cycGrade` — every grade is
  `1`-transitive.
* `Physics.GradedTransitivity.transCount_two_cycGrade` — `t₂(ZMod n) = n − 1`.
* `Physics.GradedTransitivity.denom_cycGrade_two` — `(1 − q)^2` clears the denominator of
  `∑ₙ t₂ qⁿ`, while `denom_cycGrade_two_not_one` shows `(1 − q)` does not.
-/

namespace Physics.GradedTransitivity

open Finset Function PowerSeries MulAction

/-- The `n`-th cyclic grade `ZMod n`, to be acted on by `Multiplicative ℤ` by
translation. -/
def CycGrade (n : ℕ) : Type := ZMod n

namespace CycGrade

instance (n : ℕ) [NeZero n] : Fintype (CycGrade n) := inferInstanceAs (Fintype (ZMod n))
instance (n : ℕ) : DecidableEq (CycGrade n) := inferInstanceAs (DecidableEq (ZMod n))
instance (n : ℕ) : AddCommGroup (CycGrade n) := inferInstanceAs (AddCommGroup (ZMod n))

/-- The underlying element of `ZMod n`. -/
def toZMod {n : ℕ} (x : CycGrade n) : ZMod n := x

/-- An element of `ZMod n` viewed as a grade. -/
def ofZMod {n : ℕ} (x : ZMod n) : CycGrade n := x

lemma toZMod_injective {n : ℕ} {x y : CycGrade n} (h : toZMod x = toZMod y) : x = y := h

@[simp] lemma toZMod_ofZMod {n : ℕ} (x : ZMod n) : toZMod (ofZMod x) = x := rfl

@[simp] lemma toZMod_add {n : ℕ} (x y : CycGrade n) :
    toZMod (x + y) = toZMod x + toZMod y := rfl

instance (n : ℕ) : MulAction (Multiplicative ℤ) (CycGrade n) where
  smul g x := ofZMod ((Multiplicative.toAdd g : ℤ) : ZMod n) + x
  one_smul x := by
    refine toZMod_injective ?_
    show ((Multiplicative.toAdd (1 : Multiplicative ℤ) : ℤ) : ZMod n) + toZMod x = toZMod x
    simp
  mul_smul g h x := by
    refine toZMod_injective ?_
    show ((Multiplicative.toAdd (g * h) : ℤ) : ZMod n) + toZMod x
      = ((Multiplicative.toAdd g : ℤ) : ZMod n)
        + (((Multiplicative.toAdd h : ℤ) : ZMod n) + toZMod x)
    rw [toAdd_mul]
    push_cast
    ring

@[simp] lemma toZMod_smul {n : ℕ} (g : Multiplicative ℤ) (x : CycGrade n) :
    toZMod (g • x) = ((Multiplicative.toAdd g : ℤ) : ZMod n) + toZMod x := rfl

end CycGrade

open CycGrade

/-- Translations realize every difference. -/
lemma exists_smul_eq_cycGrade (n : ℕ) (x y : CycGrade n) :
    ∃ g : Multiplicative ℤ, g • x = y := by
  obtain ⟨k, hk⟩ := ZMod.intCast_surjective (n := n) (toZMod y - toZMod x)
  refine ⟨Multiplicative.ofAdd k, toZMod_injective ?_⟩
  rw [toZMod_smul]
  simp only [toAdd_ofAdd, hk]
  ring

/-- Injectivity of a pair is the non-vanishing of its difference. -/
lemma injective_two_iff {Y : Type*} (a : Fin 2 → Y) : Function.Injective a ↔ a 0 ≠ a 1 := by
  constructor
  · intro h hne
    exact absurd (h hne) (by decide)
  · intro h i j hij
    fin_cases i <;> fin_cases j <;> simp_all

/-! ## Every grade is `1`-transitive -/

theorem isTransitiveDeg_one_cycGrade (n : ℕ) [NeZero n] :
    IsTransitiveDeg (Multiplicative ℤ) 1 (CycGrade n) := by
  refine ⟨⟨⟨fun _ => ofZMod 0, ?_⟩⟩, ?_⟩
  · intro i j _
    exact Subsingleton.elim i j
  · intro a b
    obtain ⟨g, hg⟩ := exists_smul_eq_cycGrade n (a.1 0) (b.1 0)
    refine ⟨g, ?_⟩
    ext i
    have hi : i = 0 := Subsingleton.elim i 0
    subst hi
    simpa using hg

/-- The transitivity generating function of the cyclic family at `r = 1`: denominator
`(1 − q)`, a fortiori `(1 − q)^{r+1}`. -/
theorem denom_cycGrade_one :
    IsPoly ((1 - X : PowerSeries ℤ) ^ (1 + 1)
      * gf (fun n => (transCount (Multiplicative ℤ) 1 (CycGrade (n + 1)) : ℤ))) :=
  denom_of_eventually_transitive (Y := fun n => CycGrade (n + 1)) (N := 0)
    (fun n _ => isTransitiveDeg_one_cycGrade (n + 1))

/-! ## The second transitivity count grows linearly -/

section Two

variable (n : ℕ) [NeZero n]

/-- The difference invariant of an injective pair. -/
def pairDiff (a : InjTuple 2 (CycGrade n)) : {d : ZMod n // d ≠ 0} :=
  ⟨toZMod (a.1 1) - toZMod (a.1 0), by
    intro hd
    have hne : a.1 0 ≠ a.1 1 := (injective_two_iff a.1).mp a.2
    exact hne (toZMod_injective (sub_eq_zero.mp hd).symm)⟩

omit [NeZero n] in
lemma pairDiff_smul (g : Multiplicative ℤ) (a : InjTuple 2 (CycGrade n)) :
    pairDiff n (g • a) = pairDiff n a := by
  apply Subtype.ext
  show toZMod ((g • a).1 1) - toZMod ((g • a).1 0)
    = toZMod (a.1 1) - toZMod (a.1 0)
  simp only [InjTuple.smul_apply, toZMod_smul]
  ring

/-- The map sending an orbit of injective pairs to its (nonzero) difference. -/
noncomputable def orbitPairMap :
    orbitRel.Quotient (Multiplicative ℤ) (InjTuple 2 (CycGrade n)) → {d : ZMod n // d ≠ 0} :=
  Quotient.lift (pairDiff n) (by
    rintro a b ⟨g, hg⟩
    rw [← hg, pairDiff_smul])

omit [NeZero n] in
lemma orbitPairMap_bijective : Function.Bijective (orbitPairMap n) := by
  constructor
  · intro x y hxy
    induction x using Quotient.inductionOn with
    | _ a =>
      induction y using Quotient.inductionOn with
      | _ b =>
        have hd : toZMod (a.1 1) - toZMod (a.1 0) = toZMod (b.1 1) - toZMod (b.1 0) :=
          congrArg Subtype.val hxy
        obtain ⟨g, hg⟩ := exists_smul_eq_cycGrade n (b.1 0) (a.1 0)
        refine Quotient.sound ⟨g, ?_⟩
        ext i
        refine toZMod_injective ?_
        have hg0 : ((Multiplicative.toAdd g : ℤ) : ZMod n) + toZMod (b.1 0) = toZMod (a.1 0) := by
          have := congrArg toZMod hg
          simpa using this
        fin_cases i
        · show ((Multiplicative.toAdd g : ℤ) : ZMod n) + toZMod (b.1 0) = toZMod (a.1 0)
          exact hg0
        · show ((Multiplicative.toAdd g : ℤ) : ZMod n) + toZMod (b.1 1) = toZMod (a.1 1)
          have hkey : ((Multiplicative.toAdd g : ℤ) : ZMod n)
              = toZMod (a.1 0) - toZMod (b.1 0) := by
            rw [← hg0]; ring
          rw [hkey]
          have : toZMod (b.1 1) = toZMod (b.1 0) + (toZMod (a.1 1) - toZMod (a.1 0)) := by
            rw [hd]; ring
          rw [this]
          ring
  · rintro ⟨d, hd⟩
    refine ⟨Quotient.mk _ ⟨![ofZMod 0, ofZMod d], ?_⟩, ?_⟩
    · rw [injective_two_iff]
      intro h
      exact hd (by simpa using (congrArg toZMod h).symm)
    · apply Subtype.ext
      show toZMod ((![ofZMod 0, ofZMod d] : Fin 2 → CycGrade n) 1)
        - toZMod ((![ofZMod 0, ofZMod d] : Fin 2 → CycGrade n) 0) = d
      simp

/-- **`t₂` of the cyclic grade.**  There are exactly `n − 1` orbits of injective pairs:
one for each nonzero difference. -/
theorem transCount_two_cycGrade :
    transCount (Multiplicative ℤ) 2 (CycGrade n) = n - 1 := by
  classical
  have hcard : Nat.card {d : ZMod n // d ≠ 0} = n - 1 := by
    rw [Nat.card_eq_fintype_card]
    have h1 : Fintype.card {d : ZMod n // d ≠ 0}
        = Fintype.card (ZMod n) - Fintype.card {d : ZMod n // d = 0} :=
      Fintype.card_subtype_compl _
    rw [h1, Fintype.card_subtype_eq, ZMod.card]
  rw [transCount, orbitNum,
    Nat.card_eq_of_bijective (orbitPairMap n) (orbitPairMap_bijective n), hcard]

end Two

lemma transCount_two_cycGrade_seq :
    (fun n => (transCount (Multiplicative ℤ) 2 (CycGrade (n + 1)) : ℤ)) = fun n : ℕ => (n : ℤ) := by
  funext n
  rw [transCount_two_cycGrade (n + 1)]
  simp

/-- The generating function of the second transitivity counts of the cyclic family is
`∑ₙ n qⁿ`, whose denominator is cleared by `(1 − q)^2`. -/
theorem denom_cycGrade_two :
    IsPoly ((1 - X : PowerSeries ℤ) ^ 2
      * gf (fun n => (transCount (Multiplicative ℤ) 2 (CycGrade (n + 1)) : ℤ))) := by
  refine (denom_pow_iff_fwdDiff_eventually_zero 2 _).mpr ⟨0, ?_⟩
  intro m _
  rw [transCount_two_cycGrade_seq]
  simp [Function.iterate_succ_apply', fwdDiff]

/-- …and `(1 − q)` alone does **not** clear it: the denominator is exactly `(1 − q)^2`,
strictly between the transitive regime `(1 − q)` and the general bound `(1 − q)^3` for
`r = 2`. -/
theorem denom_cycGrade_two_not_one :
    ¬ IsPoly ((1 - X : PowerSeries ℤ) ^ 1
      * gf (fun n => (transCount (Multiplicative ℤ) 2 (CycGrade (n + 1)) : ℤ))) := by
  intro hpoly
  obtain ⟨N, hN⟩ := (denom_pow_iff_fwdDiff_eventually_zero 1 _).mp hpoly
  rw [transCount_two_cycGrade_seq] at hN
  have hzero := hN N le_rfl
  simp [fwdDiff] at hzero

end Physics.GradedTransitivity