/-
# The Depth of the Prime Barcode

This file deepens the study of the zero-dimensional persistent homology of the
prime point cloud begun in `PrimePersistentHomology.lean`.  Recall that the
`n`-th prime sits at position `p_n` on the real line, that the Vietoris–Rips
filtration joins two points within distance `ε`, and that the degree-zero
barcode is governed entirely by the *gaps* between consecutive primes.

Here we extend that picture in four directions.

## Main results

* `PrimePH.RipsConn_mono` — **the persistence module structure.**  Enlarging the
  scale can only merge components: connectivity at scale `ε` implies connectivity
  at every larger scale `ε'`.  This is the functoriality that makes the family
  `{R_ε}` a genuine persistence module.

* `PrimePH.total_persistence_primeGap` — **total persistence telescopes.**  The
  sum of the first `n` bar lengths (prime gaps) equals `p_n − 2`: the aggregate
  persistence of the `H_0` barcode up to index `n` is exactly the displacement of
  the point cloud, `p_n − p_0`.

* `PrimePH.connected_iff_sup_primeGap` — **the global merge scale.**  The first
  `n+1` primes form a single component at scale `ε` if and only if `ε` is at least
  the largest gap among them.  Thus the death scale of the last surviving `H_0`
  bar is the maximum prime gap in the window.

* `PrimePH.barcode_unbounded` / `PrimePH.exists_unmerged_adjacent` — **the barcode
  is unbounded.**  For every scale `M` there is a bar that is still alive: prime
  gaps are arbitrarily large, so the `H_0` barcode contains bars of every length.
  This is proved from the classical factorial construction of arbitrarily long
  runs of composite numbers.

* `PrimePH.betti_eq_one_add_breaks` — **the Betti number of the prime cloud.**
  The number of connected components (the zeroth Betti number `b₀`) of the first
  `n+1` primes at scale `ε` equals `1` plus the number of gaps exceeding `ε`.
  Combined with `conn_iff_compRoot`, which identifies components with the fibres
  of a canonical "component-root" map, this is the exact `H_0` rank at every
  scale.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  The barcode of the primes should (i) be a genuine
persistence module, (ii) have total persistence equal to the point-cloud
displacement, (iii) fully merge exactly at the largest gap, (iv) contain bars of
unbounded length, and (v) have a Betti number computable from the gap sequence.

Experiment (Experimenter).  Functoriality follows from monotonicity of the Rips
edge relation under the reflexive–transitive closure.  Total persistence is a
telescoping sum.  The global merge scale is `single-linkage` specialised to the
supremum of the gaps.  Unboundedness uses the factorial run
`(k+1)!+2, …, (k+1)!+(k+1)` of composites, transported to consecutive primes via
the `count`/`nth` correspondence.  The Betti number is counted through an
explicit component-root function `compRoot`, whose fibres are the components.

Analysis (Analyst).  On a line the barcode is a purely combinatorial object: the
component-root map turns "connected component" into "value of a recursively
defined function", so counting components becomes counting its image, which is in
bijection with the set of large gaps.  The only genuinely arithmetic input is the
unbounded-gap theorem.

Critique (Critic).  `conn_iff_compRoot` shows the root map really does compute the
connectivity relation (not a redefinition), so `betti_eq_one_add_breaks` counts
the true `H_0` rank.  The unbounded-barcode theorem is stated over the honest real
scale and uses no circular reference to itself.

Synthesis.  The prime barcode is a persistence module whose ranks, total
persistence, global merge scale, and unbounded tail are all read off the gap
sequence — the topology of the primes is the combinatorics of their gaps.
-/
import Mathlib
import Novelty.PrimePersistentHomology

open Relation Classical

namespace PrimePH

/-! ### 1. The persistence module structure (functoriality in the scale) -/

/-- Enlarging the scale preserves adjacency. -/
lemma RipsAdj_mono {p : ℕ → ℝ} {ε ε' : ℝ} (h : ε ≤ ε') {a b : ℕ}
    (hab : RipsAdj p ε a b) : RipsAdj p ε' a b := by
  exact le_trans hab h

/-
**Persistence module structure.**  If two indices lie in the same component at
scale `ε`, they lie in the same component at every larger scale `ε'`.
-/
theorem RipsConn_mono {p : ℕ → ℝ} {ε ε' : ℝ} (h : ε ≤ ε') {i j : ℕ}
    (hconn : RipsConn p ε i j) : RipsConn p ε' i j := by
  exact hconn.mono fun a b hab => RipsAdj_mono h hab

/-! ### 2. Total persistence telescopes -/

/-
The sum of the first `n` bar lengths is the displacement of the point cloud.
-/
theorem total_persistence_eq {p : ℕ → ℝ} (n : ℕ) :
    ∑ k ∈ Finset.range n, (p (k + 1) - p k) = p n - p 0 := by
  rw [ Finset.sum_range_sub ]

/-
**Total persistence of the prime barcode.**  The sum of the first `n` prime
gaps equals `p_n − 2`.
-/
theorem total_persistence_primeGap (n : ℕ) :
    ∑ k ∈ Finset.range n, (TwinPrimeGaps.primeGap k : ℝ) = P n - 2 := by
  convert PrimePH.total_persistence_eq n using 1;
  exact Finset.sum_congr rfl fun _ _ => ( PrimePH.death_scale_eq_primeGap _ ).symm;
  unfold P;
  norm_num [ Nat.Prime.ne_zero, Nat.Prime.ne_one ]

/-! ### 3. The global merge scale is the maximum gap -/

/-
**Global merge scale.**  For `n ≥ 1`, the first `n+1` primes form one component
at scale `ε` iff `ε` is at least the largest gap in the window.
-/
theorem connected_iff_sup_primeGap {ε : ℝ} (hε : 0 ≤ ε) {n : ℕ} (hn : 0 < n) :
    RipsConn P ε 0 n ↔
      (Finset.range n).sup' (Finset.nonempty_range_iff.mpr hn.ne')
        (fun k => (TwinPrimeGaps.primeGap k : ℝ)) ≤ ε := by
  convert PrimePH.line_component_iff PrimePH.P_strictMono hε ( Nat.zero_le n ) using 1;
  simp +decide [ Finset.sup'_le_iff, PrimePH.death_scale_eq_primeGap ]

/-! ### 4. The barcode is unbounded: arbitrarily long bars -/

/-
Every element of the factorial run `(k+1)! + 2, …, (k+1)! + (k+1)` is
composite.
-/
lemma factorial_run_not_prime {k i : ℕ} (hi2 : 2 ≤ i) (hik : i ≤ k + 1) :
    ¬ (Nat.factorial (k + 1) + i).Prime := by
  rw [ Nat.prime_def_lt' ];
  exact fun h => h.2 _ hi2 ( by linarith [ Nat.self_le_factorial ( k + 1 ) ] ) ( Nat.dvd_add ( Nat.dvd_factorial ( by linarith ) ( by linarith ) ) ( dvd_refl _ ) )

/-
The prime-counting function is constant across the factorial run: there are no
primes in the interval `[(k+1)!+2, (k+1)!+2+k)`.
-/
lemma count_prime_run_eq (k : ℕ) :
    Nat.count Nat.Prime (Nat.factorial (k + 1) + 2 + k)
      = Nat.count Nat.Prime (Nat.factorial (k + 1) + 2) := by
  -- By induction on $j$, we can show that for any $j \leq k$, the count of primes at $(k+1)! + 2 + j$ is equal to the count at $(k+1)! + 2$.
  have h_ind : ∀ j ≤ k, Nat.count Nat.Prime ((k + 1).factorial + 2 + j) = Nat.count Nat.Prime ((k + 1).factorial + 2) := by
    intro j hj;
    induction' j with j ih;
    · rfl;
    · convert ih ( Nat.le_of_succ_le hj ) using 1;
      rw [ Nat.add_succ, Nat.count_succ ];
      rw [ if_neg ];
      · norm_num;
      · convert factorial_run_not_prime ( show 2 ≤ 2 + j by linarith ) ( show 2 + j ≤ k + 1 by linarith ) using 1 ; ring_nf;
  exact h_ind k le_rfl

/-
**Prime gaps are unbounded.**  For every bound `B` there is an index whose
prime gap exceeds `B`.
-/
theorem exists_large_primeGap (B : ℕ) : ∃ n, B < TwinPrimeGaps.primeGap n := by
  obtain ⟨k, hk⟩ : ∃ k : ℕ, B < k ∧ 2 ≤ k := by
    exact ⟨ B + 2, by linarith, by linarith ⟩;
  obtain ⟨c, hc⟩ : ∃ c : ℕ, Nat.count Nat.Prime (Nat.factorial (k + 1) + 2) = c := by
    use Nat.count Nat.Prime (Nat.factorial (k + 1) + 2);
  -- By definition of $c$, we know that $Nat.nth Nat.Prime (c - 1) < Nat.factorial (k + 1) + 2$ and $Nat.factorial (k + 1) + 2 + k ≤ Nat.nth Nat.Prime c$.
  have h_left : Nat.nth Nat.Prime (c - 1) < Nat.factorial (k + 1) + 2 := by
    refine' Nat.nth_lt_of_lt_count _;
    rcases c with ( _ | c ) <;> simp_all +decide [ Nat.count_eq_card_filter_range ];
    exact ⟨ 2, Finset.mem_filter.mpr ⟨ Finset.mem_range.mpr ( by linarith [ Nat.self_le_factorial ( k + 1 ) ] ), Nat.prime_two ⟩ ⟩
  have h_right : Nat.factorial (k + 1) + 2 + k ≤ Nat.nth Nat.Prime c := by
    have h_right : c < Nat.count Nat.Prime (Nat.factorial (k + 1) + 2 + k) → False := by
      rw [ ← hc, count_prime_run_eq ] ; aesop;
    contrapose! h_right;
    rw [ Nat.count_eq_card_filter_range ];
    refine' ⟨ _, trivial ⟩;
    refine' lt_of_lt_of_le _ ( Finset.card_mono <| show Finset.image ( Nat.nth Nat.Prime ) ( Finset.range ( c + 1 ) ) ⊆ Finset.filter Nat.Prime ( Finset.range ( ( k + 1 ).factorial + 2 + k ) ) from _ );
    · rw [ Finset.card_image_of_injective _ <| Nat.nth_injective <| Nat.infinite_setOf_prime ] ; simp +arith +decide;
    · exact Finset.image_subset_iff.mpr fun i hi => Finset.mem_filter.mpr ⟨ Finset.mem_range.mpr <| lt_of_le_of_lt ( Nat.nth_monotone ( Nat.infinite_setOf_prime ) <| Finset.mem_range_succ_iff.mp hi ) h_right, Nat.prime_nth_prime i ⟩;
  rcases c <;> simp_all +decide [ TwinPrimeGaps.primeGap ];
  · linarith;
  · grind

/-
**The barcode is unbounded (real scale).**  For every scale `M` there is a bar
whose death scale exceeds `M`.
-/
theorem barcode_unbounded (M : ℝ) : ∃ i, M < (TwinPrimeGaps.primeGap i : ℝ) := by
  obtain ⟨ B, hB ⟩ := exists_nat_gt M;
  exact Exists.elim ( exists_large_primeGap B ) fun n hn => ⟨ n, hB.trans_le ( mod_cast hn.le ) ⟩

/-
**An always-alive bar.**  For every non-negative scale `M` there are
neighbouring primes not yet merged at scale `M`.
-/
theorem exists_unmerged_adjacent {M : ℝ} (hM : 0 ≤ M) :
    ∃ i, ¬ RipsConn P M i (i + 1) := by
  obtain ⟨ i, hi ⟩ := PrimePH.barcode_unbounded M;
  exact ⟨ i, fun h => hi.not_ge <| by simpa using prime_adjacent_component_iff hM i |>.1 h ⟩

/-! ### 5. The zeroth Betti number of the prime cloud -/

/-- The recursively defined *component root*: the smallest index in the connected
component of `k` inside `{0, 1, …, k}`.  Two points share a component precisely
when they share a root (`conn_iff_compRoot`). -/
noncomputable def compRoot (p : ℕ → ℝ) (ε : ℝ) : ℕ → ℕ
  | 0 => 0
  | (k + 1) => if p (k + 1) - p k ≤ ε then compRoot p ε k else (k + 1)

/-- An index is a *left end* (start of a new component) if it is `0` or its gap to
the previous index exceeds `ε`. -/
def isLeftEnd (p : ℕ → ℝ) (ε : ℝ) (k : ℕ) : Prop :=
  k = 0 ∨ ε < p k - p (k - 1)

/-- A *break* occurs at `k` when the gap from `k` to `k+1` exceeds `ε`. -/
def isBreak (p : ℕ → ℝ) (ε : ℝ) (k : ℕ) : Prop :=
  ε < p (k + 1) - p k

lemma compRoot_le {p : ℕ → ℝ} {ε : ℝ} (k : ℕ) : compRoot p ε k ≤ k := by
  induction' k with k ih;
  · rfl;
  · grind +locals

/-
The root of `k` is genuinely connected to `k`.
-/
lemma conn_compRoot {p : ℕ → ℝ} (hp : StrictMono p) {ε : ℝ} (hε : 0 ≤ ε) (k : ℕ) :
    RipsConn p ε (compRoot p ε k) k := by
  induction' k with k ih;
  · exact Relation.ReflTransGen.refl;
  · by_cases h : p (k + 1) - p k ≤ ε <;> simp_all +decide [ compRoot ];
    · exact ih.tail ( by rw [ RipsAdj ] ; exact abs_le.mpr ⟨ by linarith [ hp.monotone ( Nat.le_succ k ) ], by linarith [ hp.monotone ( Nat.le_succ k ) ] ⟩ );
    · rw [ if_neg ( by linarith ) ] ; exact Relation.ReflTransGen.refl;

/-
The root of any index is a left end.
-/
lemma compRoot_isLeftEnd {p : ℕ → ℝ} {ε : ℝ} (k : ℕ) :
    isLeftEnd p ε (compRoot p ε k) := by
  induction' k with k ih <;> simp_all +decide [ isLeftEnd ];
  · exact Or.inl rfl;
  · grind +locals

/-
A left end is its own root (a fixed point of `compRoot`).
-/
lemma compRoot_of_isLeftEnd {p : ℕ → ℝ} {ε : ℝ} {k : ℕ}
    (h : isLeftEnd p ε k) : compRoot p ε k = k := by
  rcases k with ( _ | k ) <;> simp_all +decide [ isLeftEnd ];
  · rfl;
  · exact if_neg ( by linarith )

/-
If every consecutive gap between `a` and `b` is at most `ε`, the two indices
share a root.
-/
lemma compRoot_eq_of_gaps {p : ℕ → ℝ} {ε : ℝ} {a b : ℕ} (hab : a ≤ b)
    (h : ∀ m, a ≤ m → m < b → p (m + 1) - p m ≤ ε) :
    compRoot p ε a = compRoot p ε b := by
  induction' b using Nat.strong_induction_on with b ih generalizing a;
  rcases hab with ( rfl | hab );
  · rfl;
  · rw [ ih _ ( Nat.lt_succ_self _ ) hab fun m hm₁ hm₂ => h m hm₁ ( Nat.lt_succ_of_lt hm₂ ), compRoot ];
    rw [ if_pos ( h _ hab ( Nat.lt_succ_self _ ) ) ]

/-
**Components are the fibres of the root map.**  Two indices lie in the same
`ε`-component iff they share a component root.
-/
theorem conn_iff_compRoot {p : ℕ → ℝ} (hp : StrictMono p) {ε : ℝ} (hε : 0 ≤ ε)
    {i j : ℕ} : RipsConn p ε i j ↔ compRoot p ε i = compRoot p ε j := by
  -- By `PrimePH.gaps_of_chain` and `PrimePH.compRoot_eq_of_gaps`, we have that `RipsConn p ε i j` implies `compRoot p ε i = compRoot p ε j`.
  have h_forward : RipsConn p ε i j → compRoot p ε i = compRoot p ε j := by
    intro h;
    by_cases hij : i ≤ j;
    · apply compRoot_eq_of_gaps hij;
      exact fun m hm₁ hm₂ => gaps_of_chain hp h m ( by aesop ) ( by aesop );
    · have := gaps_of_chain hp h;
      convert compRoot_eq_of_gaps ( show j ≤ i from le_of_not_ge hij ) ( fun k hk₁ hk₂ => this k ( by aesop ) ( by aesop ) ) |> Eq.symm using 1;
  refine' ⟨ h_forward, _ ⟩;
  -- By `PrimePH.conn_compRoot`, we have that `compRoot p ε i` is connected to `i` and `compRoot p ε j` is connected to `j`.
  have h_connected : RipsConn p ε (compRoot p ε i) i ∧ RipsConn p ε (compRoot p ε j) j := by
    exact ⟨ PrimePH.conn_compRoot hp hε i, PrimePH.conn_compRoot hp hε j ⟩;
  intro h_eq
  have h_symm : ∀ a b, RipsConn p ε a b → RipsConn p ε b a := by
    intros a b hab
    induction' hab with a b hab ih;
    · constructor;
    · exact ReflTransGen.head ( show RipsAdj p ε b a from by rw [ RipsAdj, abs_sub_comm ] ; exact ih ) ‹_›;
  exact Relation.ReflTransGen.trans ( h_symm _ _ h_connected.1 ) ( h_eq.symm ▸ h_connected.2 )

/-- The zeroth Betti number of the first `n+1` points at scale `ε`: the number of
connected components, computed as the number of distinct component roots. -/
noncomputable def betti0 (p : ℕ → ℝ) (ε : ℝ) (n : ℕ) : ℕ :=
  ((Finset.range (n + 1)).image (compRoot p ε)).card

/-
The image of the root map on a window is exactly the set of left ends.
-/
lemma image_compRoot_eq_filter_isLeftEnd {p : ℕ → ℝ} {ε : ℝ} (n : ℕ) :
    (Finset.range (n + 1)).image (compRoot p ε)
      = (Finset.range (n + 1)).filter (isLeftEnd p ε) := by
  ext x;
  constructor;
  · simp +zetaDelta at *;
    exact fun k hk hk' => ⟨ hk'.symm ▸ compRoot_le k |> le_trans <| hk, hk'.symm ▸ compRoot_isLeftEnd k ⟩;
  · exact fun hx => Finset.mem_image.mpr ⟨ x, Finset.mem_range.mpr ( Finset.mem_range.mp ( Finset.mem_filter.mp hx |>.1 ) ), by rw [ compRoot_of_isLeftEnd ( Finset.mem_filter.mp hx |>.2 ) ] ⟩

/-
The number of left ends in `{0, …, n}` is `1` plus the number of breaks in
`{0, …, n-1}`.
-/
lemma card_filter_isLeftEnd {p : ℕ → ℝ} {ε : ℝ} (n : ℕ) :
    ((Finset.range (n + 1)).filter (isLeftEnd p ε)).card
      = 1 + ((Finset.range n).filter (isBreak p ε)).card := by
  induction' n with n ih;
  · simp +decide [ Finset.filter_singleton, isLeftEnd ];
  · rw [ Finset.range_add_one, Finset.filter_insert ];
    split_ifs <;> simp_all +decide [ Finset.range_add_one, Finset.filter_insert, isLeftEnd, isBreak ]; all_goals grind

/-
**The zeroth Betti number counts the large gaps.**  The number of connected
components of the first `n+1` points at scale `ε` equals `1` plus the number of
gaps exceeding `ε`.
-/
theorem betti_eq_one_add_breaks {p : ℕ → ℝ} (ε : ℝ) (n : ℕ) :
    betti0 p ε n = 1 + ((Finset.range n).filter (isBreak p ε)).card := by
  rw [ PrimePH.betti0, PrimePH.image_compRoot_eq_filter_isLeftEnd, PrimePH.card_filter_isLeftEnd ]

/-
**The Betti number of the prime barcode.**  The number of `ε`-components of the
first `n+1` primes equals `1` plus the number of prime gaps exceeding `ε`.
-/
theorem prime_betti_eq_one_add_large_gaps (ε : ℝ) (n : ℕ) :
    betti0 P ε n
      = 1 + ((Finset.range n).filter (fun k => ε < (TwinPrimeGaps.primeGap k : ℝ))).card := by
  rw [ betti_eq_one_add_breaks ];
  congr! 2;
  ext; simp [isBreak, death_scale_eq_primeGap]

end PrimePH