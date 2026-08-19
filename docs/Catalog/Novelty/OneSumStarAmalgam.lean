import Mathlib
import Novelty.IndependenceRatioChromatic
import Novelty.IndependenceRatioLowerBound
import Novelty.OneSumEqualityAnalysis

/-!
# Star amalgams: iterated 1-sums at a common cut vertex

`Novelty.OneSumEqualityAnalysis` analysed a single 1-sum `G = G₁ ⊕_v G₂`.  Iterating the
construction at one *fixed* cut vertex gives the **star amalgam** of a finite family
`H : ι → SimpleGraph V`: the parts pairwise meet exactly in `{v}` and cover the vertex set.
This file proves the two structural theorems of the previous file in the `m`-fold setting and
shows how the defect grows.

Main results.

* `SimpleGraph.IsStarSum.colorable` — **colourability is closed under star amalgams**: if every
  part is `k`-colourable, so is the amalgam.  Each part is recoloured by the transposition
  matching its colour at the cut vertex with the colour of a reference part.
* `SimpleGraph.IsStarSum.sum_card_le_indepNum_add` — **the independence defect of an `m`-fold
  amalgam is exactly `m - 1`**: for independent sets `sᵢ ⊆ Aᵢ` of the parts,
  `∑ᵢ |sᵢ| ≤ α(G) + (m - 1)`.
* `SimpleGraph.IsStarSum.indepRatio_ge_of_sides` — the resulting sharp bound on the
  independence ratio: if each side carries an independent set of relative density `r`, then
  `i(G) ≥ r - (m-1)(1-r)/n`.

The companion file `Novelty.StarAmalgamThresholdFamily` shows that this bound is attained for
*every* `m`, by an `m`-fold amalgam of copies of `K₈` minus an edge; letting `m → ∞` drives the
independence ratio of an amalgam of threshold graphs (`i = 1/4`) down to `1/7`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the single-cut defect `1` should accumulate linearly, giving
`m - 1` for an `m`-fold amalgam, and the colouring closure should survive verbatim because a
star amalgam only ever forces *one* colour to be matched per part.
Experiment (Experimenter): the colouring construction chooses, for each vertex `x ≠ v`, the
unique index whose side contains `x` (uniqueness is exactly `Aᵢ ∩ Aⱼ = {v}`), and applies
`Equiv.swap (C i₀ v) (C i v)`.  The independence bound splits on whether *some* part avoids the
cut vertex: if all parts contain it, the plain union works and loses `m - 1`; otherwise erasing
`v` everywhere loses at most `m - 1` as well, because the part avoiding `v` loses nothing.
Analysis (Analyst): both proofs are "one cut vertex at a time" arguments, i.e. the star amalgam
behaves like a tree of 1-sums with all cut vertices identified; the defect is the number of
extra copies of the cut vertex, `m - 1`.
Critique (Critic): `Nonempty ι` is load-bearing in the colouring theorem (an empty family makes
`G = ⊥`, still colourable, but the reference colour `C i₀ v` does not exist); the pairwise
condition `i ≠ j → Aᵢ ∩ Aⱼ = {v}` cannot be weakened to `⋂ᵢ Aᵢ = {v}` — two parts sharing two
vertices break both theorems.
Synthesis (PI): 1-sums act as `max` on colouring invariants and as an additive-with-defect
operation on independence; the defect is the only obstruction to closure of ratio thresholds.
-- !-- end Lab Notes -- !--
-/

open Finset

namespace SimpleGraph

variable {V ι : Type*}

/-- `G` is the **star amalgam** of the family `H` with sides `A`, all glued at the single cut
vertex `v`. -/
structure IsStarSum (G : SimpleGraph V) (H : ι → SimpleGraph V) (A : ι → Set V) (v : V) :
    Prop where
  /-- `G` is the edge-union of the parts. -/
  sup_eq : G = ⨆ i, H i
  /-- The edges of the `i`-th part live inside the `i`-th side. -/
  support : ∀ i ⦃x y⦄, (H i).Adj x y → x ∈ A i ∧ y ∈ A i
  /-- Two distinct sides meet exactly in the cut vertex. -/
  inter_eq : ∀ i j, i ≠ j → A i ∩ A j = {v}
  /-- Every side contains the cut vertex. -/
  cut_mem : ∀ i, v ∈ A i
  /-- The sides cover the vertex set. -/
  union_eq : (⋃ i, A i) = Set.univ

namespace IsStarSum

variable {G : SimpleGraph V} {H : ι → SimpleGraph V} {A : ι → Set V} {v : V}
variable (h : IsStarSum G H A v)
include h

theorem adj_iff {x y : V} : G.Adj x y ↔ ∃ i, (H i).Adj x y := by
  rw [h.sup_eq]
  simp [SimpleGraph.iSup_adj]

theorem le (i : ι) : H i ≤ G := by
  intro x y hxy
  exact h.adj_iff.2 ⟨i, hxy⟩

/-- A vertex on two distinct sides is the cut vertex. -/
theorem eq_cut_of_mem_two {x : V} {i j : ι} (hij : i ≠ j) (hi : x ∈ A i) (hj : x ∈ A j) :
    x = v := by
  have : x ∈ A i ∩ A j := ⟨hi, hj⟩
  rwa [h.inter_eq i j hij, Set.mem_singleton_iff] at this

/-- Off the cut vertex, the side containing a vertex is unique. -/
theorem side_unique {x : V} (hx : x ≠ v) {i j : ι} (hi : x ∈ A i) (hj : x ∈ A j) : i = j := by
  by_contra hij
  exact hx (h.eq_cut_of_mem_two hij hi hj)

theorem exists_side (x : V) : ∃ i, x ∈ A i := by
  have : x ∈ ⋃ i, A i := by rw [h.union_eq]; trivial
  simpa using this

/-- **Colourability is closed under star amalgams.**  If every part of an `m`-fold
amalgamation is `k`-colourable, so is the amalgam. -/
theorem colorable [Nonempty ι] {k : ℕ} (hk : ∀ i, (H i).Colorable k) : G.Colorable k := by
  classical
  let C : ∀ i, (H i).Coloring (Fin k) := fun i => (hk i).some
  let i₀ : ι := Classical.arbitrary ι
  let idx : V → ι := fun x => (h.exists_side x).choose
  have hidx : ∀ x, x ∈ A (idx x) := fun x => (h.exists_side x).choose_spec
  let col : V → Fin k := fun x =>
    if x = v then C i₀ v else Equiv.swap (C i₀ v) (C (idx x) v) (C (idx x) x)
  refine ⟨SimpleGraph.Coloring.mk col ?_⟩
  intro x y hxy
  obtain ⟨i, hi⟩ := h.adj_iff.1 hxy
  have hxA : x ∈ A i := (h.support i hi).1
  have hyA : y ∈ A i := (h.support i hi).2
  have hne : x ≠ y := hi.ne
  by_cases hxv : x = v
  · -- the cut vertex against a vertex of the `i`-th side
    have hyv : y ≠ v := fun hy => hne (hxv.trans hy.symm)
    have hyi : idx y = i := h.side_unique hyv (hidx y) hyA
    have hvy : (H i).Adj v y := hxv ▸ hi
    simp only [col, if_pos hxv, if_neg hyv]
    rw [hyi]
    intro hcon
    have hswap : Equiv.swap (C i₀ v) (C i v) (C i v) = C i₀ v := Equiv.swap_apply_right _ _
    have hinj := (Equiv.swap (C i₀ v) (C i v)).injective
    have : C i y = C i v := hinj (by rw [hswap]; exact hcon.symm)
    exact (C i).valid hvy this.symm
  · by_cases hyv : y = v
    · have hxi : idx x = i := h.side_unique hxv (hidx x) hxA
      have hxvadj : (H i).Adj x v := hyv ▸ hi
      simp only [col, if_neg hxv, if_pos hyv]
      rw [hxi]
      intro hcon
      have hswap : Equiv.swap (C i₀ v) (C i v) (C i v) = C i₀ v := Equiv.swap_apply_right _ _
      have hinj := (Equiv.swap (C i₀ v) (C i v)).injective
      have : C i x = C i v := hinj (by rw [hswap]; exact hcon)
      exact (C i).valid hxvadj this
    · have hxi : idx x = i := h.side_unique hxv (hidx x) hxA
      have hyi : idx y = i := h.side_unique hyv (hidx y) hyA
      simp only [col, if_neg hxv, if_neg hyv]
      rw [hxi, hyi]
      intro hcon
      exact (C i).valid hi ((Equiv.swap (C i₀ v) (C i v)).injective hcon)

variable [Fintype V] [DecidableEq V] [Fintype ι] [DecidableEq ι]

omit [Fintype V] [DecidableEq ι] in
/-- **Union lemma for star amalgams.**  A family of independent sets of the parts, each living
on its own side and none containing the cut vertex, glues to an independent set. -/
theorem isIndepSet_biUnion_erase {s : ι → Finset V} (hs : ∀ i, ↑(s i) ⊆ A i)
    (hi : ∀ i, (H i).IsIndepSet ↑(s i)) :
    G.IsIndepSet ↑(Finset.univ.biUnion (fun i => (s i).erase v)) := by
  intro x hx y hy hne hadj
  obtain ⟨i, -, hxi⟩ := Finset.mem_biUnion.1 (Finset.mem_coe.1 hx)
  obtain ⟨j, -, hyj⟩ := Finset.mem_biUnion.1 (Finset.mem_coe.1 hy)
  have hxv : x ≠ v := Finset.ne_of_mem_erase hxi
  have hyv : y ≠ v := Finset.ne_of_mem_erase hyj
  have hxs : x ∈ s i := Finset.mem_of_mem_erase hxi
  have hys : y ∈ s j := Finset.mem_of_mem_erase hyj
  obtain ⟨l, hl⟩ := h.adj_iff.1 hadj
  have hxl : x ∈ A l := (h.support l hl).1
  have hyl : y ∈ A l := (h.support l hl).2
  have hil : i = l := h.side_unique hxv (hs i hxs) hxl
  have hjl : j = l := h.side_unique hyv (hs j hys) hyl
  rw [hil] at hxs
  rw [hjl] at hys
  exact hi l (Finset.mem_coe.2 hxs) (Finset.mem_coe.2 hys) hne hl

omit [Fintype V] [DecidableEq ι] in
/-- **Union lemma for star amalgams, all parts through the cut vertex.** -/
theorem isIndepSet_biUnion {s : ι → Finset V} (hs : ∀ i, ↑(s i) ⊆ A i)
    (hi : ∀ i, (H i).IsIndepSet ↑(s i)) (hv : ∀ i, v ∈ s i) :
    G.IsIndepSet ↑(Finset.univ.biUnion s) := by
  intro x hx y hy hne hadj
  obtain ⟨i, -, hxi⟩ := Finset.mem_biUnion.1 (Finset.mem_coe.1 hx)
  obtain ⟨j, -, hyj⟩ := Finset.mem_biUnion.1 (Finset.mem_coe.1 hy)
  obtain ⟨l, hl⟩ := h.adj_iff.1 hadj
  have hxl : x ∈ A l := (h.support l hl).1
  have hyl : y ∈ A l := (h.support l hl).2
  have hxl' : x ∈ s l := by
    by_cases hxv : x = v
    · exact hxv ▸ hv l
    · exact (h.side_unique hxv (hs i hxi) hxl) ▸ hxi
  have hyl' : y ∈ s l := by
    by_cases hyv : y = v
    · exact hyv ▸ hv l
    · exact (h.side_unique hyv (hs j hyj) hyl) ▸ hyj
  exact hi l (Finset.mem_coe.2 hxl') (Finset.mem_coe.2 hyl') hne hl

/-- **The independence defect of an `m`-fold star amalgam is `m - 1`.**  For independent sets
`sᵢ` of the parts living on their own sides, `∑ᵢ |sᵢ| ≤ α(G) + (m - 1)` where `m = |ι|`. -/
theorem sum_card_le_indepNum_add [Nonempty ι] {s : ι → Finset V} (hs : ∀ i, ↑(s i) ⊆ A i)
    (hi : ∀ i, (H i).IsIndepSet ↑(s i)) :
    ∑ i, (s i).card ≤ G.indepNum + (Fintype.card ι - 1) := by
  classical
  have hdisj : ∀ i j : ι, i ≠ j → Disjoint ((s i).erase v) ((s j).erase v) := by
    intro i j hij
    refine Finset.disjoint_left.2 fun x hx hx2 => ?_
    have hxv : x = v :=
      h.eq_cut_of_mem_two hij (hs i (Finset.mem_of_mem_erase hx)) (hs j (Finset.mem_of_mem_erase hx2))
    exact (Finset.ne_of_mem_erase hx) hxv
  have hcard_biUnion : (Finset.univ.biUnion (fun i => (s i).erase v)).card
      = ∑ i, ((s i).erase v).card := by
    refine Finset.card_biUnion ?_
    intro i _ j _ hij
    exact hdisj i j hij
  by_cases hall : ∀ i, v ∈ s i
  · -- every part uses the cut vertex: the plain union loses exactly `m - 1`
    have hindep := h.isIndepSet_biUnion hs hi hall
    have hcard : (Finset.univ.biUnion s).card ≥ ∑ i, ((s i).erase v).card + 1 := by
      have hsub : Finset.univ.biUnion (fun i => (s i).erase v) ∪ {v} ⊆ Finset.univ.biUnion s := by
        intro x hx
        simp only [Finset.mem_union, Finset.mem_biUnion, Finset.mem_univ, true_and,
          Finset.mem_singleton] at hx
        rcases hx with ⟨i, hxi⟩ | rfl
        · exact Finset.mem_biUnion.2 ⟨i, Finset.mem_univ i, Finset.mem_of_mem_erase hxi⟩
        · exact Finset.mem_biUnion.2
            ⟨Classical.arbitrary ι, Finset.mem_univ _, hall (Classical.arbitrary ι)⟩
      have hdisj' : Disjoint (Finset.univ.biUnion (fun i => (s i).erase v)) ({v} : Finset V) := by
        refine Finset.disjoint_right.2 fun x hx hx2 => ?_
        simp only [Finset.mem_singleton] at hx
        subst hx
        simp only [Finset.mem_biUnion, Finset.mem_univ, true_and] at hx2
        obtain ⟨i, hi'⟩ := hx2
        exact (Finset.ne_of_mem_erase hi') rfl
      calc ∑ i, ((s i).erase v).card + 1
          = (Finset.univ.biUnion (fun i => (s i).erase v) ∪ {v}).card := by
            rw [Finset.card_union_of_disjoint hdisj', hcard_biUnion, Finset.card_singleton]
        _ ≤ (Finset.univ.biUnion s).card := Finset.card_le_card hsub
    have hle := hindep.card_le_indepNum
    have hsum2 : ∑ i, (s i).card = ∑ i, (((s i).erase v).card + 1) := by
      refine Finset.sum_congr rfl fun i _ => ?_
      rw [Finset.card_erase_of_mem (hall i)]
      have : 1 ≤ (s i).card := Finset.card_pos.2 ⟨v, hall i⟩
      omega
    rw [Finset.sum_add_distrib] at hsum2
    simp only [Finset.sum_const, Finset.card_univ, smul_eq_mul, mul_one] at hsum2
    have hm : 1 ≤ Fintype.card ι := Fintype.card_pos
    omega
  · -- some part avoids the cut vertex, so erasing it everywhere loses at most `m - 1`
    push_neg at hall
    obtain ⟨j, hj⟩ := hall
    have hindep := h.isIndepSet_biUnion_erase hs hi
    have hle := hindep.card_le_indepNum
    rw [hcard_biUnion] at hle
    have hterm : ∀ i, (s i).card ≤ ((s i).erase v).card + 1 := by
      intro i
      by_cases hv : v ∈ s i
      · rw [Finset.card_erase_of_mem hv]
        have : 1 ≤ (s i).card := Finset.card_pos.2 ⟨v, hv⟩
        omega
      · rw [Finset.erase_eq_of_notMem hv]
        omega
    have hjterm : (s j).card = ((s j).erase v).card := by
      rw [Finset.erase_eq_of_notMem hj]
    have hsum : ∑ i, (s i).card
        ≤ ∑ i, ((s i).erase v).card + (Fintype.card ι - 1) := by
      have hsplit : ∑ i, (s i).card
          = (s j).card + ∑ i ∈ Finset.univ.erase j, (s i).card := by
        rw [← Finset.add_sum_erase _ _ (Finset.mem_univ j)]
      have hsplit' : ∑ i, ((s i).erase v).card
          = ((s j).erase v).card + ∑ i ∈ Finset.univ.erase j, ((s i).erase v).card := by
        rw [← Finset.add_sum_erase _ _ (Finset.mem_univ j)]
      have hrest : ∑ i ∈ Finset.univ.erase j, (s i).card
          ≤ ∑ i ∈ Finset.univ.erase j, (((s i).erase v).card + 1) :=
        Finset.sum_le_sum fun i _ => hterm i
      have hcount : ∑ i ∈ Finset.univ.erase j, (((s i).erase v).card + 1)
          = (∑ i ∈ Finset.univ.erase j, ((s i).erase v).card) + (Fintype.card ι - 1) := by
        rw [Finset.sum_add_distrib]
        simp [Finset.card_erase_of_mem, Finset.card_univ]
      omega
    omega

/-- **The sharp ratio bound for an `m`-fold star amalgam.**  If each side carries an
independent set of relative density at least `r`, then `i(G) ≥ r - (m-1)(1-r)/n`. -/
theorem indepRatio_ge_of_sides [Nonempty ι] [∀ i, DecidablePred (· ∈ A i)]
    {s : ι → Finset V} (hs : ∀ i, ↑(s i) ⊆ A i) (hi : ∀ i, (H i).IsIndepSet ↑(s i))
    {r : ℚ}
    (hr : ∀ i, r * ((Finset.univ.filter (· ∈ A i)).card : ℚ) ≤ ((s i).card : ℚ))
    (hcover : (Fintype.card V : ℚ) + (Fintype.card ι - 1 : ℕ)
      = ∑ i, ((Finset.univ.filter (· ∈ A i)).card : ℚ))
    (hpos : 0 < Fintype.card V) :
    r - ((Fintype.card ι - 1 : ℕ) : ℚ) * (1 - r) / (Fintype.card V : ℚ) ≤ G.indepRatio := by
  have hn : (0 : ℚ) < (Fintype.card V : ℚ) := by exact_mod_cast hpos
  have hsum : ∑ i, ((s i).card : ℚ) ≤ (G.indepNum : ℚ) + ((Fintype.card ι - 1 : ℕ) : ℚ) := by
    have := h.sum_card_le_indepNum_add hs hi
    exact_mod_cast this
  have hlow : r * ((Fintype.card V : ℚ) + ((Fintype.card ι - 1 : ℕ) : ℚ))
      ≤ ∑ i, ((s i).card : ℚ) := by
    calc r * ((Fintype.card V : ℚ) + ((Fintype.card ι - 1 : ℕ) : ℚ))
        = ∑ i, r * ((Finset.univ.filter (· ∈ A i)).card : ℚ) := by
          rw [hcover, Finset.mul_sum]
      _ ≤ ∑ i, ((s i).card : ℚ) := Finset.sum_le_sum fun i _ => hr i
  have hkey : r * ((Fintype.card V : ℚ) + ((Fintype.card ι - 1 : ℕ) : ℚ))
      - ((Fintype.card ι - 1 : ℕ) : ℚ) ≤ (G.indepNum : ℚ) := by
    linarith
  rw [SimpleGraph.indepRatio, le_div_iff₀ hn, sub_mul, div_mul_cancel₀ _ (ne_of_gt hn)]
  nlinarith [hkey]

section Invariants

variable [Nonempty ι]

omit [DecidableEq V] [DecidableEq ι] in
/-- **The chromatic number of a star amalgam is the maximum over the parts.** -/
theorem chromaticNumber_eq_sup :
    G.chromaticNumber = Finset.univ.sup (fun i => (H i).chromaticNumber) := by
  classical
  have hfin : ∀ i, (H i).chromaticNumber ≠ ⊤ := by
    intro i hcon
    have := chromaticNumber_le_iff_colorable.2 (H i).colorable_of_fintype
    rw [hcon] at this
    exact absurd (top_le_iff.1 this) (by simp)
  have hcoe : ∀ i, ((H i).chromaticNumber.toNat : ℕ∞) = (H i).chromaticNumber :=
    fun i => ENat.coe_toNat (hfin i)
  set n : ℕ := Finset.univ.sup (fun i => (H i).chromaticNumber.toNat) with hn
  have hcolor : ∀ i, (H i).Colorable n := by
    intro i
    refine chromaticNumber_le_iff_colorable.1 ?_
    rw [← hcoe i]
    exact_mod_cast Finset.le_sup (f := fun i => (H i).chromaticNumber.toNat) (Finset.mem_univ i)
  refine le_antisymm ?_ (Finset.sup_le fun i _ => chromaticNumber_mono G (h.le i))
  obtain ⟨j, -, hj⟩ := Finset.exists_mem_eq_sup (Finset.univ : Finset ι) Finset.univ_nonempty
    (fun i => (H i).chromaticNumber.toNat)
  calc G.chromaticNumber ≤ (n : ℕ∞) := chromaticNumber_le_iff_colorable.2 (h.colorable hcolor)
    _ = (H j).chromaticNumber := by rw [hn, hj, hcoe j]
    _ ≤ Finset.univ.sup (fun i => (H i).chromaticNumber) :=
          Finset.le_sup (f := fun i => (H i).chromaticNumber) (Finset.mem_univ j)

omit [Fintype V] [DecidableEq V] [Fintype ι] [DecidableEq ι] in
/-- **A clique of a star amalgam lies inside a single side.** -/
theorem exists_isClique_side {s : Set V} (hs : G.IsClique s) :
    ∃ i, s ⊆ A i ∧ (H i).IsClique s := by
  classical
  by_cases hsv : ∀ x ∈ s, x = v
  · refine ⟨Classical.arbitrary ι, fun x hx => (hsv x hx) ▸ h.cut_mem _, ?_⟩
    intro x hx y hy hne
    exact absurd ((hsv x hx).trans (hsv y hy).symm) hne
  · push_neg at hsv
    obtain ⟨x₀, hx₀s, hx₀v⟩ := hsv
    obtain ⟨i, hi⟩ := h.exists_side x₀
    have hsub : s ⊆ A i := by
      intro y hy
      by_cases hyv : y = v
      · exact hyv ▸ h.cut_mem i
      · obtain ⟨j, hj⟩ := h.exists_side y
        by_cases hxy : x₀ = y
        · exact hxy ▸ hi
        · obtain ⟨l, hl⟩ := h.adj_iff.1 (hs hx₀s hy hxy)
          have hxl : x₀ ∈ A l := (h.support l hl).1
          have hyl : y ∈ A l := (h.support l hl).2
          have : l = i := h.side_unique hx₀v hxl hi
          exact this ▸ hyl
    refine ⟨i, hsub, ?_⟩
    intro x hx y hy hne
    obtain ⟨l, hl⟩ := h.adj_iff.1 (hs hx hy hne)
    have hxl : x ∈ A l := (h.support l hl).1
    have hyl : y ∈ A l := (h.support l hl).2
    by_cases hli : l = i
    · exact hli ▸ hl
    · have hxv : x = v := h.eq_cut_of_mem_two hli hxl (hsub hx)
      have hyv : y = v := h.eq_cut_of_mem_two hli hyl (hsub hy)
      exact absurd (hxv.trans hyv.symm) hne

omit [DecidableEq V] [DecidableEq ι] in
/-- **The clique number of a star amalgam is the maximum over the parts.** -/
theorem cliqueNum_eq_sup : G.cliqueNum = Finset.univ.sup (fun i => (H i).cliqueNum) := by
  classical
  refine le_antisymm ?_ (Finset.sup_le fun i _ => ?_)
  · obtain ⟨s, hs, hcard⟩ := G.exists_isNClique_cliqueNum
    obtain ⟨i, -, hsi⟩ := h.exists_isClique_side hs
    exact hcard ▸ le_trans (IsClique.card_le_cliqueNum (tc := hsi))
      (Finset.le_sup (f := fun i => (H i).cliqueNum) (Finset.mem_univ i))
  · obtain ⟨s, hs, hcard⟩ := (H i).exists_isNClique_cliqueNum
    exact hcard ▸ IsClique.card_le_cliqueNum (tc := hs.mono (h.le i))

omit [DecidableEq V] [DecidableEq ι] in
/-- **Weak perfection (`χ = ω`) is closed under star amalgams.** -/
theorem chromaticNumber_eq_cliqueNum
    (hpart : ∀ i, (H i).chromaticNumber = ((H i).cliqueNum : ℕ∞)) :
    G.chromaticNumber = (G.cliqueNum : ℕ∞) := by
  classical
  rw [h.chromaticNumber_eq_sup, h.cliqueNum_eq_sup]
  obtain ⟨j, -, hj⟩ := Finset.exists_mem_eq_sup (Finset.univ : Finset ι) Finset.univ_nonempty
    (fun i => (H i).cliqueNum)
  rw [hj]
  refine le_antisymm (Finset.sup_le fun i _ => ?_) ?_
  · rw [hpart i]
    have hle : (H i).cliqueNum ≤ (H j).cliqueNum :=
      hj ▸ Finset.le_sup (f := fun i => (H i).cliqueNum) (Finset.mem_univ i)
    exact_mod_cast hle
  · rw [← hpart j]
    exact Finset.le_sup (f := fun i => (H i).chromaticNumber) (Finset.mem_univ j)

end Invariants

end IsStarSum

end SimpleGraph