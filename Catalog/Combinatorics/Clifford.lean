/-
# Superadditivity of the rank and Clifford's theorem for graphs

Consequences of the Baker–Norine Riemann–Roch theorem.
-/
import Combinatorics.TropicalRiemannRoch.RiemannRoch

namespace TropicalRR

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V] [Nonempty V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

omit [Nonempty V] in
/-- An effective divisor of degree `m + n` splits as a sum of effective divisors of
degrees `m` and `n`. -/
lemma exists_split_effective :
    ∀ (m n : ℕ) (F : Divisor V), Effective F → degD F = (m : ℤ) + (n : ℤ) →
      ∃ F₁ F₂ : Divisor V, Effective F₁ ∧ Effective F₂ ∧ F₁ + F₂ = F ∧ degD F₁ = (m : ℤ) := by
  intro m
  induction m with
  | zero =>
      intro n F hF _
      exact ⟨0, F, fun _ => le_rfl, hF, by simp, by simp [degD]⟩
  | succ k ih =>
      intro n F hF hdeg
      have hpos : 0 < degD F := by push_cast at hdeg; omega
      obtain ⟨v, hv⟩ : ∃ v, 0 < F v := by
        by_contra hcon
        push_neg at hcon
        have : degD F = 0 := by
          refine Finset.sum_eq_zero fun u _ => le_antisymm (hcon u) (hF u)
        omega
      have hF' : Effective (F - chip v 1) := by
        intro u
        by_cases hu : u = v
        · subst hu; simp only [Pi.sub_apply, chip]; omega
        · simp only [Pi.sub_apply, chip, if_neg hu]
          have := hF u; omega
      have hdeg' : degD (F - chip v 1) = (k : ℤ) + (n : ℤ) := by
        rw [degD_sub, degD_chip]; push_cast at hdeg ⊢; omega
      obtain ⟨A, B, hA, hB, hAB, hdA⟩ := ih n (F - chip v 1) hF' hdeg'
      refine ⟨A + chip v 1, B, hA.add (effective_chip (by norm_num)), hB, ?_, ?_⟩
      · funext u
        have := congrFun hAB u
        simp only [Pi.add_apply, Pi.sub_apply] at this ⊢
        omega
      · rw [degD_add, hdA, degD_chip]; push_cast; ring

/-- The rank is superadditive on divisors of nonnegative rank. -/
theorem rank_superadditive {D E : Divisor V} (hD : 0 ≤ rank G D) (hE : 0 ≤ rank G E) :
    rank G D + rank G E ≤ rank G (D + E) := by
  set a : ℕ := (rank G D).toNat with ha
  set b : ℕ := (rank G E).toNat with hb
  have hav : ((a : ℕ) : ℤ) = rank G D := Int.toNat_of_nonneg hD
  have hbv : ((b : ℕ) : ℤ) = rank G E := Int.toNat_of_nonneg hE
  have hRD : RankGE G D a := (rank_ge_iff G D a).1 (by rw [hav])
  have hRE : RankGE G E b := (rank_ge_iff G E b).1 (by rw [hbv])
  have hmain : RankGE G (D + E) (a + b) := by
    intro F hF hdegF
    obtain ⟨F₁, F₂, hF₁, hF₂, hsum, hd₁⟩ :=
      exists_split_effective a b F hF (by rw [hdegF]; push_cast; ring)
    have hd₂ : degD F₂ = (b : ℤ) := by
      have : degD F₁ + degD F₂ = degD F := by rw [← degD_add, hsum]
      rw [hd₁, hdegF] at this; push_cast at this ⊢; omega
    have hw := (hRD F₁ hF₁ hd₁).add G (hRE F₂ hF₂ hd₂)
    have heq : (D - F₁) + (E - F₂) = (D + E) - F := by
      funext u
      have := congrFun hsum u
      simp only [Pi.add_apply, Pi.sub_apply] at this ⊢
      omega
    rwa [heq] at hw
  have := (rank_ge_iff G (D + E) (a + b)).2 hmain
  push_cast at this
  omega

/-- The rank of a divisor of nonnegative rank is at most its degree. -/
theorem rank_le_degD {D : Divisor V} (h : 0 ≤ rank G D) : rank G D ≤ degD D := by
  obtain ⟨q⟩ := ‹Nonempty V›
  set a : ℕ := (rank G D).toNat with ha
  have hav : ((a : ℕ) : ℤ) = rank G D := Int.toNat_of_nonneg h
  have hR : RankGE G D a := (rank_ge_iff G D a).1 (by rw [hav])
  have hw := hR (chip q (a : ℤ)) (effective_chip (by positivity)) (by simp)
  have := hw.degD_nonneg G
  rw [degD_sub, degD_chip] at this
  omega

/-- **Clifford's theorem for graphs.**  For a special divisor `D` (one with both `D` and
`K - D` of nonnegative rank) the rank is at most half the degree. -/
theorem clifford (hc : G.Connected) {D : Divisor V} (h1 : 0 ≤ rank G D)
    (h2 : 0 ≤ rank G (canonical G - D)) : 2 * rank G D ≤ degD D := by
  have hsuper := rank_superadditive G h1 h2
  have heq : D + (canonical G - D) = canonical G := by
    funext v; simp only [Pi.add_apply, Pi.sub_apply]; ring
  rw [heq, rank_canonical G hc] at hsuper
  have hrr := riemann_roch G hc D
  omega

end TropicalRR