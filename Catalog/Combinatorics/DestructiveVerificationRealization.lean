/-
# Destructive verification III: which verdict streams are realisable?

`Combinatorics.DestructiveVerificationDepth` shows that re-running a test on its
own residue produces a verdict stream — the *transcript* — that a finite dish
space cannot make arbitrarily wild.  This file pins down **exactly** which
streams occur.

Main results.

* `DestructiveVerification.transcript_eventually_periodic` — on `n` dishes every
  transcript is eventually periodic with preperiod `i` and period `p`
  satisfying `i + p ≤ n`.  (Analysis side.)
* `DestructiveVerification.transcript_realization` — conversely, *every*
  eventually periodic Boolean stream with preperiod `i` and period `p` is the
  transcript of an explicit test on exactly `i + p` dishes, the **rho test**
  whose residue map is the classical "rho" shape: a tail of length `i` feeding a
  cycle of length `p`.  (Synthesis side.)
* `DestructiveVerification.transcript_characterization` — the two combine into
  an exact characterisation: a stream is the transcript of a test on at most `n`
  dishes **iff** it is eventually periodic with `preperiod + period ≤ n`.  This
  is a state-complexity duality for destructive verification: the number of
  dishes needed to realise a verification behaviour is exactly the combinatorial
  complexity `i + p` of its verdict stream.
* `DestructiveVerification.nondestructive_transcript_iff` — the certificates sit
  exactly at the bottom of this scale: a test is nondestructive-like on a dish
  (constant transcript) iff its stream has period `1` and preperiod `0`, i.e.
  `i + p = 1`, the minimum possible.
* `DestructiveVerification.exists_test_of_state_complexity` — a strictness
  corollary: for each `n` there is a stream realisable on `n` dishes but on no
  fewer, so the dish-count hierarchy of verification behaviours is strict at
  every level.

Everything is proved from the orbit lemma of the previous file plus an explicit
combinatorial construction; no hardness assumption of any kind is used.
-/
import Mathlib
import Combinatorics.DestructiveVerification
import Combinatorics.DestructiveVerificationDepth

namespace DestructiveVerification

variable {D : Type*}

/-! ## 1. Analysis: transcripts on `n` dishes are eventually periodic -/

/-- A recurrence in the orbit propagates forward. -/
lemma iterate_period_of_recurrence {f : D → D} {d : D} {i p : ℕ}
    (h : f^[i + p] d = f^[i] d) : ∀ m, i ≤ m → f^[m + p] d = f^[m] d := by
  intro m hm
  have h1 : m + p = (m - i) + (i + p) := by omega
  have h2 : (m - i) + i = m := by omega
  rw [h1, Function.iterate_add_apply, h, ← Function.iterate_add_apply, h2]

/-- **Every transcript on `n` dishes is eventually periodic with
`preperiod + period ≤ n`.** -/
theorem transcript_eventually_periodic [Fintype D] (t : Test D) (d : D) :
    ∃ i p, 0 < p ∧ i + p ≤ Fintype.card D ∧
      ∀ m, i ≤ m → transcript t d (m + p) = transcript t d m := by
  obtain ⟨i, p, hp, hip, hper⟩ := exists_orbit_recurrence (residue t) d
  refine ⟨i, p, hp, hip, fun m hm => ?_⟩
  simp only [transcript]
  rw [iterate_period_of_recurrence hper m hm]

/-! ## 2. Synthesis: the rho test -/

section Rho

variable (i p : ℕ)

/-- The **rho map** on `i + p` dishes: a tail `0 → 1 → ⋯ → i + p - 1` that feeds
back into position `i`, creating a cycle of length `p` after a transient of
length `i`. -/
def rhoMap (hp : 0 < p) : Fin (i + p) → Fin (i + p) :=
  fun j => if h : j.1 + 1 < i + p then ⟨j.1 + 1, h⟩ else ⟨i, by omega⟩

/-- The index reached after `m` runs of the rho map, described by the same
recursion. -/
def rhoIdx : ℕ → ℕ
  | 0 => 0
  | m + 1 => if rhoIdx m + 1 < i + p then rhoIdx m + 1 else i

/-- The **rho test** for a Boolean stream `u`: the dish advances along the rho
shape and the verdict reads off `u` at the current position. -/
def rhoTest (hp : 0 < p) (u : ℕ → Bool) : Test (Fin (i + p)) :=
  fun j => (u j.1, rhoMap i p hp j)

variable {i p}

lemma residue_rhoTest (hp : 0 < p) (u : ℕ → Bool) (j : Fin (i + p)) :
    residue (rhoTest i p hp u) j = rhoMap i p hp j := rfl

lemma rhoMap_val (hp : 0 < p) (j : Fin (i + p)) :
    (rhoMap i p hp j).1 = if j.1 + 1 < i + p then j.1 + 1 else i := by
  unfold rhoMap
  split <;> rfl

/-- The orbit of dish `0` under the rho map is given by `rhoIdx`. -/
lemma rhoMap_iterate_val (hp : 0 < p) (m : ℕ) :
    (((rhoMap i p hp)^[m]) ⟨0, by omega⟩).1 = rhoIdx i p m := by
  induction m with
  | zero => rfl
  | succ n ih =>
      rw [Function.iterate_succ_apply', rhoMap_val, ih]
      rfl

/-- Structure of the rho index: it is always a legal position, it differs from
`m` by a multiple of the period, and once it has fallen behind it is at least
`i`. -/
lemma rhoIdx_spec (hp : 0 < p) (m : ℕ) :
    rhoIdx i p m < i + p ∧ ∃ c, m = rhoIdx i p m + c * p ∧
      (rhoIdx i p m = m ∨ i ≤ rhoIdx i p m) := by
  induction m with
  | zero =>
      refine ⟨by simp only [rhoIdx]; omega, 0, by simp [rhoIdx], Or.inl (by simp [rhoIdx])⟩
  | succ n ih =>
      obtain ⟨hlt, c, hc, hcase⟩ := ih
      by_cases hstep : rhoIdx i p n + 1 < i + p
      · refine ⟨by simp only [rhoIdx, if_pos hstep]; omega, c, ?_, ?_⟩
        · simp only [rhoIdx, if_pos hstep]; omega
        · simp only [rhoIdx, if_pos hstep]
          rcases hcase with h | h
          · exact Or.inl (by omega)
          · exact Or.inr (by omega)
      · refine ⟨by simp only [rhoIdx, if_neg hstep]; omega, c + 1, ?_, ?_⟩
        · simp only [rhoIdx, if_neg hstep]
          have hmul : (c + 1) * p = c * p + p := by ring
          omega
        · simp only [rhoIdx, if_neg hstep]
          exact Or.inr le_rfl

/-- Shifting an eventually periodic stream by a multiple of its period. -/
lemma stream_shift {u : ℕ → Bool} {i p : ℕ} (hu : ∀ m, i ≤ m → u (m + p) = u m) :
    ∀ c a, i ≤ a → u (a + c * p) = u a := by
  intro c
  induction c with
  | zero => intro a _; simp
  | succ c ih =>
      intro a ha
      have hmul : a + (c + 1) * p = (a + c * p) + p := by ring
      rw [hmul, hu _ (by omega), ih a ha]

/-- **Realisation.**  Every Boolean stream that is periodic with period `p`
after step `i` is *exactly* the transcript of the rho test on `i + p` dishes. -/
theorem transcript_realization (i p : ℕ) (hp : 0 < p) (u : ℕ → Bool)
    (hu : ∀ m, i ≤ m → u (m + p) = u m) :
    ∀ m, transcript (rhoTest i p hp u) ⟨0, by omega⟩ m = u m := by
  intro m
  have hres : residue (rhoTest i p hp u) = rhoMap i p hp := rfl
  have hval : (((residue (rhoTest i p hp u))^[m]) ⟨0, by omega⟩).1 = rhoIdx i p m := by
    rw [hres]; exact rhoMap_iterate_val hp m
  show u ((((residue (rhoTest i p hp u))^[m]) ⟨0, by omega⟩).1) = u m
  rw [hval]
  obtain ⟨_, c, hc, hcase⟩ := rhoIdx_spec (i := i) (p := p) hp m
  rcases hcase with h | h
  · rw [h]
  · conv_rhs => rw [hc]
    rw [stream_shift hu c _ h]

end Rho

/-! ## 3. The characterisation -/

/-- **State-complexity duality for destructive verification.**  A Boolean stream
is the transcript of a test on at most `n` dishes iff it is eventually periodic
with `preperiod + period ≤ n`.  The dish count needed to realise a verification
behaviour is exactly the combinatorial complexity of its verdict stream. -/
theorem transcript_characterization (u : ℕ → Bool) (n : ℕ) :
    (∃ (E : Type) (_ : Fintype E) (t : Test E) (d : E),
        Fintype.card E ≤ n ∧ ∀ m, transcript t d m = u m) ↔
      ∃ i p, 0 < p ∧ i + p ≤ n ∧ ∀ m, i ≤ m → u (m + p) = u m := by
  constructor
  · rintro ⟨E, hE, t, d, hcard, hu⟩
    obtain ⟨i, p, hp, hip, hper⟩ := transcript_eventually_periodic t d
    refine ⟨i, p, hp, by omega, fun m hm => ?_⟩
    rw [← hu, ← hu, hper m hm]
  · rintro ⟨i, p, hp, hip, hu⟩
    refine ⟨Fin (i + p), inferInstance, rhoTest i p hp u, ⟨0, by omega⟩, ?_, ?_⟩
    · simpa using hip
    · exact transcript_realization i p hp u hu

/-- Certificates are the bottom of the scale: a transcript is constant iff it is
realisable with period `1` and no transient, i.e. at complexity `1`. -/
theorem nondestructive_transcript_iff (u : ℕ → Bool) :
    (∃ (E : Type) (_ : Fintype E) (t : Test E) (d : E),
        Fintype.card E ≤ 1 ∧ ∀ m, transcript t d m = u m) ↔ ∀ m, u m = u 0 := by
  rw [transcript_characterization]
  constructor
  · rintro ⟨i, p, hp, hip, hper⟩
    have hi : i = 0 := by omega
    have hp1 : p = 1 := by omega
    subst hi; subst hp1
    intro m
    induction m with
    | zero => rfl
    | succ n ih => rw [← ih]; exact hper n (Nat.zero_le n)
  · intro h
    exact ⟨0, 1, one_pos, le_rfl, fun m _ => by rw [h (m + 1), h m]⟩

/-- The stream that says `false` exactly at the multiples of `n`, otherwise
`true`; its complexity is exactly `n`. -/
def periodicStream (n : ℕ) : ℕ → Bool := fun m => decide ¬ (n ∣ m)

/-- **Strictness of the dish-count hierarchy.**  For every `n ≥ 1` the stream
`periodicStream n` is the transcript of a test on `n` dishes but of no test on
fewer than `n` dishes.  So each extra dish buys a genuinely new verification
behaviour. -/
theorem exists_test_of_state_complexity (n : ℕ) (hn : 0 < n) :
    (∃ (E : Type) (_ : Fintype E) (t : Test E) (d : E),
        Fintype.card E ≤ n ∧ ∀ m, transcript t d m = periodicStream n m) ∧
      ¬ (∃ (E : Type) (_ : Fintype E) (t : Test E) (d : E),
        Fintype.card E ≤ n - 1 ∧ ∀ m, transcript t d m = periodicStream n m) := by
  constructor
  · rw [transcript_characterization]
    refine ⟨0, n, hn, by omega, fun m _ => ?_⟩
    simp only [periodicStream]
    congr 1
    simp [Nat.dvd_add_self_right]
  · rw [transcript_characterization]
    rintro ⟨i, p, hp, hip, hper⟩
    -- the stream is `false` exactly on multiples of `n`, so the period must be a
    -- multiple of `n`; but the hypothesis forces `p ≤ n - 1 < n`.
    have hM : i ≤ n * i := Nat.le_mul_of_pos_left i hn
    have hdvdM : n ∣ n * i := ⟨i, rfl⟩
    have h0 : periodicStream n (n * i) = false := by simp [periodicStream, hdvdM]
    have h1 : periodicStream n (n * i + p) = false := by rw [hper _ hM, h0]
    have hdvd : n ∣ n * i + p := by
      by_contra hcon
      simp [periodicStream, hcon] at h1
    have hnp : n ∣ p := (Nat.dvd_add_right hdvdM).mp hdvd
    have := Nat.le_of_dvd hp hnp
    omega

end DestructiveVerification