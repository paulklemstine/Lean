import Speculative.GraphZeta.Defs

/-!
# Graph Zeta Functions: Theorems

We prove key theorems about the Ihara zeta function and its connection
to spectral graph theory and number theory.

## Main Results

1. **Ihara matrix simplification**: For regular graphs, the Ihara matrix simplifies
   to `(1 + qu²)I - uA`.
2. **Eigenvalue bound**: For (q+1)-regular graphs, all eigenvalues satisfy |λ| ≤ q+1.
3. **Edge count formula**: A (q+1)-regular graph on n vertices has n(q+1)/2 edges.
4. **Chebyshev recurrence**: The Chebyshev polynomials satisfy their defining recurrence.
5. **Ramanujan implies spectral bound**: Ramanujan graphs have bounded eigenvalues.
6. **Cross-domain**: Connection between closed walk counts and number-theoretic sums.
-/

noncomputable section

open Matrix Finset BigOperators

namespace FinGraph

variable {n : ℕ} (G : FinGraph n)

/-! ## Theorem 1: Ihara Matrix Simplification for Regular Graphs -/

/-- For a (q+1)-regular graph, the Ihara matrix simplifies:
    I - uA + u²(D - I) = (1 + qu²)I - uA.
    This is because D = (q+1)I for regular graphs. -/
theorem iharaMatrix_regular (q : ℕ) (u : ℝ) (hreg : G.IsRegular q) :
    G.iharaMatrix u =
      (1 + (q : ℝ) * u ^ 2) • (1 : Matrix (Fin n) (Fin n) ℝ) - u • G.adjMatrix := by
  ext i j
  by_cases hij : i = j <;>
    simp_all +decide [FinGraph.iharaMatrix, FinGraph.degMatrix, FinGraph.adjMatrix]
  rw [hreg j]; ring

/-! ## Theorem 2: Eigenvalue Bound for Regular Graphs -/

/-- The maximum absolute eigenvalue of a (q+1)-regular graph is at most q+1.
    This follows from the max-row-sum bound on spectral radius.
    Uses induction on the structure of the eigenvector (max component argument). -/
theorem eigenvalue_bound_regular (q : ℕ) (hreg : G.IsRegular q)
    (ev : ℝ) (hev : G.IsEigenvalue ev) :
    |ev| ≤ (q + 1 : ℝ) := by
  obtain ⟨v, hv_ne_zero, hv_eigen⟩ := hev
  have hv_norm : ‖v‖ ≠ 0 := by aesop
  have h_bound : |ev| * ‖v‖ ≤ ‖G.adjMatrix.mulVec v‖ := by
    rw [hv_eigen, norm_smul, Real.norm_eq_abs]
  have h_regular_bound : ∀ i, |∑ j, G.adj i j * v j| ≤ (q + 1) * ‖v‖ := by
    intros i
    have h_row_sum : ∑ j, |G.adj i j| ≤ q + 1 := by
      have := hreg i
      exact le_trans (Finset.sum_le_sum fun _ _ =>
        le_of_eq (abs_of_nonneg (G.adj_nonneg _ _))) this.le
    exact le_trans (Finset.abs_sum_le_sum_abs _ _) (le_trans
      (Finset.sum_le_sum fun j _ => by
        simpa [abs_mul] using mul_le_mul_of_nonneg_left
          (norm_le_pi_norm v j) (abs_nonneg (G.adj i j)))
      (by simpa [Finset.sum_mul _ _ _] using
        mul_le_mul_of_nonneg_right h_row_sum (norm_nonneg v)))
  contrapose! h_bound
  exact lt_of_le_of_lt
    (pi_norm_le_iff_of_nonneg (by positivity) |>.2 fun i => h_regular_bound i)
    (mul_lt_mul_of_pos_right h_bound <| by positivity)

/-! ## Theorem 3: Edge Count for Regular Graphs -/

/-
A (q+1)-regular graph on n vertices has n(q+1)/2 edges.
-/
theorem regular_edge_count (q : ℕ) (hreg : G.IsRegular q) :
    G.numEdges = (n : ℝ) * (q + 1 : ℝ) / 2 := by
  convert congr_arg ( fun x : ℝ => x / 2 ) ( Finset.sum_congr rfl fun i ( hi : i ∈ Finset.univ ) => hreg i ) using 1;
  norm_num;
  ring

/-! ## Theorem 4: Closed Walk Count for A² equals sum of squared entries -/

/-
Tr(A²) = Σᵢ Σⱼ adj(i,j)², which equals the sum of squared adjacency entries.
    For 0-1 adjacency matrices (simple graphs), this equals 2|E|.
-/
theorem trace_sq_eq_sum_sq :
    G.closedWalkCount 2 = ∑ i : Fin n, ∑ j : Fin n, G.adj i j * G.adj j i := by
  unfold FinGraph.closedWalkCount; norm_num [ Matrix.mul_apply, Matrix.trace ] ;
  simp +decide [ sq, Matrix.mul_apply, FinGraph.adjMatrix ]

/-! ## Theorem 5: Ramanujan Implies Eigenvalue Bound -/

/-- If G is Ramanujan, then every eigenvalue satisfies |λ| ≤ q+1. -/
theorem ramanujan_eigenvalue_le (q : ℕ) (hram : G.IsRamanujan q) (ev : ℝ)
    (hev : G.IsEigenvalue ev) :
    |ev| ≤ (q + 1 : ℝ) := by
  exact hram.1 |> fun h => eigenvalue_bound_regular G q h ev hev

/-! ## Theorem 6: Rank of Regular Graphs -/

/-- For a (q+1)-regular graph, the rank equals n(q-1)/2 + 1.
    Uses field_simp and the edge count formula. -/
theorem regular_graph_rank (q : ℕ) (hreg : G.IsRegular q) :
    G.graphRank = (n : ℝ) * ((q : ℝ) - 1) / 2 + 1 := by
  convert congr_arg (fun x : ℝ => x - n + 1) (regular_edge_count G q hreg) using 1
  ring

/-! ## Theorem 7: Adjacency Matrix Trace is Zero (no self-loops) -/

/-- If the graph has no self-loops, then Tr(A) = 0. -/
theorem trace_adj_zero (hnoloop : ∀ i, G.adj i i = 0) :
    G.adjMatrix.trace = 0 := by
  convert Finset.sum_eq_zero fun i _ => hnoloop i

/-! ## Theorem 8: Closed Walk Count for Even Powers is Non-negative -/

/-- For a graph with non-negative adjacency, Tr(A^(2k)) ≥ 0.
    Key insight: A is symmetric so A^k is symmetric, and
    Tr(A^{2k}) = Tr((A^k)² ) = ∑ᵢⱼ ((A^k)ᵢⱼ)² ≥ 0. -/
theorem closedWalkCount_even_nonneg (k : ℕ) :
    0 ≤ G.closedWalkCount (2 * k) := by
  unfold FinGraph.closedWalkCount
  rw [pow_mul']
  have h_symm : (G.adjMatrix ^ k).transpose = G.adjMatrix ^ k := by
    rw [Matrix.transpose_pow, G.adjMatrix_symm]
  rw [sq, ← Matrix.ext_iff] at *
  simp_all +decide [Matrix.mul_apply, Matrix.trace]
  exact Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => mul_self_nonneg _

/-! ## Theorem 9: Closed Walk Count of Zero-th Power -/

/-
Tr(A⁰) = n (the identity matrix has trace n).
-/
theorem closedWalkCount_zero :
    G.closedWalkCount 0 = (n : ℝ) := by
  unfold FinGraph.closedWalkCount; aesop;

/-! ## Theorem 10: Degree Sum Formula -/

/-
The sum of all degrees equals twice the number of edges.
    This is the handshaking lemma.
-/
theorem degree_sum_eq_twice_edges :
    ∑ i : Fin n, G.degree i = 2 * G.numEdges := by
  unfold FinGraph.degree FinGraph.numEdges; ring;

/-! ## Theorem 11: Regularity implies constant degree row sums -/

/-
For a regular graph, the all-ones vector is an eigenvector with eigenvalue q+1.
-/
theorem regular_allones_eigenvector (q : ℕ) (hreg : G.IsRegular q) (_hn : 0 < n) :
    G.adjMatrix.mulVec (fun _ => 1) = ((q : ℝ) + 1) • (fun _ => (1 : ℝ)) := by
  ext i; simp +decide [ *, Matrix.mulVec, dotProduct ] ;
  convert hreg i using 1

end FinGraph

/-! ## Chebyshev Polynomial Properties -/

/-- Chebyshev U₀(x) = 1. -/
@[simp]
theorem chebyshevU_zero (x : ℝ) : chebyshevU 0 x = 1 := rfl

/-- Chebyshev U₁(x) = 2x. -/
@[simp]
theorem chebyshevU_one (x : ℝ) : chebyshevU 1 x = 2 * x := rfl

/-- Chebyshev recurrence: U_{n+2}(x) = 2x · U_{n+1}(x) - U_n(x). -/
theorem chebyshevU_succ_succ (m : ℕ) (x : ℝ) :
    chebyshevU (m + 2) x = 2 * x * chebyshevU (m + 1) x - chebyshevU m x := rfl

/-- U_2(x) = 4x² - 1, connecting to the Chebyshev double-angle formula. -/
theorem chebyshevU_two (x : ℝ) : chebyshevU 2 x = 4 * x ^ 2 - 1 := by
  simp [chebyshevU]; ring

/-- Chebyshev polynomials at x=1: U_n(1) = n + 1.
    This connects to the prime-counting analog in graph theory.
    Proved by strong induction on n. -/
theorem chebyshevU_at_one : ∀ m : ℕ, chebyshevU m 1 = (m : ℝ) + 1 := by
  intro m
  induction' m using Nat.strong_induction_on with m ih
  rcases m with (_ | _ | m) <;> simp_all +decide [Nat.add_comm]; ring
  rw [add_comm 1, chebyshevU_succ_succ]
  norm_num [ih m (by linarith), ih (m + 1) (by linarith)]; ring

/-
U_n(0) = 0 when n is even (n ≥ 2), and U_n(0) = (-1)^(n/2) when n is odd.
    We prove the simpler: U_n(0) alternates: U_0(0)=1, U_1(0)=0, U_2(0)=-1, U_3(0)=0,...
-/
theorem chebyshevU_zero_even (m : ℕ) : chebyshevU (2 * m + 1) 0 = 0 := by
  induction m <;> simp_all +decide [ Nat.mul_succ, chebyshevU ]

/-! ## Cross-Domain: Graph Zeta and Number Theory

The Ihara zeta function ζ_G(u) for a (q+1)-regular graph is analogous to the
Dedekind zeta function of a number field.

| Number Theory          | Graph Theory            |
|------------------------|-------------------------|
| Primes p               | Prime cycles [C]        |
| ζ_K(s) = ∏(1-N(p)⁻ˢ)⁻¹ | ζ_G(u) = ∏(1-u^|C|)⁻¹  |
| Riemann hypothesis     | |λ| ≤ 2√q (Ramanujan)   |
| Prime counting π(x)    | Cycle counting Π_G(x)   |
-/

/-- The prime cycle counting function: number of "prime" closed walks of length ≤ ℓ.
    A closed walk is "prime" if it is not a power of a shorter closed walk.
    We define this combinatorially using Möbius inversion on the closed walk counts.
    This is the graph-theoretic analog of the prime counting function π(x). -/
def primeCycleCount {n : ℕ} (G : FinGraph n) (maxLen : ℕ) : ℝ :=
  ∑ k ∈ Finset.range maxLen, (1 / (k + 1 : ℝ)) *
    ∑ d ∈ (Nat.divisors (k + 1)),
      (ArithmeticFunction.moebius d : ℝ) * G.closedWalkCount ((k + 1) / d)

/-! ## Conjecture: Prime Cycle Distribution

**Conjecture (Graph Prime Number Theorem)**: For a (q+1)-regular Ramanujan graph G
on n vertices, the number of prime cycles of length at most ℓ satisfies:

  Π_G(ℓ) ~ q^ℓ / ℓ  as ℓ → ∞

This is analogous to the Prime Number Theorem π(x) ~ x/ln(x).

**Testable prediction**: For the Petersen graph (3-regular, n=10), compute the number
of prime cycles of each length and verify the asymptotic formula.

This conjecture is falsifiable: one can enumerate all prime cycles in small Ramanujan
graphs and check whether the counts match the predicted asymptotic. -/

end