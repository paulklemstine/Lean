/-
# `q`-reduced divisors (Dhar / Baker–Norine)

We prove existence and uniqueness of the `q`-reduced representative of a divisor class on a
finite connected graph.  These are the two structural facts that drive the whole
Riemann–Roch machinery.
-/
import Combinatorics.TropicalRiemannRoch.Basic

namespace TropicalRR

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- Firing the set `S`: every vertex of `S` sends one chip along each incident edge. -/
def fire (S : Finset V) (D : Divisor V) : Divisor V := D - lap G (indic S)

lemma linEquiv_fire (S : Finset V) (D : Divisor V) : LinEquiv G D (fire G S D) :=
  ⟨indic S, rfl⟩

lemma fire_apply_mem {S : Finset V} {v : V} (hv : v ∈ S) (D : Divisor V) :
    fire G S D v = D v - (outdeg G S v : ℤ) := by
  simp [fire, lap_indicator, hv]

lemma fire_apply_not_mem {S : Finset V} {v : V} (hv : v ∉ S) (D : Divisor V) :
    fire G S D v = D v + (indeg G S v : ℤ) := by
  simp [fire, lap_indicator, hv]

/-- `D` is nonnegative away from `q`. -/
def NonnegOff (q : V) (D : Divisor V) : Prop := ∀ v, v ≠ q → 0 ≤ D v

/-- A divisor is `q`-reduced if it is nonnegative off `q` and no nonempty set of vertices
avoiding `q` can be fired while staying nonnegative off `q`. -/
def QReduced (q : V) (D : Divisor V) : Prop :=
  NonnegOff q D ∧ ∀ S : Finset V, S.Nonempty → q ∉ S → ∃ v ∈ S, D v < (outdeg G S v : ℤ)

/-! ### Getting into the nonnegative-off-`q` region -/

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
lemma exists_closer_neighbor (hc : G.Connected) {v q : V} (hv : v ≠ q) :
    ∃ w, G.Adj v w ∧ G.dist w q + 1 = G.dist v q := by
  obtain ⟨p, hp⟩ := hc.exists_walk_length_eq_dist v q
  have hpos : 0 < G.dist v q := hc.pos_dist_of_ne hv
  cases p with
  | nil => exact absurd rfl hv
  | @cons _ w _ h p' =>
      refine ⟨w, h, ?_⟩
      have h1 : G.dist w q ≤ p'.length := SimpleGraph.dist_le p'
      have hvw : G.dist v w = 1 := SimpleGraph.dist_eq_one_iff_adj.mpr h
      have h2 : G.dist v q ≤ G.dist v w + G.dist w q := hc.dist_triangle
      rw [SimpleGraph.Walk.length_cons] at hp
      omega

/-- **Pushing chips out of `q`.**  On a connected graph there is a firing script `f` after
which every vertex other than `q` has strictly gained. -/
lemma exists_pushout_one (hc : G.Connected) (q : V) :
    ∃ f : V → ℤ, ∀ v, v ≠ q → 1 ≤ -(lap G f) v := by
  classical
  set R : ℕ := (Finset.univ.sup fun u => G.dist u q) + 1 with hRdef
  set c : ℤ := (G.maxDegree : ℤ) + 1 with hcdef
  have hc1 : (1 : ℤ) ≤ c := by rw [hcdef]; omega
  have hdR : ∀ u : V, G.dist u q < R := by
    intro u
    have : G.dist u q ≤ Finset.univ.sup fun x => G.dist x q :=
      Finset.le_sup (f := fun x => G.dist x q) (Finset.mem_univ u)
    omega
  refine ⟨fun v => c ^ (R - G.dist v q), ?_⟩
  intro v hv
  have hsum : -(lap G (fun v => c ^ (R - G.dist v q))) v
      = ∑ w ∈ G.neighborFinset v, (c ^ (R - G.dist w q) - c ^ (R - G.dist v q)) := by
    simp only [lap, ← Finset.sum_neg_distrib]
    exact Finset.sum_congr rfl fun w _ => by ring
  rw [hsum]
  -- notation
  set d : ℕ := G.dist v q with hd
  have hd1 : 1 ≤ d := hc.pos_dist_of_ne hv
  have hdlt : d < R := hdR v
  set e : ℕ := R - d - 1 with he
  have hRd : R - d = e + 1 := by omega
  -- a strictly closer neighbour
  obtain ⟨w₀, hw₀adj, hw₀⟩ := exists_closer_neighbor G hc hv
  have hw₀mem : w₀ ∈ G.neighborFinset v := by
    simpa [SimpleGraph.mem_neighborFinset] using hw₀adj
  have hw₀pow : R - G.dist w₀ q = e + 2 := by omega
  -- all other neighbours are not too far
  have hfar : ∀ w ∈ G.neighborFinset v, c ^ e ≤ c ^ (R - G.dist w q) := by
    intro w hw
    have hadj : G.Adj v w := by simpa [SimpleGraph.mem_neighborFinset] using hw
    have hle : G.dist w q ≤ d + 1 := by
      have h2 : G.dist w q ≤ G.dist w v + G.dist v q := hc.dist_triangle
      have h3 : G.dist w v = 1 := SimpleGraph.dist_eq_one_iff_adj.mpr hadj.symm
      omega
    exact pow_le_pow_right₀ hc1 (by omega)
  have hdeg1 : 1 ≤ G.degree v := by
    rw [← SimpleGraph.card_neighborFinset_eq_degree]
    exact Finset.card_pos.2 ⟨w₀, hw₀mem⟩
  have hcard : (((G.neighborFinset v).erase w₀).card : ℤ) = (G.degree v : ℤ) - 1 := by
    rw [Finset.card_erase_of_mem hw₀mem, SimpleGraph.card_neighborFinset_eq_degree]
    omega
  rw [← Finset.add_sum_erase _ _ hw₀mem]
  simp only [hRd, hw₀pow]
  have hlow : ((G.degree v : ℤ) - 1) * (c ^ e - c ^ (e + 1))
      ≤ ∑ w ∈ (G.neighborFinset v).erase w₀, (c ^ (R - G.dist w q) - c ^ (e + 1)) := by
    calc ((G.degree v : ℤ) - 1) * (c ^ e - c ^ (e + 1))
        = ∑ _w ∈ (G.neighborFinset v).erase w₀, (c ^ e - c ^ (e + 1)) := by
          rw [Finset.sum_const, nsmul_eq_mul, hcard]
      _ ≤ _ := Finset.sum_le_sum fun w hw => by
          have := hfar w (Finset.mem_of_mem_erase hw); linarith
  have hX : (1 : ℤ) ≤ c ^ e := one_le_pow₀ hc1
  have hK : (0 : ℤ) ≤ (G.degree v : ℤ) - 1 := by
    have : (1 : ℤ) ≤ (G.degree v : ℤ) := by exact_mod_cast hdeg1
    linarith
  have hcK : ((G.degree v : ℤ) - 1) + 2 ≤ c := by
    have h1 : G.degree v ≤ G.maxDegree := G.degree_le_maxDegree v
    have : (G.degree v : ℤ) ≤ (G.maxDegree : ℤ) := by exact_mod_cast h1
    simp only [hcdef]; linarith
  have hc2 : (2 : ℤ) ≤ c := by linarith
  have h1 : (2 : ℤ) ≤ (c - 1) * (c - ((G.degree v : ℤ) - 1)) := by nlinarith
  have hkey : (1 : ℤ) ≤ c ^ e * ((c - 1) * (c - ((G.degree v : ℤ) - 1))) := by nlinarith
  have hid : (c ^ (e + 2) - c ^ (e + 1)) + ((G.degree v : ℤ) - 1) * (c ^ e - c ^ (e + 1))
      = c ^ e * ((c - 1) * (c - ((G.degree v : ℤ) - 1))) := by ring
  linarith

/-! ### Existence of `q`-reduced divisors -/

/-- Every divisor class has a representative that is nonnegative away from `q`. -/
lemma exists_nonnegOff (hc : G.Connected) (D : Divisor V) (q : V) :
    ∃ f : V → ℤ, f q = 0 ∧ NonnegOff q (D - lap G f) := by
  obtain ⟨g, hg⟩ := exists_pushout_one G hc q
  set N : ℤ := ∑ v, |D v| with hNdef
  have hN0 : 0 ≤ N := Finset.sum_nonneg fun v _ => abs_nonneg _
  have hND : ∀ v, -D v ≤ N := by
    intro v
    have h1 : |D v| ≤ N :=
      Finset.single_le_sum (f := fun u => |D u|) (fun u _ => abs_nonneg _) (Finset.mem_univ v)
    have h2 := neg_abs_le (D v)
    linarith
  refine ⟨fun v => N * g v - N * g q, by ring, ?_⟩
  intro v hv
  have hlap : lap G (fun v => N * g v - N * g q) = fun v => N * lap G g v := by
    rw [lap_sub_const G (fun v => N * g v) (N * g q)]
    exact lap_smul G N g
  rw [Pi.sub_apply, hlap]
  have h1 : (1 : ℤ) ≤ -(lap G g) v := hg v hv
  have h2 : N * 1 ≤ N * (-(lap G g) v) := by
    exact mul_le_mul_of_nonneg_left h1 hN0
  have h3 := hND v
  linarith

/-- Any representative nonnegative off `q` has value at `q` bounded by the degree. -/
lemma val_q_le_degD {q : V} {D E : Divisor V} (h : LinEquiv G D E) (hE : NonnegOff q E) :
    E q ≤ degD D := by
  have hdeg : degD E = degD D := h.degD_eq G
  have hsplit : degD E = E q + ∑ v ∈ Finset.univ.erase q, E v := by
    rw [degD, ← Finset.add_sum_erase _ _ (Finset.mem_univ q)]
  have hnn : 0 ≤ ∑ v ∈ Finset.univ.erase q, E v :=
    Finset.sum_nonneg fun v hv => hE v (Finset.ne_of_mem_erase hv)
  linarith

/-- **Existence of the `q`-reduced representative.** -/
theorem exists_qreduced (hc : G.Connected) (D : Divisor V) (q : V) :
    ∃ f : V → ℤ, QReduced G q (D - lap G f) := by
  classical
  set P : ℤ → Prop := fun z =>
    ∃ f : V → ℤ, f q = 0 ∧ NonnegOff q (D - lap G f) ∧ (D - lap G f) q = z with hPdef
  have hPb : ∃ b, ∀ z, P z → z ≤ b := by
    refine ⟨degD D, ?_⟩
    rintro z ⟨f, -, hf, rfl⟩
    exact val_q_le_degD G ⟨f, rfl⟩ hf
  have hPi : ∃ z, P z := by
    obtain ⟨f, hf0, hf⟩ := exists_nonnegOff G hc D q
    exact ⟨_, f, hf0, hf, rfl⟩
  obtain ⟨m, ⟨f₀, hf₀0, hf₀nn, hf₀q⟩, hmax⟩ := Int.exists_greatest_of_bdd hPb hPi
  set Sc : Set (V → ℤ) :=
    {f | f q = 0 ∧ NonnegOff q (D - lap G f) ∧ (D - lap G f) q = m} with hScdef
  -- the achieving scripts form a finite set
  have hfin : Sc.Finite := by
    have hinj : Set.InjOn (fun f : V → ℤ => D - lap G f) Sc := by
      intro f hf g hg hfg
      simp only at hfg
      have hlap : lap G f = lap G g := by
        have := congrArg (fun E : Divisor V => D - E) hfg
        simpa using this
      have hker : lap G (f - g) = 0 := by rw [lap_sub, hlap, sub_self]
      have hconst := const_of_lap_eq_zero G hc hker
      simp only [hScdef, Set.mem_setOf_eq] at hf hg
      funext v
      have h1 := hconst v q
      simp only [Pi.sub_apply] at h1
      rw [hf.1, hg.1] at h1
      omega
    have himg : ((fun f : V → ℤ => D - lap G f) '' Sc).Finite := by
      have hsub : ((fun f : V → ℤ => D - lap G f) '' Sc) ⊆
          Set.pi Set.univ (fun _ : V => Set.Icc (min 0 m) (max m (degD D - m))) := by
        rintro E ⟨f, hf, rfl⟩
        simp only [hScdef, Set.mem_setOf_eq] at hf
        obtain ⟨hf0, hfnn, hfq⟩ := hf
        intro v _
        show min 0 m ≤ (D - lap G f) v ∧ (D - lap G f) v ≤ max m (degD D - m)
        have hdeg : degD (D - lap G f) = degD D := LinEquiv.degD_eq G ⟨f, rfl⟩
        have hsplit : degD (D - lap G f)
            = (D - lap G f) q + ∑ u ∈ Finset.univ.erase q, (D - lap G f) u := by
          rw [degD, ← Finset.add_sum_erase _ _ (Finset.mem_univ q)]
        rw [hdeg, hfq] at hsplit
        refine ⟨?_, ?_⟩
        · by_cases hv : v = q
          · subst hv; rw [hfq]; exact min_le_right 0 m
          · exact le_trans (min_le_left _ _) (hfnn v hv)
        · by_cases hv : v = q
          · subst hv; rw [hfq]; exact le_max_left _ _
          · have h1 : (D - lap G f) v ≤ ∑ u ∈ Finset.univ.erase q, (D - lap G f) u :=
              Finset.single_le_sum (f := fun u => (D - lap G f) u)
                (fun u hu => hfnn u (Finset.ne_of_mem_erase hu))
                (Finset.mem_erase.2 ⟨hv, Finset.mem_univ v⟩)
            have h3 := le_max_right m (degD D - m)
            omega
      exact Set.Finite.subset (Set.Finite.pi (fun _ : V => Set.finite_Icc _ _)) hsub
    exact Set.Finite.of_finite_image himg hinj
  have hne : Sc.Nonempty := ⟨f₀, hf₀0, hf₀nn, hf₀q⟩
  obtain ⟨f, hfSc, hfmax⟩ := Set.exists_max_image Sc (fun g : V → ℤ => ∑ v, g v) hfin hne
  simp only [hScdef, Set.mem_setOf_eq] at hfSc
  refine ⟨f, hfSc.2.1, ?_⟩
  intro S hSne hSq
  by_contra hcon
  push_neg at hcon
  -- firing `S` yields another script achieving `m`, with strictly bigger total
  have hlapadd : lap G (f + indic S) = lap G f + lap G (indic S) := lap_add G f (indic S)
  have hfire : (f + indic S) ∈ Sc := by
    refine ⟨by simp [indic, hSq, hfSc.1], ?_, ?_⟩
    · intro v hv
      rw [Pi.sub_apply, hlapadd]
      by_cases hvS : v ∈ S
      · have h1 := hcon v hvS
        have h2 : lap G (indic S) v = (outdeg G S v : ℤ) := by rw [lap_indicator, if_pos hvS]
        simp only [Pi.add_apply, h2]
        have := hfSc.2.1
        simp only [Pi.sub_apply] at h1 ⊢
        linarith
      · have h2 : lap G (indic S) v = -(indeg G S v : ℤ) := by rw [lap_indicator, if_neg hvS]
        have h3 := hfSc.2.1 v hv
        simp only [Pi.sub_apply] at h3 ⊢
        simp only [Pi.add_apply, h2]
        have : (0:ℤ) ≤ (indeg G S v : ℤ) := Int.natCast_nonneg _
        linarith
    · have h2 : lap G (indic S) q = -(indeg G S q : ℤ) := by rw [lap_indicator, if_neg hSq]
      have hle : (D - lap G (f + indic S)) q ≤ m := by
        refine hmax _ ⟨f + indic S, by simp [indic, hSq, hfSc.1], ?_, rfl⟩
        intro v hv
        rw [Pi.sub_apply, hlapadd]
        by_cases hvS : v ∈ S
        · have h1 := hcon v hvS
          have h2' : lap G (indic S) v = (outdeg G S v : ℤ) := by rw [lap_indicator, if_pos hvS]
          simp only [Pi.add_apply, h2']
          simp only [Pi.sub_apply] at h1 ⊢
          linarith
        · have h2' : lap G (indic S) v = -(indeg G S v : ℤ) := by
            rw [lap_indicator, if_neg hvS]
          have h3 := hfSc.2.1 v hv
          simp only [Pi.sub_apply] at h3 ⊢
          simp only [Pi.add_apply, h2']
          have : (0:ℤ) ≤ (indeg G S v : ℤ) := Int.natCast_nonneg _
          linarith
      have hge : m ≤ (D - lap G (f + indic S)) q := by
        rw [Pi.sub_apply, hlapadd]
        simp only [Pi.add_apply, h2]
        have h4 := hfSc.2.2
        simp only [Pi.sub_apply] at h4
        have : (0:ℤ) ≤ (indeg G S q : ℤ) := Int.natCast_nonneg _
        linarith
      omega
  have hcard : ∑ v, (f + indic S) v = (∑ v, f v) + S.card := by
    simp only [Pi.add_apply, Finset.sum_add_distrib, indic]
    congr 1
    rw [Finset.sum_boole]
    simp
  have hSpos : 0 < S.card := Finset.card_pos.2 hSne
  have := hfmax (f + indic S) hfire
  omega

/-! ### Maximality and uniqueness -/

/-- A `q`-reduced divisor maximises the value at `q` among all equivalent divisors that are
nonnegative away from `q`. -/
theorem qreduced_val_q_max {q : V} {D E : Divisor V}
    (hD : QReduced G q D) (h : LinEquiv G D E) (hE : NonnegOff q E) : E q ≤ D q := by
  haveI : Nonempty V := ⟨q⟩
  obtain ⟨f, rfl⟩ := h
  by_cases hq : q ∈ maxSet f
  · have h0 : (0 : ℤ) ≤ lap G f q := by
      rw [lap]
      exact Finset.sum_nonneg fun w _ => by linarith [(mem_maxSet.1 hq) w]
    simp only [Pi.sub_apply]
    linarith
  · exfalso
    obtain ⟨v, hv⟩ := maxSet_nonempty f
    obtain ⟨u, huS, hu⟩ := hD.2 (maxSet f) ⟨v, hv⟩ hq
    have h1 : (outdeg G (maxSet f) u : ℤ) ≤ lap G f u := outdeg_le_lap_maxSet G huS
    have h2 : u ≠ q := fun h => hq (h ▸ huS)
    have h3 := hE u h2
    simp only [Pi.sub_apply] at h3
    linarith

/-- A `q`-reduced divisor is winnable exactly when its value at `q` is nonnegative. -/
theorem winnable_iff_qreduced {q : V} {D : Divisor V}
    (hD : QReduced G q D) : Winnable G D ↔ 0 ≤ D q := by
  constructor
  · rintro ⟨E, hEq, hEe⟩
    have := qreduced_val_q_max G hD hEq (fun v _ => hEe v)
    linarith [hEe q]
  · intro h
    refine Winnable.of_effective G (fun v => ?_)
    by_cases hv : v = q
    · subst hv; exact h
    · exact hD.1 v hv

/-- **Uniqueness of the `q`-reduced representative.** -/
theorem qreduced_unique {q : V} {D E : Divisor V}
    (h : LinEquiv G D E) (hD : QReduced G q D) (hE : QReduced G q E) : D = E := by
  haveI : Nonempty V := ⟨q⟩
  obtain ⟨f, rfl⟩ := h
  by_cases hq : q ∈ maxSet f
  · by_cases hq' : q ∈ maxSet (-f)
    · -- `f` is constant
      have hconst : ∀ w, f w = f q := by
        intro w
        have h1 := (mem_maxSet.1 hq) w
        have h2 := (mem_maxSet.1 hq') w
        simp only [Pi.neg_apply] at h2
        omega
      have : lap G f = 0 := by
        have : f = fun _ => f q := funext hconst
        rw [this, lap_const]
      rw [this]
      simp
    · exfalso
      obtain ⟨v, hv⟩ := maxSet_nonempty (-f)
      obtain ⟨u, huS, hu⟩ := hE.2 (maxSet (-f)) ⟨v, hv⟩ hq'
      have h1 : (outdeg G (maxSet (-f)) u : ℤ) ≤ lap G (-f) u := outdeg_le_lap_maxSet G huS
      have h2 : u ≠ q := fun h => hq' (h ▸ huS)
      have h3 := hD.1 u h2
      rw [lap_neg] at h1
      simp only [Pi.sub_apply, Pi.neg_apply] at hu h1 ⊢
      linarith
  · exfalso
    obtain ⟨v, hv⟩ := maxSet_nonempty f
    obtain ⟨u, huS, hu⟩ := hD.2 (maxSet f) ⟨v, hv⟩ hq
    have h1 : (outdeg G (maxSet f) u : ℤ) ≤ lap G f u := outdeg_le_lap_maxSet G huS
    have h2 : u ≠ q := fun h => hq (h ▸ huS)
    have h3 := hE.1 u h2
    simp only [Pi.sub_apply] at h3
    linarith

end TropicalRR