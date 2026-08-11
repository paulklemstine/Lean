/-
# Group-like series are not rational: a separation of the two bialgebras

The two bialgebra structures on `K⟨X⟩` studied in *Various bialgebras of representative
functions on free monoids* have very different character groups.  For the concatenation
bialgebra the characters are the Kleene stars of planes (see
`Novelty.FreeMonoidCharacters`), and these are exactly the monoid morphisms `X* → (K,·)`,
hence *representative* functions of rank one.  For the shuffle algebra the characters are
the group-like series; the exponentials `exp(ℓ)` of planes are examples.

This file proves that this second family is *disjoint from the rational world*: over `ℝ`,
the exponential of a nonzero plane is a character of the shuffle algebra which is **not**
a representative function, i.e. its graph is a non-rational noncommutative series.

The mechanism is a Hankel-rank obstruction: if `exp(ℓ)` were representative then, by the
Kleene–Schützenberger theorem proved in `Novelty.RepresentativeFunctions`, the left
translates of `exp(ℓ)` would span a finite dimensional space, so finitely many translates
along a single letter `a` would be linearly dependent.  Such a dependency is a relation

`Σ_{i ≤ N} gᵢ · tⁱ⁺ⁿ / (i+n)! = 0` for every `n`,

and `factorial_relation_vanishes` shows — by an Archimedean estimate on the factorial
ratios `(n+k)!/(n+i)!` — that all the coefficients must vanish.  Equivalently: the
infinite Hankel matrix `[1/(m+n)!]` has infinite rank.
-/
import Novelty.FreeMonoidCharacters
import Novelty.RepresentativeFunctions

namespace ShuffleCharacterNotRational

open RepresentativeFunctions FreeMonoidShuffle

/-! ## The analytic core: a Hankel-type nonsingularity statement -/

lemma factorial_ratio_le (n k i : ℕ) (hk : k + 1 ≤ i) :
    ((n + k).factorial : ℝ) / (n + i).factorial ≤ 1 / (n + k + 1) := by
  rw [div_le_div_iff₀ (by positivity) (by positivity)]
  have h1 : ((n + k + 1).factorial : ℝ) ≤ (n + i).factorial := by
    exact_mod_cast Nat.factorial_le (by omega)
  have h2 : ((n + k + 1).factorial : ℝ) = ((n : ℝ) + k + 1) * (n + k).factorial := by
    rw [show n + k + 1 = (n + k) + 1 from rfl, Nat.factorial_succ]
    push_cast; ring
  nlinarith [(Nat.cast_pos (α := ℝ)).2 (Nat.factorial_pos (n + k))]

/-- **The rows of the Hankel matrix `[1/(m+n)!]` are linearly independent.**  If a finite
linear combination of the sequences `n ↦ 1/(n+i)!` vanishes identically, all its
coefficients vanish.  The proof is a downward Archimedean estimate: after rescaling by
`(n+k)!`, the `k`-th coefficient is bounded by `M/(n+1)` for every `n`. -/
theorem factorial_relation_vanishes (N : ℕ) (g : ℕ → ℝ)
    (h : ∀ n : ℕ, ∑ i ∈ Finset.range (N + 1),
      g i * ((n.factorial : ℝ) / (n + i).factorial) = 0) :
    ∀ k ∈ Finset.range (N + 1), g k = 0 := by
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
  intro hk
  set M := ∑ i ∈ Finset.range (N + 1), |g i| with hM
  have hM0 : 0 ≤ M := Finset.sum_nonneg fun i _ => abs_nonneg _
  have hscale : ∀ n : ℕ,
      ∑ i ∈ Finset.range (N + 1), g i * (((n + k).factorial : ℝ) / (n + i).factorial) = 0 := by
    intro n
    have hfac : ((n.factorial : ℝ)) ≠ 0 := Nat.cast_ne_zero.2 (Nat.factorial_ne_zero _)
    have hc := congrArg (fun x : ℝ => x * (((n + k).factorial : ℝ) / n.factorial)) (h n)
    simp only [zero_mul, Finset.sum_mul] at hc
    rw [← hc]
    refine Finset.sum_congr rfl fun i _ => ?_
    field_simp
  have hbound : ∀ n : ℕ, |g k| ≤ M / (n + 1) := by
    intro n
    have hsplit0 := Finset.add_sum_erase (Finset.range (N + 1))
      (fun i => g i * (((n + k).factorial : ℝ) / (n + i).factorial)) hk
    have hsplit : g k * (((n + k).factorial : ℝ) / (n + k).factorial)
        + ∑ i ∈ (Finset.range (N + 1)).erase k,
            g i * (((n + k).factorial : ℝ) / (n + i).factorial) = 0 := hsplit0.trans (hscale n)
    rw [div_self (by positivity : ((n + k).factorial : ℝ) ≠ 0), mul_one] at hsplit
    have habs : |g k| ≤ ∑ i ∈ (Finset.range (N + 1)).erase k,
        |g i * (((n + k).factorial : ℝ) / (n + i).factorial)| := by
      have hgk : g k = -∑ i ∈ (Finset.range (N + 1)).erase k,
          g i * (((n + k).factorial : ℝ) / (n + i).factorial) := by linarith
      rw [hgk, abs_neg]
      exact Finset.abs_sum_le_sum_abs _ _
    have hterm : ∀ i ∈ (Finset.range (N + 1)).erase k,
        |g i * (((n + k).factorial : ℝ) / (n + i).factorial)| ≤ |g i| / ((n : ℝ) + k + 1) := by
      intro i hi
      have hik : i ≠ k := (Finset.mem_erase.1 hi).1
      rcases lt_or_gt_of_ne hik with hlt | hgt
      · have hz : g i = 0 := ih i hlt (Finset.mem_of_mem_erase hi)
        rw [hz]
        simp
      · rw [abs_mul,
          abs_of_nonneg (by positivity : (0:ℝ) ≤ ((n + k).factorial : ℝ) / (n + i).factorial)]
        have hr := factorial_ratio_le n k i (by omega)
        have habs2 : (0:ℝ) ≤ |g i| := abs_nonneg _
        calc |g i| * (((n + k).factorial : ℝ) / (n + i).factorial)
            ≤ |g i| * (1 / ((n : ℝ) + k + 1)) := by nlinarith
          _ = |g i| / ((n : ℝ) + k + 1) := by ring
    have hsum2 := Finset.sum_le_sum hterm
    have hsum3 : ∑ i ∈ (Finset.range (N + 1)).erase k, |g i| / ((n : ℝ) + k + 1)
        ≤ M / ((n : ℝ) + 1) := by
      rw [← Finset.sum_div]
      have h1 : ∑ i ∈ (Finset.range (N + 1)).erase k, |g i| ≤ M :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.erase_subset _ _)
          (fun i _ _ => abs_nonneg _)
      have hnn : (0:ℝ) ≤ ∑ i ∈ (Finset.range (N + 1)).erase k, |g i| :=
        Finset.sum_nonneg fun i _ => abs_nonneg _
      have hk0 : (0:ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
      have h2 : (0:ℝ) < (n : ℝ) + 1 := by positivity
      calc (∑ i ∈ (Finset.range (N + 1)).erase k, |g i|) / ((n : ℝ) + k + 1)
          ≤ M / ((n : ℝ) + k + 1) := by gcongr
        _ ≤ M / ((n : ℝ) + 1) := by gcongr; linarith
    linarith
  by_contra hne
  have hpos : 0 < |g k| := abs_pos.2 hne
  obtain ⟨n, hn⟩ := exists_nat_gt (M / |g k|)
  have hb := hbound n
  rw [div_lt_iff₀ hpos] at hn
  have h2 : (0:ℝ) < (n : ℝ) + 1 := by positivity
  rw [le_div_iff₀ h2] at hb
  nlinarith

/-! ## The separation theorem -/

/-- **The exponential of a nonzero plane is not a representative function.**  Equivalently,
a nontrivial group-like series for the unshuffle coproduct is never rational: the shuffle
characters and the concatenation characters of `K⟨X⟩` live in genuinely different worlds. -/
theorem not_isRepresentative_expPlane {X : Type*} (a : X) (c : X → ℝ) (hc : c a ≠ 0) :
    ¬ IsRepresentative (expPlane c) := by
  intro hrep
  set f : List X → ℝ := expPlane c with hf
  have hfin := finiteDimensional_transSpace_of_isRepresentative hrep
  set N := Module.finrank ℝ (transSpace f) with hN
  set B : Fin (N + 1) → transSpace f := fun i =>
    ⟨ltrans (List.replicate (i : ℕ) a) f, ltrans_mem_transSpace f _⟩ with hB
  have hnli : ¬ LinearIndependent ℝ B := by
    intro hli
    have h := hli.fintype_card_le_finrank
    simp only [Fintype.card_fin] at h
    omega
  obtain ⟨g, hsum, i0, hi0⟩ := Fintype.not_linearIndependent_iff.1 hnli
  have hfval : ∀ k : ℕ, f (List.replicate k a) = (c a) ^ k / (Nat.factorial k) := by
    intro k; simp [hf, expPlane, List.map_replicate, List.prod_replicate]
  have hval : ∀ n : ℕ,
      ∑ i : Fin (N + 1), g i * ((c a) ^ ((i : ℕ) + n) / (Nat.factorial ((i : ℕ) + n))) = 0 := by
    intro n
    have hc0 := congrArg (fun v : transSpace f => (v : List X → ℝ) (List.replicate n a)) hsum
    simp only [Submodule.coe_sum, Submodule.coe_smul, ZeroMemClass.coe_zero,
      Finset.sum_apply, Pi.zero_apply, Pi.smul_apply, smul_eq_mul] at hc0
    rw [← hc0]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [← hfval]
    simp [hB, ltrans, List.replicate_append_replicate]
  set t := c a with ht
  set G : ℕ → ℝ := fun i => if h : i < N + 1 then g ⟨i, h⟩ * t ^ i else 0 with hG
  have hrel : ∀ n : ℕ,
      ∑ i ∈ Finset.range (N + 1), G i * ((n.factorial : ℝ) / (n + i).factorial) = 0 := by
    intro n
    have htn : (t ^ n : ℝ) ≠ 0 := pow_ne_zero _ hc
    have hfn : ((n.factorial : ℝ)) ≠ 0 := Nat.cast_ne_zero.2 (Nat.factorial_ne_zero _)
    have h2 := congrArg (fun x : ℝ => x * ((n.factorial : ℝ) / t ^ n)) (hval n)
    simp only [zero_mul, Finset.sum_mul] at h2
    rw [← h2, ← Fin.sum_univ_eq_sum_range
      (fun i => G i * ((n.factorial : ℝ) / (n + i).factorial)) (N + 1)]
    refine Finset.sum_congr rfl fun i _ => ?_
    have hi : (i : ℕ) < N + 1 := i.2
    simp only [hG, dif_pos hi]
    rw [show ((i : ℕ) + n) = (n + (i : ℕ)) from Nat.add_comm _ _, pow_add]
    field_simp
  have hzero := factorial_relation_vanishes N G hrel (i0 : ℕ) (Finset.mem_range.2 i0.2)
  simp only [hG, dif_pos i0.2] at hzero
  refine hi0 ?_
  rcases mul_eq_zero.1 hzero with h | h
  · exact h
  · exact absurd h (pow_ne_zero _ hc)

/-- Summary of the separation: over `ℝ`, `exp(ℓ)` for a nonzero plane `ℓ` is a shuffle
character which is not representative, while the Kleene star `ℓ*` of the same plane is a
representative function (of rank one) which is not a shuffle character. -/
theorem expPlane_shuffleCharacter_not_representative {X : Type*} (a : X) (c : X → ℝ)
    (hc : c a ≠ 0) :
    IsShuffleCharacter (expPlane c) ∧ ¬ IsRepresentative (expPlane c) ∧
      IsRepresentative (planeStar c) :=
  ⟨isShuffleCharacter_expPlane c, not_isRepresentative_expPlane a c hc,
    isRepresentative_of_multiplicative (fun u v => by simp [planeStar])⟩

/-- A Kleene star of a plane is a character of the shuffle algebra only in the trivial
case where the plane vanishes on every letter: the two character groups meet only at the
counit. -/
theorem planeStar_isShuffleCharacter_imp_zero {X : Type*} {K : Type*} [Field K]
    (c : X → K) (hch : IsShuffleCharacter (planeStar c)) : ∀ x : X, c x = 0 := by
  intro x
  have h := hch.2 [x] [x]
  rw [shuf_cons_cons] at h
  simp only [shuf_nil_left, shuf_nil_right, Multiset.map_add, Multiset.map_singleton,
    Multiset.sum_add, Multiset.sum_singleton, planeStar, List.map_cons, List.map_nil,
    List.prod_cons, List.prod_nil, mul_one] at h
  have h4 : c x * c x = 0 := by linear_combination -h
  rcases mul_eq_zero.1 h4 with h5 | h5 <;> exact h5

end ShuffleCharacterNotRational