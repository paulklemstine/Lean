import Mathlib

/-!
# Rank-Uniform Tropical Satake Isomorphism for GL_n

## Overview

This file establishes the tropical (min-plus) Satake correspondence for `GL n`
uniformly in rank `n`. We prove that the tropical Schur map, sending a dominant
weight `w` of `GL n` to the orbit-min tropical polynomial
`tropSchur w x = min_{σ ∈ Sₙ} ∑ᵢ w(σ i) · x(i)`,
is injective and lands in the `Sₙ`-invariant tropical polynomials.

## Main Results

* `tropSchur_wInvariant` — `Sₙ`-invariance of tropical Schur polynomials.
* `tropSchur_injective` — Injectivity on dominant weights.
* `heckeBasis_eq_tropSchur` — Hecke basis = tropical Schur (reindexing identity).
* `satakeTransform_eq_tropSchur` — The Satake transform of a Hecke basis element
  equals the tropical Schur polynomial.
* `satakeTransform_idempotent` — Idempotency on invariant functions.
* `tropSchur_orbitMin_bijective` — Bijection to orbit-min basis elements.
-/

open Finset Equiv

noncomputable section

/-! ## Core Definitions -/

/-- A weight `v : Fin n → ℤ` is dominant (weakly decreasing). -/
def IsDominantWeight {n : ℕ} (v : Fin n → ℤ) : Prop :=
  ∀ (i j : Fin n), i ≤ j → v j ≤ v i

/-- The type of dominant weights of `GL n`. -/
structure DomWeight (n : ℕ) where
  /-- The underlying weight vector. -/
  val : Fin n → ℤ
  /-- The weight is weakly decreasing. -/
  dom : IsDominantWeight val

@[ext]
theorem DomWeight.ext {n : ℕ} {a b : DomWeight n} (h : a.val = b.val) : a = b := by
  cases a; cases b; simp at h; exact h ▸ rfl

/-- The tropical Schur polynomial for `GL n`:
    `tropSchur w x = min_{σ ∈ Sₙ} ∑ᵢ w(σ i) · x(i)`. -/
def tropSchur {n : ℕ} (w x : Fin n → ℤ) : ℤ :=
  Finset.inf' Finset.univ Finset.univ_nonempty
    (fun σ : Equiv.Perm (Fin n) => ∑ i : Fin n, w (σ i) * x i)

/-- Weyl (`Sₙ`) invariance of a function on `ℤⁿ`. -/
def WInvariant {n : ℕ} (f : (Fin n → ℤ) → ℤ) : Prop :=
  ∀ (σ : Equiv.Perm (Fin n)) (x : Fin n → ℤ),
    f (fun i => x (σ i)) = f x

/-- The Hecke basis element:
    `heckeBasis w x = min_{σ ∈ Sₙ} ∑ᵢ w(i) · x(σ(i))`. -/
def heckeBasis {n : ℕ} (w x : Fin n → ℤ) : ℤ :=
  Finset.inf' Finset.univ Finset.univ_nonempty
    (fun σ : Equiv.Perm (Fin n) => ∑ i : Fin n, w i * x (σ i))

/-- The tropical Satake transform:
    `satakeTransform f x = min_{w ∈ Sₙ} f(w · x)`. -/
def satakeTransform {n : ℕ} (f : (Fin n → ℤ) → ℤ) (x : Fin n → ℤ) : ℤ :=
  Finset.inf' Finset.univ Finset.univ_nonempty
    (fun p : Equiv.Perm (Fin n) => f (fun i => x (p i)))

/-- An orbit-min basis element: `f = tropSchur w` for some dominant weight. -/
def IsOrbitMinBasis {n : ℕ} (f : (Fin n → ℤ) → ℤ) : Prop :=
  ∃ (d : DomWeight n), f = tropSchur d.val

/-! ## Key Reindexing Identity -/

/-- Reindexing: `∑ᵢ a(i)·b(σ(i)) = ∑ᵢ a(σ⁻¹(i))·b(i)`. -/
lemma sum_perm_reindex {n : ℕ} (a : Fin n → ℤ) (b : Fin n → ℤ)
    (σ : Equiv.Perm (Fin n)) :
    (∑ i, a i * b (σ i)) = ∑ i, a (σ⁻¹ i) * b i := by
  conv_rhs => rw [ ← Equiv.sum_comp σ ] ;
  aesop

/-
**The Hecke basis element equals the tropical Schur polynomial.**
    `min_σ ∑ w(i) x(σ i) = min_σ ∑ w(σ i) x(i)`.
-/
theorem heckeBasis_eq_tropSchur {n : ℕ} (w x : Fin n → ℤ) :
    heckeBasis w x = tropSchur w x := by
  -- By definition of `heckeBasis` and `tropSchur`, we can rewrite the goal using the sum_perm_reindex lemma.
  unfold heckeBasis tropSchur;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
  · intro b; use b⁻¹; simp +decide [ sum_perm_reindex ] ;
  · exact fun σ => ⟨ σ⁻¹, by simp +decide [ sum_perm_reindex ] ⟩

/-! ## Weyl Invariance -/

/-- **Weyl Invariance of Tropical Schur Polynomials.**
    For any weight `w`, `tropSchur w` is `Sₙ`-invariant. -/
theorem tropSchur_wInvariant {n : ℕ} (w : Fin n → ℤ) :
    WInvariant (tropSchur w) := by
  -- For any σ and x, we need to show that tropSchur w (fun i => x (σ i)) = tropSchur w x.
  intro σ x
  apply le_antisymm;
  · -- For any permutation $\tau$, we have $\sum_{i} w(\tau(i)) x(\sigma(i)) = \sum_{i} w(\tau(\sigma^{-1}(i))) x(i)$.
    have h_sum_eq : ∀ τ : Equiv.Perm (Fin n), ∑ i, w (τ i) * x (σ i) = ∑ i, w (τ (σ⁻¹ i)) * x i := by
      exact fun τ => by rw [ ← Equiv.sum_comp σ⁻¹ ] ; simp +decide ;
    unfold tropSchur;
    simp +decide [ h_sum_eq, Finset.inf'_le ];
    exact fun τ => ⟨ τ * σ, by simp +decide [ h_sum_eq ] ⟩;
  · unfold tropSchur;
    simp +decide [ Finset.inf'_le, Finset.le_inf' ];
    intro b; use b * σ⁻¹; simp +decide [ mul_assoc, Finset.sum_mul _ _ _ ] ;
    conv_rhs => rw [ ← Equiv.sum_comp σ.symm ] ;
    grind +suggestions

/-- The Hecke basis element is Weyl-invariant. -/
theorem heckeBasis_wInvariant {n : ℕ} (w : Fin n → ℤ) :
    WInvariant (heckeBasis w) := by
  intro σ x
  rw [heckeBasis_eq_tropSchur, heckeBasis_eq_tropSchur]
  exact tropSchur_wInvariant w σ x

/-
The Satake transform of a Hecke basis element equals the tropical Schur
    polynomial. This is the rank-uniform tropical Satake identity.
-/
theorem satakeTransform_eq_tropSchur {n : ℕ} (w x : Fin n → ℤ) :
    satakeTransform (heckeBasis w) x = tropSchur w x := by
  unfold satakeTransform;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le ];
  · exact ⟨ Equiv.refl _, by simpa [ heckeBasis_eq_tropSchur ] ⟩;
  · intro σ; rw [ heckeBasis_eq_tropSchur ] ; exact (by
    exact tropSchur_wInvariant w σ x ▸ le_rfl);

/-- The Satake transform is idempotent on `Sₙ`-invariant functions. -/
theorem satakeTransform_idempotent {n : ℕ}
    (f : (Fin n → ℤ) → ℤ) (hf : WInvariant f) (x : Fin n → ℤ) :
    satakeTransform f x = f x := by
  refine' le_antisymm ( Finset.inf'_le _ ( Finset.mem_univ 1 ) |> le_trans <| _ ) _
  · rfl
  · exact Finset.le_inf' _ _ fun p _ => hf p x ▸ le_rfl

/-! ## Injectivity -/

/-- Test vector: indicator of `{i : Fin n | (k : ℕ) ≤ (i : ℕ)}`.
    Used to extract partial tail sums from dominant weights. -/
def testVec {n : ℕ} (k : Fin n) : Fin n → ℤ :=
  fun i => if (k : ℕ) ≤ (i : ℕ) then 1 else 0

/-
For a dominant weight, evaluating `tropSchur w (testVec k)` yields the
    sum of entries at positions `≥ k`, i.e., the `n - k` smallest entries.
    The identity permutation achieves this minimum because dominant weights
    are decreasing, so the sum of a subset of size `n - k` is minimized
    by choosing the last `n - k` entries.
-/
theorem tropSchur_testVec {n : ℕ} (w : Fin n → ℤ) (hw : IsDominantWeight w)
    (k : Fin n) :
    tropSchur w (testVec k) =
      ∑ i : Fin n, if (k : ℕ) ≤ (i : ℕ) then w i else 0 := by
  refine' le_antisymm ( Finset.inf'_le _ ( Finset.mem_univ 1 ) |> le_trans <| _ ) _;
  · exact Finset.sum_le_sum fun _ _ => by unfold testVec; aesop;
  · -- Since $w$ is dominant, any subset of size $n-k$ has a sum at least the sum of the $n-k$ smallest elements, which are $w(k), ..., w(n-1)$.
    have h_subset : ∀ S : Finset (Fin n), S.card = n - k → ∑ i ∈ S, w i ≥ ∑ i ∈ Finset.Ici k, w i := by
      intro S hS_card
      have h_sum_ge : ∑ i ∈ S, w i ≥ ∑ i ∈ Finset.Ici k, w i := by
        have h_sorted : ∃ f : Fin (n - k.val) → Fin n, StrictMono f ∧ ∀ i, f i ∈ S := by
          exact ⟨ fun i => S.orderEmbOfFin ( by aesop ) i, by aesop_cat, fun i => by aesop ⟩
        obtain ⟨f, hf_mono, hf_mem⟩ := h_sorted
        have h_sum_ge : ∑ i ∈ Finset.image f Finset.univ, w i ≥ ∑ i ∈ Finset.Ici k, w i := by
          have h_sum_ge : ∀ i : Fin (n - k.val), w (f i) ≥ w (Fin.rev (Fin.castLE (by
          exact Nat.sub_le _ _) (Fin.rev i))) := by
            all_goals generalize_proofs at *;
            intro i
            have h_f_le : f i ≤ Fin.rev (Fin.castLE (by
            exact Nat.sub_le _ _) (Fin.rev i)) := by
              all_goals generalize_proofs at *;
              have h_f_le : Finset.card (Finset.filter (fun x => x ≥ f i) Finset.univ) ≥ n - k.val - i.val := by
                have h_f_le : Finset.card (Finset.image f (Finset.Ici i)) ≤ Finset.card (Finset.filter (fun x => x ≥ f i) Finset.univ) := by
                  exact Finset.card_le_card fun x hx => by obtain ⟨ j, hj, rfl ⟩ := Finset.mem_image.mp hx; exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hf_mono.monotone <| Finset.mem_Ici.mp hj ⟩ ;
                generalize_proofs at *;
                exact le_trans ( by rw [ Finset.card_image_of_injective _ hf_mono.injective ] ; simp +decide [ Finset.card_univ ] ) h_f_le
              generalize_proofs at *;
              contrapose! h_f_le;
              rw [ show ( Finset.filter ( fun x => x ≥ f i ) Finset.univ : Finset ( Fin n ) ) = Finset.Ici ( f i ) by ext; simp +decide ] ; simp +decide [ Finset.card_univ, Finset.card_sdiff, * ];
              grind +splitIndPred
            generalize_proofs at *;
            exact hw _ _ h_f_le
          generalize_proofs at *;
          have h_sum_ge : ∑ i ∈ Finset.image f Finset.univ, w i ≥ ∑ i ∈ Finset.image (fun i : Fin (n - k.val) => Fin.rev (Fin.castLE (by
          exact Nat.sub_le _ _) (Fin.rev i))) Finset.univ, w i := by
            all_goals generalize_proofs at *;
            rw [ Finset.sum_image, Finset.sum_image ];
            · exact Finset.sum_le_sum fun i _ => h_sum_ge i;
            · intro i hi j hj hij; aesop;
            · exact hf_mono.injective.injOn
          generalize_proofs at *;
          convert h_sum_ge using 2;
          ext i; simp [Finset.mem_image];
          constructor <;> intro hi <;> simp_all +decide [ Fin.ext_iff, Fin.rev_eq_iff ];
          · use ⟨ i - k, by
              exact tsub_lt_tsub_iff_right ( mod_cast hi ) |>.2 ( Fin.is_lt i ) ⟩
            generalize_proofs at *;
            grind;
          · grind;
        rwa [ Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr fun i _ => hf_mem i ) ( by rw [ Finset.card_image_of_injective _ hf_mono.injective, Finset.card_fin, hS_card ] ) ] at h_sum_ge;
      grind;
    refine' Finset.le_inf' _ _ _;
    intro σ _; specialize h_subset ( Finset.image σ ( Finset.Ici k ) ) ; simp_all +decide [ Finset.card_image_of_injective _ σ.injective ] ;
    convert h_subset using 1 <;> simp +decide [ Finset.sum_ite, testVec ];
    · rcongr x ; aesop;
    · rcongr x ; aesop

/-
If two dominant weights have the same partial tail sums (for all
    cutoff positions), they are equal. The proof telescopes: the entry
    at position `k` equals the difference of consecutive tail sums.
-/
theorem dominant_eq_of_tail_sums {n : ℕ} (v w : Fin n → ℤ)
    (_hv : IsDominantWeight v) (_hw : IsDominantWeight w)
    (h : ∀ k : Fin n,
      (∑ i : Fin n, if (k : ℕ) ≤ (i : ℕ) then v i else 0) =
      (∑ i : Fin n, if (k : ℕ) ≤ (i : ℕ) then w i else 0)) :
    v = w := by
  funext j;
  induction' j with j ih;
  by_cases hj : j + 1 < n;
  · have := h ⟨ j, ih ⟩ ; have := h ⟨ j + 1, hj ⟩ ; simp_all +decide [ Finset.sum_ite ] ;
    rw [ show ( Finset.filter ( fun x : Fin n => j ≤ ( x : ℕ ) ) Finset.univ ) = Finset.filter ( fun x : Fin n => j < ( x : ℕ ) ) Finset.univ ∪ { ⟨ j, ih ⟩ } from ?_, Finset.sum_union ] at * <;> norm_num at *;
    · linarith;
    · grind;
  · have := h ⟨ j, ih ⟩ ; simp_all +decide [ Finset.sum_ite ] ;
    rw [ show ( Finset.univ.filter fun x : Fin n => j ≤ ( x : ℕ ) ) = { ⟨ j, ih ⟩ } from Finset.eq_singleton_iff_unique_mem.mpr ⟨ Finset.mem_filter.mpr ⟨ Finset.mem_univ _, le_rfl ⟩, fun x hx => Fin.ext <| le_antisymm ( by linarith [ Fin.is_lt x ] ) ( Finset.mem_filter.mp hx |>.2 ) ⟩ ] at this ; aesop

/-- **Injectivity of the Tropical Schur Map on Dominant Weights.** -/
theorem tropSchur_injective {n : ℕ} :
    ∀ (a b : DomWeight n), tropSchur a.val = tropSchur b.val → a = b := by
  intro ⟨v, hv⟩ ⟨w, hw⟩ h
  apply DomWeight.ext
  have key : ∀ k : Fin n,
    (∑ i : Fin n, if (k : ℕ) ≤ (i : ℕ) then v i else 0) =
    (∑ i : Fin n, if (k : ℕ) ≤ (i : ℕ) then w i else 0) := by
    intro k
    have := congr_fun h (testVec k)
    rw [tropSchur_testVec v hv, tropSchur_testVec w hw] at this
    exact this
  exact dominant_eq_of_tail_sums v w hv hw key

/-! ## Bijection Theorems -/

/-- **Bijection: Dominant Weights ↔ Orbit-Min Basis Elements.** -/
theorem tropSchur_orbitMin_bijective {n : ℕ} :
    Function.Bijective (fun (d : DomWeight n) =>
      (⟨tropSchur d.val, ⟨d, rfl⟩⟩ :
        {f : (Fin n → ℤ) → ℤ // IsOrbitMinBasis f})) := by
  constructor
  · intro a b h
    simp only [Subtype.mk.injEq] at h
    exact tropSchur_injective a b h
  · intro ⟨f, d, hf⟩
    exact ⟨d, by simp [hf]⟩

/-- Each orbit-min basis element is Weyl-invariant. -/
theorem orbitMinBasis_wInvariant {n : ℕ} (f : (Fin n → ℤ) → ℤ)
    (hf : IsOrbitMinBasis f) : WInvariant f := by
  obtain ⟨⟨w, _⟩, rfl⟩ := hf
  exact tropSchur_wInvariant w

/-- **Rank-Uniform Tropical Satake Identity.**
    The tropical Satake transform sends each Hecke basis element indexed by
    a dominant coweight to the corresponding tropical Schur polynomial.
    This identity holds uniformly for all `GL n`. -/
theorem tropical_satake_GLn {n : ℕ} (d : DomWeight n) (x : Fin n → ℤ) :
    satakeTransform (heckeBasis d.val) x = tropSchur d.val x :=
  satakeTransform_eq_tropSchur d.val x

end