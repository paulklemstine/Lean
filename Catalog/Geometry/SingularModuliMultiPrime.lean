/-
# Singular Moduli Factoring for Arbitrary Composites: it is a *smallest-factor*
# finder

Second research cycle, generalising `SingularModuliBarrier.lean` from semiprimes
`N = p q` to arbitrary squarefree composites `N = p₁ ⋯ p_k`.

Chinese Remainder coordinates now live in `∀ i, ZMod (p i)`, and an evaluation
point `j₀` produces a nontrivial gcd exactly when the reduction of `j₀` is a
root of the class polynomial modulo *some but not all* of the primes.  We prove:

* `MultiPrime.card_goodMulti` — the exact partition identity
  `|G| + ∏ r_i + ∏ (p_i - r_i) = ∏ p_i`;
* `MultiPrime.density_le` — the success density is at most `∑ r_i / p_i`
  (a Weierstrass product inequality, proved here from scratch);
* `MultiPrime.expectedTrialsMulti_ge` — hence the expected number of
  evaluations is at least `p_min / (k d)`, where `d` bounds the number of roots
  of the class polynomial modulo each prime and `p_min` is the *smallest* prime
  factor.

Interpretation.  The `√N` bound for balanced semiprimes is not a coincidence of
the two-prime case: singular moduli factoring is intrinsically a **smallest
prime factor** finder, of the same shape as Pollard rho (`Θ(√p_min)` — better in
the exponent) and Pollard `p-1`.  For balanced semiprimes `p_min ≈ √N` and one
recovers the barrier; for an unbalanced `N` with a small factor the method is
fast for exactly the same, uninteresting, reason that trial division is.

Everything is stated for arbitrary root sets `R i ⊆ ZMod (p i)`; no unproved
property of Hilbert class polynomials is used.
-/
import Mathlib

namespace MultiPrime

open Finset

variable {k : ℕ} {P : Fin k → ℕ} [∀ i, NeZero (P i)]

/-- Successful evaluation points for a composite with `k` prime factors, in CRT
coordinates: those lying in the structured set modulo some, but not all, of the
primes. -/
def goodMulti (R : ∀ i, Finset (ZMod (P i))) : Finset (∀ i, ZMod (P i)) :=
  Finset.univ.filter fun x => (∃ i, x i ∈ R i) ∧ (∃ i, x i ∉ R i)

/-- **Exact partition identity.**  The `∏ p_i` residues split into: the ones
that are roots modulo every prime (`∏ r_i` of them), the ones that are roots
modulo no prime (`∏ (p_i - r_i)`), and the successful ones. -/
theorem card_goodMulti (hk : 0 < k) (R : ∀ i, Finset (ZMod (P i))) :
    (goodMulti R).card + (∏ i, (R i).card) + (∏ i, ((R i)ᶜ).card) = ∏ i, P i := by
  classical
  set A : Finset (∀ i, ZMod (P i)) := Fintype.piFinset R with hA
  set B : Finset (∀ i, ZMod (P i)) := Fintype.piFinset (fun i => (R i)ᶜ) with hB
  have hcompl : goodMulti R = (A ∪ B)ᶜ := by
    ext x
    simp only [goodMulti, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_compl,
      Finset.mem_union, hA, hB, Fintype.mem_piFinset, not_or, not_forall]
    constructor
    · rintro ⟨⟨i, hi⟩, ⟨j, hj⟩⟩
      exact ⟨⟨j, hj⟩, ⟨i, by simpa using hi⟩⟩
    · rintro ⟨⟨j, hj⟩, ⟨i, hi⟩⟩
      exact ⟨⟨i, by simpa using hi⟩, ⟨j, hj⟩⟩
  have hdisj : Disjoint A B := by
    rw [Finset.disjoint_left]
    intro x hxA hxB
    rw [hA, Fintype.mem_piFinset] at hxA
    rw [hB, Fintype.mem_piFinset] at hxB
    have i0 : Fin k := ⟨0, hk⟩
    exact (Finset.mem_compl.mp (hxB i0)) (hxA i0)
  have hcardA : A.card = ∏ i, (R i).card := by
    rw [hA, Fintype.card_piFinset]
  have hcardB : B.card = ∏ i, ((R i)ᶜ).card := by
    rw [hB, Fintype.card_piFinset]
  have huniv : Fintype.card (∀ i, ZMod (P i)) = ∏ i, P i := by
    rw [Fintype.card_pi]
    exact Finset.prod_congr rfl fun i _ => ZMod.card (P i)
  have := Finset.card_compl (A ∪ B)
  rw [hcompl, this, Finset.card_union_of_disjoint hdisj, hcardA, hcardB, huniv]
  have hle : (∏ i, (R i).card) + (∏ i, ((R i)ᶜ).card) ≤ ∏ i, P i := by
    calc (∏ i, (R i).card) + (∏ i, ((R i)ᶜ).card)
        = A.card + B.card := by rw [hcardA, hcardB]
      _ = (A ∪ B).card := (Finset.card_union_of_disjoint hdisj).symm
      _ ≤ Fintype.card (∀ i, ZMod (P i)) := Finset.card_le_univ _
      _ = ∏ i, P i := huniv
  omega

/-- Weierstrass product inequality (proved by induction; used to convert the
partition identity into a union bound on densities). -/
theorem one_sub_sum_le_prod_one_sub {ι : Type*} [DecidableEq ι] (s : Finset ι) (x : ι → ℝ)
    (h : ∀ i ∈ s, 0 ≤ x i ∧ x i ≤ 1) :
    1 - ∑ i ∈ s, x i ≤ ∏ i ∈ s, (1 - x i) := by
  classical
  induction s using Finset.cons_induction with
  | empty => simp
  | cons a s ha ih =>
      rw [Finset.sum_cons, Finset.prod_cons]
      have h1 := h a (Finset.mem_cons_self a s)
      have h2 : ∀ i ∈ s, 0 ≤ x i ∧ x i ≤ 1 := fun i hi => h i (Finset.mem_cons_of_mem hi)
      have h3 := ih h2
      have hsum : 0 ≤ ∑ i ∈ s, x i := Finset.sum_nonneg fun i hi => (h2 i hi).1
      nlinarith [h1.1, h1.2, h3, hsum]

/-- **Density bound.**  At most a `∑ r_i / p_i` fraction of all residues are
successful. -/
theorem density_le (hk : 0 < k) (R : ∀ i, Finset (ZMod (P i))) :
    ((goodMulti R).card : ℝ) ≤ (∑ i, ((R i).card : ℝ) / P i) * ∏ i, (P i : ℝ) := by
  classical
  have hP : ∀ i, (0:ℝ) < P i := by
    intro i
    have := Nat.pos_of_ne_zero (NeZero.ne (P i)); exact_mod_cast this
  have hcard := card_goodMulti hk R
  have hrle : ∀ i, ((R i).card : ℝ) ≤ P i := by
    intro i
    have : (R i).card ≤ Fintype.card (ZMod (P i)) := Finset.card_le_univ _
    rw [ZMod.card] at this
    exact_mod_cast this
  have hcompl : ∀ i, (((R i)ᶜ).card : ℝ) = P i - (R i).card := by
    intro i
    have : ((R i)ᶜ).card = Fintype.card (ZMod (P i)) - (R i).card := Finset.card_compl _
    rw [ZMod.card] at this
    have hle : (R i).card ≤ P i := by exact_mod_cast hrle i
    rw [this]
    push_cast [Nat.cast_sub hle]
    ring
  -- pass to real numbers
  have hkey : ((goodMulti R).card : ℝ) + (∏ i, ((R i).card : ℝ)) + (∏ i, (P i - (R i).card : ℝ))
      = ∏ i, (P i : ℝ) := by
    have h := congrArg (fun n : ℕ => (n : ℝ)) hcard
    push_cast at h
    simp only [← hcompl]
    exact h
  set x : Fin k → ℝ := fun i => ((R i).card : ℝ) / P i with hx
  have hx01 : ∀ i ∈ (Finset.univ : Finset (Fin k)), 0 ≤ x i ∧ x i ≤ 1 := by
    intro i _
    constructor
    · positivity
    · rw [hx, div_le_one (hP i)]
      exact hrle i
  have hfac : ∏ i, (P i - (R i).card : ℝ) = (∏ i, (1 - x i)) * ∏ i, (P i : ℝ) := by
    rw [← Finset.prod_mul_distrib]
    refine Finset.prod_congr rfl fun i _ => ?_
    rw [hx]
    have hne : (P i : ℝ) ≠ 0 := ne_of_gt (hP i)
    field_simp
  have hw := one_sub_sum_le_prod_one_sub (Finset.univ : Finset (Fin k)) x hx01
  have hprodpos : (0:ℝ) < ∏ i, (P i : ℝ) := Finset.prod_pos fun i _ => hP i
  have hrprod : (0:ℝ) ≤ ∏ i, ((R i).card : ℝ) := Finset.prod_nonneg fun i _ => by positivity
  nlinarith [hkey, hfac, hw, hprodpos, hrprod,
    mul_le_mul_of_nonneg_right hw (le_of_lt hprodpos)]

/-- Expected number of evaluation points for a composite with `k` prime
factors. -/
noncomputable def expectedTrialsMulti (R : ∀ i, Finset (ZMod (P i))) : ℝ :=
  (∏ i, (P i : ℝ)) / (goodMulti R).card

/-- **The barrier is governed by the smallest prime factor.**  If the class
polynomial has at most `d` roots modulo each prime and every prime is at least
`pmin`, the expected number of evaluations is at least `pmin / (k d)`.  For a
balanced semiprime this is the `√N` barrier; in general the method is a
smallest-factor finder. -/
theorem expectedTrialsMulti_ge (hk : 0 < k) (R : ∀ i, Finset (ZMod (P i))) (d pmin : ℕ)
    (hd : 0 < d) (hdR : ∀ i, (R i).card ≤ d) (hpmin : ∀ i, pmin ≤ P i)
    (hG : 0 < (goodMulti R).card) :
    (pmin : ℝ) / (k * d) ≤ expectedTrialsMulti R := by
  classical
  have hP : ∀ i, (0:ℝ) < P i := by
    intro i
    have := Nat.pos_of_ne_zero (NeZero.ne (P i)); exact_mod_cast this
  rcases Nat.eq_zero_or_pos pmin with hz | hposmin
  · subst hz
    have hprodpos : (0:ℝ) < ∏ i, (P i : ℝ) := Finset.prod_pos fun i _ => hP i
    have : (0:ℝ) ≤ expectedTrialsMulti R := by
      rw [expectedTrialsMulti]; positivity
    simpa using this
  have hpmin0 : (0:ℝ) < pmin := by exact_mod_cast hposmin
  have hd0 : (0:ℝ) < d := by exact_mod_cast hd
  have hk0 : (0:ℝ) < k := by exact_mod_cast hk
  have hG0 : (0:ℝ) < (goodMulti R).card := by exact_mod_cast hG
  have hprodpos : (0:ℝ) < ∏ i, (P i : ℝ) := Finset.prod_pos fun i _ => hP i
  -- each term of the density sum is at most d / pmin
  have hterm : ∀ i, ((R i).card : ℝ) / P i ≤ (d : ℝ) / pmin := by
    intro i
    have h1 : ((R i).card : ℝ) ≤ d := by exact_mod_cast hdR i
    have h2 : (pmin : ℝ) ≤ P i := by exact_mod_cast hpmin i
    calc ((R i).card : ℝ) / P i ≤ (d : ℝ) / P i := by gcongr
      _ ≤ (d : ℝ) / pmin := by gcongr
  have hsum : (∑ i, ((R i).card : ℝ) / P i) ≤ k * ((d : ℝ) / pmin) := by
    calc (∑ i, ((R i).card : ℝ) / P i) ≤ ∑ _i : Fin k, ((d : ℝ) / pmin) :=
          Finset.sum_le_sum fun i _ => hterm i
      _ = k * ((d : ℝ) / pmin) := by simp [Finset.sum_const]
  have hdens := density_le hk R
  have hGle : ((goodMulti R).card : ℝ) ≤ (k * ((d:ℝ) / pmin)) * ∏ i, (P i : ℝ) := by
    refine hdens.trans ?_
    exact mul_le_mul_of_nonneg_right hsum (le_of_lt hprodpos)
  rw [expectedTrialsMulti, div_le_div_iff₀ (by positivity) hG0]
  have hGle' : ((goodMulti R).card : ℝ) * pmin ≤ (k * d) * ∏ i, (P i : ℝ) := by
    have := mul_le_mul_of_nonneg_right hGle (le_of_lt hpmin0)
    calc ((goodMulti R).card : ℝ) * pmin
        ≤ ((k * ((d:ℝ) / pmin)) * ∏ i, (P i : ℝ)) * pmin := this
      _ = (k * d) * ∏ i, (P i : ℝ) := by field_simp
  nlinarith [hGle']

end MultiPrime