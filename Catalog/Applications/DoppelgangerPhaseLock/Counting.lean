/-
# Doppelgänger Phase-Lock — how *typical* is telepathy?

The synchronization theorem tells us that a locking stimulus word exists.  This file
answers the quantitative question an experimenter would ask: *if the environment supplies
stimuli blindly, how likely is it that the two separated agents phase-lock?*

We slice a stimulus stream of length `L * m` into `m` blocks of length `L`, where `L` is
the length of one locking block `u`.  Because locking words form a two-sided ideal
(`Doppelganger.locks_ideal`), a stream locks as soon as **one** of its blocks equals `u`.
Hence non-locking stream-prefixes must avoid `u` in every block, and a direct count gives

`#{non-locking block sequences} ≤ (|I|^L - 1)^m`,

out of `(|I|^L)^m` sequences overall: the failure fraction decays *geometrically*.  So
doppelgänger phase-lock is not a miracle but a probability-one event under blind
environmental driving.

## Main results

* `Doppelganger.locks_blockWord` — one locking block suffices.
* `Doppelganger.card_nonlocking_le` — the exact counting bound `(|I|^L - 1)^m`.
* `Doppelganger.nonlocking_fraction_le` — the failure fraction is `≤ (1 - |I|^{-L})^m`.
* `Doppelganger.tendsto_nonlocking_fraction_zero` — blind driving locks the doppelgängers
  with asymptotic probability one.
-/
import Applications.DoppelgangerPhaseLock.Core

namespace Doppelganger

variable {S I : Type*}

/-- The stimulus word obtained by concatenating `m` blocks of length `L`. -/
def blockWord {L m : ℕ} (b : Fin m → (Fin L → I)) : List I :=
  (List.ofFn fun j => List.ofFn (b j)).flatten

/-- **One locking block suffices.**  If some block of the stream is the locking block `u`,
the whole stream locks. -/
lemma locks_blockWord {δ : S → I → S} {L m : ℕ} {u : Fin L → I}
    (hu : Locks δ (List.ofFn u)) (b : Fin m → (Fin L → I)) (j : Fin m) (hj : b j = u) :
    Locks δ (blockWord b) := by
  refine Locks.flatten_of_mem δ ?_ hu
  rw [List.mem_ofFn]
  exact ⟨j, by rw [hj]⟩

open Classical in
/-- **Counting the failures.**  At most `(|I|^L - 1)^m` of the `(|I|^L)^m` block sequences
fail to phase-lock the doppelgänger pair. -/
theorem card_nonlocking_le [Fintype I] {δ : S → I → S} {L m : ℕ} {u : Fin L → I}
    (hu : Locks δ (List.ofFn u)) :
    ((Finset.univ : Finset (Fin m → (Fin L → I))).filter
      (fun b => ¬ Locks δ (blockWord b))).card ≤ (Fintype.card I ^ L - 1) ^ m := by
  classical
  have hsub : ((Finset.univ : Finset (Fin m → (Fin L → I))).filter
      (fun b => ¬ Locks δ (blockWord b)))
      ⊆ Fintype.piFinset (fun _ : Fin m => (Finset.univ : Finset (Fin L → I)).erase u) := by
    intro b hb
    simp only [Finset.mem_filter] at hb
    rw [Fintype.mem_piFinset]
    intro j
    rw [Finset.mem_erase]
    refine ⟨fun hbj => hb.2 (locks_blockWord hu b j hbj), Finset.mem_univ _⟩
  calc _ ≤ (Fintype.piFinset
              (fun _ : Fin m => (Finset.univ : Finset (Fin L → I)).erase u)).card :=
        Finset.card_le_card hsub
    _ = (Fintype.card I ^ L - 1) ^ m := by
        rw [Fintype.card_piFinset]
        simp [Finset.card_erase_of_mem, Finset.card_univ]

open Classical in
/-- **Geometric decay of the failure fraction.**  Writing `q = |I|^L` for the number of
possible blocks, the proportion of length-`L·m` stimulus streams that fail to phase-lock
the two agents is at most `(1 - 1/q)^m`. -/
theorem nonlocking_fraction_le [Fintype I] [Nonempty I] {δ : S → I → S} {L m : ℕ}
    {u : Fin L → I} (hu : Locks δ (List.ofFn u)) :
    ((((Finset.univ : Finset (Fin m → (Fin L → I))).filter
        (fun b => ¬ Locks δ (blockWord b))).card : ℝ) / ((Fintype.card I ^ L : ℕ) : ℝ) ^ m)
      ≤ (1 - (((Fintype.card I ^ L : ℕ) : ℝ))⁻¹) ^ m := by
  classical
  set q : ℕ := Fintype.card I ^ L with hqdef
  have hq : 1 ≤ q := Nat.one_le_pow _ _ Fintype.card_pos
  have hq0 : (0:ℝ) < (q : ℝ) := by exact_mod_cast hq
  have hcast : ((q - 1 : ℕ) : ℝ) = (q : ℝ) - 1 := by
    push_cast [Nat.cast_sub hq]; ring
  have hc : (((Finset.univ : Finset (Fin m → (Fin L → I))).filter
      (fun b => ¬ Locks δ (blockWord b))).card : ℝ) ≤ ((q : ℝ) - 1) ^ m := by
    calc (((Finset.univ : Finset (Fin m → (Fin L → I))).filter
            (fun b => ¬ Locks δ (blockWord b))).card : ℝ)
          ≤ (((q - 1) ^ m : ℕ) : ℝ) := by exact_mod_cast card_nonlocking_le hu
      _ = ((q : ℝ) - 1) ^ m := by push_cast [hcast]; ring
  calc (((Finset.univ : Finset (Fin m → (Fin L → I))).filter
        (fun b => ¬ Locks δ (blockWord b))).card : ℝ) / (q : ℝ) ^ m
      ≤ ((q : ℝ) - 1) ^ m / (q : ℝ) ^ m := by gcongr
    _ = (1 - ((q : ℝ))⁻¹) ^ m := by
        rw [← div_pow]
        congr 1
        field_simp

open Classical in
/-- **Blind driving synchronizes the doppelgängers almost surely.**  As the number of
observed blocks grows, the fraction of stimulus streams that fail to phase-lock tends to
zero, provided the environment offers at least two distinguishable stimuli in a block. -/
theorem tendsto_nonlocking_fraction_zero [Fintype I] [Nonempty I] {δ : S → I → S} {L : ℕ}
    {u : Fin L → I} (hu : Locks δ (List.ofFn u)) (hq2 : 2 ≤ Fintype.card I ^ L) :
    Filter.Tendsto
      (fun m : ℕ => ((((Finset.univ : Finset (Fin m → (Fin L → I))).filter
        (fun b => ¬ Locks δ (blockWord b))).card : ℝ) / ((Fintype.card I ^ L : ℕ) : ℝ) ^ m))
      Filter.atTop (nhds 0) := by
  classical
  set q : ℕ := Fintype.card I ^ L with hqdef
  have hq0 : (0:ℝ) < (q : ℝ) := by
    have : (0:ℕ) < q := by omega
    exact_mod_cast this
  have hr0 : 0 ≤ 1 - ((q : ℝ))⁻¹ := by
    have : ((q : ℝ))⁻¹ ≤ 1 := by
      rw [inv_le_one_iff₀]
      right
      have : (1:ℕ) ≤ q := by omega
      exact_mod_cast this
    linarith
  have hr1 : 1 - ((q : ℝ))⁻¹ < 1 := by
    have : 0 < ((q : ℝ))⁻¹ := by positivity
    linarith
  refine squeeze_zero (fun m => by positivity) (fun m => nonlocking_fraction_le hu) ?_
  exact tendsto_pow_atTop_nhds_zero_of_lt_one hr0 hr1

end Doppelganger