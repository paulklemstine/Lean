import Mathlib
import Bridges.BerggrenIsogeny.Network

/-!
# Realization–Minimality Duality for Berggren Correspondence Networks

This file proves the main duality theorems connecting finite correspondence
network realizations with minimal reconstruction and observable data.

## Main Results

* `BerggrenIsogeny.minimal_realization_exists` — Every finitely realizable kernel has
  a minimal realization
* `BerggrenIsogeny.minimal_size_unique` — The size of a minimal realization is unique
* `BerggrenIsogeny.realization_minimality_duality` — The main duality: finite realizability
  ↔ existence of minimal realization
* `BerggrenIsogeny.minimal_reconstruction_rigid` — Minimal realizations determine
  the network size uniquely from observable data
* `BerggrenIsogeny.NetworkIso.kernel_eq` — Isomorphic networks produce identical kernels
-/

set_option maxHeartbeats 800000

namespace BerggrenIsogeny

/-! ## Section 1: Minimal Realizations -/

/-- A realization of K at size n is minimal if no smaller network realizes K. -/
def MinimalRealization [DecidableEq S] [AddCommMonoid R]
    (K : S → S → R) (n : ℕ) (N : CorrNetwork S R n) : Prop :=
  N.realizes K ∧ ∀ m, (∃ M : CorrNetwork S R m, M.realizes K) → n ≤ m

/-
Every finitely realizable kernel admits a minimal realization.
    This follows from the well-ordering of ℕ: among all valid realization sizes,
    there is a smallest one.
-/
theorem minimal_realization_exists [DecidableEq S] [AddCommMonoid R]
    (K : S → S → R) (h : FinitelyRealizable K) :
    ∃ n, ∃ N : CorrNetwork S R n, MinimalRealization K n N := by
  -- By definition of `FinitelyRealizable`, there exists some `n` such that there exists a network `N` of size `n` that realizes `K`.
  obtain ⟨n, ⟨N, hN⟩⟩ : ∃ n, ∃ N : CorrNetwork S R n, N.realizes K := by
    exact?;
  -- Let `n_min` be the smallest such `n`.
  obtain ⟨n_min, hn_min⟩ : ∃ n_min, (∃ N : CorrNetwork S R n_min, N.realizes K) ∧ ∀ m, (∃ N : CorrNetwork S R m, N.realizes K) → n_min ≤ m := by
    apply Classical.byContradiction
    intro h_no_min;
    push_neg at h_no_min;
    induction' n using Nat.strong_induction_on with n ih;
    exact absurd ( h_no_min n ⟨ N, hN ⟩ ) ( by rintro ⟨ m, ⟨ M, hM ⟩, hm ⟩ ; exact ih m hm M hM );
  exact ⟨ n_min, hn_min.1.choose, hn_min.1.choose_spec, hn_min.2 ⟩

/-
The size of a minimal realization is uniquely determined by the kernel.
    If two minimal realizations exist, they must have the same number of generators.
-/
theorem minimal_size_unique [DecidableEq S] [AddCommMonoid R]
    (K : S → S → R) {n₁ n₂ : ℕ}
    {N₁ : CorrNetwork S R n₁} {N₂ : CorrNetwork S R n₂}
    (h₁ : MinimalRealization K n₁ N₁) (h₂ : MinimalRealization K n₂ N₂) :
    n₁ = n₂ := by
  exact le_antisymm ( h₁.2 _ ⟨ N₂, h₂.1 ⟩ ) ( h₂.2 _ ⟨ N₁, h₁.1 ⟩ )

/-! ## Section 2: Finite Observable Rank -/

/-- The row function of K at state x: the function y ↦ K(x,y). -/
def rowFn (K : S → S → R) (x : S) : S → R := K x

/-- A kernel K has finite observable rank if its row function factors through
    a finite type. That is, there is a finite number of "row types" such that
    every row K(x,·) is one of these types. -/
def FiniteObsRank (K : S → S → R) : Prop :=
  ∃ (n : ℕ) (classify : S → Fin n) (template : Fin n → S → R),
    ∀ x, K x = template (classify x)

/-
Forward direction of the duality: if K is finitely realizable,
    then K has finite observable rank, provided the action signature
    space is finite.
-/
theorem finite_realization_implies_finite_obs_rank
    [DecidableEq S] [AddCommMonoid R]
    (K : S → S → R) (n : ℕ) (N : CorrNetwork S R n)
    (hK : N.realizes K)
    (hfin : Finite (Set.range (fun x => (fun i : Fin n => N.action i x)))) :
    FiniteObsRank K := by
  obtain ⟨classify, template, htemplate⟩ : ∃ (classify : S → Set.range (fun x : S => (fun i : Fin n => N.action i x))) (template : Set.range (fun x : S => (fun i : Fin n => N.action i x)) → S → R), ∀ x, K x = template (classify x) := by
    refine' ⟨ fun x => ⟨ _, Set.mem_range_self x ⟩, fun ⟨ σ, hσ ⟩ => fun y => ∑ i : Fin n, if σ i = y then N.weight i else 0, fun x => _ ⟩;
    exact funext fun y => hK x y;
  have := Fintype.ofFinite ( Set.range fun x : S => ( fun i : Fin n => N.action i x ) );
  refine' ⟨ Fintype.card _, fun x => Fintype.equivFin _ ( classify x ), fun i => template ( Fintype.equivFin _ |>.symm i ), fun x => _ ⟩;
  aesop

/-! ## Section 3: Observable Data and Reconstruction -/

/-- Observable data extracted from a kernel: the multiset of row functions. -/
structure ObservableData (S R : Type*) where
  /-- The set of distinct row profiles -/
  rowProfiles : Set (S → R)
  /-- Assignment of states to their row profile -/
  profileOf : S → (S → R)
  /-- Each state's profile is in the profile set -/
  mem_profiles : ∀ x, profileOf x ∈ rowProfiles

/-- Extract observable data from a kernel. -/
def obsDataOf (K : S → S → R) : ObservableData S R where
  rowProfiles := Set.range (K ·)
  profileOf := K
  mem_profiles := fun x => ⟨x, rfl⟩

/-
Two kernels produce the same observable data iff they are equal.
-/
theorem obsData_eq_iff_kernel_eq (K₁ K₂ : S → S → R) :
    obsDataOf K₁ = obsDataOf K₂ ↔ K₁ = K₂ := by
  grind +locals

/-! ## Section 4: Network Isomorphism -/

/-- Two networks of the same size are isomorphic if there is a permutation of
    generators that identifies their actions and weights. -/
structure NetworkIso {n : ℕ} (N₁ N₂ : CorrNetwork S R n) where
  /-- The permutation of generators -/
  perm : Equiv.Perm (Fin n)
  /-- Actions are conjugated by the permutation -/
  action_eq : ∀ i, N₁.action i = N₂.action (perm i)
  /-- Weights are preserved under the permutation -/
  weight_eq : ∀ i, N₁.weight i = N₂.weight (perm i)

/-
Isomorphic networks produce the same kernel.
-/
theorem NetworkIso.kernel_eq [DecidableEq S] [AddCommMonoid R]
    {n : ℕ} {N₁ N₂ : CorrNetwork S R n}
    (iso : NetworkIso N₁ N₂) :
    N₁.kernel = N₂.kernel := by
  ext x y; simp +decide [ CorrNetwork.kernel, iso.action_eq, iso.weight_eq ] ;
  conv_rhs => rw [ ← Equiv.sum_comp iso.perm ] ;

/-! ## Section 5: The Main Duality Theorem -/

/-
**Realization–Minimality Duality**: A kernel is finitely realizable if and only if
    it admits a minimal realization. This connects the existence of finite algebraic
    decomposition with the structural uniqueness of minimal networks.

    The forward direction uses well-ordering of ℕ to extract a minimal realization.
    The backward direction extracts the realization from the minimal one.
-/
theorem realization_minimality_duality [DecidableEq S] [AddCommMonoid R]
    (K : S → S → R) :
    FinitelyRealizable K ↔
      ∃ n, ∃ N : CorrNetwork S R n, MinimalRealization K n N := by
  exact ⟨ fun h => minimal_realization_exists K h, fun ⟨ n, N, hN ⟩ => ⟨ n, N, hN.1 ⟩ ⟩

/-- **Minimal Reconstruction Rigidity**: Two minimal realizations of the same kernel
    have the same size. This is the core rigidity theorem: the "public transcript"
    (the kernel K) determines the minimum complexity of any generating network. -/
theorem minimal_reconstruction_rigid [DecidableEq S] [AddCommMonoid R]
    (K : S → S → R)
    {n₁ n₂ : ℕ} {N₁ : CorrNetwork S R n₁} {N₂ : CorrNetwork S R n₂}
    (hmin₁ : MinimalRealization K n₁ N₁)
    (hmin₂ : MinimalRealization K n₂ N₂) :
    n₁ = n₂ := minimal_size_unique K hmin₁ hmin₂

/-! ## Section 6: Berggren-Specific Results -/

/-- The kernel arising from a single Berggren word is finitely realizable. -/
theorem berggren_word_realizable (R : Type*) [AddCommMonoid R]
    (w : List BerggrenGen) (r : R) :
    FinitelyRealizable (S := ℤ × ℤ × ℤ)
      (fun x y => if applyWord w x = y then r else 0) :=
  single_realizable (applyWord w) r

/-
A finite combination of Berggren word kernels is realizable.
-/
theorem berggren_combination_realizable [AddCommMonoid R]
    (m : ℕ) (ws : Fin m → List BerggrenGen) (rs : Fin m → R) :
    FinitelyRealizable (S := ℤ × ℤ × ℤ)
      (fun x y => ∑ i : Fin m, if applyWord (ws i) x = y then rs i else 0) := by
  refine' ⟨ m, _, fun x y => _ ⟩;
  exact ⟨ fun i x => applyWord ( ws i ) x, fun i => rs i ⟩;
  unfold BerggrenIsogeny.CorrNetwork.kernel; aesop;

/-- Every Berggren-compatible network kernel is finitely realizable. -/
theorem berggren_compatible_realizable [AddCommMonoid R]
    {n : ℕ} (N : CorrNetwork (ℤ × ℤ × ℤ) R n)
    (_hcompat : BerggrenCompatible N) :
    FinitelyRealizable N.kernel :=
  ⟨n, N, fun _ _ => rfl⟩

/-
Composing Berggren words corresponds to concatenation:
    applying w₁ ++ w₂ is the same as applying w₁ then w₂.
-/
theorem applyWord_append (w₁ w₂ : List BerggrenGen) (t : ℤ × ℤ × ℤ) :
    applyWord (w₁ ++ w₂) t = applyWord w₂ (applyWord w₁ t) := by
  -- By definition of applyWord, we have:
  simp [applyWord]

end BerggrenIsogeny