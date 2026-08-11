/-
# Doppelgänger Phase-Lock — the finite-state synchronization theorem

This file proves the central structural theorem of the theme: for a **finite** state
space, *pairwise* telepathy implies *global* telepathy.  In other words, if any two
individual internal states of the agent can be merged by *some* stimulus word, then a
single universal stimulus word merges **all** states simultaneously — the two
spatially separated doppelgängers phase-lock no matter how they started.

The proof is a greedy image-collapsing (Černý-style) argument, and it is quantitative:
if every pair can be merged by a word of length `≤ L`, a universal locking word of
length `≤ (|S| - 1) * L` exists.

## Main results

* `Doppelganger.rank_append_le` — the *rank* (image cardinality) of a stimulus word is
  antitone under extension: information is only ever destroyed.
* `Doppelganger.locks_iff_rank_eq_one` — locking words are exactly the rank-one words.
* `Doppelganger.exists_lock_of_pairwise_mergeable` — the quantitative synchronization
  theorem (Černý form).
* `Doppelganger.phaseLocking_iff_pairwise_mergeable` — pairwise ⟺ global phase-lock.
-/
import Applications.DoppelgangerPhaseLock.Core

namespace Doppelganger

variable {S I : Type*}

section Rank

variable [Fintype S] [DecidableEq S]

/-- The **rank** of a stimulus word: how many distinct internal states remain
distinguishable after the agents have observed it. -/
def rank (δ : S → I → S) (w : List I) : ℕ := (Finset.univ.image (drive δ w)).card

lemma rank_nil (δ : S → I → S) : rank δ ([] : List I) = Fintype.card S := by
  simp [rank, drive_eq_id_nil, Finset.card_univ]

/-- Observing more stimuli can only destroy information: rank is antitone. -/
theorem rank_append_le (δ : S → I → S) (w v : List I) : rank δ (w ++ v) ≤ rank δ w := by
  have himg : Finset.univ.image (drive δ (w ++ v))
      = (Finset.univ.image (drive δ w)).image (drive δ v) := by
    rw [Finset.image_image]
    congr 1
    funext x
    exact drive_append δ w v x
  rw [rank, himg]
  exact Finset.card_image_le

/-- Phase-locking words are exactly the rank-one words. -/
theorem locks_iff_rank_eq_one [Nonempty S] (δ : S → I → S) (w : List I) :
    Locks δ w ↔ rank δ w = 1 := by
  constructor
  · intro h
    obtain ⟨s0⟩ := ‹Nonempty S›
    have : Finset.univ.image (drive δ w) = {drive δ w s0} := by
      apply Finset.Subset.antisymm
      · intro y hy
        obtain ⟨x, _, rfl⟩ := Finset.mem_image.mp hy
        simp [h x s0]
      · intro y hy
        simp only [Finset.mem_singleton] at hy
        exact hy ▸ Finset.mem_image_of_mem _ (Finset.mem_univ s0)
    simp [rank, this]
  · intro h s t
    obtain ⟨c, hc⟩ := Finset.card_eq_one.mp h
    have hs : drive δ w s ∈ Finset.univ.image (drive δ w) :=
      Finset.mem_image_of_mem _ (Finset.mem_univ s)
    have ht : drive δ w t ∈ Finset.univ.image (drive δ w) :=
      Finset.mem_image_of_mem _ (Finset.mem_univ t)
    rw [hc] at hs ht
    simp only [Finset.mem_singleton] at hs ht
    rw [hs, ht]

end Rank

section Synchronization

variable [DecidableEq S]

/-- A collision inside a finite set strictly drops the cardinality of its image. -/
lemma card_image_lt_of_collision (f : S → S) {A : Finset S} {s t : S} (hs : s ∈ A)
    (ht : t ∈ A) (hst : s ≠ t) (hf : f s = f t) : (A.image f).card < A.card := by
  have hsub : A.image f = (A.erase s).image f := by
    apply Finset.Subset.antisymm
    · intro y hy
      simp only [Finset.mem_image] at hy ⊢
      obtain ⟨x, hx, rfl⟩ := hy
      by_cases hxs : x = s
      · exact ⟨t, Finset.mem_erase.mpr ⟨Ne.symm hst, ht⟩, by rw [hxs, hf]⟩
      · exact ⟨x, Finset.mem_erase.mpr ⟨hxs, hx⟩, rfl⟩
    · exact Finset.image_subset_image (Finset.erase_subset _ _)
  calc (A.image f).card = ((A.erase s).image f).card := by rw [hsub]
    _ ≤ (A.erase s).card := Finset.card_image_le
    _ < A.card := Finset.card_erase_lt_of_mem hs

/-- **Greedy collapse.** Bounded pairwise merging collapses every finite set of states
to a single state, using a word of length at most `(|A| - 1) * L`. -/
lemma exists_word_image_card_eq_one (δ : S → I → S) (L : ℕ)
    (h : ∀ s t : S, ∃ w : List I, w.length ≤ L ∧ drive δ w s = drive δ w t) :
    ∀ (n : ℕ) (A : Finset S), A.card ≤ n → A.Nonempty →
      ∃ w : List I, w.length ≤ (A.card - 1) * L ∧ (A.image (drive δ w)).card = 1 := by
  intro n
  induction n with
  | zero => intro A hA hne; exact absurd (Finset.card_pos.mpr hne) (by omega)
  | succ n ih =>
    intro A hcard hne
    by_cases h1 : A.card = 1
    · refine ⟨[], by simp, ?_⟩
      have himg : A.image (drive δ ([] : List I)) = A := by
        simp only [drive_eq_id_nil, Finset.image_id]
      rw [himg]; exact h1
    · have h2 : 1 < A.card := by
        have := Finset.card_pos.mpr hne; omega
      obtain ⟨s, hs, t, ht, hst⟩ := Finset.one_lt_card.mp h2
      obtain ⟨v, hvlen, hv⟩ := h s t
      set B := A.image (drive δ v) with hB
      have hBlt : B.card < A.card := card_image_lt_of_collision _ hs ht hst hv
      have hBne : B.Nonempty := hne.image _
      obtain ⟨u, hulen, hu⟩ := ih B (by omega) hBne
      refine ⟨v ++ u, ?_, ?_⟩
      · have hlen : (v ++ u).length ≤ L + (B.card - 1) * L := by
          simpa using Nat.add_le_add hvlen hulen
        refine hlen.trans ?_
        calc L + (B.card - 1) * L = (B.card - 1 + 1) * L := by ring
          _ ≤ (A.card - 1) * L := Nat.mul_le_mul_right _ (by omega)
      · rw [show A.image (drive δ (v ++ u)) = B.image (drive δ u) by
          rw [hB, Finset.image_image]; congr 1; funext x; exact drive_append δ v u x]
        exact hu

/-- **Doppelgänger phase-lock theorem (Černý form).**  If every pair of internal states
can be merged by some stimulus word of length at most `L`, then a *single* stimulus word
of length at most `(|S| - 1) * L` phase-locks the two separated agents from *any* pair of
initial states. -/
theorem exists_lock_of_pairwise_mergeable [Fintype S] [Nonempty S] (δ : S → I → S) (L : ℕ)
    (h : ∀ s t : S, ∃ w : List I, w.length ≤ L ∧ drive δ w s = drive δ w t) :
    ∃ w : List I, w.length ≤ (Fintype.card S - 1) * L ∧ Locks δ w := by
  obtain ⟨w, hlen, hcard⟩ :=
    exists_word_image_card_eq_one δ L h (Fintype.card S) Finset.univ
      (by simp [Finset.card_univ]) Finset.univ_nonempty
  refine ⟨w, by simpa [Finset.card_univ] using hlen, fun s t => ?_⟩
  obtain ⟨c, hc⟩ := Finset.card_eq_one.mp hcard
  have hs : drive δ w s ∈ Finset.univ.image (drive δ w) :=
    Finset.mem_image_of_mem _ (Finset.mem_univ s)
  have ht : drive δ w t ∈ Finset.univ.image (drive δ w) :=
    Finset.mem_image_of_mem _ (Finset.mem_univ t)
  rw [hc] at hs ht
  simp only [Finset.mem_singleton] at hs ht
  rw [hs, ht]

/-- **Pairwise telepathy is global telepathy.** For a finite agent, the doppelgänger pair
phase-locks from arbitrary initial states iff every *individual* pair of states is
mergeable. -/
theorem phaseLocking_iff_pairwise_mergeable [Fintype S] [Nonempty S] (δ : S → I → S) :
    PhaseLocking δ ↔ ∀ s t : S, Mergeable δ s t := by
  classical
  constructor
  · rintro ⟨w, hw⟩ s t
    exact hw.mergeable s t
  · intro h
    choose w hw using h
    set L := Finset.univ.sup (fun p : S × S => (w p.1 p.2).length) with hL
    have hbound : ∀ s t : S, ∃ v : List I, v.length ≤ L ∧ drive δ v s = drive δ v t := by
      intro s t
      refine ⟨w s t, ?_, hw s t⟩
      exact Finset.le_sup (f := fun p : S × S => (w p.1 p.2).length) (Finset.mem_univ (s, t))
    obtain ⟨v, _, hv⟩ := exists_lock_of_pairwise_mergeable δ L hbound
    exact ⟨v, hv⟩

end Synchronization

section AbsoluteBound

/-! ### An absolute (Černý-style) bound on the phase-lock time

So far the locking time was expressed in terms of an *assumed* bound `L` on pairwise
merging times.  We now remove that assumption: a pigeonhole argument in the **pair
automaton** `S × S` shows that a mergeable pair is always mergeable within `|S|²`
stimuli, whence an unconditional cubic bound on the doppelgänger phase-lock time.
-/

/-- **Pigeonhole in the pair automaton.**  A merging word longer than `|S|²` contains a
repeated pair-state and can therefore be shortened. -/
lemma shorten_merge [Fintype S] (δ : S → I → S) {s t : S} {w : List I}
    (hlen : Fintype.card S * Fintype.card S < w.length)
    (hw : drive δ w s = drive δ w t) :
    ∃ v : List I, v.length < w.length ∧ drive δ v s = drive δ v t := by
  classical
  set n := w.length with hn
  let f : Fin (n + 1) → S × S := fun k => (drive δ (w.take k) s, drive δ (w.take k) t)
  have hcard : Fintype.card (S × S) < Fintype.card (Fin (n + 1)) := by
    simp only [Fintype.card_prod, Fintype.card_fin]
    omega
  obtain ⟨a, b, hab, hfab⟩ := Fintype.exists_ne_map_eq_of_card_lt f hcard
  rcases lt_or_gt_of_ne hab with hlt | hlt
  · refine ⟨w.take a ++ w.drop b, ?_, ?_⟩
    · have ha : (a : ℕ) ≤ n := by omega
      have hb : (b : ℕ) ≤ n := by omega
      simp only [List.length_append, List.length_take, List.length_drop, ← hn]
      omega
    · have key : ∀ x : S,
          drive δ (w.take a ++ w.drop b) x = drive δ (w.drop b) (drive δ (w.take a) x) :=
        fun x => drive_append δ _ _ x
      have hsplit : ∀ x : S, drive δ w x = drive δ (w.drop b) (drive δ (w.take b) x) := by
        intro x
        conv_lhs => rw [← List.take_append_drop (b : ℕ) w]
        exact drive_append δ _ _ x
      have h1 : drive δ (w.take a) s = drive δ (w.take b) s := congrArg Prod.fst hfab
      have h2 : drive δ (w.take a) t = drive δ (w.take b) t := congrArg Prod.snd hfab
      rw [key, key, h1, h2, ← hsplit, ← hsplit, hw]
  · refine ⟨w.take b ++ w.drop a, ?_, ?_⟩
    · have hba : (b : ℕ) < a := hlt
      have ha : (a : ℕ) ≤ n := by omega
      simp only [List.length_append, List.length_take, List.length_drop, ← hn]
      omega
    · have key : ∀ x : S,
          drive δ (w.take b ++ w.drop a) x = drive δ (w.drop a) (drive δ (w.take b) x) :=
        fun x => drive_append δ _ _ x
      have hsplit : ∀ x : S, drive δ w x = drive δ (w.drop a) (drive δ (w.take a) x) := by
        intro x
        conv_lhs => rw [← List.take_append_drop (a : ℕ) w]
        exact drive_append δ _ _ x
      have h1 : drive δ (w.take b) s = drive δ (w.take a) s := (congrArg Prod.fst hfab).symm
      have h2 : drive δ (w.take b) t = drive δ (w.take a) t := (congrArg Prod.snd hfab).symm
      rw [key, key, h1, h2, ← hsplit, ← hsplit, hw]

/-- Every mergeable pair of internal states merges within `|S|²` stimuli. -/
lemma exists_short_merge [Fintype S] (δ : S → I → S) {s t : S} (h : Mergeable δ s t) :
    ∃ v : List I, v.length ≤ Fintype.card S * Fintype.card S ∧ drive δ v s = drive δ v t := by
  obtain ⟨w, hw⟩ := h
  induction hn : w.length using Nat.strong_induction_on generalizing w with
  | _ n ih =>
    subst hn
    by_cases hle : w.length ≤ Fintype.card S * Fintype.card S
    · exact ⟨w, hle, hw⟩
    · obtain ⟨v, hvlen, hv⟩ := shorten_merge δ (by omega) hw
      exact ih v.length hvlen v hv rfl

/-- **Unconditional phase-lock time bound.**  A finite agent that admits doppelgänger
phase-lock at all admits it within `(|S| - 1) · |S|²` stimuli. -/
theorem exists_lock_length_le_of_phaseLocking [Fintype S] [Nonempty S] [DecidableEq S]
    (δ : S → I → S) (h : PhaseLocking δ) :
    ∃ w : List I,
      w.length ≤ (Fintype.card S - 1) * (Fintype.card S * Fintype.card S) ∧ Locks δ w := by
  have hpair : ∀ s t : S, ∃ v : List I,
      v.length ≤ Fintype.card S * Fintype.card S ∧ drive δ v s = drive δ v t := by
    intro s t
    exact exists_short_merge δ (((phaseLocking_iff_pairwise_mergeable δ).mp h) s t)
  exact exists_lock_of_pairwise_mergeable δ _ hpair

end AbsoluteBound

end Doppelganger