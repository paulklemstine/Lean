import Pythagorean.AggregateDichotomy

/-!
# Rigidity fails even after adding hypotenuse data

`Pythagorean.multiset_prod_not_injective` shows that the Brahmagupta product does not
determine the unordered family.  The natural repair conjecture is that the *product together
with the multiset of hypotenuses* should determine the family: after all, the hypotenuse
records the norm, and norms multiply.  This file refutes that repair with an explicit
witness coming from conjugate factorisations of `65 = 5 · 13` inside `ℤ[i]`:

`(63 - 16i)(63 + 16i) = 4225 = (-33 + 56i)(-33 - 56i)`,

where all four Gaussian integers have norm `65²`, i.e. all four Pythagorean triples have
hypotenuse `65`, and all four are nondegenerate (no vanishing leg).

## Main result

* `Pythagorean.hypotenuse_data_does_not_rigidify` : there are two different multisets of two
  nondegenerate Pythagorean triples with the *same* product and the *same* multiset of
  hypotenuses.  Hence no amount of hypotenuse bookkeeping can restore injectivity; only a
  labelling device such as `interleave` or `gaggr` can.
-/

namespace Pythagorean

open PTriple

/-- `(3+4i)(5-12i) = 63 - 16i`, a triple with hypotenuse `65`. -/
def w1 : PTriple := ofLegs 63 (-16) 65 (by norm_num) (by norm_num)

/-- `(3-4i)(5+12i) = 63 + 16i`, a triple with hypotenuse `65`. -/
def w2 : PTriple := ofLegs 63 16 65 (by norm_num) (by norm_num)

/-- `(3+4i)(5+12i) = -33 + 56i`, a triple with hypotenuse `65`. -/
def w3 : PTriple := ofLegs (-33) 56 65 (by norm_num) (by norm_num)

/-- `(3-4i)(5-12i) = -33 - 56i`, a triple with hypotenuse `65`. -/
def w4 : PTriple := ofLegs (-33) (-56) 65 (by norm_num) (by norm_num)

/-- Both conjugate pairs multiply to the real Gaussian integer `4225 = 65²`. -/
theorem w_collision : w1 * w2 = w3 * w4 := by
  ext <;> simp [w1, w2, w3, w4]

theorem w_multiset_ne : ({w1, w2} : Multiset PTriple) ≠ {w3, w4} := by
  intro h
  have hmem : w1 ∈ ({w3, w4} : Multiset PTriple) := by
    rw [← h]; simp
  have hne3 : w1 ≠ w3 := by
    intro he
    have : (63 : ℤ) = -33 := by simpa [w1, w3] using congrArg PTriple.a he
    norm_num at this
  have hne4 : w1 ≠ w4 := by
    intro he
    have : (63 : ℤ) = -33 := by simpa [w1, w4] using congrArg PTriple.a he
    norm_num at this
  rcases Multiset.mem_cons.mp hmem with h' | h'
  · exact hne3 h'
  · exact hne4 (Multiset.mem_singleton.mp h')

theorem w_same_hypotenuses :
    ({w1, w2} : Multiset PTriple).map PTriple.c = ({w3, w4} : Multiset PTriple).map PTriple.c := by
  simp [w1, w2, w3, w4]

/-- **Hypotenuse data does not restore rigidity.**  Two distinct unordered families of
nondegenerate Pythagorean triples can share both their Brahmagupta product and their multiset
of hypotenuses. -/
theorem hypotenuse_data_does_not_rigidify :
    ∃ M N : Multiset PTriple,
      M ≠ N ∧ M.prod = N.prod ∧ M.map PTriple.c = N.map PTriple.c ∧
        Multiset.card M = 2 ∧ Multiset.card N = 2 ∧
        (∀ t ∈ M, t.a ≠ 0 ∧ t.b ≠ 0) ∧ (∀ t ∈ N, t.a ≠ 0 ∧ t.b ≠ 0) := by
  refine ⟨{w1, w2}, {w3, w4}, w_multiset_ne, ?_, w_same_hypotenuses, by simp, by simp, ?_, ?_⟩
  · simpa using w_collision
  · intro t ht
    rcases Multiset.mem_cons.mp ht with rfl | ht'
    · exact ⟨by simp [w1], by simp [w1]⟩
    · rw [Multiset.mem_singleton.mp ht']
      exact ⟨by simp [w2], by simp [w2]⟩
  · intro t ht
    rcases Multiset.mem_cons.mp ht with rfl | ht'
    · exact ⟨by simp [w3], by simp [w3]⟩
    · rw [Multiset.mem_singleton.mp ht']
      exact ⟨by simp [w4], by simp [w4]⟩

end Pythagorean