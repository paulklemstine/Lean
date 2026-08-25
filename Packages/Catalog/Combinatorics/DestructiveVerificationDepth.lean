/-
# Destructive verification II: transcripts, destruction depth, and stabilisation

Companion to `Combinatorics.DestructiveVerification`, which sets up a test as a
state transition `t : D → Bool × D` returning a verdict and a residual dish.
Here we study what happens when a test is **re-run on its own residue**, i.e.
the *transcript*

  `transcript t d k = verdict t ((residue t)^[k] d)`,

the verdict stream produced by running the same test over and over on the
successive residues of a single dish.

The results answer three questions that the one-shot picture cannot even ask.

* **How long can a destructive test masquerade as a certificate?**
  `DestructiveVerification.transcript_rigid`: on a dish type with `n` dishes, a
  transcript that is constant on its first `n` entries is constant forever.
  So the "destruction depth" of a test — the first index at which the verdict
  changes — is either infinite or `< n`.
* **Is that bound sharp?**  `DestructiveVerification.depth_hierarchy` builds,
  for every `k`, a test on `k + 2` dishes whose transcript is constant on
  `[0, k]` and flips at `k + 1 = n - 1`.  Together with rigidity this gives a
  *strict, exhaustive hierarchy of destruction depths*
  (`DestructiveVerification.depth_hierarchy_sharp`): every value `< n` is
  realised and no value `≥ n` is.
* **Does repeated testing ever settle down?**
  `DestructiveVerification.exists_idempotent_iterate` and
  `DestructiveVerification.batch_residue_idempotent`: on a finite dish type
  there is a batch length `N > 0` such that running the batch twice leaves the
  same dish as running it once — every test is nondestructive on its own
  stabilised residue.

The capstone is `DestructiveVerification.batch_accept_forever`: a dish that
survives `n = #D` consecutive runs of a test survives *arbitrarily many* runs.
Finite testing certifies infinite testing — but only after `n` runs, and
`depth_hierarchy` shows `n - 1` runs are genuinely not enough.

The engine behind all of this is the orbit lemma
`DestructiveVerification.exists_orbit_rep`: every point of the forward orbit of
a dish under the residue map is already one of the first `n` points of that
orbit.
-/
import Mathlib
import Combinatorics.DestructiveVerification

namespace DestructiveVerification

variable {D : Type*}

/-! ## 1. Transcripts -/

/-- The **transcript** of a test on a dish: the verdict stream obtained by
re-running the test on each successive residue. -/
def transcript (t : Test D) (d : D) (k : ℕ) : Bool := verdict t ((residue t)^[k] d)

@[simp] lemma transcript_zero (t : Test D) (d : D) : transcript t d 0 = verdict t d := rfl

lemma transcript_succ (t : Test D) (d : D) (k : ℕ) :
    transcript t d (k + 1) = transcript t (residue t d) k := by
  simp [transcript, Function.iterate_succ_apply]

/-- Certificates have constant transcripts. -/
theorem Nondestructive.transcript_const {t : Test D} (h : Nondestructive t) (d : D) (k : ℕ) :
    transcript t d k = transcript t d 0 := h.repeatable_iterate k d

/-- Repeatable tests have constant transcripts (the converse of
`transcript_const` fails to distinguish them: repeatability is exactly
constancy of all transcripts). -/
theorem Repeatable.transcript_const {t : Test D} (h : Repeatable t) (d : D) (k : ℕ) :
    transcript t d k = transcript t d 0 := h.iterate k d

theorem repeatable_iff_transcript_const {t : Test D} :
    Repeatable t ↔ ∀ d k, transcript t d k = transcript t d 0 := by
  constructor
  · intro h d k; exact h.transcript_const d k
  · intro h d
    have := h d 1
    simpa [transcript] using this

/-! ## 2. The orbit lemma -/

/-- **Recurrence.**  On `n` dishes the forward orbit of any dish under the
residue map revisits a dish within the first `n` steps. -/
theorem exists_orbit_recurrence [Fintype D] (f : D → D) (d : D) :
    ∃ i p, 0 < p ∧ i + p ≤ Fintype.card D ∧ f^[i + p] d = f^[i] d := by
  have hcard : Fintype.card D < Fintype.card (Fin (Fintype.card D + 1)) := by simp
  obtain ⟨a, b, hab, hfab⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun j : Fin (Fintype.card D + 1) => f^[j.1] d) hcard
  rcases lt_or_gt_of_ne (fun h : a.1 = b.1 => hab (Fin.ext h)) with h | h
  · refine ⟨a.1, b.1 - a.1, by omega, ?_, ?_⟩
    · have := b.2; omega
    · have : a.1 + (b.1 - a.1) = b.1 := by omega
      rw [this]; exact hfab.symm
  · refine ⟨b.1, a.1 - b.1, by omega, ?_, ?_⟩
    · have := a.2; omega
    · have : b.1 + (a.1 - b.1) = a.1 := by omega
      rw [this]; exact hfab

/-- **Orbit lemma.**  Every dish reachable by iterating the residue map is
already reached within the first `n = #D` steps.  This is the finiteness input
that all the depth theorems below rely on. -/
theorem exists_orbit_rep [Fintype D] (f : D → D) (d : D) (m : ℕ) :
    ∃ j < Fintype.card D, f^[m] d = f^[j] d := by
  obtain ⟨i, p, hp, hip, hper⟩ := exists_orbit_recurrence f d
  by_cases hm : m < i
  · exact ⟨m, by omega, rfl⟩
  · push_neg at hm
    have hy : Function.IsPeriodicPt f p (f^[i] d) := by
      show f^[p] (f^[i] d) = f^[i] d
      rw [← Function.iterate_add_apply, Nat.add_comm p i]
      exact hper
    refine ⟨i + (m - i) % p, by have := Nat.mod_lt (m - i) hp; omega, ?_⟩
    have h1 : f^[m] d = f^[m - i] (f^[i] d) := by
      rw [← Function.iterate_add_apply]
      congr 1
      omega
    have h2 : f^[i + (m - i) % p] d = f^[(m - i) % p] (f^[i] d) := by
      rw [← Function.iterate_add_apply]
      congr 1
      omega
    rw [h1, h2, hy.iterate_mod_apply]

/-! ## 3. Rigidity: destruction depth is either infinite or `< #D` -/

/-- **Transcript rigidity.**  If the first `n = #D` verdicts of a transcript all
agree with the initial verdict, then the whole (infinite) transcript is
constant: a destructive test cannot masquerade as a certificate for `#D`
consecutive runs and then betray itself. -/
theorem transcript_rigid [Fintype D] (t : Test D) (d : D)
    (h : ∀ j < Fintype.card D, transcript t d j = transcript t d 0) (m : ℕ) :
    transcript t d m = transcript t d 0 := by
  obtain ⟨j, hj, hjm⟩ := exists_orbit_rep (residue t) d m
  rw [transcript, hjm, ← transcript]
  exact h j hj

/-- Contrapositive form: if a transcript ever changes, it changes within the
first `#D` runs. -/
theorem transcript_change_early [Fintype D] (t : Test D) (d : D) (m : ℕ)
    (hm : transcript t d m ≠ transcript t d 0) :
    ∃ j < Fintype.card D, transcript t d j ≠ transcript t d 0 := by
  by_contra hcon
  push_neg at hcon
  exact hm (transcript_rigid t d hcon m)

/-! ## 4. Sharpness: a test of every destruction depth -/

/-- The **fuse test** on `k + 2` dishes: the dish is advanced one notch per run
and burns out at the last notch, where the verdict flips.  It accepts the
initial dish for exactly `k + 1` runs. -/
def fuseTest (k : ℕ) : Test (Fin (k + 2)) :=
  fun d => (decide (d.1 ≤ k), ⟨min (d.1 + 1) (k + 1), by omega⟩)

lemma fuseTest_iterate (k j : ℕ) :
    (((residue (fuseTest k))^[j]) (0 : Fin (k + 2))).1 = min j (k + 1) := by
  induction j with
  | zero => simp
  | succ n ih =>
      rw [Function.iterate_succ_apply']
      show min ((((residue (fuseTest k))^[n]) (0 : Fin (k + 2))).1 + 1) (k + 1) = _
      rw [ih]
      omega

lemma fuseTest_transcript (k j : ℕ) :
    transcript (fuseTest k) 0 j = decide (j ≤ k) := by
  show decide ((((residue (fuseTest k))^[j]) (0 : Fin (k + 2))).1 ≤ k) = _
  rw [fuseTest_iterate]
  by_cases h : j ≤ k <;> simp [h]

/-- **Depth hierarchy.**  For every `k` there is a test on `k + 2` dishes whose
transcript is constant on `[0, k]` and flips at step `k + 1`.  Since
`k + 1 = #(Fin (k+2)) - 1`, the bound in `transcript_rigid` is sharp. -/
theorem depth_hierarchy (k : ℕ) :
    ∃ (t : Test (Fin (k + 2))) (d : Fin (k + 2)),
      (∀ j ≤ k, transcript t d j = transcript t d 0) ∧
      transcript t d (k + 1) ≠ transcript t d 0 := by
  refine ⟨fuseTest k, 0, fun j hj => ?_, ?_⟩
  · rw [fuseTest_transcript, fuseTest_transcript]
    simp [hj]
  · rw [fuseTest_transcript, fuseTest_transcript]
    simp

/-- The hierarchy is strict and exhaustive: on `n = k + 2` dishes a test can
hide its destructiveness for exactly `n - 1` runs (`depth_hierarchy`) and never
for `n` runs (`transcript_rigid`). -/
theorem depth_hierarchy_sharp (k : ℕ) :
    (∃ (t : Test (Fin (k + 2))) (d : Fin (k + 2)),
      (∀ j < Fintype.card (Fin (k + 2)) - 1, transcript t d j = transcript t d 0) ∧
      transcript t d (Fintype.card (Fin (k + 2)) - 1) ≠ transcript t d 0) ∧
    (∀ (t : Test (Fin (k + 2))) (d : Fin (k + 2)),
      (∀ j < Fintype.card (Fin (k + 2)), transcript t d j = transcript t d 0) →
      ∀ m, transcript t d m = transcript t d 0) := by
  constructor
  · obtain ⟨t, d, h1, h2⟩ := depth_hierarchy k
    refine ⟨t, d, fun j hj => h1 j ?_, ?_⟩
    · simp only [Fintype.card_fin] at hj; omega
    · simpa using h2
  · intro t d h m
    exact transcript_rigid t d h m

/-! ## 5. Batches: running a test `n` times in a row -/

/-- The **batch test** `batch t n`: run `t` exactly `n` times, each time on the
previous residue, and accept iff every run accepted. -/
def batch (t : Test D) : ℕ → Test D
  | 0 => one D
  | n + 1 => seq (batch t n) t

@[simp] lemma batch_zero (t : Test D) : batch t 0 = one D := rfl

lemma batch_succ (t : Test D) (n : ℕ) : batch t (n + 1) = seq (batch t n) t := rfl

/-- The residue of a batch is the iterated residue. -/
@[simp] lemma residue_batch (t : Test D) (n : ℕ) (d : D) :
    residue (batch t n) d = (residue t)^[n] d := by
  induction n generalizing d with
  | zero => rfl
  | succ n ih =>
      rw [batch_succ, residue_seq, ih, Function.iterate_succ_apply']

/-- The verdict of a batch is the conjunction of the transcript. -/
theorem verdict_batch (t : Test D) (n : ℕ) (d : D) :
    verdict (batch t n) d = true ↔ ∀ j < n, transcript t d j = true := by
  induction n with
  | zero => simp [batch]
  | succ n ih =>
      rw [batch_succ, verdict_seq, Bool.and_eq_true, ih, residue_batch]
      constructor
      · rintro ⟨h1, h2⟩ j hj
        rcases Nat.lt_succ_iff_lt_or_eq.mp hj with hj | rfl
        · exact h1 j hj
        · exact h2
      · intro h
        exact ⟨fun j hj => h j (by omega), h n (by omega)⟩

/-- **Finite testing certifies infinite testing.**  A dish that survives `#D`
consecutive runs of a test survives every batch length.  (By
`depth_hierarchy`, `#D - 1` runs would not suffice.) -/
theorem batch_accept_forever [Fintype D] (t : Test D) (d : D)
    (h : verdict (batch t (Fintype.card D)) d = true) (m : ℕ) :
    verdict (batch t m) d = true := by
  rw [verdict_batch] at h ⊢
  intro j _
  obtain ⟨i, hi, hij⟩ := exists_orbit_rep (residue t) d j
  rw [transcript, hij, ← transcript]
  exact h i hi

/-! ## 6. Stabilisation: every test is nondestructive on its own core -/

/-- On a finite dish type some batch length `N > 0` makes the residue map
idempotent: `res^[N]` is a retraction onto the eventual image of the dish
space. -/
theorem exists_idempotent_iterate [Finite D] (f : D → D) :
    ∃ N, 0 < N ∧ ∀ d, f^[N] (f^[N] d) = f^[N] d := by
  obtain ⟨a, b, hab, hfab⟩ := Finite.exists_ne_map_eq_of_infinite (fun n : ℕ => f^[n])
  -- normalise so that `i < j`
  obtain ⟨i, j, hij, hfij⟩ : ∃ i j, i < j ∧ f^[i] = f^[j] := by
    rcases lt_or_gt_of_ne hab with h | h
    · exact ⟨a, b, h, hfab⟩
    · exact ⟨b, a, h, hfab.symm⟩
  set p := j - i with hp
  have hp0 : 0 < p := by omega
  have hstep : ∀ m, i ≤ m → ∀ d, f^[m + p] d = f^[m] d := by
    intro m hm d
    have h1 : m + p = (m - i) + j := by omega
    have h2 : m = (m - i) + i := by omega
    rw [h1, Function.iterate_add_apply, ← hfij, ← Function.iterate_add_apply, ← h2]
  have hmul : ∀ c, ∀ m, i ≤ m → ∀ d, f^[m + c * p] d = f^[m] d := by
    intro c
    induction c with
    | zero => intro m _ d; simp
    | succ c ih =>
        intro m hm d
        have : m + (c + 1) * p = (m + c * p) + p := by ring
        rw [this, hstep (m + c * p) (by omega) d, ih m hm d]
  refine ⟨p * (i + 1), by positivity, fun d => ?_⟩
  have hge : i ≤ p * (i + 1) := by nlinarith
  have := hmul (i + 1) (p * (i + 1)) hge d
  rw [← Function.iterate_add_apply]
  calc f^[p * (i + 1) + p * (i + 1)] d
      = f^[p * (i + 1) + (i + 1) * p] d := by ring_nf
    _ = f^[p * (i + 1)] d := this

/-- **Stabilisation of verification.**  On a finite dish type there is a batch
length `N > 0` such that re-running the batch on the residue leaves the dish
alone: `batch t N` is destructive in general, but it is *nondestructive on its
own residues*.  Repeatable verification is therefore always attainable at the
cost of a fixed number of preparatory runs. -/
theorem batch_residue_idempotent [Finite D] (t : Test D) :
    ∃ N, 0 < N ∧ ∀ d, residue (batch t N) (residue (batch t N) d) = residue (batch t N) d := by
  obtain ⟨N, hN, hid⟩ := exists_idempotent_iterate (residue t)
  exact ⟨N, hN, fun d => by simpa using hid d⟩

/-- On its stabilised core the batch test *is* a certificate: every dish in the
image of `batch t N` is returned unchanged by it. -/
theorem batch_certificate_on_core [Finite D] (t : Test D) :
    ∃ N, 0 < N ∧ ∀ e ∈ Set.range (residue (batch t N)), residue (batch t N) e = e := by
  obtain ⟨N, hN, hid⟩ := batch_residue_idempotent t
  refine ⟨N, hN, ?_⟩
  rintro e ⟨c, rfl⟩
  exact hid c

/-- **Destruction is confined to the transient.**  On the stabilised core of the
dish space the residue map of the *original* test is a bijection: after enough
preparatory runs the test is reversible, whatever it did on the way in. -/
theorem residue_bijOn_core [Finite D] (t : Test D) :
    ∃ N, 0 < N ∧ Set.BijOn (residue t) (Set.range ((residue t)^[N]))
      (Set.range ((residue t)^[N])) := by
  set f := residue t with hf
  obtain ⟨N, hN, hid⟩ := exists_idempotent_iterate f
  refine ⟨N, hN, ?_⟩
  obtain ⟨M, rfl⟩ : ∃ M, N = M + 1 := ⟨N - 1, by omega⟩
  have hfix : ∀ x ∈ Set.range (f^[M + 1]), f^[M + 1] x = x := by
    rintro x ⟨a, rfl⟩; exact hid a
  have hcomm : ∀ (m : ℕ) (x : D), f^[m] (f x) = f (f^[m] x) := by
    intro m x
    rw [← Function.iterate_succ_apply f m x, Function.iterate_succ_apply']
  refine ⟨?_, ?_, ?_⟩
  · rintro x ⟨a, rfl⟩
    exact ⟨f a, hcomm _ a⟩
  · intro x hx y hy hxy
    have hx2 : f^[M] (f x) = x := by
      rw [← Function.iterate_succ_apply]; exact hfix x hx
    have hy2 : f^[M] (f y) = y := by
      rw [← Function.iterate_succ_apply]; exact hfix y hy
    rw [← hx2, hxy, hy2]
  · rintro x hx
    have hx' : f^[M + 1] x = x := hfix x hx
    refine ⟨f^[M] x, ⟨f^[M] x, ?_⟩, ?_⟩
    · rw [← Function.iterate_add_apply]
      have hMM : M + 1 + M = M + (M + 1) := by omega
      rw [hMM, Function.iterate_add_apply, hx']
    · exact (Function.iterate_succ_apply' f M x).symm.trans hx'

end DestructiveVerification