import Mathlib
import Catalog.Logic.ProofComplexity.SimulationPreorder
import Catalog.Logic.ProofComplexity.SimulationDegrees
import Catalog.Logic.ProofComplexity.DegreeLattice

/-! # The order type of the p-degrees: infinite width, a least degree, and density

This file is the **fourth cycle** of the order-theoretic Cook–Reckhow development.  The
previous files established, for the simulation preorder `Simulates` on abstract proof
systems (`Catalog.Logic.ProofComplexity.SimulationPreorder`):

* that `Simulates` is a `Preorder` and `PEquiv` a `Setoid` (the p-degrees);
* a generic separation template `no_simulation_of_hard` and concrete witnesses
  `linSystem`, `fibSystem` (`SimulationDegrees`);
* binary **meets** (`isGLB_sumSystem`) and an infinite strictly increasing **chain**
  `powSystem` — so the poset of p-degrees has *infinite height* (`DegreeLattice`).

Height tells only half the story of an order type; this file adds **width** and
**density**, three structural pillars that, with the earlier height result, pin down much
of the order type of the p-degrees:

* **Infinite width (an infinite antichain).**  The 2-adic valuation partitions `ℕ` into
  infinitely many infinite "spike sets" `{n : v₂ n = i}`.  Putting an exponential spike
  `2^n` on the `i`-th set yields proof systems `spikeSys i` that are **pairwise
  incomparable** (`spikeSys_incomparable`): no polynomial blow-up can fix `f 0` and still
  cover an unbounded exponential spike.  Hence the p-degrees contain an *infinite
  antichain* (`spikeSys_isAntichain`, `spikeSys_pdegrees_injective`), so their width is
  infinite and the order is far from a chain (`exists_incomparable_pair`).

* **A least p-degree.**  The "free" system of size `0` (`zeroSys`) p-simulates **every**
  proof system over `ℕ` (`simulates_zeroSys`); it is therefore a bottom element
  `zeroSys_isBot`, lying strictly below the whole height ladder (`zeroSys_lt_lin`).  (This
  is honest in the size-only abstraction, where the Cook–Reckhow polynomial-time
  computability constraint on `proves` has been dropped — see the lab notebook.)

* **Density: an intermediate degree.**  Between the comparable pair `linSystem < fibSystem`
  there is a *strictly intermediate* p-degree (`exists_strictly_between_lin_fib`), realised
  by the "spiky" size function `interSys` that is Fibonacci-fast on the even numbers and
  linear on the odds: super-polynomial enough to escape `linSystem`, yet too thin on the
  odds to recover the full Fibonacci rate, so `fibSystem` cannot simulate it.

The engine throughout is the master reduction `simulates_sysOfSize_iff`: simulation between
size-indexed systems is *polynomial domination of size functions*.

-- !-- Lab Notebook -- !--
Hypothesis : The poset of p-degrees should have, beyond its known infinite height, (1) an
             infinite antichain (infinite width), (2) a least element, and (3) be order-dense
             at least at the witnessed pair `linSystem < fibSystem`.
Result     : All three confirmed, `sorry = 0`.  Width: `spikeSys_isAntichain` /
             `spikeSys_pdegrees_injective`.  Least element: `zeroSys_isBot`.  Density:
             `exists_strictly_between_lin_fib`.
Insight    : Incomparability is a *one-point* phenomenon under the domination characterisation
             `simulates_sysOfSize_iff`: a blow-up `f` is pinned at `f 0`, so a size function
             that is `0` on an infinite set but exponentially large on a *disjoint* infinite
             set cannot be polynomially dominated by another with the spikes swapped.  The
             2-adic valuation hands us a canonical family of disjoint infinite supports, and
             `(2^i * (2k+1)).factorization 2 = i` makes membership a one-line fact.  Density
             uses the same parity trick: thinning the Fibonacci spike to the even numbers
             keeps it super-polynomial (so `lin <`) but starves the odd indices, where the
             *full* Fibonacci rate still lives, so `< fib` is strict.
Failure analysis : Defining the spike supports by an explicit modular formula
             `n % 2^(i+1) = 2^i` made the *disjointness* proof awkward (relating two moduli);
             routing through `Nat.factorization … 2` instead reduces every membership and
             non-membership to the single multiplicative valuation identity above.
-- !-- Lab Notebook -- !--
-/

set_option maxHeartbeats 1000000

namespace ProofComplexity

universe u v

/-! ## Exponential beats polynomial (reusable growth fact) -/

/-
!-- comment: For each polynomial degree `k` and shift `a`, the exponential `2^m`
eventually overtakes the polynomial `(2m+a)^k`. -- !--

**Exponential dominates polynomial.**  For every `a k : ℕ` there is an `m` with
`(2 * m + a) ^ k < 2 ^ m`.  This is the one analytic ingredient behind the strict
separations below.
-/
lemma exp_dominates_poly (a k : ℕ) : ∃ m, (2 * m + a) ^ k < 2 ^ m := by
  by_contra h_contra;
  -- We'll use that exponential functions grow faster than polynomial functions.
  have h_exp_growth : Filter.Tendsto (fun m : ℕ => (2 * m + a : ℝ) ^ k / 2 ^ m) Filter.atTop (nhds 0) := by
    -- We can factor out $2^m$ from the numerator and denominator.
    suffices h_factor : Filter.Tendsto (fun m : ℕ => ((2 + a / (m : ℝ)) ^ k) * (m ^ k / 2 ^ m)) Filter.atTop (nhds 0) by
      refine h_factor.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with m hm using by rw [ show ( 2 * m + a : ℝ ) = m * ( 2 + a / m ) by rw [ mul_add, mul_div_cancel₀ _ ( by positivity ) ] ; ring ] ; rw [ mul_pow ] ; ring );
    -- We'll use the fact that $m^k / 2^m$ tends to $0$ as $m$ tends to infinity.
    have h_lim : Filter.Tendsto (fun m : ℕ => (m : ℝ) ^ k / 2 ^ m) Filter.atTop (nhds 0) := by
      -- We can convert this limit into a form that is easier to handle by substituting $n = m \log 2$.
      suffices h_log : Filter.Tendsto (fun n : ℝ => (n / Real.log 2) ^ k / Real.exp n) Filter.atTop (nhds 0) by
        convert h_log.comp ( tendsto_natCast_atTop_atTop.atTop_mul_const ( Real.log_pos one_lt_two ) ) using 2 ; norm_num [ Real.exp_nat_mul, Real.exp_log ];
      -- We can factor out $(1 / \log 2)^k$ from the limit.
      suffices h_factor : Filter.Tendsto (fun n : ℝ => n ^ k / Real.exp n) Filter.atTop (nhds 0) by
        convert h_factor.div_const ( Real.log 2 ^ k ) using 2 <;> ring;
      simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero k;
    simpa using Filter.Tendsto.mul ( Filter.Tendsto.pow ( tendsto_const_nhds.add ( tendsto_const_nhds.mul tendsto_inv_atTop_nhds_zero_nat ) ) k ) h_lim;
  exact h_contra <| by have := h_exp_growth.eventually ( gt_mem_nhds zero_lt_one ) ; obtain ⟨ m, hm ⟩ := this.exists; exact ⟨ m, by rw [ div_lt_one ( by positivity ) ] at hm; exact_mod_cast hm ⟩ ;

/-! ## A least p-degree (bottom element) -/

-- !-- comment: The "free" / size-0 proof system over `ℕ`: every theorem `n` is proved by
--             the proof `n` at zero cost.  (Abstraction drops the Cook–Reckhow
--             polynomial-time-`proves` constraint, so this is a legitimate bottom.) -- !--
/-- The size-`0` proof system over `ℕ`. -/
def zeroSys : ProofSystem.{0, 0} ℕ := sysOfSize (fun _ => 0)

/-
!-- comment: `zeroSys` p-simulates *any* proof system over `ℕ`: translate a proof of `t`
to the `zeroSys`-proof `t` itself, of size `0`. -- !--

**`zeroSys` simulates everything.**  The size-`0` system p-simulates every proof system
over `ℕ` (identity blow-up suffices since all its proofs have size `0`).
-/
theorem simulates_zeroSys (P : ProofSystem.{0, 0} ℕ) : Simulates zeroSys P := by
  refine' ⟨ fun n => n, polyMono_id, fun q => ⟨ P.proves q, _, _ ⟩ ⟩ <;> simp +decide [ zeroSys, sysOfSize ]

/-- **A least p-degree.**  `zeroSys` is a bottom element of the simulation preorder on
`ProofSystem ℕ`. -/
theorem zeroSys_isBot : IsBot zeroSys := simulates_zeroSys

/-- `zeroSys` is *strictly* below `linSystem`: `linSystem` cannot simulate it, since a
blow-up of the constant size `0` is a constant, but `linSystem` needs unbounded sizes. -/
theorem zeroSys_lt_lin : zeroSys < linSystem := by
  refine' lt_of_le_not_ge _ _;
  · convert simulates_zeroSys linSystem;
  · rintro ⟨ f, hf₁, hf₂ ⟩;
    cases' hf₂ ( f 0 + 1 ) with p hp ; cases' hp with hp₁ hp₂ ; simp_all +decide [ linSystem, zeroSys ];
    exact absurd ( hf₂ ( f 0 + 1 ) ) ( by simp +decide [ sysOfSize ] )

/-! ## Infinite width: an antichain of p-degrees -/

-- !-- comment: `spikeSys i` puts an exponential spike `2^n` on the set `{n : v₂ n = i}`,
--             i.e. on the integers with exactly `i` factors of two. -- !--
/-- The `i`-th spike system: size `2^n` on `{n : v₂ n = i}`, size `0` elsewhere. -/
noncomputable def spikeSys (i : ℕ) : ProofSystem.{0, 0} ℕ :=
  sysOfSize (fun n => if n.factorization 2 = i then 2 ^ n else 0)

-- !-- comment: The valuation of `2^i * (2k+1)` is exactly `i`: the engine that makes the
--             spike supports disjoint and infinite. -- !--
/-- `2^i * (2k+1)` has 2-adic valuation exactly `i`. -/
lemma factorization_two_spike (i k : ℕ) : (2 ^ i * (2 * k + 1)).factorization 2 = i := by
  rw [Nat.factorization_mul (by positivity) (by omega)]
  simp [Nat.prime_two,
    Nat.factorization_eq_zero_of_not_dvd (by omega : ¬ (2 ∣ 2 * k + 1))]

/-
!-- comment: Pairwise incomparability: a simulation `spikeSys i ⟶ spikeSys j` would pin
`f 0` above the unbounded spike of `spikeSys i` on its (disjoint) support. -- !--

**Spikes are incomparable.**  For `i ≠ j`, `spikeSys i` does not p-simulate
`spikeSys j`.
-/
theorem spikeSys_incomparable {i j : ℕ} (h : i ≠ j) :
    ¬ Simulates (spikeSys i) (spikeSys j) := by
  intro h';
  obtain ⟨ f, hf, h ⟩ := simulates_sysOfSize_iff _ _ |>.1 h';
  -- Choose $n$ such that $n.factorization 2 = i$ and $n > f 0$.
  obtain ⟨n, hn⟩ : ∃ n, n.factorization 2 = i ∧ n > f 0 := by
    use 2^i * (2 * (f 0 + 1) + 1);
    rw [ Nat.factorization_mul ] <;> norm_num;
    exact ⟨ Nat.factorization_eq_zero_of_not_dvd ( by norm_num [ Nat.dvd_add_right ] ), by nlinarith [ Nat.one_le_pow i 2 zero_lt_two ] ⟩;
  specialize h n;
  split_ifs at h <;> simp_all +decide;
  linarith [ Nat.pow_le_pow_right two_pos ( show n ≥ 1 by linarith ), show 2 ^ n > n by exact Nat.recOn n ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; linarith [ Nat.one_le_pow n 2 zero_lt_two ] ]

-- !-- comment: Packaging incomparability in both directions for every distinct pair. -- !--
/-- **Infinite antichain (raw form).**  `spikeSys` is a family of pairwise incomparable
proof systems. -/
theorem exists_infinite_antichain :
    ∃ A : ℕ → ProofSystem.{0, 0} ℕ, ∀ i j, i ≠ j →
      ¬ Simulates (A i) (A j) ∧ ¬ Simulates (A j) (A i) :=
  ⟨spikeSys, fun _ _ h => ⟨spikeSys_incomparable h, spikeSys_incomparable (Ne.symm h)⟩⟩

/-- The simulation preorder is **not** a total order: it has incomparable elements. -/
theorem exists_incomparable_pair :
    ∃ P Q : ProofSystem.{0, 0} ℕ, ¬ Simulates P Q ∧ ¬ Simulates Q P :=
  ⟨spikeSys 0, spikeSys 1, spikeSys_incomparable (by decide),
    spikeSys_incomparable (by decide)⟩

/-
!-- comment: Distinct indices give distinct p-degrees (incomparable ⟹ not p-equivalent). -- !--

The spike family descends to an **injection** into the poset of p-degrees.
-/
theorem spikeSys_pdegrees_injective :
    Function.Injective
      (fun i => toAntisymmetrization (α := ProofSystem.{0, 0} ℕ) (· ≤ ·) (spikeSys i)) := by
  intro i j hij;
  by_contra h_neq;
  convert spikeSys_incomparable h_neq _;
  convert ( Quotient.exact hij ) |>.1 using 1

/-
!-- comment: The image of the spike family is an antichain in the partial order of
p-degrees: an *infinite antichain*, so the width is infinite. -- !--

**Infinite width.**  The image of `spikeSys` is an antichain in the poset of p-degrees
`Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`; being also injective, it is an *infinite*
antichain.
-/
theorem spikeSys_isAntichain :
    IsAntichain (· ≤ ·)
      (Set.range fun i =>
        toAntisymmetrization (α := ProofSystem.{0, 0} ℕ) (· ≤ ·) (spikeSys i)) := by
  intro x hx y hy hxy
  obtain ⟨i, hi⟩ := hx
  obtain ⟨j, hj⟩ := hy
  have h_incomparable : ¬ Simulates (spikeSys i) (spikeSys j) := by
    convert spikeSys_incomparable _;
    grind;
  aesop

/-! ## Density: an intermediate p-degree between `linSystem` and `fibSystem` -/

-- !-- comment: Fibonacci-fast on the evens, linear on the odds: super-polynomial (so above
--             `lin`) yet too thin to recover the full Fibonacci rate (so below `fib`). -- !--
/-- An intermediate-growth proof system: size `F n` on even `n`, size `n` on odd `n`. -/
def interSys : ProofSystem.{0, 0} ℕ :=
  sysOfSize (fun n => if Even n then Nat.fib n else n)

/-
The intermediate size function is **not** polynomially bounded (it is Fibonacci-fast on
the even numbers).
-/
lemma interSys_size_not_polyBounded :
    ¬ PolyBounded (fun n => if Even n then Nat.fib n else n) := by
  -- Assume for contradiction that the function is polynomially bounded.
  by_contra h_poly_bounded
  obtain ⟨k, hk⟩ := h_poly_bounded;
  -- Evaluate at the even numbers `n = 2*m + 2`: `Even (2*m+2)` so `g (2*m+2) = Nat.fib (2*m+2)`.
  have h_even : ∀ m, Nat.fib (2 * m + 2) + 1 ≤ (2 * m + 4) ^ k := by
    grind;
  exact absurd ( ProofComplexity.exp_dominates_poly 4 k ) ( by rintro ⟨ m, hm ⟩ ; linarith [ h_even m, two_pow_le_fib m, Nat.fib_mono ( by linarith : 2 * m + 1 ≤ 2 * m + 2 ) ] )

/-
`linSystem` strictly precedes `interSys`: `linSystem` simulates it (linear blow-up),
but `interSys` is super-polynomial so cannot be simulated by `linSystem`.
-/
theorem lin_lt_inter : linSystem < interSys := by
  constructor;
  · unfold linSystem interSys;
    unfold sysOfSize;
    refine' ⟨ fun n => n + 5, _, _ ⟩ <;> norm_num;
    · constructor;
      · exact monotone_id.add_const _;
      · use 6;
        grind +revert;
    · intro n; split_ifs <;> norm_num;
      linarith [ Nat.le_fib_add_one n, Nat.le_fib_add_one ( n + 1 ) ];
  · intro h;
    obtain ⟨ f, hf_mono, hf_bound ⟩ := h;
    apply interSys_size_not_polyBounded;
    exact polyBounded_of_le ( fun n => by obtain ⟨ p, hp₁, hp₂ ⟩ := hf_bound n; aesop ) hf_mono.2

/-
`interSys` strictly precedes `fibSystem`: `interSys` is simulated by `fibSystem`, but
the full Fibonacci rate on the odd indices escapes any polynomial blow-up of `interSys`,
so `fibSystem` cannot simulate `interSys`.
-/
theorem inter_lt_fib : interSys < fibSystem := by
  constructor;
  · use fun n => n + 5;
    constructor;
    · constructor;
      · exact fun n m h => Nat.add_le_add_right h 5;
      · exact ⟨ 6, fun n => by nlinarith [ sq ( n ^ 2 ) ] ⟩;
    · intro q
      use q;
      unfold interSys fibSystem;
      unfold sysOfSize; norm_num; split_ifs <;> norm_num;
      rcases q with ( _ | _ | _ | _ | _ | q ) <;> simp +arith +decide [ Nat.fib_add_two ] at *;
      linarith [ Nat.le_fib_add_one q, Nat.le_fib_add_one ( q + 1 ) ];
  · -- By contradiction, assume there exists a polynomial $f$ such that $Nat.fib n \leq f (g n)$ for all $n$.
    by_contra h_contra
    obtain ⟨f, hf_poly, hf_bound⟩ := (simulates_sysOfSize_iff Nat.fib (fun n => if Even n then Nat.fib n else n)).mp h_contra;
    obtain ⟨ k, hk ⟩ := hf_poly.2;
    obtain ⟨ m, hm ⟩ := exp_dominates_poly 3 k;
    -- Combine the inequalities to get a contradiction.
    have h_contradiction : Nat.fib (2 * m + 1) ≤ (2 * m + 3) ^ k := by
      exact le_trans ( hf_bound _ ) ( by simpa using Nat.le_of_succ_le ( hk _ ) );
    exact absurd h_contradiction ( by linarith [ two_pow_le_fib m ] )

-- !-- comment: Density witness at the Fibonacci separation: a strictly intermediate
--             p-degree exists between `linSystem` and `fibSystem`. -- !--
/-- **Density (witness).**  There is a p-degree strictly between `linSystem` and
`fibSystem`: the simulation order is order-dense at the catalog's Fibonacci separation. -/
theorem exists_strictly_between_lin_fib :
    ∃ S : ProofSystem.{0, 0} ℕ, linSystem < S ∧ S < fibSystem :=
  ⟨interSys, lin_lt_inter, inter_lt_fib⟩

end ProofComplexity