import Combinatorics.BellDefectSharpConstant

/-!
# A falling-factorial lower bound for the fibre spectrum

Every bound proved so far in this thread is *linear* in the spectrum `t_r` (= the number of
`G`-orbits of injective `r`-tuples).  This file proves the first genuinely *multiplicative*
constraint, the first half of Conjecture I of `FUTURE_DIRECTIONS.md`:

  `t_1^{\underline r} ≤ t_r`  (`descFactorial_injOrbits_one_le`),

i.e. `t_r ≥ t_1(t_1−1)⋯(t_1−r+1)`.  The mechanism is that an `r`-tuple of *pairwise distinct
point orbits* can be lifted to an injective `r`-tuple of points, and different tuples of orbits
give different orbits of tuples; so the falling factorial of the orbit count embeds into the
`r`-th fibre.

Consequences:

* `injOrbits_one_eq_card_orbits` : `t_1` is exactly Burnside's orbit count on `X`.
* `sq_le_injOrbits_two_add` : `t_1² ≤ t_2 + t_1`, i.e. `t_1(t_1 − 1) ≤ t_2`; a badly intransitive
  action has *quadratically* many pair orbits.
* `bellDefect_ge_of_card_orbits` : hence an explicit lower bound for the Bell defect in terms of
  the number of point orbits alone,
  `|G|·((t_1 − 1) + (B_k − 1)·(t_1·(t_1 − 1) − 1)) ≤ D_k` for `2 ≤ k ≤ |X|` — the defect grows at
  least quadratically in the failure of transitivity.

There are no `sorry`s, no `native_decide`, and no new axioms.
-/

open Finset MulAction Function

namespace BellDefectGraded

open MoonshineBell MoonshineFibre FibreSpectrum

section OrbitProduct

variable (G : Type*) [Group G] (X : Type*) [MulAction G X] [Finite X]

/-- The first spectral value is Burnside's orbit count. -/
theorem injOrbits_one_eq_card_orbits :
    injOrbits G X 1 = Nat.card (orbitRel.Quotient G X) := by
  have hfin : Finite (orbitRel.Quotient G (Fin 1 → X)) := Quotient.finite _
  have hfib : {o : orbitRel.Quotient G (Fin 1 → X) // orbitPattern o = idPattern 1}
      ≃ orbitRel.Quotient G (Fin 1 → X) := by
    refine Equiv.subtypeUnivEquiv fun o => ?_
    induction o using Quotient.inductionOn with
    | h f =>
      refine Subtype.ext (funext fun i => ?_)
      have hf : Function.Injective f := fun a b _ => Subsingleton.elim a b
      exact congrFun (kerPat_of_injective hf) i
  have hq : orbitRel.Quotient G (Fin 1 → X) ≃ orbitRel.Quotient G X := by
    refine Quotient.congr (Equiv.funUnique (Fin 1) X) ?_
    intro a b
    constructor
    · intro hab
      obtain ⟨g, hg⟩ := (orbitRel_apply).1 hab
      exact (orbitRel_apply).2 ⟨g, congrFun hg default⟩
    · intro hab
      obtain ⟨g, hg⟩ := (orbitRel_apply).1 hab
      refine (orbitRel_apply).2 ⟨g, funext fun i => ?_⟩
      have hi : i = default := Subsingleton.elim i default
      subst hi
      exact hg
  show Nat.card {o : orbitRel.Quotient G (Fin 1 → X) // orbitPattern o = idPattern 1}
      = Nat.card (orbitRel.Quotient G X)
  rw [Nat.card_congr hfib, Nat.card_congr hq]

/-- **The falling factorial of the orbit count embeds in the `r`-th fibre.**  Choosing one point
from each of `r` pairwise distinct orbits produces an injective `r`-tuple, and distinct choices of
orbits give distinct orbits of tuples. -/
theorem descFactorial_injOrbits_one_le (r : ℕ) :
    (injOrbits G X 1).descFactorial r ≤ injOrbits G X r := by
  classical
  have hfinQ : Finite (orbitRel.Quotient G X) := Quotient.finite _
  have hfin : Finite (orbitRel.Quotient G (Fin r → X)) := Quotient.finite _
  -- the lifting map: a tuple of distinct orbits ↦ the orbit of a tuple of representatives
  have hlift : ∀ u : {u : Fin r → orbitRel.Quotient G X // Function.Injective u},
      Function.Injective (fun i => Quotient.out (u.1 i)) := by
    rintro ⟨u, hu⟩ i j hij
    have hij' : Quotient.out (u i) = Quotient.out (u j) := hij
    refine hu ?_
    have h : Quotient.mk (orbitRel G X) (Quotient.out (u i))
        = Quotient.mk (orbitRel G X) (Quotient.out (u j)) := by rw [hij']
    simpa using h
  set Ψ : {u : Fin r → orbitRel.Quotient G X // Function.Injective u} →
      {o : orbitRel.Quotient G (Fin r → X) // orbitPattern o = idPattern r} :=
    fun u => ⟨Quotient.mk (orbitRel G (Fin r → X)) (fun i => Quotient.out (u.1 i)),
      Subtype.ext (kerPat_of_injective (hlift u))⟩
  have hinj : Function.Injective Ψ := by
    rintro ⟨u, hu⟩ ⟨v, hv⟩ huv
    have h := congrArg Subtype.val huv
    obtain ⟨g, hg⟩ := (orbitRel_apply).1 (Quotient.exact h)
    have hg' : ∀ i, g • Quotient.out (v i) = Quotient.out (u i) := fun i => congrFun hg i
    refine Subtype.ext (funext fun i => ?_)
    have h2 : Quotient.mk (orbitRel G X) (Quotient.out (u i))
        = Quotient.mk (orbitRel G X) (Quotient.out (v i)) :=
      Quotient.sound ((orbitRel_apply).2 ⟨g, hg' i⟩)
    simpa using h2
  have hcard := Nat.card_le_card_of_injective Ψ hinj
  rw [card_injective_tuples (orbitRel.Quotient G X) r,
    ← injOrbits_one_eq_card_orbits G X] at hcard
  exact hcard

/-- **The quadratic case**: `t_1² ≤ t_2 + t_1`, i.e. `t_1(t_1 − 1) ≤ t_2`.  A badly intransitive
action has quadratically many orbits of pairs. -/
theorem sq_le_injOrbits_two_add :
    injOrbits G X 1 * injOrbits G X 1 ≤ injOrbits G X 2 + injOrbits G X 1 := by
  have h := descFactorial_injOrbits_one_le G X 2
  have hd : (injOrbits G X 1).descFactorial 2
      = injOrbits G X 1 * (injOrbits G X 1 - 1) := by
    simp [Nat.descFactorial]
    ring
  rw [hd] at h
  rcases Nat.eq_zero_or_pos (injOrbits G X 1) with h0 | hpos
  · rw [h0]
    simp
  · obtain ⟨n, hn⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : injOrbits G X 1 ≠ 0)
    rw [hn] at h ⊢
    simp only [Nat.succ_sub_one] at h
    have hsucc : n.succ * n.succ = n.succ * n + n.succ := by
      simp only [Nat.succ_eq_add_one]
      ring
    omega

end OrbitProduct

section DefectBound

variable (k : ℕ) (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

/-- **The Bell defect grows quadratically in the failure of transitivity.**  Writing `t_1` for the
number of point orbits, the `k`-th defect obeys
`|G|·((t_1 − 1) + (B_k − 1)·(t_1·(t_1 − 1) − 1)) ≤ D_k` for `2 ≤ k ≤ |X|`: the bracket is
quadratic in `t_1`, whereas the general lower bound `le_bellDefect_of_two_le` was only linear. -/
theorem bellDefect_ge_of_card_orbits (hk2 : 2 ≤ k) (hk : k ≤ Nat.card X) :
    ((injOrbits G X 1 - 1)
        + (bell k - 1) * (injOrbits G X 1 * (injOrbits G X 1 - 1) - 1)) * Nat.card G
      ≤ bellDefect k G X := by
  refine le_trans (Nat.mul_le_mul_right _ ?_) (le_bellDefect_of_two_le k G X hk2 hk)
  refine Nat.add_le_add_left (Nat.mul_le_mul_left _ (Nat.sub_le_sub_right ?_ 1)) _
  have h := descFactorial_injOrbits_one_le G X 2
  have hd : (injOrbits G X 1).descFactorial 2
      = injOrbits G X 1 * (injOrbits G X 1 - 1) := by
    simp [Nat.descFactorial]
    ring
  rwa [hd] at h

end DefectBound

end BellDefectGraded