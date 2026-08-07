/-
# A spread bound: `2·d(H_{p^3}) + p + 2 ≤ 3p²`

`Algebra.Heisenberg125.RefinedBound` bounds a product-one-free sequence over
`Heis p` by `2p(p-1)` by showing that at most `p - 1` of the `p + 1` direction
classes can be large.  Here we do substantially better by *combining* the two
extraction mechanisms available to us:

* **line extraction** — a direction class of size `≥ p` contains a nonempty
  block of size `≤ p` with central product (pigeonhole on the chart of
  `LineBound`);
* **plane extraction** — *any* `2p - 1` elements contain a nonempty subsequence
  with central product (Chevalley–Warning, `ZeroSumTwoDim`), since
  `D(F_p^2) = 2p - 1`.

A product-one-free sequence cannot contain `p` pairwise disjoint nonempty
blocks with central product (`BlockCriterion`).  Peeling off line blocks until
every direction class is small leaves a remainder of length at most `p² - 1`,
from which plane extraction still produces `⌊r/(2p-1)⌋` further blocks.  The
resulting optimisation gives

  `2·|L| + p + 2 ≤ 3p²`,  i.e.  `d(H_{p^3}) ≤ (3p² - p - 2)/2`.

For `p = 2` this reads `d(H_8) ≤ 4`, which is **sharp** (see
`Algebra.Heisenberg125.PrimeTwoAnomaly`); for `p = 3` it gives `11`, and for
`p = 5` it gives `d(H_125) ≤ 34`.
-/
import Algebra.Heisenberg125.RefinedBound
import Algebra.Heisenberg125.ZeroSumTwoDim
import Algebra.Heisenberg125.PrimeTwoAnomaly

namespace Heisenberg125

namespace Heis

variable {p : ℕ}

/-! ### A generic greedy extraction of disjoint blocks -/

/-- Appending a common prefix preserves the sub-multiset relation. -/
lemma subperm_append_left_of {α : Type*} (l : List α) {a b : List α} (h : a.Subperm b) :
    (l ++ a).Subperm (l ++ b) := by
  rw [← Multiset.coe_le] at h
  rw [← Multiset.coe_le, ← Multiset.coe_add, ← Multiset.coe_add]
  exact add_le_add le_rfl h

/-- **Greedy extraction.**  If every list of length exactly `D` contains a
nonempty sublist with property `P`, then every list of length at least `k * D`
contains `k` pairwise disjoint nonempty sublists with property `P` (disjointness
being recorded as: their concatenation is a sub-multiset of the list). -/
lemma exists_disjoint_blocks {α : Type*} (P : List α → Prop) (D : ℕ)
    (hex : ∀ M : List α, M.length = D → ∃ B : List α, B.Sublist M ∧ B ≠ [] ∧ P B) :
    ∀ (k : ℕ) (M : List α), k * D ≤ M.length →
      ∃ Bs : List (List α), Bs.length = k ∧ (∀ B ∈ Bs, B ≠ [] ∧ P B) ∧
        Bs.flatten.Subperm M := by
  intro k
  induction k with
  | zero => exact fun M _ => ⟨[], rfl, by simp, by simp⟩
  | succ k ih =>
      intro M hM
      have hD : D ≤ M.length :=
        le_trans (Nat.le_mul_of_pos_left D (Nat.succ_pos k)) hM
      have htlen : (M.take D).length = D := by
        simp [Nat.min_eq_left hD]
      obtain ⟨B, hBsub, hBne, hBP⟩ := hex (M.take D) htlen
      have hBM : B.Sublist M := hBsub.trans (List.take_sublist _ _)
      have hBlen : B.length ≤ D := le_of_le_of_eq hBsub.length_le htlen
      obtain ⟨M', hM'⟩ := hBM.exists_perm_append
      have hsum : M.length = B.length + M'.length := by
        rw [hM'.length_eq, List.length_append]
      have hlen' : k * D ≤ M'.length := by
        have h1 : k * D + D ≤ M.length := by rw [← Nat.succ_mul]; exact hM
        omega
      obtain ⟨Bs, hBslen, hBsprop, hBssub⟩ := ih M' hlen'
      refine ⟨B :: Bs, by simp [hBslen], ?_, ?_⟩
      · intro B' hB'
        rcases List.mem_cons.1 hB' with rfl | h
        · exact ⟨hBne, hBP⟩
        · exact hBsprop B' h
      · rw [List.flatten_cons]
        exact (subperm_append_left_of B hBssub).trans hM'.symm.subperm

section Prime

variable [Fact p.Prime]

/-! ### Plane extraction: `2p - 1` elements always contain a central block -/

/-- Any `2p - 1` elements of `Heis p` contain a nonempty subsequence whose
product is central.  This is the Davenport constant `D(F_p^2) = 2p - 1`,
obtained from Chevalley–Warning. -/
lemma exists_central_block_of_length (M : List (Heis p)) (hM : M.length = 2 * p - 1) :
    ∃ B : List (Heis p), B.Sublist M ∧ B ≠ [] ∧ (B.prod).a = 0 ∧ (B.prod).b = 0 := by
  obtain ⟨T, hTsub, hTne, hTa, hTb⟩ :=
    exists_nonempty_zeroSum_sublist M Heis.a Heis.b (le_of_eq hM.symm)
  exact ⟨T, hTsub, hTne, by rw [prod_eq]; exact hTa, by rw [prod_eq]; exact hTb⟩

/-! ### Disjoint central blocks are limited by product-one-freeness -/

/-- A product-one-free sequence over `Heis p` admits fewer than `p` pairwise
disjoint nonempty blocks with central product. -/
theorem card_disjoint_central_blocks_lt {L : List (Heis p)} (hfree : ProductOneFree L)
    {Bs : List (List (Heis p))} (hne : ∀ B ∈ Bs, B ≠ [])
    (hcen : ∀ B ∈ Bs, (B.prod).a = 0 ∧ (B.prod).b = 0)
    (hsub : Bs.flatten.Subperm L) : Bs.length < p := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  by_contra hlen
  push_neg at hlen
  obtain ⟨T, hTsub, hTne, hTprod⟩ := exists_productOne_of_central_blocks hne hcen hlen
  exact ProductOneFree.subperm hfree (hTsub.subperm.trans hsub) hTne
    ⟨T, List.Perm.refl _, hTprod⟩

/-! ### Phase one: peel off line blocks -/

/-- **Line peeling.**  Every sequence over `Heis p` splits (up to reordering)
into a family of nonempty blocks of size at most `p` with central product,
together with a remainder all of whose direction classes have size at most
`p - 1`. -/
lemma exists_line_blocks_and_small_remainder :
    ∀ (n : ℕ) (L : List (Heis p)), L.length ≤ n →
      ∃ (Bs : List (List (Heis p))) (R : List (Heis p)),
        (Bs.flatten ++ R).Perm L ∧
        (∀ B ∈ Bs, B ≠ [] ∧ B.length ≤ p ∧ (B.prod).a = 0 ∧ (B.prod).b = 0) ∧
        (∀ d : Option (ZMod p),
          (R.filter (fun g => decide (dirOf g = d))).length < p) := by
  classical
  intro n
  induction n with
  | zero =>
      intro L hL
      have hnil : L = [] := List.eq_nil_of_length_eq_zero (Nat.le_zero.1 hL)
      subst hnil
      exact ⟨[], [], by simp, by simp, fun d => by
        simpa using (Fact.out : p.Prime).pos⟩
  | succ n ih =>
      intro L hL
      by_cases hsmall : ∀ d : Option (ZMod p),
          (L.filter (fun g => decide (dirOf g = d))).length < p
      · exact ⟨[], L, by simp, by simp, hsmall⟩
      · push_neg at hsmall
        obtain ⟨d, hd⟩ := hsmall
        set C : List (Heis p) := L.filter (fun g => decide (dirOf g = d)) with hC
        have hCdir : ∀ g ∈ C, dirOf g = d := by
          intro g hg
          simpa [hC] using List.of_mem_filter hg
        have htlen : (C.take p).length = p := by
          simp [Nat.min_eq_left hd]
        obtain ⟨B, hBsub, hBne, hBa, hBb⟩ :=
          exists_central_block_of_dir (C := C.take p)
            (fun g hg => hCdir g ((List.take_sublist _ _).mem hg)) (le_of_eq htlen.symm)
        have hBlen : B.length ≤ p := le_of_le_of_eq hBsub.length_le htlen
        have hCL : C.Sublist L := by rw [hC]; exact List.filter_sublist
        have hBL : B.Sublist L :=
          (hBsub.trans (List.take_sublist _ _)).trans hCL
        obtain ⟨L', hL'⟩ := hBL.exists_perm_append
        have hBpos : 0 < B.length := List.length_pos_iff.2 hBne
        have hlen' : L'.length ≤ n := by
          have := hL'.length_eq
          rw [List.length_append] at this
          omega
        obtain ⟨Bs, R, hperm, hprop, hR⟩ := ih L' hlen'
        refine ⟨B :: Bs, R, ?_, ?_, hR⟩
        · have hassoc : ((B :: Bs).flatten ++ R) = B ++ (Bs.flatten ++ R) := by
            rw [List.flatten_cons, List.append_assoc]
          rw [hassoc]
          exact (hperm.append_left B).trans hL'.symm
        · intro B' hB'
          rcases List.mem_cons.1 hB' with rfl | h
          · exact ⟨hBne, hBlen, hBa, hBb⟩
          · exact hprop B' h

/-! ### The spread bound -/

/-- **Spread bound.**  For every prime `p`, a product-one-free sequence `L`
over the Heisenberg group `Heis p` satisfies `2·|L| + p + 2 ≤ 3p²`.

For `p = 2` this is sharp (`d(H_8) = 4`); for `p = 5` it gives
`d(H_125) ≤ 34`, improving the bounds `48` of `LineBound` and `40` of
`RefinedBound`. -/
theorem two_mul_length_add_le {L : List (Heis p)} (hfree : ProductOneFree L) :
    2 * L.length + p + 2 ≤ 3 * p ^ 2 := by
  classical
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  have hp2 : 2 ≤ p := (Fact.out : p.Prime).two_le
  obtain ⟨q, rfl⟩ : ∃ q, p = q + 1 := ⟨p - 1, by omega⟩
  obtain ⟨Bs, R, hperm, hprop, hR⟩ :=
    exists_line_blocks_and_small_remainder L.length L le_rfl
  set k : ℕ := Bs.length with hk
  set r : ℕ := R.length with hr
  -- the remainder is short: every direction class of `R` has size at most `q`
  have hrle : r ≤ (q + 2) * q := by
    have hsplit := length_eq_sum_filter (dirOf (p := q + 1)) R
    have hcard : (Finset.univ : Finset (Option (ZMod (q + 1)))).card = q + 2 := by
      simp [ZMod.card]
    calc r = ∑ d : Option (ZMod (q + 1)),
              (R.filter (fun g => decide (dirOf g = d))).length := hsplit
      _ ≤ ∑ _d : Option (ZMod (q + 1)), q :=
          Finset.sum_le_sum fun d _ => by have := hR d; omega
      _ = (q + 2) * q := by rw [Finset.sum_const, hcard, smul_eq_mul]
  -- the length is controlled by the blocks and the remainder
  have hflatlen : Bs.flatten.length ≤ (q + 1) * k := by
    have hall : ∀ x ∈ Bs.map List.length, x ≤ q + 1 := by
      intro x hx
      obtain ⟨B, hB, rfl⟩ := List.mem_map.1 hx
      exact (hprop B hB).2.1
    have hsum := List.sum_le_card_nsmul (Bs.map List.length) (q + 1) hall
    simpa [List.length_flatten, hk, mul_comm] using hsum
  have hlen : L.length ≤ (q + 1) * k + r := by
    have := hperm.length_eq
    rw [List.length_append] at this
    omega
  -- phase two: extract further blocks from the remainder
  set m : ℕ := r / (2 * q + 1) with hm
  obtain ⟨Bs2, hBs2len, hBs2prop, hBs2sub⟩ :=
    exists_disjoint_blocks (fun B : List (Heis (q + 1)) => (B.prod).a = 0 ∧ (B.prod).b = 0)
      (2 * q + 1) (fun M hM => exists_central_block_of_length M (by omega)) m R
      (by simpa [hm, hr] using Nat.div_mul_le_self R.length (2 * q + 1))
  -- all blocks together are pairwise disjoint inside `L`
  have hallsub : (Bs ++ Bs2).flatten.Subperm L := by
    rw [List.flatten_append]
    exact (subperm_append_left_of Bs.flatten hBs2sub).trans hperm.subperm
  have hcount : k + m < q + 1 := by
    have := card_disjoint_central_blocks_lt hfree (Bs := Bs ++ Bs2)
      (fun B hB => by
        rcases List.mem_append.1 hB with h | h
        · exact (hprop B h).1
        · exact (hBs2prop B h).1)
      (fun B hB => by
        rcases List.mem_append.1 hB with h | h
        · exact ⟨(hprop B h).2.2.1, (hprop B h).2.2.2⟩
        · exact (hBs2prop B h).2)
      hallsub
    simpa [hk, hBs2len] using this
  -- the arithmetic optimisation
  have hgoal : 2 * L.length ≤ 3 * q ^ 2 + 5 * q := by
    by_cases hcase : 2 * k ≤ q
    · nlinarith [hlen, hrle, hcase]
    · push_neg at hcase
      have hdec : (2 * q + 1) * m + r % (2 * q + 1) = r := Nat.div_add_mod r (2 * q + 1)
      have hmod : r % (2 * q + 1) ≤ 2 * q := by
        have := Nat.mod_lt r (show 0 < 2 * q + 1 by omega)
        omega
      have hkm : k + m ≤ q := by omega
      nlinarith [hlen, hdec, hmod, hkm, hcase]
  nlinarith [hgoal]

/-- `d(H_{p^3}) ≤ (3p² - p - 2)/2` for every prime `p`. -/
theorem smallDavenport_le_spread (p : ℕ) [Fact p.Prime] :
    smallDavenport (Heis p) ≤ (3 * p ^ 2 - p - 2) / 2 := by
  have key : ∀ A n pp : ℕ, 2 * n + pp + 2 ≤ A → n ≤ (A - pp - 2) / 2 := by
    intro A n pp h; omega
  refine csSup_le ⟨0, ⟨[], rfl, productOneFree_nil⟩⟩ ?_
  rintro n ⟨L, rfl, hL⟩
  exact key _ _ _ (two_mul_length_add_le hL)

end Prime

end Heis

open Heis

/-- For the Heisenberg group of order `125`: `d(H_125) ≤ 34`. -/
theorem smallDavenport_heis_five_le_34 : smallDavenport (Heis 5) ≤ 34 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have := smallDavenport_le_spread 5
  norm_num at this
  exact this

/-- The sharpest two-sided bound obtained here for the Heisenberg group of
order `125`: `12 ≤ d(H_125) ≤ 34`. -/
theorem smallDavenport_heis_five_spread_bounds :
    12 ≤ smallDavenport (Heis 5) ∧ smallDavenport (Heis 5) ≤ 34 :=
  ⟨twelve_le_smallDavenport_heis_five, smallDavenport_heis_five_le_34⟩

/-- For the Heisenberg group of order `27`: `d(H_27) ≤ 11`. -/
theorem smallDavenport_heis_three_le_11 : smallDavenport (Heis 3) ≤ 11 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  have := smallDavenport_le_spread 3
  norm_num at this
  exact this

/-- For `p = 2` the spread bound is **sharp**: combined with the explicit
product-one-free sequence of `PrimeTwoAnomaly` it evaluates `d(H_8) = 4`. -/
theorem smallDavenport_heis_two_eq_four : smallDavenport (Heis 2) = 4 := by
  haveI : Fact (Nat.Prime 2) := ⟨by norm_num⟩
  have hub := smallDavenport_le_spread 2
  norm_num at hub
  exact le_antisymm hub four_le_smallDavenport_heis_two

end Heisenberg125