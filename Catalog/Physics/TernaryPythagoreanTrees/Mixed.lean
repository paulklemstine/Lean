import Physics.TernaryPythagoreanTrees.Berggren
import Physics.TernaryPythagoreanTrees.Price

/-!
# A third ternary tree, with *mixed* determinants `2, 1, -2`

The conjecture that Berggren's triple (all determinants `±1`) and Price's triple (all
determinants `±2`) are, up to relabelling, the only ternary trees of integer linear maps on
the node set is **false**.  There is a third one, mixing the two determinant regimes:

* `F₀ (m, n) = (m + 3n, 2n)`,  determinant `2`,
* `F₁ (m, n) = (2m - n, m)`,   determinant `1`   (Berggren's first branch),
* `F₂ (m, n) = (2m, m - n)`,   determinant `-2`  (Price's second branch).

`TernaryTree.mixed_isTernaryTree` proves that this triple is a ternary tree on the node set,
and `TernaryTree.berggren_price_classification_false` records the refutation: the determinant
multiset `{2, 1, -2}` is neither `{±1, ±1, ±1}` nor `{±2, ±2, ±2}`, so the triple is not a
relabelling of Berggren's or Price's.

The descent rule is a *hybrid*: nodes with `m < 2n` descend by `F₁` (ratio rule), while nodes
with `m > 2n` descend by `F₀` or `F₂` according to the parity of `n` (parity rule).
-/

namespace TernaryTree

/-- The first branch of the mixed tree, `(m,n) ↦ (m + 3n, 2n)`, determinant `2`. -/
def mixF0 : IntMap := ⟨1, 3, 0, 2⟩

/-- The mixed triple: determinants `2`, `1`, `-2`. -/
def mixed : Fin 3 → IntMap
  | 0 => mixF0
  | 1 => bergA
  | 2 => priceP1

@[simp] lemma mixF0_det : mixF0.det = 2 := by norm_num [mixF0, IntMap.det]

lemma mixF0_preserves : Preserves mixF0 :=
  preserves_mk (by norm_num) ⟨0, by norm_num⟩ ⟨2, by norm_num⟩ (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)

/-- **The mixed triple is a ternary tree on the node set.** -/
theorem mixed_isTernaryTree : IsTernaryTree mixed where
  preserves i := by
    fin_cases i
    · exact mixF0_preserves
    · exact bergA_preserves
    · exact priceP1_preserves
  root_not_hit := by
    intro i m n hnode h
    have h1 := hnode.one_le
    have h2 := hnode.lt
    fin_cases i <;>
      simp [mixed, mixF0, bergA, priceP1, IntMap.app, Prod.ext_iff] at h <;> omega
  covers := by
    intro m n hnode hne
    have h1 := hnode.one_le
    have h2 := hnode.lt
    have hcop := hnode.cop
    obtain ⟨t, ht⟩ := hnode.odd
    rcases lt_trichotomy m (2 * n) with hlt | heq | hgt
    · -- ratio branch `F₁ = A`: parent `(n, 2n - m)`
      refine ⟨1, n, 2 * n - m, ⟨by omega, by omega, ?_, ⟨2 * n - t - 1, by omega⟩⟩, ?_⟩
      · exact isCoprime_of_unimodular hcop (α := 0) (β := 1) (γ := -1) (δ := 2)
          (by ring) (by ring) (by norm_num)
      · simp [mixed, bergA, IntMap.app]
    · -- `m = 2n` happens only at the root
      have hn1 : n = 1 := eq_one_of_dvd_node hnode (k := 2) (by omega)
      exact absurd (by simp [Prod.ext_iff]; omega) hne
    · rcases Int.even_or_odd n with hn | hn
      · -- `n` even: parity branch `F₀`, parent `(m - 3n/2, n/2)`
        obtain ⟨k, hk⟩ := hn
        have hn2 : n = 2 * k := by omega
        have hcop' : IsCoprime m k := by
          rw [hn2] at hcop; exact hcop.of_mul_right_right
        refine ⟨0, m - 3 * k, k, ⟨by omega, by omega, ?_, ⟨t - 2 * k, by omega⟩⟩, ?_⟩
        · exact isCoprime_of_unimodular hcop' (α := 1) (β := -3) (γ := 0) (δ := 1)
            (by ring) (by ring) (by norm_num)
        · simp [mixed, mixF0, IntMap.app, hn2]
      · -- `n` odd, hence `m` even: parity branch `F₂`, parent `(m/2, m/2 - n)`
        obtain ⟨r, hr⟩ := hn
        obtain ⟨j, hj⟩ : ∃ j, m = 2 * j := ⟨t - r, by omega⟩
        have hcop' : IsCoprime j n := by
          rw [hj] at hcop; exact hcop.of_mul_left_right
        refine ⟨2, j, j - n, ⟨by omega, by omega, ?_, ⟨j - r - 1, by omega⟩⟩, ?_⟩
        · exact isCoprime_of_unimodular hcop' (α := 1) (β := 0) (γ := 1) (δ := -1)
            (by ring) (by ring) (by norm_num)
        · simp [mixed, priceP1, IntMap.app, hj]
  inj := by
    intro i j x y u v hxy huv heq
    have hx1 := hxy.one_le
    have hx2 := hxy.lt
    have hu1 := huv.one_le
    have hu2 := huv.lt
    obtain ⟨s, hs⟩ := hxy.odd
    obtain ⟨w, hw⟩ := huv.odd
    fin_cases i <;> fin_cases j <;>
      simp [mixed, mixF0, bergA, priceP1, IntMap.app, Prod.ext_iff] at heq ⊢ <;> omega

/-- The determinants of the three trees. -/
@[simp] lemma mixed_det_zero : (mixed 0).det = 2 := by simp [mixed]
@[simp] lemma mixed_det_one : (mixed 1).det = 1 := by simp [mixed]
@[simp] lemma mixed_det_two : (mixed 2).det = -2 := by simp [mixed]

/-- **Refutation of the classification conjecture.**  There is a ternary Pythagorean tree
whose determinants are neither all `±1` (Berggren) nor all `±2` (Price); since the multiset
of determinants is invariant under relabelling, this triple is not a relabelling of either
classical tree. -/
theorem berggren_price_classification_false :
    ∃ T : Fin 3 → IntMap, IsTernaryTree T ∧
      ¬ (∀ i, (T i).det = 1 ∨ (T i).det = -1) ∧ ¬ (∀ i, (T i).det = 2 ∨ (T i).det = -2) := by
  refine ⟨mixed, mixed_isTernaryTree, ?_, ?_⟩
  · intro h
    rcases h 0 with h0 | h0 <;> rw [mixed_det_zero] at h0 <;> omega
  · intro h
    rcases h 1 with h1 | h1 <;> rw [mixed_det_one] at h1 <;> omega

/-- Three genuinely different ternary trees exist: Berggren's, Price's and the mixed one. -/
theorem three_ternary_trees :
    IsTernaryTree berg ∧ IsTernaryTree price ∧ IsTernaryTree mixed ∧
      berg ≠ price ∧ berg ≠ mixed ∧ price ≠ mixed := by
  refine ⟨berg_isTernaryTree, price_isTernaryTree, mixed_isTernaryTree, ?_, ?_, ?_⟩
  · intro h
    have := congrArg (fun T => (T 0).det) h
    simp [berg, price] at this
  · intro h
    have := congrArg (fun T => (T 1).det) h
    simp [berg, mixed] at this
  · intro h
    have := congrArg (fun T => (T 1).det) h
    simp [price, mixed] at this

end TernaryTree