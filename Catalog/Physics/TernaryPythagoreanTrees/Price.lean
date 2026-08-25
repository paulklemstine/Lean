import Physics.TernaryPythagoreanTrees.Tree

/-!
# The Price tree (determinants `±2`)

Price's triple, in Euclid parameters `(m, n)`:

* `P₀ (m, n) = (m + n, 2n)`,   determinant `2`,
* `P₁ (m, n) = (2m, m - n)`,   determinant `-2`,
* `P₂ (m, n) = (2m, m + n)`,   determinant `2`.

We prove that these three maps organise the node set into a ternary tree rooted at `(2,1)`
(`TernaryTree.price_isTernaryTree`).

The descent is by *parity and halving* rather than by ratio: if `n` is even the parent is
`(m - n/2, n/2)`; if `n` is odd then `m` is even and the parent is `(m/2, |m/2 - n|)`, the
sign distinguishing the branches `P₁` and `P₂`.  Note that every map here has `|det| = 2`,
so this is a genuine determinant-`2` tree.
-/

namespace TernaryTree

/-- Price's first branch `(m,n) ↦ (m + n, 2n)`, determinant `2`. -/
def priceP0 : IntMap := ⟨1, 1, 0, 2⟩
/-- Price's second branch `(m,n) ↦ (2m, m - n)`, determinant `-2`. -/
def priceP1 : IntMap := ⟨2, 0, 1, -1⟩
/-- Price's third branch `(m,n) ↦ (2m, m + n)`, determinant `2`. -/
def priceP2 : IntMap := ⟨2, 0, 1, 1⟩

/-- The Price triple. -/
def price : Fin 3 → IntMap
  | 0 => priceP0
  | 1 => priceP1
  | 2 => priceP2

@[simp] lemma priceP0_det : priceP0.det = 2 := by norm_num [priceP0, IntMap.det]
@[simp] lemma priceP1_det : priceP1.det = -2 := by norm_num [priceP1, IntMap.det]
@[simp] lemma priceP2_det : priceP2.det = 2 := by norm_num [priceP2, IntMap.det]

/-- A convenient sufficient criterion for node preservation of an explicit matrix. -/
lemma preserves_mk' {a b c d : ℤ}
    (hdet : a * d - b * c = 1 ∨ a * d - b * c = -1 ∨ a * d - b * c = 2 ∨ a * d - b * c = -2)
    (h1 : Odd (a + c)) (h2 : Odd (b + d)) (h3 : 0 ≤ c) (h4 : 0 ≤ c + d)
    (h5 : ¬(c = 0 ∧ d = 0)) (h6 : 0 ≤ a - c) (h7 : 0 ≤ (a - c) + (b - d))
    (h8 : ¬(a - c = 0 ∧ b - d = 0)) : Preserves ⟨a, b, c, d⟩ :=
  (preserves_iff _).2
    ⟨h1, h2, no_odd_prime_dvd_of_det_small (M := ⟨a, b, c, d⟩) (by simpa [IntMap.det] using hdet),
      h3, h4, h5, h6, h7, h8⟩

lemma priceP0_preserves : Preserves priceP0 :=
  preserves_mk' (by norm_num) ⟨0, by norm_num⟩ ⟨1, by norm_num⟩ (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)

lemma priceP1_preserves : Preserves priceP1 :=
  preserves_mk' (by norm_num) ⟨1, by norm_num⟩ ⟨-1, by norm_num⟩ (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)

lemma priceP2_preserves : Preserves priceP2 :=
  preserves_mk' (by norm_num) ⟨1, by norm_num⟩ ⟨0, by norm_num⟩ (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)

/-- **The Price triple is a ternary tree on the node set.** -/
theorem price_isTernaryTree : IsTernaryTree price where
  preserves i := by
    fin_cases i
    · exact priceP0_preserves
    · exact priceP1_preserves
    · exact priceP2_preserves
  root_not_hit := by
    intro i m n hnode h
    have h1 := hnode.one_le
    have h2 := hnode.lt
    fin_cases i <;>
      simp [price, priceP0, priceP1, priceP2, IntMap.app, Prod.ext_iff] at h <;> omega
  covers := by
    intro m n hnode hne
    have h1 := hnode.one_le
    have h2 := hnode.lt
    have hcop := hnode.cop
    obtain ⟨t, ht⟩ := hnode.odd
    rcases Int.even_or_odd n with hn | hn
    · -- `n` even: branch `P₀`, parent `(m - n/2, n/2)`
      obtain ⟨k, hk⟩ := hn
      have hn2 : n = 2 * k := by omega
      have hcop' : IsCoprime m k := by
        rw [hn2] at hcop; exact hcop.of_mul_right_right
      refine ⟨0, m - k, k, ⟨by omega, by omega, ?_, ⟨t - k, by omega⟩⟩, ?_⟩
      · exact isCoprime_of_unimodular hcop' (α := 1) (β := -1) (γ := 0) (δ := 1)
          (by ring) (by ring) (by norm_num)
      · simp [price, priceP0, IntMap.app, hn2]
    · -- `n` odd, hence `m` even
      obtain ⟨r, hr⟩ := hn
      have hmeven : ∃ j, m = 2 * j := ⟨t - r, by omega⟩
      obtain ⟨j, hj⟩ := hmeven
      have hcop' : IsCoprime j n := by
        rw [hj] at hcop; exact hcop.of_mul_left_right
      rcases lt_trichotomy n j with hlt | heq | hgt
      · -- branch `P₁`, parent `(m/2, m/2 - n)`
        refine ⟨1, j, j - n, ⟨by omega, by omega, ?_, ⟨j - r - 1, by omega⟩⟩, ?_⟩
        · exact isCoprime_of_unimodular hcop' (α := 1) (β := 0) (γ := 1) (δ := -1)
            (by ring) (by ring) (by norm_num)
        · simp [price, priceP1, IntMap.app, hj]
      · -- `m = 2n` happens only at the root
        have hn1 : n = 1 := eq_one_of_dvd_node hnode (k := 2) (by omega)
        exact absurd (by simp [Prod.ext_iff]; omega) hne
      · -- branch `P₂`, parent `(m/2, n - m/2)`
        refine ⟨2, j, n - j, ⟨by omega, by omega, ?_, ⟨r, by omega⟩⟩, ?_⟩
        · exact isCoprime_of_unimodular hcop' (α := 1) (β := 0) (γ := -1) (δ := 1)
            (by ring) (by ring) (by norm_num)
        · simp [price, priceP2, IntMap.app, hj]
  inj := by
    intro i j x y u v hxy huv heq
    have hx1 := hxy.one_le
    have hx2 := hxy.lt
    have hu1 := huv.one_le
    have hu2 := huv.lt
    obtain ⟨s, hs⟩ := hxy.odd
    obtain ⟨w, hw⟩ := huv.odd
    fin_cases i <;> fin_cases j <;>
      simp [price, priceP0, priceP1, priceP2, IntMap.app, Prod.ext_iff] at heq ⊢ <;> omega

end TernaryTree