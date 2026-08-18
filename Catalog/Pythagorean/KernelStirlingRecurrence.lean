import Pythagorean.KernelBlockCount

/-!
# The Stirling recursion for kernel patterns

`KernelPattern.stirling2 n k` counts the kernel patterns of length `n` with exactly `k`
blocks.  Here we prove the classical recursion

`stirling2 (n+1) (k+1) = stirling2 n k + (k+1) * stirling2 n (k+1)`,

by splitting the patterns of length `n + 1` according to whether the last coordinate forms a
block of its own or joins one of the existing blocks.  The two directions of the split are
implemented by `KernelPattern.restrictPattern` (delete the last coordinate) and
`KernelPattern.attachLast` (append a coordinate pointing at a prescribed block label).

Together with the boundary values in `Pythagorean.KernelBlockCount` this determines the
whole Stirling triangle, and hence (via `sum_stirling2_eq_bell`) the Bell numbers.
-/

open Finset

namespace KernelPattern

variable {n k : ℕ}

/-! ## Deleting and appending a coordinate -/

/-- Delete the last coordinate of a pattern of length `n + 1`. -/
def restrictPattern (p : Fin (n + 1) → Fin (n + 1)) (i : Fin n) : Fin n :=
  if h : (p i.castSucc).val < n then ⟨(p i.castSucc).val, h⟩ else i

/-- Append a coordinate to a pattern of length `n`, pointing at the label `b`. -/
def attachLast (q : Fin n → Fin n) (b : Fin (n + 1)) : Fin (n + 1) → Fin (n + 1) := fun i =>
  if h : i.val < n then (q ⟨i.val, h⟩).castSucc else b

@[simp] theorem attachLast_castSucc (q : Fin n → Fin n) (b : Fin (n + 1)) (a : Fin n) :
    attachLast q b a.castSucc = (q a).castSucc := by
  simp [attachLast, Fin.castSucc, Fin.is_lt]

@[simp] theorem attachLast_last (q : Fin n → Fin n) (b : Fin (n + 1)) :
    attachLast q b (Fin.last n) = b := by
  simp [attachLast]

theorem pattern_apply_lt {p : Fin (n + 1) → Fin (n + 1)} (hp : p ∈ Patterns (n + 1))
    (i : Fin n) : (p i.castSucc).val < n := by
  have h := canon_le_self p i.castSucc
  rw [mem_patterns_iff.1 hp] at h
  have : (p i.castSucc).val ≤ (i.castSucc).val := h
  simpa [Fin.castSucc, Fin.val_castAdd] using lt_of_le_of_lt this i.is_lt

theorem castSucc_restrictPattern {p : Fin (n + 1) → Fin (n + 1)} (hp : p ∈ Patterns (n + 1))
    (i : Fin n) : (restrictPattern p i).castSucc = p i.castSucc := by
  have h := pattern_apply_lt hp i
  simp only [restrictPattern, h, dif_pos]
  exact Fin.ext (by simp)

theorem restrictPattern_attachLast (q : Fin n → Fin n) (b : Fin (n + 1)) :
    restrictPattern (attachLast q b) = q := by
  funext i
  have h : ((attachLast q b) i.castSucc).val < n := by
    rw [attachLast_castSucc]
    simp
  simp only [restrictPattern, h, dif_pos]
  exact Fin.ext (by simp)

theorem attachLast_restrictPattern {p : Fin (n + 1) → Fin (n + 1)} (hp : p ∈ Patterns (n + 1)) :
    attachLast (restrictPattern p) (p (Fin.last n)) = p := by
  funext i
  rcases Fin.eq_castSucc_or_eq_last i with ⟨a, rfl⟩ | rfl
  · rw [attachLast_castSucc, castSucc_restrictPattern hp]
  · rw [attachLast_last]

/-! ## Images and block counts -/

theorem image_attachLast (q : Fin n → Fin n) (b : Fin (n + 1)) :
    univ.image (attachLast q b) = insert b ((univ.image q).image Fin.castSucc) := by
  ext x
  simp only [Finset.mem_image, Finset.mem_univ, true_and, Finset.mem_insert]
  constructor
  · rintro ⟨i, rfl⟩
    rcases Fin.eq_castSucc_or_eq_last i with ⟨a, rfl⟩ | rfl
    · exact Or.inr ⟨q a, ⟨a, rfl⟩, by rw [attachLast_castSucc]⟩
    · exact Or.inl (by rw [attachLast_last])
  · rintro (rfl | ⟨y, ⟨a, rfl⟩, rfl⟩)
    · exact ⟨Fin.last n, by rw [attachLast_last]⟩
    · exact ⟨a.castSucc, by rw [attachLast_castSucc]⟩

theorem card_image_castSucc (q : Fin n → Fin n) :
    ((univ.image q).image Fin.castSucc).card = nblocks q := by
  rw [Finset.card_image_of_injective _ (Fin.castSucc_injective n), nblocks]

theorem nblocks_attachLast_last (q : Fin n → Fin n) :
    nblocks (attachLast q (Fin.last n)) = nblocks q + 1 := by
  rw [nblocks, image_attachLast, Finset.card_insert_of_notMem, card_image_castSucc]
  intro hmem
  obtain ⟨y, -, hy⟩ := Finset.mem_image.1 hmem
  exact absurd hy (Fin.castSucc_lt_last y).ne

theorem nblocks_attachLast_of_mem {q : Fin n → Fin n} {b : Fin (n + 1)}
    (hb : b ∈ (univ.image q).image Fin.castSucc) : nblocks (attachLast q b) = nblocks q := by
  rw [nblocks, image_attachLast, Finset.insert_eq_self.2 hb, card_image_castSucc]

/-! ## Canonicity -/

theorem restrictPattern_mem_patterns {p : Fin (n + 1) → Fin (n + 1)}
    (hp : p ∈ Patterns (n + 1)) : restrictPattern p ∈ Patterns n := by
  have hcan : canon p = p := mem_patterns_iff.1 hp
  rw [mem_patterns_iff]
  funext i
  refine canon_eq_iff_least.2 ⟨?_, ?_⟩
  · have h1 : (restrictPattern p i).castSucc = p i.castSucc := castSucc_restrictPattern hp i
    have h2 : p (p i.castSucc) = p i.castSucc := by
      have := canon_canon_apply p i.castSucc
      rwa [hcan] at this
    apply Fin.castSucc_injective n
    rw [castSucc_restrictPattern hp, h1, h2]
  · intro j hj
    have h1 : p j.castSucc = p i.castSucc := by
      rw [← castSucc_restrictPattern hp, ← castSucc_restrictPattern hp, hj]
    have h2 : canon p i.castSucc ≤ j.castSucc := canon_le h1
    rw [hcan] at h2
    have h3 : (p i.castSucc).val ≤ (j.castSucc).val := h2
    have h4 : (restrictPattern p i).val = (p i.castSucc).val := by
      have := castSucc_restrictPattern hp i
      simpa using congrArg Fin.val this
    have : (restrictPattern p i).val ≤ j.val := by
      simpa [Fin.castSucc, Fin.val_castAdd, h4] using h3
    exact this

theorem attachLast_mem_patterns {q : Fin n → Fin n} {b : Fin (n + 1)} (hq : q ∈ Patterns n)
    (hb : b = Fin.last n ∨ b ∈ (univ.image q).image Fin.castSucc) :
    attachLast q b ∈ Patterns (n + 1) := by
  have hcan : canon q = q := mem_patterns_iff.1 hq
  have hidem : ∀ a : Fin n, q (q a) = q a := by
    intro a
    have := canon_canon_apply q a
    rwa [hcan] at this
  have hmin : ∀ a d : Fin n, q d = q a → q a ≤ d := by
    intro a d h
    have := canon_le (f := q) h
    rwa [hcan] at this
  rw [mem_patterns_iff]
  funext i
  refine canon_eq_iff_least.2 ⟨?_, ?_⟩
  · rcases Fin.eq_castSucc_or_eq_last i with ⟨a, rfl⟩ | rfl
    · rw [attachLast_castSucc, attachLast_castSucc, hidem]
    · rw [attachLast_last]
      rcases hb with rfl | hb
      · rw [attachLast_last]
      · obtain ⟨y, hy, rfl⟩ := Finset.mem_image.1 hb
        obtain ⟨a, -, rfl⟩ := Finset.mem_image.1 hy
        rw [attachLast_castSucc, hidem]
  · intro j hj
    rcases Fin.eq_castSucc_or_eq_last i with ⟨a, rfl⟩ | rfl
    · rw [attachLast_castSucc] at hj ⊢
      rcases Fin.eq_castSucc_or_eq_last j with ⟨d, rfl⟩ | rfl
      · rw [attachLast_castSucc] at hj
        exact Fin.castSucc_le_castSucc_iff.2 (hmin a d (Fin.castSucc_injective n hj))
      · exact Fin.le_last _
    · rw [attachLast_last] at hj ⊢
      rcases hb with rfl | hb
      · rcases Fin.eq_castSucc_or_eq_last j with ⟨d, rfl⟩ | rfl
        · rw [attachLast_castSucc] at hj
          exact absurd hj (Fin.castSucc_lt_last (q d)).ne
        · exact le_refl _
      · obtain ⟨y, hy, hyb⟩ := Finset.mem_image.1 hb
        obtain ⟨a, -, rfl⟩ := Finset.mem_image.1 hy
        rcases Fin.eq_castSucc_or_eq_last j with ⟨d, rfl⟩ | rfl
        · rw [attachLast_castSucc] at hj
          rw [← hyb] at hj ⊢
          exact Fin.castSucc_le_castSucc_iff.2 (hmin a d (Fin.castSucc_injective n hj))
        · exact Fin.le_last _

/-! ## The two halves of the split -/

/-- Patterns of length `n` with exactly `k` blocks. -/
def PatK (n k : ℕ) : Finset (Fin n → Fin n) := (Patterns n).filter (fun p => nblocks p = k)

theorem stirling2_eq_card_patK (n k : ℕ) : stirling2 n k = (PatK n k).card := rfl

theorem mem_patK {n k : ℕ} {p : Fin n → Fin n} :
    p ∈ PatK n k ↔ p ∈ Patterns n ∧ nblocks p = k := Finset.mem_filter

/-- Patterns whose last coordinate is a singleton block correspond to patterns of length `n`
with one block fewer. -/
theorem card_filter_last_eq (n k : ℕ) :
    ((PatK (n + 1) (k + 1)).filter (fun p => p (Fin.last n) = Fin.last n)).card
      = stirling2 n k := by
  rw [stirling2_eq_card_patK]
  refine Finset.card_nbij' restrictPattern (fun q => attachLast q (Fin.last n)) ?_ ?_ ?_ ?_
  · intro p hp
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_patK] at hp
    obtain ⟨⟨hmem, hb⟩, hlast⟩ := hp
    refine Finset.mem_coe.2 (mem_patK.2 ⟨restrictPattern_mem_patterns hmem, ?_⟩)
    have hp' : attachLast (restrictPattern p) (Fin.last n) = p := by
      rw [← hlast]; exact attachLast_restrictPattern hmem
    have := nblocks_attachLast_last (restrictPattern p)
    rw [hp', hb] at this
    omega
  · intro q hq
    simp only [Finset.mem_coe, mem_patK] at hq
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_patK]
    refine ⟨⟨attachLast_mem_patterns hq.1 (Or.inl rfl), ?_⟩, by rw [attachLast_last]⟩
    rw [nblocks_attachLast_last, hq.2]
  · intro p hp
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_patK] at hp
    rw [← hp.2]
    exact attachLast_restrictPattern hp.1.1
  · intro q _
    exact restrictPattern_attachLast q (Fin.last n)

theorem last_mem_image {p : Fin (n + 1) → Fin (n + 1)} (hp : p ∈ Patterns (n + 1))
    (hlast : p (Fin.last n) ≠ Fin.last n) :
    p (Fin.last n) ∈ (univ.image (restrictPattern p)).image Fin.castSucc := by
  obtain ⟨c, hc⟩ : ∃ c : Fin n, p (Fin.last n) = c.castSucc := by
    rcases Fin.eq_castSucc_or_eq_last (p (Fin.last n)) with ⟨c, hc⟩ | hc
    · exact ⟨c, hc⟩
    · exact absurd hc hlast
  have hidem : p (p (Fin.last n)) = p (Fin.last n) := by
    have := canon_canon_apply p (Fin.last n)
    rwa [mem_patterns_iff.1 hp] at this
  have hcc : (restrictPattern p c).castSucc = c.castSucc := by
    rw [castSucc_restrictPattern hp, ← hc, hidem, hc]
  have : restrictPattern p c = c := Fin.castSucc_injective n hcc
  refine Finset.mem_image.2 ⟨c, ?_, hc.symm⟩
  exact Finset.mem_image.2 ⟨c, Finset.mem_univ c, this⟩

/-- Patterns whose last coordinate joins an existing block: there are `k+1` choices of the
block for each pattern of length `n` with `k+1` blocks. -/
theorem card_filter_last_ne (n k : ℕ) :
    ((PatK (n + 1) (k + 1)).filter (fun p => ¬ p (Fin.last n) = Fin.last n)).card
      = (k + 1) * stirling2 n (k + 1) := by
  classical
  have hmaps : ∀ p ∈ (PatK (n + 1) (k + 1)).filter (fun p => ¬ p (Fin.last n) = Fin.last n),
      restrictPattern p ∈ PatK n (k + 1) := by
    intro p hp
    simp only [Finset.mem_filter, mem_patK] at hp
    obtain ⟨⟨hmem, hb⟩, hlast⟩ := hp
    refine mem_patK.2 ⟨restrictPattern_mem_patterns hmem, ?_⟩
    have hb' : p (Fin.last n) ∈ (univ.image (restrictPattern p)).image Fin.castSucc :=
      last_mem_image hmem hlast
    have hp' : attachLast (restrictPattern p) (p (Fin.last n)) = p :=
      attachLast_restrictPattern hmem
    have := nblocks_attachLast_of_mem hb'
    rw [hp', hb] at this
    exact this.symm
  rw [Finset.card_eq_sum_card_fiberwise hmaps]
  have hfiber : ∀ q ∈ PatK n (k + 1),
      (((PatK (n + 1) (k + 1)).filter (fun p => ¬ p (Fin.last n) = Fin.last n)).filter
        (fun p => restrictPattern p = q)).card = k + 1 := by
    intro q hq
    rw [mem_patK] at hq
    have hcard : ((univ.image q).image Fin.castSucc).card = k + 1 := by
      rw [card_image_castSucc, hq.2]
    rw [← hcard]
    refine Finset.card_nbij' (fun p => p (Fin.last n)) (fun b => attachLast q b) ?_ ?_ ?_ ?_
    · intro p hp
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_filter, mem_patK] at hp
      obtain ⟨⟨⟨hmem, -⟩, hlast⟩, hrq⟩ := hp
      have := last_mem_image hmem hlast
      rwa [hrq] at this
    · intro b hb
      simp only [Finset.mem_coe] at hb
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_filter, mem_patK]
      refine ⟨⟨⟨attachLast_mem_patterns hq.1 (Or.inr hb), ?_⟩, ?_⟩, restrictPattern_attachLast q b⟩
      · rw [nblocks_attachLast_of_mem hb, hq.2]
        exact hcard.symm
      · rw [attachLast_last]
        obtain ⟨y, -, rfl⟩ := Finset.mem_image.1 hb
        exact (Fin.castSucc_lt_last y).ne
    · intro p hp
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_filter, mem_patK] at hp
      obtain ⟨⟨⟨hmem, -⟩, -⟩, hrq⟩ := hp
      rw [← hrq]
      exact attachLast_restrictPattern hmem
    · intro b _
      exact attachLast_last q b
  rw [Finset.sum_congr rfl hfiber, Finset.sum_const, smul_eq_mul, stirling2_eq_card_patK,
    mul_comm]

/-- **The Stirling recursion.** -/
theorem stirling2_succ_succ (n k : ℕ) :
    stirling2 (n + 1) (k + 1) = stirling2 n k + (k + 1) * stirling2 n (k + 1) := by
  classical
  rw [stirling2_eq_card_patK, ← Finset.card_filter_add_card_filter_not
    (s := PatK (n + 1) (k + 1)) (p := fun p => p (Fin.last n) = Fin.last n),
    card_filter_last_eq, card_filter_last_ne]

set_option maxRecDepth 40000 in
/-- Sanity check against the `decide`-verified table:
`stirling2 5 3 = stirling2 4 2 + 3 * stirling2 4 3 = 7 + 18 = 25`. -/
theorem stirling2_five_three : stirling2 5 3 = 25 := by
  have h := stirling2_succ_succ 4 2
  have h4 := stirling2_table_four
  simp only [Prod.mk.injEq] at h4
  rw [h4.2.2.1, h4.2.2.2.1] at h
  omega

end KernelPattern