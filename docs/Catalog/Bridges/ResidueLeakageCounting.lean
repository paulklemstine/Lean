/-
# Counting the leakage: the fingerprint carries exactly `K` bits

Sixth file of the residue-leakage thread.  `qrFingerprint_range_eq` identifies
the range of the fingerprint on primes with the set of `±1`-vectors of length
`K`.  Here we count that set, so that the leakage curve becomes an exact
number:

`|{ F_A(q) : q prime, q ∉ A }| = 2^K`.

Combined with `dirichlet_no_pruning` this is the quantitative form of the
verdict: the channel emits exactly `K` bits about `N`, and none of them about
the individual factors.
-/

import Mathlib
import Bridges.ResidueLeakagePatternSurjectivity

namespace Bridges.ResidueLeakage

/-- The set of `±1`-vectors of length `n`, as lists. -/
def signVectors (n : ℕ) : Set (List ℤ) :=
  {v : List ℤ | v.length = n ∧ ∀ x ∈ v, x = 1 ∨ x = -1}

@[simp] theorem signVectors_zero : signVectors 0 = {([] : List ℤ)} := by
  ext v
  simp only [signVectors, Set.mem_setOf_eq, Set.mem_singleton_iff]
  constructor
  · rintro ⟨hlen, -⟩; exact List.length_eq_zero_iff.1 hlen
  · rintro rfl; exact ⟨rfl, by simp⟩

theorem signVectors_succ (n : ℕ) :
    signVectors (n + 1) =
      (List.cons 1 '' signVectors n) ∪ (List.cons (-1) '' signVectors n) := by
  ext v
  constructor
  · rintro ⟨hlen, hv⟩
    obtain ⟨x, w, rfl⟩ : ∃ x w, v = x :: w := by
      cases v with
      | nil => simp at hlen
      | cons x w => exact ⟨x, w, rfl⟩
    have hw : w ∈ signVectors n :=
      ⟨by simpa using hlen, fun y hy => hv y (List.mem_cons_of_mem _ hy)⟩
    rcases hv x (by simp) with hx | hx
    · exact Or.inl ⟨w, hw, by rw [hx]⟩
    · exact Or.inr ⟨w, hw, by rw [hx]⟩
  · rintro (⟨w, ⟨hlen, hw⟩, rfl⟩ | ⟨w, ⟨hlen, hw⟩, rfl⟩) <;>
      refine ⟨by simpa using hlen, ?_⟩ <;> intro y hy <;>
      rcases List.mem_cons.1 hy with rfl | hy
    · exact Or.inl rfl
    · exact hw y hy
    · exact Or.inr rfl
    · exact hw y hy

theorem signVectors_finite (n : ℕ) : (signVectors n).Finite := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [signVectors_succ]
      exact (ih.image _).union (ih.image _)

/-- **Exactly `2^n` sign vectors.** -/
theorem signVectors_ncard (n : ℕ) : (signVectors n).ncard = 2 ^ n := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hinj1 : Function.Injective (List.cons (1 : ℤ)) := by
        intro a b hab; simpa using hab
      have hinj2 : Function.Injective (List.cons (-1 : ℤ)) := by
        intro a b hab; simpa using hab
      have hdisj : Disjoint (List.cons (1 : ℤ) '' signVectors n)
          (List.cons (-1 : ℤ) '' signVectors n) := by
        rw [Set.disjoint_left]
        rintro v ⟨w, -, rfl⟩ ⟨w', -, hw'⟩
        have : (1 : ℤ) = -1 := by
          have := congrArg (fun l : List ℤ => l.head?) hw'
          simpa using this.symm
        norm_num at this
      rw [signVectors_succ, Set.ncard_union_eq hdisj
        ((signVectors_finite n).image _) ((signVectors_finite n).image _),
        Set.ncard_image_of_injective _ hinj1,
        Set.ncard_image_of_injective _ hinj2, ih]
      ring

/-- **The leakage is exactly `K` bits.**  For a duplicate-free list of `K` probe
primes, the fingerprints of the primes outside the probe set number exactly
`2^K`. -/
theorem qrFingerprint_range_ncard {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    (hnd : A.Nodup) :
    {v : List ℤ | ∃ q : ℕ, q.Prime ∧ q ∉ A ∧ qrFingerprint A q = v}.ncard
      = 2 ^ A.length := by
  rw [qrFingerprint_range_eq hA hnd]
  exact signVectors_ncard A.length

/-- The same statement for the first `K` primes: the QR fingerprint over the
first `K` primes takes exactly `2^K` values on primes. -/
theorem primeBasis_range_ncard (K : ℕ) :
    {v : List ℤ | ∃ q : ℕ, q.Prime ∧ q ∉ primeBasis K ∧
        qrFingerprint (primeBasis K) q = v}.ncard = 2 ^ K := by
  have := qrFingerprint_range_ncard (A := primeBasis K)
    (fun _ ha => primeBasis_prime ha) (primeBasis_nodup K)
  simpa using this

end Bridges.ResidueLeakage