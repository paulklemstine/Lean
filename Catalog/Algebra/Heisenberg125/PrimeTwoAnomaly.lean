/-
# The oddness hypothesis is necessary: `d(H_8) ≥ 4 > 3·2 - 3`

Godara and Sarkar conjecture `d(H_{p^3}) = 3p - 3` for every *odd* prime `p`.
The group `Heis 2` of order `8` (which has exponent `4`, not `2`, so it is not
the exponent-`p` Heisenberg group) shows that the oddness is not cosmetic: the
sequence `y · (xy)^3` is product-one-free of length `4 > 3 = 3·2 - 3`.

This also pins down where our odd-`p` arguments break: for `p = 2` one has
`p ∤ binom p 2`, so `p` equal elements in one coset of the centre need not
multiply to a central element, and `2` is not invertible, so the cocycle
straightening `c ↦ c - (m/2) a²` of `Algebra.Heisenberg125.LineBound` is
unavailable.
-/
import Algebra.Heisenberg125.LowerBound

namespace Heisenberg125

namespace Heis

/-- `y = (0,1,0)` in `Heis 2`. -/
private def g2 : Heis 2 := ⟨0, 1, 0⟩
/-- `xy = (1,1,0)` in `Heis 2`. -/
private def h2 : Heis 2 := ⟨1, 1, 0⟩

/-- The product-one-free sequence `y (xy)^3` of length `4` over `Heis 2`. -/
def anomalySeq : List (Heis 2) := [g2] ++ List.replicate 3 h2

@[simp] lemma length_anomalySeq : anomalySeq.length = 4 := by
  simp [anomalySeq]

/-- **`y (xy)^3` is product-one-free over `Heis 2`.** -/
theorem productOneFree_anomalySeq : ProductOneFree anomalySeq := by
  rintro T hT hne ⟨M, hM, hprod⟩
  obtain ⟨T1, T2, rfl, h1, hrep⟩ := List.sublist_append_iff.1 hT
  obtain ⟨j, hj, rfl⟩ := List.sublist_replicate_iff.1 hrep
  have ha : asum (T1 ++ List.replicate j h2) = 0 := by
    rw [← asum_perm hM]; exact ((prod_eq_one_iff M).1 hprod).1
  have hb : bsum (T1 ++ List.replicate j h2) = 0 := by
    rw [← bsum_perm hM]; exact ((prod_eq_one_iff M).1 hprod).2.1
  rcases List.sublist_singleton.1 h1 with rfl | rfl
  · -- no copy of `y`
    simp only [List.nil_append, asum_replicate, bsum_replicate, h2] at ha hb
    interval_cases j
    · exact hne rfl
    · revert ha; decide
    · -- `j = 2`: the product is the central element `v ≠ 1`
      have hMeq : M = List.replicate 2 h2 := List.perm_replicate.1 (by simpa using hM)
      rw [hMeq] at hprod
      revert hprod
      decide
    · revert ha; decide
  · -- one copy of `y`
    simp only [List.singleton_append, asum_cons, bsum_cons, asum_replicate, bsum_replicate,
      g2, h2] at ha hb
    interval_cases j <;> revert ha hb <;> decide

/-- `d(H_8) ≥ 4`, whereas `3p - 3 = 3` for `p = 2`: the Godara–Sarkar formula
fails at the even prime. -/
theorem four_le_smallDavenport_heis_two : 4 ≤ smallDavenport (Heis 2) := by
  simpa using productOneFree_anomalySeq.length_le_smallDavenport

end Heis

end Heisenberg125