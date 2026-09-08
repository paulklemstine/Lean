import Mathlib
import Shared.NeuralCoding.Relu

/-!
# Depth-`L` size lower bounds for ReLU networks from oscillation counting

This file proves, from first principles, a *depth separation* theorem for ReLU
networks with one real input.

* The `k`-fold iterated sawtooth `tri^[k]` is computed **exactly** by a ReLU
  network of depth `k` and width `3`, i.e. by `3k` hidden neurons
  (`sawtooth_isNet`).
* Any ReLU network of depth `L ≥ 1` and width `w` whose output is within `1/4`
  (uniformly on `[0,1]`) of `tri^[L^2+4]` must satisfy `2^L ≤ 2*w + 2`, hence
  `w ≥ 2^(L-1) - 1` (`relu_depth_separation`, `relu_depth_separation_width`).

Since `tri^[L^2+4]` is computed by a network of depth `L^2+4` and size
`3(L^2+4)` — both polynomial in `L` — this is exactly the assertion of the
research mission: there are explicit functions represented by networks of
polynomial depth and size which any depth-`L` network must have size
*exponential* in `L` to approximate within a fixed uniform tolerance
(`depth_separation_summary`).

## Method: knot counting

We introduce the predicate `PWA S f`, "`f` is affine on every subinterval of
`[0,1]` whose interior avoids the finite knot set `S`", and establish:

* closure under affine read-outs (`PWA.affine_comb`), with the same knot set;
* the crucial `PWA.relu_step`: post-composition with `relu` costs at most
  `S.card + 2` extra knots (bound stated as `2 * S.card + 4` after normalising
  the knot set to lie in `[0,1]`);
* consequently a depth-`L` width-`w` ReLU network has a knot set of size at most
  `knotBound w L ≤ 2 * (2w+2)^L` (`layerUnits_pwa`, `knotBound_le`);
* an *oscillation* lower bound: a function alternating between `≤ 1/4` and
  `≥ 3/4` at `m+1` ordered points of `[0,1]` needs `m ≤ 2 * S.card + 1`
  (`alternating_knots`), whose engine is `no_affine_oscillation`: an affine
  function cannot go low-high-low;
* the iterated sawtooth alternates between `0` and `1` at the `2^k+1` dyadic
  points `i/2^k` (`tri_iterate_dyadic`).

Combining the two sides gives the exponential lower bound.

All results are unconditional and proved without `sorry`.
-/

noncomputable section

namespace ReluDepth

open Finset

/-! ## Piecewise affine functions with a finite knot set -/

/-- `AffineOn f u v` : `f` agrees with an affine map on the closed interval `[u,v]`. -/
def AffineOn (f : ℝ → ℝ) (u v : ℝ) : Prop :=
  ∃ a b : ℝ, ∀ x ∈ Set.Icc u v, f x = a * x + b

/-- `PWA S f` : on every subinterval of `[0,1]` whose interior avoids the finite
set `S`, the function `f` is affine.  `S` is a set of *knots* for `f`. -/
def PWA (S : Finset ℝ) (f : ℝ → ℝ) : Prop :=
  ∀ u v : ℝ, 0 ≤ u → u ≤ v → v ≤ 1 → (∀ z ∈ S, z ≤ u ∨ v ≤ z) → AffineOn f u v

lemma PWA.mono {S T : Finset ℝ} {f : ℝ → ℝ} (hST : S ⊆ T) (h : PWA S f) : PWA T f :=
  fun u v hu huv hv hz => h u v hu huv hv (fun z hzS => hz z (hST hzS))

lemma PWA.affine (a b : ℝ) : PWA ∅ (fun x => a * x + b) :=
  fun _ _ _ _ _ _ => ⟨a, b, fun _ _ => rfl⟩

/-- An affine read-out of finitely many functions sharing the knot set `S` again has
knot set `S`. -/
lemma PWA.affine_comb {n : ℕ} {S : Finset ℝ} {f : Fin n → ℝ → ℝ}
    (hf : ∀ i, PWA S (f i)) (c : Fin n → ℝ) (d : ℝ) :
    PWA S (fun x => (∑ i, c i * f i x) + d) := by
  intro u v hu huv hv hz
  choose A B hAB using fun i => hf i u v hu huv hv hz
  refine ⟨∑ i, c i * A i, (∑ i, c i * B i) + d, fun x hx => ?_⟩
  have h : ∀ i : Fin n, c i * f i x = c i * A i * x + c i * B i := by
    intro i; rw [hAB i x hx]; ring
  simp only [h]
  rw [Finset.sum_add_distrib, Finset.sum_mul]; ring

/-- If an affine piece `A x + B` of `f` has no sign change inside `[u,v]`, then
`relu ∘ f` is affine on `[u,v]`. -/
theorem affineOn_relu_of_no_crossing {f : ℝ → ℝ} {p q u v : ℝ} (hpu : p ≤ u) (hnv : v ≤ q)
    (A B : ℝ) (hAB : ∀ x ∈ Set.Icc p q, f x = A * x + B)
    (hc : (if A = 0 then p else -B / A) ≤ u ∨ v ≤ (if A = 0 then p else -B / A)) :
    AffineOn (fun x => relu (f x)) u v := by
  have hsub : ∀ x ∈ Set.Icc u v, x ∈ Set.Icc p q := fun x hx =>
    ⟨le_trans hpu hx.1, le_trans hx.2 hnv⟩
  have hBA : A ≠ 0 → A * (-B / A) = -B := by intro h; field_simp
  by_cases hA : A = 0
  · refine ⟨0, relu B, fun x hx => ?_⟩
    show relu (f x) = _
    rw [hAB x (hsub x hx), hA]; ring_nf
  · rw [if_neg hA] at hc
    rcases lt_trichotomy A 0 with hAneg | hA0 | hApos
    · rcases hc with h | h
      · refine ⟨0, 0, fun x hx => ?_⟩
        have hx1 : -B / A ≤ x := le_trans h hx.1
        have hle : A * x + B ≤ 0 := by
          have h2 := mul_le_mul_of_nonpos_left hx1 (le_of_lt hAneg)
          rw [hBA hA] at h2; linarith
        show relu (f x) = _
        rw [hAB x (hsub x hx)]
        simp [relu, max_eq_right hle]
      · refine ⟨A, B, fun x hx => ?_⟩
        have hx1 : x ≤ -B / A := le_trans hx.2 h
        have hle : 0 ≤ A * x + B := by
          have h2 := mul_le_mul_of_nonpos_left hx1 (le_of_lt hAneg)
          rw [hBA hA] at h2; linarith
        show relu (f x) = _
        rw [hAB x (hsub x hx)]
        simp [relu, max_eq_left hle]
    · exact absurd hA0 hA
    · rcases hc with h | h
      · refine ⟨A, B, fun x hx => ?_⟩
        have hx1 : -B / A ≤ x := le_trans h hx.1
        have hle : 0 ≤ A * x + B := by
          have h2 := mul_le_mul_of_nonneg_left hx1 (le_of_lt hApos)
          rw [hBA hA] at h2; linarith
        show relu (f x) = _
        rw [hAB x (hsub x hx)]
        simp [relu, max_eq_left hle]
      · refine ⟨0, 0, fun x hx => ?_⟩
        have hx1 : x ≤ -B / A := le_trans hx.2 h
        have hle : A * x + B ≤ 0 := by
          have h2 := mul_le_mul_of_nonneg_left hx1 (le_of_lt hApos)
          rw [hBA hA] at h2; linarith
        show relu (f x) = _
        rw [hAB x (hsub x hx)]
        simp [relu, max_eq_right hle]

/-- **The ReLU step.**  Post-composing a piecewise affine function with `relu`
creates at most one new knot per affine piece. -/
theorem PWA.relu_step {S : Finset ℝ} {f : ℝ → ℝ} (hf : PWA S f) :
    ∃ T : Finset ℝ, T.card ≤ 2 * S.card + 4 ∧ PWA T (fun x => relu (f x)) := by
  classical
  set S' : Finset ℝ := insert 0 (insert 1 (S.filter (fun z => 0 ≤ z ∧ z ≤ 1))) with hS'def
  have hmem01 : ∀ z ∈ S', 0 ≤ z ∧ z ≤ 1 := by
    intro z hz
    simp only [hS'def, Finset.mem_insert, Finset.mem_filter] at hz
    rcases hz with rfl | rfl | ⟨_, h⟩
    · norm_num
    · norm_num
    · exact h
  have h0 : (0:ℝ) ∈ S' := by simp [hS'def]
  have h1 : (1:ℝ) ∈ S' := by simp [hS'def]
  have hcard : S'.card ≤ S.card + 2 := by
    have e1 := Finset.card_insert_le (0:ℝ) (insert 1 (S.filter (fun z => 0 ≤ z ∧ z ≤ 1)))
    have e2 := Finset.card_insert_le (1:ℝ) (S.filter (fun z => 0 ≤ z ∧ z ≤ 1))
    have e3 := Finset.card_filter_le S (fun z => 0 ≤ z ∧ z ≤ 1)
    rw [hS'def]; omega
  have hf' : PWA S' f := by
    intro u v hu huv hv hz
    refine hf u v hu huv hv ?_
    intro z hzS
    by_contra hcon
    push_neg at hcon
    obtain ⟨h2, h3⟩ := hcon
    have hzS' : z ∈ S' := by
      simp only [hS'def, Finset.mem_insert, Finset.mem_filter]
      exact Or.inr (Or.inr ⟨hzS, le_of_lt (lt_of_le_of_lt hu h2), le_of_lt (lt_of_lt_of_le h3 hv)⟩)
    rcases hz z hzS' with h | h <;> linarith
  -- the successor knot, and the (at most one) sign change of `f` on each gap
  set nxt : ℝ → ℝ := fun p =>
    if h : (S'.filter (fun z => p < z)).Nonempty then (S'.filter (fun z => p < z)).min' h else 1
    with hnxt
  set cross : ℝ → ℝ := fun p =>
    if h : ∃ ab : ℝ × ℝ, ∀ x ∈ Set.Icc p (nxt p), f x = ab.1 * x + ab.2 then
      (if h.choose.1 = 0 then p else -h.choose.2 / h.choose.1) else p with hcross
  refine ⟨S' ∪ S'.image cross, ?_, ?_⟩
  · calc (S' ∪ S'.image cross).card ≤ S'.card + (S'.image cross).card := Finset.card_union_le _ _
      _ ≤ S'.card + S'.card := by have := Finset.card_image_le (s := S') (f := cross); omega
      _ ≤ 2 * S.card + 4 := by omega
  · intro u v hu huv hv hz
    rcases eq_or_lt_of_le huv with rfl | huv'
    · refine ⟨0, relu (f u), fun x hx => ?_⟩
      simp only [Set.mem_Icc] at hx
      have hxv : x = u := le_antisymm hx.2 hx.1
      show relu (f x) = 0 * x + relu (f u)
      rw [hxv]; ring
    have hne : (S'.filter (fun z => z ≤ u)).Nonempty := ⟨0, by simp [Finset.mem_filter, h0, hu]⟩
    set p : ℝ := (S'.filter (fun z => z ≤ u)).max' hne with hp
    have hpmem : p ∈ S'.filter (fun z => z ≤ u) := Finset.max'_mem _ hne
    have hpS' : p ∈ S' := (Finset.mem_filter.mp hpmem).1
    have hpu : p ≤ u := by have := (Finset.mem_filter.mp hpmem).2; simpa using this
    have hp1 : p < 1 := by linarith
    have hnxtne : (S'.filter (fun z => p < z)).Nonempty := ⟨1, by simp [Finset.mem_filter, h1, hp1]⟩
    have hnxtval : nxt p = (S'.filter (fun z => p < z)).min' hnxtne := by
      simp [hnxt, dif_pos hnxtne]
    have hnxtmem : nxt p ∈ S' := by
      rw [hnxtval]; exact (Finset.mem_filter.mp (Finset.min'_mem _ hnxtne)).1
    have hpnxt : p < nxt p := by
      rw [hnxtval]
      exact (Finset.mem_filter.mp (Finset.min'_mem (S'.filter (fun z => p < z)) hnxtne)).2
    have hnv : v ≤ nxt p := by
      by_contra hcon
      push_neg at hcon
      have hgt : u < nxt p := by
        by_contra hcon2
        push_neg at hcon2
        have hmm : nxt p ∈ S'.filter (fun z => z ≤ u) :=
          Finset.mem_filter.mpr ⟨hnxtmem, by simpa using hcon2⟩
        have := Finset.le_max' _ _ hmm
        rw [← hp] at this
        linarith
      rcases hz (nxt p) (Finset.mem_union_left _ hnxtmem) with h | h <;> linarith
    have hp0 : 0 ≤ p := (hmem01 p hpS').1
    have hnxt1 : nxt p ≤ 1 := (hmem01 _ hnxtmem).2
    have hgap : ∀ z ∈ S', z ≤ p ∨ nxt p ≤ z := by
      intro z hzS'
      by_contra hcon
      push_neg at hcon
      obtain ⟨hz1, hz2⟩ := hcon
      have hmm : z ∈ S'.filter (fun w => p < w) := Finset.mem_filter.mpr ⟨hzS', by simpa using hz1⟩
      have := Finset.min'_le _ _ hmm
      rw [hnxtval] at hz2
      linarith
    obtain ⟨a, b, hab⟩ := hf' p (nxt p) hp0 (le_of_lt hpnxt) hnxt1 hgap
    have hex : ∃ ab : ℝ × ℝ, ∀ x ∈ Set.Icc p (nxt p), f x = ab.1 * x + ab.2 := ⟨(a, b), hab⟩
    have hcp : cross p = (if hex.choose.1 = 0 then p else -hex.choose.2 / hex.choose.1) := by
      rw [hcross]; simp only [dif_pos hex]
    have hcin : cross p ≤ u ∨ v ≤ cross p :=
      hz (cross p) (Finset.mem_union_right _ (Finset.mem_image_of_mem cross hpS'))
    rw [hcp] at hcin
    exact affineOn_relu_of_no_crossing hpu hnv hex.choose.1 hex.choose.2 hex.choose_spec hcin

/-! ## ReLU networks with one input -/

/-- The knot budget of a depth-`L`, width-`w` ReLU network. -/
def knotBound (w : ℕ) : ℕ → ℕ
  | 0 => 0
  | (L+1) => w * (2 * knotBound w L + 4)

/-- `LayerUnits w L us` : the family `us` is the family of unit functions of layer `L`
of a ReLU network with one real input whose hidden layers have width at most `w`. -/
inductive LayerUnits (w : ℕ) : ℕ → ∀ {n : ℕ}, (Fin n → ℝ → ℝ) → Prop
  | input : LayerUnits w 0 (fun (_ : Fin 1) (x : ℝ) => x)
  | step {L n m : ℕ} {us : Fin n → ℝ → ℝ} (h : LayerUnits w L us) (hm : m ≤ w)
      (W : Fin m → Fin n → ℝ) (b : Fin m → ℝ) :
      LayerUnits w (L+1) (fun (j : Fin m) (x : ℝ) => relu ((∑ i, W j i * us i x) + b j))

/-- `IsNet w L f` : `f : ℝ → ℝ` is computed exactly by a ReLU network with `L`
hidden layers of width at most `w` and an affine read-out. -/
def IsNet (w L : ℕ) (f : ℝ → ℝ) : Prop :=
  ∃ (n : ℕ) (us : Fin n → ℝ → ℝ), LayerUnits w L us ∧
    ∃ (c : Fin n → ℝ) (d : ℝ), f = fun x => (∑ i, c i * us i x) + d

/-- Every unit of layer `L` is piecewise affine with at most `knotBound w L` knots. -/
theorem layerUnits_pwa {w L n : ℕ} {us : Fin n → ℝ → ℝ} (h : LayerUnits w L us) :
    ∃ S : Finset ℝ, S.card ≤ knotBound w L ∧ ∀ i, PWA S (us i) := by
  classical
  induction h with
  | input =>
      refine ⟨∅, by simp [knotBound], fun i => ?_⟩
      have he : (fun (x : ℝ) => x) = fun (x : ℝ) => (1:ℝ) * x + 0 := by funext x; ring
      simpa [he] using PWA.affine (1:ℝ) 0
  | @step L n m us _ hm W b ih =>
      obtain ⟨S, hScard, hS⟩ := ih
      have hg : ∀ j : Fin m, PWA S (fun x => (∑ i, W j i * us i x) + b j) :=
        fun j => PWA.affine_comb hS (W j) (b j)
      choose T hTcard hT using fun j => (hg j).relu_step
      refine ⟨Finset.univ.biUnion T, ?_,
        fun j => (hT j).mono (Finset.subset_biUnion_of_mem T (Finset.mem_univ j))⟩
      calc (Finset.univ.biUnion T).card ≤ ∑ j : Fin m, (T j).card := Finset.card_biUnion_le
        _ ≤ ∑ _j : Fin m, (2 * S.card + 4) := Finset.sum_le_sum (fun j _ => hTcard j)
        _ = m * (2 * S.card + 4) := by simp [Finset.sum_const, mul_comm]
        _ ≤ w * (2 * knotBound w L + 4) := Nat.mul_le_mul hm (by omega)

/-- The function computed by a depth-`L`, width-`w` network is piecewise affine with
at most `knotBound w L` knots. -/
theorem IsNet.pwa {w L : ℕ} {f : ℝ → ℝ} (h : IsNet w L f) :
    ∃ S : Finset ℝ, S.card ≤ knotBound w L ∧ PWA S f := by
  obtain ⟨n, us, hus, c, d, rfl⟩ := h
  obtain ⟨S, hScard, hS⟩ := layerUnits_pwa hus
  exact ⟨S, hScard, PWA.affine_comb hS c d⟩

/-- The knot budget grows at most like `(2w+2)^L`. -/
theorem knotBound_le (w L : ℕ) : knotBound w L + 2 ≤ 2 * (2 * w + 2) ^ L := by
  induction L with
  | zero => simp [knotBound]
  | succ L ih =>
      have hpos : 1 ≤ (2 * w + 2) ^ L := Nat.one_le_pow _ _ (by omega)
      simp only [knotBound]
      have hrw : w * (2 * knotBound w L + 4) + 2 = 2 * w * (knotBound w L + 2) + 2 := by ring
      rw [hrw]
      calc 2 * w * (knotBound w L + 2) + 2 ≤ 2 * w * (2 * (2 * w + 2) ^ L) + 2 := by
            have := Nat.mul_le_mul_left (2 * w) ih; omega
        _ ≤ 2 * (2 * w + 2) ^ (L + 1) := by
            rw [pow_succ]
            nlinarith [hpos]

/-! ## The sawtooth tower -/

/-- The sawtooth (hat) map on `[0,1]`, written as a width-`3` ReLU combination. -/
def tri (y : ℝ) : ℝ := 2 * relu y - 4 * relu (y - 1/2) + 2 * relu (y - 1)

/-- The three biases of the sawtooth layer. -/
def triShift : Fin 3 → ℝ := ![0, 1/2, 1]

/-- The three read-out weights of the sawtooth layer. -/
def triCoef : Fin 3 → ℝ := ![2, -4, 2]

lemma tri_as_comb (y : ℝ) : (∑ i : Fin 3, triCoef i * relu (y - triShift i)) = tri y := by
  simp [Fin.sum_univ_three, triCoef, triShift, tri]
  ring

lemma tri_left {y : ℝ} (h0 : 0 ≤ y) (h1 : y ≤ 1/2) : tri y = 2 * y := by
  unfold tri relu
  rw [max_eq_left h0, max_eq_right (by linarith), max_eq_right (by linarith)]
  ring

lemma tri_right {y : ℝ} (h0 : 1/2 ≤ y) (h1 : y ≤ 1) : tri y = 2 - 2 * y := by
  unfold tri relu
  rw [max_eq_left (by linarith), max_eq_left (by linarith), max_eq_right (by linarith)]
  ring

/-- **Oscillation of the sawtooth tower.**  At the `2^k+1` dyadic points `i/2^k`
the `k`-fold sawtooth alternates between `0` and `1`. -/
theorem tri_iterate_dyadic (k : ℕ) : ∀ i : ℕ, i ≤ 2^k →
    tri^[k] ((i : ℝ) / 2^k) = if Even i then 0 else 1 := by
  induction k with
  | zero =>
      intro i hi
      interval_cases i <;> norm_num
  | succ k ih =>
      intro i hi
      rw [Function.iterate_succ_apply]
      rcases le_or_gt i (2^k) with hcase | hcase
      · have hx0 : (0:ℝ) ≤ (i:ℝ)/2^(k+1) := by positivity
        have hx1 : (i:ℝ)/2^(k+1) ≤ 1/2 := by
          rw [div_le_iff₀ (by positivity)]
          have : (i:ℝ) ≤ 2^k := by exact_mod_cast hcase
          rw [pow_succ]; linarith
        rw [tri_left hx0 hx1]
        have hdouble : 2 * ((i:ℝ)/2^(k+1)) = (i:ℝ)/2^k := by rw [pow_succ]; field_simp
        rw [hdouble]
        exact ih i hcase
      · have hx0 : (1:ℝ)/2 ≤ (i:ℝ)/2^(k+1) := by
          rw [le_div_iff₀ (by positivity)]
          have : (2:ℝ)^k ≤ i := by exact_mod_cast hcase.le
          rw [pow_succ]; linarith
        have hx1 : (i:ℝ)/2^(k+1) ≤ 1 := by
          rw [div_le_one (by positivity)]
          exact_mod_cast hi
        rw [tri_right hx0 hx1]
        set j : ℕ := 2^(k+1) - i with hj
        have hji : (j : ℝ) = 2^(k+1) - i := by
          rw [hj]; push_cast [Nat.cast_sub hi]; ring
        have hjle : j ≤ 2^k := by
          have h1 : 2^k ≤ i := hcase.le
          have h2 : 2^(k+1) = 2^k + 2^k := by ring
          omega
        have heq : 2 - 2 * ((i:ℝ)/2^(k+1)) = (j:ℝ)/2^k := by
          rw [hji, pow_succ]; field_simp
        rw [heq, ih j hjle]
        have hpar : Even j ↔ Even i := by
          rw [hj, Nat.even_sub hi]
          simp [Nat.even_pow]
        by_cases hEi : Even i
        · rw [if_pos (hpar.mpr hEi), if_pos hEi]
        · rw [if_neg (fun hc => hEi (hpar.mp hc)), if_neg hEi]

/-- **Stacking sawtooth layers.**  On top of *any* sub-network with units `us` and
read-out `g = ∑ c i * us i + d`, one can stack `l+1` further layers of width `3`,
and the resulting layer computes the shifted units of `tri^[l] ∘ g`. -/
theorem tri_tower_layerUnits {w L n : ℕ} (h3 : 3 ≤ w) {us : Fin n → ℝ → ℝ}
    (hus : LayerUnits w L us) (c : Fin n → ℝ) (d : ℝ) (l : ℕ) :
    LayerUnits w (L + 1 + l)
      (fun (j : Fin 3) (x : ℝ) => relu (tri^[l] ((∑ i, c i * us i x) + d) - triShift j)) := by
  induction l with
  | zero =>
      have h := hus.step h3 (fun (_ : Fin 3) (i : Fin n) => c i) (fun j => d - triShift j)
      have e : (fun (j : Fin 3) (x : ℝ) => relu (tri^[0] ((∑ i, c i * us i x) + d) - triShift j))
          = fun (j : Fin 3) (x : ℝ) => relu ((∑ i, c i * us i x) + (d - triShift j)) := by
        funext j x; simp [Function.iterate_zero_apply]; ring_nf
      rw [e]; exact h
  | succ l ih =>
      have h := ih.step h3 (fun (_ : Fin 3) (i : Fin 3) => triCoef i) (fun j => -triShift j)
      have e : (fun (j : Fin 3) (x : ℝ) =>
            relu (tri^[l+1] ((∑ i, c i * us i x) + d) - triShift j))
          = fun (j : Fin 3) (x : ℝ) => relu ((∑ i : Fin 3, triCoef i *
              relu (tri^[l] ((∑ i, c i * us i x) + d) - triShift i)) + (-triShift j)) := by
        funext j x
        rw [tri_as_comb, ← Function.iterate_succ_apply' tri l, sub_eq_add_neg]
      rw [e]; exact h

/-- Composing a sub-network with a tower of `l+1` sawtooth layers. -/
theorem tri_tower_isNet {w L n : ℕ} (h3 : 3 ≤ w) {us : Fin n → ℝ → ℝ}
    (hus : LayerUnits w L us) (c : Fin n → ℝ) (d : ℝ) (l : ℕ) :
    IsNet w (L + 1 + l) (fun x => tri^[l+1] ((∑ i, c i * us i x) + d)) := by
  refine ⟨3, _, tri_tower_layerUnits h3 hus c d l, triCoef, 0, ?_⟩
  funext x
  rw [add_zero, tri_as_comb, ← Function.iterate_succ_apply' tri l]

/-- **Upper bound side.**  `tri^[l+1]` is computed *exactly* by a ReLU network of
depth `l+1` and width `3`, i.e. with `3(l+1)` hidden neurons. -/
theorem sawtooth_isNet (l : ℕ) : IsNet 3 (l+1) (tri^[l+1]) := by
  have h := tri_tower_isNet (w := 3) (le_refl 3) LayerUnits.input (fun _ : Fin 1 => (1:ℝ)) 0 l
  have e : (fun x : ℝ => tri^[l+1] ((∑ _i : Fin 1, (1:ℝ) * x) + 0)) = tri^[l+1] := by
    funext x; simp
  rw [e] at h
  have e2 : 0 + 1 + l = l + 1 := by omega
  rwa [e2] at h

/-! ## The oscillation lower bound -/

/-- An affine function cannot go low–high–low. -/
lemma no_affine_oscillation {f : ℝ → ℝ} {x1 x2 x3 : ℝ} (h12 : x1 < x2) (h23 : x2 < x3)
    (haff : AffineOn f x1 x3) (hl1 : f x1 ≤ 1/4) (hh : 3/4 ≤ f x2) (hl3 : f x3 ≤ 1/4) : False := by
  obtain ⟨a, b, hab⟩ := haff
  have e1 : f x1 = a * x1 + b := hab x1 ⟨le_refl _, le_of_lt (lt_trans h12 h23)⟩
  have e2 : f x2 = a * x2 + b := hab x2 ⟨le_of_lt h12, le_of_lt h23⟩
  have e3 : f x3 = a * x3 + b := hab x3 ⟨le_of_lt (lt_trans h12 h23), le_refl _⟩
  rw [e1] at hl1; rw [e2] at hh; rw [e3] at hl3
  nlinarith [mul_pos (sub_pos.2 h12) (sub_pos.2 h23), sub_pos.2 h12, sub_pos.2 h23]

/-- **Oscillations force knots.**  A piecewise affine function alternating between
`≤ 1/4` and `≥ 3/4` along `m+1` increasing points of `[0,1]` has at least
`⌊m/2⌋` knots. -/
theorem alternating_knots {S : Finset ℝ} {f : ℝ → ℝ} (hf : PWA S f) (m : ℕ)
    (p : ℕ → ℝ) (hmono : StrictMono p) (hp0 : 0 ≤ p 0) (hpm : p m ≤ 1)
    (hlow : ∀ j ≤ m, Even j → f (p j) ≤ 1/4)
    (hhigh : ∀ j ≤ m, ¬ Even j → 3/4 ≤ f (p j)) :
    m ≤ 2 * S.card + 1 := by
  classical
  have key : ∀ t : ℕ, 2 * t + 2 ≤ m → ∃ z ∈ S, p (2*t) < z ∧ z < p (2*t+2) := by
    intro t ht
    by_contra hcon
    push_neg at hcon
    have hno : ∀ z ∈ S, z ≤ p (2*t) ∨ p (2*t+2) ≤ z := by
      intro z hz
      rcases le_or_gt z (p (2*t)) with h | h
      · exact Or.inl h
      · exact Or.inr (hcon z hz h)
    have haff := hf (p (2*t)) (p (2*t+2)) (le_trans hp0 (hmono.monotone (Nat.zero_le _)))
      (hmono.monotone (by omega)) (le_trans (hmono.monotone ht) hpm) hno
    exact no_affine_oscillation (hmono (by omega : 2*t < 2*t+1)) (hmono (by omega : 2*t+1 < 2*t+2))
      haff (hlow _ (by omega) ⟨t, by ring⟩)
      (hhigh _ (by omega) (by simp [parity_simps]))
      (hlow _ ht ⟨t+1, by ring⟩)
  have key' : ∀ t : ℕ, ∃ z : ℝ, 2 * t + 2 ≤ m → (z ∈ S ∧ p (2*t) < z ∧ z < p (2*t+2)) := by
    intro t
    by_cases ht : 2 * t + 2 ≤ m
    · obtain ⟨z, hz1, hz2⟩ := key t ht
      exact ⟨z, fun _ => ⟨hz1, hz2⟩⟩
    · exact ⟨0, fun h => absurd h ht⟩
  choose g hg using key'
  have hmaps : Set.MapsTo g (Finset.range (m / 2) : Finset ℕ) (S : Finset ℝ) := by
    intro t ht
    simp only [Finset.coe_range, Set.mem_Iio] at ht
    exact_mod_cast (hg t (by omega)).1
  have hinj : Set.InjOn g (Finset.range (m / 2)) := by
    intro s hs t ht hst
    simp only [Finset.coe_range, Set.mem_Iio] at hs ht
    by_contra hne
    rcases lt_or_gt_of_ne hne with h | h
    · have h1 := (hg s (by omega)).2.2
      have h2 := (hg t (by omega)).2.1
      have h3 : p (2*s+2) ≤ p (2*t) := hmono.monotone (by omega)
      rw [hst] at h1; linarith
    · have h1 := (hg t (by omega)).2.2
      have h2 := (hg s (by omega)).2.1
      have h3 : p (2*t+2) ≤ p (2*s) := hmono.monotone (by omega)
      rw [hst] at h2; linarith
  have hcard := Finset.card_le_card_of_injOn g hmaps hinj
  simp only [Finset.card_range] at hcard
  omega

/-- **Approximating the sawtooth tower costs knots.**  Any piecewise affine `f`
within `1/4` of `tri^[k]` on `[0,1]` has at least `(2^k-1)/2` knots. -/
theorem sawtooth_knots_lower_bound {S : Finset ℝ} {f : ℝ → ℝ} (hf : PWA S f) (k : ℕ)
    (happrox : ∀ x ∈ Set.Icc (0:ℝ) 1, |f x - tri^[k] x| ≤ 1/4) :
    2^k ≤ 2 * S.card + 1 := by
  set p : ℕ → ℝ := fun j => (j : ℝ) / 2^k with hp
  have hmono : StrictMono p := by
    intro a b hab
    have h : (a:ℝ) < b := by exact_mod_cast hab
    simp only [hp]
    gcongr
  have hmem : ∀ j : ℕ, j ≤ 2^k → p j ∈ Set.Icc (0:ℝ) 1 := by
    intro j hj
    refine ⟨by positivity, ?_⟩
    rw [hp]
    simp only
    rw [div_le_one (by positivity)]
    exact_mod_cast hj
  refine alternating_knots hf (2^k) p hmono (by simp [hp]) ?_ ?_ ?_
  · have hone : p (2^k) = 1 := by
      simp only [hp]
      rw [div_eq_one_iff_eq (by positivity)]
      push_cast; ring
    rw [hone]
  · intro j hj hje
    have h1 := happrox (p j) (hmem j hj)
    have h2 : tri^[k] (p j) = 0 := by rw [hp]; simpa [hje] using tri_iterate_dyadic k j hj
    rw [h2] at h1
    linarith [(abs_le.mp h1).2]
  · intro j hj hje
    have h1 := happrox (p j) (hmem j hj)
    have h2 : tri^[k] (p j) = 1 := by rw [hp]; simpa [hje] using tri_iterate_dyadic k j hj
    rw [h2] at h1
    linarith [(abs_le.mp h1).1]

/-! ## The main separation -/

/-- **The general oscillation bound.**  A depth-`L`, width-`w` ReLU network which is
uniformly within `1/4` of the sawtooth tower `tri^[k]` on `[0,1]` forces
`2^k ≤ 4 (2w+2)^L`.  Every separation below is an instance of this inequality. -/
theorem relu_oscillation_bound (L w k : ℕ) (f : ℝ → ℝ) (hnet : IsNet w L f)
    (happrox : ∀ x ∈ Set.Icc (0:ℝ) 1, |f x - tri^[k] x| ≤ 1/4) :
    2 ^ k ≤ 4 * (2 * w + 2) ^ L := by
  obtain ⟨S, hScard, hS⟩ := hnet.pwa
  have h1 : 2 ^ k ≤ 2 * S.card + 1 := sawtooth_knots_lower_bound hS _ happrox
  have h2 := knotBound_le w L
  omega

/-- **Main theorem.**  If a ReLU network of depth `L ≥ 1` and width `w` approximates
the sawtooth tower `tri^[L^2+4]` within `1/4` uniformly on `[0,1]`, then
`2^L ≤ 2w + 2`: the width must be exponential in the depth. -/
theorem relu_depth_separation (L w : ℕ) (hL : 1 ≤ L) (f : ℝ → ℝ) (hnet : IsNet w L f)
    (happrox : ∀ x ∈ Set.Icc (0:ℝ) 1, |f x - tri^[L^2+4] x| ≤ 1/4) :
    2 ^ L ≤ 2 * w + 2 := by
  have hbig : 2 ^ (L^2+4) ≤ 4 * (2 * w + 2) ^ L :=
    relu_oscillation_bound L w (L^2+4) f hnet happrox
  by_contra hcon
  push_neg at hcon
  have e : ((2:ℕ)^L)^L = 2^(L^2) := by rw [← pow_mul, pow_two]
  have h3 : (2*w+2)^L < (2^L)^L := Nat.pow_lt_pow_left hcon (by omega)
  rw [e] at h3
  have h4 : (2:ℕ)^(L^2+4) = 2^(L^2) * 16 := by rw [pow_add]; norm_num
  have h5 : 1 ≤ (2:ℕ)^(L^2) := Nat.one_le_pow _ _ (by norm_num)
  omega

/-- The same bound in width form: a depth-`L` approximator has width at least
`2^(L-1) - 1`. -/
theorem relu_depth_separation_width (L w : ℕ) (hL : 1 ≤ L) (f : ℝ → ℝ) (hnet : IsNet w L f)
    (happrox : ∀ x ∈ Set.Icc (0:ℝ) 1, |f x - tri^[L^2+4] x| ≤ 1/4) :
    2 ^ (L - 1) ≤ w + 1 := by
  have h := relu_depth_separation L w hL f hnet happrox
  have e : (2:ℕ) ^ L = 2 * 2 ^ (L - 1) := by
    obtain ⟨m, rfl⟩ : ∃ m, L = m + 1 := ⟨L - 1, by omega⟩
    rw [pow_succ]; simp [mul_comm]
  omega

/-- **Exact representations are just as expensive.**  Even an exact piecewise affine
representation of `tri^[k]` needs `(2^k-1)/2` knots. -/
theorem tri_iterate_knots {S : Finset ℝ} (k : ℕ) (hS : PWA S (tri^[k])) :
    2 ^ k ≤ 2 * S.card + 1 :=
  sawtooth_knots_lower_bound hS k (by intro x _; simp)

/-- **Summary of the depth separation.**  For every depth `L ≥ 1`:

* the explicit function `tri^[L^2+4]` is computed *exactly* by a ReLU network of
  depth `L^2+4` and width `3` — depth and size both polynomial in `L`;
* every ReLU network of depth `L` whose output is uniformly within `1/4` of it on
  `[0,1]` has width at least `2^(L-1) - 1`, hence *exponential* size in `L`. -/
theorem depth_separation_summary (L : ℕ) (hL : 1 ≤ L) :
    IsNet 3 (L^2+4) (tri^[L^2+4]) ∧
      ∀ (w : ℕ) (f : ℝ → ℝ), IsNet w L f →
        (∀ x ∈ Set.Icc (0:ℝ) 1, |f x - tri^[L^2+4] x| ≤ 1/4) → 2 ^ (L - 1) ≤ w + 1 := by
  refine ⟨?_, fun w f hnet happrox => relu_depth_separation_width L w hL f hnet happrox⟩
  have h := sawtooth_isNet (L^2+3)
  have e : L^2 + 3 + 1 = L^2 + 4 := by omega
  rwa [e] at h

end ReluDepth

end