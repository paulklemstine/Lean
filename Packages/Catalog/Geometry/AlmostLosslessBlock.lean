/-
# Beating the decoder-search barrier: the blocked (product) random code

Part of the research thread *Compression Beyond the Pigeonhole Bound*
(Phase B, Question 2: can random number generators help?).

The single-hash almost-lossless scheme of `Geometry.AlmostLosslessDecoder` has
optimal rate but its decoder scans the whole typical set: cost `|S|`, which is
*exponential* in the block length.  Here we remove that obstacle.

Split a string into `b` blocks over a block alphabet `β`, each block typical in
`T : Finset β`, so the global typical set is the product `T^b`, of size
`|T|^b`.  Draw one random codebook `H : Fin b × β → Fin M` and hash each block
*separately*.  Then:

* `AlmostLossless.blockDecode_cost` — the decoder costs exactly `b * |T|` hash
  comparisons, **linear** in the number of blocks, versus `|T| ^ b` for the flat
  scheme (`AlmostLossless.block_beats_flat`: `b * |T| < |T| ^ b`).
* `AlmostLossless.blockDecode_never_wrong` — no silent corruption survives the
  product construction: a decoded string is always the transmitted one.
* `AlmostLossless.blockFail_prob_le` / `AlmostLossless.blockDecode_success_prob_ge` —
  the price is only a union-bound factor `b` in the failure probability:
  `P[failure] ≤ b (|T| - 1) / M`.
-/
import Geometry.AlmostLosslessDecoder

namespace AlmostLossless

open Finset

variable {β : Type*} [Fintype β] [DecidableEq β] {b M : ℕ}

/-! ## 1. The blocked scheme -/

/-- The blocked encoder: hash each block with its own slice of the codebook. -/
def blockEncode (H : Fin b × β → Fin M) (x : Fin b → β) : Fin b → Fin M :=
  fun i => H (i, x i)

/-- The blocked decoder: run the scanning decoder of `AlmostLosslessDecoder`
independently on each block, and succeed only if *every* block decodes
unambiguously.  The second component is the total number of hash comparisons. -/
def blockDecode (LT : List β) (H : Fin b × β → Fin M) (c : Fin b → Fin M) :
    Option (Fin b → β) × ℕ :=
  (if h : ∀ i : Fin b, ((decode LT (fun y => H (i, y)) (c i)).1).isSome then
      some (fun i => ((decode LT (fun y => H (i, y)) (c i)).1).get (h i))
    else none,
   ∑ i : Fin b, (decode LT (fun y => H (i, y)) (c i)).2)

omit [Fintype β] [DecidableEq β] in
/-- **Exact decoding complexity of the blocked scheme**: `b * |T|` hash
comparisons. -/
theorem blockDecode_cost (LT : List β) (H : Fin b × β → Fin M) (c : Fin b → Fin M) :
    (blockDecode LT H c).2 = b * LT.length := by
  simp [blockDecode, decode_cost, Finset.sum_const, Finset.card_univ]

/-! ## 2. No silent corruption, blockwise -/

omit [Fintype β] [DecidableEq β] in
/-- If the blocked decoder outputs a string, every block decoded successfully. -/
theorem blockDecode_blocks {LT : List β} {H : Fin b × β → Fin M} {c : Fin b → Fin M}
    {z : Fin b → β} (h : (blockDecode LT H c).1 = some z) :
    ∀ i, (decode LT (fun y => H (i, y)) (c i)).1 = some (z i) := by
  simp only [blockDecode] at h
  by_cases hall : ∀ i : Fin b, ((decode LT (fun y => H (i, y)) (c i)).1).isSome
  · rw [dif_pos hall] at h
    have hz : (fun i => ((decode LT (fun y => H (i, y)) (c i)).1).get (hall i)) = z :=
      Option.some_injective _ h
    intro i
    rw [← hz]
    exact (Option.some_get (hall i)).symm
  · rw [dif_neg hall] at h
    exact absurd h (by simp)

omit [Fintype β] [DecidableEq β] in
/-- **No silent corruption for the product code.**  If every block of the
transmitted string is typical, then any output of the blocked decoder equals the
transmitted string exactly. -/
theorem blockDecode_never_wrong {LT : List β} {H : Fin b × β → Fin M}
    {x z : Fin b → β} (hx : ∀ i, x i ∈ LT)
    (h : (blockDecode LT H (blockEncode H x)).1 = some z) : z = x := by
  funext i
  have hi := blockDecode_blocks h i
  exact decode_never_wrong (hx i) hi

/-! ## 3. Success of the blocked decoder -/

/-- The blocked failure event: some block of `x` collides with another typical
block value under the corresponding slice of the codebook. -/
def blockFail (T : Finset β) (x : Fin b → β) (M : ℕ) : Finset (Fin b × β → Fin M) :=
  univ.filter (fun H => ∃ i : Fin b, ∃ y ∈ T.erase (x i), H (i, y) = H (i, x i))

/-- Off the blocked failure event, every block decodes correctly, hence the whole
string is recovered, at cost exactly `b * |T|`. -/
theorem blockDecode_success {T : Finset β} {LT : List β} {x : Fin b → β}
    {H : Fin b × β → Fin M} (hnd : LT.Nodup) (hmem : ∀ y, y ∈ LT ↔ y ∈ T)
    (hx : ∀ i, x i ∈ T) (hH : H ∉ blockFail T x M) :
    blockDecode LT H (blockEncode H x) = (some x, b * LT.length) := by
  have hblock : ∀ i : Fin b,
      decode LT (fun y => H (i, y)) (H (i, x i)) = (some (x i), LT.length) := by
    intro i
    refine decode_success_of_not_mem_failSet hnd hmem (hx i) ?_
    intro hmemf
    simp only [failSet, mem_filter, mem_univ, true_and] at hmemf
    obtain ⟨y, hy, hHy⟩ := hmemf
    exact hH (by
      simp only [blockFail, mem_filter, mem_univ, true_and]
      exact ⟨i, y, hy, hHy⟩)
  have hsome : ∀ i : Fin b,
      ((decode LT (fun y => H (i, y)) (blockEncode H x i)).1).isSome := by
    intro i
    simp [blockEncode, hblock i]
  refine Prod.ext ?_ (blockDecode_cost LT H (blockEncode H x))
  simp only [blockDecode, dif_pos hsome, Option.some.injEq]
  funext i
  have hEq : (decode LT (fun y => H (i, y)) (blockEncode H x i)).1 = some (x i) := by
    simp [blockEncode, hblock i]
  have hgen : ∀ (o : Option β) (h : o.isSome) (v : β), o = some v → o.get h = v := by
    rintro _ h v rfl; rfl
  exact hgen _ (hsome i) (x i) hEq

/-! ## 4. Failure probability: a union bound over the blocks -/

/-- The blocked failure event is contained in a union of `b (|T| - 1)` pairwise
collision events. -/
theorem blockFail_subset (T : Finset β) (x : Fin b → β) :
    blockFail T x M ⊆
      multiCollision M ((univ : Finset (Fin b)).biUnion
        (fun i => (T.erase (x i)).image (fun y => ((i, y), (i, x i))))) := by
  intro H hH
  simp only [blockFail, mem_filter, mem_univ, true_and] at hH
  obtain ⟨i, y, hy, hHy⟩ := hH
  simp only [multiCollision, mem_filter, mem_univ, true_and]
  exact ⟨((i, y), (i, x i)), mem_biUnion.2 ⟨i, mem_univ i, mem_image.2 ⟨y, hy, rfl⟩⟩, hHy⟩

/-- **Blocked random-coding bound.**  With one shared random codebook and
independent per-block hashing, the failure probability obeys the union bound
`P[failure] ≤ b (|T| - 1) / M` — only a factor `b` worse than the flat scheme,
while the decoder cost drops from `|T| ^ b` to `b |T|`. -/
theorem blockFail_prob_le (T : Finset β) {x : Fin b → β} (hx : ∀ i, x i ∈ T) :
    M * (blockFail T x M).card ≤ (b * (T.card - 1)) * M ^ (b * Fintype.card β) := by
  classical
  set P : Finset ((Fin b × β) × (Fin b × β)) :=
    (univ : Finset (Fin b)).biUnion
      (fun i => (T.erase (x i)).image (fun y => ((i, y), (i, x i)))) with hP
  have hpairs : ∀ p ∈ P, p.1 ≠ p.2 := by
    intro p hp
    rw [hP, mem_biUnion] at hp
    obtain ⟨i, -, hi⟩ := hp
    obtain ⟨y, hy, rfl⟩ := mem_image.1 hi
    have : y ≠ x i := (Finset.mem_erase.1 hy).1
    simpa using this
  have hPcard : P.card ≤ b * (T.card - 1) := by
    have h1 : P.card ≤ ∑ i : Fin b, ((T.erase (x i)).image
        (fun y => ((i, y), (i, x i)))).card := by
      rw [hP]; exact Finset.card_biUnion_le
    have h2 : ∀ i : Fin b, ((T.erase (x i)).image (fun y => ((i, y), (i, x i)))).card
        ≤ T.card - 1 := by
      intro i
      have h := Finset.card_image_le (s := T.erase (x i))
        (f := fun y => ((i, y), (i, x i)))
      rwa [Finset.card_erase_of_mem (hx i)] at h
    calc P.card ≤ ∑ i : Fin b, ((T.erase (x i)).image
            (fun y => ((i, y), (i, x i)))).card := h1
      _ ≤ ∑ _i : Fin b, (T.card - 1) := Finset.sum_le_sum (fun i _ => h2 i)
      _ = b * (T.card - 1) := by
          rw [Finset.sum_const, smul_eq_mul, Finset.card_univ, Fintype.card_fin]
  have hcardι : Fintype.card (Fin b × β) = b * Fintype.card β := by
    simp [Fintype.card_prod]
  calc M * (blockFail T x M).card
      ≤ M * (multiCollision M P).card :=
        Nat.mul_le_mul_left _ (Finset.card_le_card (blockFail_subset T x))
    _ ≤ P.card * M ^ Fintype.card (Fin b × β) := card_multiCollision_mul_le P hpairs
    _ ≤ (b * (T.card - 1)) * M ^ (b * Fintype.card β) := by
        rw [hcardι]; exact Nat.mul_le_mul_right _ hPcard

/-- The codebooks on which the blocked scheme recovers `x`. -/
def blockGood (LT : List β) (x : Fin b → β) (M : ℕ) : Finset (Fin b × β → Fin M) :=
  univ.filter (fun H => (blockDecode LT H (blockEncode H x)).1 = some x)

theorem card_blockGood_ge {T : Finset β} {LT : List β} {x : Fin b → β}
    (hnd : LT.Nodup) (hmem : ∀ y, y ∈ LT ↔ y ∈ T) (hx : ∀ i, x i ∈ T) :
    M ^ (b * Fintype.card β) ≤ (blockGood LT x M).card + (blockFail T x M).card := by
  classical
  have hcardι : Fintype.card (Fin b × β) = b * Fintype.card β := by simp [Fintype.card_prod]
  have hsub : (blockFail T x M)ᶜ ⊆ blockGood LT x M := by
    intro H hH
    simp only [mem_compl] at hH
    have hdec := blockDecode_success hnd hmem hx hH
    simp only [blockGood, mem_filter, mem_univ, true_and, hdec]
  have h1 : ((blockFail T x M)ᶜ).card ≤ (blockGood LT x M).card := Finset.card_le_card hsub
  have hle : (blockFail T x M).card ≤ M ^ (b * Fintype.card β) := by
    have h := Finset.card_le_univ (blockFail T x M)
    rwa [card_codebooks, hcardι] at h
  have h2 : ((blockFail T x M)ᶜ).card + (blockFail T x M).card
      = M ^ (b * Fintype.card β) := by
    rw [Finset.card_compl, card_codebooks, hcardι]
    omega
  omega

/-- **Almost-lossless guarantee for the blocked scheme.**  If
`M ≥ b (|T| - 1) / ε` then a uniformly random codebook recovers a fixed typical
string with probability at least `1 - ε`, using exactly `b |T|` hash
comparisons. -/
theorem blockDecode_success_prob_ge {T : Finset β} {LT : List β} {x : Fin b → β}
    (hnd : LT.Nodup) (hmem : ∀ y, y ∈ LT ↔ y ∈ T) (hx : ∀ i, x i ∈ T)
    (hM : 0 < M) {ε : ℝ} (hε : 0 < ε)
    (hMe : (b : ℝ) * ((T.card : ℝ) - 1) / ε ≤ M) (hT : 0 < T.card) :
    1 - ε ≤ ((blockGood LT x M).card : ℝ) / ((M : ℝ) ^ (b * Fintype.card β)) := by
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have hpos : (0 : ℝ) < (M : ℝ) ^ (b * Fintype.card β) := by positivity
  have hT1 : (1 : ℕ) ≤ T.card := hT
  have hfail : (M : ℝ) * (blockFail T x M).card
      ≤ ((b : ℝ) * ((T.card : ℝ) - 1)) * (M : ℝ) ^ (b * Fintype.card β) := by
    have h := blockFail_prob_le (M := M) T hx
    have h' : ((M * (blockFail T x M).card : ℕ) : ℝ)
        ≤ (((b * (T.card - 1)) * M ^ (b * Fintype.card β) : ℕ) : ℝ) := Nat.cast_le.2 h
    push_cast [Nat.cast_sub hT1] at h'
    exact h'
  have hgood : (M : ℝ) ^ (b * Fintype.card β) - (blockFail T x M).card
      ≤ (blockGood LT x M).card := by
    have h := card_blockGood_ge (M := M) hnd hmem hx
    have h' : ((M ^ (b * Fintype.card β) : ℕ) : ℝ)
        ≤ ((blockGood LT x M).card : ℝ) + ((blockFail T x M).card : ℝ) := by
      exact_mod_cast h
    push_cast at h'
    linarith
  have hbound : (b : ℝ) * ((T.card : ℝ) - 1) ≤ ε * M := by
    have := (div_le_iff₀ hε).1 hMe
    linarith
  have hfail2 : ((blockFail T x M).card : ℝ) ≤ ε * (M : ℝ) ^ (b * Fintype.card β) := by
    have h2 : (M : ℝ) * (blockFail T x M).card
        ≤ (M : ℝ) * (ε * (M : ℝ) ^ (b * Fintype.card β)) := by
      have h3 : ((b : ℝ) * ((T.card : ℝ) - 1)) * (M : ℝ) ^ (b * Fintype.card β)
          ≤ (ε * M) * (M : ℝ) ^ (b * Fintype.card β) :=
        mul_le_mul_of_nonneg_right hbound hpos.le
      nlinarith [hfail, h3]
    exact le_of_mul_le_mul_left h2 hMpos
  rw [le_div_iff₀ hpos]
  nlinarith [hgood, hfail2]

/-! ## 5. The complexity separation -/

omit [Fintype β] [DecidableEq β] in
/-- The global typical set is the product of the per-block typical sets, of size
`|T| ^ b`: this is what the *flat* decoder must scan. -/
theorem card_productTypical (T : Finset β) :
    (Fintype.piFinset (fun _ : Fin b => T)).card = T.card ^ b := by
  rw [Fintype.card_piFinset]
  simp

/-- **Exponential-to-linear decoder speedup.**  For at least three blocks over a
non-degenerate block alphabet, the blocked decoder's cost `b |T|` is strictly
smaller than the flat decoder's cost `|T| ^ b`; the gap is exponential in `b`. -/
theorem block_beats_flat {t : ℕ} (ht : 2 ≤ t) (hb : 3 ≤ b) : b * t < t ^ b := by
  induction b with
  | zero => omega
  | succ n ih =>
      rcases Nat.lt_or_ge n 3 with hn | hn
      · -- base case: n + 1 = 3
        interval_cases n
        · omega
        · omega
        · have h : t ^ (2 + 1) = t * t * t := by ring
          have h4 : 4 * t ≤ t * t * t := by nlinarith
          rw [h]; linarith
      · have hprev : n * t < t ^ n := ih (by omega)
        have hpow : t ≤ t ^ n := Nat.le_self_pow (by omega) t
        calc (n + 1) * t = n * t + t := by ring
          _ < t ^ n + t := by omega
          _ ≤ t ^ n + t ^ n := by omega
          _ = 2 * t ^ n := by ring
          _ ≤ t * t ^ n := Nat.mul_le_mul_right _ ht
          _ = t ^ (n + 1) := by ring
  
omit [Fintype β] in
/-- Putting it together: the blocked decoder is strictly cheaper than scanning the
product typical set, which is exactly what the flat scheme of
`AlmostLosslessDecoder` does. -/
theorem blockDecode_cost_lt_flat_cost {T : Finset β} {LT : List β}
    (hnd : LT.Nodup) (hmem : ∀ y, y ∈ LT ↔ y ∈ T) (hT : 2 ≤ T.card) (hb : 3 ≤ b)
    (H : Fin b × β → Fin M) (c : Fin b → Fin M) :
    (blockDecode LT H c).2 < (Fintype.piFinset (fun _ : Fin b => T)).card := by
  have hlen : LT.length = T.card := by
    have : LT.toFinset = T := by
      ext y; simpa using hmem y
    rw [← this, List.toFinset_card_of_nodup hnd]
  rw [blockDecode_cost, card_productTypical, hlen]
  exact block_beats_flat hT hb

end AlmostLossless