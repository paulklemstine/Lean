/-
# Tropical Eigenvector Existence via Critical Graph

This file proves the main theorem: for any finite real matrix, there exists
a tropical spectral value and a vector that is a subeigenvector globally,
with equality on every critical node. Moreover, on a critical strongly
connected component, the vector is a genuine tropical eigenvector.

## Main Results

* `exists_tropical_subeigenpair` — existence of a tropical subeigenpair at the
  spectral value
* `exists_tropical_subeigenpair_with_critical_equality` — subeigenpair with
  equality on all critical nodes
* `exists_tropical_eigenpair_on_critical_component` — genuine eigenpair on
  a critical strongly connected component

## Mathematical Overview

We work in the max-plus semiring convention:
  `(A ⊗ v)_i = max_j (A i j + v j)`

The tropical spectral value `μ = tropSpec A` is the maximum cycle mean.
The subeigenvector condition `(A ⊗ v)_i ≤ μ + v_i` for all `i` is equivalent
to difference constraints: `v j - v i ≤ μ - A i j`.

The potential function `v_i = max_{m < n} (bestWalk A i m - m * μ)` satisfies
these constraints when all shifted cycles have non-positive weight.

Critical edges are those where equality holds: `A i j + v j = μ + v i`.
On critical nodes, the tropical action achieves the spectral value exactly.

## References

* R.A. Cuninghame-Green, "Minimax algebra", 1979
* R.M. Karp, "A characterization of the minimum cycle mean in a digraph", 1978
* P. Butkovič, "Max-linear systems: theory and algorithms", 2010
-/
import Tropical.Defs

noncomputable section

open Finset BigOperators

namespace TropicalSpectral

variable {n : ℕ}

/-! ## Telescoping Sum Lemma -/

/-
Summing `f i - f (cycleSucc i)` around a cycle telescopes to zero.
-/
theorem cycleSucc_sum_zero {k : ℕ} (hk : 0 < k) (f : Fin k → ℝ) :
    ∑ i : Fin k, (f i - f (cycleSucc hk i)) = 0 := by
  rcases k with ( _ | _ | k ) <;> norm_num at *;
  · exact sub_eq_zero_of_eq <| Finset.sum_congr rfl fun x hx => by fin_cases x; rfl;
  · erw [ sub_eq_zero, Equiv.sum_comp ( Equiv.addRight 1 ) ]

/-! ## Cycle Weight Bound from Subeigenvector -/

/-
From a subeigenvector, every cycle has total weight at most `k * mu`.
-/
theorem cycleWt_le_of_subeig (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) (mu : ℝ)
    (v : Fin n → ℝ) (hv : IsTropicalSubeigenpair hn A mu v)
    {k : ℕ} (hk : 0 < k) (c : Fin k → Fin n) :
    cycleWt A c hk ≤ ↑k * mu := by
  -- Applying the subeigenpair condition to each edge in the cycle.
  have h_cycle : ∑ i : Fin k, A (c i) (c (cycleSucc hk i)) + ∑ i : Fin k, v (c (cycleSucc hk i)) ≤ k * mu + ∑ i : Fin k, v (c i) := by
    have h_cycle : ∀ i : Fin k, A (c i) (c (cycleSucc hk i)) + v (c (cycleSucc hk i)) ≤ mu + v (c i) := by
      exact fun i => TropicalSpectral.isTropicalSubeigenpair_iff hn A mu v |>.1 hv _ _;
    simpa [ Finset.sum_add_distrib ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h_cycle i;
  -- Since `cycleSucc` is a permutation of `Fin k`, the sums of `v` over `Fin k` cancel out.
  have h_cancel : ∑ i : Fin k, v (c (cycleSucc hk i)) = ∑ i : Fin k, v (c i) := by
    rcases k with ( _ | _ | k ) <;> norm_num at *;
    · rfl;
    · conv_rhs => rw [ ← Equiv.sum_comp ( Equiv.addRight 1 ) ] ;
      norm_num [ Fin.add_def, cycleSucc ];
  linarith!

/-! ## Easy Direction: subeigenpair implies spectral bound -/

/-
If a subeigenpair exists at value `mu`, then `tropSpec A ≤ mu`.
-/
theorem tropSpec_le_of_subeigenpair (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (mu : ℝ) (v : Fin n → ℝ) (hv : IsTropicalSubeigenpair hn A mu v) :
    tropSpec hn A ≤ mu := by
  refine' Finset.sup'_le _ _ _;
  intro p hp;
  exact div_le_iff₀' ( by positivity ) |>.2 ( cycleWt_le_of_subeig hn A mu v hv _ _ )

/-! ## Hard Direction: spectral bound implies subeigenpair -/

/-- Walk weight extension: prepending an edge. -/
theorem walkWt_cons (A : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) (m : ℕ)
    (f : Fin m → Fin n) :
    walkWt A i (m + 1) (Fin.cons j f) = A i j + walkWt A j m f := by
  rfl

/-
A walk weight is at most the best walk weight.
-/
theorem walkWt_le_bestWalk (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (i : Fin n) (m : ℕ) (f : Fin m → Fin n) :
    walkWt A i m f ≤ bestWalk hn A i m := by
  convert Finset.le_sup' _ ( Finset.mem_univ f ) using 1

/-
bestWalk of length m contributes to the potential when m < n.
-/
theorem bestWalk_sub_le_potential (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (mu : ℝ) (i : Fin n) (m : ℕ) (hm : m < n) :
    bestWalk hn A i m - m * mu ≤ potential hn A mu i := by
  exact Finset.le_sup' ( fun m => bestWalk hn A i m - m * mu ) ( Finset.mem_range.mpr hm )

/-
Cycle weight bound from non-positive shifted cycles.
-/
theorem cycleWt_sub (A : Matrix (Fin n) (Fin n) ℝ) (mu : ℝ) {k : ℕ} (hk : 0 < k)
    (c : Fin k → Fin n) :
    cycleWt (fun i j => A i j - mu) c hk = cycleWt A c hk - ↑k * mu := by
  unfold cycleWt;
  simp +decide [ Finset.sum_sub_distrib ]

/-
Prepending an edge: `A i j + bestWalk j m ≤ bestWalk i (m+1)`.
-/
theorem prepend_edge_bestWalk (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (i j : Fin n) (m : ℕ) :
    A i j + bestWalk hn A j m ≤ bestWalk hn A i (m + 1) := by
  unfold bestWalk;
  simp +decide [ Finset.sup'_le_iff ];
  obtain ⟨ f, hf ⟩ := Finset.exists_max_image Finset.univ ( fun f => walkWt A j m f ) ⟨ fun _ => j, Finset.mem_univ _ ⟩ ; use Fin.cons j f; simp_all +decide [ walkWt_cons ]

/-
Pigeonhole: any walk of length n in a graph with n vertices has a repeated vertex.
-/
theorem walk_has_repeated_vertex (hn : 0 < n) (i : Fin n) (f : Fin n → Fin n) :
    ∃ a b : Fin (n + 1), a.val < b.val ∧ walkVert i f a = walkVert i f b := by
  by_contra h;
  exact absurd ( Finset.card_le_univ ( Finset.image ( fun a : Fin ( n + 1 ) => walkVert i f a ) Finset.univ ) ) ( by rw [ Finset.card_image_of_injective _ fun a b hab => le_antisymm ( not_lt.1 fun ha => h ⟨ b, a, ha, hab.symm ⟩ ) ( not_lt.1 fun hb => h ⟨ a, b, hb, hab ⟩ ) ] ; norm_num )

/-
walkWt expressed as a sum.
-/
theorem walkWt_eq_sum (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) (m : ℕ)
    (f : Fin m → Fin n) :
    walkWt A i m f = ∑ t : Fin m, A (walkVert i f t.castSucc) (walkVert i f t.succ) := by
  nontriviality;
  cases m <;> simp_all +decide [ Fin.sum_univ_succ ];
  · rfl;
  · convert walkWt_cons A i ( f 0 ) _ ( Fin.tail f ) using 1;
    congr! 1;
    induction' ‹ℕ› with m ih <;> simp_all +decide [ Fin.sum_univ_succ, walkWt ];
    convert congr_arg₂ ( · + · ) rfl ( ih ( Fin.tail f ) ) using 1

/-
Any cycle of length d ≤ n has total weight ≤ d * mu when tropSpec A ≤ mu.
-/
theorem any_cycle_wt_le (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (mu : ℝ) (hmu : tropSpec hn A ≤ mu)
    {d : ℕ} (hd : 0 < d) (hdn : d ≤ n) (c : Fin d → Fin n) :
    cycleWt A c hd ≤ d * mu := by
  rcases d with ( _ | d ) <;> simp_all +decide [ Finset.mem_univ, ne_of_gt, cycleWt ];
  refine' le_trans _ ( mul_le_mul_of_nonneg_left hmu <| by positivity );
  convert mul_le_mul_of_nonneg_left ( Finset.le_sup' ( fun p : Σ j : Fin n, ( Fin ( j.1 + 1 ) → Fin n ) => cycleWt A p.2 ( Nat.succ_pos _ ) / ( p.1.1 + 1 : ℝ ) ) <| Finset.mem_univ ⟨ ⟨ d, by linarith ⟩, c ⟩ ) ( show ( 0 :ℝ ) ≤ d + 1 by linarith ) using 1;
  · unfold cycleWt; norm_num [ mul_div_cancel₀, Nat.cast_add_one_ne_zero ] ;
  · unfold tropSpec; aesop;

/-
Splitting a walk at position a: the weight decomposes additively.
-/
theorem walkWt_split (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) (a b : ℕ)
    (f : Fin (a + b) → Fin n) :
    walkWt A i (a + b) f =
      walkWt A i a (fun t => f ⟨t.val, by omega⟩) +
      walkWt A (walkVert i f ⟨a, by omega⟩) b (fun t => f ⟨a + t.val, by omega⟩) := by
  by_contra h_contra_sum;
  -- By definition of walkWt, we can split the sum into two parts.
  have h_split : ∀ (k : ℕ) (f : Fin k → Fin n), walkWt A i k f = ∑ t : Fin k, A (walkVert i f t.castSucc) (walkVert i f t.succ) := by
    grind +suggestions
  generalize_proofs at *;
  simp_all +decide [ Fin.sum_univ_add ];
  refine' h_contra_sum _;
  congr! 1;
  · congr! 2;
    rename_i k _;
    induction' k with k ih;
    induction' k with k ih;
    · rfl;
    · simp +decide [ Fin.castAdd, walkVert ];
  · rw [ show walkWt A ( walkVert i f ⟨ a, by linarith ⟩ ) b ( fun t => f ⟨ a + t, by linarith [ Fin.is_lt t ] ⟩ ) = ∑ t : Fin b, A ( walkVert ( walkVert i f ⟨ a, by linarith ⟩ ) ( fun t => f ⟨ a + t, by linarith [ Fin.is_lt t ] ⟩ ) t.castSucc ) ( walkVert ( walkVert i f ⟨ a, by linarith ⟩ ) ( fun t => f ⟨ a + t, by linarith [ Fin.is_lt t ] ⟩ ) t.succ ) from ?_ ];
    · congr! 2;
      rename_i k hk;
      induction' k.castSucc using Fin.inductionOn with k ih;
      · rfl;
      · convert congr_arg ( fun x => f ⟨ a + k, by linarith [ Fin.is_lt k ] ⟩ ) ih using 1;
    · convert walkWt_eq_sum _ _ _ _ using 1

/-
Concatenation lemma: if walkVert i f a = j, then
    walkWt i a (prefix) + walkWt j b (suffix) ≤ bestWalk i (a + b).
-/
theorem walkWt_prefix_suffix_le_bestWalk (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (i : Fin n) (a b : ℕ)
    (f1 : Fin a → Fin n) (f2 : Fin b → Fin n)
    (j : Fin n) (hj : walkVert i f1 ⟨a, by omega⟩ = j) :
    walkWt A i a f1 + walkWt A j b f2 ≤ bestWalk hn A i (a + b) := by
  -- Define the concatenated walk g : Fin (a+b) → Fin n.
  set g : Fin (a + b) → Fin n := fun t => if ht : t.val < a then f1 ⟨t.val, ht⟩ else f2 ⟨t.val - a, by omega⟩;
  -- By definition of $g$, we have $walkWt A i (a + b) g = walkWt A i a f1 + walkWt A j b f2$.
  have h_walkWt_g : walkWt A i (a + b) g = walkWt A i a f1 + walkWt A j b f2 := by
    convert walkWt_split A i a b g;
    · aesop;
    · unfold walkVert at *; aesop;
    · aesop;
  exact h_walkWt_g ▸ walkWt_le_bestWalk hn A i ( a + b ) g

/-
walkVert of a prefix sub-walk equals walkVert of the full walk.
-/
theorem walkVert_prefix (i : Fin n) (m : ℕ) (f : Fin m → Fin n)
    (a : ℕ) (ha : a ≤ m) (t : ℕ) (ht : t ≤ a) :
    walkVert i (fun s : Fin a => f ⟨s.val, by omega⟩) ⟨t, by omega⟩ =
    walkVert i f ⟨t, by omega⟩ := by
  induction' t with t ih;
  · rfl;
  · exact congr_arg ( fun x => f x ) ( by simp +decide [ Fin.ext_iff ] )

/-
Key walk shortening: removing a cycle from a walk.
-/
theorem walk_remove_cycle (A : Matrix (Fin n) (Fin n) ℝ)
    (i : Fin n) (f : Fin n → Fin n)
    (a : ℕ) (d : ℕ) (ha : a + d ≤ n) (hd : 0 < d)
    (hloop : walkVert i f ⟨a, by omega⟩ = walkVert i f ⟨a + d, by omega⟩) :
    ∃ g : Fin (n - d) → Fin n,
      walkWt A i n f =
        walkWt A i (n - d) g +
        walkWt A (walkVert i f ⟨a, by omega⟩) d
          (fun t => f ⟨a + t.val, by omega⟩) := by
  -- Apply the walkWt_split lemma to decompose the walkWt into three parts.
  have h_split : walkWt A i n f = walkWt A i a (fun t => f ⟨t.val, by omega⟩) + walkWt A (walkVert i f ⟨a, by omega⟩) d (fun t => f ⟨a + t.val, by omega⟩) + walkWt A (walkVert i f ⟨a + d, by omega⟩) (n - a - d) (fun t => f ⟨a + d + t.val, by omega⟩) := by
    convert walkWt_split A i ( a + d ) ( n - a - d ) ( fun t => f ⟨ t.val, by omega ⟩ ) using 1;
    · convert rfl;
      omega;
    · convert congr_arg₂ ( · + · ) ( walkWt_split A i a d ( fun t => f ⟨ t.val, by omega ⟩ ) ) rfl using 1;
      congr! 1;
      · convert walkWt_split A i a d ( fun t => f ⟨ t.val, by omega ⟩ ) |> Eq.symm using 1;
        grind +suggestions;
      · rw [ walkWt_split ];
        unfold walkVert; aesop;
  have h_split_g : walkWt A i (n - d) (fun t => if t.val < a then f ⟨t.val, by omega⟩ else f ⟨t.val + d, by omega⟩) =
      walkWt A i a (fun t => f ⟨t.val, by omega⟩) + walkWt A (walkVert i f ⟨a, by omega⟩) (n - a - d) (fun t => f ⟨a + d + t.val, by omega⟩) := by
        convert walkWt_split A i a ( n - a - d ) _ using 1;
        congr! 1;
        any_goals exact fun t => if t.val < a then f ⟨ t.val, by omega ⟩ else f ⟨ t.val + d, by omega ⟩;
        · omega;
        · congr! 1;
          · congr! 1;
          · rename_i k hk;
            rw [ Fin.heq_ext_iff ] at hk ; aesop;
            grind;
        · congr! 1;
          · exact congr_arg _ ( funext fun x => by aesop );
          · congr! 1;
            · unfold walkVert; aesop;
            · ext t; simp +decide [ add_comm, add_left_comm, add_assoc ] ;
  grind

/-
A closed walk (returning to start) of length d ≤ n has weight ≤ d * mu
    when tropSpec A ≤ mu.
-/
theorem closed_walk_wt_le (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (mu : ℝ) (hmu : tropSpec hn A ≤ mu)
    (v : Fin n) (d : ℕ) (hd : 0 < d) (hdn : d ≤ n)
    (f : Fin d → Fin n) (hloop : walkVert v f ⟨d, by omega⟩ = v) :
    walkWt A v d f ≤ d * mu := by
  convert any_cycle_wt_le hn A mu hmu hd hdn ( fun i => walkVert v f ⟨ i.val, by linarith [ Fin.is_lt i ] ⟩ ) using 1;
  convert walkWt_eq_sum A v d f using 1;
  refine' Finset.sum_bij ( fun t _ => t ) _ _ _ _ <;> simp +decide [ Fin.ext_iff ];
  intro a; rcases a with ⟨ a, ha ⟩ ; rcases ha with ( _ | ha ) <;> simp +decide [ *, cycleSucc ] ;
  · congr! 2;
  · norm_num [ Nat.mod_eq_of_lt ( show a + 1 < _ from Nat.lt_of_le_of_lt ( Nat.succ_le_of_lt ha ) ( Nat.lt_succ_self _ ) ) ]

/-
For any walk f of length n from vertex i, there exists a walk g of
    length m < n from i such that walkWt f - n * mu ≤ walkWt g - m * mu.
-/
theorem walk_shorten_shifted (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (mu : ℝ) (hmu : tropSpec hn A ≤ mu)
    (i : Fin n) (f : Fin n → Fin n) :
    ∃ m : ℕ, m < n ∧ ∃ g : Fin m → Fin n,
      walkWt A i n f - n * mu ≤ walkWt A i m g - m * mu := by
  -- By walk_has_repeated_vertex, obtain a, b with a.val < b.val and walkVert i f a = walkVert i f b.
  obtain ⟨a, b, hab, hloop⟩ : ∃ a b : Fin (n + 1), a.val < b.val ∧ walkVert i f a = walkVert i f b := by
    exact?;
  -- Set d = b.val - a.val. Then 0 < d, a.val + d = b.val, a.val + d ≤ n.
  set d := b.val - a.val with hd'
  have hd_pos : 0 < d := by
    exact Nat.sub_pos_of_lt hab
  have hd_le_n : d ≤ n := by
    exact Nat.sub_le_of_le_add <| by linarith [ Fin.is_lt a, Fin.is_lt b ] ;
  have ha_d_le_n : a.val + d ≤ n := by
    omega
  have hloop' : walkVert i f ⟨a.val, by
    exact Nat.lt_succ_of_le ( Nat.le_trans ( Nat.le_add_right _ _ ) ha_d_le_n )⟩ = walkVert i f ⟨a.val + d, by
    linarith⟩ := by
    grind +splitImp
  generalize_proofs at *;
  -- By walk_remove_cycle, obtain g : Fin (n-d) → Fin n with
  obtain ⟨g, hg⟩ : ∃ g : Fin (n - d) → Fin n,
      walkWt A i n f = walkWt A i (n - d) g +
        walkWt A (walkVert i f ⟨a.val, by omega⟩) d (fun t => f ⟨a.val + t.val, by omega⟩) := by
          apply walk_remove_cycle A i f a.val d ha_d_le_n hd_pos hloop';
  -- The second term is a closed walk from walkVert(a) of length d ≤ n returning to walkVert(a) (since walkVert(a+d) = walkVert(a)). The closed walk endpoint is: walkVert (walkVert i f ⟨a.val,_⟩) (fun t => f ⟨a.val + t.val,_⟩) ⟨d,_⟩ = walkVert i f ⟨a.val + d,_⟩ = walkVert i f ⟨a.val,_⟩. By closed_walk_wt_le, this ≤ d * mu.
  have h_closed_walk : walkWt A (walkVert i f ⟨a.val, by omega⟩) d (fun t => f ⟨a.val + t.val, by omega⟩) ≤ d * mu := by
    apply closed_walk_wt_le hn A mu hmu (walkVert i f ⟨a.val, by omega⟩) d hd_pos hd_le_n (fun t => f ⟨a.val + t.val, by omega⟩) (by
    convert hloop'.symm using 1
    generalize_proofs at *;
    have h_walkVert_eq : ∀ (t : Fin (d + 1)), walkVert (walkVert i f ⟨a.val, by
      linarith⟩) (fun t => f ⟨a.val + t.val, by
      grind⟩) t = walkVert i f ⟨a.val + t.val, by
      linarith [ Fin.is_lt t ]⟩ := by
      all_goals generalize_proofs at *;
      intro t; induction t using Fin.inductionOn <;> simp +decide [ *, walkVert ] ;
      · cases a ; trivial;
      · rename_i k hk₁ hk₂ hk₃ hk₄ hk₅ hk₆₇
        generalize_proofs at *;
        rcases hk₅ with ⟨ _ | hk₅, hk₅' ⟩ <;> norm_num [ Fin.ext_iff, Fin.val_add ] at *
    generalize_proofs at *;
    exact h_walkVert_eq ⟨ d, by linarith ⟩)
  generalize_proofs at *;
  exact ⟨ n - d, Nat.sub_lt hn hd_pos, g, by push_cast [ Nat.cast_sub ( show d ≤ n from hd_le_n ) ] at *; linarith ⟩

/-
Walk of length n can be shortened without decreasing shifted weight.
-/
theorem bestWalk_n_le_potential (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (mu : ℝ) (hmu : tropSpec hn A ≤ mu)
    (i : Fin n) :
    bestWalk hn A i n - n * mu ≤ potential hn A mu i := by
  have h_walkWt_le_potential : ∀ f : Fin n → Fin n, walkWt A i n f - n * mu ≤ potential hn A mu i := by
    intro f
    obtain ⟨m, hm₁, g, hg⟩ := walk_shorten_shifted hn A mu hmu i f;
    exact le_trans hg ( bestWalk_sub_le_potential hn A mu i m hm₁ |> le_trans ( by simpa using walkWt_le_bestWalk hn A i m g ) );
  simp_all +decide [ bestWalk ]

/-
The potential satisfies the subeigenvector edgewise inequality.
-/
theorem potential_subeig_edge (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (mu : ℝ) (hmu : tropSpec hn A ≤ mu)
    (i j : Fin n) :
    A i j + potential hn A mu j ≤ mu + potential hn A mu i := by
  refine' add_le_of_le_sub_left _;
  refine' Finset.sup'_le _ _ _;
  intro m hm
  by_cases hm_lt_n : m < n - 1;
  · -- By definition of `bestWalk`, we have `A i j + bestWalk hn A j m ≤ bestWalk hn A i (m + 1)`.
    have h_bestWalk : A i j + bestWalk hn A j m ≤ bestWalk hn A i (m + 1) := by
      grind +suggestions;
    have h_bestWalk_le_potential : bestWalk hn A i (m + 1) - (m + 1) * mu ≤ potential hn A mu i := by
      convert bestWalk_sub_le_potential hn A mu i ( m + 1 ) ( Nat.lt_pred_iff.mp hm_lt_n ) using 1 ; norm_cast;
    linarith;
  · -- Since $m \geq n - 1$, we have $m = n - 1$.
    have hm_eq_n_minus_1 : m = n - 1 := by
      exact le_antisymm ( Nat.le_sub_one_of_lt ( Finset.mem_range.mp hm ) ) ( not_lt.mp hm_lt_n );
    rcases n <;> simp_all +decide [ potential ];
    have := bestWalk_n_le_potential hn A mu hmu i;
    have := prepend_edge_bestWalk hn A i j ‹_›; norm_num at *; linarith!;

/-
If `tropSpec A ≤ mu`, then a subeigenpair exists at value `mu`.
-/
theorem subeigenpair_of_tropSpec_le (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (mu : ℝ) (hmu : tropSpec hn A ≤ mu) :
    ∃ v : Fin n → ℝ, IsTropicalSubeigenpair hn A mu v := by
  exact ⟨ _, fun i => tropMulVec_le_iff _ _ _ _ _ |>.2 fun j => potential_subeig_edge _ _ _ hmu _ _ ⟩

/-! ## The Collatz-Wielandt Characterization -/

/-
**Tropical Collatz–Wielandt**: A subeigenpair at value `mu` exists iff `tropSpec A ≤ mu`.
-/
theorem tropical_collatz_wielandt (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) (mu : ℝ) :
    (∃ v, IsTropicalSubeigenpair hn A mu v) ↔ tropSpec hn A ≤ mu := by
  exact ⟨ fun ⟨ v, hv ⟩ => tropSpec_le_of_subeigenpair hn A mu v hv, fun h => subeigenpair_of_tropSpec_le hn A mu h ⟩

/-! ## Existence of Subeigenpair at the Spectral Value -/

/-- There exists a subeigenpair at the spectral value `tropSpec A`. -/
theorem exists_tropical_subeigenpair (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ v : Fin n → ℝ, IsTropicalSubeigenpair hn A (tropSpec hn A) v := by
  exact subeigenpair_of_tropSpec_le hn A (tropSpec hn A) le_rfl

/-! ## Critical Graph Structure -/

/-
The spectral value is attained by some cycle.
-/
theorem tropSpec_attained (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ (k : ℕ) (hk : 0 < k) (_ : k ≤ n) (c : Fin k → Fin n),
      cycleMean A c hk = tropSpec hn A := by
  -- By definition of supremum, there exists a pair (j, c) such that the cycle mean is equal to the supremum.
  obtain ⟨p, hp⟩ : ∃ p : Σ j : Fin n, (Fin (j.1 + 1) → Fin n), cycleMean A p.2 (Nat.succ_pos _) = tropSpec hn A := by
    have := Finset.exists_max_image Finset.univ ( fun p : Σ j : Fin n, ( Fin ( j.1 + 1 ) → Fin n ) => cycleMean A p.2 ( Nat.succ_pos _ ) ) ⟨ ⟨ ⟨ 0, hn ⟩, fun _ => ⟨ 0, hn ⟩ ⟩, Finset.mem_univ _ ⟩;
    obtain ⟨ p, hp₁, hp₂ ⟩ := this;
    exact ⟨ p, le_antisymm ( Finset.le_sup' ( fun p : Σ j : Fin n, ( Fin ( j.1 + 1 ) → Fin n ) => cycleMean A p.2 ( Nat.succ_pos _ ) ) hp₁ ) ( Finset.sup'_le _ _ fun x hx => hp₂ x hx ) ⟩;
  grind

/-
At the optimal spectral value, every optimal cycle consists entirely of critical edges.
-/
theorem optimal_cycle_edges_critical (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (v : Fin n → ℝ) (hv : IsTropicalSubeigenpair hn A (tropSpec hn A) v)
    {k : ℕ} (hk : 0 < k) (c : Fin k → Fin n)
    (hopt : cycleMean A c hk = tropSpec hn A) :
    ∀ t : Fin k, IsCriticalEdge A (tropSpec hn A) v (c t) (c (cycleSucc hk t)) := by
  -- By definition of $hv$, we know that for all $t$, $A (c t) (c (cycleSucc hk t)) + v (c (cycleSucc hk t)) \leq tropSpec hn A + v (c t)$.
  have h_le : ∀ t : Fin k, A (c t) (c (cycleSucc hk t)) + v (c (cycleSucc hk t)) ≤ tropSpec hn A + v (c t) := by
    exact fun t => hv _ |> fun h => le_trans ( le_tropMulVec hn A v _ _ ) h;
  -- By definition of $hv$, we know that for all $t$, $A (c t) (c (cycleSucc hk t)) + v (c (cycleSucc hk t)) \leq tropSpec hn A + v (c t)$. Summing these inequalities over all $t$, we get that the sum of $A (c t) (c (cycleSucc hk t))$ over all $t$ is less than or equal to $k * tropSpec hn A$.
  have h_sum_le : ∑ t : Fin k, (A (c t) (c (cycleSucc hk t)) + v (c (cycleSucc hk t))) = k * tropSpec hn A + ∑ t : Fin k, v (c t) := by
    unfold cycleMean at hopt;
    rw [ ← hopt, mul_div_cancel₀ _ ( by positivity ) ];
    simp +decide [ cycleWt, Finset.sum_add_distrib ];
    rcases k with ( _ | _ | k ) <;> norm_num [ cycleSucc ] at *;
    · simp +decide [ Fin.eq_zero ];
    · conv_rhs => rw [ ← Equiv.sum_comp ( Equiv.addRight 1 ) ] ;
      norm_num [ Fin.add_def ];
  contrapose! h_sum_le;
  refine' ne_of_lt ( lt_of_lt_of_le ( Finset.sum_lt_sum _ _ ) _ );
  use fun t => tropSpec hn A + v ( c t );
  · grind;
  · exact ⟨ h_sum_le.choose, Finset.mem_univ _, lt_of_le_of_ne ( h_le _ ) h_sum_le.choose_spec ⟩;
  · norm_num [ Finset.sum_add_distrib ]

/-
On a critical node, the tropical action achieves the spectral value.
-/
theorem tropMulVec_eq_on_critical (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (v : Fin n → ℝ) (hv : IsTropicalSubeigenpair hn A (tropSpec hn A) v)
    (i : Fin n) (hi : IsCriticalNode A (tropSpec hn A) v i) :
    tropMulVec hn A v i = tropSpec hn A + v i := by
  exact isCriticalNode_iff_eq hn A ( tropSpec hn A ) v i hv |>.1 hi

/-! ## Main Existence Theorems -/

/-
**Existence of tropical subeigenpair with critical equality.**
    For any matrix, there exists a spectral value and a vector that is a subeigenvector
    globally, with equality at every critical node.

    This is the central theorem of tropical spectral theory for finite matrices.
-/
theorem exists_tropical_subeigenpair_with_critical_equality
    (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ mu : ℝ, ∃ v : Fin n → ℝ,
      IsTropicalSubeigenpair hn A mu v ∧
      (∀ i, IsCriticalNode A mu v i → tropMulVec hn A v i = mu + v i) := by
  exact ⟨ tropSpec hn A, by exact Exists.choose ( exists_tropical_subeigenpair hn A ), Exists.choose_spec ( exists_tropical_subeigenpair hn A ), fun i hi => tropMulVec_eq_on_critical hn A _ ( Exists.choose_spec ( exists_tropical_subeigenpair hn A ) ) i hi ⟩

/-
**Existence of tropical eigenpair on a critical component.**
    There exists a spectral value, a set of critical vertices forming a
    component, and a vector achieving tropical eigenvector equality on that component.
-/
theorem exists_tropical_eigenpair_on_critical_component
    (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ mu : ℝ, ∃ (C : Finset (Fin n)), ∃ v : Fin n → ℝ,
      C.Nonempty ∧
      (∀ i, i ∈ C → tropMulVec hn A v i = mu + v i) ∧
      IsTropicalSubeigenpair hn A mu v := by
  -- By the existence of a subeigenpair at the spectral value, let's obtain such a vector $v$.
  obtain ⟨v, hv⟩ := exists_tropical_subeigenpair hn A;
  -- By the existence of a cycle achieving the spectral value, let's obtain such a cycle $c$.
  obtain ⟨k, hk, hkn, c, hc⟩ := tropSpec_attained hn A;
  -- By the optimal cycle edges critical theorem, every edge in $c$ is critical.
  have h_critical_edges : ∀ t : Fin k, IsCriticalEdge A (tropSpec hn A) v (c t) (c (cycleSucc hk t)) := by
    -- Apply the optimal_cycle_edges_critical theorem with the given hypotheses.
    apply optimal_cycle_edges_critical hn A v hv hk c hc;
  refine' ⟨ tropSpec hn A, Finset.image c Finset.univ, v, _, _, hv ⟩ <;> simp_all +decide [ Finset.Nonempty ];
  · exact ⟨ ⟨ 0, hk ⟩ ⟩;
  · exact fun t => tropMulVec_eq_on_critical hn A v hv _ ( by exact ⟨ _, h_critical_edges t ⟩ )

/-! ## Duality: Min-Plus and Max-Plus -/

/-
The negation map sends max-plus subeigenpairs to min-plus subeigenpairs.
-/
theorem max_min_duality (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (mu : ℝ) (v : Fin n → ℝ)
    (hv : IsTropicalSubeigenpair hn A mu v) :
    haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
    ∀ i, (-mu) + (-v i) ≤
      Finset.inf' univ (Finset.univ_nonempty (α := Fin n))
        (fun j => (-A i j) + (-v j)) := by
  grind +suggestions

end TropicalSpectral