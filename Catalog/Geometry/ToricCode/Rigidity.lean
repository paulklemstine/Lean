import ToricCode.ClassWeights

/-!
# Rigidity of minimum-weight logical operators

`ToricCode.toric_distance` computes the *value* `min M N` of the `Z`-distance.
This file classifies the *optimisers*: for a strictly rectangular torus
(`M < N`) a logical operator of the minimal weight `M` is **exactly** one of the
`N` horizontal row loops — no other chain achieves the distance.

* `rowLoop y` — all `M` horizontal edges of the row at height `y`;
* `rowLoop_is_logical` / `hammingNorm_rowLoop` — each row loop is a logical
  operator of weight `M`;
* `min_weight_logical_eq_rowLoop` — the converse, i.e. rigidity;
* `min_weight_logicals_card` — consequently the minimum-weight logical operators
  are in bijection with `ZMod N`: there are exactly `N` of them.

The proof is a counting rigidity argument.  A cycle with nonzero horizontal
winding meets each of the `M` disjoint column cuts, so weight `M` forces the
support to meet each cut *exactly once* and to contain **no vertical edge at
all**.  A purely horizontal cycle satisfies `z(false, u) = z(false, u - (1,0))`,
so its indicator is constant along each row; counting the support again then
forces exactly one row to be occupied.
-/

open Matrix

namespace ToricCode

variable (M N : ℕ) [NeZero M] [NeZero N]

lemma F2_eq_one_of_ne_zero {a : F2} (h : a ≠ 0) : a = 1 := by
  revert h
  revert a
  decide

/-- The horizontal loop at height `y`: all `M` horizontal edges of that row. -/
def rowLoop (y : ZMod N) : Edge M N → F2 := fun e => if e.1 = false ∧ e.2.2 = y then 1 else 0

omit [NeZero M] [NeZero N] in
lemma rowLoop_zero : rowLoop M N 0 = loopH M N := rfl

variable {M N}

lemma rowLoop_cycle (y : ZMod N) : (d1 M N) *ᵥ (rowLoop M N y) = 0 := by
  funext v
  rw [d1_mulVec]
  obtain ⟨a, b⟩ := v
  simp only [rowLoop]
  have e1 : ((a, b) : ZMod M × ZMod N) - (1, 0) = (a - 1, b) := by simp
  have e2 : ((a, b) : ZMod M × ZMod N) - (0, 1) = (a, b - 1) := by simp
  rw [e1, e2]
  by_cases h : b = y
  · simp [h]
    decide
  · simp [h]

lemma rowLoop_mem (y : ZMod N) : rowLoop M N y ∈ cycles M N := by
  simpa [cycles, LinearMap.mem_ker] using rowLoop_cycle y

omit [NeZero M] in
lemma hWind_rowLoop (y : ZMod N) (i : ZMod M) : hWind M N (rowLoop M N y) i = 1 := by
  rw [hWind]
  have hpt : ∀ b : ZMod N,
      rowLoop M N y (false, (i, b)) = if y = b then (1 : F2) else 0 := by
    intro b
    simp only [rowLoop]
    by_cases h : b = y
    · simp [h]
    · simp [h, Ne.symm h]
  rw [Finset.sum_congr rfl (fun b _ => hpt b)]
  simp

lemma rowLoop_not_boundary (y : ZMod N) : rowLoop M N y ∉ boundaries M N := by
  rintro ⟨g, hg⟩
  have h := hWind_of_boundary M N g 0
  rw [show (d2 M N) *ᵥ g = rowLoop M N y from hg, hWind_rowLoop] at h
  exact one_ne_zero h

/-- Each row loop is an undetectable non-stabiliser error. -/
theorem rowLoop_is_logical (y : ZMod N) :
    rowLoop M N y ∈ cycles M N ∧ rowLoop M N y ∉ boundaries M N :=
  ⟨rowLoop_mem y, rowLoop_not_boundary y⟩

omit [NeZero M] [NeZero N] in
/-- The support of a row loop is exactly the set of horizontal edges of that row. -/
lemma rowLoop_ne_zero_iff (y : ZMod N) (e : Edge M N) :
    rowLoop M N y e ≠ 0 ↔ (e.1 = false ∧ e.2.2 = y) := by
  simp only [rowLoop]
  by_cases h : e.1 = false ∧ e.2.2 = y <;> simp [h]

/-- A row loop has weight exactly `M`. -/
lemma hammingNorm_rowLoop (y : ZMod N) : hammingNorm (rowLoop M N y) = M := by
  classical
  rw [support_card_eq]
  have hinj : Function.Injective (fun x : ZMod M => ((false, (x, y)) : Edge M N)) :=
    fun a b hab => by simpa using congrArg (fun e : Edge M N => e.2.1) hab
  have himg : (Finset.univ.filter (fun e : Edge M N => rowLoop M N y e ≠ 0))
      = Finset.univ.image (fun x : ZMod M => ((false, (x, y)) : Edge M N)) := by
    ext e
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image,
      rowLoop_ne_zero_iff]
    constructor
    · rintro ⟨h1, h2⟩
      obtain ⟨b, x, w⟩ := e
      exact ⟨x, by simp_all⟩
    · rintro ⟨x, rfl⟩
      exact ⟨rfl, rfl⟩
  rw [himg, Finset.card_image_of_injective _ hinj, Finset.card_univ, ZMod.card]

/-! ### Rigidity -/

/-- **A minimum-weight logical operator of a strictly rectangular torus contains
no vertical edge.** -/
lemma no_vertical_edge_of_min_weight (hMN : M < N) {z : Edge M N → F2}
    (hz : z ∈ cycles M N) (hnb : z ∉ boundaries M N) (hw : hammingNorm z = M)
    (x : ZMod M) (y : ZMod N) : z (true, (x, y)) = 0 := by
  classical
  have hcyc : (d1 M N) *ᵥ z = 0 := by simpa [cycles, LinearMap.mem_ker] using hz
  -- the horizontal winding must be the nonzero one
  have hh : hWind M N z 0 ≠ 0 := by
    rcases winding_ne_zero_of_not_boundary M N hz hnb with h | h
    · exact h
    · exact absurd (le_trans (N_le_weight_of_vWind M N hz h) (le_of_eq hw)) (by omega)
  set supp := Finset.univ.filter (fun e : Edge M N => z e ≠ 0) with hsupp
  have hcard : supp.card = M := by rw [hsupp, ← support_card_eq]; exact hw
  -- every column cut is met by a horizontal edge of the support
  have hcol : ∀ i : ZMod M, ∃ b : ZMod N, z (false, (i, b)) ≠ 0 := by
    intro i
    have hi : hWind M N z i ≠ 0 := by rw [hWind_const M N hcyc i]; exact hh
    by_contra hc
    push_neg at hc
    exact hi (Finset.sum_eq_zero (fun b _ => hc b))
  have hsurj : Set.SurjOn (fun e : Edge M N => e.2.1) supp (Finset.univ : Finset (ZMod M)) := by
    intro i _
    obtain ⟨b, hb⟩ := hcol i
    exact ⟨(false, (i, b)), by simp [hsupp, hb], rfl⟩
  have hinj : Set.InjOn (fun e : Edge M N => e.2.1) supp := by
    refine Finset.injOn_of_surjOn_of_card_le _ (fun e _ => Finset.mem_univ _) hsurj ?_
    rw [hcard, Finset.card_univ, ZMod.card]
  -- a vertical support edge would collide with the horizontal one in its column
  by_contra hne
  obtain ⟨b, hb⟩ := hcol x
  have h1 : ((true, (x, y)) : Edge M N) ∈ supp := by simp [hsupp, hne]
  have h2 : ((false, (x, b)) : Edge M N) ∈ supp := by simp [hsupp, hb]
  have := hinj h1 h2 rfl
  simp at this

/-- **Rigidity of the optimisers.**  On the `M × N` torus with `M < N`, every
logical operator of the minimal weight `M` *is* one of the `N` row loops. -/
theorem min_weight_logical_eq_rowLoop (hMN : M < N) {z : Edge M N → F2}
    (hz : z ∈ cycles M N) (hnb : z ∉ boundaries M N) (hw : hammingNorm z = M) :
    ∃ y : ZMod N, z = rowLoop M N y := by
  classical
  have hcyc : (d1 M N) *ᵥ z = 0 := by simpa [cycles, LinearMap.mem_ker] using hz
  have hvert : ∀ (x : ZMod M) (y : ZMod N), z (true, (x, y)) = 0 :=
    no_vertical_edge_of_min_weight hMN hz hnb hw
  -- a purely horizontal cycle is constant along each row
  have hstep : ∀ (x : ZMod M) (y : ZMod N),
      z (false, (x + 1, y)) = z (false, (x, y)) := by
    intro x y
    have h := congrFun hcyc (x + 1, y)
    rw [d1_mulVec] at h
    have e1 : ((x + 1, y) : ZMod M × ZMod N) - (1, 0) = (x, y) := by
      simp only [Prod.mk_sub_mk, Prod.mk.injEq]
      constructor <;> ring
    have e2 : ((x + 1, y) : ZMod M × ZMod N) - (0, 1) = (x + 1, y - 1) := by simp
    rw [e1, e2, hvert, hvert, add_zero, add_zero] at h
    have h2 : ∀ a c : F2, a + c = 0 → a = c := by decide
    exact h2 _ _ h
  have hconst : ∀ (x : ZMod M) (y : ZMod N), z (false, (x, y)) = z (false, (0, y)) := by
    intro x y
    exact zmod_const_of_succ (fun x => z (false, (x, y))) (fun x => hstep x y) x
  -- count the occupied rows
  set T := Finset.univ.filter (fun y : ZMod N => z (false, (0, y)) ≠ 0) with hT
  have himg : (Finset.univ.filter (fun e : Edge M N => z e ≠ 0))
      = (Finset.univ ×ˢ T).image (fun p : ZMod M × ZMod N => ((false, p) : Edge M N)) := by
    ext e
    obtain ⟨b, x, y⟩ := e
    constructor
    · intro hmem
      have hne : z (b, (x, y)) ≠ 0 := by simpa using hmem
      cases b
      · refine Finset.mem_image.mpr ⟨(x, y), ?_, rfl⟩
        simp only [Finset.mem_product, Finset.mem_univ, true_and, hT, Finset.mem_filter]
        rw [← hconst x y]
        exact hne
      · exact absurd (hvert x y) hne
    · intro hmem
      obtain ⟨p, hp, hpe⟩ := Finset.mem_image.mp hmem
      obtain ⟨a, c⟩ := p
      have hc : z (false, (0, c)) ≠ 0 := by
        have h2 := (Finset.mem_product.mp hp).2
        simpa [hT] using h2
      simp only [Prod.mk.injEq] at hpe
      obtain ⟨rfl, rfl, rfl⟩ := hpe
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      rw [hconst a c]
      exact hc
  have hinj : Function.Injective (fun p : ZMod M × ZMod N => ((false, p) : Edge M N)) :=
    fun a b hab => by simpa using hab
  have hcard : M * T.card = M := by
    have := hw
    rw [support_card_eq, himg, Finset.card_image_of_injective _ hinj,
      Finset.card_product, Finset.card_univ, ZMod.card] at this
    exact this
  have hM : 0 < M := Nat.pos_of_ne_zero (NeZero.ne M)
  have hT1 : T.card = 1 :=
    Nat.eq_of_mul_eq_mul_left hM (by rw [hcard, mul_one])
  obtain ⟨y₀, hy₀⟩ := Finset.card_eq_one.mp hT1
  refine ⟨y₀, ?_⟩
  funext e
  obtain ⟨b, x, y⟩ := e
  have hyT : ∀ y : ZMod N, z (false, (0, y)) ≠ 0 ↔ y = y₀ := by
    intro y
    constructor
    · intro h
      have : y ∈ T := by simp [hT, h]
      rw [hy₀] at this
      simpa using this
    · intro hy
      have hmem : y₀ ∈ T := by rw [hy₀]; simp
      rw [hy]
      simpa [hT] using hmem
  cases b
  · rw [hconst x y]
    by_cases h : y = y₀
    · subst h
      rw [show rowLoop M N y ((false, (x, y)) : Edge M N) = 1 by simp [rowLoop]]
      exact F2_eq_one_of_ne_zero ((hyT y).mpr rfl)
    · rw [show rowLoop M N y₀ ((false, (x, y)) : Edge M N) = 0 by simp [rowLoop, h]]
      by_contra hc
      exact h ((hyT y).mp hc)
  · rw [hvert x y, show rowLoop M N y₀ ((true, (x, y)) : Edge M N) = 0 by simp [rowLoop]]

/-- **There are exactly `N` minimum-weight logical operators** on the `M × N`
torus with `M < N`: the `N` horizontal row loops, and nothing else. -/
theorem min_weight_logicals_card (hMN : M < N) :
    {z : Edge M N → F2 | z ∈ cycles M N ∧ z ∉ boundaries M N ∧ hammingNorm z = M}
      = Set.range (rowLoop M N) := by
  ext z
  constructor
  · rintro ⟨hz, hnb, hw⟩
    obtain ⟨y, rfl⟩ := min_weight_logical_eq_rowLoop hMN hz hnb hw
    exact ⟨y, rfl⟩
  · rintro ⟨y, rfl⟩
    exact ⟨rowLoop_mem y, rowLoop_not_boundary y, hammingNorm_rowLoop y⟩

end ToricCode

/-
-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer).
  `toric_distance` computes the *value* of the systole; the bolder claim is that
  the optimisers are rigid, i.e. that a shortest noncontractible cellular loop on
  a strictly rectangular torus must literally be a straight row.

Experiment (Experimenter).
  Exhaustive enumeration over all `2^(2MN)` one-chains, using the definitions of
  this directory, counting the logical operators of the minimal weight
  `min M N` and comparing them with the `N` row loops `rowLoop`:

    M=1 N=2 :  #minimum-weight logicals = 2,  #row loops = 2,  equal
    M=1 N=3 :  #minimum-weight logicals = 3,  #row loops = 3,  equal
    M=2 N=3 :  #minimum-weight logicals = 3,  #row loops = 3,  equal
    M=2 N=2 :  #minimum-weight logicals = 4,  #row loops = 2,  NOT equal

  The last line is the decisive datum: it shows the hypothesis `M < N` is not a
  proof artefact.  On the square torus the `L` column loops also attain the
  distance, so there are `2L` optimisers and the classification statement is
  false as literally phrased.

Analysis (Analyst).
  The proof is a two-step counting rigidity.  (i) Weight `M` plus nonzero
  horizontal winding forces the support to meet each of the `M` column cuts, and
  since `|support| = M` the column map is a *bijection* on the support
  (`Finset.injOn_of_surjOn_of_card_le`); a vertical support edge would then
  collide with the horizontal edge in its own column, so there is none.
  (ii) A purely horizontal cycle satisfies `z(false,u) = z(false,u-(1,0))`, hence
  is constant along rows, so the support is a union of complete rows; `M·|T| = M`
  leaves exactly one row.  Note that step (i) is where `M < N` enters — it is
  needed only to rule out the *vertical* winding, via `N ≤ weight = M`.

Critique (Critic).
  The statement is not vacuous: `rowLoop_is_logical` and `hammingNorm_rowLoop`
  exhibit `N` distinct witnesses, and `min_weight_logicals_card` is an equality
  of sets, not an inequality.  No `native_decide` is used; the two `decide` calls
  are on closed identities in `𝔽₂`.

----
-/