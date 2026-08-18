/-
# The exact failure probability of random hashing

Part of the research thread *Compression Beyond the Pigeonhole Bound*
(Phase B, Question 2: can random number generators help?).

`AlmostLosslessDecoder` gives the upper bound `P[failure] ≤ (|S|-1)/M` and
`AlmostLosslessConverse` the Bonferroni lower bound `P[failure] ≥ (|S|-1)/(2M)`.
Here we compute the quantity **exactly**:

`AlmostLossless.card_sepSet` :  `M^k · |{H : H separates x from D}| = (M-1)^k · M^{|α|}`  (`k = |D|`),

whence `AlmostLossless.failure_prob_exact`:

`P[failure at x] = 1 - (1 - 1/M)^{|S|-1}`.

Both previously proved bounds are corollaries of this identity in the regime
they cover, and the measured values of `AlmostLosslessLabNotes` (`3/4`, `5/9`,
`7/16`, `15/64`, `31/256`) are exactly its values at `|S| = 3`.

The proof is an explicit bijection
`{H separating x from D ∪ {a}} × Fin M  ≃  Σ_{H separating x from D} (Fin M \ {H x})`,
given by `(H, v) ↦ ⟨update H a v, H a⟩`, iterated by induction on `D`.
-/
import Geometry.AlmostLosslessDecoder

namespace AlmostLossless

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α] {M : ℕ}

/-- Codebooks that separate `x` from every element of `D`. -/
def sepSet (D : Finset α) (x : α) (M : ℕ) : Finset (α → Fin M) :=
  univ.filter (fun H => ∀ y ∈ D, H y ≠ H x)

/-- The one-step recursion: adding one competitor multiplies the number of
separating codebooks by `(M-1)/M`. -/
theorem card_sepSet_insert {D : Finset α} {x a : α} (ha : a ∉ D) (hax : a ≠ x) :
    M * (sepSet (insert a D) x M).card = (M - 1) * (sepSet D x M).card := by
  classical
  have hbij : ((sepSet (insert a D) x M) ×ˢ (univ : Finset (Fin M))).card
      = ((sepSet D x M).sigma (fun H => (univ : Finset (Fin M)).erase (H x))).card := by
    apply Finset.card_bij (fun z _ => ⟨Function.update z.1 a z.2, z.1 a⟩)
    · rintro ⟨H, v⟩ hz
      rw [mem_product] at hz
      have hH : ∀ y ∈ insert a D, H y ≠ H x := by
        simpa [sepSet] using hz.1
      have hHa : H a ≠ H x := hH a (mem_insert_self a D)
      rw [Finset.mem_sigma]
      constructor
      · simp only [sepSet, mem_filter, mem_univ, true_and]
        intro y hy
        have hya : y ≠ a := fun h => ha (h ▸ hy)
        have hyx : x ≠ a := fun h => hax h.symm
        simpa [Function.update_apply, hya, hyx] using hH y (mem_insert_of_mem hy)
      · have hxa : x ≠ a := fun h => hax h.symm
        simp only [Finset.mem_erase, mem_univ, and_true]
        simpa [Function.update_apply, hxa] using hHa
    · rintro ⟨H, v⟩ hz ⟨H', v'⟩ hz' heq
      simp only [Sigma.mk.injEq] at heq
      have hHa : H a = H' a := eq_of_heq heq.2
      have hupd : Function.update H a v = Function.update H' a v' := heq.1
      have hv : v = v' := by
        have := congrArg (fun f => f a) hupd
        simpa using this
      have hHH : H = H' := by
        funext y
        rcases eq_or_ne y a with hy | hy
        · rw [hy, hHa]
        · have := congrArg (fun f => f y) hupd
          simpa [Function.update_apply, hy] using this
      simp [hHH, hv]
    · rintro ⟨H, w⟩ hz
      rw [Finset.mem_sigma] at hz
      have hH : ∀ y ∈ D, H y ≠ H x := by simpa [sepSet] using hz.1
      have hw : w ≠ H x := (Finset.mem_erase.1 hz.2).1
      have hxa : x ≠ a := fun h => hax h.symm
      refine ⟨(Function.update H a w, H a), ?_, ?_⟩
      · rw [mem_product]
        refine ⟨?_, mem_univ _⟩
        simp only [sepSet, mem_filter, mem_univ, true_and]
        intro y hy
        rcases Finset.mem_insert.1 hy with hy' | hy'
        · simpa [hy', Function.update_apply, hxa] using hw
        · have hya : y ≠ a := fun h => ha (h ▸ hy')
          simpa [Function.update_apply, hya, hxa] using hH y hy'
      · have h1 : Function.update (Function.update H a w) a (H a) = H := by
          funext y
          rcases eq_or_ne y a with hy | hy
          · rw [hy]; simp
          · simp [hy]
        simp [h1]
  rw [Finset.card_product, Finset.card_univ, Fintype.card_fin, Finset.card_sigma] at hbij
  have hsum : ∑ H ∈ sepSet D x M, ((univ : Finset (Fin M)).erase (H x)).card
      = (sepSet D x M).card * (M - 1) := by
    rw [Finset.sum_congr rfl (fun H _ => by
      rw [Finset.card_erase_of_mem (mem_univ _), Finset.card_univ, Fintype.card_fin]),
      Finset.sum_const, smul_eq_mul]
  rw [hsum] at hbij
  calc M * (sepSet (insert a D) x M).card
      = (sepSet (insert a D) x M).card * M := by ring
    _ = (sepSet D x M).card * (M - 1) := hbij
    _ = (M - 1) * (sepSet D x M).card := by ring

/-- **Exact count of separating codebooks**:
`M^{|D|} · |{H : H y ≠ H x for all y ∈ D}| = (M-1)^{|D|} · M^{|α|}`. -/
theorem card_sepSet (x : α) (D : Finset α) (hx : x ∉ D) :
    M ^ D.card * (sepSet D x M).card = (M - 1) ^ D.card * M ^ Fintype.card α := by
  classical
  induction D using Finset.induction_on with
  | empty => simp [sepSet, Finset.card_univ]
  | insert a D ha ih =>
      have hax : a ≠ x := by
        intro h
        exact hx (h ▸ mem_insert_self a D)
      have hxD : x ∉ D := fun h => hx (mem_insert_of_mem h)
      have hstep := card_sepSet_insert (M := M) (x := x) ha hax
      have hIH := ih hxD
      calc M ^ (insert a D).card * (sepSet (insert a D) x M).card
          = M ^ D.card * (M * (sepSet (insert a D) x M).card) := by
            rw [Finset.card_insert_of_notMem ha]; ring
        _ = M ^ D.card * ((M - 1) * (sepSet D x M).card) := by rw [hstep]
        _ = (M - 1) * (M ^ D.card * (sepSet D x M).card) := by ring
        _ = (M - 1) * ((M - 1) ^ D.card * M ^ Fintype.card α) := by rw [hIH]
        _ = (M - 1) ^ (insert a D).card * M ^ Fintype.card α := by
            rw [Finset.card_insert_of_notMem ha]; ring

/-- The separating codebooks are exactly the complement of the failure event. -/
theorem sepSet_compl (S : Finset α) (x : α) :
    sepSet (S.erase x) x M = (failSet S x M)ᶜ := by
  ext H
  simp only [sepSet, failSet, mem_filter, mem_univ, true_and, mem_compl, not_exists]
  push_neg
  rfl

/-- **Exact failure count of uniform random hashing**:
`M^k · (M^{|α|} - |failSet|) = (M-1)^k · M^{|α|}` with `k = |S| - 1`. -/
theorem card_failSet_exact (S : Finset α) (x : α) :
    M ^ (S.erase x).card * (M ^ Fintype.card α - (failSet S x M).card)
      = (M - 1) ^ (S.erase x).card * M ^ Fintype.card α := by
  have hx : x ∉ S.erase x := Finset.notMem_erase x S
  have h := card_sepSet (M := M) x (S.erase x) hx
  rw [sepSet_compl] at h
  rwa [Finset.card_compl, card_codebooks] at h

/-- **The exact failure probability of random hashing**:
`P[failure at x] = 1 - (1 - 1/M)^{|S|-1}`.
This identity is sharp: it implies the union bound of `failSet_prob_le` and the
Bonferroni bound of `failure_prob_lower_bound`, and reproduces every measured
value in `AlmostLosslessLabNotes`. -/
theorem failure_prob_exact (S : Finset α) (x : α) (hM : 0 < M) :
    ((failSet S x M).card : ℝ) / ((M : ℝ) ^ Fintype.card α)
      = 1 - (1 - 1 / (M : ℝ)) ^ (S.erase x).card := by
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have hpow : (0 : ℝ) < (M : ℝ) ^ Fintype.card α := by positivity
  have hkpow : (0 : ℝ) < (M : ℝ) ^ (S.erase x).card := by positivity
  have hle : (failSet S x M).card ≤ M ^ Fintype.card α := by
    have h := Finset.card_le_univ (failSet S x M)
    rwa [card_codebooks] at h
  have hnat := card_failSet_exact (M := M) S x
  -- cast the natural-number identity to ℝ
  have hcast : (M : ℝ) ^ (S.erase x).card
        * ((M : ℝ) ^ Fintype.card α - ((failSet S x M).card : ℝ))
      = ((M : ℝ) - 1) ^ (S.erase x).card * (M : ℝ) ^ Fintype.card α := by
    have h1 : (((M ^ (S.erase x).card * (M ^ Fintype.card α - (failSet S x M).card) : ℕ)) : ℝ)
        = (((M - 1) ^ (S.erase x).card * M ^ Fintype.card α : ℕ) : ℝ) := by
      exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) hnat
    have hM1 : ((M - 1 : ℕ) : ℝ) = (M : ℝ) - 1 := by
      have : (1 : ℕ) ≤ M := hM
      push_cast [Nat.cast_sub this]; ring
    push_cast [Nat.cast_sub hle, hM1] at h1
    exact h1
  have hsplit : (1 - 1 / (M : ℝ)) ^ (S.erase x).card
      = ((M : ℝ) - 1) ^ (S.erase x).card / (M : ℝ) ^ (S.erase x).card := by
    rw [← div_pow]
    congr 1
    field_simp
  rw [hsplit]
  field_simp
  nlinarith [hcast, hkpow, hpow]

end AlmostLossless