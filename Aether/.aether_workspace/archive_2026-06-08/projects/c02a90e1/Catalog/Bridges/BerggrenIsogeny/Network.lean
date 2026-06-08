import Mathlib
import Bridges.BerggrenIsogeny.Basic

/-!
# Correspondence Networks and Realization Theory

This file develops the abstract theory of correspondence networks over arbitrary
state spaces, then specializes to Berggren-compatible networks on Pythagorean triples.

## Main Definitions

* `BerggrenIsogeny.CorrNetwork` — A finite correspondence network (actions + weights)
* `BerggrenIsogeny.CorrNetwork.kernel` — The kernel (weighted adjacency) of a network
* `BerggrenIsogeny.FinitelyRealizable` — A kernel admits a finite network decomposition
* `BerggrenIsogeny.ObsEquiv` — Two kernels agree on all observable data
* `BerggrenIsogeny.BerggrenCompatible` — Network actions factor through Berggren words

## Main Results

* `BerggrenIsogeny.zero_realizable` — The zero kernel is finitely realizable
* `BerggrenIsogeny.single_realizable` — Weighted indicator kernels are realizable
* `BerggrenIsogeny.sum_realizable` — Sum of realizable kernels is realizable
* `BerggrenIsogeny.finite_row_support` — Realizable kernels have finite row support
* `BerggrenIsogeny.row_support_bound` — Row support cardinality ≤ network size
-/

set_option maxHeartbeats 800000

namespace BerggrenIsogeny

/-! ## Section 1: Correspondence Networks -/

/-- A correspondence network over state space `S` with weights in semiring `R`,
    parametrized by `n` generators. Each generator `i : Fin n` defines an
    action `S → S` and carries a weight in `R`. The network encodes a finite
    decomposition of a weighted correspondence. -/
structure CorrNetwork (S : Type*) (R : Type*) (n : ℕ) where
  /-- The action of each generator on the state space -/
  action : Fin n → S → S
  /-- The weight (in the semiring R) assigned to each generator -/
  weight : Fin n → R

/-- The kernel (correspondence matrix) induced by a network:
    `K(x,y) = ∑ᵢ wᵢ · [Fᵢ(x) = y]`.
    This is the fundamental bridge between network structure and observable data. -/
def CorrNetwork.kernel [DecidableEq S] [AddCommMonoid R] {n : ℕ}
    (N : CorrNetwork S R n) (x y : S) : R :=
  ∑ i : Fin n, if N.action i x = y then N.weight i else 0

/-- A network `N` realizes a kernel `K` if their values agree everywhere. -/
def CorrNetwork.realizes [DecidableEq S] [AddCommMonoid R] {n : ℕ}
    (N : CorrNetwork S R n) (K : S → S → R) : Prop :=
  ∀ x y, K x y = N.kernel x y

/-- A kernel `K` is finitely realizable if there exists a correspondence network
    whose kernel equals `K`. This is the central notion connecting observable
    correspondence data to finite algebraic structure. -/
def FinitelyRealizable [DecidableEq S] [AddCommMonoid R] (K : S → S → R) : Prop :=
  ∃ n, ∃ N : CorrNetwork S R n, N.realizes K

/-! ## Section 2: Basic Realizability Results -/

/-- The zero kernel (all entries zero) is finitely realizable with 0 generators. -/
theorem zero_realizable (S : Type*) [DecidableEq S] (R : Type*) [AddCommMonoid R] :
    FinitelyRealizable (fun (_ _ : S) => (0 : R)) := by
  exact ⟨0, ⟨Fin.elim0, Fin.elim0⟩, fun x y => by simp [CorrNetwork.kernel]⟩

/-- A single weighted indicator kernel `(x,y) ↦ if f(x) = y then w else 0` is
    finitely realizable with 1 generator. -/
theorem single_realizable [DecidableEq S] [AddCommMonoid R] (f : S → S) (w : R) :
    FinitelyRealizable (fun x y => if f x = y then w else 0) := by
  exact ⟨1, ⟨fun _ => f, fun _ => w⟩, fun x y => by simp [CorrNetwork.kernel]⟩

/-
The sum of two finitely realizable kernels is finitely realizable.
    The realization uses `n₁ + n₂` generators by concatenating the two networks.
    This establishes that finitely realizable kernels form an additive submonoid.
-/
theorem sum_realizable [DecidableEq S] [AddCommMonoid R]
    {K₁ K₂ : S → S → R}
    (h₁ : FinitelyRealizable K₁) (h₂ : FinitelyRealizable K₂) :
    FinitelyRealizable (fun x y => K₁ x y + K₂ x y) := by
  obtain ⟨ n₁, N₁, hN₁ ⟩ := h₁
  obtain ⟨ n₂, N₂, hN₂ ⟩ := h₂;
  refine' ⟨ n₁ + n₂, _, _ ⟩;
  constructor;
  exact fun i x => if hi : i.val < n₁ then N₁.action ⟨ i.val, hi ⟩ x else N₂.action ⟨ i.val - n₁, by rw [ tsub_lt_iff_left ] <;> linarith [ Fin.is_lt i ] ⟩ x;
  exact fun i => if hi : i.val < n₁ then N₁.weight ⟨ i.val, hi ⟩ else N₂.weight ⟨ i.val - n₁, by rw [ tsub_lt_iff_left ] <;> linarith [ Fin.is_lt i ] ⟩;
  intro x y; simp +decide [ hN₁, hN₂, CorrNetwork.realizes ] ;
  unfold CorrNetwork.kernel; simp +decide [ Fin.sum_univ_add, hN₁, hN₂ ] ;
  exact congr_arg₂ ( · + · ) ( hN₁ x y ) ( hN₂ x y )

/-! ## Section 3: Row Support Properties -/

/-- The support set of a row: the set of `y` values where `K(x,y) ≠ 0`. -/
def rowSupport [AddCommMonoid R] (K : S → S → R) (x : S) : Set S :=
  {y | K x y ≠ 0}

/-
For a finitely realizable kernel, every row has finite support.
    The support of row `x` is contained in `{F_i(x) | i : Fin n}`,
    which is a finite set. This is a key structural consequence of
    finite realizability.
-/
theorem finite_row_support [DecidableEq S] [AddCommMonoid R]
    {n : ℕ} {N : CorrNetwork S R n} {K : S → S → R}
    (hK : N.realizes K) (x : S) :
    Set.Finite (rowSupport K x) := by
  refine Set.Finite.subset ( Set.toFinite ( Set.range ( fun i : Fin n => N.action i x ) ) ) ?_;
  intro y hy;
  exact by_contra fun h => hy <| by rw [ hK ] ; exact Finset.sum_eq_zero fun i _ => if_neg <| by aesop;

/-
The row support is contained in the image of the action functions at `x`.
-/
theorem rowSupport_subset_image [DecidableEq S] [AddCommMonoid R]
    {n : ℕ} (N : CorrNetwork S R n) (K : S → S → R)
    (hK : N.realizes K) (x : S) :
    rowSupport K x ⊆ Set.range (fun i : Fin n => N.action i x) := by
  intro y hy; by_contra h; simp_all +decide [ Set.mem_range, rowSupport ] ;
  exact hy ( hK x y ▸ by simp +decide [ h, CorrNetwork.kernel ] )

/-
The cardinality of the row support is bounded by the network size.
    This gives a concrete upper bound: if K is realized by n generators,
    then each row of K has at most n nonzero entries.
-/
theorem row_support_card_bound [DecidableEq S] [AddCommMonoid R]
    {n : ℕ} (N : CorrNetwork S R n) (K : S → S → R)
    (hK : N.realizes K) (x : S) :
    (finite_row_support hK x).toFinset.card ≤ n := by
  have h_card : (Set.range (fun i : Fin n => N.action i x)).toFinset.card ≤ n := by
    exact le_trans ( Finset.card_le_card ( show _ ⊆ Finset.image ( fun i : Fin n => N.action i x ) Finset.univ from by aesop_cat ) ) ( Finset.card_image_le.trans ( by simp +decide ) );
  refine' le_trans _ h_card;
  convert Set.toFinset_mono ( rowSupport_subset_image N K hK x );
  any_goals exact Set.Finite.fintype ( finite_row_support hK x );
  constructor <;> intro h <;> simp_all +decide [ Set.subset_def ];
  · exact fun y hy => by have := rowSupport_subset_image N K hK x hy; aesop;
  · exact Finset.card_le_card fun y hy => by aesop;

/-! ## Section 4: Observable Equivalence -/

/-- Two kernels are observationally equivalent if they agree on all pairs. -/
def ObsEquiv [DecidableEq S] [AddCommMonoid R] (K₁ K₂ : S → S → R) : Prop :=
  ∀ x y, K₁ x y = K₂ x y

/-- Observable equivalence is reflexive. -/
theorem ObsEquiv.refl [DecidableEq S] [AddCommMonoid R] (K : S → S → R) :
    ObsEquiv K K := fun _ _ => rfl

/-- Observable equivalence is symmetric. -/
theorem ObsEquiv.symm [DecidableEq S] [AddCommMonoid R] {K₁ K₂ : S → S → R}
    (h : ObsEquiv K₁ K₂) : ObsEquiv K₂ K₁ :=
  fun x y => (h x y).symm

/-- Observable equivalence is transitive. -/
theorem ObsEquiv.trans [DecidableEq S] [AddCommMonoid R] {K₁ K₂ K₃ : S → S → R}
    (h₁ : ObsEquiv K₁ K₂) (h₂ : ObsEquiv K₂ K₃) : ObsEquiv K₁ K₃ :=
  fun x y => (h₁ x y).trans (h₂ x y)

/-- If two networks realize the same kernel, they are observationally equivalent. -/
theorem realizes_obs_equiv [DecidableEq S] [AddCommMonoid R]
    {n₁ n₂ : ℕ} {N₁ : CorrNetwork S R n₁} {N₂ : CorrNetwork S R n₂}
    {K : S → S → R} (h₁ : N₁.realizes K) (h₂ : N₂.realizes K) :
    ObsEquiv N₁.kernel N₂.kernel := by
  intro x y
  rw [← h₁ x y, ← h₂ x y]

/-! ## Section 5: Berggren-Compatible Networks -/

/-- A network on ℤ-triples is Berggren-compatible if each action factors through
    a word in the Berggren generators {A, B, C}. This encodes the constraint
    that transition operators respect the tree structure. -/
def BerggrenCompatible {n : ℕ} (N : CorrNetwork (ℤ × ℤ × ℤ) R n) : Prop :=
  ∀ i : Fin n, ∃ w : List BerggrenGen, ∀ t, N.action i t = applyWord w t

/-- Invariant stability: a kernel respects an invariant function σ,
    meaning transitions only connect states with the same invariant value. -/
def InvariantStable {S T : Type*} [Zero R] (σ : S → T) (K : S → S → R) : Prop :=
  ∀ x y, K x y ≠ 0 → σ x = σ y

/-- Height profile of a triple: the hypotenuse (third component). -/
def berggrenHeight (t : ℤ × ℤ × ℤ) : ℤ := t.2.2

/-- Parity signature of a triple: encodes parity structure. -/
def paritySig (t : ℤ × ℤ × ℤ) : ℤ × ℤ := (t.1 % 2, t.2.1 % 2)

end BerggrenIsogeny