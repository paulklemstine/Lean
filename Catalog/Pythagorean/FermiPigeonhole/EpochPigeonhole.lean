/-
# The pigeonhole side: civilizations in epochs

Deterministic combinatorics of the "holes" in the Fermi picture.  Civilizations
(`civs`, a finite set of labels) are assigned birth epochs by a map
`epoch : ι → Fin T`.  Two civilizations can only meet if they share an epoch.

* `exists_crowded_epoch` — quantitative pigeonhole: if `T * n < |civs|` then some
  epoch carries more than `n` civilizations;
* `exists_contemporaries` — with more civilizations than epochs, two of them are
  contemporaries (contact is forced);
* `exists_contactfree_schedule` — conversely, as soon as there are at most `T`
  civilizations, a contact-free schedule exists, so pigeonhole forces nothing:
  the threshold `|civs| = T` is sharp;
* `card_empty_epochs_ge` — *dual pigeonhole*: at least `T - |civs|` epochs are
  completely empty.  In the Fermi regime, where the expected number of
  civilizations is far below the number of epochs, almost every hole is empty.
-/
import Mathlib

namespace Pythagorean.FermiPigeonhole

open Finset

variable {ι : Type*} {T : ℕ}

/-- **Quantitative pigeonhole.**  If the `|civs|` civilizations are spread over `T`
epochs and `T * n < |civs|`, then some epoch carries more than `n` of them. -/
theorem exists_crowded_epoch (civs : Finset ι) (epoch : ι → Fin T) {n : ℕ}
    (h : T * n < civs.card) :
    ∃ e : Fin T, n < {c ∈ civs | epoch c = e}.card := by
  classical
  have hmaps : ∀ c ∈ civs, epoch c ∈ (Finset.univ : Finset (Fin T)) := by
    intro c _; exact Finset.mem_univ _
  have hlt : (Finset.univ : Finset (Fin T)).card * n < civs.card := by
    simpa [Finset.card_univ] using h
  obtain ⟨e, _, he⟩ :=
    Finset.exists_lt_card_fiber_of_mul_lt_card_of_maps_to hmaps hlt
  exact ⟨e, he⟩

/-- **Contact is forced by pigeonhole.**  More civilizations than epochs means two
distinct civilizations are contemporaries. -/
theorem exists_contemporaries (civs : Finset ι) (epoch : ι → Fin T)
    (h : T < civs.card) :
    ∃ c ∈ civs, ∃ d ∈ civs, c ≠ d ∧ epoch c = epoch d := by
  classical
  obtain ⟨e, he⟩ := exists_crowded_epoch civs epoch (n := 1) (by simpa using h)
  obtain ⟨c, hc, d, hd, hcd⟩ := Finset.one_lt_card.mp he
  simp only [Finset.mem_filter] at hc hd
  exact ⟨c, hc.1, d, hd.1, hcd, by rw [hc.2, hd.2]⟩

/-- **Sharpness of the pigeonhole threshold.**  If there are at most `T`
civilizations, some schedule makes all of them pairwise non-contemporaneous, so no
contact is forced. -/
theorem exists_contactfree_schedule [Fintype ι] (h : Fintype.card ι ≤ T) :
    ∃ epoch : ι → Fin T, ∀ c d : ι, c ≠ d → epoch c ≠ epoch d := by
  obtain ⟨g⟩ := Function.Embedding.nonempty_of_card_le
    (α := ι) (β := Fin T) (by simpa using h)
  exact ⟨g, fun c d hcd => fun hg => hcd (g.injective hg)⟩

/-- **Dual pigeonhole: most holes are empty.**  At least `T - |civs|` of the `T`
epochs contain no civilization at all. -/
theorem card_empty_epochs_ge (civs : Finset ι) (epoch : ι → Fin T) :
    T - civs.card
      ≤ {e ∈ (Finset.univ : Finset (Fin T)) | ∀ c ∈ civs, epoch c ≠ e}.card := by
  classical
  have hcompl : {e ∈ (Finset.univ : Finset (Fin T)) | ¬ (∀ c ∈ civs, epoch c ≠ e)}
      = civs.image epoch := by
    ext e
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image,
      not_forall, not_not]
    constructor
    · rintro ⟨c, hc, hce⟩
      exact ⟨c, hc, by simpa using hce⟩
    · rintro ⟨c, hc, hce⟩
      exact ⟨c, hc, by simp [hce]⟩
  have hsplit :
      {e ∈ (Finset.univ : Finset (Fin T)) | ∀ c ∈ civs, epoch c ≠ e}.card
        + {e ∈ (Finset.univ : Finset (Fin T)) | ¬ (∀ c ∈ civs, epoch c ≠ e)}.card
        = T := by
    rw [Finset.card_filter_add_card_filter_not]
    simp [Finset.card_univ]
  have himg : (civs.image epoch).card ≤ civs.card := Finset.card_image_le
  rw [hcompl] at hsplit
  omega

/-- **The Fermi reading of the pigeonhole principle.**  When the number of
civilizations is strictly below the number of epochs, no contact is forced *and* a
positive number of epochs is completely empty.  Pigeonhole predicts emptiness, not
encounters. -/
theorem pigeonhole_predicts_emptiness [Fintype ι] (civs : Finset ι) (epoch : ι → Fin T)
    (h : civs.card < T) :
    0 < {e ∈ (Finset.univ : Finset (Fin T)) | ∀ c ∈ civs, epoch c ≠ e}.card := by
  have hge := card_empty_epochs_ge civs epoch
  have hpos : 0 < T - civs.card := Nat.sub_pos_of_lt h
  exact lt_of_lt_of_le hpos hge

end Pythagorean.FermiPigeonhole