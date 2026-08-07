/-
# Heavy direction classes: sharpening the class bound

`Algebra.Heisenberg125.ClassBound` excludes four populated direction classes.
Here we exploit the fact that a *single* direction class carrying `2p - 2`
entries already provides both the parallel block `G` of the spread criterion
`Heis.isProductOne_of_parallel_spread` **and** one of the two independent
"steering" blocks used to prescribe the image of the selected subsequence in
`(ZMod p)²`.  Consequently a heavy class (`2p - 2` entries) coexists neither
with a class of `p` entries (`Heis.heavy_pair_exclusion`) nor with a class of
`p - 1` entries together with any third populated class
(`Heis.heavy_triple_exclusion`).

Feeding these two exclusions into the class count improves the bound of
`ClassBound.lean` from `p² + 2p - 3` to `p² + 2p - 5`; for `p = 5` this gives
`d(H_125) ≤ 30`.
-/
import Algebra.Heisenberg125.ClassBound

namespace Heisenberg125

namespace Heis

variable {p : ℕ}

section Prime

variable [Fact p.Prime]

/-! ### Sub-multisets assembled from repeated classes -/

/-- Two blocks from one class and one block from each of two further classes
assemble to a sub-multiset of the whole sequence. -/
lemma subperm_of_split_classes {L : List (Heis p)} {k0 k1 k2 : Option (Option (ZMod p))}
    (h01 : k0 ≠ k1) (h02 : k0 ≠ k2) (h12 : k1 ≠ k2) {A0 A1 A2 A3 : List (Heis p)}
    (hA02 : (A0 ++ A2).Sublist (classList L k0)) (hA1 : A1.Sublist (classList L k1))
    (hA3 : A3.Sublist (classList L k2)) :
    (A0 ++ A1 ++ A2 ++ A3).Subperm L := by
  classical
  set F : Option (Option (ZMod p)) → Multiset (Heis p) :=
    fun k => ((classList L k : List (Heis p)) : Multiset (Heis p)) with hF
  have hsum : ∑ k ∈ ({k0, k1, k2} : Finset (Option (Option (ZMod p)))), F k
      = F k0 + F k1 + F k2 := by
    rw [Finset.sum_insert (by simp [h01, h02]), Finset.sum_insert (by simp [h12]),
      Finset.sum_singleton]
    abel
  have hle : ((A0 ++ A1 ++ A2 ++ A3 : List (Heis p)) : Multiset (Heis p))
      ≤ (L : Multiset (Heis p)) := by
    have hexp : ((A0 ++ A1 ++ A2 ++ A3 : List (Heis p)) : Multiset (Heis p))
        = ((A0 ++ A2 : List (Heis p)) : Multiset (Heis p)) + (A1 : Multiset (Heis p))
          + (A3 : Multiset (Heis p)) := by
      have h : ∀ (l m : List (Heis p)), ((l ++ m : List (Heis p)) : Multiset (Heis p))
          = (l : Multiset (Heis p)) + m := fun _ _ => rfl
      rw [h, h, h, h]
      abel
    rw [hexp]
    calc ((A0 ++ A2 : List (Heis p)) : Multiset (Heis p)) + (A1 : Multiset (Heis p))
          + (A3 : Multiset (Heis p))
        ≤ F k0 + F k1 + F k2 :=
          add_le_add (add_le_add (Multiset.coe_le.2 hA02.subperm) (Multiset.coe_le.2 hA1.subperm))
            (Multiset.coe_le.2 hA3.subperm)
      _ = ∑ k ∈ ({k0, k1, k2} : Finset (Option (Option (ZMod p)))), F k := hsum.symm
      _ ≤ ∑ k : Option (Option (ZMod p)), F k :=
          Finset.sum_le_sum_of_subset (Finset.subset_univ _)
      _ = (L : Multiset (Heis p)) := sum_coe_filter_fiber (dirClass (p := p)) L
  exact Multiset.coe_le.1 hle

/-- Two blocks from each of two distinct classes assemble to a sub-multiset of
the whole sequence. -/
lemma subperm_of_two_split_classes {L : List (Heis p)} {k0 k1 : Option (Option (ZMod p))}
    (h01 : k0 ≠ k1) {A0 A1 A2 A3 : List (Heis p)}
    (hA02 : (A0 ++ A2).Sublist (classList L k0))
    (hA13 : (A1 ++ A3).Sublist (classList L k1)) :
    (A0 ++ A1 ++ A2 ++ A3).Subperm L := by
  classical
  set F : Option (Option (ZMod p)) → Multiset (Heis p) :=
    fun k => ((classList L k : List (Heis p)) : Multiset (Heis p)) with hF
  have hsum : ∑ k ∈ ({k0, k1} : Finset (Option (Option (ZMod p)))), F k = F k0 + F k1 := by
    rw [Finset.sum_insert (by simp [h01]), Finset.sum_singleton]
  have hle : ((A0 ++ A1 ++ A2 ++ A3 : List (Heis p)) : Multiset (Heis p))
      ≤ (L : Multiset (Heis p)) := by
    have hexp : ((A0 ++ A1 ++ A2 ++ A3 : List (Heis p)) : Multiset (Heis p))
        = ((A0 ++ A2 : List (Heis p)) : Multiset (Heis p))
          + ((A1 ++ A3 : List (Heis p)) : Multiset (Heis p)) := by
      have h : ∀ (l m : List (Heis p)), ((l ++ m : List (Heis p)) : Multiset (Heis p))
          = (l : Multiset (Heis p)) + m := fun _ _ => rfl
      rw [h, h, h, h, h]
      abel
    rw [hexp]
    calc ((A0 ++ A2 : List (Heis p)) : Multiset (Heis p))
          + ((A1 ++ A3 : List (Heis p)) : Multiset (Heis p))
        ≤ F k0 + F k1 :=
          add_le_add (Multiset.coe_le.2 hA02.subperm) (Multiset.coe_le.2 hA13.subperm)
      _ = ∑ k ∈ ({k0, k1} : Finset (Option (Option (ZMod p)))), F k := hsum.symm
      _ ≤ ∑ k : Option (Option (ZMod p)), F k :=
          Finset.sum_le_sum_of_subset (Finset.subset_univ _)
      _ = (L : Multiset (Heis p)) := sum_coe_filter_fiber (dirClass (p := p)) L
  exact Multiset.coe_le.1 hle

/-! ### The two heavy-class exclusions -/

/-- **Heavy pair exclusion.**  A product-one-free sequence over `Heis p`
(`p` an odd prime) cannot have one direction carrying `2p - 2` non-central
entries and a second direction carrying `p` of them.

The heavy class supplies the parallel block `G` (its first `p - 1` entries)
*and*, through its remaining `p - 1` entries, all sums along its own line; the
second class supplies the pivot `z` and, through its remaining `p - 1` entries,
all sums along the transversal line.  The two lines span `(ZMod p)²`, so the
image of the selected subsequence can be made to vanish. -/
theorem heavy_pair_exclusion (hodd : Odd p) {L : List (Heis p)} (hfree : ProductOneFree L)
    {d0 dz : Option (ZMod p)} (h0z : d0 ≠ dz)
    (hd0 : 2 * p - 2 ≤ (classList L (some d0)).length)
    (hdz : p ≤ (classList L (some dz)).length) : False := by
  classical
  have hp2 := (Fact.out : p.Prime).two_le
  set C0 : List (Heis p) := classList L (some d0) with hC0
  set G : List (Heis p) := C0.take (p - 1) with hG
  set K : List (Heis p) := C0.drop (p - 1) with hK
  have hGK : G ++ K = C0 := by rw [hG, hK, List.take_append_drop]
  have hGlen : G.length = p - 1 := by
    rw [hG, List.length_take, Nat.min_eq_left (by omega)]
  have hKlen : p - 1 ≤ K.length := by
    rw [hK, List.length_drop]; omega
  have hGmem : ∀ g ∈ G, g ∈ C0 := fun g hg => (List.take_sublist _ _).mem hg
  have hKmem : ∀ g ∈ K, g ∈ C0 := fun g hg => (List.drop_sublist _ _).mem hg
  -- the pivot and the transversal block
  have hne : classList L (some dz) ≠ [] := by
    intro hnil
    rw [hnil] at hdz
    simp at hdz
    omega
  obtain ⟨z, Lz, hz⟩ := List.exists_cons_of_ne_nil hne
  have hzmem : z ∈ classList L (some dz) := by rw [hz]; exact List.mem_cons_self ..
  have hzdir : dirOf z = dz := dirOf_of_mem_classList hzmem
  have hznc : ¬ (z.a = 0 ∧ z.b = 0) := not_central_of_mem_classList hzmem
  set E : List (Heis p) := Lz.take (p - 1) with hE
  have hLzlen : p - 1 ≤ Lz.length := by
    have : (classList L (some dz)).length = Lz.length + 1 := by rw [hz]; simp
    omega
  have hElen : p - 1 ≤ E.length := by
    rw [hE, List.length_take, Nat.min_eq_left hLzlen]
  have hEmem : ∀ g ∈ E, g ∈ classList L (some dz) := by
    intro g hg
    have : g ∈ Lz := (List.take_sublist _ _).mem hg
    rw [hz]; exact List.mem_cons_of_mem _ this
  -- prescribe the image
  obtain ⟨R, hRsub, hRa, hRb⟩ :=
    exists_sublist_asum_bsum (d := d0) (d' := dz) h0z
      (fun g hg => ⟨dirOf_of_mem_classList (hKmem g hg), not_central_of_mem_classList (hKmem g hg)⟩)
      (fun g hg => ⟨dirOf_of_mem_classList (hEmem g hg), not_central_of_mem_classList (hEmem g hg)⟩)
      hKlen hElen (-(asum G + z.a)) (-(bsum G + z.b))
  obtain ⟨R1, R2, hReq, hR1, hR2⟩ := List.sublist_append_iff.1 hRsub
  have hsubperm : (G ++ z :: R).Subperm L := by
    have hA02 : (G ++ R1).Sublist C0 := by
      have h := (List.Sublist.refl G).append hR1
      rw [hGK] at h
      exact h
    have hA13 : ([z] ++ R2).Sublist (classList L (some dz)) := by
      rw [hz]
      simpa using (hR2.trans (List.take_sublist _ _)).cons₂ z
    have h4 := subperm_of_two_split_classes (L := L) (k0 := some d0) (k1 := some dz)
      (by simpa using h0z) (A0 := G) (A1 := [z]) (A2 := R1) (A3 := R2) hA02 hA13
    have heq : G ++ [z] ++ R1 ++ R2 = G ++ z :: R := by
      rw [hReq]; simp
    rwa [heq] at h4
  refine not_parallel_spread_of_productOneFree hodd hfree hsubperm ?_ ?_ ?_ ?_ ?_
  · intro g hg h hh
    exact mul_comm_of_dir_eq (dirOf_of_mem_classList (hGmem g hg))
      (dirOf_of_mem_classList (hGmem h hh))
  · intro g hg htw
    have := dirOf_eq_of_twist_eq_zero (not_central_of_mem_classList (hGmem g hg)) hznc htw
    rw [dirOf_of_mem_classList (hGmem g hg), hzdir] at this
    exact h0z this
  · omega
  · rw [asum_append]
    simp only [asum_cons, hRa]
    ring
  · rw [bsum_append]
    simp only [bsum_cons, hRb]
    ring

/-- **Heavy triple exclusion.**  A product-one-free sequence over `Heis p`
(`p` an odd prime) cannot have one direction carrying `2p - 2` non-central
entries, a second direction carrying `p - 1` of them, and a third populated
direction. -/
theorem heavy_triple_exclusion (hodd : Odd p) {L : List (Heis p)} (hfree : ProductOneFree L)
    {d0 e dz : Option (ZMod p)} (h0e : d0 ≠ e) (h0z : d0 ≠ dz) (hez : e ≠ dz)
    (hd0 : 2 * p - 2 ≤ (classList L (some d0)).length)
    (he : p - 1 ≤ (classList L (some e)).length)
    (hdz : classList L (some dz) ≠ []) : False := by
  classical
  have hp2 := (Fact.out : p.Prime).two_le
  set C0 : List (Heis p) := classList L (some d0) with hC0
  set G : List (Heis p) := C0.take (p - 1) with hG
  set K : List (Heis p) := C0.drop (p - 1) with hK
  have hGK : G ++ K = C0 := by rw [hG, hK, List.take_append_drop]
  have hGlen : G.length = p - 1 := by
    rw [hG, List.length_take, Nat.min_eq_left (by omega)]
  have hKlen : p - 1 ≤ K.length := by
    rw [hK, List.length_drop]; omega
  have hGmem : ∀ g ∈ G, g ∈ C0 := fun g hg => (List.take_sublist _ _).mem hg
  have hKmem : ∀ g ∈ K, g ∈ C0 := fun g hg => (List.drop_sublist _ _).mem hg
  set E : List (Heis p) := (classList L (some e)).take (p - 1) with hE
  have hElen : p - 1 ≤ E.length := by
    rw [hE, List.length_take, Nat.min_eq_left he]
  have hEmem : ∀ g ∈ E, g ∈ classList L (some e) := fun g hg =>
    (List.take_sublist _ _).mem hg
  obtain ⟨z, Lz, hz⟩ := List.exists_cons_of_ne_nil hdz
  have hzmem : z ∈ classList L (some dz) := by rw [hz]; exact List.mem_cons_self ..
  have hzdir : dirOf z = dz := dirOf_of_mem_classList hzmem
  have hznc : ¬ (z.a = 0 ∧ z.b = 0) := not_central_of_mem_classList hzmem
  obtain ⟨R, hRsub, hRa, hRb⟩ :=
    exists_sublist_asum_bsum (d := d0) (d' := e) h0e
      (fun g hg => ⟨dirOf_of_mem_classList (hKmem g hg), not_central_of_mem_classList (hKmem g hg)⟩)
      (fun g hg => ⟨dirOf_of_mem_classList (hEmem g hg), not_central_of_mem_classList (hEmem g hg)⟩)
      hKlen hElen (-(asum G + z.a)) (-(bsum G + z.b))
  obtain ⟨R1, R2, hReq, hR1, hR2⟩ := List.sublist_append_iff.1 hRsub
  have hsubperm : (G ++ z :: R).Subperm L := by
    have hA02 : (G ++ R1).Sublist C0 := by
      have h := (List.Sublist.refl G).append hR1
      rw [hGK] at h
      exact h
    have h4 := subperm_of_split_classes (L := L) (k0 := some d0) (k1 := some dz)
      (k2 := some e) (by simpa using h0z) (by simpa using h0e)
      (by simpa using (Ne.symm hez))
      (A0 := G) (A1 := [z]) (A2 := R1) (A3 := R2) hA02
      (by rw [hz]; exact List.singleton_sublist.2 (by simp))
      (hR2.trans (List.take_sublist _ _))
    have heq : G ++ [z] ++ R1 ++ R2 = G ++ z :: R := by
      rw [hReq]; simp
    rwa [heq] at h4
  refine not_parallel_spread_of_productOneFree hodd hfree hsubperm ?_ ?_ ?_ ?_ ?_
  · intro g hg h hh
    exact mul_comm_of_dir_eq (dirOf_of_mem_classList (hGmem g hg))
      (dirOf_of_mem_classList (hGmem h hh))
  · intro g hg htw
    have := dirOf_eq_of_twist_eq_zero (not_central_of_mem_classList (hGmem g hg)) hznc htw
    rw [dirOf_of_mem_classList (hGmem g hg), hzdir] at this
    exact h0z this
  · omega
  · rw [asum_append]
    simp only [asum_cons, hRa]
    ring
  · rw [bsum_append]
    simp only [bsum_cons, hRb]
    ring

/-! ### Why the threshold `2p - 2` cannot simply be lowered -/

/-- In `Heis.heavy_pair_exclusion` and `Heis.heavy_triple_exclusion` the heavy
class is required to carry `2p - 2` entries: `p - 1` of them form the parallel
block `G` and the other `p - 1` are needed to sweep the whole line through
subsequence sums.  The following statement shows that `2p - 3` entries do *not*
suffice for that sweep, so the thresholds above are optimal for this argument:
for `p = 5`, a class of `2p - 3 = 7` entries all of which have the same image
leaves only `p - 2 = 3` entries after the parallel block is removed, and sums of
at most `3` copies of a fixed generator never reach `4`. -/
theorem short_constant_sums_ne :
    ∃ t : ZMod 5, ∀ l : List (ZMod 5), (∀ x ∈ l, x = 1) → l.length ≤ 3 → l.sum ≠ t := by
  have hsum : ∀ l : List (ZMod 5), (∀ x ∈ l, x = 1) → l.sum = (l.length : ZMod 5) := by
    intro l
    induction l with
    | nil => simp
    | cons a t ih =>
        intro hl
        have ha : a = 1 := hl a (List.mem_cons_self ..)
        have ht : ∀ x ∈ t, x = 1 := fun x hx => hl x (List.mem_cons_of_mem _ hx)
        rw [List.sum_cons, ha, ih ht, List.length_cons]
        push_cast
        ring
  refine ⟨4, fun l hl hlen => ?_⟩
  rw [hsum l hl]
  set n := l.length with hn
  clear_value n
  interval_cases n <;> decide

/-! ### The sharpened class bound -/

/-- **Sharpened class bound.**  For every prime `p ≥ 5` a product-one-free
sequence over `Heis p` has length at most `p² + 2p - 5`; for `p = 5` this gives
`d(H_125) ≤ 30`, improving the bound `32` of `ClassBound.lean`. -/
theorem length_le_heavy_bound (hodd : Odd p) (hp5 : 5 ≤ p) {L : List (Heis p)}
    (hfree : ProductOneFree L) : L.length ≤ p ^ 2 + 2 * p - 5 := by
  classical
  obtain ⟨q, rfl⟩ : ∃ q, p = q + 5 := ⟨p - 5, by omega⟩
  set cnt : Option (Option (ZMod (q + 5))) → ℕ := fun k => (classList L k).length with hcnt
  have hsplit : L.length = cnt none + ∑ d : Option (ZMod (q + 5)), cnt (some d) := by
    rw [length_eq_sum_filter (dirClass (p := q + 5)) L]
    exact Fintype.sum_option _
  have hcentral : cnt none ≤ q + 4 := by
    have := length_central_le (p := q + 5) hfree
    simpa [hcnt] using this
  have hclass : ∀ d : Option (ZMod (q + 5)), cnt (some d) ≤ 2 * q + 8 := by
    intro d
    have := length_class_le hodd hfree d
    simpa [hcnt] using this
  have hcardOpt : Fintype.card (Option (ZMod (q + 5))) = q + 6 := by
    simp [ZMod.card]
  have hRHS : (q + 5) ^ 2 + 2 * (q + 5) - 5 = q ^ 2 + 12 * q + 30 := by
    have hsq : (q + 5) ^ 2 = q ^ 2 + 10 * q + 25 := by ring
    omega
  rw [hRHS]
  by_cases hheavy : ∃ d0 : Option (ZMod (q + 5)), 2 * q + 8 ≤ cnt (some d0)
  · -- a heavy class exists
    obtain ⟨d0, hd0⟩ := hheavy
    have hd0' : 2 * (q + 5) - 2 ≤ (classList L (some d0)).length := by
      simp only [hcnt] at hd0; omega
    have hother : ∀ d : Option (ZMod (q + 5)), d ≠ d0 → cnt (some d) ≤ q + 4 := by
      intro d hd
      by_contra hcon
      refine heavy_pair_exclusion hodd hfree (Ne.symm hd) hd0' ?_
      simp only [hcnt] at hcon ⊢
      omega
    by_cases hbig : ∃ e : Option (ZMod (q + 5)), e ≠ d0 ∧ q + 4 ≤ cnt (some e)
    · obtain ⟨e, hed0, he⟩ := hbig
      have he' : (q + 5) - 1 ≤ (classList L (some e)).length := by
        simp only [hcnt] at he; omega
      have hzero : ∀ d : Option (ZMod (q + 5)),
          d ∉ ({d0, e} : Finset (Option (ZMod (q + 5)))) → cnt (some d) = 0 := by
        intro d hd
        by_contra hne
        have hne' : classList L (some d) ≠ [] := by
          intro hnil
          exact hne (by simp [hcnt, hnil])
        simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hd
        exact heavy_triple_exclusion hodd hfree (Ne.symm hed0) (Ne.symm hd.1)
          (Ne.symm hd.2) hd0' he' hne'
      have hsum2 : ∑ d : Option (ZMod (q + 5)), cnt (some d)
          = ∑ d ∈ ({d0, e} : Finset (Option (ZMod (q + 5)))), cnt (some d) :=
        (Finset.sum_subset (Finset.subset_univ _) (fun x _ hx => hzero x hx)).symm
      have hpair : ∑ d ∈ ({d0, e} : Finset (Option (ZMod (q + 5)))), cnt (some d)
          = cnt (some d0) + cnt (some e) := Finset.sum_pair (Ne.symm hed0)
      have h1 := hclass d0
      have h2 := hother e hed0
      rw [hsplit, hsum2, hpair]
      omega
    · push_neg at hbig
      have hbnd : ∀ d : Option (ZMod (q + 5)), d ∈ (Finset.univ.erase d0) → cnt (some d) ≤ q + 3 := by
        intro d hd
        have hne : d ≠ d0 := Finset.ne_of_mem_erase hd
        have := hbig d hne
        omega
      have hsplit2 : cnt (some d0) + ∑ d ∈ Finset.univ.erase d0, cnt (some d)
          = ∑ d : Option (ZMod (q + 5)), cnt (some d) :=
        Finset.add_sum_erase Finset.univ (fun d => cnt (some d)) (Finset.mem_univ d0)
      have hcarde : (Finset.univ.erase d0).card = q + 5 := by
        rw [Finset.card_erase_of_mem (Finset.mem_univ d0), Finset.card_univ, hcardOpt]
        omega
      have hle : ∑ d ∈ Finset.univ.erase d0, cnt (some d)
          ≤ (Finset.univ.erase d0).card * (q + 3) := by
        have := Finset.sum_le_card_nsmul (Finset.univ.erase d0) (fun d => cnt (some d)) (q + 3) hbnd
        simpa [mul_comm] using this
      rw [hcarde] at hle
      have h1 := hclass d0
      rw [hsplit, ← hsplit2]
      nlinarith [hcentral, hle, h1]
  · -- no heavy class
    push_neg at hheavy
    have hclass' : ∀ d : Option (ZMod (q + 5)), cnt (some d) ≤ 2 * q + 7 := by
      intro d
      have := hheavy d
      omega
    set S : Finset (Option (ZMod (q + 5))) :=
      Finset.univ.filter (fun d => q + 4 ≤ cnt (some d)) with hS
    have hmemS : ∀ d : Option (ZMod (q + 5)), d ∈ S ↔ q + 4 ≤ cnt (some d) := by
      intro d; simp [hS]
    by_cases h3 : 3 ≤ S.card
    · obtain ⟨T, hTS, hT3⟩ := Finset.exists_subset_card_eq h3
      obtain ⟨d0, e1, e2, h01, h02, h12, rfl⟩ := Finset.card_eq_three.1 hT3
      have hbig : ∀ d ∈ ({d0, e1, e2} : Finset (Option (ZMod (q + 5)))),
          q + 4 ≤ cnt (some d) := fun d hd => (hmemS d).1 (hTS hd)
      have hd0 : q + 4 ≤ cnt (some d0) := hbig d0 (by simp)
      have he1 : q + 4 ≤ cnt (some e1) := hbig e1 (by simp)
      have he2 : q + 4 ≤ cnt (some e2) := hbig e2 (by simp)
      have hzero : ∀ d ∉ ({d0, e1, e2} : Finset (Option (ZMod (q + 5)))), cnt (some d) = 0 := by
        intro d hd
        by_contra hne
        have hne' : classList L (some d) ≠ [] := by
          intro hnil
          exact hne (by simp [hcnt, hnil])
        simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hd
        exact four_class_exclusion hodd hfree h01 h02 (Ne.symm hd.1) h12 (Ne.symm hd.2.1)
          (Ne.symm hd.2.2) (by simpa [hcnt] using hd0) (by simpa [hcnt] using he1)
          (by simpa [hcnt] using he2) hne'
      have hsum3 : ∑ d : Option (ZMod (q + 5)), cnt (some d)
          = ∑ d ∈ ({d0, e1, e2} : Finset (Option (ZMod (q + 5)))), cnt (some d) :=
        (Finset.sum_subset (Finset.subset_univ _) (fun x _ hx => hzero x hx)).symm
      have hle3 : ∑ d ∈ ({d0, e1, e2} : Finset (Option (ZMod (q + 5)))), cnt (some d)
          ≤ 3 * (2 * q + 7) := by
        have hcard : ({d0, e1, e2} : Finset (Option (ZMod (q + 5)))).card = 3 := hT3
        have := Finset.sum_le_card_nsmul ({d0, e1, e2} : Finset (Option (ZMod (q + 5))))
          (fun d => cnt (some d)) (2 * q + 7) (fun d _ => hclass' d)
        simpa [hcard, mul_comm] using this
      rw [hsplit, hsum3]
      nlinarith [hcentral, hle3, sq_nonneg q]
    · have hS2 : S.card ≤ 2 := by omega
      have hsplitS : ∑ d : Option (ZMod (q + 5)), cnt (some d)
          = ∑ d ∈ S, cnt (some d) + ∑ d ∈ Sᶜ, cnt (some d) :=
        (Finset.sum_add_sum_compl S _).symm
      have hleS : ∑ d ∈ S, cnt (some d) ≤ S.card * (2 * q + 7) := by
        have := Finset.sum_le_card_nsmul S (fun d => cnt (some d)) (2 * q + 7)
          (fun d _ => hclass' d)
        simpa [mul_comm] using this
      have hleSc : ∑ d ∈ Sᶜ, cnt (some d) ≤ Sᶜ.card * (q + 3) := by
        have hbnd : ∀ d ∈ Sᶜ, cnt (some d) ≤ q + 3 := by
          intro d hd
          have : ¬ (q + 4 ≤ cnt (some d)) := by
            intro hcon
            exact (Finset.mem_compl.1 hd) ((hmemS d).2 hcon)
          omega
        have := Finset.sum_le_card_nsmul Sᶜ (fun d => cnt (some d)) (q + 3) hbnd
        simpa [mul_comm] using this
      have hcardc : S.card + Sᶜ.card = q + 6 := by
        have := Finset.card_add_card_compl S
        rw [hcardOpt] at this
        omega
      have hkey : S.card * (q + 4) ≤ 2 * (q + 4) := Nat.mul_le_mul_right _ hS2
      have hprod : (Sᶜ.card + S.card) * (q + 3) = (q + 6) * (q + 3) := by
        rw [show Sᶜ.card + S.card = q + 6 by omega]
      rw [hsplit, hsplitS]
      nlinarith [hcentral, hleS, hleSc, hprod, hkey]

/-- `d(H_{p³}) ≤ p² + 2p - 5` for every prime `p ≥ 5`. -/
theorem smallDavenport_le_heavy_bound (hodd : Odd p) (hp5 : 5 ≤ p) :
    smallDavenport (Heis p) ≤ p ^ 2 + 2 * p - 5 := by
  refine csSup_le ⟨0, ⟨[], rfl, productOneFree_nil⟩⟩ ?_
  rintro n ⟨L, rfl, hL⟩
  exact length_le_heavy_bound hodd hp5 hL

end Prime

end Heis

open Heis

/-- For the Heisenberg group of order `125`: `d(H_125) ≤ 30`. -/
theorem smallDavenport_heis_five_le_30 : smallDavenport (Heis 5) ≤ 30 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have h := Heis.smallDavenport_le_heavy_bound (p := 5) (by decide) (by norm_num)
  norm_num at h
  exact h

/-- The sharpest two-sided bound proved here for the Heisenberg group of order
`125`: `12 ≤ d(H_125) ≤ 30`. -/
theorem smallDavenport_heis_five_heavy_bounds :
    12 ≤ smallDavenport (Heis 5) ∧ smallDavenport (Heis 5) ≤ 30 :=
  ⟨twelve_le_smallDavenport_heis_five, smallDavenport_heis_five_le_30⟩

end Heisenberg125