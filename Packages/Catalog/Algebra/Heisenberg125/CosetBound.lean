/-
# A spread bound: at most `2p - 2` entries in any coset of the centre

The centre of `H_{p^3}` is `⟨v⟩`, and the cosets of the centre are the fibres of
the projection `(a,b,c) ↦ (a,b)` onto `(ZMod p)^2`.

**Theorem** (`Heis.length_le_of_const_image`).  If `p` is odd and `C` is a
product-one-free sequence over `H_{p^3}` all of whose entries have the same
image `(α, β)` in `(ZMod p)^2`, then `|C| ≤ 2p - 2`.

The proof is a genuine cross-domain application of the **Erdős–Ginzburg–Ziv
theorem**: `2p - 1` entries in one coset contain `p` of them whose central
coordinates sum to zero; those `p` entries multiply (in any order) to
`(pα, pβ, Σc + (p choose 2) αβ) = 1`, using that `p` is odd so that
`p ∣ binom p 2`.

The bound is sharp: `v^{p-1}` and `x^{p-1}(xv)^{p-1}`-type sequences show that
`2p - 2` entries with equal image can occur inside a product-one-free sequence.
-/
import Algebra.Heisenberg125.LowerBound

namespace Heisenberg125

namespace Heis

variable {p : ℕ}

/-- The `a`-sum of a list all of whose entries have first coordinate `α`. -/
lemma asum_of_const {L : List (Heis p)} {α : ZMod p} (h : ∀ g ∈ L, g.a = α) :
    asum L = α * (L.length : ℕ) := by
  induction L with
  | nil => simp
  | cons g L ih =>
      rw [asum_cons, h g (by simp), ih fun t ht => h t (by simp [ht])]
      simp only [List.length_cons]
      push_cast
      ring

/-- An element of the coset `(α, β)` of the centre is determined by its central
coordinate. -/
lemma eq_mk_of_const {g : Heis p} {α β : ZMod p} (h : g.a = α ∧ g.b = β) :
    g = ⟨α, β, g.c⟩ := by
  ext
  · exact h.1
  · exact h.2
  · rfl

/-- The multiset underlying a list contained in one coset of the centre is the
image of the multiset of central coordinates. -/
lemma coe_eq_map_mk {C : List (Heis p)} {α β : ZMod p}
    (h : ∀ g ∈ C, g.a = α ∧ g.b = β) :
    (C : Multiset (Heis p)) = ((C.map Heis.c : List (ZMod p)) : Multiset (ZMod p)).map
      (fun z => (⟨α, β, z⟩ : Heis p)) := by
  induction C with
  | nil => simp
  | cons g C ih =>
      have hg := h g (by simp)
      have hC : ∀ t ∈ C, t.a = α ∧ t.b = β := fun t ht => h t (by simp [ht])
      rw [List.map_cons, ← Multiset.cons_coe, ← Multiset.cons_coe, Multiset.map_cons,
        ← ih hC, ← eq_mk_of_const hg]

/-- **Spread bound in a coset of the centre.**  In a product-one-free sequence
over the odd-exponent Heisenberg group, at most `2p - 2` entries can lie in one
coset of the centre. -/
theorem length_le_of_const_image (hodd : Odd p) {C : List (Heis p)} {α β : ZMod p}
    (hfree : ProductOneFree C) (hconst : ∀ g ∈ C, g.a = α ∧ g.b = β) :
    C.length ≤ 2 * p - 2 := by
  by_contra hlen
  push_neg at hlen
  have hp : 0 < p := hodd.pos
  -- Erdős–Ginzburg–Ziv applied to the central coordinates.
  have hcard : 2 * p - 1 ≤ Multiset.card ((C.map Heis.c : List (ZMod p)) : Multiset (ZMod p)) := by
    simp only [Multiset.coe_card, List.length_map]
    omega
  obtain ⟨t, hts, htcard, htsum⟩ := ZMod.erdos_ginzburg_ziv_multiset _ hcard
  -- lift the chosen central coordinates back to a sub-multiset of `C`
  set f : ZMod p → Heis p := fun z => ⟨α, β, z⟩ with hf
  have hu : t.map f ≤ (C : Multiset (Heis p)) := by
    rw [coe_eq_map_mk hconst]
    exact Multiset.map_le_map hts
  -- realise this sub-multiset as a genuine subsequence `T` of `C`
  obtain ⟨T, hTperm, hTsub⟩ : List.Subperm (t.map f).toList C := by
    have : ((t.map f).toList : Multiset (Heis p)) ≤ (C : Multiset (Heis p)) := by
      rwa [Multiset.coe_toList]
    exact Multiset.coe_le.1 this
  have hTcoe : (T : Multiset (Heis p)) = t.map f := by
    rw [← Multiset.coe_toList (t.map f)]
    exact Quot.sound hTperm
  have hTlen : T.length = p := by
    have := congrArg Multiset.card hTcoe
    simpa [htcard] using this
  have hTconst : ∀ g ∈ T, g.a = α ∧ g.b = β := fun g hg => hconst g (hTsub.mem hg)
  -- the product of `T` is `1`
  have hprod : T.prod = 1 := by
    rw [prod_eq_one_iff]
    refine ⟨?_, ?_, ?_⟩
    · rw [asum_of_const fun g hg => (hTconst g hg).1, hTlen, ZMod.natCast_self, mul_zero]
    · rw [bsum_of_const fun g hg => (hTconst g hg).2, hTlen, ZMod.natCast_self, mul_zero]
    · have hcs : csum T = 0 := by
        have : csum T = Multiset.sum (Multiset.map Heis.c (T : Multiset (Heis p))) := rfl
        rw [this, hTcoe, Multiset.map_map]
        simpa [hf, Function.comp] using htsum
      rw [hcs, crossSum_of_const hTconst, hTlen, cast_choose_two_eq_zero hodd]
      simp
  exact hfree T hTsub (by intro hc; rw [hc] at hTlen; simp at hTlen; omega)
    ⟨T, List.Perm.refl _, hprod⟩

/-! ### Sharpness of the coset bound -/

/-- If every entry has vanishing second coordinate, the cross sum vanishes. -/
lemma crossSum_eq_zero_of_b_eq_zero {L : List (Heis p)} (h : ∀ g ∈ L, g.b = 0) :
    crossSum L = 0 := by
  induction L with
  | nil => rfl
  | cons g L ih =>
      have hb : bsum L = 0 := by
        rw [bsum_of_const (β := 0) fun t ht => h t (by simp [ht])]
        simp
      simp [hb, ih fun t ht => h t (by simp [ht])]

/-- The sequence `x^{p-1} (xv)^{p-1}`, of length `2p - 2`, all of whose entries
lie in the single coset `(1, 0)` of the centre. -/
def cosetExtremalSeq (p : ℕ) : List (Heis p) :=
  List.replicate (p - 1) (⟨1, 0, 0⟩ : Heis p) ++ List.replicate (p - 1) (⟨1, 0, 1⟩ : Heis p)

@[simp] lemma length_cosetExtremalSeq : (cosetExtremalSeq p).length = 2 * (p - 1) := by
  simp only [cosetExtremalSeq, List.length_append, List.length_replicate]
  ring

lemma const_image_cosetExtremalSeq :
    ∀ g ∈ cosetExtremalSeq p, g.a = (1 : ZMod p) ∧ g.b = (0 : ZMod p) := by
  intro g hg
  rcases List.mem_append.1 hg with h | h <;>
    · rw [List.eq_of_mem_replicate h]; exact ⟨rfl, rfl⟩

/-- **The coset bound `2p - 2` is attained**: `x^{p-1} (xv)^{p-1}` is
product-one-free and lives in a single coset of the centre.  In particular the
Erdős–Ginzburg–Ziv bound above cannot be improved. -/
theorem productOneFree_cosetExtremalSeq (hp : 0 < p) :
    ProductOneFree (cosetExtremalSeq p) := by
  rintro T hT hne ⟨M, hM, hprod⟩
  obtain ⟨T1, T2, rfl, h1, h2⟩ := List.sublist_append_iff.1 hT
  obtain ⟨i, hi, rfl⟩ := List.sublist_replicate_iff.1 h1
  obtain ⟨j, hj, rfl⟩ := List.sublist_replicate_iff.1 h2
  rw [prod_eq_one_iff] at hprod
  obtain ⟨ha, -, hc⟩ := hprod
  have hbzero : ∀ g ∈ M, g.b = 0 := by
    intro g hg
    exact (const_image_cosetExtremalSeq g
      (hT.mem (hM.mem_iff.1 hg))).2
  rw [crossSum_eq_zero_of_b_eq_zero hbzero, add_zero, csum_perm hM] at hc
  rw [asum_perm hM] at ha
  simp only [asum_append, asum_replicate, csum_append, csum_replicate,
    mul_one, mul_zero, zero_add] at ha hc
  have hj0 : j = 0 := eq_zero_of_cast_eq_zero hp hj hc
  subst hj0
  have hi0 : i = 0 := by
    refine eq_zero_of_cast_eq_zero hp hi ?_
    simpa using ha
  subst hi0
  exact hne (by simp)

end Heis

end Heisenberg125