import Mathlib
import Cryptography.BerggrenStars.HypercycleStars

/-!
# The curves of the Berggren picture: horocycle census

Besides the *stars* of hypercycles studied in `Cryptography.BerggrenStars.HypercycleStars`,
a picture of the Berggren tree embedded in the Poincaré half-plane by `z(m,n) = (n+i)/m` shows a
second family of curves: the **horizontal lines**, which are the horocycles based at the boundary
point `∞`. The nodes at height `1/m` are exactly the Euclid seeds with first coordinate `m`.

## Main results

* `card_horocycleSeeds_even`, `card_horocycleSeeds_odd` : an exact census of each horocycle.
  The horocycle at height `1/m` carries exactly `φ(m)` nodes when `m` is even, and exactly
  `φ(m)/2` nodes when `m` is odd — Euler's totient is the *occupation number* of the horocycle.
* `horocycleSeeds_nonempty` : every horocycle at height `1/m` with `m ≥ 2` is occupied.
* `horocycle_pairwise_separated` : the nodes on one horocycle are uniformly separated, at
  pairwise hyperbolic distance at least `arcosh (3/2)`, however deep in the tree they lie. So
  the horizontal curves of the picture are *uniformly discrete* point sets, in sharp contrast
  with the hypercycle rays, along which the nodes accumulate (`step_along_spoke_tendsto_zero`).
-/

namespace BerggrenHypercycleStars

open Real UpperHalfPlane

/-- The Euclid seeds sitting on the horocycle `Im z = 1/m`, recorded by their second
coordinate. -/
def horocycleSeeds (m : ℕ) : Finset ℕ :=
  (Finset.range m).filter (fun n => Nat.Coprime m n ∧ (m + n) % 2 = 1)

theorem mem_horocycleSeeds_iff (m n : ℕ) (hm : 2 ≤ m) :
    n ∈ horocycleSeeds m ↔ IsSeed m n := by
  rw [horocycleSeeds, Finset.mem_filter, Finset.mem_range]
  constructor
  · rintro ⟨hlt, hcop, hpar⟩
    refine ⟨?_, hlt, hcop, hpar⟩
    rcases Nat.eq_zero_or_pos n with hn | hn
    · subst hn
      rw [Nat.Coprime, Nat.gcd_zero_right] at hcop
      omega
    · exact hn
  · rintro ⟨-, hlt, hcop, hpar⟩
    exact ⟨hlt, hcop, hpar⟩

/-- **Horocycle census, even case.** If `m` is even, the horocycle at height `1/m` carries
exactly `φ(m)` Berggren nodes. -/
theorem card_horocycleSeeds_even (m : ℕ) (hm : m % 2 = 0) :
    (horocycleSeeds m).card = Nat.totient m := by
  classical
  rw [Nat.totient_eq_card_coprime]
  refine congrArg Finset.card (Finset.filter_congr ?_)
  intro n _
  constructor
  · rintro ⟨hcop, -⟩; exact hcop
  · intro hcop
    refine ⟨hcop, ?_⟩
    -- `m` even and `gcd m n = 1` force `n` odd
    rcases Nat.even_or_odd n with hn | hn
    · exfalso
      obtain ⟨k, hk⟩ := hn
      obtain ⟨j, hj⟩ : ∃ j, m = 2 * j := ⟨m / 2, by omega⟩
      have h2 : 2 ∣ Nat.gcd m n := Nat.dvd_gcd ⟨j, hj⟩ ⟨k, by omega⟩
      rw [Nat.Coprime] at hcop
      omega
    · obtain ⟨k, hk⟩ := hn
      omega

/-- **Horocycle census, odd case.** If `m ≥ 3` is odd, the horocycle at height `1/m` carries
exactly `φ(m)/2` Berggren nodes: the totatives of `m` split into two classes of equal size by
parity, and only the even ones give seeds. -/
theorem card_horocycleSeeds_odd (m : ℕ) (hm : m % 2 = 1) (hm3 : 3 ≤ m) :
    2 * (horocycleSeeds m).card = Nat.totient m := by
  classical
  have hTcard : ((Finset.range m).filter m.Coprime).card = Nat.totient m :=
    (Nat.totient_eq_card_coprime m).symm
  -- the even totatives are exactly the seeds on this horocycle
  have hE : horocycleSeeds m
      = ((Finset.range m).filter m.Coprime).filter (fun n => n % 2 = 0) := by
    rw [horocycleSeeds, Finset.filter_filter]
    refine Finset.filter_congr ?_
    intro n _
    constructor
    · rintro ⟨hcop, hpar⟩; exact ⟨hcop, by omega⟩
    · rintro ⟨hcop, hpar⟩; exact ⟨hcop, by omega⟩
  -- the odd totatives are the image of the even ones under `n ↦ m - n`
  have hbij : (((Finset.range m).filter m.Coprime).filter (fun n => n % 2 = 0)).card
      = (((Finset.range m).filter m.Coprime).filter (fun n => ¬ n % 2 = 0)).card := by
    refine Finset.card_bij' (fun n _ => m - n) (fun n _ => m - n) ?_ ?_ ?_ ?_
    · intro a ha
      simp only [Finset.mem_filter, Finset.mem_range] at ha ⊢
      obtain ⟨⟨hlt, hcop⟩, hpar⟩ := ha
      have ha0 : a ≠ 0 := by
        rintro rfl
        rw [Nat.Coprime, Nat.gcd_zero_right] at hcop
        omega
      exact ⟨⟨by omega, (Nat.coprime_self_sub_right hlt.le).2 hcop⟩, by omega⟩
    · intro a ha
      simp only [Finset.mem_filter, Finset.mem_range] at ha ⊢
      obtain ⟨⟨hlt, hcop⟩, hpar⟩ := ha
      exact ⟨⟨by omega, (Nat.coprime_self_sub_right hlt.le).2 hcop⟩, by omega⟩
    · intro a ha
      simp only [Finset.mem_filter, Finset.mem_range] at ha
      show m - (m - a) = a
      omega
    · intro a ha
      simp only [Finset.mem_filter, Finset.mem_range] at ha
      show m - (m - a) = a
      omega
  have hsplit :
      (((Finset.range m).filter m.Coprime).filter (fun n => n % 2 = 0)).card
        + (((Finset.range m).filter m.Coprime).filter (fun n => ¬ n % 2 = 0)).card
      = ((Finset.range m).filter m.Coprime).card :=
    Finset.card_filter_add_card_filter_not _
  rw [hE, ← hTcard, ← hsplit, ← hbij]
  ring

/-- Every horocycle at height `1/m`, `m ≥ 2`, carries at least one node of the tree. -/
theorem horocycleSeeds_nonempty (m : ℕ) (hm : 2 ≤ m) : (horocycleSeeds m).Nonempty := by
  classical
  have hpos : 0 < Nat.totient m := Nat.totient_pos.2 (by omega)
  rcases Nat.even_or_odd m with hme | hmo
  · have h : (horocycleSeeds m).card = Nat.totient m :=
      card_horocycleSeeds_even m (Nat.even_iff.1 hme)
    exact Finset.card_pos.1 (by omega)
  · have hodd : m % 2 = 1 := Nat.odd_iff.1 hmo
    have h : 2 * (horocycleSeeds m).card = Nat.totient m :=
      card_horocycleSeeds_odd m hodd (by omega)
    exact Finset.card_pos.1 (by omega)

/-- **The horizontal curves are uniformly discrete.** Any two distinct nodes on one horocycle
are at hyperbolic distance at least `arcosh (3/2) = 0.9624…`, uniformly in `m`; contrast with
the hypercycle rays of the stars, along which the hyperbolic steps tend to `0`. -/
theorem horocycle_pairwise_separated (m n n' : ℕ) (hm : 0 < m) (h : n ≠ n') :
    Real.arsinh (Real.sqrt 2 / 2) ≤ dist (hpoint m n hm) (hpoint m n' hm) := by
  have hkey : (3 : ℝ) / 2 ≤ Real.cosh (dist (hpoint m n hm) (hpoint m n' hm)) :=
    cosh_dist_same_height m n n' hm h
  have hc : Real.cosh (Real.arsinh (Real.sqrt 2 / 2)) = Real.sqrt (3 / 2) := by
    rw [Real.cosh_arsinh]
    congr 1
    rw [div_pow, Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2)]
    norm_num
  have hle : Real.cosh (Real.arsinh (Real.sqrt 2 / 2))
      ≤ Real.cosh (dist (hpoint m n hm) (hpoint m n' hm)) := by
    rw [hc]
    refine le_trans ?_ hkey
    rw [show (3 : ℝ) / 2 = Real.sqrt ((3 / 2) ^ 2) by
      rw [Real.sqrt_sq (by norm_num)]]
    exact Real.sqrt_le_sqrt (by norm_num)
  have h1 := Real.cosh_le_cosh.1 hle
  rwa [abs_of_nonneg (Real.arsinh_nonneg_iff.2 (by positivity)),
    abs_of_nonneg dist_nonneg] at h1

end BerggrenHypercycleStars