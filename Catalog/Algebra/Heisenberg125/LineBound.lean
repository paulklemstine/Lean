/-
# The line bound: `d(H_{p^3}) ≤ 2p² - 2`

Every element of `H_{p^3}` has a *direction*: the point of the projective line
`P^1(F_p)` determined by its image `(a, b)` in `(ZMod p)^2` (with the convention
`dirOf (0, b, c) = none`, the vertical direction).  There are exactly `p + 1`
directions.

Elements sharing a direction generate an **abelian** subgroup (their commutator
is trivial because the corresponding determinant vanishes), and on that subgroup
product-one-freeness is equivalent to zero-sum-freeness in `C_p ⊕ C_p`, once one
straightens the `2`-cocycle by the substitution
`c ↦ c - (m / 2) a²` (legitimate because `p` is odd).  The Chevalley–Warning
bound `D(C_p ⊕ C_p) ≤ 2p - 1` of `Algebra.Heisenberg125.ZeroSumTwoDim` therefore
caps each direction class at `2p - 2` entries, and summing over the `p + 1`
directions gives

  `d(H_{p^3}) ≤ (p + 1)(2p - 2) = 2p² - 2`,

in particular `d(H_125) ≤ 48`.  (The true value, according to the paper under
study, is `12`; its upper bound rests on an exhaustive machine search that is
not reproduced here.  Everything in this development is proof-checked.)
-/
import Algebra.Heisenberg125.CosetBound
import Algebra.Heisenberg125.ZeroSumTwoDim

namespace Heisenberg125

namespace Heis

variable {p : ℕ}

/-- Sum of the squares of the first coordinates. -/
def sqsum (L : List (Heis p)) : ZMod p := (L.map (fun g => g.a ^ 2)).sum

@[simp] lemma sqsum_nil : sqsum ([] : List (Heis p)) = 0 := rfl
@[simp] lemma sqsum_cons (g : Heis p) (L) : sqsum (g :: L) = g.a ^ 2 + sqsum L := rfl

/-- On a list of elements lying on the line `b = m a`, the `b`-sum is `m` times
the `a`-sum. -/
lemma bsum_eq_mul_asum {m : ZMod p} {L : List (Heis p)} (h : ∀ g ∈ L, g.b = m * g.a) :
    bsum L = m * asum L := by
  induction L with
  | nil => simp
  | cons g L ih =>
      rw [bsum_cons, asum_cons, h g (by simp), ih fun t ht => h t (by simp [ht])]
      ring

/-- **Straightening the cocycle.**  On a list of elements lying on the line
`b = m a`, the cross sum is determined by the `a`-sum and the sum of squares:
`2 Σ_{i<j} a_i a_j m = m ((Σ a)² - Σ a²)`. -/
lemma two_mul_crossSum {m : ZMod p} {L : List (Heis p)} (h : ∀ g ∈ L, g.b = m * g.a) :
    2 * crossSum L = m * ((asum L) ^ 2 - sqsum L) := by
  induction L with
  | nil => simp
  | cons g L ih =>
      have hL : ∀ t ∈ L, t.b = m * t.a := fun t ht => h t (by simp [ht])
      rw [crossSum_cons, bsum_eq_mul_asum hL, asum_cons, sqsum_cons]
      linear_combination ih hL

/-! ### Directions -/

section Prime

variable [Fact p.Prime]

/-- The direction of an element of `H_{p^3}`: a point of the projective line
`P^1(F_p)`, encoded as `Option (ZMod p)` (`none` is the vertical direction). -/
def dirOf (g : Heis p) : Option (ZMod p) := if g.a = 0 then none else some (g.b / g.a)

/-- First coordinate of the linearising chart attached to a direction. -/
def coord1 (d : Option (ZMod p)) (g : Heis p) : ZMod p :=
  match d with
  | none => g.b
  | some _ => g.a

/-- Second coordinate of the linearising chart attached to a direction: the
central coordinate corrected by the quadratic term `(m/2) a²`. -/
noncomputable def coord2 (d : Option (ZMod p)) (g : Heis p) : ZMod p :=
  match d with
  | none => g.c
  | some m => g.c - m * (2 : ZMod p)⁻¹ * g.a ^ 2

omit [Fact p.Prime] in
@[simp] lemma sum_coord1_none (L : List (Heis p)) :
    (L.map (coord1 (p := p) none)).sum = bsum L := rfl

omit [Fact p.Prime] in
@[simp] lemma sum_coord1_some (m : ZMod p) (L : List (Heis p)) :
    (L.map (coord1 (some m))).sum = asum L := rfl

@[simp] lemma sum_coord2_none (L : List (Heis p)) :
    (L.map (coord2 (p := p) none)).sum = csum L := rfl

lemma sum_coord2_some (m : ZMod p) (L : List (Heis p)) :
    (L.map (coord2 (some m))).sum = csum L - m * (2 : ZMod p)⁻¹ * sqsum L := by
  induction L with
  | nil => simp [csum, sqsum]
  | cons g L ih =>
      rw [List.map_cons, List.sum_cons, ih]
      simp only [coord2, csum_cons, sqsum_cons]
      ring

lemma two_ne_zero_of_odd (hodd : Odd p) : (2 : ZMod p) ≠ 0 := by
  intro h
  have hp := (Fact.out : p.Prime)
  have hcast : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
  have hdvd : p ∣ 2 := (ZMod.natCast_eq_zero_iff _ _).1 hcast
  have hp2 : p = 2 := (Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).1 hdvd
  rw [hp2] at hodd
  simp [Nat.odd_iff] at hodd

/-- Elements of direction `none` have vanishing first coordinate. -/
lemma a_eq_zero_of_dir_none {g : Heis p} (h : dirOf g = none) : g.a = 0 := by
  unfold dirOf at h
  by_cases hga : g.a = 0
  · exact hga
  · simp [hga] at h

/-- Elements of direction `some m` lie on the line `b = m a`. -/
lemma b_eq_mul_of_dir_some {g : Heis p} {m : ZMod p} (h : dirOf g = some m) :
    g.b = m * g.a := by
  unfold dirOf at h
  by_cases hga : g.a = 0
  · simp [hga] at h
  · simp only [hga, if_false, Option.some.injEq] at h
    rw [← h, div_mul_cancel₀ _ hga]

/-- **Product-one criterion inside a direction class.**  If all entries of `T`
have the same direction and both chart coordinates sum to zero, then `T` has
product one (in the given order, indeed in every order). -/
theorem prod_eq_one_of_chart_zeroSum (hodd : Odd p)
    {d : Option (ZMod p)} {T : List (Heis p)} (hdir : ∀ g ∈ T, dirOf g = d)
    (h1 : (T.map (coord1 d)).sum = 0) (h2 : (T.map (coord2 d)).sum = 0) :
    T.prod = 1 := by
  cases d with
  | none =>
      have hazero : ∀ g ∈ T, g.a = 0 := fun g hg => a_eq_zero_of_dir_none (hdir g hg)
      rw [prod_eq_one_iff]
      refine ⟨?_, ?_, ?_⟩
      · rw [asum_of_const (α := 0) hazero]; ring
      · rw [← sum_coord1_none]; exact h1
      · rw [crossSum_eq_zero_of_a_eq_zero hazero, add_zero, ← sum_coord2_none]; exact h2
  | some m =>
      have hline : ∀ g ∈ T, g.b = m * g.a := fun g hg => b_eq_mul_of_dir_some (hdir g hg)
      have ha : asum T = 0 := by rw [← sum_coord1_some m]; exact h1
      rw [sum_coord2_some] at h2
      have hcross := two_mul_crossSum hline
      rw [ha] at hcross
      have h2ne : (2 : ZMod p) ≠ 0 := two_ne_zero_of_odd hodd
      have hinv : (2 : ZMod p) * (2 : ZMod p)⁻¹ = 1 := mul_inv_cancel₀ h2ne
      rw [prod_eq_one_iff]
      refine ⟨ha, by rw [bsum_eq_mul_asum hline, ha, mul_zero], ?_⟩
      have hcs : csum T = m * (2 : ZMod p)⁻¹ * sqsum T := by linear_combination h2
      have hkey : 2 * (csum T + crossSum T) = 0 := by
        rw [mul_add, hcs, hcross]
        linear_combination (m * sqsum T) * hinv
      rcases mul_eq_zero.1 hkey with h | h
      · exact absurd h h2ne
      · exact h

/-! ### The bound for one direction class -/

/-- At most `2p - 2` entries of a product-one-free sequence can share a
direction. -/
theorem length_le_of_const_dir (hodd : Odd p) {d : Option (ZMod p)}
    {C : List (Heis p)} (hfree : ProductOneFree C) (hdir : ∀ g ∈ C, dirOf g = d) :
    C.length ≤ 2 * p - 2 := by
  by_contra hlen
  push_neg at hlen
  have hp := (Fact.out : p.Prime).two_le
  obtain ⟨T, hTsub, hTne, hT1, hT2⟩ :=
    exists_nonempty_zeroSum_sublist C (coord1 d) (coord2 d) (by omega)
  exact hfree T hTsub hTne
    ⟨T, List.Perm.refl _,
      prod_eq_one_of_chart_zeroSum hodd (fun g hg => hdir g (hTsub.mem hg)) hT1 hT2⟩

/-! ### Summing over the `p + 1` directions -/

/-- Splitting a list according to the fibres of a map to a finite type. -/
lemma length_eq_sum_filter {α β : Type*} [Fintype β] [DecidableEq β] (f : α → β) (L : List α) :
    L.length = ∑ b : β, (L.filter (fun g => decide (f g = b))).length := by
  classical
  induction L with
  | nil => simp
  | cons g L ih =>
      have hstep : ∀ b : β, ((g :: L).filter (fun x => decide (f x = b))).length
          = (if b = f g then 1 else 0) + (L.filter (fun x => decide (f x = b))).length := by
        intro b
        by_cases hb : f g = b
        · subst hb; simp; omega
        · simp [hb, Ne.symm hb]
      rw [Finset.sum_congr rfl fun b _ => hstep b, Finset.sum_add_distrib, ← ih]
      simp
      omega

/-- **Line bound.**  A product-one-free sequence over the odd-exponent
Heisenberg group has length at most `(p + 1)(2p - 2) = 2p² - 2`. -/
theorem length_le_of_productOneFree (hodd : Odd p) {L : List (Heis p)}
    (hfree : ProductOneFree L) : L.length ≤ (p + 1) * (2 * p - 2) := by
  classical
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  have hsplit := length_eq_sum_filter (dirOf (p := p)) L
  have hbound : ∀ d : Option (ZMod p),
      (L.filter (fun g => decide (dirOf g = d))).length ≤ 2 * p - 2 := by
    intro d
    refine length_le_of_const_dir (d := d) hodd (hfree.sublist List.filter_sublist) ?_
    intro g hg
    have := List.of_mem_filter hg
    simpa using this
  calc L.length = ∑ d : Option (ZMod p), (L.filter (fun g => decide (dirOf g = d))).length :=
        hsplit
    _ ≤ ∑ _d : Option (ZMod p), (2 * p - 2) := Finset.sum_le_sum fun d _ => hbound d
    _ = (p + 1) * (2 * p - 2) := by
        simp [Finset.sum_const, Fintype.card_option, ZMod.card, mul_comm]

end Prime

end Heis

open Heis

/-- **Upper bound for the small Davenport constant of `H_{p^3}`,
`p` an odd prime:** `d(H_{p^3}) ≤ 2p² - 2`. -/
theorem smallDavenport_le_two_p_sq_sub_two {p : ℕ} [Fact p.Prime] (hodd : Odd p) :
    smallDavenport (Heis p) ≤ (p + 1) * (2 * p - 2) := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  refine csSup_le ⟨0, ⟨[], rfl, productOneFree_nil⟩⟩ ?_
  rintro n ⟨L, rfl, hL⟩
  exact length_le_of_productOneFree hodd hL

/-- For `p = 5`: `d(H_125) ≤ 48`. -/
theorem smallDavenport_heis_five_le_48 : smallDavenport (Heis 5) ≤ 48 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have := smallDavenport_le_two_p_sq_sub_two (p := 5) (by decide)
  simpa using this

/-- The two-sided bound proved here for the Heisenberg group of order `125`:
`12 ≤ d(H_125) ≤ 48`. -/
theorem smallDavenport_heis_five_bounds :
    12 ≤ smallDavenport (Heis 5) ∧ smallDavenport (Heis 5) ≤ 48 :=
  ⟨twelve_le_smallDavenport_heis_five, smallDavenport_heis_five_le_48⟩

end Heisenberg125