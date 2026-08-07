/-
# Consequences of the parallel spread criterion: a bound by direction classes

Using `Heis.isProductOne_of_parallel_spread` we show that a product-one-free
sequence over `Heis p` cannot spread over four direction classes in the
following sense: there are no four *distinct* directions `d₀, e₁, e₂, d_z`
such that `d₀, e₁, e₂` each carry `p - 1` non-central entries and `d_z` carries
at least one.

The mechanism: `p - 1` entries of the class `d₀` are pairwise commuting and
none of them commutes with an entry `z` of class `d_z`; the classes `e₁, e₂`
point in independent directions and each carries `p - 1` entries, so their
subsequence sums realise *every* element of `(ZMod p)²`
(`Heis.exists_sublist_asum_bsum`), in particular the one that makes the whole
selected subsequence have vanishing image.  The spread criterion then produces
a product-one subsequence.
-/
import Algebra.Heisenberg125.ParallelSpread

namespace Heisenberg125

namespace Heis

variable {p : ℕ}

section Prime

variable [Fact p.Prime]

/-! ### Refined classes: centre and directions -/

/-- The refined class of an element: `none` for central elements, `some d` for
non-central elements of direction `d`. -/
noncomputable def dirClass (g : Heis p) : Option (Option (ZMod p)) :=
  if g.a = 0 ∧ g.b = 0 then none else some (dirOf g)

/-- The entries of `L` in the refined class `k`. -/
noncomputable def classList (L : List (Heis p)) (k : Option (Option (ZMod p))) : List (Heis p) :=
  L.filter (fun g => decide (dirClass g = k))

lemma mem_classList {L : List (Heis p)} {k : Option (Option (ZMod p))} {g : Heis p}
    (hg : g ∈ classList L k) : g ∈ L ∧ dirClass g = k := by
  classical
  refine ⟨List.mem_of_mem_filter hg, ?_⟩
  simpa using List.of_mem_filter hg

lemma classList_sublist (L : List (Heis p)) (k : Option (Option (ZMod p))) :
    (classList L k).Sublist L := List.filter_sublist

lemma dirOf_of_mem_classList {L : List (Heis p)} {d : Option (ZMod p)} {g : Heis p}
    (hg : g ∈ classList L (some d)) : dirOf g = d := by
  have h := (mem_classList hg).2
  unfold dirClass at h
  by_cases hc : g.a = 0 ∧ g.b = 0
  · simp [hc] at h
  · simpa [hc] using h

lemma not_central_of_mem_classList {L : List (Heis p)} {d : Option (ZMod p)} {g : Heis p}
    (hg : g ∈ classList L (some d)) : ¬ (g.a = 0 ∧ g.b = 0) := by
  have h := (mem_classList hg).2
  unfold dirClass at h
  by_cases hc : g.a = 0 ∧ g.b = 0
  · simp [hc] at h
  · exact hc

lemma central_of_mem_classList_none {L : List (Heis p)} {g : Heis p}
    (hg : g ∈ classList L none) : g.a = 0 ∧ g.b = 0 := by
  have h := (mem_classList hg).2
  unfold dirClass at h
  by_cases hc : g.a = 0 ∧ g.b = 0
  · exact hc
  · simp [hc] at h

/-! ### Commuting and twisting -/

/-- Two elements of the same direction commute. -/
lemma mul_comm_of_dir_eq {d : Option (ZMod p)} {g h : Heis p}
    (hg : dirOf g = d) (hh : dirOf h = d) : g.a * h.b = h.a * g.b := by
  cases d with
  | none =>
      rw [a_eq_zero_of_dir_none hg, a_eq_zero_of_dir_none hh]; ring
  | some m =>
      rw [b_eq_mul_of_dir_some hg, b_eq_mul_of_dir_some hh]; ring

/-- Non-central elements with vanishing twist have the same direction. -/
lemma dirOf_eq_of_twist_eq_zero {g z : Heis p} (hg : ¬ (g.a = 0 ∧ g.b = 0))
    (hz : ¬ (z.a = 0 ∧ z.b = 0)) (h : twist z g = 0) : dirOf g = dirOf z := by
  have h' : g.a * z.b = z.a * g.b := by
    unfold twist at h
    linear_combination h
  by_cases hga : g.a = 0
  · have hgb : g.b ≠ 0 := fun hb => hg ⟨hga, hb⟩
    have hza : z.a = 0 := by
      have hzero : z.a * g.b = 0 := by rw [← h', hga, zero_mul]
      rcases mul_eq_zero.1 hzero with h1 | h1
      · exact h1
      · exact absurd h1 hgb
    simp [dirOf, hga, hza]
  · have hza : z.a ≠ 0 := by
      intro hza
      have hzero : g.a * z.b = 0 := by rw [h', hza, zero_mul]
      rcases mul_eq_zero.1 hzero with h1 | h1
      · exact hga h1
      · exact hz ⟨hza, h1⟩
    simp only [dirOf, hga, hza, if_false, Option.some.injEq]
    rw [div_eq_div_iff hga hza]
    linear_combination -h'

/-! ### Prescribed sums from two independent classes -/

/-- The direction vector of a point of the projective line. -/
def dirVec : Option (ZMod p) → ZMod p × ZMod p
  | none => (0, 1)
  | some m => (1, m)

lemma asum_bsum_of_dir {d : Option (ZMod p)} {K : List (Heis p)}
    (h : ∀ g ∈ K, dirOf g = d) :
    asum K = (K.map (coord1 d)).sum * (dirVec d).1 ∧
      bsum K = (K.map (coord1 d)).sum * (dirVec d).2 := by
  cases d with
  | none =>
      have ha : asum K = 0 := by
        have : ∀ g ∈ K, g.a = 0 := fun g hg => a_eq_zero_of_dir_none (h g hg)
        simpa using asum_of_const this
      constructor
      · simp [dirVec, ha]
      · simp [dirVec]
  | some m =>
      have hb : bsum K = m * asum K :=
        bsum_eq_mul_asum (fun g hg => b_eq_mul_of_dir_some (h g hg))
      constructor
      · simp [dirVec]
      · simp [dirVec, hb, mul_comm]

lemma det_ne_zero_of_ne {d d' : Option (ZMod p)} (hne : d ≠ d') :
    (dirVec d).1 * (dirVec d').2 - (dirVec d').1 * (dirVec d).2 ≠ 0 := by
  cases d with
  | none =>
      cases d' with
      | none => exact absurd rfl hne
      | some m' => simp [dirVec]
  | some m =>
      cases d' with
      | none => simp [dirVec]
      | some m' =>
          simp only [dirVec, one_mul]
          intro h
          apply hne
          have : m = m' := by linear_combination -h
          rw [this]

/-- **Two independent classes realise every image.**  If `B` and `C` consist of
non-central elements of two distinct directions, and each has at least `p - 1`
entries, then every element of `(ZMod p)²` is the image of a subsequence of
`B ++ C`. -/
theorem exists_sublist_asum_bsum {d d' : Option (ZMod p)} (hne : d ≠ d')
    {B C : List (Heis p)} (hB : ∀ g ∈ B, dirOf g = d ∧ ¬ (g.a = 0 ∧ g.b = 0))
    (hC : ∀ g ∈ C, dirOf g = d' ∧ ¬ (g.a = 0 ∧ g.b = 0))
    (hBlen : p - 1 ≤ B.length) (hClen : p - 1 ≤ C.length) (s t : ZMod p) :
    ∃ R : List (Heis p), R.Sublist (B ++ C) ∧ asum R = s ∧ bsum R = t := by
  classical
  have hcoordB : ∀ g ∈ B, coord1 d g ≠ 0 := by
    intro g hg
    obtain ⟨hdir, hnc⟩ := hB g hg
    cases d with
    | none =>
        have ha : g.a = 0 := a_eq_zero_of_dir_none hdir
        simp only [coord1]
        intro hb
        exact hnc ⟨ha, hb⟩
    | some m =>
        simp only [coord1]
        intro ha
        exact hnc ⟨ha, by rw [b_eq_mul_of_dir_some hdir, ha, mul_zero]⟩
  have hcoordC : ∀ g ∈ C, coord1 d' g ≠ 0 := by
    intro g hg
    obtain ⟨hdir, hnc⟩ := hC g hg
    cases d' with
    | none =>
        have ha : g.a = 0 := a_eq_zero_of_dir_none hdir
        simp only [coord1]
        intro hb
        exact hnc ⟨ha, hb⟩
    | some m =>
        simp only [coord1]
        intro ha
        exact hnc ⟨ha, by rw [b_eq_mul_of_dir_some hdir, ha, mul_zero]⟩
  set D : ZMod p := (dirVec d).1 * (dirVec d').2 - (dirVec d').1 * (dirVec d).2 with hD
  have hDne : D ≠ 0 := det_ne_zero_of_ne hne
  set σ : ZMod p := (s * (dirVec d').2 - t * (dirVec d').1) / D with hσ
  set τ : ZMod p := (t * (dirVec d).1 - s * (dirVec d).2) / D with hτ
  have hsol1 : σ * (dirVec d).1 + τ * (dirVec d').1 = s := by
    rw [hσ, hτ, div_mul_eq_mul_div, div_mul_eq_mul_div, ← add_div, div_eq_iff hDne, hD]
    ring
  have hsol2 : σ * (dirVec d).2 + τ * (dirVec d').2 = t := by
    rw [hσ, hτ, div_mul_eq_mul_div, div_mul_eq_mul_div, ← add_div, div_eq_iff hDne, hD]
    ring
  obtain ⟨KB, hKBsub, hKBsum⟩ :=
    exists_sublist_map_sum_eq (coord1 d) B hcoordB hBlen σ
  obtain ⟨KC, hKCsub, hKCsum⟩ :=
    exists_sublist_map_sum_eq (coord1 d') C hcoordC hClen τ
  refine ⟨KB ++ KC, hKBsub.append hKCsub, ?_, ?_⟩
  · rw [asum_append]
    obtain ⟨h1, _⟩ := asum_bsum_of_dir (d := d) (K := KB)
      (fun g hg => (hB g (hKBsub.mem hg)).1)
    obtain ⟨h2, _⟩ := asum_bsum_of_dir (d := d') (K := KC)
      (fun g hg => (hC g (hKCsub.mem hg)).1)
    rw [h1, h2, hKBsum, hKCsum, hsol1]
  · rw [bsum_append]
    obtain ⟨_, h1⟩ := asum_bsum_of_dir (d := d) (K := KB)
      (fun g hg => (hB g (hKBsub.mem hg)).1)
    obtain ⟨_, h2⟩ := asum_bsum_of_dir (d := d') (K := KC)
      (fun g hg => (hC g (hKCsub.mem hg)).1)
    rw [h1, h2, hKBsum, hKCsum, hsol2]

/-! ### Four distinct classes cannot all be populated -/

/-- Sub-multisets of four *distinct* refined classes assemble to a sub-multiset
of the whole sequence. -/
lemma subperm_of_four_classes {L : List (Heis p)} {k0 k1 k2 k3 : Option (Option (ZMod p))}
    (h01 : k0 ≠ k1) (h02 : k0 ≠ k2) (h03 : k0 ≠ k3) (h12 : k1 ≠ k2) (h13 : k1 ≠ k3)
    (h23 : k2 ≠ k3) {A0 A1 A2 A3 : List (Heis p)}
    (hA0 : A0.Sublist (classList L k0)) (hA1 : A1.Sublist (classList L k1))
    (hA2 : A2.Sublist (classList L k2)) (hA3 : A3.Sublist (classList L k3)) :
    (A0 ++ A1 ++ A2 ++ A3).Subperm L := by
  classical
  set F : Option (Option (ZMod p)) → Multiset (Heis p) :=
    fun k => ((classList L k : List (Heis p)) : Multiset (Heis p)) with hF
  have hsum : ∑ k ∈ ({k0, k1, k2, k3} : Finset (Option (Option (ZMod p)))), F k
      = F k0 + F k1 + F k2 + F k3 := by
    rw [Finset.sum_insert (by simp [h01, h02, h03]),
      Finset.sum_insert (by simp [h12, h13]),
      Finset.sum_insert (by simp [h23]), Finset.sum_singleton]
    abel
  have hle : ((A0 ++ A1 ++ A2 ++ A3 : List (Heis p)) : Multiset (Heis p))
      ≤ (L : Multiset (Heis p)) := by
    have hexp : ((A0 ++ A1 ++ A2 ++ A3 : List (Heis p)) : Multiset (Heis p))
        = (A0 : Multiset (Heis p)) + (A1 : Multiset (Heis p)) + (A2 : Multiset (Heis p))
          + (A3 : Multiset (Heis p)) := by
      simp [← Multiset.coe_add, add_assoc]
    rw [hexp]
    calc (A0 : Multiset (Heis p)) + (A1 : Multiset (Heis p)) + (A2 : Multiset (Heis p))
          + (A3 : Multiset (Heis p))
        ≤ F k0 + F k1 + F k2 + F k3 := by
          gcongr <;> exact Multiset.coe_le.2 (by assumption : List.Sublist _ _).subperm
      _ = ∑ k ∈ ({k0, k1, k2, k3} : Finset (Option (Option (ZMod p)))), F k := hsum.symm
      _ ≤ ∑ k : Option (Option (ZMod p)), F k :=
          Finset.sum_le_sum_of_subset (Finset.subset_univ _)
      _ = (L : Multiset (Heis p)) := sum_coe_filter_fiber (dirClass (p := p)) L
  exact Multiset.coe_le.1 hle

/-- **Four-class exclusion.**  A product-one-free sequence over `Heis p`
(`p` an odd prime) cannot have three distinct directions carrying `p - 1`
non-central entries each together with a fourth direction carrying an entry. -/
theorem four_class_exclusion (hodd : Odd p) {L : List (Heis p)} (hfree : ProductOneFree L)
    {d0 e1 e2 dz : Option (ZMod p)}
    (h01 : d0 ≠ e1) (h02 : d0 ≠ e2) (h0z : d0 ≠ dz) (h12 : e1 ≠ e2) (h1z : e1 ≠ dz)
    (h2z : e2 ≠ dz)
    (hd0 : p - 1 ≤ (classList L (some d0)).length)
    (he1 : p - 1 ≤ (classList L (some e1)).length)
    (he2 : p - 1 ≤ (classList L (some e2)).length)
    (hdz : classList L (some dz) ≠ []) : False := by
  classical
  set G : List (Heis p) := (classList L (some d0)).take (p - 1) with hG
  set B : List (Heis p) := (classList L (some e1)).take (p - 1) with hB
  set C : List (Heis p) := (classList L (some e2)).take (p - 1) with hC
  obtain ⟨z, Lz, hz⟩ := List.exists_cons_of_ne_nil hdz
  have hzmem : z ∈ classList L (some dz) := by rw [hz]; exact List.mem_cons_self ..
  have hzdir : dirOf z = dz := dirOf_of_mem_classList hzmem
  have hznc : ¬ (z.a = 0 ∧ z.b = 0) := not_central_of_mem_classList hzmem
  have hGmem : ∀ g ∈ G, g ∈ classList L (some d0) := fun g hg =>
    (List.take_sublist _ _).mem hg
  have hBmem : ∀ g ∈ B, g ∈ classList L (some e1) := fun g hg =>
    (List.take_sublist _ _).mem hg
  have hCmem : ∀ g ∈ C, g ∈ classList L (some e2) := fun g hg =>
    (List.take_sublist _ _).mem hg
  have hGlen : G.length = p - 1 := by
    rw [hG, List.length_take, Nat.min_eq_left hd0]
  have hBlen : p - 1 ≤ B.length := by
    rw [hB, List.length_take, Nat.min_eq_left he1]
  have hClen : p - 1 ≤ C.length := by
    rw [hC, List.length_take, Nat.min_eq_left he2]
  obtain ⟨R, hRsub, hRa, hRb⟩ :=
    exists_sublist_asum_bsum (d := e1) (d' := e2) h12
      (fun g hg => ⟨dirOf_of_mem_classList (hBmem g hg), not_central_of_mem_classList (hBmem g hg)⟩)
      (fun g hg => ⟨dirOf_of_mem_classList (hCmem g hg), not_central_of_mem_classList (hCmem g hg)⟩)
      hBlen hClen (-(asum G + z.a)) (-(bsum G + z.b))
  -- the configuration is a sub-multiset of `L`
  obtain ⟨R1, R2, hReq, hR1, hR2⟩ := List.sublist_append_iff.1 hRsub
  have hsubperm : (G ++ z :: R).Subperm L := by
    have h4 := subperm_of_four_classes (L := L) (k0 := some d0) (k1 := some dz)
      (k2 := some e1) (k3 := some e2)
      (by simpa using h0z) (by simpa using h01) (by simpa using h02)
      (by simpa using (Ne.symm h1z)) (by simpa using (Ne.symm h2z)) (by simpa using h12)
      (A0 := G) (A1 := [z]) (A2 := R1) (A3 := R2)
      (List.take_sublist _ _)
      (by rw [hz]; exact List.singleton_sublist.2 (by simp))
      (hR1.trans (List.take_sublist _ _)) (hR2.trans (List.take_sublist _ _))
    have heq : G ++ [z] ++ R1 ++ R2 = G ++ z :: R := by
      rw [hReq]; simp
    rwa [heq] at h4
  -- the spread criterion applies
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

/-! ### Counting the classes -/

/-- At most `p - 1` entries of a product-one-free sequence are central. -/
lemma length_central_le {L : List (Heis p)} (hfree : ProductOneFree L) :
    (classList L none).length ≤ p - 1 := by
  classical
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  by_contra hlen
  push_neg at hlen
  have hlen' : p ≤ (classList L none).length := by omega
  obtain ⟨i, j, hij, hj, hsum⟩ :=
    exists_consecutive_block_sum_zero (Heis.c) (classList L none) hlen'
  set T : List (Heis p) := ((classList L none).take j).drop i with hT
  have hTsub : T.Sublist L :=
    ((List.drop_sublist _ _).trans (List.take_sublist _ _)).trans (classList_sublist L none)
  have hTmem : ∀ g ∈ T, g.a = 0 ∧ g.b = 0 := fun g hg =>
    central_of_mem_classList_none
      (((List.drop_sublist _ _).trans (List.take_sublist _ _)).mem hg)
  have hTne : T ≠ [] := by
    intro h
    have hzero : T.length = 0 := by rw [h]; rfl
    rw [hT, List.length_drop, List.length_take] at hzero
    omega
  refine hfree T hTsub hTne ⟨T, List.Perm.refl _, ?_⟩
  rw [prod_eq_one_iff]
  refine ⟨?_, ?_, ?_⟩
  · simpa using asum_of_const (fun g hg => (hTmem g hg).1)
  · simpa using bsum_of_const (fun g hg => (hTmem g hg).2)
  · rw [crossSum_eq_zero_of_a_eq_zero (fun g hg => (hTmem g hg).1), add_zero]
    exact hsum

/-- Each direction class of a product-one-free sequence has at most `2p - 2`
entries. -/
lemma length_class_le (hodd : Odd p) {L : List (Heis p)} (hfree : ProductOneFree L)
    (d : Option (ZMod p)) : (classList L (some d)).length ≤ 2 * p - 2 :=
  length_le_of_const_dir hodd (hfree.sublist (classList_sublist L (some d)))
    (fun _ hg => dirOf_of_mem_classList hg)

/-- **At most three large classes.**  In a product-one-free sequence over
`Heis p` (`p` an odd prime) at most three of the `p + 1` direction classes
carry `p - 1` or more non-central entries. -/
theorem card_large_classes_le_three (hodd : Odd p) {L : List (Heis p)}
    (hfree : ProductOneFree L) :
    (Finset.univ.filter
      (fun d : Option (ZMod p) => p - 1 ≤ (classList L (some d)).length)).card ≤ 3 := by
  classical
  set S : Finset (Option (ZMod p)) :=
    Finset.univ.filter (fun d => p - 1 ≤ (classList L (some d)).length) with hS
  have hmemS : ∀ d : Option (ZMod p), d ∈ S ↔ p - 1 ≤ (classList L (some d)).length := by
    intro d; simp [hS]
  by_contra hcard
  push_neg at hcard
  have h3 : 3 ≤ S.card := by omega
  obtain ⟨T, hTS, hT3⟩ := Finset.exists_subset_card_eq h3
  obtain ⟨d0, e1, e2, h01, h02, h12, rfl⟩ := Finset.card_eq_three.1 hT3
  have hss : ({d0, e1, e2} : Finset (Option (ZMod p))) ⊂ S :=
    Finset.ssubset_iff_of_subset hTS |>.2 (by
      by_contra hcon
      push_neg at hcon
      have : S ⊆ ({d0, e1, e2} : Finset (Option (ZMod p))) := fun x hx => by
        by_contra hx'
        exact absurd (hcon x hx) hx'
      have := Finset.card_le_card this
      omega)
  obtain ⟨dz, hdzS, hdzT⟩ := Finset.exists_of_ssubset hss
  have hp2 := (Fact.out : p.Prime).two_le
  have hbig : ∀ d ∈ ({d0, e1, e2} : Finset (Option (ZMod p))),
      p - 1 ≤ (classList L (some d)).length := fun d hd => (hmemS d).1 (hTS hd)
  have hne : classList L (some dz) ≠ [] := by
    intro hnil
    have := (hmemS dz).1 hdzS
    rw [hnil] at this
    simp at this
    omega
  simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hdzT
  exact four_class_exclusion hodd hfree h01 h02 (Ne.symm hdzT.1) h12 (Ne.symm hdzT.2.1)
    (Ne.symm hdzT.2.2) (hbig d0 (by simp)) (hbig e1 (by simp)) (hbig e2 (by simp)) hne

/-- **Class bound.**  For every prime `p ≥ 5` a product-one-free sequence over
`Heis p` has length at most `p² + 2p - 3`; for `p = 5` this gives
`d(H_125) ≤ 32`, improving the spread bound `34`. -/
theorem length_le_class_bound (hodd : Odd p) (hp5 : 5 ≤ p) {L : List (Heis p)}
    (hfree : ProductOneFree L) : L.length ≤ p ^ 2 + 2 * p - 3 := by
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
  set S : Finset (Option (ZMod (q + 5))) :=
    Finset.univ.filter (fun d => q + 4 ≤ cnt (some d)) with hS
  have hmemS : ∀ d : Option (ZMod (q + 5)), d ∈ S ↔ q + 4 ≤ cnt (some d) := by
    intro d; simp [hS]
  have hcardOpt : Fintype.card (Option (ZMod (q + 5))) = q + 6 := by
    simp [ZMod.card]
  have hRHS : (q + 5) ^ 2 + 2 * (q + 5) - 3 = q ^ 2 + 12 * q + 32 := by
    have hsq : (q + 5) ^ 2 = q ^ 2 + 10 * q + 25 := by ring
    omega
  rw [hRHS]
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
        ≤ 3 * (2 * q + 8) := by
      have hcard : ({d0, e1, e2} : Finset (Option (ZMod (q + 5)))).card = 3 := hT3
      have := Finset.sum_le_card_nsmul ({d0, e1, e2} : Finset (Option (ZMod (q + 5))))
        (fun d => cnt (some d)) (2 * q + 8) (fun d _ => hclass d)
      simpa [hcard, mul_comm] using this
    rw [hsplit, hsum3]
    nlinarith [hcentral, hle3, sq_nonneg q]
  · have hS2 : S.card ≤ 2 := by omega
    have hsplitS : ∑ d : Option (ZMod (q + 5)), cnt (some d)
        = ∑ d ∈ S, cnt (some d) + ∑ d ∈ Sᶜ, cnt (some d) :=
      (Finset.sum_add_sum_compl S _).symm
    have hleS : ∑ d ∈ S, cnt (some d) ≤ S.card * (2 * q + 8) := by
      have := Finset.sum_le_card_nsmul S (fun d => cnt (some d)) (2 * q + 8)
        (fun d _ => hclass d)
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
    have hkey : S.card * (q + 5) ≤ 2 * (q + 5) := Nat.mul_le_mul_right _ hS2
    have hprod : (Sᶜ.card + S.card) * (q + 3) = (q + 6) * (q + 3) := by
      rw [show Sᶜ.card + S.card = q + 6 by omega]
    rw [hsplit, hsplitS]
    nlinarith [hcentral, hleS, hleSc, hprod, hkey]

/-- `d(H_{p³}) ≤ p² + 2p - 3` for every prime `p ≥ 5`. -/
theorem smallDavenport_le_class_bound (hodd : Odd p) (hp5 : 5 ≤ p) :
    smallDavenport (Heis p) ≤ p ^ 2 + 2 * p - 3 := by
  refine csSup_le ⟨0, ⟨[], rfl, productOneFree_nil⟩⟩ ?_
  rintro n ⟨L, rfl, hL⟩
  exact length_le_class_bound hodd hp5 hL

end Prime

end Heis

open Heis

/-- For the Heisenberg group of order `125`: `d(H_125) ≤ 32`, improving the
spread bound `34` of `SpreadBound.lean`. -/
theorem smallDavenport_heis_five_le_32 : smallDavenport (Heis 5) ≤ 32 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  have h := Heis.smallDavenport_le_class_bound (p := 5) (by decide) (by norm_num)
  norm_num at h
  exact h

/-- The sharpest two-sided bound proved here for the Heisenberg group of order
`125`: `12 ≤ d(H_125) ≤ 32`. -/
theorem smallDavenport_heis_five_class_bounds :
    12 ≤ smallDavenport (Heis 5) ∧ smallDavenport (Heis 5) ≤ 32 :=
  ⟨twelve_le_smallDavenport_heis_five, smallDavenport_heis_five_le_32⟩

end Heisenberg125