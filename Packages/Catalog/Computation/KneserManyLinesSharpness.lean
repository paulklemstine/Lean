/-
# Sharpness of the `(k-2)(p-1)` threshold: a counterexample family for every odd prime

`Catalog/Computation/KneserManyLines.lean` refutes the "Kneser input for many
lines" conjecture at the two sample parameters `(p,k) = (3,4)` and `(5,6)`.
This file upgrades those isolated computations to a *uniform* family: for every
odd prime `p` and every `k ≥ 4` there is a pairwise independent family of
directions `v : Fin k → 𝔽_p²` and sets `S i ∋ 0` with

  `∑ i (p - #(S i)) = (k-2)(p-1)`   and   `Reach v S ≠ 𝔽_p²`.

The configuration is the *harmonic quadruple*
`(1,0), (0,1), (1,1), (-1,1)` with `S₁ = S₂ = 𝔽_p \ {1}` and `S₃ = S₄ = {0,1}`;
the point `(1,2)` is never reached.  All remaining directions carry `S i = {0}`,
which costs exactly `p-1` of deficiency each — so the deficiency lands exactly
on the conjectured bound `(k-2)(p-1)`.

Consequently the conjecture fails for *all* `k ≥ 4` and all odd primes, and the
best possible corrected threshold is at most `(k-2)(p-1) - 1`.
-/
import Mathlib
import Computation.KneserManyLines

namespace KneserLines

open Finset

variable {p : ℕ}

section Harmonic

variable [Fact p.Prime]

/-- The four harmonic directions `(1,0), (0,1), (1,1), (-1,1)`. -/
def harmDir (p : ℕ) : Fin 4 → Plane p := ![(1, 0), (0, 1), (1, 1), (-1, 1)]

/-- In `ZMod p` for an odd prime `p`, `2 ≠ 0`. -/
lemma two_ne_zero_of_odd_prime (hp : p.Prime) (hodd : p ≠ 2) : (2 : ZMod p) ≠ 0 := by
  have : ((2 : ℕ) : ZMod p) ≠ 0 := by
    rw [Ne, ZMod.natCast_eq_zero_iff]
    intro h
    exact hodd ((Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).mp h)
  simpa using this

lemma harmDir_pairwiseIndep (hp : p.Prime) (hodd : p ≠ 2) :
    PairwiseIndep (harmDir p) := by
  have h2 : (2 : ZMod p) ≠ 0 := two_ne_zero_of_odd_prime hp hodd
  have h1 : (1 : ZMod p) ≠ 0 := one_ne_zero
  intro i j hij
  fin_cases i <;> fin_cases j <;> simp_all [harmDir, det] <;>
    ring_nf <;> simpa using h2

/-- The key arithmetic fact: with `s₃, s₄ ∈ {0,1}` the point `(1,2)` forces one of
`s₁, s₂` to be `1`. -/
lemma harmonic_blocked (s0 s1 s2 s3 : ZMod p)
    (h2 : s2 = 0 ∨ s2 = 1) (h3 : s3 = 0 ∨ s3 = 1)
    (e1 : s0 + s2 - s3 = 1) (e2 : s1 + s2 + s3 = 2) :
    s0 = 1 ∨ s1 = 1 := by
  rcases h2 with h2 | h2 <;> rcases h3 with h3 | h3 <;> rw [h2, h3] at e1 e2
  · exact Or.inl (by linear_combination e1)
  · exact Or.inr (by linear_combination e2)
  · exact Or.inr (by linear_combination e2)
  · exact Or.inl (by linear_combination e1)

end Harmonic

/-- **Sharpness at `k = 4`.**  For every odd prime `p` there is a pairwise
independent quadruple of directions and sets `S i ∋ 0` with total deficiency
exactly `(4-2)(p-1)` whose reach is not the whole plane. -/
theorem counterexample_four_lines (hp : p.Prime) (hodd : p ≠ 2) :
    ∃ (v : Fin 4 → Plane p) (S : Fin 4 → Finset (ZMod p)),
      PairwiseIndep v ∧ (∀ i, (0 : ZMod p) ∈ S i) ∧
      defSum S = (4 - 2) * (p - 1) ∧ Reach v S ≠ Set.univ := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : Nontrivial (ZMod p) := ⟨⟨0, 1, zero_ne_one⟩⟩
  refine ⟨harmDir p, ![univ.erase 1, univ.erase 1, {0, 1}, {0, 1}],
    harmDir_pairwiseIndep hp hodd, ?_, ?_, ?_⟩
  · intro i
    fin_cases i <;> simp [Finset.mem_erase, (zero_ne_one : (0 : ZMod p) ≠ 1)]
  · have hcard : Fintype.card (ZMod p) = p := ZMod.card p
    have he : #((univ : Finset (ZMod p)).erase 1) = p - 1 := by
      rw [Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ, hcard]
    have hzo : (0 : ZMod p) ≠ 1 := zero_ne_one
    have hc2 : #({0, 1} : Finset (ZMod p)) = 2 := by
      rw [Finset.card_insert_of_notMem (by simp [hzo]), Finset.card_singleton]
    have hp2 : 2 ≤ p := hp.two_le
    simp [defSum, Fin.sum_univ_four, he, hc2]
    omega
  · intro hcon
    have : ((1 : ZMod p), (2 : ZMod p)) ∈ Reach (harmDir p)
        ![univ.erase 1, univ.erase 1, {0, 1}, {0, 1}] := hcon ▸ Set.mem_univ _
    obtain ⟨s, hs, hsum⟩ := this
    have hs0 : s 0 ∈ (univ : Finset (ZMod p)).erase 1 := by simpa using hs 0
    have hs1 : s 1 ∈ (univ : Finset (ZMod p)).erase 1 := by simpa using hs 1
    have hs2 : s 2 = 0 ∨ s 2 = 1 := by simpa [Finset.mem_insert] using hs 2
    have hs3 : s 3 = 0 ∨ s 3 = 1 := by simpa [Finset.mem_insert] using hs 3
    rw [Fin.sum_univ_four] at hsum
    simp only [harmDir, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
      Matrix.cons_val_two, Matrix.tail_cons, Matrix.cons_val_three, Prod.smul_mk,
      smul_eq_mul, Prod.mk_add_mk, Prod.mk.injEq] at hsum
    obtain ⟨e1, e2⟩ := hsum
    have e1' : s 0 + s 2 - s 3 = 1 := by linear_combination e1
    have e2' : s 1 + s 2 + s 3 = 2 := by linear_combination e2
    rcases harmonic_blocked _ _ _ _ hs2 hs3 e1' e2' with h | h
    · exact (Finset.mem_erase.mp hs0).1 h
    · exact (Finset.mem_erase.mp hs1).1 h


/-!
### The uniform counterexample family for every `k` with `4 ≤ k ≤ p+1`

We realise the harmonic quadruple inside a full pairwise independent family of
`k` directions.  Index `0 ↦ (1,0)`, `1 ↦ (0,1)`, `2 ↦ (1,1)`, `3 ↦ (-1,1)` and
index `j ≥ 4 ↦ (1, j-2)`; the slope labels `lab` are pairwise distinct elements
of `𝔽_p` avoiding `0, 1, -1`, which is possible exactly when `k ≤ p + 1`
(the projective line over `𝔽_p` has `p+1` points, so this is the full range in
which a pairwise independent `k`-family exists at all).
-/

section Uniform

def lab (j : ℕ) : ℕ := if j = 0 then 0 else if j = 2 then 1 else j - 2

lemma lab_ne_of_ne {a b : ℕ} (ha1 : a ≠ 1) (ha3 : a ≠ 3) (hb1 : b ≠ 1) (hb3 : b ≠ 3)
    (hab : a ≠ b) : lab a ≠ lab b := by
  unfold lab; split_ifs <;> omega

lemma lab_le {j k q : ℕ} (hj : j < k) (hkp : k ≤ q + 1) (hq : 3 ≤ q) : lab j ≤ q - 2 := by
  unfold lab; split_ifs <;> omega

variable [Fact p.Prime]

lemma cast_ne_zero_of_pos_lt {n : ℕ} (h0 : 0 < n) (hn : n < p) : ((n : ℕ) : ZMod p) ≠ 0 := by
  intro hz
  have := ZMod.val_cast_of_lt hn
  rw [hz, ZMod.val_zero] at this
  omega

lemma cast_ne_cast {a b : ℕ} (ha : a < p) (hb : b < p) (hab : a ≠ b) :
    ((a : ℕ) : ZMod p) ≠ ((b : ℕ) : ZMod p) := by
  intro hz
  have h1 := ZMod.val_cast_of_lt ha
  have h2 := ZMod.val_cast_of_lt hb
  rw [hz, h2] at h1
  exact hab h1.symm

def manyDir (p k : ℕ) (i : Fin k) : Plane p :=
  if (i : ℕ) = 1 then (0, 1) else if (i : ℕ) = 3 then (-1, 1) else (1, ((lab i : ℕ) : ZMod p))

lemma manyDir_other {k : ℕ} {i : Fin k} (h1 : (i:ℕ) ≠ 1) (h3 : (i:ℕ) ≠ 3) :
    manyDir p k i = (1, ((lab i : ℕ) : ZMod p)) := by
  simp [manyDir, h1, h3]

lemma manyDir_pairwiseIndep {k : ℕ} (hq : 3 ≤ p) (hkp : k ≤ p + 1) :
    PairwiseIndep (manyDir p k) := by
  intro i j hij
  have hij' : (i:ℕ) ≠ (j:ℕ) := fun h => hij (Fin.ext h)
  by_cases hi1 : (i:ℕ) = 1
  · by_cases hj3 : (j:ℕ) = 3
    · simp [manyDir, hi1, hj3, det]
    · have hj1 : (j:ℕ) ≠ 1 := by omega
      rw [manyDir, manyDir_other hj1 hj3]
      simp [hi1, det]
  · by_cases hi3 : (i:ℕ) = 3
    · by_cases hj1 : (j:ℕ) = 1
      · simp [manyDir, hi3, hj1, det]
      · have hj3 : (j:ℕ) ≠ 3 := by omega
        rw [manyDir, manyDir_other hj1 hj3]
        have hb : ((lab j : ℕ) : ZMod p) + 1 ≠ 0 := by
          have hle : lab j ≤ p - 2 := lab_le j.isLt hkp hq
          have : ((lab j + 1 : ℕ) : ZMod p) ≠ 0 := cast_ne_zero_of_pos_lt (by omega) (by omega)
          simpa using this
        rw [if_neg hi1, if_pos hi3]
        simp only [det]
        intro hc
        exact hb (by linear_combination -hc)
    · by_cases hj1 : (j:ℕ) = 1
      · rw [manyDir_other hi1 hi3, manyDir]
        simp [hj1, det]
      · by_cases hj3 : (j:ℕ) = 3
        · rw [manyDir_other hi1 hi3, manyDir]
          have hb : ((lab i : ℕ) : ZMod p) + 1 ≠ 0 := by
            have hle : lab i ≤ p - 2 := lab_le i.isLt hkp hq
            have : ((lab i + 1 : ℕ) : ZMod p) ≠ 0 := cast_ne_zero_of_pos_lt (by omega) (by omega)
            simpa using this
          rw [if_neg hj1, if_pos hj3]
          simp only [det]
          intro hc
          exact hb (by linear_combination hc)
        · rw [manyDir_other hi1 hi3, manyDir_other hj1 hj3]
          have hne : lab i ≠ lab j := lab_ne_of_ne hi1 hi3 hj1 hj3 hij'
          have hli : lab i ≤ p - 2 := lab_le i.isLt hkp hq
          have hlj : lab j ≤ p - 2 := lab_le j.isLt hkp hq
          have := cast_ne_cast (p := p) (by omega : lab i < p) (by omega : lab j < p) hne
          simp only [det]
          intro hc
          exact this (by linear_combination -hc)

def manySet (p k : ℕ) [NeZero p] (i : Fin k) : Finset (ZMod p) :=
  if (i:ℕ) = 0 ∨ (i:ℕ) = 1 then Finset.univ.erase 1
  else if (i:ℕ) = 2 ∨ (i:ℕ) = 3 then {0, 1} else {0}

lemma manySet_card_erase : #((univ : Finset (ZMod p)).erase 1) = p - 1 := by
  rw [Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ, ZMod.card]

/-- Total deficiency of the counterexample family is exactly `(k-2)(p-1)`. -/
lemma manySet_defSum {k : ℕ} (hq : 3 ≤ p) (hk : 4 ≤ k) :
    defSum (manySet p k) = (k - 2) * (p - 1) := by
  classical
  have hzo : (0 : ZMod p) ≠ 1 := zero_ne_one
  have hc2 : #({0, 1} : Finset (ZMod p)) = 2 := by
    rw [Finset.card_insert_of_notMem (by simp [hzo]), Finset.card_singleton]
  set i0 : Fin k := ⟨0, by omega⟩ with hi0
  set i1 : Fin k := ⟨1, by omega⟩ with hi1
  set i2 : Fin k := ⟨2, by omega⟩ with hi2
  set i3 : Fin k := ⟨3, by omega⟩ with hi3
  set T : Finset (Fin k) := {i0, i1, i2, i3} with hT
  have hmemT : ∀ i : Fin k, i ∈ T ↔ ((i:ℕ) = 0 ∨ (i:ℕ) = 1 ∨ (i:ℕ) = 2 ∨ (i:ℕ) = 3) := by
    intro i; simp [hT, hi0, hi1, hi2, hi3, Fin.ext_iff]
  have hcardT : #T = 4 := by
    rw [hT, Finset.card_insert_of_notMem (by simp [hi0, hi1, hi2, hi3, Fin.ext_iff]),
      Finset.card_insert_of_notMem (by simp [hi1, hi2, hi3, Fin.ext_iff]),
      Finset.card_insert_of_notMem (by simp [hi2, hi3, Fin.ext_iff]), Finset.card_singleton]
  have hTsum : ∀ f : Fin k → ℕ, ∑ i ∈ T, f i = f i0 + f i1 + f i2 + f i3 := by
    intro f
    rw [hT, Finset.sum_insert (by simp [hi0, hi1, hi2, hi3, Fin.ext_iff]),
      Finset.sum_insert (by simp [hi1, hi2, hi3, Fin.ext_iff]),
      Finset.sum_insert (by simp [hi2, hi3, Fin.ext_iff]), Finset.sum_singleton,
      ← add_assoc, ← add_assoc]
  have hsplit := Finset.sum_sdiff (f := fun i => p - #(manySet p k i)) (Finset.subset_univ T)
  have hout : ∑ i ∈ univ \ T, (p - #(manySet p k i)) = (k - 4) * (p - 1) := by
    rw [Finset.sum_congr rfl (g := fun _ => p - 1) ?_]
    · rw [Finset.sum_const, Finset.card_sdiff_of_subset (Finset.subset_univ T),
        Finset.card_univ, Fintype.card_fin, hcardT, smul_eq_mul]
    · intro i hi
      have hni : ¬ (i ∈ T) := (Finset.mem_sdiff.mp hi).2
      rw [hmemT] at hni
      push_neg at hni
      simp [manySet, hni.1, hni.2.1, hni.2.2.1, hni.2.2.2]
  have hin : ∑ i ∈ T, (p - #(manySet p k i)) = 1 + 1 + (p - 2) + (p - 2) := by
    rw [hTsum]
    simp only [manySet, hi0, hi1, hi2, hi3]
    norm_num [manySet_card_erase, hc2]
    omega
  rw [defSum, ← hsplit, hout, hin]
  have h2 : k - 2 = (k - 4) + 2 := by omega
  rw [h2, add_mul]
  generalize (k - 4) * (p - 1) = c
  omega

/-- The point `(1,2)` is not reachable by the counterexample family. -/
lemma manySet_reach_ne_univ {k : ℕ} (hk : 4 ≤ k) :
    Reach (manyDir p k) (manySet p k) ≠ Set.univ := by
  classical
  set i0 : Fin k := ⟨0, by omega⟩ with hi0
  set i1 : Fin k := ⟨1, by omega⟩ with hi1
  set i2 : Fin k := ⟨2, by omega⟩ with hi2
  set i3 : Fin k := ⟨3, by omega⟩ with hi3
  set T : Finset (Fin k) := {i0, i1, i2, i3} with hT
  have hmemT : ∀ i : Fin k, i ∈ T ↔ ((i:ℕ) = 0 ∨ (i:ℕ) = 1 ∨ (i:ℕ) = 2 ∨ (i:ℕ) = 3) := by
    intro i; simp [hT, hi0, hi1, hi2, hi3, Fin.ext_iff]
  have hTsum : ∀ f : Fin k → Plane p, ∑ i ∈ T, f i = f i0 + f i1 + f i2 + f i3 := by
    intro f
    rw [hT, Finset.sum_insert (by simp [hi0, hi1, hi2, hi3, Fin.ext_iff]),
      Finset.sum_insert (by simp [hi1, hi2, hi3, Fin.ext_iff]),
      Finset.sum_insert (by simp [hi2, hi3, Fin.ext_iff]), Finset.sum_singleton,
      ← add_assoc, ← add_assoc]
  intro hcon
  have hmem : ((1 : ZMod p), (2 : ZMod p)) ∈ Reach (manyDir p k) (manySet p k) :=
    hcon ▸ Set.mem_univ _
  obtain ⟨s, hs, hsum⟩ := hmem
  have hzero : ∀ i ∈ (univ : Finset (Fin k)), i ∉ T → s i • manyDir p k i = 0 := by
    intro i _ hi
    rw [hmemT] at hi
    push_neg at hi
    have hsi : s i ∈ manySet p k i := hs i
    rw [manySet, if_neg (by tauto), if_neg (by tauto)] at hsi
    simp only [Finset.mem_singleton] at hsi
    rw [hsi, zero_smul]
  rw [← Finset.sum_subset (Finset.subset_univ T) hzero, hTsum] at hsum
  have hs0 : s i0 ∈ (univ : Finset (ZMod p)).erase 1 := by
    have := hs i0; rwa [manySet, if_pos (by left; simp [hi0])] at this
  have hs1 : s i1 ∈ (univ : Finset (ZMod p)).erase 1 := by
    have := hs i1; rwa [manySet, if_pos (by right; simp [hi1])] at this
  have hs2 : s i2 = 0 ∨ s i2 = 1 := by
    have := hs i2
    rw [manySet, if_neg (by simp [hi2]), if_pos (by left; simp [hi2])] at this
    simpa [Finset.mem_insert] using this
  have hs3 : s i3 = 0 ∨ s i3 = 1 := by
    have := hs i3
    rw [manySet, if_neg (by simp [hi3]), if_pos (by right; simp [hi3])] at this
    simpa [Finset.mem_insert] using this
  have d0 : manyDir p k i0 = ((1 : ZMod p), (0 : ZMod p)) := by
    rw [manyDir_other (by simp [hi0]) (by simp [hi0])]
    simp [hi0, lab]
  have d1 : manyDir p k i1 = ((0 : ZMod p), (1 : ZMod p)) := by
    rw [manyDir, if_pos (by simp [hi1])]
  have d2 : manyDir p k i2 = ((1 : ZMod p), (1 : ZMod p)) := by
    rw [manyDir_other (by simp [hi2]) (by simp [hi2])]
    simp [hi2, lab]
  have d3 : manyDir p k i3 = ((-1 : ZMod p), (1 : ZMod p)) := by
    rw [manyDir, if_neg (by simp [hi3]), if_pos (by simp [hi3])]
  rw [d0, d1, d2, d3] at hsum
  simp only [Prod.smul_mk, smul_eq_mul, Prod.mk_add_mk, Prod.mk.injEq, mul_zero, mul_one] at hsum
  obtain ⟨e1, e2⟩ := hsum
  have e1' : s i0 + s i2 - s i3 = 1 := by linear_combination e1
  have e2' : s i1 + s i2 + s i3 = 2 := by linear_combination e2
  rcases harmonic_blocked _ _ _ _ hs2 hs3 e1' e2' with h | h
  · exact (Finset.mem_erase.mp hs0).1 h
  · exact (Finset.mem_erase.mp hs1).1 h

lemma manySet_mem_zero {k : ℕ} (i : Fin k) : (0 : ZMod p) ∈ manySet p k i := by
  unfold manySet
  split_ifs <;> simp [(zero_ne_one : (0 : ZMod p) ≠ 1), Finset.mem_erase]

/-- **Sharpness for every admissible `k`.**  For every prime `p ≥ 3` and every
`k` with `4 ≤ k ≤ p + 1` there is a pairwise independent family of `k`
directions and sets `S i ∋ 0` of total deficiency exactly `(k-2)(p-1)` whose
reach is not the whole plane.  Since a pairwise independent family in `𝔽_p²`
has at most `p + 1` members, this covers the entire feasible range of `k`. -/
theorem counterexample_many_lines {k : ℕ} (hq : 3 ≤ p) (hk : 4 ≤ k) (hkp : k ≤ p + 1) :
    ∃ (v : Fin k → Plane p) (S : Fin k → Finset (ZMod p)),
      PairwiseIndep v ∧ (∀ i, (0 : ZMod p) ∈ S i) ∧
      defSum S = (k - 2) * (p - 1) ∧ Reach v S ≠ Set.univ :=
  ⟨manyDir p k, manySet p k, manyDir_pairwiseIndep hq hkp, manySet_mem_zero,
    manySet_defSum hq hk, manySet_reach_ne_univ hk⟩

/-!
### Optimality of the triple criterion

`KneserManyLines.reach_eq_univ_of_triple` says that if *some* three distinct
indices `i, j, l` satisfy `d i + d j + d l < p` (where `d i = p - #(S i)`) then
the reach is all of `𝔽_p²`.  The family above shows that the strict inequality
cannot be relaxed to `≤ p`: every triple of distinct indices has deficiency sum
at least `p`, and the minimum `p` is attained.
-/

lemma manySet_defect_dichotomy {k : ℕ} (hq : 3 ≤ p) (i : Fin k) :
    ((i : ℕ) ≤ 1 ∧ p - #(manySet p k i) = 1) ∨
      (2 ≤ (i : ℕ) ∧ p - 2 ≤ p - #(manySet p k i)) := by
  classical
  have hzo : (0 : ZMod p) ≠ 1 := zero_ne_one
  have hc2 : #({0, 1} : Finset (ZMod p)) = 2 := by
    rw [Finset.card_insert_of_notMem (by simp [hzo]), Finset.card_singleton]
  by_cases h01 : (i : ℕ) = 0 ∨ (i : ℕ) = 1
  · left
    refine ⟨by omega, ?_⟩
    rw [manySet, if_pos h01, manySet_card_erase]
    omega
  · right
    refine ⟨by omega, ?_⟩
    by_cases h23 : (i : ℕ) = 2 ∨ (i : ℕ) = 3
    · rw [manySet, if_neg h01, if_pos h23, hc2]
    · rw [manySet, if_neg h01, if_neg h23, Finset.card_singleton]
      omega

/-- Every triple of distinct indices of the counterexample family has total
deficiency at least `p`. -/
lemma manySet_triple_defect {k : ℕ} (hq : 3 ≤ p) {i j l : Fin k}
    (hij : i ≠ j) (hil : i ≠ l) (hjl : j ≠ l) :
    p ≤ (p - #(manySet p k i)) + (p - #(manySet p k j)) + (p - #(manySet p k l)) := by
  have hij' : (i : ℕ) ≠ (j : ℕ) := fun h => hij (Fin.ext h)
  have hil' : (i : ℕ) ≠ (l : ℕ) := fun h => hil (Fin.ext h)
  have hjl' : (j : ℕ) ≠ (l : ℕ) := fun h => hjl (Fin.ext h)
  rcases manySet_defect_dichotomy hq i with hi | hi <;>
    rcases manySet_defect_dichotomy hq j with hj | hj <;>
      rcases manySet_defect_dichotomy hq l with hl | hl <;> omega

/-- **The triple criterion is sharp.**  For every `p ≥ 3` and every `k` in the
range `4 ≤ k ≤ p + 1` there is a pairwise independent family of directions and
sets containing `0` such that *every* triple of distinct indices has deficiency
sum at least `p`, the value `p` is attained by some triple, and the reach is
still not the whole plane.  Hence the strict inequality `< p` in
`reach_eq_univ_of_triple` cannot be weakened to `≤ p`. -/
theorem triple_criterion_sharp {k : ℕ} (hq : 3 ≤ p) (hk : 4 ≤ k) (hkp : k ≤ p + 1) :
    ∃ (v : Fin k → Plane p) (S : Fin k → Finset (ZMod p)),
      PairwiseIndep v ∧ (∀ i, (0 : ZMod p) ∈ S i) ∧
      (∀ i j l : Fin k, i ≠ j → i ≠ l → j ≠ l →
        p ≤ (p - #(S i)) + (p - #(S j)) + (p - #(S l))) ∧
      (∃ i j l : Fin k, i ≠ j ∧ i ≠ l ∧ j ≠ l ∧
        (p - #(S i)) + (p - #(S j)) + (p - #(S l)) = p) ∧
      Reach v S ≠ Set.univ := by
  refine ⟨manyDir p k, manySet p k, manyDir_pairwiseIndep hq hkp, manySet_mem_zero, ?_, ?_, ?_⟩
  · intro i j l hij hil hjl
    exact manySet_triple_defect hq hij hil hjl
  · refine ⟨⟨0, by omega⟩, ⟨1, by omega⟩, ⟨2, by omega⟩, by simp [Fin.ext_iff],
      by simp [Fin.ext_iff], by simp [Fin.ext_iff], ?_⟩
    have hzo : (0 : ZMod p) ≠ 1 := zero_ne_one
    have hc2 : #({0, 1} : Finset (ZMod p)) = 2 := by
      rw [Finset.card_insert_of_notMem (by simp [hzo]), Finset.card_singleton]
    rw [manySet, if_pos (by left; rfl), manySet, if_pos (by right; rfl), manySet,
      if_neg (by simp), if_pos (by left; rfl), manySet_card_erase, hc2]
    omega
  · exact manySet_reach_ne_univ hk

end Uniform

end KneserLines