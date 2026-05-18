import Mathlib

/-!
# Tropical Amortization: Amortized Complexity via Min-Plus Algebra

This module rebuilds the logic of amortized complexity analysis inside the
tropical (min-plus) semiring. The classical potential method and accounting
method are shown to be tropical linear certificates for sequence cost bounds.

## Main results

* `potential_method_telescoping` — the potential method telescopes exactly
* `potential_method_amortized_bound` — corollary with nonneg potential
* `accounting_potential_equiv` — accounting ↔ potential duality
* `accountingPotential_spec` — constructive witness for the equivalence
* `tropicalConv_le_split` — min-plus convolution bounds every split
* `le_tropicalConv_of_le_all_splits` — min-plus convolution is the greatest lower bound
-/

open Finset BigOperators

/-! ## Tropical operations on ℕ -/

/-- Tropical addition is minimum. -/
def tropAdd (a b : ℕ) : ℕ := min a b

/-- Tropical multiplication is addition. -/
def tropMul (a b : ℕ) : ℕ := a + b

/-! ## Sequence costs and amortized costs -/

/-- Total cost of the first `n` operations. -/
def seqCost (c : ℕ → ℤ) (n : ℕ) : ℤ :=
  ∑ i ∈ Finset.range n, c i

/-- The accounting potential: cumulative slack between amortized and actual costs. -/
def accountingPotential (c a : ℕ → ℤ) (n : ℕ) : ℤ :=
  (∑ i ∈ Finset.range n, a i) - (∑ i ∈ Finset.range n, c i)

/-! ## Min-plus (tropical) convolution -/

/-- Min-plus convolution of two cost functions.
    `(f ⋆ g)(n) = min_{0 ≤ k ≤ n} (f(k) + g(n-k))` -/
noncomputable def tropicalConv (f g : ℕ → ℕ) (n : ℕ) : ℕ :=
  ((Finset.range (n + 1)).image (fun k => f k + g (n - k))).min'
    ⟨f 0 + g n, Finset.mem_image.mpr ⟨0, by simp, rfl⟩⟩

/-! ## Telescoping lemma -/

/-
Telescoping sum identity: `∑ i ∈ range n, (Φ(i+1) - Φ(i)) = Φ(n) - Φ(0)`.
-/
theorem sum_range_telescoping (Φ : ℕ → ℤ) (n : ℕ) :
    ∑ i ∈ Finset.range n, (Φ (i + 1) - Φ i) = Φ n - Φ 0 := by
  convert Finset.sum_range_sub _ _

/-! ## Theorem 1: Potential method telescopes exactly -/

/-
**Potential method telescoping theorem.**
If `c(i) + Φ(i+1) - Φ(i) ≤ a(i)` for all `i`, then
`∑_{i<n} c(i) ≤ ∑_{i<n} a(i) + Φ(0) - Φ(n)`.

This is the foundational bridge theorem: the potential method is a tropical
linear certificate for sequence cost bounds.
-/
theorem potential_method_telescoping
    (c a Φ : ℕ → ℤ)
    (hstep : ∀ i, c i + Φ (i + 1) - Φ i ≤ a i) :
    ∀ n,
      (∑ i ∈ Finset.range n, c i) ≤
      (∑ i ∈ Finset.range n, a i) + Φ 0 - Φ n := by
  intro n;
  induction' n with n ih <;> norm_num [ Finset.sum_range_succ ] at * ; linarith [ hstep n ]

/-
**Amortized bound corollary.**
With `Φ(0) = 0` and `Φ(n) ≥ 0` for all `n`, the total actual cost
is bounded by the total amortized cost.
-/
theorem potential_method_amortized_bound
    (c a Φ : ℕ → ℤ)
    (hstep : ∀ i, c i + Φ (i + 1) - Φ i ≤ a i)
    (hinit : Φ 0 = 0)
    (hnonneg : ∀ n, 0 ≤ Φ n) :
    ∀ n, (∑ i ∈ Finset.range n, c i) ≤ ∑ i ∈ Finset.range n, a i := by
  exact fun n => by linarith [ potential_method_telescoping c a Φ hstep n, hnonneg n ] ;

/-! ## Theorem 2: Accounting ↔ Potential duality -/

/-
**Accounting–potential equivalence.**
The following are equivalent:
1. There exists a potential `Φ` with `Φ(0) = 0`, `Φ(n) ≥ 0`, and
   `c(i) + Φ(i+1) - Φ(i) ≤ a(i)` for all `i`.
2. For every prefix, `∑_{i<n} c(i) ≤ ∑_{i<n} a(i)`.

This is a duality theorem: global prefix domination equals existence of
a local potential certificate.
-/
theorem accounting_potential_equiv
    (c a : ℕ → ℤ) :
    (∃ Φ : ℕ → ℤ,
        Φ 0 = 0 ∧
        (∀ n, 0 ≤ Φ n) ∧
        (∀ i, c i + Φ (i + 1) - Φ i ≤ a i)) ↔
    (∀ n, (∑ i ∈ Finset.range n, c i) ≤ ∑ i ∈ Finset.range n, a i) := by
  constructor <;> intro h;
  · exact fun n => potential_method_amortized_bound c a _ h.choose_spec.2.2 h.choose_spec.1 h.choose_spec.2.1 n;
  · use fun n => ∑ i ∈ Finset.range n, a i - ∑ i ∈ Finset.range n, c i;
    simp_all +decide [ Finset.sum_range_succ ];
    exact fun i => by linarith;

/-! ## Constructive accounting potential witness -/

theorem accountingPotential_zero (c a : ℕ → ℤ) :
    accountingPotential c a 0 = 0 := by
  -- By definition, the accounting potential at 0 is the difference between the sum of a(i) up to 0 and the sum of c(i) up to 0.
  simp [accountingPotential]

theorem accountingPotential_step (c a : ℕ → ℤ) (i : ℕ) :
    accountingPotential c a (i + 1) - accountingPotential c a i = a i - c i := by
  unfold accountingPotential; simp +decide [ Finset.sum_range_succ ] ; ring;

/-
**Constructive accounting potential specification.**
Given prefix domination, the canonical potential `Φ(n) = ∑a - ∑c`
satisfies `Φ(0) = 0`, `Φ(n) ≥ 0`, and `c(i) + Φ(i+1) - Φ(i) = a(i)`.
-/
theorem accountingPotential_spec
    (c a : ℕ → ℤ)
    (hprefix : ∀ n, (∑ i ∈ Finset.range n, c i) ≤ ∑ i ∈ Finset.range n, a i) :
    let Φ := accountingPotential c a
    Φ 0 = 0 ∧
    (∀ n, 0 ≤ Φ n) ∧
    (∀ i, c i + Φ (i + 1) - Φ i = a i) := by
  exact ⟨ by simpa using accountingPotential_zero c a, fun n => by linarith [ hprefix n, show accountingPotential c a n = ∑ x ∈ Finset.range n, a x - ∑ x ∈ Finset.range n, c x from rfl ], fun i => by linarith [ accountingPotential_step c a i ] ⟩

/-! ## Theorem 3: Tropical convolution properties -/

/-
Min-plus convolution is at most any particular split cost.
-/
theorem tropicalConv_le_split
    (f g : ℕ → ℕ) (n k : ℕ) (hk : k ≤ n) :
    tropicalConv f g n ≤ f k + g (n - k) := by
  exact Finset.min'_le _ _ ( Finset.mem_image_of_mem _ ( Finset.mem_range.mpr ( Nat.lt_succ_of_le hk ) ) )

/-
Min-plus convolution is the greatest lower bound: if `h(n) ≤ f(k) + g(n-k)`
for all valid splits, then `h(n) ≤ tropicalConv f g n`.
-/
theorem le_tropicalConv_of_le_all_splits
    (f g h : ℕ → ℕ)
    (hh : ∀ n k, k ≤ n → h n ≤ f k + g (n - k)) :
    ∀ n, h n ≤ tropicalConv f g n := by
  exact fun n => Finset.le_min' _ _ _ fun x hx => by aesop;

/-! ## Tropical algebra: plus distributes over min -/

/-
Addition distributes over minimum (tropical distributivity).
-/
theorem tropical_plus_distributes_over_min (a b c : ℕ) :
    a + min b c = min (a + b) (a + c) := by
  grind +splitImp

/-
Minimum distributes over addition from the right.
-/
theorem tropical_plus_distributes_over_min_right (a b c : ℕ) :
    min a b + c = min (a + c) (b + c) := by
  rw [ min_add_add_right ]

/-! ## Stretch: Associativity of tropical convolution -/

/-
**Associativity of min-plus convolution.**
This upgrades amortized complexity composition to a full min-plus algebra.
-/
theorem tropicalConv_assoc
    (f g h : ℕ → ℕ) :
    ∀ n, tropicalConv (tropicalConv f g) h n = tropicalConv f (tropicalConv g h) n := by
  -- Both sides equal min over all (j, k) with j + k ≤ n of f j + g k + h (n - j - k). Specifically, for the LHS: tropicalConv (tropicalConv f g) h n = min_{m ≤ n} (tropicalConv f g m + h (n-m)) = min_{m ≤ n} min_{j ≤ m} (f j + g (m-j) + h (n-m)). Setting k = m-j, this equals min_{j+k ≤ n} (f j + g k + h (n-j-k)). Similarly for the RHS.
  have h_lhs : ∀ n, tropicalConv (tropicalConv f g) h n = Finset.min' (Finset.image (fun (j, k) => f j + g k + h (n - j - k)) (Finset.filter (fun (j, k) => j + k ≤ n) (Finset.product (Finset.range (n + 1)) (Finset.range (n + 1))))) ⟨f 0 + g 0 + h n, by
    exact Finset.mem_image.mpr ⟨ ( 0, 0 ), by aesop ⟩⟩ := by
    all_goals generalize_proofs at *;
    intro n;
    refine' le_antisymm _ _ <;> simp +decide [ tropicalConv ];
    · rintro y x y' hx hy hxy rfl;
      refine' le_trans ( Finset.min'_le _ _ <| Finset.mem_image_of_mem _ <| Finset.mem_range.mpr <| Nat.lt_succ_of_le <| show x + y' ≤ n from hxy ) _;
      simp +decide [ Nat.sub_sub, Finset.min' ];
      exact ⟨ x, by linarith, by simp +decide [ add_tsub_cancel_left ] ⟩;
    · intro a ha
      generalize_proofs at *;
      simp +decide [ Finset.min', Finset.mem_image ];
      obtain ⟨ k, hk ⟩ := Finset.mem_image.mp ( Finset.min'_mem ( Finset.image ( fun x => f x + g ( a - x ) ) ( Finset.range ( a + 1 ) ) ) ‹_› ) ; use k, a - k; simp_all +decide [ Finset.mem_image, Finset.mem_range ] ;
      simp_all +decide [ Finset.min', Finset.inf'_eq_csInf_image ];
      exact ⟨ ⟨ by linarith, by linarith ⟩, by rw [ show n - k - ( a - k ) = n - a by omega ] ⟩;
  all_goals generalize_proofs at *;
  simp_all +decide [ tropicalConv ];
  intro n;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.min' ];
  · intro b hb;
    obtain ⟨ k, hk ⟩ := Finset.exists_min_image ( Finset.range ( n - b + 1 ) ) ( fun x => g x + h ( n - b - x ) ) ⟨ 0, Finset.mem_range.mpr ( Nat.succ_pos _ ) ⟩;
    use b, k;
    simp_all +decide [ add_assoc, Finset.inf'_le ];
    exact ⟨ hk.1.trans ( Nat.sub_le _ _ ), by linarith [ Nat.sub_add_cancel hb ] ⟩;
  · intro a b ha hb hab; use a; simp +decide [ *, add_assoc ] ;
    exact ⟨ b, Nat.le_sub_of_add_le ( by linarith ), le_rfl ⟩