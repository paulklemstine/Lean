/-
# Destructive verification VI: `#D` runs decide everything

`Combinatorics.DestructiveVerificationIndistinguishability` proves that two
dishes agreeing on the first `2 · #D` verdicts of a test agree forever.  This
file halves the constant: **`#D` runs suffice**, matching the destruction-depth
horizon of `transcript_rigid`.  So a single number — the number of dishes —
governs both phenomena: after `#D` runs a transcript can no longer change its
mind, and after `#D` runs two dishes can no longer part company.

The improvement needs genuinely more structure than the previous bound.  We
replace the pigeonhole recurrence by the **minimal** recurrence of an orbit
(`DestructiveVerification.exists_minimal_recurrence`), which gives three things
at once: the first `i + p` orbit points are pairwise distinct (so `i + p ≤ #D`),
every orbit point is one of them, and the period `p` divides every eventual
period of the orbit (`period_dvd_of_eventual_period`).

Then the two orbits are compared by an **orbit dichotomy**:

* if they never meet, their point sets are disjoint, so
  `(i₁ + p₁) + (i₂ + p₂) ≤ #D` and the Fine–Wilf window
  `max i₁ i₂ + p₁ + p₂ - gcd p₁ p₂` fits inside `#D`;
* if they do meet (`orbit_period_eq_of_meet`), each period is an eventual period
  of the other orbit, so `p₁ = p₂`, the gcd absorbs one of them, and the window
  collapses to `max i₁ i₂ + p₁ ≤ #D`.

Main results: `DestructiveVerification.transcript_indistinguishable_card` and
its prefix form `DestructiveVerification.indistinguishable_iff_card_prefix`.
Exhaustive enumeration (see `ComputationalEvidence.md`) shows the true threshold
is `#D - 1`; the remaining gap of one is recorded as Conjecture 1 of
`FUTURE_DIRECTIONS.md`.
-/
import Mathlib
import Combinatorics.DestructiveVerification
import Combinatorics.DestructiveVerificationDepth
import Combinatorics.DestructiveVerificationRealization
import Combinatorics.DestructiveVerificationIndistinguishability

namespace DestructiveVerification

variable {D : Type*}

/-! ## 1. The minimal recurrence of an orbit -/

/-- Every orbit point of `d` is one of the first `i + p` points, once
`f^[i+p] d = f^[i] d`. -/
lemma orbit_rep_of_recurrence {f : D → D} {d : D} {i p : ℕ} (hp : 0 < p)
    (hrec : f^[i + p] d = f^[i] d) (m : ℕ) : ∃ j < i + p, f^[m] d = f^[j] d := by
  by_cases hm : m < i
  · exact ⟨m, by omega, rfl⟩
  · push_neg at hm
    have hy : Function.IsPeriodicPt f p (f^[i] d) := by
      show f^[p] (f^[i] d) = f^[i] d
      rw [← Function.iterate_add_apply, Nat.add_comm p i]
      exact hrec
    refine ⟨i + (m - i) % p, by have := Nat.mod_lt (m - i) hp; omega, ?_⟩
    have h1 : f^[m] d = f^[m - i] (f^[i] d) := by
      rw [← Function.iterate_add_apply]; congr 1; omega
    have h2 : f^[i + (m - i) % p] d = f^[(m - i) % p] (f^[i] d) := by
      rw [← Function.iterate_add_apply]; congr 1; omega
    rw [h1, h2, hy.iterate_mod_apply]

/-- **Minimal recurrence.**  Every orbit in a finite dish space has a shortest
recurrence `f^[i+p] d = f^[i] d`; its first `i + p` points are pairwise
distinct. -/
theorem exists_minimal_recurrence [Fintype D] (f : D → D) (d : D) :
    ∃ i p, 0 < p ∧ f^[i + p] d = f^[i] d ∧
      (∀ a b, a < b → b < i + p → f^[a] d ≠ f^[b] d) := by
  classical
  have hex : ∃ k, ∃ i p, 0 < p ∧ i + p = k ∧ f^[k] d = f^[i] d := by
    obtain ⟨i, p, hp, _, hrec⟩ := exists_orbit_recurrence f d
    exact ⟨i + p, i, p, hp, rfl, hrec⟩
  obtain ⟨i, p, hp, hik, hrec⟩ := Nat.find_spec hex
  refine ⟨i, p, hp, by rw [hik]; exact hrec, ?_⟩
  intro a b hab hb hcon
  have hmin := Nat.find_min hex (m := b) (by omega)
  exact hmin ⟨a, b - a, by omega, by omega, hcon.symm⟩

/-- The points of a minimal recurrence are `i + p` distinct dishes, so
`i + p ≤ #D`. -/
theorem card_orbit_of_minimal [Fintype D] [DecidableEq D] {f : D → D} {d : D} {i p : ℕ}
    (hdist : ∀ a b, a < b → b < i + p → f^[a] d ≠ f^[b] d) :
    ((Finset.range (i + p)).image (fun j => f^[j] d)).card = i + p := by
  rw [Finset.card_image_of_injOn, Finset.card_range]
  intro a ha b hb hab
  simp only [Finset.coe_range, Set.mem_Iio] at ha hb
  by_contra hne
  rcases lt_or_gt_of_ne hne with h | h
  · exact hdist a b h hb hab
  · exact hdist b a h ha hab.symm

theorem minimal_recurrence_card_le [Fintype D] {f : D → D} {d : D} {i p : ℕ}
    (hdist : ∀ a b, a < b → b < i + p → f^[a] d ≠ f^[b] d) :
    i + p ≤ Fintype.card D := by
  classical
  have h := card_orbit_of_minimal (f := f) (d := d) (i := i) (p := p) hdist
  have hle := Finset.card_le_univ ((Finset.range (i + p)).image (fun j => f^[j] d))
  omega

/-- **Minimality of the period.**  For the shortest recurrence, `p` divides
every eventual period of the orbit. -/
theorem period_dvd_of_eventual_period [Fintype D] {f : D → D} {d : D} {i p : ℕ}
    (hp : 0 < p) (hrec : f^[i + p] d = f^[i] d)
    (hdist : ∀ a b, a < b → b < i + p → f^[a] d ≠ f^[b] d)
    {q J : ℕ} (hJ : ∀ m, J ≤ m → f^[m + q] d = f^[m] d) :
    p ∣ q := by
  set s : ℕ → D := fun m => f^[i + m] d with hs
  have hsper : ∀ m, s (m + p) = s m := by
    intro m
    have h1 : i + (m + p) = (i + m) + p := by omega
    simp only [hs, h1]
    exact iterate_period_of_recurrence hrec (i + m) (by omega)
  have hsmod : ∀ m, s m = s (m % p) := eq_mod_period s hp hsper
  set M := i + p * (J + 1) with hM
  have hMJ : J ≤ M := by nlinarith
  have hM1 : f^[M] d = f^[i] d := by
    have : f^[M] d = s (p * (J + 1)) := rfl
    rw [this, hsmod (p * (J + 1))]
    simp [hs, Nat.mul_mod_right]
  have hM2 : f^[M + q] d = f^[i + q % p] d := by
    have h1 : f^[M + q] d = s (p * (J + 1) + q) := by
      simp only [hs, hM]; congr 1; omega
    rw [h1, hsmod (p * (J + 1) + q)]
    have h2 : (p * (J + 1) + q) % p = q % p := by
      rw [Nat.add_comm, Nat.add_mul_mod_self_left]
    rw [h2]
  have hkey : f^[i + q % p] d = f^[i] d := by rw [← hM2, hJ M hMJ, hM1]
  by_contra hcon
  have hr : 0 < q % p := by
    rcases Nat.eq_zero_or_pos (q % p) with h | h
    · exact absurd (Nat.dvd_of_mod_eq_zero h) hcon
    · exact h
  have hrlt : q % p < p := Nat.mod_lt _ hp
  exact hdist i (i + q % p) (by omega) (by omega) hkey.symm

/-! ## 2. The orbit dichotomy -/

/-- If two orbits meet, their minimal periods coincide: they are running around
the same cycle. -/
theorem orbit_period_eq_of_meet [Fintype D] {f : D → D} {d e : D} {i₁ p₁ i₂ p₂ : ℕ}
    (hp₁ : 0 < p₁) (hrec₁ : f^[i₁ + p₁] d = f^[i₁] d)
    (hdist₁ : ∀ a b, a < b → b < i₁ + p₁ → f^[a] d ≠ f^[b] d)
    (hp₂ : 0 < p₂) (hrec₂ : f^[i₂ + p₂] e = f^[i₂] e)
    (hdist₂ : ∀ a b, a < b → b < i₂ + p₂ → f^[a] e ≠ f^[b] e)
    {a b : ℕ} (hab : f^[a] d = f^[b] e) : p₁ = p₂ := by
  have hshift : ∀ c, f^[c + a] d = f^[c + b] e := by
    intro c
    rw [Function.iterate_add_apply, Function.iterate_add_apply, hab]
  -- `p₁` is an eventual period of the orbit of `e`
  have hp₁e : ∀ m, b + i₁ ≤ m → f^[m + p₁] e = f^[m] e := by
    intro m hm
    have hc : (m - b) + b = m := by omega
    have h1 : f^[m] e = f^[(m - b) + a] d := by rw [hshift (m - b), hc]
    have h2 : f^[m + p₁] e = f^[((m - b) + p₁) + b] e := by congr 1; omega
    rw [h2, ← hshift ((m - b) + p₁), h1]
    have h3 : (m - b) + p₁ + a = ((m - b) + a) + p₁ := by omega
    rw [h3]
    exact iterate_period_of_recurrence hrec₁ ((m - b) + a) (by omega)
  -- and symmetrically
  have hp₂d : ∀ m, a + i₂ ≤ m → f^[m + p₂] d = f^[m] d := by
    intro m hm
    have hc : (m - a) + a = m := by omega
    have h1 : f^[m] d = f^[(m - a) + b] e := by rw [← hshift (m - a), hc]
    have h2 : f^[m + p₂] d = f^[((m - a) + p₂) + a] d := by congr 1; omega
    rw [h2, hshift ((m - a) + p₂), h1]
    have h3 : (m - a) + p₂ + b = ((m - a) + b) + p₂ := by omega
    rw [h3]
    exact iterate_period_of_recurrence hrec₂ ((m - a) + b) (by omega)
  have hd1 : p₂ ∣ p₁ :=
    period_dvd_of_eventual_period hp₂ hrec₂ hdist₂ hp₁e
  have hd2 : p₁ ∣ p₂ :=
    period_dvd_of_eventual_period hp₁ hrec₁ hdist₁ hp₂d
  exact Nat.dvd_antisymm hd2 hd1

/-- If two orbits never meet, their point sets are disjoint, so their sizes add
up to at most `#D`. -/
theorem card_add_card_le_of_disjoint [Fintype D] [DecidableEq D] {f : D → D} {d e : D} {i₁ p₁ i₂ p₂ : ℕ}
    (hdist₁ : ∀ a b, a < b → b < i₁ + p₁ → f^[a] d ≠ f^[b] d)
    (hdist₂ : ∀ a b, a < b → b < i₂ + p₂ → f^[a] e ≠ f^[b] e)
    (hmeet : ∀ a b, f^[a] d ≠ f^[b] e) :
    (i₁ + p₁) + (i₂ + p₂) ≤ Fintype.card D := by
  set S₁ := (Finset.range (i₁ + p₁)).image (fun j => f^[j] d) with hS₁
  set S₂ := (Finset.range (i₂ + p₂)).image (fun j => f^[j] e) with hS₂
  have hdisj : Disjoint S₁ S₂ := by
    rw [Finset.disjoint_left]
    rintro x hx₁ hx₂
    simp only [hS₁, hS₂, Finset.mem_image, Finset.mem_range] at hx₁ hx₂
    obtain ⟨j₁, -, rfl⟩ := hx₁
    obtain ⟨j₂, -, hj₂⟩ := hx₂
    exact hmeet j₁ j₂ hj₂.symm
  have hcard : S₁.card + S₂.card = (S₁ ∪ S₂).card := (Finset.card_union_of_disjoint hdisj).symm
  rw [card_orbit_of_minimal hdist₁, card_orbit_of_minimal hdist₂] at hcard
  rw [hcard]
  exact Finset.card_le_univ _

/-! ## 3. `#D` runs decide observational equivalence -/

/-- **Sharpened indistinguishability.**  If two dishes give the same verdict for
the first `#D` runs of a test, they give the same verdict forever.  This matches
the destruction-depth horizon: `#D` runs settle every question that repeated
testing can ask about a dish. -/
theorem transcript_indistinguishable_card [Fintype D] (t : Test D) (d e : D)
    (h : ∀ j < Fintype.card D, transcript t d j = transcript t e j) (m : ℕ) :
    transcript t d m = transcript t e m := by
  classical
  set f := residue t with hf
  obtain ⟨i₁, p₁, hp₁, hrec₁, hdist₁⟩ := exists_minimal_recurrence f d
  obtain ⟨i₂, p₂, hp₂, hrec₂, hdist₂⟩ := exists_minimal_recurrence f e
  have hle₁ : i₁ + p₁ ≤ Fintype.card D := minimal_recurrence_card_le hdist₁
  have hle₂ : i₂ + p₂ ≤ Fintype.card D := minimal_recurrence_card_le hdist₂
  have hper₁ : ∀ m, i₁ ≤ m → transcript t d (m + p₁) = transcript t d m := by
    intro m hm
    simp only [transcript]
    rw [iterate_period_of_recurrence hrec₁ m hm]
  have hper₂ : ∀ m, i₂ ≤ m → transcript t e (m + p₂) = transcript t e m := by
    intro m hm
    simp only [transcript]
    rw [iterate_period_of_recurrence hrec₂ m hm]
  have hwindow : max i₁ i₂ + p₁ + p₂ - Nat.gcd p₁ p₂ ≤ Fintype.card D := by
    by_cases hmeet : ∃ a b, f^[a] d = f^[b] e
    · obtain ⟨a, b, hab⟩ := hmeet
      have hpp : p₁ = p₂ :=
        orbit_period_eq_of_meet hp₁ hrec₁ hdist₁ hp₂ hrec₂ hdist₂ hab
      subst hpp
      have hg : Nat.gcd p₁ p₁ = p₁ := Nat.gcd_self p₁
      rw [hg]
      omega
    · push_neg at hmeet
      have hsum := card_add_card_le_of_disjoint hdist₁ hdist₂ hmeet
      omega
  exact transcript_agree_of_window t d e hp₁ hp₂ hper₁ hper₂ hwindow h m

/-- Observational equivalence is decided by exactly `#D` runs. -/
theorem indistinguishable_iff_card_prefix [Fintype D] (t : Test D) (d e : D) :
    (∀ m, transcript t d m = transcript t e m) ↔
      ∀ j < Fintype.card D, transcript t d j = transcript t e j := by
  constructor
  · intro h j _; exact h j
  · intro h m; exact transcript_indistinguishable_card t d e h m

end DestructiveVerification