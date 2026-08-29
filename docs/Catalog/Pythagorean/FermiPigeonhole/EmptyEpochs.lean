/-
# Bridge: probabilistic first moment meets deterministic dual pigeonhole

`EpochPigeonhole` says that a set of civilizations can occupy at most as many
epochs as there are civilizations, so at least `T - #civs` epochs stay empty.
`DrakeFirstMoment` says that the expected number of civilizations is `N * p`.

Combining the two gives the central quantitative statement of this development:

  `expected_empty_epochs_ge`:  `E[# empty epochs] ≥ T - N * p`.

In the honest Drake regime `N * p < 1` this says that *all but at most one* of the
`T` epochs are expected to be empty: the pigeonhole principle, applied with the
correct counts, predicts an empty universe rather than a crowded one.
-/
import Pythagorean.FermiPigeonhole.DrakeFirstMoment
import Pythagorean.FermiPigeonhole.EpochPigeonhole

namespace Pythagorean.FermiPigeonhole

open Finset

variable {N T : ℕ} {p : ℝ}

/-- The epochs in which no site hosts a civilization. -/
noncomputable def emptyEpochs (N T : ℕ) (f : Cosmos N T) : Finset (Fin T) :=
  {e ∈ (Finset.univ : Finset (Fin T)) | ∀ i, f i ≠ some e}

/-- **Deterministic dual pigeonhole for an outcome.**  At least `T - civCount f`
epochs of an outcome `f` are completely empty. -/
theorem card_emptyEpochs_ge (f : Cosmos N T) :
    T - civCount N T f ≤ (emptyEpochs N T f).card := by
  classical
  by_cases hocc : ∃ e : Fin T, ∃ i, f i = some e
  · obtain ⟨e₀, -⟩ := hocc
    set civs : Finset (Fin N) := {i ∈ (Finset.univ : Finset (Fin N)) | f i ≠ none} with hcivs
    have hcount : civs.card = civCount N T f := by
      rw [hcivs, civCount]
      congr 1
      ext i
      simp
    have hsub := card_empty_epochs_ge (T := T) civs (fun i => (f i).getD e₀)
    refine le_trans (by omega) (le_trans hsub (le_of_eq ?_))
    · congr 1
      ext e
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, emptyEpochs, hcivs]
      constructor
      · intro h i hfi
        have hine : f i ≠ none := by rw [hfi]; simp
        have hne := h i hine
        rw [hfi] at hne
        exact hne rfl
      · intro h i hine hgi
        obtain ⟨e', he'⟩ := Option.ne_none_iff_exists'.mp hine
        rw [he'] at hgi
        simp only [Option.getD_some] at hgi
        exact h i (by rw [he', hgi])
  · have hall : emptyEpochs N T f = (Finset.univ : Finset (Fin T)) := by
      ext e
      simp only [emptyEpochs, Finset.mem_filter, Finset.mem_univ, true_and, iff_true]
      intro i hi
      exact hocc ⟨e, i, hi⟩
    rw [hall, Finset.card_univ, Fintype.card_fin]
    omega

/-- Total mass of the model is one (indicator-free form). -/
lemma sum_weight_eq_one (hT : 0 < T) :
    ∑ f : Cosmos N T, weight N T p f = 1 := by
  have h := prb_univ (N := N) (T := T) (p := p) hT
  rwa [Prb, Set.indicator_univ] at h

/-- **The expected number of empty epochs.**  At least `T - N * p` of the `T`
epochs are expected to contain no civilization at all. -/
theorem expected_empty_epochs_ge (h0 : 0 ≤ p) (h1 : p ≤ 1) (hT : 0 < T) :
    (T : ℝ) - (N : ℝ) * p
      ≤ ∑ f : Cosmos N T, weight N T p f * ((emptyEpochs N T f).card : ℝ) := by
  classical
  have hpoint : ∀ f : Cosmos N T,
      weight N T p f * ((T : ℝ) - (civCount N T f : ℝ))
        ≤ weight N T p f * ((emptyEpochs N T f).card : ℝ) := by
    intro f
    refine mul_le_mul_of_nonneg_left ?_ (weight_nonneg h0 h1 f)
    rcases le_or_gt (civCount N T f) T with hle | hgt
    · have := card_emptyEpochs_ge (N := N) (T := T) f
      have hcast : ((T - civCount N T f : ℕ) : ℝ) ≤ ((emptyEpochs N T f).card : ℝ) := by
        exact_mod_cast this
      rw [Nat.cast_sub hle] at hcast
      exact hcast
    · have h1' : (T : ℝ) - (civCount N T f : ℝ) ≤ 0 := by
        have : (T : ℝ) ≤ (civCount N T f : ℝ) := by exact_mod_cast hgt.le
        linarith
      exact le_trans h1' (Nat.cast_nonneg _)
  calc (T : ℝ) - (N : ℝ) * p
      = ∑ f : Cosmos N T, weight N T p f * ((T : ℝ) - (civCount N T f : ℝ)) := by
        have hsum : ∑ f : Cosmos N T, weight N T p f * ((T : ℝ) - (civCount N T f : ℝ))
            = (T : ℝ) * (∑ f : Cosmos N T, weight N T p f)
              - ∑ f : Cosmos N T, weight N T p f * (civCount N T f : ℝ) := by
          rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
          exact Finset.sum_congr rfl fun f _ => by ring
        rw [hsum, sum_weight_eq_one (N := N) (p := p) hT,
          drake_expected_count (N := N) (p := p) hT, mul_one]
    _ ≤ ∑ f : Cosmos N T, weight N T p f * ((emptyEpochs N T f).card : ℝ) :=
        Finset.sum_le_sum fun f _ => hpoint f

end Pythagorean.FermiPigeonhole