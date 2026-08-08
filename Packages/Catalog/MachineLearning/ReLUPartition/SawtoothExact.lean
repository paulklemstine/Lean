import MachineLearning.ReLUPartition.SawtoothCount

/-!
# The exact cell count of the sawtooth network

`MachineLearning.ReLUPartition.SawtoothCount` pins the number of cells of the
depth-`L` width-two sawtooth network between `2 ^ L` and `3 · 2 ^ (L-1)`, and
counts the *loud* cells (those on which no layer is silent) exactly: there are
`2 ^ L` of them.  This file closes the remaining gap by counting the
**degenerate** cells exactly, giving the closed formula

  `#(sawNet.netRegions (M+2)) = 5 · 2 ^ M + 1`.

The mechanism is a complete classification of the degenerate pattern words.
Writing `u_l = sawOrbit l t` for the scalar orbit driving the network, a layer's
pattern is `∅`, `{0}` or `{0,1}` according to whether `u_l ≤ 0`, `0 < u_l ≤ 1/2`
or `1/2 < u_l` (`layerPattern_eq_cellOf`).  If some layer is silent, let `k` be
the first silent index.  Then:

* `k = 0`: the word is all silent;
* `k = 1`: the word is `{0,1}` followed by silence;
* `k ≥ 2`: the orbit must satisfy `u_{k-1} = 1` and hence `u_{k-2} = 1/2`
  exactly, so the word is `b`, `{0}`, `{0,1}`, silence — where the prefix `b` of
  length `j = k-2` is an arbitrary binary itinerary, realised by
  `exists_itinerary_endpoint`.

Thus the degenerate cells are in bijection with
`Unit ⊕ Unit ⊕ (Σ j : Fin M, (Fin j → Bool))`, of cardinality
`1 + 1 + (2 ^ M - 1) = 2 ^ M + 1`.
-/

namespace ReLUPartition

open Finset

/-! ### The three cell shapes -/

/-- The activation pattern of a sawtooth layer as a function of its scalar
pre-activation. -/
noncomputable def cellOf (u : ℝ) : Finset (Fin 2) :=
  if u ≤ 0 then ∅ else if u ≤ 1 / 2 then {0} else {0, 1}

lemma cellOf_of_nonpos {u : ℝ} (h : u ≤ 0) : cellOf u = ∅ := by
  rw [cellOf, if_pos h]

lemma cellOf_of_low {u : ℝ} (h0 : 0 < u) (h1 : u ≤ 1 / 2) : cellOf u = {0} := by
  rw [cellOf, if_neg (not_le.mpr h0), if_pos h1]

lemma cellOf_of_high {u : ℝ} (h : 1 / 2 < u) : cellOf u = {0, 1} := by
  rw [cellOf, if_neg (by linarith), if_neg (by linarith)]

lemma singleton_ne_pair : ({0} : Finset (Fin 2)) ≠ {0, 1} := by decide

lemma pair_ne_empty : ({0, 1} : Finset (Fin 2)) ≠ ∅ := by decide

lemma singleton_ne_empty : ({0} : Finset (Fin 2)) ≠ ∅ := by decide

lemma cellOf_eq_empty_iff {u : ℝ} : cellOf u = ∅ ↔ u ≤ 0 := by
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    rcases le_or_gt u (1 / 2) with h1 | h1
    · rw [cellOf_of_low hcon h1] at h; exact singleton_ne_empty h
    · rw [cellOf_of_high h1] at h; exact pair_ne_empty h
  · exact cellOf_of_nonpos

/-- The layer pattern of the sawtooth network is `cellOf` of the scalar orbit. -/
lemma layerPattern_eq_cellOf (x : Fin 1 → ℝ) (l : ℕ) :
    sawNet.layerPattern l x = cellOf (sawOrbit l (x 0)) := by
  rcases le_or_gt (sawOrbit l (x 0)) 0 with h | h
  · rw [cellOf_of_nonpos h, layerPattern_sawNet_eq_empty_iff]
    exact h
  · rcases le_or_gt (sawOrbit l (x 0)) (1 / 2) with h2 | h2
    · rw [cellOf_of_low h h2]
      ext i
      fin_cases i
      · simp only [Finset.mem_singleton]
        constructor
        · intro _; rfl
        · intro _; exact (zero_mem_layerPattern_sawNet x l).mpr h
      · simp only [Finset.mem_singleton]
        constructor
        · intro hc
          exact absurd ((one_mem_layerPattern_sawNet x l).mp hc) (not_lt.mpr h2)
        · intro hc; exact absurd hc (by decide)
    · rw [cellOf_of_high h2]
      ext i
      fin_cases i
      · simp only [Finset.mem_insert, Finset.mem_singleton]
        constructor
        · intro _; exact Or.inl rfl
        · intro _; exact (zero_mem_layerPattern_sawNet x l).mpr h
      · simp only [Finset.mem_insert, Finset.mem_singleton]
        constructor
        · intro _; exact Or.inr rfl
        · intro _; exact (one_mem_layerPattern_sawNet x l).mpr h2

/-- The whole pattern word of the network, as a function of the scalar input. -/
noncomputable def sawWord (L : ℕ) (t : ℝ) : Fin L → Finset (Fin 2) :=
  fun l => cellOf (sawOrbit (l : ℕ) t)

lemma netPattern_eq_sawWord (L : ℕ) (x : Fin 1 → ℝ) :
    sawNet.netPattern L x = sawWord L (x 0) :=
  funext fun l => layerPattern_eq_cellOf x (l : ℕ)

lemma mem_netRegions_iff_sawWord {L : ℕ} {q : Fin L → Finset (Fin 2)} :
    q ∈ sawNet.netRegions L ↔ ∃ t : ℝ, sawWord L t = q := by
  rw [ReLUNet.mem_netRegions]
  constructor
  · rintro ⟨x, rfl⟩
    exact ⟨x 0, (netPattern_eq_sawWord L x).symm⟩
  · rintro ⟨t, rfl⟩
    exact ⟨fun _ => t, netPattern_eq_sawWord L (fun _ => t)⟩

/-! ### The degenerate cells -/

/-- The degenerate cells: those on which some layer is silent. -/
noncomputable def degenRegions (L : ℕ) : Finset (Fin L → Finset (Fin 2)) :=
  (sawNet.netRegions L).filter (fun q => ¬ ∀ l, q l ≠ ∅)

/-- Codes for degenerate cells: all-silent, immediate shut-off, or a free
itinerary of length `j` followed by the forced word `{0}, {0,1}, ∅ …`. -/
abbrev DegCode (M : ℕ) := Unit ⊕ Unit ⊕ (Σ j : Fin M, (Fin (j : ℕ) → Bool))

/-- The pattern word attached to a code. -/
def degWord {M : ℕ} : DegCode M → (Fin (M + 2) → Finset (Fin 2))
  | Sum.inl _ => fun _ => ∅
  | Sum.inr (Sum.inl _) => fun l => if (l : ℕ) = 0 then {0, 1} else ∅
  | Sum.inr (Sum.inr ⟨j, b⟩) => fun l =>
      if h : (l : ℕ) < (j : ℕ) then (if b ⟨(l : ℕ), h⟩ then {0, 1} else {0})
      else if (l : ℕ) = (j : ℕ) then {0}
      else if (l : ℕ) = (j : ℕ) + 1 then {0, 1} else ∅

lemma degWord_sigma_lt {M : ℕ} {j : Fin M} {b : Fin (j : ℕ) → Bool} {l : Fin (M + 2)}
    (h : (l : ℕ) < (j : ℕ)) :
    degWord (M := M) (Sum.inr (Sum.inr ⟨j, b⟩)) l
      = if b ⟨(l : ℕ), h⟩ then {0, 1} else {0} := by
  simp only [degWord, dif_pos h]

lemma degWord_sigma_eq {M : ℕ} {j : Fin M} {b : Fin (j : ℕ) → Bool} {l : Fin (M + 2)}
    (h : (l : ℕ) = (j : ℕ)) : degWord (M := M) (Sum.inr (Sum.inr ⟨j, b⟩)) l = {0} := by
  simp only [degWord, dif_neg (by omega : ¬ (l : ℕ) < (j : ℕ)), if_pos h]

lemma degWord_sigma_succ {M : ℕ} {j : Fin M} {b : Fin (j : ℕ) → Bool} {l : Fin (M + 2)}
    (h : (l : ℕ) = (j : ℕ) + 1) :
    degWord (M := M) (Sum.inr (Sum.inr ⟨j, b⟩)) l = {0, 1} := by
  simp only [degWord, dif_neg (by omega : ¬ (l : ℕ) < (j : ℕ)),
    if_neg (by omega : ¬ (l : ℕ) = (j : ℕ)), if_pos h]

lemma degWord_sigma_gt {M : ℕ} {j : Fin M} {b : Fin (j : ℕ) → Bool} {l : Fin (M + 2)}
    (h : (j : ℕ) + 1 < (l : ℕ)) : degWord (M := M) (Sum.inr (Sum.inr ⟨j, b⟩)) l = ∅ := by
  simp only [degWord, dif_neg (by omega : ¬ (l : ℕ) < (j : ℕ)),
    if_neg (by omega : ¬ (l : ℕ) = (j : ℕ)), if_neg (by omega : ¬ (l : ℕ) = (j : ℕ) + 1)]

/-! ### `degWord` is injective -/

theorem degWord_injective (M : ℕ) : Function.Injective (degWord (M := M)) := by
  intro c c' hc
  match c, c' with
  | Sum.inl _, Sum.inl _ => rfl
  | Sum.inr (Sum.inl _), Sum.inr (Sum.inl _) => rfl
  | Sum.inl _, Sum.inr (Sum.inl _) =>
      exfalso
      have h := congrFun hc (⟨0, by omega⟩ : Fin (M + 2))
      simp only [degWord] at h
      exact pair_ne_empty h.symm
  | Sum.inr (Sum.inl _), Sum.inl _ =>
      exfalso
      have h := congrFun hc (⟨0, by omega⟩ : Fin (M + 2))
      simp only [degWord] at h
      exact pair_ne_empty h
  | Sum.inl _, Sum.inr (Sum.inr ⟨j, b⟩) =>
      exfalso
      have hlt : (j : ℕ) + 1 < M + 2 := by omega
      have h := congrFun hc (⟨(j : ℕ) + 1, hlt⟩ : Fin (M + 2))
      rw [degWord_sigma_succ (b := b) (l := (⟨(j : ℕ) + 1, hlt⟩ : Fin (M + 2))) rfl] at h
      exact pair_ne_empty h.symm
  | Sum.inr (Sum.inr ⟨j, b⟩), Sum.inl _ =>
      exfalso
      have hlt : (j : ℕ) + 1 < M + 2 := by omega
      have h := congrFun hc (⟨(j : ℕ) + 1, hlt⟩ : Fin (M + 2))
      rw [degWord_sigma_succ (b := b) (l := (⟨(j : ℕ) + 1, hlt⟩ : Fin (M + 2))) rfl] at h
      exact pair_ne_empty h
  | Sum.inr (Sum.inl _), Sum.inr (Sum.inr ⟨j, b⟩) =>
      exfalso
      have hlt : (j : ℕ) + 1 < M + 2 := by omega
      have h := congrFun hc (⟨(j : ℕ) + 1, hlt⟩ : Fin (M + 2))
      rw [degWord_sigma_succ (b := b) (l := (⟨(j : ℕ) + 1, hlt⟩ : Fin (M + 2))) rfl] at h
      simp only [degWord, if_neg (by omega : ¬ ((j : ℕ) + 1) = 0)] at h
      exact pair_ne_empty h.symm
  | Sum.inr (Sum.inr ⟨j, b⟩), Sum.inr (Sum.inl _) =>
      exfalso
      have hlt : (j : ℕ) + 1 < M + 2 := by omega
      have h := congrFun hc (⟨(j : ℕ) + 1, hlt⟩ : Fin (M + 2))
      rw [degWord_sigma_succ (b := b) (l := (⟨(j : ℕ) + 1, hlt⟩ : Fin (M + 2))) rfl] at h
      simp only [degWord, if_neg (by omega : ¬ ((j : ℕ) + 1) = 0)] at h
      exact pair_ne_empty h
  | Sum.inr (Sum.inr ⟨j, b⟩), Sum.inr (Sum.inr ⟨j', b'⟩) =>
      have hjj : (j : ℕ) = (j' : ℕ) := by
        by_contra hne
        rcases Nat.lt_or_ge (j : ℕ) (j' : ℕ) with hlt' | hge
        · have hlt : (j' : ℕ) + 1 < M + 2 := by omega
          have h := congrFun hc (⟨(j' : ℕ) + 1, hlt⟩ : Fin (M + 2))
          rw [degWord_sigma_succ (b := b') (l := (⟨(j' : ℕ) + 1, hlt⟩ : Fin (M + 2))) rfl,
            degWord_sigma_gt (j := j) (b := b) (l := (⟨(j' : ℕ) + 1, hlt⟩ : Fin (M + 2)))
              (by simp; omega)] at h
          exact pair_ne_empty h.symm
        · have hgt : (j' : ℕ) < (j : ℕ) := by omega
          have hlt : (j : ℕ) + 1 < M + 2 := by omega
          have h := congrFun hc (⟨(j : ℕ) + 1, hlt⟩ : Fin (M + 2))
          rw [degWord_sigma_succ (b := b) (l := (⟨(j : ℕ) + 1, hlt⟩ : Fin (M + 2))) rfl,
            degWord_sigma_gt (j := j') (b := b') (l := (⟨(j : ℕ) + 1, hlt⟩ : Fin (M + 2)))
              (by simp; omega)] at h
          exact pair_ne_empty h
      have hj : j = j' := Fin.ext hjj
      subst hj
      have hb : b = b' := by
        funext i
        have hlt : (i : ℕ) < M + 2 := by omega
        have hij : ((⟨(i : ℕ), hlt⟩ : Fin (M + 2)) : ℕ) < (j : ℕ) := i.isLt
        have h := congrFun hc (⟨(i : ℕ), hlt⟩ : Fin (M + 2))
        rw [degWord_sigma_lt (j := j) (b := b) (l := (⟨(i : ℕ), hlt⟩ : Fin (M + 2))) hij,
          degWord_sigma_lt (j := j) (b := b') (l := (⟨(i : ℕ), hlt⟩ : Fin (M + 2))) hij] at h
        have hii : (⟨(i : ℕ), hij⟩ : Fin (j : ℕ)) = i := Fin.ext rfl
        rw [hii] at h
        by_cases h1 : b i <;> by_cases h2 : b' i <;>
          simp only [h1, h2, if_true] at h ⊢
        · exact absurd h singleton_ne_pair.symm
        · exact absurd h singleton_ne_pair
      subst hb
      rfl

/-! ### Every code is realized by a degenerate cell -/

lemma sawStep_one : sawStep 1 = 0 := by
  unfold sawStep
  rw [max_eq_right (by norm_num : (0:ℝ) ≤ 1), max_eq_right (by norm_num : (0:ℝ) ≤ 1 - 1/2)]
  norm_num

lemma sawStep_half : sawStep (1 / 2) = 1 := by
  rw [sawStep_of_pos_le_half (by norm_num) (le_refl _)]
  norm_num

lemma sawStep_of_half_lt {u : ℝ} (h : 1 / 2 < u) : sawStep u = 2 - 2 * u := by
  unfold sawStep
  rw [max_eq_right (by linarith), max_eq_right (by linarith)]
  ring

theorem degWord_mem_degenRegions {M : ℕ} (c : DegCode M) :
    degWord c ∈ degenRegions (M + 2) := by
  classical
  rw [degenRegions, Finset.mem_filter]
  match c with
  | Sum.inl _ =>
      refine ⟨mem_netRegions_iff_sawWord.mpr ⟨0, ?_⟩, ?_⟩
      · funext l
        exact cellOf_of_nonpos
          (sawOrbit_nonpos_mono (Nat.zero_le (l : ℕ)) (le_refl (0 : ℝ)))
      · push_neg
        exact ⟨⟨0, by omega⟩, rfl⟩
  | Sum.inr (Sum.inl _) =>
      have h1 : sawOrbit 1 (1 : ℝ) ≤ 0 := by
        rw [sawOrbit_succ, show sawOrbit 0 (1 : ℝ) = 1 from rfl, sawStep_one]
      refine ⟨mem_netRegions_iff_sawWord.mpr ⟨1, ?_⟩, ?_⟩
      · funext l
        by_cases h : (l : ℕ) = 0
        · have hw : degWord (M := M) (Sum.inr (Sum.inl ())) l = ({0, 1} : Finset (Fin 2)) := by
            simp only [degWord]; rw [if_pos h]
          show cellOf (sawOrbit (l : ℕ) 1) = _
          rw [hw, h, show sawOrbit 0 (1 : ℝ) = 1 from rfl]
          exact cellOf_of_high (by norm_num)
        · have hw : degWord (M := M) (Sum.inr (Sum.inl ())) l = (∅ : Finset (Fin 2)) := by
            simp only [degWord]; rw [if_neg h]
          show cellOf (sawOrbit (l : ℕ) 1) = _
          rw [hw]
          exact cellOf_of_nonpos (sawOrbit_nonpos_mono (by omega) h1)
      · push_neg
        refine ⟨⟨1, by omega⟩, ?_⟩
        simp only [degWord]
        rw [if_neg (by norm_num)]
  | Sum.inr (Sum.inr ⟨j, b⟩) =>
      obtain ⟨y, hy0, hy1, hyE, hy⟩ := exists_itinerary_endpoint (j : ℕ) b
      have horb : ∀ l : ℕ, sawOrbit l y = tent^[l] y :=
        fun l => sawOrbit_eq_tent_iterate hy0.le hy1.le l
      have hjv : sawOrbit (j : ℕ) y = 1 / 2 := by rw [horb]; exact hyE
      have hj1 : sawOrbit ((j : ℕ) + 1) y = 1 := by rw [sawOrbit_succ, hjv, sawStep_half]
      have hj2 : sawOrbit ((j : ℕ) + 2) y ≤ 0 := by
        rw [show (j : ℕ) + 2 = ((j : ℕ) + 1) + 1 from rfl, sawOrbit_succ, hj1, sawStep_one]
      refine ⟨mem_netRegions_iff_sawWord.mpr ⟨y, ?_⟩, ?_⟩
      · funext l
        show cellOf (sawOrbit (l : ℕ) y) = _
        rcases Nat.lt_trichotomy (l : ℕ) (j : ℕ) with h | h | h
        · rw [degWord_sigma_lt (b := b) h]
          have hpos : 0 < sawOrbit (l : ℕ) y := by
            rw [horb]
            exact tent_iterate_pos_of_endpoint hy0.le hy1.le hyE (le_of_lt h)
          have hbit : (1 / 2 < sawOrbit (l : ℕ) y) ↔ b ⟨(l : ℕ), h⟩ = true := by
            rw [horb]; exact hy ⟨(l : ℕ), h⟩
          by_cases hb : b ⟨(l : ℕ), h⟩
          · rw [if_pos hb]
            exact cellOf_of_high (hbit.mpr hb)
          · rw [if_neg hb]
            refine cellOf_of_low hpos ?_
            by_contra hcon
            exact hb (hbit.mp (not_le.mp hcon))
        · rw [degWord_sigma_eq (b := b) h, h, hjv]
          exact cellOf_of_low (by norm_num) (le_refl _)
        · rcases Nat.lt_or_ge ((j : ℕ) + 1) (l : ℕ) with h2 | h2
          · rw [degWord_sigma_gt (b := b) h2]
            exact cellOf_of_nonpos (sawOrbit_nonpos_mono (by omega) hj2)
          · have hl : (l : ℕ) = (j : ℕ) + 1 := by omega
            rw [degWord_sigma_succ (b := b) hl, hl, hj1]
            exact cellOf_of_high (by norm_num)
      · push_neg
        refine ⟨⟨(j : ℕ) + 2, by omega⟩, ?_⟩
        exact degWord_sigma_gt (b := b) (l := (⟨(j : ℕ) + 2, by omega⟩ : Fin (M + 2)))
          (by simp)

/-! ### Every degenerate cell has a code -/

theorem exists_code_of_mem_degenRegions {M : ℕ} {q : Fin (M + 2) → Finset (Fin 2)}
    (hq : q ∈ degenRegions (M + 2)) : ∃ c : DegCode M, degWord c = q := by
  classical
  rw [degenRegions, Finset.mem_filter, mem_netRegions_iff_sawWord] at hq
  obtain ⟨⟨t, rfl⟩, hdeg⟩ := hq
  push_neg at hdeg
  obtain ⟨l0, hl0⟩ := hdeg
  have hl0' : sawOrbit (l0 : ℕ) t ≤ 0 := cellOf_eq_empty_iff.mp hl0
  have hex : ∃ k : ℕ, sawOrbit k t ≤ 0 := ⟨(l0 : ℕ), hl0'⟩
  set k := Nat.find hex with hk
  have hkle : sawOrbit k t ≤ 0 := Nat.find_spec hex
  have hkmin : ∀ m, m < k → 0 < sawOrbit m t := fun m hm => not_le.mp (Nat.find_min hex hm)
  have hkbound : k < M + 2 := lt_of_le_of_lt (Nat.find_le hl0') l0.isLt
  match hk0 : k with
  | 0 =>
      refine ⟨Sum.inl (), ?_⟩
      funext l
      show (∅ : Finset (Fin 2)) = cellOf (sawOrbit (l : ℕ) t)
      refine (cellOf_of_nonpos ?_).symm
      exact sawOrbit_nonpos_mono (Nat.zero_le _) hkle
  | 1 =>
      have hpos0 : 0 < sawOrbit 0 t := hkmin 0 (by omega)
      have hhalf : 1 / 2 < sawOrbit 0 t := half_lt_of_succ_nonpos hpos0 hkle
      refine ⟨Sum.inr (Sum.inl ()), ?_⟩
      funext l
      show (if (l : ℕ) = 0 then ({0, 1} : Finset (Fin 2)) else ∅)
        = cellOf (sawOrbit (l : ℕ) t)
      by_cases h : (l : ℕ) = 0
      · rw [if_pos h, h]
        exact (cellOf_of_high hhalf).symm
      · rw [if_neg h]
        exact (cellOf_of_nonpos (sawOrbit_nonpos_mono (by omega : 1 ≤ (l : ℕ)) hkle)).symm
  | (j + 2) =>
      have hjM : j < M := by omega
      have hposj1 : 0 < sawOrbit (j + 1) t := hkmin (j + 1) (by omega)
      have hposj : 0 < sawOrbit j t := hkmin j (by omega)
      have hnext : sawOrbit (j + 2) t ≤ 0 := hkle
      have hhalf1 : 1 / 2 < sawOrbit (j + 1) t := half_lt_of_succ_nonpos hposj1 hnext
      have hge1 : 1 ≤ sawOrbit (j + 1) t := by
        have : sawOrbit (j + 2) t = 2 - 2 * sawOrbit (j + 1) t := by
          rw [show j + 2 = (j + 1) + 1 from rfl, sawOrbit_succ, sawStep_of_half_lt hhalf1]
        linarith [this ▸ hnext]
      have hjhalf : sawOrbit j t = 1 / 2 := by
        rcases le_or_gt (sawOrbit j t) (1 / 2) with hle | hgt
        · have hstep : sawOrbit (j + 1) t = 2 * sawOrbit j t := by
            rw [sawOrbit_succ, sawStep_of_pos_le_half hposj hle]
          linarith [hstep ▸ hge1]
        · have hstep : sawOrbit (j + 1) t = 2 - 2 * sawOrbit j t := by
            rw [sawOrbit_succ, sawStep_of_half_lt hgt]
          linarith [hstep ▸ hge1]
      have hj1one : sawOrbit (j + 1) t = 1 := by
        rw [sawOrbit_succ, hjhalf, sawStep_half]
      refine ⟨Sum.inr (Sum.inr ⟨⟨j, hjM⟩, fun i => decide (1 / 2 < sawOrbit (i : ℕ) t)⟩), ?_⟩
      funext l
      have hjval : ((⟨j, hjM⟩ : Fin M) : ℕ) = j := rfl
      rcases Nat.lt_trichotomy (l : ℕ) j with h | h | h
      · rw [degWord_sigma_lt (j := ⟨j, hjM⟩)
          (b := fun i => decide (1 / 2 < sawOrbit (i : ℕ) t)) (by rw [hjval]; exact h)]
        show (if decide (1 / 2 < sawOrbit (l : ℕ) t) then ({0, 1} : Finset (Fin 2)) else {0})
          = cellOf (sawOrbit (l : ℕ) t)
        by_cases hb : 1 / 2 < sawOrbit (l : ℕ) t
        · rw [if_pos (by simpa using hb)]
          exact (cellOf_of_high hb).symm
        · rw [if_neg (by simpa using hb)]
          exact (cellOf_of_low (hkmin (l : ℕ) (by omega)) (not_lt.mp hb)).symm
      · rw [degWord_sigma_eq (j := ⟨j, hjM⟩)
          (b := fun i => decide (1 / 2 < sawOrbit (i : ℕ) t)) (by rw [hjval]; exact h)]
        show ({0} : Finset (Fin 2)) = cellOf (sawOrbit (l : ℕ) t)
        rw [h, hjhalf]
        exact (cellOf_of_low (by norm_num) (le_refl _)).symm
      · rcases Nat.lt_or_ge (j + 1) (l : ℕ) with h2 | h2
        · rw [degWord_sigma_gt (j := ⟨j, hjM⟩)
            (b := fun i => decide (1 / 2 < sawOrbit (i : ℕ) t)) (by rw [hjval]; exact h2)]
          show (∅ : Finset (Fin 2)) = cellOf (sawOrbit (l : ℕ) t)
          exact (cellOf_of_nonpos (sawOrbit_nonpos_mono (by omega) hnext)).symm
        · have hl : (l : ℕ) = j + 1 := by omega
          rw [degWord_sigma_succ (j := ⟨j, hjM⟩)
            (b := fun i => decide (1 / 2 < sawOrbit (i : ℕ) t)) (by rw [hjval]; exact hl)]
          show ({0, 1} : Finset (Fin 2)) = cellOf (sawOrbit (l : ℕ) t)
          rw [hl, hj1one]
          exact (cellOf_of_high (by norm_num)).symm

/-! ### Counting the codes -/

lemma sum_two_pow_fin (M : ℕ) : ∑ j : Fin M, 2 ^ (j : ℕ) = 2 ^ M - 1 := by
  induction M with
  | zero => simp
  | succ M ih =>
      rw [Fin.sum_univ_castSucc]
      simp only [Fin.val_castSucc, Fin.val_last, ih]
      have h1 : 1 ≤ 2 ^ M := Nat.one_le_two_pow
      have h2 : 2 ^ (M + 1) = 2 * 2 ^ M := by ring
      omega

lemma card_DegCode (M : ℕ) : Fintype.card (DegCode M) = 2 ^ M + 1 := by
  have hsig : Fintype.card (Σ j : Fin M, (Fin (j : ℕ) → Bool)) = 2 ^ M - 1 := by
    rw [Fintype.card_sigma]
    rw [show (∑ j : Fin M, Fintype.card (Fin (j : ℕ) → Bool)) = ∑ j : Fin M, 2 ^ (j : ℕ) from
      Finset.sum_congr rfl fun j _ => by
        rw [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]]
    exact sum_two_pow_fin M
  have h1 : 1 ≤ 2 ^ M := Nat.one_le_two_pow
  rw [Fintype.card_sum, Fintype.card_sum, Fintype.card_unit, hsig]
  omega

/-! ### The exact counts -/

lemma degenRegions_eq_image (M : ℕ) :
    degenRegions (M + 2) = Finset.image (degWord (M := M)) Finset.univ := by
  classical
  ext q
  constructor
  · intro hq
    obtain ⟨c, hc⟩ := exists_code_of_mem_degenRegions hq
    exact Finset.mem_image.mpr ⟨c, Finset.mem_univ c, hc⟩
  · intro hq
    obtain ⟨c, -, rfl⟩ := Finset.mem_image.mp hq
    exact degWord_mem_degenRegions c

/-- **Exact count of the degenerate cells.**  The depth-`(M+2)` sawtooth network
has exactly `2 ^ M + 1` cells on which some layer is silent. -/
theorem card_degenRegions_sawNet (M : ℕ) : (degenRegions (M + 2)).card = 2 ^ M + 1 := by
  classical
  rw [degenRegions_eq_image, Finset.card_image_of_injective _ (degWord_injective M),
    Finset.card_univ, card_DegCode]

/-- **The exact cell count of the sawtooth network.**  For every depth `L = M+2`,
the width-two sawtooth network on the line partitions `ℝ` into exactly
`5 · 2 ^ M + 1` activation cells.  This closes the sandwich
`2 ^ L ≤ card ≤ 2 ^ (L+1)` of `sawNet_card_sandwich`. -/
theorem card_netRegions_sawNet_exact (M : ℕ) :
    (sawNet.netRegions (M + 2)).card = 5 * 2 ^ M + 1 := by
  classical
  have h := card_netRegions_sawNet_eq_two_pow_add (M + 2)
  have hd : ((sawNet.netRegions (M + 2)).filter (fun q => ¬ ∀ l, q l ≠ ∅)).card = 2 ^ M + 1 :=
    card_degenRegions_sawNet M
  have hpow : (2 : ℕ) ^ (M + 2) = 4 * 2 ^ M := by ring
  rw [h, hd, hpow]
  ring

/-- The exact count in the original variable: for `L ≥ 2` the depth-`L` sawtooth
network has `5 · 2 ^ (L-2) + 1` cells. -/
theorem card_netRegions_sawNet_exact' {L : ℕ} (hL : 2 ≤ L) :
    (sawNet.netRegions L).card = 5 * 2 ^ (L - 2) + 1 := by
  obtain ⟨M, rfl⟩ : ∃ M, L = M + 2 := ⟨L - 2, by omega⟩
  simpa using card_netRegions_sawNet_exact M

/-- Both ends of the previously proved sandwich `2 ^ L ≤ card ≤ 2 ^ (L+1)` are
strict for every depth `L = M + 2`. -/
theorem card_netRegions_sawNet_strict (M : ℕ) :
    2 ^ (M + 2) < (sawNet.netRegions (M + 2)).card ∧
      (sawNet.netRegions (M + 2)).card < 2 ^ (M + 3) := by
  obtain ⟨p, hp1, hp⟩ : ∃ p : ℕ, 1 ≤ p ∧ 2 ^ M = p := ⟨2 ^ M, Nat.one_le_two_pow, rfl⟩
  have h := card_netRegions_sawNet_exact M
  have h1 : (2 : ℕ) ^ (M + 2) = 4 * 2 ^ M := by ring
  have h2 : (2 : ℕ) ^ (M + 3) = 8 * 2 ^ M := by ring
  rw [h, h1, h2, hp]
  omega

/-- **Exact doubling recurrence.**  From depth `L ≥ 2` on, adding one sawtooth
layer doubles the number of cells and removes one: the single "lost" cell is the
degenerate word that the new layer merges into its predecessor. -/
theorem card_netRegions_sawNet_recurrence (M : ℕ) :
    (sawNet.netRegions (M + 3)).card = 2 * (sawNet.netRegions (M + 2)).card - 1 := by
  have h1 := card_netRegions_sawNet_exact (M + 1)
  have h2 := card_netRegions_sawNet_exact M
  have hp : (2 : ℕ) ^ (M + 1) = 2 * 2 ^ M := by ring
  rw [show M + 3 = (M + 1) + 2 from rfl, h1, h2, hp]
  omega

/-- **Sharpened width–depth separation.**  Knowing the sawtooth's cell count
exactly improves the shallow-width lower bound of `shallow_width_ge_of_matching`
from `2 ^ L - 1` to `5 · 2 ^ (L-2)`: a single ReLU layer on the line matching the
depth-`(M+2)` sawtooth needs at least `5 · 2 ^ M` neurons. -/
theorem shallow_width_ge_of_matching_exact {v M : ℕ} (F : AffineFamily v 1)
    (h : (sawNet.netRegions (M + 2)).card ≤ F.regionCount) : 5 * 2 ^ M ≤ v := by
  have h1 : F.regionCount ≤ schlafli v 1 := F.regionCount_le_schlafli
  have h2 := card_netRegions_sawNet_exact M
  rw [schlafli_one_dim] at h1
  omega

end ReLUPartition