/-
# Gonality of a graph, and the gonality of the complete graph

The *gonality* of a graph is the smallest degree of a divisor of positive Baker–Norine rank,
i.e. the smallest number of chips that can be arranged so as to cover any prescribed vertex.
It is the chip-firing analogue of the gonality of an algebraic curve, and it is the invariant
that controls tropical Brill–Noether theory.

Main results:
* `TropicalRR.rank_linEquiv` : the rank is a linear-equivalence invariant;
* `TropicalRR.one_le_gonality` : the gonality of a connected graph is at least `1`;
* `TropicalRR.gonality_le_genus_add_one` : `gon(G) ≤ g + 1` (the trivial Brill–Noether bound);
* `TropicalRR.gonality_eq_one_of_isTree` : a tree has gonality `1`;
* `TropicalRR.two_le_gonality_of_genus_pos` : positive genus forces gonality `≥ 2`;
* `TropicalRR.gonality_eq_two_of_genus_one` : a genus-one tropical curve is hyperelliptic
  (`gon = 2`);
* `TropicalRR.gonality_top` : **the gonality of `K_n` (`n ≥ 2`) is exactly `n - 1`**.

The lower bound for `K_n` is the interesting half: an effective divisor of degree at most
`n - 2` is automatically `q`-reduced at any vertex `q` it misses, because firing a set `S` of
size `s` avoiding `q` costs `s (n - s) ≥ n - 1` chips.  Hence such a divisor cannot cover `q`,
and its rank is at most `0`.
-/
import Combinatorics.TropicalRiemannRoch.MetricGraph

namespace TropicalRR

open Finset

section Invariance

variable {V : Type*} [Fintype V] [DecidableEq V] [Nonempty V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

omit [DecidableEq V] [Nonempty V] in
/-- `RankGE` is a linear-equivalence invariant. -/
lemma rankGE_of_linEquiv {D D' : Divisor V} (h : LinEquiv G D D') (k : ℕ)
    (hD : RankGE G D k) : RankGE G D' k := by
  intro E hE hdeg
  have h1 : LinEquiv G (D + (-E)) (D' + (-E)) := h.add_right G (-E)
  have h2 : D + (-E) = D - E := by funext v; simp [sub_eq_add_neg]
  have h3 : D' + (-E) = D' - E := by funext v; simp [sub_eq_add_neg]
  rw [h2, h3] at h1
  exact Winnable.of_linEquiv G (h1.symm G) (hD E hE hdeg)

omit [DecidableEq V] [Nonempty V] in
/-- **The Baker–Norine rank only depends on the divisor class.** -/
theorem rank_linEquiv {D D' : Divisor V} (h : LinEquiv G D D') : rank G D = rank G D' := by
  have hset : {k : ℕ | ¬ RankGE G D k} = {k : ℕ | ¬ RankGE G D' k} := by
    ext k
    simp only [Set.mem_setOf_eq]
    constructor
    · exact fun hk hk' => hk (rankGE_of_linEquiv G (h.symm G) k hk')
    · exact fun hk hk' => hk (rankGE_of_linEquiv G h k hk')
  simp only [rank, hset]

end Invariance

section Chips

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- An effective divisor of degree `1` is a single chip. -/
lemma eq_chip_of_effective_degD_one {E : Divisor V} (hE : Effective E) (h : degD E = 1) :
    ∃ w, E = chip w 1 := by
  have hex : ∃ w, 1 ≤ E w := by
    by_contra hcon
    push_neg at hcon
    have hzero : ∀ v, E v = 0 := fun v => le_antisymm (by have := hcon v; omega) (hE v)
    rw [degD] at h
    simp [hzero] at h
  obtain ⟨w, hw⟩ := hex
  have hle : ∀ v, v ≠ w → E v ≤ 0 := by
    intro v hv
    have hsub : ∑ u ∈ ({w, v} : Finset V), E u ≤ degD E :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) fun u _ _ => hE u
    rw [Finset.sum_pair (Ne.symm hv)] at hsub
    omega
  have hwone : E w = 1 := by
    have hsub : ∑ u ∈ ({w} : Finset V), E u ≤ degD E :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) fun u _ _ => hE u
    rw [Finset.sum_singleton] at hsub
    omega
  refine ⟨w, funext fun v => ?_⟩
  by_cases hv : v = w
  · subst hv; simp [chip, hwone]
  · have h1 := hE v
    have h2 := hle v hv
    simp only [chip, if_neg hv]
    omega

end Chips

section Gonality

variable {V : Type*} [Fintype V] [DecidableEq V] [Nonempty V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The set of degrees of divisors of positive rank. -/
def gonalitySet : Set ℕ := {d : ℕ | ∃ D : Divisor V, degD D = (d : ℤ) ∧ 1 ≤ rank G D}

/-- The **gonality** of a graph: the least degree of a divisor of positive Baker–Norine rank. -/
noncomputable def gonality : ℕ := sInf (gonalitySet G)

omit [DecidableEq V] [Nonempty V] in
lemma gonality_le {d : ℕ} (h : d ∈ gonalitySet G) : gonality G ≤ d := Nat.sInf_le h

omit [DecidableEq V] [Nonempty V] in
lemma le_gonality {m : ℕ} (hne : (gonalitySet G).Nonempty)
    (h : ∀ d ∈ gonalitySet G, m ≤ d) : m ≤ gonality G :=
  le_csInf hne h

/-- Degree `0` never has positive rank, so the gonality is at least `1`. -/
theorem one_le_gonality (hne : (gonalitySet G).Nonempty) : 1 ≤ gonality G := by
  refine le_gonality G hne fun d hd => ?_
  rcases Nat.eq_zero_or_pos d with rfl | hd0
  · obtain ⟨D, hdeg, hr⟩ := hd
    have h0 : (0 : ℤ) ≤ rank G D := by omega
    have := rank_le_degD G h0
    rw [hdeg] at this
    omega
  · exact hd0

/-- The gonality set of a connected graph is nonempty: a pile of `g + 1` chips has positive
rank by Riemann's inequality. -/
theorem gonalitySet_nonempty (hc : G.Connected) : (gonalitySet G).Nonempty := by
  obtain ⟨q⟩ := ‹Nonempty V›
  have hg : 0 ≤ genus G := genus_nonneg G hc
  refine ⟨(genus G + 1).toNat, chip q (((genus G + 1).toNat : ℕ) : ℤ), by simp, ?_⟩
  have hdcast : (((genus G + 1).toNat : ℕ) : ℤ) = genus G + 1 := Int.toNat_of_nonneg (by omega)
  have hri := riemann_inequality G hc (chip q (((genus G + 1).toNat : ℕ) : ℤ))
  rw [degD_chip] at hri
  omega

/-- The trivial Brill–Noether bound: `gon(G) ≤ g + 1`. -/
theorem gonality_le_genus_add_one (hc : G.Connected) :
    (gonality G : ℤ) ≤ genus G + 1 := by
  obtain ⟨q⟩ := ‹Nonempty V›
  have hg : 0 ≤ genus G := genus_nonneg G hc
  have hdcast : (((genus G + 1).toNat : ℕ) : ℤ) = genus G + 1 := Int.toNat_of_nonneg (by omega)
  have hmem : (genus G + 1).toNat ∈ gonalitySet G := by
    refine ⟨chip q (((genus G + 1).toNat : ℕ) : ℤ), by simp, ?_⟩
    have hri := riemann_inequality G hc (chip q (((genus G + 1).toNat : ℕ) : ℤ))
    rw [degD_chip] at hri
    omega
  have := gonality_le G hmem
  omega

/-- A tree has gonality exactly `1`. -/
theorem gonality_eq_one_of_isTree (hc : G.Connected) (hT : G.IsTree) : gonality G = 1 := by
  have hg : genus G = 0 := (genus_eq_zero_iff_isTree G hc).2 hT
  have h1 := one_le_gonality G (gonalitySet_nonempty G hc)
  have h2 := gonality_le_genus_add_one G hc
  rw [hg] at h2
  omega

/-- **Positive genus forces gonality at least two.**  A divisor of degree `1` and positive
rank would make `K - D` violate Clifford's theorem. -/
theorem two_le_gonality_of_genus_pos (hc : G.Connected) (hg : 1 ≤ genus G) :
    2 ≤ gonality G := by
  refine le_gonality G (gonalitySet_nonempty G hc) fun d hd => ?_
  by_contra hlt
  push_neg at hlt
  obtain ⟨D, hdeg, hr⟩ := hd
  have h0 : (0 : ℤ) ≤ rank G D := by omega
  have hle := rank_le_degD G h0
  rw [hdeg] at hle
  -- the degree must be exactly `1`, and then so is the rank
  have hd1 : (d : ℤ) = 1 := by omega
  have hrD : rank G D = 1 := by omega
  have hdeg1 : degD D = 1 := by rw [hdeg, hd1]
  -- Riemann–Roch computes the rank of `K - D`
  have hrr := riemann_roch G hc D
  have hrK : rank G (canonical G - D) = genus G - 1 := by omega
  -- Clifford applied to `K - D`
  have hself : canonical G - (canonical G - D) = D := by funext v; simp only [Pi.sub_apply]; ring
  have hcl := clifford G hc (D := canonical G - D) (by omega) (by rw [hself]; omega)
  rw [hrK, degD_sub, degD_canonical, hdeg1] at hcl
  omega

/-- A graph of genus `1` has gonality exactly `2`: every tropical curve of genus one is
hyperelliptic. -/
theorem gonality_eq_two_of_genus_one (hc : G.Connected) (hg : genus G = 1) :
    gonality G = 2 := by
  have h1 := two_le_gonality_of_genus_pos G hc (by omega)
  have h2 := gonality_le_genus_add_one G hc
  rw [hg] at h2
  omega

end Gonality

section CompleteGraphGonality

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- On the complete graph, a vertex inside `S` has `|V| - |S|` edges leaving `S`. -/
lemma outdeg_top {S : Finset V} {v : V} (hv : v ∈ S) :
    outdeg (⊤ : SimpleGraph V) S v = Fintype.card V - S.card := by
  have h1 : (⊤ : SimpleGraph V).neighborFinset v = Finset.univ.erase v := by
    ext w
    simp [SimpleGraph.mem_neighborFinset, Finset.mem_erase, ne_comm]
  have h2 : (Finset.univ.erase v) \ S = (Finset.univ : Finset V) \ S := by
    ext w
    simp only [Finset.mem_sdiff, Finset.mem_erase, Finset.mem_univ, true_and, and_true]
    constructor
    · exact fun h => h.2
    · intro hwS
      exact ⟨fun hwv => hwS (hwv ▸ hv), hwS⟩
  rw [outdeg, h1, h2, Finset.card_univ_diff]

/-- On the complete graph, a vertex outside `{q}` has exactly one edge into `{q}`. -/
lemma indeg_top_singleton {q v : V} (hv : v ≠ q) :
    indeg (⊤ : SimpleGraph V) {q} v = 1 := by
  have h : (⊤ : SimpleGraph V).neighborFinset v ∩ {q} = {q} := by
    ext w
    simp only [Finset.mem_inter, Finset.mem_singleton, SimpleGraph.mem_neighborFinset,
      SimpleGraph.top_adj, and_iff_right_iff_imp]
    rintro rfl
    exact hv
  rw [indeg, h, Finset.card_singleton]

/-- **Small divisors are reduced on the complete graph.**  If `D` is nonnegative away from `q`
and carries fewer than `|V| - 1` chips away from `q`, then no set avoiding `q` can be fired:
firing a set `S` of size `s` costs `s (|V| - s) ≥ |V| - 1` chips. -/
lemma qreduced_top_of_small {D : Divisor V} {q : V} (hoff : NonnegOff q D)
    (h : ∑ v ∈ Finset.univ.erase q, D v < (Fintype.card V : ℤ) - 1) :
    QReduced (⊤ : SimpleGraph V) q D := by
  refine ⟨hoff, fun S hSne hqS => ?_⟩
  by_contra hcon
  push_neg at hcon
  set n : ℕ := Fintype.card V with hn
  set s : ℕ := S.card with hs
  have hSsub : S ⊆ Finset.univ.erase q := fun v hv =>
    Finset.mem_erase.2 ⟨fun hvq => hqS (hvq ▸ hv), Finset.mem_univ v⟩
  have hs1 : 1 ≤ s := Finset.card_pos.2 hSne
  have hsn : s ≤ n - 1 := by
    have hcard := Finset.card_le_card hSsub
    rw [Finset.card_erase_of_mem (Finset.mem_univ q), Finset.card_univ] at hcard
    omega
  have hnpos : 1 ≤ n := Fintype.card_pos_iff.2 ⟨q⟩
  -- every vertex of `S` carries at least `n - s` chips
  have hlow : ∀ v ∈ S, ((n : ℤ) - (s : ℤ)) ≤ D v := by
    intro v hv
    have hv' := hcon v hv
    rw [outdeg_top hv] at hv'
    omega
  -- hence `S` alone carries at least `s (n - s)` chips
  have hsum : ((s : ℤ)) * ((n : ℤ) - (s : ℤ)) ≤ ∑ v ∈ S, D v := by
    calc ((s : ℤ)) * ((n : ℤ) - (s : ℤ))
        = ∑ _v ∈ S, ((n : ℤ) - (s : ℤ)) := by
          rw [Finset.sum_const, nsmul_eq_mul, hs]
      _ ≤ ∑ v ∈ S, D v := Finset.sum_le_sum hlow
  have hmono : ∑ v ∈ S, D v ≤ ∑ v ∈ Finset.univ.erase q, D v :=
    Finset.sum_le_sum_of_subset_of_nonneg hSsub fun v hv _ =>
      hoff v (Finset.mem_erase.1 hv).1
  -- but `s (n - s) ≥ n - 1` for `1 ≤ s ≤ n - 1`
  have hs1' : (1 : ℤ) ≤ (s : ℤ) := by exact_mod_cast hs1
  have hsn' : (s : ℤ) ≤ (n : ℤ) - 1 := by omega
  have hkey : (n : ℤ) - 1 ≤ ((s : ℤ)) * ((n : ℤ) - (s : ℤ)) := by nlinarith
  omega

variable [Nonempty V]

/-- **Gonality lower bound for `K_n`.**  A divisor of degree at most `|V| - 2` has rank `≤ 0`:
it cannot cover a vertex that its effective representative misses. -/
theorem rank_le_zero_of_degD_lt_top {D : Divisor V}
    (h : degD D < (Fintype.card V : ℤ) - 1) : rank (⊤ : SimpleGraph V) D ≤ 0 := by
  by_contra hcon
  push_neg at hcon
  -- pass to an effective representative
  have hw : Winnable (⊤ : SimpleGraph V) D := by
    have h0 : ((0 : ℕ) : ℤ) ≤ rank (⊤ : SimpleGraph V) D := by push_cast; omega
    exact (rankGE_zero_iff (⊤ : SimpleGraph V)).1
      ((rank_ge_iff (⊤ : SimpleGraph V) D 0).1 h0)
  obtain ⟨D', hlin, hD'⟩ := hw
  have hdeg' : degD D' = degD D := hlin.degD_eq _
  have hrank' : rank (⊤ : SimpleGraph V) D' = rank (⊤ : SimpleGraph V) D :=
    (rank_linEquiv (⊤ : SimpleGraph V) hlin).symm
  -- some vertex is missed by `D'`
  have hex : ∃ q, D' q = 0 := by
    by_contra hall
    push_neg at hall
    have hge : ∀ v ∈ (Finset.univ : Finset V), (1 : ℤ) ≤ D' v := by
      intro v _
      have h1 := hD' v
      have h2 := hall v
      omega
    have hsum := Finset.sum_le_sum hge
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one, ← degD] at hsum
    omega
  obtain ⟨q, hq⟩ := hex
  -- `D' - q` is `q`-reduced with a negative value at `q`, hence not winnable
  set E : Divisor V := D' - chip q 1 with hE
  have hoff : NonnegOff q E := by
    intro v hv
    simp only [hE, Pi.sub_apply, chip, if_neg hv, sub_zero]
    exact hD' v
  have hsum : ∑ v ∈ Finset.univ.erase q, E v < (Fintype.card V : ℤ) - 1 := by
    have hEeq : ∀ v ∈ Finset.univ.erase q, E v = D' v := by
      intro v hv
      have hvq : v ≠ q := (Finset.mem_erase.1 hv).1
      simp [hE, chip, hvq]
    rw [Finset.sum_congr rfl hEeq]
    have hsplit : ∑ v ∈ Finset.univ.erase q, D' v = degD D' - D' q := by
      rw [degD, ← Finset.add_sum_erase _ _ (Finset.mem_univ q)]
      ring
    rw [hsplit, hq, hdeg']
    omega
  have hred : QReduced (⊤ : SimpleGraph V) q E := qreduced_top_of_small hoff hsum
  have hEq : E q = -1 := by simp [hE, chip, hq]
  have hnw : ¬ Winnable (⊤ : SimpleGraph V) E := by
    intro hwin
    have := (winnable_iff_qreduced (⊤ : SimpleGraph V) hred).1 hwin
    omega
  refine hnw ?_
  have hrk : RankGE (⊤ : SimpleGraph V) D' 1 :=
    (rank_ge_iff (⊤ : SimpleGraph V) D' 1).1 (by rw [hrank']; exact_mod_cast hcon)
  exact hrk (chip q 1) (effective_chip (by norm_num)) (by simp)

omit [Nonempty V] in
/-- **Gonality upper bound for `K_n`.**  A pile of `|V| - 1` chips at one vertex has positive
rank: firing that vertex spreads exactly one chip to every other vertex. -/
theorem rankGE_one_chip_top (hcard : 2 ≤ Fintype.card V) (q : V) :
    RankGE (⊤ : SimpleGraph V) (chip q ((Fintype.card V : ℤ) - 1)) 1 := by
  have hcast : ((Fintype.card V - 1 : ℕ) : ℤ) = (Fintype.card V : ℤ) - 1 :=
    Nat.cast_sub (by omega)
  have hn2 : (2 : ℤ) ≤ (Fintype.card V : ℤ) := by exact_mod_cast hcard
  intro Eff hEff hdeg
  obtain ⟨w, rfl⟩ := eq_chip_of_effective_degD_one hEff (by simpa using hdeg)
  by_cases hwq : w = q
  · -- the requested vertex already carries the pile
    subst hwq
    refine Winnable.of_effective _ (fun v => ?_)
    by_cases hv : v = w
    · subst hv
      simp only [Pi.sub_apply, chip, if_true]
      omega
    · simp [chip, hv]
  · -- fire `q`: it spreads exactly one chip to every other vertex
    set F : Divisor V := fire (⊤ : SimpleGraph V) {q} (chip q ((Fintype.card V : ℤ) - 1))
      with hF
    have hlin : LinEquiv (⊤ : SimpleGraph V) (chip q ((Fintype.card V : ℤ) - 1)) F :=
      linEquiv_fire _ _ _
    have hlin' : LinEquiv (⊤ : SimpleGraph V)
        (chip q ((Fintype.card V : ℤ) - 1) + (-(chip w 1))) (F + (-(chip w 1))) :=
      hlin.add_right _ _
    have h2 : chip q ((Fintype.card V : ℤ) - 1) + (-(chip w 1))
        = chip q ((Fintype.card V : ℤ) - 1) - chip w 1 := by
      funext v; simp [sub_eq_add_neg]
    have h3 : F + (-(chip w 1)) = F - chip w 1 := by funext v; simp [sub_eq_add_neg]
    rw [h2, h3] at hlin'
    have hFq : F q = 0 := by
      rw [hF, fire_apply_mem _ (Finset.mem_singleton_self q),
        outdeg_top (Finset.mem_singleton_self q), Finset.card_singleton, hcast]
      simp [chip]
    have hFv : ∀ u : V, u ≠ q → F u = 1 := by
      intro u hu
      rw [hF, fire_apply_not_mem _ (by simpa using hu), indeg_top_singleton hu]
      simp [chip, hu]
    refine Winnable.of_linEquiv _ hlin' (Winnable.of_effective _ fun v => ?_)
    by_cases hv : v = q
    · subst hv
      have hvw : v ≠ w := fun hvw => hwq (hvw ▸ rfl)
      simp [Pi.sub_apply, hFq, chip, hvw]
    · rw [Pi.sub_apply, hFv v hv]
      by_cases hvw : v = w
      · simp [chip, hvw]
      · simp [chip, hvw]

/-- **The gonality of the complete graph `K_n` is `n - 1`.**  Concentrating `n - 1` chips at a
vertex covers every vertex, and no divisor of degree `n - 2` or less has positive rank. -/
theorem gonality_top (hcard : 2 ≤ Fintype.card V) :
    gonality (⊤ : SimpleGraph V) = Fintype.card V - 1 := by
  obtain ⟨q⟩ := ‹Nonempty V›
  have hcast : ((Fintype.card V - 1 : ℕ) : ℤ) = (Fintype.card V : ℤ) - 1 :=
    Nat.cast_sub (by omega)
  have hmem : (Fintype.card V - 1) ∈ gonalitySet (⊤ : SimpleGraph V) := by
    refine ⟨chip q ((Fintype.card V : ℤ) - 1), by rw [degD_chip, hcast], ?_⟩
    have hge := (rank_ge_iff (⊤ : SimpleGraph V) (chip q ((Fintype.card V : ℤ) - 1)) 1).2
      (rankGE_one_chip_top hcard q)
    exact_mod_cast hge
  refine le_antisymm (gonality_le _ hmem)
    (le_gonality _ ⟨Fintype.card V - 1, hmem⟩ fun d hd => ?_)
  by_contra hlt
  push_neg at hlt
  obtain ⟨D, hdeg, hr⟩ := hd
  have hdlt : (d : ℤ) < (Fintype.card V : ℤ) - 1 := by omega
  have := rank_le_zero_of_degD_lt_top (D := D) (by rw [hdeg]; exact hdlt)
  omega

end CompleteGraphGonality

end TropicalRR