/-
# The Price of Universality XI: exchangeable classes are cheap, whatever they are

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

All the bounds proved so far are for *parametric* families: memoryless, Markov,
finite-state.  One might suspect that parametricity is what keeps the price of
universality logarithmic.  It is not.  The only thing that matters is a symmetry
of the class:

**If a class of sources on messages of length `n` is invariant under permuting
the positions of the message, its price of universality is at most
`(#A − 1) · log₂ (n + 1)` bits — no matter how large, non-parametric or wild the
class is.**

The reason is that permutation invariance forces the likelihood to depend on the
message only through its type (the vector of letter counts), and there are at
most `(n+1)^(#A−1)` types.  The class of *all* exchangeable sources — in
particular every mixture of memoryless sources, by de Finetti — is therefore no
more expensive to code universally than the memoryless family itself.

## Main results

* `exists_perm_of_countStat_eq` — two words with the same letter counts differ
  by a permutation of positions
* `shtarkovSum_le_of_countInvariant` — a class whose likelihood factors through
  the type has `Cₛ ≤ (n+1)^(#A−1)`
* `shtarkovSum_le_of_permInvariant` — the same for permutation-invariant
  (exchangeable) classes
* `price_permInvariant_le_bits` — bit form
* `exchangeable_price_binary` — for a binary alphabet: at most `log₂ (n+1)` bits,
  for *every* exchangeable class

## Application keywords

exchangeability, de Finetti, method of types, minimax redundancy, Shtarkov sum,
non-parametric universal coding
-/

import Logic.PriceOfUniversality.TypeDimension

open Finset Real

namespace UniversalRedundancy

variable {A : Type*} [Fintype A] [DecidableEq A] {n : ℕ}

omit [Fintype A] in
/-- **Words with equal letter counts are permutations of one another.**  Given
`x` and `y` with the same counts, there is a permutation `σ` of the positions
with `y (σ j) = x j` for every `j`. -/
theorem exists_perm_of_countStat_eq {x y : Fin n → A}
    (h : countStat x = countStat y) :
    ∃ σ : Equiv.Perm (Fin n), ∀ j, y (σ j) = x j := by
  classical
  -- fibrewise bijections
  have hcard : ∀ b : A, Fintype.card {j : Fin n // x j = b}
      = Fintype.card {j : Fin n // y j = b} := by
    intro b
    have hx : Fintype.card {j : Fin n // x j = b}
        = (univ.filter (fun j => x j = b)).card := Fintype.card_subtype _
    have hy : Fintype.card {j : Fin n // y j = b}
        = (univ.filter (fun j => y j = b)).card := Fintype.card_subtype _
    have := congrArg (fun (f : A → Fin (n + 1)) => ((f b : Fin (n + 1)) : ℕ)) h
    simpa [hx, hy, countStat] using this
  have e : ∀ b : A, {j : Fin n // x j = b} ≃ {j : Fin n // y j = b} :=
    fun b => Fintype.equivOfCardEq (hcard b)
  -- reassemble the fibrewise bijections into a single permutation of positions
  refine ⟨(Equiv.sigmaFiberEquiv x).symm.trans
    ((Equiv.sigmaCongrRight e).trans (Equiv.sigmaFiberEquiv y)), fun j => ?_⟩
  simp [Equiv.sigmaFiberEquiv]
  exact (e (x j) ⟨j, rfl⟩).2

/-- **Type-invariant classes are cheap.**  If the likelihood of every source in
the class depends on the message only through its vector of letter counts, then
the Shtarkov sum is at most the number of types, `(n+1)^(#A−1)`. -/
theorem shtarkovSum_le_of_countInvariant [Nonempty A] {Θ : Type*} [Nonempty Θ]
    (S : SourceClass (Fin n → A) Θ)
    (hS : ∀ θ x y, countStat x = countStat y → S.prob θ x = S.prob θ y) :
    S.shtarkovSum ≤ ((n : ℝ) + 1) ^ (Fintype.card A - 1) := by
  classical
  set a₀ : A := Classical.arbitrary A with ha₀
  have hstat := S.shtarkovSum_le_card_statistic
    (σ := {a : A // a ≠ a₀} → Fin (n + 1))
    (T := fun x b => countStat x b.1) ?_
  · refine hstat.trans (le_of_eq ?_)
    rw [Fintype.card_fun]
    have hcard : Fintype.card {a : A // a ≠ a₀} = Fintype.card A - 1 := by
      simp [Fintype.card_subtype_compl (p := fun b : A => b = a₀)]
    rw [hcard, Fintype.card_fin]
    push_cast
    ring
  · intro θ x y hxy
    exact hS θ x y (countStat_eq_of_eq_off a₀ x y fun b hb => congrFun hxy ⟨b, hb⟩)

/-- **Exchangeable classes are cheap.**  A class invariant under permutations of
the message positions has Shtarkov sum at most `(n+1)^(#A−1)`, however large the
class is. -/
theorem shtarkovSum_le_of_permInvariant [Nonempty A] {Θ : Type*} [Nonempty Θ]
    (S : SourceClass (Fin n → A) Θ)
    (hS : ∀ (θ : Θ) (x : Fin n → A) (σ : Equiv.Perm (Fin n)),
      S.prob θ (fun j => x (σ j)) = S.prob θ x) :
    S.shtarkovSum ≤ ((n : ℝ) + 1) ^ (Fintype.card A - 1) := by
  refine shtarkovSum_le_of_countInvariant S fun θ x y hxy => ?_
  obtain ⟨σ, hσ⟩ := exists_perm_of_countStat_eq hxy
  have hx : (fun j => y (σ j)) = x := funext hσ
  calc S.prob θ x = S.prob θ (fun j => y (σ j)) := by rw [hx]
    _ = S.prob θ y := hS θ y σ

/-- **Bit form.**  The price of universality of any exchangeable class of
length-`n` sources is at most `(#A − 1) · log₂ (n+1)` bits. -/
theorem price_permInvariant_le_bits [Nonempty A] {Θ : Type*} [Nonempty Θ]
    (S : SourceClass (Fin n → A) Θ)
    (hS : ∀ (θ : Θ) (x : Fin n → A) (σ : Equiv.Perm (Fin n)),
      S.prob θ (fun j => x (σ j)) = S.prob θ x) :
    logb 2 S.shtarkovSum ≤ ((Fintype.card A : ℝ) - 1) * logb 2 ((n : ℝ) + 1) := by
  have hC := shtarkovSum_le_of_permInvariant S hS
  have hle : logb 2 S.shtarkovSum
      ≤ logb 2 (((n : ℝ) + 1) ^ (Fintype.card A - 1)) :=
    Real.logb_le_logb_of_le (by norm_num) S.shtarkovSum_pos hC
  rw [Real.logb_pow] at hle
  have hcard : ((Fintype.card A - 1 : ℕ) : ℝ) = (Fintype.card A : ℝ) - 1 := by
    have h1 : 1 ≤ Fintype.card A := Fintype.card_pos
    push_cast [Nat.cast_sub h1]
    ring
  rwa [hcard] at hle

/-- **Binary exchangeable sources cost at most `log₂ (n+1)` bits of
universality**, whatever the class: mixtures of Bernoulli sources, Pólya urns,
and every other exchangeable law are all served by one code at that price. -/
theorem exchangeable_price_binary {Θ : Type*} [Nonempty Θ]
    (S : SourceClass (Fin n → Bool) Θ)
    (hS : ∀ (θ : Θ) (x : Fin n → Bool) (σ : Equiv.Perm (Fin n)),
      S.prob θ (fun j => x (σ j)) = S.prob θ x) :
    logb 2 S.shtarkovSum ≤ logb 2 ((n : ℝ) + 1) := by
  have h := price_permInvariant_le_bits S hS
  have hc : (Fintype.card Bool : ℝ) - 1 = 1 := by norm_num
  rwa [hc, one_mul] at h

end UniversalRedundancy