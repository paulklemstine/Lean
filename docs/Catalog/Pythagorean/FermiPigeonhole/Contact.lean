/-
# Second-moment bound: contact is quadratically rare

Contact between two civilizations requires them to be *contemporaneous*: two
distinct sites `i ≠ j` must both be civilized and land in the same epoch.

Because each site is civilized with probability `p` and epochs are uniform over
`T` slots, a fixed ordered pair contributes probability at most `p ^ 2 / T`
(`prb_sameEpoch_le`), and a union bound over the `N ^ 2 - N` ordered pairs gives

  `Prb (Contact) ≤ (N ^ 2 - N) * p ^ 2 / T`   (`prb_contact_le`).

Note the structure of the estimate: contact is *quadratic* in the small parameter
`p` and *inversely proportional* to the number of epochs.  Adding more time (more
"holes" in the pigeonhole picture) makes contact rarer, not more likely.
-/
import Pythagorean.FermiPigeonhole.DrakeFirstMoment

namespace Pythagorean.FermiPigeonhole

open Finset

variable {N T : ℕ} {p : ℝ}

/-- Sites `i` and `j` are both civilized and contemporaneous. -/
def SameEpoch (N T : ℕ) (i j : Fin N) : Set (Cosmos N T) :=
  {f | f i = f j ∧ f i ≠ none}

/-- Some two distinct sites are civilized and contemporaneous: contact is possible. -/
def Contact (N T : ℕ) : Set (Cosmos N T) :=
  {f | ∃ i j, i ≠ j ∧ f i = f j ∧ f i ≠ none}

/-- Probability that two prescribed distinct sites are civilized in two prescribed
(not necessarily distinct) epochs. -/
lemma prb_two_sites {i j : Fin N} (hij : i ≠ j) (e e' : Fin T) :
    Prb N T p {f | f i = some e ∧ f j = some e'} = (p / T) ^ 2 := by
  classical
  set B : Fin N → Finset (Option (Fin T)) := fun k =>
    if k = i then {some e} else if k = j then {some e'} else Finset.univ with hB
  have hset : {f : Cosmos N T | f i = some e ∧ f j = some e'}
      = {f : Cosmos N T | ∀ k, f k ∈ B k} := by
    ext f
    constructor
    · rintro ⟨hi, hj⟩ k
      by_cases hk : k = i
      · subst hk; simp [hB, hi]
      · by_cases hk' : k = j
        · subst hk'; simp [hB, hk, hj]
        · simp [hB, hk, hk']
    · intro hf
      have hi := hf i
      have hj := hf j
      simp only [hB, if_pos rfl] at hi
      simp only [hB, if_neg (Ne.symm hij)] at hj
      exact ⟨by simpa using hi, by simpa using hj⟩
  rw [hset, prb_cylinder]
  have hg : ∀ k : Fin N, (∑ x ∈ B k, siteWeight T p x)
      = if k = i ∨ k = j then p / T else 1 := by
    intro k
    have hT : 0 < T := by
      by_contra h
      have hT0 : T = 0 := by omega
      subst hT0
      exact (Fin.elim0 e)
    by_cases hk : k = i
    · subst hk
      simp only [hB, if_pos rfl]
      simp [siteWeight]
    · by_cases hk' : k = j
      · subst hk'
        simp only [hB, if_neg hk]
        simp [siteWeight]
      · simp only [hB, if_neg hk, if_neg hk', if_neg (by tauto : ¬ (k = i ∨ k = j))]
        exact siteWeight_sum hT
  have hsub : ({i, j} : Finset (Fin N)) ⊆ Finset.univ := Finset.subset_univ _
  have hprod : ∏ k ∈ ({i, j} : Finset (Fin N)), (∑ x ∈ B k, siteWeight T p x)
      = ∏ k : Fin N, (∑ x ∈ B k, siteWeight T p x) := by
    refine Finset.prod_subset hsub fun k _ hk => ?_
    have hk' : ¬ (k = i ∨ k = j) := by
      simpa [Finset.mem_insert, Finset.mem_singleton] using hk
    rw [hg k, if_neg hk']
  rw [← hprod, Finset.prod_pair hij, hg i, hg j, if_pos (Or.inl rfl), if_pos (Or.inr rfl), sq]

/-- Probability that two prescribed distinct sites are both civilized in a
prescribed epoch `e`. -/
lemma prb_two_sites_epoch {i j : Fin N} (hij : i ≠ j) (e : Fin T) :
    Prb N T p {f | f i = some e ∧ f j = some e} = (p / T) ^ 2 :=
  prb_two_sites hij e e

/-- **Pairwise contact bound.**  Two prescribed distinct sites are civilized and
contemporaneous with probability at most `p ^ 2 / T`. -/
lemma prb_sameEpoch_le (h0 : 0 ≤ p) (h1 : p ≤ 1) (hT : 0 < T) {i j : Fin N}
    (hij : i ≠ j) :
    Prb N T p (SameEpoch N T i j) ≤ p ^ 2 / T := by
  classical
  have hsub : SameEpoch N T i j
      ⊆ {f : Cosmos N T | ∃ e ∈ (Finset.univ : Finset (Fin T)),
          f ∈ {g : Cosmos N T | g i = some e ∧ g j = some e}} := by
    rintro f ⟨hfij, hfi⟩
    obtain ⟨e, he⟩ : ∃ e, f i = some e := Option.ne_none_iff_exists'.mp hfi
    exact ⟨e, Finset.mem_univ e, he, by rw [← hfij, he]⟩
  calc Prb N T p (SameEpoch N T i j)
      ≤ Prb N T p {f : Cosmos N T | ∃ e ∈ (Finset.univ : Finset (Fin T)),
          f ∈ {g : Cosmos N T | g i = some e ∧ g j = some e}} := prb_mono h0 h1 hsub
    _ ≤ ∑ e : Fin T, Prb N T p {g : Cosmos N T | g i = some e ∧ g j = some e} :=
        prb_union_bound h0 h1 _ _
    _ = ∑ _e : Fin T, (p / T) ^ 2 :=
        Finset.sum_congr rfl fun e _ => prb_two_sites_epoch hij e
    _ = p ^ 2 / T := by
        have hT' : (T : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hT.ne'
        rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
        field_simp

/-- **Contact is quadratically rare.**  The probability that the cosmos ever
contains two contemporaneous civilizations is at most `(N ^ 2 - N) * p ^ 2 / T`. -/
theorem prb_contact_le (h0 : 0 ≤ p) (h1 : p ≤ 1) (hT : 0 < T) :
    Prb N T p (Contact N T) ≤ ((N : ℝ) ^ 2 - N) * (p ^ 2 / T) := by
  classical
  have hsub : Contact N T
      ⊆ {f : Cosmos N T | ∃ q ∈ (Finset.univ : Finset (Fin N)).offDiag,
          f ∈ SameEpoch N T q.1 q.2} := by
    rintro f ⟨i, j, hij, hfij, hfi⟩
    exact ⟨(i, j), Finset.mem_offDiag.mpr ⟨Finset.mem_univ _, Finset.mem_univ _, hij⟩,
      hfij, hfi⟩
  have hcard : (((Finset.univ : Finset (Fin N)).offDiag.card : ℝ)) = (N : ℝ) ^ 2 - N := by
    rw [Finset.offDiag_card]
    simp only [Finset.card_univ, Fintype.card_fin]
    rcases Nat.eq_zero_or_pos N with hN | hN
    · subst hN; simp
    · rw [Nat.cast_sub (Nat.le_mul_of_pos_left N hN)]
      push_cast
      ring
  have hterm : ∀ q ∈ (Finset.univ : Finset (Fin N)).offDiag,
      Prb N T p (SameEpoch N T q.1 q.2) ≤ p ^ 2 / T := by
    intro q hq
    exact prb_sameEpoch_le h0 h1 hT (Finset.mem_offDiag.mp hq).2.2
  calc Prb N T p (Contact N T)
      ≤ Prb N T p {f : Cosmos N T | ∃ q ∈ (Finset.univ : Finset (Fin N)).offDiag,
          f ∈ SameEpoch N T q.1 q.2} := prb_mono h0 h1 hsub
    _ ≤ ∑ q ∈ (Finset.univ : Finset (Fin N)).offDiag,
          Prb N T p (SameEpoch N T q.1 q.2) := prb_union_bound h0 h1 _ _
    _ ≤ ∑ _q ∈ (Finset.univ : Finset (Fin N)).offDiag, p ^ 2 / T :=
        Finset.sum_le_sum hterm
    _ = ((N : ℝ) ^ 2 - N) * (p ^ 2 / T) := by
        rw [Finset.sum_const, nsmul_eq_mul, hcard]

end Pythagorean.FermiPigeonhole