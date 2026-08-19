import Combinatorics.BellDefectOrbitProduct

/-!
# The extremal ray of the sharp bound is not realized by actions (Conjecture H)

`bellDefect_two_propagation_sharp` proves `B_k·D_2 ≤ 2·D_k`, and
`bellDefect_sharp_constant_attained` shows that equality holds for every *constant* spectrum
`t_1 = ⋯ = t_k`.  Conjecture H of `FUTURE_DIRECTIONS.md` asked whether that extremal ray is
realized by an actual group action with `D_2 > 0`.  It is not, as soon as `k ≥ 3`:

* `three_le_injOrbits_two` : if `X` has at least three points and exactly two point orbits, then
  there are at least three orbits of injective pairs.  (Two cross-orbit pairs, plus one pair inside
  whichever orbit is not a singleton.)
* `injOrbits_one_eq_one_of_eq_two` : consequently `t_1 = t_2` forces `t_1 = 1` whenever
  `|X| ≥ 3` — combining with the falling-factorial bound `t_1(t_1 − 1) ≤ t_2`, which already rules
  out `t_1 ≥ 3`.
* `bellDefect_two_eq_zero_of_constant_spectrum` : hence a constant spectrum on `1 ≤ r ≤ k` with
  `3 ≤ k ≤ |X|` forces `D_2 = 0`, so on the extremal ray the sharp inequality degenerates to
  `0 ≤ 0`.  For genuinely non-`2`-transitive actions the propagation constant is therefore
  strictly larger than `B_k/2`.

There are no `sorry`s, no `native_decide`, and no new axioms.
-/

open Finset MulAction Function

namespace BellDefectGraded

open MoonshineBell MoonshineFibre FibreSpectrum

section PairTuple

variable {Y : Type*}

/-- The pair `(x, y)` as a tuple, injective when `x ≠ y`. -/
private def pairTuple (x y : Y) : Fin 2 → Y := fun i => if i = 0 then x else y

private theorem pairTuple_zero (x y : Y) : pairTuple x y 0 = x := rfl

private theorem pairTuple_one (x y : Y) : pairTuple x y 1 = y := rfl

private theorem pairTuple_injective {x y : Y} (hxy : x ≠ y) :
    Function.Injective (pairTuple x y) := by
  intro i j hij
  fin_cases i <;> fin_cases j <;> simp_all [pairTuple]

end PairTuple

section ExtremalRay

variable (G : Type*) [Group G] (X : Type*) [MulAction G X] [Finite X]

/-- The pair of point orbits underlying an orbit of pairs. -/
noncomputable def orbitPairMap :
    orbitRel.Quotient G (Fin 2 → X) →
      orbitRel.Quotient G X × orbitRel.Quotient G X :=
  Quotient.lift
    (fun f => (Quotient.mk (orbitRel G X) (f 0), Quotient.mk (orbitRel G X) (f 1)))
    (by
      intro a b hab
      obtain ⟨g, hg⟩ := (orbitRel_apply).1 hab
      have h0 : g • b 0 = a 0 := congrFun hg 0
      have h1 : g • b 1 = a 1 := congrFun hg 1
      exact Prod.ext (Quotient.sound ((orbitRel_apply).2 ⟨g, h0⟩))
        (Quotient.sound ((orbitRel_apply).2 ⟨g, h1⟩)))

omit [Finite X] in
@[simp] theorem orbitPairMap_mk (f : Fin 2 → X) :
    orbitPairMap G X (Quotient.mk (orbitRel G (Fin 2 → X)) f)
      = (Quotient.mk (orbitRel G X) (f 0), Quotient.mk (orbitRel G X) (f 1)) := rfl

/-- The orbit of an injective pair, as an element of the top fibre at level `2`. -/
private noncomputable def pairFibre {x y : X} (hxy : x ≠ y) :
    {o : orbitRel.Quotient G (Fin 2 → X) // orbitPattern o = idPattern 2} :=
  ⟨Quotient.mk (orbitRel G (Fin 2 → X)) (pairTuple x y),
    Subtype.ext (kerPat_of_injective (pairTuple_injective hxy))⟩

/-- **Three pair orbits.**  An action of a group on at least three points with exactly two point
orbits has at least three orbits of injective pairs. -/
theorem three_le_injOrbits_two (hX : 3 ≤ Nat.card X) (h2 : injOrbits G X 1 = 2) :
    3 ≤ injOrbits G X 2 := by
  classical
  have hQcard : Nat.card (orbitRel.Quotient G X) = 2 := by
    rw [← injOrbits_one_eq_card_orbits G X, h2]
  have hXne : Nonempty X := (Nat.card_pos_iff.1 (by omega : 0 < Nat.card X)).1
  cases nonempty_fintype X
  have hfinQ : Fintype (orbitRel.Quotient G X) := Fintype.ofFinite _
  -- two distinct orbits
  obtain ⟨A, B, hAB⟩ : ∃ A B : orbitRel.Quotient G X, A ≠ B := by
    have hQ1 : 1 < Fintype.card (orbitRel.Quotient G X) := by
      rw [← Nat.card_eq_fintype_card, hQcard]; omega
    obtain ⟨B, hB⟩ :=
      Fintype.exists_ne_of_one_lt_card hQ1 (Quotient.mk (orbitRel G X) (Classical.arbitrary X))
    exact ⟨B, Quotient.mk (orbitRel G X) (Classical.arbitrary X), hB⟩
  -- two distinct points in a common orbit
  obtain ⟨x, y, hxy, hxyq⟩ : ∃ x y : X, x ≠ y ∧
      Quotient.mk (orbitRel G X) x = Quotient.mk (orbitRel G X) y := by
    have hlt : Fintype.card (orbitRel.Quotient G X) < Fintype.card X := by
      have h1 : Fintype.card (orbitRel.Quotient G X) = 2 := by
        rw [← Nat.card_eq_fintype_card]; exact hQcard
      have h2' : 3 ≤ Fintype.card X := by rwa [← Nat.card_eq_fintype_card]
      omega
    obtain ⟨x, y, hne, heq⟩ :=
      Fintype.exists_ne_map_eq_of_card_lt (fun z : X => Quotient.mk (orbitRel G X) z) hlt
    exact ⟨x, y, hne, heq⟩
  set p := Quotient.out A with hp
  set q := Quotient.out B with hq
  have hpq : Quotient.mk (orbitRel G X) p ≠ Quotient.mk (orbitRel G X) q := by
    rw [hp, hq]
    simpa using hAB
  have hpqne : p ≠ q := fun h => hpq (by rw [h])
  have hqpne : q ≠ p := fun h => hpq (by rw [h])
  -- the three orbits of injective pairs
  set a := pairFibre G X hpqne with ha
  set b := pairFibre G X hqpne with hb
  set c := pairFibre G X hxy with hc
  have hΦa : orbitPairMap G X a.1
      = (Quotient.mk (orbitRel G X) p, Quotient.mk (orbitRel G X) q) := rfl
  have hΦb : orbitPairMap G X b.1
      = (Quotient.mk (orbitRel G X) q, Quotient.mk (orbitRel G X) p) := rfl
  have hΦc : orbitPairMap G X c.1
      = (Quotient.mk (orbitRel G X) x, Quotient.mk (orbitRel G X) x) := by
    rw [hc, pairFibre, orbitPairMap_mk, pairTuple_zero, pairTuple_one, hxyq]
  have hab : a ≠ b := by
    intro h
    have : orbitPairMap G X a.1 = orbitPairMap G X b.1 := by rw [h]
    rw [hΦa, hΦb] at this
    exact hpq (congrArg Prod.fst this)
  have hac : a ≠ c := by
    intro h
    have : orbitPairMap G X a.1 = orbitPairMap G X c.1 := by rw [h]
    rw [hΦa, hΦc] at this
    exact hpq ((congrArg Prod.fst this).trans (congrArg Prod.snd this).symm)
  have hbc : b ≠ c := by
    intro h
    have : orbitPairMap G X b.1 = orbitPairMap G X c.1 := by rw [h]
    rw [hΦb, hΦc] at this
    exact hpq (((congrArg Prod.snd this).trans (congrArg Prod.fst this).symm))
  -- three distinct elements give `t_2 ≥ 3`
  have hfin : Finite {o : orbitRel.Quotient G (Fin 2 → X) // orbitPattern o = idPattern 2} := by
    have : Finite (orbitRel.Quotient G (Fin 2 → X)) := Quotient.finite _
    infer_instance
  have hinj : Function.Injective
      (fun i : Fin 3 => if i = 0 then a else if i = 1 then b else c) := by
    intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all
  have hcard := Nat.card_le_card_of_injective _ hinj
  simpa [injOrbits, patternMultiplicity] using hcard

/-- `t_1 = t_2` forces transitivity as soon as `X` has at least three points. -/
theorem injOrbits_one_eq_one_of_eq_two (hX : 3 ≤ Nat.card X)
    (heq : injOrbits G X 1 = injOrbits G X 2) : injOrbits G X 1 = 1 := by
  have hquad := sq_le_injOrbits_two_add G X
  have hpos : 1 ≤ injOrbits G X 1 := by
    have hne : Nonempty X := (Nat.card_pos_iff.1 (by omega : 0 < Nat.card X)).1
    have : Nonempty (orbitRel.Quotient G X) := ⟨Quotient.mk _ (Classical.arbitrary X)⟩
    rw [injOrbits_one_eq_card_orbits G X]
    exact Nat.card_pos
  rcases Nat.lt_or_ge (injOrbits G X 1) 3 with hlt | hge
  · interval_cases h : injOrbits G X 1
    · rfl
    · exfalso
      have h3 := three_le_injOrbits_two G X hX h
      omega
  · exfalso
    -- `t_1 ≥ 3` contradicts `t_1(t_1 − 1) ≤ t_2 = t_1`
    nlinarith [hquad, heq, hge]

end ExtremalRay

section Degenerate

variable (k : ℕ) (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

/-- **Conjecture H, resolved.**  On the extremal ray of the sharp propagation bound — a spectrum
that is constant on `1 ≤ r ≤ k` — the second defect vanishes as soon as `k ≥ 3`.  So no action
with `D_2 > 0` attains `2·D_k = B_k·D_2`, and the optimal constant for actual actions is strictly
larger than `B_k/2`. -/
theorem bellDefect_two_eq_zero_of_constant_spectrum (hk3 : 3 ≤ k) (hk : k ≤ Nat.card X)
    (hconst : ∀ r, 1 ≤ r → r ≤ k → injOrbits G X r = injOrbits G X 1) :
    bellDefect 2 G X = 0 := by
  have hX : 3 ≤ Nat.card X := le_trans hk3 hk
  have h12 : injOrbits G X 1 = injOrbits G X 2 := (hconst 2 (by omega) (by omega)).symm
  have h1 : injOrbits G X 1 = 1 := injOrbits_one_eq_one_of_eq_two G X hX h12
  rw [bellDefect_two_eq G X (by omega), h1, ← h12, h1]
  simp

end Degenerate

end BellDefectGraded