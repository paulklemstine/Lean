import Physics.WeakD6Core

/-!
# The abelian-labelling obstruction for weakly `D₆`-free families

The conjecture under investigation asks for explicit `q`, `n₀` and a rational
`c > 3` such that, for `n ≥ n₀`, a labelling of `[n]` into a finite vector space
produces a weakly `D₆`-free family in `2^[n]` of size at least `c · C(n, ⌊n/2⌋)`.

The natural mechanism is: take **four** consecutive layers `k, k+1, k+2, k+3`
around the middle, keep three of them in full, and *thin out* the layer `k+2`
using a labelling `v : [n] → V` (`V` a finite abelian group, e.g. `𝔽_q^d`) by
keeping only those `S` whose *sum label* `∑_{i ∈ S} v i` lies in a prescribed set
`U ⊆ V`.  By `WeakD6.fourLayer_weaklyD6Free_iff`, freeness of the resulting
family is *exactly* a deterministic interval-exclusion condition on `(v, U)`.

This file proves that this mechanism **cannot** produce any constant `c > 3`:

* `WeakD6.safe_of_weaklyD6Free` — freeness forces the algebraic *safety*
  condition on `(v, U)` (this is the deterministic half of the conjecture, and
  it needs no probabilistic input);
* `WeakD6.card_labelFiber_le_two` — safety forces every label class to have at
  most two elements (so `|V| ≥ n/2` for any nontrivial selection);
* `WeakD6.card_U_le_two` — if the label set occupies more than `2/3` of `V`,
  safety forces `|U| ≤ 2`: at most **two** of the `|V|` colour classes survive;
* `WeakD6.card_selectedFamily_le` and `WeakD6.selection_gain_le` — hence the
  family has at most `3·C(n,⌊n/2⌋) + 2b` sets, where `b` bounds the size of a
  single colour class, i.e. `c ≤ 3 + 2/K` whenever `K·b ≤ C(n,⌊n/2⌋)`.

Under the equidistribution heuristic `b ≈ C(n,⌊n/2⌋)/|V|` and `|V| ≥ n/2`, the
last item gives `c ≤ 3 + O(1/n)`: the gain is *finite but vanishing*, so no fixed
rational `c > 3` is attainable by an abelian sum-labelling.
-/

namespace WeakD6

open Finset

variable {V : Type*} [AddCommGroup V] [Fintype V] [DecidableEq V]

/-- The sum label `∑_{i ∈ S} v i` of a set `S`. -/
def sumLabel (v : ℕ → V) (S : Finset ℕ) : V := ∑ i ∈ S, v i

omit [Fintype V] [DecidableEq V] in
lemma sumLabel_union_of_disjoint (v : ℕ → V) {A B : Finset ℕ} (h : Disjoint A B) :
    sumLabel v (A ∪ B) = sumLabel v A + sumLabel v B := by
  simp [sumLabel, Finset.sum_union h]

/-- The four-layer family thinned out by the labelling: layers `k`, `k+1`, `k+3`
in full, and the `U`-coloured part of layer `k+2`. -/
def selectedFamily (n k : ℕ) (v : ℕ → V) (U : Finset V) : Finset (Finset ℕ) :=
  layer n k ∪ layer n (k + 1) ∪
    ((layer n (k + 2)).filter fun S => sumLabel v S ∈ U) ∪ layer n (k + 3)

/-- The algebraic *safety* condition: no three distinct points `x, y, z` and no
shift `g` have all three pair-labels `g + v a + v b` inside the keep-set `U`. -/
def SafeSelection (n : ℕ) (v : ℕ → V) (U : Finset V) : Prop :=
  ∀ g : V, ∀ x ∈ Finset.range n, ∀ y ∈ Finset.range n, ∀ z ∈ Finset.range n,
    x ≠ y → x ≠ z → y ≠ z →
    ¬ (g + v x + v y ∈ U ∧ g + v x + v z ∈ U ∧ g + v y + v z ∈ U)

/-- Sum-richness: every group element is realised as the sum label of a `k`-set
avoiding three prescribed points.  (This is the "probabilistic rank estimate"
input, isolated as a hypothesis.) -/
def SumRich (n k : ℕ) (v : ℕ → V) : Prop :=
  ∀ g : V, ∀ x y z : ℕ, ∃ A ∈ layer n k, Disjoint A ({x, y, z} : Finset ℕ) ∧ sumLabel v A = g

section Membership

variable {n k : ℕ} {v : ℕ → V} {U : Finset V}

omit [Fintype V] in
lemma layer_k_subset_selected : layer n k ⊆ selectedFamily n k v U := fun S hS => by
  simp only [selectedFamily, Finset.mem_union]
  exact Or.inl (Or.inl (Or.inl hS))

omit [Fintype V] in
lemma layer_k1_subset_selected : layer n (k + 1) ⊆ selectedFamily n k v U := fun S hS => by
  simp only [selectedFamily, Finset.mem_union]
  exact Or.inl (Or.inl (Or.inr hS))

omit [Fintype V] in
lemma layer_k3_subset_selected : layer n (k + 3) ⊆ selectedFamily n k v U := fun S hS => by
  simp only [selectedFamily, Finset.mem_union]
  exact Or.inr hS

omit [Fintype V] in
lemma mem_selected_of_layer_k2 {S : Finset ℕ} (hS : S ∈ layer n (k + 2))
    (hU : sumLabel v S ∈ U) : S ∈ selectedFamily n k v U := by
  simp only [selectedFamily, Finset.mem_union, Finset.mem_filter]
  exact Or.inl (Or.inr ⟨hS, hU⟩)

end Membership

omit [Fintype V] in
/-- **Freeness forces safety.**  If the thinned four-layer family is weakly
`D₆`-free and the labelling is sum-rich, then `(v, U)` is safe. -/
theorem safe_of_weaklyD6Free (n k : ℕ) (v : ℕ → V) (U : Finset V) (hrich : SumRich n k v)
    (hfree : WeaklyDiamondFree 6 (selectedFamily n k v U)) : SafeSelection n v U := by
  classical
  rintro g x hx y hy z hz hxy hxz hyz ⟨h1, h2, h3⟩
  obtain ⟨A, hA, hdisj, hsum⟩ := hrich g x y z
  rw [mem_layer] at hA
  have hxr : x < n := Finset.mem_range.1 hx
  have hyr : y < n := Finset.mem_range.1 hy
  have hzr : z < n := Finset.mem_range.1 hz
  set C : Finset ℕ := A ∪ ({x, y, z} : Finset ℕ) with hC
  have hxyz_card : ({x, y, z} : Finset ℕ).card = 3 := by
    rw [Finset.card_insert_of_notMem (by simp [hxy, hxz]),
      Finset.card_insert_of_notMem (by simp [hyz]), Finset.card_singleton]
  have hCcard : C.card = k + 3 := by
    rw [hC, Finset.card_union_of_disjoint hdisj, hA.2, hxyz_card]
  have hCsub : C ⊆ Finset.range n := by
    rw [hC]
    refine Finset.union_subset hA.1 ?_
    intro a ha
    simp only [Finset.mem_insert, Finset.mem_singleton] at ha
    rcases ha with rfl | rfl | rfl <;> simp [Finset.mem_range, hxr, hyr, hzr]
  have hAC : A ⊆ C := Finset.subset_union_left
  have hAmem : A ∈ selectedFamily n k v U :=
    layer_k_subset_selected (mem_layer.2 ⟨hA.1, hA.2⟩)
  have hCmem : C ∈ selectedFamily n k v U :=
    layer_k3_subset_selected (mem_layer.2 ⟨hCsub, hCcard⟩)
  obtain ⟨B, hAB, hBC, hBF⟩ :=
    exclusion_of_weaklyD6Free hfree hAmem hCmem hAC (by omega)
  -- every set strictly between `A` and `C` does belong to the family
  apply hBF
  have hBsub : B ⊆ Finset.range n := hBC.1.trans hCsub
  have hBcards : A.card < B.card ∧ B.card < C.card :=
    ⟨Finset.card_lt_card hAB, Finset.card_lt_card hBC⟩
  have hBA : B \ A ⊆ ({x, y, z} : Finset ℕ) := by
    intro a ha
    obtain ⟨haB, haA⟩ := Finset.mem_sdiff.1 ha
    rcases Finset.mem_union.1 (hBC.1 haB) with h | h
    · exact absurd h haA
    · exact h
  have hBeq : A ∪ (B \ A) = B := Finset.union_sdiff_of_subset hAB.1
  have hdisjBA : Disjoint A (B \ A) := Finset.disjoint_sdiff
  have hBAcard : (B \ A).card = B.card - A.card := Finset.card_sdiff_of_subset hAB.1
  rcases (show B.card = k + 1 ∨ B.card = k + 2 by omega) with hb | hb
  · exact layer_k1_subset_selected (mem_layer.2 ⟨hBsub, hb⟩)
  · refine mem_selected_of_layer_k2 (mem_layer.2 ⟨hBsub, hb⟩) ?_
    -- the sum label of `B` is one of the three pair labels
    have hcard2 : (B \ A).card = 2 := by omega
    obtain ⟨a, b, hab, hBAeq⟩ := Finset.card_eq_two.1 hcard2
    have hpair : sumLabel v ({a, b} : Finset ℕ) = v a + v b := by
      rw [sumLabel, Finset.sum_insert (by simp [hab]), Finset.sum_singleton]
    have hsumB : sumLabel v B = g + v a + v b := by
      rw [← hBeq, sumLabel_union_of_disjoint v hdisjBA, hsum, hBAeq, hpair]
      abel
    have haBA : a ∈ B \ A := by rw [hBAeq]; simp
    have hbBA : b ∈ B \ A := by rw [hBAeq]; simp
    have ha3 : a ∈ ({x, y, z} : Finset ℕ) := hBA haBA
    have hb3 : b ∈ ({x, y, z} : Finset ℕ) := hBA hbBA
    simp only [Finset.mem_insert, Finset.mem_singleton] at ha3 hb3
    rw [hsumB]
    rcases ha3 with rfl | rfl | rfl <;> rcases hb3 with rfl | rfl | rfl <;>
      first
        | exact absurd rfl hab
        | exact h1
        | exact h2
        | exact h3
        | (simpa [add_right_comm] using h1)
        | (simpa [add_right_comm] using h2)
        | (simpa [add_right_comm] using h3)

omit [Fintype V] in
/-- **Label multiplicity.**  Safety with a nonempty keep-set forces every label
class to contain at most two points of `[n]`. -/
theorem card_labelFiber_le_two (n : ℕ) (v : ℕ → V) (U : Finset V)
    (hsafe : SafeSelection n v U) (hU : U.Nonempty) (a : V) :
    ((Finset.range n).filter (fun i => v i = a)).card ≤ 2 := by
  classical
  by_contra hcon
  push_neg at hcon
  obtain ⟨T, hTsub, hTcard⟩ :=
    Finset.exists_subset_card_eq (show 3 ≤ ((Finset.range n).filter (fun i => v i = a)).card by
      omega)
  obtain ⟨x, y, z, hxy, hxz, hyz, rfl⟩ := Finset.card_eq_three.1 hTcard
  obtain ⟨u, hu⟩ := hU
  have hx : x ∈ (Finset.range n).filter (fun i => v i = a) := hTsub (by simp)
  have hy : y ∈ (Finset.range n).filter (fun i => v i = a) := hTsub (by simp)
  have hz : z ∈ (Finset.range n).filter (fun i => v i = a) := hTsub (by simp)
  rw [Finset.mem_filter] at hx hy hz
  refine hsafe (u - a - a) x hx.1 y hy.1 z hz.1 hxy hxz hyz ⟨?_, ?_, ?_⟩
  · rw [hx.2, hy.2, show u - a - a + a + a = u from by abel]; exact hu
  · rw [hx.2, hz.2, show u - a - a + a + a = u from by abel]; exact hu
  · rw [hy.2, hz.2, show u - a - a + a + a = u from by abel]; exact hu

omit [AddCommGroup V] in
/-- A finite-group pigeonhole: two subsets of a finite type meet if their sizes
add up to more than the size of the type. -/
lemma card_inter_ge (s t : Finset V) :
    s.card + t.card ≤ (s ∩ t).card + Fintype.card V := by
  have h1 : (s ∩ t).card + (s ∪ t).card = s.card + t.card := Finset.card_inter_add_card_union s t
  have h2 : (s ∪ t).card ≤ Fintype.card V := Finset.card_le_univ _
  omega

/-- **The closure obstruction.**  If the label set occupies more than two thirds
of `V`, safety forces the keep-set to have at most two elements. -/
theorem card_U_le_two (n : ℕ) (v : ℕ → V) (U : Finset V) (hsafe : SafeSelection n v U)
    (hrich : 2 * Fintype.card V < 3 * ((Finset.range n).image v).card) :
    U.card ≤ 2 := by
  classical
  by_contra hcon
  push_neg at hcon
  obtain ⟨T, hTsub, hTcard⟩ := Finset.exists_subset_card_eq (show 3 ≤ U.card by omega)
  obtain ⟨u₁, u₂, u₃, h12, h13, h23, rfl⟩ := Finset.card_eq_three.1 hTcard
  have hu₁ : u₁ ∈ U := hTsub (by simp)
  have hu₂ : u₂ ∈ U := hTsub (by simp)
  have hu₃ : u₃ ∈ U := hTsub (by simp)
  set L : Finset V := (Finset.range n).image v with hL
  set al : V := u₁ - u₃ with hal
  set be : V := u₁ - u₂ with hbe
  -- pigeonhole: some `c` has `c`, `c + al`, `c + be` all in the label set
  set s₂ : Finset V := L.image (fun t => t - al) with hs₂
  set s₃ : Finset V := L.image (fun t => t - be) with hs₃
  have hcard₂ : s₂.card = L.card :=
    Finset.card_image_of_injective _ (fun a b h => by simpa using h)
  have hcard₃ : s₃.card = L.card :=
    Finset.card_image_of_injective _ (fun a b h => by simpa using h)
  have hne : (L ∩ s₂ ∩ s₃).Nonempty := by
    have h1 := card_inter_ge L s₂
    have h2 := card_inter_ge (L ∩ s₂) s₃
    refine Finset.card_pos.1 ?_
    omega
  obtain ⟨c, hc⟩ := hne
  rw [Finset.mem_inter, Finset.mem_inter] at hc
  obtain ⟨⟨hcL, hc₂⟩, hc₃⟩ := hc
  have hc₂' : c + al ∈ L := by
    rw [hs₂, Finset.mem_image] at hc₂
    obtain ⟨t, ht, hteq⟩ := hc₂
    have : c + al = t := by rw [← hteq]; abel
    rwa [this]
  have hc₃' : c + be ∈ L := by
    rw [hs₃, Finset.mem_image] at hc₃
    obtain ⟨t, ht, hteq⟩ := hc₃
    have : c + be = t := by rw [← hteq]; abel
    rwa [this]
  -- recover indices carrying these three labels
  rw [hL, Finset.mem_image] at hcL hc₂' hc₃'
  obtain ⟨z, hz, hvz⟩ := hcL
  obtain ⟨x, hx, hvx⟩ := hc₂'
  obtain ⟨y, hy, hvy⟩ := hc₃'
  -- the three labels are pairwise distinct, hence so are the indices
  have hal0 : al ≠ 0 := by
    intro h; rw [hal] at h; exact h13 (sub_eq_zero.1 h)
  have hbe0 : be ≠ 0 := by
    intro h; rw [hbe] at h; exact h12 (sub_eq_zero.1 h)
  have halbe : al ≠ be := by
    intro h
    rw [hal, hbe] at h
    exact h23 (sub_right_inj.mp h).symm
  have hxy : x ≠ y := by
    intro h
    have h1 : c + al = c + be := by rw [← hvx, ← hvy, h]
    exact halbe (add_left_cancel h1)
  have hxz : x ≠ z := by
    intro h
    have h1 : c + al = c := by rw [← hvx, ← hvz, h]
    exact hal0 (by simpa using h1)
  have hyz : y ≠ z := by
    intro h
    have h1 : c + be = c := by rw [← hvy, ← hvz, h]
    exact hbe0 (by simpa using h1)
  -- the shift that makes all three pair labels land in `U`
  refine hsafe (u₂ + u₃ - u₁ - c - c) x hx y hy z hz hxy hxz hyz ⟨?_, ?_, ?_⟩
  · have : u₂ + u₃ - u₁ - c - c + v x + v y = u₁ := by
      rw [hvx, hvy, hal, hbe]; abel
    rw [this]; exact hu₁
  · have : u₂ + u₃ - u₁ - c - c + v x + v z = u₂ := by
      rw [hvx, hvz, hal]; abel
    rw [this]; exact hu₂
  · have : u₂ + u₃ - u₁ - c - c + v y + v z = u₃ := by
      rw [hvy, hvz, hbe]; abel
    rw [this]; exact hu₃

/-- **Small groups cannot help.**  Combining the multiplicity bound with the
closure obstruction: if the labelling group has fewer than `3n/4` elements and
anything at all survives in the thinned layer, then at most two colour classes
survive.  (The label set then automatically covers more than two thirds of `V`.) -/
theorem card_U_le_two_of_small_group (n : ℕ) (v : ℕ → V) (U : Finset V)
    (hsafe : SafeSelection n v U) (hU : U.Nonempty) (hV : 4 * Fintype.card V < 3 * n) :
    U.card ≤ 2 := by
  classical
  have hmult : ∀ a : V, ((Finset.range n).filter (fun i => v i = a)).card ≤ 2 :=
    card_labelFiber_le_two n v U hsafe hU
  have hn : n ≤ 2 * ((Finset.range n).image v).card := by
    have := Finset.card_le_mul_card_image (s := Finset.range n) (f := v) 2 (fun a _ => hmult a)
    simpa using this
  exact card_U_le_two n v U hsafe (by omega)

omit [Fintype V] in
/-- The `U`-coloured part of a layer is at most `|U|` colour classes big. -/
lemma card_filter_mem_le (n k : ℕ) (v : ℕ → V) (U : Finset V) (b : ℕ)
    (hfib : ∀ u : V, ((layer n k).filter (fun S => sumLabel v S = u)).card ≤ b) :
    ((layer n k).filter (fun S => sumLabel v S ∈ U)).card ≤ U.card * b := by
  classical
  have hsub : (layer n k).filter (fun S => sumLabel v S ∈ U) ⊆
      U.biUnion (fun u => (layer n k).filter (fun S => sumLabel v S = u)) := by
    intro S hS
    rw [Finset.mem_filter] at hS
    exact Finset.mem_biUnion.2 ⟨sumLabel v S, hS.2, Finset.mem_filter.2 ⟨hS.1, rfl⟩⟩
  calc ((layer n k).filter (fun S => sumLabel v S ∈ U)).card
      ≤ (U.biUnion (fun u => (layer n k).filter (fun S => sumLabel v S = u))).card :=
        Finset.card_le_card hsub
    _ ≤ ∑ u ∈ U, ((layer n k).filter (fun S => sumLabel v S = u)).card :=
        Finset.card_biUnion_le
    _ ≤ ∑ _u ∈ U, b := Finset.sum_le_sum (fun u _ => hfib u)
    _ = U.card * b := by rw [Finset.sum_const, smul_eq_mul]

omit [Fintype V] in
/-- **Cardinality ceiling for the labelling construction.**  With at most two
surviving colour classes, each of size at most `b`, the thinned four-layer family
has at most `3·C(n,⌊n/2⌋) + 2b` members. -/
theorem card_selectedFamily_le (n k : ℕ) (v : ℕ → V) (U : Finset V) (b : ℕ)
    (hfib : ∀ u : V, ((layer n (k + 2)).filter (fun S => sumLabel v S = u)).card ≤ b)
    (hU : U.card ≤ 2) :
    (selectedFamily n k v U).card ≤ 3 * n.choose (n / 2) + 2 * b := by
  classical
  have hmid : ∀ j : ℕ, (layer n j).card ≤ n.choose (n / 2) := by
    intro j; rw [card_layer]; exact Nat.choose_le_middle j n
  have hsel := card_filter_mem_le n (k + 2) v U b hfib
  have h1 : (selectedFamily n k v U).card ≤
      (layer n k).card + (layer n (k + 1)).card +
        ((layer n (k + 2)).filter (fun S => sumLabel v S ∈ U)).card + (layer n (k + 3)).card := by
    refine le_trans (Finset.card_union_le _ _) ?_
    have := Finset.card_union_le (layer n k ∪ layer n (k + 1))
      ((layer n (k + 2)).filter fun S => sumLabel v S ∈ U)
    have h2 := Finset.card_union_le (layer n k) (layer n (k + 1))
    omega
  have hUb : U.card * b ≤ 2 * b := Nat.mul_le_mul_right b hU
  have := hmid k
  have := hmid (k + 1)
  have := hmid (k + 3)
  omega

/-- **No constant improvement.**  Suppose the thinned four-layer family produced
by an abelian sum-labelling is weakly `D₆`-free, the labelling is sum-rich and
label-rich, and every colour class inside the thinned layer has at most `b`
members with `K·b ≤ C(n, ⌊n/2⌋)`.  Then the family has size at most
`(3 + 2/K)·C(n, ⌊n/2⌋)`.  In particular no fixed rational `c > 3` is reachable
once `K` grows with `n` (as equidistribution predicts, `K ≈ |V| ≥ n/2`). -/
theorem selection_gain_le (n k : ℕ) (v : ℕ → V) (U : Finset V) (b K : ℕ)
    (hrich : SumRich n k v)
    (hlabels : 2 * Fintype.card V < 3 * ((Finset.range n).image v).card)
    (hfib : ∀ u : V, ((layer n (k + 2)).filter (fun S => sumLabel v S = u)).card ≤ b)
    (hK : K * b ≤ n.choose (n / 2))
    (hfree : WeaklyDiamondFree 6 (selectedFamily n k v U)) :
    K * (selectedFamily n k v U).card ≤ (3 * K + 2) * n.choose (n / 2) := by
  have hsafe := safe_of_weaklyD6Free n k v U hrich hfree
  have hU := card_U_le_two n v U hsafe hlabels
  have hcard := card_selectedFamily_le n k v U b hfib hU
  calc K * (selectedFamily n k v U).card ≤ K * (3 * n.choose (n / 2) + 2 * b) :=
        Nat.mul_le_mul_left K hcard
    _ = 3 * K * n.choose (n / 2) + 2 * (K * b) := by ring
    _ ≤ 3 * K * n.choose (n / 2) + 2 * n.choose (n / 2) :=
        Nat.add_le_add_left (Nat.mul_le_mul_left 2 hK) _
    _ = (3 * K + 2) * n.choose (n / 2) := by ring

/-- **No constant improvement, small-group form.**  Same conclusion as
`selection_gain_le`, but with the natural hypothesis `|V| < 3n/4` in place of
label richness: the labelling group is small enough that the labels must cover
more than two thirds of it. -/
theorem selection_gain_le_small_group (n k : ℕ) (v : ℕ → V) (U : Finset V) (b K : ℕ)
    (hrich : SumRich n k v) (hV : 4 * Fintype.card V < 3 * n)
    (hfib : ∀ u : V, ((layer n (k + 2)).filter (fun S => sumLabel v S = u)).card ≤ b)
    (hK : K * b ≤ n.choose (n / 2))
    (hfree : WeaklyDiamondFree 6 (selectedFamily n k v U)) :
    K * (selectedFamily n k v U).card ≤ (3 * K + 2) * n.choose (n / 2) := by
  have hU : U.card ≤ 2 := by
    rcases U.eq_empty_or_nonempty with rfl | hne
    · simp
    · exact card_U_le_two_of_small_group n v U (safe_of_weaklyD6Free n k v U hrich hfree) hne hV
  have hcard := card_selectedFamily_le n k v U b hfib hU
  calc K * (selectedFamily n k v U).card ≤ K * (3 * n.choose (n / 2) + 2 * b) :=
        Nat.mul_le_mul_left K hcard
    _ = 3 * K * n.choose (n / 2) + 2 * (K * b) := by ring
    _ ≤ 3 * K * n.choose (n / 2) + 2 * n.choose (n / 2) :=
        Nat.add_le_add_left (Nat.mul_le_mul_left 2 hK) _
    _ = (3 * K + 2) * n.choose (n / 2) := by ring

end WeakD6