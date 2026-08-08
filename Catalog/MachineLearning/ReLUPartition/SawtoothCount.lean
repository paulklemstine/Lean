import MachineLearning.ReLUPartition.DepthSeparation

/-!
# The sawtooth network's cell count, pinned down up to a factor of two

`MachineLearning.ReLUPartition.DeepBound` gives the generic product upper bound
`(schlafli w d)^L`, which for the width-two sawtooth network on the line reads
`3 ^ L`.  `MachineLearning.ReLUPartition.DepthSeparation` gives the matching
lower bound `2 ^ L`.  This file closes most of that gap by exploiting the *shape*
of the sawtooth's pattern language rather than counting hyperplanes:

* the whole network is driven by a single scalar orbit `sawOrbit l x`
  (`act_sawNet_eq`), so a layer pattern is a function of one real number;
* the empty pattern is **absorbing** (`layerPattern_absorbing`): once the layer
  switches off, the orbit is pinned at `0` forever;
* the layer immediately before switching off must have its *second* neuron
  firing (`half_lt_of_succ_nonpos`).

Together these show that a realized pattern sequence is reconstructible from the
firing bits of the second neuron plus a single extra bit, giving
`card ≤ 2 ^ (L + 1)`.  Combined with the lower bound this yields
`2 ^ L ≤ card (sawNet.netRegions L) ≤ 2 ^ (L + 1)`, so the product bound `3 ^ L`
is exponentially far from tight.
-/

namespace ReLUPartition

open Finset AffineFamily

/-! ### The scalar orbit driving the network -/

/-- The exact one-step map computed by the repeated sawtooth layer.  It agrees
with the tent map on `[0, ∞)` and is identically `0` on `(-∞, 0]`. -/
noncomputable def sawStep (u : ℝ) : ℝ := 2 * max 0 u - 4 * max 0 (u - 1 / 2)

lemma sawStep_of_nonpos {u : ℝ} (h : u ≤ 0) : sawStep u = 0 := by
  unfold sawStep
  rw [max_eq_left h, max_eq_left (by linarith)]
  ring

lemma sawStep_of_pos_le_half {u : ℝ} (h0 : 0 < u) (h1 : u ≤ 1 / 2) : sawStep u = 2 * u := by
  unfold sawStep
  rw [max_eq_right h0.le, max_eq_left (by linarith)]
  ring

lemma sawStep_eq_tent {u : ℝ} (h : 0 ≤ u) : sawStep u = tent u := by
  unfold sawStep tent
  rw [max_eq_right h]

/-- The scalar orbit: `sawOrbit l x` is the pre-activation of the first neuron of
layer `l` on input `x`. -/
noncomputable def sawOrbit (l : ℕ) (t : ℝ) : ℝ := sawStep^[l] t

@[simp] lemma sawOrbit_zero (t : ℝ) : sawOrbit 0 t = t := rfl

lemma sawOrbit_succ (l : ℕ) (t : ℝ) : sawOrbit (l + 1) t = sawStep (sawOrbit l t) :=
  Function.iterate_succ_apply' sawStep l t

/-! ### The network is a function of the scalar orbit -/

/-- **State formula (unconditional).**  After `l` layers the sawtooth network
holds `(relu (sawOrbit l x), relu (sawOrbit l x - 1/2))`, for *every* real input
— no restriction to the unit interval. -/
lemma act_sawNet_eq (x : Fin 1 → ℝ) (l : ℕ) :
    sawNet.act l x = ![max 0 (sawOrbit l (x 0)), max 0 (sawOrbit l (x 0) - 1 / 2)] := by
  induction l with
  | zero =>
      funext i
      simp only [ReLUNet.act, sawNet_first, sawOrbit_zero]
      fin_cases i
      · show max 0 (sawFirst.eval 0 x) = max 0 (x 0)
        rw [eval_sawFirst_zero]
      · show max 0 (sawFirst.eval 1 x) = max 0 (x 0 - 1 / 2)
        rw [eval_sawFirst_one]
  | succ l ih =>
      have hz0 : sawNet.act l x 0 = max 0 (sawOrbit l (x 0)) := by rw [ih]; simp
      have hz1 : sawNet.act l x 1 = max 0 (sawOrbit l (x 0) - 1 / 2) := by rw [ih]; simp
      have hstep : 2 * sawNet.act l x 0 - 4 * sawNet.act l x 1 = sawOrbit (l + 1) (x 0) := by
        rw [hz0, hz1, sawOrbit_succ, sawStep]
      funext i
      simp only [ReLUNet.act, sawNet_layer]
      fin_cases i
      · show max 0 (sawLayer.eval 0 (sawNet.act l x)) = max 0 (sawOrbit (l + 1) (x 0))
        rw [eval_sawLayer_zero, hstep]
      · show max 0 (sawLayer.eval 1 (sawNet.act l x)) = max 0 (sawOrbit (l + 1) (x 0) - 1 / 2)
        rw [eval_sawLayer_one]
        congr 1
        rw [← hstep]

lemma zero_mem_layerPattern_sawNet (x : Fin 1 → ℝ) (l : ℕ) :
    (0 : Fin 2) ∈ sawNet.layerPattern l x ↔ 0 < sawOrbit l (x 0) := by
  cases l with
  | zero =>
      rw [ReLUNet.layerPattern, sawNet_first, mem_pattern, eval_sawFirst_zero]
      exact Iff.rfl
  | succ l =>
      rw [ReLUNet.layerPattern, sawNet_layer, mem_pattern, eval_sawLayer_zero, act_sawNet_eq]
      simp only [Matrix.cons_val_zero, Matrix.cons_val_one, sawOrbit_succ]
      exact Iff.rfl

lemma one_mem_layerPattern_sawNet (x : Fin 1 → ℝ) (l : ℕ) :
    (1 : Fin 2) ∈ sawNet.layerPattern l x ↔ 1 / 2 < sawOrbit l (x 0) := by
  cases l with
  | zero =>
      rw [ReLUNet.layerPattern, sawNet_first, mem_pattern, eval_sawFirst_one]
      simp only [sawOrbit_zero]
      constructor <;> intro h <;> linarith
  | succ l =>
      rw [ReLUNet.layerPattern, sawNet_layer, mem_pattern, eval_sawLayer_one, act_sawNet_eq]
      simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
      rw [show 2 * max 0 (sawOrbit l (x 0)) - 4 * max 0 (sawOrbit l (x 0) - 1 / 2)
            = sawOrbit (l + 1) (x 0) from by rw [sawOrbit_succ, sawStep]]
      constructor <;> intro h <;> linarith

lemma layerPattern_sawNet_eq_empty_iff (x : Fin 1 → ℝ) (l : ℕ) :
    sawNet.layerPattern l x = ∅ ↔ sawOrbit l (x 0) ≤ 0 := by
  constructor
  · intro h
    have : (0 : Fin 2) ∉ sawNet.layerPattern l x := by rw [h]; exact notMem_empty _
    rw [zero_mem_layerPattern_sawNet] at this
    linarith [not_lt.mp this]
  · intro h
    rw [Finset.eq_empty_iff_forall_notMem]
    intro i
    fin_cases i
    · show (0 : Fin 2) ∉ sawNet.layerPattern l x
      rw [zero_mem_layerPattern_sawNet]
      exact not_lt.mpr h
    · show (1 : Fin 2) ∉ sawNet.layerPattern l x
      rw [one_mem_layerPattern_sawNet]
      intro hc
      linarith

/-! ### Structure of the pattern language -/

/-- Once the orbit is non-positive it stays non-positive: the empty pattern is
absorbing. -/
lemma sawOrbit_nonpos_succ {l : ℕ} {t : ℝ} (h : sawOrbit l t ≤ 0) :
    sawOrbit (l + 1) t ≤ 0 := by
  rw [sawOrbit_succ, sawStep_of_nonpos h]

lemma sawOrbit_nonpos_mono {l m : ℕ} {t : ℝ} (hlm : l ≤ m) (h : sawOrbit l t ≤ 0) :
    sawOrbit m t ≤ 0 := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hlm
  clear hlm
  induction k with
  | zero => simpa using h
  | succ k ih =>
      have : l + (k + 1) = (l + k) + 1 := by omega
      rw [this]
      exact sawOrbit_nonpos_succ ih

/-- **The last active layer fires its second neuron.**  If the orbit is positive
at step `l` but non-positive at step `l + 1`, then it must already have exceeded
`1/2` at step `l`. -/
lemma half_lt_of_succ_nonpos {l : ℕ} {t : ℝ} (hpos : 0 < sawOrbit l t)
    (h : sawOrbit (l + 1) t ≤ 0) : 1 / 2 < sawOrbit l t := by
  by_contra hc
  push_neg at hc
  rw [sawOrbit_succ, sawStep_of_pos_le_half hpos hc] at h
  linarith

/-- Reaching a non-positive value with no intervening firing of the second neuron
forces the orbit to have been non-positive all along. -/
lemma sawOrbit_nonpos_of_no_fire {t : ℝ} :
    ∀ (k l : ℕ), sawOrbit (l + k) t ≤ 0 →
      (∀ m, l ≤ m → m < l + k → ¬ (1 / 2 < sawOrbit m t)) → sawOrbit l t ≤ 0 := by
  intro k
  induction k with
  | zero => intro l h _; simpa using h
  | succ k ih =>
      intro l h hb
      have hstep : sawOrbit ((l + 1) + k) t ≤ 0 := by
        have : (l + 1) + k = l + (k + 1) := by omega
        rw [this]; exact h
      have hnext : sawOrbit (l + 1) t ≤ 0 := by
        refine ih (l + 1) hstep ?_
        intro m hm hm'
        exact hb m (by omega) (by omega)
      by_contra hc
      push_neg at hc
      exact hb l (le_refl _) (by omega) (half_lt_of_succ_nonpos hc hnext)

/-! ### Reconstructing a cell from the second neuron's firing bits -/

/-- **Reconstruction lemma.**  If the sawtooth network's pattern sequence at `x`
contains an empty pattern, then *which* patterns are empty is completely
determined by the firing bits of the second neuron. -/
lemma layerPattern_empty_iff_no_later_fire {L : ℕ} (x : Fin 1 → ℝ)
    (hex : ∃ l0 : Fin L, sawNet.layerPattern (l0 : ℕ) x = ∅) (l : Fin L) :
    sawNet.layerPattern (l : ℕ) x = ∅ ↔
      ∀ m : Fin L, l ≤ m → (1 : Fin 2) ∉ sawNet.layerPattern (m : ℕ) x := by
  rw [layerPattern_sawNet_eq_empty_iff]
  constructor
  · intro h m hm
    rw [one_mem_layerPattern_sawNet]
    have := sawOrbit_nonpos_mono (t := x 0) hm h
    linarith
  · intro h
    obtain ⟨l0, hl0⟩ := hex
    rw [layerPattern_sawNet_eq_empty_iff] at hl0
    rcases le_or_gt (l0 : ℕ) (l : ℕ) with hle | hlt
    · exact sawOrbit_nonpos_mono hle hl0
    · refine sawOrbit_nonpos_of_no_fire ((l0 : ℕ) - (l : ℕ)) (l : ℕ) ?_ ?_
      · have : (l : ℕ) + ((l0 : ℕ) - (l : ℕ)) = (l0 : ℕ) := by omega
        rw [this]; exact hl0
      · intro m hm hm'
        have hmL : m < L := by omega
        have := h ⟨m, hmL⟩ hm
        rw [one_mem_layerPattern_sawNet] at this
        exact this

/-- Two inputs with the same "all layers active?" flag and the same second-neuron
firing bits produce the same cell. -/
lemma netPattern_sawNet_ext {L : ℕ} {x x' : Fin 1 → ℝ}
    (hflag : (∀ l : Fin L, sawNet.netPattern L x l ≠ ∅) ↔
      (∀ l : Fin L, sawNet.netPattern L x' l ≠ ∅))
    (hbit : ∀ l : Fin L, ((1 : Fin 2) ∈ sawNet.netPattern L x l ↔
      (1 : Fin 2) ∈ sawNet.netPattern L x' l)) :
    sawNet.netPattern L x = sawNet.netPattern L x' := by
  classical
  simp only [ReLUNet.netPattern] at hflag hbit ⊢
  -- first: the empty layers agree
  have hempty : ∀ l : Fin L, sawNet.layerPattern (l : ℕ) x = ∅ ↔
      sawNet.layerPattern (l : ℕ) x' = ∅ := by
    by_cases hall : ∀ l : Fin L, sawNet.layerPattern (l : ℕ) x ≠ ∅
    · have hall' := hflag.mp hall
      intro l
      constructor
      · intro h; exact absurd h (hall l)
      · intro h; exact absurd h (hall' l)
    · have hall' : ¬ ∀ l : Fin L, sawNet.layerPattern (l : ℕ) x' ≠ ∅ :=
        fun hc => hall (hflag.mpr hc)
      push_neg at hall hall'
      obtain ⟨l1, hl1⟩ := hall
      obtain ⟨l1', hl1'⟩ := hall'
      intro l
      rw [layerPattern_empty_iff_no_later_fire (L := L) x ⟨l1, hl1⟩ l,
        layerPattern_empty_iff_no_later_fire (L := L) x' ⟨l1', hl1'⟩ l]
      exact forall_congr' fun m => imp_congr Iff.rfl (not_congr (hbit m))
  funext l
  ext i
  fin_cases i
  · -- the first neuron fires exactly when the layer is non-empty
    have hx : ((0 : Fin 2) ∈ sawNet.layerPattern (l : ℕ) x) ↔
        sawNet.layerPattern (l : ℕ) x ≠ ∅ := by
      rw [zero_mem_layerPattern_sawNet, ne_eq, layerPattern_sawNet_eq_empty_iff]
      constructor
      · intro h hc; linarith
      · intro h; exact lt_of_not_ge h
    have hx' : ((0 : Fin 2) ∈ sawNet.layerPattern (l : ℕ) x') ↔
        sawNet.layerPattern (l : ℕ) x' ≠ ∅ := by
      rw [zero_mem_layerPattern_sawNet, ne_eq, layerPattern_sawNet_eq_empty_iff]
      constructor
      · intro h hc; linarith
      · intro h; exact lt_of_not_ge h
    show (0 : Fin 2) ∈ sawNet.layerPattern (l : ℕ) x ↔
      (0 : Fin 2) ∈ sawNet.layerPattern (l : ℕ) x'
    rw [hx, hx']
    exact not_congr (hempty l)
  · show (1 : Fin 2) ∈ sawNet.layerPattern (l : ℕ) x ↔
      (1 : Fin 2) ∈ sawNet.layerPattern (l : ℕ) x'
    exact hbit l

/-! ### The improved upper bound -/

/-- **Sharpened upper bound.**  The depth-`L` sawtooth network has at most
`2^(L+1)` cells — exponentially fewer than the generic product bound `3^L`. -/
theorem card_netRegions_sawNet_le (L : ℕ) :
    (sawNet.netRegions L).card ≤ 2 ^ (L + 1) := by
  classical
  set Psi : (Fin L → Finset (Fin 2)) → Bool × (Fin L → Bool) :=
    fun q => (decide (∀ l, q l ≠ ∅), fun l => decide ((1 : Fin 2) ∈ q l)) with hPsi
  have hinj : Set.InjOn Psi (sawNet.netRegions L) := by
    intro q hq q' hq' heq
    simp only [Finset.mem_coe, ReLUNet.mem_netRegions] at hq hq'
    obtain ⟨x, rfl⟩ := hq
    obtain ⟨x', rfl⟩ := hq'
    have h1 : decide (∀ l, sawNet.netPattern L x l ≠ ∅)
        = decide (∀ l, sawNet.netPattern L x' l ≠ ∅) := congrArg Prod.fst heq
    have h2 : (fun l => decide ((1 : Fin 2) ∈ sawNet.netPattern L x l))
        = fun l => decide ((1 : Fin 2) ∈ sawNet.netPattern L x' l) := congrArg Prod.snd heq
    refine netPattern_sawNet_ext ?_ ?_
    · exact decide_eq_decide.mp h1
    · intro l
      exact decide_eq_decide.mp (congrFun h2 l)
  have hcard := Finset.card_le_card_of_injOn Psi
    (fun a _ => Finset.mem_univ (Psi a)) hinj
  have huniv : (Finset.univ : Finset (Bool × (Fin L → Bool))).card = 2 ^ (L + 1) := by
    rw [Finset.card_univ, Fintype.card_prod, Fintype.card_bool, Fintype.card_fun,
      Fintype.card_bool, Fintype.card_fin]
    ring
  omega

/-- **The sawtooth cell count, pinned to within a factor of two.**  Compare the
generic product bound `3 ^ L` of `card_netRegions_le`. -/
theorem sawNet_card_sandwich (L : ℕ) :
    2 ^ L ≤ (sawNet.netRegions L).card ∧ (sawNet.netRegions L).card ≤ 2 ^ (L + 1) :=
  ⟨two_pow_le_card_netRegions_sawNet L, card_netRegions_sawNet_le L⟩

lemma two_pow_succ_lt_three_pow {L : ℕ} (hL : 2 ≤ L) : 2 ^ (L + 1) < 3 ^ L := by
  induction L, hL using Nat.le_induction with
  | base => norm_num
  | succ L hL ih =>
      have hpos : (0 : ℕ) < 3 ^ L := pow_pos (by norm_num) L
      calc 2 ^ (L + 1 + 1) = 2 * 2 ^ (L + 1) := by ring
        _ < 2 * 3 ^ L := by omega
        _ ≤ 3 * 3 ^ L := by omega
        _ = 3 ^ (L + 1) := by ring

/-- The generic depth-`L` product bound `3 ^ L` is *not* attained by the sawtooth
network as soon as `L ≥ 2`: the true count is smaller by an exponential factor. -/
theorem card_netRegions_sawNet_lt_three_pow {L : ℕ} (hL : 2 ≤ L) :
    (sawNet.netRegions L).card < 3 ^ L :=
  lt_of_le_of_lt (card_netRegions_sawNet_le L) (two_pow_succ_lt_three_pow hL)

/-! ### An exact count: the full-support cells

A cell of the sawtooth network is *loud* if no layer is silent on it.  The loud
cells are counted **exactly**: there are `2 ^ L` of them, one for each binary
itinerary of the tent map.  Together with `sawNet_card_sandwich` this says that
the whole discrepancy between `2 ^ L` and the true cell count is carried by the
degenerate cells whose orbit falls onto the fixed point `0`.
-/

/-- Every point of `(0,1)` whose `L`-th tent iterate is `1/2` has a strictly
positive orbit up to time `L`. -/
lemma tent_iterate_pos_of_endpoint {y : ℝ} (h0 : 0 ≤ y) (h1 : y ≤ 1) {L : ℕ}
    (hL : tent^[L] y = 1 / 2) {l : ℕ} (hl : l ≤ L) : 0 < tent^[l] y := by
  obtain ⟨hm0, _⟩ := tent_iterate_mem h0 h1 l
  rcases hm0.lt_or_eq with h | h
  · exact h
  · exfalso
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hl
    have hfix : tent 0 = 0 := by unfold tent; rw [max_eq_left (by norm_num)]; ring
    have : tent^[l + k] y = 0 := by
      rw [add_comm, Function.iterate_add_apply, ← h, Function.iterate_fixed hfix]
    rw [this] at hL
    norm_num at hL

/-- **Prescribed itinerary with a prescribed endpoint.**  Strengthening of
`exists_itinerary`: the witness can be chosen so that its `L`-th tent iterate is
exactly `1/2`, which forces the whole orbit to stay strictly positive. -/
theorem exists_itinerary_endpoint (L : ℕ) (b : Fin L → Bool) :
    ∃ y : ℝ, 0 < y ∧ y < 1 ∧ tent^[L] y = 1 / 2 ∧
      ∀ l : Fin L, ((1 / 2 < tent^[(l : ℕ)] y) ↔ b l = true) := by
  induction L with
  | zero =>
      exact ⟨1 / 2, by norm_num, by norm_num, by simp, fun l => absurd l.isLt (by omega)⟩
  | succ L ih =>
      obtain ⟨y, hy0, hy1, hyE, hy⟩ := ih (fun j : Fin L => b j.succ)
      by_cases hb : b 0 = true
      · have hx : (1 : ℝ) / 2 ≤ 1 - y / 2 := by linarith
        have htent : tent (1 - y / 2) = y := by rw [tent_of_ge hx]; ring
        refine ⟨1 - y / 2, by linarith, by linarith, ?_, ?_⟩
        · rw [Function.iterate_succ_apply, htent, hyE]
        · intro l
          refine Fin.cases ?_ ?_ l
          · simp only [Fin.val_zero, Function.iterate_zero_apply, hb, iff_true]
            linarith
          · intro j
            have hval : ((j.succ : Fin (L + 1)) : ℕ) = (j : ℕ) + 1 := rfl
            rw [hval, Function.iterate_succ_apply, htent]
            exact hy j
      · have hb' : b 0 = false := by
          rcases Bool.eq_false_or_eq_true (b 0) with h | h
          · exact absurd h hb
          · exact h
        have hx : y / 2 ≤ (1 : ℝ) / 2 := by linarith
        have htent : tent (y / 2) = y := by rw [tent_of_le hx]; ring
        refine ⟨y / 2, by linarith, by linarith, ?_, ?_⟩
        · rw [Function.iterate_succ_apply, htent, hyE]
        · intro l
          refine Fin.cases ?_ ?_ l
          · simp only [Fin.val_zero, Function.iterate_zero_apply, hb', Bool.false_eq_true,
              iff_false, not_lt]
            linarith
          · intro j
            have hval : ((j.succ : Fin (L + 1)) : ℕ) = (j : ℕ) + 1 := rfl
            rw [hval, Function.iterate_succ_apply, htent]
            exact hy j

/-- On the invariant interval `[0,1]` the network's scalar orbit is the tent
orbit. -/
lemma sawOrbit_eq_tent_iterate {t : ℝ} (h0 : 0 ≤ t) (h1 : t ≤ 1) (l : ℕ) :
    sawOrbit l t = tent^[l] t := by
  induction l with
  | zero => rfl
  | succ l ih =>
      obtain ⟨hm0, _⟩ := tent_iterate_mem h0 h1 l
      rw [sawOrbit_succ, ih, sawStep_eq_tent hm0]
      exact (Function.iterate_succ_apply' tent l t).symm

/-- The *loud* cells of the sawtooth network: those on which no layer is
silent. -/
noncomputable def loudRegions (L : ℕ) : Finset (Fin L → Finset (Fin 2)) :=
  (sawNet.netRegions L).filter (fun q => ∀ l, q l ≠ ∅)

/-- **Exact count of the full-support cells.**  The sawtooth network has exactly
`2 ^ L` cells on which every layer is active — one for each binary itinerary. -/
theorem card_loudRegions_sawNet (L : ℕ) : (loudRegions L).card = 2 ^ L := by
  classical
  set bmap : (Fin L → Finset (Fin 2)) → (Fin L → Bool) :=
    fun q l => decide ((1 : Fin 2) ∈ q l) with hbmap
  have hinj : Set.InjOn bmap (loudRegions L) := by
    intro q hq q' hq' heq
    simp only [loudRegions, Finset.coe_filter, Set.mem_setOf_eq, ReLUNet.mem_netRegions]
      at hq hq'
    obtain ⟨⟨x, rfl⟩, hloud⟩ := hq
    obtain ⟨⟨x', rfl⟩, hloud'⟩ := hq'
    refine netPattern_sawNet_ext (iff_of_true hloud hloud') ?_
    intro l
    exact decide_eq_decide.mp (congrFun heq l)
  have himg : (loudRegions L).image bmap = Finset.univ := by
    refine Finset.eq_univ_iff_forall.mpr ?_
    intro b
    obtain ⟨y, hy0, hy1, hyE, hy⟩ := exists_itinerary_endpoint L b
    have hpos : ∀ l : Fin L, 0 < sawOrbit (l : ℕ) y := by
      intro l
      rw [sawOrbit_eq_tent_iterate hy0.le hy1.le]
      exact tent_iterate_pos_of_endpoint hy0.le hy1.le hyE (le_of_lt l.isLt)
    have hbit : ∀ l : Fin L,
        ((1 : Fin 2) ∈ sawNet.layerPattern (l : ℕ) (fun _ : Fin 1 => y)) ↔ b l = true := by
      intro l
      rw [one_mem_layerPattern_sawNet, sawOrbit_eq_tent_iterate hy0.le hy1.le]
      exact hy l
    refine Finset.mem_image.mpr ⟨sawNet.netPattern L (fun _ : Fin 1 => y), ?_, ?_⟩
    · simp only [loudRegions, Finset.mem_filter, ReLUNet.mem_netRegions]
      refine ⟨⟨fun _ => y, rfl⟩, ?_⟩
      intro l
      rw [ReLUNet.netPattern, Ne, layerPattern_sawNet_eq_empty_iff]
      exact not_le.mpr (hpos l)
    · funext l
      simp only [hbmap, ReLUNet.netPattern]
      rw [decide_eq_decide.mpr (hbit l), Bool.decide_coe]
  have := Finset.card_image_of_injOn hinj
  rw [himg] at this
  rw [← this, Finset.card_univ, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]

/-- The gap between the proved lower bound and the true cell count is exactly the
number of degenerate (partially silent) cells. -/
theorem card_netRegions_sawNet_eq_two_pow_add (L : ℕ) :
    (sawNet.netRegions L).card
      = 2 ^ L + ((sawNet.netRegions L).filter (fun q => ¬ ∀ l, q l ≠ ∅)).card := by
  classical
  rw [← card_loudRegions_sawNet L, loudRegions]
  exact (Finset.card_filter_add_card_filter_not _).symm

/-! ### Squeezing the degenerate cells -/

/-- If some layer is silent then the last layer is silent: the degenerate cells
are exactly those whose final layer is switched off. -/
lemma layerPattern_last_eq_empty {L : ℕ} {x : Fin 1 → ℝ}
    (h : ∃ l : Fin (L + 1), sawNet.layerPattern (l : ℕ) x = ∅) :
    sawNet.layerPattern L x = ∅ := by
  obtain ⟨l, hl⟩ := h
  rw [layerPattern_sawNet_eq_empty_iff] at hl ⊢
  exact sawOrbit_nonpos_mono (by omega) hl

/-- The degenerate (partially silent) cells number at most `2 ^ L`: their final
layer is forced to be silent, so one bit of the itinerary is spent. -/
theorem card_degenerate_sawNet_le (L : ℕ) :
    ((sawNet.netRegions (L + 1)).filter (fun q => ¬ ∀ l, q l ≠ ∅)).card ≤ 2 ^ L := by
  classical
  set g : (Fin (L + 1) → Finset (Fin 2)) → (Fin L → Bool) :=
    fun q l => decide ((1 : Fin 2) ∈ q l.castSucc) with hg
  have hinj : Set.InjOn g
      ((sawNet.netRegions (L + 1)).filter (fun q => ¬ ∀ l, q l ≠ ∅)) := by
    intro q hq q' hq' heq
    simp only [Finset.coe_filter, Set.mem_setOf_eq, ReLUNet.mem_netRegions] at hq hq'
    obtain ⟨⟨x, rfl⟩, hdeg⟩ := hq
    obtain ⟨⟨x', rfl⟩, hdeg'⟩ := hq'
    have hlast : sawNet.layerPattern L x = ∅ := by
      refine layerPattern_last_eq_empty (L := L) ?_
      by_contra hc
      exact hdeg fun l he => hc ⟨l, he⟩
    have hlast' : sawNet.layerPattern L x' = ∅ := by
      refine layerPattern_last_eq_empty (L := L) ?_
      by_contra hc
      exact hdeg' fun l he => hc ⟨l, he⟩
    refine netPattern_sawNet_ext (iff_of_false hdeg hdeg') ?_
    intro l
    refine Fin.lastCases ?_ ?_ l
    · show (1 : Fin 2) ∈ sawNet.layerPattern (Fin.last L : ℕ) x ↔
        (1 : Fin 2) ∈ sawNet.layerPattern (Fin.last L : ℕ) x'
      rw [show ((Fin.last L : Fin (L + 1)) : ℕ) = L from rfl, hlast, hlast']
    · intro j
      have := congrFun heq j
      simp only [hg] at this
      exact decide_eq_decide.mp this
  have hcard := Finset.card_le_card_of_injOn g
    (fun a _ => Finset.mem_univ (g a)) hinj
  have huniv : (Finset.univ : Finset (Fin L → Bool)).card = 2 ^ L := by
    rw [Finset.card_univ, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]
  omega

/-- **Best proved bound.**  Refining `card_netRegions_sawNet_le` with the exact
loud count and the degenerate bound: `2 ^ (L+1) ≤ card ≤ 3 · 2 ^ L`. -/
theorem card_netRegions_sawNet_le_three_mul (L : ℕ) :
    (sawNet.netRegions (L + 1)).card ≤ 3 * 2 ^ L := by
  have h := card_netRegions_sawNet_eq_two_pow_add (L + 1)
  have hd := card_degenerate_sawNet_le L
  have : (2 : ℕ) ^ (L + 1) = 2 * 2 ^ L := by ring
  omega

end ReLUPartition