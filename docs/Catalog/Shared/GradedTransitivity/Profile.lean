import Shared.GradedTransitivity.Sharpness

/-!
# The whole transitivity profile is rational

`r`-transitivity is a *downward closed* condition: an `r`-transitive `G`-set is
`s`-transitive for every `s ≤ r`.  Consequently, if the grades of a graded
`G`-set are eventually `r`-transitive, then *all* of the Hilbert series
`∑_n t_s(Y_n) qⁿ`, `s ≤ r`, are rational with denominator `1-q`, and each of
them has numerator evaluating to `1` at `q = 1`.

## Main results

* `nat_le_enatCard_of_embedding` : an injective `n`-tuple witnesses `n ≤ #α`.
* `isRTransitive_of_le` : downward closure of `r`-transitivity.
* `hilbertSeq_profile_rational` : rationality of the whole profile.
-/

namespace GradedTransitivity

open Polynomial

/-- The existence of an injective `n`-tuple in `α` bounds `n` by the
cardinality of `α`, as an `ℕ∞`-valued statement (no finiteness needed). -/
theorem nat_le_enatCard_of_embedding {α : Type u} {n : ℕ} (h : Nonempty (Fin n ↪ α)) :
    (n : ℕ∞) ≤ ENat.card α := by
  have h1 : Cardinal.lift.{u} (Cardinal.mk (Fin n)) ≤ Cardinal.lift.{0} (Cardinal.mk α) :=
    Cardinal.lift_mk_le'.2 h
  have h2 : Cardinal.toENat (Cardinal.lift.{u} (Cardinal.mk (Fin n)))
      ≤ Cardinal.toENat (Cardinal.lift.{0} (Cardinal.mk α)) := OrderHomClass.mono _ h1
  simpa [ENat.card] using h2

/-- **Downward closure.**  An `r`-transitive `G`-set is `s`-transitive for all
`s ≤ r`. -/
theorem isRTransitive_of_le {G : Type*} [Group G] {Y : Type u} [MulAction G Y] {s r : ℕ}
    (hsr : s ≤ r) (h : IsRTransitive G Y r) : IsRTransitive G Y s := by
  obtain ⟨hpre, hne⟩ := h
  have hcard : (r : ℕ∞) ≤ ENat.card Y := nat_le_enatCard_of_embedding hne
  refine ⟨?_, ?_⟩
  · have : MulAction.IsMultiplyPretransitive G Y r := hpre
    exact MulAction.isMultiplyPretransitive_of_le' hsr hcard
  · obtain ⟨f⟩ := hne
    exact ⟨(Fin.castLEEmb hsr).trans f⟩

section Profile

variable {G : ℕ → Type*} [∀ n, Group (G n)] {Y : ℕ → Type*} [∀ n, MulAction (G n) (Y n)]

/-- Eventual `r`-transitivity implies eventual `s`-transitivity for `s ≤ r`. -/
theorem eventually_isRTransitive_of_le {s r N : ℕ} (hsr : s ≤ r)
    (h : ∀ n ≥ N, IsRTransitive (G n) (Y n) r) :
    ∀ n ≥ N, IsRTransitive (G n) (Y n) s :=
  fun n hn => isRTransitive_of_le hsr (h n hn)

/-- **The whole transitivity profile is rational.**  If the grades are
eventually `r`-transitive then for every `s ≤ r` the series
`∑_n t_s(Y_n) qⁿ` is rational with denominator `1-q` (hence with denominator
dividing `(1-q)^{s+1}`), and its numerator takes the value `1` at `q = 1`. -/
theorem hilbertSeq_profile_rational (r N : ℕ) (h : ∀ n ≥ N, IsRTransitive (G n) (Y n) r) :
    ∀ s ≤ r, ∃ P : ℚ[X],
      (1 - PowerSeries.X) * gen (hilbertSeq G Y s) = (P : PowerSeries ℚ) ∧ P.eval 1 = 1 := by
  intro s hs
  obtain ⟨P, hP⟩ :=
    gen_hilbertSeq_rational s N (eventually_isRTransitive_of_le hs h)
  exact ⟨P, hP, hilbertSeq_residue_one s N (eventually_isRTransitive_of_le hs h) hP⟩

/-- Restated with the denominator `(1-q)^{s+1}` of the mission statement. -/
theorem hilbertSeq_profile_rational_pow (r N : ℕ) (h : ∀ n ≥ N, IsRTransitive (G n) (Y n) r) :
    ∀ s ≤ r, ∃ P : ℚ[X],
      (1 - PowerSeries.X) ^ (s + 1) * gen (hilbertSeq G Y s) = (P : PowerSeries ℚ) :=
  fun s hs => gen_hilbertSeq_rational_pow s N (eventually_isRTransitive_of_le hs h)

end Profile

end GradedTransitivity