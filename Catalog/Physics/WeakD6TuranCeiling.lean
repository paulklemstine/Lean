import Physics.WeakD6Core
import Physics.WeakD6Maximality

/-!
# A Turán ceiling for four-layer weakly `D₆`-free families

`Physics.WeakD6Maximality` shows that four consecutive full layers always contain
a weak `D₆`, so a four-layer construction has to delete sets from the interior.
This file quantifies *how much* has to go, by a genuinely cross-domain argument:
**extremal graph theory inside the Boolean lattice**.

For a `k`-set `A`, the *link graph* of a family `F` at `A` has vertex set
`[n] \ A` and an edge `{x, y}` whenever `A ∪ {x, y} ∈ F`.  If `F` contains the
layers `k+1` and `k+3` in full and is weakly `D₆`-free, then every link graph is
**triangle-free** (`WeakD6.linkPairs_triangle_free`): a triangle over `A` would
complete an entire distance-`3` interval.  Mantel's theorem (obtained from
Mathlib's Turán bound) then caps each link graph by `(n-k)²/4`
(`WeakD6.card_linkPairs_le`), and a double count over all `A` in layer `k` yields

`4 · C(k+2,2) · |F ∩ layer(k+2)| ≤ C(n,k) · (n-k)²`  (`WeakD6.middleLayer_ceiling`).

For the balanced choice `k ≈ (n-3)/2` the right-hand side is `≈ (n²/16)·C(n,k)`
while `C(k+2,2) ≈ n²/8`, so at most about **half** of the interior layer can be
kept, i.e. such constructions cannot exceed `≈ 3.5 · C(n, ⌊n/2⌋)`
(`WeakD6.fourLayer_total_ceiling`).  Together with `Physics.WeakD6AbelianNoGo`
(no abelian sum-labelling can gain a constant at all) this pins the search for a
constant `c > 3` into a narrow corridor.
-/

namespace WeakD6

open Finset
open scoped Classical

noncomputable section

/-- **Mantel's theorem, pair-set form.**  A triangle-free family `Q` of
`2`-element subsets of `W` has at most `|W|²/4` members. -/
lemma mantel_pairs (W : Finset ℕ) (Q : Finset (Finset ℕ))
    (hQ : ∀ D ∈ Q, D ⊆ W ∧ D.card = 2)
    (htri : ∀ x y z : ℕ, x ≠ y → x ≠ z → y ≠ z →
      ¬(({x, y} : Finset ℕ) ∈ Q ∧ ({x, z} : Finset ℕ) ∈ Q ∧ ({y, z} : Finset ℕ) ∈ Q)) :
    4 * Q.card ≤ W.card ^ 2 := by
  set G : SimpleGraph {x // x ∈ W} :=
    { Adj := fun a b => a ≠ b ∧ ({a.1, b.1} : Finset ℕ) ∈ Q
      symm := by
        rintro a b ⟨hab, hQab⟩
        exact ⟨hab.symm, by rwa [Finset.pair_comm]⟩
      loopless := ⟨fun a h => h.1 rfl⟩ } with hG
  have hcf : G.CliqueFree 3 := by
    intro t ht
    rw [SimpleGraph.is3Clique_iff] at ht
    obtain ⟨a, b, c, hab, hac, hbc, -⟩ := ht
    refine htri a.1 b.1 c.1 ?_ ?_ ?_ ⟨hab.2, hac.2, hbc.2⟩
    · exact fun h => hab.1 (Subtype.ext h)
    · exact fun h => hac.1 (Subtype.ext h)
    · exact fun h => hbc.1 (Subtype.ext h)
  have hcard : Fintype.card {x // x ∈ W} = W.card := Fintype.card_coe W
  have hedge := hcf.card_edgeFinset_le (r := 2)
  simp only [hcard] at hedge
  have hsurj : Q.card ≤ G.edgeFinset.card := by
    refine Finset.card_le_card_of_surjOn
      (Sym2.lift ⟨fun a b => ({a.1, b.1} : Finset ℕ),
        by intro a b; exact Finset.pair_comm (a : ℕ) (b : ℕ)⟩) ?_
    intro D hD
    simp only [Set.mem_image, Finset.mem_coe] at hD ⊢
    obtain ⟨hDW, hDcard⟩ := hQ D hD
    obtain ⟨a, b, hab, rfl⟩ := Finset.card_eq_two.1 hDcard
    have ha : a ∈ W := hDW (by simp)
    have hb : b ∈ W := hDW (by simp)
    refine ⟨s(⟨a, ha⟩, ⟨b, hb⟩), ?_, ?_⟩
    · simp only [SimpleGraph.mem_edgeFinset, SimpleGraph.mem_edgeSet]
      exact ⟨fun h => hab (congrArg Subtype.val h), hD⟩
    · simp
  have h2 : G.edgeFinset.card ≤ W.card ^ 2 / 4 := by
    refine le_trans hedge ?_
    have hz : (W.card % 2).choose 2 = 0 := by
      rcases Nat.mod_two_eq_zero_or_one W.card with h | h <;> simp [h]
    rw [hz, add_zero]
    have hle : (W.card ^ 2 - (W.card % 2) ^ 2) * (2 - 1) ≤ W.card ^ 2 := by simp
    exact Nat.div_le_div_right hle
  have := Nat.div_mul_le_self (W.card ^ 2) 4
  omega

/-- A two-element subset of a three-element set is one of its three pairs. -/
lemma pair_subset_triple {D : Finset ℕ} {x y z : ℕ} (hD : D ⊆ ({x, y, z} : Finset ℕ))
    (hcard : D.card = 2) :
    D = ({x, y} : Finset ℕ) ∨ D = ({x, z} : Finset ℕ) ∨ D = ({y, z} : Finset ℕ) := by
  obtain ⟨a, b, hab, rfl⟩ := Finset.card_eq_two.1 hcard
  have ha : a ∈ ({x, y, z} : Finset ℕ) := hD (by simp)
  have hb : b ∈ ({x, y, z} : Finset ℕ) := hD (by simp)
  simp only [Finset.mem_insert, Finset.mem_singleton] at ha hb
  rcases ha with rfl | rfl | rfl <;> rcases hb with rfl | rfl | rfl <;>
    simp_all [Finset.pair_comm]

/-- The link graph of `F` at `A`, recorded as the set of kept pairs. -/
def linkPairs (n : ℕ) (F : Finset (Finset ℕ)) (A : Finset ℕ) : Finset (Finset ℕ) :=
  ((Finset.range n \ A).powersetCard 2).filter (fun D => A ∪ D ∈ F)

lemma mem_linkPairs {n : ℕ} {F : Finset (Finset ℕ)} {A D : Finset ℕ} :
    D ∈ linkPairs n F A ↔ (D ⊆ Finset.range n \ A ∧ D.card = 2) ∧ A ∪ D ∈ F := by
  simp [linkPairs, Finset.mem_powersetCard]

/-- **Link graphs of a weakly `D₆`-free family are triangle-free.**  If `F`
contains the layers `k+1` and `k+3` in full, a triangle in the link graph at a
`k`-set `A ∈ F` would fill an entire distance-`3` interval. -/
lemma linkPairs_triangle_free (n k : ℕ) (F : Finset (Finset ℕ))
    (hL1 : layer n (k + 1) ⊆ F) (hL3 : layer n (k + 3) ⊆ F)
    (hfree : WeaklyDiamondFree 6 F) {A : Finset ℕ} (hA : A ∈ layer n k) (hAF : A ∈ F)
    (x y z : ℕ) (hxy : x ≠ y) (hxz : x ≠ z) (hyz : y ≠ z) :
    ¬(({x, y} : Finset ℕ) ∈ linkPairs n F A ∧ ({x, z} : Finset ℕ) ∈ linkPairs n F A ∧
      ({y, z} : Finset ℕ) ∈ linkPairs n F A) := by
  rintro ⟨h1, h2, h3⟩
  rw [mem_linkPairs] at h1 h2 h3
  rw [mem_layer] at hA
  -- the three points lie outside `A` and inside `[n]`
  have hx : x ∈ Finset.range n \ A := h1.1.1 (by simp)
  have hy : y ∈ Finset.range n \ A := h1.1.1 (by simp)
  have hz : z ∈ Finset.range n \ A := h2.1.1 (by simp)
  have hdisj : Disjoint A ({x, y, z} : Finset ℕ) := by
    refine Finset.disjoint_left.2 ?_
    intro a haA ha3
    simp only [Finset.mem_insert, Finset.mem_singleton] at ha3
    rcases ha3 with rfl | rfl | rfl
    · exact (Finset.mem_sdiff.1 hx).2 haA
    · exact (Finset.mem_sdiff.1 hy).2 haA
    · exact (Finset.mem_sdiff.1 hz).2 haA
  have h3card : ({x, y, z} : Finset ℕ).card = 3 := by
    rw [Finset.card_insert_of_notMem (by simp [hxy, hxz]),
      Finset.card_insert_of_notMem (by simp [hyz]), Finset.card_singleton]
  set C : Finset ℕ := A ∪ ({x, y, z} : Finset ℕ) with hC
  have hCcard : C.card = k + 3 := by
    rw [hC, Finset.card_union_of_disjoint hdisj, hA.2, h3card]
  have hCsub : C ⊆ Finset.range n := by
    refine Finset.union_subset hA.1 ?_
    intro a ha
    simp only [Finset.mem_insert, Finset.mem_singleton] at ha
    rcases ha with rfl | rfl | rfl
    · exact (Finset.mem_sdiff.1 hx).1
    · exact (Finset.mem_sdiff.1 hy).1
    · exact (Finset.mem_sdiff.1 hz).1
  have hCF : C ∈ F := hL3 (mem_layer.2 ⟨hCsub, hCcard⟩)
  refine not_weaklyD6Free_of_interval_subset hAF hCF Finset.subset_union_left
    (by omega) ?_ hfree
  intro B hB
  rw [mem_openInterval] at hB
  obtain ⟨hAB, hBC⟩ := hB
  have hBsub : B ⊆ Finset.range n := hBC.1.trans hCsub
  have hBcard : A.card < B.card ∧ B.card < C.card :=
    ⟨Finset.card_lt_card hAB, Finset.card_lt_card hBC⟩
  have hBA : B \ A ⊆ ({x, y, z} : Finset ℕ) := by
    intro a ha
    obtain ⟨haB, haA⟩ := Finset.mem_sdiff.1 ha
    rcases Finset.mem_union.1 (hBC.1 haB) with h | h
    · exact absurd h haA
    · exact h
  have hBeq : A ∪ (B \ A) = B := Finset.union_sdiff_of_subset hAB.1
  have hBAcard : (B \ A).card = B.card - A.card := Finset.card_sdiff_of_subset hAB.1
  rcases (show B.card = k + 1 ∨ B.card = k + 2 by omega) with hb | hb
  · exact hL1 (mem_layer.2 ⟨hBsub, hb⟩)
  · have hpair : (B \ A).card = 2 := by omega
    rcases pair_subset_triple hBA hpair with h | h | h
    · rw [← hBeq, h]; exact h1.2
    · rw [← hBeq, h]; exact h2.2
    · rw [← hBeq, h]; exact h3.2

/-- **Mantel bound for the link graph.** -/
lemma card_linkPairs_le (n k : ℕ) (F : Finset (Finset ℕ))
    (hL1 : layer n (k + 1) ⊆ F) (hL3 : layer n (k + 3) ⊆ F)
    (hfree : WeaklyDiamondFree 6 F) {A : Finset ℕ} (hA : A ∈ layer n k) (hAF : A ∈ F) :
    4 * (linkPairs n F A).card ≤ (n - k) ^ 2 := by
  have hAmem := mem_layer.1 hA
  have hW : (Finset.range n \ A).card = n - k := by
    rw [Finset.card_sdiff_of_subset hAmem.1, hAmem.2, Finset.card_range]
  have := mantel_pairs (Finset.range n \ A) (linkPairs n F A)
    (fun D hD => ⟨(mem_linkPairs.1 hD).1.1, (mem_linkPairs.1 hD).1.2⟩)
    (linkPairs_triangle_free n k F hL1 hL3 hfree hA hAF)
  rwa [hW] at this

/-- Kept pairs over `A` correspond to kept `(k+2)`-sets above `A`. -/
lemma card_linkPairs_eq (n k : ℕ) (F : Finset (Finset ℕ)) {A : Finset ℕ} (hA : A ∈ layer n k) :
    (linkPairs n F A).card
      = ((F ∩ layer n (k + 2)).filter (fun S => A ⊆ S)).card := by
  obtain ⟨hAsub, hAcard⟩ := mem_layer.1 hA
  refine Finset.card_bij' (fun D _ => A ∪ D) (fun S _ => S \ A) ?_ ?_ ?_ ?_
  · intro D hD
    rw [mem_linkPairs] at hD
    obtain ⟨⟨hDsub, hDcard⟩, hDF⟩ := hD
    have hdisj : Disjoint A D :=
      Finset.disjoint_left.2 fun a ha haD => (Finset.mem_sdiff.1 (hDsub haD)).2 ha
    refine Finset.mem_filter.2 ⟨Finset.mem_inter.2 ⟨hDF, mem_layer.2 ⟨?_, ?_⟩⟩,
      Finset.subset_union_left⟩
    · exact Finset.union_subset hAsub (hDsub.trans Finset.sdiff_subset)
    · rw [Finset.card_union_of_disjoint hdisj, hAcard, hDcard]
  · intro S hS
    rw [Finset.mem_filter, Finset.mem_inter, mem_layer] at hS
    obtain ⟨⟨hSF, hSsub, hScard⟩, hAS⟩ := hS
    refine mem_linkPairs.2 ⟨⟨?_, ?_⟩, ?_⟩
    · intro a ha
      obtain ⟨haS, haA⟩ := Finset.mem_sdiff.1 ha
      exact Finset.mem_sdiff.2 ⟨hSsub haS, haA⟩
    · rw [Finset.card_sdiff_of_subset hAS, hScard, hAcard]; omega
    · rwa [Finset.union_sdiff_of_subset hAS]
  · intro D hD
    rw [mem_linkPairs] at hD
    have hdisj : Disjoint A D :=
      Finset.disjoint_left.2 fun a ha haD => (Finset.mem_sdiff.1 (hD.1.1 haD)).2 ha
    exact Finset.union_sdiff_cancel_left hdisj
  · intro S hS
    rw [Finset.mem_filter] at hS
    exact Finset.union_sdiff_of_subset hS.2

/-- Double counting containments between layer `k` and the kept part of layer `k+2`. -/
lemma sum_card_above (n k : ℕ) (G : Finset (Finset ℕ))
    (hG : ∀ S ∈ G, S ⊆ Finset.range n ∧ S.card = k + 2) :
    ∑ A ∈ layer n k, (G.filter (fun S => A ⊆ S)).card = G.card * (k + 2).choose k := by
  have h1 : ∀ A : Finset ℕ, (G.filter (fun S => A ⊆ S)).card
      = ∑ S ∈ G, if A ⊆ S then 1 else 0 := by
    intro A; rw [Finset.card_filter]
  simp_rw [h1]
  rw [Finset.sum_comm]
  have h2 : ∀ S ∈ G, (∑ A ∈ layer n k, if A ⊆ S then 1 else 0) = (k + 2).choose k := by
    intro S hS
    obtain ⟨hSsub, hScard⟩ := hG S hS
    rw [← Finset.card_filter]
    have hfilter : (layer n k).filter (fun A => A ⊆ S) = S.powersetCard k := by
      ext A
      simp only [Finset.mem_filter, mem_layer, Finset.mem_powersetCard]
      constructor
      · rintro ⟨⟨-, hc⟩, hAS⟩; exact ⟨hAS, hc⟩
      · rintro ⟨hAS, hc⟩; exact ⟨⟨hAS.trans hSsub, hc⟩, hAS⟩
    rw [hfilter, Finset.card_powersetCard, hScard]
  rw [Finset.sum_congr rfl h2, Finset.sum_const, smul_eq_mul]

/-- **The trade-off ceiling.**  Without assuming that layer `k` is kept in full,
double counting containments between the kept parts of layers `k` and `k+2`
still yields a Mantel-type inequality: the number of (bottom, interior)
incidences is at most `|F ∩ layer k| · (n-k)² / 4`. -/
theorem linkCount_ceiling (n k : ℕ) (F : Finset (Finset ℕ))
    (hL1 : layer n (k + 1) ⊆ F) (hL3 : layer n (k + 3) ⊆ F)
    (hfree : WeaklyDiamondFree 6 F) :
    4 * ∑ S ∈ F ∩ layer n (k + 2), ((F ∩ layer n k).filter (fun A => A ⊆ S)).card
      ≤ (F ∩ layer n k).card * (n - k) ^ 2 := by
  have hcomm : ∑ S ∈ F ∩ layer n (k + 2), ((F ∩ layer n k).filter (fun A => A ⊆ S)).card
      = ∑ A ∈ F ∩ layer n k, ((F ∩ layer n (k + 2)).filter (fun S => A ⊆ S)).card := by
    simp_rw [Finset.card_filter]
    rw [Finset.sum_comm]
  rw [hcomm, Finset.mul_sum]
  calc ∑ A ∈ F ∩ layer n k, 4 * ((F ∩ layer n (k + 2)).filter (fun S => A ⊆ S)).card
      ≤ ∑ _A ∈ F ∩ layer n k, (n - k) ^ 2 := by
        refine Finset.sum_le_sum ?_
        intro A hA
        obtain ⟨hAF, hAlayer⟩ := Finset.mem_inter.1 hA
        rw [← card_linkPairs_eq n k F hAlayer]
        exact card_linkPairs_le n k F hL1 hL3 hfree hAlayer hAF
    _ = (F ∩ layer n k).card * (n - k) ^ 2 := by rw [Finset.sum_const, smul_eq_mul]

/-- **The Turán ceiling.**  If a weakly `D₆`-free family `F` contains the layers
`k`, `k+1` and `k+3` of `2^[n]` in full, then its intersection with the interior
layer `k+2` obeys `4·C(k+2,2)·|F ∩ layer(k+2)| ≤ C(n,k)·(n-k)²`.  For the
balanced choice `k ≈ (n-3)/2` this keeps at most about half of that layer. -/
theorem middleLayer_ceiling (n k : ℕ) (F : Finset (Finset ℕ))
    (hL0 : layer n k ⊆ F) (hL1 : layer n (k + 1) ⊆ F) (hL3 : layer n (k + 3) ⊆ F)
    (hfree : WeaklyDiamondFree 6 F) :
    4 * ((k + 2).choose k) * (F ∩ layer n (k + 2)).card ≤ n.choose k * (n - k) ^ 2 := by
  set G : Finset (Finset ℕ) := F ∩ layer n (k + 2) with hGdef
  have hG : ∀ S ∈ G, S ⊆ Finset.range n ∧ S.card = k + 2 := by
    intro S hS
    exact mem_layer.1 (Finset.mem_inter.1 hS).2
  have hsum : ∑ A ∈ layer n k, 4 * (linkPairs n F A).card ≤ ∑ _A ∈ layer n k, (n - k) ^ 2 :=
    Finset.sum_le_sum fun A hA => card_linkPairs_le n k F hL1 hL3 hfree hA (hL0 hA)
  have hleft : ∑ A ∈ layer n k, 4 * (linkPairs n F A).card
      = 4 * (G.card * (k + 2).choose k) := by
    rw [← Finset.mul_sum]
    congr 1
    rw [← sum_card_above n k G hG]
    exact Finset.sum_congr rfl fun A hA => card_linkPairs_eq n k F hA
  have hright : ∑ _A ∈ layer n k, (n - k) ^ 2 = n.choose k * (n - k) ^ 2 := by
    rw [Finset.sum_const, smul_eq_mul, card_layer]
  rw [hleft, hright] at hsum
  calc 4 * ((k + 2).choose k) * G.card = 4 * (G.card * (k + 2).choose k) := by ring
    _ ≤ n.choose k * (n - k) ^ 2 := hsum

/-- **Total ceiling for four-layer constructions.**  A weakly `D₆`-free family
inside the four-layer window that keeps the layers `k`, `k+1`, `k+3` in full has
size bounded by three full layers plus the Turán-limited interior. -/
theorem fourLayer_total_ceiling (n k : ℕ) (F : Finset (Finset ℕ))
    (hFsub : ∀ S ∈ F, S ⊆ Finset.range n ∧ k ≤ S.card ∧ S.card ≤ k + 3)
    (hL0 : layer n k ⊆ F) (hL1 : layer n (k + 1) ⊆ F) (hL3 : layer n (k + 3) ⊆ F)
    (hfree : WeaklyDiamondFree 6 F) :
    4 * ((k + 2).choose k) * F.card ≤
      4 * ((k + 2).choose k) * (n.choose k + n.choose (k + 1) + n.choose (k + 3)) +
        n.choose k * (n - k) ^ 2 := by
  have hsplit : F ⊆ layer n k ∪ layer n (k + 1) ∪ (F ∩ layer n (k + 2)) ∪ layer n (k + 3) := by
    intro S hS
    obtain ⟨hSsub, hlow, hhigh⟩ := hFsub S hS
    rcases (show S.card = k ∨ S.card = k + 1 ∨ S.card = k + 2 ∨ S.card = k + 3 by omega)
      with h | h | h | h
    · exact Finset.mem_union_left _ (Finset.mem_union_left _
        (Finset.mem_union_left _ (mem_layer.2 ⟨hSsub, h⟩)))
    · exact Finset.mem_union_left _ (Finset.mem_union_left _
        (Finset.mem_union_right _ (mem_layer.2 ⟨hSsub, h⟩)))
    · exact Finset.mem_union_left _ (Finset.mem_union_right _
        (Finset.mem_inter.2 ⟨hS, mem_layer.2 ⟨hSsub, h⟩⟩))
    · exact Finset.mem_union_right _ (mem_layer.2 ⟨hSsub, h⟩)
  have hcard : F.card ≤ (layer n k).card + (layer n (k + 1)).card +
      (F ∩ layer n (k + 2)).card + (layer n (k + 3)).card := by
    refine le_trans (Finset.card_le_card hsplit) ?_
    have h1 := Finset.card_union_le (layer n k ∪ layer n (k + 1) ∪ (F ∩ layer n (k + 2)))
      (layer n (k + 3))
    have h2 := Finset.card_union_le (layer n k ∪ layer n (k + 1)) (F ∩ layer n (k + 2))
    have h3 := Finset.card_union_le (layer n k) (layer n (k + 1))
    omega
  have hmid := middleLayer_ceiling n k F hL0 hL1 hL3 hfree
  have hL : (layer n k).card = n.choose k := card_layer n k
  have hL' : (layer n (k + 1)).card = n.choose (k + 1) := card_layer n (k + 1)
  have hL'' : (layer n (k + 3)).card = n.choose (k + 3) := card_layer n (k + 3)
  calc 4 * ((k + 2).choose k) * F.card
      ≤ 4 * ((k + 2).choose k) *
          (n.choose k + n.choose (k + 1) + (F ∩ layer n (k + 2)).card + n.choose (k + 3)) := by
        refine Nat.mul_le_mul_left _ ?_
        omega
    _ = 4 * ((k + 2).choose k) * (n.choose k + n.choose (k + 1) + n.choose (k + 3)) +
          4 * ((k + 2).choose k) * (F ∩ layer n (k + 2)).card := by ring
    _ ≤ 4 * ((k + 2).choose k) * (n.choose k + n.choose (k + 1) + n.choose (k + 3)) +
          n.choose k * (n - k) ^ 2 := by omega

end

end WeakD6