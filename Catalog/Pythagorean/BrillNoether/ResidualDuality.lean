/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.BrillNoether.Divisors
import Pythagorean.BrillNoether.HalfCanonicalRegular

/-!
# The residual involution at the half-canonical degree

`Divisors.lean` provides the Baker–Norine rank *inequality* `RankAtLeast G D r`.
Here we package it into an honest integer-valued rank function `rankBN` (with the
usual convention `rankBN D = -1` when `D` is not equivalent to an effective
divisor) and study the *residual involution* `D ↦ K - D` on divisors of the
half-canonical degree `g - 1`.

## Main definitions

* `rankBN` — the Baker–Norine rank as an element of `ℤ`, characterised by
  `rankBN_ge_iff : (r : ℤ) ≤ rankBN G D ↔ RankAtLeast G D r`.
* `residual` — the residual divisor `K - D`.
* `SatisfiesRR` — the Baker–Norine Riemann–Roch identity
  `r(D) - r(K - D) = deg D - g + 1`, as a hypothesis on `G`.
* `IsThetaChar` — a *theta characteristic*: a divisor with `2D ∼ K`.

## Main results

* `deg_residual_halfCanonical`, `residual_residual` — the residual map is an
  involution preserving the half-canonical degree `g - 1`.  This part is
  unconditional.
* `rankBN_residual_of_halfCanonical` — under Riemann–Roch, `r(K - D) = r(D)` at
  degree `g - 1`; hence `residual_preserves_witnesses`: the involution preserves
  the set of half-canonical divisors of rank at least `r`.  This is the
  formalised content of the *residual pairing of extremal witnesses* conjecture.
* `linEquiv_residual_iff_thetaChar` — the classes fixed by the involution are
  exactly the theta characteristics, and `rankBN_residual_of_thetaChar` shows that
  for those the rank identity holds with no Riemann–Roch hypothesis at all.
* `exists_thetaChar_regular_even` — on an even-degree regular graph the constant
  divisor `(k-2)/2` is an explicit fixed class of the involution, of degree
  `g - 1` and of rank at least `k - 2`.
-/

open Finset

namespace BrillNoetherResidual

open BrillNoetherDivisor BrillNoetherHalfCanonical

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ## The integer-valued Baker–Norine rank -/

open Classical in
/-- The Baker–Norine rank of a divisor, as an integer: the largest `r` with
`RankAtLeast G D r`, and `-1` when `D` is not equivalent to an effective
divisor. -/
noncomputable def rankBN (D : Divisor V) : ℤ :=
  if RankAtLeast G D 0 then (Nat.findGreatest (fun r => RankAtLeast G D r) (deg D).toNat : ℤ)
  else -1

/-- The rank is always at least `-1`. -/
theorem neg_one_le_rankBN (D : Divisor V) : -1 ≤ rankBN G D := by
  classical
  unfold rankBN
  split_ifs with _
  · have : (0 : ℤ) ≤ ((Nat.findGreatest (fun r => RankAtLeast G D r) (deg D).toNat : ℕ) : ℤ) :=
      Int.natCast_nonneg _
    omega
  · exact le_rfl

/-- **The defining property of `rankBN`.** -/
theorem rankBN_ge_iff [Nonempty V] (D : Divisor V) (r : ℕ) :
    (r : ℤ) ≤ rankBN G D ↔ RankAtLeast G D r := by
  classical
  constructor
  · intro h
    unfold rankBN at h
    split_ifs at h with h0
    · have hr : r ≤ Nat.findGreatest (fun r => RankAtLeast G D r) (deg D).toNat := by
        exact_mod_cast h
      have hspec : RankAtLeast G D (Nat.findGreatest (fun r => RankAtLeast G D r) (deg D).toNat) :=
        Nat.findGreatest_spec (Nat.zero_le _) h0
      exact rankAtLeast_antitone G hr hspec
    · have : (0 : ℤ) ≤ (r : ℤ) := Int.natCast_nonneg r
      omega
  · intro h
    have h0 : RankAtLeast G D 0 := rankAtLeast_antitone G (Nat.zero_le r) h
    have hdeg : (r : ℤ) ≤ deg D := deg_ge_of_rankAtLeast G h
    have hle : r ≤ (deg D).toNat := by omega
    have := Nat.le_findGreatest (P := fun r => RankAtLeast G D r) hle h
    unfold rankBN
    rw [if_pos h0]
    exact_mod_cast this

/-- The rank never exceeds the degree (for divisors of nonnegative rank; for the
remaining ones the rank is `-1` by convention while the degree may be smaller). -/
theorem rankBN_le_deg [Nonempty V] {D : Divisor V} (h0 : RankAtLeast G D 0) :
    rankBN G D ≤ deg D := by
  classical
  unfold rankBN
  rw [if_pos h0]
  exact deg_ge_of_rankAtLeast G (Nat.findGreatest_spec (Nat.zero_le _) h0)

/-- Two integers `≥ -1` agreeing on all natural-number lower bounds are equal. -/
private lemma int_eq_of_natCast_le_iff {x y : ℤ} (hx : -1 ≤ x) (hy : -1 ≤ y)
    (h : ∀ r : ℕ, ((r : ℤ) ≤ x ↔ (r : ℤ) ≤ y)) : x = y := by
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hlt
  · have hy0 : 0 ≤ y := by omega
    have := (h y.toNat).mpr (by omega)
    omega
  · have hx0 : 0 ≤ x := by omega
    have := (h x.toNat).mp (by omega)
    omega

/-- `rankBN` is determined by the rank inequalities it satisfies. -/
theorem rankBN_ext [Nonempty V] {D D' : Divisor V}
    (h : ∀ r : ℕ, RankAtLeast G D r ↔ RankAtLeast G D' r) : rankBN G D = rankBN G D' :=
  int_eq_of_natCast_le_iff (neg_one_le_rankBN G D) (neg_one_le_rankBN G D')
    fun r => by rw [rankBN_ge_iff, rankBN_ge_iff, h r]

/-- A characterisation of `rankBN` by the rank inequalities it satisfies. -/
theorem rankBN_eq_of_forall_iff [Nonempty V] {D : Divisor V} {c : ℤ} (hc : -1 ≤ c)
    (h : ∀ r : ℕ, RankAtLeast G D r ↔ (r : ℤ) ≤ c) : rankBN G D = c :=
  int_eq_of_natCast_le_iff (neg_one_le_rankBN G D) hc
    fun r => by rw [rankBN_ge_iff, h r]

/-- The rank is an invariant of the divisor class. -/
theorem rankBN_eq_of_linEquiv [Nonempty V] {D D' : Divisor V} (h : LinEquiv G D D') :
    rankBN G D = rankBN G D' :=
  rankBN_ext G fun _r =>
    ⟨fun hr => rankAtLeast_of_linEquiv G h hr,
      fun hr => rankAtLeast_of_linEquiv G (linEquiv_symm G h) hr⟩

/-! ## The residual involution -/

/-- The residual of a divisor: `K - D`. -/
def residual (D : Divisor V) : Divisor V := canonical G - D

omit [DecidableEq V] in
@[simp] theorem residual_residual (D : Divisor V) : residual G (residual G D) = D := by
  funext v; simp [residual]

omit [DecidableEq V] in
/-- The degree of the residual divisor is `2g - 2 - deg D`. -/
theorem deg_residual (D : Divisor V) : deg (residual G D) = 2 * genus G - 2 - deg D := by
  rw [residual, deg_sub, deg_canonical]

omit [DecidableEq V] in
/-- **The residual map preserves the half-canonical degree.** -/
theorem deg_residual_halfCanonical {D : Divisor V} (h : deg D = genus G - 1) :
    deg (residual G D) = genus G - 1 := by
  rw [deg_residual, h]; ring

/-- **The Baker–Norine Riemann–Roch identity**, as a hypothesis on `G`. -/
def SatisfiesRR : Prop :=
  ∀ D : Divisor V, rankBN G D - rankBN G (residual G D) = deg D - genus G + 1

/-- **Residual rank identity at the half-canonical degree.**  Riemann–Roch forces
the rank of a divisor of degree `g - 1` and the rank of its residual to agree. -/
theorem rankBN_residual_of_halfCanonical (hRR : SatisfiesRR G) {D : Divisor V}
    (h : deg D = genus G - 1) : rankBN G (residual G D) = rankBN G D := by
  have := hRR D
  rw [h] at this
  linarith

/-- **Residual pairing of extremal witnesses.**  Under Riemann–Roch the involution
`D ↦ K - D` maps the set of divisors of degree `g - 1` and rank at least `r` onto
itself. -/
theorem residual_preserves_witnesses [Nonempty V] (hRR : SatisfiesRR G) (r : ℕ)
    (D : Divisor V) (h : deg D = genus G - 1) :
    (deg (residual G D) = genus G - 1 ∧ (RankAtLeast G D r ↔ RankAtLeast G (residual G D) r)) := by
  refine ⟨deg_residual_halfCanonical G h, ?_⟩
  rw [← rankBN_ge_iff, ← rankBN_ge_iff, rankBN_residual_of_halfCanonical G hRR h]

/-! ## Fixed classes: theta characteristics -/

/-- A *theta characteristic* is a divisor `D` with `2D` linearly equivalent to the
canonical divisor. -/
def IsThetaChar (D : Divisor V) : Prop := LinEquiv G (D + D) (canonical G)

/-- **The classes fixed by the residual involution are the theta
characteristics.** -/
theorem linEquiv_residual_iff_thetaChar (D : Divisor V) :
    LinEquiv G D (residual G D) ↔ IsThetaChar G D := by
  constructor
  · rintro ⟨f, hf⟩
    refine ⟨f, ?_⟩
    funext v
    have := congrFun hf v
    simp only [residual, Pi.sub_apply, Pi.add_apply] at this ⊢
    linarith
  · rintro ⟨f, hf⟩
    refine ⟨f, ?_⟩
    funext v
    have := congrFun hf v
    simp only [residual, Pi.sub_apply, Pi.add_apply] at this ⊢
    linarith

/-- A theta characteristic automatically has the half-canonical degree `g - 1`. -/
theorem deg_of_thetaChar {D : Divisor V} (h : IsThetaChar G D) : deg D = genus G - 1 := by
  have h1 : deg (D + D) = deg (canonical G) := deg_eq_of_linEquiv G h
  rw [deg_add, deg_canonical] at h1
  linarith

/-- **Unconditional residual rank identity for fixed classes.**  For a theta
characteristic the rank of `D` and of its residual agree, with no Riemann–Roch
hypothesis: the two divisors are linearly equivalent. -/
theorem rankBN_residual_of_thetaChar [Nonempty V] {D : Divisor V} (h : IsThetaChar G D) :
    rankBN G (residual G D) = rankBN G D :=
  (rankBN_eq_of_linEquiv G ((linEquiv_residual_iff_thetaChar G D).mpr h)).symm

/-- **An explicit fixed class of large rank on an even regular graph.**  If `G` is
`2j`-regular with `j ≥ 2`, the constant divisor with `j - 1` chips at every vertex
is a theta characteristic — a fixed class of the residual involution — of degree
`g - 1` and of Baker–Norine rank at least `2j - 2 = k - 2`. -/
theorem exists_thetaChar_regular_even [Nonempty V] {j : ℕ}
    (hreg : G.IsRegularOfDegree (2 * j)) (hj : 2 ≤ j) :
    ∃ D : Divisor V, IsThetaChar G D ∧ deg D = genus G - 1 ∧
      RankAtLeast G D (2 * j - 2) ∧ LinEquiv G D (residual G D) := by
  classical
  have hth : IsThetaChar G (fun _ => (j : ℤ) - 1) := by
    refine ⟨0, ?_⟩
    funext v
    simp only [canonical, Pi.add_apply, Pi.zero_apply, lap_zero, hreg v]
    push_cast
    ring
  refine ⟨fun _ => (j : ℤ) - 1, hth, deg_of_thetaChar G hth, ?_,
    (linEquiv_residual_iff_thetaChar G _).mpr hth⟩
  have hk : ∀ v, 2 * j ≤ G.degree v := fun v => (hreg v).ge
  have hD : ∀ _v : V, ((j - 1 : ℕ) : ℤ) ≤ ((j : ℤ) - 1) := fun _ => by omega
  have hrank := rankAtLeast_add_of_forall_le G (k := 2 * j) (m := j - 1) (t := j - 1) hk hD
    le_rfl (by omega)
  have heq : (j - 1) + (j - 1) = 2 * j - 2 := by omega
  rwa [heq] at hrank

/-! ## Non-vacuity of the Riemann–Roch hypothesis

The Baker–Norine theorem asserts `SatisfiesRR G` for every connected graph.  We do
not reprove it here, but we check the hypothesis is consistent by verifying it on
the one-vertex graph, where the rank function can be computed outright.
-/

section OneVertex

variable [Nonempty V] [Subsingleton V]

omit [DecidableEq V] [Nonempty V] in
/-- A graph on a single vertex has no edges. -/
lemma edgeFinset_eq_empty_of_subsingleton : G.edgeFinset = ∅ := by
  classical
  rw [Finset.eq_empty_iff_forall_notMem]
  intro e he
  induction e with
  | h u v =>
    rw [SimpleGraph.mem_edgeFinset, SimpleGraph.mem_edgeSet] at he
    exact G.ne_of_adj he (Subsingleton.elim u v)

omit [DecidableEq V] in
/-- The one-vertex graph has genus `0`. -/
lemma genus_eq_zero_of_subsingleton : genus G = 0 := by
  have hcard : Fintype.card V = 1 := Fintype.card_eq_one_iff_nonempty_unique.mpr
    ⟨uniqueOfSubsingleton (Classical.arbitrary V)⟩
  simp [genus, edgeFinset_eq_empty_of_subsingleton G, hcard]

omit [Nonempty V] in
/-- On a one-vertex graph every chip-firing move is trivial. -/
lemma lap_eq_zero_of_subsingleton (f : V → ℤ) : lap G f = 0 := by
  funext v
  rw [lap_apply]
  have hdeg : G.degree v = 0 := by
    classical
    rw [SimpleGraph.degree, Finset.card_eq_zero, Finset.eq_empty_iff_forall_notMem]
    intro u hu
    rw [SimpleGraph.mem_neighborFinset] at hu
    exact G.ne_of_adj hu (Subsingleton.elim v u)
  have hnb : G.neighborFinset v = ∅ := by
    classical
    rwa [← Finset.card_eq_zero, ← SimpleGraph.degree]
  simp [hnb]

/-- On a one-vertex graph, `RankAtLeast G D r` says exactly that `D` has at least
`r` chips. -/
lemma rankAtLeast_iff_of_subsingleton (D : Divisor V) (r : ℕ) :
    RankAtLeast G D r ↔ (r : ℤ) ≤ deg D := by
  classical
  obtain ⟨v₀⟩ := ‹Nonempty V›
  have hdeg : ∀ E : Divisor V, deg E = E v₀ := by
    intro E
    rw [deg]
    rw [Finset.sum_eq_single v₀ (fun b _ hb => absurd (Subsingleton.elim b v₀) hb)
      (fun h => absurd (Finset.mem_univ v₀) h)]
  constructor
  · intro h
    obtain ⟨f, hf⟩ := h (fun _ => (r : ℤ)) (fun _ => Int.natCast_nonneg r) (by rw [hdeg])
    have := hf v₀
    rw [lap_eq_zero_of_subsingleton G f] at this
    simp only [Pi.add_apply, Pi.sub_apply, Pi.zero_apply] at this
    rw [hdeg D]
    linarith
  · intro h E hE hE'
    refine ⟨0, fun v => ?_⟩
    have hv : v = v₀ := Subsingleton.elim v v₀
    subst hv
    rw [lap_zero]
    have h1 : E v = (r : ℤ) := by rw [← hdeg E, hE']
    have h2 : (r : ℤ) ≤ D v := by rw [hdeg D] at h; exact h
    simp only [Pi.add_apply, Pi.sub_apply, Pi.zero_apply]
    linarith

/-- On a one-vertex graph the Baker–Norine rank is `max (-1) (deg D)`. -/
lemma rankBN_eq_of_subsingleton (D : Divisor V) : rankBN G D = max (-1) (deg D) := by
  refine rankBN_eq_of_forall_iff G (le_max_left _ _) fun r => ?_
  rw [rankAtLeast_iff_of_subsingleton]
  have : (0 : ℤ) ≤ (r : ℤ) := Int.natCast_nonneg r
  constructor
  · intro h; exact le_max_of_le_right h
  · intro h; rcases max_cases (-1 : ℤ) (deg D) with ⟨he, _⟩ | ⟨he, _⟩ <;> omega

/-- **The Riemann–Roch hypothesis is satisfiable**: the one-vertex graph satisfies
the Baker–Norine Riemann–Roch identity. -/
theorem satisfiesRR_of_subsingleton : SatisfiesRR G := by
  intro D
  rw [rankBN_eq_of_subsingleton, rankBN_eq_of_subsingleton, genus_eq_zero_of_subsingleton,
    deg_residual, genus_eq_zero_of_subsingleton]
  rcases max_cases (-1 : ℤ) (deg D) with ⟨h1, h1'⟩ | ⟨h1, h1'⟩ <;>
    rcases max_cases (-1 : ℤ) (2 * (0 : ℤ) - 2 - deg D) with ⟨h2, h2'⟩ | ⟨h2, h2'⟩ <;>
      rw [h1, h2] <;> omega

end OneVertex

end BrillNoetherResidual