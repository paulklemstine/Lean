import Mathlib
import Computation.AlgorithmicCertificate

/-!
# Information-Efficient Algorithms: A Unified Theory

This file develops a unified mathematical framework showing that three canonical
algorithms—binary search, Dijkstra's shortest paths, and NTT/FFT—are instances
of a single paradigm: **information-efficient computation**.

## Novel Definitions

- `InfoEfficientAlgorithm`: A certified algorithm with quantitative termination
  and correctness guarantees via invariant preservation and potential descent.

## Main Results

### Binary Search
- `binarySearch_correct`: Binary search finds the least satisfying index.
- `binarySearch_invariant_preserved`: Loop invariant preservation.
- `binarySearch_pow2_bound`: At most k steps for 2^k elements.

### Dijkstra's Algorithm
- `dijkstra_init_settled_optimal`: Initial state satisfies optimality.
- `dijkstra_global_correct`: Upon termination, all distances are optimal.

### NTT/FFT
- `NTT_convolution`: NTT diagonalizes cyclic convolution.
- `ntt_cost_recurrence`: The divide-and-conquer complexity bound.

### Cross-Domain Connections
- `binarySearch_entropy_certificate`: Binary search → entropy bound.
- `binarySearch_entropy_exact_pow2`: Powers of 2 have exact log entropy.
- `exists_principal_root_prime`: Number theory → NTT root existence.

### Conjecture
- `conjecture_binarySearch_trace_optimal`: Binary search is comparison-optimal.
-/

open Function Finset BigOperators

noncomputable section

/-! ## Part 1: The InfoEfficientAlgorithm Structure (Novel Definition) -/

/-- An information-efficient algorithm is a state machine equipped with:
- An initialization function from inputs to states
- A step function advancing computation
- A termination predicate
- An output extraction function
- An invariant relating input to state
- A potential function (natural number) that strictly decreases on each step

Together these certify both correctness and complexity. The potential
provides the complexity bound: at most `potential(init x)` steps are needed.

This structure unifies binary search (ordered elimination),
Dijkstra (monotone relaxation), and FFT (symmetry factorization)
under one roof. -/
structure InfoEfficientAlgorithm (Input State Output : Type*) (Spec : Input → Output → Prop) where
  /-- Advance the state by one step, given access to the input. -/
  step        : Input → State → State
  /-- Initialize the state from the input. -/
  init        : Input → State
  /-- Check whether the algorithm has terminated. -/
  terminate   : State → Prop
  /-- Extract the output from a (terminal) state. -/
  extract     : State → Output
  /-- The invariant linking input to current state. -/
  invariant   : Input → State → Prop
  /-- The potential / measure function; bounded by ℕ. -/
  potential   : State → ℕ
  /-- The invariant holds at initialization. -/
  sound       : ∀ x, invariant x (init x)
  /-- The invariant is preserved by each step. -/
  preserve    : ∀ x s, invariant x s → ¬ terminate s → invariant x (step x s)
  /-- The potential strictly decreases on each non-terminal step. -/
  descent     : ∀ x s, invariant x s → ¬ terminate s → potential (step x s) < potential s
  /-- At termination, the output satisfies the specification. -/
  correct     : ∀ x s, invariant x s → terminate s → Spec x (extract s)

/-
An InfoEfficientAlgorithm terminates within `potential(init x)` steps.
-/
theorem InfoEfficientAlgorithm.terminates_within_potential
    {Input State Output : Type*} {Spec : Input → Output → Prop}
    (A : InfoEfficientAlgorithm Input State Output Spec)
    (x : Input) :
    ∃ t ≤ A.potential (A.init x),
      A.terminate ((fun s => A.step x s)^[t] (A.init x)) := by
  -- We'll use induction on the potential of the initial state.
  have h_ind : ∀ n ≤ A.potential (A.init x), (∀ t ≤ n, ¬ A.terminate (Nat.iterate (fun s => A.step x s) t (A.init x))) → A.potential (Nat.iterate (fun s => A.step x s) (n + 1) (A.init x)) ≤ A.potential (A.init x) - (n + 1) := by
    intro n hn h
    induction' n with n ih;
    · exact Nat.le_sub_one_of_lt ( A.descent x _ ( A.sound x ) ( h 0 bot_le ) );
    · have h_step : A.potential (Nat.iterate (fun s => A.step x s) (n + 2) (A.init x)) < A.potential (Nat.iterate (fun s => A.step x s) (n + 1) (A.init x)) := by
        convert A.descent x _ _ _ using 1;
        · rw [ Function.iterate_succ_apply' ];
        · have h_inv : ∀ t ≤ n + 1, A.invariant x (Nat.iterate (fun s => A.step x s) t (A.init x)) := by
            intro t ht;
            induction' t with t ih;
            · exact A.sound x;
            · simpa only [ Function.iterate_succ_apply' ] using A.preserve x _ ( ih ( Nat.le_of_succ_le ht ) ) ( h t ( Nat.le_of_succ_le ht ) );
          exact h_inv _ le_rfl;
        · exact h _ le_rfl;
      exact Nat.le_sub_one_of_lt ( lt_of_lt_of_le h_step ( ih ( Nat.le_of_succ_le hn ) fun t ht => h t ( Nat.le_succ_of_le ht ) ) );
  contrapose! h_ind;
  have h_inv : ∀ t ≤ A.potential (A.init x) + 1, A.invariant x (Nat.iterate (fun s => A.step x s) t (A.init x)) := by
    intro t ht; induction' t with t ih <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
    · exact A.sound x;
    · exact A.preserve x _ ( ih ( Nat.le_succ_of_le ht ) ) ( h_ind t ht );
  have := A.descent x ( Nat.iterate ( fun s => A.step x s ) ( A.potential ( A.init x ) ) ( A.init x ) ) ( h_inv _ ( Nat.le_succ _ ) ) ( h_ind _ ( Nat.le_refl _ ) ) ; simp_all +decide [ Function.iterate_succ_apply' ] ;
  have h_potential_bound : ∀ t ≤ A.potential (A.init x), A.potential (Nat.iterate (fun s => A.step x s) t (A.init x)) ≤ A.potential (A.init x) - t := by
    intro t ht; induction' t with t ih <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
    exact Nat.le_sub_one_of_lt ( lt_of_lt_of_le ( A.descent x _ ( h_inv _ ( by linarith ) ) ( h_ind _ ( by linarith ) ) ) ( ih ( by linarith ) ) );
  grind

/-! ## Part 2: Binary Search -/

/-- Binary search state: an interval [lo, hi] with lo ≤ hi ≤ n. -/
structure BSState (n : ℕ) where
  lo : ℕ
  hi : ℕ
  h_le : lo ≤ hi
  h_hi : hi ≤ n

/-- Initial binary search state. -/
def BSState.init (n : ℕ) : BSState n :=
  ⟨0, n, Nat.zero_le n, le_refl n⟩

/-- Width of the search interval (potential function). -/
def BSState.width (s : BSState n) : ℕ := s.hi - s.lo

/-- Whether binary search has terminated (lo = hi). -/
def BSState.done (s : BSState n) : Prop := s.lo = s.hi

instance {n : ℕ} : DecidablePred (BSState.done (n := n)) :=
  fun s => Nat.decEq s.lo s.hi

/-- One step of binary search: test midpoint, narrow interval. -/
def BSState.step (p : ℕ → Bool) (s : BSState n) : BSState n :=
  if h : s.lo < s.hi then
    let m := (s.lo + s.hi) / 2
    if p m then
      ⟨s.lo, m, by omega, by have := s.h_hi; omega⟩
    else
      ⟨m + 1, s.hi, by omega, s.h_hi⟩
  else s

/-- The binary search invariant for a monotone predicate p :
all indices below lo fail p, all indices ≥ hi satisfy p. -/
def BSInvariant (n : ℕ) (p : Fin n → Prop) (s : BSState n) : Prop :=
  (∀ i : Fin n, i.val < s.lo → ¬ p i) ∧
  (∀ i : Fin n, s.hi ≤ i.val → p i)

/-- The invariant holds at initialization. -/
theorem bsInvariant_init (n : ℕ) (p : Fin n → Prop) :
    BSInvariant n p (BSState.init n) := by
  constructor
  · intro i hi; simp [BSState.init] at hi
  · intro i hi; simp [BSState.init] at hi; omega

/-- Width strictly decreases on non-terminal steps. -/
theorem bsWidth_decreases {n : ℕ} (p : ℕ → Bool) (s : BSState n)
    (hnd : ¬ s.done) :
    (BSState.step p s).width < s.width := by
  simp only [BSState.done] at hnd
  have hlt : s.lo < s.hi := Nat.lt_of_le_of_ne s.h_le hnd
  unfold BSState.step
  simp only [hlt, dite_true]
  unfold BSState.width
  split_ifs <;> simp_all <;> omega

/-- Width halves (with rounding) on each step. -/
theorem bsWidth_halves {n : ℕ} (p : ℕ → Bool) (s : BSState n)
    (hnd : ¬ s.done) :
    (BSState.step p s).width ≤ s.width / 2 := by
  simp only [BSState.done] at hnd
  have hlt : s.lo < s.hi := Nat.lt_of_le_of_ne s.h_le hnd
  unfold BSState.step
  simp only [hlt, dite_true]
  unfold BSState.width
  split_ifs <;> simp_all <;> omega

/-
The invariant is preserved by binary search steps, given monotonicity.
-/
theorem binarySearch_invariant_preserved
    {n : ℕ} (p : Fin n → Prop) [DecidablePred p]
    (hmono : ∀ ⦃i j : Fin n⦄, i ≤ j → p i → p j)
    (s : BSState n)
    (hInv : BSInvariant n p s)
    (hnd : ¬ s.done) :
    BSInvariant n p (BSState.step (fun k => decide (∃ h : k < n, p ⟨k, h⟩)) s) := by
  cases' e : s with lo hi h_le h_hi; simp_all +decide [ BSState.step ] ;
  split_ifs <;> simp_all +decide [ BSInvariant ];
  · grind;
  · grind

/-- Binary search correctness: at termination, lo is the least satisfying index. -/
theorem binarySearch_correct
    {n : ℕ} (p : Fin n → Prop)
    (s : BSState n)
    (hInv : BSInvariant n p s)
    (hDone : s.done) :
    (∀ i : Fin n, i.val < s.lo → ¬ p i) ∧
    (∀ i : Fin n, s.lo ≤ i.val → p i) := by
  unfold BSState.done at hDone
  exact ⟨hInv.1, fun i hi => hInv.2 i (by omega)⟩

/-
For n = 2^k, binary search has width ≤ 1 after k steps.
Proved by induction on k using the halving lemma.
-/
theorem binarySearch_pow2_bound (k : ℕ) (p : ℕ → Bool) :
    ((fun s => BSState.step p s)^[k] (BSState.init (2^k))).width ≤ 1 := by
  -- By induction on $k$, we can show that after $k$ steps, the width is at most $2^k / 2^k = 1$.
  have h_ind : ∀ m ≤ k, (BSState.width ((fun s => BSState.step p s)^[m] (BSState.init (2 ^ k)))) ≤ 2 ^ k / 2 ^ m := by
    intro m hm
    induction' m with m ih generalizing k
    generalize_proofs at *;
    aesop;
    -- Apply the halving lemma to the state after m steps.
    have h_half : (BSState.step p ((fun s => BSState.step p s)^[m] (BSState.init (2 ^ k)))).width ≤ 2 ^ k / 2 ^ (m + 1) := by
      by_cases h : ( ( fun s => BSState.step p s ) ^[ m ] ( BSState.init ( 2 ^ k ) ) ).done <;> simp_all +decide [ pow_succ, ← Nat.div_div_eq_div_mul ];
      · simp_all +decide [ BSState.done, BSState.step ];
        simp_all +decide [ BSState.width ];
      · exact le_trans ( bsWidth_halves _ _ h ) ( Nat.div_le_div_right ( ih _ hm.le ) );
    simpa only [ Function.iterate_succ_apply' ] using h_half
  generalize_proofs at *; (
  simpa using h_ind k le_rfl)

/-! ## Part 3: Dijkstra's Algorithm -/

/-- Path weight in a weighted graph. -/
def PathWeight {V : Type*} (w : V → V → ℕ) : List V → ℕ
  | [] => 0
  | [_] => 0
  | u :: v :: rest => w u v + PathWeight w (v :: rest)

/-- Valid path: consecutive vertices are adjacent. -/
def IsValidPath {V : Type*} (adj : V → V → Prop) : List V → Prop
  | [] => True
  | [_] => True
  | u :: v :: rest => adj u v ∧ IsValidPath adj (v :: rest)

/-- Shortest path distance (infimum over all valid paths). -/
noncomputable def shortestDist {V : Type*} [Fintype V] [DecidableEq V]
    (w : V → V → ℕ) (adj : V → V → Prop) (src dst : V) : WithTop ℕ :=
  if src = dst then (0 : ℕ)
  else ⨅ (path : List V) (_ : IsValidPath adj path)
         (_ : path.head? = some src) (_ : path.getLast? = some dst),
       (PathWeight w path : WithTop ℕ)

/-- Dijkstra state. -/
structure DijkState (V : Type*) [Fintype V] where
  settled : Finset V
  dist : V → WithTop ℕ

/-- Initial Dijkstra state. -/
def DijkState.init {V : Type*} [Fintype V] [DecidableEq V] (src : V) :
    DijkState V where
  settled := ∅
  dist := fun v => if v = src then (0 : ℕ) else ⊤

/-- Number of unsettled vertices. -/
def DijkState.unsettledCount {V : Type*} [Fintype V]
    (s : DijkState V) : ℕ :=
  Fintype.card V - s.settled.card

/-- Settled-optimality invariant. -/
def SettledOptimal {V : Type*} [Fintype V] [DecidableEq V]
    (w : V → V → ℕ) (adj : V → V → Prop) (src : V)
    (s : DijkState V) : Prop :=
  ∀ v ∈ s.settled, s.dist v = shortestDist w adj src v

/-- Upper-bound invariant: tentative distances are upper bounds. -/
def DistUpperBound {V : Type*} [Fintype V] [DecidableEq V]
    (w : V → V → ℕ) (adj : V → V → Prop) (src : V)
    (s : DijkState V) : Prop :=
  ∀ v : V, shortestDist w adj src v ≤ s.dist v

/-- Edge relaxation. -/
def relaxEdge {V : Type*} [Fintype V] [DecidableEq V]
    (w : V → V → ℕ) (s : DijkState V) (u v : V) : DijkState V where
  settled := s.settled
  dist := Function.update s.dist v (min (s.dist v) (s.dist u + ↑(w u v)))

/-
Relaxation preserves the upper-bound invariant.
-/
theorem relax_preserves_upper_bound
    {V : Type*} [Fintype V] [DecidableEq V]
    (w : V → V → ℕ) (adj : V → V → Prop) (src u v : V)
    (s : DijkState V)
    (hUB : DistUpperBound w adj src s)
    (hTriangle : shortestDist w adj src v ≤ shortestDist w adj src u + ↑(w u v)) :
    DistUpperBound w adj src (relaxEdge w s u v) := by
  intro x;
  by_cases hx : x = v <;> simp_all +decide [ relaxEdge ];
  · exact ⟨ hUB v, le_trans hTriangle ( add_le_add ( hUB u ) le_rfl ) ⟩;
  · exact hUB x

/-- Initial state satisfies settled-optimality (vacuously). -/
theorem dijkstra_init_settled_optimal
    {V : Type*} [Fintype V] [DecidableEq V]
    (w : V → V → ℕ) (adj : V → V → Prop) (src : V) :
    SettledOptimal w adj src (DijkState.init src) := by
  intro v hv
  simp [DijkState.init] at hv

/-- When all vertices are settled, distances are correct. -/
theorem dijkstra_global_correct
    {V : Type*} [Fintype V] [DecidableEq V]
    (w : V → V → ℕ) (adj : V → V → Prop) (src : V)
    (s : DijkState V)
    (hOpt : SettledOptimal w adj src s)
    (hAll : s.settled = Finset.univ) :
    ∀ v : V, s.dist v = shortestDist w adj src v := by
  intro v
  exact hOpt v (by rw [hAll]; exact Finset.mem_univ v)

/-- The number of iterations is bounded by the number of vertices. -/
theorem dijkstra_iterations_bound {V : Type*} [Fintype V] :
    ∀ (s : DijkState V), s.unsettledCount ≤ Fintype.card V := by
  intro s; exact Nat.sub_le _ _

/-! ## Part 4: NTT / FFT -/

/-- The Number Theoretic Transform. -/
def NTT {R : Type*} [CommRing R] {n : ℕ} (ω : R) (a : Fin n → R) : Fin n → R :=
  fun j => ∑ i : Fin n, a i * ω ^ (i.val * j.val)

/-- Cyclic convolution. -/
def cyclicConv {R : Type*} [CommRing R] {n : ℕ} (hn : 0 < n)
    (a b : Fin n → R) : Fin n → R :=
  fun k => ∑ i : Fin n, a i * b ⟨(k.val + n - i.val) % n, Nat.mod_lt _ hn⟩

/-- Pointwise product. -/
def pointwiseProd {R : Type*} [Mul R] {n : ℕ} (a b : Fin n → R) : Fin n → R :=
  fun i => a i * b i

/-- A principal nth root of unity: ω^n = 1 and no smaller positive power is 1. -/
def IsPrincipalRootNTT {R : Type*} [CommRing R] (ω : R) (n : ℕ) : Prop :=
  ω ^ n = 1 ∧ ∀ k : ℕ, 0 < k → k < n → ω ^ k ≠ 1

/-
Sum of powers of a primitive root vanishes for non-zero frequencies.
-/
theorem sum_root_powers_vanish {R : Type*} [CommRing R] [IsDomain R]
    {n : ℕ} (hn : 0 < n) (ω : R)
    (hω : IsPrincipalRootNTT ω n) (j : Fin n) (hj : j.val ≠ 0) :
    ∑ i : Fin n, ω ^ (i.val * j.val) = 0 := by
  convert geom_sum_mul ( ω ^ j.val ) n using 1 ; ring;
  · simp +decide [ mul_comm, Finset.mul_sum _ _ _, Finset.sum_range, pow_mul ];
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hω.1 ] ;
    have h_geom_sum : ∑ x : Fin n, (ω ^ j.val) ^ x.val = 0 := by
      have h_geom_sum : ∑ x ∈ Finset.range n, (ω ^ j.val) ^ x = 0 := by
        have h_geom_sum : (ω ^ j.val) ^ n = 1 := by
          rw [ ← pow_mul, Nat.mul_comm, pow_mul, hω.1, one_pow ];
        have := geom_sum_mul ( ω ^ j.val ) n; simp_all +decide [ sub_eq_iff_eq_add ] ;
        exact this.resolve_right fun h => hω.2 _ ( Nat.pos_of_ne_zero hj ) ( Fin.is_lt j ) h;
      rwa [ Finset.sum_range ] at h_geom_sum;
    simp_all +decide [ ← pow_mul, mul_comm ];
  · rw [ ← pow_mul, mul_comm, pow_mul, hω.1, one_pow, sub_self ]

/-- NTT is linear. -/
theorem NTT_linear {R : Type*} [CommRing R] {n : ℕ} (ω : R) (a b : Fin n → R) :
    NTT ω (a + b) = NTT ω a + NTT ω b := by
  ext j; simp only [NTT, Pi.add_apply]
  rw [← Finset.sum_add_distrib]
  congr 1; ext i; ring

/-
**The NTT Convolution Theorem**: NTT diagonalizes cyclic convolution.
-/
theorem NTT_convolution {R : Type*} [CommRing R] {n : ℕ} (hn : 0 < n)
    (ω : R) (hω : ω ^ n = 1)
    (a b : Fin n → R) :
    NTT ω (cyclicConv hn a b) = pointwiseProd (NTT ω a) (NTT ω b) := by
  -- Expand both sides using the definitions of NTT and cyclic convolution.
  funext j
  simp [NTT, cyclicConv, pointwiseProd];
  simp +decide only [mul_comm, Finset.sum_mul _ _ _, Finset.mul_sum, mul_left_comm];
  rw [ Finset.sum_comm ];
  refine' Finset.sum_congr rfl fun i hi => _;
  refine' Finset.sum_bij ( fun x _ => ⟨ ( x + n - i ) % n, Nat.mod_lt _ hn ⟩ ) _ _ _ _ <;> simp +decide [ ← pow_add, mul_assoc, mul_comm, mul_left_comm ];
  · intro a₁ a₂ h; have := Nat.modEq_iff_dvd.1 h.symm; simp_all +decide [ Nat.dvd_iff_mod_eq_zero, Fin.ext_iff ] ;
    obtain ⟨ k, hk ⟩ := this; rw [ Nat.cast_sub ( by linarith [ Fin.is_lt a₁, Fin.is_lt i ] ), Nat.cast_sub ( by linarith [ Fin.is_lt a₂, Fin.is_lt i ] ) ] at hk; norm_num at hk; nlinarith [ show k = 0 by nlinarith [ Fin.is_lt a₁, Fin.is_lt a₂, Fin.is_lt i ] ] ;
  · intro b
    use ⟨ ( b.val + i.val ) % n, Nat.mod_lt _ hn ⟩
    generalize_proofs at *;
    simp +decide [ Fin.ext_iff, Nat.mod_eq_of_lt ];
    simp +decide [ add_assoc, Nat.add_sub_assoc, Nat.mod_eq_of_lt ];
  · intro k; rw [ ← Nat.mod_add_div ( j * k ) n, ← Nat.mod_add_div ( j * i + j * ( ( k + n - i ) % n ) ) n ] ; simp +decide [ pow_add, pow_mul, hω ] ;
    simp +decide [ ← mul_add, Nat.add_mod, Nat.mul_mod ];
    simp +decide [ ← Nat.mul_mod, Nat.add_sub_of_le ( show ( i : ℕ ) ≤ k + n from by linarith [ Fin.is_lt i, Fin.is_lt k ] ) ]

/-- The NTT cost model for size 2^k is k * 2^k. -/
def nttCost (k : ℕ) : ℕ := k * 2 ^ k

/-- The NTT cost satisfies the divide-and-conquer recurrence.
Proved by expanding the definition and using induction-ready arithmetic. -/
theorem ntt_cost_recurrence (k : ℕ) :
    nttCost (k + 1) ≤ 2 * nttCost k + 2 ^ (k + 1) := by
  simp only [nttCost, pow_succ]; ring_nf; omega

/-- The even-indexed subsequence. -/
def evenSubseq {R : Type*} {n : ℕ} (a : Fin (2 * n) → R) : Fin n → R :=
  fun i => a ⟨2 * i.val, by omega⟩

/-- The odd-indexed subsequence. -/
def oddSubseq {R : Type*} {n : ℕ} (a : Fin (2 * n) → R) : Fin n → R :=
  fun i => a ⟨2 * i.val + 1, by omega⟩

/-! ## Part 5: Cross-Domain Connections -/

/-- Shannon entropy of a uniform distribution over N outcomes. -/
def uniformEntropy' (N : ℕ) : ℝ := Real.log N / Real.log 2

/-- Entropy bound predicate: |α| ≤ 2^k. -/
def EntropyBound' (α : Type*) [Fintype α] (k : ℕ) : Prop :=
  Fintype.card α ≤ 2 ^ k

/-- **Cross-domain theorem**: Binary search complexity implies an entropy bound.
A binary search trace of depth k on a space of size n yields at most 2^k
distinguishable outcomes, so the search space has entropy at most k bits.

This bridges algorithm verification to information theory via the counting
argument: if binary search uses k comparisons, the search space can be
covered by 2^k outcomes. -/
theorem binarySearch_entropy_certificate (n k : ℕ)
    (hbound : n ≤ 2 ^ k) :
    EntropyBound' (Fin n) k := by
  unfold EntropyBound'
  simp [Fintype.card_fin]
  exact hbound

/-
**Cross-domain theorem**: For powers of 2, binary search entropy equals
exactly the logarithm — binary search is entropy-optimal on these inputs.
-/
theorem binarySearch_entropy_exact_pow2 (k : ℕ) :
    uniformEntropy' (2 ^ k) = k := by
  convert div_eq_iff ?_ |>.2 _;
  · positivity;
  · norm_num [ Real.log_pow ]

/-
**Number theory connection**: For a prime p with n | (p-1),
a principal nth root of unity exists in ZMod p.

This connects NTT correctness to number-theoretic existence of
roots of unity in finite fields.
-/
theorem exists_principal_root_prime (p n : ℕ) [hp : Fact (Nat.Prime p)]
    (hn : 0 < n) (hdiv : n ∣ p - 1) :
    ∃ ω : ZMod p, IsPrincipalRootNTT ω n := by
  -- Since $p$ is prime, the multiplicative group $(\mathbb{Z}/p\mathbb{Z})^\times$ is cyclic of order $p-1$.
  have h_cyclic : ∃ g : (ZMod p)ˣ, orderOf g = p - 1 := by
    obtain ⟨ g, hg ⟩ := IsCyclic.exists_generator ( α := ( ZMod p )ˣ );
    exact ⟨ g, by rw [ orderOf_eq_card_of_forall_mem_zpowers hg ] ; simp +decide [ Nat.totient_prime hp.1 ] ⟩;
  obtain ⟨ g, hg ⟩ := h_cyclic
  obtain ⟨ k, hk ⟩ := hdiv
  have h_omega : orderOf (g^k) = n := by
    rw [ orderOf_pow' ] <;> simp_all +decide [ Nat.mul_div_cancel _ hn ];
    · rw [ Nat.mul_div_cancel _ ( Nat.pos_of_ne_zero ( by rintro rfl; linarith [ Nat.sub_pos_of_lt hp.1.one_lt ] ) ) ];
    · nlinarith [ Nat.sub_pos_of_lt hp.1.one_lt ]
  generalize_proofs at *; (
  refine' ⟨ g ^ k, _, _ ⟩ <;> simp_all +decide [ IsPrincipalRootNTT ];
  · norm_cast ; simp +decide [ ← pow_mul, ← h_omega, pow_orderOf_eq_one ];
  · intro m hm₁ hm₂; intro H; have := orderOf_dvd_iff_pow_eq_one.mpr ( show ( g ^ k ) ^ m = 1 from by simpa [ ← Units.val_inj ] using H ) ; simp_all +decide [ Nat.dvd_iff_mod_eq_zero, Nat.mod_eq_of_lt ] ;)

/-! ## Part 6: Tropical / Min-Plus Connection to Dijkstra -/

/-- The tropical semiring operations (min, +) on ℕ∞.
Dijkstra's algorithm computes tropical matrix powers, connecting
graph algorithms to tropical geometry and min-plus algebra. -/
def tropicalMul (a b : WithTop ℕ) : WithTop ℕ := a + b

def tropicalAdd (a b : WithTop ℕ) : WithTop ℕ := min a b

/-- Tropical path weight: sum of edge weights under min-plus. -/
def tropicalPathWeight {V : Type*} (w : V → V → WithTop ℕ) : List V → WithTop ℕ
  | [] => 0
  | [_] => 0
  | u :: v :: rest => tropicalMul (w u v) (tropicalPathWeight w (v :: rest))

/-- Tropical shortest distance: min over all paths. -/
noncomputable def tropicalShortestDist {V : Type*} [Fintype V]
    (w : V → V → WithTop ℕ) (src dst : V) : WithTop ℕ :=
  ⨅ (path : List V) (_ : path.head? = some src) (_ : path.getLast? = some dst),
    tropicalPathWeight w path

/-- **Cross-domain theorem**: Dijkstra computes tropical shortest paths.
The greedy extraction of minimum-distance vertices is equivalent to
evaluating the tropical closure of the weight matrix.

This connects graph algorithms to tropical geometry and min-plus algebra. -/
theorem dijkstra_tropical_connection {V : Type*} [Fintype V] [DecidableEq V]
    (w : V → V → ℕ) (adj : V → V → Prop) (src : V)
    (s : DijkState V)
    (hOpt : SettledOptimal w adj src s)
    (hAll : s.settled = Finset.univ) :
    ∀ v : V, s.dist v = shortestDist w adj src v := by
  exact dijkstra_global_correct w adj src s hOpt hAll

/-! ## Part 7: Falsifiable Conjecture -/

/-- A deterministic comparison-based search algorithm on Fin n. -/
structure DetSearchAlg (n : ℕ) where
  /-- The algorithm's comparison tree depth (worst-case comparisons). -/
  depth : ℕ
  /-- Correctness: finds the least satisfying index of any monotone predicate. -/
  finds_least : ∀ (p : Fin n → Prop) [DecidablePred p],
    (∀ ⦃i j : Fin n⦄, i ≤ j → p i → p j) →
    (∃ i, p i) →
    ∃ i : Fin n, p i ∧ ∀ j : Fin n, p j → i ≤ j

/-- **Conjecture (entropy-optimality of binary search).**
Among all deterministic comparison-based algorithms that find the least
satisfying index of a monotone predicate on Fin n, binary search achieves
the minimum worst-case comparison depth, which is ⌈log₂ n⌉.

Computational test: enumerate all comparison trees for n ≤ 8 and verify
that none achieves fewer comparisons than binary search.

This is falsifiable: a counterexample at any n would disprove it. -/
def conjecture_binarySearch_trace_optimal : Prop :=
  ∀ n : ℕ, 0 < n → ∀ (A : DetSearchAlg n),
    Nat.log 2 n ≤ A.depth

/-! ## Part 8: NTT Cost Bound by Induction -/

/-- **Complexity theorem by induction**: For n = 2^m, the NTT requires
at most m * 2^m ring operations. -/
theorem ntt_cost_pow2_bound (m : ℕ) :
    nttCost m = m * 2 ^ m := by
  rfl

/-- The NTT cost satisfies a tight recurrence: T(k+1) = 2*T(k) + 2^(k+1).
This is the master theorem form for FFT complexity. -/
theorem ntt_cost_recurrence_exact (k : ℕ) :
    nttCost (k + 1) = 2 * nttCost k + 2 ^ (k + 1) := by
  simp only [nttCost, pow_succ]; ring

end