import Mathlib

/-!
# Symmetric-readout vacuity and the exact `1/2` which-factor wall

Standing finding 6 of the campaign ("for an unordered secret and an
order-sensitive label, every public-input readout is blind") and the
"exact which-factor wall" of the Galois side-channel closure are made precise
here as a *counting* theorem, with an attaining decoder.

Setting: a finite secret set `S`, an involution `σ` of `S` (e.g. swapping the
two prime factors), a public readout `R` with `R ∘ σ = R` (e.g. `N = p·q`), and
a label `L` with `L (σ x) ≠ L x` (e.g. "the first factor").

* `which_factor_wall`: **every** decoder `D` is correct on at most half of `S`:
  `2 · #{x ∈ S | D (R x) = L x} ≤ #S`.
* `symmetric_readout_vacuity`: in particular no decoder is correct on all of a
  nonempty `S`.
* `semiprime_which_factor_wall`: the instance `S = ` ordered pairs of distinct
  primes from a finite set `P`, `R (p,q) = p q`, `L (p,q) = p`.
* `minFac_attains_wall`: the decoder `N ↦ N.minFac` is correct on **exactly**
  half of `S`, so the wall `1/2` is sharp.
-/

namespace FactoringFrontier.WhichFactor

open Finset

section Abstract

variable {X Y Z : Type*} [DecidableEq X] [DecidableEq Z]

/-- **The which-factor wall.**  Under a readout invariant under an involution
that flips the label, any decoder succeeds on at most half of the secrets. -/
theorem which_factor_wall (S : Finset X) (σ : X → X) (hσS : ∀ x ∈ S, σ x ∈ S)
    (hinv : ∀ x, σ (σ x) = x) (R : X → Y) (hR : ∀ x, R (σ x) = R x)
    (L : X → Z) (hL : ∀ x ∈ S, L (σ x) ≠ L x) (D : Y → Z) :
    2 * (S.filter (fun x => D (R x) = L x)).card ≤ S.card := by
  set T := S.filter (fun x => D (R x) = L x) with hT
  have hinj : Set.InjOn σ (T : Set X) := fun x _ y _ hxy => by
    rw [← hinv x, ← hinv y, hxy]
  have himg_card : (T.image σ).card = T.card := card_image_of_injOn hinj
  have hdisj : Disjoint T (T.image σ) := by
    rw [disjoint_left]
    intro x hxT hxI
    obtain ⟨y, hyT, rfl⟩ := mem_image.1 hxI
    have hy := (mem_filter.1 hyT)
    have hx := (mem_filter.1 hxT)
    -- `D (R (σ y)) = D (R y) = L y`, but also `= L (σ y)`
    apply hL y hy.1
    rw [← hx.2, hR, hy.2]
  have hsub : T ∪ T.image σ ⊆ S := by
    intro x hx
    rcases mem_union.1 hx with h | h
    · exact (mem_filter.1 h).1
    · obtain ⟨y, hyT, rfl⟩ := mem_image.1 h
      exact hσS y (mem_filter.1 hyT).1
  have := card_le_card hsub
  rw [card_union_of_disjoint hdisj, himg_card] at this
  omega

/-- **Symmetric-readout vacuity.**  On a nonempty secret set, no decoder of a
symmetric readout recovers an order-sensitive label everywhere. -/
theorem symmetric_readout_vacuity (S : Finset X) (hS : S.Nonempty) (σ : X → X)
    (hσS : ∀ x ∈ S, σ x ∈ S) (hinv : ∀ x, σ (σ x) = x) (R : X → Y)
    (hR : ∀ x, R (σ x) = R x) (L : X → Z) (hL : ∀ x ∈ S, L (σ x) ≠ L x) (D : Y → Z) :
    ¬ ∀ x ∈ S, D (R x) = L x := by
  intro hall
  have hw := which_factor_wall S σ hσS hinv R hR L hL D
  rw [filter_true_of_mem hall] at hw
  have := hS.card_pos
  omega

end Abstract

section Semiprime

/-- Ordered pairs of distinct elements of `P`. -/
def orderedPairs (P : Finset ℕ) : Finset (ℕ × ℕ) := P.offDiag

/-- **Semiprime which-factor wall.**  For any decoder `D : ℕ → ℕ`, the number of
ordered pairs `(p, q)` of distinct elements of `P` with `D (p q) = p` is at most
half the number of pairs. -/
theorem semiprime_which_factor_wall (P : Finset ℕ) (D : ℕ → ℕ) :
    2 * ((orderedPairs P).filter (fun x => D (x.1 * x.2) = x.1)).card
      ≤ (orderedPairs P).card := by
  refine which_factor_wall (orderedPairs P) Prod.swap ?_ (fun x => Prod.swap_swap x)
    (fun x => x.1 * x.2) (fun x => Nat.mul_comm _ _) Prod.fst ?_ D
  · intro x hx
    simp only [orderedPairs, mem_offDiag] at hx ⊢
    exact ⟨hx.2.1, hx.1, fun h => hx.2.2 h.symm⟩
  · intro x hx
    simp only [orderedPairs, mem_offDiag] at hx
    exact fun h => hx.2.2 h.symm

/-- The ordered pairs split evenly into increasing and decreasing ones. -/
theorem two_mul_card_lt_pairs (P : Finset ℕ) :
    2 * ((orderedPairs P).filter (fun x => x.1 < x.2)).card = (orderedPairs P).card := by
  set U := (orderedPairs P).filter (fun x => x.1 < x.2)
  set W := (orderedPairs P).filter (fun x => ¬ x.1 < x.2)
  have hsplit := card_filter_add_card_filter_not
    (s := orderedPairs P) (fun x : ℕ × ℕ => x.1 < x.2)
  have hW : W = U.image Prod.swap := by
    ext x
    simp only [W, U, orderedPairs, mem_filter, mem_offDiag, mem_image]
    constructor
    · rintro ⟨⟨h1, h2, h3⟩, h4⟩
      refine ⟨x.swap, ⟨⟨h2, h1, fun h => h3 h.symm⟩, ?_⟩, Prod.swap_swap x⟩
      simp only [Prod.fst_swap, Prod.snd_swap]
      omega
    · rintro ⟨y, ⟨⟨h1, h2, h3⟩, h4⟩, rfl⟩
      simp only [Prod.fst_swap, Prod.snd_swap]
      exact ⟨⟨h2, h1, fun h => h3 h.symm⟩, by omega⟩
  have hWc : W.card = U.card := by
    rw [hW]; exact card_image_of_injective _ Prod.swap_injective
  change U.card + W.card = _ at hsplit
  omega

/-- **The wall is sharp.**  If `P` consists of primes, the decoder
`N ↦ N.minFac` is correct on exactly half of the ordered pairs. -/
theorem minFac_attains_wall (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) :
    2 * ((orderedPairs P).filter (fun x => (x.1 * x.2).minFac = x.1)).card
      = (orderedPairs P).card := by
  rw [← two_mul_card_lt_pairs P]
  congr 2
  apply filter_congr
  intro x hx
  simp only [orderedPairs, mem_offDiag] at hx
  obtain ⟨hp, hq, hne⟩ := hx
  have hpP := hP _ hp
  have hqP := hP _ hq
  -- the least prime factor of `p q` is `min p q`
  have hmin : (x.1 * x.2).minFac = min x.1 x.2 := by
    have hdvd : (x.1 * x.2).minFac ∣ x.1 * x.2 := Nat.minFac_dvd _
    have hpr : (x.1 * x.2).minFac.Prime :=
      Nat.minFac_prime (by nlinarith [hpP.two_le, hqP.two_le] : 1 < x.1 * x.2).ne'
    rcases (Nat.Prime.dvd_mul hpr).1 hdvd with h | h
    · have e1 := (Nat.prime_dvd_prime_iff_eq hpr hpP).1 h
      have le2 : (x.1 * x.2).minFac ≤ x.2 :=
        Nat.minFac_le_of_dvd hqP.two_le (Dvd.intro_left _ rfl)
      rw [e1] at le2 ⊢; exact (min_eq_left le2).symm
    · have e1 := (Nat.prime_dvd_prime_iff_eq hpr hqP).1 h
      have le2 : (x.1 * x.2).minFac ≤ x.1 :=
        Nat.minFac_le_of_dvd hpP.two_le (Dvd.intro _ rfl)
      rw [e1] at le2 ⊢; exact (min_eq_right le2).symm
  rw [hmin]
  constructor
  · intro h; rcases lt_or_gt_of_ne hne with h' | h'
    · exact h'
    · rw [min_eq_right h'.le] at h; omega
  · intro h; exact min_eq_left h.le

/-! ## Lab notes (kernel-checked)

`P = {2,3,5,7}`: `12` ordered pairs; the `minFac` decoder is right on the `6`
increasing ones; the "max factor" decoder `N ↦ N / N.minFac` on the other `6`. -/

example : 2 * ((orderedPairs {2, 3, 5, 7}).filter
    (fun x => (x.1 * x.2).minFac = x.1)).card = 12 := by
  rw [minFac_attains_wall]
  · decide
  · intro p hp
    simp only [mem_insert, mem_singleton] at hp
    rcases hp with rfl | rfl | rfl | rfl <;> norm_num

example : (orderedPairs {2, 3, 5, 7}).card = 12 := by decide

end Semiprime

end FactoringFrontier.WhichFactor