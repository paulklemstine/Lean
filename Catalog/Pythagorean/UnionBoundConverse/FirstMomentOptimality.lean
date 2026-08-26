import Pythagorean.UnionBoundConverse.PairwiseIndependence

/-!
# First-moment optimality, and the sharp role of exactness

Third cycle.  Two questions left open by `UniversalCollision.lean` are settled.

## 1. Is `2`-universality itself optimal?

`fiber_sq_lower_bound` and `collisionCount_ge_pigeonhole` show, by a
Cauchy–Schwarz argument on the fibre sizes, that **every** single hash function
— universal or not — collides on at least `n²/m - n` ordered pairs of `n` keys.
Averaging (`exp_collisionCount_ge_of_any_family`) this holds for the expected
collision count of an arbitrary family.  Since an exactly `2`-universal family
achieves expectation exactly `n(n-1)/m = n²/m - n/m`, the gap to the absolute
optimum is only the additive term `n(1 - 1/m)`
(`two_universal_first_moment_near_optimal`): the union bound's first moment is
essentially unimprovable, and the Carter–Wegman axiom is not costing anything
at the level of expectations.

## 2. Is *exactness* needed for the `1/m` converse?

Yes, and sharply so.  `exists_injective_sub2Universal` builds, for `n ≤ m`, a
one-element family that is Carter–Wegman `2`-universal (`P(h x = h y) = 0 ≤
1/m`) and never collides.  Together with the pigeonhole theorem this gives the
**dichotomy** `sub2Universal_dichotomy`: for the inequality-only notion the
extremal collision probability is `0` when `n ≤ m` and `1` when `n > m`, with
nothing in between.  The value `1/m` of the main theorem is therefore a
phenomenon of *exact* (equivalently, pairwise independent) `2`-universality,
not of the union bound's hypothesis.
-/

namespace UnionBoundConverse

open Finset

variable {Ω K V : Type*} [Fintype Ω] [Fintype V] [DecidableEq K] [DecidableEq V]

/-! ### Every hash function collides at least `n²/m - n` times -/

omit [DecidableEq K] in
/-- Cauchy–Schwarz on the fibre sizes: the sum of squared fibre cardinalities of
any map `f : K → V` restricted to `S` is at least `n²/m`. -/
theorem fiber_sq_lower_bound (f : K → V) (S : Finset K) :
    (S.card : ℝ) ^ 2 / (Fintype.card V : ℝ) ≤
      ∑ v : V, (((S.filter (fun x => f x = v)).card : ℝ)) ^ 2 := by
  have hsum : ∑ v : V, ((S.filter (fun x => f x = v)).card : ℝ) = (S.card : ℝ) := by
    have := Finset.card_eq_sum_card_fiberwise
      (f := f) (s := S) (t := (Finset.univ : Finset V)) (fun x _ => Finset.mem_univ (f x))
    exact_mod_cast this.symm
  have hCS := Finset.sum_sq_le_sum_mul_sum_of_sq_eq_mul (Finset.univ : Finset V)
      (r := fun v => ((S.filter (fun x => f x = v)).card : ℝ))
      (f := fun v => ((S.filter (fun x => f x = v)).card : ℝ) ^ 2)
      (g := fun _ => (1 : ℝ))
      (fun v _ => sq_nonneg _) (fun _ _ => zero_le_one)
      (fun v _ => by dsimp only; ring)
  rw [hsum, Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one] at hCS
  rcases Nat.eq_zero_or_pos (Fintype.card V) with hm | hm
  · rw [hm]
    simp only [Nat.cast_zero, div_zero]
    exact Finset.sum_nonneg fun v _ => sq_nonneg _
  · have hmR : (0 : ℝ) < Fintype.card V := by exact_mod_cast hm
    rw [div_le_iff₀ hmR]
    calc (S.card : ℝ) ^ 2 ≤ (∑ v : V, ((S.filter (fun x => f x = v)).card : ℝ) ^ 2)
          * (Fintype.card V : ℝ) := by linarith [hCS]
      _ = _ := rfl

/-- The pairs of `S` on which `f` agrees, split into diagonal and off-diagonal
contributions: `∑_v c_v² = #{colliding ordered pairs} + n`. -/
theorem sum_fiber_sq_eq (f : K → V) (S : Finset K) :
    ∑ v : V, ((S.filter (fun x => f x = v)).card) ^ 2
      = (S.offDiag.filter (fun q => f q.1 = f q.2)).card + S.card := by
  classical
  have hprod : ((S ×ˢ S).filter (fun q => f q.1 = f q.2)).card
      = ∑ v : V, ((S.filter (fun x => f x = v)).card) ^ 2 := by
    rw [Finset.card_eq_sum_card_fiberwise
      (f := fun q : K × K => f q.1) (s := (S ×ˢ S).filter (fun q => f q.1 = f q.2))
      (t := (Finset.univ : Finset V)) (fun q _ => Finset.mem_univ _)]
    refine Finset.sum_congr rfl fun v _ => ?_
    have hset : (((S ×ˢ S).filter (fun q => f q.1 = f q.2)).filter (fun q => f q.1 = v))
        = (S.filter (fun x => f x = v)) ×ˢ (S.filter (fun x => f x = v)) := by
      ext q
      simp only [Finset.mem_filter, Finset.mem_product]
      constructor
      · rintro ⟨⟨⟨h1, h2⟩, heq⟩, hv⟩
        exact ⟨⟨h1, hv⟩, ⟨h2, heq ▸ hv⟩⟩
      · rintro ⟨⟨h1, hv1⟩, ⟨h2, hv2⟩⟩
        exact ⟨⟨⟨h1, h2⟩, hv1.trans hv2.symm⟩, hv1⟩
    rw [hset, Finset.card_product, sq]
  rw [← hprod, ← Finset.diag_union_offDiag S, Finset.filter_union]
  have hdiag : (S.diag.filter (fun q => f q.1 = f q.2)) = S.diag := by
    refine Finset.filter_true_of_mem fun q hq => ?_
    rw [Finset.mem_diag] at hq
    rw [hq.2]
  rw [hdiag, Finset.card_union_of_disjoint, Finset.diag_card, add_comm]
  exact Finset.disjoint_left.mpr fun q hq hq' =>
    (Finset.mem_offDiag.mp (Finset.mem_filter.mp hq').1).2.2 (Finset.mem_diag.mp hq).2

/-- **Absolute pigeonhole bound.**  Any single hash function collides on at
least `n²/m - n` ordered pairs of `n` keys.  No family, universal or not, can
do better on average. -/
theorem collisionCount_ge_pigeonhole (f : K → V) (S : Finset K) :
    (S.card : ℝ) ^ 2 / (Fintype.card V : ℝ) - S.card ≤
      ((S.offDiag.filter (fun q => f q.1 = f q.2)).card : ℝ) := by
  have h1 := fiber_sq_lower_bound f S
  have h2 : ∑ v : V, (((S.filter (fun x => f x = v)).card : ℝ)) ^ 2
      = ((S.offDiag.filter (fun q => f q.1 = f q.2)).card : ℝ) + S.card := by
    have := sum_fiber_sq_eq f S
    have hcast : ((∑ v : V, ((S.filter (fun x => f x = v)).card) ^ 2 : ℕ) : ℝ)
        = ∑ v : V, (((S.filter (fun x => f x = v)).card : ℝ)) ^ 2 := by push_cast; ring
    rw [← hcast, this]
    push_cast
    ring
  linarith [h1, h2.symm.le, h2.le]

omit [Fintype V] in
/-- **First moment of an arbitrary family.**  For every family of hash
functions and every law on its index set, the expected number of colliding
ordered pairs is at least `n²/m - n`. -/
theorem exp_collisionCount_ge_of_any_family [Fintype V] (L : FinLaw Ω) (h : Ω → K → V)
    (S : Finset K) :
    (S.card : ℝ) ^ 2 / (Fintype.card V : ℝ) - S.card ≤ L.exp (collisionCount h S) := by
  have hpoint : ∀ o, ((S.card : ℝ) ^ 2 / (Fintype.card V : ℝ) - S.card)
      ≤ collisionCount h S o := fun o => collisionCount_ge_pigeonhole (h o) S
  have := FinLaw.exp_mono (L := L)
    (f := fun _ => (S.card : ℝ) ^ 2 / (Fintype.card V : ℝ) - S.card)
    (g := collisionCount h S) hpoint
  rwa [FinLaw.exp_const] at this

omit [DecidableEq K] in
/-- **`2`-universality is first-moment optimal up to an additive `n`.**  The
expected collision count of an exactly `2`-universal family exceeds the
absolute pigeonhole minimum by exactly `n(1 - 1/m)`, hence by less than the
number of keys. -/
theorem two_universal_first_moment_near_optimal {L : FinLaw Ω} {h : Ω → K → V} {S : Finset K}
    (hu : Exactly2Universal L h S) :
    L.exp (collisionCount h S) -
        ((S.card : ℝ) ^ 2 / (Fintype.card V : ℝ) - S.card)
      = (S.card : ℝ) * (1 - 1 / (Fintype.card V : ℝ)) := by
  rw [exp_collisionCount hu, Finset.offDiag_card]
  rcases Nat.eq_zero_or_pos (Fintype.card V) with hm | hm
  · rw [hm]
    simp
  · have hmR : (0 : ℝ) ≠ Fintype.card V := by
      have : (0 : ℝ) < Fintype.card V := by exact_mod_cast hm
      exact ne_of_lt this
    have hle : S.card ≤ S.card * S.card := by
      rcases Nat.eq_zero_or_pos S.card with hz | hz
      · simp [hz]
      · exact Nat.le_mul_of_pos_left _ hz
    have hcast : ((S.card * S.card - S.card : ℕ) : ℝ)
        = (S.card : ℝ) * S.card - S.card := by
      push_cast [Nat.cast_sub hle]; ring
    rw [hcast]
    field_simp
    ring

/-! ### Exactness is necessary: the Carter–Wegman dichotomy -/

omit [DecidableEq V] in
/-- For `n ≤ m` there is a (one-element, deterministic) family that is
Carter–Wegman `2`-universal on `S` and never collides: the inequality-only
axiom `P(h x = h y) ≤ 1/m` admits collision probability `0`. -/
theorem exists_injective_sub2Universal {S : Finset K} (hS : 2 ≤ S.card)
    (hcard : S.card ≤ Fintype.card V) :
    ∃ (Ω' : Type) (_ : Fintype Ω') (L : FinLaw Ω') (h : Ω' → K → V),
      Sub2Universal L h S ∧ L.prob (Collides h S) = 0 := by
  classical
  have hVpos : 0 < Fintype.card V := lt_of_lt_of_le (by omega) hcard
  have hVne : Nonempty V := Fintype.card_pos_iff.mp hVpos
  have hemb : Nonempty ({x // x ∈ S} ↪ V) := by
    refine Function.Embedding.nonempty_of_card_le ?_
    simpa using hcard
  obtain ⟨e⟩ := hemb
  classical
  let f : K → V := fun k => if hk : k ∈ S then e ⟨k, hk⟩ else Classical.arbitrary V
  have hinj : ∀ x ∈ S, ∀ y ∈ S, f x = f y → x = y := by
    intro x hx y hy hfe
    simp only [f, dif_pos hx, dif_pos hy] at hfe
    exact congrArg Subtype.val (e.injective hfe)
  refine ⟨Unit, inferInstance, ⟨fun _ => 1, fun _ => zero_le_one, by simp⟩, fun _ => f, ?_, ?_⟩
  · intro x hx y hy hne
    have hzero : (⟨fun _ => 1, fun _ => zero_le_one, by simp⟩ : FinLaw Unit).prob
        (fun _ : Unit => f x = f y) = 0 := by
      refine FinLaw.prob_eq_zero_of_forall_not fun o hfe => hne (hinj x hx y hy hfe)
    rw [hzero]
    positivity
  · refine FinLaw.prob_eq_zero_of_forall_not fun o hcol => ?_
    obtain ⟨x, hx, y, hy, hne, heq⟩ := hcol
    exact hne (hinj x hx y hy heq)

omit [DecidableEq V] in
/-- **Carter–Wegman dichotomy.**  Under the inequality-only `2`-universality
axiom the extremal collision probability is `0` for `n ≤ m` and `1` for
`n > m`: no intermediate value, and in particular no `1/m` lower bound.  The
`1/m` of the main theorem is a consequence of *exact* `2`-universality. -/
theorem sub2Universal_dichotomy {S : Finset K} (hS : 2 ≤ S.card) :
    (S.card ≤ Fintype.card V →
        ∃ (Ω' : Type) (_ : Fintype Ω') (L : FinLaw Ω') (h : Ω' → K → V),
          Sub2Universal L h S ∧ L.prob (Collides h S) = 0) ∧
      (Fintype.card V < S.card →
        ∀ (L : FinLaw Ω) (h : Ω → K → V), L.prob (Collides h S) = 1) :=
  ⟨fun hle => exists_injective_sub2Universal hS hle,
    fun hlt L h => collisionProb_eq_one_of_card_lt L h hlt⟩

end UnionBoundConverse