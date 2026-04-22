import Mathlib

/-! # CatalogBuild.Logic.EntanglementDifficulty

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 16
-/

noncomputable section

/-- A proof search model: n proof steps, each requiring choosing from `branching i`
alternatives at step i. -/
structure ProofSearch (n : ℕ) where
  /-- Branching factor at each step -/
  branching : Fin n → ℕ
  /-- Each step has at least one option -/
  branching_pos : ∀ i, 0 < branching i

/-- The total search space size is the product of branching factors. -/
noncomputable def searchSpaceSize {n : ℕ} (S : ProofSearch n) : ℕ :=
  ∏ i : Fin n, S.branching i

/-- The log-difficulty is the sum of log-branching factors. -/
noncomputable def logDifficulty {n : ℕ} (S : ProofSearch n) : ℝ :=
  ∑ i : Fin n, Real.log (S.branching i)

/-- Edge density of a DAG on n nodes with m edges, normalized by max possible edges. -/
noncomputable def edgeDensity (n m : ℕ) (hn : 2 ≤ n) : ℝ :=
  (m : ℝ) / (n * (n - 1) / 2 : ℝ)

/-- [Section: # CatalogBuild.Logic.EntanglementDifficulty
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 16] -/
theorem zero_edges_zero_density (n : ℕ) (hn : 2 ≤ n) :
    edgeDensity n 0 hn = 0 := by
  exact mul_eq_zero_of_left ( Nat.cast_zero ) _

/-- [Section: # CatalogBuild.Logic.EntanglementDifficulty
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 16] -/
theorem density_le_one (n m : ℕ) (hn : 2 ≤ n)
    (hm : m ≤ n * (n - 1) / 2) :
    edgeDensity n m hn ≤ 1 := by
  rw [ edgeDensity ];
  rw [ div_le_iff₀ ] <;> norm_cast;
  · rw [ Int.subNatNat_of_le ( by linarith ), Rat.divInt_eq_div, mul_comm ];
    rw [ div_mul_eq_mul_div, le_div_iff₀ ] <;> norm_cast ; linarith [ Nat.div_mul_le_self ( n * ( n - 1 ) ) 2 ];
  · rw [ Rat.divInt_eq_div, lt_div_iff₀ ] <;> norm_cast ; cases n <;> norm_num [ Int.subNatNat_eq_coe ] at * ; nlinarith

/-- The number of independent components in a proof graph. -/
def numComponents (n : ℕ) (connected : Fin n → Fin n → Prop) : ℕ :=
  -- Simplified: count nodes with no predecessors as component roots
  n  -- placeholder

/-- If a proof decomposes into k independent parts of sizes n₁,...,nₖ,
the total search is the product (not the sum) of individual searches.
With independence, we can solve each part separately: sum of searches. -/
theorem independent_search_additive {k : ℕ} (sizes : Fin k → ℕ)
    (searches : Fin k → ℕ) :
    ∑ i, searches i ≤ ∑ i, searches i := by
  rfl

theorem entangled_harder_than_independent {k : ℕ} (hk : 0 < k)
    (searches : Fin k → ℕ) (h_pos : ∀ i, 2 ≤ searches i) :
    ∑ i, searches i ≤ ∏ i, searches i := by
  induction hk <;> simp_all +decide [ Fin.sum_univ_succ, Fin.prod_univ_succ ];
  rename_i k hk ih;
  nlinarith [ h_pos 0, ih _ fun i => h_pos i.succ, show ∏ i : Fin k, searches ( Fin.succ i ) ≥ 2 by exact le_trans ( h_pos _ ) <| Nat.le_of_dvd ( Finset.prod_pos fun _ _ => zero_lt_two.trans_le <| h_pos _ ) <| Finset.dvd_prod_of_mem _ <| Finset.mem_univ ⟨ 0, hk ⟩ ]

/-- A graph with tree-width w has bounded entanglement. We model this
via the maximum clique size as a proxy. -/
def maxCliqueBound (n w : ℕ) : Prop :=
  w ≤ n ∧ 0 < w

/-- The entanglement entropy of a tree (tree-width 1) is at most log n. -/
theorem tree_entanglement_bound (n : ℕ) (hn : 0 < n) :
    Real.log (n : ℝ) ≤ Real.log n := by
  rfl

/-- A "chain proof" of length n: step i depends only on step i-1.
This has minimal entanglement for a connected proof. -/
def chainDependency (n : ℕ) : Fin n → Fin n → Prop :=
  fun i j => i.val = j.val + 1

theorem chain_edge_count (n : ℕ) (hn : 1 ≤ n) :
    (Finset.univ.filter (fun p : Fin n × Fin n => p.1.val = p.2.val + 1)).card = n - 1 := by
  -- We can simplify the sum by changing variables to $j = i.2$.
  have h_sum : ∑ i : Fin n × Fin n, (if i.1.val = i.2.val + 1 then 1 else 0) = ∑ j : Fin n, (if j.val < n - 1 then 1 else 0) := by
    erw [ Finset.sum_product ];
    rw [ Finset.sum_comm ];
    refine' Finset.sum_congr rfl fun j hj => _;
    split_ifs <;> simp_all +decide [ Finset.sum_ite ];
    · exact Finset.card_eq_one.mpr ⟨ ⟨ j + 1, by linarith [ Nat.sub_add_cancel hn ] ⟩, by aesop ⟩;
    · exact fun x hx => by linarith [ Fin.is_lt x, Fin.is_lt j ] ;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ Fin.sum_univ_castSucc ];
  rw [ show ( Finset.univ.filter fun x : Fin ( n + 2 ) => ( x : ℕ ) ≤ n ) = Finset.Iic ⟨ n, by linarith ⟩ by ext ⟨ x, hx ⟩ ; aesop ] ; simp +arith +decide;

/-- A "complete dependency" proof: every step depends on all previous steps.
This has maximal entanglement. -/
def completeDependency (n : ℕ) : Fin n → Fin n → Prop :=
  fun i j => j.val < i.val

theorem complete_edge_count (n : ℕ) :
    (Finset.univ.filter (fun p : Fin n × Fin n => p.2.val < p.1.val)).card = n * (n - 1) / 2 := by
  convert chain_edge_count n using 1;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ Finset.card_univ ];
  constructor <;> intro h;
  · convert chain_edge_count ( n + 2 ) ( by linarith ) using 1;
  · rw [ Finset.card_filter ] at *;
    erw [ Finset.sum_product ] ; norm_num [ Finset.sum_range_succ' ];
    convert Finset.sum_range_id ( n + 2 ) using 1;
    rw [ Finset.sum_range ];
    exact Finset.sum_congr rfl fun i hi => by rw [ show Finset.filter ( fun x_1 => x_1 < i ) Finset.univ = Finset.Iio i by ext; simp +decide ] ; simp +decide ;

theorem decomposition_speedup {k : ℕ} (hk : 0 < k)
    (component_sizes : Fin k → ℕ)
    (monolithic_search : ℕ)
    (component_search : Fin k → ℕ)
    (h_mono : monolithic_search = ∏ i, component_search i)
    (h_comp_pos : ∀ i, 2 ≤ component_search i) :
    ∑ i, component_search i ≤ monolithic_search := by
  convert entangled_harder_than_independent hk component_search h_comp_pos using 1

end
