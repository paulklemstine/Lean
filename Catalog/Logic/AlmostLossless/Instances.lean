import Logic.AlmostLossless.Scheme

/-!
# Instances: linear scan, bucketed scan, and a concrete `ZMod p` compressor

Two instances of `AlmostLossless.ScanScheme`:

* `AlmostLossless.linearScan` — the decoder scans the whole typical set:
  cost exactly `|T|` hash evaluations, deterministic worst case.
* `AlmostLossless.bucketed` — the codeword is a pair (bucket hash, checksum
  hash) and the decoder scans only one bucket, taken from a precomputed index
  of `T`.  Its cost when decoding a typical word `x` is exactly
  `1 + collisionCount`, and the *expected* cost over the random seed is at most
  `1 + (|T|-1)/m₁` (`AlmostLossless.avg_decodeCost_bucketed_le`): the decoder
  becomes essentially constant-time once `m₁ ≳ |T|`, while the transmitted rate
  is `log m₁ + log m₂` bits.

Finally `AlmostLossless.zmod_scheme` packages the whole pipeline over
`(ZMod p)^k` with the inner-product hash family: `k` field symbols are
compressed to *one* symbol plus a failure flag, the decoder is honest for every
seed, its cost is exactly `|T|`, and the average failure probability is at most
`ε + |T|(|T|-1)/p`.  The companion statement
`AlmostLossless.zmod_uniform_hopeless` shows this is no contradiction with the
pigeonhole bound: on the *uniform* source the very same alphabet fails with
probability at least `1 - (p+1)/p^k`.
-/

namespace AlmostLossless

open Finset

variable {S A M : Type*} [DecidableEq S] [DecidableEq M]

/-! ## The linear-scan scheme -/

/-- The naive scheme: the decoder scans the entire typical set. -/
def linearScan (T : Finset S) (h : A → S → M) : ScanScheme S A M where
  typical := T
  hash := h
  cand := fun _ _ => T
  cand_subset := fun _ _ => Finset.Subset.refl T
  self_mem_cand := fun _ _ hs => hs

omit [DecidableEq S] [DecidableEq M] in
/-- The linear-scan decoder costs exactly `|T|` hash evaluations. -/
theorem decodeCost_linearScan (T : Finset S) (h : A → S → M) (a : A) (m : M) :
    (linearScan T h).decodeCost a m = T.card := rfl

/-! ## The bucketed scheme -/

section Bucketed

variable {A₁ A₂ M₁ M₂ : Type*} [DecidableEq M₁] [DecidableEq M₂]

/-- The bucketed scheme: `h₁` selects a bucket of the decoder's index of `T`
and `h₂` is a checksum used to single out the right word inside the bucket. -/
def bucketed (T : Finset S) (h₁ : A₁ → S → M₁) (h₂ : A₂ → S → M₂) :
    ScanScheme S (A₁ × A₂) (M₁ × M₂) where
  typical := T
  hash := fun a x => (h₁ a.1 x, h₂ a.2 x)
  cand := fun a m => {t ∈ T | h₁ a.1 t = m.1}
  cand_subset := fun _ _ => Finset.filter_subset _ _
  self_mem_cand := fun _ _ hs => Finset.mem_filter.2 ⟨hs, rfl⟩

/-- The size of a bucket containing the typical word `x`: one true candidate
plus the false candidates counted by `collisionCount`. -/
theorem card_bucket_eq (T : Finset S) (h₁ : A₁ → S → M₁) (a₁ : A₁) {x : S} (hx : x ∈ T) :
    #{t ∈ T | h₁ a₁ t = h₁ a₁ x} = 1 + collisionCount h₁ T a₁ x := by
  classical
  have hins : ({t ∈ T | h₁ a₁ t = h₁ a₁ x} : Finset S)
      = insert x ({t ∈ T.erase x | h₁ a₁ t = h₁ a₁ x} : Finset S) := by
    ext y
    simp only [Finset.mem_filter, Finset.mem_insert, Finset.mem_erase]
    constructor
    · rintro ⟨hyT, hy⟩
      by_cases hyx : y = x
      · exact Or.inl hyx
      · exact Or.inr ⟨⟨hyx, hyT⟩, hy⟩
    · rintro (rfl | ⟨⟨_, hyT⟩, hy⟩)
      · exact ⟨hx, rfl⟩
      · exact ⟨hyT, hy⟩
  have hnot : x ∉ ({t ∈ T.erase x | h₁ a₁ t = h₁ a₁ x} : Finset S) := by
    simp only [Finset.mem_filter, Finset.mem_erase]
    rintro ⟨⟨hne, _⟩, _⟩
    exact hne rfl
  rw [hins, Finset.card_insert_of_notMem hnot, collisionCount, Nat.add_comm]

omit [DecidableEq M₂] in
/-- The exact cost of decoding a typical word with the bucketed decoder. -/
theorem decodeCost_bucketed_self (T : Finset S) (h₁ : A₁ → S → M₁) (h₂ : A₂ → S → M₂)
    (a₁ : A₁) (a₂ : A₂) {x : S} (hx : x ∈ T) :
    (bucketed T h₁ h₂).decodeCost (a₁, a₂) ((bucketed T h₁ h₂).hash (a₁, a₂) x)
      = 1 + collisionCount h₁ T a₁ x :=
  card_bucket_eq T h₁ a₁ hx

omit [DecidableEq M₂] in
/-- **Expected decoder complexity of the bucketed scheme.**  Averaged over the
random seed, decoding a typical word costs at most `1 + (|T|-1)/m₁` candidate
tests — constant on average as soon as the bucket count `m₁` exceeds `|T|`,
versus `|T|` for the naive scan and `|S|` for a naive random codebook. -/
theorem avg_decodeCost_bucketed_le [Fintype A₁] [DecidableEq A₁] [Nonempty A₁]
    [Fintype M₁] [Nonempty M₁] (T : Finset S) {h₁ : A₁ → S → M₁} (h₂ : A₂ → S → M₂)
    (hu₁ : TwoUniversal h₁) (a₂ : A₂) {x : S} (hx : x ∈ T) :
    (∑ a₁ : A₁, (((bucketed T h₁ h₂).decodeCost (a₁, a₂)
        ((bucketed T h₁ h₂).hash (a₁, a₂) x) : ℕ) : ℚ)) / (Fintype.card A₁ : ℚ)
      ≤ 1 + ((T.erase x).card : ℚ) / (Fintype.card M₁ : ℚ) := by
  have hA : (0 : ℚ) < (Fintype.card A₁ : ℚ) := by exact_mod_cast Fintype.card_pos (α := A₁)
  have hterm : ∀ a₁ : A₁, (((bucketed T h₁ h₂).decodeCost (a₁, a₂)
      ((bucketed T h₁ h₂).hash (a₁, a₂) x) : ℕ) : ℚ)
      = 1 + (collisionCount h₁ T a₁ x : ℚ) := by
    intro a₁
    rw [decodeCost_bucketed_self T h₁ h₂ a₁ a₂ hx]
    push_cast
    ring
  rw [Finset.sum_congr rfl (fun a₁ _ => hterm a₁), Finset.sum_add_distrib]
  have havg := avg_collisionCount_le hu₁ T x
  rw [div_le_iff₀ hA] at havg ⊢
  have h1 : ∑ _a₁ : A₁, (1 : ℚ) = (Fintype.card A₁ : ℚ) := by simp
  rw [h1]
  have : ((T.erase x).card : ℚ) / (Fintype.card M₁ : ℚ) * (Fintype.card A₁ : ℚ)
      ≥ ∑ a₁ : A₁, (collisionCount h₁ T a₁ x : ℚ) := havg
  nlinarith [this]

end Bucketed

/-! ## A concrete compressor over `(ZMod p)^k` -/

section ZMod

variable {p k : ℕ} [Fact p.Prime]

/-- The concrete Monte-Carlo compressor: source words are `k`-symbol strings
over `ZMod p`, the shared random seed is a vector `a ∈ (ZMod p)^k` produced by a
random number generator, and the codeword is the single field element
`⟨a, x⟩` (plus an explicit failure flag). -/
def zmodScheme (T : Finset (Fin k → ZMod p)) :
    ScanScheme (Fin k → ZMod p) (Fin k → ZMod p) (ZMod p) :=
  linearScan T (dotHash p k)

/-- **Main theorem (the deliverable).**  For every typical set `T` of
probability at least `1 - ε`:

1. the decoder is *honest for every seed* — it never returns a wrong word,
   only the true word or an explicit failure;
2. its cost is exactly `|T|` hash evaluations;
3. the average failure probability over the random seed is at most
   `ε + |T|(|T|-1)/p`,

while the transmitted codeword ranges over only `p + 1` symbols, against
`p ^ k` source words. -/
theorem zmod_scheme_reliable (T : Finset (Fin k → ZMod p))
    (μ : Source (Fin k → ZMod p)) (ε : ℚ) (hε : 0 ≤ ε) (hT : 1 - ε ≤ μ.prob T) :
    (∀ a : Fin k → ZMod p, Honest ((zmodScheme T).code a)) ∧
    (∀ (a : Fin k → ZMod p) (m : ZMod p), (zmodScheme T).decodeCost a m = T.card) ∧
    avgFailProb μ (fun a => (zmodScheme T).code a)
      ≤ ε + (T.offDiag.card : ℚ) / (Fintype.card (ZMod p) : ℚ) := by
  refine ⟨fun a => honest_scanCode _ a, fun a m => rfl, ?_⟩
  exact avgFailProb_scanCode_le μ (zmodScheme T) (twoUniversal_dotHash) ε hε hT

/-- The codeword alphabet really is small: `p + 1` symbols. -/
theorem card_zmod_codeword : Fintype.card (Option (ZMod p)) = p + 1 := by
  simp [ZMod.card]

/-- **The pigeonhole bound is not violated.**  On the *uniform* source over all
of `(ZMod p)^k` the same `p+1`-symbol alphabet fails with probability at least
`1 - (p+1)/p^k`; the Monte-Carlo scheme wins only because the source is
concentrated on a small typical set. -/
theorem zmod_uniform_hopeless (K : Code (Fin k → ZMod p) (Option (ZMod p))) :
    1 - ((p : ℚ) + 1) / ((p : ℚ) ^ k) ≤ failProb uniformSource K := by
  have hcard : Fintype.card (Fin k → ZMod p) = p ^ k := by simp [ZMod.card]
  have h := uniform_failProb_lower (S := Fin k → ZMod p) (C := Option (ZMod p)) K
  rw [hcard, card_zmod_codeword] at h
  push_cast at h
  exact h

end ZMod

end AlmostLossless