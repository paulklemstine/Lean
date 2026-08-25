import Physics.TernaryPythagoreanTrees.Tree

/-!
# The Berggren tree (determinants `±1`)

The classical Berggren triple, in Euclid parameters `(m, n)`:

* `A (m, n) = (2m - n, m)`,
* `B (m, n) = (2m + n, m)`,
* `C (m, n) = (m + 2n, n)`,

with determinants `1, -1, 1`.  We prove that these three maps organise the node set into a
ternary tree rooted at `(2,1)` (`TernaryTree.berg_isTernaryTree`).

The proof is a *descent by ratio*: the images of `A`, `B`, `C` are exactly the nodes with
`m < 2n`, `2n < m < 3n` and `3n < m` respectively, and the excluded ratios `m = 2n`,
`m = 3n` single out the root and an impossible parity.
-/

namespace TernaryTree

/-- Berggren's first branch `(m,n) ↦ (2m - n, m)`, determinant `1`. -/
def bergA : IntMap := ⟨2, -1, 1, 0⟩
/-- Berggren's second branch `(m,n) ↦ (2m + n, m)`, determinant `-1`. -/
def bergB : IntMap := ⟨2, 1, 1, 0⟩
/-- Berggren's third branch `(m,n) ↦ (m + 2n, n)`, determinant `1`. -/
def bergC : IntMap := ⟨1, 2, 0, 1⟩

/-- The Berggren triple. -/
def berg : Fin 3 → IntMap
  | 0 => bergA
  | 1 => bergB
  | 2 => bergC

@[simp] lemma bergA_det : bergA.det = 1 := by norm_num [bergA, IntMap.det]
@[simp] lemma bergB_det : bergB.det = -1 := by norm_num [bergB, IntMap.det]
@[simp] lemma bergC_det : bergC.det = 1 := by norm_num [bergC, IntMap.det]

/-- A convenient sufficient criterion for node preservation of an explicit matrix. -/
lemma preserves_mk {a b c d : ℤ}
    (hdet : a * d - b * c = 1 ∨ a * d - b * c = -1 ∨ a * d - b * c = 2 ∨ a * d - b * c = -2)
    (h1 : Odd (a + c)) (h2 : Odd (b + d)) (h3 : 0 ≤ c) (h4 : 0 ≤ c + d)
    (h5 : ¬(c = 0 ∧ d = 0)) (h6 : 0 ≤ a - c) (h7 : 0 ≤ (a - c) + (b - d))
    (h8 : ¬(a - c = 0 ∧ b - d = 0)) : Preserves ⟨a, b, c, d⟩ :=
  (preserves_iff _).2
    ⟨h1, h2, no_odd_prime_dvd_of_det_small (M := ⟨a, b, c, d⟩) (by simpa [IntMap.det] using hdet),
      h3, h4, h5, h6, h7, h8⟩

lemma bergA_preserves : Preserves bergA :=
  preserves_mk (by norm_num) ⟨1, by norm_num⟩ ⟨-1, by norm_num⟩ (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)

lemma bergB_preserves : Preserves bergB :=
  preserves_mk (by norm_num) ⟨1, by norm_num⟩ ⟨0, by norm_num⟩ (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)

lemma bergC_preserves : Preserves bergC :=
  preserves_mk (by norm_num) ⟨0, by norm_num⟩ ⟨1, by norm_num⟩ (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)

/-- **The Berggren triple is a ternary tree on the node set.** -/
theorem berg_isTernaryTree : IsTernaryTree berg where
  preserves i := by
    fin_cases i
    · exact bergA_preserves
    · exact bergB_preserves
    · exact bergC_preserves
  root_not_hit := by
    intro i m n hnode h
    have h1 := hnode.one_le
    have h2 := hnode.lt
    fin_cases i <;>
      simp [berg, bergA, bergB, bergC, IntMap.app, Prod.ext_iff] at h <;> omega
  covers := by
    intro m n hnode hne
    have h1 := hnode.one_le
    have h2 := hnode.lt
    have hcop := hnode.cop
    obtain ⟨t, ht⟩ := hnode.odd
    rcases lt_trichotomy m (2 * n) with hlt | heq | hgt
    · -- branch `A`: parent `(n, 2n - m)`
      refine ⟨0, n, 2 * n - m, ⟨by omega, by omega, ?_, ⟨2 * n - t - 1, by omega⟩⟩, ?_⟩
      · exact isCoprime_of_unimodular hcop (α := 0) (β := 1) (γ := -1) (δ := 2)
          (by ring) (by ring) (by norm_num)
      · simp [berg, bergA, IntMap.app]
    · -- `m = 2n` happens only at the root
      have hn1 : n = 1 := eq_one_of_dvd_node hnode (k := 2) (by omega)
      exact absurd (by simp [Prod.ext_iff]; omega) hne
    · rcases lt_trichotomy m (3 * n) with hlt3 | heq3 | hgt3
      · -- branch `B`: parent `(n, m - 2n)`
        refine ⟨1, n, m - 2 * n, ⟨by omega, by omega, ?_, ⟨t - n, by omega⟩⟩, ?_⟩
        · exact isCoprime_of_unimodular hcop (α := 0) (β := 1) (γ := 1) (δ := -2)
            (by ring) (by ring) (by norm_num)
        · simp [berg, bergB, IntMap.app]
      · -- `m = 3n` is impossible: it forces `n = 1`, `m = 3`, and `m + n` even
        have hn1 : n = 1 := eq_one_of_dvd_node hnode (k := 3) (by omega)
        omega
      · -- branch `C`: parent `(m - 2n, n)`
        refine ⟨2, m - 2 * n, n, ⟨by omega, by omega, ?_, ⟨t - n, by omega⟩⟩, ?_⟩
        · exact isCoprime_of_unimodular hcop (α := 1) (β := -2) (γ := 0) (δ := 1)
            (by ring) (by ring) (by norm_num)
        · simp [berg, bergC, IntMap.app]
  inj := by
    intro i j x y u v hxy huv heq
    have hx1 := hxy.one_le
    have hx2 := hxy.lt
    have hu1 := huv.one_le
    have hu2 := huv.lt
    fin_cases i <;> fin_cases j <;>
      simp [berg, bergA, bergB, bergC, IntMap.app, Prod.ext_iff] at heq ⊢ <;> omega

end TernaryTree