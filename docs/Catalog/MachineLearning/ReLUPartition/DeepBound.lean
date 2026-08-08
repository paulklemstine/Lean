import Mathlib
import MachineLearning.ReLUPartition.MomentSharp

/-!
# Depth-`L` ReLU networks: the product region bound

A depth-`L` ReLU network on `ℝ^d` with hidden layers of width `w` partitions its
input space into the cells on which the whole network is affine.  A cell is
indexed by the tuple of activation patterns of the `L` layers, and this file
proves the exact product bound

  `#regions ≤ (schlafli w d)^L = (∑_{k ≤ d} C(w,k))^L`.

The mechanism is the *cell-wise affinization* of the network: on the set where
the first `l` activation patterns are fixed to `p_0, …, p_{l-1}`, every
pre-activation of layer `l` is an explicit affine function of the *input*
(`preFamily`, `layerPattern_eq_preFamily_pattern`).  Consequently the last
layer can only contribute as many new patterns as an affine family of `w`
functionals on `ℝ^d` can, namely `schlafli w d` of them by the exact bound of
`MachineLearning.ReLUPartition.SignVectors`; the product bound then follows by
induction on the depth.

Since the single-layer bound is attained (`regionCount_momentFamily`), the base
`schlafli w d` of the exponential is optimal: it cannot be replaced by anything
smaller that is valid for all layers.
-/

open Finset

namespace ReLUPartition

variable {d w : ℕ}

namespace AffineFamily

/-- The vector-valued affine map determined by a family of affine functionals. -/
def applyVec (F : AffineFamily w d) (x : Fin d → ℝ) : Fin w → ℝ := fun i => F.eval i x

/-- Composition of an affine family with a vector-valued affine map. -/
def comp {m : ℕ} (G : AffineFamily w m) (F : AffineFamily m d) : AffineFamily w d :=
  { weight := fun i j => ∑ p, G.weight i p * F.weight p j
    bias := fun i => (∑ p, G.weight i p * F.bias p) + G.bias i }

lemma eval_comp {m : ℕ} (G : AffineFamily w m) (F : AffineFamily m d) (i : Fin w)
    (x : Fin d → ℝ) : (G.comp F).eval i x = G.eval i (F.applyVec x) := by
  simp only [comp, eval, applyVec]
  have hexp : ∀ p : Fin m, G.weight i p * ((∑ j, F.weight p j * x j) + F.bias p)
      = (∑ j, G.weight i p * F.weight p j * x j) + G.weight i p * F.bias p := by
    intro p
    rw [mul_add, Finset.mul_sum]
    congr 1
    exact Finset.sum_congr rfl fun j _ => by ring
  have hswap : (∑ j, (∑ p, G.weight i p * F.weight p j) * x j)
      = ∑ p, ∑ j, G.weight i p * F.weight p j * x j := by
    have hmul : ∀ j : Fin d, (∑ p, G.weight i p * F.weight p j) * x j
        = ∑ p, G.weight i p * F.weight p j * x j := fun j => Finset.sum_mul _ _ _
    rw [Finset.sum_congr rfl (fun j _ => hmul j), Finset.sum_comm]
  rw [Finset.sum_congr rfl (fun p _ => hexp p), Finset.sum_add_distrib, hswap]
  ring

/-- Silencing the neurons outside `S`: this is what a ReLU layer does once its
activation pattern is known to be `S`. -/
def maskFamily (S : Finset (Fin w)) (F : AffineFamily w d) : AffineFamily w d :=
  { weight := fun i j => if i ∈ S then F.weight i j else 0
    bias := fun i => if i ∈ S then F.bias i else 0 }

lemma eval_maskFamily (S : Finset (Fin w)) (F : AffineFamily w d) (i : Fin w) (x : Fin d → ℝ) :
    (maskFamily S F).eval i x = if i ∈ S then F.eval i x else 0 := by
  by_cases hi : i ∈ S <;> simp [maskFamily, eval, hi]

/-- On the cell where the pattern of `F` is `S`, the ReLU of `F` is the affine
map `maskFamily S F`. -/
lemma relu_eq_maskFamily {F : AffineFamily w d} {S : Finset (Fin w)} {x : Fin d → ℝ}
    (hx : F.pattern x = S) (i : Fin w) :
    max 0 (F.eval i x) = (maskFamily S F).eval i x := by
  rw [eval_maskFamily]
  by_cases hi : i ∈ S
  · have hpos : 0 < F.eval i x := mem_pattern.mp (by rw [hx]; exact hi)
    simp [hi, le_of_lt hpos]
  · have : ¬ (0 < F.eval i x) := fun hcon => hi (by rw [← hx]; exact mem_pattern.mpr hcon)
    simp [hi, max_eq_left (not_lt.mp this)]

end AffineFamily

open AffineFamily

/-- A ReLU network on `ℝ^d` whose hidden layers all have width `w`. -/
structure ReLUNet (d w : ℕ) where
  /-- The first layer, mapping the input space to the first hidden layer. -/
  first : AffineFamily w d
  /-- The `(l+1)`-st layer, mapping hidden layer `l` to hidden layer `l+1`. -/
  layer : ℕ → AffineFamily w w

namespace ReLUNet

/-- The post-activation vector after `l+1` layers. -/
noncomputable def act (net : ReLUNet d w) : ℕ → (Fin d → ℝ) → (Fin w → ℝ)
  | 0, x => fun i => max 0 (net.first.eval i x)
  | (l + 1), x => fun i => max 0 ((net.layer l).eval i (net.act l x))

/-- The activation pattern of layer `l` at input `x`. -/
noncomputable def layerPattern (net : ReLUNet d w) : ℕ → (Fin d → ℝ) → Finset (Fin w)
  | 0, x => net.first.pattern x
  | (l + 1), x => (net.layer l).pattern (net.act l x)

/-- The input-space affine family computing the pre-activations of layer `l`,
given that the activation patterns of the earlier layers are `p`. -/
noncomputable def preFamily (net : ReLUNet d w) (p : ℕ → Finset (Fin w)) :
    ℕ → AffineFamily w d
  | 0 => net.first
  | (l + 1) => (net.layer l).comp (maskFamily (p l) (net.preFamily p l))

/-- **Cell-wise affinization.**  On the cell where the first `l+1` activation
patterns are `p`, the post-activation vector of layer `l` is an affine function
of the input, and the pattern of layer `l` is the pattern of the affine family
`preFamily p l`. -/
theorem act_eq_applyVec (net : ReLUNet d w) (p : ℕ → Finset (Fin w)) (x : Fin d → ℝ) :
    ∀ l : ℕ, (∀ i ≤ l, net.layerPattern i x = p i) →
      net.act l x = (maskFamily (p l) (net.preFamily p l)).applyVec x := by
  intro l
  induction l with
  | zero =>
      intro h
      funext i
      have hp : net.first.pattern x = p 0 := h 0 (le_refl 0)
      simpa [act, preFamily, applyVec] using relu_eq_maskFamily hp i
  | succ l ih =>
      intro h
      have hprev := ih (fun i hi => h i (by omega))
      funext i
      have hcomp : (net.layer l).eval i (net.act l x) = (net.preFamily p (l + 1)).eval i x := by
        rw [hprev, preFamily, eval_comp]
      have hpat : (net.preFamily p (l + 1)).pattern x = p (l + 1) := by
        have hl : net.layerPattern (l + 1) x = p (l + 1) := h (l + 1) (le_refl _)
        rw [← hl]
        ext j
        rw [mem_pattern, layerPattern, mem_pattern, hprev, preFamily, eval_comp]
      have := relu_eq_maskFamily hpat i
      rw [act, applyVec]
      simp only []
      rw [hcomp, this]

/-- The pattern of layer `l` is the pattern of the affine family `preFamily p l`
whenever the earlier patterns agree with `p`. -/
theorem layerPattern_eq_preFamily_pattern (net : ReLUNet d w) (p : ℕ → Finset (Fin w))
    (x : Fin d → ℝ) :
    ∀ l : ℕ, (∀ i < l, net.layerPattern i x = p i) →
      net.layerPattern l x = (net.preFamily p l).pattern x := by
  intro l
  cases l with
  | zero => intro _; rfl
  | succ l =>
      intro h
      have hprev := net.act_eq_applyVec p x l (fun i hi => h i (by omega))
      ext j
      rw [layerPattern, mem_pattern, mem_pattern, hprev, preFamily, eval_comp]

/-- The full activation pattern of a depth-`L` network. -/
noncomputable def netPattern (net : ReLUNet d w) (L : ℕ) (x : Fin d → ℝ) :
    Fin L → Finset (Fin w) := fun l => net.layerPattern (l : ℕ) x

open Classical in
/-- The set of realized activation patterns of a depth-`L` network: its cells. -/
noncomputable def netRegions (net : ReLUNet d w) (L : ℕ) : Finset (Fin L → Finset (Fin w)) :=
  univ.filter (fun q => ∃ x, net.netPattern L x = q)

@[simp] lemma mem_netRegions {net : ReLUNet d w} {L : ℕ} {q : Fin L → Finset (Fin w)} :
    q ∈ net.netRegions L ↔ ∃ x, net.netPattern L x = q := by
  classical simp [netRegions]

/-- **The depth-`L` product bound.**  A depth-`L` ReLU network with hidden layers
of width `w` on input space `ℝ^d` has at most `(∑_{k ≤ d} C(w,k))^L` cells. -/
theorem card_netRegions_le (net : ReLUNet d w) (L : ℕ) :
    (net.netRegions L).card ≤ (schlafli w d) ^ L := by
  classical
  induction L with
  | zero =>
      have : (net.netRegions 0).card ≤ 1 := by
        refine Finset.card_le_one.mpr fun a _ b _ => ?_
        funext i
        exact absurd i.isLt (by omega)
      simpa using this
  | succ L ih =>
      set r : (Fin (L + 1) → Finset (Fin w)) → (Fin L → Finset (Fin w)) :=
        fun q l => q l.castSucc with hr
      have hfiber : ∀ q0 ∈ (net.netRegions (L + 1)).image r,
          ((net.netRegions (L + 1)).filter (fun q => r q = q0)).card ≤ schlafli w d := by
        intro q0 _
        set p : ℕ → Finset (Fin w) := fun k => if h : k < L then q0 ⟨k, h⟩ else ∅ with hp
        have hpval : ∀ (k : ℕ) (hk : k < L), p k = q0 ⟨k, hk⟩ := by
          intro k hk
          simp only [hp]
          exact dif_pos hk
        set H : AffineFamily w d := net.preFamily p L with hH
        have hmaps : ∀ q ∈ (net.netRegions (L + 1)).filter (fun q => r q = q0),
            q (Fin.last L) ∈ H.regions := by
          intro q hq
          simp only [Finset.mem_filter, mem_netRegions] at hq
          obtain ⟨⟨x, hx⟩, hrq⟩ := hq
          have hpre : ∀ i < L, net.layerPattern i x = p i := by
            intro i hi
            have h1 : net.layerPattern i x = q ⟨i, by omega⟩ := by
              rw [← hx]; rfl
            have h2 : q ⟨i, by omega⟩ = q0 ⟨i, hi⟩ := by
              rw [← hrq, hr]
              rfl
            rw [h1, h2, hpval i hi]
          have hlast : net.layerPattern L x = H.pattern x :=
            net.layerPattern_eq_preFamily_pattern p x L hpre
          refine mem_regions.mpr ⟨x, ?_⟩
          rw [← hlast, ← hx]
          rfl
        have hinj : Set.InjOn (fun q : Fin (L + 1) → Finset (Fin w) => q (Fin.last L))
            ((net.netRegions (L + 1)).filter (fun q => r q = q0)) := by
          intro a ha b hb hab
          simp only [Finset.coe_filter, Set.mem_setOf_eq] at ha hb
          funext i
          refine Fin.lastCases ?_ ?_ i
          · exact hab
          · intro j
            have h1 : a j.castSucc = q0 j := by rw [← ha.2, hr]
            have h2 : b j.castSucc = q0 j := by rw [← hb.2, hr]
            rw [h1, h2]
        calc ((net.netRegions (L + 1)).filter (fun q => r q = q0)).card
            ≤ H.regions.card := Finset.card_le_card_of_injOn _ hmaps hinj
          _ ≤ schlafli w d := H.regionCount_le_schlafli
      have hmul := Finset.card_le_mul_card_image (f := r) (net.netRegions (L + 1))
        (schlafli w d) hfiber
      have himg : ((net.netRegions (L + 1)).image r).card ≤ (net.netRegions L).card := by
        refine Finset.card_le_card ?_
        intro q0 hq0
        simp only [Finset.mem_image, mem_netRegions] at hq0 ⊢
        obtain ⟨q, ⟨x, hx⟩, rfl⟩ := hq0
        exact ⟨x, by rw [← hx]; rfl⟩
      calc (net.netRegions (L + 1)).card
          ≤ schlafli w d * ((net.netRegions (L + 1)).image r).card := hmul
        _ ≤ schlafli w d * (net.netRegions L).card := Nat.mul_le_mul_left _ himg
        _ ≤ schlafli w d * (schlafli w d) ^ L := Nat.mul_le_mul_left _ ih
        _ = (schlafli w d) ^ (L + 1) := by ring

/-- The catalog capacity heuristic dominates the depth-`L` bound as well. -/
theorem card_netRegions_le_regionCapacity (net : ReLUNet d w) (L : ℕ) :
    (net.netRegions L).card ≤ ReLUWidthDepth.regionCapacity w (d * L) := by
  refine le_trans (net.card_netRegions_le L) ?_
  unfold ReLUWidthDepth.regionCapacity
  rw [pow_mul]
  exact Nat.pow_le_pow_left (schlafli_le_regionCapacity w d) L

/-- The base of the exponential is optimal: one layer already achieves
`schlafli w d` cells, so no bound of the form `c^L` with `c < schlafli w d` can
hold for all depth-`L` networks. -/
theorem exists_net_card_netRegions_eq (w d : ℕ) :
    ∃ net : ReLUNet d w, (net.netRegions 1).card = schlafli w d := by
  classical
  refine ⟨⟨momentFamily w d, fun _ => momentFamily w w⟩, ?_⟩
  have himg : (⟨momentFamily w d, fun _ => momentFamily w w⟩ : ReLUNet d w).netRegions 1
      = (momentFamily w d).regions.image (fun S => (fun _ => S : Fin 1 → Finset (Fin w))) := by
    ext q
    simp only [mem_netRegions, Finset.mem_image, AffineFamily.mem_regions]
    constructor
    · rintro ⟨x, rfl⟩
      exact ⟨(momentFamily w d).pattern x, ⟨x, rfl⟩, by funext i; fin_cases i; rfl⟩
    · rintro ⟨S, ⟨x, rfl⟩, rfl⟩
      exact ⟨x, by funext i; fin_cases i; rfl⟩
  rw [himg, Finset.card_image_of_injective _ (fun a b hab => by
    have := congrFun hab (0 : Fin 1); exact this)]
  exact regionCount_momentFamily w d

end ReLUNet

end ReLUPartition