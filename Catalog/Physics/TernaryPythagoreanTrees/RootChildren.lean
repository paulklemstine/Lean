import Physics.TernaryPythagoreanTrees.Images

/-!
# Which map can send the root to a given small node?

The classification of ternary trees rests on the following rigidity: the image of the root
`(2,1)` under a node preserving map determines the map up to a very short list.  Each proof is
a finite case analysis: the cone conditions bound `c`, the parity condition ties `a` to `c`,
and the determinant condition (no odd prime divisor, nonzero) removes the remaining cases.

* `root_child_cases_32` : `M (2,1) = (3,2)` forces `M ∈ {bergA, priceP0}`.
* `root_child_cases_41` : `M (2,1) = (4,1)` forces `M ∈ {bergC, priceP1}`.
* `root_child_cases_43` : `M (2,1) = (4,3)` forces `M ∈ {priceP2, exotic32}`.
* `root_child_cases_52` : `M (2,1) = (5,2)` forces `M ∈ {mixF0, bergB, exotic52}`.

Here `exotic32 = (3,-2;2,-1)` and `exotic52 = (3,-1;2,-2)` are two further node preserving
maps (determinants `1` and `-4`) which are not branches of any ternary tree — they are
eliminated later, in the classification proof.
-/

namespace TernaryTree

/-- A node preserving map of determinant `1` sending the root to `(4,3)`. -/
def exotic32 : IntMap := ⟨3, -2, 2, -1⟩
/-- A node preserving map of determinant `-4` sending the root to `(5,2)`. -/
def exotic52 : IntMap := ⟨3, -1, 2, -2⟩

@[simp] lemma exotic32_det : exotic32.det = 1 := by norm_num [exotic32, IntMap.det]
@[simp] lemma exotic52_det : exotic52.det = -4 := by norm_num [exotic52, IntMap.det]

lemma exotic32_preserves : Preserves exotic32 :=
  preserves_mk (by norm_num) ⟨2, by norm_num⟩ ⟨-2, by norm_num⟩ (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)

private lemma three_dvd_absurd {M : IntMap} (hM : Preserves M) (h : (3 : ℤ) ∣ M.det) : False :=
  hM.not_odd_prime_dvd_det (p := 3) (by norm_num) (by decide) h

/-- `M (2,1) = (3,2)` forces `M` to be Berggren's `A` or Price's `P₀`. -/
lemma root_child_cases_32 {M : IntMap} (hM : Preserves M) (h : M.app 2 1 = (3, 2)) :
    M = bergA ∨ M = priceP0 := by
  have hA := (preserves_iff M).1 hM
  have h1 : 2 * M.a + M.b = 3 := by
    have := congrArg Prod.fst h; simp [IntMap.app] at this; omega
  have h2 : 2 * M.c + M.d = 2 := by
    have := congrArg Prod.snd h; simp [IntMap.app] at this; omega
  have hc := hA.c_nonneg
  have hcd := hA.cd_nonneg
  have hac := hA.ac_nonneg
  have hdiff := hA.diff_nonneg
  obtain ⟨k, hk⟩ := hA.parity_ac
  have hdet := hM.det_ne_zero
  have hc2 : M.c ≤ 2 := by omega
  have haa : M.a = M.c + 1 := by omega
  obtain ⟨a, b, c, d⟩ := M
  simp only at h1 h2 hc hcd hac hdiff hk haa hdet ⊢
  interval_cases c
  · right
    have : a = 1 := by omega
    simp [priceP0, IntMap.mk.injEq]; omega
  · left
    have : a = 2 := by omega
    simp [bergA, IntMap.mk.injEq]; omega
  · exfalso
    have ha : a = 3 := by omega
    have hb : b = -3 := by omega
    have hd : d = -2 := by omega
    rw [ha, hb, hd] at hdet
    simp [IntMap.det] at hdet

/-- `M (2,1) = (4,1)` forces `M` to be Berggren's `C` or Price's `P₁`. -/
lemma root_child_cases_41 {M : IntMap} (hM : Preserves M) (h : M.app 2 1 = (4, 1)) :
    M = bergC ∨ M = priceP1 := by
  have hA := (preserves_iff M).1 hM
  have h1 : 2 * M.a + M.b = 4 := by
    have := congrArg Prod.fst h; simp [IntMap.app] at this; omega
  have h2 : 2 * M.c + M.d = 1 := by
    have := congrArg Prod.snd h; simp [IntMap.app] at this; omega
  have hc := hA.c_nonneg
  have hcd := hA.cd_nonneg
  have hac := hA.ac_nonneg
  have hdiff := hA.diff_nonneg
  obtain ⟨k, hk⟩ := hA.parity_ac
  have hdet := hM.det_ne_zero
  have hpos := hM.a_pos
  have h3 := fun hh => three_dvd_absurd hM hh
  have hc1 : M.c ≤ 1 := by omega
  have haub : M.a ≤ M.c + 3 := by omega
  obtain ⟨a, b, c, d⟩ := M
  simp only [IntMap.det] at hdet h3
  simp only at h1 h2 hc hcd hac hdiff hk hpos hc1 haub ⊢
  interval_cases c
  · -- c = 0, a odd, 1 ≤ a ≤ 3
    interval_cases a
    · left
      simp [bergC, IntMap.mk.injEq]; omega
    · exfalso; omega
    · exfalso
      have hb : b = -2 := by omega
      have hd : d = 1 := by omega
      exact h3 ⟨1, by rw [hb, hd]; ring⟩
  · -- c = 1, a even, 1 ≤ a ≤ 4
    interval_cases a
    · exfalso; omega
    · right
      simp [priceP1, IntMap.mk.injEq]; omega
    · exfalso; omega
    · exfalso
      have hb : b = -4 := by omega
      have hd : d = -1 := by omega
      rw [hb, hd] at hdet
      simp at hdet

/-- `M (2,1) = (4,3)` forces `M` to be Price's `P₂` or the exotic map `(3,-2;2,-1)`. -/
lemma root_child_cases_43 {M : IntMap} (hM : Preserves M) (h : M.app 2 1 = (4, 3)) :
    M = priceP2 ∨ M = exotic32 := by
  have hA := (preserves_iff M).1 hM
  have h1 : 2 * M.a + M.b = 4 := by
    have := congrArg Prod.fst h; simp [IntMap.app] at this; omega
  have h2 : 2 * M.c + M.d = 3 := by
    have := congrArg Prod.snd h; simp [IntMap.app] at this; omega
  have hc := hA.c_nonneg
  have hcd := hA.cd_nonneg
  have hac := hA.ac_nonneg
  have hdiff := hA.diff_nonneg
  obtain ⟨k, hk⟩ := hA.parity_ac
  have hdet := hM.det_ne_zero
  have h3 := fun hh => three_dvd_absurd hM hh
  have hc3 : M.c ≤ 3 := by omega
  have haa : M.a = M.c + 1 := by omega
  obtain ⟨a, b, c, d⟩ := M
  simp only [IntMap.det] at hdet h3
  simp only at h1 h2 hc hcd hac hdiff hk haa ⊢
  interval_cases c
  · exfalso
    have ha : a = 1 := by omega
    have hb : b = 2 := by omega
    have hd : d = 3 := by omega
    exact h3 ⟨1, by rw [ha, hb, hd]; ring⟩
  · left
    have ha : a = 2 := by omega
    simp [priceP2, IntMap.mk.injEq]; omega
  · right
    have ha : a = 3 := by omega
    simp [exotic32, IntMap.mk.injEq]; omega
  · exfalso
    have ha : a = 4 := by omega
    have hb : b = -4 := by omega
    have hd : d = -3 := by omega
    rw [ha, hb, hd] at hdet
    simp at hdet

/-- `M (2,1) = (5,2)` forces `M` to be `mixF0`, Berggren's `B`, or the exotic map
`(3,-1;2,-2)`. -/
lemma root_child_cases_52 {M : IntMap} (hM : Preserves M) (h : M.app 2 1 = (5, 2)) :
    M = mixF0 ∨ M = bergB ∨ M = exotic52 := by
  have hA := (preserves_iff M).1 hM
  have h1 : 2 * M.a + M.b = 5 := by
    have := congrArg Prod.fst h; simp [IntMap.app] at this; omega
  have h2 : 2 * M.c + M.d = 2 := by
    have := congrArg Prod.snd h; simp [IntMap.app] at this; omega
  have hc := hA.c_nonneg
  have hcd := hA.cd_nonneg
  have hac := hA.ac_nonneg
  have hdiff := hA.diff_nonneg
  obtain ⟨k, hk⟩ := hA.parity_ac
  have hdet := hM.det_ne_zero
  have hpos := hM.a_pos
  have h3 := fun hh => three_dvd_absurd hM hh
  have hc2 : M.c ≤ 2 := by omega
  have haub : M.a ≤ M.c + 3 := by omega
  obtain ⟨a, b, c, d⟩ := M
  simp only [IntMap.det] at hdet h3
  simp only at h1 h2 hc hcd hac hdiff hk hpos hc2 haub ⊢
  interval_cases c
  · interval_cases a
    · left
      simp [mixF0, IntMap.mk.injEq]; omega
    · exfalso; omega
    · exfalso
      have hb : b = -1 := by omega
      have hd : d = 2 := by omega
      exact h3 ⟨2, by rw [hb, hd]; ring⟩
  · interval_cases a
    · exfalso; omega
    · right; left
      simp [bergB, IntMap.mk.injEq]; omega
    · exfalso; omega
    · exfalso
      have hb : b = -3 := by omega
      have hd : d = 0 := by omega
      exact h3 ⟨1, by rw [hb, hd]; ring⟩
  · interval_cases a
    · exfalso; omega
    · exfalso; omega
    · right; right
      simp [exotic52, IntMap.mk.injEq]; omega
    · exfalso; omega
    · exfalso
      have hb : b = -5 := by omega
      have hd : d = -2 := by omega
      rw [hb, hd] at hdet
      simp at hdet

end TernaryTree