/-
# The Baker–Norine Riemann–Roch theorem for graphs

The rank `r(D)` of a divisor, the Baker–Norine dichotomy, and the Riemann–Roch formula
`r(D) - r(K - D) = deg D - g + 1`.
-/
import Combinatorics.TropicalRiemannRoch.Orientations

namespace TropicalRR

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V] [Nonempty V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The divisor consisting of `k` chips placed at the vertex `q`. -/
def chip (q : V) (k : ℤ) : Divisor V := fun v => if v = q then k else 0

omit [Fintype V] [Nonempty V] in
lemma effective_chip {q : V} {k : ℤ} (hk : 0 ≤ k) : Effective (chip q k) := by
  intro v; by_cases h : v = q <;> simp [chip, h, hk]

omit [Nonempty V] in
@[simp] lemma degD_chip (q : V) (k : ℤ) : degD (chip q k) = k := by
  simp [degD, chip]

omit [DecidableEq V] [Nonempty V] in
lemma eq_zero_of_effective_of_degD_zero {E : Divisor V} (hE : Effective E) (h : degD E = 0) :
    E = 0 := by
  funext v
  have := (Finset.sum_eq_zero_iff_of_nonneg (fun u _ => hE u)).1 h v (Finset.mem_univ v)
  simpa using this

/-! ### The rank of a divisor -/

/-- `RankGE G D k` says that `D` minus any effective divisor of degree `k` is winnable. -/
def RankGE (D : Divisor V) (k : ℕ) : Prop :=
  ∀ E : Divisor V, Effective E → degD E = (k : ℤ) → Winnable G (D - E)

omit [DecidableEq V] [Nonempty V] in
lemma rankGE_zero_iff {D : Divisor V} : RankGE G D 0 ↔ Winnable G D := by
  constructor
  · intro h
    have := h 0 (fun _ => le_rfl) (by simp [degD])
    simpa using this
  · intro h E hE hdeg
    rw [eq_zero_of_effective_of_degD_zero hE (by simpa using hdeg)]
    simpa using h

lemma rankGE_pred {D : Divisor V} {k : ℕ} (h : RankGE G D (k + 1)) : RankGE G D k := by
  intro E hE hdeg
  obtain ⟨q⟩ := ‹Nonempty V›
  have hE' : Effective (E + chip q 1) := hE.add (effective_chip (by norm_num))
  have hdeg' : degD (E + chip q 1) = ((k + 1 : ℕ) : ℤ) := by
    rw [degD_add, hdeg, degD_chip]; push_cast; ring
  have hw := h _ hE' hdeg'
  have hsplit : D - E = (D - (E + chip q 1)) + chip q 1 := by
    funext v; simp only [Pi.sub_apply, Pi.add_apply]; ring
  rw [hsplit]
  exact hw.add_effective G (effective_chip (by norm_num))

lemma rankGE_of_le {D : Divisor V} : ∀ {j k : ℕ}, j ≤ k → RankGE G D k → RankGE G D j := by
  intro j k
  induction k with
  | zero => intro hjk h; simpa [Nat.le_zero.1 hjk] using h
  | succ n ih =>
      intro hjk h
      rcases Nat.lt_or_ge j (n + 1) with hlt | hge
      · exact ih (by omega) (rankGE_pred G h)
      · have : j = n + 1 := by omega
        subst this; exact h

lemma exists_not_rankGE (D : Divisor V) : ∃ k : ℕ, ¬ RankGE G D k := by
  obtain ⟨q⟩ := ‹Nonempty V›
  refine ⟨(max 0 (degD D)).toNat + 1, fun h => ?_⟩
  set k : ℕ := (max 0 (degD D)).toNat + 1 with hk
  have hkpos : (0 : ℤ) ≤ (max 0 (degD D)) := le_max_left _ _
  have hkval : ((k : ℕ) : ℤ) = max 0 (degD D) + 1 := by
    rw [hk]; push_cast [Int.toNat_of_nonneg hkpos]; ring
  have hw := h (chip q ((k : ℕ) : ℤ)) (effective_chip (by positivity)) (by simp)
  have hdeg : degD (D - chip q ((k : ℕ) : ℤ)) = degD D - (k : ℤ) := by
    rw [degD_sub, degD_chip]
  have := hw.degD_nonneg G
  have hmax : degD D ≤ max 0 (degD D) := le_max_right _ _
  omega

/-- The Baker–Norine rank of a divisor. -/
noncomputable def rank (D : Divisor V) : ℤ := (sInf {k : ℕ | ¬ RankGE G D k} : ℕ) - 1

omit [DecidableEq V] [Nonempty V] in
lemma rank_add_one_nonneg (D : Divisor V) : (0 : ℤ) ≤ rank G D + 1 := by
  simp only [rank]
  omega

omit [DecidableEq V] [Nonempty V] in
theorem neg_one_le_rank (D : Divisor V) : -1 ≤ rank G D := by
  have := rank_add_one_nonneg G D; omega

/-- The defining property of the rank. -/
theorem rank_ge_iff (D : Divisor V) (k : ℕ) : ((k : ℤ) ≤ rank G D) ↔ RankGE G D k := by
  set m : ℕ := sInf {k : ℕ | ¬ RankGE G D k} with hm
  have hmem : ¬ RankGE G D m := Nat.sInf_mem (exists_not_rankGE G D)
  constructor
  · intro hk
    have hlt : k < m := by simp only [rank, ← hm] at hk; omega
    have : k ∉ {k : ℕ | ¬ RankGE G D k} := Nat.notMem_of_lt_sInf (by rw [← hm]; exact hlt)
    simpa using this
  · intro hR
    have hlt : k < m := by
      by_contra hge
      exact hmem (rankGE_of_le G (by omega) hR)
    simp only [rank, ← hm]
    omega

theorem rank_eq_neg_one_iff (D : Divisor V) : rank G D = -1 ↔ ¬ Winnable G D := by
  constructor
  · intro h hw
    have h0 := (rank_ge_iff G D 0).2 ((rankGE_zero_iff G).2 hw)
    push_cast at h0
    omega
  · intro hw
    have h0 : ¬ RankGE G D 0 := fun h => hw ((rankGE_zero_iff G).1 h)
    have := neg_one_le_rank G D
    by_contra hne
    have hge : ((0 : ℕ) : ℤ) ≤ rank G D := by omega
    exact h0 ((rank_ge_iff G D 0).1 hge)

theorem rank_eq_neg_one_of_degD_neg {D : Divisor V} (h : degD D < 0) : rank G D = -1 := by
  rw [rank_eq_neg_one_iff]
  intro hw
  have := hw.degD_nonneg G
  omega

@[simp] theorem rank_zero : rank G (0 : Divisor V) = 0 := by
  obtain ⟨q⟩ := ‹Nonempty V›
  have hge : ((0 : ℕ) : ℤ) ≤ rank G 0 :=
    (rank_ge_iff G 0 0).2 ((rankGE_zero_iff G).2 (Winnable.of_effective G (fun _ => le_rfl)))
  have hlt : ¬ (((1 : ℕ) : ℤ) ≤ rank G 0) := by
    intro h
    have := (rank_ge_iff G 0 1).1 h (chip q 1) (effective_chip (by norm_num)) (by simp)
    have h2 := this.degD_nonneg G
    rw [degD_sub, degD_chip] at h2
    simp [degD] at h2
  push_cast at hge hlt
  omega

/-! ### The Baker–Norine dichotomy -/

/-- **Baker–Norine dichotomy.**  A divisor fails to be winnable exactly when some acyclic
orientation divisor `ν_t` dominates it up to linear equivalence. -/
theorem not_winnable_iff_exists_nu (hc : G.Connected) (D : Divisor V) :
    ¬ Winnable G D ↔ ∃ t : V → ℕ, Function.Injective t ∧ Winnable G (nu G t - D) := by
  constructor
  · intro hnw
    obtain ⟨q⟩ := ‹Nonempty V›
    obtain ⟨f, hred⟩ := exists_qreduced G hc D q
    have hlin : LinEquiv G D (D - lap G f) := ⟨f, rfl⟩
    have hnw' : ¬ Winnable G (D - lap G f) := fun hw => hnw (Winnable.of_linEquiv G hlin hw)
    have hq : (D - lap G f) q ≤ -1 := by
      have h1 : ¬ (0 ≤ (D - lap G f) q) :=
        fun hge => hnw' ((winnable_iff_qreduced G hred).2 hge)
      omega
    obtain ⟨t, htinj, hdom⟩ := exists_nu_dominating G hred.2 hq
    refine ⟨t, htinj, ?_⟩
    have heff : Effective (nu G t - (D - lap G f)) := by
      intro v
      have h2 := hdom v
      simp only [Pi.sub_apply] at h2 ⊢
      omega
    exact Winnable.of_linEquiv G (LinEquiv.sub_left G hlin (nu G t))
      (Winnable.of_effective G heff)
  · rintro ⟨t, htinj, hw⟩ hwD
    have : Winnable G (D + (nu G t - D)) := hwD.add G hw
    have heq : D + (nu G t - D) = nu G t := by funext v; simp only [Pi.add_apply, Pi.sub_apply]; ring
    rw [heq] at this
    exact nu_not_winnable G t this

/-! ### Riemann–Roch -/

/-- The Riemann–Roch inequality; applying it twice gives the equality. -/
theorem riemann_roch_ge (hc : G.Connected) (D : Divisor V) :
    degD D - genus G + 1 + rank G (canonical G - D) ≤ rank G D := by
  set s : ℤ := rank G (canonical G - D) with hs
  set k : ℤ := degD D - genus G + 1 + s with hkdef
  rcases lt_or_ge k 0 with hk | hk
  · have := neg_one_le_rank G D
    omega
  · have hkn : ((k.toNat : ℕ) : ℤ) = k := Int.toNat_of_nonneg hk
    have hmain : RankGE G D k.toNat := by
      intro E hE hdegE
      by_contra hnw
      obtain ⟨t, htinj, hwin⟩ := (not_winnable_iff_exists_nu G hc (D - E)).1 hnw
      obtain ⟨A, hA, hAe⟩ := hwin
      have hdegA : degD A = s := by
        rw [hA.degD_eq G, degD_sub, degD_sub, degD_nu G t htinj, hdegE, hkn]
        rw [hkdef]; ring
      have hs0 : 0 ≤ s := by rw [← hdegA]; exact hAe.degD_nonneg
      have hsn : ((s.toNat : ℕ) : ℤ) = s := Int.toNat_of_nonneg hs0
      have hrank : RankGE G (canonical G - D) s.toNat :=
        (rank_ge_iff G (canonical G - D) s.toNat).1 (by rw [hsn, hs])
      have hw1 : Winnable G ((canonical G - D) - A) := hrank A hAe (by rw [hdegA, hsn])
      have hw2 : Winnable G ((canonical G - D) - (nu G t - (D - E))) :=
        Winnable.of_linEquiv G (LinEquiv.sub_left G hA (canonical G - D)) hw1
      have heq : (canonical G - D) - (nu G t - (D - E)) = (canonical G - nu G t) - E := by
        funext v; simp only [Pi.sub_apply]; ring
      rw [heq] at hw2
      have hw3 : Winnable G (((canonical G - nu G t) - E) + E) :=
        hw2.add_effective G hE
      have heq2 : ((canonical G - nu G t) - E) + E = nu G (revRank t) := by
        rw [← canonical_sub_nu G t htinj]
        funext v; simp only [Pi.sub_apply, Pi.add_apply]; ring
      rw [heq2] at hw3
      exact nu_not_winnable G (revRank t) hw3
    have := (rank_ge_iff G D k.toNat).2 hmain
    omega

/-- **The Baker–Norine Riemann–Roch theorem for graphs.**
`r(D) - r(K - D) = deg D - g + 1`. -/
theorem riemann_roch (hc : G.Connected) (D : Divisor V) :
    rank G D - rank G (canonical G - D) = degD D - genus G + 1 := by
  have h1 := riemann_roch_ge G hc D
  have h2 := riemann_roch_ge G hc (canonical G - D)
  have h3 : canonical G - (canonical G - D) = D := by funext v; simp only [Pi.sub_apply]; ring
  rw [h3] at h2
  have h4 : degD (canonical G - D) = 2 * genus G - 2 - degD D := by
    rw [degD_sub, degD_canonical]
  omega

/-! ### Consequences -/

/-- **Riemann's inequality** `r(D) ≥ deg D - g`. -/
theorem riemann_inequality (hc : G.Connected) (D : Divisor V) :
    degD D - genus G ≤ rank G D := by
  have h := riemann_roch G hc D
  have := neg_one_le_rank G (canonical G - D)
  omega

/-- The rank of the canonical divisor is `g - 1`. -/
theorem rank_canonical (hc : G.Connected) : rank G (canonical G) = genus G - 1 := by
  have h := riemann_roch G hc (canonical G)
  have h2 : canonical G - canonical G = (0 : Divisor V) := by funext v; simp
  rw [h2, rank_zero, degD_canonical] at h
  omega

/-- For divisors of large degree the rank is exactly `deg D - g`. -/
theorem rank_eq_of_degD_large (hc : G.Connected) {D : Divisor V}
    (h : 2 * genus G - 1 ≤ degD D) : rank G D = degD D - genus G := by
  have hrr := riemann_roch G hc D
  have hdeg : degD (canonical G - D) = 2 * genus G - 2 - degD D := by
    rw [degD_sub, degD_canonical]
  have hneg : rank G (canonical G - D) = -1 :=
    rank_eq_neg_one_of_degD_neg G (by omega)
  omega

end TropicalRR