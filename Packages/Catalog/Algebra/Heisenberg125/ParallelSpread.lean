/-
# A spread criterion: `p - 1` parallel elements plus one transversal element

This file records a *product-one criterion* for the Heisenberg group `Heis p`
which is genuinely non-commutative in nature: it exploits the fact that
reordering a sequence changes its product by a central element, and that the
achievable central corrections form the set of subset sums of a family of
nonzero elements of `ZMod p`.

The main theorem `Heis.isProductOne_of_parallel_spread` states:

> Let `G` be a list of pairwise *commuting* elements of `Heis p` (equivalently:
> their images in `(ZMod p)²` are pairwise parallel), let `z` be an element
> which commutes with *no* element of `G`, and let `R` be arbitrary.  If
> `|G| ≥ p - 1` and the sequence `G ++ z :: R` has vanishing image in
> `(ZMod p)²`, then some ordering of that sequence has product `1`.

No hypothesis whatsoever is needed on the central coordinates: the `p - 1`
parallel elements can be shuffled past `z` independently, and the resulting
central corrections `g.a * z.b - z.a * g.b` are `p - 1` nonzero elements of
`ZMod p`, whose subset sums exhaust `ZMod p`
(`Heis.exists_sublist_map_sum_eq`).
-/
import Algebra.Heisenberg125.RefinedBound

namespace Heisenberg125

namespace Heis

variable {p : ℕ}

/-! ### Subset sums of nonzero elements of `ZMod p` -/

section SubsetSums

variable [Fact p.Prime]

open Finset

/-- The set of all sums `Σ_{k ∈ K} f k` for `K` a sublist of `L`. -/
noncomputable def mapSums {α : Type*} (f : α → ZMod p) (L : List α) : Finset (ZMod p) :=
  (L.sublists.map (fun K => (K.map f).sum)).toFinset

omit [Fact p.Prime] in
lemma mem_mapSums_iff {α : Type*} (f : α → ZMod p) (L : List α) (t : ZMod p) :
    t ∈ mapSums f L ↔ ∃ K : List α, K.Sublist L ∧ (K.map f).sum = t := by
  simp [mapSums, List.mem_sublists, eq_comm]

omit [Fact p.Prime] in
lemma zero_mem_mapSums {α : Type*} (f : α → ZMod p) (L : List α) :
    (0 : ZMod p) ∈ mapSums f L :=
  (mem_mapSums_iff f L 0).2 ⟨[], List.nil_sublist _, by simp⟩

omit [Fact p.Prime] in
lemma mapSums_subset_cons {α : Type*} (f : α → ZMod p) (a : α) (L : List α) :
    mapSums f L ⊆ mapSums f (a :: L) := by
  intro t ht
  obtain ⟨K, hK, rfl⟩ := (mem_mapSums_iff f L t).1 ht
  exact (mem_mapSums_iff f (a :: L) _).2 ⟨K, hK.cons _, rfl⟩

omit [Fact p.Prime] in
lemma mapSums_image_subset_cons {α : Type*} (f : α → ZMod p) (a : α) (L : List α) :
    (mapSums f L).image (· + f a) ⊆ mapSums f (a :: L) := by
  intro t ht
  obtain ⟨s, hs, rfl⟩ := Finset.mem_image.1 ht
  obtain ⟨K, hK, rfl⟩ := (mem_mapSums_iff f L s).1 hs
  refine (mem_mapSums_iff f (a :: L) _).2 ⟨a :: K, hK.cons₂ _, ?_⟩
  simp [add_comm]

/-- A nonempty subset of `ZMod p` stable under translation by a nonzero element
is everything. -/
lemma eq_univ_of_add_stable {S : Finset (ZMod p)} {a : ZMod p} (ha : a ≠ 0)
    (hne : S.Nonempty) (hstab : ∀ x ∈ S, x + a ∈ S) : S = Finset.univ := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  obtain ⟨x₀, hx₀⟩ := hne
  have hstep : ∀ n : ℕ, x₀ + (n : ZMod p) * a ∈ S := by
    intro n
    induction n with
    | zero => simpa using hx₀
    | succ n ih =>
        have hmem := hstab _ ih
        have hcast : x₀ + ((n + 1 : ℕ) : ZMod p) * a = x₀ + (n : ZMod p) * a + a := by
          push_cast; ring
        rwa [hcast]
  refine Finset.eq_univ_iff_forall.2 fun y => ?_
  set k : ZMod p := (y - x₀) * a⁻¹ with hk
  have hkval : ((k.val : ℕ) : ZMod p) = k := by
    simp [ZMod.natCast_val, ZMod.cast_id]
  have hmem := hstep k.val
  rwa [hkval, hk, mul_assoc, inv_mul_cancel₀ ha, mul_one, add_sub_cancel] at hmem

/-- **Cauchy–Davenport bound for subset sums.**  If `f` takes nonzero values on
the entries of `M`, then the set of subset sums of `f` over `M` has at least
`min p (|M| + 1)` elements: each new nonzero value either enlarges the set of
reachable sums or the set is already all of `ZMod p`. -/
theorem card_mapSums_ge {α : Type*} (f : α → ZMod p) :
    ∀ M : List α, (∀ a ∈ M, f a ≠ 0) → min p (M.length + 1) ≤ (mapSums f M).card := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  intro M
  induction M with
    | nil =>
        intro _
        have h1 : (mapSums f ([] : List α)).card = 1 := by simp [mapSums]
        rw [h1]
        simp
    | cons a M ih =>
        intro hM
        have hM' : ∀ b ∈ M, f b ≠ 0 := fun b hb => hM b (by simp [hb])
        have ihM := ih hM'
        by_cases hfull : mapSums f M = Finset.univ
        · have huniv : mapSums f (a :: M) = Finset.univ :=
            Finset.eq_univ_iff_forall.2 fun x =>
              mapSums_subset_cons f a M (by rw [hfull]; exact Finset.mem_univ x)
          have hcp : (mapSums f (a :: M)).card = p := by
            rw [huniv, Finset.card_univ, ZMod.card]
          rw [hcp]
          exact min_le_left _ _
        · have hex : ∃ y ∈ (mapSums f M).image (· + f a), y ∉ mapSums f M := by
            by_contra hcon
            push_neg at hcon
            exact hfull (eq_univ_of_add_stable (hM a (by simp))
              ⟨0, zero_mem_mapSums f M⟩
              (fun x hx => hcon _ (Finset.mem_image.2 ⟨x, hx, rfl⟩)))
          obtain ⟨y, hy, hy'⟩ := hex
          have hins : insert y (mapSums f M) ⊆ mapSums f (a :: M) := by
            refine Finset.insert_subset ?_ (mapSums_subset_cons f a M)
            exact mapSums_image_subset_cons f a M hy
          have hcard' : (mapSums f M).card + 1 ≤ (mapSums f (a :: M)).card := by
            have hle := Finset.card_le_card hins
            rwa [Finset.card_insert_of_notMem hy'] at hle
          have hmin : min p (M.length + 1 + 1) ≤ min p (M.length + 1) + 1 := by
            rcases le_total p (M.length + 1) with h | h
            · rw [min_eq_left h, min_eq_left (le_trans h (Nat.le_succ _))]
              omega
            · rw [min_eq_right h]
              omega
          simp only [List.length_cons]
          omega
/-- **Subset sums of nonzero elements.**  If `f` takes nonzero values on the
`≥ p - 1` entries of `L`, then every element of `ZMod p` is the sum of `f`
over a sublist of `L`. -/
theorem exists_sublist_map_sum_eq {α : Type*} (f : α → ZMod p) (L : List α)
    (hnz : ∀ a ∈ L, f a ≠ 0) (hlen : p - 1 ≤ L.length) (t : ZMod p) :
    ∃ K : List α, K.Sublist L ∧ (K.map f).sum = t := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  have hL := card_mapSums_ge f L hnz
  have hp : p ≤ L.length + 1 := by
    have := (Fact.out : p.Prime).pos
    omega
  rw [min_eq_left hp] at hL
  have huniv : mapSums f L = Finset.univ := by
    apply Finset.eq_univ_of_card
    have hle : (mapSums f L).card ≤ p := by
      have := Finset.card_le_univ (mapSums f L)
      simpa [ZMod.card] using this
    have : Fintype.card (ZMod p) = p := ZMod.card p
    omega
  have hmem : t ∈ mapSums f L := by rw [huniv]; exact Finset.mem_univ t
  exact (mem_mapSums_iff f L t).1 hmem

end SubsetSums

/-! ### Cross sums of commuting lists -/

lemma crossSum_append (L M : List (Heis p)) :
    crossSum (L ++ M) = crossSum L + crossSum M + asum L * bsum M := by
  induction L with
  | nil => simp
  | cons g L ih =>
      simp only [List.cons_append, crossSum_cons, ih, bsum_append, asum_cons]
      ring

/-- If `g` commutes with every entry of `L`, then `g.a * bsum L = asum L * g.b`. -/
lemma mul_bsum_eq_asum_mul {g : Heis p} {L : List (Heis p)}
    (h : ∀ x ∈ L, g.a * x.b = x.a * g.b) : g.a * bsum L = asum L * g.b := by
  induction L with
  | nil => simp
  | cons y M ih =>
      have hy : g.a * y.b = y.a * g.b := h y (by simp)
      have hM : ∀ x ∈ M, g.a * x.b = x.a * g.b := fun x hx => h x (by simp [hx])
      simp only [asum_cons, bsum_cons, mul_add, add_mul, hy, ih hM]

/-- For a list of pairwise commuting elements, twice the cross sum is a
permutation invariant expression. -/
lemma two_mul_crossSum_of_pairwise_comm {L : List (Heis p)}
    (h : ∀ g ∈ L, ∀ h' ∈ L, g.a * h'.b = h'.a * g.b) :
    2 * crossSum L = asum L * bsum L - (L.map fun g => g.a * g.b).sum := by
  induction L with
  | nil => simp
  | cons g L ih =>
      have hL : ∀ x ∈ L, ∀ y ∈ L, x.a * y.b = y.a * x.b := fun x hx y hy =>
        h x (by simp [hx]) y (by simp [hy])
      have hgL : ∀ x ∈ L, g.a * x.b = x.a * g.b := fun x hx =>
        h g (by simp) x (by simp [hx])
      have hsum : g.a * bsum L = asum L * g.b := mul_bsum_eq_asum_mul hgL
      simp only [crossSum_cons, asum_cons, bsum_cons, List.map_cons, List.sum_cons]
      rw [mul_add, ih hL]
      linear_combination hsum

/-- Cross sums of pairwise commuting lists are permutation invariant (only
`2 ≠ 0` in `ZMod p` is used, so `p` is assumed odd). -/
lemma crossSum_perm_of_pairwise_comm (hodd : Odd p) [Fact p.Prime] {L M : List (Heis p)}
    (h : ∀ g ∈ L, ∀ h' ∈ L, g.a * h'.b = h'.a * g.b) (hperm : L.Perm M) :
    crossSum L = crossSum M := by
  have h' : ∀ g ∈ M, ∀ h'' ∈ M, g.a * h''.b = h''.a * g.b := by
    intro g hg h'' hh''
    exact h g (hperm.mem_iff.2 hg) h'' (hperm.mem_iff.2 hh'')
  have h2 : (2 : ZMod p) ≠ 0 := two_ne_zero_of_odd hodd
  have e1 := two_mul_crossSum_of_pairwise_comm h
  have e2 := two_mul_crossSum_of_pairwise_comm h'
  have hA : asum L = asum M := asum_perm hperm
  have hB : bsum L = bsum M := bsum_perm hperm
  have hC : (L.map fun g => g.a * g.b).sum = (M.map fun g => g.a * g.b).sum :=
    (hperm.map _).sum_eq
  have hkey : (2 : ZMod p) * crossSum L = 2 * crossSum M := by rw [e1, e2, hA, hB, hC]
  exact mul_left_cancel₀ h2 hkey

/-! ### The parallel spread criterion -/

/-- The central correction produced by moving `g` past `z`. -/
def twist (z g : Heis p) : ZMod p := g.a * z.b - z.a * g.b

lemma sum_map_twist (z : Heis p) (K : List (Heis p)) :
    (K.map (twist z)).sum = asum K * z.b - z.a * bsum K := by
  induction K with
  | nil => simp
  | cons g K ih =>
      simp only [List.map_cons, List.sum_cons, ih, twist, asum_cons, bsum_cons]
      ring

section Criterion

variable [Fact p.Prime]

/-- **Parallel spread criterion.**  If a sequence over `Heis p` with vanishing
image in `(ZMod p)²` contains `p - 1` pairwise commuting elements, none of
which commutes with a further element `z` of the sequence, then some ordering
of the sequence has product `1`. -/
theorem isProductOne_of_parallel_spread (hodd : Odd p) {G R : List (Heis p)} {z : Heis p}
    (hcomm : ∀ g ∈ G, ∀ h ∈ G, g.a * h.b = h.a * g.b)
    (htw : ∀ g ∈ G, twist z g ≠ 0)
    (hlen : p - 1 ≤ G.length)
    (ha : asum (G ++ z :: R) = 0) (hb : bsum (G ++ z :: R) = 0) :
    IsProductOne (G ++ z :: R) := by
  classical
  set T : List (Heis p) := G ++ z :: R with hT
  set C1 : ZMod p :=
    crossSum G + crossSum R + z.a * bsum R + asum G * bsum R + asum G * z.b with hC1
  obtain ⟨K, hKsub, hKsum⟩ :=
    exists_sublist_map_sum_eq (twist z) G htw hlen (C1 + csum T)
  obtain ⟨J, hJ⟩ := hKsub.exists_perm_append
  set M : List (Heis p) := J ++ z :: (K ++ R) with hM
  have hGperm : G.Perm (J ++ K) := hJ.trans List.perm_append_comm
  have hMT : M.Perm T := by
    have heq : J ++ (K ++ R) = J ++ K ++ R := (List.append_assoc J K R).symm
    have h1 : M.Perm (z :: (J ++ (K ++ R))) := by
      rw [hM]; exact List.perm_middle
    rw [heq] at h1
    have h2 : ((J ++ K) ++ z :: R).Perm (z :: ((J ++ K) ++ R)) := List.perm_middle
    have h3 : M.Perm ((J ++ K) ++ z :: R) := h1.trans h2.symm
    refine h3.trans ?_
    rw [hT]
    exact (hGperm.symm).append_right _
  refine ⟨M, hMT, ?_⟩
  have hcommJK : ∀ g ∈ J ++ K, ∀ h ∈ J ++ K, g.a * h.b = h.a * g.b := by
    intro g hg h hh
    exact hcomm g (hGperm.mem_iff.2 hg) h (hGperm.mem_iff.2 hh)
  have hcsG : crossSum (J ++ K) = crossSum G :=
    (crossSum_perm_of_pairwise_comm hodd hcommJK hGperm.symm)
  have hcsJK : crossSum J + crossSum K + asum J * bsum K = crossSum G := by
    rw [← hcsG, crossSum_append]
  have haJK : asum J + asum K = asum G := by
    rw [← asum_append]; exact (asum_perm hGperm).symm
  have hcross : crossSum M = C1 - (K.map (twist z)).sum := by
    rw [hM, crossSum_append]
    simp only [crossSum_cons, crossSum_append, bsum_append, bsum_cons]
    rw [sum_map_twist, hC1, ← hcsJK, ← haJK]
    ring
  have hasumM : asum M = 0 := by rw [asum_perm hMT]; exact ha
  have hbsumM : bsum M = 0 := by rw [bsum_perm hMT]; exact hb
  have hcsumM : csum M = csum T := csum_perm hMT
  rw [prod_eq_one_iff]
  refine ⟨hasumM, hbsumM, ?_⟩
  rw [hcsumM, hcross, hKsum]
  ring

/-- Contrapositive form of the spread criterion: a product-one-free sequence
contains no such configuration. -/
theorem not_parallel_spread_of_productOneFree (hodd : Odd p) {L G R : List (Heis p)}
    {z : Heis p} (hfree : ProductOneFree L) (hsub : (G ++ z :: R).Subperm L)
    (hcomm : ∀ g ∈ G, ∀ h ∈ G, g.a * h.b = h.a * g.b)
    (htw : ∀ g ∈ G, twist z g ≠ 0)
    (hlen : p - 1 ≤ G.length)
    (ha : asum (G ++ z :: R) = 0) (hb : bsum (G ++ z :: R) = 0) : False :=
  ProductOneFree.subperm hfree hsub (by simp)
    (isProductOne_of_parallel_spread hodd hcomm htw hlen ha hb)

end Criterion

end Heis

end Heisenberg125