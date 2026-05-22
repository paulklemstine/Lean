import Mathlib
import Speculative.ProofPhaseTransitions.Defs

/-!
# Parallel Path Proof Model: Exact Threshold Formula

This file formalizes a concrete proof system where certificates are **parallel
disjoint paths** of uniform length, and proves exact counting formulas.

## Model Description

Consider `r` independent proof channels, each requiring `k` axioms to complete.
The axiom pool consists of `r * k` axioms partitioned into `r` groups of `k`.
Target `t` is provable iff at least one complete channel is activated.

## Main Results

* `card_supersets_univ_fin` — Only `univ` is a superset of `univ` in `Fin k`
* `card_non_supersets_univ_fin` — Count of non-covering subsets is `2^k - 1`
* `card_finset_fin` — `|Finset (Fin n)| = 2^n`
-/

open Finset BigOperators

/-! ### Basic Counting Lemmas -/

/-
The number of subsets of `Fin n` is `2^n`.
-/
theorem card_finset_fin (n : ℕ) :
    Fintype.card (Finset (Fin n)) = 2 ^ n := by
  norm_num [ Fintype.card_finset ]

/-
The only superset of `Finset.univ` in `Finset (Fin k)` is `Finset.univ` itself.
-/
theorem filter_superset_univ_fin (k : ℕ) :
    ((Finset.univ : Finset (Finset (Fin k))).filter
      (fun A => Finset.univ ⊆ A)) = {Finset.univ} := by
  grind +revert

/-
For a single channel: only 1 subset of `Fin k` contains all elements.
-/
theorem card_supersets_univ_fin (k : ℕ) :
    ((Finset.univ : Finset (Finset (Fin k))).filter
      (fun A => Finset.univ ⊆ A)).card = 1 := by
  convert congr_arg Finset.card ( filter_superset_univ_fin k ) using 1

/-
For a single channel: the number of subsets of `Fin k` that do NOT contain
all elements is `2^k - 1`.
-/
theorem card_non_supersets_univ_fin (k : ℕ) (_hk : 0 < k) :
    ((Finset.univ : Finset (Finset (Fin k))).filter
      (fun A => ¬ Finset.univ ⊆ A)).card = 2 ^ k - 1 := by
  grind +suggestions

/-! ### The Parallel Disjoint Certificate Model -/

/-- Construct a monotone provability system with `r` disjoint certificates each of size `k`,
using axiom type `Fin (r * k)` and a single target `Unit`.
Certificate `i` (for `i : Fin r`) consists of axioms `{i*k, i*k+1, ..., i*k+(k-1)}`. -/
noncomputable def parallelPathSystem (k r : ℕ) (_hk : 0 < k) (_hr : 0 < r) :
    MonotoneProvabilitySystem (Fin (r * k)) Unit where
  Cert := fun _ =>
    Finset.image (fun i : Fin r =>
      Finset.image (fun j : Fin k =>
        ⟨i.val * k + j.val, by
          have hi := i.isLt
          have hj := j.isLt
          calc i.val * k + j.val < i.val * k + k := by omega
            _ = (i.val + 1) * k := by ring
            _ ≤ r * k := by nlinarith⟩) Finset.univ) Finset.univ

/-
Each certificate in the parallel path system has exactly `k` elements.
-/
theorem parallelPathSystem_cert_card (k r : ℕ) (hk : 0 < k) (hr : 0 < r)
    (S : Finset (Fin (r * k))) (hS : S ∈ (parallelPathSystem k r hk hr).Cert ()) :
    S.card = k := by
  unfold parallelPathSystem at hS;
  norm_num +zetaDelta at *;
  rcases hS with ⟨ a, rfl ⟩ ; rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ] ;
  exact fun i j h => Fin.ext h

/-
The certificates in the parallel path system are pairwise disjoint.
-/
theorem parallelPathSystem_certs_disjoint (k r : ℕ) (hk : 0 < k) (hr : 0 < r) :
    ∀ S₁ S₂ : Finset (Fin (r * k)),
      S₁ ∈ (parallelPathSystem k r hk hr).Cert () →
      S₂ ∈ (parallelPathSystem k r hk hr).Cert () →
      S₁ ≠ S₂ → Disjoint S₁ S₂ := by
  unfold parallelPathSystem;
  simp +decide [ Finset.disjoint_left ];
  rintro S₁ S₂ x rfl y rfl hne a ha hb; contrapose! hne; simp_all +decide [ Fin.ext_iff, Finset.mem_image ] ;
  -- Since $x$ and $y$ are distinct, we have $x.val \neq y.val$.
  have hxy : x.val = y.val := by
    nlinarith [ ha.choose_spec, hb.choose_spec, Fin.is_lt ha.choose, Fin.is_lt hb.choose ] ;
  rw [ show x = y from Fin.ext hxy ]

/-
The number of certificates in the parallel path system is `r`.
-/
theorem parallelPathSystem_cert_count (k r : ℕ) (hk : 0 < k) (hr : 0 < r) :
    ((parallelPathSystem k r hk hr).Cert ()).card = r := by
  convert Finset.card_image_of_injective _ _;
  · exact Eq.symm (card_fin r);
  · intro i j hij; replace hij := Finset.ext_iff.mp hij; have := hij ⟨ i.val * k, by nlinarith [ Fin.is_lt i ] ⟩ ; have := hij ⟨ j.val * k, by nlinarith [ Fin.is_lt j ] ⟩ ; simp_all +decide [ Fin.ext_iff ] ;
    contrapose! hij;
    cases lt_or_gt_of_ne hij <;> [ exact ⟨ ⟨ i * k, by nlinarith [ Fin.is_lt i ] ⟩, Or.inl ⟨ ⟨ ⟨ 0, by linarith ⟩, by simp +decide ⟩, fun a ha ↦ by nlinarith [ Fin.is_lt i, Fin.is_lt j, Fin.is_lt a ] ⟩ ⟩ ; exact ⟨ ⟨ j * k, by nlinarith [ Fin.is_lt j ] ⟩, Or.inr ⟨ fun a ha ↦ by nlinarith [ Fin.is_lt i, Fin.is_lt j, Fin.is_lt a ], ⟨ ⟨ 0, by linarith ⟩, by simp +decide ⟩ ⟩ ⟩ ]