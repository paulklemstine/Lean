import Mathlib

/-!
# Tropical Brill–Noether Theory: CDPR Existence Theorem

This file formalizes the combinatorial core of the Cools–Draisma–Payne–Robeva (CDPR)
theorem, proving that the existence of certain combinatorial structures (allocations,
displacement tableaux) encoding rank-r divisors on a chain of loops is equivalent
to the non-negativity of the Brill–Noether number ρ(g,r,d) = g − (r+1)(g−d+r).

## Main Results

* `brillNoetherNumber` — The Brill–Noether number ρ(g,r,d).
* `CDPRAllocation` — A weakly decreasing allocation encoding CDPR lattice path endpoints.
* `allocation_iff_rho_nonneg` — A CDPR allocation exists iff ρ(g,r,d) ≥ 0.
* `DisplacementTableau` — An injective row-strict filling of a rectangle.
* `displacementTableau_exists_iff` — A displacement tableau exists iff the rectangle fits.
* `InWeylChamber` — Weyl chamber condition for integer vectors.
* `initialState_inWeylChamber` — The CDPR initial state is in the Weyl chamber iff r ≤ d.

## References

* Cools, Draisma, Payne, Robeva, "A tropical proof of the Brill–Noether theorem"
* Baker, Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph"
-/

namespace TropicalBrillNoether

open Finset

/-! ### The Brill–Noether Number -/

/-- The Brill–Noether number ρ(g,r,d) = g − (r+1)(g−d+r).
This measures the expected dimension of the space of linear series
of degree `d` and rank `r` on a curve of genus `g`. -/
def brillNoetherNumber (g r d : ℕ) : ℤ :=
  ↑g - (↑r + 1) * (↑g - ↑d + ↑r)

@[simp]
theorem brillNoetherNumber_def (g r d : ℕ) :
    brillNoetherNumber g r d = ↑g - (↑r + 1) * (↑g - ↑d + ↑r) := rfl

/-! ### Weyl Chamber -/

/-- A vector in ℤ^{r+1} lies in the (closed) Weyl chamber if it is weakly decreasing
(antitone) and the last coordinate is non-negative. -/
def InWeylChamber {r : ℕ} (v : Fin (r + 1) → ℤ) : Prop :=
  Antitone v ∧ 0 ≤ v ⟨r, by omega⟩

/-- The initial CDPR state vector: v(j) = d − j for j = 0, 1, ..., r.
This represents the initial chip configuration before traversing any loops. -/
def initialState (r d : ℕ) : Fin (r + 1) → ℤ :=
  fun j => ↑d - ↑j.val

/-
The initial CDPR state lies in the Weyl chamber if and only if r ≤ d.
-/
theorem initialState_inWeylChamber {r d : ℕ} :
    InWeylChamber (initialState r d) ↔ r ≤ d := by
  unfold InWeylChamber initialState;
  simp +decide [ Antitone ];
  exact fun h a b hab => by linarith [ show ( a : ℤ ) ≤ b from mod_cast hab ] ;

/-! ### CDPR Allocation -/

/-- A CDPR allocation for parameters (g, r, d) encodes the endpoint of a valid CDPR
lattice path through the Weyl chamber. It consists of a weakly decreasing sequence
`counts : Fin (r+1) → ℕ` representing how many times each coordinate was incremented,
subject to:
- The total number of increments equals g (one per loop).
- The sequence is antitone (preserving Weyl chamber ordering).
- A floor bound ensuring positivity of all coordinates at the final state. -/
structure CDPRAllocation (g r d : ℕ) where
  counts : Fin (r + 1) → ℕ
  sum_eq : ∑ j, counts j = g
  antitone : Antitone counts
  floor_bound : (g : ℤ) - ↑d + ↑r ≤ ↑(counts ⟨r, by omega⟩)

/-
For an antitone function on `Fin (r+1)`, every value is at least the value at `r`.
-/
theorem antitone_fin_le_of_last {r : ℕ} {f : Fin (r + 1) → ℕ}
    (hf : Antitone f) (j : Fin (r + 1)) :
    f ⟨r, by omega⟩ ≤ f j := by
  exact hf ( Fin.le_last _ )

/-
**Forward direction**: If a CDPR allocation exists, then ρ(g,r,d) ≥ 0.
-/
theorem rho_nonneg_of_allocation {g r d : ℕ} (a : CDPRAllocation g r d) :
    0 ≤ brillNoetherNumber g r d := by
  -- From a.antitone, for every j : Fin(r+1), a.counts(⟨r,_⟩) ≤ a.counts(j) (use antitone_fin_le_of_last).
  have h_le : ∀ j : Fin (r + 1), a.counts ⟨r, by omega⟩ ≤ a.counts j := by
    exact fun j => a.antitone ( Fin.le_last _ );
  exact Int.le_of_lt_add_one ( by have := a.sum_eq ▸ Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h_le i; norm_num at *; nlinarith [ a.floor_bound ] )

/-
**Backward direction**: If ρ(g,r,d) ≥ 0, then a CDPR allocation exists.
The construction uses a canonical allocation where coordinate 0 gets the
surplus and all other coordinates get the minimum required count.
-/
theorem allocation_of_rho_nonneg {g r d : ℕ} (h : 0 ≤ brillNoetherNumber g r d) :
    Nonempty (CDPRAllocation g r d) := by
  -- Compute $c = g + r - d$
  set c := (g + r) - d;
  by_cases h_cases : d ≤ g + r;
  · -- When $d \leq g + r$, we define the counts function as $counts(j) = if j.val = 0 then g - r * c else c$.
    use fun j => if j.val = 0 then g - r * c else c;
    · rcases r with ( _ | r ) <;> simp_all +decide [ Fin.sum_univ_succ ];
      rw [ Nat.sub_add_cancel ( by nlinarith [ Nat.sub_add_cancel h_cases ] ) ];
    · intro i j hij; rcases i with ⟨ _ | i, hi ⟩ <;> rcases j with ⟨ _ | j, hj ⟩ <;> norm_num at *;
      exact le_tsub_of_add_le_left ( by nlinarith [ Nat.sub_add_cancel h_cases ] );
    · grind;
  · use fun j => if j.val = 0 then g else 0;
    · cases r <;> aesop;
    · intro i j hij; aesop;
    · grind

/-- **CDPR Existence Theorem (Allocation Form).**
A CDPR allocation for parameters (g, r, d) exists if and only if the
Brill–Noether number ρ(g,r,d) is non-negative. This is the combinatorial
heart of the CDPR theorem on tropical Brill–Noether theory. -/
theorem allocation_iff_rho_nonneg (g r d : ℕ) :
    Nonempty (CDPRAllocation g r d) ↔ 0 ≤ brillNoetherNumber g r d :=
  ⟨fun ⟨a⟩ => rho_nonneg_of_allocation a, allocation_of_rho_nonneg⟩

/-! ### Displacement Tableaux -/

/-- A displacement tableau is an injective filling of a `rows × cols` rectangle
with entries from `Fin g`, such that each row is strictly increasing.
This models the CDPR displacement data on a chain of loops. -/
structure DisplacementTableau (g rows cols : ℕ) where
  entries : Fin rows → Fin cols → Fin g
  row_strict : ∀ i : Fin rows, StrictMono (entries i)
  injective : Function.Injective (fun p : Fin rows × Fin cols => entries p.1 p.2)

/-
A displacement tableau of shape `rows × cols` with entries in `Fin g`
exists if and only if `rows * cols ≤ g`. The forward direction is a
cardinality/pigeonhole argument; the backward direction constructs the
canonical filling `T(i,j) = i * cols + j`.
-/
theorem displacementTableau_exists_iff {g rows cols : ℕ} :
    Nonempty (DisplacementTableau g rows cols) ↔ rows * cols ≤ g := by
  refine' ⟨ _, fun h => _ ⟩;
  · rintro ⟨ T ⟩;
    have := Fintype.card_le_of_injective ( fun p : Fin rows × Fin cols => T.entries p.1 p.2 ) T.injective; simp_all +decide ;
  · refine' ⟨ ⟨ fun i j => ⟨ i.val * cols + j.val, by nlinarith [ Fin.is_lt i, Fin.is_lt j ] ⟩, _, _ ⟩ ⟩;
    · exact fun i => fun j k hjk => Nat.add_lt_add_left hjk _;
    · norm_num [ Function.Injective ];
      intro a b c d h; have := congr_arg ( · % cols ) h; norm_num [ Nat.add_mod, Nat.mod_eq_of_lt ] at this;
      exact ⟨ Fin.ext ( by nlinarith [ Fin.is_lt a, Fin.is_lt b, Fin.is_lt c, Fin.is_lt d ] ), Fin.ext this ⟩

/-
**CDPR Existence Theorem (Tableau Form).**
A displacement tableau of shape `(r+1) × (g+r−d)` with entries in `Fin g`
exists if and only if ρ(g,r,d) ≥ 0.
-/
theorem tableau_iff_rho_nonneg {g r d : ℕ} (hd : d ≤ g + r) :
    Nonempty (DisplacementTableau g (r + 1) (g + r - d)) ↔
    0 ≤ brillNoetherNumber g r d := by
  convert displacementTableau_exists_iff;
  unfold brillNoetherNumber;
  constructor <;> intro <;> nlinarith [ Nat.sub_add_cancel hd ]

/-! ### CDPR Lattice Path -/

/-- Count of steps assigned to coordinate `j` among the first `i` steps of `σ`. -/
def stepCount {g : ℕ} (r : ℕ) (σ : Fin g → Fin (r + 1)) (i : ℕ) (j : Fin (r + 1)) : ℕ :=
  (Finset.univ.filter fun k : Fin g => k.val < i ∧ σ k = j).card

/-- A CDPR lattice path for parameters (g, r, d) is a step function
`σ : Fin g → Fin (r+1)` assigning each of the `g` loops to one of `r+1`
coordinates, such that:
1. At each time step, the cumulative counts are weakly decreasing
   (Weyl chamber ordering condition).
2. At each time step, the bottom coordinate of the state vector
   remains non-negative (positivity condition). -/
def CDPRPathValid (g r d : ℕ) (σ : Fin g → Fin (r + 1)) : Prop :=
  (∀ (i : Fin (g + 1)) (j : Fin r),
    stepCount r σ i.val ⟨j.val + 1, by omega⟩ ≤
    stepCount r σ i.val ⟨j.val, by omega⟩) ∧
  (∀ (i : Fin (g + 1)),
    (d : ℤ) - ↑r - ↑i.val +
    ↑(stepCount r σ i.val ⟨r, by omega⟩) ≥ 0)

/-
The total step count across all coordinates equals the number of steps taken.
-/
theorem stepCount_total_eq {g r : ℕ} (σ : Fin g → Fin (r + 1)) (i : ℕ) (hi : i ≤ g) :
    ∑ j : Fin (r + 1), stepCount r σ i j = i := by
  revert i hi;
  intro i hi
  have h_total : ∑ j : Fin (r + 1), stepCount r σ i j = Finset.card (Finset.univ.filter (fun k : Fin g => k.val < i)) := by
    simp +decide [ stepCount ];
    rw [ ← Finset.card_biUnion ] ; congr ; ext ; aesop;
    exact fun x _ y _ hxy => Finset.disjoint_left.mpr fun z => by aesop;
  rw [ h_total, Finset.card_eq_of_bijective ];
  use fun k hk => ⟨ k, by linarith ⟩;
  · grind;
  · aesop;
  · aesop

/-
Forward direction for the path theorem: a valid CDPR path yields ρ ≥ 0.
-/
theorem cdprPath_implies_rho_nonneg {g r d : ℕ} {σ : Fin g → Fin (r + 1)}
    (hσ : CDPRPathValid g r d σ) : 0 ≤ brillNoetherNumber g r d := by
  obtain ⟨h_ordering, h_pos⟩ := hσ;
  -- From h_ordering, the function j ↦ stepCount r σ g j is antitone on Fin(r+1).
  have h_antitone : Antitone (fun j : Fin (r + 1) => stepCount r σ g j) := by
    intro i j hij;
    induction' j using Fin.inductionOn with j ih;
    · aesop;
    · cases hij.eq_or_lt <;> [ aesop; exact le_trans ( h_ordering ⟨ g, Nat.lt_succ_self _ ⟩ j ) ( ih <| Nat.le_of_lt_succ ‹_› ) ];
  -- From h_pos, we have that the floor bound holds.
  have h_floor_bound : (g : ℤ) - d + r ≤ stepCount r σ g ⟨r, by omega⟩ := by
    specialize h_pos ⟨ g, Nat.lt_succ_self g ⟩ ; norm_num at h_pos ; linarith;
  convert rho_nonneg_of_allocation ⟨ fun j => stepCount r σ g j, ?_, h_antitone, h_floor_bound ⟩;
  convert stepCount_total_eq σ g le_rfl

/-- The round-robin assignment σ(k) = k mod (r+1). -/
def roundRobinPath (g r : ℕ) : Fin g → Fin (r + 1) :=
  fun k => ⟨k.val % (r + 1), Nat.mod_lt _ (by omega)⟩

/-
The round-robin path is a valid CDPR path when ρ ≥ 0.
-/
theorem roundRobin_cdprPathValid {g r d : ℕ}
    (h : 0 ≤ brillNoetherNumber g r d) :
    CDPRPathValid g r d (roundRobinPath g r) := by
  constructor;
  · intro i j;
    -- By definition of `roundRobinPath`, the count of steps for coordinate `j+1` is at most the count for coordinate `j`.
    have h_count : ∀ i : ℕ, i ≤ g → ∀ j : Fin r, (stepCount r (roundRobinPath g r) i ⟨j.val + 1, by omega⟩) ≤ (stepCount r (roundRobinPath g r) i ⟨j.val, by omega⟩) := by
      intros i hi j
      have h_count : ∀ n : ℕ, n ≤ i → (Finset.filter (fun k : Fin g => k.val < n ∧ (k.val % (r + 1) = j.val + 1)) Finset.univ).card ≤ (Finset.filter (fun k : Fin g => k.val < n ∧ (k.val % (r + 1) = j.val)) Finset.univ).card := by
        intros n hn
        have h_count : Finset.card (Finset.filter (fun k : ℕ => k < n ∧ k % (r + 1) = j.val + 1) (Finset.range g)) ≤ Finset.card (Finset.filter (fun k : ℕ => k < n ∧ k % (r + 1) = j.val) (Finset.range g)) := by
          have h_count : Finset.card (Finset.filter (fun k : ℕ => k < n ∧ k % (r + 1) = j.val + 1) (Finset.range g)) ≤ Finset.card (Finset.image (fun k => k + 1) (Finset.filter (fun k : ℕ => k < n ∧ k % (r + 1) = j.val) (Finset.range g))) := by
            refine Finset.card_mono ?_;
            intro k hk; simp_all +decide ;
            exact ⟨ k - 1, ⟨ by omega, by omega, by rw [ ← Nat.mod_add_div k ( r + 1 ), hk.2.2 ] ; norm_num [ Nat.add_mod, Nat.mod_eq_of_lt ( show ( j : ℕ ) + 1 < r + 1 from Nat.succ_lt_succ j.2 ) ] ⟩, Nat.succ_pred_eq_of_pos ( Nat.pos_of_ne_zero ( by aesop_cat ) ) ⟩;
          exact h_count.trans ( Finset.card_image_le );
        convert h_count using 1;
        · refine' Finset.card_bij ( fun x hx => x ) _ _ _ <;> simp +decide;
          · exact fun a₁ ha₁ ha₂ a₂ ha₃ ha₄ ha₅ => Fin.ext ha₅;
          · exact fun b hb₁ hb₂ hb₃ => ⟨ ⟨ b, hb₁ ⟩, ⟨ hb₂, hb₃ ⟩, rfl ⟩;
        · refine' Finset.card_bij ( fun x hx => x ) _ _ _ <;> simp +decide;
          · exact fun a₁ ha₁ ha₂ a₂ ha₃ ha₄ ha₅ => Fin.ext ha₅;
          · exact fun b hb₁ hb₂ hb₃ => ⟨ ⟨ b, hb₁ ⟩, ⟨ hb₂, hb₃ ⟩, rfl ⟩;
      unfold stepCount roundRobinPath; aesop;
    exact h_count _ ( Nat.le_of_lt_succ i.2 ) _;
  · intro i
    have h_step_count : stepCount r (roundRobinPath g r) i.val ⟨r, by omega⟩ ≥ (i.val : ℤ) / (r + 1) := by
      -- The step count for coordinate r is the number of times r appears in the first i steps, which is at least i/(r+1).
      have h_step_count_r : (stepCount r (roundRobinPath g r) i.val ⟨r, by omega⟩ : ℕ) ≥ i.val / (r + 1) := by
        have h_div : ∀ k : Fin g, (roundRobinPath g r k = ⟨r, by omega⟩) ↔ (k.val % (r + 1) = r) := by
          exact fun k => by simp +decide [ roundRobinPath ] ;
        -- The set of indices $k$ such that $k.val < i.val$ and $k.val \% (r + 1) = r$ has cardinality at least $i.val / (r + 1)$.
        have h_card : Finset.card (Finset.filter (fun k : ℕ => k < i.val ∧ k % (r + 1) = r) (Finset.range i.val)) ≥ i.val / (r + 1) := by
          -- The set of indices $k$ such that $k.val < i.val$ and $k.val \% (r + 1) = r$ is exactly the set $\{r, r + (r + 1), r + 2(r + 1), \ldots, r + (i.val / (r + 1) - 1)(r + 1)\}$.
          have h_set : Finset.filter (fun k : ℕ => k < i.val ∧ k % (r + 1) = r) (Finset.range i.val) ⊇ Finset.image (fun k => r + k * (r + 1)) (Finset.range (i.val / (r + 1))) := by
            simp +decide [ Finset.subset_iff ];
            exact fun a ha => by nlinarith [ Nat.div_mul_le_self i ( r + 1 ) ] ;
          exact le_trans ( by rw [ Finset.card_image_of_injective ] <;> aesop_cat ) ( Finset.card_mono h_set );
        refine le_trans h_card ?_;
        refine' le_of_eq _;
        refine' Finset.card_bij ( fun x hx => ⟨ x, by linarith [ Finset.mem_range.mp ( Finset.mem_filter.mp hx |>.1 ), Fin.is_lt i ] ⟩ ) _ _ _ <;> simp +decide [ h_div ];
        exact fun k hk₁ hk₂ => ⟨ k, ⟨ hk₁, hk₂ ⟩, rfl ⟩;
      exact_mod_cast h_step_count_r;
    unfold brillNoetherNumber at h;
    nlinarith [ Nat.div_add_mod i ( r + 1 ), Nat.mod_lt i ( Nat.succ_pos r ), show ( i : ℕ ) ≤ g from Fin.is_le i ]

/-- **CDPR Existence Theorem (Path Form).**
A valid CDPR lattice path exists if and only if ρ(g,r,d) ≥ 0. -/
theorem cdprPath_iff_rho_nonneg (g r d : ℕ) :
    (∃ σ, CDPRPathValid g r d σ) ↔ 0 ≤ brillNoetherNumber g r d :=
  ⟨fun ⟨_, hσ⟩ => cdprPath_implies_rho_nonneg hσ,
   fun h => ⟨roundRobinPath g r, roundRobin_cdprPathValid h⟩⟩

/-! ### Computational Verification -/

-- Verify the Brill–Noether number for small cases
#eval brillNoetherNumber 4 1 3  -- Expected: 0
#eval brillNoetherNumber 5 1 4  -- Expected: 1
#eval brillNoetherNumber 3 1 2  -- Expected: -1
#eval brillNoetherNumber 6 1 4  -- Expected: 0
#eval brillNoetherNumber 0 0 0  -- Expected: 0
#eval brillNoetherNumber 2 1 2  -- Expected: 0

-- The classical Brill–Noether theorem: ρ(g,1,g) = g − 2
#eval brillNoetherNumber 3 1 3  -- Expected: 1

end TropicalBrillNoether