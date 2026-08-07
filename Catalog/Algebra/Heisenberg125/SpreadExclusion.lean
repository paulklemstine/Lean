/-
# A quantitative spread exclusion for three direction classes

The parallel spread criterion `Heis.isProductOne_of_parallel_spread` needs three
ingredients inside a product-one-free sequence `L`:

* `p - 1` pairwise commuting entries `G` (a block of one direction class `d₁`);
* a pivot `z` of a *different* direction;
* enough further entries to make the image of the whole selected subsequence
  vanish in `(ZMod p)²`.

`Algebra.Heisenberg125.ClassBound` and `Algebra.Heisenberg125.HeavyClass` used
this with two *completely covering* auxiliary classes (`p - 1` entries each, so
that every image is realisable).  Here we make the argument quantitative:

* the entries of `d₁` beyond the block `G` provide **several** admissible images
  `a • dirVec d₁` for the `d₁`-part (`card_mapSums_ge`);
* a class with `n` entries realises at least `min p (n + 1)` sums along its own
  line, so it *fails* to realise at most `p - 1 - n` of them.

Comparing the two counts gives `Heis.spread_exclusion`: three distinct
directions with class sizes `n₁, n₂, n₃` are impossible as soon as

`(p - 1 - n₂) + (p - 1 - n₃) + 1 < min p (n₁ - (p - 1) + 1)`.

This one statement contains the four-class exclusion as a special case and, for
`p = 5`, yields the exclusions `(5,4,4)`, `(6,4,3)`, `(7,3,3)`, `(7,4,2)` and
`(8,3,2)` used in `Algebra.Heisenberg125.SpreadClassBound` to push the upper
bound for `d(H_125)` from `27` down to `23`.
-/
import Algebra.Heisenberg125.MixedBound

namespace Heisenberg125

namespace Heis

variable {p : ℕ}

section Prime

variable [Fact p.Prime]

/-! ### Chart coordinates of non-central elements -/

/-- The linearising coordinate of a non-central element of direction `d` is
nonzero. -/
lemma coord1_ne_zero_of_dir {d : Option (ZMod p)} {g : Heis p}
    (hdir : dirOf g = d) (hnc : ¬ (g.a = 0 ∧ g.b = 0)) : coord1 d g ≠ 0 := by
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

/-- A direction vector is never zero. -/
lemma dirVec_ne_zero (d : Option (ZMod p)) : (dirVec d).1 ≠ 0 ∨ (dirVec d).2 ≠ 0 := by
  cases d with
  | none => exact Or.inr (by simp [dirVec])
  | some m => exact Or.inl (by simp [dirVec])

/-- **Prescribed images from two classes, quantitatively.**  If `σ` is a
realisable coordinate sum of `B` and `τ` one of `C`, then some pair of
sublists of `B` and `C` has image `σ • dirVec d + τ • dirVec d'`. -/
lemma exists_sublists_image_of_mapSums {d d' : Option (ZMod p)}
    {B C : List (Heis p)} (hB : ∀ g ∈ B, dirOf g = d) (hC : ∀ g ∈ C, dirOf g = d')
    {σ τ : ZMod p} (hσ : σ ∈ mapSums (coord1 d) B) (hτ : τ ∈ mapSums (coord1 d') C) :
    ∃ K K' : List (Heis p), K.Sublist B ∧ K'.Sublist C ∧
      asum (K ++ K') = σ * (dirVec d).1 + τ * (dirVec d').1 ∧
      bsum (K ++ K') = σ * (dirVec d).2 + τ * (dirVec d').2 := by
  obtain ⟨K, hKsub, hKsum⟩ := (mem_mapSums_iff _ _ _).1 hσ
  obtain ⟨K', hK'sub, hK'sum⟩ := (mem_mapSums_iff _ _ _).1 hτ
  refine ⟨K, K', hKsub, hK'sub, ?_, ?_⟩
  · rw [asum_append]
    obtain ⟨h1, _⟩ := asum_bsum_of_dir (d := d) (K := K) (fun g hg => hB g (hKsub.mem hg))
    obtain ⟨h2, _⟩ := asum_bsum_of_dir (d := d') (K := K') (fun g hg => hC g (hK'sub.mem hg))
    rw [h1, h2, hKsum, hK'sum]
  · rw [bsum_append]
    obtain ⟨_, h1⟩ := asum_bsum_of_dir (d := d) (K := K) (fun g hg => hB g (hKsub.mem hg))
    obtain ⟨_, h2⟩ := asum_bsum_of_dir (d := d') (K := K') (fun g hg => hC g (hK'sub.mem hg))
    rw [h1, h2, hKsum, hK'sum]

/-! ### Cramer coefficients for three pairwise distinct directions -/

/-- The coefficient expressing `-dirVec d₁` along `dirVec d₂` in the basis
`(dirVec d₂, dirVec d₃)`. -/
noncomputable def cramer2 (d1 d2 d3 : Option (ZMod p)) : ZMod p :=
  -((dirVec d1).1 * (dirVec d3).2 - (dirVec d3).1 * (dirVec d1).2) /
    ((dirVec d2).1 * (dirVec d3).2 - (dirVec d3).1 * (dirVec d2).2)

/-- The coefficient expressing `-dirVec d₁` along `dirVec d₃` in the basis
`(dirVec d₂, dirVec d₃)`. -/
noncomputable def cramer3 (d1 d2 d3 : Option (ZMod p)) : ZMod p :=
  -((dirVec d2).1 * (dirVec d1).2 - (dirVec d1).1 * (dirVec d2).2) /
    ((dirVec d2).1 * (dirVec d3).2 - (dirVec d3).1 * (dirVec d2).2)

lemma cramer2_ne_zero {d1 d2 d3 : Option (ZMod p)} (h13 : d1 ≠ d3) (h23 : d2 ≠ d3) :
    cramer2 d1 d2 d3 ≠ 0 := by
  have hnum : (dirVec d1).1 * (dirVec d3).2 - (dirVec d3).1 * (dirVec d1).2 ≠ 0 :=
    det_ne_zero_of_ne h13
  have hden : (dirVec d2).1 * (dirVec d3).2 - (dirVec d3).1 * (dirVec d2).2 ≠ 0 :=
    det_ne_zero_of_ne h23
  simp only [cramer2]
  exact div_ne_zero (neg_ne_zero.2 hnum) hden

lemma cramer3_ne_zero {d1 d2 d3 : Option (ZMod p)} (h12 : d1 ≠ d2) (h23 : d2 ≠ d3) :
    cramer3 d1 d2 d3 ≠ 0 := by
  have hnum : (dirVec d2).1 * (dirVec d1).2 - (dirVec d1).1 * (dirVec d2).2 ≠ 0 :=
    det_ne_zero_of_ne (Ne.symm h12)
  have hden : (dirVec d2).1 * (dirVec d3).2 - (dirVec d3).1 * (dirVec d2).2 ≠ 0 :=
    det_ne_zero_of_ne h23
  simp only [cramer3]
  exact div_ne_zero (neg_ne_zero.2 hnum) hden

lemma cramer_solves {d1 d2 d3 : Option (ZMod p)} (h23 : d2 ≠ d3) (a : ZMod p) :
    a * (dirVec d1).1 + (cramer2 d1 d2 d3 * a) * (dirVec d2).1
        + (cramer3 d1 d2 d3 * a) * (dirVec d3).1 = 0 ∧
      a * (dirVec d1).2 + (cramer2 d1 d2 d3 * a) * (dirVec d2).2
        + (cramer3 d1 d2 d3 * a) * (dirVec d3).2 = 0 := by
  have hden : (dirVec d2).1 * (dirVec d3).2 - (dirVec d3).1 * (dirVec d2).2 ≠ 0 :=
    det_ne_zero_of_ne h23
  have hD : ((dirVec d2).1 * (dirVec d3).2 - (dirVec d3).1 * (dirVec d2).2) *
      ((dirVec d2).1 * (dirVec d3).2 - (dirVec d3).1 * (dirVec d2).2)⁻¹ = 1 :=
    mul_inv_cancel₀ hden
  simp only [cramer2, cramer3, div_eq_mul_inv]
  constructor
  · linear_combination (-(a * (dirVec d1).1)) * hD
  · linear_combination (-(a * (dirVec d1).2)) * hD

/-! ### The spread exclusion -/

/-- **Quantitative spread exclusion.**  Let `L` be product-one-free over
`Heis p` (`p` an odd prime) and let `d₁, d₂, d₃` be three pairwise distinct
directions with class sizes `n₁, n₂, n₃`, `n₁ ≥ p - 1`.  If

`(p - 1 - n₂) + (p - 1 - n₃) + 1 < min p (n₁ - (p - 1) + 1)`,

then a contradiction follows: the `n₁ - (p - 1) + 1` admissible images of the
`d₁`-part cannot all be blocked by the at most `p - 1 - n₂` and `p - 1 - n₃`
sums missing from the two other classes (plus the single image `0`, which would
make the pivot disappear). -/
theorem spread_exclusion (hodd : Odd p) {L : List (Heis p)} (hfree : ProductOneFree L)
    {d1 d2 d3 : Option (ZMod p)} (h12 : d1 ≠ d2) (h13 : d1 ≠ d3) (h23 : d2 ≠ d3)
    (hn1 : p - 1 ≤ (classList L (some d1)).length)
    (hkey : (p - 1 - (classList L (some d2)).length)
          + (p - 1 - (classList L (some d3)).length) + 1
        < min p ((classList L (some d1)).length - (p - 1) + 1)) : False := by
  classical
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  set C1 : List (Heis p) := classList L (some d1) with hC1
  set C2 : List (Heis p) := classList L (some d2) with hC2
  set C3 : List (Heis p) := classList L (some d3) with hC3
  set G : List (Heis p) := C1.take (p - 1) with hG
  set E : List (Heis p) := C1.drop (p - 1) with hE
  have hGE : G ++ E = C1 := List.take_append_drop _ _
  have hGlen : G.length = p - 1 := by rw [hG, List.length_take, Nat.min_eq_left hn1]
  have hElen : E.length = C1.length - (p - 1) := by rw [hE, List.length_drop]
  have hdir1 : ∀ g ∈ C1, dirOf g = d1 := fun g hg => dirOf_of_mem_classList hg
  have hdir2 : ∀ g ∈ C2, dirOf g = d2 := fun g hg => dirOf_of_mem_classList hg
  have hdir3 : ∀ g ∈ C3, dirOf g = d3 := fun g hg => dirOf_of_mem_classList hg
  have hnc1 : ∀ g ∈ C1, ¬ (g.a = 0 ∧ g.b = 0) := fun g hg => not_central_of_mem_classList hg
  have hnc2 : ∀ g ∈ C2, ¬ (g.a = 0 ∧ g.b = 0) := fun g hg => not_central_of_mem_classList hg
  have hnc3 : ∀ g ∈ C3, ¬ (g.a = 0 ∧ g.b = 0) := fun g hg => not_central_of_mem_classList hg
  have hEsub : E.Sublist C1 := List.drop_sublist _ _
  have hnzE : ∀ g ∈ E, coord1 d1 g ≠ 0 := fun g hg =>
    coord1_ne_zero_of_dir (hdir1 g (hEsub.mem hg)) (hnc1 g (hEsub.mem hg))
  have hnz2 : ∀ g ∈ C2, coord1 d2 g ≠ 0 := fun g hg => coord1_ne_zero_of_dir (hdir2 g hg) (hnc2 g hg)
  have hnz3 : ∀ g ∈ C3, coord1 d3 g ≠ 0 := fun g hg => coord1_ne_zero_of_dir (hdir3 g hg) (hnc3 g hg)
  set S1 : Finset (ZMod p) := mapSums (coord1 d1) E with hS1
  set S2 : Finset (ZMod p) := mapSums (coord1 d2) C2 with hS2
  set S3 : Finset (ZMod p) := mapSums (coord1 d3) C3 with hS3
  have hS1card : min p (E.length + 1) ≤ S1.card := card_mapSums_ge _ E hnzE
  have hS2card : min p (C2.length + 1) ≤ S2.card := card_mapSums_ge _ C2 hnz2
  have hS3card : min p (C3.length + 1) ≤ S3.card := card_mapSums_ge _ C3 hnz3
  have hcompl2 : S2.card + S2ᶜ.card = p := by
    have := Finset.card_add_card_compl S2
    rwa [ZMod.card] at this
  have hcompl3 : S3.card + S3ᶜ.card = p := by
    have := Finset.card_add_card_compl S3
    rwa [ZMod.card] at this
  -- the admissible images of the `d₁`-part
  set g0 : ZMod p := (G.map (coord1 d1)).sum with hg0
  set A : Finset (ZMod p) := S1.image (fun e => g0 + e) with hA
  have hAcard : A.card = S1.card :=
    Finset.card_image_of_injective _ (add_right_injective g0)
  set l2 : ZMod p := cramer2 d1 d2 d3 with hl2
  set l3 : ZMod p := cramer3 d1 d2 d3 with hl3
  have hl2ne : l2 ≠ 0 := cramer2_ne_zero h13 h23
  have hl3ne : l3 ≠ 0 := cramer3_ne_zero h12 h23
  -- some admissible image is nonzero and realisable in both other classes
  have hgood : ∃ a ∈ A, a ≠ 0 ∧ l2 * a ∈ S2 ∧ l3 * a ∈ S3 := by
    by_contra hcon
    push_neg at hcon
    have hsub : A ⊆ ({0} : Finset (ZMod p)) ∪ (S2ᶜ.image (fun y => l2⁻¹ * y))
        ∪ (S3ᶜ.image (fun y => l3⁻¹ * y)) := by
      intro a ha
      by_cases h0 : a = 0
      · simp [h0]
      · by_cases h2 : l2 * a ∈ S2
        · have h3 : l3 * a ∉ S3 := hcon a ha h0 h2
          refine Finset.mem_union_right _ (Finset.mem_image.2 ⟨l3 * a, ?_, ?_⟩)
          · simpa using h3
          · field_simp
        · refine Finset.mem_union_left _ (Finset.mem_union_right _
            (Finset.mem_image.2 ⟨l2 * a, ?_, ?_⟩))
          · simpa using h2
          · field_simp
    have hcard := Finset.card_le_card hsub
    have h1 : (({0} : Finset (ZMod p)) ∪ (S2ᶜ.image (fun y => l2⁻¹ * y))
        ∪ (S3ᶜ.image (fun y => l3⁻¹ * y))).card ≤ 1 + S2ᶜ.card + S3ᶜ.card := by
      refine le_trans (Finset.card_union_le _ _) ?_
      have hu : (({0} : Finset (ZMod p)) ∪ (S2ᶜ.image (fun y => l2⁻¹ * y))).card
          ≤ 1 + S2ᶜ.card := by
        refine le_trans (Finset.card_union_le _ _) ?_
        have := Finset.card_image_le (s := S2ᶜ) (f := fun y : ZMod p => l2⁻¹ * y)
        simpa using this
      have := Finset.card_image_le (s := S3ᶜ) (f := fun y : ZMod p => l3⁻¹ * y)
      omega
    omega
  obtain ⟨a, haA, ha0, ha2, ha3⟩ := hgood
  obtain ⟨e, heS1, hea⟩ := Finset.mem_image.1 haA
  -- the `d₁`-part of the block
  obtain ⟨K1, hK1sub, hK1sum⟩ := (mem_mapSums_iff _ _ _).1 heS1
  have hPdir : ∀ g ∈ G ++ K1, dirOf g = d1 := by
    intro g hg
    rcases List.mem_append.1 hg with hg | hg
    · exact hdir1 g ((List.take_sublist _ _).mem hg)
    · exact hdir1 g (hEsub.mem (hK1sub.mem hg))
  have hPcoord : ((G ++ K1).map (coord1 d1)).sum = a := by
    rw [List.map_append, List.sum_append, hK1sum, ← hg0, hea]
  obtain ⟨hPa, hPb⟩ := asum_bsum_of_dir (d := d1) (K := G ++ K1) hPdir
  rw [hPcoord] at hPa hPb
  -- the completion
  obtain ⟨K2, K3, hK2sub, hK3sub, hRa, hRb⟩ :=
    exists_sublists_image_of_mapSums (d := d2) (d' := d3) hdir2 hdir3 ha2 ha3
  obtain ⟨hsolve1, hsolve2⟩ := cramer_solves (d1 := d1) h23 a
  have hRa' : asum (K2 ++ K3) = -(a * (dirVec d1).1) := by
    rw [hRa]; linear_combination hsolve1
  have hRb' : bsum (K2 ++ K3) = -(a * (dirVec d1).2) := by
    rw [hRb]; linear_combination hsolve2
  -- the completion is nonempty, and provides the pivot
  have hRne : K2 ++ K3 ≠ [] := by
    intro hnil
    have h1 : asum (K2 ++ K3) = 0 := by rw [hnil]; rfl
    have h2 : bsum (K2 ++ K3) = 0 := by rw [hnil]; rfl
    rw [hRa'] at h1
    rw [hRb'] at h2
    have hv1 : (dirVec d1).1 = 0 := by
      rcases mul_eq_zero.1 (by linear_combination -h1 : a * (dirVec d1).1 = 0) with h | h
      · exact absurd h ha0
      · exact h
    have hv2 : (dirVec d1).2 = 0 := by
      rcases mul_eq_zero.1 (by linear_combination -h2 : a * (dirVec d1).2 = 0) with h | h
      · exact absurd h ha0
      · exact h
    rcases dirVec_ne_zero d1 with h | h
    · exact h hv1
    · exact h hv2
  obtain ⟨z, R', hzR⟩ := List.exists_cons_of_ne_nil hRne
  have hzmem : z ∈ K2 ++ K3 := by rw [hzR]; exact List.mem_cons_self ..
  have hzdir : dirOf z = d2 ∨ dirOf z = d3 := by
    rcases List.mem_append.1 hzmem with hz | hz
    · exact Or.inl (hdir2 z (hK2sub.mem hz))
    · exact Or.inr (hdir3 z (hK3sub.mem hz))
  have hznc : ¬ (z.a = 0 ∧ z.b = 0) := by
    rcases List.mem_append.1 hzmem with hz | hz
    · exact hnc2 z (hK2sub.mem hz)
    · exact hnc3 z (hK3sub.mem hz)
  -- the spread configuration
  have hGmem : ∀ g ∈ G, g ∈ C1 := fun g hg => (List.take_sublist _ _).mem hg
  have hcomm : ∀ g ∈ G, ∀ h ∈ G, g.a * h.b = h.a * g.b := fun g hg h hh =>
    mul_comm_of_dir_eq (hdir1 g (hGmem g hg)) (hdir1 h (hGmem h hh))
  have htw : ∀ g ∈ G, twist z g ≠ 0 := by
    intro g hg htz
    have hgd := hdir1 g (hGmem g hg)
    have := dirOf_eq_of_twist_eq_zero (hnc1 g (hGmem g hg)) hznc htz
    rw [hgd] at this
    rcases hzdir with hz | hz
    · exact h12 (this.trans hz)
    · exact h13 (this.trans hz)
  -- the image of the whole configuration vanishes
  have hsplit : z :: R' = K2 ++ K3 := hzR.symm
  have hasum : asum (G ++ z :: (R' ++ K1)) = 0 := by
    have h1 : asum (G ++ z :: (R' ++ K1)) = asum G + (z.a + (asum R' + asum K1)) := by
      simp [asum_append]
    have h2 : asum (K2 ++ K3) = z.a + asum R' := by rw [← hsplit]; simp
    have h3 : asum G + asum K1 = a * (dirVec d1).1 := by
      rw [← asum_append]; exact hPa
    rw [h1]
    rw [hRa'] at h2
    linear_combination h3 - h2
  have hbsum : bsum (G ++ z :: (R' ++ K1)) = 0 := by
    have h1 : bsum (G ++ z :: (R' ++ K1)) = bsum G + (z.b + (bsum R' + bsum K1)) := by
      simp [bsum_append]
    have h2 : bsum (K2 ++ K3) = z.b + bsum R' := by rw [← hsplit]; simp
    have h3 : bsum G + bsum K1 = a * (dirVec d1).2 := by
      rw [← bsum_append]; exact hPb
    rw [h1]
    rw [hRb'] at h2
    linear_combination h3 - h2
  -- the configuration is a sub-multiset of `L`
  have hsubperm : (G ++ z :: (R' ++ K1)).Subperm L := by
    have hbase : (G ++ K2 ++ K1 ++ K3).Subperm L := by
      refine subperm_of_split_classes (L := L) (k0 := some d1) (k1 := some d2) (k2 := some d3)
        (by simpa using h12) (by simpa using h13) (by simpa using h23)
        (A0 := G) (A1 := K2) (A2 := K1) (A3 := K3) ?_ ?_ ?_
      · have hsub1 : (G ++ K1).Sublist (G ++ E) := (List.Sublist.refl G).append hK1sub
        rw [hGE] at hsub1
        exact hC1 ▸ hsub1
      · exact hK2sub
      · exact hK3sub
    have hperm : (G ++ z :: (R' ++ K1)).Perm (G ++ K2 ++ K1 ++ K3) := by
      have e0 : G ++ z :: (R' ++ K1) = G ++ ((z :: R') ++ K1) := by simp
      have e1 : (z :: R') ++ K1 = (K2 ++ K3) ++ K1 := by rw [hsplit]
      have e2 : ((K2 ++ K3) ++ K1).Perm (K2 ++ (K1 ++ K3)) := by
        have e2' : ((K2 ++ K3) ++ K1) = K2 ++ (K3 ++ K1) := by simp
        rw [e2']
        exact List.Perm.append_left K2 List.perm_append_comm
      have e3 : G ++ (K2 ++ (K1 ++ K3)) = G ++ K2 ++ K1 ++ K3 := by simp
      rw [e0, e1, ← e3]
      exact List.Perm.append_left G e2
    exact hperm.subperm.trans hbase
  exact not_parallel_spread_of_productOneFree hodd hfree hsubperm hcomm htw
    (by omega) hasum hbsum

end Prime

end Heis

end Heisenberg125