/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.SchubertCalculus.Mahonian

/-!
# Schubert calculus VIII: inversions are Coxeter length

`Mahonian.lean` proves the Mahonian identity `∑_{w ∈ S_N} q^{inv w} = [N]_q !` and, by way of
`sign_eq_neg_one_pow_invCount`, the *parity* half of the statement that `invCount` is the
length function of the Coxeter group `S_N`.  This file settles the exact-value half, which is
sub-conjecture **(C2)** of the previous research cycle:

> `invCount w` is the minimal number of adjacent transpositions needed to write `w`.

Together with the Mahonian identity this identifies the dimension of the Bruhat cell of `w` in
the complete flag variety with the Coxeter length `ℓ(w)`, and turns the flag-variety point
count into the Poincaré series of the Coxeter group `A_{N-1}`.

The argument is the classical one, formalised from scratch (mathlib does not carry a Coxeter
system structure on `Equiv.Perm (Fin n)`):

* `invPairs` realises `invCount` as the cardinality of the inversion *set*
  `{(a, b) : a < b, w b < w a}`;
* `card_invPairs_erase` : right multiplication by the adjacent transposition
  `s_i = (i, i+1)` induces, via `(a, b) ↦ (s_i a, s_i b)`, a bijection between the inversion
  sets of `w · s_i` and of `w` *after deleting the single pair `(i, i+1)`*.  The crucial point
  is that `s_i` preserves the order of every pair except `(i, i+1)` itself, because `i` and
  `i+1` are adjacent;
* hence `inv (w · s_i) = inv w ± 1`, the sign being `+` exactly when `(i, i+1)` is not already
  an inversion (`invCount_mul_adjGen_of_lt`, `invCount_mul_adjGen_of_gt`);
* a permutation with no inversions is strictly monotone, hence the identity
  (`invCount_eq_zero_iff`), which supplies the base case of a descent induction producing a
  word of length `inv w` (`exists_word`);
* the `± 1` estimate bounds `inv` below by the length of *any* word (`invCount_le_length`).

Main results:

* `SchubertCalculus.coxLength_eq_invCount` : **`ℓ(w) = inv w`**;
* `SchubertCalculus.coxLength_mul_adjGen_of_lt` / `..._of_gt` : the exchange behaviour of the
  length function, `ℓ(w s_i) = ℓ(w) ± 1`;
* `SchubertCalculus.sum_pow_coxLength` : the **Poincaré series of the Coxeter group**
  `∑_{w ∈ S_N} q^{ℓ(w)} = [N]_q !`;
* `SchubertCalculus.card_completeFlag_eq_sum_pow_coxLength` : the flag-variety point count in
  its Coxeter form;
* `SchubertCalculus.sign_eq_neg_one_pow_coxLength` : `sgn w = (-1)^{ℓ(w)}`;
* `SchubertCalculus.invCount_mul_two_eq_iff` : the number of inversions is maximal, equal to
  `N(N-1)/2`, **exactly** for the reversal permutation `w₀`;
* `SchubertCalculus.coxLength_revPerm_mul_two` : hence `ℓ(w₀) = dim Fl(K^{N+1}) = (N+1)N/2`,
  matching the degree of the `q`-factorial `[N+1]_q !`;
* `SchubertCalculus.invCount_inv` : `ℓ(w⁻¹) = ℓ(w)`;
* `SchubertCalculus.invCount_revPerm_mul_add` : `ℓ(w₀ w) + ℓ(w) = dim Fl`, the flag-variety
  analogue of the complementary-dimension identity `dimCell_add_dimCell_compl`.
-/

namespace SchubertCalculus

open Finset

/-! ### Inversions as a set of pairs -/

/-- The inversion *set* of a permutation: the pairs `(a, b)` with `a < b` and `w b < w a`. -/
def invPairs {N : ℕ} (w : Equiv.Perm (Fin N)) : Finset (Fin N × Fin N) :=
  {p ∈ (univ : Finset (Fin N × Fin N)) | p.1 < p.2 ∧ w p.2 < w p.1}

@[simp] lemma mem_invPairs {N : ℕ} {w : Equiv.Perm (Fin N)} {p : Fin N × Fin N} :
    p ∈ invPairs w ↔ p.1 < p.2 ∧ w p.2 < w p.1 := by
  simp [invPairs]

/-- `invCount` is the cardinality of the inversion set. -/
lemma card_invPairs {N : ℕ} (w : Equiv.Perm (Fin N)) : (invPairs w).card = invCount w := by
  rw [invPairs, invCount, Finset.card_filter, Fintype.sum_prod_type]
  exact Finset.sum_congr rfl fun i _ => (Finset.card_filter _ _).symm

/-! ### Adjacent transpositions -/

variable {n : ℕ}

/-- The `i`-th adjacent transposition (simple reflection) of `S_{n+1}`. -/
def adjGen (i : Fin n) : Equiv.Perm (Fin (n + 1)) := Equiv.swap i.castSucc i.succ

lemma adjGen_castSucc (i : Fin n) : adjGen i i.castSucc = i.succ := by
  simp [adjGen]

lemma adjGen_succ (i : Fin n) : adjGen i i.succ = i.castSucc := by
  simp [adjGen]

lemma adjGen_mul_self (i : Fin n) : adjGen i * adjGen i = 1 := by
  simp [adjGen, Equiv.swap_mul_self]

lemma adjGen_adjGen (i : Fin n) (a : Fin (n + 1)) : adjGen i (adjGen i a) = a := by
  simp [adjGen]

/-- An adjacent transposition preserves the order of every pair *except* the pair it swaps:
this is exactly where adjacency (`i + 1` is the successor of `i`) is used. -/
lemma adjGen_lt_adjGen {i : Fin n} {a b : Fin (n + 1)} (hab : a < b)
    (hne : ¬(a = i.castSucc ∧ b = i.succ)) : adjGen i a < adjGen i b := by
  have hu : (i.castSucc : ℕ) = (i : ℕ) := rfl
  have hv : (i.succ : ℕ) = (i : ℕ) + 1 := rfl
  have hab' : (a : ℕ) < (b : ℕ) := hab
  by_cases hau : a = i.castSucc
  · subst hau
    have hbv : b ≠ i.succ := fun h => hne ⟨rfl, h⟩
    have hbu : b ≠ i.castSucc := fun h => absurd (h ▸ hab') (lt_irrefl _)
    have hbv' : (b : ℕ) ≠ (i : ℕ) + 1 := fun h => hbv (Fin.ext (by rw [h, hv]))
    rw [adjGen_castSucc, adjGen, Equiv.swap_apply_of_ne_of_ne hbu hbv]
    show (i.succ : ℕ) < (b : ℕ)
    rw [hv]; omega
  · by_cases hav : a = i.succ
    · subst hav
      have hbu : b ≠ i.castSucc := by
        intro h
        have : (b : ℕ) = (i : ℕ) := by rw [h, hu]
        omega
      have hbv : b ≠ i.succ := fun h => absurd (h ▸ hab') (lt_irrefl _)
      rw [adjGen_succ, adjGen, Equiv.swap_apply_of_ne_of_ne hbu hbv]
      show (i.castSucc : ℕ) < (b : ℕ)
      rw [hu]; omega
    · have hau' : (a : ℕ) ≠ (i : ℕ) := fun h => hau (Fin.ext (by rw [h, hu]))
      have hav' : (a : ℕ) ≠ (i : ℕ) + 1 := fun h => hav (Fin.ext (by rw [h, hv]))
      rw [adjGen, Equiv.swap_apply_of_ne_of_ne hau hav]
      by_cases hbu : b = i.castSucc
      · subst hbu
        rw [Equiv.swap_apply_left]
        show (a : ℕ) < (i.succ : ℕ)
        rw [hv]; rw [hu] at hab'; omega
      · by_cases hbv : b = i.succ
        · subst hbv
          rw [Equiv.swap_apply_right]
          show (a : ℕ) < (i.castSucc : ℕ)
          rw [hu]; rw [hv] at hab'; omega
        · rw [Equiv.swap_apply_of_ne_of_ne hbu hbv]
          exact hab

/-! ### The inversion set changes by exactly one pair -/

/-- Deleting the pair `(i, i+1)`, the inversion sets of `w · s_i` and of `w` are in bijection
under `(a, b) ↦ (s_i a, s_i b)`. -/
lemma card_invPairs_erase (w : Equiv.Perm (Fin (n + 1))) (i : Fin n) :
    ((invPairs (w * adjGen i)).erase (i.castSucc, i.succ)).card
      = ((invPairs w).erase (i.castSucc, i.succ)).card := by
  refine Finset.card_nbij' (i := fun p => (adjGen i p.1, adjGen i p.2))
    (j := fun p => (adjGen i p.1, adjGen i p.2)) ?_ ?_ ?_ ?_
  · rintro ⟨a, b⟩ hp
    have hne : (a, b) ≠ (i.castSucc, i.succ) := Finset.ne_of_mem_erase hp
    have hmem := mem_invPairs.mp (Finset.mem_of_mem_erase hp)
    obtain ⟨hab, hinv⟩ := hmem
    have hne' : ¬(a = i.castSucc ∧ b = i.succ) := fun h => hne (Prod.ext h.1 h.2)
    refine Finset.mem_erase.mpr ⟨?_, mem_invPairs.mpr ⟨adjGen_lt_adjGen hab hne', ?_⟩⟩
    · rintro h
      have h1 : adjGen i a = i.castSucc := congrArg Prod.fst h
      have h2 : adjGen i b = i.succ := congrArg Prod.snd h
      have ha : a = i.succ := by
        have := congrArg (adjGen i) h1
        rwa [adjGen_adjGen, adjGen_castSucc] at this
      have hb : b = i.castSucc := by
        have := congrArg (adjGen i) h2
        rwa [adjGen_adjGen, adjGen_succ] at this
      rw [ha, hb] at hab
      exact absurd hab (not_lt.2 Fin.castSucc_lt_succ.le)
    · simpa [Equiv.Perm.mul_apply] using hinv
  · rintro ⟨a, b⟩ hp
    have hne : (a, b) ≠ (i.castSucc, i.succ) := Finset.ne_of_mem_erase hp
    have hmem := mem_invPairs.mp (Finset.mem_of_mem_erase hp)
    obtain ⟨hab, hinv⟩ := hmem
    have hne' : ¬(a = i.castSucc ∧ b = i.succ) := fun h => hne (Prod.ext h.1 h.2)
    refine Finset.mem_erase.mpr ⟨?_, mem_invPairs.mpr ⟨adjGen_lt_adjGen hab hne', ?_⟩⟩
    · rintro h
      have h1 : adjGen i a = i.castSucc := congrArg Prod.fst h
      have h2 : adjGen i b = i.succ := congrArg Prod.snd h
      have ha : a = i.succ := by
        have := congrArg (adjGen i) h1
        rwa [adjGen_adjGen, adjGen_castSucc] at this
      have hb : b = i.castSucc := by
        have := congrArg (adjGen i) h2
        rwa [adjGen_adjGen, adjGen_succ] at this
      rw [ha, hb] at hab
      exact absurd hab (not_lt.2 Fin.castSucc_lt_succ.le)
    · simpa [Equiv.Perm.mul_apply, adjGen_adjGen] using hinv
  · rintro ⟨a, b⟩ _
    simp [adjGen_adjGen]
  · rintro ⟨a, b⟩ _
    simp [adjGen_adjGen]

lemma pair_mem_invPairs_mul_iff (w : Equiv.Perm (Fin (n + 1))) (i : Fin n) :
    (i.castSucc, i.succ) ∈ invPairs (w * adjGen i) ↔ w i.castSucc < w i.succ := by
  simp [mem_invPairs, Equiv.Perm.mul_apply, adjGen_castSucc, adjGen_succ]

lemma pair_mem_invPairs_iff (w : Equiv.Perm (Fin (n + 1))) (i : Fin n) :
    (i.castSucc, i.succ) ∈ invPairs w ↔ w i.succ < w i.castSucc := by
  simp [mem_invPairs]

/-- **Ascent case.**  Multiplying on the right by `s_i` at an ascent raises the number of
inversions by exactly one. -/
theorem invCount_mul_adjGen_of_lt {w : Equiv.Perm (Fin (n + 1))} {i : Fin n}
    (h : w i.castSucc < w i.succ) :
    invCount (w * adjGen i) = invCount w + 1 := by
  have hA : (i.castSucc, i.succ) ∈ invPairs (w * adjGen i) :=
    (pair_mem_invPairs_mul_iff w i).mpr h
  have hB : (i.castSucc, i.succ) ∉ invPairs w := by
    rw [pair_mem_invPairs_iff]; exact not_lt.2 h.le
  have h1 : ((invPairs (w * adjGen i)).erase (i.castSucc, i.succ)).card
      = (invPairs (w * adjGen i)).card - 1 := Finset.card_erase_of_mem hA
  have h2 : (invPairs w).erase (i.castSucc, i.succ) = invPairs w := Finset.erase_eq_of_notMem hB
  have h3 := card_invPairs_erase w i
  rw [h1, h2] at h3
  have h4 : 1 ≤ (invPairs (w * adjGen i)).card := Finset.card_pos.mpr ⟨_, hA⟩
  rw [← card_invPairs, ← card_invPairs]
  omega

/-- **Descent case.**  Multiplying on the right by `s_i` at a descent lowers the number of
inversions by exactly one. -/
theorem invCount_mul_adjGen_of_gt {w : Equiv.Perm (Fin (n + 1))} {i : Fin n}
    (h : w i.succ < w i.castSucc) :
    invCount (w * adjGen i) + 1 = invCount w := by
  have hB : (i.castSucc, i.succ) ∈ invPairs w := (pair_mem_invPairs_iff w i).mpr h
  have hA : (i.castSucc, i.succ) ∉ invPairs (w * adjGen i) := by
    rw [pair_mem_invPairs_mul_iff]; exact not_lt.2 h.le
  have h1 : ((invPairs w).erase (i.castSucc, i.succ)).card = (invPairs w).card - 1 :=
    Finset.card_erase_of_mem hB
  have h2 : (invPairs (w * adjGen i)).erase (i.castSucc, i.succ) = invPairs (w * adjGen i) :=
    Finset.erase_eq_of_notMem hA
  have h3 := card_invPairs_erase w i
  rw [h1, h2] at h3
  have h4 : 1 ≤ (invPairs w).card := Finset.card_pos.mpr ⟨_, hB⟩
  rw [← card_invPairs, ← card_invPairs]
  omega

/-- Each simple reflection changes the inversion number by exactly one. -/
theorem invCount_mul_adjGen_le (w : Equiv.Perm (Fin (n + 1))) (i : Fin n) :
    invCount (w * adjGen i) ≤ invCount w + 1 := by
  rcases lt_trichotomy (w i.castSucc) (w i.succ) with h | h | h
  · exact le_of_eq (invCount_mul_adjGen_of_lt h)
  · exact absurd (w.injective h) Fin.castSucc_lt_succ.ne
  · have := invCount_mul_adjGen_of_gt h
    omega

/-! ### Permutations with no inversions -/

/-- A strictly monotone permutation of `Fin N` is the identity. -/
theorem eq_one_of_strictMono {N : ℕ} {w : Equiv.Perm (Fin N)} (hmono : StrictMono w) :
    w = 1 := by
  have hsymm : StrictMono w.symm := by
    intro a b hab
    by_contra hc
    push_neg at hc
    have := hmono.monotone hc
    rw [Equiv.apply_symm_apply, Equiv.apply_symm_apply] at this
    exact absurd hab (not_lt.2 this)
  ext i
  have h1 : i ≤ w i := hmono.le_apply
  have h2 : i ≤ w.symm i := hsymm.le_apply
  have h3 : w i ≤ i := by
    have := hmono.monotone h2
    rwa [Equiv.apply_symm_apply] at this
  exact congrArg Fin.val (le_antisymm h3 h1)

/-- A permutation of `Fin N` with no inversions is the identity. -/
theorem invCount_eq_zero_iff {N : ℕ} (w : Equiv.Perm (Fin N)) : invCount w = 0 ↔ w = 1 := by
  constructor
  · intro h
    refine eq_one_of_strictMono ?_
    intro a b hab
    rcases lt_trichotomy (w a) (w b) with h1 | h1 | h1
    · exact h1
    · exact absurd (w.injective h1) (ne_of_lt hab)
    · exfalso
      have hmem : (a, b) ∈ invPairs w := mem_invPairs.mpr ⟨hab, h1⟩
      have hpos : 0 < (invPairs w).card := Finset.card_pos.mpr ⟨_, hmem⟩
      rw [card_invPairs, h] at hpos
      exact lt_irrefl _ hpos
  · rintro rfl
    exact invCount_refl N

/-- A non-identity permutation has a descent at some adjacent pair. -/
theorem exists_descent {w : Equiv.Perm (Fin (n + 1))} (hw : w ≠ 1) :
    ∃ i : Fin n, w i.succ < w i.castSucc := by
  by_contra hc
  push_neg at hc
  have hmono : StrictMono w := by
    refine Fin.strictMono_iff_lt_succ.mpr fun i => ?_
    rcases lt_or_eq_of_le (hc i) with h | h
    · exact h
    · exact absurd (w.injective h) Fin.castSucc_lt_succ.ne
  refine hw ?_
  have hzero : invCount w = 0 := by
    rw [← card_invPairs, Finset.card_eq_zero, Finset.eq_empty_iff_forall_notMem]
    rintro ⟨a, b⟩ hab
    obtain ⟨h1, h2⟩ := mem_invPairs.mp hab
    exact absurd (hmono h1) (not_lt.2 h2.le)
  exact (invCount_eq_zero_iff w).mp hzero

/-! ### Words in the simple reflections -/

/-- The product of the adjacent transpositions listed by `L`. -/
def wordProd (L : List (Fin n)) : Equiv.Perm (Fin (n + 1)) := (L.map adjGen).prod

@[simp] lemma wordProd_nil : wordProd ([] : List (Fin n)) = 1 := rfl

lemma wordProd_append (L : List (Fin n)) (i : Fin n) :
    wordProd (L ++ [i]) = wordProd L * adjGen i := by
  simp [wordProd]

/-- **Existence of a reduced word.**  Every permutation is a product of `invCount w` adjacent
transpositions, obtained by repeatedly cancelling a descent. -/
theorem exists_word (w : Equiv.Perm (Fin (n + 1))) :
    ∃ L : List (Fin n), L.length = invCount w ∧ wordProd L = w := by
  generalize hk : invCount w = k
  induction k using Nat.strong_induction_on generalizing w with
  | _ k ih =>
    rcases eq_or_ne w 1 with rfl | hw
    · refine ⟨[], ?_, rfl⟩
      simp [← hk, (invCount_eq_zero_iff (1 : Equiv.Perm (Fin (n + 1)))).mpr rfl]
    · obtain ⟨i, hi⟩ := exists_descent hw
      have hstep : invCount (w * adjGen i) + 1 = invCount w := invCount_mul_adjGen_of_gt hi
      have hlt : invCount (w * adjGen i) < k := by omega
      obtain ⟨L, hL, hLw⟩ := ih _ hlt (w * adjGen i) rfl
      refine ⟨L ++ [i], ?_, ?_⟩
      · simp [hL]; omega
      · rw [wordProd_append, hLw, mul_assoc, adjGen_mul_self, mul_one]

/-- **Lower bound.**  No word shorter than `invCount w` can represent `w`. -/
theorem invCount_le_length (L : List (Fin n)) : invCount (wordProd L) ≤ L.length := by
  induction L using List.reverseRecOn with
  | nil =>
    rw [List.length_nil, Nat.le_zero, wordProd_nil]
    exact invCount_refl (n + 1)
  | append_singleton L i ih =>
    rw [wordProd_append]
    have := invCount_mul_adjGen_le (wordProd L) i
    simp only [List.length_append, List.length_singleton]
    omega

/-! ### The length function -/

/-- The Coxeter length of a permutation: the minimal number of adjacent transpositions whose
product is `w`. -/
noncomputable def coxLength (w : Equiv.Perm (Fin (n + 1))) : ℕ :=
  sInf {l : ℕ | ∃ L : List (Fin n), L.length = l ∧ wordProd L = w}

/-- **Inversions are Coxeter length.**  The minimal number of adjacent transpositions needed to
write `w` is exactly the number of inversions of `w`; equivalently, the dimension of the Bruhat
cell of `w` in the complete flag variety is `ℓ(w)`. -/
theorem coxLength_eq_invCount (w : Equiv.Perm (Fin (n + 1))) : coxLength w = invCount w := by
  obtain ⟨L, hL, hLw⟩ := exists_word w
  refine le_antisymm (Nat.sInf_le ⟨L, hL, hLw⟩) ?_
  have hne : {l : ℕ | ∃ L : List (Fin n), L.length = l ∧ wordProd L = w}.Nonempty :=
    ⟨L.length, L, rfl, hLw⟩
  obtain ⟨M, hM, hMw⟩ := Nat.sInf_mem hne
  calc invCount w = invCount (wordProd M) := by rw [hMw]
    _ ≤ M.length := invCount_le_length M
    _ = coxLength w := hM

theorem coxLength_eq_zero_iff (w : Equiv.Perm (Fin (n + 1))) : coxLength w = 0 ↔ w = 1 := by
  rw [coxLength_eq_invCount, invCount_eq_zero_iff]

/-- The exchange behaviour of the length function at an ascent. -/
theorem coxLength_mul_adjGen_of_lt {w : Equiv.Perm (Fin (n + 1))} {i : Fin n}
    (h : w i.castSucc < w i.succ) : coxLength (w * adjGen i) = coxLength w + 1 := by
  rw [coxLength_eq_invCount, coxLength_eq_invCount]
  exact invCount_mul_adjGen_of_lt h

/-- The exchange behaviour of the length function at a descent. -/
theorem coxLength_mul_adjGen_of_gt {w : Equiv.Perm (Fin (n + 1))} {i : Fin n}
    (h : w i.succ < w i.castSucc) : coxLength (w * adjGen i) + 1 = coxLength w := by
  rw [coxLength_eq_invCount, coxLength_eq_invCount]
  exact invCount_mul_adjGen_of_gt h

/-! ### Consequences: the Poincaré series of `S_N` -/

/-- **The Poincaré series of the Coxeter group `A_{N-1}`.**
`∑_{w ∈ S_N} q^{ℓ(w)} = [N]_q !`, over an arbitrary commutative semiring. -/
theorem sum_pow_coxLength {R : Type*} [CommSemiring R] (q : R) (N : ℕ) :
    ∑ w : Equiv.Perm (Fin (N + 1)), q ^ coxLength w
      = ∏ j ∈ range (N + 1), ∑ a ∈ range (j + 1), q ^ a := by
  rw [← sum_pow_invCount q (N + 1)]
  exact Finset.sum_congr rfl fun w _ => by rw [coxLength_eq_invCount]

/-- **Coxeter form of the flag-variety point count.**  Over a field with `q` elements, an
`(N+1)`-dimensional vector space has `∑_{w ∈ S_{N+1}} q^{ℓ(w)}` complete flags: the Bruhat cell
of `w` is an affine space of dimension `ℓ(w)`, the Coxeter length of `w`. -/
theorem card_completeFlag_eq_sum_pow_coxLength {K V : Type*} [Field K] [Fintype K]
    [AddCommGroup V] [Module K V] [FiniteDimensional K V] {N : ℕ}
    (hN : N + 1 = Module.finrank K V) :
    Nat.card (CompleteFlag K V (N + 1))
      = ∑ w : Equiv.Perm (Fin (N + 1)), (Fintype.card K) ^ coxLength w := by
  rw [card_completeFlag_eq_sum_pow_invCount hN]
  exact Finset.sum_congr rfl fun w _ => by rw [coxLength_eq_invCount]

/-- The sign of a permutation is the parity of its Coxeter length. -/
theorem sign_eq_neg_one_pow_coxLength (w : Equiv.Perm (Fin (n + 1))) :
    Equiv.Perm.sign w = (-1) ^ coxLength w := by
  rw [coxLength_eq_invCount]
  exact sign_eq_neg_one_pow_invCount w

/-! ### The longest element and the dimension of the flag variety -/

/-- All ordered pairs of distinct indices. -/
def allPairs (N : ℕ) : Finset (Fin N × Fin N) :=
  {p ∈ (univ : Finset (Fin N × Fin N)) | p.1 < p.2}

lemma invPairs_subset_allPairs {N : ℕ} (w : Equiv.Perm (Fin N)) : invPairs w ⊆ allPairs N := by
  intro p hp
  exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, (mem_invPairs.mp hp).1⟩

/-- The reversal permutation inverts *every* pair. -/
lemma invPairs_revPerm (N : ℕ) : invPairs (Fin.revPerm : Equiv.Perm (Fin N)) = allPairs N := by
  ext p
  simp only [mem_invPairs, allPairs, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · exact fun h => h.1
  · exact fun h => ⟨h, Fin.rev_lt_rev.mpr h⟩

lemma card_allPairs (N : ℕ) :
    (allPairs N).card = ∑ i : Fin N, #{j ∈ (univ : Finset (Fin N)) | i < j} := by
  rw [allPairs, Finset.card_filter, Fintype.sum_prod_type]
  exact Finset.sum_congr rfl fun i _ => (Finset.card_filter _ _).symm

lemma card_allPairs_mul_two (N : ℕ) : (allPairs N).card * 2 = N * (N - 1) := by
  have h : ∀ i : Fin N, #{j ∈ (univ : Finset (Fin N)) | i < j} = N - 1 - (i : ℕ) := by
    intro i
    rw [show {j ∈ (univ : Finset (Fin N)) | i < j} = Finset.Ioi i from by ext j; simp]
    simp [Fin.card_Ioi]
  rw [card_allPairs, Finset.sum_congr rfl fun i _ => h i,
    Fin.sum_univ_eq_sum_range (fun i => N - 1 - i) N, Finset.sum_range_reflect (fun i => i) N,
    Finset.sum_range_id_mul_two]

/-- **The longest element.**  The reversal permutation has `N(N-1)/2` inversions: the number of
pairs, i.e. the dimension of the complete flag variety of an `N`-dimensional space. -/
theorem invCount_revPerm_mul_two (N : ℕ) :
    invCount (Fin.revPerm : Equiv.Perm (Fin N)) * 2 = N * (N - 1) := by
  rw [← card_invPairs, invPairs_revPerm, card_allPairs_mul_two]

/-- Every permutation has at most `N(N-1)/2` inversions. -/
theorem invCount_mul_two_le {N : ℕ} (w : Equiv.Perm (Fin N)) :
    invCount w * 2 ≤ N * (N - 1) := by
  rw [← card_allPairs_mul_two N, ← card_invPairs]
  exact Nat.mul_le_mul_right 2 (Finset.card_le_card (invPairs_subset_allPairs w))

/-- **The maximum is attained exactly at the reversal.**  A permutation has the maximal number
of inversions if and only if it is the longest element `w₀`. -/
theorem invCount_mul_two_eq_iff {N : ℕ} (w : Equiv.Perm (Fin N)) :
    invCount w * 2 = N * (N - 1) ↔ w = Fin.revPerm := by
  constructor
  · intro h
    have hcard : (allPairs N).card ≤ (invPairs w).card := by
      have h2 := card_allPairs_mul_two N
      rw [← card_invPairs] at h
      omega
    have hset : invPairs w = allPairs N :=
      Finset.eq_of_subset_of_card_le (invPairs_subset_allPairs w) hcard
    have hmono : StrictMono (fun a : Fin N => w a.rev) := by
      intro a b hab
      have hmem : (b.rev, a.rev) ∈ invPairs w := by
        rw [hset]
        exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, Fin.rev_lt_rev.mpr hab⟩
      exact (mem_invPairs.mp hmem).2
    have hmul : w * Fin.revPerm = 1 := eq_one_of_strictMono hmono
    have hinv : (Fin.revPerm : Equiv.Perm (Fin N)) * Fin.revPerm = 1 := by
      ext i; simp
    calc w = w * ((Fin.revPerm : Equiv.Perm (Fin N)) * Fin.revPerm) := by rw [hinv, mul_one]
      _ = (w * Fin.revPerm) * Fin.revPerm := (mul_assoc _ _ _).symm
      _ = Fin.revPerm := by rw [hmul, one_mul]
  · rintro rfl
    exact invCount_revPerm_mul_two N

/-- **The dimension of the complete flag variety.**  The Coxeter length of the longest element
of `S_{N+1}` is `(N+1)N/2`, which is exactly the dimension of `Fl(K^{N+1})` and the degree of
the `q`-factorial `[N+1]_q !`. -/
theorem coxLength_revPerm_mul_two (N : ℕ) :
    coxLength (Fin.revPerm : Equiv.Perm (Fin (N + 1))) * 2 = (N + 1) * N := by
  rw [coxLength_eq_invCount, invCount_revPerm_mul_two, Nat.add_sub_cancel]

/-- The Coxeter length is bounded by the dimension of the flag variety. -/
theorem coxLength_mul_two_le {N : ℕ} (w : Equiv.Perm (Fin (N + 1))) :
    coxLength w * 2 ≤ (N + 1) * N := by
  rw [coxLength_eq_invCount]
  simpa using invCount_mul_two_le w

/-! ### Inverses and the complementary (Poincaré-dual) cell -/

/-- **Length is inversion-invariant**, `ℓ(w⁻¹) = ℓ(w)`: transposing an inversion `(a, b)` of
`w⁻¹` to `(w⁻¹ b, w⁻¹ a)` is a bijection onto the inversions of `w`. -/
theorem invCount_inv {N : ℕ} (w : Equiv.Perm (Fin N)) : invCount w⁻¹ = invCount w := by
  rw [← card_invPairs, ← card_invPairs]
  refine Finset.card_nbij' (i := fun p => (w⁻¹ p.2, w⁻¹ p.1)) (j := fun p => (w p.2, w p.1))
    ?_ ?_ ?_ ?_
  · rintro ⟨a, b⟩ hp
    obtain ⟨h1, h2⟩ := mem_invPairs.mp hp
    refine mem_invPairs.mpr ⟨h2, ?_⟩
    simpa using h1
  · rintro ⟨a, b⟩ hp
    obtain ⟨h1, h2⟩ := mem_invPairs.mp hp
    refine mem_invPairs.mpr ⟨h2, ?_⟩
    simpa using h1
  · rintro ⟨a, b⟩ _
    simp
  · rintro ⟨a, b⟩ _
    simp

theorem coxLength_inv {N : ℕ} (w : Equiv.Perm (Fin (N + 1))) : coxLength w⁻¹ = coxLength w := by
  rw [coxLength_eq_invCount, coxLength_eq_invCount, invCount_inv]

/-- The inversion set of `w₀ w` is the exact complement of the inversion set of `w`. -/
lemma invPairs_revPerm_mul {N : ℕ} (w : Equiv.Perm (Fin N)) :
    invPairs ((Fin.revPerm : Equiv.Perm (Fin N)) * w) = allPairs N \ invPairs w := by
  ext p
  simp only [mem_invPairs, allPairs, Finset.mem_sdiff, Finset.mem_filter, Finset.mem_univ,
    true_and, Equiv.Perm.mul_apply]
  constructor
  · rintro ⟨h1, h2⟩
    refine ⟨h1, ?_⟩
    rintro ⟨-, h3⟩
    exact absurd (Fin.rev_lt_rev.mp h2) (not_lt.2 h3.le)
  · rintro ⟨h1, h2⟩
    refine ⟨h1, Fin.rev_lt_rev.mpr ?_⟩
    rcases lt_trichotomy (w p.1) (w p.2) with h3 | h3 | h3
    · exact h3
    · exact absurd (w.injective h3) (ne_of_lt h1)
    · exact absurd ⟨h1, h3⟩ h2

/-- **Complementary cells / Poincaré duality for the flag variety.**
`inv (w₀ w) + inv w = N(N-1)/2 = dim Fl`: the Bruhat cells of `w` and `w₀ w` have complementary
dimensions, exactly as the Schubert cells `dimCell_add_dimCell_compl` do on a Grassmannian. -/
theorem invCount_revPerm_mul_add {N : ℕ} (w : Equiv.Perm (Fin N)) :
    (invCount ((Fin.revPerm : Equiv.Perm (Fin N)) * w) + invCount w) * 2 = N * (N - 1) := by
  have hsub := invPairs_subset_allPairs w
  have hcard : (invPairs ((Fin.revPerm : Equiv.Perm (Fin N)) * w)).card
      = (allPairs N).card - (invPairs w).card := by
    rw [invPairs_revPerm_mul, Finset.card_sdiff, Finset.inter_eq_left.mpr hsub]
  have hle : (invPairs w).card ≤ (allPairs N).card := Finset.card_le_card hsub
  have h2 := card_allPairs_mul_two N
  rw [← card_invPairs, ← card_invPairs, hcard]
  omega

theorem coxLength_revPerm_mul_add {N : ℕ} (w : Equiv.Perm (Fin (N + 1))) :
    (coxLength ((Fin.revPerm : Equiv.Perm (Fin (N + 1))) * w) + coxLength w) * 2
      = (N + 1) * N := by
  rw [coxLength_eq_invCount, coxLength_eq_invCount]
  simpa using invCount_revPerm_mul_add w

/-! ### A worked case -/

/-- The longest element of `S₃`, the reversal `w₀ = (0 2)`, has Coxeter length `3`, and
`s₀ s₁ s₀` is a reduced word for it.  (Its Bruhat cell is the top-dimensional cell of
`Fl(𝔽_q³)`, of dimension `3`.) -/
theorem coxLength_longest_three :
    coxLength (Equiv.swap (0 : Fin 3) 2) = 3 ∧
      wordProd [(0 : Fin 2), 1, 0] = Equiv.swap (0 : Fin 3) 2 := by
  refine ⟨?_, by decide⟩
  rw [coxLength_eq_invCount]
  decide

end SchubertCalculus