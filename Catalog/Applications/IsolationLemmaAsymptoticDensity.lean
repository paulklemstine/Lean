import Mathlib

/-!
# A bridge: Isolation-Lemma tightness ⇄ asymptotic density (analysis)

This file continues the study of the Faber–Harris / Isolation-Lemma count begun in
`IsolationLemmaTightness.lean` and `IsolationLemmaTightnessArbitraryOffsets.lean`.
Those files establish the **exact** enumerative identity for the singleton
hypergraph with zero offset:

`# isolating assignments in [d]^n  =  n · ∑_{j<d} j^{n-1}`,

matching the Faber–Harris lower bound term for term.

Here we build a **cross-domain bridge**: we connect this purely *enumerative
combinatorics* identity to *real analysis* by computing the asymptotic behaviour
of the **density** of isolating assignments as the weight range `d → ∞`.

## The bridge (`isolating_density_tendsto_one`)

For every fixed number of vertices `n ≥ 1`, the fraction of weight assignments in
`[d]^n` that are isolating for the singleton hypergraph tends to `1`:

`(# isolating(n,d)) / d^n  ⟶  1   as  d ⟶ ∞`.

Probabilistically: if the vertex weights are drawn uniformly and independently
from `{0,…,d-1}`, then the probability that some vertex is a *strict* minimum
tends to `1` — ties become asymptotically negligible.  Thus the singleton
Isolation Lemma is, in the large-alphabet limit, "almost surely for free".

The proof links the discrete power sum `∑_{j<d} j^{n-1}` to the analytic value
`∫_0^1 x^{n-1} dx = 1/n` through the elementary telescoping sandwich

`d^n - n·d^{n-1}  ≤  n · ∑_{j<d} j^{n-1}  ≤  d^n`,

whose two sides both have density `→ 1`, and squeezes the ratio between them.
The per-term inequalities behind the sandwich,

`(k+1)·x^k ≤ (x+1)^{k+1} − x^{k+1} ≤ (k+1)·(x+1)^k`   (for `x ≥ 0`),

are proved by induction on `k` — a clean discrete analogue of the mean-value
theorem for `t ↦ t^{k+1}`.

To stay self-contained (compiles independently) we reprove the exact count
`card_isolating_singleton_eq` here from scratch, then add the analytic bridge.
-/

open Finset
open scoped Classical Topology

namespace IsolationAsymptoticBridge

variable {n d : ℕ}

/-! ## Core strict-minimum machinery (self-contained reproof) -/

/-- A hypergraph on `Fin n` is a finite family of edges (vertex subsets). -/
abbrev Hypergraph (n : ℕ) := Finset (Finset (Fin n))

/-- A hypergraph is **inclusion-free** (a Sperner family / antichain). -/
def InclusionFree {n : ℕ} (H : Hypergraph n) : Prop :=
  ∀ ⦃S⦄, S ∈ H → ∀ ⦃T⦄, T ∈ H → S ⊆ T → S = T

/-- `w` has a **strict minimum** vertex. -/
def HasStrictMin (w : Fin n → Fin d) : Prop := ∃ i, ∀ j, j ≠ i → w i < w j

/-- The set of assignments with a unique strict minimum vertex. -/
noncomputable def isolatingSet (n d : ℕ) : Finset (Fin n → Fin d) :=
  Finset.univ.filter (fun w => HasStrictMin w)

/-- The set of assignments for which vertex `i` is the strict minimum. -/
noncomputable def strictMinAt (n d : ℕ) (i : Fin n) : Finset (Fin n → Fin d) :=
  Finset.univ.filter (fun w => ∀ j, j ≠ i → w i < w j)

/-- Number of values in `Fin d` strictly above `m`. -/
theorem card_gt (m : Fin d) :
    (Finset.univ.filter (fun v : Fin d => m < v)).card = d - 1 - m.val := by
  rw [ Finset.card_eq_of_bijective ];
  use fun i hi => ⟨ m + 1 + i, by omega ⟩;
  · simp +zetaDelta at *;
    exact fun a ha => ⟨ a - ( m + 1 ), by omega, by erw [ Fin.ext_iff ] ; norm_num; omega ⟩;
  · grind +qlia;
  · grind

/-- For a fixed minimum value `m`, the number of strict-min-at-`i` assignments
attaining `w i = m` is `(d-1-m)^{n-1}`. -/
theorem card_fiber (i : Fin n) (m : Fin d) :
    (Finset.univ.filter
        (fun w : Fin n → Fin d => w i = m ∧ ∀ j, j ≠ i → m < w j)).card
      = (d - 1 - m.val) ^ (n - 1) := by
  set t : Fin n → Finset (Fin d) := fun j => if j = i then {m} else Finset.filter (fun v => m < v) Finset.univ;
  have h_filter_eq_piFinset : Finset.filter (fun w : Fin n → Fin d => w i = m ∧ ∀ j, j ≠ i → m < w j) (Finset.univ : Finset (Fin n → Fin d)) = Fintype.piFinset t := by
    grind +splitImp;
  rw [ h_filter_eq_piFinset, Fintype.card_piFinset ];
  rw [ Finset.prod_eq_mul_prod_diff_singleton <| Finset.mem_univ i ];
  simp +zetaDelta at *;
  rw [ Finset.prod_congr rfl fun x hx => by aesop ];
  simp +decide [ Finset.card_sdiff, Finset.card_singleton, Finset.card_univ, card_gt ]

/-- The number of assignments for which `i` is the strict minimum equals
`∑_{j<d} j^{n-1}`, independent of `i`. -/
theorem card_strictMinAt (i : Fin n) :
    (strictMinAt n d i).card = ∑ j ∈ Finset.range d, j ^ (n - 1) := by
  have h_fiber_eq : ∀ m : Fin d, (Finset.univ.filter (fun w : Fin n → Fin d => ∀ j, j ≠ i → w i < w j)).filter (fun w => w i = m) = Finset.univ.filter (fun w : Fin n → Fin d => w i = m ∧ ∀ j, j ≠ i → m < w j) := by
    grind;
  have h_final : (Finset.univ.filter (fun w : Fin n → Fin d => ∀ j, j ≠ i → w i < w j)).card = ∑ m : Fin d, (d - 1 - m.val) ^ (n - 1) := by
    have h_final : (Finset.univ.filter (fun w : Fin n → Fin d => ∀ j, j ≠ i → w i < w j)).card = ∑ m : Fin d, (Finset.univ.filter (fun w : Fin n → Fin d => w i = m ∧ ∀ j, j ≠ i → m < w j)).card := by
      rw [ ← Finset.sum_congr rfl fun m hm => congr_arg Finset.card <| h_fiber_eq m, Finset.card_eq_sum_ones ];
      simp +decide only [card_eq_sum_ones, sum_fiberwise];
    exact h_final.trans ( Finset.sum_congr rfl fun m hm => card_fiber i m );
  convert h_final using 1;
  rw [ ← Finset.sum_range_reflect, Finset.sum_range ]

/-- The isolating set is the disjoint union of the strict-min-at-`i` sets. -/
theorem isolatingSet_card_eq_sum :
    (isolatingSet n d).card = ∑ i : Fin n, (strictMinAt n d i).card := by
  rw [ ← Finset.card_biUnion ];
  · congr with w ; simp +decide [ Finset.mem_biUnion, strictMinAt ];
    exact ⟨ fun hw => by simpa [ HasStrictMin ] using Finset.mem_filter.mp hw |>.2, fun hw => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by simpa [ HasStrictMin ] using hw ⟩ ⟩;
  · intro i hi j hj hij; simp_all +decide [ Finset.disjoint_left, strictMinAt ] ;
    exact fun a ha => ⟨ i, by tauto, le_of_lt ( ha j ( by tauto ) ) ⟩

/-- **Exact tightness of the Isolation-Lemma lower bound.**
The number of isolating weight assignments in `[d]^n` for the singleton
hypergraph with zero offset is *exactly* `n · ∑_{j=0}^{d-1} j^{n-1}`. -/
theorem card_isolating_singleton_eq (n d : ℕ) :
    (isolatingSet n d).card = n * ∑ j ∈ Finset.range d, j ^ (n - 1) := by
  rw [ isolatingSet_card_eq_sum, Finset.sum_congr rfl fun _ _ => card_strictMinAt _ ] ; norm_num [ mul_comm, Finset.card_univ ]

/-! ## Part 2 — The analytic bridge: telescoping power-sum sandwich -/

/-
**Upper per-term inequality** (discrete mean-value bound from below).
For `x ≥ 0`, `x^{k+1} + (k+1)·x^k ≤ (x+1)^{k+1}`, i.e. the first two binomial
terms of `(x+1)^{k+1}`.  Proved by induction on `k`.
-/
theorem key_upper (x : ℝ) (hx : 0 ≤ x) (k : ℕ) :
    x ^ (k + 1) + (k + 1) * x ^ k ≤ (x + 1) ^ (k + 1) := by
  induction' k with k ih;
  · norm_num;
  · norm_num [ pow_succ' ] at * ; nlinarith [ pow_nonneg hx k, pow_nonneg hx ( k + 1 ) ]

/-
**Lower per-term inequality** (discrete mean-value bound from above).
For `x ≥ 0`, `(x+1)^{k+1} − x^{k+1} ≤ (k+1)·(x+1)^k`.  Proved by induction on `k`.
-/
theorem key_lower (x : ℝ) (hx : 0 ≤ x) (k : ℕ) :
    (x + 1) ^ (k + 1) - x ^ (k + 1) ≤ (k + 1) * (x + 1) ^ k := by
  induction' k with k ih <;> norm_num [ pow_succ' ] at *;
  nlinarith [ pow_nonneg hx k, pow_le_pow_left₀ hx ( by linarith : x ≤ x + 1 ) k ]

/-
**Upper telescoping sum bound.**
`(k+1) · ∑_{j<d} j^k ≤ d^{k+1}` over `ℝ`.
-/
theorem sum_upper (d k : ℕ) :
    ((k : ℝ) + 1) * ∑ j ∈ Finset.range d, (j : ℝ) ^ k ≤ (d : ℝ) ^ (k + 1) := by
  -- Rewrite the right-hand side as a sum of differences.
  have h_sum : (d : ℝ) ^ (k + 1) = ∑ j ∈ Finset.range d, ((j + 1 : ℝ) ^ (k + 1) - (j : ℝ) ^ (k + 1)) := by
    exact Nat.recOn d ( by norm_num ) fun n ih => by norm_num [ Finset.sum_range_succ ] at * ; linarith;
  rw [ h_sum, Finset.mul_sum _ _ _ ];
  exact Finset.sum_le_sum fun i hi => by have := key_upper ( i : ℝ ) ( Nat.cast_nonneg i ) k; norm_num [ add_pow ] at *; linarith;

/-
**Lower telescoping sum bound.**
`d^{k+1} ≤ (k+1) · ∑_{j<d} j^k + (k+1) · d^k` over `ℝ`.
-/
theorem sum_lower (d k : ℕ) :
    (d : ℝ) ^ (k + 1)
      ≤ ((k : ℝ) + 1) * (∑ j ∈ Finset.range d, (j : ℝ) ^ k)
          + ((k : ℝ) + 1) * (d : ℝ) ^ k := by
  induction' d with d hd;
  · cases k <;> norm_num;
  · have := key_lower ( d : ℝ ) ( by positivity ) k;
    norm_num [ Finset.sum_range_succ ] at * ; nlinarith [ pow_nonneg ( by positivity : ( 0 :ℝ ) ≤ d ) k, pow_nonneg ( by positivity : ( 0 :ℝ ) ≤ d + 1 ) k ]

/-- The isolating count as a real number equals `(k+1) · ∑_{j<d} j^k` when
`n = k + 1`. -/
theorem card_isolating_real (k d : ℕ) :
    (((isolatingSet (k + 1) d).card : ℝ))
      = ((k : ℝ) + 1) * ∑ j ∈ Finset.range d, (j : ℝ) ^ k := by
  rw [card_isolating_singleton_eq]
  push_cast [Nat.add_sub_cancel]
  ring

/-
**The bridge, indexed form.**  For `n = k+1` vertices, the density of isolating
assignments tends to `1` as the weight range grows.
-/
theorem isolating_density_tendsto_one_succ (k : ℕ) :
    Filter.Tendsto
      (fun d : ℕ => (((isolatingSet (k + 1) d).card : ℝ)) / (d : ℝ) ^ (k + 1))
      Filter.atTop (nhds 1) := by
  refine' ( tendsto_of_tendsto_of_tendsto_of_le_of_le' _ tendsto_const_nhds _ _ );
  refine' fun d => 1 - ( k + 1 : ℝ ) / d;
  · exact le_trans ( tendsto_const_nhds.sub ( tendsto_const_nhds.div_atTop tendsto_natCast_atTop_atTop ) ) ( by norm_num );
  · filter_upwards [ Filter.eventually_gt_atTop 0 ] with d hd;
    rw [ card_isolating_real ];
    rw [ one_sub_div, div_le_div_iff₀ ] <;> first | positivity | have := sum_lower d k ; norm_num [ pow_succ' ] at * ; nlinarith;
  · filter_upwards [ Filter.eventually_gt_atTop 0 ] with d hd using div_le_one_of_le₀ ( mod_cast by
      exact le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ) ( by positivity )

/-- **The bridge (main statement): Isolation-Lemma density → 1.**
For every fixed `n ≥ 1`, the fraction of weight assignments in `[d]^n` that are
isolating for the singleton hypergraph tends to `1` as the weight range
`d → ∞`.  This connects the exact enumerative count
`# isolating = n·∑_{j<d} j^{n-1}` (combinatorics) to a limit statement
(analysis): almost every assignment is isolating in the large-alphabet limit. -/
theorem isolating_density_tendsto_one (n : ℕ) (hn : 1 ≤ n) :
    Filter.Tendsto
      (fun d : ℕ => (((isolatingSet n d).card : ℝ)) / (d : ℝ) ^ n)
      Filter.atTop (nhds 1) := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (Nat.one_le_iff_ne_zero.mp hn)
  exact isolating_density_tendsto_one_succ k

end IsolationAsymptoticBridge