/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.SchubertCalculus.CellCount

/-!
# Schubert calculus X: the point count of the complete flag variety

This file completes Conjecture 1 of `FUTURE_DIRECTIONS.md` by counting the complete flags of
an `N`-dimensional vector space over a finite field with `q` elements:

`#Fl(V) = [N]_q ! = ∏_{j=1}^{N} (1 + q + ⋯ + q^{j-1})`.

The proof is a second fibration argument, this time over the space of ordered bases.  A basis
`s` produces the flag of its prefix spans (`SchubertCalculus.flagOfBasis`), and the fibre over
a flag `F` consists exactly of the *adapted* bases, those with `sᵢ ∈ F_{i+1} \ F_i`; the
`i`-th vector may be chosen freely and independently in `F_{i+1} \ F_i`, so the fibre is a
product of `q^{i+1} - q^i` choices (`SchubertCalculus.flagFiberEquiv`).  Comparing with
Mathlib's count of independent `N`-tuples and factoring
`q^N - q^i = (q^{i+1} - q^i)(1 + q + ⋯ + q^{N-i-1})` gives the `q`-factorial.

Main results:

* `SchubertCalculus.span_prefix_eq_part` : an adapted family recovers the flag as its prefix
  spans;
* `SchubertCalculus.flagFiberEquiv` : the bases inducing a given flag are exactly the adapted
  ones, and they form a product of affine punctured spaces;
* `SchubertCalculus.card_flag_mul` : the two-way count of independent `N`-tuples;
* `SchubertCalculus.card_completeFlag_eq_qFactorial` : **the point count**
  `#Fl(V) = [N]_q !`;
* `SchubertCalculus.card_completeFlag_two_three` : `Fl(𝔽₂³)` has `21` points.
-/

namespace SchubertCalculus

open Finset Module Submodule

/-! ### The `q`-factorial -/

/-- The `q`-factorial `[N]_q ! = ∏_{j=1}^{N} (1 + q + ⋯ + q^{j-1})`, the point count of the
complete flag variety. -/
def qFactorial (q N : ℕ) : ℕ := ∏ j ∈ range N, ∑ a ∈ range (j + 1), q ^ a

lemma geom_nat (q m : ℕ) (hq : 1 ≤ q) : (q - 1) * ∑ a ∈ range m, q ^ a = q ^ m - 1 := by
  induction m with
  | zero => simp
  | succ m ih =>
      have h1 : 1 ≤ q ^ m := Nat.one_le_pow _ _ (by omega)
      have h2 : q ^ m ≤ q ^ (m + 1) := Nat.pow_le_pow_right (by omega) (by omega)
      have h3 : (q - 1) * q ^ m = q ^ (m + 1) - q ^ m := by
        rw [Nat.sub_mul, one_mul, ← pow_succ']
      rw [Finset.sum_range_succ, Nat.mul_add, ih, h3]
      omega

/-- The termwise factorisation `q^N - q^i = (q^{i+1} - q^i)(1 + q + ⋯ + q^{N-i-1})`. -/
lemma pow_sub_pow_factor {q N i : ℕ} (hq : 1 ≤ q) (hi : i ≤ N) :
    q ^ N - q ^ i = (q ^ (i + 1) - q ^ i) * ∑ a ∈ range (N - i), q ^ a := by
  have h1 : q ^ (i + 1) - q ^ i = q ^ i * (q - 1) := by
    rw [Nat.mul_sub, mul_one, ← pow_succ]
  rw [h1, mul_assoc, geom_nat q (N - i) hq, Nat.mul_sub, mul_one, ← pow_add,
    Nat.add_sub_cancel' hi]

/-- The product of `q^N - q^i` factors as the product of `q^{i+1} - q^i` times the
`q`-factorial. -/
theorem prod_pow_sub_pow (q N : ℕ) (hq : 1 ≤ q) :
    ∏ i ∈ range N, (q ^ N - q ^ i)
      = (∏ i ∈ range N, (q ^ (i + 1) - q ^ i)) * qFactorial q N := by
  have h : ∀ i ∈ range N, q ^ N - q ^ i
      = (q ^ (i + 1) - q ^ i) * ∑ a ∈ range (N - i), q ^ a := fun i hi =>
    pow_sub_pow_factor hq (le_of_lt (Finset.mem_range.mp hi))
  rw [Finset.prod_congr rfl h, Finset.prod_mul_distrib, qFactorial]
  congr 1
  rw [← Finset.prod_range_reflect (fun j => ∑ a ∈ range (j + 1), q ^ a) N]
  refine Finset.prod_congr rfl fun i hi => ?_
  have hiN : i < N := Finset.mem_range.mp hi
  congr 2
  omega

/-! ### Prefix spans -/

section Prefix

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V] {N : ℕ}

/-- The set of indices of a family that are smaller than `j`. -/
def prefixSet (N j : ℕ) : Set (Fin N) := {i : Fin N | (i : ℕ) < j}

instance (N j : ℕ) : Fintype (prefixSet N j) := by unfold prefixSet; infer_instance

/-- `prefixSet N j` has `min j N` elements. -/
def prefixSetEquiv (N j : ℕ) : prefixSet N j ≃ Fin (min j N) where
  toFun i := ⟨i.1, lt_min i.2 i.1.2⟩
  invFun a := ⟨⟨a.1, lt_of_lt_of_le a.2 (min_le_right j N)⟩, lt_of_lt_of_le a.2 (min_le_left j N)⟩
  left_inv _ := rfl
  right_inv _ := rfl

lemma card_prefixSet (N j : ℕ) : Fintype.card (prefixSet N j) = min j N := by
  rw [Fintype.card_congr (prefixSetEquiv N j), Fintype.card_fin]

lemma prefixSet_eq_univ {N j : ℕ} (hj : N ≤ j) : prefixSet N j = Set.univ := by
  ext i
  simp only [prefixSet, Set.mem_setOf_eq, Set.mem_univ, iff_true]
  omega

lemma prefixSet_mono {N j j' : ℕ} (h : j ≤ j') : prefixSet N j ⊆ prefixSet N j' :=
  fun _ hi => lt_of_lt_of_le hi h

lemma prefixSet_succ {N j : ℕ} (hj : j < N) :
    prefixSet N (j + 1) = insert (⟨j, hj⟩ : Fin N) (prefixSet N j) := by
  ext i
  simp only [prefixSet, Set.mem_setOf_eq, Set.mem_insert_iff]
  constructor
  · intro h
    rcases Nat.lt_succ_iff_lt_or_eq.mp h with h' | h'
    · exact Or.inr h'
    · exact Or.inl (Fin.ext h')
  · rintro (rfl | h)
    · simp
    · omega

lemma notMem_prefixSet_self {N : ℕ} (i : Fin N) : i ∉ prefixSet N (i : ℕ) := by
  simp [prefixSet]

lemma finrank_span_image {s : Fin N → V} (hs : LinearIndependent K s) (t : Set (Fin N))
    [Fintype t] : finrank K (Submodule.span K (s '' t)) = Fintype.card t := by
  have h : s '' t = Set.range (s ∘ (Subtype.val : t → Fin N)) := by
    rw [Set.range_comp, Subtype.range_coe]
  rw [h, finrank_span_eq_card (hs.comp Subtype.val Subtype.val_injective)]

variable [FiniteDimensional K V]

/-- The complete flag of prefix spans of an independent family of the right size. -/
def flagOfBasis (s : Fin N → V) (hs : LinearIndependent K s) (hN : N = finrank K V) :
    CompleteFlag K V N where
  part j := Submodule.span K (s '' prefixSet N j)
  mono := fun _ _ h => Submodule.span_mono (Set.image_mono (prefixSet_mono h))
  finrank_part := fun j hj => by
    rw [finrank_span_image hs, card_prefixSet, min_eq_left hj]
  part_top := by
    apply Submodule.eq_top_of_finrank_eq
    rw [finrank_span_image hs, card_prefixSet, min_self, hN]

@[simp] lemma flagOfBasis_part (s : Fin N → V) (hs : LinearIndependent K s)
    (hN : N = finrank K V) (j : ℕ) :
    (flagOfBasis s hs hN).part j = Submodule.span K (s '' prefixSet N j) := rfl

/-- **Recovery of a flag from an adapted family.**  If `sᵢ ∈ F_{i+1} \ F_i` for all `i`, then
the prefix spans of `s` are the members of the flag. -/
theorem span_prefix_eq_part (Fl : CompleteFlag K V N) (s : Fin N → V)
    (hs : ∀ i : Fin N, s i ∈ Fl.part ((i : ℕ) + 1) ∧ s i ∉ Fl.part (i : ℕ)) :
    ∀ j, j ≤ N → Submodule.span K (s '' prefixSet N j) = Fl.part j := by
  intro j
  induction j with
  | zero =>
      intro _
      rw [show prefixSet N 0 = ∅ by ext i; simp [prefixSet], Set.image_empty,
        Submodule.span_empty, Fl.part_zero]
  | succ j ih =>
      intro hj
      have hjN : j < N := hj
      have hprev := ih hjN.le
      rw [prefixSet_succ hjN, Set.image_insert_eq, Submodule.span_insert, hprev]
      have hmem := hs ⟨j, hjN⟩
      have hle : Submodule.span K {s ⟨j, hjN⟩} ⊔ Fl.part j ≤ Fl.part (j + 1) := by
        refine sup_le ?_ (Fl.mono (Nat.le_succ j))
        rw [Submodule.span_le, Set.singleton_subset_iff]
        exact hmem.1
      have hlt : Fl.part j < Submodule.span K {s ⟨j, hjN⟩} ⊔ Fl.part j := by
        refine lt_of_le_of_ne le_sup_right fun h => hmem.2 ?_
        exact h ▸ (le_sup_left (a := Submodule.span K {s ⟨j, hjN⟩}))
          (Submodule.mem_span_singleton_self _)
      have h1 : finrank K (Fl.part j) = j := Fl.finrank_part j hjN.le
      have h2 : finrank K (Fl.part (j + 1)) = j + 1 := Fl.finrank_part (j + 1) hj
      have h3 := Submodule.finrank_lt_finrank_of_lt hlt
      have h4 := Submodule.finrank_mono hle
      exact Submodule.eq_of_le_of_finrank_eq hle (by omega)

/-- An adapted family spans the whole space. -/
lemma adapted_span_top (Fl : CompleteFlag K V N) (s : Fin N → V)
    (hs : ∀ i : Fin N, s i ∈ Fl.part ((i : ℕ) + 1) ∧ s i ∉ Fl.part (i : ℕ)) :
    Submodule.span K (Set.range s) = ⊤ := by
  have h := span_prefix_eq_part Fl s hs N le_rfl
  rwa [prefixSet_eq_univ le_rfl, Set.image_univ, Fl.part_top] at h

/-- An adapted family is a basis. -/
lemma adapted_indep (Fl : CompleteFlag K V N) (s : Fin N → V)
    (hs : ∀ i : Fin N, s i ∈ Fl.part ((i : ℕ) + 1) ∧ s i ∉ Fl.part (i : ℕ))
    (hN : N = finrank K V) : LinearIndependent K s := by
  rw [linearIndependent_iff_card_eq_finrank_span, Fintype.card_fin]
  show N = finrank K (Submodule.span K (Set.range s))
  rw [adapted_span_top Fl s hs, finrank_top, hN]

end Prefix

/-! ### Flags are finitely many -/

namespace CompleteFlag

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V] {N : ℕ}

lemma ext' {F G : CompleteFlag K V N} (h : ∀ j, F.part j = G.part j) : F = G := by
  cases F; cases G
  congr 1
  exact funext h

lemma part_eq_top_of_le (F : CompleteFlag K V N) {j : ℕ} (hj : N ≤ j) : F.part j = ⊤ :=
  top_le_iff.mp (F.part_top ▸ F.mono hj)

lemma part_injective : Function.Injective
    (fun F : CompleteFlag K V N => fun j : Fin (N + 1) => F.part j) := by
  intro F G h
  refine ext' fun j => ?_
  by_cases hj : j ≤ N
  · exact congrFun h ⟨j, by omega⟩
  · push_neg at hj
    rw [F.part_eq_top_of_le hj.le, G.part_eq_top_of_le hj.le]

instance [Fintype K] [FiniteDimensional K V] : Finite (CompleteFlag K V N) := by
  haveI : Finite V := Module.finite_of_finite K
  exact Finite.of_injective _ part_injective

end CompleteFlag

/-! ### The fibration over the flag variety -/

section FlagCount

variable {K V : Type*} [Field K] [Fintype K] [AddCommGroup V] [Module K V]
  [FiniteDimensional K V] {N : ℕ}

/-- **The fibre of the basis-to-flag map.**  The bases whose prefix spans give the flag `F`
are exactly the families with `sᵢ ∈ F_{i+1} \ F_i`, chosen independently for each `i`. -/
def flagFiberEquiv (hN : N = finrank K V) (Fl : CompleteFlag K V N) :
    {s : {s : Fin N → V // LinearIndependent K s} // flagOfBasis s.1 s.2 hN = Fl} ≃
      ((i : Fin N) → {v : V //
        v ∈ (Fl.part ((i : ℕ) + 1) : Set V) \ (Fl.part (i : ℕ) : Set V)}) where
  toFun s i := ⟨s.1.1 i, by
    have hfl : ∀ j, Submodule.span K (s.1.1 '' prefixSet N j) = Fl.part j := fun j =>
      congrArg (fun F : CompleteFlag K V N => F.part j) s.2
    refine ⟨?_, ?_⟩
    · rw [← hfl ((i : ℕ) + 1)]
      exact Submodule.subset_span ⟨i, by simp [prefixSet], rfl⟩
    · rw [← hfl (i : ℕ)]
      exact s.1.2.notMem_span_image (notMem_prefixSet_self i)⟩
  invFun v :=
    ⟨⟨fun i => (v i).1, adapted_indep Fl _ (fun i => ⟨(v i).2.1, (v i).2.2⟩) hN⟩, by
      refine CompleteFlag.ext' fun j => ?_
      rw [flagOfBasis_part]
      by_cases hj : j ≤ N
      · exact span_prefix_eq_part Fl _ (fun i => ⟨(v i).2.1, (v i).2.2⟩) j hj
      · push_neg at hj
        rw [prefixSet_eq_univ hj.le, Set.image_univ,
          adapted_span_top Fl _ (fun i => ⟨(v i).2.1, (v i).2.2⟩),
          Fl.part_eq_top_of_le hj.le]⟩
  left_inv s := by apply Subtype.ext; apply Subtype.ext; rfl
  right_inv v := by funext i; apply Subtype.ext; rfl

/-- **Two-way count of ordered bases.**  Counting the bases of `V` directly and fibrewise over
the flag they induce. -/
theorem card_flag_mul (hN : N = finrank K V) :
    Nat.card (CompleteFlag K V N) * ∏ i ∈ range N, (Fintype.card K ^ (i + 1) - Fintype.card K ^ i)
      = ∏ i ∈ range N, (Fintype.card K ^ N - Fintype.card K ^ i) := by
  classical
  haveI : Finite V := Module.finite_of_finite K
  haveI : Fintype (CompleteFlag K V N) := Fintype.ofFinite _
  have hbases : Nat.card {s : Fin N → V // LinearIndependent K s}
      = ∏ i ∈ range N, (Fintype.card K ^ N - Fintype.card K ^ i) := by
    rw [card_linearIndependent (by omega : N ≤ finrank K V),
      Fin.prod_univ_eq_prod_range
        (fun i => Fintype.card K ^ finrank K V - Fintype.card K ^ i) N, ← hN]
  haveI : Finite {s : Fin N → V // LinearIndependent K s} := Subtype.finite
  set f : {s : Fin N → V // LinearIndependent K s} → CompleteFlag K V N :=
    fun s => flagOfBasis s.1 s.2 hN with hfdef
  have hfib : ∀ Fl : CompleteFlag K V N,
      Nat.card {s : {s : Fin N → V // LinearIndependent K s} // f s = Fl}
        = ∏ i ∈ range N, (Fintype.card K ^ (i + 1) - Fintype.card K ^ i) := by
    intro Fl
    rw [Nat.card_congr (flagFiberEquiv hN Fl), Nat.card_pi]
    rw [← Fin.prod_univ_eq_prod_range
      (fun i => Fintype.card K ^ (i + 1) - Fintype.card K ^ i) N]
    refine Finset.prod_congr rfl fun i _ => ?_
    rw [Nat.card_coe_set_eq, ncard_sdiff_submodule (Fl.mono (Nat.le_succ (i : ℕ))),
      Fl.finrank_part ((i : ℕ) + 1) i.2, Fl.finrank_part (i : ℕ) i.2.le]
  have hcount := card_eq_card_mul_of_fibers f
    (∏ i ∈ range N, (Fintype.card K ^ (i + 1) - Fintype.card K ^ i)) hfib
  rw [hbases] at hcount
  exact hcount.symm

/-- **Point count of the complete flag variety.**  An `N`-dimensional vector space over a field
with `q` elements has exactly `[N]_q ! = ∏_{j=1}^{N}(1 + q + ⋯ + q^{j-1})` complete flags. -/
theorem card_completeFlag_eq_qFactorial (hN : N = finrank K V) :
    Nat.card (CompleteFlag K V N) = qFactorial (Fintype.card K) N := by
  have hq : 2 ≤ Fintype.card K := Fintype.one_lt_card
  have hpos : 0 < ∏ i ∈ range N, (Fintype.card K ^ (i + 1) - Fintype.card K ^ i) := by
    refine Finset.prod_pos fun i _ => ?_
    have : Fintype.card K ^ i < Fintype.card K ^ (i + 1) :=
      Nat.pow_lt_pow_right (by omega) (by omega)
    omega
  have h := card_flag_mul (K := K) (V := V) hN
  rw [prod_pow_sub_pow _ N (by omega), mul_comm _ (qFactorial (Fintype.card K) N)] at h
  exact Nat.eq_of_mul_eq_mul_right hpos h

/-- The complete flags of `𝔽₂³`: there are `(1)(1+2)(1+2+4) = 21` of them. -/
theorem card_completeFlag_two_three :
    Nat.card (CompleteFlag (ZMod 2) (Fin 3 → ZMod 2) 3) = 21 := by
  have hN : (3 : ℕ) = finrank (ZMod 2) (Fin 3 → ZMod 2) := by simp
  rw [card_completeFlag_eq_qFactorial hN, show Fintype.card (ZMod 2) = 2 from rfl]
  decide

end FlagCount

end SchubertCalculus