/-
# Destructive verification IV: how many runs distinguish two dishes?

In the state-transition model of `Combinatorics.DestructiveVerification` a test
`t : D → Bool × D` can only be used by *running* it: the observer sees the
verdict stream (`transcript`) obtained by feeding the residue back in.  Two
dishes are **observationally equivalent** for `t` when their transcripts agree
at every step.  How long must one watch before equivalence is certain?

The naive answer, obtained by running the product dynamics on `D × D` and
applying the pigeonhole principle, is `#D ^ 2` runs.  The main theorem here
improves this to a **linear** bound:

* `DestructiveVerification.transcript_indistinguishable` — if the transcripts of
  two dishes agree for the first `2 * #D` runs, they agree forever; and
* `DestructiveVerification.indistinguishable_iff_prefix` — hence observational
  equivalence is *exactly* agreement on a prefix of length `2 * #D`.

The improvement is a genuine cross-domain bridge: the quadratic bound is what
dynamics on the product state space gives, while the linear bound comes from
**combinatorics on words** — the Fine–Wilf periodicity lemma
(`List.HasPeriod.gcd` in Mathlib).  Both transcripts are eventually periodic
with `preperiod + period ≤ #D` (that is the state-transition input); a window of
length `p + q` on which they agree forces the common word to have period
`gcd p q` (that is the word-combinatorial input), which pins the two streams
together forever.

Supporting general-purpose lemmas, stated for arbitrary streams:

* `DestructiveVerification.eq_mod_period` — a globally `p`-periodic stream is
  determined by its values on `[0, p)`;
* `DestructiveVerification.fine_wilf_mod` — a stream that is globally
  `p`-periodic and `q`-periodic on a window of length `p + q` is globally
  `gcd p q`-periodic.

Finally `DestructiveVerification.clock_distinguishing_delay` exhibits, on five
dishes, two dishes whose transcripts agree for three runs and disagree on the
fourth: watching is genuinely necessary, one run never suffices.
-/
import Mathlib
import Combinatorics.DestructiveVerification
import Combinatorics.DestructiveVerificationDepth
import Combinatorics.DestructiveVerificationRealization

namespace DestructiveVerification

variable {D : Type*}

/-! ## 1. Streams: periodicity toolkit -/

/-- A globally `p`-periodic stream is determined by its values below `p`. -/
lemma eq_mod_period {α : Type*} (s : ℕ → α) {p : ℕ} (hp : 0 < p)
    (hper : ∀ m, s (m + p) = s m) : ∀ m, s m = s (m % p) := by
  intro m
  induction m using Nat.strong_induction_on with
  | _ m ih =>
    by_cases hm : m < p
    · rw [Nat.mod_eq_of_lt hm]
    · push_neg at hm
      have hmp : m - p + p = m := by omega
      have h1 : s m = s (m - p) := by
        conv_lhs => rw [← hmp]
        exact hper (m - p)
      rw [h1, ih (m - p) (by omega), Nat.mod_eq_sub_mod hm]

/-- **Fine–Wilf for streams.**  A stream that is globally `p`-periodic and is
`q`-periodic on the window `[0, p + q)` is globally `gcd p q`-periodic.  This is
the word-combinatorial engine of the linear distinguishing bound. -/
lemma fine_wilf_mod {α : Type*} (s : ℕ → α) {p q : ℕ} (hp : 0 < p) (hq : 0 < q)
    (hper_p : ∀ m, s (m + p) = s m)
    (hper_q : ∀ k, k + q < p + q - Nat.gcd p q → s (k + q) = s k) :
    ∀ m, s m = s (m % Nat.gcd p q) := by
  set g := Nat.gcd p q with hg
  have hg0 : 0 < g := Nat.gcd_pos_of_pos_left q hp
  have hgp : g ≤ p := Nat.le_of_dvd hp (Nat.gcd_dvd_left p q)
  have hgq : g ≤ q := Nat.le_of_dvd hq (Nat.gcd_dvd_right p q)
  set L := p + q - g with hL
  set w := (List.range L).map s with hw
  have hlen : w.length = L := by simp [hw]
  have hget : ∀ i, i < L → w[i]? = some (s i) := by
    intro i hi
    simp [hw, hi]
  have hP : List.HasPeriod w p := by
    rw [List.hasPeriod_iff_getElem?]
    intro i hi
    rw [hlen] at hi
    rw [hget i (by omega), hget (i + p) (by omega), hper_p i]
  have hQ : List.HasPeriod w q := by
    rw [List.hasPeriod_iff_getElem?]
    intro i hi
    rw [hlen] at hi
    rw [hget i (by omega), hget (i + q) (by omega), hper_q i (by omega)]
  have hG : List.HasPeriod w g := hP.gcd hQ (by rw [hlen])
  have hstep : ∀ i, i + g < L → s (i + g) = s i := by
    intro i hi
    rw [List.hasPeriod_iff_getElem?] at hG
    have hgi := hG i (by rw [hlen]; omega)
    rw [hget i (by omega), hget (i + g) (by omega)] at hgi
    exact (Option.some_inj.mp hgi).symm
  have hsmall : ∀ k, k < p → s k = s (k % g) := by
    intro k
    induction k using Nat.strong_induction_on with
    | _ k ih =>
      intro hk
      by_cases hkg : k < g
      · rw [Nat.mod_eq_of_lt hkg]
      · push_neg at hkg
        have hkgg : k - g + g = k := by omega
        have h1 : s k = s (k - g) := by
          conv_lhs => rw [← hkgg]
          exact hstep (k - g) (by omega)
        rw [h1, ih (k - g) (by omega) (by omega), Nat.mod_eq_sub_mod hkg]
  intro m
  have h1 : s m = s (m % p) := eq_mod_period s hp hper_p m
  have h2 : s (m % p) = s ((m % p) % g) := hsmall (m % p) (Nat.mod_lt _ hp)
  rw [h1, h2, Nat.mod_mod_of_dvd m (Nat.gcd_dvd_left p q)]

/-! ## 2. The distinguishing engine -/

/-- **Distinguishing engine.**  Suppose the two transcripts are eventually
periodic with preperiods `i₁, i₂` and periods `p₁, p₂`, and suppose they agree
on a prefix of length `T` where `T` covers the Fine–Wilf window
`max i₁ i₂ + p₁ + p₂ - gcd p₁ p₂`.  Then they agree everywhere.

All distinguishing bounds below are instances of this lemma; only the estimate
of the window changes. -/
theorem transcript_agree_of_window (t : Test D) (d e : D) {i₁ p₁ i₂ p₂ T : ℕ}
    (hp₁ : 0 < p₁) (hp₂ : 0 < p₂)
    (hper₁ : ∀ m, i₁ ≤ m → transcript t d (m + p₁) = transcript t d m)
    (hper₂ : ∀ m, i₂ ≤ m → transcript t e (m + p₂) = transcript t e m)
    (hT : max i₁ i₂ + p₁ + p₂ - Nat.gcd p₁ p₂ ≤ T)
    (h : ∀ j < T, transcript t d j = transcript t e j) (m : ℕ) :
    transcript t d m = transcript t e m := by
  set g := Nat.gcd p₁ p₂ with hg
  have hg0 : 0 < g := Nat.gcd_pos_of_pos_left p₂ hp₁
  have hgp₁ : g ≤ p₁ := Nat.le_of_dvd hp₁ (Nat.gcd_dvd_left p₁ p₂)
  have hgp₂ : g ≤ p₂ := Nat.le_of_dvd hp₂ (Nat.gcd_dvd_right p₁ p₂)
  set I := max i₁ i₂ with hI
  set s : ℕ → Bool := fun k => transcript t d (I + k) with hs
  set s' : ℕ → Bool := fun k => transcript t e (I + k) with hs'
  have hsp : ∀ k, s (k + p₁) = s k := by
    intro k
    have hik : I + (k + p₁) = (I + k) + p₁ := by omega
    simp only [hs, hik]
    exact hper₁ (I + k) (by omega)
  have hs'p : ∀ k, s' (k + p₂) = s' k := by
    intro k
    have hik : I + (k + p₂) = (I + k) + p₂ := by omega
    simp only [hs', hik]
    exact hper₂ (I + k) (by omega)
  have hagree : ∀ k, I + k < T → s k = s' k := fun k hk => h (I + k) hk
  have hsq : ∀ k, k + p₂ < p₁ + p₂ - g → s (k + p₂) = s k := by
    intro k hk
    have h1 : s (k + p₂) = s' (k + p₂) := hagree _ (by omega)
    have h2 : s' (k + p₂) = s' k := hs'p k
    have h3 : s' k = s k := (hagree k (by omega)).symm
    rw [h1, h2, h3]
  have hs'q : ∀ k, k + p₁ < p₂ + p₁ - Nat.gcd p₂ p₁ → s' (k + p₁) = s' k := by
    intro k hk
    rw [Nat.gcd_comm p₂ p₁] at hk
    have h1 : s' (k + p₁) = s (k + p₁) := (hagree _ (by omega)).symm
    have h2 : s (k + p₁) = s k := hsp k
    have h3 : s k = s' k := hagree k (by omega)
    rw [h1, h2, h3]
  have hsg := fine_wilf_mod s hp₁ hp₂ hsp hsq
  have hs'g := fine_wilf_mod s' hp₂ hp₁ hs'p hs'q
  rw [Nat.gcd_comm p₂ p₁] at hs'g
  by_cases hm : m < I
  · exact h m (by omega)
  · push_neg at hm
    have hmod : (m - I) % g < g := Nat.mod_lt _ hg0
    have hwin : I + (m - I) % g < I + p₁ + p₂ - g := by omega
    have hkey : s (m - I) = s' (m - I) := by
      rw [hsg (m - I), hs'g (m - I)]
      exact hagree _ (lt_of_lt_of_le hwin hT)
    have hmI' : I + (m - I) = m := by omega
    have e1 : transcript t d m = s (m - I) := by simp only [hs]; rw [hmI']
    have e2 : transcript t e m = s' (m - I) := by simp only [hs']; rw [hmI']
    rw [e1, e2, hkey]

/-- **Linear indistinguishability.**  If two dishes produce the same verdict for
the first `2 * #D` runs of a test, they produce the same verdict forever.  No
destructive test can postpone the reveal past `2 * #D` runs.  (The sharper
bound `#D` is `Combinatorics.DestructiveVerificationSharpBound`.) -/
theorem transcript_indistinguishable [Fintype D] (t : Test D) (d e : D)
    (h : ∀ j < 2 * Fintype.card D, transcript t d j = transcript t e j) (m : ℕ) :
    transcript t d m = transcript t e m := by
  obtain ⟨i₁, p₁, hp₁, hip₁, hper₁⟩ := transcript_eventually_periodic t d
  obtain ⟨i₂, p₂, hp₂, hip₂, hper₂⟩ := transcript_eventually_periodic t e
  exact transcript_agree_of_window t d e hp₁ hp₂ hper₁ hper₂ (by omega) h m

/-- Observational equivalence of two dishes is *exactly* agreement of the first
`2 * #D` verdicts: a finite, explicitly bounded amount of watching settles it. -/
theorem indistinguishable_iff_prefix [Fintype D] (t : Test D) (d e : D) :
    (∀ m, transcript t d m = transcript t e m) ↔
      ∀ j < 2 * Fintype.card D, transcript t d j = transcript t e j := by
  constructor
  · intro h j _; exact h j
  · intro h m; exact transcript_indistinguishable t d e h m

/-! ## 3. A distinguishing delay: watching is necessary -/

/-- Five dishes: a two-cycle `{0,1}` and a three-cycle `{2,3,4}`, with verdicts
`true, false, true, false, true`.  Dishes `0` and `2` look identical for three
runs and part company on the fourth. -/
def clockTest : Test (Fin 5) :=
  fun j => (![true, false, true, false, true] j, ![1, 0, 3, 4, 2] j)

theorem clock_distinguishing_delay :
    (∀ j < 3, transcript clockTest 0 j = transcript clockTest 2 j) ∧
      transcript clockTest 0 3 ≠ transcript clockTest 2 3 := by
  refine ⟨by decide, by decide⟩

end DestructiveVerification