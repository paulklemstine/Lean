/-
# Hyperelliptic graphs

A graph of positive genus is *hyperelliptic* when it carries a divisor of degree `2` and
positive Baker–Norine rank — the chip-firing analogue of a degree-two map to the projective
line.  This file relates hyperellipticity to the gonality, pins down the rank of a
degree-two divisor exactly, and shows that hyperelliptic graphs are precisely the graphs on
which Clifford's inequality is attained by a degree-two class.

Main results:
* `TropicalRR.rank_le_one_of_degD_two` : on a connected graph of positive genus every divisor
  of degree `2` has rank at most `1` (a sharpening of Clifford in the smallest interesting
  degree);
* `TropicalRR.hyperelliptic_iff_gonality_eq_two` : hyperelliptic ⟺ gonality `2`;
* `TropicalRR.hyperelliptic_of_genus_one` : every genus-one graph is hyperelliptic;
* `TropicalRR.clifford_equality_of_hyperelliptic` : a hyperelliptic graph carries a divisor
  with `2 r(D) = deg D = 2` and `r(D) = 1`, so Clifford's bound is sharp;
* `TropicalRR.not_hyperelliptic_top` : the complete graph `K_n` is **not** hyperelliptic for
  `n ≥ 4`, since its gonality is `n - 1`.
-/
import Combinatorics.TropicalRiemannRoch.CompleteGraph
import Combinatorics.TropicalRiemannRoch.Jacobian

namespace TropicalRR

open Finset

section Hyperelliptic

variable {V : Type*} [Fintype V] [DecidableEq V] [Nonempty V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- A graph is *hyperelliptic* if it has positive genus and carries a divisor of degree `2`
with positive rank. -/
def Hyperelliptic : Prop := 1 ≤ genus G ∧ ∃ D : Divisor V, degD D = 2 ∧ 1 ≤ rank G D

/-- **A degree-two divisor on a graph of positive genus has rank at most one.**  Rank `2`
would give `r(K - D) = g - 1` with `deg (K - D) = 2g - 4`, contradicting Clifford. -/
theorem rank_le_one_of_degD_two (hc : G.Connected) (hg : 1 ≤ genus G) {D : Divisor V}
    (hdeg : degD D = 2) : rank G D ≤ 1 := by
  by_contra hlt
  push_neg at hlt
  have h0 : (0 : ℤ) ≤ rank G D := by omega
  have hle : rank G D ≤ degD D := rank_le_degD G h0
  rw [hdeg] at hle
  have hr2 : rank G D = 2 := by omega
  have hrr := riemann_roch G hc D
  have hrK : rank G (canonical G - D) = genus G - 1 := by omega
  have hself : canonical G - (canonical G - D) = D := by
    funext v; simp only [Pi.sub_apply]; ring
  have hcl := clifford G hc (D := canonical G - D) (by omega) (by rw [hself]; omega)
  rw [hrK, degD_sub, degD_canonical, hdeg] at hcl
  omega

/-- On a hyperelliptic graph the exhibiting divisor has rank exactly `1`. -/
theorem exists_rank_one_degD_two (hc : G.Connected) (hH : Hyperelliptic G) :
    ∃ D : Divisor V, degD D = 2 ∧ rank G D = 1 := by
  obtain ⟨hg, D, hdeg, hr⟩ := hH
  exact ⟨D, hdeg, le_antisymm (rank_le_one_of_degD_two G hc hg hdeg) hr⟩

/-- **Clifford's inequality is attained on a hyperelliptic graph**: there is a divisor with
`2 r(D) = deg D = 2`. -/
theorem clifford_equality_of_hyperelliptic (hc : G.Connected) (hH : Hyperelliptic G) :
    ∃ D : Divisor V, degD D = 2 ∧ rank G D = 1 ∧ 2 * rank G D = degD D := by
  obtain ⟨D, hdeg, hr⟩ := exists_rank_one_degD_two G hc hH
  exact ⟨D, hdeg, hr, by rw [hr, hdeg]; norm_num⟩

/-- **Hyperelliptic is the same as gonality two.** -/
theorem hyperelliptic_iff_gonality_eq_two (hc : G.Connected) (hg : 1 ≤ genus G) :
    Hyperelliptic G ↔ gonality G = 2 := by
  constructor
  · rintro ⟨-, D, hdeg, hr⟩
    have hmem : 2 ∈ gonalitySet G := ⟨D, by rw [hdeg]; norm_num, hr⟩
    have h1 := gonality_le G hmem
    have h2 := two_le_gonality_of_genus_pos G hc hg
    omega
  · intro h
    have hmem : gonality G ∈ gonalitySet G := Nat.sInf_mem (gonalitySet_nonempty G hc)
    rw [h] at hmem
    obtain ⟨D, hdeg, hr⟩ := hmem
    exact ⟨hg, D, by rw [hdeg]; norm_num, hr⟩

/-- Every connected graph of genus one is hyperelliptic. -/
theorem hyperelliptic_of_genus_one (hc : G.Connected) (hg : genus G = 1) :
    Hyperelliptic G :=
  (hyperelliptic_iff_gonality_eq_two G hc (by omega)).2 (gonality_eq_two_of_genus_one G hc hg)

end Hyperelliptic

section CompleteGraph

variable {V : Type*} [Fintype V] [DecidableEq V] [Nonempty V]

/-- **The complete graph `K_n` is not hyperelliptic for `n ≥ 4`**: its gonality is `n - 1`,
which exceeds `2`. -/
theorem not_hyperelliptic_top (hcard : 4 ≤ Fintype.card V) :
    ¬ Hyperelliptic (⊤ : SimpleGraph V) := by
  rintro ⟨-, D, hdeg, hr⟩
  have hmem : 2 ∈ gonalitySet (⊤ : SimpleGraph V) := ⟨D, by rw [hdeg]; norm_num, hr⟩
  have h1 := gonality_le (⊤ : SimpleGraph V) hmem
  have h2 := gonality_top (V := V) (by omega)
  omega

/-- `K_3` (the triangle) *is* hyperelliptic: it has genus one. -/
theorem hyperelliptic_top_of_card_three (hcard : Fintype.card V = 3) :
    Hyperelliptic (⊤ : SimpleGraph V) := by
  have hg : genus (⊤ : SimpleGraph V) = 1 := by
    rw [genus_top, hcard]
    norm_num
  exact hyperelliptic_of_genus_one _ top_connected hg

end CompleteGraph

end TropicalRR