/-
# A product-one criterion: reduction to the abelian quotient

The paper under study reduces the non-commutative product-one problem for
`H_{p^3}` to additive combinatorics over `F_p^2`.  Here we formalise the
complementary half of that reduction: the passage from the *centre*.

**Theorem** (`exists_productOne_of_central_blocks`).  If a sequence is split
into `p` nonempty consecutive blocks, each of which has *central* product, then
it has a nonempty product-one subsequence.

The proof is a pigeonhole on the prefix products of the block products: those
prefix products all lie in the centre `⟨v⟩ ≅ C_p`, of which there are only `p`,
so two of the `p + 1` prefixes coincide and the blocks in between multiply to
`1`.

We also record that product-one-freeness only depends on the multiset of the
sequence (`ProductOneFree.perm`), so the "consecutive blocks" hypothesis costs
no generality once one is allowed to reorder.
-/
import Algebra.Heisenberg125.Basic
import Algebra.Heisenberg125.CosetBound

namespace Heisenberg125

variable {G : Type*} [Group G]

/-- Having product one only depends on the multiset of the sequence. -/
lemma IsProductOne.perm {L L' : List G} (h : IsProductOne L) (hp : L.Perm L') :
    IsProductOne L' := by
  obtain ⟨M, hM, hprod⟩ := h
  exact ⟨M, hM.trans hp, hprod⟩

/-- Product-one-freeness only depends on the multiset of the sequence. -/
theorem ProductOneFree.perm {L L' : List G} (h : ProductOneFree L) (hp : L.Perm L') :
    ProductOneFree L' := by
  intro T hT hne hone
  obtain ⟨T', hT'perm, hT'sub⟩ := (hT.subperm.trans hp.symm.subperm)
  refine h T' hT'sub (fun hc => hne ?_) (hone.perm hT'perm.symm)
  have hTnil : T.Perm [] := by rw [← hc]; exact hT'perm.symm
  exact hTnil.eq_nil

namespace Heis

variable {p : ℕ}

/-- The product of a list of central elements is central, with central
coordinate the sum of the central coordinates. -/
lemma prod_of_central {L : List (Heis p)} (h : ∀ g ∈ L, g.a = 0 ∧ g.b = 0) :
    L.prod = ⟨0, 0, csum L⟩ := by
  rw [prod_eq, crossSum_eq_zero_of_a_eq_zero fun g hg => (h g hg).1,
    asum_of_const (α := 0) fun g hg => (h g hg).1,
    bsum_of_const (β := 0) fun g hg => (h g hg).2]
  simp

/-- **Block criterion.**  If a sequence is cut into at least `p` nonempty
consecutive blocks whose products are all central, then it has a nonempty
product-one subsequence: the "quotient sequence" of block products lives in the
centre `C_p`, where the pigeonhole applies. -/
theorem exists_productOne_of_central_blocks [NeZero p] {Bs : List (List (Heis p))}
    (hne : ∀ B ∈ Bs, B ≠ []) (hcen : ∀ B ∈ Bs, (B.prod).a = 0 ∧ (B.prod).b = 0)
    (hlen : p ≤ Bs.length) :
    ∃ T : List (Heis p), T.Sublist Bs.flatten ∧ T ≠ [] ∧ T.prod = 1 := by
  classical
  set P : List (Heis p) := Bs.map List.prod with hP
  have hPlen : P.length = Bs.length := by simp [hP]
  have hPcen : ∀ g ∈ P, g.a = 0 ∧ g.b = 0 := by
    intro g hg
    obtain ⟨B, hB, rfl⟩ := List.mem_map.1 hg
    exact hcen B hB
  -- all prefix products of `P` are central
  have hprefix : ∀ k : ℕ, ((P.take k).prod).a = 0 ∧ ((P.take k).prod).b = 0 := by
    intro k
    have hsub : ∀ g ∈ P.take k, g.a = 0 ∧ g.b = 0 := fun g hg =>
      hPcen g ((List.take_sublist k P).mem hg)
    rw [prod_of_central hsub]
    exact ⟨rfl, rfl⟩
  -- the key construction, given two prefixes with the same central coordinate
  have hkey : ∀ k l : ℕ, k < l → l ≤ Bs.length →
      ((P.take k).prod).c = ((P.take l).prod).c →
      ∃ T : List (Heis p), T.Sublist Bs.flatten ∧ T ≠ [] ∧ T.prod = 1 := by
    intro k l hlt hle heq
    have hpeq : (P.take k).prod = (P.take l).prod := by
      ext
      · rw [(hprefix k).1, (hprefix l).1]
      · rw [(hprefix k).2, (hprefix l).2]
      · exact heq
    refine ⟨((Bs.take l).drop k).flatten,
      ((List.drop_sublist _ _).trans (List.take_sublist _ _)).flatten, ?_, ?_⟩
    · -- nonempty, since the first block in the range is nonempty
      have hlenBs : ((Bs.take l).drop k).length = l - k := by
        simp [List.length_drop, List.length_take, Nat.min_eq_left hle]
      have hBsne : (Bs.take l).drop k ≠ [] := by
        intro hc
        rw [hc] at hlenBs
        simp only [List.length_nil] at hlenBs
        omega
      obtain ⟨B, hB⟩ := List.exists_mem_of_ne_nil _ hBsne
      have hBne : B ≠ [] :=
        hne B (((List.drop_sublist _ _).trans (List.take_sublist _ _)).mem hB)
      obtain ⟨g, hg⟩ := List.exists_mem_of_ne_nil B hBne
      intro hc
      have hmem : g ∈ ((Bs.take l).drop k).flatten := List.mem_flatten.2 ⟨B, hB, hg⟩
      rw [hc] at hmem
      simp at hmem
    · -- the product telescopes to `1`
      have hmap : ((Bs.take l).drop k).map List.prod = (P.take l).drop k := by
        rw [hP, ← List.map_take, ← List.map_drop]
      rw [List.prod_flatten, hmap]
      have htake : (P.take l).take k = P.take k := by
        rw [List.take_take, Nat.min_eq_left hlt.le]
      have hsplit : (P.take k).prod * ((P.take l).drop k).prod = (P.take l).prod := by
        rw [← htake, ← List.prod_append, List.take_append_drop]
      exact mul_left_cancel (a := (P.take k).prod) (by rw [hsplit, ← hpeq, mul_one])
  -- pigeonhole on the central coordinate of the first `p + 1` prefix products
  obtain ⟨i, hi, j, hj, hij, hval⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to
      (s := Finset.range (p + 1)) (t := (Finset.univ : Finset (ZMod p)))
      (by simp [ZMod.card]) (fun k _ => Finset.mem_univ (((P.take k).prod).c))
  simp only [Finset.mem_range] at hi hj
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · exact hkey i j hlt (by omega) hval
  · exact hkey j i hlt (by omega) hval.symm

/-- Contrapositive form: a product-one-free sequence cannot be reordered into
`p` nonempty consecutive blocks with central products. -/
theorem lt_of_productOneFree_blocks [NeZero p] {L : List (Heis p)}
    {Bs : List (List (Heis p))} (hfree : ProductOneFree L) (hperm : L.Perm Bs.flatten)
    (hne : ∀ B ∈ Bs, B ≠ []) (hcen : ∀ B ∈ Bs, (B.prod).a = 0 ∧ (B.prod).b = 0) :
    Bs.length < p := by
  by_contra hlen
  push_neg at hlen
  obtain ⟨T, hTsub, hTne, hTprod⟩ := exists_productOne_of_central_blocks hne hcen hlen
  exact (hfree.perm hperm) T hTsub hTne ⟨T, List.Perm.refl _, hTprod⟩

end Heis

end Heisenberg125